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
        spec:RegisterPack( "Survival", 20201007.9, [[de0(3aqiPk9iHkQlraXMuvAuOi6uOiSkHkXRiOzrG2LGFPQQHHI0Xecldf1ZeImnHkCnHO2gbuFtQImoPkkNtOsToHksnpvvUhkzFeGfIc9qHksgPqfHtkvrLvkv1mLQOQDkv6Ncve9uPmvvf7vL)sXGvLdtAXq5XqMSixgzZI6ZeA0cPtlz1eq61cLzt0TrLDR0VvmCu1XLQWYbEoOPt11HQTJs13rbJxOQZJsz9cvsZxQy)u6lI7Z1sQtxxMzkZmncMY0EkWCemnoIJ4(AoB8014vumvKU2QC01A4a2l2v514v2KJMUpxdo4aeDTOUZdJt))Vy5rXXcOH7pS4WLQxZIaA2)dlo0)RHHxsVNBpSRLuNUUmZuMzAemLP9uG5iyACehrCnf3JoGR1koCP61SXPaA2Vw0kLO9WUwIGORfNTVgoG9IDvAFXjWxNa2(Xz7lojYhmcyF9KG2hZmLzMA7B7hNTVEEIDsAFcW(ImtdxtwqhEFUwIYkU0Vpx3iUpxtrEn714WJRXvjDnAvmjLogp)6Y895AkYRzVgoKmLtCWRrRIjP0X45x3iDFUgTkMKshJxtrEn71qQuAuKxZAKf0VMSGUzvo6AOe88RBCCFUgTkMKshJxdbkNaLEnf5f7KHwIRiO99Z(y(AkYRzVgsLsJI8AwJSG(1Kf0nRYrxd6NFDJ895A0QyskDmEneOCcu61uKxStgAjUIG2NaSViUMI8A2RHuP0OiVM1ilOFnzbDZQC01qsszNo)6kW3NRPiVM9AkaPlz8baO1VgTkMKshJNFD7P7Z1uKxZEnmv0mzJdkum41OvXKu6y88ZVgssk70956gX95A0QyskDmEneOCcu61CvsRhCcWbnt2qROksC06bAvmjLSVV2xEq4q77N9LheomWPXFnf51SxlQc4Nzp)6Y895AkYRzVgdLmzG8fOC41OvXKu6y88RBKUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaqCATq77N9jIs23x7dnJmnmSHSubuaqCATq77N9jIsxtrEn71CfyCGYF(1noUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaN)AkYRzVwwQa68RBKVpxtrEn71aeCw1Rv0OaWWW1OvXKu6y88RRaFFUgTkMKshJxdbkNaLETmUuAaekQcejJxCK99Z(erPRPiVM9AmuYuUaKbB4Wo)62t3NRPiVM9AOOAmGYbVgTkMKshJNFD7z3NRrRIjP0X41qGYjqPxlnEagfO8ljnydhwWluSAfTVV2htAFPXd16eyvPbtsuQwXa0vum77N9XS91PJ9LgpaJcu(LKgSHdlaioTwO99Z(erj7JjUMI8A2RHH7OOeGTZVUX995A0QyskDmEneOCcu61sJhGrbk)ssd2WHf8cfRwXRPiVM9AifWoD(1ncMEFUgTkMKshJxdbkNaLET8GWH2Nq7dPq3airATVF2xEq4WaNg)1uKxZETePEudkQgdOCNFDJiI7Z1uKxZEn0mGuTQtjJcHkU0VgTkMKshJNFDJG57Z1OvXKu6y8Aiq5eO0RHIQarcAYaf51SQ0(eG9XCiY23x7dnJmnmSbgkzkxaYGnCyHmUuAaekQcejJxCK9ja7dYtsPXvGi5q7tGyFmFnf51Sxdd3rrjaBNFDJis3NRrRIjP0X41qGYjqPxlpiCO9j0(qk0nasKw77N9LheomWPXFnf51Sxll1nwTIgOdQy05x3iIJ7Z1OvXKu6y8AkYRzVwSsknOHJt301qGYjqPxlpiCO9j0(qk0nasKw77N9LheomWPXBFFTVmUuAaekQcejJxCK99Z(erPRHydjjJRarYHx3io)6grKVpxJwftsPJXRHaLtGsVwV2xA8adLmLlazWgoSGxOy1kEnf51SxJHsMYfGmydh25x3ie47Z1OvXKu6y8Aiq5eO0RXK2xV23sX7ggkd2WHfGrbk)ss7Rth7Rx7ZvjTEGHsMYfGm1MXH1SbAvmjLSpMW((AFOzKPHHnWqjt5cqgSHdlKXLsdGqrvGiz8IJSpbyFqEsknUcejhAFce7J5RPiVM9Ay4okkby78RBe9095A0QyskDmEneOCcu61qZitddBGHsMYfGmydhwiJlLgaHIQarY4fhzFcW(G8KuACfiso0(ei2hZxtrEn71qkGD68RBe9S7Z1uKxZETyLuAGrh)A0QyskDmE(1nI4((Cnf51Sxllv2OKbgD8RrRIjP0X45xxMz695AkYRzVMA4WbjcyMSbbggGxJwftsPJXZVUmhX95A0QyskDmEneOCcu6161(a4lLhGifwccRvKbfWg04aLNVwrJYZRa1XHbQh4fppLSVoDSV8GWH2Nq7dPq3airATpH2hZr2((zF5bHddCA8xtrEn71GorsJdu(ZVUmZ895A0QyskDmEnf51SxdsaEADd0Rv8Aiq5eO0RbOmGGrvmjzFFTpxL06HOSLak0GvofOvXKu6Ai2qsY4kqKC41nIZVUmhP7Z1uKxZEnKcyNUgTkMKshJNFDzooUpxJwftsPJXRPiVM9AXkP0GgooDtxdbkNaLET8GWH2Nq7dPq3airATVF2xEq4WaNg)1qSHKKXvGi5WRBeNFDzoY3NRrRIjP0X41uKxZEnib4P1nqVwXRHaLtGsVgGYacgvXKK991(ys7Rx7ZvjTEaRajOzYgEaXwGwftsj7Rth7Rx7ddpNdOzaPAvNsgfcvCPhW5TpMW((AFmP91R9bWxkparkaytQXGUkJraObnBEW3uTIgOdQyemq9aV45PK91PJ9Tu8UHHYGnCyb2hP6LKSVoDSpxL06bmChfLaSfOvXKuY(yc7Rth7ddpNdSx8eaAyN2HlGZFneBijzCfiso86gX5xxMf47Z1OvXKu6y8AkYRzVg3SIZajdw501qGYjqPxlry45CqQoTUHFk4SMAfOeYRzdqxrXSpbyFX91qSHKKXvGi5WRBeNFDzUNUpxJwftsPJXRPiVM9AaL3hGb6GkgDneOCcu61segEohKQtRB4NcoRPwbkH8A2a0vum7ta2xCFneBijzCfiso86gX5xxM7z3NRrRIjP0X41uKxZEnib4P1nqVwXRHaLtGsVwV2NRsA9awbsqZKn8aITaTkMKs23x7Rx7ZvjTEG9INaqd70oCbAvmjLSVV2xV2haFP8aePGuDADd)uWzn1kqjKpayG6bEXZtj77R91R9bWxkparkaytQXGUkJraObnBEW3uTIgOdQyemq9aV45P01qSHKKXvGi5WRBeNFDzoUVpxJwftsPJXRPiVM9ACZkodKmyLtxdXgssgxbIKdVUrC(1nsm9(CnAvmjLogVMI8A2RbuEFagOdQy01qSHKKXvGi5WRBeNF(1qj4956gX95A0QyskDmEneOCcu61qZitddBandivR6uYOqOIl9aG40AH2NaSViX0RPiVM9AyYzsMmoGTZVUmFFUgTkMKshJxdbkNaLEn0mY0WWgqZas1QoLmkeQ4spaioTwO9ja7lsm9AkYRzVMUic6avAqQuE(1ns3NRrRIjP0X41qGYjqPxdnJmnmSb0mGuTQtjJcHkU0daItRfAFcW(IetVMI8A2RLlaHjNjD(1noUpxtrEn71KLyuhAeO4jroA9RrRIjP0X45x3iFFUgTkMKshJxdbkNaLEn0mY0WWgqZas1QoLmkeQ4spaioTwO9ja7tGzQ91PJ95fhz8XKkY((zFrePRPiVM9AyeasGy1kE(1vGVpxJwftsPJXRHaLtGsVwUeJ6gaXP1cTVF2hZcS91PJ9HHNZb0mGuTQtjJcHkU0d48xtrEn714hVM98RBpDFUgTkMKshJxdbkNaLEnxbIKhsf01fr2NayzFc81uKxZEnfYti3mzJhLmKkkPZp)Aq)(CDJ4(CnAvmjLogVgcuobk9AUkP1dob4GMjBOvufjoA9aTkMKs23x7lpiCO99Z(Ydchg404VMI8A2Rfvb8ZSNFDz((CnAvmjLogVgcuobk9A5bHdTpH2hsHUbqI0AF)SV8GWHbonE77R9HHNZbV4nt24rjdKNuqa6kkM99Z(IK991(61(CvsRhujFu1WdOK6diqRIjP01uKxZETyLuAqdhNUPZVUr6(CnAvmjLogVgcuobk9APXdWOaLFjPbB4WcEHIvRO991(ys7lnEOwNaRknysIs1kgGUIIzF)SpMTVoDSV04byuGYVK0GnCybaXP1cTVF2NikzFmH91PJ9HHNZbUzfNbsMmoGTaoV991(WWZ5a3SIZajtghWwaqCATq77N9Lheo0(ei2xKyQ9fxSpruY(60X(CvsRhWkqcAMSHhqSfOvXKuY((AFy45CandivR6uYOqOIl9aoV991(WWZ5aAgqQw1PKrHqfx6baXP1cTVF2NikDnf51SxJBwXzGKbRC68RBCCFUgTkMKshJxdbkNaLET04byuGYVK0GnCybVqXQv0((AFmP9LgpuRtGvLgmjrPAfdqxrXSVF2hZ2xNo2xA8amkq5xsAWgoSaG40AH23p7teLSpMW(60X(CvsRhWkqcAMSHhqSfOvXKuY((AFy45CandivR6uYOqOIl9aoV991(WWZ5aAgqQw1PKrHqfx6baXP1cTVF2NikDnf51SxdO8(amqhuXOZVUr((Cnf51SxJHsMmq(cuo8A0QyskDmE(1vGVpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaqCATq77N9jIs23x7dnJmnmSHSubuaqCATq77N9jIsxtrEn71CfyCGYF(1TNUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaN)AkYRzVwwQa68RBp7(Cnf51SxdndivR6uYOqOIl9RrRIjP0X45x34((Cnf51SxdqWzvVwrJcaddxJwftsPJXZVUrW07Z1uKxZETSuzJsgy0XVgTkMKshJNFDJiI7Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404VMI8A2RLi1JAqr1yaL78RBemFFUMI8A2RfRKsdm64xJwftsPJXZVUreP7Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404VMI8A2RLL6gRwrd0bvm68RBeXX95A0QyskDmEneOCcu61YdchAFcTpKcDdGeP1((zF5bHddCA823x7ddpNdEXBMSXJsgipPGa0vum77N9fj77R9LXLsdGqrvGiz8IJSVF2hZ2xCX(erPRPiVM9AXkP0GgooDtNFDJiY3NRPiVM9AOOAmGYbVgTkMKshJNFDJqGVpxtrEn71udhoiraZKniWWa8A0QyskDmE(1nIE6(CnAvmjLogVgcuobk9AlfVByOmydhwG9rQEjj77R9LgpajapTUb61kg8cfRwr77R9LgpajapTUb61kgaugqWOkMKUMI8A2RXqjt5cqgSHd78RBe9S7Z1OvXKu6y8Aiq5eO0RbOmGGrvmjzFFTpM0(WWZ5a3SIZajtghWwa6kkM99Z(IS91PJ91R95QKwpWnR4mqYGvofOvXKuY(yc77R9XK2xV2hgEohqZas1QoLmkeQ4spGZBFD6yF9AFUkP1dyfibnt2Wdi2c0QyskzFmH91PJ9HHNZb2lEcanSt7WfW5VMI8A2RbjapTUb61kE(1nI4((CnAvmjLogVgcuobk9AlfVByOmydhwagfO8ljTVV2xEq4q7ta2NaZu7Rth7BP4DddLbB4Wc8rjWWnlzFFTpM0(YdchAFcTpKcDdGeP1(eAFkYRzdXkP0GgooDtbKcDdGeP1(Il2xKSVF2xEq4WaNgV91PJ95QKwpWnR4mqYGvofOvXKuY((AF9AFy45CGBwXzGKjJdylGZBFmH91PJ91R9LgpWqjt5cqgSHdl4fkwTI23x7lJlLgaHIQarY4fhzF)Spru6AkYRzVgdLmLlazWgoSZVUmZ07Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404TVV2hgEoh8I3mzJhLmqEsbbOROy23p7lsxtrEn71IvsPbnCC6Mo)6YCe3NRrRIjP0X41qGYjqPxRx7dGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88uY(60X(YdchAFcTpKcDdGeP1(eAFmhz77N9LheomWPXFnf51Sxd6ejnoq5p)6YmZ3NRrRIjP0X41qGYjqPxdGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88uY((AF5bHdTpH2hsHUbqI0AFcTpMJS99Z(Ydchg404VMI8A2R5kW4aL)8RlZr6(CnAvmjLogVgcuobk9Aa8LYdqKclbH1kYGcydACGYZxROr55vG64Wa1d8INNs23x7lpiCO9j0(qk0nasKw7tO9XCKTVF2xEq4WaNg)1uKxZETmGO4ATIghO8NFDzooUpxJwftsPJXRHaLtGsVggEoh4MvCgizY4a2c482xNo2xEq4q7tO9PiVMneRKsdA440nfqk0nasKw7ta2xEq4WaNg)1uKxZEnUzfNbsgSYPZVUmh57Z1OvXKu6y8Aiq5eO0R1R9Tu8UHHYGnCybyuGYVK0(60X(WWZ5Gx8MjB8OKbYtkiaDffZ(eG9XS91PJ9Lheo0(eAFkYRzdXkP0GgooDtbKcDdGeP1(eG9LheomWPXFnf51SxdO8(amqhuXOZVUmlW3NRrRIjP0X41qGYjqPxddpNdEXBMSXJsgipPGa0vum77N9fPRPiVM9AXkP0GgooDtNFDzUNUpxJwftsPJXRHaLtGsVwV2xA8adLmLlazWgoSGxOy1kAFFTVETpxL06bgkzkxaYuBghwZgOvXKu6AkYRzVgdLmLlazWgoSZp)A8acnCyQFFUUrCFUgTkMKshJxdbkNaLEna(s5bisb4GlZdqKmehgbGbQh4fppLUMI8A2R5kW4aL)8RlZ3NRPiVM9AqNiPXbk)1OvXKu6y88RBKUpxtrEn71qZas1QoLmkeQ4s)A0QyskDmE(1noUpxJwftsPJXRPiVM9A8JxZETeBRYvidpG4h)ArC(5NFn2jaSM96YmtzMPmnUzoYH4(AmOGTwr416544hGtj7lY2NI8Aw7twqhgS9VgKNqxxMJCKVgpyYLKUwC2(A4a2l2vP9fNaFDcy7hNTV4KiFWiG91tcAFmZuMzQTVTFC2(65j2jP9ja7lYmny7B7RiVMfg4beA4WuxiR)Ucmoq5fSYSa4lLhGifGdUmparYqCyeagOEGx88uY2xrEnlmWdi0WHPUqw)HorsJduEBFf51SWapGqdhM6cz9hndivR6uYOqOIlDBFf51SWapGqdhM6cz9NF8AwbtSTkxHm8aIFCwry7B7RiVMfgqjOqw)XKZKmzCaBcwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbejMA7RiVMfgqjOqw)1frqhOsdsLsbRml0mY0WWgqZas1QoLmkeQ4spaioTwOaIetT9vKxZcdOeuiR)5cqyYzscwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbejMA7RiVMfgqjOqw)LLyuhAeO4jroADBFf51SWakbfY6pgbGeiwTIcwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbiWmTthV4iJpMur)Iis2(kYRzHbuckK1F(XRzfSYSYLyu3aioTw4pMf4oDWWZ5aAgqQw1PKrHqfx6bCEBFf51SWakbfY6Vc5jKBMSXJsgsfLKGvMLRarYdPc66IibWsGT9T9vKxZcfY6phECnUkjBFf51SqHS(Jdjt5eh02xrEnluiR)ivknkYRznYc6cUkhXcLG2(kYRzHcz9hPsPrrEnRrwqxWv5iwqxWkZsrEXozOL4kc(JzBFf51SqHS(JuP0OiVM1ilOl4QCelKKu2jbRmlf5f7KHwIRiOaIW2xrEnluiR)kaPlz8baO1T9vKxZcfY6pMkAMSXbfkg0232xrEnlmaDHS(hvb8ZScwzwUkP1dob4GMjBOvufjoA9aTkMKsFZdch(lpiCyGtJ32xrEnlmaDHS(hRKsdA440njyLzLheouisHUbqI0(lpiCyGtJ)lgEoh8I3mzJhLmqEsbbOROy)I03EDvsRhujFu1WdOK6diqRIjPKTVI8Awya6cz9NBwXzGKbRCsWkZknEagfO8ljnydhwWluSAf)YKPXd16eyvPbtsuQwXa0vuSFm3PtA8amkq5xsAWgoSaG40AH)erjMOthm8CoWnR4mqYKXbSfW5)IHNZbUzfNbsMmoGTaG40AH)YdchkqIetJlIOuNoUkP1dyfibnt2Wdi2c0Qysk9fdpNdOzaPAvNsgfcvCPhW5)IHNZb0mGuTQtjJcHkU0daItRf(teLS9vKxZcdqxiR)aL3hGb6GkgjyLzLgpaJcu(LKgSHdl4fkwTIFzY04HADcSQ0GjjkvRya6kk2pM70jnEagfO8ljnydhwaqCATWFIOet0PJRsA9awbsqZKn8aITaTkMKsFXWZ5aAgqQw1PKrHqfx6bC(Vy45CandivR6uYOqOIl9aG40AH)erjBFf51SWa0fY6pdLmzG8fOCOTVI8Awya6cz93vGXbkVGvMfaFP8aePaCWL5bisgIdJaWa1d8INNsFDfyCGYhaeNwl8Nik9fnJmnmSHSubuaqCATWFIOKTVI8Awya6cz9plvajyLzbWxkparkahCzEaIKH4Wiamq9aV45P0xxbghO8bCEBFf51SWa0fY6pAgqQw1PKrHqfx62(kYRzHbOlK1FabNv9Afnkammy7RiVMfgGUqw)ZsLnkzGrh32xrEnlmaDHS(Ni1JAqr1yaLtWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8Awya6cz9pwjLgy0XT9vKxZcdqxiR)zPUXQv0aDqfJeSYSYdchkePq3airA)LheomWPXB7RiVMfgGUqw)JvsPbnCC6MeSYSYdchkePq3airA)LheomWPX)fdpNdEXBMSXJsgipPGa0vuSFr6BgxknacfvbIKXlo6hZXfruY2xrEnlmaDHS(JIQXakh02xrEnlmaDHS(RgoCqIaMjBqGHbOTVI8Awya6cz9NHsMYfGmydhMGvM1sX7ggkd2WHfyFKQxs6BA8aKa806gOxRyWluSAf)MgpajapTUb61kgaugqWOkMKS9vKxZcdqxiR)qcWtRBGETIcwzwakdiyuftsFzsm8CoWnR4mqYKXbSfGUII9lYD60RRsA9a3SIZajdw5uGwftsjM4lt2lgEohqZas1QoLmkeQ4spGZ3PtVUkP1dyfibnt2Wdi2c0QyskXeD6GHNZb2lEcanSt7WfW5T9vKxZcdqxiR)muYuUaKbB4WeSYSwkE3WqzWgoSamkq5xs(npiCOaeyM2PZsX7ggkd2WHf4JsGHBw6ltMheouisHUbqI0kurEnBiwjLg0WXPBkGuOBaKiTXLi9lpiCyGtJVthxL06bUzfNbsgSYPaTkMKsF7fdpNdCZkodKmzCaBbCEMOtNEtJhyOKPCbid2WHf8cfRwXVzCP0aiuufisgV4OFIOKTVI8Awya6cz9pwjLg0WXPBsWkZkpiCOqKcDdGeP9xEq4WaNg)xm8Co4fVzYgpkzG8KccqxrX(fjBFf51SWa0fY6p0jsACGYlyLz1laFP8aePWsqyTImOa2GghO881kAuEEfOoomq9aV45PuNo5bHdfIuOBaKiTczoY)Ydchg404T9vKxZcdqxiR)Ucmoq5fSYSa4lLhGifwccRvKbfWg04aLNVwrJYZRa1XHbQh4fppL(MheouisHUbqI0kK5i)lpiCyGtJ32xrEnlmaDHS(NbefxRv04aLxWkZcGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88u6BEq4qHif6gajsRqMJ8V8GWHbonEBFf51SWa0fY6p3SIZajdw5KGvMfgEoh4MvCgizY4a2c48D6KheouOI8A2qSsknOHJt3uaPq3airAfqEq4WaNgVTVI8Awya6cz9hO8(amqhuXibRmRExkE3WqzWgoSamkq5xs2PdgEoh8I3mzJhLmqEsbbOROycG5oDYdchkurEnBiwjLg0WXPBkGuOBaKiTcipiCyGtJ32xrEnlmaDHS(hRKsdA440njyLzHHNZbV4nt24rjdKNuqa6kk2Viz7RiVMfgGUqw)zOKPCbid2WHjyLz1BA8adLmLlazWgoSGxOy1k(TxxL06bgkzkxaYuBghwZgOvXKuY232xrEnlmGKKYojK1)OkGFMvWkZYvjTEWjah0mzdTIQiXrRhOvXKu6BEq4WF5bHddCA82(kYRzHbKKu2jHS(ZqjtgiFbkhA7RiVMfgqsszNeY6VRaJduEbRmla(s5bisb4GlZdqKmehgbGbQh4fppL(6kW4aLpaioTw4pru6lAgzAyydzPcOaG40AH)erjBFf51SWassk7Kqw)Zsfqcwzwa8LYdqKcWbxMhGiziomcadupWlEEk91vGXbkFaN32xrEnlmGKKYojK1FabNv9Afnkammy7RiVMfgqsszNeY6pdLmLlazWgombRmRmUuAaekQcejJxC0pruY2xrEnlmGKKYojK1Fuungq5G2(kYRzHbKKu2jHS(JH7OOeGnbRmR04byuGYVK0GnCybVqXQv8ltMgpuRtGvLgmjrPAfdqxrX(XCNoPXdWOaLFjPbB4WcaItRf(teLycBFf51SWassk7Kqw)rkGDsWkZknEagfO8ljnydhwWluSAfT9vKxZcdijPStcz9prQh1GIQXakNGvMvEq4qHif6gajs7V8GWHbonEBFf51SWassk7Kqw)rZas1QoLmkeQ4s32xrEnlmGKKYojK1FmChfLaSjyLzHIQarcAYaf51SQuamhI8x0mY0WWgyOKPCbid2WHfY4sPbqOOkqKmEXrcaYtsPXvGi5qbcZ2(kYRzHbKKu2jHS(NL6gRwrd0bvmsWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8AwyajjLDsiR)XkP0GgooDtcIydjjJRarYHSIqWkZkpiCOqKcDdGeP9xEq4WaNg)3mUuAaekQcejJxC0pruY2xrEnlmGKKYojK1FgkzkxaYGnCycwzw9MgpWqjt5cqgSHdl4fkwTI2(kYRzHbKKu2jHS(JH7OOeGnbRmlMS3LI3nmugSHdlaJcu(LKD60RRsA9adLmLlazQnJdRzd0QyskXeFrZitddBGHsMYfGmydhwiJlLgaHIQarY4fhjaipjLgxbIKdfimB7RiVMfgqsszNeY6psbStcwzwOzKPHHnWqjt5cqgSHdlKXLsdGqrvGiz8IJeaKNKsJRarYHceMT9vKxZcdijPStcz9pwjLgy0XT9vKxZcdijPStcz9plv2OKbgDCBFf51SWassk7Kqw)vdhoiraZKniWWa02xrEnlmGKKYojK1FOtK04aLxWkZQxa(s5bisHLGWAfzqbSbnoq55Rv0O88kqDCyG6bEXZtPoDYdchkePq3airAfYCK)LheomWPXB7RiVMfgqsszNeY6pKa806gOxROGi2qsY4kqKCiRieSYSaugqWOkMK(6QKwpeLTeqHgSYPaTkMKs2(kYRzHbKKu2jHS(Jua7KTVI8AwyajjLDsiR)XkP0GgooDtcIydjjJRarYHSIqWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8AwyajjLDsiR)qcWtRBGETIcIydjjJRarYHSIqWkZcqzabJQys6lt2RRsA9awbsqZKn8aITaTkMKsD60lgEohqZas1QoLmkeQ4spGZZeFzYEb4lLhGifaSj1yqxLXia0GMnp4BQwrd0bvmcgOEGx88uQtNLI3nmugSHdlW(ivVKuNoUkP1dy4okkbylqRIjPet0PdgEohyV4ja0WoTdxaN32xrEnlmGKKYojK1FUzfNbsgSYjbrSHKKXvGi5qwriyLzLim8CoivNw3WpfCwtTcuc51SbOROyciUT9vKxZcdijPStcz9hO8(amqhuXibrSHKKXvGi5qwriyLzLim8CoivNw3WpfCwtTcuc51SbOROyciUT9vKxZcdijPStcz9hsaEADd0RvuqeBijzCfisoKvecwzw96QKwpGvGe0mzdpGylqRIjP03EDvsRhyV4ja0WoTdxGwftsPV9cWxkparkivNw3WpfCwtTcuc5dagOEGx88u6BVa8LYdqKca2KAmORYyeaAqZMh8nvROb6GkgbdupWlEEkz7RiVMfgqsszNeY6p3SIZajdw5KGi2qsY4kqKCiRiS9vKxZcdijPStcz9hO8(amqhuXibrSHKKXvGi5qwrC(53b]] )
    else
        spec:RegisterPack( "Survival", 20201007.1, [[dCeZ2bqifQEKiKCjrisBsenkfkDkfkwfrv9kfXSiQClfvv7IKFrummivogeSmIQ8mrOMMIQY1Gi2MIQ4BqQsJtrv6CqQI1jcrP5bHUhrAFqKoOieQfsu6HIqaUOievBuec0ifHqCsriIvcrntriKUPieq7es8trikgQieupfWuHK(QieK9c1FrAWu6WuTyv8yetwuxg1Mj1NfPrRiDAjRwes9AiLztXTbA3k9BPgUcwoONRQPlCDvA7kkFxHmEfvoViy9qQQ5te7NWyeWOIbYEWyuKh6Kh6qaDOd9QKhcOBEriXyGiHbgdm4e08ugdSoiJbaUWz1m3Gbg8emTNXOIb((cjmgyAedFISYitAftVhfPbL5lWRXJQxc01HmFbsKbdCULjsKS4dgi7bJrrEOtEOdb0Ho0RsEiGo0lsMhmGFJPnedauGxJhvVjca66admTYzEXhmqMFcgirjSax4SAMBe2erUBWqbYjkHnrgs0hgkSOx5ew5Ho5HobYcKtucBIO8m2iSivyrc6uyat9XJrfd4dFGrfJccyuXaojQEXaOvgd9N2bgGx)y4mwwCGrrEyuXa86hdNXYIbiWkyy5yGZvRvKUH5A9GZu)F)Ac1DqytkSJvypxTwr6gMR1dot9)9Rjuqg0R9fwefweuiryLVWMsYcRejc75Q1QJ5cPTMgUP3xDhe2Kc75Q1QJ5cPTMgUP3xbzqV2xyruyrqHeHv(cBkjlSJbd4KO6fda2BA3ptpvW4aJsIXOIb41pgoJLfdqGvWWYXaNRwRiDdZ16bNP()(1eQ7GWMuyhRWEUATI0nmxRhCM6)7xtOGmOx7lSikSiOqIWkFHnLKfwjse2ZvRvhZfsBnnCtVV6oiSjf2ZvRvhZfsBnnCtVVcYGETVWIOWIGcjcR8f2uswyhdgWjr1lga6drdPFal0yCGrz(WOIb41pgoJLfdqGvWWYXa6MCFHDIWs8pOqoLxHfrHv3K7Ra95WaojQEXaAJVOvBk9dyHgJdmkibJkgGx)y4mwwmGtIQxmaALXqjniOVzmabwbdlhdOVgdfYKPomLPrbYclIclckKiSYxytjzHnPWQBY9f2jclX)Gc5uEfwefwDtUVc0NddqsGyyA4WuoEmkiGdmkZdgvmaV(XWzSSyacScgwogq3K7lStewI)bfYP8kSikS6MCFfOphgWjr1lg4dMn0a6d4aJc6fJkgGx)y4mwwmabwbdlhdOBY9f2jclX)Gc5uEfwefwDtUVc0NtytkSJlSrrqR2uHnPWoUWEUATcKbByc0wtnxsLPzi7GV6oiSjf2XkS6RXqHmzQdtzAuGSWIOWIGcjcR8f2uswyLiryhxyZDOgvMSUGm90Ghvue0QnvytkSJlSNRwRiDdZ16bNP()(1eQ7GWkrIWoUWM7qnQmzDbz6PbpQOiOvBQWMuypxTwb2BA3pt1xycQpCcAclIclcc7yewjse2OazA00CXclIclcZRWMuyhxyZDOgvMSUGm90Ghvue0Qnfd4KO6fdmQmzDbz6Pbp4aJY8IrfdWRFmCgllgGaRGHLJbgxyZDOEgoWBq)O2uvue0QnvytkSJlSNRwRiDdZ16bNP()(1eQ7agWjr1lg4z4aVb9JAtXbgf0dgvmaV(XWzSSyaNevVya0kJHsAqqFZyacScgwogq3K7lStewI)bfYP8kSikS6MCFfOpNWMuyhRWEUATcS30UFMQVWeuF4e0ewefwKiSsKiS6MCFHfrH1jr1RcS30UFMEQGvK(dHDmyascedtdhMYXJrbbCGrbb0HrfdWRFmCgllgGaRGHLJbGSgY)u)yyHnPWoUWEUATI0nmxRhCM6)7xtOUdcBsH9C1AfyVPD)mvFHjO(WjOjSikSibd4KO6fd8mCG3G(rTP4aJcciGrfdWRFmCgllgGaRGHLJbgxypxTwr6gMR1dot9)9Rju3bmGtIQxmGtbVWmdPTMsG9OhhyuqqEyuXa86hdNXYIbiWkyy5yGXf2ZvRvKUH5A9GZu)F)Ac1Dad4KO6fdq6gMR1dot9)9RjWbgfesmgvmaV(XWzSSyacScgwog4C1AfyVPD)mvFHjOUdcRejcRUj3xyNiSe)dkKt5vyrQWQBY9vG(Cc78lSiGoHvIeH9C1AfPByUwp4m1)3VMqDhWaojQEXaG9M29Z0tfmoWOGW8Hrfd4KO6fda9HOH0pGfAmgGx)y4mwwCGrbbKGrfdWRFmCgllgGaRGHLJbgxyJIGwTPyaNevVyGrLjRlitpn4bh4admsxyuXOGagvmGtIQxmaALXq)PDGb41pgoJLfhyuKhgvmaV(XWzSSyacScgwogq3K7lStewI)bfYP8kSikS6MCFfOpNWMuyd3WBOcgc(0wt5n1tzqEdfV(XWzmGtIQxmWuho09IdmkjgJkgGx)y4mwwmabwbdlhdCUAT6yUqARPHB69v3bHnPWEUAT6yUqARPHB69vqg0R9fwef2usgd4KO6fda2BA3ptpvW4aJY8HrfdWRFmCgllgGaRGHLJboxTwDmxiT10Wn9(Q7GWMuypxTwDmxiT10Wn9(kid61(clIcBkjJbCsu9IbG(q0q6hWcnghyuqcgvmaV(XWzSSyacScgwog4C1A1SAGHpDgVnO6oiSjf2ZvRvZQbg(0z82Gkid61(clIclckKiSYxytjzHvIeHDCHn3H6z4aVb9JAtvrrqR2umGtIQxmWZWbEd6h1MIdmkZdgvmaV(XWzSSyacScgwogqFngkKjtDyktJcKfwefweuiryLVWMsYcBsHv3K7lStewI)bfYP8kSikS6MCFfOpNWkrIWowHD55c6OIEAWJAwB8OmSWMuyZDOEgoWBq)O2uvue0QnvytkS5oupdh4nOFuBQcYAi)t9JHfwjse2LNlOJk6PbpQHPmSb7Lf2Kc74c75Q1kWEt7(zQ(ctqDhe2KcRUj3xyNiSe)dkKt5vyruy1n5(kqFoHD(fwNevVk0kJHsAqqFZkI)bfYP8kSYxytSWogmGtIQxmWOYK1fKPNg8GdmkOxmQyaE9JHZyzXaojQEXaOvgdL0GG(MXaeyfmSCmGUj3xyNiSe)dkKt5vyruy1n5(kqFoHD(fwDtUVcYP8IbijqmmnCykhpgfeWbgL5fJkgWjr1lgWPGxyMH0wtjWE0Jb41pgoJLfhyuqpyuXa86hdNXYIbiWkyy5yaDtUVWoryj(huiNYRWIOWQBY9vG(CyaNevVyGpy2qdOpGdmkiGomQyaE9JHZyzXaeyfmSCmG(AmuitM6WuMgfilSikSiOqIWkFHnLKXaojQEXaJktwxqMEAWdoWOGacyuXaojQEXaKUH5A9GZu)F)AcmaV(XWzSS4aJccYdJkgGx)y4mwwmabwbdlhdCUATAwnWWNoJ3guDhe2KcBUd1ZWbEd6h1MQGmOx7lSikSZNWkFHnLKXaojQEXapdh4nOFuBkoWOGqIXOIb41pgoJLfdqGvWWYXa5ou)uOpSSHEAWJkkcA1MkSsKiSNRwRa7nT7NP6lmb1hobnHvQWIemGtIQxmayVPD)m9ubJdmkimFyuXa86hdNXYIbiWkyy5yGLNlOJk6PbpQFk0hw2iSjf2ChQNHd8g0pQnvbzqV2xyrQWIeHv(cBkjJbCsu9IbgvMSUGm90GhCGrbbKGrfdWRFmCgllgGaRGHLJbGSgY)u)yymGtIQxmWZWbEd6h1MIdmkimpyuXa86hdNXYIbiWkyy5yGXf2ZvRvG9M29Zu9fMGcYGETpgWjr1lgGm1rd6GpoWOGa6fJkgWjr1lgaS30UFMEQGXa86hdNXYIdmkimVyuXaojQEXaqFiAi9dyHgJb41pgoJLfhyuqa9GrfdWRFmCgllgGaRGHLJboxTwnRgy4tNXBdQUdyaNevVyGNHd8g0pQnfhyuKh6WOIb41pgoJLfdqGvWWYXalpxqhv0tdEuZAJhLHf2KcBUd1ZWbEd6h1MQIIGwTPcRejc7YZf0rf90Gh1Wug2G9YcRejc7YZf0rf90Gh1pf6dlBWaojQEXaJktwxqMEAWdoWbgWhgPlmQyuqaJkgWjr1lgaTYyO)0oWa86hdNXYIdmkYdJkgGx)y4mwwmabwbdlhdCUAT6yUqARPHB69v3bHnPWEUAT6yUqARPHB69vqg0R9fwef2usgd4KO6fda2BA3ptpvW4aJsIXOIb41pgoJLfdqGvWWYXaNRwRoMlK2AA4MEF1DqytkSNRwRoMlK2AA4MEFfKb9AFHfrHnLKXaojQEXaqFiAi9dyHgJdmkZhgvmaV(XWzSSyacScgwogyCHn3H6z4aVb9JAtvrrqR2umGtIQxmWZWbEd6h1MIdmkibJkgWjr1lgWPGxyMH0wtjWE0Jb41pgoJLfhyuMhmQyaE9JHZyzXaeyfmSCmG(AmuitM6WuMgfilSikSiOqIWkFHnLKfwjsewDtUVWoryj(huiNYRWIOWQBY9vG(CcBsHDSc7YZf0rf90Gh1S24rzyHnPWM7q9mCG3G(rTPQOiOvBQWMuyZDOEgoWBq)O2ufK1q(N6hdlSsKiSlpxqhv0tdEudtzyd2llSjf2Xf2ZvRvG9M29Zu9fMG6oiSjfwDtUVWoryj(huiNYRWIOWQBY9vG(Cc78lSojQEvOvgdL0GG(Mve)dkKt5vyLVWMyHDmyaNevVyGrLjRlitpn4bhyuqVyuXaojQEXaKUH5A9GZu)F)AcmaV(XWzSS4aJY8IrfdWRFmCgllgGaRGHLJboxTwb2BA3pt1xyckid61(cBsHD55c6OIEAWJAykdBWEzmGtIQxmayVPD)m9ubJdmkOhmQyaE9JHZyzXaojQEXaOvgdL0GG(MXaeyfmSCmG(AmuitM6WuMgfilSikSiOqIWkFHnLKf2KcRUj3xyNiSe)dkKt5vyruy1n5(kqFoHD(fw5HomajbIHPHdt54XOGaoWOGa6WOIb41pgoJLfdqGvWWYXa6MCFHDIWs8pOqoLxHfrHv3K7Ra95WaojQEXaFWSHgqFahyuqabmQyaE9JHZyzXaeyfmSCmW5Q1QOgOTMgtz6pWou9HtqtyLkSjwyLiryZDO(PqFyzd90Ghvue0Qnfd4KO6fda9HOH0pGfAmoWOGG8WOIb41pgoJLfdqGvWWYXa5ou)uOpSSHEAWJkkcA1MIbCsu9Iba7nT7NPNkyCGrbHeJrfdWRFmCgllgGaRGHLJbwEUGoQONg8O(PqFyzJWMuy1n5(clsf2eJoHnPWM7q9mCG3G(rTPkid61(clsfwKiSYxytjzmGtIQxmWOYK1fKPNg8GdmkimFyuXa86hdNXYIbiWkyy5yGXf2ZvRvG9M29Zu9fMGcYGETpgWjr1lgGm1rd6GpoWOGasWOIb41pgoJLfdqGvWWYXaqwd5FQFmmgWjr1lg4z4aVb9JAtXbgfeMhmQyaE9JHZyzXaojQEXaOvgdL0GG(MXaeyfmSCmGUj3xyNiSe)dkKt5vyruy1n5(kqFoHnPWowH9C1AfyVPD)mvFHjO(WjOjSikSiryLiry1n5(clIcRtIQxfyVPD)m9ubRi9hc7yWaKeigMgomLJhJcc4aJccOxmQyaNevVyaOpenK(bSqJXa86hdNXYIdmkimVyuXa86hdNXYIbiWkyy5yGZvRvG9M29Zu9fMG6oiSsKiS6MCFHfPc78HoHvIeHn3H6Nc9HLn0tdEurrqR2umGtIQxmayVPD)m9ubJdmkiGEWOIb41pgoJLfdqGvWWYXalpxqhv0tdEuZAJhLHf2KcBUd1ZWbEd6h1MQIIGwTPcRejc7YZf0rf90Gh1Wug2G9YcRejc7YZf0rf90Gh1pf6dlBe2KcRUj3xyrQWIe0HbCsu9IbgvMSUGm90GhCGdmaXW(mgJkgfeWOIb41pgoJLfd0dyGNJsJbCsu9IbM5WYpggdmZH01bzmaXHZykjdXaeyfmSCmGtIAgt5Lbl(fwefwKGbM5MltzZZyaKGbM5MlJbCsuZykVmyXpoWOipmQyaE9JHZyzXaeyfmSCmGJ(mScwDmxiT10Wn9(kOVOjSivyrNWMuyhRWEUATI0nmxRhCM6)7xtOUdcBsHDSc75Q1ks3WCTEWzQ)VFnHcYGETVWIOWIGcjcR8f2uswyLirypxTwDmxiT10Wn9(Q7GWMuypxTwDmxiT10Wn9(kid61(clIclckKiSYxytjzHvIeH9C1AfPByUwp4m1)3VMqbzqV2xytkSJlSNRwRoMlK2AA4MEFfKb9AFHDmc7yWaojQEXaG9M29Z0tfmoWOKymQyaE9JHZyzXaojQEXaG9M29Z0tfmgGaRGHLJbY85Q1kJh8g0HU(EvF4e0ewKkSJvyDsuZykVmyXVWkrIWIEe2XiSjf2WHPCOIcKPrtZflSikSojQzmLxgS4xyLVWMsYyascedtdhMYXJrbbCGrz(WOIbCsu9IbCk4fMziT1ucSh9yaE9JHZyzXbgfKGrfd4KO6fdq6gMR1dot9)9RjWa86hdNXYIdmkZdgvmaV(XWzSSyacScgwogi3H6Nc9HLn0tdEurrqR2uHnPWoUWgUH3qnnHm0F6PcwXRFmCwyLiryZDO(PqFyzd90Ghvue0QnvytkSojQzmLxgS4xyrQWIemGtIQxmaXHZyCGrb9IrfdWRFmCgllgGaRGHLJbgxyd3WBOsVmewgJtdNef5v86hdNfwjsew91yOqMm1HPmnkqwyruytjzHvIeHf6vMYZ4nuEo)kid61(clIc78iSjfwOxzkpJ3q558R45QpEmGtIQxmWOYK1fKPNg8GdmkZlgvmaV(XWzSSyacScgwogGm1HP8t1qNevVUryrQWkpfsewjse2ChQFk0hw2qpn4rffbTAtfwjsews3MCpAvJktwxqMEAWJcYGETVWIuH1jrnJP8YGf)c78lSPKSWkrIWM5ZvRvht3zARPXuMYldMGcYGETVWkrIWc9kt5z8gkpNFfKb9AFHfrHfjcBsHf6vMYZ4nuEo)kEU6Jhd4KO6fdCUbzkdtahyuqpyuXa86hdNXYIbCsu9Iba7nT7NPNkymabwbdlhdK5ZvRvgp4nOdD99Q(WjOjSivyNxmajbIHPHdt54XOGaoWOGa6WOIbCsu9IbitD0Go4Jb41pgoJLfhyuqabmQyaE9JHZyzXaojQEXaOvgdL0GG(MXaeyfmSCmGUj3xyNiSe)dkKt5vyruy1n5(kqFomajbIHPHdt54XOGaoWOGG8WOIb41pgoJLfdqGvWWYXaHB4nubdbFARP8M6PmiVHIx)y4mgWjr1lgyQdh6EXbgfesmgvmaV(XWzSSyacScgwogiCdVHk9YqyzmonCsuKxXRFmCgd4KO6fdqC4mghyuqy(WOIb41pgoJLfdqGvWWYXaKUn5E0QgvMSUGm90GhfKb9AFHfPc7yfwNe1mMYldw8lSsKiSiryhdgWjr1lg4CdYugMaoWOGasWOIb41pgoJLfdqGvWWYXa6MCFHDIWs8pOqoLxHfrHv3K7Ra95WaojQEXaAJVOvBk9dyHgJdmkimpyuXa86hdNXYIbiWkyy5yGChQrLjRlitpn4rbznK)P(XWcRejcB4gEd1OYK1fKP1QVF1RIx)y4mgWjr1lgyuzY6cY0tdEWbgfeqVyuXa86hdNXYIbCsu9IbEgoWBq)O2umabwbdlhdCUATAwnWWNoJ3gubzNeyascedtdhMYXJrbbCGrbH5fJkgGx)y4mwwmabwbdlhdq62K7rRAuzY6cY0tdEuqg0R9fwKkSZCy5hdRioCgtjzOWMivyLhgWjr1lgG4WzmoWOGa6bJkgWjr1lg4dMn0a6dyaE9JHZyzXbgf5HomQyaE9JHZyzXaojQEXapdh4nOFuBkgGaRGHLJbGSgY)u)yyHnPWEUATkQbARPXuM(dSdvF4e0ewef2elSjf2LNlOJk6PbpQzTXJYWcRejclK1q(N6hdlSjfwh9zyfSY4bVbDORVxf0x0ewKkSOddqsGyyA4WuoEmkiGdmkYdbmQyaE9JHZyzXaojQEXaG9M29Z0tfmgGKaXW0WHPC8yuqahyuKN8WOIb41pgoJLfd4KO6fda9HOH0pGfAmgGKaXW0WHPC8yuqah4adKzTFnbgvmkiGrfd4KO6fdaErF03WyaE9JHZyzXbgf5Hrfd4KO6fdCFMwbd(yaE9JHZyzXbgLeJrfdWRFmCgllgWjr1lgG4gd1jr1l1uFGbm1h01bzmaj)4aJY8HrfdWRFmCgllgGaRGHLJbCsuZykVmyXVWkvyrqytkSHdt5qffitJMMlwyruy1n5(cBIuHDScRtIQxfyVPD)m9ubRi9hc78lSe)dkKt5vyhJWkFHnLKXaojQEXaG9M29Z0tfmoWOGemQyaE9JHZyzXaeyfmSCmGtIAgt5Lbl(fwef2elSjf2Wn8gkYuhnOd(kE9JHZcBsHnCdVHYndtD6aKZE0qfV(XWzmGtIQxmaXngQtIQxQP(adyQpORdYyaFyKUWbgL5bJkgGx)y4mwwmabwbdlhd4KOMXuEzWIFHfrHnXcBsHnCdVHIm1rd6GVIx)y4mgWjr1lgG4gd1jr1l1uFGbm1h01bzmWiDHdmkOxmQyaE9JHZyzXaeyfmSCmGtIAgt5Lbl(fwef2elSjf2Xf2Wn8gk3mm1Pdqo7rdv86hdNf2Kc74cB4gEd1OYK1fKP1QVF1RIx)y4mgWjr1lgG4gd1jr1l1uFGbm1h01bzmWh4aJY8IrfdWRFmCgllgGaRGHLJbCsuZykVmyXVWIOWMyHnPWgUH3q5MHPoDaYzpAOIx)y4SWMuyhxyd3WBOgvMSUGmTw99REv86hdNXaojQEXae3yOojQEPM6dmGP(GUoiJb8HpWbgf0dgvmaV(XWzSSyacScgwogWjrnJP8YGf)clIcBIf2KcB4gEdLBgM60biN9OHkE9JHZcBsHnCdVHAuzY6cY0A13V6vXRFmCgd4KO6fdqCJH6KO6LAQpWaM6d66GmgWhgPlCGrbb0HrfdWRFmCgllgGaRGHLJbCsuZykVmyXVWIOWMyHnPWoUWgUH3q5MHPoDaYzpAOIx)y4SWMuyd3WBOgvMSUGmTw99REv86hdNXaojQEXae3yOojQEPM6dmGP(GUoiJbgPlCGrbbeWOIb41pgoJLfdqGvWWYXaojQzmLxgS4xyrQWIGWMuyhxyd3WBOofm)0wthGCckE9JHZcRejcRtIAgt5Lbl(fwKkSYdd4KO6fdqCJH6KO6LAQpWaM6d66GmgGyyFgJdmkiipmQyaNevVyasVeEdOhCMQnoiJb41pgoJLfhyuqiXyuXaojQEXaoK4ltJgc5nWa86hdNXYIdmkimFyuXaojQEXahpL2AAalcApgGx)y4mwwCGdmaj)yuXOGagvmaV(XWzSSyacScgwogG0Tj3JwfPByUwp4m1)3VMqbzqV2xyrQWMy0HbCsu9IboMUZu9fMaoWOipmQyaE9JHZyzXaeyfmSCmaPBtUhTks3WCTEWzQ)VFnHcYGETVWIuHnXOdd4KO6fd4lH)a6gkXngCGrjXyuXa86hdNXYIbiWkyy5yas3MCpAvKUH5A9GZu)F)AcfKb9AFHfPcBIrhgWjr1lgqxq(y6oJdmkZhgvmGtIQxmGPsNgpnrFZPG8gyaE9JHZyzXbgfKGrfdWRFmCgllgGaRGHLJbiDBY9Ovr6gMR1dot9)9Rjuqg0R9fwKkSZd6ewjse2OazA00CXclIclcjgd4KO6fdCy4Zq0QnfhyuMhmQyaE9JHZyzXaeyfmSCmW5Q1Q0RdZLV0wtD0NHDmvDhe2Kc7yf2ZvRvhg(meTAtv3bHvIeH9C1A1X0DMQVWeu3bHvIeHDCHf6ewfW2ye2XiSsKiSJvyj9(xq)yy1qhvV0wtV7bwzdNP6lmbHnPWQR0PbfYGETVWIOWopiiSsKiS6kDAqHmOx7lSikSYBEe2XiSsKiSJlS8)8syfP3mVpNPMsZ6gsyfONOBOWMuypxTwr6gMR1dot9)9Rju3bmGtIQxmWqhvV4aJc6fJkgGx)y4mwwmabwbdlhdeomLdvU(WxclSivQWopyaNevVya)hysqBnnMYu2tnmoWOmVyuXa86hdNXYIbCsu9Ib8F6mF5NcD0VHusdDdgGaRGHLJboxTwbYGnmbARPMlPY0mKDWxDhe2KcRUsNguid61(clIclPBtUhTkqgSHjqBn1CjvMMHSd(kid61(c7eHfbKiSsKiSNRwRsVomx(sBn1rFg2Xu1hobnHvQWIeHnPWQR0PbfYGETVWIOWs62K7rRk96WC5lT1uh9zyhtvqg0R9f2jcR8qNWkrIWM5ZvRvqh9BiL0q3qZ85Q1QCpAfwjsewDLonOqg0R9fwefw5HGWkrIWEUATAudn5zCTui)96lHvqg0R9f2KcRUsNguid61(clIclPBtUhTQrn0KNX1sH83RVewbzqV2xyNiSimVcRejc74cB4gEd1PG5N2A6aKtqXRFmCwytkS6kDAqHmOx7lSikSKUn5E0QiDdZ16bNP()(1ekid61(c7eHvEOtytkSNRwRiDdZ16bNP()(1ekid61(yG1bzmG)tN5l)uOJ(nKsAOBWbgf0dgvmaV(XWzSSyaNevVyGu3We3yy4tpDVyacScgwogG0Tj3Jwfid2WeOTMAUKktZq2bFfKb9AFHvIeHnCdVHAuzY6cY0A13V6vXRFmCwytkSKUn5E0QiDdZ16bNP()(1ekid61(cRejc74cl)pVewbYGnmbARPMlPY0mKDWxb6j6gkSjfws3MCpAvKUH5A9GZu)F)AcfKb9AFmW6Gmgi1nmXngg(0t3loWOGa6WOIb41pgoJLfdSoiJbC0)N6q)P6EdARPd9igIbCsu9IbC0)N6q)P6EdARPd9igIdmkiGagvmaV(XWzSSyacScgwoga6vMYZ4nuEo)QAfwKkSOh0jSjfwDtUVWIOWQBY9vG(Cc78lSYdjcRejc7yfwNe1mMYldw8lSivyrqytkSJlSHB4nuNcMFARPdqobfV(XWzHvIeH1jrnJP8YGf)clsfw5jSJrytkSJvypxTwDmxiT10Wn9(Q7GWMuypxTwDmxiT10Wn9(kid61(clsf2elSYxytjzHvIeHDCH9C1A1XCH0wtd307RUdc7yWaojQEXa6MCFotD0NHvW0d7G4aJccYdJkgGx)y4mwwmabwbdlhdmwHDScl0RmLNXBO8C(vqg0R9fwKkSOh0jSsKiSJlSqVYuEgVHYZ5xXZvF8c7yewjse2XkSojQzmLxgS4xyrQWIGWMuyhxyd3WBOofm)0wthGCckE9JHZcRejcRtIAgt5Lbl(fwKkSYtyhJWogHnPWQBY9fwefwDtUVc0Ndd4KO6fdCmDNPTMgtzkVmyc4aJccjgJkgGx)y4mwwmabwbdlhdmwHDScl0RmLNXBO8C(vqg0R9fwKkSZd6ewjse2XfwOxzkpJ3q558R45QpEHDmcRejc7yfwNe1mMYldw8lSivyrqytkSJlSHB4nuNcMFARPdqobfV(XWzHvIeH1jrnJP8YGf)clsfw5jSJryhJWMuy1n5(clIcRUj3xb6ZHbCsu9IbgUWsNqTP0JX)ahyuqy(WOIbCsu9IbsVomx(sBn1rFg2XumaV(XWzSS4aJccibJkgWjr1lgawddgMwl9hCcJb41pgoJLfhyuqyEWOIb41pgoJLfdqGvWWYXa6RXqHmzQdtzAuGSWIOWIGWkFHnLKXaojQEXaKEj8gqp4mvBCqghyuqa9IrfdWRFmCgllgGaRGHLJboxTwbzcAg(FQUHewDhWaojQEXaXuME3tF3mv3qcJdmkimVyuXaojQEXaJAOjpJRLc5VxFjmgGx)y4mwwCGrbb0dgvmaV(XWzSSyacScgwogiCykhQPSBIPQbsiSivyNx0jSsKiSHdt5qnLDtmvnqcHfrPcR8qNWkrIWgomLdvuGmnA6ajOYdDclsf2eJomGtIQxmaK9HAtPAJdYpoWOip0HrfdWRFmCgllgGaRGHLJb4)5LWkqgSHjqBn1CjvMMHSd(kqpr3qHnPWcznK)P(XWcBsH9C1A1SAGHpDgVnO6oiSjf2Xfws3MCpAvGmydtG2AQ5sQmndzh8vqg0R9XaojQEXapdh4nOFuBkoWOipeWOIb41pgoJLfdqGvWWYXa8)8syfid2WeOTMAUKktZq2bFfONOBOWMuyhxyjDBY9OvbYGnmbARPMlPY0mKDWxbzqV2hd4KO6fda2BA3ptpvW4aJI8KhgvmaV(XWzSSyacScgwogG)NxcRazWgMaT1uZLuzAgYo4Ra9eDdf2KcR(AmuitM6WuMgfilSikSiOqIWkFHnLKf2KcRUj3xyruyDsu9Qa7nT7NPNkyfP)qytkSJlSKUn5E0QazWgMaT1uZLuzAgYo4RGmOx7JbCsu9IbgvMSUGm90GhCGrrEjgJkgGx)y4mwwmabwbdlhdOBY9fwefwNevVkWEt7(z6Pcwr6pe2Kc75Q1ks3WCTEWzQ)VFnH6oGbCsu9IbazWgMaT1uZLuzAgYo4JdCGb(aJkgfeWOIbCsu9IbqRmg6pTdmaV(XWzSS4aJI8WOIb41pgoJLfdqGvWWYXaHB4nubdbFARP8M6PmiVHIx)y4mgWjr1lgyQdh6EXbgLeJrfdWRFmCgllgGaRGHLJb0n5(c7eHL4FqHCkVclIcRUj3xb6ZHbCsu9Ib0gFrR2u6hWcnghyuMpmQyaE9JHZyzXaeyfmSCmW5Q1ks3WCTEWzQ)VFnH6oiSjf2XkSNRwRiDdZ16bNP()(1ekid61(clIclckKiSYxytjzHvIeH9C1A1XCH0wtd307RUdcBsH9C1A1XCH0wtd307RGmOx7lSikSiOqIWkFHnLKf2XGbCsu9IbG(q0q6hWcnghyuqcgvmaV(XWzSSyacScgwog4C1AfPByUwp4m1)3VMqDhe2Kc7yf2ZvRvKUH5A9GZu)F)AcfKb9AFHfrHfbfsew5lSPKSWkrIWEUAT6yUqARPHB69v3bHnPWEUAT6yUqARPHB69vqg0R9fwefweuiryLVWMsYc7yWaojQEXaG9M29Z0tfmoWOmpyuXa86hdNXYIbCsu9IbqRmgkPbb9nJbiWkyy5yaDtUVWoryj(huiNYRWIOWQBY9vG(CyascedtdhMYXJrbbCGrb9IrfdWRFmCgllgGaRGHLJboxTwnRgy4tNXBdQUdcBsH9C1A1SAGHpDgVnOcYGETVWIOWIGWkFHnLKXaojQEXapdh4nOFuBkoWOmVyuXa86hdNXYIbiWkyy5yaDtUVWoryj(huiNYRWIOWQBY9vG(CyaNevVyGpy2qdOpGdmkOhmQyaE9JHZyzXaeyfmSCmGUj3xyNiSe)dkKt5vyruy1n5(kqFoHnPWcznK)P(XWcBsHvFngkKjtDyktJcKfwef2uswytkSJlSNRwRazWgMaT1uZLuzAgYo4RUdcRejcRUj3xyNiSe)dkKt5vyruy1n5(kqFoHnPWowHDCHn3HAuzY6cY0tdEurrqR2uHnPWowHDCH9C1AfPByUwp4m1)3VMqDhewjse2ZvRvG9M29Zu9fMG6dNGMWIOWIGWkrIWgfitJMMlwyruyryEfwjse2Xf2ChQrLjRlitpn4rffbTAtf2KcRJ(mScwnQmzgU8)0)cNvZCJc6lAclsfw0jSJryhJWMuyhxypxTwbYGnmbARPMlPY0mKDWxDhWaojQEXaJktwxqMEAWdoWOGa6WOIb41pgoJLfdqGvWWYXaNRwRMvdm8PZ4Tbv3bHnPWM7q9mCG3G(rTPkid61(clIc78jSYxytjzHvIeHn3H6z4aVb9JAtvqwd5FQFmSWMuyhxypxTwr6gMR1dot9)9Rju3bmGtIQxmWZWbEd6h1MIdmkiGagvmaV(XWzSSyacScgwogyCH9C1AfPByUwp4m1)3VMqDhWaojQEXaof8cZmK2Akb2JECGrbb5HrfdWRFmCgllgGaRGHLJbgxypxTwr6gMR1dot9)9Rju3bmGtIQxmaPByUwp4m1)3VMahyuqiXyuXa86hdNXYIbiWkyy5yGZvRvG9M29Zu9fMG6oiSsKiS6MCFHDIWs8pOqoLxHfPcRUj3xb6ZjSZVWkp0jSjf2Wn8gQz1adF6mEBqfV(XWzHvIeHv3K7lStewI)bfYP8kSivy1n5(kqFoHD(fwee2KcB4gEdvWqWN2AkVPEkdYBO41pgolSsKiSNRwRiDdZ16bNP()(1eQ7agWjr1lgaS30UFMEQGXbgfeMpmQyaNevVyaOpenK(bSqJXa86hdNXYIdmkiGemQyaE9JHZyzXaeyfmSCmqUd1OYK1fKPNg8OGSgY)u)yymGtIQxmWOYK1fKPNg8GdmkimpyuXa86hdNXYIbiWkyy5yGZvRvZQbg(0z82GQ7agWjr1lg4z4aVb9JAtXboWadqM0GhpWOIrbbmQyaE9JHZyzXaRdYyah9)Po0FQU3G2A6qpIHyaNevVyah9)Po0FQU3G2A6qpIH4aJI8WOIbCsu9IbsVomx(sBn1rFg2XumaV(XWzSS4aJsIXOIbCsu9IbiDdZ16bNP()(1eyaE9JHZyzXbgL5dJkgWjr1lgyudn5zCTui)96lHXa86hdNXYIdmkibJkgGx)y4mwwmGtIQxmWqhvVyGCcRdwe6aKh6adGaoWOmpyuXaojQEXaFWSHgqFadWRFmCglloWOGEXOIbCsu9IbM6WHUxmaV(XWzSS4ah4admJHF1lgf5Ho5Ho0HEKhsuOd9GKeJW8Hbg5WT20hdKibCOHbNf25vyDsu9kSM6Jxjqgd8dmbJI8qcsWadWwxggdKOewGlCwnZncBIi3nyOa5eLWMidj6ddfw0RCcR8qN8qNazbYjkHnruEgBeweLkSibDkbYcKDsu9(QbitAWJhtKkZ9zAfmOCRdYsD0)N6q)P6EdARPd9igkq2jr17RgGmPbpEmrQmPxhMlFPTM6Opd7yQazNevVVAaYKg84XePYq6gMR1dot9)9Rjei7KO69vdqM0GhpMivMrn0KNX1sH83RVewGStIQ3xnazsdE8yIuzg6O6vUCcRdwe6aKh6qkccKDsu9(QbitAWJhtKkZhmBOb0hei7KO69vdqM0GhpMivMPoCO7vGSazNevV)ePYaErF03WcKDsu9(tKkZ9zAfm4lq2jr17prQme3yOojQEPM6d5whKLsYVazNevV)ePYa2BA3ptpvWYvAPojQzmLxgS4xkcjdhMYHkkqMgnnxmI6MC)ePJ1jr1RcS30UFMEQGvK(J5N4FqHCkVJr(PKSazNevV)ePYqCJH6KO6LAQpKBDqwQpmsxYvAPojQzmLxgS4hXeNmCdVHIm1rd6GVIx)y4CYWn8gk3mm1Pdqo7rdv86hdNfi7KO69NivgIBmuNevVut9HCRdYshPl5kTuNe1mMYldw8JyItgUH3qrM6ObDWxXRFmCwGStIQ3FIuziUXqDsu9sn1hYToil9d5kTuNe1mMYldw8JyItoE4gEdLBgM60biN9OHkE9JHZjhpCdVHAuzY6cY0A13V6vXRFmCwGStIQ3FIuziUXqDsu9sn1hYToil1h(qUsl1jrnJP8YGf)iM4KHB4nuUzyQthGC2JgQ41pgoNC8Wn8gQrLjRlitRvF)QxfV(XWzbYojQE)jsLH4gd1jr1l1uFi36GSuFyKUKR0sDsuZykVmyXpIjoz4gEdLBgM60biN9OHkE9JHZjd3WBOgvMSUGmTw99REv86hdNfi7KO69NivgIBmuNevVut9HCRdYshPl5kTuNe1mMYldw8JyItoE4gEdLBgM60biN9OHkE9JHZjd3WBOgvMSUGmTw99REv86hdNfi7KO69NivgIBmuNevVut9HCRdYsjg2NXYvAPojQzmLxgS4hPiKC8Wn8gQtbZpT10biNGIx)y4SejojQzmLxgS4hPYtGSa5eLWMiyzmm8Ltyj(hcBPf2TJP1MkSS5zHTEH1N5LXpgwjq2jr17prQmKEj8gqp4mvBCqwGStIQ3FIuzCiXxMgneYBiq2jr17prQmhpL2AAalcAVazbYojQEFfj)tKkZX0DMQVWeKR0sjDBY9Ovr6gMR1dot9)9Rjuqg0R9rAIrNazNevVVIK)jsLXxc)b0nuIBmYvAPKUn5E0QiDdZ16bNP()(1ekid61(inXOtGStIQ3xrY)ePYOliFmDNLR0sjDBY9Ovr6gMR1dot9)9Rjuqg0R9rAIrNazNevVVIK)jsLXuPtJNMOV5uqEdbYojQEFfj)tKkZHHpdrR2u5kTus3MCpAvKUH5A9GZu)F)AcfKb9AFKopOtIKOazA00CXiIqIfi7KO69vK8prQmdDu9kxPLEUATk96WC5lT1uh9zyhtv3HKJ9C1A1HHpdrR2u1DqIKZvRvht3zQ(ctqDhKizCOtyvaBJzmsKmwsV)f0pgwn0r1lT107EGv2WzQ(ctiPUsNguid61(iopiirIUsNguid61(ikV5zmsKmo)pVewr6nZ7ZzQP0SUHewb6j6gM8C1AfPByUwp4m1)3VMqDhei7KO69vK8prQm(pWKG2AAmLPSNAy5kT0WHPCOY1h(syKkDEei7KO69vK8prQm3NPvWGYToil1)PZ8LFk0r)gsjn0nYvAPNRwRazWgMaT1uZLuzAgYo4RUdj1v60GczqV2hrs3MCpAvGmydtG2AQ5sQmndzh8vqg0R9NGasKi5C1Av61H5YxARPo6ZWoMQ(WjOjfjj1v60GczqV2hrs3MCpAvPxhMlFPTM6Opd7yQcYGET)e5HojsY85Q1kOJ(nKsAOBOz(C1AvUhTsKOR0PbfYGETpIYdbjsoxTwnQHM8mUwkK)E9LWkid61(j1v60GczqV2hrs3MCpAvJAOjpJRLc5VxFjScYGET)eeMxjsgpCdVH6uW8tBnDaYjO41pgoNuxPtdkKb9AFejDBY9Ovr6gMR1dot9)9Rjuqg0R9Nip0L8C1AfPByUwp4m1)3VMqbzqV2xGStIQ3xrY)ePYCFMwbdk36GS0u3We3yy4tpDVYvAPKUn5E0QazWgMaT1uZLuzAgYo4RGmOx7lrs4gEd1OYK1fKP1QVF1RIx)y4Css3MCpAvKUH5A9GZu)F)AcfKb9AFjsgN)NxcRazWgMaT1uZLuzAgYo4Ra9eDdts62K7rRI0nmxRhCM6)7xtOGmOx7lq2jr17Ri5FIuzUptRGbLBDqwQJ()uh6pv3BqBnDOhXqbYcKtucBI8)5LWVazNevVVIK)jsLr3K7ZzQJ(mScMEyhuUslf6vMYZ4nuEo)QArk6bDj1n5(iQBY9vG(CZV8qIejJ1jrnJP8YGf)ifHKJhUH3qDky(PTMoa5eu86hdNLiXjrnJP8YGf)ivEJj5ypxTwDmxiT10Wn9(Q7qYZvRvhZfsBnnCtVVcYGETpstS8tjzjsg)C1A1XCH0wtd307RUdJrGStIQ3xrY)ePYCmDNPTMgtzkVmycYvAPJDSqVYuEgVHYZ5xbzqV2hPOh0jrY4qVYuEgVHYZ5xXZvF8JrIKX6KOMXuEzWIFKIqYXd3WBOofm)0wthGCckE9JHZsK4KOMXuEzWIFKkVXmMK6MCFe1n5(kqFobYojQEFfj)tKkZWfw6eQnLEm(hYvAPJDSqVYuEgVHYZ5xbzqV2hPZd6KizCOxzkpJ3q558R45Qp(XirYyDsuZykVmyXpsri54HB4nuNcMFARPdqobfV(XWzjsCsuZykVmyXpsL3ygtsDtUpI6MCFfOpNazNevVVIK)jsLj96WC5lT1uh9zyhtfi7KO69vK8prQmWAyWW0AP)GtybYojQEFfj)tKkdPxcVb0dot1ghKLR0s1xJHczYuhMY0Oazerq(PKSazNevVVIK)jsLjMY07E67MP6gsy5kT0ZvRvqMGMH)NQBiHv3bbYojQEFfj)tKkZOgAYZ4APq(71xclq2jr17Ri5FIuzGSpuBkvBCq(LR0sdhMYHAk7MyQAGeiDErNejHdt5qnLDtmvnqceLkp0jrs4WuourbY0OPdKGkp0H0eJobYjkH1CjvwyteONOBOWMiytUF(coiSdt9Nfi7KO69vK8prQmpdh4nOFuBQCLwk)pVewbYGnmbARPMlPY0mKDWxb6j6gMeYAi)t9JHtEUATAwnWWNoJ3guDhsooPBtUhTkqgSHjqBn1CjvMMHSd(kid61(cKDsu9(ks(NivgWEt7(z6PcwUslL)NxcRazWgMaT1uZLuzAgYo4Ra9eDdtooPBtUhTkqgSHjqBn1CjvMMHSd(kid61(cKDsu9(ks(NivMrLjRlitpn4rUslL)NxcRazWgMaT1uZLuzAgYo4Ra9eDdtQVgdfYKPomLPrbYiIGcjYpLKtQBY9r0jr1RcS30UFMEQGvK(JKJt62K7rRcKbByc0wtnxsLPzi7GVcYGETVazNevVVIK)jsLbKbByc0wtnxsLPzi7GVCLwQUj3hrNevVkWEt7(z6Pcwr6psEUATI0nmxRhCM6)7xtOUdcKfi7KO69vFmrQmOvgd9N2HazNevVV6JjsLzQdh6ELR0sd3WBOcgc(0wt5n1tzqEdfV(XWzbYojQEF1htKkJ24lA1Ms)awOXYvAP6MC)je)dkKt5frDtUVc0NtGStIQ3x9XePYa9HOH0pGfASCLw65Q1ks3WCTEWzQ)VFnH6oKCSNRwRiDdZ16bNP()(1ekid61(iIGcjYpLKLi5C1A1XCH0wtd307RUdjpxTwDmxiT10Wn9(kid61(iIGcjYpLKhJa5eLWIAlSFbEnEWc799uwy1nuyb7nT7NPNkyHTHcl0hIgs)awOXcB(cRnvyte)dmje2wlSXuwytK7PgwoHL0djiSStMkSnHCHqEjSW2AHnMYcRtIQxH13SW6dd8Mfwk7PgwyJwyJPSW6KO6vyxhKvcKDsu9(QpMivgWEt7(z6PcwUsl9C1AfPByUwp4m1)3VMqDhso2ZvRvKUH5A9GZu)F)AcfKb9AFerqHe5NsYsKCUAT6yUqARPHB69v3HKNRwRoMlK2AA4MEFfKb9AFerqHe5NsYJrGStIQ3x9XePYGwzmusdc6BwoscedtdhMYXlfb5kTuDtU)eI)bfYP8IOUj3xb6Zjq2jr17R(yIuzEgoWBq)O2u5kT0ZvRvZQbg(0z82GQ7qYZvRvZQbg(0z82Gkid61(iIG8tjzbYojQEF1htKkZhmBOb0hKR0s1n5(ti(huiNYlI6MCFfOpNazNevVV6JjsLzuzY6cY0tdEKR0s1n5(ti(huiNYlI6MCFfOpxsiRH8p1pgoP(AmuitM6WuMgfiJykjNC8ZvRvGmydtG2AQ5sQmndzh8v3bjs0n5(ti(huiNYlI6MCFfOpxYXoEUd1OYK1fKPNg8OIIGwTPjh74NRwRiDdZ16bNP()(1eQ7GejNRwRa7nT7NP6lmb1hobnerqIKOazA00CXiIW8krY45ouJktwxqMEAWJkkcA1MM0rFgwbRgvMmdx(F6FHZQzUrb9fnKIUXmMKJFUATcKbByc0wtnxsLPzi7GV6oiq2jr17R(yIuzEgoWBq)O2u5kT0ZvRvZQbg(0z82GQ7qYChQNHd8g0pQnvbzqV2hX5t(PKSej5oupdh4nOFuBQcYAi)t9JHto(5Q1ks3WCTEWzQ)VFnH6oiq2jr17R(yIuzCk4fMziT1ucSh9YvAPJFUATI0nmxRhCM6)7xtOUdcKDsu9(QpMivgs3WCTEWzQ)VFnHCLw64NRwRiDdZ16bNP()(1eQ7GazNevVV6JjsLbS30UFMEQGLR0spxTwb2BA3pt1xycQ7Gej6MC)je)dkKt5fP6MCFfOp38lp0LmCdVHAwnWWNoJ3guXRFmCwIeDtU)eI)bfYP8IuDtUVc0NB(riz4gEdvWqWN2AkVPEkdYBO41pgolrY5Q1ks3WCTEWzQ)VFnH6oiq2jr17R(yIuzG(q0q6hWcnwGStIQ3x9XePYmQmzDbz6PbpYvAP5ouJktwxqMEAWJcYAi)t9JHfi7KO69vFmrQmpdh4nOFuBQCLw65Q1Qz1adF6mEBq1DqGSa5eLWMi2mm1f2eHHC2Jgkq2jr17R8HpMivg0kJH(t7qGStIQ3x5dFmrQmG9M29Z0tfSCLw65Q1ks3WCTEWzQ)VFnH6oKCSNRwRiDdZ16bNP()(1ekid61(iIGcjYpLKLi5C1A1XCH0wtd307RUdjpxTwDmxiT10Wn9(kid61(iIGcjYpLKhJazNevVVYh(yIuzG(q0q6hWcnwUsl9C1AfPByUwp4m1)3VMqDhso2ZvRvKUH5A9GZu)F)AcfKb9AFerqHe5NsYsKCUAT6yUqARPHB69v3HKNRwRoMlK2AA4MEFfKb9AFerqHe5NsYJrGStIQ3x5dFmrQmAJVOvBk9dyHglxPLQBY9Nq8pOqoLxe1n5(kqFobYojQEFLp8XePYGwzmusdc6BwoscedtdhMYXlfb5kTu91yOqMm1HPmnkqgreuir(PKCsDtU)eI)bfYP8IOUj3xb6Zjq2jr17R8HpMivMpy2qdOpixPLQBY9Nq8pOqoLxe1n5(kqFobYojQEFLp8XePYmQmzDbz6PbpYvAP6MC)je)dkKt5frDtUVc0Nl54rrqR20KJFUATcKbByc0wtnxsLPzi7GV6oKCS6RXqHmzQdtzAuGmIiOqI8tjzjsgp3HAuzY6cY0tdEurrqR20KJFUATI0nmxRhCM6)7xtOUdsKmEUd1OYK1fKPNg8OIIGwTPjpxTwb2BA3pt1xycQpCcAiIWyKijkqMgnnxmIimVjhp3HAuzY6cY0tdEurrqR2ubYojQEFLp8XePY8mCG3G(rTPYvAPJN7q9mCG3G(rTPQOiOvBAYXpxTwr6gMR1dot9)9Rju3bbYojQEFLp8XePYGwzmusdc6BwoscedtdhMYXlfb5kTuDtU)eI)bfYP8IOUj3xb6ZLCSNRwRa7nT7NP6lmb1hobnerIej6MCFeDsu9Qa7nT7NPNkyfP)ymcKDsu9(kF4JjsL5z4aVb9JAtLR0sHSgY)u)y4KJFUATI0nmxRhCM6)7xtOUdjpxTwb2BA3pt1xycQpCcAiIebYojQEFLp8XePY4uWlmZqARPeyp6LR0sh)C1AfPByUwp4m1)3VMqDhei7KO69v(WhtKkdPByUwp4m1)3VMqUslD8ZvRvKUH5A9GZu)F)Ac1DqGStIQ3x5dFmrQmG9M29Z0tfSCLw65Q1kWEt7(zQ(ctqDhKir3K7pH4FqHCkViv3K7Ra95MFeqNejNRwRiDdZ16bNP()(1eQ7GazNevVVYh(yIuzG(q0q6hWcnwGStIQ3x5dFmrQmJktwxqMEAWJCLw64rrqR2ubYcKtucBIqLjRlilSjsw99REfi7KO69vJ01ePYGwzm0FAhcKDsu9(Qr6AIuzM6WHUx5kTuDtU)eI)bfYP8IOUj3xb6ZLmCdVHkyi4tBnL3upLb5nu86hdNfi7KO69vJ01ePYa2BA3ptpvWYvAPNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzqV2hXuswGStIQ3xnsxtKkd0hIgs)awOXYvAPNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzqV2hXuswGStIQ3xnsxtKkZZWbEd6h1MkxPLEUATAwnWWNoJ3guDhsEUATAwnWWNoJ3gubzqV2hreuir(PKSejJN7q9mCG3G(rTPQOiOvBQazNevVVAKUMivMrLjRlitpn4rUslvFngkKjtDyktJcKrebfsKFkjNu3K7pH4FqHCkViQBY9vG(CsKm2LNlOJk6PbpQzTXJYWjZDOEgoWBq)O2uvue0QnnzUd1ZWbEd6h1MQGSgY)u)yyjswEUGoQONg8OgMYWgSxo54NRwRa7nT7NP6lmb1DiPUj3FcX)Gc5uEru3K7Ra95MFNevVk0kJHsAqqFZkI)bfYP8k)epgbYojQEF1iDnrQmOvgdL0GG(MLJKaXW0WHPC8srqUslv3K7pH4FqHCkViQBY9vG(CZVUj3xb5uEfi7KO69vJ01ePY4uWlmZqARPeyp6fi7KO69vJ01ePY8bZgAa9b5kTuDtU)eI)bfYP8IOUj3xb6Zjq2jr17RgPRjsLzuzY6cY0tdEKR0s1xJHczYuhMY0OazerqHe5NsYcKDsu9(Qr6AIuziDdZ16bNP()(1ecKDsu9(Qr6AIuzEgoWBq)O2u5kT0ZvRvZQbg(0z82GQ7qYChQNHd8g0pQnvbzqV2hX5t(PKSazNevVVAKUMivgWEt7(z6PcwUsln3H6Nc9HLn0tdEurrqR2ujsoxTwb2BA3pt1xycQpCcAsrIazNevVVAKUMivMrLjRlitpn4rUslD55c6OIEAWJ6Nc9HLnjZDOEgoWBq)O2ufKb9AFKIe5NsYcKDsu9(Qr6AIuzEgoWBq)O2u5kTuiRH8p1pgwGStIQ3xnsxtKkdzQJg0bF5kT0XpxTwb2BA3pt1xyckid61(cKDsu9(Qr6AIuza7nT7NPNkybYojQEF1iDnrQmqFiAi9dyHglq2jr17RgPRjsL5z4aVb9JAtLR0spxTwnRgy4tNXBdQUdcKDsu9(Qr6AIuzgvMSUGm90Gh5kT0LNlOJk6PbpQzTXJYWjZDOEgoWBq)O2uvue0QnvIKLNlOJk6PbpQHPmSb7LLiz55c6OIEAWJ6Nc9HLncKfiNOe2eXMHPUWMimKZE0WjcBIqLjRlilSjsw99REfi7KO69v(WiDnrQmOvgd9N2HazNevVVYhgPRjsLbS30UFMEQGLR0spxTwDmxiT10Wn9(Q7qYZvRvhZfsBnnCtVVcYGETpIPKSazNevVVYhgPRjsLb6drdPFal0y5kT0ZvRvhZfsBnnCtVV6oK8C1A1XCH0wtd307RGmOx7Jykjlq2jr17R8Hr6AIuzEgoWBq)O2u5kT0XZDOEgoWBq)O2uvue0QnvGStIQ3x5dJ01ePY4uWlmZqARPeyp6fi7KO69v(WiDnrQmJktwxqMEAWJCLwQ(AmuitM6WuMgfiJickKi)uswIeDtU)eI)bfYP8IOUj3xb6ZLCSlpxqhv0tdEuZAJhLHtM7q9mCG3G(rTPQOiOvBAYChQNHd8g0pQnvbznK)P(XWsKS8CbDurpn4rnmLHnyVCYXpxTwb2BA3pt1xycQ7qsDtU)eI)bfYP8IOUj3xb6Zn)ojQEvOvgdL0GG(Mve)dkKt5v(jEmcKDsu9(kFyKUMivgs3WCTEWzQ)VFnHazNevVVYhgPRjsLbS30UFMEQGLR0spxTwb2BA3pt1xyckid61(jxEUGoQONg8OgMYWgSxwGStIQ3x5dJ01ePYGwzmusdc6BwoscedtdhMYXlfb5kTu91yOqMm1HPmnkqgreuir(PKCsDtU)eI)bfYP8IOUj3xb6Zn)YdDcKDsu9(kFyKUMivMpy2qdOpixPLQBY9Nq8pOqoLxe1n5(kqFobYojQEFLpmsxtKkd0hIgs)awOXYvAPNRwRIAG2AAmLP)a7q1hobnPjwIKChQFk0hw2qpn4rffbTAtfi7KO69v(WiDnrQmG9M29Z0tfSCLwAUd1pf6dlBONg8OIIGwTPcKDsu9(kFyKUMivMrLjRlitpn4rUslD55c6OIEAWJ6Nc9HLnj1n5(inXOlzUd1ZWbEd6h1MQGmOx7JuKi)uswGStIQ3x5dJ01ePYqM6ObDWxUslD8ZvRvG9M29Zu9fMGcYGETVazNevVVYhgPRjsL5z4aVb9JAtLR0sHSgY)u)yybYojQEFLpmsxtKkdALXqjniOVz5ijqmmnCykhVueKR0s1n5(ti(huiNYlI6MCFfOpxYXEUATcS30UFMQVWeuF4e0qejsKOBY9r0jr1RcS30UFMEQGvK(JXiq2jr17R8Hr6AIuzG(q0q6hWcnwGStIQ3x5dJ01ePYa2BA3ptpvWYvAPNRwRa7nT7NP6lmb1DqIeDtUpsNp0jrsUd1pf6dlBONg8OIIGwTPcKDsu9(kFyKUMivMrLjRlitpn4rUslD55c6OIEAWJAwB8OmCYChQNHd8g0pQnvffbTAtLiz55c6OIEAWJAykdBWEzjswEUGoQONg8O(PqFyztsDtUpsrc6eilq2jr17Rig2NXtKkZmhw(XWYToilL4WzmLKHY1dsFokTCZCZLL6KOMXuEzWIF5M5MltzZZsrICKEZvu9k1jrnJP8YGf)iIebYojQEFfXW(mEIuza7nT7NPNky5kTuh9zyfS6yUqARPHB69vqFrdPOl5ypxTwr6gMR1dot9)9Rju3HKJ9C1AfPByUwp4m1)3VMqbzqV2hreuir(PKSejNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzqV2hreuir(PKSejNRwRiDdZ16bNP()(1ekid61(jh)C1A1XCH0wtd307RGmOx7pMXiq2jr17Rig2NXtKkdyVPD)m9ublhjbIHPHdt54LIGCLwAMpxTwz8G3Go013R6dNGgshRtIAgt5Lbl(Lib9mMKHdt5qffitJMMlgrNe1mMYldw8l)uswGStIQ3xrmSpJNivgNcEHzgsBnLa7rVazNevVVIyyFgprQmKUH5A9GZu)F)AcbYojQEFfXW(mEIuzioCglxPLM7q9tH(WYg6PbpQOiOvBAYXd3WBOMMqg6p9ubR41pgolrsUd1pf6dlBONg8OIIGwTPjDsuZykVmyXpsrIazNevVVIyyFgprQmJktwxqMEAWJCLw64HB4nuPxgclJXPHtII8kE9JHZsKOVgdfYKPomLPrbYiMsYsKa9kt5z8gkpNFfKb9AFeNNKqVYuEgVHYZ5xXZvF8cKDsu9(kIH9z8ePYCUbzkdtqUslLm1HP8t1qNevVUbPYtHejsYDO(PqFyzd90Ghvue0QnvIes3MCpAvJktwxqMEAWJcYGETpsDsuZykVmyX)8NsYsKK5ZvRvht3zARPXuMYldMGcYGETVejqVYuEgVHYZ5xbzqV2hrKKe6vMYZ4nuEo)kEU6JxGStIQ3xrmSpJNivgWEt7(z6PcwoscedtdhMYXlfb5kT0mFUATY4bVbDORVx1hobnKoVcKDsu9(kIH9z8ePYqM6ObDWxGStIQ3xrmSpJNivg0kJHsAqqFZYrsGyyA4WuoEPiixPLQBY9Nq8pOqoLxe1n5(kqFobYojQEFfXW(mEIuzM6WHUx5kT0Wn8gQGHGpT1uEt9ugK3qXRFmCwGStIQ3xrmSpJNivgIdNXYvAPHB4nuPxgclJXPHtII8kE9JHZcKDsu9(kIH9z8ePYCUbzkdtqUslL0Tj3Jw1OYK1fKPNg8OGmOx7J0X6KOMXuEzWIFjsqYyei7KO69ved7Z4jsLrB8fTAtPFal0y5kTuDtU)eI)bfYP8IOUj3xb6Zjq2jr17Rig2NXtKkZOYK1fKPNg8ixPLM7qnQmzDbz6PbpkiRH8p1pgwIKWn8gQrLjRlitRvF)QxfV(XWzbYojQEFfXW(mEIuzEgoWBq)O2u5ijqmmnCykhVueKR0spxTwnRgy4tNXBdQGStcbYojQEFfXW(mEIuzioCglxPLs62K7rRAuzY6cY0tdEuqg0R9r6mhw(XWkIdNXusgMivEcKDsu9(kIH9z8ePY8bZgAa9bbYojQEFfXW(mEIuzEgoWBq)O2u5ijqmmnCykhVueKR0sHSgY)u)y4KNRwRIAG2AAmLP)a7q1hobnetCYLNlOJk6PbpQzTXJYWsKaznK)P(XWjD0NHvWkJh8g0HU(EvqFrdPOtGCIsyrTf2VaVgpyH9(EklS6gkSG9M29Z0tfSW2qHf6drdPFal0yHnFH1MkSjI)bMecBRf2yklSjY9udlNWs6Heew2jtf2MqUqiVewyBTWgtzH1jr1RW6Bwy9HbEZclL9udlSrlSXuwyDsu9kSRdYkbYojQEFfXW(mEIuza7nT7NPNky5ijqmmnCykhVueei7KO69ved7Z4jsLb6drdPFal0y5ijqmmnCykhVueWboWya]] )
    end

end