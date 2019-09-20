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


    spec:RegisterPack( "Survival", 20190920, [[dCefMbqiGQEeHuDjekQ2eG8jekOgfcLofcvwLOiVsuAweu3IqODj4xaXWiKCmGYYaO6zeIMgafxdOY2efvFJqknocP4CauADiuG5Ha3Ja7dHQoicfAHiOhkkk1frOOmsekcNeHIOvcGzIqrQBkkkzNaPHIqrYsrOG8ufnva1Ev1FjAWICyklwLEmKjRWLrTzs9zHA0IQoTKvlkk8AeYSj52iA3k9BPgUqoUOOOLd1ZbnDQUUk2ob57IkJhGCErH1tiy(eQ9J0pypW)Cyo)Gc4IcmaROaSaUOcGjkrb4IuK)0ZiI)zKHiYI5FUgj)Z5blujKP(zKLHQTXd8pH9bJ4FM39iiXaqajU88NBa1KGalYJY8Qxe20oiWIebYpVNs5etU)9NdZ5huaxuGbyffGfWfvamrjkaxK)0oE(g)ZzrEuMx9MzJnT)Z81yW7F)5GHOFk6008GfQeYu0eXeN1zmfarNMY7EeKyaiGexE(ZnGAsqGf5rzE1lcBAheyrIaHcGOtttoYzYlJPjaxucttaUOadWsbGcGOttz25TnMHedOai60KisteJJbpOPmRJiickMM8MMgS2okNMmKx9stQc6bkaIonjI0uMDEBJ5bn5goMDzPPjgqrygcREH0K30ekdKILUHJzhgOai60Kistzw9O0fpOjKHfILObMM8MMY1yIOjYgZ0eBWsLbnLR880KNNPjBm6LyyinvKrkMKx38QxAQ10KqgUSRIduaeDAsePjIXXGh00Xlv5zqteJetrmD4NQc6Wh4FArq)b(bfSh4FYRDv84j8NiC5mUSFEpADa1nEuR58qAqODuE4ertartelnDpADa1nEuR58qAqODuEaZKwTqAIaAcSa4OPmrtXObnjwmnDpAD4QoyzRLUP6fgor0eq009O1HR6GLTw6MQxyaZKwTqAIaAcSa4OPmrtXObnrC)0qE17pj7nUBilVLZV)Gc4pW)Kx7Q4Xt4pr4YzCz)8E06aQB8OwZ5H0Gq7O8WjIMaIMiwA6E06aQB8OwZ5H0Gq7O8aMjTAH0eb0eybWrtzIMIrdAsSyA6E06WvDWYwlDt1lmCIOjGOP7rRdx1blBT0nvVWaMjTAH0eb0eybWrtzIMIrdAI4(PH8Q3FITiVXsOJlI43Fqf5d8p51UkE8e(teUCgx2p1n6aPPS0eYGUeZX8steqt6gDGbsdq)0qE17p1kBjQ2yj0Xfr87pOaMh4FYRDv84j8NiC5mUSFQpkLeZO8goMLErY0eb0eybWrtzIMIrdAciAs3OdKMYstid6smhZlnranPB0bginartIinbMO(PH8Q3FsuPusutsA749huW9a)tETRIhpH)eHlNXL9tDJoqAklnHmOlXCmV0eb0KUrhyG0a0pnKx9(tOZSs6yl69h0m)b(N8AxfpEc)jcxoJl7N6gDG0uwAczqxI5yEPjcOjDJoWaPbiAciAc80KxiIQnMMaIMapnDpADGKjBCgYwlvhunKdmBKWWjIMaIMiwAsFukjMr5nCml9IKPjcOjWcGJMYenfJg0KyX0e4PPr7HCLAOlmlVn5n4fIOAJPjGOjWtt3JwhqDJh1AopKgeAhLhor0eX9td5vV)mxPg6cZYBtEF)bv0(a)tETRIhpH)eHlNXL9tWttJ2dqghXRlHETXbVqevBmnbenbEA6E06aQB8OwZ5H0Gq7O8Wj6NgYRE)jKXr86sOxB87pOIMh4FYRDv84j8NiC5mUSFQB0bstzPjKbDjMJ5LMiGM0n6adKgGOjGOjILMUhToq2BC3qwQp4mcq3qerteqtGJMelMM0n6aPjcOjd5vVbYEJ7gYYB5Ca1qNMiUFAiV69NevkLe1KK2oE)bfW(a)tETRIhpH)eHlNXL9tmRXmmVDvmnbenbEA6E06aQB8OwZ5H0Gq7O8WjIMaIMUhToq2BC3qwQp4mcq3qerteqtG7NgYRE)jKXr86sOxB87pOGjQh4FYRDv84j8NiC5mUSFcEA6E06aQB8OwZ5H0Gq7O8Wj6NgYRE)Pjjp4bJLTwIWDo47pOGb2d8pnKx9(tu34rTMZdPbH2r5)Kx7Q4Xt47pOGb4pW)Kx7Q4Xt4pr4YzCz)8E06azVXDdzP(GZiCIOjXIPjDJoqAklnHmOlXCmV0eXtt6gDGbsdq0KistGjkAsSyA6E06aQB8OwZ5H0Gq7O8Wj6NgYRE)jzVXDdz5TC(9huWe5d8pnKx9(tSf5nwcDCre)tETRIhpHV)GcgG5b(N8AxfpEc)jcxoJl7NGNM8cruTX)0qE17pZvQHUWS82K33F)NifBcXpWpOG9a)tETRIhpH)SJ(jK9s)td5vV)uidx2vX)uidlxJK)jYWcXs0a)teUCgx2pnKxcXsEzYIH0eb0e4(PqM6Wswb5FcUFkKPo8pnKxcXsEzYIHV)Gc4pW)0qE17pnj5bpySS1seUZb)jV2vXJNW3Fqf5d8pnKx9(tu34rTMZdPbH2r5)Kx7Q4Xt47pOaMh4FYRDv84j8NiC5mUSFoApaZJTOLvYBtEdEHiQ24FAiV69Nidle)(dk4EG)jV2vXJNWFIWLZ4Y(j4Pj3u86H4dJXLszs3qEHGbETRIh0KyX0K(OusmJYB4yw6fjtteqtXOXpnKx9(ZCLAOlmlVn599h0m)b(N8AxfpEc)PH8Q3Fs2BC3qwElN)jcxoJl7Nd(E06GYCEDzuxWEdq3qertcOjWe1przGuS0nCm7WhuWE)bv0(a)td5vV)eL3icBKWFYRDv84j89hurZd8p51UkE8e(td5vV)KOsPKOMK02Xpr4YzCz)u3OdKMYstid6smhZlnranPB0bgina9tugiflDdhZo8bfS3FqbSpW)Kx7Q4Xt4pr4YzCz)uFukjMr5nCml9IKPjcOPy0GMelMMapn5MIxpKRudDHzzT6dS6nWRDv8GMelMMgThG5Xw0Yk5TjVbVqevBmnbennApuRZ41uYRI5rTXbOBiIOjcOjr(td5vV)8ECuEgNX7pOGjQh4FYRDv84j8NiC5mUSF6MIxpeFymUukt6gYlemWRDv84NgYRE)jYWcXV)GcgypW)Kx7Q4Xt4pr4YzCz)u3OdKMYstid6smhZlnranPB0bgina9td5vV)uRSLOAJLqhxeXV)GcgG)a)tETRIhpH)eHlNXL9Zr7HCLAOlmlVn5nGznMH5TRIPjXIPj3u86HCLAOlmlRvFGvVbETRIh)0qE17pZvQHUWS82K33FqbtKpW)Kx7Q4Xt4pnKx9(tiJJ41LqV24FIWLZ4Y(59O1bHQigdLcXBtgWSH8FIYaPyPB4y2HpOG9(dkyaMh4FYRDv84j8NiC5mUSFI6wn6CBixPg6cZYBtEdyM0QfstepnjKHl7Q4aYWcXs0atteZPja)NgYRE)jYWcXV)Gcg4EG)PH8Q3FcDMvshBr)Kx7Q4Xt47pOGL5pW)Kx7Q4Xt4pr4YzCz)0nfVEWzmju2AjVXwmtYRh41UkE8td5vV)mVHJ6EF)bfmr7d8p51UkE8e(td5vV)eY4iEDj0Rn(NiC5mUSFIznMH5TRIPjGOP7rRdEfjBT0ZZsyeB4a0ner0eb0Ki)jkdKILUHJzh(Gc27pOGjAEG)jV2vXJNWFAiV69NK9g3nKL3Y5FIYaPyPB4y2HpOG9(dkya2h4FYRDv84j8NgYRE)j2I8glHoUiI)jkdKILUHJzh(Gc27V)tO)a)Gc2d8p51UkE8e(teUCgx2pDtXRhCgtcLTwYBSfZK86bETRIh)0qE17pZB4OU33Fqb8h4FYRDv84j8NiC5mUSFQB0bstzPjKbDjMJ5LMiGM0n6adKgG(PH8Q3FQv2suTXsOJlI43Fqf5d8p51UkE8e(teUCgx2pVhToG6gpQ1CEini0okpCIOjGOjILMUhToG6gpQ1CEini0okpGzsRwinranbwaC0uMOPy0GMelMMUhToCvhSS1s3u9cdNiAciA6E06WvDWYwlDt1lmGzsRwinranbwaC0uMOPy0GMiUFAiV69NylYBSe64Ii(9huaZd8p51UkE8e(teUCgx2pVhToG6gpQ1CEini0okpCIOjGOjILMUhToG6gpQ1CEini0okpGzsRwinranbwaC0uMOPy0GMelMMUhToCvhSS1s3u9cdNiAciA6E06WvDWYwlDt1lmGzsRwinranbwaC0uMOPy0GMiUFAiV69NK9g3nKL3Y53Fqb3d8p51UkE8e(teUCgx2p1n6aPPS0eYGUeZX8steqt6gDGbsdq)0qE17pjQukjQjjTD8(dAM)a)tETRIhpH)eHlNXL9tDJoqAklnHmOlXCmV0eb0KUrhyG0a0pnKx9(tOZSs6yl69hur7d8p51UkE8e(teUCgx2p1n6aPPS0eYGUeZX8steqt6gDGbsdq0eq0e4PjVqevBmnbenbEA6E06ajt24mKTwQoOAihy2iHHtenbenrS0K(OusmJYB4yw6fjtteqtGfahnLjAkgnOjXIPjWttJ2d5k1qxywEBYBWler1gttartGNMUhToG6gpQ1CEini0okpCIOjI7NgYRE)zUsn0fML3M8((dQO5b(N8AxfpEc)jcxoJl7N3Jwhi7nUBil1hCgbOBiIOjINMahnbenbEAc1TA052aQB8OwZ5H0Gq7O8aMjTAH)0qE17pj7nUBilVLZV)GcyFG)jV2vXJNWFIWLZ4Y(59O1bHQigdLcXBtgor0eq00O9aKXr86sOxBCaZKwTqAIaAcWqtzIMIrdAsSyAA0EaY4iEDj0RnoGznMH5TRIPjGOjWtt3JwhqDJh1AopKgeAhLhor)0qE17pHmoIxxc9AJF)bfmr9a)tETRIhpH)eHlNXL9tWtt3JwhqDJh1AopKgeAhLhor)0qE17pnj5bpySS1seUZbF)bfmWEG)PH8Q3FI6gpQ1CEini0ok)N8AxfpEcF)bfma)b(N8AxfpEc)jcxoJl7N3Jwhi7nUBil1hCgHtenjwmnPB0bstzPjKbDjMJ5LMiEAs3OdmqAaIMerAcWffnben5MIxpiufXyOuiEBYaV2vXdAsSyAs3OdKMYstid6smhZlnr80KUrhyG0aenjI0ey0eq0KBkE9GZysOS1sEJTyMKxpWRDv8GMelMMUhToG6gpQ1CEini0okpCI(PH8Q3Fs2BC3qwElNF)bfmr(a)td5vV)eBrEJLqhxeX)Kx7Q4Xt47pOGbyEG)jV2vXJNWFIWLZ4Y(5O9qUsn0fML3M8gWSgZW82vX)0qE17pZvQHUWS82K33FqbdCpW)Kx7Q4Xt4pr4YzCz)8E06GqveJHsH4TjdNOFAiV69NqghXRlHETXV)(pZPRh4huWEG)jV2vXJNWFIWLZ4Y(PUrhinLLMqg0LyoMxAIaAs3OdmqAaIMaIMCtXRhCgtcLTwYBSfZK86bETRIh)0qE17pZB4OU33Fqb8h4FYRDv84j8NiC5mUSFEpAD4QoyzRLUP6fgor0eq009O1HR6GLTw6MQxyaZKwTqAIaAkgn(PH8Q3Fs2BC3qwElNF)bvKpW)Kx7Q4Xt4pr4YzCz)8E06WvDWYwlDt1lmCIOjGOP7rRdx1blBT0nvVWaMjTAH0eb0umA8td5vV)eBrEJLqhxeXV)GcyEG)jV2vXJNWFIWLZ4Y(59O1bHQigdLcXBtgor0eq009O1bHQigdLcXBtgWmPvlKMiGMalaoAkt0umAqtIfttGNMgThGmoIxxc9AJdEHiQ24FAiV69NqghXRlHETXV)GcUh4FYRDv84j8NiC5mUSFQpkLeZO8goMLErY0eb0eybWrtzIMIrdAciAs3OdKMYstid6smhZlnranPB0bginartIfttelnTmGCzUsEBYBqOwzEPyAciAA0EaY4iEDj0Rno4fIOAJPjGOPr7biJJ41LqV24aM1ygM3UkMMelMMwgqUmxjVn5neLNXnzVmnbenbEA6E06azVXDdzP(GZiCIOjGOjDJoqAklnHmOlXCmV0eb0KUrhyG0aenjI0KH8Q3arLsjrnjPTJaYGUeZX8stzIMejnrC)0qE17pZvQHUWS82K33FqZ8h4FYRDv84j8NiC5mUSFQB0bstzPjKbDjMJ5LMiGM0n6adKgGOjrKM0n6adyoM3FAiV69NevkLe1KK2oE)bv0(a)td5vV)0KKh8GXYwlr4oh8N8AxfpEcF)bv08a)tETRIhpH)eHlNXL9tDJoqAklnHmOlXCmV0eb0KUrhyG0a0pnKx9(tOZSs6yl69hua7d8p51UkE8e(teUCgx2p1hLsIzuEdhZsVizAIaAcSa4OPmrtXOXpnKx9(ZCLAOlmlVn599huWe1d8pnKx9(tu34rTMZdPbH2r5)Kx7Q4Xt47pOGb2d8p51UkE8e(teUCgx2pVhToiufXyOuiEBYWjIMaIMgThGmoIxxc9AJdyM0QfsteqtagAkt0umA8td5vV)eY4iEDj0Rn(9huWa8h4FYRDv84j8NiC5mUSFoApaZJTOLvYBtEdEHiQ2yAsSyA6E06azVXDdzP(GZiaDdrenjGMa3pnKx9(tYEJ7gYYB587pOGjYh4FYRDv84j8NiC5mUSFUmGCzUsEBYBaMhBrlROjGOPr7biJJ41LqV24aMjTAH0eXttGJMYenfJg)0qE17pZvQHUWS82K33FqbdW8a)tETRIhpH)eHlNXL9tmRXmmVDv8pnKx9(tiJJ41LqV243FqbdCpW)Kx7Q4Xt4pr4YzCz)e8009O1bYEJ7gYs9bNraZKwTWFAiV69NO8gryJe((dkyz(d8pnKx9(tYEJ7gYYB58p51UkE8e((dkyI2h4FAiV69NylYBSe64Ii(N8AxfpEcF)bfmrZd8p51UkE8e(teUCgx2pVhToiufXyOuiEBYWj6NgYRE)jKXr86sOxB87pOGbyFG)jV2vXJNWFIWLZ4Y(5YaYL5k5TjVbHAL5LIPjGOPr7biJJ41LqV24GxiIQnMMelMMwgqUmxjVn5neLNXnzVmnjwmnTmGCzUsEBYBaMhBrlR(PH8Q3FMRudDHz5TjVV)(pTOC66b(bfSh4FYRDv84j8NiC5mUSFEpAD4QoyzRLUP6fgor0eq009O1HR6GLTw6MQxyaZKwTqAIaAkgn(PH8Q3Fs2BC3qwElNF)bfWFG)jV2vXJNWFIWLZ4Y(59O1HR6GLTw6MQxy4ertart3JwhUQdw2APBQEHbmtA1cPjcOPy04NgYRE)j2I8glHoUiIF)bvKpW)Kx7Q4Xt4pr4YzCz)e800O9aKXr86sOxBCWler1g)td5vV)eY4iEDj0Rn(9huaZd8pnKx9(ttsEWdglBTeH7CWFYRDv84j89huW9a)tETRIhpH)eHlNXL9t9rPKygL3WXS0lsMMiGMalaoAkt0umAqtIftt6gDG0uwAczqxI5yEPjcOjDJoWaPbiAciAIyPPLbKlZvYBtEdc1kZlfttartJ2dqghXRlHETXbVqevBmnbennApazCeVUe61ghWSgZW82vX0KyX00YaYL5k5TjVHO8mUj7LPjGOjWtt3Jwhi7nUBil1hCgHtenbenPB0bstzPjKbDjMJ5LMiGM0n6adKgGOjrKMmKx9giQukjQjjTDeqg0LyoMxAkt0KiPjI7NgYRE)zUsn0fML3M8((dAM)a)td5vV)e1nEuR58qAqODu(p51UkE8e((dQO9b(N8AxfpEc)jcxoJl7N3Jwhi7nUBil1hCgbmtA1cPjGOPLbKlZvYBtEdr5zCt2l)td5vV)KS34UHS8wo)(dQO5b(N8AxfpEc)jcxoJl7N6JsjXmkVHJzPxKmnranbwaC0uMOPy0GMaIM0n6aPPS0eYGUeZX8steqt6gDGbsdq0KistaUO(PH8Q3FsuPusutsA749hua7d8p51UkE8e(teUCgx2p1n6aPPS0eYGUeZX8steqt6gDGbsdq)0qE17pHoZkPJTO3FqbtupW)Kx7Q4Xt4pr4YzCz)8E06GxrYwl98SegXgoaDdrenjGMejnjwmnnApaZJTOLvYBtEdEHiQ24FAiV69NylYBSe64Ii(9huWa7b(N8AxfpEc)jcxoJl7NJ2dW8ylAzL82K3GxiIQn(NgYRE)jzVXDdz5TC(9huWa8h4FYRDv84j8NiC5mUSFUmGCzUsEBYBaMhBrlROjGOjDJoqAI4PjrkkAciAA0EaY4iEDj0RnoGzsRwinr80e4OPmrtXOXpnKx9(ZCLAOlmlVn599huWe5d8p51UkE8e(teUCgx2pbpnDpADGS34UHSuFWzeWmPvl8NgYRE)jkVre2iHV)GcgG5b(N8AxfpEc)jcxoJl7NywJzyE7Q4FAiV69NqghXRlHETXV)Gcg4EG)jV2vXJNWFIWLZ4Y(PUrhinLLMqg0LyoMxAIaAs3OdmqAaIMaIMiwA6E06azVXDdzP(GZiaDdrenranboAsSyAs3OdKMiGMmKx9gi7nUBilVLZbudDAI4(PH8Q3FsuPusutsA749huWY8h4FAiV69NylYBSe64Ii(N8AxfpEcF)bfmr7d8p51UkE8e(teUCgx2pVhToq2BC3qwQp4mcNiAsSyAs3OdKMiEAcWikAsSyAA0EaMhBrlRK3M8g8cruTX)0qE17pj7nUBilVLZV)GcMO5b(N8AxfpEc)jcxoJl7NldixMRK3M8geQvMxkMMaIMgThGmoIxxc9AJdEHiQ2yAsSyAAza5YCL82K3quEg3K9Y0KyX00YaYL5k5TjVbyESfTSIMaIM0n6aPjINMaNO(PH8Q3FMRudDHz5TjVV)(pJWmQjVM)a)Gc2d8pnKx9(t4HKSxze7)Kx7Q4Xt47pOa(d8pnKx9(ZO2RE)jV2vXJNW3Fqf5d8p51UkE8e(Z1i5FAIamVHnOu3RlBTmQZX4FAiV69NMiaZBydk196YwlJ6Cm(9huaZd8p51UkE8e(td5vV)eLbs1oU3cjVkd6)eHlNXL9tWttyRgswiE9qTcDulJTRIdmGkOd)jR1mYLRrY)eLbs1oU3cjVkd6V)GcUh4FAiV69NXhdpkBLTwAIaJBp)p51UkE8e((dAM)a)td5vV)e6mRKo2I(jV2vXJNW3FqfTpW)0qE17pZB4OU3FYRDv84j893)jAaFGFqb7b(N8AxfpEc)jcxoJl7NOUvJo3gqDJh1AopKgeAhLhWmPvlKMiEAsKI6NgYRE)5v19qQp4mE)bfWFG)jV2vXJNWFIWLZ4Y(jQB1OZTbu34rTMZdPbH2r5bmtA1cPjINMePO(PH8Q3FAlIHo2usKPuV)GkYh4FYRDv84j8NiC5mUSFI6wn6CBa1nEuR58qAqODuEaZKwTqAI4PjrkQFAiV69N6cZxv3J3FqbmpW)0qE17pvvCEhkZmoJysE9FYRDv84j89huW9a)tETRIhpH)eHlNXL9tu3QrNBdOUXJAnNhsdcTJYdyM0QfstepnL5IIMelMM8IKLElhftteqtGjYFAiV69Nxgdzmr1g)(dAM)a)tETRIhpH)eHlNXL9Z7rRdOUXJAnNhsdcTJYdNiAciAIyPP7rRdxgdzmr1ghor0KyX009O1HRQ7HuFWzeor0KyX0e4PjSH4GJBLIMaIMapnHnehAmIMioAsSyAIyPjuVWdPDvCiQ9QxzRLN9IRHIhs9bNbnben5fjl9wokMMiGMYCWOjXIPjVizP3YrX0eb0eGN50eX9td5vV)mQ9Q33FqfTpW)Kx7Q4Xt4pr4YzCz)0nCm7HrbDBrmnr8cOPm)NgYRE)PbJyKlBT0ZZs2Iv87pOIMh4FYRDv84j8NgYRE)PbZlKTmuInrOXsuJn1pr4YzCz)KZmpvuepcdCDVQAJL1suupOjGOjILMg89O1bSjcnwIASPKd(E06WOZT0KyX0KxKS0BzeYLIuu0eb0ey0KyX0eXst5zt55driNMiGMePOOjGOP7rRdXhdpkBLTwAIaJBpF4ertIftt3JwhizYgNHS1s1bvd5aZgjmCIOjIJMioAsSyAIyPjWttCM5PII4ryGR7vvBSSwII6bnbenrS009O1bsMSXziBTuDq1qoWSrcdNiAsSyA6E06q8XWJYwzRLMiW42Zhor0eXrtIfttd(E06a2eHglrn2uYbFpADy05wAI4OjXIPjVizP3YrX0eb0eGlQFUgj)tdMxiBzOeBIqJLOgBQ3FqbSpW)Kx7Q4Xt4pnKx9(ZytXitPymuE7E)jcxoJl7NOUvJo3gizYgNHS1s1bvd5aZgjmGzsRwinjwmn5MIxpKRudDHzzT6dS6nWRDv8GMaIMqDRgDUnG6gpQ1CEini0okpGzsRwinjwmnH6wn6CBaLbs1oU3cjVkd6bmtA1cPjXIPjWttmeYlIdKmzJZq2AP6GQHCGzJegiTmJgttartOUvJo3gqDJh1AopKgeAhLhWmPvl8NRrY)m2umYukgdL3U33FqbtupW)Kx7Q4Xt4pxJK)PjcW8g2GsDVUS1YOohJ)PH8Q3FAIamVHnOu3RlBTmQZX43FqbdSh4FAiV69N6gDG8qAIaJlNLx2i)jV2vXJNW3FqbdWFG)jV2vXJNWFIWLZ4Y(PUrhinranPB0bginartIinjsrrtart3JwhqDJh1AopKgeAhLhor)0qE17pjzYgNHS1s1bvd5aZgj89huWe5d8p51UkE8e(teUCgx2pVhToG6gpQ1CEini0okpCI(PH8Q3FEvDpKTw65zjVmzgV)GcgG5b(NgYRE)z0bx6mQnwEvg0)jV2vXJNW3FqbdCpW)0qE17pJpgEu2kBT0ebg3E(FYRDv84j89huWY8h4FAiV69N4kksXYALWidX)Kx7Q4Xt47pOGjAFG)jV2vXJNWFIWLZ4Y(P(OusmJYB4yw6fjtteqtGrtzIMIrJFAiV69NOEr86yZ5HuRms(9huWenpW)Kx7Q4Xt4pr4YzCz)8E06aMrePyiuQBmIdNOFAiV69NEEwE2BF2Hu3ye)(dkya2h4FAiV69N5ASAiexReZWETfX)Kx7Q4Xt47V)ZbRTJYFGFqb7b(N8AxfpEc)jcxoJl7Nd(E06aYGETXHtenjwmnn47rRdJcgXkLDvSK0Ilu4ertIfttd(E06WOGrSszxfl5fBXC4e9td5vV)ezkL0qE1Ruvq)NQc6Y1i5FE8svEgV)Gc4pW)0qE17ppqwwotc)jV2vXJNW3Fqf5d8p51UkE8e(td5vV)ezkL0qE1Ruvq)NQc6Y1i5FIgW3FqbmpW)Kx7Q4Xt4pr4YzCz)0qEjel5LjlgsteqtIKMaIMCtXRhq5nIWgjmWRDv8GMaIMCtXRhmvuEtgH5H5noWRDv84NgYRE)jYukPH8QxPQG(pvf0LRrY)0IYPR3Fqb3d8p51UkE8e(teUCgx2pnKxcXsEzYIH0eb0KiPjGOj3u86buEJiSrcd8Axfp(PH8Q3FImLsAiV6vQkO)tvbD5AK8pZPR3FqZ8h4FYRDv84j8NiC5mUSFAiVeIL8YKfdPjcOjrstartGNMCtXRhmvuEtgH5H5noWRDv8GMaIMapn5MIxpKRudDHzzT6dS6nWRDv84NgYRE)jYukPH8QxPQG(pvf0LRrY)e6V)GkAFG)jV2vXJNWFIWLZ4Y(PH8siwYltwmKMiGMejnben5MIxpyQO8MmcZdZBCGx7Q4bnbenbEAYnfVEixPg6cZYA1hy1BGx7Q4XpnKx9(tKPusd5vVsvb9FQkOlxJK)Pfb93FqfnpW)Kx7Q4Xt4pr4YzCz)0qEjel5LjlgsteqtIKMaIMCtXRhmvuEtgH5H5noWRDv8GMaIMCtXRhYvQHUWSSw9bw9g41UkE8td5vV)ezkL0qE1Ruvq)NQc6Y1i5FAr5017pOa2h4FYRDv84j8NiC5mUSFAiVeIL8YKfdPjcOjrstartGNMCtXRhmvuEtgH5H5noWRDv8GMaIMCtXRhYvQHUWSSw9bw9g41UkE8td5vV)ezkL0qE1Ruvq)NQc6Y1i5FMtxV)GcMOEG)jV2vXJNWFIWLZ4Y(PH8siwYltwmKMiEAcSFAiV69NitPKgYRELQc6)uvqxUgj)tKInH43FqbdSh4FAiV69NOEr86yZ5HuRms(N8AxfpEcF)bfma)b(NgYRE)PHr2YsVXyE9FYRDv84j893)5Xlv5z8a)Gc2d8pnKx9(tYJiick(N8AxfpEcF)bfWFG)PH8Q3FczmVLNHCCG(p51UkE8e((dQiFG)PH8Q3FcJAmlrQ(m(jV2vXJNW3FqbmpW)0qE17pHD75RnwMZCg)tETRIhpHV)GcUh4FAiV69NWElK8QmO)tETRIhpHV)GM5pW)0qE17px2ZZyjmFJi6N8AxfpEcF)bv0(a)td5vV)eLVYmkO0X2MzEkv5z8tETRIhpHV)GkAEG)PH8Q3FcJkC5sy(gr0p51UkE8e((dkG9b(NgYRE)5A(bZqzm2q8p51UkE8e((7V)tHymS69bfWffyawrjAeLi)zodV1gd)jXKKrn25bnbyPjd5vV0KQGomqb4NWig9Gc4GdC)mc36sX)u0PP5blujKPOjIjoRZykaIonL39iiXaqajU88NBa1KGalYJY8Qxe20oiWIebcfarNMMCKZKxgttaUOeMMaCrbgGLcafarNMYSZBBmdjgqbq0PjrKMighdEqtzwhrqeumn5nnnyTDuonziV6LMuf0duaeDAsePPm782gZdAYnCm7YsttmGIWmew9cPjVPjugiflDdhZomqbq0PjrKMYS6rPlEqtidlelrdmn5nnLRXertKnMPj2GLkdAkx55Pjpptt2y0lXWqAQiJumjVU5vV0uRPjHmCzxfhOai60KisteJJbpOPJxQYZGMigjMIy6afakaIonrmdqm648GMUSUXmnHAYR500LJRfgOjIreIJCinT9kI5nmP(OOjd5vVqAQxvgbkaIonziV6fgIWmQjVMlqRmiruaeDAYqE1lmeHzutEnpRaqStmjVU5vVuaeDAYqE1lmeHzutEnpRaq0DpOayiV6fgIWmQjVMNvaiWdjzVYi2Pai600CTiy(2PjSvdA6E0AEqtq3CinDzDJzAc1KxZPPlhxlKMSDqtryweJA3RnMMkinn6LduaeDAYqE1lmeHzutEnpRaqGRfbZ3Ue6MdPayiV6fgIWmQjVMNvairTx9sbWqE1lmeHzutEnpRaqoqwwotk8AKSateG5nSbL6EDzRLrDogtbWqE1lmeHzutEnpRaqoqwwotkmR1mYLRrYcqzGuTJ7TqYRYGUWLwa4XwnKSq86HAf6OwgBxfhyavqhsbWqE1lmeHzutEnpRaqIpgEu2kBT0ebg3EEkagYREHHimJAYR5zfac0zwjDSfrbWqE1lmeHzutEnpRaqYB4OUxkauamKx9cdhVuLNHaYJiickMcGH8Qxy44LQ8mYkaeiJ5T8mKJd0PayiV6fgoEPkpJScabg1ywIu9zqbWqE1lmC8svEgzfacSBpFTXYCMZykagYREHHJxQYZiRaqG9wi5vzqNcGH8Qxy44LQ8mYkaKL98mwcZ3iIOayiV6fgoEPkpJScabLVYmkO0X2MzEkv5zqbWqE1lmC8svEgzfacmQWLlH5BeruamKx9cdhVuLNrwbGSMFWmugJnetbGcGOtteZaeJoopOjwigNbn5fjttEEMMmK3yAQG0KjKvk7Q4afad5vVqbitPKgYRELQc6cVgjl44LQ8meU0cg89O1bKb9AJdNiXIh89O1HrbJyLYUkwsAXfkCIelEW3JwhgfmIvk7QyjVylMdNikagYREHzfaYbYYYzsifad5vVWScabzkL0qE1Ruvqx41izbObKcGH8QxywbGGmLsAiV6vQkOl8AKSalkNUeU0cmKxcXsEzYIHeisGCtXRhq5nIWgjmWRDv8ai3u86btfL3KryEyEJd8AxfpOayiV6fMvaiitPKgYRELQc6cVgjliNUeU0cmKxcXsEzYIHeisGCtXRhq5nIWgjmWRDv8GcGH8QxywbGGmLsAiV6vQkOl8AKSaOlCPfyiVeIL8YKfdjqKabE3u86btfL3KryEyEJd8Axfpac8UP41d5k1qxywwR(aREd8AxfpOayiV6fMvaiitPKgYRELQc6cVgjlWIGUWLwGH8siwYltwmKarcKBkE9GPIYBYimpmVXbETRIhabE3u86HCLAOlmlRvFGvVbETRIhuamKx9cZkaeKPusd5vVsvbDHxJKfyr50LWLwGH8siwYltwmKarcKBkE9GPIYBYimpmVXbETRIha5MIxpKRudDHzzT6dS6nWRDv8GcGH8QxywbGGmLsAiV6vQkOl8AKSGC6s4slWqEjel5LjlgsGibc8UP41dMkkVjJW8W8gh41UkEaKBkE9qUsn0fML1QpWQ3aV2vXdkagYREHzfacYukPH8QxPQGUWRrYcqk2eIfU0cmKxcXsEzYIHepyuamKx9cZkaeuViEDS58qQvgjtbWqE1lmRaqmmYww6ngZRtbGcGH8QxyWIGUaYEJ7gYYB5SWLwW9O1bu34rTMZdPbH2r5Hteqe79O1bu34rTMZdPbH2r5bmtA1cjaSa4YumAiw89O1HR6GLTw6MQxy4eb09O1HR6GLTw6MQxyaZKwTqcalaUmfJgehfad5vVWGfb9ScabBrEJLqhxeXcxAb3JwhqDJh1AopKgeAhLhorarS3JwhqDJh1AopKgeAhLhWmPvlKaWcGltXOHyX3JwhUQdw2APBQEHHteq3JwhUQdw2APBQEHbmtA1cjaSa4YumAqCuamKx9cdwe0ZkaeTYwIQnwcDCrelCPfOB0bMfzqxI5yEjq3OdmqAaIcGH8QxyWIGEwbGquPusutsA7q4slqFukjMr5nCml9IKjaSa4YumAaKUrhywKbDjMJ5LaDJoWaPbiremrrbWqE1lmyrqpRaqGoZkPJTiHlTaDJoWSid6smhZlb6gDGbsdquamKx9cdwe0ZkaKCLAOlmlVn5v4slq3OdmlYGUeZX8sGUrhyG0aeqG3ler1gde4VhToqYKnodzRLQdQgYbMnsy4ebeXQpkLeZO8goMLErYeawaCzkgnelg8J2d5k1qxywEBYBWler1gde4VhToG6gpQ1CEini0okpCIiokagYREHblc6zfacKXr86sOxBSWLwa4hThGmoIxxc9AJdEHiQ2yGa)9O1bu34rTMZdPbH2r5Htefad5vVWGfb9ScaHOsPKOMK02HWLwGUrhywKbDjMJ5LaDJoWaPbiGi27rRdK9g3nKL6doJa0nereaoXI1n6ajWqE1BGS34UHS8wohqn0jokagYREHblc6zfacKXr86sOxBSWLwaM1ygM3UkgiWFpADa1nEuR58qAqODuE4eb09O1bYEJ7gYs9bNra6gIicahfad5vVWGfb9ScaXKKh8GXYwlr4ohu4sla83JwhqDJh1AopKgeAhLhoruamKx9cdwe0Zkaeu34rTMZdPbH2r5uamKx9cdwe0ZkaeYEJ7gYYB5SWLwW9O1bYEJ7gYs9bNr4ejwSUrhywKbDjMJ5L41n6adKgGerWeLyX3JwhqDJh1AopKgeAhLhoruamKx9cdwe0ZkaeSf5nwcDCretbWqE1lmyrqpRaqYvQHUWS82KxHlTaW7fIOAJPaqbWqE1lmyr50LaYEJ7gYYB5SWLwW9O1HR6GLTw6MQxy4eb09O1HR6GLTw6MQxyaZKwTqcIrdkagYREHblkNUYkaeSf5nwcDCrelCPfCpAD4QoyzRLUP6fgoraDpAD4QoyzRLUP6fgWmPvlKGy0GcGH8QxyWIYPRScabY4iEDj0Rnw4sla8J2dqghXRlHETXbVqevBmfad5vVWGfLtxzfaIjjp4bJLTwIWDoifad5vVWGfLtxzfasUsn0fML3M8kCPfOpkLeZO8goMLErYeawaCzkgnelw3OdmlYGUeZX8sGUrhyG0aeqe7YaYL5k5TjVbHAL5LIbA0EaY4iEDj0Rno4fIOAJbA0EaY4iEDj0RnoGznMH5TRIflEza5YCL82K3quEg3K9Yab(7rRdK9g3nKL6doJWjciDJoWSid6smhZlb6gDGbsdqIOH8Q3arLsjrnjPTJaYGUeZX8MjrsCuamKx9cdwuoDLvaiOUXJAnNhsdcTJYPayiV6fgSOC6kRaqi7nUBilVLZcxAb3Jwhi7nUBil1hCgbmtA1cbAza5YCL82K3quEg3K9YuamKx9cdwuoDLvaievkLe1KK2oeU0c0hLsIzuEdhZsVizcalaUmfJgaPB0bMfzqxI5yEjq3OdmqAasebCrrbWqE1lmyr50vwbGaDMvshBrcxAb6gDGzrg0LyoMxc0n6adKgGOayiV6fgSOC6kRaqWwK3yj0XfrSWLwW9O1bVIKTw65zjmInCa6gIibIuS4r7byESfTSsEBYBWler1gtbWqE1lmyr50vwbGq2BC3qwElNfU0cgThG5Xw0Yk5TjVbVqevBmfad5vVWGfLtxzfasUsn0fML3M8kCPfSmGCzUsEBYBaMhBrlRas3OdK4fPOaA0EaY4iEDj0RnoGzsRwiXdUmfJguamKx9cdwuoDLvaiO8gryJekCPfa(7rRdK9g3nKL6doJaMjTAHuamKx9cdwuoDLvaiqghXRlHETXcxAbywJzyE7QykagYREHblkNUYkaeIkLsIAssBhcxAb6gDGzrg0LyoMxc0n6adKgGaIyVhToq2BC3qwQp4mcq3qera4elw3OdKad5vVbYEJ7gYYB5Ca1qN4OayiV6fgSOC6kRaqWwK3yj0Xfrmfad5vVWGfLtxzfaczVXDdz5TCw4sl4E06azVXDdzP(GZiCIelw3OdK4bmIsS4r7byESfTSsEBYBWler1gtbWqE1lmyr50vwbGKRudDHz5TjVcxAbldixMRK3M8geQvMxkgOr7biJJ41LqV24GxiIQnwS4LbKlZvYBtEdr5zCt2llw8YaYL5k5TjVbyESfTSciDJoqIhCIIcafad5vVWaAafCvDpK6dodHlTau3QrNBdOUXJAnNhsdcTJYdyM0Qfs8IuuuamKx9cdObmRaqSfXqhBkjYukHlTau3QrNBdOUXJAnNhsdcTJYdyM0Qfs8IuuuamKx9cdObmRaq0fMVQUhcxAbOUvJo3gqDJh1AopKgeAhLhWmPvlK4fPOOayiV6fgqdywbGOQ48ouMzCgXK86uamKx9cdObmRaqUmgYyIQnw4sla1TA052aQB8OwZ5H0Gq7O8aMjTAHeFMlkXI9IKLElhftayIKcGH8QxyanGzfasu7vVcxAb3JwhqDJh1AopKgeAhLhorarS3JwhUmgYyIQnoCIel(E06Wv19qQp4mcNiXIbp2qCWXTsbe4XgIdngrCIftSOEHhs7Q4qu7vVYwlp7fxdfpK6dodG8IKLElhftqMdMyXErYsVLJIjaWZCIJcGH8QxyanGzfaIbJyKlBT0ZZs2IvSWLwGB4y2dJc62IyIxqMtbWqE1lmGgWSca5azz5mPWRrYcmyEHSLHsSjcnwIASPeU0c4mZtffXJWax3RQ2yzTef1dGi2bFpADaBIqJLOgBk5GVhTom6CRyXErYsVLrixksrrayIftS5zt55driNarkkGUhToeFm8OSv2APjcmU98HtKyX3JwhizYgNHS1s1bvd5aZgjmCIioItSyIf8CM5PII4ryGR7vvBSSwII6bqe79O1bsMSXziBTuDq1qoWSrcdNiXIVhToeFm8OSv2APjcmU98HteXjw8GVhToGnrOXsuJnLCW3JwhgDUL4el2lsw6TCumbaUOOayiV6fgqdywbGCGSSCMu41izbXMIrMsXyO829kCPfG6wn6CBGKjBCgYwlvhunKdmBKWaMjTAHIf7MIxpKRudDHzzT6dS6nWRDv8aiu3QrNBdOUXJAnNhsdcTJYdyM0QfkwmQB1OZTbugiv74ElK8QmOhWmPvluSyWZqiVioqYKnodzRLQdQgYbMnsyG0YmAmqOUvJo3gqDJh1AopKgeAhLhWmPvlKcGH8QxyanGzfaYbYYYzsHxJKfyIamVHnOu3RlBTmQZXykagYREHb0aMvai6gDG8qAIaJlNLx2iPayiV6fgqdywbGqYKnodzRLQdQgYbMnsOWLwGUrhib6gDGbsdqIOiffq3JwhqDJh1AopKgeAhLhoruamKx9cdObmRaqUQUhYwl98SKxMmdHlTG7rRdOUXJAnNhsdcTJYdNikagYREHb0aMvairhCPZO2y5vzqNcGH8QxyanGzfas8XWJYwzRLMiW42ZtbWqE1lmGgWScabxrrkwwRegziMcGH8QxyanGzfacQxeVo2CEi1kJKfU0c0hLsIzuEdhZsVizcaltXObfad5vVWaAaZkaepplp7Tp7qQBmIfU0cUhToGzerkgcL6gJ4WjIcGH8QxyanGzfasUgRgcX1kXmSxBrmfakagYREHbKInHybcz4YUkw41izbidlelrdSWDKai7LwyHm1HfyiVeIL8YKfdfwitDyjRGSaWjmQ3r5vVcmKxcXsEzYIHeaokagYREHbKInH4ScaXKKh8GXYwlr4ohKcGH8QxyaPytioRaqqDJh1AopKgeAhLtbWqE1lmGuSjeNvaiidlelCPfmApaZJTOLvYBtEdEHiQ2ykagYREHbKInH4ScajxPg6cZYBtEfU0caVBkE9q8HX4sPmPBiVqWaV2vXdXI1hLsIzuEdhZsVizcIrdkagYREHbKInH4ScaHS34UHS8wolmkdKILUHJzhkamHlTGbFpADqzoVUmQlyVbOBiIeaMOOayiV6fgqk2eIZkaeuEJiSrcPayiV6fgqk2eIZkaeIkLsIAssBhcJYaPyPB4y2Hcat4slq3OdmlYGUeZX8sGUrhyG0aefad5vVWasXMqCwbGCpokpJZq4slqFukjMr5nCml9IKjignelg8UP41d5k1qxywwR(aREd8AxfpelE0EaMhBrlRK3M8g8cruTXanApuRZ41uYRI5rTXbOBiIiqKuamKx9cdifBcXzfacYWcXcxAbUP41dXhgJlLYKUH8cbd8AxfpOayiV6fgqk2eIZkaeTYwIQnwcDCrelCPfOB0bMfzqxI5yEjq3OdmqAaIcGH8QxyaPytioRaqYvQHUWS82KxHlTGr7HCLAOlmlVn5nGznMH5TRIfl2nfVEixPg6cZYA1hy1BGx7Q4bfad5vVWasXMqCwbGazCeVUe61glmkdKILUHJzhkamHlTG7rRdcvrmgkfI3MmGzd5uamKx9cdifBcXzfacYWcXcxAbOUvJo3gYvQHUWS82K3aMjTAHeVqgUSRIdidlelrdmXCaNcGH8QxyaPytioRaqGoZkPJTikagYREHbKInH4ScajVHJ6EfU0cCtXRhCgtcLTwYBSfZK86bETRIhuamKx9cdifBcXzfacKXr86sOxBSWOmqkw6goMDOaWeU0cWSgZW82vXaDpADWRizRLEEwcJydhGUHiIarsbq0PjGBAcwKhL5mnDGwmtt6gttzw9g3nKPjclNPPgttedzrEJPPPJlIyAACW1gtteJWig50uRPjpptteZSyflmnH6OmOj2q5PPgHoymViMMAnn55zAYqE1lnz7GMSOiEh0KKTyfttEttEEMMmKx9stRrYbkagYREHbKInH4ScaHS34UHS8wolmkdKILUHJzhkamkagYREHbKInH4ScabBrEJLqhxeXcJYaPyPB4y2HcaJcafad5vVWa0fK3WrDVcxAbUP41doJjHYwl5n2IzsE9aV2vXdkagYREHbONvaiALTevBSe64Iiw4slq3OdmlYGUeZX8sGUrhyG0aefad5vVWa0ZkaeSf5nwcDCrelCPfCpADa1nEuR58qAqODuE4ebeXEpADa1nEuR58qAqODuEaZKwTqcalaUmfJgIfFpAD4QoyzRLUP6fgoraDpAD4QoyzRLUP6fgWmPvlKaWcGltXObXrbq0PjGBAcwKhL5mnDGwmtt6gttzw9g3nKPjclNPPgttedzrEJPPPJlIyAACW1gtteJWig50uRPjpptteZSyflmnH6OmOj2q5PPgHoymViMMAnn55zAYqE1lnz7GMSOiEh0KKTyfttEttEEMMmKx9stRrYbkagYREHbONvaiK9g3nKL3YzHlTG7rRdOUXJAnNhsdcTJYdNiGi27rRdOUXJAnNhsdcTJYdyM0QfsaybWLPy0qS47rRdx1blBT0nvVWWjcO7rRdx1blBT0nvVWaMjTAHeawaCzkgniokagYREHbONvaievkLe1KK2oeU0c0n6aZImOlXCmVeOB0bginarbWqE1lma9Scab6mRKo2IeU0c0n6aZImOlXCmVeOB0bginarbWqE1lma9ScajxPg6cZYBtEfU0c0n6aZImOlXCmVeOB0bginabe49cruTXab(7rRdKmzJZq2AP6GQHCGzJegorarS6JsjXmkVHJzPxKmbGfaxMIrdXIb)O9qUsn0fML3M8g8cruTXab(7rRdOUXJAnNhsdcTJYdNiIJcGH8Qxya6zfaczVXDdz5TCw4sl4E06azVXDdzP(GZiaDdreXdoGapQB1OZTbu34rTMZdPbH2r5bmtA1cPayiV6fgGEwbGazCeVUe61glCPfCpADqOkIXqPq82KHteqJ2dqghXRlHETXbmtA1cjaWKPy0qS4r7biJJ41LqV24aM1ygM3UkgiWFpADa1nEuR58qAqODuE4erbWqE1lma9ScaXKKh8GXYwlr4ohu4sla83JwhqDJh1AopKgeAhLhoruamKx9cdqpRaqqDJh1AopKgeAhLtbWqE1lma9ScaHS34UHS8wolCPfCpADGS34UHSuFWzeorIfRB0bMfzqxI5yEjEDJoWaPbireWffqUP41dcvrmgkfI3MmWRDv8qSyDJoWSid6smhZlXRB0bginajIGbKBkE9GZysOS1sEJTyMKxpWRDv8qS47rRdOUXJAnNhsdcTJYdNikagYREHbONvaiylYBSe64IiMcGH8Qxya6zfasUsn0fML3M8kCPfmApKRudDHz5TjVbmRXmmVDvmfad5vVWa0ZkaeiJJ41LqV2yHlTG7rRdcvrmgkfI3MmCIOaqbWqE1lmKtxcYB4OUxHlTaDJoWSid6smhZlb6gDGbsdqa5MIxp4mMekBTK3ylMj51d8AxfpOayiV6fgYPRScaHS34UHS8wolCPfCpAD4QoyzRLUP6fgoraDpAD4QoyzRLUP6fgWmPvlKGy0GcGH8QxyiNUYkaeSf5nwcDCrelCPfCpAD4QoyzRLUP6fgoraDpAD4QoyzRLUP6fgWmPvlKGy0GcGH8QxyiNUYkaeiJJ41LqV2yHlTG7rRdcvrmgkfI3MmCIa6E06GqveJHsH4TjdyM0QfsaybWLPy0qSyWpApazCeVUe61gh8cruTXuamKx9cd50vwbGKRudDHz5TjVcxAb6JsjXmkVHJzPxKmbGfaxMIrdG0n6aZImOlXCmVeOB0bginajwmXUmGCzUsEBYBqOwzEPyGgThGmoIxxc9AJdEHiQ2yGgThGmoIxxc9AJdywJzyE7QyXIxgqUmxjVn5neLNXnzVmqG)E06azVXDdzP(GZiCIas3OdmlYGUeZX8sGUrhyG0aKiAiV6nquPusutsA7iGmOlXCmVzsKehfad5vVWqoDLvaievkLe1KK2oeU0c0n6aZImOlXCmVeOB0bginajI6gDGbmhZlfad5vVWqoDLvaiMK8Ghmw2Ajc35GuamKx9cd50vwbGaDMvshBrcxAb6gDGzrg0LyoMxc0n6adKgGOayiV6fgYPRScajxPg6cZYBtEfU0c0hLsIzuEdhZsVizcalaUmfJguamKx9cd50vwbGG6gpQ1CEini0okNcGH8QxyiNUYkaeiJJ41LqV2yHlTG7rRdcvrmgkfI3MmCIaA0EaY4iEDj0RnoGzsRwibaMmfJguamKx9cd50vwbGq2BC3qwElNfU0cgThG5Xw0Yk5TjVbVqevBSyX3Jwhi7nUBil1hCgbOBiIeaokagYREHHC6kRaqYvQHUWS82KxHlTGLbKlZvYBtEdW8ylAzfqJ2dqghXRlHETXbmtA1cjEWLPy0GcGH8QxyiNUYkaeiJJ41LqV2yHlTamRXmmVDvmfad5vVWqoDLvaiO8gryJekCPfa(7rRdK9g3nKL6doJaMjTAHuamKx9cd50vwbGq2BC3qwElNPayiV6fgYPRScabBrEJLqhxeXuamKx9cd50vwbGazCeVUe61glCPfCpADqOkIXqPq82KHtefad5vVWqoDLvai5k1qxywEBYRWLwWYaYL5k5TjVbHAL5LIbA0EaY4iEDj0Rno4fIOAJflEza5YCL82K3quEg3K9YIfVmGCzUsEBYBaMhBrlRE)9)b]] )


end