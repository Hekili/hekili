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

    spec:RegisterPack( "Survival", 20200425, [[dC0uYbqivIEKkbUKci0MuO(Kkvk1OGq5uqOAvkq9kvsZIi1Tua1Ui5xqsdJOOJbbltbYZuaMMkbDniKTPsL8nIczCQurNJOqTovQumpiQ7re7tLqhuLk0cjsEOkvqxubemsvQuYjvPsfRuLYmvPsLUPkvGDcjgQkvQYsvPsv9uvzQqK9c8xcdMshwyXQ4XqnzrDzuBMuFweJwHCAjRwbKEnKYSP42QQDR0VLA4I0XvarlhXZbnDQUUI2oKQVRGgVkvDEIsRNOG5tuTFKgGaajWlhodqzqYCqYuMx4GqKsM3jIgacda8CztzWlnWOfjm4TXNbV3KGEHEyaV0qwthzasGhSNemdEJCpfE3GkQjLpAEu4(JkS(tt4vVysODuH1hJk4DMLXV7SGd4LdNbOmizoizkZlCqisjZ7erdqM3j4ftFutaVx9NMWREVdjH2bVrvoZl4aEzgIbVlGAFtc6f6HHAVBnxNj0Bxa1oY9u4DdQOMu(O5rH7pQW6pnHx9IjH2rfwFmQ0Bxa1EhtjLHAheIKMAhKmhKmP3O3UaQ9oCuSjm8UHE7cO2bMAVJ5mNP27GPmidgMA9MAZSoMgNAdSx9sTMc6k6TlGAhyQ9oCuSjCMA9GKWUO0ulFFkHHWQxi16n1ILfByHhKe2Hk6TlGAhyQ9oOZLU4m1Idc6SaNjuR3u7WMGg1(BctTCalJSu7WYhrT(iMAJCU372qQT(Pg(ZRhE1l12AQf9GuXXWk6TlGAhyQ9oMZCMANEzkxwQ9oE37URc8mf0HaKaVif6aKaOGaajWJ34y4mqkWdtkNjvaENPwRWDtY1goNfbegtJRMPu7yQfXO2ZuRv4Uj5AdNZIacJPXve(h1cPwKPweuiIAhm1MGZuRC5u7zQ1QJzseTw4HPxOAMsTJP2ZuRvhZKiATWdtVqfH)rTqQfzQfbfIO2btTj4m1I4GxG9QxW73Bs3qwCkNboaLbbqc84nogodKc8WKYzsfG3zQ1kC3KCTHZzraHX04Qzk1oMArmQ9m1AfUBsU2W5SiGWyACfH)rTqQfzQfbfIO2btTj4m1kxo1EMAT6yMerRfEy6fQMPu7yQ9m1A1XmjIwl8W0lur4FulKArMArqHiQDWuBcotTio4fyV6f8irQ3eb0jfAmWbOmaasGhVXXWzGuGhMuotQa80nEcP2RuloGUGWj8sTitT6gpHQFCp4fyV6f80MyrR2eb0jfAmWbOCHaKapEJJHZaPaVa7vVGhALXiW9)hBg8WKYzsfGNEAmccJhfKew41NPwKPweuiIAhm1MGZu7yQv34jKAVsT4a6ccNWl1Im1QB8eQ(X9GhwwSHfEqsyhcqbbGdqbraKapEJJHZaPapmPCMub4PB8esTxPwCaDbHt4LArMA1nEcv)4EWlWE1l4bDMncNePahGYDbqc84nogodKc8WKYzsfGNUXti1ELAXb0feoHxQfzQv34ju9J7P2Xu7LuRxy0QnHAhtTxsTNPwR(8VjYkATWmXvwKjC8HQzk1oMArmQvpngbHXJcscl86ZulYulckerTdMAtWzQvUCQ9sQn3UAyzY6IWIt)pkVWOvBc1oMAVKAptTwH7MKRnColcimMgxntPw5YP2lP2C7QHLjRlclo9)O8cJwTju7yQ9m1A1V3KUHSqpjYQGEGrJArMArGArCQvUCQ1Rpl8wKlMArMAr4oP2Xu7LuBUD1WYK1fHfN(FuEHrR2eWlWE1l4nSmzDryXP)hGdqrgbqc84nogodKc8WKYzsfG3LuBUDfKjP86cOxBIYlmA1MqTJP2lP2ZuRv4Uj5AdNZIacJPXvZuWlWE1l4bzskVUa61MaCak3jajWJ34y4mqkWlWE1l4HwzmcC))XMbpmPCMub4PB8esTxPwCaDbHt4LArMA1nEcv)4EQDm1Iyu7zQ1QFVjDdzHEsKvb9aJg1Im1IiQvUCQv34jKArMAdSx9Q(9M0nKfNYzfUHo1I4GhwwSHfEqsyhcqbbGdqrgdqc84nogodKc8WKYzsfGhH1egokogMAhtTxsTNPwRWDtY1goNfbegtJRMPu7yQ9m1A1V3KUHSqpjYQGEGrJArMAre4fyV6f8GmjLxxa9AtaoafeKjajWJ34y4mqkWdtkNjvaExsTNPwRWDtY1goNfbegtJRMPGxG9QxWle)jjZerRfyspecCakiGaajWJ34y4mqkWdtkNjvaExsTNPwRWDtY1goNfbegtJRMPGxG9QxWd3njxB4CweqymnoWbOGWGaibE8ghdNbsbEys5mPcW7m1A1V3KUHSqpjYQMPuRC5uRUXti1ELAXb0feoHxQ9IuRUXtO6h3tTdm1IGmPw5YP2ZuRv4Uj5AdNZIacJPXvZuWlWE1l497nPBiloLZahGccdaGe4fyV6f8irQ3eb0jfAm4XBCmCgifWbOGWfcqc84nogodKc8WKYzsfG3LuRxy0Qnb8cSx9cEdltwxewC6)b4ah8WgoqNbibqbbasGhVXXWzGuGxNcEq2ln4fyV6f8qpivCmm4HEqeB8zWdhe0zbotapmPCMub4fyVqNf8Y)IHulYulIap0dZKfSbYGhIap0dZKbVa7f6SGx(xme4augeajWlWE1l4fI)KKzIO1cmPhcbpEJJHZaPaoaLbaqc8cSx9cE4Uj5AdNZIacJPXbpEJJHZaPaoaLleGe4XBCmCgif4HjLZKkaVC7k4isKUSrC6)r5fgTAtaVa7vVGhoiOZahGcIaibE8ghdNbsbEys5mPcW7sQ1ddVUkzYeszmHWdSxyOI34y4m1kxo1QNgJGW4rbjHfE9zQfzQnbNbVa7vVG3WYK1fHfN(FaoaL7cGe4XBCmCgif4fyV6f8(9M0nKfNYzWdtkNjvaEz(m1ALjCEDrAxWEvqpWOrTsOweKj4HLfByHhKe2Hauqa4auKraKaVa7vVGhEuGgj(qWJ34y4mqkGdq5obibE8ghdNbsbEb2REbp0kJrG7)p2m4HjLZKkapDJNqQ9k1IdOliCcVulYuRUXtO6h3dEyzXgw4bjHDiafeaoafzmajWJ34y4mqkWdtkNjvaE6PXiimEuqsyHxFMArMAtWzQvUCQ9sQ1ddVUAyzY6IWIA1ty1RI34y4m1kxo1MBxbhrI0LnIt)pkVWOvBc1oMAZTRQ1zYggXXWCU2ef0dmAulYu7aaVa7vVG3z64rmrwGdqbbzcqc84nogodKc8WKYzsfGNhgEDvYKjKYycHhyVWqfVXXWzWlWE1l4Hdc6mWbOGacaKapEJJHZaPapmPCMub4PB8esTxPwCaDbHt4LArMA1nEcv)4EWlWE1l4PnXIwTjcOtk0yGdqbHbbqc84nogodKc8WKYzsfGxUD1WYK1fHfN(Fuewty4O4yyQvUCQ1ddVUAyzY6IWIA1ty1RI34y4m4fyV6f8gwMSUiS40)dWbOGWaaibE8ghdNbsbEb2REbpits51fqV2eWdtkNjvaENPwRqVszcuGoV9xr4a7GhwwSHfEqsyhcqbbGdqbHleGe4XBCmCgif4HjLZKkapC3MCpCvdltwxewC6)rr4FulKAVi1IEqQ4yyfoiOZcCMqTdeP2bbEb2REbpCqqNboafeqeajWlWE1l4bDMncNePGhVXXWzGuahGcc3fajWJ34y4mqkWdtkNjvaEEy41vot(qrRf8Mej8NxxXBCmCg8cSx9cEJcsA3lWbOGGmcGe4XBCmCgif4fyV6f8GmjLxxa9AtapmPCMub4rynHHJIJHP2Xu7zQ1kVsfTw4JybmLdIc6bgnQfzQDaGhwwSHfEqsyhcqbbGdqbH7eGe4XBCmCgif4fyV6f8(9M0nKfNYzWdll2WcpijSdbOGaWbOGGmgGe4XBCmCgif4fyV6f8irQ3eb0jfAm4HLfByHhKe2Hauqa4ah8Goajakiaqc84nogodKc8WKYzsfGNhgEDLZKpu0AbVjrc)51v8ghdNbVa7vVG3OGK29cCakdcGe4XBCmCgif4HjLZKkapDJNqQ9k1IdOliCcVulYuRUXtO6h3dEb2REbpTjw0QnraDsHgdCakdaGe4XBCmCgif4HjLZKkaVZuRv4Uj5AdNZIacJPXvZuQDm1Iyu7zQ1kC3KCTHZzraHX04kc)JAHulYulckerTdMAtWzQvUCQ9m1A1XmjIwl8W0luntP2Xu7zQ1QJzseTw4HPxOIW)Owi1Im1IGcru7GP2eCMArCWlWE1l4rIuVjcOtk0yGdq5cbibE8ghdNbsbEys5mPcW7m1AfUBsU2W5SiGWyAC1mLAhtTig1EMATc3njxB4CweqymnUIW)Owi1Im1IGcru7GP2eCMALlNAptTwDmtIO1cpm9cvZuQDm1EMAT6yMerRfEy6fQi8pQfsTitTiOqe1oyQnbNPweh8cSx9cE)Et6gYIt5mWbOGiasGhVXXWzGuGxG9QxWdTYye4()JndEys5mPcWt34jKAVsT4a6ccNWl1Im1QB8eQ(X9GhwwSHfEqsyhcqbbGdq5UaibE8ghdNbsbEys5mPcW7m1Af6vktGc05T)Qzk1oMAptTwHELYeOaDE7VIW)Owi1Im1Ia1oyQnbNbVa7vVGhKjP86cOxBcWbOiJaibE8ghdNbsbEys5mPcWt34jKAVsT4a6ccNWl1Im1QB8eQ(X9GxG9QxWd6mBeojsboaL7eGe4XBCmCgif4HjLZKkapDJNqQ9k1IdOliCcVulYuRUXtO6h3tTJP2lPwVWOvBc1oMAVKAptTw95FtKv0AHzIRSit44dvZuQDm1IyuREAmccJhfKew41NPwKPweuiIAhm1MGZuRC5u7LuBUD1WYK1fHfN(FuEHrR2eQDm1Ej1EMATc3njxB4CweqymnUAMsTYLtTxsT52vdltwxewC6)r5fgTAtO2Xu7zQ1QFVjDdzHEsKvb9aJg1Im1Ia1I4uRC5uRxFw4Tixm1Im1IWDsTJP2lP2C7QHLjRlclo9)O8cJwTjGxG9QxWByzY6IWIt)pahGImgGe4XBCmCgif4HjLZKkaVZuRvOxPmbkqN3(RMPu7yQn3UcYKuEDb0Rnrr4FulKArMAVqQDWuBcotTYLtT52vqMKYRlGETjkcRjmCuCmm1oMAVKAptTwH7MKRnColcimMgxntbVa7vVGhKjP86cOxBcWbOGGmbibE8ghdNbsbEys5mPcW7sQ9m1AfUBsU2W5SiGWyAC1mf8cSx9cEH4pjzMiATat6HqGdqbbeaibE8ghdNbsbEys5mPcW7sQ9m1AfUBsU2W5SiGWyAC1mf8cSx9cE4Uj5AdNZIacJPXboafegeajWJ34y4mqkWdtkNjvaENPwR(9M0nKf6jrw1mLALlNA1nEcP2RuloGUGWj8sTxKA1nEcv)4EQDGP2bjtQDm16HHxxHELYeOaDE7VI34y4m1kxo1QB8esTxPwCaDbHt4LAVi1QB8eQ(X9u7atTiqTJPwpm86kNjFOO1cEtIe(ZRR4nogotTYLtTNPwRWDtY1goNfbegtJRMPGxG9QxW73Bs3qwCkNboafegaajWlWE1l4rIuVjcOtk0yWJ34y4mqkGdqbHleGe4XBCmCgif4HjLZKkaVC7QHLjRlclo9)OiSMWWrXXWGxG9QxWByzY6IWIt)pahGccicGe4XBCmCgif4HjLZKkaVZuRvOxPmbkqN3(RMPGxG9QxWdYKuEDb0Rnb4ah8gQlasauqaGe4XBCmCgif4HjLZKkapDJNqQ9k1IdOliCcVulYuRUXtO6h3tTJPwpm86kNjFOO1cEtIe(ZRR4nogodEb2REbVrbjT7f4augeajWJ34y4mqkWdtkNjvaENPwRoMjr0AHhMEHQzk1oMAptTwDmtIO1cpm9cve(h1cPwKP2eCg8cSx9cE)Et6gYIt5mWbOmaasGhVXXWzGuGhMuotQa8otTwDmtIO1cpm9cvZuQDm1EMAT6yMerRfEy6fQi8pQfsTitTj4m4fyV6f8irQ3eb0jfAmWbOCHaKapEJJHZaPapmPCMub4DMATc9kLjqb682F1mLAhtTNPwRqVszcuGoV9xr4FulKArMArqHiQDWuBcotTYLtTxsT52vqMKYRlGETjkVWOvBc4fyV6f8GmjLxxa9Ataoafebqc84nogodKc8WKYzsfGNEAmccJhfKew41NPwKPweuiIAhm1MGZu7yQv34jKAVsT4a6ccNWl1Im1QB8eQ(X9uRC5ulIrTlFVlgwIt)pk0Bt4LHP2XuBUDfKjP86cOxBIYlmA1MqTJP2C7kits51fqV2efH1egokogMALlNAx(ExmSeN(FuPJys)7LP2Xu7Lu7zQ1QFVjDdzHEsKvntP2XuRUXti1ELAXb0feoHxQfzQv34ju9J7P2bMAdSx9QqRmgbU))yZkCaDbHt4LAhm1oaQfXbVa7vVG3WYK1fHfN(FaoaL7cGe4XBCmCgif4HjLZKkapDJNqQ9k1IdOliCcVulYuRUXtO6h3tTdm1QB8eQiCcVGxG9QxWdTYye4()JndCakYiasGxG9QxWle)jjZerRfyspecE8ghdNbsbCak3jajWJ34y4mqkWdtkNjvaE6gpHu7vQfhqxq4eEPwKPwDJNq1pUh8cSx9cEqNzJWjrkWbOiJbibE8ghdNbsbEys5mPcWtpngbHXJcscl86ZulYulckerTdMAtWzWlWE1l4nSmzDryXP)hGdqbbzcqc8cSx9cE4Uj5AdNZIacJPXbpEJJHZaPaoafeqaGe4XBCmCgif4HjLZKkaVZuRvOxPmbkqN3(RMPu7yQn3UcYKuEDb0Rnrr4FulKArMAVqQDWuBcodEb2REbpits51fqV2eGdqbHbbqc84nogodKc8WKYzsfGxUDfCejsx2io9)O8cJwTjuRC5u7zQ1QFVjDdzHEsKvb9aJg1kHAre4fyV6f8(9M0nKfNYzGdqbHbaqc84nogodKc8WKYzsfG3Y37IHL40)JcoIePlBO2XuBUDfKjP86cOxBIIW)Owi1ErQfru7GP2eCg8cSx9cEdltwxewC6)b4auq4cbibE8ghdNbsbEys5mPcWJWAcdhfhddEb2REbpits51fqV2eGdqbbebqc84nogodKc8WKYzsfG3Lu7zQ1QFVjDdzHEsKvr4Fule8cSx9cE4rbAK4dboafeUlasGxG9QxW73Bs3qwCkNbpEJJHZaPaoafeKraKaVa7vVGhjs9MiGoPqJbpEJJHZaPaoafeUtasGhVXXWzGuGhMuotQa8otTwHELYeOaDE7VAMcEb2REbpits51fqV2eGdqbbzmajWJ34y4mqkWdtkNjvaElFVlgwIt)pk0Bt4LHP2XuBUDfKjP86cOxBIYlmA1MqTYLtTlFVlgwIt)pQ0rmP)9YuRC5u7Y37IHL40)JcoIePlBaVa7vVG3WYK1fHfN(FaoWbViDOUaibqbbasGhVXXWzGuGhMuotQa8otTwDmtIO1cpm9cvZuQDm1EMAT6yMerRfEy6fQi8pQfsTitTj4m4fyV6f8(9M0nKfNYzGdqzqaKapEJJHZaPapmPCMub4DMAT6yMerRfEy6fQMPu7yQ9m1A1XmjIwl8W0lur4FulKArMAtWzWlWE1l4rIuVjcOtk0yGdqzaaKapEJJHZaPapmPCMub4Dj1MBxbzskVUa61MO8cJwTjGxG9QxWdYKuEDb0Rnb4auUqasGxG9QxWle)jjZerRfyspecE8ghdNbsbCakicGe4XBCmCgif4HjLZKkap90yeegpkijSWRptTitTiOqe1oyQnbNPw5YPwDJNqQ9k1IdOliCcVulYuRUXtO6h3tTJPweJAx(ExmSeN(FuO3MWldtTJP2C7kits51fqV2eLxy0QnHAhtT52vqMKYRlGETjkcRjmCuCmm1kxo1U89Uyyjo9)OshXK(3ltTJP2lP2ZuRv)Et6gYc9KiRAMsTJPwDJNqQ9k1IdOliCcVulYuRUXtO6h3tTdm1gyV6vHwzmcC))XMv4a6ccNWl1oyQDaulIdEb2REbVHLjRlclo9)aCak3fajWlWE1l4H7MKRnColcimMgh84nogodKc4auKraKapEJJHZaPapmPCMub4DMAT63Bs3qwONezve(h1cP2Xu7Y37IHL40)JkDet6FVm4fyV6f8(9M0nKfNYzGdq5obibE8ghdNbsbEys5mPcWtpngbHXJcscl86ZulYulckerTdMAtWzQDm1QB8esTxPwCaDbHt4LArMA1nEcv)4EQDGP2bjtWlWE1l4HwzmcC))XMboafzmajWJ34y4mqkWdtkNjvaE6gpHu7vQfhqxq4eEPwKPwDJNq1pUh8cSx9cEqNzJWjrkWbOGGmbibE8ghdNbsbEys5mPcW7m1ALxPIwl8rSaMYbrb9aJg1kHAha1kxo1MBxbhrI0LnIt)pkVWOvBc4fyV6f8irQ3eb0jfAmWbOGacaKapEJJHZaPapmPCMub4LBxbhrI0LnIt)pkVWOvBc4fyV6f8(9M0nKfNYzGdqbHbbqc84nogodKc8WKYzsfG3Y37IHL40)JcoIePlBO2XuRUXti1ErQDaYKAhtT52vqMKYRlGETjkc)JAHu7fPwerTdMAtWzWlWE1l4nSmzDryXP)hGdqbHbaqc84nogodKc8WKYzsfG3Lu7zQ1QFVjDdzHEsKvr4Fule8cSx9cE4rbAK4dboafeUqasGhVXXWzGuGhMuotQa8iSMWWrXXWGxG9QxWdYKuEDb0Rnb4auqaraKapEJJHZaPapmPCMub4PB8esTxPwCaDbHt4LArMA1nEcv)4EQDm1Iyu7zQ1QFVjDdzHEsKvb9aJg1Im1IiQvUCQv34jKArMAdSx9Q(9M0nKfNYzfUHo1I4GxG9QxWdTYye4()JndCakiCxaKaVa7vVGhjs9MiGoPqJbpEJJHZaPaoafeKraKapEJJHZaPapmPCMub4DMAT63Bs3qwONezvZuQvUCQv34jKAVi1EHYKALlNAZTRGJir6YgXP)hLxy0Qnb8cSx9cE)Et6gYIt5mWbOGWDcqc84nogodKc8WKYzsfG3Y37IHL40)Jc92eEzyQDm1MBxbzskVUa61MO8cJwTjuRC5u7Y37IHL40)JkDet6FVm1kxo1U89Uyyjo9)OGJir6YgQDm1QB8esTxKArKmbVa7vVG3WYK1fHfN(FaoWbVucJ7)jCasauqaGe4fyV6f8GZ)Vxrk7GhVXXWzGuahGYGaibE8ghdNbsbEB8zWlKb4OGeqHUxx0ArApKjGxG9QxWlKb4OGeqHUxx0ArApKjahGYaaibE8ghdNbsbEb2REbpSSyt7KElS4ycOdEys5mPcW7sQLevwWOZRRQf9PzzsCmSIVVGoe8yTMXUyJpdEyzXM2j9wyXXeqh4auUqasGxG9QxWlzgKCfRO1Iqgys7JapEJJHZaPaoafebqc8cSx9cE4Uj5AdNZIacJPXbpEJJHZaPaoaL7cGe4fyV6f8g2etgDUwbHH9glMbpEJJHZaPaoafzeajWJ34y4mqkWlWE1l4L2E1l4LLDJFHfPeoTDWdbGdq5obibEb2REbpOZSr4Kif84nogodKc4auKXaKaVa7vVG3OGK29cE8ghdNbsbCGdE4meGeafeaibE8ghdNbsbEys5mPcWd3Tj3dxfUBsU2W5SiGWyACfH)rTqQ9Iu7aKj4fyV6f8oMUZc9KilWbOmiasGhVXXWzGuGhMuotQa8WDBY9WvH7MKRnColcimMgxr4FulKAVi1oazcEb2REbVyXm0jHrGdJb4augaajWJ34y4mqkWdtkNjvaE4Un5E4QWDtY1goNfbegtJRi8pQfsTxKAhGmbVa7vVGNUi8X0Dg4auUqasGxG9QxWZujJCOyGoZjFEDWJ34y4mqkGdqbraKapEJJHZaPapmPCMub4H72K7HRc3njxB4CweqymnUIW)Owi1ErQ9UKj1kxo161NfElYftTitTimaWlWE1l4DycKjOvBcWbOCxaKapEJJHZaPapmPCMub4DMATkzgKCfRO1Iqgys7JuZuQDm1Iyu7zQ1QdtGmbTAtuZuQvUCQ9m1A1X0DwONezvZuQvUCQ9sQLeyw5K2yOweNALlNArmQf3lC(JJHvPTx9kATyUhsLnCwONezP2XuRxFw4Tixm1Im1ExiqTYLtTE9zH3ICXulYu7GUlQfXPw5YP2lPwgc5fZkCVzEHCwyknRBcMv)yG2eQDm1EMATc3njxB4CweqymnUAMcEb2REbV02REboafzeajWJ34y4mqkWdtkNjvaEEqsyxLlOhlMP2lkHAVlWlWE1l4fWug7Iwl8rSGJeddCak3jajWJ34y4mqkWlWE1l4fWrOhldfKqgAIa3KWaEys5mPcWJhiNvAkNvzsDoMAte1IwANP2XulIrTz(m1AfjKHMiWnjmImFMATk3dxQvUCQ1Rpl8wKIDXaKj1Im1Ia1kxo1Iyu7iom(ivk2PwKP2bitQDm1EMATkzgKCfRO1Iqgys7JuZuQvUCQ9m1A1N)nrwrRfMjUYImHJpuntPweNArCQvUCQfXO2lPwEGCwPPCwLj15yQnrulAPDMAhtTig1EMAT6Z)MiRO1cZexzrMWXhQMPuRC5u7zQ1QKzqYvSIwlczGjTpsntP2XulUBtUhUQKzqYvSIwlczGjTpsr4FulKAVi1IGmcrulItTYLtTz(m1AfjKHMiWnjmImFMATk3dxQfXPw5YPwV(SWBrUyQfzQDqYe824ZGxahHESmuqczOjcCtcdWbOiJbibE8ghdNbsbEb2REbVKWW4WyycuC6EbpmPCMub4H72K7HR6Z)MiRO1cZexzrMWXhQi8pQfsTYLtTEy41vdltwxewuREcREv8ghdNP2XulUBtUhUkC3KCTHZzraHX04kc)JAHuRC5u7LuldH8Iz1N)nrwrRfMjUYImHJpu9JbAtO2XulUBtUhUkC3KCTHZzraHX04kc)JAHG3gFg8scdJdJHjqXP7f4auqqMaKapEJJHZaPaVn(m4fYaCuqcOq3RlATiThYeWlWE1l4fYaCuqcOq3RlATiThYeGdqbbeaibE8ghdNbsbEys5mPcWJevwWOZRRICgQQLAVi1kJLj1oMA1nEcPwKPwDJNq1pUNAhyQDqiIALlNArmQnWEHol4L)fdP2lsTiqTJP2lPwpm86QtrYqrRfPewwfVXXWzQvUCQnWEHol4L)fdP2lsTdIArCQDm1Iyu7zQ1QJzseTw4HPxOAMsTJP2ZuRvhZKiATWdtVqfH)rTqQ9Iu7aO2btTj4m1kxo1Ej1EMAT6yMerRfEy6fQMPulIdEb2REbpDJNqolczGjLZIdhFGdqbHbbqc84nogodKc8WKYzsfG3zQ1kC3KCTHZzraHX04Qzk4fyV6f8oMUZIwl8rSGx(llWbOGWaaibEb2REbV0jP0YwBI4ycOdE8ghdNbsbCakiCHaKaVa7vVGxYmi5kwrRfHmWK2hbE8ghdNbsbCakiGiasGxG9QxWJuPPgwuRaMgyg84nogodKc4auq4UaibE8ghdNbsbEys5mPcWtpngbHXJcscl86ZulYulcu7GP2eCg8cSx9cE4EX86KW5SqBIpdCakiiJaibE8ghdNbsbEys5mPcW7m1AfHXOzyiuOBcMvZuWlWE1l45JyXCp9CZcDtWmWbOGWDcqc8cSx9cEdBIjJoxRGWWEJfZGhVXXWzGuahGccYyasGhVXXWzGuGhMuotQa88GKWUAehgFKkf7u7fP27uMuRC5uRhKe2vJ4W4JuPyNArwc1oizsTYLtTEqsyx51NfElsXUyqYKAVi1oazcEb2REbpchP1Mi0M4ZqGdqzqYeGe4XBCmCgif4HjLZKkapgc5fZQp)BISIwlmtCLfzchFO6hd0MqTJPwcRjmCuCmm1oMAptTwHELYeOaDE7VAMsTJP2lPwC3MCpCvF(3ezfTwyM4klYeo(qfH)rTqWlWE1l4bzskVUa61MaCakdcbasGhVXXWzGuGhMuotQa8yiKxmR(8VjYkATWmXvwKjC8HQFmqBc1oMAVKAXDBY9Wv95FtKv0AHzIRSit44dve(h1cbVa7vVG3V3KUHS4uodCakdAqaKapEJJHZaPapmPCMub4XqiVyw95FtKv0AHzIRSit44dv)yG2eQDm1QNgJGW4rbjHfE9zQfzQfbfIO2btTj4m1oMA1nEcPwKP2a7vVQFVjDdzXPCwHBOtTJP2lPwC3MCpCvF(3ezfTwyM4klYeo(qfH)rTqWlWE1l4nSmzDryXP)hGdqzqdaGe4XBCmCgif4HjLZKkapDJNqQfzQnWE1R63Bs3qwCkNv4g6u7yQ9m1AfUBsU2W5SiGWyAC1mf8cSx9cEF(3ezfTwyM4klYeo(qGdCWlZ6yACasauqaGe4XBCmCgif4HjLZKkaVmFMATchqV2e1mLALlNAptTwLlykBmXXWIFKuy1mLALlNAptTwLlykBmXXWcEjrcRMPGxG9QxWdhgJiWE1RWuqh8mf0fB8zWB6LPCzboaLbbqc8cSx9cEtilkN)qWJ34y4mqkGdqzaaKapEJJHZaPaVa7vVGhomgrG9QxHPGo4zkOl24ZGhodboaLleGe4XBCmCgif4HjLZKkaVa7f6SGx(xmKALqTiqTJPwpijSR86ZcVf5IPwKPwDJNqQDGi1IyuBG9Qx1V3KUHS4uoRWn0P2bMAXb0feoHxQfXP2btTj4m4fyV6f8(9M0nKfNYzGdqbraKapEJJHZaPapmPCMub4fyVqNf8Y)IHulYu7aO2XuRhgEDfEuGgj(qfVXXWzQDm16HHxxfM0rHiLW5WBII34y4m4fyV6f8WHXicSx9kmf0bptbDXgFg8I0H6c4auUlasGhVXXWzGuGhMuotQa8cSxOZcE5FXqQfzQDau7yQ1ddVUcpkqJeFOI34y4m4fyV6f8WHXicSx9kmf0bptbDXgFg8gQlGdqrgbqc84nogodKc8WKYzsfGxG9cDwWl)lgsTitTdGAhtTxsTEy41vHjDuisjCo8MO4nogotTJP2lPwpm86QHLjRlclQvpHvVkEJJHZGxG9QxWdhgJiWE1RWuqh8mf0fB8zWd6ahGYDcqc84nogodKc8WKYzsfGxG9cDwWl)lgsTitTdGAhtTEy41vHjDuisjCo8MO4nogotTJP2lPwpm86QHLjRlclQvpHvVkEJJHZGxG9QxWdhgJiWE1RWuqh8mf0fB8zWlsHoWbOiJbibE8ghdNbsbEys5mPcWlWEHol4L)fdPwKP2bqTJPwpm86QWKokePeohEtu8ghdNP2XuRhgED1WYK1fHf1QNWQxfVXXWzWlWE1l4HdJreyV6vykOdEMc6In(m4fPd1fWbOGGmbibE8ghdNbsbEys5mPcWlWEHol4L)fdPwKP2bqTJP2lPwpm86QWKokePeohEtu8ghdNP2XuRhgED1WYK1fHf1QNWQxfVXXWzWlWE1l4HdJreyV6vykOdEMc6In(m4nuxahGcciaqc84nogodKc8WKYzsfGxG9cDwWl)lgsTxKArGAhtTxsTEy41vNIKHIwlsjSSkEJJHZuRC5uBG9cDwWl)lgsTxKAhe4fyV6f8WHXicSx9kmf0bptbDXgFg8WgoqNboafegeajWlWE1l4H7fZRtcNZcTj(m4XBCmCgifWbOGWaaibEb2REbVGGJLfEti86GhVXXWzGuahGccxiajWlWE1l4DIerRfoPWObbpEJJHZaPaoWbVPxMYLfGeafeaibEb2REbV)ugKbddE8ghdNbsbCakdcGe4fyV6f8GmH3YLvKNqh84nogodKc4augaajWlWE1l4btBclWMEMbpEJJHZaPaoaLleGe4fyV6f8GD7JQnrmmCMaE8ghdNbsbCakicGe4fyV6f8G9wyXXeqh84nogodKc4auUlasGxG9QxWBzFeteWrngnWJ34y4mqkGdqrgbqc8cSx9cE4r1aTGcNe7a5SmLll4XBCmCgifWbOCNaKaVa7vVGhmTiLlGJAmAGhVXXWzGuahGImgGe4fyV6f82WNegksibMbpEJJHZaPaoWbo4HotGvVaugKmhKmL5aKjcG3WGS1MabV7o)0M4CMALXuBG9QxQ1uqhQO3aVusRlddExa1(Me0l0dd1E3AUotO3UaQDK7PW7gurnP8rZJc3FuH1FAcV6ftcTJkS(yuP3UaQ9oMskd1oiejn1oizoizsVrVDbu7D4Oyty4Dd92fqTdm1EhZzotT3btzqgmm16n1MzDmno1gyV6LAnf0v0Bxa1oWu7D4Oyt4m16bjHDrPPw((ucdHvVqQ1BQfll2WcpijSdv0Bxa1oWu7DqNlDXzQfhe0zbotOwVP2HnbnQ93eMA5awgzP2HLpIA9rm1g5CV3THuB9tn8Nxp8QxQT1ul6bPIJHv0Bxa1oWu7DmN5m1o9YuUSu7D8U3Dxf9g92fqTdeUNXtNZu7H1nHPwC)pHtThoPwOIAVJymN6qQD7DGhfKVEAO2a7vVqQTxJSk6TlGAdSx9cvPeg3)t4s0MaIg92fqTb2REHQucJ7)j8RsqnMjFE9WREP3UaQnWE1luLsyC)pHFvcQ6UZ0Bb2REHQucJ7)j8Rsqfo))EfPStVDbu7BJu4O2PwsuzQ9m1AotTqpCi1EyDtyQf3)t4u7HtQfsTXMP2ucpWPT71MqTfKAZ9Yk6TlGAdSx9cvPeg3)t4xLGkCJu4O2fqpCi9wG9QxOkLW4(Fc)QeuNqwuo)LEJpljKb4OGeqHUxx0ArApKj0Bb2REHQucJ7)j8RsqDczr58xAwRzSl24ZsWYInTt6TWIJjGU0LwYLKOYcgDEDvTOpnltIJHv89f0H0Bb2REHQucJ7)j8RsqnzgKCfRO1Iqgys7JO3cSx9cvPeg3)t4xLGkUBsU2W5SiGWyAC6Ta7vVqvkHX9)e(vjOoSjMm6CTccd7nwmtVfyV6fQsjmU)NWVkb102RELol7g)clsjCA7sqGElWE1luLsyC)pHFvcQqNzJWjrk9wG9QxOkLW4(Fc)QeuhfK0Ux6n6Ta7vVq10lt5Yk5pLbzWW0Bb2REHQPxMYL9QeuHmH3YLvKNqNElWE1lun9YuUSxLGkmTjSaB6zMElWE1lun9YuUSxLGkSBFuTjIHHZe6Ta7vVq10lt5YEvcQWElS4ycOtVfyV6fQMEzkx2RsqDzFeteWrngn6Ta7vVq10lt5YEvcQ4r1aTGcNe7a5SmLll9wG9QxOA6LPCzVkbvyArkxah1y0O3cSx9cvtVmLl7vjOUHpjmuKqcmtVrVDbu7aH7z805m1YOZezPwV(m16JyQnWEtO2csTb6rzIJHv0Bb2REHsWHXicSx9kmf0LEJplz6LPCzLU0sY8zQ1kCa9AtuZu5YptTwLlykBmXXWIFKuy1mvU8ZuRv5cMYgtCmSGxsKWQzk9wG9Qx4vjOoHSOC(dP3cSx9cVkbvCymIa7vVctbDP34ZsWzi9wG9Qx4vjO(7nPBiloLZsxAjb2l0zbV8VyOeeg7bjHDLxFw4TixmY6gpHderSa7vVQFVjDdzXPCwHBOpW4a6ccNWlIp4eCMElWE1l8QeuXHXicSx9kmf0LEJpljshQlPlTKa7f6SGx(xme5bm2ddVUcpkqJeFOI34y48ypm86QWKokePeohEtu8ghdNP3cSx9cVkbvCymIa7vVctbDP34ZsgQlPlTKa7f6SGx(xme5bm2ddVUcpkqJeFOI34y4m9wG9Qx4vjOIdJreyV6vykOl9gFwc0LU0scSxOZcE5FXqKhW4l9WWRRct6OqKs4C4nrXBCmCE8LEy41vdltwxewuREcREv8ghdNP3cSx9cVkbvCymIa7vVctbDP34ZsIuOlDPLeyVqNf8Y)IHipGXEy41vHjDuisjCo8MO4nogop(spm86QHLjRlclQvpHvVkEJJHZ0Bb2REHxLGkomgrG9QxHPGU0B8zjr6qDjDPLeyVqNf8Y)IHipGXEy41vHjDuisjCo8MO4nogop2ddVUAyzY6IWIA1ty1RI34y4m9wG9Qx4vjOIdJreyV6vykOl9gFwYqDjDPLeyVqNf8Y)IHipGXx6HHxxfM0rHiLW5WBII34y48ypm86QHLjRlclQvpHvVkEJJHZ0Bb2REHxLGkomgrG9QxHPGU0B8zjydhOZsxAjb2l0zbV8Vy4fry8LEy41vNIKHIwlsjSSkEJJHZYLhyVqNf8Y)IHxCq0Bb2REHxLGkUxmVojCol0M4Z0Bb2REHxLGAqWXYcVjeED6Ta7vVWRsq9ejIwlCsHrdsVrVfyV6fQIuOl53Bs3qwCkNLU0sotTwH7MKRnColcimMgxnthJyNPwRWDtY1goNfbegtJRi8pQfImcken4eCwU8ZuRvhZKiATWdtVq1mD8zQ1QJzseTw4HPxOIW)OwiYiOq0GtWzeNElWE1lufPq)QeujrQ3eb0jfAS0LwYzQ1kC3KCTHZzraHX04Qz6ye7m1AfUBsU2W5SiGWyACfH)rTqKrqHObNGZYLFMAT6yMerRfEy6fQMPJptTwDmtIO1cpm9cve(h1crgbfIgCcoJ40Bb2REHQif6xLGQ2elA1MiGoPqJLU0s0nEcVIdOliCcViRB8eQ(X90Bb2REHQif6xLGkALXiW9)hBwASSydl8GKWouccsxAj6PXiimEuqsyHxFgzeuiAWj48yDJNWR4a6ccNWlY6gpHQFCp9wG9QxOksH(vjOcDMncNePsxAj6gpHxXb0feoHxK1nEcv)4E6Ta7vVqvKc9RsqDyzY6IWIt)psxAj6gpHxXb0feoHxK1nEcv)4(Xx6fgTAtgF5zQ1Qp)BISIwlmtCLfzchFOAMogX0tJrqy8OGKWcV(mYiOq0GtWz5YVm3UAyzY6IWIt)pkVWOvBY4lptTwH7MKRnColcimMgxntLl)YC7QHLjRlclo9)O8cJwTjJptTw97nPBil0tISkOhy0qgbexUCV(SWBrUyKr4ohFzUD1WYK1fHfN(FuEHrR2e6Ta7vVqvKc9RsqfYKuEDb0Rnr6sl5YC7kits51fqV2eLxy0Qnz8LNPwRWDtY1goNfbegtJRMP0Bb2REHQif6xLGkALXiW9)hBwASSydl8GKWouccsxAj6gpHxXb0feoHxK1nEcv)4(Xi2zQ1QFVjDdzHEsKvb9aJgYisUCDJNqKdSx9Q(9M0nKfNYzfUHoItVfyV6fQIuOFvcQqMKYRlGETjsxAjewty4O4y4XxEMATc3njxB4CweqymnUAMo(m1A1V3KUHSqpjYQGEGrdzerVfyV6fQIuOFvcQH4pjzMiATat6HqPlTKlptTwH7MKRnColcimMgxntP3cSx9cvrk0VkbvC3KCTHZzraHX04sxAjxEMATc3njxB4CweqymnUAMsVfyV6fQIuOFvcQ)Et6gYIt5S0LwYzQ1QFVjDdzHEsKvntLlx34j8koGUGWj8ErDJNq1pUFGrqMYLFMATc3njxB4CweqymnUAMsVfyV6fQIuOFvcQKi1BIa6KcnMElWE1lufPq)QeuhwMSUiS40)J0LwYLEHrR2e6n6Ta7vVqvKouxs(9M0nKfNYzPlTKZuRvhZKiATWdtVq1mD8zQ1QJzseTw4HPxOIW)OwiYj4m9wG9QxOkshQRRsqLePEteqNuOXsxAjNPwRoMjr0AHhMEHQz64ZuRvhZKiATWdtVqfH)rTqKtWz6Ta7vVqvKouxxLGkKjP86cOxBI0LwYL52vqMKYRlGETjkVWOvBc9wG9QxOkshQRRsqne)jjZerRfyspesVfyV6fQI0H66QeuhwMSUiS40)J0LwIEAmccJhfKew41NrgbfIgCcolxUUXt4vCaDbHt4fzDJNq1pUFmIT89Uyyjo9)OqVnHxgECUDfKjP86cOxBIYlmA1Mmo3UcYKuEDb0RnrrynHHJIJHLlF57DXWsC6)rLoIj9VxE8LNPwR(9M0nKf6jrw1mDSUXt4vCaDbHt4fzDJNq1pUFGdSx9QqRmgbU))yZkCaDbHt4DWdaXP3cSx9cvr6qDDvcQ4Uj5AdNZIacJPXP3cSx9cvr6qDDvcQ)Et6gYIt5S0LwYzQ1QFVjDdzHEsKvr4FulC8Y37IHL40)JkDet6FVm9wG9QxOkshQRRsqfTYye4()JnlDPLONgJGW4rbjHfE9zKrqHObNGZJ1nEcVIdOliCcViRB8eQ(X9d8GKj9wG9QxOkshQRRsqf6mBeojsLU0s0nEcVIdOliCcViRB8eQ(X90Bb2REHQiDOUUkbvsK6nraDsHglDPLCMATYRurRf(iwat5GOGEGrtYaKlp3UcoIePlBeN(FuEHrR2e6Ta7vVqvKouxxLG6V3KUHS4uolDPLKBxbhrI0LnIt)pkVWOvBc9wG9QxOkshQRRsqDyzY6IWIt)psxAjlFVlgwIt)pk4isKUSzSUXt4fhGmhNBxbzskVUa61MOi8pQfEren4eCMElWE1lufPd11vjOIhfOrIpu6sl5YZuRv)Et6gYc9KiRIW)Owi9wG9QxOkshQRRsqfYKuEDb0Rnr6slHWAcdhfhdtVfyV6fQI0H66QeurRmgbU))yZsxAj6gpHxXb0feoHxK1nEcv)4(Xi2zQ1QFVjDdzHEsKvb9aJgYisUCDJNqKdSx9Q(9M0nKfNYzfUHoItVfyV6fQI0H66QeujrQ3eb0jfAm9wG9QxOkshQRRsq93Bs3qwCkNLU0sotTw97nPBil0tISQzQC56gpHx8cLPC552vWrKiDzJ40)JYlmA1MqVfyV6fQI0H66QeuhwMSUiS40)J0LwYY37IHL40)Jc92eEz4X52vqMKYRlGETjkVWOvBIC5lFVlgwIt)pQ0rmP)9YYLV89Uyyjo9)OGJir6YMX6gpHxerYKEJElWE1luHZqjht3zHEsKv6slb3Tj3dxfUBsU2W5SiGWyACfH)rTWloazsVfyV6fQWz4vjOglMHojmcCymsxAj4Un5E4QWDtY1goNfbegtJRi8pQfEXbit6Ta7vVqfodVkbvDr4JP7S0LwcUBtUhUkC3KCTHZzraHX04kc)JAHxCaYKElWE1luHZWRsq1ujJCOyGoZjFED6Ta7vVqfodVkb1dtGmbTAtKU0sWDBY9WvH7MKRnColcimMgxr4Ful8I3LmLl3Rpl8wKlgzega9wG9QxOcNHxLGAA7vVsxAjNPwRsMbjxXkATiKbM0(i1mDmIDMAT6WeitqR2e1mvU8ZuRvht3zHEsKvntLl)ssGzLtAJbXLlhXW9cN)4yyvA7vVIwlM7HuzdNf6jr2XE9zH3ICXiFxiixUxFw4TixmYd6UqC5YVKHqEXSc3BMxiNfMsZ6MGz1pgOnz8zQ1kC3KCTHZzraHX04Qzk9wG9QxOcNHxLGAatzSlATWhXcosmS0LwIhKe2v5c6XI5lk5UO3cSx9cv4m8QeuNqwuo)LEJpljGJqpwgkiHm0ebUjHr6slHhiNvAkNvzsDoMAte1IwANhJyz(m1AfjKHMiWnjmImFMATk3dx5Y96ZcVfPyxmazImcYLJyJ4W4JuPyh5biZXNPwRsMbjxXkATiKbM0(i1mvU8ZuRvF(3ezfTwyM4klYeo(q1mfXrC5YrSl5bYzLMYzvMuNJP2erTOL25Xi2zQ1Qp)BISIwlmtCLfzchFOAMkx(zQ1QKzqYvSIwlczGjTpsnthJ72K7HRkzgKCfRO1Iqgys7Jue(h1cVicYieH4YLN5ZuRvKqgAIa3KWiY8zQ1QCpCrC5Y96ZcVf5IrEqYKElWE1luHZWRsqDczr58x6n(SKKWW4WyycuC6ELU0sWDBY9Wv95FtKv0AHzIRSit44dve(h1cLl3ddVUAyzY6IWIA1ty1RI34y48yC3MCpCv4Uj5AdNZIacJPXve(h1cLl)sgc5fZQp)BISIwlmtCLfzchFO6hd0Mmg3Tj3dxfUBsU2W5SiGWyACfH)rTq6Ta7vVqfodVkb1jKfLZFP34ZsczaokibuO71fTwK2dzc9wG9QxOcNHxLGQUXtiNfHmWKYzXHJV0LwcjQSGrNxxf5muv7fLXYCSUXtiY6gpHQFC)apiejxoIfyVqNf8Y)IHxeHXx6HHxxDksgkATiLWYQ4nogolxEG9cDwWl)lgEXbH4JrSZuRvhZKiATWdtVq1mD8zQ1QJzseTw4HPxOIW)Ow4fhWGtWz5YV8m1A1XmjIwl8W0luntrC6Ta7vVqfodVkb1JP7SO1cFel4L)YkDPLCMATc3njxB4CweqymnUAMsVfyV6fQWz4vjOMojLw2AtehtaD6Ta7vVqfodVkb1KzqYvSIwlczGjTpIElWE1luHZWRsqLuPPgwuRaMgyMElWE1luHZWRsqf3lMxNeoNfAt8zPlTe90yeegpkijSWRpJmcdobNP3cSx9cv4m8Qeu9rSyUNEUzHUjyw6sl5m1AfHXOzyiuOBcMvZu6Ta7vVqfodVkb1HnXKrNRvqyyVXIz6Ta7vVqfodVkbvchP1Mi0M4ZqPlTepijSRgXHXhPsX(fVtzkxUhKe2vJ4W4JuPyhzjdsMYL7bjHDLxFw4Tif7IbjZloazsVfyV6fQWz4vjOczskVUa61MiDPLWqiVyw95FtKv0AHzIRSit44dv)yG2KXewty4O4y4XNPwRqVszcuGoV9xnthFjUBtUhUQp)BISIwlmtCLfzchFOIW)Owi9wG9QxOcNHxLG6V3KUHS4uolDPLWqiVyw95FtKv0AHzIRSit44dv)yG2KXxI72K7HR6Z)MiRO1cZexzrMWXhQi8pQfsVfyV6fQWz4vjOoSmzDryXP)hPlTegc5fZQp)BISIwlmtCLfzchFO6hd0MmwpngbHXJcscl86ZiJGcrdobNhRB8eICG9Qx1V3KUHS4uoRWn0hFjUBtUhUQp)BISIwlmtCLfzchFOIW)Owi9wG9QxOcNHxLG6N)nrwrRfMjUYImHJpu6slr34je5a7vVQFVjDdzXPCwHBOp(m1AfUBsU2W5SiGWyAC1mLEJElWE1luHnCGolb9GuXXWsVXNLGdc6SaNjs3PsGSxAPrpmtwsG9cDwWl)lgkn6HzYc2azjisACV5YRELeyVqNf8Y)IHiJi6Ta7vVqf2Wb68vjOgI)KKzIO1cmPhcP3cSx9cvydhOZxLGkUBsU2W5SiGWyAC6Ta7vVqf2Wb68vjOIdc6S0LwsUDfCejsx2io9)O8cJwTj0Bb2REHkSHd05RsqDyzY6IWIt)psxAjx6HHxxLmzcPmMq4b2lmuXBCmCwUC90yeegpkijSWRpJCcotVfyV6fQWgoqNVkb1FVjDdzXPCwASSydl8GKWouccsxAjz(m1ALjCEDrAxWEvqpWOjbbzsVfyV6fQWgoqNVkbv8Oans8H0Bb2REHkSHd05RsqfTYye4()JnlnwwSHfEqsyhkbbPlTeDJNWR4a6ccNWlY6gpHQFCp9wG9QxOcB4aD(QeupthpIjYkDPLONgJGW4rbjHfE9zKtWz5YV0ddVUAyzY6IWIA1ty1RI34y4SC552vWrKiDzJ40)JYlmA1Mmo3UQwNjByehdZ5AtuqpWOH8aO3cSx9cvydhOZxLGkoiOZsxAjEy41vjtMqkJjeEG9cdv8ghdNP3cSx9cvydhOZxLGQ2elA1MiGoPqJLU0s0nEcVIdOliCcViRB8eQ(X90Bb2REHkSHd05RsqDyzY6IWIt)psxAj52vdltwxewC6)rrynHHJIJHLl3ddVUAyzY6IWIA1ty1RI34y4m9wG9QxOcB4aD(QeuHmjLxxa9AtKgll2WcpijSdLGG0LwYzQ1k0RuMafOZB)veoWo9wG9QxOcB4aD(QeuXbbDw6slb3Tj3dx1WYK1fHfN(Fue(h1cVi6bPIJHv4GGolWzYaXbrVfyV6fQWgoqNVkbvOZSr4KiLElWE1luHnCGoFvcQJcsA3R0LwIhgEDLZKpu0AbVjrc)51v8ghdNP3cSx9cvydhOZxLGkKjP86cOxBI0yzXgw4bjHDOeeKU0siSMWWrXXWJptTw5vQO1cFelGPCquqpWOH8aO3UaQfPMAH1FAcNP2jmsyQv3eQ9oO3KUHm1kv5m12eQ9UFK6nHAFoPqJP28KuBc1EhHPm2P2wtT(iMAhiejgwAQf3PYsTCGhrTngpjeEXm12AQ1hXuBG9QxQn2m1gPP8MPwbhjgMA9MA9rm1gyV6LA34Zk6Ta7vVqf2Wb68vjO(7nPBiloLZsJLfByHhKe2HsqGElWE1luHnCGoFvcQKi1BIa6KcnwASSydl8GKWoucc0B0Bb2REHkOlzuqs7ELU0s8WWRRCM8HIwl4njs4pVUI34y4m9wG9QxOc6xLGQ2elA1MiGoPqJLU0s0nEcVIdOliCcViRB8eQ(X90Bb2REHkOFvcQKi1BIa6Kcnw6sl5m1AfUBsU2W5SiGWyAC1mDmIDMATc3njxB4CweqymnUIW)OwiYiOq0GtWz5YptTwDmtIO1cpm9cvZ0XNPwRoMjr0AHhMEHkc)JAHiJGcrdobNrC6TlGArQPwy9NMWzQDcJeMA1nHAVd6nPBitTsvotTnHAV7hPEtO2Ntk0yQnpj1MqT3rykJDQT1uRpIP2bcrIHLMAXDQSulh4ruBJXtcHxmtTTMA9rm1gyV6LAJntTrAkVzQvWrIHPwVPwFetTb2REP2n(SIElWE1lub9Rsq93Bs3qwCkNLU0sotTwH7MKRnColcimMgxnthJyNPwRWDtY1goNfbegtJRi8pQfImcken4eCwU8ZuRvhZKiATWdtVq1mD8zQ1QJzseTw4HPxOIW)OwiYiOq0GtWzeNElWE1lub9RsqfTYye4()JnlnwwSHfEqsyhkbbPlTeDJNWR4a6ccNWlY6gpHQFCp9wG9QxOc6xLGkKjP86cOxBI0LwYzQ1k0RuMafOZB)vZ0XNPwRqVszcuGoV9xr4FulezegCcotVfyV6fQG(vjOcDMncNePsxAj6gpHxXb0feoHxK1nEcv)4E6Ta7vVqf0Vkb1HLjRlclo9)iDPLOB8eEfhqxq4eErw34ju9J7hFPxy0Qnz8LNPwR(8VjYkATWmXvwKjC8HQz6yetpngbHXJcscl86ZiJGcrdobNLl)YC7QHLjRlclo9)O8cJwTjJV8m1AfUBsU2W5SiGWyAC1mvU8lZTRgwMSUiS40)JYlmA1Mm(m1A1V3KUHSqpjYQGEGrdzeqC5Y96ZcVf5IrgH7C8L52vdltwxewC6)r5fgTAtO3cSx9cvq)QeuHmjLxxa9AtKU0sotTwHELYeOaDE7VAMoo3UcYKuEDb0Rnrr4Fule5lCWj4SC552vqMKYRlGETjkcRjmCuCm84lptTwH7MKRnColcimMgxntP3cSx9cvq)QeudXFsYmr0AbM0dHsxAjxEMATc3njxB4CweqymnUAMsVfyV6fQG(vjOI7MKRnColcimMgx6sl5YZuRv4Uj5AdNZIacJPXvZu6Ta7vVqf0Vkb1FVjDdzXPCw6sl5m1A1V3KUHSqpjYQMPYLRB8eEfhqxq4eEVOUXtO6h3pWdsMJ9WWRRqVszcuGoV9xXBCmCwUCDJNWR4a6ccNW7f1nEcv)4(bgHXEy41vot(qrRf8Mej8NxxXBCmCwU8ZuRv4Uj5AdNZIacJPXvZu6Ta7vVqf0VkbvsK6nraDsHgtVfyV6fQG(vjOoSmzDryXP)hPlTKC7QHLjRlclo9)OiSMWWrXXW0Bb2REHkOFvcQqMKYRlGETjsxAjNPwRqVszcuGoV9xntP3O3cSx9cvd1LKrbjT7v6slr34j8koGUGWj8ISUXtO6h3p2ddVUYzYhkATG3KiH)86kEJJHZ0Bb2REHQH66Qeu)9M0nKfNYzPlTKZuRvhZKiATWdtVq1mD8zQ1QJzseTw4HPxOIW)OwiYj4m9wG9QxOAOUUkbvsK6nraDsHglDPLCMAT6yMerRfEy6fQMPJptTwDmtIO1cpm9cve(h1crobNP3cSx9cvd11vjOczskVUa61MiDPLCMATc9kLjqb682F1mD8zQ1k0RuMafOZB)ve(h1crgbfIgCcolx(L52vqMKYRlGETjkVWOvBc9wG9QxOAOUUkb1HLjRlclo9)iDPLONgJGW4rbjHfE9zKrqHObNGZJ1nEcVIdOliCcViRB8eQ(X9YLJylFVlgwIt)pk0Bt4LHhNBxbzskVUa61MO8cJwTjJZTRGmjLxxa9Atuewty4O4yy5Yx(ExmSeN(FuPJys)7LhF5zQ1QFVjDdzHEsKvnthRB8eEfhqxq4eErw34ju9J7h4a7vVk0kJrG7)p2Schqxq4eEh8aqC6Ta7vVq1qDDvcQOvgJa3)FSzPlTeDJNWR4a6ccNWlY6gpHQFC)aRB8eQiCcV0Bb2REHQH66QeudXFsYmr0AbM0dH0Bb2REHQH66QeuHoZgHtIuPlTeDJNWR4a6ccNWlY6gpHQFCp9wG9QxOAOUUkb1HLjRlclo9)iDPLONgJGW4rbjHfE9zKrqHObNGZ0Bb2REHQH66QeuXDtY1goNfbegtJtVfyV6fQgQRRsqfYKuEDb0Rnr6sl5m1Af6vktGc05T)Qz64C7kits51fqV2efH)rTqKVWbNGZ0Bb2REHQH66Qeu)9M0nKfNYzPlTKC7k4isKUSrC6)r5fgTAtKl)m1A1V3KUHSqpjYQGEGrtcIO3cSx9cvd11vjOoSmzDryXP)hPlTKLV3fdlXP)hfCejsx2mo3UcYKuEDb0Rnrr4Ful8IiAWj4m9wG9QxOAOUUkbvits51fqV2ePlTecRjmCuCmm9wG9QxOAOUUkbv8Oans8HsxAjxEMAT63Bs3qwONezve(h1cP3cSx9cvd11vjO(7nPBiloLZ0Bb2REHQH66QeujrQ3eb0jfAm9wG9QxOAOUUkbvits51fqV2ePlTKZuRvOxPmbkqN3(RMP0Bb2REHQH66QeuhwMSUiS40)J0LwYY37IHL40)Jc92eEz4X52vqMKYRlGETjkVWOvBIC5lFVlgwIt)pQ0rmP)9YYLV89Uyyjo9)OGJir6YgWdMYyakdcric4ahaaa]] )


end