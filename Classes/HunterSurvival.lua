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


    spec:RegisterPack( "Survival", 20190803, [[dCuDKbqicKhriQlbufXMauFcOksJIqHtrOOvrOYRKKMfb1Tiq1Ue8lG0Wiu1XakldGQNrimnakUgqLTrOuFdOknocu6CauADeOO5ra3dH2hqvDqcL0crGhcufCrcuOrcufQtsGcSsjvZKaf0njuI2jqmuGQOAPavr5PkAQaYEv1FjAWsCyklwLEmKjRWLrTzs9zHmAaCArRMqj8Ae0Sj52iA3k9BPgUqDCGQqwouph00P66Qy7eKVlPmEaY5jKwpHiZxsSFK(b7b6NdZ5heax8GbyfVGv8Iia4GjcWlGlIF6IgZ)m2qeAr8pxJK)58GfkfYu)m2ev124b6NW(Gr8pbW9yOGjOGgLoaNBa1KGctYJY8Sxe20oOWKeb6pVNu5cgS)9NdZ5heax8GbyfVGv8Iia4GjcWlya2FAhhGg)ZzsEuMN9cEaBA)NaKJbV)9NdgI(PitlZdwOuitrlGhFwNX06ImTaG7XqbtqbnkDao3aQjbfMKhL5zViSPDqHjjcuADrMweRNOd0PfrimTa4IhmalTi40cGvWeCInToTUitlGhaW2igkysRlY0IGtlI1XGh0Iy5rKejftlEtldwBhLtlgYZEPfvc9aTUitlcoTaEaaBJ4bT4goIDzQPfgqXygcZEH0I30csuKILUHJyhgO1fzArWPfXYEK6Kh0cYWcXs0atlEtl1AmH0czJzAHnyQeLwQLoa0Idatl2y0l4PqAjjJvmjVU5zV0sRPfHmCAxfhO1fzArWPfX6yWdA54PkDrPfXk45cgg(PkHo8b6Nwm0FGEqa7b6N8AxfpEc(jcNoJt7N3JwhqDJh5AopKgeAhLhoX0cW0Iyql3JwhqDJh5AopKgeAhLhWmPLlKweGwalaoArC0seAqlvQql3JwhUQdw2APBQEHHtmTamTCpAD4QoyzRLUP6fgWmPLlKweGwalaoArC0seAqlI5pnKN9(tYEJ6gYYB687pia(d0p51UkE8e8teoDgN2pVhToG6gpY1CEini0okpCIPfGPfXGwUhToG6gpY1CEini0okpGzslxiTiaTawaC0I4OLi0GwQuHwUhToCvhSS1s3u9cdNyAbyA5E06WvDWYwlDt1lmGzslxiTiaTawaC0I4OLi0GweZFAip79Nyl2BSe64Kq(9her8a9tETRIhpb)eHtNXP9tDJoqAPkTGmOlXCeV0Ia0IUrhyG0a0pnKN9(tTYwcZnscDCsi)(dcG5b6N8AxfpEc(jcNoJt7N6JsjXmcadhXspjzAraAbSa4OfXrlrObTamTOB0bslvPfKbDjMJ4LweGw0n6adKgGOfbNwat8)0qE27pjmvkjQjjTD8(dc4EG(jV2vXJNGFIWPZ40(PUrhiTuLwqg0LyoIxAraAr3OdmqAa6NgYZE)j0zwjDSf)(dIy)a9tETRIhpb)eHtNXP9tDJoqAPkTGmOlXCeV0Ia0IUrhyG0aeTamTiiAXteH5grlatlcIwUhToqYKnwuzRLQdkhYbMnsy4etlatlIbTOpkLeZiamCel9KKPfbOfWcGJwehTeHg0sLk0IGOLr7HAPAOtmlVn5n4jIWCJOfGPfbrl3JwhqDJh5AopKgeAhLhoX0Iy(td5zV)SwQg6eZYBtEF)bb8(a9tETRIhpb)eHtNXP9tbrlJ2dqghZRlHEUrbpreMBeTamTiiA5E06aQB8ixZ5H0Gq7O8Wj(NgYZE)jKXX86sONB07pic2hOFYRDv84j4NiC6moTFQB0bslvPfKbDjMJ4LweGw0n6adKgGOfGPfXGwUhToq2Bu3qwQpyrdq3qeslcqlGJwQuHw0n6aPfbOfd5zVbYEJ6gYYB6Ca1qNweZFAip79NeMkLe1KK2oE)bbW(a9tETRIhpb)eHtNXP9tmRXmea7QyAbyArq0Y9O1bu34rUMZdPbH2r5HtmTamTCpADGS3OUHSuFWIgGUHiKweGwa3pnKN9(tiJJ51Lqp3O3Fqat8pq)Kx7Q4XtWpr40zCA)uq0Y9O1bu34rUMZdPbH2r5Ht8pnKN9(ttsEWdglBTeH7AW3FqadShOFAip79NOUXJCnNhsdcTJY)jV2vXJNG3FqadWFG(jV2vXJNGFIWPZ40(59O1bYEJ6gYs9blA4etlvQql6gDG0svAbzqxI5iEPfWNw0n6adKgGOfbNwat80sLk0Y9O1bu34rUMZdPbH2r5Ht8pnKN9(tYEJ6gYYB687piGjIhOFAip79Nyl2BSe64Kq(N8AxfpEcE)bbmaZd0p51UkE8e8teoDgN2pfeT4jIWCJ(PH8S3FwlvdDIz5TjVV)(prk2eIFGEqa7b6N8AxfpEc(zh)ti7P(NgYZE)PqgoTRI)PqgwUgj)tKHfILOb(NiC6moTFAipfIL8YKjdPfbOfW9tHm1HLScY)eC)uitD4FAipfIL8YKjdF)bbWFG(PH8S3FAsYdEWyzRLiCxd(tETRIhpbV)GiIhOFAip79NOUXJCnNhsdcTJY)jV2vXJNG3Fqampq)Kx7Q4XtWpr40zCA)C0Eaca2IxwjVn5n4jIWCJ(PH8S3FImSq87piG7b6N8AxfpEc(jcNoJt7NcIwCtXRhIomgNkLjDd5jcg41UkEqlvQql6JsjXmcadhXspjzAraAjcn(PH8S3FwlvdDIz5TjVV)Gi2pq)Kx7Q4XtWpnKN9(tYEJ6gYYB68pr40zCA)CW3JwhuMZRlJ7e2Ba6gIqAHiTaM4)jsuKILUHJyh(Ga27piG3hOFAip79NiamcXgj8N8AxfpEcE)brW(a9tETRIhpb)0qE27pjmvkjQjjTD8teoDgN2p1n6aPLQ0cYGUeZr8slcql6gDGbsdq)ejksXs3WrSdFqa79hea7d0p51UkE8e8teoDgN2p1hLsIzeagoILEsY0Ia0seAqlvQqlcIwCtXRhQLQHoXSmx9bM9g41UkEqlvQqlJ2dqaWw8Yk5TjVbpreMBeTamTmApKRZ41uYRI5rUrbOBicPfbOfr8td5zV)8ECeamw03Fqat8pq)Kx7Q4XtWpr40zCA)0nfVEi6WyCQuM0nKNiyGx7Q4XpnKN9(tKHfIF)bbmWEG(jV2vXJNGFIWPZ40(PUrhiTuLwqg0LyoIxAraAr3OdmqAa6NgYZE)PwzlH5gjHoojKF)bbma)b6N8AxfpEc(jcNoJt7NJ2d1s1qNywEBYBaZAmdbWUkMwQuHwCtXRhQLQHoXSmx9bM9g41UkE8td5zV)SwQg6eZYBtEF)bbmr8a9tETRIhpb)0qE27pHmoMxxc9CJ(jcNoJt7N3JwhekJzmukeVnzaZgY)jsuKILUHJyh(Ga27piGbyEG(jV2vXJNGFIWPZ40(jQB1ORTHAPAOtmlVn5nGzslxiTa(0IqgoTRIdidlelrdmTaEcTa4)0qE27prgwi(9heWa3d0pnKN9(tOZSs6yl(N8AxfpEcE)bbmX(b6N8AxfpEc(jcNoJt7NUP41doJjHYwl5nYIysE9aV2vXJFAip79Nay44U33Fqad8(a9tETRIhpb)0qE27pHmoMxxc9CJ(jcNoJt7NywJzia2vX0cW0Y9O1bpJLTw6aWsymB4a0neH0Ia0Ii(jsuKILUHJyh(Ga27piGjyFG(jV2vXJNGFAip79NK9g1nKL305FIefPyPB4i2HpiG9(dcya2hOFYRDv84j4NgYZE)j2I9glHoojK)jsuKILUHJyh(Ga27V)tO)a9Ga2d0p51UkE8e8teoDgN2pDtXRhCgtcLTwYBKfXK86bETRIh)0qE27pbWWXDVV)Ga4pq)Kx7Q4XtWpr40zCA)u3OdKwQslid6smhXlTiaTOB0bgina9td5zV)uRSLWCJKqhNeYV)GiIhOFYRDv84j4NiC6moTFEpADa1nEKR58qAqODuE4etlatlIbTCpADa1nEKR58qAqODuEaZKwUqAraAbSa4OfXrlrObTuPcTCpAD4QoyzRLUP6fgoX0cW0Y9O1HR6GLTw6MQxyaZKwUqAraAbSa4OfXrlrObTiM)0qE27pXwS3yj0XjH87piaMhOFYRDv84j4NiC6moTFEpADa1nEKR58qAqODuE4etlatlIbTCpADa1nEKR58qAqODuEaZKwUqAraAbSa4OfXrlrObTuPcTCpAD4QoyzRLUP6fgoX0cW0Y9O1HR6GLTw6MQxyaZKwUqAraAbSa4OfXrlrObTiM)0qE27pj7nQBilVPZV)GaUhOFYRDv84j4NiC6moTFQB0bslvPfKbDjMJ4LweGw0n6adKgG(PH8S3FsyQusutsA749heX(b6N8AxfpEc(jcNoJt7N6gDG0svAbzqxI5iEPfbOfDJoWaPbOFAip79NqNzL0Xw87piG3hOFYRDv84j4NiC6moTFQB0bslvPfKbDjMJ4LweGw0n6adKgGOfGPfbrlEIim3iAbyArq0Y9O1bsMSXIkBTuDq5qoWSrcdNyAbyArmOf9rPKygbGHJyPNKmTiaTawaC0I4OLi0GwQuHweeTmApulvdDIz5TjVbpreMBeTamTiiA5E06aQB8ixZ5H0Gq7O8WjMweZFAip79N1s1qNywEBY77pic2hOFYRDv84j4NiC6moTFEpADGS3OUHSuFWIgGUHiKwaFAbC0cW0IGOfu3QrxBdOUXJCnNhsdcTJYdyM0Yf(td5zV)KS3OUHS8Mo)(dcG9b6N8AxfpEc(jcNoJt7N3JwhekJzmukeVnz4etlatlJ2dqghZRlHEUrbmtA5cPfbOfadTioAjcnOLkvOLr7biJJ51Lqp3OaM1ygcGDvmTamTiiA5E06aQB8ixZ5H0Gq7O8Wj(NgYZE)jKXX86sONB07piGj(hOFYRDv84j4NiC6moTFkiA5E06aQB8ixZ5H0Gq7O8Wj(NgYZE)Pjjp4bJLTwIWDn47piGb2d0pnKN9(tu34rUMZdPbH2r5)Kx7Q4XtW7piGb4pq)Kx7Q4XtWpr40zCA)8E06azVrDdzP(GfnCIPLkvOfDJoqAPkTGmOlXCeV0c4tl6gDGbsdq0IGtlaU4PfGPf3u86bHYygdLcXBtg41UkEqlvQql6gDG0svAbzqxI5iEPfWNw0n6adKgGOfbNwaJwaMwCtXRhCgtcLTwYBKfXK86bETRIh0sLk0Y9O1bu34rUMZdPbH2r5Ht8pnKN9(tYEJ6gYYB687piGjIhOFAip79Nyl2BSe64Kq(N8AxfpEcE)bbmaZd0p51UkE8e8teoDgN2phThQLQHoXS82K3aM1ygcGDv8pnKN9(ZAPAOtmlVn599heWa3d0p51UkE8e8teoDgN2pVhToiugZyOuiEBYWj(NgYZE)jKXX86sONB07V)ZA68b6bbShOFYRDv84j4NiC6moTFQB0bslvPfKbDjMJ4LweGw0n6adKgGOfGPf3u86bNXKqzRL8gzrmjVEGx7Q4XpnKN9(tamCC377pia(d0p51UkE8e8teoDgN2pVhToCvhSS1s3u9cdNyAbyA5E06WvDWYwlDt1lmGzslxiTiaTeHg)0qE27pj7nQBilVPZV)GiIhOFYRDv84j4NiC6moTFEpAD4QoyzRLUP6fgoX0cW0Y9O1HR6GLTw6MQxyaZKwUqAraAjcn(PH8S3FITyVXsOJtc53Fqampq)Kx7Q4XtWpr40zCA)8E06GqzmJHsH4TjdNyAbyA5E06GqzmJHsH4TjdyM0YfslcqlGfahTioAjcnOLkvOfbrlJ2dqghZRlHEUrbpreMB0pnKN9(tiJJ51Lqp3O3Fqa3d0p51UkE8e8teoDgN2p1hLsIzeagoILEsY0Ia0cybWrlIJwIqdAbyAr3OdKwQslid6smhXlTiaTOB0bginarlvQqlIbTSmGCzTuEBYBqOwzEQyAbyAz0EaY4yEDj0Znk4jIWCJOfGPLr7biJJ51Lqp3OaM1ygcGDvmTuPcTSmGCzTuEBYBigag3K9Y0cW0IGOL7rRdK9g1nKL6dw0WjMwaMw0n6aPLQ0cYGUeZr8slcql6gDGbsdq0IGtlgYZEdeMkLe1KK2ocid6smhXlTioAre0Iy(td5zV)SwQg6eZYBtEF)brSFG(jV2vXJNGFIWPZ40(PUrhiTuLwqg0LyoIxAraAr3OdmqAaIweCAr3OdmG5iE)PH8S3FsyQusutsA749heW7d0pnKN9(ttsEWdglBTeH7AWFYRDv84j49heb7d0p51UkE8e8teoDgN2p1n6aPLQ0cYGUeZr8slcql6gDGbsdq)0qE27pHoZkPJT43FqaSpq)Kx7Q4XtWpr40zCA)uFukjMray4iw6jjtlcqlGfahTioAjcn(PH8S3FwlvdDIz5TjVV)GaM4FG(PH8S3FI6gpY1CEini0ok)N8AxfpEcE)bbmWEG(jV2vXJNGFIWPZ40(59O1bHYygdLcXBtgoX0cW0YO9aKXX86sONBuaZKwUqAraAbWqlIJwIqJFAip79NqghZRlHEUrV)GagG)a9tETRIhpb)eHtNXP9Zr7biaylEzL82K3GNicZnIwQuHwUhToq2Bu3qwQpyrdq3qeslePfW9td5zV)KS3OUHS8Mo)(dcyI4b6N8AxfpEc(jcNoJt7NldixwlL3M8gGaGT4Lv0cW0YO9aKXX86sONBuaZKwUqAb8PfWrlIJwIqJFAip79N1s1qNywEBY77piGbyEG(jV2vXJNGFIWPZ40(jM1ygcGDv8pnKN9(tiJJ51Lqp3O3FqadCpq)Kx7Q4XtWpr40zCA)uq0Y9O1bYEJ6gYs9blAaZKwUWFAip79NiamcXgj89heWe7hOFAip79NK9g1nKL305FYRDv84j49heWaVpq)0qE27pXwS3yj0XjH8p51UkE8e8(dcyc2hOFYRDv84j4NiC6moTFEpADqOmMXqPq82KHt8pnKN9(tiJJ51Lqp3O3FqadW(a9tETRIhpb)eHtNXP9ZLbKlRLYBtEdc1kZtftlatlJ2dqghZRlHEUrbpreMBeTuPcTSmGCzTuEBYBigag3K9Y0sLk0YYaYL1s5TjVbiaylEz1pnKN9(ZAPAOtmlVn5993)PfxtNpqpiG9a9tETRIhpb)eHtNXP9Z7rRdx1blBT0nvVWWjMwaMwUhToCvhSS1s3u9cdyM0YfslcqlrOXpnKN9(tYEJ6gYYB687pia(d0p51UkE8e8teoDgN2pVhToCvhSS1s3u9cdNyAbyA5E06WvDWYwlDt1lmGzslxiTiaTeHg)0qE27pXwS3yj0XjH87piI4b6N8AxfpEc(jcNoJt7NcIwgThGmoMxxc9CJcEIim3OFAip79NqghZRlHEUrV)GayEG(PH8S3FAsYdEWyzRLiCxd(tETRIhpbV)GaUhOFYRDv84j4NiC6moTFQpkLeZiamCel9KKPfbOfWcGJwehTeHg0sLk0IUrhiTuLwqg0LyoIxAraAr3OdmqAaIwaMwedAzza5YAP82K3GqTY8uX0cW0YO9aKXX86sONBuWteH5grlatlJ2dqghZRlHEUrbmRXmea7QyAPsfAzza5YAP82K3qmamUj7LPfGPfbrl3Jwhi7nQBil1hSOHtmTamTOB0bslvPfKbDjMJ4LweGw0n6adKgGOfbNwmKN9gimvkjQjjTDeqg0LyoIxArC0IiOfX8NgYZE)zTun0jML3M8((dIy)a9td5zV)e1nEKR58qAqODu(p51UkE8e8(dc49b6N8AxfpEc(jcNoJt7N3Jwhi7nQBil1hSObmtA5cPfGPLLbKlRLYBtEdXaW4MSx(NgYZE)jzVrDdz5nD(9heb7d0p51UkE8e8teoDgN2p1hLsIzeagoILEsY0Ia0cybWrlIJwIqdAbyAr3OdKwQslid6smhXlTiaTOB0bginarlcoTa4I)NgYZE)jHPsjrnjPTJ3FqaSpq)Kx7Q4XtWpr40zCA)u3OdKwQslid6smhXlTiaTOB0bgina9td5zV)e6mRKo2IF)bbmX)a9tETRIhpb)eHtNXP9Z7rRdEglBT0bGLWy2WbOBicPfI0IiOLkvOLr7biaylEzL82K3GNicZn6NgYZE)j2I9glHoojKF)bbmWEG(jV2vXJNGFIWPZ40(5O9aeaSfVSsEBYBWteH5g9td5zV)KS3OUHS8Mo)(dcya(d0p51UkE8e8teoDgN2pxgqUSwkVn5nabaBXlROfGPfDJoqAb8PfriEAbyAz0EaY4yEDj0ZnkGzslxiTa(0c4OfXrlrOXpnKN9(ZAPAOtmlVn599heWeXd0p51UkE8e8teoDgN2pfeTCpADGS3OUHSuFWIgWmPLl8NgYZE)jcaJqSrcF)bbmaZd0p51UkE8e8teoDgN2pXSgZqaSRI)PH8S3FczCmVUe65g9(dcyG7b6N8AxfpEc(jcNoJt7N6gDG0svAbzqxI5iEPfbOfDJoWaPbiAbyArmOL7rRdK9g1nKL6dw0a0neH0Ia0c4OLkvOfDJoqAraAXqE2BGS3OUHS8Mohqn0PfX8NgYZE)jHPsjrnjPTJ3FqatSFG(PH8S3FITyVXsOJtc5FYRDv84j49heWaVpq)Kx7Q4XtWpr40zCA)8E06azVrDdzP(GfnCIPLkvOfDJoqAb8PfaJ4PLkvOLr7biaylEzL82K3GNicZn6NgYZE)jzVrDdz5nD(9heWeSpq)Kx7Q4XtWpr40zCA)Cza5YAP82K3GqTY8uX0cW0YO9aKXX86sONBuWteH5grlvQqlldixwlL3M8gIbGXnzVmTuPcTSmGCzTuEBYBaca2Ixwrlatl6gDG0c4tlGt8)0qE27pRLQHoXS82K33F)NXyg1KxZFGEqa7b6NgYZE)j8qs2RmM9FYRDv84j49hea)b6NgYZE)zC7zV)Kx7Q4XtW7piI4b6N8AxfpEc(5AK8pnrccGHnOu3RlBTmURX4FAip79NMibbWWguQ71LTwg31y87piaMhOFYRDv84j4NgYZE)jsuKQDCVjsEvg0)jcNoJt7NcIwWwoKSq86HCf6OwgBxfhyaLqh(twRzKlxJK)jsuKQDCVjsEvg0F)bbCpq)0qE27pJogEK2kBT0ejg3oa)Kx7Q4XtW7piI9d0pnKN9(tOZSs6yl(N8AxfpEcE)bb8(a9td5zV)eadh39(tETRIhpbV)(prd4d0dcypq)Kx7Q4XtWpr40zCA)e1TA012aQB8ixZ5H0Gq7O8aMjTCH0c4tlIq8)0qE27pVQUhs9bl67pia(d0p51UkE8e8teoDgN2prDRgDTnG6gpY1CEini0okpGzslxiTa(0Iie)pnKN9(tBrm0XMsImL69her8a9tETRIhpb)eHtNXP9tu3QrxBdOUXJCnNhsdcTJYdyM0YfslGpTicX)td5zV)uNy(Q6E8(dcG5b6NgYZE)PkJaWHsXIZiIKx)N8AxfpEcE)bbCpq)Kx7Q4XtWpr40zCA)e1TA012aQB8ixZ5H0Gq7O8aMjTCH0c4tlIT4PLkvOfpjzP3YrY0Ia0cyI4NgYZE)5LXqgtyUrV)Gi2pq)Kx7Q4XtWpr40zCA)8E06aQB8ixZ5H0Gq7O8WjMwaMwedA5E06WLXqgtyUrHtmTuPcTCpAD4Q6Ei1hSOHtmTuPcTiiAbBio44wPOfGPfbrlydXHgJOfXKwQuHwedAb1l8qAxfhIBp7v2A5zV4CO4HuFWIslatlEsYsVLJKPfbOfXgmAPsfAXtsw6TCKmTiaTa4InTiM)0qE27pJBp799heW7d0p51UkE8e8teoDgN2pDdhXEyKq3wetlGprArS)PH8S3FAWyg5YwlDayjBrk(9heb7d0p51UkE8e8td5zV)0GaiKTmuInrQXsuJn1pr40zCA)8E06ajt2yrLTwQoOCihy2iHHtmTuPcTCpADi6y4rARS1stKyC7aeoX0sLk0YGVhToGnrQXsuJnLCW3JwhgDTLwQuHw8KKLElhjtlcqlaU4)5AK8pniaczldLytKASe1yt9(dcG9b6N8AxfpEc(PH8S3FgzkgzkfJHYB37pr40zCA)e1TA012ajt2yrLTwQoOCihy2iHbmtA5cPLkvOf3u86HAPAOtmlZvFGzVbETRIh0cW0cQB1ORTbu34rUMZdPbH2r5bmtA5cPLkvOfu3QrxBdirrQ2X9Mi5vzqpGzslxiTuPcTiiAHHqErCGKjBSOYwlvhuoKdmBKWaPjw0yAbyAb1TA012aQB8ixZ5H0Gq7O8aMjTCH)Cns(NrMIrMsXyO829((dcyI)b6N8AxfpEc(5AK8pnrccGHnOu3RlBTmURX4FAip79NMibbWWguQ71LTwg31y87piGb2d0pnKN9(tDJoqEinrIXPZYlBK)Kx7Q4XtW7piGb4pq)Kx7Q4XtWpr40zCA)u3OdKweGw0n6adKgGOfbNweH4PfGPL7rRdOUXJCnNhsdcTJYdN4FAip79NKmzJfv2AP6GYHCGzJe((dcyI4b6N8AxfpEc(jcNoJt7N3JwhqDJh5AopKgeAhLhoX)0qE27pVQUhYwlDayjVmPOV)GagG5b6NgYZE)z8bNArZnsEvg0)jV2vXJNG3FqadCpq)0qE27pJogEK2kBT0ejg3oa)Kx7Q4XtW7piGj2pq)0qE27pXzCSIL5kHXgI)jV2vXJNG3Fqad8(a9tETRIhpb)eHtNXP9t9rPKygbGHJyPNKmTiaTagTioAjcn(PH8S3FI6fXRJnNhsTYi53FqatW(a9tETRIhpb)eHtNXP9Z7rRdygrOIHqPUXioCI)PH8S3F6aWYZE7ZoK6gJ43FqadW(a9td5zV)SwJvdH4CLyg2RTi(N8AxfpEcE)9FoyTDu(d0dcypq)Kx7Q4XtWpr40zCA)CW3Jwhqg0ZnkCIPLkvOLbFpADyKWywPSRILKwuIcNyAPsfAzW3JwhgjmMvk7QyjVylIdN4FAip79NitPKgYZELQe6)uLqxUgj)ZJNQ0f99hea)b6NgYZE)5bYY0zs4p51UkE8e8(dIiEG(jV2vXJNGFAip79NitPKgYZELQe6)uLqxUgj)t0a((dcG5b6N8AxfpEc(jcNoJt7NgYtHyjVmzYqAraAre0cW0IBkE9acaJqSrcd8AxfpOfGPf3u86btfdGjJX8W8gh41UkE8td5zV)ezkL0qE2RuLq)NQe6Y1i5FAX1057piG7b6N8AxfpEc(jcNoJt7NgYtHyjVmzYqAraAre0cW0IBkE9acaJqSrcd8Axfp(PH8S3FImLsAip7vQsO)tvcD5AK8pRPZ3Fqe7hOFYRDv84j4NiC6moTFAipfIL8YKjdPfbOfrqlatlcIwCtXRhmvmaMmgZdZBCGx7Q4bTamTiiAXnfVEOwQg6eZYC1hy2BGx7Q4XpnKN9(tKPusd5zVsvc9FQsOlxJK)j0F)bb8(a9tETRIhpb)eHtNXP9td5PqSKxMmziTiaTicAbyAXnfVEWuXayYympmVXbETRIh0cW0IGOf3u86HAPAOtmlZvFGzVbETRIh)0qE27prMsjnKN9kvj0)PkHUCns(Nwm0F)brW(a9tETRIhpb)eHtNXP9td5PqSKxMmziTiaTicAbyAXnfVEWuXayYympmVXbETRIh0cW0IBkE9qTun0jML5QpWS3aV2vXJFAip79NitPKgYZELQe6)uLqxUgj)tlUMoF)bbW(a9tETRIhpb)eHtNXP9td5PqSKxMmziTiaTicAbyArq0IBkE9GPIbWKXyEyEJd8AxfpOfGPf3u86HAPAOtmlZvFGzVbETRIh)0qE27prMsjnKN9kvj0)PkHUCns(N1057piGj(hOFYRDv84j4NiC6moTFAipfIL8YKjdPfWNwa7NgYZE)jYukPH8SxPkH(pvj0LRrY)ePyti(9heWa7b6NgYZE)jQxeVo2CEi1kJK)jV2vXJNG3FqadWFG(PH8S3FAyKTS0BmMx)N8AxfpEcE)9FE8uLUOpqpiG9a9td5zV)K8isIKI)jV2vXJNG3Fqa8hOFAip79NqgZB6IkhhO)tETRIhpbV)GiIhOFAip79NW4gZsKQpJFYRDv84j49heaZd0pnKN9(ty3oa5gjRzoJ)jV2vXJNG3Fqa3d0pnKN9(tyVjsEvg0)jV2vXJNG3Fqe7hOFAip79Nl7aWyjeGgr4p51UkE8e8(dc49b6NgYZE)jcGuSiHshBl4rNuLUO)Kx7Q4XtW7pic2hOFAip79NW4eNUecqJi8N8AxfpEcE)bbW(a9td5zV)Cn)GzOmcBi(N8AxfpEcE)93)PqmgM9(Ga4IhmaR4bVaUG9N1m8MBe8Ncgqg3yNh0cGLwmKN9slQe6WaT(pHXm6bbWbh4(zmU1PI)PitlZdwOuitrlGhFwNX06ImTaG7XqbtqbnkDao3aQjbfMKhL5zViSPDqHjjcuADrMweRNOd0PfrimTa4IhmalTi40cGvWeCInToTUitlGhaW2igkysRlY0IGtlI1XGh0Iy5rKejftlEtldwBhLtlgYZEPfvc9aTUitlcoTaEaaBJ4bT4goIDzQPfgqXygcZEH0I30csuKILUHJyhgO1fzArWPfXYEK6Kh0cYWcXs0atlEtl1AmH0czJzAHnyQeLwQLoa0Idatl2y0l4PqAjjJvmjVU5zV0sRPfHmCAxfhO1fzArWPfX6yWdA54PkDrPfXk45cggO1P1fzArWiGy0X5bTCzDJzAb1KxZPLlhLlmqlIveIJDiTS9k4ayys9rrlgYZEH0sVkrd06ImTyip7fgIXmQjVMtuRmiH06ImTyip7fgIXmQjVMxLiO2jIKx38SxADrMwmKN9cdXyg1KxZRseuD3dADd5zVWqmMrn518QebfEij7vgZoTUitlZ1IHa0oTGTCql3JwZdAb6MdPLlRBmtlOM8AoTC5OCH0ITdAjgZcEC7EUr0scPLrVCGwxKPfd5zVWqmMrn518QebfUwmeG2Lq3CiTUH8SxyigZOM8AEvIGg3E2lTUH8SxyigZOM8AEvIGEGSmDMu41izIMibbWWguQ71LTwg31ymTUH8SxyigZOM8AEvIGEGSmDMuywRzKlxJKjIefPAh3BIKxLbDHtnrbHTCizH41d5k0rTm2UkoWakHoKw3qE2lmeJzutEnVkrqJogEK2kBT0ejg3oa06gYZEHHymJAYR5vjck0zwjDSftRBip7fgIXmQjVMxLiOay44UxADADd5zVWWXtv6IsK8isIKIP1nKN9cdhpvPlAvIGczmVPlQCCGoTUH8Sxy44PkDrRseuyCJzjs1NbTUH8Sxy44PkDrRseuy3oa5gjRzoJP1nKN9cdhpvPlAvIGc7nrYRYGoTUH8Sxy44PkDrRse0LDaySecqJiKw3qE2lmC8uLUOvjckcGuSiHshBl4rNuLUO06gYZEHHJNQ0fTkrqHXjoDjeGgriTUH8Sxy44PkDrRse018dMHYiSHyADADrMwemcigDCEqlSqmwuAXtsMwCayAXqEJPLeslMqwQSRId06gYZEHerMsjnKN9kvj0fEnsM4Xtv6IkCQjo47rRdid65gfoXvQm47rRdJegZkLDvSK0Isu4exPYGVhTomsymRu2vXsEXwehoX06gYZEHvjc6bYY0zsiTUH8SxyvIGImLsAip7vQsOl8AKmr0asRBip7fwLiOitPKgYZELQe6cVgjt0IRPtHtnrd5PqSKxMmzOaIay3u86beagHyJeg41UkEaSBkE9GPIbWKXyEyEJd8AxfpO1nKN9cRseuKPusd5zVsvcDHxJKjwtNcNAIgYtHyjVmzYqbebWUP41diamcXgjmWRDv8Gw3qE2lSkrqrMsjnKN9kvj0fEnsMi0fo1enKNcXsEzYKHcicGfKBkE9GPIbWKXyEyEJd8AxfpawqUP41d1s1qNywMR(aZEd8AxfpO1nKN9cRseuKPusd5zVsvcDHxJKjAXqx4ut0qEkel5LjtgkGia2nfVEWuXayYympmVXbETRIhali3u86HAPAOtmlZvFGzVbETRIh06gYZEHvjckYukPH8SxPkHUWRrYeT4A6u4ut0qEkel5LjtgkGia2nfVEWuXayYympmVXbETRIha7MIxpulvdDIzzU6dm7nWRDv8Gw3qE2lSkrqrMsjnKN9kvj0fEnsMynDkCQjAipfIL8YKjdfqeali3u86btfdGjJX8W8gh41UkEaSBkE9qTun0jML5QpWS3aV2vXdADd5zVWQebfzkL0qE2RuLqx41izIifBcXcNAIgYtHyjVmzYqWhmADd5zVWQebf1lIxhBopKALrY06gYZEHvjcQHr2YsVXyEDADADd5zVWGfdDIK9g1nKL30zHtnX7rRdOUXJCnNhsdcTJYdNyGfJ7rRdOUXJCnNhsdcTJYdyM0YfkaybWjUi0OsL7rRdx1blBT0nvVWWjg47rRdx1blBT0nvVWaMjTCHcawaCIlcnetADd5zVWGfd9QebfBXEJLqhNeYcNAI3JwhqDJh5AopKgeAhLhoXalg3JwhqDJh5AopKgeAhLhWmPLluaWcGtCrOrLk3JwhUQdw2APBQEHHtmW3JwhUQdw2APBQEHbmtA5cfaSa4exeAiM06gYZEHblg6vjcQwzlH5gjHoojKfo1e1n6aRImOlXCeVcOB0bginarRBip7fgSyOxLiOeMkLe1KK2oeo1e1hLsIzeagoILEsYcawaCIlcnaw3OdSkYGUeZr8kGUrhyG0aKGdM4P1nKN9cdwm0RseuOZSs6ylw4utu3OdSkYGUeZr8kGUrhyG0aeTUH8SxyWIHEvIGwlvdDIz5TjVcNAI6gDGvrg0LyoIxb0n6adKgGawqEIim3iGf09O1bsMSXIkBTuDq5qoWSrcdNyGfd9rPKygbGHJyPNKSaGfaN4IqJkve0O9qTun0jML3M8g8eryUralO7rRdOUXJCnNhsdcTJYdNyXKw3qE2lmyXqVkrqHmoMxxc9CJeo1ef0O9aKXX86sONBuWteH5gbSGUhToG6gpY1CEini0okpCIP1nKN9cdwm0RseuctLsIAssBhcNAI6gDGvrg0LyoIxb0n6adKgGawmUhToq2Bu3qwQpyrdq3qeka4Qur3Oduad5zVbYEJ6gYYB6Ca1qxmP1nKN9cdwm0RseuiJJ51Lqp3iHtnrmRXmea7QyGf09O1bu34rUMZdPbH2r5HtmW3Jwhi7nQBil1hSObOBicfaC06gYZEHblg6vjcQjjp4bJLTwIWDnOWPMOGUhToG6gpY1CEini0okpCIP1nKN9cdwm0Rseuu34rUMZdPbH2r506gYZEHblg6vjckzVrDdz5nDw4ut8E06azVrDdzP(GfnCIRur3OdSkYGUeZr8c(6gDGbsdqcoyIVsL7rRdOUXJCnNhsdcTJYdNyADd5zVWGfd9QebfBXEJLqhNeY06gYZEHblg6vjcATun0jML3M8kCQjkipreMBeToTUH8SxyWIRPtIK9g1nKL30zHtnX7rRdx1blBT0nvVWWjg47rRdx1blBT0nvVWaMjTCHceHg06gYZEHblUMoRseuSf7nwcDCsilCQjEpAD4QoyzRLUP6fgoXaFpAD4QoyzRLUP6fgWmPLluGi0Gw3qE2lmyX10zvIGczCmVUe65gjCQjkOr7biJJ51Lqp3OGNicZnIw3qE2lmyX10zvIGAsYdEWyzRLiCxdsRBip7fgS4A6SkrqRLQHoXS82KxHtnr9rPKygbGHJyPNKSaGfaN4IqJkv0n6aRImOlXCeVcOB0bginabSySmGCzTuEBYBqOwzEQyGhThGmoMxxc9CJcEIim3iGhThGmoMxxc9CJcywJzia2vXvQSmGCzTuEBYBigag3K9YalO7rRdK9g1nKL6dw0WjgyDJoWQid6smhXRa6gDGbsdqcUH8S3aHPsjrnjPTJaYGUeZr8koriM06gYZEHblUMoRseuu34rUMZdPbH2r506gYZEHblUMoRseuYEJ6gYYB6SWPM49O1bYEJ6gYs9blAaZKwUqGxgqUSwkVn5nedaJBYEzADd5zVWGfxtNvjckHPsjrnjPTdHtnr9rPKygbGHJyPNKSaGfaN4IqdG1n6aRImOlXCeVcOB0bginaj4aU4P1nKN9cdwCnDwLiOqNzL0XwSWPMOUrhyvKbDjMJ4vaDJoWaPbiADd5zVWGfxtNvjck2I9glHoojKfo1eVhTo4zSS1shawcJzdhGUHiKOiQuz0Eaca2IxwjVn5n4jIWCJO1nKN9cdwCnDwLiOK9g1nKL30zHtnXr7biaylEzL82K3GNicZnIw3qE2lmyX10zvIGwlvdDIz5TjVcNAIldixwlL3M8gGaGT4LvaRB0bc(Iq8apApazCmVUe65gfWmPLle8bN4IqdADd5zVWGfxtNvjckcaJqSrcfo1ef09O1bYEJ6gYs9blAaZKwUqADd5zVWGfxtNvjckKXX86sONBKWPMiM1ygcGDvmTUH8SxyWIRPZQebLWuPKOMK02HWPMOUrhyvKbDjMJ4vaDJoWaPbiGfJ7rRdK9g1nKL6dw0a0neHcaUkv0n6afWqE2BGS3OUHS8Mohqn0ftADd5zVWGfxtNvjck2I9glHoojKP1nKN9cdwCnDwLiOK9g1nKL30zHtnX7rRdK9g1nKL6dw0WjUsfDJoqWhWi(kvgThGaGT4LvYBtEdEIim3iADd5zVWGfxtNvjcATun0jML3M8kCQjUmGCzTuEBYBqOwzEQyGhThGmoMxxc9CJcEIim3OkvwgqUSwkVn5nedaJBYE5kvwgqUSwkVn5nabaBXlRaw3Ode8bN4P1P1nKN9cdObK4v19qQpyrfo1erDRgDTnG6gpY1CEini0okpGzslxi4lcXtRBip7fgqdyvIGAlIHo2usKPucNAIOUvJU2gqDJh5AopKgeAhLhWmPLle8fH4P1nKN9cdObSkrq1jMVQUhcNAIOUvJU2gqDJh5AopKgeAhLhWmPLle8fH4P1nKN9cdObSkrqvzeaoukwCgrK8606gYZEHb0awLiOxgdzmH5gjCQjI6wn6ABa1nEKR58qAqODuEaZKwUqWxSfFLkEsYsVLJKfamrqRBip7fgqdyvIGg3E2RWPM49O1bu34rUMZdPbH2r5HtmWIX9O1HlJHmMWCJcN4kvUhToCvDpK6dw0WjUsfbHnehCCRualiSH4qJrIzLkIbQx4H0Ukoe3E2RS1YZEX5qXdP(GffypjzP3YrYci2GvPINKS0B5izbaCXwmP1nKN9cdObSkrqnymJCzRLoaSKTiflCQj6goI9WiHUTig8jk206gYZEHb0awLiOhiltNjfEnsMObbqiBzOeBIuJLOgBkHtnX7rRdKmzJfv2AP6GYHCGzJegoXvQCpADi6y4rARS1stKyC7aeoXvQm47rRdytKASe1ytjh89O1HrxBRuXtsw6TCKSaaU4P1nKN9cdObSkrqpqwMotk8AKmXitXitPymuE7Efo1erDRgDTnqYKnwuzRLQdkhYbMnsyaZKwUWkvCtXRhQLQHoXSmx9bM9g41UkEamQB1ORTbu34rUMZdPbH2r5bmtA5cRub1TA012asuKQDCVjsEvg0dyM0YfwPIGyiKxehizYglQS1s1bLd5aZgjmqAIfngyu3QrxBdOUXJCnNhsdcTJYdyM0YfsRBip7fgqdyvIGEGSmDMu41izIMibbWWguQ71LTwg31ymTUH8SxyanGvjcQUrhipKMiX40z5LnsADd5zVWaAaRseusMSXIkBTuDq5qoWSrcfo1e1n6afq3OdmqAasWfH4b(E06aQB8ixZ5H0Gq7O8WjMw3qE2lmGgWQeb9Q6EiBT0bGL8YKIkCQjEpADa1nEKR58qAqODuE4etRBip7fgqdyvIGgFWPw0CJKxLbDADd5zVWaAaRse0OJHhPTYwlnrIXTdaTUH8SxyanGvjckoJJvSmxjm2qmTUH8SxyanGvjckQxeVo2CEi1kJKfo1e1hLsIzeagoILEsYcaM4IqdADd5zVWaAaRseuhawE2BF2Hu3yelCQjEpADaZicvmek1ngXHtmTUH8SxyanGvjcATgRgcX5kXmSxBrmToTUH8SxyaPytiMOqgoTRIfEnsMiYWcXs0alChteYEQfwitDyIgYtHyjVmzYqHfYuhwYkiteCcJ6DKE2lrd5PqSKxMmzOaGJw3qE2lmGuSjexLiOMK8Ghmw2Ajc31G06gYZEHbKInH4Qebf1nEKR58qAqODuoTUH8SxyaPytiUkrqrgwiw4utC0Eaca2IxwjVn5n4jIWCJO1nKN9cdifBcXvjcATun0jML3M8kCQjki3u86HOdJXPszs3qEIGbETRIhvQOpkLeZiamCel9KKficnO1nKN9cdifBcXvjckzVrDdz5nDwyKOiflDdhXoKiycNAId(E06GYCEDzCNWEdq3qesemXtRBip7fgqk2eIRseueagHyJesRBip7fgqk2eIRseuctLsIAssBhcJefPyPB4i2Hebt4utu3OdSkYGUeZr8kGUrhyG0aeTUH8SxyaPytiUkrqVhhbaJfv4utuFukjMray4iw6jjlqeAuPIGCtXRhQLQHoXSmx9bM9g41UkEuPYO9aeaSfVSsEBYBWteH5gb8O9qUoJxtjVkMh5gfGUHiuarqRBip7fgqk2eIRseuKHfIfo1eDtXRhIomgNkLjDd5jcg41UkEqRBip7fgqk2eIRseuTYwcZnscDCsilCQjQB0bwfzqxI5iEfq3OdmqAaIw3qE2lmGuSjexLiO1s1qNywEBYRWPM4O9qTun0jML3M8gWSgZqaSRIRuXnfVEOwQg6eZYC1hy2BGx7Q4bTUH8SxyaPytiUkrqHmoMxxc9CJegjksXs3WrSdjcMWPM49O1bHYygdLcXBtgWSHCADd5zVWasXMqCvIGImSqSWPMiQB1ORTHAPAOtmlVn5nGzslxi4lKHt7Q4aYWcXs0adEcGtRBip7fgqk2eIRseuOZSs6ylMw3qE2lmGuSjexLiOay44UxHtnr3u86bNXKqzRL8gzrmjVEGx7Q4bTUH8SxyaPytiUkrqHmoMxxc9CJegjksXs3WrSdjcMWPMiM1ygcGDvmW3Jwh8mw2APdalHXSHdq3qekGiO1fzAbOMwGj5rzotlhOfX0IUX0IyzVrDdzAHG0zAPX0c4zwS3yAz64KqMwghCUr0IyfgZiNwAnT4aW0IGrlsXctlOowuAHnea0sJqhmMxetlTMwCayAXqE2lTy7GwS4yEh0IKTiftlEtloamTyip7LwwJKd06gYZEHbKInH4QebLS3OUHS8MolmsuKILUHJyhsemADd5zVWasXMqCvIGITyVXsOJtczHrIIuS0nCe7qIGrRtRBip7fgGoramCC3RWPMOBkE9GZysOS1sEJSiMKxpWRDv8Gw3qE2lma9QebvRSLWCJKqhNeYcNAI6gDGvrg0LyoIxb0n6adKgGO1nKN9cdqVkrqXwS3yj0XjHSWPM49O1bu34rUMZdPbH2r5HtmWIX9O1bu34rUMZdPbH2r5bmtA5cfaSa4exeAuPY9O1HR6GLTw6MQxy4ed89O1HR6GLTw6MQxyaZKwUqbalaoXfHgIjTUitla10cmjpkZzA5aTiMw0nMwel7nQBitleKotlnMwapZI9gtlthNeY0Y4GZnIweRWyg50sRPfhaMwemArkwyAb1XIslSHaGwAe6GX8IyAP10IdatlgYZEPfBh0IfhZ7GwKSfPyAXBAXbGPfd5zV0YAKCGw3qE2lma9QebLS3OUHS8MolCQjEpADa1nEKR58qAqODuE4edSyCpADa1nEKR58qAqODuEaZKwUqbalaoXfHgvQCpAD4QoyzRLUP6fgoXaFpAD4QoyzRLUP6fgWmPLluaWcGtCrOHysRBip7fgGEvIGsyQusutsA7q4utu3OdSkYGUeZr8kGUrhyG0aeTUH8Sxya6vjck0zwjDSflCQjQB0bwfzqxI5iEfq3OdmqAaIw3qE2lma9QebTwQg6eZYBtEfo1e1n6aRImOlXCeVcOB0bginabSG8eryUralO7rRdKmzJfv2AP6GYHCGzJegoXalg6JsjXmcadhXspjzbalaoXfHgvQiOr7HAPAOtmlVn5n4jIWCJawq3JwhqDJh5AopKgeAhLhoXIjTUH8Sxya6vjckzVrDdz5nDw4ut8E06azVrDdzP(GfnaDdri4doGfeQB1ORTbu34rUMZdPbH2r5bmtA5cP1nKN9cdqVkrqHmoMxxc9CJeo1eVhToiugZyOuiEBYWjg4r7biJJ51Lqp3OaMjTCHcayexeAuPYO9aKXX86sONBuaZAmdbWUkgybDpADa1nEKR58qAqODuE4etRBip7fgGEvIGAsYdEWyzRLiCxdkCQjkO7rRdOUXJCnNhsdcTJYdNyADd5zVWa0Rseuu34rUMZdPbH2r506gYZEHbOxLiOK9g1nKL30zHtnX7rRdK9g1nKL6dw0WjUsfDJoWQid6smhXl4RB0bginaj4aU4b2nfVEqOmMXqPq82KbETRIhvQOB0bwfzqxI5iEbFDJoWaPbibhmGDtXRhCgtcLTwYBKfXK86bETRIhvQCpADa1nEKR58qAqODuE4etRBip7fgGEvIGITyVXsOJtczADd5zVWa0Rse0APAOtmlVn5v4utC0EOwQg6eZYBtEdywJzia2vX06gYZEHbOxLiOqghZRlHEUrcNAI3JwhekJzmukeVnz4etRtRBip7fgQPtIay44UxHtnrDJoWQid6smhXRa6gDGbsdqa7MIxp4mMekBTK3ilIj51d8AxfpO1nKN9cd10zvIGs2Bu3qwEtNfo1eVhToCvhSS1s3u9cdNyGVhToCvhSS1s3u9cdyM0YfkqeAqRBip7fgQPZQebfBXEJLqhNeYcNAI3JwhUQdw2APBQEHHtmW3JwhUQdw2APBQEHbmtA5cficnO1nKN9cd10zvIGczCmVUe65gjCQjEpADqOmMXqPq82KHtmW3JwhekJzmukeVnzaZKwUqbalaoXfHgvQiOr7biJJ51Lqp3OGNicZnIw3qE2lmutNvjcATun0jML3M8kCQjQpkLeZiamCel9KKfaSa4exeAaSUrhyvKbDjMJ4vaDJoWaPbOkveJLbKlRLYBtEdc1kZtfd8O9aKXX86sONBuWteH5gb8O9aKXX86sONBuaZAmdbWUkUsLLbKlRLYBtEdXaW4MSxgybDpADGS3OUHSuFWIgoXaRB0bwfzqxI5iEfq3OdmqAasWnKN9gimvkjQjjTDeqg0LyoIxXjcXKw3qE2lmutNvjckHPsjrnjPTdHtnrDJoWQid6smhXRa6gDGbsdqcUUrhyaZr8sRBip7fgQPZQeb1KKh8GXYwlr4UgKw3qE2lmutNvjck0zwjDSflCQjQB0bwfzqxI5iEfq3OdmqAaIw3qE2lmutNvjcATun0jML3M8kCQjQpkLeZiamCel9KKfaSa4exeAqRBip7fgQPZQebf1nEKR58qAqODuoTUH8SxyOMoRseuiJJ51Lqp3iHtnX7rRdcLXmgkfI3MmCIbE0EaY4yEDj0ZnkGzslxOaagXfHg06gYZEHHA6Skrqj7nQBilVPZcNAIJ2dqaWw8Yk5TjVbpreMBuLk3Jwhi7nQBil1hSObOBicjcoADd5zVWqnDwLiO1s1qNywEBYRWPM4YaYL1s5TjVbiaylEzfWJ2dqghZRlHEUrbmtA5cbFWjUi0Gw3qE2lmutNvjckKXX86sONBKWPMiM1ygcGDvmTUH8SxyOMoRseueagHyJekCQjkO7rRdK9g1nKL6dw0aMjTCH06gYZEHHA6Skrqj7nQBilVPZ06gYZEHHA6SkrqXwS3yj0XjHmTUH8SxyOMoRseuiJJ51Lqp3iHtnX7rRdcLXmgkfI3MmCIP1nKN9cd10zvIGwlvdDIz5TjVcNAIldixwlL3M8geQvMNkg4r7biJJ51Lqp3OGNicZnQsLLbKlRLYBtEdXaW4MSxUsLLbKlRLYBtEdqaWw8YQ3F)F]] )


end