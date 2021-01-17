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

    spec:RegisterPack( "Survival", 20210117, [[dyuh8bqicWJausUeHISjrYNerbJIqPtjIyvek8krQzriUfGc7sWVqedJGshtewgb0ZauzAaQQRjIQTbOOVbOkJdqPohGsSoru08iq3drTpcQoiHIklKG8qck8rcfLgjGsQoPik0kbKzsqr7ealLqrXtbAQisFLqrv7fYFjzWK6WuTyK8yqtwPUmQnRKpdLrlQ60swnGskVwuA2cDBKA3k(TudhHJlI0Yv55QA6uUouTDcPVlkgpHQZlQSEruA(a0(jAucePiWTBmcabkScmHWMibWlKircGDYtGaTCemcKWHzDmgboonJabXprlr9icKWZfBFJifb(n(bzeiWkPoVzeFYKesWklpova20K8fnE0TQh45lJKVOHKGaPWROLmoike42ngbGafwbMqytKa4fsKibWo5iqh3Y3hceSOfgiW81EZdIcbU5hIabwj1G4NOLOEuQbwhFm(KabSsQbYhC)Yj1jaEIi1cuyfyceySE7rKIaDI3qKIaibIueipovK3iHqGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aTloc0Hw1dcCZULxbZ7zpNgziaeiIueipovK3iHqGo0QEqGpFe8yQ3QbdbcVY4RCeOaK6DBHNpcEm1B1GfScMTgmPoLuB(HXwWkAwzTAxSulCPg4HaH5Grwz(HX2JaibYqaaCisrGo0QEqGRONJ3QpFBiqECQiVrcHmeaaFePiqhAvpiWJ)ECRgmLFxNbbYJtf5nsiKHai5isrGo0QEqGzQ4w9e1v2Ja5XPI8gjeYqaamrKIaDOv9GaHDF7ACJ3k)FhpAiqECQiVrcHmeaapePiqhAvpiWSvmQ(8THa5XPI8gjeYqaaSrKIa5XPI8gjeceELXx5iWvdXFPoTud93uhJXJulOuVAi(hODXrGo0QEqGROpzRbt92vzzKHaaybrkc0Hw1dc0v043MpvVuWRZ8iqECQiVrcHmeajewePiqECQiVrcHaHxz8vocCHhJQJH59dJvwrZsTGsngCl1acOuVAi(l1PLAO)M6ymEKAbL6vdX)aTlUuNsQfRupS4MktPOAAQGOD0TkYsDkPE3w45JGht9wnybRGzRbtQtj172cpFe8yQ3QblC864pVtfzPgqaL6Hf3uzkfvttfiYZxt3dl1PKAbi1u4RvGUhSUFwTWVCbCcPoLuVAi(l1PLAO)M6ymEKAbL6vdX)aTlUudmKAhAvpHSvmQGnnTp7a0FtDmgpsTyi1aNuNePgqaLAROzL1QDXsTGsDcHfb6qR6bbMPI7vDSIQPPqgcGejqKIa5XPI8gjeceELXx5iqhALOSIhMU4xQfUuNqQtj1cqQp8Hx9HXHlx0Z(MhZY3RG9SA8zxdM6TRYYFGtkErqWBeOdTQhei0przKHaiHarKIa5XPI8gjeceELXx5iqhALOSIhMU4xQfUuNqQtj1cqQp8Hx9HXHlx0Z(MhZY3RG9SA8zxdM6TRYYFGtkErqWBPoLud7oU7mtitf3R6yfvttfw4XO6yyE)WyLv0SulCP(j4yuz(HX2l1PKAXk1W8(HXVADo0QE8OulCPwGHKl1acOuVBl85pNy4OIQPPcwbZwdMuNeeOdTQheifUbZZxoKHaibWHifbYJtf5nsiei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq7IJaDOv9GaFJ5OYoNaziasa8rKIa5XPI8gjec0Hw1dcKUhSUFwrvgJaHxz8vocKcFTc09G19ZQf(LlGti1PKAk81kq3dw3pRw4xUWX0EnVulOuVAi(l1Ki1IvQDOv9eO7bR7NvuLXby)MudmKAO)M6ymEK6Ki1IHuJb3sDkPwasnf(AfYuXT6jQRSpCmTxZl1acOutHVwb6EW6(z1c)YfoM2R5L6us9WIBQmLIQPPce55RP7HrGWCWiRm)Wy7raKaziasKCePiqECQiVrcHaDOv9GaZwXOc200(SrGWRm(khbUWJr1XW8(HXkROzPwqPgdUL6us9QH4VuNwQH(BQJX4rQfuQxne)d0U4iqyoyKvMFyS9iasGmeajaMisrG84urEJecb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRGveQEPS8S6jy)cV5WSsnzPg4KAabuQ3Tf(8NtmCur10ubRGzRbdbcZbJSY8dJThbqcKHaibWdrkcKhNkYBKqiq4vgFLJa3Tf(8NtmCur10ubRGzRbdb6qR6bbs3dw3pROkJrgcGeaBePiqECQiVrcHaDOv9GaF(i4XuVvdgceELXx5iWJxh)5DQil1PKAZpm2cwrZkRv7ILAHl1apeimhmYkZpm2EeajqgcGealisrG84urEJecbcVY4RCe4WIBQmLIQPPcF(Zjgok1PK6vdXFPw4sTdTQNaDpyD)SIQmoa73KAXqQfOuNsQ3TfE(i4XuVvdw4yAVMxQfUuNCPwmKAm4gb6qR6bbMPI7vDSIQPPqgcabkSisrGo0QEqGW8E2ZPFeipovK3iHqgcabMarkcKhNkYBKqiqhAvpiWSvmQGnnTpBei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq7IJaH5Grwz(HX2JaibYqaiqbIifbYJtf5nsiei8kJVYrGh(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjfVii4nc0Hw1dcmtf3R6yfvttHmeace4qKIa5XPI8gjec0Hw1dcKUhSUFwrvgJaHxz8vocKcFTc09G19ZQf(LlGti1acOuVAi(l1PLAhAvpHSvmQGnnTp7a0FtDmgpsTWL6vdX)aTlUudmK6ejxQbeqPE3w4ZFoXWrfvttfScMTgmPgqaLAk81kKPIB1tuxzF4yAVMhbcZbJSY8dJThbqcKHaqGaFePiqECQiVrcHaDOv9GapNW6t92vzzeimhmYkZpm2EeajqgcabMCePiqECQiVrcHaHxz8vocCyXnvMsr10ubr7OBvKL6us9UTWZhbpM6TAWcwbZwdMudiGs9WIBQmLIQPPce55RP7HLAabuQhwCtLPuunnv4ZFoXWrPoLuVAi(l1cxQtUWIaDOv9GaZuX9Qowr10uidziqyKDrzePiasGifbYJtf5nsieOdTQhe4ZhbpM6TAWqGWRm(khbAEKhlKp3(8xrvgh4XPI8wQtj1u4Rvq0IGVxjkpnD4yAVMxQtj1u4Rvq0IGVxjkpnD4yAVMxQfuQXGBeimhmYkZpm2EeajqgcabIifb6qR6bbMPIB1tuxzpcKhNkYBKqidbaWHifb6qR6bbE83JB1GP876miqECQiVrcHmeaaFePiqECQiVrcHaHxz8vocCHhJQJH59dJvwrZsTGsngCJaDOv9GaZuX9Qowr10uidbqYrKIaDOv9GaH59SNt)iqECQiVrcHmeaatePiqECQiVrcHaHxz8vocC3w4ZFoXWrfvttfScMTgmPoLulwPE3wOgJVXJkQiZ7AWcV5WSsTGsTaLAabuQ3Tf(8NtmCur10uHJP9AEPwqPgdUL6KGaDOv9GaPWnyE(YHmeaapePiqECQiVrcHaHxz8vocC3w4ZFoXWrfvttfScMTgmeOdTQhei0przKHaayJifbYJtf5nsiei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq7IJaDOv9Ga3SB5vW8E2ZPrgcaGfePiqhAvpiqy33Ug34TY)3XJgcKhNkYBKqidbqcHfrkcKhNkYBKqiq4vgFLJaH59dJF16COv94rPw4sTadjxQtj1WUJ7oZeYuX9Qowr10uHfEmQogM3pmwzfnl1cxQFcogvMFyS9snjsTarGo0QEqGu4gmpF5qgcGejqKIa5XPI8gjeceELXx5iWvdXFPoTud93uhJXJulOuVAi(hODXrGo0QEqGROpzRbt92vzzKHaiHarKIa5XPI8gjeceELXx5iqy3XDNzczQ4EvhROAAQWcpgvhdZ7hgRSIMLAHl1pbhJkZpm2EPMePwGsDkP28ipwWJe5DfXXB36lWJtf5nc0Hw1dce6NOmYqaKa4qKIa5XPI8gjec0Hw1dcmBfJkytt7ZgbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)d0U4sDkPEHhJQJH59dJvwrZsTGsngCl1PKAXk1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6usnS74UZmH1XCYwdMYoNiCmTxZl1PKAy3XDNzcMFk7CIWX0EnVudiGsTaK6dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3sDsqGWCWiRm)Wy7raKaziasa8rKIa5XPI8gjeceELXx5iqbi172czQ4EvhROAAQGvWS1GHaDOv9GaZuX9Qowr10uidbqIKJifbYJtf5nsiei8kJVYrGIvQfGupS4MktPOAAQWN)CIHJsnGak1cqQnpYJfYuX9QowvZc)REc84urEl1jrQtj1WUJ7oZeYuX9Qowr10uHfEmQogM3pmwzfnl1cxQFcogvMFyS9snjsTarGo0QEqGu4gmpF5qgcGeatePiqECQiVrcHaHxz8voce2DC3zMqMkUx1XkQMMkSWJr1XW8(HXkROzPw4s9tWXOY8dJTxQjrQfic0Hw1dce6NOmYqaKa4Hifb6qR6bbMTIr1NVneipovK3iHqgcGeaBePiqhAvpiWv0ZXB1NVneipovK3iHqgcGealisrGo0QEqGUIg)28P6LcEDMhbYJtf5nsiKHaqGclIueOdTQhe4Bmhv25eiqECQiVrcHmeacmbIueipovK3iHqGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)8ovKL6usT5rESq(C7ZFfvzCGhNkYBPoLuB(HXwWkAwzTAxSulCPgyJaH5Grwz(HX2JaibYqaiqbIifb6qR6bbc9tugbYJtf5nsiKHaqGahIueipovK3iHqGo0QEqGzRyubBAAF2iq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG2fxQtj1IvQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PKAy3XDNzcRJ5KTgmLDor4yAVMxQtj1WUJ7oZem)u25eHJP9AEPgqaLAbi1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6KGaH5Grwz(HX2JaibYqaiqGpIueipovK3iHqGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)8ovKrGWCWiRm)Wy7raKaziaeyYrKIa5XPI8gjec0Hw1dcKUhSUFwrvgJaH5Grwz(HX2JaibYqaiqGjIueipovK3iHqGo0QEqGNty9PE7QSmceMdgzL5hgBpcGeidziWnVC8OHifbqcePiqhAvpiqA8KnzJmcKhNkYBKqidbGarKIaDOv9GaTZNKIxXkzRbt95BdbYJtf5nsiKHaa4qKIaDOv9GaXFwvgt)iqECQiVrcHmeaaFePiqECQiVrcHaDOv9GaHEmQCOv9OI1BiWy9MACAgbc3pYqaKCePiqECQiVrcHaHxz8voc0HwjkR4HPl(LAbLAGtQtj1cqQnpYJf8irExrC82T(c84urEl1PKAbi1Mh5XczQ4EvhRQzH)vpbECQiVrGo0QEqGqpgvo0QEuX6neySEtnonJaPAcKHaayIifbYJtf5nsiei8kJVYrGo0krzfpmDXVulOudCsDkP28ipwWJe5DfXXB36lWJtf5TuNsQfGuBEKhlKPI7vDSQMf(x9e4XPI8gb6qR6bbc9yu5qR6rfR3qGX6n140mc0jOAcKHaa4HifbYJtf5nsiei8kJVYrGo0krzfpmDXVulOudCsDkP28ipwWJe5DfXXB36lWJtf5TuNsQnpYJfYuX9QowvZc)REc84urEJaDOv9GaHEmQCOv9OI1BiWy9MACAgb6eVHmeaaBePiqECQiVrcHaHxz8voc0HwjkR4HPl(LAbLAGtQtj1cqQnpYJf8irExrC82T(c84urEl1PKAZJ8yHmvCVQJv1SW)QNapovK3iqhAvpiqOhJkhAvpQy9gcmwVPgNMrGVHmeaalisrG84urEJecbcVY4RCeOdTsuwXdtx8l1cxQfic0Hw1dce6XOYHw1JkwVHaJ1BQXPzeimYUOmYqaKqyrKIaDOv9Ga9d6dRS(oEmeipovK3iHqgYqGobvtGifbqcePiqhAvpiWmvCREI6k7rG84urEJecziaeiIueipovK3iHqGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aTloc0Hw1dcCf9jBnyQ3UklJmeaahIueOdTQhe4k654T6Z3gcKhNkYBKqidbaWhrkcKhNkYBKqiq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG2fhb6qR6bbUz3YRG59SNtJmeajhrkc0Hw1dcmBfJQpFBiqECQiVrcHmeaatePiqECQiVrcHaDOv9GaP7bR7NvuLXiq4vgFLJaPWxRaS7BxJB8w5)74rlGti1PKAk81ka7(214gVv()oE0cht718sTGsDIqYLAXqQXGBeimhmYkZpm2EeajqgcaGhIueipovK3iHqGo0QEqGNty9PE7QSmceELXx5iqk81ka7(214gVv()oE0c4esDkPMcFTcWUVDnUXBL)VJhTWX0EnVulOuNiKCPwmKAm4gbcZbJSY8dJThbqcKHaayJifbYJtf5nsiei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq7IJaDOv9GaxrFYwdM6TRYYidbaWcIueipovK3iHqGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aTlUuNsQfGuBfmBnysDkPwSs9cpgvhdZ7hgRSIMLAbLAm4wQbeqPwas9UTqMkUx1XkQMMkyfmBnysDkPMcFTc09G19ZQf(LlCmTxZl1cxQx4XO6yyE)WyLv0SudmK6esTyi1yWTudiGsTaK6DBHmvCVQJvunnvWky2AWK6usTaKAk81kq3dw3pRw4xUWX0EnVuNePgqaLAROzL1QDXsTGsDcGTuNsQfGuVBlKPI7vDSIQPPcwbZwdgc0Hw1dcmtf3R6yfvttHmeajewePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCeOdTQhe4Bmhv25eidbqIeisrG84urEJecb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YfWjK6usnf(AfO7bR7Nvl8lx4yAVMxQfuQxne)LAsKAXk1o0QEc09G19ZkQY4aSFtQbgsn0FtDmgpsDsKAXqQXGBeimhmYkZpm2EeajqgcGecerkcKhNkYBKqiqhAvpiWSvmQGnnTpBei8kJVYrGl8yuDmmVFySYkAwQfuQXGBPoLuVAi(l1PLAO)M6ymEKAbL6vdX)aTlUuNsQfRuF4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8wQtj1WUJ7oZewhZjBnyk7CIWX0EnVuNsQHDh3DMjy(PSZjcht718snGak1cqQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1jbbcZbJSY8dJThbqcKHaibWHifbYJtf5nsieOdTQhe4ZhbpM6TAWqGWRm(khbUBl88rWJPERgSWXRJ)8ovKL6usTaKAk81kq3dw3pRw4xUWX0EnpceMdgzL5hgBpcGeidbqcGpIueipovK3iHqGo0QEqGzRyubBAAF2iq4vgFLJaxne)L60sn0FtDmgpsTGs9QH4FG2fxQtj1IvQPWxRaDpyD)SAHF5cV5WSsTGsDYLAabuQxne)LAbLAhAvpb6EW6(zfvzCa2Vj1jrQtj1IvQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PKAy3XDNzcRJ5KTgmLDor4yAVMxQtj1WUJ7oZem)u25eHJP9AEPgqaLAbi1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6KGaH5Grwz(HX2JaibYqaKi5isrGo0QEqGUIg)28P6LcEDMhbYJtf5nsiKHaibWerkc0Hw1dc84Vh3Qbt531zqG84urEJecziasa8qKIaDOv9GaHDF7ACJ3k)FhpAiqECQiVrcHmeaja2isrG84urEJecb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YfWjKAabuQxne)L60sTdTQNq2kgvWMM2NDa6VPogJhPw4s9QH4FG2fxQbeqPMcFTcWUVDnUXBL)VJhTaobceMdgzL5hgBpcGeidbqcGfePiqECQiVrcHaDOv9GapNW6t92vzzeimhmYkZpm2EeajqgcabkSisrG84urEJecbcVY4RCeOaKARGzRbdb6qR6bbMPI7vDSIQPPqgYqGVHifbqcePiqhAvpiWv0ZXB1NVneipovK3iHqgcabIifb6qR6bbMPIB1tuxzpcKhNkYBKqidbaWHifb6qR6bbE83JB1GP876miqECQiVrcHmeaaFePiqECQiVrcHaDOv9GaF(i4XuVvdgceELXx5iqk81kiArW3ReLNMoGti1PKAk81kiArW3ReLNMoCmTxZl1ck1yWTudiGsTaKARGzRbdbcZbJSY8dJThbqcKHai5isrG84urEJecbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)d0U4iqhAvpiWn7wEfmVN9CAKHaayIifbYJtf5nsieOdTQhe45ewFQ3UklJaHxz8vocKcFTcwrO6LYYZQNG9l8MdZk1KLAGdbcZbJSY8dJThbqcKHaa4Hifb6qR6bbc7(214gVv()oE0qG84urEJecziaa2isrGo0QEqGzRyu95BdbYJtf5nsiKHaaybrkcKhNkYBKqiq4vgFLJax4XO6yyE)WyLv0SulOuJb3sDkPE1q8xQtl1q)n1Xy8i1ck1RgI)bAxCPgqaLAXk1dlUPYukQMMkiAhDRISuNsQ3TfE(i4XuVvdwWky2AWK6us9UTWZhbpM6TAWchVo(Z7urwQbeqPEyXnvMsr10ubI88109WsDkPE1q8xQtl1q)n1Xy8i1ck1RgI)bAxCPgyi1o0QEczRyubBAAF2bO)M6ymEKAXqQboPoLulaPMcFTc09G19ZQf(LlCmTxZl1jbb6qR6bbMPI7vDSIQPPqgcGeclIueipovK3iHqGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aTloc0Hw1dc8nMJk7CcKHaircePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCeOdTQhe4k6t2AWuVDvwgziasiqePiqECQiVrcHaDOv9GaZwXOc200(SrGWRm(khbUAi(l1PLAO)M6ymEKAbL6vdX)aTlUuNsQfRuF4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8wQtj1WUJ7oZewhZjBnyk7CIWX0EnVuNsQHDh3DMjy(PSZjcht718snGak1cqQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1jbbcZbJSY8dJThbqcKHaibWHifbYJtf5nsiei8kJVYrGo0krzfpmDXVulCPoHuNsQfGuF4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNu8IGG3iqhAvpiqOFIYidbqcGpIueipovK3iHqGWRm(khb6qReLv8W0f)sTWL6esDkPwas9Hp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCsXlccEl1PKAy3XDNzczQ4EvhROAAQWcpgvhdZ7hgRSIMLAHl1pbhJkZpm2EPoLulwPgM3pm(vRZHw1JhLAHl1cmKCPgqaL6DBHp)5edhvunnvWky2AWK6KGaDOv9GaPWnyE(YHmeajsoIueOdTQheOROXVnFQEPGxN5rG84urEJecziasamrKIa5XPI8gjec0Hw1dcKUhSUFwrvgJaHxz8vocC3w4ZFoXWrfvttfScMTgmPgqaLAk81kq3dw3pRw4xUWBomRutwQtoceMdgzL5hgBpcGeidbqcGhIueipovK3iHqGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)8ovKLAabuQPWxRGOfbFVsuEA6aobceMdgzL5hgBpcGeidbqcGnIueipovK3iHqGWRm(khboS4MktPOAAQWN)CIHJsDkPE3w45JGht9wnyHJP9AEPw4sDYLAXqQXGBPgqaL6dF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4KIxee8gb6qR6bbMPI7vDSIQPPqgcGealisrGo0QEqGW8E2ZPFeipovK3iHqgcabkSisrG84urEJecb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YfWjKAabuQxne)L60sTdTQNq2kgvWMM2NDa6VPogJhPw4s9QH4FG2fxQbgsDIKl1acOuVBl85pNy4OIQPPcwbZwdgceMdgzL5hgBpcGeidbGatGifbYJtf5nsieOdTQhe45ewFQ3UklJaH5Grwz(HX2JaibYqaiqbIifbYJtf5nsiei8kJVYrGdlUPYukQMMkiAhDRISuNsQ3TfE(i4XuVvdwWky2AWKAabuQhwCtLPuunnvGipFnDpSudiGs9WIBQmLIQPPcF(ZjgoIaDOv9GaZuX9Qowr10uidziq4(rKIaibIueipovK3iHqGWRm(khbAEKhly8r)QEP4bZXyAESapovK3sDkPE1q8xQfuQxne)d0U4iqhAvpiW8(r09GmeacerkcKhNkYBKqiq4vgFLJaHDh3DMja7(214gVv()oE0cht718sTWLAGtyrGo0QEqGuXU3Qf(LdziaaoePiqECQiVrcHaHxz8voce2DC3zMaS7BxJB8w5)74rlCmTxZl1cxQboHfb6qR6bb6dKF78Oc6XiYqaa8rKIa5XPI8gjeceELXx5iqy3XDNzcWUVDnUXBL)VJhTWX0EnVulCPg4eweOdTQhe4QoMk29gziasoIueOdTQheySWYBVcyn8ngnpgcKhNkYBKqidbaWerkcKhNkYBKqiq4vgFLJaHDh3DMjKTIrfSPP9zhw4XO6yyE)WyLv0SulCPgdUrGo0QEqGuoMQxk7ky2hziaaEisrG84urEJecbcVY4RCeiS74UZmby33Ug34TY)3XJw4yAVMxQfUudmfwPgqaLAROzL1QDXsTGsDcGdb6qR6bbsX3Zx2AWqgcaGnIueOdTQheinEYMSrgbYJtf5nsiKHaaybrkcKhNkYBKqiq4vgFLJan)WylyfnRSwTlwQfuQbMcRudiGsnf(AfGDF7ACJ3k)FhpAbCceOdTQheirBvpidbqcHfrkcKhNkYBKqiq4vgFLJap8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PK6vdXFPoTud93uhJXJulOuVAi(hODXrGo0QEqGVXCuzNtGmeajsGifbYJtf5nsiei8kJVYrGh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6us9QH4VuNwQH(BQJX4rQfuQxne)d0U4iqhAvpiW1XCYwdMYoNaziasiqePiqECQiVrcHaHxz8voc8WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4TuNsQxne)L60sn0FtDmgpsTGs9QH4FG2fxQbeqPE1q8xQtl1q)n1Xy8i1ck1RgI)bAxCPoLuF4dV6dJdFJhx9HXkMMIVpWjfVii4TuNsQn)u25eHJP9AEPwqPgdUL6usnS74UZmHv0poCmTxZl1ck1yWTuNsQfRu7qReLv8W0f)sTWL6esnGak1o0krzfpmDXVutwQti1PKAROzL1QDXsTWL6Kl1IHuJb3sDsqGo0QEqGMFk7CcKHaibWHifbYJtf5nsieOdTQhe4k6hJaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCPoLuB(PSZjc4esDkP(WhE1hgh(gpU6dJvmnfFFGtkErqWBPoLuBfnRSwTlwQfUud8LAXqQXGBeySgwb3iqbMCKHaibWhrkcKhNkYBKqiq4vgFLJaDOvIYkEy6IFPMSuNqQtj1MFySfSIMvwR2fl1ck1RgI)snjsTyLAhAvpb6EW6(zfvzCa2Vj1adPg6VPogJhPojsTyi1yWnc0Hw1dcmBfJQpFBidbqIKJifbYJtf5nsiei8kJVYrGo0krzfpmDXVutwQti1PKAZpm2cwrZkRv7ILAbL6vdXFPMePwSsTdTQNaDpyD)SIQmoa73KAGHud93uhJXJuNePwmKAm4gb6qR6bbs3dw3pROkJrgcGeatePiqECQiVrcHaHxz8voc0HwjkR4HPl(LAYsDcPoLuB(HXwWkAwzTAxSulOuVAi(l1Ki1IvQDOv9eO7bR7NvuLXby)MudmKAO)M6ymEK6Ki1IHuJb3iqhAvpiWZjS(uVDvwgziasa8qKIa5XPI8gjeceELXx5iqZpm2c76nFGSulCYsnWeb6qR6bb6pbdnvVuwEwXowKrgYqGunbIueajqKIa5XPI8gjec0Hw1dc85JGht9wnyiq4vgFLJaPWxRGOfbFVsuEA6WX0EnVuNsQPWxRGOfbFVsuEA6WX0EnVulOuJb3iqyoyKvMFyS9iasGmeacerkcKhNkYBKqiqhAvpiWSvmQGnnTpBei8kJVYrGRgI)sDAPg6VPogJhPwqPE1q8pq7Il1PKAk81km8)1GLXVCVYoNGOgmLtq4NB4FaNabcZbJSY8dJThbqcKHaa4qKIa5XPI8gjeceELXx5iWvdXFPoTud93uhJXJulOuVAi(hODXL6usTaKARGzRbtQtj1l8yuDmmVFySYkAwQfuQXGBeOdTQheyMkUx1XkQMMcziaa(isrGo0QEqGzQ4w9e1v2Ja5XPI8gjeYqaKCePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCeOdTQhe4k6t2AWuVDvwgziaaMisrGo0QEqGRONJ3QpFBiqECQiVrcHmeaapePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCeOdTQhe4MDlVcM3ZEonYqaaSrKIaDOv9GaZwXO6Z3gcKhNkYBKqidbaWcIueipovK3iHqGo0QEqGNty9PE7QSmceELXx5iqk81ka7(214gVv()oE0c4esDkPMcFTcWUVDnUXBL)VJhTWX0EnVulOuNiKCPwmKAm4gbcZbJSY8dJThbqcKHaiHWIifbYJtf5nsieOdTQheiDpyD)SIQmgbcVY4RCeif(AfGDF7ACJ3k)FhpAbCcPoLutHVwby33Ug34TY)3XJw4yAVMxQfuQtesUulgsngCJaH5Grwz(HX2JaibYqaKibIueOdTQheOROXVnFQEPGxN5rG84urEJecziasiqePiqECQiVrcHaDOv9GapNW6t92vzzei8kJVYrGu4RvWkcvVuwEw9eSFH3CywPMSudCiqyoyKvMFyS9iasGmeajaoePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCPoLulaP2ky2AWK6usTyL6fEmQogM3pmwzfnl1ck1yWTudiGsTaK6DBHmvCVQJvunnvWky2AWK6usnf(AfO7bR7Nvl8lx4yAVMxQfUuVWJr1XW8(HXkROzPgyi1jKAXqQXGBPgqaLAbi172czQ4EvhROAAQGvWS1Gj1PKAbi1u4RvGUhSUFwTWVCHJP9AEPojsnGak1wrZkRv7ILAbL6eaBPoLulaPE3witf3R6yfvttfScMTgmeOdTQheyMkUx1XkQMMcziasa8rKIa5XPI8gjec0Hw1dcmBfJkytt7ZgbcVY4RCe4QH4VuNwQH(BQJX4rQfuQxne)d0U4sDkPwas9Hp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqWBPgqaL6vdXFPoTud93uhJXJulOuVAi(hODXL6usTyLAXk1h(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVL6usTaKAZJ8yH3yoQSZjc84urEl1PKAy3XDNzcRJ5KTgmLDor4yAVMxQtj1WUJ7oZem)u25eHJP9AEPojsnGak1IvQp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccEl1PKAZJ8yH3yoQSZjc84urEl1PKAy3XDNzcRJ5KTgmLDor4yAVMxQtj1WUJ7oZem)u25eHJP9AEPoLud7oU7mt4nMJk7CIWX0EnVuNePojsnGak1RgI)sTGsTdTQNaDpyD)SIQmoa73qGWCWiRm)Wy7raKaziasKCePiqECQiVrcHaHxz8vocC1q8xQtl1q)n1Xy8i1ck1RgI)bAxCeOdTQhe4Bmhv25eidbqcGjIueipovK3iHqGo0QEqGpFe8yQ3QbdbcVY4RCeif(AfeTi47vIYtthWjK6us9XRJ)8ovKLAabuQ3TfE(i4XuVvdw441XFENkYsDkPwasnf(AfGDF7ACJ3k)FhpAbCceimhmYkZpm2EeajqgcGeapePiqhAvpiWJ)ECRgmLFxNbbYJtf5nsiKHaibWgrkcKhNkYBKqiq4vgFLJafGutHVwby33Ug34TY)3XJwaNab6qR6bbc7(214gVv()oE0qgcGealisrG84urEJecbcVY4RCeif(AfO7bR7Nvl8lxaNqQbeqPE1q8xQtl1o0QEczRyubBAAF2bO)M6ymEKAHl1RgI)bAxCPgqaLAk81ka7(214gVv()oE0c4eiqhAvpiq6EW6(zfvzmYqaiqHfrkcKhNkYBKqiqhAvpiWZjS(uVDvwgbcZbJSY8dJThbqcKHaqGjqKIa5XPI8gjeceELXx5iWDBHmvCVQJvunnv441XFENkYiqhAvpiWmvCVQJvunnfYqaiqbIifbYJtf5nsieOdTQhe4ZhbpM6TAWqGWRm(khbsHVwbrlc(ELO800bCceimhmYkZpm2EeajqgYqGehdBAk3qKIaibIueOdTQhe4Jtt3JIGneipovK3iHqgcabIifb6qR6bbs1Mf5TAf9C8otnykRfVgeipovK3iHqgcaGdrkcKhNkYBKqiq4vgFLJap8Hx9HXHVXJR(WyfttX3h4KIxee8gb6qR6bbA(PSZjqgcaGpIueOdTQhe4Bmhv25eiqECQiVrcHmKHmeOO89vpiaeOWkqHnHafOWIaZ43ud2JafZlMtmdajJaiMnzk1snP5zPUOj6ZK6vFsDYGt8wYGuFCsXRJ3s930Su74wt7gVLAyEFW4pibsywdl1ja(jtPwy0JO8z8wQblAHHu)5gZfxQftsT1sTWe3L6DjA9vpsDtWNB9j1ILKKi1InH4jjibscKyEXCIzaizeaXSjtPwQjnpl1fnrFMuV6tQtgGr2fLtgK6JtkED8wQ)MMLAh3AA34TudZ7dg)bjqcZAyPoHWMmLAHrpIYNXBPgSOfgs9NBmxCPwmj1wl1ctCxQ3LO1x9i1nbFU1NulwssIul2eINKGeiHznSuNqGjtPwy0JO8z8wQblAHHu)5gZfxQftsT1sTWe3L6DjA9vpsDtWNB9j1ILKKi1InH4jjibsywdl1jsEYuQfg9ikFgVLAWIwyi1FUXCXLAXKuBTulmXDPExIwF1Ju3e85wFsTyjjjsTytiEscsGeM1WsDcGzYuQfg9ikFgVLAWIwyi1FUXCXLAXKuBTulmXDPExIwF1Ju3e85wFsTyjjjsTytiEscsGKajMxmNygasgbqmBYuQLAsZZsDrt0Nj1R(K6Kb4(tgK6JtkED8wQ)MMLAh3AA34TudZ7dg)bjqcZAyPobWpzk1cJEeLpJ3snyrlmK6p3yU4sTysQTwQfM4UuVlrRV6rQBc(CRpPwSKKePwSjepjbjqcZAyPorYtMsTWOhr5Z4Tudw0cdP(ZnMlUulMKARLAHjUl17s06REK6MGp36tQfljjrQfBcXtsqcKWSgwQtamtMsTWOhr5Z4Tudw0cdP(ZnMlUulMKARLAHjUl17s06REK6MGp36tQfljjrQfBcXtsqcKeiX8I5eZaqYiaIztMsTutAEwQlAI(mPE1NuNm4eunrYGuFCsXRJ3s930Su74wt7gVLAyEFW4pibsywdl1jsKmLAHrpIYNXBPgSOfgs9NBmxCPwmj1wl1ctCxQ3LO1x9i1nbFU1NulwssIul2eINKGeijqjJ0e9z8wQb2sTdTQhPowV9bjqiqIRxvKrGaRKAq8t0supk1aRJpgFsGawj1a5dUF5K6eaprKAbkScmHeijqo0QE(aXXWMMYT0Kj5XPP7rrWMeihAvpFG4yytt5wAYKq1Mf5TAf9C8otnykRfVgjqo0QE(aXXWMMYT0KjX8tzNtisTiF4dV6dJdFJhx9HXkMMIVpWjfVii4TeihAvpFG4yytt5wAYK8gZrLDoHeijqo0QE(0KjHgpzt2ilbYHw1ZNMmj25tsXRyLS1GP(8TjbYHw1ZNMmj4pRkJPFjqo0QE(0Kjb6XOYHw1JkwVjY40mz4(La5qR65ttMeOhJkhAvpQy9MiJtZKPAcrQfzhALOSIhMU4xqGlLampYJf8irExrC82T(c84urENsaMh5XczQ4EvhRQzH)vpbECQiVLa5qR65ttMeOhJkhAvpQy9MiJtZKDcQMqKAr2HwjkR4HPl(fe4szEKhl4rI8UI44TB9f4XPI8oLampYJfYuX9QowvZc)REc84urElbYHw1ZNMmjqpgvo0QEuX6nrgNMj7eVjsTi7qReLv8W0f)ccCPmpYJf8irExrC82T(c84urENY8ipwitf3R6yvnl8V6jWJtf5TeihAvpFAYKa9yu5qR6rfR3ezCAM8BIulYo0krzfpmDXVGaxkbyEKhl4rI8UI44TB9f4XPI8oL5rESqMkUx1XQAw4F1tGhNkYBjqo0QE(0Kjb6XOYHw1JkwVjY40mzyKDrzrQfzhALOSIhMU4x4cucKdTQNpnzs8d6dRS(oEmjqsGCOv98bNGQjiNPIB1tuxzVeihAvpFWjOAI0Kjzf9jBnyQ3UkllsTiVAi(Ng6VPogJhbxne)d0U4sGCOv98bNGQjstMKv0ZXB1NVnjqo0QE(Gtq1ePjtYMDlVcM3ZEoTi1I8QH4FAO)M6ymEeC1q8pq7IlbYHw1ZhCcQMinzsYwXO6Z3MeihAvpFWjOAI0KjHUhSUFwrvglcmhmYkZpm2EYjePwKPWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWX0EnVGjcjxmWGBjqo0QE(Gtq1ePjtY5ewFQ3UkllcmhmYkZpm2EYjePwKPWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWX0EnVGjcjxmWGBjqo0QE(Gtq1ePjtYk6t2AWuVDvwwKArE1q8pn0FtDmgpcUAi(hODXLa5qR65dobvtKMmjzQ4EvhROAAkrQf5vdX)0q)n1Xy8i4QH4FG2fpLaScMTgSuIDHhJQJH59dJvwrZcIb3acOa2TfYuX9Qowr10ubRGzRblff(AfO7bR7Nvl8lx4yAVMx4l8yuDmmVFySYkAgyKqmWGBabua72czQ4EvhROAAQGvWS1GLsau4RvGUhSUFwTWVCHJP9A(KaiGwrZkRv7IfmbWoLa2TfYuX9Qowr10ubRGzRbtcKdTQNp4eunrAYK8gZrLDoHi1I8QH4FAO)M6ymEeC1q8pq7IlbYHw1ZhCcQMinzsO7bR7NvuLXIaZbJSY8dJTNCcrQfzk81kq3dw3pRw4xUaorkk81kq3dw3pRw4xUWX0EnVGRgI)IjX6qR6jq3dw3pROkJdW(nGb0FtDmgpjrmWGBjqo0QE(Gtq1ePjts2kgvWMM2NTiWCWiRm)Wy7jNqKArEHhJQJH59dJvwrZcIb3Pwne)td93uhJXJGRgI)bAx8uI9WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4Dky3XDNzcRJ5KTgmLDor4yAVMpfS74UZmbZpLDor4yAVMhqafWHp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqW7KibYHw1ZhCcQMinzsE(i4XuVvdMiWCWiRm)Wy7jNqKArE3w45JGht9wnyHJxh)5DQiNsau4RvGUhSUFwTWVCHJP9AEjqo0QE(Gtq1ePjts2kgvWMM2NTiWCWiRm)Wy7jNqKArE1q8pn0FtDmgpcUAi(hODXtjwk81kq3dw3pRw4xUWBomRGjhqaxne)f0Hw1tGUhSUFwrvghG9BjjLyp8Hx9HXHH)VgSm(L7v25ee1GPCcc)Cd)dCsXlccENc2DC3zMW6yozRbtzNteoM2R5tb7oU7mtW8tzNteoM2R5beqbC4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8ojsGCOv98bNGQjstMexrJFB(u9sbVoZlbYHw1ZhCcQMinzso(7XTAWu(DDgjqo0QE(Gtq1ePjtcS7BxJB8w5)74rtcKdTQNp4eunrAYKq3dw3pROkJfbMdgzL5hgBp5eIulYu4RvGUhSUFwTWVCbCcabC1q8pTdTQNq2kgvWMM2NDa6VPogJhHVAi(hODXbeqk81ka7(214gVv()oE0c4esGCOv98bNGQjstMKZjS(uVDvwweyoyKvMFyS9KtibYHw1ZhCcQMinzsYuX9Qowr10uIulYcWky2AWKajbYHw1ZhCI3iVz3YRG59SNtlsTiVAi(Ng6VPogJhbxne)d0U4sGCOv98bN4T0Kj55JGht9wnyIaZbJSY8dJTNCcrQfzbSBl88rWJPERgSGvWS1GLY8dJTGv0SYA1UyHd8Ka5qR65doXBPjtYk654T6Z3MeihAvpFWjElnzso(7XTAWu(DDgjqo0QE(Gt8wAYKKPIB1tuxzVeihAvpFWjElnzsGDF7ACJ3k)FhpAsGCOv98bN4T0KjjBfJQpFBsGCOv98bN4T0Kjzf9jBnyQ3UkllsTiVAi(Ng6VPogJhbxne)d0U4sGCOv98bN4T0KjXv043MpvVuWRZ8sGCOv98bN4T0Kjjtf3R6yfvttjsTiVWJr1XW8(HXkROzbXGBabC1q8pn0FtDmgpcUAi(hODXtj2Hf3uzkfvttfeTJUvro1UTWZhbpM6TAWcwbZwdwQDBHNpcEm1B1GfoED8N3PImGaoS4MktPOAAQarE(A6E4ucGcFTc09G19ZQf(LlGtKA1q8pn0FtDmgpcUAi(hODXbgo0QEczRyubBAAF2bO)M6ymEedGljacOv0SYA1UybtiSsGCOv98bN4T0Kjb6NOSi1ISdTsuwXdtx8l8ePeWHp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCsXlccElbYHw1ZhCI3stMekCdMNVCIulYo0krzfpmDXVWtKsah(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjfVii4Dky3XDNzczQ4EvhROAAQWcpgvhdZ7hgRSIMf(tWXOY8dJTpLyH59dJF16COv94rHlWqYbeWDBHp)5edhvunnvWky2AWsIeihAvpFWjElnzsEJ5OYoNqKArE1q8pn0FtDmgpcUAi(hODXLa5qR65doXBPjtcDpyD)SIQmweyoyKvMFyS9KtisTitHVwb6EW6(z1c)YfWjsrHVwb6EW6(z1c)YfoM2R5fC1q8xmjwhAvpb6EW6(zfvzCa2VbmG(BQJX4jjIbgCNsau4Rvitf3QNOUY(WX0EnpGasHVwb6EW6(z1c)YfoM2R5tnS4MktPOAAQarE(A6Eyjqo0QE(Gt8wAYKKTIrfSPP9zlcmhmYkZpm2EYjePwKx4XO6yyE)WyLv0SGyWDQvdX)0q)n1Xy8i4QH4FG2fxcKdTQNp4eVLMmjNty9PE7QSSiWCWiRm)Wy7jNqKArMcFTcwrO6LYYZQNG9l8MdZsg4aeWDBHp)5edhvunnvWky2AWKa5qR65doXBPjtcDpyD)SIQmwKArE3w4ZFoXWrfvttfScMTgmjqo0QE(Gt8wAYK88rWJPERgmrG5Grwz(HX2toHi1I8XRJ)8ovKtz(HXwWkAwzTAxSWbEsGCOv98bN4T0Kjjtf3R6yfvttjsTipS4MktPOAAQWN)CIHJPwne)fUdTQNaDpyD)SIQmoa73edbMA3w45JGht9wnyHJP9AEHNCXadULa5qR65doXBPjtcmVN9C6xcKdTQNp4eVLMmjzRyubBAAF2IaZbJSY8dJTNCcrQf5vdX)0q)n1Xy8i4QH4FG2fxcKdTQNp4eVLMmjzQ4EvhROAAkrQf5dF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4KIxee8wcKdTQNp4eVLMmj09G19ZkQYyrG5Grwz(HX2toHi1Imf(AfO7bR7Nvl8lxaNaqaxne)t7qR6jKTIrfSPP9zhG(BQJX4r4RgI)bAxCGrIKdiG72cF(ZjgoQOAAQGvWS1GbiGu4Rvitf3QNOUY(WX0EnVeihAvpFWjElnzsoNW6t92vzzrG5Grwz(HX2toHeihAvpFWjElnzsYuX9Qowr10uIulYdlUPYukQMMkiAhDRICQDBHNpcEm1B1GfScMTgmabCyXnvMsr10ubI88109Wac4WIBQmLIQPPcF(ZjgoMA1q8x4jxyLajbYHw1ZhOAcYpFe8yQ3QbteyoyKvMFyS9KtisTitHVwbrlc(ELO800HJP9A(uu4Rvq0IGVxjkpnD4yAVMxqm4wcKdTQNpq1ePjts2kgvWMM2NTiWCWiRm)Wy7jNqKArE1q8pn0FtDmgpcUAi(hODXtrHVwHH)VgSm(L7v25ee1GPCcc)Cd)d4esGCOv98bQMinzsYuX9Qowr10uIulYRgI)PH(BQJX4rWvdX)aTlEkbyfmBnyPw4XO6yyE)WyLv0SGyWTeihAvpFGQjstMKmvCREI6k7La5qR65dunrAYKSI(KTgm1BxLLfPwKxne)td93uhJXJGRgI)bAxCjqo0QE(avtKMmjRONJ3QpFBsGCOv98bQMinzs2SB5vW8E2ZPfPwKxne)td93uhJXJGRgI)bAxCjqo0QE(avtKMmjzRyu95BtcKdTQNpq1ePjtY5ewFQ3UkllcmhmYkZpm2EYjePwKPWxRaS7BxJB8w5)74rlGtKIcFTcWUVDnUXBL)VJhTWX0EnVGjcjxmWGBjqo0QE(avtKMmj09G19ZkQYyrG5Grwz(HX2toHi1Imf(AfGDF7ACJ3k)FhpAbCIuu4Rva29TRXnER8)D8OfoM2R5fmri5IbgClbYHw1ZhOAI0KjXv043MpvVuWRZ8sGCOv98bQMinzsoNW6t92vzzrG5Grwz(HX2toHi1Imf(AfSIq1lLLNvpb7x4nhMLmWjbYHw1ZhOAI0Kjjtf3R6yfvttjsTiVAi(Ng6VPogJhbxne)d0U4PeGvWS1GLsSl8yuDmmVFySYkAwqm4gqafWUTqMkUx1XkQMMkyfmBnyPOWxRaDpyD)SAHF5cht718cFHhJQJH59dJvwrZaJeIbgCdiGcy3witf3R6yfvttfScMTgSucGcFTc09G19ZQf(LlCmTxZNeab0kAwzTAxSGja2PeWUTqMkUx1XkQMMkyfmBnysGCOv98bQMinzsYwXOc200(SfbMdgzL5hgBp5eIulYRgI)PH(BQJX4rWvdX)aTlEkbC4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8gqaxne)td93uhJXJGRgI)bAx8uIvSh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtjaZJ8yH3yoQSZjc84urENc2DC3zMW6yozRbtzNteoM2R5tb7oU7mtW8tzNteoM2R5tcGak2dF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3PmpYJfEJ5OYoNiWJtf5Dky3XDNzcRJ5KTgmLDor4yAVMpfS74UZmbZpLDor4yAVMpfS74UZmH3yoQSZjcht718jjjac4QH4VGo0QEc09G19ZkQY4aSFtcKdTQNpq1ePjtYBmhv25eIulYRgI)PH(BQJX4rWvdX)aTlUeihAvpFGQjstMKNpcEm1B1GjcmhmYkZpm2EYjePwKPWxRGOfbFVsuEA6aorQJxh)5DQidiG72cpFe8yQ3QblC864pVtf5ucGcFTcWUVDnUXBL)VJhTaoHeihAvpFGQjstMKJ)ECRgmLFxNrcKdTQNpq1ePjtcS7BxJB8w5)74rtKArwau4Rva29TRXnER8)D8OfWjKa5qR65dunrAYKq3dw3pROkJfPwKPWxRaDpyD)SAHF5c4eac4QH4FAhAvpHSvmQGnnTp7a0FtDmgpcF1q8pq7IdiGu4Rva29TRXnER8)D8OfWjKa5qR65dunrAYKCoH1N6TRYYIaZbJSY8dJTNCcjqo0QE(avtKMmjzQ4EvhROAAkrQf5DBHmvCVQJvunnv441XFENkYsGCOv98bQMinzsE(i4XuVvdMiWCWiRm)Wy7jNqKArMcFTcIwe89kr5PPd4esGKa5qR65dW9toVFeDpIulYMh5XcgF0VQxkEWCmMMhlWJtf5DQvdXFbxne)d0U4sGCOv98b4(ttMeQy3B1c)YjsTid7oU7mta29TRXnER8)D8OfoM2R5foWjSsGCOv98b4(ttMeFG8BNhvqpgfPwKHDh3DMja7(214gVv()oE0cht718ch4ewjqo0QE(aC)PjtYQoMk29wKArg2DC3zMaS7BxJB8w5)74rlCmTxZlCGtyLa5qR65dW9NMmjXclV9kG1W3y08ysGCOv98b4(ttMekht1lLDfm7lsTid7oU7mtiBfJkytt7ZoSWJr1XW8(HXkROzHJb3sGCOv98b4(ttMek(E(YwdMi1ImS74UZmby33Ug34TY)3XJw4yAVMx4atHfqaTIMvwR2flycGtcKdTQNpa3FAYKqJNSjBKLa5qR65dW9NMmjeTv9isTiB(HXwWkAwzTAxSGatHfqaPWxRaS7BxJB8w5)74rlGtibYHw1ZhG7pnzsEJ5OYoNqKAr(WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4DQvdX)0q)n1Xy8i4QH4FG2fxcKdTQNpa3FAYKSoMt2AWu25eIulYh(WR(W4WW)xdwg)Y9k7CcIAWuobHFUH)boP4fbbVtTAi(Ng6VPogJhbxne)d0U4sGCOv98b4(ttMeZpLDoHi1I8Hp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqW7uRgI)PH(BQJX4rWvdX)aTloGaUAi(Ng6VPogJhbxne)d0U4Po8Hx9HXHVXJR(WyfttX3h4KIxee8oL5NYoNiCmTxZligCNc2DC3zMWk6hhoM2R5fedUtjwhALOSIhMU4x4jaeqhALOSIhMU4NCIuwrZkRv7IfEYfdm4ojsGCOv98b4(ttMKv0pwKynScUjlWKlsTiVAi(Ng6VPogJhbxne)d0U4Pm)u25ebCIuh(WR(W4W34XvFySIPP47dCsXlccENYkAwzTAxSWb(IbgClbYHw1ZhG7pnzsYwXO6Z3Mi1ISdTsuwXdtx8torkZpm2cwrZkRv7IfC1q8xmjwhAvpb6EW6(zfvzCa2VbmG(BQJX4jjIbgClbYHw1ZhG7pnzsO7bR7NvuLXIulYo0krzfpmDXp5ePm)WylyfnRSwTlwWvdXFXKyDOv9eO7bR7NvuLXby)gWa6VPogJNKigyWTeihAvpFaU)0Kj5CcRp1BxLLfPwKDOvIYkEy6IFYjsz(HXwWkAwzTAxSGRgI)IjX6qR6jq3dw3pROkJdW(nGb0FtDmgpjrmWGBjqo0QE(aC)PjtI)em0u9sz5zf7yrwKAr28dJTWUEZhilCYatjqsGCOv98byKDrzYpFe8yQ3QbteyoyKvMFyS9KtisTiBEKhlKp3(8xrvgh4XPI8off(AfeTi47vIYtthoM2R5trHVwbrlc(ELO800HJP9AEbXGBjqo0QE(amYUOCAYKKPIB1tuxzVeihAvpFagzxuonzso(7XTAWu(DDgjqo0QE(amYUOCAYKKPI7vDSIQPPePwKx4XO6yyE)WyLv0SGyWTeihAvpFagzxuonzsG59SNt)sGCOv98byKDr50KjHc3G55lNi1I8UTWN)CIHJkQMMkyfmBnyPe7UTqngFJhvurM31GfEZHzfuGac4UTWN)CIHJkQMMkCmTxZligCNejqo0QE(amYUOCAYKa9tuwKArE3w4ZFoXWrfvttfScMTgmjqo0QE(amYUOCAYKSz3YRG59SNtlsTiVAi(Ng6VPogJhbxne)d0U4sGCOv98byKDr50Kjb29TRXnER8)D8OjbYHw1ZhGr2fLttMekCdMNVCIulYW8(HXVADo0QE8OWfyi5PGDh3DMjKPI7vDSIQPPcl8yuDmmVFySYkAw4pbhJkZpm2EXKaLa5qR65dWi7IYPjtYk6t2AWuVDvwwKArE1q8pn0FtDmgpcUAi(hODXLa5qR65dWi7IYPjtc0przrQfzy3XDNzczQ4EvhROAAQWcpgvhdZ7hgRSIMf(tWXOY8dJTxmjWuMh5XcEKiVRioE7wFbECQiVLa5qR65dWi7IYPjts2kgvWMM2NTiWCWiRm)Wy7jNqKArE1q8pn0FtDmgpcUAi(hODXtTWJr1XW8(HXkROzbXG7uI9WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4Dky3XDNzcRJ5KTgmLDor4yAVMpfS74UZmbZpLDor4yAVMhqafWHp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqW7KibYHw1ZhGr2fLttMKmvCVQJvunnLi1ISa2TfYuX9Qowr10ubRGzRbtcKdTQNpaJSlkNMmju4gmpF5ePwKfRagwCtLPuunnv4ZFoXWrabuaMh5XczQ4EvhRQzH)vpbECQiVtsky3XDNzczQ4EvhROAAQWcpgvhdZ7hgRSIMf(tWXOY8dJTxmjqjqo0QE(amYUOCAYKa9tuwKArg2DC3zMqMkUx1XkQMMkSWJr1XW8(HXkROzH)eCmQm)Wy7ftcucKdTQNpaJSlkNMmjzRyu95BtcKdTQNpaJSlkNMmjRONJ3QpFBsGCOv98byKDr50KjXv043MpvVuWRZ8sGCOv98byKDr50Kj5nMJk7Ccjqo0QE(amYUOCAYK88rWJPERgmrG5Grwz(HX2toHi1I8XRJ)8ovKtzEKhlKp3(8xrvgh4XPI8oL5hgBbROzL1QDXchylbYHw1ZhGr2fLttMeOFIYsGCOv98byKDr50KjjBfJkytt7ZweyoyKvMFyS9KtisTiVAi(Ng6VPogJhbxne)d0U4Pe7Hp8Qpmom8)1GLXVCVYoNGOgmLtq4NB4FGtkErqW7uWUJ7oZewhZjBnyk7CIWX0EnFky3XDNzcMFk7CIWX0EnpGakGdF4vFyCy4)RblJF5ELDobrnykNGWp3W)aNu8IGG3jrcKdTQNpaJSlkNMmjpFe8yQ3QbteyoyKvMFyS9KtisTiF864pVtfzjqo0QE(amYUOCAYKq3dw3pROkJfbMdgzL5hgBp5esGCOv98byKDr50Kj5CcRp1BxLLfbMdgzL5hgBp5esGKa5qR65dVrEf9C8w95BtcKdTQNp8wAYKKPIB1tuxzVeihAvpF4T0Kj54Vh3Qbt531zKa5qR65dVLMmjpFe8yQ3QbteyoyKvMFyS9KtisTitHVwbrlc(ELO800bCIuu4Rvq0IGVxjkpnD4yAVMxqm4gqafGvWS1GjbYHw1ZhElnzs2SB5vW8E2ZPfPwKxne)td93uhJXJGRgI)bAxCjqo0QE(WBPjtY5ewFQ3UkllcmhmYkZpm2EYjePwKPWxRGveQEPS8S6jy)cV5WSKbojqo0QE(WBPjtcS7BxJB8w5)74rtcKdTQNp8wAYKKTIr1NVnjqo0QE(WBPjtsMkUx1XkQMMsKArEHhJQJH59dJvwrZcIb3Pwne)td93uhJXJGRgI)bAxCabuSdlUPYukQMMkiAhDRICQDBHNpcEm1B1GfScMTgSu72cpFe8yQ3QblC864pVtfzabCyXnvMsr10ubI88109WPwne)td93uhJXJGRgI)bAxCGHdTQNq2kgvWMM2NDa6VPogJhXa4sjak81kq3dw3pRw4xUWX0EnFsKa5qR65dVLMmjVXCuzNtisTiVAi(Ng6VPogJhbxne)d0U4sGCOv98H3stMKv0NS1GPE7QSSi1I8QH4FAO)M6ymEeC1q8pq7IlbYHw1ZhElnzsYwXOc200(SfbMdgzL5hgBp5eIulYRgI)PH(BQJX4rWvdX)aTlEkXE4dV6dJdd)Fnyz8l3RSZjiQbt5ee(5g(h4KIxee8ofS74UZmH1XCYwdMYoNiCmTxZNc2DC3zMG5NYoNiCmTxZdiGc4WhE1hghg()AWY4xUxzNtqudMYji8Zn8pWjfVii4DsKa5qR65dVLMmjq)eLfPwKDOvIYkEy6IFHNiLao8Hx9HXHlx0Z(MhZY3RG9SA8zxdM6TRYYFGtkErqWBjqo0QE(WBPjtcfUbZZxorQfzhALOSIhMU4x4jsjGdF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4KIxee8ofS74UZmHmvCVQJvunnvyHhJQJH59dJvwrZc)j4yuz(HX2NsSW8(HXVADo0QE8OWfyi5ac4UTWN)CIHJkQMMkyfmBnyjrcKdTQNp8wAYK4kA8BZNQxk41zEjqo0QE(WBPjtcDpyD)SIQmweyoyKvMFyS9KtisTiVBl85pNy4OIQPPcwbZwdgGasHVwb6EW6(z1c)YfEZHzjNCjqo0QE(WBPjtYZhbpM6TAWebMdgzL5hgBp5eIulYhVo(Z7urgqaPWxRGOfbFVsuEA6aoHeihAvpF4T0Kjjtf3R6yfvttjsTipS4MktPOAAQWN)CIHJP2TfE(i4XuVvdw4yAVMx4jxmWGBab8WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boP4fbbVLa5qR65dVLMmjW8E2ZPFjqo0QE(WBPjtcDpyD)SIQmweyoyKvMFyS9KtisTitHVwb6EW6(z1c)YfWjaeWvdX)0o0QEczRyubBAAF2bO)M6ymEe(QH4FG2fhyKi5ac4UTWN)CIHJkQMMkyfmBnysGCOv98H3stMKZjS(uVDvwweyoyKvMFyS9KtibYHw1ZhElnzsYuX9Qowr10uIulYdlUPYukQMMkiAhDRICQDBHNpcEm1B1GfScMTgmabCyXnvMsr10ubI88109Wac4WIBQmLIQPPcF(ZjgoIaFcgIaqGjp5idzie]] )
end