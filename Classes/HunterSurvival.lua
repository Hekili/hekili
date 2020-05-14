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
            nomounted = true,

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
        width = "full"
    } )  

    spec:RegisterPack( "Survival", 20200514, [[dCuu2bqirQEKifDjIIQSjfYNikkYOuuQtbLIvjsPxPiMfrPBjss7IKFbvzyefogu0Yej8mrsnnrsCnOuTnfL4BIuOXPOKohuk16GsjAEqj3Ji2NirhekL0cjsEiukHlsuuQrsuuvNKOOGvQOAMeff6Mefv2juPHsuuulLOOKEQQmvOI9c6VegmLomvlwLEmIjlQlJAZu8zrmAfPtlz1IuWRHQA2K62QQDR0VLA4k44efLy5qEoW0fUUk2ou47kuJxrX5jsTEIImFIQ9J0qmH4aFzpyiUPqgPqgYa7yMkkzGTLrksLub(cPhy4BWj47jm8T(NHV3bHrHHRHVbxAD7zioWhOpicdFtJyaGTep8sQy65Qi9hpq9pApQEji3e4bQpbp47EkDiZWcVWx2dgIBkKrkKHmWoMPIsgyBzKIuNkWNFIPnc(E1)O9O6fBbYnb8nTYzEHx4lZac8LMu77GWOWW1uRm)ZgmIopnP2PrmaWwIhEjvm9CvK(JhO(hThvVeKBc8a1NGhDEAsTYCU0ulMykl1MczKczqNtNNMul2IP(MWaSL05Pj1MQul2AoZzQvM7itYKMP2OP2mB8JoOwNevVuRUaHIopnP2uLAXwm13eotTHJs4qugQLNzaXaq1lGAJMAjst0SiCuchafDEAsTPk1kZ15YuCMAjocdwqYiQnAQDCJWNA)nIPw2bLwAQDCftP2yktTEo3RmtaQT(dA(ZB4r1l12gQfdhv(vZk680KAtvQfBnN5m1EIsxH0ul2QmZYmQGpDbcaeh4ZhabehiUycXb(41VAodLc(iOkyu5W39ymks3OCTEWzHda(rhQZa1oIANn1EpgJI0nkxRhCw4aGF0HcXFVwa1If1IPc7uBAP2esMALlNAVhJrD1hKOnIW19cuNbQDe1EpgJ6QpirBeHR7fOq83RfqTyrTyQWo1MwQnHKPwSb(Csu9cF)Et6gWIBfmmG4McioWhV(vZzOuWhbvbJkh(UhJrr6gLR1dolCaWp6qDgO2ru7SP27XyuKUr5A9GZcha8Joui(71cOwSOwmvyNAtl1MqYuRC5u79ymQR(GeTreUUxG6mqTJO27Xyux9bjAJiCDVafI)ETaQflQftf2P20sTjKm1InWNtIQx4d5drJeGav4ZWaIBQH4aF86xnNHsbFeufmQC4Z0KdGANqTeheceNWl1If1AAYbO((mWNtIQx4ZO9f)AteGav4ZWaIBQaXb(41VAodLc(Csu9cF4xATG0)VVz4JGQGrLdFMJwlqmzQJsyruFMAXIAXuHDQnTuBcjtTJOwttoaQDc1sCqiqCcVulwuRPjhG67ZaFePjAweokHdaexmHbexSdXb(41VAodLc(iOkyu5WNPjha1oHAjoieioHxQflQ10Kdq99zGpNevVWhiywlcKpadiUZceh4Jx)Q5muk4JGQGrLdFMMCau7eQL4GqG4eEPwSOwttoa13NHAhrTPtTrrWV2eQDe1Mo1EpgJ6Z)gjTOnc9HuzrgX(hOodu7iQD2uR5O1cetM6Oewe1NPwSOwmvyNAtl1MqYuRC5uB6uBUd14sNnfIf3(FvrrWV2eQDe1Mo1EpgJI0nkxRhCw4aGF0H6mqTYLtTPtT5ouJlD2uiwC7)vffb)AtO2ru79ymQFVjDdyH5GKwbcNGp1If1Ij1InuRC5uBuFweTixm1If1I5SsTJO20P2ChQXLoBkelU9)QIIGFTjWNtIQx4BCPZMcXIB)VWaIBAeId8XRF1Cgkf8rqvWOYHV0P2ChkaJg4neGO2evue8RnHAhrTPtT3JXOiDJY16bNfoa4hDOodWNtIQx4dWObEdbiQnbgqCNvioWhV(vZzOuWNtIQx4d)sRfK()9ndFeufmQC4Z0KdGANqTeheceNWl1If1AAYbO((mu7iQD2u79ymQFVjDdyH5GKwbcNGp1If1IDQvUCQ10KdGAXIADsu9Q(9M0nGf3kyfPbb1InWhrAIMfHJs4aaXftyaXfBdXb(41VAodLc(iOkyu5WhInigm1VAMAhrTPtT3JXOiDJY16bNfoa4hDOodu7iQ9Emg1V3KUbSWCqsRaHtWNAXIAXo85KO6f(amAG3qaIAtGbexmLbeh4Jx)Q5muk4JGQGrLdFPtT3JXOiDJY16bNfoa4hDOodWNtIQx4Zf)dkZirBeeupgadiUyIjeh4Jx)Q5muk4JGQGrLdFPtT3JXOiDJY16bNfoa4hDOodWNtIQx4J0nkxRhCw4aGF0bmG4IzkG4aF86xnNHsbFeufmQC47Emg1V3KUbSWCqsRoduRC5uRPjha1oHAjoieioHxQnLuRPjhG67ZqTPk1IPmOw5YP27XyuKUr5A9GZcha8JouNb4Zjr1l897nPBalUvWWaIlMPgId85KO6f(q(q0ibiqf(m8XRF1CgkfmG4IzQaXb(41VAodLc(iOkyu5Wx6uBue8Rnb(Csu9cFJlD2uiwC7)fgWa(iA2XGH4aXftioWhV(vZzOuWxpaFaokd85KO6f(WWrLF1m8HHJeR)z4J4imybjJGpcQcgvo85KOWGf8Y)Ibulwul2HpmC9HfSgWWh2HpmC9HHpNefgSGx(xmagqCtbeh4Zjr1l85I)bLzKOnccQhdGpE9RMZqPGbe3udXb(Csu9cFKUr5A9GZcha8JoGpE9RMZqPGbe3ubId8XRF1Cgkf8rqvWOYHVChkWuKpSSwC7)vffb)AtGpNevVWhXryWWaIl2H4aF86xnNHsbFeufmQC4lDQnCnVHk5WiuP1UiCsueGIx)Q5m1kxo1AoATaXKPokHfr9zQflQnHKHpNevVW34sNnfIf3(FHbe3zbId8XRF1Cgkf85KO6f((9M0nGf3ky4JGQGrLdFz(EmgL2dEdXqxGEvGWj4tTsOwmLb8rKMOzr4OeoaqCXegqCtJqCGpNevVWhzQJpY)a4Jx)Q5mukyaXDwH4aF86xnNHsbFojQEHp8lTwq6)33m8rqvWOYHpttoaQDc1sCqiqCcVulwuRPjhG67ZaFePjAweokHdaexmHbexSneh4Jx)Q5muk4JGQGrLdFMJwlqmzQJsyruFMAXIAtizQvUCQnDQnCnVHACPZMcXIAnhq1RIx)Q5m1kxo1M7qbMI8HL1IB)VQOi4xBc1oIAZDOQny06AXvZCU2efiCc(ulwuBQHpNevVW39eKPmsAyaXftzaXb(41VAodLc(iOkyu5Wx4AEdvYHrOsRDr4KOiafV(vZz4Zjr1l8rCegmmG4IjMqCGpE9RMZqPGpcQcgvo8zAYbqTtOwIdcbIt4LAXIAnn5auFFg4Zjr1l8z0(IFTjcqGk8zyaXfZuaXb(41VAodLc(iOkyu5WxUd14sNnfIf3(Fvi2GyWu)QzQvUCQnCnVHACPZMcXIAnhq1RIx)Q5m85KO6f(gx6SPqS42)lmG4IzQH4aF86xnNHsbFojQEHpaJg4neGO2e4JGQGrLdF3JXOWOgyeqGbV9xHyNeWhrAIMfHJs4aaXftyaXfZubId8XRF1Cgkf8rqvWOYHps36CpEvJlD2uiwC7)vH4VxlGAtj1IHJk)QzfXryWcsgrTY8O2uaFojQEHpIJWGHbexmXoeh4Zjr1l8bcM1Ia5dWhV(vZzOuWaIlMZceh4Jx)Q5muk4JGQGrLdFHR5nubJ(arBe8M4j8N3qXRF1Cg(Csu9cFtD0q3lmG4IzAeId8XRF1Cgkf85KO6f(amAG3qaIAtGpcQcgvo8HydIbt9RMP2ru79ymQOgeTretzbyGDKceobFQflQn1WhrAIMfHJs4aaXftyaXfZzfId8XRF1Cgkf85KO6f((9M0nGf3ky4JinrZIWrjCaG4IjmG4Ij2gId8XRF1Cgkf85KO6f(q(q0ibiqf(m8rKMOzr4OeoaqCXegWa(abehiUycXb(41VAodLc(iOkyu5Wx4AEdvWOpq0gbVjEc)5nu86xnNHpNevVW3uhn09cdiUPaId8XRF1Cgkf8rqvWOYHpttoaQDc1sCqiqCcVulwuRPjhG67ZaFojQEHpJ2x8RnracuHpddiUPgId8XRF1Cgkf8rqvWOYHV7XyuKUr5A9GZcha8JouNbQDe1oBQ9EmgfPBuUwp4SWba)OdfI)ETaQflQftf2P20sTjKm1kxo1EpgJ6QpirBeHR7fOodu7iQ9Emg1vFqI2icx3lqH4VxlGAXIAXuHDQnTuBcjtTyd85KO6f(q(q0ibiqf(mmG4MkqCGpE9RMZqPGpcQcgvo8DpgJI0nkxRhCw4aGF0H6mqTJO2ztT3JXOiDJY16bNfoa4hDOq83RfqTyrTyQWo1MwQnHKPw5YP27Xyux9bjAJiCDVa1zGAhrT3JXOU6ds0gr46Ebke)9AbulwulMkStTPLAtizQfBGpNevVW3V3KUbS4wbddiUyhId8XRF1Cgkf85KO6f(WV0AbP)FFZWhbvbJkh(mn5aO2julXbHaXj8sTyrTMMCaQVpd8rKMOzr4OeoaqCXegqCNfioWhV(vZzOuWhbvbJkh(UhJrHrnWiGadE7V6mqTJO27XyuyudmciWG3(Rq83RfqTyrTysTPLAtiz4Zjr1l8by0aVHae1MadiUPrioWhV(vZzOuWhbvbJkh(mn5aO2julXbHaXj8sTyrTMMCaQVpd85KO6f(abZArG8byaXDwH4aF86xnNHsbFeufmQC4Z0KdGANqTeheceNWl1If1AAYbO((mu7iQfXgedM6xntTJOwZrRfiMm1rjSiQptTyrTjKm1oIAtNAVhJr95FJKw0gH(qQSiJy)duNbQvUCQ10KdGANqTeheceNWl1If1AAYbO((mu7iQD2uB6uBUd14sNnfIf3(FvrrWV2eQDe1oBQnDQ9EmgfPBuUwp4SWba)Od1zGALlNAVhJr97nPBalmhK0kq4e8PwSOwmPw5YP2O(SiArUyQflQfZzLALlNAtNAZDOgx6SPqS42)Rkkc(1MqTJOwxMyufSACPZmAzaqaoimkmCTc5l(uBkPwzqTyd1Inu7iQnDQ9Emg1N)nsArBe6dPYImI9pqDgGpNevVW34sNnfIf3(FHbexSneh4Jx)Q5muk4JGQGrLdF3JXOWOgyeqGbV9xDgO2ruBUdfGrd8gcquBIcXFVwa1If1MkuBAP2esMALlNAZDOamAG3qaIAtui2GyWu)QzQDe1Mo1EpgJI0nkxRhCw4aGF0H6maFojQEHpaJg4neGO2eyaXftzaXb(41VAodLc(iOkyu5Wx6u79ymks3OCTEWzHda(rhQZa85KO6f(CX)GYms0gbb1JbWaIlMycXb(41VAodLc(iOkyu5Wx6u79ymks3OCTEWzHda(rhQZa85KO6f(iDJY16bNfoa4hDadiUyMcioWhV(vZzOuWhbvbJkh(UhJr97nPBalmhK0QZa1kxo1AAYbqTtOwIdcbIt4LAtj1AAYbO((muBQsTPqgu7iQnCnVHcJAGrabg82FfV(vZzQvUCQ10KdGANqTeheceNWl1MsQ10Kdq99zO2uLAXKAhrTHR5nubJ(arBe8M4j8N3qXRF1CMALlNAVhJrr6gLR1dolCaWp6qDgGpNevVW3V3KUbS4wbddiUyMAioWNtIQx4d5drJeGav4ZWhV(vZzOuWaIlMPceh4Jx)Q5muk4JGQGrLdF5ouJlD2uiwC7)vHydIbt9RMHpNevVW34sNnfIf3(FHbexmXoeh4Jx)Q5muk4JGQGrLdF3JXOWOgyeqGbV9xDgGpNevVWhGrd8gcquBcmGb8n2uqCG4Ijeh4Jx)Q5muk4JGQGrLdFMMCau7eQL4GqG4eEPwSOwttoa13NHAhrTHR5nubJ(arBe8M4j8N3qXRF1Cg(Csu9cFtD0q3lmG4McioWhV(vZzOuWhbvbJkh(UhJrD1hKOnIW19cuNbQDe1EpgJ6QpirBeHR7fOq83RfqTyrTjKm85KO6f((9M0nGf3kyyaXn1qCGpE9RMZqPGpcQcgvo8DpgJ6QpirBeHR7fOodu7iQ9Emg1vFqI2icx3lqH4VxlGAXIAtiz4Zjr1l8H8HOrcqGk8zyaXnvG4aF86xnNHsbFeufmQC47Emgfg1aJacm4T)QZa1oIAVhJrHrnWiGadE7VcXFVwa1If1IPc7uBAP2esMALlNAtNAZDOamAG3qaIAturrWV2e4Zjr1l8by0aVHae1MadiUyhId8XRF1Cgkf8rqvWOYHpZrRfiMm1rjSiQptTyrTyQWo1MwQnHKP2ruRPjha1oHAjoieioHxQflQ10Kdq99zOw5YP2ztTlptigxIB)VkmAThLMP2ruBUdfGrd8gcquBIkkc(1MqTJO2ChkaJg4neGO2efInigm1VAMALlNAxEMqmUe3(Fvdtzu)7LP2ruB6u79ymQFVjDdyH5GKwDgO2ruRPjha1oHAjoieioHxQflQ10Kdq99zO2uLADsu9QWV0AbP)FFZkIdcbIt4LAtl1MAQfBGpNevVW34sNnfIf3(FHbe3zbId8XRF1Cgkf8rqvWOYHpttoaQDc1sCqiqCcVulwuRPjhG67ZqTPk1AAYbOqCcVWNtIQx4d)sRfK()9nddiUPrioWNtIQx4Zf)dkZirBeeupgaF86xnNHsbdiUZkeh4Jx)Q5muk4JGQGrLdFMMCau7eQL4GqG4eEPwSOwttoa13Nb(Csu9cFGGzTiq(amG4ITH4aF86xnNHsbFeufmQC4ZC0AbIjtDuclI6ZulwulMkStTPLAtiz4Zjr1l8nU0ztHyXT)xyaXftzaXb(Csu9cFKUr5A9GZcha8JoGpE9RMZqPGbexmXeId8XRF1Cgkf8rqvWOYHV7XyuyudmciWG3(Rodu7iQn3HcWObEdbiQnrH4VxlGAXIAtfQnTuBcjdFojQEHpaJg4neGO2eyaXfZuaXb(41VAodLc(iOkyu5WxUdfykYhwwlU9)QIIGFTjuRC5u79ymQFVjDdyH5GKwbcNGp1kHAXo85KO6f((9M0nGf3kyyaXfZudXb(41VAodLc(iOkyu5W3YZeIXL42)Rcmf5dlRP2ruBUdfGrd8gcquBIcXFVwa1MsQf7uBAP2esg(Csu9cFJlD2uiwC7)fgqCXmvG4aF86xnNHsbFeufmQC4dXgedM6xndFojQEHpaJg4neGO2eyaXftSdXb(41VAodLc(iOkyu5Wx6u79ymQFVjDdyH5GKwH4Vxla(Csu9cFKPo(i)dGbexmNfioWNtIQx473Bs3awCRGHpE9RMZqPGbexmtJqCGpNevVWhYhIgjabQWNHpE9RMZqPGbexmNvioWhV(vZzOuWhbvbJkh(UhJrHrnWiGadE7V6maFojQEHpaJg4neGO2eyaXftSneh4Jx)Q5muk4JGQGrLdFlptigxIB)VkmAThLMP2ruBUdfGrd8gcquBIkkc(1MqTYLtTlptigxIB)VQHPmQ)9YuRC5u7YZeIXL42)Rcmf5dlRHpNevVW34sNnfIf3(FHbmGpFySPG4aXftioWhV(vZzOuWhbvbJkh(UhJrD1hKOnIW19cuNbQDe1EpgJ6QpirBeHR7fOq83RfqTyrTjKm85KO6f((9M0nGf3kyyaXnfqCGpE9RMZqPGpcQcgvo8DpgJ6QpirBeHR7fOodu7iQ9Emg1vFqI2icx3lqH4VxlGAXIAtiz4Zjr1l8H8HOrcqGk8zyaXn1qCGpE9RMZqPGpcQcgvo8Lo1M7qby0aVHae1MOIIGFTjWNtIQx4dWObEdbiQnbgqCtfioWNtIQx4Zf)dkZirBeeupgaF86xnNHsbdiUyhId8XRF1Cgkf8rqvWOYHpZrRfiMm1rjSiQptTyrTyQWo1MwQnHKPw5YPwttoaQDc1sCqiqCcVulwuRPjhG67ZqTJO2ztTlptigxIB)VkmAThLMP2ruBUdfGrd8gcquBIkkc(1MqTJO2ChkaJg4neGO2efInigm1VAMALlNAxEMqmUe3(Fvdtzu)7LP2ruB6u79ymQFVjDdyH5GKwDgO2ruRPjha1oHAjoieioHxQflQ10Kdq99zO2uLADsu9QWV0AbP)FFZkIdcbIt4LAtl1MAQfBGpNevVW34sNnfIf3(FHbe3zbId85KO6f(iDJY16bNfoa4hDaF86xnNHsbdiUPrioWhV(vZzOuWhbvbJkh(UhJr97nPBalmhK0ke)9Abu7iQD5zcX4sC7)vnmLr9Vxg(Csu9cF)Et6gWIBfmmG4oRqCGpE9RMZqPGpcQcgvo8zoATaXKPokHfr9zQflQftf2P20sTjKm1oIAnn5aO2julXbHaXj8sTyrTMMCaQVpd1MQuBkKb85KO6f(WV0AbP)FFZWaIl2gId8XRF1Cgkf8rqvWOYHpttoaQDc1sCqiqCcVulwuRPjhG67ZaFojQEHpqWSweiFagqCXugqCGpE9RMZqPGpcQcgvo8DpgJkQbrBeXuwagyhPaHtWNALqTPMALlNAZDOatr(WYAXT)xvue8Rnb(Csu9cFiFiAKaeOcFggqCXetioWhV(vZzOuWhbvbJkh(YDOatr(WYAXT)xvue8Rnb(Csu9cF)Et6gWIBfmmG4IzkG4aF86xnNHsbFeufmQC4B5zcX4sC7)vbMI8HL1u7iQ10KdGAtj1MAzqTJO2ChkaJg4neGO2efI)ETaQnLul2P20sTjKm85KO6f(gx6SPqS42)lmG4IzQH4aF86xnNHsbFeufmQC4lDQ9Emg1V3KUbSWCqsRq83RfaFojQEHpYuhFK)bWaIlMPceh4Jx)Q5muk4JGQGrLdFi2GyWu)Qz4Zjr1l8by0aVHae1MadiUyIDioWhV(vZzOuWhbvbJkh(mn5aO2julXbHaXj8sTyrTMMCaQVpd1oIANn1EpgJ63Bs3awyoiPvGWj4tTyrTyNALlNAnn5aOwSOwNevVQFVjDdyXTcwrAqqTyd85KO6f(WV0AbP)FFZWaIlMZceh4Zjr1l8H8HOrcqGk8z4Jx)Q5mukyaXfZ0ieh4Jx)Q5muk4JGQGrLdF3JXO(9M0nGfMdsA1zGALlNAnn5aO2usTPImOw5YP2ChkWuKpSSwC7)vffb)AtGpNevVW3V3KUbS4wbddiUyoRqCGpE9RMZqPGpcQcgvo8T8mHyCjU9)QWO1EuAMAhrT5ouagnWBiarTjQOi4xBc1kxo1U8mHyCjU9)QgMYO(3ltTYLtTlptigxIB)VkWuKpSSMAhrTMMCauBkPwSld4Zjr1l8nU0ztHyXT)xyad4BaXK(F9aIdexmH4aFojQEHpW5)7vmWb8XRF1CgkfmG4McioWhV(vZzOuW36Fg(Czcm1roqy6neTrm0Jze85KO6f(Czcm1roqy6neTrm0JzemG4MAioWhV(vZzOuWNtIQx4Jinr3bQ3IiUAheWhbvbJkh(sNArELfmg8gQAX4Oxg5xnR4zkqaGp2yysiw)ZWhrAIUduVfrC1oiGbe3ubId85KO6f(sookx(kAJWLjg1Xu4Jx)Q5mukyaXf7qCGpNevVWhPBuUwp4SWba)Od4Jx)Q5mukyaXDwG4aFojQEHVXnsNXGRvGyqV(sy4Jx)Q5mukyaXnncXb(41VAodLc(Csu9cFdDu9cFzPx)xeXaIh6a(WegqCNvioWNtIQx4demRfbYhGpE9RMZqPGbexSneh4Zjr1l8n1rdDVWhV(vZzOuWagWhjdG4aXftioWhV(vZzOuWhbvbJkh(iDRZ94vr6gLR1dolCaWp6qH4VxlGAtj1MAzaFojQEHVRU7SWCqsddiUPaId8XRF1Cgkf8rqvWOYHps36CpEvKUr5A9GZcha8Joui(71cO2usTPwgWNtIQx4ZxcdcKRfexRHbe3udXb(41VAodLc(iOkyu5WhPBDUhVks3OCTEWzHda(rhke)9AbuBkP2uld4Zjr1l8zkeF1DNHbe3ubId85KO6f(0vY0aisdNCYN3a(41VAodLcgqCXoeh4Jx)Q5muk4JGQGrLdFKU15E8QiDJY16bNfoa4hDOq83RfqTPKANfzqTYLtTr9zr0ICXulwulMPg(Csu9cFxgbye(1MadiUZceh4Jx)Q5muk4JGQGrLdF3JXOsookx(kAJWLjg1Xu1zGAhrTZMAVhJrDzeGr4xBI6mqTYLtT3JXOU6UZcZbjT6mqTYLtTPtTiNWQa1An1InuRC5u7SPwsVGZ3VAwn0r1ROnIZErvwZzH5GKMAhrTr9zr0ICXulwu7SGj1kxo1g1NfrlYftTyrTPywOwSHALlNAtNAzaGxcRi9M5fWzHUmSPrew990qJO2ru79ymks3OCTEWzHda(rhQZa85KO6f(g6O6fgqCtJqCGpE9RMZqPGpcQcgvo8fokHdvUaHVeMAtPeQDwGpNevVWNdgysiAJiMYc2t0mmG4oRqCGpE9RMZqPGpNevVWNdMIHVmqGCzQrcsJCn8rqvWOYHV7XyuF(3iPfTrOpKklYi2)a1zGAhrTHJs4qf1NfrlYftTyrTKU15E8Q(8VrslAJqFivwKrS)bke)9Abu7eQftStTYLtT3JXOsookx(kAJWLjg1XufiCc(uReQf7u7iQnCuchQO(SiArUyQflQL0To3JxvYXr5YxrBeUmXOoMQq83RfqTtO2uidQvUCQnZ3JXOqUm1ibPrUwK57Xyu5E8sTYLtTHJs4qf1NfrlYftTyrTPatQvUCQ9Emg14gPZyW1kqmOxFjScXFVwa1oIAdhLWHkQplIwKlMAXIAjDRZ94vnUr6mgCTced61xcRq83RfqTtOwmNvQvUCQnDQnCnVH6wOmq0gXaILwXRF1CMAhrTHJs4qf1NfrlYftTyrTKU15E8QiDJY16bNfoa4hDOq83RfqTtO2uidQDe1EpgJI0nkxRhCw4aGF0HcXFVwa8T(NHphmfdFzGa5YuJeKg5AyaXfBdXb(41VAodLc(Csu9cFjUMjUwZiG429cFeufmQC4J0To3Jx1N)nsArBe6dPYImI9pqH4VxlGALlNAdxZBOgx6SPqSOwZbu9Q41VAotTJOws36CpEvKUr5A9GZcha8Joui(71cOw5YP20Pwga4LWQp)BK0I2i0hsLfze7FG67PHgrTJOws36CpEvKUr5A9GZcha8Joui(71cGV1)m8L4AM4AnJaIB3lmG4IPmG4aF86xnNHsbFR)z4ZLjWuh5aHP3q0gXqpMrWNtIQx4ZLjWuh5aHP3q0gXqpMrWaIlMycXb(41VAodLc(iOkyu5WhYRSGXG3q55mqvl1MsQfBldQDe1AAYbqTyrTMMCaQVpd1MQuBkWo1kxo1oBQ1jrHbl4L)fdO2usTysTJO20P2W18gQBHYarBediwAfV(vZzQvUCQ1jrHbl4L)fdO2usTPGAXgQDe1oBQ9Emg1vFqI2icx3lqDgO2ru79ymQR(GeTreUUxGcXFVwa1MsQn1uBAP2esMALlNAtNAVhJrD1hKOnIW19cuNbQfBGpNevVWNPjhaNfUmXOkyXL9pmG4IzkG4aF86xnNHsbFeufmQC4B2u7SPwKxzbJbVHYZzGcXFVwa1MsQfBldQvUCQnDQf5vwWyWBO8CgO4zkqaOwSHALlNANn16KOWGf8Y)IbuBkPwmP2ruB6uB4AEd1TqzGOnIbelTIx)Q5m1kxo16KOWGf8Y)IbuBkP2uqTyd1Inu7iQ10KdGAXIAnn5auFFg4Zjr1l8D1DNfTretzbV8xAyaXfZudXb(41VAodLc(iOkyu5W3SP2ztTiVYcgdEdLNZafI)ETaQnLu7SidQvUCQnDQf5vwWyWBO8CgO4zkqaOwSHALlNANn16KOWGf8Y)IbuBkPwmP2ruB6uB4AEd1TqzGOnIbelTIx)Q5m1kxo16KOWGf8Y)IbuBkP2uqTyd1Inu7iQ10KdGAXIAnn5auFFg4Zjr1l8nCqLr6AtexTdcyaXfZubId85KO6f(sookx(kAJWLjg1Xu4Jx)Q5mukyaXftSdXb(Csu9cFOAyqZIAfGbNWWhV(vZzOuWaIlMZceh4Jx)Q5muk4JGQGrLdFMJwlqmzQJsyruFMAXIAXKAtl1MqYWNtIQx4J0lH3a5bNfgT)zyaXfZ0ieh4Jx)Q5muk4JGQGrLdF3JXOqmbFndactJiS6maFojQEHVyklo7TpBwyAeHHbexmNvioWNtIQx4BCJ0zm4Afig0RVeg(41VAodLcgqCXeBdXb(41VAodLc(iOkyu5Wx4OeoutzxhtvdKGAtj1oRYGALlNAdhLWHAk76yQAGeulwsO2uidQvUCQnCuchQO(SiAXajePqguBkP2uld4Zjr1l8HyFO2eHr7FgadiUPqgqCGpE9RMZqPGpcQcgvo8XaaVew95FJKw0gH(qQSiJy)duFpn0iQDe1IydIbt9RMP2ru79ymkmQbgbeyWB)vNbQDe1Mo1s6wN7XR6Z)gjTOnc9HuzrgX(hOq83RfaFojQEHpaJg4neGO2eyaXnfycXb(41VAodLc(iOkyu5Whda8sy1N)nsArBe6dPYImI9pq990qJO2ruB6ulPBDUhVQp)BK0I2i0hsLfze7FGcXFVwa85KO6f((9M0nGf3kyyaXnfPaId8XRF1Cgkf8rqvWOYHpga4LWQp)BK0I2i0hsLfze7FG67PHgrTJOwZrRfiMm1rjSiQptTyrTyQWo1MwQnHKP2ruRPjha1If16KO6v97nPBalUvWksdcQDe1Mo1s6wN7XR6Z)gjTOnc9HuzrgX(hOq83RfaFojQEHVXLoBkelU9)cdiUPi1qCGpE9RMZqPGpcQcgvo8zAYbqTyrTojQEv)Et6gWIBfSI0GGAhrT3JXOiDJY16bNfoa4hDOodWNtIQx47Z)gjTOnc9HuzrgX(hadyaFz24hDaXbIlMqCGpE9RMZqPGpcQcgvo8L57Xyuehe1MOoduRC5u79ymQCbgyT2VAw89KIOoduRC5u79ymQCbgyT2VAwWlYty1za(Csu9cFexRfojQEf6ceWNUaHy9pdFNO0vinmG4McioWNtIQx47ayrf8haF86xnNHsbdiUPgId8XRF1Cgkf85KO6f(iUwlCsu9k0fiGpDbcX6Fg(izamG4MkqCGpE9RMZqPGpcQcgvo85KOWGf8Y)IbuReQftQDe1gokHdvuFweTixm1If1AAYbqTY8O2ztTojQEv)Et6gWIBfSI0GGAtvQL4GqG4eEPwSHAtl1MqYWNtIQx473Bs3awCRGHbexSdXb(41VAodLc(iOkyu5WNtIcdwWl)lgqTyrTPMAhrTHR5nuKPo(i)du86xnNP2ruB4AEdLRhM6IbeN9OrkE9RMZWNtIQx4J4ATWjr1RqxGa(0fieR)z4ZhgBkyaXDwG4aF86xnNHsbFeufmQC4ZjrHbl4L)fdOwSO2utTJO2W18gkYuhFK)bkE9RMZWNtIQx4J4ATWjr1RqxGa(0fieR)z4BSPGbe30ieh4Jx)Q5muk4JGQGrLdFojkmybV8Vya1If1MAQDe1Mo1gUM3q56HPUyaXzpAKIx)Q5m1oIAtNAdxZBOgx6SPqSOwZbu9Q41VAodFojQEHpIR1cNevVcDbc4txGqS(NHpqadiUZkeh4Jx)Q5muk4JGQGrLdFojkmybV8Vya1If1MAQDe1gUM3q56HPUyaXzpAKIx)Q5m1oIAtNAdxZBOgx6SPqSOwZbu9Q41VAodFojQEHpIR1cNevVcDbc4txGqS(NHpFaeWaIl2gId8XRF1Cgkf8rqvWOYHpNefgSGx(xmGAXIAtn1oIAdxZBOC9WuxmG4ShnsXRF1CMAhrTHR5nuJlD2uiwuR5aQEv86xnNHpNevVWhX1AHtIQxHUab8Plqiw)ZWNpm2uWaIlMYaId8XRF1Cgkf8rqvWOYHpNefgSGx(xmGAXIAtn1oIAtNAdxZBOC9WuxmG4ShnsXRF1CMAhrTHR5nuJlD2uiwuR5aQEv86xnNHpNevVWhX1AHtIQxHUab8Plqiw)ZW3ytbdiUyIjeh4Jx)Q5muk4JGQGrLdFojkmybV8Vya1MsQftQDe1Mo1gUM3qDlugiAJyaXsR41VAotTYLtTojkmybV8Vya1MsQnfWNtIQx4J4ATWjr1RqxGa(0fieR)z4JOzhdggqCXmfqCGpNevVWhPxcVbYdolmA)ZWhV(vZzOuWaIlMPgId85KO6f(CeXxwencXBaF86xnNHsbdiUyMkqCGpNevVW31teTreOIGpa(41VAodLcgWa(orPRqAioqCXeId85KO6f((hzsM0m8XRF1CgkfmG4McioWNtIQx4dWiERqAr(ac4Jx)Q5mukyaXn1qCGpNevVWhyOrSGO7tg(41VAodLcgqCtfioWNtIQx4d0DmT2eXypye8XRF1CgkfmG4IDioWNtIQx4d0BrexTdc4Jx)Q5mukyaXDwG4aFojQEHVLJPmsaM2e8HpE9RMZqPGbe30ieh4Zjr1l8rMwPHcicKVYSCkDfsdF86xnNHsbdiUZkeh4Zjr1l8bgkufcW0MGp8XRF1CgkfmG4ITH4aFojQEHV1JdIbIeKty4Jx)Q5mukyadyaFyWiq1le3uiJuidzKkPa7W3yhT1MaGpzg(dnk4m1ITPwNevVuRUabqrNdFdO2uAg(stQ9Dqyuy4AQvM)zdgrNNMu70igaylXdVKkMEUks)Xdu)J2JQxcYnbEG6tWJopnPwzoxAQftmLLAtHmsHmOZPZttQfBXuFtya2s680KAtvQfBnN5m1kZDKjzsZuB0uBMn(rhuRtIQxQvxGqrNNMuBQsTylM6BcNP2WrjCikd1YZmGyaO6fqTrtTePjAweokHdGIopnP2uLAL56CzkotTehHblize1gn1oUr4tT)gXul7Gsln1oUIPuBmLPwpN7vMja1w)bn)5n8O6LABd1IHJk)QzfDEAsTPk1ITMZCMAprPRqAQfBvMzzgv0505Pj1kZEgMCcotTx20iMAj9)6b1E5KAbkQfBLq4HaqTBVP6uh9nhn16KO6fqT9QLwrNNMuRtIQxGAaXK(F9qIr7a8PZttQ1jr1lqnGys)VEmrcE(j5ZB4r1lDEAsTojQEbQbet6)1JjsWZ0DMo3jr1lqnGys)VEmrcEGZ)3RyGd680KAFRpaM2b1I8ktT3JXWzQfeEaO2lBAetTK(F9GAVCsTaQ13m1oG4uDOJO2eQTauBUxwrNNMuRtIQxGAaXK(F9yIe8aRpaM2HaeEaOZDsu9cudiM0)RhtKG3bWIk4VSR)zjUmbM6ihim9gI2ig6XmIo3jr1lqnGys)VEmrcEhalQG)YYgdtcX6FwcrAIUduVfrC1oiKTmssh5vwWyWBOQfJJEzKF1SINPabGo3jr1lqnGys)VEmrcEjhhLlFfTr4YeJ6ykDUtIQxGAaXK(F9yIe8iDJY16bNfoa4hDqN7KO6fOgqmP)xpMibVXnsNXGRvGyqV(sy6CNevVa1aIj9)6Xej4n0r1RSzPx)xeXaIh6qcM05ojQEbQbet6)1JjsWdemRfbYhOZDsu9cudiM0)RhtKG3uhn09sNtN7KO6fOorPRqAj)JmjtAMo3jr1lqDIsxH0tKGhGr8wH0I8be05ojQEbQtu6kKEIe8adnIfeDFY05ojQEbQtu6kKEIe8aDhtRnrm2dgrN7KO6fOorPRq6jsWd0BrexTdc6CNevVa1jkDfsprcElhtzKamTj4tN7KO6fOorPRq6jsWJmTsdfqeiFLz5u6kKMo3jr1lqDIsxH0tKGhyOqviatBc(05ojQEbQtu6kKEIe8wpoigisqoHPZPZttQvM9mm5eCMAzmyK0uBuFMAJPm16KOruBbOwhdV0(vZk6CNevVajexRfojQEf6ceYU(NLCIsxH0Ywgjz(EmgfXbrTjQZGC53JXOYfyG1A)QzX3tkI6mix(9ymQCbgyT2VAwWlYty1zGo3jr1lyIe8oawub)b05ojQEbtKGhX1AHtIQxHUaHSR)zjKmGo3jr1lyIe8(9M0nGf3kyzlJeNefgSGx(xmqcMJchLWHkQplIwKlglttoazEZ2jr1R63Bs3awCRGvKgePkXbHaXj8InPnHKPZDsu9cMibpIR1cNevVcDbczx)Zs8HXMs2YiXjrHbl4L)fdWk1JcxZBOitD8r(hO41VAopkCnVHY1dtDXaIZE0ifV(vZz6CNevVGjsWJ4ATWjr1RqxGq21)SKXMs2YiXjrHbl4L)fdWk1JcxZBOitD8r(hO41VAotN7KO6fmrcEexRfojQEf6ceYU(NLaczlJeNefgSGx(xmaRupk9W18gkxpm1fdio7rJu86xnNhLE4AEd14sNnfIf1AoGQxfV(vZz6CNevVGjsWJ4ATWjr1RqxGq21)SeFaeYwgjojkmybV8VyawPEu4AEdLRhM6IbeN9OrkE9RMZJspCnVHACPZMcXIAnhq1RIx)Q5mDUtIQxWej4rCTw4KO6vOlqi76FwIpm2uYwgjojkmybV8VyawPEu4AEdLRhM6IbeN9OrkE9RMZJcxZBOgx6SPqSOwZbu9Q41VAotN7KO6fmrcEexRfojQEf6ceYU(NLm2uYwgjojkmybV8VyawPEu6HR5nuUEyQlgqC2JgP41VAopkCnVHACPZMcXIAnhq1RIx)Q5mDUtIQxWej4rCTw4KO6vOlqi76FwcrZogSSLrItIcdwWl)lgKsmhLE4AEd1TqzGOnIbelTIx)Q5SC5ojkmybV8VyqktbDUtIQxWej4r6LWBG8GZcJ2)mDUtIQxWej45iIVSiAeI3Go3jr1lyIe8UEIOnIave8b0505ojQEbkFaes(9M0nGf3kyzlJK7XyuKUr5A9GZcha8JouNHrZ(EmgfPBuUwp4SWba)OdfI)ETaSWuH90MqYYLFpgJ6QpirBeHR7fOodJUhJrD1hKOnIW19cui(71cWctf2tBcjJn05ojQEbkFaetKGhYhIgjabQWNLTmsUhJrr6gLR1dolCaWp6qDggn77XyuKUr5A9GZcha8Joui(71cWctf2tBcjlx(9ymQR(GeTreUUxG6mm6Emg1vFqI2icx3lqH4VxlalmvypTjKm2qN7KO6fO8bqmrcEgTV4xBIaeOcFw2YiX0KdycXbHaXj8ILPjhG67ZqN7KO6fO8bqmrcE4xATG0)VVzzjst0SiCuchajykBzKyoATaXKPokHfr9zSWuH90MqYJmn5aMqCqiqCcVyzAYbO((m05ojQEbkFaetKGhiywlcKpiBzKyAYbmH4GqG4eEXY0Kdq99zOZDsu9cu(aiMibVXLoBkelU9)kBzKyAYbmH4GqG4eEXY0Kdq99zgLEue8Rnzu63JXO(8VrslAJqFivwKrS)bQZWOzBoATaXKPokHfr9zSWuH90MqYYLNEUd14sNnfIf3(FvrrWV2KrPFpgJI0nkxRhCw4aGF0H6mixE65ouJlD2uiwC7)vffb)AtgDpgJ63Bs3awyoiPvGWj4JfMyJC5r9zr0ICXyH5Sok9ChQXLoBkelU9)QIIGFTj05ojQEbkFaetKGhGrd8gcquBISLrs65ouagnWBiarTjQOi4xBYO0VhJrr6gLR1dolCaWp6qDgOZDsu9cu(aiMibp8lTwq6)33SSePjAweokHdGemLTmsmn5aMqCqiqCcVyzAYbO((mJM99ymQFVjDdyH5GKwbcNGpwyxUCttoaSCsu9Q(9M0nGf3kyfPbb2qN7KO6fO8bqmrcEagnWBiarTjYwgji2GyWu)Q5rPFpgJI0nkxRhCw4aGF0H6mm6Emg1V3KUbSWCqsRaHtWhlStN7KO6fO8bqmrcEU4FqzgjAJGG6XazlJK0VhJrr6gLR1dolCaWp6qDgOZDsu9cu(aiMibps3OCTEWzHda(rhYwgjPFpgJI0nkxRhCw4aGF0H6mqN7KO6fO8bqmrcE)Et6gWIBfSSLrY9ymQFVjDdyH5GKwDgKl30KdycXbHaXj8Msttoa13NjvXugYLFpgJI0nkxRhCw4aGF0H6mqN7KO6fO8bqmrcEiFiAKaeOcFMo3jr1lq5dGyIe8gx6SPqS42)RSLrs6rrWV2e6C6CNevVaLpm2us(9M0nGf3kyzlJK7Xyux9bjAJiCDVa1zy09ymQR(GeTreUUxGcXFVwawjKmDUtIQxGYhgBQjsWd5drJeGav4ZYwgj3JXOU6ds0gr46EbQZWO7Xyux9bjAJiCDVafI)ETaSsiz6CNevVaLpm2utKGhGrd8gcquBISLrs65ouagnWBiarTjQOi4xBcDUtIQxGYhgBQjsWZf)dkZirBeeupgqN7KO6fO8HXMAIe8gx6SPqS42)RSLrI5O1cetM6Oewe1NXctf2tBcjlxUPjhWeIdcbIt4flttoa13Nz0SxEMqmUe3(Fvy0Apknpk3HcWObEdbiQnrffb)AtgL7qby0aVHae1MOqSbXGP(vZYLV8mHyCjU9)QgMYO(3lpk97Xyu)Et6gWcZbjT6mmY0KdycXbHaXj8ILPjhG67ZKQojQEv4xATG0)VVzfXbHaXj8M2uJn05ojQEbkFySPMibps3OCTEWzHda(rh05ojQEbkFySPMibVFVjDdyXTcw2Yi5Emg1V3KUbSWCqsRq83RfmA5zcX4sC7)vnmLr9VxMo3jr1lq5dJn1ej4HFP1cs))(MLTmsmhTwGyYuhLWIO(mwyQWEAti5rMMCatioieioHxSmn5auFFMunfYGo3jr1lq5dJn1ej4bcM1Ia5dYwgjMMCatioieioHxSmn5auFFg6CNevVaLpm2utKGhYhIgjabQWNLTmsUhJrf1GOnIykladSJuGWj4lj1YLN7qbMI8HL1IB)VQOi4xBcDUtIQxGYhgBQjsW73Bs3awCRGLTmsYDOatr(WYAXT)xvue8RnHo3jr1lq5dJn1ej4nU0ztHyXT)xzlJKLNjeJlXT)xfykYhwwpY0KdiLPwgJYDOamAG3qaIAtui(71csj2tBcjtN7KO6fO8HXMAIe8itD8r(hiBzKK(9ymQFVjDdyH5GKwH4VxlGo3jr1lq5dJn1ej4by0aVHae1MiBzKGydIbt9RMPZDsu9cu(WytnrcE4xATG0)VVzzlJettoGjeheceNWlwMMCaQVpZOzFpgJ63Bs3awyoiPvGWj4Jf2Ll30KdalNevVQFVjDdyXTcwrAqGn05ojQEbkFySPMibpKpensacuHptN7KO6fO8HXMAIe8(9M0nGf3kyzlJK7Xyu)Et6gWcZbjT6mixUPjhqktfzixEUdfykYhwwlU9)QIIGFTj05ojQEbkFySPMibVXLoBkelU9)kBzKS8mHyCjU9)QWO1EuAEuUdfGrd8gcquBIkkc(1Mix(YZeIXL42)RAykJ6FVSC5lptigxIB)VkWuKpSSEKPjhqkXUmOZPZDsu9cuKmqYv3DwyoiPLTmsiDRZ94vr6gLR1dolCaWp6qH4VxliLPwg05ojQEbksgmrcE(syqGCTG4ATSLrcPBDUhVks3OCTEWzHda(rhke)9AbPm1YGo3jr1lqrYGjsWZui(Q7olBzKq6wN7XRI0nkxRhCw4aGF0HcXFVwqktTmOZDsu9cuKmyIe80vY0aisdNCYN3Go3jr1lqrYGjsW7YiaJWV2ezlJes36CpEvKUr5A9GZcha8Joui(71cs5Sid5YJ6ZIOf5IXcZutN7KO6fOizWej4n0r1RSLrY9ymQKJJYLVI2iCzIrDmvDggn77Xyuxgbye(1MOodYLFpgJ6Q7olmhK0QZGC5PJCcRcuR1yJC5ZM0l489RMvdDu9kAJ4SxuL1CwyoiPhf1NfrlYfJ1SGPC5r9zr0ICXyLIzbBKlpDga4LWksVzEbCwOldBAeHvFpn0Or3JXOiDJY16bNfoa4hDOod05ojQEbksgmrcEoyGjHOnIyklyprZYwgjHJs4qLlq4lHtPKzHo3jr1lqrYGjsW7ayrf8x21)SehmfdFzGa5YuJeKg5AzlJK7XyuF(3iPfTrOpKklYi2)a1zyu4Oeour9zr0ICXyr6wN7XR6Z)gjTOnc9HuzrgX(hOq83RfmbtSlx(9ymQKJJYLVI2iCzIrDmvbcNGVeSpkCuchQO(SiArUySiDRZ94vLCCuU8v0gHltmQJPke)9AbtsHmKlpZ3JXOqUm1ibPrUwK57Xyu5E8kxE4Oeour9zr0ICXyLcmLl)Emg14gPZyW1kqmOxFjScXFVwWOWrjCOI6ZIOf5IXI0To3Jx14gPZyW1kqmOxFjScXFVwWemNv5YtpCnVH6wOmq0gXaILwXRF1CEu4Oeour9zr0ICXyr6wN7XRI0nkxRhCw4aGF0HcXFVwWKuiJr3JXOiDJY16bNfoa4hDOq83RfqN7KO6fOizWej4DaSOc(l76FwsIRzIR1mciUDVYwgjKU15E8Q(8VrslAJqFivwKrS)bke)9AbYLhUM3qnU0ztHyrTMdO6vXRF1CEePBDUhVks3OCTEWzHda(rhke)9AbYLNoda8sy1N)nsArBe6dPYImI9pq990qJgr6wN7XRI0nkxRhCw4aGF0HcXFVwaDUtIQxGIKbtKG3bWIk4VSR)zjUmbM6ihim9gI2ig6XmIo3jr1lqrYGjsWZ0KdGZcxMyufS4Y(x2Yib5vwWyWBO8CgOQnLyBzmY0Kdalttoa13Njvtb2LlF2ojkmybV8VyqkXCu6HR5nu3cLbI2igqS0kE9RMZYL7KOWGf8Y)IbPmfyZOzFpgJ6QpirBeHR7fOodJUhJrD1hKOnIW19cui(71cszQtBcjlxE63JXOU6ds0gr46EbQZa2qN7KO6fOizWej4D1DNfTretzbV8xAzlJKzpBKxzbJbVHYZzGcXFVwqkX2YqU80rELfmg8gkpNbkEMceaSrU8z7KOWGf8Y)IbPeZrPhUM3qDlugiAJyaXsR41VAolxUtIcdwWl)lgKYuGnyZittoaSmn5auFFg6CNevVafjdMibVHdQmsxBI4QDqiBzKm7zJ8klym4nuEodui(71cs5Sid5Yth5vwWyWBO8CgO4zkqaWg5YNTtIcdwWl)lgKsmhLE4AEd1TqzGOnIbelTIx)Q5SC5ojkmybV8Vyqktb2GnJmn5aWY0Kdq99zOZDsu9cuKmyIe8sookx(kAJWLjg1Xu6CNevVafjdMibpunmOzrTcWGty6CNevVafjdMibpsVeEdKhCwy0(NLTmsmhTwGyYuhLWIO(mwyM2esMo3jr1lqrYGjsWlMYIZE7ZMfMgryzlJK7XyuiMGVMbaHPrewDgOZDsu9cuKmyIe8g3iDgdUwbIb96lHPZDsu9cuKmyIe8qSpuBIWO9pdKTmschLWHAk76yQAGePCwLHC5HJs4qnLDDmvnqcSKKczixE4Oeour9zr0IbsisHmszQLbDUtIQxGIKbtKGhGrd8gcquBISLrcda8sy1N)nsArBe6dPYImI9pq990qJgHydIbt9RMhDpgJcJAGrabg82F1zyu6KU15E8Q(8VrslAJqFivwKrS)bke)9Ab05ojQEbksgmrcE)Et6gWIBfSSLrcda8sy1N)nsArBe6dPYImI9pq990qJgLoPBDUhVQp)BK0I2i0hsLfze7FGcXFVwaDUtIQxGIKbtKG34sNnfIf3(FLTmsyaGxcR(8VrslAJqFivwKrS)bQVNgA0iZrRfiMm1rjSiQpJfMkSN2esEKPjhawojQEv)Et6gWIBfSI0Gyu6KU15E8Q(8VrslAJqFivwKrS)bke)9Ab05ojQEbksgmrcEF(3iPfTrOpKklYi2)azlJettoaSCsu9Q(9M0nGf3kyfPbXO7XyuKUr5A9GZcha8JouNb6C6CNevVafrZogSemCu5xnl76FwcXryWcsgjBpibWrzKfdxFyjojkmybV8VyGSy46dlynGLGDzj9MRO6vItIcdwWl)lgGf2PZDsu9cuen7yWtKGNl(huMrI2iiOEmGo3jr1lqr0SJbprcEKUr5A9GZcha8JoOZDsu9cuen7yWtKGhXryWYwgj5ouGPiFyzT42)Rkkc(1MqN7KO6fOiA2XGNibVXLoBkelU9)kBzKKE4AEdvYHrOsRDr4KOiafV(vZz5YnhTwGyYuhLWIO(mwjKmDUtIQxGIOzhdEIe8(9M0nGf3kyzjst0SiCuchajykBzKK57XyuAp4nedDb6vbcNGVemLbDUtIQxGIOzhdEIe8itD8r(hqN7KO6fOiA2XGNibp8lTwq6)33SSePjAweokHdGemLTmsmn5aMqCqiqCcVyzAYbO((m05ojQEbkIMDm4jsW7EcYugjTSLrI5O1cetM6Oewe1NXkHKLlp9W18gQXLoBkelQ1CavVkE9RMZYLN7qbMI8HL1IB)VQOi4xBYOChQAdgTUwC1mNRnrbcNGpwPMo3jr1lqr0SJbprcEehHblBzKeUM3qLCyeQ0AxeojkcqXRF1CMo3jr1lqr0SJbprcEgTV4xBIaeOcFw2YiX0KdycXbHaXj8ILPjhG67ZqN7KO6fOiA2XGNibVXLoBkelU9)kBzKK7qnU0ztHyXT)xfInigm1VAwU8W18gQXLoBkelQ1CavVkE9RMZ05ojQEbkIMDm4jsWdWObEdbiQnrwI0enlchLWbqcMYwgj3JXOWOgyeqGbV9xHyNe05ojQEbkIMDm4jsWJ4imyzlJes36CpEvJlD2uiwC7)vH4VxliLy4OYVAwrCegSGKrY8sbDUtIQxGIOzhdEIe8abZArG8b6CNevVafrZog8ej4n1rdDVYwgjHR5nubJ(arBe8M4j8N3qXRF1CMo3jr1lqr0SJbprcEagnWBiarTjYsKMOzr4OeoasWu2YibXgedM6xnp6EmgvudI2iIPSamWosbcNGpwPMopnPwCAQfu)J2dMApapHPwtJOwzUEt6gWuRuvWuBJOwzw9HOru7lqf(m1MpOAtOwSvWatcQTnuBmLPwz2EIMLLAj9G0ul7KPuBtiheIxctTTHAJPm16KO6LA9ntT(WaVzQvWEIMP2OP2yktTojQEP21)SIo3jr1lqr0SJbprcE)Et6gWIBfSSePjAweokHdGemPZDsu9cuen7yWtKGhYhIgjabQWNLLinrZIWrjCaKGjDoDUtIQxGcesM6OHUxzlJKW18gQGrFGOncEt8e(ZBO41VAotN7KO6fOaXej4z0(IFTjcqGk8zzlJettoGjeheceNWlwMMCaQVpdDUtIQxGcetKGhYhIgjabQWNLTmsUhJrr6gLR1dolCaWp6qDggn77XyuKUr5A9GZcha8Joui(71cWctf2tBcjlx(9ymQR(GeTreUUxG6mm6Emg1vFqI2icx3lqH4VxlalmvypTjKm2qNNMulon1cQ)r7btThGNWuRPruRmxVjDdyQvQkyQTruRmR(q0iQ9fOcFMAZhuTjul2kyGjb12gQnMYuRmBprZYsTKEqAQLDYuQTjKdcXlHP22qTXuMADsu9sT(MPwFyG3m1kyprZuB0uBmLPwNevVu76FwrN7KO6fOaXej497nPBalUvWYwgj3JXOiDJY16bNfoa4hDOodJM99ymks3OCTEWzHda(rhke)9AbyHPc7PnHKLl)Emg1vFqI2icx3lqDggDpgJ6QpirBeHR7fOq83RfGfMkSN2esgBOZDsu9cuGyIe8WV0AbP)FFZYsKMOzr4OeoasWu2YiX0KdycXbHaXj8ILPjhG67ZqN7KO6fOaXej4by0aVHae1MiBzKCpgJcJAGrabg82F1zy09ymkmQbgbeyWB)vi(71cWcZ0MqY05ojQEbkqmrcEGGzTiq(GSLrIPjhWeIdcbIt4flttoa13NHo3jr1lqbIjsWBCPZMcXIB)VYwgjMMCatioieioHxSmn5auFFMri2GyWu)Q5rMJwlqmzQJsyruFgResEu63JXO(8VrslAJqFivwKrS)bQZGC5MMCatioieioHxSmn5auFFMrZo9ChQXLoBkelU9)QIIGFTjJMD63JXOiDJY16bNfoa4hDOodYLFpgJ63Bs3awyoiPvGWj4JfMYLh1NfrlYfJfMZQC5PN7qnU0ztHyXT)xvue8RnzKltmQcwnU0zgTmaiahegfgUwH8f)ukdSbBgL(9ymQp)BK0I2i0hsLfze7FG6mqN7KO6fOaXej4by0aVHae1MiBzKCpgJcJAGrabg82F1zyuUdfGrd8gcquBIcXFVwawPsAtiz5YZDOamAG3qaIAtui2GyWu)Q5rPFpgJI0nkxRhCw4aGF0H6mqN7KO6fOaXej45I)bLzKOnccQhdKTmss)EmgfPBuUwp4SWba)Od1zGo3jr1lqbIjsWJ0nkxRhCw4aGF0HSLrs63JXOiDJY16bNfoa4hDOod05ojQEbkqmrcE)Et6gWIBfSSLrY9ymQFVjDdyH5GKwDgKl30KdycXbHaXj8Msttoa13NjvtHmgfUM3qHrnWiGadE7VIx)Q5SC5MMCatioieioH3uAAYbO((mPkMJcxZBOcg9bI2i4nXt4pVHIx)Q5SC53JXOiDJY16bNfoa4hDOod05ojQEbkqmrcEiFiAKaeOcFMo3jr1lqbIjsWBCPZMcXIB)VYwgj5ouJlD2uiwC7)vHydIbt9RMPZDsu9cuGyIe8amAG3qaIAtKTmsUhJrHrnWiGadE7V6mqNtN7KO6fOgBkjtD0q3RSLrIPjhWeIdcbIt4flttoa13Nzu4AEdvWOpq0gbVjEc)5nu86xnNPZDsu9cuJn1ej497nPBalUvWYwgj3JXOU6ds0gr46EbQZWO7Xyux9bjAJiCDVafI)ETaSsiz6CNevVa1ytnrcEiFiAKaeOcFw2Yi5Emg1vFqI2icx3lqDggDpgJ6QpirBeHR7fOq83RfGvcjtN7KO6fOgBQjsWdWObEdbiQnr2Yi5Emgfg1aJacm4T)QZWO7XyuyudmciWG3(Rq83RfGfMkSN2eswU80ZDOamAG3qaIAturrWV2e6CNevVa1ytnrcEJlD2uiwC7)v2YiXC0AbIjtDuclI6ZyHPc7PnHKhzAYbmH4GqG4eEXY0Kdq99zKlF2lptigxIB)VkmAThLMhL7qby0aVHae1MOIIGFTjJYDOamAG3qaIAtui2GyWu)Qz5YxEMqmUe3(Fvdtzu)7LhL(9ymQFVjDdyH5GKwDggzAYbmH4GqG4eEXY0Kdq99zsvNevVk8lTwq6)33SI4GqG4eEtBQXg6CNevVa1ytnrcE4xATG0)VVzzlJettoGjeheceNWlwMMCaQVptQAAYbOqCcV05ojQEbQXMAIe8CX)GYms0gbb1Jb05ojQEbQXMAIe8abZArG8bzlJettoGjeheceNWlwMMCaQVpdDUtIQxGASPMibVXLoBkelU9)kBzKyoATaXKPokHfr9zSWuH90MqY05ojQEbQXMAIe8iDJY16bNfoa4hDqN7KO6fOgBQjsWdWObEdbiQnr2Yi5Emgfg1aJacm4T)QZWOChkaJg4neGO2efI)ETaSsL0MqY05ojQEbQXMAIe8(9M0nGf3kyzlJKChkWuKpSSwC7)vffb)AtKl)Emg1V3KUbSWCqsRaHtWxc2PZDsu9cuJn1ej4nU0ztHyXT)xzlJKLNjeJlXT)xfykYhwwpk3HcWObEdbiQnrH4VxliLypTjKmDUtIQxGASPMibpaJg4neGO2ezlJeeBqmyQF1mDUtIQxGASPMibpYuhFK)bYwgjPFpgJ63Bs3awyoiPvi(71cOZDsu9cuJn1ej497nPBalUvW05ojQEbQXMAIe8q(q0ibiqf(mDUtIQxGASPMibpaJg4neGO2ezlJK7XyuyudmciWG3(Rod05ojQEbQXMAIe8gx6SPqS42)RSLrYYZeIXL42)RcJw7rP5r5ouagnWBiarTjQOi4xBIC5lptigxIB)VQHPmQ)9YYLV8mHyCjU9)Qatr(WYA4dmWeiUPa7yhgWacb]] )


end