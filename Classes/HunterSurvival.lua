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


    spec:RegisterPack( "Survival", 20190728, [[dC0gJbqiGQEeHixcHcXMauFcHcPrrOWPie1Qiu5vssZIG6wiu1Ue8lG0Wiu6yaXYaq9mcHPrOQUgqLTrOOVHqLghasNdHIwhcv08qi3Ja7dHsheHcwic8qcvjxeHk0ijuLQtIqfyLskZeHkOBsOkANaLHIqHQLIqHYtv0ubK9QQ)s0GL4WuTyv6XqMScxg1Mj1NfYObOtlA1eQcVgbnBsUnI2Ts)wQHluhNqvklhQNdA6uUUk2ob57sQgpaCEcP1dGy(sI9J0pipq)C4g)GbWIfeIPyjUamanacaveIja)tt0y(NXoIqpI)56K8pNhSqPqU6NXUOQ2hpq)e2hmI)jGMfdjobf0O0a8CdOMeuysEuUL9IWU2afMKiq)59KkJ4G9V)C4g)GbWIfeIPyjUamanacaveIjiG7N(XaSX)CMKhLBzVIxyxB)eWCm49V)CWq0pfjAzEWcLc5kAr8(zngtRjs0cGMfdjobf0O0a8CdOMeuysEuUL9IWU2afMKiqP1ejAP2rjkTaWauHPfawSGqmPfINwabGsCkcWrRrRjs0I4fG(gXqItAnrIwiEAHyym4bTiEEaiaeftlwtldw7hLrloYYEPfvcTaTMirlepTiEbOVr8GwmhhXMm10cdGymdHzVqAXAAbjksXsZXrSbd0AIeTq80I4zpsDYdAb5yHyjAGPfRPL6nMqAHSXmTWomvIsl1tdqAXaKPfFm6LyuiTKKXkMKxZTSxAP10Iqoo9RId0AIeTq80cXWyWdA5yPknrPfIbIXjom8tvcn4d0p9yO9a9GbYd0p51VkE8e8teongN(pVhToG6gpY1nEiDi0pklCIPfGPfXGwUhToG6gpY1nEiDi0pklGzspxiTqeTasaC0I4OLi0GwQuHwUhToCvhSS1sZv9cdNyAbyA5E06WvDWYwlnx1lmGzspxiTqeTasaC0I4OLi0Gwe5F6il79NK9g1nKL3043EWa4hOFYRFv84j4NiCAmo9FEpADa1nEKRB8q6qOFuw4etlatlIbTCpADa1nEKRB8q6qOFuwaZKEUqAHiAbKa4OfXrlrObTuPcTCpAD4QoyzRLMR6fgoX0cW0Y9O1HR6GLTwAUQxyaZKEUqAHiAbKa4OfXrlrObTiY)0rw27pXES1yj0WjH8BpyI4b6N86xfpEc(jcNgJt)N6gDG0svAb5qtI5iEPfIOfDJoWaPdGF6il79NALVeMBKeA4Kq(ThmX)b6N86xfpEc(jcNgJt)N6JsjXmcqhhXsljzAHiAbKa4OfXrlrObTamTOB0bslvPfKdnjMJ4LwiIw0n6adKoaOfINwarS)0rw27pjmvkjQjj9D82dg4EG(jV(vXJNGFIWPX40)PUrhiTuLwqo0KyoIxAHiAr3Odmq6a4NoYYE)j0ywjnSh)2dMy(a9tE9RIhpb)eHtJXP)tDJoqAPkTGCOjXCeV0cr0IUrhyG0baTamTaEAXseH5grlatlGNwUhToqYKnwuzRLQdkhYbMDsy4etlatlIbTOpkLeZiaDCelTKKPfIOfqcGJwehTeHg0sLk0c4PLrBH6PAOtmlVn5nyjIWCJOfGPfWtl3JwhqDJh56gpKoe6hLfoX0Ii)thzzV)SEQg6eZYBtEF7bJ4(a9tE9RIhpb)eHtJXP)tWtlJ2cqghZRjHwUrblreMBeTamTaEA5E06aQB8ix34H0Hq)OSWj(NoYYE)jKXX8AsOLB0Bpya0hOFYRFv84j4NiCAmo9FQB0bslvPfKdnjMJ4LwiIw0n6adKoaOfGPfXGwUhToq2Bu3qwQpyrdqZreslerlGJwQuHw0n6aPfIOfhzzVbYEJ6gYYBACa1qJwe5F6il79NeMkLe1KK(oE7bJy(a9tE9RIhpb)eHtJXP)tmRXmeq)QyAbyAb80Y9O1bu34rUUXdPdH(rzHtmTamTCpADGS3OUHSuFWIgGMJiKwiIwa3pDKL9(tiJJ51Kql3O3EWarSpq)Kx)Q4XtWpr40yC6)e80Y9O1bu34rUUXdPdH(rzHt8pDKL9(txsEWdglBTeH76W3EWabKhOF6il79NOUXJCDJhshc9JY(jV(vXJNG3EWabGFG(jV(vXJNGFIWPX40)59O1bYEJ6gYs9blA4etlvQql6gDG0svAb5qtI5iEPfILw0n6adKoaOfINwarS0sLk0Y9O1bu34rUUXdPdH(rzHt8pDKL9(tYEJ6gYYBA8BpyGiIhOF6il79Nyp2ASeA4Kq(N86xfpEcE7bdeX)b6N86xfpEc(jcNgJt)NGNwSeryUr)0rw27pRNQHoXS82K33E7Nif7cXpqpyG8a9tE9RIhpb)SJ)jKTu)thzzV)uihN(vX)uihlxNK)jYXcXs0a)teongN(pDKLcXsEzYKH0cr0c4(PqU6Wswb5FcUFkKRo8pDKLcXsEzYKHV9GbWpq)0rw27pDj5bpySS1seURd)jV(vXJNG3EWeXd0pDKL9(tu34rUUXdPdH(rz)Kx)Q4XtWBpyI)d0p51VkE8e8teongN(phTfGaI94LvYBtEdwIim3OF6il79Nihle)2dg4EG(jV(vXJNGFIWPX40)j4PfZv8AHOdJXPs5sZrwIGbE9RIh0sLk0I(OusmJa0XrS0ssMwiIwIqJF6il79N1t1qNywEBY7BpyI5d0p51VkE8e8thzzV)KS3OUHS8Mg)teongN(ph89O1bLB8AY4oH9gGMJiKweqlGi2FIefPyP54i2GpyG82dgX9b6NoYYE)jcqNqStc)jV(vXJNG3EWaOpq)Kx)Q4XtWpDKL9(tctLsIAssFh)eHtJXP)tDJoqAPkTGCOjXCeV0cr0IUrhyG0bWprIIuS0CCeBWhmqE7bJy(a9tE9RIhpb)eHtJXP)t9rPKygbOJJyPLKmTqeTeHg0sLk0c4PfZv8AH6PAOtmlZvFGzVbE9RIh0sLk0YOTaeqShVSsEBYBWseH5grlatlJ2c5AmEDL8QyEKBuaAoIqAHiAre)0rw27pVhdbiJf9Thmqe7d0p51VkE8e8teongN(pnxXRfIomgNkLlnhzjcg41VkE8thzzV)e5yH43EWabKhOFYRFv84j4NiCAmo9FQB0bslvPfKdnjMJ4LwiIw0n6adKoa(PJSS3FQv(syUrsOHtc53EWabGFG(jV(vXJNGFIWPX40)5OTq9un0jML3M8gWSgZqa9RIPLkvOfZv8AH6PAOtmlZvFGzVbE9RIh)0rw27pRNQHoXS82K33EWarepq)Kx)Q4XtWpDKL9(tiJJ51Kql3OFIWPX40)59O1bHYygdLcXBtgWSJSFIefPyP54i2GpyG82dgiI)d0p51VkE8e8teongN(prDRgD9nupvdDIz5TjVbmt65cPfILweYXPFvCa5yHyjAGPfIrOfa(NoYYE)jYXcXV9Gbc4EG(PJSS3FcnMvsd7X)Kx)Q4XtWBpyGiMpq)Kx)Q4XtWpr40yC6)0CfVwWymju2AjVrEetYRf41VkE8thzzV)eqhh39(2dgie3hOFYRFv84j4NoYYE)jKXX8AsOLB0pr40yC6)eZAmdb0VkMwaMwUhToyzSS1sdqwcJzhhGMJiKwiIweXprIIuS0CCeBWhmqE7bdea6d0p51VkE8e8thzzV)KS3OUHS8Mg)tKOiflnhhXg8bdK3EWaHy(a9tE9RIhpb)0rw27pXES1yj0WjH8prIIuS0CCeBWhmqE7TFcThOhmqEG(jV(vXJNGFIWPX40)P5kETGXysOS1sEJ8iMKxlWRFv84NoYYE)jGooU79Thma(b6N86xfpEc(jcNgJt)N6gDG0svAb5qtI5iEPfIOfDJoWaPdGF6il79NALVeMBKeA4Kq(Thmr8a9tE9RIhpb)eHtJXP)Z7rRdOUXJCDJhshc9JYcNyAbyArmOL7rRdOUXJCDJhshc9JYcyM0ZfslerlGeahTioAjcnOLkvOL7rRdx1blBT0CvVWWjMwaMwUhToCvhSS1sZv9cdyM0ZfslerlGeahTioAjcnOfr(NoYYE)j2JTglHgojKF7bt8FG(jV(vXJNGFIWPX40)59O1bu34rUUXdPdH(rzHtmTamTig0Y9O1bu34rUUXdPdH(rzbmt65cPfIOfqcGJwehTeHg0sLk0Y9O1HR6GLTwAUQxy4etlatl3JwhUQdw2AP5QEHbmt65cPfIOfqcGJwehTeHg0Ii)thzzV)KS3OUHS8Mg)2dg4EG(jV(vXJNGFIWPX40)PUrhiTuLwqo0KyoIxAHiAr3Odmq6a4NoYYE)jHPsjrnjPVJ3EWeZhOFYRFv84j4NiCAmo9FQB0bslvPfKdnjMJ4LwiIw0n6adKoa(PJSS3FcnMvsd7XV9GrCFG(jV(vXJNGFIWPX40)PUrhiTuLwqo0KyoIxAHiAr3Odmq6aGwaMwapTyjIWCJOfGPfWtl3JwhizYglQS1s1bLd5aZojmCIPfGPfXGw0hLsIzeGooILwsY0cr0cibWrlIJwIqdAPsfAb80YOTq9un0jML3M8gSeryUr0cW0c4PL7rRdOUXJCDJhshc9JYcNyArK)PJSS3FwpvdDIz5TjVV9GbqFG(jV(vXJNGFIWPX40)59O1bYEJ6gYs9blAaAoIqAHyPfWrlatlGNwqDRgD9nG6gpY1nEiDi0pklGzspx4pDKL9(tYEJ6gYYBA8BpyeZhOFYRFv84j4NiCAmo9FEpADqOmMXqPq82KHtmTamTmAlazCmVMeA5gfWmPNlKwiIweFArC0seAqlvQqlJ2cqghZRjHwUrbmRXmeq)QyAbyAb80Y9O1bu34rUUXdPdH(rzHt8pDKL9(tiJJ51Kql3O3EWarSpq)Kx)Q4XtWpr40yC6)e80Y9O1bu34rUUXdPdH(rzHt8pDKL9(txsEWdglBTeH76W3EWabKhOF6il79NOUXJCDJhshc9JY(jV(vXJNG3EWabGFG(jV(vXJNGFIWPX40)59O1bYEJ6gYs9blA4etlvQql6gDG0svAb5qtI5iEPfILw0n6adKoaOfINwayXslatlMR41ccLXmgkfI3MmWRFv8GwQuHw0n6aPLQ0cYHMeZr8slelTOB0bgiDaqlepTacTamTyUIxlymMekBTK3ipIj51c86xfpOLkvOL7rRdOUXJCDJhshc9JYcN4F6il79NK9g1nKL3043EWarepq)0rw27pXES1yj0WjH8p51VkE8e82dgiI)d0p51VkE8e8teongN(phTfQNQHoXS82K3aM1ygcOFv8pDKL9(Z6PAOtmlVn59Thmqa3d0p51VkE8e8teongN(pVhToiugZyOuiEBYWj(NoYYE)jKXX8AsOLB0BV9Z668b6bdKhOFYRFv84j4NiCAmo9FQB0bslvPfKdnjMJ4LwiIw0n6adKoaOfGPfZv8AbJXKqzRL8g5rmjVwGx)Q4XpDKL9(taDCC37Bpya8d0p51VkE8e8teongN(pVhToCvhSS1sZv9cdNyAbyA5E06WvDWYwlnx1lmGzspxiTqeTeHg)0rw27pj7nQBilVPXV9GjIhOFYRFv84j4NiCAmo9FEpAD4QoyzRLMR6fgoX0cW0Y9O1HR6GLTwAUQxyaZKEUqAHiAjcn(PJSS3FI9yRXsOHtc53EWe)hOFYRFv84j4NiCAmo9FEpADqOmMXqPq82KHtmTamTCpADqOmMXqPq82Kbmt65cPfIOfqcGJwehTeHg0sLk0c4PLrBbiJJ51Kql3OGLicZn6NoYYE)jKXX8AsOLB0BpyG7b6N86xfpEc(jcNgJt)N6JsjXmcqhhXsljzAHiAbKa4OfXrlrObTamTOB0bslvPfKdnjMJ4LwiIw0n6adKoaOLkvOfXGwwgaMSEkVn5niuRClvmTamTmAlazCmVMeA5gfSeryUr0cW0YOTaKXX8AsOLBuaZAmdb0VkMwQuHwwgaMSEkVn5nediJBYEzAbyAb80Y9O1bYEJ6gYs9blA4etlatl6gDG0svAb5qtI5iEPfIOfDJoWaPdaAH4PfhzzVbctLsIAssFhbKdnjMJ4LwehTicArK)PJSS3FwpvdDIz5TjVV9GjMpq)Kx)Q4XtWpr40yC6)u3OdKwQslihAsmhXlTqeTOB0bgiDaqlepTOB0bgWCeV)0rw27pjmvkjQjj9D82dgX9b6NoYYE)Pljp4bJLTwIWDD4p51VkE8e82dga9b6N86xfpEc(jcNgJt)N6gDG0svAb5qtI5iEPfIOfDJoWaPdGF6il79NqJzL0WE8BpyeZhOFYRFv84j4NiCAmo9FQpkLeZiaDCelTKKPfIOfqcGJwehTeHg)0rw27pRNQHoXS82K33EWarSpq)0rw27prDJh56gpKoe6hL9tE9RIhpbV9Gbcipq)Kx)Q4XtWpr40yC6)8E06GqzmJHsH4TjdNyAbyAz0waY4yEnj0YnkGzspxiTqeTi(0I4OLi04NoYYE)jKXX8AsOLB0BpyGaWpq)Kx)Q4XtWpr40yC6)C0waci2JxwjVn5nyjIWCJOLkvOL7rRdK9g1nKL6dw0a0CeH0IaAbC)0rw27pj7nQBilVPXV9GbIiEG(jV(vXJNGFIWPX40)5YaWK1t5TjVbiGypEzfTamTmAlazCmVMeA5gfWmPNlKwiwAbC0I4OLi04NoYYE)z9un0jML3M8(2dgiI)d0p51VkE8e8teongN(pXSgZqa9RI)PJSS3FczCmVMeA5g92dgiG7b6N86xfpEc(jcNgJt)NGNwUhToq2Bu3qwQpyrdyM0Zf(thzzV)ebOti2jHV9GbIy(a9thzzV)KS3OUHS8Mg)tE9RIhpbV9GbcX9b6NoYYE)j2JTglHgojK)jV(vXJNG3EWabG(a9tE9RIhpb)eHtJXP)Z7rRdcLXmgkfI3MmCI)PJSS3FczCmVMeA5g92dgieZhOFYRFv84j4NiCAmo9FUmamz9uEBYBqOw5wQyAbyAz0waY4yEnj0YnkyjIWCJOLkvOLLbGjRNYBtEdXaY4MSxMwQuHwwgaMSEkVn5nabe7XlR(PJSS3FwpvdDIz5TjVV92p94668b6bdKhOFYRFv84j4NiCAmo9FEpAD4QoyzRLMR6fgoX0cW0Y9O1HR6GLTwAUQxyaZKEUqAHiAjcn(PJSS3Fs2Bu3qwEtJF7bdGFG(jV(vXJNGFIWPX40)59O1HR6GLTwAUQxy4etlatl3JwhUQdw2AP5QEHbmt65cPfIOLi04NoYYE)j2JTglHgojKF7btepq)Kx)Q4XtWpr40yC6)e80YOTaKXX8AsOLBuWseH5g9thzzV)eY4yEnj0Yn6ThmX)b6NoYYE)Pljp4bJLTwIWDD4p51VkE8e82dg4EG(jV(vXJNGFIWPX40)P(OusmJa0XrS0ssMwiIwajaoArC0seAqlvQql6gDG0svAb5qtI5iEPfIOfDJoWaPdaAbyArmOLLbGjRNYBtEdc1k3sftlatlJ2cqghZRjHwUrblreMBeTamTmAlazCmVMeA5gfWSgZqa9RIPLkvOLLbGjRNYBtEdXaY4MSxMwaMwapTCpADGS3OUHSuFWIgoX0cW0IUrhiTuLwqo0KyoIxAHiAr3Odmq6aGwiEAXrw2BGWuPKOMK03ra5qtI5iEPfXrlIGwe5F6il79N1t1qNywEBY7BpyI5d0pDKL9(tu34rUUXdPdH(rz)Kx)Q4XtWBpye3hOFYRFv84j4NiCAmo9FEpADGS3OUHSuFWIgWmPNlKwaMwwgaMSEkVn5nediJBYE5F6il79NK9g1nKL3043EWaOpq)Kx)Q4XtWpr40yC6)uFukjMra64iwAjjtlerlGeahTioAjcnOfGPfDJoqAPkTGCOjXCeV0cr0IUrhyG0baTq80cal2F6il79NeMkLe1KK(oE7bJy(a9tE9RIhpb)eHtJXP)tDJoqAPkTGCOjXCeV0cr0IUrhyG0bWpDKL9(tOXSsAyp(Thmqe7d0p51VkE8e8teongN(pVhToyzSS1sdqwcJzhhGMJiKweqlIGwQuHwgTfGaI94LvYBtEdwIim3OF6il79Nyp2ASeA4Kq(Thmqa5b6N86xfpEc(jcNgJt)NJ2cqaXE8Yk5TjVblreMB0pDKL9(tYEJ6gYYBA8BpyGaWpq)Kx)Q4XtWpr40yC6)CzayY6P82K3aeqShVSIwaMw0n6aPfILweHyPfGPLrBbiJJ51Kql3OaMj9CH0cXslGJwehTeHg)0rw27pRNQHoXS82K33EWarepq)Kx)Q4XtWpr40yC6)e80Y9O1bYEJ6gYs9blAaZKEUWF6il79NiaDcXoj8Thmqe)hOFYRFv84j4NiCAmo9FIznMHa6xf)thzzV)eY4yEnj0Yn6Thmqa3d0p51VkE8e8teongN(p1n6aPLQ0cYHMeZr8slerl6gDGbsha0cW0Iyql3Jwhi7nQBil1hSObO5icPfIOfWrlvQql6gDG0cr0IJSS3azVrDdz5nnoGAOrlI8pDKL9(tctLsIAssFhV9GbIy(a9thzzV)e7XwJLqdNeY)Kx)Q4XtWBpyGqCFG(jV(vXJNGFIWPX40)59O1bYEJ6gYs9blA4etlvQql6gDG0cXslIVyPLkvOLrBbiGypEzL82K3GLicZn6NoYYE)jzVrDdz5nn(ThmqaOpq)Kx)Q4XtWpr40yC6)CzayY6P82K3GqTYTuX0cW0YOTaKXX8AsOLBuWseH5grlvQqlldatwpL3M8gIbKXnzVmTuPcTSmamz9uEBYBaci2Jxwrlatl6gDG0cXslGtS)0rw27pRNQHoXS82K33E7NXyg1Kx3EGEWa5b6NoYYE)j8qs2RmMTFYRFv84j4Thma(b6NoYYE)zCBzV)Kx)Q4XtWBpyI4b6NoYYE)j0ywjnSh)tE9RIhpbV9Gj(pq)0rw27pb0XXDV)Kx)Q4XtWBpyG7b6N86xfpEc(PJSS3Fg3iczdMaeEirnz8XCl7voyHse)teongN(pbpTG9CizH41c5k0rTm2VkoWaiHg8NSwZitUoj)tKOivB4EtK8QCO92B)enGpqpyG8a9tE9RIhpb)eHtJXP)tu3QrxFdOUXJCDJhshc9JYcyM0ZfslelTicX(thzzV)8Q6Ei1hSOV9GbWpq)Kx)Q4XtWpr40yC6)e1TA013aQB8ix34H0Hq)OSaMj9CH0cXslIqS)0rw27p9fXqd7kjYvQ3EWeXd0p51VkE8e8teongN(prDRgD9nG6gpY1nEiDi0pklGzspxiTqS0Iie7pDKL9(tDI5RQ7XBpyI)d0pDKL9(tvgbObLIhNrejV2p51VkE8e82dg4EG(jV(vXJNGFIWPX40)jQB1ORVbu34rUUXdPdH(rzbmt65cPfILwetXslvQqlwsYsRLJKPfIOfqeXpDKL9(ZlJHmMWCJE7btmFG(jV(vXJNGFIWPX40)59O1bu34rUUXdPdH(rzHtmTamTig0Y9O1HlJHmMWCJcNyAPsfA5E06Wv19qQpyrdNyAPsfAb80c2rCWWTsrlatlGNwWoIdngrlImTuPcTig0cQx4H0Vkoe3w2RS1YZEX5qXdP(GfLwaMwSKKLwlhjtlerlIji0sLk0ILKS0A5izAHiAbGftArK)PJSS3Fg3w27Bpye3hOFYRFv84j4NiCAmo9FAooITWiHMViMwiwb0Iy(thzzV)0HXmYKTwAaYs2Ju8Bpya0hOFYRFv84j4NoYYE)PdbuiFzOe7aKglrn2v)eHtJXP)Z7rRdKmzJfv2AP6GYHCGzNegoX0sLk0Y9O1HOJJhPVYwlDacJBdWWjMwQuHwg89O1bSdqASe1yxjh89O1HrxFPLkvOfljzP1YrY0cr0cal2FUoj)thcOq(Yqj2binwIASRE7bJy(a9tE9RIhpb)0rw27pJCfJCLIXq5T79NiCAmo9FI6wn66BGKjBSOYwlvhuoKdm7KWaMj9CH0sLk0I5kETq9un0jML5QpWS3aV(vXdAbyAb1TA013aQB8ix34H0Hq)OSaMj9CH0sLk0cQB1ORVbKOivB4EtK8QCOfWmPNlKwQuHwapTWqiVioqYKnwuzRLQdkhYbMDsyG0fpAmTamTaEAXCfVwOEQg6eZYC1hy2BGx)Q4XpxNK)zKRyKRumgkVDVV9GbIyFG(PJSS3FQB0bYdPdqyCAS8Yo5p51VkE8e82dgiG8a9tE9RIhpb)eHtJXP)tDJoqAHiAr3Odmq6aGwiEAreILwaMwUhToG6gpY1nEiDi0pklCI)PJSS3FsYKnwuzRLQdkhYbMDs4BpyGaWpq)Kx)Q4XtWpr40yC6)8E06aQB8ix34H0Hq)OSWj(NoYYE)5v19q2APbil5Ljf9ThmqeXd0pDKL9(Z4do1IMBK8QCO9tE9RIhpbV9GbI4)a9thzzV)m644r6RS1shGW42a8N86xfpEcE7bdeW9a9thzzV)eNXXkwMReg7i(N86xfpEcE7bdeX8b6N86xfpEc(jcNgJt)N6JsjXmcqhhXsljzAHiAbeArC0seA8thzzV)e1lIxd7gpKALtYV9GbcX9b6N86xfpEc(jcNgJt)N3JwhWmIqfdHsDJrC4e)thzzV)0aKLN92NDi1ngXV9Gbca9b6NoYYE)z9gRgcX5kXmSxFr8p51VkE8e82B)CWA)OShOhmqEG(jV(vXJNGFIWPX40)5GVhToGCOLBu4etlvQqld(E06WiHXSs5xflj9OefoX0sLk0YGVhTomsymRu(vXsEXEehoX)0rw27prUsjDKL9kvj0(PkHMCDs(NhlvPj6Bpya8d0pDKL9(ZdKLPXKWFYRFv84j4Thmr8a9tE9RIhpb)0rw27prUsjDKL9kvj0(PkHMCDs(NOb8ThmX)b6N86xfpEc(jcNgJt)NoYsHyjVmzYqAHiAre0cW0I5kETacqNqStcd86xfpOfGPfZv8AbxfdOlJX8WTgh41VkE8thzzV)e5kL0rw2RuLq7NQeAY1j5F6X115BpyG7b6N86xfpEc(jcNgJt)NoYsHyjVmzYqAHiAre0cW0I5kETacqNqStcd86xfp(PJSS3FICLs6il7vQsO9tvcn56K8pRRZ3EWeZhOFYRFv84j4NiCAmo9F6ilfIL8YKjdPfIOfrqlatlGNwmxXRfCvmGUmgZd3ACGx)Q4bTamTaEAXCfVwOEQg6eZYC1hy2BGx)Q4XpDKL9(tKRushzzVsvcTFQsOjxNK)j0E7bJ4(a9tE9RIhpb)eHtJXP)thzPqSKxMmziTqeTicAbyAXCfVwWvXa6YympCRXbE9RIh0cW0c4PfZv8AH6PAOtmlZvFGzVbE9RIh)0rw27prUsjDKL9kvj0(PkHMCDs(NEm0E7bdG(a9tE9RIhpb)eHtJXP)thzPqSKxMmziTqeTicAbyAXCfVwWvXa6YympCRXbE9RIh0cW0I5kETq9un0jML5QpWS3aV(vXJF6il79NixPKoYYELQeA)uLqtUoj)tpUUoF7bJy(a9tE9RIhpb)eHtJXP)thzPqSKxMmziTqeTicAbyAb80I5kETGRIb0LXyE4wJd86xfpOfGPfZv8AH6PAOtmlZvFGzVbE9RIh)0rw27prUsjDKL9kvj0(PkHMCDs(N115BpyGi2hOFYRFv84j4NiCAmo9F6ilfIL8YKjdPfILwa5NoYYE)jYvkPJSSxPkH2pvj0KRtY)ePyxi(Thmqa5b6NoYYE)jQxeVg2nEi1kNK)jV(vXJNG3EWabGFG(PJSS3F6yKVS0AmMx7N86xfpEcE7TFESuLMOpqpyG8a9thzzV)K8aqaik(N86xfpEcE7bdGFG(PJSS3FczmVPjQCCG2p51VkE8e82dMiEG(PJSS3FcJBmlrQ(m(jV(vXJNG3EWe)hOF6il79NWUnaZnsw3ng)tE9RIhpbV9GbUhOF6il79NWEtK8QCO9tE9RIhpbV9GjMpq)0rw27px2aKXsiGnIWFYRFv84j4ThmI7d0pDKL9(teGP4rcLg2xXBNuLMO)Kx)Q4XtWBpya0hOF6il79NW4eNMecyJi8N86xfpEcE7bJy(a9thzzV)CD7GzOmc7i(N86xfpEcE7T3(PqmgM9(GbWIfeIPyjUamaheRyfli)SUJ3CJG)K4aY4gB8GwiM0IJSSxArLqdgO1(jmMrpyam4a3pJXTov8pfjAzEWcLc5kAr8(zngtRjs0cGMfdjobf0O0a8CdOMeuysEuUL9IWU2afMKiqP1ejAP2rjkTaWauHPfawSGqmPfINwabGsCkcWrRrRjs0I4fG(gXqItAnrIwiEAHyym4bTiEEaiaeftlwtldw7hLrloYYEPfvcTaTMirlepTiEbOVr8GwmhhXMm10cdGymdHzVqAXAAbjksXsZXrSbd0AIeTq80I4zpsDYdAb5yHyjAGPfRPL6nMqAHSXmTWomvIsl1tdqAXaKPfFm6LyuiTKKXkMKxZTSxAP10Iqoo9RId0AIeTq80cXWyWdA5yPknrPfIbIXjomqRrRjs0cXraWOJXdA5Y6gZ0cQjVUrlxokxyGwigqio2G0Y2lXdOJj1hfT4il7fsl9QenqRjs0IJSSxyigZOM86MaTYHesRjs0IJSSxyigZOM86wvbG6NisEn3YEP1ejAXrw2lmeJzutEDRQaq1DpO1CKL9cdXyg1Kx3Qkau4HKSxzmB0AIeTmxpgcyB0c2ZbTCpAnpOfO5gKwUSUXmTGAYRB0YLJYfsl(oOLymt8XTz5grljKwg9YbAnrIwCKL9cdXyg1Kx3Qkau46XqaBtcn3G0AoYYEHHymJAYRBvfaACBzV0AoYYEHHymJAYRBvfak0ywjnShtR5il7fgIXmQjVUvvaOa644UxAnhzzVWqmMrn51TQca9azzAmPWSwZitUojlajks1gU3ejVkhAcNAbGh75qYcXRfYvOJAzSFvCGbqcniTgTMJSSxy4yPknrfqEaiaeftR5il7fgowQst0QcafYyEttu54anAnhzzVWWXsvAIwvaOW4gZsKQpdAnhzzVWWXsvAIwvaOWUnaZnsw3ngtR5il7fgowQst0Qcaf2BIKxLdnAnhzzVWWXsvAIwvaOlBaYyjeWgriTMJSSxy4yPknrRkaueGP4rcLg2xXBNuLMO0AoYYEHHJLQ0eTQaqHXjonjeWgriTMJSSxy4yPknrRka01TdMHYiSJyAnAnrIwiocagDmEqlSqmwuAXssMwmazAXrwJPLeslUqEQ8RId0AoYYEHcqUsjDKL9kvj0eEDswWXsvAIkCQfm47rRdihA5gfoXvQm47rRdJegZkLFvSK0Jsu4exPYGVhTomsymRu(vXsEXEehoX0AoYYEHvfa6bYY0ysiTMJSSxyvbGICLs6il7vQsOj86KSa0asR5il7fwvaOixPKoYYELQeAcVojlWJRRtHtTahzPqSKxMmzirIayZv8AbeGoHyNeg41VkEaS5kETGRIb0LXyE4wJd86xfpO1CKL9cRkauKRushzzVsvcnHxNKfuxNcNAboYsHyjVmzYqIebWMR41ciaDcXojmWRFv8GwZrw2lSQaqrUsjDKL9kvj0eEDswa0eo1cCKLcXsEzYKHejcGbV5kETGRIb0LXyE4wJd86xfpag8MR41c1t1qNywMR(aZEd86xfpO1CKL9cRkauKRushzzVsvcnHxNKf4Xqt4ulWrwkel5LjtgsKia2CfVwWvXa6YympCRXbE9RIhadEZv8AH6PAOtmlZvFGzVbE9RIh0AoYYEHvfakYvkPJSSxPkHMWRtYc8466u4ulWrwkel5LjtgsKia2CfVwWvXa6YympCRXbE9RIhaBUIxlupvdDIzzU6dm7nWRFv8GwZrw2lSQaqrUsjDKL9kvj0eEDswqDDkCQf4ilfIL8YKjdjseadEZv8AbxfdOlJX8WTgh41VkEaS5kETq9un0jML5QpWS3aV(vXdAnhzzVWQcaf5kL0rw2RuLqt41jzbif7cXcNAboYsHyjVmzYqIfeAnhzzVWQcaf1lIxd7gpKALtY0AoYYEHvfaQJr(YsRXyEnAnAnhzzVWGhdnbK9g1nKL30yHtTG7rRdOUXJCDJhshc9JYcNyGfJ7rRdOUXJCDJhshc9JYcyM0ZfseibWjUi0OsL7rRdx1blBT0CvVWWjg47rRdx1blBT0CvVWaMj9CHebsaCIlcnezAnhzzVWGhdTQcaf7XwJLqdNeYcNAb3JwhqDJh56gpKoe6hLfoXalg3JwhqDJh56gpKoe6hLfWmPNlKiqcGtCrOrLk3JwhUQdw2AP5QEHHtmW3JwhUQdw2AP5QEHbmt65cjcKa4exeAiY0AoYYEHbpgAvfaQw5lH5gjHgojKfo1c0n6aRICOjXCeVePB0bgiDaqR5il7fg8yOvvaOeMkLe1KK(oeo1c0hLsIzeGooILwsYebsaCIlcnaw3OdSkYHMeZr8sKUrhyG0baXdIyP1CKL9cdEm0QkauOXSsAypw4ulq3OdSkYHMeZr8sKUrhyG0baTMJSSxyWJHwvbGwpvdDIz5TjVcNAb6gDGvro0KyoIxI0n6adKoaag8wIim3iGb)9O1bsMSXIkBTuDq5qoWStcdNyGfd9rPKygbOJJyPLKmrGeaN4IqJkva)OTq9un0jML3M8gSeryUrad(7rRdOUXJCDJhshc9JYcNyrMwZrw2lm4XqRQaqHmoMxtcTCJeo1ca)OTaKXX8AsOLBuWseH5gbm4VhToG6gpY1nEiDi0pklCIP1CKL9cdEm0QkauctLsIAssFhcNAb6gDGvro0KyoIxI0n6adKoaawmUhToq2Bu3qwQpyrdqZrese4Qur3OdKihzzVbYEJ6gYYBACa1qtKP1CKL9cdEm0QkauiJJ51Kql3iHtTamRXmeq)QyGb)9O1bu34rUUXdPdH(rzHtmW3Jwhi7nQBil1hSObO5icjcC0AoYYEHbpgAvfaQljp4bJLTwIWDDOWPwa4VhToG6gpY1nEiDi0pklCIP1CKL9cdEm0Qkauu34rUUXdPdH(rz0AoYYEHbpgAvfakzVrDdz5nnw4ul4E06azVrDdzP(GfnCIRur3OdSkYHMeZr8sS6gDGbshaepiITsL7rRdOUXJCDJhshc9JYcNyAnhzzVWGhdTQcaf7XwJLqdNeY0AoYYEHbpgAvfaA9un0jML3M8kCQfaElreMBeTgTMJSSxyWJRRtbK9g1nKL30yHtTG7rRdx1blBT0CvVWWjg47rRdx1blBT0CvVWaMj9CHefHg0AoYYEHbpUUoRkauShBnwcnCsilCQfCpAD4QoyzRLMR6fgoXaFpAD4QoyzRLMR6fgWmPNlKOi0GwZrw2lm4X11zvbGczCmVMeA5gjCQfa(rBbiJJ51Kql3OGLicZnIwZrw2lm4X11zvbG6sYdEWyzRLiCxhsR5il7fg8466SQaqRNQHoXS82KxHtTa9rPKygbOJJyPLKmrGeaN4IqJkv0n6aRICOjXCeVePB0bgiDaaSySmamz9uEBYBqOw5wQyGhTfGmoMxtcTCJcwIim3iGhTfGmoMxtcTCJcywJziG(vXvQSmamz9uEBYBigqg3K9Yad(7rRdK9g1nKL6dw0WjgyDJoWQihAsmhXlr6gDGbshaeVJSS3aHPsjrnjPVJaYHMeZr8koriY0AoYYEHbpUUoRkauu34rUUXdPdH(rz0AoYYEHbpUUoRkauYEJ6gYYBASWPwW9O1bYEJ6gYs9blAaZKEUqGxgaMSEkVn5nediJBYEzAnhzzVWGhxxNvfakHPsjrnjPVdHtTa9rPKygbOJJyPLKmrGeaN4IqdG1n6aRICOjXCeVePB0bgiDaq8aSyP1CKL9cdECDDwvaOqJzL0WESWPwGUrhyvKdnjMJ4LiDJoWaPdaAnhzzVWGhxxNvfak2JTglHgojKfo1cUhToyzSS1sdqwcJzhhGMJiuGiQuz0waci2JxwjVn5nyjIWCJO1CKL9cdECDDwvaOK9g1nKL30yHtTGrBbiGypEzL82K3GLicZnIwZrw2lm4X11zvbGwpvdDIz5TjVcNAbldatwpL3M8gGaI94LvaRB0bsSIqSapAlazCmVMeA5gfWmPNlKybN4IqdAnhzzVWGhxxNvfakcqNqStcfo1ca)9O1bYEJ6gYs9blAaZKEUqAnhzzVWGhxxNvfakKXX8AsOLBKWPwaM1ygcOFvmTMJSSxyWJRRZQcaLWuPKOMK03HWPwGUrhyvKdnjMJ4LiDJoWaPdaGfJ7rRdK9g1nKL6dw0a0CeHebUkv0n6ajYrw2BGS3OUHS8Mghqn0ezAnhzzVWGhxxNvfak2JTglHgojKP1CKL9cdECDDwvaOK9g1nKL30yHtTG7rRdK9g1nKL6dw0WjUsfDJoqIv8fBLkJ2cqaXE8Yk5TjVblreMBeTMJSSxyWJRRZQcaTEQg6eZYBtEfo1cwgaMSEkVn5niuRClvmWJ2cqghZRjHwUrblreMBuLkldatwpL3M8gIbKXnzVCLkldatwpL3M8gGaI94LvaRB0bsSGtS0A0AoYYEHb0ak4Q6Ei1hSOcNAbOUvJU(gqDJh56gpKoe6hLfWmPNlKyfHyP1CKL9cdObSQaq9fXqd7kjYvkHtTau3QrxFdOUXJCDJhshc9JYcyM0ZfsSIqS0AoYYEHb0awvaO6eZxv3dHtTau3QrxFdOUXJCDJhshc9JYcyM0ZfsSIqS0AoYYEHb0awvaOQmcqdkfpoJisEnAnhzzVWaAaRka0lJHmMWCJeo1cqDRgD9nG6gpY1nEiDi0pklGzspxiXkMITsfljzP1YrYebIiO1CKL9cdObSQaqJBl7v4ul4E06aQB8ix34H0Hq)OSWjgyX4E06WLXqgtyUrHtCLk3JwhUQUhs9blA4exPc4XoIdgUvkGbp2rCOXirUsfXa1l8q6xfhIBl7v2A5zV4CO4HuFWIcSLKS0A5izIetqQuXsswATCKmraSykY0AoYYEHb0awvaOomMrMS1sdqwYEKIfo1cmhhXwyKqZxetScetAnhzzVWaAaRka0dKLPXKcVojlWHakKVmuIDasJLOg7kHtTG7rRdKmzJfv2AP6GYHCGzNegoXvQCpADi644r6RS1shGW42amCIRuzW3JwhWoaPXsuJDLCW3JwhgD9TsfljzP1YrYebWILwZrw2lmGgWQca9azzAmPWRtYcICfJCLIXq5T7v4ula1TA013ajt2yrLTwQoOCihy2jHbmt65cRuXCfVwOEQg6eZYC1hy2BGx)Q4bWOUvJU(gqDJh56gpKoe6hLfWmPNlSsfu3QrxFdirrQ2W9Mi5v5qlGzspxyLkGNHqErCGKjBSOYwlvhuoKdm7KWaPlE0yGbV5kETq9un0jML5QpWS3aV(vXdAnhzzVWaAaRkauDJoqEiDacJtJLx2jP1CKL9cdObSQaqjzYglQS1s1bLd5aZoju4ulq3OdKiDJoWaPdaIxeIf47rRdOUXJCDJhshc9JYcNyAnhzzVWaAaRka0RQ7HS1sdqwYltkQWPwW9O1bu34rUUXdPdH(rzHtmTMJSSxyanGvfaA8bNArZnsEvo0O1CKL9cdObSQaqJooEK(kBT0bimUnaP1CKL9cdObSQaqXzCSIL5kHXoIP1CKL9cdObSQaqr9I41WUXdPw5KSWPwG(OusmJa0XrS0ssMiqexeAqR5il7fgqdyvbGAaYYZE7ZoK6gJyHtTG7rRdygrOIHqPUXioCIP1CKL9cdObSQaqR3y1qioxjMH96lIP1O1CKL9cdif7cXceYXPFvSWRtYcqowiwIgyH7ybq2sTWc5QdlWrwkel5LjtgkSqU6WswbzbGtyuVJ0YEf4ilfIL8YKjdjcC0AoYYEHbKIDH4Qca1LKh8GXYwlr4UoKwZrw2lmGuSlexvaOOUXJCDJhshc9JYO1CKL9cdif7cXvfakYXcXcNAbJ2cqaXE8Yk5TjVblreMBeTMJSSxyaPyxiUQaqRNQHoXS82KxHtTaWBUIxleDymovkxAoYsemWRFv8Osf9rPKygbOJJyPLKmrrObTMJSSxyaPyxiUQaqj7nQBilVPXcJefPyP54i2Gcar4ulyW3JwhuUXRjJ7e2BaAoIqbGiwAnhzzVWasXUqCvbGIa0je7KqAnhzzVWasXUqCvbGsyQusuts67qyKOiflnhhXguaicNAb6gDGvro0KyoIxI0n6adKoaO1CKL9cdif7cXvfa69yiazSOcNAb6JsjXmcqhhXsljzIIqJkvaV5kETq9un0jML5QpWS3aV(vXJkvgTfGaI94LvYBtEdwIim3iGhTfY1y86k5vX8i3Oa0CeHejcAnhzzVWasXUqCvbGICSqSWPwG5kETq0HX4uPCP5ilrWaV(vXdAnhzzVWasXUqCvbGQv(syUrsOHtczHtTaDJoWQihAsmhXlr6gDGbsha0AoYYEHbKIDH4QcaTEQg6eZYBtEfo1cgTfQNQHoXS82K3aM1ygcOFvCLkMR41c1t1qNywMR(aZEd86xfpO1CKL9cdif7cXvfakKXX8AsOLBKWirrkwAooInOaqeo1cUhToiugZyOuiEBYaMDKrR5il7fgqk2fIRkauKJfIfo1cqDRgD9nupvdDIz5TjVbmt65cjwHCC6xfhqowiwIgyIrayAnhzzVWasXUqCvbGcnMvsd7X0AoYYEHbKIDH4Qcafqhh39kCQfyUIxlymMekBTK3ipIj51c86xfpO1CKL9cdif7cXvfakKXX8AsOLBKWirrkwAooInOaqeo1cWSgZqa9RIb(E06GLXYwlnazjmMDCaAoIqIebTMirla10cmjpk3yA5a9iMw0nMwep7nQBitleKgtlnMwigZJTgtltdNeY0Y4GZnIwigGXmYOLwtlgGmTqC0JuSW0cQJfLwyhbiT0i0bJ5fX0sRPfdqMwCKL9sl(oOfpoM3bTizpsX0I10IbitloYYEPL1j5aTMJSSxyaPyxiUQaqj7nQBilVPXcJefPyP54i2GcaHwZrw2lmGuSlexvaOyp2ASeA4KqwyKOiflnhhXguai0A0AoYYEHbOjaqhh39kCQfyUIxlymMekBTK3ipIj51c86xfpO1CKL9cdqRQaq1kFjm3ij0WjHSWPwGUrhyvKdnjMJ4LiDJoWaPdaAnhzzVWa0QkauShBnwcnCsilCQfCpADa1nEKRB8q6qOFuw4edSyCpADa1nEKRB8q6qOFuwaZKEUqIajaoXfHgvQCpAD4QoyzRLMR6fgoXaFpAD4QoyzRLMR6fgWmPNlKiqcGtCrOHitRjs0cqnTatYJYnMwoqpIPfDJPfXZEJ6gY0cbPX0sJPfIX8yRX0Y0WjHmTmo4CJOfIbymJmAP10Ibitleh9iflmTG6yrPf2raslncDWyErmT0AAXaKPfhzzV0IVdAXJJ5Dqls2JumTynTyaY0IJSSxAzDsoqR5il7fgGwvbGs2Bu3qwEtJfo1cUhToG6gpY1nEiDi0pklCIbwmUhToG6gpY1nEiDi0pklGzspxirGeaN4IqJkvUhToCvhSS1sZv9cdNyGVhToCvhSS1sZv9cdyM0ZfseibWjUi0qKP1CKL9cdqRQaqjmvkjQjj9DiCQfOB0bwf5qtI5iEjs3Odmq6aGwZrw2lmaTQcafAmRKg2Jfo1c0n6aRICOjXCeVePB0bgiDaqR5il7fgGwvbGwpvdDIz5TjVcNAb6gDGvro0KyoIxI0n6adKoaag8wIim3iGb)9O1bsMSXIkBTuDq5qoWStcdNyGfd9rPKygbOJJyPLKmrGeaN4IqJkva)OTq9un0jML3M8gSeryUrad(7rRdOUXJCDJhshc9JYcNyrMwZrw2lmaTQcaLS3OUHS8MglCQfCpADGS3OUHSuFWIgGMJiKybhWGh1TA013aQB8ix34H0Hq)OSaMj9CH0AoYYEHbOvvaOqghZRjHwUrcNAb3JwhekJzmukeVnz4ed8OTaKXX8AsOLBuaZKEUqIeFXfHgvQmAlazCmVMeA5gfWSgZqa9RIbg83JwhqDJh56gpKoe6hLfoX0AoYYEHbOvvaOUK8Ghmw2Ajc31HcNAbG)E06aQB8ix34H0Hq)OSWjMwZrw2lmaTQcaf1nEKRB8q6qOFugTMJSSxyaAvfakzVrDdz5nnw4ul4E06azVrDdzP(GfnCIRur3OdSkYHMeZr8sS6gDGbshaepalwGnxXRfekJzmukeVnzGx)Q4rLk6gDGvro0KyoIxIv3Odmq6aG4bbyZv8AbJXKqzRL8g5rmjVwGx)Q4rLk3JwhqDJh56gpKoe6hLfoX0AoYYEHbOvvaOyp2ASeA4KqMwZrw2lmaTQcaTEQg6eZYBtEfo1cgTfQNQHoXS82K3aM1ygcOFvmTMJSSxyaAvfakKXX8AsOLBKWPwW9O1bHYygdLcXBtgoX0A0AoYYEHH66uaGooU7v4ulq3OdSkYHMeZr8sKUrhyG0baWMR41cgJjHYwl5nYJysETaV(vXdAnhzzVWqDDwvaOK9g1nKL30yHtTG7rRdx1blBT0CvVWWjg47rRdx1blBT0CvVWaMj9CHefHg0AoYYEHH66SQaqXES1yj0WjHSWPwW9O1HR6GLTwAUQxy4ed89O1HR6GLTwAUQxyaZKEUqIIqdAnhzzVWqDDwvaOqghZRjHwUrcNAb3JwhekJzmukeVnz4ed89O1bHYygdLcXBtgWmPNlKiqcGtCrOrLkGF0waY4yEnj0YnkyjIWCJO1CKL9cd11zvbGwpvdDIz5TjVcNAb6JsjXmcqhhXsljzIajaoXfHgaRB0bwf5qtI5iEjs3Odmq6aOsfXyzayY6P82K3GqTYTuXapAlazCmVMeA5gfSeryUrapAlazCmVMeA5gfWSgZqa9RIRuzzayY6P82K3qmGmUj7Lbg83Jwhi7nQBil1hSOHtmW6gDGvro0KyoIxI0n6adKoaiEhzzVbctLsIAssFhbKdnjMJ4vCIqKP1CKL9cd11zvbGsyQusuts67q4ulq3OdSkYHMeZr8sKUrhyG0baXRB0bgWCeV0AoYYEHH66SQaqDj5bpySS1seURdP1CKL9cd11zvbGcnMvsd7XcNAb6gDGvro0KyoIxI0n6adKoaO1CKL9cd11zvbGwpvdDIz5TjVcNAb6JsjXmcqhhXsljzIajaoXfHg0AoYYEHH66SQaqrDJh56gpKoe6hLrR5il7fgQRZQcafY4yEnj0Yns4ul4E06GqzmJHsH4TjdNyGhTfGmoMxtcTCJcyM0ZfsK4lUi0GwZrw2lmuxNvfakzVrDdz5nnw4uly0waci2JxwjVn5nyjIWCJQu5E06azVrDdzP(GfnanhrOaWrR5il7fgQRZQcaTEQg6eZYBtEfo1cwgaMSEkVn5nabe7XlRaE0waY4yEnj0YnkGzspxiXcoXfHg0AoYYEHH66SQaqHmoMxtcTCJeo1cWSgZqa9RIP1CKL9cd11zvbGIa0je7KqHtTaWFpADGS3OUHSuFWIgWmPNlKwZrw2lmuxNvfakzVrDdz5nnMwZrw2lmuxNvfak2JTglHgojKP1CKL9cd11zvbGczCmVMeA5gjCQfCpADqOmMXqPq82KHtmTMJSSxyOUoRka06PAOtmlVn5v4ulyzayY6P82K3GqTYTuXapAlazCmVMeA5gfSeryUrvQSmamz9uEBYBigqg3K9YvQSmamz9uEBYBaci2Jxw92B)d]] )


end