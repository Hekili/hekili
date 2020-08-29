-- HunterSurvival.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'HUNTER' then
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
        aspect_of_the_cheetah = {
            id = 186258,
            duration = 9,
            max_stack = 1,
        },
        aspect_of_the_cheetah_sprint = {
            id = 186257, 
            duration = 3,
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
            duration = 20,
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
            cooldown = function () return talent.born_to_be_wild.enabled and 144 or 180 end,
            gcd = "spell",

            startsCombat = false,
            texture = 132242,

            handler = function ()
                applyBuff( "aspect_of_the_cheetah_sprint" )
                applyBuff( "aspect_of_the_cheetah", 12 )
            end,
        },


        aspect_of_the_eagle = {
            id = 186289,
            cast = 0,
            cooldown = function () return talent.born_to_be_wild.enabled and 72 or 90 end,
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
            cooldown = function () return talent.born_to_be_wild.enabled and 144 or 180 end,
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
            end,
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
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
            gcd = "spell",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                setDistance( 15 )
                if talent.posthaste.enabled then applyBuff( "posthaste" ) end
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
            end,
        },


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
        },


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


        flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135815,

            handler = function ()
                applyDebuff( "target", "flare" )
            end,
        },


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

                if debuff.shrapnel_bomb.up then applyDebuff( "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end
            end,
        },


        kill_shot = {
            id = 320976,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 10,
            spendType = "focus",
            
            startsCombat = true,
            texture = 236174,
            
            usable = function () return target.health.pct < 20, "requires target health below 20 percent" end,            
            handler = function ()
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
            end,

            copy = { "raptor_strike_eagle", 265189 },
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
                summonPet( 'made_up_pet', 3600, 'ferocity' )
            end,
        },


        tar_trap = {
            id = 187698,
            cast = 0,
            cooldown = 30,
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
            
            usable = function () return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires dispellable_enrage or dispellable_magic" end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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

        potion = "unbridled_fury",

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

    spec:RegisterPack( "Survival", 20200829.1, [[dOKU)bqiqWJaLWLebO2Kc8jfrfJseXPebTkrKELIQzru1TerXUi1ViQmmIKogizzGs9mrunnqj6AGqBtreFteLACkI05ueL1jcO5bsDpIyFejoOikzHePEOiaCrrGOpkcGmsraItkcKSsq0mfbQUPIOs7euzOIaOwQiq5PQQPcQ6RIaKgRiqyVq9xcdMKdtzXQ4XiMSOUmQntvFwKgTI0PLSAfrvVgumBQCBvz3k9BPgUcDCrGulhYZbMUW1vPTRO8Df04veoVi06bL08jk7hPXqHHh)ZwWy4GTuHTuL6Kc7jtdfeLkujhI4FK4iJ)JgbglLX)1Em()VOz1mZH)JwIU2Yy4XFqFreg)NgXiibkNCPvm9E0K(jhOExNfvVeK5d5a1Jih(FULlsqT4d(NTGXWbBPcBPk1jf2tMgkikvOG9KH)2nM2i8)xVRZIQ3eaiZh4)0kN5fFW)mdi4pSGQ(x0SAM5OQeqUBWikKWcQkzDtVGGQG9KjpvbBPcBPsHKcjSGQsam12ugKaPqclOQKHQsw5mNPQj3lScRoMQIMQYS3UUGQmsu9svUceAkKWcQkzOQeatTnLZuvyOuoeLNQ4jgrmau9cOQOPksIehlcdLYbqtHewqvjdvn525YxCMQigAglizevfnvnSrWqvVgXufBGYLivnSIPuvmLPklN7DYbqv1B0XpEdlQEPQ2tvZmuzhhRPqclOQKHQsw5mNPQBuUksKQswjaNGRXFxbcagE83gbbgEmCqHHh)51oooJLg)jOkyuz4)569As3OCTwWzHba21f67ivnGQscvDUEVM0nkxRfCwyaGDDHgXpRwavbnvbLgIuvsPQusMQKjJQoxVxFCxKO9IWC9c03rQAavDUEV(4Uir7fH56fOr8ZQfqvqtvqPHivLuQkLKPQeI)gjQEX)xVPDdyXPcghy4GngE8Nx744mwA8NGQGrLH)NR3RjDJY1AbNfgayxxOVJu1aQkju1569As3OCTwWzHba21fAe)SAbuf0ufuAisvjLQsjzQsMmQ6C9E9XDrI2lcZ1lqFhPQbu15696J7IeTxeMRxGgXpRwavbnvbLgIuvsPQusMQsi(BKO6f)r2y0ibiqfmmoWWLCm84pV2XXzS04pbvbJkd)9n5cOQ5ufXaHaXP8svqtv(MCb6Nnb(BKO6f)9oBHP2ubiqfmmoWWblXWJ)8AhhNXsJ)gjQEXFykNtq63Z2m(tqvWOYWF)15eiMm1qPSiQhtvqtvqPHivLuQkLKPQbuLVjxavnNQigieioLxQcAQY3Klq)SjWFsIehlcdLYbadhu4adheXWJ)8AhhNXsJ)eufmQm833KlGQMtvedeceNYlvbnv5BYfOF2e4VrIQx8hem7ebYgXbgUjbdp(ZRDCCgln(tqvWOYWFFtUaQAovrmqiqCkVuf0uLVjxG(ztqvdOkiqvrrGP2uQAavbbQ6C9E9JFnkrr7fUlPYImIThqFhPQbuvsOk)15eiMm1qPSiQhtvqtvqPHivLuQkLKPkzYOkiqv5o0dlx2xiwC63rhfbMAtPQbufeOQZ171KUr5ATGZcdaSRl03rQsMmQccuvUd9WYL9fIfN(D0rrGP2uQAavDUEV(1BA3aw4VOe1GWiWqvqtvqrvjKQKjJQI6XIOf5IPkOPkOMuQAavbbQk3HEy5Y(cXIt)o6OiWuBk(BKO6f)hwUSVqS40VdoWWLSXWJ)8AhhNXsJ)eufmQm8hcuvUdnGrJ8gcquBQokcm1MsvdOkiqvNR3RjDJY1AbNfgayxxOVJ4VrIQx8hWOrEdbiQnfhy4Mum84pV2XXzS04VrIQx8hMY5eK(9SnJ)eufmQm833KlGQMtvedeceNYlvbnv5BYfOF2eu1aQkju15696xVPDdyH)IsudcJadvbnvbrQsMmQY3KlGQGMQmsu9QF9M2nGfNkynPbbvLq8NKiXXIWqPCaWWbfoWWnzy4XFETJJZyPXFcQcgvg(JypIbtTJJPQbufeOQZ171KUr5ATGZcdaSRl03rQAavDUEV(1BA3aw4VOe1GWiWqvqtvqe)nsu9I)agnYBiarTP4adhusfdp(ZRDCCgln(tqvWOYWFiqvNR3RjDJY1AbNfgayxxOVJ4VrIQx83eVlkZir7feupeGdmCqbfgE8Nx744mwA8NGQGrLH)qGQoxVxt6gLR1colmaWUUqFhXFJevV4pPBuUwl4SWaa76cCGHdkyJHh)51oooJLg)jOkyuz4)5696xVPDdyH)IsuFhPkzYOkFtUaQAovrmqiqCkVuLuOkFtUa9ZMGQsgQckPsvYKrvNR3RjDJY1AbNfgayxxOVJ4VrIQx8)1BA3awCQGXbgoOsogE83ir1l(JSXOrcqGkyy8Nx744mwACGHdkyjgE8Nx744mwA8NGQGrLH)qGQIIatTP4VrIQx8Fy5Y(cXIt)o4ah4pXX2mgdpgoOWWJ)8AhhNXsJ)9i(d4O84VrIQx8FMHk74y8FMHeR9y8NyOzSGKr4pbvbJkd)nsuZybV8Ryavbnvbr8FM5USGDag)Hi(pZCxg)nsuZybV8RyaoWWbBm84pV2XXzS04pbvbJkd)nyLrvW6J7IeTxeMRxGgzlmuLuOkPsvdOQKqvNR3RjDJY1AbNfgayxxOVJu1aQkju1569As3OCTwWzHba21fAe)SAbuf0ufuAisvjLQsjzQsMmQ6C9E9XDrI2lcZ1lqFhPQbu15696J7IeTxeMRxGgXpRwavbnvbLgIuvsPQusMQKjJQoxVxt6gLR1colmaWUUqJ4NvlGQgqvqGQoxVxFCxKO9IWC9c0i(z1cOQesvje)nsu9I)VEt7gWItfmoWWLCm84pV2XXzS04VrIQx8)1BA3awCQGXFcQcgvg(N5Z171ol4neJDb6vdcJadvjfQkjuLrIAgl4LFfdOkzYOQjJQsivnGQcdLYHoQhlIwKlMQGMQmsuZybV8RyavLuQkLKX)WqPCikp(JdmCWsm84VrIQx83eVlkZir7feupeG)8AhhNXsJdmCqedp(BKO6f)jDJY1AbNfgayxxG)8AhhNXsJdmCtcgE8Nx744mwA8NGQGrLH)5o0GPiBCzN40VJokcm1MsvdOkiqvH54n0ttmJmG4ubR51oootvYKrv5o0GPiBCzN40VJokcm1MsvdOkJe1mwWl)kgqvsHQGi(BKO6f)jgAgJdmCjBm84pV2XXzS04pbvbJkd)HavfMJ3qNEzeQCotegjkcqZRDCCMQKjJQ8xNtGyYudLYIOEmvbnvLsYuLmzufYQSGNXBOTCgOr8ZQfqvqtvtcvnGQqwLf8mEdTLZanprbca(BKO6f)hwUSVqS40VdoWWnPy4XFETJJZyPXFcQcgvg(tMAOugi8iJevVMJQKcvbBnePkzYOQChAWuKnUStC63rhfbMAtPkzYOks3UCpC1dlx2xiwC63rJ4NvlGQKcvzKOMXcE5xXaQkzOQusMQKjJQY85696JR7SO9Iykl4LFjQr8ZQfqvYKrviRYcEgVH2YzGgXpRwavbnvbrQAavHSkl4z8gAlNbAEIcea83ir1l(FUbzkJsehy4Mmm84pV2XXzS04VrIQx8)1BA3awCQGXFcQcgvg(N5Z171ol4neJDb6vdcJadvjfQAsX)WqPCikp(JdmCqjvm84VrIQx8Nm1Gbzpa(ZRDCCglnoWWbfuy4XFETJJZyPXFJevV4pmLZji97zBg)jOkyuz4VVjxavnNQigieioLxQcAQY3Klq)SjWFsIehlcdLYbadhu4adhuWgdp(ZRDCCgln(tqvWOYW)WC8g6GrpGO9cEtTu(XBO51oooJ)gjQEX)PgAS7fhy4Gk5y4XFETJJZyPXFcQcgvg(hMJ3qNEzeQCotegjkcqZRDCCg)nsu9I)ednJXbgoOGLy4XFETJJZyPXFcQcgvg(t62L7HREy5Y(cXIt)oAe)SAbuLuOQKqvgjQzSGx(vmGQKjJQGivLq83ir1l(FUbzkJsehy4GcIy4XFETJJZyPXFcQcgvg(7BYfqvZPkIbcbIt5LQGMQ8n5c0pBc83ir1l(7D2ctTPcqGkyyCGHdQjbdp(ZRDCCgln(tqvWOYW)Ch6HLl7lelo97OrShXGP2XXuLmzuvyoEd9WYL9fIf16VGQxnV2XXz83ir1l(pSCzFHyXPFhCGHdQKngE8Nx744mwA83ir1l(dy0iVHae1MI)eufmQm8)C9E9SAKraXmE7NgXgjWFsIehlcdLYbadhu4adhutkgE8Nx744mwA8NGQGrLH)KUD5E4QhwUSVqS40VJgXpRwavjfQAMHk74ynXqZybjJOQeWufSXFJevV4pXqZyCGHdQjddp(BKO6f)bbZorGSr8Nx744mwACGHd2sfdp(ZRDCCgln(BKO6f)bmAK3qaIAtXFcQcgvg(JypIbtTJJPQbu15696OgfTxetzbyKnKgegbgQcAQk5u1aQA5jcXWsC63rpRDwuoMQKjJQqShXGP2XXu1aQYGvgvbRDwWBig7c0RgzlmuLuOkPI)KejowegkLdagoOWbgoydfgE83ir1l(dt5CcW0oWFETJJZyPXbgoydBm84pV2XXzS04VrIQx8)1BA3awCQGXFsIehlcdLYbadhu4adhStogE8Nx744mwA83ir1l(JSXOrcqGkyy8NKiXXIWqPCaWWbfoWb(dcm8y4Gcdp(ZRDCCgln(tqvWOYW)WC8g6GrpGO9cEtTu(XBO51oooJ)gjQEX)PgAS7fhy4GngE8Nx744mwA8NGQGrLH)(MCbu1CQIyGqG4uEPkOPkFtUa9ZMa)nsu9I)ENTWuBQaeOcgghy4sogE8Nx744mwA8NGQGrLH)NR3RjDJY1AbNfgayxxOVJu1aQkju1569As3OCTwWzHba21fAe)SAbuf0ufuAisvjLQsjzQsMmQ6C9E9XDrI2lcZ1lqFhPQbu15696J7IeTxeMRxGgXpRwavbnvbLgIuvsPQusMQsi(BKO6f)r2y0ibiqfmmoWWblXWJ)8AhhNXsJ)eufmQm8)C9EnPBuUwl4SWaa76c9DKQgqvjHQoxVxt6gLR1colmaWUUqJ4NvlGQGMQGsdrQkPuvkjtvYKrvNR3RpUls0EryUEb67ivnGQoxVxFCxKO9IWC9c0i(z1cOkOPkO0qKQskvLsYuvcXFJevV4)R30UbS4ubJdmCqedp(ZRDCCgln(BKO6f)HPCobPFpBZ4pbvbJkd)9n5cOQ5ufXaHaXP8svqtv(MCb6Nnb(tsK4yryOuoay4Gchy4Mem84pV2XXzS04pbvbJkd)pxVxpRgzeqmJ3(PVJu1aQ6C9E9SAKraXmE7NgXpRwavbnvbfvLuQkLKXFJevV4pGrJ8gcquBkoWWLSXWJ)8AhhNXsJ)eufmQm833KlGQMtvedeceNYlvbnv5BYfOF2e4VrIQx8hem7ebYgXbgUjfdp(ZRDCCgln(tqvWOYWFFtUaQAovrmqiqCkVuf0uLVjxG(ztqvdOke7rmyQDCmvnGQ8xNtGyYudLYIOEmvbnvLsYu1aQccu15696h)AuII2lCxsLfzeBpG(osvYKrv(MCbu1CQIyGqG4uEPkOPkFtUa9ZMGQgqvjHQGavL7qpSCzFHyXPFhDueyQnLQgqvjHQGavDUEVM0nkxRfCwyaGDDH(osvYKrvNR3RF9M2nGf(lkrnimcmuf0ufuuLmzuvupweTixmvbnvb1KsvYKrvqGQYDOhwUSVqS40VJokcm1MsvdOkdwzufSEy5YmAzaqaUOz1mZPr2cdvjfQsQuvcPQesvdOkiqvNR3RF8RrjkAVWDjvwKrS9a67i(BKO6f)hwUSVqS40VdoWWnzy4XFETJJZyPXFcQcgvg(FUEVEwnYiGygV9tFhPQbuvUdnGrJ8gcquBQgXpRwavbnvblPQKsvPKmvjtgvL7qdy0iVHae1MQrShXGP2XXu1aQccu1569As3OCTwWzHba21f67i(BKO6f)bmAK3qaIAtXbgoOKkgE8Nx744mwA8NGQGrLH)qGQoxVxt6gLR1colmaWUUqFhXFJevV4VjExuMrI2liOEiahy4Gckm84pV2XXzS04pbvbJkd)HavDUEVM0nkxRfCwyaGDDH(oI)gjQEXFs3OCTwWzHba21f4adhuWgdp(ZRDCCgln(tqvWOYW)Z171VEt7gWc)fLO(osvYKrv(MCbu1CQIyGqG4uEPkPqv(MCb6NnbvLmufSLkvnGQcZXBONvJmciMXB)08AhhNPkzYOkFtUaQAovrmqiqCkVuLuOkFtUa9ZMGQsgQckQAavfMJ3qhm6beTxWBQLYpEdnV2XXzQsMmQ6C9EnPBuUwl4SWaa76c9De)nsu9I)VEt7gWItfmoWWbvYXWJ)gjQEXFKngnsacubdJ)8AhhNXsJdmCqblXWJ)8AhhNXsJ)eufmQm8p3HEy5Y(cXIt)oAe7rmyQDCm(BKO6f)hwUSVqS40VdoWWbfeXWJ)8AhhNXsJ)eufmQm8)C9E9SAKraXmE7N(oI)gjQEXFaJg5neGO2uCGHdQjbdp(BKO6f)HPCobyAh4pV2XXzS04ah4)qFHHhdhuy4XFETJJZyPXFcQcgvg(7BYfqvZPkIbcbIt5LQGMQ8n5c0pBcQAavfMJ3qhm6beTxWBQLYpEdnV2XXz83ir1l(p1qJDV4adhSXWJ)8AhhNXsJ)eufmQm8)C9E9XDrI2lcZ1lqFhPQbu15696J7IeTxeMRxGgXpRwavbnvLsY4VrIQx8)1BA3awCQGXbgUKJHh)51oooJLg)jOkyuz4)5696J7IeTxeMRxG(osvdOQZ171h3fjAVimxVanIFwTaQcAQkLKXFJevV4pYgJgjabQGHXbgoyjgE8Nx744mwA8NGQGrLH)NR3RNvJmciMXB)03rQAavDUEVEwnYiGygV9tJ4NvlGQGMQGsdrQkPuvkjtvYKrvqGQYDObmAK3qaIAt1rrGP2u83ir1l(dy0iVHae1MIdmCqedp(ZRDCCgln(tqvWOYWF)15eiMm1qPSiQhtvqtvqPHivLuQkLKPQbuLVjxavnNQigieioLxQcAQY3Klq)SjOkzYOQKqvlprigwIt)o6zTZIYXu1aQk3HgWOrEdbiQnvhfbMAtPQbuvUdnGrJ8gcquBQgXEedMAhhtvYKrvlprigwIt)o6XPmQF9Yu1aQccu15696xVPDdyH)IsuFhPQbuLVjxavnNQigieioLxQcAQY3Klq)SjOQKHQmsu9QHPCobPFpBZAIbcbIt5LQskvLCQkH4VrIQx8Fy5Y(cXIt)o4ad3KGHh)51oooJLg)nsu9I)WuoNG0VNTz8NGQGrLH)(MCbu1CQIyGqG4uEPkOPkFtUa9ZMGQsgQY3KlqJ4uEXFsIehlcdLYbadhu4adxYgdp(BKO6f)nX7IYms0Ebb1db4pV2XXzS04ad3KIHh)51oooJLg)jOkyuz4VVjxavnNQigieioLxQcAQY3Klq)SjWFJevV4piy2jcKnIdmCtggE8Nx744mwA8NGQGrLH)(RZjqmzQHszrupMQGMQGsdrQkPuvkjJ)gjQEX)HLl7lelo97GdmCqjvm84VrIQx8N0nkxRfCwyaGDDb(ZRDCCglnoWWbfuy4XFETJJZyPXFcQcgvg(FUEVEwnYiGygV9tFhPQbuvUdnGrJ8gcquBQgXpRwavbnvblPQKsvPKm(BKO6f)bmAK3qaIAtXbgoOGngE8Nx744mwA8NGQGrLH)5o0GPiBCzN40VJokcm1MsvYKrvNR3RF9M2nGf(lkrnimcmuLeQcI4VrIQx8)1BA3awCQGXbgoOsogE8Nx744mwA8NGQGrLH)lprigwIt)oAWuKnUSJQgqv5o0agnYBiarTPAe)SAbuLuOkisvjLQsjz83ir1l(pSCzFHyXPFhCGHdkyjgE8Nx744mwA8NGQGrLH)i2JyWu74y83ir1l(dy0iVHae1MIdmCqbrm84pV2XXzS04pbvbJkd)HavDUEV(1BA3aw4VOe1i(z1cWFJevV4pzQbdYEaCGHdQjbdp(BKO6f)F9M2nGfNky8Nx744mwACGHdQKngE83ir1l(JSXOrcqGkyy8Nx744mwACGHdQjfdp(ZRDCCgln(tqvWOYW)Z171ZQrgbeZ4TF67i(BKO6f)bmAK3qaIAtXbgoOMmm84pV2XXzS04pbvbJkd)xEIqmSeN(D0ZANfLJPQbuvUdnGrJ8gcquBQokcm1MsvYKrvlprigwIt)o6XPmQF9YuLmzu1YteIHL40VJgmfzJl7WFJevV4)WYL9fIfN(DWbgoylvm84VrIQx8hMY5eGPDG)8AhhNXsJdCG)24qFHHhdhuy4XFETJJZyPXFcQcgvg(FUEV(4Uir7fH56fOVJu1aQ6C9E9XDrI2lcZ1lqJ4NvlGQGMQsjz83ir1l()6nTBalovW4adhSXWJ)8AhhNXsJ)eufmQm8)C9E9XDrI2lcZ1lqFhPQbu15696J7IeTxeMRxGgXpRwavbnvLsY4VrIQx8hzJrJeGavWW4adxYXWJ)8AhhNXsJ)eufmQm8hcuvUdnGrJ8gcquBQokcm1MI)gjQEXFaJg5neGO2uCGHdwIHh)nsu9I)M4DrzgjAVGG6Ha8Nx744mwACGHdIy4XFETJJZyPXFcQcgvg(7VoNaXKPgkLfr9yQcAQcknePQKsvPKmvjtgv5BYfqvZPkIbcbIt5LQGMQ8n5c0pBcQAavLeQA5jcXWsC63rpRDwuoMQgqv5o0agnYBiarTP6OiWuBkvnGQYDObmAK3qaIAt1i2JyWu74yQsMmQA5jcXWsC63rpoLr9RxMQgqvqGQoxVx)6nTBal8xuI67ivnGQ8n5cOQ5ufXaHaXP8svqtv(MCb6NnbvLmuLrIQxnmLZji97zBwtmqiqCkVuvsPQKtvje)nsu9I)dlx2xiwC63bhy4Mem84VrIQx8N0nkxRfCwyaGDDb(ZRDCCglnoWWLSXWJ)8AhhNXsJ)eufmQm8)C9E9R30UbSWFrjQr8ZQfqvdOQLNiedlXPFh94ug1VEz83ir1l()6nTBalovW4ad3KIHh)51oooJLg)nsu9I)WuoNG0VNTz8NGQGrLH)(RZjqmzQHszrupMQGMQGsdrQkPuvkjtvdOkFtUaQAovrmqiqCkVuf0uLVjxG(ztqvjdvbBPI)HHs5quE8hhy4Mmm84pV2XXzS04pbvbJkd)9n5cOQ5ufXaHaXP8svqtv(MCb6Nnb(BKO6f)bbZorGSrCGHdkPIHh)51oooJLg)jOkyuz4)5696OgfTxetzbyKnKgegbgQscvLCQsMmQk3HgmfzJl7eN(D0rrGP2u83ir1l(JSXOrcqGkyyCGHdkOWWJ)8AhhNXsJ)eufmQm8p3HgmfzJl7eN(D0rrGP2u83ir1l()6nTBalovW4adhuWgdp(ZRDCCgln(tqvWOYW)LNiedlXPFhnykYgx2rvdOkFtUaQskuvYLkvnGQYDObmAK3qaIAt1i(z1cOkPqvqKQskvLsY4VrIQx8Fy5Y(cXIt)o4adhujhdp(ZRDCCgln(tqvWOYWFiqvNR3RF9M2nGf(lkrnIFwTa83ir1l(tMAWGShahy4GcwIHh)51oooJLg)jOkyuz4pI9igm1oog)nsu9I)agnYBiarTP4adhuqedp(ZRDCCgln(BKO6f)HPCobPFpBZ4pbvbJkd)9n5cOQ5ufXaHaXP8svqtv(MCb6NnbvnGQscvDUEV(1BA3aw4VOe1GWiWqvqtvqKQKjJQ8n5cOkOPkJevV6xVPDdyXPcwtAqqvje)ddLYHO84poWWb1KGHh)nsu9I)iBmAKaeOcgg)51oooJLghy4GkzJHh)51oooJLg)jOkyuz4)5696xVPDdyH)IsuFhPkzYOkFtUaQskufSuQuLmzuvUdnykYgx2jo97OJIatTP4VrIQx8)1BA3awCQGXbgoOMum84pV2XXzS04pbvbJkd)xEIqmSeN(D0ZANfLJPQbuvUdnGrJ8gcquBQokcm1MsvYKrvlprigwIt)o6XPmQF9YuLmzu1YteIHL40VJgmfzJl7OQbuLVjxavjfQcIsf)nsu9I)dlx2xiwC63bh4a)hrmPFhlWWJHdkm84VrIQx8hCFVEfJCG)8AhhNXsJdmCWgdp(ZRDCCgln(V2JXFdwbtnKbe(Edr7fJ9qgH)gjQEXFdwbtnKbe(Edr7fJ9qgHdmCjhdp(ZRDCCgln(BKO6f)jjsCDG6TiIJZab(tqvWOYWFiqviRYcEgVHU2zx3Yi74ynprbca(ZEptcXApg)jjsCDG6TiIJZaboWWblXWJ)gjQEX)0RHYLTI2lmyLrDmf)51oooJLghy4GigE83ir1l(t6gLR1colmaWUUa)51oooJLghy4Mem84VrIQx8FyJC5zCTced61wcJ)8AhhNXsJdmCjBm84pV2XXzS04VrIQx8FSJQx8pN4AVIigr8yh4pu4ad3KIHh)nsu9I)GGzNiq2i(ZRDCCglnoWWnzy4XFJevV4)udn29I)8AhhNXsJdCG)KmadpgoOWWJ)8AhhNXsJ)eufmQm8N0Tl3dxnPBuUwl4SWaa76cnIFwTaQskuvYLk(BKO6f)pUUZc)fLioWWbBm84pV2XXzS04pbvbJkd)jD7Y9Wvt6gLR1colmaWUUqJ4NvlGQKcvLCPI)gjQEXFBjmiqMtqmNdhy4sogE8Nx744mwA8NGQGrLH)KUD5E4QjDJY1AbNfgayxxOr8ZQfqvsHQsUuXFJevV4VVq8X1Dghy4GLy4XFJevV4VRsNgaXK)MtF8g4pV2XXzS04adheXWJ)8AhhNXsJ)eufmQm8N0Tl3dxnPBuUwl4SWaa76cnIFwTaQsku1KivQsMmQkQhlIwKlMQGMQGk54VrIQx8)WiaJGP2uCGHBsWWJ)8AhhNXsJ)eufmQm8)C9ED61q5Ywr7fgSYOoMQVJu1aQkju15696dJamcMAt13rQsMmQ6C9E9X1Dw4VOe13rQsMmQccufYiSoqTZrvjKQKjJQscvr6fCF2XX6XoQEfTxC3dQYool8xuIu1aQkQhlIwKlMQGMQMeOOkzYOQOESiArUyQcAQc2tcvLqQsMmQccufda8synP3mVaolCLN9nIW6Nn5BevnGQoxVxt6gLR1colmaWUUqFhXFJevV4)yhvV4adxYgdp(ZRDCCgln(tqvWOYW)WqPCOZfiSLWuLuKqvtc(BKO6f)nWitcr7fXuwWwQJXbgUjfdp(ZRDCCgln(BKO6f)nW0z2YabYG1gjinYC4pbvbJkd)pxVx)4xJsu0EH7sQSiJy7b03rQAavfgkLdDupweTixmvbnvr62L7HR(XVgLOO9c3LuzrgX2dOr8ZQfqvZPkOGivjtgvDUEVo9AOCzRO9cdwzuht1GWiWqvsOkisvdOQWqPCOJ6XIOf5IPkOPks3UCpC1PxdLlBfTxyWkJ6yQgXpRwavnNQGTuPkzYOQmFUEVgzWAJeKgzorMpxVxN7HlvjtgvfgkLdDupweTixmvbnvbBOOkzYOQZ171dBKlpJRvGyqV2synIFwTaQAavfgkLdDupweTixmvbnvr62L7HREyJC5zCTced61wcRr8ZQfqvZPkOMuQsMmQccuvyoEd9PqzGO9IreNOMx744mvnGQcdLYHoQhlIwKlMQGMQiD7Y9Wvt6gLR1colmaWUUqJ4NvlGQMtvWwQu1aQ6C9EnPBuUwl4SWaa76cnIFwTa8FThJ)gy6mBzGazWAJeKgzoCGHBYWWJ)8AhhNXsJ)gjQEX)uZXeZ5yeqC6EXFcQcgvg(t62L7HR(XVgLOO9c3LuzrgX2dOr8ZQfqvYKrvH54n0dlx2xiwuR)cQE18AhhNPQbufPBxUhUAs3OCTwWzHba21fAe)SAbuLmzufeOkga4LW6h)AuII2lCxsLfzeBpG(zt(grvdOks3UCpC1KUr5ATGZcdaSRl0i(z1cW)1Em(NAoMyohJaIt3loWWbLuXWJ)8AhhNXsJ)R9y83GvWudzaHV3q0EXypKr4VrIQx83GvWudzaHV3q0EXypKr4adhuqHHh)51oooJLg)jOkyuz4pYQSGNXBOTCgORLQKcvnzsLQgqv(MCbuf0uLVjxG(ztqvjdvbBisvYKrvjHQmsuZybV8RyavjfQckQAavbbQkmhVH(uOmq0EXiItuZRDCCMQKjJQmsuZybV8RyavjfQc2uvcPQbuvsOQZ171h3fjAVimxVa9DKQgqvNR3RpUls0EryUEbAe)SAbuLuOQKtvjLQsjzQsMmQccu15696J7IeTxeMRxG(osvje)nsu9I)(MCbCwyWkJQGfh2E4adhuWgdp(ZRDCCgln(tqvWOYW)KqvjHQqwLf8mEdTLZanIFwTaQsku1KjvQsMmQccufYQSGNXBOTCgO5jkqaOQesvYKrvjHQmsuZybV8RyavjfQckQAavbbQkmhVH(uOmq0EXiItuZRDCCMQKjJQmsuZybV8RyavjfQc2uvcPQesvdOkFtUaQcAQY3Klq)SjWFJevV4)X1Dw0ErmLf8YVeXbgoOsogE8Nx744mwA8NGQGrLH)jHQscvHSkl4z8gAlNbAe)SAbuLuOQjrQuLmzufeOkKvzbpJ3qB5mqZtuGaqvjKQKjJQscvzKOMXcE5xXaQskufuu1aQccuvyoEd9PqzGO9IreNOMx744mvjtgvzKOMXcE5xXaQskufSPQesvjKQgqv(MCbuf0uLVjxG(ztG)gjQEX)XlQ8jwBQ44mqGdmCqblXWJ)gjQEX)0RHYLTI2lmyLrDmf)51oooJLghy4GcIy4XFJevV4pQghDSOwby0im(ZRDCCglnoWWb1KGHh)51oooJLg)jOkyuz4V)6CcetMAOuwe1JPkOPkOOQKsvPKm(BKO6f)j9s4nqwWzH3zpghy4GkzJHh)51oooJLg)jOkyuz4)569AetGXXaGW3icRVJ4VrIQx8pMYI7E67Mf(gryCGHdQjfdp(BKO6f)h2ixEgxRaXGETLW4pV2XXzS04adhutggE8Nx744mwA8NGQGrLH)HHs5qpLnxmvpscQsku1KkvQsMmQkmukh6PS5IP6rsqvqlHQGTuPkzYOQWqPCOJ6XIOfJKqaBPsvsHQsUuXFJevV4pITXAtfEN9yaoWWbBPIHh)nsu9I)ig0Rf1MkmeQhI)8AhhNXsJdmCWgkm84VrIQx8pZwmvqMAWGSh(ZRDCCglnoWWbByJHh)nsu9I)dlxwaglufa8Nx744mwACGHd2jhdp(BKO6f)9olrolat7a)51oooJLghy4GnSedp(ZRDCCgln(tqvWOYWFga4LW6h)AuII2lCxsLfzeBpG(zt(grvdOke7rmyQDCmvnGQoxVxpRgzeqmJ3(PVJu1aQccufPBxUhU6h)AuII2lCxsLfzeBpGgXpRwa(BKO6f)bmAK3qaIAtXbgoydrm84pV2XXzS04pbvbJkd)zaGxcRF8RrjkAVWDjvwKrS9a6Nn5BevnGQGavr62L7HR(XVgLOO9c3LuzrgX2dOr8ZQfG)gjQEX)xVPDdyXPcghy4G9KGHh)51oooJLg)jOkyuz4pda8sy9JFnkrr7fUlPYImIThq)SjFJOQbuL)6CcetMAOuwe1JPkOPkO0qKQskvLsYu1aQY3KlGQGMQmsu9QF9M2nGfNkynPbbvnGQGavr62L7HR(XVgLOO9c3LuzrgX2dOr8ZQfG)gjQEX)HLl7lelo97GdmCWozJHh)51oooJLg)jOkyuz4VVjxavbnvzKO6v)6nTBalovWAsdcQAavDUEVM0nkxRfCwyaGDDH(oI)gjQEX)h)AuII2lCxsLfzeBpaoWb(NzVDDbgEmCqHHh)51oooJLg)jOkyuz4FMpxVxtmquBQ(osvYKrvNR3RZfyKDo74yXZslI(osvYKrvNR3RZfyKDo74ybVilL13r83ir1l(tmNtyKO6v4kqG)UceI1Em(FJYvrI4adhSXWJ)gjQEX)lGfvWpa(ZRDCCglnoWWLCm84pV2XXzS04pbvbJkd)ddLYHoQhlIwKlMQKcvbfePQbuvsOQmFUEVE6DdgbepdbJo3dxQAavzKOMXICh6P3nyeq8memuLeQsQuvcXFJevV4)07gmciEgcgCGHdwIHh)51oooJLg)nsu9I)eZ5egjQEfUce4VRaHyThJ)Kmahy4GigE8Nx744mwA8NGQGrLH)gjQzSGx(vmGQKqvqrvdOQWqPCOJ6XIOf5IPkOPkFtUaQkbmvLeQYir1R(1BA3awCQG1KgeuvYqvedeceNYlvLqQkPuvkjJ)gjQEX)xVPDdyXPcghy4Mem84pV2XXzS04pbvbJkd)nsuZybV8RyavbnvLCQAavfMJ3qtMAWGShqZRDCCMQgqvH54n0MBCQjgrC2IgP51oooJ)gjQEXFI5CcJevVcxbc83vGqS2JXFBCOVWbgUKngE8Nx744mwA8NGQGrLH)gjQzSGx(vmGQGMQsovnGQcZXBOjtnyq2dO51oooJ)gjQEXFI5CcJevVcxbc83vGqS2JX)H(chy4Mum84pV2XXzS04pbvbJkd)nsuZybV8RyavbnvLCQAavbbQkmhVH2CJtnXiIZw0inV2XXzQAavbbQkmhVHEy5Y(cXIA9xq1RMx744m(BKO6f)jMZjmsu9kCfiWFxbcXApg)bboWWnzy4XFETJJZyPXFcQcgvg(BKOMXcE5xXaQcAQk5u1aQkmhVH2CJtnXiIZw0inV2XXzQAavbbQkmhVHEy5Y(cXIA9xq1RMx744m(BKO6f)jMZjmsu9kCfiWFxbcXApg)TrqGdmCqjvm84pV2XXzS04pbvbJkd)nsuZybV8RyavbnvLCQAavfMJ3qBUXPMyeXzlAKMx744mvnGQcZXBOhwUSVqSOw)fu9Q51oooJ)gjQEXFI5CcJevVcxbc83vGqS2JXFBCOVWbgoOGcdp(ZRDCCgln(tqvWOYWFJe1mwWl)kgqvqtvjNQgqvqGQcZXBOn34utmI4SfnsZRDCCMQgqvH54n0dlx2xiwuR)cQE18AhhNXFJevV4pXCoHrIQxHRab(7kqiw7X4)qFHdmCqbBm84pV2XXzS04pbvbJkd)nsuZybV8RyavjfQckQAavbbQkmhVH(uOmq0EXiItuZRDCCMQKjJQmsuZybV8RyavjfQc24VrIQx8NyoNWir1RWvGa)DfieR9y8N4yBgJdmCqLCm84VrIQx8N0lH3azbNfEN9y8Nx744mwACGHdkyjgE83ir1l(BiITSiAeI3a)51oooJLghy4GcIy4XFJevV4)XsfTxeOIada)51oooJLgh4a)Vr5Qirm8y4Gcdp(BKO6f)FxyfwDm(ZRDCCglnoWWbBm84VrIQx8pq2MG(wUcwRnvaM2b(ZRDCCglnoWboW)zmcu9IHd2sf2svQtkSNm8FOH2Atb4FcOjRem4sqbxcqjqQIQGFktv1BSrbv5Bevn5qCSnJNCOkeNG(wiotvG(XuLDJ(zbNPkYuBtzGMczcETmvL8eivLGXVEgNPQxTjWeeufzktGHQsY2bvzZSYzhhtv1sv876SO6nHuvsGAIeQPqMGxltvtwcKQsW4xpJZu1ZMibMGGQitzcmuvs2oOkBMvo74yQQwQIFxNfvVjKQscutKqnfskKjGMSsWGlbfCjaLaPkQc(PmvvVXgfuLVru1KJno0xtoufItqFleNPkq)yQYUr)SGZufzQTPmqtHmbVwMQM0eivLGXVEgNPQxTjWeeufzktGHQsY2bvzZSYzhhtv1sv876SO6nHuvsGAIeQPqMGxltvqbXeivLGXVEgNPQxTjWeeufzktGHQsY2bvzZSYzhhtv1sv876SO6nHuvsGAIeQPqsHmb1BSrbNPQjJQmsu9svUceanfs8Fe1(YX4pSGQ(x0SAM5OQeqUBWikKWcQkzDtVGGQG9KjpvbBPcBPsHKcjSGQsam12ugKaPqclOQKHQsw5mNPQj3lScRoMQIMQYS3UUGQmsu9svUceAkKWcQkzOQeatTnLZuvyOuoeLNQ4jgrmau9cOQOPksIehlcdLYbqtHewqvjdvn525YxCMQigAglizevfnvnSrWqvVgXufBGYLivnSIPuvmLPklN7DYbqv1B0XpEdlQEPQ2tvZmuzhhRPqclOQKHQsw5mNPQBuUksKQswjaNGRPqsHewqvjiNGj3GZu1H9nIPks)owqvhoTwGMQswecpgaQA7nzMAON)6OkJevVaQQxxIAkKWcQYir1lqpIys)owiX7mamuiHfuLrIQxGEeXK(DSyUe5SB6J3WIQxkKWcQYir1lqpIys)owmxIC(UZuinsu9c0JiM0VJfZLih4(E9kg5GcjSGQ(RncM2bvHSktvNR3ZzQcewaOQd7BetvK(DSGQoCATaQY2mvnI4KzSJO2uQQauvUxwtHewqvgjQEb6ret63XI5sKdS2iyAhcqybGcPrIQxGEeXK(DSyUe5Uawub)KFThlXGvWudzaHV3q0EXypKruinsu9c0JiM0VJfZLi3fWIk4N8S3ZKqS2JLqsK46a1BrehNbc5lVeiGSkl4z8g6ANDDlJSJJ18efiauinsu9c0JiM0VJfZLix61q5Ywr7fgSYOoMsH0ir1lqpIys)owmxICKUr5ATGZcdaSRlOqAKO6fOhrmPFhlMlrUHnYLNX1kqmOxBjmfsJevVa9iIj97yXCjYn2r1R85ex7veXiIh7qcuuinsu9c0JiM0VJfZLihiy2jcKnsH0ir1lqpIys)owmxICtn0y3lfskKgjQEb6BuUksuY7cRWQJPqAKO6fOVr5QiX5sKlq2MG(wUcwRnvaM2bfskKWcQkb5em5gCMQ4zmkrQkQhtvXuMQms0iQQauLnZkNDCSMcPrIQxGeI5CcJevVcxbc5x7XsUr5Qir5lVKmFUEVMyGO2u9DuMSZ1715cmYoNDCS4zPfrFhLj7C9EDUaJSZzhhl4fzPS(osH0ir1lyUe5Uawub)auinsu9cMlrUP3nyeq8memYxEjHHs5qh1JfrlYflfOG4GKK5Z171tVBWiG4ziy05E4oWirnJf5o0tVBWiG4ziyKi1esH0ir1lyUe5iMZjmsu9kCfiKFThlHKbuinsu9cMlrUxVPDdyXPcw(YlXirnJf8YVIbsGAqyOuo0r9yr0ICXq7BYfKaojgjQE1VEt7gWItfSM0GizigieioL3eM0usMcPrIQxWCjYrmNtyKO6v4kqi)ApwIno0xYxEjgjQzSGx(vma6KpimhVHMm1GbzpGMx7448GWC8gAZno1eJioBrJ08AhhNPqAKO6fmxICeZ5egjQEfUceYV2JLm0xYxEjgjQzSGx(vma6KpimhVHMm1GbzpGMx744mfsJevVG5sKJyoNWir1RWvGq(1ESeqiF5LyKOMXcE5xXaOt(aieMJ3qBUXPMyeXzlAKMx7448aieMJ3qpSCzFHyrT(lO6vZRDCCMcPrIQxWCjYrmNtyKO6v4kqi)ApwIncc5lVeJe1mwWl)kgaDYheMJ3qBUXPMyeXzlAKMx7448aieMJ3qpSCzFHyrT(lO6vZRDCCMcPrIQxWCjYrmNtyKO6v4kqi)ApwIno0xYxEjgjQzSGx(vma6KpimhVH2CJtnXiIZw0inV2XX5bH54n0dlx2xiwuR)cQE18AhhNPqAKO6fmxICeZ5egjQEfUceYV2JLm0xYxEjgjQzSGx(vma6KpacH54n0MBCQjgrC2IgP51ooopimhVHEy5Y(cXIA9xq1RMx744mfsJevVG5sKJyoNWir1RWvGq(1ESeIJTzS8LxIrIAgl4LFfdKcudGqyoEd9PqzGO9IreNOMx744SmzgjQzSGx(vmqkWMcPrIQxWCjYr6LWBGSGZcVZEmfsJevVG5sKZqeBzr0ieVbfsJevVG5sK7yPI2lcurGbqHKcPrIQxG2gbHKxVPDdyXPcw(Yl5C9EnPBuUwl4SWaa76c9DCqsoxVxt6gLR1colmaWUUqJ4NvlaAO0qmPPKSmzNR3RpUls0EryUEb674GZ171h3fjAVimxVanIFwTaOHsdXKMsYjKcPrIQxG2gbXCjYHSXOrcqGkyy5lVKZ171KUr5ATGZcdaSRl03Xbj5C9EnPBuUwl4SWaa76cnIFwTaOHsdXKMsYYKDUEV(4Uir7fH56fOVJdoxVxFCxKO9IWC9c0i(z1cGgknetAkjNqkKgjQEbABeeZLiN3zlm1MkabQGHLV8s8n5cMtmqiqCkVq7BYfOF2euinsu9c02iiMlroykNtq63Z2S8KejowegkLdGeOKV8s8xNtGyYudLYIOEm0qPHystj5b(MCbZjgieioLxO9n5c0pBckKgjQEbABeeZLihiy2jcKnkF5L4BYfmNyGqG4uEH23Klq)SjOqAKO6fOTrqmxICdlx2xiwC63r(YlX3KlyoXaHaXP8cTVjxG(ztmacrrGP20bq4C9E9JFnkrr7fUlPYImIThqFhhKe)15eiMm1qPSiQhdnuAiM0uswMmiK7qpSCzFHyXPFhDueyQnDaeoxVxt6gLR1colmaWUUqFhLjdc5o0dlx2xiwC63rhfbMAthCUEV(1BA3aw4VOe1GWiWanujuMSOESiArUyOHAshaHCh6HLl7lelo97OJIatTPuinsu9c02iiMlroaJg5neGO2u5lVeiK7qdy0iVHae1MQJIatTPdGW569As3OCTwWzHba21f67ifsJevVaTncI5sKdMY5eK(9SnlpjrIJfHHs5aibk5lVeFtUG5edeceNYl0(MCb6NnXGKCUEV(1BA3aw4VOe1GWiWaneLjZ3KlaAJevV6xVPDdyXPcwtAqKqkKgjQEbABeeZLihGrJ8gcquBQ8LxcI9igm1ooEaeoxVxt6gLR1colmaWUUqFhhCUEV(1BA3aw4VOe1GWiWanePqAKO6fOTrqmxICM4DrzgjAVGG6Ha5lVeiCUEVM0nkxRfCwyaGDDH(osH0ir1lqBJGyUe5iDJY1AbNfgayxxiF5LaHZ171KUr5ATGZcdaSRl03rkKgjQEbABeeZLi3R30UbS4ublF5LCUEV(1BA3aw4VOe13rzY8n5cMtmqiqCkVsX3Klq)SjsgOKQmzNR3RjDJY1AbNfgayxxOVJuinsu9c02iiMlroKngnsacubdtH0ir1lqBJGyUe5gwUSVqS40VJ8LxceIIatTPuiPqAKO6fOTXH(sYR30UbS4ublF5LCUEV(4Uir7fH56fOVJdoxVxFCxKO9IWC9c0i(z1cGoLKPqAKO6fOTXH(AUe5q2y0ibiqfmS8LxY5696J7IeTxeMRxG(oo4C9E9XDrI2lcZ1lqJ4Nvla6usMcPrIQxG2gh6R5sKdWOrEdbiQnv(Ylbc5o0agnYBiarTP6OiWuBkfsJevVaTno0xZLiNjExuMrI2liOEiGcPrIQxG2gh6R5sKBy5Y(cXIt)oYxEj(RZjqmzQHszrupgAO0qmPPKSmz(MCbZjgieioLxO9n5c0pBIbjz5jcXWsC63rpRDwuoEqUdnGrJ8gcquBQokcm1Moi3HgWOrEdbiQnvJypIbtTJJLjB5jcXWsC63rpoLr9RxEaeoxVx)6nTBal8xuI674aFtUG5edeceNYl0(MCb6NnrYyKO6vdt5Ccs)E2M1edeceNYBstEcPqAKO6fOTXH(AUe5iDJY1AbNfgayxxqH0ir1lqBJd91CjY96nTBalovWYxEjNR3RF9M2nGf(lkrnIFwTGblprigwIt)o6XPmQF9Yuinsu9c024qFnxICWuoNG0VNTz5ddLYHO8sE1MapUUZaMHHrAe)SAbYxEj(RZjqmzQHszrupgAO0qmPPK8aFtUG5edeceNYl0(MCb6NnrYaBPsH0ir1lqBJd91CjYbcMDIazJYxEj(MCbZjgieioLxO9n5c0pBckKgjQEbABCOVMlroKngnsacubdlF5LCUEVoQrr7fXuwagzdPbHrGrsYLjl3HgmfzJl7eN(D0rrGP2ukKgjQEbABCOVMlrUxVPDdyXPcw(Ylj3HgmfzJl7eN(D0rrGP2ukKgjQEbABCOVMlrUHLl7lelo97iF5LS8eHyyjo97Obtr24YUb(MCbsj5sDqUdnGrJ8gcquBQgXpRwGuGystjzkKgjQEbABCOVMlroYudgK9aYxEjq4C9E9R30UbSWFrjQr8ZQfqH0ir1lqBJd91CjYby0iVHae1MkF5LGypIbtTJJPqAKO6fOTXH(AUe5GPCobPFpBZYhgkLdr5L8QnbECDNbmddJ0i(z1cKV8s8n5cMtmqiqCkVq7BYfOF2edsY5696xVPDdyH)IsudcJad0quMmFtUaOnsu9QF9M2nGfNkynPbrcPqAKO6fOTXH(AUe5q2y0ibiqfmmfsJevVaTno0xZLi3R30UbS4ublF5LCUEV(1BA3aw4VOe13rzY8n5cKcSuQYKL7qdMISXLDIt)o6OiWuBkfsJevVaTno0xZLi3WYL9fIfN(DKV8swEIqmSeN(D0ZANfLJhK7qdy0iVHae1MQJIatTPYKT8eHyyjo97OhNYO(1llt2YteIHL40VJgmfzJl7g4BYfifikvkKuinsu9c0KmqYX1Dw4VOeLV8siD7Y9Wvt6gLR1colmaWUUqJ4NvlqkjxQuinsu9c0KmyUe5SLWGazobXCo5lVes3UCpC1KUr5ATGZcdaSRl0i(z1cKsYLkfsJevVanjdMlroFH4JR7S8LxcPBxUhUAs3OCTwWzHba21fAe)SAbsj5sLcPrIQxGMKbZLiNRsNgaXK)MtF8guinsu9c0KmyUe5omcWiyQnv(YlH0Tl3dxnPBuUwl4SWaa76cnIFwTaPmjsvMSOESiArUyOHk5uinsu9c0KmyUe5g7O6v(Yl5C9ED61q5Ywr7fgSYOoMQVJdsY5696dJamcMAt13rzYoxVxFCDNf(lkr9DuMmiGmcRdu7CjuMSKq6fCF2XX6XoQEfTxC3dQYool8xuIdI6XIOf5IHEsGsMSOESiArUyOH9KKqzYGada8synP3mVaolCLN9nIW6Nn5B0GZ171KUr5ATGZcdaSRl03rkKgjQEbAsgmxICgyKjHO9Iyklyl1XYxEjHHs5qNlqylHLIKjHcPrIQxGMKbZLi3fWIk4N8R9yjgy6mBzGazWAJeKgzo5lVKZ171p(1OefTx4UKklYi2Ea9DCqyOuo0r9yr0ICXqt62L7HR(XVgLOO9c3LuzrgX2dOr8ZQfmhkikt256960RHYLTI2lmyLrDmvdcJaJeioimukh6OESiArUyOjD7Y9WvNEnuUSv0EHbRmQJPAe)SAbZHTuLjlZNR3RrgS2ibPrMtK5Z1715E4ktwyOuo0r9yr0ICXqdBOKj7C9E9Wg5YZ4Afig0RTewJ4NvlyqyOuo0r9yr0ICXqt62L7HREyJC5zCTced61wcRr8ZQfmhQjvMmieMJ3qFkugiAVyeXjQ51ooopimukh6OESiArUyOjD7Y9Wvt6gLR1colmaWUUqJ4NvlyoSL6GZ171KUr5ATGZcdaSRl0i(z1cOqAKO6fOjzWCjYDbSOc(j)ApwsQ5yI5CmcioDVYxEjKUD5E4QF8RrjkAVWDjvwKrS9aAe)SAbYKfMJ3qpSCzFHyrT(lO6vZRDCCEaPBxUhUAs3OCTwWzHba21fAe)SAbYKbbga4LW6h)AuII2lCxsLfzeBpG(zt(gnG0Tl3dxnPBuUwl4SWaa76cnIFwTakKgjQEbAsgmxICxalQGFYV2JLyWkyQHmGW3BiAVyShYikKgjQEbAsgmxIC(MCbCwyWkJQGfh2EYxEjiRYcEgVH2YzGUwPmzsDGVjxa0(MCb6NnrYaBiktwsmsuZybV8RyGuGAaecZXBOpfkdeTxmI4e18AhhNLjZirnJf8YVIbsb2jCqsoxVxFCxKO9IWC9c03XbNR3RpUls0EryUEbAe)SAbsj5jnLKLjdcNR3RpUls0EryUEb67ycPqAKO6fOjzWCjYDCDNfTxetzbV8lr5lVKKKeKvzbpJ3qB5mqJ4NvlqktMuLjdciRYcEgVH2YzGMNOabiHYKLeJe1mwWl)kgifOgaHWC8g6tHYar7fJiornV2XXzzYmsuZybV8RyGuGDct4aFtUaO9n5c0pBckKgjQEbAsgmxICJxu5tS2uXXzGq(YljjjbzvwWZ4n0wod0i(z1cKYKivzYGaYQSGNXBOTCgO5jkqasOmzjXirnJf8YVIbsbQbqimhVH(uOmq0EXiItuZRDCCwMmJe1mwWl)kgifyNWeoW3KlaAFtUa9ZMGcPrIQxGMKbZLix61q5Ywr7fgSYOoMsH0ir1lqtYG5sKdvJJowuRamAeMcPrIQxGMKbZLihPxcVbYcol8o7XYxEj(RZjqmzQHszrupgAOsAkjtH0ir1lqtYG5sKlMYI7E67Mf(gry5lVKZ171iMaJJbaHVrewFhPqAKO6fOjzWCjYnSrU8mUwbIb9AlHPqAKO6fOjzWCjYHyBS2uH3zpgiF5LegkLd9u2CXu9ijKYKkvzYcdLYHEkBUyQEKeqlb2svMSWqPCOJ6XIOfJKqaBPkLKlvkKgjQEbAsgmxICig0Rf1MkmeQhsH0ir1lqtYG5sKlZwmvqMAWGShfsJevVanjdMlrUHLllaJfQcafsJevVanjdMlroVZsKZcW0oOqAKO6fOjzWCjYby0iVHae1MkF5LWaaVew)4xJsu0EH7sQSiJy7b0pBY3Obi2JyWu744bNR3RNvJmciMXB)03XbqG0Tl3dx9JFnkrr7fUlPYImIThqJ4NvlGcPrIQxGMKbZLi3R30UbS4ublF5LWaaVew)4xJsu0EH7sQSiJy7b0pBY3ObqG0Tl3dx9JFnkrr7fUlPYImIThqJ4NvlGcPrIQxGMKbZLi3WYL9fIfN(DKV8syaGxcRF8RrjkAVWDjvwKrS9a6Nn5B0a)15eiMm1qPSiQhdnuAiM0usEGVjxa0gjQE1VEt7gWItfSM0GyaeiD7Y9Wv)4xJsu0EH7sQSiJy7b0i(z1cOqAKO6fOjzWCjY94xJsu0EH7sQSiJy7bKV8s8n5cG2ir1R(1BA3awCQG1KgedoxVxt6gLR1colmaWUUqFhPqsH0ir1lqtCSnJLmZqLDCS8R9yjednJfKms(EucGJYl)mZDzjgjQzSGx(vmq(zM7Yc2byjquEsV5kQELyKOMXcE5xXaOHifsJevVanXX2mEUe5E9M2nGfNky5lVedwzufS(4Uir7fH56fOr2cJuK6GKCUEVM0nkxRfCwyaGDDH(ooijNR3RjDJY1AbNfgayxxOr8ZQfanuAiM0uswMSZ171h3fjAVimxVa9DCW5696J7IeTxeMRxGgXpRwa0qPHystjzzYoxVxt6gLR1colmaWUUqJ4NvlyaeoxVxFCxKO9IWC9c0i(z1csycPqAKO6fOjo2MXZLi3R30UbS4ublFyOuoeLxYR2eyupweTixS8LxsMpxVx7SG3qm2fOxnimcmsjjgjQzSGx(vmqMSjlHdcdLYHoQhlIwKlgAJe1mwWl)kgK0usMcPrIQxGM4yBgpxICM4DrzgjAVGG6HakKgjQEbAIJTz8CjYr6gLR1colmaWUUGcPrIQxGM4yBgpxICednJLV8sYDObtr24YoXPFhDueyQnDaecZXBONMygzaXPcwZRDCCwMSChAWuKnUStC63rhfbMAthyKOMXcE5xXaParkKgjQEbAIJTz8CjYnSCzFHyXPFh5lVeieMJ3qNEzeQCotegjkcqZRDCCwMm)15eiMm1qPSiQhdDkjltgYQSGNXBOTCgOr8ZQfa9KmazvwWZ4n0wod08efiauinsu9c0ehBZ45sK7CdYugLO8LxczQHszGWJmsu9AoPaBneLjl3HgmfzJl7eN(D0rrGP2uzYiD7Y9WvpSCzFHyXPFhnIFwTaPyKOMXcE5xXGKjLKLjlZNR3RpUUZI2lIPSGx(LOgXpRwGmziRYcEgVH2YzGgXpRwa0qCaYQSGNXBOTCgO5jkqaOqAKO6fOjo2MXZLi3R30UbS4ublFyOuoeLxYZMibM5Z171ol4neJDb6vdcJaJ8LxsMpxVx7SG3qm2fOxnimcmszsPqAKO6fOjo2MXZLihzQbdYEakKgjQEbAIJTz8CjYbt5Ccs)E2MLNKiXXIWqPCaKaL8LxIVjxWCIbcbIt5fAFtUa9ZMGcPrIQxGM4yBgpxICtn0y3R8LxsyoEdDWOhq0EbVPwk)4n08AhhNPqAKO6fOjo2MXZLihXqZy5lVKWC8g60lJqLZzIWirraAETJJZuinsu9c0ehBZ45sK7CdYugLO8LxcPBxUhU6HLl7lelo97Or8ZQfiLKyKOMXcE5xXazYGycPqAKO6fOjo2MXZLiN3zlm1MkabQGHLV8s8n5cMtmqiqCkVq7BYfOF2euinsu9c0ehBZ45sKBy5Y(cXIt)oYxEj5o0dlx2xiwC63rJypIbtTJJLjlmhVHEy5Y(cXIA9xq1RMx744mfsJevVanXX2mEUe5amAK3qaIAtLNKiXXIWqPCaKaL8LxY5696z1iJaIz82pnInsqH0ir1lqtCSnJNlroIHMXYxEjKUD5E4QhwUSVqS40VJgXpRwGuMzOYoowtm0mwqYOeWWMcPrIQxGM4yBgpxICGGzNiq2ifsJevVanXX2mEUe5amAK3qaIAtLNKiXXIWqPCaKaL8LxcI9igm1ooEW5696OgfTxetzbyKnKgegbgOt(GLNiedlXPFh9S2zr5yzYqShXGP2XXdmyLrvWANf8gIXUa9Qr2cJuKkfsJevVanXX2mEUe5GPCobyAhuiHfuf8nvbQ31zbtvxGLYuLVru1KBVPDdyQs6kyQQruvcMngnIQ(bQGHPQ8fvBkvLSaJmjOQ2tvXuMQsqAPowEQI0JjsvSrMsvnHCriEjmv1EQkMYuLrIQxQY2mvzJJ8MPkbBPoMQIMQIPmvzKO6LQw7XAkKgjQEbAIJTz8CjY96nTBalovWYtsK4yryOuoasGIcPrIQxGM4yBgpxICiBmAKaeOcgwEsIehlcdLYbqcuuiPqAKO6fObHKPgAS7v(YljmhVHoy0diAVG3ulLF8gAETJJZuinsu9c0GyUe58oBHP2ubiqfmS8LxIVjxWCIbcbIt5fAFtUa9ZMGcPrIQxGgeZLihYgJgjabQGHLV8soxVxt6gLR1colmaWUUqFhhKKZ171KUr5ATGZcdaSRl0i(z1cGgknetAkjlt25696J7IeTxeMRxG(oo4C9E9XDrI2lcZ1lqJ4NvlaAO0qmPPKCcPqclOk4BQcuVRZcMQUalLPkFJOQj3Et7gWuL0vWuvJOQemBmAev9dubdtv5lQ2uQkzbgzsqvTNQIPmvLG0sDS8ufPhtKQyJmLQAc5Iq8syQQ9uvmLPkJevVuLTzQYgh5ntvc2sDmvfnvftzQYir1lvT2J1uinsu9c0GyUe5E9M2nGfNky5lVKZ171KUr5ATGZcdaSRl03Xbj5C9EnPBuUwl4SWaa76cnIFwTaOHsdXKMsYYKDUEV(4Uir7fH56fOVJdoxVxFCxKO9IWC9c0i(z1cGgknetAkjNqkKgjQEbAqmxICWuoNG0VNTz5jjsCSimukhajqjF5L4BYfmNyGqG4uEH23Klq)SjOqAKO6fObXCjYby0iVHae1MkF5LCUEVEwnYiGygV9tFhhCUEVEwnYiGygV9tJ4NvlaAOsAkjtH0ir1lqdI5sKdem7ebYgLV8s8n5cMtmqiqCkVq7BYfOF2euinsu9c0GyUe5gwUSVqS40VJ8LxIVjxWCIbcbIt5fAFtUa9ZMyaI9igm1ooEG)6CcetMAOuwe1JHoLKhaHZ171p(1OefTx4UKklYi2Ea9DuMmFtUG5edeceNYl0(MCb6NnXGKaHCh6HLl7lelo97OJIatTPdsceoxVxt6gLR1colmaWUUqFhLj7C9E9R30UbSWFrjQbHrGbAOKjlQhlIwKlgAOMuzYGqUd9WYL9fIfN(D0rrGP20bgSYOky9WYLz0YaGaCrZQzMtJSfgPi1eMWbq4C9E9JFnkrr7fUlPYImIThqFhPqAKO6fObXCjYby0iVHae1MkF5LCUEVEwnYiGygV9tFhhK7qdy0iVHae1MQr8ZQfanSmPPKSmz5o0agnYBiarTPAe7rmyQDC8aiCUEVM0nkxRfCwyaGDDH(osH0ir1lqdI5sKZeVlkZir7feupeiF5LaHZ171KUr5ATGZcdaSRl03rkKgjQEbAqmxICKUr5ATGZcdaSRlKV8sGW569As3OCTwWzHba21f67ifsJevVaniMlrUxVPDdyXPcw(Yl5C9E9R30UbSWFrjQVJYK5BYfmNyGqG4uELIVjxG(ztKmWwQdcZXBONvJmciMXB)08AhhNLjZ3KlyoXaHaXP8kfFtUa9ZMizGAqyoEdDWOhq0EbVPwk)4n08AhhNLj7C9EnPBuUwl4SWaa76c9DKcPrIQxGgeZLihYgJgjabQGHPqAKO6fObXCjYnSCzFHyXPFh5lVKCh6HLl7lelo97OrShXGP2XXuinsu9c0GyUe5amAK3qaIAtLV8soxVxpRgzeqmJ3(PVJuinsu9c0GyUe5GPCobyAhuiPqAKO6fOh6ljtn0y3R8LxIVjxWCIbcbIt5fAFtUa9ZMyqyoEdDWOhq0EbVPwk)4n08AhhNPqAKO6fOh6R5sK71BA3awCQGLV8soxVxFCxKO9IWC9c03XbNR3RpUls0EryUEbAe)SAbqNsYuinsu9c0d91CjYHSXOrcqGkyy5lVKZ171h3fjAVimxVa9DCW5696J7IeTxeMRxGgXpRwa0PKmfsJevVa9qFnxICagnYBiarTPYxEjNR3RNvJmciMXB)03XbNR3RNvJmciMXB)0i(z1cGgknetAkjltgeYDObmAK3qaIAt1rrGP2ukKgjQEb6H(AUe5gwUSVqS40VJ8LxI)6CcetMAOuwe1JHgknetAkjpW3KlyoXaHaXP8cTVjxG(ztitwswEIqmSeN(D0ZANfLJhK7qdy0iVHae1MQJIatTPdYDObmAK3qaIAt1i2JyWu74yzYwEIqmSeN(D0Jtzu)6LhaHZ171VEt7gWc)fLO(ooW3KlyoXaHaXP8cTVjxG(ztKmgjQE1WuoNG0VNTznXaHaXP8M0KNqkKgjQEb6H(AUe5GPCobPFpBZYtsK4yryOuoasGs(YlX3KlyoXaHaXP8cTVjxG(ztKm(MCbAeNYlfsJevVa9qFnxICM4DrzgjAVGG6HakKgjQEb6H(AUe5abZorGSr5lVeFtUG5edeceNYl0(MCb6NnbfsJevVa9qFnxICdlx2xiwC63r(YlXFDobIjtnuklI6XqdLgIjnLKPqAKO6fOh6R5sKJ0nkxRfCwyaGDDbfsJevVa9qFnxICagnYBiarTPYxEjNR3RNvJmciMXB)03Xb5o0agnYBiarTPAe)SAbqdltAkjtH0ir1lqp0xZLi3R30UbS4ublF5LK7qdMISXLDIt)o6OiWuBQmzNR3RF9M2nGf(lkrnimcmsGifsJevVa9qFnxICdlx2xiwC63r(Ylz5jcXWsC63rdMISXLDdYDObmAK3qaIAt1i(z1cKcetAkjtH0ir1lqp0xZLihGrJ8gcquBQ8LxcI9igm1ooMcPrIQxGEOVMlroYudgK9aYxEjq4C9E9R30UbSWFrjQr8ZQfqH0ir1lqp0xZLi3R30UbS4ubtH0ir1lqp0xZLihYgJgjabQGHPqAKO6fOh6R5sKdWOrEdbiQnv(Yl5C9E9SAKraXmE7N(osH0ir1lqp0xZLi3WYL9fIfN(DKV8swEIqmSeN(D0ZANfLJhK7qdy0iVHae1MQJIatTPYKT8eHyyjo97OhNYO(1llt2YteIHL40VJgmfzJl7OqAKO6fOh6R5sKdMY5eGPDG)GrMGHd2qeI4ahym]] )


end