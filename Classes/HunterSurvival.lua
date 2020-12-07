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

    spec:RegisterPack( "Survival", 20201206, [[dK0qbcqiOs9iaq1LiuP2Kq5tqfvJIq0PiewfHkELKywek3cav7sWVGQmmHihtiTmOcptiQPrOsUga02aa(gHQyCqfX5iuLwhHQY8iq3JG2hujhKqvvwiH0dHkstKqvfDraquFeaegjaiYjbaLvcOMjurzNsklLqvv9uGMkuvFLqvLglaiTxi)LKbtQdt1IrQhdAYk6YO2ScFgHrdqNw0QjuvHxdiZwIBJKDR0VLA4i64ailxvpxLPt56qz7eW3LKgVq48sQwpakZxOA)enkkcFe40ngvdhrchrkkoIeaiGJibGroYaic0QtYiqshcKtWiW1Pyeii2lqkGxqGKE9s7te(iWRXEiJab0mYt8HhEePbigDa2u4DjfwXTSx47ddVlPG4HaPXYIbaBr0iWPBmQgoIeoIuuCejaqahrcaJCKXbc0Xma7hbcMuyf3YEXPVpmeiG5CYlIgbo5dIabGl1GyVaPaErQbGe2A8lbgaUul(jdzkA(LAaGysnoIeoIecSKNDi8rGo5zi8r1IIWhbYRtx4jsuei8tJ)0rGJgIDsDfPg6NPEMGxPwqPE0qSlq5rGaDOL9IaNSBaQGa6a9ofYq1WbcFeiVoDHNirrGo0YErGh)K8AQZYLabc)04pDeiUL6zBHJFsEn1z5seSecuUesDmP28NGTGLuSYA1mzPgxsT4bbcRdlSY8NGTdvlkYq1ImcFeOdTSxe4O415P6aSneiVoDHNirrgQM4cHpc0Hw2lc85Rx3YLq5)3vrG860fEIefzOAaicFeOdTSxey1Smvhz(PDiqED6cprIImunaacFeOdTSxeiS7FMRB8u535yfdbYRtx4jsuKHQjEq4JaDOL9Iabklf1byBiqED6cprIImunCccFeiVoDHNirrGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhbc0Hw2lcCu8fOCjuN9jqmYq1eVi8rGo0YErGUIc7N8R6Hc(D1dbYRtx4jsuKHQfnsi8rG860fEIefbc)04pDe4aRuupdb0Fcwzjfl1ck1eWPuhpUupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQfPuVCeMQAQOBk6GaDXTSWsDmPE2w44NKxtDwUeblHaLlHuhtQNTfo(j51uNLlr45XZhGoDHL64XL6LJWuvtfDtrhibK)MQxwQJj14wQPXgJavVeDFSAG91dyKsDmPE0qStQRi1q)m1Ze8k1ck1JgIDbkpcPgGl1o0YEdaLLIc2uu(odq)m1Ze8k1IJuhzPwesD84sTLuSYA1mzPwqPoAKqGo0YErGvZYCKpROBkAKHQfnkcFeiVoDHNirrGWpn(thb6qlfGv8YujFsnUK6OsDmPg3s9JT8OFco81loqN5fG4)uWEhn2oZLqD2NaXxGbiSKKKNiqhAzViqO)cWidvlkoq4Ja51Pl8ejkce(PXF6iWrdXoPUIud9ZuptWRulOupAi2fO8iqGo0YErGNXCrzVtImuTOrgHpcKxNUWtKOiqhAzViqQEj6(yfDAmce(PXF6iqASXiq1lr3hRgyF9agPuhtQPXgJavVeDFSAG91dpt55EsTGs9OHyNuJNulsP2Hw2BGQxIUpwrNghG9zsnaxQH(zQNj4vQfHulosnbCk1XKACl10yJrOAwMQJm)0UWZuEUNuhpUutJngbQEj6(y1a7RhEMYZ9K6ys9YryQQPIUPOdKaYFt1lJaH1Hfwz(tW2HQffzOArfxi8rG860fEIefb6ql7fbcuwkkytr57ebc)04pDe4aRuupdb0Fcwzjfl1ck1eWPuhtQhne7K6ksn0pt9mbVsTGs9OHyxGYJabcRdlSY8NGTdvlkYq1IcGi8rG860fEIefb6ql7fb(oP1V6SpbIrGWpn(thbsJngbljv9qzaYQJK9pCMdbsQfk1rwQJhxQNTfoaFNC5IIUPOdwcbkxceiSoSWkZFc2ouTOidvlkaaHpcKxNUWtKOiq4Ng)PJaNTfoaFNC5IIUPOdwcbkxceOdTSxeivVeDFSIongzOArfpi8rG860fEIefb6ql7fbE8tYRPolxcei8tJ)0rGppE(a0PlSuhtQn)jylyjfRSwntwQXLulEqGW6WcRm)jy7q1IImuTO4ee(iqED6cprIIaHFA8NocC5imv1ur3u0HdW3jxUi1XK6rdXoPgxsTdTS3avVeDFSIonoa7ZKAXrQXHuhtQNTfo(j51uNLlr4zkp3tQXLudGsT4i1eWjc0Hw2lcSAwMJ8zfDtrJmuTOIxe(iqhAzViqiGoqVtDiqED6cprIImunCeje(iqED6cprIIaDOL9IabklffSPO8DIaHFA8NocC0qStQRi1q)m1Ze8k1ck1JgIDbkpceiSoSWkZFc2ouTOidvdhrr4Ja51Pl8ejkce(PXF6iWhB5r)eC4RxCGoZlaX)PG9oASDMlH6SpbIVadqyjjjprGo0YErGvZYCKpROBkAKHQHdCGWhbYRtx4jsueOdTSxeivVeDFSIongbc)04pDein2yeO6LO7JvdSVEaJuQJhxQhne7K6ksTdTS3aqzPOGnfLVZa0pt9mbVsnUK6rdXUaLhHudWL6OaOuhpUupBlCa(o5YffDtrhSecuUesD84snn2yeQMLP6iZpTl8mLN7HaH1Hfwz(tW2HQffzOA4iYi8rG860fEIefb6ql7fb(oP1V6SpbIrGW6WcRm)jy7q1IImunCiUq4Ja51Pl8ejkce(PXF6iWLJWuvtfDtrheOlULfwQJj1Z2ch)K8AQZYLiyjeOCjK64XL6LJWuvtfDtrhibK)MQxwQJhxQxoctvnv0nfD4a8DYLlsDmPE0qStQXLudGrcb6ql7fbwnlZr(SIUPOrgYqGKpdBkA3q4JQffHpc0Hw2lc8WOO6vrYgcKxNUWtKOidvdhi8rG860fEIefbc)04pDe4JT8OFcoCnwz0pbRykA(VadqyjjjprGo0YErGM)k7DsKHQfze(iqhAzViWZyUOS3jrG860fEIefzidbo5HJvme(OArr4JaDOL9IaPWayaScJa51Pl8ejkYq1WbcFeOdTSxei2XQ0yQdbYRtx4jsuKHQfze(iqED6cprIIaHFA8Noc0HwkaR4LPs(KAbL6il1XKACl1Mx41cEHeqxr(80T(d860fEk1XKACl1Mx41cvZYCKpRYDGDzVbED6cprGo0YErGqVuuo0YEvL8meyjptTofJaPBsKHQjUq4Ja51Pl8ejkce(PXF6iqhAPaSIxMk5tQfuQJSuhtQnVWRf8cjGUI85PB9h41Pl8uQJj14wQnVWRfQML5iFwL7a7YEd860fEIaDOL9IaHEPOCOL9Qk5ziWsEMADkgb6K0njYq1aqe(iqED6cprIIaHFA8Noc0HwkaR4LPs(KAbL6il1XKAZl8AbVqcORiFE6w)bED6cpL6ysT5fETq1Smh5ZQChyx2BGxNUWteOdTSxei0lfLdTSxvjpdbwYZuRtXiqN8mKHQbaq4Ja51Pl8ejkce(PXF6iqhAPaSIxMk5tQfuQJSuhtQXTuBEHxl4fsaDf5Zt36pWRtx4PuhtQnVWRfQML5iFwL7a7YEd860fEIaDOL9IaHEPOCOL9Qk5ziWsEMADkgbEgYq1epi8rG860fEIefbc)04pDeOdTuawXltL8j14sQXbc0Hw2lce6LIYHw2RQKNHal5zQ1PyeiSWUamYq1Wji8rGo0YErG(d9Lvw)pVgcKxNUWtKOidziqyHDbye(OArr4Ja51Pl8ejkc0Hw2lc84NKxtDwUeiq4Ng)PJanVWRfaS(89trNgh41Pl8uQJj10yJrqGKK)tjaVnv4zkp3tQJj10yJrqGKK)tjaVnv4zkp3tQfuQjGteiSoSWkZFc2ouTOidvdhi8rGo0YErGvZYuDK5N2Ha51Pl8ejkYq1ImcFeOdTSxe4ZxVULlHY)VRIa51Pl8ejkYq1exi8rG860fEIefbc)04pDe4aRuupdb0Fcwzjfl1ck1eWjc0Hw2lcSAwMJ8zfDtrJmunaeHpc0Hw2lcecOd07uhcKxNUWtKOidvdaGWhbYRtx4jsuei8tJ)0rGZ2chGVtUCrr3u0blHaLlHuhtQfPupBlKRX)6ffDH5zUeHZCiqsTGsnoK64XL6zBHdW3jxUOOBk6WZuEUNulOutaNsTiqGo0YErG0ygeq(RJmunXdcFeiVoDHNirrGWpn(thboBlCa(o5YffDtrhSecuUeiqhAzViqO)cWidvdNGWhbYRtx4jsuei8tJ)0rGJgIDsDfPg6NPEMGxPwqPE0qSlq5rGaDOL9IaNSBaQGa6a9ofYq1eVi8rGo0YErGWU)zUUXtLFNJvmeiVoDHNirrgQw0iHWhbYRtx4jsuei8tJ)0rGqa9NGp14DOL96fPgxsnocaOuhtQHDxMD1nunlZr(SIUPOddSsr9meq)jyLLuSuJlP(i5srz(tW2j14j14ab6ql7fbsJzqa5VoYq1IgfHpcKxNUWtKOiq4Ng)PJahne7K6ksn0pt9mbVsTGs9OHyxGYJab6ql7fbok(cuUeQZ(eigzOArXbcFeiVoDHNirrGWpn(thbc7Um7QBOAwMJ8zfDtrhgyLI6ziG(tWklPyPgxs9rYLIY8NGTtQXtQXHuhtQnVWRf8cjGUI85PB9h41Pl8eb6ql7fbc9xagzOArJmcFeiVoDHNirrGo0YErGaLLIc2uu(orGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQhyLI6ziG(tWklPyPwqPMaoL6ysTiL6hB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpL6ysnS7YSRUHXZmalxcL9oz4zkp3tQJj1WUlZU6gm)v27KHNP8CpPoECPg3s9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNsTiqGW6WcRm)jy7q1IImuTOIle(iqED6cprIIaHFA8Noce3s9STq1Smh5Zk6MIoyjeOCjqGo0YErGvZYCKpROBkAKHQffar4Ja51Pl8ejkce(PXF6iqrk14wQxoctvnv0nfD4a8DYLlsD84snULAZl8AHQzzoYNv5oWUS3aVoDHNsTiK6ysnS7YSRUHQzzoYNv0nfDyGvkQNHa6pbRSKILACj1hjxkkZFc2oPgpPghiqhAzViqAmdci)1rgQwuaacFeiVoDHNirrGWpn(thbc7Um7QBOAwMJ8zfDtrhgyLI6ziG(tWklPyPgxs9rYLIY8NGTtQXtQXbc0Hw2lce6VamYq1IkEq4JaDOL9Iabklf1byBiqED6cprIImuTO4ee(iqhAzViWrXRZt1byBiqED6cprIImuTOIxe(iqhAzViqxrH9t(v9qb)U6Ha51Pl8ejkYq1WrKq4JaDOL9IapJ5IYENebYRtx4jsuKHQHJOi8rG860fEIefb6ql7fbE8tYRPolxcei8tJ)0rGppE(a0PlSuhtQnVWRfaS(89trNgh41Pl8uQJj1M)eSfSKIvwRMjl14sQXjiqyDyHvM)eSDOArrgQgoWbcFeOdTSxei0FbyeiVoDHNirrgQgoImcFeiVoDHNirrGo0YErGaLLIc2uu(orGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQfPu)ylp6NGdlFxUev9V(PS3jjZLq5KK(7g2fyacljj5PuhtQHDxMD1nmEMby5sOS3jdpt55EsDmPg2Dz2v3G5VYENm8mLN7j1XJl14wQFSLh9tWHLVlxIQ(x)u27KK5sOCss)Dd7cmaHLKK8uQfbcewhwyL5pbBhQwuKHQHdXfcFeiVoDHNirrGo0YErGh)K8AQZYLabc)04pDe4ZJNpaD6cJaH1Hfwz(tW2HQffzOA4aar4Ja51Pl8ejkc0Hw2lcKQxIUpwrNgJaH1Hfwz(tW2HQffzOA4aaGWhbYRtx4jsueOdTSxe47Kw)QZ(eigbcRdlSY8NGTdvlkYqgcKUjr4JQffHpcKxNUWtKOiqhAzViWJFsEn1z5sGaHFA8NocKgBmccKK8Fkb4TPcpt55EsDmPMgBmccKK8Fkb4TPcpt55EsTGsnbCIaH1Hfwz(tW2HQffzOA4aHpcKxNUWtKOiqhAzViqGYsrbBkkFNiq4Ng)PJahne7K6ksn0pt9mbVsTGs9OHyxGYJqQJj10yJry57YLOQ)1pL9ojzUekNK0F3WUagjcewhwyL5pbBhQwuKHQfze(iqED6cprIIaHFA8NocC0qStQRi1q)m1Ze8k1ck1JgIDbkpcPoMuJBP2siq5si1XK6bwPOEgcO)eSYskwQfuQjGteOdTSxey1Smh5Zk6MIgzOAIle(iqhAzViWQzzQoY8t7qG860fEIefzOAaicFeiVoDHNirrGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhbc0Hw2lcCu8fOCjuN9jqmYq1aai8rGo0YErGJIxNNQdW2qG860fEIefzOAIhe(iqED6cprIIaHFA8NocC0qStQRi1q)m1Ze8k1ck1JgIDbkpceOdTSxe4KDdqfeqhO3PqgQgobHpc0Hw2lceOSuuhGTHa51Pl8ejkYq1eVi8rG860fEIefb6ql7fb(oP1V6SpbIrGWpn(thbsJngby3)mx34PYVZXkwaJuQJj10yJra29pZ1nEQ87CSIfEMYZ9KAbL6ObauQfhPMaorGW6WcRm)jy7q1IImuTOrcHpcKxNUWtKOiqhAzViqQEj6(yfDAmce(PXF6iqASXia7(N56gpv(DowXcyKsDmPMgBmcWU)zUUXtLFNJvSWZuEUNulOuhnaGsT4i1eWjcewhwyL5pbBhQwuKHQfnkcFeOdTSxeOROW(j)QEOGFx9qG860fEIefzOArXbcFeiVoDHNirrGo0YErGVtA9Ro7tGyei8tJ)0rG0yJrWssvpugGS6iz)dN5qGKAHsDKrGW6WcRm)jy7q1IImuTOrgHpcKxNUWtKOiq4Ng)PJahne7K6ksn0pt9mbVsTGs9OHyxGYJqQJj14wQTecuUesDmPwKs9aRuupdb0Fcwzjfl1ck1eWPuhpUuJBPE2wOAwMJ8zfDtrhSecuUesDmPMgBmcu9s09XQb2xp8mLN7j14sQhyLI6ziG(tWklPyPgGl1rLAXrQjGtPoECPg3s9STq1Smh5Zk6MIoyjeOCjK6ysnULAASXiq1lr3hRgyF9WZuEUNulcPoECP2skwzTAMSulOuhfNi1XKACl1Z2cvZYCKpROBk6GLqGYLab6ql7fbwnlZr(SIUPOrgQwuXfcFeiVoDHNirrGo0YErGaLLIc2uu(orGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQXTu)ylp6NGdlFxUev9V(PS3jjZLq5KK(7g2fyacljj5PuhpUupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQfPulsP(XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYtPoMuJBP28cVw4mMlk7DYaVoDHNsDmPg2Dz2v3W4zgGLlHYENm8mLN7j1XKAy3LzxDdM)k7DYWZuEUNulcPoECPwKs9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNsDmP28cVw4mMlk7DYaVoDHNsDmPg2Dz2v3W4zgGLlHYENm8mLN7j1XKAy3LzxDdM)k7DYWZuEUNuhtQHDxMD1nCgZfL9oz4zkp3tQfHulcPoECPE0qStQfuQDOL9gO6LO7Jv0PXbyFgcewhwyL5pbBhQwuKHQffar4Ja51Pl8ejkce(PXF6iWrdXoPUIud9ZuptWRulOupAi2fO8iqGo0YErGNXCrzVtImuTOaae(iqED6cprIIaDOL9Iap(j51uNLlbce(PXF6iqASXiiqsY)PeG3MkGrk1XK6NhpFa60fwQJhxQNTfo(j51uNLlr45XZhGoDHL6ysnULAASXia7(N56gpv(DowXcyKiqyDyHvM)eSDOArrgQwuXdcFeOdTSxe4ZxVULlHY)VRIa51Pl8ejkYq1IItq4Ja51Pl8ejkce(PXF6iqCl10yJra29pZ1nEQ87CSIfWirGo0YErGWU)zUUXtLFNJvmKHQfv8IWhbYRtx4jsuei8tJ)0rG0yJrGQxIUpwnW(6bmsPoECPE0qStQRi1o0YEdaLLIc2uu(odq)m1Ze8k14sQhne7cuEesD84snn2yeGD)ZCDJNk)ohRybmseOdTSxeivVeDFSIongzOA4isi8rG860fEIefb6ql7fb(oP1V6SpbIrGW6WcRm)jy7q1IImunCefHpcKxNUWtKOiq4Ng)PJaNTfQML5iFwr3u0HNhpFa60fgb6ql7fbwnlZr(SIUPOrgQgoWbcFeiVoDHNirrGo0YErGh)K8AQZYLabc)04pDein2yeeij5)ucWBtfWirGW6WcRm)jy7q1IImKHaHZdHpQwue(iqED6cprIIaHFA8Noc08cVwW4N6u9qXlHtWu8AbED6cpL6ys9OHyNulOupAi2fO8iqGo0YErGa6pz3lYq1WbcFeiVoDHNirrGWpn(thbc7Um7QBa29pZ1nEQ87CSIfEMYZ9KACj1rosiqhAzViq6s3t1a7RJmuTiJWhbYRtx4jsuei8tJ)0rGWUlZU6gGD)ZCDJNk)ohRyHNP8CpPgxsDKJec0Hw2lc0xiF27ff0lfKHQjUq4Ja51Pl8ejkce(PXF6iqy3LzxDdWU)zUUXtLFNJvSWZuEUNuJlPoYrcb6ql7fboYNPlDprgQgaIWhb6ql7fbwscaTtj(b2KGIxdbYRtx4jsuKHQbaq4Ja51Pl8ejkce(PXF6iqy3LzxDdaLLIc2uu(oddSsr9meq)jyLLuSuJlPMaorGo0YErG0oHQhk7tiqhYq1epi8rG860fEIefbc)04pDeiS7YSRUby3)mx34PYVZXkw4zkp3tQXLudaIKuhpUuBjfRSwntwQfuQJgzeOdTSxein)h)aLlbYq1Wji8rG860fEIefbc)04pDeO5pbBblPyL1QzYsTGsnaissD84snn2yeGD)ZCDJNk)ohRybmseOdTSxeizBzVidvt8IWhbYRtx4jsuei8tJ)0rGp2YJ(j4WY3Llrv)RFk7DsYCjuojP)UHDbgGWsssEk1XK6rdXoPUIud9ZuptWRulOupAi2fO8iqGo0YErGNXCrzVtImuTOrcHpcKxNUWtKOiq4Ng)PJaFSLh9tWHLVlxIQ(x)u27KK5sOCss)Dd7cmaHLKK8uQJj1JgIDsDfPg6NPEMGxPwqPE0qSlq5rGaDOL9IahpZaSCju27KidvlAue(iqED6cprIIaHFA8Noc8XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYtPoMupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhpUupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQFSLh9tWHRXkJ(jyftrZ)fyacljj5PuhtQn)v27KHNP8CpPwqPMaoL6ysnS7YSRUHrXFo8mLN7j1ck1eWPuhtQfPu7qlfGv8YujFsnUK6OsD84sTdTuawXltL8j1cL6OsDmP2skwzTAMSuJlPgaLAXrQjGtPweiqhAzViqZFL9ojYq1IIde(iqED6cprIIaHFA8NocC0qStQRi1q)m1Ze8k1ck1JgIDbkpcPoMuB(RS3jdyKsDmP(XwE0pbhUgRm6NGvmfn)xGbiSKKKNsDmP2skwzTAMSuJlPwCj1IJutaNiqhAzViWrXFgzOArJmcFeiVoDHNirrGWpn(thb6qlfGv8YujFsTqPoQuhtQn)jylyjfRSwntwQfuQhne7KA8KArk1o0YEdu9s09Xk604aSptQb4sn0pt9mbVsTiKAXrQjGteOdTSxeiqzPOoaBdzOArfxi8rG860fEIefbc)04pDeOdTuawXltL8j1cL6OsDmP28NGTGLuSYA1mzPwqPE0qStQXtQfPu7ql7nq1lr3hROtJdW(mPgGl1q)m1Ze8k1IqQfhPMaorGo0YErGu9s09Xk60yKHQffar4Ja51Pl8ejkce(PXF6iqhAPaSIxMk5tQfk1rL6ysT5pbBblPyL1QzYsTGs9OHyNuJNulsP2Hw2BGQxIUpwrNghG9zsnaxQH(zQNj4vQfHulosnbCIaDOL9IaFN06xD2NaXidvlkaaHpcKxNUWtKOiq4Ng)PJan)jylmZZ8fYsnUek1aaeOdTSxeOFKm0u9qzaYk2jkmYq1IkEq4Ja51Pl8ejkce(PXF6iW3ZPIfGxl4Z5fYvQXLulEJKuhtQhne7KAbL6rdXUaLhHudWLACaGsD84sTiLAhAPaSIxMk5tQXLuhvQJj14wQnVWRfOZFEQEOiFUEGxNUWtPoECP2HwkaR4LPs(KACj14qQfHuhtQfPutJngb6c2R6HY8sVxaJuQJj10yJrGUG9QEOmV07fEMYZ9KACj1rwQfhPMaoL64XLACl10yJrGUG9QEOmV07fWiLArGaDOL9Iahne74PYby8NgROzNczOArXji8rG860fEIefbc)04pDeOiLArk1VNtflaVwWNZl8mLN7j14sQfVrsQJhxQXTu)EovSa8AbFoVahrE2j1IqQJhxQfPu7qlfGv8YujFsnUK6OsDmPg3sT5fETaD(Zt1df5Z1d860fEk1XJl1o0sbyfVmvYNuJlPghsTiKAri1XK6rdXoPwqPE0qSlq5rGaDOL9IaPlDpv9qzaYkEzQ6idvlQ4fHpcKxNUWtKOiq4Ng)PJafPulsP(9CQyb41c(CEHNP8CpPgxsnaissD84snUL63ZPIfGxl4Z5f4iYZoPwesD84sTiLAhAPaSIxMk5tQXLuhvQJj14wQnVWRfOZFEQEOiFUEGxNUWtPoECP2HwkaR4LPs(KACj14qQfHulcPoMupAi2j1ck1JgIDbkpceOdTSxeij2NJ65sOOl(zidvdhrcHpc0Hw2lcKaZ)z6RQhkhGXFBaIa51Pl8ejkYq1Wrue(iqhAzViWpjjlSkx1r6qgbYRtx4jsuKHQHdCGWhbYRtx4jsuei8tJ)0rGdSsr9meq)jyLLuSulOuhvQfhPMaorGo0YErGWEH8AVB8unkofJmunCeze(iqED6cprIIaHFA8NocKgBmcpdbQW3Pg9d5agjc0Hw2lc0aKvylDJTt1OFiJmunCiUq4JaDOL9IaR2FzkaNR65RxFHmcKxNUWtKOidvdhaicFeiVoDHNirrGWpn(thbA(tWwaq2lgGbsOj14sQXjrsQJhxQn)jylai7fdWaj0KAbfk14issD84sT5pbBblPyL1ksOPWrKKACj1rosiqhAzViWNDYCjuJItXhYq1WbaaHpcKxNUWtKOiq4Ng)PJahne7KAbLAhAzVbQEj6(yfDACa2Nj1XKAASXia7(N56gpv(DowXcyKiqhAzViqkMQ)6QEOkyWCQMp7uhYqgc8me(OArr4JaDOL9IahfVopvhGTHa51Pl8ejkYq1WbcFeOdTSxey1Smvhz(PDiqED6cprIImuTiJWhb6ql7fb(81RB5sO8)7QiqED6cprIImunXfcFeiVoDHNirrGo0YErGh)K8AQZYLabc)04pDein2yeeij5)ucWBtfWiL6ysnn2yeeij5)ucWBtfEMYZ9KAbLAc4uQJhxQXTuBjeOCjqGW6WcRm)jy7q1IImunaeHpcKxNUWtKOiq4Ng)PJahne7K6ksn0pt9mbVsTGs9OHyxGYJab6ql7fboz3aubb0b6DkKHQbaq4Ja51Pl8ejkc0Hw2lc8DsRF1zFceJaHFA8NocKgBmcwsQ6HYaKvhj7F4mhcKuluQJmcewhwyL5pbBhQwuKHQjEq4JaDOL9IaHD)ZCDJNk)ohRyiqED6cprIImunCccFeOdTSxeiqzPOoaBdbYRtx4jsuKHQjEr4Ja51Pl8ejkce(PXF6iWbwPOEgcO)eSYskwQfuQjGtPoMupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhpUulsPE5imv1ur3u0bb6IBzHL6ys9STWXpjVM6SCjcwcbkxcPoMupBlC8tYRPolxIWZJNpaD6cl1XJl1lhHPQMk6MIoqci)nvVSuhtQhne7K6ksn0pt9mbVsTGs9OHyxGYJqQb4sTdTS3aqzPOGnfLVZa0pt9mbVsT4i1rwQJj14wQPXgJavVeDFSAG91dpt55EsTiqGo0YErGvZYCKpROBkAKHQfnsi8rG860fEIefbc)04pDe4OHyNuxrQH(zQNj4vQfuQhne7cuEeiqhAzViWZyUOS3jrgQw0Oi8rG860fEIefbc)04pDe4OHyNuxrQH(zQNj4vQfuQhne7cuEeiqhAzViWrXxGYLqD2NaXidvlkoq4Ja51Pl8ejkc0Hw2lceOSuuWMIY3jce(PXF6iWrdXoPUIud9ZuptWRulOupAi2fO8iK6ysTiL6hB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpL6ysnS7YSRUHXZmalxcL9oz4zkp3tQJj1WUlZU6gm)v27KHNP8CpPoECPg3s9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNsTiqGW6WcRm)jy7q1IImuTOrgHpcKxNUWtKOiq4Ng)PJaDOLcWkEzQKpPgxsDuPoMuJBP(XwE0pbh(6fhOZ8cq8FkyVJgBN5sOo7tG4lWaewssYteOdTSxei0FbyKHQfvCHWhb6ql7fb6kkSFYVQhk43vpeiVoDHNirrgQwuaeHpcKxNUWtKOiqhAzViqQEj6(yfDAmce(PXF6iWzBHdW3jxUOOBk6GLqGYLqQJhxQPXgJavVeDFSAG91dN5qGKAHsnaIaH1Hfwz(tW2HQffzOArbai8rG860fEIefb6ql7fbE8tYRPolxcei8tJ)0rGppE(a0PlSuhpUutJngbbss(pLa82ubmseiSoSWkZFc2ouTOidvlQ4bHpcKxNUWtKOiq4Ng)PJaxoctvnv0nfD4a8DYLlsDmPE2w44NKxtDwUeHNP8CpPgxsnak1IJutaNsD84s9JT8OFco81loqN5fG4)uWEhn2oZLqD2NaXxGbiSKKKNiqhAzViWQzzoYNv0nfnYq1IItq4JaDOL9IaHa6a9o1Ha51Pl8ejkYq1IkEr4Ja51Pl8ejkc0Hw2lcKQxIUpwrNgJaHFA8NocKgBmcu9s09XQb2xpGrk1XJl1JgIDsDfP2Hw2BaOSuuWMIY3za6NPEMGxPgxs9OHyxGYJqQb4sDuauQJhxQNTfoaFNC5IIUPOdwcbkxceiSoSWkZFc2ouTOidvdhrcHpcKxNUWtKOiqhAzViW3jT(vN9jqmcewhwyL5pbBhQwuKHQHJOi8rG860fEIefbc)04pDe4YryQQPIUPOdc0f3Ycl1XK6zBHJFsEn1z5seSecuUesD84s9YryQQPIUPOdKaYFt1ll1XJl1lhHPQMk6MIoCa(o5YfeOdTSxey1Smh5Zk6MIgzidb6K0njcFuTOi8rGo0YErGvZYuDK5N2Ha51Pl8ejkYq1WbcFeiVoDHNirrGWpn(thboAi2j1vKAOFM6zcELAbL6rdXUaLhbc0Hw2lcCu8fOCjuN9jqmYq1ImcFeOdTSxe4O415P6aSneiVoDHNirrgQM4cHpcKxNUWtKOiq4Ng)PJahne7K6ksn0pt9mbVsTGs9OHyxGYJab6ql7fboz3aubb0b6DkKHQbGi8rGo0YErGaLLI6aSneiVoDHNirrgQgaaHpcKxNUWtKOiqhAzViqQEj6(yfDAmce(PXF6iqASXia7(N56gpv(DowXcyKsDmPMgBmcWU)zUUXtLFNJvSWZuEUNulOuhnaGsT4i1eWjcewhwyL5pbBhQwuKHQjEq4Ja51Pl8ejkc0Hw2lc8DsRF1zFceJaHFA8NocKgBmcWU)zUUXtLFNJvSagPuhtQPXgJaS7FMRB8u535yfl8mLN7j1ck1rdaOulosnbCIaH1Hfwz(tW2HQffzOA4ee(iqED6cprIIaHFA8NocC0qStQRi1q)m1Ze8k1ck1JgIDbkpceOdTSxe4O4lq5sOo7tGyKHQjEr4Ja51Pl8ejkce(PXF6iWrdXoPUIud9ZuptWRulOupAi2fO8iK6ysnULAlHaLlHuhtQfPupWkf1Zqa9NGvwsXsTGsnbCk1XJl14wQNTfQML5iFwr3u0blHaLlHuhtQPXgJavVeDFSAG91dpt55EsnUK6bwPOEgcO)eSYskwQb4sDuPwCKAc4uQJhxQXTupBlunlZr(SIUPOdwcbkxcPoMuJBPMgBmcu9s09XQb2xp8mLN7j1IqQJhxQTKIvwRMjl1ck1rXjsDmPg3s9STq1Smh5Zk6MIoyjeOCjqGo0YErGvZYCKpROBkAKHQfnsi8rG860fEIefbc)04pDe4OHyNuxrQH(zQNj4vQfuQhne7cuEeiqhAzViWZyUOS3jrgQw0Oi8rG860fEIefb6ql7fbs1lr3hROtJrGWpn(thbsJngbQEj6(y1a7RhWiL6ysnn2yeO6LO7JvdSVE4zkp3tQfuQhne7KA8KArk1o0YEdu9s09Xk604aSptQb4sn0pt9mbVsTiKAXrQjGteiSoSWkZFc2ouTOidvlkoq4Ja51Pl8ejkc0Hw2lceOSuuWMIY3jce(PXF6iWbwPOEgcO)eSYskwQfuQjGtPoMupAi2j1vKAOFM6zcELAbL6rdXUaLhHuhtQfPu)ylp6NGdlFxUev9V(PS3jjZLq5KK(7g2fyacljj5PuhtQHDxMD1nmEMby5sOS3jdpt55EsDmPg2Dz2v3G5VYENm8mLN7j1XJl14wQFSLh9tWHLVlxIQ(x)u27KK5sOCss)Dd7cmaHLKK8uQfbcewhwyL5pbBhQwuKHQfnYi8rG860fEIefb6ql7fbE8tYRPolxcei8tJ)0rGZ2ch)K8AQZYLi8845dqNUWsDmPg3snn2yeO6LO7JvdSVE4zkp3dbcRdlSY8NGTdvlkYq1IkUq4Ja51Pl8ejkc0Hw2lceOSuuWMIY3jce(PXF6iWrdXoPUIud9ZuptWRulOupAi2fO8iK6ysTiLAASXiq1lr3hRgyF9WzoeiPwqPgaL64XL6rdXoPwqP2Hw2BGQxIUpwrNghG9zsTiK6ysTiL6hB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpL6ysnS7YSRUHXZmalxcL9oz4zkp3tQJj1WUlZU6gm)v27KHNP8CpPoECPg3s9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNsTiqGW6WcRm)jy7q1IImuTOaicFeOdTSxeOROW(j)QEOGFx9qG860fEIefzOArbai8rGo0YErGpF96wUek))UkcKxNUWtKOidvlQ4bHpc0Hw2lce29pZ1nEQ87CSIHa51Pl8ejkYq1IItq4Ja51Pl8ejkc0Hw2lcKQxIUpwrNgJaHFA8NocKgBmcu9s09XQb2xpGrk1XJl1JgIDsDfP2Hw2BaOSuuWMIY3za6NPEMGxPgxs9OHyxGYJqQJhxQPXgJaS7FMRB8u535yflGrIaH1Hfwz(tW2HQffzOArfVi8rG860fEIefb6ql7fb(oP1V6SpbIrGW6WcRm)jy7q1IImunCeje(iqED6cprIIaHFA8Noce3sTLqGYLab6ql7fbwnlZr(SIUPOrgYqgcua(VSxunCejCePOrXbobbw1)nxIdbk(v8N4)AaWQbaH4tQLA8bKL6KISFtQh9l14CN8mCUu)maHLppL6RPyP2XSMYnEk1qa9LGVGeyCwUSuhnYIpPgN2Ra8B8uQbtkCQuF1xZJqQf3sT1snodZL6zkqEzVsDtYVB9l1Iepri1ImAeIiibwcS4xXFI)RbaRgaeIpPwQXhqwQtkY(nPE0VuJZHf2fGX5s9Zaew(8uQVMILAhZAk34Pudb0xc(csGXz5YsD0ij(KACAVcWVXtPgmPWPs9vFnpcPwCl1wl14mmxQNPa5L9k1nj)U1Vuls8eHulYOriIGeyCwUSuhfhIpPgN2Ra8B8uQbtkCQuF1xZJqQf3sT1snodZL6zkqEzVsDtYVB9l1Iepri1ImAeIiibgNLll1rbqXNuJt7va(nEk1GjfovQV6R5ri1IBP2APgNH5s9mfiVSxPUj53T(LArINiKArgncreKaJZYLL6OaaXNuJt7va(nEk1GjfovQV6R5ri1IBP2APgNH5s9mfiVSxPUj53T(LArINiKArgncreKalbw8R4pX)1aGvdacXNul14dil1jfz)Mup6xQX5W5HZL6NbiS85PuFnfl1oM1uUXtPgcOVe8fKaJZYLL6Orw8j140EfGFJNsnysHtL6R(AEesT4wQTwQXzyUuptbYl7vQBs(DRFPwK4jcPwKrJqebjW4SCzPoQ4s8j140EfGFJNsnysHtL6R(AEesT4wQTwQXzyUuptbYl7vQBs(DRFPwK4jcPwKrJqebjW4SCzPokak(KACAVcWVXtPgmPWPs9vFnpcPwCl1wl14mmxQNPa5L9k1nj)U1Vuls8eHulYOriIGeyCwUSuhv8i(KACAVcWVXtPgNBEHxlaafNl1wl14CZl8AbaObED6cpX5sTiJgHicsGXz5YsDuCI4tQXP9ka)gpLACU5fETaauCUuBTuJZnVWRfaGg41Pl8eNl1ImAeIiibgNLll1rfVIpPgN2Ra8B8uQX5Mx41caqX5sT1sno38cVwaaAGxNUWtCUulYOriIGeyjWIFf)j(VgaSAaqi(KAPgFazPoPi73K6r)sno3jPBsCUu)maHLppL6RPyP2XSMYnEk1qa9LGVGeyCwUSuhnQ4tQXP9ka)gpLAWKcNk1x918iKAXTuBTuJZWCPEMcKx2Ru3K87w)sTiXtesTiJgHicsGLadaJISFJNsnorQDOL9k1L8Slibgbs(9ilmceaUudI9cKc4fPgasyRXVeya4sT4NmKPO5xQbaIj14is4issGLa7ql79cKpdBkA3QieVdJIQxfjBsGDOL9EbYNHnfTBveIN5VYENuSCi8XwE0pbhUgRm6NGvmfn)xGbiSKKKNsGDOL9EbYNHnfTBveI3zmxu27KsGLa7ql79QiepkmagaRWsGDOL9EveIh2XQ0yQtcSdTS3RIq8GEPOCOL9Qk5zIToflKUjflhcDOLcWkEzQKpbJCmCBEHxl4fsaDf5Zt36pWRtx4zmCBEHxlunlZr(Sk3b2L9g41Pl8ucSdTS3RIq8GEPOCOL9Qk5zITofl0jPBsXYHqhAPaSIxMk5tWihZ8cVwWlKa6kYNNU1FGxNUWZy428cVwOAwMJ8zvUdSl7nWRtx4PeyhAzVxfH4b9sr5ql7vvYZeBDkwOtEMy5qOdTuawXltL8jyKJzEHxl4fsaDf5Zt36pWRtx4zmZl8AHQzzoYNv5oWUS3aVoDHNsGDOL9EveIh0lfLdTSxvjptS1PyHNjwoe6qlfGv8YujFcg5y428cVwWlKa6kYNNU1FGxNUWZyMx41cvZYCKpRYDGDzVbED6cpLa7ql79QiepOxkkhAzVQsEMyRtXcHf2fGflhcDOLcWkEzQKpCHdjWo0YEVkcXZFOVSY6)51Kalb2Hw27fCs6Muy1Smvhz(PDsGDOL9EbNKUjRieVrXxGYLqD2NaXILdHJgIDvG(zQNj4vWrdXUaLhHeyhAzVxWjPBYkcXBu868uDa2MeyhAzVxWjPBYkcXBYUbOccOd07uILdHJgIDvG(zQNj4vWrdXUaLhHeyhAzVxWjPBYkcXdOSuuhGTjb2Hw27fCs6MSIq8O6LO7Jv0PXIbRdlSY8NGTtyuXYHqASXia7(N56gpv(DowXcyKXOXgJaS7FMRB8u535yfl8mLN7jy0aakoeWPeyhAzVxWjPBYkcX7DsRF1zFcelgSoSWkZFc2oHrflhcPXgJaS7FMRB8u535yflGrgJgBmcWU)zUUXtLFNJvSWZuEUNGrdaO4qaNsGDOL9EbNKUjRieVrXxGYLqD2NaXILdHJgIDvG(zQNj4vWrdXUaLhHeyhAzVxWjPBYkcXRAwMJ8zfDtrlwoeoAi2vb6NPEMGxbhne7cuEeXWTLqGYLiMihyLI6ziG(tWklPybjGZ4XX9STq1Smh5Zk6MIoyjeOCjIrJngbQEj6(y1a7RhEMYZ9W1aRuupdb0FcwzjfdWJkoeWz844E2wOAwMJ8zfDtrhSecuUeXWnn2yeO6LO7JvdSVE4zkp3teXJBjfRSwntwWO4Ky4E2wOAwMJ8zfDtrhSecuUesGDOL9EbNKUjRieVZyUOS3jflhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVGts3KveIhvVeDFSIonwmyDyHvM)eSDcJkwoesJngbQEj6(y1a7RhWiJrJngbQEj6(y1a7RhEMYZ9eC0qStClshAzVbQEj6(yfDACa2NbWH(zQNj4veIdbCkb2Hw27fCs6MSIq8aklffSPO8DkgSoSWkZFc2oHrflhchyLI6ziG(tWklPybjGZyJgIDvG(zQNj4vWrdXUaLhrmr(ylp6NGdlFxUev9V(PS3jjZLq5KK(7g2fyacljj5zmy3LzxDdJNzawUek7DYWZuEUxmy3LzxDdM)k7DYWZuEUx844(XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYtrib2Hw27fCs6MSIq8o(j51uNLlHyW6WcRm)jy7egvSCiC2w44NKxtDwUeHNhpFa60fogUPXgJavVeDFSAG91dpt55EsGDOL9EbNKUjRiepGYsrbBkkFNIbRdlSY8NGTtyuXYHWrdXUkq)m1Ze8k4OHyxGYJiMiPXgJavVeDFSAG91dN5qGeeaJhF0qStqhAzVbQEj6(yfDACa2NjIyI8XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYZyWUlZU6ggpZaSCju27KHNP8CVyWUlZU6gm)v27KHNP8CV4XX9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNIqcSdTS3l4K0nzfH45kkSFYVQhk43vpjWo0YEVGts3KveI3ZxVULlHY)VRkb2Hw27fCs6MSIq8GD)ZCDJNk)ohRysGDOL9EbNKUjRiepQEj6(yfDASyW6WcRm)jy7egvSCiKgBmcu9s09XQb2xpGrgp(OHyxfhAzVbGYsrbBkkFNbOFM6zcEX1OHyxGYJiECASXia7(N56gpv(DowXcyKsGDOL9EbNKUjRieV3jT(vN9jqSyW6WcRm)jy7egvcSdTS3l4K0nzfH4vnlZr(SIUPOflhcXTLqGYLqcSeyhAzVxWjpt4KDdqfeqhO3Pelhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVGtEwfH4D8tYRPolxcXG1Hfwz(tW2jmQy5qiUNTfo(j51uNLlrWsiq5seZ8NGTGLuSYA1mzCjEKa7ql79co5zveI3O415P6aSnjWo0YEVGtEwfH4981RB5sO8)7QsGDOL9EbN8SkcXRAwMQJm)0ojWo0YEVGtEwfH4b7(N56gpv(DowXKa7ql79co5zveIhqzPOoaBtcSdTS3l4KNvriEJIVaLlH6SpbIflhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVGtEwfH45kkSFYVQhk43vpjWo0YEVGtEwfH4vnlZr(SIUPOflhchyLI6ziG(tWklPybjGZ4Xhne7Qa9ZuptWRGJgIDbkpIyIC5imv1ur3u0bb6IBzHJnBlC8tYRPolxIGLqGYLi2STWXpjVM6SCjcppE(a0PlC84lhHPQMk6MIoqci)nvVCmCtJngbQEj6(y1a7RhWiJnAi2vb6NPEMGxbhne7cuEeaChAzVbGYsrbBkkFNbOFM6zcEfNilI4XTKIvwRMjly0ijb2Hw27fCYZQiepO)cWILdHo0sbyfVmvYhUIgd3p2YJ(j4WxV4aDMxaI)tb7D0y7mxc1zFceFbgGWsssEkb2Hw27fCYZQieVZyUOS3jflhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVGtEwfH4r1lr3hROtJfdwhwyL5pbBNWOILdH0yJrGQxIUpwnW(6bmYy0yJrGQxIUpwnW(6HNP8Cpbhne7e3I0Hw2BGQxIUpwrNghG9zaCOFM6zcEfH4qaNXWnn2yeQMLP6iZpTl8mLN7fpon2yeO6LO7JvdSVE4zkp3l2YryQQPIUPOdKaYFt1llb2Hw27fCYZQiepGYsrbBkkFNIbRdlSY8NGTtyuXYHWbwPOEgcO)eSYskwqc4m2OHyxfOFM6zcEfC0qSlq5rib2Hw27fCYZQieV3jT(vN9jqSyW6WcRm)jy7egvSCiKgBmcwsQ6HYaKvhj7F4mhcKWihp(STWb47Klxu0nfDWsiq5sib2Hw27fCYZQiepQEj6(yfDASy5q4STWb47Klxu0nfDWsiq5sib2Hw27fCYZQieVJFsEn1z5sigSoSWkZFc2oHrflhcFE88bOtx4yM)eSfSKIvwRMjJlXJeyhAzVxWjpRIq8QML5iFwr3u0ILdHlhHPQMk6MIoCa(o5YLyJgID4YHw2BGQxIUpwrNghG9zIdoInBlC8tYRPolxIWZuEUhUaqXHaoLa7ql79co5zveIheqhO3PojWo0YEVGtEwfH4buwkkytr57umyDyHvM)eSDcJkwoeoAi2vb6NPEMGxbhne7cuEesGDOL9EbN8SkcXRAwMJ8zfDtrlwoe(ylp6NGdF9Id0zEbi(pfS3rJTZCjuN9jq8fyacljj5PeyhAzVxWjpRIq8O6LO7Jv0PXIbRdlSY8NGTtyuXYHqASXiq1lr3hRgyF9agz84JgIDvCOL9gaklffSPO8DgG(zQNj4fxJgIDbkpcaEuamE8zBHdW3jxUOOBk6GLqGYLiECASXiunlt1rMFAx4zkp3tcSdTS3l4KNvriEVtA9Ro7tGyXG1Hfwz(tW2jmQeyhAzVxWjpRIq8QML5iFwr3u0ILdHlhHPQMk6MIoiqxCllCSzBHJFsEn1z5seSecuUeXJVCeMQAQOBk6ajG83u9YXJVCeMQAQOBk6Wb47KlxInAi2HlamssGLa7ql79c0nPWJFsEn1z5sigSoSWkZFc2oHrflhcPXgJGajj)NsaEBQWZuEUxmASXiiqsY)PeG3Mk8mLN7jibCkb2Hw27fOBYkcXdOSuuWMIY3PyW6WcRm)jy7egvSCiC0qSRc0pt9mbVcoAi2fO8iIrJngHLVlxIQ(x)u27KK5sOCss)Dd7cyKsGDOL9Eb6MSIq8QML5iFwr3u0ILdHJgIDvG(zQNj4vWrdXUaLhrmCBjeOCjInWkf1Zqa9NGvwsXcsaNsGDOL9Eb6MSIq8QMLP6iZpTtcSdTS3lq3KveI3O4lq5sOo7tGyXYHWrdXUkq)m1Ze8k4OHyxGYJqcSdTS3lq3KveI3O415P6aSnjWo0YEVaDtwriEt2navqaDGENsSCiC0qSRc0pt9mbVcoAi2fO8iKa7ql79c0nzfH4buwkQdW2Ka7ql79c0nzfH49oP1V6SpbIfdwhwyL5pbBNWOILdH0yJra29pZ1nEQ87CSIfWiJrJngby3)mx34PYVZXkw4zkp3tWObauCiGtjWo0YEVaDtwriEu9s09Xk60yXG1Hfwz(tW2jmQy5qin2yeGD)ZCDJNk)ohRybmYy0yJra29pZ1nEQ87CSIfEMYZ9emAaafhc4ucSdTS3lq3KveINROW(j)QEOGFx9Ka7ql79c0nzfH49oP1V6SpbIfdwhwyL5pbBNWOILdH0yJrWssvpugGS6iz)dN5qGegzjWo0YEVaDtwriEvZYCKpROBkAXYHWrdXUkq)m1Ze8k4OHyxGYJigUTecuUeXe5aRuupdb0FcwzjflibCgpoUNTfQML5iFwr3u0blHaLlrmASXiq1lr3hRgyF9WZuEUhUgyLI6ziG(tWklPyaEuXHaoJhh3Z2cvZYCKpROBk6GLqGYLigUPXgJavVeDFSAG91dpt55EIiEClPyL1QzYcgfNed3Z2cvZYCKpROBk6GLqGYLqcSdTS3lq3KveIhqzPOGnfLVtXG1Hfwz(tW2jmQy5q4OHyxfOFM6zcEfC0qSlq5red3p2YJ(j4WY3Llrv)RFk7DsYCjuojP)UHDbgGWsssEgp(OHyxfOFM6zcEfC0qSlq5retKI8XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYZy428cVw4mMlk7DYaVoDHNXGDxMD1nmEMby5sOS3jdpt55EXGDxMD1ny(RS3jdpt55EIiECr(ylp6NGdlFxUev9V(PS3jjZLq5KK(7g2fyacljj5zmZl8AHZyUOS3jd860fEgd2Dz2v3W4zgGLlHYENm8mLN7fd2Dz2v3G5VYENm8mLN7fd2Dz2v3Wzmxu27KHNP8CpriI4Xhne7e0Hw2BGQxIUpwrNghG9zsGDOL9Eb6MSIq8oJ5IYENuSCiC0qSRc0pt9mbVcoAi2fO8iKa7ql79c0nzfH4D8tYRPolxcXG1Hfwz(tW2jmQy5qin2yeeij5)ucWBtfWiJ9845dqNUWXJpBlC8tYRPolxIWZJNpaD6chd30yJra29pZ1nEQ87CSIfWiLa7ql79c0nzfH4981RB5sO8)7QsGDOL9Eb6MSIq8GD)ZCDJNk)ohRyILdH4MgBmcWU)zUUXtLFNJvSagPeyhAzVxGUjRiepQEj6(yfDASy5qin2yeO6LO7JvdSVEaJmE8rdXUko0YEdaLLIc2uu(odq)m1Ze8IRrdXUaLhr840yJra29pZ1nEQ87CSIfWiLa7ql79c0nzfH49oP1V6SpbIfdwhwyL5pbBNWOsGDOL9Eb6MSIq8QML5iFwr3u0ILdHZ2cvZYCKpROBk6WZJNpaD6clb2Hw27fOBYkcX74NKxtDwUeIbRdlSY8NGTtyuXYHqASXiiqsY)PeG3MkGrkbwcSdTS3laNNqa9NS7vSCi08cVwW4N6u9qXlHtWu8AbED6cpJnAi2j4OHyxGYJqcSdTS3laNxfH4rx6EQgyFDXYHqy3LzxDdWU)zUUXtLFNJvSWZuEUhUICKKa7ql79cW5vriE(c5ZEVOGEPiwoec7Um7QBa29pZ1nEQ87CSIfEMYZ9WvKJKeyhAzVxaoVkcXBKptx6Ekwoec7Um7QBa29pZ1nEQ87CSIfEMYZ9WvKJKeyhAzVxaoVkcXRKeaANs8dSjbfVMeyhAzVxaoVkcXJ2ju9qzFcb6elhcHDxMD1nauwkkytr57mmWkf1Zqa9NGvwsX4IaoLa7ql79cW5vriE08F8duUeILdHWUlZU6gGD)ZCDJNk)ohRyHNP8CpCbaIu84wsXkRvZKfmAKLa7ql79cW5vriEKTL9kwoeA(tWwWskwzTAMSGaGifpon2yeGD)ZCDJNk)ohRybmsjWo0YEVaCEveI3zmxu27KILdHp2YJ(j4WY3Llrv)RFk7DsYCjuojP)UHDbgGWsssEgB0qSRc0pt9mbVcoAi2fO8iKa7ql79cW5vriEJNzawUek7DsXYHWhB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpJnAi2vb6NPEMGxbhne7cuEesGDOL9Eb48QiepZFL9oPy5q4JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNXgne7Qa9ZuptWRGJgIDbkpI4Xhne7Qa9ZuptWRGJgIDbkpIyp2YJ(j4W1yLr)eSIPO5)cmaHLKK8mM5VYENm8mLN7jibCgd2Dz2v3WO4phEMYZ9eKaoJjshAPaSIxMk5dxrJh3HwkaR4LPs(egnMLuSYA1mzCbGIdbCkcjWo0YEVaCEveI3O4plwoeoAi2vb6NPEMGxbhne7cuEeXm)v27KbmYyp2YJ(j4W1yLr)eSIPO5)cmaHLKK8mMLuSYA1mzCjUehc4ucSdTS3laNxfH4buwkQdW2elhcDOLcWkEzQKpHrJz(tWwWskwzTAMSGJgIDIBr6ql7nq1lr3hROtJdW(mao0pt9mbVIqCiGtjWo0YEVaCEveIhvVeDFSIonwSCi0HwkaR4LPs(egnM5pbBblPyL1QzYcoAi2jUfPdTS3avVeDFSIonoa7Za4q)m1Ze8kcXHaoLa7ql79cW5vriEVtA9Ro7tGyXYHqhAPaSIxMk5ty0yM)eSfSKIvwRMjl4OHyN4wKo0YEdu9s09Xk604aSpdGd9ZuptWRiehc4ucSdTS3laNxfH45hjdnvpugGSIDIclwoeA(tWwyMN5lKXLqaGeya4snaKVJxiFsGDOL9Eb48QieVrdXoEQCag)PXkA2PelhcFpNkwaETGpNxixCjEJuSrdXobhne7cuEeaCCaGXJlshAPaSIxMk5dxrJHBZl8Ab68NNQhkYNRhpUdTuawXltL8HlCiIyIKgBmc0fSx1dL5LEVagzmASXiqxWEvpuMx69cpt55E4kYIdbCgpoUPXgJaDb7v9qzEP3lGrkcjWo0YEVaCEveIhDP7PQhkdqwXltvxSCiuKI89CQyb41c(CEHNP8CpCjEJu844(9CQyb41c(CEboI8SteXJlshAPaSIxMk5dxrJHBZl8Ab68NNQhkYNRhpUdTuawXltL8HlCicreB0qStWrdXUaLhHeyhAzVxaoVkcXJe7Zr9Cju0f)mXYHqrkY3ZPIfGxl4Z5fEMYZ9WfaisXJJ73ZPIfGxl4Z5f4iYZorepUiDOLcWkEzQKpCfngUnVWRfOZFEQEOiFUE84o0sbyfVmvYhUWHierSrdXobhne7cuEesGDOL9Eb48Qiepcm)NPVQEOCag)TbOeyhAzVxaoVkcX7tsYcRYvDKoKLa7ql79cW5vriEWEH8AVB8unkoflwoeoWkf1Zqa9NGvwsXcgvCiGtjWo0YEVaCEveINbiRWw6gBNQr)qwSCiKgBmcpdbQW3Pg9d5agPeyhAzVxaoVkcXRA)LPaCUQNVE9fYsGDOL9Eb48QieVNDYCjuJItXNy5qO5pbBbazVyagiHgUWjrkECZFc2caYEXamqcnbfIJifpU5pbBblPyL1ksOPWrKWvKJKeyhAzVxaoVkcXJIP6VUQhQcgmNQ5Zo1jwoeoAi2jOdTS3avVeDFSIonoa7ZIrJngby3)mx34PYVZXkwaJucSeyhAzVxawyxaw4XpjVM6SCjedwhwyL5pbBNWOILdHMx41cawF((POtJd860fEgJgBmccKK8Fkb4TPcpt55EXOXgJGajj)NsaEBQWZuEUNGeWPeyhAzVxawyxaUIq8QMLP6iZpTtcSdTS3lalSlaxriEpF96wUek))UQeyhAzVxawyxaUIq8QML5iFwr3u0ILdHdSsr9meq)jyLLuSGeWPeyhAzVxawyxaUIq8Ga6a9o1jb2Hw27fGf2fGRiepAmdci)1flhcNTfoaFNC5IIUPOdwcbkxIyIC2wixJ)1lk6cZZCjcN5qGeehXJpBlCa(o5YffDtrhEMYZ9eKaofHeyhAzVxawyxaUIq8G(lalwoeoBlCa(o5YffDtrhSecuUesGDOL9EbyHDb4kcXBYUbOccOd07uILdHJgIDvG(zQNj4vWrdXUaLhHeyhAzVxawyxaUIq8GD)ZCDJNk)ohRysGDOL9EbyHDb4kcXJgZGaYFDXYHqiG(tWNA8o0YE9cUWraaJb7Um7QBOAwMJ8zfDtrhgyLI6ziG(tWklPyCDKCPOm)jy7e34qcSdTS3lalSlaxriEJIVaLlH6SpbIflhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVaSWUaCfH4b9xawSCie2Dz2v3q1Smh5Zk6MIomWkf1Zqa9NGvwsX46i5srz(tW2jUXrmZl8AbVqcORiFE6w)bED6cpLa7ql79cWc7cWveIhqzPOGnfLVtXG1Hfwz(tW2jmQy5q4OHyxfOFM6zcEfC0qSlq5reBGvkQNHa6pbRSKIfKaoJjYhB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpJb7Um7QBy8mdWYLqzVtgEMYZ9Ib7Um7QBW8xzVtgEMYZ9Ihh3p2YJ(j4WY3Llrv)RFk7DsYCjuojP)UHDbgGWsssEkcjWo0YEVaSWUaCfH4vnlZr(SIUPOflhcX9STq1Smh5Zk6MIoyjeOCjKa7ql79cWc7cWveIhnMbbK)6ILdHIe3lhHPQMk6MIoCa(o5YL4XXT5fETq1Smh5ZQChyx2BGxNUWtred2Dz2v3q1Smh5Zk6MIomWkf1Zqa9NGvwsX46i5srz(tW2jUXHeyhAzVxawyxaUIq8G(lalwoec7Um7QBOAwMJ8zfDtrhgyLI6ziG(tWklPyCDKCPOm)jy7e34qcSdTS3lalSlaxriEaLLI6aSnjWo0YEVaSWUaCfH4nkEDEQoaBtcSdTS3lalSlaxriEUIc7N8R6Hc(D1tcSdTS3lalSlaxriENXCrzVtkb2Hw27fGf2fGRieVJFsEn1z5sigSoSWkZFc2oHrflhcFE88bOtx4yMx41cawF((POtJd860fEgZ8NGTGLuSYA1mzCHtKa7ql79cWc7cWveIh0FbyjWo0YEVaSWUaCfH4buwkkytr57umyDyHvM)eSDcJkwoeoAi2vb6NPEMGxbhne7cuEeXe5JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNXGDxMD1nmEMby5sOS3jdpt55EXGDxMD1ny(RS3jdpt55EXJJ7hB5r)eCy57YLOQ)1pL9ojzUekNK0F3WUadqyjjjpfHeyhAzVxawyxaUIq8o(j51uNLlHyW6WcRm)jy7egvSCi85XZhGoDHLa7ql79cWc7cWveIhvVeDFSIonwmyDyHvM)eSDcJkb2Hw27fGf2fGRieV3jT(vN9jqSyW6WcRm)jy7egvcSeyhAzVx4mHJIxNNQdW2Ka7ql79cNvriEvZYuDK5N2jb2Hw27foRIq8E(61TCju()DvjWo0YEVWzveI3XpjVM6SCjedwhwyL5pbBNWOILdH0yJrqGKK)tjaVnvaJmgn2yeeij5)ucWBtfEMYZ9eKaoJhh3wcbkxcjWo0YEVWzveI3KDdqfeqhO3Pelhchne7Qa9ZuptWRGJgIDbkpcjWo0YEVWzveI37Kw)QZ(eiwmyDyHvM)eSDcJkwoesJngbljv9qzaYQJK9pCMdbsyKLa7ql79cNvriEWU)zUUXtLFNJvmjWo0YEVWzveIhqzPOoaBtcSdTS3lCwfH4vnlZr(SIUPOflhchyLI6ziG(tWklPybjGZyJgIDvG(zQNj4vWrdXUaLhr84IC5imv1ur3u0bb6IBzHJnBlC8tYRPolxIGLqGYLi2STWXpjVM6SCjcppE(a0PlC84lhHPQMk6MIoqci)nvVCSrdXUkq)m1Ze8k4OHyxGYJaG7ql7nauwkkytr57ma9ZuptWR4e5y4MgBmcu9s09XQb2xp8mLN7jcjWo0YEVWzveI3zmxu27KILdHJgIDvG(zQNj4vWrdXUaLhHeyhAzVx4SkcXBu8fOCjuN9jqSy5q4OHyxfOFM6zcEfC0qSlq5rib2Hw27foRIq8aklffSPO8DkgSoSWkZFc2oHrflhchne7Qa9ZuptWRGJgIDbkpIyI8XwE0pbhw(UCjQ6F9tzVtsMlHYjj93nSlWaewssYZyWUlZU6ggpZaSCju27KHNP8CVyWUlZU6gm)v27KHNP8CV4XX9JT8OFcoS8D5su1)6NYENKmxcLts6VByxGbiSKKKNIqcSdTS3lCwfH4b9xawSCi0HwkaR4LPs(Wv0y4(XwE0pbh(6fhOZ8cq8FkyVJgBN5sOo7tG4lWaewssYtjWo0YEVWzveINROW(j)QEOGFx9Ka7ql79cNvriEu9s09Xk60yXG1Hfwz(tW2jmQy5q4STWb47Klxu0nfDWsiq5sepon2yeO6LO7JvdSVE4mhcKqaucSdTS3lCwfH4D8tYRPolxcXG1Hfwz(tW2jmQy5q4ZJNpaD6chpon2yeeij5)ucWBtfWiLa7ql79cNvriEvZYCKpROBkAXYHWLJWuvtfDtrhoaFNC5sSzBHJFsEn1z5seEMYZ9WfakoeWz84p2YJ(j4WxV4aDMxaI)tb7D0y7mxc1zFceFbgGWsssEkb2Hw27foRIq8Ga6a9o1jb2Hw27foRIq8O6LO7Jv0PXIbRdlSY8NGTtyuXYHqASXiq1lr3hRgyF9agz84JgIDvCOL9gaklffSPO8DgG(zQNj4fxJgIDbkpcaEuamE8zBHdW3jxUOOBk6GLqGYLqcSdTS3lCwfH49oP1V6SpbIfdwhwyL5pbBNWOsGDOL9EHZQieVQzzoYNv0nfTy5q4YryQQPIUPOdc0f3YchB2w44NKxtDwUeblHaLlr84lhHPQMk6MIoqci)nvVC84lhHPQMk6MIoCa(o5Yfe4rYqunCaGaiYqgcba]] )

end