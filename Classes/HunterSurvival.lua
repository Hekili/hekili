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
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cast = 0,
            charges = 2,
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


    spec:RegisterPack( "Survival", 20190722.0001, [[dCuxFbqicIhjeYLaqfTjG0NaqLmkHeoLqIwLqKxjjMfb1Tiizxc(fGAycrDmGYYes6zcbttiuxdOY2aq6BeKY4aq4CavL1buv18iG7Hq7dOkhearleb9qcsvxeOQsJeav4KaOQSsjPzcGQQBsqQStGyOaOkTuaufpvrtfq2RQ(lrdwIdt1IvPhdzYkCzuBMuFMqJws1PfTAGQkEncmBsUnI2Ts)wQHluhhavQLd1ZbnDkxxfBNa9DaA8aW5fsTEauMVKY(r6hShOFoCJFqIAKbd8fzHwuJAiYGbg4aha9Nw0X8pJDebUi)Z1j5FopybtbD1pJ9OvTpEG(jSpye)Z6Mfdb)bgyX0QFUbutcmmjpk3YEryxBadtseW)8EsLbW3(3FoCJFqIAKbd8fzHwuJ6p9JvVX)CMKhLBzVc9yxB)SEog8(3Foyi6NreTmpybtbDfTaWXzngtRgr0sDZIHG)adSyA1p3aQjbgMKhLBzViSRnGHjjcyA1iIwQEurtlrfmHPLOgzWaF0IqrlrnYG)GlIPvPvJiArOVUVIme8NwnIOfHIwaihdEqlcDhagatX0I10YG1(rz0IJSSxArLqlqRgr0Iqrlc919vKh0I5yr2KPMwyaeJzim7fslwtlOOrkwAowKnyGwnIOfHIwe66rQtEqlihlilrdmTynTayJjGwiBmtlSdtv00cGPvNwS6mT4JrVaCbPLKmwXK8AUL9slTMwe0XPFvCGwnIOfHIwaihdEqlhlvPfnTaqcWla)HFQsObFG(PhdThOheWEG(jV(vXJNWFIWPX40)59O1bu34rUUXdPdH(rzHtmTakTef0Y9O1bu34rUUXdPdH(rzbmt65cPfbOfWcGJwIeTiIg0sTA0Y9O1HR6GLTwAUQxy4etlGsl3JwhUQdw2AP5QEHbmt65cPfbOfWcGJwIeTiIg0su(thzzV)KSxXUHS8Mg)2dsuFG(jV(vXJNWFIWPX40)59O1bu34rUUXdPdH(rzHtmTakTef0Y9O1bu34rUUXdPdH(rzbmt65cPfbOfWcGJwIeTiIg0sTA0Y9O1HR6GLTwAUQxy4etlGsl3JwhUQdw2AP5QEHbmt65cPfbOfWcGJwIeTiIg0su(thzzV)e7XwJLqdNeWV9GeHhOFYRFv84j8NiCAmo9FQB0bslvOfKdnjMf5LweGw0n6adKoa(PJSS3FQv(sqUIsOHtc43EqI4hOFYRFv84j8NiCAmo9FQpkLeZO6owKLwsY0Ia0cybWrlrIwerdAbuAr3OdKwQqlihAsmlYlTiaTOB0bgiDaqlcfTawK)PJSS3FsqQusuts674TheW9a9tE9RIhpH)eHtJXP)tDJoqAPcTGCOjXSiV0Ia0IUrhyG0bWpDKL9(tOXSsAyp(Thea6d0p51VkE8e(teongN(p1n6aPLk0cYHMeZI8slcql6gDGbsha0cO0IqOflreKRiTakTieA5E06ajt24OLTwQoOCihy2jHHtmTakTef0I(OusmJQ7yrwAjjtlcqlGfahTejArenOLA1OfHqlJ2caMQHoXS82K3GLicYvKwaLwecTCpADa1nEKRB8q6qOFuw4etlr5pDKL9(tat1qNywEBY7BpicThOFYRFv84j8NiCAmo9FkeAz0waY4yEnj0YvmyjIGCfPfqPfHql3JwhqDJh56gpKoe6hLfoX)0rw27pHmoMxtcTCfF7bbG4b6N86xfpEc)jcNgJt)N6gDG0sfAb5qtIzrEPfbOfDJoWaPdaAbuAjkOL7rRdK9k2nKL6do6a0Ceb0Ia0c4OLA1OfDJoqAraAXrw2BGSxXUHS8Mghqn0OLO8NoYYE)jbPsjrnjPVJ3EqaFpq)Kx)Q4Xt4pr40yC6)eZAmdR7xftlGslcHwUhToG6gpY1nEiDi0pklCIPfqPL7rRdK9k2nKL6do6a0Ceb0Ia0c4(PJSS3FczCmVMeA5k(2dcyr(b6N86xfpEc)jcNgJt)NcHwUhToG6gpY1nEiDi0pklCI)PJSS3F6sYdEWyzRLiCdi8TheWa7b6NoYYE)jQB8ix34H0Hq)OSFYRFv84j8TheWI6d0p51VkE8e(teongN(pVhToq2Ry3qwQp4OdNyAPwnAr3OdKwQqlihAsmlYlTaE0IUrhyG0baTiu0cyrMwQvJwUhToG6gpY1nEiDi0pklCI)PJSS3Fs2Ry3qwEtJF7bbSi8a9thzzV)e7XwJLqdNeW)Kx)Q4Xt4BpiGfXpq)Kx)Q4Xt4pr40yC6)ui0ILicYv8NoYYE)jGPAOtmlVn59T3(jsXUG8d0dcypq)Kx)Q4Xt4p74Fczl1)0rw27pf0XPFv8pf0XY1j5FICSGSenW)eHtJXP)thzPGSKxMmziTiaTaUFkORoSKvq(NG7Nc6Qd)thzPGSKxMmz4Bpir9b6NoYYE)Pljp4bJLTwIWnGWFYRFv84j8ThKi8a9thzzV)e1nEKRB8q6qOFu2p51VkE8e(2dse)a9tE9RIhpH)eHtJXP)ZrBbyDShVSsEBYBWseb5k(thzzV)e5yb53Eqa3d0p51VkE8e(teongN(pfcTyUIxliEymovkxAoYsemWRFv8GwQvJw0hLsIzuDhlYsljzAraAren(PJSS3FcyQg6eZYBtEF7bbG(a9tE9RIhpH)0rw27pj7vSBilVPX)eHtJXP)ZbFpADq5gVMmUtyVbO5icOfI0cyr(NOOrkwAowKn4dcyV9Gi0EG(PJSS3FIQ7eGDs4p51VkE8e(2dcaXd0p51VkE8e(thzzV)KGuPKOMK03Xpr40yC6)u3OdKwQqlihAsmlYlTiaTOB0bgiDa8tu0iflnhlYg8bbS3EqaFpq)Kx)Q4Xt4pr40yC6)uFukjMr1DSilTKKPfbOfr0GwQvJwecTyUIxlayQg6eZYC1hy2BGx)Q4bTuRgTmAlaRJ94LvYBtEdwIiixrAbuAz0wixJXRRKxfZJCfdqZreqlcqlr4NoYYE)59yO6mo63EqalYpq)Kx)Q4Xt4pr40yC6)0CfVwq8WyCQuU0CKLiyGx)Q4XpDKL9(tKJfKF7bbmWEG(jV(vXJNWFIWPX40)PUrhiTuHwqo0KywKxAraAr3Odmq6a4NoYYE)Pw5lb5kkHgojGF7bbSO(a9tE9RIhpH)eHtJXP)ZrBbat1qNywEBYBaZAmdR7xftl1QrlMR41caMQHoXSmx9bM9g41VkE8thzzV)eWun0jML3M8(2dcyr4b6N86xfpEc)PJSS3FczCmVMeA5k(teongN(pVhToiygZyOuqEBYaMDK9tu0iflnhlYg8bbS3EqalIFG(jV(vXJNWFIWPX40)jQB1ObCdaMQHoXS82K3aMj9CH0c4rlc640VkoGCSGSenW0caN0su)PJSS3FICSG8BpiGbUhOF6il79NqJzL0WE8p51VkE8e(2dcya0hOFYRFv84j8NiCAmo9FAUIxlymMekBTKxrxKj51c86xfp(PJSS3Fw3XXDVV9GaMq7b6N86xfpEc)PJSS3FczCmVMeA5k(teongN(pXSgZW6(vX0cO0Y9O1blJLTwA1zjmMDCaAoIaAraAjc)efnsXsZXISbFqa7TheWaiEG(jV(vXJNWF6il79NK9k2nKL304FIIgPyP5yr2GpiG92dcyGVhOFYRFv84j8NoYYE)j2JTglHgojG)jkAKILMJfzd(Ga2BV9tO9a9Ga2d0p51VkE8e(teongN(pnxXRfmgtcLTwYROlYK8AbE9RIh)0rw27pR744U33EqI6d0p51VkE8e(teongN(p1n6aPLk0cYHMeZI8slcql6gDGbsha)0rw27p1kFjixrj0Wjb8Bpir4b6N86xfpEc)jcNgJt)N3JwhqDJh56gpKoe6hLfoX0cO0suql3JwhqDJh56gpKoe6hLfWmPNlKweGwalaoAjs0IiAql1Qrl3JwhUQdw2AP5QEHHtmTakTCpAD4QoyzRLMR6fgWmPNlKweGwalaoAjs0IiAqlr5pDKL9(tShBnwcnCsa)2dse)a9tE9RIhpH)eHtJXP)Z7rRdOUXJCDJhshc9JYcNyAbuAjkOL7rRdOUXJCDJhshc9JYcyM0ZfslcqlGfahTejArenOLA1OL7rRdx1blBT0CvVWWjMwaLwUhToCvhSS1sZv9cdyM0ZfslcqlGfahTejArenOLO8NoYYE)jzVIDdz5nn(TheW9a9tE9RIhpH)eHtJXP)tDJoqAPcTGCOjXSiV0Ia0IUrhyG0bWpDKL9(tcsLsIAssFhV9GaqFG(jV(vXJNWFIWPX40)PUrhiTuHwqo0KywKxAraAr3Odmq6a4NoYYE)j0ywjnSh)2dIq7b6N86xfpEc)jcNgJt)N6gDG0sfAb5qtIzrEPfbOfDJoWaPdaAbuAri0ILicYvKwaLwecTCpADGKjBC0YwlvhuoKdm7KWWjMwaLwIcArFukjMr1DSilTKKPfbOfWcGJwIeTiIg0sTA0IqOLrBbat1qNywEBYBWseb5kslGslcHwUhToG6gpY1nEiDi0pklCIPLO8NoYYE)jGPAOtmlVn59TheaIhOFYRFv84j8NiCAmo9FEpADGSxXUHSuFWrhGMJiGwapAbC0cO0IqOfu3Qrd4gqDJh56gpKoe6hLfWmPNl8NoYYE)jzVIDdz5nn(TheW3d0p51VkE8e(teongN(pVhToiygZyOuqEBYWjMwaLwgTfGmoMxtcTCfdyM0ZfslcqlrmTejArenOLA1OLrBbiJJ51KqlxXaM1ygw3VkMwaLwecTCpADa1nEKRB8q6qOFuw4e)thzzV)eY4yEnj0Yv8TheWI8d0p51VkE8e(teongN(pfcTCpADa1nEKRB8q6qOFuw4e)thzzV)0LKh8GXYwlr4gq4BpiGb2d0pDKL9(tu34rUUXdPdH(rz)Kx)Q4Xt4BpiGf1hOFYRFv84j8NiCAmo9FEpADGSxXUHSuFWrhoX0sTA0IUrhiTuHwqo0KywKxAb8OfDJoWaPdaArOOLOgzAbuAXCfVwqWmMXqPG82KbE9RIh0sTA0IUrhiTuHwqo0KywKxAb8OfDJoWaPdaArOOfWOfqPfZv8AbJXKqzRL8k6ImjVwGx)Q4bTuRgTCpADa1nEKRB8q6qOFuw4e)thzzV)KSxXUHS8Mg)2dcyr4b6NoYYE)j2JTglHgojG)jV(vXJNW3EqalIFG(jV(vXJNWFIWPX40)5OTaGPAOtmlVn5nGznMH19RI)PJSS3FcyQg6eZYBtEF7bbmW9a9tE9RIhpH)eHtJXP)Z7rRdcMXmgkfK3MmCI)PJSS3FczCmVMeA5k(2B)eqD(a9Ga2d0p51VkE8e(teongN(p1n6aPLk0cYHMeZI8slcql6gDGbsha0cO0I5kETGXysOS1sEfDrMKxlWRFv84NoYYE)zDhh39(2dsuFG(jV(vXJNWFIWPX40)59O1HR6GLTwAUQxy4etlGsl3JwhUQdw2AP5QEHbmt65cPfbOfr04NoYYE)jzVIDdz5nn(ThKi8a9tE9RIhpH)eHtJXP)Z7rRdx1blBT0CvVWWjMwaLwUhToCvhSS1sZv9cdyM0ZfslcqlIOXpDKL9(tShBnwcnCsa)2dse)a9tE9RIhpH)eHtJXP)Z7rRdcMXmgkfK3MmCIPfqPL7rRdcMXmgkfK3MmGzspxiTiaTawaC0sKOfr0GwQvJwecTmAlazCmVMeA5kgSerqUI)0rw27pHmoMxtcTCfF7bbCpq)Kx)Q4Xt4pr40yC6)uFukjMr1DSilTKKPfbOfWcGJwIeTiIg0cO0IUrhiTuHwqo0KywKxAraAr3Odmq6aGwQvJwIcAzzaysat5TjVbbBLBPIPfqPLrBbiJJ51KqlxXGLicYvKwaLwgTfGmoMxtcTCfdywJzyD)QyAPwnAzzaysat5TjVH46mUj7LPfqPfHql3Jwhi7vSBil1hC0HtmTakTOB0bslvOfKdnjMf5LweGw0n6adKoaOfHIwCKL9giivkjQjj9Deqo0KywKxAjs0seOLO8NoYYE)jGPAOtmlVn59Thea6d0p51VkE8e(teongN(p1n6aPLk0cYHMeZI8slcql6gDGbsha0Iqrl6gDGbmlY7pDKL9(tcsLsIAssFhV9Gi0EG(PJSS3F6sYdEWyzRLiCdi8N86xfpEcF7bbG4b6N86xfpEc)jcNgJt)N6gDG0sfAb5qtIzrEPfbOfDJoWaPdGF6il79NqJzL0WE8BpiGVhOFYRFv84j8NiCAmo9FQpkLeZO6owKLwsY0Ia0cybWrlrIwerJF6il79NaMQHoXS82K33EqalYpq)0rw27prDJh56gpKoe6hL9tE9RIhpHV9Gagypq)Kx)Q4Xt4pr40yC6)8E06GGzmJHsb5TjdNyAbuAz0waY4yEnj0YvmGzspxiTiaTeX0sKOfr04NoYYE)jKXX8AsOLR4BpiGf1hOFYRFv84j8NiCAmo9FoAlaRJ94LvYBtEdwIiixrAPwnA5E06azVIDdzP(GJoanhraTqKwa3pDKL9(tYEf7gYYBA8BpiGfHhOFYRFv84j8NiCAmo9FUmamjGP82K3aSo2JxwrlGslJ2cqghZRjHwUIbmt65cPfWJwahTejAren(PJSS3FcyQg6eZYBtEF7bbSi(b6N86xfpEc)jcNgJt)NywJzyD)Q4F6il79NqghZRjHwUIV9Gag4EG(jV(vXJNWFIWPX40)PqOL7rRdK9k2nKL6do6aMj9CH)0rw27pr1DcWoj8TheWaOpq)0rw27pj7vSBilVPX)Kx)Q4Xt4BpiGj0EG(PJSS3FI9yRXsOHtc4FYRFv84j8TheWaiEG(jV(vXJNWFIWPX40)59O1bbZygdLcYBtgoX)0rw27pHmoMxtcTCfF7bbmW3d0p51VkE8e(teongN(pxgaMeWuEBYBqWw5wQyAbuAz0waY4yEnj0YvmyjIGCfPLA1OLLbGjbmL3M8gIRZ4MSxMwQvJwwgaMeWuEBYBawh7XlR(PJSS3FcyQg6eZYBtEF7TF6XaQZhOheWEG(jV(vXJNWFIWPX40)59O1HR6GLTwAUQxy4etlGsl3JwhUQdw2AP5QEHbmt65cPfbOfr04NoYYE)jzVIDdz5nn(ThKO(a9tE9RIhpH)eHtJXP)Z7rRdx1blBT0CvVWWjMwaLwUhToCvhSS1sZv9cdyM0ZfslcqlIOXpDKL9(tShBnwcnCsa)2dseEG(jV(vXJNWFIWPX40)PqOLrBbiJJ51KqlxXGLicYv8NoYYE)jKXX8AsOLR4Bpir8d0pDKL9(txsEWdglBTeHBaH)Kx)Q4Xt4BpiG7b6N86xfpEc)jcNgJt)N6JsjXmQUJfzPLKmTiaTawaC0sKOfr0GwQvJw0n6aPLk0cYHMeZI8slcql6gDGbsha0cO0suqlldatcykVn5niyRClvmTakTmAlazCmVMeA5kgSerqUI0cO0YOTaKXX8AsOLRyaZAmdR7xftl1QrlldatcykVn5nexNXnzVmTakTieA5E06azVIDdzP(GJoCIPfqPfDJoqAPcTGCOjXSiV0Ia0IUrhyG0baTiu0IJSS3abPsjrnjPVJaYHMeZI8slrIwIaTeL)0rw27pbmvdDIz5TjVV9GaqFG(PJSS3FI6gpY1nEiDi0pk7N86xfpEcF7brO9a9tE9RIhpH)eHtJXP)Z7rRdK9k2nKL6do6aMj9CH0cO0YYaWKaMYBtEdX1zCt2l)thzzV)KSxXUHS8Mg)2dcaXd0p51VkE8e(teongN(p1hLsIzuDhlYsljzAraAbSa4OLirlIObTakTOB0bslvOfKdnjMf5LweGw0n6adKoaOfHIwIAK)PJSS3FsqQusuts674TheW3d0p51VkE8e(teongN(p1n6aPLk0cYHMeZI8slcql6gDGbsha)0rw27pHgZkPH943EqalYpq)Kx)Q4Xt4pr40yC6)8E06GLXYwlT6SegZooanhraTqKwIaTuRgTmAlaRJ94LvYBtEdwIiixXF6il79Nyp2ASeA4Ka(TheWa7b6N86xfpEc)jcNgJt)NJ2cW6ypEzL82K3GLicYv8NoYYE)jzVIDdz5nn(TheWI6d0p51VkE8e(teongN(pxgaMeWuEBYBawh7XlROfqPfDJoqAb8OLiezAbuAz0waY4yEnj0YvmGzspxiTaE0c4OLirlIOXpDKL9(tat1qNywEBY7BpiGfHhOFYRFv84j8NiCAmo9FkeA5E06azVIDdzP(GJoGzspx4pDKL9(tuDNaStcF7bbSi(b6N86xfpEc)jcNgJt)NywJzyD)Q4F6il79NqghZRjHwUIV9Gag4EG(jV(vXJNWFIWPX40)PUrhiTuHwqo0KywKxAraAr3Odmq6aGwaLwIcA5E06azVIDdzP(GJoanhraTiaTaoAPwnAr3OdKweGwCKL9gi7vSBilVPXbudnAjk)PJSS3FsqQusuts674TheWaOpq)0rw27pXES1yj0Wjb8p51VkE8e(2dcycThOFYRFv84j8NiCAmo9FEpADGSxXUHSuFWrhoX0sTA0IUrhiTaE0sehzAPwnAz0wawh7XlRK3M8gSerqUI)0rw27pj7vSBilVPXV9GagaXd0p51VkE8e(teongN(pxgaMeWuEBYBqWw5wQyAbuAz0waY4yEnj0YvmyjIGCfPLA1OLLbGjbmL3M8gIRZ4MSxMwQvJwwgaMeWuEBYBawh7XlROfqPfDJoqAb8OfWf5F6il79NaMQHoXS82K33E7NXyg1Kx3EGEqa7b6NoYYE)j8qs2RmMTFYRFv84j8ThKO(a9thzzV)mUTS3FYRFv84j8ThKi8a9thzzV)eAmRKg2J)jV(vXJNW3EqI4hOF6il79N1DCC37p51VkE8e(2B)enGpqpiG9a9tE9RIhpH)eHtJXP)tu3Qrd4gqDJh56gpKoe6hLfWmPNlKwapAjcr(NoYYE)5v19qQp4OF7bjQpq)Kx)Q4Xt4pr40yC6)e1TA0aUbu34rUUXdPdH(rzbmt65cPfWJwIqK)PJSS3F6lIHg2vsKRuV9GeHhOFYRFv84j8NiCAmo9FI6wnAa3aQB8ix34H0Hq)OSaMj9CH0c4rlriY)0rw27p1jMVQUhV9GeXpq)0rw27pvPyDdkb)CgIK8A)Kx)Q4Xt4BpiG7b6N86xfpEc)jcNgJt)NOUvJgWnG6gpY1nEiDi0pklGzspxiTaE0canY0sTA0ILKS0A5izAraAbSi8thzzV)8YyiJjixX3EqaOpq)Kx)Q4Xt4pr40yC6)8E06aQB8ix34H0Hq)OSWjMwaLwIcA5E06WLXqgtqUIHtmTuRgTCpAD4Q6Ei1hC0HtmTuRgTieAb7ioy4wPOfqPfHqlyhXHgJOLOKwQvJwSKKLwlhjtlcqlrfG(thzzV)mUTS33EqeApq)Kx)Q4Xt4pr40yC6)0CSiBHrcnFrmTaEePfa6pDKL9(thgZit2APvNLSlQ43EqaiEG(jV(vXJNWFUoj)thwxqFzOe7aSglrn2v)0rw27pDyDb9LHsSdWASe1yx9teongN(pVhToqYKnoAzRLQdkhYbMDsy4etl1Qrl3JwhepoEK(kBT0bymUT6HtmTuRgTm47rRdyhG1yjQXUso47rRdJgWLwQvJwSKKLwlhjtlcqlrnYV9Ga(EG(PJSS3FQB0bYdPdWyCAS8Yo5p51VkE8e(2dcyr(b6N86xfpEc)jcNgJt)N6gDG0Ia0IUrhyG0baTiu0seImTakTCpADa1nEKRB8q6qOFuw4e)thzzV)KKjBC0YwlvhuoKdm7KW3EqadShOFYRFv84j8NiCAmo9FEpADa1nEKRB8q6qOFuw4e)thzzV)8Q6EiBT0QZsEzYOF7bbSO(a9thzzV)m(GtD05kkVkhA)Kx)Q4Xt4BpiGfHhOF6il79NIhhpsFLTw6amg3w9FYRFv84j8TheWI4hOF6il79N4mowXYCLWyhX)Kx)Q4Xt4BpiGbUhOFYRFv84j8NiCAmo9FQpkLeZO6owKLwsY0Ia0cy0sKOfr04NoYYE)jQxeVg2nEi1kNKF7bbma6d0p51VkE8e(teongN(pVhToGzebkgcL6gJ4Wj(NoYYE)PvNLN92NDi1ngXV9GaMq7b6NoYYE)jGnwneKZvIzyV(I4FYRFv84j8T3(5G1(rzpqpiG9a9tE9RIhpH)eHtJXP)ZbFpADa5qlxXWjMwQvJwg89O1HrcJzLYVkws6IjkCIPLA1OLbFpADyKWywP8RIL8IDroCI)PJSS3FICLs6il7vQsO9tvcn56K8ppwQsl63EqI6d0pDKL9(ZdKLPXKWFYRFv84j8ThKi8a9tE9RIhpH)0rw27prUsjDKL9kvj0(PkHMCDs(NOb8ThKi(b6N86xfpEc)jcNgJt)NoYsbzjVmzYqAraAjc0cO0I5kETaQUta2jHbE9RIh0cO0I5kETGRIR7YympCRXbE9RIh)0rw27prUsjDKL9kvj0(PkHMCDs(NEmG68TheW9a9tE9RIhpH)eHtJXP)thzPGSKxMmziTiaTebAbuAXCfVwav3ja7KWaV(vXJF6il79NixPKoYYELQeA)uLqtUoj)ta15Bpia0hOFYRFv84j8NiCAmo9F6ilfKL8YKjdPfbOLiqlGslcHwmxXRfCvCDxgJ5HBnoWRFv8GwaLwecTyUIxlayQg6eZYC1hy2BGx)Q4XpDKL9(tKRushzzVsvcTFQsOjxNK)j0E7brO9a9tE9RIhpH)eHtJXP)thzPGSKxMmziTiaTebAbuAXCfVwWvX1DzmMhU14aV(vXdAbuAri0I5kETaGPAOtmlZvFGzVbE9RIh)0rw27prUsjDKL9kvj0(PkHMCDs(NEm0E7bbG4b6N86xfpEc)jcNgJt)NoYsbzjVmzYqAraAjc0cO0I5kETGRIR7YympCRXbE9RIh0cO0I5kETaGPAOtmlZvFGzVbE9RIh)0rw27prUsjDKL9kvj0(PkHMCDs(NEmG68TheW3d0p51VkE8e(teongN(pDKLcYsEzYKH0Ia0seOfqPfHqlMR41cUkUUlJX8WTgh41VkEqlGslMR41caMQHoXSmx9bM9g41VkE8thzzV)e5kL0rw2RuLq7NQeAY1j5FcOoF7bbSi)a9tE9RIhpH)eHtJXP)thzPGSKxMmziTaE0cy)0rw27prUsjDKL9kvj0(PkHMCDs(Nif7cYV9Gagypq)0rw27pr9I41WUXdPw5K8p51VkE8e(2dcyr9b6NoYYE)PJr(YsRXyETFYRFv84j8T3(5XsvAr)a9Ga2d0pDKL9(tYdadGP4FYRFv84j8ThKO(a9thzzV)eYyEtlA54aTFYRFv84j8ThKi8a9thzzV)eg3ywIu9z8tE9RIhpHV9GeXpq)0rw27pHDB1ZvucOBm(N86xfpEcF7bbCpq)0rw27pH9Mi5v5q7N86xfpEcF7bbG(a9thzzV)CzRoJLW6nIGFYRFv84j8TheH2d0pDKL9(tu9e8tcLg2xaUpPkTO)jV(vXJNW3EqaiEG(PJSS3FcJtCAsy9grWp51VkE8e(2dc47b6NoYYE)562bZqPi2r8p51VkE8e(2BV9tbzmm79bjQrgmWxKfArnQ)eqhV5kc)jaFKXn24bTa(OfhzzV0IkHgmqR(ZyCRtf)ZiIwMhSGPGUIwa44SgJPvJiAPUzXqWFGbwmT6NBa1KadtYJYTSxe21gWWKebmTAerlvpQOPLOcMW0suJmyGpArOOLOgzWFWfX0Q0QreTi0x3xrgc(tRgr0IqrlaKJbpOfHUdadGPyAXAAzWA)OmAXrw2lTOsOfOvJiArOOfH(6(kYdAXCSiBYutlmaIXmeM9cPfRPfu0iflnhlYgmqRgr0IqrlcD9i1jpOfKJfKLObMwSMwaSXeqlKnMPf2HPkAAbW0QtlwDMw8XOxaUG0ssgRysEn3YEPLwtlc640VkoqRgr0IqrlaKJbpOLJLQ0IMwaib4fG)aTkTAerlGFbaJogpOLlRBmtlOM86gTCzXCHbAbGeH4ydslBVcvDhtQpkAXrw2lKw6vfDGwnIOfhzzVWqmMrn51nIALdjGwnIOfhzzVWqmMrn51Tkeb2pIK8AUL9sRgr0IJSSxyigZOM86wfIaR7EqR6il7fgIXmQjVUvHiWWdjzVYy2OvJiAzUEmSEB0c2ZbTCpAnpOfO5gKwUSUXmTGAYRB0YLfZfsl(oOLymluXTz5ksljKwg9YbA1iIwCKL9cdXyg1Kx3Qqey46XW6TjHMBqAvhzzVWqmMrn51TkeboUTSxAvhzzVWqmMrn51TkebgAmRKg2JPvDKL9cdXyg1Kx3Qqe46ooU7LwLw1rw2lmCSuLw0ejpamaMIPvDKL9cdhlvPfDfIadzmVPfTCCGgTQJSSxy4yPkTORqeyyCJzjs1NbTQJSSxy4yPkTORqeyy3w9CfLa6gJPvDKL9cdhlvPfDfIad7nrYRYHgTQJSSxy4yPkTORqe4LT6mwcR3icOvDKL9cdhlvPfDfIaJQNGFsO0W(cW9jvPfnTQJSSxy4yPkTORqeyyCIttcR3icOvDKL9cdhlvPfDfIaVUDWmukIDetRsRgr0c4xaWOJXdAHfKXrtlwsY0IvNPfhznMwsiT4c6PYVkoqR6il7fse5kL0rw2RuLqt41jzIhlvPfTWPM4GVhToGCOLRy4exR2GVhTomsymRu(vXssxmrHtCTAd(E06WiHXSs5xfl5f7IC4etR6il7fwHiWhiltJjH0QoYYEHvicmYvkPJSSxPkHMWRtYerdiTQJSSxyfIaJCLs6il7vQsOj86KmrpgqDkCQj6ilfKL8YKjdficGAUIxlGQ7eGDsyGx)Q4bOMR41cUkUUlJX8WTgh41VkEqR6il7fwHiWixPKoYYELQeAcVojteqDkCQj6ilfKL8YKjdficGAUIxlGQ7eGDsyGx)Q4bTQJSSxyfIaJCLs6il7vQsOj86KmrOjCQj6ilfKL8YKjdficGkeZv8Abxfx3LXyE4wJd86xfpaviMR41caMQHoXSmx9bM9g41VkEqR6il7fwHiWixPKoYYELQeAcVojt0JHMWPMOJSuqwYltMmuGiaQ5kETGRIR7YympCRXbE9RIhGkeZv8Abat1qNywMR(aZEd86xfpOvDKL9cRqeyKRushzzVsvcnHxNKj6XaQtHtnrhzPGSKxMmzOarauZv8Abxfx3LXyE4wJd86xfpa1CfVwaWun0jML5QpWS3aV(vXdAvhzzVWkebg5kL0rw2RuLqt41jzIaQtHtnrhzPGSKxMmzOarauHyUIxl4Q46UmgZd3ACGx)Q4bOMR41caMQHoXSmx9bM9g41VkEqR6il7fwHiWixPKoYYELQeAcVojtePyxqw4ut0rwkil5LjtgcEGrR6il7fwHiWOEr8Ay34HuRCsMw1rw2lScrGDmYxwAngZRrRsR6il7fg8yOrKSxXUHS8MglCQjEpADa1nEKRB8q6qOFuw4edAuCpADa1nEKRB8q6qOFuwaZKEUqbalaUijIg1QDpAD4QoyzRLMR6fgoXGEpAD4QoyzRLMR6fgWmPNluaWcGlsIOrusR6il7fg8yOvHiWyp2ASeA4Kaw4ut8E06aQB8ix34H0Hq)OSWjg0O4E06aQB8ix34H0Hq)OSaMj9CHcawaCrsenQv7E06WvDWYwlnx1lmCIb9E06WvDWYwlnx1lmGzspxOaGfaxKerJOKw1rw2lm4XqRcrG1kFjixrj0WjbSWPMOUrhyfKdnjMf5vaDJoWaPdaAvhzzVWGhdTkebMGuPKOMK03HWPMO(OusmJQ7yrwAjjlaybWfjr0auDJoWkihAsmlYRa6gDGbshacfyrMw1rw2lm4XqRcrGHgZkPH9yHtnrDJoWkihAsmlYRa6gDGbsha0QoYYEHbpgAvicmGPAOtmlVn5v4utu3OdScYHMeZI8kGUrhyG0baOcXseb5kcQqUhToqYKnoAzRLQdkhYbMDsy4edAuOpkLeZO6owKLwsYcawaCrsenQvtiJ2caMQHoXS82K3GLicYveuHCpADa1nEKRB8q6qOFuw4ehL0QoYYEHbpgAvicmKXX8AsOLROWPMOqgTfGmoMxtcTCfdwIiixrqfY9O1bu34rUUXdPdH(rzHtmTQJSSxyWJHwfIatqQusuts67q4utu3OdScYHMeZI8kGUrhyG0baOrX9O1bYEf7gYs9bhDaAoIabaxTA6gDGc4il7nq2Ry3qwEtJdOgArjTQJSSxyWJHwfIadzCmVMeA5kkCQjIznMH19RIbvi3JwhqDJh56gpKoe6hLfoXGEpADGSxXUHSuFWrhGMJiqaWrR6il7fg8yOvHiWUK8Ghmw2Ajc3acfo1efY9O1bu34rUUXdPdH(rzHtmTQJSSxyWJHwfIaJ6gpY1nEiDi0pkJw1rw2lm4XqRcrGj7vSBilVPXcNAI3Jwhi7vSBil1hC0HtCTA6gDGvqo0KywKxWt3Odmq6aqOalY1QDpADa1nEKRB8q6qOFuw4etR6il7fg8yOvHiWyp2ASeA4KaMw1rw2lm4XqRcrGbmvdDIz5TjVcNAIcXseb5ksRsR6il7fg8ya1jrYEf7gYYBASWPM49O1HR6GLTwAUQxy4ed69O1HR6GLTwAUQxyaZKEUqberdAvhzzVWGhdOoRqeyShBnwcnCsalCQjEpAD4QoyzRLMR6fgoXGEpAD4QoyzRLMR6fgWmPNluar0Gw1rw2lm4XaQZkebgY4yEnj0Yvu4utuiJ2cqghZRjHwUIblreKRiTQJSSxyWJbuNvicSljp4bJLTwIWnGqAvhzzVWGhdOoRqeyat1qNywEBYRWPMO(OusmJQ7yrwAjjlaybWfjr0OwnDJoWkihAsmlYRa6gDGbshaGgfldatcykVn5niyRClvmOJ2cqghZRjHwUIblreKRiOJ2cqghZRjHwUIbmRXmSUFvCTAldatcykVn5nexNXnzVmOc5E06azVIDdzP(GJoCIbv3OdScYHMeZI8kGUrhyG0bGq5il7nqqQusuts67iGCOjXSiVrkcrjTQJSSxyWJbuNvicmQB8ix34H0Hq)OmAvhzzVWGhdOoRqeyYEf7gYYBASWPM49O1bYEf7gYs9bhDaZKEUqqxgaMeWuEBYBiUoJBYEzAvhzzVWGhdOoRqeycsLsIAssFhcNAI6JsjXmQUJfzPLKSaGfaxKerdq1n6aRGCOjXSiVcOB0bgiDaiurnY0QoYYEHbpgqDwHiWqJzL0WESWPMOUrhyfKdnjMf5vaDJoWaPdaAvhzzVWGhdOoRqeyShBnwcnCsalCQjEpADWYyzRLwDwcJzhhGMJiGyeQvB0wawh7XlRK3M8gSerqUI0QoYYEHbpgqDwHiWK9k2nKL30yHtnXrBbyDShVSsEBYBWseb5ksR6il7fg8ya1zfIadyQg6eZYBtEfo1exgaMeWuEBYBawh7XlRav3Ode8IqKbD0waY4yEnj0YvmGzspxi4bUijIg0QoYYEHbpgqDwHiWO6obyNekCQjkK7rRdK9k2nKL6do6aMj9CH0QoYYEHbpgqDwHiWqghZRjHwUIcNAIywJzyD)QyAvhzzVWGhdOoRqeycsLsIAssFhcNAI6gDGvqo0KywKxb0n6adKoaankUhToq2Ry3qwQp4OdqZreia4Qvt3OduahzzVbYEf7gYYBACa1qlkPvDKL9cdEmG6ScrGXES1yj0WjbmTQJSSxyWJbuNvicmzVIDdz5nnw4ut8E06azVIDdzP(GJoCIRvt3Ode8I4ixR2OTaSo2JxwjVn5nyjIGCfPvDKL9cdEmG6ScrGbmvdDIz5TjVcNAIldatcykVn5niyRClvmOJ2cqghZRjHwUIblreKRyTAldatcykVn5nexNXnzVCTAldatcykVn5naRJ94LvGQB0bcEGlY0Q0QoYYEHb0as8Q6Ei1hC0cNAIOUvJgWnG6gpY1nEiDi0pklGzspxi4fHitR6il7fgqdyfIa7lIHg2vsKRucNAIOUvJgWnG6gpY1nEiDi0pklGzspxi4fHitR6il7fgqdyfIaRtmFvDpeo1erDRgnGBa1nEKRB8q6qOFuwaZKEUqWlcrMw1rw2lmGgWkebwLI1nOe8ZzisYRrR6il7fgqdyfIaFzmKXeKROWPMiQB1ObCdOUXJCDJhshc9JYcyM0ZfcEa0ixRMLKS0A5izbalc0QoYYEHb0awHiWXTL9kCQjEpADa1nEKRB8q6qOFuw4edAuCpAD4YyiJjixXWjUwT7rRdxv3dP(GJoCIRvtiyhXbd3kfOcb7io0yuuwRMLKS0A5izbIkaLw1rw2lmGgWkeb2HXmYKTwA1zj7Ikw4ut0CSiBHrcnFrm4reGsR6il7fgqdyfIaFGSmnMu41jzIoSUG(Yqj2bynwIASReo1eVhToqYKnoAzRLQdkhYbMDsy4exR29O1bXJJhPVYwlDagJBRE4exR2GVhToGDawJLOg7k5GVhTomAa3A1SKKLwlhjlquJmTQJSSxyanGvicSUrhipKoaJXPXYl7K0QoYYEHb0awHiWKmzJJw2AP6GYHCGzNekCQjQB0bkGUrhyG0bGqfHid69O1bu34rUUXdPdH(rzHtmTQJSSxyanGvic8v19q2APvNL8YKrlCQjEpADa1nEKRB8q6qOFuw4etR6il7fgqdyfIahFWPo6CfLxLdnAvhzzVWaAaRqeyXJJhPVYwlDagJBRoTQJSSxyanGvicmoJJvSmxjm2rmTQJSSxyanGvicmQxeVg2nEi1kNKfo1e1hLsIzuDhlYsljzbalsIObTQJSSxyanGvicSvNLN92NDi1ngXcNAI3JwhWmIafdHsDJrC4etR6il7fgqdyfIadyJvdb5CLyg2RViMwLw1rw2lmGuSlituqhN(vXcVojte5ybzjAGfUJjczl1clORomrhzPGSKxMmzOWc6QdlzfKjcoHr9osl7LOJSuqwYltMmuaWrR6il7fgqk2fKRqeyxsEWdglBTeHBaH0QoYYEHbKIDb5kebg1nEKRB8q6qOFugTQJSSxyaPyxqUcrGrowqw4utC0wawh7XlRK3M8gSerqUI0QoYYEHbKIDb5kebgWun0jML3M8kCQjkeZv8AbXdJXPs5sZrwIGbE9RIh1QPpkLeZO6owKLwsYciIg0QoYYEHbKIDb5kebMSxXUHS8MglmkAKILMJfzdsemHtnXbFpADq5gVMmUtyVbO5icicwKPvDKL9cdif7cYvicmQUta2jH0QoYYEHbKIDb5kebMGuPKOMK03HWOOrkwAowKnirWeo1e1n6aRGCOjXSiVcOB0bgiDaqR6il7fgqk2fKRqe47Xq1zC0cNAI6JsjXmQUJfzPLKSaIOrTAcXCfVwaWun0jML5QpWS3aV(vXJA1gTfG1XE8Yk5TjVblreKRiOJ2c5AmEDL8QyEKRyaAoIabIaTQJSSxyaPyxqUcrGrowqw4ut0CfVwq8WyCQuU0CKLiyGx)Q4bTQJSSxyaPyxqUcrG1kFjixrj0WjbSWPMOUrhyfKdnjMf5vaDJoWaPdaAvhzzVWasXUGCfIadyQg6eZYBtEfo1ehTfamvdDIz5TjVbmRXmSUFvCTAMR41caMQHoXSmx9bM9g41VkEqR6il7fgqk2fKRqeyiJJ51KqlxrHrrJuS0CSiBqIGjCQjEpADqWmMXqPG82Kbm7iJw1rw2lmGuSlixHiWihlilCQjI6wnAa3aGPAOtmlVn5nGzspxi4jOJt)Q4aYXcYs0adWzuPvDKL9cdif7cYvicm0ywjnShtR6il7fgqk2fKRqe46ooU7v4ut0CfVwWymju2AjVIUitYRf41VkEqR6il7fgqk2fKRqeyiJJ51KqlxrHrrJuS0CSiBqIGjCQjIznMH19RIb9E06GLXYwlT6SegZooanhrGarGwnIOfGAAbMKhLBmTCGUitl6gtlcD9k2nKPfctJPLgtla84XwJPLPHtcyAzCW5kslaKWygz0sRPfRotlGFDrflmTG64OPf2r1PLgHoymViMwAnTy1zAXrw2lT47Gw84yEh0IKDrftlwtlwDMwCKL9slRtYbAvhzzVWasXUGCfIat2Ry3qwEtJfgfnsXsZXISbjcgTQJSSxyaPyxqUcrGXES1yj0WjbSWOOrkwAowKnirWOvPvDKL9cdqJyDhh39kCQjAUIxlymMekBTKxrxKj51c86xfpOvDKL9cdqRcrG1kFjixrj0WjbSWPMOUrhyfKdnjMf5vaDJoWaPdaAvhzzVWa0QqeyShBnwcnCsalCQjEpADa1nEKRB8q6qOFuw4edAuCpADa1nEKRB8q6qOFuwaZKEUqbalaUijIg1QDpAD4QoyzRLMR6fgoXGEpAD4QoyzRLMR6fgWmPNluaWcGlsIOrusRgr0cqnTatYJYnMwoqxKPfDJPfHUEf7gY0cHPX0sJPfaE8yRX0Y0WjbmTmo4CfPfasymJmAP10IvNPfWVUOIfMwqDC00c7O60sJqhmMxetlTMwS6mT4il7Lw8DqlECmVdArYUOIPfRPfRotloYYEPL1j5aTQJSSxyaAvicmzVIDdz5nnw4ut8E06aQB8ix34H0Hq)OSWjg0O4E06aQB8ix34H0Hq)OSaMj9CHcawaCrsenQv7E06WvDWYwlnx1lmCIb9E06WvDWYwlnx1lmGzspxOaGfaxKerJOKw1rw2lmaTkebMGuPKOMK03HWPMOUrhyfKdnjMf5vaDJoWaPdaAvhzzVWa0QqeyOXSsAypw4utu3OdScYHMeZI8kGUrhyG0baTQJSSxyaAvicmGPAOtmlVn5v4utu3OdScYHMeZI8kGUrhyG0baOcXseb5kcQqUhToqYKnoAzRLQdkhYbMDsy4edAuOpkLeZO6owKLwsYcawaCrsenQvtiJ2caMQHoXS82K3GLicYveuHCpADa1nEKRB8q6qOFuw4ehL0QoYYEHbOvHiWK9k2nKL30yHtnX7rRdK9k2nKL6do6a0CebGh4aviOUvJgWnG6gpY1nEiDi0pklGzspxiTQJSSxyaAvicmKXX8AsOLROWPM49O1bbZygdLcYBtgoXGoAlazCmVMeA5kgWmPNluGiosIOrTAJ2cqghZRjHwUIbmRXmSUFvmOc5E06aQB8ix34H0Hq)OSWjMw1rw2lmaTkeb2LKh8GXYwlr4gqOWPMOqUhToG6gpY1nEiDi0pklCIPvDKL9cdqRcrGrDJh56gpKoe6hLrR6il7fgGwfIat2Ry3qwEtJfo1eVhToq2Ry3qwQp4OdN4A10n6aRGCOjXSiVGNUrhyG0bGqf1idQ5kETGGzmJHsb5Tjd86xfpQvt3OdScYHMeZI8cE6gDGbshacfyGAUIxlymMekBTKxrxKj51c86xfpQv7E06aQB8ix34H0Hq)OSWjMw1rw2lmaTkebg7XwJLqdNeW0QoYYEHbOvHiWaMQHoXS82KxHtnXrBbat1qNywEBYBaZAmdR7xftR6il7fgGwfIadzCmVMeA5kkCQjEpADqWmMXqPG82KHtmTkTQJSSxyaqDsSUJJ7Efo1e1n6aRGCOjXSiVcOB0bgiDaaQ5kETGXysOS1sEfDrMKxlWRFv8Gw1rw2lmaOoRqeyYEf7gYYBASWPM49O1HR6GLTwAUQxy4ed69O1HR6GLTwAUQxyaZKEUqberdAvhzzVWaG6ScrGXES1yj0WjbSWPM49O1HR6GLTwAUQxy4ed69O1HR6GLTwAUQxyaZKEUqberdAvhzzVWaG6ScrGHmoMxtcTCffo1eVhToiygZyOuqEBYWjg07rRdcMXmgkfK3MmGzspxOaGfaxKerJA1eYOTaKXX8AsOLRyWseb5ksR6il7fgauNvicmGPAOtmlVn5v4utuFukjMr1DSilTKKfaSa4IKiAaQUrhyfKdnjMf5vaDJoWaPdGA1IILbGjbmL3M8geSvULkg0rBbiJJ51KqlxXGLicYve0rBbiJJ51KqlxXaM1ygw3VkUwTLbGjbmL3M8gIRZ4MSxguHCpADGSxXUHSuFWrhoXGQB0bwb5qtIzrEfq3Odmq6aqOCKL9giivkjQjj9Deqo0KywK3ifHOKw1rw2lmaOoRqeycsLsIAssFhcNAI6gDGvqo0KywKxb0n6adKoaekDJoWaMf5Lw1rw2lmaOoRqeyxsEWdglBTeHBaH0QoYYEHba1zfIadnMvsd7XcNAI6gDGvqo0KywKxb0n6adKoaOvDKL9cdaQZkebgWun0jML3M8kCQjQpkLeZO6owKLwsYcawaCrsenOvDKL9cdaQZkebg1nEKRB8q6qOFugTQJSSxyaqDwHiWqghZRjHwUIcNAI3JwhemJzmukiVnz4ed6OTaKXX8AsOLRyaZKEUqbI4ijIg0QoYYEHba1zfIat2Ry3qwEtJfo1ehTfG1XE8Yk5TjVblreKRyTA3Jwhi7vSBil1hC0bO5icicoAvhzzVWaG6ScrGbmvdDIz5TjVcNAIldatcykVn5naRJ94LvGoAlazCmVMeA5kgWmPNle8axKerdAvhzzVWaG6ScrGHmoMxtcTCffo1eXSgZW6(vX0QoYYEHba1zfIaJQ7eGDsOWPMOqUhToq2Ry3qwQp4OdyM0ZfsR6il7fgauNvicmzVIDdz5nnMw1rw2lmaOoRqeyShBnwcnCsatR6il7fgauNvicmKXX8AsOLROWPM49O1bbZygdLcYBtgoX0QoYYEHba1zfIadyQg6eZYBtEfo1exgaMeWuEBYBqWw5wQyqhTfGmoMxtcTCfdwIiixXA1wgaMeWuEBYBiUoJBYE5A1wgaMeWuEBYBawh7XlR(jmMrpirfCG7T3(h]] )


end