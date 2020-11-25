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

    spec:RegisterPack( "Survival", 20201124, [[dGuC)bqicupsik6sesQnju9jcjzuqv6uqvSkcjELOyweQUfaL2LGFbvAycroMqAzqfEgaX0GkkxdG02aO4BesX4GkIZrivwhHuAEqvDpcAFeihuikyHekpeQiDrHOqFKqQQgjHufDsHOuReqntOIQDkQAPesv6Panvc4ResvzScrj7fYFjzWK6WuTyK6XGMSIUmQnRWNry0IkNwYQjKQWRbKzlYTrYUv63snCeDCaQwUQEUktNY1HY2jeFxuA8cHZdG1levZxOSFIgffjacC6gJYJJiHJifnkoWzbCefqbeCGZqGgaKmcK0Ha5emcCDkgbcI9IuI4jeiPdqQ9jsae41ypKrG5mJ8eT4Ilrz5WOdWMc3ROWsUv9cFFy4EffexeinwLSi7frJaNUXO84is4isrJIdCwahrbuabhrrGoMLRFeiyrHLCR6fN((WqG5Q5KxencCYhebgzk1GyViLiEsQf9eBn(Lahzk15BrykA(LACaiIl14is4issGLahzk1G58zNn578K6NtSFSut(v)LbGuJ3SLLtQJmEhVq(WtabMQZoKaiqN8mKaO8rrcGa51Pt8ejgce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iqGo0QErGt2TCkyohO3PqgkpoqcGa51Pt8ejgc0Hw1lc84NKxtDwTeiq4xg)LJafSupBlC8tYRPoRwIGvqGQLqQJl1M)eSfSIIvwRMfl1csQfniqiaWeRm)jy7q5JImuEabjac0Hw1lcCKCa4P6Y1gcKxNoXtKyidLhNHeab6qR6fb(81RB1sO8)7SiqED6eprIHmuEafjac0Hw1lce29pR1nEQ87CSKHa51Pt8ejgYq5bmibqGo0QErGavPK6Y1gcKxNoXtKyidLx0GeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5rGaDOv9IahjFbQwc1zFbeJmuECcsaeOdTQxeOROW(j)QEOGFN9qG860jEIedzO8IoKaiqED6eprIHaHFz8xocCGLsQNH58NGvwrXsn(snbCk1XIj1JgIDsDgPg6NPEMGxPgFPE0qSlq5ri1XLA8k1lhHPYwk6MIoisNCRsSuhxQNTfo(j51uNvlrWkiq1si1XL6zBHJFsEn1z1seEE88LZPtSuhlMuVCeMkBPOBk6azo(BQEzPoUulyPMgBmcu9s09XQb2dqaJuQJl1JgIDsDgPg6NPEMGxPgFPE0qSlq5ri1awP2Hw1BaOkLuWMIY3za6NPEMGxPwuKAarQXJuhlMuBffRSwnlwQXxQJgjeOdTQxey2knh1Zk6MIgzO8rJesaeiVoDINiXqGWVm(lhboAi2j1zKAOFM6zcELA8L6rdXUaLhbc0Hw1lc8mMtk7DsKHYhnksaeiVoDINiXqGo0QErGu9s09Xk6Yyei8lJ)YrG0yJrGQxIUpwnWEacyKsDCPMgBmcu9s09XQb2dq4zkV2tQXxQhne7KACLA8k1o0QEdu9s09Xk6Y4aSptQbSsn0pt9mbVsnEKArrQjGtPoUulyPMgBmczR0uDK1x2fEMYR9K6yXKAASXiq1lr3hRgypaHNP8ApPoUuVCeMkBPOBk6azo(BQEzeieayIvM)eSDO8rrgkFuCGeabYRtN4jsmeOdTQxeiqvkPGnfLVtei8lJ)YrGdSus9mmN)eSYkkwQXxQjGtPoUupAi2j1zKAOFM6zcELA8L6rdXUaLhbcecamXkZFc2ou(OidLpkGGeabYRtN4jsmeOdTQxe47Kw)QZ(cigbc)Y4VCein2yeSIu1dLLJvhj7F4mhcKuluQbePowmPE2w4Y9o5YjfDtrhSccuTeiqiaWeRm)jy7q5JImu(O4mKaiqED6eprIHaHFz8xocC2w4Y9o5YjfDtrhSccuTeiqhAvViqQEj6(yfDzmYq5JcOibqG860jEIedb6qR6fbE8tYRPoRwcei8lJ)YrGppE(Y50jwQJl1M)eSfSIIvwRMfl1csQfniqiaWeRm)jy7q5JImu(OagKaiqED6eprIHaHFz8xocC5imv2sr3u0Hl37KlNK64s9OHyNuliP2Hw1BGQxIUpwrxghG9zsTOi14qQJl1Z2ch)K8AQZQLi8mLx7j1csQbuPwuKAc4eb6qR6fbMTsZr9SIUPOrgkFurdsaeOdTQxeimNd07uhcKxNoXtKyidLpkobjacKxNoXtKyiqhAvViqGQusbBkkFNiq4xg)LJahne7K6msn0pt9mbVsn(s9OHyxGYJabcbaMyL5pbBhkFuKHYhv0HeabYRtN4jsmei8lJ)YrGp2YJ(j4WdqYb6mpbe)Nc27OX2zTeQZ(ci(cmGJvKK8eb6qR6fbMTsZr9SIUPOrgkpoIesaeiVoDINiXqGo0QErGu9s09Xk6Yyei8lJ)YrG0yJrGQxIUpwnWEacyKsDSys9OHyNuNrQDOv9gaQsjfSPO8DgG(zQNj4vQfKupAi2fO8iKAaRuhfqL6yXK6zBHl37KlNu0nfDWkiq1si1XIj10yJriBLMQJS(YUWZuEThcecamXkZFc2ou(OidLhhrrcGa51Pt8ejgc0Hw1lc8DsRF1zFbeJaHaatSY8NGTdLpkYq5XboqcGa51Pt8ejgce(LXF5iWLJWuzlfDtrhePtUvjwQJl1Z2ch)K8AQZQLiyfeOAjK6yXK6LJWuzlfDtrhiZXFt1ll1XIj1lhHPYwk6MIoC5ENC5KuhxQhne7KAbj1aAKqGo0QErGzR0CupROBkAKHmeimXUimsau(OibqG860jEIedb6qR6fbE8tYRPoRwcei8lJ)YrGMN41c5ay((POlJd860jEk1XLAASXiisrY)PeH3Mk8mLx7j1XLAASXiisrY)PeH3Mk8mLx7j14l1eWjcecamXkZFc2ou(OidLhhibqGo0QErGzR0uDK1x2Ha51Pt8ejgYq5beKaiqhAvViWNVEDRwcL)FNfbYRtN4jsmKHYJZqcGa51Pt8ejgce(LXF5iWbwkPEgMZFcwzffl14l1eWjc0Hw1lcmBLMJ6zfDtrJmuEafjac0Hw1lceMZb6DQdbYRtN4jsmKHYdyqcGa51Pt8ejgce(LXF5iWzBHl37KlNu0nfDWkiq1si1XLA8k1Z2c1A8VEsrNyEwlr4mhcKuJVuJdPowmPE2w4Y9o5YjfDtrhEMYR9KA8LAc4uQXdc0Hw1lcKgZG54haKHYlAqcGa51Pt8ejgce(LXF5iWzBHl37KlNu0nfDWkiq1sGaDOv9IaH(lcJmuECcsaeiVoDINiXqGWVm(lhboAi2j1zKAOFM6zcELA8L6rdXUaLhbc0Hw1lcCYULtbZ5a9ofYq5fDibqGo0QErGWU)zTUXtLFNJLmeiVoDINiXqgkF0iHeabYRtN4jsmei8lJ)YrGWC(tWNA8o0QE9KuliPghbavQJl1WUtZo7gYwP5OEwr3u0HbwkPEgMZFcwzffl1csQpsoLuM)eSDsnUsnoqGo0QErG0ygmh)aGmu(OrrcGa51Pt8ejgce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iqGo0QErGJKVavlH6SVaIrgkFuCGeabYRtN4jsmei8lJ)YrGWUtZo7gYwP5OEwr3u0HbwkPEgMZFcwzffl1csQpsoLuM)eSDsnUsnoK64sT5jETGNiZ5kYNNU1FGxNoXteOdTQxei0FryKHYhfqqcGa51Pt8ejgc0Hw1lceOkLuWMIY3jce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iK64s9alLupdZ5pbRSIILA8LAc4uQJl14vQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuhxQHDNMD2nmEMJ8Aju27KHNP8ApPoUud7on7SBW8xzVtgEMYR9K6yXKAbl1p2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uQXdcecamXkZFc2ou(OidLpkodjacKxNoXtKyiq4xg)LJafSupBlKTsZr9SIUPOdwbbQwceOdTQxey2knh1Zk6MIgzO8rbuKaiqED6eprIHaHFz8xoceVsTGL6LJWuzlfDtrhUCVtUCsQJftQfSuBEIxlKTsZr9SQ2b2v9g41Pt8uQXJuhxQHDNMD2nKTsZr9SIUPOddSus9mmN)eSYkkwQfKuFKCkPm)jy7KACLACGaDOv9IaPXmyo(bazO8rbmibqG860jEIedbc)Y4VCeiS70SZUHSvAoQNv0nfDyGLsQNH58NGvwrXsTGK6JKtjL5pbBNuJRuJdeOdTQxei0FryKHYhv0Geab6qR6fbcuLsQlxBiqED6eprIHmu(O4eKaiqhAvViWrYbGNQlxBiqED6eprIHmu(OIoKaiqhAvViqxrH9t(v9qb)o7Ha51Pt8ejgYq5XrKqcGaDOv9IapJ5KYENebYRtN4jsmKHYJJOibqG860jEIedb6qR6fbE8tYRPoRwcei8lJ)YrGppE(Y50jwQJl1MN41c5ay((POlJd860jEk1XLAZFc2cwrXkRvZILAbj14eeieayIvM)eSDO8rrgkpoWbsaeOdTQxei0FryeiVoDINiXqgkpoaeKaiqED6eprIHaDOv9IabQsjfSPO8DIaHFz8xocC0qStQZi1q)m1Ze8k14l1JgIDbkpcPoUuJxP(XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKNsDCPg2DA2z3W4zoYRLqzVtgEMYR9K64snS70SZUbZFL9oz4zkV2tQJftQfSu)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYtPgpiqiaWeRm)jy7q5JImuECGZqcGa51Pt8ejgc0Hw1lc84NKxtDwTeiq4xg)LJaFE88LZPtmcecamXkZFc2ou(OidLhhaksaeiVoDINiXqGo0QErGu9s09Xk6YyeieayIvM)eSDO8rrgkpoamibqG860jEIedb6qR6fb(oP1V6SVaIrGqaGjwz(tW2HYhfzidbo5HJLmKaO8rrcGaDOv9IaPWI8ipXiqED6eprIHmuECGeab6qR6fbIDSQmM6qG860jEIedzO8acsaeiVoDINiXqGWVm(lhb6qReHv8YufFsn(snGi1XLAbl1MN41cEImNRiFE6w)bED6epL64sTGLAZt8AHSvAoQNv1oWUQ3aVoDINiqhAvViqONskhAvVQuDgcmvNPwNIrG0njYq5XzibqG860jEIedbc)Y4VCeOdTsewXltv8j14l1aIuhxQnpXRf8ezoxr(80T(d860jEk1XLAbl1MN41czR0CupRQDGDvVbED6eprGo0QErGqpLuo0QEvP6meyQotTofJaDs6MezO8aksaeiVoDINiXqGWVm(lhb6qReHv8YufFsn(snGi1XLAZt8AbprMZvKppDR)aVoDINsDCP28eVwiBLMJ6zvTdSR6nWRtN4jc0Hw1lce6PKYHw1RkvNHat1zQ1PyeOtEgYq5bmibqG860jEIedbc)Y4VCeOdTsewXltv8j14l1aIuhxQfSuBEIxl4jYCUI85PB9h41Pt8uQJl1MN41czR0CupRQDGDvVbED6eprGo0QErGqpLuo0QEvP6meyQotTofJapdzO8IgKaiqED6eprIHaHFz8xoc0HwjcR4LPk(KAbj14ab6qR6fbc9us5qR6vLQZqGP6m16umceMyxegzO84eKaiqhAvViq)H(YkR)NxdbYRtN4jsmKHmeOts3Kibq5JIeab6qR6fbMTst1rwFzhcKxNoXtKyidLhhibqG860jEIedbc)Y4VCe4OHyNuNrQH(zQNj4vQXxQhne7cuEeiqhAvViWrYxGQLqD2xaXidLhqqcGaDOv9IahjhaEQUCTHa51Pt8ejgYq5XzibqG860jEIedbc)Y4VCe4OHyNuNrQH(zQNj4vQXxQhne7cuEeiqhAvViWj7wofmNd07uidLhqrcGaDOv9IabQsj1LRneiVoDINiXqgkpGbjacKxNoXtKyiqhAvViqQEj6(yfDzmce(LXF5iqASXia7(N16gpv(DowYcyKsDCPMgBmcWU)zTUXtLFNJLSWZuETNuJVuhnaOsTOi1eWjcecamXkZFc2ou(OidLx0GeabYRtN4jsmeOdTQxe47Kw)QZ(cigbc)Y4VCein2yeGD)ZADJNk)ohlzbmsPoUutJngby3)Sw34PYVZXsw4zkV2tQXxQJgauPwuKAc4ebcbaMyL5pbBhkFuKHYJtqcGa51Pt8ejgce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iqGo0QErGJKVavlH6SVaIrgkVOdjacKxNoXtKyiq4xg)LJahne7K6msn0pt9mbVsn(s9OHyxGYJqQJl1cwQTccuTesDCPgVs9alLupdZ5pbRSIILA8LAc4uQJftQfSupBlKTsZr9SIUPOdwbbQwcPoUutJngbQEj6(y1a7bi8mLx7j1csQhyPK6zyo)jyLvuSudyL6OsTOi1eWPuhlMulyPE2wiBLMJ6zfDtrhSccuTesDCPwWsnn2yeO6LO7JvdShGWZuETNuJhPowmP2kkwzTAwSuJVuhfNi1XLAbl1Z2czR0CupROBk6GvqGQLab6qR6fbMTsZr9SIUPOrgkF0iHeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5rGaDOv9IapJ5KYENezO8rJIeabYRtN4jsmeOdTQxeivVeDFSIUmgbc)Y4VCein2yeO6LO7JvdShGagPuhxQPXgJavVeDFSAG9aeEMYR9KA8L6rdXoPgxPgVsTdTQ3avVeDFSIUmoa7ZKAaRud9ZuptWRuJhPwuKAc4ebcbaMyL5pbBhkFuKHYhfhibqG860jEIedb6qR6fbcuLskytr57ebc)Y4VCe4alLupdZ5pbRSIILA8LAc4uQJl1JgIDsDgPg6NPEMGxPgFPE0qSlq5ri1XLA8k1p2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uQJl1WUtZo7ggpZrETek7DYWZuETNuhxQHDNMD2ny(RS3jdpt51EsDSysTGL6hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEk14bbcbaMyL5pbBhkFuKHYhfqqcGa51Pt8ejgc0Hw1lc84NKxtDwTeiq4xg)LJaNTfo(j51uNvlr45XZxoNoXsDCPwWsnn2yeO6LO7JvdShGWZuEThcecamXkZFc2ou(OidLpkodjacKxNoXtKyiqhAvViqGQusbBkkFNiq4xg)LJahne7K6msn0pt9mbVsn(s9OHyxGYJqQJl14vQPXgJavVeDFSAG9aeoZHaj14l1aQuhlMupAi2j14l1o0QEdu9s09Xk6Y4aSptQXJuhxQXRu)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYtPoUud7on7SBy8mh51sOS3jdpt51EsDCPg2DA2z3G5VYENm8mLx7j1XIj1cwQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuJheieayIvM)eSDO8rrgkFuafjac0Hw1lc0vuy)KFvpuWVZEiqED6eprIHmu(OagKaiqhAvViWNVEDRwcL)FNfbYRtN4jsmKHYhv0Geab6qR6fbc7(N16gpv(DowYqG860jEIedzO8rXjibqG860jEIedb6qR6fbs1lr3hROlJrGWVm(lhbsJngbQEj6(y1a7biGrk1XIj1JgIDsDgP2Hw1BaOkLuWMIY3za6NPEMGxPwqs9OHyxGYJqQJftQPXgJaS7FwRB8u535yjlGrIaHaatSY8NGTdLpkYq5Jk6qcGa51Pt8ejgc0Hw1lc8DsRF1zFbeJaHaatSY8NGTdLpkYq5XrKqcGa51Pt8ejgce(LXF5iqbl1wbbQwceOdTQxey2knh1Zk6MIgzidbs3Kibq5JIeabYRtN4jsmeOdTQxe4XpjVM6SAjqGWVm(lhbsJngbrks(pLi82uHNP8ApPoUutJngbrks(pLi82uHNP8ApPgFPMaorGqaGjwz(tW2HYhfzO84ajacKxNoXtKyiqhAvViqGQusbBkkFNiq4xg)LJahne7K6msn0pt9mbVsn(s9OHyxGYJqQJl10yJry57QLiR)aCk7DsYAjuojP)UHDbmseieayIvM)eSDO8rrgkpGGeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5ri1XLAbl1wbbQwcPoUupWsj1ZWC(tWkROyPgFPMaorGo0QErGzR0CupROBkAKHYJZqcGaDOv9IaZwPP6iRVSdbYRtN4jsmKHYdOibqG860jEIedbc)Y4VCe4OHyNuNrQH(zQNj4vQXxQhne7cuEeiqhAvViWrYxGQLqD2xaXidLhWGeab6qR6fbosoa8uD5AdbYRtN4jsmKHYlAqcGa51Pt8ejgce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iqGo0QErGt2TCkyohO3Pqgkpobjac0Hw1lceOkLuxU2qG860jEIedzO8IoKaiqED6eprIHaDOv9IaFN06xD2xaXiq4xg)LJaPXgJaS7FwRB8u535yjlGrk1XLAASXia7(N16gpv(DowYcpt51Esn(sD0aGk1IIutaNiqiaWeRm)jy7q5JImu(OrcjacKxNoXtKyiqhAvViqQEj6(yfDzmce(LXF5iqASXia7(N16gpv(DowYcyKsDCPMgBmcWU)zTUXtLFNJLSWZuETNuJVuhnaOsTOi1eWjcecamXkZFc2ou(OidLpAuKaiqhAvViqxrH9t(v9qb)o7Ha51Pt8ejgYq5JIdKaiqED6eprIHaDOv9IaFN06xD2xaXiq4xg)LJaPXgJGvKQEOSCS6iz)dN5qGKAHsnGGaHaatSY8NGTdLpkYq5JciibqG860jEIedbc)Y4VCe4OHyNuNrQH(zQNj4vQXxQhne7cuEesDCPwWsTvqGQLqQJl14vQhyPK6zyo)jyLvuSuJVutaNsDSysTGL6zBHSvAoQNv0nfDWkiq1si1XLAASXiq1lr3hRgypaHNP8ApPwqs9alLupdZ5pbRSIILAaRuhvQffPMaoL6yXKAbl1Z2czR0CupROBk6GvqGQLqQJl1cwQPXgJavVeDFSAG9aeEMYR9KA8i1XIj1wrXkRvZILA8L6O4ePoUulyPE2wiBLMJ6zfDtrhSccuTeiqhAvViWSvAoQNv0nfnYq5JIZqcGa51Pt8ejgc0Hw1lceOkLuWMIY3jce(LXF5iWrdXoPoJud9ZuptWRuJVupAi2fO8iK64sTGL6hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEk1XIj1JgIDsDgPg6NPEMGxPgFPE0qSlq5ri1XLA8k14vQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuhxQfSuBEIxlCgZjL9ozGxNoXtPoUud7on7SBy8mh51sOS3jdpt51EsDCPg2DA2z3G5VYENm8mLx7j14rQJftQXRu)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYtPoUuBEIxlCgZjL9ozGxNoXtPoUud7on7SBy8mh51sOS3jdpt51EsDCPg2DA2z3G5VYENm8mLx7j1XLAy3PzNDdNXCszVtgEMYR9KA8i14rQJftQhne7KA8LAhAvVbQEj6(yfDzCa2NHaHaatSY8NGTdLpkYq5JcOibqG860jEIedbc)Y4VCe4OHyNuNrQH(zQNj4vQXxQhne7cuEeiqhAvViWZyoPS3jrgkFuadsaeiVoDINiXqGo0QErGh)K8AQZQLabc)Y4VCein2yeePi5)uIWBtfWiL64s9ZJNVCoDIL6yXK6zBHJFsEn1z1seEE88LZPtSuhxQfSutJngby3)Sw34PYVZXswaJebcbaMyL5pbBhkFuKHYhv0Geab6qR6fb(81RB1sO8)7SiqED6eprIHmu(O4eKaiqED6eprIHaHFz8xocuWsnn2yeGD)ZADJNk)ohlzbmseOdTQxeiS7FwRB8u535yjdzO8rfDibqG860jEIedbc)Y4VCein2yeO6LO7JvdShGagPuhlMupAi2j1zKAhAvVbGQusbBkkFNbOFM6zcELAbj1JgIDbkpcPowmPMgBmcWU)zTUXtLFNJLSagjc0Hw1lcKQxIUpwrxgJmuECejKaiqED6eprIHaDOv9IaFN06xD2xaXiqiaWeRm)jy7q5JImuECefjacKxNoXtKyiq4xg)LJaNTfYwP5OEwr3u0HNhpF5C6eJaDOv9IaZwP5OEwr3u0idLhh4ajacKxNoXtKyiqhAvViWJFsEn1z1sGaHFz8xocKgBmcIuK8Fkr4TPcyKiqiaWeRm)jy7q5JImKHaHZdjakFuKaiqED6eprIHaHFz8xoc08eVwW4N6u9qXlHtWu8AbED6epL64s9OHyNuJVupAi2fO8iqGo0QErG58NS7fzO84ajacKxNoXtKyiq4xg)LJaHDNMD2na7(N16gpv(DowYcpt51EsTGKAajsiqhAvViq6u3t1a7bazO8acsaeiVoDINiXqGWVm(lhbc7on7SBa29pR1nEQ87CSKfEMYR9KAbj1asKqGo0QErG(c5ZEpPGEkHmuECgsaeiVoDINiXqGWVm(lhbc7on7SBa29pR1nEQ87CSKfEMYR9KAbj1asKqGo0QErGJ6z6u3tKHYdOibqGo0QErGPIiNDkrpWMeu8AiqED6eprIHmuEadsaeiVoDINiXqGWVm(lhbc7on7SBaOkLuWMIY3zyGLsQNH58NGvwrXsTGKAc4eb6qR6fbs7eQEOSVGaDidLx0GeabYRtN4jsmei8lJ)YrGWUtZo7gGD)ZADJNk)ohlzHNP8ApPwqsnGjssDSysTvuSYA1SyPgFPokGGaDOv9IaP5)4hOAjqgkpobjacKxNoXtKyiq4xg)LJan)jylyffRSwnlwQXxQbmrsQJftQPXgJaS7FwRB8u535yjlGrIaDOv9IajBR6fzO8IoKaiqED6eprIHaHFz8xoc8XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKNsDCPE0qStQZi1q)m1Ze8k14l1JgIDbkpceOdTQxe4zmNu27KidLpAKqcGa51Pt8ejgce(LXF5iWhB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEk1XL6rdXoPoJud9ZuptWRuJVupAi2fO8iqGo0QErGJN5iVwcL9ojYq5JgfjacKxNoXtKyiq4xg)LJaFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuhxQhne7K6msn0pt9mbVsn(s9OHyxGYJqQJftQhne7K6msn0pt9mbVsn(s9OHyxGYJqQJl1p2YJ(j4W1yPr)eSIPO5)cmGJvKK8uQJl1M)k7DYWZuETNuJVutaNsDCPg2DA2z3Wi5phEMYR9KA8LAc4uQJl14vQDOvIWkEzQIpPwqsDuPowmP2HwjcR4LPk(KAHsDuPoUuBffRSwnlwQfKudOsTOi1eWPuJheOdTQxeO5VYENezO8rXbsaeiVoDINiXqGWVm(lhboAi2j1zKAOFM6zcELA8L6rdXUaLhHuhxQn)v27KbmsPoUu)ylp6NGdxJLg9tWkMIM)lWaowrsYtPoUuBffRSwnlwQfKuJZKArrQjGteOdTQxe4i5pJmu(OacsaeiVoDINiXqGWVm(lhb6qReHv8YufFsTqPoQuhxQn)jylyffRSwnlwQXxQhne7KACLA8k1o0QEdu9s09Xk6Y4aSptQbSsn0pt9mbVsnEKArrQjGteOdTQxeiqvkPUCTHmu(O4mKaiqED6eprIHaHFz8xoc0HwjcR4LPk(KAHsDuPoUuB(tWwWkkwzTAwSuJVupAi2j14k14vQDOv9gO6LO7Jv0LXbyFMudyLAOFM6zcELA8i1IIutaNiqhAvViqQEj6(yfDzmYq5JcOibqG860jEIedbc)Y4VCeOdTsewXltv8j1cL6OsDCP28NGTGvuSYA1SyPgFPE0qStQXvQXRu7qR6nq1lr3hROlJdW(mPgWk1q)m1Ze8k14rQffPMaorGo0QErGVtA9Ro7lGyKHYhfWGeabYRtN4jsmei8lJ)YrGM)eSfM1z(czPwqcLAadc0Hw1lc0psgAQEOSCSIDIeJmu(OIgKaiqED6eprIHaHFz8xoc89AQyr41c(CEHALAbj1IUij1XL6rdXoPgFPE0qSlq5ri1awPghaQuhlMuJxP2HwjcR4LPk(KAbj1rL64sTGLAZt8Ab66NNQhkYNbiWRtN4PuhlMu7qReHv8YufFsTGKACi14rQJl14vQPXgJaDc7v9qzEQ3lGrk1XLAASXiqNWEvpuMN69cpt51EsTGKAarQffPMaoL6yXKAbl10yJrGoH9QEOmp17fWiLA8GaDOv9Iahne74PYJC(lJv0StHmu(O4eKaiqED6eprIHaHFz8xoceVsnEL63RPIfHxl4Z5fEMYR9KAbj1IUij1XIj1cwQFVMkweETGpNxGJOo7KA8i1XIj14vQDOvIWkEzQIpPwqsDuPoUulyP28eVwGU(5P6HI8zac860jEk1XIj1o0kryfVmvXNuliPghsnEKA8i1XL6rdXoPgFPE0qSlq5rGaDOv9IaPtDpv9qz5yfVmfaidLpQOdjacKxNoXtKyiq4xg)LJaXRuJxP(9AQyr41c(CEHNP8ApPwqsnGjssDSysTGL63RPIfHxl4Z5f4iQZoPgpsDSysnELAhALiSIxMQ4tQfKuhvQJl1cwQnpXRfORFEQEOiFgGaVoDINsDSysTdTsewXltv8j1csQXHuJhPgpsDCPE0qStQXxQhne7cuEeiqhAvViqsSVgaulHIo5NHmuECejKaiqhAvViqcm)NLVQEO8iN)2YHa51Pt8ejgYq5XruKaiqhAvViWVijtSQw1r6qgbYRtN4jsmKHYJdCGeabYRtN4jsmei8lJ)YrGdSus9mmN)eSYkkwQXxQJk1IIutaNiqhAvViqyVqET3nEQgjNIrgkpoaeKaiqED6eprIHaHFz8xocKgBmcpdbkX3Pg9d5agjc0Hw1lc0YXkSLUX2PA0pKrgkpoWzibqGo0QErGz7pnfHRv981RVqgbYRtN4jsmKHYJdafjacKxNoXtKyiq4xg)LJan)jylKJ9KLlqcnPwqsnojssDSysT5pbBHCSNSCbsOj14luQXrKK6yXKAZFc2cwrXkRvKqtHJij1csQbKiHaDOv9IaF2jRLqnsofFidLhhagKaiqED6eprIHaHFz8xocC0qStQXxQDOv9gO6LO7Jv0LXbyFMuhxQPXgJaS7FwRB8u535yjlGrIaDOv9IaPyQ(bq1dvcdwt18zN6qgYqGNHeaLpksaeOdTQxe4i5aWt1LRneiVoDINiXqgkpoqcGaDOv9IaZwPP6iRVSdbYRtN4jsmKHYdiibqGo0QErGpF96wTek))olcKxNoXtKyidLhNHeabYRtN4jsmeOdTQxe4XpjVM6SAjqGWVm(lhbsJngbrks(pLi82ubmsPoUutJngbrks(pLi82uHNP8ApPgFPMaoL6yXKAbl1wbbQwceieayIvM)eSDO8rrgkpGIeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5rGaDOv9IaNSB5uWCoqVtHmuEadsaeiVoDINiXqGo0QErGVtA9Ro7lGyei8lJ)YrG0yJrWksvpuwowDKS)HZCiqsTqPgqqGqaGjwz(tW2HYhfzO8IgKaiqhAvViqy3)Sw34PYVZXsgcKxNoXtKyidLhNGeab6qR6fbcuLsQlxBiqED6eprIHmuErhsaeiVoDINiXqGWVm(lhboWsj1ZWC(tWkROyPgFPMaoL64s9OHyNuNrQH(zQNj4vQXxQhne7cuEesDSysnEL6LJWuzlfDtrhePtUvjwQJl1Z2ch)K8AQZQLiyfeOAjK64s9STWXpjVM6SAjcppE(Y50jwQJftQxoctLTu0nfDGmh)nvVSuhxQhne7K6msn0pt9mbVsn(s9OHyxGYJqQbSsTdTQ3aqvkPGnfLVZa0pt9mbVsTOi1aIuhxQfSutJngbQEj6(y1a7bi8mLx7j14bb6qR6fbMTsZr9SIUPOrgkF0iHeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5rGaDOv9IapJ5KYENezO8rJIeabYRtN4jsmei8lJ)YrGJgIDsDgPg6NPEMGxPgFPE0qSlq5rGaDOv9IahjFbQwc1zFbeJmu(O4ajacKxNoXtKyiqhAvViqGQusbBkkFNiq4xg)LJahne7K6msn0pt9mbVsn(s9OHyxGYJqQJl14vQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuhxQHDNMD2nmEMJ8Aju27KHNP8ApPoUud7on7SBW8xzVtgEMYR9K6yXKAbl1p2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uQXdcecamXkZFc2ou(OidLpkGGeab6qR6fb6kkSFYVQhk43zpeiVoDINiXqgkFuCgsaeiVoDINiXqGo0QErGu9s09Xk6Yyei8lJ)YrGZ2cxU3jxoPOBk6GvqGQLqQJftQPXgJavVeDFSAG9aeoZHaj1cLAafbcbaMyL5pbBhkFuKHYhfqrcGa51Pt8ejgc0Hw1lc84NKxtDwTeiq4xg)LJaFE88LZPtSuhlMutJngbrks(pLi82ubmseieayIvM)eSDO8rrgkFuadsaeiVoDINiXqGWVm(lhbUCeMkBPOBk6WL7DYLtsDCPE2w44NKxtDwTeHNP8ApPwqsnGk1IIutaNsDSys9JT8OFco8aKCGoZtaX)PG9oASDwlH6SVaIVad4yfjjprGo0QErGzR0CupROBkAKHYhv0Geab6qR6fbcZ5a9o1Ha51Pt8ejgYq5JItqcGa51Pt8ejgc0Hw1lcKQxIUpwrxgJaHFz8xocKgBmcu9s09XQb2dqaJuQJftQhne7K6msTdTQ3aqvkPGnfLVZa0pt9mbVsTGK6rdXUaLhHudyL6OaQuhlMupBlC5ENC5KIUPOdwbbQwceieayIvM)eSDO8rrgkFurhsaeiVoDINiXqGo0QErGVtA9Ro7lGyeieayIvM)eSDO8rrgkpoIesaeiVoDINiXqGWVm(lhbUCeMkBPOBk6GiDYTkXsDCPE2w44NKxtDwTebRGavlHuhlMuVCeMkBPOBk6azo(BQEzPowmPE5imv2sr3u0Hl37KlNqGo0QErGzR0CupROBkAKHmei5ZWMI2nKaO8rrcGa51Pt8ejgce(LXF5iWhB5r)eC4AS0OFcwXu08FbgWXkssEIaDOv9Ian)v27KidLhhibqGo0QErGNXCszVtIa51Pt8ejgYqgYqGIW)v9IYJJiHJifnkoaKqueyw)3AjoeOOVidIEZhzNx0VOvQLAbYXsDrr2Vj1J(LArLtEMOsQFgWXQNNs91uSu7ywt5gpLAyoFj4libgNxll1rJkALACAVIWVXtPgSOWPs9bWAEesTOwQTwQX5yUuplrQR6vQBs(DRFPgV4IhPgVrJapbjWsGf9fzq0B(i78I(fTsTulqowQlkY(nPE0VulQGj2fHfvs9Zaow98uQVMILAhZAk34PudZ5lbFbjW48AzPoAKeTsnoTxr434Pudwu4uP(aynpcPwul1wl14CmxQNLi1v9k1nj)U1VuJxCXJuJ3OrGNGeyCETSuhfhIwPgN2Ri8B8uQblkCQuFaSMhHulQLARLACoMl1ZsK6QEL6MKF36xQXlU4rQXB0iWtqcmoVwwQJcOIwPgN2Ri8B8uQblkCQuFaSMhHulQLARLACoMl1ZsK6QEL6MKF36xQXlU4rQXB0iWtqcmoVwwQJcyeTsnoTxr434Pudwu4uP(aynpcPwul1wl14CmxQNLi1v9k1nj)U1VuJxCXJuJ3OrGNGeyjWI(Imi6nFKDEr)IwPwQfihl1ffz)Mup6xQfvW5jQK6NbCS65PuFnfl1oM1uUXtPgMZxc(csGX51YsDuar0k140EfHFJNsnyrHtL6dG18iKArTuBTuJZXCPEwIux1Ru3K87w)snEXfpsnEJgbEcsGX51YsDuCMOvQXP9kc)gpLAWIcNk1haR5ri1IAP2APgNJ5s9SePUQxPUj53T(LA8IlEKA8gnc8eKaJZRLL6OaQOvQXP9kc)gpLAWIcNk1haR5ri1IAP2APgNJ5s9SePUQxPUj53T(LA8IlEKA8gnc8eKaJZRLL6OIgrRuJt7ve(nEk1IkZt8AHilrLuBTulQmpXRfISc860jEkQKA8gnc8eKaJZRLL6O4erRuJt7ve(nEk1IkZt8AHilrLuBTulQmpXRfISc860jEkQKA8gnc8eKaJZRLL6OIorRuJt7ve(nEk1IkZt8AHilrLuBTulQmpXRfISc860jEkQKA8gnc8eKalbw0xKbrV5JSZl6x0k1sTa5yPUOi73K6r)sTOYjPBsrLu)mGJvppL6RPyP2XSMYnEk1WC(sWxqcmoVwwQJgv0k140EfHFJNsnyrHtL6dG18iKArTuBTuJZXCPEwIux1Ru3K87w)snEXfpsnEJgbEcsGLahztr2VXtPgNi1o0QEL6uD2fKaJaj)Eujgbgzk1GyViLiEsQf9eBn(Lahzk15BrykA(LACGZexQXrKWrKKalboYuQbZ5ZoBY35j1pNy)yPM8R(ldaPgVzllNuhz8oEH8HNGeyjWo0QEVa5ZWMI2TmcX18xzVtkEne(ylp6NGdxJLg9tWkMIM)lWaowrsYtjWo0QEVa5ZWMI2TmcX9mMtk7DsjWsGDOv9EzeIlfwKh5jwcSdTQ3lJqCXowvgtDsGDOv9EzeIl0tjLdTQxvQot81PyH0nP41qOdTsewXltv8HpGexWMN41cEImNRiFE6w)bED6epJlyZt8AHSvAoQNv1oWUQ3aVoDINsGDOv9EzeIl0tjLdTQxvQot81PyHojDtkEne6qReHv8YufF4diXnpXRf8ezoxr(80T(d860jEgxWMN41czR0CupRQDGDvVbED6epLa7qR69YiexONskhAvVQuDM4RtXcDYZeVgcDOvIWkEzQIp8bK4MN41cEImNRiFE6w)bED6epJBEIxlKTsZr9SQ2b2v9g41Pt8ucSdTQ3lJqCHEkPCOv9Qs1zIVofl8mXRHqhALiSIxMQ4dFajUGnpXRf8ezoxr(80T(d860jEg38eVwiBLMJ6zvTdSR6nWRtN4PeyhAvVxgH4c9us5qR6vLQZeFDkwimXUiS41qOdTsewXltv8jiCib2Hw17LriU(d9Lvw)pVMeyjWo0QEVGts3KcZwPP6iRVStcSdTQ3l4K0nzgH4os(cuTeQZ(ciw8AiC0qSld0pt9mbV4pAi2fO8iKa7qR69cojDtMriUJKdapvxU2Ka7qR69cojDtMriUt2TCkyohO3PeVgchne7Ya9ZuptWl(JgIDbkpcjWo0QEVGts3KzeIlqvkPUCTjb2Hw17fCs6MmJqCP6LO7Jv0LXIdbaMyL5pbBNWOIxdH0yJra29pR1nEQ87CSKfWiJtJngby3)Sw34PYVZXsw4zkV2d)ObavuiGtjWo0QEVGts3KzeI77Kw)QZ(ciwCiaWeRm)jy7egv8AiKgBmcWU)zTUXtLFNJLSagzCASXia7(N16gpv(DowYcpt51E4hnaOIcbCkb2Hw17fCs6MmJqChjFbQwc1zFbelEneoAi2Lb6NPEMGx8hne7cuEesGDOv9EbNKUjZie3SvAoQNv0nfT41q4OHyxgOFM6zcEXF0qSlq5rexWwbbQwI44DGLsQNH58NGvwrX4taNXIj4zBHSvAoQNv0nfDWkiq1seNgBmcu9s09XQb2dq4zkV2tqdSus9mmN)eSYkkgWgvuiGZyXe8STq2knh1Zk6MIoyfeOAjIlyASXiq1lr3hRgypaHNP8Ap8elMvuSYA1Sy8JItIl4zBHSvAoQNv0nfDWkiq1sib2Hw17fCs6MmJqCpJ5KYENu8AiC0qSld0pt9mbV4pAi2fO8iKa7qR69cojDtMriUu9s09Xk6YyXHaatSY8NGTtyuXRHqASXiq1lr3hRgypabmY40yJrGQxIUpwnWEacpt51E4pAi2jQXRdTQ3avVeDFSIUmoa7ZaSq)m1Ze8IhrHaoLa7qR69cojDtMriUavPKc2uu(ofhcamXkZFc2oHrfVgchyPK6zyo)jyLvum(eWz8rdXUmq)m1Ze8I)OHyxGYJioEFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5zCy3PzNDdJN5iVwcL9oz4zkV2loS70SZUbZFL9oz4zkV2lwmb)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYt8ib2Hw17fCs6MmJqCp(j51uNvlH4qaGjwz(tW2jmQ41q4STWXpjVM6SAjcppE(Y50joUGPXgJavVeDFSAG9aeEMYR9Ka7qR69cojDtMriUavPKc2uu(ofhcamXkZFc2oHrfVgchne7Ya9ZuptWl(JgIDbkpI44LgBmcu9s09XQb2dq4mhce(aASyJgID47qR6nq1lr3hROlJdW(m8ehVp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8moS70SZUHXZCKxlHYENm8mLx7fh2DA2z3G5VYENm8mLx7flMGFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5jEKa7qR69cojDtMriUUIc7N8R6Hc(D2tcSdTQ3l4K0nzgH4(81RB1sO8)7SsGDOv9EbNKUjZiexy3)Sw34PYVZXsMeyhAvVxWjPBYmcXLQxIUpwrxgloeayIvM)eSDcJkEnesJngbQEj6(y1a7biGrgl2OHyxghAvVbGQusbBkkFNbOFM6zcEf0OHyxGYJiwmASXia7(N16gpv(DowYcyKsGDOv9EbNKUjZie33jT(vN9fqS4qaGjwz(tW2jmQeyhAvVxWjPBYmcXnBLMJ6zfDtrlEnekyRGavlHeyjWo0QEVGtEMWj7wofmNd07uIxdHJgIDzG(zQNj4f)rdXUaLhHeyhAvVxWjplJqCp(j51uNvlH4qaGjwz(tW2jmQ41qOGNTfo(j51uNvlrWkiq1se38NGTGvuSYA1SybjAKa7qR69co5zzeI7i5aWt1LRnjWo0QEVGtEwgH4(81RB1sO8)7SsGDOv9EbN8SmcXf29pR1nEQ87CSKjb2Hw17fCYZYiexGQusD5AtcSdTQ3l4KNLriUJKVavlH6SVaIfVgchne7Ya9ZuptWl(JgIDbkpcjWo0QEVGtEwgH46kkSFYVQhk43zpjWo0QEVGtEwgH4MTsZr9SIUPOfVgchyPK6zyo)jyLvum(eWzSyJgIDzG(zQNj4f)rdXUaLhrC8UCeMkBPOBk6GiDYTkXXNTfo(j51uNvlrWkiq1seF2w44NKxtDwTeHNhpF5C6ehl2YryQSLIUPOdK54VP6LJlyASXiq1lr3hRgypabmY4JgIDzG(zQNj4f)rdXUaLhbG1Hw1BaOkLuWMIY3za6NPEMGxrbqWtSywrXkRvZIXpAKKa7qR69co5zzeI7zmNu27KIxdHJgIDzG(zQNj4f)rdXUaLhHeyhAvVxWjplJqCP6LO7Jv0LXIdbaMyL5pbBNWOIxdH0yJrGQxIUpwnWEacyKXPXgJavVeDFSAG9aeEMYR9WF0qStuJxhAvVbQEj6(yfDzCa2NbyH(zQNj4fpIcbCgxW0yJriBLMQJS(YUWZuETxSy0yJrGQxIUpwnWEacpt51EXxoctLTu0nfDGmh)nvVSeyhAvVxWjplJqCbQsjfSPO8DkoeayIvM)eSDcJkEneoWsj1ZWC(tWkROy8jGZ4JgIDzG(zQNj4f)rdXUaLhHeyhAvVxWjplJqCFN06xD2xaXIdbaMyL5pbBNWOIxdH0yJrWksvpuwowDKS)HZCiqcbKyXMTfUCVtUCsr3u0bRGavlHeyhAvVxWjplJqCP6LO7Jv0LXIxdHZ2cxU3jxoPOBk6GvqGQLqcSdTQ3l4KNLriUh)K8AQZQLqCiaWeRm)jy7egv8Ai85XZxoNoXXn)jylyffRSwnlwqIgjWo0QEVGtEwgH4MTsZr9SIUPOfVgcxoctLTu0nfD4Y9o5YP4JgIDcYHw1BGQxIUpwrxghG9zIcoIpBlC8tYRPoRwIWZuETNGaurHaoLa7qR69co5zzeIlmNd07uNeyhAvVxWjplJqCbQsjfSPO8DkoeayIvM)eSDcJkEneoAi2Lb6NPEMGx8hne7cuEesGDOv9EbN8SmcXnBLMJ6zfDtrlEne(ylp6NGdpajhOZ8eq8FkyVJgBN1sOo7lG4lWaowrsYtjWo0QEVGtEwgH4s1lr3hROlJfhcamXkZFc2oHrfVgcPXgJavVeDFSAG9aeWiJfB0qSlJdTQ3aqvkPGnfLVZa0pt9mbVcA0qSlq5rayJcOXInBlC5ENC5KIUPOdwbbQwIyXOXgJq2knvhz9LDHNP8ApjWo0QEVGtEwgH4(oP1V6SVaIfhcamXkZFc2oHrLa7qR69co5zzeIB2knh1Zk6MIw8AiC5imv2sr3u0br6KBvIJpBlC8tYRPoRwIGvqGQLiwSLJWuzlfDtrhiZXFt1lhl2YryQSLIUPOdxU3jxofF0qStqaAKKalb2Hw17fOBsHh)K8AQZQLqCiaWeRm)jy7egv8AiKgBmcIuK8Fkr4TPcpt51EXPXgJGifj)NseEBQWZuETh(eWPeyhAvVxGUjZiexGQusbBkkFNIdbaMyL5pbBNWOIxdHJgIDzG(zQNj4f)rdXUaLhrCASXiS8D1sK1FaoL9ojzTekNK0F3WUagPeyhAvVxGUjZie3SvAoQNv0nfT41q4OHyxgOFM6zcEXF0qSlq5rexWwbbQwI4dSus9mmN)eSYkkgFc4ucSdTQ3lq3KzeIB2knvhz9LDsGDOv9Eb6MmJqChjFbQwc1zFbelEneoAi2Lb6NPEMGx8hne7cuEesGDOv9Eb6MmJqChjhaEQUCTjb2Hw17fOBYmcXDYULtbZ5a9oL41q4OHyxgOFM6zcEXF0qSlq5rib2Hw17fOBYmcXfOkLuxU2Ka7qR69c0nzgH4(oP1V6SVaIfhcamXkZFc2oHrfVgcPXgJaS7FwRB8u535yjlGrgNgBmcWU)zTUXtLFNJLSWZuETh(rdaQOqaNsGDOv9Eb6MmJqCP6LO7Jv0LXIdbaMyL5pbBNWOIxdH0yJra29pR1nEQ87CSKfWiJtJngby3)Sw34PYVZXsw4zkV2d)ObavuiGtjWo0QEVaDtMriUUIc7N8R6Hc(D2tcSdTQ3lq3KzeI77Kw)QZ(ciwCiaWeRm)jy7egv8AiKgBmcwrQ6HYYXQJK9pCMdbsiGib2Hw17fOBYmcXnBLMJ6zfDtrlEneoAi2Lb6NPEMGx8hne7cuEeXfSvqGQLioEhyPK6zyo)jyLvum(eWzSycE2wiBLMJ6zfDtrhSccuTeXPXgJavVeDFSAG9aeEMYR9e0alLupdZ5pbRSIIbSrffc4mwmbpBlKTsZr9SIUPOdwbbQwI4cMgBmcu9s09XQb2dq4zkV2dpXIzffRSwnlg)O4K4cE2wiBLMJ6zfDtrhSccuTesGDOv9Eb6MmJqCbQsjfSPO8DkoeayIvM)eSDcJkEneoAi2Lb6NPEMGx8hne7cuEeXf8JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpJfB0qSld0pt9mbV4pAi2fO8iIJx8(ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYZ4c28eVw4mMtk7DYaVoDINXHDNMD2nmEMJ8Aju27KHNP8AV4WUtZo7gm)v27KHNP8Ap8elgEFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5zCZt8AHZyoPS3jd860jEgh2DA2z3W4zoYRLqzVtgEMYR9Id7on7SBW8xzVtgEMYR9Id7on7SB4mMtk7DYWZuEThEWtSyJgID47qR6nq1lr3hROlJdW(mjWo0QEVaDtMriUNXCszVtkEneoAi2Lb6NPEMGx8hne7cuEesGDOv9Eb6MmJqCp(j51uNvlH4qaGjwz(tW2jmQ41qin2yeePi5)uIWBtfWiJ)845lNtN4yXMTfo(j51uNvlr45XZxoNoXXfmn2yeGD)ZADJNk)ohlzbmsjWo0QEVaDtMriUpF96wTek))oReyhAvVxGUjZiexy3)Sw34PYVZXsM41qOGPXgJaS7FwRB8u535yjlGrkb2Hw17fOBYmcXLQxIUpwrxglEnesJngbQEj6(y1a7biGrgl2OHyxghAvVbGQusbBkkFNbOFM6zcEf0OHyxGYJiwmASXia7(N16gpv(DowYcyKsGDOv9Eb6MmJqCFN06xD2xaXIdbaMyL5pbBNWOsGDOv9Eb6MmJqCZwP5OEwr3u0IxdHZ2czR0CupROBk6WZJNVCoDILa7qR69c0nzgH4E8tYRPoRwcXHaatSY8NGTtyuXRHqASXiisrY)PeH3MkGrkbwcSdTQ3laNNWC(t29kEneAEIxly8tDQEO4LWjykETaVoDINXhne7WF0qSlq5rib2Hw17fGZlJqCPtDpvdShaXRHqy3PzNDdWU)zTUXtLFNJLSWZuETNGaKijb2Hw17fGZlJqC9fYN9Esb9us8Aie2DA2z3aS7FwRB8u535yjl8mLx7jiajssGDOv9Eb48Yie3r9mDQ7P41qiS70SZUby3)Sw34PYVZXsw4zkV2tqasKKa7qR69cW5LriUPIiNDkrpWMeu8AsGDOv9Eb48YiexANq1dL9feOt8Aie2DA2z3aqvkPGnfLVZWalLupdZ5pbRSIIfebCkb2Hw17fGZlJqCP5)4hOAjeVgcHDNMD2na7(N16gpv(DowYcpt51EccWePyXSIIvwRMfJFuarcSdTQ3laNxgH4s2w1R41qO5pbBbROyL1QzX4dyIuSy0yJra29pR1nEQ87CSKfWiLa7qR69cW5LriUNXCszVtkEne(ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYZ4JgIDzG(zQNj4f)rdXUaLhHeyhAvVxaoVmcXD8mh51sOS3jfVgcFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5z8rdXUmq)m1Ze8I)OHyxGYJqcSdTQ3laNxgH4A(RS3jfVgcFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5z8rdXUmq)m1Ze8I)OHyxGYJiwSrdXUmq)m1Ze8I)OHyxGYJi(JT8OFcoCnwA0pbRykA(Vad4yfjjpJB(RS3jdpt51E4taNXHDNMD2nms(ZHNP8Ap8jGZ441HwjcR4LPk(eu0yXCOvIWkEzQIpHrJBffRSwnlwqaQOqaN4rcSdTQ3laNxgH4os(ZIxdHJgIDzG(zQNj4f)rdXUaLhrCZFL9ozaJm(JT8OFcoCnwA0pbRykA(Vad4yfjjpJBffRSwnlwq4mrHaoLa7qR69cW5LriUavPK6Y1M41qOdTsewXltv8jmACZFc2cwrXkRvZIXF0qStuJxhAvVbQEj6(yfDzCa2NbyH(zQNj4fpIcbCkb2Hw17fGZlJqCP6LO7Jv0LXIxdHo0kryfVmvXNWOXn)jylyffRSwnlg)rdXornEDOv9gO6LO7Jv0LXbyFgGf6NPEMGx8ikeWPeyhAvVxaoVmcX9DsRF1zFbelEne6qReHv8YufFcJg38NGTGvuSYA1Sy8hne7e141Hw1BGQxIUpwrxghG9zawOFM6zcEXJOqaNsGDOv9Eb48Yiex)izOP6HYYXk2jsS41qO5pbBHzDMVqwqcbmsGJmL6iJ3XlKpjWo0QEVaCEzeI7OHyhpvEKZFzSIMDkXRHW3RPIfHxl4Z5fQvqIUifF0qSd)rdXUaLhbGfhaASy41HwjcR4LPk(eu04c28eVwGU(5P6HI8zaIfZHwjcR4LPk(eeoWtC8sJngb6e2R6HY8uVxaJmon2yeOtyVQhkZt9EHNP8ApbbiIcbCglMGPXgJaDc7v9qzEQ3lGrIhjWo0QEVaCEzeIlDQ7PQhklhR4LPaq8AieV499AQyr41c(CEHNP8Apbj6IuSyc(9AQyr41c(CEboI6SdpXIHxhALiSIxMQ4tqrJlyZt8Ab66NNQhkYNbiwmhALiSIxMQ4tq4ap4j(OHyh(JgIDbkpcjWo0QEVaCEzeIlj2xdaQLqrN8ZeVgcXlEFVMkweETGpNx4zkV2tqaMiflMGFVMkweETGpNxGJOo7WtSy41HwjcR4LPk(eu04c28eVwGU(5P6HI8zaIfZHwjcR4LPk(eeoWdEIpAi2H)OHyxGYJqcSdTQ3laNxgH4sG5)S8v1dLh583wojWo0QEVaCEzeI7xKKjwvR6iDilb2Hw17fGZlJqCH9c51E34PAKCkw8AiCGLsQNH58NGvwrX4hvuiGtjWo0QEVaCEzeIRLJvylDJTt1OFilEnesJngHNHaL47uJ(HCaJucSdTQ3laNxgH4MT)0ueUw1ZxV(czjWo0QEVaCEzeI7ZozTeQrYP4t8Ai08NGTqo2twUaj0eeojsXIz(tWwih7jlxGeA4lehrkwmZFc2cwrXkRvKqtHJijiajssGDOv9Eb48YiexkMQFau9qLWG1unF2PoXRHWrdXo8DOv9gO6LO7Jv0LXbyFwCASXia7(N16gpv(DowYcyKsGLa7qR69cWe7IWcp(j51uNvlH4qaGjwz(tW2jmQ41qO5jETqoaMVFk6Y4aVoDINXPXgJGifj)NseEBQWZuETxCASXiisrY)PeH3Mk8mLx7HpbCkb2Hw17fGj2fHZie3SvAQoY6l7Ka7qR69cWe7IWzeI7ZxVUvlHY)VZkb2Hw17fGj2fHZie3SvAoQNv0nfT41q4alLupdZ5pbRSIIXNaoLa7qR69cWe7IWzeIlmNd07uNeyhAvVxaMyxeoJqCPXmyo(bq8AiC2w4Y9o5YjfDtrhSccuTeXX7STqTg)RNu0jMN1seoZHaHpoIfB2w4Y9o5YjfDtrhEMYR9WNaoXJeyhAvVxaMyxeoJqCH(lclEneoBlC5ENC5KIUPOdwbbQwcjWo0QEVamXUiCgH4oz3YPG5CGENs8AiC0qSld0pt9mbV4pAi2fO8iKa7qR69cWe7IWzeIlS7FwRB8u535yjtcSdTQ3latSlcNriU0ygmh)aiEnecZ5pbFQX7qR61tcchbanoS70SZUHSvAoQNv0nfDyGLsQNH58NGvwrXc6i5usz(tW2jQXHeyhAvVxaMyxeoJqChjFbQwc1zFbelEneoAi2Lb6NPEMGx8hne7cuEesGDOv9EbyIDr4mcXf6ViS41qiS70SZUHSvAoQNv0nfDyGLsQNH58NGvwrXc6i5usz(tW2jQXrCZt8AbprMZvKppDR)aVoDINsGDOv9EbyIDr4mcXfOkLuWMIY3P4qaGjwz(tW2jmQ41q4OHyxgOFM6zcEXF0qSlq5reFGLsQNH58NGvwrX4taNXX7JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpJd7on7SBy8mh51sOS3jdpt51EXHDNMD2ny(RS3jdpt51EXIj4hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEIhjWo0QEVamXUiCgH4MTsZr9SIUPOfVgcf8STq2knh1Zk6MIoyfeOAjKa7qR69cWe7IWzeIlnMbZXpaIxdH4vWlhHPYwk6MIoC5ENC5uSyc28eVwiBLMJ6zvTdSR6nWRtN4jEId7on7SBiBLMJ6zfDtrhgyPK6zyo)jyLvuSGosoLuM)eSDIACib2Hw17fGj2fHZiexO)IWIxdHWUtZo7gYwP5OEwr3u0HbwkPEgMZFcwzfflOJKtjL5pbBNOghsGDOv9EbyIDr4mcXfOkLuxU2Ka7qR69cWe7IWzeI7i5aWt1LRnjWo0QEVamXUiCgH46kkSFYVQhk43zpjWo0QEVamXUiCgH4EgZjL9oPeyhAvVxaMyxeoJqCp(j51uNvlH4qaGjwz(tW2jmQ41q4ZJNVCoDIJBEIxlKdG57NIUmoWRtN4zCZFc2cwrXkRvZIfeorcSdTQ3latSlcNriUq)fHLa7qR69cWe7IWzeIlqvkPGnfLVtXHaatSY8NGTtyuXRHWrdXUmq)m1Ze8I)OHyxGYJioEFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5zCy3PzNDdJN5iVwcL9oz4zkV2loS70SZUbZFL9oz4zkV2lwmb)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYt8ib2Hw17fGj2fHZie3JFsEn1z1sioeayIvM)eSDcJkEne(845lNtNyjWo0QEVamXUiCgH4s1lr3hROlJfhcamXkZFc2oHrLa7qR69cWe7IWzeI77Kw)QZ(ciwCiaWeRm)jy7egvcSeyhAvVx4mHJKdapvxU2Ka7qR69cNLriUzR0uDK1x2jb2Hw17folJqCF(61TAju()DwjWo0QEVWzzeI7XpjVM6SAjehcamXkZFc2oHrfVgcPXgJGifj)NseEBQagzCASXiisrY)PeH3Mk8mLx7HpbCglMGTccuTesGDOv9EHZYie3j7wofmNd07uIxdHJgIDzG(zQNj4f)rdXUaLhHeyhAvVx4SmcX9DsRF1zFbeloeayIvM)eSDcJkEnesJngbRiv9qz5y1rY(hoZHajeqKa7qR69cNLriUWU)zTUXtLFNJLmjWo0QEVWzzeIlqvkPUCTjb2Hw17folJqCZwP5OEwr3u0IxdHdSus9mmN)eSYkkgFc4m(OHyxgOFM6zcEXF0qSlq5relgExoctLTu0nfDqKo5wL44Z2ch)K8AQZQLiyfeOAjIpBlC8tYRPoRwIWZJNVCoDIJfB5imv2sr3u0bYC83u9YXhne7Ya9ZuptWl(JgIDbkpcaRdTQ3aqvkPGnfLVZa0pt9mbVIcGexW0yJrGQxIUpwnWEacpt51E4rcSdTQ3lCwgH4EgZjL9oP41q4OHyxgOFM6zcEXF0qSlq5rib2Hw17folJqChjFbQwc1zFbelEneoAi2Lb6NPEMGx8hne7cuEesGDOv9EHZYiexGQusbBkkFNIdbaMyL5pbBNWOIxdHJgIDzG(zQNj4f)rdXUaLhrC8(ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYZ4WUtZo7ggpZrETek7DYWZuETxCy3PzNDdM)k7DYWZuETxSyc(XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKN4rcSdTQ3lCwgH46kkSFYVQhk43zpjWo0QEVWzzeIlvVeDFSIUmwCiaWeRm)jy7egv8AiC2w4Y9o5YjfDtrhSccuTeXIrJngbQEj6(y1a7biCMdbsiGkb2Hw17folJqCp(j51uNvlH4qaGjwz(tW2jmQ41q4ZJNVCoDIJfJgBmcIuK8Fkr4TPcyKsGDOv9EHZYie3SvAoQNv0nfT41q4YryQSLIUPOdxU3jxofF2w44NKxtDwTeHNP8ApbbOIcbCgl2JT8OFco8aKCGoZtaX)PG9oASDwlH6SVaIVad4yfjjpLa7qR69cNLriUWCoqVtDsGDOv9EHZYiexQEj6(yfDzS4qaGjwz(tW2jmQ41qin2yeO6LO7JvdShGagzSyJgIDzCOv9gaQsjfSPO8DgG(zQNj4vqJgIDbkpcaBuanwSzBHl37KlNu0nfDWkiq1sib2Hw17folJqCFN06xD2xaXIdbaMyL5pbBNWOsGDOv9EHZYie3SvAoQNv0nfT41q4YryQSLIUPOdI0j3QehF2w44NKxtDwTebRGavlrSylhHPYwk6MIoqMJ)MQxowSLJWuzlfDtrhUCVtUCcbEKmeLhhakGImKHqa]] )

end