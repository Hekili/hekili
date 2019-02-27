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
            cooldown = 120,
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
            id = 270323,            
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
            id = 270335,
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
            id = 271045,
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
            id = 259495,
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


    spec:RegisterPack( "Survival", 20190227.1116, [[dGuxpbqiqv9iIQYLiQQInPc(KkuiJIOsNIOkRIQk6vGWSOQ0TikQDrLFreggrfhJQQwgrHNruQPrvfUgvvABQq13uHsJJOiohrvL1bQszEer3JiTpIsoirrAHGkpeuLQlcQsAJevvPrQcf4KevvvRufzMevvLBcQsStqQHQcfQLQcf5PQ0ubr7f4VKAWeoSWIf1Jr1KvQlJSzL8zQYOfjNwYQvHI61GKztYTrPDl1VvmCrCCvOGwoupxvtNY1rX2vr9DrQXRc58uvSEqvmFqz)qg4pasWDhgbGwgYXF5NCKHmowN)(7)XLTmbCnFsiWnj4qfEe42blbUxg856COa3KWh1eBaKG7pmyobUPml5H3KqcVYsXKD8HvIVyzuHvtZXXYK4lwUeGBMPuM8)gKb3DyeaAzih)LFYrgY4yD(7V)hx2hl4gmwQbdU3ILrfwnn8oowg4MQ2BQbzWDtphCLpK4YGpxNdfsCmGPncJojFirkZsE4njKWRSumzhFyL4lwgvy10CCSmj(ILlb6K8HeYFPmMjW(GeY4y9fjKHC8x(HeYms4VCG38JJJeYu4f0j0j5djG3tfTh9WBOtYhsiZiHmDVPnsWyLQmFqcz6Xy5Fo0j5djKzKaEpv0E0gjSa7rMUwibDucM(VM(rcBqcUpCfPTa7r27qNKpKqMrc4LzxRI2ibpWNjnFJrcBqI0dgkKGDWesqXxkFqI0LLcjSuese790hJEKOytuel1wy10iXSqIZbUISICGRQE7bqcUPxL(naKaO9haj4gCRMgCdnldEty9S0C8K(bxQJSI2a4agaAzaGeCdUvtdU8zW7QdJ264)GrzGl1rwrBaCadaTSbqcUuhzfTbWbUCCzeUcWnGhcxg5sxQnHB6F9ZGpxNdLJ6iROnsCajA6itNU05Hn7opQWkfHehqI9yUNWjuB63Q2ZHj2O6hjKfsidN)iHFIeE8nsCaj2J5EcNqTPFRAphMyJQFKqsKq2o)Ie(js4X3iXbKGpJApPBx6sTxfM05Hn7WeBu9JeYcjKHZViHFIeE8n4gCRMgCzN2BMN05YiGbG2paqcUuhzfTbWbUCCzeUcWDXOuAmXtfypsBflHesIeE8nsadgsixKynCMhjGaj4XBAm5rnsijsSgoZ7yJJqc5Hehqc5IenDKPtx68WMDNhvyLIqIdiXEm3t4eQn9Bv75SIdv1EiXbKypM7jCc1M(TQ9CyAHPpvKvesadgs00rMoDPZdB2LKIWd70esCajGpsKzwlh70EZ8KEXG9XXKGehqI1WzEKacKGhVPXKh1iHKiXA4mVJnocjKzKi4wnTdQsP08HLn6TJhVPXKh1iHFIeYgjKh4gCRMgCtxQ9QWKopSzGbG2VaibxQJSI2a4axoUmcxb4UgoZJeqGe84nnM8OgjKejwdN5DSXriXbKiZSwoRs0ZsBPi9Nqb29wWHcjKejKnsCajKlsaFKWcf1MlujPcDcM2Hnyh1rwrBKagmKiZSwo2P9M5j9Ib7J7TGdfsijs4xKagmKynCMhjKejcUvt7yN2BMN05YihFEdjKh4gCRMgCHQuknFyzJEdma0hhaj4sDKv0gah4YXLr4ka39yUQnc3HsNveTR2Z9wWHcjKejKnsCaj2J5(u4iPjLopSzNvCOQ2djoGeWhjSqrT5yN2BMN05Yih1rwrBWn4wnn4IJeBW63WfueWaqFSaibxQJSI2a4axoUmcxb420rMoDPZdB29PWrstkK4asKzwlh70EZ8KEXG9XTN0nsCajKlsWNrTN0TdQsP08HLn6TdtSr1psilKWJVrcyWqI1WzEKqwiXXLdsipK4asaFKypM7jCc1M(TQ9CyAHPpvKve4gCRMgCtxQ9QWKopSzGbGwMaGeCdUvtdUVrKsB4ibCPoYkAdGdyaOLFaibxQJSI2a4axoUmcxb4UgoZJeqGe84nnM8OgjKejwdN5DSXrGBWTAAWDPIgQQ90VHlOiGbG2F5aGeCPoYkAdGdC54YiCfGBMzTCNRec)6ZupSomfCdjGbdjW0ctFQiRiK4asixKa(iHfkQnh70EZ8Koxg5OoYkAJeWGHeWhjSqrT5oxje(1NPEyDuhzfTrcyWqIMoY0PlDEyZUZJkSsriXbKa(iXEm3NchjnP05Hn7SIdv1EibmyirapeUmYPcJAtNm1pTJ6iROnsadgseWdHlJCNPEyhMxVI27DuhzfTrcyWqImZA5yN2BMN0lgSpU3couiHuKWViH8a3GB10G7t4eQn9Bv7bma0(7pasWL6iROnaoWLJlJWvaUwOO2CgHzF9S0u7fEel1MJ6iROn4gCRMgCtf4KzAGbG2FzaGeCPoYkAdGdC54YiCfGBMzTCSt7nZt6fd2hhtcsadgsSgoZJeYcjoUCqcyWqI9yUpfosAsPZdB2zfhQQ9a3GB10Gl70EZ8Koxgbma0(lBaKGBWTAAWfhj2G1VHlOiWL6iROnaoGbG2F)aaj4sDKv0gah4YXLr4kaxmTW0NkYkcCdUvtdUpHtO20VvThWaq7VFbqcUuhzfTbWbUCCzeUcWTPJmD6sNh2S78OcRuesCaj2J5EcNqTPFRApNvCOQ2djGbdjA6itNU05Hn7ssr4HDAcjGbdjA6itNU05Hn7(u4iPjfsCajwdN5rczHe(voGBWTAAWnDP2Rct68WMbgWaxUIIZeasa0(dGeCPoYkAdGdCNeW9jdCdUvtdUNdCfzfbUNdfdbUb3QZKMAITOhjKfs4xK4as4xKagmKi4wDM0utSf9G75aR7GLaxEGptA(gdma0Yaaj4gCRMgCdnldEty9S0C8K(bxQJSI2a4agaAzdGeCdUvtdU8zW7QdJ264)GrzGl1rwrBaCadaTFaGeCPoYkAdGdC54YiCfG7Em3NchjnP05Hn7SIdv1EGBWTAAWLh4ZeWaq7xaKGl1rwrBaCGlhxgHRaCHpsyHIAZ5XqyCPuH2cUv83rDKv0gjGbdjwmkLgt8ub2J0wXsiHKiHhFdUb3QPb30LAVkmPZdBgyaOpoasWL6iROnaoWn4wnn4YoT3mpPZLrGlhxgHRaC3uMzTCQWO20jt9t7El4qHesrc)Ld4Y9HRiTfypYEa0(dma0hlasWn4wnn4YtfqHd2hCPoYkAdGdyaOLjaibxQJSI2a4a3GB10GluLsP5dlB0BWLJlJWvaURHZ8ibeibpEtJjpQrcjrI1WzEhBCe4Y9HRiTfypYEa0(dma0YpaKGl1rwrBaCGlhxgHRaCxmkLgt8ub2J0wXsiHKiHhFJeWGHeWhjSqrT5sxQ9QWKU6fZxt7OoYkAJeWGHe7XCFkCK0KsNh2SZkouv7HehqI9yUQnc3HsNveTR2Z9wWHcjKejKn4gCRMgCZmgpfH9byaO9xoaibxQJSI2a4axoUmcxb4AHIAZ5XqyCPuH2cUv83rDKv0gCdUvtdU8aFMagaA)9haj4sDKv0gah4YXLr4ka31WzEKacKGhVPXKh1iHKiXA4mVJnocCdUvtdUlv0qvTN(nCbfbma0(ldaKGl1rwrBaCGlhxgHRaC3J5sxQ9QWKopSzhMwy6tfzfHeWGHewOO2CPl1Evysx9I5RPDuhzfTb3GB10GB6sTxfM05Hndma0(lBaKGl1rwrBaCGBWTAAW9jCc1M(TQ9axoUmcxb4Mzwl35kHWV(m1dRdtb3axUpCfPTa7r2dG2FGbG2F)aaj4sDKv0gah4YXLr4kax(mQ9KUDPl1EvysNh2SdtSr1psilK4CGRiRihpWNjnFJrc5piHma3GB10GlpWNjGbG2F)cGeCdUvtdUVrKsB4ibCPoYkAdGdyaO9)4aibxQJSI2a4axoUmcxb4AHIAZzeM91ZstTx4rSuBoQJSI2GBWTAAWnvGtMPbgaA)pwaKGl1rwrBaCGBWTAAW9jCc1M(TQ9axoUmcxb4IPfM(urwriXbKiZSwoRs0ZsBPi9Nqb29wWHcjKejKn4Y9HRiTfypYEa0(dma0(ltaqcUuhzfTbWbUCCzeUcWDtzM1YPcJAtNm1pTJjbCdUvtdUSt7nZt6CzeWaq7V8daj4sDKv0gah4YXLr4ka3nLzwlNkmQnDYu)0oMeWn4wnn4IJeBW63WfueWag4UPvWOmaKaO9haj4sDKv0gah4YXLr4ka3nLzwlhpERAphtcsadgsSPmZA521NqkvKvKMn8kUJjbjGbdj2uMzTC76tiLkYkstno8ihtc4gCRMgC5HsPdUvtRv1BGRQEt3blbUmwPkZhGbGwgaib3GB10GlZt6Yi2hCPoYkAdGdyaOLnasWL6iROnaoWn4wnn4YdLshCRMwRQ3axv9MUdwcC57hyaO9daKGl1rwrBaCGlhxgHRaCdUvNjn1eBrpsijsiBK4asyHIAZLUu7vHjD1lMVM2rDKv0gjoGewOO2CHkjvOtW0oSb7OoYkAJehqcluuBo2P9M5jDUmYrDKv0gCdUvtdU8qP0b3QP1Q6nWvvVP7GLax2Sos0PxL(nGbG2VaibxQJSI2a4axoUmcxb4gCRotAQj2IEKqsKq2iXbKWcf1MlDP2Rct6QxmFnTJ6iROn4gCRMgC5HsPdUvtRv1BGRQEt3blbUPxL(nGbG(4aibxQJSI2a4axoUmcxb4gCRotAQj2IEKqsKqgibmyirapeUmYLvmy9S0wOM(DuhzfTrIdiHfkQnxUW7xplDcM8XrDKv0gjoGezM1YXNbVRomARJ)dgL5ysa3GB10GlpukDWTAATQEdCv1B6oyjW9nGbG(ybqcUuhzfTbWbUCCzeUcWn4wDM0utSf9iHSqc)b3GB10GlpukDWTAATQEdCv1B6oyjWLRO4mbma0YeaKGBWTAAWnW8OjTnym1g4sDKv0gahWag4MGj(WMddajaA)bqcUuhzfTbWbma0Yaaj4sDKv0gahWaqlBaKGl1rwrBaCadaTFaGeCdUvtdUpdl706eYaxQJSI2a4agaA)cGeCPoYkAdGdyaOpoasWn4wnn4Mmwnn4sDKv0gahWaqFSaib3GB10G7BeP0gosaxQJSI2a4agaAzcasWn4wnn4MkWjZ0Gl1rwrBaCadyG7Baibq7pasWn4wnn4gAwg8MW6zP54j9dUuhzfTbWbma0Yaaj4sDKv0gah4YXLr4kaxluuBUCH3VEw6em5JJ6iROnsCajYmRLJpdExDy0wh)hmkZXKGehqc5IezM1YXNbVRomARJ)dgL5WeBu9JesIeE8nsadgsKzwlxwXG1ZsBHA63XKGehqImZA5YkgSEwAlut)omXgv)iHKiHhFJeYdCdUvtdUSt7nZt6CzeWaqlBaKGl1rwrBaCGlhxgHRaCTqrT5YfE)6zPtWKpoQJSI2iXbKiZSwo(m4D1HrBD8FWOmhtcsCajKlsKzwlhFg8U6WOTo(pyuMdtSr1psijs4X3ibmyirMzTCzfdwplTfQPFhtcsCajYmRLlRyW6zPTqn97WeBu9JesIeE8nsipWn4wnn4IJeBW63WfueWaq7haibxQJSI2a4axoUmcxb4Mzwl35kHWV(m1dRdtb3qIdirMzTCNRec)6ZupSomXgv)iHKiHhFdUb3QPb3NWjuB63Q2dyaO9lasWL6iROnaoWLJlJWvaURHZ8ibeibpEtJjpQrcjrI1WzEhBCesCajKlsaFKWcf1MlujPcDcM2Hnyh1rwrBKagmKWcf1MlujPcDcM2Hnyh1rwrBK4asSyuknM4PcShPTILqcjrc)D(fj8tKWJVrIdiXA4mpsabsWJ30yYJAKqsKynCM3XghHeYmsid5GeYdCdUvtdUqvkLMpSSrVbga6JdGeCPoYkAdGdC54YiCfG7A4mpsabsWJ30yYJAKqsKynCM3XghHehqc5IelgLsJjEQa7rARyjKqsKWJVrcyWqc4Je7XCPl1EvysNh2SZkouv7Hehqc5IezM1YXoT3mpPxmyFC7jDJeWGHelgLsJjEQa7rARyjKqsKWpC(fj8tKWJVrc5HeYdCdUvtdUPl1EvysNh2mWaqFSaibxQJSI2a4axoUmcxb4Mzwl35kHWV(m1dRdtb3qIdiXEm3t4eQn9Bv75WeBu9JesIe(bs4NiHhFJeWGHeWhjSqrT5oxje(1NPEyDuhzfTrIdib8rI9yUNWjuB63Q2ZzfhQQ9qIdib8rImZA54ZG3vhgT1X)bJYCmjGBWTAAW9jCc1M(TQ9agaAzcasWL6iROnaoWLJlJWvaUyAHPpvKvesCajKlseWdHlJCQWO20jt9t7WrdfsilKqgibmyirapeUmYPcJAtNm1pTJ6iROnsCajc4HWLrUZupSdZRxr79oQJSI2ibmyiHCrIaEiCzKtfg1MozQFAh1rwrBKagmKiGhcxg5ot9WomVEfT37OoYkAJeYdjoGeYfjGpseWdHlJCzfdwplTfQPFh1rwrBKagmKa(iHfkQnxUW7xplDcM8XrDKv0gjGbdjGpsKzwlhFg8U6WOTo(pyuMJjbjKhsipWn4wnn4(eoHAt)w1EadaT8daj4gCRMgCFJiL2Wrc4sDKv0gahWaq7VCaqcUuhzfTbWbUCCzeUcW1cf1MZim7RNLMAVWJyP2CuhzfTb3GB10GBQaNmtdma0(7pasWn4wnn4YNbVRomARJ)dgLbUuhzfTbWbma0(ldaKGBWTAAWLNkGchSp4sDKv0gahWaq7VSbqcUuhzfTbWbUCCzeUcWDnCMhjGaj4XBAm5rnsijsSgoZ7yJJa3GB10G7sfnuv7PFdxqradaT)(basWL6iROnaoWLJlJWvaURHZ8ibeibpEtJjpQrcjrI1WzEhBCesCajKlsKzwlh70EZ8KEXG9X9wWHcjKej8dKagmKynCMhjKejcUvt7yN2BMN05YihFEdjKh4gCRMgCHQuknFyzJEdma0(7xaKGl1rwrBaCGlhxgHRaCZmRLJDAVzEsVyW(4ysqcyWqc5IeRHZ8ibeibpEtJjpQrczHeRHZ8o24iKqMrc)LdsadgsyHIAZDUsi8Rpt9W6OoYkAJehqI1WzEKacKGhVPXKh1iHSqI1WzEhBCesiZiHmKdsipKagmKiZSwo(m4D1HrBD8FWOmhtc4gCRMgCzN2BMN05YiGbG2)JdGeCdUvtdU4iXgS(nCbfbUuhzfTbWbma0(FSaibxQJSI2a4axoUmcxb4UhZ9eoHAt)w1EomTW0NkYkcjoGeWhjYmRLJpdExDy0wh)hmkZXKaUb3QPb3NWjuB63Q2dyaO9xMaGeCPoYkAdGdC54YiCfG7Emx6sTxfM05Hn7W0ctFQiRiWn4wnn4MUu7vHjDEyZadyGlF)aibq7pasWL6iROnaoWLJlJWvaU8zu7jD74ZG3vhgT1X)bJYCyInQ(rczHeYwoGBWTAAWnRMzRxmyFagaAzaGeCPoYkAdGdC54YiCfGlFg1Es3o(m4D1HrBD8FWOmhMyJQFKqwiHSLd4gCRMgCJMtVHdLMhkfWaqlBaKGl1rwrBaCGlhxgHRaC5ZO2t62XNbVRomARJ)dgL5WeBu9JeYcjKTCa3GB10G7QWuwnZgyaO9daKGBWTAAWvvEPSxFmZS9yP2axQJSI2a4agaA)cGeCPoYkAdGdC54YiCfGlFg1Es3o(m4D1HrBD8FWOmhMyJQFKqwiXXLdsadgsyflPTrVlcjKej8x2GBWTAAWnt4NWqvThWaqFCaKGl1rwrBaCGlhxgHRaCZmRLJpdExDy0wh)hmkZXKGehqc5IezM1YLj8tyOQ2ZXKGeWGHezM1YLvZS1lgSpoMeKagmKa(ibo4KZWJsHehqc4Je4GtUbZrc5HeWGHewXsAB07IqcjrczCCWn4wnn4MmwnnWaqFSaibxQJSI2a4axoUmcxb4Ab2Jm3UElAoHeYsksCCWn4wnn4gFcXn9S0wkstHNIagWax2Sos0PxL(naKaO9haj4sDKv0gah4YXLr4kax4Je7XCpHtO20VvTNZkouv7bUb3QPb3NWjuB63Q2dyaOLbasWL6iROnaoWLJlJWvaUlgLsJjEQa7rARyjKqsKWJVrcyWqc5IeRHZ8ibeibpEtJjpQrcjrI1WzEhBCesipK4asixKOPJmD6sNh2S78OcRuesCaj2J5EcNqTPFRApNvCOQ2djoGe7XCpHtO20VvTNdtlm9PISIqcyWqIMoY0PlDEyZUKueEyNMqIdib8rImZA5yN2BMN0lgSpoMeK4asSgoZJeqGe84nnM8OgjKejwdN5DSXriHmJeb3QPDqvkLMpSSrVD84nnM8Ogj8tKq2iH8a3GB10GB6sTxfM05Hndma0Ygaj4gCRMgC5ZG3vhgT1X)bJYaxQJSI2a4agaA)aaj4gCRMgCdnldEty9S0C8K(bxQJSI2a4agaA)cGeCdUvtdUVrKsB4ibCPoYkAdGdyaOpoasWL6iROnaoWLJlJWvaUzM1YXoT3mpPxmyFCyInQ(rIdirthz60LopSzxskcpSttGBWTAAWLDAVzEsNlJaga6Jfaj4sDKv0gah4YXLr4ka31WzEKacKGhVPXKh1iHKiXA4mVJnocjoGeYfjYmRLJDAVzEsVyW(4El4qHesIe(fjGbdjwdN5rcjrIGB10o2P9M5jDUmYXN3qc5bUb3QPbxOkLsZhw2O3adaTmbaj4sDKv0gah4YXLr4ka3MoY0PlDEyZUpfosAsHehqI1WzEKqwiXXLdsCaj2J5EcNqTPFRAphMyJQFKqwiHSrc)ej84BWn4wnn4MUu7vHjDEyZadaT8daj4sDKv0gah4YXLr4kaxmTW0NkYkcjoGeYfjA6itNU05Hn7opQWkfHehqc4Je7XCFkCK0KsNh2SZkouv7HeWGHeb8q4YiNkmQnDYu)0oQJSI2ibmyirapeUmYDM6HDyE9kAV3rDKv0gjKh4gCRMgCFcNqTPFRApGbG2F5aGeCPoYkAdGdC54YiCfGBMzTCSt7nZt6fd2hhtcsadgsSgoZJeYcjoUCqcyWqI9yUpfosAsPZdB2zfhQQ9a3GB10Gl70EZ8Koxgbma0(7pasWL6iROnaoWLJlJWvaUyAHPpvKve4gCRMgCFcNqTPFRApGbG2FzaGeCPoYkAdGdC54YiCfGBthz60LopSz35rfwPiK4asShZ9eoHAt)w1EoR4qvThsadgs00rMoDPZdB2LKIWd70esadgs00rMoDPZdB29PWrstkK4asSgoZJeYcj8RCa3GB10GB6sTxfM05HndmGbUmwPkZhaKaO9haj4gCRMgCzzGh4rrGl1rwrBaCadaTmaqcUb3QPb3NWuxMp6nZBGl1rwrBaCadaTSbqcUb3QPb3pzWKMRgMn4sDKv0gahWaq7haib3GB10G7pJLQApD6Wim4sDKv0gahWaq7xaKGBWTAAW9NU46SkEdCPoYkAdGdyaOpoasWn4wnn42KLIW6p1WHcCPoYkAdGdyaOpwaKGBWTAAWLNQoMRxB4OpgYuQY8bCPoYkAdGdyaOLjaib3GB10G7Nu4Y0FQHdf4sDKv0gahWaql)aqcUb3QPb3omgm9ApCWjWL6iROnaoGbmGbUNj8xtdGwgYXF5NCKHmoUtgY2V(fCth4UAVhCL)ZMmyJ2iHmbjcUvtJeQ6T3HobUj4zvkcCLpK4YGpxNdfsCmGPncJojFiH8xkJzcSpiHmowFrczih)LFiHmJe(lh4n)44iHmfEbDcDs(qc49ur7rp8g6K8HeYmsit3BAJemwPkZhKqMEmw(NdDs(qczgjG3tfThTrclWEKPRfsqhLGP)RPFKWgKG7dxrAlWEK9o0j5djKzKaEz21QOnsWd8zsZ3yKWgKi9GHcjyhmHeu8LYhKiDzPqclfHeXEp9XOhjk2efXsTfwnnsmlK4CGRiRih6e6K8HeWRhrCgJ2irMwdMqc(WMddjYKx1VdjKPCoLyps0tlZPcm7IrHeb3QPFKyALpo0PGB10Vlbt8HnhM0LkEOqNcUvt)UemXh2CyqivIGXJLAlSAA0PGB10Vlbt8HnhgesLynZgDk4wn97sWeFyZHbHujEgw2P1jKHojFiXTJKp1yiboQnsKzwlAJeVf2JezAnycj4dBomKitEv)ir0BKibtYCYyw1Eir9iXEAYHofCRM(DjyIpS5WGqQeFhjFQX0Vf2JofCRM(DjyIpS5WGqQejJvtJofCRM(DjyIpS5WGqQeVrKsB4ibDk4wn97sWeFyZHbHujsf4KzA0j0j5djGxpI4mgTrc6mH9bjSILqclfHeb3gmsupseNJsfzf5qNcUvt)s5HsPdUvtRv1B(2bljLXkvz(4BTKUPmZA54XBv75ysGbBtzM1YTRpHuQiRinB4vChtcmyBkZSwUD9jKsfzfPPghEKJjbDk4wn9dHujyEsxgX(Otb3QPFiKkbpukDWTAATQEZ3oyjP89JofCRM(HqQe8qP0b3QP1Q6nF7GLKYM1rIo9Q0V5BTKgCRotAQj2IEjL9bluuBU0LAVkmPREX810oQJSI2hSqrT5cvsQqNGPDyd2rDKv0(GfkQnh70EZ8Koxg5OoYkAJofCRM(HqQe8qP0b3QP1Q6nF7GLKMEv638TwsdUvNjn1eBrVKY(GfkQnx6sTxfM0vVy(AAh1rwrB0PGB10pesLGhkLo4wnTwvV5BhSK038TwsdUvNjn1eBrVKYagSaEiCzKlRyW6zPTqn97OoYkAFWcf1Mlx49RNLobt(4OoYkAFiZSwo(m4D1HrBD8FWOmhtc6uWTA6hcPsWdLshCRMwRQ38TdwskxrXzY3Ajn4wDM0utSf9YYF0PGB10pesLiW8OjTnym1g6e6uWTA63XyLQmFKYYapWJIqNcUvt)ogRuL5desL4jm1L5JEZ8g6uWTA63XyLQmFGqQeFYGjnxnmB0PGB10VJXkvz(aHuj(zSuv7PthgHrNcUvt)ogRuL5desL4NU46SkEdDk4wn97ySsvMpqivIMSuew)PgouOtb3QPFhJvQY8bcPsWtvhZ1RnC0hdzkvz(GofCRM(DmwPkZhiKkXNu4Y0FQHdf6uWTA63XyLQmFGqQeDymy61E4GtOtOtb3QPFhF)sZQz26fd2hFRLu(mQ9KUD8zW7QdJ264)GrzomXgv)Ys2YbDk4wn9747hcPsenNEdhknpukFRLu(mQ9KUD8zW7QdJ264)GrzomXgv)Ys2YbDk4wn9747hcPsSkmLvZS9Tws5ZO2t62XNbVRomARJ)dgL5WeBu9llzlh0PGB10VJVFiKkHQ8szV(yMz7XsTHofCRM(D89dHujYe(jmuv75BTKYNrTN0TJpdExDy0wh)hmkZHj2O6xwhxoWGzflPTrVlss)Ln6uWTA63X3pesLizSAAFRL0mZA54ZG3vhgT1X)bJYCmjhKBMzTCzc)egQQ9CmjWGLzwlxwnZwVyW(4ysGbd(4Gtodpk1b4Jdo5gmxEWGzflPTrVlsszCC0PGB10VJVFiKkr8je30ZsBPinfEkY3Aj1cShzUD9w0Cswspo6e6uWTA63XvuCMKEoWvKvKVDWss5b(mP5BSVtI0NmFphkgsAWT6mPPMyl6LLFp4xyWcUvNjn1eBrp6uWTA63XvuCMGqQeHMLbVjSEwAoEs)Otb3QPFhxrXzccPsWNbVRomARJ)dgLHofCRM(DCffNjiKkbpWNjFRL09yUpfosAsPZdB2zfhQQ9qNcUvt)oUIIZeesLiDP2Rct68WM9TwsHVfkQnNhdHXLsfAl4wXFh1rwrByWwmkLgt8ub2J0wXss6X3Otb3QPFhxrXzccPsWoT3mpPZLr(Y9HRiTfypYEP(7BTKUPmZA5uHrTPtM6N29wWHsQ)YbDk4wn974kkotqivcEQakCW(Otb3QPFhxrXzccPsavPuA(WYg92xUpCfPTa7r2l1FFRL01WzEi4XBAm5rTKRHZ8o24i0PGB10VJRO4mbHujYmgpfH9X3AjDXOuAmXtfypsBfljPhFddg8TqrT5sxQ9QWKU6fZxt7OoYkAdd2Em3NchjnP05Hn7SIdv1Eh2J5Q2iChkDwr0UAp3BbhkjLn6uWTA63XvuCMGqQe8aFM8TwsTqrT58yimUuQqBb3k(7OoYkAJofCRM(DCffNjiKkXsfnuv7PFdxqr(wlPRHZ8qWJ30yYJAjxdN5DSXrOtb3QPFhxrXzccPsKUu7vHjDEyZ(wlP7XCPl1EvysNh2Sdtlm9PISIGbZcf1MlDP2Rct6QxmFnTJ6iROn6uWTA63XvuCMGqQepHtO20VvTNVCF4ksBb2JSxQ)(wlPzM1YDUsi8Rpt9W6WuWn0PGB10VJRO4mbHuj4b(m5BTKYNrTN0TlDP2Rct68WMDyInQ(L15axrwroEGptA(gl)rgOtb3QPFhxrXzccPs8grkTHJe0PGB10VJRO4mbHujsf4KzAFRLuluuBoJWSVEwAQ9cpILAZrDKv0gDk4wn974kkotqivINWjuB63Q2ZxUpCfPTa7r2l1FFRLumTW0NkYk6qMzTCwLONL2sr6pHcS7TGdLKYgDs(qcihK4lwgvyesW8HhHeRbJeWlt7nZtibCLriXGrIJPiXgmsCnCbfHeBgC1EiHm9tiUHeZcjSuesaVgEkYxKGpj(GeuWtHedNZGXuZjKywiHLIqIGB10ir0BKissOEJeAk8uesydsyPiKi4wnns0bl5qNcUvt)oUIIZeesLGDAVzEsNlJ8Tws3uMzTCQWO20jt9t7ysqNcUvt)oUIIZeesLahj2G1VHlOiFRL0nLzwlNkmQnDYu)0oMe0j0PGB10VJnRJeD6vPFt6t4eQn9Bv75BTKc)9yUNWjuB63Q2ZzfhQQ9qNcUvt)o2Sos0PxL(niKkr6sTxfM05Hn7BTKUyuknM4PcShPTILK0JVHbtURHZ8qWJ30yYJAjxdN5DSXrY7GCB6itNU05Hn7opQWkfDypM7jCc1M(TQ9CwXHQAVd7XCpHtO20VvTNdtlm9PISIGbRPJmD6sNh2SljfHh2PPdWpZSwo2P9M5j9Ib7JJj5WA4mpe84nnM8OwY1WzEhBCKmhCRM2bvPuA(WYg92XJ30yYJA)u2YdDk4wn97yZ6irNEv63GqQe8zW7QdJ264)GrzOtb3QPFhBwhj60Rs)gesLi0Sm4nH1ZsZXt6hDk4wn97yZ6irNEv63GqQeVrKsB4ibDs(qcihK4lwgvyesW8HhHeRbJeWlt7nZtibCLriXGrIJPiXgmsCnCbfHeBgC1EiHm9tiUHeZcjSuesaVgEkYxKGpj(GeuWtHedNZGXuZjKywiHLIqIGB10ir0BKissOEJeAk8uesydsyPiKi4wnns0bl5qNcUvt)o2Sos0PxL(niKkb70EZ8Koxg5BTKMzwlh70EZ8KEXG9XHj2O6)qthz60LopSzxskcpSttOtb3QPFhBwhj60Rs)gesLaQsP08HLn6TV1s6A4mpe84nnM8OwY1WzEhBC0b5Mzwlh70EZ8KEXG9X9wWHss)cd2A4mVKb3QPDSt7nZt6CzKJpVjp0PGB10VJnRJeD6vPFdcPsKUu7vHjDEyZ(wlPnDKPtx68WMDFkCK0K6WA4mVSoUCoShZ9eoHAt)w1EomXgv)Ys2(PhFJofCRM(DSzDKOtVk9BqivINWjuB63Q2Z3Ajftlm9PISIoi3MoY0PlDEyZUZJkSsrhG)Em3NchjnP05Hn7SIdv1EWGfWdHlJCQWO20jt9t7OoYkAddwapeUmYDM6HDyE9kAV3rDKv0wEOtb3QPFhBwhj60Rs)gesLGDAVzEsNlJ8TwsZmRLJDAVzEsVyW(4ysGbBnCMxwhxoWGThZ9PWrstkDEyZoR4qvTh6uWTA63XM1rIo9Q0VbHujEcNqTPFRApFRLumTW0NkYkcDk4wn97yZ6irNEv63GqQePl1EvysNh2SV1sAthz60LopSz35rfwPOd7XCpHtO20VvTNZkouv7bdwthz60LopSzxskcpSttWG10rMoDPZdB29PWrstQdRHZ8YYVYbDcDk4wn97EtAOzzWBcRNLMJN0p6K8HeqoiXxSmQWiKG5dpcjwdgjGxM2BMNqc4kJqIbJehtrInyK4A4ckcj2m4Q9qcz6NqCdjMfsyPiKaEn8uKVibFs8bjOGNcjgoNbJPMtiXSqclfHeb3QPrIO3irKKq9gj0u4PiKWgKWsrirWTAAKOdwYHofCRM(DVbHujyN2BMN05YiFRLuluuBUCH3VEw6em5JJ6iRO9HmZA54ZG3vhgT1X)bJYCmjhKBMzTC8zW7QdJ264)GrzomXgv)s6X3WGLzwlxwXG1ZsBHA63XKCiZSwUSIbRNL2c10VdtSr1VKE8T8qNcUvt)U3GqQe4iXgS(nCbf5BTKAHIAZLl8(1ZsNGjFCuhzfTpKzwlhFg8U6WOTo(pyuMJj5GCZmRLJpdExDy0wh)hmkZHj2O6xsp(ggSmZA5YkgSEwAlut)oMKdzM1YLvmy9S0wOM(DyInQ(L0JVLh6uWTA639gesL4jCc1M(TQ98TwsZmRL7CLq4xFM6H1HPGBhYmRL7CLq4xFM6H1Hj2O6xsp(gDk4wn97EdcPsavPuA(WYg923AjDnCMhcE8MgtEul5A4mVJno6GCHVfkQnxOssf6emTdBWoQJSI2WGzHIAZfQKuHobt7WgSJ6iRO9HfJsPXepvG9iTvSKK(78RF6X3hwdN5HGhVPXKh1sUgoZ7yJJKzzih5HofCRM(DVbHujsxQ9QWKopSzFRL01WzEi4XBAm5rTKRHZ8o24OdYDXOuAmXtfypsBfljPhFddg83J5sxQ9QWKopSzNvCOQ27GCZmRLJDAVzEsVyW(42t6ggSfJsPXepvG9iTvSKK(HZV(PhFlp5HofCRM(DVbHujEcNqTPFRApFRL0mZA5oxje(1NPEyDyk42H9yUNWjuB63Q2ZHj2O6xs)Wp94ByWGVfkQn35kHWV(m1dRJ6iRO9b4VhZ9eoHAt)w1EoR4qvT3b4NzwlhFg8U6WOTo(pyuMJjbDk4wn97EdcPs8eoHAt)w1E(wlPyAHPpvKv0b5gWdHlJCQWO20jt9t7WrdLSKbmyb8q4YiNkmQnDYu)0oQJSI2hc4HWLrUZupSdZRxr79oQJSI2WGj3aEiCzKtfg1MozQFAh1rwrByWc4HWLrUZupSdZRxr79oQJSI2Y7GCHFapeUmYLvmy9S0wOM(DuhzfTHbd(wOO2C5cVF9S0jyYhh1rwrByWGFMzTC8zW7QdJ264)GrzoMe5jp0PGB10V7niKkXBeP0gosqNcUvt)U3GqQePcCYmTV1sQfkQnNry2xpln1EHhXsT5OoYkAJofCRM(DVbHuj4ZG3vhgT1X)bJYqNcUvt)U3GqQe8ubu4G9rNcUvt)U3GqQelv0qvTN(nCbf5BTKUgoZdbpEtJjpQLCnCM3XghHofCRM(DVbHujGQuknFyzJE7BTKUgoZdbpEtJjpQLCnCM3XghDqUzM1YXoT3mpPxmyFCVfCOK0pGbBnCMxYGB10o2P9M5jDUmYXN3Kh6uWTA639gesLGDAVzEsNlJ8TwsZmRLJDAVzEsVyW(4ysGbtURHZ8qWJ30yYJAzTgoZ7yJJKz)LdmywOO2CNRec)6ZupSoQJSI2hwdN5HGhVPXKh1YAnCM3XghjZYqoYdgSmZA54ZG3vhgT1X)bJYCmjOtb3QPF3BqivcCKydw)gUGIqNcUvt)U3GqQepHtO20VvTNV1s6Em3t4eQn9Bv75W0ctFQiROdWpZSwo(m4D1HrBD8FWOmhtc6uWTA639gesLiDP2Rct68WM9Tws3J5sxQ9QWKopSzhMwy6tfzfHoHofCRM(DPxL(nPHMLbVjSEwAoEs)Otb3QPFx6vPFdcPsWNbVRomARJ)dgLHojFibKds8flJkmcjy(WJqI1Grc4LP9M5jKaUYiKyWiXXuKydgjUgUGIqIndUApKqM(je3qIzHewkcjGxdpf5lsWNeFqck4PqIHZzWyQ5esmlKWsrirWTAAKi6nsejjuVrcnfEkcjSbjSueseCRMgj6GLCOtb3QPFx6vPFdcPsWoT3mpPZLr(wlPb8q4Yix6sTjCt)RFg856COCuhzfTp00rMoDPZdB2DEuHvk6WEm3t4eQn9Bv75WeBu9llz483p947d7XCpHtO20VvTNdtSr1VKY25x)0JVpWNrTN0TlDP2Rct68WMDyInQ(LLmC(1p94B0PGB10Vl9Q0VbHujsxQ9QWKopSzFRL0fJsPXepvG9iTvSKKE8nmyYDnCMhcE8MgtEul5A4mVJnosEhKBthz60LopSz35rfwPOd7XCpHtO20VvTNZkouv7DypM7jCc1M(TQ9CyAHPpvKvemynDKPtx68WMDjPi8WonDa(zM1YXoT3mpPxmyFCmjhwdN5HGhVPXKh1sUgoZ7yJJK5GB10oOkLsZhw2O3oE8MgtEu7NYwEOtb3QPFx6vPFdcPsavPuA(WYg923AjDnCMhcE8MgtEul5A4mVJno6qMzTCwLONL2sr6pHcS7TGdLKY(GCHVfkQnxOssf6emTdBWoQJSI2WGLzwlh70EZ8KEXG9X9wWHss)cd2A4mVKb3QPDSt7nZt6CzKJpVjp0PGB10Vl9Q0VbHujWrIny9B4ckY3AjDpMRAJWDO0zfr7Q9CVfCOKu2h2J5(u4iPjLopSzNvCOQ27a8TqrT5yN2BMN05Yih1rwrB0PGB10Vl9Q0VbHujsxQ9QWKopSzFRL0MoY0PlDEyZUpfosAsDiZSwo2P9M5j9Ib7JBpP7dYLpJApPBhuLsP5dlB0BhMyJQFz5X3WGTgoZlRJlh5Da(7XCpHtO20VvTNdtlm9PISIqNcUvt)U0Rs)gesL4nIuAdhjOtb3QPFx6vPFdcPsSurdv1E63WfuKV1s6A4mpe84nnM8OwY1WzEhBCe6uWTA63LEv63GqQepHtO20VvTNV1sAMzTCNRec)6ZupSomfCdgmmTW0NkYk6GCHVfkQnh70EZ8Koxg5OoYkAddg8TqrT5oxje(1NPEyDuhzfTHbRPJmD6sNh2S78OcRu0b4VhZ9PWrstkDEyZoR4qvThmyb8q4YiNkmQnDYu)0oQJSI2WGfWdHlJCNPEyhMxVI27DuhzfTHblZSwo2P9M5j9Ib7J7TGdLu)kp0PGB10Vl9Q0VbHujsf4KzAFRLuluuBoJWSVEwAQ9cpILAZrDKv0gDk4wn97sVk9Bqivc2P9M5jDUmY3AjnZSwo2P9M5j9Ib7JJjbgS1WzEzDC5ad2Em3NchjnP05Hn7SIdv1EOtb3QPFx6vPFdcPsGJeBW63Wfue6uWTA63LEv63GqQepHtO20VvTNV1skMwy6tfzfHofCRM(DPxL(niKkr6sTxfM05Hn7BTK20rMoDPZdB2DEuHvk6WEm3t4eQn9Bv75SIdv1EWG10rMoDPZdB2LKIWd70emynDKPtx68WMDFkCK0K6WA4mVS8RCa3pH4aOLHF9lWagaa]] )


end