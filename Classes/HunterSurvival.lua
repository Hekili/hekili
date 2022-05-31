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

            cycle = function ()
                -- We want to target the lowest Bloodseeker on a target with Pheromone Bomb ticking.
                if talent.wildfire_infusion.enabled and debuff.pheromone_bomb.up then
                    if talent.bloodseeker.enabled then
                        -- Apply Bloodseeker to this target.
                        if debuff.kill_command.down then return end
                        -- If there are other Pheromoned targets, and fewer Bloodseekers than Pheromone Bombs, swap to _someone_.
                        if active_dot.pheromone_bomb > 1 and active_dot.kill_command < active_dot.pheromone_bomb then
                            return "kill_command"
                        end
                        -- Otherwise, just hit this target.
                        return
                    end
                end
                return talent.bloodseeker.enabled and "kill_command" or nil
            end,

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


    spec:RegisterPack( "Survival", 20220530, [[da1(ZcqisvEKikYLajvBIO8jqsgfH0PiQSkru6vkkMfPQUfiv2fIFjszyGeoMizzkQEgPcMgirUgHOTriW3erHXjIQoNikQ1bsv9ocbvzEkkDpbAFIi)JqqXbjeKfcs5HKk0ejeu5Ieck1gbjkXhbjQAKeck5KGuLwjPsVeKOYmbjLBcsuQDsu1pjeuvdfKOKwkirXtjLPks1xbPkASIOI9kQ)sYGHCyQwmbpgPjl0LrTzO6ZkYOfHtlz1GufEnuA2kCBISBP(TsdxqhNqOLRYZbMoLRdQTdfFNqnEsfDEbSEruP5dI9RQZPYPN1IUXz5NdfZNdfIuhGcskOeuckLkvwZceYzTqNI1N4Sw7sCwtd(Wuy8rwl0dmwpMtpRbw4JYzTKPhLWSqa0pT0MklbSaHUsPbkj4HB120ZXT0aLenTSMaCnmO3olK1IUXz5NdfZNdfIuhGcskOeushGsjJSMdBj2lRPvs6ywlrfJCNfYArgqZAAWhMcJpEKiSGBJVxxOS9apshGc9F0COy(8x3xxDCBm8zpcFPWGhTy4J6HpIMGPybpY2hDmiKP2JAw8JOdhaEeGnR6jWJs7rWa(rnl(r0emfRcFPWa1IHpQh(iwNHhda12KS2OagiNEwZUQXYgiNEw(u50ZAC7cdoMHwwBdZAa2YAo1QTZAy8RCHbN1W4dyoRjaJJtogSTBvpP87wXe4WhbbYJeGXXj0DVy1UXrLdao8WiWHznm(PAxIZAGanvbhMTS8ZZPN142fgCmdTS2gM1aSL1CQvBN1W4x5cdoRHXhWCwJUy42BJGnWvE)izpsaghNCmyB3QEs53TIjWHps2JeGXXj0DVy1UXrLdao8WiWHpccKhP3JOlgU92iydCL3ps2JeGXXj0DVy1UXrLdao8WiWHznm(PAxIZAa72Esbc0ufCy2YYRd50ZAC7cdoMHwwBdZAa2k8SMtTA7Sgg)kxyWznm(PAxIZAa72Esbc0u1XsE1GSg9kJVYZAcW44e6UxSA34OYbahEyK4kUZAy8bmR4bGZA0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaiRHXhWCwJU7iUIBYXGTDR6jLF3kMCSKxn4rZkcZJO7oIR4Mq39Iv7ghvoa4WdJCSKxnqnbZaq2YYdLYPN142fgCmdTS2gM1aSv4znNA12znm(vUWGZAy8t1UeN1a2T9KceOPQJL8Qbzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHznm(aMv8aWzn6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaK1W4dyoRr3DexXn5yW2Uv9KYVBftowYRgKTS8ImNEwJBxyWXm0YABywdWwHN1CQvBN1W4x5cdoRHXpv7sCwdeOPQJL8Qbzn6vgFLN1OlgU92iydCL3znm(aMv8aWzn6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaK1W4dyoRr3DexXn5yW2Uv9KYVBftowYRg8OKeH5r0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaiBz5fb50ZAC7cdoMHwwZPwTDwZUQXYwQSg9kJVYZAI(irFKDvJLnILIKWbkyaReGXXFeeipIUy42BJGnWvE)izpYUQXYgXsrs4afD3rCf3psUhj7rI(im(vUWGja72Esbc0ufC4JK9irFKEpIUy42BJGnWvE)izpsVhzx1yzJyZjjCGcgWkbyC8hbbYJOlgU92iydCL3ps2J07r2vnw2i2CschOO7oIR4(rqG8i7QglBeBoHU7iUIBYXsE1GhbbYJSRASSrSuKeoqbdyLamo(JK9irFKEpYUQXYgXMts4afmGvcW44pccKhzx1yzJyPi0DhXvCtIWNB12pkPGpYUQXYgXMtO7oIR4MeHp3QTFKCpccKhzx1yzJyPijCGIU7iUI7hj7r69i7QglBeBojHduWawjaJJ)izpYUQXYgXsrO7oIR4MeHp3QTFusbFKDvJLnInNq3DexXnjcFUvB)i5EeeipsVhHXVYfgmby32tkqGMQGdFKShj6J07r2vnw2i2CschOGbSsagh)rYEKOpYUQXYgXsrO7oIR4MeHp3QTFe09ir(OzFeg)kxyWeqGMQowYRg8iiqEeg)kxyWeqGMQowYRg8OKEKDvJLnILIq3DexXnjcFUvB)O0E08hj3JGa5r2vnw2i2CschOGbSsagh)rYEKOpYUQXYgXsrs4afmGvcW44ps2JSRASSrSue6UJ4kUjr4ZTA7hLuWhzx1yzJyZj0DhXvCtIWNB12ps2Je9r2vnw2iwkcD3rCf3Ki85wT9JGUhjYhn7JW4x5cdMac0u1XsE1GhbbYJW4x5cdMac0u1XsE1GhL0JSRASSrSue6UJ4kUjr4ZTA7hL2JM)i5Eeeips0hP3JSRASSrSuKeoqbdyLamo(JGa5r2vnw2i2CcD3rCf3Ki85wT9Jsk4JSRASSrSue6UJ4kUjr4ZTA7hj3JK9irFKDvJLnInNq3DexXn5ypg4rYEKDvJLnInNq3DexXnjcFUvB)iO7rI8rj9im(vUWGjGanvDSKxn4rYEeg)kxyWeqGMQowYRg8OzFKDvJLnInNq3DexXnjcFUvB)O0E08hbbYJ07r2vnw2i2CcD3rCf3KJ9yGhj7rI(i7QglBeBoHU7iUIBYXsE1GhbDpsKpA2hHXVYfgmby32tkqGMQowYRg8izpcJFLlmycWUTNuGanvDSKxn4rj9O5qXJK9irFKDvJLnILIq3DexXnjcFUvB)iO7rI8rZ(im(vUWGjGanvDSKxn4rqG8i7QglBeBoHU7iUIBYXsE1GhbDpsKpA2hHXVYfgmbeOPQJL8Qbps2JSRASSrS5e6UJ4kUjr4ZTA7hbDpkfu8OzEeg)kxyWeqGMQowYRg8OzFeg)kxyWeGDBpPabAQ6yjVAWJGa5ry8RCHbtabAQ6yjVAWJs6r2vnw2iwkcD3rCf3Ki85wT9Js7rZFeeipcJFLlmyciqtvWHpsUhbbYJSRASSrS5e6UJ4kUjhl5vdEe09ir(OKEeg)kxyWeGDBpPabAQ6yjVAWJK9irFKDvJLnILIq3DexXnjcFUvB)iO7rI8rZ(im(vUWGja72Esbc0u1XsE1GhbbYJSRASSrSue6UJ4kUjr4ZTA7hn7JWRPeM6yjVAWJK9im(vUWGja72Esbc0u1XsE1GhnZJSRASSrSue6UJ4kUjr4ZTA7hL0JWRPeM6yjVAWJGa5r69i7QglBelfjHduWawjaJJ)izps0hHXVYfgmbeOPQJL8QbpkPhzx1yzJyPi0DhXvCtIWNB12pkThn)rqG8im(vUWGjGanvbh(i5EKCpsUhj3JK7rY9iiqEK53eBeRKyLTQyXpA2hHXVYfgmbeOPQJL8QbpsUhbbYJ07r2vnw2iwkschOGbSsagh)rYEKEpIUy42BJGnWvE)izps0hzx1yzJyZjjCGcgWkbyC8hj7rI(irFKEpcJFLlmyciqtvWHpccKhzx1yzJyZj0DhXvCtowYRg8OKEKiFKCps2Je9ry8RCHbtabAQ6yjVAWJs6rZHIhbbYJSRASSrS5e6UJ4kUjhl5vdEe09ir(OKEeg)kxyWeqGMQowYRg8i5EKCpccKhP3JSRASSrS5KeoqbdyLamo(JK9irFKEpYUQXYgXMts4afD3rCf3pccKhzx1yzJyZj0DhXvCtowYRg8iiqEKDvJLnInNq3DexXnjcFUvB)OKc(i7QglBelfHU7iUIBse(CR2(rY9i5EKCps2Je9r69i7QglBelfPaeQttWQfx5ureUooQSJDa8XGhbbYJCQvyyf3SuXGhn7JM)izpsaghN4ureUooQe7DKah(iiqEKtTcdR4MLkg8OKEuQhj7r69ibyCCItfr464OsS3rcC4JKlRbgRbYA2vnw2sLTS8jJC6znUDHbhZqlR5uR2oRzx1yzBEwJELXx5znrFKOpYUQXYgXMts4afmGvcW44pccKhrxmC7TrWg4kVFKShzx1yzJyZjjCGIU7iUI7hj3JK9irFeg)kxyWeGDBpPabAQco8rYEKOpsVhrxmC7TrWg4kVFKShP3JSRASSrSuKeoqbdyLamo(JGa5r0fd3EBeSbUY7hj7r69i7QglBelfjHdu0DhXvC)iiqEKDvJLnILIq3DexXn5yjVAWJGa5r2vnw2i2CschOGbSsagh)rYEKOpsVhzx1yzJyPijCGcgWkbyC8hbbYJSRASSrS5e6UJ4kUjr4ZTA7hLuWhzx1yzJyPi0DhXvCtIWNB12psUhbbYJSRASSrS5Keoqr3DexX9JK9i9EKDvJLnILIKWbkyaReGXXFKShzx1yzJyZj0DhXvCtIWNB12pkPGpYUQXYgXsrO7oIR4MeHp3QTFKCpccKhP3JW4x5cdMaSB7jfiqtvWHps2Je9r69i7QglBelfjHduWawjaJJ)izps0hzx1yzJyZj0DhXvCtIWNB12pc6EKiF0SpcJFLlmyciqtvhl5vdEeeipcJFLlmyciqtvhl5vdEuspYUQXYgXMtO7oIR4MeHp3QTFuApA(JK7rqG8i7QglBelfjHduWawjaJJ)izps0hzx1yzJyZjjCGcgWkbyC8hj7r2vnw2i2CcD3rCf3Ki85wT9Jsk4JSRASSrSue6UJ4kUjr4ZTA7hj7rI(i7QglBeBoHU7iUIBse(CR2(rq3Je5JM9ry8RCHbtabAQ6yjVAWJGa5ry8RCHbtabAQ6yjVAWJs6r2vnw2i2CcD3rCf3Ki85wT9Js7rZFKCpccKhj6J07r2vnw2i2CschOGbSsagh)rqG8i7QglBelfHU7iUIBse(CR2(rjf8r2vnw2i2CcD3rCf3Ki85wT9JK7rYEKOpYUQXYgXsrO7oIR4MCShd8izpYUQXYgXsrO7oIR4MeHp3QTFe09ir(OKEeg)kxyWeqGMQowYRg8izpcJFLlmyciqtvhl5vdE0SpYUQXYgXsrO7oIR4MeHp3QTFuApA(JGa5r69i7QglBelfHU7iUIBYXEmWJK9irFKDvJLnILIq3DexXn5yjVAWJGUhjYhn7JW4x5cdMaSB7jfiqtvhl5vdEKShHXVYfgmby32tkqGMQowYRg8OKE0CO4rYEKOpYUQXYgXMtO7oIR4MeHp3QTFe09ir(OzFeg)kxyWeqGMQowYRg8iiqEKDvJLnILIq3DexXn5yjVAWJGUhjYhn7JW4x5cdMac0u1XsE1Ghj7r2vnw2iwkcD3rCf3Ki85wT9JGUhLckE0mpcJFLlmyciqtvhl5vdE0SpcJFLlmycWUTNuGanvDSKxn4rqG8im(vUWGjGanvDSKxn4rj9i7QglBeBoHU7iUIBse(CR2(rP9O5pccKhHXVYfgmbeOPk4Whj3JGa5r2vnw2iwkcD3rCf3KJL8Qbpc6EKiFuspcJFLlmycWUTNuGanvDSKxn4rYEKOpYUQXYgXMtO7oIR4MeHp3QTFe09ir(OzFeg)kxyWeGDBpPabAQ6yjVAWJGa5r2vnw2i2CcD3rCf3Ki85wT9JM9r41uctDSKxn4rYEeg)kxyWeGDBpPabAQ6yjVAWJM5r2vnw2i2CcD3rCf3Ki85wT9Js6r41uctDSKxn4rqG8i9EKDvJLnInNKWbkyaReGXXFKShj6JW4x5cdMac0u1XsE1GhL0JSRASSrS5e6UJ4kUjr4ZTA7hL2JM)iiqEeg)kxyWeqGMQGdFKCpsUhj3JK7rY9i5EeeipY8BInIvsSYwvS4hn7JW4x5cdMac0u1XsE1Ghj3JGa5r69i7QglBeBojHduWawjaJJ)izpsVhrxmC7TrWg4kVFKShj6JSRASSrSuKeoqbdyLamo(JK9irFKOpsVhHXVYfgmbeOPk4WhbbYJSRASSrSue6UJ4kUjhl5vdEuspsKpsUhj7rI(im(vUWGjGanvDSKxn4rj9O5qXJGa5r2vnw2iwkcD3rCf3KJL8Qbpc6EKiFuspcJFLlmyciqtvhl5vdEKCpsUhbbYJ07r2vnw2iwkschOGbSsagh)rYEKOpsVhzx1yzJyPijCGIU7iUI7hbbYJSRASSrSue6UJ4kUjhl5vdEeeipYUQXYgXsrO7oIR4MeHp3QTFusbFKDvJLnInNq3DexXnjcFUvB)i5EKCpsUhj7rI(i9EKDvJLnInNuac1Pjy1IRCQicxhhv2Xoa(yWJGa5ro1kmSIBwQyWJM9rZFKShjaJJtCQicxhhvI9osGdFeeipYPwHHvCZsfdEuspk1JK9i9EKamooXPIiCDCuj27ibo8rYL1aJ1azn7QglBZZww(KpNEwJBxyWXm0YATlXznOhRb3tCDNkYaR6aaf1hJSMtTA7Sg0J1G7jUUtfzGvDaGI6Jr2YwwRnpNEw(u50ZAo1QTZAaJ5HYopmRXTlm4ygAzll)8C6znUDHbhZqlRrVY4R8SMEpsaghNiUgrfiSUYaKJL8QbpccKhjaJJtexJOcewxzaYXsE1Ghj7r0DhXvCtWwJHIUssEhjhl5vdYAo1QTZA4hZj3QNu25HzllVoKtpRXTlm4ygAzn6vgFLN107rcW44eX1iQaH1vgGCSKxn4rqG8ibyCCI4AevGW6kdqowYRg8izpIU7iUIBc2Amu0vsY7i5yjVAqwZPwTDwZ8tzNhMTSL1ImUdpSC6z5tLtpRXTlm4ygAzn6vgFLN1m)MyJSWgOICY)izpcWMv9eGadyvc)c3TFKShjaJJtCqitn1IRSeSI9PbtIR4oR5uR2oRLWVWD7SLLFEo9SMtTA7SMeCYn5o4Sg3UWGJzOLTS86qo9Sg3UWGJzOL1CQvBN1SZBreUgvYT6jfiXAzTidOxfA12znO87J8eShFK3XhL(5TicxJk5YpsEOSQJpIBwQyG(psm)O42qL9O4(ilrbEe(EpkC4b4d8ibM6Wa(rLbvXhjWpY29rGqxskWJ8o(iX8JOEdv2Jo2J1iWJs)8weFeiKPfErFKamooGK1Oxz8vEwtVhz(nXgPaQWHhGVSLLhkLtpRXTlm4ygAznNA12znOhRb3tCDNkYaR6aaf1hJSg9kJVYZAo1kmSIBwQyWJc(Oups2Je9rcW44e6UxSA34OYbahEye4WhbbYJ07r0DhXvCtO7EXQDJJkhaC4HrowYRg8iiqEKWcaps2JSsIv2QIf)OzFKoafpsUhbbYJe9ro1kmSIBwQyWJs6rPEKShjaJJtogSTBvpP87wXe4WhbbYJeGXXj0DVy1UXrLdao8WiWHpsUSw7sCwd6XAW9ex3PImWQoaqr9XiBz5fzo9SMtTA7SgmGvLXsGSg3UWGJzOLTS8IGC6znUDHbhZqlRrVY4R8SgDXWT3gbBGR8(rYEeD3rCf3e6UxSA34OYbahEyKJL8Qbps2JO7oIR4MCmyB3QEs53TIjhl5vdEeeipsVhrxmC7TrWg4kVFKShr3DexXnHU7fR2noQCaWHhg5yjVAqwZPwTDwJ6JHYPwTTAualRnkGPAxIZA2vnw2azllFYiNEwJBxyWXm0YAo1QTZAuFmuo1QTvJcyzTrbmv7sCwJgbzllFYNtpRXTlm4ygAzn6vgFLN1CQvyyf3SuXGhn7J0Hhj7rMp42ic1fbQfxfECac3UWGJznGDf1YYNkR5uR2oRr9Xq5uR2wnkGL1gfWuTlXznHnmBz5tMZPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJM9r6WJK9i9EK5dUnIqDrGAXvHhhGWTlm4ywdyxrTS8PYAo1QTZAuFmuo1QTvJcyzTrbmv7sCwdyzllFkOiNEwJBxyWXm0YA0Rm(kpR5uRWWkUzPIbpkPhnpRbSROww(uznNA12znQpgkNA12QrbSS2OaMQDjoRrhSJHZww(uPYPN1CQvBN18J6nRS9oUTSg3UWGJzOLTSL1cpMUscULtplFQC6znUDHbhZqlRTHznaBfEwJELXx5znZhCBePTN2fWkHYyc3UWGJzTidOxfA12znDCBm8zpcFPWGhTy4J6HpIMGPybpY2hDmiKP2JAw8JOdhaEeGnR6jWJs7rWa(rnl(r0emfRcFPWa1IHpQh(iwNHhda12KSgg)uTlXznjb1bu0fyznNA12znm(vUWGZAy8bmR4bGZAo1QTjNhA7Pa2vyzcDbwwdJpG5SMtTABI02t7cyLqzmHUalBz5NNtpR5uR2oRbGLK2wfYwwJBxyWXm0YwwEDiNEwZPwTDwtynBWrf(WdWrXvpPSvNvN142fgCmdTSLLhkLtpR5uR2oRHpyqc654wwJBxyWXm0YwwErMtpRXTlm4ygAzn6vgFLN1o4MX3BIjGfEGV3eRyjb(aeweHRWqoM1CQvBN1m)u25HzllViiNEwZPwTDwdympu25HznUDHbhZqlBzlRbSC6z5tLtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFup8rYEKOpsVhDEfvmgUnIhJacRZcyGhbbYJ07rNxrfJHBJ4XiGah(izp68kQymCBepgbKi85wT9JM5rNxrfJHBJ4XiGu9JM9rI8rY9iiqE05vuXy42iEmciWHps2JoVIkgd3gXJra5yjVAWJs6rqjOiR5uR2oRfz3sOOjCSNlLTS8ZZPN142fgCmdTSMtTA7SgGVqUnfWQEkRrVY4R8SMEpkUgbWxi3McyvprSIIT6Phj7rMFtSrSsIv2QIf)OKEuY4rYEKOpsVhfxJeMGVvABwjSsceROyRE6rqG8ibyCCIKhvcRKGFXIpcC4JK9OM1PPexkHvsGeMGVvAB(rY9iiqEKamoobtfYhqHH7vIah(izpsaghNGPc5dOWW9krowYRg8OzF0en(iiqEKEpcWMsyByaXk(MN8Q5H0hj7r69O4AeaFHCBkGv9eXkk2QNEKShz(nXgXkjwzRkw8Js6rjJSgnaDWkZVj2az5tLTS86qo9SMtTA7Sg(WdWrfiXAznUDHbhZqlBz5Hs50ZAC7cdoMHwwJELXx5znbyCCc(WdWhqj5hwcCywZPwTDwdBngkqI1YwwErMtpRXTlm4ygAzn6vgFLN107rNxrfJHBJ4XiGW6Sag4rqG8i9E05vuXy42iEmciWHps2Je9rNxrfJHBJ4XiGeHp3QTF0mp68kQymCBepgbKQF0SpAou8iiqE05vuXy42iEmci0fUThf8rPEKCpccKhDEfvmgUnIhJacC4JK9OZROIXWTr8yeqowYRg8OKEeuckEeeipsybGhj7rwjXkBvXIF0SpkfuK1CQvBN1ogSTBvpP87wXzllViiNEwJBxyWXm0YA0Rm(kpRP3JoVIkgd3gXJraH1zbmWJGa5r69OZROIXWTr8yeqGdFKShDEfvmgUnIhJase(CR2(rZ8OZROIXWTr8yeqQ(rZ(O5qXJGa5rNxrfJHBJ4XiGah(izp68kQymCBepgbKJL8QbpkPhnhkEeeipsybGhj7rwjXkBvXIF0SpAouK1CQvBN1exJOcewxzGSLLpzKtpRXTlm4ygAzn6vgFLN107rNxrfJHBJ4XiGW6Sag4rqG8i6IHBVnsxtjmfUZps2JO7oIR4MiUgrfiSUYaKJL8QbpccKhP3JOlgU92iDnLWu4o)izps0hP3JoVIkgd3gXJrabo8rYE05vuXy42iEmcir4ZTA7hnZJoVIkgd3gXJraP6hn7J0bO4rqG8OZROIXWTr8yeqGdFKShDEfvmgUnIhJaYXsE1GhL0JMdfpccKhP3JoVIkgd3gXJrabo8rY9iiqEKWcaps2JSsIv2QIf)OzFKoafznNA12zn6UxSA34OYbahEyzllFYNtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBz5tMZPN1CQvBN1CLe8f5tT4k6TIbznUDHbhZqlBz5tbf50ZAC7cdoMHwwJELXx5znC4XqDmnHFtSYkj(rZ(O5pkzF0en(izpcWMsyByaXk(MN8Q5H0hbbYJeGXXjsEujSsc(fl(iWHpccKhP3JaSPe2ggqSIV5jVAEi9rYEKOpchEmuhtt43eRSsIF0SpAIgFeeipIMGPyv4lfgOwm8r9Whj7rI(OM1PPexkHvsGGzhUvd(rYEuCncGVqUnfWQEIyffB1tps2JIRra8fYTPaw1tKJXpgKWfg8JGa5rnRttjUucRKajmbFR028JK9i9EKamoorA7PDbSch(cqGdFKShj6JaSzvpbi(ySIv4lfgOwm8r9WhbbYJWxkm4rZ8iQdm1XtC)OzFe(sHbejxNpc6EKtTABc2Amu0vsY7iH6atD8e3pkzFKo8i5EKCpccKhjSaWJK9iRKyLTQyXpA2hLckEKCznNA12znX1iIxhRewjHSLLpvQC6znUDHbhZqlR5uR2oRHTgdfDLK8oM1Oxz8vEwdWMsyByaXk(MN8Q5H0hj7rX1iHj4BL2MvcRKaXkk2QNEKShP3JeGXXjsEujSsc(fl(iWHznAa6GvMFtSbYYNkBz5tnpNEwZPwTDwdBngkqI1YAC7cdoMHw2YYNshYPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJs6rPEKShP3Jo4MX3BIjxGHJfy(alFafDB8fUJvpPa2vyzaHfr4kmKJznNA12znQFy4SLLpfukNEwJBxyWXm0YA0Rm(kpR5uRWWkUzPIbpkPhL6rYEKEp6GBgFVjMCbgowG5dS8bu0TXx4ow9KcyxHLbeweHRWqo(izpIU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsIFuspceYJHY8BInWJK9irFenHFtmqHFo1QT9XJs6rZjI8rqG8O4AeqIZdBEOewjbIvuSvp9i5YAo1QTZAcWgnbFbYww(uImNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OEywZPwTDwdympu25HzllFkrqo9Sg3UWGJzOL1CQvBN1K2EAxaRekJZA0Rm(kpRz(GBJ4JWeUk84OB7r42fgC8rYEKOpsaghNiT90UawHdFbiWHps2JeGXXjsBpTlGv4WxaYXsE1Ghn7JWxkm4rP9irFeg)kxyWejb1bu0fypc6Ee1bM64jUFKCpkzF0en(izpsVhjaJJtexJOcewxzaYXsE1GhbbYJeGXXjsBpTlGv4WxaYXsE1Ghj7rnRttjUucRKajmbFR028JKlRrdqhSY8BInqw(uzllFQKro9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRHdpgQJPj8BIvwjXpA2hnrJps2JOjykwf(sHbQfdFupmRrdqhSY8BInqw(uzllFQKpNEwJBxyWXm0YAo1QTZANhA7Pa2vy5Sg9kJVYZAcW44eRcvlUYsWkqi7hbyof7Jc(iD4rqG8O4AeqIZdBEOewjbIvuSvpL1ObOdwz(nXgilFQSLLpvYCo9Sg3UWGJzOL1Oxz8vEwlUgbK48WMhkHvsGyffB1tznNA12znPTN2fWkHY4SLLFouKtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5zTJXpgKWfg8JK9iZVj2iwjXkBvXIFuspkz8iiqEKamoobtfYhqHH7vIahM1ObOdwz(nXgilFQSLLFEQC6znUDHbhZqlRrVY4R8SwZ60uIlLWkjqajopS5XJK9i8LcdEuspcJFLlmyIKG6ak6cShLSpA(JK9O4AeaFHCBkGv9e5yjVAWJs6rI8rj7JMOXhj7r69iaBkHTHbeR4BEYRMhsZAo1QTZAIRreVowjSsczll)8550ZAo1QTZA0eo2ZLaznUDHbhZqlBz5NRd50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrVY4R8SgnbtXQWxkmqTy4J6HznAa6GvMFtSbYYNkBz5NdLYPN142fgCmdTSg9kJVYZAhCZ47nXKlWWXcmFGLpGIUn(c3XQNua7kSmGWIiCfgYXSMtTA7SM4AeXRJvcRKq2YYpxK50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SMamoorA7PDbSch(cqGdFeeipcFPWGhnZJCQvBtWwJHIUssEhjuhyQJN4(rj9i8LcdisUoFe09OuI8rqG8O4AeqIZdBEOewjbIvuSvp9iiqEKamoorCnIkqyDLbihl5vdYA0a0bRm)MydKLpv2YYpxeKtpRXTlm4ygAznNA12zTZdT9ua7kSCwJgGoyL53eBGS8PYww(5jJC6znUDHbhZqlRrVY4R8SMOpQzDAkXLsyLeiy2HB1GFKShfxJa4lKBtbSQNiwrXw90JGa5rnRttjUucRKajmbFR028JGa5rnRttjUucRKabK48WMhps2JWxkm4rj9ircfpsUhj7r69iaBkHTHbeR4BEYRMhsZAo1QTZAIRreVowjSsczlBznAeKtplFQC6znUDHbhZqlRrVY4R8SM5dUnIXNeqT4kUN8jwIBJWTlm44JK9i8LcdE0SpcFPWaIKRZSMtTA7Swc)c3TZww(550ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcCywZPwTDwtySBuHdFbYwwEDiNEwJBxyWXm0YA0Rm(kpRjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAEtzGD(qr9XiBz5Hs50ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcCywZPwTDwdVowySBmBz5fzo9SMtTA7S2OMsyaf0d44Ke3wwJBxyWXm0YwwErqo9Sg3UWGJzOL1Oxz8vEwJU7iUIBc2Amu0vsY7ibhEmuhtt43eRSsIFuspAIgZAo1QTZAc(KAXv2vuSGSLLpzKtpRXTlm4ygAzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHpccKhzLeRSvfl(rZ(Ou6qwZPwTDwtGpaFyREkBz5t(C6znNA12znj4KBYDWznUDHbhZqlBz5tMZPN142fgCmdTSg9kJVYZAcla8izpcVMsyQJL8QbpA2hnxKpccKhjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAHRvBNTS8PGIC6znUDHbhZqlRrVY4R8SMOpcFPWGhn7JsgqXJGa5r0DhXvCtO7EXQDJJkhaC4HrowYRg8OzF0en(i5EKShj6Jal8qO6ijegyWdwXhCOvBt42fgC8rqG8iWcpeQosWSd3QbRa7ad3gHBxyWXhj7rcW44em7WTAWkWoWWTrIR4(rYL1CQvBN1Whmib9CClRvTX3bhAQcpRrt4DZJQNKPhyHhcvhjHWadEWk(GdTA7SLLpvQC6znUDHbhZqlRrVY4R8SgnbtXQWxkmqTy4J6Hps2Jo4MX3BIjGfEGV3eRyjb(aeweHRWqo(izpY8tzNhsowYRg8OzF0en(izpIU7iUIBc(WpMCSKxn4rZ(OjA8rYEKOpYPwHHvCZsfdEuspk1JGa5ro1kmSIBwQyWJc(Oups2JSsIv2QIf)OKEKiFuY(OjA8rYL1CQvBN1m)u25HzllFQ550ZAC7cdoMHwwZPwTDwdF4hN1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rMFk78qcC4JK9OdUz89MycyHh47nXkwsGpaHfr4kmKJps2JSsIv2QIf)OKEeu6rj7JMOXS2OAwrJzT5ImBz5tPd50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7Sg2AmuGeRLTS8PGs50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7SM02t7cyLqzC2YYNsK50ZAC7cdoMHwwJELXx5znNAfgwXnlvm4rbFuQhj7rMFtSrSsIv2QIf)OzFe(sHbpkThj6JW4x5cdMijOoGIUa7rq3JOoWuhpX9JK7rj7JMOXSMtTA7S25H2EkGDfwoBz5tjcYPN142fgCmdTSg9kJVYZAMFtSrIfW8MYpkPGpseK1CQvBN1Cqitn1IRSeSI9PbNTSL1e2WC6z5tLtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5znbyCCcMkKpGcd3Re5yjVAWJK9irFKamoobtfYhqHH7vICSKxn4rZ(OjA8rqG8OJXpgKWfg8JKlRrdqhSY8BInqw(uzll)8C6znUDHbhZqlR5uR2oRHTgdfDLK8oM1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rcW44KMbvpj2VaaLDEyy1tkpm0p3Gbe4WhbbYJe9ra2SQNaeFmwXk8Lcdulg(OE4JGa5r4lfg8OzEe1bM64jUF0SpcFPWaIKRZhnZJsbfpsUhj7rcW44KMbvpj2VaaLDEyy1tkpm0p3Gbe4Whj7rcW44KMbvpj2VaaLDEyy1tkpm0p3GbKJL8QbpA2hnrJznAa6GvMFtSbYYNkBz51HC6znNA12znS1yOajwlRXTlm4ygAzllpukNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OE4JK9iC4XqDmnHFtSYkj(rZ(OjA8rqG8ibyCCIKhvcRKGFXIpcCywZPwTDwtCnI41XkHvsiBz5fzo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7Sg(WBSvpPa2vy5SLLxeKtpR5uR2oRHp8aCubsSwwJBxyWXm0Yww(Kro9Sg3UWGJzOL1Oxz8vEw7GBgFVjM0mau9Ky)cau25HHvpP8Wq)CdgqyreUcd54JK9i8LcdE0SpcJFLlmyIKG6ak6cSSgWUIAz5tL1CQvBN1O(yOCQvBRgfWYAJcyQ2L4SwBE2YYN850ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZAr2TekAch75szllFYCo9Sg3UWGJzOL1CQvBN1op02tbSRWYzn6vgFLN1eGXXj0DVy1UXrLdao8WiWHps2JeGXXj0DVy1UXrLdao8Wihl5vdE0SpkfrKpkzF0enM1ObOdwz(nXgilFQSLLpfuKtpRXTlm4ygAznNA12znPTN2fWkHY4Sg9kJVYZAcW44e6UxSA34OYbahEye4Whj7rcW44e6UxSA34OYbahEyKJL8QbpA2hLIiYhLSpAIgZA0a0bRm)MydKLpv2YYNkvo9SMtTA7SMRKGViFQfxrVvmiRXTlm4ygAzllFQ550ZAC7cdoMHwwZPwTDw78qBpfWUclN1Oxz8vEwtaghNyvOAXvwcwbcz)iaZPyFuWhPdznAa6GvMFtSbYYNkBz5tPd50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SM5dUnIpct4QWJJUThHBxyWXhj7rI(ibyCCI02t7cyfo8fGah(izpsaghNiT90UawHdFbihl5vdE0SpcFPWGhL2Je9ry8RCHbtKeuhqrxG9iO7ruhyQJN4(rY9OK9rt04JKlRrdqhSY8BInqw(uzllFkOuo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9Whj7r69iROyRE6rYEKOpchEmuhtt43eRSsIF0SpAIgFeeipsVhfxJiUgr86yLWkjqSIIT6Phj7rcW44ePTN2fWkC4la5yjVAWJs6r4WJH6yAc)MyLvs8JGUhL6rj7JMOXhbbYJ07rX1iIRreVowjSsceROyRE6rYEKEpsaghNiT90UawHdFbihl5vdEKCpccKhzLeRSvfl(rZ(Ouj)JK9i9EuCnI4AeXRJvcRKaXkk2QNYAo1QTZAIRreVowjSsczllFkrMtpRXTlm4ygAznNA12znS1yOORKK3XSgnaDWkZVj2az5tL1Oxz8vEwJMGPyv4lfgOwm8r9Whj7rI(i9E0b3m(EtmPzaO6jX(faOSZddREs5HH(5gmGWTlm44JGa5r4lfg8OzFeg)kxyWejb1bu0fypsUSwKb0RcTA7Sg0l(JcSWpkUnuzpkHJHFK8mau9Ky)cavGhL(5HHvp9irOWq)CdgO)JaLu4iWJOoWEeuUAmEKoUssEhFuH)Oal8JeVnuzpAXWh1dF02pckllfg8i8BLEuCRE6rGL8iOx8hfyHFuCFuchd)i5zaO6jX(faQapk9ZddRE6rIqHH(5gm4rbw4hbsSWJ4JOoWEeuUAmEKoUssEhFuH)Oal89i8LcdEubEKapwXpYsWpIUa7rl(JGYE7PDb8JGwz8J27rqz8qBVhPzxHLZww(uIGC6znUDHbhZqlR5uR2oRHTgdfDLK8oM1ObOdwz(nXgilFQSg9kJVYZA0emfRcFPWa1IHpQh(izp6GBgFVjM0mau9Ky)cau25HHvpP8Wq)Cdgq42fgC8rYEeD3rCf3e8J5KB1tk78qYXsE1GhL0Je9r4lfg8O0EKOpcJFLlmyIKG6ak6cShbDpI6atD8e3psUhLSpAIgFKCps2JO7oIR4My(PSZdjhl5vdEusps0hHVuyWJs7rI(im(vUWGjscQdOOlWEe09iQdm1XtC)i5EuY(OjA8rY9izps0hP3JmFWTragZdLDEiHBxyWXhbbYJmFWTragZdLDEiHBxyWXhj7r0DhXvCtagZdLDEi5yjVAWJs6rI(i8LcdEuAps0hHXVYfgmrsqDafDb2JGUhrDGPoEI7hj3Js2hnrJpsUhjxwlYa6vHwTDwd6zzjEK8mau9Ky)cavGhL(5HHvp9irOWq)Cdg8OThbEeuUAmEKoUssEhFuH)Oal89i78qWJ8JF02pIU7iUIB9F0Aj4tCb4hbSn8rWGQNEeuUAmEKoUssEhFuH)Oal89ik8DCBpcFPWGh5slCBpQapI7fEkXJS9rayG5v)ilb)ixAHB7rl(JSsIF0GXThHV3J8oWJw8hfyHVhzNhcEKTpIUs8JwC8hr3DexXD2YYNkzKtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRbmMhk78WSLLpvYNtpRXTlm4ygAznNA12znaFHCBkGv9uwJELXx5zT4AeaFHCBkGv9e5y8JbjCHb)izpsVhjaJJtO7EXQDJJkhaC4HrGdFeeipY8b3gXhHjCv4Xr32JWTlm44JK9OJXpgKWfg8JK9i9EKamoorA7PDbSch(cqGdZA0a0bRm)MydKLpv2YYNkzoNEwZPwTDw7yW2Uv9KYVBfN142fgCmdTSLLFouKtpR5uR2oRjUgrfiSUYaznUDHbhZqlBz5NNkNEwJBxyWXm0YA0Rm(kpRP3JeGXXj0DVy1UXrLdao8WiWHznNA12zn6UxSA34OYbahEyzll)8550ZAC7cdoMHwwJELXx5znbyCCI02t7cyfo8fGah(iiqEe(sHbpAMh5uR2MGTgdfDLK8osOoWuhpX9Js6r4lfgqKCD(iiqEKamooHU7fR2noQCaWHhgbomR5uR2oRjT90UawjugNTS8Z1HC6znUDHbhZqlR5uR2oRDEOTNcyxHLZA0a0bRm)MydKLpv2YYphkLtpRXTlm4ygAzn6vgFLN1IRrexJiEDSsyLeihJFmiHlm4SMtTA7SM4AeXRJvcRKq2YYpxK50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwtaghNGPc5dOWW9krGdZA0a0bRm)MydKLpv2YwwJoyhdNtplFQC6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRz(GBJKiq8CGsOmMWTlm44JK9ibyCCcMkKpGcd3Re5yjVAWJK9ibyCCcMkKpGcd3Re5yjVAWJM9rt0ywJgGoyL53eBGS8PYww(550ZAC7cdoMHwwJELXx5zn9E05vuXy42iEmciSolGbEeeip68kQymCBepgbKJL8QbpkPGpkfu8iiqEKtTcdR4MLkg8OKc(OZROIXWTr8yeqOlCBpkzF08SMtTA7SM4AevGW6kdKTS86qo9Sg3UWGJzOL1Oxz8vEwtVhDEfvmgUnIhJacRZcyGhbbYJoVIkgd3gXJra5yjVAWJsk4Js(hbbYJCQvyyf3SuXGhLuWhDEfvmgUnIhJacDHB7rj7JMN1CQvBN1ogSTBvpP87wXzllpukNEwJBxyWXm0YA0Rm(kpRP3JoVIkgd3gXJraH1zbmWJGa5rNxrfJHBJ4XiGCSKxn4rjf8rPGIhbbYJCQvyyf3SuXGhLuWhDEfvmgUnIhJacDHB7rj7JMN1CQvBN1O7EXQDJJkhaC4HLTS8ImNEwJBxyWXm0YA0Rm(kpRHdpgQJPj8BIvwjXpA2hnrJpccKhjaJJtK8OsyLe8lw8rGdFeeipsybGhj7r41uctDSKxn4rZ(irM1CQvBN1exJiEDSsyLeYwwErqo9Sg3UWGJzOL1Oxz8vEwJU7iUIBI4AeXRJvcRKaHMWVjgOWpNA12(4rZ(OuznNA12znQFy4SLLpzKtpRXTlm4ygAzn6vgFLN1e9r69OZROIXWTr8yeqyDwad8iiqE05vuXy42iEmcihl5vdEuspsKpccKh5uRWWkUzPIbpkPGp68kQymCBepgbe6c32Js2hn)rY9iiqEenbtXQWxkmqTy4J6Hps2J07rhCZ47nXebFsT4kj4USABaHfr4kmKJznNA12zTi7wcfnHJ9CPSLLp5ZPN142fgCmdTSg9kJVYZAhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihFKShHVuyWJM9ry8RCHbtKeuhqrxGL1a2vullFQSMtTA7Sg1hdLtTAB1OawwBuat1UeN1AZZww(K5C6znNA12znAch75sGSg3UWGJzOLTS8PGIC6znUDHbhZqlRrVY4R8SwCnciX5HnpucRKaXkk2QNEKShj6JIRrQ24R9HsyWCS6jcWCk2hn7JM)iiqEuCnciX5HnpucRKa5yjVAWJM9rt04JKlR5uR2oRjaB0e8fiBz5tLkNEwJBxyWXm0YA0Rm(kpRfxJasCEyZdLWkjqSIIT6Phj7r69iaBkHTHbeR4BEYRMhsZAo1QTZAu)WWzllFQ550ZAC7cdoMHwwJELXx5znAc)MyGc)CQvB7JhL0JMte5JK9i6UJ4kUjIRreVowjSsceC4XqDmnHFtSYkj(rj9iqipgkZVj2apkThnpR5uR2oRjaB0e8fiBz5tPd50ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZA4dVXw9KcyxHLZww(uqPC6znUDHbhZqlR5uR2oRHTgdfDLK8oM1Oxz8vEwlUgjmbFR02SsyLeiwrXw90JK9iaBkHTHbeR4BEYRMhsFKShP3JeGXXjsEujSsc(fl(iWHznAa6GvMFtSbYYNkBz5tjYC6znUDHbhZqlRrVY4R8SMamoobF4b4dOK8dlbomR5uR2oRHTgdfiXAzllFkrqo9Sg3UWGJzOL1CQvBN1WhEaoQajwlRrdqhSY8BInqw(uzllFQKro9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1og)yqcxyWps2J07rwrXw90JK9OM1PPexkHvsGGzhUvd(rYEK53eBeRKyLTQyXpkPhLsKps2JWxkm4rZ8iQdm1XtC)OKEKoiYhj7ro1kmSIBwQyWJMn4JGsznAa6GvMFtSbYYNkBz5tL850ZAC7cdoMHwwJELXx5zn9EuCnI4AeXRJvcRKaXkk2QNEKShP3JaSPe2ggqSIV5jVAEi9rqG8OZROIXWTr8yeqyDwad8izps0hrt43edu4NtTABF8OKEukY8hj7ro1kmSIBwQyWJs6rqPhbbYJOj8BIbk8ZPwTTpEuspkfbk9izpYPwHHvCZsfdEuspshEeeipIMWVjgOWpNA12(4rj9OuerWJK7rqG8i9E05vuXy42iEmciSolGbEKShrt43edu4NtTABF8OKEukIiZAo1QTZAIRreVowjSsczllFQK5C6znUDHbhZqlRrVY4R8SMOpsVh1SonL4sjSsceqIZdBE8iiqEKEpY8b3grCnI41XQQXHb12eUDHbhFKCps2JO7oIR4MiUgr86yLWkjqWHhd1X0e(nXkRK4hL0JaH8yOm)Myd8O0E08SMtTA7SMaSrtWxGSLLFouKtpRXTlm4ygAzn6vgFLN1O7oIR4MiUgr86yLWkjqWHhd1X0e(nXkRK4hL0JaH8yOm)Myd8O0E08SMtTA7Sg1pmC2YYppvo9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRrtWuSk8Lcdulg(OE4JK9iC4XqDmnHFtSYkj(rZ(OjA8rYEKOp6GBgFVjM0mau9Ky)cau25HHvpP8Wq)CdgqyreUcd54JK9i6UJ4kUj4hZj3QNu25HKJL8Qbps2JO7oIR4My(PSZdjhl5vdEeeipsVhDWnJV3etAgaQEsSFbak78WWQNuEyOFUbdiSicxHHC8rYL1ObOdwz(nXgilFQSLLF(8C6znNA12znxjbFr(ulUIERyqwJBxyWXm0Yww(56qo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7SgWyEOSZdZww(5qPC6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRDm(XGeUWGFKShz(GBJKiq8CGsOmMWTlm44JK9iZVj2iwjXkBvXIFuspk5ZA0a0bRm)MydKLpv2YYpxK50ZAo1QTZAu)WWznUDHbhZqlBz5NlcYPN142fgCmdTSMtTA7Sg2Amu0vsY7ywJELXx5znAcMIvHVuyGAXWh1dFKShj6Jo4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbeweHRWqo(izpIU7iUIBc(XCYT6jLDEi5yjVAWJK9i6UJ4kUjMFk78qYXsE1GhbbYJ07rhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihFKCznAa6GvMFtSbYYNkBz5NNmYPN1CQvBN1WwJHcKyTSg3UWGJzOLTS8Zt(C6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRDm(XGeUWGZA0a0bRm)MydKLpv2YYppzoNEwJBxyWXm0YAo1QTZAsBpTlGvcLXznAa6GvMFtSbYYNkBz51bOiNEwJBxyWXm0YAo1QTZANhA7Pa2vy5SgnaDWkZVj2az5tLTSLTSgg(a12z5NdfZNdfImfukRj2VU6jqwd6Pieug5HELhkp0)rpk9e8JkPW9ShHV3JGk7QglBaO6rhlIW1XXhbwj(roSTsUXXhrt49ediVUqTQ5hjcG(psh3gdFghFKwjPJpceOnxNpcQ)iBFeud2FuSWuGA7hTH852Eps00K7rIksDkh51fQvn)ira0)r642y4Z44JGk7QglBKuKKdu9iBFeuzx1yzJyPijhO6rIohkPt5iVUqTQ5hjcG(psh3gdFghFeuzx1yzJmNKCGQhz7JGk7QglBeBoj5avps05IaDkh51fQvn)OKb0)r642y4Z44J0kjD8rGaT568rq9hz7JGAW(JIfMcuB)OnKp327rIMMCpsurQt5iVUqTQ5hLmG(psh3gdFghFeuzx1yzJKIKCGQhz7JGk7QglBelfj5avps05IaDkh51fQvn)OKb0)r642y4Z44JGk7QglBK5KKdu9iBFeuzx1yzJyZjjhO6rIohkPt5iVUVUqpfHGYip0R8q5H(p6rPNGFujfUN9i89EeufEmDLeCdQE0XIiCDC8rGvIFKdBRKBC8r0eEpXaYRluRA(rPG(psh3gdFghFeuz(GBJKCGQhz7JGkZhCBKKdHBxyWrO6rU9irylcFO2JenLoLJ86(6c9ueckJ8qVYdLh6)OhLEc(rLu4E2JW37rqfWGQhDSicxhhFeyL4h5W2k5ghFenH3tmG86c1QMFukra0)r642y4Z44J0kjD8rGaT568rq9hz7JGAW(JIfMcuB)OnKp327rIMMCps0u6uoYR7Rl0triOmYd9kpuEO)JEu6j4hvsH7zpcFVhbv0iaQE0XIiCDC8rGvIFKdBRKBC8r0eEpXaYRluRA(rPGcO)J0XTXWNXXhbvGfEiuDKKCGQhz7JGkWcpeQossoeUDHbhHQhj6CDkh51fQvn)Ou6a0)r642y4Z44J0kjD8rGaT568rq9hz7JGAW(JIfMcuB)OnKp327rIMMCps0u6uoYRluRA(rPGsq)hPJBJHpJJpsRK0Xhbc0MRZhb1FKTpcQb7pkwykqT9J2q(CBVhjAAY9irtPt5iVUqTQ5hLsKq)hPJBJHpJJpsRK0Xhbc0MRZhb1FKTpcQb7pkwykqT9J2q(CBVhjAAY9irtPt5iVUVUqpfHGYip0R8q5H(p6rPNGFujfUN9i89EeujSHq1JoweHRJJpcSs8JCyBLCJJpIMW7jgqEDHAvZpkLoa9FKoUng(mo(iTsshFeiqBUoFeu)r2(iOgS)OyHPa12pAd5ZT9EKOPj3JenLoLJ86c1QMFukrc9FKoUng(mo(iO6GBgFVjMKCGQhz7JGQdUz89MysYHWTlm4iu9irtPt5iVUqTQ5hLsea9FKoUng(mo(iTsshFeiqBUoFeu)r2(iOgS)OyHPa12pAd5ZT9EKOPj3Jevh0PCKxxOw18JsjcG(psh3gdFghFeuz(GBJKCGQhz7JGkZhCBKKdHBxyWrO6rIoxNYrEDHAvZpkLia6)iDCBm8zC8rq1b3m(Etmj5avpY2hbvhCZ47nXKKdHBxyWrO6rIMsNYrEDHAvZpkvYd9FKoUng(mo(iOY8b3gj5avpY2hbvMp42ijhc3UWGJq1JenLoLJ86(6c9ueckJ8qVYdLh6)OhLEc(rLu4E2JW37rqfDWoggQE0XIiCDC8rGvIFKdBRKBC8r0eEpXaYRluRA(rPMd9FKoUng(mo(iTsshFeiqBUoFeu)r2(iOgS)OyHPa12pAd5ZT9EKOPj3JenLoLJ86c1QMFuQKzO)J0XTXWNXXhPvs64JabAZ15JG6pY2hb1G9hflmfO2(rBiFUT3Jenn5EKOP0PCKxxOw18JMdfq)hPJBJHpJJpsRK0Xhbc0MRZhb1FKTpcQb7pkwykqT9J2q(CBVhjAAY9irtPt5iVUVUqVsH7zC8rj)JCQvB)Orbma51nRbczAw(5IuKzTWBXRbN1sMEKg8HPW4Jhjcl42471nz6rqz7bEKoaf6)O5qX85VUVUjtpsh3gdF2JWxkm4rlg(OE4JOjykwWJS9rhdczQ9OMf)i6WbGhbyZQEc8O0EemGFuZIFenbtXQWxkmqTy4J6HpI1z4XaqTn51911PwTnGeEmDLeCBMGPHXVYfgS(TlXbLeuhqrxGP)ggeWwHRpgFaZbDQvBtK2EAxaRekJj0fy6JXhWSIhaoOtTABY5H2EkGDfwMqxGPpD7yz12bnFWTrK2EAxaRekJFDDQvBdiHhtxjb3MjyAayjPTvHS966uR2gqcpMUscUntW0ewZgCuHp8aCuC1tkB1z1VUo1QTbKWJPRKGBZemn8bdsqph3EDDQvBdiHhtxjb3MjyAMFk78q9l8GhCZ47nXeWcpW3BIvSKaFaclIWvyihFDDQvBdiHhtxjb3MjyAaJ5HYop81911PwTniyc)c3T1VWdA(nXgzHnqf5KxgGnR6jabgWQe(fUBltaghN4GqMAQfxzjyf7tdMexX9RRtTABWmbttco5MCh8RBY0JGYVpYtWE8rEhFu6N3IiCnQKl)i5HYQo(iUzPIbIW7rI5hf3gQShf3hzjkWJW37rHdpaFGhjWuhgWpQmOk(ib(r2Upce6ssbEK3XhjMFe1BOYE0XESgbEu6N3I4JaHmTWl6JeGXXbKxxNA12GzcMMDElIW1OsUvpPajwt)cpOEMFtSrkGkC4b4711PwTnyMGPbdyvzSK(TlXbHESgCpX1DQidSQdauuFm0VWd6uRWWkUzPIbbtjtubyCCcD3lwTBCu5aGdpmcCiei6r3DexXnHU7fR2noQCaWHhg5yjVAaeiclaiZkjwzRkw8S6auiheiI6uRWWkUzPIbjLsMamoo5yW2Uv9KYVBftGdHaraghNq39Iv7ghvoa4WdJahk3RRtTABWmbtdgWQYyjWRBYuY0JeHJhEGhH70QNEuGf(EuCHfShb3wnEuGf(rjCm8JcHThbLHbB7w1tpse6Uv8JIR4w)hT3Jk8hzj4hr3DexX9JkWJSDF0y7Phz7JI8Wd8iCNw90JcSW3JeHBHfmYJGEXFuVn)Of)rwcgWpIUDSSABWJ8JFKlm4hz7JKy7rIllr1pYsWpkfu8iat3ocE0GzXEa9FKLGFeOKEeUtzWJcSW3JeHBHfSh5W2k5wr9Xia51nzkz6ro1QTbZemTMfJVWDuDmyhyy9l8GGfEiuDK0Sy8fUJQJb7adltubyCCYXGTDR6jLF3kMahcbcD3rCf3KJbB7w1tk)Uvm5yjVAqsPGciqm)MyJyLeRSvflE2uIa5EDDQvBdMjyAuFmuo1QTvJcy63Ueh0UQXYgq)cpiDXWT3gbBGR8wgD3rCf3e6UxSA34OYbahEyKJL8QbYO7oIR4MCmyB3QEs53TIjhl5vdGarp6IHBVnc2ax5Tm6UJ4kUj0DVy1UXrLdao8Wihl5vdEDDQvBdMjyAuFmuo1QTvJcy63UehKgbVUo1QTbZemnQpgkNA12Qrbm9BxIdkSH6dSROwWu6x4bDQvyyf3SuXGz1bzMp42ic1fbQfxfECac3UWGJVUo1QTbZemnQpgkNA12Qrbm9BxIdcm9b2vulyk9l8Go1kmSIBwQyWS6Gm9mFWTreQlculUk84aeUDHbhFDDQvBdMjyAuFmuo1QTvJcy63UehKoyhdRpWUIAbtPFHh0PwHHvCZsfdsA(RRtTABWmbtZpQ3SY2742EDFDDQvBdicByqaFHCBkGv9K(0a0bRm)MydemL(fEqbyCCcMkKpGcd3Re5yjVAGmrfGXXjyQq(akmCVsKJL8QbZorJqGCm(XGeUWGL711PwTnGiSHZemnS1yOORKK3r9PbOdwz(nXgiyk9l8G0emfRcFPWa1IHpQhktaghN0mO6jX(faOSZddREs5HH(5gmGahcbIOa2SQNaeFmwXk8Lcdulg(OEiei4lfgmd1bM64jUNfFPWaIKRZzsbfYjtaghN0mO6jX(faOSZddREs5HH(5gmGahktaghN0mO6jX(faOSZddREs5HH(5gmGCSKxny2jA811PwTnGiSHZemnS1yOajw711PwTnGiSHZemnX1iIxhRewjb9l8G0emfRcFPWa1IHpQhkdhEmuhtt43eRSsINDIgHaraghNi5rLWkj4xS4Jah(66uR2gqe2WzcMg(WBSvpPa2vyz9l8G0emfRcFPWa1IHpQh(66uR2gqe2WzcMg(WdWrfiXAVUo1QTbeHnCMGPr9Xq5uR2wnkGPF7sCW2C9b2vulyk9l8GhCZ47nXKMbGQNe7xaGYopmS6jLhg6NBWaclIWvyihLHVuyWSy8RCHbtKeuhqrxG966uR2gqe2WzcMwKDlHIMWXEUK(fEqAcMIvHVuyGAXWh1dFDDQvBdicB4mbt78qBpfWUclRpnaDWkZVj2abtPFHhuaghNq39Iv7ghvoa4WdJahktaghNq39Iv7ghvoa4WdJCSKxny2uerMSt04RRtTABarydNjyAsBpTlGvcLX6tdqhSY8BInqWu6x4bfGXXj0DVy1UXrLdao8WiWHYeGXXj0DVy1UXrLdao8Wihl5vdMnfrKj7en(66uR2gqe2WzcMMRKGViFQfxrVvm411PwTnGiSHZemTZdT9ua7kSS(0a0bRm)MydemL(fEqbyCCIvHQfxzjyfiK9JamNInOo866uR2gqe2WzcMM02t7cyLqzS(0a0bRm)MydemL(fEqZhCBeFeMWvHhhDBpc3UWGJYevaghNiT90UawHdFbiWHYeGXXjsBpTlGv4WxaYXsE1GzXxkmaQlkg)kxyWejb1bu0fyqh1bM64jULlzNOr5EDDQvBdicB4mbttCnI41XkHvsq)cpinbtXQWxkmqTy4J6HY0Zkk2QNKjko8yOoMMWVjwzLep7encbIEX1iIRreVowjSsceROyREsMamoorA7PDbSch(cqowYRgKeo8yOoMMWVjwzLedDPs2jAece9IRrexJiEDSsyLeiwrXw9Km9eGXXjsBpTlGv4WxaYXsE1a5GaXkjwzRkw8SPsEz6fxJiUgr86yLWkjqSIIT6Px3KPhb9I)Oal8JIBdv2Js4y4hjpdavpj2Vaqf4rPFEyy1tpsekm0p3Gb6)iqjfoc8iQdShbLRgJhPJRKK3Xhv4pkWc)iXBdv2Jwm8r9WhT9JGYYsHbpc)wPhf3QNEeyjpc6f)rbw4hf3hLWXWpsEgaQEsSFbGkWJs)8WWQNEKiuyOFUbdEuGf(rGel8i(iQdShbLRgJhPJRKK3Xhv4pkWcFpcFPWGhvGhjWJv8JSe8JOlWE0I)iOS3EAxa)iOvg)O9Eeugp027rA2vy5xxNA12aIWgotW0WwJHIUssEh1NgGoyL53eBGGP0VWdstWuSk8Lcdulg(OEOmr17GBgFVjM0mau9Ky)cau25HHvpP8Wq)Cdgabc(sHbZIXVYfgmrsqDafDbMCVUjtpc6zzjEK8mau9Ky)cavGhL(5HHvp9irOWq)Cdg8OThbEeuUAmEKoUssEhFuH)Oal89i78qWJ8JF02pIU7iUIB9F0Aj4tCb4hbSn8rWGQNEeuUAmEKoUssEhFuH)Oal89ik8DCBpcFPWGh5slCBpQapI7fEkXJS9rayG5v)ilb)ixAHB7rl(JSsIF0GXThHV3J8oWJw8hfyHVhzNhcEKTpIUs8JwC8hr3DexX9RRtTABarydNjyAyRXqrxjjVJ6tdqhSY8BInqWu6x4bPjykwf(sHbQfdFupu2b3m(EtmPzaO6jX(faOSZddREs5HH(5gmqgD3rCf3e8J5KB1tk78qYXsE1GKefFPWaOUOy8RCHbtKeuhqrxGbDuhyQJN4wUKDIgLtgD3rCf3eZpLDEi5yjVAqsIIVuyauxum(vUWGjscQdOOlWGoQdm1XtClxYorJYjtu9mFWTragZdLDEieiMp42iaJ5HYopugD3rCf3eGX8qzNhsowYRgKKO4lfga1ffJFLlmyIKG6ak6cmOJ6atD8e3YLSt0OCY966uR2gqe2WzcMgWyEOSZd1VWdstWuSk8Lcdulg(OE4RRtTABarydNjyAa(c52uaR6j9PbOdwz(nXgiyk9l8GX1ia(c52uaR6jYX4hds4cdwMEcW44e6UxSA34OYbahEye4qiqmFWTr8rycxfEC0T9KDm(XGeUWGLPNamoorA7PDbSch(cqGdFDDQvBdicB4mbt7yW2Uv9KYVBf)66uR2gqe2WzcMM4AevGW6kd866uR2gqe2WzcMgD3lwTBCu5aGdpm9l8G6jaJJtO7EXQDJJkhaC4HrGdFDDQvBdicB4mbttA7PDbSsOmw)cpOamoorA7PDbSch(cqGdHabFPWGzCQvBtWwJHIUssEhjuhyQJN4oj8LcdisUoHaraghNq39Iv7ghvoa4WdJah(66uR2gqe2WzcM25H2EkGDfwwFAa6GvMFtSbcM611PwTnGiSHZemnX1iIxhRewjb9l8GX1iIRreVowjSscKJXpgKWfg8RRtTABarydNjyAa(c52uaR6j9PbOdwz(nXgiyk9l8GcW44emviFafgUxjcC4R7RRtTABaHgbbt4x4UT(fEqZhCBeJpjGAXvCp5tSe3gHBxyWrz4lfgml(sHbejxNVUo1QTbeAemtW0eg7gv4Wxa9l8GcW44e6UxSA34OYbahEye4WxxNA12acncMjyAEtzGD(qr9Xq)cpOamooHU7fR2noQCaWHhgbo811PwTnGqJGzcMgEDSWy3O(fEqbyCCcD3lwTBCu5aGdpmcC4RRtTABaHgbZemTrnLWakOhWXjjUTxxNA12acncMjyAc(KAXv2vuSa9l8G0DhXvCtWwJHIUssEhj4WJH6yAc)MyLvsCst04RRtTABaHgbZemnb(a8HT6j9l8GcW44e6UxSA34OYbahEye4qiqSsIv2QIfpBkD411PwTnGqJGzcMMeCYn5o4xxNA12acncMjyAHRvBRFHhuybaz41uctDSKxny25IecebyCCcD3lwTBCu5aGdpmcC4RRtTABaHgbZemn8bdsqph30VAJVdo0ufEqAcVBEu9Km9al8qO6ijegyWdwXhCOvBRFHhuu8LcdMnzafqGq3DexXnHU7fR2noQCaWHhg5yjVAWSt0OCYefSWdHQJKqyGbpyfFWHwTneiGfEiuDKGzhUvdwb2bgUnzcW44em7WTAWkWoWWTrIR4wUxxNA12acncMjyAMFk78q9l8G0emfRcFPWa1IHpQhk7GBgFVjMaw4b(EtSILe4dqyreUcd5OmZpLDEi5yjVAWSt0Om6UJ4kUj4d)yYXsE1GzNOrzI6uRWWkUzPIbjLcceNAfgwXnlvmiykzwjXkBvXItsKj7enk3RRtTABaHgbZemn8HFS(JQzfngCUi1VWdstWuSk8Lcdulg(OEOmZpLDEibou2b3m(EtmbSWd89MyfljWhGWIiCfgYrzwjXkBvXItckLSt04RRtTABaHgbZemnS1yOajwt)cpOtTcdR4MLkgemLmZVj2iwjXkBvXINfFPWaOUOy8RCHbtKeuhqrxGbDuhyQJN4wUKDIgFDDQvBdi0iyMGPjT90UawjugRFHh0PwHHvCZsfdcMsM53eBeRKyLTQyXZIVuyauxum(vUWGjscQdOOlWGoQdm1XtClxYorJVUo1QTbeAemtW0op02tbSRWY6x4bDQvyyf3SuXGGPKz(nXgXkjwzRkw8S4lfga1ffJFLlmyIKG6ak6cmOJ6atD8e3YLSt04RRtTABaHgbZemnheYutT4klbRyFAW6x4bn)MyJelG5nLtkOi41911PwTnGqhSJHdc4lKBtbSQN0NgGoyL53eBGGP0VWdA(GBJKiq8CGsOmMWTlm4OmbyCCcMkKpGcd3Re5yjVAGmbyCCcMkKpGcd3Re5yjVAWSt04RRtTABaHoyhdptW0exJOcewxza9l8G6DEfvmgUnIhJacRZcyaiqoVIkgd3gXJra5yjVAqsbtbfqG4uRWWkUzPIbjf88kQymCBepgbe6c3wYo)11PwTnGqhSJHNjyAhd22TQNu(DRy9l8G6DEfvmgUnIhJacRZcyaiqoVIkgd3gXJra5yjVAqsbtEiqCQvyyf3SuXGKcEEfvmgUnIhJacDHBlzN)66uR2gqOd2XWZemn6UxSA34OYbahEy6x4b178kQymCBepgbewNfWaqGCEfvmgUnIhJaYXsE1GKcMckGaXPwHHvCZsfdsk45vuXy42iEmci0fUTKD(RRtTABaHoyhdptW0exJiEDSsyLe0VWdIdpgQJPj8BIvwjXZorJqGiaJJtK8OsyLe8lw8rGdHarybaz41uctDSKxnywr(66uR2gqOd2XWZemnQFyy9l8G0DhXvCtexJiEDSsyLei0e(nXaf(5uR22hZM611PwTnGqhSJHNjyAr2TekAch75s6x4bfvVZROIXWTr8yeqyDwadabY5vuXy42iEmcihl5vdssKqG4uRWWkUzPIbjf88kQymCBepgbe6c3wYoxoiqOjykwf(sHbQfdFupuMEhCZ47nXebFsT4kj4USABaHfr4kmKJVUo1QTbe6GDm8mbtJ6JHYPwTTAuat)2L4GT56dSROwWu6x4bp4MX3BIjndavpj2VaaLDEyy1tkpm0p3GbeweHRWqokdFPWGzX4x5cdMijOoGIUa711PwTnGqhSJHNjyA0eo2ZLaVUo1QTbe6GDm8mbtta2Oj4lG(fEW4AeqIZdBEOewjbIvuSvpjt04AKQn(AFOegmhREIamNID25qGexJasCEyZdLWkjqowYRgm7enk3RRtTABaHoyhdptW0O(HH1VWdgxJasCEyZdLWkjqSIIT6jz6bytjSnmGyfFZtE18q6RRtTABaHoyhdptW0eGnAc(cOFHhKMWVjgOWpNA12(iP5erkJU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsItceYJHY8BInauF(RRtTABaHoyhdptW0WhEJT6jfWUclRFHhKMGPyv4lfgOwm8r9WxxNA12acDWogEMGPHTgdfDLK8oQpnaDWkZVj2abtPFHhmUgjmbFR02SsyLeiwrXw9KmaBkHTHbeR4BEYRMhsLPNamoorYJkHvsWVyXhbo811PwTnGqhSJHNjyAyRXqbsSM(fEqbyCCc(WdWhqj5hwcC4RRtTABaHoyhdptW0WhEaoQajwtFAa6GvMFtSbcM611PwTnGqhSJHNjyAa(c52uaR6j9PbOdwz(nXgiyk9l8GhJFmiHlmyz6zffB1tYAwNMsCPewjbcMD4wnyzMFtSrSsIv2QIfNukrkdFPWGzOoWuhpXDs6GiL5uRWWkUzPIbZgek966uR2gqOd2XWZemnX1iIxhRewjb9l8G6fxJiUgr86yLWkjqSIIT6jz6bytjSnmGyfFZtE18qkeiNxrfJHBJ4XiGW6SagqMO0e(nXaf(5uR22hjLImxMtTcdR4MLkgKeucceAc)MyGc)CQvB7JKsrGsYCQvyyf3SuXGK0biqOj8BIbk8ZPwTTpskfreihei6DEfvmgUnIhJacRZcyaz0e(nXaf(5uR22hjLIiYxxNA12acDWogEMGPjaB0e8fq)cpOO61SonL4sjSsceqIZdBEabIEMp42iIRreVowvnomO2MWTlm4OCYO7oIR4MiUgr86yLWkjqWHhd1X0e(nXkRK4KaH8yOm)Myda1N)66uR2gqOd2XWZemnQFyy9l8G0DhXvCtexJiEDSsyLei4WJH6yAc)MyLvsCsGqEmuMFtSbG6ZFDDQvBdi0b7y4zcMg2Amu0vsY7O(0a0bRm)MydemL(fEqAcMIvHVuyGAXWh1dLHdpgQJPj8BIvwjXZorJYe9GBgFVjM0mau9Ky)cau25HHvpP8Wq)CdgqyreUcd5Om6UJ4kUj4hZj3QNu25HKJL8QbYO7oIR4My(PSZdjhl5vdGarVdUz89MysZaq1tI9laqzNhgw9KYdd9ZnyaHfr4kmKJY966uR2gqOd2XWZemnxjbFr(ulUIERyWRRtTABaHoyhdptW0agZdLDEO(fEqAcMIvHVuyGAXWh1dFDDQvBdi0b7y4zcMgGVqUnfWQEsFAa6GvMFtSbcMs)cp4X4hds4cdwM5dUnsIaXZbkHYyc3UWGJYm)MyJyLeRSvfloPK)11PwTnGqhSJHNjyAu)WWVUo1QTbe6GDm8mbtdBngk6kj5DuFAa6GvMFtSbcMs)cpinbtXQWxkmqTy4J6HYe9GBgFVjM0mau9Ky)cau25HHvpP8Wq)CdgqyreUcd5Om6UJ4kUj4hZj3QNu25HKJL8QbYO7oIR4My(PSZdjhl5vdGarVdUz89MysZaq1tI9laqzNhgw9KYdd9ZnyaHfr4kmKJY966uR2gqOd2XWZemnS1yOajw711PwTnGqhSJHNjyAa(c52uaR6j9PbOdwz(nXgiyk9l8GhJFmiHlm4xxNA12acDWogEMGPjT90UawjugRpnaDWkZVj2abt966uR2gqOd2XWZemTZdT9ua7kSS(0a0bRm)Mydem1R7RRtTABaPnpiWyEOSZdFDDQvBdiT5Zemn8J5KB1tk78q9l8G6jaJJtexJOcewxzaYXsE1aiqeGXXjIRrubcRRma5yjVAGm6UJ4kUjyRXqrxjjVJKJL8QbVUo1QTbK28zcMM5NYopu)cpOEcW44eX1iQaH1vgGCSKxnacebyCCI4AevGW6kdqowYRgiJU7iUIBc2Amu0vsY7i5yjVAWR7RRtTABabybJSBju0eo2ZL0VWdstWuSk8Lcdulg(OEOmr178kQymCBepgbewNfWaqGO35vuXy42iEmciWHYoVIkgd3gXJrajcFUvBpZ5vuXy42iEmcivpRiLdcKZROIXWTr8yeqGdLDEfvmgUnIhJaYXsE1GKGsqXRRtTABabyZemnaFHCBkGv9K(0a0bRm)MydemL(fEq9IRra8fYTPaw1teROyREsM53eBeRKyLTQyXjLmKjQEX1iHj4BL2MvcRKaXkk2QNGaraghNi5rLWkj4xS4JahkRzDAkXLsyLeiHj4BL2MLdcebyCCcMkKpGcd3RebouMamoobtfYhqHH7vICSKxny2jAece9aSPe2ggqSIV5jVAEivMEX1ia(c52uaR6jIvuSvpjZ8BInIvsSYwvS4KsgVUo1QTbeGntW0WhEaoQajw711PwTnGaSzcMg2AmuGeRPFHhuaghNGp8a8bus(HLah(66uR2gqa2mbt7yW2Uv9KYVBfRFHhuVZROIXWTr8yeqyDwadabIENxrfJHBJ4XiGahkt0ZROIXWTr8yeqIWNB12ZCEfvmgUnIhJas1ZohkGa58kQymCBepgbe6c3wWuYbbY5vuXy42iEmciWHYoVIkgd3gXJra5yjVAqsqjOaceHfaKzLeRSvflE2uqXRRtTABabyZemnX1iQaH1vgq)cpOENxrfJHBJ4XiGW6Sagace9oVIkgd3gXJrabou25vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6zNdfqGCEfvmgUnIhJacCOSZROIXWTr8yeqowYRgK0COaceHfaKzLeRSvflE25qXRRtTABabyZemn6UxSA34OYbahEy6x4b178kQymCBepgbewNfWaqGqxmC7Tr6AkHPWDwgD3rCf3eX1iQaH1vgGCSKxnace9OlgU92iDnLWu4oltu9oVIkgd3gXJrabou25vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6z1bOacKZROIXWTr8yeqGdLDEfvmgUnIhJaYXsE1GKMdfqGO35vuXy42iEmciWHYbbIWcaYSsIv2QIfpRoafVUo1QTbeGntW0WhEJT6jfWUclRFHhKMGPyv4lfgOwm8r9WxxNA12acWMjyAUsc(I8PwCf9wXGxxNA12acWMjyAIRreVowjSsc6x4bXHhd1X0e(nXkRK4zNNSt0OmaBkHTHbeR4BEYRMhsHaraghNi5rLWkj4xS4JahcbIEa2ucBddiwX38KxnpKktuC4XqDmnHFtSYkjE2jAeceAcMIvHVuyGAXWh1dLjAZ60uIlLWkjqWSd3QbllUgbWxi3McyvprSIIT6jzX1ia(c52uaR6jYX4hds4cdgcKM1PPexkHvsGeMGVvABwMEcW44ePTN2fWkC4labouMOa2SQNaeFmwXk8Lcdulg(OEiei4lfgmd1bM64jUNfFPWaIKRtOZPwTnbBngk6kj5DKqDGPoEI7KvhKtoiqewaqMvsSYwvS4ztbfY966uR2gqa2mbtdBngk6kj5DuFAa6GvMFtSbcMs)cpiGnLW2WaIv8np5vZdPYIRrctW3kTnRewjbIvuSvpjtpbyCCIKhvcRKGFXIpcC4RRtTABabyZemnS1yOajw711PwTnGaSzcMg1pmS(fEqNAfgwXnlvmiPuY07GBgFVjMCbgowG5dS8bu0TXx4ow9KcyxHLbeweHRWqo(66uR2gqa2mbtta2Oj4lG(fEqNAfgwXnlvmiPuY07GBgFVjMCbgowG5dS8bu0TXx4ow9KcyxHLbeweHRWqokJU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsItceYJHY8BInGmrPj8BIbk8ZPwTTpsAorKqGexJasCEyZdLWkjqSIIT6j5EDDQvBdiaBMGPbmMhk78q9l8G0emfRcFPWa1IHpQh(66uR2gqa2mbttA7PDbSsOmwFAa6GvMFtSbcMs)cpO5dUnIpct4QWJJUThHBxyWrzIkaJJtK2EAxaRWHVae4qzcW44ePTN2fWkC4la5yjVAWS4lfga1ffJFLlmyIKG6ak6cmOJ6atD8e3YLSt0Om9eGXXjIRrubcRRma5yjVAaeicW44ePTN2fWkC4la5yjVAGSM1PPexkHvsGeMGVvABwUxxNA12acWMjyAyRXqrxjjVJ6tdqhSY8BInqWu6x4bXHhd1X0e(nXkRK4zNOrz0emfRcFPWa1IHpQh(66uR2gqa2mbt78qBpfWUclRpnaDWkZVj2abtPFHhuaghNyvOAXvwcwbcz)iaZPydQdqGexJasCEyZdLWkjqSIIT6PxxNA12acWMjyAsBpTlGvcLX6x4bJRrajopS5HsyLeiwrXw90RRtTABabyZemnaFHCBkGv9K(0a0bRm)MydemL(fEWJXpgKWfgSmZVj2iwjXkBvXItkzabIamoobtfYhqHH7vIah(66uR2gqa2mbttCnI41XkHvsq)cpyZ60uIlLWkjqajopS5Hm8LcdscJFLlmyIKG6ak6cSKDUS4AeaFHCBkGv9e5yjVAqsImzNOrz6bytjSnmGyfFZtE18q6RRtTABabyZemnAch75sGxxNA12acWMjyAyRXqrxjjVJ6tdqhSY8BInqWu6x4bPjykwf(sHbQfdFup811PwTnGaSzcMM4AeXRJvcRKG(fEWdUz89MyYfy4ybMpWYhqr3gFH7y1tkGDfwgqyreUcd54RRtTABabyZemnPTN2fWkHYy9PbOdwz(nXgiyk9l8GcW44ePTN2fWkC4laboece8LcdMXPwTnbBngk6kj5DKqDGPoEI7KWxkmGi56e6sjsiqIRrajopS5HsyLeiwrXw9eeicW44eX1iQaH1vgGCSKxn411PwTnGaSzcM25H2EkGDfwwFAa6GvMFtSbcM611PwTnGaSzcMM4AeXRJvcRKG(fEqrBwNMsCPewjbcMD4wnyzX1ia(c52uaR6jIvuSvpbbsZ60uIlLWkjqctW3kTndbsZ60uIlLWkjqajopS5Hm8LcdssKqHCY0dWMsyByaXk(MN8Q5H0x3xxNA12aIDvJLnqqm(vUWG1VDjoiiqtvWH6JXhWCqbyCCYXGTDR6jLF3kMahcbIamooHU7fR2noQCaWHhgbo811PwTnGyx1yzdmtW0W4x5cdw)2L4Ga72Esbc0ufCO(y8bmhKUy42BJGnWvEltaghNCmyB3QEs53TIjWHYeGXXj0DVy1UXrLdao8WiWHqGOhDXWT3gbBGR8wMamooHU7fR2noQCaWHhgbo811PwTnGyx1yzdmtW0W4x5cdw)2L4Ga72Esbc0u1XsE1a93WGa2kC9PBhlR2oiDXWT3gbBGR8wFm(aMds3DexXn5yW2Uv9KYVBftowYRgmRim0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaqFm(aMv8aWbP7oIR4Mq39Iv7ghvoa4WdJCSKxnqnbZaG(fEqbyCCcD3lwTBCu5aGdpmsCf3VUo1QTbe7QglBGzcMgg)kxyW63Uehey32tkqGMQowYRgO)ggeWwHRpD7yz12bPlgU92iydCL36JXhWCq6UJ4kUjhd22TQNu(DRyYXsE1a9X4dywXdahKU7iUIBcD3lwTBCu5aGdpmYXsE1a1emda6x4bfGXXj0DVy1UXrLdao8WiWHVUo1QTbe7QglBGzcMgg)kxyW63UeheeOPQJL8Qb6VHbbSv46t3owwTDq6IHBVnc2ax5T(y8bmhKU7iUIBYXGTDR6jLF3kMCSKxnijryO7oIR4Mq39Iv7ghvoa4WdJCSKxnqnbZaG(y8bmR4bGds3DexXnHU7fR2noQCaWHhg5yjVAGAcMbGxxNA12aIDvJLnWmbtdgWQYyjG(GXAGG2vnw2sPFHhuurTRASSrsrs4afmGvcW44qGqxmC7TrWg4kVLzx1yzJKIKWbk6UJ4kULtMOy8RCHbta2T9KceOPk4qzIQhDXWT3gbBGR8wME2vnw2iZjjCGcgWkbyCCiqOlgU92iydCL3Y0ZUQXYgzojHdu0DhXvCdbIDvJLnYCcD3rCf3KJL8QbqGyx1yzJKIKWbkyaReGXXLjQE2vnw2iZjjCGcgWkbyCCiqSRASSrsrO7oIR4MeHp3QTtkODvJLnYCcD3rCf3Ki85wTTCqGyx1yzJKIKWbk6UJ4kULPNDvJLnYCschOGbSsaghxMDvJLnskcD3rCf3Ki85wTDsbTRASSrMtO7oIR4MeHp3QTLdce9W4x5cdMaSB7jfiqtvWHYevp7QglBK5KeoqbdyLamoUmrTRASSrsrO7oIR4MeHp3QTHorolg)kxyWeqGMQowYRgabcg)kxyWeqGMQowYRgKKDvJLnskcD3rCf3Ki85wTnuFUCqGyx1yzJmNKWbkyaReGXXLjQDvJLnskschOGbSsaghxMDvJLnskcD3rCf3Ki85wTDsbTRASSrMtO7oIR4MeHp3QTLjQDvJLnskcD3rCf3Ki85wTn0jYzX4x5cdMac0u1XsE1aiqW4x5cdMac0u1XsE1GKSRASSrsrO7oIR4MeHp3QTH6ZLdcer1ZUQXYgjfjHduWawjaJJdbIDvJLnYCcD3rCf3Ki85wTDsbTRASSrsrO7oIR4MeHp3QTLtMO2vnw2iZj0DhXvCto2JbKzx1yzJmNq3DexXnjcFUvBdDImjm(vUWGjGanvDSKxnqgg)kxyWeqGMQowYRgmRDvJLnYCcD3rCf3Ki85wTnuFoei6zx1yzJmNq3DexXn5ypgqMO2vnw2iZj0DhXvCtowYRgaDICwm(vUWGja72Esbc0u1XsE1azy8RCHbta2T9KceOPQJL8QbjnhkKjQDvJLnskcD3rCf3Ki85wTn0jYzX4x5cdMac0u1XsE1aiqSRASSrMtO7oIR4MCSKxna6e5Sy8RCHbtabAQ6yjVAGm7QglBK5e6UJ4kUjr4ZTABOlfumdg)kxyWeqGMQowYRgmlg)kxyWeGDBpPabAQ6yjVAaeiy8RCHbtabAQ6yjVAqs2vnw2iPi0DhXvCtIWNB12q95qGGXVYfgmbeOPk4q5GaXUQXYgzoHU7iUIBYXsE1aOtKjHXVYfgmby32tkqGMQowYRgitu7QglBKue6UJ4kUjr4ZTABOtKZIXVYfgmby32tkqGMQowYRgabIDvJLnskcD3rCf3Ki85wT9S41uctDSKxnqgg)kxyWeGDBpPabAQ6yjVAWm2vnw2iPi0DhXvCtIWNB12jHxtjm1XsE1aiq0ZUQXYgjfjHduWawjaJJltum(vUWGjGanvDSKxnij7QglBKue6UJ4kUjr4ZTABO(CiqW4x5cdMac0ufCOCYjNCYjheiMFtSrSsIv2QIfplg)kxyWeqGMQowYRgihei6zx1yzJKIKWbkyaReGXXLPhDXWT3gbBGR8wMO2vnw2iZjjCGcgWkbyCCzIkQEy8RCHbtabAQcoece7QglBK5e6UJ4kUjhl5vdssKYjtum(vUWGjGanvDSKxniP5qbei2vnw2iZj0DhXvCtowYRgaDImjm(vUWGjGanvDSKxnqo5Garp7QglBK5KeoqbdyLamoUmr1ZUQXYgzojHdu0DhXvCdbIDvJLnYCcD3rCf3KJL8QbqGyx1yzJmNq3DexXnjcFUvBNuq7QglBKue6UJ4kUjr4ZTAB5KtozIQNDvJLnsksbiuNMGvlUYPIiCDCuzh7a4JbqG4uRWWkUzPIbZoxMamooXPIiCDCuj27iboeceNAfgwXnlvmiPuY0taghN4ureUooQe7DKahk3RRtTABaXUQXYgyMGPbdyvzSeqFWynqq7QglBZ1VWdkQO2vnw2iZjjCGcgWkbyCCiqOlgU92iydCL3YSRASSrMts4afD3rCf3Yjtum(vUWGja72Esbc0ufCOmr1JUy42BJGnWvEltp7QglBKuKeoqbdyLamooei0fd3EBeSbUYBz6zx1yzJKIKWbk6UJ4kUHaXUQXYgjfHU7iUIBYXsE1aiqSRASSrMts4afmGvcW44Yevp7QglBKuKeoqbdyLamooei2vnw2iZj0DhXvCtIWNB12jf0UQXYgjfHU7iUIBse(CR2woiqSRASSrMts4afD3rCf3Y0ZUQXYgjfjHduWawjaJJlZUQXYgzoHU7iUIBse(CR2oPG2vnw2iPi0DhXvCtIWNB12YbbIEy8RCHbta2T9KceOPk4qzIQNDvJLnskschOGbSsaghxMO2vnw2iZj0DhXvCtIWNB12qNiNfJFLlmyciqtvhl5vdGabJFLlmyciqtvhl5vdsYUQXYgzoHU7iUIBse(CR2gQpxoiqSRASSrsrs4afmGvcW44Ye1UQXYgzojHduWawjaJJlZUQXYgzoHU7iUIBse(CR2oPG2vnw2iPi0DhXvCtIWNB12Ye1UQXYgzoHU7iUIBse(CR2g6e5Sy8RCHbtabAQ6yjVAaeiy8RCHbtabAQ6yjVAqs2vnw2iZj0DhXvCtIWNB12q95YbbIO6zx1yzJmNKWbkyaReGXXHaXUQXYgjfHU7iUIBse(CR2oPG2vnw2iZj0DhXvCtIWNB12Yjtu7QglBKue6UJ4kUjh7XaYSRASSrsrO7oIR4MeHp3QTHorMeg)kxyWeqGMQowYRgidJFLlmyciqtvhl5vdM1UQXYgjfHU7iUIBse(CR2gQphce9SRASSrsrO7oIR4MCShditu7QglBKue6UJ4kUjhl5vdGorolg)kxyWeGDBpPabAQ6yjVAGmm(vUWGja72Esbc0u1XsE1GKMdfYe1UQXYgzoHU7iUIBse(CR2g6e5Sy8RCHbtabAQ6yjVAaei2vnw2iPi0DhXvCtowYRgaDICwm(vUWGjGanvDSKxnqMDvJLnskcD3rCf3Ki85wTn0LckMbJFLlmyciqtvhl5vdMfJFLlmycWUTNuGanvDSKxnacem(vUWGjGanvDSKxnij7QglBK5e6UJ4kUjr4ZTABO(CiqW4x5cdMac0ufCOCqGyx1yzJKIq3DexXn5yjVAa0jYKW4x5cdMaSB7jfiqtvhl5vdKjQDvJLnYCcD3rCf3Ki85wTn0jYzX4x5cdMaSB7jfiqtvhl5vdGaXUQXYgzoHU7iUIBse(CR2Ew8AkHPowYRgidJFLlmycWUTNuGanvDSKxnyg7QglBK5e6UJ4kUjr4ZTA7KWRPeM6yjVAaei6zx1yzJmNKWbkyaReGXXLjkg)kxyWeqGMQowYRgKKDvJLnYCcD3rCf3Ki85wTnuFoeiy8RCHbtabAQcouo5Kto5KdceZVj2iwjXkBvXINfJFLlmyciqtvhl5vdKdce9SRASSrMts4afmGvcW44Y0JUy42BJGnWvEltu7QglBKuKeoqbdyLamoUmrfvpm(vUWGjGanvbhcbIDvJLnskcD3rCf3KJL8Qbjjs5Kjkg)kxyWeqGMQowYRgK0COace7QglBKue6UJ4kUjhl5vdGorMeg)kxyWeqGMQowYRgiNCqGONDvJLnskschOGbSsaghxMO6zx1yzJKIKWbk6UJ4kUHaXUQXYgjfHU7iUIBYXsE1aiqSRASSrsrO7oIR4MeHp3QTtkODvJLnYCcD3rCf3Ki85wTTCYjNmr1ZUQXYgzoPaeQttWQfx5ureUooQSJDa8XaiqCQvyyf3SuXGzNltaghN4ureUooQe7DKahcbItTcdR4MLkgKukz6jaJJtCQicxhhvI9osGdL711PwTnGyx1yzdmtW0GbSQmws)2L4GqpwdUN46ovKbw1bakQpgzlB5ma]] )


end