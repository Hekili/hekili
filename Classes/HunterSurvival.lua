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

    

    spec:RegisterSetting( "ca_vop_overlap", false, {
        name = "|T2065565:0|t Coordinated Assault Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T2065565:0|t Coordinated Assault even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Coordinated Assault would cost you one or more uses of Coordinated Assault in a given fight.",
        type = "toggle",
        width = 1.5
    } )  

    spec:RegisterPack( "Survival", 20200223, [[dG0ARbqivfEKOiDjescBsvYNqijzuiK6ueewLQiELOQzriULOOSlb)cbnmcshtvQLri1ZiKmnrr11qi2MQi5BeezCiK4CIIW6ufPyEQkDpcSpvf5GQIuTqeQhkkI6IiKuTrvrk1ivfPKtIqs0kvfMjcjPUPOiYovv1qriPyPiKu6PQyQQQSxG)s0Gf5WuTyf9yitwHlJAZK6Zcz0IsNwYQjikVgbMnj3gr7wPFl1WfQJtquTCOEoOPt56Q02jO(UOY4vf15ffwVQIA(eQ9J0G3GFGZWng8x0cv0cvOIw0Iki0mXBHk0mhCSmIzWj2re4rm4SojdoNlw4syxboXEgQ2hGFGdSVyedoznlg(0qiHrLL9odOMKqyrEvUv9IWU2iewKicbN5TugrLlycod3yWFrlurluHkArlQGqZeVbh)AzBm4CkYRYTQ3mzSRnWjBng8cMGZGHiWjtPPZflCjSROPNw31ym9rMstznlg(0qiHrLL9odOMKqyrEvUv9IWU2iewKicPpYuA6PnpXxhNbnjArlcnjAHkAHsFqFKP0uMCwFJy4td9rMstzgn90hdEqtzs3p)zfttwttdw7xLrtoYQEPjvbTa9rMstzgnLjN13iEqtMJJytwAAIFogZqy1lKMSMMqzGuS0CCeBWa9rMstzgnLj1Jsx8GMqowywIgyAYAAkxJjGMiBmttSdlvg0uUYYstwwMM8XOxIQG0urgRysEn3QEPPwttc74YNkoqFKP0uMrtp9XGh001kvzzqtpDIAiQoaoQcAqWpWXJHg4h4)BWpWHxFQ4bGyWbHlJXLdoZRwhqDJh16gpKoe6xLfUX00lAIOPP5vRdOUXJADJhshc9RYcyM0RfstFPP3bIqtpHMIqdAsSyAAE16WuDXYwlnx1lmCJPPx008Q1HP6ILTwAUQxyaZKETqA6ln9oqeA6j0ueAqtcb44iR6fCi7nQBilNLXad8x0GFGdV(uXdaXGdcxgJlhCMxToG6gpQ1nEiDi0VklCJPPx0erttZRwhqDJh16gpKoe6xLfWmPxlKM(stVdeHMEcnfHg0KyX008Q1HP6ILTwAUQxy4gttVOP5vRdt1flBT0CvVWaMj9AH00xA6DGi00tOPi0GMecWXrw1l4G9yRXsOHlcyGb(lkWpWHxFQ4bGyWbHlJXLdo6gDH0uEAc5qtI5iEPPV0KUrxyG0FgCCKv9coALVeuBKeA4IagyG)zo4h4WRpv8aqm44iR6fCiOukjQjj9DaoiCzmUCWrFvkjMrzDCelTIKPPV007arOPNqtrObn9IM0n6cPP80eYHMeZr8stFPjDJUWaP)m4GYaPyP54i2GG)Vbg4pra)ahE9PIhaIbheUmgxo4OB0fst5PjKdnjMJ4LM(st6gDHbs)zWXrw1l4anMvsd7Xad8)Pa)ahE9PIhaIbheUmgxo4OB0fst5PjKdnjMJ4LM(st6gDHbs)zA6fn9bnzfIGAJOPx00h008Q1bsMSXziBTuDr1qoWStcd3yA6fnr00K(QusmJY64iwAfjttFPP3bIqtpHMIqdAsSyA6dAA0wixPg6cZYztodwHiO2iA6fn9bnnVADa1nEuRB8q6qOFvw4gttIfttFqtJ2c5k1qxywoBYzWkeb1grtVOP5vRdK9g1nKL6loJa0Ceb00xA6nnje0KyX0KvKS0A5OyA6ln9MOqtVOPpOPrBHCLAOlmlNn5myfIGAJahhzvVGtUsn0fMLZMCcmWFHe4h4WRpv8aqm4GWLX4YbNpOPrBbiJJ51KqR2OGvicQnIMErtFqtZRwhqDJh16gpKoe6xLfUXGJJSQxWbY4yEnj0QncyG)efWpWHxFQ4bGyWXrw1l4qqPusuts67aCq4YyC5GJUrxinLNMqo0KyoIxA6lnPB0fgi9NPPx0erttZRwhi7nQBil1xCgbO5icOPV0erOjXIPjDJUqA6ln5iR6nq2Bu3qwolJdOgA0KqaoOmqkwAooIni4)BGb(Nja)ahE9PIhaIbheUmgxo4GznMHz9PIPPx00h008Q1bu34rTUXdPdH(vzHBmn9IMMxToq2Bu3qwQV4mcqZreqtFPjIaooYQEbhiJJ51KqR2iGb()wOGFGdV(uXdaXGdcxgJlhC(GMMxToG6gpQ1nEiDi0VklCJbhhzvVGJljV4bJLTwIWDoiWa)F)g8dC41NkEaigCq4YyC5GZh008Q1bu34rTUXdPdH(vzHBm44iR6fCqDJh16gpKoe6xLbmW)3Ig8dC41NkEaigCq4YyC5GZ8Q1bYEJ6gYs9fNr4gttIftt6gDH0uEAc5qtI5iEPPprt6gDHbs)zAkZOP3cLMelMMMxToG6gpQ1nEiDi0VklCJbhhzvVGdzVrDdz5SmgyG)Vff4h44iR6fCWES1yj0Wfbm4WRpv8aqmWa)FN5GFGdV(uXdaXGdcxgJlhC(GMScrqTrGJJSQxWjxPg6cZYztobgWahKIDHzWpW)3GFGdV(uXdaXGthdoq2kn44iR6fCe2XLpvm4iSJLRtYGdYXcZs0adoiCzmUCWXrwjml5LjlgstFPjIaoc7QllzfKbhIaoc7QldooYkHzjVmzXqGb(lAWpWXrw1l44sYlEWyzRLiCNdco86tfpaedmWFrb(booYQEbhu34rTUXdPdH(vzGdV(uXdaXad8pZb)ahE9PIhaIbheUmgxo4mAlaZI94LvYztodwHiO2iWXrw1l4GCSWmWa)jc4h4WRpv8aqm4GWLX4YbNpOjZv8AHOlJXLs5sZrwHGbE9PIh0KyX0K(QusmJY64iwAfjttFPPi0aCCKv9co5k1qxywoBYjWa)FkWpWHxFQ4bGyWXrw1l4q2Bu3qwolJbheUmgxo4m45vRdk341KXDb7nanhranjGMEluWbLbsXsZXrSbb)FdmWFHe4h44iR6fCqzDcWojeC41NkEaigyG)efWpWHxFQ4bGyWXrw1l4qqPusuts67aCq4YyC5GJUrxinLNMqo0KyoIxA6lnPB0fgi9NbhugiflnhhXge8)nWa)ZeGFGdV(uXdaXGdcxgJlhC0xLsIzuwhhXsRizA6lnfHg0KyX00h0K5kETqUsn0fML1QVWQ3aV(uXdAsSyAA0waMf7XlRKZMCgScrqTr00lAA0wOwJXRRKtfZJAJcqZreqtFPjrbooYQEbN51qzzCgad8)Tqb)ahE9PIhaIbheUmgxo4yUIxleDzmUukxAoYkemWRpv8aCCKv9coihlmdmW)3Vb)ahE9PIhaIbheUmgxo4OB0fst5PjKdnjMJ4LM(st6gDHbs)zWXrw1l4Ov(sqTrsOHlcyGb()w0GFGdV(uXdaXGdcxgJlhCgTfYvQHUWSC2KZaM1ygM1NkMMelMMmxXRfYvQHUWSSw9fw9g41NkEaooYQEbNCLAOlmlNn5eyG)Vff4h4WRpv8aqm44iR6fCGmoMxtcTAJaheUmgxo4mVADq4kMXqPW82Kbm7idCqzGuS0CCeBqW)3ad8)DMd(bo86tfpaedoiCzmUCWb1TA052qUsn0fMLZMCgWmPxlKM(enjSJlFQ4aYXcZs0attevqtIgCCKv9coihlmdmW)3eb8dCCKv9coqJzL0WEm4WRpv8aqmWa)F)uGFGdV(uXdaXGdcxgJlhCmxXRfmgtcLTwYBKhXK8AbE9PIhGJJSQxWjRJJ7Ebg4)BHe4h4WRpv8aqm44iR6fCGmoMxtcTAJaheUmgxo4GznMHz9PIPPx008Q1bRILTwAzzjmMDCaAoIaA6lnjkWbLbsXsZXrSbb)FdmW)3efWpWHxFQ4bGyWXrw1l4q2Bu3qwolJbhugiflnhhXge8)nWa)FNja)ahE9PIhaIbhhzvVGd2JTglHgUiGbhugiflnhhXge8)nWag4anWpW)3GFGdV(uXdaXGdcxgJlhCmxXRfmgtcLTwYBKhXK8AbE9PIhGJJSQxWjRJJ7Ebg4VOb)ahE9PIhaIbheUmgxo4OB0fst5PjKdnjMJ4LM(st6gDHbs)zWXrw1l4Ov(sqTrsOHlcyGb(lkWpWHxFQ4bGyWbHlJXLdoZRwhqDJh16gpKoe6xLfUX00lAIOPP5vRdOUXJADJhshc9RYcyM0RfstFPP3bIqtpHMIqdAsSyAAE16WuDXYwlnx1lmCJPPx008Q1HP6ILTwAUQxyaZKETqA6ln9oqeA6j0ueAqtcb44iR6fCWES1yj0WfbmWa)ZCWpWHxFQ4bGyWbHlJXLdoZRwhqDJh16gpKoe6xLfUX00lAIOPP5vRdOUXJADJhshc9RYcyM0RfstFPP3bIqtpHMIqdAsSyAAE16WuDXYwlnx1lmCJPPx008Q1HP6ILTwAUQxyaZKETqA6ln9oqeA6j0ueAqtcb44iR6fCi7nQBilNLXad8NiGFGdV(uXdaXGJJSQxWHGsPKOMK03b4GWLX4YbhDJUqAkpnHCOjXCeV00xAs3Olmq6pdoOmqkwAooIni4)BGb()uGFGdV(uXdaXGdcxgJlhC0n6cPP80eYHMeZr8stFPjDJUWaP)m44iR6fCGgZkPH9yGb(lKa)ahE9PIhaIbheUmgxo4OB0fst5PjKdnjMJ4LM(st6gDHbs)zA6fn9bnzfIGAJOPx00h008Q1bsMSXziBTuDr1qoWStcd3yA6fnr00K(QusmJY64iwAfjttFPP3bIqtpHMIqdAsSyA6dAA0wixPg6cZYztodwHiO2iA6fn9bnnVADa1nEuRB8q6qOFvw4gttIfttFqtJ2c5k1qxywoBYzWkeb1grtVOP5vRdK9g1nKL6loJa0Ceb00xA6nnje0KyX0KvKS0A5OyA6ln9MOqtVOPpOPrBHCLAOlmlNn5myfIGAJahhzvVGtUsn0fMLZMCcmWFIc4h4WRpv8aqm4GWLX4YbN5vRdcxXmgkfM3MmCJPPx00OTaKXX8AsOvBuaZKETqA6lnL500tOPi0GMelMMgTfGmoMxtcTAJcywJzywFQyA6fn9bnnVADa1nEuRB8q6qOFvw4gdooYQEbhiJJ51KqR2iGb(Nja)ahE9PIhaIbheUmgxo48bnnVADa1nEuRB8q6qOFvw4gdooYQEbhxsEXdglBTeH7CqGb()wOGFGdV(uXdaXGdcxgJlhC(GMMxToG6gpQ1nEiDi0VklCJbhhzvVGdQB8Ow34H0Hq)QmGb()(n4h4WRpv8aqm4GWLX4YbN5vRdK9g1nKL6loJWnMMelMM0n6cPP80eYHMeZr8stFIM0n6cdK(Z0uMrtIwO00lAYCfVwq4kMXqPW82KbE9PIh0KyX0KUrxinLNMqo0KyoIxA6t0KUrxyG0FMMYmA6nn9IMmxXRfmgtcLTwYBKhXK8AbE9PIh0KyX008Q1bu34rTUXdPdH(vzHBm44iR6fCi7nQBilNLXad8)TOb)ahhzvVGd2JTglHgUiGbhE9PIhaIbg4)Brb(bo86tfpaedoiCzmUCWz0wixPg6cZYztodywJzywFQyWXrw1l4KRudDHz5SjNad8)DMd(bo86tfpaedoiCzmUCWzE16GWvmJHsH5Tjd3yWXrw1l4azCmVMeA1gbmGbo50f4h4)BWpWHxFQ4bGyWbHlJXLdo6gDH0uEAc5qtI5iEPPV0KUrxyG0FMMErtMR41cgJjHYwl5nYJysETaV(uXdWXrw1l4K1XXDVad8x0GFGdV(uXdaXGdcxgJlhCMxTomvxSS1sZv9cd3yA6fnnVADyQUyzRLMR6fgWmPxlKM(strOb44iR6fCi7nQBilNLXad8xuGFGdV(uXdaXGdcxgJlhCMxTomvxSS1sZv9cd3yA6fnnVADyQUyzRLMR6fgWmPxlKM(strOb44iR6fCWES1yj0WfbmWa)ZCWpWHxFQ4bGyWbHlJXLdoZRwheUIzmukmVnz4gttVOP5vRdcxXmgkfM3MmGzsVwin9LMEhicn9eAkcnOjXIPPpOPrBbiJJ51KqR2OGvicQncCCKv9coqghZRjHwTrad8NiGFGdV(uXdaXGdcxgJlhC0xLsIzuwhhXsRizA6ln9oqeA6j0ueAqtVOjDJUqAkpnHCOjXCeV00xAs3Olmq6pttIfttennT8ZMmxjNn5miCRCRumn9IMgTfGmoMxtcTAJcwHiO2iA6fnnAlazCmVMeA1gfWSgZWS(uX0KyX00YpBYCLC2KZqCwg3K9Y00lA6dAAE16azVrDdzP(IZiCJPPx0KUrxinLNMqo0KyoIxA6lnPB0fgi9NPPmJMCKv9giOukjQjj9Deqo0KyoIxA6j0KOOjHaCCKv9co5k1qxywoBYjWa)FkWpWHxFQ4bGyWbHlJXLdo6gDH0uEAc5qtI5iEPPV0KUrxyG0FMMYmAs3OlmG5iEbhhzvVGdbLsjrnjPVdGb(lKa)ahhzvVGJljV4bJLTwIWDoi4WRpv8aqmWa)jkGFGdV(uXdaXGdcxgJlhC0n6cPP80eYHMeZr8stFPjDJUWaP)m44iR6fCGgZkPH9yGb(Nja)ahE9PIhaIbheUmgxo4OVkLeZOSooILwrY00xA6DGi00tOPi0aCCKv9co5k1qxywoBYjWa)FluWpWXrw1l4G6gpQ1nEiDi0VkdC41NkEaigyG)VFd(bo86tfpaedoiCzmUCWzE16GWvmJHsH5Tjd3yA6fnnAlazCmVMeA1gfWmPxlKM(stzon9eAkcnahhzvVGdKXX8AsOvBeWa)FlAWpWHxFQ4bGyWbHlJXLdoJ2cWSypEzLC2KZGvicQnIMelMMMxToq2Bu3qwQV4mcqZreqtcOjIaooYQEbhYEJ6gYYzzmWa)FlkWpWHxFQ4bGyWbHlJXLdol)SjZvYztodWSypEzfn9IMgTfGmoMxtcTAJcyM0RfstFIMicn9eAkcnahhzvVGtUsn0fMLZMCcmW)3zo4h4WRpv8aqm4GWLX4YbhmRXmmRpvm44iR6fCGmoMxtcTAJag4)BIa(bo86tfpaedoiCzmUCW5dAAE16azVrDdzP(IZiGzsVwi44iR6fCqzDcWojeyG)VFkWpWXrw1l4q2Bu3qwolJbhE9PIhaIbg4)BHe4h44iR6fCWES1yj0Wfbm4WRpv8aqmWa)Ftua)ahE9PIhaIbheUmgxo4mVADq4kMXqPW82KHBm44iR6fCGmoMxtcTAJag4)7mb4h4WRpv8aqm4GWLX4YbNLF2K5k5SjNbHBLBLIPPx00OTaKXX8AsOvBuWkeb1grtIfttl)SjZvYztodXzzCt2lttIfttl)SjZvYztodWSypEzf44iR6fCYvQHUWSC2KtGbmWXJZPlWpW)3GFGdV(uXdaXGdcxgJlhCMxTomvxSS1sZv9cd3yA6fnnVADyQUyzRLMR6fgWmPxlKM(strOb44iR6fCi7nQBilNLXad8x0GFGdV(uXdaXGdcxgJlhCMxTomvxSS1sZv9cd3yA6fnnVADyQUyzRLMR6fgWmPxlKM(strOb44iR6fCWES1yj0WfbmWa)ff4h4WRpv8aqm4GWLX4YbNpOPrBbiJJ51KqR2OGvicQncCCKv9coqghZRjHwTrad8pZb)ahhzvVGJljV4bJLTwIWDoi4WRpv8aqmWa)jc4h4WRpv8aqm4GWLX4Ybh9vPKygL1XrS0ksMM(stVdeHMEcnfHg0KyX0KUrxinLNMqo0KyoIxA6lnPB0fgi9NPPx0erttl)SjZvYztodc3k3kfttVOPrBbiJJ51KqR2OGvicQnIMErtJ2cqghZRjHwTrbmRXmmRpvmnjwmnT8ZMmxjNn5meNLXnzVmn9IM(GMMxToq2Bu3qwQV4mc3yA6fnPB0fst5PjKdnjMJ4LM(st6gDHbs)zAkZOjhzvVbckLsIAssFhbKdnjMJ4LMEcnjkAsiahhzvVGtUsn0fMLZMCcmW)Nc8dCCKv9coOUXJADJhshc9RYahE9PIhaIbg4Vqc8dC41NkEaigCq4YyC5GZ8Q1bYEJ6gYs9fNraZKETqA6fnT8ZMmxjNn5meNLXnzVm44iR6fCi7nQBilNLXad8NOa(bo86tfpaedoiCzmUCWrFvkjMrzDCelTIKPPV007arOPNqtrObn9IM0n6cPP80eYHMeZr8stFPjDJUWaP)mnLz0KOfk44iR6fCiOukjQjj9DamW)mb4h4WRpv8aqm4GWLX4YbhDJUqAkpnHCOjXCeV00xAs3Olmq6pdooYQEbhOXSsAypgyG)Vfk4h4WRpv8aqm4GWLX4YbN5vRdwflBT0YYsym74a0Ceb0KaAsu0KyX00OTaml2JxwjNn5myfIGAJahhzvVGd2JTglHgUiGbg4)73GFGdV(uXdaXGdcxgJlhCgTfGzXE8Yk5SjNbRqeuBe44iR6fCi7nQBilNLXad8)TOb)ahE9PIhaIbheUmgxo4S8ZMmxjNn5maZI94Lv00lAs3OlKM(enjkHstVOPrBbiJJ51KqR2OaMj9AH00NOjIqtpHMIqdWXrw1l4KRudDHz5SjNad8)TOa)ahE9PIhaIbheUmgxo48bnnVADGS3OUHSuFXzeWmPxleCCKv9coOSobyNecmW)3zo4h4WRpv8aqm4GWLX4YbhmRXmmRpvm44iR6fCGmoMxtcTAJag4)BIa(bo86tfpaedoiCzmUCWr3OlKMYttihAsmhXln9LM0n6cdK(Z00lAIOPP5vRdK9g1nKL6loJa0Ceb00xAIi0KyX0KUrxin9LMCKv9gi7nQBilNLXbudnAsiahhzvVGdbLsjrnjPVdGb()(Pa)ahhzvVGd2JTglHgUiGbhE9PIhaIbg4)BHe4h4WRpv8aqm4GWLX4YbN5vRdK9g1nKL6loJWnMMelMM0n6cPPprtzUqPjXIPPrBbywShVSsoBYzWkeb1gbooYQEbhYEJ6gYYzzmWa)Ftua)ahE9PIhaIbheUmgxo4S8ZMmxjNn5miCRCRumn9IMgTfGmoMxtcTAJcwHiO2iAsSyAA5NnzUsoBYziolJBYEzAsSyAA5NnzUsoBYzaMf7XlROPx0KUrxin9jAIicfCCKv9co5k1qxywoBYjWag4eJzutoDd8d8)n4h44iR6fCGxsYELXSbo86tfpaedmWFrd(bo86tfpaedoRtYGJ)zywh7qPUxt2AzCNJXGJJSQxWX)mmRJDOu3RjBTmUZXyGb(lkWpWXrw1l4eDD8O8v2AP)zg3wwWHxFQ4bGyGb(N5GFGJJSQxWjUTQxWHxFQ4bGyGb(teWpWHxFQ4bGyWXrw1l4GYaPAd3BHKtLdnWbHlJXLdoFqtyVgswyETqTcFvlJ9PId8Zf0GGdR1mYKRtYGdkdKQnCVfsovo0ag4)tb(booYQEbhOXSsAypgC41NkEaigyG)cjWpWXrw1l4K1XXDVGdV(uXdaXadyGdAab)a)Fd(bo86tfpaedoiCzmUCWb1TA052aQB8Ow34H0Hq)QSaMj9AH00NOjrjuWXrw1l4mvDpK6lodGb(lAWpWHxFQ4bGyWbHlJXLdoOUvJo3gqDJh16gpKoe6xLfWmPxlKM(enjkHcooYQEbhFrm0WUsICLcyG)Ic8dC41NkEaigCq4YyC5GdQB1OZTbu34rTUXdPdH(vzbmt61cPPprtIsOGJJSQxWrxyEQ6EamW)mh8dCCKv9coQkkRbLcz3rejVg4WRpv8aqmWa)jc4h4WRpv8aqm4GWLX4Ybhu3QrNBdOUXJADJhshc9RYcyM0RfstFIMEkHstIfttwrYsRLJIPPV00BrbooYQEbNjJHmMGAJag4)tb(bo86tfpaedoiCzmUCWzE16q01XJYxzRL(NzCBzd3yA6fnr0008Q1HjJHmMGAJc3yAsSyAAE16Wu19qQV4mc3yAsSyA6dAc7ioy4wPOjHGMelMMiAAc1l8s6tfhIBR6v2A5DN4AO4HuFXzqtVOjRizP1YrX00xA6PEttIfttwrYsRLJIPPV0KOFkAsiOjXIPPpOjgc5fXbuVdEH8qQknRBmIdKUqwJPPx008Q1bu34rTUXdPdH(vzHBm44iR6fCIBR6fyG)cjWpWHxFQ4bGyWbHlJXLdoMJJylmkO5lIPPpjGMEkWXrw1l44WygzYwlTSSK9ifdmWFIc4h4WRpv8aqm44iR6fCCywH9LHsS)5glrn2vGdcxgJlhCyH8BfhZJWaxZPQ2izTee3dA6fnr000GNxToG9p3yjQXUso45vRdJo3stIfttwrYsRLXitkkHstFPP30KyX0erttzzxzzdXiJM(stIsO00lAAE16q01XJYxzRL(NzCBzd3yAsSyAAE16ajt24mKTwQUOAihy2jHHBmnje0KqqtIfttenn9bnXc53koMhHbUMtvTrYAjiUh00lAIOPP5vRdKmzJZq2AP6IQHCGzNegUX0KyX008Q1HORJhLVYwl9pZ42YgUX00lAc1TA052q01XJYxzRL(NzCBzdyM0RfstFIMElKicnje0KyX00GNxToG9p3yjQXUso45vRdJo3stcbnjwmnzfjlTwokMM(stIwOGZ6Km44WSc7ldLy)ZnwIASRag4FMa8dC41NkEaigCCKv9corUIrUsXyOC29coiCzmUCWb1TA052ajt24mKTwQUOAihy2jHbmt61cPjXIPjZv8AHCLAOlmlRvFHvVbE9PIh00lAc1TA052aQB8Ow34H0Hq)QSaMj9AH0KyX0eQB1OZTbugivB4ElKCQCOfWmPxlKMelMM(GMyiKxehizYgNHS1s1fvd5aZojmq6cznMMErtOUvJo3gqDJh16gpKoe6xLfWmPxleCwNKbNixXixPymuo7Ebg4)BHc(bo86tfpaedoRtYGJ)zywh7qPUxt2AzCNJXGJJSQxWX)mmRJDOu3RjBTmUZXyGb()(n4h44iR6fC0n6c5H0)mJlJLt2jbhE9PIhaIbg4)Brd(bo86tfpaedoiCzmUCWzE16aQB8Ow34H0Hq)QSWngCCKv9cotv3dzRLwwwYltMbWa)FlkWpWXrw1l4eFXLoJAJKtLdnWHxFQ4bGyGb()oZb)ahhzvVGt01XJYxzRL(NzCBzbhE9PIhaIbg4)BIa(booYQEbhCfhRyzTsySJyWHxFQ4bGyGb()(Pa)ahE9PIhaIbheUmgxo4OVkLeZOSooILwrY00xA6nn9eAkcnahhzvVGdQxeVg2nEi1kNKbg4)BHe4h4WRpv8aqm4GWLX4YbN5vRdygrGIHqPUXioCJbhhzvVGJLLL3D23Di1ngXad8)nrb8dCCKv9co5ASAimxReZWE9fXGdV(uXdaXad8)DMa8dC41NkEaigCq4YyC5GJ54i2czzxzzdXiJM(enrueknjwmnzooITqw2vw2qmYOPVcOjrluAsSyAYCCeBbRizP1YyKjfTqPPprtIsOGJJSQxWbZECTrsTYjziWa)fTqb)ahE9PIhaIbheUmgxo4OB0fstFPjhzvVbYEJ6gYYzzCa1qJMErtZRwhqDJh16gpKoe6xLfUXGJJSQxWHKjBCgYwlvxunKdm7KqGbmWzWA)QmWpW)3GFGdV(uXdaXGdcxgJlhCg88Q1bKdTAJc3yAsSyAAE16WOGXSs5tflj9OcfUX0KyX008Q1HrbJzLYNkwYl2J4WngCCKv9coixPKoYQELQcAGJQGMCDsgCUwPkldGb(lAWpWXrw1l4CHSSmMeco86tfpaedmWFrb(bo86tfpaedooYQEbhKRushzvVsvbnWrvqtUojdoObeyG)zo4h4WRpv8aqm4GWLX4YbhhzLWSKxMSyinjGMEttVOjIMMmxXRfCvCwxgJ5HBnoWRpv8GMErtwrYsRLJIPPV00BHstIfttwrYsRLJIPPV0erOjHaCCKv9coK9g1nKLZYyGb(teWpWHxFQ4bGyWbHlJXLdooYkHzjVmzXqA6lnjkA6fnzUIxlGY6eGDsyGxFQ4bn9IMmxXRfCvCwxgJ5HBnoWRpv8aCCKv9coixPKoYQELQcAGJQGMCDsgC84C6cyG)pf4h4WRpv8aqm4GWLX4YbhhzLWSKxMSyin9LMefn9IMmxXRfqzDcWojmWRpv8aCCKv9coixPKoYQELQcAGJQGMCDsgCYPlGb(lKa)ahE9PIhaIbheUmgxo44iReML8YKfdPPV0KOOPx00h0K5kETGRIZ6YympCRXbE9PIh00lA6dAYCfVwixPg6cZYA1xy1BGxFQ4b44iR6fCqUsjDKv9kvf0ahvbn56Km4anGb(tua)ahE9PIhaIbheUmgxo44iReML8YKfdPPV0KOOPx0K5kETGRIZ6YympCRXbE9PIh00lA6dAYCfVwixPg6cZYA1xy1BGxFQ4b44iR6fCqUsjDKv9kvf0ahvbn56Km44XqdyG)zcWpWHxFQ4bGyWbHlJXLdooYkHzjVmzXqA6lnjkA6fnzUIxl4Q4SUmgZd3ACGxFQ4bn9IMmxXRfYvQHUWSSw9fw9g41NkEaooYQEbhKRushzvVsvbnWrvqtUojdoECoDbmW)3cf8dC41NkEaigCq4YyC5GJJSsywYltwmKM(stIIMErtFqtMR41cUkoRlJX8WTgh41NkEqtVOjZv8AHCLAOlmlRvFHvVbE9PIhGJJSQxWb5kL0rw1RuvqdCuf0KRtYGtoDbmW)3Vb)ahE9PIhaIbheUmgxo44iReML8YKfdPPprtVPPx00h0K5kETWSWdOS1YymNrGxFQ4bnjwmn5iReML8YKfdPPprtIgCCKv9coixPKoYQELQcAGJQGMCDsgCqk2fMbg4)Brd(booYQEbhuViEnSB8qQvojdo86tfpaedmW)3Ic8dCCKv9coog5llTgJ51ahE9PIhaIbg4)7mh8dCCKv9cotps2APHlebqWHxFQ4bGyGbmW5ALQSma)a)Fd(booYQEbhY7N)SIbhE9PIhaIbg4VOb)ahhzvVGdKX8wwgYXfAGdV(uXdaXad8xuGFGJJSQxWbg3ywIu9Dao86tfpaedmW)mh8dCCKv9coWUTS1gjZ5gJbhE9PIhaIbg4pra)ahhzvVGdS3cjNkhAGdV(uXdaXad8)Pa)ahhzvVGZYwwglHzBebGdV(uXdaXad8xib(booYQEbhu2siRGsd7Rq(TuLLb4WRpv8aqmWa)jkGFGJJSQxWbgx4YKWSnIaWHxFQ4bGyGb(Nja)ahhzvVGZ62fZqze2rm4WRpv8aqmWagWahHzmS6f8x0cv0cvOVfDMdo5C8wBeeCiQKmUXgpOPmbn5iR6LMuf0Gb6dWbgZiWFrteIaoX4wxkgCYuA6CXcxc7kA6P1DngtFKP0uwZIHpnesyuzzVZaQjjewKxLBvViSRncHfjIq6JmLMEAZt81XzqtIw0IqtIwOIwO0h0hzknLjN13ig(0qFKP0uMrtp9XGh0uM09ZFwX0K100G1(vz0KJSQxAsvqlqFKP0uMrtzYz9nIh0K54i2KLMM4NJXmew9cPjRPjugiflnhhXgmqFKP0uMrtzs9O0fpOjKJfMLObMMSMMY1ycOjYgZ0e7WsLbnLRSS0KLLPjFm6LOkinvKXkMKxZTQxAQ10KWoU8PId0hzknLz00tFm4bnDTsvwg00tNOgIQd0h0hzknru)zgDnEqttw3yMMqn50nAAYr1cd00thH4ydstBVzwwhtQVkAYrw1lKM6vLrG(itPjhzvVWqmMrn50nbALdjG(itPjhzvVWqmMrn50T8ci0VrK8AUv9sFKP0KJSQxyigZOMC6wEbeQ7EqF4iR6fgIXmQjNULxaHWljzVYy2OpYuA6SEmmBB0e2RbnnVAnpOjO5gKMMSUXmnHAYPB00KJQfst(oOPymNzXTz1grtfKMg9Yb6JmLMCKv9cdXyg1Kt3YlGq46XWSTjHMBq6dhzvVWqmMrn50T8ci8czzzmPiRtYc8pdZ6yhk19AYwlJ7CmM(Wrw1lmeJzutoDlVacJUoEu(kBT0)mJBll9HJSQxyigZOMC6wEbeg3w1l9HJSQxyigZOMC6wEbeEHSSmMuewRzKjxNKfGYaPAd3BHKtLdnrkTGpWEnKSW8AHAf(Qwg7tfh4NlObPpCKv9cdXyg1Kt3YlGqOXSsAypM(Wrw1lmeJzutoDlVacZ644Ux6d6dhzvVWW1kvzziG8(5pRy6dhzvVWW1kvzzKxaHqgZBzzihxOrF4iR6fgUwPklJ8cieg3ywIu9DqF4iR6fgUwPklJ8cie2TLT2izo3ym9HJSQxy4ALQSmYlGqyVfsovo0OpCKv9cdxRuLLrEbeUSLLXsy2gra9HJSQxy4ALQSmYlGqu2siRGsd7Rq(TuLLb9HJSQxy4ALQSmYlGqyCHltcZ2icOpCKv9cdxRuLLrEbeUUDXmugHDetFqFKP0er9Nz014bnXcZ4mOjRizAYYY0KJSgttfKMCH9s5tfhOpCKv9cfGCLs6iR6vQkOjY6KSGRvQYYqKslyWZRwhqo0QnkCJflEE16WOGXSs5tflj9OcfUXIfpVADyuWywP8PIL8I9ioCJPpCKv9cZlGWlKLLXKq6dhzvVW8cie5kL0rw1RuvqtK1jzbObK(Wrw1lmVacj7nQBilNLXIuAboYkHzjVmzXqbVFr0MR41cUkoRlJX8WTgh41NkE8YkswATCu833cvSyRizP1YrXFjIqqF4iR6fMxaHixPKoYQELQcAISojlWJZPlrkTahzLWSKxMSy4xr9YCfVwaL1ja7KWaV(uXJxMR41cUkoRlJX8WTgh41NkEqF4iR6fMxaHixPKoYQELQcAISojliNUeP0cCKvcZsEzYIHFf1lZv8AbuwNaStcd86tfpOpCKv9cZlGqKRushzvVsvbnrwNKfanrkTahzLWSKxMSy4xr96dZv8AbxfN1LXyE4wJd86tfpE9H5kETqUsn0fML1QVWQ3aV(uXd6dhzvVW8cie5kL0rw1RuvqtK1jzbEm0eP0cCKvcZsEzYIHFf1lZv8AbxfN1LXyE4wJd86tfpE9H5kETqUsn0fML1QVWQ3aV(uXd6dhzvVW8cie5kL0rw1RuvqtK1jzbECoDjsPf4iReML8YKfd)kQxMR41cUkoRlJX8WTgh41NkE8YCfVwixPg6cZYA1xy1BGxFQ4b9HJSQxyEbeICLs6iR6vQkOjY6KSGC6sKslWrwjml5Ljlg(vuV(WCfVwWvXzDzmMhU14aV(uXJxMR41c5k1qxywwR(cREd86tfpOpCKv9cZlGqKRushzvVsvbnrwNKfGuSlmlsPf4iReML8YKfd)07xFyUIxlml8akBTmgZze41NkEiwSJSsywYltwm8tIM(Wrw1lmVacr9I41WUXdPw5Km9HJSQxyEbe6yKVS0AmMxJ(Wrw1lmVacNEKS1sdxicG0h0hoYQEHbpgAci7nQBilNLXIuAbZRwhqDJh16gpKoe6xLfUXVi65vRdOUXJADJhshc9RYcyM0Rf(9DGipjcnelEE16WuDXYwlnx1lmCJFnVADyQUyzRLMR6fgWmPxl877arEseAie0hoYQEHbpgA5fqi2JTglHgUiGfP0cMxToG6gpQ1nEiDi0VklCJFr0ZRwhqDJh16gpKoe6xLfWmPxl877arEseAiw88Q1HP6ILTwAUQxy4g)AE16WuDXYwlnx1lmGzsVw433bI8Ki0qiOpCKv9cdEm0YlGqTYxcQnscnCralsPfOB0fMh5qtI5iE)QB0fgi9NPpCKv9cdEm0YlGqckLsIAssFhIGYaPyP54i2GcElsPfOVkLeZOSooILwrYFFhiYtIqJx6gDH5ro0KyoI3V6gDHbs)z6dhzvVWGhdT8cieAmRKg2JfP0c0n6cZJCOjXCeVF1n6cdK(Z0hoYQEHbpgA5fqyUsn0fMLZMCksPfOB0fMh5qtI5iE)QB0fgi9NF9HvicQn61hZRwhizYgNHS1s1fvd5aZojmCJFr06RsjXmkRJJyPvK833bI8Ki0qS4pgTfYvQHUWSC2KZGvicQn61hZRwhqDJh16gpKoe6xLfUXIf)XOTqUsn0fMLZMCgScrqTrVMxToq2Bu3qwQV4mcqZre89TqiwSvKS0A5O4VVjkV(y0wixPg6cZYztodwHiO2i6dhzvVWGhdT8cieY4yEnj0QnsKsl4JrBbiJJ51KqR2OGvicQn61hZRwhqDJh16gpKoe6xLfUX0hoYQEHbpgA5fqibLsjrnjPVdrqzGuS0CCeBqbVfP0c0n6cZJCOjXCeVF1n6cdK(ZVi65vRdK9g1nKL6loJa0CebFjIyX6gDHFDKv9gi7nQBilNLXbudnHG(Wrw1lm4XqlVacHmoMxtcTAJeP0cWSgZWS(uXV(yE16aQB8Ow34H0Hq)QSWn(18Q1bYEJ6gYs9fNraAoIGVeH(Wrw1lm4XqlVacDj5fpySS1seUZbfP0c(yE16aQB8Ow34H0Hq)QSWnM(Wrw1lm4XqlVacrDJh16gpKoe6xLjsPf8X8Q1bu34rTUXdPdH(vzHBm9HJSQxyWJHwEbes2Bu3qwolJfP0cMxToq2Bu3qwQV4mc3yXI1n6cZJCOjXCeVFs3Olmq6pNzVfQyXZRwhqDJh16gpKoe6xLfUX0hoYQEHbpgA5fqi2JTglHgUiGPpCKv9cdEm0YlGWCLAOlmlNn5uKsl4dRqeuBe9b9HJSQxyWJZPlbK9g1nKLZYyrkTG5vRdt1flBT0CvVWWn(18Q1HP6ILTwAUQxyaZKETWVrOb9HJSQxyWJZPR8cie7XwJLqdxeWIuAbZRwhMQlw2AP5QEHHB8R5vRdt1flBT0CvVWaMj9AHFJqd6dhzvVWGhNtx5fqiKXX8AsOvBKiLwWhJ2cqghZRjHwTrbRqeuBe9HJSQxyWJZPR8ci0LKx8GXYwlr4ohK(Wrw1lm4X50vEbeMRudDHz5SjNIuAb6RsjXmkRJJyPvK833bI8Ki0qSyDJUW8ihAsmhX7xDJUWaP)8lIE5NnzUsoBYzq4w5wP4xJ2cqghZRjHwTrbRqeuB0RrBbiJJ51KqR2OaM1ygM1NkwS4LF2K5k5SjNH4SmUj7LF9X8Q1bYEJ6gYs9fNr4g)s3OlmpYHMeZr8(v3Olmq6pNzoYQEdeukLe1KK(ocihAsmhX7teLqqF4iR6fg84C6kVacrDJh16gpKoe6xLrF4iR6fg84C6kVacj7nQBilNLXIuAbZRwhi7nQBil1xCgbmt61cFT8ZMmxjNn5meNLXnzVm9HJSQxyWJZPR8ciKGsPKOMK03HiLwG(QusmJY64iwAfj)9DGipjcnEPB0fMh5qtI5iE)QB0fgi9NZmrlu6dhzvVWGhNtx5fqi0ywjnShlsPfOB0fMh5qtI5iE)QB0fgi9NPpCKv9cdECoDLxaHyp2ASeA4IawKslyE16GvXYwlTSSegZooanhrGarjw8OTaml2JxwjNn5myfIGAJOpCKv9cdECoDLxaHK9g1nKLZYyrkTGrBbywShVSsoBYzWkeb1grF4iR6fg84C6kVacZvQHUWSC2KtrkTGLF2K5k5SjNbywShVS6LUrx4NeLqFnAlazCmVMeA1gfWmPxl8te5jrOb9HJSQxyWJZPR8cieL1ja7KqrkTGpMxToq2Bu3qwQV4mcyM0RfsF4iR6fg84C6kVacHmoMxtcTAJeP0cWSgZWS(uX0hoYQEHbpoNUYlGqckLsIAssFhIuAb6gDH5ro0KyoI3V6gDHbs)5xe98Q1bYEJ6gYs9fNraAoIGVerSyDJUWVoYQEdK9g1nKLZY4aQHMqqF4iR6fg84C6kVacXES1yj0Wfbm9HJSQxyWJZPR8ciKS3OUHSCwglsPfmVADGS3OUHSuFXzeUXIfRB0f(PmxOIfpAlaZI94LvYztodwHiO2i6dhzvVWGhNtx5fqyUsn0fMLZMCksPfS8ZMmxjNn5miCRCRu8RrBbiJJ51KqR2OGvicQnsS4LF2K5k5SjNH4SmUj7LflE5NnzUsoBYzaMf7XlREPB0f(jIiu6d6dhzvVWaAafmvDpK6lodrkTau3QrNBdOUXJADJhshc9RYcyM0Rf(jrju6dhzvVWaAaZlGqFrm0WUsICLsKsla1TA052aQB8Ow34H0Hq)QSaMj9AHFsucL(Wrw1lmGgW8ciuxyEQ6EisPfG6wn6CBa1nEuRB8q6qOFvwaZKETWpjkHsF4iR6fgqdyEbeQQOSgukKDhrK8A0hoYQEHb0aMxaHtgdzmb1gjsPfG6wn6CBa1nEuRB8q6qOFvwaZKETWp9ucvSyRizP1YrXFFlk6dhzvVWaAaZlGW42QEfP0cMxToeDD8O8v2AP)zg3w2Wn(frpVADyYyiJjO2OWnwS45vRdtv3dP(IZiCJfl(dSJ4GHBLsielMOr9cVK(uXH42QELTwE3jUgkEi1xCgVSIKLwlhf)9PElwSvKS0A5O4VI(PecXI)GHqErCa17GxipKQsZ6gJ4aPlK14xZRwhqDJh16gpKoe6xLfUX0hoYQEHb0aMxaHomMrMS1slllzpsXIuAbMJJylmkO5lI)KGNI(Wrw1lmGgW8ci8czzzmPiRtYcCywH9LHsS)5glrn2vIuAbSq(TIJ5ryGR5uvBKSwcI7XlIEWZRwhW(NBSe1yxjh88Q1HrNBfl2kswATmgzsrj0VVflMOZYUYYgIr2xrj0xZRwhIUoEu(kBT0)mJBlB4glw88Q1bsMSXziBTuDr1qoWStcd3yHqielMO)GfYVvCmpcdCnNQAJK1sqCpEr0ZRwhizYgNHS1s1fvd5aZojmCJflEE16q01XJYxzRL(NzCBzd34xOUvJo3gIUoEu(kBT0)mJBlBaZKETWp9wireHqS4bpVADa7FUXsuJDLCWZRwhgDUviel2kswATCu8xrlu6dhzvVWaAaZlGWlKLLXKISojliYvmYvkgdLZUxrkTau3QrNBdKmzJZq2AP6IQHCGzNegWmPxluSyZv8AHCLAOlmlRvFHvVbE9PIhVqDRgDUnG6gpQ1nEiDi0VklGzsVwOyXOUvJo3gqzGuTH7TqYPYHwaZKETqXI)GHqErCGKjBCgYwlvxunKdm7KWaPlK14xOUvJo3gqDJh16gpKoe6xLfWmPxlK(Wrw1lmGgW8ci8czzzmPiRtYc8pdZ6yhk19AYwlJ7CmM(Wrw1lmGgW8ciu3OlKhs)ZmUmwozNK(Wrw1lmGgW8ciCQ6EiBT0YYsEzYmeP0cMxToG6gpQ1nEiDi0VklCJPpCKv9cdObmVacJV4sNrTrYPYHg9HJSQxyanG5fqy01XJYxzRL(NzCBzPpCKv9cdObmVacXvCSIL1kHXoIPpCKv9cdObmVacr9I41WUXdPw5KSiLwG(QusmJY64iwAfj)99tIqd6dhzvVWaAaZlGqlllV7SV7qQBmIfP0cMxToGzebkgcL6gJ4WnM(Wrw1lmGgW8cimxJvdH5ALyg2RViM(Wrw1lmGgW8cieZECTrsTYjzOiLwG54i2czzxzzdXi7tefHkwS54i2czzxzzdXi7RarluXInhhXwWkswATmgzsrl0pjkHsF4iR6fgqdyEbesYKnodzRLQlQgYbMDsOiLwGUrx4xhzvVbYEJ6gYYzzCa1q718Q1bu34rTUXdPdH(vzHBm9b9HJSQxyaPyxywGWoU8PIfzDswaYXcZs0alshlaYwPfryxDzboYkHzjVmzXqre2vxwYkilGiIG6Duw1RahzLWSKxMSy4xIqF4iR6fgqk2fMZlGqxsEXdglBTeH7Cq6dhzvVWasXUWCEbeI6gpQ1nEiDi0VkJ(Wrw1lmGuSlmNxaHihlmlsPfmAlaZI94LvYztodwHiO2i6dhzvVWasXUWCEbeMRudDHz5SjNIuAbFyUIxleDzmUukxAoYkemWRpv8qSy9vPKygL1XrS0ks(BeAqF4iR6fgqk2fMZlGqYEJ6gYYzzSiOmqkwAooInOG3IuAbdEE16GYnEnzCxWEdqZrei4TqPpCKv9cdif7cZ5fqikRta2jH0hoYQEHbKIDH58ciKGsPKOMK03HiOmqkwAooInOG3IuAb6gDH5ro0KyoI3V6gDHbs)z6dhzvVWasXUWCEbeoVgklJZqKslqFvkjMrzDCelTIK)gHgIf)H5kETqUsn0fML1QVWQ3aV(uXdXIhTfGzXE8Yk5SjNbRqeuB0RrBHAngVUsovmpQnkanhrWxrrF4iR6fgqk2fMZlGqKJfMfP0cmxXRfIUmgxkLlnhzfcg41NkEqF4iR6fgqk2fMZlGqTYxcQnscnCralsPfOB0fMh5qtI5iE)QB0fgi9NPpCKv9cdif7cZ5fqyUsn0fMLZMCksPfmAlKRudDHz5SjNbmRXmmRpvSyXMR41c5k1qxywwR(cREd86tfpOpCKv9cdif7cZ5fqiKXX8AsOvBKiOmqkwAooInOG3IuAbZRwheUIzmukmVnzaZoYOpCKv9cdif7cZ5fqiYXcZIuAbOUvJo3gYvQHUWSC2KZaMj9AHFsyhx(uXbKJfMLObMOcrtF4iR6fgqk2fMZlGqOXSsAypM(Wrw1lmGuSlmNxaHzDCC3RiLwG5kETGXysOS1sEJ8iMKxlWRpv8G(Wrw1lmGuSlmNxaHqghZRjHwTrIGYaPyP54i2GcElsPfGznMHz9PIFnVADWQyzRLwwwcJzhhGMJi4ROOpYuA6xttWI8QCJPPl0JyAs3yAktQ3OUHmnrCzmn1yAIOwp2AmnDmCrattJlU2iA6PdJzKrtTMMSSmnru3JuSi0eQJZGMyhLLMAe6IX8IyAQ10KLLPjhzvV0KVdAYJJ5Dqts2JumnznnzzzAYrw1lnTojhOpCKv9cdif7cZ5fqizVrDdz5SmweugiflnhhXguWB6dhzvVWasXUWCEbeI9yRXsOHlcyrqzGuS0CCeBqbVPpOpCKv9cdqtqwhh39ksPfyUIxlymMekBTK3ipIj51c86tfpOpCKv9cdqlVac1kFjO2ij0WfbSiLwGUrxyEKdnjMJ49RUrxyG0FM(Wrw1lmaT8cie7XwJLqdxeWIuAbZRwhqDJh16gpKoe6xLfUXVi65vRdOUXJADJhshc9RYcyM0Rf(9DGipjcnelEE16WuDXYwlnx1lmCJFnVADyQUyzRLMR6fgWmPxl877arEseAie0hzkn9RPjyrEvUX00f6rmnPBmnLj1Bu3qMMiUmMMAmnruRhBnMMogUiGPPXfxBen90HXmYOPwttwwMMiQ7rkweAc1XzqtSJYstncDXyErmn1AAYYY0KJSQxAY3bn5XX8oOjj7rkMMSMMSSmn5iR6LMwNKd0hoYQEHbOLxaHK9g1nKLZYyrkTG5vRdOUXJADJhshc9RYc34xe98Q1bu34rTUXdPdH(vzbmt61c)(oqKNeHgIfpVADyQUyzRLMR6fgUXVMxTomvxSS1sZv9cdyM0Rf(9DGipjcnec6dhzvVWa0YlGqckLsIAssFhIGYaPyP54i2GcElsPfOB0fMh5qtI5iE)QB0fgi9NPpCKv9cdqlVacHgZkPH9yrkTaDJUW8ihAsmhX7xDJUWaP)m9HJSQxyaA5fqyUsn0fMLZMCksPfOB0fMh5qtI5iE)QB0fgi9NF9HvicQn61hZRwhizYgNHS1s1fvd5aZojmCJFr06RsjXmkRJJyPvK833bI8Ki0qS4pgTfYvQHUWSC2KZGvicQn61hZRwhqDJh16gpKoe6xLfUXIf)XOTqUsn0fMLZMCgScrqTrVMxToq2Bu3qwQV4mcqZre89TqiwSvKS0A5O4VVjkV(y0wixPg6cZYztodwHiO2i6dhzvVWa0YlGqiJJ51KqR2irkTG5vRdcxXmgkfM3MmCJFnAlazCmVMeA1gfWmPxl8BM)Ki0qS4rBbiJJ51KqR2OaM1ygM1Nk(1hZRwhqDJh16gpKoe6xLfUX0hoYQEHbOLxaHUK8Ihmw2Ajc35GIuAbFmVADa1nEuRB8q6qOFvw4gtF4iR6fgGwEbeI6gpQ1nEiDi0VktKsl4J5vRdOUXJADJhshc9RYc3y6dhzvVWa0YlGqYEJ6gYYzzSiLwW8Q1bYEJ6gYs9fNr4glwSUrxyEKdnjMJ49t6gDHbs)5mt0c9L5kETGWvmJHsH5Tjd86tfpelw3OlmpYHMeZr8(jDJUWaP)CM9(L5kETGXysOS1sEJ8iMKxlWRpv8qS45vRdOUXJADJhshc9RYc3y6dhzvVWa0YlGqShBnwcnCratF4iR6fgGwEbeMRudDHz5SjNIuAbJ2c5k1qxywoBYzaZAmdZ6tftF4iR6fgGwEbeczCmVMeA1gjsPfmVADq4kMXqPW82KHBm9b9HJSQxyiNUeK1XXDVIuAb6gDH5ro0KyoI3V6gDHbs)5xMR41cgJjHYwl5nYJysETaV(uXd6dhzvVWqoDLxaHK9g1nKLZYyrkTG5vRdt1flBT0CvVWWn(18Q1HP6ILTwAUQxyaZKETWVrOb9HJSQxyiNUYlGqShBnwcnCralsPfmVADyQUyzRLMR6fgUXVMxTomvxSS1sZv9cdyM0Rf(ncnOpCKv9cd50vEbeczCmVMeA1gjsPfmVADq4kMXqPW82KHB8R5vRdcxXmgkfM3MmGzsVw433bI8Ki0qS4pgTfGmoMxtcTAJcwHiO2i6dhzvVWqoDLxaH5k1qxywoBYPiLwG(QusmJY64iwAfj)9DGipjcnEPB0fMh5qtI5iE)QB0fgi9NflMOx(ztMRKZMCgeUvUvk(1OTaKXX8AsOvBuWkeb1g9A0waY4yEnj0QnkGznMHz9PIflE5NnzUsoBYziolJBYE5xFmVADGS3OUHSuFXzeUXV0n6cZJCOjXCeVF1n6cdK(ZzMJSQ3abLsjrnjPVJaYHMeZr8(erje0hoYQEHHC6kVacjOukjQjj9DisPfOB0fMh5qtI5iE)QB0fgi9NZmDJUWaMJ4L(Wrw1lmKtx5fqOljV4bJLTwIWDoi9HJSQxyiNUYlGqOXSsAypwKslq3OlmpYHMeZr8(v3Olmq6ptF4iR6fgYPR8cimxPg6cZYztofP0c0xLsIzuwhhXsRi5VVde5jrOb9HJSQxyiNUYlGqu34rTUXdPdH(vz0hoYQEHHC6kVacHmoMxtcTAJeP0cMxToiCfZyOuyEBYWn(1OTaKXX8AsOvBuaZKETWVz(tIqd6dhzvVWqoDLxaHK9g1nKLZYyrkTGrBbywShVSsoBYzWkeb1gjw88Q1bYEJ6gYs9fNraAoIabeH(Wrw1lmKtx5fqyUsn0fMLZMCksPfS8ZMmxjNn5maZI94LvVgTfGmoMxtcTAJcyM0Rf(jI8Ki0G(Wrw1lmKtx5fqiKXX8AsOvBKiLwaM1ygM1NkM(Wrw1lmKtx5fqikRta2jHIuAbFmVADGS3OUHSuFXzeWmPxlK(Wrw1lmKtx5fqizVrDdz5SmM(Wrw1lmKtx5fqi2JTglHgUiGPpCKv9cd50vEbeczCmVMeA1gjsPfmVADq4kMXqPW82KHBm9HJSQxyiNUYlGWCLAOlmlNn5uKsly5NnzUsoBYzq4w5wP4xJ2cqghZRjHwTrbRqeuBKyXl)SjZvYztodXzzCt2llw8YpBYCLC2KZaml2JxwbmGba]] )


end