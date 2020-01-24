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
        gladiators_medallion = 3568, -- 208683
        relentless = 3567, -- 196029
        adaptation = 3566, -- 214027

        trackers_net = 665, -- 212638
        roar_of_sacrifice = 663, -- 53480
        mending_bandage = 662, -- 212640
        hunting_pack = 661, -- 203235
        viper_sting = 3615, -- 202797
        sticky_tar = 664, -- 203264
        dragonscale_armor = 3610, -- 202589
        scorpid_sting = 3609, -- 202900
        spider_sting = 3608, -- 202914
        diamond_ice = 686, -- 203340
        hiexplosive_trap = 3606, -- 236776
        survival_tactics = 3607, -- 202746
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
            generate = function ()
                local kc = debuff.kill_command
                local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 259277, "PLAYER" )

                if name then
                    kc.name = name
                    kc.count = 1
                    kc.expires = expires
                    kc.applied = expires - duration
                    kc.caster = caster
                    return
                end

                kc.count = 0
                kc.expires = 0
                kc.applied = 0
                kc.caster = "nobody"
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
            duration = 3600,
            max_stack = 2,
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

                if level < 116 and equipped.frizzos_fingertrap and active_dot.lacerate > 0 then
                    active_dot.lacerate = active_dot.lacerate + 1
                end

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

            toggle = "cooldowns",

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

                if level < 116 and equipped.frizzos_fingertrap and active_dot.lacerate > 0 then
                    active_dot.lacerate = active_dot.lacerate + 1
                end

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

            spend = 30,
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

            usable = function () return pet.alive end,
            handler = function ()
                applyBuff( "coordinated_assault" )
            end,
        },


        disengage = {
            id = 781,
            cast = 0,
            charges = 1,
            cooldown = 20,
            recharge = 20,
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
            cooldown = 40,
            gcd = "spell",

            startsCombat = true,
            texture = 236184,

            talent = "flanking_strike",

            usable = function () return pet.alive end,
            handler = function ()
                gain( 30, "focus" )
            end,
        },


        --[[ flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135815,

            handler = function ()
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

            usable = function () return target.distance > 8 end,
            handler = function ()
                applyDebuff( "target", "harpoon" )
                if talent.terms_of_engagement.enabled then applyBuff( "terms_of_engagement" ) end
                setDistance( 5 )
            end,
        },


        intimidation = {
            id = 19577,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 132111,

            usable = function () return pet.alive end,
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

            usable = function () return pet.alive end,
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


        masters_call = {
            id = 272682,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 236189,

            usable = function () return pet.alive end,
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

            spend = 30,
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


    spec:RegisterPack( "Survival", 20200124, [[dC0iRbqivfEKcuUKQiLSjvjFcHKWOqi1PiizvQI4vkuZIG6wkGSlb)cbnmcIJPk1YuG8mfGPPaQRHqSnvrY3iivJdHeNJGuwNQifZtvP7rG9PQihuvKQfIq9qfOQUOcuHrQksPojcjrRuvyMiKK6Mkqv2PQQgkcjjlvbQONQIPQQYEb(lrdwKdt1Iv0JHmzrDzuBMuFwiJwbDAjRgHK61iWSj52iA3k9BPgUqDCfOslhQNdA6uUUkTDcX3viJxvuNNqA9QkQ5tO2psdEd(boz3yW)bjKbjeH8EqdCqicTbjeIaoMOXm4e7ic8igCwNKbNZflsjIRaNyxuv7zWpWb2xmIbNHMfdFAiKWOYgENbutsiSiVk3QEryxBeclseHGZ8wkJOYfmbNSBm4)GeYGeIqEpOboieH2GeYateWXV2WgdoNI8QCR6DWh7AdCgw5mVGj4KzicCgmA6CXIuI4kA6P9DngtFmy00qZIHpnesyuzdVZaQjjewKxLBvViSRncHfjIq6JbJME471XIstd6TW00GeYGec9b9XGrtd(d9nIHpn0hdgnnq00tpN5mnn4D)8NvmnznnLzTFvgn5iR6LMuf0c0hdgnnq00G)qFJ4mnzooInzPPj(5ymdHvVqAYAAcjksXsZXrSbd0hdgnnq00GxNlDXzAc5yryjkJPjRPPrnMaAISXmnXoSuIstJkBinzdzAYZ5EjQastfzSIj51CR6LMAnnjIJlFQ4a9XGrtden90ZzottxRuLjkn90jQIO6a4OkObb)ahpgAGFG)Vb)ahE9PIZaIbheUmgxo4mVADa1noxRBCw6qOFvw4gttVOjIMMMxToG6gNR1nolDi0VklGzsVwin9LMEhicn9eAkcLPjXIPP5vRdt1flBT0CvVWWnMMErtZRwhMQlw2AP5QEHbmt61cPPV007arOPNqtrOmnjuGJJSQxWHS3OUHSCwgdmW)bb(bo86tfNbedoiCzmUCWzE16aQBCUw34S0Hq)QSWnMMErtennnVADa1noxRBCw6qOFvwaZKETqA6ln9oqeA6j0uekttIfttZRwhMQlw2AP5QEHHBmn9IMMxTomvxSS1sZv9cdyM0RfstFPP3bIqtpHMIqzAsOahhzvVGd2JTglHgUiGbg4)aa)ahE9PIZaIbheUmgxo4OB0fstJPjKdnjMJ4LM(st6gDHbs)zWXrw1l4Ov(sqTrsOHlcyGb(pWGFGdV(uXzaXGJJSQxWHGsPKOMK03m4GWLX4Ybh9vPKygn0XrS0ksMM(stVdeHMEcnfHY00lAs3OlKMgttihAsmhXln9LM0n6cdK(ZGdsuKILMJJydc()gyG)eb8dC41NkodigCq4YyC5GJUrxinnMMqo0KyoIxA6lnPB0fgi9NbhhzvVGd0ywjnShdmW)Nc8dC41NkodigCq4YyC5GJUrxinnMMqo0KyoIxA6lnPB0fgi9NPPx00h0KvicQnIMErtFqtZRwhizYglQS1s1fvzzgZojmCJPPx0ertt6RsjXmAOJJyPvKmn9LMEhicn9eAkcLPjXIPPpOPCBHrLkRlmlNn5myfIGAJOPx00h008Q1bu34CTUXzPdH(vzHBmnjwmn9bnLBlmQuzDHz5SjNbRqeuBen9IMMxToq2Bu3qwQVyrdqZreqtFPP30KqrtIfttwrYsRL5IPPV00BIcn9IM(GMYTfgvQSUWSC2KZGvicQncCCKv9coJkvwxywoBYjWa)f6GFGdV(uXzaXGdcxgJlhC(GMYTfGmoMxtcTAJcwHiO2iA6fn9bnnVADa1noxRBCw6qOFvw4gdooYQEbhiJJ51KqR2iGb(tua)ahE9PIZaIbhhzvVGdbLsjrnjPVzWbHlJXLdo6gDH00yAc5qtI5iEPPV0KUrxyG0FMMErtennnVADGS3OUHSuFXIgGMJiGM(steHMelMM0n6cPPV0KJSQ3azVrDdz5SmoGAOrtcf4GefPyP54i2GG)Vbg4Vqd8dC41NkodigCq4YyC5GdM1ygo0NkMMErtFqtZRwhqDJZ16gNLoe6xLfUX00lAAE16azVrDdzP(Ifnanhran9LMic44iR6fCGmoMxtcTAJag4)BHa(bo86tfNbedoiCzmUCW5dAAE16aQBCUw34S0Hq)QSWngCCKv9coUK8IZmw2Ajc3JGad8)9BWpWHxFQ4mGyWbHlJXLdoFqtZRwhqDJZ16gNLoe6xLfUXGJJSQxWb1noxRBCw6qOFvgWa)FpiWpWHxFQ4mGyWbHlJXLdoZRwhi7nQBil1xSOHBmnjwmnPB0fstJPjKdnjMJ4LM(enPB0fgi9NPPbIMEleAsSyAAE16aQBCUw34S0Hq)QSWngCCKv9coK9g1nKLZYyGb()EaGFGJJSQxWb7XwJLqdxeWGdV(uXzaXad8)9ad(bo86tfNbedoiCzmUCW5dAYkeb1gbooYQEbNrLkRlmlNn5eyadCqk2fHb)a)Fd(bo86tfNbedoDm4azR0GJJSQxWrehx(uXGJiowUojdoihlclrzm4GWLX4YbhhzLiSKxMSyin9LMic4iIRUSKvqgCic4iIRUm44iReHL8YKfdbg4)Ga)ahhzvVGJljV4mJLTwIW9ii4WRpvCgqmWa)ha4h44iR6fCqDJZ16gNLoe6xLbo86tfNbedmW)bg8dC41NkodigCq4YyC5GtUTaCi2JxwjNn5myfIGAJahhzvVGdYXIWad8NiGFGdV(uXzaXGdcxgJlhC(GMmxXRfIUmgxkLlnhzfcg41NkottIftt6RsjXmAOJJyPvKmn9LMIqzWXrw1l4mQuzDHz5SjNad8)Pa)ahE9PIZaIbhhzvVGdzVrDdz5SmgCq4YyC5GtMNxToOCJxtg3fS3a0Ceb0KaA6TqahKOiflnhhXge8)nWa)f6GFGJJSQxWbn0ja7KqWHxFQ4mGyGb(tua)ahE9PIZaIbhhzvVGdbLsjrnjPVzWbHlJXLdo6gDH00yAc5qtI5iEPPV0KUrxyG0FgCqIIuS0CCeBqW)3ad8xOb(bo86tfNbedoiCzmUCWrFvkjMrdDCelTIKPPV0uekttIfttFqtMR41cJkvwxywwR(cREd86tfNPjXIPPCBb4qShVSsoBYzWkeb1grtVOPCBHAngVUsovmNRnkanhran9LMga44iR6fCMxdnKXIcmW)3cb8dC41NkodigCq4YyC5GJ5kETq0LX4sPCP5iRqWaV(uXzWXrw1l4GCSimWa)F)g8dC41NkodigCq4YyC5GJUrxinnMMqo0KyoIxA6lnPB0fgi9NbhhzvVGJw5lb1gjHgUiGbg4)7bb(bo86tfNbedoiCzmUCWj3wyuPY6cZYztodywJz4qFQyAsSyAYCfVwyuPY6cZYA1xy1BGxFQ4m44iR6fCgvQSUWSC2KtGb()EaGFGdV(uXzaXGJJSQxWbY4yEnj0QncCq4YyC5GZ8Q1brQygdLIWBtgWSJmWbjksXsZXrSbb)FdmW)3dm4h4WRpvCgqm4GWLX4Ybhu3QCpAdJkvwxywoBYzaZKETqA6t0KioU8PIdihlclrzmn90IMge44iR6fCqowegyG)Vjc4h44iR6fCGgZkPH9yWHxFQ4mGyGb()(Pa)ahE9PIZaIbheUmgxo4yUIxlymMekBTK3ipIj51c86tfNbhhzvVGZqhh39cmW)3cDWpWHxFQ4mGyWXrw1l4azCmVMeA1gboiCzmUCWbZAmdh6tfttVOP5vRdwflBT0gYsym74a0Ceb00xAAaGdsuKILMJJydc()gyG)VjkGFGdV(uXzaXGJJSQxWHS3OUHSCwgdoirrkwAooIni4)BGb()wOb(bo86tfNbedooYQEbhShBnwcnCradoirrkwAooIni4)BGbmWbAGFG)Vb)ahE9PIZaIbheUmgxo4yUIxlymMekBTK3ipIj51c86tfNbhhzvVGZqhh39cmW)bb(bo86tfNbedoiCzmUCWr3OlKMgttihAsmhXln9LM0n6cdK(ZGJJSQxWrR8LGAJKqdxeWad8FaGFGdV(uXzaXGdcxgJlhCMxToG6gNR1nolDi0VklCJPPx0erttZRwhqDJZ16gNLoe6xLfWmPxlKM(stVdeHMEcnfHY0KyX008Q1HP6ILTwAUQxy4gttVOP5vRdt1flBT0CvVWaMj9AH00xA6DGi00tOPiuMMekWXrw1l4G9yRXsOHlcyGb(pWGFGdV(uXzaXGdcxgJlhCMxToG6gNR1nolDi0VklCJPPx0erttZRwhqDJZ16gNLoe6xLfWmPxlKM(stVdeHMEcnfHY0KyX008Q1HP6ILTwAUQxy4gttVOP5vRdt1flBT0CvVWaMj9AH00xA6DGi00tOPiuMMekWXrw1l4q2Bu3qwolJbg4pra)ahE9PIZaIbhhzvVGdbLsjrnjPVzWbHlJXLdo6gDH00yAc5qtI5iEPPV0KUrxyG0FgCqIIuS0CCeBqW)3ad8)Pa)ahE9PIZaIbheUmgxo4OB0fstJPjKdnjMJ4LM(st6gDHbs)zWXrw1l4anMvsd7Xad8xOd(bo86tfNbedoiCzmUCWr3OlKMgttihAsmhXln9LM0n6cdK(Z00lA6dAYkeb1grtVOPpOP5vRdKmzJfv2AP6IQSmJzNegUX00lAIOPj9vPKygn0XrS0ksMM(stVdeHMEcnfHY0KyX00h0uUTWOsL1fMLZMCgScrqTr00lA6dAAE16aQBCUw34S0Hq)QSWnMMelMM(GMYTfgvQSUWSC2KZGvicQnIMErtZRwhi7nQBil1xSObO5icOPV00BAsOOjXIPjRizP1YCX00xA6nrHMErtFqt52cJkvwxywoBYzWkeb1gbooYQEbNrLkRlmlNn5eyG)efWpWHxFQ4mGyWbHlJXLdoZRwhePIzmukcVnz4gttVOPCBbiJJ51KqR2OaMj9AH00xAAGPPNqtrOmnjwmnLBlazCmVMeA1gfWSgZWH(uX00lA6dAAE16aQBCUw34S0Hq)QSWngCCKv9coqghZRjHwTrad8xOb(bo86tfNbedoiCzmUCW5dAAE16aQBCUw34S0Hq)QSWngCCKv9coUK8IZmw2Ajc3JGad8)Tqa)ahE9PIZaIbheUmgxo48bnnVADa1noxRBCw6qOFvw4gdooYQEbhu34CTUXzPdH(vzad8)9BWpWHxFQ4mGyWbHlJXLdoZRwhi7nQBil1xSOHBmnjwmnPB0fstJPjKdnjMJ4LM(enPB0fgi9NPPbIMgKqOPx0K5kETGivmJHsr4Tjd86tfNPjXIPjDJUqAAmnHCOjXCeV00NOjDJUWaP)mnnq00BA6fnzUIxlymMekBTK3ipIj51c86tfNPjXIPP5vRdOUX5ADJZshc9RYc3yWXrw1l4q2Bu3qwolJbg4)7bb(booYQEbhShBnwcnCrado86tfNbedmW)3da8dC41NkodigCq4YyC5GtUTWOsL1fMLZMCgWSgZWH(uXGJJSQxWzuPY6cZYztobg4)7bg8dC41NkodigCq4YyC5GZ8Q1brQygdLIWBtgUXGJJSQxWbY4yEnj0QncyadCgPlWpW)3GFGdV(uXzaXGdcxgJlhC0n6cPPX0eYHMeZr8stFPjDJUWaP)mn9IMmxXRfmgtcLTwYBKhXK8AbE9PIZGJJSQxWzOJJ7Ebg4)Ga)ahE9PIZaIbheUmgxo4mVADyQUyzRLMR6fgUX00lAAE16WuDXYwlnx1lmGzsVwin9LMIqzWXrw1l4q2Bu3qwolJbg4)aa)ahE9PIZaIbheUmgxo4mVADyQUyzRLMR6fgUX00lAAE16WuDXYwlnx1lmGzsVwin9LMIqzWXrw1l4G9yRXsOHlcyGb(pWGFGdV(uXzaXGdcxgJlhCMxToisfZyOueEBYWnMMErtZRwhePIzmukcVnzaZKETqA6ln9oqeA6j0uekttIfttFqt52cqghZRjHwTrbRqeuBe44iR6fCGmoMxtcTAJag4pra)ahE9PIZaIbheUmgxo4OVkLeZOHooILwrY00xA6DGi00tOPiuMMErt6gDH00yAc5qtI5iEPPV0KUrxyG0FMMelMMiAAA5Nn5OsoBYzqKw5wPyA6fnLBlazCmVMeA1gfScrqTr00lAk3waY4yEnj0QnkGznMHd9PIPjXIPPLF2KJk5SjNH4HmUj7LPPx00h008Q1bYEJ6gYs9flA4gttVOjDJUqAAmnHCOjXCeV00xAs3Olmq6pttden5iR6nqqPusuts6BoGCOjXCeV00tOPbqtcf44iR6fCgvQSUWSC2KtGb()uGFGdV(uXzaXGdcxgJlhC0n6cPPX0eYHMeZr8stFPjDJUWaP)mnnq0KUrxyaZr8cooYQEbhckLsIAssFZad8xOd(booYQEbhxsEXzglBTeH7rqWHxFQ4mGyGb(tua)ahE9PIZaIbheUmgxo4OB0fstJPjKdnjMJ4LM(st6gDHbs)zWXrw1l4anMvsd7Xad8xOb(bo86tfNbedoiCzmUCWrFvkjMrdDCelTIKPPV007arOPNqtrOm44iR6fCgvQSUWSC2KtGb()wiGFGJJSQxWb1noxRBCw6qOFvg4WRpvCgqmWa)F)g8dC41NkodigCq4YyC5GZ8Q1brQygdLIWBtgUX00lAk3waY4yEnj0QnkGzsVwin9LMgyA6j0uekdooYQEbhiJJ51KqR2iGb()EqGFGdV(uXzaXGdcxgJlhCYTfGdXE8Yk5SjNbRqeuBenjwmnnVADGS3OUHSuFXIgGMJiGMeqtebCCKv9coK9g1nKLZYyGb()EaGFGdV(uXzaXGdcxgJlhCw(ztoQKZMCgGdXE8YkA6fnLBlazCmVMeA1gfWmPxlKM(enreA6j0uekdooYQEbNrLkRlmlNn5eyG)VhyWpWHxFQ4mGyWbHlJXLdoywJz4qFQyWXrw1l4azCmVMeA1gbmW)3eb8dC41NkodigCq4YyC5GZh008Q1bYEJ6gYs9flAaZKETqWXrw1l4Gg6eGDsiWa)F)uGFGJJSQxWHS3OUHSCwgdo86tfNbedmW)3cDWpWXrw1l4G9yRXsOHlcyWHxFQ4mGyGb()MOa(bo86tfNbedoiCzmUCWzE16GivmJHsr4Tjd3yWXrw1l4azCmVMeA1gbmW)3cnWpWHxFQ4mGyWbHlJXLdol)SjhvYztodI0k3kfttVOPCBbiJJ51KqR2OGvicQnIMelMMw(ztoQKZMCgIhY4MSxMMelMMw(ztoQKZMCgGdXE8YkWXrw1l4mQuzDHz5SjNadyGJhpsxGFG)Vb)ahE9PIZaIbheUmgxo4mVADyQUyzRLMR6fgUX00lAAE16WuDXYwlnx1lmGzsVwin9LMIqzWXrw1l4q2Bu3qwolJbg4)Ga)ahE9PIZaIbheUmgxo4mVADyQUyzRLMR6fgUX00lAAE16WuDXYwlnx1lmGzsVwin9LMIqzWXrw1l4G9yRXsOHlcyGb(paWpWHxFQ4mGyWbHlJXLdoFqt52cqghZRjHwTrbRqeuBe44iR6fCGmoMxtcTAJag4)ad(booYQEbhxsEXzglBTeH7rqWHxFQ4mGyGb(teWpWHxFQ4mGyWbHlJXLdo6RsjXmAOJJyPvKmn9LMEhicn9eAkcLPjXIPjDJUqAAmnHCOjXCeV00xAs3Olmq6pttVOjIMMw(ztoQKZMCgePvUvkMMErt52cqghZRjHwTrbRqeuBen9IMYTfGmoMxtcTAJcywJz4qFQyAsSyAA5Nn5OsoBYziEiJBYEzA6fn9bnnVADGS3OUHSuFXIgUX00lAs3OlKMgttihAsmhXln9LM0n6cdK(Z00artoYQEdeukLe1KK(MdihAsmhXln9eAAa0KqbooYQEbNrLkRlmlNn5eyG)pf4h44iR6fCqDJZ16gNLoe6xLbo86tfNbedmWFHo4h4WRpvCgqm4GWLX4YbN5vRdK9g1nKL6lw0aMj9AH00lAA5Nn5OsoBYziEiJBYEzWXrw1l4q2Bu3qwolJbg4prb8dC41NkodigCq4YyC5GJ(QusmJg64iwAfjttFPP3bIqtpHMIqzA6fnPB0fstJPjKdnjMJ4LM(st6gDHbs)zAAGOPbjeWXrw1l4qqPusuts6BgyG)cnWpWHxFQ4mGyWbHlJXLdo6gDH00yAc5qtI5iEPPV0KUrxyG0FgCCKv9coqJzL0WEmWa)FleWpWHxFQ4mGyWbHlJXLdoZRwhSkw2APnKLWy2XbO5icOjb00aOjXIPPCBb4qShVSsoBYzWkeb1gbooYQEbhShBnwcnCradmW)3Vb)ahE9PIZaIbheUmgxo4KBlahI94LvYztodwHiO2iWXrw1l4q2Bu3qwolJbg4)7bb(bo86tfNbedoiCzmUCWz5Nn5OsoBYzaoe7XlROPx0KUrxin9jAAacHMErt52cqghZRjHwTrbmt61cPPprteHMEcnfHYGJJSQxWzuPY6cZYztobg4)7ba(bo86tfNbedoiCzmUCW5dAAE16azVrDdzP(IfnGzsVwi44iR6fCqdDcWojeyG)VhyWpWHxFQ4mGyWbHlJXLdoywJz4qFQyWXrw1l4azCmVMeA1gbmW)3eb8dC41NkodigCq4YyC5GJUrxinnMMqo0KyoIxA6lnPB0fgi9NPPx0erttZRwhi7nQBil1xSObO5icOPV0erOjXIPjDJUqA6ln5iR6nq2Bu3qwolJdOgA0KqbooYQEbhckLsIAssFZad8)9tb(booYQEbhShBnwcnCrado86tfNbedmW)3cDWpWHxFQ4mGyWbHlJXLdoZRwhi7nQBil1xSOHBmnjwmnPB0fstFIMgyHqtIftt52cWHypEzLC2KZGvicQncCCKv9coK9g1nKLZYyGb()MOa(bo86tfNbedoiCzmUCWz5Nn5OsoBYzqKw5wPyA6fnLBlazCmVMeA1gfScrqTr0KyX00YpBYrLC2KZq8qg3K9Y0KyX00YpBYrLC2KZaCi2JxwrtVOjDJUqA6t0erec44iR6fCgvQSUWSC2KtGbmWjgZOMC6g4h4)BWpWXrw1l4aVKK9kJzdC41NkodigyG)dc8dC41NkodigCwNKbh)ZWHo2HsDVMS1Y4EeJbhhzvVGJ)z4qh7qPUxt2AzCpIXad8FaGFGJJSQxWj664C5RS1s)ZmUTHGdV(uXzaXad8FGb)ahhzvVGtCBvVGdV(uXzaXad8NiGFGdV(uXzaXGJJSQxWbjks1gU3cjNkhAGdcxgJlhC(GMWELLSi8AHAf5Qwg7tfh4NlObbhwRzKjxNKbhKOivB4ElKCQCObmW)Nc8dCCKv9coqJzL0WEm4WRpvCgqmWa)f6GFGJJSQxWzOJJ7EbhE9PIZaIbgWahugc(b()g8dC41NkodigCq4YyC5GdQBvUhTbu34CTUXzPdH(vzbmt61cPPprtdqiGJJSQxWzQ6ol1xSOad8FqGFGdV(uXzaXGdcxgJlhCqDRY9OnG6gNR1nolDi0VklGzsVwin9jAAacbCCKv9co(IyOHDLe5kfWa)ha4h4WRpvCgqm4GWLX4Ybhu3QCpAdOUX5ADJZshc9RYcyM0RfstFIMgGqahhzvVGJUW8u1DgyG)dm4h44iR6fCuv0qdkjQV5isEnWHxFQ4mGyGb(teWpWHxFQ4mGyWbHlJXLdoOUv5E0gqDJZ16gNLoe6xLfWmPxlKM(en9ucHMelMMSIKLwlZfttFPP3daCCKv9cotgdzmb1gbmW)Nc8dC41NkodigCq4YyC5GZ8Q1HORJZLVYwl9pZ42ggUX00lAIOPP5vRdtgdzmb1gfUX0KyX008Q1HPQ7SuFXIgUX0KyX00h0e2rCWWTsrtcfnjwmnr00eQx4L0Nkoe3w1RS1Y7oXvwXzP(IfLMErtwrYsRL5IPPV00t9MMelMMSIKLwlZfttFPPb9u0KqrtIfttFqtmeYlIdOEZ8c5SuvAw3yehiDI6gttVOP5vRdOUX5ADJZshc9RYc3yWXrw1l4e3w1lWa)f6GFGdV(uXzaXGdcxgJlhCmhhXwixqZxettFsan9uGJJSQxWXHXmYKTwAdzj7rkgyG)efWpWHxFQ4mGyWXrw1l44WHI4ldLy)ZnwIASRaheUmgxo4WdU3koMZHmUMtvTrYAjiUZ00lAIOPPmpVADa7FUXsuJDLmZZRwhY9OLMelMMSIKLwlJrMCacHM(stVPjXIPjIMMgYUYggIrgn9LMgGqOPx008Q1HORJZLVYwl9pZ42ggUX0KyX008Q1bsMSXIkBTuDrvwMXStcd3yAsOOjHIMelMMiAA6dAIhCVvCmNdzCnNQAJK1sqCNPPx0erttZRwhizYglQS1s1fvzzgZojmCJPjXIPP5vRdrxhNlFLTw6FMXTnmCJPPx0eQBvUhTHORJZLVYwl9pZ42ggWmPxlKM(en9wOteAsOOjXIPPmpVADa7FUXsuJDLmZZRwhY9OLMekAsSyAYkswATmxmn9LMgKqaN1jzWXHdfXxgkX(NBSe1yxbmWFHg4h4WRpvCgqm44iR6fCICfJCLIXq5S7fCq4YyC5GdQBvUhTbsMSXIkBTuDrvwMXStcdyM0RfstIfttMR41cJkvwxywwR(cREd86tfNPPx0eQBvUhTbu34CTUXzPdH(vzbmt61cPjXIPju3QCpAdirrQ2W9wi5u5qlGzsVwinjwmn9bnXqiVioqYKnwuzRLQlQYYmMDsyG0jQBmn9IMqDRY9OnG6gNR1nolDi0VklGzsVwi4SojdorUIrUsXyOC29cmW)3cb8dC41NkodigCwNKbh)ZWHo2HsDVMS1Y4EeJbhhzvVGJ)z4qh7qPUxt2AzCpIXad8)9BWpWXrw1l4OB0fYzP)zgxglNStco86tfNbedmW)3dc8dC41NkodigCq4YyC5GJUrxin9LM0n6cdK(Z00artdqi00lAAE16aQBCUw34S0Hq)QSWngCCKv9coKmzJfv2AP6IQSmJzNecmW)3da8dC41NkodigCq4YyC5GZ8Q1bu34CTUXzPdH(vzHBm44iR6fCMQUZYwlTHSKxMuuGb()EGb)ahhzvVGt8fxArRnsovo0ahE9PIZaIbg4)BIa(booYQEbNORJZLVYwl9pZ42gco86tfNbedmW)3pf4h44iR6fCWvCSIL1kHXoIbhE9PIZaIbg4)BHo4h4WRpvCgqm4GWLX4Ybh9vPKygn0XrS0ksMM(stVPPNqtrOm44iR6fCq9I41WUXzPw5KmWa)Ftua)ahE9PIZaIbheUmgxo4mVADaZicumek1ngXHBm44iR6fCSHS8UZ(UzPUXigyG)VfAGFGJJSQxWzuJvzr4ALyg2RVigC41NkodigyG)dsiGFGdV(uXzaXGdcxgJlhCmhhXwyi7kByigz00NOjIIqOjXIPjZXrSfgYUYggIrgn9vanniHqtIfttMJJylyfjlTwgJm5Gecn9jAAacbCCKv9coy2JRnsQvojdbgWaNmR9RYa)a)Fd(bo86tfNbedoiCzmUCWjZZRwhqo0QnkCJPjXIPP5vRd5cgZkLpvSK0Jku4gttIfttZRwhYfmMvkFQyjVypId3yWXrw1l4GCLs6iR6vQkOboQcAY1jzW5ALQmrbg4)Ga)ahhzvVGZfYYYysi4WRpvCgqmWa)ha4h4WRpvCgqm44iR6fCqUsjDKv9kvf0ahvbn56Km4GYqGb(pWGFGdV(uXzaXGdcxgJlhCmxXRfCv8qxgJ5SBnoWRpvCMMErtwrYsRL5IPPV00BHqtIfttwrYsRL5IPPV0erahhzvVGdzVrDdz5SmgyG)eb8dC41NkodigCq4YyC5GJJSsewYltwmKM(stdGMErtMR41cOHobyNeg41NkottVOjZv8Abxfp0LXyo7wJd86tfNbhhzvVGdYvkPJSQxPQGg4OkOjxNKbhpEKUag4)tb(bo86tfNbedoiCzmUCWXrwjcl5LjlgstFPPbqtVOjZv8Ab0qNaStcd86tfNbhhzvVGdYvkPJSQxPQGg4OkOjxNKbNr6cyG)cDWpWHxFQ4mGyWbHlJXLdooYkryjVmzXqA6lnnaA6fn9bnzUIxl4Q4HUmgZz3ACGxFQ4mn9IM(GMmxXRfgvQSUWSSw9fw9g41NkodooYQEbhKRushzvVsvbnWrvqtUojdoqdyG)efWpWHxFQ4mGyWbHlJXLdooYkryjVmzXqA6lnnaA6fnzUIxl4Q4HUmgZz3ACGxFQ4mn9IM(GMmxXRfgvQSUWSSw9fw9g41NkodooYQEbhKRushzvVsvbnWrvqtUojdoEm0ag4Vqd8dC41NkodigCq4YyC5GJJSsewYltwmKM(stdGMErtMR41cUkEOlJXC2Tgh41NkottVOjZv8AHrLkRlmlRvFHvVbE9PIZGJJSQxWb5kL0rw1RuvqdCuf0KRtYGJhpsxad8)Tqa)ahE9PIZaIbheUmgxo44iReHL8YKfdPPV00aOPx00h0K5kETGRIh6YymNDRXbE9PIZ00lAYCfVwyuPY6cZYA1xy1BGxFQ4m44iR6fCqUsjDKv9kvf0ahvbn56Km4msxad8)9BWpWHxFQ4mGyWbHlJXLdooYkryjVmzXqA6t00BA6fn9bnzUIxlmlCgkBTmgZIg41NkottIfttoYkryjVmzXqA6t00GahhzvVGdYvkPJSQxPQGg4OkOjxNKbhKIDryGb()EqGFGJJSQxWb1lIxd7gNLALtYGdV(uXzaXad8)9aa)ahhzvVGJJr(YsRXyEnWHxFQ4mGyGb()EGb)ahhzvVGZ0JKTwA4craeC41NkodigyadCUwPktuWpW)3GFGJJSQxWH8(5pRyWHxFQ4mGyGb(piWpWXrw1l4azmVLjQmFHg4WRpvCgqmWa)ha4h44iR6fCGXnMLivFZGdV(uXzaXad8FGb)ahhzvVGdSBByTrYrUXyWHxFQ4mGyGb(teWpWXrw1l4a7TqYPYHg4WRpvCgqmWa)FkWpWXrw1l4SSnKXs4Wgra4WRpvCgqmWa)f6GFGJJSQxWbnSiQlO0W(o4ElvzIco86tfNbedmWFIc4h44iR6fCGXfUmjCyJiaC41NkodigyG)cnWpWXrw1l4SUDXmugHDedo86tfNbedmGbmWregdREb)hKqEl0E)(9BWzKJ3AJGGdrLKXn24mnj0OjhzvV0KQGgmqFaoWygb(piIqeWjg36sXGZGrtNlwKsexrtpTVRXy6JbJMgAwm8PHqcJkB4DgqnjHWI8QCR6fHDTriSiresFmy00dFVowuAAqVfMMgKqgKqOpOpgmAAWFOVrm8PH(yWOPbIME65mNPPbV7N)SIPjRPPmR9RYOjhzvV0KQGwG(yWOPbIMg8h6BeNPjZXrSjlnnXphJziS6fstwttirrkwAooInyG(yWOPbIMg86CPlottihlclrzmnznnnQXeqtKnMPj2HLsuAAuzdPjBittEo3lrfqAQiJvmjVMBvV0uRPjrCC5tfhOpgmAAGOPNEoZzA6ALQmrPPNorvevhOpOpgmAAWXZm6ACMMMSUXmnHAYPB00KJQfgOPNocXXgKM2EhOHoMuFv0KJSQxin1Rs0a9XGrtoYQEHHymJAYPBc0khsa9XGrtoYQEHHymJAYPBJfqOFJi51CR6L(yWOjhzvVWqmMrn50TXciu3DM(Wrw1lmeJzutoDBSacHxsYELXSrFmy00z9y4W2OjSxzAAE1AottqZninnzDJzAc1Kt3OPjhvlKM8nttXyEGIBZQnIMkinL7Ld0hdgn5iR6fgIXmQjNUnwaHW1JHdBtcn3G0hoYQEHHymJAYPBJfq4fYYYysHxNKf4Fgo0XouQ71KTwg3Jym9HJSQxyigZOMC62ybegDDCU8v2AP)zg32q6dhzvVWqmMrn50TXcimUTQx6dhzvVWqmMrn50TXci8czzzmPWSwZitUojlajks1gU3cjNkhAcxAbFG9klzr41c1kYvTm2NkoWpxqdsF4iR6fgIXmQjNUnwaHqJzL0WEm9HJSQxyigZOMC62ybeo0XXDV0h0hoYQEHHRvQYeva59ZFwX0hoYQEHHRvQYeDSacHmM3YevMVqJ(Wrw1lmCTsvMOJfqimUXSeP6BM(Wrw1lmCTsvMOJfqiSBByTrYrUXy6dhzvVWW1kvzIowaHWElKCQCOrF4iR6fgUwPkt0XciCzBiJLWHnIa6dhzvVWW1kvzIowaHOHfrDbLg23b3BPktu6dhzvVWW1kvzIowaHW4cxMeoSreqF4iR6fgUwPkt0XciCD7IzOmc7iM(G(yWOPbhpZORXzAIfHXIstwrY0KnKPjhznMMkin5I4LYNkoqF4iR6fka5kL0rw1Ruvqt41jzbxRuLjQWLwqMNxToGCOvBu4glw88Q1HCbJzLYNkws6rfkCJflEE16qUGXSs5tfl5f7rC4gtF4iR6fowaHxillJjH0hoYQEHJfqiYvkPJSQxPQGMWRtYcqzi9HJSQx4ybes2Bu3qwolJfU0cmxXRfCv8qxgJ5SBnoWRpvC(LvKS0AzU4VVfIyXwrYsRL5I)se6dhzvVWXcie5kL0rw1Ruvqt41jzbE8iDjCPf4iReHL8YKfd)oGxMR41cOHobyNeg41Nko)YCfVwWvXdDzmMZU14aV(uXz6dhzvVWXcie5kL0rw1Ruvqt41jzbJ0LWLwGJSsewYltwm87aEzUIxlGg6eGDsyGxFQ4m9HJSQx4ybeICLs6iR6vQkOj86KSaOjCPf4iReHL8YKfd)oGxFyUIxl4Q4HUmgZz3ACGxFQ48RpmxXRfgvQSUWSSw9fw9g41NkotF4iR6fowaHixPKoYQELQcAcVojlWJHMWLwGJSsewYltwm87aEzUIxl4Q4HUmgZz3ACGxFQ48RpmxXRfgvQSUWSSw9fw9g41NkotF4iR6fowaHixPKoYQELQcAcVojlWJhPlHlTahzLiSKxMSy43b8YCfVwWvXdDzmMZU14aV(uX5xMR41cJkvwxywwR(cREd86tfNPpCKv9chlGqKRushzvVsvbnHxNKfmsxcxAboYkryjVmzXWVd41hMR41cUkEOlJXC2Tgh41Nko)YCfVwyuPY6cZYA1xy1BGxFQ4m9HJSQx4ybeICLs6iR6vQkOj86KSaKIDryHlTahzLiSKxMSy4NE)6dZv8AHzHZqzRLXyw0aV(uXzXIDKvIWsEzYIHFAq0hoYQEHJfqiQxeVg2nol1kNKPpCKv9chlGqhJ8LLwJX8A0hoYQEHJfq40JKTwA4craK(G(Wrw1lm4XqtazVrDdz5Smw4slyE16aQBCUw34S0Hq)QSWn(frpVADa1noxRBCw6qOFvwaZKETWVVde5jrOSyXZRwhMQlw2AP5QEHHB8R5vRdt1flBT0CvVWaMj9AHFFhiYtIqzHI(Wrw1lm4XqBSacXES1yj0WfbSWLwW8Q1bu34CTUXzPdH(vzHB8lIEE16aQBCUw34S0Hq)QSaMj9AHFFhiYtIqzXINxTomvxSS1sZv9cd34xZRwhMQlw2AP5QEHbmt61c)(oqKNeHYcf9HJSQxyWJH2ybeQv(sqTrsOHlcyHlTaDJUWXihAsmhX7xDJUWaP)m9HJSQxyWJH2ybesqPusuts6BwyKOiflnhhXguWBHlTa9vPKygn0XrS0ks(77arEsek)s3OlCmYHMeZr8(v3Olmq6ptF4iR6fg8yOnwaHqJzL0WESWLwGUrx4yKdnjMJ49RUrxyG0FM(Wrw1lm4XqBSachvQSUWSC2KtHlTaDJUWXihAsmhX7xDJUWaP)8RpScrqTrV(yE16ajt2yrLTwQUOklZy2jHHB8lIwFvkjMrdDCelTIK)(oqKNeHYIf)rUTWOsL1fMLZMCgScrqTrV(yE16aQBCUw34S0Hq)QSWnwS4pYTfgvQSUWSC2KZGvicQn618Q1bYEJ6gYs9flAaAoIGVVfkXITIKLwlZf)9nr51h52cJkvwxywoBYzWkeb1grF4iR6fg8yOnwaHqghZRjHwTrcxAbFKBlazCmVMeA1gfScrqTrV(yE16aQBCUw34S0Hq)QSWnM(Wrw1lm4XqBSacjOukjQjj9nlmsuKILMJJydk4TWLwGUrx4yKdnjMJ49RUrxyG0F(frpVADGS3OUHSuFXIgGMJi4lrelw3Ol8RJSQ3azVrDdz5SmoGAOju0hoYQEHbpgAJfqiKXX8AsOvBKWLwaM1ygo0Nk(1hZRwhqDJZ16gNLoe6xLfUXVMxToq2Bu3qwQVyrdqZre8Li0hoYQEHbpgAJfqOljV4mJLTwIW9iOWLwWhZRwhqDJZ16gNLoe6xLfUX0hoYQEHbpgAJfqiQBCUw34S0Hq)QmHlTGpMxToG6gNR1nolDi0VklCJPpCKv9cdEm0glGqYEJ6gYYzzSWLwW8Q1bYEJ6gYs9flA4glwSUrx4yKdnjMJ49t6gDHbs)5b6TqelEE16aQBCUw34S0Hq)QSWnM(Wrw1lm4XqBSacXES1yj0Wfbm9HJSQxyWJH2ybeoQuzDHz5SjNcxAbFyfIGAJOpOpCKv9cdE8iDjGS3OUHSCwglCPfmVADyQUyzRLMR6fgUXVMxTomvxSS1sZv9cdyM0Rf(ncLPpCKv9cdE8iDnwaHyp2ASeA4Iaw4slyE16WuDXYwlnx1lmCJFnVADyQUyzRLMR6fgWmPxl8BektF4iR6fg84r6ASacHmoMxtcTAJeU0c(i3waY4yEnj0QnkyfIGAJOpCKv9cdE8iDnwaHUK8IZmw2Ajc3JG0hoYQEHbpEKUglGWrLkRlmlNn5u4slqFvkjMrdDCelTIK)(oqKNeHYIfRB0fog5qtI5iE)QB0fgi9NFr0l)SjhvYztodI0k3kf)k3waY4yEnj0QnkyfIGAJELBlazCmVMeA1gfWSgZWH(uXIfV8ZMCujNn5mepKXnzV8RpMxToq2Bu3qwQVyrd34x6gDHJro0KyoI3V6gDHbs)5bYrw1BGGsPKOMK03Ca5qtI5iEFYaek6dhzvVWGhpsxJfqiQBCUw34S0Hq)Qm6dhzvVWGhpsxJfqizVrDdz5Smw4slyE16azVrDdzP(IfnGzsVw4RLF2KJk5SjNH4HmUj7LPpCKv9cdE8iDnwaHeukLe1KK(MfU0c0xLsIz0qhhXsRi5VVde5jrO8lDJUWXihAsmhX7xDJUWaP)8aniHqF4iR6fg84r6ASacHgZkPH9yHlTaDJUWXihAsmhX7xDJUWaP)m9HJSQxyWJhPRXcie7XwJLqdxeWcxAbZRwhSkw2APnKLWy2XbO5icemaXIZTfGdXE8Yk5SjNbRqeuBe9HJSQxyWJhPRXciKS3OUHSCwglCPfKBlahI94LvYztodwHiO2i6dhzvVWGhpsxJfq4OsL1fMLZMCkCPfS8ZMCujNn5mahI94LvV0n6c)0aeYRCBbiJJ51KqR2OaMj9AHFIipjcLPpCKv9cdE8iDnwaHOHobyNekCPf8X8Q1bYEJ6gYs9flAaZKETq6dhzvVWGhpsxJfqiKXX8AsOvBKWLwaM1ygo0NkM(Wrw1lm4XJ01ybesqPusuts6Bw4slq3OlCmYHMeZr8(v3Olmq6p)IONxToq2Bu3qwQVyrdqZre8LiIfRB0f(1rw1BGS3OUHSCwghqn0ek6dhzvVWGhpsxJfqi2JTglHgUiGPpCKv9cdE8iDnwaHK9g1nKLZYyHlTG5vRdK9g1nKL6lw0WnwSyDJUWpnWcrS4CBb4qShVSsoBYzWkeb1grF4iR6fg84r6ASachvQSUWSC2KtHlTGLF2KJk5SjNbrALBLIFLBlazCmVMeA1gfScrqTrIfV8ZMCujNn5mepKXnzVSyXl)SjhvYztodWHypEz1lDJUWpreHqFqF4iR6fgqzOGPQ7SuFXIkCPfG6wL7rBa1noxRBCw6qOFvwaZKETWpnaHqF4iR6fgqz4ybe6lIHg2vsKRucxAbOUv5E0gqDJZ16gNLoe6xLfWmPxl8tdqi0hoYQEHbugowaH6cZtv3zHlTau3QCpAdOUX5ADJZshc9RYcyM0Rf(Pbie6dhzvVWakdhlGqvfn0GsI6BoIKxJ(Wrw1lmGYWXciCYyiJjO2iHlTau3QCpAdOUX5ADJZshc9RYcyM0Rf(PNsiIfBfjlTwMl(77bqF4iR6fgqz4ybeg3w1RWLwW8Q1HORJZLVYwl9pZ42ggUXVi65vRdtgdzmb1gfUXIfpVADyQ6ol1xSOHBSyXFGDehmCRucLyXenQx4L0Nkoe3w1RS1Y7oXvwXzP(If9LvKS0AzU4Vp1BXITIKLwlZf)DqpLqjw8hmeYlIdOEZ8c5SuvAw3yehiDI6g)AE16aQBCUw34S0Hq)QSWnM(Wrw1lmGYWXci0HXmYKTwAdzj7rkw4slWCCeBHCbnFr8Ne8u0hoYQEHbugowaHxillJjfEDswGdhkIVmuI9p3yjQXUs4slGhCVvCmNdzCnNQAJK1sqCNFr0zEE16a2)CJLOg7kzMNxToK7rRyXwrYsRLXitoaH89TyXe9q2v2WqmY(oaH8AE16q01X5YxzRL(NzCBdd3yXINxToqYKnwuzRLQlQYYmMDsy4glucLyXe9h8G7TIJ5CiJR5uvBKSwcI78lIEE16ajt2yrLTwQUOklZy2jHHBSyXZRwhIUoox(kBT0)mJBBy4g)c1Tk3J2q01X5YxzRL(NzCBddyM0Rf(P3cDIiuIfN55vRdy)ZnwIASRKzEE16qUhTcLyXwrYsRL5I)oiHqF4iR6fgqz4ybeEHSSmMu41jzbrUIrUsXyOC29kCPfG6wL7rBGKjBSOYwlvxuLLzm7KWaMj9AHIfBUIxlmQuzDHzzT6lS6nWRpvC(fQBvUhTbu34CTUXzPdH(vzbmt61cflg1Tk3J2asuKQnCVfsovo0cyM0Rfkw8hmeYlIdKmzJfv2AP6IQSmJzNegiDI6g)c1Tk3J2aQBCUw34S0Hq)QSaMj9AH0hoYQEHbugowaHxillJjfEDswG)z4qh7qPUxt2AzCpIX0hoYQEHbugowaH6gDHCw6FMXLXYj7K0hoYQEHbugowaHKmzJfv2AP6IQSmJzNekCPfOB0f(v3Olmq6ppqdqiVMxToG6gNR1nolDi0VklCJPpCKv9cdOmCSacNQUZYwlTHSKxMuuHlTG5vRdOUX5ADJZshc9RYc3y6dhzvVWakdhlGW4lU0IwBKCQCOrF4iR6fgqz4ybegDDCU8v2AP)zg32q6dhzvVWakdhlGqCfhRyzTsySJy6dhzvVWakdhlGquViEnSBCwQvojlCPfOVkLeZOHooILwrYFF)KiuM(Wrw1lmGYWXci0gYY7o77ML6gJyHlTG5vRdygrGIHqPUXioCJPpCKv9cdOmCSach1yvweUwjMH96lIPpCKv9cdOmCSacXShxBKuRCsgkCPfyooITWq2v2WqmY(erriIfBooITWq2v2WqmY(kyqcrSyZXrSfSIKLwlJrMCqc5tdqi0h0hoYQEHbKIDrybI44YNkw41jzbihlclrzSWDSaiBLwyrC1Lf4iReHL8YKfdfwexDzjRGSaIimQ3CzvVcCKvIWsEzYIHFjc9HJSQxyaPyxeESacDj5fNzSS1seUhbPpCKv9cdif7IWJfqiQBCUw34S0Hq)Qm6dhzvVWasXUi8ybeICSiSWLwqUTaCi2JxwjNn5myfIGAJOpCKv9cdif7IWJfq4OsL1fMLZMCkCPf8H5kETq0LX4sPCP5iRqWaV(uXzXI1xLsIz0qhhXsRi5VrOm9HJSQxyaPyxeESacj7nQBilNLXcJefPyP54i2GcElCPfK55vRdk341KXDb7nanhrGG3cH(Wrw1lmGuSlcpwaHOHobyNesF4iR6fgqk2fHhlGqckLsIAssFZcJefPyP54i2GcElCPfOB0fog5qtI5iE)QB0fgi9NPpCKv9cdif7IWJfq48AOHmwuHlTa9vPKygn0XrS0ks(Beklw8hMR41cJkvwxywwR(cREd86tfNflo3waoe7XlRKZMCgScrqTrVYTfQ1y86k5uXCU2Oa0CebFha9HJSQxyaPyxeESacrowew4slWCfVwi6YyCPuU0CKviyGxFQ4m9HJSQxyaPyxeESac1kFjO2ij0WfbSWLwGUrx4yKdnjMJ49RUrxyG0FM(Wrw1lmGuSlcpwaHJkvwxywoBYPWLwqUTWOsL1fMLZMCgWSgZWH(uXIfBUIxlmQuzDHzzT6lS6nWRpvCM(Wrw1lmGuSlcpwaHqghZRjHwTrcJefPyP54i2GcElCPfmVADqKkMXqPi82Kbm7iJ(Wrw1lmGuSlcpwaHihlclCPfG6wL7rByuPY6cZYztodyM0Rf(jrCC5tfhqowewIY4NwdI(Wrw1lmGuSlcpwaHqJzL0WEm9HJSQxyaPyxeESach644UxHlTaZv8AbJXKqzRL8g5rmjVwGxFQ4m9HJSQxyaPyxeESacHmoMxtcTAJegjksXsZXrSbf8w4slaZAmdh6tf)AE16GvXYwlTHSegZooanhrW3bqFmy00VMMGf5v5gttxOhX0KUX00GxVrDdzAI4YyAQX00Gtp2AmnDmCratt5lU2iA6PdJzKrtTMMSHmnn4WJuSW0eQJfLMyhnKMAe6IX8IyAQ10KnKPjhzvV0KVzAYJJ5ntts2JumnznnzdzAYrw1lnTojhOpCKv9cdif7IWJfqizVrDdz5SmwyKOiflnhhXguWB6dhzvVWasXUi8ybeI9yRXsOHlcyHrIIuS0CCeBqbVPpOpCKv9cdqtWqhh39kCPfyUIxlymMekBTK3ipIj51c86tfNPpCKv9cdqBSac1kFjO2ij0WfbSWLwGUrx4yKdnjMJ49RUrxyG0FM(Wrw1lmaTXcie7XwJLqdxeWcxAbZRwhqDJZ16gNLoe6xLfUXVi65vRdOUX5ADJZshc9RYcyM0Rf(9DGipjcLflEE16WuDXYwlnx1lmCJFnVADyQUyzRLMR6fgWmPxl877arEseklu0hdgn9RPjyrEvUX00f6rmnPBmnn41Bu3qMMiUmMMAmnn40JTgtthdxeW0u(IRnIME6Wygz0uRPjBittdo8iflmnH6yrPj2rdPPgHUymViMMAnnzdzAYrw1ln5BMM84yEZ0KK9ifttwtt2qMMCKv9stRtYb6dhzvVWa0glGqYEJ6gYYzzSWLwW8Q1bu34CTUXzPdH(vzHB8lIEE16aQBCUw34S0Hq)QSaMj9AHFFhiYtIqzXINxTomvxSS1sZv9cd34xZRwhMQlw2AP5QEHbmt61c)(oqKNeHYcf9HJSQxyaAJfqibLsjrnjPVzHrIIuS0CCeBqbVfU0c0n6chJCOjXCeVF1n6cdK(Z0hoYQEHbOnwaHqJzL0WESWLwGUrx4yKdnjMJ49RUrxyG0FM(Wrw1lmaTXciCuPY6cZYztofU0c0n6chJCOjXCeVF1n6cdK(ZV(Wkeb1g96J5vRdKmzJfv2AP6IQSmJzNegUXViA9vPKygn0XrS0ks(77arEseklw8h52cJkvwxywoBYzWkeb1g96J5vRdOUX5ADJZshc9RYc3yXI)i3wyuPY6cZYztodwHiO2OxZRwhi7nQBil1xSObO5ic((wOel2kswATmx833eLxFKBlmQuzDHz5SjNbRqeuBe9HJSQxyaAJfqiKXX8AsOvBKWLwW8Q1brQygdLIWBtgUXVYTfGmoMxtcTAJcyM0Rf(DGFseklwCUTaKXX8AsOvBuaZAmdh6tf)6J5vRdOUX5ADJZshc9RYc3y6dhzvVWa0glGqxsEXzglBTeH7rqHlTGpMxToG6gNR1nolDi0VklCJPpCKv9cdqBSacrDJZ16gNLoe6xLjCPf8X8Q1bu34CTUXzPdH(vzHBm9HJSQxyaAJfqizVrDdz5Smw4slyE16azVrDdzP(IfnCJflw3OlCmYHMeZr8(jDJUWaP)8aniH8YCfVwqKkMXqPi82KbE9PIZIfRB0fog5qtI5iE)KUrxyG0FEGE)YCfVwWymju2AjVrEetYRf41Nkolw88Q1bu34CTUXzPdH(vzHBm9HJSQxyaAJfqi2JTglHgUiGPpCKv9cdqBSachvQSUWSC2KtHlTGCBHrLkRlmlNn5mGznMHd9PIPpCKv9cdqBSacHmoMxtcTAJeU0cMxToisfZyOueEBYWnM(G(Wrw1lmmsxcg644UxHlTaDJUWXihAsmhX7xDJUWaP)8lZv8AbJXKqzRL8g5rmjVwGxFQ4m9HJSQxyyKUglGqYEJ6gYYzzSWLwW8Q1HP6ILTwAUQxy4g)AE16WuDXYwlnx1lmGzsVw43iuM(Wrw1lmmsxJfqi2JTglHgUiGfU0cMxTomvxSS1sZv9cd34xZRwhMQlw2AP5QEHbmt61c)gHY0hoYQEHHr6ASacHmoMxtcTAJeU0cMxToisfZyOueEBYWn(18Q1brQygdLIWBtgWmPxl877arEseklw8h52cqghZRjHwTrbRqeuBe9HJSQxyyKUglGWrLkRlmlNn5u4slqFvkjMrdDCelTIK)(oqKNeHYV0n6chJCOjXCeVF1n6cdK(ZIft0l)SjhvYztodI0k3kf)k3waY4yEnj0QnkyfIGAJELBlazCmVMeA1gfWSgZWH(uXIfV8ZMCujNn5mepKXnzV8RpMxToq2Bu3qwQVyrd34x6gDHJro0KyoI3V6gDHbs)5bYrw1BGGsPKOMK03Ca5qtI5iEFYaek6dhzvVWWiDnwaHeukLe1KK(MfU0c0n6chJCOjXCeVF1n6cdK(ZdKUrxyaZr8sF4iR6fggPRXci0LKxCMXYwlr4EeK(Wrw1lmmsxJfqi0ywjnShlCPfOB0fog5qtI5iE)QB0fgi9NPpCKv9cdJ01ybeoQuzDHz5SjNcxAb6RsjXmAOJJyPvK833bI8KiuM(Wrw1lmmsxJfqiQBCUw34S0Hq)Qm6dhzvVWWiDnwaHqghZRjHwTrcxAbZRwhePIzmukcVnz4g)k3waY4yEnj0QnkGzsVw43b(jrOm9HJSQxyyKUglGqYEJ6gYYzzSWLwqUTaCi2JxwjNn5myfIGAJelEE16azVrDdzP(IfnanhrGaIqF4iR6fggPRXciCuPY6cZYztofU0cw(ztoQKZMCgGdXE8YQx52cqghZRjHwTrbmt61c)erEsektF4iR6fggPRXcieY4yEnj0Qns4slaZAmdh6tftF4iR6fggPRXcien0ja7KqHlTGpMxToq2Bu3qwQVyrdyM0RfsF4iR6fggPRXciKS3OUHSCwgtF4iR6fggPRXcie7XwJLqdxeW0hoYQEHHr6ASacHmoMxtcTAJeU0cMxToisfZyOueEBYWnM(Wrw1lmmsxJfq4OsL1fMLZMCkCPfS8ZMCujNn5misRCRu8RCBbiJJ51KqR2OGvicQnsS4LF2KJk5SjNH4HmUj7LflE5Nn5OsoBYzaoe7XlRagWaaa]] )


end