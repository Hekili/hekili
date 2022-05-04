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

    spec:RegisterCombatLogEvent( function ( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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

        if prev_gcd[1].kill_command and pheromoneReset and ( now - action.kill_command.lastCast < 0.25 ) then
            setCooldown( "kill_command", 0 )
        end

        if now - action.harpoon.lastCast < 1.5 then
            setDistance( 5 )
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
                    gainCharges( "kill_command", 1 )
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
            id = 270323,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,

            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            start = function () end,
            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "pheromone_bomb" )
            end,

            copy = 270329,

            unlisted = true,
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
            id = 270335,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
            start = function () end,
            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "shrapnel_bomb" )
            end,

            copy = 270338,

            unlisted = true,
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
            id = 271045,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,

            start = function ()
            end,

            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "volatile_bomb" )
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
            end,

            copy = 271048,

            unlisted = true,
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

            bind = function () return current_wildfire_bomb end,
            velocity = 35,

            start = function ()
                removeBuff( "flame_infusion" )
            end,

            impact = function ()
                if not talent.wildfire_infusion.enabled and buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
                    removeBuff( "mad_bombardier" )
                end
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

            copy = 259495, -- { 271045, 270335, 270323, 259495 }
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


    spec:RegisterPack( "Survival", 20220502, [[davzYcqisLEKas6sGuXMikFcKWOiuDkIkRsaLxPOywcWTaj1Uq8lrsddKOJjIwMIQNjGQPbsvUgHsBJqbFtaPgNirDobKyDGuvVJqHsnpfLUNaTprk)dKeQdsOqwiiLhkGyIeku5IekuLncscPpcsImsqsiojivQvsQ4LGKOMjijDtcfk2jrv)KqHQAOekuYsbjbpLuMQivFfKkPXksK2RO(ljdgYHPAXe8yKMSqxg1MHQpRiJweoTKvdsL41qPzRWTjYUL63knCbDCcfTCvEoW0PCDqTDO47eY4fjCEsvRxKiMpi2VQoNmNEwl6gNLFouoFoukwOCojzGc0tmKumK1m9HCwl0Py9joR1UeN10GpmfgFK1cD9J1J50ZAGf(OCwlq9rjmlea9tn1PYsalqORuQGscE4wTn9CClvqjrtnRjaxdd6UZczTOBCw(5q585qPyHY5KKbkqpXqsOxwZHTe7L10kPajRLOIrUZczTidOznn4dtHXhpcQiWTX3RJymU(hnpGhnhkNp)151jq2gdF2JWxkm4rlg(OE4JOjykwWJS9rhdczQ9OMf9i6WbGhbyZQEc8OuFemGFuZIEenbtXQWxkmqTy4J6HpItr4XaqTnjRnkGbYPN1cpMUscULtplFYC6znUDHbhZqlRTHznaBfEwJELXx5znZhCBePTN2fWkHYyc3UWGJzTidOxfA12zTazBm8zpcFPWGhTy4J6HpIMGPybpY2hDmiKP2JAw0JOdhaEeGnR6jWJs9rWa(rnl6r0emfRcFPWa1IHpQh(iofHhda12KSgg)uTlXznjb1bu0fyznNA12znm(vUWGZAy8bmR4bGZAo1QTjNhA7Pa2vyzcDbwwdJpG5SMtTABI02t7cyLqzmHUalBz5NNtpR5uR2oRbGLK2wfYwwJBxyWXm0Yww(apNEwZPwTDwtynBWrf(W1ZrrvpPSnfvN142fgCmdTSLLh6LtpR5uR2oRHpyqc654wwJBxyWXm0YwwEXMtpRXTlm4ygAzn6vgFLN1o4MX3BIjGfEGV3eRyjb(aewmHRWqoM1CQvBN1m)u25HzllVyiNEwZPwTDwdympu25HznUDHbhZqlBzlR1MNtplFYC6znNA12znGX8qzNhM142fgCmdTSLLFEo9Sg3UWGJzOL1Oxz8vEwt3hjaJJtevJOcewxzaYXsE1GhbbYJeGXXjIQrubcRRma5yjVAWJK9i6UJ4kQjyRXqrxjjVJKJL8QbznNA12zn8J5us1tk78WSLLpWZPN142fgCmdTSg9kJVYZA6(ibyCCIOAevGW6kdqowYRg8iiqEKamoorunIkqyDLbihl5vdEKShr3DexrnbBngk6kj5DKCSKxniR5uR2oRz(PSZdZw2YArg3Hhwo9S8jZPN142fgCmdTSg9kJVYZAMFtSrwyduroLFKShbyZQEcqGbSkHFH72ps2JeGXXjoiKPMAXvwcwX(0GjXvuN1CQvBN1s4x4UD2YYppNEwZPwTDwtcoLKsgCwJBxyWXm0Yww(apNEwJBxyWXm0YAo1QTZA25TycxJkLu9KcKyTSwKb0RcTA7SguP9rEc2JpY74Js)8wmHRrLs4hjVyScKhXnlvmiGhjIFuCBOWEuCFKLOapcFVhfoC98bEKatDya)OYGI4Je4hz7(iqOljP)rEhFKi(ruVHc7rh7XAO)rPFElMpceY0cVOpsaghhqYA0Rm(kpRP7Jm)MyJuav4W1Zx2YYd9YPN142fgCmdTSMtTA7Sg0L1G7jUUtfzGvTEGI6JrwJELXx5znNAfgwXnlvm4rbFuYhj7rI)ibyCCcD3lwTBCu5aGdpmcC4JGa5r6(i6UJ4kQj0DVy1UXrLdao8Wihl5vdEeeipsybGhj7rwjXkBvXIF0SpkWHYhj3JGa5rI)iNAfgwXnlvm4rP9OKps2JeGXXjhd22TQNu(DRicC4JGa5rcW44e6UxSA34OYbahEye4WhjxwRDjoRbDzn4EIR7urgyvRhOO(yKTS8InNEwZPwTDwdgWQYyjqwJBxyWXm0YwwEXqo9Sg3UWGJzOL1Oxz8vEwJUy42BJGv)vE)izpIU7iUIAcD3lwTBCu5aGdpmYXsE1Ghj7r0DhXvutogSTBvpP87wrKJL8QbpccKhP7JOlgU92iy1FL3ps2JO7oIROMq39Iv7ghvoa4WdJCSKxniR5uR2oRr9Xq5uR2wnkGL1gfWuTlXzn7QglBGSLLpqNtpRXTlm4ygAznNA12znQpgkNA12QrbSS2OaMQDjoRrJGSLLpLZPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJM9rb(JK9iZhCBeH6Ia1IRcpwpHBxyWXSgWUIAz5tM1CQvBN1O(yOCQvBRgfWYAJcyQ2L4SMWgMTS8bk50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rZ(Oa)rYEKUpY8b3grOUiqT4QWJ1t42fgCmRbSROww(KznNA12znQpgkNA12QrbSS2OaMQDjoRbSSLLpjuMtpRXTlm4ygAzn6vgFLN1CQvyyf3SuXGhL2JMN1a2vullFYSMtTA7Sg1hdLtTAB1OawwBuat1UeN1Od2XWzllFYK50ZAo1QTZA(r9Mv2Eh3wwJBxyWXm0Yw2YA0b7y4C6z5tMtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5znZhCBKe6JNducLXeUDHbhFKShjaJJtWuH8buy4ELihl5vdEKShjaJJtWuH8buy4ELihl5vdE0SpAIgZAu90bRm)MydKLpz2YYppNEwJBxyWXm0YA0Rm(kpRP7JoVIkgd3gXJraHtrbmWJGa5rNxrfJHBJ4XiGCSKxn4rPf8rjHYhbbYJCQvyyf3SuXGhLwWhDEfvmgUnIhJacDHB7rb2JMN1CQvBN1evJOcewxzGSLLpWZPN142fgCmdTSg9kJVYZA6(OZROIXWTr8yeq4uuad8iiqE05vuXy42iEmcihl5vdEuAbFuk)iiqEKtTcdR4MLkg8O0c(OZROIXWTr8yeqOlCBpkWE08SMtTA7S2XGTDR6jLF3kkBz5HE50ZAC7cdoMHwwJELXx5znDF05vuXy42iEmciCkkGbEeeip68kQymCBepgbKJL8QbpkTGpkju(iiqEKtTcdR4MLkg8O0c(OZROIXWTr8yeqOlCBpkWE08SMtTA7SgD3lwTBCu5aGdpSSLLxS50ZAC7cdoMHwwJELXx5znC4XqDmnHFtSYkj(rZ(OjA8rqG8ibyCCIKhvcRKGFXIpcCywZPwTDwtunI41XkHvsiBz5fd50ZAC7cdoMHwwJELXx5zn6UJ4kQjIQreVowjSsceAc)MyGc)CQvB7Jhn7JsM1CQvBN1O(HHZww(aDo9Sg3UWGJzOL1Oxz8vEwt8hP7JoVIkgd3gXJraHtrbmWJGa5rNxrfJHBJ4XiGCSKxn4rP9iX(iiqEKtTcdR4MLkg8O0c(OZROIXWTr8yeqOlCBpkWE08hj3JGa5r0emfRcFPWa1IHpQh(izps3hDWnJV3ete8j1IRKG7YQTbewmHRWqoM1CQvBN1ISBju0eo2ZLYww(uoNEwJBxyWXm0YA0Rm(kpRDWnJV3etAgaQEsKF6bk78WWQNuEyOFUbdiSycxHHC8rYEe(sHbpA2hHXVYfgmrsqDafDbwwdyxrTS8jZAo1QTZAuFmuo1QTvJcyzTrbmv7sCwRnpBz5duYPN1CQvBN1OjCSNlbYAC7cdoMHw2YYNekZPN142fgCmdTSg9kJVYZAX1iGeNh28qjSsceROyRE6rYEK4pkUgPAJV2hkHbZXQNiaZPyF0SpA(JGa5rX1iGeNh28qjSscKJL8QbpA2hnrJpsUSMtTA7SMaSrtWN(SLLpzYC6znUDHbhZqlRrVY4R8SwCnciX5HnpucRKaXkk2QNEKShP7JaSPe2ggqSIV5PSAEinR5uR2oRr9ddNTS8jNNtpRXTlm4ygAzn6vgFLN1Oj8BIbk8ZPwTTpEuApAorSps2JO7oIROMiQgr86yLWkjqWHhd1X0e(nXkRK4hL2JaH8yOm)Myd8OuF08SMtTA7SMaSrtWN(SLLpzGNtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBz5tc9YPN142fgCmdTSg9kJVYZAcW44ejpQewjb)IfFe4WSMtTA7SMOAeXRJvcRKq2YYNuS50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrVY4R8SwCnsyc(wPTzLWkjqSIIT6Phj7ra2ucBddiwX38uwnpK(izps3hjaJJtK8OsyLe8lw8rGdZAu90bRm)MydKLpz2YYNumKtpRXTlm4ygAzn6vgFLN1eGXXj4dxpFaLKFyjWHznNA12znS1yOajwlBz5tgOZPN142fgCmdTSMtTA7Sg(W1ZrfiXAznQE6GvMFtSbYYNmBz5tMY50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEw7y8JbjCHb)izps3hzffB1tps2JAofMsuPewjbcMD4wn4hj7rMFtSrSsIv2QIf)O0EusX(izpcFPWGhnZJOoWuhpX9Js7rbUyFKSh5uRWWkUzPIbpA2Gpc6L1O6Pdwz(nXgilFYSLLpzGso9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRrtWuSk8Lcdulg(OE4JK9iC4XqDmnHFtSYkj(rZ(OjA8rYEK4p6GBgFVjM0mau9Ki)0du25HHvpP8Wq)CdgqyXeUcd54JK9i6UJ4kQj4hZPKQNu25HKJL8Qbps2JO7oIROMy(PSZdjhl5vdEeeips3hDWnJV3etAgaQEsKF6bk78WWQNuEyOFUbdiSycxHHC8rYL1O6Pdwz(nXgilFYSLLFouMtpRXTlm4ygAzn6vgFLN109rX1iIQreVowjSsceROyRE6rYEKUpcWMsyByaXk(MNYQ5H0hbbYJOj8BIbk8ZPwTTpEuApkjjWZAo1QTZAIQreVowjSsczll)8K50ZAC7cdoMHwwJELXx5znXFKUpQ5uykrLsyLeiGeNh284rqG8iDFK5dUnIOAeXRJvvJddQTjC7cdo(i5EKShr3DexrnrunI41XkHvsGGdpgQJPj8BIvwjXpkThbc5Xqz(nXg4rP(O5znNA12znbyJMGp9zll)8550ZAC7cdoMHwwJELXx5zn6UJ4kQjIQreVowjSsceC4XqDmnHFtSYkj(rP9iqipgkZVj2apk1hnpR5uR2oRr9ddNTS8Zd8C6znNA12znxjbFr(ulUIERiqwJBxyWXm0Yww(5qVC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6HznNA12znGX8qzNhMTS8ZfBo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1og)yqcxyWps2JmFWTrsOpEoqjugt42fgC8rYEK53eBeRKyLTQyXpkThLYznQE6GvMFtSbYYNmBz5NlgYPN1CQvBN1O(HHZAC7cdoMHw2YYppqNtpRXTlm4ygAznNA12znS1yOORKK3XSg9kJVYZA0emfRcFPWa1IHpQh(izps8hDWnJV3etAgaQEsKF6bk78WWQNuEyOFUbdiSycxHHC8rYEeD3rCf1e8J5us1tk78qYXsE1Ghj7r0DhXvutm)u25HKJL8QbpccKhP7Jo4MX3BIjndavpjYp9aLDEyy1tkpm0p3GbewmHRWqo(i5YAu90bRm)MydKLpz2YYppLZPN1CQvBN1WwJHcKyTSg3UWGJzOLTS8ZduYPN142fgCmdTSMtTA7SgGVqUnfWQEkRrVY4R8S2X4hds4cdoRr1thSY8BInqw(KzllFGdL50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRr1thSY8BInqw(KzllFGNmNEwJBxyWXm0YAo1QTZANhA7Pa2vy5SgvpDWkZVj2az5tMTSL1e2WC6z5tMtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5znbyCCcMkKpGcd3Re5yjVAWJK9iXFKamoobtfYhqHH7vICSKxn4rZ(OjA8rqG8OJXpgKWfg8JKlRr1thSY8BInqw(Kzll)8C6znUDHbhZqlR5uR2oRHTgdfDLK8oM1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rcW44KMbvpjYp9aLDEyy1tkpm0p3Gbe4WhbbYJe)ra2SQNaeFmwrk8Lcdulg(OE4JGa5r4lfg8OzEe1bM64jUF0SpcFPWaIKNIhnZJscLpsUhj7rcW44KMbvpjYp9aLDEyy1tkpm0p3Gbe4Whj7rcW44KMbvpjYp9aLDEyy1tkpm0p3GbKJL8QbpA2hnrJznQE6GvMFtSbYYNmBz5d8C6znNA12znS1yOajwlRXTlm4ygAzllp0lNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OE4JK9iC4XqDmnHFtSYkj(rZ(OjA8rqG8ibyCCIKhvcRKGFXIpcCywZPwTDwtunI41XkHvsiBz5fBo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7Sg(WBSvpPa2vy5SLLxmKtpR5uR2oRHpC9CubsSwwJBxyWXm0Yww(aDo9Sg3UWGJzOL1Oxz8vEw7GBgFVjM0mau9Ki)0du25HHvpP8Wq)CdgqyXeUcd54JK9i8LcdE0SpcJFLlmyIKG6ak6cSSgWUIAz5tM1CQvBN1O(yOCQvBRgfWYAJcyQ2L4SwBE2YYNY50ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZAr2TekAch75szllFGso9Sg3UWGJzOL1CQvBN1op02tbSRWYzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHps2JeGXXj0DVy1UXrLdao8Wihl5vdE0SpkjrSpkWE0enM1O6Pdwz(nXgilFYSLLpjuMtpRXTlm4ygAznNA12znPTN2fWkHY4Sg9kJVYZAcW44e6UxSA34OYbahEye4Whj7rcW44e6UxSA34OYbahEyKJL8QbpA2hLKi2hfypAIgZAu90bRm)MydKLpz2YYNmzo9SMtTA7SMRKGViFQfxrVveiRXTlm4ygAzllFY550ZAC7cdoMHwwZPwTDw78qBpfWUclN1Oxz8vEwtaghNyvOAXvwcwbcz)iaZPyFuWhf4znQE6GvMFtSbYYNmBz5tg450ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SM5dUnIpct4QWJJUThHBxyWXhj7rI)ibyCCI02t7cyfo8PNah(izpsaghNiT90UawHdF6jhl5vdE0SpcFPWGhL6Je)ry8RCHbtKeuhqrxG9iO(ruhyQJN4(rY9Oa7rt04JKlRr1thSY8BInqw(KzllFsOxo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9Whj7r6(iROyRE6rYEK4pchEmuhtt43eRSsIF0SpAIgFeeips3hfxJiQgr86yLWkjqSIIT6Phj7rcW44ePTN2fWkC4tp5yjVAWJs7r4WJH6yAc)MyLvs8JG6hL8rb2JMOXhbbYJ09rX1iIQreVowjSsceROyRE6rYEKUpsaghNiT90UawHdF6jhl5vdEKCpccKhzLeRSvfl(rZ(OKP8JK9iDFuCnIOAeXRJvcRKaXkk2QNYAo1QTZAIQreVowjSsczllFsXMtpRXTlm4ygAznNA12znS1yOORKK3XSgvpDWkZVj2az5tM1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rI)iDF0b3m(EtmPzaO6jr(PhOSZddREs5HH(5gmGWTlm44JGa5r4lfg8OzFeg)kxyWejb1bu0fypsUSwKb0RcTA7Sg0n(J0VWpkUnuypkHJHFK8mau9Ki)0dfGhL(5HHvp9iXOWq)CdgeWJaLu4q)JOoWEeu5AmEuGSssEhFuH)i9l8JeTnuypAXWh1dF02pcQOlfg8i8BLEuCRE6rGL8iOB8hPFHFuCFuchd)i5zaO6jr(Phkapk9ZddRE6rIrHH(5gm4r6x4hbsSWJ4JOoWEeu5AmEuGSssEhFuH)i9l89i8LcdEubEKapwrpYsWpIUa7rl(JeJz7PDb8JGwz8J27rqf8qBVhPzxHLZww(KIHC6znUDHbhZqlR5uR2oRHTgdfDLK8oM1O6Pdwz(nXgilFYSg9kJVYZA0emfRcFPWa1IHpQh(izp6GBgFVjM0mau9Ki)0du25HHvpP8Wq)Cdgq42fgC8rYEeD3rCf1e8J5us1tk78qYXsE1GhL2Je)r4lfg8OuFK4pcJFLlmyIKG6ak6cShb1pI6atD8e3psUhfypAIgFKCps2JO7oIROMy(PSZdjhl5vdEuAps8hHVuyWJs9rI)im(vUWGjscQdOOlWEeu)iQdm1XtC)i5EuG9OjA8rY9izps8hP7JmFWTragZdLDEiHBxyWXhbbYJmFWTragZdLDEiHBxyWXhj7r0DhXvutagZdLDEi5yjVAWJs7rI)i8LcdEuQps8hHXVYfgmrsqDafDb2JG6hrDGPoEI7hj3JcShnrJpsUhjxwlYa6vHwTDwd6AzjEK8mau9Ki)0dfGhL(5HHvp9iXOWq)Cdg8OTh6Feu5AmEuGSssEhFuH)i9l89i78qWJ8JF02pIU7iUI6aE0Aj4tub4hbSn8rWGQNEeu5AmEuGSssEhFuH)i9l89ik8DCBpcFPWGh5slCBpQapI7fEkXJS9rayG5v)ilb)ixAHB7rl(JSsIF0GXThHV3J8w)Jw8hPFHVhzNhcEKTpIUs8JwC8hr3DexrD2YYNmqNtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRbmMhk78WSLLpzkNtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5zT4AeaFHCBkGv9e5y8JbjCHb)izps3hjaJJtO7EXQDJJkhaC4HrGdFeeipY8b3gXhHjCv4Xr32JWTlm44JK9OJXpgKWfg8JK9iDFKamoorA7PDbSch(0tGdZAu90bRm)MydKLpz2YYNmqjNEwZPwTDw7yW2Uv9KYVBfL142fgCmdTSLLFouMtpR5uR2oRjQgrfiSUYaznUDHbhZqlBz5NNmNEwJBxyWXm0YA0Rm(kpRP7JeGXXj0DVy1UXrLdao8WiWHznNA12zn6UxSA34OYbahEyzll)8550ZAC7cdoMHwwJELXx5znbyCCI02t7cyfo8PNah(iiqEe(sHbpAMh5uR2MGTgdfDLK8osOoWuhpX9Js7r4lfgqK8u8iiqEKamooHU7fR2noQCaWHhgbomR5uR2oRjT90UawjugNTS8Zd8C6znUDHbhZqlR5uR2oRDEOTNcyxHLZAu90bRm)MydKLpz2YYph6LtpRXTlm4ygAzn6vgFLN1IRrevJiEDSsyLeihJFmiHlm4SMtTA7SMOAeXRJvcRKq2YYpxS50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwtaghNGPc5dOWW9krGdZAu90bRm)MydKLpz2YwwJgb50ZYNmNEwJBxyWXm0YA0Rm(kpRz(GBJy8jbulUI7jFIL42iC7cdo(izpcFPWGhn7JWxkmGi5PiR5uR2oRLWVWD7SLLFEo9Sg3UWGJzOL1Oxz8vEwtaghNq39Iv7ghvoa4WdJahM1CQvBN1eg7gv4WN(SLLpWZPN142fgCmdTSg9kJVYZAcW44e6UxSA34OYbahEye4WSMtTA7SM3ugyNpuuFmYwwEOxo9Sg3UWGJzOL1Oxz8vEwtaghNq39Iv7ghvoa4WdJahM1CQvBN1WRJfg7gZwwEXMtpR5uR2oRnQPegqbDboojXTL142fgCmdTSLLxmKtpRXTlm4ygAzn6vgFLN1O7oIROMGTgdfDLK8osWHhd1X0e(nXkRK4hL2JMOXSMtTA7SMGpPwCLDffliBz5d050ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcC4JGa5rwjXkBvXIF0SpkzGN1CQvBN1e4dWh2QNYww(uoNEwZPwTDwtcoLKsgCwJBxyWXm0Yww(aLC6znUDHbhZqlRrVY4R8SMWcaps2JWRPeM6yjVAWJM9rZf7JGa5rcW44e6UxSA34OYbahEye4WSMtTA7Sw4A12zllFsOmNEwJBxyWXm0YA0Rm(kpRj(JWxkm4rZ(Oanu(iiqEeD3rCf1e6UxSA34OYbahEyKJL8QbpA2hnrJpsUhj7rI)iWcpeQoscHbg8Gv8bhA12eUDHbhFeeipcSWdHQJem7WTAWkWoWWTr42fgC8rYEKamoobZoCRgScSdmCBK4kQFKCznNA12zn8bdsqph3YAvB8DWHMQWZA0eE38O6jz6cw4Hq1rsimWGhSIp4qR2oBz5tMmNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OE4JK9OdUz89MycyHh47nXkwsGpaHft4kmKJps2Jm)u25HKJL8QbpA2hnrJps2JO7oIROMGp8Jjhl5vdE0SpAIgFKShj(JCQvyyf3SuXGhL2Js(iiqEKtTcdR4MLkg8OGpk5JK9iRKyLTQyXpkThj2hfypAIgFKCznNA12znZpLDEy2YYNCEo9Sg3UWGJzOL1CQvBN1Wh(Xzn6vgFLN1Ojykwf(sHbQfdFup8rYEK5NYopKah(izp6GBgFVjMaw4b(EtSILe4dqyXeUcd54JK9iRKyLTQyXpkThb9EuG9OjAmRnQMv0ywBUyZww(KbEo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuWhL8rYEK53eBeRKyLTQyXpA2hHVuyWJs9rI)im(vUWGjscQdOOlWEeu)iQdm1XtC)i5EuG9OjAmR5uR2oRHTgdfiXAzllFsOxo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuWhL8rYEK53eBeRKyLTQyXpA2hHVuyWJs9rI)im(vUWGjscQdOOlWEeu)iQdm1XtC)i5EuG9OjAmR5uR2oRjT90UawjugNTS8jfBo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuWhL8rYEK53eBeRKyLTQyXpA2hHVuyWJs9rI)im(vUWGjscQdOOlWEeu)iQdm1XtC)i5EuG9OjAmR5uR2oRDEOTNcyxHLZww(KIHC6znUDHbhZqlRrVY4R8SM53eBKybmVP8Jsl4JedznNA12znheYutT4klbRyFAWzlBznGLtplFYC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6Hps2Je)r6(OZROIXWTr8yeq4uuad8iiqEKUp68kQymCBepgbe4Whj7rNxrfJHBJ4XiGeHp3QTF0mp68kQymCBepgbKQF0SpsSpsUhbbYJoVIkgd3gXJrabo8rYE05vuXy42iEmcihl5vdEuApc6bLznNA12zTi7wcfnHJ9CPSLLFEo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN109rX1ia(c52uaR6jIvuSvp9izpY8BInIvsSYwvS4hL2Jc0ps2Je)r6(O4AKWe8TsBZkHvsGyffB1tpccKhjaJJtK8OsyLe8lw8rGdFKSh1CkmLOsjSscKWe8TsBZpsUhbbYJeGXXjyQq(akmCVse4Whj7rcW44emviFafgUxjYXsE1Ghn7JMOXhbbYJ09ra2ucBddiwX38uwnpK(izps3hfxJa4lKBtbSQNiwrXw90JK9iZVj2iwjXkBvXIFuApkqN1O6Pdwz(nXgilFYSLLpWZPN1CQvBN1WhUEoQajwlRXTlm4ygAzllp0lNEwJBxyWXm0YA0Rm(kpRP7JoVIkgd3gXJraHtrbmWJGa5r6(OZROIXWTr8yeqGdFKShj(JoVIkgd3gXJrajcFUvB)OzE05vuXy42iEmciv)OzF0CO8rqG8OZROIXWTr8yeqOlCBpk4Js(i5Eeeip68kQymCBepgbe4Whj7rNxrfJHBJ4XiGCSKxn4rP9iOhu(iiqEKWcaps2JSsIv2QIf)OzFusOmR5uR2oRDmyB3QEs53TIYwwEXMtpRXTlm4ygAzn6vgFLN109rNxrfJHBJ4XiGWPOag4rqG8iDF05vuXy42iEmciWHps2JoVIkgd3gXJrajcFUvB)OzE05vuXy42iEmciv)OzF0CO8rqG8OZROIXWTr8yeqGdFKShDEfvmgUnIhJaYXsE1GhL2JMdLpccKhjSaWJK9iRKyLTQyXpA2hnhkZAo1QTZAIQrubcRRmq2YYlgYPN142fgCmdTSg9kJVYZA6(OZROIXWTr8yeq4uuad8iiqEeDXWT3gPRPeMc35hj7r0DhXvutevJOcewxzaYXsE1GhbbYJ09r0fd3EBKUMsykCNFKShj(J09rNxrfJHBJ4XiGah(izp68kQymCBepgbKi85wT9JM5rNxrfJHBJ4XiGu9JM9rbou(iiqE05vuXy42iEmciWHps2JoVIkgd3gXJra5yjVAWJs7rZHYhbbYJ09rNxrfJHBJ4XiGah(i5EeeipsybGhj7rwjXkBvXIF0SpkWHYSMtTA7SgD3lwTBCu5aGdpSSLLpqNtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBz5t5C6znNA12znxjbFr(ulUIERiqwJBxyWXm0Yww(aLC6znUDHbhZqlRrVY4R8Sgo8yOoMMWVjwzLe)OzF08hfypAIgFKShbytjSnmGyfFZtz18q6JGa5rcW44ejpQewjb)IfFe4WhbbYJ09ra2ucBddiwX38uwnpK(izps8hHdpgQJPj8BIvwjXpA2hnrJpccKhrtWuSk8Lcdulg(OE4JK9iXFuZPWuIkLWkjqWSd3Qb)izpkUgbWxi3McyvprSIIT6Phj7rX1ia(c52uaR6jYX4hds4cd(rqG8OMtHPevkHvsGeMGVvAB(rYEKUpsaghNiT90UawHdF6jWHps2Je)ra2SQNaeFmwrk8Lcdulg(OE4JGa5r4lfg8OzEe1bM64jUF0SpcFPWaIKNIhb1pYPwTnbBngk6kj5DKqDGPoEI7hfypkWFKCpsUhbbYJewa4rYEKvsSYwvS4hn7JscLpsUSMtTA7SMOAeXRJvcRKq2YYNekZPN142fgCmdTSMtTA7Sg2Amu0vsY7ywJELXx5znaBkHTHbeR4BEkRMhsFKShfxJeMGVvABwjSsceROyRE6rYEKUpsaghNi5rLWkj4xS4JahM1O6Pdwz(nXgilFYSLLpzYC6znNA12znS1yOajwlRXTlm4ygAzllFY550ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rP9OKps2J09rhCZ47nXKt)WXcmFGLpGIUn(c3XQNua7kSmGWIjCfgYXSMtTA7Sg1pmC2YYNmWZPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJs7rjFKShP7Jo4MX3BIjN(HJfy(alFafDB8fUJvpPa2vyzaHft4kmKJps2JO7oIROMiQgr86yLWkjqWHhd1X0e(nXkRK4hL2JaH8yOm)Myd8izps8hrt43edu4NtTABF8O0E0CIyFeeipkUgbK48WMhkHvsGyffB1tpsUSMtTA7SMaSrtWN(SLLpj0lNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OEywZPwTDwdympu25HzllFsXMtpRXTlm4ygAznNA12znPTN2fWkHY4Sg9kJVYZAMp42i(imHRcpo62EeUDHbhFKShj(JeGXXjsBpTlGv4WNEcC4JK9ibyCCI02t7cyfo8PNCSKxn4rZ(i8LcdEuQps8hHXVYfgmrsqDafDb2JG6hrDGPoEI7hj3JcShnrJps2J09rcW44er1iQaH1vgGCSKxn4rqG8ibyCCI02t7cyfo8PNCSKxn4rYEuZPWuIkLWkjqctW3kTn)i5YAu90bRm)MydKLpz2YYNumKtpRXTlm4ygAznNA12znS1yOORKK3XSg9kJVYZA4WJH6yAc)MyLvs8JM9rt04JK9iAcMIvHVuyGAXWh1dZAu90bRm)MydKLpz2YYNmqNtpRXTlm4ygAznNA12zTZdT9ua7kSCwJELXx5znbyCCIvHQfxzjyfiK9JamNI9rbFuG)iiqEuCnciX5HnpucRKaXkk2QNYAu90bRm)MydKLpz2YYNmLZPN142fgCmdTSg9kJVYZAX1iGeNh28qjSsceROyREkR5uR2oRjT90UawjugNTS8jduYPN142fgCmdTSMtTA7SgGVqUnfWQEkRrVY4R8S2X4hds4cd(rYEK53eBeRKyLTQyXpkThfOFeeipsaghNGPc5dOWW9krGdZAu90bRm)MydKLpz2YYphkZPN142fgCmdTSg9kJVYZAnNctjQucRKabK48WMhps2JWxkm4rP9im(vUWGjscQdOOlWEuG9O5ps2JIRra8fYTPaw1tKJL8QbpkThj2hfypAIgFKShP7JaSPe2ggqSIV5PSAEinR5uR2oRjQgr86yLWkjKTS8ZtMtpR5uR2oRrt4ypxcK142fgCmdTSLLF(8C6znUDHbhZqlR5uR2oRHTgdfDLK8oM1Oxz8vEwJMGPyv4lfgOwm8r9WSgvpDWkZVj2az5tMTS8Zd8C6znUDHbhZqlRrVY4R8S2b3m(Etm50pCSaZhy5dOOBJVWDS6jfWUcldiSycxHHCmR5uR2oRjQgr86yLWkjKTS8ZHE50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SMamoorA7PDbSch(0tGdFeeipcFPWGhnZJCQvBtWwJHIUssEhjuhyQJN4(rP9i8LcdisEkEeu)OKI9rqG8O4AeqIZdBEOewjbIvuSvp9iiqEKamoorunIkqyDLbihl5vdYAu90bRm)MydKLpz2YYpxS50ZAC7cdoMHwwZPwTDw78qBpfWUclN1O6Pdwz(nXgilFYSLLFUyiNEwJBxyWXm0YA0Rm(kpRj(JAofMsuPewjbcMD4wn4hj7rX1ia(c52uaR6jIvuSvp9iiqEuZPWuIkLWkjqctW3kTn)iiqEuZPWuIkLWkjqajopS5XJK9i8LcdEuApsSq5JK7rYEKUpcWMsyByaXk(MNYQ5H0SMtTA7SMOAeXRJvcRKq2YwwZUQXYgiNEw(K50ZAC7cdoMHwwBdZAa2YAo1QTZAy8RCHbN1W4dyoRjaJJtogSTBvpP87wre4WhbbYJeGXXj0DVy1UXrLdao8WiWHznm(PAxIZAa9nvbhMTS8ZZPN142fgCmdTS2gM1aSL1CQvBN1W4x5cdoRHXhWCwJUy42BJGv)vE)izpsaghNCmyB3QEs53TIiWHps2JeGXXj0DVy1UXrLdao8WiWHpccKhP7JOlgU92iy1FL3ps2JeGXXj0DVy1UXrLdao8WiWHznm(PAxIZAa72Esb03ufCy2YYh450ZAC7cdoMHwwBdZAa2k8SMtTA7Sgg)kxyWznm(PAxIZAa72Esb03u1XsE1GSg9kJVYZAcW44e6UxSA34OYbahEyK4kQZAy8bmR4bGZA0DhXvutO7EXQDJJkhaC4HrowYRgOMGzaiRHXhWCwJU7iUIAYXGTDR6jLF3kICSKxn4rZcv8JO7oIROMq39Iv7ghvoa4WdJCSKxnqnbZaq2YYd9YPN142fgCmdTS2gM1aSv4znNA12znm(vUWGZAy8t1UeN1a2T9KcOVPQJL8Qbzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHznm(aMv8aWzn6UJ4kQj0DVy1UXrLdao8Wihl5vdutWmaK1W4dyoRr3Dexrn5yW2Uv9KYVBfrowYRgKTS8InNEwJBxyWXm0YABywdWwHN1CQvBN1W4x5cdoRHXpv7sCwdOVPQJL8Qbzn6vgFLN1OlgU92iy1FL3znm(aMv8aWzn6UJ4kQj0DVy1UXrLdao8Wihl5vdutWmaK1W4dyoRr3Dexrn5yW2Uv9KYVBfrowYRg8O0Gk(r0DhXvutO7EXQDJJkhaC4HrowYRgOMGzaiBz5fd50ZAC7cdoMHwwZPwTDwZUQXYwYSg9kJVYZAI)iXFKDvJLnILKKWbkyaReGXXFeeipIUy42BJGv)vE)izpYUQXYgXsss4afD3rCf1psUhj7rI)im(vUWGja72Esb03ufC4JK9iXFKUpIUy42BJGv)vE)izps3hzx1yzJyZjjCGcgWkbyC8hbbYJOlgU92iy1FL3ps2J09r2vnw2i2CschOO7oIRO(rqG8i7QglBeBoHU7iUIAYXsE1GhbbYJSRASSrSKKeoqbdyLamo(JK9iXFKUpYUQXYgXMts4afmGvcW44pccKhzx1yzJyjj0DhXvutIWNB12pkTGpYUQXYgXMtO7oIROMeHp3QTFKCpccKhzx1yzJyjjjCGIU7iUI6hj7r6(i7QglBeBojHduWawjaJJ)izpYUQXYgXssO7oIROMeHp3QTFuAbFKDvJLnInNq3DexrnjcFUvB)i5Eeeips3hHXVYfgmby32tkG(MQGdFKShj(J09r2vnw2i2CschOGbSsagh)rYEK4pYUQXYgXssO7oIROMeHp3QTFeu)iX(OzFeg)kxyWeG(MQowYRg8iiqEeg)kxyWeG(MQowYRg8O0EKDvJLnILKq3DexrnjcFUvB)OuF08hj3JGa5r2vnw2i2CschOGbSsagh)rYEK4pYUQXYgXsss4afmGvcW44ps2JSRASSrSKe6UJ4kQjr4ZTA7hLwWhzx1yzJyZj0DhXvutIWNB12ps2Je)r2vnw2iwscD3rCf1Ki85wT9JG6hj2hn7JW4x5cdMa03u1XsE1GhbbYJW4x5cdMa03u1XsE1GhL2JSRASSrSKe6UJ4kQjr4ZTA7hL6JM)i5Eeeips8hP7JSRASSrSKKeoqbdyLamo(JGa5r2vnw2i2CcD3rCf1Ki85wT9Jsl4JSRASSrSKe6UJ4kQjr4ZTA7hj3JK9iXFKDvJLnInNq3Dexrn5ypQ)rYEKDvJLnInNq3DexrnjcFUvB)iO(rI9rP9im(vUWGja9nvDSKxn4rYEeg)kxyWeG(MQowYRg8OzFKDvJLnInNq3DexrnjcFUvB)OuF08hbbYJ09r2vnw2i2CcD3rCf1KJ9O(hj7rI)i7QglBeBoHU7iUIAYXsE1Ghb1psSpA2hHXVYfgmby32tkG(MQowYRg8izpcJFLlmycWUTNua9nvDSKxn4rP9O5q5JK9iXFKDvJLnILKq3DexrnjcFUvB)iO(rI9rZ(im(vUWGja9nvDSKxn4rqG8i7QglBeBoHU7iUIAYXsE1Ghb1psSpA2hHXVYfgmbOVPQJL8Qbps2JSRASSrS5e6UJ4kQjr4ZTA7hb1pkju(OzEeg)kxyWeG(MQowYRg8OzFeg)kxyWeGDBpPa6BQ6yjVAWJGa5ry8RCHbta6BQ6yjVAWJs7r2vnw2iwscD3rCf1Ki85wT9Js9rZFeeipcJFLlmycqFtvWHpsUhbbYJSRASSrS5e6UJ4kQjhl5vdEeu)iX(O0Eeg)kxyWeGDBpPa6BQ6yjVAWJK9iXFKDvJLnILKq3DexrnjcFUvB)iO(rI9rZ(im(vUWGja72Esb03u1XsE1GhbbYJSRASSrSKe6UJ4kQjr4ZTA7hn7JWRPeM6yjVAWJK9im(vUWGja72Esb03u1XsE1GhnZJSRASSrSKe6UJ4kQjr4ZTA7hL2JWRPeM6yjVAWJGa5r6(i7QglBeljjHduWawjaJJ)izps8hHXVYfgmbOVPQJL8QbpkThzx1yzJyjj0DhXvutIWNB12pk1hn)rqG8im(vUWGja9nvbh(i5EKCpsUhj3JK7rY9iiqEK53eBeRKyLTQyXpA2hHXVYfgmbOVPQJL8QbpsUhbbYJ09r2vnw2iwsschOGbSsagh)rYEKUpIUy42BJGv)vE)izps8hzx1yzJyZjjCGcgWkbyC8hj7rI)iXFKUpcJFLlmycqFtvWHpccKhzx1yzJyZj0DhXvutowYRg8O0EKyFKCps2Je)ry8RCHbta6BQ6yjVAWJs7rZHYhbbYJSRASSrS5e6UJ4kQjhl5vdEeu)iX(O0Eeg)kxyWeG(MQowYRg8i5EKCpccKhP7JSRASSrS5KeoqbdyLamo(JK9iXFKUpYUQXYgXMts4afD3rCf1pccKhzx1yzJyZj0DhXvutowYRg8iiqEKDvJLnInNq3DexrnjcFUvB)O0c(i7QglBeljHU7iUIAse(CR2(rY9i5EKCps2Je)r6(i7QglBeljPaeQttWQfx5uXeUooQSJDa8XGhbbYJCQvyyf3SuXGhn7JM)izpsaghN4uXeUooQe5DKah(iiqEKtTcdR4MLkg8O0EuYhj7r6(ibyCCItft464OsK3rcC4JKlRbgRbYA2vnw2sMTS8b6C6znUDHbhZqlR5uR2oRzx1yzBEwJELXx5znXFK4pYUQXYgXMts4afmGvcW44pccKhrxmC7TrWQ)kVFKShzx1yzJyZjjCGIU7iUI6hj3JK9iXFeg)kxyWeGDBpPa6BQco8rYEK4ps3hrxmC7TrWQ)kVFKShP7JSRASSrSKKeoqbdyLamo(JGa5r0fd3EBeS6VY7hj7r6(i7QglBeljjHdu0DhXvu)iiqEKDvJLnILKq3Dexrn5yjVAWJGa5r2vnw2i2CschOGbSsagh)rYEK4ps3hzx1yzJyjjjCGcgWkbyC8hbbYJSRASSrS5e6UJ4kQjr4ZTA7hLwWhzx1yzJyjj0DhXvutIWNB12psUhbbYJSRASSrS5Keoqr3Dexr9JK9iDFKDvJLnILKKWbkyaReGXXFKShzx1yzJyZj0DhXvutIWNB12pkTGpYUQXYgXssO7oIROMeHp3QTFKCpccKhP7JW4x5cdMaSB7jfqFtvWHps2Je)r6(i7QglBeljjHduWawjaJJ)izps8hzx1yzJyZj0DhXvutIWNB12pcQFKyF0SpcJFLlmycqFtvhl5vdEeeipcJFLlmycqFtvhl5vdEuApYUQXYgXMtO7oIROMeHp3QTFuQpA(JK7rqG8i7QglBeljjHduWawjaJJ)izps8hzx1yzJyZjjCGcgWkbyC8hj7r2vnw2i2CcD3rCf1Ki85wT9Jsl4JSRASSrSKe6UJ4kQjr4ZTA7hj7rI)i7QglBeBoHU7iUIAse(CR2(rq9Je7JM9ry8RCHbta6BQ6yjVAWJGa5ry8RCHbta6BQ6yjVAWJs7r2vnw2i2CcD3rCf1Ki85wT9Js9rZFKCpccKhj(J09r2vnw2i2CschOGbSsagh)rqG8i7QglBeljHU7iUIAse(CR2(rPf8r2vnw2i2CcD3rCf1Ki85wT9JK7rYEK4pYUQXYgXssO7oIROMCSh1)izpYUQXYgXssO7oIROMeHp3QTFeu)iX(O0Eeg)kxyWeG(MQowYRg8izpcJFLlmycqFtvhl5vdE0SpYUQXYgXssO7oIROMeHp3QTFuQpA(JGa5r6(i7QglBeljHU7iUIAYXEu)JK9iXFKDvJLnILKq3Dexrn5yjVAWJG6hj2hn7JW4x5cdMaSB7jfqFtvhl5vdEKShHXVYfgmby32tkG(MQowYRg8O0E0CO8rYEK4pYUQXYgXMtO7oIROMeHp3QTFeu)iX(OzFeg)kxyWeG(MQowYRg8iiqEKDvJLnILKq3Dexrn5yjVAWJG6hj2hn7JW4x5cdMa03u1XsE1Ghj7r2vnw2iwscD3rCf1Ki85wT9JG6hLekF0mpcJFLlmycqFtvhl5vdE0SpcJFLlmycWUTNua9nvDSKxn4rqG8im(vUWGja9nvDSKxn4rP9i7QglBeBoHU7iUIAse(CR2(rP(O5pccKhHXVYfgmbOVPk4Whj3JGa5r2vnw2iwscD3rCf1KJL8QbpcQFKyFuApcJFLlmycWUTNua9nvDSKxn4rYEK4pYUQXYgXMtO7oIROMeHp3QTFeu)iX(OzFeg)kxyWeGDBpPa6BQ6yjVAWJGa5r2vnw2i2CcD3rCf1Ki85wT9JM9r41uctDSKxn4rYEeg)kxyWeGDBpPa6BQ6yjVAWJM5r2vnw2i2CcD3rCf1Ki85wT9Js7r41uctDSKxn4rqG8iDFKDvJLnInNKWbkyaReGXXFKShj(JW4x5cdMa03u1XsE1GhL2JSRASSrS5e6UJ4kQjr4ZTA7hL6JM)iiqEeg)kxyWeG(MQGdFKCpsUhj3JK7rY9i5EeeipY8BInIvsSYwvS4hn7JW4x5cdMa03u1XsE1Ghj3JGa5r6(i7QglBeBojHduWawjaJJ)izps3hrxmC7TrWQ)kVFKShj(JSRASSrSKKeoqbdyLamo(JK9iXFK4ps3hHXVYfgmbOVPk4WhbbYJSRASSrSKe6UJ4kQjhl5vdEuApsSpsUhj7rI)im(vUWGja9nvDSKxn4rP9O5q5JGa5r2vnw2iwscD3rCf1KJL8QbpcQFKyFuApcJFLlmycqFtvhl5vdEKCpsUhbbYJ09r2vnw2iwsschOGbSsagh)rYEK4ps3hzx1yzJyjjjCGIU7iUI6hbbYJSRASSrSKe6UJ4kQjhl5vdEeeipYUQXYgXssO7oIROMeHp3QTFuAbFKDvJLnInNq3DexrnjcFUvB)i5EKCpsUhj7rI)iDFKDvJLnInNuac1Pjy1IRCQycxhhv2Xoa(yWJGa5ro1kmSIBwQyWJM9rZFKShjaJJtCQycxhhvI8osGdFeeipYPwHHvCZsfdEuApk5JK9iDFKamooXPIjCDCujY7ibo8rYL1aJ1azn7QglBZZww(uoNEwJBxyWXm0YATlXznOlRb3tCDNkYaRA9af1hJSMtTA7Sg0L1G7jUUtfzGvTEGI6Jr2Yw2YAy4duBNLFouoFouc9MNYznr(1vpbYAqxfJGkip0T8qLG(p6rPNGFujfUN9i89Eeuyx1yzdafp6yXeUoo(iWkXpYHTvYno(iAcVNya51bQwn)iXa0)rbY2y4Z44J0kPa5ra9T5P4rqNhz7JGQW(JIfMcuB)OnKp327rINQCpsCXMc5iVoq1Q5hjgG(pkq2gdFghFeuyx1yzJKKKsHIhz7JGc7QglBeljjLcfps85qVuih51bQwn)iXa0)rbY2y4Z44JGc7QglBK5Kuku8iBFeuyx1yzJyZjPuO4rIpxmKc5iVoq1Q5hfOH(pkq2gdFghFKwjfipcOVnpfpc68iBFeuf2FuSWuGA7hTH852Eps8uL7rIl2uih51bQwn)Oan0)rbY2y4Z44JGc7QglBKKKuku8iBFeuyx1yzJyjjPuO4rIpxmKc5iVoq1Q5hfOH(pkq2gdFghFeuyx1yzJmNKsHIhz7JGc7QglBeBojLcfps85qVuih5151b6Qyeub5HULhQe0)rpk9e8JkPW9ShHV3JGIWJPRKGBqXJowmHRJJpcSs8JCyBLCJJpIMW7jgqEDGQvZpkj0)rbY2y4Z44JGcZhCBKuku8iBFeuy(GBJKsjC7cdocfpYThjgpX4dvFK4jtHCKxNxhORIrqfKh6wEOsq)h9O0tWpQKc3ZEe(Epckagu8OJft4644JaRe)ih2wj344JOj8EIbKxhOA18JskwO)JcKTXWNXXhPvsbYJa6BZtXJGopY2hbvH9hflmfO2(rBiFUT3Jepv5EK4jtHCKxNxhORIrqfKh6wEOsq)h9O0tWpQKc3ZEe(EpckOrau8OJft4644JaRe)ih2wj344JOj8EIbKxhOA18JscLq)hfiBJHpJJpckal8qO6ijLcfpY2hbfGfEiuDKKsjC7cdocfps85PqoYRduTA(rjdCO)JcKTXWNXXhPvsbYJa6BZtXJGopY2hbvH9hflmfO2(rBiFUT3Jepv5EK4jtHCKxhOA18Jsc9G(pkq2gdFghFKwjfipcOVnpfpc68iBFeuf2FuSWuGA7hTH852Eps8uL7rINmfYrEDGQvZpkPyH(pkq2gdFghFKwjfipcOVnpfpc68iBFeuf2FuSWuGA7hTH852Eps8uL7rINmfYrEDEDGUkgbvqEOB5Hkb9F0Jspb)OskCp7r479iOqydHIhDSycxhhFeyL4h5W2k5ghFenH3tmG86avRMFuYah6)OazBm8zC8rALuG8iG(28u8iOZJS9rqvy)rXctbQTF0gYNB79iXtvUhjEYuih51bQwn)OKIf6)OazBm8zC8rqXb3m(EtmjLcfpY2hbfhCZ47nXKukHBxyWrO4rINmfYrEDGQvZpkPya6)OazBm8zC8rALuG8iG(28u8iOZJS9rqvy)rXctbQTF0gYNB79iXtvUhjEGNc5iVoq1Q5hLuma9FuGSng(mo(iOW8b3gjLcfpY2hbfMp42iPuc3UWGJqXJeFEkKJ86avRMFusXa0)rbY2y4Z44JGIdUz89MyskfkEKTpcko4MX3BIjPuc3UWGJqXJepzkKJ86avRMFuYug6)OazBm8zC8rqH5dUnskfkEKTpckmFWTrsPeUDHbhHIhjEYuih5151b6Qyeub5HULhQe0)rpk9e8JkPW9ShHV3JGc6GDmmu8OJft4644JaRe)ih2wj344JOj8EIbKxhOA18Jsoh6)OazBm8zC8rALuG8iG(28u8iOZJS9rqvy)rXctbQTF0gYNB79iXtvUhjEYuih51bQwn)O5jH(pkq2gdFghFKwjfipcOVnpfpc68iBFeuf2FuSWuGA7hTH852Eps8uL7rINmfYrEDGQvZpA(CO)JcKTXWNXXhPvsbYJa6BZtXJGopY2hbvH9hflmfO2(rBiFUT3Jepv5EK4jtHCKxNxhOBPW9mo(Ou(ro1QTF0OagG86K1cVfVgCwlq9rAWhMcJpEeurGBJVxNa1hjgJR)rZd4rZHY5ZFDEDcuFuGSng(ShHVuyWJwm8r9WhrtWuSGhz7JogeYu7rnl6r0HdapcWMv9e4rP(iya)OMf9iAcMIvHVuyGAXWh1dFeNIWJbGABYRZRJtTABaj8y6kj42mbtfJFLlm4aAxIdkjOoGIUalGnmiGTcpam(aMd6uR2MiT90UawjugtOlWcaJpGzfpaCqNA12KZdT9ua7kSmHUala62XYQTdA(GBJiT90Uawjug)64uR2gqcpMUscUntWubWssBRcz71XPwTnGeEmDLeCBMGPkSMn4OcF465OOQNu2MIQFDCQvBdiHhtxjb3MjyQ4dgKGEoU964uR2gqcpMUscUntWun)u25Hbu4bp4MX3BIjGfEGV3eRyjb(aewmHRWqo(64uR2gqcpMUscUntWubgZdLDE4RZRJtTABqWe(fUBhqHh08BInYcBGkYPSmaBw1tacmGvj8lC3wMamooXbHm1ulUYsWk2NgmjUI6xhNA12GzcMQeCkjLm4xNa1hbvAFKNG94J8o(O0pVft4AuPe(rYlgRa5rCZsfdeJ9JeXpkUnuypkUpYsuGhHV3JchUE(apsGPomGFuzqr8rc8JSDFei0LK0)iVJpse)iQ3qH9OJ9yn0)O0pVfZhbczAHx0hjaJJdiVoo1QTbZemv78wmHRrLsQEsbsSwafEqDn)MyJuav4W1Z3RJtTABWmbtfgWQYyPaAxIdcDzn4EIR7urgyvRhOO(yeqHh0PwHHvCZsfdcMuM4cW44e6UxSA34OYbahEye4qiq0LU7iUIAcD3lwTBCu5aGdpmYXsE1aiqewaqMvsSYwvS4zdCOuoiqe3PwHHvCZsfdslPmbyCCYXGTDR6jLF3kIahcbIamooHU7fR2noQCaWHhgbouUxhNA12GzcMkmGvLXsGxNa1a1hjghpC9pc3Pvp9i9l89O4clypcUTA8i9l8Js4y4hfcBpcQad22TQNEKy0DROhfxrDapAVhv4pYsWpIU7iUI6hvGhz7(OX2tpY2hf5HR)r4oT6PhPFHVhjg3clyKhbDJ)OEB(rl(JSemGFeD7yz12Gh5h)ixyWpY2hjX2JevwIQFKLGFusO8raMUDe8ObZIC9b8ilb)iqj9iCNYGhPFHVhjg3clypYHTvYTI6JHEYRtGAG6JCQvBdMjyQnlcFH7O6yWoWWbu4bbl8qO6iPzr4lChvhd2bgwM4cW44KJbB7w1tk)Uveboece6UJ4kQjhd22TQNu(DRiYXsE1G0scLqGy(nXgXkjwzRkw8SjfdY964uR2gmtWuP(yOCQvBRgfWcODjoODvJLnqafEq6IHBVncw9x5Tm6UJ4kQj0DVy1UXrLdao8Wihl5vdKr3Dexrn5yW2Uv9KYVBfrowYRgabIU0fd3EBeS6VYBz0DhXvutO7EXQDJJkhaC4HrowYRg864uR2gmtWuP(yOCQvBRgfWcODjoincEDCQvBdMjyQuFmuo1QTvJcyb0UehuyddayxrTGjdOWd6uRWWkUzPIbZg4YmFWTreQlculUk8y9eUDHbhFDCQvBdMjyQuFmuo1QTvJcyb0UeheybaSROwWKbu4bDQvyyf3SuXGzdCz6A(GBJiuxeOwCv4X6jC7cdo(64uR2gmtWuP(yOCQvBRgfWcODjoiDWogoaGDf1cMmGcpOtTcdR4MLkgK28xhNA12GzcMQFuVzLT3XT96864uR2gqe2WGa(c52uaR6PaO6Pdwz(nXgiyYak8GcW44emviFafgUxjYXsE1azIlaJJtWuH8buy4ELihl5vdMDIgHa5y8JbjCHbl3RJtTABarydNjyQyRXqrxjjVJbq1thSY8BInqWKbu4bPjykwf(sHbQfdFupuMamooPzq1tI8tpqzNhgw9KYdd9ZnyaboeceXbSzvpbi(ySIu4lfgOwm8r9qiqWxkmygQdm1XtCpl(sHbejpfZKekLtMamooPzq1tI8tpqzNhgw9KYdd9ZnyabouMamooPzq1tI8tpqzNhgw9KYdd9Znya5yjVAWSt04RJtTABarydNjyQyRXqbsS2RJtTABarydNjyQIQreVowjSscbu4bPjykwf(sHbQfdFupugo8yOoMMWVjwzLep7encbIamoorYJkHvsWVyXhbo81XPwTnGiSHZemv8H3yREsbSRWYbu4bPjykwf(sHbQfdFup81XPwTnGiSHZemv8HRNJkqI1EDCQvBdicB4mbtL6JHYPwTTAualG2L4GT5baSROwWKbu4bp4MX3BIjndavpjYp9aLDEyy1tkpm0p3GbewmHRWqokdFPWGzX4x5cdMijOoGIUa71XPwTnGiSHZem1i7wcfnHJ9CPak8G0emfRcFPWa1IHpQh(64uR2gqe2WzcM65H2EkGDfwoaQE6GvMFtSbcMmGcpOamooHU7fR2noQCaWHhgbouMamooHU7fR2noQCaWHhg5yjVAWSjjInWMOXxhNA12aIWgotWuL2EAxaRekJdGQNoyL53eBGGjdOWdkaJJtO7EXQDJJkhaC4HrGdLjaJJtO7EXQDJJkhaC4HrowYRgmBsIydSjA81XPwTnGiSHZemvxjbFr(ulUIERiWRJtTABarydNjyQNhA7Pa2vy5aO6Pdwz(nXgiyYak8GcW44eRcvlUYsWkqi7hbyofBWa)1XPwTnGiSHZemvPTN2fWkHY4aO6Pdwz(nXgiyYak8GMp42i(imHRcpo62EeUDHbhLjUamoorA7PDbSch(0tGdLjaJJtK2EAxaRWHp9KJL8QbZIVuya0rCm(vUWGjscQdOOlWGAQdm1XtClxGnrJY964uR2gqe2WzcMQOAeXRJvcRKqafEqAcMIvHVuyGAXWh1dLPRvuSvpjtCC4XqDmnHFtSYkjE2jAeceDJRrevJiEDSsyLeiwrXw9KmbyCCI02t7cyfo8PNCSKxninC4XqDmnHFtSYkjgQtgyt0iei6gxJiQgr86yLWkjqSIIT6jz6kaJJtK2EAxaRWHp9KJL8QbYbbIvsSYwvS4ztMYY0nUgrunI41XkHvsGyffB1tVobQpc6g)r6x4hf3gkShLWXWpsEgaQEsKF6HcWJs)8WWQNEKyuyOFUbdc4rGskCO)ruhypcQCngpkqwjjVJpQWFK(f(rI2gkShTy4J6HpA7hbv0LcdEe(TspkUvp9iWsEe0n(J0VWpkUpkHJHFK8mau9Ki)0dfGhL(5HHvp9iXOWq)Cdg8i9l8Jajw4r8ruhypcQCngpkqwjjVJpQWFK(f(Ee(sHbpQapsGhROhzj4hrxG9Of)rIXS90Ua(rqRm(r79iOcEOT3J0SRWYVoo1QTbeHnCMGPITgdfDLK8ogavpDWkZVj2abtgqHhKMGPyv4lfgOwm8r9qzIR7b3m(EtmPzaO6jr(PhOSZddREs5HH(5gmace8LcdMfJFLlmyIKG6ak6cm5EDcuFe01Ys8i5zaO6jr(Phkapk9ZddRE6rIrHH(5gm4rBp0)iOY1y8OazLK8o(Oc)r6x47r25HGh5h)OTFeD3rCf1b8O1sWNOcWpcyB4JGbvp9iOY1y8OazLK8o(Oc)r6x47ru4742Ee(sHbpYLw42EubEe3l8uIhz7JaWaZR(rwc(rU0c32Jw8hzLe)ObJBpcFVh5T(hT4ps)cFpYope8iBFeDL4hT44pIU7iUI6xhNA12aIWgotWuXwJHIUssEhdGQNoyL53eBGGjdOWdstWuSk8Lcdulg(OEOSdUz89MysZaq1tI8tpqzNhgw9KYdd9ZnyGm6UJ4kQj4hZPKQNu25HKJL8QbPjo(sHbqhXX4x5cdMijOoGIUadQPoWuhpXTCb2enkNm6UJ4kQjMFk78qYXsE1G0ehFPWaOJ4y8RCHbtKeuhqrxGb1uhyQJN4wUaBIgLtM46A(GBJamMhk78qiqmFWTragZdLDEOm6UJ4kQjaJ5HYopKCSKxninXXxkma6iog)kxyWejb1bu0fyqn1bM64jULlWMOr5K71XPwTnGiSHZemvGX8qzNhgqHhKMGPyv4lfgOwm8r9WxhNA12aIWgotWub8fYTPaw1tbq1thSY8BInqWKbu4bJRra8fYTPaw1tKJXpgKWfgSmDfGXXj0DVy1UXrLdao8WiWHqGy(GBJ4JWeUk84OB7j7y8JbjCHbltxbyCCI02t7cyfo8PNah(64uR2gqe2WzcM6XGTDR6jLF3k61XPwTnGiSHZemvr1iQaH1vg41XPwTnGiSHZemv6UxSA34OYbahEybu4b1vaghNq39Iv7ghvoa4WdJah(64uR2gqe2WzcMQ02t7cyLqzCafEqbyCCI02t7cyfo8PNahcbc(sHbZ4uR2MGTgdfDLK8osOoWuhpXDA4lfgqK8uabIamooHU7fR2noQCaWHhgbo81XPwTnGiSHZem1ZdT9ua7kSCau90bRm)Mydem5RJtTABarydNjyQIQreVowjSscbu4bJRrevJiEDSsyLeihJFmiHlm4xhNA12aIWgotWub8fYTPaw1tbq1thSY8BInqWKbu4bfGXXjyQq(akmCVse4WxNxhNA12acnccMWVWD7ak8GMp42igFsa1IR4EYNyjUnc3UWGJYWxkmyw8LcdisEkEDCQvBdi0iyMGPkm2nQWHp9bu4bfGXXj0DVy1UXrLdao8WiWHVoo1QTbeAemtWu9MYa78HI6JrafEqbyCCcD3lwTBCu5aGdpmcC4RJtTABaHgbZemv86yHXUXak8GcW44e6UxSA34OYbahEye4WxhNA12acncMjyQJAkHbuqxGJtsCBVoo1QTbeAemtWuf8j1IRSROybbu4bP7oIROMGTgdfDLK8osWHhd1X0e(nXkRK40MOXxhNA12acncMjyQc8b4dB1tbu4bfGXXj0DVy1UXrLdao8WiWHqGyLeRSvflE2Kb(RJtTABaHgbZemvj4uskzWVoo1QTbeAemtWudxR2oGcpOWcaYWRPeM6yjVAWSZfleicW44e6UxSA34OYbahEye4WxhNA12acncMjyQ4dgKGEoUfq1gFhCOPk8G0eE38O6jz6cw4Hq1rsimWGhSIp4qR2oGcpO44lfgmBGgkHaHU7iUIAcD3lwTBCu5aGdpmYXsE1GzNOr5KjoyHhcvhjHWadEWk(GdTABiqal8qO6ibZoCRgScSdmCBYeGXXjy2HB1GvGDGHBJexrTCVoo1QTbeAemtWun)u25Hbu4bPjykwf(sHbQfdFupu2b3m(EtmbSWd89MyfljWhGWIjCfgYrzMFk78qYXsE1GzNOrz0DhXvutWh(XKJL8QbZorJYe3PwHHvCZsfdsljeio1kmSIBwQyqWKYSsIv2QIfNMydSjAuUxhNA12acncMjyQ4d)4agvZkAm4CXgqHhKMGPyv4lfgOwm8r9qzMFk78qcCOSdUz89MycyHh47nXkwsGpaHft4kmKJYSsIv2QIfNg0lWMOXxhNA12acncMjyQyRXqbsSwafEqNAfgwXnlvmiyszMFtSrSsIv2QIfpl(sHbqhXX4x5cdMijOoGIUadQPoWuhpXTCb2en(64uR2gqOrWmbtvA7PDbSsOmoGcpOtTcdR4MLkgemPmZVj2iwjXkBvXINfFPWaOJ4y8RCHbtKeuhqrxGb1uhyQJN4wUaBIgFDCQvBdi0iyMGPEEOTNcyxHLdOWd6uRWWkUzPIbbtkZ8BInIvsSYwvS4zXxkma6iog)kxyWejb1bu0fyqn1bM64jULlWMOXxhNA12acncMjyQoiKPMAXvwcwX(0GdOWdA(nXgjwaZBkNwqXWRZRJtTABaHoyhdheWxi3McyvpfavpDWkZVj2abtgqHh08b3gjH(45aLqzmHBxyWrzcW44emviFafgUxjYXsE1azcW44emviFafgUxjYXsE1GzNOXxhNA12acDWogEMGPkQgrfiSUYabu4b198kQymCBepgbeoffWaqGCEfvmgUnIhJaYXsE1G0cMekHaXPwHHvCZsfdsl45vuXy42iEmci0fUTaB(RJtTABaHoyhdptWupgSTBvpP87wrbu4b198kQymCBepgbeoffWaqGCEfvmgUnIhJaYXsE1G0cMYqG4uRWWkUzPIbPf88kQymCBepgbe6c3wGn)1XPwTnGqhSJHNjyQ0DVy1UXrLdao8WcOWdQ75vuXy42iEmciCkkGbGa58kQymCBepgbKJL8QbPfmjucbItTcdR4MLkgKwWZROIXWTr8yeqOlCBb28xhNA12acDWogEMGPkQgr86yLWkjeqHhehEmuhtt43eRSsINDIgHaraghNi5rLWkj4xS4Jah(64uR2gqOd2XWZemvQFy4ak8G0DhXvutevJiEDSsyLei0e(nXaf(5uR22hZM81XPwTnGqhSJHNjyQr2TekAch75sbu4bfx3ZROIXWTr8yeq4uuadabY5vuXy42iEmcihl5vdstSqG4uRWWkUzPIbPf88kQymCBepgbe6c3wGnxoiqOjykwf(sHbQfdFupuMUhCZ47nXebFsT4kj4USABaHft4kmKJVoo1QTbe6GDm8mbtL6JHYPwTTAualG2L4GT5baSROwWKbu4bp4MX3BIjndavpjYp9aLDEyy1tkpm0p3GbewmHRWqokdFPWGzX4x5cdMijOoGIUa71XPwTnGqhSJHNjyQ0eo2ZLaVoo1QTbe6GDm8mbtva2Oj4tFafEW4AeqIZdBEOewjbIvuSvpjt84AKQn(AFOegmhREIamNID25qGexJasCEyZdLWkjqowYRgm7enk3RJtTABaHoyhdptWuP(HHdOWdgxJasCEyZdLWkjqSIIT6jz6cytjSnmGyfFZtz18q6RJtTABaHoyhdptWufGnAc(0hqHhKMWVjgOWpNA12(iT5eXkJU7iUIAIOAeXRJvcRKabhEmuhtt43eRSsItdeYJHY8BIna0z(RJtTABaHoyhdptWuXhEJT6jfWUclhqHhKMGPyv4lfgOwm8r9WxhNA12acDWogEMGPkQgr86yLWkjeqHhuaghNi5rLWkj4xS4Jah(64uR2gqOd2XWZemvS1yOORKK3XaO6Pdwz(nXgiyYak8GX1iHj4BL2MvcRKaXkk2QNKbytjSnmGyfFZtz18qQmDfGXXjsEujSsc(fl(iWHVoo1QTbe6GDm8mbtfBngkqI1cOWdkaJJtWhUE(akj)WsGdFDCQvBdi0b7y4zcMk(W1ZrfiXAbq1thSY8BInqWKVoo1QTbe6GDm8mbtfWxi3McyvpfavpDWkZVj2abtgqHh8y8JbjCHbltxROyREswZPWuIkLWkjqWSd3QblZ8BInIvsSYwvS40skwz4lfgmd1bM64jUtlWfRmNAfgwXnlvmy2GqVxhNA12acDWogEMGPITgdfDLK8ogavpDWkZVj2abtgqHhKMGPyv4lfgOwm8r9qz4WJH6yAc)MyLvs8St0OmXp4MX3BIjndavpjYp9aLDEyy1tkpm0p3GbewmHRWqokJU7iUIAc(XCkP6jLDEi5yjVAGm6UJ4kQjMFk78qYXsE1aiq09GBgFVjM0mau9Ki)0du25HHvpP8Wq)CdgqyXeUcd5OCVoo1QTbe6GDm8mbtvunI41XkHvsiGcpOUX1iIQreVowjSsceROyREsMUa2ucBddiwX38uwnpKcbcnHFtmqHFo1QT9rAjjb(RJtTABaHoyhdptWufGnAc(0hqHhuCDBofMsuPewjbciX5HnpGarxZhCBer1iIxhRQghguBt42fgCuoz0DhXvutevJiEDSsyLei4WJH6yAc)MyLvsCAGqEmuMFtSbGoZFDCQvBdi0b7y4zcMk1pmCafEq6UJ4kQjIQreVowjSsceC4XqDmnHFtSYkjonqipgkZVj2aqN5Voo1QTbe6GDm8mbt1vsWxKp1IRO3kc864uR2gqOd2XWZemvGX8qzNhgqHhKMGPyv4lfgOwm8r9WxhNA12acDWogEMGPc4lKBtbSQNcGQNoyL53eBGGjdOWdEm(XGeUWGLz(GBJKqF8CGsOmMWTlm4OmZVj2iwjXkBvXItlLFDCQvBdi0b7y4zcMk1pm8RJtTABaHoyhdptWuXwJHIUssEhdGQNoyL53eBGGjdOWdstWuSk8Lcdulg(OEOmXp4MX3BIjndavpjYp9aLDEyy1tkpm0p3GbewmHRWqokJU7iUIAc(XCkP6jLDEi5yjVAGm6UJ4kQjMFk78qYXsE1aiq09GBgFVjM0mau9Ki)0du25HHvpP8Wq)CdgqyXeUcd5OCVoo1QTbe6GDm8mbtfBngkqI1EDCQvBdi0b7y4zcMkGVqUnfWQEkaQE6GvMFtSbcMmGcp4X4hds4cd(1XPwTnGqhSJHNjyQsBpTlGvcLXbq1thSY8BInqWKVoo1QTbe6GDm8mbt98qBpfWUclhavpDWkZVj2abt(6864uR2gqAZdcmMhk78WxhNA12asB(mbtf)yoLu9KYopmGcpOUcW44er1iQaH1vgGCSKxnacebyCCIOAevGW6kdqowYRgiJU7iUIAc2Amu0vsY7i5yjVAWRJtTABaPnFMGPA(PSZddOWdQRamoorunIkqyDLbihl5vdGaraghNiQgrfiSUYaKJL8QbYO7oIROMGTgdfDLK8osowYRg86864uR2gqawWi7wcfnHJ9CPak8G0emfRcFPWa1IHpQhktCDpVIkgd3gXJraHtrbmaei6EEfvmgUnIhJacCOSZROIXWTr8yeqIWNB12ZCEfvmgUnIhJas1Zkw5Ga58kQymCBepgbe4qzNxrfJHBJ4XiGCSKxninOhu(64uR2gqa2mbtfWxi3McyvpfavpDWkZVj2abtgqHhu34AeaFHCBkGv9eXkk2QNKz(nXgXkjwzRkwCAbAzIRBCnsyc(wPTzLWkjqSIIT6jiqeGXXjsEujSsc(fl(iWHYAofMsuPewjbsyc(wPTz5GaraghNGPc5dOWW9krGdLjaJJtWuH8buy4ELihl5vdMDIgHarxaBkHTHbeR4BEkRMhsLPBCncGVqUnfWQEIyffB1tYm)MyJyLeRSvfloTa9RJtTABabyZemv8HRNJkqI1EDCQvBdiaBMGPEmyB3QEs53TIcOWdQ75vuXy42iEmciCkkGbGar3ZROIXWTr8yeqGdLj(5vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6zNdLqGCEfvmgUnIhJacDHBlys5Ga58kQymCBepgbe4qzNxrfJHBJ4XiGCSKxninOhucbIWcaYSsIv2QIfpBsO81XPwTnGaSzcMQOAevGW6kdeqHhu3ZROIXWTr8yeq4uuadabIUNxrfJHBJ4XiGahk78kQymCBepgbKi85wT9mNxrfJHBJ4XiGu9SZHsiqoVIkgd3gXJrabou25vuXy42iEmcihl5vdsBoucbIWcaYSsIv2QIfp7CO81XPwTnGaSzcMkD3lwTBCu5aGdpSak8G6EEfvmgUnIhJacNIcyaiqOlgU92iDnLWu4olJU7iUIAIOAevGW6kdqowYRgabIU0fd3EBKUMsykCNLjUUNxrfJHBJ4XiGahk78kQymCBepgbKi85wT9mNxrfJHBJ4XiGu9SboucbY5vuXy42iEmciWHYoVIkgd3gXJra5yjVAqAZHsiq098kQymCBepgbe4q5GarybazwjXkBvXINnWHYxhNA12acWMjyQ4dVXw9KcyxHLdOWdstWuSk8Lcdulg(OE4RJtTABabyZemvxjbFr(ulUIERiWRJtTABabyZemvr1iIxhRewjHak8G4WJH6yAc)MyLvs8SZdSjAugGnLW2WaIv8npLvZdPqGiaJJtK8OsyLe8lw8rGdHarxaBkHTHbeR4BEkRMhsLjoo8yOoMMWVjwzLep7encbcnbtXQWxkmqTy4J6HYeV5uykrLsyLeiy2HB1GLfxJa4lKBtbSQNiwrXw9KS4AeaFHCBkGv9e5y8JbjCHbdbsZPWuIkLWkjqctW3kTnltxbyCCI02t7cyfo8PNahktCaBw1taIpgRif(sHbQfdFupece8LcdMH6atD8e3ZIVuyarYtbu7uR2MGTgdfDLK8osOoWuhpXDGf4YjheiclaiZkjwzRkw8SjHs5EDCQvBdiaBMGPITgdfDLK8ogavpDWkZVj2abtgqHheWMsyByaXk(MNYQ5HuzX1iHj4BL2MvcRKaXkk2QNKPRamoorYJkHvsWVyXhbo81XPwTnGaSzcMk2AmuGeR964uR2gqa2mbtL6hgoGcpOtTcdR4MLkgKwsz6EWnJV3eto9dhlW8bw(ak624lChREsbSRWYaclMWvyihFDCQvBdiaBMGPkaB0e8PpGcpOtTcdR4MLkgKwsz6EWnJV3eto9dhlW8bw(ak624lChREsbSRWYaclMWvyihLr3DexrnrunI41XkHvsGGdpgQJPj8BIvwjXPbc5Xqz(nXgqM40e(nXaf(5uR22hPnNiwiqIRrajopS5HsyLeiwrXw9KCVoo1QTbeGntWubgZdLDEyafEqAcMIvHVuyGAXWh1dFDCQvBdiaBMGPkT90UawjughavpDWkZVj2abtgqHh08b3gXhHjCv4Xr32JWTlm4OmXfGXXjsBpTlGv4WNEcCOmbyCCI02t7cyfo8PNCSKxnyw8LcdGoIJXVYfgmrsqDafDbgutDGPoEIB5cSjAuMUcW44er1iQaH1vgGCSKxnacebyCCI02t7cyfo8PNCSKxnqwZPWuIkLWkjqctW3kTnl3RJtTABabyZemvS1yOORKK3XaO6Pdwz(nXgiyYak8G4WJH6yAc)MyLvs8St0OmAcMIvHVuyGAXWh1dFDCQvBdiaBMGPEEOTNcyxHLdGQNoyL53eBGGjdOWdkaJJtSkuT4klbRaHSFeG5uSbdCiqIRrajopS5HsyLeiwrXw90RJtTABabyZemvPTN2fWkHY4ak8GX1iGeNh28qjSsceROyRE61XPwTnGaSzcMkGVqUnfWQEkaQE6GvMFtSbcMmGcp4X4hds4cdwM53eBeRKyLTQyXPfOHaraghNGPc5dOWW9krGdFDCQvBdiaBMGPkQgr86yLWkjeqHhS5uykrLsyLeiGeNh28qg(sHbPHXVYfgmrsqDafDbwGnxwCncGVqUnfWQEICSKxninXgyt0OmDbSPe2ggqSIV5PSAEi91XPwTnGaSzcMknHJ9CjWRJtTABabyZemvS1yOORKK3XaO6Pdwz(nXgiyYak8G0emfRcFPWa1IHpQh(64uR2gqa2mbtvunI41XkHvsiGcp4b3m(Etm50pCSaZhy5dOOBJVWDS6jfWUcldiSycxHHC81XPwTnGaSzcMQ02t7cyLqzCau90bRm)MydemzafEqbyCCI02t7cyfo8PNahcbc(sHbZ4uR2MGTgdfDLK8osOoWuhpXDA4lfgqK8ua1jfleiX1iGeNh28qjSsceROyREccebyCCIOAevGW6kdqowYRg864uR2gqa2mbt98qBpfWUclhavpDWkZVj2abt(64uR2gqa2mbtvunI41XkHvsiGcpO4nNctjQucRKabZoCRgSS4AeaFHCBkGv9eXkk2QNGaP5uykrLsyLeiHj4BL2MHaP5uykrLsyLeiGeNh28qg(sHbPjwOuoz6cytjSnmGyfFZtz18q6RZRJtTABaXUQXYgiig)kxyWb0UeheOVPk4WaW4dyoOamoo5yW2Uv9KYVBfrGdHaraghNq39Iv7ghvoa4WdJah(64uR2gqSRASSbMjyQy8RCHbhq7sCqGDBpPa6BQcomam(aMdsxmC7TrWQ)kVLjaJJtogSTBvpP87wre4qzcW44e6UxSA34OYbahEye4qiq0LUy42BJGv)vEltaghNq39Iv7ghvoa4WdJah(64uR2gqSRASSbMjyQy8RCHbhq7sCqGDBpPa6BQ6yjVAqaByqaBfEa0TJLvBhKUy42BJGv)vEhagFaZbP7oIROMCmyB3QEs53TIihl5vdMfQy6UJ4kQj0DVy1UXrLdao8Wihl5vdutWmaeagFaZkEa4G0DhXvutO7EXQDJJkhaC4HrowYRgOMGzaiGcpOamooHU7fR2noQCaWHhgjUI6xhNA12aIDvJLnWmbtfJFLlm4aAxIdcSB7jfqFtvhl5vdcyddcyRWdGUDSSA7G0fd3EBeS6VY7aW4dyoiD3rCf1KJbB7w1tk)Uve5yjVAqay8bmR4bGds3DexrnHU7fR2noQCaWHhg5yjVAGAcMbGak8GcW44e6UxSA34OYbahEye4WxhNA12aIDvJLnWmbtfJFLlm4aAxIdc03u1XsE1Ga2WGa2k8aOBhlR2oiDXWT3gbR(R8oam(aMds3Dexrn5yW2Uv9KYVBfrowYRgKguX0DhXvutO7EXQDJJkhaC4HrowYRgOMGzaiam(aMv8aWbP7oIROMq39Iv7ghvoa4WdJCSKxnqnbZaWRJtTABaXUQXYgyMGPcdyvzSeiaWynqq7QglBjdOWdkU42vnw2ijjjCGcgWkbyCCiqOlgU92iy1FL3YSRASSrsss4afD3rCf1YjtCm(vUWGja72Esb03ufCOmX1LUy42BJGv)vEltx7QglBK5KeoqbdyLamooei0fd3EBeS6VYBz6Ax1yzJmNKWbk6UJ4kQHaXUQXYgzoHU7iUIAYXsE1aiqSRASSrsss4afmGvcW44Yexx7QglBK5KeoqbdyLamooei2vnw2ijj0DhXvutIWNB12Pf0UQXYgzoHU7iUIAse(CR2woiqSRASSrsss4afD3rCf1Y01UQXYgzojHduWawjaJJlZUQXYgjjHU7iUIAse(CR2oTG2vnw2iZj0DhXvutIWNB12YbbIUy8RCHbta2T9KcOVPk4qzIRRDvJLnYCschOGbSsaghxM42vnw2ijj0DhXvutIWNB12qTyNfJFLlmycqFtvhl5vdGabJFLlmycqFtvhl5vdsZUQXYgjjHU7iUIAse(CR2g6mxoiqSRASSrMts4afmGvcW44Ye3UQXYgjjjHduWawjaJJlZUQXYgjjHU7iUIAse(CR2oTG2vnw2iZj0DhXvutIWNB12Ye3UQXYgjjHU7iUIAse(CR2gQf7Sy8RCHbta6BQ6yjVAaeiy8RCHbta6BQ6yjVAqA2vnw2ijj0DhXvutIWNB12qN5YbbI46Ax1yzJKKKWbkyaReGXXHaXUQXYgzoHU7iUIAse(CR2oTG2vnw2ijj0DhXvutIWNB12YjtC7QglBK5e6UJ4kQjh7r9YSRASSrMtO7oIROMeHp3QTHAXMgg)kxyWeG(MQowYRgidJFLlmycqFtvhl5vdM1UQXYgzoHU7iUIAse(CR2g6mhceDTRASSrMtO7oIROMCSh1ltC7QglBK5e6UJ4kQjhl5vdGAXolg)kxyWeGDBpPa6BQ6yjVAGmm(vUWGja72Esb03u1XsE1G0MdLYe3UQXYgjjHU7iUIAse(CR2gQf7Sy8RCHbta6BQ6yjVAaei2vnw2iZj0DhXvutowYRga1IDwm(vUWGja9nvDSKxnqMDvJLnYCcD3rCf1Ki85wTnuNekNbJFLlmycqFtvhl5vdMfJFLlmycWUTNua9nvDSKxnacem(vUWGja9nvDSKxnin7QglBKKe6UJ4kQjr4ZTABOZCiqW4x5cdMa03ufCOCqGyx1yzJmNq3Dexrn5yjVAaul20W4x5cdMaSB7jfqFtvhl5vdKjUDvJLnsscD3rCf1Ki85wTnul2zX4x5cdMaSB7jfqFtvhl5vdGaXUQXYgjjHU7iUIAse(CR2Ew8AkHPowYRgidJFLlmycWUTNua9nvDSKxnyg7QglBKKe6UJ4kQjr4ZTA70WRPeM6yjVAaei6Ax1yzJKKKWbkyaReGXXLjog)kxyWeG(MQowYRgKMDvJLnsscD3rCf1Ki85wTn0zoeiy8RCHbta6BQcouo5Kto5KdceZVj2iwjXkBvXINfJFLlmycqFtvhl5vdKdceDTRASSrsss4afmGvcW44Y0LUy42BJGv)vEltC7QglBK5KeoqbdyLamoUmXfxxm(vUWGja9nvbhcbIDvJLnYCcD3rCf1KJL8QbPjw5Kjog)kxyWeG(MQowYRgK2COece7QglBK5e6UJ4kQjhl5vdGAXMgg)kxyWeG(MQowYRgiNCqGORDvJLnYCschOGbSsaghxM46Ax1yzJmNKWbk6UJ4kQHaXUQXYgzoHU7iUIAYXsE1aiqSRASSrMtO7oIROMeHp3QTtlODvJLnsscD3rCf1Ki85wTTCYjNmX11UQXYgjjPaeQttWQfx5uXeUooQSJDa8XaiqCQvyyf3SuXGzNltaghN4uXeUooQe5DKahcbItTcdR4MLkgKwsz6kaJJtCQycxhhvI8osGdL71XPwTnGyx1yzdmtWuHbSQmwceaySgiODvJLT5bu4bfxC7QglBK5KeoqbdyLamooei0fd3EBeS6VYBz2vnw2iZjjCGIU7iUIA5Kjog)kxyWeGDBpPa6BQcouM46sxmC7TrWQ)kVLPRDvJLnssschOGbSsaghhce6IHBVncw9x5TmDTRASSrsss4afD3rCf1qGyx1yzJKKq3Dexrn5yjVAaei2vnw2iZjjCGcgWkbyCCzIRRDvJLnssschOGbSsaghhce7QglBK5e6UJ4kQjr4ZTA70cAx1yzJKKq3DexrnjcFUvBlhei2vnw2iZjjCGIU7iUIAz6Ax1yzJKKKWbkyaReGXXLzx1yzJmNq3DexrnjcFUvBNwq7QglBKKe6UJ4kQjr4ZTAB5Garxm(vUWGja72Esb03ufCOmX11UQXYgjjjHduWawjaJJltC7QglBK5e6UJ4kQjr4ZTABOwSZIXVYfgmbOVPQJL8QbqGGXVYfgmbOVPQJL8QbPzx1yzJmNq3DexrnjcFUvBdDMlhei2vnw2ijjjCGcgWkbyCCzIBx1yzJmNKWbkyaReGXXLzx1yzJmNq3DexrnjcFUvBNwq7QglBKKe6UJ4kQjr4ZTABzIBx1yzJmNq3DexrnjcFUvBd1IDwm(vUWGja9nvDSKxnacem(vUWGja9nvDSKxnin7QglBK5e6UJ4kQjr4ZTABOZC5GarCDTRASSrMts4afmGvcW44qGyx1yzJKKq3DexrnjcFUvBNwq7QglBK5e6UJ4kQjr4ZTAB5KjUDvJLnsscD3rCf1KJ9OEz2vnw2ijj0DhXvutIWNB12qTytdJFLlmycqFtvhl5vdKHXVYfgmbOVPQJL8QbZAx1yzJKKq3DexrnjcFUvBdDMdbIU2vnw2ijj0DhXvuto2J6LjUDvJLnsscD3rCf1KJL8QbqTyNfJFLlmycWUTNua9nvDSKxnqgg)kxyWeGDBpPa6BQ6yjVAqAZHszIBx1yzJmNq3DexrnjcFUvBd1IDwm(vUWGja9nvDSKxnace7QglBKKe6UJ4kQjhl5vdGAXolg)kxyWeG(MQowYRgiZUQXYgjjHU7iUIAse(CR2gQtcLZGXVYfgmbOVPQJL8QbZIXVYfgmby32tkG(MQowYRgabcg)kxyWeG(MQowYRgKMDvJLnYCcD3rCf1Ki85wTn0zoeiy8RCHbta6BQcouoiqSRASSrssO7oIROMCSKxnaQfBAy8RCHbta2T9KcOVPQJL8QbYe3UQXYgzoHU7iUIAse(CR2gQf7Sy8RCHbta2T9KcOVPQJL8QbqGyx1yzJmNq3DexrnjcFUvBplEnLWuhl5vdKHXVYfgmby32tkG(MQowYRgmJDvJLnYCcD3rCf1Ki85wTDA41uctDSKxnaceDTRASSrMts4afmGvcW44YehJFLlmycqFtvhl5vdsZUQXYgzoHU7iUIAse(CR2g6mhcem(vUWGja9nvbhkNCYjNCYbbI53eBeRKyLTQyXZIXVYfgmbOVPQJL8QbYbbIU2vnw2iZjjCGcgWkbyCCz6sxmC7TrWQ)kVLjUDvJLnssschOGbSsaghxM4IRlg)kxyWeG(MQGdHaXUQXYgjjHU7iUIAYXsE1G0eRCYehJFLlmycqFtvhl5vdsBoucbIDvJLnsscD3rCf1KJL8QbqTytdJFLlmycqFtvhl5vdKtoiq01UQXYgjjjHduWawjaJJltCDTRASSrsss4afD3rCf1qGyx1yzJKKq3Dexrn5yjVAaei2vnw2ijj0DhXvutIWNB12Pf0UQXYgzoHU7iUIAse(CR2wo5KtM46Ax1yzJmNuac1Pjy1IRCQycxhhv2Xoa(yaeio1kmSIBwQyWSZLjaJJtCQycxhhvI8osGdHaXPwHHvCZsfdslPmDfGXXjovmHRJJkrEhjWHY964uR2gqSRASSbMjyQWawvglfq7sCqOlRb3tCDNkYaRA9af1hJSgiKPz5NlwXMTSLZa]] )


end