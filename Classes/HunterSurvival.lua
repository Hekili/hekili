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
            indicator = function () return debuff.latent_poison_injection.down and active_dot.latent_poison_injection > 0 and "cycle" or nil end,

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


    spec:RegisterPack( "Survival", 20220724.1, [[Hekili:T3vBZTnos6FlQMAyKIDuKOTs8mNK2A2zVBVj3CzVAZw1DFYs0suwCnfPw(ID8uQ0V9Rbabjaydaskzp5UA3ARjjIenA0DJUF6MnbVD8T)TB)YAVm)B)S7ix3rF096HJ)WORg)HB)s2Z79V9l79w9G39WFjYBh8F)sEYJbp6fsUWZHXERjeinopzfCXV74YTzz7t)X3)(7dY2MF3WvX7EFAWU8qVSG4OvjEBYi)7vV)2VCxEqy2VeD7DQmWTFXlpBBCcmzb7(5B)Y2G1R9z3NF6Qkw44Y)98Om)KJF6t5HpFCP71xc)hGih)0Xp9ZXrp6NKDC5M4v5Phxgd)RvE7pUC1w)vpa)qw8XLj(P79xb3uK)tWvc9sHlK6NLfeDp83E)XL5P(8Rsg3ck1wusm)VUhOrkS0gE7xcdsZsjIJvRj)XNPYw)iV7c9xF7Fe(5KaGBd8ajRxOFu2q4FTdi2Mf(r3dI4DKFR4(pU0PK1Nw83gUZ7RGSzfrscsfVK9XWFjdeCANO7Y3Sb0bXjRdIaz86fWk0lpmBy((kkDxyC86fBYtEMqSRonI5fTYpnlXlCXkVWqcbV(0i4MGeFkhsO1ecT4xjm4(TzPl(75RVNi6eNe4w)G2PfMXW1Xpfn8HGqGnJ3TZlA9Wn5W)iXFfixV3FrwWoqXp)4Y7xTwqs5DprDLLeaMqKj5JDzTDC5HdG9hmdlYIxSoWNQIhFLW84NK6N8ayfsMKBex07Y)TFl0xzT(d6zJyIjnXwIiSG13oVGiMnL7egJ0iTW(y6FcZ14rktwazpys((SfbBGPERxuKFiW6o9a3cH3faY295Pz5H(l8j3gZmHRDd9t3sDliY19fT9)4igFwQ2W4vXfgOYoUCaDvdesltuTvJq9YB7XyIVk4(sJdFuDhjvwv7oiCfmJuPJ(n9OoqaAMKh5Vjgm6gs4b6FBH)oIjWq))rEW(9fZDMxcy55TV(A1rq4Sj0lXh9wazbrQ)iq9i)Db(Pu77XSLV6vMrVIJIzkC)GrZB5I4k1iN3OIa9UJ0jckxA5TuKOWCxZzordmqEq8ve5VG87UtO8OEVC6LeehdGtBL9TfgQVNkGF0dObqZH7UBrsk4BjfcU8oq94Ls28DVFe1YuLjPoIs3gNr5n9om)9G32fhDFCCQ)I7aUGYFt(MI)aZMS4KfqmNGhy8NEp)fSXAiqnjofyZaC4hecErHdqDXVfwgE3hsOi4AkkZRmIo)MtZ89dzw9YEJ1B)3RWdYtbHRxKUpaUqA1E1sNX4xwCxUuKRI7qWMpX3)3apWLBj1BT)kXrc(hYiW42qCABdJevxfNNLgS2)g6SXHMneGLTOaauLFzeTh11SEmtgdQQk0kxljErGtOWaQiMURLcmnjOi22Fgqw6T13d8rbcJJl)BLdaS4(8)1pdWgzBqa4Qpb)064O3Kr(dyFY2GuY2IKJl3h69m4WdwB(R8OWqdYEZAY)KGDfU309E729CXCqOZkpkDsGzoGGhMoVK7ZFvWMGvmPu6qf1FHCoiDbBgXGSXx6)94S8O79dsswaRyqv8CkdMxt8b03iudMXwVMgMNAzYX2O6w5QrupfK7rBqpUrdaFpgMdIQ0ljj(PswXiVoGNoKwjIkyvIfliI2LAbMk)(jezb7FSGKyHmawa2Hha84HNH)DK8grJInXBS2kxs4s1eDBAyzcTGjGa3Yrp4NHIww)AvGaKKP4GGBuqhIbqrqhAww3fKSMMLfKQ2ZC0Ce33akEs4IgYh3fV3muBT8rVZnRKMHcexpRaM8UTFAwf679OFfQ2YOKaUTiYgUKKAPDLvoSMKa82NxN4LsrwGaZoyp4)BbydgVtYc2WvNQaoaYIApmrli7mVhyGNbMBbZJxkH)SfToXly9cFkiFV1Rb0NFLKJpBhI61kzccOIXJWXvtUM6axfNhLrb24wX5IrCTgcVZS5nNixQ6dbl4X5HtpzbkIdRsN0OClwbb4PtvgGyN36f3fV7opG2(jvbp0N29ezDmP8gukGfmaPMfsJziJ5sxSjHrtsrXi1sqChEcBpS(sv0N6IQBAgAcHDqVugGwxkH9eZcSOUl7YJciRQQSaRwNR99Y2UaKhpK4TZCaJk6grQDx09p5LaHTj4t3tTK3V3lXllxjzZQksGKPs79UssPGhpPCam2xfJGbp9RJZgMUf48iixeQjrwWksHJ4qUi3aTcnGTXcy8(WEG7hc5)S6bwvGyQH60PEfvQ4Z7YZa9gREHgQ4HzMRhfpp87rGKod294EZc39RqmDnwrH6Bair7gorgUI82gn16dqkd)Er4bAAPUAwZ69gJyplKywOx0d0SgQYwvV7sI4BpmLXqk4(1LFycpUGf33ufJiMTgEyrdz5tj(gw6jl25L8qDsxwldDWBPdFDr2tOZVE)v9yMRYQ0gyzH7lJ7NJTDrJ904HU07aby11C)yAg416g4vwg4hk9rAW7SJbcyksZy9UhzHdI8)A2INcycx(M4s2Pa)wjzdI2KtFkiLO4g8IU)tpk8Z4mw6)XvV)xDHVmbEGzP1XOqvf6vSip4z4vVIXCRPom3dAJ3dx5egGi3jR9tiXWxbOevJV52QkglGUVQcCeQO3PCIpiTs3sUIyMH6s)aRALGXYnTlVIRLIStTLuw26DXQZS6)3B38brHwvOefbN(ydcA62PTu9hYhRC5VXhRQ3i(yLlnn2yP4gnNQSbtblO2rUm)5RO8ZRZtOpF(JlVO(fdIy5TugoQHevmjHRhzaPUXmWPyif1Fsr61St9JcsitOOmLgNJsmWsAukhQxhIIXzTafL6hty462kVvw969yYlwBwWEEb1HyLEj8mhMXlU1lPqUqoR7oCAbp2cybSKIEBdY0FqB2Q)zP4bs4FLCUPpOqN3U3VB74DhHVFVinEwH9pfFck1kPwhrmYCHM0xTKolPoNIPgicCTjcChjJHxSIGgtqY0YVSU(r0ItTXZVowD8NfypTdgpA0jivV60LQAyObwK5xjiZ1u0q9jp120))H2Gt2qDGS7iZXusXMQLPPWu9nNPJPc81xXXoVRAOx0CSV6xvcGVLygLLhHJSJ05BcUklFiZEHHXpPY5eIxujWlK7nbX20J24cm1Q8tgxCaVLgFAGDlssTVhykzE9Oh1Q5SuCPZtnKCBcA(w0loLp6wPCrsEo07biMF4d(0QXgTbcqTUAFgw5IRQTyZ72MtD2R7LTT1NWXunQO18KyhzOSR6QHBRYevxc4gB8gAc3EH736rE4NR9a0ss5C330UsKRiIOU7TrKKTULEGrZ8BccBRsJ0qfpTunjJ6OgSnvF4SgGV2OfxRaiBOQEnycQ1NAgQAx96bPlnsD551Q0SC17FwtzwDknQNRXIM9q00emu6PZjBPB(rUul0IRKlCnpFkdvE7ennD17DUlEGnTqT88oQ7xsgjGTG9Zvrhm2U36sJpmptTY3IRUNdtd2wAOABDfdNjeA1UMMDftgXFidT2QotOTKqQ9w8EkUPQXZ3as(BH5(fweDPZXO0I3fpphTAr(ESkGzNdW6nl9CLttB9oneTblMSKyYgUQ1KQpHI1e5DeaBvHrOsl9YfT1wxB6FOz9O2I7Z9t5uEHFyQi5BW4u8oGncARNMvVFyEneeVOlmM(v1FztxwDA9a74F1vSk7gWQ4eFHw4nzSIVr4)xCLHzJhU1lDbPlqjYvLcXiSFtzaCwx4fAPeoG8Eo(L1SpUNaPDBiVuFmvSdzmcxuqdkGBw7QVKvnYtcdVK(v1oI0HryCq1DmaLlQwdweloNnoOxt0AM4J(2yL3rH6j2BsIB0yCHMln3gTFVy)A1CU8Slm)MsoOOZW2EBE1iTErNVb1wYs7Z8w)SSyfDAycK5Ax1oAVYuBK(9LDpwpB8O2frXCHO2Qh(tHzXUHIQ)EUSuAlpRYSwvnKk7DHjnG5L7PBnxNccLiVbl)52yXoQk0TAntOP1A4wRwmxyJMZRrtvlE8GBVq6fL)pvMGu9c9MLdA0cqdkI(wda0xjAhN1TApnN3Ib2eF8hVtBTovLcicc8L05dgu3demqq0iR6cshUYB1wFsj68w9pYH8CxVidC9MMN4xWaQvYEkV4rum(LJ6jsrl4kltv)wZWgaW7dJHKQRaeJ8Ckvan7Aa0CtbQQv9Cgbn3ua81hJgRLX2TwSzn(cH6aHlQwdwelwJ61yoODGMXDcBMvSfbVHHxnaocpdedC5zxy(nLC41jNp9qoqanBaqYPcA2s49E24rTlIxfqZD2sPT8SwqZ6unVoGMTKYJDqZ6x(Tf0CtvfwbnJsOte0mUFjRGMXdU9cPxEjanJSaAaOz8aanc0mM9u3bn3qRZgaA2ET9onyqDpqGoqZUFtdA2fRdZSCAducQ2W5rqg7Dy3yZMt5rTV419BCRnl9a2h0UhwEBEwYv6JiFJVpcCfu)Zv)DDrrBz1koOH3QIiTnpW8RAshxP)HQ3LxNjIeJUQm0Ry1EC7DSHJq6GsP3ye9TvTHxzKo8sT48s96a3XolT27uHHteUCdpiyhdpWxrRYXdNy7KycVfF03toVC8vd6pIXT69vZW7JmLln1WuTtCPVXA(2TJ6AzxV1ENrKq5YVK72Cp1Z2BmSjXXCC6)oAO932MzPN5jIJmvT7FVHpyTu3GJ2AT2zdJLiFKw9laUUNJZlpRQ269iWCFUYF5BsPN3uupMhx(tCxMxcHBd2TNCAurSwoU8)aM1Jl)z20ECzaNUpXOBPAMGG7FJzeUjjEhzIPuonE4XLcCtZzLIHaHgYdxBMDsk3aqonUUZhGjaQLT(e49Krfd32)zHo84Y)iyVc)gmO)kDh9XLFHVL2QPmdyAlIaX3Flatbpc0XIZJsDTSqRu))3bzBBMmooIOR1kwjlj4U8s8zQyoUDWojgeWjpfqKOPzX7jh9UuIRLwRYPN)qLYbVDS3ljIodqMMFpWYKd530CW9l5TkHQb53frhY2ih6VjR4mxZl6z2vK4wcrajfHLj53W55MOF7GM1X(7Q7CMtVtXhT88u)f(9CnffzEXcwv1U4YgYgUSixkC9ZlFY2POhHyB6bE9a4S8wRieFqhkibzLH4(6OQkoGwLv2yPxuPAVnEk9d8iXBw69wt5g1NjQzzHaOA83qldhPaAafjN4hJ8nTDEltbYg3wVj11Dkt2a0HgAo66ifqFX4BDxqFcDbpKUdyUUIKFi6B8Uq)dwdLRKyR6CZ7XYUkumZRIEkSqdkpu2DWzAUNc5UfSyGskGIbkfu81)eMpt5ylnnFhS8wS3xnzxPQaCxCwgCLfSCJFIgoj(RbryffOkp6QJLBP7sV9rdoZMROFMW5fTuc86ouDP2pGmHiiUv4lfaepnIikbmk)0F9Z)YN)Z)4XLa0esKEa3zCcpY(BkkUw6Bi6ewn4iOjjr19YZI3r2YsF1QIU3pD4Xp9RbKMr)d)ib6bvptUm57ramQNHK1HD9Fptf)R5Eas0Ghdi8gyga7q8OWa7)Ei2s)jFDGoYXzQHJh()8ggXEJqzpj)wF3RBW4DrgVBX4)GW4)45D58XoSCmWonA5Wehh)Kf1DPRM2PVhRYrm)pvStX)M7dc(Dpyo)x)l)kWBJBgRL2wE6mye2qwB16wU)y8ifbw5XOFPiR6xeeA9DfmdgF15AbwqVRpZ0BY5IEwva3fVVLkGZTStzT(Mk36LAuHFsuLkrMZGn7vgOxt2ykBJPsGoUUUPd8rd19SZn3wQ(DpD5SP13jtVF4CrVJF6xOslcvUHJphsENCSwaxgqoa4SiayNqWzgVjGaR77GzS2hli4hr(Eb9DL85RhGoY8YwiPdldyDXS3ZXLEjbC7SkSTxgVFgfI8Lu8QZ0cX9Yk8SZ0cN9YvXrRPNNQZWGzJZAvqoXVUoWM43Dfmt8RZHjEzWMznaFPgwUesPG8EwXNcacLlAfa(xAahSVYaoSNERMVWaLKfMo23saQbvJ)qa8V87YhcarUU(h1aIKPxHOP8JdG4q4NO9mRuDp4zcziJP6PIpBStFdjlF4qVYk(y4X9C4a54YWrOy5tVA0Gdh6lpzZhZ0CiVwKaf0ZfdWwPPGwfuR)jFqwakhVv0cuYQv46487azo4JjiSOuZSktVph(5)A50FC5prMFYayL9mHvtZIYlZBrIG0cLBymzmeppRXM2)ezAlkjEe99NnMrSuk5k2GZl5kRMqeITd2aV8PaWmJxyuYtZo1NmKusnr9FY75llUuAWo686NknTLrMcik6NhYKovInWhi9nXEbr4h(OpXuOenO6flSjq1tcnic(Rh48XJoCOEh9mD8hK0JQpawMLlpZqc7P0(oonXs0Xk7rnPBpHTZ6aED73eGP8s2tJE2467gNELJPpob2jp8NgPEVtJ8murgMI5UIer(BtGya27ObpfQs1LsfPIrATT3sH5j2LME)Q1hoiuFTbstkWuIvreBwrWj40K(eHS3OVP2z5Wb6)8IQkxoTSQLxmE0Ggoln62eKgORFsmf1liv)rDsI6p8vMehVNtuNcLogrZKGmkEFKOEjCZuaqRKnAlEWpfGxCOm0uSNEHchi1ShnCbjb)tRLpESqhBTEX0XdN8we9UeEYxRjTwZB0nrbEpCm7QwVgn(aBkCRO(0iC03MaSnWFFFe7K3vTnFarYuZpuJ2U1RONcC6RBJxpT9HGb(EEDQ9UXV1g96PNGawpPq934ONou04)ZEyO99WW5isw)En2zyr8kmNGdO6W)zJiG0icNdLuJvroMBoH59BH)jhTnGq7it)E16Gas6ak)KJHgjOvZxn)Qv0RHrJTId1yVcu4vux6ZObCCQp(ApcC14KkzZGfnH)C9RbsQoVrRNGP2BWyGvEyzvMMJWLnwDpV(5LOEnM0FRqkyn4QXNbFRTiWE87IP3aPckxtlBFHXlWBw1fdIKc4OQVk4wqQPoq5Va4TCWLFTVB54u(wGxBXi(H7MLOFHValFdWNlHWSGyLFDUTWKkiuUsLq8sfk)RSp12ustQWL07r1u3jn0cUqCwwG1lf)mDpBvt(kDtybMFXPFCKqvymbkN5pwljpCq73zBg2r0VT2duxwI1f2C0mT1k2rnKdH1fcUj(z0MEPAfw8Wb5Fz2yXQroFIceCUcbO7LfFnQN5or3kiR6lIDZwncZ81VfXOTmh86vqHW41RDwZdiwZSw1Z9l70j7L(fF6qEgamhU05G)PLE(Spi5DMwfl71Fs)hMgh9LMYyLPu5bLa30OY4hw8hoO5qwF(ms5wv2omd9ReWBDrMFvGfDJhU5uybD4tAnxCAsIAygAxTUkEgiYriMGTCjN21sH9KbMu)eLE6yeYuRWt9BTaBsJfxq(9OLNObFvirLa)(v1UkMO44Zf5s8tJ7sW)yNiSo9n81CCQ7HdA)koovjwundd9Zzp0JqEZRG62tZDhoXrJ1hcQlPZ98VhBRtBRRB5aTLDS(dgFhmjbpzk91HwEM5HGPJs5JOi(YKxiA9jGO3FIPsRHTAQVXLTH2PpIkD8qxhLnZxt20ICJxREJxP5g)aSTxJtfh0bG5Ut0uSFp0dtyywS9nmCWz1E1Ml4oruB2Yn)XP40Vd((mxki9v3HOIB9SH5(YqT(lVNwuCMQXydNMy1umGzRoWZ53OZ24mPE))K6rKhqyN0fid34ZNbdCQ5A(unca7WmXwls43j(TfLKupXuh(yhK7fO7WUKdEzku7pGI5umR4xKPRActZM1KNcPJEaI1UajrxnFNOUO(3iQPtgupwfcj44oVEKiZ3eZQEAp)6X2w)ryPQh5Goa8o4hc(dkUFLY9zorpqKIJpPDRdfXKXTd04RgFAPNvPciwWVIJfEOXHCN6(wdPBnqr2G2KamPwBYWfBNq)2SvWDu9Tc0KOMnUTBsq6QUXQ7CAC5do1T4yRldCVlg37QY9TnZ)6FV7KHfw39ApKHu3pylLfx1EzbYuoaTRjRBw3QmROdYasSsJgBv6GU5dnjl9fab3NN2wxangf6NWeh9Unn(W506Jc)HU505(36Dm5RUh51BVAaM2E8ivVy2azIkGnKKS18HRMvepNLPjPKV4yXc)08p4pkuxmXWZZe01CertO2D4eSA4uizvvCTiXg69)nCNk5yfUk6mOdOqlTW1KrSDjQvWrgXLyqvBuZzQADTfKRCES1rdIde1MVD0kUWQu6CeRH36I6sTOGXm7dZfHK56Ow1vBK23UAU26RlokA7Mr0DBTTBhE3ytoumKjyBm0TjTAB8vDrqv(Df7QjJgOZkPIb5T6)m53WQIZBZI3QkQqPTVVi1NJluFpUsLodRlMm13laDtU(2HT4nMbHmNfoTWGO6vpR6TgtzslxrwEBiM(hAsNeW(Emj(IS1IrfyOTmK7yUFNKbVaRRMPzFzwoZFXvPORTY3lRlPNGQ83KhwDj6NvEAeiE(0kKrxXEf57JZsdCQaUiVZfsMtLe9Ykp5cmpxk3iFYoCO63fe2faGWxiKUEuZSwnGsIXZTC(mKzIFXbQZf)o0TaDoHzQNEXRMjRVHz7DtMIEOfF4a6pp3aP(E3bI6dDSWzro8QUMQeSQBjmWHvSpczhuX)QF2NCmqZ3nzo6kWb9xNAGsFVl5b5PJfWzokrLKT1D17y6IZDh1r9wd5hrgXKyC8OlWLyM4(oz9OoiAPKmTAMBu62yPhg7ByStLAfgJkXlmTLvImcwyQEGppss6)d99xfL(d0Zq1cm1xNFS(9uzdt6Z5tgOBXsQ0ydneexddK23AmUw7cs2Axydg4i6y08jdVA3ln1T4Gbq5yDVwxonUOehQ34G2aSXvgyJnWg4IXUbSXgikLBSUoR(X8V(GSN)4uQZf)o0Tan5212m1aGnQ(rmmBDfeaAWYAa8WyHZIC4vDn9cGegneLmWg0yxDcyJMaf90Yc4m35fytR0BnKFWa2GjgFra2Ob(ObGnyRMgcSXM0ZeWgKX2fGnyBz1bSr1d85rsEcaBCBkWgv)yMa2uxF2qGnwme0bSrBc7DjizRDHjbSX2N8MxzGnMpZGON2N3()o]] )


end