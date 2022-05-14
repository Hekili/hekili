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


    spec:RegisterPack( "Survival", 20220514, [[dafHZcqisvEePcYLajvBIO8jqIgfH0PiQSkru6vkkMfPQUfiv2fIFjszyGeoMizzkQEMikMgijUgHOTriW3ivGXjIQohPcQ1bsv9ocbvzEkkDpbAFIi)JqqXbjeKfcs5HKk0ejeu5Ieck1gbjjXhbjPAKeck5KGuLwjPsVeKKYmbjLBcssQDsu1pjeuvdfKKKwkijXtjLPks1xbPkASIOI9kQ)sYGHCyQwmbpgPjl0LrTzO6ZkYOfHtlz1GufEnuA2kCBISBP(TsdxqhNqOLRYZbMoLRdQTdfFNqnEsfDEbSEruP5dI9RQZPYPN1IUXz5NdfZNdfImfuHKshav0bIeQK1SaHCwl0Py9joR1UeN10GpmfgFK1c9aJ1J50ZAGf(OCwth6rjmlea9tlTPYsalqORuAGscE4wTn9CClnqjrtlRjaxdd6TZczTOBCw(5qX85qHitbviP0bqfDGiZAoSLyVSMwjPJzTevmYDwiRfzanRPbFykm(4rIWcUn(EDHQ2d8OujJ(pAoumF(R7RRoUng(ShHVuyWJwm8r9WhrtWuSGhz7JogeYu7rnl(r0HdapcWMv9e4rP9iya)OMf)iAcMIvHVuyGAXWh1dFeRZWJbGABswBuadKtpRrhSJHZPNLpvo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1mFWTrseiEoqjugt42fgC8rYEKamoobtfYhqHH7vICSKxn4rYEKamoobtfYhqHH7vICSKxn4rZ(OjAmRrdqhSY8BInqw(uzll)8C6znUDHbhZqlRrVY4R8SMEp68kQymCBepgbewNfWapccKhDEfvmgUnIhJaYXsE1GhLuWhLckEeeipYPwHHvCZsfdEusbF05vuXy42iEmci0fUThLSpAEwZPwTDwtCnIkqyDLbYww(KjNEwJBxyWXm0YA0Rm(kpRP3JoVIkgd3gXJraH1zbmWJGa5rNxrfJHBJ4XiGCSKxn4rjf8rj)JGa5ro1kmSIBwQyWJsk4JoVIkgd3gXJraHUWT9OK9rZZAo1QTZAhd22TQNu(DR4SLLhQKtpRXTlm4ygAzn6vgFLN107rNxrfJHBJ4XiGW6Sag4rqG8OZROIXWTr8yeqowYRg8OKc(OuqXJGa5ro1kmSIBwQyWJsk4JoVIkgd3gXJraHUWT9OK9rZZAo1QTZA0DVy1UXrLdao8WYwwErMtpRXTlm4ygAzn6vgFLN1WHhd1X0e(nXkRK4hn7JMOXhbbYJeGXXjsEujSsc(fl(iWHpccKhjSaWJK9i8AkHPowYRg8OzFKiZAo1QTZAIRreVowjSsczllViiNEwJBxyWXm0YA0Rm(kpRr3DexXnrCnI41XkHvsGqt43edu4NtTABF8OzFuQSMtTA7Sg1pmC2YYRdYPN142fgCmdTSg9kJVYZAI(i9E05vuXy42iEmciSolGbEeeip68kQymCBepgbKJL8QbpkPhjYhbbYJCQvyyf3SuXGhLuWhDEfvmgUnIhJacDHB7rj7JM)i5EeeipIMGPyv4lfgOwm8r9Whj7r69OdUz89MyIGpPwCLeCxwTnGWIiCfgYXSMtTA7SwKDlHIMWXEUu2YYN850ZAC7cdoMHwwJELXx5zTdUz89MysZaq1tI9laqzNhgw9KYdd9ZnyaHfr4kmKJps2JWxkm4rZ(im(vUWGjscQdOOlWYAa7kQLLpvwZPwTDwJ6JHYPwTTAualRnkGPAxIZAT5zllVoCo9SMtTA7SgnHJ9CjqwJBxyWXm0Yww(uqro9Sg3UWGJzOL1Oxz8vEwlUgbK48WMhkHvsGyffB1tps2Je9rX1ivB81(qjmyow9ebyof7JM9rZFeeipkUgbK48WMhkHvsGCSKxn4rZ(OjA8rYL1CQvBN1eGnAc(cKTS8PsLtpRXTlm4ygAzn6vgFLN1IRrajopS5HsyLeiwrXw90JK9i9EeGnLW2WaIv8np5vZdPznNA12znQFy4SLLp18C6znUDHbhZqlRrVY4R8SgnHFtmqHFo1QT9XJs6rZjI8rYEeD3rCf3eX1iIxhRewjbco8yOoMMWVjwzLe)OKEeiKhdL53eBGhL2JMN1CQvBN1eGnAc(cKTS8PsMC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6HznNA12zn8H3yREsbSRWYzllFkOso9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRfxJeMGVvABwjSsceROyRE6rYEeGnLW2WaIv8np5vZdPps2J07rcW44ejpQewjb)IfFe4WSgnaDWkZVj2az5tLTS8Pezo9Sg3UWGJzOL1Oxz8vEwtaghNGp8a8bus(HLahM1CQvBN1WwJHcKyTSLLpLiiNEwJBxyWXm0YAo1QTZA4dpahvGeRL1ObOdwz(nXgilFQSLLpLoiNEwJBxyWXm0YAo1QTZAa(c52uaR6PSg9kJVYZAhJFmiHlm4hj7r69iROyRE6rYEuZ60uIlLWkjqWSd3Qb)izpY8BInIvsSYwvS4hL0JsjYhj7r4lfg8OzEe1bM64jUFuspkze5JK9iNAfgwXnlvm4rZg8rqLSgnaDWkZVj2az5tLTS8Ps(C6znUDHbhZqlRrVY4R8SMEpkUgrCnI41XkHvsGyffB1tps2J07ra2ucBddiwX38KxnpK(iiqE05vuXy42iEmciSolGbEKShj6JOj8BIbk8ZPwTTpEuspkfz(JK9iNAfgwXnlvm4rj9iOYJGa5r0e(nXaf(5uR22hpkPhLIavEKSh5uRWWkUzPIbpkPhLmpccKhrt43edu4NtTABF8OKEukIi4rY9iiqEKEp68kQymCBepgbewNfWaps2JOj8BIbk8ZPwTTpEuspkfrKznNA12znX1iIxhRewjHSLLpLoCo9Sg3UWGJzOL1Oxz8vEwt0hP3JAwNMsCPewjbciX5HnpEeeipsVhz(GBJiUgr86yv14WGABc3UWGJpsUhj7r0DhXvCtexJiEDSsyLei4WJH6yAc)MyLvs8Js6rGqEmuMFtSbEuApAEwZPwTDwta2Oj4lq2YYphkYPN142fgCmdTSg9kJVYZA0DhXvCtexJiEDSsyLei4WJH6yAc)MyLvs8Js6rGqEmuMFtSbEuApAEwZPwTDwJ6hgoBz5NNkNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1Ojykwf(sHbQfdFup8rYEeo8yOoMMWVjwzLe)OzF0en(izps0hDWnJV3etAgaQEsSFbak78WWQNuEyOFUbdiSicxHHC8rYEeD3rCf3e8J5KB1tk78qYXsE1Ghj7r0DhXvCtm)u25HKJL8QbpccKhP3Jo4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbeweHRWqo(i5YA0a0bRm)MydKLpv2YYpFEo9SMtTA7SMRKGViFQfxrVvmiRXTlm4ygAzll)8KjNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OEywZPwTDwdympu25Hzll)COso9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1og)yqcxyWps2JmFWTrseiEoqjugt42fgC8rYEK53eBeRKyLTQyXpkPhL8znAa6GvMFtSbYYNkBz5NlYC6znNA12znQFy4Sg3UWGJzOLTS8Zfb50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrVY4R8SgnbtXQWxkmqTy4J6Hps2Je9rhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihFKShr3DexXnb)yo5w9KYopKCSKxn4rYEeD3rCf3eZpLDEi5yjVAWJGa5r69OdUz89MysZaq1tI9laqzNhgw9KYdd9ZnyaHfr4kmKJpsUSgnaDWkZVj2az5tLTS8Z1b50ZAo1QTZAyRXqbsSwwJBxyWXm0Yww(5jFo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1og)yqcxyWznAa6GvMFtSbYYNkBz5NRdNtpRXTlm4ygAznNA12znPTN2fWkHY4SgnaDWkZVj2az5tLTS8jduKtpRXTlm4ygAznNA12zTZdT9ua7kSCwJgGoyL53eBGS8PYw2YAT550ZYNkNEwZPwTDwdympu25HznUDHbhZqlBz5NNtpRXTlm4ygAzn6vgFLN107rcW44eX1iQaH1vgGCSKxn4rqG8ibyCCI4AevGW6kdqowYRg8izpIU7iUIBc2Amu0vsY7i5yjVAqwZPwTDwd)yo5w9KYopmBz5tMC6znUDHbhZqlRrVY4R8SMEpsaghNiUgrfiSUYaKJL8QbpccKhjaJJtexJOcewxzaYXsE1Ghj7r0DhXvCtWwJHIUssEhjhl5vdYAo1QTZAMFk78WSLTSwKXD4HLtplFQC6znUDHbhZqlRrVY4R8SM53eBKf2avKt(hj7ra2SQNaeyaRs4x4U9JK9ibyCCIdczQPwCLLGvSpnysCf3znNA12zTe(fUBNTS8ZZPN1CQvBN1KGtUj3bN142fgCmdTSLLpzYPN142fgCmdTSMtTA7SMDElIW1OsUvpPajwlRfza9QqR2oRbvFFKNG94J8o(O0pVfr4Aujx(rYdvvD8rCZsfd0)rI5hf3gkThf3hzjkWJW37rHdpaFGhjWuhgWpQmOm(ib(r2Upce6ssbEK3XhjMFe1BO0E0XESgbEu6N3I4JaHmTWl6JeGXXbKSg9kJVYZA69iZVj2ifqfo8a8LTS8qLC6znUDHbhZqlR5uR2oRb9yn4EIR7urgyvhaOO(yK1Oxz8vEwZPwHHvCZsfdEuWhL6rYEKOpsaghNq39Iv7ghvoa4WdJah(iiqEKEpIU7iUIBcD3lwTBCu5aGdpmYXsE1GhbbYJewa4rYEKvsSYwvS4hn7JsgO4rY9iiqEKOpYPwHHvCZsfdEuspk1JK9ibyCCYXGTDR6jLF3kMah(iiqEKamooHU7fR2noQCaWHhgbo8rYL1AxIZAqpwdUN46ovKbw1bakQpgzllViZPN1CQvBN1GbSQmwcK142fgCmdTSLLxeKtpRXTlm4ygAzn6vgFLN1OlgU92iydCL3ps2JO7oIR4Mq39Iv7ghvoa4WdJCSKxn4rYEeD3rCf3KJbB7w1tk)Uvm5yjVAWJGa5r69i6IHBVnc2ax59JK9i6UJ4kUj0DVy1UXrLdao8Wihl5vdYAo1QTZAuFmuo1QTvJcyzTrbmv7sCwZUQXYgiBz51b50ZAC7cdoMHwwZPwTDwJ6JHYPwTTAualRnkGPAxIZA0iiBz5t(C6znUDHbhZqlRrVY4R8SMtTcdR4MLkg8OzFuY8izpY8b3grOUiqT4QWJdq42fgCmRbSROww(uznNA12znQpgkNA12QrbSS2OaMQDjoRjSHzllVoCo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdE0SpkzEKShP3JmFWTreQlculUk84aeUDHbhZAa7kQLLpvwZPwTDwJ6JHYPwTTAualRnkGPAxIZAalBz5tbf50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rj9O5znGDf1YYNkR5uR2oRr9Xq5uR2wnkGL1gfWuTlXzn6GDmC2YYNkvo9SMtTA7SMFuVzLT3XTL142fgCmdTSLTSw4X0vsWTC6z5tLtpRXTlm4ygAzTnmRbyRWZA0Rm(kpRz(GBJiT90Uawjugt42fgCmRfza9QqR2oRPJBJHp7r4lfg8OfdFup8r0emfl4r2(OJbHm1EuZIFeD4aWJaSzvpbEuApcgWpQzXpIMGPyv4lfgOwm8r9WhX6m8yaO2MK1W4NQDjoRjjOoGIUalR5uR2oRHXVYfgCwdJpGzfpaCwZPwTn58qBpfWUcltOlWYAy8bmN1CQvBtK2EAxaRekJj0fyzll)8C6znNA12znaSK02Qq2YAC7cdoMHw2YYNm50ZAo1QTZAcRzdoQWhEaokU6jLT6S6Sg3UWGJzOLTS8qLC6znNA12zn8bdsqph3YAC7cdoMHw2YYlYC6znUDHbhZqlRrVY4R8S2b3m(EtmbSWd89MyfljWhGWIiCfgYXSMtTA7SM5NYopmBz5fb50ZAo1QTZAaJ5HYopmRXTlm4ygAzlBznHnmNEw(u50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwtaghNGPc5dOWW9krowYRg8izps0hjaJJtWuH8buy4ELihl5vdE0SpAIgFeeip6y8JbjCHb)i5YA0a0bRm)MydKLpv2YYppNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1Ojykwf(sHbQfdFup8rYEKamooPzq1tI9laqzNhgw9KYdd9Znyabo8rqG8irFeGnR6jaXhJvScFPWa1IHpQh(iiqEe(sHbpAMhrDGPoEI7hn7JWxkmGi568rZ8OuqXJK7rYEKamooPzq1tI9laqzNhgw9KYdd9Znyabo8rYEKamooPzq1tI9laqzNhgw9KYdd9Znya5yjVAWJM9rt0ywJgGoyL53eBGS8PYww(KjNEwZPwTDwdBngkqI1YAC7cdoMHw2YYdvYPN142fgCmdTSg9kJVYZA0emfRcFPWa1IHpQh(izpchEmuhtt43eRSsIF0SpAIgFeeipsaghNi5rLWkj4xS4JahM1CQvBN1exJiEDSsyLeYwwErMtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBz5fb50ZAo1QTZA4dpahvGeRL142fgCmdTSLLxhKtpRXTlm4ygAzn6vgFLN1o4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbeweHRWqo(izpcFPWGhn7JW4x5cdMijOoGIUalRbSROww(uznNA12znQpgkNA12QrbSS2OaMQDjoR1MNTS8jFo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7SwKDlHIMWXEUu2YYRdNtpRXTlm4ygAznNA12zTZdT9ua7kSCwJELXx5znbyCCcD3lwTBCu5aGdpmcC4JK9ibyCCcD3lwTBCu5aGdpmYXsE1Ghn7Jsre5Js2hnrJznAa6GvMFtSbYYNkBz5tbf50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SMamooHU7fR2noQCaWHhgbo8rYEKamooHU7fR2noQCaWHhg5yjVAWJM9rPiI8rj7JMOXSgnaDWkZVj2az5tLTS8PsLtpR5uR2oR5kj4lYNAXv0BfdYAC7cdoMHw2YYNAEo9Sg3UWGJzOL1CQvBN1op02tbSRWYzn6vgFLN1eGXXjwfQwCLLGvGq2pcWCk2hf8rjtwJgGoyL53eBGS8PYww(ujto9Sg3UWGJzOL1CQvBN1K2EAxaRekJZA0Rm(kpRz(GBJ4JWeUk84OB7r42fgC8rYEKOpsaghNiT90UawHdFbiWHps2JeGXXjsBpTlGv4WxaYXsE1Ghn7JWxkm4rP9irFeg)kxyWejb1bu0fypc6Ee1bM64jUFKCpkzF0en(i5YA0a0bRm)MydKLpv2YYNcQKtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFup8rYEKEpYkk2QNEKShj6JWHhd1X0e(nXkRK4hn7JMOXhbbYJ07rX1iIRreVowjSsceROyRE6rYEKamoorA7PDbSch(cqowYRg8OKEeo8yOoMMWVjwzLe)iO7rPEuY(OjA8rqG8i9EuCnI4AeXRJvcRKaXkk2QNEKShP3JeGXXjsBpTlGv4WxaYXsE1Ghj3JGa5rwjXkBvXIF0SpkvY)izpsVhfxJiUgr86yLWkjqSIIT6PSMtTA7SM4AeXRJvcRKq2YYNsK50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrdqhSY8BInqw(uzn6vgFLN1Ojykwf(sHbQfdFup8rYEKOpsVhDWnJV3etAgaQEsSFbak78WWQNuEyOFUbdiC7cdo(iiqEe(sHbpA2hHXVYfgmrsqDafDb2JKlRfza9QqR2oRb9I)Oal8JIBdL2Js4y4hjpdavpj2Vaqj4rPFEyy1tpsekm0p3Gb6)iqjfoc8iQdShbvRgJhPJRKK3Xhv4pkWc)iXBdL2Jwm8r9WhT9JGQYsHbpc)wPhf3QNEeyjpc6f)rbw4hf3hLWXWpsEgaQEsSFbGsWJs)8WWQNEKiuyOFUbdEuGf(rGel8i(iQdShbvRgJhPJRKK3Xhv4pkWcFpcFPWGhvGhjWJv8JSe8JOlWE0I)iOQ3EAxa)iOvg)O9Eeufp027rA2vy5SLLpLiiNEwJBxyWXm0YAo1QTZAyRXqrxjjVJznAa6GvMFtSbYYNkRrVY4R8SgnbtXQWxkmqTy4J6Hps2Jo4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbeUDHbhFKShr3DexXnb)yo5w9KYopKCSKxn4rj9irFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXhj3JK9i6UJ4kUjMFk78qYXsE1GhL0Je9r4lfg8O0EKOpcJFLlmyIKG6ak6cShbDpI6atD8e3psUhLSpAIgFKCps2Je9r69iZhCBeGX8qzNhs42fgC8rqG8iZhCBeGX8qzNhs42fgC8rYEeD3rCf3eGX8qzNhsowYRg8OKEKOpcFPWGhL2Je9ry8RCHbtKeuhqrxG9iO7ruhyQJN4(rY9OK9rt04JK7rYL1ImGEvOvBN1GEwwIhjpdavpj2Vaqj4rPFEyy1tpsekm0p3GbpA7rGhbvRgJhPJRKK3Xhv4pkWcFpYope8i)4hT9JO7oIR4w)hTwc(exa(raBdFemO6PhbvRgJhPJRKK3Xhv4pkWcFpIcFh32JWxkm4rU0c32JkWJ4EHNs8iBFeagyE1pYsWpYLw42E0I)iRK4hnyC7r479iVd8Of)rbw47r25HGhz7JORe)Ofh)r0DhXvCNTS8P0b50ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZAaJ5HYopmBz5tL850ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwlUgbWxi3Mcyvprog)yqcxyWps2J07rcW44e6UxSA34OYbahEye4WhbbYJmFWTr8rycxfEC0T9iC7cdo(izp6y8JbjCHb)izpsVhjaJJtK2EAxaRWHVae4WSgnaDWkZVj2az5tLTS8P0HZPN1CQvBN1ogSTBvpP87wXznUDHbhZqlBz5Ndf50ZAo1QTZAIRrubcRRmqwJBxyWXm0Yww(5PYPN142fgCmdTSg9kJVYZA69ibyCCcD3lwTBCu5aGdpmcCywZPwTDwJU7fR2noQCaWHhw2YYpFEo9Sg3UWGJzOL1Oxz8vEwtaghNiT90UawHdFbiWHpccKhHVuyWJM5ro1QTjyRXqrxjjVJeQdm1XtC)OKEe(sHbejxNpccKhjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAsBpTlGvcLXzll)8KjNEwJBxyWXm0YAo1QTZANhA7Pa2vy5SgnaDWkZVj2az5tLTS8ZHk50ZAC7cdoMHwwJELXx5zT4AeX1iIxhRewjbYX4hds4cdoR5uR2oRjUgr86yLWkjKTS8Zfzo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1eGXXjyQq(akmCVse4WSgnaDWkZVj2az5tLTSL1SRASSbYPNLpvo9Sg3UWGJzOL12WSgGTSMtTA7Sgg)kxyWznm(aMZAcW44KJbB7w1tk)Uvmbo8rqG8ibyCCcD3lwTBCu5aGdpmcCywdJFQ2L4SgiqtvWHzll)8C6znUDHbhZqlRTHznaBznNA12znm(vUWGZAy8bmN1OlgU92iydCL3ps2JeGXXjhd22TQNu(DRycC4JK9ibyCCcD3lwTBCu5aGdpmcC4JGa5r69i6IHBVnc2ax59JK9ibyCCcD3lwTBCu5aGdpmcCywdJFQ2L4SgWUTNuGanvbhMTS8jto9Sg3UWGJzOL12WSgGTcpR5uR2oRHXVYfgCwdJFQ2L4SgWUTNuGanvDSKxniRrVY4R8SMamooHU7fR2noQCaWHhgjUI7SggFaZkEa4SgD3rCf3e6UxSA34OYbahEyKJL8QbQjygaYAy8bmN1O7oIR4MCmyB3QEs53TIjhl5vdE0SIW8i6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaKTS8qLC6znUDHbhZqlRTHznaBfEwZPwTDwdJFLlm4Sgg)uTlXznGDBpPabAQ6yjVAqwJELXx5znbyCCcD3lwTBCu5aGdpmcCywdJpGzfpaCwJU7iUIBcD3lwTBCu5aGdpmYXsE1a1emdaznm(aMZA0DhXvCtogSTBvpP87wXKJL8QbzllViZPN142fgCmdTS2gM1aSv4znNA12znm(vUWGZAy8t1UeN1abAQ6yjVAqwJELXx5zn6IHBVnc2ax5DwdJpGzfpaCwJU7iUIBcD3lwTBCu5aGdpmYXsE1a1emdaznm(aMZA0DhXvCtogSTBvpP87wXKJL8QbpkjryEeD3rCf3e6UxSA34OYbahEyKJL8QbQjygaYwwErqo9Sg3UWGJzOL1CQvBN1SRASSLkRrVY4R8SMOps0hzx1yzJyPijCGcgWkbyC8hbbYJOlgU92iydCL3ps2JSRASSrSuKeoqr3DexX9JK7rYEKOpcJFLlmycWUTNuGanvbh(izps0hP3JOlgU92iydCL3ps2J07r2vnw2i2CschOGbSsagh)rqG8i6IHBVnc2ax59JK9i9EKDvJLnInNKWbk6UJ4kUFeeipYUQXYgXMtO7oIR4MCSKxn4rqG8i7QglBelfjHduWawjaJJ)izps0hP3JSRASSrS5KeoqbdyLamo(JGa5r2vnw2iwkcD3rCf3Ki85wT9Jsk4JSRASSrS5e6UJ4kUjr4ZTA7hj3JGa5r2vnw2iwkschOO7oIR4(rYEKEpYUQXYgXMts4afmGvcW44ps2JSRASSrSue6UJ4kUjr4ZTA7hLuWhzx1yzJyZj0DhXvCtIWNB12psUhbbYJ07ry8RCHbta2T9KceOPk4Whj7rI(i9EKDvJLnInNKWbkyaReGXXFKShj6JSRASSrSue6UJ4kUjr4ZTA7hbDpsKpA2hHXVYfgmbeOPQJL8QbpccKhHXVYfgmbeOPQJL8QbpkPhzx1yzJyPi0DhXvCtIWNB12pkThn)rY9iiqEKDvJLnInNKWbkyaReGXXFKShj6JSRASSrSuKeoqbdyLamo(JK9i7QglBelfHU7iUIBse(CR2(rjf8r2vnw2i2CcD3rCf3Ki85wT9JK9irFKDvJLnILIq3DexXnjcFUvB)iO7rI8rZ(im(vUWGjGanvDSKxn4rqG8im(vUWGjGanvDSKxn4rj9i7QglBelfHU7iUIBse(CR2(rP9O5psUhbbYJe9r69i7QglBelfjHduWawjaJJ)iiqEKDvJLnInNq3DexXnjcFUvB)OKc(i7QglBelfHU7iUIBse(CR2(rY9izps0hzx1yzJyZj0DhXvCto2JbEKShzx1yzJyZj0DhXvCtIWNB12pc6EKiFuspcJFLlmyciqtvhl5vdEKShHXVYfgmbeOPQJL8QbpA2hzx1yzJyZj0DhXvCtIWNB12pkThn)rqG8i9EKDvJLnInNq3DexXn5ypg4rYEKOpYUQXYgXMtO7oIR4MCSKxn4rq3Je5JM9ry8RCHbta2T9KceOPQJL8Qbps2JW4x5cdMaSB7jfiqtvhl5vdEuspAou8izps0hzx1yzJyPi0DhXvCtIWNB12pc6EKiF0SpcJFLlmyciqtvhl5vdEeeipYUQXYgXMtO7oIR4MCSKxn4rq3Je5JM9ry8RCHbtabAQ6yjVAWJK9i7QglBeBoHU7iUIBse(CR2(rq3JsbfpAMhHXVYfgmbeOPQJL8QbpA2hHXVYfgmby32tkqGMQowYRg8iiqEeg)kxyWeqGMQowYRg8OKEKDvJLnILIq3DexXnjcFUvB)O0E08hbbYJW4x5cdMac0ufC4JK7rqG8i7QglBeBoHU7iUIBYXsE1GhbDpsKpkPhHXVYfgmby32tkqGMQowYRg8izps0hzx1yzJyPi0DhXvCtIWNB12pc6EKiF0SpcJFLlmycWUTNuGanvDSKxn4rqG8i7QglBelfHU7iUIBse(CR2(rZ(i8AkHPowYRg8izpcJFLlmycWUTNuGanvDSKxn4rZ8i7QglBelfHU7iUIBse(CR2(rj9i8AkHPowYRg8iiqEKEpYUQXYgXsrs4afmGvcW44ps2Je9ry8RCHbtabAQ6yjVAWJs6r2vnw2iwkcD3rCf3Ki85wT9Js7rZFeeipcJFLlmyciqtvWHpsUhj3JK7rY9i5EKCpccKhz(nXgXkjwzRkw8JM9ry8RCHbtabAQ6yjVAWJK7rqG8i9EKDvJLnILIKWbkyaReGXXFKShP3JOlgU92iydCL3ps2Je9r2vnw2i2CschOGbSsagh)rYEKOps0hP3JW4x5cdMac0ufC4JGa5r2vnw2i2CcD3rCf3KJL8QbpkPhjYhj3JK9irFeg)kxyWeqGMQowYRg8OKE0CO4rqG8i7QglBeBoHU7iUIBYXsE1GhbDpsKpkPhHXVYfgmbeOPQJL8QbpsUhj3JGa5r69i7QglBeBojHduWawjaJJ)izps0hP3JSRASSrS5Keoqr3DexX9JGa5r2vnw2i2CcD3rCf3KJL8QbpccKhzx1yzJyZj0DhXvCtIWNB12pkPGpYUQXYgXsrO7oIR4MeHp3QTFKCpsUhj3JK9irFKEpYUQXYgXsrkaH60eSAXvoveHRJJk7yhaFm4rqG8iNAfgwXnlvm4rZ(O5ps2JeGXXjoveHRJJkXEhjWHpccKh5uRWWkUzPIbpkPhL6rYEKEpsaghN4ureUooQe7DKah(i5YAGXAGSMDvJLTuzllVoiNEwJBxyWXm0YAo1QTZA2vnw2MN1Oxz8vEwt0hj6JSRASSrS5KeoqbdyLamo(JGa5r0fd3EBeSbUY7hj7r2vnw2i2CschOO7oIR4(rY9izps0hHXVYfgmby32tkqGMQGdFKShj6J07r0fd3EBeSbUY7hj7r69i7QglBelfjHduWawjaJJ)iiqEeDXWT3gbBGR8(rYEKEpYUQXYgXsrs4afD3rCf3pccKhzx1yzJyPi0DhXvCtowYRg8iiqEKDvJLnInNKWbkyaReGXXFKShj6J07r2vnw2iwkschOGbSsagh)rqG8i7QglBeBoHU7iUIBse(CR2(rjf8r2vnw2iwkcD3rCf3Ki85wT9JK7rqG8i7QglBeBojHdu0DhXvC)izpsVhzx1yzJyPijCGcgWkbyC8hj7r2vnw2i2CcD3rCf3Ki85wT9Jsk4JSRASSrSue6UJ4kUjr4ZTA7hj3JGa5r69im(vUWGja72Esbc0ufC4JK9irFKEpYUQXYgXsrs4afmGvcW44ps2Je9r2vnw2i2CcD3rCf3Ki85wT9JGUhjYhn7JW4x5cdMac0u1XsE1GhbbYJW4x5cdMac0u1XsE1GhL0JSRASSrS5e6UJ4kUjr4ZTA7hL2JM)i5EeeipYUQXYgXsrs4afmGvcW44ps2Je9r2vnw2i2CschOGbSsagh)rYEKDvJLnInNq3DexXnjcFUvB)OKc(i7QglBelfHU7iUIBse(CR2(rYEKOpYUQXYgXMtO7oIR4MeHp3QTFe09ir(OzFeg)kxyWeqGMQowYRg8iiqEeg)kxyWeqGMQowYRg8OKEKDvJLnInNq3DexXnjcFUvB)O0E08hj3JGa5rI(i9EKDvJLnInNKWbkyaReGXXFeeipYUQXYgXsrO7oIR4MeHp3QTFusbFKDvJLnInNq3DexXnjcFUvB)i5EKShj6JSRASSrSue6UJ4kUjh7Xaps2JSRASSrSue6UJ4kUjr4ZTA7hbDpsKpkPhHXVYfgmbeOPQJL8Qbps2JW4x5cdMac0u1XsE1Ghn7JSRASSrSue6UJ4kUjr4ZTA7hL2JM)iiqEKEpYUQXYgXsrO7oIR4MCShd8izps0hzx1yzJyPi0DhXvCtowYRg8iO7rI8rZ(im(vUWGja72Esbc0u1XsE1Ghj7ry8RCHbta2T9KceOPQJL8QbpkPhnhkEKShj6JSRASSrS5e6UJ4kUjr4ZTA7hbDpsKpA2hHXVYfgmbeOPQJL8QbpccKhzx1yzJyPi0DhXvCtowYRg8iO7rI8rZ(im(vUWGjGanvDSKxn4rYEKDvJLnILIq3DexXnjcFUvB)iO7rPGIhnZJW4x5cdMac0u1XsE1Ghn7JW4x5cdMaSB7jfiqtvhl5vdEeeipcJFLlmyciqtvhl5vdEuspYUQXYgXMtO7oIR4MeHp3QTFuApA(JGa5ry8RCHbtabAQco8rY9iiqEKDvJLnILIq3DexXn5yjVAWJGUhjYhL0JW4x5cdMaSB7jfiqtvhl5vdEKShj6JSRASSrS5e6UJ4kUjr4ZTA7hbDpsKpA2hHXVYfgmby32tkqGMQowYRg8iiqEKDvJLnInNq3DexXnjcFUvB)OzFeEnLWuhl5vdEKShHXVYfgmby32tkqGMQowYRg8OzEKDvJLnInNq3DexXnjcFUvB)OKEeEnLWuhl5vdEeeipsVhzx1yzJyZjjCGcgWkbyC8hj7rI(im(vUWGjGanvDSKxn4rj9i7QglBeBoHU7iUIBse(CR2(rP9O5pccKhHXVYfgmbeOPk4Whj3JK7rY9i5EKCpsUhbbYJm)MyJyLeRSvfl(rZ(im(vUWGjGanvDSKxn4rY9iiqEKEpYUQXYgXMts4afmGvcW44ps2J07r0fd3EBeSbUY7hj7rI(i7QglBelfjHduWawjaJJ)izps0hj6J07ry8RCHbtabAQco8rqG8i7QglBelfHU7iUIBYXsE1GhL0Je5JK7rYEKOpcJFLlmyciqtvhl5vdEuspAou8iiqEKDvJLnILIq3DexXn5yjVAWJGUhjYhL0JW4x5cdMac0u1XsE1Ghj3JK7rqG8i9EKDvJLnILIKWbkyaReGXXFKShj6J07r2vnw2iwkschOO7oIR4(rqG8i7QglBelfHU7iUIBYXsE1GhbbYJSRASSrSue6UJ4kUjr4ZTA7hLuWhzx1yzJyZj0DhXvCtIWNB12psUhj3JK7rYEKOpsVhzx1yzJyZjfGqDAcwT4kNkIW1XrLDSdGpg8iiqEKtTcdR4MLkg8OzF08hj7rcW44eNkIW1XrLyVJe4WhbbYJCQvyyf3SuXGhL0Js9izpsVhjaJJtCQicxhhvI9osGdFKCznWynqwZUQXY28SLLp5ZPN142fgCmdTSw7sCwd6XAW9ex3PImWQoaqr9XiR5uR2oRb9yn4EIR7urgyvhaOO(yKTSL1awo9S8PYPN142fgCmdTSg9kJVYZA0emfRcFPWa1IHpQh(izps0hP3JoVIkgd3gXJraH1zbmWJGa5r69OZROIXWTr8yeqGdFKShDEfvmgUnIhJase(CR2(rZ8OZROIXWTr8yeqQ(rZ(ir(i5Eeeip68kQymCBepgbe4Whj7rNxrfJHBJ4XiGCSKxn4rj9iOcuK1CQvBN1ISBju0eo2ZLYww(550ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwtVhfxJa4lKBtbSQNiwrXw90JK9iZVj2iwjXkBvXIFuspsh8izps0hP3JIRrctW3kTnRewjbIvuSvp9iiqEKamoorYJkHvsWVyXhbo8rYEuZ60uIlLWkjqctW3kTn)i5EeeipsaghNGPc5dOWW9krGdFKShjaJJtWuH8buy4ELihl5vdE0SpAIgFeeipsVhbytjSnmGyfFZtE18q6JK9i9EuCncGVqUnfWQEIyffB1tps2Jm)MyJyLeRSvfl(rj9iDqwJgGoyL53eBGS8PYww(KjNEwZPwTDwdF4b4OcKyTSg3UWGJzOLTS8qLC6znUDHbhZqlRrVY4R8SMEp68kQymCBepgbewNfWapccKhP3JoVIkgd3gXJrabo8rYEKOp68kQymCBepgbKi85wT9JM5rNxrfJHBJ4XiGu9JM9rZHIhbbYJoVIkgd3gXJraHUWT9OGpk1JK7rqG8OZROIXWTr8yeqGdFKShDEfvmgUnIhJaYXsE1GhL0JGkqXJGa5rcla8izpYkjwzRkw8JM9rPGISMtTA7S2XGTDR6jLF3koBz5fzo9Sg3UWGJzOL1Oxz8vEwtVhDEfvmgUnIhJacRZcyGhbbYJ07rNxrfJHBJ4XiGah(izp68kQymCBepgbKi85wT9JM5rNxrfJHBJ4XiGu9JM9rZHIhbbYJoVIkgd3gXJrabo8rYE05vuXy42iEmcihl5vdEuspAou8iiqEKWcaps2JSsIv2QIf)OzF0COiR5uR2oRjUgrfiSUYazllViiNEwJBxyWXm0YA0Rm(kpRP3JoVIkgd3gXJraH1zbmWJGa5r0fd3EBKUMsykCNFKShr3DexXnrCnIkqyDLbihl5vdEeeipsVhrxmC7Tr6AkHPWD(rYEKOpsVhDEfvmgUnIhJacC4JK9OZROIXWTr8yeqIWNB12pAMhDEfvmgUnIhJas1pA2hLmqXJGa5rNxrfJHBJ4XiGah(izp68kQymCBepgbKJL8QbpkPhnhkEeeipsVhDEfvmgUnIhJacC4JK7rqG8iHfaEKShzLeRSvfl(rZ(OKbkYAo1QTZA0DVy1UXrLdao8WYwwEDqo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7Sg(WBSvpPa2vy5SLLp5ZPN1CQvBN1CLe8f5tT4k6TIbznUDHbhZqlBz51HZPN142fgCmdTSg9kJVYZA4WJH6yAc)MyLvs8JM9rZFuY(OjA8rYEeGnLW2WaIv8np5vZdPpccKhjaJJtK8OsyLe8lw8rGdFeeipsVhbytjSnmGyfFZtE18q6JK9irFeo8yOoMMWVjwzLe)OzF0en(iiqEenbtXQWxkmqTy4J6Hps2Je9rnRttjUucRKabZoCRg8JK9O4AeaFHCBkGv9eXkk2QNEKShfxJa4lKBtbSQNihJFmiHlm4hbbYJAwNMsCPewjbsyc(wPT5hj7r69ibyCCI02t7cyfo8fGah(izps0hbyZQEcq8XyfRWxkmqTy4J6HpccKhHVuyWJM5ruhyQJN4(rZ(i8LcdisUoFe09iNA12eS1yOORKK3rc1bM64jUFuY(OK5rY9i5EeeipsybGhj7rwjXkBvXIF0Spkfu8i5YAo1QTZAIRreVowjSsczllFkOiNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1aSPe2ggqSIV5jVAEi9rYEuCnsyc(wPTzLWkjqSIIT6Phj7r69ibyCCIKhvcRKGFXIpcCywJgGoyL53eBGS8PYww(uPYPN1CQvBN1WwJHcKyTSg3UWGJzOLTS8PMNtpRXTlm4ygAzn6vgFLN1CQvyyf3SuXGhL0Js9izpsVhDWnJV3etUadhlW8bw(ak624lChREsbSRWYaclIWvyihZAo1QTZAu)WWzllFQKjNEwJBxyWXm0YA0Rm(kpR5uRWWkUzPIbpkPhL6rYEKEp6GBgFVjMCbgowG5dS8bu0TXx4ow9KcyxHLbeweHRWqo(izpIU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsIFuspceYJHY8BInWJK9irFenHFtmqHFo1QT9XJs6rZjI8rqG8O4AeqIZdBEOewjbIvuSvp9i5YAo1QTZAcWgnbFbYww(uqLC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6HznNA12znGX8qzNhMTS8Pezo9Sg3UWGJzOL1CQvBN1K2EAxaRekJZA0Rm(kpRz(GBJ4JWeUk84OB7r42fgC8rYEKOpsaghNiT90UawHdFbiWHps2JeGXXjsBpTlGv4WxaYXsE1Ghn7JWxkm4rP9irFeg)kxyWejb1bu0fypc6Ee1bM64jUFKCpkzF0en(izpsVhjaJJtexJOcewxzaYXsE1GhbbYJeGXXjsBpTlGv4WxaYXsE1Ghj7rnRttjUucRKajmbFR028JKlRrdqhSY8BInqw(uzllFkrqo9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRHdpgQJPj8BIvwjXpA2hnrJps2JOjykwf(sHbQfdFupmRrdqhSY8BInqw(uzllFkDqo9Sg3UWGJzOL1CQvBN1op02tbSRWYzn6vgFLN1eGXXjwfQwCLLGvGq2pcWCk2hf8rjZJGa5rX1iGeNh28qjSsceROyREkRrdqhSY8BInqw(uzllFQKpNEwJBxyWXm0YA0Rm(kpRfxJasCEyZdLWkjqSIIT6PSMtTA7SM02t7cyLqzC2YYNshoNEwJBxyWXm0YAo1QTZAa(c52uaR6PSg9kJVYZAhJFmiHlm4hj7rMFtSrSsIv2QIf)OKEKo4rqG8ibyCCcMkKpGcd3RebomRrdqhSY8BInqw(uzll)COiNEwJBxyWXm0YA0Rm(kpR1SonL4sjSsceqIZdBE8izpcFPWGhL0JW4x5cdMijOoGIUa7rj7JM)izpkUgbWxi3McyvprowYRg8OKEKiFuY(OjA8rYEKEpcWMsyByaXk(MN8Q5H0SMtTA7SM4AeXRJvcRKq2YYppvo9SMtTA7SgnHJ9CjqwJBxyWXm0Yww(5ZZPN142fgCmdTSMtTA7Sg2Amu0vsY7ywJELXx5znAcMIvHVuyGAXWh1dZA0a0bRm)MydKLpv2YYppzYPN142fgCmdTSg9kJVYZAhCZ47nXKlWWXcmFGLpGIUn(c3XQNua7kSmGWIiCfgYXSMtTA7SM4AeXRJvcRKq2YYphQKtpRXTlm4ygAznNA12znPTN2fWkHY4Sg9kJVYZAcW44ePTN2fWkC4labo8rqG8i8LcdE0mpYPwTnbBngk6kj5DKqDGPoEI7hL0JWxkmGi568rq3JsjYhbbYJIRrajopS5HsyLeiwrXw90JGa5rcW44eX1iQaH1vgGCSKxniRrdqhSY8BInqw(uzll)CrMtpRXTlm4ygAznNA12zTZdT9ua7kSCwJgGoyL53eBGS8PYww(5IGC6znUDHbhZqlRrVY4R8SMOpQzDAkXLsyLeiy2HB1GFKShfxJa4lKBtbSQNiwrXw90JGa5rnRttjUucRKajmbFR028JGa5rnRttjUucRKabK48WMhps2JWxkm4rj9ircfpsUhj7r69iaBkHTHbeR4BEYRMhsZAo1QTZAIRreVowjSsczlBznAeKtplFQC6znUDHbhZqlRrVY4R8SM5dUnIXNeqT4kUN8jwIBJWTlm44JK9i8LcdE0SpcFPWaIKRZSMtTA7Swc)c3TZww(550ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcCywZPwTDwtySBuHdFbYww(KjNEwJBxyWXm0YA0Rm(kpRjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAEtzGD(qr9XiBz5Hk50ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcCywZPwTDwdVowySBmBz5fzo9SMtTA7S2OMsyaf0d44Ke3wwJBxyWXm0YwwErqo9Sg3UWGJzOL1Oxz8vEwJU7iUIBc2Amu0vsY7ibhEmuhtt43eRSsIFuspAIgZAo1QTZAc(KAXv2vuSGSLLxhKtpRXTlm4ygAzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHpccKhzLeRSvfl(rZ(OujtwZPwTDwtGpaFyREkBz5t(C6znNA12znj4KBYDWznUDHbhZqlBz51HZPN142fgCmdTSg9kJVYZAcla8izpcVMsyQJL8QbpA2hnxKpccKhjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAHRvBNTS8PGIC6znUDHbhZqlRrVY4R8SMOpcFPWGhn7J0bqXJGa5r0DhXvCtO7EXQDJJkhaC4HrowYRg8OzF0en(i5EKShj6Jal8qO6ijegyWdwXhCOvBt42fgC8rqG8iWcpeQosWSd3QbRa7ad3gHBxyWXhj7rcW44em7WTAWkWoWWTrIR4(rYL1CQvBN1Whmib9CClRvTX3bhAQcpRrt4DZJQNKPhyHhcvhjHWadEWk(GdTA7SLLpvQC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6Hps2Jo4MX3BIjGfEGV3eRyjb(aeweHRWqo(izpY8tzNhsowYRg8OzF0en(izpIU7iUIBc(WpMCSKxn4rZ(OjA8rYEKOpYPwHHvCZsfdEuspk1JGa5ro1kmSIBwQyWJc(Oups2JSsIv2QIf)OKEKiFuY(OjA8rYL1CQvBN1m)u25HzllFQ550ZAC7cdoMHwwZPwTDwdF4hN1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rMFk78qcC4JK9OdUz89MycyHh47nXkwsGpaHfr4kmKJps2JSsIv2QIf)OKEeu5rj7JMOXS2OAwrJzT5ImBz5tLm50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7Sg2AmuGeRLTS8PGk50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7SM02t7cyLqzC2YYNsK50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7S25H2EkGDfwoBz5tjcYPN142fgCmdTSg9kJVYZAMFtSrIfW8MYpkPGpseK1CQvBN1Cqitn1IRSeSI9PbNTSLTSgg(a12z5NdfZNdfIekMN1e7xx9eiRb9uecQI8qVYdvh6)OhLEc(rLu4E2JW37rqPDvJLnau(OJfr4644JaRe)ih2wj344JOj8EIbKxxOw18Jebq)hPJBJHpJJpsRK0Xhbc0MRZhb1FKTpcQb7pkwykqT9J2q(CBVhjAAY9irfPoLJ86c1QMFKia6)iDCBm8zC8rqPDvJLnsksYbkFKTpckTRASSrSuKKdu(irNdv0PCKxxOw18Jebq)hPJBJHpJJpckTRASSrMtsoq5JS9rqPDvJLnInNKCGYhj6CrGoLJ86c1QMFKoa6)iDCBm8zC8rALKo(iqG2CD(iO(JS9rqny)rXctbQTF0gYNB79irttUhjQi1PCKxxOw18J0bq)hPJBJHpJJpckTRASSrsrsoq5JS9rqPDvJLnILIKCGYhj6CrGoLJ86c1QMFKoa6)iDCBm8zC8rqPDvJLnYCsYbkFKTpckTRASSrS5KKdu(irNdv0PCKx3xxONIqqvKh6vEO6q)h9O0tWpQKc3ZEe(EpckdpMUscUbLp6yreUoo(iWkXpYHTvYno(iAcVNya51fQvn)Ouq)hPJBJHpJJpcknFWTrsoq5JS9rqP5dUnsYHWTlm4iu(i3EKiSfHpu7rIMsNYrEDFDHEkcbvrEOx5HQd9F0Jspb)OskCp7r479iOeyq5JoweHRJJpcSs8JCyBLCJJpIMW7jgqEDHAvZpkLiH(psh3gdFghFKwjPJpceOnxNpcQ)iBFeud2FuSWuGA7hTH852Eps00K7rIMsNYrEDFDHEkcbvrEOx5HQd9F0Jspb)OskCp7r479iOKgbq5JoweHRJJpcSs8JCyBLCJJpIMW7jgqEDHAvZpkfua9FKoUng(mo(iOeSWdHQJKKdu(iBFeucw4Hq1rsYHWTlm4iu(irNRt5iVUqTQ5hLkzG(psh3gdFghFKwjPJpceOnxNpcQ)iBFeud2FuSWuGA7hTH852Eps00K7rIMsNYrEDHAvZpkfub6)iDCBm8zC8rALKo(iqG2CD(iO(JS9rqny)rXctbQTF0gYNB79irttUhjAkDkh51fQvn)OuIe6)iDCBm8zC8rALKo(iqG2CD(iO(JS9rqny)rXctbQTF0gYNB79irttUhjAkDkh5191f6Pieuf5HELhQo0)rpk9e8JkPW9ShHV3JGsHnekF0XIiCDC8rGvIFKdBRKBC8r0eEpXaYRluRA(rPsgO)J0XTXWNXXhPvs64JabAZ15JG6pY2hb1G9hflmfO2(rBiFUT3Jenn5EKOP0PCKxxOw18JsjsO)J0XTXWNXXhbLhCZ47nXKKdu(iBFeuEWnJV3etsoeUDHbhHYhjAkDkh51fQvn)OuIaO)J0XTXWNXXhPvs64JabAZ15JG6pY2hb1G9hflmfO2(rBiFUT3Jenn5EKOjJoLJ86c1QMFukra0)r642y4Z44JGsZhCBKKdu(iBFeuA(GBJKCiC7cdocLps056uoYRluRA(rPebq)hPJBJHpJJpckp4MX3BIjjhO8r2(iO8GBgFVjMKCiC7cdocLps0u6uoYRluRA(rPsEO)J0XTXWNXXhbLMp42ijhO8r2(iO08b3gj5q42fgCekFKOP0PCKx3xxONIqqvKh6vEO6q)h9O0tWpQKc3ZEe(EpckPd2XWq5JoweHRJJpcSs8JCyBLCJJpIMW7jgqEDHAvZpk1CO)J0XTXWNXXhPvs64JabAZ15JG6pY2hb1G9hflmfO2(rBiFUT3Jenn5EKOP0PCKxxOw18JsPdd9FKoUng(mo(iTsshFeiqBUoFeu)r2(iOgS)OyHPa12pAd5ZT9EKOPj3JenLoLJ86c1QMF0COa6)iDCBm8zC8rALKo(iqG2CD(iO(JS9rqny)rXctbQTF0gYNB79irttUhjAkDkh5191f6vkCpJJpk5FKtTA7hnkGbiVUzTWBXRbN10HEKg8HPW4Jhjcl42471vh6rqv7bEuQKr)hnhkMp)191vh6r642y4ZEe(sHbpAXWh1dFenbtXcEKTp6yqitTh1S4hrhoa8iaBw1tGhL2JGb8JAw8JOjykwf(sHbQfdFup8rSodpgaQTjVUVUo1QTbKWJPRKGBZemnm(vUWG1VDjoOKG6ak6cm93WGa2kC9X4dyoOtTABI02t7cyLqzmHUatFm(aMv8aWbDQvBtop02tbSRWYe6cm9PBhlR2oO5dUnI02t7cyLqz8RRtTABaj8y6kj42mbtdaljTTkKTxxNA12as4X0vsWTzcMMWA2GJk8HhGJIREszRoR(11PwTnGeEmDLeCBMGPHpyqc6542RRtTABaj8y6kj42mbtZ8tzNhQFHh8GBgFVjMaw4b(EtSILe4dqyreUcd54RRtTABaj8y6kj42mbtdympu25HVUVUo1QTbbt4x4UT(fEqZVj2ilSbQiN8YaSzvpbiWawLWVWDBzcW44eheYutT4klbRyFAWK4kUFDDQvBdMjyAsWj3K7GFD1HEeu99rEc2JpY74Js)8weHRrLC5hjpuv1XhXnlvmqeEpsm)O42qP9O4(ilrbEe(EpkC4b4d8ibM6Wa(rLbLXhjWpY29rGqxskWJ8o(iX8JOEdL2Jo2J1iWJs)8weFeiKPfErFKamooG866uR2gmtW0SZBreUgvYT6jfiXA6x4b1Z8BInsbuHdpaFVUo1QTbZemnyaRkJL0VDjoi0J1G7jUUtfzGvDaGI6JH(fEqNAfgwXnlvmiykzIkaJJtO7EXQDJJkhaC4HrGdHarp6UJ4kUj0DVy1UXrLdao8Wihl5vdGarybazwjXkBvXINnzGc5GaruNAfgwXnlvmiPuYeGXXjhd22TQNu(DRycCieicW44e6UxSA34OYbahEye4q5EDDQvBdMjyAWawvglbED1H0HEKiC8Wd8iCNw90JcSW3JIlSG9i42QXJcSWpkHJHFuiS9iOkmyB3QE6rIq3TIFuCf36)O9EuH)ilb)i6UJ4kUFubEKT7JgBp9iBFuKhEGhH70QNEuGf(EKiClSGrEe0l(J6T5hT4pYsWa(r0TJLvBdEKF8JCHb)iBFKeBpsCzjQ(rwc(rPGIhby62rWJgml2dO)JSe8JaL0JWDkdEuGf(EKiClSG9ih2wj3kQpgbiVU6q6qpYPwTnyMGP1Sy8fUJQJb7adRFHheSWdHQJKMfJVWDuDmyhyyzIkaJJtogSTBvpP87wXe4qiqO7oIR4MCmyB3QEs53TIjhl5vdskfuabI53eBeRKyLTQyXZMsei3RRtTABWmbtJ6JHYPwTTAuat)2L4G2vnw2a6x4bPlgU92iydCL3YO7oIR4Mq39Iv7ghvoa4WdJCSKxnqgD3rCf3KJbB7w1tk)Uvm5yjVAaei6rxmC7TrWg4kVLr3DexXnHU7fR2noQCaWHhg5yjVAWRRtTABWmbtJ6JHYPwTTAuat)2L4G0i411PwTnyMGPr9Xq5uR2wnkGPF7sCqHnuFGDf1cMs)cpOtTcdR4MLkgmBYiZ8b3grOUiqT4QWJdq42fgC811PwTnyMGPr9Xq5uR2wnkGPF7sCqGPpWUIAbtPFHh0PwHHvCZsfdMnzKPN5dUnIqDrGAXvHhhGWTlm44RRtTABWmbtJ6JHYPwTTAuat)2L4G0b7yy9b2vulyk9l8Go1kmSIBwQyqsZFDDQvBdMjyA(r9Mv2Eh32R7RRtTABaryddc4lKBtbSQN0NgGoyL53eBGGP0VWdkaJJtWuH8buy4ELihl5vdKjQamoobtfYhqHH7vICSKxny2jAecKJXpgKWfgSCVUo1QTbeHnCMGPHTgdfDLK8oQpnaDWkZVj2abtPFHhKMGPyv4lfgOwm8r9qzcW44KMbvpj2VaaLDEyy1tkpm0p3Gbe4qiqefWMv9eG4JXkwHVuyGAXWh1dHabFPWGzOoWuhpX9S4lfgqKCDotkOqozcW44KMbvpj2VaaLDEyy1tkpm0p3Gbe4qzcW44KMbvpj2VaaLDEyy1tkpm0p3GbKJL8QbZorJVUo1QTbeHnCMGPHTgdfiXAVUo1QTbeHnCMGPjUgr86yLWkjOFHhKMGPyv4lfgOwm8r9qz4WJH6yAc)MyLvs8St0ieicW44ejpQewjb)IfFe4WxxNA12aIWgotW0WhEJT6jfWUclRFHhKMGPyv4lfgOwm8r9WxxNA12aIWgotW0WhEaoQajw711PwTnGiSHZemnQpgkNA12Qrbm9BxId2MRpWUIAbtPFHh8GBgFVjM0mau9Ky)cau25HHvpP8Wq)CdgqyreUcd5Om8LcdMfJFLlmyIKG6ak6cSxxNA12aIWgotW0ISBju0eo2ZL0VWdstWuSk8Lcdulg(OE4RRtTABarydNjyANhA7Pa2vyz9PbOdwz(nXgiyk9l8GcW44e6UxSA34OYbahEye4qzcW44e6UxSA34OYbahEyKJL8QbZMIiYKDIgFDDQvBdicB4mbttA7PDbSsOmwFAa6GvMFtSbcMs)cpOamooHU7fR2noQCaWHhgbouMamooHU7fR2noQCaWHhg5yjVAWSPiImzNOXxxNA12aIWgotW0CLe8f5tT4k6TIbVUo1QTbeHnCMGPDEOTNcyxHL1NgGoyL53eBGGP0VWdkaJJtSkuT4klbRaHSFeG5uSbtMxxNA12aIWgotW0K2EAxaRekJ1NgGoyL53eBGGP0VWdA(GBJ4JWeUk84OB7r42fgCuMOcW44ePTN2fWkC4labouMamoorA7PDbSch(cqowYRgml(sHbqDrX4x5cdMijOoGIUad6OoWuhpXTCj7enk3RRtTABarydNjyAIRreVowjSsc6x4bPjykwf(sHbQfdFupuMEwrXw9KmrXHhd1X0e(nXkRK4zNOriq0lUgrCnI41XkHvsGyffB1tYeGXXjsBpTlGv4WxaYXsE1GKWHhd1X0e(nXkRKyOlvYorJqGOxCnI4AeXRJvcRKaXkk2QNKPNamoorA7PDbSch(cqowYRgiheiwjXkBvXINnvYltV4AeX1iIxhRewjbIvuSvp96Qd9iOx8hfyHFuCBO0Euchd)i5zaO6jX(fakbpk9ZddRE6rIqHH(5gmq)hbkPWrGhrDG9iOA1y8iDCLK8o(Oc)rbw4hjEBO0E0IHpQh(OTFeuvwkm4r43k9O4w90Jal5rqV4pkWc)O4(Oeog(rYZaq1tI9laucEu6Nhgw90JeHcd9ZnyWJcSWpcKyHhXhrDG9iOA1y8iDCLK8o(Oc)rbw47r4lfg8Oc8ibESIFKLGFeDb2Jw8hbv92t7c4hbTY4hT3JGQ4H2EpsZUcl)66uR2gqe2WzcMg2Amu0vsY7O(0a0bRm)MydemL(fEqAcMIvHVuyGAXWh1dLjQEhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaiqWxkmywm(vUWGjscQdOOlWK71vh6rqpllXJKNbGQNe7xaOe8O0ppmS6Phjcfg6NBWGhT9iWJGQvJXJ0XvsY74Jk8hfyHVhzNhcEKF8J2(r0DhXvCR)JwlbFIla)iGTHpcgu90JGQvJXJ0XvsY74Jk8hfyHVhrHVJB7r4lfg8ixAHB7rf4rCVWtjEKTpcadmV6hzj4h5slCBpAXFKvs8JgmU9i89EK3bE0I)Oal89i78qWJS9r0vIF0IJ)i6UJ4kUFDDQvBdicB4mbtdBngk6kj5DuFAa6GvMFtSbcMs)cpinbtXQWxkmqTy4J6HYo4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbYO7oIR4MGFmNCREszNhsowYRgKKO4lfga1ffJFLlmyIKG6ak6cmOJ6atD8e3YLSt0OCYO7oIR4My(PSZdjhl5vdssu8LcdG6IIXVYfgmrsqDafDbg0rDGPoEIB5s2jAuozIQN5dUncWyEOSZdHaX8b3gbympu25HYO7oIR4MamMhk78qYXsE1GKefFPWaOUOy8RCHbtKeuhqrxGbDuhyQJN4wUKDIgLtUxxNA12aIWgotW0agZdLDEO(fEqAcMIvHVuyGAXWh1dFDDQvBdicB4mbtdWxi3McyvpPpnaDWkZVj2abtPFHhmUgbWxi3Mcyvprog)yqcxyWY0taghNq39Iv7ghvoa4WdJahcbI5dUnIpct4QWJJUTNSJXpgKWfgSm9eGXXjsBpTlGv4WxacC4RRtTABarydNjyAhd22TQNu(DR4xxNA12aIWgotW0exJOcewxzGxxNA12aIWgotW0O7EXQDJJkhaC4HPFHhupbyCCcD3lwTBCu5aGdpmcC4RRtTABarydNjyAsBpTlGvcLX6x4bfGXXjsBpTlGv4WxacCiei4lfgmJtTABc2Amu0vsY7iH6atD8e3jHVuyarY1jeicW44e6UxSA34OYbahEye4WxxNA12aIWgotW0op02tbSRWY6tdqhSY8BInqWuVUo1QTbeHnCMGPjUgr86yLWkjOFHhmUgrCnI41XkHvsGCm(XGeUWGFDDQvBdicB4mbtdWxi3McyvpPpnaDWkZVj2abtPFHhuaghNGPc5dOWW9krGdFDFDDQvBdi0iiyc)c3T1VWdA(GBJy8jbulUI7jFIL42iC7cdokdFPWGzXxkmGi56811PwTnGqJGzcMMWy3Och(cOFHhuaghNq39Iv7ghvoa4WdJah(66uR2gqOrWmbtZBkdSZhkQpg6x4bfGXXj0DVy1UXrLdao8WiWHVUo1QTbeAemtW0WRJfg7g1VWdkaJJtO7EXQDJJkhaC4HrGdFDDQvBdi0iyMGPnQPegqb9aoojXT966uR2gqOrWmbttWNulUYUIIfOFHhKU7iUIBc2Amu0vsY7ibhEmuhtt43eRSsItAIgFDDQvBdi0iyMGPjWhGpSvpPFHhuaghNq39Iv7ghvoa4WdJahcbIvsSYwvS4ztLmVUo1QTbeAemtW0KGtUj3b)66uR2gqOrWmbtlCTAB9l8GclaidVMsyQJL8QbZoxKqGiaJJtO7EXQDJJkhaC4HrGdFDDQvBdi0iyMGPHpyqc654M(vB8DWHMQWdst4DZJQNKPhyHhcvhjHWadEWk(GdTAB9l8GIIVuyWS6aOace6UJ4kUj0DVy1UXrLdao8Wihl5vdMDIgLtMOGfEiuDKecdm4bR4do0QTHabSWdHQJem7WTAWkWoWWTjtaghNGzhUvdwb2bgUnsCf3Y966uR2gqOrWmbtZ8tzNhQFHhKMGPyv4lfgOwm8r9qzhCZ47nXeWcpW3BIvSKaFaclIWvyihLz(PSZdjhl5vdMDIgLr3DexXnbF4htowYRgm7enktuNAfgwXnlvmiPuqG4uRWWkUzPIbbtjZkjwzRkwCsImzNOr5EDDQvBdi0iyMGPHp8J1FunROXGZfP(fEqAcMIvHVuyGAXWh1dLz(PSZdjWHYo4MX3BIjGfEGV3eRyjb(aeweHRWqokZkjwzRkwCsqLKDIgFDDQvBdi0iyMGPHTgdfiXA6x4bDQvyyf3SuXGGPKz(nXgXkjwzRkw8S4lfga1ffJFLlmyIKG6ak6cmOJ6atD8e3YLSt04RRtTABaHgbZemnPTN2fWkHYy9l8Go1kmSIBwQyqWuYm)MyJyLeRSvflEw8LcdG6IIXVYfgmrsqDafDbg0rDGPoEIB5s2jA811PwTnGqJGzcM25H2EkGDfww)cpOtTcdR4MLkgemLmZVj2iwjXkBvXINfFPWaOUOy8RCHbtKeuhqrxGbDuhyQJN4wUKDIgFDDQvBdi0iyMGP5GqMAQfxzjyf7tdw)cpO53eBKybmVPCsbfbVUVUo1QTbe6GDmCqaFHCBkGv9K(0a0bRm)MydemL(fEqZhCBKebINducLXeUDHbhLjaJJtWuH8buy4ELihl5vdKjaJJtWuH8buy4ELihl5vdMDIgFDDQvBdi0b7y4zcMM4AevGW6kdOFHhuVZROIXWTr8yeqyDwadabY5vuXy42iEmcihl5vdskykOaceNAfgwXnlvmiPGNxrfJHBJ4XiGqx42s25VUo1QTbe6GDm8mbt7yW2Uv9KYVBfRFHhuVZROIXWTr8yeqyDwadabY5vuXy42iEmcihl5vdskyYdbItTcdR4MLkgKuWZROIXWTr8yeqOlCBj78xxNA12acDWogEMGPr39Iv7ghvoa4Wdt)cpOENxrfJHBJ4XiGW6SagacKZROIXWTr8yeqowYRgKuWuqbeio1kmSIBwQyqsbpVIkgd3gXJraHUWTLSZFDDQvBdi0b7y4zcMM4AeXRJvcRKG(fEqC4XqDmnHFtSYkjE2jAecebyCCIKhvcRKGFXIpcCieiclaidVMsyQJL8QbZkYxxNA12acDWogEMGPr9ddRFHhKU7iUIBI4AeXRJvcRKaHMWVjgOWpNA12(y2uVUo1QTbe6GDm8mbtlYULqrt4ypxs)cpOO6DEfvmgUnIhJacRZcyaiqoVIkgd3gXJra5yjVAqsIeceNAfgwXnlvmiPGNxrfJHBJ4XiGqx42s25YbbcnbtXQWxkmqTy4J6HY07GBgFVjMi4tQfxjb3LvBdiSicxHHC811PwTnGqhSJHNjyAuFmuo1QTvJcy63UehSnxFGDf1cMs)cp4b3m(EtmPzaO6jX(faOSZddREs5HH(5gmGWIiCfgYrz4lfgmlg)kxyWejb1bu0fyVUo1QTbe6GDm8mbtJMWXEUe411PwTnGqhSJHNjyAcWgnbFb0VWdgxJasCEyZdLWkjqSIIT6jzIgxJuTXx7dLWG5y1teG5uSZohcK4AeqIZdBEOewjbYXsE1GzNOr5EDDQvBdi0b7y4zcMg1pmS(fEW4AeqIZdBEOewjbIvuSvpjtpaBkHTHbeR4BEYRMhsFDDQvBdi0b7y4zcMMaSrtWxa9l8G0e(nXaf(5uR22hjnNisz0DhXvCtexJiEDSsyLei4WJH6yAc)MyLvsCsGqEmuMFtSbG6ZFDDQvBdi0b7y4zcMg(WBSvpPa2vyz9l8G0emfRcFPWa1IHpQh(66uR2gqOd2XWZemnS1yOORKK3r9PbOdwz(nXgiyk9l8GX1iHj4BL2MvcRKaXkk2QNKbytjSnmGyfFZtE18qQm9eGXXjsEujSsc(fl(iWHVUo1QTbe6GDm8mbtdBngkqI10VWdkaJJtWhEa(akj)WsGdFDDQvBdi0b7y4zcMg(WdWrfiXA6tdqhSY8BInqWuVUo1QTbe6GDm8mbtdWxi3McyvpPpnaDWkZVj2abtPFHh8y8JbjCHbltpROyREswZ60uIlLWkjqWSd3QblZ8BInIvsSYwvS4Ksjsz4lfgmd1bM64jUtkzePmNAfgwXnlvmy2GqLxxNA12acDWogEMGPjUgr86yLWkjOFHhuV4AeX1iIxhRewjbIvuSvpjtpaBkHTHbeR4BEYRMhsHa58kQymCBepgbewNfWaYeLMWVjgOWpNA12(iPuK5YCQvyyf3SuXGKGkqGqt43edu4NtTABFKukcurMtTcdR4MLkgKuYabcnHFtmqHFo1QT9rsPiIa5GarVZROIXWTr8yeqyDwadiJMWVjgOWpNA12(iPuer(66uR2gqOd2XWZemnbyJMGVa6x4bfvVM1PPexkHvsGasCEyZdiq0Z8b3grCnI41XQQXHb12eUDHbhLtgD3rCf3eX1iIxhRewjbco8yOoMMWVjwzLeNeiKhdL53eBaO(8xxNA12acDWogEMGPr9ddRFHhKU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsItceYJHY8BInauF(RRtTABaHoyhdptW0WwJHIUssEh1NgGoyL53eBGGP0VWdstWuSk8Lcdulg(OEOmC4XqDmnHFtSYkjE2jAuMOhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihLr3DexXnb)yo5w9KYopKCSKxnqgD3rCf3eZpLDEi5yjVAaei6DWnJV3etAgaQEsSFbak78WWQNuEyOFUbdiSicxHHCuUxxNA12acDWogEMGP5kj4lYNAXv0BfdEDDQvBdi0b7y4zcMgWyEOSZd1VWdstWuSk8Lcdulg(OE4RRtTABaHoyhdptW0a8fYTPaw1t6tdqhSY8BInqWu6x4bpg)yqcxyWYmFWTrseiEoqjugt42fgCuM53eBeRKyLTQyXjL8VUo1QTbe6GDm8mbtJ6hg(11PwTnGqhSJHNjyAyRXqrxjjVJ6tdqhSY8BInqWu6x4bPjykwf(sHbQfdFupuMOhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihLr3DexXnb)yo5w9KYopKCSKxnqgD3rCf3eZpLDEi5yjVAaei6DWnJV3etAgaQEsSFbak78WWQNuEyOFUbdiSicxHHCuUxxNA12acDWogEMGPHTgdfiXAVUo1QTbe6GDm8mbtdWxi3McyvpPpnaDWkZVj2abtPFHh8y8JbjCHb)66uR2gqOd2XWZemnPTN2fWkHYy9PbOdwz(nXgiyQxxNA12acDWogEMGPDEOTNcyxHL1NgGoyL53eBGGPEDFDDQvBdiT5bbgZdLDE4RRtTABaPnFMGPHFmNCREszNhQFHhupbyCCI4AevGW6kdqowYRgabIamoorCnIkqyDLbihl5vdKr3DexXnbBngk6kj5DKCSKxn411PwTnG0MptW0m)u25H6x4b1taghNiUgrfiSUYaKJL8QbqGiaJJtexJOcewxzaYXsE1az0DhXvCtWwJHIUssEhjhl5vdEDFDDQvBdialyKDlHIMWXEUK(fEqAcMIvHVuyGAXWh1dLjQENxrfJHBJ4XiGW6Sagace9oVIkgd3gXJrabou25vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6zfPCqGCEfvmgUnIhJacCOSZROIXWTr8yeqowYRgKeubkEDDQvBdiaBMGPb4lKBtbSQN0NgGoyL53eBGGP0VWdQxCncGVqUnfWQEIyffB1tYm)MyJyLeRSvflojDGmr1lUgjmbFR02SsyLeiwrXw9eeicW44ejpQewjb)IfFe4qznRttjUucRKajmbFR02SCqGiaJJtWuH8buy4ELiWHYeGXXjyQq(akmCVsKJL8QbZorJqGOhGnLW2WaIv8np5vZdPY0lUgbWxi3McyvprSIIT6jzMFtSrSsIv2QIfNKo411PwTnGaSzcMg(WdWrfiXAVUo1QTbeGntW0ogSTBvpP87wX6x4b178kQymCBepgbewNfWaqGO35vuXy42iEmciWHYe98kQymCBepgbKi85wT9mNxrfJHBJ4XiGu9SZHciqoVIkgd3gXJraHUWTfmLCqGCEfvmgUnIhJacCOSZROIXWTr8yeqowYRgKeubkGarybazwjXkBvXINnfu866uR2gqa2mbttCnIkqyDLb0VWdQ35vuXy42iEmciSolGbGarVZROIXWTr8yeqGdLDEfvmgUnIhJase(CR2EMZROIXWTr8yeqQE25qbeiNxrfJHBJ4XiGahk78kQymCBepgbKJL8QbjnhkGarybazwjXkBvXINDou866uR2gqa2mbtJU7fR2noQCaWHhM(fEq9oVIkgd3gXJraH1zbmaei0fd3EBKUMsykCNLr3DexXnrCnIkqyDLbihl5vdGarp6IHBVnsxtjmfUZYevVZROIXWTr8yeqGdLDEfvmgUnIhJase(CR2EMZROIXWTr8yeqQE2KbkGa58kQymCBepgbe4qzNxrfJHBJ4XiGCSKxniP5qbei6DEfvmgUnIhJacCOCqGiSaGmRKyLTQyXZMmqXRRtTABabyZemn8H3yREsbSRWY6x4bPjykwf(sHbQfdFup811PwTnGaSzcMMRKGViFQfxrVvm411PwTnGaSzcMM4AeXRJvcRKG(fEqC4XqDmnHFtSYkjE25j7enkdWMsyByaXk(MN8Q5HuiqeGXXjsEujSsc(fl(iWHqGOhGnLW2WaIv8np5vZdPYefhEmuhtt43eRSsINDIgHaHMGPyv4lfgOwm8r9qzI2SonL4sjSscem7WTAWYIRra8fYTPaw1teROyREswCncGVqUnfWQEICm(XGeUWGHaPzDAkXLsyLeiHj4BL2MLPNamoorA7PDbSch(cqGdLjkGnR6jaXhJvScFPWa1IHpQhcbc(sHbZqDGPoEI7zXxkmGi56e6CQvBtWwJHIUssEhjuhyQJN4oztg5KdceHfaKzLeRSvflE2uqHCVUo1QTbeGntW0WwJHIUssEh1NgGoyL53eBGGP0VWdcytjSnmGyfFZtE18qQS4AKWe8TsBZkHvsGyffB1tY0taghNi5rLWkj4xS4Jah(66uR2gqa2mbtdBngkqI1EDDQvBdiaBMGPr9ddRFHh0PwHHvCZsfdskLm9o4MX3BIjxGHJfy(alFafDB8fUJvpPa2vyzaHfr4kmKJVUo1QTbeGntW0eGnAc(cOFHh0PwHHvCZsfdskLm9o4MX3BIjxGHJfy(alFafDB8fUJvpPa2vyzaHfr4kmKJYO7oIR4MiUgr86yLWkjqWHhd1X0e(nXkRK4KaH8yOm)MydituAc)MyGc)CQvB7JKMtejeiX1iGeNh28qjSsceROyREsUxxNA12acWMjyAaJ5HYopu)cpinbtXQWxkmqTy4J6HVUo1QTbeGntW0K2EAxaRekJ1NgGoyL53eBGGP0VWdA(GBJ4JWeUk84OB7r42fgCuMOcW44ePTN2fWkC4labouMamoorA7PDbSch(cqowYRgml(sHbqDrX4x5cdMijOoGIUad6OoWuhpXTCj7enktpbyCCI4AevGW6kdqowYRgabIamoorA7PDbSch(cqowYRgiRzDAkXLsyLeiHj4BL2ML711PwTnGaSzcMg2Amu0vsY7O(0a0bRm)MydemL(fEqC4XqDmnHFtSYkjE2jAugnbtXQWxkmqTy4J6HVUo1QTbeGntW0op02tbSRWY6tdqhSY8BInqWu6x4bfGXXjwfQwCLLGvGq2pcWCk2GjdeiX1iGeNh28qjSsceROyRE611PwTnGaSzcMM02t7cyLqzS(fEW4AeqIZdBEOewjbIvuSvp966uR2gqa2mbtdWxi3McyvpPpnaDWkZVj2abtPFHh8y8JbjCHblZ8BInIvsSYwvS4K0bqGiaJJtWuH8buy4ELiWHVUo1QTbeGntW0exJiEDSsyLe0VWd2SonL4sjSsceqIZdBEidFPWGKW4x5cdMijOoGIUalzNllUgbWxi3McyvprowYRgKKit2jAuMEa2ucBddiwX38KxnpK(66uR2gqa2mbtJMWXEUe411PwTnGaSzcMg2Amu0vsY7O(0a0bRm)MydemL(fEqAcMIvHVuyGAXWh1dFDDQvBdiaBMGPjUgr86yLWkjOFHh8GBgFVjMCbgowG5dS8bu0TXx4ow9KcyxHLbeweHRWqo(66uR2gqa2mbttA7PDbSsOmwFAa6GvMFtSbcMs)cpOamoorA7PDbSch(cqGdHabFPWGzCQvBtWwJHIUssEhjuhyQJN4oj8LcdisUoHUuIecK4AeqIZdBEOewjbIvuSvpbbIamoorCnIkqyDLbihl5vdEDDQvBdiaBMGPDEOTNcyxHL1NgGoyL53eBGGPEDDQvBdiaBMGPjUgr86yLWkjOFHhu0M1PPexkHvsGGzhUvdwwCncGVqUnfWQEIyffB1tqG0SonL4sjSscKWe8TsBZqG0SonL4sjSsceqIZdBEidFPWGKejuiNm9aSPe2ggqSIV5jVAEi91911PwTnGyx1yzdeeJFLlmy9BxIdcc0ufCO(y8bmhuaghNCmyB3QEs53TIjWHqGiaJJtO7EXQDJJkhaC4HrGdFDDQvBdi2vnw2aZemnm(vUWG1VDjoiWUTNuGanvbhQpgFaZbPlgU92iydCL3YeGXXjhd22TQNu(DRycCOmbyCCcD3lwTBCu5aGdpmcCiei6rxmC7TrWg4kVLjaJJtO7EXQDJJkhaC4HrGdFDDQvBdi2vnw2aZemnm(vUWG1VDjoiWUTNuGanvDSKxnq)nmiGTcxF62XYQTdsxmC7TrWg4kV1hJpG5G0DhXvCtogSTBvpP87wXKJL8QbZkcdD3rCf3e6UxSA34OYbahEyKJL8QbQjyga0hJpGzfpaCq6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaOFHhuaghNq39Iv7ghvoa4WdJexX9RRtTABaXUQXYgyMGPHXVYfgS(TlXbb2T9KceOPQJL8Qb6VHbbSv46t3owwTDq6IHBVnc2ax5T(y8bmhKU7iUIBYXGTDR6jLF3kMCSKxnqFm(aMv8aWbP7oIR4Mq39Iv7ghvoa4WdJCSKxnqnbZaG(fEqbyCCcD3lwTBCu5aGdpmcC4RRtTABaXUQXYgyMGPHXVYfgS(TlXbbbAQ6yjVAG(ByqaBfU(0TJLvBhKUy42BJGnWvERpgFaZbP7oIR4MCmyB3QEs53TIjhl5vdsseg6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaOpgFaZkEa4G0DhXvCtO7EXQDJJkhaC4HrowYRgOMGza411PwTnGyx1yzdmtW0GbSQmwcOpySgiODvJLTu6x4bfvu7QglBKuKeoqbdyLamooei0fd3EBeSbUYBz2vnw2iPijCGIU7iUIB5Kjkg)kxyWeGDBpPabAQcouMO6rxmC7TrWg4kVLPNDvJLnYCschOGbSsaghhce6IHBVnc2ax5Tm9SRASSrMts4afD3rCf3qGyx1yzJmNq3DexXn5yjVAaei2vnw2iPijCGcgWkbyCCzIQNDvJLnYCschOGbSsaghhce7QglBKue6UJ4kUjr4ZTA7KcAx1yzJmNq3DexXnjcFUvBlhei2vnw2iPijCGIU7iUIBz6zx1yzJmNKWbkyaReGXXLzx1yzJKIq3DexXnjcFUvBNuq7QglBK5e6UJ4kUjr4ZTAB5Garpm(vUWGja72Esbc0ufCOmr1ZUQXYgzojHduWawjaJJltu7QglBKue6UJ4kUjr4ZTABOtKZIXVYfgmbeOPQJL8QbqGGXVYfgmbeOPQJL8Qbjzx1yzJKIq3DexXnjcFUvBd1Nlhei2vnw2iZjjCGcgWkbyCCzIAx1yzJKIKWbkyaReGXXLzx1yzJKIq3DexXnjcFUvBNuq7QglBK5e6UJ4kUjr4ZTABzIAx1yzJKIq3DexXnjcFUvBdDICwm(vUWGjGanvDSKxnacem(vUWGjGanvDSKxnij7QglBKue6UJ4kUjr4ZTABO(C5Garu9SRASSrsrs4afmGvcW44qGyx1yzJmNq3DexXnjcFUvBNuq7QglBKue6UJ4kUjr4ZTAB5KjQDvJLnYCcD3rCf3KJ9yaz2vnw2iZj0DhXvCtIWNB12qNitcJFLlmyciqtvhl5vdKHXVYfgmbeOPQJL8QbZAx1yzJmNq3DexXnjcFUvBd1NdbIE2vnw2iZj0DhXvCto2JbKjQDvJLnYCcD3rCf3KJL8QbqNiNfJFLlmycWUTNuGanvDSKxnqgg)kxyWeGDBpPabAQ6yjVAqsZHczIAx1yzJKIq3DexXnjcFUvBdDICwm(vUWGjGanvDSKxnace7QglBK5e6UJ4kUjhl5vdGorolg)kxyWeqGMQowYRgiZUQXYgzoHU7iUIBse(CR2g6sbfZGXVYfgmbeOPQJL8QbZIXVYfgmby32tkqGMQowYRgabcg)kxyWeqGMQowYRgKKDvJLnskcD3rCf3Ki85wTnuFoeiy8RCHbtabAQcouoiqSRASSrMtO7oIR4MCSKxna6ezsy8RCHbta2T9KceOPQJL8QbYe1UQXYgjfHU7iUIBse(CR2g6e5Sy8RCHbta2T9KceOPQJL8QbqGyx1yzJKIq3DexXnjcFUvBplEnLWuhl5vdKHXVYfgmby32tkqGMQowYRgmJDvJLnskcD3rCf3Ki85wTDs41uctDSKxnace9SRASSrsrs4afmGvcW44YefJFLlmyciqtvhl5vdsYUQXYgjfHU7iUIBse(CR2gQphcem(vUWGjGanvbhkNCYjNCYbbI53eBeRKyLTQyXZIXVYfgmbeOPQJL8QbYbbIE2vnw2iPijCGcgWkbyCCz6rxmC7TrWg4kVLjQDvJLnYCschOGbSsaghxMOIQhg)kxyWeqGMQGdHaXUQXYgzoHU7iUIBYXsE1GKePCYefJFLlmyciqtvhl5vdsAouabIDvJLnYCcD3rCf3KJL8QbqNitcJFLlmyciqtvhl5vdKtoiq0ZUQXYgzojHduWawjaJJltu9SRASSrMts4afD3rCf3qGyx1yzJmNq3DexXn5yjVAaei2vnw2iZj0DhXvCtIWNB12jf0UQXYgjfHU7iUIBse(CR2wo5KtMO6zx1yzJKIuac1Pjy1IRCQicxhhv2Xoa(yaeio1kmSIBwQyWSZLjaJJtCQicxhhvI9osGdHaXPwHHvCZsfdskLm9eGXXjoveHRJJkXEhjWHY966uR2gqSRASSbMjyAWawvglb0hmwde0UQXY2C9l8GIkQDvJLnYCschOGbSsaghhce6IHBVnc2ax5Tm7QglBK5Keoqr3DexXTCYefJFLlmycWUTNuGanvbhktu9OlgU92iydCL3Y0ZUQXYgjfjHduWawjaJJdbcDXWT3gbBGR8wME2vnw2iPijCGIU7iUIBiqSRASSrsrO7oIR4MCSKxnace7QglBK5KeoqbdyLamoUmr1ZUQXYgjfjHduWawjaJJdbIDvJLnYCcD3rCf3Ki85wTDsbTRASSrsrO7oIR4MeHp3QTLdce7QglBK5Keoqr3DexXTm9SRASSrsrs4afmGvcW44YSRASSrMtO7oIR4MeHp3QTtkODvJLnskcD3rCf3Ki85wTTCqGOhg)kxyWeGDBpPabAQcouMO6zx1yzJKIKWbkyaReGXXLjQDvJLnYCcD3rCf3Ki85wTn0jYzX4x5cdMac0u1XsE1aiqW4x5cdMac0u1XsE1GKSRASSrMtO7oIR4MeHp3QTH6ZLdce7QglBKuKeoqbdyLamoUmrTRASSrMts4afmGvcW44YSRASSrMtO7oIR4MeHp3QTtkODvJLnskcD3rCf3Ki85wTTmrTRASSrMtO7oIR4MeHp3QTHorolg)kxyWeqGMQowYRgabcg)kxyWeqGMQowYRgKKDvJLnYCcD3rCf3Ki85wTnuFUCqGiQE2vnw2iZjjCGcgWkbyCCiqSRASSrsrO7oIR4MeHp3QTtkODvJLnYCcD3rCf3Ki85wTTCYe1UQXYgjfHU7iUIBYXEmGm7QglBKue6UJ4kUjr4ZTABOtKjHXVYfgmbeOPQJL8QbYW4x5cdMac0u1XsE1GzTRASSrsrO7oIR4MeHp3QTH6ZHarp7QglBKue6UJ4kUjh7XaYe1UQXYgjfHU7iUIBYXsE1aOtKZIXVYfgmby32tkqGMQowYRgidJFLlmycWUTNuGanvDSKxniP5qHmrTRASSrMtO7oIR4MeHp3QTHorolg)kxyWeqGMQowYRgabIDvJLnskcD3rCf3KJL8QbqNiNfJFLlmyciqtvhl5vdKzx1yzJKIq3DexXnjcFUvBdDPGIzW4x5cdMac0u1XsE1GzX4x5cdMaSB7jfiqtvhl5vdGabJFLlmyciqtvhl5vdsYUQXYgzoHU7iUIBse(CR2gQphcem(vUWGjGanvbhkhei2vnw2iPi0DhXvCtowYRgaDImjm(vUWGja72Esbc0u1XsE1azIAx1yzJmNq3DexXnjcFUvBdDICwm(vUWGja72Esbc0u1XsE1aiqSRASSrMtO7oIR4MeHp3QTNfVMsyQJL8QbYW4x5cdMaSB7jfiqtvhl5vdMXUQXYgzoHU7iUIBse(CR2oj8AkHPowYRgabIE2vnw2iZjjCGcgWkbyCCzIIXVYfgmbeOPQJL8Qbjzx1yzJmNq3DexXnjcFUvBd1Ndbcg)kxyWeqGMQGdLto5Kto5GaX8BInIvsSYwvS4zX4x5cdMac0u1XsE1a5Garp7QglBK5KeoqbdyLamoUm9OlgU92iydCL3Ye1UQXYgjfjHduWawjaJJltur1dJFLlmyciqtvWHqGyx1yzJKIq3DexXn5yjVAqsIuozIIXVYfgmbeOPQJL8QbjnhkGaXUQXYgjfHU7iUIBYXsE1aOtKjHXVYfgmbeOPQJL8QbYjhei6zx1yzJKIKWbkyaReGXXLjQE2vnw2iPijCGIU7iUIBiqSRASSrsrO7oIR4MCSKxnace7QglBKue6UJ4kUjr4ZTA7KcAx1yzJmNq3DexXnjcFUvBlNCYjtu9SRASSrMtkaH60eSAXvoveHRJJk7yhaFmaceNAfgwXnlvmy25YeGXXjoveHRJJkXEhjWHqG4uRWWkUzPIbjLsMEcW44eNkIW1XrLyVJe4q5EDDQvBdi2vnw2aZemnyaRkJL0VDjoi0J1G7jUUtfzGvDaGI6JrwdeY0S8ZfPiZw2Yza]] )


end