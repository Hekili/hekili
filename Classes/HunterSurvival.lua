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

        if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
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

            toggle = "interrupts",
            
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
            --[[ texture = function ()
                local a = current_wildfire_bomb and current_wildfire_bomb or "wildfire_bomb"
                if a == "wildfire_bomb" or not action[ a ] then return 2065634 end                
                return action[ a ].texture
            end, ]]

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


    spec:RegisterPack( "Survival", 20210502, [[dKeS9bqieLEKieQlrKO2Ki1Naeyuev6uIaRIiPELOywePUfGK2LGFHinmIeoMiAzikEgGOPbivxteQTbi03issJJirohGewNie9oabrZdr19iI9ruXbfHGwirXdbKYhbeuJeqIYjbKiReqntIK4Macs7eadfqqyPIqipfOPIi(QieyVq(ljdMuhMQfJKhdAYk1LrTzL8zOmArvNwYQbKO61IsZwOBJu7wXVLA4iCCrqlxLNRQPt56q12jk9DrY4jQ68IkRxesZhG2pHrjrKGa3UXiaiJuqMKsrILcYesMyGeisgGebA5iyeiHdZ6ymcCCAgbcIFYwY6reiHNl2(grcc8B8dYiWeXcDEZi(ejPKIvwECQaSPj9lA8OBvpWZxgPFrdjfbsHxrdO0GOqGB3yeaKrkitsPiXsbzcjtmqceLIKiqh3Y3hceSObAiW81EZdIcbU5hIabXpzlz9Oqdug(y8jagiupNqtgPfAYifKjjcmwV9isqGoXBisqaKerccKhNkYBKmiq4vgFLJaxne)f6mcn0FtDmgpcn5c9QH4FG2Lhb6qR6bbUz3YRG59SNtJmeaKbrccKhNkYBKmiqhAvpiWNpcEm1B1GHaHxz8vocKSc9UTWZhbpM6TAWcwbZwdMqNwOn)WylyfnRSwTlwOLJqlvrGWCWiRm)Wy7raKeziaasejiqhAvpiWv0ZXB1NVneipovK3izqgcaGoIeeOdTQhe4XFpUvdMYVRtHa5XPI8gjdYqaKyejiqhAvpiWuvCREI6k7rG84urEJKbziaaIisqGo0QEqGWUVDnUXBL)VJhneipovK3izqgcaPkIeeOdTQhey2kgvF(2qG84urEJKbziaKsisqG84urEJKbbcVY4RCe4QH4VqNrOH(BQJX4rOjxOxne)d0U8iqhAvpiWv0NS1GPE7QSmYqaauGibb6qR6bb6kA8BZNQxk41PEeipovK3izqgcGKsbIeeipovK3izqGWRm(khbUWJr1XW8(HXkROzHMCHgdUfAabuOxne)f6mcn0FtDmgpcn5c9QH4FG2LxOtl0YvOhwEtLQuunnvq2o6wfzHoTqVBl88rWJPERgSGvWS1Gj0Pf6DBHNpcEm1B1GfoED8N3PISqdiGc9WYBQuLIQPPce55RP7Hf60cnzfAk81kq3dw3pRw4xUaoHqNwOxne)f6mcn0FtDmgpcn5c9QH4FG2LxObQcTdTQNq2kgvWMM2NDa6VPogJhHwQfAGuOtGqdiGcTv0SYA1UyHMCHoPuGaDOv9GatvX9Qowr10uidbqYKisqG84urEJKbbcVY4RCeOdTswwXdtx8l0YrOtk0PfAYk0h(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjeVii4nc0Hw1dce6NSmYqaKKmisqG84urEJKbbcVY4RCeOdTswwXdtx8l0YrOtk0PfAYk0h(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjeVii4TqNwOHDh3DQjKQI7vDSIQPPcl8yuDmmVFySYkAwOLJq)eCmQm)Wy7f60cTCfAyE)W4xTohAvpEuOLJqtMqIfAabuO3Tf(8NtmCur10ubRGzRbtOtac0Hw1dcKc3G55lhYqaKeirKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGVXCuzNtGmeajb6isqG84urEJKbb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YfWje60cnf(AfO7bR7Nvl8lx4yAVMxOjxOxne)fAsfA5k0o0QEc09G19ZkQY4aSFtObQcn0FtDmgpcDceAPwOXGBHoTqtwHMcFTcPQ4w9e1v2hoM2R5fAabuOPWxRaDpyD)SAHF5cht718cDAHEy5nvQsr10ubI88109WiqyoyKvMFyS9iasImeajtmIeeipovK3izqGo0QEqGzRyubBAAF2iq4vgFLJax4XO6yyE)WyLv0SqtUqJb3cDAHE1q8xOZi0q)n1Xy8i0Kl0RgI)bAxEeimhmYkZpm2EeajrgcGKarejiqECQiVrYGaDOv9GapNW6t92vzzei8kJVYrGu4RvWkcvVuwEw9eSFH3CywHwIqdKcnGak072cF(ZjgoQOAAQGvWS1GHaH5Grwz(HX2JaijYqaKuQIibbYJtf5nsgei8kJVYrG72cF(ZjgoQOAAQGvWS1GHaDOv9GaP7bR7NvuLXidbqsPeIeeipovK3izqGo0QEqGpFe8yQ3QbdbcVY4RCe4XRJ)8ovKf60cT5hgBbROzL1QDXcTCeAPkceMdgzL5hgBpcGKidbqsGcejiqECQiVrYGaHxz8vocCy5nvQsr10uHp)5edhf60c9QH4VqlhH2Hw1tGUhSUFwrvghG9BcTul0KrOtl072cpFe8yQ3QblCmTxZl0YrOtSql1cngCJaDOv9GatvX9Qowr10uidbazKcejiqhAvpiqyEp750pcKhNkYBKmidbazsIibbYJtf5nsgeOdTQhey2kgvWMM2NnceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGWCWiRm)Wy7raKeziaidzqKGa5XPI8gjdceELXx5iWdF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4eIxee8gb6qR6bbMQI7vDSIQPPqgcaYaKisqG84urEJKbb6qR6bbs3dw3pROkJrGWRm(khbsHVwb6EW6(z1c)YfWjeAabuOxne)f6mcTdTQNq2kgvWMM2NDa6VPogJhHwoc9QH4FG2LxObQcDYel0acOqVBl85pNy4OIQPPcwbZwdMqdiGcnf(AfsvXT6jQRSpCmTxZJaH5Grwz(HX2JaijYqaqgGoIeeipovK3izqGo0QEqGNty9PE7QSmceMdgzL5hgBpcGKidbazsmIeeipovK3izqGWRm(khboS8MkvPOAAQGSD0TkYcDAHE3w45JGht9wnybRGzRbtObeqHEy5nvQsr10ubI88109WcnGak0dlVPsvkQMMk85pNy4OqNwOxne)fA5i0jwkqGo0QEqGPQ4EvhROAAkKHmeiXXWMMYnejiasIibbYJtf5nsge4MF4vew1dceiupNqtgPfAYifKjjc0Hw1dc8XPP7rrWgYqaqgejiqhAvpiqQ2SiVvRONJ3PQbtzT81Ga5XPI8gjdYqaaKisqG84urEJKbbcVY4RCe4Hp8Qpmo8nEC1hgRyAk((aNq8IGG3iqhAvpiqZpLDobYqaa0rKGaDOv9GaFJ5OYoNabYJtf5nsgKHme4MxoE0qKGaijIeeOdTQheinEIMOrgbYJtf5nsgKHaGmisqG84urEJKbb6qR6bbANpjeVIvIwdM6Z3gcCZp8kcR6bbceUfApp7BH2NTqtY5tcXRyLOSqdaqiaAcnpmDXV0cDkwO39aeyc9UfAlF9c9QpHMi6547fAkg64pl0LbeSfAkwOTUf6NWPPZj0(Sf6uSqd9biWe6J9DfZj0KC(KqH(jyyTkOqtHVwFabcVY4RCeizfAZpm2c1RiIEo(qgcaGercc0Hw1dce)zvzm9Ja5XPI8gjdYqaa0rKGa5XPI8gjdc0Hw1dce6XOYHw1JkwVHaJ1BQXPzeiC)idbqIrKGa5XPI8gjdceELXx5iqhALSSIhMU4xOjxObsHoTqtwH28ipwWJe5DfXXB36lWJtf5TqNwOjRqBEKhlKQI7vDSQMf(x9e4XPI8gb6qR6bbc9yu5qR6rfR3qGX6n140mcKQjqgcaGiIeeipovK3izqGWRm(khb6qRKLv8W0f)cn5cnqk0PfAZJ8ybpsK3vehVDRVapovK3cDAHMScT5rESqQkUx1XQAw4F1tGhNkYBeOdTQhei0JrLdTQhvSEdbgR3uJtZiqNGQjqgcaPkIeeipovK3izqGWRm(khb6qRKLv8W0f)cn5cnqk0PfAZJ8ybpsK3vehVDRVapovK3cDAH28ipwivf3R6yvnl8V6jWJtf5nc0Hw1dce6XOYHw1JkwVHaJ1BQXPzeOt8gYqaiLqKGa5XPI8gjdceELXx5iqhALSSIhMU4xOjxObsHoTqtwH28ipwWJe5DfXXB36lWJtf5TqNwOnpYJfsvX9QowvZc)REc84urEJaDOv9GaHEmQCOv9OI1BiWy9MACAgb(gYqaauGibbYJtf5nsgei8kJVYrGo0kzzfpmDXVqlhHMmiqhAvpiqOhJkhAvpQy9gcmwVPgNMrGWi7YYidbqsParcc0Hw1dc0pOpSY674XqG84urEJKbzidbcJSllJibbqsejiqECQiVrYGaDOv9GaF(i4XuVvdgceELXx5iqZJ8yH852N)kQY4apovK3cDAHMcFTcYwe89kz5PPdht718cDAHMcFTcYwe89kz5PPdht718cn5cngCJaH5Grwz(HX2JaijYqaqgejiqhAvpiWuvCREI6k7rG84urEJKbziaasejiqhAvpiWJ)ECRgmLFxNcbYJtf5nsgKHaaOJibbYJtf5nsgei8kJVYrGl8yuDmmVFySYkAwOjxOXGBeOdTQheyQkUx1XkQMMcziasmIeeOdTQheimVN9C6hbYJtf5nsgKHaaiIibbYJtf5nsgei8kJVYrG72cF(ZjgoQOAAQGvWS1Gj0PfA5k072c1y8nEurfzExdw4nhMvOjxOjJqdiGc9UTWN)CIHJkQMMkCmTxZl0Kl0yWTqNaeOdTQheifUbZZxoKHaqQIibbYJtf5nsgei8kJVYrG72cF(ZjgoQOAAQGvWS1GHaDOv9GaH(jlJmeasjejiqECQiVrYGaHxz8vocC1q8xOZi0q)n1Xy8i0Kl0RgI)bAxEeOdTQhe4MDlVcM3ZEonYqaauGibb6qR6bbc7(214gVv()oE0qG84urEJKbziaskfisqG84urEJKbbcVY4RCeimVFy8RwNdTQhpk0YrOjtiXcDAHg2DC3PMqQkUx1XkQMMkSWJr1XW8(HXkROzHwoc9tWXOY8dJTxOjvOjdc0Hw1dcKc3G55lhYqaKmjIeeipovK3izqGWRm(khbUAi(l0zeAO)M6ymEeAYf6vdX)aTlpc0Hw1dcCf9jBnyQ3UklJmeajjdIeeipovK3izqGWRm(khbc7oU7utivf3R6yfvttfw4XO6yyE)WyLv0SqlhH(j4yuz(HX2l0Kk0KrOtl0Mh5XcEKiVRioE7wFbECQiVrGo0QEqGq)KLrgcGKajIeeipovK3izqGo0QEqGzRyubBAAF2iq4vgFLJaxne)f6mcn0FtDmgpcn5c9QH4FG2LxOtl0l8yuDmmVFySYkAwOjxOXGBHoTqlxH(WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNwOHDh3DQjSoMt0AWu25eHJP9AEHoTqd7oU7utW8tzNteoM2R5fAabuOjRqF4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8wOtaceMdgzL5hgBpcGKidbqsGoIeeipovK3izqGWRm(khbswHE3wivf3R6yfvttfScMTgmeOdTQheyQkUx1XkQMMcziasMyejiqECQiVrYGaHxz8vocuUcnzf6HL3uPkfvttf(8NtmCuObeqHMScT5rESqQkUx1XQAw4F1tGhNkYBHobcDAHg2DC3PMqQkUx1XkQMMkSWJr1XW8(HXkROzHwoc9tWXOY8dJTxOjvOjdc0Hw1dcKc3G55lhYqaKeiIibbYJtf5nsgei8kJVYrGWUJ7o1esvX9Qowr10uHfEmQogM3pmwzfnl0YrOFcogvMFyS9cnPcnzqGo0QEqGq)KLrgcGKsvejiqhAvpiWSvmQ(8THa5XPI8gjdYqaKukHibb6qR6bbUIEoER(8THa5XPI8gjdYqaKeOarcc0Hw1dc0v043MpvVuWRt9iqECQiVrYGmeaKrkqKGaDOv9GaFJ5OYoNabYJtf5nsgKHaGmjrKGa5XPI8gjdc0Hw1dc85JGht9wnyiq4vgFLJapED8N3PISqNwOnpYJfYNBF(ROkJd84urEl0PfAZpm2cwrZkRv7IfA5i0sjeimhmYkZpm2EeajrgcaYqgejiqhAvpiqOFYYiqECQiVrYGmeaKbirKGa5XPI8gjdc0Hw1dcmBfJkytt7ZgbcVY4RCe4QH4VqNrOH(BQJX4rOjxOxne)d0U8cDAHwUc9Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqWBHoTqd7oU7utyDmNO1GPSZjcht718cDAHg2DC3PMG5NYoNiCmTxZl0acOqtwH(WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNaeimhmYkZpm2EeajrgcaYa0rKGa5XPI8gjdc0Hw1dc85JGht9wnyiq4vgFLJapED8N3PImceMdgzL5hgBpcGKidbazsmIeeipovK3izqGo0QEqG09G19ZkQYyeimhmYkZpm2EeajrgcaYaerKGa5XPI8gjdc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKezidbs1eisqaKerccKhNkYBKmiqhAvpiWNpcEm1B1GHaHxz8vocKcFTcYwe89kz5PPdht718cDAHMcFTcYwe89kz5PPdht718cn5cngCJaH5Grwz(HX2JaijYqaqgejiqECQiVrYGaDOv9GaZwXOc200(SrGWRm(khbUAi(l0zeAO)M6ymEeAYf6vdX)aTlVqNwOPWxRWW)xdwk)Y9k7CcIAWuobHFUH)bCceimhmYkZpm2EeajrgcaGerccKhNkYBKmiq4vgFLJaxne)f6mcn0FtDmgpcn5c9QH4FG2LxOtl0KvOTcMTgmHoTqVWJr1XW8(HXkROzHMCHgdUrGo0QEqGPQ4EvhROAAkKHaaOJibb6qR6bbMQIB1tuxzpcKhNkYBKmidbqIrKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGROpzRbt92vzzKHaaiIibb6qR6bbUIEoER(8THa5XPI8gjdYqaivrKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGB2T8kyEp750idbGucrcc0Hw1dcmBfJQpFBiqECQiVrYGmeaafisqG84urEJKbb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRaS7BxJB8w5)74rlGti0PfAk81ka7(214gVv()oE0cht718cn5cDYqIfAPwOXGBeimhmYkZpm2EeajrgcGKsbIeeipovK3izqGo0QEqG09G19ZkQYyei8kJVYrGu4Rva29TRXnER8)D8OfWje60cnf(AfGDF7ACJ3k)FhpAHJP9AEHMCHoziXcTul0yWnceMdgzL5hgBpcGKidbqYKisqGo0QEqGUIg)28P6LcEDQhbYJtf5nsgKHaijzqKGa5XPI8gjdc0Hw1dc8CcRp1BxLLrGWRm(khbsHVwbRiu9sz5z1tW(fEZHzfAjcnqIaH5Grwz(HX2JaijYqaKeirKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5f60cnzfARGzRbtOtl0YvOx4XO6yyE)WyLv0SqtUqJb3cnGak0KvO3TfsvX9Qowr10ubRGzRbtOtl0u4RvGUhSUFwTWVCHJP9AEHwoc9cpgvhdZ7hgRSIMfAGQqNuOLAHgdUfAabuOjRqVBlKQI7vDSIQPPcwbZwdMqNwOjRqtHVwb6EW6(z1c)YfoM2R5f6ei0acOqBfnRSwTlwOjxOtkLe60cnzf6DBHuvCVQJvunnvWky2AWqGo0QEqGPQ4EvhROAAkKHaijqhrccKhNkYBKmiqhAvpiWSvmQGnnTpBei8kJVYrGRgI)cDgHg6VPogJhHMCHE1q8pq7Yl0PfAYk0h(WR(W4WW)xdwk)Y9k7CcIAWuobHFUH)boH4fbbVfAabuOxne)f6mcn0FtDmgpcn5c9QH4FG2LxOtl0YvOLRqF4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8wOtl0KvOnpYJfEJ5OYoNiWJtf5TqNwOHDh3DQjSoMt0AWu25eHJP9AEHoTqd7oU7utW8tzNteoM2R5f6ei0acOqlxH(WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNwOnpYJfEJ5OYoNiWJtf5TqNwOHDh3DQjSoMt0AWu25eHJP9AEHoTqd7oU7utW8tzNteoM2R5f60cnS74UtnH3yoQSZjcht718cDce6ei0acOqVAi(l0Kl0o0QEc09G19ZkQY4aSFdbcZbJSY8dJThbqsKHaizIrKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGVXCuzNtGmeajbIisqG84urEJKbb6qR6bb(8rWJPERgmei8kJVYrGu4Rvq2IGVxjlpnDaNqOtl0hVo(Z7urwObeqHE3w45JGht9wnyHJxh)5DQil0PfAYk0u4Rva29TRXnER8)D8OfWjqGWCWiRm)Wy7raKeziaskvrKGaDOv9Gap(7XTAWu(DDkeipovK3izqgcGKsjejiqECQiVrYGaHxz8vocKScnf(AfGDF7ACJ3k)FhpAbCceOdTQheiS7BxJB8w5)74rdziascuGibbYJtf5nsgei8kJVYrGu4RvGUhSUFwTWVCbCcHgqaf6vdXFHoJq7qR6jKTIrfSPP9zhG(BQJX4rOLJqVAi(hOD5fAabuOPWxRaS7BxJB8w5)74rlGtGaDOv9GaP7bR7NvuLXidbazKcejiqECQiVrYGaDOv9GapNW6t92vzzeimhmYkZpm2EeajrgcaYKerccKhNkYBKmiq4vgFLJa3TfsvX9Qowr10uHJxh)5DQiJaDOv9GatvX9Qowr10uidbazidIeeipovK3izqGo0QEqGpFe8yQ3QbdbcVY4RCeif(AfKTi47vYYtthWjqGWCWiRm)Wy7raKezidbc3pIeeajrKGa5XPI8gjdceELXx5iqZJ8ybJp6x1lfpyogtZJf4XPI8wOtl0RgI)cn5c9QH4FG2Lhb6qR6bbM3pIUhKHaGmisqG84urEJKbbcVY4RCeiS74Utnby33Ug34TY)3XJw4yAVMxOLJqdKsbc0Hw1dcKk29wTWVCidbaqIibbYJtf5nsgei8kJVYrGWUJ7o1eGDF7ACJ3k)FhpAHJP9AEHwocnqkfiqhAvpiqFG8BNhvqpgrgcaGoIeeipovK3izqGWRm(khbc7oU7uta29TRXnER8)D8OfoM2R5fA5i0aPuGaDOv9Gax1XuXU3idbqIrKGaDOv9GaJfwE7vaLJVXO5XqG84urEJKbziaaIisqG84urEJKbbcVY4RCeiS74UtnHSvmQGnnTp7WcpgvhdZ7hgRSIMfA5i0yWnc0Hw1dcKYXu9szxbZ(idbGufrccKhNkYBKmiq4vgFLJaHDh3DQja7(214gVv()oE0cht718cTCeAGOui0acOqBfnRSwTlwOjxOtcKiqhAvpiqk(E(YwdgYqaiLqKGaDOv9GaPXt0enYiqECQiVrYGmeaafisqG84urEJKbbcVY4RCeO5hgBbROzL1QDXcn5cnqukeAabuOPWxRaS7BxJB8w5)74rlGtGaDOv9GajAR6bziaskfisqG84urEJKbbcVY4RCe4Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqWBHoTqVAi(l0zeAO)M6ymEeAYf6vdX)aTlpc0Hw1dc8nMJk7CcKHaizsejiqECQiVrYGaHxz8voc8WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNwOxne)f6mcn0FtDmgpcn5c9QH4FG2Lhb6qR6bbUoMt0AWu25eidbqsYGibbYJtf5nsgei8kJVYrGh(WR(W4WW)xdwk)Y9k7CcIAWuobHFUH)boH4fbbVf60c9QH4VqNrOH(BQJX4rOjxOxne)d0U8cnGak0RgI)cDgHg6VPogJhHMCHE1q8pq7Yl0Pf6dF4vFyC4B84QpmwX0u89boH4fbbVf60cT5NYoNiCmTxZl0Kl0yWTqNwOHDh3DQjSI(XHJP9AEHMCHgdUf60cTCfAhALSSIhMU4xOLJqNuObeqH2HwjlR4HPl(fAjcDsHoTqBfnRSwTlwOLJqNyHwQfAm4wOtac0Hw1dc08tzNtGmeajbsejiqECQiVrYGaDOv9Gaxr)yei8kJVYrGRgI)cDgHg6VPogJhHMCHE1q8pq7Yl0PfAZpLDoraNqOtl0h(WR(W4W34XvFySIPP47dCcXlccEl0PfAROzL1QDXcTCeAGUql1cngCJaJ1Wk4gbsMeJmeajb6isqG84urEJKbbcVY4RCeOdTswwXdtx8l0se6KcDAH28dJTGv0SYA1UyHMCHE1q8xOjvOLRq7qR6jq3dw3pROkJdW(nHgOk0q)n1Xy8i0jqOLAHgdUrGo0QEqGzRyu95BdziasMyejiqECQiVrYGaHxz8voc0HwjlR4HPl(fAjcDsHoTqB(HXwWkAwzTAxSqtUqVAi(l0Kk0YvODOv9eO7bR7NvuLXby)MqdufAO)M6ymEe6ei0sTqJb3iqhAvpiq6EW6(zfvzmYqaKeiIibbYJtf5nsgei8kJVYrGo0kzzfpmDXVqlrOtk0PfAZpm2cwrZkRv7IfAYf6vdXFHMuHwUcTdTQNaDpyD)SIQmoa73eAGQqd93uhJXJqNaHwQfAm4gb6qR6bbEoH1N6TRYYidbqsPkIeeipovK3izqGWRm(khbA(HXwyxV5dKfA5irObIiqhAvpiq)jyOP6LYYZk2XImYqgc8nejiasIibb6qR6bbUIEoER(8THa5XPI8gjdYqaqgejiqhAvpiWuvCREI6k7rG84urEJKbziaasejiqhAvpiWJ)ECRgmLFxNcbYJtf5nsgKHaaOJibbYJtf5nsgeOdTQhe4ZhbpM6TAWqGWRm(khbsHVwbzlc(ELS800bCcHoTqtHVwbzlc(ELS800HJP9AEHMCHgdUfAabuOjRqBfmBnyiqyoyKvMFyS9iasImeajgrccKhNkYBKmiq4vgFLJaxne)f6mcn0FtDmgpcn5c9QH4FG2Lhb6qR6bbUz3YRG59SNtJmeaarejiqECQiVrYGaDOv9GapNW6t92vzzei8kJVYrGu4RvWkcvVuwEw9eSFH3CywHwIqdKiqyoyKvMFyS9iasImeasvejiqhAvpiqy33Ug34TY)3XJgcKhNkYBKmidbGucrcc0Hw1dcmBfJQpFBiqECQiVrYGmeaafisqG84urEJKbbcVY4RCe4cpgvhdZ7hgRSIMfAYfAm4wOtl0RgI)cDgHg6VPogJhHMCHE1q8pq7Yl0acOqlxHEy5nvQsr10ubz7OBvKf60c9UTWZhbpM6TAWcwbZwdMqNwO3TfE(i4XuVvdw441XFENkYcnGak0dlVPsvkQMMkqKNVMUhwOtl0RgI)cDgHg6VPogJhHMCHE1q8pq7Yl0avH2Hw1tiBfJkytt7Zoa93uhJXJql1cnqk0PfAYk0u4RvGUhSUFwTWVCHJP9AEHobiqhAvpiWuvCVQJvunnfYqaKukqKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGVXCuzNtGmeajtIibbYJtf5nsgei8kJVYrGRgI)cDgHg6VPogJhHMCHE1q8pq7YJaDOv9GaxrFYwdM6TRYYidbqsYGibbYJtf5nsgeOdTQhey2kgvWMM2NnceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5f60cTCf6dF4vFyCy4)RblLF5ELDobrnykNGWp3W)aNq8IGG3cDAHg2DC3PMW6yorRbtzNteoM2R5f60cnS74UtnbZpLDor4yAVMxObeqHMSc9Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqWBHobiqyoyKvMFyS9iasImeajbsejiqECQiVrYGaHxz8voc0HwjlR4HPl(fA5i0jf60cnzf6dF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4eIxee8gb6qR6bbc9twgziasc0rKGa5XPI8gjdceELXx5iqhALSSIhMU4xOLJqNuOtl0KvOp8Hx9HXHlx0Z(MhZY3RG9SA8zxdM6TRYYFGtiErqWBHoTqd7oU7utivf3R6yfvttfw4XO6yyE)WyLv0SqlhH(j4yuz(HX2l0PfA5k0W8(HXVADo0QE8OqlhHMmHel0acOqVBl85pNy4OIQPPcwbZwdMqNaeOdTQheifUbZZxoKHaizIrKGaDOv9GaDfn(T5t1lf86upcKhNkYBKmidbqsGiIeeipovK3izqGo0QEqG09G19ZkQYyei8kJVYrG72cF(ZjgoQOAAQGvWS1Gj0acOqtHVwb6EW6(z1c)YfEZHzfAjcDIrGWCWiRm)Wy7raKeziaskvrKGa5XPI8gjdc0Hw1dc85JGht9wnyiq4vgFLJapED8N3PISqdiGcnf(AfKTi47vYYtthWjqGWCWiRm)Wy7raKeziaskLqKGa5XPI8gjdceELXx5iWHL3uPkfvttf(8NtmCuOtl072cpFe8yQ3QblCmTxZl0YrOtSql1cngCl0acOqF4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNq8IGG3iqhAvpiWuvCVQJvunnfYqaKeOarcc0Hw1dceM3ZEo9Ja5XPI8gjdYqaqgParccKhNkYBKmiqhAvpiq6EW6(zfvzmceELXx5iqk81kq3dw3pRw4xUaoHqdiGc9QH4VqNrODOv9eYwXOc200(Sdq)n1Xy8i0YrOxne)d0U8cnqvOtMyHgqaf6DBHp)5edhvunnvWky2AWqGWCWiRm)Wy7raKeziaitsejiqECQiVrYGaDOv9GapNW6t92vzzeimhmYkZpm2EeajrgcaYqgejiqECQiVrYGaHxz8vocCy5nvQsr10ubz7OBvKf60c9UTWZhbpM6TAWcwbZwdMqdiGc9WYBQuLIQPPce55RP7HfAabuOhwEtLQuunnv4ZFoXWreOdTQheyQkUx1XkQMMczidb6eunbIeeajrKGaDOv9GatvXT6jQRShbYJtf5nsgKHaGmisqG84urEJKbbcVY4RCe4QH4VqNrOH(BQJX4rOjxOxne)d0U8iqhAvpiWv0NS1GPE7QSmYqaaKisqGo0QEqGRONJ3QpFBiqECQiVrYGmeaaDejiqECQiVrYGaHxz8vocC1q8xOZi0q)n1Xy8i0Kl0RgI)bAxEeOdTQhe4MDlVcM3ZEonYqaKyejiqhAvpiWSvmQ(8THa5XPI8gjdYqaaerKGa5XPI8gjdc0Hw1dcKUhSUFwrvgJaHxz8vocKcFTcWUVDnUXBL)VJhTaoHqNwOPWxRaS7BxJB8w5)74rlCmTxZl0Kl0jdjwOLAHgdUrGWCWiRm)Wy7raKeziaKQisqG84urEJKbb6qR6bbEoH1N6TRYYiq4vgFLJaPWxRaS7BxJB8w5)74rlGti0PfAk81ka7(214gVv()oE0cht718cn5cDYqIfAPwOXGBeimhmYkZpm2EeajrgcaPeIeeipovK3izqGWRm(khbUAi(l0zeAO)M6ymEeAYf6vdX)aTlpc0Hw1dcCf9jBnyQ3UklJmeaafisqG84urEJKbbcVY4RCe4QH4VqNrOH(BQJX4rOjxOxne)d0U8cDAHMScTvWS1Gj0PfA5k0l8yuDmmVFySYkAwOjxOXGBHgqafAYk072cPQ4EvhROAAQGvWS1Gj0PfAk81kq3dw3pRw4xUWX0EnVqlhHEHhJQJH59dJvwrZcnqvOtk0sTqJb3cnGak0KvO3TfsvX9Qowr10ubRGzRbtOtl0KvOPWxRaDpyD)SAHF5cht718cDceAabuOTIMvwR2fl0Kl0jLscDAHMSc9UTqQkUx1XkQMMkyfmBnyiqhAvpiWuvCVQJvunnfYqaKukqKGa5XPI8gjdceELXx5iWvdXFHoJqd93uhJXJqtUqVAi(hOD5rGo0QEqGVXCuzNtGmeajtIibbYJtf5nsgeOdTQheiDpyD)SIQmgbcVY4RCeif(AfO7bR7Nvl8lxaNqOtl0u4RvGUhSUFwTWVCHJP9AEHMCHE1q8xOjvOLRq7qR6jq3dw3pROkJdW(nHgOk0q)n1Xy8i0jqOLAHgdUrGWCWiRm)Wy7raKeziassgejiqECQiVrYGaDOv9GaZwXOc200(SrGWRm(khbUWJr1XW8(HXkROzHMCHgdUf60c9QH4VqNrOH(BQJX4rOjxOxne)d0U8cDAHwUc9Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqWBHoTqd7oU7utyDmNO1GPSZjcht718cDAHg2DC3PMG5NYoNiCmTxZl0acOqtwH(WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNaeimhmYkZpm2EeajrgcGKajIeeipovK3izqGo0QEqGpFe8yQ3QbdbcVY4RCe4UTWZhbpM6TAWchVo(Z7urwOtl0KvOPWxRaDpyD)SAHF5cht718iqyoyKvMFyS9iasImeajb6isqG84urEJKbb6qR6bbMTIrfSPP9zJaHxz8vocC1q8xOZi0q)n1Xy8i0Kl0RgI)bAxEHoTqlxHMcFTc09G19ZQf(Ll8MdZk0Kl0jwObeqHE1q8xOjxODOv9eO7bR7NvuLXby)MqNaHoTqlxH(WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4TqNwOHDh3DQjSoMt0AWu25eHJP9AEHoTqd7oU7utW8tzNteoM2R5fAabuOjRqF4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8wOtaceMdgzL5hgBpcGKidbqYeJibb6qR6bb6kA8BZNQxk41PEeipovK3izqgcGKarejiqhAvpiWJ)ECRgmLFxNcbYJtf5nsgKHaiPufrcc0Hw1dce29TRXnER8)D8OHa5XPI8gjdYqaKukHibbYJtf5nsgeOdTQheiDpyD)SIQmgbcVY4RCeif(AfO7bR7Nvl8lxaNqObeqHE1q8xOZi0o0QEczRyubBAAF2bO)M6ymEeA5i0RgI)bAxEHgqafAk81ka7(214gVv()oE0c4eiqyoyKvMFyS9iasImeajbkqKGa5XPI8gjdc0Hw1dc8CcRp1BxLLrGWCWiRm)Wy7raKeziaiJuGibbYJtf5nsgei8kJVYrGKvOTcMTgmeOdTQheyQkUx1XkQMMczidziqz57REqaqgPGmjLIKjLQiWu(n1G9iWebjctebaqjaacNifAHMK8Sqx0e9zc9QpHgiWjEdiqOpoH41XBH(BAwODCRPDJ3cnmVpy8healvQHf6Ka9ePqd06rw(mEl0GfnqtO)CJ5Yl0szH2AHwQG7c9UKT(QhHUj4ZT(eA5sAceA5Mu(eeealaorqIWeraaucaGWjsHwOjjpl0fnrFMqV6tObcGr2LLbce6JtiED8wO)MMfAh3AA34TqdZ7dg)bbWsLAyHoPuKifAGwpYYNXBHgSObAc9NBmxEHwkl0wl0sfCxO3LS1x9i0nbFU1NqlxstGql3KYNGGayPsnSqNKmjsHgO1JS8z8wOblAGMq)5gZLxOLYcT1cTub3f6DjB9vpcDtWNB9j0YL0ei0YnP8jiiawQudl0jtCIuObA9ilFgVfAWIgOj0FUXC5fAPSqBTqlvWDHExYwF1Jq3e85wFcTCjnbcTCtkFcccGLk1WcDsGyIuObA9ilFgVfAWIgOj0FUXC5fAPSqBTqlvWDHExYwF1Jq3e85wFcTCjnbcTCtkFcccGfaNiiryIiaakbaq4ePql0KKNf6IMOptOx9j0abW9dei0hNq864Tq)nnl0oU10UXBHgM3hm(dcGLk1WcDsGEIuObA9ilFgVfAWIgOj0FUXC5fAPSqBTqlvWDHExYwF1Jq3e85wFcTCjnbcTCtkFcccGLk1WcDYeNifAGwpYYNXBHgSObAc9NBmxEHwkl0wl0sfCxO3LS1x9i0nbFU1NqlxstGql3KYNGGayPsnSqNeiMifAGwpYYNXBHgSObAc9NBmxEHwkl0wl0sfCxO3LS1x9i0nbFU1NqlxstGql3KYNGGaybWjcseMicaGsaaeork0cnj5zHUOj6Ze6vFcnqGtq1eabc9XjeVoEl0FtZcTJBnTB8wOH59bJ)GayPsnSqNmzIuObA9ilFgVfAWIgOj0FUXC5fAPSqBTqlvWDHExYwF1Jq3e85wFcTCjnbcTCtkFcccGfaduIMOpJ3cTusODOv9i0X6Tpiagb(emebazsCIrGexVQiJatel0G4NSLSEuObkdFm(eaNiwObc1Zj0KrAHMmsbzskawaSdTQNpqCmSPPClJesFCA6EueSja2Hw1Zhiog20uULrcPuTzrERwrphVtvdMYA5RraSdTQNpqCmSPPClJesn)u25esxljh(WR(W4W34XvFySIPP47dCcXlccEla2Hw1Zhiog20uULrcPVXCuzNtiawaSdTQNpJesPXt0enYcGtel0aHBH2ZZ(wO9zl0KC(Kq8kwjkl0aaecGMqZdtx8desHofl07EacmHE3cTLVEHE1Nqte9C89cnfdD8Nf6Yac2cnfl0w3c9t4005eAF2cDkwOH(aeyc9X(UI5eAsoFsOq)emSwfuOPWxRpia2Hw1ZNrcP25tcXRyLO1GP(8TjDTKqwZpm2c1RiIEo(ea7qR65ZiHu8NvLX0VayhAvpFgjKc9yu5qR6rfR3KECAwcC)cGDOv98zKqk0JrLdTQhvSEt6XPzjunH01sIdTswwXdtx8toqMMSMh5XcEKiVRioE7wFbECQiVttwZJ8yHuvCVQJv1SW)QNapovK3cGDOv98zKqk0JrLdTQhvSEt6XPzjobvtiDTK4qRKLv8W0f)KdKPnpYJf8irExrC82T(c84urENMSMh5XcPQ4EvhRQzH)vpbECQiVfa7qR65ZiHuOhJkhAvpQy9M0JtZsCI3KUwsCOvYYkEy6IFYbY0Mh5XcEKiVRioE7wFbECQiVtBEKhlKQI7vDSQMf(x9e4XPI8waSdTQNpJesHEmQCOv9OI1Bsponl5nPRLehALSSIhMU4NCGmnznpYJf8irExrC82T(c84urEN28ipwivf3R6yvnl8V6jWJtf5TayhAvpFgjKc9yu5qR6rfR3KECAwcmYUSS01sIdTswwXdtx8lhYia2Hw1ZNrcP(b9HvwFhpMaybWo0QE(Gtq1essvXT6jQRSxaSdTQNp4eunrgjKUI(KTgm1BxLLLUwswne)Za93uhJXd5RgI)bAxEbWo0QE(Gtq1ezKq6k654T6Z3MayhAvpFWjOAImsiDZULxbZ7zpNw6Ajz1q8pd0FtDmgpKVAi(hOD5fa7qR65dobvtKrcPzRyu95BtaSdTQNp4eunrgjKs3dw3pROkJLgMdgzL5hgBVKKsxlju4Rva29TRXnER8)D8OfWjstHVwby33Ug34TY)3XJw4yAVMN8KHel1yWTayhAvpFWjOAImsi9CcRp1BxLLLgMdgzL5hgBVKKsxlju4Rva29TRXnER8)D8OfWjstHVwby33Ug34TY)3XJw4yAVMN8KHel1yWTayhAvpFWjOAImsiDf9jBnyQ3UkllDTKSAi(Nb6VPogJhYxne)d0U8cGDOv98bNGQjYiH0uvCVQJvunnL01sYQH4FgO)M6ymEiF1q8pq7YNMSwbZwdwA5UWJr1XW8(HXkROzYXGBabKS72cPQ4EvhROAAQGvWS1GLMcFTc09G19ZQf(LlCmTxZlNfEmQogM3pmwzfndutk1yWnGas2DBHuvCVQJvunnvWky2AWstwk81kq3dw3pRw4xUWX0EnFcaeqROzL1QDXKNukLMS72cPQ4EvhROAAQGvWS1Gja2Hw1ZhCcQMiJesFJ5OYoNq6Ajz1q8pd0FtDmgpKVAi(hOD5fa7qR65dobvtKrcP09G19ZkQYyPH5Grwz(HX2ljP01scf(AfO7bR7Nvl8lxaNinf(AfO7bR7Nvl8lx4yAVMN8vdXFPSCDOv9eO7bR7NvuLXby)gqf6VPogJNei1yWTayhAvpFWjOAImsinBfJkytt7ZwAyoyKvMFyS9sskDTKSWJr1XW8(HXkROzYXG70RgI)zG(BQJX4H8vdX)aTlFA5E4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8onS74UtnH1XCIwdMYoNiCmTxZNg2DC3PMG5NYoNiCmTxZdiGK9WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4Dcea7qR65dobvtKrcPpFe8yQ3QbtAyoyKvMFyS9sskDTKSBl88rWJPERgSWXRJ)8ovKttwk81kq3dw3pRw4xUWX0EnVayhAvpFWjOAImsinBfJkytt7ZwAyoyKvMFyS9sskDTKSAi(Nb6VPogJhYxne)d0U8PLlf(AfO7bR7Nvl8lx4nhML8ediGRgI)K7qR6jq3dw3pROkJdW(TeKwUh(WR(W4WW)xdwk)Y9k7CcIAWuobHFUH)boH4fbbVtd7oU7utyDmNO1GPSZjcht718PHDh3DQjy(PSZjcht718acizp8Hx9HXHH)VgSu(L7v25ee1GPCcc)Cd)dCcXlccENabWo0QE(Gtq1ezKqQROXVnFQEPGxN6fa7qR65dobvtKrcPh)94wnyk)UoLayhAvpFWjOAImsif29TRXnER8)D8Oja2Hw1ZhCcQMiJesP7bR7NvuLXsdZbJSY8dJTxssPRLek81kq3dw3pRw4xUaobGaUAi(NXHw1tiBfJkytt7Zoa93uhJXJCwne)d0U8acif(AfGDF7ACJ3k)FhpAbCcbWo0QE(Gtq1ezKq65ewFQ3UkllnmhmYkZpm2Ejjfa7qR65dobvtKrcPPQ4EvhROAAkPRLeYAfmBnycGfa7qR65doXBs2SB5vW8E2ZPLUwswne)Za93uhJXd5RgI)bAxEbWo0QE(Gt8wgjK(8rWJPERgmPH5Grwz(HX2ljP01scz3TfE(i4XuVvdwWky2AWsB(HXwWkAwzTAxSCKQcGDOv98bN4TmsiDf9C8w95BtaSdTQNp4eVLrcPh)94wnyk)UoLayhAvpFWjElJestvXT6jQRSxaSdTQNp4eVLrcPWUVDnUXBL)VJhnbWo0QE(Gt8wgjKMTIr1NVnbWo0QE(Gt8wgjKUI(KTgm1BxLLLUwswne)Za93uhJXd5RgI)bAxEbWo0QE(Gt8wgjK6kA8BZNQxk41PEbWo0QE(Gt8wgjKMQI7vDSIQPPKUwsw4XO6yyE)WyLv0m5yWnGaUAi(Nb6VPogJhYxne)d0U8PL7WYBQuLIQPPcY2r3QiNE3w45JGht9wnybRGzRbl9UTWZhbpM6TAWchVo(Z7urgqahwEtLQuunnvGipFnDpCAYsHVwb6EW6(z1c)YfWjsVAi(Nb6VPogJhYxne)d0U8avhAvpHSvmQGnnTp7a0FtDmgpsnqMaab0kAwzTAxm5jLcbWo0QE(Gt8wgjKc9tww6AjXHwjlR4HPl(LtY0K9WhE1hghUCrp7BEmlFVc2ZQXNDnyQ3Ukl)boH4fbbVfa7qR65doXBzKqkfUbZZxoPRLehALSSIhMU4xojtt2dF4vFyC4Yf9SV5XS89kypRgF21GPE7QS8h4eIxee8onS74UtnHuvCVQJvunnvyHhJQJH59dJvwrZY5j4yuz(HX2NwUW8(HXVADo0QE8OCitiXac4UTWN)CIHJkQMMkyfmBnyjqaSdTQNp4eVLrcPVXCuzNtiDTKSAi(Nb6VPogJhYxne)d0U8cGDOv98bN4TmsiLUhSUFwrvglnmhmYkZpm2EjjLUwsOWxRaDpyD)SAHF5c4ePPWxRaDpyD)SAHF5cht718KVAi(lLLRdTQNaDpyD)SIQmoa73aQq)n1Xy8KaPgdUttwk81kKQIB1tuxzF4yAVMhqaPWxRaDpyD)SAHF5cht718PhwEtLQuunnvGipFnDpSayhAvpFWjElJesZwXOc200(SLgMdgzL5hgBVKKsxljl8yuDmmVFySYkAMCm4o9QH4FgO)M6ymEiF1q8pq7Yla2Hw1ZhCI3YiH0ZjS(uVDvwwAyoyKvMFyS9sskDTKqHVwbRiu9sz5z1tW(fEZHzLaKac4UTWN)CIHJkQMMkyfmBnycGDOv98bN4TmsiLUhSUFwrvglDTKSBl85pNy4OIQPPcwbZwdMayhAvpFWjElJesF(i4XuVvdM0WCWiRm)Wy7LKu6Aj541XFENkYPn)WylyfnRSwTlwosvbWo0QE(Gt8wgjKMQI7vDSIQPPKUwsgwEtLQuunnv4ZFoXWX0RgI)YXHw1tGUhSUFwrvghG9BsnzsVBl88rWJPERgSWX0EnVCsSuJb3cGDOv98bN4TmsifM3ZEo9la2Hw1ZhCI3YiH0SvmQGnnTpBPH5Grwz(HX2ljP01sYQH4FgO)M6ymEiF1q8pq7Yla2Hw1ZhCI3YiH0uvCVQJvunnL01sYHp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCcXlccEla2Hw1ZhCI3YiHu6EW6(zfvzS0WCWiRm)Wy7LKu6AjHcFTc09G19ZQf(LlGtaiGRgI)zCOv9eYwXOc200(Sdq)n1Xy8iNvdX)aTlpqnzIbeWDBHp)5edhvunnvWky2AWaeqk81kKQIB1tuxzF4yAVMxaSdTQNp4eVLrcPNty9PE7QSS0WCWiRm)Wy7LKuaSdTQNp4eVLrcPPQ4EvhROAAkPRLKHL3uPkfvttfKTJUvro9UTWZhbpM6TAWcwbZwdgGaoS8MkvPOAAQarE(A6EyabCy5nvQsr10uHp)5edhtVAi(lNelfcGfa7qR65dunHKNpcEm1B1GjnmhmYkZpm2EjjLUwsOWxRGSfbFVswEA6WX0EnFAk81kiBrW3RKLNMoCmTxZtogCla2Hw1ZhOAImsinBfJkytt7ZwAyoyKvMFyS9sskDTKSAi(Nb6VPogJhYxne)d0U8PPWxRWW)xdwk)Y9k7CcIAWuobHFUH)bCcbWo0QE(avtKrcPPQ4EvhROAAkPRLKvdX)mq)n1Xy8q(QH4FG2LpnzTcMTgS0l8yuDmmVFySYkAMCm4waSdTQNpq1ezKqAQkUvprDL9cGDOv98bQMiJesxrFYwdM6TRYYsxljRgI)zG(BQJX4H8vdX)aTlVayhAvpFGQjYiH0v0ZXB1NVnbWo0QE(avtKrcPB2T8kyEp750sxljRgI)zG(BQJX4H8vdX)aTlVayhAvpFGQjYiH0SvmQ(8Tja2Hw1ZhOAImsi9CcRp1BxLLLgMdgzL5hgBVKKsxlju4Rva29TRXnER8)D8OfWjstHVwby33Ug34TY)3XJw4yAVMN8KHel1yWTayhAvpFGQjYiHu6EW6(zfvzS0WCWiRm)Wy7LKu6AjHcFTcWUVDnUXBL)VJhTaorAk81ka7(214gVv()oE0cht718KNmKyPgdUfa7qR65dunrgjK6kA8BZNQxk41PEbWo0QE(avtKrcPNty9PE7QSS0WCWiRm)Wy7LKu6AjHcFTcwrO6LYYZQNG9l8MdZkbifa7qR65dunrgjKMQI7vDSIQPPKUwswne)Za93uhJXd5RgI)bAx(0K1ky2AWsl3fEmQogM3pmwzfntogCdiGKD3wivf3R6yfvttfScMTgS0u4RvGUhSUFwTWVCHJP9AE5SWJr1XW8(HXkROzGAsPgdUbeqYUBlKQI7vDSIQPPcwbZwdwAYsHVwb6EW6(z1c)YfoM2R5taGaAfnRSwTlM8KsP0KD3wivf3R6yfvttfScMTgmbWo0QE(avtKrcPzRyubBAAF2sdZbJSY8dJTxssPRLKvdX)mq)n1Xy8q(QH4FG2Lpnzp8Hx9HXHH)VgSu(L7v25ee1GPCcc)Cd)dCcXlccEdiGRgI)zG(BQJX4H8vdX)aTlFA5k3dF4vFyCy4)RblLF5ELDobrnykNGWp3W)aNq8IGG3PjR5rESWBmhv25ebECQiVtd7oU7utyDmNO1GPSZjcht718PHDh3DQjy(PSZjcht718jaqaL7Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqW70Mh5XcVXCuzNte4XPI8onS74UtnH1XCIwdMYoNiCmTxZNg2DC3PMG5NYoNiCmTxZNg2DC3PMWBmhv25eHJP9A(eKaabC1q8NChAvpb6EW6(zfvzCa2Vja2Hw1ZhOAImsi9nMJk7CcPRLKvdX)mq)n1Xy8q(QH4FG2LxaSdTQNpq1ezKq6ZhbpM6TAWKgMdgzL5hgBVKKsxlju4Rvq2IGVxjlpnDaNi9XRJ)8ovKbeWDBHNpcEm1B1GfoED8N3PICAYsHVwby33Ug34TY)3XJwaNqaSdTQNpq1ezKq6XFpUvdMYVRtja2Hw1ZhOAImsif29TRXnER8)D8OjDTKqwk81ka7(214gVv()oE0c4ecGDOv98bQMiJesP7bR7NvuLXsxlju4RvGUhSUFwTWVCbCcabC1q8pJdTQNq2kgvWMM2NDa6VPogJh5SAi(hOD5beqk81ka7(214gVv()oE0c4ecGDOv98bQMiJespNW6t92vzzPH5Grwz(HX2ljPayhAvpFGQjYiH0uvCVQJvunnL01sYUTqQkUx1XkQMMkC864pVtfzbWo0QE(avtKrcPpFe8yQ3QbtAyoyKvMFyS9sskDTKqHVwbzlc(ELS800bCcbWcGDOv98b4(LK3pIUhPRLeZJ8ybJp6x1lfpyogtZJf4XPI8o9QH4p5RgI)bAxEbWo0QE(aC)zKqkvS7TAHF5KUwsGDh3DQja7(214gVv()oE0cht718YbiLcbWo0QE(aC)zKqQpq(TZJkOhJsxljWUJ7o1eGDF7ACJ3k)FhpAHJP9AE5aKsHayhAvpFaU)msiDvhtf7ElDTKa7oU7uta29TRXnER8)D8OfoM2R5LdqkfcGDOv98b4(ZiH0yHL3Efq54BmAEmbWo0QE(aC)zKqkLJP6LYUcM9LUwsGDh3DQjKTIrfSPP9zhw4XO6yyE)WyLv0SCWGBbWo0QE(aC)zKqkfFpFzRbt6Ajb2DC3PMaS7BxJB8w5)74rlCmTxZlhGOuaiGwrZkRv7Ijpjqka2Hw1ZhG7pJesPXt0enYcGDOv98b4(ZiHuI2QEKUwsm)WylyfnRSwTlMCGOuaiGu4Rva29TRXnER8)D8OfWjea7qR65dW9NrcPVXCuzNtiDTKC4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8o9QH4FgO)M6ymEiF1q8pq7Yla2Hw1ZhG7pJesxhZjAnyk7CcPRLKdF4vFyCy4)RblLF5ELDobrnykNGWp3W)aNq8IGG3Pxne)Za93uhJXd5RgI)bAxEbWo0QE(aC)zKqQ5NYoNq6Aj5WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4D6vdX)mq)n1Xy8q(QH4FG2Lhqaxne)Za93uhJXd5RgI)bAx(0h(WR(W4W34XvFySIPP47dCcXlccEN28tzNteoM2R5jhdUtd7oU7utyf9Jdht718KJb3PLRdTswwXdtx8lNKacOdTswwXdtx8ljzAROzL1QDXYjXsngCNabWo0QE(aC)zKq6k6hlDSgwb3sitILUwswne)Za93uhJXd5RgI)bAx(0MFk7CIaor6dF4vFyC4B84QpmwX0u89boH4fbbVtBfnRSwTlwoaDPgdUfa7qR65dW9NrcPzRyu95Bt6AjXHwjlR4HPl(LKmT5hgBbROzL1QDXKVAi(lLLRdTQNaDpyD)SIQmoa73aQq)n1Xy8KaPgdUfa7qR65dW9NrcP09G19ZkQYyPRLehALSSIhMU4xsY0MFySfSIMvwR2ft(QH4VuwUo0QEc09G19ZkQY4aSFdOc93uhJXtcKAm4waSdTQNpa3FgjKEoH1N6TRYYsxljo0kzzfpmDXVKKPn)WylyfnRSwTlM8vdXFPSCDOv9eO7bR7NvuLXby)gqf6VPogJNei1yWTayhAvpFaU)msi1FcgAQEPS8SIDSilDTKy(HXwyxV5dKLJeGOaybWo0QE(amYUSSKNpcEm1B1GjnmhmYkZpm2EjjLUwsmpYJfYNBF(ROkJd84urENMcFTcYwe89kz5PPdht718PPWxRGSfbFVswEA6WX0Enp5yWTayhAvpFagzxwoJestvXT6jQRSxaSdTQNpaJSllNrcPh)94wnyk)UoLayhAvpFagzxwoJestvX9Qowr10usxljl8yuDmmVFySYkAMCm4waSdTQNpaJSllNrcPW8E2ZPFbWo0QE(amYUSCgjKsHBW88Lt6Ajz3w4ZFoXWrfvttfScMTgS0YD3wOgJVXJkQiZ7AWcV5WSKtgabC3w4ZFoXWrfvttfoM2R5jhdUtGayhAvpFagzxwoJesH(jllDTKSBl85pNy4OIQPPcwbZwdMayhAvpFagzxwoJes3SB5vW8E2ZPLUwswne)Za93uhJXd5RgI)bAxEbWo0QE(amYUSCgjKc7(214gVv()oE0ea7qR65dWi7YYzKqkfUbZZxoPRLeyE)W4xTohAvpEuoKjK40WUJ7o1esvX9Qowr10uHfEmQogM3pmwzfnlNNGJrL5hgBVuMmcGDOv98byKDz5msiDf9jBnyQ3UkllDTKSAi(Nb6VPogJhYxne)d0U8cGDOv98byKDz5msif6NSS01scS74UtnHuvCVQJvunnvyHhJQJH59dJvwrZY5j4yuz(HX2lLjtAZJ8ybpsK3vehVDRVapovK3cGDOv98byKDz5msinBfJkytt7ZwAyoyKvMFyS9sskDTKSAi(Nb6VPogJhYxne)d0U8Px4XO6yyE)WyLv0m5yWDA5E4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8onS74UtnH1XCIwdMYoNiCmTxZNg2DC3PMG5NYoNiCmTxZdiGK9WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4Dcea7qR65dWi7YYzKqAQkUx1XkQMMs6AjHS72cPQ4EvhROAAQGvWS1Gja2Hw1ZhGr2LLZiHukCdMNVCsxljYLSdlVPsvkQMMk85pNy4iGaswZJ8yHuvCVQJv1SW)QNapovK3jinS74UtnHuvCVQJvunnvyHhJQJH59dJvwrZY5j4yuz(HX2lLjJayhAvpFagzxwoJesH(jllDTKa7oU7utivf3R6yfvttfw4XO6yyE)WyLv0SCEcogvMFyS9szYia2Hw1ZhGr2LLZiH0SvmQ(8Tja2Hw1ZhGr2LLZiH0v0ZXB1NVnbWo0QE(amYUSCgjK6kA8BZNQxk41PEbWo0QE(amYUSCgjK(gZrLDoHayhAvpFagzxwoJesF(i4XuVvdM0WCWiRm)Wy7LKu6Aj541XFENkYPnpYJfYNBF(ROkJd84urEN28dJTGv0SYA1Uy5iLea7qR65dWi7YYzKqk0pzzbWo0QE(amYUSCgjKMTIrfSPP9zlnmhmYkZpm2EjjLUwswne)Za93uhJXd5RgI)bAx(0Y9WhE1hghg()AWs5xUxzNtqudMYji8Zn8pWjeVii4DAy3XDNAcRJ5eTgmLDor4yAVMpnS74UtnbZpLDor4yAVMhqaj7Hp8Qpmom8)1GLYVCVYoNGOgmLtq4NB4FGtiErqW7eia2Hw1ZhGr2LLZiH0NpcEm1B1GjnmhmYkZpm2EjjLUwsoED8N3PISayhAvpFagzxwoJesP7bR7NvuLXsdZbJSY8dJTxssbWo0QE(amYUSCgjKEoH1N6TRYYsdZbJSY8dJTxssbWcGDOv98H3KSIEoER(8Tja2Hw1ZhElJestvXT6jQRSxaSdTQNp8wgjKE83JB1GP876ucGDOv98H3YiH0NpcEm1B1GjnmhmYkZpm2EjjLUwsOWxRGSfbFVswEA6aorAk81kiBrW3RKLNMoCmTxZtogCdiGK1ky2AWea7qR65dVLrcPB2T8kyEp750sxljRgI)zG(BQJX4H8vdX)aTlVayhAvpF4Tmsi9CcRp1BxLLLgMdgzL5hgBVKKsxlju4RvWkcvVuwEw9eSFH3CywjaPayhAvpF4Tmsif29TRXnER8)D8Oja2Hw1ZhElJesZwXO6Z3MayhAvpF4Tmsinvf3R6yfvttjDTKSWJr1XW8(HXkROzYXG70RgI)zG(BQJX4H8vdX)aTlpGak3HL3uPkfvttfKTJUvro9UTWZhbpM6TAWcwbZwdw6DBHNpcEm1B1GfoED8N3PImGaoS8MkvPOAAQarE(A6E40RgI)zG(BQJX4H8vdX)aTlpq1Hw1tiBfJkytt7Zoa93uhJXJudKPjlf(AfO7bR7Nvl8lx4yAVMpbcGDOv98H3YiH03yoQSZjKUwswne)Za93uhJXd5RgI)bAxEbWo0QE(WBzKq6k6t2AWuVDvww6Ajz1q8pd0FtDmgpKVAi(hOD5fa7qR65dVLrcPzRyubBAAF2sdZbJSY8dJTxssPRLKvdX)mq)n1Xy8q(QH4FG2LpTCp8Hx9HXHH)VgSu(L7v25ee1GPCcc)Cd)dCcXlccENg2DC3PMW6yorRbtzNteoM2R5td7oU7utW8tzNteoM2R5beqYE4dV6dJdd)FnyP8l3RSZjiQbt5ee(5g(h4eIxee8obcGDOv98H3YiHuOFYYsxljo0kzzfpmDXVCsMMSh(WR(W4WLl6zFZJz57vWEwn(SRbt92vz5pWjeVii4TayhAvpF4TmsiLc3G55lN01sIdTswwXdtx8lNKPj7Hp8QpmoC5IE238yw(EfSNvJp7AWuVDvw(dCcXlccENg2DC3PMqQkUx1XkQMMkSWJr1XW8(HXkROz58eCmQm)Wy7tlxyE)W4xTohAvpEuoKjKyabC3w4ZFoXWrfvttfScMTgSeia2Hw1ZhElJesDfn(T5t1lf86uVayhAvpF4TmsiLUhSUFwrvglnmhmYkZpm2EjjLUws2Tf(8NtmCur10ubRGzRbdqaPWxRaDpyD)SAHF5cV5WSssSayhAvpF4Tmsi95JGht9wnysdZbJSY8dJTxssPRLKJxh)5DQidiGu4Rvq2IGVxjlpnDaNqaSdTQNp8wgjKMQI7vDSIQPPKUwsgwEtLQuunnv4ZFoXWX072cpFe8yQ3QblCmTxZlNel1yWnGaE4dV6dJdxUON9npMLVxb7z14ZUgm1BxLL)aNq8IGG3cGDOv98H3YiHuyEp750VayhAvpF4TmsiLUhSUFwrvglnmhmYkZpm2EjjLUwsOWxRaDpyD)SAHF5c4eac4QH4FghAvpHSvmQGnnTp7a0FtDmgpYz1q8pq7YdutMyabC3w4ZFoXWrfvttfScMTgmbWo0QE(WBzKq65ewFQ3UkllnmhmYkZpm2Ejjfa7qR65dVLrcPPQ4EvhROAAkPRLKHL3uPkfvttfKTJUvro9UTWZhbpM6TAWcwbZwdgGaoS8MkvPOAAQarE(A6EyabCy5nvQsr10uHp)5edhrgYqi]] )


end