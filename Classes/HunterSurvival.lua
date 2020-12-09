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

    spec:RegisterPack( "Survival", 20201209, [[dKuofcqiOs9iaQQUeHQ0MerFIqfnkcWPiGwfHk9krXSiuUfujSlb)cQYWeHCmrQLbO8maktJqfUgaX2aOY3iufJteQohujADeQkZJqCpcAFaQoiHQkTqcPhcvsMiavrUiavr9raQcJKqvfojavPvcvmtOsQDcilLqvvEkqtfQQVsOQQglavL9c5VKmysDyQwmsEmOjROlJAZk8zegTOYPLSAcvv0RfvnBHUnsTBL(TudhrhhG0Yv55QA6uUou2ob67IsJxeCEaSErOmFrY(jAuAe(iWPBmciGLiGLO0alr4YqIWLawIdmadbAaqYiqshM3jye460mcee7eSe0JiqshGy7te(iWVXoiJaZzg5l(WdpIYYHrfGnnEFrJfDR6fE(WW7lAiEiqkSkAaExefcC6gJacyjcyjknWseUmKiCjGL4adb6ywU(qGGfnw0TQxC15ddbMRMtEruiWj)qeiGFPge7eSe0JsT4hyRXNeha)snGNyittXNuJlftQbwIawIqGX6ThHpc0jFdHpcO0i8rG86urEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EciqhAvViWj7wofmNN)CAKHacyi8rG86urEIefb6qR6fb(8rYRPERwcei8kJVYrG4wQNTfE(i51uVvlrWky(AjK6KsT5hbBbROzL1QzXsnWLAXdcecamYkZpc2EeqPrgciadHpc0Hw1lcCeDa4P6Z1gcKxNkYtKOidbK4aHpc0Hw1lc84Vx3QLq531zrG86urEIefziGaee(iqhAvViWSvCQEY6k7rG86urEIefziGaCi8rGo0QErGWUVzTUXtL)VJfneiVovKNirrgciXdcFeOdTQxey(kgvFU2qG86urEIefziGsCe(iqEDQiprIIaHxz8vocC0qSxQZi1q)n1Xe8k1Ii1JgI9bApbeOdTQxe4i6B(AjuVDvEgziGWLi8rGo0QErGUIg7M8P6HcED2hbYRtf5jsuKHakDIq4Ja51PI8ejkceELXx5iWbwmQogMZpcwzfnl1Ii1eWPuNkLupAi2l1zKAO)M6ycELArK6rdX(aTNGuNuQfGuVCcMkBPOAAQGGD0TkYsDsPE2w45JKxt9wTebRG5RLqQtk1Z2cpFK8AQ3QLiC844pNtfzPovkPE5emv2sr10ubYC8109YsDsPg3snf2yeO7LO7NvdSdGagPuNuQhne7L6msn0FtDmbVsTis9OHyFG2tqQXfsTdTQ3q(kgvWMM23za6VPoMGxPwCLAatQfOuNkLuBfnRSwnlwQfrQtNieOdTQxey2koh1XkQMMcziGsNgHpcKxNkYtKOiq4vgFLJaDOvcYkEz6IFPg4sDAPoPuJBP(WwE0hbhoaIE(38yE(EfS3rJTZAjuVDvE(dmGIvKK8eb6qR6fbc9tqgziGsdme(iqEDQiprIIaHxz8voc0HwjiR4LPl(LAGl1PL6KsnUL6dB5rFeC4ai65FZJ557vWEhn2oRLq92v55pWakwrsYtPoPud7oo7SBiBfNJ6yfvttfgyXO6yyo)iyLv0SudCP(j5yuz(rW2l1jLAbi1WC(rWVACo0QE9OudCPgybarQtLsQNTf(CNtUCur10ubRG5RLqQfic0Hw1lcKcZG54daKHaknGHWhbYRtf5jsuei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7jGaDOv9IaFJ5OYoNeziGsloq4Ja51PI8ejkc0Hw1lcKUxIUFwrvgJaHxz8vocKcBmc09s09ZQb2bqaJuQtk1uyJrGUxIUFwnWoacht71(sTis9OHyVuJNulaP2Hw1BGUxIUFwrvghG9BsnUqQH(BQJj4vQfOulUsnbCk1jLACl1uyJriBfNQNSUY(WX0ETVuNkLutHngb6Ej6(z1a7aiCmTx7l1jL6LtWuzlfvttfiZXxt3lJaHaaJSY8JGThbuAKHaknGGWhbYRtf5jsueOdTQxey(kgvWMM23jceELXx5iWbwmQogMZpcwzfnl1Ii1eWPuNuQhne7L6msn0FtDmbVsTis9OHyFG2tabcbagzL5hbBpcO0idbuAahcFeiVovKNirrGo0QErGNtA9PE7Q8mceELXx5iqkSXiyfPQhklhREs2VWBomVuluQbmPovkPE2w4ZDo5YrfvttfScMVwceieayKvMFeS9iGsJmeqPfpi8rG86urEIefbcVY4RCe4STWN7CYLJkQMMkyfmFTeiqhAvViq6Ej6(zfvzmYqaLoXr4Ja51PI8ejkc0Hw1lc85JKxt9wTeiq4vgFLJapEC8NZPISuNuQn)iylyfnRSwnlwQbUulEqGqaGrwz(rW2JaknYqaLgxIWhbYRtf5jsuei8kJVYrGlNGPYwkQMMk85oNC5OuNuQhne7LAGl1o0QEd09s09ZkQY4aSFtQfxPgysDsPE2w45JKxt9wTeHJP9AFPg4snGi1IRutaNiqhAvViWSvCoQJvunnfYqabSeHWhb6qR6fbcZ55pN(rG86urEIefziGawAe(iqEDQiprIIaDOv9IaZxXOc200(orGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aTNacecamYkZpc2EeqPrgciGbme(iqEDQiprIIaHxz8voc8WwE0hbhoaIE(38yE(EfS3rJTZAjuVDvE(dmGIvKK8eb6qR6fbMTIZrDSIQPPqgciGbyi8rG86urEIefb6qR6fbs3lr3pROkJrGWRm(khbsHngb6Ej6(z1a7aiGrk1Psj1JgI9sDgP2Hw1BiFfJkytt77ma93uhtWRudCPE0qSpq7ji14cPonGi1Psj1Z2cFUZjxoQOAAQGvW81si1Psj1uyJriBfNQNSUY(WX0ETpcecamYkZpc2EeqPrgciGjoq4Ja51PI8ejkc0Hw1lc8CsRp1BxLNrGqaGrwz(rW2JaknYqabmabHpcKxNkYtKOiq4vgFLJaxobtLTuunnvqWo6wfzPoPupBl88rYRPERwIGvW81si1Psj1lNGPYwkQMMkqMJVMUxwQtLsQxobtLTuunnv4ZDo5YrPoPupAi2l1axQbKeHaDOv9IaZwX5Oowr10uidziqyKDbze(iGsJWhbYRtf5jsueOdTQxe4ZhjVM6TAjqGWRm(khbAEKxlKdG55VIQmoWRtf5PuNuQPWgJGGfjFVsqEB6WX0ETVuNuQPWgJGGfjFVsqEB6WX0ETVulIutaNiqiaWiRm)iy7raLgziGagcFeOdTQxey2kovpzDL9iqEDQiprIImeqagcFeOdTQxe4XFVUvlHYVRZIa51PI8ejkYqajoq4Ja51PI8ejkceELXx5iWbwmQogMZpcwzfnl1Ii1eWjc0Hw1lcmBfNJ6yfvttHmeqaccFeOdTQxeimNN)C6hbYRtf5jsuKHacWHWhbYRtf5jsuei8kJVYrGZ2cFUZjxoQOAAQGvW81si1jLAbi1Z2c1A8TEurfzEwlr4nhMxQfrQbMuNkLupBl85oNC5OIQPPcht71(sTisnbCk1ceb6qR6fbsHzWC8baYqajEq4Ja51PI8ejkceELXx5iWzBHp35KlhvunnvWky(AjqGo0QErGq)eKrgcOehHpcKxNkYtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2tab6qR6fboz3YPG588NtJmeq4se(iqhAvViqy33Sw34PY)3XIgcKxNkYtKOidbu6eHWhbYRtf5jsuei8kJVYrGWC(rWVACo0QE9OudCPgybarQtk1WUJZo7gYwX5Oowr10uHbwmQogMZpcwzfnl1axQFsogvMFeS9snEsnWqGo0QErGuygmhFaGmeqPtJWhbYRtf5jsuei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7jGaDOv9IahrFZxlH6TRYZidbuAGHWhbYRtf5jsuei8kJVYrGWUJZo7gYwX5Oowr10uHbwmQogMZpcwzfnl1axQFsogvMFeS9snEsnWK6KsT5rETGhjZ5kYJNU1xGxNkYteOdTQxei0pbzKHaknGHWhbYRtf5jsueOdTQxey(kgvWMM23jceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eK6Ks9algvhdZ5hbRSIMLArKAc4uQtk1cqQpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5PuNuQHDhND2nmoMtSAju25KHJP9AFPoPud7oo7SBW8tzNtgoM2R9L6uPKACl1h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8uQficecamYkZpc2EeqPrgcO0Ide(iqEDQiprIIaHxz8voce3s9STq2koh1XkQMMkyfmFTeiqhAvViWSvCoQJvunnfYqaLgqq4Ja51PI8ejkceELXx5iqbi14wQxobtLTuunnv4ZDo5YrPovkPg3sT5rETq2koh1XQAhyF1BGxNkYtPwGsDsPg2DC2z3q2koh1XkQMMkmWIr1XWC(rWkROzPg4s9tYXOY8JGTxQXtQbgc0Hw1lcKcZG54daKHaknGdHpcKxNkYtKOiq4vgFLJaHDhND2nKTIZrDSIQPPcdSyuDmmNFeSYkAwQbUu)KCmQm)iy7LA8KAGHaDOv9IaH(jiJmeqPfpi8rGo0QErG5Ryu95AdbYRtf5jsuKHakDIJWhb6qR6fboIoa8u95AdbYRtf5jsuKHaknUeHpc0Hw1lc0v0y3KpvpuWRZ(iqEDQiprIImeqalri8rGo0QErGVXCuzNtIa51PI8ejkYqabS0i8rG86urEIefb6qR6fb(8rYRPERwcei8kJVYrGhpo(Z5urwQtk1Mh51c5ayE(ROkJd86urEk1jLAZpc2cwrZkRvZILAGl1jocecamYkZpc2EeqPrgciGbme(iqhAvViqOFcYiqEDQiprIImeqadWq4Ja51PI8ejkc0Hw1lcmFfJkytt77ebcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EcsDsPwas9HT8OpcoS8)1sK1paELDojzTekNK0p3W(adOyfjjpL6KsnS74SZUHXXCIvlHYoNmCmTx7l1jLAy3XzNDdMFk7CYWX0ETVuNkLuJBP(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbuSIKKNsTarGqaGrwz(rW2JaknYqabmXbcFeiVovKNirrGo0QErGpFK8AQ3QLabcVY4RCe4XJJ)CovKrGqaGrwz(rW2JaknYqabmabHpcKxNkYtKOiqhAvViq6Ej6(zfvzmcecamYkZpc2EeqPrgciGb4q4Ja51PI8ejkc0Hw1lc8CsRp1BxLNrGqaGrwz(rW2JaknYqgcCYdhlAi8raLgHpc0Hw1lcKglXsSiJa51PI8ejkYqabme(iqhAvViqSNvLX0pcKxNkYtKOidbeGHWhbYRtf5jsuei8kJVYrGo0kbzfVmDXVulIudysDsPg3sT5rETGhjZ5kYJNU1xGxNkYtPoPuJBP28iVwiBfNJ6yvTdSV6nWRtf5jc0Hw1lce6XOYHw1RkwVHaJ1BQ1PzeivtImeqIde(iqEDQiprIIaHxz8voc0HwjiR4LPl(LArKAatQtk1Mh51cEKmNRipE6wFbEDQipL6KsnULAZJ8AHSvCoQJv1oW(Q3aVovKNiqhAvViqOhJkhAvVQy9gcmwVPwNMrGojvtImeqaccFeiVovKNirrGWRm(khb6qReKv8Y0f)sTisnGj1jLAZJ8AbpsMZvKhpDRVaVovKNsDsP28iVwiBfNJ6yvTdSV6nWRtf5jc0Hw1lce6XOYHw1RkwVHaJ1BQ1PzeOt(gYqab4q4Ja51PI8ejkceELXx5iqhALGSIxMU4xQfrQbmPoPuJBP28iVwWJK5Cf5Xt36lWRtf5PuNuQnpYRfYwX5Oowv7a7REd86urEIaDOv9IaHEmQCOv9QI1BiWy9MADAgb(gYqajEq4Ja51PI8ejkceELXx5iqhALGSIxMU4xQbUudmeOdTQxei0JrLdTQxvSEdbgR3uRtZiqyKDbzKHakXr4JaDOv9Ia9d6lRS(oEneiVovKNirrgYqGojvtIWhbuAe(iqhAvViWSvCQEY6k7rG86urEIefziGagcFeiVovKNirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aTNac0Hw1lcCe9nFTeQ3UkpJmeqagcFeOdTQxe4i6aWt1NRneiVovKNirrgciXbcFeiVovKNirrGWRm(khboAi2l1zKAO)M6ycELArK6rdX(aTNac0Hw1lcCYULtbZ55pNgziGaee(iqhAvViW8vmQ(CTHa51PI8ejkYqab4q4Ja51PI8ejkc0Hw1lcKUxIUFwrvgJaHxz8vocKcBmcWUVzTUXtL)VJfTagPuNuQPWgJaS7BwRB8u5)7yrlCmTx7l1Ii1PdaIulUsnbCIaHaaJSY8JGThbuAKHas8GWhbYRtf5jsueOdTQxe45KwFQ3UkpJaHxz8vocKcBmcWUVzTUXtL)VJfTagPuNuQPWgJaS7BwRB8u5)7yrlCmTx7l1Ii1PdaIulUsnbCIaHaaJSY8JGThbuAKHakXr4Ja51PI8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eqGo0QErGJOV5RLq92v5zKHacxIWhbYRtf5jsuei8kJVYrGJgI9sDgPg6VPoMGxPwePE0qSpq7ji1jLACl1wbZxlHuNuQfGupWIr1XWC(rWkROzPwePMaoL6uPKACl1Z2czR4CuhROAAQGvW81si1jLAkSXiq3lr3pRgyhaHJP9AFPg4s9algvhdZ5hbRSIMLACHuNwQfxPMaoL6uPKACl1Z2czR4CuhROAAQGvW81si1jLACl1uyJrGUxIUFwnWoacht71(sTaL6uPKAROzL1QzXsTisD6exQtk14wQNTfYwX5Oowr10ubRG5RLab6qR6fbMTIZrDSIQPPqgcO0jcHpcKxNkYtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2tab6qR6fb(gZrLDojYqaLoncFeiVovKNirrGo0QErG09s09ZkQYyei8kJVYrGuyJrGUxIUFwnWoacyKsDsPMcBmc09s09ZQb2bq4yAV2xQfrQhne7LA8KAbi1o0QEd09s09ZkQY4aSFtQXfsn0FtDmbVsTaLAXvQjGteieayKvMFeS9iGsJmeqPbgcFeiVovKNirrGo0QErG5RyubBAAFNiq4vgFLJahyXO6yyo)iyLv0SulIutaNsDsPE0qSxQZi1q)n1Xe8k1Ii1JgI9bApbPoPulaP(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbuSIKKNsDsPg2DC2z3W4yoXQLqzNtgoM2R9L6KsnS74SZUbZpLDoz4yAV2xQtLsQXTuFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWakwrsYtPwGiqiaWiRm)iy7raLgziGsdyi8rG86urEIefb6qR6fb(8rYRPERwcei8kJVYrGZ2cpFK8AQ3QLiC844pNtfzPoPuJBPMcBmc09s09ZQb2bq4yAV2hbcbagzL5hbBpcO0idbuAXbcFeiVovKNirrGo0QErG5RyubBAAFNiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2tqQtk1cqQPWgJaDVeD)SAGDaeEZH5LArKAarQtLsQhne7LArKAhAvVb6Ej6(zfvzCa2Vj1cuQtk1cqQpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5PuNuQHDhND2nmoMtSAju25KHJP9AFPoPud7oo7SBW8tzNtgoM2R9L6uPKACl1h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8uQficecamYkZpc2EeqPrgcO0accFeOdTQxeOROXUjFQEOGxN9rG86urEIefziGsd4q4JaDOv9Iap(71TAju(DDweiVovKNirrgcO0Ihe(iqhAvViqy33Sw34PY)3XIgcKxNkYtKOidbu6ehHpcKxNkYtKOiqhAvViq6Ej6(zfvzmceELXx5iqkSXiq3lr3pRgyhabmsPovkPE0qSxQZi1o0QEd5RyubBAAFNbO)M6ycELAGl1JgI9bApbPovkPMcBmcWUVzTUXtL)VJfTagjcecamYkZpc2EeqPrgcO04se(iqEDQiprIIaDOv9IapN06t92v5zeieayKvMFeS9iGsJmeqalri8rG86urEIefbcVY4RCeiULARG5RLab6qR6fbMTIZrDSIQPPqgYqGVHWhbuAe(iqhAvViWr0bGNQpxBiqEDQiprIImeqadHpc0Hw1lcmBfNQNSUYEeiVovKNirrgciadHpc0Hw1lc84Vx3QLq531zrG86urEIefziGehi8rG86urEIefb6qR6fb(8rYRPERwcei8kJVYrGuyJrqWIKVxjiVnDaJuQtk1uyJrqWIKVxjiVnD4yAV2xQfrQjGtPovkPg3sTvW81sGaHaaJSY8JGThbuAKHacqq4Ja51PI8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eqGo0QErGt2TCkyop)50idbeGdHpcKxNkYtKOiqhAvViWZjT(uVDvEgbcVY4RCeif2yeSIu1dLLJvpj7x4nhMxQfk1agcecamYkZpc2EeqPrgciXdcFeOdTQxeiS7BwRB8u5)7yrdbYRtf5jsuKHakXr4JaDOv9IaZxXO6Z1gcKxNkYtKOidbeUeHpcKxNkYtKOiq4vgFLJahyXO6yyo)iyLv0SulIutaNsDsPE0qSxQZi1q)n1Xe8k1Ii1JgI9bApbPovkPwas9YjyQSLIQPPcc2r3Qil1jL6zBHNpsEn1B1seScMVwcPoPupBl88rYRPERwIWXJJ)CovKL6uPK6LtWuzlfvttfiZXxt3ll1jL6rdXEPoJud93uhtWRulIupAi2hO9eKACHu7qR6nKVIrfSPP9DgG(BQJj4vQfxPgWK6KsnULAkSXiq3lr3pRgyhaHJP9AFPwGiqhAvViWSvCoQJvunnfYqaLori8rG86urEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EciqhAvViW3yoQSZjrgcO0Pr4Ja51PI8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eqGo0QErGJOV5RLq92v5zKHaknWq4Ja51PI8ejkc0Hw1lcmFfJkytt77ebcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EcsDsPwas9HT8OpcoS8)1sK1paELDojzTekNK0p3W(adOyfjjpL6KsnS74SZUHXXCIvlHYoNmCmTx7l1jLAy3XzNDdMFk7CYWX0ETVuNkLuJBP(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbuSIKKNsTarGqaGrwz(rW2JaknYqaLgWq4Ja51PI8ejkceELXx5iqhALGSIxMU4xQbUuNwQtk14wQpSLh9rWHdGON)npMNVxb7D0y7Swc1BxLN)adOyfjjprGo0QErGq)eKrgcO0Ide(iqEDQiprIIaHxz8voc0HwjiR4LPl(LAGl1PL6KsnUL6dB5rFeC4ai65FZJ557vWEhn2oRLq92v55pWakwrsYtPoPud7oo7SBiBfNJ6yfvttfgyXO6yyo)iyLv0SudCP(j5yuz(rW2l1jLAbi1WC(rWVACo0QE9OudCPgybarQtLsQNTf(CNtUCur10ubRG5RLqQfic0Hw1lcKcZG54daKHaknGGWhb6qR6fb6kASBYNQhk41zFeiVovKNirrgcO0aoe(iqEDQiprIIaDOv9IaP7LO7NvuLXiq4vgFLJaNTf(CNtUCur10ubRG5RLqQtLsQPWgJaDVeD)SAGDaeEZH5LAHsnGGaHaaJSY8JGThbuAKHakT4bHpcKxNkYtKOiqhAvViWNpsEn1B1sGaHxz8voc84XXFoNkYsDQusnf2yeeSi57vcYBthWirGqaGrwz(rW2JaknYqaLoXr4Ja51PI8ejkceELXx5iWLtWuzlfvttf(CNtUCuQtk1Z2cpFK8AQ3QLiCmTx7l1axQbePwCLAc4uQtLsQpSLh9rWHdGON)npMNVxb7D0y7Swc1BxLN)adOyfjjprGo0QErGzR4CuhROAAkKHaknUeHpc0Hw1lceMZZFo9Ja51PI8ejkYqabSeHWhbYRtf5jsueOdTQxeiDVeD)SIQmgbcVY4RCeif2yeO7LO7NvdSdGagPuNkLupAi2l1zKAhAvVH8vmQGnnTVZa0FtDmbVsnWL6rdX(aTNGuJlK60aIuNkLupBl85oNC5OIQPPcwbZxlbcecamYkZpc2EeqPrgciGLgHpcKxNkYtKOiqhAvViWZjT(uVDvEgbcbagzL5hbBpcO0idbeWagcFeiVovKNirrGWRm(khbUCcMkBPOAAQGGD0TkYsDsPE2w45JKxt9wTebRG5RLqQtLsQxobtLTuunnvGmhFnDVSuNkLuVCcMkBPOAAQWN7CYLJiqhAvViWSvCoQJvunnfYqgceoFe(iGsJWhbYRtf5jsuei8kJVYrGMh51cgF0VQhkEjCcMMxlWRtf5PuNuQhne7LArK6rdX(aTNac0Hw1lcmNFKDVidbeWq4Ja51PI8ejkceELXx5iqy3XzNDdWUVzTUXtL)VJfTWX0ETVudCPgWsec0Hw1lcKk29unWoaqgciadHpcKxNkYtKOiq4vgFLJaHDhND2na7(M16gpv()ow0cht71(snWLAalriqhAvViqFH8BNhvqpgrgciXbcFeiVovKNirrGWRm(khbc7oo7SBa29nR1nEQ8)DSOfoM2R9LAGl1awIqGo0QErGJ6yQy3tKHacqq4JaDOv9IaJfro7vIFInjO51qG86urEIefziGaCi8rG86urEIefbcVY4RCeiS74SZUH8vmQGnnTVZWalgvhdZ5hbRSIMLAGl1eWjc0Hw1lcKYju9qzxbZ)idbK4bHpcKxNkYtKOiq4vgFLJaHDhND2na7(M16gpv()ow0cht71(snWLAaxIK6uPKAROzL1QzXsTisDAadb6qR6fbsX3Zx(AjqgcOehHpc0Hw1lcKglXsSiJa51PI8ejkYqaHlr4Ja51PI8ejkceELXx5iqZpc2cwrZkRvZILArKAaxIK6uPKAkSXia7(M16gpv()ow0cyKiqhAvViqY2QErgcO0jcHpcKxNkYtKOiq4vgFLJapSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5PuNuQhne7L6msn0FtDmbVsTis9OHyFG2tab6qR6fb(gZrLDojYqaLoncFeiVovKNirrGWRm(khbEylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWakwrsYtPoPupAi2l1zKAO)M6ycELArK6rdX(aTNac0Hw1lcCCmNy1sOSZjrgcO0adHpcKxNkYtKOiq4vgFLJapSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5PuNuQhne7L6msn0FtDmbVsTis9OHyFG2tqQtLsQhne7L6msn0FtDmbVsTis9OHyFG2tqQtk1h2YJ(i4W3yXrFeSIPP47dmGIvKK8uQtk1MFk7CYWX0ETVulIutaNsDsPg2DC2z3Wi6hhoM2R9LArKAc4uQtk1cqQDOvcYkEz6IFPg4sDAPovkP2HwjiR4LPl(LAHsDAPoPuBfnRSwnlwQbUudisT4k1eWPulqeOdTQxeO5NYoNeziGsdyi8rG86urEIefb6qR6fboI(Xiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2tqQtk1MFk7CYagPuNuQpSLh9rWHVXIJ(iyfttX3hyafRij5PuNuQTIMvwRMfl1axQfhsT4k1eWjcmwlRGteiWaeKHakT4aHpcKxNkYtKOiq4vgFLJaDOvcYkEz6IFPwOuNwQtk1MFeSfSIMvwRMfl1Ii1JgI9snEsTaKAhAvVb6Ej6(zfvzCa2Vj14cPg6VPoMGxPwGsT4k1eWjc0Hw1lcmFfJQpxBidbuAabHpcKxNkYtKOiq4vgFLJaDOvcYkEz6IFPwOuNwQtk1MFeSfSIMvwRMfl1Ii1JgI9snEsTaKAhAvVb6Ej6(zfvzCa2Vj14cPg6VPoMGxPwGsT4k1eWjc0Hw1lcKUxIUFwrvgJmeqPbCi8rG86urEIefbcVY4RCeOdTsqwXltx8l1cL60sDsP28JGTGv0SYA1SyPwePE0qSxQXtQfGu7qR6nq3lr3pROkJdW(nPgxi1q)n1Xe8k1cuQfxPMaorGo0QErGNtA9PE7Q8mYqaLw8GWhbYRtf5jsuei8kJVYrGMFeSfM1B(czPg4cLAahc0Hw1lc0FsgAQEOSCSIDIiJmeqPtCe(iqEDQiprIIaHxz8voc88AQyb51c(C(HALAGl14Yej1jL6rdXEPwePE0qSpq7ji14cPgyaIuNkLulaP2HwjiR4LPl(LAGl1PL6KsnULAZJ8AbQ6MVQhkYJbiWRtf5PuNkLu7qReKv8Y0f)snWLAGj1cuQtk1cqQPWgJave7u9qzES3pGrk1jLAkSXiqfXovpuMh79dht71(snWLAatQfxPMaoL6uPKACl1uyJrGkIDQEOmp27hWiLAbIaDOv9Iahne75PYtm(kJvuStJmeqPXLi8rG86urEIefbcVY4RCeOaKAbi1NxtfliVwWNZpCmTx7l1axQXLjsQtLsQXTuFEnvSG8AbFo)aNq92l1cuQtLsQfGu7qReKv8Y0f)snWL60sDsPg3sT5rETavDZx1df5Xae41PI8uQtLsQDOvcYkEz6IFPg4snWKAbk1cuQtk1JgI9sTis9OHyFG2tab6qR6fbsf7EQ6HYYXkEzAaqgciGLie(iqEDQiprIIaHxz8vocuasTaK6ZRPIfKxl4Z5hoM2R9LAGl1aUej1Psj14wQpVMkwqETGpNFGtOE7LAbk1Psj1cqQDOvcYkEz6IFPg4sDAPoPuJBP28iVwGQU5R6HI8yac86urEk1Psj1o0kbzfVmDXVudCPgysTaLAbk1jL6rdXEPwePE0qSpq7jGaDOv9IajXUAaqTekQO)gYqabS0i8rGo0QErGey(nlFv9q5jgFTLdbYRtf5jsuKHacyadHpc0Hw1lc8ksYiRQv9KoKrG86urEIefziGagGHWhbYRtf5jsuei8kJVYrGdSyuDmmNFeSYkAwQfrQtl1IRutaNiqhAvViqyVqETZnEQgrNMrgciGjoq4Ja51PI8ejkceELXx5iqkSXiCmmFK)xn6dYbmseOdTQxeOLJvylvJTt1OpiJmeqadqq4JaDOv9IaZ2xCkixR64VxFHmcKxNkYtKOidbeWaCi8rG86urEIefbcVY4RCeO5hbBHCShTCbsOj1axQt8ej1Psj1MFeSfYXE0YfiHMulIqPgyjsQtLsQn)iylyfnRSwrcnfWsKudCPgWsec0Hw1lc8yNSwc1i608Jmeqat8GWhbYRtf5jsuei8kJVYrGJgI9sTisTdTQ3aDVeD)SIQmoa73K6Ksnf2yeGDFZADJNk)FhlAbmseOdTQxeint3haQEOIyWAQMh70pYqgcKQjr4JakncFeiVovKNirrGo0QErGpFK8AQ3QLabcVY4RCeif2yeeSi57vcYBthoM2R9L6Ksnf2yeeSi57vcYBthoM2R9LArKAc4ebcbagzL5hbBpcO0idbeWq4Ja51PI8ejkc0Hw1lcmFfJkytt77ebcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EcsDsPMcBmcl)FTez9dGxzNtswlHYjj9ZnSpGrIaHaaJSY8JGThbuAKHacWq4Ja51PI8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eK6KsnULARG5RLqQtk1dSyuDmmNFeSYkAwQfrQjGteOdTQxey2koh1XkQMMcziGehi8rGo0QErGzR4u9K1v2Ja51PI8ejkYqabii8rG86urEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EciqhAvViWr0381sOE7Q8mYqab4q4JaDOv9IahrhaEQ(CTHa51PI8ejkYqajEq4Ja51PI8ejkceELXx5iWrdXEPoJud93uhtWRulIupAi2hO9eqGo0QErGt2TCkyop)50idbuIJWhb6qR6fbMVIr1NRneiVovKNirrgciCjcFeiVovKNirrGo0QErGNtA9PE7Q8mceELXx5iqkSXia7(M16gpv()ow0cyKsDsPMcBmcWUVzTUXtL)VJfTWX0ETVulIuNoaisT4k1eWjcecamYkZpc2EeqPrgcO0jcHpcKxNkYtKOiqhAvViq6Ej6(zfvzmceELXx5iqkSXia7(M16gpv()ow0cyKsDsPMcBmcWUVzTUXtL)VJfTWX0ETVulIuNoaisT4k1eWjcecamYkZpc2EeqPrgcO0Pr4JaDOv9IaDfn2n5t1df86SpcKxNkYtKOidbuAGHWhbYRtf5jsueOdTQxe45KwFQ3UkpJaHxz8vocKcBmcwrQ6HYYXQNK9l8MdZl1cLAadbcbagzL5hbBpcO0idbuAadHpcKxNkYtKOiq4vgFLJahne7L6msn0FtDmbVsTis9OHyFG2tqQtk14wQTcMVwcPoPulaPEGfJQJH58JGvwrZsTisnbCk1Psj14wQNTfYwX5Oowr10ubRG5RLqQtk1uyJrGUxIUFwnWoacht71(snWL6bwmQogMZpcwzfnl14cPoTulUsnbCk1Psj14wQNTfYwX5Oowr10ubRG5RLqQtk14wQPWgJaDVeD)SAGDaeoM2R9LAbk1Psj1wrZkRvZILArK60jUuNuQXTupBlKTIZrDSIQPPcwbZxlbc0Hw1lcmBfNJ6yfvttHmeqPfhi8rG86urEIefb6qR6fbMVIrfSPP9DIaHxz8vocC0qSxQZi1q)n1Xe8k1Ii1JgI9bApbPoPuJBP(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbuSIKKNsDQus9OHyVuNrQH(BQJj4vQfrQhne7d0EcsDsPwasTaK6dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEk1jLACl1Mh51cVXCuzNtg41PI8uQtk1WUJZo7gghZjwTek7CYWX0ETVuNuQHDhND2ny(PSZjdht71(sTaL6uPKAbi1h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8uQtk1Mh51cVXCuzNtg41PI8uQtk1WUJZo7gghZjwTek7CYWX0ETVuNuQHDhND2ny(PSZjdht71(sDsPg2DC2z3WBmhv25KHJP9AFPwGsTaL6uPK6rdXEPweP2Hw1BGUxIUFwrvghG9BiqiaWiRm)iy7raLgziGsdii8rG86urEIefbcVY4RCe4OHyVuNrQH(BQJj4vQfrQhne7d0EciqhAvViW3yoQSZjrgcO0aoe(iqEDQiprIIaDOv9IaF(i51uVvlbceELXx5iqkSXiiyrY3ReK3MoGrk1jL6Jhh)5CQil1Psj1Z2cpFK8AQ3QLiC844pNtfzPoPuJBPMcBmcWUVzTUXtL)VJfTagjcecamYkZpc2EeqPrgcO0Ihe(iqhAvViWJ)EDRwcLFxNfbYRtf5jsuKHakDIJWhbYRtf5jsuei8kJVYrG4wQPWgJaS7BwRB8u5)7yrlGrIaDOv9IaHDFZADJNk)FhlAidbuACjcFeiVovKNirrGWRm(khbsHngb6Ej6(z1a7aiGrk1Psj1JgI9sDgP2Hw1BiFfJkytt77ma93uhtWRudCPE0qSpq7ji1Psj1uyJra29nR1nEQ8)DSOfWirGo0QErG09s09ZkQYyKHacyjcHpcKxNkYtKOiqhAvViWZjT(uVDvEgbcbagzL5hbBpcO0idbeWsJWhbYRtf5jsuei8kJVYrGZ2czR4CuhROAAQWXJJ)CovKrGo0QErGzR4CuhROAAkKHacyadHpcKxNkYtKOiqhAvViWNpsEn1B1sGaHxz8vocKcBmccwK89kb5TPdyKiqiaWiRm)iy7raLgzidbsEmSPPCdHpcO0i8rGo0QErGpgnDVks2qG86urEIefziGagcFeiVovKNirrGWRm(khbEylp6JGdFJfh9rWkMMIVpWakwrsYteOdTQxeO5NYoNeziGame(iqhAvViW3yoQSZjrG86urEIefzidziqb57RErabSebSeLgyjkXrGz9BRL4rGI)f)k(diaVab4H4tQLA8ZXsDrt2Nj1J(KAXPt(M4uQpgqXQJNs930Su7ywt7gpLAyoFj4piXbxxll1PfhIpPgx1RG8z8uQblACLu)aSMNGulELARLACnMl1ZsW6REL6MKp36tQfaEcuQfq6eeyqIJehX)IFf)beGxGa8q8j1sn(5yPUOj7ZK6rFsT4egzxqwCk1hdOy1XtP(BAwQDmRPDJNsnmNVe8hK4GRRLL60js8j14QEfKpJNsnyrJRK6hG18eKAXRuBTuJRXCPEwcwF1Ru3K85wFsTaWtGsTasNGadsCW11YsDAGj(KACvVcYNXtPgSOXvs9dWAEcsT4vQTwQX1yUuplbRV6vQBs(CRpPwa4jqPwaPtqGbjo46AzPonGi(KACvVcYNXtPgSOXvs9dWAEcsT4vQTwQX1yUuplbRV6vQBs(CRpPwa4jqPwaPtqGbjo46AzPonGt8j14QEfKpJNsnyrJRK6hG18eKAXRuBTuJRXCPEwcwF1Ru3K85wFsTaWtGsTasNGadsCK4i(x8R4pGa8ceGhIpPwQXphl1fnzFMup6tQfNW5loL6JbuS64Pu)nnl1oM10UXtPgMZxc(dsCW11YsDAXH4tQXv9kiFgpLAWIgxj1paR5ji1IxP2APgxJ5s9SeS(QxPUj5ZT(KAbGNaLAbKobbgK4GRRLL60aI4tQXv9kiFgpLAWIgxj1paR5ji1IxP2APgxJ5s9SeS(QxPUj5ZT(KAbGNaLAbKobbgK4GRRLL60aoXNuJR6vq(mEk1GfnUsQFawZtqQfVsT1snUgZL6zjy9vVsDtYNB9j1capbk1ciDccmiXbxxll1PtCXNuJR6vq(mEk1ItZJ8AbaFItP2APwCAEKxla4lWRtf5P4uQfq6eeyqIdUUwwQtJlfFsnUQxb5Z4PulonpYRfa8joLARLAXP5rETaGVaVovKNItPwaPtqGbjo46AzPgyjs8j14QEfKpJNsT408iVwaWN4uQTwQfNMh51ca(c86urEkoLAbKobbgK4iXr8V4xXFab4fiapeFsTuJFowQlAY(mPE0NuloDsQMuCk1hdOy1XtP(BAwQDmRPDJNsnmNVe8hK4GRRLL60PfFsnUQxb5Z4Pudw04kP(bynpbPw8k1wl14AmxQNLG1x9k1njFU1Nula8eOulG0jiWGehjoaEPj7Z4PuN4sTdTQxPowV9bjoiWNKHiGagGaiiqYRhvKrGa(LAqStWsqpk1IFGTgFsCa8l1aEIHmnfFsnUumPgyjcyjsIJehhAvVFG8yytt5wgH49y009QiztIJdTQ3pqEmSPPClJq8m)u25KIvdHh2YJ(i4W3yXrFeSIPP47dmGIvKK8uIJdTQ3pqEmSPPClJq8EJ5OYoNuIJehhAvVFgH4rJLyjwKL44qR69ZiepSNvLX0VehhAvVFgH4b9yu5qR6vfR3eBDAwivtkwne6qReKv8Y0f)IayjXT5rETGhjZ5kYJNU1xGxNkYZK428iVwiBfNJ6yvTdSV6nWRtf5PehhAvVFgH4b9yu5qR6vfR3eBDAwOts1KIvdHo0kbzfVmDXViawsZJ8AbpsMZvKhpDRVaVovKNjXT5rETq2koh1XQAhyF1BGxNkYtjoo0QE)mcXd6XOYHw1RkwVj260SqN8nXQHqhALGSIxMU4xealP5rETGhjZ5kYJNU1xGxNkYZKMh51czR4CuhRQDG9vVbEDQipL44qR69ZiepOhJkhAvVQy9MyRtZcFtSAi0HwjiR4LPl(fbWsIBZJ8AbpsMZvKhpDRVaVovKNjnpYRfYwX5Oowv7a7REd86urEkXXHw17NriEqpgvo0QEvX6nXwNMfcJSlilwne6qReKv8Y0f)ahysCCOv9(zeINFqFzL13XRjXrIJdTQ3p4KunPWSvCQEY6k7L44qR69dojvtMriEJOV5RLq92v5zXQHWrdX(mq)n1Xe8kYOHyFG2tqIJdTQ3p4KunzgH4nIoa8u95AtIJdTQ3p4KunzgH4nz3YPG588NtlwneoAi2Nb6VPoMGxrgne7d0EcsCCOv9(bNKQjZieV8vmQ(CTjXXHw17hCsQMmJq8O7LO7NvuLXIbbagzL5hbBVW0IvdHuyJra29nR1nEQ8)DSOfWitsHngby33Sw34PY)3XIw4yAV2xK0barCjGtjoo0QE)Gts1KzeI35KwFQ3UkplgeayKvMFeS9ctlwnesHngby33Sw34PY)3XIwaJmjf2yeGDFZADJNk)FhlAHJP9AFrshaeXLaoL44qR69dojvtMriEJOV5RLq92v5zXQHWrdX(mq)n1Xe8kYOHyFG2tqIJdTQ3p4KunzgH4LTIZrDSIQPPeRgchne7Za93uhtWRiJgI9bApHK42ky(AjskGbwmQogMZpcwzfnlcbCMkfUNTfYwX5Oowr10ubRG5RLijf2yeO7LO7NvdSdGWX0ETpWhyXO6yyo)iyLv0mUiT4saNPsH7zBHSvCoQJvunnvWky(AjsIBkSXiq3lr3pRgyhaHJP9AFbMkLv0SYA1SyrsN4jX9STq2koh1XkQMMkyfmFTesCCOv9(bNKQjZieV3yoQSZjfRgchne7Za93uhtWRiJgI9bApbjoo0QE)Gts1KzeIhDVeD)SIQmwmiaWiRm)iy7fMwSAiKcBmc09s09ZQb2bqaJmjf2yeO7LO7NvdSdGWX0ETViJgI9Ixb4qR6nq3lr3pROkJdW(nCb0FtDmbVcuCjGtjoo0QE)Gts1KzeIx(kgvWMM23PyqaGrwz(rW2lmTy1q4algvhdZ5hbRSIMfHaotoAi2Nb6VPoMGxrgne7d0EcjfWHT8OpcoS8)1sK1paELDojzTekNK0p3W(adOyfjjptc7oo7SByCmNy1sOSZjdht71(jHDhND2ny(PSZjdht71(PsH7dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEkqjoo0QE)Gts1KzeI3ZhjVM6TAjedcamYkZpc2EHPfRgcNTfE(i51uVvlr44XXFoNkYjXnf2yeO7LO7NvdSdGWX0ETVehhAvVFWjPAYmcXlFfJkytt77umiaWiRm)iy7fMwSAiC0qSpd0FtDmbVImAi2hO9eskakSXiq3lr3pRgyhaH3CyEraKuPgne7fXHw1BGUxIUFwrvghG9BcmPaoSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5zsy3XzNDdJJ5eRwcLDoz4yAV2pjS74SZUbZpLDoz4yAV2pvkCFylp6JGdl)FTez9dGxzNtswlHYjj9ZnSpWakwrsYtbkXXHw17hCsQMmJq8Cfn2n5t1df86SVehhAvVFWjPAYmcX74Vx3QLq531zL44qR69dojvtMriEWUVzTUXtL)VJfnjoo0QE)Gts1KzeIhDVeD)SIQmwmiaWiRm)iy7fMwSAiKcBmc09s09ZQb2bqaJmvQrdX(mo0QEd5RyubBAAFNbO)M6ycEb(OHyFG2tivkkSXia7(M16gpv()ow0cyKsCCOv9(bNKQjZieVZjT(uVDvEwmiaWiRm)iy7fMwIJdTQ3p4KunzgH4LTIZrDSIQPPeRgcXTvW81siXrIJdTQ3p4KVjCYULtbZ55pNwSAiC0qSpd0FtDmbVImAi2hO9eK44qR69do5BzeI3ZhjVM6TAjedcamYkZpc2EHPfRgcX9STWZhjVM6TAjcwbZxlrsZpc2cwrZkRvZIbU4rIJdTQ3p4KVLriEJOdapvFU2K44qR69do5BzeI3XFVUvlHYVRZkXXHw17hCY3YieVSvCQEY6k7L44qR69do5BzeIhS7BwRB8u5)7yrtIJdTQ3p4KVLriE5Ryu95AtIJdTQ3p4KVLriEJOV5RLq92v5zXQHWrdX(mq)n1Xe8kYOHyFG2tqIJdTQ3p4KVLriEUIg7M8P6HcED2xIJdTQ3p4KVLriEzR4CuhROAAkXQHWbwmQogMZpcwzfnlcbCMk1OHyFgO)M6ycEfz0qSpq7jKualNGPYwkQMMkiyhDRICYzBHNpsEn1B1seScMVwIKZ2cpFK8AQ3QLiC844pNtf5uPwobtLTuunnvGmhFnDVCsCtHngb6Ej6(z1a7aiGrMC0qSpd0FtDmbVImAi2hO9eWfo0QEd5RyubBAAFNbO)M6ycEfxatGPszfnRSwnlwK0jsIJdTQ3p4KVLriEq)eKfRgcDOvcYkEz6IFGNojUpSLh9rWHdGON)npMNVxb7D0y7Swc1BxLN)adOyfjjpL44qR69do5BzeIhfMbZXhaIvdHo0kbzfVmDXpWtNe3h2YJ(i4Wbq0Z)MhZZ3RG9oASDwlH6TRYZFGbuSIKKNjHDhND2nKTIZrDSIQPPcdSyuDmmNFeSYkAg4pjhJkZpc2(KcaMZpc(vJZHw1RhboWcasQuZ2cFUZjxoQOAAQGvW81siqjoo0QE)Gt(wgH49gZrLDoPy1q4OHyFgO)M6ycEfz0qSpq7jiXXHw17hCY3Yiep6Ej6(zfvzSyqaGrwz(rW2lmTy1qif2yeO7LO7NvdSdGagzskSXiq3lr3pRgyhaHJP9AFrgne7fVcWHw1BGUxIUFwrvghG9B4cO)M6ycEfO4saNjXnf2yeYwXP6jRRSpCmTx7Nkff2yeO7LO7NvdSdGWX0ETFYLtWuzlfvttfiZXxt3llXXHw17hCY3YieV8vmQGnnTVtXGaaJSY8JGTxyAXQHWbwmQogMZpcwzfnlcbCMC0qSpd0FtDmbVImAi2hO9eK44qR69do5BzeI35KwFQ3UkplgeayKvMFeS9ctlwnesHngbRiv9qz5y1tY(fEZH5fcyPsnBl85oNC5OIQPPcwbZxlHehhAvVFWjFlJq8O7LO7NvuLXIvdHZ2cFUZjxoQOAAQGvW81siXXHw17hCY3YieVNpsEn1B1sigeayKvMFeS9ctlwneE844pNtf5KMFeSfSIMvwRMfdCXJehhAvVFWjFlJq8YwX5Oowr10uIvdHlNGPYwkQMMk85oNC5yYrdXEG7qR6nq3lr3pROkJdW(nXfyjNTfE(i51uVvlr4yAV2h4aI4saNsCCOv9(bN8TmcXdMZZFo9lXXHw17hCY3YieV8vmQGnnTVtXGaaJSY8JGTxyAXQHWrdX(mq)n1Xe8kYOHyFG2tqIJdTQ3p4KVLriEzR4CuhROAAkXQHWdB5rFeC4ai65FZJ557vWEhn2oRLq92v55pWakwrsYtjoo0QE)Gt(wgH4r3lr3pROkJfdcamYkZpc2EHPfRgcPWgJaDVeD)SAGDaeWitLA0qSpJdTQ3q(kgvWMM23za6VPoMGxGpAi2hO9eWfPbKuPMTf(CNtUCur10ubRG5RLivkkSXiKTIt1twxzF4yAV2xIJdTQ3p4KVLriENtA9PE7Q8SyqaGrwz(rW2lmTehhAvVFWjFlJq8YwX5Oowr10uIvdHlNGPYwkQMMkiyhDRICYzBHNpsEn1B1seScMVwIuPwobtLTuunnvGmhFnDVCQulNGPYwkQMMk85oNC5yYrdXEGdijsIJehhAvVFGQjf(8rYRPERwcXGaaJSY8JGTxyAXQHqkSXiiyrY3ReK3MoCmTx7NKcBmccwK89kb5TPdht71(IqaNsCCOv9(bQMmJq8YxXOc200(ofdcamYkZpc2EHPfRgchne7Za93uhtWRiJgI9bApHKuyJry5)RLiRFa8k7CsYAjuojPFUH9bmsjoo0QE)avtMriEzR4CuhROAAkXQHWrdX(mq)n1Xe8kYOHyFG2tijUTcMVwIKdSyuDmmNFeSYkAwec4uIJdTQ3pq1KzeIx2kovpzDL9sCCOv9(bQMmJq8grFZxlH6TRYZIvdHJgI9zG(BQJj4vKrdX(aTNGehhAvVFGQjZieVr0bGNQpxBsCCOv9(bQMmJq8MSB5uWCE(ZPfRgchne7Za93uhtWRiJgI9bApbjoo0QE)avtMriE5Ryu95AtIJdTQ3pq1KzeI35KwFQ3UkplgeayKvMFeS9ctlwnesHngby33Sw34PY)3XIwaJmjf2yeGDFZADJNk)FhlAHJP9AFrshaeXLaoL44qR69dunzgH4r3lr3pROkJfdcamYkZpc2EHPfRgcPWgJaS7BwRB8u5)7yrlGrMKcBmcWUVzTUXtL)VJfTWX0ETViPdaI4saNsCCOv9(bQMmJq8Cfn2n5t1df86SVehhAvVFGQjZieVZjT(uVDvEwmiaWiRm)iy7fMwSAiKcBmcwrQ6HYYXQNK9l8MdZleWK44qR69dunzgH4LTIZrDSIQPPeRgchne7Za93uhtWRiJgI9bApHK42ky(AjskGbwmQogMZpcwzfnlcbCMkfUNTfYwX5Oowr10ubRG5RLijf2yeO7LO7NvdSdGWX0ETpWhyXO6yyo)iyLv0mUiT4saNPsH7zBHSvCoQJvunnvWky(AjsIBkSXiq3lr3pRgyhaHJP9AFbMkLv0SYA1SyrsN4jX9STq2koh1XkQMMkyfmFTesCCOv9(bQMmJq8YxXOc200(ofdcamYkZpc2EHPfRgchne7Za93uhtWRiJgI9bApHK4(WwE0hbhw()AjY6haVYoNKSwcLts6NByFGbuSIKKNPsnAi2Nb6VPoMGxrgne7d0EcjfGaoSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5zsCBEKxl8gZrLDozGxNkYZKWUJZo7gghZjwTek7CYWX0ETFsy3XzNDdMFk7CYWX0ETVatLsah2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8mP5rETWBmhv25KbEDQiptc7oo7SByCmNy1sOSZjdht71(jHDhND2ny(PSZjdht71(jHDhND2n8gZrLDoz4yAV2xGcmvQrdXErCOv9gO7LO7NvuLXby)MehhAvVFGQjZieV3yoQSZjfRgchne7Za93uhtWRiJgI9bApbjoo0QE)avtMriEpFK8AQ3QLqmiaWiRm)iy7fMwSAiKcBmccwK89kb5TPdyKjpEC8NZPICQuZ2cpFK8AQ3QLiC844pNtf5K4McBmcWUVzTUXtL)VJfTagPehhAvVFGQjZieVJ)EDRwcLFxNvIJdTQ3pq1KzeIhS7BwRB8u5)7yrtSAie3uyJra29nR1nEQ8)DSOfWiL44qR69dunzgH4r3lr3pROkJfRgcPWgJaDVeD)SAGDaeWitLA0qSpJdTQ3q(kgvWMM23za6VPoMGxGpAi2hO9esLIcBmcWUVzTUXtL)VJfTagPehhAvVFGQjZieVZjT(uVDvEwmiaWiRm)iy7fMwIJdTQ3pq1KzeIx2koh1XkQMMsSAiC2wiBfNJ6yfvttfoEC8NZPISehhAvVFGQjZieVNpsEn1B1sigeayKvMFeS9ctlwnesHngbbls(ELG820bmsjosCCOv9(b48fMZpYUxXQHqZJ8AbJp6x1dfVeobtZRf41PI8m5OHyViJgI9bApbjoo0QE)aC(zeIhvS7PAGDaiwnec7oo7SBa29nR1nEQ8)DSOfoM2R9boGLijoo0QE)aC(zeINVq(TZJkOhJIvdHWUJZo7gGDFZADJNk)FhlAHJP9AFGdyjsIJdTQ3paNFgH4nQJPIDpfRgcHDhND2na7(M16gpv()ow0cht71(ahWsKehhAvVFao)mcXlwe5Sxj(j2KGMxtIJdTQ3paNFgH4r5eQEOSRG5FXQHqy3XzNDd5RyubBAAFNHbwmQogMZpcwzfndCc4uIJdTQ3paNFgH4rX3Zx(AjeRgcHDhND2na7(M16gpv()ow0cht71(ahWLOuPSIMvwRMflsAatIJdTQ3paNFgH4rJLyjwKL44qR69dW5NriEKTv9kwneA(rWwWkAwzTAwSiaUeLkff2yeGDFZADJNk)FhlAbmsjoo0QE)aC(zeI3Bmhv25KIvdHh2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8m5OHyFgO)M6ycEfz0qSpq7jiXXHw17hGZpJq8ghZjwTek7CsXQHWdB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEMC0qSpd0FtDmbVImAi2hO9eK44qR69dW5NriEMFk7CsXQHWdB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEMC0qSpd0FtDmbVImAi2hO9esLA0qSpd0FtDmbVImAi2hO9esEylp6JGdFJfh9rWkMMIVpWakwrsYZKMFk7CYWX0ETVieWzsy3XzNDdJOFC4yAV2xec4mPaCOvcYkEz6IFGNovkhALGSIxMU4xy6KwrZkRvZIboGiUeWPaL44qR69dW5NriEJOFSyXAzfCkeyaIy1q4OHyFgO)M6ycEfz0qSpq7jK08tzNtgWitEylp6JGdFJfh9rWkMMIVpWakwrsYZKwrZkRvZIbU4qCjGtjoo0QE)aC(zeIx(kgvFU2eRgcDOvcYkEz6IFHPtA(rWwWkAwzTAwSiJgI9Ixb4qR6nq3lr3pROkJdW(nCb0FtDmbVcuCjGtjoo0QE)aC(zeIhDVeD)SIQmwSAi0HwjiR4LPl(fMoP5hbBbROzL1QzXImAi2lEfGdTQ3aDVeD)SIQmoa73Wfq)n1Xe8kqXLaoL44qR69dW5NriENtA9PE7Q8Sy1qOdTsqwXltx8lmDsZpc2cwrZkRvZIfz0qSx8kahAvVb6Ej6(zfvzCa2VHlG(BQJj4vGIlbCkXXHw17hGZpJq88NKHMQhklhRyNiYIvdHMFeSfM1B(czGleWjXbWVud45)5fYVehhAvVFao)mcXB0qSNNkpX4RmwrXoTy1q451uXcYRf858d1cCCzIsoAi2lYOHyFG2taxamajvkb4qReKv8Y0f)apDsCBEKxlqv38v9qrEmaPs5qReKv8Y0f)ahycmPaOWgJave7u9qzES3pGrMKcBmcurSt1dL5XE)WX0ETpWbmXLaotLc3uyJrGkIDQEOmp27hWifOehhAvVFao)mcXJk29u1dLLJv8Y0aiwnekabCEnvSG8AbFo)WX0ETpWXLjkvkCFEnvSG8AbFo)aNq92lWuPeGdTsqwXltx8d80jXT5rETavDZx1df5XaKkLdTsqwXltx8dCGjqbMC0qSxKrdX(aTNGehhAvVFao)mcXJe7Qba1sOOI(BIvdHcqaNxtfliVwWNZpCmTx7dCaxIsLc3NxtfliVwWNZpWjuV9cmvkb4qReKv8Y0f)apDsCBEKxlqv38v9qrEmaPs5qReKv8Y0f)ahycuGjhne7fz0qSpq7jiXXHw17hGZpJq8iW8Bw(Q6HYtm(AlNehhAvVFao)mcX7ksYiRQv9KoKL44qR69dW5NriEWEH8ANB8unIonlwneoWIr1XWC(rWkROzrslUeWPehhAvVFao)mcXZYXkSLQX2PA0hKfRgcPWgJWXW8r(F1OpihWiL44qR69dW5NriEz7lofKRvD83RVqwIJdTQ3paNFgH4DStwlHAeDA(fRgcn)iylKJ9OLlqcnGN4jkvkZpc2c5ypA5cKqteHalrPsz(rWwWkAwzTIeAkGLiGdyjsIJdTQ3paNFgH4rZ09bGQhQigSMQ5Xo9lwneoAi2lIdTQ3aDVeD)SIQmoa73ssHngby33Sw34PY)3XIwaJuIJehhAvVFagzxqw4ZhjVM6TAjedcamYkZpc2EHPfRgcnpYRfYbW88xrvgh41PI8mjf2yeeSi57vcYBthoM2R9tsHngbbls(ELG820HJP9AFriGtjoo0QE)amYUGCgH4LTIt1twxzVehhAvVFagzxqoJq8o(71TAju(DDwjoo0QE)amYUGCgH4LTIZrDSIQPPeRgchyXO6yyo)iyLv0SieWPehhAvVFagzxqoJq8G588Nt)sCCOv9(byKDb5mcXJcZG54daXQHWzBHp35KlhvunnvWky(AjskGzBHAn(wpQOImpRLi8MdZlcWsLA2w4ZDo5YrfvttfoM2R9fHaofOehhAvVFagzxqoJq8G(jilwneoBl85oNC5OIQPPcwbZxlHehhAvVFagzxqoJq8MSB5uWCE(ZPfRgchne7Za93uhtWRiJgI9bApbjoo0QE)amYUGCgH4b7(M16gpv()ow0K44qR69dWi7cYzeIhfMbZXhaIvdHWC(rWVACo0QE9iWbwaqsc7oo7SBiBfNJ6yfvttfgyXO6yyo)iyLv0mWFsogvMFeS9IxGjXXHw17hGr2fKZieVr0381sOE7Q8Sy1q4OHyFgO)M6ycEfz0qSpq7jiXXHw17hGr2fKZiepOFcYIvdHWUJZo7gYwX5Oowr10uHbwmQogMZpcwzfnd8NKJrL5hbBV4fyjnpYRf8izoxrE80T(c86urEkXXHw17hGr2fKZieV8vmQGnnTVtXGaaJSY8JGTxyAXQHWrdX(mq)n1Xe8kYOHyFG2ti5algvhdZ5hbRSIMfHaotkGdB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEMe2DC2z3W4yoXQLqzNtgoM2R9tc7oo7SBW8tzNtgoM2R9tLc3h2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8uGsCCOv9(byKDb5mcXlBfNJ6yfvttjwneI7zBHSvCoQJvunnvWky(AjK44qR69dWi7cYzeIhfMbZXhaIvdHca3lNGPYwkQMMk85oNC5yQu428iVwiBfNJ6yvTdSV6nWRtf5Patc7oo7SBiBfNJ6yfvttfgyXO6yyo)iyLv0mWFsogvMFeS9IxGjXXHw17hGr2fKZiepOFcYIvdHWUJZo7gYwX5Oowr10uHbwmQogMZpcwzfnd8NKJrL5hbBV4fysCCOv9(byKDb5mcXlFfJQpxBsCCOv9(byKDb5mcXBeDa4P6Z1MehhAvVFagzxqoJq8Cfn2n5t1df86SVehhAvVFagzxqoJq8EJ5OYoNuIJdTQ3paJSliNriEpFK8AQ3QLqmiaWiRm)iy7fMwSAi84XXFoNkYjnpYRfYbW88xrvgh41PI8mP5hbBbROzL1QzXapXL44qR69dWi7cYzeIh0pbzjoo0QE)amYUGCgH4LVIrfSPP9DkgeayKvMFeS9ctlwneoAi2Nb6VPoMGxrgne7d0EcjfWHT8OpcoS8)1sK1paELDojzTekNK0p3W(adOyfjjptc7oo7SByCmNy1sOSZjdht71(jHDhND2ny(PSZjdht71(PsH7dB5rFeCy5)RLiRFa8k7CsYAjuojPFUH9bgqXkssEkqjoo0QE)amYUGCgH498rYRPERwcXGaaJSY8JGTxyAXQHWJhh)5CQilXXHw17hGr2fKZiep6Ej6(zfvzSyqaGrwz(rW2lmTehhAvVFagzxqoJq8oN06t92v5zXGaaJSY8JGTxyAjosCCOv9(H3eoIoa8u95AtIJdTQ3p8wgH4LTIt1twxzVehhAvVF4TmcX74Vx3QLq531zL44qR69dVLriEpFK8AQ3QLqmiaWiRm)iy7fMwSAiKcBmccwK89kb5TPdyKjPWgJGGfjFVsqEB6WX0ETVieWzQu42ky(AjK44qR69dVLriEt2TCkyop)50IvdHJgI9zG(BQJj4vKrdX(aTNGehhAvVF4TmcX7CsRp1BxLNfdcamYkZpc2EHPfRgcPWgJGvKQEOSCS6jz)cV5W8cbmjoo0QE)WBzeIhS7BwRB8u5)7yrtIJdTQ3p8wgH4LVIr1NRnjoo0QE)WBzeIx2koh1XkQMMsSAiCGfJQJH58JGvwrZIqaNjhne7Za93uhtWRiJgI9bApHuPeWYjyQSLIQPPcc2r3QiNC2w45JKxt9wTebRG5RLi5STWZhjVM6TAjchpo(Z5urovQLtWuzlfvttfiZXxt3lNC0qSpd0FtDmbVImAi2hO9eWfo0QEd5RyubBAAFNbO)M6ycEfxaljUPWgJaDVeD)SAGDaeoM2R9fOehhAvVF4TmcX7nMJk7CsXQHWrdX(mq)n1Xe8kYOHyFG2tqIJdTQ3p8wgH4nI(MVwc1BxLNfRgchne7Za93uhtWRiJgI9bApbjoo0QE)WBzeIx(kgvWMM23PyqaGrwz(rW2lmTy1q4OHyFgO)M6ycEfz0qSpq7jKuah2YJ(i4WY)xlrw)a4v25KK1sOCss)Cd7dmGIvKK8mjS74SZUHXXCIvlHYoNmCmTx7Ne2DC2z3G5NYoNmCmTx7NkfUpSLh9rWHL)VwIS(bWRSZjjRLq5KK(5g2hyafRij5PaL44qR69dVLriEq)eKfRgcDOvcYkEz6IFGNojUpSLh9rWHdGON)npMNVxb7D0y7Swc1BxLN)adOyfjjpL44qR69dVLriEuygmhFaiwne6qReKv8Y0f)apDsCFylp6JGdharp)BEmpFVc27OX2zTeQ3Ukp)bgqXkssEMe2DC2z3q2koh1XkQMMkmWIr1XWC(rWkROzG)KCmQm)iy7tkayo)i4xnohAvVEe4alaiPsnBl85oNC5OIQPPcwbZxlHaL44qR69dVLriEUIg7M8P6HcED2xIJdTQ3p8wgH4r3lr3pROkJfdcamYkZpc2EHPfRgcNTf(CNtUCur10ubRG5RLivkkSXiq3lr3pRgyhaH3CyEHaIehhAvVF4TmcX75JKxt9wTeIbbagzL5hbBVW0IvdHhpo(Z5urovkkSXiiyrY3ReK3MoGrkXXHw17hElJq8YwX5Oowr10uIvdHlNGPYwkQMMk85oNC5yYzBHNpsEn1B1seoM2R9boGiUeWzQuh2YJ(i4Wbq0Z)MhZZ3RG9oASDwlH6TRYZFGbuSIKKNsCCOv9(H3Yiepyop)50VehhAvVF4TmcXJUxIUFwrvglgeayKvMFeS9ctlwnesHngb6Ej6(z1a7aiGrMk1OHyFghAvVH8vmQGnnTVZa0FtDmbVaF0qSpq7jGlsdiPsnBl85oNC5OIQPPcwbZxlHehhAvVF4TmcX7CsRp1BxLNfdcamYkZpc2EHPL44qR69dVLriEzR4CuhROAAkXQHWLtWuzlfvttfeSJUvro5STWZhjVM6TAjcwbZxlrQulNGPYwkQMMkqMJVMUxovQLtWuzlfvttf(CNtUCezidHa]] )

end