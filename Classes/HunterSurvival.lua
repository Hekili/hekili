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

    spec:RegisterPack( "Survival", 20201220, [[dCKV7bqieLEeGG6seeztIOpjcbJIqPtjcSkcfELi1Sie3cqu7sWVqeddqYXejldrXZaKAAacDnrO2gGiFJqrghbbNteIwhGaZdr19iW(iiDqriKfsq9qccnrcff(iHIQgjHIIojGGSsa1mjiQDcGLsOOYtbAQisFLqrP9c5VKmysDyQwmsEmOjRuxg1MvYNHYOfvoTKvlcH61IsZwOBJu7wXVLA4iCCrqlxLNRQPt56q12jK(UOy8eQoVOQ1lcP5dq7NOrPqKIa3UXiaidqrgGkfzidqfaQezIbIjofc0YtWiqchM1Xye440mcee)eTe1JiqcpFS9nIue434hKrGaHL6CMr8abKqcwz5WPcWMMKVOXJUv9apFzK8fnKeeifEfnGqdIcbUDJraqgGImavkYqgGkaujYedebIcbeOJB56dbcw0creyUAV5brHa38drGaHLAq8t0supk1IzIpgFsGbcl1IzWqMMIpPMmaLisnzakYauiWy92Jifb6eVHifbqkePiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i1Kl1RgI)bAxCeOdTQhe4MDlNcMZZEonYqaqgePiqECQiVrcJaDOv9GaF(i4XuVvdgceELXx5iqYk172cpFe8yQ3QblyfmBnysDsP28dJTGv0SYA1UyPwOsTycbcZdJSY8dJThbqkKHaaOrKIaDOv9GaxrppVvFU2qG84urEJegziaaIisrGo0QEqGh)94wnyk)UodcKhNkYBKWidbqIrKIaDOv9GaZuXT6jQRShbYJtf5nsyKHaaiHifb6qR6bbc7(214gVv()oE0qG84urEJegziaetisrGo0QEqGzRyu95AdbYJtf5nsyKHaqiGifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaxrFYwdM6TRYYidbqIerkc0Hw1dc0v043MpvVuWRZ8iqECQiVrcJmeaPakePiqECQiVrcJaHxz8vocCHhJQJH58dJvwrZsn5sngCl1acOuVAi(l1PLAO)M6ymEKAYL6vdX)aTlUuNuQfRupS4MktPOAAQGOD0TkYsDsPE3w45JGht9wnybRGzRbtQtk172cpFe8yQ3QblC864pNtfzPgqaL6Hf3uzkfvttfiYXxt3dl1jLAYk1u4RvGUhSUFwTWV8bCcPoPuVAi(l1PLAO)M6ymEKAYL6vdX)aTlUudKLAhAvpHSvmQGnnTp7a0FtDmgpsTyi1aTuNaPgqaLAROzL1QDXsn5sDkGcb6qR6bbMPI7vDSIQPPqgcGuPqKIa5XPI8gjmceELXx5iqhALOSIhMU4xQfQuNsQtk1KvQp8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtiErqWBeOdTQhei0przKHaifzqKIa5XPI8gjmceELXx5iqhALOSIhMU4xQfQuNsQtk1KvQp8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtiErqWBPoPud7oU7mtitf3R6yfvttfw4XO6yyo)WyLv0SuluP(j4yuz(HX2l1jLAXk1WC(HXVADo0QE8OuluPMmHel1acOuVBl85oNy4OIQPPcwbZwdMuNaeOdTQheifUbZXxEKHaifqJifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaFJ5OYoNaziasberKIa5XPI8gjmc0Hw1dcKUhSUFwrvgJaHxz8vocKcFTc09G19ZQf(LpGti1jLAk81kq3dw3pRw4x(WX0EnVutUuVAi(l1Ki1IvQDOv9eO7bR7NvuLXby)MudKLAO)M6ymEK6ei1IHuJb3sDsPMSsnf(AfYuXT6jQRSpCmTxZl1acOutHVwb6EW6(z1c)YhoM2R5L6Ks9WIBQmLIQPPce54RP7HrGW8WiRm)Wy7raKcziasLyePiqECQiVrcJaDOv9GaZwXOc200(SrGWRm(khbUWJr1XWC(HXkROzPMCPgdUL6Ks9QH4VuNwQH(BQJX4rQjxQxne)d0U4iqyEyKvMFyS9iasHmeaPasisrG84urEJegb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRGveQEPSCS6jy)cV5WSsTaPgOLAabuQ3Tf(CNtmCur10ubRGzRbdbcZdJSY8dJThbqkKHaiLycrkcKhNkYBKWiq4vgFLJa3Tf(CNtmCur10ubRGzRbdb6qR6bbs3dw3pROkJrgcGucbePiqECQiVrcJaDOv9GaF(i4XuVvdgceELXx5iWJxh)5CQil1jLAZpm2cwrZkRv7ILAHk1IjeimpmYkZpm2EeaPqgcGujsePiqECQiVrcJaHxz8vocCyXnvMsr10uHp35edhL6Ks9QH4VuluP2Hw1tGUhSUFwrvghG9BsTyi1KrQtk172cpFe8yQ3QblCmTxZl1cvQtSulgsngCJaDOv9GaZuX9Qowr10uidbazakePiqhAvpiqyop750pcKhNkYBKWidbazsHifbYJtf5nsyeOdTQhey2kgvWMM2NnceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXrGW8WiRm)Wy7raKcziaidzqKIa5XPI8gjmceELXx5iWdF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4eIxee8gb6qR6bbMPI7vDSIQPPqgcaYa0isrG84urEJegb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YhWjKAabuQxne)L60sTdTQNq2kgvWMM2NDa6VPogJhPwOs9QH4FG2fxQbYsDQel1acOuVBl85oNy4OIQPPcwbZwdMudiGsnf(AfYuXT6jQRSpCmTxZJaH5Hrwz(HX2JaifYqaqgGiIueipovK3iHrGo0QEqGNty9PE7QSmceMhgzL5hgBpcGuidbazsmIueipovK3iHrGWRm(khboS4MktPOAAQGOD0TkYsDsPE3w45JGht9wnybRGzRbtQbeqPEyXnvMsr10ubIC8109WsnGak1dlUPYukQMMk85oNy4OuNuQxne)LAHk1jgOqGo0QEqGzQ4EvhROAAkKHmeOtq1eisraKcrkc0Hw1dcmtf3QNOUYEeipovK3iHrgcaYGifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaxrFYwdM6TRYYidbaqJifb6qR6bbUIEEER(CTHa5XPI8gjmYqaaerKIa5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXrGo0QEqGB2TCkyop750idbqIrKIaDOv9GaZwXO6Z1gcKhNkYBKWidbaqcrkcKhNkYBKWiqhAvpiq6EW6(zfvzmceELXx5iqk81ka7(214gVv()oE0c4esDsPMcFTcWUVDnUXBL)VJhTWX0EnVutUuNkKyPwmKAm4gbcZdJSY8dJThbqkKHaqmHifbYJtf5nsyeOdTQhe45ewFQ3UklJaHxz8vocKcFTcWUVDnUXBL)VJhTaoHuNuQPWxRaS7BxJB8w5)74rlCmTxZl1Kl1PcjwQfdPgdUrGW8WiRm)Wy7raKcziaecisrG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQjxQxne)d0U4iqhAvpiWv0NS1GPE7QSmYqaKirKIa5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXL6KsnzLARGzRbtQtk1IvQx4XO6yyo)WyLv0SutUuJb3snGak1KvQ3TfYuX9Qowr10ubRGzRbtQtk1u4RvGUhSUFwTWV8HJP9AEPwOs9cpgvhdZ5hgRSIMLAGSuNsQfdPgdULAabuQjRuVBlKPI7vDSIQPPcwbZwdMuNuQjRutHVwb6EW6(z1c)YhoM2R5L6ei1acOuBfnRSwTlwQjxQtjeK6KsnzL6DBHmvCVQJvunnvWky2AWqGo0QEqGzQ4EvhROAAkKHaifqHifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaFJ5OYoNaziasLcrkcKhNkYBKWiqhAvpiq6EW6(zfvzmceELXx5iqk81kq3dw3pRw4x(aoHuNuQPWxRaDpyD)SAHF5dht718sn5s9QH4VutIulwP2Hw1tGUhSUFwrvghG9BsnqwQH(BQJX4rQtGulgsngCJaH5Hrwz(HX2JaifYqaKImisrG84urEJegb6qR6bbMTIrfSPP9zJaHxz8vocCHhJQJH58dJvwrZsn5sngCl1jL6vdXFPoTud93uhJXJutUuVAi(hODXL6KsTyL6dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3sDsPg2DC3zMW6yorRbtzNteoM2R5L6KsnS74UZmbZpLDor4yAVMxQbeqPMSs9Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtiErqWBPobiqyEyKvMFyS9iasHmeaPaAePiqECQiVrcJaDOv9GaF(i4XuVvdgceELXx5iWDBHNpcEm1B1GfoED8NZPISuNuQjRutHVwb6EW6(z1c)YhoM2R5rGW8WiRm)Wy7raKcziasberKIa5XPI8gjmc0Hw1dcmBfJkytt7ZgbcVY4RCe4QH4VuNwQH(BQJX4rQjxQxne)d0U4sDsPwSsnf(AfO7bR7Nvl8lF4nhMvQjxQtSudiGs9QH4VutUu7qR6jq3dw3pROkJdW(nPobsDsPwSs9Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtiErqWBPoPud7oU7mtyDmNO1GPSZjcht718sDsPg2DC3zMG5NYoNiCmTxZl1acOutwP(WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjeVii4TuNaeimpmYkZpm2EeaPqgcGujgrkc0Hw1dc0v043MpvVuWRZ8iqECQiVrcJmeaPasisrGo0QEqGh)94wnyk)UodcKhNkYBKWidbqkXeIueOdTQheiS7BxJB8w5)74rdbYJtf5nsyKHaiLqarkcKhNkYBKWiqhAvpiq6EW6(zfvzmceELXx5iqk81kq3dw3pRw4x(aoHudiGs9QH4VuNwQDOv9eYwXOc200(Sdq)n1Xy8i1cvQxne)d0U4snGak1u4Rva29TRXnER8)D8OfWjqGW8WiRm)Wy7raKcziasLirKIa5XPI8gjmc0Hw1dc8CcRp1BxLLrGW8WiRm)Wy7raKcziaidqHifbYJtf5nsyei8kJVYrGKvQTcMTgmeOdTQheyMkUx1XkQMMczidbU5LJhnePiasHifb6qR6bbsJNOjAKrG84urEJegziaidIueOdTQheOD(Kq8kwjAnyQpxBiqECQiVrcJmeaanIueOdTQhei(ZQYy6hbYJtf5nsyKHaaiIifbYJtf5nsyei8kJVYrGo0krzfpmDXVutUud0sDsPMSsT5rESGhjY5kIJ3U1xGhNkYBPoPutwP28ipwitf3R6yvnl8V6jWJtf5nc0Hw1dce6XOYHw1JkwVHaJ1BQXPzeivtGmeajgrkcKhNkYBKWiq4vgFLJaDOvIYkEy6IFPMCPgOL6KsT5rESGhjY5kIJ3U1xGhNkYBPoPutwP28ipwitf3R6yvnl8V6jWJtf5nc0Hw1dce6XOYHw1JkwVHaJ1BQXPzeOtq1eidbaqcrkcKhNkYBKWiq4vgFLJaDOvIYkEy6IFPMCPgOL6KsT5rESGhjY5kIJ3U1xGhNkYBPoPuBEKhlKPI7vDSQMf(x9e4XPI8gb6qR6bbc9yu5qR6rfR3qGX6n140mc0jEdziaetisrG84urEJegbcVY4RCeOdTsuwXdtx8l1Kl1aTuNuQjRuBEKhl4rICUI44TB9f4XPI8wQtk1Mh5XczQ4EvhRQzH)vpbECQiVrGo0QEqGqpgvo0QEuX6neySEtnonJaFdziaecisrG84urEJegbcVY4RCeOdTsuwXdtx8l1cvQjdc0Hw1dce6XOYHw1JkwVHaJ1BQXPzeimYUOmYqaKirKIaDOv9Ga9d6dRS(oEmeipovK3iHrgYqGehdBAk3qKIaifIueOdTQhe4Jtt3JIGneipovK3iHrgcaYGifb6qR6bbs1Mf5TAf988otnykRfVgeipovK3iHrgcaGgrkcKhNkYBKWiq4vgFLJap8Hx9HXHVXJR(WyfttX3h4eIxee8gb6qR6bbA(PSZjqgcaGiIueOdTQhe4Bmhv25eiqECQiVrcJmKHaFdrkcGuisrGo0QEqGRONN3QpxBiqECQiVrcJmeaKbrkc0Hw1dcmtf3QNOUYEeipovK3iHrgcaGgrkc0Hw1dc84Vh3Qbt531zqG84urEJegziaaIisrG84urEJegb6qR6bb(8rWJPERgmei8kJVYrGu4Rvq0IGVxjkpnDaNqQtk1u4Rvq0IGVxjkpnD4yAVMxQjxQXGBPgqaLAYk1wbZwdgceMhgzL5hgBpcGuidbqIrKIa5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXrGo0QEqGB2TCkyop750idbaqcrkcKhNkYBKWiqhAvpiWZjS(uVDvwgbcVY4RCeif(AfSIq1lLLJvpb7x4nhMvQfi1anceMhgzL5hgBpcGuidbGycrkc0Hw1dce29TRXnER8)D8OHa5XPI8gjmYqaieqKIaDOv9GaZwXO6Z1gcKhNkYBKWidbqIerkcKhNkYBKWiq4vgFLJax4XO6yyo)WyLv0SutUuJb3sDsPE1q8xQtl1q)n1Xy8i1Kl1RgI)bAxCPgqaLAXk1dlUPYukQMMkiAhDRISuNuQ3TfE(i4XuVvdwWky2AWK6Ks9UTWZhbpM6TAWchVo(Z5urwQbeqPEyXnvMsr10ubIC8109WsDsPE1q8xQtl1q)n1Xy8i1Kl1RgI)bAxCPgil1o0QEczRyubBAAF2bO)M6ymEKAXqQbAPoPutwPMcFTc09G19ZQf(LpCmTxZl1jab6qR6bbMPI7vDSIQPPqgcGuafIueipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKAYL6vdX)aTloc0Hw1dc8nMJk7CcKHaivkePiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i1Kl1RgI)bAxCeOdTQhe4k6t2AWuVDvwgziasrgePiqECQiVrcJaDOv9GaZwXOc200(SrGWRm(khbUAi(l1PLAO)M6ymEKAYL6vdX)aTlUuNuQfRuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4eIxee8wQtk1WUJ7oZewhZjAnyk7CIWX0EnVuNuQHDh3DMjy(PSZjcht718snGak1KvQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCcXlccEl1jabcZdJSY8dJThbqkKHaifqJifbYJtf5nsyei8kJVYrGo0krzfpmDXVuluPoLuNuQjRuF4dV6dJdx(ON9npMLVxb7z14ZUgm1BxLL)aNq8IGG3iqhAvpiqOFIYidbqkGiIueipovK3iHrGWRm(khb6qReLv8W0f)sTqL6usDsPMSs9Hp8QpmoC5JE238yw(EfSNvJp7AWuVDvw(dCcXlccEl1jLAy3XDNzczQ4EvhROAAQWcpgvhdZ5hgRSIMLAHk1pbhJkZpm2EPoPulwPgMZpm(vRZHw1JhLAHk1KjKyPgqaL6DBHp35edhvunnvWky2AWK6eGaDOv9GaPWnyo(YJmeaPsmIueOdTQheOROXVnFQEPGxN5rG84urEJegziasbKqKIa5XPI8gjmc0Hw1dcKUhSUFwrvgJaHxz8vocC3w4ZDoXWrfvttfScMTgmPgqaLAk81kq3dw3pRw4x(WBomRulqQtmceMhgzL5hgBpcGuidbqkXeIueipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)CovKLAabuQPWxRGOfbFVsuEA6aobceMhgzL5hgBpcGuidbqkHaIueipovK3iHrGWRm(khboS4MktPOAAQWN7CIHJsDsPE3w45JGht9wnyHJP9AEPwOsDILAXqQXGBPgqaL6dF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4eIxee8gb6qR6bbMPI7vDSIQPPqgcGujsePiqhAvpiqyop750pcKhNkYBKWidbazakePiqECQiVrcJaDOv9GaP7bR7NvuLXiq4vgFLJaPWxRaDpyD)SAHF5d4esnGak1RgI)sDAP2Hw1tiBfJkytt7Zoa93uhJXJuluPE1q8pq7Il1azPovILAabuQ3Tf(CNtmCur10ubRGzRbdbcZdJSY8dJThbqkKHaGmPqKIa5XPI8gjmc0Hw1dc8CcRp1BxLLrGW8WiRm)Wy7raKcziaidzqKIa5XPI8gjmceELXx5iWHf3uzkfvttfeTJUvrwQtk172cpFe8yQ3QblyfmBnysnGak1dlUPYukQMMkqKJVMUhwQbeqPEyXnvMsr10uHp35edhrGo0QEqGzQ4EvhROAAkKHmeiC)israKcrkcKhNkYBKWiq4vgFLJanpYJfm(OFvVu8G5ymnpwGhNkYBPoPuVAi(l1Kl1RgI)bAxCeOdTQheyo)i6EqgcaYGifbYJtf5nsyei8kJVYrGWUJ7oZeGDF7ACJ3k)FhpAHJP9AEPwOsnqduiqhAvpiqQy3B1c)YJmeaanIueipovK3iHrGWRm(khbc7oU7mta29TRXnER8)D8OfoM2R5LAHk1anqHaDOv9Ga9bYVDEub9yeziaaIisrG84urEJegbcVY4RCeiS74UZmby33Ug34TY)3XJw4yAVMxQfQud0afc0Hw1dcCvhtf7EJmeajgrkc0Hw1dcmwy5SxLigFJrZJHa5XPI8gjmYqaaKqKIa5XPI8gjmceELXx5iqy3XDNzczRyubBAAF2HfEmQogMZpmwzfnl1cvQXGBeOdTQheiLJP6LYUcM9rgcaXeIueipovK3iHrGWRm(khbc7oU7mta29TRXnER8)D8OfoM2R5LAHk1ajGsQbeqP2kAwzTAxSutUuNcOrGo0QEqGu898LTgmKHaqiGifb6qR6bbsJNOjAKrG84urEJegziasKisrG84urEJegbcVY4RCeO5hgBbROzL1QDXsn5snqcOKAabuQPWxRaS7BxJB8w5)74rlGtGaDOv9GajAR6bziasbuisrG84urEJegbcVY4RCe4Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtiErqWBPoPuVAi(l1PLAO)M6ymEKAYL6vdX)aTloc0Hw1dc8nMJk7CcKHaivkePiqECQiVrcJaHxz8voc8WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjeVii4TuNuQxne)L60sn0FtDmgpsn5s9QH4FG2fhb6qR6bbUoMt0AWu25eidbqkYGifbYJtf5nsyei8kJVYrGh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVL6Ks9QH4VuNwQH(BQJX4rQjxQxne)d0U4snGak1RgI)sDAPg6VPogJhPMCPE1q8pq7Il1jL6dF4vFyC4B84QpmwX0u89boH4fbbVL6KsT5NYoNiCmTxZl1Kl1yWTuNuQHDh3DMjSI(XHJP9AEPMCPgdUL6KsTyLAhALOSIhMU4xQfQuNsQbeqP2HwjkR4HPl(LAbsDkPoPuBfnRSwTlwQfQuNyPwmKAm4wQtac0Hw1dc08tzNtGmeaPaAePiqECQiVrcJaDOv9Gaxr)yei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7Il1jLAZpLDoraNqQtk1h(WR(W4W34XvFySIPP47dCcXlccEl1jLAROzL1QDXsTqLAGOulgsngCJaJ1Wk4gbsMeJmeaPaIisrG84urEJegbcVY4RCeOdTsuwXdtx8l1cK6usDsP28dJTGv0SYA1UyPMCPE1q8xQjrQfRu7qR6jq3dw3pROkJdW(nPgil1q)n1Xy8i1jqQfdPgdUrGo0QEqGzRyu95AdziasLyePiqECQiVrcJaHxz8voc0HwjkR4HPl(LAbsDkPoPuB(HXwWkAwzTAxSutUuVAi(l1Ki1IvQDOv9eO7bR7NvuLXby)MudKLAO)M6ymEK6ei1IHuJb3iqhAvpiq6EW6(zfvzmYqaKciHifbYJtf5nsyei8kJVYrGo0krzfpmDXVulqQtj1jLAZpm2cwrZkRv7ILAYL6vdXFPMePwSsTdTQNaDpyD)SIQmoa73KAGSud93uhJXJuNaPwmKAm4gb6qR6bbEoH1N6TRYYidbqkXeIueipovK3iHrGWRm(khbA(HXwyxV5dKLAHkqQbsiqhAvpiq)jyOP6LYYXk2XImYqgcKQjqKIaifIueipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCeif(AfeTi47vIYtthoM2R5L6Ksnf(AfeTi47vIYtthoM2R5LAYLAm4gbcZdJSY8dJThbqkKHaGmisrG84urEJegb6qR6bbMTIrfSPP9zJaHxz8vocC1q8xQtl1q)n1Xy8i1Kl1RgI)bAxCPoPutHVwHH)VgSm(L)v25ee1GPCcc)Cd)d4eiqyEyKvMFyS9iasHmeaanIueipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKAYL6vdX)aTlUuNuQjRuBfmBnysDsPEHhJQJH58dJvwrZsn5sngCJaDOv9GaZuX9Qowr10uidbaqerkc0Hw1dcmtf3QNOUYEeipovK3iHrgcGeJifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaxrFYwdM6TRYYidbaqcrkc0Hw1dcCf988w95AdbYJtf5nsyKHaqmHifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9Ga3SB5uWCE2ZPrgcaHaIueOdTQhey2kgvFU2qG84urEJegziasKisrG84urEJegb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRaS7BxJB8w5)74rlGti1jLAk81ka7(214gVv()oE0cht718sn5sDQqILAXqQXGBeimpmYkZpm2EeaPqgcGuafIueipovK3iHrGo0QEqG09G19ZkQYyei8kJVYrGu4Rva29TRXnER8)D8OfWjK6Ksnf(AfGDF7ACJ3k)FhpAHJP9AEPMCPoviXsTyi1yWnceMhgzL5hgBpcGuidbqQuisrGo0QEqGUIg)28P6LcEDMhbYJtf5nsyKHaifzqKIa5XPI8gjmc0Hw1dc8CcRp1BxLLrGWRm(khbsHVwbRiu9sz5y1tW(fEZHzLAbsnqJaH5Hrwz(HX2JaifYqaKcOrKIa5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXL6KsnzLARGzRbtQtk1IvQx4XO6yyo)WyLv0SutUuJb3snGak1KvQ3TfYuX9Qowr10ubRGzRbtQtk1u4RvGUhSUFwTWV8HJP9AEPwOs9cpgvhdZ5hgRSIMLAGSuNsQfdPgdULAabuQjRuVBlKPI7vDSIQPPcwbZwdMuNuQjRutHVwb6EW6(z1c)YhoM2R5L6ei1acOuBfnRSwTlwQjxQtjeK6KsnzL6DBHmvCVQJvunnvWky2AWqGo0QEqGzQ4EvhROAAkKHaifqerkcKhNkYBKWiqhAvpiWSvmQGnnTpBei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7Il1jLAYk1h(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVLAabuQxne)L60sn0FtDmgpsn5s9QH4FG2fxQtk1IvQfRuF4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4eIxee8wQtk1KvQnpYJfEJ5OYoNiWJtf5TuNuQHDh3DMjSoMt0AWu25eHJP9AEPoPud7oU7mtW8tzNteoM2R5L6ei1acOulwP(WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjeVii4TuNuQnpYJfEJ5OYoNiWJtf5TuNuQHDh3DMjSoMt0AWu25eHJP9AEPoPud7oU7mtW8tzNteoM2R5L6KsnS74UZmH3yoQSZjcht718sDcK6ei1acOuVAi(l1Kl1o0QEc09G19ZkQY4aSFdbcZdJSY8dJThbqkKHaivIrKIa5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXrGo0QEqGVXCuzNtGmeaPasisrG84urEJegb6qR6bb(8rWJPERgmei8kJVYrGu4Rvq0IGVxjkpnDaNqQtk1hVo(Z5urwQbeqPE3w45JGht9wnyHJxh)5CQil1jLAYk1u4Rva29TRXnER8)D8OfWjqGW8WiRm)Wy7raKcziasjMqKIaDOv9Gap(7XTAWu(DDgeipovK3iHrgcGucbePiqECQiVrcJaHxz8vocKSsnf(AfGDF7ACJ3k)FhpAbCceOdTQheiS7BxJB8w5)74rdziasLirKIa5XPI8gjmceELXx5iqk81kq3dw3pRw4x(aoHudiGs9QH4VuNwQDOv9eYwXOc200(Sdq)n1Xy8i1cvQxne)d0U4snGak1u4Rva29TRXnER8)D8OfWjqGo0QEqG09G19ZkQYyKHaGmafIueipovK3iHrGo0QEqGNty9PE7QSmceMhgzL5hgBpcGuidbazsHifbYJtf5nsyei8kJVYrG72czQ4EvhROAAQWXRJ)CovKrGo0QEqGzQ4EvhROAAkKHaGmKbrkcKhNkYBKWiqhAvpiWNpcEm1B1GHaHxz8vocKcFTcIwe89kr5PPd4eiqyEyKvMFyS9iasHmKHaHr2fLrKIaifIueipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCeO5rESqU87ZFfvzCGhNkYBPoPutHVwbrlc(ELO800HJP9AEPoPutHVwbrlc(ELO800HJP9AEPMCPgdUrGW8WiRm)Wy7raKcziaidIueOdTQheyMkUvprDL9iqECQiVrcJmeaanIueOdTQhe4XFpUvdMYVRZGa5XPI8gjmYqaaerKIa5XPI8gjmceELXx5iWfEmQogMZpmwzfnl1Kl1yWnc0Hw1dcmtf3R6yfvttHmeajgrkc0Hw1dceMZZEo9Ja5XPI8gjmYqaaKqKIa5XPI8gjmceELXx5iWDBHp35edhvunnvWky2AWK6KsTyL6DBHAm(gpQOImVRbl8MdZk1Kl1KrQbeqPE3w4ZDoXWrfvttfoM2R5LAYLAm4wQtac0Hw1dcKc3G54lpYqaiMqKIa5XPI8gjmceELXx5iWDBHp35edhvunnvWky2AWqGo0QEqGq)eLrgcaHaIueipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKAYL6vdX)aTloc0Hw1dcCZULtbZ5zpNgziasKisrGo0QEqGWUVDnUXBL)VJhneipovK3iHrgcGuafIueipovK3iHrGWRm(khbcZ5hg)Q15qR6XJsTqLAYesSuNuQHDh3DMjKPI7vDSIQPPcl8yuDmmNFySYkAwQfQu)eCmQm)Wy7LAsKAYGaDOv9GaPWnyo(YJmeaPsHifbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMCPE1q8pq7IJaDOv9GaxrFYwdM6TRYYidbqkYGifbYJtf5nsyei8kJVYrGWUJ7oZeYuX9Qowr10uHfEmQogMZpmwzfnl1cvQFcogvMFyS9snjsnzK6KsT5rESGhjY5kIJ3U1xGhNkYBeOdTQhei0przKHaifqJifbYJtf5nsyeOdTQhey2kgvWMM2NnceELXx5iWvdXFPoTud93uhJXJutUuVAi(hODXL6Ks9cpgvhdZ5hgRSIMLAYLAm4wQtk1IvQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCcXlccEl1jLAy3XDNzcRJ5eTgmLDor4yAVMxQtk1WUJ7oZem)u25eHJP9AEPgqaLAYk1h(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVL6eGaH5Hrwz(HX2JaifYqaKciIifbYJtf5nsyei8kJVYrGKvQ3TfYuX9Qowr10ubRGzRbdb6qR6bbMPI7vDSIQPPqgcGujgrkcKhNkYBKWiq4vgFLJafRutwPEyXnvMsr10uHp35edhLAabuQjRuBEKhlKPI7vDSQMf(x9e4XPI8wQtGuNuQHDh3DMjKPI7vDSIQPPcl8yuDmmNFySYkAwQfQu)eCmQm)Wy7LAsKAYGaDOv9GaPWnyo(YJmeaPasisrG84urEJegbcVY4RCeiS74UZmHmvCVQJvunnvyHhJQJH58dJvwrZsTqL6NGJrL5hgBVutIutgeOdTQhei0przKHaiLycrkc0Hw1dcmBfJQpxBiqECQiVrcJmeaPecisrGo0QEqGRONN3QpxBiqECQiVrcJmeaPsKisrGo0QEqGUIg)28P6LcEDMhbYJtf5nsyKHaGmafIueOdTQhe4Bmhv25eiqECQiVrcJmeaKjfIueipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)CovKL6KsT5rESqU87ZFfvzCGhNkYBPoPuB(HXwWkAwzTAxSuluPwiGaH5Hrwz(HX2JaifYqaqgYGifb6qR6bbc9tugbYJtf5nsyKHaGmanIueipovK3iHrGo0QEqGzRyubBAAF2iq4vgFLJaxne)L60sn0FtDmgpsn5s9QH4FG2fxQtk1IvQp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCcXlccEl1jLAy3XDNzcRJ5eTgmLDor4yAVMxQtk1WUJ7oZem)u25eHJP9AEPgqaLAYk1h(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVL6eGaH5Hrwz(HX2JaifYqaqgGiIueipovK3iHrGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)CovKrGW8WiRm)Wy7raKcziaitIrKIa5XPI8gjmc0Hw1dcKUhSUFwrvgJaH5Hrwz(HX2JaifYqaqgGeIueipovK3iHrGo0QEqGNty9PE7QSmceMhgzL5hgBpcGuidzidbkkFF1dcaYauKbOsrMuajeyg)MAWEeOy2erI5aaieaI5bcKAPM0CSux0e9zs9QpPorWjElrqQpoH41XBP(BAwQDCRPDJ3snmNpy8hKalKRHL6uarGaPwi2JO8z8wQblAHOu)5hZfxQfssT1sTqg3L6DjA9vpsDtWNB9j1ILKei1InL4jiibwcSy2erI5aaieaI5bcKAPM0CSux0e9zs9QpPoragzxuorqQpoH41XBP(BAwQDCRPDJ3snmNpy8hKalKRHL6uafqGule7ru(mEl1GfTquQ)8J5Il1cjP2APwiJ7s9UeT(QhPUj4ZT(KAXsscKAXMs8eeKalKRHL6uKbiqQfI9ikFgVLAWIwik1F(XCXLAHKuBTulKXDPExIwF1Ju3e85wFsTyjjbsTytjEccsGfY1WsDQedei1cXEeLpJ3snyrleL6p)yU4sTqsQTwQfY4UuVlrRV6rQBc(CRpPwSKKaPwSPepbbjWc5AyPofqciqQfI9ikFgVLAWIwik1F(XCXLAHKuBTulKXDPExIwF1Ju3e85wFsTyjjbsTytjEccsGLalMnrKyoaacbGyEGaPwQjnhl1fnrFMuV6tQteG7prqQpoH41XBP(BAwQDCRPDJ3snmNpy8hKalKRHL6uarGaPwi2JO8z8wQblAHOu)5hZfxQfssT1sTqg3L6DjA9vpsDtWNB9j1ILKei1InL4jiibwixdl1PsmqGule7ru(mEl1GfTquQ)8J5Il1cjP2APwiJ7s9UeT(QhPUj4ZT(KAXsscKAXMs8eeKalKRHL6uajGaPwi2JO8z8wQblAHOu)5hZfxQfssT1sTqg3L6DjA9vpsDtWNB9j1ILKei1InL4jiibwcSy2erI5aaieaI5bcKAPM0CSux0e9zs9QpPorWjOAIebP(4eIxhVL6VPzP2XTM2nEl1WC(GXFqcSqUgwQtLciqQfI9ikFgVLAWIwik1F(XCXLAHKuBTulKXDPExIwF1Ju3e85wFsTyjjbsTytjEccsGLadeIMOpJ3sTqqQDOv9i1X6TpibgbsC9QImceiSudIFIwI6rPwmt8X4tcmqyPwmdgY0u8j1KbOerQjdqrgGscSeyhAvpFG4yytt5wAbK84009OiytcSdTQNpqCmSPPClTasOAZI8wTIEEENPgmL1IxJeyhAvpFG4yytt5wAbKy(PSZjePwco8Hx9HXHVXJR(WyfttX3h4eIxee8wcSdTQNpqCmSPPClTasEJ5OYoNqcSeyhAvpFAbKqJNOjAKLa7qR65tlGe78jH4vSs0AWuFU2Ka7qR65tlGe8NvLX0VeyhAvpFAbKa9yu5qR6rfR3ezCAwavtisTe4qReLv8W0f)Kd0jjR5rESGhjY5kIJ3U1xGhNkY7KK18ipwitf3R6yvnl8V6jWJtf5TeyhAvpFAbKa9yu5qR6rfR3ezCAwGtq1eIulbo0krzfpmDXp5aDsZJ8ybpsKZvehVDRVapovK3jjR5rESqMkUx1XQAw4F1tGhNkYBjWo0QE(0cib6XOYHw1JkwVjY40SaN4nrQLahALOSIhMU4NCGoP5rESGhjY5kIJ3U1xGhNkY7KMh5XczQ4EvhRQzH)vpbECQiVLa7qR65tlGeOhJkhAvpQy9MiJtZcEtKAjWHwjkR4HPl(jhOtswZJ8ybpsKZvehVDRVapovK3jnpYJfYuX9QowvZc)REc84urElb2Hw1ZNwajqpgvo0QEuX6nrgNMfaJSlklsTe4qReLv8W0f)cLmsGDOv98PfqIFqFyL13XJjbwcSdTQNp4eunHGmvCREI6k7La7qR65dobvtKwajROpzRbt92vzzrQLGvdX)0q)n1Xy8q(QH4FG2fxcSdTQNp4eunrAbKSIEEER(CTjb2Hw1ZhCcQMiTas2SB5uWCE2ZPfPwcwne)td93uhJXd5RgI)bAxCjWo0QE(Gtq1ePfqs2kgvFU2Ka7qR65dobvtKwaj09G19ZkQYyrG5Hrwz(HX2liLi1saf(AfGDF7ACJ3k)FhpAbCIKu4Rva29TRXnER8)D8OfoM2R5jpviXIbgClb2Hw1ZhCcQMiTasoNW6t92vzzrG5Hrwz(HX2liLi1saf(AfGDF7ACJ3k)FhpAbCIKu4Rva29TRXnER8)D8OfoM2R5jpviXIbgClb2Hw1ZhCcQMiTaswrFYwdM6TRYYIulbRgI)PH(BQJX4H8vdX)aTlUeyhAvpFWjOAI0cijtf3R6yfvttjsTeSAi(Ng6VPogJhYxne)d0U4jjRvWS1GLuSl8yuDmmNFySYkAMCm4gqaj7UTqMkUx1XkQMMkyfmBnyjPWxRaDpyD)SAHF5dht718cDHhJQJH58dJvwrZa5uIbgCdiGKD3witf3R6yfvttfScMTgSKKLcFTc09G19ZQf(LpCmTxZNaab0kAwzTAxm5Pecjj7UTqMkUx1XkQMMkyfmBnysGDOv98bNGQjslGK3yoQSZjePwcwne)td93uhJXd5RgI)bAxCjWo0QE(Gtq1ePfqcDpyD)SIQmweyEyKvMFyS9csjsTeqHVwb6EW6(z1c)YhWjssHVwb6EW6(z1c)YhoM2R5jF1q8xijwhAvpb6EW6(zfvzCa2VbKH(BQJX4jbIbgClb2Hw1ZhCcQMiTasYwXOc200(SfbMhgzL5hgBVGuIulbl8yuDmmNFySYkAMCm4o5QH4FAO)M6ymEiF1q8pq7INuSh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVtc7oU7mtyDmNO1GPSZjcht718jHDh3DMjy(PSZjcht718acizp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCcXlccENajWo0QE(Gtq1ePfqYZhbpM6TAWebMhgzL5hgBVGuIulb72cpFe8yQ3QblC864pNtf5KKLcFTc09G19ZQf(LpCmTxZlb2Hw1ZhCcQMiTasYwXOc200(SfbMhgzL5hgBVGuIulbRgI)PH(BQJX4H8vdX)aTlEsXsHVwb6EW6(z1c)YhEZHzjpXac4QH4p5o0QEc09G19ZkQY4aSFlbjf7Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtiErqW7KWUJ7oZewhZjAnyk7CIWX0EnFsy3XDNzcMFk7CIWX0EnpGas2dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3jqcSdTQNp4eunrAbK4kA8BZNQxk41zEjWo0QE(Gtq1ePfqYXFpUvdMYVRZib2Hw1ZhCcQMiTasGDF7ACJ3k)FhpAsGDOv98bNGQjslGe6EW6(zfvzSiW8WiRm)Wy7fKsKAjGcFTc09G19ZQf(LpGtaiGRgI)PDOv9eYwXOc200(Sdq)n1Xy8i0vdX)aTloGasHVwby33Ug34TY)3XJwaNqcSdTQNp4eunrAbKCoH1N6TRYYIaZdJSY8dJTxqkjWo0QE(Gtq1ePfqsMkUx1XkQMMsKAjGSwbZwdMeyjWo0QE(Gt8MGn7wofmNN9CArQLGvdX)0q)n1Xy8q(QH4FG2fxcSdTQNp4eVLwajpFe8yQ3QbteyEyKvMFyS9csjsTeq2DBHNpcEm1B1GfScMTgSKMFySfSIMvwR2fluXKeyhAvpFWjElTaswrppVvFU2Ka7qR65doXBPfqYXFpUvdMYVRZib2Hw1ZhCI3slGKmvCREI6k7La7qR65doXBPfqcS7BxJB8w5)74rtcSdTQNp4eVLwajzRyu95AtcSdTQNp4eVLwajROpzRbt92vzzrQLGvdX)0q)n1Xy8q(QH4FG2fxcSdTQNp4eVLwajUIg)28P6LcEDMxcSdTQNp4eVLwajzQ4EvhROAAkrQLGfEmQogMZpmwzfntogCdiGRgI)PH(BQJX4H8vdX)aTlEsXoS4MktPOAAQGOD0TkYj3TfE(i4XuVvdwWky2AWsUBl88rWJPERgSWXRJ)CovKbeWHf3uzkfvttfiYXxt3dNKSu4RvGUhSUFwTWV8bCIKRgI)PH(BQJX4H8vdX)aTloq2Hw1tiBfJkytt7Zoa93uhJXJya0jaqaTIMvwR2ftEkGscSdTQNp4eVLwajq)eLfPwcCOvIYkEy6IFHMkjzp8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtiErqWBjWo0QE(Gt8wAbKqHBWC8LxKAjWHwjkR4HPl(fAQKK9WhE1hghU8rp7BEmlFVc2ZQXNDnyQ3Ukl)boH4fbbVtc7oU7mtitf3R6yfvttfw4XO6yyo)WyLv0SqFcogvMFyS9jflmNFy8RwNdTQhpkuYesmGaUBl85oNy4OIQPPcwbZwdwcKa7qR65doXBPfqYBmhv25eIulbRgI)PH(BQJX4H8vdX)aTlUeyhAvpFWjElTasO7bR7NvuLXIaZdJSY8dJTxqkrQLak81kq3dw3pRw4x(aorsk81kq3dw3pRw4x(WX0Enp5RgI)cjX6qR6jq3dw3pROkJdW(nGm0FtDmgpjqmWG7KKLcFTczQ4w9e1v2hoM2R5beqk81kq3dw3pRw4x(WX0EnFYHf3uzkfvttfiYXxt3dlb2Hw1ZhCI3slGKSvmQGnnTpBrG5Hrwz(HX2liLi1sWcpgvhdZ5hgRSIMjhdUtUAi(Ng6VPogJhYxne)d0U4sGDOv98bN4T0ci5CcRp1BxLLfbMhgzL5hgBVGuIulbu4RvWkcvVuwow9eSFH3CywbanGaUBl85oNy4OIQPPcwbZwdMeyhAvpFWjElTasO7bR7NvuLXIulb72cFUZjgoQOAAQGvWS1Gjb2Hw1ZhCI3slGKNpcEm1B1GjcmpmYkZpm2EbPePwcoED8NZPICsZpm2cwrZkRv7IfQyscSdTQNp4eVLwajzQ4EvhROAAkrQLGHf3uzkfvttf(CNtmCm5QH4VqDOv9eO7bR7NvuLXby)MyqMK72cpFe8yQ3QblCmTxZl0elgyWTeyhAvpFWjElTasG58SNt)sGDOv98bN4T0cijBfJkytt7ZweyEyKvMFyS9csjsTeSAi(Ng6VPogJhYxne)d0U4sGDOv98bN4T0cijtf3R6yfvttjsTeC4dV6dJdx(ON9npMLVxb7z14ZUgm1BxLL)aNq8IGG3sGDOv98bN4T0ciHUhSUFwrvglcmpmYkZpm2EbPePwcOWxRaDpyD)SAHF5d4eac4QH4FAhAvpHSvmQGnnTp7a0FtDmgpcD1q8pq7IdKtLyabC3w4ZDoXWrfvttfScMTgmabKcFTczQ4w9e1v2hoM2R5La7qR65doXBPfqY5ewFQ3UkllcmpmYkZpm2EbPKa7qR65doXBPfqsMkUx1XkQMMsKAjyyXnvMsr10ubr7OBvKtUBl88rWJPERgSGvWS1GbiGdlUPYukQMMkqKJVMUhgqahwCtLPuunnv4ZDoXWXKRgI)cnXaLeyjWo0QE(avti45JGht9wnyIaZdJSY8dJTxqkrQLak81kiArW3ReLNMoCmTxZNKcFTcIwe89kr5PPdht718KJb3sGDOv98bQMiTasYwXOc200(SfbMhgzL5hgBVGuIulbRgI)PH(BQJX4H8vdX)aTlEsk81km8)1GLXV8VYoNGOgmLtq4NB4FaNqcSdTQNpq1ePfqsMkUx1XkQMMsKAjy1q8pn0FtDmgpKVAi(hODXtswRGzRbl5cpgvhdZ5hgRSIMjhdULa7qR65dunrAbKKPIB1tuxzVeyhAvpFGQjslGKv0NS1GPE7QSSi1sWQH4FAO)M6ymEiF1q8pq7Ilb2Hw1ZhOAI0cizf988w95AtcSdTQNpq1ePfqYMDlNcMZZEoTi1sWQH4FAO)M6ymEiF1q8pq7Ilb2Hw1ZhOAI0cijBfJQpxBsGDOv98bQMiTasoNW6t92vzzrG5Hrwz(HX2liLi1saf(AfGDF7ACJ3k)FhpAbCIKu4Rva29TRXnER8)D8OfoM2R5jpviXIbgClb2Hw1ZhOAI0ciHUhSUFwrvglcmpmYkZpm2EbPePwcOWxRaS7BxJB8w5)74rlGtKKcFTcWUVDnUXBL)VJhTWX0Enp5PcjwmWGBjWo0QE(avtKwajUIg)28P6LcEDMxcSdTQNpq1ePfqY5ewFQ3UkllcmpmYkZpm2EbPePwcOWxRGveQEPSCS6jy)cV5WScaAjWo0QE(avtKwajzQ4EvhROAAkrQLGvdX)0q)n1Xy8q(QH4FG2fpjzTcMTgSKIDHhJQJH58dJvwrZKJb3aciz3TfYuX9Qowr10ubRGzRbljf(AfO7bR7Nvl8lF4yAVMxOl8yuDmmNFySYkAgiNsmWGBabKS72czQ4EvhROAAQGvWS1GLKSu4RvGUhSUFwTWV8HJP9A(eaiGwrZkRv7IjpLqijz3TfYuX9Qowr10ubRGzRbtcSdTQNpq1ePfqs2kgvWMM2NTiW8WiRm)Wy7fKsKAjy1q8pn0FtDmgpKVAi(hODXts2dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3ac4QH4FAO)M6ymEiF1q8pq7INuSI9WhE1hghg()AWY4x(xzNtqudMYji8Zn8pWjeVii4DsYAEKhl8gZrLDorGhNkY7KWUJ7oZewhZjAnyk7CIWX0EnFsy3XDNzcMFk7CIWX0EnFcaeqXE4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4eIxee8oP5rESWBmhv25ebECQiVtc7oU7mtyDmNO1GPSZjcht718jHDh3DMjy(PSZjcht718jHDh3DMj8gZrLDor4yAVMpbjaqaxne)j3Hw1tGUhSUFwrvghG9BsGDOv98bQMiTasEJ5OYoNqKAjy1q8pn0FtDmgpKVAi(hODXLa7qR65dunrAbK88rWJPERgmrG5Hrwz(HX2liLi1saf(AfeTi47vIYtthWjsE864pNtfzabC3w45JGht9wnyHJxh)5CQiNKSu4Rva29TRXnER8)D8OfWjKa7qR65dunrAbKC83JB1GP876msGDOv98bQMiTasGDF7ACJ3k)FhpAIulbKLcFTcWUVDnUXBL)VJhTaoHeyhAvpFGQjslGe6EW6(zfvzSi1saf(AfO7bR7Nvl8lFaNaqaxne)t7qR6jKTIrfSPP9zhG(BQJX4rORgI)bAxCabKcFTcWUVDnUXBL)VJhTaoHeyhAvpFGQjslGKZjS(uVDvwweyEyKvMFyS9csjb2Hw1ZhOAI0cijtf3R6yfvttjsTeSBlKPI7vDSIQPPchVo(Z5urwcSdTQNpq1ePfqYZhbpM6TAWebMhgzL5hgBVGuIulbu4Rvq0IGVxjkpnDaNqcSeyhAvpFaUFb58JO7rKAjW8ipwW4J(v9sXdMJX08ybECQiVtUAi(t(QH4FG2fxcSdTQNpa3FAbKqf7ERw4xErQLay3XDNzcWUVDnUXBL)VJhTWX0EnVqbAGscSdTQNpa3FAbK4dKF78Oc6XOi1saS74UZmby33Ug34TY)3XJw4yAVMxOanqjb2Hw1ZhG7pTasw1XuXU3IulbWUJ7oZeGDF7ACJ3k)FhpAHJP9AEHc0aLeyhAvpFaU)0cijwy5SxLigFJrZJjb2Hw1ZhG7pTasOCmvVu2vWSVi1saS74UZmHSvmQGnnTp7WcpgvhdZ5hgRSIMfkgClb2Hw1ZhG7pTasO475lBnyIulbWUJ7oZeGDF7ACJ3k)FhpAHJP9AEHcKakab0kAwzTAxm5PaAjWo0QE(aC)PfqcnEIMOrwcSdTQNpa3FAbKq0w1Ji1sG5hgBbROzL1QDXKdKakabKcFTcWUVDnUXBL)VJhTaoHeyhAvpFaU)0ci5nMJk7CcrQLGdF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3jxne)td93uhJXd5RgI)bAxCjWo0QE(aC)PfqY6yorRbtzNtisTeC4dV6dJdd)Fnyz8l)RSZjiQbt5ee(5g(h4eIxee8o5QH4FAO)M6ymEiF1q8pq7Ilb2Hw1ZhG7pTasm)u25eIulbh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVtUAi(Ng6VPogJhYxne)d0U4ac4QH4FAO)M6ymEiF1q8pq7IN8WhE1hgh(gpU6dJvmnfFFGtiErqW7KMFk7CIWX0Enp5yWDsy3XDNzcROFC4yAVMNCm4oPyDOvIYkEy6IFHMcqaDOvIYkEy6IFbPsAfnRSwTlwOjwmWG7eib2Hw1ZhG7pTaswr)yrI1Wk4wazsSi1sWQH4FAO)M6ymEiF1q8pq7IN08tzNteWjsE4dV6dJdFJhx9HXkMMIVpWjeVii4DsROzL1QDXcfikgyWTeyhAvpFaU)0cijBfJQpxBIulbo0krzfpmDXVGujn)WylyfnRSwTlM8vdXFHKyDOv9eO7bR7NvuLXby)gqg6VPogJNeigyWTeyhAvpFaU)0ciHUhSUFwrvglsTe4qReLv8W0f)csL08dJTGv0SYA1UyYxne)fsI1Hw1tGUhSUFwrvghG9BazO)M6ymEsGyGb3sGDOv98b4(tlGKZjS(uVDvwwKAjWHwjkR4HPl(fKkP5hgBbROzL1QDXKVAi(lKeRdTQNaDpyD)SIQmoa73aYq)n1Xy8KaXadULa7qR65dW9Nwaj(tWqt1lLLJvSJfzrQLaZpm2c76nFGSqfaKKalb2Hw1ZhGr2fLf88rWJPERgmrG5Hrwz(HX2liLi1sG5rESqU87ZFfvzCGhNkY7Ku4Rvq0IGVxjkpnD4yAVMpjf(AfeTi47vIYtthoM2R5jhdULa7qR65dWi7IYPfqsMkUvprDL9sGDOv98byKDr50ci54Vh3Qbt531zKa7qR65dWi7IYPfqsMkUx1XkQMMsKAjyHhJQJH58dJvwrZKJb3sGDOv98byKDr50cibMZZEo9lb2Hw1ZhGr2fLtlGekCdMJV8Iulb72cFUZjgoQOAAQGvWS1GLuS72c1y8nEurfzExdw4nhMLCYaiG72cFUZjgoQOAAQWX0Enp5yWDcKa7qR65dWi7IYPfqc0przrQLGDBHp35edhvunnvWky2AWKa7qR65dWi7IYPfqYMDlNcMZZEoTi1sWQH4FAO)M6ymEiF1q8pq7Ilb2Hw1ZhGr2fLtlGey33Ug34TY)3XJMeyhAvpFagzxuoTasOWnyo(YlsTeaZ5hg)Q15qR6XJcLmHeNe2DC3zMqMkUx1XkQMMkSWJr1XWC(HXkROzH(eCmQm)Wy7fsKrcSdTQNpaJSlkNwajROpzRbt92vzzrQLGvdX)0q)n1Xy8q(QH4FG2fxcSdTQNpaJSlkNwajq)eLfPwcGDh3DMjKPI7vDSIQPPcl8yuDmmNFySYkAwOpbhJkZpm2EHezsAEKhl4rICUI44TB9f4XPI8wcSdTQNpaJSlkNwajzRyubBAAF2IaZdJSY8dJTxqkrQLGvdX)0q)n1Xy8q(QH4FG2fp5cpgvhdZ5hgRSIMjhdUtk2dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3jHDh3DMjSoMt0AWu25eHJP9A(KWUJ7oZem)u25eHJP9AEabKSh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVtGeyhAvpFagzxuoTasYuX9Qowr10uIulbKD3witf3R6yfvttfScMTgmjWo0QE(amYUOCAbKqHBWC8LxKAjqSKDyXnvMsr10uHp35edhbeqYAEKhlKPI7vDSQMf(x9e4XPI8objHDh3DMjKPI7vDSIQPPcl8yuDmmNFySYkAwOpbhJkZpm2EHezKa7qR65dWi7IYPfqc0przrQLay3XDNzczQ4EvhROAAQWcpgvhdZ5hgRSIMf6tWXOY8dJTxirgjWo0QE(amYUOCAbKKTIr1NRnjWo0QE(amYUOCAbKSIEEER(CTjb2Hw1ZhGr2fLtlGexrJFB(u9sbVoZlb2Hw1ZhGr2fLtlGK3yoQSZjKa7qR65dWi7IYPfqYZhbpM6TAWebMhgzL5hgBVGuIulbhVo(Z5uroP5rESqU87ZFfvzCGhNkY7KMFySfSIMvwR2fluHGeyhAvpFagzxuoTasG(jklb2Hw1ZhGr2fLtlGKSvmQGnnTpBrG5Hrwz(HX2liLi1sWQH4FAO)M6ymEiF1q8pq7INuSh(WR(W4WW)xdwg)Y)k7CcIAWuobHFUH)boH4fbbVtc7oU7mtyDmNO1GPSZjcht718jHDh3DMjy(PSZjcht718acizp8Hx9HXHH)VgSm(L)v25ee1GPCcc)Cd)dCcXlccENajWo0QE(amYUOCAbK88rWJPERgmrG5Hrwz(HX2liLi1sWXRJ)CovKLa7qR65dWi7IYPfqcDpyD)SIQmweyEyKvMFyS9csjb2Hw1ZhGr2fLtlGKZjS(uVDvwweyEyKvMFyS9csjbwcSdTQNp8MGv0ZZB1NRnjWo0QE(WBPfqsMkUvprDL9sGDOv98H3slGKJ)ECRgmLFxNrcSdTQNp8wAbK88rWJPERgmrG5Hrwz(HX2liLi1saf(AfeTi47vIYtthWjssHVwbrlc(ELO800HJP9AEYXGBabKSwbZwdMeyhAvpF4T0cizZULtbZ5zpNwKAjy1q8pn0FtDmgpKVAi(hODXLa7qR65dVLwajNty9PE7QSSiW8WiRm)Wy7fKsKAjGcFTcwrO6LYYXQNG9l8MdZkaOLa7qR65dVLwajWUVDnUXBL)VJhnjWo0QE(WBPfqs2kgvFU2Ka7qR65dVLwajzQ4EvhROAAkrQLGfEmQogMZpmwzfntogCNC1q8pn0FtDmgpKVAi(hODXbeqXoS4MktPOAAQGOD0TkYj3TfE(i4XuVvdwWky2AWsUBl88rWJPERgSWXRJ)CovKbeWHf3uzkfvttfiYXxt3dNC1q8pn0FtDmgpKVAi(hODXbYo0QEczRyubBAAF2bO)M6ymEedGojzPWxRaDpyD)SAHF5dht718jqcSdTQNp8wAbK8gZrLDoHi1sWQH4FAO)M6ymEiF1q8pq7Ilb2Hw1ZhElTaswrFYwdM6TRYYIulbRgI)PH(BQJX4H8vdX)aTlUeyhAvpF4T0cijBfJkytt7ZweyEyKvMFyS9csjsTeSAi(Ng6VPogJhYxne)d0U4jf7Hp8Qpmom8)1GLXV8VYoNGOgmLtq4NB4FGtiErqW7KWUJ7oZewhZjAnyk7CIWX0EnFsy3XDNzcMFk7CIWX0EnpGas2dF4vFyCy4)RblJF5FLDobrnykNGWp3W)aNq8IGG3jqcSdTQNp8wAbKa9tuwKAjWHwjkR4HPl(fAQKK9WhE1hghU8rp7BEmlFVc2ZQXNDnyQ3Ukl)boH4fbbVLa7qR65dVLwaju4gmhF5fPwcCOvIYkEy6IFHMkjzp8Hx9HXHlF0Z(MhZY3RG9SA8zxdM6TRYYFGtiErqW7KWUJ7oZeYuX9Qowr10uHfEmQogMZpmwzfnl0NGJrL5hgBFsXcZ5hg)Q15qR6XJcLmHediG72cFUZjgoQOAAQGvWS1GLajWo0QE(WBPfqIROXVnFQEPGxN5La7qR65dVLwaj09G19ZkQYyrG5Hrwz(HX2liLi1sWUTWN7CIHJkQMMkyfmBnyacif(AfO7bR7Nvl8lF4nhMvqILa7qR65dVLwajpFe8yQ3QbteyEyKvMFyS9csjsTeC864pNtfzabKcFTcIwe89kr5PPd4esGDOv98H3slGKmvCVQJvunnLi1sWWIBQmLIQPPcFUZjgoMC3w45JGht9wnyHJP9AEHMyXadUbeWdF4vFyC4Yh9SV5XS89kypRgF21GPE7QS8h4eIxee8wcSdTQNp8wAbKaZ5zpN(La7qR65dVLwaj09G19ZkQYyrG5Hrwz(HX2liLi1saf(AfO7bR7Nvl8lFaNaqaxne)t7qR6jKTIrfSPP9zhG(BQJX4rORgI)bAxCGCQediG72cFUZjgoQOAAQGvWS1Gjb2Hw1ZhElTasoNW6t92vzzrG5Hrwz(HX2liLeyhAvpF4T0cijtf3R6yfvttjsTemS4MktPOAAQGOD0TkYj3TfE(i4XuVvdwWky2AWaeWHf3uzkfvttfiYXxt3ddiGdlUPYukQMMk85oNy4ic8jyicaYK4eJmKHqa]] )
end