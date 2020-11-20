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

    spec:RegisterPack( "Survival", 20201120, [[dKKdhbqijrpIuPYLivQAtskFIuPKrHkQtHkYQqvcVsKAwKkUfPsrTlQ8liyyQeDmujldvQNrQKPHQu5AssABOkPVHQenovc6CQeyDssO5bHUhQQ9jj1brvkvlevXdrvQ6IOkLyJOkLKpIQukJKuPGtsQuQvkPAMssWnrvkP2PkPLsQuKNQIPcr9vsLcTxq)LObtvhMYIrXJHAYI6YiBwIplIrlsoTuRwsIETkvZMKBJs7wPFRy4KYXvj0Yv1ZbMUW1H02vP8DuHXljCEiY6rvkMpPQ9tyixqKHNSfe8k3xY9LCXf3x6U8cV8c5QQWtGKgbpAg(ULqWZASe8Cq)B9ntbpAgsQXYqKHhWG(ycEsfHgOkIacjDKcLXHhweanlQYIEw8BLabqZIraEyqBvOBVqg4jBbbVY9LCFjxCX9LUlVWlVqUGhdnsnp8CAwuLf9S8(3kb8KQZzAHmWtMay4r3j8h0)wFZucVUb0nOxux3j8xNBeld9cp3xQJWZ9LCFPOUOUUt4pPS8WHY2mq4FsrgGeETVNVdKeEoZrhPeEElaaTycWjh8OAqaGidpzQyOQaIm8kxqKHhdh9SWdlkVH3Oi4HwJrrzipWaELBiYWJHJEw4bfqYoiwa8qRXOOmKhyaVQliYWdTgJIYqEGhdh9SWd2ukPHJEwPQbb8OAqixJLGhCgad4vEhez4HwJrrzipWd(7G(2Ghdh9nsslX2eq4ru45gEmC0ZcpytPKgo6zLQgeWJQbHCnwcEabmGxRkez4HwJrrzipWd(7G(2Ghdh9nsslX2eq4Rw45cEmC0ZcpytPKgo6zLQgeWJQbHCnwcEWkYUrWaELxHidpgo6zHh7X2sYy(N2aEO1yuugYdmGx5LqKHhdh9SWdJLiNIm(gFhap0Amkkd5bgWaEWkYUrqKHx5cIm8qRXOOmKh4b)DqFBWtykAdxqplqofjTjwcXsB4O1yuuw4Rj8LbJceEef(YGrbowRc4XWrpl8KYETzwyaVYnez4XWrpl8WrRYsGw)DaGhAngfLH8ad4vDbrgEO1yuugYd8G)oOVn45rxQmFc5adQQmFcjjwg6bo6IOTMgLf(AcFyVmEtZ9eR1lq4ru4tWzHVMWJNrLhowxrzp5EI16fi8ik8j4m8y4ONfEc7LXBAWaEL3brgEO1yuugYd8G)oOVn45rxQmFc5adQQmFcjjwg6bo6IOTMgLf(AcFyVmEtZHQbpgo6zHNIYEcgWRvfIm8y4ONfEEcmRf9MiT)hoGhAngfLH8ad4vEfIm8qRXOOmKh4b)DqFBWtbvPKpHtzFcjJMLeEef(eCgEmC0ZcpC0QCPFsYmSmWaELxcrgEmC0Zcp4u293ybWdTgJIYqEGb86fcrgEO1yuugYd8G)oOVn4jpHdK6nTLusMHLXfn(EVjcFnHNZcFEcxVb9RPKmkIY9M4aHHVl8ik8Cl861l85jCGuVPTKsYmSmUNyTEbcpIcFcol8CcEmC0ZcpmObof9ibd41laIm8qRXOOmKh4b)DqFBWtEchi1BAlPKmdlJlA89EtGhdh9SWd2(BemGx56siYWdTgJIYqEGh83b9TbpLbJce(0cp2aH8PeAfEef(YGrbowRc4XWrpl8KjlsjXPS7VXcd4vU4cIm8y4ONfEWZ85ETGYsdamuvap0Amkkd5bgWRCXnez4HwJrrzipWd(7G(2GhCk7tiGS8go6znLWxTWZTRQcFnHhpJkpCSooAvU0pjzgwgxbvPKpHtzFcjJMLe(QfEGgPuYW(ekacpccp3WJHJEw4HbnWPOhjyaVYLUGidp0Amkkd5bEWFh03g8ugmkq4tl8ydeYNsOv4ru4ldgf4yTkGhdh9SWtrz79EtKG477emGx5I3brgEO1yuugYd8y4ONfEU3kLepSS2MHh83b9TbpLbJce(0cp2aH8PeAfEef(YGrbowRcHVMWxqvk5t4u2NqYOzjHhrHpbNHhmsyfjd7tOaaVYfmGx5QQqKHhAngfLH8ap4Vd6BdEQu4Zt44Ov5s)KKzyzCrJV3Bc8y4ONfE4Ov5s)KKzyzGb8kx8kez4HwJrrzipWd(7G(2Ghol8vk8lvri5OLmdlJdK6nTLucVE9cFLcFykAdhhTkx6NK9wqb9SoAngfLfEoj81eE8mQ8WX64Ov5s)KKzyzCfuLs(eoL9jKmAws4Rw4bAKsjd7tOai8ii8Cdpgo6zHhg0aNIEKGb8kx8siYWdTgJIYqEGh83b9Tbp4zu5HJ1XrRYL(jjZWY4kOkL8jCk7tiz0SKWxTWd0iLsg2Nqbq4rq45gEmC0Zcpy7VrWaELRleIm8y4ONfEU3kLeKAc4HwJrrzipWaELRlaIm8y4ONfEkkdjklbPMaEO1yuugYdmGx5(siYWJHJEw4XKSOFME5uK4F4aap0Amkkd5bgWRCZfez4HwJrrzipWd(7G(2GNkf(hDPY8jKBjaO3eoShjGmEttR3ePPPzVfOahDr0wtJYcVE9cFzWOaHpTWJnqiFkHwHpTWZDvfEef(YGrbowRc4XWrpl8acIuY4nnyaVYn3qKHhAngfLH8apgo6zHha9A0gsq0Bc8G)oOVn45PYtGugJIe(AcFykAdxkKYVbKmDqoAngfLHhmsyfjd7tOaaVYfmGx5wxqKHhdh9SWd2(Be8qRXOOmKhyaVYnVdIm8qRXOOmKh4XWrpl8CVvkjEyzTndp4Vd6BdEkdgfi8PfESbc5tj0k8ik8LbJcCSwfWdgjSIKH9juaGx5cgWRCxviYWdTgJIYqEGhdh9SWdGEnAdji6nbEWFh03g88u5jqkJrrcFnHNZcFLcFykAdht)zGCksTNqYrRXOOSWRxVWxPWZGwko8mFUxlOS0aadvfounHNtcFnHNZcFLc)JUuz(eY9iPS7GWu3PhiXZwg0n3BIeeFFNao6IOTMgLfE96f(LQiKC0sMHLXDBuw0ks41Rx4dtrB4yqdCk6rYrRXOOSWZjHxVEHNbTuC3An6bYB0oSoun4bJewrYW(ekaWRCbd4vU5viYWdTgJIYqEGhdh9SWd7SjZaijthe8G)oOVn4jtmOLItzbTHuBAWSYERsch9Soqy47cF1c)fapyKWksg2NqbaELlyaVYnVeIm8qRXOOmKh4XWrpl88MwmVeeFFNGh83b9TbpzIbTuCklOnKAtdMv2Bvs4ON1bcdFx4Rw4Va4bJewrYW(ekaWRCbd4vUVqiYWdTgJIYqEGhdh9SWdGEnAdji6nbEWFh03g8uPWhMI2WX0FgiNIu7jKC0Amkkl81e(kf(Wu0gUBTg9a5nAhwhTgJIYcFnHVsH)rxQmFc5uwqBi1MgmRS3QKWX8ahDr0wtJYcFnHVsH)rxQmFc5EKu2DqyQ70dK4zld6M7nrcIVVtahDr0wtJYWdgjSIKH9juaGx5cgWRCFbqKHhAngfLH8apgo6zHh2ztMbqsMoi4bJewrYW(ekaWRCbd4vDDjez4HwJrrzipWJHJEw45nTyEji((obpyKWksg2NqbaELlyad4bNbqKHx5cIm8qRXOOmKh4b)DqFBWdEgvE4yD4z(CVwqzPbagQkCpXA9ce(QfEDDj8y4ONfEyuZKLf0hjyaVYnez4HwJrrzipWd(7G(2Gh8mQ8WX6WZ85ETGYsdamuv4EI16fi8vl866s4XWrpl8ylMaXBkj2ukyaVQliYWdTgJIYqEGh83b9Tbp4zu5HJ1HN5Z9AbLLgayOQW9eR1lq4Rw411LWJHJEw4P0pXOMjdd4vEhez4XWrpl8O6KubqwLO5ewAd4HwJrrzipWaETQqKHhAngfLH8ap4Vd6BdEWZOYdhRdpZN71cklnaWqvH7jwRxGWxTWZRxk861l8rZsYyK5MeEefEU0f8y4ONfEyOhq)9EtGb8kVcrgEO1yuugYd8G)oOVn4P0jPc5tSwVaHhrHNBEv41Rx4zqlfhEMp3RfuwAaGHQchQg8y4ONfE0MONfgWR8siYWdTgJIYqEGh83b9TbpH9ju4YniSftcF18fEEfEmC0ZcpgqJWHCkYifjjlrrWaE9cHidp0Amkkd5bEWFh03g88wNL0nAdNLZaxVcF1c)fCPWxt4ldgfi8ik8LbJcCSwfcVUzHN7Qk861l8Cw4nC03ijTeBtaHVAHNlHVMWxPWhMI2WX0FgiNIu7jKC0Amkkl861l8go6BKKwITjGWxTWZTWZjHVMWZzHNbTuCmk0xofzyQzbounHVMWZGwkogf6lNImm1Sa3tSwVaHVAHxxcpVq4tWzHxVEHVsHNbTuCmk0xofzyQzbounHNtWJHJEw4PmyuaLLgVH(oijdzSWaE9cGidp0Amkkd5bEWFh03g8WzHNZc)BDws3OnCwodCpXA9ce(Qf(l4sHxVEHVsH)TolPB0golNboQIgeaHNtcVE9cpNfEdh9nsslX2eq4Rw45s4Rj8vk8HPOnCm9NbYPi1EcjhTgJIYcVE9cVHJ(gjPLyBci8vl8Cl8Cs45KWxt4ldgfi8ik8LbJcCSwfWJHJEw4HrntwofzKIK0sSibd4vUUeIm8qRXOOmKh4b)DqFBWdNfEol8V1zjDJ2Wz5mW9eR1lq4Rw451lfE96f(kf(36SKUrB4SCg4OkAqaeEoj861l8Cw4nC03ijTeBtaHVAHNlHVMWxPWhMI2WX0FgiNIu7jKC0Amkkl861l8go6BKKwITjGWxTWZTWZjHNtcFnHVmyuGWJOWxgmkWXAvapgo6zHhn0Vli1BIKrzGagWRCXfez4XWrpl8KGAFUTvofPXBOFIuWdTgJIYqEGb8kxCdrgEmC0ZcpFRPPizVsGMHj4HwJrrzipWaELlDbrgEO1yuugYd8G)oOVn4PGQuYNWPSpHKrZscpIcpxcpVq4tWz4XWrpl8GNftB8wqzzrzSemGx5I3brgEO1yuugYd8G)oOVn4HbTuCpHVRiaqwMhtoun4XWrpl8ePij6YmOBwwMhtWaELRQcrgEmC0ZcpCmVkFJ6v(eywBXe8qRXOOmKhyaVYfVcrgEO1yuugYd8G)oOVn4jSpHcxkYurkNgoe(Qf(l8sHxVEHpSpHcxkYurkNgoeEe5l8CFPWRxVWh2NqHlAwsgJudhsUVu4Rw411LWJHJEw45jtR3ezrzSeagWRCXlHidp0Amkkd5bEWFh03g8qaaTyYXsSZJKCksfkUZY8tglWXAv58cFnH)PYtGugJIe(AcpdAP4U1A0dK3ODyDOAcFnHVsHhpJkpCSowIDEKKtrQqXDwMFYybUNyTEbWJHJEw4bqVgTHee9Mad4vUUqiYWdTgJIYqEGh83b9TbpeaqlMCSe78ijNIuHI7Sm)KXcCSwvoVWxt4Ru4XZOYdhRJLyNhj5uKkuCNL5NmwG7jwRxa8y4ONfEyNnzgajz6GGb8kxxaez4HwJrrzipWd(7G(2GhcaOftowIDEKKtrQqXDwMFYybowRkNx4Rj8fuLs(eoL9jKmAws4ru45YvvHNxi8j4SWxt4ldgfi8ik8go6zDSZMmdGKmDqo8acHVMWxPWJNrLhowhlXopsYPivO4olZpzSa3tSwVa4XWrpl8WrRYL(jjZWYad4vUVeIm8qRXOOmKh4b)DqFBWtzWOaHhrH3WrpRJD2KzaKKPdYHhqi81eEg0sXHN5Z9AbLLgayOQWHQbpgo6zHhwIDEKKtrQqXDwMFYybWagWdiGidVYfez4HwJrrzipWd(7G(2GNWu0gUGEwGCksAtSeIL2WrRXOOSWxt4ldgfi8ik8LbJcCSwfWJHJEw4jL9AZSWaELBiYWdTgJIYqEGh83b9TbpLbJce(0cp2aH8PeAfEef(YGrbowRcHVMWZGwkUO1KtrgPijqJS3bcdFx4ru41LWxt4Ru4dtrB4mLwktQ9u2I5D0Amkkdpgo6zHN7TsjXdlRTzyaVQliYWdTgJIYqEGh83b9Tbp5jCGuVPTKsYmSmUOX37nr4Rj8Cw4Zt46nOFnLKrruU3ehim8DHhrHNBHxVEHppHdK6nTLusMHLX9eR1lq4ru4tWzHNtcVE9cpdAP4yNnzgajlOpsounHVMWZGwko2ztMbqYc6JK7jwRxGWJOWxgmkq4rq411LcpVq4tWzHxVEHpmfTHJP)mqofP2ti5O1yuuw4Rj8mOLIdpZN71cklnaWqvHdvt4Rj8mOLIdpZN71cklnaWqvH7jwRxGWJOWNGZWJHJEw4HD2KzaKKPdcgWR8oiYWdTgJIYqEGh83b9Tbp5jCGuVPTKsYmSmUOX37nr4Rj8Cw4Zt46nOFnLKrruU3ehim8DHhrHNBHxVEHppHdK6nTLusMHLX9eR1lq4ru4tWzHNtcVE9cFykAdht)zGCksTNqYrRXOOSWxt4zqlfhEMp3RfuwAaGHQchQMWxt4zqlfhEMp3RfuwAaGHQc3tSwVaHhrHpbNHhdh9SWZBAX8sq89DcgWRvfIm8y4ONfE4OvzjqR)oaWdTgJIYqEGb8kVcrgEO1yuugYd8G)oOVn45rxQmFc5adQQmFcjjwg6bo6IOTMgLf(AcFyVmEtZ9eR1lq4ru4tWzHVMWJNrLhowxrzp5EI16fi8ik8j4m8y4ONfEc7LXBAWaELxcrgEO1yuugYd8G)oOVn45rxQmFc5adQQmFcjjwg6bo6IOTMgLf(AcFyVmEtZHQbpgo6zHNIYEcgWRxiez4XWrpl8GN5Z9AbLLgayOQaEO1yuugYdmGxVaiYWJHJEw45jWSw0BI0(F4aEO1yuugYdmGx56siYWJHJEw4POmKOSeKAc4HwJrrzipWaELlUGidp0Amkkd5bEWFh03g8ugmkq4tl8ydeYNsOv4ru4ldgf4yTkGhdh9SWtMSiLeNYU)glmGx5IBiYWJHJEw45ERusqQjGhAngfLH8ad4vU0fez4HwJrrzipWd(7G(2GNYGrbcFAHhBGq(ucTcpIcFzWOahRvb8y4ONfEkkBV3BIeeFFNGb8kx8oiYWdTgJIYqEGh83b9TbpLbJce(0cp2aH8PeAfEef(YGrbowRcHVMWZGwkUO1KtrgPijqJS3bcdFx4ru41LWxt4lOkL8jCk7tiz0SKWJOWZTWZle(eCgEmC0Zcp3BLsIhwwBZWaELRQcrgEmC0Zcp4u293ybWdTgJIYqEGb8kx8kez4XWrpl8ysw0ptVCks8pCaGhAngfLH8ad4vU4LqKHhAngfLH8ap4Vd6BdEwQIqYrlzgwg3TrzrRiHVMWNNWbOxJ2qcIEtCrJV3BIWxt4Zt4a0RrBibrVjUNkpbszmkcEmC0ZcpC0QCPFsYmSmWaELRleIm8qRXOOmKh4b)DqFBWZtLNaPmgfj81eEol8mOLIJD2KzaKSG(i5aHHVl8ik8vv41Rx4Ru4dtrB4yNnzgajz6GC0Amkkl8Cs4Rj8Cw4Ru4zqlfhEMp3RfuwAaGHQchQMWRxVWxPWhMI2WX0FgiNIu7jKC0Amkkl8Cs41Rx4zqlf3TwJEG8gTdRdvdEmC0Zcpa61OnKGO3eyaVY1fargEO1yuugYd8G)oOVn4zPkcjhTKzyzCGuVPTKs4Rj8LbJce(QfEE9sHxVEHFPkcjhTKzyzCAPOFyNLe(AcpNf(YGrbcFAHhBGq(ucTcFAH3WrpR7ERus8WYAB2HnqiFkHwHNxi86s4ru4ldgf4yTkeE96f(Wu0go2ztMbqsMoihTgJIYcFnHVsHNbTuCSZMmdGKf0hjhQMWZjHxVEHVsHppHJJwLl9tsMHLXfn(EVjcFnHVGQuYNWPSpHKrZscpIcFcodpgo6zHhoAvU0pjzgwgyaVY9LqKHhAngfLH8ap4Vd6BdEkdgfi8PfESbc5tj0k8ik8LbJcCSwfcFnHNbTuCrRjNImsrsGgzVdeg(UWJOWRl4XWrpl8CVvkjEyzTndd4vU5cIm8qRXOOmKh4b)DqFBWtLc)JUuz(eYTea0Bch2JeqgVPP1BI000S3cuGJUiARPrzHxVEHVmyuGWNw4XgiKpLqRWNw45UQcpIcFzWOahRvb8y4ONfEabrkz8MgmGx5MBiYWdTgJIYqEGh83b9Tbpp6sL5ti3saqVjCypsaz8MMwVjsttZElqbo6IOTMgLf(AcFzWOaHpTWJnqiFkHwHpTWZDvfEef(YGrbowRc4XWrpl8e2lJ30Gb8k36cIm8qRXOOmKh4b)DqFBWZJUuz(eYTea0Bch2JeqgVPP1BI000S3cuGJUiARPrzHVMWxgmkq4tl8ydeYNsOv4tl8CxvHhrHVmyuGJ1QaEmC0ZcpLNiEtVjY4nnyaVYnVdIm8qRXOOmKh4b)DqFBWddAP4yNnzgajlOpsounHxVEHVmyuGWNw4nC0Z6U3kLepSS2MDydeYNsOv4Rw4ldgf4yTkGhdh9SWd7SjZaijthemGx5UQqKHhAngfLH8ap4Vd6BdEQu4xQIqYrlzgwghi1BAlPeE96fEg0sXfTMCkYifjbAK9oqy47cF1cp3cVE9cFzWOaHpTWB4ON1DVvkjEyzTn7WgiKpLqRWxTWxgmkWXAvapgo6zHN30I5LG477emGx5MxHidp0Amkkd5bEWFh03g8WGwkUO1KtrgPijqJS3bcdFx4ru41f8y4ONfEU3kLepSS2MHb8k38siYWdTgJIYqEGh83b9Tbpvk85jCC0QCPFsYmSmUOX37nr4Rj8vk8HPOnCC0QCPFs2Bbf0Z6O1yuugEmC0ZcpC0QCPFsYmSmWagWJ2t4HLXciYWRCbrgEO1yuugYd8G)oOVn45rxQmFc5adQQmFcjjwg6bo6IOTMgLHhdh9SWtyVmEtdgWRCdrgEmC0ZcpGGiLmEtdEO1yuugYdmGx1fez4XWrpl8GN5Z9AbLLgayOQaEO1yuugYdmGbmGNB0d6zHx5(sUVKlU4(s4Hd73EtaWJUrE76MUQBFL3wvu4fEKtrcFZQnFi8L5fEDlqOBj8pDr0(PSWdgws4n0yyTGYcpoLTjeWjQxf6LeEDvffEE)S3OpOSWFAwEVWdqAdRcHx3l8Xi8vbut4Z9Tg0Zk8Jg9wmVWZze4KWZzUQGtorDrDDJ821nDv3(kVTQOWl8iNIe(MvB(q4lZl86wyfz3iDlH)PlI2pLfEWWscVHgdRfuw4XPSnHaor9QqVKWZf3vrHN3p7n6dkl8NML3l8aK2WQq419cFmcFva1e(CFRb9Sc)OrVfZl8Cgboj8CMRk4KtuVk0lj8CXRvrHN3p7n6dkl8NML3l8aK2WQq419cFmcFva1e(CFRb9Sc)OrVfZl8Cgboj8CMRk4KtuVk0lj8CXlRIcpVF2B0huw4pnlVx4biTHvHWR7f(ye(QaQj85(wd6zf(rJElMx45mcCs45mxvWjNOUOUUnR28bLf(Qk8go6zfEvdcGtuhEaAegEL7Qwv4r7NsRi4r3j8h0)wFZucVUb0nOxux3j8xNBeld9cp3xQJWZ9LCFPOUOUUt4pPS8WHY2mq4FsrgGeETVNVdKeEoZrhPeEElaaTycWjNOUOUHJEwGt7j8WYyrA(ie2lJ300Pl8F0LkZNqoWGQkZNqsILHEGJUiARPrzrDdh9SaN2t4HLXI08raeePKXBAI6go6zboTNWdlJfP5JaEMp3RfuwAaGHQcrDrDdh9SahodsZhbg1mzzb9rsNUWhpJkpCSo8mFUxlOS0aadvfUNyTEbvRRlf1nC0ZcC4minFeSftG4nLeBkLoDHpEgvE4yD4z(CVwqzPbagQkCpXA9cQwxxkQB4ONf4WzqA(iu6NyuZK1Pl8XZOYdhRdpZN71cklnaWqvH7jwRxq166srDdh9SahodsZhbvNKkaYQenNWsBiQB4ONf4WzqA(iWqpG(79MOtx4JNrLhowhEMp3RfuwAaGHQc3tSwVGQ51l1RpAwsgJm3eICPlrDdh9SahodsZhbTj6z1Pl8lDsQq(eR1larU5v96zqlfhEMp3RfuwAaGHQchQMOUHJEwGdNbP5JGb0iCiNImsrsYsuKoDHFyFcfUCdcBXu185vrDDNWZBbaOftarDdh9SahodsZhHYGrbuwA8g67GKmKXQtx4)wNL0nAdNLZaxVvFbxwRmyuaILbJcCSwf6M5UQ61Zzdh9nsslX2eOAUQvzykAdht)zGCksTNqYrRXOOSE9go6BKKwITjq1CZPACMbTuCmk0xofzyQzbouTAmOLIJrH(YPidtnlW9eR1lOADXlsWz96RKbTuCmk0xofzyQzbounojQB4ONf4WzqA(iWOMjlNImsrsAjwK0Pl85mNFRZs6gTHZYzG7jwRxq1xWL61x5BDws3OnCwodCufniaCsVEoB4OVrsAj2MavZvTkdtrB4y6pdKtrQ9esoAngfL1R3WrFJK0sSnbQMBoXPALbJcqSmyuGJ1Qqu3WrplWHZG08rqd97cs9Mizugi0Pl85mNFRZs6gTHZYzG7jwRxq186L61x5BDws3OnCwodCufniaCsVEoB4OVrsAj2MavZvTkdtrB4y6pdKtrQ9esoAngfL1R3WrFJK0sSnbQMBoXPALbJcqSmyuGJ1Qqu3WrplWHZG08rib1(CBRCksJ3q)ePe1nC0ZcC4minFe(wttrYELandtI6go6zboCgKMpc4zX0gVfuwwuglPtx4xqvk5t4u2NqYOzje5IxKGZI6go6zboCgKMpcrksIUmd6MLL5XKoDHpdAP4EcFxraGSmpMCOAI6go6zboCgKMpcCmVkFJ6v(eywBXKOUHJEwGdNbP5JWtMwVjYIYyjGoDHFyFcfUuKPIuonCu9fEPE9H9ju4srMks50WbI85(s96d7tOWfnljJrQHdj3xwTUUuux3j8kuCNfEERTQCEHN3QbJcYOSAcVwkdqI6go6zboCgKMpca61OnKGO3eD6cFcaOftowIDEKKtrQqXDwMFYybowRkNV2tLNaPmgfvJbTuC3An6bYB0oSouTAvINrLhowhlXopsYPivO4olZpzSa3tSwVarDdh9SahodsZhb2ztMbqsMoiD6cFcaOftowIDEKKtrQqXDwMFYybowRkNVwL4zu5HJ1XsSZJKCksfkUZY8tglW9eR1lqu3WrplWHZG08rGJwLl9tsMHLrNUWNaaAXKJLyNhj5uKkuCNL5NmwGJ1QY5Rvqvk5t4u2NqYOzje5YvvErcoxRmyuaIgo6zDSZMmdGKmDqo8aIAvINrLhowhlXopsYPivO4olZpzSa3tSwVarDdh9SahodsZhbwIDEKKtrQqXDwMFYyb60f(LbJcq0WrpRJD2KzaKKPdYHhquJbTuC4z(CVwqzPbagQkCOAI6I6go6zbP5JalkVH3OirDdh9SG08rafqYoiwGOUHJEwqA(iGnLsA4ONvQAqOZASeFCgiQB4ONfKMpcytPKgo6zLQge6SglXhe60f(go6BKKwITjaIClQB4ONfKMpcytPKgo6zLQge6SglXhRi7gPtx4B4OVrsAj2MavZLOUHJEwqA(iyp2wsgZ)0gI6go6zbP5JaJLiNIm(gFhiQlQB4ONf4arA(iKYETzwD6c)Wu0gUGEwGCksAtSeIL2WrRXOOCTYGrbiwgmkWXAviQB4ONf4arA(iCVvkjEyzTnRtx4xgmkin2aH8PeArSmyuGJ1QOgdAP4IwtofzKIKanYEhim8De1vTkdtrB4mLwktQ9u2I5D0AmkklQB4ONf4arA(iWoBYmasY0bPtx4NNWbs9M2skjZWY4IgFV3KACopHR3G(1usgfr5EtCGWW3rKB96Zt4aPEtBjLKzyzCpXA9cqmbN5KE9mOLIJD2KzaKSG(i5q1QXGwko2ztMbqYc6JK7jwRxaILbJc0966sErcoRxFykAdht)zGCksTNqYrRXOOCng0sXHN5Z9AbLLgayOQWHQvJbTuC4z(CVwqzPbagQkCpXA9cqmbNf1nC0ZcCGinFeEtlMxcIVVt60f(5jCGuVPTKsYmSmUOX37nPgNZt46nOFnLKrruU3ehim8De5wV(8eoqQ30wsjzgwg3tSwVaetWzoPxFykAdht)zGCksTNqYrRXOOCng0sXHN5Z9AbLLgayOQWHQvJbTuC4z(CVwqzPbagQkCpXA9cqmbNf1nC0ZcCGinFe4OvzjqR)oaI6go6zboqKMpcH9Y4nnD6c)hDPY8jKdmOQY8jKKyzOh4OlI2AAuUwyVmEtZ9eR1laXeCUgEgvE4yDfL9K7jwRxaIj4SOUHJEwGdeP5JqrzpPtx4)OlvMpHCGbvvMpHKeld9ahDr0wtJY1c7LXBAounrDdh9SahisZhb8mFUxlOS0aadvfI6go6zboqKMpcpbM1IEtK2)dhI6go6zboqKMpcfLHeLLGutiQB4ONf4arA(iKjlsjXPS7VXQtx4xgmkin2aH8PeArSmyuGJ1Qqu3WrplWbI08r4ERusqQje1nC0ZcCGinFekkBV3BIeeFFN0Pl8ldgfKgBGq(ucTiwgmkWXAviQB4ONf4arA(iCVvkjEyzTnRtx4xgmkin2aH8PeArSmyuGJ1QOgdAP4IwtofzKIKanYEhim8De1vTcQsjFcNY(esgnlHi38IeCwu3WrplWbI08raNYU)glqu3WrplWbI08rWKSOFME5uK4F4aiQB4ONf4arA(iWrRYL(jjZWYOtx4VufHKJwYmSmUBJYIwr1Yt4a0RrBibrVjUOX37nPwEchGEnAdji6nX9u5jqkJrrI6go6zboqKMpca61OnKGO3eD6c)NkpbszmkQgNzqlfh7SjZaizb9rYbcdFhXQQxFLHPOnCSZMmdGKmDqoAngfL5unoxjdAP4WZ85ETGYsdamuv4q10RVYWu0goM(Za5uKApHKJwJrrzoPxpdAP4U1A0dK3ODyDOAI6go6zboqKMpcC0QCPFsYmSm60f(lvri5OLmdlJdK6nTLu1kdgfunVEPE9lvri5OLmdlJtlf9d7Sunoxgmkin2aH8PeAtB4ON1DVvkjEyzTn7WgiKpLqlVqxiwgmkWXAvOxFykAdh7SjZaijthKJwJrr5AvYGwko2ztMbqYc6JKdvJt61xzEchhTkx6NKmdlJlA89EtQvqvk5t4u2NqYOzjetWzrDdh9SahisZhH7TsjXdlRTzD6c)YGrbPXgiKpLqlILbJcCSwf1yqlfx0AYPiJuKeOr27aHHVJOUe1nC0ZcCGinFeabrkz8MMoDHFLp6sL5ti3saqVjCypsaz8MMwVjsttZElqbo6IOTMgL1RVmyuqASbc5tj0MM7QIyzWOahRvHOUHJEwGdeP5JqyVmEttNUW)rxQmFc5wca6nHd7rciJ3006nrAAA2BbkWrxeT10OCTYGrbPXgiKpLqBAURkILbJcCSwfI6go6zboqKMpcLNiEtVjY4nnD6c)hDPY8jKBjaO3eoShjGmEttR3ePPPzVfOahDr0wtJY1kdgfKgBGq(ucTP5UQiwgmkWXAviQB4ONf4arA(iWoBYmasY0bPtx4ZGwko2ztMbqYc6JKdvtV(YGrbPnC0Z6U3kLepSS2MDydeYNsOT6YGrbowRcrDdh9SahisZhH30I5LG477KoDHFLlvri5OLmdlJdK6nTLu61ZGwkUO1KtrgPijqJS3bcdFVAU1RVmyuqAdh9SU7TsjXdlRTzh2aH8PeARUmyuGJ1Qqu3WrplWbI08r4ERus8WYABwNUWNbTuCrRjNImsrsGgzVdeg(oI6su3WrplWbI08rGJwLl9tsMHLrNUWVY8eooAvU0pjzgwgx0479MuRYWu0gooAvU0pj7TGc6zD0AmkklQlQB4ONf4WkYUrP5Jqk71Mz1Pl8dtrB4c6zbYPiPnXsiwAdhTgJIY1kdgfGyzWOahRvHOUHJEwGdRi7gLMpcC0QSeO1FharDdh9Sahwr2nknFec7LXBA60f(p6sL5tihyqvL5tijXYqpWrxeT10OCTWEz8MM7jwRxaIj4Cn8mQ8WX6kk7j3tSwVaetWzrDdh9Sahwr2nknFekk7jD6c)hDPY8jKdmOQY8jKKyzOh4OlI2AAuUwyVmEtZHQjQB4ONf4WkYUrP5JWtGzTO3eP9)WHOUHJEwGdRi7gLMpcC0QCPFsYmSm60f(fuLs(eoL9jKmAwcXeCwu3WrplWHvKDJsZhbCk7(BSarDdh9Sahwr2nknFeyqdCk6rsNUWppHdK6nTLusMHLXfn(EVj14CEcxVb9RPKmkIY9M4aHHVJi361NNWbs9M2skjZWY4EI16fGycoZjrDdh9Sahwr2nknFeW2FJ0Pl8Zt4aPEtBjLKzyzCrJV3BIOUHJEwGdRi7gLMpczYIusCk7(BS60f(LbJcsJnqiFkHweldgf4yTke1nC0ZcCyfz3O08rapZN71cklnaWqvHOUHJEwGdRi7gLMpcmObof9iPtx4JtzFcbKL3WrpRPQMBxvRHNrLhowhhTkx6NKmdlJRGQuYNWPSpHKrZsvd0iLsg2Nqbq3ZTOUHJEwGdRi7gLMpcfLT37nrcIVVt60f(LbJcsJnqiFkHweldgf4yTke1nC0ZcCyfz3O08r4ERus8WYABwhmsyfjd7tOaWNlD6c)YGrbPXgiKpLqlILbJcCSwf1kOkL8jCk7tiz0SeIj4SOUHJEwGdRi7gLMpcC0QCPFsYmSm60f(vMNWXrRYL(jjZWY4IgFV3erDdh9Sahwr2nknFeyqdCk6rsNUWNZvUufHKJwYmSmoqQ30wsPxFLHPOnCC0QCPFs2Bbf0Z6O1yuuMt1WZOYdhRJJwLl9tsMHLXvqvk5t4u2NqYOzPQbAKsjd7tOaO75wu3WrplWHvKDJsZhbS93iD6cF8mQ8WX64Ov5s)KKzyzCfuLs(eoL9jKmAwQAGgPuYW(eka6EUf1nC0ZcCyfz3O08r4ERusqQje1nC0ZcCyfz3O08rOOmKOSeKAcrDdh9Sahwr2nknFemjl6NPxofj(hoaI6go6zboSISBuA(iacIuY4nnD6c)kF0LkZNqULaGEt4WEKaY4nnTEtKMMM9wGcC0frBnnkRxFzWOG0ydeYNsOnn3vfXYGrbowRcrDdh9Sahwr2nknFea0RrBibrVj6GrcRizyFcfa(CPtx4)u5jqkJrr1ctrB4sHu(nGKPdYrRXOOSOUHJEwGdRi7gLMpcy7VrI6go6zboSISBuA(iCVvkjEyzTnRdgjSIKH9jua4ZLoDHFzWOG0ydeYNsOfXYGrbowRcrDdh9Sahwr2nknFea0RrBibrVj6GrcRizyFcfa(CPtx4)u5jqkJrr14CLHPOnCm9NbYPi1EcjhTgJIY61xjdAP4WZ85ETGYsdamuv4q14unox5JUuz(eY9iPS7GWu3PhiXZwg0n3BIeeFFNao6IOTMgL1RFPkcjhTKzyzC3gLfTI0RpmfTHJbnWPOhjhTgJIYCsVEg0sXDR1OhiVr7W6q1e1nC0ZcCyfz3O08rGD2KzaKKPdshmsyfjd7tOaWNlD6c)mXGwkoLf0gsTPbZk7TkjC0Z6aHHVx9fiQB4ONf4WkYUrP5JWBAX8sq89Dshmsyfjd7tOaWNlD6c)mXGwkoLf0gsTPbZk7TkjC0Z6aHHVx9fiQB4ONf4WkYUrP5JaGEnAdji6nrhmsyfjd7tOaWNlD6c)kdtrB4y6pdKtrQ9esoAngfLRvzykAd3TwJEG8gTdRJwJrr5Av(OlvMpHCklOnKAtdMv2Bvs4yEGJUiARPr5Av(OlvMpHCpsk7oim1D6bs8SLbDZ9MibX33jGJUiARPrzrDdh9Sahwr2nknFeyNnzgajz6G0bJewrYW(eka85su3WrplWHvKDJsZhH30I5LG477KoyKWksg2NqbGpxWagqi]] )

end