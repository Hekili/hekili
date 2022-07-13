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


    spec:RegisterPack( "Survival", 20220713, [[Hekili:L31EZTTrs(plQsfAslzAbitL4CICRnzVkxCLZ3wrPQ9U)HGJahkIZGam4HLzkw4Z(19Gxdg0ZaWhY27EPsjlYzME639V5bGMBn)3NF)swcF(7TV22(6VZ6MXx)2389x)9ZVpz3w(873YC)a7r4xcyBGF(JCwCs2I)t4N8ODyZ78dzlrYehMg5cD5BYwSojzB8p86x)OxY60hg7gU51XEBs9zjEHbUrSvj4NDF987Fi1Zp5xcM)afBC7BEZ87zPjRdJMF)9EB(P53V2B5sEE35XUQ8t2I)J0a4xYE37sd4zlSV5k4hafZEx27(P1SGh5X)q27Ev2IFJ)kEa7bFOt)il6b(YSf3VoeO0phXCHV8VZJ8cxow03)bZZ3l4XYEKUf504XZV33lojwOb5RyP(jWV(EHgL5Ic687DdfSJtmmW53NpHlN)JZta5e7x93unKKiwWFakfV)eMYIbIIAK328o8ZHzlyR5mGJzbWp(9QbaS97)7)u2cEaFJhpge9NGVAzyWlsW)jBrYAV4SfRcJYwS1NTJhbF6bUllng6NxYlwIFe6wi034TSnB2vmhiDCzc6ebZSN)UI5f7h31BLNlm00vRqTcWQGm7XMF)faTyrpYtg7f7KpJOOFJIOxpa3WpcFFqY4pSd(Cq2IbW8gg6Vm8PGXmCQsCcx5KSM78KN)YXr8nmVG4M9lIhhgaEAG6Jfff(uDV2VpBXfyppQzb8WtI8CtqBCTfM577K)bh0Di3PWjpyb6EWh4GlcmM3OXEBKaUlfJDIwfgoWpYDkS4zlUdC3pC(e(i07B79SmlBH1HplU(C2h5ZX56(TrCiPWdS2HmXPB2aJElNmGPSxpeMKaT4ScDQw(eARtc)KxGYyUrEmR85XRfjFu6LQPbzoiFItIhY2wJNifDYICGi0TYANiivdet9iFmKb0x8Bo8nparxJliAUNxD)c4XXal)elAxSGCBfoRB3YIyjPvdJY0BG3EGhN4X8DEciY6wHH(CWHp2f(j6B)GFiKDRI9giIl6wqYnEvU1L2oj(leunXOTRKR(id4bOv838t5yg)vRAhJMUnxjjALigmDRGuLoS7cCDGVIipA3mav4VEMAGjEYykLEkkjrHyI(Ajsn9yHe5TIwMOiuvgRANaDCdM0Rq14W9Jf6Notf68yk4clPr7m17D)LELJTGWebLpVAHCBYZQoGkAUVcLgPrXR7zxeGm)hQzuTOsnmhroelzXzy2c4)lAzCI141SyhaBIdA1Yd1OIZugqj7LTyKOzGKL60Xnd2kBwt87fsK2UN8s7XuZo4yKAusBlbprR0xXQg5jPHxr)LPrcC3G1Bknhu3JrKCrTm0HAzWzJdUOpwnt8XWUyfay)ebGP65rkmlNl000SUO9RbyyTvMDYLNDL5xv6bfBgv4TzPPH8soFJAjYnIZyl31uTson5kKzAL6bAB5UUiDU(OW)2mpQvikMlcZw7sFkmlvhMHlq(85PCO8SkZ2PPXcy2lnzbmlUNU3CBkG5KAhRRt8N1flEKMcDsRzcbKyL3JRtoapMl7IMZArtvpE6IBpt2fL)xOtY3vcCruW6gDw6Xn5woQxcGgued7SaWqLQDLSEN(tZeobeOCOcW7KADL2BePIGwKoFWGo(cbJKunnnDEXJDzUaKva5kZ9ps9I4lHLHZzXPr8cgGAJvKwvx5OEIfuVoqQTjP01qZWgbG79dHLsxdigan)DMbnBBa0CFbQQ18Cgbn3xa8ThJgVfRU9w6YB8zc1bbxuldDOw6SQxV5Gdd0mDsyZSsxvW7z5vdGJOxbIbU8SRm)Qsp85znF6HCqaA2aGKtf0ChL3VOlEuRq8zb08r7PCO8SwqZ6mnFEan3XsE6g0SEX)qbn3xtrNGMjj0jcAMoVuNGMPlU9mzxEoantia9a0mDbGEbAMYF64bn3tVZEaAU79270GbD8fc0bA2(RAqZ25NlfEAPehjL8(LxiZnoQSg(g3CDnCBwGl0ViOF45AsDythnPxbsK4m4mFE4dl0b4ER7eV1dAiM8yNcePowX4sQB6dSQS5M8zruFUHxjp0mPT8hpmqE0h8cEuYVbYTv)HcqlfjlwZz(a536Mi8gUzsDWq(js(bpFFEKdmrjEbUj1hjzDKZdHX5zyv4lGEw3iF8NLSg1Xh91Sof9dCwLgT7RdD6Ts60kwR60RkBYhhySZ)B6Yh3atQYrQR)Ueysp2bNzlXzBdf)RiUpoXCy)qT2vCcRSdnCiuReiNvmI5T0H)ruvZwUmEm)t49aQYkO2C9QVuBPH5wTrVCGgLLHigU42fLTyAzgZwvsRT3A4j1VwwQTERitBvYWwMmZjef25vr8G)CxJyKIVQ2UcS)JUlfQGhe3elXLEY5r8Ey5SvCnSk8miJAr5Engye7SkkNzz(5cW43KlKvxRbOdcN14sXG7VecuavMV8LCO29VMFmNNU7Boroo9IBpYyzVAHWpqYpCLplIR2fIRGIHlvKGeYmy1mxA47KHXi8aUdoZ2tAf9lsmeVg7wpJ7p64MtjOPNKSPBFTuk7SvTVCs64DLohnvcFVC3WKXuD6T9kYrMZ4FI7MMWfx9NYmksab1EZlQDXgkxLG)PT(HXi2lK7AEvLYRMH2y)04KXsRvJcWU51hiDdLEk)IuMZHOsW66JgqfwPcax(s6W)lRf6oU6tiNVkfSrr8CcvOFPIm1Wkge(3QnzIL(6vRcDtJfYG4QEfXFKxSOtSHXByFQMQl5aR4aC(hIyBe0TJuYgk9QrgSKSGXjSnB5l5IzQXTRJ5SjncZMcu2fmVXk(7wDJiRn8jtC1xdfLnwr(Sv6vn2wOo1FNqh2hmnwtkr)qU67(LxzIcckd3BOkuugD0QG6OhhUMeq))exHM3Xt0p4w5Gq31EBy8igvbhRVRvzj3WnBGfvR2XV3CgKMHP17pHbK7Y3sv2JIKprEUFquu16TY81syHXopGxQFfUYwFPIHfzgfBhJBi(8aCzzYYIKNVSPxTS03yZCYTvZY3wIqLoMt6gE80ekFpmkRbnQYR2qwortDDVGRxr5fYq4(d2wFMdpIVmnWbgStiMiwPIUEJJ0AODdFO05bv56lrPFf0AbJBxulnyzQxsb4cEcMSOtG32Dut708izrUmaP72u8AtIZ2PHZxeOFWx1Bs4926RzEcZaaTKlE4sQMgJ1sQrJ0iI6Y881J0bmPqRMegfHBpq(g0L)eayCX6DK)wFUYP5ycWoH8qJ9uCQ28ZVu8atCylYLYl9Frw5R7oWg5KxFogntgx2RG7FvvEneSAUjUrQWRhBprsoWuMO3hHgIMe31WeTj1pXRmXqFIp2gM6Ugf7i2Fgg5uPjASY8Cdu(ZeLZgw0he3i82RHlX0dJt)Nt6vrAC9Z9j1ZZXwmOExuoT9uqsSJ4vRvMK8N0QG0V66VO5xu3qHwR)TJulNHfQ2vFkwxDFxanDkddlU9u0)tor1FB0Z6bw8LKpjxWN(0WDTUEtB2VU12RpZAF2EQ5g2YNg7JO(nrR5cB0TlAnxuJXL)0yx50T)Lnxmsx7PHH1KCyAjiCpcFiRnd6UiJ4mPf5KtGXvfffRrzo9Q8E2bs3APD230VL2PBBS1Kfu3ETDgwacvYmdWJZlfvYiqjP60XnJOvwy1PvM)CUcd9L3pHzO9km0xM34kmU56dBfgGBYhbvf2C(lsGBHezqoOOaGBGO3)XF93E)V8(F(hYwKT43xJp07B2ggLu8mX)IQNk5xakyE(1oiBrCiwMLLMeUHLGFHB(lsGXzV7x9W3YaVbO3pfgaZSO5xuR5(VbcLe28RkvxqtmyM)3)V(1SfdT(0OtNCnOYefQuufVIeLFUVJV3CHQqL9Uo06fxIJ4dtPFBt(dF7qaJAxqcge(T5C4VMYYwS07JEOhr2IqynvSeCoh(AWRA4ejX9wv1vXnFXssJvF9AWVBO9B6X4TjgVDX4VvA8F35vC(UJqCmWo9sCEt)m3Ulpql9nNONSA8u)hFNYs8bMPW(CfurtUTCum(FgpECj1k(9H2sJsvF2BM48KLIwuE7rBKOhVEvH8OSU(eNwBvc0B1qtYyPqMsukveP6l6utAF023Zn9AsMZMdtNrL5BG0)cez2VrD0k2NN6901d7n5Aqf1Yq9Mk0m1XeURHsQk9(LVPv6IEom1z7uspC0wMZn9AsMZMPo7D)IiBasLBlxHC2cX7QlO553JBucUQUBW3MoHR8W31gFZ3KTq3RsmSnIxNy4xx)kfd)0H8AfRO)AE1IH0pNXJhxTOKP1VAKiA9YPVw3lfj6Ex)6qIU9YLjEL8RCOPwJNCL3QP1Mc1LPUFFDBDSWrnsH8Eqqo5xqUJKdUqptjPpHzq(TYgyjaJd4D1RxPA)BFrELQjZ7TF9WvOrIA8Awl3b7VXHpaChZv4JTlmnc560hqxTGepFX3LTynuUe4)0e0bUCRhZw8xX9SdhWtbGFpkIERqjMxVlYWxfxiD(H4yWa1Lut7FdN2Xzl(fGebHy0uyoXI55BkJNqebTtewPwecHeBd4TV4jpqphum34UWhZXHa92NZFIT7QIMI92iMxC3wLM2Qk)E4f5Fxr4xTsnG)0kWNyPdUXR(FKJQu0f6bVGLJvBCWqXwLr8YIA)(oVjmZSUE)(27F1Dw3oQHhQY7rTRW3dqtlxO8v5V51MAH8PYLHzqflO)TZZGozZ97V4iOB3saS2VU7e8VYci2E9UOFND3eih)NbImZsoblWutB(OEKRxnDojZU56geaZNw(iDCuJU(Pxah(qQt8v2OuDNOgOFZ)hqEDtgnyyJnXDMPNTJll)L97h26Pp4UBMaSe9ZCWOr73JBA8GgZ1Dw30sUREcd(Yj3TF(lo7Y9TQYTYJpHAZ5pEdOkrVCsot232W1wejmT9WffnOpFlOao9zBnBkM8sjsAk5bA9sBvEan117M)vn2N98quekmopJBE)jgq(9LI70hDxEPUlpbOGiCNg0(acMzn(ndQrpy(Ysqizvh)ckhah9QM8m11AygERikyWw3iIbDp(7O0WvNswtiA6UncdOU1deKv6q66hHjOrfAsJGhhOE9fUd0MdOV2cyt0mBKOaU01tyGjKHTOqJltasjXzpCz9Tq4UQdJGy0YEBFfgL1(ge0uftwVscydz73zzFjsfsC5u8ydi(hLsAYPOJuH98fGfkpS9JifV1ek3o5ZzxB60sEVXJsIXaEtzziARXjWtz5lp3DI2ADA70E34bLFQcO85IxfHpdp78lZ7RYjQtYjsh2DLvS9bOtAcPSG1hp(HhvtSII3cbTuf6ShqDc4uMYQJSUsdjFs3yAdsp7(LP)O2MGAhu5dyU5eD4eR55ilGHMNXx60OV8MRhjN2VMmXjAGxnKa1QuIuQNmJz2xdWu1MjQvdqLTH6EMfUS9ZRWD2qLLwdqKJAQ1aLf8HizjMpDzdTE7izDIIl7)ucVloP3EZhpUL4KkmlfpVLtTNCmWxY15TtVk((EdkHYf7q9W6bjQ9AARjAx5r0crvNCr7Ol8nyyN7dIWmo8cYNyYc3p5NsYrT33KrKB3ZeZXkDI26LTDY1daB)(Je0hvvffg)OWklgzFbarTzzQQpdiheTtH3Bi5UeqpFp)zL1Ku(KZbRc0EO56pwtWkunCG7tuYK(SZNqTnnwtOOe1o80ku6FwTcAafxNwRajARKcNheM5bQeOlZzUgW8Yr(8kbsyj4pVCOXN4TxznAwbU5wpWCsUgudDMfM4c0W6IhfFDx3arC79Ko(h6hios90nMZetVFKhfW68mvspRzNQjTFqtokG251IpdGSLfAZaSTMObGD5PEmT8vSvXPeK)g)6kXF7cMQ)iz0xBP9ua8QYK04LOzXCPMGu3CBylQjoFLZgFw4UCv42PI)0sCv1HRPY5vYtx53)l94WFY)t(Wv1)fOyA)hKbiaIdz8lTc4Slv9ZO(8imZEMTMKsg(UUZlHVj(kXBUTYJYuS5fdhwF7uLFV41gksZ(vYraSanV1BhmSvy2f13KvZZLshlNmact13lPQlrmtki4ki0mR1dOIyLGuMnLyMkBCK6Cv2dDc4GtyMUqV6vZKn0WS9Qj3r(YsC)EYVEMbs9T2JKTh6yHZIE4ZQmvRyvdjmWH1SpbzhvZ)Q)5MyGbA(QjZiLGbKF7DgO03AJhAQowGM5YbxkRBBNMFGPgHfDCK2TEYpYmIj1O11xsRXmX9hL3J6Ge7kHjPzMrTBV1EuSVHXExdSTgnIxAkKTbzK8WuZaFE0KI)JCvSK0FKEgQvHPH6YJn8cv2WK9C2Kr6ewCfU90rqwgg1iU1yDTdRi5bNctSba1DW8BKw1dN7o7ci2kVozBDiEwdUGSJJoeGn2nb20fydA14XbSPlqukDSTnR9Rxy9fzp)1PuNRYEOtanL2TRzQhaBuZJyy2owqaKflBbWJIfol6HpRY0ZasyYsunb2qw76Oa2OPqXfAzbAM78cS5GSB9KFOa2qPgFwa2Ob(ObGnustpb20L2ZeWgIXEmaBOcz1bSrnd85rtEcaBS7lWg18yMa202E2tGnD4iOdyJ2fSFmfjp4uyna201RA)ZpWgXdo)8)V]] )


end