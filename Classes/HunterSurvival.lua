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


    spec:RegisterPack( "Survival", 20220605, [[Hekili:T3t)ZnUn293IMmHR0UE1krBT7MulDtUCTxZ200oXzM2FYs0suw8SePosk71z0O)27da8daW3dausE3CDUoDUSwK4H3x49fEa82H3(B3EZIG8WB)f)b((dE)GR677p8s)V72BYFEB4T3Sny(db3d)J4GnW)7n7sFm6XG1Sh886KGfmaKLSlDo8WV5WSv55BZ((39U7JYxT7U(Zt28USOn7whKhLeppnyzo7VN)UBV5UDrRZ)P4BVdhb(WT3eSlFvskmNrB(XBVzv0IfHIxpmBEnMCy2)(U48W0dF6t7Idpm7QlomJbQdF6WN(XK4hdtZpmBzY8DzhMLa)18GThMnFv48hGFip5WS0WSTHZHxko8j4jRdYGhKfMNhfFp8VE3Hz7YclFkBCt5qBAfWc)8wagzab2)2BwhLLNXykWVbu)Db5WF8lC(CyCWDRdxC7F(2Bs2cCTW8OL3EZ80ia7JcagEW6W48(BsIVpjjlC6DWd6xoiovNgTLXhV9MVce2JbPtf6aBUBAA205jz5GmAUaHGNgXqu2)A9UWPHRZclFA)0GT5jPtZYtJEiSVyG8xR6nuPz(BKdAemUw5mKTBd8wt3gMlZjH36s536UK8C4jtxUo45Wfpbu608KphfRnMRKhZY1HzR46MAV1inPwTOkfu1wMKEFyFq3Fn)FnnCZDHPz9d)77I2ULjXkHFoW5YbEadKVxHKYddxlEKYed4rCEqLEJTxxWNqXZohMD3ULl7)u06ftZ2gbpiRFA4MGOyqdy)EJp2dulsswVi5P4(peTEniY3SjiEr5BiXbtdd)DoVUGmV8RngjXZZzRDwgSBn6kr5LFGumVFYU8SOfHFKpBLRw6dRuMUkiDBssm)bCKmGV(AAYYP5Ra5FW9Rd7ZWTA0OyinuM3S73)D2ILMkYsOwfTKgedkvRJ4S4Svj5Awd(RWI9GvHblG)tm8)8BvdawE)l)3)iSsooCtuygyA8j4NwKe)QC2)bStSkkJzfj9WSTSLmPWFDx48aULHO8xTG9NmZjW7MTnyZMNlMdgCMhWHtkmZrRFUyEzVx48OLrZfCPS(AI)c(Cu2uXmwTEeH0)Bj57IVpmknDkqXGO4zWWtW61YGK9UpcSFbjEy24dZgYLrDletGkt6IOyWjZIPGnqMMq)DBfkBDK0OWEpvnZKmHsyE0MqWUY0frax46dZUCWHz9eVdmP6i0KseIJnGf1eyoyIYG00KNQqfJ4AVshWKCKs7vLSoMglWI2KPPL9EYfaZbd)XbGhOhEg(7y1LBgzoYVyd6tHfY53h30utAm6DQ4pMY83k86w4DcCYe)qi4dgO1pqOwzeaZxWh7hj5t6YxMcGqTq4a)UO0fzmRcG3ZNRDGZC)npNzbYn84UeUP0VR94rNZnQiChpCGZOcOY73(Pz(6WGhd5tLIJVaiCKy2cU0uGOA4RSyyig3R8CgMUfg5u26L7rc5A1ZlsdYuc4QEb7JrBbZItbL2KnkQ8gEkikUFoWON)mGCtfw8Yy4NnV1PbrlMg(idPcwSaIM4ZS4jfRD0Fw1SnHzYBG4LAijg3CGZtGiMpm71CHujps2JRvx4hnA(Xtel1TUG5848GPNmdfXuM5GkxUdwBaznSIPUmL5JPursYbXMGftVJLxba7W0ANhLUMwgD)Q8PYkIJuLXlJsd5qWMZGclYkJPVa5YMUmvatw(xWCOScpvSgw34BnS7YnrDCsgGEok5sLdA0mDegnRJQ)UG7zwn3SloIrvyr1VimiF1uGF8qAWgZomQHBmlDQ47FkifCBZIpDlxtE72G0G8D1tJqukYTdyVLzx1xo1R2ADLLsrP)KQbiqF9yemyPFrsE)SvaMhd5IWvjYJM)aqfLHCXEHiwc5GUXuy8HWAG77NLhm)boT4lednHJMXtEmpL45D7Yb5w6Z1(gocKRdpEE43JboDoS6X)Jt93ohr1DiTnASfamVD9hPgiJ6YgSL2t4rkd)EH7bEg5(e0mT1ye9zPeZwhe)apRbEU3CqrfRTCcv6m1TaIKaPFh2KRIXslz34wSWDloK2WihmlfPNmDtq6dCGOG38SIyqr3IMeN4zWqSi7j05N2EvhH6QQi1bnlCBzL25elxi0Ng23N)gibwDvPDmIbEf1aV0YaFFLnsdwN9maatEAgsBEu4oio8Z5tFksWClxexHofbQvb2O4L74fMQkCTEVOR)OJc)moJv2F81T)ABnkLtntHui0)osFtvuTsPFWZiSSwmnYe8yM7EebvRMWa45oDrykZh(CikrD)B(MSVBWCQuf4yqHQGnKPBKgcSRSvSbiNWiv6hfvkrPAdGo0hjybkf1uOlPr26Mypw1Q)FKEJsbzRDLOX4OkKGlsAIjw3EyjivkfoXy1TgvowLcTJo2CrDfoMCLnNmCxhYhUWFO8IakXYzsrLJsGsIjDKYuO6kvUxio6KN0Hh7LkIj)nSIFMXYZ6(Wyo5XFaeRZN5pC4GshsUIbo(QovHHlDrNMoR5JXzcD(PgIjGoIV2guRYQyLq9uOz6q8ogtkVyPOrhQKr(sJmsD1mH6sCQsq7zOe1YQLdzPc9AdQNnYUKY03xA8QvXq0ihr34U5rBl3WiiwWG0YmJhdXNtGwuHzqYUkcRiy92vbSk)UiaqiLilkTwxbIL7sFwHBQ(ez(yHo)74qbrT)WS3QADSxjBN0CFJCsTBmILtGAHhSzEYAwCMO7j4W)T8T251Tzw6yEIkYatFhMg(XYbtcDtjF5yGF6IghKdDBBezLAHsEtXnFY1wu2NZFA5HzpNSRAdmxf8iBdoRNXxLX3es(CEy2puoPxaE2J2SLTfLm9YdZ(paY(WSFuq3hMfvc3NeWTI(yB27)MahxMMSHnXCiNL0)WmjSXDuPyiGVPDRxygDsR4pSTO9UqiIe2(1Y23vo3jbET)ZcLOdZ(ZGGc(nyq)k3(ZHz3uxYhQIIC6I)JqW7qwatelOpfdn2sL4CnfDLlprD(HQ65gESmwk98ZlEQVq6)jkFLBARjXSvnKkOmCfERG0qXILssbwXLaQQPpfX0nZYt2YA2ioWjH18D8T3RIyd2iQEpt7hYMy39ReT1u2oWLzuCXAHY3ITAqytED4Y8IwAii(zXtuWwgqaLEgkVCznoBPiGTOWanQ1L1CR4fUw(H91lvqhhAMb7(9PGQECaeUPv27GgBfNwoZdKFzLDxu7fPRNVzIwkOA8TAZqzEiI(rnfpb4v70i5fztus7ZspCqf3MPcjzpF(IQ(GsJnJuqPQeKrlqwMOwuAacviwT3xKHv(HgrVc)1gERlegFFW9HBy)MSQCDSdvYGAmvVVRO1bSjSUBDsYcUcsvM1hpWcINhccZG1vTSdT0ZjaYKBCmSkD6YNSMTpWzt)B7wC)MgnnHl77RIwpr1S5PsvXPe7zklL3hq7(gNOnIWFVuAEaTSWuEeVL5kxTYcRT6OlDVHnn3FulwqVnH)FXsTTEY6kRY(HIMlWL(EsAdrlJ4G10P3fbYLTGVWDWISW0DCx7QHDu9ApMWAaB49Ysw)O(cjXIx93GHvkBbRCxYY3Fx2uoL3bZRcIJdxdceVoKywDc2U6Dvl(sYgTL)EndWtABoQd3CnePc6Rq22EyTAqvhgQxz(rkz6wY5K7)xYQgWrnx4ivu6UwYH0W1RQlgci6cNY(hGLFScouJu0CcKTQ4KQvGwskv7VlTbZVg4wdx5g2f7Vg4NAaeyPck73LJglIGWRb)uIoQ59soVA2TZcp6zwASAlLoWqBaH84sTETFEXUu(rmHh3M(dJeLOFuv1vCeOYjHD1GAorJcTsTOMmGPI64OgYVCvIi26VpiX4m1xgMAxmpT9AVcgvShSW5KCvyDhEiBhI6ky1Ekhp8xLT6GUW)hDlcsRb294uc9hGRcw0QAcJcNIAAHiKQv1hoWqgC5M2tMJMtDoztoWc8TXc8hqKxQXaJTq(vD1EmpwYLbHQHEqFEx6qoyCdKNax9YtNRsGq9SWZVCG1S1pYsVGSBGk5eyBFCOtpGydf8RdYZZuFFrz)1Mfsh2kddEuvmTxgvp)HMn7APcuSzLYRHhDDKkXQZZgR)w7LK5182CRNDfs(o0BOiiKBsjvliqkpT0)KDAzBsQSjLuBUVHgyfpnhpTTXj951bpabcU(HqE4MXlb)tlQxMH1r01TpR7jqCQZEtJSTTf88m1gM826LPhzOZIPAt5wTNMsXmQwkzQAX9pGB(RKYULt)jX8BkYvIvloUZx2S5xvjbmjNtDtmEgz61eZu3byrrKapO7LedqIo9wQwkXLgHZy490zEGtynAr26PKOtI9Q0ENqO6koNieodvoakQQ0MpvbnRVUIjCIJGrJ9UWMMRZQMn2TbjH1ryb2eHsDudm3OpN3TLH1Ig2nIxP8HzzIGpszA2LDTHopJJngotrO14zeRkgv12ITwRox6K3sFHxupETlmIcr)XC4OLVAkYEoE(0DBXQjJDma7GjtJvEoSHSYP2PduhiM80e2cUAAsFLR01icgvHbOAvA1fDyOJ4Umq(c9WL9Ry697cZYK4Qwpy4x)NCBNqkGms9CEHzec5YllBaR4lUswe0JMU3lpnagrATOKkcTcRjd1Sn2L1gh8N0pFy)vbztzx0bmjNwDyKwVPnGs8tAd1QchqDnx5Jjwh3rc0(oIlnhtn6WgJ0dLy3sbits9vOQrCsA4vWVU0rSs(JHb1VrpuSOMgSWw8oByqhxKAMWJU2qL3Yd1tU5eLxOjWcIhnXgSFN8rs2DS8SZm)dfFqtMHT82m1OqVOZxVgKSY6SGfpRYwrNgbdzcjv7r(KRTb63vDaP7ydhjjII5crS109NgYI9cff)9CPP0wCwhzTkAyv27nMKaMj3txBUjeKQqUdK)eBO4rkkOOwZa66gThJvnM3ydMtAatDnECNBVqYfT)FopbFp5jqGEoraerr01QdGUAE7krDR6ttk30BBSVYD3PTAN6CbegbojD(cd64De0tI1Ok6IY6ppy(QqwT4cM)33b55UyAoy6nBxAybcOxj7RllEeplIQr9eR6eLcltv)Myy9GW7xNWAA2c8Bi2ELPf0SVHGMDnqvsXZzmOzxdGV5yi0wgAxBXM24luuhiyrnnyHTy1RNZyq7cAg3iSzuXMhChDVAi4i8mqmGLNDM5FO4dFzY5JoKdKGMneqYPg0Sf37DSHJKeXxKGMpAnL2IZKbntjA(Ye0SLuESh0mn532GMDvuynOzuaDIbnJBxYAqZ4o3EHKlVebnJqaoe0mUdaNcAgtF64dA2rTthcA2ET9oTWGoEhbubn7)h6GM9RAlmPGMTCH6wfuTHRCx((E9yyk7QOQ4gSFeRv3EkinM1Vt3EZ)Zp8R)Yp9l)1V)WSdZ(n2bwmAZ2K0YdO4RkWVSxXoBEcYGDUnyTDqWU8KnSANZ7ofabY6F4t)CeB)8E)3ZobL8RaE2Jzxq(WOEooNTHNF7b(jC8N3fCy2IOhJY4IUKTHPb8ZfC33bcWUJ(CpkWvIu9h2))9vcG9kjnh2V11)khgVpY49lg)7Lg)hoVKZhocYXa64e5iyhh(KfXD1hfG2jVhQJrIE8PgDk(7Y28b(9ayo)x)V(za3g6gQL1wCA0Pl1Ce1MVOLRpgoqJHvDSKQyz1)IetRRVKAWWlpxeyb8U6mdVVCcG7s22sbW5M3PrRVQUtvQKOs)KSivbmNbdNxAaEUSWuvhthahjD9XJapCu2lUDTBP43)05ZMOVtgEF35cEh(0pX5wmO8XYwt6Wm(xbg4XSpdmjlJyBx)3attJpznWp28RwZ3uHBv9MtvRs)s99DHnVcKpRFLtQ3m(DLrTEblyPX1nl3fjBhZ7mHl49gW4IEYQ53XLlQ75GYxkTXNdMlMNeVGFtlpg7JGdoQv)bHb)5uFkyWF76J3k(Zlp2LxeTCSlh5sCuUQ3EL43JloS6mixKbv53GepSV)iEIGEj(2Jubwy6ehhAUcLZFIq(x(Q8jcrgRB(5oHXz6uWAQ(SHipKYV1fcTuQ41zGrnzIXd96Y5MZrB6N977uLee2BuKB1(9StzGNuAVxF5GE733vDYMmui5q6Mmac0yrpmkndKQGy9Vec8cq4emN3dGIR5Kfj7Ud45GjMO1f33qIRNOT7GF(xRM(dZ(b28ZgG4gBjvCDSuChdvMzzuwHWDDcBmmlplWM2)cBAlUxKI5TDyIayzCWvSapR42IHzuraSnWc4zpfbQzXfZnRyuzHSHKXUoxcFk45lkEuw0g(8YseuAAR8gfXe0p3xWDQzBGnqEdSoLX8x)yitvOkcq9hwOtGkNKYRgVfOMmCW(9nleY1dFVICu)AauO5wMnid90Q6HNlAIEwrpUkD7bSDuhIr3(lbXrEH4orC8WMRgV(sptF2sSdE4)Ae6DonWlIeYWumXxgiQF1sKDWEh35Pux8EHspclanxhe7S2wOEI9ORVF(I97LA5(EktkGuYnnn2SIeNGWQL1RWuWENPt51(98)8n1nQ91vnP9BgoONJZItVMe3aL(z(u0FGs)mtXjAE6qeCCos18O(PnfANurIjbzuLhQz9hHRMcbXQOJ2IROTIGx84i01vvSu6msOHbkNeEhjiLW)i18X9f6r(Ssz(W(JEnICxjEYVutAJJE6XXkWpuqJVS10OXJgwHzf9dFHhYVws2CX832frp5T1lZ7X4mnSd50YTofhUbVUul86qEByAaVN0eAVD4RTbVo0aeI1tXv)h9OHdpA8)5fzz7VilphEY62XzJHf(RWmc2Jld)N3HIi3HINdHKZIO6ixrVgrN0Tf2NQHvU2njv7at3onURpzPdO9t1ZwZR8ZwnFnSRwdph9gBnouJxmafwfPsFg1HJxZX34e)P7NulBgmVjLhAVgbj1e341tWaIB2XAPBzDKUmcxXyPoEItQI61ys)TksbRoxnEtq2AnIMPFStUEw9HubvRPLT7ZXI4nRp0MYGcWO67GrlrQPpq17BXwo4Q7wXwooTBEXgeJ81KOir)cBbwUXfNOeHzbWQUleTGKArOCPoGklvO6VkUyd5GMvHlL2p5A)roQbxWoRkW6fYxFGJD62dKHcc7Ix)HbsvHXuq5c7XKGC)EYRhrrSJOxjI90jl56cB2BgzTI90D5WqDjNBYxAH8h1OWI73R(lJhkxnYjJ0cbVuGaW9II7(VX(JOOG86lCq3OgPz(QxJO0wLdEZkOWq8M1oZDhInuR1TC)YoDQwPFXNoK9aqyWLphLxKFtg)EfRZ8QyzV(t0FBQ8OlnLXktPJdAoU5ELXVIT2VN4QPAYyw5w1womg9Uv71(iZVEGfhho8XtbfOIpP1yXPXjAeZq7Q1vXEGO6Hyeg5YUKGuC7PgysZlINRhIaMgfEQBRzyJCMDb53JwEch(EXIYb(6v1UAKO4whb5rLxIrvb)JDJz411W351R93VN87761A(IAOyqpNDqVJTmtbn1NM43FKhH2hsuxkxxuFl2sN2wx3QbAl7y6BompmorzYu01HwDMlDbZhL2NxvCYSSq00jGqBpXuP1WOMMlCflO96Iish233tBX8vSfTiV4v6V4LeV47HL9egv8qhaM5ozvXUDqVdwGzX2x30ENv9vBMGpkGAtx29TtXR7ry7ZCPGORUdte36zdZ8LHA9x9oTO4m1JXwCAYvtXqmBnd8CYhP0notI3)HuoISbHhLSaz4g3FgSGtnxZN6raXomwU1IK(DMDBzoj3sm3Gp2fDvr0DypYdVmf69hqXCkNv8lY0vpHz5JDzxi9OdqSXdyj6sC76(MM3SUxpQxtFviGOmUZRgiJ8UOw1H8A)cBz9hasLoYbQa49WV7W6v8(AL7ZCIEalfp(K2rhASj0ncN)KwLfhM0UBBe3(dAkU5jkmEyBveq6CSH6AhoNI8PQgJrxgWEFmS3xh7BB2TnVjSvd9PPjKoidP5A9wYlUS98cKPShANb2uTUvzpWhKHOnQuASLnVpRKsOjsqNKp(6AYTNh1om6TBOhTPbJBa1(942Ti2yjVJUhLERG)sTToV(YEys7Hd6PjzSfifkd2qIGwZ5REwrSCwLkGwordLlUH73fOAqxo5NZZeCS5bHM0OF)ry1POGZQl4ArW783)pWDJJN1qYqNbQqeAPgorwF25OgJhUQqguDlLbrTrjNPks12a5uZvRzep4bBzZ2oAvfevdCcI2WR9rnPwuuuH(H5cTjmD0OcIoj9TlMBqFhJHI2Uy8SSJ(VDOjdkgY2Pnk624wT1)kLhuTFxtVA0GEuAj1iyz7Spw9uevCu8lo5qCMsBptenNJ3OFwLuVEBkMm9EFNAYPB5ZItfccyolyAHcr9XRQ(KrPnPvuKLo()6)Kl7wU4(yv(WA1IrfzO1du7kSVs8Gxa6Ynj7ld5m5fxKIsBvN9Ol4xUcLNwfU9ZUDZRoL9YxDfsz0vSwr99krPEEDrVEuyHS3y5wN8QtKV55s7flNS97R)DjMDraq4ecRZ(iM16bubSYClNmgzMkFyp95Q8nOiqVtyM6qZEjMSUgMT3o6A07ZK97r)5jga1363twEqHcNf(WxuAQMXQVKWagwJ(iGTxn(RFJW6zaMVD0eukWd9xV2aK(wF2MvrHc4ihhOk82MM69m9Wj(dos5MJ4JmIyInoCWBW5yMW(Js7rFq8sjzIAMyK76m3dd9nm2RvA3dJcX3yAjRcyK0W0TaFE4K8)p0ZOjk87rJqnCm1LYow3o6OHj55Kr9OiwwLgDurqMg6PSU1OFT25KS1MW61Zt2WO5lnk9o05A)Id)U2n(uJo5zyrjo0FXETjWgF1aBSfSboB84cSXwquAVytzwZBamANSNF)u6Zv5BqrGMm7ABMCiWgD7igMTJniauNLncWddfol8HVO00lqKWOUOudSb131rfydHJIoKOaoYDEdSPvYnhXhSaBWyJVib2qe(OHaBWOghdSXg3ZuGniJ9ycSbBjlvGn6wGppCYtiWgFxdSr3oMPaBAkpDmWglkcub2qMW(X4KS1MWucSX2TH5x4aBmFV4C7nSZra7dA3i(fA5T)F)]] )


end