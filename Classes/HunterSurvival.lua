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


    spec:RegisterPack( "Survival", 20190925, [[dC0CNbqiGOhriQlPabTja5tiGOgfHGtHa1QuG6vkOzrqDlcr2LGFbunmcPogqAzaKEgHKPPaPRbe2gaHVriKXriuNdGO1HacZdbDpcSpeihebKwic5HkquxubcmseqHtIakALayMiGsDtfiYobkdfbuYsrarEQkMkGAVQ6VenyromLfRspgYKf1LrTzs9zHA0kuNwYQravVgHA2KCBeTBL(TudxihxbcTCOEoOPt11v02jiFxHmEaQZRawpcW8ju7hPFqFG)t2C(bdqfnOasrdib0bnaQigqbbGc6F8bI4)eziITy(pRrY)5mXcvczQ)ezdOAl)a)hypXi(pJDpcsGaCWJlF88gqnj4WICQmV6fHnTdoSirG)N7SuobM7F)t2C(bdqfnOasrdib0bnaQigqbbOaI)ytFCJ)ZPiNkZREhKXM2)Z4kN59V)jZq0FezA6mXcvczkAIaJ56mMcGittJDpcsGaCWJlF88gqnj4WICQmV6fHnTdoSirGtbqKPPdh5m5LX0eGccHPjav0GciPaqbqKPPb5X2gZqceuaezAsKOjc0CMZ00G0KaiafttEttzwBtLttgYREPjvb9afarMMejAAqESTXCMMCdhZUS00ed4imdHvVqAYBAcnasXs3WXSdduaezAsKOPbPox6IZ0eYWcXsugttEttJAmX0ezJzAInyPgGMgv(yAYhZ0KLZ9sGmKMkYiftYRBE1ln1AAsidx2vXbkaImnjs0ebAoZzAA6LQ8bOjcucSiWo8hvbD4d8FSiO)a)Gb6d8F41Uko)e9heUCgx2FUtToG6gNR1Colni0MkpmJOjGOjrGMUtToG6gNR1Colni0MkpGzsRwinrinbAae00GPPyuMMelMMUtToCvtSS1s3u9cdZiAciA6o16WvnXYwlDt1lmGzsRwinrinbAae00GPPyuMMi4)yiV69pK9g3nKL3Y53FWa0h4)WRDvC(j6piC5mUS)CNADa1noxR5CwAqOnvEygrtartIanDNADa1noxR5CwAqOnvEaZKwTqAIqAc0aiOPbttXOmnjwmnDNAD4QMyzRLUP6fgMr0eq00DQ1HRAILTw6MQxyaZKwTqAIqAc0aiOPbttXOmnrW)XqE17FWwK3yj0XfX87pyI6b(p8AxfNFI(dcxoJl7p6gnH00qAczqxI5yEPjcPjDJMWaPb4)yiV69pALTexBSe64Iy(9hSb9b(p8AxfNFI(dcxoJl7p6PsjXmASHJzPxKmnrinbAae00GPPyuMMaIM0nAcPPH0eYGUeZX8stest6gnHbsdW0KirtGk6)yiV69pexkLe1KK2MF)bdepW)Hx7Q48t0Fq4YzCz)r3OjKMgstid6smhZlnrinPB0egina)hd5vV)b6mRKo2IE)bdq8a)hETRIZpr)bHlNXL9hDJMqAAinHmOlXCmV0eH0KUrtyG0amnbenbsAYleX1gttartGKMUtToqYKnEazRLQjQYYmMnsyygrtartIanPNkLeZOXgoMLErY0eH0eObqqtdMMIrzAsSyAcK0uU9WOsL1fML3M8g8crCTX0eq0eiPP7uRdOUX5AnNZsdcTPYdZiAIG)JH8Q3)mQuzDHz5TjVV)GjIEG)dV2vX5NO)GWLZ4Y(diPPC7biJJ41LqV24GxiIRnMMaIMajnDNADa1noxR5CwAqOnvEyg9hd5vV)bY4iEDj0Rn(9hmr8d8F41Uko)e9heUCgx2F0nAcPPH0eYGUeZX8stest6gnHbsdW0eq0Kiqt3Pwhi7nUBil1t8abOBiIPjcPjqqtIftt6gnH0eH0KH8Q3azVXDdz5TCoGAOtte8FmKx9(hIlLsIAssBZV)GbiFG)dV2vX5NO)GWLZ4Y(dM1ygo2UkMMaIMajnDNADa1noxR5CwAqOnvEygrtart3Pwhi7nUBil1t8abOBiIPjcPjq8hd5vV)bY4iEDj0Rn(9hmqf9d8F41Uko)e9heUCgx2FajnDNADa1noxR5CwAqOnvEyg9hd5vV)XKKtCMXYwlr4Ee89hmqb9b(p8AxfNFI(dcxoJl7pGKMUtToG6gNR1Colni0MkpmJ(JH8Q3)G6gNR1Colni0Mk)9hmqb0h4)WRDvC(j6piC5mUS)CNADGS34UHSupXdeMr0KyX0KUrtinnKMqg0LyoMxAIGOjDJMWaPbyAsKOjqfnnjwmnDNADa1noxR5CwAqOnvEyg9hd5vV)HS34UHS8wo)(dgOI6b(pgYRE)d2I8glHoUiM)dV2vX5NO3FWaDqFG)dV2vX5NO)GWLZ4Y(diPjVqexB8FmKx9(NrLkRlmlVn5993)dsXMq8d8dgOpW)Hx7Q48t0F6O)azV0)XqE17FeYWLDv8FeYWY1i5)GmSqSeLX)bHlNXL9hd5LqSKxMSyinrinbI)iKPMSKvq(pG4pczQj)hd5LqSKxMSy47pya6d8FmKx9(htsoXzglBTeH7rW)WRDvC(j69hmr9a)hd5vV)b1noxR5CwAqOnv(F41Uko)e9(d2G(a)hETRIZpr)bHlNXL9NC7b4ySfTSsEBYBWleX1g)hd5vV)bzyH43FWaXd8F41Uko)e9heUCgx2Fajn5MIxpepzmUukt6gYlemWRDvCMMelMM0tLsIz0ydhZsVizAIqAkgL)JH8Q3)mQuzDHz5TjVV)GbiEG)dV2vX5NO)yiV69pK9g3nKL3Y5)GWLZ4Y(tMVtToOmNxxg1fS3a0neX0KaAcur)h0aiflDdhZo8bd03FWerpW)XqE17FqJnIXgj8p8AxfNFIE)bte)a)hETRIZpr)XqE17FiUukjQjjTn)heUCgx2F0nAcPPH0eYGUeZX8stest6gnHbsdW)bnasXs3WXSdFWa99hma5d8F41Uko)e9heUCgx2F0tLsIz0ydhZsVizAIqAkgLPjXIPjqstUP41dJkvwxywwREcREd8AxfNPjXIPPC7b4ySfTSsEBYBWleX1gttart52d16mEnL8QyoxBCa6gIyAIqAsu)XqE17FUthnMXd8(dgOI(b(p8AxfNFI(dcxoJl7pUP41dXtgJlLYKUH8cbd8AxfN)JH8Q3)GmSq87pyGc6d8F41Uko)e9heUCgx2F0nAcPPH0eYGUeZX8stest6gnHbsdW)XqE17F0kBjU2yj0XfX87pyGcOpW)Hx7Q48t0Fq4YzCz)j3EyuPY6cZYBtEdywJz4y7QyAsSyAYnfVEyuPY6cZYA1ty1BGx7Q48FmKx9(NrLkRlmlVn599hmqf1d8F41Uko)e9hd5vV)bY4iEDj0Rn(piC5mUS)CNADqOkIXqPq82KbmBi)pObqkw6goMD4dgOV)Gb6G(a)hETRIZpr)bHlNXL9hu3QCpAdJkvwxywEBYBaZKwTqAIGOjHmCzxfhqgwiwIYyAAqinbO)XqE17Fqgwi(9hmqbXd8FmKx9(hOZSs6yl6p8AxfNFIE)bduaXd8F41Uko)e9heUCgx2FCtXRhCgtcLTwYBSfZK86bETRIZ)XqE17FgB4OU33FWave9a)hETRIZpr)XqE17FGmoIxxc9AJ)dcxoJl7pywJz4y7QyAciA6o16GxrYwl9XSegXgoaDdrmnrinjQ)GgaPyPB4y2HpyG((dgOI4h4)WRDvC(j6pgYRE)dzVXDdz5TC(pObqkw6goMD4dgOV)GbkG8b(p8AxfNFI(JH8Q3)GTiVXsOJlI5)GgaPyPB4y2HpyG((7)b6pWpyG(a)hETRIZpr)bHlNXL9h3u86bNXKqzRL8gBXmjVEGx7Q48FmKx9(NXgoQ799hma9b(p8AxfNFI(dcxoJl7p6gnH00qAczqxI5yEPjcPjDJMWaPb4)yiV69pALTexBSe64Iy(9hmr9a)hETRIZpr)bHlNXL9N7uRdOUX5AnNZsdcTPYdZiAciAseOP7uRdOUX5AnNZsdcTPYdyM0QfstestGgabnnyAkgLPjXIPP7uRdx1elBT0nvVWWmIMaIMUtToCvtSS1s3u9cdyM0QfstestGgabnnyAkgLPjc(pgYRE)d2I8glHoUiMF)bBqFG)dV2vX5NO)GWLZ4Y(ZDQ1bu34CTMZzPbH2u5Hzenbenjc00DQ1bu34CTMZzPbH2u5bmtA1cPjcPjqdGGMgmnfJY0KyX00DQ1HRAILTw6MQxyygrtart3PwhUQjw2APBQEHbmtA1cPjcPjqdGGMgmnfJY0eb)hd5vV)HS34UHS8wo)(dgiEG)dV2vX5NO)GWLZ4Y(JUrtinnKMqg0LyoMxAIqAs3OjmqAa(pgYRE)dXLsjrnjPT53FWaepW)Hx7Q48t0Fq4YzCz)r3OjKMgstid6smhZlnrinPB0egina)hd5vV)b6mRKo2IE)bte9a)hETRIZpr)bHlNXL9hDJMqAAinHmOlXCmV0eH0KUrtyG0amnbenbsAYleX1gttartGKMUtToqYKnEazRLQjQYYmMnsyygrtartIanPNkLeZOXgoMLErY0eH0eObqqtdMMIrzAsSyAcK0uU9WOsL1fML3M8g8crCTX0eq0eiPP7uRdOUX5AnNZsdcTPYdZiAIG)JH8Q3)mQuzDHz5TjVV)GjIFG)dV2vX5NO)GWLZ4Y(ZDQ1bYEJ7gYs9epqa6gIyAIGOjqqtartGKMqDRY9OnG6gNR1Colni0MkpGzsRw4FmKx9(hYEJ7gYYB587pyaYh4)WRDvC(j6piC5mUS)CNADqOkIXqPq82KHzenbenLBpazCeVUe61ghWmPvlKMiKMguAAW0umkttIftt52dqghXRlHETXbmRXmCSDvmnbenbsA6o16aQBCUwZ5S0GqBQ8Wm6pgYRE)dKXr86sOxB87pyGk6h4)WRDvC(j6piC5mUS)asA6o16aQBCUwZ5S0GqBQ8Wm6pgYRE)JjjN4mJLTwIW9i47pyGc6d8F41Uko)e9heUCgx2FajnDNADa1noxR5CwAqOnvEyg9hd5vV)b1noxR5CwAqOnv(7pyGcOpW)Hx7Q48t0Fq4YzCz)5o16azVXDdzPEIhimJOjXIPjDJMqAAinHmOlXCmV0ebrt6gnHbsdW0KirtaQOPjGOj3u86bHQigdLcXBtg41UkottIftt6gnH00qAczqxI5yEPjcIM0nAcdKgGPjrIMaLMaIMCtXRhCgtcLTwYBSfZK86bETRIZ0KyX00DQ1bu34CTMZzPbH2u5Hz0FmKx9(hYEJ7gYYB587pyGkQh4)yiV69pylYBSe64Iy(p8AxfNFIE)bd0b9b(p8AxfNFI(dcxoJl7p52dJkvwxywEBYBaZAmdhBxf)hd5vV)zuPY6cZYBtEF)bduq8a)hETRIZpr)bHlNXL9N7uRdcvrmgkfI3MmmJ(JH8Q3)azCeVUe61g)(7)zKUEGFWa9b(p8AxfNFI(dcxoJl7p6gnH00qAczqxI5yEPjcPjDJMWaPbyAciAYnfVEWzmju2AjVXwmtYRh41Uko)hd5vV)zSHJ6EF)bdqFG)dV2vX5NO)GWLZ4Y(ZDQ1HRAILTw6MQxyygrtart3PwhUQjw2APBQEHbmtA1cPjcPPyu(pgYRE)dzVXDdz5TC(9hmr9a)hETRIZpr)bHlNXL9N7uRdx1elBT0nvVWWmIMaIMUtToCvtSS1s3u9cdyM0QfstestXO8FmKx9(hSf5nwcDCrm)(d2G(a)hETRIZpr)bHlNXL9N7uRdcvrmgkfI3MmmJOjGOP7uRdcvrmgkfI3MmGzsRwinrinbAae00GPPyuMMelMMajnLBpazCeVUe61gh8crCTX)XqE17FGmoIxxc9AJF)bdepW)Hx7Q48t0Fq4YzCz)rpvkjMrJnCml9IKPjcPjqdGGMgmnfJY0eq0KUrtinnKMqg0LyoMxAIqAs3OjmqAaMMelMMebAAza7YrL82K3GqTY8sX0eq0uU9aKXr86sOxBCWleX1gttart52dqghXRlHETXbmRXmCSDvmnjwmnTmGD5OsEBYBiAmJBYEzAciAcK00DQ1bYEJ7gYs9epqygrtart6gnH00qAczqxI5yEPjcPjDJMWaPbyAsKOjd5vVbIlLsIAssBZbKbDjMJ5LMgmnjkAIG)JH8Q3)mQuzDHz5TjVV)GbiEG)dV2vX5NO)GWLZ4Y(JUrtinnKMqg0LyoMxAIqAs3OjmqAaMMejAs3OjmG5yE)JH8Q3)qCPusutsAB(9hmr0d8FmKx9(htsoXzglBTeH7rW)WRDvC(j69hmr8d8F41Uko)e9heUCgx2F0nAcPPH0eYGUeZX8stest6gnHbsdW)XqE17FGoZkPJTO3FWaKpW)Hx7Q48t0Fq4YzCz)rpvkjMrJnCml9IKPjcPjqdGGMgmnfJY)XqE17FgvQSUWS82K33FWav0pW)XqE17FqDJZ1AoNLgeAtL)hETRIZprV)GbkOpW)Hx7Q48t0Fq4YzCz)5o16GqveJHsH4TjdZiAciAk3EaY4iEDj0RnoGzsRwinrinnO00GPPyu(pgYRE)dKXr86sOxB87pyGcOpW)Hx7Q48t0Fq4YzCz)j3EaogBrlRK3M8g8crCTX0KyX00DQ1bYEJ7gYs9epqa6gIyAsanbI)yiV69pK9g3nKL3Y53FWavupW)Hx7Q48t0Fq4YzCz)zza7YrL82K3aCm2Iwwrtart52dqghXRlHETXbmtA1cPjcIMabnnyAkgL)JH8Q3)mQuzDHz5TjVV)Gb6G(a)hETRIZpr)bHlNXL9hmRXmCSDv8FmKx9(hiJJ41LqV243FWafepW)Hx7Q48t0Fq4YzCz)bK00DQ1bYEJ7gYs9epqaZKwTW)yiV69pOXgXyJe((dgOaIh4)yiV69pK9g3nKL3Y5)WRDvC(j69hmqfrpW)XqE17FWwK3yj0XfX8F41Uko)e9(dgOI4h4)WRDvC(j6piC5mUS)CNADqOkIXqPq82KHz0FmKx9(hiJJ41LqV243FWafq(a)hETRIZpr)bHlNXL9NLbSlhvYBtEdc1kZlfttart52dqghXRlHETXbVqexBmnjwmnTmGD5OsEBYBiAmJBYEzAsSyAAza7YrL82K3aCm2Iww9hd5vV)zuPY6cZYBtEF)9)yrJ01d8dgOpW)Hx7Q48t0Fq4YzCz)5o16WvnXYwlDt1lmmJOjGOP7uRdx1elBT0nvVWaMjTAH0eH0umk)hd5vV)HS34UHS8wo)(dgG(a)hETRIZpr)bHlNXL9N7uRdx1elBT0nvVWWmIMaIMUtToCvtSS1s3u9cdyM0QfstestXO8FmKx9(hSf5nwcDCrm)(dMOEG)dV2vX5NO)GWLZ4Y(diPPC7biJJ41LqV24GxiIRn(pgYRE)dKXr86sOxB87pyd6d8FmKx9(htsoXzglBTeH7rW)WRDvC(j69hmq8a)hETRIZpr)bHlNXL9h9uPKygn2WXS0lsMMiKManacAAW0umkttIftt6gnH00qAczqxI5yEPjcPjDJMWaPbyAciAseOPLbSlhvYBtEdc1kZlfttart52dqghXRlHETXbVqexBmnbenLBpazCeVUe61ghWSgZWX2vX0KyX00Ya2LJk5TjVHOXmUj7LPjGOjqst3Pwhi7nUBil1t8aHzenbenPB0estdPjKbDjMJ5LMiKM0nAcdKgGPjrIMmKx9giUukjQjjTnhqg0LyoMxAAW0KOOjc(pgYRE)ZOsL1fML3M8((dgG4b(pgYRE)dQBCUwZ5S0GqBQ8)WRDvC(j69hmr0d8F41Uko)e9heUCgx2FUtToq2BC3qwQN4bcyM0QfstartldyxoQK3M8gIgZ4MSx(pgYRE)dzVXDdz5TC(9hmr8d8F41Uko)e9heUCgx2F0tLsIz0ydhZsVizAIqAc0aiOPbttXOmnbenPB0estdPjKbDjMJ5LMiKM0nAcdKgGPjrIMaur)hd5vV)H4sPKOMK0287pyaYh4)WRDvC(j6piC5mUS)OB0estdPjKbDjMJ5LMiKM0nAcdKgG)JH8Q3)aDMvshBrV)GbQOFG)dV2vX5NO)GWLZ4Y(ZDQ1bVIKTw6JzjmInCa6gIyAsanjkAsSyAk3EaogBrlRK3M8g8crCTX)XqE17FWwK3yj0XfX87pyGc6d8F41Uko)e9heUCgx2FYThGJXw0Yk5TjVbVqexB8FmKx9(hYEJ7gYYB587pyGcOpW)Hx7Q48t0Fq4YzCz)zza7YrL82K3aCm2Iwwrtart6gnH0ebrtIs00eq0uU9aKXr86sOxBCaZKwTqAIGOjqqtdMMIr5)yiV69pJkvwxywEBY77pyGkQh4)WRDvC(j6piC5mUS)asA6o16azVXDdzPEIhiGzsRw4FmKx9(h0yJySrcF)bd0b9b(p8AxfNFI(dcxoJl7pywJz4y7Q4)yiV69pqghXRlHETXV)GbkiEG)dV2vX5NO)GWLZ4Y(JUrtinnKMqg0LyoMxAIqAs3OjmqAaMMaIMebA6o16azVXDdzPEIhiaDdrmnrinbcAsSyAs3OjKMiKMmKx9gi7nUBilVLZbudDAIG)JH8Q3)qCPusutsAB(9hmqbepW)XqE17FWwK3yj0XfX8F41Uko)e9(dgOIOh4)WRDvC(j6piC5mUS)CNADGS34UHSupXdeMr0KyX0KUrtinrq00GkAAsSyAk3EaogBrlRK3M8g8crCTX)XqE17Fi7nUBilVLZV)GbQi(b(p8AxfNFI(dcxoJl7pldyxoQK3M8geQvMxkMMaIMYThGmoIxxc9AJdEHiU2yAsSyAAza7YrL82K3q0yg3K9Y0KyX00Ya2LJk5TjVb4ySfTSIMaIM0nAcPjcIMaHO)JH8Q3)mQuzDHz5TjVV)(FIWmQjVM)a)Gb6d8FmKx9(h4KKSxze7)Hx7Q48t07pya6d8FmKx9(NO2RE)dV2vX5NO3FWe1d8F41Uko)e9N1i5)yeaCSHnOu3RlBTmQhX4)yiV69pgbahBydk196YwlJ6rm(9hSb9b(p8AxfNFI(JH8Q3)GgaPAh3BHKxLb9)GWLZ4Y(diPjSvzjleVEOwHMQLX2vXbgWf0H)H1Ag5Y1i5)GgaPAh3BHKxLb93FWaXd8FmKx9(N4PHZLTYwlncGXTp(p8AxfNFIE)bdq8a)hd5vV)b6mRKo2I(dV2vX5NO3FWerpW)XqE17FgB4OU3)WRDvC(j693)dkdFGFWa9b(p8AxfNFI(dcxoJl7pOUv5E0gqDJZ1AoNLgeAtLhWmPvlKMiiAsuI(pgYRE)Zv1DwQN4bE)bdqFG)dV2vX5NO)GWLZ4Y(dQBvUhTbu34CTMZzPbH2u5bmtA1cPjcIMeLO)JH8Q3)ylIHo2usKPuV)GjQh4)WRDvC(j6piC5mUS)G6wL7rBa1noxR5CwAqOnvEaZKwTqAIGOjrj6)yiV69p6cZxv353FWg0h4)yiV69pQkESdLe4ZCmjV(F41Uko)e9(dgiEG)dV2vX5NO)GWLZ4Y(dQBvUhTbu34CTMZzPbH2u5bmtA1cPjcIMaeIMMelMM8IKLElZfttestGkQ)yiV69pxgdzmX1g)(dgG4b(p8AxfNFI(dcxoJl7p3PwhINgox2kBT0iag3(4WmIMaIMebA6o16WLXqgtCTXHzenjwmnDNAD4Q6ol1t8aHzenjwmnbsAcBio44wPOjcMMelMMebAc1lCsAxfhIAV6v2A5CV4kR4SupXdqtartErYsVL5IPjcPjabO0KyX0KxKS0BzUyAIqAcqbe0ebttIfttGKMyiKxehq9M5fYzPQ0SUXioqAe4nMMaIMUtToG6gNR1Colni0MkpmJ(JH8Q3)e1E177pyIOh4)WRDvC(j6piC5mUS)4goM9qUGUTiMMiib0eG4pgYRE)JbJyKlBT0hZs2Iv87pyI4h4)WRDvC(j6pgYRE)JbhlKTmuIncOXsuJn1Fq4YzCz)HheNvueNdzCDVQAJL1sCuNPjGOjrGMY8DQ1bSranwIASPKz(o16qUhT0KyX0KxKS0BzeYLIs00eH0eO0KyX0KiqtJzt5JdriNMiKMeLOPjGOP7uRdXtdNlBLTwAeaJBFCygrtIftt3PwhizYgpGS1s1evzzgZgjmmJOjcMMiyAsSyAseOjqst8G4SII4CiJR7vvBSSwIJ6mnbenjc00DQ1bsMSXdiBTunrvwMXSrcdZiAsSyA6o16q80W5YwzRLgbW42hhMr0eq0eQBvUhTH4PHZLTYwlncGXTpoGzsRwinrq0eOIiqqtemnjwmnL57uRdyJaASe1ytjZ8DQ1HCpAPjcMMelMM8IKLElZfttestaQO)ZAK8Fm4yHSLHsSranwIASPE)bdq(a)hETRIZpr)XqE17FInfJmLIXq5T79piC5mUS)G6wL7rBGKjB8aYwlvtuLLzmBKWaMjTAH0KyX0KBkE9WOsL1fML1QNWQ3aV2vXzAciAc1Tk3J2aQBCUwZ5S0GqBQ8aMjTAH0KyX0eQBvUhTb0aiv74ElK8QmOhWmPvlKMelMMajnXqiVioqYKnEazRLQjQYYmMnsyG0iWBmnbenH6wL7rBa1noxR5CwAqOnvEaZKwTW)Sgj)NytXitPymuE7EF)bdur)a)hETRIZpr)zns(pgbahBydk196YwlJ6rm(pgYRE)JraWXg2GsDVUS1YOEeJF)bduqFG)JH8Q3)OB0eYzPramUCwEzJ8p8AxfNFIE)bdua9b(p8AxfNFI(dcxoJl7p6gnH0eH0KUrtyG0amnjs0KOennbenDNADa1noxR5CwAqOnvEyg9hd5vV)HKjB8aYwlvtuLLzmBKW3FWavupW)Hx7Q48t0Fq4YzCz)5o16aQBCUwZ5S0GqBQ8Wm6pgYRE)Zv1Dw2APpML8YKd8(dgOd6d8FmKx9(NOjU0duBS8QmO)hETRIZprV)GbkiEG)JH8Q3)epnCUSv2APramU9X)Hx7Q48t07pyGciEG)JH8Q3)GROiflRvcJme)hETRIZprV)GbQi6b(p8AxfNFI(dcxoJl7p6PsjXmASHJzPxKmnrinbknnyAkgL)JH8Q3)G6fXRJnNZsTYi53FWave)a)hETRIZpr)bHlNXL9N7uRdygrSIHqPUXiomJ(JH8Q3)4Jz5CV9CZsDJr87pyGciFG)JH8Q3)mQXQSqCTsmd71we)hETRIZprV)(FYS2Mk)b(bd0h4)WRDvC(j6piC5mUS)K57uRdid61ghMr0KyX0uMVtToKlyeRu2vXsslUqHzenjwmnL57uRd5cgXkLDvSKxSfZHz0FmKx9(hKPusd5vVsvb9)OkOlxJK)Z0lv5d8(dgG(a)hd5vV)zczz5mj8p8AxfNFIE)btupW)Hx7Q48t0FmKx9(hKPusd5vVsvb9)OkOlxJK)dkdF)bBqFG)dV2vX5NO)GWLZ4Y(JH8siwYltwmKMiKMefnben5MIxpGgBeJnsyGx7Q4mnben5MIxpyQOXMmcZzZBCGx7Q48FmKx9(hKPusd5vVsvb9)OkOlxJK)JfnsxV)GbIh4)WRDvC(j6piC5mUS)yiVeIL8YKfdPjcPjrrtartUP41dOXgXyJeg41Uko)hd5vV)bzkL0qE1Ruvq)pQc6Y1i5)msxV)GbiEG)dV2vX5NO)GWLZ4Y(JH8siwYltwmKMiKMefnbenbsAYnfVEWurJnzeMZM34aV2vXzAciAcK0KBkE9WOsL1fML1QNWQ3aV2vX5)yiV69pitPKgYRELQc6)rvqxUgj)hO)(dMi6b(p8AxfNFI(dcxoJl7pgYlHyjVmzXqAIqAsu0eq0KBkE9GPIgBYimNnVXbETRIZ0eq0eiPj3u86HrLkRlmlRvpHvVbETRIZ)XqE17FqMsjnKx9kvf0)JQGUCns(pwe0F)bte)a)hETRIZpr)bHlNXL9hd5LqSKxMSyinrinjkAciAYnfVEWurJnzeMZM34aV2vXzAciAYnfVEyuPY6cZYA1ty1BGx7Q48FmKx9(hKPusd5vVsvb9)OkOlxJK)JfnsxV)GbiFG)dV2vX5NO)GWLZ4Y(JH8siwYltwmKMiKMefnbenbsAYnfVEWurJnzeMZM34aV2vXzAciAYnfVEyuPY6cZYA1ty1BGx7Q48FmKx9(hKPusd5vVsvb9)OkOlxJK)ZiD9(dgOI(b(p8AxfNFI(dcxoJl7pgYlHyjVmzXqAIGOjq)JH8Q3)GmLsAiV6vQkO)hvbD5AK8Fqk2eIF)bduqFG)JH8Q3)G6fXRJnNZsTYi5)WRDvC(j69hmqb0h4)yiV69pggzll9gJ51)dV2vX5NO3F)ptVuLpWd8dgOpW)XqE17FiNeabO4)WRDvC(j69hma9b(pgYRE)dKX8w(aY8e6)Hx7Q48t07pyI6b(pgYRE)dmQXSeP6z(p8AxfNFIE)bBqFG)JH8Q3)a72hxBSCK5m(p8AxfNFIE)bdepW)XqE17FG9wi5vzq)p8AxfNFIE)bdq8a)hd5vV)zzFmJLWXnI4)WRDvC(j69hmr0d8FmKx9(h04IaVGshB7G4SuLpWF41Uko)e9(dMi(b(pgYRE)dmQWLlHJBeX)Hx7Q48t07pyaYh4)yiV69pR5tmdLXydX)Hx7Q48t07V)(FeIXWQ3hmav0GcifnGeqf9Fgz4T2y4FiWKmQXoNPjajnziV6LMuf0Hbka)jc36sX)rKPPZelujKPOjcmMRZykaImnn29iibcWbpU8XZBa1KGdlYPY8Qxe20o4WIebofarMMoCKZKxgttakieMMaurdkGKcafarMMgKhBBmdjqqbqKPjrIMiqZzottdstcGaumn5nnLzTnvonziV6LMuf0duaezAsKOPb5X2gZzAYnCm7YsttmGJWmew9cPjVPj0aiflDdhZomqbqKPjrIMgK6CPlottidlelrzmn5nnnQXettKnMPj2GLAaAAu5JPjFmttwo3lbYqAQiJumjVU5vV0uRPjHmCzxfhOaiY0KirteO5mNPPPxQYhGMiqjWIa7afakaImnniaWmA6CMMUSUXmnHAYR500LJRfgOjcueIJCinT9ksJnmPEQOjd5vVqAQx1abkaImnziV6fgIWmQjVMlqRmiXuaezAYqE1lmeHzutEnFOaWTzmjVU5vVuaezAYqE1lmeHzutEnFOaW1DNPayiV6fgIWmQjVMpua4WjjzVYi2PaiY00zTi442PjSvzA6o1Aottq3CinDzDJzAc1KxZPPlhxlKMSnttrywKIA3RnMMkinL7LduaezAYqE1lmeHzutEnFOaWHRfbh3Ue6MdPayiV6fgIWmQjVMpua4rTx9sbWqE1lmeHzutEnFOaWNqwwotk8AKSaJaGJnSbL6EDzRLr9igtbWqE1lmeHzutEnFOaWNqwwotkmR1mYLRrYcqdGuTJ7TqYRYGUWLwaiXwLLSq86HAfAQwgBxfhyaxqhsbWqE1lmeHzutEnFOaWJNgox2kBT0iag3(ykagYREHHimJAYR5dfao0zwjDSfrbWqE1lmeHzutEnFOaWhB4OUxkauamKx9cdtVuLpGaYjbqakMcGH8Qxyy6LQ8bgkaCiJ5T8bK5j0PayiV6fgMEPkFGHcahg1ywIu9mtbWqE1lmm9sv(adfaoSBFCTXYrMZykagYREHHPxQYhyOaWH9wi5vzqNcGH8Qxyy6LQ8bgka8L9Xmwch3iIPayiV6fgMEPkFGHcahnUiWlO0X2oiolv5dqbWqE1lmm9sv(adfaomQWLlHJBeXuamKx9cdtVuLpWqbGVMpXmugJnetbGcGittdcamJMoNPjwigpan5fjtt(yMMmK3yAQG0KjKvk7Q4afad5vVqbitPKgYRELQc6cVgjly6LQ8beU0cY8DQ1bKb9AJdZiXIZ8DQ1HCbJyLYUkwsAXfkmJeloZ3PwhYfmIvk7QyjVylMdZikagYREHdfa(eYYYzsifad5vVWHcahzkL0qE1Ruvqx41izbOmKcGH8Qx4qbGJmLsAiV6vQkOl8AKSalAKUeU0cmKxcXsEzYIHekkGCtXRhqJnIXgjmWRDvCgi3u86btfn2KryoBEJd8AxfNPayiV6foua4itPKgYRELQc6cVgjlyKUeU0cmKxcXsEzYIHekkGCtXRhqJnIXgjmWRDvCMcGH8Qx4qbGJmLsAiV6vQkOl8AKSaOlCPfyiVeIL8YKfdjuuabs3u86btfn2KryoBEJd8AxfNbcKUP41dJkvwxywwREcREd8AxfNPayiV6foua4itPKgYRELQc6cVgjlWIGUWLwGH8siwYltwmKqrbKBkE9GPIgBYimNnVXbETRIZabs3u86HrLkRlmlRvpHvVbETRIZuamKx9chkaCKPusd5vVsvbDHxJKfyrJ0LWLwGH8siwYltwmKqrbKBkE9GPIgBYimNnVXbETRIZa5MIxpmQuzDHzzT6jS6nWRDvCMcGH8Qx4qbGJmLsAiV6vQkOl8AKSGr6s4slWqEjel5LjlgsOOacKUP41dMkASjJWC28gh41UkodKBkE9WOsL1fML1QNWQ3aV2vXzkagYREHdfaoYukPH8QxPQGUWRrYcqk2eIfU0cmKxcXsEzYIHeeOuamKx9chkaCuViEDS5CwQvgjtbWqE1lCOaWnmYww6ngZRtbGcGH8QxyWIGUaYEJ7gYYB5SWLwWDQ1bu34CTMZzPbH2u5HzeqIWDQ1bu34CTMZzPbH2u5bmtA1cje0aigCmklw8DQ1HRAILTw6MQxyygb0DQ1HRAILTw6MQxyaZKwTqcbnaIbhJYemfad5vVWGfb9HcahBrEJLqhxeZcxAb3PwhqDJZ1AoNLgeAtLhMrajc3PwhqDJZ1AoNLgeAtLhWmPvlKqqdGyWXOSyX3PwhUQjw2APBQEHHzeq3PwhUQjw2APBQEHbmtA1cje0aigCmktWuamKx9cdwe0hkaCTYwIRnwcDCrmlCPfOB0eoezqxI5yEju3OjmqAaMcGH8QxyWIG(qbGtCPusutsABw4slqpvkjMrJnCml9IKje0aigCmkdKUrt4qKbDjMJ5LqDJMWaPbyrcurtbWqE1lmyrqFOaWHoZkPJTiHlTaDJMWHid6smhZlH6gnHbsdWuamKx9cdwe0hka8rLkRlmlVn5v4slq3OjCiYGUeZX8sOUrtyG0amqG0leX1gdeiVtToqYKnEazRLQjQYYmMnsyygbKiONkLeZOXgoMLErYecAaedogLflgK52dJkvwxywEBYBWleX1gdeiVtToG6gNR1Colni0MkpmJiykagYREHblc6dfaoKXr86sOxBSWLwaiZThGmoIxxc9AJdEHiU2yGa5DQ1bu34CTMZzPbH2u5Hzefad5vVWGfb9HcaN4sPKOMK02SWLwGUrt4qKbDjMJ5LqDJMWaPbyGeH7uRdK9g3nKL6jEGa0neXeccXI1nAcj0qE1BGS34UHS8wohqn0jykagYREHblc6dfaoKXr86sOxBSWLwaM1ygo2UkgiqENADa1noxR5CwAqOnvEygb0DQ1bYEJ7gYs9epqa6gIycbbfad5vVWGfb9Hca3KKtCMXYwlr4Eeu4slaK3PwhqDJZ1AoNLgeAtLhMruamKx9cdwe0hkaCu34CTMZzPbH2u5cxAbG8o16aQBCUwZ5S0GqBQ8WmIcGH8QxyWIG(qbGt2BC3qwElNfU0cUtToq2BC3qwQN4bcZiXI1nAchImOlXCmVeKUrtyG0aSibQOfl(o16aQBCUwZ5S0GqBQ8WmIcGH8QxyWIG(qbGJTiVXsOJlIzkagYREHblc6dfa(OsL1fML3M8kCPfasVqexBmfakagYREHblAKUeq2BC3qwElNfU0cUtToCvtSS1s3u9cdZiGUtToCvtSS1s3u9cdyM0QfsymktbWqE1lmyrJ01qbGJTiVXsOJlIzHlTG7uRdx1elBT0nvVWWmcO7uRdx1elBT0nvVWaMjTAHegJYuamKx9cdw0iDnua4qghXRlHETXcxAbGm3EaY4iEDj0Rno4fI4AJPayiV6fgSOr6AOaWnj5eNzSS1seUhbPayiV6fgSOr6AOaWhvQSUWS82KxHlTa9uPKygn2WXS0lsMqqdGyWXOSyX6gnHdrg0LyoMxc1nAcdKgGbsewgWUCujVn5niuRmVumq52dqghXRlHETXbVqexBmq52dqghXRlHETXbmRXmCSDvSyXldyxoQK3M8gIgZ4MSxgiqENADGS34UHSupXdeMraPB0eoezqxI5yEju3OjmqAawKmKx9giUukjQjjTnhqg0LyoM3blkcMcGH8QxyWIgPRHcah1noxR5CwAqOnvofad5vVWGfnsxdfaozVXDdz5TCw4sl4o16azVXDdzPEIhiGzsRwiqldyxoQK3M8gIgZ4MSxMcGH8QxyWIgPRHcaN4sPKOMK02SWLwGEQusmJgB4yw6fjtiObqm4yugiDJMWHid6smhZlH6gnHbsdWIeGkAkagYREHblAKUgkaCOZSs6yls4slq3OjCiYGUeZX8sOUrtyG0amfad5vVWGfnsxdfao2I8glHoUiMfU0cUtTo4vKS1sFmlHrSHdq3qelquIfNBpahJTOLvYBtEdEHiU2ykagYREHblAKUgkaCYEJ7gYYB5SWLwqU9aCm2IwwjVn5n4fI4AJPayiV6fgSOr6AOaWhvQSUWS82KxHlTGLbSlhvYBtEdWXylAzfq6gnHeKOenq52dqghXRlHETXbmtA1cjiqm4yuMcGH8QxyWIgPRHcahn2igBKqHlTaqENADGS34UHSupXdeWmPvlKcGH8QxyWIgPRHcahY4iEDj0Rnw4slaZAmdhBxftbWqE1lmyrJ01qbGtCPusutsABw4slq3OjCiYGUeZX8sOUrtyG0amqIWDQ1bYEJ7gYs9epqa6gIycbHyX6gnHeAiV6nq2BC3qwElNdOg6emfad5vVWGfnsxdfao2I8glHoUiMPayiV6fgSOr6AOaWj7nUBilVLZcxAb3Pwhi7nUBil1t8aHzKyX6gnHe0GkAXIZThGJXw0Yk5TjVbVqexBmfad5vVWGfnsxdfa(OsL1fML3M8kCPfSmGD5OsEBYBqOwzEPyGYThGmoIxxc9AJdEHiU2yXIxgWUCujVn5nenMXnzVSyXldyxoQK3M8gGJXw0YkG0nAcjiqiAkauamKx9cdOmuWv1DwQN4beU0cqDRY9OnG6gNR1Colni0MkpGzsRwibjkrtbWqE1lmGYWHca3wedDSPKitPeU0cqDRY9OnG6gNR1Colni0MkpGzsRwibjkrtbWqE1lmGYWHcaxxy(Q6olCPfG6wL7rBa1noxR5CwAqOnvEaZKwTqcsuIMcGH8QxyaLHdfaUQIh7qjb(mhtYRtbWqE1lmGYWHca)YyiJjU2yHlTau3QCpAdOUX5AnNZsdcTPYdyM0QfsqacrlwSxKS0BzUycbvuuamKx9cdOmCOaWJAV6v4sl4o16q80W5YwzRLgbW42hhMrajc3PwhUmgYyIRnomJel(o16Wv1DwQN4bcZiXIbj2qCWXTsrWIflcOEHts7Q4qu7vVYwlN7fxzfNL6jEaG8IKLElZftiGauXI9IKLElZftiGciiyXIbjdH8I4aQ3mVqolvLM1ngXbsJaVXaDNADa1noxR5CwAqOnvEygrbWqE1lmGYWHca3GrmYLTw6JzjBXkw4slWnCm7HCbDBrmbjaqqbWqE1lmGYWHcaFczz5mPWRrYcm4yHSLHsSranwIASPeU0c4bXzffX5qgx3RQ2yzTeh1zGeHmFNADaBeqJLOgBkzMVtToK7rRyXErYsVLrixkkrtiOIflcJzt5JdriNqrjAGUtToepnCUSv2APramU9XHzKyX3PwhizYgpGS1s1evzzgZgjmmJiycwSyraK8G4SII4CiJR7vvBSSwIJ6mqIWDQ1bsMSXdiBTunrvwMXSrcdZiXIVtToepnCUSv2APramU9XHzeqOUv5E0gINgox2kBT0iag3(4aMjTAHeeOIiqqWIfN57uRdyJaASe1ytjZ8DQ1HCpAjyXI9IKLElZftiGkAkagYREHbugoua4tillNjfEnswqSPyKPumgkVDVcxAbOUv5E0gizYgpGS1s1evzzgZgjmGzsRwOyXUP41dJkvwxywwREcREd8AxfNbc1Tk3J2aQBCUwZ5S0GqBQ8aMjTAHIfJ6wL7rBanas1oU3cjVkd6bmtA1cflgKmeYlIdKmzJhq2APAIQSmJzJeginc8gdeQBvUhTbu34CTMZzPbH2u5bmtA1cPayiV6fgqz4qbGpHSSCMu41izbgbahBydk196YwlJ6rmMcGH8QxyaLHdfaUUrtiNLgbW4Yz5LnskagYREHbugoua4KmzJhq2APAIQSmJzJekCPfOB0esOUrtyG0aSijkrd0DQ1bu34CTMZzPbH2u5Hzefad5vVWakdhka8RQ7SS1sFml5Ljhq4sl4o16aQBCUwZ5S0GqBQ8WmIcGH8QxyaLHdfaE0ex6bQnwEvg0PayiV6fgqz4qbGhpnCUSv2APramU9XuamKx9cdOmCOaWXvuKIL1kHrgIPayiV6fgqz4qbGJ6fXRJnNZsTYizHlTa9uPKygn2WXS0lsMqqhCmktbWqE1lmGYWHca3hZY5E75ML6gJyHlTG7uRdygrSIHqPUXiomJOayiV6fgqz4qbGpQXQSqCTsmd71wetbGcGH8QxyaPytiwGqgUSRIfEnswaYWcXsuglChjaYEPfwitnzbgYlHyjVmzXqHfYutwYkilaecJ6nxE1Rad5LqSKxMSyiHGGcGH8QxyaPytiEOaWnj5eNzSS1seUhbPayiV6fgqk2eIhkaCu34CTMZzPbH2u5uamKx9cdifBcXdfaoYWcXcxAb52dWXylAzL82K3GxiIRnMcGH8QxyaPytiEOaWhvQSUWS82KxHlTaq6MIxpepzmUukt6gYlemWRDvCwSy9uPKygn2WXS0lsMWyuMcGH8QxyaPytiEOaWj7nUBilVLZcJgaPyPB4y2Hcav4sliZ3PwhuMZRlJ6c2Ba6gIybGkAkagYREHbKInH4Hcahn2igBKqkagYREHbKInH4HcaN4sPKOMK02SWObqkw6goMDOaqfU0c0nAchImOlXCmVeQB0eginatbWqE1lmGuSjepua43PJgZ4beU0c0tLsIz0ydhZsVizcJrzXIbPBkE9WOsL1fML1QNWQ3aV2vXzXIZThGJXw0Yk5TjVbVqexBmq52d16mEnL8QyoxBCa6gIycfffad5vVWasXMq8qbGJmSqSWLwGBkE9q8KX4sPmPBiVqWaV2vXzkagYREHbKInH4HcaxRSL4AJLqhxeZcxAb6gnHdrg0LyoMxc1nAcdKgGPayiV6fgqk2eIhka8rLkRlmlVn5v4sli3EyuPY6cZYBtEdywJz4y7QyXIDtXRhgvQSUWSSw9ew9g41UkotbWqE1lmGuSjepua4qghXRlHETXcJgaPyPB4y2Hcav4sl4o16GqveJHsH4Tjdy2qofad5vVWasXMq8qbGJmSqSWLwaQBvUhTHrLkRlmlVn5nGzsRwibjKHl7Q4aYWcXsugpieqPayiV6fgqk2eIhkaCOZSs6ylIcGH8QxyaPytiEOaWhB4OUxHlTa3u86bNXKqzRL8gBXmjVEGx7Q4mfad5vVWasXMq8qbGdzCeVUe61glmAaKILUHJzhkauHlTamRXmCSDvmq3Pwh8ks2APpMLWi2WbOBiIjuuuaezAc4MMGf5uzotttOfZ0KUX00GuVXDdzAIOYzAQX0ebswK3yA644IyMMYtCTX0ebkmIron1AAYhZ00GalwXcttOoAaAIn0yAQrOjgZlIPPwtt(yMMmKx9st2MPjlkI3mnjzlwX0K30KpMPjd5vV00AKCGcGH8QxyaPytiEOaWj7nUBilVLZcJgaPyPB4y2HcaLcGH8QxyaPytiEOaWXwK3yj0XfXSWObqkw6goMDOaqPaqbWqE1lmaDbJnCu3RWLwGBkE9GZysOS1sEJTyMKxpWRDvCMcGH8Qxya6dfaUwzlX1glHoUiMfU0c0nAchImOlXCmVeQB0eginatbWqE1lma9HcahBrEJLqhxeZcxAb3PwhqDJZ1AoNLgeAtLhMrajc3PwhqDJZ1AoNLgeAtLhWmPvlKqqdGyWXOSyX3PwhUQjw2APBQEHHzeq3PwhUQjw2APBQEHbmtA1cje0aigCmktWuaezAc4MMGf5uzotttOfZ0KUX00GuVXDdzAIOYzAQX0ebswK3yA644IyMMYtCTX0ebkmIron1AAYhZ00GalwXcttOoAaAIn0yAQrOjgZlIPPwtt(yMMmKx9st2MPjlkI3mnjzlwX0K30KpMPjd5vV00AKCGcGH8Qxya6dfaozVXDdz5TCw4sl4o16aQBCUwZ5S0GqBQ8Wmcir4o16aQBCUwZ5S0GqBQ8aMjTAHecAaedogLfl(o16WvnXYwlDt1lmmJa6o16WvnXYwlDt1lmGzsRwiHGgaXGJrzcMcGH8Qxya6dfaoXLsjrnjPTzHlTaDJMWHid6smhZlH6gnHbsdWuamKx9cdqFOaWHoZkPJTiHlTaDJMWHid6smhZlH6gnHbsdWuamKx9cdqFOaWhvQSUWS82KxHlTaDJMWHid6smhZlH6gnHbsdWabsVqexBmqG8o16ajt24bKTwQMOklZy2iHHzeqIGEQusmJgB4yw6fjtiObqm4yuwSyqMBpmQuzDHz5TjVbVqexBmqG8o16aQBCUwZ5S0GqBQ8WmIGPayiV6fgG(qbGt2BC3qwElNfU0cUtToq2BC3qwQN4bcq3qetqGaiqI6wL7rBa1noxR5CwAqOnvEaZKwTqkagYREHbOpua4qghXRlHETXcxAb3PwheQIymukeVnzygbuU9aKXr86sOxBCaZKwTqch0bhJYIfNBpazCeVUe61ghWSgZWX2vXabY7uRdOUX5AnNZsdcTPYdZikagYREHbOpua4MKCIZmw2Ajc3JGcxAbG8o16aQBCUwZ5S0GqBQ8WmIcGH8Qxya6dfaoQBCUwZ5S0GqBQCHlTaqENADa1noxR5CwAqOnvEygrbWqE1lma9HcaNS34UHS8wolCPfCNADGS34UHSupXdeMrIfRB0eoezqxI5yEjiDJMWaPbyrcqfnqUP41dcvrmgkfI3MmWRDvCwSyDJMWHid6smhZlbPB0eginalsGcKBkE9GZysOS1sEJTyMKxpWRDvCwS47uRdOUX5AnNZsdcTPYdZikagYREHbOpua4ylYBSe64IyMcGH8Qxya6dfa(OsL1fML3M8kCPfKBpmQuzDHz5TjVbmRXmCSDvmfad5vVWa0hkaCiJJ41LqV2yHlTG7uRdcvrmgkfI3MmmJOaqbWqE1lmmsxcgB4OUxHlTaDJMWHid6smhZlH6gnHbsdWa5MIxp4mMekBTK3ylMj51d8AxfNPayiV6fggPRHcaNS34UHS8wolCPfCNAD4QMyzRLUP6fgMraDNAD4QMyzRLUP6fgWmPvlKWyuMcGH8QxyyKUgkaCSf5nwcDCrmlCPfCNAD4QMyzRLUP6fgMraDNAD4QMyzRLUP6fgWmPvlKWyuMcGH8QxyyKUgkaCiJJ41LqV2yHlTG7uRdcvrmgkfI3MmmJa6o16GqveJHsH4TjdyM0QfsiObqm4yuwSyqMBpazCeVUe61gh8crCTXuamKx9cdJ01qbGpQuzDHz5TjVcxAb6PsjXmASHJzPxKmHGgaXGJrzG0nAchImOlXCmVeQB0eginalwSiSmGD5OsEBYBqOwzEPyGYThGmoIxxc9AJdEHiU2yGYThGmoIxxc9AJdywJz4y7QyXIxgWUCujVn5nenMXnzVmqG8o16azVXDdzPEIhimJas3OjCiYGUeZX8sOUrtyG0aSiziV6nqCPusutsABoGmOlXCmVdwuemfad5vVWWiDnua4exkLe1KK2MfU0c0nAchImOlXCmVeQB0eginals6gnHbmhZlfad5vVWWiDnua4MKCIZmw2Ajc3JGuamKx9cdJ01qbGdDMvshBrcxAb6gnHdrg0LyoMxc1nAcdKgGPayiV6fggPRHcaFuPY6cZYBtEfU0c0tLsIz0ydhZsVizcbnaIbhJYuamKx9cdJ01qbGJ6gNR1Colni0MkNcGH8QxyyKUgkaCiJJ41LqV2yHlTG7uRdcvrmgkfI3MmmJak3EaY4iEDj0RnoGzsRwiHd6GJrzkagYREHHr6AOaWj7nUBilVLZcxAb52dWXylAzL82K3GxiIRnwS47uRdK9g3nKL6jEGa0neXcabfad5vVWWiDnua4JkvwxywEBYRWLwWYa2LJk5TjVb4ySfTScOC7biJJ41LqV24aMjTAHeeigCmktbWqE1lmmsxdfaoKXr86sOxBSWLwaM1ygo2UkMcGH8QxyyKUgkaC0yJySrcfU0ca5DQ1bYEJ7gYs9epqaZKwTqkagYREHHr6AOaWj7nUBilVLZuamKx9cdJ01qbGJTiVXsOJlIzkagYREHHr6AOaWHmoIxxc9AJfU0cUtToiufXyOuiEBYWmIcGH8QxyyKUgka8rLkRlmlVn5v4slyza7YrL82K3GqTY8sXaLBpazCeVUe61gh8crCTXIfVmGD5OsEBYBiAmJBYEzXIxgWUCujVn5nahJTOLv)bgXOhmafeG493)h]] )


end