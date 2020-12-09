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

    spec:RegisterPack( "Survival", 20201208, [[dKKifcqiOs9iakvxIqvAtcPprOsgfb4ueqRIqfVsumlcLBbqLDj4xqvgMqKJjuwgGYZGkX0aOQRbqABau8ncvX4eIQZrOsTocvL5riUhbTpavhKqvLwiH0dHkjteGsKlcqjQpcqjmscvv4KausReQyMqLu7eqwkHQQ8uGMkuvFLqvvnwakL9c5VKmysDyQwmsEmOjROlJAZk8zegTOYPLSAcvv0RfvnBrUnsTBL(TudhrhhGy5Q8CvnDkxhkBNa9DrPXleopawVquMVq1(jAume(iWPBmciGfjGfPyalsrEiM4gWdSibOiqdasgbs6W8obJaxNMrGGyNGLGEcbs6aKAFIWhb(n2bzeyoZiFXhE4ruwomQaSPX7lASKBvVWZhgEFrdXdbsHvjdW6IOqGt3yeqalsalsXawKI8qmXnGhyrcWJaDmlxFiqWIgl5w1lU68HHaZvZjVike4KFiceWUudIDcwc6jPw8dS14tIdGDPgWsmKPP4tQJCXKAGfjGfjeyQE7r4JaDY3q4JakgcFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThbc0Hw1lcCYULtbZ55pNgziGagcFeiVovINirrGo0QErGpFK8AQ3QLabcVY4RCeiUL6zBHNpsEn1B1seScMVwcPoQuB(rWwWkAwzTAwSudCPw8GaHaatSY8JGThbumKHacxq4JaDOv9IahjhaEQ(CTHa51Ps8ejkYqab4r4JaDOv9Iap(71TAju(DDweiVovINirrgciafHpc0Hw1lcmBLMQNSUYEeiVovINirrgciadcFeOdTQxeiS7BwRB8u5)7yjdbYRtL4jsuKHas8GWhb6qR6fbMVsj1NRneiVovINirrgcOihHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fbos(MVwc1BxLNrgciXncFeOdTQxeOROXUjFQEOGxN9rG86ujEIefziGIfje(iqEDQeprIIaHxz8vocCGLsQJH58JGvwrZsTisnbCk1XJl1JgI9sDgPg6VPoMGxPwePE0qSpq7ri1rLAbi1lhHPYwkQMMkiyNCRsSuhvQNTfE(i51uVvlrWky(AjK6Os9STWZhjVM6TAjchpo(Z5ujwQJhxQxoctLTuunnvGmhFnDVSuhvQXTutHngb6Ej6(z1a7aiGrk1rL6rdXEPoJud93uhtWRulIupAi2hO9iKAaNu7qR6nKVsjfSPP9DgG(BQJj4vQfhPgxKAbk1XJl1wrZkRvZILArK6yrcb6qR6fbMTsZrDSIQPPqgcOyXq4Ja51Ps8ejkceELXx5iqhALGSIxMU4xQbUuhtQJk14wQpSLh9rWHdGKN)npLNVxb7D0y7Swc1BxLN)adiyfjjprGo0QErGq)eKrgcOyadHpcKxNkXtKOiq4vgFLJaDOvcYkEz6IFPg4sDmPoQuJBP(WwE0hbhoasE(38uE(EfS3rJTZAjuVDvE(dmGGvKK8uQJk1WUtZo7gYwP5Oowr10uHbwkPogMZpcwzfnl1axQFsoLuMFeS9sDuPwasnmNFe8RgNdTQxpj1axQbwaqL64XL6zBHp35KlNuunnvWky(AjKAbIaDOv9IaPWmyo(aaziGIHli8rG86ujEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EeiqhAvViW3yoPSZjrgcOyaEe(iqEDQeprIIaDOv9IaP7LO7NvuLXiq4vgFLJaPWgJaDVeD)SAGDaeWiL6Osnf2yeO7LO7NvdSdGWX0ETVulIupAi2l14j1cqQDOv9gO7LO7NvuLXby)Mud4KAO)M6ycELAbk1IJutaNsDuPg3snf2yeYwPP6jRRSpCmTx7l1XJl1uyJrGUxIUFwnWoacht71(sDuPE5imv2sr10ubYC8109YiqiaWeRm)iy7rafdziGIbOi8rG86ujEIefb6qR6fbMVsjfSPP9DIaHxz8vocCGLsQJH58JGvwrZsTisnbCk1rL6rdXEPoJud93uhtWRulIupAi2hO9iqGqaGjwz(rW2JakgYqafdWGWhbYRtL4jsueOdTQxe45KwFQ3UkpJaHxz8vocKcBmcwrQ6HYYXQNK9l8MdZl1cLACrQJhxQNTf(CNtUCsr10ubRG5RLabcbaMyL5hbBpcOyidbumXdcFeiVovINirrGWRm(khboBl85oNC5KIQPPcwbZxlbc0Hw1lcKUxIUFwrvgJmeqXICe(iqEDQeprIIaDOv9IaF(i51uVvlbceELXx5iWJhh)5CQel1rLAZpc2cwrZkRvZILAGl1IheieayIvMFeS9iGIHmeqXe3i8rG86ujEIefbcVY4RCe4YryQSLIQPPcFUZjxoj1rL6rdXEPg4sTdTQ3aDVeD)SIQmoa73KAXrQbMuhvQNTfE(i51uVvlr4yAV2xQbUudOsT4i1eWjc0Hw1lcmBLMJ6yfvttHmeqalsi8rGo0QErGWCE(ZPFeiVovINirrgciGfdHpcKxNkXtKOiqhAvViW8vkPGnnTVtei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7rGaHaatSY8JGThbumKHacyadHpcKxNkXtKOiq4vgFLJapSLh9rWHdGKN)npLNVxb7D0y7Swc1BxLN)adiyfjjprGo0QErGzR0CuhROAAkKHacy4ccFeiVovINirrGo0QErG09s09ZkQYyei8kJVYrGuyJrGUxIUFwnWoacyKsD84s9OHyVuNrQDOv9gYxPKc200(odq)n1Xe8k1axQhne7d0EesnGtQJbOsD84s9STWN7CYLtkQMMkyfmFTesD84snf2yeYwPP6jRRSpCmTx7JaHaatSY8JGThbumKHacyaEe(iqEDQeprIIaDOv9IapN06t92v5zeieayIvMFeS9iGIHmeqadqr4Ja51Ps8ejkceELXx5iWLJWuzlfvttfeStUvjwQJk1Z2cpFK8AQ3QLiyfmFTesD84s9YryQSLIQPPcK54RP7LL64XL6LJWuzlfvttf(CNtUCsQJk1JgI9snWLAansiqhAvViWSvAoQJvunnfYqgcK8yytt5gcFeqXq4JaDOv9IaFmA6EvKSHa51Ps8ejkYqabme(iqEDQeprIIaHxz8voc8WwE0hbh(gln6JGvmnfFFGbeSIKKNiqhAvViqZpLDojYqaHli8rGo0QErGVXCszNtIa51Ps8ejkYqgcCYdhlzi8rafdHpc0Hw1lcKglYISeJa51Ps8ejkYqabme(iqhAvViqSNvLX0pcKxNkXtKOidbeUGWhbYRtL4jsuei8kJVYrGo0kbzfVmDXVulIuJlsDuPg3sT5jETGNiZ5kYJNU1xGxNkXtPoQuJBP28eVwiBLMJ6yvTdSV6nWRtL4jc0Hw1lce6PKYHw1RkvVHat1BQ1PzeivtImeqaEe(iqEDQeprIIaHxz8voc0HwjiR4LPl(LArKACrQJk1MN41cEImNRipE6wFbEDQepL6OsnULAZt8AHSvAoQJv1oW(Q3aVovINiqhAvViqONskhAvVQu9gcmvVPwNMrGojvtImeqakcFeiVovINirrGWRm(khb6qReKv8Y0f)sTisnUi1rLAZt8AbprMZvKhpDRVaVovINsDuP28eVwiBLMJ6yvTdSV6nWRtL4jc0Hw1lce6PKYHw1RkvVHat1BQ1PzeOt(gYqabyq4Ja51Ps8ejkceELXx5iqhALGSIxMU4xQfrQXfPoQuJBP28eVwWtK5Cf5Xt36lWRtL4PuhvQnpXRfYwP5Oowv7a7REd86ujEIaDOv9IaHEkPCOv9Qs1BiWu9MADAgb(gYqajEq4Ja51Ps8ejkceELXx5iqhALGSIxMU4xQbUudmeOdTQxei0tjLdTQxvQEdbMQ3uRtZiqyIDbzKHakYr4JaDOv9Ia9d6lRS(oEneiVovINirrgYqGWe7cYi8rafdHpcKxNkXtKOiqhAvViWNpsEn1B1sGaHxz8voc08eVwihaZZFfvzCGxNkXtPoQutHngbbls(ELG820HJP9AFPoQutHngbbls(ELG820HJP9AFPwePMaorGqaGjwz(rW2JakgYqabme(iqhAvViWSvAQEY6k7rG86ujEIefziGWfe(iqhAvViWJ)EDRwcLFxNfbYRtL4jsuKHacWJWhbYRtL4jsuei8kJVYrGdSusDmmNFeSYkAwQfrQjGteOdTQxey2knh1XkQMMcziGaue(iqhAvViqyop)50pcKxNkXtKOidbeGbHpcKxNkXtKOiq4vgFLJaNTf(CNtUCsr10ubRG5RLqQJk1cqQNTfQ14B9KIkX8SwIWBomVulIudmPoECPE2w4ZDo5YjfvttfoM2R9LArKAc4uQfic0Hw1lcKcZG54daKHas8GWhbYRtL4jsuei8kJVYrGZ2cFUZjxoPOAAQGvW81sGaDOv9IaH(jiJmeqrocFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThbc0Hw1lcCYULtbZ55pNgziGe3i8rGo0QErGWUVzTUXtL)VJLmeiVovINirrgcOyrcHpcKxNkXtKOiq4vgFLJaH58JGF14COv96jPg4snWcaQuhvQHDNMD2nKTsZrDSIQPPcdSusDmmNFeSYkAwQbUu)KCkPm)iy7LA8KAGHaDOv9IaPWmyo(aaziGIfdHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fbos(MVwc1BxLNrgcOyadHpcKxNkXtKOiq4vgFLJaHDNMD2nKTsZrDSIQPPcdSusDmmNFeSYkAwQbUu)KCkPm)iy7LA8KAGj1rLAZt8AbprMZvKhpDRVaVovINiqhAvViqOFcYidbumCbHpcKxNkXtKOiqhAvViW8vkPGnnTVtei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7ri1rL6bwkPogMZpcwzfnl1Ii1eWPuhvQfGuFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtPoQud7on7SByCmhz1sOSZjdht71(sDuPg2DA2z3G5NYoNmCmTx7l1XJl14wQpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyabRij5PulqeieayIvMFeS9iGIHmeqXa8i8rG86ujEIefbcVY4RCeiUL6zBHSvAoQJvunnvWky(AjqGo0QErGzR0CuhROAAkKHakgGIWhbYRtL4jsuei8kJVYrGcqQXTuVCeMkBPOAAQWN7CYLtsD84snULAZt8AHSvAoQJv1oW(Q3aVovINsTaL6OsnS70SZUHSvAoQJvunnvyGLsQJH58JGvwrZsnWL6NKtjL5hbBVuJNudmeOdTQxeifMbZXhaidbumadcFeiVovINirrGWRm(khbc7on7SBiBLMJ6yfvttfgyPK6yyo)iyLv0SudCP(j5usz(rW2l14j1adb6qR6fbc9tqgziGIjEq4JaDOv9IaZxPK6Z1gcKxNkXtKOidbuSihHpc0Hw1lcCKCa4P6Z1gcKxNkXtKOidbumXncFeOdTQxeOROXUjFQEOGxN9rG86ujEIefziGawKq4JaDOv9IaFJ5KYoNebYRtL4jsuKHacyXq4Ja51Ps8ejkc0Hw1lc85JKxt9wTeiq4vgFLJapEC8NZPsSuhvQnpXRfYbW88xrvgh41Ps8uQJk1MFeSfSIMvwRMfl1axQJCeieayIvMFeS9iGIHmeqadyi8rGo0QErGq)eKrG86ujEIefziGagUGWhbYRtL4jsueOdTQxey(kLuWMM23jceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9iK6OsTaK6dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqWkssEk1rLAy3PzNDdJJ5iRwcLDoz4yAV2xQJk1WUtZo7gm)u25KHJP9AFPoECPg3s9HT8OpcoS8)1sK1paELDojzTekNK0p3W(adiyfjjpLAbIaHaatSY8JGThbumKHacyaEe(iqEDQeprIIaDOv9IaF(i51uVvlbceELXx5iWJhh)5CQeJaHaatSY8JGThbumKHacyakcFeiVovINirrGo0QErG09s09ZkQYyeieayIvMFeS9iGIHmeqadWGWhbYRtL4jsueOdTQxe45KwFQ3UkpJaHaatSY8JGThbumKHme4Bi8rafdHpc0Hw1lcCKCa4P6Z1gcKxNkXtKOidbeWq4JaDOv9IaZwPP6jRRShbYRtL4jsuKHacxq4JaDOv9Iap(71TAju(DDweiVovINirrgciapcFeiVovINirrGo0QErGpFK8AQ3QLabcVY4RCeif2yeeSi57vcYBthWiL6Osnf2yeeSi57vcYBthoM2R9LArKAc4uQJhxQXTuBfmFTeiqiaWeRm)iy7rafdziGaue(iqEDQeprIIaHxz8vocC0qSxQZi1q)n1Xe8k1Ii1JgI9bApceOdTQxe4KDlNcMZZFonYqabyq4Ja51Ps8ejkc0Hw1lc8CsRp1BxLNrGWRm(khbsHngbRiv9qz5y1tY(fEZH5LAHsnUGaHaatSY8JGThbumKHas8GWhb6qR6fbc7(M16gpv()owYqG86ujEIefziGICe(iqhAvViW8vkP(CTHa51Ps8ejkYqajUr4Ja51Ps8ejkceELXx5iWbwkPogMZpcwzfnl1Ii1eWPuhvQhne7L6msn0FtDmbVsTis9OHyFG2JqQJhxQfGuVCeMkBPOAAQGGDYTkXsDuPE2w45JKxt9wTebRG5RLqQJk1Z2cpFK8AQ3QLiC844pNtLyPoECPE5imv2sr10ubYC8109YsDuPE0qSxQZi1q)n1Xe8k1Ii1JgI9bApcPgWj1o0QEd5RusbBAAFNbO)M6ycELAXrQXfPoQuJBPMcBmc09s09ZQb2bq4yAV2xQfic0Hw1lcmBLMJ6yfvttHmeqXIecFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThbc0Hw1lc8nMtk7CsKHakwme(iqEDQeprIIaHxz8vocC0qSxQZi1q)n1Xe8k1Ii1JgI9bApceOdTQxe4i5B(AjuVDvEgziGIbme(iqEDQeprIIaDOv9IaZxPKc200(orGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThHuhvQfGuFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtPoQud7on7SByCmhz1sOSZjdht71(sDuPg2DA2z3G5NYoNmCmTx7l1XJl14wQpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyabRij5PulqeieayIvMFeS9iGIHmeqXWfe(iqEDQeprIIaHxz8voc0HwjiR4LPl(LAGl1XK6OsnUL6dB5rFeC4ai55FZt557vWEhn2oRLq92v55pWacwrsYteOdTQxei0pbzKHakgGhHpcKxNkXtKOiq4vgFLJaDOvcYkEz6IFPg4sDmPoQuJBP(WwE0hbhoasE(38uE(EfS3rJTZAjuVDvE(dmGGvKK8uQJk1WUtZo7gYwP5Oowr10uHbwkPogMZpcwzfnl1axQFsoLuMFeS9sDuPwasnmNFe8RgNdTQxpj1axQbwaqL64XL6zBHp35KlNuunnvWky(AjKAbIaDOv9IaPWmyo(aaziGIbOi8rGo0QErGUIg7M8P6HcED2hbYRtL4jsuKHakgGbHpcKxNkXtKOiqhAvViq6Ej6(zfvzmceELXx5iWzBHp35KlNuunnvWky(AjK64XLAkSXiq3lr3pRgyhaH3CyEPwOudOiqiaWeRm)iy7rafdziGIjEq4Ja51Ps8ejkc0Hw1lc85JKxt9wTeiq4vgFLJapEC8NZPsSuhpUutHngbbls(ELG820bmseieayIvMFeS9iGIHmeqXICe(iqEDQeprIIaHxz8vocC5imv2sr10uHp35KlNK6Os9STWZhjVM6TAjcht71(snWLAavQfhPMaoL64XL6dB5rFeC4ai55FZt557vWEhn2oRLq92v55pWacwrsYteOdTQxey2knh1XkQMMcziGIjUr4JaDOv9IaH588Nt)iqEDQeprIImeqalsi8rG86ujEIefb6qR6fbs3lr3pROkJrGWRm(khbsHngb6Ej6(z1a7aiGrk1XJl1JgI9sDgP2Hw1BiFLskytt77ma93uhtWRudCPE0qSpq7ri1aoPogGk1XJl1Z2cFUZjxoPOAAQGvW81sGaHaatSY8JGThbumKHacyXq4Ja51Ps8ejkc0Hw1lc8CsRp1BxLNrGqaGjwz(rW2JakgYqabmGHWhbYRtL4jsuei8kJVYrGlhHPYwkQMMkiyNCRsSuhvQNTfE(i51uVvlrWky(AjK64XL6LJWuzlfvttfiZXxt3ll1XJl1lhHPYwkQMMk85oNC5ec0Hw1lcmBLMJ6yfvttHmKHaHZhHpcOyi8rG86ujEIefbcVY4RCeO5jETGXh9R6HIxcNGP51c86ujEk1rL6rdXEPwePE0qSpq7rGaDOv9IaZ5hz3lYqabme(iqEDQeprIIaHxz8voce2DA2z3aS7BwRB8u5)7yjlCmTx7l1axQXLiHaDOv9IaPsDpvdSdaKHacxq4Ja51Ps8ejkceELXx5iqy3PzNDdWUVzTUXtL)VJLSWX0ETVudCPgxIec0Hw1lc0xi)25jf0tjKHacWJWhbYRtL4jsuei8kJVYrGWUtZo7gGDFZADJNk)FhlzHJP9AFPg4snUejeOdTQxe4OoMk19eziGaue(iqhAvViWurKZEL4NytcAEneiVovINirrgciadcFeiVovINirrGWRm(khbc7on7SBiFLskytt77mmWsj1XWC(rWkROzPg4snbCIaDOv9IaPCcvpu2vW8pYqajEq4Ja51Ps8ejkceELXx5iqy3PzNDdWUVzTUXtL)VJLSWX0ETVudCPgWejPoECP2kAwzTAwSulIuhdxqGo0QErGu898LVwcKHakYr4JaDOv9IaPXISilXiqEDQeprIImeqIBe(iqEDQeprIIaHxz8voc08JGTGv0SYA1SyPwePgWejPoECPMcBmcWUVzTUXtL)VJLSagjc0Hw1lcKSTQxKHakwKq4Ja51Ps8ejkceELXx5iWdB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqWkssEk1rL6rdXEPoJud93uhtWRulIupAi2hO9iqGo0QErGVXCszNtImeqXIHWhbYRtL4jsuei8kJVYrGh2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGGvKK8uQJk1JgI9sDgPg6VPoMGxPwePE0qSpq7rGaDOv9IahhZrwTek7CsKHakgWq4Ja51Ps8ejkceELXx5iWdB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqWkssEk1rL6rdXEPoJud93uhtWRulIupAi2hO9iK64XL6rdXEPoJud93uhtWRulIupAi2hO9iK6Os9HT8Opco8nwA0hbRyAk((adiyfjjpL6OsT5NYoNmCmTx7l1Ii1eWPuhvQHDNMD2nms(XHJP9AFPwePMaoL6OsTaKAhALGSIxMU4xQbUuhtQJhxQDOvcYkEz6IFPwOuhtQJk1wrZkRvZILAGl1aQulosnbCk1ceb6qR6fbA(PSZjrgcOy4ccFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThHuhvQn)u25KbmsPoQuFylp6JGdFJLg9rWkMMIVpWacwrsYtPoQuBfnRSwnlwQbUud4LAXrQjGteOdTQxe4i5hJmeqXa8i8rG86ujEIefbcVY4RCeOdTsqwXltx8l1cL6ysDuP28JGTGv0SYA1SyPwePE0qSxQXtQfGu7qR6nq3lr3pROkJdW(nPgWj1q)n1Xe8k1cuQfhPMaorGo0QErG5Rus95AdziGIbOi8rG86ujEIefbcVY4RCeOdTsqwXltx8l1cL6ysDuP28JGTGv0SYA1SyPwePE0qSxQXtQfGu7qR6nq3lr3pROkJdW(nPgWj1q)n1Xe8k1cuQfhPMaorGo0QErG09s09ZkQYyKHakgGbHpcKxNkXtKOiq4vgFLJaDOvcYkEz6IFPwOuhtQJk1MFeSfSIMvwRMfl1Ii1JgI9snEsTaKAhAvVb6Ej6(zfvzCa2Vj1aoPg6VPoMGxPwGsT4i1eWjc0Hw1lc8CsRp1BxLNrgcOyIhe(iqEDQeprIIaHxz8voc08JGTWSEZxil1axOudyqGo0QErG(tYqt1dLLJvStKyKHakwKJWhbYRtL4jsuei8kJVYrGNxtfliVwWNZpuRudCPwChjPoQupAi2l1Ii1JgI9bApcPgWj1adqL64XLAbi1o0kbzfVmDXVudCPoMuhvQXTuBEIxlqv38v9qrEmabEDQepL64XLAhALGSIxMU4xQbUudmPwGsDuPwasnf2yeOsyNQhkZt9(bmsPoQutHngbQe2P6HY8uVF4yAV2xQbUuJlsT4i1eWPuhpUuJBPMcBmcujSt1dL5PE)agPulqeOdTQxe4OHyppvEKXxzSIIDAKHakM4gHpcKxNkXtKOiq4vgFLJafGulaP(8AQyb51c(C(HJP9AFPg4sT4ossD84snUL6ZRPIfKxl4Z5h4iQ3EPwGsD84sTaKAhALGSIxMU4xQbUuhtQJk14wQnpXRfOQB(QEOipgGaVovINsD84sTdTsqwXltx8l1axQbMulqPwGsDuPE0qSxQfrQhne7d0EeiqhAvViqQu3tvpuwowXltdaYqabSiHWhbYRtL4jsuei8kJVYrGcqQfGuFEnvSG8AbFo)WX0ETVudCPgWejPoECPg3s951uXcYRf858dCe1BVulqPoECPwasTdTsqwXltx8l1axQJj1rLACl1MN41cu1nFvpuKhdqGxNkXtPoECP2HwjiR4LPl(LAGl1atQfOulqPoQupAi2l1Ii1JgI9bApceOdTQxeij2vdaQLqrL83qgciGfdHpc0Hw1lcKaZVz5RQhkpY4RTCiqEDQeprIImeqadyi8rGo0QErGxrsMyvTQN0HmcKxNkXtKOidbeWWfe(iqEDQeprIIaHxz8vocCGLsQJH58JGvwrZsTisDmPwCKAc4eb6qR6fbc7fYRDUXt1i50mYqabmapcFeiVovINirrGWRm(khbsHngHJH5t8)QrFqoGrIaDOv9IaTCScBPASDQg9bzKHacyakcFeOdTQxey2(stb5Avh)96lKrG86ujEIefziGagGbHpcKxNkXtKOiq4vgFLJan)iylKJ9KLlqcnPg4sDKhjPoECP28JGTqo2twUaj0KArek1alssD84sT5hbBbROzL1ksOPawKKAGl14sKqGo0QErGh7K1sOgjNMFKHacyIhe(iqEDQeprIIaHxz8vocC0qSxQfrQDOv9gO7LO7NvuLXby)MuhvQPWgJaS7BwRB8u5)7yjlGrIaDOv9IaPz6(aq1dvcdwt18yN(rgYqGunjcFeqXq4Ja51Ps8ejkc0Hw1lc85JKxt9wTeiq4vgFLJaPWgJGGfjFVsqEB6WX0ETVuhvQPWgJGGfjFVsqEB6WX0ETVulIutaNiqiaWeRm)iy7rafdziGagcFeiVovINirrGo0QErG5RusbBAAFNiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2JqQJk1uyJry5)RLiRFa8k7CsYAjuojPFUH9bmseieayIvMFeS9iGIHmeq4ccFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThHuhvQXTuBfmFTesDuPEGLsQJH58JGvwrZsTisnbCIaDOv9IaZwP5Oowr10uidbeGhHpc0Hw1lcmBLMQNSUYEeiVovINirrgciafHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fbos(MVwc1BxLNrgciadcFeOdTQxe4i5aWt1NRneiVovINirrgciXdcFeiVovINirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aThbc0Hw1lcCYULtbZ55pNgziGICe(iqhAvViW8vkP(CTHa51Ps8ejkYqajUr4Ja51Ps8ejkc0Hw1lc8CsRp1BxLNrGWRm(khbsHngby33Sw34PY)3XswaJuQJk1uyJra29nR1nEQ8)DSKfoM2R9LArK6ybavQfhPMaorGqaGjwz(rW2JakgYqaflsi8rG86ujEIefb6qR6fbs3lr3pROkJrGWRm(khbsHngby33Sw34PY)3XswaJuQJk1uyJra29nR1nEQ8)DSKfoM2R9LArK6ybavQfhPMaorGqaGjwz(rW2JakgYqaflgcFeOdTQxeOROXUjFQEOGxN9rG86ujEIefziGIbme(iqEDQeprIIaDOv9IapN06t92v5zei8kJVYrGuyJrWksvpuwow9KSFH3CyEPwOuJliqiaWeRm)iy7rafdziGIHli8rG86ujEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EesDuPg3sTvW81si1rLAbi1dSusDmmNFeSYkAwQfrQjGtPoECPg3s9STq2knh1XkQMMkyfmFTesDuPMcBmc09s09ZQb2bq4yAV2xQbUupWsj1XWC(rWkROzPgWj1XKAXrQjGtPoECPg3s9STq2knh1XkQMMkyfmFTesDuPg3snf2yeO7LO7NvdSdGWX0ETVulqPoECP2kAwzTAwSulIuhlYL6OsnUL6zBHSvAoQJvunnvWky(AjqGo0QErGzR0CuhROAAkKHakgGhHpcKxNkXtKOiqhAvViW8vkPGnnTVtei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7ri1rLACl1h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGGvKK8uQJhxQhne7L6msn0FtDmbVsTis9OHyFG2JqQJk1cqQfGuFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtPoQuJBP28eVw4nMtk7CYaVovINsDuPg2DA2z3W4yoYQLqzNtgoM2R9L6OsnS70SZUbZpLDoz4yAV2xQfOuhpUulaP(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbeSIKKNsDuP28eVw4nMtk7CYaVovINsDuPg2DA2z3W4yoYQLqzNtgoM2R9L6OsnS70SZUbZpLDoz4yAV2xQJk1WUtZo7gEJ5KYoNmCmTx7l1cuQfOuhpUupAi2l1Ii1o0QEd09s09ZkQY4aSFdbcbaMyL5hbBpcOyidbumafHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fb(gZjLDojYqafdWGWhbYRtL4jsueOdTQxe4ZhjVM6TAjqGWRm(khbsHngbbls(ELG820bmsPoQuF844pNtLyPoECPE2w45JKxt9wTeHJhh)5CQel1rLACl1uyJra29nR1nEQ8)DSKfWirGqaGjwz(rW2JakgYqaft8GWhb6qR6fbE83RB1sO876SiqEDQeprIImeqXICe(iqEDQeprIIaHxz8voce3snf2yeGDFZADJNk)FhlzbmseOdTQxeiS7BwRB8u5)7yjdziGIjUr4Ja51Ps8ejkceELXx5iqkSXiq3lr3pRgyhabmsPoECPE0qSxQZi1o0QEd5RusbBAAFNbO)M6ycELAGl1JgI9bApcPoECPMcBmcWUVzTUXtL)VJLSagjc0Hw1lcKUxIUFwrvgJmeqalsi8rG86ujEIefb6qR6fbEoP1N6TRYZiqiaWeRm)iy7rafdziGawme(iqEDQeprIIaHxz8vocC2wiBLMJ6yfvttfoEC8NZPsmc0Hw1lcmBLMJ6yfvttHmeqadyi8rG86ujEIefb6qR6fb(8rYRPERwcei8kJVYrGuyJrqWIKVxjiVnDaJebcbaMyL5hbBpcOyidziqNKQjr4JakgcFeOdTQxey2knvpzDL9iqEDQeprIImeqadHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fbos(MVwc1BxLNrgciCbHpc0Hw1lcCKCa4P6Z1gcKxNkXtKOidbeGhHpcKxNkXtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2Jab6qR6fboz3YPG588NtJmeqakcFeOdTQxey(kLuFU2qG86ujEIefziGami8rG86ujEIefb6qR6fbs3lr3pROkJrGWRm(khbsHngby33Sw34PY)3XswaJuQJk1uyJra29nR1nEQ8)DSKfoM2R9LArK6ybavQfhPMaorGqaGjwz(rW2JakgYqajEq4Ja51Ps8ejkc0Hw1lc8CsRp1BxLNrGWRm(khbsHngby33Sw34PY)3XswaJuQJk1uyJra29nR1nEQ8)DSKfoM2R9LArK6ybavQfhPMaorGqaGjwz(rW2JakgYqaf5i8rG86ujEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EeiqhAvViWrY381sOE7Q8mYqajUr4Ja51Ps8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9iK6OsnULARG5RLqQJk1cqQhyPK6yyo)iyLv0SulIutaNsD84snUL6zBHSvAoQJvunnvWky(AjK6Osnf2yeO7LO7NvdSdGWX0ETVudCPEGLsQJH58JGvwrZsnGtQJj1IJutaNsD84snUL6zBHSvAoQJvunnvWky(AjK6OsnULAkSXiq3lr3pRgyhaHJP9AFPwGsD84sTv0SYA1SyPwePowKl1rLACl1Z2czR0CuhROAAQGvW81sGaDOv9IaZwP5Oowr10uidbuSiHWhbYRtL4jsuei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7rGaDOv9IaFJ5KYoNeziGIfdHpcKxNkXtKOiqhAvViq6Ej6(zfvzmceELXx5iqkSXiq3lr3pRgyhabmsPoQutHngb6Ej6(z1a7aiCmTx7l1Ii1JgI9snEsTaKAhAvVb6Ej6(zfvzCa2Vj1aoPg6VPoMGxPwGsT4i1eWjcecamXkZpc2EeqXqgcOyadHpcKxNkXtKOiqhAvViW8vkPGnnTVtei8kJVYrGdSusDmmNFeSYkAwQfrQjGtPoQupAi2l1zKAO)M6ycELArK6rdX(aThHuhvQfGuFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtPoQud7on7SByCmhz1sOSZjdht71(sDuPg2DA2z3G5NYoNmCmTx7l1XJl14wQpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyabRij5PulqeieayIvMFeS9iGIHmeqXWfe(iqEDQeprIIaDOv9IaF(i51uVvlbceELXx5iWzBHNpsEn1B1seoEC8NZPsSuhvQXTutHngb6Ej6(z1a7aiCmTx7JaHaatSY8JGThbumKHakgGhHpcKxNkXtKOiqhAvViW8vkPGnnTVtei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7ri1rLAbi1uyJrGUxIUFwnWoacV5W8sTisnGk1XJl1JgI9sTisTdTQ3aDVeD)SIQmoa73KAbk1rLAbi1h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGGvKK8uQJk1WUtZo7gghZrwTek7CYWX0ETVuhvQHDNMD2ny(PSZjdht71(sD84snUL6dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqWkssEk1cebcbaMyL5hbBpcOyidbumafHpc0Hw1lc0v0y3KpvpuWRZ(iqEDQeprIImeqXami8rGo0QErGh)96wTek)UolcKxNkXtKOidbumXdcFeOdTQxeiS7BwRB8u5)7yjdbYRtL4jsuKHakwKJWhbYRtL4jsueOdTQxeiDVeD)SIQmgbcVY4RCeif2yeO7LO7NvdSdGagPuhpUupAi2l1zKAhAvVH8vkPGnnTVZa0FtDmbVsnWL6rdX(aThHuhpUutHngby33Sw34PY)3XswaJebcbaMyL5hbBpcOyidbumXncFeiVovINirrGo0QErGNtA9PE7Q8mcecamXkZpc2EeqXqgciGfje(iqEDQeprIIaHxz8voce3sTvW81sGaDOv9IaZwP5Oowr10uidzidbkiFF1lciGfjGfPyalsageyw)2AjEeO4FXVI)acWkqawi(KAPg)CSux0K9zs9OpPwC5KVjUK6JbeS64Pu)nnl1oM10UXtPgMZxc(dsCW11YsDmaV4tQXv9kiFgpLAWIgxj1paR5ri1IxP2APgxJ5s9SeS(QxPUj5ZT(KAbGNaLAbelcbgK4iXr8V4xXFabyfialeFsTuJFowQlAY(mPE0NulUGj2fKfxs9XacwD8uQ)MMLAhZAA34PudZ5lb)bjo46AzPowKeFsnUQxb5Z4Pudw04kP(bynpcPw8k1wl14AmxQNLG1x9k1njFU1Nula8eOulGyriWGehCDTSuhdyIpPgx1RG8z8uQblACLu)aSMhHulELARLACnMl1ZsW6REL6MKp36tQfaEcuQfqSieyqIdUUwwQJbOIpPgx1RG8z8uQblACLu)aSMhHulELARLACnMl1ZsW6REL6MKp36tQfaEcuQfqSieyqIdUUwwQJbyeFsnUQxb5Z4Pudw04kP(bynpcPw8k1wl14AmxQNLG1x9k1njFU1Nula8eOulGyriWGehjoI)f)k(diaRabyH4tQLA8ZXsDrt2Nj1J(KAXfC(IlP(yabRoEk1FtZsTJznTB8uQH58LG)GehCDTSuhdWl(KACvVcYNXtPgSOXvs9dWAEesT4vQTwQX1yUuplbRV6vQBs(CRpPwa4jqPwaXIqGbjo46AzPogGk(KACvVcYNXtPgSOXvs9dWAEesT4vQTwQX1yUuplbRV6vQBs(CRpPwa4jqPwaXIqGbjo46AzPogGr8j14QEfKpJNsnyrJRK6hG18iKAXRuBTuJRXCPEwcwF1Ru3K85wFsTaWtGsTaIfHadsCW11YsDSix8j14QEfKpJNsT4Y8eVwaWM4sQTwQfxMN41ca2c86ujEkUKAbelcbgK4GRRLL6yIBXNuJR6vq(mEk1IlZt8AbaBIlP2APwCzEIxlaylWRtL4P4sQfqSieyqIdUUwwQbwKeFsnUQxb5Z4PulUmpXRfaSjUKARLAXL5jETaGTaVovINIlPwaXIqGbjosCe)l(v8hqawbcWcXNul14NJL6IMSptQh9j1IlNKQjfxs9XacwD8uQ)MMLAhZAA34PudZ5lb)bjo46AzPowmXNuJR6vq(mEk1GfnUsQFawZJqQfVsT1snUgZL6zjy9vVsDtYNB9j1capbk1ciwecmiXrIdGvAY(mEk1rUu7qR6vQt1BFqIdc8jziciGbOakcK86rLyeiGDPge7eSe0tsT4hyRXNeha7snGLyittXNuh5Ij1alsalssCK44qR69dKhdBAk3YieVhJMUxfjBsCCOv9(bYJHnnLBzeIN5NYoNuSAi8WwE0hbh(gln6JGvmnfFFGbeSIKKNsCCOv9(bYJHnnLBzeI3BmNu25KsCK44qR69ZiepASilYsSehhAvVFgH4H9SQmM(L44qR69ZiepONskhAvVQu9MyRtZcPAsXQHqhALGSIxMU4xeCjkUnpXRf8ezoxrE80T(c86ujEgf3MN41czR0CuhRQDG9vVbEDQepL44qR69ZiepONskhAvVQu9MyRtZcDsQMuSAi0HwjiR4LPl(fbxIAEIxl4jYCUI84PB9f41Ps8mkUnpXRfYwP5Oowv7a7REd86ujEkXXHw17NriEqpLuo0QEvP6nXwNMf6KVjwne6qReKv8Y0f)IGlrnpXRf8ezoxrE80T(c86ujEg18eVwiBLMJ6yvTdSV6nWRtL4PehhAvVFgH4b9us5qR6vLQ3eBDAw4BIvdHo0kbzfVmDXVi4suCBEIxl4jYCUI84PB9f41Ps8mQ5jETq2knh1XQAhyF1BGxNkXtjoo0QE)mcXd6PKYHw1RkvVj260SqyIDbzXQHqhALGSIxMU4h4atIJdTQ3pJq88d6lRS(oEnjosCCOv9(bNKQjfMTst1twxzVehhAvVFWjPAYmcXBK8nFTeQ3UkplwneoAi2Nb6VPoMGxrgne7d0EesCCOv9(bNKQjZieVrYbGNQpxBsCCOv9(bNKQjZieVj7wofmNN)CAXQHWrdX(mq)n1Xe8kYOHyFG2JqIJdTQ3p4KunzgH4LVsj1NRnjoo0QE)Gts1KzeIhDVeD)SIQmwmiaWeRm)iy7fgtSAiKcBmcWUVzTUXtL)VJLSagzukSXia7(M16gpv()owYcht71(IelaOIdbCkXXHw17hCsQMmJq8oN06t92v5zXGaatSY8JGTxymXQHqkSXia7(M16gpv()owYcyKrPWgJaS7BwRB8u5)7yjlCmTx7lsSaGkoeWPehhAvVFWjPAYmcXBK8nFTeQ3UkplwneoAi2Nb6VPoMGxrgne7d0EesCCOv9(bNKQjZieVSvAoQJvunnLy1q4OHyFgO)M6ycEfz0qSpq7ref3wbZxlrubmWsj1XWC(rWkROzriGZ4XX9STq2knh1XkQMMkyfmFTerPWgJaDVeD)SAGDaeoM2R9b(alLuhdZ5hbRSIMbCXehc4mECCpBlKTsZrDSIQPPcwbZxlruCtHngb6Ej6(z1a7aiCmTx7lW4XTIMvwRMflsSipkUNTfYwP5Oowr10ubRG5RLqIJdTQ3p4KunzgH49gZjLDoPy1q4OHyFgO)M6ycEfz0qSpq7riXXHw17hCsQMmJq8O7LO7NvuLXIbbaMyL5hbBVWyIvdHuyJrGUxIUFwnWoacyKrPWgJaDVeD)SAGDaeoM2R9fz0qSx8kahAvVb6Ej6(zfvzCa2Vb4G(BQJj4vGIdbCkXXHw17hCsQMmJq8YxPKc200(ofdcamXkZpc2EHXeRgchyPK6yyo)iyLv0SieWz0rdX(mq)n1Xe8kYOHyFG2JiQaoSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyabRij5zuy3PzNDdJJ5iRwcLDoz4yAV2pkS70SZUbZpLDoz4yAV2pECCFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtbkXXHw17hCsQMmJq8E(i51uVvlHyqaGjwz(rW2lmMy1q4STWZhjVM6TAjchpo(Z5ujokUPWgJaDVeD)SAGDaeoM2R9L44qR69dojvtMriE5RusbBAAFNIbbaMyL5hbBVWyIvdHJgI9zG(BQJj4vKrdX(aThrubqHngb6Ej6(z1a7ai8MdZlcGgp(OHyVio0QEd09s09ZkQY4aSFtGrfWHT8OpcoS8)1sK1paELDojzTekNK0p3W(adiyfjjpJc7on7SByCmhz1sOSZjdht71(rHDNMD2ny(PSZjdht71(XJJ7dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqWkssEkqjoo0QE)Gts1KzeINROXUjFQEOGxN9L44qR69dojvtMriEh)96wTek)UoRehhAvVFWjPAYmcXd29nR1nEQ8)DSKjXXHw17hCsQMmJq8O7LO7NvuLXIbbaMyL5hbBVWyIvdHuyJrGUxIUFwnWoacyKXJpAi2NXHw1BiFLskytt77ma93uhtWlWhne7d0EeXJtHngby33Sw34PY)3XswaJuIJdTQ3p4KunzgH4DoP1N6TRYZIbbaMyL5hbBVWysCCOv9(bNKQjZieVSvAoQJvunnLy1qiUTcMVwcjosCCOv9(bN8nHt2TCkyop)50IvdHJgI9zG(BQJj4vKrdX(aThHehhAvVFWjFlJq8E(i51uVvlHyqaGjwz(rW2lmMy1qiUNTfE(i51uVvlrWky(AjIA(rWwWkAwzTAwmWfpsCCOv9(bN8TmcXBKCa4P6Z1MehhAvVFWjFlJq8o(71TAju(DDwjoo0QE)Gt(wgH4LTst1twxzVehhAvVFWjFlJq8GDFZADJNk)FhlzsCCOv9(bN8TmcXlFLsQpxBsCCOv9(bN8TmcXBK8nFTeQ3UkplwneoAi2Nb6VPoMGxrgne7d0EesCCOv9(bN8TmcXZv0y3KpvpuWRZ(sCCOv9(bN8TmcXlBLMJ6yfvttjwneoWsj1XWC(rWkROzriGZ4Xhne7Za93uhtWRiJgI9bApIOcy5imv2sr10ubb7KBvIJoBl88rYRPERwIGvW81seD2w45JKxt9wTeHJhh)5CQehp(YryQSLIQPPcK54RP7LJIBkSXiq3lr3pRgyhabmYOJgI9zG(BQJj4vKrdX(aThbGZHw1BiFLskytt77ma93uhtWR4GlcmECROzL1QzXIelssCCOv9(bN8TmcXd6NGSy1qOdTsqwXltx8d8yrX9HT8OpcoCaK88V5P889kyVJgBN1sOE7Q88hyabRij5PehhAvVFWjFlJq8OWmyo(aqSAi0HwjiR4LPl(bESO4(WwE0hbhoasE(38uE(EfS3rJTZAjuVDvE(dmGGvKK8mkS70SZUHSvAoQJvunnvyGLsQJH58JGvwrZa)j5usz(rW2hvaWC(rWVACo0QE9eWbwaqJhF2w4ZDo5YjfvttfScMVwcbkXXHw17hCY3YieV3yoPSZjfRgchne7Za93uhtWRiJgI9bApcjoo0QE)Gt(wgH4r3lr3pROkJfdcamXkZpc2EHXeRgcPWgJaDVeD)SAGDaeWiJsHngb6Ej6(z1a7aiCmTx7lYOHyV4vao0QEd09s09ZkQY4aSFdWb93uhtWRafhc4mkUPWgJq2knvpzDL9HJP9A)4XPWgJaDVeD)SAGDaeoM2R9JUCeMkBPOAAQazo(A6Ezjoo0QE)Gt(wgH4LVsjfSPP9DkgeayIvMFeS9cJjwneoWsj1XWC(rWkROzriGZOJgI9zG(BQJj4vKrdX(aThHehhAvVFWjFlJq8oN06t92v5zXGaatSY8JGTxymXQHqkSXiyfPQhklhREs2VWBomVqCjE8zBHp35KlNuunnvWky(AjK44qR69do5BzeIhDVeD)SIQmwSAiC2w4ZDo5YjfvttfScMVwcjoo0QE)Gt(wgH498rYRPERwcXGaatSY8JGTxymXQHWJhh)5CQeh18JGTGv0SYA1SyGlEK44qR69do5BzeIx2knh1XkQMMsSAiC5imv2sr10uHp35KlNIoAi2dChAvVb6Ej6(zfvzCa2Vjoal6STWZhjVM6TAjcht71(ahqfhc4uIJdTQ3p4KVLriEWCE(ZPFjoo0QE)Gt(wgH4LVsjfSPP9DkgeayIvMFeS9cJjwneoAi2Nb6VPoMGxrgne7d0EesCCOv9(bN8TmcXlBLMJ6yfvttjwneEylp6JGdhajp)BEkpFVc27OX2zTeQ3Ukp)bgqWkssEkXXHw17hCY3Yiep6Ej6(zfvzSyqaGjwz(rW2lmMy1qif2yeO7LO7NvdSdGagz84JgI9zCOv9gYxPKc200(odq)n1Xe8c8rdX(aThbGlgGgp(STWN7CYLtkQMMkyfmFTeXJtHngHSvAQEY6k7dht71(sCCOv9(bN8TmcX7CsRp1BxLNfdcamXkZpc2EHXK44qR69do5BzeIx2knh1XkQMMsSAiC5imv2sr10ubb7KBvIJoBl88rYRPERwIGvW81sep(YryQSLIQPPcK54RP7LJhF5imv2sr10uHp35KlNIoAi2dCanssCK44qR69dunPWNpsEn1B1sigeayIvMFeS9cJjwnesHngbbls(ELG820HJP9A)OuyJrqWIKVxjiVnD4yAV2xec4uIJdTQ3pq1KzeIx(kLuWMM23PyqaGjwz(rW2lmMy1q4OHyFgO)M6ycEfz0qSpq7reLcBmcl)FTez9dGxzNtswlHYjj9ZnSpGrkXXHw17hOAYmcXlBLMJ6yfvttjwneoAi2Nb6VPoMGxrgne7d0EerXTvW81seDGLsQJH58JGvwrZIqaNsCCOv9(bQMmJq8YwPP6jRRSxIJdTQ3pq1KzeI3i5B(AjuVDvEwSAiC0qSpd0FtDmbVImAi2hO9iK44qR69dunzgH4nsoa8u95AtIJdTQ3pq1KzeI3KDlNcMZZFoTy1q4OHyFgO)M6ycEfz0qSpq7riXXHw17hOAYmcXlFLsQpxBsCCOv9(bQMmJq8oN06t92v5zXGaatSY8JGTxymXQHqkSXia7(M16gpv()owYcyKrPWgJaS7BwRB8u5)7yjlCmTx7lsSaGkoeWPehhAvVFGQjZiep6Ej6(zfvzSyqaGjwz(rW2lmMy1qif2yeGDFZADJNk)FhlzbmYOuyJra29nR1nEQ8)DSKfoM2R9fjwaqfhc4uIJdTQ3pq1KzeINROXUjFQEOGxN9L44qR69dunzgH4DoP1N6TRYZIbbaMyL5hbBVWyIvdHuyJrWksvpuwow9KSFH3CyEH4IehhAvVFGQjZieVSvAoQJvunnLy1q4OHyFgO)M6ycEfz0qSpq7ref3wbZxlrubmWsj1XWC(rWkROzriGZ4XX9STq2knh1XkQMMkyfmFTerPWgJaDVeD)SAGDaeoM2R9b(alLuhdZ5hbRSIMbCXehc4mECCpBlKTsZrDSIQPPcwbZxlruCtHngb6Ej6(z1a7aiCmTx7lW4XTIMvwRMflsSipkUNTfYwP5Oowr10ubRG5RLqIJdTQ3pq1KzeIx(kLuWMM23PyqaGjwz(rW2lmMy1q4OHyFgO)M6ycEfz0qSpq7ref3h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGGvKK8mE8rdX(mq)n1Xe8kYOHyFG2JiQaeWHT8OpcoS8)1sK1paELDojzTekNK0p3W(adiyfjjpJIBZt8AH3yoPSZjd86ujEgf2DA2z3W4yoYQLqzNtgoM2R9Jc7on7SBW8tzNtgoM2R9fy84c4WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbeSIKKNrnpXRfEJ5KYoNmWRtL4zuy3PzNDdJJ5iRwcLDoz4yAV2pkS70SZUbZpLDoz4yAV2pkS70SZUH3yoPSZjdht71(cuGXJpAi2lIdTQ3aDVeD)SIQmoa73K44qR69dunzgH49gZjLDoPy1q4OHyFgO)M6ycEfz0qSpq7riXXHw17hOAYmcX75JKxt9wTeIbbaMyL5hbBVWyIvdHuyJrqWIKVxjiVnDaJm6XJJ)CovIJhF2w45JKxt9wTeHJhh)5CQehf3uyJra29nR1nEQ8)DSKfWiL44qR69dunzgH4D83RB1sO876SsCCOv9(bQMmJq8GDFZADJNk)FhlzIvdH4McBmcWUVzTUXtL)VJLSagPehhAvVFGQjZiep6Ej6(zfvzSy1qif2yeO7LO7NvdSdGagz84JgI9zCOv9gYxPKc200(odq)n1Xe8c8rdX(aThr84uyJra29nR1nEQ8)DSKfWiL44qR69dunzgH4DoP1N6TRYZIbbaMyL5hbBVWysCCOv9(bQMmJq8YwP5Oowr10uIvdHZ2czR0CuhROAAQWXJJ)CovIL44qR69dunzgH498rYRPERwcXGaatSY8JGTxymXQHqkSXiiyrY3ReK3MoGrkXrIJdTQ3paNVWC(r29kwneAEIxly8r)QEO4LWjyAETaVovINrhne7fz0qSpq7riXXHw17hGZpJq8OsDpvdSdaXQHqy3PzNDdWUVzTUXtL)VJLSWX0ETpWXLijXXHw17hGZpJq88fYVDEsb9usSAie2DA2z3aS7BwRB8u5)7yjlCmTx7dCCjssCCOv9(b48ZieVrDmvQ7Py1qiS70SZUby33Sw34PY)3Xsw4yAV2h44sKK44qR69dW5NriEPIiN9kXpXMe08AsCCOv9(b48ZiepkNq1dLDfm)lwnec7on7SBiFLskytt77mmWsj1XWC(rWkROzGtaNsCCOv9(b48Ziepk(E(YxlHy1qiS70SZUby33Sw34PY)3Xsw4yAV2h4aMifpUv0SYA1SyrIHlsCCOv9(b48ZiepASilYsSehhAvVFao)mcXJSTQxXQHqZpc2cwrZkRvZIfbWeP4XPWgJaS7BwRB8u5)7yjlGrkXXHw17hGZpJq8EJ5KYoNuSAi8WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbeSIKKNrhne7Za93uhtWRiJgI9bApcjoo0QE)aC(zeI34yoYQLqzNtkwneEylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYZOJgI9zG(BQJj4vKrdX(aThHehhAvVFao)mcXZ8tzNtkwneEylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYZOJgI9zG(BQJj4vKrdX(aThr84JgI9zG(BQJj4vKrdX(aThr0dB5rFeC4BS0OpcwX0u89bgqWkssEg18tzNtgoM2R9fHaoJc7on7SByK8Jdht71(IqaNrfGdTsqwXltx8d8yXJ7qReKv8Y0f)cJf1kAwzTAwmWbuXHaofOehhAvVFao)mcXBK8JfRgchne7Za93uhtWRiJgI9bApIOMFk7CYagz0dB5rFeC4BS0OpcwX0u89bgqWkssEg1kAwzTAwmWb8IdbCkXXHw17hGZpJq8YxPK6Z1My1qOdTsqwXltx8lmwuZpc2cwrZkRvZIfz0qSx8kahAvVb6Ej6(zfvzCa2Vb4G(BQJj4vGIdbCkXXHw17hGZpJq8O7LO7NvuLXIvdHo0kbzfVmDXVWyrn)iylyfnRSwnlwKrdXEXRaCOv9gO7LO7NvuLXby)gGd6VPoMGxbkoeWPehhAvVFao)mcX7CsRp1BxLNfRgcDOvcYkEz6IFHXIA(rWwWkAwzTAwSiJgI9Ixb4qR6nq3lr3pROkJdW(nah0FtDmbVcuCiGtjoo0QE)aC(zeIN)Km0u9qz5yf7ejwSAi08JGTWSEZxidCHagjoa2LAal)pVq(L44qR69dW5NriEJgI98u5rgFLXkk2PfRgcpVMkwqETGpNFOwGlUJu0rdXErgne7d0EeaoGbOXJlahALGSIxMU4h4XIIBZt8AbQ6MVQhkYJbiEChALGSIxMU4h4atGrfaf2yeOsyNQhkZt9(bmYOuyJrGkHDQEOmp17hoM2R9boUioeWz844McBmcujSt1dL5PE)agPaL44qR69dW5NriEuPUNQEOSCSIxMgaXQHqbiGZRPIfKxl4Z5hoM2R9bU4osXJJ7ZRPIfKxl4Z5h4iQ3EbgpUaCOvcYkEz6IFGhlkUnpXRfOQB(QEOipgG4XDOvcYkEz6IFGdmbkWOJgI9ImAi2hO9iK44qR69dW5NriEKyxnaOwcfvYFtSAiuac48AQyb51c(C(HJP9AFGdyIu844(8AQyb51c(C(boI6TxGXJlahALGSIxMU4h4XIIBZt8AbQ6MVQhkYJbiEChALGSIxMU4h4atGcm6OHyViJgI9bApcjoo0QE)aC(zeIhbMFZYxvpuEKXxB5K44qR69dW5NriExrsMyvTQN0HSehhAvVFao)mcXd2lKx7CJNQrYPzXQHWbwkPogMZpcwzfnlsmXHaoL44qR69dW5NriEwowHTun2ovJ(GSy1qif2yeogMpX)Rg9b5agPehhAvVFao)mcXlBFPPGCTQJ)E9fYsCCOv9(b48ZieVJDYAjuJKtZVy1qO5hbBHCSNSCbsOb8ipsXJB(rWwih7jlxGeAIieyrkECZpc2cwrZkRvKqtbSibCCjssCCOv9(b48ZiepAMUpau9qLWG1unp2PFXQHWrdXErCOv9gO7LO7NvuLXby)wukSXia7(M16gpv()owYcyKsCK44qR69dWe7cYcF(i51uVvlHyqaGjwz(rW2lmMy1qO5jETqoaMN)kQY4aVovINrPWgJGGfjFVsqEB6WX0ETFukSXiiyrY3ReK3MoCmTx7lcbCkXXHw17hGj2fKZieVSvAQEY6k7L44qR69dWe7cYzeI3XFVUvlHYVRZkXXHw17hGj2fKZieVSvAoQJvunnLy1q4alLuhdZ5hbRSIMfHaoL44qR69dWe7cYzeIhmNN)C6xIJdTQ3patSliNriEuygmhFaiwneoBl85oNC5KIQPPcwbZxlrubmBluRX36jfvI5zTeH3CyEraw84Z2cFUZjxoPOAAQWX0ETVieWPaL44qR69dWe7cYzeIh0pbzXQHWzBHp35KlNuunnvWky(AjK44qR69dWe7cYzeI3KDlNcMZZFoTy1q4OHyFgO)M6ycEfz0qSpq7riXXHw17hGj2fKZiepy33Sw34PY)3XsMehhAvVFaMyxqoJq8OWmyo(aqSAieMZpc(vJZHw1RNaoWcaAuy3PzNDdzR0CuhROAAQWalLuhdZ5hbRSIMb(tYPKY8JGTx8cmjoo0QE)amXUGCgH4ns(MVwc1BxLNfRgchne7Za93uhtWRiJgI9bApcjoo0QE)amXUGCgH4b9tqwSAie2DA2z3q2knh1XkQMMkmWsj1XWC(rWkROzG)KCkPm)iy7fValQ5jETGNiZ5kYJNU1xGxNkXtjoo0QE)amXUGCgH4LVsjfSPP9DkgeayIvMFeS9cJjwneoAi2Nb6VPoMGxrgne7d0EerhyPK6yyo)iyLv0SieWzubCylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYZOWUtZo7gghZrwTek7CYWX0ETFuy3PzNDdMFk7CYWX0ETF844(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbeSIKKNcuIJdTQ3patSliNriEzR0CuhROAAkXQHqCpBlKTsZrDSIQPPcwbZxlHehhAvVFaMyxqoJq8OWmyo(aqSAiua4E5imv2sr10uHp35KlNIhh3MN41czR0CuhRQDG9vVbEDQepfyuy3PzNDdzR0CuhROAAQWalLuhdZ5hbRSIMb(tYPKY8JGTx8cmjoo0QE)amXUGCgH4b9tqwSAie2DA2z3q2knh1XkQMMkmWsj1XWC(rWkROzG)KCkPm)iy7fVatIJdTQ3patSliNriE5Rus95AtIJdTQ3patSliNriEJKdapvFU2K44qR69dWe7cYzeINROXUjFQEOGxN9L44qR69dWe7cYzeI3BmNu25KsCCOv9(byIDb5mcX75JKxt9wTeIbbaMyL5hbBVWyIvdHhpo(Z5ujoQ5jETqoaMN)kQY4aVovINrn)iylyfnRSwnlg4rUehhAvVFaMyxqoJq8G(jilXXHw17hGj2fKZieV8vkPGnnTVtXGaatSY8JGTxymXQHWrdX(mq)n1Xe8kYOHyFG2JiQaoSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyabRij5zuy3PzNDdJJ5iRwcLDoz4yAV2pkS70SZUbZpLDoz4yAV2pECCFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWacwrsYtbkXXHw17hGj2fKZieVNpsEn1B1sigeayIvMFeS9cJjwneE844pNtLyjoo0QE)amXUGCgH4r3lr3pROkJfdcamXkZpc2EHXK44qR69dWe7cYzeI35KwFQ3UkplgeayIvMFeS9cJjXrIJdTQ3p8MWrYbGNQpxBsCCOv9(H3YieVSvAQEY6k7L44qR69dVLriEh)96wTek)UoRehhAvVF4TmcX75JKxt9wTeIbbaMyL5hbBVWyIvdHuyJrqWIKVxjiVnDaJmkf2yeeSi57vcYBthoM2R9fHaoJhh3wbZxlHehhAvVF4TmcXBYULtbZ55pNwSAiC0qSpd0FtDmbVImAi2hO9iK44qR69dVLriENtA9PE7Q8SyqaGjwz(rW2lmMy1qif2yeSIu1dLLJvpj7x4nhMxiUiXXHw17hElJq8GDFZADJNk)FhlzsCCOv9(H3YieV8vkP(CTjXXHw17hElJq8YwP5Oowr10uIvdHdSusDmmNFeSYkAwec4m6OHyFgO)M6ycEfz0qSpq7repUawoctLTuunnvqWo5wL4OZ2cpFK8AQ3QLiyfmFTerNTfE(i51uVvlr44XXFoNkXXJVCeMkBPOAAQazo(A6E5OJgI9zG(BQJj4vKrdX(aThbGZHw1BiFLskytt77ma93uhtWR4GlrXnf2yeO7LO7NvdSdGWX0ETVaL44qR69dVLriEVXCszNtkwneoAi2Nb6VPoMGxrgne7d0EesCCOv9(H3YieVrY381sOE7Q8Sy1q4OHyFgO)M6ycEfz0qSpq7riXXHw17hElJq8YxPKc200(ofdcamXkZpc2EHXeRgchne7Za93uhtWRiJgI9bApIOc4WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbeSIKKNrHDNMD2nmoMJSAju25KHJP9A)OWUtZo7gm)u25KHJP9A)4XX9HT8OpcoS8)1sK1paELDojzTekNK0p3W(adiyfjjpfOehhAvVF4TmcXd6NGSy1qOdTsqwXltx8d8yrX9HT8OpcoCaK88V5P889kyVJgBN1sOE7Q88hyabRij5PehhAvVF4TmcXJcZG54daXQHqhALGSIxMU4h4XII7dB5rFeC4ai55FZt557vWEhn2oRLq92v55pWacwrsYZOWUtZo7gYwP5Oowr10uHbwkPogMZpcwzfnd8NKtjL5hbBFubaZ5hb)QX5qR61tahybanE8zBHp35KlNuunnvWky(AjeOehhAvVF4TmcXZv0y3KpvpuWRZ(sCCOv9(H3Yiep6Ej6(zfvzSyqaGjwz(rW2lmMy1q4STWN7CYLtkQMMkyfmFTeXJtHngb6Ej6(z1a7ai8MdZleqL44qR69dVLriEpFK8AQ3QLqmiaWeRm)iy7fgtSAi84XXFoNkXXJtHngbbls(ELG820bmsjoo0QE)WBzeIx2knh1XkQMMsSAiC5imv2sr10uHp35KlNIoBl88rYRPERwIWX0ETpWbuXHaoJh)WwE0hbhoasE(38uE(EfS3rJTZAjuVDvE(dmGGvKK8uIJdTQ3p8wgH4bZ55pN(L44qR69dVLriE09s09ZkQYyXGaatSY8JGTxymXQHqkSXiq3lr3pRgyhabmY4Xhne7Z4qR6nKVsjfSPP9DgG(BQJj4f4JgI9bApcaxmanE8zBHp35KlNuunnvWky(AjK44qR69dVLriENtA9PE7Q8SyqaGjwz(rW2lmMehhAvVF4TmcXlBLMJ6yfvttjwneUCeMkBPOAAQGGDYTkXrNTfE(i51uVvlrWky(AjIhF5imv2sr10ubYC8109YXJVCeMkBPOAAQWN7CYLtidziea]] )

end