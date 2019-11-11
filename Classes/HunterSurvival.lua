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


    spec:RegisterPack( "Survival", 20191111, [[dCKAObqiGWJie1LaKKSja1NqikmkesDkcbRsb0RuiZIG6weISlb)cbgMcuhdGwgGuptbyAkq6AarBdqIVriKXriuNdHiRdqsmpe09iW(qi5GasQfIq9qfiQlQabgjGKuNeHOOvcGzIquQBQar2jqzOieLSufiONQIPcK2RQ(lrdwKdtzXQ0JHmzrDzuBMKpluJwH60swncr1RbQMnPUnI2Ts)wQHlKJRaHwouph00P66kA7eKVRGgpG48esRhHW8ju7hPFaFq)t2C(bdOhmGejabeqadac0aciqpO)XfnI)tKHa3I5)Sgj)NZelujKP)tKjQUT8d6FG9eJ4)m29iiqfciiU8XZBa1KealYP28Qxe2uobWIerWFUZs7ezU)9pzZ5hmGEWasKaeqabmaiqdiGakI)Jn9Xn(pNICQnV6DqgBk)pJRCM3)(Nmdr)rKPPZelujKPPjGQNRZykaImnn29iiqfciiU8XZBa1KealYP28Qxe2uobWIerafarMMoCKZKxgttanifMMa6bdirIcafarMMgKhBBmdbQqbqKPjrIMaQZzottdstIGi0mn5nnLzLn1onziV6LM0f0duaezAsKOPb5X2gZzAYnCm7YsrtmqIWmew9cPjVPjKOinlDdhZomqbqKPjrIMgK6CPkottidlelrzmn5nnnSXGttKnMPj2GLwuAAy5JPjFmttwo3lrgqAQiJ0mjVU5vV0uROjHmCzxnhOaiY0Kirta15mNPPPx6YfLMaQjYIi7WF0f0HpO)XIG(d6dgGpO)Hx7Q58t8Fq4YzCz)5ovQaQBCUwZ5S0GqBQ9WmIMaMMiAA6ovQaQBCUwZ5S0GqBQ9aMjTAH0eH0eGbqstdKMIrzAsSyA6ovQWvpXYwjDt3lmmJOjGPP7uPcx9elBL0nDVWaMjTAH0eH0eGbqstdKMIrzAse(JH8Q3)q2BC3qwElNF)bdOFq)dV2vZ5N4)GWLZ4Y(ZDQubu34CTMZzPbH2u7Hzenbmnr000DQubu34CTMZzPbH2u7bmtA1cPjcPjadGKMginfJY0KyX00DQuHREILTs6MUxyygrtatt3PsfU6jw2kPB6EHbmtA1cPjcPjadGKMginfJY0Ki8hd5vV)bBrEJLqhxGZV)GnGh0)WRD1C(j(piC5mUS)OA0estJOjKbDjMJ5LMiKMunAcdKgq(JH8Q3)O02cETXsOJlW53FWg0h0)WRD1C(j(piC5mUS)OMATeZOXgoMLErY0eH0eGbqstdKMIrzAcyAs1OjKMgrtid6smhZlnrinPA0eginGqtIenb4G)JH8Q3)aEP1sutsAB(9hmq(G(hETRMZpX)bHlNXL9hvJMqAAenHmOlXCmV0eH0KQrtyG0aYFmKx9(hOZSw6yl69hmGYd6F41UAo)e)heUCgx2FunAcPPr0eYGUeZX8stestQgnHbsdi0eW0eiOjVqGxBmnbmnbcA6ovQajt2yrLTsQNOklZy2iHHzenbmnr00KAQ1smJgB4yw6fjttestagajnnqAkgLPjXIPjqqt52ddlDwvywEBYBWle41gttattGGMUtLkG6gNR1Colni0MApmJOjXIPjqqt52ddlDwvywEBYBWle41gttatt3Psfi7nUBilvtSObOBiWPjcPjaPjr4pgYRE)ZWsNvfML3M8((dMi6b9p8AxnNFI)dcxoJl7pGGMYThGmoIxxc9AJdEHaV2yAcyAce00DQubu34CTMZzPbH2u7Hz0FmKx9(hiJJ41LqV243FWeXpO)Hx7Q58t8Fq4YzCz)r1OjKMgrtid6smhZlnrinPA0eginGqtattennDNkvGS34UHSunXIgGUHaNMiKMajnjwmnPA0estestgYREdK9g3nKL3Y5aQHonjc)XqE17FaV0AjQjjTn)(dgr6b9p8AxnNFI)dcxoJl7pywHz4y7QzAcyAce00DQubu34CTMZzPbH2u7HzenbmnDNkvGS34UHSunXIgGUHaNMiKMa5FmKx9(hiJJ41LqV243FWaCWpO)Hx7Q58t8Fq4YzCz)be00DQubu34CTMZzPbH2u7Hz0FmKx9(htsoXzglBLeH7HW3FWaeWh0)WRD1C(j(piC5mUS)acA6ovQaQBCUwZ5S0GqBQ9Wm6pgYRE)dQBCUwZ5S0GqBQ93FWaeOFq)dV2vZ5N4)GWLZ4Y(ZDQubYEJ7gYs1elAygrtIfttQgnH00iAczqxI5yEPjIIMunAcdKgqOjrIMaCW0KyX00DQubu34CTMZzPbH2u7Hz0FmKx9(hYEJ7gYYB587pyaoGh0)yiV69pylYBSe64cC(p8AxnNFIF)bdWb9b9p8AxnNFI)dcxoJl7pGGM8cbETX)XqE17Fgw6SQWS82K33F)pinBcXpOpya(G(hETRMZpX)PJ(dK9s9hd5vV)ridx2vZ)ridlxJK)dYWcXsug)heUCgx2FmKxcXsEzYIH0eH0ei)JqMEYswd5)aY)iKPN8FmKxcXsEzYIHV)Gb0pO)XqE17Fmj5eNzSSvseUhc)dV2vZ5N43FWgWd6FmKx9(hu34CTMZzPbH2u7)Hx7Q58t87pyd6d6F41UAo)e)heUCgx2FYThGJXw0YA5TjVbVqGxB8FmKx9(hKHfIF)bdKpO)Hx7Q58t8Fq4YzCz)be0KBAE9q8KX4sRnPBiVqWaV2vZzAsSyAsn1AjMrJnCml9IKPjcPPyu(pgYRE)ZWsNvfML3M8((dgq5b9p8AxnNFI)JH8Q3)q2BC3qwElN)dcxoJl7pz(ovQG2CEDzuxWEdq3qGttcOjah8FqII0S0nCm7WhmaF)bte9G(hd5vV)bn2ahBKW)WRD1C(j(9hmr8d6F41UAo)e)hd5vV)b8sRLOMK028Fq4YzCz)r1OjKMgrtid6smhZlnrinPA0eginG8hKOinlDdhZo8bdW3FWispO)Hx7Q58t8Fq4YzCz)rn1AjMrJnCml9IKPjcPPyuMMelMMabn5MMxpmS0zvHzzTQjS6nWRD1CMMelMMYThGJXw0YA5TjVbVqGxBmnbmnLBpuRZ410YRM5CTXbOBiWPjcPPb8hd5vV)5oD0ygl67pyao4h0)WRD1C(j(piC5mUS)4MMxpepzmU0At6gYlemWRD1C(pgYRE)dYWcXV)GbiGpO)Hx7Q58t8Fq4YzCz)r1OjKMgrtid6smhZlnrinPA0eginG8hd5vV)rPTf8AJLqhxGZV)Gbiq)G(hETRMZpX)bHlNXL9NC7HHLoRkmlVn5nGzfMHJTRMPjXIPj3086HHLoRkmlRvnHvVbETRMZ)XqE17Fgw6SQWS82K33FWaCapO)Hx7Q58t8FmKx9(hiJJ41LqV24)GWLZ4Y(ZDQubHQigdLcXBtgWSH8)GefPzPB4y2Hpya((dgGd6d6F41UAo)e)heUCgx2FqDRZ9WnmS0zvHz5TjVbmtA1cPjIIMeYWLD1CazyHyjkJPjGQOjG(pgYRE)dYWcXV)GbiiFq)JH8Q3)aDM1shBr)Hx7Q58t87pyacuEq)dV2vZ5N4)GWLZ4Y(JBAE9GZysOSvsEJTyMKxpWRD1C(pgYRE)Zydh19((dgGIOh0)WRD1C(j(pgYRE)dKXr86sOxB8Fq4YzCz)bZkmdhBxnttatt3Psf8ks2kPpMLWi2WbOBiWPjcPPb8hKOinlDdhZo8bdW3FWaue)G(hETRMZpX)XqE17Fi7nUBilVLZ)bjksZs3WXSdFWa89hmajspO)Hx7Q58t8FmKx9(hSf5nwcDCbo)hKOinlDdhZo8bdW3F)pq)b9bdWh0)WRD1C(j(piC5mUS)4MMxp4mMekBLK3ylMj51d8AxnN)JH8Q3)m2WrDVV)Gb0pO)Hx7Q58t8Fq4YzCz)r1OjKMgrtid6smhZlnrinPA0eginG8hd5vV)rPTf8AJLqhxGZV)GnGh0)WRD1C(j(piC5mUS)CNkva1noxR5CwAqOn1EygrtattennDNkva1noxR5CwAqOn1EaZKwTqAIqAcWaiPPbstXOmnjwmnDNkv4QNyzRKUP7fgMr0eW00DQuHREILTs6MUxyaZKwTqAIqAcWaiPPbstXOmnjc)XqE17FWwK3yj0Xf487pyd6d6F41UAo)e)heUCgx2FUtLkG6gNR1Colni0MApmJOjGPjIMMUtLkG6gNR1Colni0MApGzsRwinrinbyaK00aPPyuMMelMMUtLkC1tSSvs309cdZiAcyA6ovQWvpXYwjDt3lmGzsRwinrinbyaK00aPPyuMMeH)yiV69pK9g3nKL3Y53FWa5d6F41UAo)e)heUCgx2FunAcPPr0eYGUeZX8stestQgnHbsdi)XqE17FaV0AjQjjTn)(dgq5b9p8AxnNFI)dcxoJl7pQgnH00iAczqxI5yEPjcPjvJMWaPbK)yiV69pqNzT0Xw07pyIOh0)WRD1C(j(piC5mUS)OA0estJOjKbDjMJ5LMiKMunAcdKgqOjGPjqqtEHaV2yAcyAce00DQubsMSXIkBLuprvwMXSrcdZiAcyAIOPj1uRLygn2WXS0lsMMiKMamasAAG0umkttIfttGGMYThgw6SQWS82K3GxiWRnMMaMMabnDNkva1noxR5CwAqOn1EygrtIfttGGMYThgw6SQWS82K3GxiWRnMMaMMUtLkq2BC3qwQMyrdq3qGttestastIWFmKx9(NHLoRkmlVn599hmr8d6F41UAo)e)heUCgx2FUtLkq2BC3qwQMyrdq3qGttefnbsAcyAce0eQBDUhUbu34CTMZzPbH2u7bmtA1c)JH8Q3)q2BC3qwElNF)bJi9G(hETRMZpX)bHlNXL9N7uPccvrmgkfI3MmmJOjGPPC7biJJ41LqV24aMjTAH0eH00GstdKMIrzAsSyAk3EaY4iEDj0RnoGzfMHJTRMPjGPjqqt3PsfqDJZ1AoNLgeAtThMr)XqE17FGmoIxxc9AJF)bdWb)G(hETRMZpX)bHlNXL9hqqt3PsfqDJZ1AoNLgeAtThMr)XqE17Fmj5eNzSSvseUhcF)bdqaFq)dV2vZ5N4)GWLZ4Y(diOP7uPcOUX5AnNZsdcTP2dZO)yiV69pOUX5AnNZsdcTP2F)bdqG(b9p8AxnNFI)dcxoJl7p3Psfi7nUBilvtSOHzenjwmnPA0estJOjKbDjMJ5LMikAs1OjmqAaHMejAcOhmnbmn5MMxpiufXyOuiEBYaV2vZzAsSyAs1OjKMgrtid6smhZlnru0KQrtyG0acnjs0eG0eW0KBAE9GZysOSvsEJTyMKxpWRD1CMMelMMUtLkG6gNR1Colni0MApmJ(JH8Q3)q2BC3qwElNF)bdWb8G(hd5vV)bBrEJLqhxGZ)Hx7Q58t87pyaoOpO)Hx7Q58t8Fq4YzCz)j3EyyPZQcZYBtEdywHz4y7Q5)yiV69pdlDwvywEBY77pyacYh0)WRD1C(j(piC5mUS)CNkvqOkIXqPq82KHz0FmKx9(hiJJ41LqV243F)pdv1d6dgGpO)Hx7Q58t8Fq4YzCz)r1OjKMgrtid6smhZlnrinPA0eginGqtattUP51doJjHYwj5n2IzsE9aV2vZ5)yiV69pJnCu377pya9d6F41UAo)e)heUCgx2FUtLkC1tSSvs309cdZiAcyA6ovQWvpXYwjDt3lmGzsRwinrinfJY)XqE17Fi7nUBilVLZV)GnGh0)WRD1C(j(piC5mUS)CNkv4QNyzRKUP7fgMr0eW00DQuHREILTs6MUxyaZKwTqAIqAkgL)JH8Q3)GTiVXsOJlW53FWg0h0)WRD1C(j(piC5mUS)CNkvqOkIXqPq82KHzenbmnDNkvqOkIXqPq82KbmtA1cPjcPjadGKMginfJY0KyX0eiOPC7biJJ41LqV24GxiWRn(pgYRE)dKXr86sOxB87pyG8b9p8AxnNFI)dcxoJl7pQPwlXmASHJzPxKmnrinbyaK00aPPyuMMaMMunAcPPr0eYGUeZX8stestQgnHbsdi0KyX0erttldexoSK3M8geQ1MxAMMaMMYThGmoIxxc9AJdEHaV2yAcyAk3EaY4iEDj0RnoGzfMHJTRMPjXIPPLbIlhwYBtEdrJzCt2lttattGGMUtLkq2BC3qwQMyrdZiAcyAs1OjKMgrtid6smhZlnrinPA0eginGqtIenziV6naEP1sutsABoGmOlXCmV00aPPbqtIWFmKx9(NHLoRkmlVn599hmGYd6F41UAo)e)heUCgx2FunAcPPr0eYGUeZX8stestQgnHbsdi0KirtQgnHbmhZ7FmKx9(hWlTwIAssBZV)GjIEq)JH8Q3)ysYjoZyzRKiCpe(hETRMZpXV)GjIFq)dV2vZ5N4)GWLZ4Y(JQrtinnIMqg0LyoMxAIqAs1OjmqAa5pgYRE)d0zwlDSf9(dgr6b9p8AxnNFI)dcxoJl7pQPwlXmASHJzPxKmnrinbyaK00aPPyu(pgYRE)ZWsNvfML3M8((dgGd(b9pgYRE)dQBCUwZ5S0GqBQ9)WRD1C(j(9hmab8b9p8AxnNFI)dcxoJl7p3PsfeQIymukeVnzygrtatt52dqghXRlHETXbmtA1cPjcPPbLMginfJY)XqE17FGmoIxxc9AJF)bdqG(b9p8AxnNFI)dcxoJl7p52dWXylAzT82K3GxiWRnMMelMMUtLkq2BC3qwQMyrdq3qGttcOjq(hd5vV)HS34UHS8wo)(dgGd4b9p8AxnNFI)dcxoJl7pldexoSK3M8gGJXw0YAAcyAk3EaY4iEDj0RnoGzsRwinru0eiPPbstXO8FmKx9(NHLoRkmlVn599hmah0h0)WRD1C(j(piC5mUS)GzfMHJTRM)JH8Q3)azCeVUe61g)(dgGG8b9p8AxnNFI)dcxoJl7pGGMUtLkq2BC3qwQMyrdyM0Qf(hd5vV)bn2ahBKW3FWaeO8G(hd5vV)HS34UHS8wo)hETRMZpXV)GbOi6b9pgYRE)d2I8glHoUaN)dV2vZ5N43FWaue)G(hETRMZpX)bHlNXL9N7uPccvrmgkfI3MmmJ(JH8Q3)azCeVUe61g)(dgGePh0)WRD1C(j(piC5mUS)SmqC5WsEBYBqOwBEPzAcyAk3EaY4iEDj0Rno4fc8AJPjXIPPLbIlhwYBtEdrJzCt2lttIfttldexoSK3M8gGJXw0Y6)yiV69pdlDwvywEBY77V)hlAOQEqFWa8b9p8AxnNFI)dcxoJl7p3PsfU6jw2kPB6EHHzenbmnDNkv4QNyzRKUP7fgWmPvlKMiKMIr5)yiV69pK9g3nKL3Y53FWa6h0)WRD1C(j(piC5mUS)CNkv4QNyzRKUP7fgMr0eW00DQuHREILTs6MUxyaZKwTqAIqAkgL)JH8Q3)GTiVXsOJlW53FWgWd6F41UAo)e)heUCgx2FabnLBpazCeVUe61gh8cbETX)XqE17FGmoIxxc9AJF)bBqFq)JH8Q3)ysYjoZyzRKiCpe(hETRMZpXV)GbYh0)WRD1C(j(piC5mUS)OMATeZOXgoMLErY0eH0eGbqstdKMIrzAsSyAs1OjKMgrtid6smhZlnrinPA0eginGqtattennTmqC5WsEBYBqOwBEPzAcyAk3EaY4iEDj0Rno4fc8AJPjGPPC7biJJ41LqV24aMvygo2UAMMelMMwgiUCyjVn5nenMXnzVmnbmnbcA6ovQazVXDdzPAIfnmJOjGPjvJMqAAenHmOlXCmV0eH0KQrtyG0acnjs0KH8Q3a4LwlrnjPT5aYGUeZX8stdKMganjc)XqE17Fgw6SQWS82K33FWakpO)XqE17FqDJZ1AoNLgeAtT)hETRMZpXV)GjIEq)dV2vZ5N4)GWLZ4Y(ZDQubYEJ7gYs1elAaZKwTqAcyAAzG4YHL82K3q0yg3K9Y)XqE17Fi7nUBilVLZV)GjIFq)dV2vZ5N4)GWLZ4Y(JAQ1smJgB4yw6fjttestagajnnqAkgLPjGPjvJMqAAenHmOlXCmV0eH0KQrtyG0acnjs0eqp4)yiV69pGxATe1KK2MF)bJi9G(hETRMZpX)bHlNXL9hvJMqAAenHmOlXCmV0eH0KQrtyG0aYFmKx9(hOZSw6yl69hmah8d6F41UAo)e)heUCgx2FUtLk4vKSvsFmlHrSHdq3qGttcOPbqtIftt52dWXylAzT82K3GxiWRn(pgYRE)d2I8glHoUaNF)bdqaFq)dV2vZ5N4)GWLZ4Y(tU9aCm2IwwlVn5n4fc8AJ)JH8Q3)q2BC3qwElNF)bdqG(b9p8AxnNFI)dcxoJl7pldexoSK3M8gGJXw0YAAcyAs1OjKMikAAadMMaMMYThGmoIxxc9AJdyM0QfstefnbsAAG0umk)hd5vV)zyPZQcZYBtEF)bdWb8G(hETRMZpX)bHlNXL9hqqt3Psfi7nUBilvtSObmtA1c)JH8Q3)GgBGJns47pyaoOpO)Hx7Q58t8Fq4YzCz)bZkmdhBxn)hd5vV)bY4iEDj0Rn(9hmab5d6F41UAo)e)heUCgx2FunAcPPr0eYGUeZX8stestQgnHbsdi0eW0ertt3Psfi7nUBilvtSObOBiWPjcPjqstIfttQgnH0eH0KH8Q3azVXDdz5TCoGAOttIWFmKx9(hWlTwIAssBZV)Gbiq5b9pgYRE)d2I8glHoUaN)dV2vZ5N43FWaue9G(hETRMZpX)bHlNXL9N7uPcK9g3nKLQjw0WmIMelMMunAcPjIIMg0bttIftt52dWXylAzT82K3GxiWRn(pgYRE)dzVXDdz5TC(9hmafXpO)Hx7Q58t8Fq4YzCz)zzG4YHL82K3GqT28sZ0eW0uU9aKXr86sOxBCWle41gttIfttldexoSK3M8gIgZ4MSxMMelMMwgiUCyjVn5nahJTOL10eW0KQrtinru0eih8FmKx9(NHLoRkmlVn5993)teMrn518h0hmaFq)JH8Q3)aNKK9kJy)p8AxnNFIF)bdOFq)JH8Q3)e1E17F41UAo)e)(d2aEq)dV2vZ5N4)Sgj)hJiGJnSbLQEDzRKr9qg)hd5vV)Xic4ydBqPQxx2kzupKXV)GnOpO)Hx7Q58t8FmKx9(hKOiD74ElK8QnO)heUCgx2FabnHTklzH41d1k0uVm2UAoWaPGo8pSsXixUgj)hKOiD74ElK8QnO)(dgiFq)JH8Q3)epnCUSv2kPremU9X)Hx7Q58t87pyaLh0)yiV69pqNzT0Xw0F41UAo)e)(dMi6b9pgYRE)Zydh19(hETRMZpXV)(Fqz4d6dgGpO)Hx7Q58t8Fq4YzCz)b1To3d3aQBCUwZ5S0GqBQ9aMjTAH0errtdyW)XqE17FU6UZs1el67pya9d6F41UAo)e)heUCgx2FqDRZ9WnG6gNR1Colni0MApGzsRwinru00ag8FmKx9(hBrm0XMwImT(9hSb8G(hETRMZpX)bHlNXL9hu36CpCdOUX5AnNZsdcTP2dyM0QfstefnnGb)hd5vV)rvy(Q7o)(d2G(G(hd5vV)rxXJDOKiFMJj51)dV2vZ5N43FWa5d6F41UAo)e)heUCgx2FqDRZ9WnG6gNR1Colni0MApGzsRwinru0eqzW0KyX0KxKS0BzUyAIqAcWb8hd5vV)5YyiJbV243FWakpO)Hx7Q58t8Fq4YzCz)5ovQq80W5YwzRKgrW42hhMr0eW0ertt3PsfUmgYyWRnomJOjXIPP7uPcxD3zPAIfnmJOjXIPjqqtydXbh3Annjc0KyX0erttOEHts7Q5qu7vVYwjN7fxznNLQjwuAcyAYlsw6TmxmnrinbuaKMelMM8IKLElZfttestanqHMebAsSyAce0edH8I4aQ3mVqol1LIvngXbsJiVX0eW00DQubu34CTMZzPbH2u7Hz0FmKx9(NO2REF)bte9G(hETRMZpX)bHlNXL9h3WXShYf0TfX0erjGMak)XqE17FmyeJCzRK(ywYwSMF)bte)G(hETRMZpX)XqE17Fm4yHSLHsSrenwIASP)dcxoJl7p8G4SII4CiJR7vxBSSwWJ6mnbmnr00uMVtLkGnIOXsuJnTmZ3PsfY9WLMelMM8IKLElJqUCadMMiKMaKMelMMiAAAmBAFCic50eH00agmnbmnDNkviEA4CzRSvsJiyC7JdZiAsSyA6ovQajt2yrLTsQNOklZy2iHHzenjc0KiqtIfttennbcAIheNvueNdzCDV6AJL1cEuNPjGPjIMMUtLkqYKnwuzRK6jQYYmMnsyygrtIftt3PsfINgox2kBL0icg3(4WmIMaMMqDRZ9WnepnCUSv2kPremU9XbmtA1cPjIIMauebsAseOjXIPPmFNkvaBerJLOgBAzMVtLkK7Hlnjc0KyX0KxKS0BzUyAIqAcOh8FwJK)JbhlKTmuInIOXsuJn97pyePh0)WRD1C(j(pgYRE)tSPzKP1mgkVDV)bHlNXL9hu36CpCdKmzJfv2kPEIQSmJzJegWmPvlKMelMMCtZRhgw6SQWSSw1ew9g41UAottattOU15E4gqDJZ1AoNLgeAtThWmPvlKMelMMqDRZ9WnGefPBh3BHKxTb9aMjTAH0KyX0eiOjgc5fXbsMSXIkBLuprvwMXSrcdKgrEJPjGPju36CpCdOUX5AnNZsdcTP2dyM0Qf(N1i5)eBAgzAnJHYB377pyao4h0)WRD1C(j(pRrY)Xic4ydBqPQxx2kzupKX)XqE17FmIao2WguQ61LTsg1dz87pyac4d6FmKx9(hvJMqolnIGXLZYlBK)Hx7Q58t87pyac0pO)Hx7Q58t8Fq4YzCz)r1OjKMiKMunAcdKgqOjrIMgWGPjGPP7uPcOUX5AnNZsdcTP2dZO)yiV69pKmzJfv2kPEIQSmJzJe((dgGd4b9p8AxnNFI)dcxoJl7p3PsfqDJZ1AoNLgeAtThMr)XqE17FU6UZYwj9XSKxMu03FWaCqFq)JH8Q3)enXLs0AJLxTb9)WRD1C(j(9hmab5d6FmKx9(N4PHZLTYwjnIGXTp(p8AxnNFIF)bdqGYd6FmKx9(hCffPzzTsyKH4)WRD1C(j(9hmafrpO)Hx7Q58t8Fq4YzCz)rn1AjMrJnCml9IKPjcPjaPPbstXO8FmKx9(huViEDS5CwQ0gj)(dgGI4h0)WRD1C(j(piC5mUS)CNkvaZiW1mekvngXHz0FmKx9(hFmlN7TNBwQAmIF)bdqI0d6FmKx9(NHnwNfIRvIzyV2I4)WRD1C(j(93)tMv2u7pOpya(G(hETRMZpX)bHlNXL9NmFNkvazqV24WmIMelMMY8DQuHCbJyT2UAwsAXfkmJOjXIPPmFNkvixWiwRTRML8ITyomJ(JH8Q3)GmTwAiV6vQlO)hDbD5AK8FMEPlx03FWa6h0)yiV69ptillNjH)Hx7Q58t87pyd4b9p8AxnNFI)JH8Q3)GmTwAiV6vQlO)hDbD5AK8Fqz47pyd6d6F41UAo)e)heUCgx2FmKxcXsEzYIH0eH00aOjGPj3086b0ydCSrcd8AxnNPjGPj3086bthn2KryoBEJd8AxnN)JH8Q3)GmTwAiV6vQlO)hDbD5AK8FSOHQ69hmq(G(hETRMZpX)bHlNXL9hd5LqSKxMSyinrinnaAcyAYnnVEan2ahBKWaV2vZ5)yiV69pitRLgYREL6c6)rxqxUgj)NHQ69hmGYd6F41UAo)e)heUCgx2FmKxcXsEzYIH0eH00aOjGPjqqtUP51dMoASjJWC28gh41UAottattGGMCtZRhgw6SQWSSw1ew9g41UAo)hd5vV)bzAT0qE1Ruxq)p6c6Y1i5)a93FWerpO)Hx7Q58t8Fq4YzCz)XqEjel5LjlgstestdGMaMMCtZRhmD0ytgH5S5noWRD1CMMaMMabn5MMxpmS0zvHzzTQjS6nWRD1C(pgYRE)dY0APH8QxPUG(F0f0LRrY)XIG(7pyI4h0)WRD1C(j(piC5mUS)yiVeIL8YKfdPjcPPbqtattUP51dMoASjJWC28gh41UAottattUP51ddlDwvywwRAcREd8AxnN)JH8Q3)GmTwAiV6vQlO)hDbD5AK8FSOHQ69hmI0d6F41UAo)e)heUCgx2FmKxcXsEzYIH0eH00aOjGPjqqtUP51dMoASjJWC28gh41UAottattUP51ddlDwvywwRAcREd8AxnN)JH8Q3)GmTwAiV6vQlO)hDbD5AK8FgQQ3FWaCWpO)Hx7Q58t8Fq4YzCz)XqEjel5Ljlgstefnb4FmKx9(hKP1sd5vVsDb9)OlOlxJK)dsZMq87pyac4d6FmKx9(huViEDS5CwQ0gj)hETRMZpXV)Gbiq)G(hd5vV)XWiBzP3ymV(F41UAo)e)(7)z6LUCrFqFWa8b9pgYRE)d5Kiicn)hETRMZpXV)Gb0pO)XqE17FGmM3YfvMNq)p8AxnNFIF)bBapO)XqE17FGrnMLiDpZ)Hx7Q58t87pyd6d6FmKx9(hy3(4AJLdnNX)Hx7Q58t87pyG8b9pgYRE)dS3cjVAd6)Hx7Q58t87pyaLh0)yiV69pl7JzSeoUrG)hETRMZpXV)GjIEq)JH8Q3)Ggxe5fu6yBheNLUCr)dV2vZ5N43FWeXpO)XqE17FGrfUCjCCJa)p8AxnNFIF)bJi9G(hd5vV)znFIzOmgBi(p8AxnNFIF)93)Jqmgw9(Gb0dgqI0Gjsani)ZqdV1gd)drMKrn25mnrKOjd5vV0KUGomqb4pWig9Gb0GeK)jc3QsZ)rKPPZelujKPPjGQNRZykaImnn29iiqfciiU8XZBa1KealYP28Qxe2uobWIerafarMMaRfIjVmMMaeqHPjGEWasKOaqbqKPPb5X2gZqGkuaezAsKOjG6CMZ00G0KiicnttEttzwztTttgYREPjDb9afarMMejAAqESTXCMMCdhZUSu0edKimdHvVqAYBAcjksZs3WXSdduaezAsKOPbPoxQIZ0eYWcXsugttEttdBm40ezJzAInyPfLMgw(yAYhZ0KLZ9sKbKMkYintYRBE1ln1kAsidx2vZbkaImnjs0eqDoZzAA6LUCrPjGAISiYoqbGcGittdcacJMoNPPlRAmttOM8AonD54AHbAcOgH4ihstBVI0ydtQMAAYqE1lKM6vlAGcGittgYREHHimJAYR5cuAdcofarMMmKx9cdryg1KxZhjGaBgtYRBE1lfarMMmKx9cdryg1KxZhjGav3zkagYREHHimJAYR5JeqaCss2RmIDkaImnDwlcoUDAcBvMMUtLIZ0e0nhstxw1yMMqn51CA6YX1cPjBZ0ueMfPO29AJPPcst5E5afarMMmKx9cdryg1KxZhjGa4ArWXTlHU5qkagYREHHimJAYR5Jeqqu7vVuamKx9cdryg1KxZhjGGjKLLZKcVgjlWic4ydBqPQxx2kzupKXuamKx9cdryg1KxZhjGGjKLLZKcZkfJC5AKSaKOiD74ElK8QnOlCPeacSvzjleVEOwHM6LX2vZbgif0HuamKx9cdryg1KxZhjGG4PHZLTYwjnIGXTpMcGH8QxyicZOM8A(ibeaDM1shBruamKx9cdryg1KxZhjGGXgoQ7Lcafad5vVWW0lD5IkGCseeHMPayiV6fgMEPlx0rciaYyElxuzEcDkagYREHHPx6YfDKacGrnMLiDpZuamKx9cdtV0Ll6ibea72hxBSCO5mMcGH8Qxyy6LUCrhjGayVfsE1g0PayiV6fgMEPlx0rciyzFmJLWXncCkagYREHHPx6YfDKacqJlI8ckDSTdIZsxUOuamKx9cdtV0Ll6ibeaJkC5s44gbofad5vVWW0lD5IosabR5tmdLXydXuaOaiY00GaGWOPZzAIfIXIstErY0KpMPjd5nMMkinzczL2UAoqbWqE1luaY0APH8QxPUGUWRrYcMEPlxuHlLGmFNkvazqV24WmsS4mFNkvixWiwRTRMLKwCHcZiXIZ8DQuHCbJyT2UAwYl2I5WmIcGH8Qx4ibemHSSCMesbWqE1lCKacqMwlnKx9k1f0fEnswakdPayiV6fosabitRLgYREL6c6cVgjlWIgQkHlLad5LqSKxMSyiHday3086b0ydCSrcd8AxnNb2nnVEW0rJnzeMZM34aV2vZzkagYREHJeqaY0APH8QxPUGUWRrYcgQkHlLad5LqSKxMSyiHday3086b0ydCSrcd8AxnNPayiV6fosabitRLgYREL6c6cVgjla6cxkbgYlHyjVmzXqchaWGWnnVEW0rJnzeMZM34aV2vZzGbHBAE9WWsNvfML1QMWQ3aV2vZzkagYREHJeqaY0APH8QxPUGUWRrYcSiOlCPeyiVeIL8YKfdjCaa7MMxpy6OXMmcZzZBCGx7Q5mWGWnnVEyyPZQcZYAvty1BGx7Q5mfad5vVWrciazAT0qE1Ruxqx41izbw0qvjCPeyiVeIL8YKfdjCaa7MMxpy6OXMmcZzZBCGx7Q5mWUP51ddlDwvywwRAcREd8AxnNPayiV6fosabitRLgYREL6c6cVgjlyOQeUucmKxcXsEzYIHeoaGbHBAE9GPJgBYimNnVXbETRMZa7MMxpmS0zvHzzTQjS6nWRD1CMcGH8Qx4ibeGmTwAiV6vQlOl8AKSaKMnHyHlLad5LqSKxMSyirbifad5vVWrcia1lIxhBoNLkTrYuamKx9chjGadJSLLEJX86uaOayiV6fgSiOlGS34UHS8wolCPeCNkva1noxR5CwAqOn1EygbmrFNkva1noxR5CwAqOn1EaZKwTqcbmaYbgJYIfFNkv4QNyzRKUP7fgMraFNkv4QNyzRKUP7fgWmPvlKqadGCGXOSiqbWqE1lmyrqFKacWwK3yj0Xf4SWLsWDQubu34CTMZzPbH2u7HzeWe9DQubu34CTMZzPbH2u7bmtA1cjeWaihymklw8DQuHREILTs6MUxyygb8DQuHREILTs6MUxyaZKwTqcbmaYbgJYIafad5vVWGfb9rciqPTf8AJLqhxGZcxkbQgnHJqg0LyoMxcvnAcdKgqOayiV6fgSiOpsabGxATe1KK2MfUucutTwIz0ydhZsVizcbmaYbgJYaRA0eoczqxI5yEju1OjmqAarKaCWuamKx9cdwe0hjGaOZSw6yls4sjq1OjCeYGUeZX8sOQrtyG0acfad5vVWGfb9rciyyPZQcZYBtEfUucunAchHmOlXCmVeQA0eginGami8cbETXadI7uPcKmzJfv2kPEIQSmJzJegMrat0QPwlXmASHJzPxKmHaga5aJrzXIbrU9WWsNvfML3M8g8cbETXadI7uPcOUX5AnNZsdcTP2dZiXIbrU9WWsNvfML3M8g8cbETXaFNkvGS34UHSunXIgGUHaNqafbkagYREHblc6JeqaKXr86sOxBSWLsaiYThGmoIxxc9AJdEHaV2yGbXDQubu34CTMZzPbH2u7Hzefad5vVWGfb9rcia8sRLOMK02SWLsGQrt4iKbDjMJ5LqvJMWaPbeGj67uPcK9g3nKLQjw0a0ne4ecsXIvnAcj0qE1BGS34UHS8wohqn0fbkagYREHblc6JeqaKXr86sOxBSWLsaMvygo2UAgyqCNkva1noxR5CwAqOn1Eygb8DQubYEJ7gYs1elAa6gcCcbjfad5vVWGfb9rciWKKtCMXYwjr4Eiu4sjae3PsfqDJZ1AoNLgeAtThMruamKx9cdwe0hjGau34CTMZzPbH2u7cxkbG4ovQaQBCUwZ5S0GqBQ9WmIcGH8QxyWIG(ibeq2BC3qwElNfUucUtLkq2BC3qwQMyrdZiXIvnAchHmOlXCmVeLQrtyG0aIib4Gfl(ovQaQBCUwZ5S0GqBQ9WmIcGH8QxyWIG(ibeGTiVXsOJlWzkagYREHblc6JeqWWsNvfML3M8kCPeacVqGxBmfakagYREHblAOQeq2BC3qwElNfUucUtLkC1tSSvs309cdZiGVtLkC1tSSvs309cdyM0QfsymktbWqE1lmyrdv1ibeGTiVXsOJlWzHlLG7uPcx9elBL0nDVWWmc47uPcx9elBL0nDVWaMjTAHegJYuamKx9cdw0qvnsabqghXRlHETXcxkbGi3EaY4iEDj0Rno4fc8AJPayiV6fgSOHQAKacmj5eNzSSvseUhcPayiV6fgSOHQAKacgw6SQWS82KxHlLa1uRLygn2WXS0lsMqadGCGXOSyXQgnHJqg0LyoMxcvnAcdKgqaMOxgiUCyjVn5niuRnV0mW52dqghXRlHETXbVqGxBmW52dqghXRlHETXbmRWmCSD1SyXldexoSK3M8gIgZ4MSxgyqCNkvGS34UHSunXIgMraRA0eoczqxI5yEju1OjmqAarKmKx9gaV0AjQjjTnhqg0LyoM3boarGcGH8QxyWIgQQrcia1noxR5CwAqOn1ofad5vVWGfnuvJeqazVXDdz5TCw4sj4ovQazVXDdzPAIfnGzsRwiWldexoSK3M8gIgZ4MSxMcGH8QxyWIgQQrcia8sRLOMK02SWLsGAQ1smJgB4yw6fjtiGbqoWyugyvJMWrid6smhZlHQgnHbsdiIeqpykagYREHblAOQgjGaOZSw6yls4sjq1OjCeYGUeZX8sOQrtyG0acfad5vVWGfnuvJeqa2I8glHoUaNfUucUtLk4vKSvsFmlHrSHdq3qGlyaIfNBpahJTOL1YBtEdEHaV2ykagYREHblAOQgjGaYEJ7gYYB5SWLsqU9aCm2IwwlVn5n4fc8AJPayiV6fgSOHQAKacgw6SQWS82KxHlLGLbIlhwYBtEdWXylAznWQgnHe1agmW52dqghXRlHETXbmtA1cjkqoWyuMcGH8QxyWIgQQrcian2ahBKqHlLaqCNkvGS34UHSunXIgWmPvlKcGH8QxyWIgQQrciaY4iEDj0Rnw4sjaZkmdhBxntbWqE1lmyrdv1ibeaEP1sutsABw4sjq1OjCeYGUeZX8sOQrtyG0acWe9DQubYEJ7gYs1elAa6gcCcbPyXQgnHeAiV6nq2BC3qwElNdOg6Iafad5vVWGfnuvJeqa2I8glHoUaNPayiV6fgSOHQAKaci7nUBilVLZcxkb3Psfi7nUBilvtSOHzKyXQgnHe1GoyXIZThGJXw0YA5TjVbVqGxBmfad5vVWGfnuvJeqWWsNvfML3M8kCPeSmqC5WsEBYBqOwBEPzGZThGmoIxxc9AJdEHaV2yXIxgiUCyjVn5nenMXnzVSyXldexoSK3M8gGJXw0YAGvnAcjkqoykauamKx9cdOmuWv3DwQMyrfUucqDRZ9WnG6gNR1Colni0MApGzsRwirnGbtbWqE1lmGYWrciWwedDSPLitRfUucqDRZ9WnG6gNR1Colni0MApGzsRwirnGbtbWqE1lmGYWrciqvy(Q7olCPeG6wN7HBa1noxR5CwAqOn1EaZKwTqIAadMcGH8QxyaLHJeqGUIh7qjr(mhtYRtbWqE1lmGYWrci4YyiJbV2yHlLau36CpCdOUX5AnNZsdcTP2dyM0QfsuaLblwSxKS0BzUycbCauamKx9cdOmCKacIAV6v4sj4ovQq80W5YwzRKgrW42hhMrat03PsfUmgYyWRnomJel(ovQWv3DwQMyrdZiXIbb2qCWXTwlcIft0OEHts7Q5qu7vVYwjN7fxznNLQjwuG9IKLElZftiqbqXI9IKLElZftiqduebXIbbdH8I4aQ3mVqol1LIvngXbsJiVXaFNkva1noxR5CwAqOn1EygrbWqE1lmGYWrciWGrmYLTs6JzjBXAw4sjWnCm7HCbDBrmrjaOqbWqE1lmGYWrciyczz5mPWRrYcm4yHSLHsSrenwIASPfUuc4bXzffX5qgx3RU2yzTGh1zGj6mFNkvaBerJLOgBAzMVtLkK7HRyXErYsVLrixoGbtiGIft0Jzt7JdriNWbmyGVtLkepnCUSv2kPremU9XHzKyX3PsfizYglQSvs9evzzgZgjmmJebrqSyIge8G4SII4CiJR7vxBSSwWJ6mWe9DQubsMSXIkBLuprvwMXSrcdZiXIVtLkepnCUSv2kPremU9XHzeWOU15E4gINgox2kBL0icg3(4aMjTAHefGIiqkcIfN57uPcyJiASe1ytlZ8DQuHCpCfbXI9IKLElZftiqpykagYREHbugosabtillNjfEnswqSPzKP1mgkVDVcxkbOU15E4gizYglQSvs9evzzgZgjmGzsRwOyXUP51ddlDwvywwRAcREd8AxnNbg1To3d3aQBCUwZ5S0GqBQ9aMjTAHIfJ6wN7HBajks3oU3cjVAd6bmtA1cflgemeYlIdKmzJfv2kPEIQSmJzJeginI8gdmQBDUhUbu34CTMZzPbH2u7bmtA1cPayiV6fgqz4ibemHSSCMu41izbgrahBydkv96YwjJ6HmMcGH8QxyaLHJeqGQrtiNLgrW4Yz5LnskagYREHbugosabKmzJfv2kPEIQSmJzJekCPeOA0esOQrtyG0aIinGbd8DQubu34CTMZzPbH2u7Hzefad5vVWakdhjGGRU7SSvsFml5Ljfv4sj4ovQaQBCUwZ5S0GqBQ9WmIcGH8QxyaLHJeqq0exkrRnwE1g0PayiV6fgqz4ibeepnCUSv2kPremU9XuamKx9cdOmCKacWvuKML1kHrgIPayiV6fgqz4ibeG6fXRJnNZsL2izHlLa1uRLygn2WXS0lsMqahymktbWqE1lmGYWrciWhZY5E75MLQgJyHlLG7uPcygbUMHqPQXiomJOayiV6fgqz4ibemSX6SqCTsmd71wetbGcGH8QxyaPztiwGqgUSRMfEnswaYWcXsuglChjaYEPewitpzbgYlHyjVmzXqHfY0twYAilaKcJ6nxE1Rad5LqSKxMSyiHGKcGH8QxyaPztiEKacmj5eNzSSvseUhcPayiV6fgqA2eIhjGau34CTMZzPbH2u7uamKx9cdinBcXJeqaYWcXcxkb52dWXylAzT82K3GxiWRnMcGH8QxyaPztiEKacgw6SQWS82KxHlLaq4MMxpepzmU0At6gYlemWRD1CwSy1uRLygn2WXS0lsMWyuMcGH8QxyaPztiEKaci7nUBilVLZcJefPzPB4y2Hcau4sjiZ3Psf0MZRlJ6c2Ba6gcCbaoykagYREHbKMnH4rcian2ahBKqkagYREHbKMnH4rcia8sRLOMK02SWirrAw6goMDOaafUucunAchHmOlXCmVeQA0eginGqbWqE1lmG0Sjepsab3PJgZyrfUucutTwIz0ydhZsVizcJrzXIbHBAE9WWsNvfML1QMWQ3aV2vZzXIZThGJXw0YA5TjVbVqGxBmW52d16mEnT8QzoxBCa6gcCchafad5vVWasZMq8ibeGmSqSWLsGBAE9q8KX4sRnPBiVqWaV2vZzkagYREHbKMnH4rciqPTf8AJLqhxGZcxkbQgnHJqg0LyoMxcvnAcdKgqOayiV6fgqA2eIhjGGHLoRkmlVn5v4sji3EyyPZQcZYBtEdywHz4y7QzXIDtZRhgw6SQWSSw1ew9g41UAotbWqE1lmG0SjepsabqghXRlHETXcJefPzPB4y2Hcau4sj4ovQGqveJHsH4Tjdy2qofad5vVWasZMq8ibeGmSqSWLsaQBDUhUHHLoRkmlVn5nGzsRwirjKHl7Q5aYWcXsugdufqtbWqE1lmG0SjepsabqNzT0Xwefad5vVWasZMq8ibem2WrDVcxkbUP51doJjHYwj5n2IzsE9aV2vZzkagYREHbKMnH4rciaY4iEDj0RnwyKOinlDdhZouaGcxkbywHz4y7QzGVtLk4vKSvsFmlHrSHdq3qGt4aOaiY0eOnnblYP2CMMMqlMPjvJPPbPEJ7gY0eXLZ0uJPPbHwK3yA644cCMMYtCTX0eqnmIron1kAYhZ00GalwZcttOosuAIn0yAQrOjgZlIPPwrt(yMMmKx9st2MPjlkI3mnjzlwZ0K30KpMPjd5vV00AKCGcGH8QxyaPztiEKaci7nUBilVLZcJefPzPB4y2HcaKcGH8QxyaPztiEKacWwK3yj0Xf4SWirrAw6goMDOaaPaqbWqE1lmaDbJnCu3RWLsGBAE9GZysOSvsEJTyMKxpWRD1CMcGH8Qxya6JeqGsBl41glHoUaNfUucunAchHmOlXCmVeQA0eginGqbWqE1lma9rciaBrEJLqhxGZcxkb3PsfqDJZ1AoNLgeAtThMrat03PsfqDJZ1AoNLgeAtThWmPvlKqadGCGXOSyX3PsfU6jw2kPB6EHHzeW3PsfU6jw2kPB6EHbmtA1cjeWaihymklcuaezAc0MMGf5uBotttOfZ0KQX00GuVXDdzAI4YzAQX00GqlYBmnDCCbott5jU2yAcOggXiNMAfn5JzAAqGfRzHPjuhjknXgAmn1i0eJ5fX0uROjFmttgYREPjBZ0KffXBMMKSfRzAYBAYhZ0KH8QxAAnsoqbWqE1lma9rciGS34UHS8wolCPeCNkva1noxR5CwAqOn1EygbmrFNkva1noxR5CwAqOn1EaZKwTqcbmaYbgJYIfFNkv4QNyzRKUP7fgMraFNkv4QNyzRKUP7fgWmPvlKqadGCGXOSiqbWqE1lma9rcia8sRLOMK02SWLsGQrt4iKbDjMJ5LqvJMWaPbekagYREHbOpsabqNzT0XwKWLsGQrt4iKbDjMJ5LqvJMWaPbekagYREHbOpsabdlDwvywEBYRWLsGQrt4iKbDjMJ5LqvJMWaPbeGbHxiWRngyqCNkvGKjBSOYwj1tuLLzmBKWWmcyIwn1AjMrJnCml9IKjeWaihymklwmiYThgw6SQWS82K3GxiWRngyqCNkva1noxR5CwAqOn1EygjwmiYThgw6SQWS82K3GxiWRng47uPcK9g3nKLQjw0a0ne4ecOiqbWqE1lma9rciGS34UHS8wolCPeCNkvGS34UHSunXIgGUHaNOajWGa1To3d3aQBCUwZ5S0GqBQ9aMjTAHuamKx9cdqFKacGmoIxxc9AJfUucUtLkiufXyOuiEBYWmc4C7biJJ41LqV24aMjTAHeoOdmgLflo3EaY4iEDj0RnoGzfMHJTRMbge3PsfqDJZ1AoNLgeAtThMruamKx9cdqFKacmj5eNzSSvseUhcfUucaXDQubu34CTMZzPbH2u7Hzefad5vVWa0hjGau34CTMZzPbH2u7cxkbG4ovQaQBCUwZ5S0GqBQ9WmIcGH8Qxya6JeqazVXDdz5TCw4sj4ovQazVXDdzPAIfnmJelw1OjCeYGUeZX8suQgnHbsdiIeqpyGDtZRheQIymukeVnzGx7Q5SyXQgnHJqg0LyoMxIs1OjmqAarKaey3086bNXKqzRK8gBXmjVEGx7Q5SyX3PsfqDJZ1AoNLgeAtThMruamKx9cdqFKacWwK3yj0Xf4mfad5vVWa0hjGGHLoRkmlVn5v4sji3EyyPZQcZYBtEdywHz4y7QzkagYREHbOpsabqghXRlHETXcxkb3PsfeQIymukeVnzygrbGcGH8QxyyOQem2WrDVcxkbQgnHJqg0LyoMxcvnAcdKgqa2nnVEWzmju2kjVXwmtYRh41UAotbWqE1lmmuvJeqazVXDdz5TCw4sj4ovQWvpXYwjDt3lmmJa(ovQWvpXYwjDt3lmGzsRwiHXOmfad5vVWWqvnsabylYBSe64cCw4sj4ovQWvpXYwjDt3lmmJa(ovQWvpXYwjDt3lmGzsRwiHXOmfad5vVWWqvnsabqghXRlHETXcxkb3PsfeQIymukeVnzygb8DQubHQigdLcXBtgWmPvlKqadGCGXOSyXGi3EaY4iEDj0Rno4fc8AJPayiV6fggQQrciyyPZQcZYBtEfUucutTwIz0ydhZsVizcbmaYbgJYaRA0eoczqxI5yEju1OjmqAarSyIEzG4YHL82K3GqT28sZaNBpazCeVUe61gh8cbETXaNBpazCeVUe61ghWScZWX2vZIfVmqC5WsEBYBiAmJBYEzGbXDQubYEJ7gYs1elAygbSQrt4iKbDjMJ5LqvJMWaPberYqE1Ba8sRLOMK02CazqxI5yEh4aebkagYREHHHQAKacaV0AjQjjTnlCPeOA0eoczqxI5yEju1OjmqAarKunAcdyoMxkagYREHHHQAKacmj5eNzSSvseUhcPayiV6fggQQrcia6mRLo2IeUucunAchHmOlXCmVeQA0eginGqbWqE1lmmuvJeqWWsNvfML3M8kCPeOMATeZOXgoMLErYecyaKdmgLPayiV6fggQQrcia1noxR5CwAqOn1ofad5vVWWqvnsabqghXRlHETXcxkb3PsfeQIymukeVnzygbCU9aKXr86sOxBCaZKwTqch0bgJYuamKx9cddv1ibeq2BC3qwElNfUucYThGJXw0YA5TjVbVqGxBSyX3Psfi7nUBilvtSObOBiWfaskagYREHHHQAKacgw6SQWS82KxHlLGLbIlhwYBtEdWXylAznW52dqghXRlHETXbmtA1cjkqoWyuMcGH8QxyyOQgjGaiJJ41LqV2yHlLamRWmCSD1mfad5vVWWqvnsabOXg4yJekCPeaI7uPcK9g3nKLQjw0aMjTAHuamKx9cddv1ibeq2BC3qwElNPayiV6fggQQrciaBrEJLqhxGZuamKx9cddv1ibeazCeVUe61glCPeCNkvqOkIXqPq82KHzefad5vVWWqvnsabdlDwvywEBYRWLsWYaXLdl5TjVbHAT5LMbo3EaY4iEDj0Rno4fc8AJflEzG4YHL82K3q0yg3K9YIfVmqC5WsEBYBaogBrlRF)9)b]] )


end