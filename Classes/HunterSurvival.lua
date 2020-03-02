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

    spec:RegisterPack( "Survival", 20200301, [[dCemVbqivk9ifqDjvkQYMuj9jOkQYOieCkOk1QuG8kfQzrqDlvkyxK6xqfdJq0XuPAzkq9mfGPPsHUMQI2Mkf5BeczCqvKZPaI1PsrP5PQ09iW(GQWbHQOSqOQEOkfvUiHqLrsiu1jHQOIvQsmtvkQQBsiu2PQQgkufvAPqvuvpvrtvvL9c8xIgSihMQfRIhdzYI6YO2SGplKrRGoTKvRasVgQ0Sj52qz3k9BPgUqDCvkkwoINdA6uUUQSDcY3viJxvHZtiTEOkz(eQ9J0G7GFGz2ng8FWICWIuKdqK313)8Ui6(NGPjAmdMXocxpIbZ1XyWC(icvc5kWm2fv1Eg8dmH9JGyWCOzXWBwCWjQSHVJg1y4alSNYTQxeXdgoWcdHdyEELYWZzbhWm7gd(pyroyrkYbiY767FExeDFaGP)SHnbmNf2t5w17nhXdgyoSYzEbhWmZqeyoW008reQeYv0Ki(3AmHEzGPPHMfdVzXbNOYg(oAuJHdSWEk3QErepy4almeo0ldmnjI5e0qA6UW00Gf5Gfj9c9Yatt3Cd9nIH3S0ldmnDd0eEwoZzAse7Hx4LIPjRPPmh8NYOjhzvV0KQGMMEzGPPBGMU5g6BeNPjZjrSjRanXFetyiS6fstwttirrkwAojInOMEzGPPBGMeX6CfkottiNielrzcnznnnQj4stynHPj2HLsuAAuzdPjBittEo3lEEqAQWIvmgVMBvV0uhOjHCs5hfRPxgyA6gOj8SCMZ00ZkvzIst4z45EZxdMQcAqWpW0JHg4h4)DWpWKx)O4maFWerkJjLdMNxiOrDtY16gNLoe6pLPFX00vAseOPZle0OUj5ADJZshc9NY0egZRfstFPP76pPPbrtrOmnjwmnDEHG(OEezhKMR6fQFX00vA68cb9r9iYoinx1lutymVwin9LMUR)KMgenfHY0eEdMoYQEbtSEJ6gYYtzmWa)hm4hyYRFuCgGpyIiLXKYbZZle0OUj5ADJZshc9NY0VyA6knjc005fcAu3KCTUXzPdH(tzAcJ51cPPV00D9N00GOPiuMMelMMoVqqFupISdsZv9c1VyA6knDEHG(OEezhKMR6fQjmMxlKM(st31FstdIMIqzAcVbthzvVGjXJTMiHgPWLbg4)aa)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dW0rw1lygu(IBTrsOrkCzGb(FJGFGjV(rXza(GPJSQxWe3sPKOgdZ3myIiLXKYbZWtPKegn0jrS0kmMM(st31FstdIMIqzA6knfA0dstJPjKdnjHJ4LM(stHg9GAm)dWejksXsZjrSbb)VdmW)pb)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dW0rw1lycnMvsJ4Xad8)Ma)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dA6knDlnzfc3AJOPR00T005fcAmgRjIk7Gu9qvwMjSJb1VyA6knjc0u4PuscJg6KiwAfgttFPP76pPPbrtrOmnjwmnDlnLBtpQu5qry5PXoARq4wBenDLMULMoVqqJ6MKR1nolDi0Fkt)IPjXIPPBPPCB6rLkhkclpn2rBfc3AJOPR005fcASEJ6gYYWJiQgAocxA6lnDNMWBAsSyAYkmwATmxmn9LMUJNOPR00T0uUn9OsLdfHLNg7OTcHBTrGPJSQxWCuPYHIWYtJDag4Vic8dm51pkodWhmrKYys5G5T0uUnnKjX8AsOvBK2keU1grtxPPBPPZle0OUj5ADJZshc9NY0VyW0rw1lyczsmVMeA1gbmWF8e4hyYRFuCgGpy6iR6fmXTukjQXW8ndMiszmPCWm0OhKMgttihAschXln9LMcn6b1y(h00vAseOPZle0y9g1nKLHhrun0CeU00xA6tAsSyAk0OhKM(stoYQE1y9g1nKLNYynQHgnH3GjsuKILMtIydc(FhyG)deWpWKx)O4maFWerkJjLdMeoqy4q)OyA6knDlnDEHGg1njxRBCw6qO)uM(fttxPPZle0y9g1nKLHhrun0CeU00xA6tW0rw1lyczsmVMeA1gbmW)7Ie8dm51pkodWhmrKYys5G5T005fcAu3KCTUXzPdH(tz6xmy6iR6fmDj2JKzISdsePhbbg4)97GFGjV(rXza(GjIugtkhmVLMoVqqJ6MKR1nolDi0Fkt)IbthzvVGjQBsUw34S0Hq)PmGb(FFWGFGjV(rXza(GjIugtkhmpVqqJ1Bu3qwgEer1VyAsSyAk0OhKMgttihAschXlnHh0uOrpOgZ)GMUbA6UiPjXIPPZle0OUj5ADJZshc9NY0VyW0rw1lyI1Bu3qwEkJbg4)9ba(bMoYQEbtIhBnrcnsHldM86hfNb4dmW)73i4hyYRFuCgGpyIiLXKYbZBPjRq4wBey6iR6fmhvQCOiS80yhGbmWePyxig8d8)o4hyYRFuCgGpy2XGjKTkaMoYQEbtHCs5hfdMc5e56ymyICIqSeLjGjIugtkhmDKvcXsEzSIH00xA6tWuix9yjRGmy(jykKREmy6iReIL8Yyfdbg4)Gb)athzvVGPlXEKmtKDqIi9iiyYRFuCgGpWa)ha4hy6iR6fmrDtY16gNLoe6pLbM86hfNb4dmW)Be8dm51pkodWhmrKYys5GzUnnCiXJxwjpn2rBfc3AJathzvVGjYjcXad8)tWpWKx)O4maFWerkJjLdM3stMR410rpMqkLYLMJScb186hfNPjXIPPWtPKegn0jrS0kmMM(strOmy6iR6fmhvQCOiS80yhGb(FtGFGjV(rXza(GPJSQxWeR3OUHS8ugdMiszmPCWmZNxiOvUXRjJ7c2RgAocxAsanDxKGjsuKILMtIydc(FhyG)IiWpW0rw1lyIg64sCmiyYRFuCgGpWa)XtGFGjV(rXza(GPJSQxWe3sPKOgdZ3myIiLXKYbZqJEqAAmnHCOjjCeV00xAk0OhuJ5FaMirrkwAojIni4)DGb(pqa)atE9JIZa8btePmMuoygEkLKWOHojILwHX00xAkcLPjXIPPBPjZv8A6rLkhkclRn8GvVAE9JIZ0KyX0uUnnCiXJxwjpn2rBfc3AJOPR0uUnDTgtwxjpkMZ1gPHMJWLM(stdamDKv9cMNNHgYerbg4)Drc(bM86hfNb4dMiszmPCW0CfVMo6XesPuU0CKviOMx)O4my6iR6fmrorigyG)3Vd(bM86hfNb4dMiszmPCWm0OhKMgttihAschXln9LMcn6b1y(hGPJSQxWmO8f3AJKqJu4Yad8)(Gb)atE9JIZa8btePmMuoyMBtpQu5qry5PXoAchimCOFumnjwmnzUIxtpQu5qryzTHhS6vZRFuCgmDKv9cMJkvouewEASdWa)VpaWpWKx)O4maFW0rw1lyczsmVMeA1gbMiszmPCW88cbTqvmtGsH4TX0e2rgyIefPyP5Ki2GG)3bg4)9Be8dm51pkodWhmrKYys5GjQBvUhT6rLkhkclpn2rtymVwinHh0KqoP8JI1iNielrzcnDZJMgmy6iR6fmrorigyG)3)e8dmDKv9cMqJzL0iEmyYRFuCgGpWa)VFtGFGjV(rXza(GjIugtkhmnxXRPnMGbLDqYBKhXy8AAE9JIZGPJSQxWCOtI7Ebg4)Dre4hyYRFuCgGpy6iR6fmHmjMxtcTAJatePmMuoys4aHHd9JIPPR005fcARILDqAdzjmMDIgAocxA6lnnaWejksXsZjrSbb)VdmW)74jWpWKx)O4maFW0rw1lyI1Bu3qwEkJbtKOiflnNeXge8)oWa)Vpqa)atE9JIZa8bthzvVGjXJTMiHgPWLbtKOiflnNeXge8)oWagycnWpW)7GFGjV(rXza(GjIugtkhmnxXRPnMGbLDqYBKhXy8AAE9JIZGPJSQxWCOtI7Ebg4)Gb)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dW0rw1lygu(IBTrsOrkCzGb(paWpWKx)O4maFWerkJjLdMNxiOrDtY16gNLoe6pLPFX00vAseOPZle0OUj5ADJZshc9NY0egZRfstFPP76pPPbrtrOmnjwmnDEHG(OEezhKMR6fQFX00vA68cb9r9iYoinx1lutymVwin9LMUR)KMgenfHY0eEdMoYQEbtIhBnrcnsHldmW)Be8dm51pkodWhmrKYys5G55fcAu3KCTUXzPdH(tz6xmnDLMebA68cbnQBsUw34S0Hq)PmnHX8AH00xA6U(tAAq0uekttIfttNxiOpQhr2bP5QEH6xmnDLMoVqqFupISdsZv9c1egZRfstFPP76pPPbrtrOmnH3GPJSQxWeR3OUHS8ugdmW)pb)atE9JIZa8bthzvVGjULsjrngMVzWerkJjLdMHg9G00yAc5qts4iEPPV0uOrpOgZ)amrIIuS0CseBqW)7ad8)Ma)atE9JIZa8btePmMuoyEEHGwOkMjqPq82y6xmnDLMoVqqlufZeOuiEBmnHX8AH00xA6onniAkcLbthzvVGjKjX8AsOvBeWa)frGFGjV(rXza(GjIugtkhmdn6bPPX0eYHMKWr8stFPPqJEqnM)by6iR6fmHgZkPr8yGb(JNa)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dA6knDlnzfc3AJOPR00T005fcAmgRjIk7Gu9qvwMjSJb1VyA6knjc0u4PuscJg6KiwAfgttFPP76pPPbrtrOmnjwmnDlnLBtpQu5qry5PXoARq4wBenDLMULMoVqqJ6MKR1nolDi0Fkt)IPjXIPPBPPCB6rLkhkclpn2rBfc3AJOPR005fcASEJ6gYYWJiQgAocxA6lnDNMWBAsSyAYkmwATmxmn9LMUJNOPR00T0uUn9OsLdfHLNg7OTcHBTrGPJSQxWCuPYHIWYtJDag4)ab8dm51pkodWhmrKYys5G55fcAHQyMaLcXBJPFX00vAk3MgYKyEnj0QnstymVwin9LMUrAAq0uekttIftt520qMeZRjHwTrAchimCOFumnDLMULMoVqqJ6MKR1nolDi0Fkt)IbthzvVGjKjX8AsOvBeWa)VlsWpWKx)O4maFWerkJjLdM3stNxiOrDtY16gNLoe6pLPFXGPJSQxW0LypsMjYoirKEeeyG)3Vd(bM86hfNb4dMiszmPCW8wA68cbnQBsUw34S0Hq)Pm9lgmDKv9cMOUj5ADJZshc9NYag4)9bd(bM86hfNb4dMiszmPCW88cbnwVrDdzz4rev)IPjXIPPqJEqAAmnHCOjjCeV0eEqtHg9GAm)dA6gOPblsA6knzUIxtlufZeOuiEBmnV(rXzAsSyAk0OhKMgttihAschXlnHh0uOrpOgZ)GMUbA6onDLMmxXRPnMGbLDqYBKhXy8AAE9JIZ0KyX005fcAu3KCTUXzPdH(tz6xmy6iR6fmX6nQBilpLXad8)(aa)athzvVGjXJTMiHgPWLbtE9JIZa8bg4)9Be8dm51pkodWhmrKYys5GzUn9OsLdfHLNg7OjCGWWH(rXGPJSQxWCuPYHIWYtJDag4)9pb)atE9JIZa8btePmMuoyEEHGwOkMjqPq82y6xmy6iR6fmHmjMxtcTAJagWaZrHc8d8)o4hyYRFuCgGpyIiLXKYbZqJEqAAmnHCOjjCeV00xAk0OhuJ5FqtxPjZv8AAJjyqzhK8g5rmgVMMx)O4my6iR6fmh6K4UxGb(pyWpWKx)O4maFWerkJjLdMNxiOpQhr2bP5QEH6xmnDLMoVqqFupISdsZv9c1egZRfstFPPiugmDKv9cMy9g1nKLNYyGb(paWpWKx)O4maFWerkJjLdMNxiOpQhr2bP5QEH6xmnDLMoVqqFupISdsZv9c1egZRfstFPPiugmDKv9cMep2AIeAKcxgyG)3i4hyYRFuCgGpyIiLXKYbZZle0cvXmbkfI3gt)IPPR005fcAHQyMaLcXBJPjmMxlKM(st31FstdIMIqzAsSyA6wAk3MgYKyEnj0QnsBfc3AJathzvVGjKjX8AsOvBeWa))e8dm51pkodWhmrKYys5Gz4PuscJg6KiwAfgttFPP76pPPbrtrOmnDLMcn6bPPX0eYHMKWr8stFPPqJEqnM)bnjwmnjc00YFyYrL80yhTqTYTsX00vAk3MgYKyEnj0QnsBfc3AJOPR0uUnnKjX8AsOvBKMWbcdh6hfttIfttl)HjhvYtJD0XdzsJ1lttxPPBPPZle0y9g1nKLHhru9lMMUstHg9G00yAc5qts4iEPPV0uOrpOgZ)GMUbAYrw1Rg3sPKOgdZ3Sg5qts4iEPPbrtdGMWBW0rw1lyoQu5qry5PXoad8)Ma)atE9JIZa8btePmMuoygA0dstJPjKdnjHJ4LM(stHg9GAm)dA6gOPqJEqnHJ4fmDKv9cM4wkLe1yy(Mbg4Vic8dmDKv9cMUe7rYmr2bjI0JGGjV(rXza(ad8hpb(bM86hfNb4dMiszmPCWm0OhKMgttihAschXln9LMcn6b1y(hGPJSQxWeAmRKgXJbg4)ab8dm51pkodWhmrKYys5Gz4PuscJg6KiwAfgttFPP76pPPbrtrOmy6iR6fmhvQCOiS80yhGb(FxKGFGPJSQxWe1njxRBCw6qO)ugyYRFuCgGpWa)VFh8dm51pkodWhmrKYys5G55fcAHQyMaLcXBJPFX00vAk3MgYKyEnj0QnstymVwin9LMUrAAq0uekdMoYQEbtitI51KqR2iGb(FFWGFGjV(rXza(GjIugtkhmZTPHdjE8Yk5PXoARq4wBenjwmnDEHGgR3OUHSm8iIQHMJWLMeqtFcMoYQEbtSEJ6gYYtzmWa)VpaWpWKx)O4maFWerkJjLdMl)HjhvYtJD0WHepEzfnDLMYTPHmjMxtcTAJ0egZRfst4bn9jnniAkcLbthzvVG5OsLdfHLNg7amW)73i4hyYRFuCgGpyIiLXKYbtchimCOFumy6iR6fmHmjMxtcTAJag4)9pb)atE9JIZa8btePmMuoyElnDEHGgR3OUHSm8iIQjmMxlemDKv9cMOHoUehdcmW)73e4hy6iR6fmX6nQBilpLXGjV(rXza(ad8)Uic8dmDKv9cMep2AIeAKcxgm51pkodWhyG)3XtGFGjV(rXza(GjIugtkhmpVqqlufZeOuiEBm9lgmDKv9cMqMeZRjHwTrad8)(ab8dm51pkodWhmrKYys5G5YFyYrL80yhTqTYTsX00vAk3MgYKyEnj0QnsBfc3AJOjXIPPL)WKJk5PXo64HmPX6LPjXIPPL)WKJk5PXoA4qIhVScmDKv9cMJkvouewEASdWagy6XJcf4h4)DWpWKx)O4maFWerkJjLdMNxiOpQhr2bP5QEH6xmnDLMoVqqFupISdsZv9c1egZRfstFPPiugmDKv9cMy9g1nKLNYyGb(pyWpWKx)O4maFWerkJjLdMNxiOpQhr2bP5QEH6xmnDLMoVqqFupISdsZv9c1egZRfstFPPiugmDKv9cMep2AIeAKcxgyG)da8dm51pkodWhmrKYys5G5T0uUnnKjX8AsOvBK2keU1gbMoYQEbtitI51KqR2iGb(FJGFGPJSQxW0LypsMjYoirKEeem51pkodWhyG)Fc(bM86hfNb4dMiszmPCWm8ukjHrdDselTcJPPV00D9N00GOPiuMMelMMcn6bPPX0eYHMKWr8stFPPqJEqnM)bnDLMebAA5pm5OsEASJwOw5wPyA6knLBtdzsmVMeA1gPTcHBTr00vAk3MgYKyEnj0Qnst4aHHd9JIPjXIPPL)WKJk5PXo64HmPX6LPPR00T005fcASEJ6gYYWJiQ(fttxPPqJEqAAmnHCOjjCeV00xAk0OhuJ5Fqt3an5iR6vJBPusuJH5BwJCOjjCeV00GOPbqt4ny6iR6fmhvQCOiS80yhGb(FtGFGPJSQxWe1njxRBCw6qO)ugyYRFuCgGpWa)frGFGjV(rXza(GjIugtkhmpVqqJ1Bu3qwgEer1egZRfstxPPL)WKJk5PXo64HmPX6LbthzvVGjwVrDdz5PmgyG)4jWpWKx)O4maFWerkJjLdMHNsjjmAOtIyPvymn9LMUR)KMgenfHY00vAk0OhKMgttihAschXln9LMcn6b1y(h00nqtdwKGPJSQxWe3sPKOgdZ3mWa)hiGFGjV(rXza(GjIugtkhmdn6bPPX0eYHMKWr8stFPPqJEqnM)by6iR6fmHgZkPr8yGb(FxKGFGjV(rXza(GjIugtkhmpVqqBvSSdsBilHXSt0qZr4stcOPbqtIftt520WHepEzL80yhTviCRncmDKv9cMep2AIeAKcxgyG)3Vd(bM86hfNb4dMiszmPCWm3MgoK4XlRKNg7OTcHBTrGPJSQxWeR3OUHS8ugdmW)7dg8dm51pkodWhmrKYys5G5YFyYrL80yhnCiXJxwrtxPPqJEqAcpOPbisA6knLBtdzsmVMeA1gPjmMxlKMWdA6tAAq0uekdMoYQEbZrLkhkclpn2byG)3ha4hyYRFuCgGpyIiLXKYbZBPPZle0y9g1nKLHhrunHX8AHGPJSQxWen0XL4yqGb(F)gb)atE9JIZa8btePmMuoys4aHHd9JIbthzvVGjKjX8AsOvBeWa)V)j4hyYRFuCgGpyIiLXKYbZqJEqAAmnHCOjjCeV00xAk0OhuJ5FqtxPjrGMoVqqJ1Bu3qwgEer1qZr4stFPPpPjXIPPqJEqA6ln5iR6vJ1Bu3qwEkJ1OgA0eEdMoYQEbtClLsIAmmFZad8)(nb(bMoYQEbtIhBnrcnsHldM86hfNb4dmW)7IiWpWKx)O4maFWerkJjLdMNxiOX6nQBildpIO6xmnjwmnfA0dst4bnDJIKMelMMYTPHdjE8Yk5PXoARq4wBey6iR6fmX6nQBilpLXad8)oEc8dm51pkodWhmrKYys5G5YFyYrL80yhTqTYTsX00vAk3MgYKyEnj0QnsBfc3AJOjXIPPL)WKJk5PXo64HmPX6LPjXIPPL)WKJk5PXoA4qIhVSIMUstHg9G0eEqtFksW0rw1lyoQu5qry5PXoadyGzmHrn2XnWpW)7GFGPJSQxWe(WW6vgZgyYRFuCgGpWa)hm4hyYRFuCgGpyUogdMoEbh6ehkd9AYoiJ7rmbmDKv9cMoEbh6ehkd9AYoiJ7rmbyG)da8dm51pkodWhmDKv9cMirrQ2i9wi5r5qdmrKYys5G5T0eXRSKfIxtxRqp1Ye)Oyn)rbniyYHaJm56ymyIefPAJ0BHKhLdnGb(FJGFGPJSQxWm65KC5RSdshVysBdbtE9JIZa8bg4)NGFGPJSQxWe1njxRBCw6qO)ugyYRFuCgGpWa)VjWpW0rw1lyoQjQSqCTscd71xedM86hfNb4dmWFre4hyYRFuCgGpy6iR6fmJBR6fmZIUowHKXeoUnW8oWa)XtGFGPJSQxWeAmRKgXJbtE9JIZa8bg4)ab8dmDKv9cMdDsC3lyYRFuCgGpWagyIYqWpW)7GFGjV(rXza(GjIugtkhmrDRY9OvJ6MKR1nolDi0FkttymVwinHh00aejy6iR6fmpQUZYWJikWa)hm4hyYRFuCgGpyIiLXKYbtu3QCpA1OUj5ADJZshc9NY0egZRfst4bnnarcMoYQEbtFrm0iUsICLcyG)da8dm51pkodWhmrKYys5GjQBvUhTAu3KCTUXzPdH(tzAcJ51cPj8GMgGibthzvVGzOi8r1DgyG)3i4hy6iR6fmvv0qdkhOVCegVgyYRFuCgGpWa))e8dm51pkodWhmrKYys5GjQBvUhTAu3KCTUXzPdH(tzAcJ51cPj8GMUjrstIfttwHXsRL5IPPV009baMoYQEbZdtGmb3AJag4)nb(bM86hfNb4dMiszmPCW88cbD0Zj5YxzhKoEXK2gQFX00vAseOPZle0hMazcU1gPFX0KyX005fc6JQ7Sm8iIQFX0KyX00T0eXrS2iTsrt4nnjwmnjc0eQx4dZpkwh3w1RSdY3EivwXzz4reLMUstwHXsRL5IPPV00nDNMelMMScJLwlZfttFPPbFt0eEttIftt3stmeYlI1OEZ8c5Suvbo0eeRX8bAtOPR005fcAu3KCTUXzPdH(tz6xmy6iR6fmJBR6fyG)IiWpWKx)O4maFWerkJjLdMMtIytNlO5lIPj8qanDtGPJSQxW0HXmYKDqAdzj7rkgyG)4jWpWKx)O4maFW0rw1ly6WHc5ldLehVAIe1exbMiszmPCWKVzEvCmN1zsDoQAJK1IBCNPPR0Kiqtz(8cbnXXRMirnXvYmFEHGo3JwAsSyAYkmwATmgzYbisA6lnDNMelMMebAAi7kBOogz00xAAaIKMUstNxiOJEojx(k7G0XlM02q9lMMelMMoVqqJXynruzhKQhQYYmHDmO(ftt4nnH30KyX0Kiqt3st8nZRIJ5SotQZrvBKSwCJ7mnDLMebA68cbngJ1erLDqQEOklZe2XG6xmnjwmnDEHGo65KC5RSdshVysBd1VyA6knH6wL7rRo65KC5RSdshVysBd1egZRfst4bnDxe9jnH30KyX0uMpVqqtC8QjsutCLmZNxiOZ9OLMWBAsSyAYkmwATmxmn9LMgSibZ1XyW0HdfYxgkjoE1ejQjUcyG)deWpWKx)O4maFW0rw1lyg5kg5kftGYt3lyIiLXKYbtu3QCpA1ymwtev2bP6HQSmtyhdQjmMxlKMelMMmxXRPhvQCOiSS2Wdw9Q51pkottxPju3QCpA1OUj5ADJZshc9NY0egZRfstIftt3stmeYlI1ymwtev2bP6HQSmtyhdQX8bAtOPR0eQBvUhTAu3KCTUXzPdH(tzAcJ51cbZ1XyWmYvmYvkMaLNUxGb(FxKGFGjV(rXza(G56ymy64fCOtCOm0Rj7GmUhXeW0rw1ly64fCOtCOm0Rj7GmUhXeGb(F)o4hy6iR6fmdn6b5S0XlMuglpSJbM86hfNb4dmW)7dg8dm51pkodWhmrKYys5G55fcAu3KCTUXzPdH(tz6xmy6iR6fmpQUZYoiTHSKxgtuGb(FFaGFGPJSQxWm(rQGO1gjpkhAGjV(rXza(ad8)(nc(bMoYQEbZONtYLVYoiD8IjTnem51pkodWhyG)3)e8dmDKv9cMKkowXYALWyhXGjV(rXza(ad8)(nb(bM86hfNb4dMiszmPCWm8ukjHrdDselTcJPPV00DAAq0uekdMoYQEbtuViEnIBCwguogdmW)7IiWpWKx)O4maFWerkJjLdMNxiOjmcxfdHYqtqS(fdMoYQEbtBilF7PFBwgAcIbg4)D8e4hy6iR6fmh1evwiUwjHH96lIbtE9JIZa8bg4)9bc4hyYRFuCgGpyIiLXKYbtZjrSPhYUYgQJrgnHh0eEsK0KyX0K5Ki20dzxzd1XiJM(kGMgSiPjXIPjZjrSPTcJLwlJrMCWIKMWdAAaIemDKv9cMe2JRnsguogdbg4)Gfj4hyYRFuCgGpyIiLXKYbtgc5fXAmgRjIk7Gu9qvwMjSJb1y(aTj00vA6wAc1Tk3JwngJ1erLDqQEOklZe2XGAcJ51cbthzvVGjwVrDdz5PmgyG)d(o4hyYRFuCgGpyIiLXKYbtgc5fXAmgRjIk7Gu9qvwMjSJb1y(aTj00vAk8ukjHrdDselTcJPPV00D9N00GOPiuMMUstHg9G00xAYrw1RgR3OUHS8ugRrn0OPR00T0eQBvUhTAmgRjIk7Gu9qvwMjSJb1egZRfcMoYQEbZrLkhkclpn2byG)dEWGFGjV(rXza(GjIugtkhmdn6bPPV0KJSQxnwVrDdz5PmwJAOrtxPPZle0OUj5ADJZshc9NY0VyW0rw1lyIXynruzhKQhQYYmHDmiWagyM5G)ug4h4)DWpWKx)O4maFWerkJjLdMz(8cbnYHwTr6xmnjwmnDEHGoxWywP8JILyEuH0VyAsSyA68cbDUGXSs5hfl5L4rS(fdMoYQEbtKRushzvVsvbnWuvqtUogdMpRuLjkWa)hm4hy6iR6fmFqwwgJbbtE9JIZa8bg4)aa)atE9JIZa8bthzvVGjYvkPJSQxPQGgyQkOjxhJbtugcmW)Be8dm51pkodWhmrKYys5GPJSsiwYlJvmKMeqt3PPR0KiqtMR410UkEOlJjC2TMO51pkottxPjRWyP1YCX00xA6UiPjXIPjRWyP1YCX00xA6tAcVbthzvVGjwVrDdz5PmgyG)Fc(bM86hfNb4dMiszmPCW0rwjel5LXkgstFPPbqtxPjZv8AA0qhxIJb186hfNPPR0K5kEnTRIh6YycNDRjAE9JIZGPJSQxWe5kL0rw1Ruvqdmvf0KRJXGPhpkuad8)Ma)atE9JIZa8btePmMuoy6iReIL8YyfdPPV00aOPR0K5kEnnAOJlXXGAE9JIZGPJSQxWe5kL0rw1Ruvqdmvf0KRJXG5OqbmWFre4hyYRFuCgGpyIiLXKYbthzLqSKxgRyin9LMganDLMULMmxXRPDv8qxgt4SBnrZRFuCMMUst3stMR410JkvouewwB4bRE186hfNbthzvVGjYvkPJSQxPQGgyQkOjxhJbtObmWF8e4hyYRFuCgGpyIiLXKYbthzLqSKxgRyin9LMganDLMmxXRPDv8qxgt4SBnrZRFuCMMUst3stMR410JkvouewwB4bRE186hfNbthzvVGjYvkPJSQxPQGgyQkOjxhJbtpgAad8FGa(bM86hfNb4dMiszmPCW0rwjel5LXkgstFPPbqtxPjZv8AAxfp0LXeo7wt086hfNPPR0K5kEn9OsLdfHL1gEWQxnV(rXzW0rw1lyICLs6iR6vQkObMQcAY1XyW0JhfkGb(FxKGFGjV(rXza(GjIugtkhmDKvcXsEzSIH00xAAa00vA6wAYCfVM2vXdDzmHZU1enV(rXzA6knzUIxtpQu5qryzTHhS6vZRFuCgmDKv9cMixPKoYQELQcAGPQGMCDmgmhfkGb(F)o4hyYRFuCgGpyIiLXKYbthzLqSKxgRyinHh00DA6knDlnzUIxtFksgk7GmMWIQ51pkottIfttoYkHyjVmwXqAcpOPbdMoYQEbtKRushzvVsvbnWuvqtUogdMif7cXad8)(Gb)athzvVGjQxeVgXnoldkhJbtE9JIZa8bg4)9ba(bMoYQEbtNG8LLwti8AGjV(rXza(ad8)(nc(bMoYQEbZJhj7G0ifcxiyYRFuCgGpWagy(SsvMOGFG)3b)athzvVGj2dVWlfdM86hfNb4dmW)bd(bMoYQEbtit4TmrL5h0atE9JIZa8bg4)aa)athzvVGjmUjSeP6xgm51pkodWhyG)3i4hy6iR6fmHDBdRnsoYnMaM86hfNb4dmW)pb)athzvVGjS3cjpkhAGjV(rXza(ad8)Ma)athzvVG5Y2qMiHdBeUGjV(rXza(ad8xeb(bMoYQEbt0WAGwqPr89M5vQYefm51pkodWhyG)4jWpW0rw1lycJlszs4WgHlyYRFuCgGpWa)hiGFGPJSQxWCD7ryOmI4igm51pkodWhyadyGPqmbw9c(pyroyrkYbp4baMJCYwBeemXZblUjgNPPbcn5iR6LMuf0GA6fWegZiW)b)5NGzmPdLIbZbMMMpIqLqUIMeX)wJj0ldmnn0Sy4nlo4ev2W3rJAmCGf2t5w1lI4bdhyHHWHEzGPjrmNGgst3fMMgSihSiPxOxgyA6MBOVrm8MLEzGPPBGMWZYzottIyp8cVumnznnL5G)ugn5iR6LMuf000ldmnDd00n3qFJ4mnzojInzfOj(JycdHvVqAYAAcjksXsZjrSb10ldmnDd0KiwNRqXzAc5eHyjktOjRPPrnbxAcRjmnXoSuIstJkBinzdzAYZ5EXZdstfwSIX41CR6LM6anjKtk)Oyn9Yatt3anHNLZCMMEwPktuAcpdp3B(A6f6LbMMeX9bJEgNPPdhActtOg74gnD4OAHAAcpdH4ydstBV3WqNGfEkAYrw1lKM6vjQMEzGPjhzvVqDmHrn2XnbbLdXLEzGPjhzvVqDmHrn2XTXcWXFry8AUv9sVmW0KJSQxOoMWOg742yb4e6otV4iR6fQJjmQXoUnwaoWhgwVYy2OxgyAAUEmCyB0eXRmnDEHaNPjO5gKMoCOjmnHASJB00HJQfst(MPPycFdXTz1grtfKMY9YA6LbMMCKv9c1Xeg1yh3glah46XWHTjHMBq6fhzvVqDmHrn2XTXcW5bzzzmMWRJXcC8co0joug61KDqg3Jyc9IJSQxOoMWOg742yb48GSSmgtyoeyKjxhJfGefPAJ0BHKhLdnHRGGBjELLSq8A6Af6PwM4hfR5pkObPxCKv9c1Xeg1yh3glaNONtYLVYoiD8IjTnKEXrw1luhtyuJDCBSaCqDtY16gNLoe6pLrV4iR6fQJjmQXoUnwaoJAIklexRKWWE9fX0loYQEH6ycJASJBJfGtCBvVcNfDDScjJjCCBcUtV4iR6fQJjmQXoUnwaoqJzL0iEm9IJSQxOoMWOg742yb4m0jXDV0l0loYQEH6NvQYeva2dVWlftV4iR6fQFwPkt0XcWbYeEltuz(bn6fhzvVq9ZkvzIowaoW4MWsKQFz6fhzvVq9ZkvzIowaoWUTH1gjh5gtOxCKv9c1pRuLj6yb4a7TqYJYHg9IJSQxO(zLQmrhlaNLTHmrch2iCPxCKv9c1pRuLj6yb4Ggwd0cknIV3mVsvMO0loYQEH6NvQYeDSaCGXfPmjCyJWLEXrw1lu)SsvMOJfGZ62JWqzeXrm9c9YattI4(GrpJZ0eleteLMScJPjBittoYAcnvqAYfYlLFuSMEXrw1luaYvkPJSQxPQGMWRJXcEwPktuHRGGmFEHGg5qR2i9lwS4Zle05cgZkLFuSeZJkK(flw85fc6CbJzLYpkwYlXJy9lMEXrw1lCSaCEqwwgJbPxCKv9chlahKRushzvVsvbnHxhJfGYq6fhzvVWXcWbR3OUHS8uglCfe4iReIL8YyfdfC)QiyUIxt7Q4HUmMWz3AIMx)O48vRWyP1YCXFVlsXITcJLwlZf)9t8MEXrw1lCSaCqUsjDKv9kvf0eEDmwGhpkucxbboYkHyjVmwXWVd4Q5kEnnAOJlXXGAE9JIZxnxXRPDv8qxgt4SBnrZRFuCMEXrw1lCSaCqUsjDKv9kvf0eEDmwWOqjCfe4iReIL8Yyfd)oGRMR410OHoUehdQ51pkotV4iR6fowaoixPKoYQELQcAcVoglaAcxbboYkHyjVmwXWVd46TMR410UkEOlJjC2TMO51pkoF9wZv8A6rLkhkclRn8GvVAE9JIZ0loYQEHJfGdYvkPJSQxPQGMWRJXc8yOjCfe4iReIL8Yyfd)oGRMR410UkEOlJjC2TMO51pkoF9wZv8A6rLkhkclRn8GvVAE9JIZ0loYQEHJfGdYvkPJSQxPQGMWRJXc84rHs4kiWrwjel5LXkg(DaxnxXRPDv8qxgt4SBnrZRFuC(Q5kEn9OsLdfHL1gEWQxnV(rXz6fhzvVWXcWb5kL0rw1Ruvqt41XybJcLWvqGJSsiwYlJvm87aUER5kEnTRIh6YycNDRjAE9JIZxnxXRPhvQCOiSS2Wdw9Q51pkotV4iR6fowaoixPKoYQELQcAcVoglaPyxiw4kiWrwjel5LXkgIh3VER5kEn9PizOSdYyclQMx)O4SyXoYkHyjVmwXq8yW0loYQEHJfGdQxeVgXnoldkhJPxCKv9chlahNG8LLwti8A0loYQEHJfGZXJKDqAKcHlKEHEXrw1lu7XqtawVrDdz5Pmw4ki48cbnQBsUw34S0Hq)Pm9l(QiCEHGg1njxRBCw6qO)uMMWyETWV31FoOiuwS4Zle0h1Ji7G0CvVq9l(65fc6J6rKDqAUQxOMWyETWV31FoOiugVPxCKv9c1Em0glahIhBnrcnsHllCfeCEHGg1njxRBCw6qO)uM(fFveoVqqJ6MKR1nolDi0FkttymVw4376phueklw85fc6J6rKDqAUQxO(fF98cb9r9iYoinx1lutymVw4376phuekJ30loYQEHApgAJfGtq5lU1gjHgPWLfUcccn6bhJCOjjCeVFdn6b1y(h0loYQEHApgAJfGdULsjrngMVzHrIIuS0CseBqb3fUcccpLssy0qNeXsRW4V31FoOiu(AOrp4yKdnjHJ49BOrpOgZ)GEXrw1lu7XqBSaCGgZkPr8yHRGGqJEWXihAschX73qJEqnM)b9IJSQxO2JH2yb4mQu5qry5PXocxbbHg9GJro0KeoI3VHg9GAm)JR3Afc3AJUE75fcAmgRjIk7Gu9qvwMjSJb1V4RIq4PuscJg6KiwAfg)9U(ZbfHYIfFBUn9OsLdfHLNg7OTcHBTrxV98cbnQBsUw34S0Hq)Pm9lwS4BZTPhvQCOiS80yhTviCRn665fcASEJ6gYYWJiQgAoc3V3XBXITcJLwlZf)9oE66T520JkvouewEASJ2keU1grV4iR6fQ9yOnwaoqMeZRjHwTrcxbb3MBtdzsmVMeA1gPTcHBTrxV98cbnQBsUw34S0Hq)Pm9lMEXrw1lu7XqBSaCWTukjQXW8nlmsuKILMtIydk4UWvqqOrp4yKdnjHJ49BOrpOgZ)4QiCEHGgR3OUHSm8iIQHMJW97NIfhA0d(1rw1RgR3OUHS8ugRrn0WB6fhzvVqThdTXcWbYKyEnj0Qns4kiGWbcdh6hfF92Zle0OUj5ADJZshc9NY0V4RNxiOX6nQBildpIOAO5iC)(j9IJSQxO2JH2yb44sShjZezhKispckCfeC75fcAu3KCTUXzPdH(tz6xm9IJSQxO2JH2yb4G6MKR1nolDi0Fkt4ki42Zle0OUj5ADJZshc9NY0Vy6fhzvVqThdTXcWbR3OUHS8uglCfeCEHGgR3OUHSm8iIQFXIfhA0dog5qts4iEXJqJEqnM)XnCxKIfFEHGg1njxRBCw6qO)uM(ftV4iR6fQ9yOnwaoep2AIeAKcxMEXrw1lu7XqBSaCgvQCOiS80yhHRGGBTcHBTr0l0loYQEHApEuOeG1Bu3qwEkJfUccoVqqFupISdsZv9c1V4RNxiOpQhr2bP5QEHAcJ51c)gHY0loYQEHApEuOglahIhBnrcnsHllCfeCEHG(OEezhKMR6fQFXxpVqqFupISdsZv9c1egZRf(ncLPxCKv9c1E8OqnwaoqMeZRjHwTrcxbb3MBtdzsmVMeA1gPTcHBTr0loYQEHApEuOglahxI9izMi7Ger6rq6fhzvVqThpkuJfGZOsLdfHLNg7iCfeeEkLKWOHojILwHXFVR)CqrOSyXHg9GJro0KeoI3VHg9GAm)JRIWYFyYrL80yhTqTYTsXxZTPHmjMxtcTAJ0wHWT2OR520qMeZRjHwTrAchimCOFuSyXl)HjhvYtJD0XdzsJ1lF92Zle0y9g1nKLHhru9l(AOrp4yKdnjHJ49BOrpOgZ)4gCKv9QXTukjQXW8nRro0KeoI3bna8MEXrw1lu7XJc1yb4G6MKR1nolDi0FkJEXrw1lu7XJc1yb4G1Bu3qwEkJfUccoVqqJ1Bu3qwgEer1egZRfED5pm5OsEASJoEitASEz6fhzvVqThpkuJfGdULsjrngMVzHRGGWtPKegn0jrS0km(7D9NdkcLVgA0dog5qts4iE)gA0dQX8pUHbls6fhzvVqThpkuJfGd0ywjnIhlCfeeA0dog5qts4iE)gA0dQX8pOxCKv9c1E8Oqnwaoep2AIeAKcxw4ki48cbTvXYoiTHSegZordnhHRGbiwCUnnCiXJxwjpn2rBfc3AJOxCKv9c1E8Oqnwaoy9g1nKLNYyHRGGCBA4qIhVSsEASJ2keU1grV4iR6fQ94rHASaCgvQCOiS80yhHRGGL)WKJk5PXoA4qIhVS6AOrpiEmarEn3MgYKyEnj0QnstymVwiE85GIqz6fhzvVqThpkuJfGdAOJlXXGcxbb3EEHGgR3OUHSm8iIQjmMxlKEXrw1lu7XJc1yb4azsmVMeA1gjCfeq4aHHd9JIPxCKv9c1E8Oqnwao4wkLe1yy(MfUcccn6bhJCOjjCeVFdn6b1y(hxfHZle0y9g1nKLHhrun0CeUF)uS4qJEWVoYQE1y9g1nKLNYynQHgEtV4iR6fQ94rHASaCiES1ej0ifUm9IJSQxO2JhfQXcWbR3OUHS8uglCfeCEHGgR3OUHSm8iIQFXIfhA0dIh3Oiflo3MgoK4XlRKNg7OTcHBTr0loYQEHApEuOglaNrLkhkclpn2r4kiy5pm5OsEASJwOw5wP4R520qMeZRjHwTrARq4wBKyXl)HjhvYtJD0XdzsJ1llw8YFyYrL80yhnCiXJxwDn0Ohep(uK0l0loYQEHAugk4O6oldpIOcxbbOUv5E0QrDtY16gNLoe6pLPjmMxlepgGiPxCKv9c1OmCSaC8fXqJ4kjYvkHRGau3QCpA1OUj5ADJZshc9NY0egZRfIhdqK0loYQEHAugowaoHIWhv3zHRGau3QCpA1OUj5ADJZshc9NY0egZRfIhdqK0loYQEHAugowaoQkAObLd0xocJxJEXrw1luJYWXcW5WeitWT2iHRGau3QCpA1OUj5ADJZshc9NY0egZRfIh3Kifl2kmwATmx837dGEXrw1luJYWXcWjUTQxHRGGZle0rpNKlFLDq64ftABO(fFveoVqqFycKj4wBK(flw85fc6JQ7Sm8iIQFXIfFlXrS2iTsH3IflcOEHpm)OyDCBvVYoiF7HuzfNLHhr0RwHXsRL5I)Et3fl2kmwATmx83bFt4TyX3YqiViwJ6nZlKZsvf4qtqSgZhOn565fcAu3KCTUXzPdH(tz6xm9IJSQxOgLHJfGJdJzKj7G0gYs2JuSWvqG5Ki205cA(Iy8qWnrV4iR6fQrz4yb48GSSmgt41XyboCOq(YqjXXRMirnXvcxbb8nZRIJ5SotQZrvBKSwCJ78vriZNxiOjoE1ejQjUsM5Zle05E0kwSvyS0AzmYKdqKFVlwSimKDLnuhJSVdqKxpVqqh9CsU8v2bPJxmPTH6xSyXNxiOXySMiQSds1dvzzMWogu)IXB8wSyr4w(M5vXXCwNj15OQnswlUXD(QiCEHGgJXAIOYoivpuLLzc7yq9lwS4Zle0rpNKlFLDq64ftABO(fFf1Tk3JwD0Zj5YxzhKoEXK2gQjmMxlepUlI(eVfloZNxiOjoE1ejQjUsM5Zle05E0I3IfBfglTwMl(7Gfj9IJSQxOgLHJfGZdYYYymHxhJfe5kg5kftGYt3RWvqaQBvUhTAmgRjIk7Gu9qvwMjSJb1egZRfkwS5kEn9OsLdfHL1gEWQxnV(rX5ROUv5E0QrDtY16gNLoe6pLPjmMxluS4BziKxeRXySMiQSds1dvzzMWoguJ5d0MCf1Tk3JwnQBsUw34S0Hq)PmnHX8AH0loYQEHAugowaopillJXeEDmwGJxWHoXHYqVMSdY4EetOxCKv9c1OmCSaCcn6b5S0XlMuglpSJrV4iR6fQrz4yb4CuDNLDqAdzjVmMOcxbbNxiOrDtY16gNLoe6pLPFX0loYQEHAugowaoXpsfeT2i5r5qJEXrw1luJYWXcWj65KC5RSdshVysBdPxCKv9c1OmCSaCivCSIL1kHXoIPxCKv9c1OmCSaCq9I41iUXzzq5ySWvqq4PuscJg6KiwAfg)9(GIqz6fhzvVqnkdhlahBilF7PFBwgAcIfUccoVqqtyeUkgcLHMGy9lMEXrw1luJYWXcWzutuzH4ALeg2RViMEXrw1luJYWXcWHWECTrYGYXyOWvqG5Ki20dzxzd1XidpWtIuSyZjrSPhYUYgQJr2xbdwKIfBojInTvyS0AzmYKdwK4Xaej9IJSQxOgLHJfGdwVrDdz5Pmw4kiGHqErSgJXAIOYoivpuLLzc7yqnMpqBY1BrDRY9OvJXynruzhKQhQYYmHDmOMWyETq6fhzvVqnkdhlaNrLkhkclpn2r4kiGHqErSgJXAIOYoivpuLLzc7yqnMpqBY1WtPKegn0jrS0km(7D9NdkcLVgA0d(1rw1RgR3OUHS8ugRrn0UElQBvUhTAmgRjIk7Gu9qvwMjSJb1egZRfsV4iR6fQrz4yb4GXynruzhKQhQYYmHDmOWvqqOrp4xhzvVASEJ6gYYtzSg1q765fcAu3KCTUXzPdH(tz6xm9c9IJSQxOgPyxiwGqoP8JIfEDmwaYjcXsuMiChlaYwfewix9yboYkHyjVmwXqHfYvpwYkil4tHr9MlR6vGJSsiwYlJvm87N0loYQEHAKIDH4XcWXLypsMjYoirKEeKEXrw1luJuSlepwaoOUj5ADJZshc9NYOxCKv9c1if7cXJfGdYjcXcxbb520WHepEzL80yhTviCRnIEXrw1luJuSlepwaoJkvouewEASJWvqWTMR410rpMqkLYLMJScb186hfNflo8ukjHrdDselTcJ)gHY0loYQEHAKIDH4XcWbR3OUHS8uglmsuKILMtIydk4UWvqqMpVqqRCJxtg3fSxn0CeUcUls6fhzvVqnsXUq8yb4Gg64sCmi9IJSQxOgPyxiESaCWTukjQXW8nlmsuKILMtIydk4UWvqqOrp4yKdnjHJ49BOrpOgZ)GEXrw1luJuSlepwaoNNHgYerfUcccpLssy0qNeXsRW4VrOSyX3AUIxtpQu5qryzTHhS6vZRFuCwS4CBA4qIhVSsEASJ2keU1gDn3MUwJjRRKhfZ5AJ0qZr4(Da0loYQEHAKIDH4XcWb5eHyHRGaZv8A6OhtiLs5sZrwHGAE9JIZ0loYQEHAKIDH4XcWjO8f3AJKqJu4YcxbbHg9GJro0KeoI3VHg9GAm)d6fhzvVqnsXUq8yb4mQu5qry5PXocxbb520JkvouewEASJMWbcdh6hflwS5kEn9OsLdfHL1gEWQxnV(rXz6fhzvVqnsXUq8yb4azsmVMeA1gjmsuKILMtIydk4UWvqW5fcAHQyMaLcXBJPjSJm6fhzvVqnsXUq8yb4GCIqSWvqaQBvUhT6rLkhkclpn2rtymVwiEiKtk)OynYjcXsuMCZBW0loYQEHAKIDH4XcWbAmRKgXJPxCKv9c1if7cXJfGZqNe39kCfeyUIxtBmbdk7GK3ipIX41086hfNPxCKv9c1if7cXJfGdKjX8AsOvBKWirrkwAojInOG7cxbbeoqy4q)O4RNxiOTkw2bPnKLWy2jAO5iC)oa6LbMM(10eSWEk3yA6b9iMMcnHMeX6nQBitt4xgttnHMWZ3JTMqttJu4Y0u(rQnIMWZGXmYOPoqt2qMMeX5rkwyAc1XIstSJgstnc9ieErmn1bAYgY0KJSQxAY3mn5XX8MPjj7rkMMSMMSHmn5iR6LMwhJ10loYQEHAKIDH4XcWbR3OUHS8uglmsuKILMtIydk4o9IJSQxOgPyxiESaCiES1ej0ifUSWirrkwAojInOG70l0loYQEHAOjyOtI7EfUccmxXRPnMGbLDqYBKhXy8AAE9JIZ0loYQEHAOnwaobLV4wBKeAKcxw4kii0OhCmYHMKWr8(n0OhuJ5FqV4iR6fQH2yb4q8yRjsOrkCzHRGGZle0OUj5ADJZshc9NY0V4RIW5fcAu3KCTUXzPdH(tzAcJ51c)Ex)5GIqzXIpVqqFupISdsZv9c1V4RNxiOpQhr2bP5QEHAcJ51c)Ex)5GIqz8MEzGPPFnnblSNYnMMEqpIPPqtOjrSEJ6gY0e(LX0utOj889yRj000ifUmnLFKAJOj8mymJmAQd0KnKPjrCEKIfMMqDSO0e7OH0uJqpcHxettDGMSHmn5iR6LM8nttECmVzAsYEKIPjRPjBittoYQEPP1Xyn9IJSQxOgAJfGdwVrDdz5Pmw4ki48cbnQBsUw34S0Hq)Pm9l(QiCEHGg1njxRBCw6qO)uMMWyETWV31FoOiuwS4Zle0h1Ji7G0CvVq9l(65fc6J6rKDqAUQxOMWyETWV31FoOiugVPxCKv9c1qBSaCWTukjQXW8nlmsuKILMtIydk4UWvqqOrp4yKdnjHJ49BOrpOgZ)GEXrw1ludTXcWbYKyEnj0Qns4ki48cbTqvmtGsH4TX0V4RNxiOfQIzcukeVnMMWyETWV3huektV4iR6fQH2yb4anMvsJ4XcxbbHg9GJro0KeoI3VHg9GAm)d6fhzvVqn0glaNrLkhkclpn2r4kii0OhCmYHMKWr8(n0OhuJ5FC9wRq4wB01BpVqqJXynruzhKQhQYYmHDmO(fFvecpLssy0qNeXsRW4V31FoOiuwS4BZTPhvQCOiS80yhTviCRn66TNxiOrDtY16gNLoe6pLPFXIfFBUn9OsLdfHLNg7OTcHBTrxpVqqJ1Bu3qwgEer1qZr4(9oElwSvyS0AzU4V3XtxVn3MEuPYHIWYtJD0wHWT2i6fhzvVqn0glahitI51KqR2iHRGGZle0cvXmbkfI3gt)IVMBtdzsmVMeA1gPjmMxl87noOiuwS4CBAitI51KqR2inHdego0pk(6TNxiOrDtY16gNLoe6pLPFX0loYQEHAOnwaoUe7rYmr2bjI0JGcxbb3EEHGg1njxRBCw6qO)uM(ftV4iR6fQH2yb4G6MKR1nolDi0Fkt4ki42Zle0OUj5ADJZshc9NY0Vy6fhzvVqn0glahSEJ6gYYtzSWvqW5fcASEJ6gYYWJiQ(flwCOrp4yKdnjHJ4fpcn6b1y(h3WGf5vZv8AAHQyMaLcXBJP51pkolwCOrp4yKdnjHJ4fpcn6b1y(h3W9RMR410gtWGYoi5nYJymEnnV(rXzXIpVqqJ6MKR1nolDi0Fkt)IPxCKv9c1qBSaCiES1ej0ifUm9IJSQxOgAJfGZOsLdfHLNg7iCfeKBtpQu5qry5PXoAchimCOFum9IJSQxOgAJfGdKjX8AsOvBKWvqW5fcAHQyMaLcXBJPFX0l0loYQEH6rHsWqNe39kCfeeA0dog5qts4iE)gA0dQX8pUAUIxtBmbdk7GK3ipIX41086hfNPxCKv9c1Jc1yb4G1Bu3qwEkJfUccoVqqFupISdsZv9c1V4RNxiOpQhr2bP5QEHAcJ51c)gHY0loYQEH6rHASaCiES1ej0ifUSWvqW5fc6J6rKDqAUQxO(fF98cb9r9iYoinx1lutymVw43iuMEXrw1lupkuJfGdKjX8AsOvBKWvqW5fcAHQyMaLcXBJPFXxpVqqlufZeOuiEBmnHX8AHFVR)CqrOSyX3MBtdzsmVMeA1gPTcHBTr0loYQEH6rHASaCgvQCOiS80yhHRGGWtPKegn0jrS0km(7D9NdkcLVgA0dog5qts4iE)gA0dQX8pelwew(dtoQKNg7OfQvUvk(AUnnKjX8AsOvBK2keU1gDn3MgYKyEnj0Qnst4aHHd9JIflE5pm5OsEASJoEitASE5R3EEHGgR3OUHSm8iIQFXxdn6bhJCOjjCeVFdn6b1y(h3GJSQxnULsjrngMVznYHMKWr8oObG30loYQEH6rHASaCWTukjQXW8nlCfeeA0dog5qts4iE)gA0dQX8pUHqJEqnHJ4LEXrw1lupkuJfGJlXEKmtKDqIi9ii9IJSQxOEuOglahOXSsAepw4kii0OhCmYHMKWr8(n0OhuJ5FqV4iR6fQhfQXcWzuPYHIWYtJDeUcccpLssy0qNeXsRW4V31FoOiuMEXrw1lupkuJfGdQBsUw34S0Hq)Pm6fhzvVq9OqnwaoqMeZRjHwTrcxbbNxiOfQIzcukeVnM(fFn3MgYKyEnj0QnstymVw43BCqrOm9IJSQxOEuOglahSEJ6gYYtzSWvqqUnnCiXJxwjpn2rBfc3AJel(8cbnwVrDdzz4revdnhHRGpPxCKv9c1Jc1yb4mQu5qry5PXocxbbl)HjhvYtJD0WHepEz11CBAitI51KqR2inHX8AH4XNdkcLPxCKv9c1Jc1yb4azsmVMeA1gjCfeq4aHHd9JIPxCKv9c1Jc1yb4Gg64sCmOWvqWTNxiOX6nQBildpIOAcJ51cPxCKv9c1Jc1yb4G1Bu3qwEkJPxCKv9c1Jc1yb4q8yRjsOrkCz6fhzvVq9OqnwaoqMeZRjHwTrcxbbNxiOfQIzcukeVnM(ftV4iR6fQhfQXcWzuPYHIWYtJDeUccw(dtoQKNg7OfQvUvk(AUnnKjX8AsOvBK2keU1gjw8YFyYrL80yhD8qM0y9YIfV8hMCujpn2rdhs84Lvadyaaa]] )


end