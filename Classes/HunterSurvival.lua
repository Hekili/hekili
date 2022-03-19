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
                return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
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
        chimaeral_sting = 3609, -- 356719
        diamond_ice = 686, -- 203340
        dragonscale_armor = 3610, -- 202589
        hiexplosive_trap = 3606, -- 236776
        hunting_pack = 661, -- 203235
        mending_bandage = 662, -- 212640
        roar_of_sacrifice = 663, -- 53480
        sticky_tar = 664, -- 203264
        survival_tactics = 3607, -- 202746
        trackers_net = 665, -- 212638
        tranquilizing_darts = 5420, -- 356015
        wild_kingdom = 5443, -- 356707
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

        nessingwarys_trapping_apparatus = {
            id = 336744,
            duration = 5,
            max_stack = 1,
            copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
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

    spec:RegisterStateExpr( "check_focus_overcap", function ()
        if settings.allow_focus_overcap then return true end
        if not this_action then return focus.current + focus.regen * gcd.max <= focus.max end
        return focus.current + cast_regen <= focus.max
    end )


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


    local ExpireNesingwarysTrappingApparatus = setfenv( function()
        focus.regen = focus.regen * 0.5
        forecastResources( "focus" )
    end, state )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364490, "tier28_4pc", 363667 )
    -- 2-Set - Mad Bombardier - When Kill Command resets, it has a 40% chance to make your next Wildfire Bomb incur no cooldown.
    -- 4-Set - Mad Bombardier - Your Wildfire Bombs deal 30% additional damage. This bonus is increased to 80% for bombs empowered by Mad Bombardier.
    spec:RegisterAura( "mad_bombardier", {
        id = 363805,
        duration = 20,
        max_stack = 1,
    } )


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

        -- Overfix.
        if buff.mad_bombardier.up and now - action.wildfire_bomb.lastCast < 0.5 * gcd.max then
            removeBuff( "mad_bombardier" )
        end

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
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
            
            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,
            
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
                if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                    applyDebuff( "target", "pouch_of_razor_fragments" )
                    removeBuff( "flayers_mark" )
                end
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
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            gcd = "spell",

            startsCombat = true,

            texture = 2065635,
            bind = "wildfire_bomb",
            talent = "wildfire_infusion",

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            
            start = function() end,

            impact = function ()
                removeBuff( "mad_bombardier" )
                applyDebuff( "target", "pheromone_bomb" )
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

            velocity = 60,

            start = function ()
                removeBuff( "vipers_venom" )
            end,

            impact = function ()
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
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            texture = 2065637,
            bind = "wildfire_bomb",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,

            start = function () end,

            impact = function ()
                removeBuff( "mad_bombardier" )
                applyDebuff( "target", "shrapnel_bomb" )
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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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
            
            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            texture = 2065636,
            bind = "wildfire_bomb",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,

            start = function ()
            end,

            impact = function ()
                removeBuff( "mad_bombardier" )
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
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
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = function ()
                local a = current_wildfire_bomb and current_wildfire_bomb or "wildfire_bomb"
                if a == "wildfire_bomb" or not class.abilities[ a ] then return 2065634 end                
                return action[ a ].texture
            end,

            bind = function () return current_wildfire_bomb end,
            velocity = 35,

            start = function ()
                removeBuff( "flame_infusion" )
                if current_wildfire_bomb ~= "wildfire_bomb" then
                    runHandler( current_wildfire_bomb )
                end
            end,

            impact = function ()
                removeBuff( "mad_bombardier" )
                if current_wildfire_bomb == "wildfire_bomb" then applyDebuff( "target", "wildfire_bomb_dot" )
                else class.abilities[ current_wildfire_bomb ].impact() end
                current_wildfire_bomb = "wildfire_bomb"
            end,

            impactSpell = function ()
                if not talent.wildfire_infusion.enabled then return "wildfire_bomb" end
                if IsActiveSpell( 270335 ) then return "shrapnel_bomb" end
                if IsActiveSpell( 270323 ) then return "pheromone_bomb" end
                if IsActiveSpell( 271045 ) then return "volatile_bomb" end
                return "wildfire_bomb"
            end,

            impactSpells = {
                wildfire_bomb = true,
                shrapnel_bomb = true,
                pheromone_bomb = true,
                volatile_bomb = true
            },

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
    
    --[[ spec:RegisterSetting( "ca_vop_overlap", false, {
        name = "|T2065565:0|t Coordinated Assault Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T2065565:0|t Coordinated Assault even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Coordinated Assault would cost you one or more uses of Coordinated Assault in a given fight.",
        type = "toggle",
        width = "full"
    } ) ]]

    spec:RegisterSetting( "allow_focus_overcap", false, {
        name = "Allow Focus Overcap",
        desc = "The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can " ..
            "result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature " ..
            "appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\n" ..
            "The default setting is |cFFFFD100unchecked|r.",
        type = "toggle",
        width = 1.49
    })


    spec:RegisterPack( "Survival", 20220318, [[d8uN7bqiPk9iqb6siLuBsk8jPumkPkoLuQwfsjEfjvZcPQBbkODjYVirnmkQ6ysrlJKYZKQIPbkKRjvL2gsP03OOIghsfDoKsH1bkuVJIkv18KQQ7rc7du0bLsPAHuuEisPAIuuPYfPOsv2isPO6JuujnsKsr5KGcyLifVKIk0mLsj3KIkHDck9tkQe1qPOsKLsrf8uinvsKVsrLYyLsPSxI(lPgmIdlSyK8yOMmLUmQndYNPWOPiNwYQrkf51sLMTOUnH2TQ(TIHtWXrQWYv65QmDQUoeBhu9DPKXJuPZlvSEKsY8jj7hyztPssuB4Sew1mVAQz((0KotQPwFutT(ir9ocSeviWDddwI(Hilrrrw4f8ilrfIo5jSsLKO3GSywIcdciMCx4GXkRSr5MqOs4ru5RerYHxZJ3aYv(krSYsukKk7WaVKsIAdNLWQM5vtnZ3NM0zsn16JAnPnKObIBAwjkAjs7sutL1YVKsIA5dlrrrw4f8idi0MH8oVaAmxel2eG0KoPhquZ8QPgGgan0(8W51beObJCaYaNxCiaiytmU7bi(ailFcm2bKNBbi4CChGCS71BCaIYacYXaYZTaeSjg3vdnyKtpW5fhcactxHLVRMpjrZ15Nujj67HujjSnLkjrdSxZlrpN5S23qqIYFqLzR0mPlHvnPssu(dQmBLMjrXB58wHeTxaHcbck1QYw9juB5xAzXO(dquPcqOqGGsTQSvFc1w(LwwmQ)aKgacEMSDA9PUvoRXJOy820YIr9NenWEnVefAzMwvVH23qq6sy7Jujjk)bvMTsZKO4TCERqI2lGqHabLAvzR(eQT8lTSyu)biQubiuiqqPwv2QpHAl)sllg1Fasdabpt2oT(u3kN14rumEBAzXO(tIgyVMxI6XQ9neKU0LOwgkqYUujjSnLkjr5pOYSvAMefVLZBfsupwd2tdIFLLPtaPbGCS71BCjKJ1MIvyMhqAaiuiqqP4eySRhiTBI1CyK5KDA9s0a718sutXkmZlDjSQjvsIgyVMxIkIqROvzwIYFqLzR0mPlHTpsLKO8huz2kntIgyVMxI6B80bsLlAv9g6Z04sulF4Te8AEjQ56aiHjoSas8warPnE6aPYfTIbeynxI2be(zXIp6bKwmGyNVnoGyhaXnvhGanlGiKJo8EacfJdKJbKYBJfqOyaXNbqoHquSdGeVfqAXaco(24aYYHTYDaeL24Pda5eyCbvyaHcbc6ssu8woVvir7fq8ynypvNwihD4v6syHrsLKO8huz2kntIgyVMxIsBACK3GRD1w(867CACKZsu8woVvirdSxWzn)SyXhGOaqAcinaKEaekeiOeEM1wF4Svh3fizpHiaiQubi9ci4zY2P1NWZS26dNT64Uaj7PLfJ6parLkaHAUdqAaiEjYAF02IbK(bK(yEaPDarLkaPhajWEbN18ZIfFacmbKMasdaHcbckT8nF41BOJDNwjebarLkaHcbckHNzT1hoB1XDbs2ticas7s0pezjkTPXrEdU2vB5ZRVZPXrolDjS9vQKenWEnVef5yD5S4jr5pOYSvAM0LWsBLkjr5pOYSvAMenWEnVefh5SoWEnVoxNlrZ156pezjk2EsxcR5uQKeL)GkZwPzsu8woVvirdSxWzn)SyXhG0pG0haPbG4rMFprvR90dKwy5oj(dQmBLONVf2LW2uIgyVMxIIJCwhyVMxNRZLO56C9hISeLAeKUew6uQKeL)GkZwPzsu8woVvirdSxWzn)SyXhG0pG0haPbG0lG4rMFprvR90dKwy5oj(dQmBLONVf2LW2uIgyVMxIIJCwhyVMxNRZLO56C9hISe9CPlHL2qQKeL)GkZwPzsu8woVvirdSxWzn)SyXhGatarnj65BHDjSnLOb2R5LO4iN1b2R5156CjAUox)HilrXzoGZsxcBtZlvsIgyVMxIgloEw7ZU87su(dQmBLMjDPlrfwgpIuHlvscBtPssu(dQmBLMjrhbj6XEbjrXB58wHe1Jm)EsCEJzowtvoN4pOYSvIA5dVLGxZlrP95HZRdiqdg5aKboV4qaqWMyC3dq8bqw(eySdip3cqW54oa5y3R34aeLbeKJbKNBbiytmURgAWiNEGZloeaeMUclFxnFsIcpw9hISevKsVNgpNlrdSxZlrHhBfuzwIcpYiSMZhlrdSxZN2qWNvF(wD5eEoxIcpYiSenWEnFsCEJzowtvoNWZ5sxcRAsLKOb2R5LOhIO48Ab2LO8huz2knt6sy7JujjAG9AEjk14EMTAOC0HTTQ3q7dDRxIYFqLzR0mPlHfgjvsIgyVMxIcL5ZeEdixIYFqLzR0mPlHTVsLKO8huz2kntII3Y5Tcj6I8m0SgC6gKm0SgSMfP49smDGuccSvIgyVMxI6XQ9neKUewARujjAG9AEj65mN1(gcsu(dQmBLMjDPlrXzoGZsLKW2uQKeL)GkZwPzs0a718s0Jxb(D951BirXB58wHe1Jm)EYuh7gNMQCoXFqLzlG0aqOqGGsWlbEpnC(hX0YIr9hG0aqOqGGsWlbEpnC(hX0YIr9hG0pGyGTsuChCM1ESgSFsyBkDjSQjvsIYFqLzR0mjkElN3kKO9ciBuwndNFpfw7Ly6wNFaIkvaYgLvZW53tH1EPLfJ6pabMkaKMMhquPcqcSxWzn)SyXhGatfaYgLvZW53tH1Ej8G8oGqlaIAs0a718s0wv2QpHAl)KUe2(ivsIYFqLzR0mjkElN3kKO9ciBuwndNFpfw7Ly6wNFaIkvaYgLvZW53tH1EPLfJ6pabMkae6equPcqcSxWzn)SyXhGatfaYgLvZW53tH1Ej8G8oGqlaIAs0a718s0LV5dVEdDS70s6syHrsLKO8huz2kntII3Y5TcjAVaYgLvZW53tH1EjMU15hGOsfGSrz1mC(9uyTxAzXO(dqGPcaPP5bevQaKa7fCwZplw8biWubGSrz1mC(9uyTxcpiVdi0cGOMenWEnVefpZARpC2QJ7cKSlDjS9vQKeL)GkZwPzsu8woVvirHqYz9YytXAWAVezaPFaXaBLOb2R5LOTQSfQwwtnIusxclTvQKeL)GkZwPzsu8woVvir7bq6fq2OSAgo)EkS2lX0To)aevQaKnkRMHZVNcR9sllg1FacmbK(ciQubib2l4SMFwS4dqGPcazJYQz487PWAVeEqEhqOfarnaPDarLkabBIXD1qdg50dCEXHaG0aq6fqwKNHM1GtuHHEG0IiF518xIPdKsqGTs0a718sulhUjn2u0DdrPlH1CkvsIYFqLzR0mjkElN3kKOlYZqZAWPNVREJwX250(gcc1BOdbHydh5smDGuccSfqAaiqdg5aK(be4XwbvMtIu69045Cj65BHDjSnLOb2R5LO4iN1b2R5156CjAUox)HilrFpKUew6uQKenWEnVefBk6UH4jr5pOYSvAM0LWsBivsIYFqLzR0mjkElN3kKO2XtNPneEoRPgrQKx4U1BainaKEae74P6DE)iRPYmBR3iDEG7ci9diQbiQubi2XtNPneEoRPgrQ0YIr9hG0pGyGTas7s0a718sukehBI3osxcBtZlvsIYFqLzR0mjkElN3kKO2XtNPneEoRPgrQKx4U1BainaKEbKJDn18ixYlEvJo1QjGLOb2R5LO4yHZsxcBZMsLKO8huz2kntII3Y5Tcjk2uSg8PH2a718rgqGjGOwQVasdabpt2oT(uRkBHQL1uJivccjN1lJnfRbR9sKbeyciNaNZApwd2parzarnjAG9AEjkfIJnXBhPlHTPAsLKO8huz2kntII3Y5Tcjk2eJ7QHgmYPh48IdbjAG9AEjkuo(U1BOpFRUS0LW2SpsLKO8huz2kntII3Y5TcjkEMSDA9Pwv2cvlRPgrQeesoRxgBkwdw7LidiWeqoboN1ESgSFaIYaIAs0a718suCSWzPlHTjmsQKeL)GkZwPzsu8woVvirPqGGsIHvtnIuXAlEtics0a718s0wv2cvlRPgrkPlHTzFLkjr5pOYSvAMenWEnVeTBLZA8ikgVvII3Y5TcjQD8KGjEhX5zn1isL8c3TEdaPbGCSRPMh5sEXRA0PwnbSef3bNzThRb7Ne2MsxcBtARujjk)bvMTsZKO4TCERqIsHabLGYrhEpTySDtics0a718s0UvoRptJlDjSnnNsLKO8huz2kntIgyVMxIcLJoSvFMgxII7GZS2J1G9tcBtPlHTjDkvsIYFqLzR0mjAG9AEj6XRa)U(86nKO4TCERqIUm0YNPGkZasdaPxaXlC36naKgaYZ011Tkn1isLGp5WRmdinaepwd2tEjYAF02Ibeycin7lG0aqGgmYbiQdi44C9Yg8diWeq6tFbKgasG9coR5Nfl(aK(vaiWijkUdoZApwd2pjSnLUe2M0gsLKO8huz2kntIgyVMxI2TYznEefJ3krXB58wHefBIXD1qdg50dCEXHaG0aqGqYz9YytXAWAVezaPFaXaBbKgaspaYI8m0SgC657Q3OvSDoTVHGq9g6qqi2WrUethiLGaBbKgacEMSDA9jOLzAv9gAFdH0YIr9hG0aqWZKTtRp5XQ9nesllg1FaIkvasVaYI8m0SgC657Q3OvSDoTVHGq9g6qqi2WrUethiLGaBbK2LO4o4mR9yny)KW2u6syvZ8sLKO8huz2kntII3Y5TcjAVaID8uRkBHQL1uJivYlC36naKgasVaYXUMAEKl5fVQrNA1eWaIkvac2uSg8PH2a718rgqGjG0m1hjAG9AEjARkBHQL1uJiL0LWQwtPssu(dQmBLMjrXB58wHeThaPxa5z666wLMAePsNPneEodiQubi9ciEK53tTQSfQwwxpeYvZN4pOYSfqAhqAai4zY2P1NAvzluTSMAePsqi5SEzSPynyTxImGata5e4Cw7XAW(bikdiQjrdSxZlrPqCSjE7iDjSQPMujjAG9AEjAOfrwlV6bsJ3P1jr5pOYSvAM0LWQwFKkjr5pOYSvAMefVLZBfsuSjg3vdnyKtpW5fhcs0a718s0ZzoR9neKUew1GrsLKO8huz2kntIgyVMxIE8kWVRpVEdjkElN3kKOldT8zkOYmG0aq8iZVNm1XUXPPkNt8huz2cinaepwd2tEjYAF02Ibeyci0Pef3bNzThRb7Ne2MsxcRA9vQKenWEnVefhlCwIYFqLzR0mPlHvnARujjk)bvMTsZKOb2R5LODRCwJhrX4Tsu8woVvirXMyCxn0Gro9aNxCiainaKEaKf5zOzn40Z3vVrRy7CAFdbH6n0HGqSHJCjMoqkbb2cinae8mz706tqlZ0Q6n0(gcPLfJ6paPbGGNjBNwFYJv7BiKwwmQ)aevQaKEbKf5zOzn40Z3vVrRy7CAFdbH6n0HGqSHJCjMoqkbb2ciTlrXDWzw7XAW(jHTP0LWQM5uQKenWEnVeTBLZ6Z04su(dQmBLMjDjSQrNsLKO8huz2kntIgyVMxIE8kWVRpVEdjkElN3kKOldT8zkOYSef3bNzThRb7Ne2MsxcRA0gsLKO8huz2kntIgyVMxIkoVXmhRPkNLO4o4mR9yny)KW2u6sy7J5Lkjr5pOYSvAMenWEnVeDdbFw95B1LLO4o4mR9yny)KW2u6sxIITNujjSnLkjr5pOYSvAMefVLZBfsupY87jNxXtpqA(ncdwKFpXFqLzlG0aqGgmYbi9diqdg5sIbDLOb2R5LOMIvyMx6syvtQKeL)GkZwPzsu8woVvirPqGGs4zwB9HZwDCxGK9eIGenWEnVeLkpJvdHSDKUe2(ivsIYFqLzR0mjkElN3kKOuiqqj8mRT(WzRoUlqYEcrqIgyVMxIgpMpFJSgh5S0LWcJKkjr5pOYSvAMefVLZBfsukeiOeEM1wF4Svh3fizpHiirdSxZlrHQLPYZyLUe2(kvsIgyVMxIMldt(PPnHyne53LO8huz2knt6syPTsLKO8huz2kntII3Y5TcjkEMSDA9PUvoRXJOy82eesoRxgBkwdw7LidiWeqmWwjAG9AEjkvyOhiTVfU7jDjSMtPssu(dQmBLMjrXB58wHeLcbckHNzT1hoB1XDbs2ticaIkvaIxIS2hTTyaPFaPzFKOb2R5LOu8E82TEdPlHLoLkjrdSxZlrfrOv0Qmlr5pOYSvAM0LWsBivsIYFqLzR0mjkElN3kKOuZDasdabQmm56LfJ6paPFarT(ciQubiuiqqj8mRT(WzRoUlqYEcrqIgyVMxIkmEnV0LW208sLKO8huz2kntII3Y5TcjApac0GroaPFaXCAEarLkabpt2oT(eEM1wF4Svh3fizpTSyu)bi9digylG0oG0aq6bqUbjtvVnjGCosM18Ii418j(dQmBbevQaKBqYu1BtWNC4vM13KHZVN4pOYSfqAaiuiqqj4to8kZ6BYW53t2P1diTlrdSxZlrHY8zcVbKlrR35DreCDbjrXMI)5C9gn69gKmv92KaY5izwZlIGxZlDjSnBkvsIYFqLzR0mjkElN3kKOytmURgAWiNEGZloeaKgaYI8m0SgC6gKm0SgSMfP49smDGuccSfqAaiESAFdH0YIr9hG0pGyGTasdabpt2oT(euowoTSyu)bi9digylG0aq6bqcSxWzn)SyXhGataPjGOsfGeyVGZA(zXIparbG0eqAaiEjYAF02Ibeyci9fqOfaXaBbK2LOb2R5LOESAFdbPlHTPAsLKO8huz2kntIgyVMxIcLJLLO4TCERqIInX4UAObJC6boV4qaqAaiESAFdHeIaG0aqwKNHM1Gt3GKHM1G1SifVxIPdKsqGTasdaXlrw7J2wmGatabgbi0cGyGTs0C9SgBLOQ1xPlHTzFKkjr5pOYSvAMefVLZBfs0a7fCwZplw8bikaKMasdaXJ1G9KxIS2hTTyaPFabAWihGOmG0dGap2kOYCsKsVNgpNdiWqabhNRx2GFaPDaHwaedSvIgyVMxI2TYz9zACPlHTjmsQKeL)GkZwPzsu8woVvirdSxWzn)SyXhGOaqAcinaepwd2tEjYAF02IbK(beObJCaIYaspac8yRGkZjrk9EA8CoGadbeCCUEzd(bK2beAbqmWwjAG9AEjQ48gZCSMQCw6syB2xPssu(dQmBLMjrXB58wHenWEbN18ZIfFaIcaPjG0aq8ynyp5LiR9rBlgq6hqGgmYbikdi9aiWJTcQmNeP07PXZ5acmeqWX56Ln4hqAhqOfaXaBLOb2R5LOBi4ZQpFRUS0LW2K2kvsIYFqLzR0mjkElN3kKOESgSNS15XJzabMkaeARenWEnVenobg76bs7Mynhgzw6sxIsncsLKW2uQKeL)GkZwPzs0a718s0Jxb(D951BirXB58wHeLcbckbVe490W5Fetllg1FasdaPhaHcbckbVe490W5Fetllg1Fas)aIb2ciQubildT8zkOYmG0Uef3bNzThRb7Ne2MsxcRAsLKO8huz2kntIgyVMxI2TYznEefJ3krXB58wHefBIXD1qdg50dCEXHaG0aqOqGGspF1B0k2oN23qqOEdDiieB4ixcraquPcq6bqo296nUuKZtln0Gro9aNxCiaiQubiqdg5ae1beCCUEzd(bK(beObJCjXGUaI6astZdiTdinaekeiO0Zx9gTITZP9neeQ3qhccXgoYLqeaKgacfceu65REJwX250(gcc1BOdbHydh5sllg1Fas)aIb2krXDWzw7XAW(jHTP0LW2hPss0a718s0UvoRptJlr5pOYSvAM0LWcJKkjr5pOYSvAMefVLZBfsuSjg3vdnyKtpW5fhcasdabcjN1lJnfRbR9sKbK(bedSfquPcqOqGGsIHvtnIuXAlEtics0a718s0wv2cvlRPgrkPlHTVsLKO8huz2kntII3Y5Tcjk2eJ7QHgmYPh48IdbjAG9AEjkuo(U1BOpFRUS0LWsBLkjrdSxZlrHYrh2QptJlr5pOYSvAM0LWAoLkjr5pOYSvAMefVLZBfs0f5zOzn40Z3vVrRy7CAFdbH6n0HGqSHJCjMoqkbb2cinaeObJCas)ac8yRGkZjrk9EA8CUe98TWUe2Ms0a718suCKZ6a7186CDUenxNR)qKLOVhsxclDkvsIYFqLzR0mjkElN3kKOytmURgAWiNEGZloeKOb2R5LOwoCtASPO7gIsxclTHujjk)bvMTsZKOb2R5LOBi4ZQpFRUSefVLZBfsukeiOeEM1wF4Svh3fizpHiainaekeiOeEM1wF4Svh3fizpTSyu)bi9dint9fqOfaXaBLO4o4mR9yny)KW2u6syBAEPssu(dQmBLMjrdSxZlrfN3yMJ1uLZsu8woVvirPqGGs4zwB9HZwDCxGK9eIaG0aqOqGGs4zwB9HZwDCxGK90YIr9hG0pG0m1xaHwaedSvII7GZS2J1G9tcBtPlHTztPss0a718s0qlISwE1dKgVtRtIYFqLzR0mPlHTPAsLKO8huz2kntIgyVMxIUHGpR(8T6Ysu8woVvirPqGGsEjOhiTBI1NahB68a3fquai9rII7GZS2J1G9tcBtPlHTzFKkjr5pOYSvAMenWEnVevCEJzowtvolrXB58wHe1Jm)EkYcMcTWY2WNnXFqLzlG0aq6bqOqGGsIZBmZXAiKTtcraqAaiuiqqjX5nM5yneY2jTSyu)bi9diqdg5aeLbKEae4XwbvMtIu69045Cabgci44C9Yg8diTdi0cGyGTas7suChCM1ESgSFsyBkDjSnHrsLKO8huz2kntII3Y5Tcjk2eJ7QHgmYPh48IdbaPbG0lG4fUB9gasdaPhabcjN1lJnfRbR9sKbK(bedSfquPcq6fqSJNAvzluTSMAePsEH7wVbG0aqOqGGsIZBmZXAiKTtAzXO(dqGjGaHKZ6LXMI1G1EjYacmeqAci0cGyGTaIkvasVaID8uRkBHQL1uJivYlC36naKgasVacfceusCEJzowdHSDsllg1Fas7aIkvaIxIS2hTTyaPFaPjDcinaKEbe74Pwv2cvlRPgrQKx4U1BirdSxZlrBvzluTSMAePKUe2M9vQKeL)GkZwPzs0a718s0UvoRXJOy8wjkUdoZApwd2pjSnLO4TCERqIInX4UAObJC6boV4qaqAai9ai9cilYZqZAWPNVREJwX250(gcc1BOdbHydh5s8huz2ciQubiqdg5aK(be4XwbvMtIu69045CaPDjQLp8wcEnVefgacq6miaID(24aIPaodiWY3vVrRy70MdquAdbH6naK2UGqSHJC0dixjkK7ai44CaXCSYzaH2hrX4TasbbiDgeaP18TXbKboV4qaqMhqOnFWihGaTJiGyN6naKBsacmaeG0zqae7aiMc4mGalFx9gTITtBoarPneeQ3aqA7ccXgoYbiDgea5mnizlGGJZbeZXkNbeAFefJ3cifeG0zqwabAWihGuhGqX5PfG4MyabpNdideGyUyEJzogqmRCgqMfqmhcbFwab13QllDjSnPTsLKO8huz2kntIgyVMxI2TYznEefJ3krXDWzw7XAW(jHTPefVLZBfsuSjg3vdnyKtpW5fhcasdazrEgAwdo98D1B0k2oN23qqOEdDiieB4ixI)GkZwaPbGGNjBNwFcAzMwvVH23qiTSyu)biWeq6bqGgmYbikdi9aiWJTcQmNeP07PXZ5acmeqWX56Ln4hqAhqOfaXaBbK2bKgacEMSDA9jpwTVHqAzXO(dqGjG0dGanyKdqugq6bqGhBfuzojsP3tJNZbeyiGGJZ1lBWpG0oGqlaIb2ciTdinaKEaKEbepY87PZzoR9nes8huz2ciQubiEK53tNZCw7BiK4pOYSfqAai4zY2P1NoN5S23qiTSyu)biWeq6bqGgmYbikdi9aiWJTcQmNeP07PXZ5acmeqWX56Ln4hqAhqOfaXaBbK2bK2LOw(WBj418suZTYnbiWY3vVrRy70MdquAdbH6naK2UGqSHJCaY85oaI5yLZacTpIIXBbKccq6milG4BiCasSmGmpGGNjBNwp9aY4M4TvDmGC(iaiix9gaI5yLZacTpIIXBbKccq6milGGr2LFhqGgmYbiH4G8oGuhGW)Gyycq8bqoKZJ6be3ediH4G8oGmqaIxImGKzihqGMfqIVdGmqasNbzbeFdHdq8bqWJidideeGGNjBNwV0LW20CkvsIYFqLzR0mjkElN3kKOytmURgAWiNEGZloeKOb2R5LONZCw7BiiDjSnPtPssu(dQmBLMjrdSxZlrpEf431NxVHefVLZBfsu74PJxb(D951BKwgA5ZuqLzaPbG0lGqHabLWZS26dNT64Uaj7jebarLkaXJm)EkYcMcTWY2WNnXFqLzlG0aqwgA5ZuqLzaPbG0lGqHabLeN3yMJ1qiBNeIGef3bNzThRb7Ne2MsxcBtAdPss0a718s0LV5dVEdDS70sIYFqLzR0mPlHvnZlvsIgyVMxI2QYw9juB5NeL)GkZwPzsxcRAnLkjr5pOYSvAMefVLZBfs0EbekeiOeEM1wF4Svh3fizpHiirdSxZlrXZS26dNT64Uaj7sxcRAQjvsIYFqLzR0mjkElN3kKOuiqqjX5nM5yneY2jHiaiQubiqdg5ae1bKa718PUvoRXJOy82eooxVSb)acmbeObJCjXGUaIkvacfceucpZARpC2QJ7cKSNqeKOb2R5LOIZBmZXAQYzPlHvT(ivsIYFqLzR0mjAG9AEj6gc(S6Z3QllrXDWzw7XAW(jHTP0LWQgmsQKeL)GkZwPzsu8woVvirTJNAvzluTSMAePsldT8zkOYSenWEnVeTvLTq1YAQrKs6syvRVsLKO8huz2kntIgyVMxIE8kWVRpVEdjkElN3kKOuiqqj4LaVNgo)JycrqII7GZS2J1G9tcBtPlDj65sLKW2uQKeL)GkZwPzsu8woVvirXMyCxn0Gro9aNxCiainaKEaKEbKnkRMHZVNcR9smDRZparLkaPxazJYQz487PWAVeIaG0aq2OSAgo)EkS2lzr2WR5be1bKnkRMHZVNcR9s1di9di9fqAhquPcq2OSAgo)EkS2lHiainaKnkRMHZVNcR9sllg1FacmbeyK5LOb2R5LOwoCtASPO7gIsxcRAsLKO8huz2kntIgyVMxIE8kWVRpVEdjkElN3kKO9ci2XthVc876ZR3i5fUB9gasdaXJ1G9KxIS2hTTyabMaI5equPcqOqGGsWlbEpnC(hXeIaG0aqOqGGsWlbEpnC(hX0YIr9hG0pGyGTsuChCM1ESgSFsyBkDjS9rQKenWEnVefkhDyR(mnUeL)GkZwPzsxclmsQKeL)GkZwPzsu8woVvir7fq2OSAgo)EkS2lX0To)aevQaKEbKnkRMHZVNcR9sicasdaPhazJYQz487PWAVKfzdVMhquhq2OSAgo)EkS2lvpG0pGOM5bevQaKnkRMHZVNcR9s4b5DarbG0eqAhquPcq2OSAgo)EkS2lHiainaKnkRMHZVNcR9sllg1FacmbeyK5bevQaeQ5oaPbG4LiR9rBlgq6hqAAEjAG9AEj6Y38HxVHo2DAjDjS9vQKeL)GkZwPzsu8woVvir7fq2OSAgo)EkS2lX0To)aevQaKEbKnkRMHZVNcR9sicasdazJYQz487PWAVKfzdVMhquhq2OSAgo)EkS2lvpG0pGOM5bevQaKnkRMHZVNcR9sicasdazJYQz487PWAV0YIr9hGatarnZdiQubiuZDasdaXlrw7J2wmG0pGOM5LOb2R5LOTQSvFc1w(jDjS0wPssu(dQmBLMjrXB58wHeTxazJYQz487PWAVet368dquPcqWdC(J3tFzyY1qbdinae8mz706tTQSvFc1w(LwwmQ)aevQaKEbe8aN)490xgMCnuWasdaPhaPxazJYQz487PWAVeIaG0aq2OSAgo)EkS2lzr2WR5be1bKnkRMHZVNcR9s1di9di9X8aIkvaYgLvZW53tH1EjebaPbGSrz1mC(9uyTxAzXO(dqGjGOM5bevQaKEbKnkRMHZVNcR9sicas7aIkvac1ChG0aq8sK1(OTfdi9di9X8s0a718su8mRT(WzRoUlqYU0LWAoLkjrdSxZlr7w5S(mnUeL)GkZwPzsxclDkvsIYFqLzR0mjkElN3kKOytmURgAWiNEGZloeKOb2R5LOq547wVH(8T6YsxclTHujjAG9AEjAOfrwlV6bsJ3P1jr5pOYSvAM0LW208sLKO8huz2kntII3Y5TcjkesoRxgBkwdw7Lidi9diQbi0cGyGTasda5yxtnpYL8Ix1OtTAcyarLkaHcbckjgwn1isfRT4nHiaiQubi9cih7AQ5rUKx8QgDQvtadinaKEaeiKCwVm2uSgS2lrgq6hqmWwarLkabBIXD1qdg50dCEXHaG0aq6bqEMUUUvPPgrQe8jhELzaPbGyhpD8kWVRpVEJKx4U1Bainae74PJxb(D951BKwgA5ZuqLzarLka5z666wLMAePscM4DeNNbKgasVacfceusCEJzowdHSDsicasdaPha5y3R34sropT0qdg50dCEXHaGOsfGanyKdquhqWX56Ln4hq6hqGgmYLed6ciWqajWEnFQBLZA8ikgVnHJZ1lBWpGqlasFaK2bK2bevQaeQ5oaPbG4LiR9rBlgq6hqAAEaPDjAG9AEjARkBHQL1uJiL0LW2SPujjk)bvMTsZKOb2R5LODRCwJhrX4Tsu8woVvirp21uZJCjV4vn6uRMagqAai2XtcM4DeNN1uJivYlC36naKgasVacfceusmSAQrKkwBXBcrqII7GZS2J1G9tcBtPlHTPAsLKO8huz2kntII3Y5TcjAG9coR5Nfl(aeycinbKgasVaYI8m0SgCA7KJUNh5U8EA88qdYBR3qF(wD5lX0bsjiWwjAG9AEjkow4S0LW2SpsLKO8huz2kntII3Y5TcjAG9coR5Nfl(aeycinbKgasVaYI8m0SgCA7KJUNh5U8EA88qdYBR3qF(wD5lX0bsjiWwaPbGGNjBNwFQvLTq1YAQrKkbHKZ6LXMI1G1EjYacmbKtGZzThRb7hG0aq6bqWMI1Gpn0gyVMpYacmbe1s9fquPcqSJNotBi8CwtnIujVWDR3aqAxIgyVMxIsH4yt82r6syBcJKkjr5pOYSvAMefVLZBfsuSjg3vdnyKtpW5fhcs0a718s0ZzoR9neKUe2M9vQKeL)GkZwPzs0a718suX5nM5ynv5SefVLZBfsupY87Pilyk0clBdF2e)bvMTasdaPhaHcbckjoVXmhRHq2ojebaPbGqHabLeN3yMJ1qiBN0YIr9hG0pGanyKdqugq6bqGhBfuzojsP3tJNZbeyiGGJZ1lBWpG0oGqlaIb2cinaKEbekeiOuRkB1NqTLFPLfJ6parLkaHcbckjoVXmhRHq2oPLfJ6paPbG8mDDDRstnIujbt8oIZZas7suChCM1ESgSFsyBkDjSnPTsLKO8huz2kntIgyVMxI2TYznEefJ3krXB58wHefcjN1lJnfRbR9sKbK(bedSfqAaiytmURgAWiNEGZloeKO4o4mR9yny)KW2u6syBAoLkjr5pOYSvAMenWEnVeDdbFw95B1LLO4TCERqIsHabL8sqpqA3eRpbo205bUlGOaq6dGOsfGyhpDM2q45SMAePsEH7wVHef3bNzThRb7Ne2MsxcBt6uQKeL)GkZwPzsu8woVvirTJNotBi8CwtnIujVWDR3qIgyVMxIkoVXmhRPkNLUe2M0gsLKO8huz2kntIgyVMxIE8kWVRpVEdjkElN3kKOldT8zkOYmG0aq8ynyp5LiR9rBlgqGjGyobevQaekeiOe8sG3tdN)rmHiirXDWzw7XAW(jHTP0LWQM5Lkjr5pOYSvAMefVLZBfs0NPRRBvAQrKkDM2q45mG0aqGgmYbiWeqGhBfuzojsP3tJNZbeAbqudqAai2XthVc876ZR3iTSyu)biWeq6lGqlaIb2krdSxZlrBvzluTSMAePKUew1AkvsIgyVMxIInfD3q8KO8huz2knt6syvtnPssu(dQmBLMjrdSxZlr7w5SgpIIXBLO4TCERqIInX4UAObJC6boV4qqII7GZS2J1G9tcBtPlHvT(ivsIYFqLzR0mjkElN3kKOlYZqZAWPTto6EEK7Y7PXZdniVTEd95B1LVethiLGaBLOb2R5LOTQSfQwwtnIusxcRAWiPssu(dQmBLMjrdSxZlrfN3yMJ1uLZsu8woVvirPqGGsIZBmZXAiKTtcraquPcqGgmYbiQdib2R5tDRCwJhrX4TjCCUEzd(beyciqdg5sIbDbeyiG0SVaIkvaID80zAdHNZAQrKk5fUB9gaIkvacfceuQvLT6tO2YV0YIr9Nef3bNzThRb7Ne2MsxcRA9vQKeL)GkZwPzs0a718s0ne8z1NVvxwII7GZS2J1G9tcBtPlHvnARujjk)bvMTsZKO4TCERqI2dG8mDDDRstnIuj4to8kZasdaXoE64vGFxFE9gjVWDR3aquPcqEMUUUvPPgrQKGjEhX5zarLka5z666wLMAePsNPneEodinaeObJCacmbK(AEaPDaPbG0lGCSRPMh5sEXRA0PwnbSenWEnVeTvLTq1YAQrKs6sx6su48E18syvZ8QPM57ttAReTvSF9gNe1CRTBoalmaSMRWyabquYediLOWSoGanlG0gHLXJiv4TbqwMoqQLTaYnImGei(igoBbeSP4n4lbOPTQNbKMWyaH2NhoVoBbK24rMFp12AdG4dG0gpY87P2wI)GkZ22aiHdiM7zUCBbi90KUTNa0aOXCRTBoalmaSMRWyabquYediLOWSoGanlG0MZBdGSmDGulBbKBezajq8rmC2ciytXBWxcqtBvpdin7lmgqO95HZRZwabTePDa568EqxaHwdi(aiTfsai2cED18aYiWB4Zci9OC7aspnPB7janaAm3A7MdWcdaR5kmgqaeLmXasjkmRdiqZciTbBV2ailthi1Ywa5grgqceFedNTac2u8g8La00w1ZastZdJbeAFE486SfqAZnizQ6TP2wBaeFaK2CdsMQEBQTL4pOYSTnaspQr32taAAR6zaPzFGXacTppCED2ciOLiTdixN3d6ci0AaXhaPTqcaXwWRRMhqgbEdFwaPhLBhq6PjDBpbOPTQNbKMWiymGq7ZdNxNTacAjs7aY159GUacTgq8bqAlKaqSf86Q5bKrG3WNfq6r52bKEAs32taAAR6zaPzFHXacTppCED2ciOLiTdixN3d6ci0AaXhaPTqcaXwWRRMhqgbEdFwaPhLBhq6PjDBpbObqJ5wB3CawyaynxHXacGOKjgqkrHzDabAwaPnuJqBaKLPdKAzlGCJidibIpIHZwabBkEd(saAAR6zaPzFGXacTppCED2ciOLiTdixN3d6ci0AaXhaPTqcaXwWRRMhqgbEdFwaPhLBhq6PjDBpbOPTQNbKM9fgdi0(8W51zlG0Mf5zOzn4uBRnaIpasBwKNHM1GtTTe)bvMTTbq6PjDBpbOPTQNbKM0wymGq7ZdNxNTacAjs7aY159GUacTgq8bqAlKaqSf86Q5bKrG3WNfq6r52bKE6dDBpbOPTQNbKM0wymGq7ZdNxNTasB8iZVNABTbq8bqAJhz(9uBlXFqLzBBaKEuJUTNa00w1ZastAlmgqO95HZRZwaPnlYZqZAWP2wBaeFaK2SipdnRbNABj(dQmBBdG0tt62EcqtBvpdinPtymGq7ZdNxNTasB8iZVNABTbq8bqAJhz(9uBlXFqLzBBaKEAs32taAa0yU12nhGfgawZvymGaikzIbKsuywhqGMfqAdoZbCUnaYY0bsTSfqUrKbKaXhXWzlGGnfVbFjanTv9mG0SjmgqO95HZRZwabTePDa568EqxaHwdi(aiTfsai2cED18aYiWB4Zci9OC7aspnPB7janTv9mG0SpWyaH2NhoVoBbe0sK2bKRZ7bDbeAnG4dG0wibGyl41vZdiJaVHplG0JYTdi90KUTNa00w1ZaIAnHXacTppCED2ciOLiTdixN3d6ci0AaXhaPTqcaXwWRRMhqgbEdFwaPhLBhq6PjDBpbObqdmGOWSoBbeZjGeyVMhqY15xcqJevyhOkZsuyqabfzHxWJmGqBgY78cObgeqmxel2eG0KoPhquZ8QPgGganWGacTppCEDabAWihGmW5fhcac2eJ7EaIpaYYNaJDa55wacoh3bih7E9ghGOmGGCmG8ClabBIXD1qdg50dCEXHaGW0vy57Q5taAa0eyVM)sclJhrQWvxHYWJTcQmt)hIScrk9EA8Co9JGIJ9cIE4rgHveyVMpjoVXmhRPkNt45C6HhzewZ5JveyVMpTHGpR(8T6Yj8Co945TLxZRWJm)EsCEJzowtvodOjWEn)LewgpIuHRUcLperX51cSdOjWEn)LewgpIuHRUcLPg3ZSvdLJoSTv9gAFOB9aAcSxZFjHLXJiv4QRqzOmFMWBa5aAcSxZFjHLXJiv4QRqzpwTVHa9fKIf5zOzn40nizOznynlsX7Ly6aPeeylGMa718xsyz8isfU6ku(CMZAFdbanaAcSxZFkmfRWmp9fKcpwd2tdIFLLPZgh7E9gxc5yTPyfM5BqHabLItGXUEG0UjwZHrMt2P1dOjWEn)PUcLfrOv0QmdObgeqmxhajmXHfqI3cikTXthivUOvmGaR5s0oGWplw8zUpG0Ibe78TXbe7aiUP6aeOzbeHC0H3dqOyCGCmGuEBSacfdi(maYjeIIDaK4TaslgqWX3ghqwoSvUdGO0gpDaiNaJlOcdiuiqqxcqtG9A(tDfk7B80bsLlAv9g6Z040xqk61J1G9uDAHC0Hxanb2R5p1vOmYX6Yzr6)qKvqBACK3GRD1w(867CACKZ0xqkcSxWzn)SyXNIMn6HcbckHNzT1hoB1XDbs2ticQu1lEMSDA9j8mRT(WzRoUlqYEAzXO(tLkQ5UgEjYAF02I7VpMVDvQ6jWEbN18ZIfFWSzdkeiO0Y38HxVHo2DALqeuPIcbckHNzT1hoB1XDbs2ticTdOjWEn)PUcLrowxolEaAGbHbbeZDCo6aiqbUEdaPZGSaIDqOCab59kdiDgeaXuaNbebehqmh4B(WR3aqA77oTae706PhqMfqkiaXnXacEMSDA9asDaIpdGKN3aq8bqSCo6aiqbUEdaPZGSaI5UbHYtacmaeG8ZZaYabiUj(yabpVT8A(dqILbKGkZaIpaIi7asRYnvpG4MyaPP5bKJXZBpajZCROd9aIBIbKRebeOaZhG0zqwaXC3Gq5asG4Jy4foY5ojanWGWGasG9A(tDfk)ClOb5T6LVjdNPVGuCdsMQEB65wqdYB1lFtgo3OhkeiO0Y38HxVHo2DALqeuPcpt2oT(0Y38HxVHo2DALwwmQ)GztZRsLhRb7jVezTpABX93K22oGMa718N6kugh5SoWEnVoxNt)hIScS9a0eyVM)uxHY4iN1b2R5156C6)qKvqnc0F(wyxrt6lifb2l4SMFwS4R)(0WJm)EIQw7PhiTWYDs8huz2cOjWEn)PUcLXroRdSxZRZ150)HiR4C6pFlSROj9fKIa7fCwZplw81FFA0Rhz(9evT2tpqAHL7K4pOYSfqtG9A(tDfkJJCwhyVMxNRZP)drwboZbCM(Z3c7kAsFbPiWEbN18ZIfFWunanb2R5p1vOCS44zTp7YVdObqtG9A(lrnckoEf431NxVb94o4mR9yny)u0K(csbfceucEjW7PHZ)iMwwmQ)A0dfceucEjW7PHZ)iMwwmQ)63aBvPAzOLptbvMBhqtG9A(lrncQRq5UvoRXJOy8w6XDWzw7XAW(POj9fKcSjg3vdnyKtpW5fhcnOqGGspF1B0k2oN23qqOEdDiieB4ixcrqLQEo296nUuKZtln0Gro9aNxCiOsf0Gro1XX56Ln4VFObJCjXGUQ308T3Gcbck98vVrRy7CAFdbH6n0HGqSHJCjeHguiqqPNV6nAfBNt7BiiuVHoeeInCKlTSyu)1Vb2cOjWEn)LOgb1vOC3kN1NPXb0eyVM)suJG6kuUvLTq1YAQrKI(csb2eJ7QHgmYPh48IdHgqi5SEzSPynyTxIC)gyRkvuiqqjXWQPgrQyTfVjebanb2R5Ve1iOUcLHYX3TEd95B1LPVGuGnX4UAObJC6boV4qaqtG9A(lrncQRqzOC0HT6Z04aAcSxZFjQrqDfkJJCwhyVMxNRZP)drwX7b9NVf2v0K(csXI8m0SgC657Q3OvSDoTVHGq9g6qqi2WrUethiLGaBBanyKRF4XwbvMtIu69045Canb2R5Ve1iOUcLTC4M0ytr3nePVGuGnX4UAObJC6boV4qaqtG9A(lrncQRq5ne8z1NVvxMEChCM1ESgSFkAsFbPGcbckHNzT1hoB1XDbs2ticnOqGGs4zwB9HZwDCxGK90YIr9x)nt9LwmWwanb2R5Ve1iOUcLfN3yMJ1uLZ0J7GZS2J1G9trt6lifuiqqj8mRT(WzRoUlqYEcrObfceucpZARpC2QJ7cKSNwwmQ)6VzQV0Ib2cOjWEn)LOgb1vOCOfrwlV6bsJ3P1bOjWEn)LOgb1vO8gc(S6Z3QltpUdoZApwd2pfnPVGuqHabL8sqpqA3eRpbo205bURI(aOjWEn)LOgb1vOS48gZCSMQCMEChCM1ESgSFkAsFbPWJm)EkYcMcTWY2WNnXFqLzBJEOqGGsIZBmZXAiKTtcrObfceusCEJzowdHSDsllg1F9dnyKJw3d8yRGkZjrk9EA8ComehNRx2G)2PfdSTDanb2R5Ve1iOUcLBvzluTSMAePOVGuGnX4UAObJC6boV4qOrVEH7wVrJEGqYz9YytXAWAVe5(nWwvQ61oEQvLTq1YAQrKk5fUB9gnOqGGsIZBmZXAiKTtAzXO(dMqi5SEzSPynyTxImmSjTyGTQu1RD8uRkBHQL1uJivYlC36nA0lfceusCEJzowdHSDsllg1FTRsLxIS2hTT4(BsNn61oEQvLTq1YAQrKk5fUB9gaAGbbeyaiaPZGai25BJdiMc4mGalFx9gTITtBoarPneeQ3aqA7ccXgoYrpGCLOqUdGGJZbeZXkNbeAFefJ3cifeG0zqaKwZ3ghqg48IdbazEaH28bJCac0oIaIDQ3aqUjbiWaqasNbbqSdGykGZacS8D1B0k2oT5aeL2qqOEdaPTlieB4ihG0zqaKZ0GKTacoohqmhRCgqO9rumElGuqasNbzbeObJCasDacfNNwaIBIbe8CoGmqaI5I5nM5yaXSYzazwaXCie8zbeuFRUmGMa718xIAeuxHYDRCwJhrX4T0J7GZS2J1G9trt6lifytmURgAWiNEGZloeA0tVlYZqZAWPNVREJwX250(gcc1BOdbHydh5uPcAWix)WJTcQmNeP07PXZ5TdObgeqm3k3eGalFx9gTITtBoarPneeQ3aqA7ccXgoYbiZN7aiMJvodi0(ikgVfqkiaPZGSaIVHWbiXYaY8acEMSDA90diJBI3w1XaY5JaGGC1BaiMJvodi0(ikgVfqkiaPZGSacgzx(DabAWihGeIdY7asDac)dIHjaXha5qopQhqCtmGeIdY7aYabiEjYasMHCabAwaj(oaYabiDgKfq8neoaXhabpImGmqqacEMSDA9aAcSxZFjQrqDfk3TYznEefJ3spUdoZApwd2pfnPVGuGnX4UAObJC6boV4qOXI8m0SgC657Q3OvSDoTVHGq9g6qqi2WrUg4zY2P1NGwMPv1BO9nesllg1FWShObJC06EGhBfuzojsP3tJNZHH44C9Yg83oTyGTT3apt2oT(KhR23qiTSyu)bZEGgmYrR7bESvqL5KiLEpnEohgIJZ1lBWF70Ib22EJE61Jm)E6CMZAFdbvQ8iZVNoN5S23qObEMSDA9PZzoR9nesllg1FWShObJC06EGhBfuzojsP3tJNZHH44C9Yg83oTyGTT3oGMa718xIAeuxHYNZCw7BiqFbPaBIXD1qdg50dCEXHaGMa718xIAeuxHYhVc876ZR3GEChCM1ESgSFkAsFbPWoE64vGFxFE9gPLHw(mfuzUrVuiqqj8mRT(WzRoUlqYEcrqLkpY87Pilyk0clBdF2gldT8zkOYCJEPqGGsIZBmZXAiKTtcraqtG9A(lrncQRq5LV5dVEdDS70cqtG9A(lrncQRq5wv2QpHAl)a0eyVM)suJG6kugpZARpC2QJ7cKStFbPOxkeiOeEM1wF4Svh3fizpHiaOjWEn)LOgb1vOS48gZCSMQCM(csbfceusCEJzowdHSDsicQubnyKt9a718PUvoRXJOy82eooxVSb)WeAWixsmORkvuiqqj8mRT(WzRoUlqYEcraqtG9A(lrncQRq5ne8z1NVvxMEChCM1ESgSFkAcOjWEn)LOgb1vOCRkBHQL1uJif9fKc74Pwv2cvlRPgrQ0YqlFMcQmdOjWEn)LOgb1vO8XRa)U(86nOh3bNzThRb7NIM0xqkOqGGsWlbEpnC(hXeIaGganb2R5Ve2EkmfRWmp9fKcpY87jNxXtpqA(ncdwKFpXFqLzBdObJC9dnyKljg0fqtG9A(lHTN6kuMkpJvdHSDOVGuqHabLWZS26dNT64Uaj7jebanb2R5Ve2EQRq54X85BK14iNPVGuqHabLWZS26dNT64Uaj7jebanb2R5Ve2EQRqzOAzQ8mw6lifuiqqj8mRT(WzRoUlqYEcraqtG9A(lHTN6kuoxgM8ttBcXAiYVdOjWEn)LW2tDfktfg6bs7BH7E0xqkWZKTtRp1TYznEefJ3MGqYz9YytXAWAVezyAGTaAcSxZFjS9uxHYu8E82TEd6lifuiqqj8mRT(WzRoUlqYEcrqLkVezTpABX93SpaAcSxZFjS9uxHYIi0kAvMb0eyVM)sy7PUcLfgVMN(csb1CxdOYWKRxwmQ)6xT(QsffceucpZARpC2QJ7cKSNqea0eyVM)sy7PUcLHY8zcVbKtF9oVlIGRlifytX)CUEJg9EdsMQEBsa5CKmR5frWR5PVGu0d0GrU(nNMxLk8mz706t4zwB9HZwDCxGK90YIr9x)gyB7n65gKmv92KaY5izwZlIGxZRs1nizQ6Tj4to8kZ6BYW53BqHabLGp5WRmRVjdNFpzNwF7aAcSxZFjS9uxHYESAFdb6lifytmURgAWiNEGZloeASipdnRbNUbjdnRbRzrkEVethiLGaBB4XQ9nesllg1F9BGTnWZKTtRpbLJLtllg1F9BGTn6jWEbN18ZIfFWSPkvb2l4SMFwS4trZgEjYAF02IHzFPfdSTDanb2R5Ve2EQRqzOCSm956zn2QqT(sFbPaBIXD1qdg50dCEXHqdpwTVHqcrOXI8m0SgC6gKm0SgSMfP49smDGuccSTHxIS2hTTyycJOfdSfqtG9A(lHTN6kuUBLZ6Z040xqkcSxWzn)SyXNIMn8ynyp5LiR9rBlUFObJC06EGhBfuzojsP3tJNZHH44C9Yg83oTyGTaAcSxZFjS9uxHYIZBmZXAQYz6lifb2l4SMFwS4trZgESgSN8sK1(OTf3p0GroADpWJTcQmNeP07PXZ5WqCCUEzd(BNwmWwanb2R5Ve2EQRq5ne8z1NVvxM(csrG9coR5Nfl(u0SHhRb7jVezTpABX9dnyKJw3d8yRGkZjrk9EA8ComehNRx2G)2PfdSfqtG9A(lHTN6kuoobg76bs7MynhgzM(csHhRb7jBDE8ygMkOTaAa0eyVM)s4mhWzfhVc876ZR3GEChCM1ESgSFkAsFbPWJm)EYuh7gNMQCoXFqLzBdkeiOe8sG3tdN)rmTSyu)1GcbckbVe490W5Fetllg1F9BGTaAcSxZFjCMd4S6kuUvLT6tO2Yp6lif9Urz1mC(9uyTxIPBD(Ps1gLvZW53tH1EPLfJ6pyQOP5vPkWEbN18ZIfFWuXgLvZW53tH1Ej8G8oTOgGMa718xcN5aoRUcLx(Mp86n0XUtl6lif9Urz1mC(9uyTxIPBD(Ps1gLvZW53tH1EPLfJ6pyQGovPkWEbN18ZIfFWuXgLvZW53tH1Ej8G8oTOgGMa718xcN5aoRUcLXZS26dNT64Uaj70xqk6DJYQz487PWAVet368tLQnkRMHZVNcR9sllg1FWurtZRsvG9coR5Nfl(GPInkRMHZVNcR9s4b5DArnanb2R5VeoZbCwDfk3QYwOAzn1isrFbPacjN1lJnfRbR9sK73aBb0eyVM)s4mhWz1vOSLd3KgBk6UHi9fKIE6DJYQz487PWAVet368tLQnkRMHZVNcR9sllg1FWSVQufyVGZA(zXIpyQyJYQz487PWAVeEqENwuRDvQWMyCxn0Gro9aNxCi0O3f5zOzn4evyOhiTiYxEn)Ly6aPeeylGMa718xcN5aoRUcLXroRdSxZRZ150)HiR49G(Z3c7kAsFbPyrEgAwdo98D1B0k2oN23qqOEdDiieB4ixIPdKsqGTnGgmY1p8yRGkZjrk9EA8CoGMa718xcN5aoRUcLXMIUBiEaAcSxZFjCMd4S6kuMcXXM4Td9fKc74PZ0gcpN1uJivYlC36nA0JD8u9oVFK1uzMT1BKopWD7xnvQSJNotBi8CwtnIuPLfJ6V(nW22b0eyVM)s4mhWz1vOmow4m9fKc74PZ0gcpN1uJivYlC36nA07XUMAEKl5fVQrNA1eWaAcSxZFjCMd4S6kuMcXXM4Td9fKcSPyn4tdTb2R5Jmmvl13g4zY2P1NAvzluTSMAePsqi5SEzSPynyTxImmpboN1ESgSF0A1a0eyVM)s4mhWz1vOmuo(U1BOpFRUm9fKcSjg3vdnyKtpW5fhcaAcSxZFjCMd4S6kughlCM(csbEMSDA9Pwv2cvlRPgrQeesoRxgBkwdw7LidZtGZzThRb7hTwnanb2R5VeoZbCwDfk3QYwOAzn1isrFbPGcbckjgwn1isfRT4nHiaOjWEn)LWzoGZQRq5UvoRXJOy8w6XDWzw7XAW(POj9fKc74jbt8oIZZAQrKk5fUB9gno21uZJCjV4vn6uRMagqtG9A(lHZCaNvxHYDRCwFMgN(csbfceuckhD490IX2nHiaOjWEn)LWzoGZQRqzOC0HT6Z040J7GZS2J1G9trtanb2R5VeoZbCwDfkF8kWVRpVEd6XDWzw7XAW(POj9fKILHw(mfuzUrVEH7wVrJNPRRBvAQrKkbFYHxzUHhRb7jVezTpABXWSzFBanyKtDCCUEzd(HzF6BJa7fCwZplw81VcyeGMa718xcN5aoRUcL7w5SgpIIXBPh3bNzThRb7NIM0xqkWMyCxn0Gro9aNxCi0acjN1lJnfRbR9sK73aBB0ZI8m0SgC657Q3OvSDoTVHGq9g6qqi2WrUethiLGaBBGNjBNwFcAzMwvVH23qiTSyu)1apt2oT(KhR23qiTSyu)PsvVlYZqZAWPNVREJwX250(gcc1BOdbHydh5smDGuccSTDanb2R5VeoZbCwDfk3QYwOAzn1isrFbPOx74Pwv2cvlRPgrQKx4U1B0O3JDn18ixYlEvJo1QjGvPcBkwd(0qBG9A(idZMP(aOjWEn)LWzoGZQRqzkehBI3o0xqk6P3NPRRBvAQrKkDM2q45Skv96rMFp1QYwOAzD9qixnFI)GkZ22BGNjBNwFQvLTq1YAQrKkbHKZ6LXMI1G1EjYW8e4Cw7XAW(rRvdqtG9A(lHZCaNvxHYHwezT8QhinENwhGMa718xcN5aoRUcLpN5S23qG(csb2eJ7QHgmYPh48Idbanb2R5VeoZbCwDfkF8kWVRpVEd6XDWzw7XAW(POj9fKILHw(mfuzUHhz(9KPo2nonv5CI)GkZ2gESgSN8sK1(OTfdt6eqtG9A(lHZCaNvxHY4yHZaAcSxZFjCMd4S6kuUBLZA8ikgVLEChCM1ESgSFkAsFbPaBIXD1qdg50dCEXHqJEwKNHM1GtpFx9gTITZP9neeQ3qhccXgoYLy6aPeeyBd8mz706tqlZ0Q6n0(gcPLfJ6Vg4zY2P1N8y1(gcPLfJ6pvQ6DrEgAwdo98D1B0k2oN23qqOEdDiieB4ixIPdKsqGTTdOjWEn)LWzoGZQRq5UvoRptJdOjWEn)LWzoGZQRq5Jxb(D951BqpUdoZApwd2pfnPVGuSm0YNPGkZaAcSxZFjCMd4S6kuwCEJzowtvotpUdoZApwd2pfnb0eyVM)s4mhWz1vO8gc(S6Z3QltpUdoZApwd2pfnb0aOjWEn)LEpuCoZzTVHaGMa718x69qDfkdTmtRQ3q7BiqFbPOxkeiOuRkB1NqTLFPLfJ6pvQOqGGsTQSvFc1w(LwwmQ)AGNjBNwFQBLZA8ikgVnTSyu)bOjWEn)LEpuxHYESAFdb6lif9sHabLAvzR(eQT8lTSyu)PsffceuQvLT6tO2YV0YIr9xd8mz706tDRCwJhrX4TPLfJ6panaAcSxZFPZvy5WnPXMIUBisFbPaBIXD1qdg50dCEXHqJE6DJYQz487PWAVet368tLQE3OSAgo)EkS2lHi0yJYQz487PWAVKfzdVMx9nkRMHZVNcR9s13FFBxLQnkRMHZVNcR9sicn2OSAgo)EkS2lTSyu)btyK5b0eyVM)sNRUcLpEf431NxVb94o4mR9yny)u0K(csrV2XthVc876ZR3i5fUB9gn8ynyp5LiR9rBlgMMtvQOqGGsWlbEpnC(hXeIqdkeiOe8sG3tdN)rmTSyu)1Vb2cOjWEn)LoxDfkdLJoSvFMghqtG9A(lDU6kuE5B(WR3qh7oTOVGu07gLvZW53tH1EjMU15Nkv9Urz1mC(9uyTxcrOrpBuwndNFpfw7LSiB418QVrz1mC(9uyTxQ((vZ8QuTrz1mC(9uyTxcpiVROz7QuTrz1mC(9uyTxcrOXgLvZW53tH1EPLfJ6pycJmVkvuZDn8sK1(OTf3FtZdOjWEn)LoxDfk3QYw9juB5h9fKIE3OSAgo)EkS2lX0To)uPQ3nkRMHZVNcR9sicn2OSAgo)EkS2lzr2WR5vFJYQz487PWAVu99RM5vPAJYQz487PWAVeIqJnkRMHZVNcR9sllg1FWunZRsf1CxdVezTpABX9RM5b0eyVM)sNRUcLXZS26dNT64Uaj70xqk6DJYQz487PWAVet368tLk8aN)490xgMCnuWnWZKTtRp1QYw9juB5xAzXO(tLQEXdC(J3tFzyY1qb3ONE3OSAgo)EkS2lHi0yJYQz487PWAVKfzdVMx9nkRMHZVNcR9s13FFmVkvBuwndNFpfw7LqeASrz1mC(9uyTxAzXO(dMQzEvQ6DJYQz487PWAVeIq7Qurn31Wlrw7J2wC)9X8aAcSxZFPZvxHYDRCwFMghqtG9A(lDU6kugkhF36n0NVvxM(csb2eJ7QHgmYPh48Idbanb2R5V05QRq5qlISwE1dKgVtRdqtG9A(lDU6kuUvLTq1YAQrKI(csbesoRxgBkwdw7Li3VA0Ib224yxtnpYL8Ix1OtTAcyvQOqGGsIHvtnIuXAlEticQu17XUMAEKl5fVQrNA1eWn6bcjN1lJnfRbR9sK73aBvPcBIXD1qdg50dCEXHqJEEMUUUvPPgrQe8jhEL5g2XthVc876ZR3i5fUB9gnSJNoEf431NxVrAzOLptbvMvP6z666wLMAePscM4DeNNB0lfceusCEJzowdHSDsicn65y3R34sropT0qdg50dCEXHGkvqdg5uhhNRx2G)(HgmYLed6cddSxZN6w5SgpIIXBt44C9Yg8tl9P92vPIAURHxIS2hTT4(BA(2b0eyVM)sNRUcL7w5SgpIIXBPh3bNzThRb7NIM0xqko21uZJCjV4vn6uRMaUHD8KGjEhX5zn1isL8c3TEJg9sHabLedRMAePI1w8Mqea0eyVM)sNRUcLXXcNPVGueyVGZA(zXIpy2SrVlYZqZAWPTto6EEK7Y7PXZdniVTEd95B1LVethiLGaBb0eyVM)sNRUcLPqCSjE7qFbPiWEbN18ZIfFWSzJExKNHM1GtBNC098i3L3tJNhAqEB9g6Z3QlFjMoqkbb22apt2oT(uRkBHQL1uJivccjN1lJnfRbR9sKH5jW5S2J1G9RrpytXAWNgAdSxZhzyQwQVQuzhpDM2q45SMAePsEH7wVr7aAcSxZFPZvxHYNZCw7BiqFbPaBIXD1qdg50dCEXHaGMa718x6C1vOS48gZCSMQCMEChCM1ESgSFkAsFbPWJm)EkYcMcTWY2WNnXFqLzBJEOqGGsIZBmZXAiKTtcrObfceusCEJzowdHSDsllg1F9dnyKJw3d8yRGkZjrk9EA8ComehNRx2G)2PfdSTrVuiqqPwv2QpHAl)sllg1FQurHabLeN3yMJ1qiBN0YIr9xJNPRRBvAQrKkjyI3rCEUDanb2R5V05QRq5UvoRXJOy8w6XDWzw7XAW(POj9fKciKCwVm2uSgS2lrUFdSTb2eJ7QHgmYPh48Idbanb2R5V05QRq5ne8z1NVvxMEChCM1ESgSFkAsFbPGcbck5LGEG0UjwFcCSPZdCxf9rLk74PZ0gcpN1uJivYlC36na0eyVM)sNRUcLfN3yMJ1uLZ0xqkSJNotBi8CwtnIujVWDR3aqtG9A(lDU6ku(4vGFxFE9g0J7GZS2J1G9trt6lifldT8zkOYCdpwd2tEjYAF02IHP5uLkkeiOe8sG3tdN)rmHiaOjWEn)LoxDfk3QYwOAzn1isrFbP4z666wLMAePsNPneEo3aAWihmHhBfuzojsP3tJNZPf1AyhpD8kWVRpVEJ0YIr9hm7lTyGTaAcSxZFPZvxHYytr3nepanb2R5V05QRq5UvoRXJOy8w6XDWzw7XAW(POj9fKcSjg3vdnyKtpW5fhcaAcSxZFPZvxHYTQSfQwwtnIu0xqkwKNHM1GtBNC098i3L3tJNhAqEB9g6Z3QlFjMoqkbb2cOjWEn)LoxDfkloVXmhRPkNPh3bNzThRb7NIM0xqkOqGGsIZBmZXAiKTtcrqLkObJCQhyVMp1TYznEefJ3MWX56Ln4hMqdg5sIbDHHn7Rkv2XtNPneEoRPgrQKx4U1BOsffceuQvLT6tO2YV0YIr9hGMa718x6C1vO8gc(S6Z3QltpUdoZApwd2pfnb0eyVM)sNRUcLBvzluTSMAePOVGu0ZZ011Tkn1isLGp5WRm3WoE64vGFxFE9gjVWDR3qLQNPRRBvAQrKkjyI3rCEwLQNPRRBvAQrKkDM2q45CdObJCWSVMV9g9ESRPMh5sEXRA0PwnbSe9eySew16BFLU0Lsa]] )


end