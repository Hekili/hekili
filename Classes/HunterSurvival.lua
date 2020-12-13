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

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
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
            cooldown = function () return level > 55 and 25 or 30 end,
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

        potion = "spectral_agility",

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

    spec:RegisterPack( "Survival", 20201213, [[dGKE7bqicOhbisDjcfztIKpjIenkcLoLiIvrOWRePMfH4wasSlb)cPyyeahtewgbXZaeMgGKUMiQ2gGO(gGunoaPCoarSorK08iq3dPAFeKoOisWcjOEibitKqrHpsOOQrsOOKtciswjGAMeG6Mekk1obWsjuu5PanvKsFvej0EH8xsgmPomvlgjpg0KvQlJAZk5Zqz0IkNwYQjuu0RfLMTq3gr7wXVLA4iCCruwUkpxvtNY1HQTti9DrX4juDErvRxePMpaTFIgLarlcC7gJaqicGqeGecjbqesaecaqpbqdbA5jyeiHdZ6ymcCCsgbkMTFzFsF(CfbcKWZhBFJOfb(n(bzeiqAPoNzeFsLgAWklhova2K08fjE0TQh45lJMViH0GaPWRObKAquiWTBmcaHiacrasiKearibqiaa9eazeOJB56dbcwKcieyUAV5brHa38drGaPLAXS9l7t6ZNRiKAXSWhJpjWaPLAXmyitsXNuNaierQfIaiebabgR3EeTiqN4neTiasGOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq6IJaDOv9Ga3SB5uWCE2ZjrgcaHGOfbYJtf5nsyeOdTQhe4ZhbpM6TAWqGWRm(khbkqPE3w45JGht9wnybRGzRbtQtj1MFySfSIKvwR2fl1cvQb6iqyEyKvMFyS9iasGmeaabIweOdTQhe4k655T6Z1gcKhNkYBKWidbaqfrlc0Hw1dc84Vh3Qbt531zqG84urEJegziasoIweOdTQheyMkUvprDL9iqECQiVrcJmeaazeTiqhAvpiqy33Ug34TY)3XJgcKhNkYBKWidbaqhrlc0Hw1dcmBfJQpxBiqECQiVrcJmeaaneTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bsxCeOdTQhe4k6t2AWuVDvwgziaasq0IaDOv9GaDfj(T5t1lf86mpcKhNkYBKWidbqcbarlcKhNkYBKWiq4vgFLJax4XO6yyo)WyLvKSulOuJb3snGak1RgI)sDAPg6VPogJhPwqPE1q8pq6Il1PKAXk1dlUPYukQMKkiAhDRISuNsQ3TfE(i4XuVvdwWky2AWK6us9UTWZhbpM6TAWchVo(Z5urwQbeqPEyXnvMsr1KubIC81K9WsDkPwGsnf(Afi7bR7Nvl8lFaNqQtj1RgI)sDAPg6VPogJhPwqPE1q8pq6Il1afP2Hw1tiBfJkyts6Zoa93uhJXJulgsnqi1jrQbeqP2kswzTAxSulOuNqaqGo0QEqGzQ4EvhROAskKHairceTiqECQiVrcJaHxz8voc0HwjkR4Hjl(LAHk1jK6usTaL6dF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4KHxee8gb6qR6bbc9tugziasieeTiqECQiVrcJaHxz8voc0HwjkR4Hjl(LAHk1jK6usTaL6dF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4KHxee8wQtj1WUJ7oZeYuX9Qowr1KuHfEmQogMZpmwzfjl1cvQFcogvMFyS9sDkPwSsnmNFy8RwNdTQhpk1cvQfsi5snGak172cFUZjgoQOAsQGvWS1Gj1jbb6qR6bbsHBWC8LhziasaeiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiW3yoQSZjqgcGeaveTiqECQiVrcJaDOv9Gaj7bR7NvuLXiq4vgFLJaPWxRazpyD)SAHF5d4esDkPMcFTcK9G19ZQf(LpCmPxZl1ck1RgI)snnsTyLAhAvpbYEW6(zfvzCa2Vj1afPg6VPogJhPojsTyi1yWTuNsQfOutHVwHmvCREI6k7dht618snGak1u4RvGShSUFwTWV8HJj9AEPoLupS4MktPOAsQaro(AYEyeimpmYkZpm2EeajqgcGejhrlcKhNkYBKWiqhAvpiWSvmQGnjPpBei8kJVYrGl8yuDmmNFySYkswQfuQXGBPoLuVAi(l1PLAO)M6ymEKAbL6vdX)aPloceMhgzL5hgBpcGeidbqcGmIweipovK3iHrGo0QEqGNty9PE7QSmceELXx5iqk81kyfHQxklhREc2VWBomRutxQbcPgqaL6DBHp35edhvunjvWky2AWqGW8WiRm)Wy7raKaziasa0r0Ia5XPI8gjmceELXx5iWDBHp35edhvunjvWky2AWqGo0QEqGK9G19ZkQYyKHaibqdrlcKhNkYBKWiqhAvpiWNpcEm1B1GHaHxz8voc841XFoNkYsDkP28dJTGvKSYA1UyPwOsnqhbcZdJSY8dJThbqcKHaibqcIweipovK3iHrGWRm(khboS4MktPOAsQWN7CIHJsDkPE1q8xQfQu7qR6jq2dw3pROkJdW(nPwmKAHi1PK6DBHNpcEm1B1GfoM0R5LAHk1jxQfdPgdUrGo0QEqGzQ4EvhROAskKHaqicaIweOdTQheimNN9CYhbYJtf5nsyKHaqijq0Ia5XPI8gjmc0Hw1dcmBfJkyts6ZgbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqyEyKvMFyS9iasGmeacriiArG84urEJegbcVY4RCe4Hp8QpmoC5JE238yw(EfSNvJp7AWuVDvw(dCYWlccEJaDOv9GaZuX9Qowr1KuidbGqaceTiqECQiVrcJaDOv9Gaj7bR7NvuLXiq4vgFLJaPWxRazpyD)SAHF5d4esnGak1RgI)sDAP2Hw1tiBfJkyts6Zoa93uhJXJuluPE1q8pq6Il1afPorYLAabuQ3Tf(CNtmCur1KubRGzRbtQbeqPMcFTczQ4w9e1v2hoM0R5rGW8WiRm)Wy7raKaziaecqfrlcKhNkYBKWiqhAvpiWZjS(uVDvwgbcZdJSY8dJThbqcKHaqijhrlcKhNkYBKWiq4vgFLJahwCtLPuunjvq0o6wfzPoLuVBl88rWJPERgSGvWS1Gj1acOupS4MktPOAsQaro(AYEyPgqaL6Hf3uzkfvtsf(CNtmCuQtj1RgI)sTqL6KlaiqhAvpiWmvCVQJvunjfYqgcK4yyts5gIweajq0IaDOv9GaFCsYEueSHa5XPI8gjmYqaieeTiqhAvpiqQ2SiVvRONN3zQbtzT41Ga5XPI8gjmYqaaeiArG84urEJegbcVY4RCe4Hp8Qpmo8nEC1hgRysk((aNm8IGG3iqhAvpiqZpLDobYqaaur0IaDOv9GaFJ5OYoNabYJtf5nsyKHme4MxoE0q0IaibIweOdTQheijEsN0rgbYJtf5nsyKHaqiiArGo0QEqG4pRkJjFeipovK3iHrgcaGarlcKhNkYBKWiq4vgFLJaDOvIYkEyYIFPwqPgiK6usTaLAZJ8ybpsKZvehVDRVapovK3sDkPwGsT5rESqMkUx1XQAw4F1tGhNkYBeOdTQhei0JrLdTQhvSEdbgR3uJtYiqQMaziaaQiArG84urEJegbcVY4RCeOdTsuwXdtw8l1ck1aHuNsQnpYJf8iroxrC82T(c84urEl1PKAbk1Mh5XczQ4EvhRQzH)vpbECQiVrGo0QEqGqpgvo0QEuX6neySEtnojJaDcQMaziasoIweipovK3iHrGWRm(khb6qReLv8WKf)sTGsnqi1PKAZJ8ybpsKZvehVDRVapovK3sDkP28ipwitf3R6yvnl8V6jWJtf5nc0Hw1dce6XOYHw1JkwVHaJ1BQXjzeOt8gYqaaKr0Ia5XPI8gjmceELXx5iqhALOSIhMS4xQfuQbcPoLulqP28ipwWJe5CfXXB36lWJtf5TuNsQnpYJfYuX9QowvZc)REc84urEJaDOv9GaHEmQCOv9OI1BiWy9MACsgb(gYqaa0r0Ia5XPI8gjmceELXx5iqhALOSIhMS4xQfQuleeOdTQhei0JrLdTQhvSEdbgR3uJtYiqyKDrzKHaaOHOfb6qR6bb6h0hwz9D8yiqECQiVrcJmKHaHr2fLr0IaibIweipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCeO5rESqU87ZFfvzCGhNkYBPoLutHVwbrlc(ELO80KHJj9AEPoLutHVwbrlc(ELO80KHJj9AEPwqPgdUrGW8WiRm)Wy7raKaziaecIweOdTQheyMkUvprDL9iqECQiVrcJmeaabIweOdTQhe4XFpUvdMYVRZGa5XPI8gjmYqaaur0Ia5XPI8gjmceELXx5iWfEmQogMZpmwzfjl1ck1yWnc0Hw1dcmtf3R6yfvtsHmeajhrlc0Hw1dceMZZEo5Ja5XPI8gjmYqaaKr0Ia5XPI8gjmceELXx5iWDBHp35edhvunjvWky2AWK6usTyL6DBHAm(gpQOImVRbl8MdZk1ck1crQbeqPE3w4ZDoXWrfvtsfoM0R5LAbLAm4wQtcc0Hw1dcKc3G54lpYqaa0r0Ia5XPI8gjmceELXx5iWDBHp35edhvunjvWky2AWqGo0QEqGq)eLrgcaGgIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aPloc0Hw1dcCZULtbZ5zpNeziaasq0IaDOv9GaHDF7ACJ3k)FhpAiqECQiVrcJmeajeaeTiqECQiVrcJaHxz8voceMZpm(vRZHw1JhLAHk1cjKCPoLud7oU7mtitf3R6yfvtsfw4XO6yyo)WyLvKSuluP(j4yuz(HX2l10i1cbb6qR6bbsHBWC8LhziasKarlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG0fhb6qR6bbUI(KTgm1BxLLrgcGecbrlcKhNkYBKWiq4vgFLJaHDh3DMjKPI7vDSIQjPcl8yuDmmNFySYkswQfQu)eCmQm)Wy7LAAKAHi1PKAZJ8ybpsKZvehVDRVapovK3iqhAvpiqOFIYidbqcGarlcKhNkYBKWiqhAvpiWSvmQGnjPpBei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq6Il1PK6fEmQogMZpmwzfjl1ck1yWTuNsQfRuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtj1WUJ7oZewhZjDnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618snGak1cuQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCYWlccEl1jbbcZdJSY8dJThbqcKHaibqfrlcKhNkYBKWiq4vgFLJafOuVBlKPI7vDSIQjPcwbZwdgc0Hw1dcmtf3R6yfvtsHmeajsoIweipovK3iHrGWRm(khbkwPwGs9WIBQmLIQjPcFUZjgok1acOulqP28ipwitf3R6yvnl8V6jWJtf5TuNePoLud7oU7mtitf3R6yfvtsfw4XO6yyo)WyLvKSuluP(j4yuz(HX2l10i1cbb6qR6bbsHBWC8LhziasaKr0Ia5XPI8gjmceELXx5iqy3XDNzczQ4EvhROAsQWcpgvhdZ5hgRSIKLAHk1pbhJkZpm2EPMgPwiiqhAvpiqOFIYidbqcGoIweOdTQhey2kgvFU2qG84urEJegziasa0q0IaDOv9GaxrppVvFU2qG84urEJegziasaKGOfb6qR6bb6ks8BZNQxk41zEeipovK3iHrgcaHiaiArGo0QEqGVXCuzNtGa5XPI8gjmYqaiKeiArG84urEJegb6qR6bb(8rWJPERgmei8kJVYrGhVo(Z5urwQtj1Mh5Xc5YVp)vuLXbECQiVL6usT5hgBbRizL1QDXsTqLAGgceMhgzL5hgBpcGeidbGqecIweOdTQhei0przeipovK3iHrgcaHaeiArG84urEJegb6qR6bbMTIrfSjj9zJaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bsxCPoLulwP(WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4TuNsQHDh3DMjSoMt6AWu25eHJj9AEPoLud7oU7mtW8tzNteoM0R5LAabuQfOuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtcceMhgzL5hgBpcGeidbGqaQiArG84urEJegb6qR6bb(8rWJPERgmei8kJVYrGhVo(Z5urgbcZdJSY8dJThbqcKHaqijhrlcKhNkYBKWiqhAvpiqYEW6(zfvzmceMhgzL5hgBpcGeidbGqaYiArG84urEJegb6qR6bbEoH1N6TRYYiqyEyKvMFyS9iasGmKHaPAceTiasGOfbYJtf5nsyeOdTQhe4ZhbpM6TAWqGWRm(khbsHVwbrlc(ELO80KHJj9AEPoLutHVwbrlc(ELO80KHJj9AEPwqPgdUrGW8WiRm)Wy7raKaziaecIweipovK3iHrGo0QEqGzRyubBssF2iq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG0fxQtj1u4Rvy4)RblJF5FLDobrnykNGWp3W)aobceMhgzL5hgBpcGeidbaqGOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq6Il1PKAbk1wbZwdMuNsQx4XO6yyo)WyLvKSulOuJb3iqhAvpiWmvCVQJvunjfYqaaur0IaDOv9GaZuXT6jQRShbYJtf5nsyKHai5iArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiWv0NS1GPE7QSmYqaaKr0IaDOv9GaxrppVvFU2qG84urEJegziaa6iArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiWn7wofmNN9CsKHaaOHOfb6qR6bbMTIr1NRneipovK3iHrgcaGeeTiqECQiVrcJaDOv9GapNW6t92vzzei8kJVYrGu4Rva29TRXnER8)D8OfWjK6usnf(AfGDF7ACJ3k)FhpAHJj9AEPwqPori5sTyi1yWnceMhgzL5hgBpcGeidbqcbarlcKhNkYBKWiqhAvpiqYEW6(zfvzmceELXx5iqk81ka7(214gVv()oE0c4esDkPMcFTcWUVDnUXBL)VJhTWXKEnVulOuNiKCPwmKAm4gbcZdJSY8dJThbqcKHairceTiqhAvpiqxrIFB(u9sbVoZJa5XPI8gjmYqaKqiiArG84urEJegb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRGveQEPSCS6jy)cV5WSsnDPgiqGW8WiRm)Wy7raKaziasaeiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4sDkPwGsTvWS1Gj1PKAXk1l8yuDmmNFySYkswQfuQXGBPgqaLAbk172czQ4EvhROAsQGvWS1Gj1PKAk81kq2dw3pRw4x(WXKEnVuluPEHhJQJH58dJvwrYsnqrQti1IHuJb3snGak1cuQ3TfYuX9Qowr1KubRGzRbtQtj1cuQPWxRazpyD)SAHF5dht618sDsKAabuQTIKvwR2fl1ck1jaAsDkPwGs9UTqMkUx1XkQMKkyfmBnyiqhAvpiWmvCVQJvunjfYqaKaOIOfbYJtf5nsyeOdTQhey2kgvWMK0NnceELXx5iWvdXFPoTud93uhJXJulOuVAi(hiDXL6usTaL6dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNm8IGG3snGak1RgI)sDAPg6VPogJhPwqPE1q8pq6Il1PKAXk1IvQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCYWlccEl1PKAbk1Mh5XcVXCuzNte4XPI8wQtj1WUJ7oZewhZjDnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618sDsKAabuQfRuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtj1Mh5XcVXCuzNte4XPI8wQtj1WUJ7oZewhZjDnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618sDkPg2DC3zMWBmhv25eHJj9AEPojsDsKAabuQxne)LAbLAhAvpbYEW6(zfvzCa2VHaH5Hrwz(HX2JaibYqaKi5iArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiW3yoQSZjqgcGeazeTiqECQiVrcJaDOv9GaF(i4XuVvdgceELXx5iqk81kiArW3ReLNMmGti1PK6Jxh)5CQil1acOuVBl88rWJPERgSWXRJ)CovKL6usTaLAk81ka7(214gVv()oE0c4eiqyEyKvMFyS9iasGmeaja6iArGo0QEqGh)94wnyk)UodcKhNkYBKWidbqcGgIweipovK3iHrGWRm(khbkqPMcFTcWUVDnUXBL)VJhTaobc0Hw1dce29TRXnER8)D8OHmeajasq0Ia5XPI8gjmceELXx5iqk81kq2dw3pRw4x(aoHudiGs9QH4VuNwQDOv9eYwXOc2KK(Sdq)n1Xy8i1cvQxne)dKU4snGak1u4Rva29TRXnER8)D8OfWjqGo0QEqGK9G19ZkQYyKHaqicaIweipovK3iHrGo0QEqGNty9PE7QSmceMhgzL5hgBpcGeidbGqsGOfbYJtf5nsyei8kJVYrG72czQ4EvhROAsQWXRJ)CovKrGo0QEqGzQ4EvhROAskKHaqicbrlcKhNkYBKWiqhAvpiWNpcEm1B1GHaHxz8vocKcFTcIwe89kr5Pjd4eiqyEyKvMFyS9iasGmKHaH7hrlcGeiArG84urEJegbcVY4RCeO5rESGXh5R6LIhmhJj5Xc84urEl1PK6vdXFPwqPE1q8pq6IJaDOv9GaZ5hr3dYqaieeTiqECQiVrcJaHxz8voce2DC3zMaS7BxJB8w5)74rlCmPxZl1cvQbcbab6qR6bbsf7ERw4xEKHaaiq0Ia5XPI8gjmceELXx5iqy3XDNzcWUVDnUXBL)VJhTWXKEnVuluPgieaeOdTQheOpq(TZJkOhJidbaqfrlcKhNkYBKWiq4vgFLJaHDh3DMja7(214gVv()oE0cht618sTqLAGqaqGo0QEqGR6yQy3BKHai5iArGo0QEqGXclN9kXmX3yK8yiqECQiVrcJmeaazeTiqECQiVrcJaHxz8voce2DC3zMq2kgvWMK0NDyHhJQJH58dJvwrYsTqLAm4gb6qR6bbs5yQEPSRGzFKHaaOJOfbYJtf5nsyei8kJVYrGWUJ7oZeGDF7ACJ3k)FhpAHJj9AEPwOsnqwaKAabuQTIKvwR2fl1ck1jaceOdTQheifFpFzRbdziaaAiArGo0QEqGK4jDshzeipovK3iHrgcaGeeTiqECQiVrcJaHxz8voc08dJTGvKSYA1UyPwqPgilasnGak1u4Rva29TRXnER8)D8OfWjqGo0QEqGeTv9GmeajeaeTiqECQiVrcJaHxz8voc8WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4TuNsQxne)L60sn0FtDmgpsTGs9QH4FG0fhb6qR6bb(gZrLDobYqaKibIweipovK3iHrGWRm(khbE4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtj1RgI)sDAPg6VPogJhPwqPE1q8pq6IJaDOv9GaxhZjDnyk7CcKHaiHqq0Ia5XPI8gjmceELXx5iWdF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNm8IGG3sDkPE1q8xQtl1q)n1Xy8i1ck1RgI)bsxCPgqaL6vdXFPoTud93uhJXJulOuVAi(hiDXL6us9Hp8Qpmo8nEC1hgRysk((aNm8IGG3sDkP28tzNteoM0R5LAbLAm4wQtj1WUJ7oZewr)4WXKEnVulOuJb3sDkPwSsTdTsuwXdtw8l1cvQti1acOu7qReLv8WKf)snDPoHuNsQTIKvwR2fl1cvQtUulgsngCl1jbb6qR6bbA(PSZjqgcGeabIweipovK3iHrGo0QEqGROFmceELXx5iWvdXFPoTud93uhJXJulOuVAi(hiDXL6usT5NYoNiGti1PK6dF4vFyC4B84QpmwXKu89boz4fbbVL6usTvKSYA1UyPwOsnqvQfdPgdUrGXAyfCJafsYrgcGeaveTiqECQiVrcJaHxz8voc0HwjkR4Hjl(LA6sDcPoLuB(HXwWkswzTAxSulOuVAi(l10i1IvQDOv9ei7bR7NvuLXby)MuduKAO)M6ymEK6Ki1IHuJb3iqhAvpiWSvmQ(CTHmeajsoIweipovK3iHrGWRm(khb6qReLv8WKf)snDPoHuNsQn)WylyfjRSwTlwQfuQxne)LAAKAXk1o0QEcK9G19ZkQY4aSFtQbksn0FtDmgpsDsKAXqQXGBeOdTQheizpyD)SIQmgziasaKr0Ia5XPI8gjmceELXx5iqhALOSIhMS4xQPl1jK6usT5hgBbRizL1QDXsTGs9QH4VutJulwP2Hw1tGShSUFwrvghG9BsnqrQH(BQJX4rQtIulgsngCJaDOv9GapNW6t92vzzKHaibqhrlcKhNkYBKWiq4vgFLJan)WylSR38bYsTqPl1azeOdTQheO)em0u9sz5yf7yrgzidb(gIweajq0IaDOv9GaxrppVvFU2qG84urEJegziaecIweOdTQheyMkUvprDL9iqECQiVrcJmeaabIweOdTQhe4XFpUvdMYVRZGa5XPI8gjmYqaaur0Ia5XPI8gjmc0Hw1dc85JGht9wnyiq4vgFLJaPWxRGOfbFVsuEAYaoHuNsQPWxRGOfbFVsuEAYWXKEnVulOuJb3snGak1cuQTcMTgmeimpmYkZpm2EeajqgcGKJOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq6IJaDOv9Ga3SB5uWCE2ZjrgcaGmIweipovK3iHrGo0QEqGNty9PE7QSmceELXx5iqk81kyfHQxklhREc2VWBomRutxQbceimpmYkZpm2EeajqgcaGoIweOdTQheiS7BxJB8w5)74rdbYJtf5nsyKHaaOHOfb6qR6bbMTIr1NRneipovK3iHrgcaGeeTiqECQiVrcJaHxz8vocCHhJQJH58dJvwrYsTGsngCl1PK6vdXFPoTud93uhJXJulOuVAi(hiDXLAabuQfRupS4MktPOAsQGOD0TkYsDkPE3w45JGht9wnybRGzRbtQtj172cpFe8yQ3QblC864pNtfzPgqaL6Hf3uzkfvtsfiYXxt2dl1PK6vdXFPoTud93uhJXJulOuVAi(hiDXLAGIu7qR6jKTIrfSjj9zhG(BQJX4rQfdPgiK6usTaLAk81kq2dw3pRw4x(WXKEnVuNeeOdTQheyMkUx1XkQMKcziasiaiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiW3yoQSZjqgcGejq0Ia5XPI8gjmceELXx5iWvdXFPoTud93uhJXJulOuVAi(hiDXrGo0QEqGROpzRbt92vzzKHaiHqq0Ia5XPI8gjmc0Hw1dcmBfJkyts6ZgbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4sDkPwSs9Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtgErqWBPoLud7oU7mtyDmN01GPSZjcht618sDkPg2DC3zMG5NYoNiCmPxZl1acOulqP(WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4TuNeeimpmYkZpm2EeajqgcGeabIweipovK3iHrGWRm(khb6qReLv8WKf)sTqL6esDkPwGs9Hp8QpmoC5JE238yw(EfSNvJp7AWuVDvw(dCYWlccEJaDOv9GaH(jkJmeajaQiArG84urEJegbcVY4RCeOdTsuwXdtw8l1cvQti1PKAbk1h(WR(W4WLp6zFZJz57vWEwn(SRbt92vz5pWjdVii4TuNsQHDh3DMjKPI7vDSIQjPcl8yuDmmNFySYkswQfQu)eCmQm)Wy7L6usTyLAyo)W4xTohAvpEuQfQulKqYLAabuQ3Tf(CNtmCur1KubRGzRbtQtcc0Hw1dcKc3G54lpYqaKi5iArGo0QEqGUIe)28P6LcEDMhbYJtf5nsyKHaibqgrlcKhNkYBKWiqhAvpiqYEW6(zfvzmceELXx5iWDBHp35edhvunjvWky2AWKAabuQPWxRazpyD)SAHF5dV5WSsnDPo5iqyEyKvMFyS9iasGmeaja6iArG84urEJegb6qR6bb(8rWJPERgmei8kJVYrGhVo(Z5urwQbeqPMcFTcIwe89kr5Pjd4eiqyEyKvMFyS9iasGmeajaAiArG84urEJegbcVY4RCe4WIBQmLIQjPcFUZjgok1PK6DBHNpcEm1B1GfoM0R5LAHk1jxQfdPgdULAabuQp8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtgErqWBeOdTQheyMkUx1XkQMKcziasaKGOfb6qR6bbcZ5zpN8rG84urEJegziaeIaGOfbYJtf5nsyeOdTQheizpyD)SIQmgbcVY4RCeif(Afi7bR7Nvl8lFaNqQbeqPE1q8xQtl1o0QEczRyubBssF2bO)M6ymEKAHk1RgI)bsxCPgOi1jsUudiGs9UTWN7CIHJkQMKkyfmBnyiqyEyKvMFyS9iasGmeacjbIweipovK3iHrGo0QEqGNty9PE7QSmceMhgzL5hgBpcGeidbGqecIweipovK3iHrGWRm(khboS4MktPOAsQGOD0TkYsDkPE3w45JGht9wnybRGzRbtQbeqPEyXnvMsr1KubIC81K9WsnGak1dlUPYukQMKk85oNy4ic0Hw1dcmtf3R6yfvtsHmKHaDcQMarlcGeiArGo0QEqGzQ4w9e1v2Ja5XPI8gjmYqaieeTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bsxCeOdTQhe4k6t2AWuVDvwgziaaceTiqhAvpiWv0ZZB1NRneipovK3iHrgcaGkIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aPloc0Hw1dcCZULtbZ5zpNeziasoIweOdTQhey2kgvFU2qG84urEJegziaaYiArG84urEJegb6qR6bbs2dw3pROkJrGWRm(khbsHVwby33Ug34TY)3XJwaNqQtj1u4Rva29TRXnER8)D8OfoM0R5LAbL6eHKl1IHuJb3iqyEyKvMFyS9iasGmeaaDeTiqECQiVrcJaDOv9GapNW6t92vzzei8kJVYrGu4Rva29TRXnER8)D8OfWjK6usnf(AfGDF7ACJ3k)FhpAHJj9AEPwqPori5sTyi1yWnceMhgzL5hgBpcGeidbaqdrlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG0fhb6qR6bbUI(KTgm1BxLLrgcaGeeTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bsxCPoLulqP2ky2AWK6usTyL6fEmQogMZpmwzfjl1ck1yWTudiGsTaL6DBHmvCVQJvunjvWky2AWK6usnf(Afi7bR7Nvl8lF4ysVMxQfQuVWJr1XWC(HXkRizPgOi1jKAXqQXGBPgqaLAbk172czQ4EvhROAsQGvWS1Gj1PKAbk1u4RvGShSUFwTWV8HJj9AEPojsnGak1wrYkRv7ILAbL6eanPoLulqPE3witf3R6yfvtsfScMTgmeOdTQheyMkUx1XkQMKcziasiaiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)dKU4iqhAvpiW3yoQSZjqgcGejq0Ia5XPI8gjmc0Hw1dcKShSUFwrvgJaHxz8vocKcFTcK9G19ZQf(LpGti1PKAk81kq2dw3pRw4x(WXKEnVulOuVAi(l10i1IvQDOv9ei7bR7NvuLXby)MuduKAO)M6ymEK6Ki1IHuJb3iqyEyKvMFyS9iasGmeajecIweipovK3iHrGo0QEqGzRyubBssF2iq4vgFLJax4XO6yyo)WyLvKSulOuJb3sDkPE1q8xQtl1q)n1Xy8i1ck1RgI)bsxCPoLulwP(WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4TuNsQHDh3DMjSoMt6AWu25eHJj9AEPoLud7oU7mtW8tzNteoM0R5LAabuQfOuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtcceMhgzL5hgBpcGeidbqcGarlcKhNkYBKWiqhAvpiWNpcEm1B1GHaHxz8vocC3w45JGht9wnyHJxh)5CQil1PKAbk1u4RvGShSUFwTWV8HJj9AEeimpmYkZpm2EeajqgcGeaveTiqECQiVrcJaDOv9GaZwXOc2KK(SrGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aPlUuNsQfRutHVwbYEW6(z1c)YhEZHzLAbL6Kl1acOuVAi(l1ck1o0QEcK9G19ZkQY4aSFtQtIuNsQfRuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8wQtj1WUJ7oZewhZjDnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618snGak1cuQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCYWlccEl1jbbcZdJSY8dJThbqcKHairYr0IaDOv9GaDfj(T5t1lf86mpcKhNkYBKWidbqcGmIweOdTQhe4XFpUvdMYVRZGa5XPI8gjmYqaKaOJOfb6qR6bbc7(214gVv()oE0qG84urEJegziasa0q0Ia5XPI8gjmc0Hw1dcKShSUFwrvgJaHxz8vocKcFTcK9G19ZQf(LpGti1acOuVAi(l1PLAhAvpHSvmQGnjPp7a0FtDmgpsTqL6vdX)aPlUudiGsnf(AfGDF7ACJ3k)FhpAbCceimpmYkZpm2EeajqgcGeajiArG84urEJegb6qR6bbEoH1N6TRYYiqyEyKvMFyS9iasGmeacraq0Ia5XPI8gjmceELXx5iqbk1wbZwdgc0Hw1dcmtf3R6yfvtsHmKHmeOO89vpiaeIaiebiHqeaGeeyg)MAWEeysXKcI5aaifaI5tQsTutBowQlsI(mPE1NuNu6eVLuk1hNm864Tu)njl1oU1KUXBPgMZhm(dsGfW1WsDcGAsvQfq9ikFgVLAWIuaj1F(XCXLAXKuBTulGXDPExIwF1Ju3e85wFsTyPjjsTytiEscsGLaNumPGyoaasbGy(KQul10MJL6IKOptQx9j1jLWi7IYjLs9XjdVoEl1FtYsTJBnPB8wQH58bJ)GeybCnSuNqasQsTaQhr5Z4TudwKciP(ZpMlUulMKARLAbmUl17s06REK6MGp36tQflnjrQfBcXtsqcSaUgwQtiKKQulG6ru(mEl1GfPasQ)8J5Il1IjP2APwaJ7s9UeT(QhPUj4ZT(KAXstsKAXMq8KeKalGRHL6ejpPk1cOEeLpJ3snyrkGK6p)yU4sTysQTwQfW4UuVlrRV6rQBc(CRpPwS0KePwSjepjbjWc4AyPobqoPk1cOEeLpJ3snyrkGK6p)yU4sTysQTwQfW4UuVlrRV6rQBc(CRpPwS0KePwSjepjbjWsGtkMuqmhaaPaqmFsvQLAAZXsDrs0Nj1R(K6Ks4(tkL6JtgED8wQ)MKLAh3As34TudZ5dg)bjWc4AyPobqnPk1cOEeLpJ3snyrkGK6p)yU4sTysQTwQfW4UuVlrRV6rQBc(CRpPwS0KePwSjepjbjWc4AyPorYtQsTaQhr5Z4TudwKciP(ZpMlUulMKARLAbmUl17s06REK6MGp36tQflnjrQfBcXtsqcSaUgwQtaKtQsTaQhr5Z4TudwKciP(ZpMlUulMKARLAbmUl17s06REK6MGp36tQflnjrQfBcXtsqcSe4KIjfeZbaqkaeZNuLAPM2CSuxKe9zs9QpPoP0jOAIKsP(4KHxhVL6VjzP2XTM0nEl1WC(GXFqcSaUgwQtKiPk1cOEeLpJ3snyrkGK6p)yU4sTysQTwQfW4UuVlrRV6rQBc(CRpPwS0KePwSjepjbjWsGbsrs0NXBPgOj1o0QEK6y92hKaJaFcgIaqijhOIajUEvrgbcKwQbXprlr9OulMf(y8jbgiTulMbdzsk(K6eaHisTqeaHiasGLa7qR65dehdBsk3stNMhNKShfbBsGDOv98bIJHnjLBPPtdvBwK3Qv0ZZ7m1GPSw8AKa7qR65dehdBsk3stNgZpLDoHi1I(Hp8Qpmo8nEC1hgRysk((aNm8IGG3sGDOv98bIJHnjLBPPtZBmhv25esGLa7qR65ttNgs8KoPJSeyhAvpFA60G)SQmM8La7qR65ttNgOhJkhAvpQy9MiJtY0PAcrQfDhALOSIhMS4xqGiLanpYJf8iroxrC82T(c84urENsGMh5XczQ4EvhRQzH)vpbECQiVLa7qR65ttNgOhJkhAvpQy9MiJtY0DcQMqKAr3HwjkR4Hjl(feiszEKhl4rICUI44TB9f4XPI8oLanpYJfYuX9QowvZc)REc84urElb2Hw1ZNMonqpgvo0QEuX6nrgNKP7eVjsTO7qReLv8WKf)ccePmpYJf8iroxrC82T(c84urENY8ipwitf3R6yvnl8V6jWJtf5TeyhAvpFA60a9yu5qR6rfR3ezCsM(BIul6o0krzfpmzXVGarkbAEKhl4rICUI44TB9f4XPI8oL5rESqMkUx1XQAw4F1tGhNkYBjWo0QE(00Pb6XOYHw1JkwVjY4KmDyKDrzrQfDhALOSIhMS4xOcrcSdTQNpnDA8d6dRS(oEmjWsGDOv98bNGQjONPIB1tuxzVeyhAvpFWjOAI00Pzf9jBnyQ3UkllsTOVAi(Ng6VPogJhbxne)dKU4sGDOv98bNGQjstNMv0ZZB1NRnjWo0QE(Gtq1ePPtZMDlNcMZZEoPi1I(QH4FAO)M6ymEeC1q8pq6Ilb2Hw1ZhCcQMinDAYwXO6Z1MeyhAvpFWjOAI00PHShSUFwrvglcmpmYkZpm2E6jePw0PWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWXKEnVGjcjxmWGBjWo0QE(Gtq1ePPtZ5ewFQ3UkllcmpmYkZpm2E6jePw0PWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWXKEnVGjcjxmWGBjWo0QE(Gtq1ePPtZk6t2AWuVDvwwKArF1q8pn0FtDmgpcUAi(hiDXLa7qR65dobvtKMonzQ4EvhROAskrQf9vdX)0q)n1Xy8i4QH4FG0fpLaTcMTgSuIDHhJQJH58dJvwrYcIb3acOa3TfYuX9Qowr1KubRGzRblff(Afi7bR7Nvl8lF4ysVMxOl8yuDmmNFySYksgOKqmWGBabuG72czQ4EvhROAsQGvWS1GLsGu4RvGShSUFwTWV8HJj9A(KaiGwrYkRv7IfmbqlLa3TfYuX9Qowr1KubRGzRbtcSdTQNp4eunrA608gZrLDoHi1I(QH4FAO)M6ymEeC1q8pq6Ilb2Hw1ZhCcQMinDAi7bR7NvuLXIaZdJSY8dJTNEcrQfDk81kq2dw3pRw4x(aorkk81kq2dw3pRw4x(WXKEnVGRgI)IjX6qR6jq2dw3pROkJdW(nGc0FtDmgpjrmWGBjWo0QE(Gtq1ePPtt2kgvWMK0NTiW8WiRm)Wy7PNqKArFHhJQJH58dJvwrYcIb3Pwne)td93uhJXJGRgI)bsx8uI9WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4Dky3XDNzcRJ5KUgmLDor4ysVMpfS74UZmbZpLDor4ysVMhqaf4Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtgErqW7Kib2Hw1ZhCcQMinDAE(i4XuVvdMiW8WiRm)Wy7PNqKArF3w45JGht9wnyHJxh)5CQiNsGu4RvGShSUFwTWV8HJj9AEjWo0QE(Gtq1ePPtt2kgvWMK0NTiW8WiRm)Wy7PNqKArF1q8pn0FtDmgpcUAi(hiDXtjwk81kq2dw3pRw4x(WBomRGjhqaxne)f0Hw1tGShSUFwrvghG9BjjLyp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCYWlccENc2DC3zMW6yoPRbtzNteoM0R5tb7oU7mtW8tzNteoM0R5beqbE4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8ojsGDOv98bNGQjstNgxrIFB(u9sbVoZlb2Hw1ZhCcQMinDAo(7XTAWu(DDgjWo0QE(Gtq1ePPtdS7BxJB8w5)74rtcSdTQNp4eunrA60q2dw3pROkJfbMhgzL5hgBp9eIul6u4RvGShSUFwTWV8bCcabC1q8pTdTQNq2kgvWMK0NDa6VPogJhHUAi(hiDXbeqk81ka7(214gVv()oE0c4esGDOv98bNGQjstNMZjS(uVDvwweyEyKvMFyS90tib2Hw1ZhCcQMinDAYuX9Qowr1KuIul6c0ky2AWKalb2Hw1ZhCI3OVz3YPG58SNtksTOVAi(Ng6VPogJhbxne)dKU4sGDOv98bN4T00P55JGht9wnyIaZdJSY8dJTNEcrQfDbUBl88rWJPERgSGvWS1GLY8dJTGvKSYA1UyHc0La7qR65doXBPPtZk655T6Z1MeyhAvpFWjElnDAo(7XTAWu(DDgjWo0QE(Gt8wA60KPIB1tuxzVeyhAvpFWjElnDAGDF7ACJ3k)FhpAsGDOv98bN4T00PjBfJQpxBsGDOv98bN4T00Pzf9jBnyQ3UkllsTOVAi(Ng6VPogJhbxne)dKU4sGDOv98bN4T00PXvK43MpvVuWRZ8sGDOv98bN4T00Pjtf3R6yfvtsjsTOVWJr1XWC(HXkRizbXGBabC1q8pn0FtDmgpcUAi(hiDXtj2Hf3uzkfvtsfeTJUvro1UTWZhbpM6TAWcwbZwdwQDBHNpcEm1B1GfoED8NZPImGaoS4MktPOAsQaro(AYE4ucKcFTcK9G19ZQf(LpGtKA1q8pn0FtDmgpcUAi(hiDXbko0QEczRyubBssF2bO)M6ymEedGijacOvKSYA1UybtiasGDOv98bN4T00Pb6NOSi1IUdTsuwXdtw8l0ePe4Hp8QpmoC5JE238yw(EfSNvJp7AWuVDvw(dCYWlccElb2Hw1ZhCI3stNgkCdMJV8Iul6o0krzfpmzXVqtKsGh(WR(W4WLp6zFZJz57vWEwn(SRbt92vz5pWjdVii4Dky3XDNzczQ4EvhROAsQWcpgvhdZ5hgRSIKf6tWXOY8dJTpLyH58dJF16COv94rHkKqYbeWDBHp35edhvunjvWky2AWsIeyhAvpFWjElnDAEJ5OYoNqKArF1q8pn0FtDmgpcUAi(hiDXLa7qR65doXBPPtdzpyD)SIQmweyEyKvMFyS90tisTOtHVwbYEW6(z1c)YhWjsrHVwbYEW6(z1c)YhoM0R5fC1q8xmjwhAvpbYEW6(zfvzCa2VbuG(BQJX4jjIbgCNsGu4Rvitf3QNOUY(WXKEnpGasHVwbYEW6(z1c)YhoM0R5tnS4MktPOAsQaro(AYEyjWo0QE(Gt8wA60KTIrfSjj9zlcmpmYkZpm2E6jePw0x4XO6yyo)WyLvKSGyWDQvdX)0q)n1Xy8i4QH4FG0fxcSdTQNp4eVLMonNty9PE7QSSiW8WiRm)Wy7PNqKArNcFTcwrO6LYYXQNG9l8MdZshiaeWDBHp35edhvunjvWky2AWKa7qR65doXBPPtdzpyD)SIQmwKArF3w4ZDoXWrfvtsfScMTgmjWo0QE(Gt8wA6088rWJPERgmrG5Hrwz(HX2tpHi1I(XRJ)CovKtz(HXwWkswzTAxSqb6sGDOv98bN4T00Pjtf3R6yfvtsjsTOpS4MktPOAsQWN7CIHJPwne)fQdTQNazpyD)SIQmoa73edHKA3w45JGht9wnyHJj9AEHMCXadULa7qR65doXBPPtdmNN9CYxcSdTQNp4eVLMonzRyubBssF2IaZdJSY8dJTNEcrQf9vdX)0q)n1Xy8i4QH4FG0fxcSdTQNp4eVLMonzQ4EvhROAskrQf9dF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4KHxee8wcSdTQNp4eVLMonK9G19ZkQYyrG5Hrwz(HX2tpHi1Iof(Afi7bR7Nvl8lFaNaqaxne)t7qR6jKTIrfSjj9zhG(BQJX4rORgI)bsxCGsIKdiG72cFUZjgoQOAsQGvWS1GbiGu4Rvitf3QNOUY(WXKEnVeyhAvpFWjElnDAoNW6t92vzzrG5Hrwz(HX2tpHeyhAvpFWjElnDAYuX9Qowr1KuIul6dlUPYukQMKkiAhDRICQDBHNpcEm1B1GfScMTgmabCyXnvMsr1KubIC81K9Wac4WIBQmLIQjPcFUZjgoMA1q8xOjxaKalb2Hw1ZhOAc6pFe8yQ3QbteyEyKvMFyS90tisTOtHVwbrlc(ELO80KHJj9A(uu4Rvq0IGVxjkpnz4ysVMxqm4wcSdTQNpq1ePPtt2kgvWMK0NTiW8WiRm)Wy7PNqKArF1q8pn0FtDmgpcUAi(hiDXtrHVwHH)VgSm(L)v25ee1GPCcc)Cd)d4esGDOv98bQMinDAYuX9Qowr1KuIul6RgI)PH(BQJX4rWvdX)aPlEkbAfmBnyPw4XO6yyo)WyLvKSGyWTeyhAvpFGQjstNMmvCREI6k7La7qR65dunrA60SI(KTgm1BxLLfPw0xne)td93uhJXJGRgI)bsxCjWo0QE(avtKMonRONN3QpxBsGDOv98bQMinDA2SB5uWCE2ZjfPw0xne)td93uhJXJGRgI)bsxCjWo0QE(avtKMonzRyu95AtcSdTQNpq1ePPtZ5ewFQ3UkllcmpmYkZpm2E6jePw0PWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWXKEnVGjcjxmWGBjWo0QE(avtKMonK9G19ZkQYyrG5Hrwz(HX2tpHi1Iof(AfGDF7ACJ3k)FhpAbCIuu4Rva29TRXnER8)D8OfoM0R5fmri5IbgClb2Hw1ZhOAI00PXvK43MpvVuWRZ8sGDOv98bQMinDAoNW6t92vzzrG5Hrwz(HX2tpHi1Iof(AfSIq1lLLJvpb7x4nhMLoqib2Hw1ZhOAI00Pjtf3R6yfvtsjsTOVAi(Ng6VPogJhbxne)dKU4PeOvWS1GLsSl8yuDmmNFySYkswqm4gqaf4UTqMkUx1XkQMKkyfmBnyPOWxRazpyD)SAHF5dht618cDHhJQJH58dJvwrYaLeIbgCdiGcC3witf3R6yfvtsfScMTgSucKcFTcK9G19ZQf(LpCmPxZNeab0kswzTAxSGjaAPe4UTqMkUx1XkQMKkyfmBnysGDOv98bQMinDAYwXOc2KK(SfbMhgzL5hgBp9eIul6RgI)PH(BQJX4rWvdX)aPlEkbE4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8gqaxne)td93uhJXJGRgI)bsx8uIvSh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boz4fbbVtjqZJ8yH3yoQSZjc84urENc2DC3zMW6yoPRbtzNteoM0R5tb7oU7mtW8tzNteoM0R5tcGak2dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNm8IGG3PmpYJfEJ5OYoNiWJtf5Dky3XDNzcRJ5KUgmLDor4ysVMpfS74UZmbZpLDor4ysVMpfS74UZmH3yoQSZjcht618jjjac4QH4VGo0QEcK9G19ZkQY4aSFtcSdTQNpq1ePPtZBmhv25eIul6RgI)PH(BQJX4rWvdX)aPlUeyhAvpFGQjstNMNpcEm1B1GjcmpmYkZpm2E6jePw0PWxRGOfbFVsuEAYaorQJxh)5CQidiG72cpFe8yQ3QblC864pNtf5ucKcFTcWUVDnUXBL)VJhTaoHeyhAvpFGQjstNMJ)ECRgmLFxNrcSdTQNpq1ePPtdS7BxJB8w5)74rtKArxGu4Rva29TRXnER8)D8OfWjKa7qR65dunrA60q2dw3pROkJfPw0PWxRazpyD)SAHF5d4eac4QH4FAhAvpHSvmQGnjPp7a0FtDmgpcD1q8pq6IdiGu4Rva29TRXnER8)D8OfWjKa7qR65dunrA60CoH1N6TRYYIaZdJSY8dJTNEcjWo0QE(avtKMonzQ4EvhROAskrQf9DBHmvCVQJvunjv441XFoNkYsGDOv98bQMinDAE(i4XuVvdMiW8WiRm)Wy7PNqKArNcFTcIwe89kr5Pjd4esGLa7qR65dW9tpNFeDpIul6Mh5XcgFKVQxkEWCmMKhlWJtf5DQvdXFbxne)dKU4sGDOv98b4(ttNgQy3B1c)YlsTOd7oU7mta29TRXnER8)D8OfoM0R5fkqiasGDOv98b4(ttNgFG8BNhvqpgfPw0HDh3DMja7(214gVv()oE0cht618cfieajWo0QE(aC)PPtZQoMk29wKArh2DC3zMaS7BxJB8w5)74rlCmPxZluGqaKa7qR65dW9NMonXclN9kXmX3yK8ysGDOv98b4(ttNgkht1lLDfm7lsTOd7oU7mtiBfJkyts6ZoSWJr1XWC(HXkRizHIb3sGDOv98b4(ttNgk(E(YwdMi1IoS74UZmby33Ug34TY)3XJw4ysVMxOazbaqaTIKvwR2flycGqcSdTQNpa3FA60qIN0jDKLa7qR65dW9NMoneTv9isTOB(HXwWkswzTAxSGazbaqaPWxRaS7BxJB8w5)74rlGtib2Hw1ZhG7pnDAEJ5OYoNqKAr)WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4DQvdX)0q)n1Xy8i4QH4FG0fxcSdTQNpa3FA60SoMt6AWu25eIul6h(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boz4fbbVtTAi(Ng6VPogJhbxne)dKU4sGDOv98b4(ttNgZpLDoHi1I(Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtgErqW7uRgI)PH(BQJX4rWvdX)aPloGaUAi(Ng6VPogJhbxne)dKU4Po8Hx9HXHVXJR(WyftsX3h4KHxee8oL5NYoNiCmPxZligCNc2DC3zMWk6hhoM0R5fedUtjwhALOSIhMS4xOjaeqhALOSIhMS4NEIuwrYkRv7IfAYfdm4ojsGDOv98b4(ttNMv0pwKynScUPlKKlsTOVAi(Ng6VPogJhbxne)dKU4Pm)u25ebCIuh(WR(W4W34XvFySIjP47dCYWlccENYkswzTAxSqbQIbgClb2Hw1ZhG7pnDAYwXO6Z1Mi1IUdTsuwXdtw8tprkZpm2cwrYkRv7IfC1q8xmjwhAvpbYEW6(zfvzCa2VbuG(BQJX4jjIbgClb2Hw1ZhG7pnDAi7bR7NvuLXIul6o0krzfpmzXp9ePm)WylyfjRSwTlwWvdXFXKyDOv9ei7bR7NvuLXby)gqb6VPogJNKigyWTeyhAvpFaU)00P5CcRp1BxLLfPw0DOvIYkEyYIF6jsz(HXwWkswzTAxSGRgI)IjX6qR6jq2dw3pROkJdW(nGc0FtDmgpjrmWGBjWo0QE(aC)PPtJ)em0u9sz5yf7yrwKAr38dJTWUEZhilu6azjWsGDOv98byKDrz6pFe8yQ3QbteyEyKvMFyS90tisTOBEKhlKl)(8xrvgh4XPI8off(AfeTi47vIYttgoM0R5trHVwbrlc(ELO80KHJj9AEbXGBjWo0QE(amYUOCA60KPIB1tuxzVeyhAvpFagzxuonDAo(7XTAWu(DDgjWo0QE(amYUOCA60KPI7vDSIQjPePw0x4XO6yyo)WyLvKSGyWTeyhAvpFagzxuonDAG58SNt(sGDOv98byKDr500PHc3G54lVi1I(UTWN7CIHJkQMKkyfmBnyPe7UTqngFJhvurM31GfEZHzfuiac4UTWN7CIHJkQMKkCmPxZligCNejWo0QE(amYUOCA60a9tuwKArF3w4ZDoXWrfvtsfScMTgmjWo0QE(amYUOCA60Sz3YPG58SNtksTOVAi(Ng6VPogJhbxne)dKU4sGDOv98byKDr500Pb29TRXnER8)D8Ojb2Hw1ZhGr2fLttNgkCdMJV8Iul6WC(HXVADo0QE8Oqfsi5PGDh3DMjKPI7vDSIQjPcl8yuDmmNFySYkswOpbhJkZpm2EXKqKa7qR65dWi7IYPPtZk6t2AWuVDvwwKArF1q8pn0FtDmgpcUAi(hiDXLa7qR65dWi7IYPPtd0przrQfDy3XDNzczQ4EvhROAsQWcpgvhdZ5hgRSIKf6tWXOY8dJTxmjKuMh5XcEKiNRioE7wFbECQiVLa7qR65dWi7IYPPtt2kgvWMK0NTiW8WiRm)Wy7PNqKArF1q8pn0FtDmgpcUAi(hiDXtTWJr1XWC(HXkRizbXG7uI9WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4Dky3XDNzcRJ5KUgmLDor4ysVMpfS74UZmbZpLDor4ysVMhqaf4Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtgErqW7Kib2Hw1ZhGr2fLttNMmvCVQJvunjLi1IUa3TfYuX9Qowr1KubRGzRbtcSdTQNpaJSlkNMonu4gmhF5fPw0fRahwCtLPuunjv4ZDoXWrabuGMh5XczQ4EvhRQzH)vpbECQiVtsky3XDNzczQ4EvhROAsQWcpgvhdZ5hgRSIKf6tWXOY8dJTxmjejWo0QE(amYUOCA60a9tuwKArh2DC3zMqMkUx1XkQMKkSWJr1XWC(HXkRizH(eCmQm)Wy7ftcrcSdTQNpaJSlkNMonzRyu95AtcSdTQNpaJSlkNMonRONN3QpxBsGDOv98byKDr500PXvK43MpvVuWRZ8sGDOv98byKDr500P5nMJk7CcjWo0QE(amYUOCA6088rWJPERgmrG5Hrwz(HX2tpHi1I(XRJ)CovKtzEKhlKl)(8xrvgh4XPI8oL5hgBbRizL1QDXcfOjb2Hw1ZhGr2fLttNgOFIYsGDOv98byKDr500PjBfJkyts6ZweyEyKvMFyS90tisTOVAi(Ng6VPogJhbxne)dKU4Pe7Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtgErqW7uWUJ7oZewhZjDnyk7CIWXKEnFky3XDNzcMFk7CIWXKEnpGakWdF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNm8IGG3jrcSdTQNpaJSlkNMonpFe8yQ3QbteyEyKvMFyS90tisTOF864pNtfzjWo0QE(amYUOCA60q2dw3pROkJfbMhgzL5hgBp9esGDOv98byKDr500P5CcRp1BxLLfbMhgzL5hgBp9esGLa7qR65dVrFf988w95AtcSdTQNp8wA60KPIB1tuxzVeyhAvpF4T00P54Vh3Qbt531zKa7qR65dVLMonpFe8yQ3QbteyEyKvMFyS90tisTOtHVwbrlc(ELO80KbCIuu4Rvq0IGVxjkpnz4ysVMxqm4gqafOvWS1Gjb2Hw1ZhElnDA2SB5uWCE2ZjfPw0xne)td93uhJXJGRgI)bsxCjWo0QE(WBPPtZ5ewFQ3UkllcmpmYkZpm2E6jePw0PWxRGveQEPSCS6jy)cV5WS0bcjWo0QE(WBPPtdS7BxJB8w5)74rtcSdTQNp8wA60KTIr1NRnjWo0QE(WBPPttMkUx1XkQMKsKArFHhJQJH58dJvwrYcIb3Pwne)td93uhJXJGRgI)bsxCabuSdlUPYukQMKkiAhDRICQDBHNpcEm1B1GfScMTgSu72cpFe8yQ3QblC864pNtfzabCyXnvMsr1KubIC81K9WPwne)td93uhJXJGRgI)bsxCGIdTQNq2kgvWMK0NDa6VPogJhXaisjqk81kq2dw3pRw4x(WXKEnFsKa7qR65dVLMonVXCuzNtisTOVAi(Ng6VPogJhbxne)dKU4sGDOv98H3stNMv0NS1GPE7QSSi1I(QH4FAO)M6ymEeC1q8pq6Ilb2Hw1ZhElnDAYwXOc2KK(SfbMhgzL5hgBp9eIul6RgI)PH(BQJX4rWvdX)aPlEkXE4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4KHxee8ofS74UZmH1XCsxdMYoNiCmPxZNc2DC3zMG5NYoNiCmPxZdiGc8WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjdVii4DsKa7qR65dVLMonq)eLfPw0DOvIYkEyYIFHMiLap8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtgErqWBjWo0QE(WBPPtdfUbZXxErQfDhALOSIhMS4xOjsjWdF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4KHxee8ofS74UZmHmvCVQJvunjvyHhJQJH58dJvwrYc9j4yuz(HX2NsSWC(HXVADo0QE8Oqfsi5ac4UTWN7CIHJkQMKkyfmBnyjrcSdTQNp8wA604ks8BZNQxk41zEjWo0QE(WBPPtdzpyD)SIQmweyEyKvMFyS90tisTOVBl85oNy4OIQjPcwbZwdgGasHVwbYEW6(z1c)YhEZHzPNCjWo0QE(WBPPtZZhbpM6TAWebMhgzL5hgBp9eIul6hVo(Z5urgqaPWxRGOfbFVsuEAYaoHeyhAvpF4T00Pjtf3R6yfvtsjsTOpS4MktPOAsQWN7CIHJP2TfE(i4XuVvdw4ysVMxOjxmWGBab8WhE1hghU8rp7BEmlFVc2ZQXNDnyQ3Ukl)boz4fbbVLa7qR65dVLMonWCE2ZjFjWo0QE(WBPPtdzpyD)SIQmweyEyKvMFyS90tisTOtHVwbYEW6(z1c)YhWjaeWvdX)0o0QEczRyubBssF2bO)M6ymEe6QH4FG0fhOKi5ac4UTWN7CIHJkQMKkyfmBnysGDOv98H3stNMZjS(uVDvwweyEyKvMFyS90tib2Hw1ZhElnDAYuX9Qowr1KuIul6dlUPYukQMKkiAhDRICQDBHNpcEm1B1GfScMTgmabCyXnvMsr1KubIC81K9Wac4WIBQmLIQjPcFUZjgoImKHqa]] )

end