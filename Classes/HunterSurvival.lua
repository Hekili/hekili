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

    spec:RegisterPack( "Survival", 20201216, [[dCuC7bqiKk9iaH0LiiYMejFsefmkcLoLiIvrOWRePMfH4wasSlb)cPyyeeoMiSmKkEgGOPbiLRjIQTbi4BekY4aK05aeQ1jIIMhsv3Ja7JG0bfrHSqcQhcivtKqrHpsOOQrsOOOtcieReqntcIANayPekQ8uGMksPVsOO0EH8xsgmPomvlgjpg0KvQlJAZk5Zqz0IQoTKvlIc1RfLMTq3gr7wXVLA4iCCrKwUkpxvtNY1HQTti9DrX4juDErL1lIsZhG2prJsGOfbUDJraqhHGocrc6KaieecGkDecGebA5iyeiHdZ6ymcCCsgbcIFIwI6reiHNl2(grlc8B8dYiqGOsDEZi(Kjn0GvwECQaSjP5ls8OBvpWZxgnFrcPbbsHxrdiYGOqGB3yea0riOJqKGojacbHaOMaOsNKJaDClFFiqWIeOJaZx7npike4MFiceiQudIFIwI6rPwmt8X4tcmquPwmdgYKu8j1jasrKA6ie0riqGX6Thrlc0jEdrlcGeiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQPxQxne)dKU4iqhAvpiWn7wEfmVN9CsKHaGoiArG84urEJegbcVY4RCeiDL6DBHNpcEm1B1GfScMTgmPoLuB(HXwWkswzTAxSuluPwmHaDOv9GaF(i4XuVvdgceMdgzL5hgBpcGeidbaqIOfb6qR6bbUIEoER(8THa5XPI8gjmYqaa0q0IaDOv9Gap(7XTAWu(DDgeipovK3iHrgcGKJOfb6qR6bbMPIB1tuxzpcKhNkYBKWidbaqarlc0Hw1dce29TRXnER8)D8OHa5XPI8gjmYqaiMq0IaDOv9GaZwXO6Z3gcKhNkYBKWidbaqfrlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bbUI(KTgm1BxLLrgcaGyeTiqhAvpiqxrIFB(u9sbVoZJa5XPI8gjmYqaKqiq0Ia5XPI8gjmceELXx5iWfEmQogM3pmwzfjl10l1yWTudiGs9QH4VuNwQH(BQJX4rQPxQxne)dKU4sDkPwSs9WIBQmLIQjPcI2r3Qil1PK6DBHNpcEm1B1GfScMTgmPoLuVBl88rWJPERgSWXRJ)8ovKLAabuQhwCtLPuunjvGipFnzpSuNsQPRutHVwbYEW6(z1c)YfWjK6us9QH4VuNwQH(BQJX4rQPxQxne)dKU4snqrQDOv9eYwXOc2KK(Sdq)n1Xy8i1IHudKsDsKAabuQTIKvwR2fl10l1jeceOdTQheyMkUx1XkQMKcziasKarlcKhNkYBKWiq4vgFLJaDOvIYkEyYIFPwOsDcPoLutxP(WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boP4fbbVrGo0QEqGq)eLrgcGe0brlcKhNkYBKWiq4vgFLJaDOvIYkEyYIFPwOsDcPoLutxP(WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boP4fbbVL6usnS74UZmHmvCVQJvunjvyHhJQJH59dJvwrYsTqL6NGJrL5hgBVuNsQfRudZ7hg)Q15qR6XJsTqLA6esUudiGs9UTWN)CIHJkQMKkyfmBnysDsqGo0QEqGu4gmpF5qgcGeajIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKA6L6vdX)aPloc0Hw1dc8nMJk7CcKHaibqdrlcKhNkYBKWiq4vgFLJaPWxRazpyD)SAHF5c4esDkPMcFTcK9G19ZQf(LlCmPxZl10l1RgI)snnsTyLAhAvpbYEW6(zfvzCa2Vj1afPg6VPogJhPojsTyi1yWTuNsQPRutHVwHmvCREI6k7dht618snGak1u4RvGShSUFwTWVCHJj9AEPoLupS4MktPOAsQarE(AYEyeOdTQheizpyD)SIQmgbcZbJSY8dJThbqcKHairYr0Ia5XPI8gjmceELXx5iWfEmQogM3pmwzfjl10l1yWTuNsQxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bbMTIrfSjj9zJaH5Grwz(HX2JaibYqaKaiGOfbYJtf5nsyei8kJVYrGu4RvWkcvVuwEw9eSFH3CywPwGudKsnGak172cF(ZjgoQOAsQGvWS1GHaDOv9GapNW6t92vzzeimhmYkZpm2EeajqgcGeIjeTiqECQiVrcJaHxz8vocC3w4ZFoXWrfvtsfScMTgmeOdTQheizpyD)SIQmgziasaur0Ia5XPI8gjmceELXx5iWJxh)5DQil1PKAZpm2cwrYkRv7ILAHk1IjeOdTQhe4ZhbpM6TAWqGWCWiRm)Wy7raKaziasaeJOfbYJtf5nsyei8kJVYrGdlUPYukQMKk85pNy4OuNsQxne)LAHk1o0QEcK9G19ZkQY4aSFtQfdPMosDkPE3w45JGht9wnyHJj9AEPwOsDYLAXqQXGBeOdTQheyMkUx1XkQMKcziaOJqGOfb6qR6bbcZ7zpN8rG84urEJegziaOtceTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i10l1RgI)bsxCeOdTQhey2kgvWMK0NnceMdgzL5hgBpcGeidbaDOdIweipovK3iHrGWRm(khbE4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNu8IGG3iqhAvpiWmvCVQJvunjfYqaqhGerlcKhNkYBKWiq4vgFLJaPWxRazpyD)SAHF5c4esnGak1RgI)sDAP2Hw1tiBfJkyts6Zoa93uhJXJuluPE1q8pq6Il1afPorYLAabuQ3Tf(8NtmCur1KubRGzRbtQbeqPMcFTczQ4w9e1v2hoM0R5rGo0QEqGK9G19ZkQYyeimhmYkZpm2Eeajqgca6a0q0Ia5XPI8gjmc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKaziaOtYr0Ia5XPI8gjmceELXx5iWHf3uzkfvtsfeTJUvrwQtj172cpFe8yQ3QblyfmBnysnGak1dlUPYukQMKkqKNVMShwQbeqPEyXnvMsr1KuHp)5edhL6us9QH4VuluPo5cbc0Hw1dcmtf3R6yfvtsHmKHajog2KuUHOfbqceTiqhAvpiWhNKShfbBiqECQiVrcJmea0brlc0Hw1dcKQnlYB1k654DMAWuwlEniqECQiVrcJmeaajIweipovK3iHrGWRm(khbE4dV6dJdFJhx9HXkMKIVpWjfVii4nc0Hw1dc08tzNtGmeaaneTiqhAvpiW3yoQSZjqG84urEJegzidbU5LJhneTiasGOfb6qR6bbsINSjBKrG84urEJegziaOdIweOdTQhei(ZQYyYhbYJtf5nsyKHaair0Ia5XPI8gjmc0Hw1dce6XOYHw1JkwVHaHxz8voc0HwjkR4Hjl(LA6LAGuQtj10vQnpYJf8irExrC82T(c84urEl1PKA6k1Mh5XczQ4EvhRQzH)vpbECQiVrGX6n14KmcKQjqgcaGgIweipovK3iHrGo0QEqGqpgvo0QEuX6nei8kJVYrGo0krzfpmzXVutVudKsDkP28ipwWJe5DfXXB36lWJtf5TuNsQPRuBEKhlKPI7vDSQMf(x9e4XPI8gbgR3uJtYiqNGQjqgcGKJOfbYJtf5nsyeOdTQhei0JrLdTQhvSEdbcVY4RCeOdTsuwXdtw8l10l1aPuNsQnpYJf8irExrC82T(c84urEl1PKAZJ8yHmvCVQJv1SW)QNapovK3iWy9MACsgb6eVHmeaabeTiqECQiVrcJaDOv9GaHEmQCOv9OI1Biq4vgFLJaDOvIYkEyYIFPMEPgiL6usnDLAZJ8ybpsK3vehVDRVapovK3sDkP28ipwitf3R6yvnl8V6jWJtf5ncmwVPgNKrGVHmeaIjeTiqECQiVrcJaDOv9GaHEmQCOv9OI1Biq4vgFLJaDOvIYkEyYIFPwOsnDqGX6n14KmcegzxugziaaQiArGo0QEqG(b9HvwFhpgcKhNkYBKWidziqyKDrzeTiasGOfbYJtf5nsyei8kJVYrGMh5Xc5ZTp)vuLXbECQiVL6usnf(AfeTi47vIYttgoM0R5L6usnf(AfeTi47vIYttgoM0R5LA6LAm4gb6qR6bb(8rWJPERgmeimhmYkZpm2Eeajqgca6GOfb6qR6bbMPIB1tuxzpcKhNkYBKWidbaqIOfb6qR6bbE83JB1GP876miqECQiVrcJmeaaneTiqECQiVrcJaHxz8vocCHhJQJH59dJvwrYsn9sngCJaDOv9GaZuX9Qowr1KuidbqYr0IaDOv9GaH59SNt(iqECQiVrcJmeaabeTiqECQiVrcJaHxz8vocC3w4ZFoXWrfvtsfScMTgmPoLulwPE3wOgJVXJkQiZ7AWcV5WSsn9snDKAabuQ3Tf(8NtmCur1KuHJj9AEPMEPgdUL6KGaDOv9GaPWnyE(YHmeaIjeTiqECQiVrcJaHxz8vocC3w4ZFoXWrfvtsfScMTgmeOdTQhei0przKHaaOIOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMEPE1q8pq6IJaDOv9Ga3SB5vW8E2ZjrgcaGyeTiqhAvpiqy33Ug34TY)3XJgcKhNkYBKWidbqcHarlcKhNkYBKWiq4vgFLJaH59dJF16COv94rPwOsnDcjxQtj1WUJ7oZeYuX9Qowr1KuHfEmQogM3pmwzfjl1cvQFcogvMFyS9snnsnDqGo0QEqGu4gmpF5qgcGejq0Ia5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutVuVAi(hiDXrGo0QEqGROpzRbt92vzzKHaibDq0Ia5XPI8gjmceELXx5iqy3XDNzczQ4EvhROAsQWcpgvhdZ7hgRSIKLAHk1pbhJkZpm2EPMgPMosDkP28ipwWJe5DfXXB36lWJtf5nc0Hw1dce6NOmYqaKair0Ia5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutVuVAi(hiDXL6us9cpgvhdZ7hgRSIKLA6LAm4wQtj1IvQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PKAy3XDNzcRJ5KTgmLDor4ysVMxQtj1WUJ7oZem)u25eHJj9AEPgqaLA6k1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6KGaDOv9GaZwXOc2KK(SrGWCWiRm)Wy7raKaziasa0q0Ia5XPI8gjmceELXx5iq6k172czQ4EvhROAsQGvWS1GHaDOv9GaZuX9Qowr1KuidbqIKJOfbYJtf5nsyei8kJVYrGIvQPRupS4MktPOAsQWN)CIHJsnGak10vQnpYJfYuX9QowvZc)REc84urEl1jrQtj1WUJ7oZeYuX9Qowr1KuHfEmQogM3pmwzfjl1cvQFcogvMFyS9snnsnDqGo0QEqGu4gmpF5qgcGeabeTiqECQiVrcJaHxz8voce2DC3zMqMkUx1XkQMKkSWJr1XW8(HXkRizPwOs9tWXOY8dJTxQPrQPdc0Hw1dce6NOmYqaKqmHOfb6qR6bbMTIr1NVneipovK3iHrgcGeaveTiqhAvpiWv0ZXB1NVneipovK3iHrgcGeaXiArGo0QEqGUIe)28P6LcEDMhbYJtf5nsyKHaGocbIweOdTQhe4Bmhv25eiqECQiVrcJmea0jbIweipovK3iHrGWRm(khbE864pVtfzPoLuBEKhlKp3(8xrvgh4XPI8wQtj1MFySfSIKvwR2fl1cvQbQiqhAvpiWNpcEm1B1GHaH5Grwz(HX2JaibYqaqh6GOfb6qR6bbc9tugbYJtf5nsyKHaGoajIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKA6L6vdX)aPlUuNsQfRuF4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8wQtj1WUJ7oZewhZjBnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618snGak10vQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1jbb6qR6bbMTIrfSjj9zJaH5Grwz(HX2JaibYqaqhGgIweipovK3iHrGWRm(khbE864pVtfzeOdTQhe4ZhbpM6TAWqGWCWiRm)Wy7raKaziaOtYr0Ia5XPI8gjmc0Hw1dcKShSUFwrvgJaH5Grwz(HX2JaibYqaqhGaIweipovK3iHrGo0QEqGNty9PE7QSmceMdgzL5hgBpcGeidziW3q0IaibIweOdTQhe4k654T6Z3gcKhNkYBKWidbaDq0IaDOv9GaZuXT6jQRShbYJtf5nsyKHaair0IaDOv9Gap(7XTAWu(DDgeipovK3iHrgcaGgIweipovK3iHrGWRm(khbsHVwbrlc(ELO80KbCcPoLutHVwbrlc(ELO80KHJj9AEPMEPgdULAabuQPRuBfmBnyiqhAvpiWNpcEm1B1GHaH5Grwz(HX2JaibYqaKCeTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i10l1RgI)bsxCeOdTQhe4MDlVcM3ZEojYqaaeq0Ia5XPI8gjmceELXx5iqk81kyfHQxklpREc2VWBomRulqQbseOdTQhe45ewFQ3UklJaH5Grwz(HX2JaibYqaiMq0IaDOv9GaHDF7ACJ3k)FhpAiqECQiVrcJmeaaveTiqhAvpiWSvmQ(8THa5XPI8gjmYqaaeJOfbYJtf5nsyei8kJVYrGl8yuDmmVFySYkswQPxQXGBPoLuVAi(l1PLAO)M6ymEKA6L6vdX)aPlUudiGsTyL6Hf3uzkfvtsfeTJUvrwQtj172cpFe8yQ3QblyfmBnysDkPE3w45JGht9wnyHJxh)5DQil1acOupS4MktPOAsQarE(AYEyPoLuVAi(l1PLAO)M6ymEKA6L6vdX)aPlUuduKAhAvpHSvmQGnjPp7a0FtDmgpsTyi1aPuNsQPRutHVwbYEW6(z1c)YfoM0R5L6KGaDOv9GaZuX9Qowr1KuidbqcHarlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bb(gZrLDobYqaKibIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKA6L6vdX)aPloc0Hw1dcCf9jBnyQ3UklJmeajOdIweipovK3iHrGWRm(khbUAi(l1PLAO)M6ymEKA6L6vdX)aPlUuNsQfRuF4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8wQtj1WUJ7oZewhZjBnyk7CIWXKEnVuNsQHDh3DMjy(PSZjcht618snGak10vQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1jbb6qR6bbMTIrfSjj9zJaH5Grwz(HX2JaibYqaKair0Ia5XPI8gjmceELXx5iqhALOSIhMS4xQfQuNqQtj10vQp8Hx9HXHlx0Z(MhZY3RG9SA8zxdM6TRYYFGtkErqWBeOdTQhei0przKHaibqdrlcKhNkYBKWiq4vgFLJaDOvIYkEyYIFPwOsDcPoLutxP(WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boP4fbbVL6usnS74UZmHmvCVQJvunjvyHhJQJH59dJvwrYsTqL6NGJrL5hgBVuNsQfRudZ7hg)Q15qR6XJsTqLA6esUudiGs9UTWN)CIHJkQMKkyfmBnysDsqGo0QEqGu4gmpF5qgcGejhrlc0Hw1dc0vK43MpvVuWRZ8iqECQiVrcJmeajaciArG84urEJegbcVY4RCe4UTWN)CIHJkQMKkyfmBnysnGak1u4RvGShSUFwTWVCH3CywPwGuNCeOdTQheizpyD)SIQmgbcZbJSY8dJThbqcKHaiHycrlcKhNkYBKWiq4vgFLJapED8N3PISudiGsnf(AfeTi47vIYttgWjqGo0QEqGpFe8yQ3QbdbcZbJSY8dJThbqcKHaibqfrlcKhNkYBKWiq4vgFLJahwCtLPuunjv4ZFoXWrPoLuVBl88rWJPERgSWXKEnVuluPo5sTyi1yWTudiGs9Hp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCsXlccEJaDOv9GaZuX9Qowr1KuidbqcGyeTiqhAvpiqyEp75KpcKhNkYBKWidbaDeceTiqECQiVrcJaHxz8vocKcFTcK9G19ZQf(LlGti1acOuVAi(l1PLAhAvpHSvmQGnjPp7a0FtDmgpsTqL6vdX)aPlUuduK6ejxQbeqPE3w4ZFoXWrfvtsfScMTgmeOdTQheizpyD)SIQmgbcZbJSY8dJThbqcKHaGojq0Ia5XPI8gjmc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKaziaOdDq0Ia5XPI8gjmceELXx5iWHf3uzkfvtsfeTJUvrwQtj172cpFe8yQ3QblyfmBnysnGak1dlUPYukQMKkqKNVMShwQbeqPEyXnvMsr1KuHp)5edhrGo0QEqGzQ4EvhROAskKHmeiC)iAraKarlcKhNkYBKWiq4vgFLJanpYJfm(iFvVu8G5ymjpwGhNkYBPoLuVAi(l10l1RgI)bsxCeOdTQheyE)i6Eqgca6GOfbYJtf5nsyei8kJVYrGWUJ7oZeGDF7ACJ3k)FhpAHJj9AEPwOsnqkeiqhAvpiqQy3B1c)YHmeaajIweipovK3iHrGWRm(khbc7oU7mta29TRXnER8)D8OfoM0R5LAHk1aPqGaDOv9Ga9bYVDEub9yeziaaAiArG84urEJegbcVY4RCeiS74UZmby33Ug34TY)3XJw4ysVMxQfQudKcbc0Hw1dcCvhtf7EJmeajhrlc0Hw1dcmwy5TxLmgFJrYJHa5XPI8gjmYqaaeq0Ia5XPI8gjmceELXx5iqy3XDNzczRyubBssF2HfEmQogM3pmwzfjl1cvQXGBeOdTQheiLJP6LYUcM9rgcaXeIweipovK3iHrGWRm(khbc7oU7mta29TRXnER8)D8OfoM0R5LAHk1abHqQbeqP2kswzTAxSutVuNairGo0QEqGu898LTgmKHaaOIOfb6qR6bbsINSjBKrG84urEJegziaaIr0Ia5XPI8gjmceELXx5iqZpm2cwrYkRv7ILA6LAGGqi1acOutHVwby33Ug34TY)3XJwaNab6qR6bbs0w1dYqaKqiq0Ia5XPI8gjmceELXx5iWdF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3sDkPE1q8xQtl1q)n1Xy8i10l1RgI)bsxCeOdTQhe4Bmhv25eidbqIeiArG84urEJegbcVY4RCe4Hp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqWBPoLuVAi(l1PLAO)M6ymEKA6L6vdX)aPloc0Hw1dcCDmNS1GPSZjqgcGe0brlcKhNkYBKWiq4vgFLJap8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PK6vdXFPoTud93uhJXJutVuVAi(hiDXLAabuQxne)L60sn0FtDmgpsn9s9QH4FG0fxQtj1h(WR(W4W34XvFySIjP47dCsXlccEl1PKAZpLDor4ysVMxQPxQXGBPoLud7oU7mtyf9Jdht618sn9sngCl1PKAXk1o0krzfpmzXVuluPoHudiGsTdTsuwXdtw8l1cK6esDkP2kswzTAxSuluPo5sTyi1yWTuNeeOdTQheO5NYoNaziasaKiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQPxQxne)dKU4sDkP28tzNteWjK6us9Hp8Qpmo8nEC1hgRysk((aNu8IGG3sDkP2kswzTAxSuluPgOj1IHuJb3iqhAvpiWv0pgbgRHvWncKojhziasa0q0Ia5XPI8gjmceELXx5iqhALOSIhMS4xQfi1jK6usT5hgBbRizL1QDXsn9s9QH4VutJulwP2Hw1tGShSUFwrvghG9BsnqrQH(BQJX4rQtIulgsngCJaDOv9GaZwXO6Z3gYqaKi5iArG84urEJegbcVY4RCeOdTsuwXdtw8l1cK6esDkP28dJTGvKSYA1UyPMEPE1q8xQPrQfRu7qR6jq2dw3pROkJdW(nPgOi1q)n1Xy8i1jrQfdPgdUrGo0QEqGK9G19ZkQYyKHaibqarlcKhNkYBKWiq4vgFLJaDOvIYkEyYIFPwGuNqQtj1MFySfSIKvwR2fl10l1RgI)snnsTyLAhAvpbYEW6(zfvzCa2Vj1afPg6VPogJhPojsTyi1yWnc0Hw1dc8CcRp1BxLLrgcGeIjeTiqECQiVrcJaHxz8voc08dJTWUEZhil1cvGudeqGo0QEqG(tWqt1lLLNvSJfzKHmeivtGOfbqceTiqECQiVrcJaHxz8vocKcFTcIwe89kr5Pjdht618sDkPMcFTcIwe89kr5Pjdht618sn9sngCJaDOv9GaF(i4XuVvdgceMdgzL5hgBpcGeidbaDq0Ia5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutVuVAi(hiDXL6usnf(Afg()AWY4xUxzNtqudMYji8Zn8pGtGaDOv9GaZwXOc2KK(SrGWCWiRm)Wy7raKaziaaseTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i10l1RgI)bsxCPoLutxP2ky2AWK6us9cpgvhdZ7hgRSIKLA6LAm4gb6qR6bbMPI7vDSIQjPqgcaGgIweOdTQheyMkUvprDL9iqECQiVrcJmeajhrlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bbUI(KTgm1BxLLrgcaGaIweOdTQhe4k654T6Z3gcKhNkYBKWidbGycrlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bbUz3YRG59SNtImeaaveTiqhAvpiWSvmQ(8THa5XPI8gjmYqaaeJOfbYJtf5nsyei8kJVYrGu4Rva29TRXnER8)D8OfWjK6usnf(AfGDF7ACJ3k)FhpAHJj9AEPMEPori5sTyi1yWnc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKaziasieiArG84urEJegbcVY4RCeif(AfGDF7ACJ3k)FhpAbCcPoLutHVwby33Ug34TY)3XJw4ysVMxQPxQtesUulgsngCJaDOv9Gaj7bR7NvuLXiqyoyKvMFyS9iasGmeajsGOfb6qR6bb6ks8BZNQxk41zEeipovK3iHrgcGe0brlcKhNkYBKWiq4vgFLJaPWxRGveQEPS8S6jy)cV5WSsTaPgirGo0QEqGNty9PE7QSmceMdgzL5hgBpcGeidbqcGerlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fxQtj10vQTcMTgmPoLulwPEHhJQJH59dJvwrYsn9sngCl1acOutxPE3witf3R6yfvtsfScMTgmPoLutHVwbYEW6(z1c)YfoM0R5LAHk1l8yuDmmVFySYkswQbksDcPwmKAm4wQbeqPMUs9UTqMkUx1XkQMKkyfmBnysDkPMUsnf(Afi7bR7Nvl8lx4ysVMxQtIudiGsTvKSYA1UyPMEPobqvQtj10vQ3TfYuX9Qowr1KubRGzRbdb6qR6bbMPI7vDSIQjPqgcGeaneTiqECQiVrcJaHxz8vocC1q8xQtl1q)n1Xy8i10l1RgI)bsxCPoLutxP(WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4TudiGs9QH4VuNwQH(BQJX4rQPxQxne)dKU4sDkPwSsTyL6dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3sDkPMUsT5rESWBmhv25ebECQiVL6usnS74UZmH1XCYwdMYoNiCmPxZl1PKAy3XDNzcMFk7CIWXKEnVuNePgqaLAXk1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6usT5rESWBmhv25ebECQiVL6usnS74UZmH1XCYwdMYoNiCmPxZl1PKAy3XDNzcMFk7CIWXKEnVuNsQHDh3DMj8gZrLDor4ysVMxQtIuNePgqaL6vdXFPMEP2Hw1tGShSUFwrvghG9BiqhAvpiWSvmQGnjPpBeimhmYkZpm2EeajqgcGejhrlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bb(gZrLDobYqaKaiGOfbYJtf5nsyei8kJVYrGu4Rvq0IGVxjkpnzaNqQtj1hVo(Z7urwQbeqPE3w45JGht9wnyHJxh)5DQil1PKA6k1u4Rva29TRXnER8)D8OfWjqGo0QEqGpFe8yQ3QbdbcZbJSY8dJThbqcKHaiHycrlc0Hw1dc84Vh3Qbt531zqG84urEJegziasaur0Ia5XPI8gjmceELXx5iq6k1u4Rva29TRXnER8)D8OfWjqGo0QEqGWUVDnUXBL)VJhnKHaibqmIweipovK3iHrGWRm(khbsHVwbYEW6(z1c)YfWjKAabuQxne)L60sTdTQNq2kgvWMK0NDa6VPogJhPwOs9QH4FG0fxQbeqPMcFTcWUVDnUXBL)VJhTaobc0Hw1dcKShSUFwrvgJmea0riq0Ia5XPI8gjmc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKaziaOtceTiqECQiVrcJaHxz8vocC3witf3R6yfvtsfoED8N3PImc0Hw1dcmtf3R6yfvtsHmea0HoiArG84urEJegbcVY4RCeif(AfeTi47vIYttgWjqGo0QEqGpFe8yQ3QbdbcZbJSY8dJThbqcKHmeOtq1eiAraKarlc0Hw1dcmtf3QNOUYEeipovK3iHrgca6GOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMEPE1q8pq6IJaDOv9GaxrFYwdM6TRYYidbaqIOfb6qR6bbUIEoER(8THa5XPI8gjmYqaa0q0Ia5XPI8gjmceELXx5iWvdXFPoTud93uhJXJutVuVAi(hiDXrGo0QEqGB2T8kyEp75KidbqYr0IaDOv9GaZwXO6Z3gcKhNkYBKWidbaqarlcKhNkYBKWiq4vgFLJaPWxRaS7BxJB8w5)74rlGti1PKAk81ka7(214gVv()oE0cht618sn9sDIqYLAXqQXGBeOdTQheizpyD)SIQmgbcZbJSY8dJThbqcKHaqmHOfbYJtf5nsyei8kJVYrGu4Rva29TRXnER8)D8OfWjK6usnf(AfGDF7ACJ3k)FhpAHJj9AEPMEPori5sTyi1yWnc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKaziaaQiArG84urEJegbcVY4RCe4QH4VuNwQH(BQJX4rQPxQxne)dKU4iqhAvpiWv0NS1GPE7QSmYqaaeJOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMEPE1q8pq6Il1PKA6k1wbZwdMuNsQfRuVWJr1XW8(HXkRizPMEPgdULAabuQPRuVBlKPI7vDSIQjPcwbZwdMuNsQPWxRazpyD)SAHF5cht618sTqL6fEmQogM3pmwzfjl1afPoHulgsngCl1acOutxPE3witf3R6yfvtsfScMTgmPoLutxPMcFTcK9G19ZQf(LlCmPxZl1jrQbeqP2kswzTAxSutVuNaOk1PKA6k172czQ4EvhROAsQGvWS1GHaDOv9GaZuX9Qowr1KuidbqcHarlcKhNkYBKWiq4vgFLJaxne)L60sn0FtDmgpsn9s9QH4FG0fhb6qR6bb(gZrLDobYqaKibIweipovK3iHrGWRm(khbsHVwbYEW6(z1c)YfWjK6usnf(Afi7bR7Nvl8lx4ysVMxQPxQxne)LAAKAXk1o0QEcK9G19ZkQY4aSFtQbksn0FtDmgpsDsKAXqQXGBeOdTQheizpyD)SIQmgbcZbJSY8dJThbqcKHaibDq0Ia5XPI8gjmceELXx5iWfEmQogM3pmwzfjl10l1yWTuNsQxne)L60sn0FtDmgpsn9s9QH4FG0fxQtj1IvQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PKAy3XDNzcRJ5KTgmLDor4ysVMxQtj1WUJ7oZem)u25eHJj9AEPgqaLA6k1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6KGaDOv9GaZwXOc2KK(SrGWCWiRm)Wy7raKaziasaKiArG84urEJegbcVY4RCe4UTWZhbpM6TAWchVo(Z7urwQtj10vQPWxRazpyD)SAHF5cht618iqhAvpiWNpcEm1B1GHaH5Grwz(HX2JaibYqaKaOHOfbYJtf5nsyei8kJVYrGRgI)sDAPg6VPogJhPMEPE1q8pq6Il1PKAXk1u4RvGShSUFwTWVCH3CywPMEPo5snGak1RgI)sn9sTdTQNazpyD)SIQmoa73K6Ki1PKAXk1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6usnS74UZmH1XCYwdMYoNiCmPxZl1PKAy3XDNzcMFk7CIWXKEnVudiGsnDL6dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3sDsqGo0QEqGzRyubBssF2iqyoyKvMFyS9iasGmeajsoIweOdTQheORiXVnFQEPGxN5rG84urEJegziasaeq0IaDOv9Gap(7XTAWu(DDgeipovK3iHrgcGeIjeTiqhAvpiqy33Ug34TY)3XJgcKhNkYBKWidbqcGkIweipovK3iHrGWRm(khbsHVwbYEW6(z1c)YfWjKAabuQxne)L60sTdTQNq2kgvWMK0NDa6VPogJhPwOs9QH4FG0fxQbeqPMcFTcWUVDnUXBL)VJhTaobc0Hw1dcKShSUFwrvgJaH5Grwz(HX2JaibYqaKaigrlcKhNkYBKWiqhAvpiWZjS(uVDvwgbcZbJSY8dJThbqcKHaGocbIweipovK3iHrGWRm(khbsxP2ky2AWqGo0QEqGzQ4EvhROAskKHmKHafLVV6bbaDec6iejOtcGebMXVPgShbkMnzKyoaaIaGy(KPul10MNL6IKOptQx9j1jdoXBjds9XjfVoEl1FtYsTJBnPB8wQH59bJ)GeyHCnSuNaOLmLAGEpIYNXBPgSib6s9NBmxCPwij1wl1czCxQ3LO1x9i1nbFU1NulwAsIul2eINKGeyjWIztgjMdaGiaiMpzk1snT5zPUij6ZK6vFsDYamYUOCYGuFCsXRJ3s93KSu74wt6gVLAyEFW4pibwixdl1jeIKPud07ru(mEl1GfjqxQ)CJ5Il1cjP2APwiJ7s9UeT(QhPUj4ZT(KAXstsKAXMq8KeKalKRHL6e0jzk1a9EeLpJ3snyrc0L6p3yU4sTqsQTwQfY4UuVlrRV6rQBc(CRpPwS0KePwSjepjbjWc5AyPorYtMsnqVhr5Z4TudwKaDP(ZnMlUulKKARLAHmUl17s06REK6MGp36tQflnjrQfBcXtsqcSqUgwQtaesMsnqVhr5Z4TudwKaDP(ZnMlUulKKARLAHmUl17s06REK6MGp36tQflnjrQfBcXtsqcSeyXSjJeZbaqeaeZNmLAPM28SuxKe9zs9QpPozaU)KbP(4KIxhVL6VjzP2XTM0nEl1W8(GXFqcSqUgwQta0sMsnqVhr5Z4TudwKaDP(ZnMlUulKKARLAHmUl17s06REK6MGp36tQflnjrQfBcXtsqcSqUgwQtK8KPud07ru(mEl1GfjqxQ)CJ5Il1cjP2APwiJ7s9UeT(QhPUj4ZT(KAXstsKAXMq8KeKalKRHL6eaHKPud07ru(mEl1GfjqxQ)CJ5Il1cjP2APwiJ7s9UeT(QhPUj4ZT(KAXstsKAXMq8KeKalbwmBYiXCaaebaX8jtPwQPnpl1fjrFMuV6tQtgCcQMizqQpoP41XBP(BswQDCRjDJ3snmVpy8hKalKRHL6ejsMsnqVhr5Z4TudwKaDP(ZnMlUulKKARLAHmUl17s06REK6MGp36tQflnjrQfBcXtsqcSeyGiKe9z8wQbQsTdTQhPowV9bjWiqIRxvKrGarLAq8t0supk1IzIpgFsGbIk1IzWqMKIpPobqkIuthHGocHeyjWo0QE(aXXWMKYT0cO5Xjj7rrWMeyhAvpFG4yyts5wAb0q1Mf5TAf9C8otnykRfVgjWo0QE(aXXWMKYT0cOX8tzNtisTeC4dV6dJdFJhx9HXkMKIVpWjfVii4TeyhAvpFG4yyts5wAb08gZrLDoHeyjWo0QE(0cOHepzt2ilb2Hw1ZNwan4pRkJjFjWo0QE(0cOb6XOYHw1JkwVjY4KSaQMqKAjWHwjkR4Hjl(PhitrxZJ8ybpsK3vehVDRVapovK3POR5rESqMkUx1XQAw4F1tGhNkYBjWo0QE(0cOb6XOYHw1JkwVjY4KSaNGQjePwcCOvIYkEyYIF6bYuMh5XcEKiVRioE7wFbECQiVtrxZJ8yHmvCVQJv1SW)QNapovK3sGDOv98Pfqd0JrLdTQhvSEtKXjzboXBIulbo0krzfpmzXp9azkZJ8ybpsK3vehVDRVapovK3PmpYJfYuX9QowvZc)REc84urElb2Hw1ZNwanqpgvo0QEuX6nrgNKf8Mi1sGdTsuwXdtw8tpqMIUMh5XcEKiVRioE7wFbECQiVtzEKhlKPI7vDSQMf(x9e4XPI8wcSdTQNpTaAGEmQCOv9OI1BImojlagzxuwKAjWHwjkR4Hjl(fkDKa7qR65tlGg)G(WkRVJhtcSeyhAvpFWjOAcbzQ4w9e1v2lb2Hw1ZhCcQMiTaAwrFYwdM6TRYYIulbRgI)PH(BQJX4H(vdX)aPlUeyhAvpFWjOAI0cOzf9C8w95BtcSdTQNp4eunrAb0Sz3YRG59SNtksTeSAi(Ng6VPogJh6xne)dKU4sGDOv98bNGQjslGMSvmQ(8Tjb2Hw1ZhCcQMiTaAi7bR7NvuLXIaZbJSY8dJTxqcrQLak81ka7(214gVv()oE0c4ePOWxRaS7BxJB8w5)74rlCmPxZtFIqYfdm4wcSdTQNp4eunrAb0CoH1N6TRYYIaZbJSY8dJTxqcrQLak81ka7(214gVv()oE0c4ePOWxRaS7BxJB8w5)74rlCmPxZtFIqYfdm4wcSdTQNp4eunrAb0SI(KTgm1BxLLfPwcwne)td93uhJXd9RgI)bsxCjWo0QE(Gtq1ePfqtMkUx1XkQMKsKAjy1q8pn0FtDmgp0VAi(hiDXtrxRGzRblLyx4XO6yyE)WyLvKm9yWnGas3DBHmvCVQJvunjvWky2AWsrHVwbYEW6(z1c)YfoM0R5f6cpgvhdZ7hgRSIKbkjedm4gqaP7UTqMkUx1XkQMKkyfmBnyPOlf(Afi7bR7Nvl8lx4ysVMpjacOvKSYA1Uy6tautr3DBHmvCVQJvunjvWky2AWKa7qR65dobvtKwanVXCuzNtisTeSAi(Ng6VPogJh6xne)dKU4sGDOv98bNGQjslGgYEW6(zfvzSiWCWiRm)Wy7fKqKAjGcFTcK9G19ZQf(LlGtKIcFTcK9G19ZQf(LlCmPxZt)QH4VqsSo0QEcK9G19ZkQY4aSFdOa93uhJXtsedm4wcSdTQNp4eunrAb0KTIrfSjj9zlcmhmYkZpm2EbjePwcw4XO6yyE)WyLvKm9yWDQvdX)0q)n1Xy8q)QH4FG0fpLyp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccENc2DC3zMW6yozRbtzNteoM0R5tb7oU7mtW8tzNteoM0R5beq6E4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8ojsGDOv98bNGQjslGMNpcEm1B1GjcmhmYkZpm2EbjePwc2TfE(i4XuVvdw441XFENkYPOlf(Afi7bR7Nvl8lx4ysVMxcSdTQNp4eunrAb0KTIrfSjj9zlcmhmYkZpm2EbjePwcwne)td93uhJXd9RgI)bsx8uILcFTcK9G19ZQf(Ll8MdZsFYbeWvdXF6DOv9ei7bR7NvuLXby)wssj2dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3PGDh3DMjSoMt2AWu25eHJj9A(uWUJ7oZem)u25eHJj9AEabKUh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtIeyhAvpFWjOAI0cOXvK43MpvVuWRZ8sGDOv98bNGQjslGMJ)ECRgmLFxNrcSdTQNp4eunrAb0a7(214gVv()oE0Ka7qR65dobvtKwanK9G19ZkQYyrG5Grwz(HX2liHi1saf(Afi7bR7Nvl8lxaNaqaxne)t7qR6jKTIrfSjj9zhG(BQJX4rORgI)bsxCabKcFTcWUVDnUXBL)VJhTaoHeyhAvpFWjOAI0cO5CcRp1BxLLfbMdgzL5hgBVGesGDOv98bNGQjslGMmvCVQJvunjLi1saDTcMTgmjWsGDOv98bN4nbB2T8kyEp75KIulbRgI)PH(BQJX4H(vdX)aPlUeyhAvpFWjElTaAE(i4XuVvdMiWCWiRm)Wy7fKqKAjGU72cpFe8yQ3QblyfmBnyPm)WylyfjRSwTlwOIjjWo0QE(Gt8wAb0SIEoER(8Tjb2Hw1ZhCI3slGMJ)ECRgmLFxNrcSdTQNp4eVLwanzQ4w9e1v2lb2Hw1ZhCI3slGgy33Ug34TY)3XJMeyhAvpFWjElTaAYwXO6Z3MeyhAvpFWjElTaAwrFYwdM6TRYYIulbRgI)PH(BQJX4H(vdX)aPlUeyhAvpFWjElTaACfj(T5t1lf86mVeyhAvpFWjElTaAYuX9Qowr1KuIulbl8yuDmmVFySYksMEm4gqaxne)td93uhJXd9RgI)bsx8uIDyXnvMsr1Kubr7OBvKtTBl88rWJPERgSGvWS1GLA3w45JGht9wnyHJxh)5DQidiGdlUPYukQMKkqKNVMShofDPWxRazpyD)SAHF5c4ePwne)td93uhJXd9RgI)bsxCGIdTQNq2kgvWMK0NDa6VPogJhXaitcGaAfjRSwTlM(ecHeyhAvpFWjElTaAG(jklsTe4qReLv8WKf)cnrk6E4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNu8IGG3sGDOv98bN4T0cOHc3G55lNi1sGdTsuwXdtw8l0ePO7Hp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCsXlccENc2DC3zMqMkUx1XkQMKkSWJr1XW8(HXkRizH(eCmQm)Wy7tjwyE)W4xTohAvpEuO0jKCabC3w4ZFoXWrfvtsfScMTgSKib2Hw1ZhCI3slGM3yoQSZjePwcwne)td93uhJXd9RgI)bsxCjWo0QE(Gt8wAb0q2dw3pROkJfbMdgzL5hgBVGeIulbu4RvGShSUFwTWVCbCIuu4RvGShSUFwTWVCHJj9AE6xne)fsI1Hw1tGShSUFwrvghG9BafO)M6ymEsIyGb3POlf(AfYuXT6jQRSpCmPxZdiGu4RvGShSUFwTWVCHJj9A(udlUPYukQMKkqKNVMShwcSdTQNp4eVLwanzRyubBssF2IaZbJSY8dJTxqcrQLGfEmQogM3pmwzfjtpgCNA1q8pn0FtDmgp0VAi(hiDXLa7qR65doXBPfqZ5ewFQ3UkllcmhmYkZpm2EbjePwcOWxRGveQEPS8S6jy)cV5WScasabC3w4ZFoXWrfvtsfScMTgmjWo0QE(Gt8wAb0q2dw3pROkJfPwc2Tf(8NtmCur1KubRGzRbtcSdTQNp4eVLwanpFe8yQ3QbteyoyKvMFyS9csisTeC864pVtf5uMFySfSIKvwR2fluXKeyhAvpFWjElTaAYuX9Qowr1KuIulbdlUPYukQMKk85pNy4yQvdXFH6qR6jq2dw3pROkJdW(nXGoP2TfE(i4XuVvdw4ysVMxOjxmWGBjWo0QE(Gt8wAb0aZ7zpN8La7qR65doXBPfqt2kgvWMK0NTiWCWiRm)Wy7fKqKAjy1q8pn0FtDmgp0VAi(hiDXLa7qR65doXBPfqtMkUx1XkQMKsKAj4WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boP4fbbVLa7qR65doXBPfqdzpyD)SIQmweyoyKvMFyS9csisTeqHVwbYEW6(z1c)YfWjaeWvdX)0o0QEczRyubBssF2bO)M6ymEe6QH4FG0fhOKi5ac4UTWN)CIHJkQMKkyfmBnyacif(AfYuXT6jQRSpCmPxZlb2Hw1ZhCI3slGMZjS(uVDvwweyoyKvMFyS9csib2Hw1ZhCI3slGMmvCVQJvunjLi1sWWIBQmLIQjPcI2r3QiNA3w45JGht9wnybRGzRbdqahwCtLPuunjvGipFnzpmGaoS4MktPOAsQWN)CIHJPwne)fAYfcjWsGDOv98bQMqWZhbpM6TAWebMdgzL5hgBVGeIulbu4Rvq0IGVxjkpnz4ysVMpff(AfeTi47vIYttgoM0R5PhdULa7qR65dunrAb0KTIrfSjj9zlcmhmYkZpm2EbjePwcwne)td93uhJXd9RgI)bsx8uu4Rvy4)RblJF5ELDobrnykNGWp3W)aoHeyhAvpFGQjslGMmvCVQJvunjLi1sWQH4FAO)M6ymEOF1q8pq6INIUwbZwdwQfEmQogM3pmwzfjtpgClb2Hw1ZhOAI0cOjtf3QNOUYEjWo0QE(avtKwanROpzRbt92vzzrQLGvdX)0q)n1Xy8q)QH4FG0fxcSdTQNpq1ePfqZk654T6Z3MeyhAvpFGQjslGMn7wEfmVN9CsrQLGvdX)0q)n1Xy8q)QH4FG0fxcSdTQNpq1ePfqt2kgvF(2Ka7qR65dunrAb0CoH1N6TRYYIaZbJSY8dJTxqcrQLak81ka7(214gVv()oE0c4ePOWxRaS7BxJB8w5)74rlCmPxZtFIqYfdm4wcSdTQNpq1ePfqdzpyD)SIQmweyoyKvMFyS9csisTeqHVwby33Ug34TY)3XJwaNiff(AfGDF7ACJ3k)FhpAHJj9AE6tesUyGb3sGDOv98bQMiTaACfj(T5t1lf86mVeyhAvpFGQjslGMZjS(uVDvwweyoyKvMFyS9csisTeqHVwbRiu9sz5z1tW(fEZHzfaKsGDOv98bQMiTaAYuX9Qowr1KuIulbRgI)PH(BQJX4H(vdX)aPlEk6AfmBnyPe7cpgvhdZ7hgRSIKPhdUbeq6UBlKPI7vDSIQjPcwbZwdwkk81kq2dw3pRw4xUWXKEnVqx4XO6yyE)WyLvKmqjHyGb3aciD3TfYuX9Qowr1KubRGzRblfDPWxRazpyD)SAHF5cht618jbqaTIKvwR2ftFcGAk6UBlKPI7vDSIQjPcwbZwdMeyhAvpFGQjslGMSvmQGnjPpBrG5Grwz(HX2liHi1sWQH4FAO)M6ymEOF1q8pq6INIUh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVbeWvdX)0q)n1Xy8q)QH4FG0fpLyf7Hp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqW7u018ipw4nMJk7CIapovK3PGDh3DMjSoMt2AWu25eHJj9A(uWUJ7oZem)u25eHJj9A(KaiGI9WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4DkZJ8yH3yoQSZjc84urENc2DC3zMW6yozRbtzNteoM0R5tb7oU7mtW8tzNteoM0R5tb7oU7mt4nMJk7CIWXKEnFsscGaUAi(tVdTQNazpyD)SIQmoa73Ka7qR65dunrAb08gZrLDoHi1sWQH4FAO)M6ymEOF1q8pq6Ilb2Hw1ZhOAI0cO55JGht9wnyIaZbJSY8dJTxqcrQLak81kiArW3ReLNMmGtK641XFENkYac4UTWZhbpM6TAWchVo(Z7urofDPWxRaS7BxJB8w5)74rlGtib2Hw1ZhOAI0cO54Vh3Qbt531zKa7qR65dunrAb0a7(214gVv()oE0ePwcOlf(AfGDF7ACJ3k)FhpAbCcjWo0QE(avtKwanK9G19ZkQYyrQLak81kq2dw3pRw4xUaobGaUAi(N2Hw1tiBfJkyts6Zoa93uhJXJqxne)dKU4acif(AfGDF7ACJ3k)FhpAbCcjWo0QE(avtKwanNty9PE7QSSiWCWiRm)Wy7fKqcSdTQNpq1ePfqtMkUx1XkQMKsKAjy3witf3R6yfvtsfoED8N3PISeyhAvpFGQjslGMNpcEm1B1GjcmhmYkZpm2EbjePwcOWxRGOfbFVsuEAYaoHeyjWo0QE(aC)cY7hr3Ji1sG5rESGXh5R6LIhmhJj5Xc84urENA1q8N(vdX)aPlUeyhAvpFaU)0cOHk29wTWVCIulbWUJ7oZeGDF7ACJ3k)FhpAHJj9AEHcKcHeyhAvpFaU)0cOXhi)25rf0JrrQLay3XDNzcWUVDnUXBL)VJhTWXKEnVqbsHqcSdTQNpa3FAb0SQJPIDVfPwcGDh3DMja7(214gVv()oE0cht618cfifcjWo0QE(aC)PfqtSWYBVkzm(gJKhtcSdTQNpa3FAb0q5yQEPSRGzFrQLay3XDNzczRyubBssF2HfEmQogM3pmwzfjlum4wcSdTQNpa3FAb0qX3Zx2AWePwcGDh3DMja7(214gVv()oE0cht618cfiieacOvKSYA1Uy6taKsGDOv98b4(tlGgs8KnzJSeyhAvpFaU)0cOHOTQhrQLaZpm2cwrYkRv7IPhiieacif(AfGDF7ACJ3k)FhpAbCcjWo0QE(aC)PfqZBmhv25eIulbh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtTAi(Ng6VPogJh6xne)dKU4sGDOv98b4(tlGM1XCYwdMYoNqKAj4WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4DQvdX)0q)n1Xy8q)QH4FG0fxcSdTQNpa3FAb0y(PSZjePwco8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccENA1q8pn0FtDmgp0VAi(hiDXbeWvdX)0q)n1Xy8q)QH4FG0fp1Hp8Qpmo8nEC1hgRysk((aNu8IGG3Pm)u25eHJj9AE6XG7uWUJ7oZewr)4WXKEnp9yWDkX6qReLv8WKf)cnbGa6qReLv8WKf)csKYkswzTAxSqtUyGb3jrcSdTQNpa3FAb0SI(XIeRHvWTa6KCrQLGvdX)0q)n1Xy8q)QH4FG0fpL5NYoNiGtK6WhE1hgh(gpU6dJvmjfFFGtkErqW7uwrYkRv7IfkqtmWGBjWo0QE(aC)Pfqt2kgvF(2ePwcCOvIYkEyYIFbjsz(HXwWkswzTAxm9RgI)cjX6qR6jq2dw3pROkJdW(nGc0FtDmgpjrmWGBjWo0QE(aC)PfqdzpyD)SIQmwKAjWHwjkR4Hjl(fKiL5hgBbRizL1QDX0VAi(lKeRdTQNazpyD)SIQmoa73akq)n1Xy8KeXadULa7qR65dW9NwanNty9PE7QSSi1sGdTsuwXdtw8lirkZpm2cwrYkRv7IPF1q8xijwhAvpbYEW6(zfvzCa2VbuG(BQJX4jjIbgClb2Hw1ZhG7pTaA8NGHMQxklpRyhlYIulbMFySf21B(azHkaiibwcSdTQNpaJSlkl45JGht9wnyIaZbJSY8dJTxqcrQLaZJ8yH852N)kQY4apovK3POWxRGOfbFVsuEAYWXKEnFkk81kiArW3ReLNMmCmPxZtpgClb2Hw1ZhGr2fLtlGMmvCREI6k7La7qR65dWi7IYPfqZXFpUvdMYVRZib2Hw1ZhGr2fLtlGMmvCVQJvunjLi1sWcpgvhdZ7hgRSIKPhdULa7qR65dWi7IYPfqdmVN9CYxcSdTQNpaJSlkNwanu4gmpF5ePwc2Tf(8NtmCur1KubRGzRblLy3TfQX4B8OIkY8UgSWBoml90bqa3Tf(8NtmCur1KuHJj9AE6XG7Kib2Hw1ZhGr2fLtlGgOFIYIulb72cF(ZjgoQOAsQGvWS1Gjb2Hw1ZhGr2fLtlGMn7wEfmVN9CsrQLGvdX)0q)n1Xy8q)QH4FG0fxcSdTQNpaJSlkNwanWUVDnUXBL)VJhnjWo0QE(amYUOCAb0qHBW88LtKAjaM3pm(vRZHw1JhfkDcjpfS74UZmHmvCVQJvunjvyHhJQJH59dJvwrYc9j4yuz(HX2lKOJeyhAvpFagzxuoTaAwrFYwdM6TRYYIulbRgI)PH(BQJX4H(vdX)aPlUeyhAvpFagzxuoTaAG(jklsTea7oU7mtitf3R6yfvtsfw4XO6yyE)WyLvKSqFcogvMFyS9cj6KY8ipwWJe5DfXXB36lWJtf5TeyhAvpFagzxuoTaAYwXOc2KK(SfbMdgzL5hgBVGeIulbRgI)PH(BQJX4H(vdX)aPlEQfEmQogM3pmwzfjtpgCNsSh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtb7oU7mtyDmNS1GPSZjcht618PGDh3DMjy(PSZjcht618aciDp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccENejWo0QE(amYUOCAb0KPI7vDSIQjPePwcO7UTqMkUx1XkQMKkyfmBnysGDOv98byKDr50cOHc3G55lNi1sGyP7WIBQmLIQjPcF(ZjgociG018ipwitf3R6yvnl8V6jWJtf5Dssb7oU7mtitf3R6yfvtsfw4XO6yyE)WyLvKSqFcogvMFyS9cj6ib2Hw1ZhGr2fLtlGgOFIYIulbWUJ7oZeYuX9Qowr1KuHfEmQogM3pmwzfjl0NGJrL5hgBVqIosGDOv98byKDr50cOjBfJQpFBsGDOv98byKDr50cOzf9C8w95BtcSdTQNpaJSlkNwanUIe)28P6LcEDMxcSdTQNpaJSlkNwanVXCuzNtib2Hw1ZhGr2fLtlGMNpcEm1B1GjcmhmYkZpm2EbjePwcoED8N3PICkZJ8yH852N)kQY4apovK3Pm)WylyfjRSwTlwOavjWo0QE(amYUOCAb0a9tuwcSdTQNpaJSlkNwanzRyubBssF2IaZbJSY8dJTxqcrQLGvdX)0q)n1Xy8q)QH4FG0fpLyp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccENc2DC3zMW6yozRbtzNteoM0R5tb7oU7mtW8tzNteoM0R5beq6E4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8ojsGDOv98byKDr50cO55JGht9wnyIaZbJSY8dJTxqcrQLGJxh)5DQilb2Hw1ZhGr2fLtlGgYEW6(zfvzSiWCWiRm)Wy7fKqcSdTQNpaJSlkNwanNty9PE7QSSiWCWiRm)Wy7fKqcSeyhAvpF4nbRONJ3QpFBsGDOv98H3slGMmvCREI6k7La7qR65dVLwanh)94wnyk)UoJeyhAvpF4T0cO55JGht9wnyIaZbJSY8dJTxqcrQLak81kiArW3ReLNMmGtKIcFTcIwe89kr5Pjdht6180Jb3aciDTcMTgmjWo0QE(WBPfqZMDlVcM3ZEoPi1sWQH4FAO)M6ymEOF1q8pq6Ilb2Hw1ZhElTaAoNW6t92vzzrG5Grwz(HX2liHi1saf(AfSIq1lLLNvpb7x4nhMvaqkb2Hw1ZhElTaAGDF7ACJ3k)FhpAsGDOv98H3slGMSvmQ(8Tjb2Hw1ZhElTaAYuX9Qowr1KuIulbl8yuDmmVFySYksMEm4o1QH4FAO)M6ymEOF1q8pq6IdiGIDyXnvMsr1Kubr7OBvKtTBl88rWJPERgSGvWS1GLA3w45JGht9wnyHJxh)5DQidiGdlUPYukQMKkqKNVMSho1QH4FAO)M6ymEOF1q8pq6IduCOv9eYwXOc2KK(Sdq)n1Xy8igazk6sHVwbYEW6(z1c)YfoM0R5tIeyhAvpF4T0cO5nMJk7CcrQLGvdX)0q)n1Xy8q)QH4FG0fxcSdTQNp8wAb0SI(KTgm1BxLLfPwcwne)td93uhJXd9RgI)bsxCjWo0QE(WBPfqt2kgvWMK0NTiWCWiRm)Wy7fKqKAjy1q8pn0FtDmgp0VAi(hiDXtj2dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3PGDh3DMjSoMt2AWu25eHJj9A(uWUJ7oZem)u25eHJj9AEabKUh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtIeyhAvpF4T0cOb6NOSi1sGdTsuwXdtw8l0ePO7Hp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCsXlccElb2Hw1ZhElTaAOWnyE(YjsTe4qReLv8WKf)cnrk6E4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNu8IGG3PGDh3DMjKPI7vDSIQjPcl8yuDmmVFySYkswOpbhJkZpm2(uIfM3pm(vRZHw1JhfkDcjhqa3Tf(8NtmCur1KubRGzRbljsGDOv98H3slGgxrIFB(u9sbVoZlb2Hw1ZhElTaAi7bR7NvuLXIaZbJSY8dJTxqcrQLGDBHp)5edhvunjvWky2AWaeqk81kq2dw3pRw4xUWBomRGKlb2Hw1ZhElTaAE(i4XuVvdMiWCWiRm)Wy7fKqKAj441XFENkYacif(AfeTi47vIYttgWjKa7qR65dVLwanzQ4EvhROAskrQLGHf3uzkfvtsf(8NtmCm1UTWZhbpM6TAWcht618cn5IbgCdiGh(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjfVii4TeyhAvpF4T0cObM3ZEo5lb2Hw1ZhElTaAi7bR7NvuLXIaZbJSY8dJTxqcrQLak81kq2dw3pRw4xUaobGaUAi(N2Hw1tiBfJkyts6Zoa93uhJXJqxne)dKU4aLejhqa3Tf(8NtmCur1KubRGzRbtcSdTQNp8wAb0CoH1N6TRYYIaZbJSY8dJTxqcjWo0QE(WBPfqtMkUx1XkQMKsKAjyyXnvMsr1Kubr7OBvKtTBl88rWJPERgSGvWS1GbiGdlUPYukQMKkqKNVMShgqahwCtLPuunjv4ZFoXWre4tWqea0j5jhzidHa]] )

end