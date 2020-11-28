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

    spec:RegisterPack( "Survival", 20201128, [[dG0I)bqicOhbve1LiuInjk(eur1OiqDkcKvrOWReQMfHQBbqYUe8lOsdtiQJjKwguHNbqmncf5Aau2MqeFJqrnoHiDocL06iukZdQQ7rq7JaCqcLkwiH0dHksxeQiI(iHsvnsOIiDsOIGvcOMjurzNIklLqPkpfOPcv5RekvASqfH2lK)sYGj1HPAXi1JbnzfDzuBwHpJWOfvDAjRgQicVgqMTi3gj7wPFl1Wr0XbOA5Q65QmDkxhkBNq8DrPXleopawpaPMVqz)enkkcpe40ngLdhrghroAuCePHOrsKJeCaiiqdasgbs6qGCcgbUofJabXErkr8ecK0bi1(eHhc8AShYiW8MrEInCXLOS8y0bytH7vuyj3QEHVpmCVIcIlcKgRsgoHfrJaNUXOC4iY4iYrJIJinensICKensqGoMLVFeiyrHLCR6fN((WqG5R5KxencCYhebItwQbXErkr8KuJtk2A8lbgNSuNRfHPO5xQXrKkUuJJiJJiJat1zhcpeOtEgcpuUOi8qG860jEIefbc)Y4VCe4OHyNuhxQH(zQNj4vQXxQhne7cuEeiqhAvViWj7wEfmVd07uidLdhi8qG860jEIefb6qR6fbE8tYRPoRwcei8lJ)YrGcuQNTfo(j51uNvlrWkiq1si1zKAZFc2cwrXkRvZILAbi1IzeieayIvM)eSDOCrrgkhGGWdb6qR6fbosoa8uD5BdbYRtN4jsuKHYjMq4HaDOv9IaF(61TAju()DweiVoDINirrgkhGHWdb6qR6fbMTst1rwFzhcKxNoXtKOidLlsq4HaDOv9IaHD)ZADJNk)ohlziqED6eprIImuoXmcpeOdTQxeiqvkPU8THa51Pt8ejkYq5IueEiqED6eprIIaHFz8xocC0qStQJl1q)m1Ze8k14l1JgIDbkpceOdTQxe4i5lq1sOo7lGyKHYjwr4HaDOv9IaDff2p5x1df87ShcKxNoXtKOidLlAKr4Ha51Pt8ejkce(LXF5iWbwkPEgM3Fcwzffl14l1eWPuhlMupAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQfSuVCeMkBPOBk6GiDYTkXsDgPE2w44NKxtDwTebRGavlHuNrQNTfo(j51uNvlr45XZxENoXsDSys9YryQSLIUPOdK55VP6LL6msTaLAASXiq1lr3hRgypabmsPoJupAi2j1XLAOFM6zcELA8L6rdXUaLhHudOKAhAvVbGQusbBkkFNbOFM6zcELAXqQbePwqsDSysTvuSYA1SyPgFPoAKrGo0QErGzR0CupROBkAKHYfnkcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhbc0Hw1lc8mMtk7DsKHYffhi8qG860jEIefb6qR6fbs1lr3hROlJrGWVm(lhbsJngbQEj6(y1a7biGrk1zKAASXiq1lr3hRgypaHNP8ApPgFPE0qStQXvQfSu7qR6nq1lr3hROlJdW(mPgqj1q)m1Ze8k1csQfdPMaoL6msTaLAASXiKTst1rwFzx4zkV2tQJftQPXgJavVeDFSAG9aeEMYR9K6ms9YryQSLIUPOdK55VP6LrGqaGjwz(tW2HYffzOCrbeeEiqED6eprIIaDOv9IabQsjfSPO8DIaHFz8xocCGLsQNH59NGvwrXsn(snbCk1zK6rdXoPoUud9ZuptWRuJVupAi2fO8iqGqaGjwz(tW2HYffzOCrfti8qG860jEIefb6qR6fb(oP1V6SVaIrGWVm(lhbsJngbRiv9qz5z1rY(hoZHaj1cLAarQJftQNTfU8VtUCsr3u0bRGavlbcecamXkZFc2ouUOidLlkGHWdbYRtN4jsuei8lJ)YrGZ2cx(3jxoPOBk6GvqGQLab6qR6fbs1lr3hROlJrgkx0ibHhcKxNoXtKOiqhAvViWJFsEn1z1sGaHFz8xoc85XZxENoXsDgP28NGTGvuSYA1SyPwasTygbcbaMyL5pbBhkxuKHYfvmJWdbYRtN4jsuei8lJ)YrGlhHPYwk6MIoC5FNC5KuNrQhne7KAbi1o0QEdu9s09Xk6Y4aSptQfdPghsDgPE2w44NKxtDwTeHNP8ApPwasnGj1IHutaNiqhAvViWSvAoQNv0nfnYq5IgPi8qGo0QErGW8oqVtDiqED6eprIImuUOIveEiqED6eprIIaDOv9IabQsjfSPO8DIaHFz8xocC0qStQJl1q)m1Ze8k14l1JgIDbkpceieayIvM)eSDOCrrgkhoImcpeiVoDINirrGWVm(lhb(ylp6NGdpajhOZ8eq8FkyVJgBN1sOo7lG4lWaowrsYteOdTQxey2knh1Zk6MIgzOC4ikcpeiVoDINirrGo0QErGu9s09Xk6Yyei8lJ)YrG0yJrGQxIUpwnWEacyKsDSys9OHyNuhxQDOv9gaQsjfSPO8DgG(zQNj4vQfGupAi2fO8iKAaLuhfWK6yXK6zBHl)7KlNu0nfDWkiq1si1XIj10yJriBLMQJS(YUWZuEThcecamXkZFc2ouUOidLdh4aHhcKxNoXtKOiqhAvViW3jT(vN9fqmcecamXkZFc2ouUOidLdhaccpeiVoDINirrGWVm(lhbUCeMkBPOBk6GiDYTkXsDgPE2w44NKxtDwTebRGavlHuhlMuVCeMkBPOBk6azE(BQEzPowmPE5imv2sr3u0Hl)7KlNK6ms9OHyNulaPgWImc0Hw1lcmBLMJ6zfDtrJmKHaDs6MeHhkxueEiqhAvViWSvAQoY6l7qG860jEIefzOC4aHhcKxNoXtKOiq4xg)LJahne7K64sn0pt9mbVsn(s9OHyxGYJab6qR6fbos(cuTeQZ(cigzOCaccpeOdTQxe4i5aWt1LVneiVoDINirrgkNycHhcKxNoXtKOiq4xg)LJahne7K64sn0pt9mbVsn(s9OHyxGYJab6qR6fboz3YRG5DGENczOCagcpeOdTQxeiqvkPU8THa51Pt8ejkYq5IeeEiqED6eprIIaDOv9IaP6LO7Jv0LXiq4xg)LJaPXgJaS7FwRB8u535yjlGrk1zKAASXia7(N16gpv(DowYcpt51Esn(sD0aGj1IHutaNiqiaWeRm)jy7q5IImuoXmcpeiVoDINirrGo0QErGVtA9Ro7lGyei8lJ)YrG0yJra29pR1nEQ87CSKfWiL6msnn2yeGD)ZADJNk)ohlzHNP8ApPgFPoAaWKAXqQjGteieayIvM)eSDOCrrgkxKIWdbYRtN4jsuei8lJ)YrGJgIDsDCPg6NPEMGxPgFPE0qSlq5rGaDOv9IahjFbQwc1zFbeJmuoXkcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQfOuBfeOAjK6msTGL6bwkPEgM3Fcwzffl14l1eWPuhlMulqPE2wiBLMJ6zfDtrhSccuTesDgPMgBmcu9s09XQb2dq4zkV2tQfGupWsj1ZW8(tWkROyPgqj1rLAXqQjGtPowmPwGs9STq2knh1Zk6MIoyfeOAjK6msTaLAASXiq1lr3hRgypaHNP8ApPwqsDSysTvuSYA1SyPgFPoAKk1zKAbk1Z2czR0CupROBk6GvqGQLab6qR6fbMTsZr9SIUPOrgkx0iJWdbYRtN4jsuei8lJ)YrGJgIDsDCPg6NPEMGxPgFPE0qSlq5rGaDOv9IapJ5KYENezOCrJIWdbYRtN4jsueOdTQxeivVeDFSIUmgbc)Y4VCein2yeO6LO7JvdShGagPuNrQPXgJavVeDFSAG9aeEMYR9KA8L6rdXoPgxPwWsTdTQ3avVeDFSIUmoa7ZKAaLud9ZuptWRuliPwmKAc4ebcbaMyL5pbBhkxuKHYffhi8qG860jEIefb6qR6fbcuLskytr57ebc)Y4VCe4alLupdZ7pbRSIILA8LAc4uQZi1JgIDsDCPg6NPEMGxPgFPE0qSlq5ri1zKAbl1p2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uQZi1WUtZo7ggpZa6Aju27KHNP8ApPoJud7on7SBW8xzVtgEMYR9K6yXKAbk1p2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uQfececamXkZFc2ouUOidLlkGGWdbYRtN4jsueOdTQxe4XpjVM6SAjqGWVm(lhboBlC8tYRPoRwIWZJNV8oDIL6msTaLAASXiq1lr3hRgypaHNP8ApeieayIvM)eSDOCrrgkxuXecpeiVoDINirrGo0QErGavPKc2uu(orGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQfSutJngbQEj6(y1a7biCMdbsQXxQbmPowmPE0qStQXxQDOv9gO6LO7Jv0LXbyFMuliPoJulyP(XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKNsDgPg2DA2z3W4zgqxlHYENm8mLx7j1zKAy3PzNDdM)k7DYWZuETNuhlMulqP(XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKNsTGqGqaGjwz(tW2HYffzOCrbmeEiqhAvViqxrH9t(v9qb)o7Ha51Pt8ejkYq5Igji8qGo0QErGpF96wTek))olcKxNoXtKOidLlQygHhc0Hw1lce29pR1nEQ87CSKHa51Pt8ejkYq5IgPi8qG860jEIefb6qR6fbs1lr3hROlJrGWVm(lhbsJngbQEj6(y1a7biGrk1XIj1JgIDsDCP2Hw1BaOkLuWMIY3za6NPEMGxPwas9OHyxGYJqQJftQPXgJaS7FwRB8u535yjlGrIaHaatSY8NGTdLlkYq5Ikwr4Ha51Pt8ejkc0Hw1lc8DsRF1zFbeJaHaatSY8NGTdLlkYq5WrKr4Ha51Pt8ejkce(LXF5iqbk1wbbQwceOdTQxey2knh1Zk6MIgzidbo5HJLmeEOCrr4HaDOv9IaPWa0a6eJa51Pt8ejkYq5WbcpeOdTQxei2XQYyQdbYRtN4jsuKHYbii8qG860jEIefbc)Y4VCeOdTsewXltv8j14l1aIuNrQfOuBEIxl4jY8UI85PB9h41Pt8uQZi1cuQnpXRfYwP5OEwv7a7QEd860jEIaDOv9IaHEkPCOv9Qs1ziWuDMADkgbs3KidLtmHWdbYRtN4jsuei8lJ)YrGo0kryfVmvXNuJVudisDgP28eVwWtK5Df5Zt36pWRtN4PuNrQfOuBEIxlKTsZr9SQ2b2v9g41Pt8eb6qR6fbc9us5qR6vLQZqGP6m16umc0jPBsKHYbyi8qG860jEIefbc)Y4VCeOdTsewXltv8j14l1aIuNrQnpXRf8ezExr(80T(d860jEk1zKAZt8AHSvAoQNv1oWUQ3aVoDINiqhAvViqONskhAvVQuDgcmvNPwNIrGo5zidLlsq4Ha51Pt8ejkce(LXF5iqhALiSIxMQ4tQXxQbePoJulqP28eVwWtK5Df5Zt36pWRtN4PuNrQnpXRfYwP5OEwv7a7QEd860jEIaDOv9IaHEkPCOv9Qs1ziWuDMADkgbEgYq5eZi8qG860jEIefbc)Y4VCeOdTsewXltv8j1cqQXbc0Hw1lce6PKYHw1RkvNHat1zQ1PyeimXUimYq5IueEiqhAvViq)H(YkR)NxdbYRtN4jsuKHmei5ZWMI2neEOCrr4HaDOv9IapmkQEvKSHa51Pt8ejkYq5WbcpeiVoDINirrGWVm(lhb(ylp6NGdxJLg9tWkMIM)lWaowrsYteOdTQxeO5VYENezOCaccpeOdTQxe4zmNu27KiqED6eprIImKHaPBseEOCrr4Ha51Pt8ejkc0Hw1lc84NKxtDwTeiq4xg)LJaPXgJGifj)NseEBQWZuETNuNrQPXgJGifj)NseEBQWZuETNuJVutaNiqiaWeRm)jy7q5IImuoCGWdbYRtN4jsueOdTQxeiqvkPGnfLVtei8lJ)YrGJgIDsDCPg6NPEMGxPgFPE0qSlq5ri1zKAASXiS8D1sK1FaoL9ojzTekNK0F3WUagjcecamXkZFc2ouUOidLdqq4Ha51Pt8ejkce(LXF5iWrdXoPoUud9ZuptWRuJVupAi2fO8iK6msTaLARGavlHuNrQhyPK6zyE)jyLvuSuJVutaNiqhAvViWSvAoQNv0nfnYq5eti8qGo0QErGzR0uDK1x2Ha51Pt8ejkYq5ameEiqED6eprIIaHFz8xocC0qStQJl1q)m1Ze8k14l1JgIDbkpceOdTQxe4i5lq1sOo7lGyKHYfji8qGo0QErGJKdapvx(2qG860jEIefzOCIzeEiqED6eprIIaHFz8xocC0qStQJl1q)m1Ze8k14l1JgIDbkpceOdTQxe4KDlVcM3b6DkKHYfPi8qGo0QErGavPK6Y3gcKxNoXtKOidLtSIWdbYRtN4jsueOdTQxe47Kw)QZ(cigbc)Y4VCein2yeGD)ZADJNk)ohlzbmsPoJutJngby3)Sw34PYVZXsw4zkV2tQXxQJgamPwmKAc4ebcbaMyL5pbBhkxuKHYfnYi8qG860jEIefb6qR6fbs1lr3hROlJrGWVm(lhbsJngby3)Sw34PYVZXswaJuQZi10yJra29pR1nEQ87CSKfEMYR9KA8L6ObatQfdPMaorGqaGjwz(tW2HYffzOCrJIWdb6qR6fb6kkSFYVQhk43zpeiVoDINirrgkxuCGWdbYRtN4jsueOdTQxe47Kw)QZ(cigbc)Y4VCein2yeSIu1dLLNvhj7F4mhcKuluQbeeieayIvM)eSDOCrrgkxuabHhcKxNoXtKOiq4xg)LJahne7K64sn0pt9mbVsn(s9OHyxGYJqQZi1cuQTccuTesDgPwWs9alLupdZ7pbRSIILA8LAc4uQJftQfOupBlKTsZr9SIUPOdwbbQwcPoJutJngbQEj6(y1a7bi8mLx7j1cqQhyPK6zyE)jyLvuSudOK6OsTyi1eWPuhlMulqPE2wiBLMJ6zfDtrhSccuTesDgPwGsnn2yeO6LO7JvdShGWZuETNuliPowmP2kkwzTAwSuJVuhnsL6msTaL6zBHSvAoQNv0nfDWkiq1sGaDOv9IaZwP5OEwr3u0idLlQycHhcKxNoXtKOiqhAvViqGQusbBkkFNiq4xg)LJahne7K64sn0pt9mbVsn(s9OHyxGYJqQZi1cuQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuhlMupAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQfSulyP(XwE0pbhw(UAjY6paNYENKSwcLts6VByxGbCSIKKNsDgPwGsT5jETWzmNu27KbED6epL6msnS70SZUHXZmGUwcL9oz4zkV2tQZi1WUtZo7gm)v27KHNP8ApPwqsDSysTGL6hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEk1zKAZt8AHZyoPS3jd860jEk1zKAy3PzNDdJNzaDTek7DYWZuETNuNrQHDNMD2ny(RS3jdpt51EsDgPg2DA2z3WzmNu27KHNP8ApPwqsTGK6yXK6rdXoPgFP2Hw1BGQxIUpwrxghG9ziqiaWeRm)jy7q5IImuUOagcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhbc0Hw1lc8mMtk7DsKHYfnsq4Ha51Pt8ejkc0Hw1lc84NKxtDwTeiq4xg)LJaPXgJGifj)NseEBQagPuNrQFE88L3PtSuhlMupBlC8tYRPoRwIWZJNV8oDIL6msTaLAASXia7(N16gpv(DowYcyKiqiaWeRm)jy7q5IImuUOIzeEiqhAvViWNVEDRwcL)FNfbYRtN4jsuKHYfnsr4Ha51Pt8ejkce(LXF5iqbk10yJra29pR1nEQ87CSKfWirGo0QErGWU)zTUXtLFNJLmKHYfvSIWdbYRtN4jsuei8lJ)YrG0yJrGQxIUpwnWEacyKsDSys9OHyNuhxQDOv9gaQsjfSPO8DgG(zQNj4vQfGupAi2fO8iK6yXKAASXia7(N16gpv(DowYcyKiqhAvViqQEj6(yfDzmYq5WrKr4Ha51Pt8ejkc0Hw1lc8DsRF1zFbeJaHaatSY8NGTdLlkYq5WrueEiqED6eprIIaHFz8xocC2wiBLMJ6zfDtrhEE88L3Ptmc0Hw1lcmBLMJ6zfDtrJmuoCGdeEiqED6eprIIaDOv9Iap(j51uNvlbce(LXF5iqASXiisrY)PeH3MkGrIaHaatSY8NGTdLlkYqgceopeEOCrr4Ha51Pt8ejkce(LXF5iqZt8AbJFQt1dfVeobtXRf41Pt8uQZi1JgIDsn(s9OHyxGYJab6qR6fbM3FYUxKHYHdeEiqED6eprIIaHFz8xoce2DA2z3aS7FwRB8u535yjl8mLx7j1cqQbKiJaDOv9IaPtDpvdShaKHYbii8qG860jEIefbc)Y4VCeiS70SZUby3)Sw34PYVZXsw4zkV2tQfGudirgb6qR6fb6lKp79Kc6PeYq5eti8qG860jEIefbc)Y4VCeiS70SZUby3)Sw34PYVZXsw4zkV2tQfGudirgb6qR6fboQNPtDprgkhGHWdb6qR6fbMkI82PWjb2KGIxdbYRtN4jsuKHYfji8qG860jEIefbc)Y4VCeiS70SZUbGQusbBkkFNHbwkPEgM3Fcwzffl1cqQjGteOdTQxeiTtO6HY(cc0HmuoXmcpeiVoDINirrGWVm(lhbc7on7SBa29pR1nEQ87CSKfEMYR9KAbi1rsKL6yXKAROyL1QzXsn(sDuabb6qR6fbsZ)Xpq1sGmuUifHhcKxNoXtKOiq4xg)LJan)jylyffRSwnlwQXxQJKil1XIj10yJra29pR1nEQ87CSKfWirGo0QErGKTv9ImuoXkcpeiVoDINirrGWVm(lhb(ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYtPoJupAi2j1XLAOFM6zcELA8L6rdXUaLhbc0Hw1lc8mMtk7DsKHYfnYi8qG860jEIefbc)Y4VCe4JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpL6ms9OHyNuhxQH(zQNj4vQXxQhne7cuEeiqhAvViWXZmGUwcL9ojYq5IgfHhcKxNoXtKOiq4xg)LJaFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuNrQhne7K64sn0pt9mbVsn(s9OHyxGYJqQJftQhne7K64sn0pt9mbVsn(s9OHyxGYJqQZi1p2YJ(j4W1yPr)eSIPO5)cmGJvKK8uQZi1M)k7DYWZuETNuJVutaNsDgPg2DA2z3Wi5phEMYR9KA8LAc4uQZi1cwQDOvIWkEzQIpPwasDuPowmP2HwjcR4LPk(KAHsDuPoJuBffRSwnlwQfGudysTyi1eWPulieOdTQxeO5VYENezOCrXbcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQn)v27KbmsPoJu)ylp6NGdxJLg9tWkMIM)lWaowrsYtPoJuBffRSwnlwQfGulMKAXqQjGteOdTQxe4i5pJmuUOaccpeiVoDINirrGWVm(lhb6qReHv8YufFsTqPoQuNrQn)jylyffRSwnlwQXxQhne7KACLAbl1o0QEdu9s09Xk6Y4aSptQbusn0pt9mbVsTGKAXqQjGteOdTQxeiqvkPU8THmuUOIjeEiqED6eprIIaHFz8xoc0HwjcR4LPk(KAHsDuPoJuB(tWwWkkwzTAwSuJVupAi2j14k1cwQDOv9gO6LO7Jv0LXbyFMudOKAOFM6zcELAbj1IHutaNiqhAvViqQEj6(yfDzmYq5Icyi8qG860jEIefbc)Y4VCeOdTsewXltv8j1cL6OsDgP28NGTGvuSYA1SyPgFPE0qStQXvQfSu7qR6nq1lr3hROlJdW(mPgqj1q)m1Ze8k1csQfdPMaorGo0QErGVtA9Ro7lGyKHYfnsq4Ha51Pt8ejkce(LXF5iqZFc2cZ6mFHSulaHsDKGaDOv9Ia9JKHMQhklpRyNiXidLlQygHhcKxNoXtKOiq4xg)LJaFVMkweETGpNxOwPwasTynYsDgPE0qStQXxQhne7cuEesnGsQXbGj1XIj1cwQDOvIWkEzQIpPwasDuPoJulqP28eVwGU(5P6HI8zac860jEk1XIj1o0kryfVmvXNulaPghsTGK6msTGLAASXiqNWEvpuMN69cyKsDgPMgBmc0jSx1dL5PEVWZuETNulaPgqKAXqQjGtPowmPwGsnn2yeOtyVQhkZt9EbmsPwqiqhAvViWrdXoEQCan)LXkA2Pqgkx0ifHhcKxNoXtKOiq4xg)LJafSulyP(9AQyr41c(CEHNP8ApPwasTynYsDSysTaL63RPIfHxl4Z5f4iQZoPwqsDSysTGLAhALiSIxMQ4tQfGuhvQZi1cuQnpXRfORFEQEOiFgGaVoDINsDSysTdTsewXltv8j1cqQXHuliPwqsDgPE0qStQXxQhne7cuEeiqhAvViq6u3tvpuwEwXltbaYq5Ikwr4Ha51Pt8ejkce(LXF5iqbl1cwQFVMkweETGpNx4zkV2tQfGuhjrwQJftQfOu)EnvSi8AbFoVahrD2j1csQJftQfSu7qReHv8YufFsTaK6OsDgPwGsT5jETaD9Zt1df5Zae41Pt8uQJftQDOvIWkEzQIpPwasnoKAbj1csQZi1JgIDsn(s9OHyxGYJab6qR6fbsI91aGAju0j)mKHYHJiJWdb6qR6fbsG5)S8v1dLdO5VT8iqED6eprIImuoCefHhc0Hw1lc8lsYeRQvDKoKrG860jEIefzOC4ahi8qG860jEIefbc)Y4VCe4alLupdZ7pbRSIILA8L6OsTyi1eWjc0Hw1lce2lKx7DJNQrYPyKHYHdabHhcKxNoXtKOiq4xg)LJaPXgJWZqGs8DQr)qoGrIaDOv9IaT8ScBPBSDQg9dzKHYHdXecpeOdTQxey2(ttr4AvpF96lKrG860jEIefzOC4aWq4Ha51Pt8ejkce(LXF5iqZFc2c5zpz5dKqtQfGuhPrwQJftQn)jylKN9KLpqcnPgFHsnoISuhlMuB(tWwWkkwzTIeAkCezPwasnGezeOdTQxe4ZozTeQrYP4dzOC4isq4Ha51Pt8ejkce(LXF5iWrdXoPgFP2Hw1BGQxIUpwrxghG9zsDgPMgBmcWU)zTUXtLFNJLSagjc0Hw1lcKIP6havpujmynvZNDQdzidbEgcpuUOi8qGo0QErGJKdapvx(2qG860jEIefzOC4aHhc0Hw1lcmBLMQJS(YoeiVoDINirrgkhGGWdb6qR6fb(81RB1sO8)7SiqED6eprIImuoXecpeiVoDINirrGo0QErGh)K8AQZQLabc)Y4VCein2yeePi5)uIWBtfWiL6msnn2yeePi5)uIWBtfEMYR9KA8LAc4uQJftQfOuBfeOAjqGqaGjwz(tW2HYffzOCagcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhbc0Hw1lcCYULxbZ7a9ofYq5IeeEiqED6eprIIaDOv9IaFN06xD2xaXiq4xg)LJaPXgJGvKQEOS8S6iz)dN5qGKAHsnGGaHaatSY8NGTdLlkYq5eZi8qGo0QErGWU)zTUXtLFNJLmeiVoDINirrgkxKIWdb6qR6fbcuLsQlFBiqED6eprIImuoXkcpeiVoDINirrGWVm(lhboWsj1ZW8(tWkROyPgFPMaoL6ms9OHyNuhxQH(zQNj4vQXxQhne7cuEesDSysTGL6LJWuzlfDtrhePtUvjwQZi1Z2ch)K8AQZQLiyfeOAjK6ms9STWXpjVM6SAjcppE(Y70jwQJftQxoctLTu0nfDGmp)nvVSuNrQhne7K64sn0pt9mbVsn(s9OHyxGYJqQbusTdTQ3aqvkPGnfLVZa0pt9mbVsTyi1aIuNrQfOutJngbQEj6(y1a7bi8mLx7j1ccb6qR6fbMTsZr9SIUPOrgkx0iJWdbYRtN4jsuei8lJ)YrGJgIDsDCPg6NPEMGxPgFPE0qSlq5rGaDOv9IapJ5KYENezOCrJIWdbYRtN4jsuei8lJ)YrGJgIDsDCPg6NPEMGxPgFPE0qSlq5rGaDOv9IahjFbQwc1zFbeJmuUO4aHhcKxNoXtKOiqhAvViqGQusbBkkFNiq4xg)LJahne7K64sn0pt9mbVsn(s9OHyxGYJqQZi1cwQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PuNrQHDNMD2nmEMb01sOS3jdpt51EsDgPg2DA2z3G5VYENm8mLx7j1XIj1cuQFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PulieieayIvM)eSDOCrrgkxuabHhc0Hw1lc0vuy)KFvpuWVZEiqED6eprIImuUOIjeEiqED6eprIIaDOv9IaP6LO7Jv0LXiq4xg)LJaNTfU8VtUCsr3u0bRGavlHuhlMutJngbQEj6(y1a7biCMdbsQfk1agcecamXkZFc2ouUOidLlkGHWdbYRtN4jsueOdTQxe4XpjVM6SAjqGWVm(lhb(845lVtNyPowmPMgBmcIuK8Fkr4TPcyKiqiaWeRm)jy7q5IImuUOrccpeiVoDINirrGWVm(lhbUCeMkBPOBk6WL)DYLtsDgPE2w44NKxtDwTeHNP8ApPwasnGj1IHutaNsDSys9JT8OFco8aKCGoZtaX)PG9oASDwlH6SVaIVad4yfjjprGo0QErGzR0CupROBkAKHYfvmJWdb6qR6fbcZ7a9o1Ha51Pt8ejkYq5IgPi8qG860jEIefb6qR6fbs1lr3hROlJrGWVm(lhbsJngbQEj6(y1a7biGrk1XIj1JgIDsDCP2Hw1BaOkLuWMIY3za6NPEMGxPwas9OHyxGYJqQbusDuatQJftQNTfU8VtUCsr3u0bRGavlbcecamXkZFc2ouUOidLlQyfHhcKxNoXtKOiqhAvViW3jT(vN9fqmcecamXkZFc2ouUOidLdhrgHhcKxNoXtKOiq4xg)LJaxoctLTu0nfDqKo5wLyPoJupBlC8tYRPoRwIGvqGQLqQJftQxoctLTu0nfDGmp)nvVSuhlMuVCeMkBPOBk6WL)DYLtiqhAvViWSvAoQNv0nfnYqgceMyxegHhkxueEiqED6eprIIaDOv9Iap(j51uNvlbce(LXF5iqZt8AH8amF)u0LXbED6epL6msnn2yeePi5)uIWBtfEMYR9K6msnn2yeePi5)uIWBtfEMYR9KA8LAc4ebcbaMyL5pbBhkxuKHYHdeEiqhAvViWSvAQoY6l7qG860jEIefzOCaccpeOdTQxe4ZxVUvlHY)VZIa51Pt8ejkYq5eti8qG860jEIefbc)Y4VCe4alLupdZ7pbRSIILA8LAc4eb6qR6fbMTsZr9SIUPOrgkhGHWdb6qR6fbcZ7a9o1Ha51Pt8ejkYq5IeeEiqED6eprIIaHFz8xocC2w4Y)o5YjfDtrhSccuTesDgPwWs9STqTg)RNu0jMN1seoZHaj14l14qQJftQNTfU8VtUCsr3u0HNP8ApPgFPMaoLAbHaDOv9IaPXmyE(bazOCIzeEiqED6eprIIaHFz8xocC2w4Y)o5YjfDtrhSccuTeiqhAvViqO)IWidLlsr4Ha51Pt8ejkce(LXF5iWrdXoPoUud9ZuptWRuJVupAi2fO8iqGo0QErGt2T8kyEhO3PqgkNyfHhc0Hw1lce29pR1nEQ87CSKHa51Pt8ejkYq5IgzeEiqED6eprIIaHFz8xoceM3Fc(uJ3Hw1RNKAbi14iaysDgPg2DA2z3q2knh1Zk6MIomWsj1ZW8(tWkROyPwas9rYPKY8NGTtQXvQXbc0Hw1lcKgZG55haKHYfnkcpeiVoDINirrGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhbc0Hw1lcCK8fOAjuN9fqmYq5IIdeEiqED6eprIIaHFz8xoce2DA2z3q2knh1Zk6MIomWsj1ZW8(tWkROyPwas9rYPKY8NGTtQXvQXHuNrQnpXRf8ezExr(80T(d860jEIaDOv9IaH(lcJmuUOaccpeiVoDINirrGo0QErGavPKc2uu(orGWVm(lhboAi2j1XLAOFM6zcELA8L6rdXUaLhHuNrQhyPK6zyE)jyLvuSuJVutaNsDgPwWs9JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpL6msnS70SZUHXZmGUwcL9oz4zkV2tQZi1WUtZo7gm)v27KHNP8ApPowmPwGs9JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpLAbHaHaatSY8NGTdLlkYq5IkMq4Ha51Pt8ejkce(LXF5iqbk1Z2czR0CupROBk6GvqGQLab6qR6fbMTsZr9SIUPOrgkxuadHhcKxNoXtKOiq4xg)LJafSulqPE5imv2sr3u0Hl)7KlNK6yXKAbk1MN41czR0CupRQDGDvVbED6epLAbj1zKAy3PzNDdzR0CupROBk6WalLupdZ7pbRSIILAbi1hjNskZFc2oPgxPghiqhAvViqAmdMNFaqgkx0ibHhcKxNoXtKOiq4xg)LJaHDNMD2nKTsZr9SIUPOddSus9mmV)eSYkkwQfGuFKCkPm)jy7KACLACGaDOv9IaH(lcJmuUOIzeEiqhAvViqGQusD5BdbYRtN4jsuKHYfnsr4HaDOv9IahjhaEQU8THa51Pt8ejkYq5Ikwr4HaDOv9IaDff2p5x1df87ShcKxNoXtKOidLdhrgHhc0Hw1lc8mMtk7DseiVoDINirrgkhoIIWdbYRtN4jsueOdTQxe4XpjVM6SAjqGWVm(lhb(845lVtNyPoJuBEIxlKhG57NIUmoWRtN4PuNrQn)jylyffRSwnlwQfGuhPiqiaWeRm)jy7q5IImuoCGdeEiqhAvViqO)IWiqED6eprIImuoCaii8qG860jEIefb6qR6fbcuLskytr57ebc)Y4VCe4OHyNuhxQH(zQNj4vQXxQhne7cuEesDgPwWs9JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpL6msnS70SZUHXZmGUwcL9oz4zkV2tQZi1WUtZo7gm)v27KHNP8ApPowmPwGs9JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpLAbHaHaatSY8NGTdLlkYq5WHycHhcKxNoXtKOiqhAvViWJFsEn1z1sGaHFz8xoc85XZxENoXiqiaWeRm)jy7q5IImuoCayi8qG860jEIefb6qR6fbs1lr3hROlJrGqaGjwz(tW2HYffzOC4isq4Ha51Pt8ejkc0Hw1lc8DsRF1zFbeJaHaatSY8NGTdLlkYqgYqGIW)v9IYHJiJJihnkoetiWS(V1sCiqXUIDe7LdNqoX(InPwQXlpl1ffz)Mup6xQX5o5z4CP(zahREEk1xtXsTJznLB8uQH59LGVGeyCwTSuhfhInPgN2Ri8B8uQblkCQuFaSMhHulwKARLACgMl1ZsK6QEL6MKF36xQfmUcsQfC0ieuqcSeyXUIDe7LdNqoX(InPwQXlpl1ffz)Mup6xQX5We7IW4CP(zahREEk1xtXsTJznLB8uQH59LGVGeyCwTSuhnYInPgN2Ri8B8uQblkCQuFaSMhHulwKARLACgMl1ZsK6QEL6MKF36xQfmUcsQfC0ieuqcmoRwwQJIdXMuJt7ve(nEk1GffovQpawZJqQflsT1snodZL6zjsDvVsDtYVB9l1cgxbj1coAeckibgNvll1rbmXMuJt7ve(nEk1GffovQpawZJqQflsT1snodZL6zjsDvVsDtYVB9l1cgxbj1coAeckibgNvll1rJeXMuJt7ve(nEk1GffovQpawZJqQflsT1snodZL6zjsDvVsDtYVB9l1cgxbj1coAeckibwcSyxXoI9YHtiNyFXMul14LNL6IISFtQh9l14C48W5s9Zaow98uQVMILAhZAk34PudZ7lbFbjW4SAzPokGi2KACAVIWVXtPgSOWPs9bWAEesTyrQTwQXzyUuplrQR6vQBs(DRFPwW4kiPwWrJqqbjW4SAzPoQysSj140EfHFJNsnyrHtL6dG18iKAXIuBTuJZWCPEwIux1Ru3K87w)sTGXvqsTGJgHGcsGXz1YsDuatSj140EfHFJNsnyrHtL6dG18iKAXIuBTuJZWCPEwIux1Ru3K87w)sTGXvqsTGJgHGcsGXz1YsDuXSytQXP9kc)gpLACU5jETaorCUuBTuJZnpXRfWjg41Pt8eNl1coAeckibgNvll1rJuXMuJt7ve(nEk14CZt8AbCI4CP2APgNBEIxlGtmWRtN4joxQfC0ieuqcmoRwwQJkwfBsnoTxr434PuJZnpXRfWjIZLARLACU5jETaoXaVoDIN4CPwWrJqqbjWsGf7k2rSxoCc5e7l2KAPgV8SuxuK9Bs9OFPgN7K0njoxQFgWXQNNs91uSu7ywt5gpLAyEFj4libgNvll1rJk2KACAVIWVXtPgSOWPs9bWAEesTyrQTwQXzyUuplrQR6vQBs(DRFPwW4kiPwWrJqqbjWsGXjqr2VXtPosLAhAvVsDQo7csGrGKFpQeJaXjl1GyViLiEsQXjfBn(LaJtwQZ1IWu08l14isfxQXrKXrKLalb2Hw17fiFg2u0UfxiUhgfvVks2Ka7qR69cKpdBkA3IlexZFL9oP41q4JT8OFcoCnwA0pbRykA(Vad4yfjjpLa7qR69cKpdBkA3Ile3ZyoPS3jLalb2Hw17fxiUuyaAaDILa7qR69IlexSJvLXuNeyhAvVxCH4c9us5qR6vLQZeFDkwiDtkEne6qReHv8YufF4dizeO5jETGNiZ7kYNNU1FGxNoXZmc08eVwiBLMJ6zvTdSR6nWRtN4PeyhAvVxCH4c9us5qR6vLQZeFDkwOts3KIxdHo0kryfVmvXh(asgZt8AbprM3vKppDR)aVoDINzeO5jETq2knh1ZQAhyx1BGxNoXtjWo0QEV4cXf6PKYHw1RkvNj(6uSqN8mXRHqhALiSIxMQ4dFajJ5jETGNiZ7kYNNU1FGxNoXZmMN41czR0CupRQDGDvVbED6epLa7qR69IlexONskhAvVQuDM4RtXcpt8Ai0HwjcR4LPk(WhqYiqZt8AbprM3vKppDR)aVoDINzmpXRfYwP5OEwv7a7QEd860jEkb2Hw17fxiUqpLuo0QEvP6mXxNIfctSlclEne6qReHv8YufFcahsGDOv9EXfIR)qFzL1)ZRjbwcSdTQ3l4K0nPWSvAQoY6l7Ka7qR69cojDtgxiUJKVavlH6SVaIfVgchne7Id9ZuptWl(JgIDbkpcjWo0QEVGts3KXfI7i5aWt1LVnjWo0QEVGts3KXfI7KDlVcM3b6DkXRHWrdXU4q)m1Ze8I)OHyxGYJqcSdTQ3l4K0nzCH4cuLsQlFBsGDOv9EbNKUjJlexQEj6(yfDzS4qaGjwz(tW2jmQ41qin2yeGD)ZADJNk)ohlzbmYm0yJra29pR1nEQ87CSKfEMYR9WpAaWedc4ucSdTQ3l4K0nzCH4(oP1V6SVaIfhcamXkZFc2oHrfVgcPXgJaS7FwRB8u535yjlGrMHgBmcWU)zTUXtLFNJLSWZuETh(rdaMyqaNsGDOv9EbNKUjJle3rYxGQLqD2xaXIxdHJgIDXH(zQNj4f)rdXUaLhHeyhAvVxWjPBY4cXnBLMJ6zfDtrlEneoAi2fh6NPEMGx8hne7cuEezeOvqGQLiJGhyPK6zyE)jyLvum(eWzSycC2wiBLMJ6zfDtrhSccuTezOXgJavVeDFSAG9aeEMYR9eWalLupdZ7pbRSIIburfdc4mwmboBlKTsZr9SIUPOdwbbQwImcKgBmcu9s09XQb2dq4zkV2tqXIzffRSwnlg)OrAgboBlKTsZr9SIUPOdwbbQwcjWo0QEVGts3KXfI7zmNu27KIxdHJgIDXH(zQNj4f)rdXUaLhHeyhAvVxWjPBY4cXLQxIUpwrxgloeayIvM)eSDcJkEnesJngbQEj6(y1a7biGrMHgBmcu9s09XQb2dq4zkV2d)rdXoXIGDOv9gO6LO7Jv0LXbyFgGc6NPEMGxbjgeWPeyhAvVxWjPBY4cXfOkLuWMIY3P4qaGjwz(tW2jmQ41q4alLupdZ7pbRSIIXNaoZmAi2fh6NPEMGx8hne7cuEeze8JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpZa7on7SBy8mdORLqzVtgEMYR9Ya7on7SBW8xzVtgEMYR9IftGp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uqsGDOv9EbNKUjJle3JFsEn1z1sioeayIvM)eSDcJkEneoBlC8tYRPoRwIWZJNV8oDIZiqASXiq1lr3hRgypaHNP8ApjWo0QEVGts3KXfIlqvkPGnfLVtXHaatSY8NGTtyuXRHWrdXU4q)m1Ze8I)OHyxGYJiJGPXgJavVeDFSAG9aeoZHaHpGfl2OHyh(o0QEdu9s09Xk6Y4aSptqze8JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpZa7on7SBy8mdORLqzVtgEMYR9Ya7on7SBW8xzVtgEMYR9IftGp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uqsGDOv9EbNKUjJlexxrH9t(v9qb)o7jb2Hw17fCs6MmUqCF(61TAju()DwjWo0QEVGts3KXfIlS7FwRB8u535yjtcSdTQ3l4K0nzCH4s1lr3hROlJfhcamXkZFc2oHrfVgcPXgJavVeDFSAG9aeWiJfB0qSlUdTQ3aqvkPGnfLVZa0pt9mbVcy0qSlq5relgn2yeGD)ZADJNk)ohlzbmsjWo0QEVGts3KXfI77Kw)QZ(ciwCiaWeRm)jy7egvcSdTQ3l4K0nzCH4MTsZr9SIUPOfVgcfOvqGQLqcSeyhAvVxWjpt4KDlVcM3b6DkXRHWrdXU4q)m1Ze8I)OHyxGYJqcSdTQ3l4KNfxiUh)K8AQZQLqCiaWeRm)jy7egv8AiuGZ2ch)K8AQZQLiyfeOAjYy(tWwWkkwzTAwSaeZsGDOv9EbN8S4cXDKCa4P6Y3MeyhAvVxWjplUqCF(61TAju()DwjWo0QEVGtEwCH4MTst1rwFzNeyhAvVxWjplUqCHD)ZADJNk)ohlzsGDOv9EbN8S4cXfOkLux(2Ka7qR69co5zXfI7i5lq1sOo7lGyXRHWrdXU4q)m1Ze8I)OHyxGYJqcSdTQ3l4KNfxiUUIc7N8R6Hc(D2tcSdTQ3l4KNfxiUzR0CupROBkAXRHWbwkPEgM3FcwzffJpbCgl2OHyxCOFM6zcEXF0qSlq5rKrWlhHPYwk6MIoisNCRsCMzBHJFsEn1z1seSccuTezMTfo(j51uNvlr45XZxENoXXITCeMkBPOBk6azE(BQE5mcKgBmcu9s09XQb2dqaJmZOHyxCOFM6zcEXF0qSlq5raOCOv9gaQsjfSPO8DgG(zQNj4vmaebflMvuSYA1Sy8JgzjWo0QEVGtEwCH4EgZjL9oP41q4OHyxCOFM6zcEXF0qSlq5rib2Hw17fCYZIlexQEj6(yfDzS4qaGjwz(tW2jmQ41qin2yeO6LO7JvdShGagzgASXiq1lr3hRgypaHNP8Ap8hne7elc2Hw1BGQxIUpwrxghG9zakOFM6zcEfKyqaNzein2yeYwPP6iRVSl8mLx7flgn2yeO6LO7JvdShGWZuETxMLJWuzlfDtrhiZZFt1llb2Hw17fCYZIlexGQusbBkkFNIdbaMyL5pbBNWOIxdHdSus9mmV)eSYkkgFc4mZOHyxCOFM6zcEXF0qSlq5rib2Hw17fCYZIle33jT(vN9fqS4qaGjwz(tW2jmQ41qin2yeSIu1dLLNvhj7F4mhcKqajwSzBHl)7KlNu0nfDWkiq1sib2Hw17fCYZIlexQEj6(yfDzS41q4STWL)DYLtk6MIoyfeOAjKa7qR69co5zXfI7XpjVM6SAjehcamXkZFc2oHrfVgcFE88L3PtCgZFc2cwrXkRvZIfGywcSdTQ3l4KNfxiUzR0CupROBkAXRHWLJWuzlfDtrhU8VtUCkZOHyNaCOv9gO6LO7Jv0LXbyFMyGJmZ2ch)K8AQZQLi8mLx7jaatmiGtjWo0QEVGtEwCH4cZ7a9o1jb2Hw17fCYZIlexGQusbBkkFNIdbaMyL5pbBNWOIxdHJgIDXH(zQNj4f)rdXUaLhHeyhAvVxWjplUqCZwP5OEwr3u0IxdHp2YJ(j4WdqYb6mpbe)Nc27OX2zTeQZ(ci(cmGJvKK8ucSdTQ3l4KNfxiUu9s09Xk6YyXHaatSY8NGTtyuXRHqASXiq1lr3hRgypabmYyXgne7I7qR6nauLskytr57ma9ZuptWRagne7cuEeaQOawSyZ2cx(3jxoPOBk6GvqGQLiwmASXiKTst1rwFzx4zkV2tcSdTQ3l4KNfxiUVtA9Ro7lGyXHaatSY8NGTtyujWo0QEVGtEwCH4MTsZr9SIUPOfVgcxoctLTu0nfDqKo5wL4mZ2ch)K8AQZQLiyfeOAjIfB5imv2sr3u0bY883u9YXITCeMkBPOBk6WL)DYLtzgne7eaGfzjWsGDOv9Eb6Mu4XpjVM6SAjehcamXkZFc2oHrfVgcPXgJGifj)NseEBQWZuETxgASXiisrY)PeH3Mk8mLx7HpbCkb2Hw17fOBY4cXfOkLuWMIY3P4qaGjwz(tW2jmQ41q4OHyxCOFM6zcEXF0qSlq5rKHgBmclFxTez9hGtzVtswlHYjj93nSlGrkb2Hw17fOBY4cXnBLMJ6zfDtrlEneoAi2fh6NPEMGx8hne7cuEezeOvqGQLiZalLupdZ7pbRSIIXNaoLa7qR69c0nzCH4MTst1rwFzNeyhAvVxGUjJle3rYxGQLqD2xaXIxdHJgIDXH(zQNj4f)rdXUaLhHeyhAvVxGUjJle3rYbGNQlFBsGDOv9Eb6MmUqCNSB5vW8oqVtjEneoAi2fh6NPEMGx8hne7cuEesGDOv9Eb6MmUqCbQsj1LVnjWo0QEVaDtgxiUVtA9Ro7lGyXHaatSY8NGTtyuXRHqASXia7(N16gpv(DowYcyKzOXgJaS7FwRB8u535yjl8mLx7HF0aGjgeWPeyhAvVxGUjJlexQEj6(yfDzS4qaGjwz(tW2jmQ41qin2yeGD)ZADJNk)ohlzbmYm0yJra29pR1nEQ87CSKfEMYR9WpAaWedc4ucSdTQ3lq3KXfIRROW(j)QEOGFN9Ka7qR69c0nzCH4(oP1V6SVaIfhcamXkZFc2oHrfVgcPXgJGvKQEOS8S6iz)dN5qGecisGDOv9Eb6MmUqCZwP5OEwr3u0IxdHJgIDXH(zQNj4f)rdXUaLhrgbAfeOAjYi4bwkPEgM3FcwzffJpbCglMaNTfYwP5OEwr3u0bRGavlrgASXiq1lr3hRgypaHNP8ApbmWsj1ZW8(tWkROyavuXGaoJftGZ2czR0CupROBk6GvqGQLiJaPXgJavVeDFSAG9aeEMYR9euSywrXkRvZIXpAKMrGZ2czR0CupROBk6GvqGQLqcSdTQ3lq3KXfIlqvkPGnfLVtXHaatSY8NGTtyuXRHWrdXU4q)m1Ze8I)OHyxGYJiJaFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5zSyJgIDXH(zQNj4f)rdXUaLhrgbl4hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEMrGMN41cNXCszVtg41Pt8mdS70SZUHXZmGUwcL9oz4zkV2ldS70SZUbZFL9oz4zkV2tqXIj4hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEMX8eVw4mMtk7DYaVoDINzGDNMD2nmEMb01sOS3jdpt51EzGDNMD2ny(RS3jdpt51EzGDNMD2nCgZjL9oz4zkV2tqckwSrdXo8DOv9gO6LO7Jv0LXbyFMeyhAvVxGUjJle3ZyoPS3jfVgchne7Id9ZuptWl(JgIDbkpcjWo0QEVaDtgxiUh)K8AQZQLqCiaWeRm)jy7egv8AiKgBmcIuK8Fkr4TPcyKzEE88L3PtCSyZ2ch)K8AQZQLi8845lVtN4mcKgBmcWU)zTUXtLFNJLSagPeyhAvVxGUjJle3NVEDRwcL)FNvcSdTQ3lq3KXfIlS7FwRB8u535yjt8AiuG0yJra29pR1nEQ87CSKfWiLa7qR69c0nzCH4s1lr3hROlJfVgcPXgJavVeDFSAG9aeWiJfB0qSlUdTQ3aqvkPGnfLVZa0pt9mbVcy0qSlq5relgn2yeGD)ZADJNk)ohlzbmsjWo0QEVaDtgxiUVtA9Ro7lGyXHaatSY8NGTtyujWo0QEVaDtgxiUzR0CupROBkAXRHWzBHSvAoQNv0nfD45XZxENoXsGDOv9Eb6MmUqCp(j51uNvlH4qaGjwz(tW2jmQ41qin2yeePi5)uIWBtfWiLalb2Hw17fGZtyE)j7EfVgcnpXRfm(Povpu8s4emfVwGxNoXZmJgID4pAi2fO8iKa7qR69cW5fxiU0PUNQb2dG41qiS70SZUby3)Sw34PYVZXsw4zkV2taasKLa7qR69cW5fxiU(c5ZEpPGEkjEnec7on7SBa29pR1nEQ87CSKfEMYR9eaGezjWo0QEVaCEXfI7OEMo19u8Aie2DA2z3aS7FwRB8u535yjl8mLx7jaajYsGDOv9Eb48Ile3urK3ofojWMeu8AsGDOv9Eb48IlexANq1dL9feOt8Aie2DA2z3aqvkPGnfLVZWalLupdZ7pbRSIIfabCkb2Hw17fGZlUqCP5)4hOAjeVgcHDNMD2na7(N16gpv(DowYcpt51EcisICSywrXkRvZIXpkGib2Hw17fGZlUqCjBR6v8Ai08NGTGvuSYA1Sy8JKihlgn2yeGD)ZADJNk)ohlzbmsjWo0QEVaCEXfI7zmNu27KIxdHp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8mZOHyxCOFM6zcEXF0qSlq5rib2Hw17fGZlUqChpZa6Aju27KIxdHp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8mZOHyxCOFM6zcEXF0qSlq5rib2Hw17fGZlUqCn)v27KIxdHp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8mZOHyxCOFM6zcEXF0qSlq5rel2OHyxCOFM6zcEXF0qSlq5rK5XwE0pbhUgln6NGvmfn)xGbCSIKKNzm)v27KHNP8Ap8jGZmWUtZo7ggj)5WZuETh(eWzgb7qReHv8YufFciASyo0kryfVmvXNWOzSIIvwRMflaatmiGtbjb2Hw17fGZlUqChj)zXRHWrdXU4q)m1Ze8I)OHyxGYJiJ5VYENmGrM5XwE0pbhUgln6NGvmfn)xGbCSIKKNzSIIvwRMflaXKyqaNsGDOv9Eb48IlexGQusD5Bt8Ai0HwjcR4LPk(egnJ5pbBbROyL1QzX4pAi2jweSdTQ3avVeDFSIUmoa7Zauq)m1Ze8kiXGaoLa7qR69cW5fxiUu9s09Xk6YyXRHqhALiSIxMQ4ty0mM)eSfSIIvwRMfJ)OHyNyrWo0QEdu9s09Xk6Y4aSpdqb9ZuptWRGedc4ucSdTQ3laNxCH4(oP1V6SVaIfVgcDOvIWkEzQIpHrZy(tWwWkkwzTAwm(JgIDIfb7qR6nq1lr3hROlJdW(maf0pt9mbVcsmiGtjWo0QEVaCEXfIRFKm0u9qz5zf7ejw8Ai08NGTWSoZxilaHrIeyCYsnojVJxiFsGDOv9Eb48Ile3rdXoEQCan)LXkA2PeVgcFVMkweETGpNxOwbiwJCMrdXo8hne7cuEeakCayXIjyhALiSIxMQ4tarZiqZt8Ab66NNQhkYNbiwmhALiSIxMQ4ta4qqzemn2yeOtyVQhkZt9EbmYm0yJrGoH9QEOmp17fEMYR9eaGigeWzSycKgBmc0jSx1dL5PEVagPGKa7qR69cW5fxiU0PUNQEOS8SIxMcaXRHqbl43RPIfHxl4Z5fEMYR9eGynYXIjW3RPIfHxl4Z5f4iQZobflMGDOvIWkEzQIpbenJanpXRfORFEQEOiFgGyXCOvIWkEzQIpbGdbjOmJgID4pAi2fO8iKa7qR69cW5fxiUKyFnaOwcfDYpt8AiuWc(9AQyr41c(CEHNP8Apbejrowmb(EnvSi8AbFoVahrD2jOyXeSdTsewXltv8jGOzeO5jETaD9Zt1df5ZaelMdTsewXltv8jaCiibLz0qSd)rdXUaLhHeyhAvVxaoV4cXLaZ)z5RQhkhqZFB5La7qR69cW5fxiUFrsMyvTQJ0HSeyhAvVxaoV4cXf2lKx7DJNQrYPyXRHWbwkPEgM3FcwzffJFuXGaoLa7qR69cW5fxiUwEwHT0n2ovJ(HS41qin2yeEgcuIVtn6hYbmsjWo0QEVaCEXfIB2(ttr4AvpF96lKLa7qR69cW5fxiUp7K1sOgjNIpXRHqZFc2c5zpz5dKqtarAKJfZ8NGTqE2tw(aj0WxioICSyM)eSfSIIvwRiHMchrwaasKLa7qR69cW5fxiUumv)aO6HkHbRPA(StDIxdHJgID47qR6nq1lr3hROlJdW(Sm0yJra29pR1nEQ87CSKfWiLalb2Hw17fGj2fHfE8tYRPoRwcXHaatSY8NGTtyuXRHqZt8AH8amF)u0LXbED6epZqJngbrks(pLi82uHNP8AVm0yJrqKIK)tjcVnv4zkV2dFc4ucSdTQ3latSlchxiUzR0uDK1x2jb2Hw17fGj2fHJle3NVEDRwcL)FNvcSdTQ3latSlchxiUzR0CupROBkAXRHWbwkPEgM3FcwzffJpbCkb2Hw17fGj2fHJlexyEhO3PojWo0QEVamXUiCCH4sJzW88dG41q4STWL)DYLtk6MIoyfeOAjYi4zBHAn(xpPOtmpRLiCMdbcFCel2STWL)DYLtk6MIo8mLx7HpbCkijWo0QEVamXUiCCH4c9xew8AiC2w4Y)o5YjfDtrhSccuTesGDOv9EbyIDr44cXDYULxbZ7a9oL41q4OHyxCOFM6zcEXF0qSlq5rib2Hw17fGj2fHJlexy3)Sw34PYVZXsMeyhAvVxaMyxeoUqCPXmyE(bq8AieM3Fc(uJ3Hw1RNeaocawgy3PzNDdzR0CupROBk6WalLupdZ7pbRSIIfWrYPKY8NGTtSGdjWo0QEVamXUiCCH4os(cuTeQZ(ciw8AiC0qSlo0pt9mbV4pAi2fO8iKa7qR69cWe7IWXfIl0FryXRHqy3PzNDdzR0CupROBk6WalLupdZ7pbRSIIfWrYPKY8NGTtSGJmMN41cEImVRiFE6w)bED6epLa7qR69cWe7IWXfIlqvkPGnfLVtXHaatSY8NGTtyuXRHWrdXU4q)m1Ze8I)OHyxGYJiZalLupdZ7pbRSIIXNaoZi4hB5r)eCy57QLiR)aCk7DsYAjuojP)UHDbgWXkssEMb2DA2z3W4zgqxlHYENm8mLx7Lb2DA2z3G5VYENm8mLx7flMaFSLh9tWHLVRwIS(dWPS3jjRLq5KK(7g2fyahRij5PGKa7qR69cWe7IWXfIB2knh1Zk6MIw8AiuGZ2czR0CupROBk6GvqGQLqcSdTQ3latSlchxiU0ygmp)aiEnekybUCeMkBPOBk6WL)DYLtXIjqZt8AHSvAoQNv1oWUQ3aVoDINckdS70SZUHSvAoQNv0nfDyGLsQNH59NGvwrXc4i5usz(tW2jwWHeyhAvVxaMyxeoUqCH(lclEnec7on7SBiBLMJ6zfDtrhgyPK6zyE)jyLvuSaosoLuM)eSDIfCib2Hw17fGj2fHJlexGQusD5BtcSdTQ3latSlchxiUJKdapvx(2Ka7qR69cWe7IWXfIRROW(j)QEOGFN9Ka7qR69cWe7IWXfI7zmNu27KsGDOv9EbyIDr44cX94NKxtDwTeIdbaMyL5pbBNWOIxdHppE(Y70joJ5jETqEaMVFk6Y4aVoDINzm)jylyffRSwnlwarQeyhAvVxaMyxeoUqCH(lclb2Hw17fGj2fHJlexGQusbBkkFNIdbaMyL5pbBNWOIxdHJgIDXH(zQNj4f)rdXUaLhrgb)ylp6NGdlFxTez9hGtzVtswlHYjj93nSlWaowrsYZmWUtZo7ggpZa6Aju27KHNP8AVmWUtZo7gm)v27KHNP8AVyXe4JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpfKeyhAvVxaMyxeoUqCp(j51uNvlH4qaGjwz(tW2jmQ41q4ZJNV8oDILa7qR69cWe7IWXfIlvVeDFSIUmwCiaWeRm)jy7egvcSdTQ3latSlchxiUVtA9Ro7lGyXHaatSY8NGTtyujWsGDOv9EHZeosoa8uD5BtcSdTQ3lCwCH4MTst1rwFzNeyhAvVx4S4cX95Rx3QLq5)3zLa7qR69cNfxiUh)K8AQZQLqCiaWeRm)jy7egv8AiKgBmcIuK8Fkr4TPcyKzOXgJGifj)NseEBQWZuETh(eWzSyc0kiq1sib2Hw17folUqCNSB5vW8oqVtjEneoAi2fh6NPEMGx8hne7cuEesGDOv9EHZIle33jT(vN9fqS4qaGjwz(tW2jmQ41qin2yeSIu1dLLNvhj7F4mhcKqarcSdTQ3lCwCH4c7(N16gpv(DowYKa7qR69cNfxiUavPK6Y3MeyhAvVx4S4cXnBLMJ6zfDtrlEneoWsj1ZW8(tWkROy8jGZmJgIDXH(zQNj4f)rdXUaLhrSycE5imv2sr3u0br6KBvIZmBlC8tYRPoRwIGvqGQLiZSTWXpjVM6SAjcppE(Y70jowSLJWuzlfDtrhiZZFt1lNz0qSlo0pt9mbV4pAi2fO8iauo0QEdavPKc2uu(odq)m1Ze8kgasgbsJngbQEj6(y1a7bi8mLx7jijWo0QEVWzXfI7zmNu27KIxdHJgIDXH(zQNj4f)rdXUaLhHeyhAvVx4S4cXDK8fOAjuN9fqS41q4OHyxCOFM6zcEXF0qSlq5rib2Hw17folUqCbQsjfSPO8DkoeayIvM)eSDcJkEneoAi2fh6NPEMGx8hne7cuEeze8JT8OFcoS8D1sK1FaoL9ojzTekNK0F3WUad4yfjjpZa7on7SBy8mdORLqzVtgEMYR9Ya7on7SBW8xzVtgEMYR9IftGp2YJ(j4WY3vlrw)b4u27KK1sOCss)Dd7cmGJvKK8uqsGDOv9EHZIlexxrH9t(v9qb)o7jb2Hw17folUqCP6LO7Jv0LXIdbaMyL5pbBNWOIxdHZ2cx(3jxoPOBk6GvqGQLiwmASXiq1lr3hRgypaHZCiqcbmjWo0QEVWzXfI7XpjVM6SAjehcamXkZFc2oHrfVgcFE88L3PtCSy0yJrqKIK)tjcVnvaJucSdTQ3lCwCH4MTsZr9SIUPOfVgcxoctLTu0nfD4Y)o5YPmZ2ch)K8AQZQLi8mLx7jaatmiGZyXESLh9tWHhGKd0zEci(pfS3rJTZAjuN9fq8fyahRij5PeyhAvVx4S4cXfM3b6DQtcSdTQ3lCwCH4s1lr3hROlJfhcamXkZFc2oHrfVgcPXgJavVeDFSAG9aeWiJfB0qSlUdTQ3aqvkPGnfLVZa0pt9mbVcy0qSlq5raOIcyXInBlC5FNC5KIUPOdwbbQwcjWo0QEVWzXfI77Kw)QZ(ciwCiaWeRm)jy7egvcSdTQ3lCwCH4MTsZr9SIUPOfVgcxoctLTu0nfDqKo5wL4mZ2ch)K8AQZQLiyfeOAjIfB5imv2sr3u0bY883u9YXITCeMkBPOBk6WL)DYLtiWJKHOC4aWamKHmec]] )

end