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

        potion = "potion_of_bursting_blood",

        package = "Survival"
    } )


    spec:RegisterPack( "Survival", 20190709.1200, [[dCKlEbqicKhjjKlbfiAtaLpbfizucr5ucr1Qec9kH0SiOUfbk7sWVasdtiYXaILbf0ZecMMKaxtsvBdkGVbfQghbQCojbToOqP5ra3dkTpOqoOKq1cbQEOKqPlcfkAKqbcNekqLvkjntOavDtjHIDcOgkuGslfkqXtvyQaYEv1FPyWsCyQwSkEmKjROlJAZu6ZeA0a40IwnuOWRHIMnr3gQ2Ts)wQHluhhkqQLJ45GMoPRRsBNG8DjLXlPY5LeTEcu18bO9J0pipq)y6k)aJHrcKkmsy8ivHbqIq9vqKWWFOvgZ)i2ry6I8pwhN)X4sekfYL)i2Ru2(8b6hW(sq8paq1yiglOGkMka3ta14Gct8R01SxeXTkOWehb6po3uQyWT)5htx5hymmsGuHrcJhPkmaseQpc1xH)WVkan5hJe)kDn7TIL4w9haKZjV)5htgI(rfrlJlrOuixslyqCxLj0QveTaGQXqmwqbvmvaUNaQXbfM4xPRzViIBvqHjocuA1kIwQELvslvOW0cggjqQqArWOfqabJncrIwLwTIOLkwa8vKHyS0QveTiy0sfFo5jTuXCf8cEjtlAtlt26xPslosZEPfzc1aTAfrlcgTuXcGVI8KwuNiYQjT0cxxmHHWSxiTOnTGQejzJ6erwHbA1kIwemAPIPNPn5jTGCIqSbnj0I20sTMGjTG3eMwyhMYkPLAPcaTOaW0IpN9IbfKws8yjJZR6A2lT0wAriNK(rYbA1kIwemAPIpN8KwUAktTsAPIJblg8HFitOcFG(Hhd1hOhyqEG(bV(rYZh8FGiPYK0)X5ATbu3KzUUYtJdH(vQHBmTagTez0Y5ATbu3KzUUYtJdH(vQbcJ75cPfbOfqc1tlrKwertAbqaPLZ1Adh5LyARrDzVWWnMwaJwoxRnCKxIPTg1L9cdeg3ZfslcqlGeQNwIiTiIM0sK)dhPzV)aVxXUHS5Kk)6dmg(a9dE9JKNp4)arsLjP)JZ1AdOUjZCDLNghc9Rud3yAbmAjYOLZ1AdOUjZCDLNghc9Rudeg3ZfslcqlGeQNwIiTiIM0cGaslNR1goYlX0wJ6YEHHBmTagTCUwB4iVetBnQl7fgimUNlKweGwajupTerArenPLi)hosZE)bXJ1MyGkjXKF9bocpq)Gx)i55d(pqKuzs6)W2OlKwIslihQgclYlTiaTyB0fgW96(HJ0S3FyL(IzUIgOssm5xFGRGhOFWRFK88b)hisQmj9FyVsPHWiaCIiB0eNPfbOfqc1tlrKwertAbmAX2OlKwIslihQgclYlTiaTyB0fgW96OfbJwajs)WrA27pWmLsdQXX9D(6dC9pq)Gx)i55d(pqKuzs6)W2OlKwIslihQgclYlTiaTyB0fgW96(HJ0S3FavMLgL4XV(aJbEG(bV(rYZh8FGiPYK0)HTrxiTeLwqounewKxAraAX2OlmG71rlGrlcIw0eHzUI0cy0IGOLZ1Ad4mEtQ00wJ8IYPzsyhhgUX0cy0sKrl2RuAimcaNiYgnXzAraAbKq90sePfr0KwaeqArq0YS1qTuoTjHnNg)e0eHzUI0cy0IGOLZ1AdOUjZCDLNghc9Rud3yAjY)HJ0S3FulLtBsyZPXpV(aJXFG(bV(rYZh8FGiPYK0)HGOLzRbitI5vnqnxXGMimZvKwaJweeTCUwBa1nzMRR804qOFLA4g)dhPzV)aYKyEvduZv81hyb3d0p41psE(G)dejvMK(pSn6cPLO0cYHQHWI8slcql2gDHbCVoAbmAjYOLZ1Ad49k2nKn2lPYauDeM0Ia0s90cGasl2gDH0Ia0IJ0S3aEVIDdzZjvoGAOslr(pCKM9(dmtP0GACCFNV(axHpq)Gx)i55d(pqKuzs6)GWwcdbWpsMwaJweeTCUwBa1nzMRR804qOFLA4gtlGrlNR1gW7vSBiBSxsLbO6imPfbOL6)HJ0S3FazsmVQbQ5k(6dmir6b6h86hjpFW)bIKkts)hcIwoxRnG6MmZ1vEACi0VsnCJ)HJ0S3F4g8lzYetBnisxd(6dmiG8a9dhPzV)a1nzMRR804qOFL6p41psE(G)6dmiy4d0p41psE(G)dejvMK(poxRnG3Ry3q2yVKkd3yAbqaPfBJUqAjkTGCOAiSiV0cgrl2gDHbCVoArWOfqIeTaiG0Y5ATbu3KzUUYtJdH(vQHB8pCKM9(d8Ef7gYMtQ8RpWGeHhOF4in79hepwBIbQKet(h86hjpFWF9bgKk4b6h86hjpFW)bIKkts)hcIw0eHzUI)WrA27pQLYPnjS504NxF9hij7cXpqpWG8a9dE9JKNp4)OJ)bK10(dhPzV)qiNK(rY)qiNywhN)bYjcXg0K8dejvMK(pCKMcXgEz8KH0Ia0s9)qixEzdlH8pQ)hc5Yl)dhPPqSHxgpz4RpWy4d0pCKM9(d3GFjtMyARbr6AWFWRFK88b)1h4i8a9dhPzV)a1nzMRR804qOFL6p41psE(G)6dCf8a9dE9JKNp4)arsLjP)JzRbiaepEzP504NGMimZv8hosZE)bYjcXV(ax)d0p41psE(G)dejvMK(peeTOUKxniEzcjLs3OostemWRFK8KwaeqAXELsdHra4er2OjotlcqlIO5pCKM9(JAPCAtcBon(51hymWd0p41psE(G)dhPzV)aVxXUHS5Kk)dejvMK(pM85ATbPR8QM4oH9gGQJWKwWslGePFGQejzJ6erwHpWG86dmg)b6hosZE)bcahtIJd)bV(rYZh8xFGfCpq)Gx)i55d(pCKM9(dmtP0GACCFN)arsLjP)dBJUqAjkTGCOAiSiV0Ia0ITrxya3R7hOkrs2OorKv4dmiV(axHpq)Gx)i55d(pqKuzs6)WELsdHra4er2OjotlcqlIOjTaiG0IGOf1L8QHAPCAtcBY1EHzVbE9JKN0cGaslZwdqaiE8YsZPXpbnryMRiTagTmBnKRYK1LMJK5zUIbO6imPfbOLi8dhPzV)4CveamPYxFGbjspq)Gx)i55d(pqKuzs6)qDjVAq8YeskLUrDKMiyGx)i55pCKM9(dKteIF9bgeqEG(bV(rYZh8FGiPYK0)HTrxiTeLwqounewKxAraAX2OlmG719dhPzV)Wk9fZCfnqLKyYV(adcg(a9dE9JKNp4)arsLjP)JzRHAPCAtcBon(jqylHHa4hjtlaciTOUKxnulLtBsytU2lm7nWRFK88hosZE)rTuoTjHnNg)86dmir4b6h86hjpFW)HJ0S3FazsmVQbQ5k(dejvMK(poxRniugZeOriEB8aHDK(duLijBuNiYk8bgKxFGbPcEG(bV(rYZh8FGiPYK0)bQB5SRTHAPCAtcBon(jqyCpxiTGr0Iqoj9JKdiNieBqtcTGbjTGH)WrA27pqori(1hyqQ)b6hosZE)buzwAuIh)dE9JKNp4V(adcg4b6h86hjpFW)bIKkts)hQl5vdktWHM2A4v0fzCE1aV(rYZF4in79ha4K4U3xFGbbJ)a9dE9JKNp4)WrA27pGmjMx1a1Cf)bIKkts)he2syia(rY0cy0Y5ATbnJnT1OaWgym7KauDeM0Ia0se(bQsKKnQtezf(adYRpWGi4EG(bV(rYZh8F4in79h49k2nKnNu5FGQejzJ6erwHpWG86dmiv4d0p41psE(G)dhPzV)G4XAtmqLKyY)avjsYg1jIScFGb51x)buFGEGb5b6h86hjpFW)bIKkts)hQl5vdktWHM2A4v0fzCE1aV(rYZF4in79ha4K4U3xFGXWhOFWRFK88b)hisQmj9FyB0fslrPfKdvdHf5LweGwSn6cd4ED)WrA27pSsFXmxrdujjM8RpWr4b6h86hjpFW)bIKkts)hNR1gqDtM56kpnoe6xPgUX0cy0sKrlNR1gqDtM56kpnoe6xPgimUNlKweGwajupTerArenPfabKwoxRnCKxIPTg1L9cd3yAbmA5CT2WrEjM2Aux2lmqyCpxiTiaTasOEAjI0IiAslr(pCKM9(dIhRnXavsIj)6dCf8a9dE9JKNp4)arsLjP)JZ1AdOUjZCDLNghc9Rud3yAbmAjYOLZ1AdOUjZCDLNghc9Rudeg3ZfslcqlGeQNwIiTiIM0cGaslNR1goYlX0wJ6YEHHBmTagTCUwB4iVetBnQl7fgimUNlKweGwajupTerArenPLi)hosZE)bEVIDdzZjv(1h46FG(bV(rYZh8FGiPYK0)HTrxiTeLwqounewKxAraAX2OlmG719dhPzV)aZuknOgh335RpWyGhOFWRFK88b)hisQmj9FyB0fslrPfKdvdHf5LweGwSn6cd4ED)WrA27pGkZsJs84xFGX4pq)Gx)i55d(pqKuzs6)W2OlKwIslihQgclYlTiaTyB0fgW96OfWOfbrlAIWmxrAbmArq0Y5ATbCgVjvAARrEr50mjSJdd3yAbmAjYOf7vknegbGtezJM4mTiaTasOEAjI0IiAslaciTiiAz2AOwkN2KWMtJFcAIWmxrAbmArq0Y5ATbu3KzUUYtJdH(vQHBmTe5)WrA27pQLYPnjS504NxFGfCpq)Gx)i55d(pqKuzs6)4CT2aEVIDdzJ9sQmavhHjTGr0s90cy0IGOfu3YzxBdOUjZCDLNghc9Rudeg3Zf(dhPzV)aVxXUHS5Kk)6dCf(a9dE9JKNp4)arsLjP)JZ1AdcLXmbAeI3gpCJPfWOLzRbitI5vnqnxXaHX9CH0Ia0sfqlrKwertAbqaPLzRbitI5vnqnxXaHTegcGFKmTagTiiA5CT2aQBYmxx5PXHq)k1Wn(hosZE)bKjX8QgOMR4RpWGePhOFWRFK88b)hisQmj9FiiA5CT2aQBYmxx5PXHq)k1Wn(hosZE)HBWVKjtmT1GiDn4RpWGaYd0pCKM9(du3KzUUYtJdH(vQ)Gx)i55d(RpWGGHpq)Gx)i55d(pqKuzs6)4CT2aEVIDdzJ9sQmCJPfabKwSn6cPLO0cYHQHWI8slyeTyB0fgW96OfbJwWWirlGrlQl5vdcLXmbAeI3gpWRFK8KwaeqAX2OlKwIslihQgclYlTGr0ITrxya3RJwemAbeAbmArDjVAqzco00wdVIUiJZRg41psEslaciTCUwBa1nzMRR804qOFLA4g)dhPzV)aVxXUHS5Kk)6dmir4b6hosZE)bXJ1MyGkjXK)bV(rYZh8xFGbPcEG(bV(rYZh8FGiPYK0)XS1qTuoTjHnNg)eiSLWqa8JK)HJ0S3FulLtBsyZPXpV(ads9pq)Gx)i55d(pqKuzs6)4CT2GqzmtGgH4TXd34F4in79hqMeZRAGAUIV(6pQzZhOhyqEG(bV(rYZh8FGiPYK0)HTrxiTeLwqounewKxAraAX2OlmG71rlGrlQl5vdktWHM2A4v0fzCE1aV(rYZF4in79ha4K4U3xFGXWhOFWRFK88b)hisQmj9FCUwB4iVetBnQl7fgUX0cy0Y5ATHJ8smT1OUSxyGW4EUqAraAren)HJ0S3FG3Ry3q2CsLF9bocpq)Gx)i55d(pqKuzs6)4CT2WrEjM2Aux2lmCJPfWOLZ1Adh5LyARrDzVWaHX9CH0Ia0IiA(dhPzV)G4XAtmqLKyYV(axbpq)Gx)i55d(pqKuzs6)4CT2GqzmtGgH4TXd3yAbmA5CT2GqzmtGgH4TXdeg3ZfslcqlGeQNwIiTiIM0cGaslcIwMTgGmjMx1a1CfdAIWmxXF4in79hqMeZRAGAUIV(ax)d0p41psE(G)dejvMK(pSxP0qyeaorKnAIZ0Ia0ciH6PLislIOjTagTyB0fslrPfKdvdHf5LweGwSn6cd4ED0cGaslrgTSCDQPwAon(jiulDnLmTagTmBnazsmVQbQ5kg0eHzUI0cy0YS1aKjX8QgOMRyGWwcdbWpsMwaeqAz56utT0CA8tigaM049Y0cy0IGOLZ1Ad49k2nKn2lPYWnMwaJwSn6cPLO0cYHQHWI8slcql2gDHbCVoArWOfhPzVbmtP0GACCFNbKdvdHf5LwIiTebAjY)HJ0S3FulLtBsyZPXpV(aJbEG(bV(rYZh8FGiPYK0)HTrxiTeLwqounewKxAraAX2OlmG71rlcgTyB0fgiSiV)WrA27pWmLsdQXX9D(6dmg)b6hosZE)HBWVKjtmT1GiDn4p41psE(G)6dSG7b6h86hjpFW)bIKkts)h2gDH0suAb5q1qyrEPfbOfBJUWaUx3pCKM9(dOYS0Oep(1h4k8b6h86hjpFW)bIKkts)h2RuAimcaNiYgnXzAraAbKq90sePfr08hosZE)rTuoTjHnNg)86dmir6b6hosZE)bQBYmxx5PXHq)k1FWRFK88b)1hyqa5b6h86hjpFW)bIKkts)hNR1gekJzc0ieVnE4gtlGrlZwdqMeZRAGAUIbcJ75cPfbOLkGwIiTiIM)WrA27pGmjMx1a1CfF9bgem8b6h86hjpFW)bIKkts)hZwdqaiE8YsZPXpbnryMRiTaiG0Y5ATb8Ef7gYg7LuzaQoctAblTu)pCKM9(d8Ef7gYMtQ8RpWGeHhOFWRFK88b)hisQmj9FSCDQPwAon(jabG4XllPfWOLzRbitI5vnqnxXaHX9CH0cgrl1tlrKwerZF4in79h1s50Me2CA8ZRpWGubpq)Gx)i55d(pqKuzs6)GWwcdbWps(hosZE)bKjX8QgOMR4RpWGu)d0p41psE(G)dejvMK(peeTCUwBaVxXUHSXEjvgimUNl8hosZE)bcahtIJdF9bgemWd0pCKM9(d8Ef7gYMtQ8p41psE(G)6dmiy8hOF4in79hepwBIbQKet(h86hjpFWF9bgeb3d0p41psE(G)dejvMK(poxRniugZeOriEB8Wn(hosZE)bKjX8QgOMR4RpWGuHpq)Gx)i55d(pqKuzs6)y56utT0CA8tqOw6AkzAbmAz2AaYKyEvduZvmOjcZCfPfabKwwUo1ulnNg)eIbGjnEVmTaiG0YY1PMAP504NaeaIhVS8hosZE)rTuoTjHnNg)86R)WJRzZhOhyqEG(bV(rYZh8FGiPYK0)X5ATHJ8smT1OUSxy4gtlGrlNR1goYlX0wJ6YEHbcJ75cPfbOfr08hosZE)bEVIDdzZjv(1hym8b6h86hjpFW)bIKkts)hNR1goYlX0wJ6YEHHBmTagTCUwB4iVetBnQl7fgimUNlKweGwerZF4in79hepwBIbQKet(1h4i8a9dE9JKNp4)arsLjP)dbrlZwdqMeZRAGAUIbnryMR4pCKM9(ditI5vnqnxXxFGRGhOF4in79hUb)sMmX0wdI01G)Gx)i55d(RpW1)a9dE9JKNp4)arsLjP)d7vknegbGtezJM4mTiaTasOEAjI0IiAslaciTyB0fslrPfKdvdHf5LweGwSn6cd4ED0cy0sKrllxNAQLMtJFcc1sxtjtlGrlZwdqMeZRAGAUIbnryMRiTagTmBnazsmVQbQ5kgiSLWqa8JKPfabKwwUo1ulnNg)eIbGjnEVmTagTiiA5CT2aEVIDdzJ9sQmCJPfWOfBJUqAjkTGCOAiSiV0Ia0ITrxya3RJwemAXrA2BaZuknOgh33za5q1qyrEPLislrGwI8F4in79h1s50Me2CA8ZRpWyGhOF4in79hOUjZCDLNghc9Ru)bV(rYZh8xFGX4pq)Gx)i55d(pqKuzs6)4CT2aEVIDdzJ9sQmqyCpxiTagTSCDQPwAon(jedatA8E5F4in79h49k2nKnNu5xFGfCpq)Gx)i55d(pqKuzs6)WELsdHra4er2OjotlcqlGeQNwIiTiIM0cy0ITrxiTeLwqounewKxAraAX2OlmG71rlcgTGHr6hosZE)bMPuAqnoUVZxFGRWhOFWRFK88b)hisQmj9FyB0fslrPfKdvdHf5LweGwSn6cd4ED)WrA27pGkZsJs84xFGbjspq)Gx)i55d(pqKuzs6)4CT2GMXM2AuaydmMDsaQoctAblTebAbqaPLzRbiaepEzP504NGMimZv8hosZE)bXJ1MyGkjXKF9bgeqEG(bV(rYZh8FGiPYK0)XS1aeaIhVS0CA8tqteM5k(dhPzV)aVxXUHS5Kk)6dmiy4d0p41psE(G)dejvMK(pwUo1ulnNg)eGaq84LL0cy0ITrxiTGr0seIeTagTmBnazsmVQbQ5kgimUNlKwWiAPEAjI0IiA(dhPzV)OwkN2KWMtJFE9bgKi8a9dE9JKNp4)arsLjP)dbrlNR1gW7vSBiBSxsLbcJ75c)HJ0S3FGaWXK44WxFGbPcEG(bV(rYZh8FGiPYK0)bHTegcGFK8pCKM9(ditI5vnqnxXxFGbP(hOFWRFK88b)hisQmj9FyB0fslrPfKdvdHf5LweGwSn6cd4ED0cy0sKrlNR1gW7vSBiBSxsLbO6imPfbOL6PfabKwSn6cPfbOfhPzVb8Ef7gYMtQCa1qLwI8F4in79hyMsPb144(oF9bgemWd0pCKM9(dIhRnXavsIj)dE9JKNp4V(adcg)b6h86hjpFW)bIKkts)hNR1gW7vSBiBSxsLHBmTaiG0ITrxiTGr0sfejAbqaPLzRbiaepEzP504NGMimZv8hosZE)bEVIDdzZjv(1hyqeCpq)Gx)i55d(pqKuzs6)y56utT0CA8tqOw6AkzAbmAz2AaYKyEvduZvmOjcZCfPfabKwwUo1ulnNg)eIbGjnEVmTaiG0YY1PMAP504NaeaIhVSKwaJwSn6cPfmIwQps)WrA27pQLYPnjS504NxF9hXeg14hxFGEGb5b6h86hjpFWF9bgdFG(bV(rYZh8xFGJWd0p41psE(G)6dCf8a9dhPzV)aEXX71eZ6p41psE(G)6dC9pq)Gx)i55d(RpWyGhOF4in79hXTM9(dE9JKNp4V(aJXFG(HJ0S3FavMLgL4X)Gx)i55d(RpWcUhOF4in79ha4K4U3FWRFK88b)1x)bAcFGEGb5b6h86hjpFW)bIKkts)hOULZU2gqDtM56kpnoe6xPgimUNlKwWiAjcr6hosZE)Xr290yVKkF9bgdFG(bV(rYZh8FGiPYK0)bQB5SRTbu3KzUUYtJdH(vQbcJ75cPfmIwIqK(HJ0S3F4lIHkXLgKlLV(ahHhOFWRFK88b)hisQmj9FG6wo7ABa1nzMRR804qOFLAGW4EUqAbJOLiePF4in79h2KWhz3ZxFGRGhOF4in79hYueafAWyCNI48Q)Gx)i55d(RpW1)a9dE9JKNp4)arsLjP)du3YzxBdOUjZCDLNghc9Rudeg3ZfslyeTGbIeTaiG0IM4SrBZmzAraAbKi8dhPzV)4WeitWmxXxFGXapq)Gx)i55d(pqKuzs6)4CT2aQBYmxx5PXHq)k1WnMwaJwImA5CT2WHjqMGzUIHBmTaiG0Y5ATHJS7PXEjvgUX0cGaslcIwioIdkPLsAbmArq0cXrCOjiAjYPfabKw0eNnABMjtlcqlyig4hosZE)rCRzVV(aJXFG(bV(rYZh8FGiPYK0)H6erwdZeQ(IyAbJWslyGF4in79homMrQPTgfa2WUOKF9bwW9a9dhPzV)W2OlKNgxWZKuzZHD8FWRFK88b)1h4k8b6h86hjpFW)bIKkts)h2gDH0Ia0ITrxya3RJwemAjcrIwaJwoxRnG6MmZ1vEACi0VsnCJ)HJ0S3FGZ4nPstBnYlkNMjHDC4RpWGePhOFWRFK88b)hisQmj9FCUwBa1nzMRR804qOFLA4g)dhPzV)4i7EAARrbGn8Y4v(6dmiG8a9dhPzV)i(ssBL5kAoshQ)Gx)i55d(RpWGGHpq)WrA27peVozM(AARXf8mPva(bV(rYZh8xFGbjcpq)WrA27pizCSKn5AGXoI)bV(rYZh8xFGbPcEG(bV(rYZh8FGiPYK0)H9kLgcJaWjISrtCMweGwaHwIiTiIM)WrA27pq9I4vjUYtJv648RpWGu)d0p41psE(G)dejvMK(poxRnqyeMsgcn2MG4Wn(hosZE)HcaBU7PV70yBcIF9bgemWd0pCKM9(JAnrofIZ1qyyV(I4FWRFK88b)1x)XKT(vQpqpWG8a9dE9JKNp4)arsLjP)JjFUwBa5qnxXWnMwaeqAzYNR1gMjmMLs)izdUlMOWnMwaeqAzYNR1gMjmMLs)izdVexKd34F4in79hixknosZEnYeQ)qMq1Soo)JRMYuR81hym8b6hosZE)XfYMuzC4p41psE(G)6dCeEG(bV(rYZh8F4in79hixknosZEnYeQ)qMq1Soo)d0e(6dCf8a9dE9JKNp4)arsLjP)dhPPqSHxgpziTiaTebAbmArDjVAabGJjXXHbE9JKN0cy0I6sE1GlJbWnXeE6Atc86hjp)HJ0S3FGCP04in71itO(dzcvZ648p84A281h46FG(bV(rYZh8FGiPYK0)HJ0ui2WlJNmKweGwIaTagTOUKxnGaWXK44WaV(rYZF4in79hixknosZEnYeQ)qMq1Soo)JA281hymWd0p41psE(G)dejvMK(pCKMcXgEz8KH0Ia0seOfWOfbrlQl5vdUmga3et4PRnjWRFK8KwaJweeTOUKxnulLtBsytU2lm7nWRFK88hosZE)bYLsJJ0SxJmH6pKjunRJZ)aQV(aJXFG(bV(rYZh8FGiPYK0)HJ0ui2WlJNmKweGwIaTagTOUKxn4YyaCtmHNU2KaV(rYtAbmArq0I6sE1qTuoTjHn5AVWS3aV(rYZF4in79hixknosZEnYeQ)qMq1Soo)dpgQV(al4EG(bV(rYZh8FGiPYK0)HJ0ui2WlJNmKweGwIaTagTOUKxn4YyaCtmHNU2KaV(rYtAbmArDjVAOwkN2KWMCTxy2BGx)i55pCKM9(dKlLghPzVgzc1FitOAwhN)HhxZMV(axHpq)Gx)i55d(pqKuzs6)WrAkeB4LXtgslcqlrGwaJweeTOUKxn4YyaCtmHNU2KaV(rYtAbmArDjVAOwkN2KWMCTxy2BGx)i55pCKM9(dKlLghPzVgzc1FitOAwhN)rnB(6dmir6b6h86hjpFW)bIKkts)hostHydVmEYqAbJOfq(HJ0S3FGCP04in71itO(dzcvZ648pqs2fIF9bgeqEG(HJ0S3FG6fXRsCLNgR0X5FWRFK88b)1hyqWWhOF4in79hob5lB0Mq4v)bV(rYZh8xF9hxnLPw5d0dmipq)WrA27pWVcEbVK)bV(rYZh8xFGXWhOF4in79hqMWBQvAMxO(dE9JKNp4V(ahHhOF4in79hW4MWgKSVZFWRFK88b)1h4k4b6hosZE)bSBfGCfn1CLj)Gx)i55d(RpW1)a9dhPzV)a2BImhPd1FWRFK88b)1hymWd0pCKM9(JLvayIbcqJW8h86hjpFWF9bgJ)a9dhPzV)abqIXiHgL4lg03uMAL)Gx)i55d(RpWcUhOF4in79hW4KKQbcqJW8h86hjpFWF9bUcFG(HJ0S3FSUEjm0isCe)dE9JKNp4V(6R)qiMaZEFGXWibsfgjmedX4bqabemWpQ5Knxr4pWGdpUjkpPLkKwCKM9slYeQWaT6pIjTnL8pQiAzCjcLc5sAbdI7QmHwTIOfaungIXckOIPcW9eqnoOWe)kDn7frCRckmXrGsRwr0s1RSsAPcfMwWWibsfslcgTaciySris0Q0QveTuXcGVImeJLwTIOfbJwQ4ZjpPLkMRGxWlzArBAzYw)kvAXrA2lTitOgOvRiArWOLkwa8vKN0I6erwnPLw46IjmeM9cPfTPfuLijBuNiYkmqRwr0IGrlvm9mTjpPfKteInOjHw0MwQ1emPf8MW0c7WuwjTulvaOffaMw85SxmOG0sIhlzCEvxZEPL2slc5K0psoqRwr0IGrlv85KN0YvtzQvslvCmyXGpqRsRwr0cgZ6y0v5jTCyBtyAb14hxPLdlMlmqlvCeIJviTS9kya4eC7vslosZEH0sVYkd0QosZEHHycJA8JRyTshIjTQJ0SxyiMWOg)4AuSG6xrCEvxZEPvDKM9cdXeg14hxJIfuB3tAvhPzVWqmHrn(X1OybfEXX71eZkTAfrlJ1JHa0kTq8CslNR1YtAbQUcPLdBBctlOg)4kTCyXCH0IVtAjMWcwCRAUI0scPLzVCGw1rA2lmetyuJFCnkwqHRhdbOvduDfsR6in7fgIjmQXpUgflOXTM9sR6in7fgIjmQXpUgflOqLzPrjEmTQJ0SxyiMWOg)4AuSGcGtI7EPvPvDKM9cdxnLPwjw8RGxWlzAvhPzVWWvtzQvgflOqMWBQvAMxOsR6in7fgUAktTYOybfg3e2GK9DsR6in7fgUAktTYOybf2TcqUIMAUYeAvhPzVWWvtzQvgflOWEtK5iDOsR6in7fgUAktTYOybDzfaMyGa0imPvDKM9cdxnLPwzuSGIaiXyKqJs8fd6BktTsAvhPzVWWvtzQvgflOW4KKQbcqJWKw1rA2lmC1uMALrXc666LWqJiXrmTkTAfrlymRJrxLN0cletQKw0eNPffaMwCK2eAjH0IlKNs)i5aTQJ0SxiwKlLghPzVgzcvHxhNXE1uMALcNwSt(CT2aYHAUIHBmGao5Z1AdZegZsPFKSb3ftu4gdiGt(CT2WmHXSu6hjB4L4IC4gtR6in7fgflOxiBsLXH0QosZEHrXckYLsJJ0SxJmHQWRJZyrtiTQJ0SxyuSGICP04in71itOk864mwpUMnfoTyDKMcXgEz8KHcebWuxYRgqa4ysCCyGx)i5jyQl5vdUmga3et4PRnjWRFK8Kw1rA2lmkwqrUuACKM9AKjufEDCgBnBkCAX6infIn8Y4jdficGPUKxnGaWXK44WaV(rYtAvhPzVWOybf5sPXrA2RrMqv41XzSqv40I1rAkeB4LXtgkqeatqQl5vdUmga3et4PRnjWRFK8embPUKxnulLtBsytU2lm7nWRFK8Kw1rA2lmkwqrUuACKM9AKjufEDCgRhdvHtlwhPPqSHxgpzOaram1L8QbxgdGBIj801Me41psEcMGuxYRgQLYPnjSjx7fM9g41psEsR6in7fgflOixknosZEnYeQcVooJ1JRztHtlwhPPqSHxgpzOaram1L8QbxgdGBIj801Me41psEcM6sE1qTuoTjHn5AVWS3aV(rYtAvhPzVWOybf5sPXrA2RrMqv41XzS1SPWPfRJ0ui2WlJNmuGiaMGuxYRgCzmaUjMWtxBsGx)i5jyQl5vd1s50Me2KR9cZEd86hjpPvDKM9cJIfuKlLghPzVgzcvHxhNXIKSlelCAX6infIn8Y4jdXiqOvDKM9cJIfuuViEvIR80yLootR6in7fgflOob5lB0Mq4vPvPvDKM9cdEmuXI3Ry3q2CsLfoTypxRnG6MmZ1vEACi0VsnCJblYoxRnG6MmZ1vEACi0VsnqyCpxOaGeQpIIOjGaEUwB4iVetBnQl7fgUXGDUwB4iVetBnQl7fgimUNluaqc1hrr0mYPvDKM9cdEmuJIfuIhRnXavsIjlCAXEUwBa1nzMRR804qOFLA4gdwKDUwBa1nzMRR804qOFLAGW4EUqbajuFefrtab8CT2WrEjM2Aux2lmCJb7CT2WrEjM2Aux2lmqyCpxOaGeQpIIOzKtR6in7fg8yOgflOwPVyMRObQKetw40I12OlmkYHQHWI8kGTrxya3RJw1rA2lm4XqnkwqXmLsdQXX9DkCAXAVsPHWiaCIiB0eNfaKq9ruenbZ2OlmkYHQHWI8kGTrxya3RtWajs0QosZEHbpgQrXckuzwAuIhlCAXAB0fgf5q1qyrEfW2OlmG71rR6in7fg8yOgflO1s50Me2CA8JWPfRTrxyuKdvdHf5vaBJUWaUxhycsteM5kcMGoxRnGZ4nPstBnYlkNMjHDCy4gdwKzVsPHWiaCIiB0eNfaKq9ruenbeqbnBnulLtBsyZPXpbnryMRiyc6CT2aQBYmxx5PXHq)k1WnoYPvDKM9cdEmuJIfuitI5vnqnxrHtlwbnBnazsmVQbQ5kg0eHzUIGjOZ1AdOUjZCDLNghc9Rud3yAvhPzVWGhd1OybfZuknOgh33PWPfRTrxyuKdvdHf5vaBJUWaUxhyr25ATb8Ef7gYg7LuzaQoctbQhqaTn6cfWrA2BaVxXUHS5KkhqnuJCAvhPzVWGhd1OybfYKyEvduZvu40ILWwcdbWpsgmbDUwBa1nzMRR804qOFLA4gd25ATb8Ef7gYg7LuzaQoctbQNw1rA2lm4XqnkwqDd(LmzIPTgePRbfoTyf05ATbu3KzUUYtJdH(vQHBmTQJ0SxyWJHAuSGI6MmZ1vEACi0VsLw1rA2lm4XqnkwqX7vSBiBoPYcNwSNR1gW7vSBiBSxsLHBmGaAB0fgf5q1qyrEXiBJUWaUxNGbsKaeWZ1AdOUjZCDLNghc9Rud3yAvhPzVWGhd1OybL4XAtmqLKyY0QosZEHbpgQrXcATuoTjHnNg)iCAXkinryMRiTkTQJ0SxyWJRztS49k2nKnNuzHtl2Z1Adh5LyARrDzVWWngSZ1Adh5LyARrDzVWaHX9CHciIM0QosZEHbpUMnJIfuIhRnXavsIjlCAXEUwB4iVetBnQl7fgUXGDUwB4iVetBnQl7fgimUNluar0Kw1rA2lm4X1SzuSGczsmVQbQ5kkCAXkOzRbitI5vnqnxXGMimZvKw1rA2lm4X1SzuSG6g8lzYetBnisxdsR6in7fg84A2mkwqRLYPnjS504hHtlw7vknegbGtezJM4SaGeQpIIOjGaAB0fgf5q1qyrEfW2OlmG71bwKTCDQPwAon(jiulDnLmyZwdqMeZRAGAUIbnryMRiyZwdqMeZRAGAUIbcBjmea)izabC56utT0CA8tigaM049YGjOZ1Ad49k2nKn2lPYWngmBJUWOihQgclYRa2gDHbCVobZrA2BaZuknOgh33za5q1qyrEJyeICAvhPzVWGhxZMrXckQBYmxx5PXHq)kvAvhPzVWGhxZMrXckEVIDdzZjvw40I9CT2aEVIDdzJ9sQmqyCpxiylxNAQLMtJFcXaWKgVxMw1rA2lm4X1SzuSGIzkLguJJ77u40I1ELsdHra4er2OjolaiH6JOiAcMTrxyuKdvdHf5vaBJUWaUxNGHHrIw1rA2lm4X1SzuSGcvMLgL4XcNwS2gDHrrounewKxbSn6cd4ED0QosZEHbpUMnJIfuIhRnXavsIjlCAXEUwBqZytBnkaSbgZojavhHj2iaiGZwdqaiE8YsZPXpbnryMRiTQJ0SxyWJRzZOybfVxXUHS5KklCAXoBnabG4XllnNg)e0eHzUI0QosZEHbpUMnJIf0APCAtcBon(r40ID56utT0CA8tacaXJxwcMTrxigfHib2S1aKjX8QgOMRyGW4EUqmQ(ikIM0QosZEHbpUMnJIfueaoMehhkCAXkOZ1Ad49k2nKn2lPYaHX9CH0QosZEHbpUMnJIfuitI5vnqnxrHtlwcBjmea)izAvhPzVWGhxZMrXckMPuAqnoUVtHtlwBJUWOihQgclYRa2gDHbCVoWISZ1Ad49k2nKn2lPYauDeMcupGaAB0fkGJ0S3aEVIDdzZjvoGAOg50QosZEHbpUMnJIfuIhRnXavsIjtR6in7fg84A2mkwqX7vSBiBoPYcNwSNR1gW7vSBiBSxsLHBmGaAB0fIrvqKaeWzRbiaepEzP504NGMimZvKw1rA2lm4X1SzuSGwlLtBsyZPXpcNwSlxNAQLMtJFcc1sxtjd2S1aKjX8QgOMRyqteM5kciGlxNAQLMtJFcXaWKgVxgqaxUo1ulnNg)eGaq84LLGzB0fIr1hjAvAvhPzVWaAcXEKDpn2lPsHtlwu3YzxBdOUjZCDLNghc9Rudeg3ZfIrris0QosZEHb0egflO(IyOsCPb5sPWPflQB5SRTbu3KzUUYtJdH(vQbcJ75cXOiejAvhPzVWaAcJIfuBs4JS7PWPflQB5SRTbu3KzUUYtJdH(vQbcJ75cXOiejAvhPzVWaAcJIfuzkcGcnymUtrCEvAvhPzVWaAcJIf0dtGmbZCffoTyrDlNDTnG6MmZ1vEACi0VsnqyCpxigHbIeGaQjoB02mtwaqIaTQJ0SxyanHrXcACRzVcNwSNR1gqDtM56kpnoe6xPgUXGfzNR1gombYemZvmCJbeWZ1Adhz3tJ9sQmCJbeqbrCehuslLGjiIJ4qtqroGaQjoB02mtwamedqR6in7fgqtyuSG6WygPM2Auayd7Isw40IvDIiRHzcvFrmgHfdqR6in7fgqtyuSGAB0fYtJl4zsQS5WooTQJ0SxyanHrXckoJ3KknT1iVOCAMe2XHcNwS2gDHcyB0fgW96eSiejWoxRnG6MmZ1vEACi0VsnCJPvDKM9cdOjmkwqpYUNM2AuaydVmELcNwSNR1gqDtM56kpnoe6xPgUX0QosZEHb0egflOXxsARmxrZr6qLw1rA2lmGMWOybv86Kz6RPTgxWZKwbGw1rA2lmGMWOybLKXXs2KRbg7iMw1rA2lmGMWOybf1lIxL4kpnwPJZcNwS2RuAimcaNiYgnXzbajIIOjTQJ0SxyanHrXcQcaBU7PV70yBcIfoTypxRnqyeMsgcn2MG4WnMw1rA2lmGMWOybTwtKtH4Cneg2RViMwLw1rA2lmGKSleJviNK(rYcVooJf5eHydAseUJXcznTclKlVmwhPPqSHxgpzOWc5YlByjKXwVWOENPM9I1rAkeB4LXtgkq90QosZEHbKKDH4Oyb1n4xYKjM2AqKUgKw1rA2lmGKSlehflOOUjZCDLNghc9RuPvDKM9cdij7cXrXckYjcXcNwSZwdqaiE8YsZPXpbnryMRiTQJ0SxyajzxiokwqRLYPnjS504hHtlwbPUKxniEzcjLs3OostemWRFK8eqaTxP0qyeaorKnAIZciIM0QosZEHbKKDH4OybfVxXUHS5KklmQsKKnQtezfIfeHtl2jFUwBq6kVQjUtyVbO6imXcsKOvDKM9cdij7cXrXckcahtIJdPvDKM9cdij7cXrXckMPuAqnoUVtHrvIKSrDIiRqSGiCAXAB0fgf5q1qyrEfW2OlmG71rR6in7fgqs2fIJIf0ZvraWKkfoTyTxP0qyeaorKnAIZciIMacOGuxYRgQLYPnjSjx7fM9g41psEciGZwdqaiE8YsZPXpbnryMRiyZwd5QmzDP5izEMRyaQoctbIaTQJ0Sxyajzxiokwqroriw40IvDjVAq8YeskLUrDKMiyGx)i5jTQJ0SxyajzxiokwqTsFXmxrdujjMSWPfRTrxyuKdvdHf5vaBJUWaUxhTQJ0SxyajzxiokwqRLYPnjS504hHtl2zRHAPCAtcBon(jqylHHa4hjdiGQl5vd1s50Me2KR9cZEd86hjpPvDKM9cdij7cXrXckKjX8QgOMROWOkrs2OorKviwqeoTypxRniugZeOriEB8aHDKsR6in7fgqs2fIJIfuKteIfoTyrDlNDTnulLtBsyZPXpbcJ75cXiHCs6hjhqori2GMemiXqAvhPzVWasYUqCuSGcvMLgL4X0QosZEHbKKDH4OybfaNe39kCAXQUKxnOmbhAARHxrxKX5vd86hjpPvDKM9cdij7cXrXckKjX8QgOMROWOkrs2OorKviwqeoTyjSLWqa8JKb7CT2GMXM2AuaydmMDsaQoctbIaTAfrla10cmXVsxzA5cDrMwSnHwQy6vSBitlGNktlnHwWGXJ1MqldLKyY0Y8sYvKwQ4WygP0sBPffaMwWy6IswyAb1XvslSJaGwAe6si8IyAPT0IcatlosZEPfFN0IhhZ7KwmSlkzArBArbGPfhPzV0Y64CGw1rA2lmGKSlehflO49k2nKnNuzHrvIKSrDIiRqSGqR6in7fgqs2fIJIfuIhRnXavsIjlmQsKKnQtezfIfeAvAvhPzVWauXcGtI7EfoTyvxYRguMGdnT1WROlY48QbE9JKN0QosZEHbOgflOwPVyMRObQKetw40I12OlmkYHQHWI8kGTrxya3RJw1rA2lma1OybL4XAtmqLKyYcNwSNR1gqDtM56kpnoe6xPgUXGfzNR1gqDtM56kpnoe6xPgimUNluaqc1hrr0eqapxRnCKxIPTg1L9cd3yWoxRnCKxIPTg1L9cdeg3ZfkaiH6JOiAg50QveTautlWe)kDLPLl0fzAX2eAPIPxXUHmTaEQmT0eAbdgpwBcTmusIjtlZljxrAPIdJzKslTLwuayAbJPlkzHPfuhxjTWocaAPrOlHWlIPL2slkamT4in7Lw8DslECmVtAXWUOKPfTPffaMwCKM9slRJZbAvhPzVWauJIfu8Ef7gYMtQSWPf75ATbu3KzUUYtJdH(vQHBmyr25ATbu3KzUUYtJdH(vQbcJ75cfaKq9ruenbeWZ1Adh5LyARrDzVWWngSZ1Adh5LyARrDzVWaHX9CHcasO(ikIMroTQJ0SxyaQrXckMPuAqnoUVtHtlwBJUWOihQgclYRa2gDHbCVoAvhPzVWauJIfuOYS0Oepw40I12OlmkYHQHWI8kGTrxya3RJw1rA2lma1OybTwkN2KWMtJFeoTyTn6cJICOAiSiVcyB0fgW96atqAIWmxrWe05ATbCgVjvAARrEr50mjSJdd3yWIm7vknegbGtezJM4SaGeQpIIOjGakOzRHAPCAtcBon(jOjcZCfbtqNR1gqDtM56kpnoe6xPgUXroTQJ0SxyaQrXckEVIDdzZjvw40I9CT2aEVIDdzJ9sQmavhHjgvpycc1TC212aQBYmxx5PXHq)k1aHX9CH0QosZEHbOgflOqMeZRAGAUIcNwSNR1gekJzc0ieVnE4gd2S1aKjX8QgOMRyGW4EUqbQGikIMac4S1aKjX8QgOMRyGWwcdbWpsgmbDUwBa1nzMRR804qOFLA4gtR6in7fgGAuSG6g8lzYetBnisxdkCAXkOZ1AdOUjZCDLNghc9Rud3yAvhPzVWauJIfuu3KzUUYtJdH(vQ0QosZEHbOgflO49k2nKnNuzHtl2Z1Ad49k2nKn2lPYWngqaTn6cJICOAiSiVyKTrxya3RtWWWibM6sE1GqzmtGgH4TXd86hjpbeqBJUWOihQgclYlgzB0fgW96emqatDjVAqzco00wdVIUiJZRg41psEciGNR1gqDtM56kpnoe6xPgUX0QosZEHbOgflOepwBIbQKetMw1rA2lma1OybTwkN2KWMtJFeoTyNTgQLYPnjS504NaHTegcGFKmTQJ0SxyaQrXckKjX8QgOMROWPf75ATbHYyMancXBJhUX0Q0QosZEHHA2elaojU7v40I12OlmkYHQHWI8kGTrxya3Rdm1L8QbLj4qtBn8k6ImoVAGx)i5jTQJ0SxyOMnJIfu8Ef7gYMtQSWPf75ATHJ8smT1OUSxy4gd25ATHJ8smT1OUSxyGW4EUqbertAvhPzVWqnBgflOepwBIbQKetw40I9CT2WrEjM2Aux2lmCJb7CT2WrEjM2Aux2lmqyCpxOaIOjTQJ0SxyOMnJIfuitI5vnqnxrHtl2Z1AdcLXmbAeI3gpCJb7CT2GqzmtGgH4TXdeg3ZfkaiH6JOiAciGcA2AaYKyEvduZvmOjcZCfPvDKM9cd1SzuSGwlLtBsyZPXpcNwS2RuAimcaNiYgnXzbajuFefrtWSn6cJICOAiSiVcyB0fgW96aeWiB56utT0CA8tqOw6AkzWMTgGmjMx1a1CfdAIWmxrWMTgGmjMx1a1Cfde2syia(rYac4Y1PMAP504NqmamPX7LbtqNR1gW7vSBiBSxsLHBmy2gDHrrounewKxbSn6cd4EDcMJ0S3aMPuAqnoUVZaYHQHWI8gXie50QosZEHHA2mkwqXmLsdQXX9DkCAXAB0fgf5q1qyrEfW2OlmG71jy2gDHbclYlTQJ0SxyOMnJIfu3GFjtMyARbr6AqAvhPzVWqnBgflOqLzPrjESWPfRTrxyuKdvdHf5vaBJUWaUxhTQJ0SxyOMnJIf0APCAtcBon(r40I1ELsdHra4er2OjolaiH6JOiAsR6in7fgQzZOybf1nzMRR804qOFLkTQJ0SxyOMnJIfuitI5vnqnxrHtl2Z1AdcLXmbAeI3gpCJbB2AaYKyEvduZvmqyCpxOavqefrtAvhPzVWqnBgflO49k2nKnNuzHtl2zRbiaepEzP504NGMimZveqapxRnG3Ry3q2yVKkdq1ryITEAvhPzVWqnBgflO1s50Me2CA8JWPf7Y1PMAP504NaeaIhVSeSzRbitI5vnqnxXaHX9CHyu9ruenPvDKM9cd1SzuSGczsmVQbQ5kkCAXsylHHa4hjtR6in7fgQzZOybfbGJjXXHcNwSc6CT2aEVIDdzJ9sQmqyCpxiTQJ0SxyOMnJIfu8Ef7gYMtQmTQJ0SxyOMnJIfuIhRnXavsIjtR6in7fgQzZOybfYKyEvduZvu40I9CT2GqzmtGgH4TXd3yAvhPzVWqnBgflO1s50Me2CA8JWPf7Y1PMAP504NGqT01uYGnBnazsmVQbQ5kg0eHzUIac4Y1PMAP504NqmamPX7LbeWLRtn1sZPXpbiaepEz5pGXm6bgdRV(xF9Fa]] )


end