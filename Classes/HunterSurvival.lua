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


    spec:RegisterPack( "Survival", 20190226.2355, [[dGKCrbqiIipIiQUKsffTjLsFsPIsnkIuofrIvPuHELkXSKGULsfSlQ8lvsdtLshtczzeP6zsattPICnIQABQu03iQIgNkf6CerP1refMhrL7ru2hrshKOkSqIWdjQsCrIOOnQurHrsuL0jvQOsRuPQzQurf3uLcStGQHQsbTuIQupfWuvPAVG(lPgmHdlSyj9yunzvCzKnRKptvgTe50IwTsfv9AGYSj52O0UL63kgov1XvQOKLd1Zv10PCDuSDjQVRumELkDEjuRxc08bY(HmSi4DiWjmccU0VTij7Tsx630j9ciF5l9Becyf7tqa)Gdw4rqGoyjiaadUCwouqa)Oy1eh4DiWpmyobbkzM)lzC9QxALyQo(WE9twgvy50CCSSRFYYVwvt9ADf7WHkF1hpRur)1BiMK3rE(R3q5TwELPncRbyWLZYHY9jlhcuzsLTZTHviWjmccU0VTij7Tsx630j9ciF5x0ncbcgR0GHaajlJkSCA5fCSmiqP8COgwHah65qajhjayWLZYHcjKxzAJWO9sosuYm)xY46vV0kXuD8H96NSmQWYP54yzx)KLFTQM616k2Hdv(QpEwPI(R3qmjVJ88xVHYBT8ktBewdWGlNLdL7twoAVKJe7mOkMjWfJes)MfIes)2IKSiXoGesVasgY)w0E0EjhjKxkfTh9sgO9sosSdiH84COdsCdykybvesydsCOvWOmKi4wonsOY3CO9sosSdiH8sPO9Odsyb2JmDUqcAxFm9Fo9Je2Ge8I5ksBb2JS3H2l5iXoGe3G5KRKoibpWLjn)GrcBqIndgmKGDWesqXNQIrInPvcjSseseNZ07SFKiz9vel1wy50iXSqIYboJQICO9sosSdiH84COdsWyPkTIrc5XnCNJdcOY3E4DiWMvQFdEhcErW7qGGB50qGqZYGpewplnhpBEia1rvrhOeqdcU0H3Hab3YPHa8zWNSdJo64)GrzqaQJQIoqjGge8caVdbOoQk6aLacWXPr4mGarbjCAKBtQoeUP)1pdUCwouoQJQIoiXwKOPDn9Muxh2QR8OclvesSfjoJ5Ec7tTPFlBphMyJSFKqQiH0DfHe7is4XpiXwK4mM7jSp1M(TS9CyInY(rc5qIc4KpsSJiHh)GeBrc(mQZSPDBs1zLysxh2QdtSr2psivKq6o5Je7is4XpqGGB50qa2P9M5jDnncAqW3j4Dia1rvrhOeqaooncNbeyXOuAmXlfypsBjlHeYHeE8dsacesinKynCMhjUGe84nnM8OgjKdjwdN5DSXUiHuqITiH0qIM210BsDDyRUYJkSuriXwK4mM7jSp1M(TS9CwYblBpKylsCgZ9e2NAt)w2EomTW0xkQkcjabcjAAxtVj11HT68lr4HDAcj2IescjQmRLJDAVzEsVyWf7y8rITiXA4mpsCbj4XBAm5rnsihsSgoZ7yJDrIDajcULt7alvknFyzJ(44XBAm5rnsSJirbqcPabcULtdb2KQZkXKUoSvObbx(W7qaQJQIoqjGaCCAeodiWA4mpsCbj4XBAm5rnsihsSgoZ7yJDrITirLzTCw6RNL2kr63NcS7TGdgsihsuaKylsinKqsiHfkQnxO8lfAFmDcBWoQJQIoibiqirLzTCSt7nZt6fdUy3BbhmKqoKq(ibiqiXA4mpsihseClN2XoT3mpPRPro(8gsifiqWTCAiayPsP5dlB0hObb)MW7qaQJQIoqjGaCCAeodiWzmx2gH7qPRkIoz75El4GHeYHefaj2IeNXCFjC43Ksxh2QZsoyz7HeBrcjHewOO2CSt7nZt6AAKJ6OQOdei4woneah(2G1VHtWiObbxEcVdbOoQk6aLacWXPr4mGanTRP3K66WwDFjC43Kcj2IevM1YXoT3mpPxm4IDNztJeBrcPHe8zuNzt7alvknFyzJ(4WeBK9Jesfj84hKaeiKynCMhjKksCZBrcPGeBrcjHeNXCpH9P20VLTNdtlm9LIQIGab3YPHaBs1zLysxh2k0GGFJW7qGGB50qG3isPnC4dbOoQk6aLaAqWLSW7qaQJQIoqjGaCCAeodiWA4mpsCbj4XBAm5rnsihsSgoZ7yJDHab3YPHalv0GLTN(nCcgbni4fDl8oeG6OQOduciahNgHZacuzwlx50NWVUm1dRdtb3qcqGqcmTW0xkQkcj2IesdjKesyHIAZXoT3mpPRProQJQIoibiqiHKqcluuBUYPpHFDzQhwh1rvrhKaeiKOPDn9Muxh2QR8OclvesSfjKesCgZ9LWHFtkDDyRol5GLThsacesefKWProvyuBA)j)PDuhvfDqcqGqIOGeonYvM6HDyE9kAV3rDuv0bjabcjQmRLJDAVzEsVyWf7El4GHeYqc5JesbceClNgc8e2NAt)w2EqdcErfbVdbOoQk6aLacWXPr4mGawOO2CgHzF9S0u7fEel1MJ6OQOdei4woneOuG9NPHge8IKo8oeG6OQOduciahNgHZacuzwlh70EZ8KEXGl2X4JeGaHeRHZ8iHurIBElsacesCgZ9LWHFtkDDyRol5GLThei4woneGDAVzEsxtJGge8Ika8oei4woneah(2G1VHtWiia1rvrhOeqdcEr7e8oeG6OQOduciahNgHZacGPfM(srvrqGGB50qGNW(uB63Y2dAqWls(W7qaQJQIoqjGaCCAeodiqt7A6nPUoSvx5rfwQiKylsCgZ9e2NAt)w2Eol5GLThsaces00UMEtQRdB15xIWd70esaces00UMEtQRdB19LWHFtkKylsSgoZJesfjK)TqGGB50qGnP6SsmPRdBfAqdcWvuuMG3HGxe8oeG6OQOduciW4dbEYGab3YPHaLdCgvfbbkhkgcceClltAQj2KEKqQiH8rITiH8rcqGqIGBzzstnXM0dbkhyDhSeeGh4YKMFWqdcU0H3Hab3YPHaHMLbFiSEwAoE28qaQJQIoqjGge8caVdbcULtdb4ZGpzhgD0X)bJYGauhvfDGsani47e8oeG6OQOduciahNgHZacCgZ9LWHFtkDDyRol5GLThei4woneGh4Ye0GGlF4Dia1rvrhOeqaooncNbeqsiHfkQnNhdHXPsfAl4wYFh1rvrhKaeiKyXOuAmXlfypsBjlHeYHeE8dei4woneytQoRet66WwHge8BcVdbOoQk6aLacWXPr4mGahQYSwovyuBA)j)PDVfCWqczirr3cbcULtdbyN2BMN010iObbxEcVdbcULtdb4LcWWb7dbOoQk6aLaAqWVr4Dia1rvrhOeqGGB50qaWsLsZhw2OpqaooncNbeynCMhjUGe84nnM8OgjKdjwdN5DSXUqaEXCfPTa7r2dbViObbxYcVdbOoQk6aLacWXPr4mGalgLsJjEPa7rAlzjKqoKWJFqcqGqcjHewOO2CBs1zLysN9I5ZPDuhvfDqcqGqIZyUVeo8BsPRdB1zjhSS9qITiXzmx2gH7qPRkIoz75El4GHeYHefaceClNgcuzmEjcxm0GGx0TW7qaQJQIoqjGaCCAeodiGfkQnNhdHXPsfAl4wYFh1rvrhiqWTCAiapWLjObbVOIG3HauhvfDGsab440iCgqG1WzEK4csWJ30yYJAKqoKynCM3Xg7cbcULtdbwQOblBp9B4emcAqWls6W7qaQJQIoqjGaCCAeodiWzm3MuDwjM01HT6W0ctFPOQiKaeiKWcf1MBtQoRet6SxmFoTJ6OQOdei4woneytQoRet66WwHge8Ika8oeG6OQOduciqWTCAiWtyFQn9Bz7bb440iCgqGkZA5kN(e(1LPEyDyk4geGxmxrAlWEK9qWlcAqWlANG3HauhvfDGsab440iCgqa(mQZSPDBs1zLysxh2QdtSr2psivKOCGZOQihpWLjn)GrIDMiH0Hab3YPHa8axMGge8IKp8oei4wone4nIuAdh(qaQJQIoqjGge8IUj8oeG6OQOduciahNgHZacyHIAZzeM91ZstTx4rSuBoQJQIoqGGB50qGsb2FMgAqWlsEcVdbOoQk6aLaceClNgc8e2NAt)w2EqaooncNbeatlm9LIQIqITirLzTCw6RNL2kr63NcS7TGdgsihsuaiaVyUI0wG9i7HGxe0GGx0ncVdbOoQk6aLacWXPr4mGahQYSwovyuBA)j)PDm(qGGB50qa2P9M5jDnncAqWlsYcVdbOoQk6aLacWXPr4mGahQYSwovyuBA)j)PDm(qGGB50qaC4Bdw)gobJGg0GahAfmkdEhcErW7qaQJQIoqjGaCCAeodiWHQmRLJhVLTNJXhjabcjouLzTCN89jLkQksZgEj3X4JeGaHehQYSwUt((KsfvfPPghEKJXhceClNgcWdLshClNwRY3GaQ8nDhSeeGXsvAfdni4shEhceClNgcW8KonI9HauhvfDGsani4faEhcqDuv0bkbei4woneGhkLo4woTwLVbbu5B6oyjia)8qdc(obVdbOoQk6aLacWXPr4mGab3YYKMAInPhjKdjkasSfjSqrT52KQZkXKo7fZNt7OoQk6GeBrcluuBUq5xk0(y6e2GDuhvfDqITiHfkQnh70EZ8KUMg5OoQk6abcULtdb4HsPdULtRv5Bqav(MUdwccWw1HVEZk1Vbni4YhEhcqDuv0bkbeGJtJWzabcULLjn1eBspsihsuaKylsyHIAZTjvNvIjD2lMpN2rDuv0bceClNgcWdLshClNwRY3GaQ8nDhSeeyZk1Vbni43eEhcqDuv0bkbeGJtJWzabcULLjn1eBspsihsiDiqWTCAiapukDWTCATkFdcOY30DWsqG3GgeC5j8oeG6OQOduciahNgHZaceClltAQj2KEKqQirrqGGB50qaEOu6GB50Av(geqLVP7GLGaCffLjObb)gH3Hab3YPHabMhnPTbJP2GauhvfDGsanObb8XeFyRHbVdbVi4Dia1rvrhOeqdcU0H3HauhvfDGsani4faEhcqDuv0bkb0GGVtW7qGGB50qGNHLDATpzqaQJQIoqjGgeC5dVdbOoQk6aLaAqWVj8oei4woneWFSCAia1rvrhOeqdcU8eEhceClNgc8grkTHdFia1rvrhOeqdc(ncVdbcULtdbkfy)zAia1rvrhOeqdAqG3G3HGxe8oei4wonei0Sm4dH1ZsZXZMhcqDuv0bkb0GGlD4Dia1rvrhOeqaooncNbeWcf1MRM4ZRNL2htf7OoQk6GeBrIkZA54ZGpzhgD0X)bJYCm(iXwKqAirLzTC8zWNSdJo64)GrzomXgz)iHCiHh)GeGaHevM1Yvvmy9S0wOM(Dm(iXwKOYSwUQIbRNL2c10VdtSr2psihs4XpiHuGab3YPHaSt7nZt6AAe0GGxa4Dia1rvrhOeqaooncNbeWcf1MRM4ZRNL2htf7OoQk6GeBrIkZA54ZGpzhgD0X)bJYCm(iXwKqAirLzTC8zWNSdJo64)GrzomXgz)iHCiHh)GeGaHevM1Yvvmy9S0wOM(Dm(iXwKOYSwUQIbRNL2c10VdtSr2psihs4XpiHuGab3YPHa4W3gS(nCcgbni47e8oeG6OQOduciahNgHZacuzwlx50NWVUm1dRdtb3qITirLzTCLtFc)6YupSomXgz)iHCiHh)abcULtdbEc7tTPFlBpObbx(W7qaQJQIoqjGaCCAeodiWA4mpsCbj4XBAm5rnsihsSgoZ7yJDrITiH0qcjHewOO2CHYVuO9X0jSb7OoQk6GeGaHewOO2CHYVuO9X0jSb7OoQk6GeBrIfJsPXeVuG9iTLSesihsuKt(iXoIeE8dsSfjIcs40iNpozPYHsNTXKwoTJ6OQOdsSfjwdN5rIlibpEtJjpQrc5qIIU9wKaeiKqsiruqcNg58Xjlvou6SnM0YPDuhvfDqITiXA4mpsCbj4XBAm5rnsihsCJ3IesbceClNgcawQuA(WYg9bAqWVj8oeG6OQOduciahNgHZacSgoZJexqcE8MgtEuJeYHeRHZ8o2yxKylsinKyXOuAmXlfypsBjlHeYHeE8dsacesijK4mMBtQoRet66WwDwYblBpKylsinKOYSwo2P9M5j9IbxS7mBAKaeiKyXOuAmXlfypsBjlHeYHe7Kt(iXoIeE8dsifKqkqGGB50qGnP6SsmPRdBfAqWLNW7qaQJQIoqjGaCCAeodiqLzTCLtFc)6YupSomfCdj2IeNXCpH9P20VLTNdtSr2psihsStiXoIeE8dsacesijKWcf1MRC6t4xxM6H1rDuv0bj2IescjoJ5Ec7tTPFlBpNLCWY2dj2IescjQmRLJpd(KDy0rh)hmkZX4dbcULtdbEc7tTPFlBpObb)gH3HauhvfDGsab440iCgqamTW0xkQkcj2IesdjIcs40iNkmQnT)K)0oC0GHesfjKosacesefKWProvyuBA)j)PDuhvfDqITiruqcNg5kt9WomVEfT37OoQk6GeGaHesdjIcs40iNkmQnT)K)0oQJQIoibiqiruqcNg5kt9WomVEfT37OoQk6Gesbj2IesdjKesefKWPrUQIbRNL2c10VJ6OQOdsacesijKWcf1MRM4ZRNL2htf7OoQk6GeGaHescjQmRLJpd(KDy0rh)hmkZX4JesbjKcei4wone4jSp1M(TS9GgeCjl8oei4wone4nIuAdh(qaQJQIoqjGge8IUfEhcqDuv0bkbeGJtJWzabSqrT5mcZ(6zPP2l8iwQnh1rvrhiqWTCAiqPa7ptdni4fve8oei4woneGpd(KDy0rh)hmkdcqDuv0bkb0GGxK0H3Hab3YPHa8sby4G9HauhvfDGsani4fva4Dia1rvrhOeqaooncNbeynCMhjUGe84nnM8OgjKdjwdN5DSXUqGGB50qGLkAWY2t)gobJGge8I2j4Dia1rvrhOeqaooncNbeynCMhjUGe84nnM8OgjKdjwdN5DSXUiXwKqAirLzTCSt7nZt6fdUy3BbhmKqoKyNqcqGqI1WzEKqoKi4woTJDAVzEsxtJC85nKqkqGGB50qaWsLsZhw2OpqdcErYhEhcqDuv0bkbeGJtJWzabQmRLJDAVzEsVyWf7y8rcqGqcPHerbjCAKZhNSu5qPZ2yslN2rDuv0bj2IesdjwdN5rIlibpEtJjpQrcPIefv0TibiqiHfkQnx50NWVUm1dRJ6OQOdsSfjwdN5rcPIefD7TiHuqcPGeGaHesdjKesefKWProFCYsLdLoBJjTCAh1rvrhKylsinKynCMhjUGe84nnM8OgjKksizVfjabcjSqrT5kN(e(1LPEyDuhvfDqITiXA4mpsCbj4XBAm5rnsivK4gVfjKcsifKaeiKOYSwo(m4t2HrhD8FWOmhJpei4woneGDAVzEsxtJGge8IUj8oei4woneah(2G1VHtWiia1rvrhOeqdcErYt4Dia1rvrhOeqaooncNbe4mM7jSp1M(TS9CyAHPVuuvesSfjKesuzwlhFg8j7WOJo(pyuMJXhceClNgc8e2NAt)w2EqdcEr3i8oeG6OQOduciahNgHZacCgZTjvNvIjDDyRomTW0xkQkcceClNgcSjvNvIjDDyRqdAqa(5H3HGxe8oeG6OQOduciahNgHZacWNrDMnTJpd(KDy0rh)hmkZHj2i7hjKksuGBHab3YPHav1mh9Ibxm0GGlD4Dia1rvrhOeqaooncNbeGpJ6mBAhFg8j7WOJo(pyuMdtSr2psivKOa3cbcULtdbIMtVHdLMhkf0GGxa4Dia1rvrhOeqaooncNbeGpJ6mBAhFg8j7WOJo(pyuMdtSr2psivKOa3cbcULtdbwjMQQzoqdc(obVdbcULtdbuPxj7178mhpwQnia1rvrhOeqdcU8H3HauhvfDGsab440iCgqa(mQZSPD8zWNSdJo64)GrzomXgz)iHurIBElsacesyjlPTrFscjKdjkQiiqWTCAiqLWpHblBpObb)MW7qaQJQIoqjGaCCAeodiqLzTC8zWNSdJo64)GrzogFKylsinKOYSwUkHFcdw2EogFKaeiKOYSwUQAMJEXGl2X4JeGaHescjWbNCgEukKylsijKahCYnyosifKaeiKWswsBJ(Kesihsi9BcbcULtdb8hlNgAqWLNW7qaQJQIoqjGaCCAeodiGfypYCN8TO5esivziXnHab3YPHaX7tCtplTvI0u4PiObniaBvh(6nRu)g8oe8IG3HauhvfDGsab440iCgqajHeNXCpH9P20VLTNZsoyz7bbcULtdbEc7tTPFlBpObbx6W7qaQJQIoqjGaCCAeodiWIrP0yIxkWEK2swcjKdj84hKaeiKqAiXA4mpsCbj4XBAm5rnsihsSgoZ7yJDrcPGeBrcPHenTRP3K66WwDLhvyPIqITiXzm3tyFQn9Bz75SKdw2EiXwK4mM7jSp1M(TS9CyAHPVuuvesaces00UMEtQRdB15xIWd70esSfjKesuzwlh70EZ8KEXGl2X4JeBrI1WzEK4csWJ30yYJAKqoKynCM3Xg7Ie7aseClN2bwQuA(WYg9XXJ30yYJAKyhrIcGesbceClNgcSjvNvIjDDyRqdcEbG3Hab3YPHa8zWNSdJo64)GrzqaQJQIoqjGge8DcEhceClNgceAwg8HW6zP54zZdbOoQk6aLaAqWLp8oei4wone4nIuAdh(qaQJQIoqjGge8BcVdbOoQk6aLacWXPr4mGavM1YXoT3mpPxm4IDyInY(rITirt7A6nPUoSvNFjcpSttqGGB50qa2P9M5jDnncAqWLNW7qaQJQIoqjGaCCAeodiWA4mpsCbj4XBAm5rnsihsSgoZ7yJDrITiH0qIkZA5yN2BMN0lgCXU3coyiHCiH8rcqGqI1WzEKqoKi4woTJDAVzEsxtJC85nKqkqGGB50qaWsLsZhw2Opqdc(ncVdbOoQk6aLacWXPr4mGanTRP3K66WwDFjC43Kcj2IeRHZ8iHurIBElsSfjoJ5Ec7tTPFlBphMyJSFKqQirbqIDej84hiqWTCAiWMuDwjM01HTcni4sw4Dia1rvrhOeqaooncNbeatlm9LIQIqITiH0qIM210BsDDyRUYJkSuriXwKqsiXzm3xch(nP01HT6SKdw2EibiqiruqcNg5uHrTP9N8N2rDuv0bjabcjIcs40ixzQh2H51RO9Eh1rvrhKqkqGGB50qGNW(uB63Y2dAqWl6w4Dia1rvrhOeqaooncNbeOYSwo2P9M5j9IbxSJXhjabcjwdN5rcPIe38wKaeiK4mM7lHd)Mu66WwDwYblBpiqWTCAia70EZ8KUMgbni4fve8oeG6OQOduciahNgHZacGPfM(srvrqGGB50qGNW(uB63Y2dAqWls6W7qaQJQIoqjGaCCAeodiqt7A6nPUoSvx5rfwQiKylsCgZ9e2NAt)w2Eol5GLThsaces00UMEtQRdB15xIWd70esaces00UMEtQRdB19LWHFtkKylsSgoZJesfjK)TqGGB50qGnP6SsmPRdBfAqdcWyPkTIH3HGxe8oei4woneGLPGfurqaQJQIoqjGgeCPdVdbcULtdbEctDAfRpmVbbOoQk6aLaAqWla8oei4wone49hmP5QH5abOoQk6aLaAqW3j4DiqWTCAiWpJvkBp9MWimeG6OQOducObbx(W7qGGB50qGF6KRRQ4nia1rvrhOeqdc(nH3Hab3YPHanzLiS(lnCWGauhvfDGsani4Yt4DiqWTCAiaVuUZNV2WrVZIjvPvmeG6OQOducObb)gH3Hab3YPHaVFItt)LgoyqaQJQIoqjGgeCjl8oei4woneOdJbtV2dhCccqDuv0bkb0Gg0GaLj8Ntdbx63wKK9wPxK80D7TfjDiWMa3z79qGDUS(d2OdsCJirWTCAKqLV9o0EiGpEwPIGasosaWGlNLdfsiVY0gHr7LCKOKz(VKX1REPvIP64d71pzzuHLtZXXYU(jl)Avn1R1vSdhQ8vF8Ssf9xVHysEh55VEdL3A5vM2iSgGbxolhk3NSC0Ejhj2zqvmtGlgjK(nlejK(TfjzrIDajKEbKmK)TO9O9sosiVukAp6Lmq7LCKyhqc5X5qhK4gWuWcQiKWgK4qRGrzirWTCAKqLV5q7LCKyhqc5Lsr7rhKWcShz6CHe0U(y6)C6hjSbj4fZvK2cShzVdTxYrIDajUbZjxjDqcEGltA(bJe2GeBgmyib7GjKGIpvfJeBsResyLiKioNP3z)irY6RiwQTWYPrIzHeLdCgvf5q7LCKyhqc5X5qhKGXsvAfJeYJB4ohhApAVKJesM7sCgJoirLwdMqc(WwddjQKx2VdjKhCo5Bps0tVdLcm7IrHeb3YPFKyAvXo0(GB50VZht8HTgMSLkEWq7dULt)oFmXh2AyxKDny8yP2clNgTp4wo978XeFyRHDr211mh0(GB50VZht8HTg2fzxFgw2P1(KH2l5ibqh(FPXqcCKhKOYSw0bjElShjQ0AWesWh2AyirL8Y(rIOpiHpM2b)XSS9qI8rIZ0KdTp4wo978XeFyRHDr21Vd)V0y63c7r7dULt)oFmXh2AyxKD1FSCA0(GB50VZht8HTg2fzxFJiL2WHpAFWTC635Jj(Wwd7ISRLcS)mnApAFWTC63XyPkTILXYuWcQi0(GB50VJXsvAfFr21NWuNwX6dZBO9b3YPFhJLQ0k(ISRV)Gjnxnmh0(GB50VJXsvAfFr21FgRu2E6nHry0(GB50VJXsvAfFr21F6KRRQ4n0(GB50VJXsvAfFr21MSsew)LgoyO9b3YPFhJLQ0k(ISR8s5oF(Adh9olMuLwXO9b3YPFhJLQ0k(ISRVFItt)LgoyO9b3YPFhJLQ0k(ISRDymy61E4GtO9O9sosizUlXzm6GeuzcxmsyjlHewjcjcUnyKiFKikhPkQkYH2hClN(LXdLshClNwRY3kSdwsgJLQ0kUWCj7qvM1YXJ3Y2ZX4dc0HQmRL7KVpPurvrA2Wl5ogFqGouLzTCN89jLkQkstno8ihJpApAFWTC6)ISRmpPtJyF0(GB50)fzx5HsPdULtRv5Bf2bljJFE0(GB50)fzx5HsPdULtRv5Bf2bljJTQdF9MvQFRWCjl4wwM0utSj9YvGTwOO2CBs1zLysN9I5ZPDuhvfD2AHIAZfk)sH2htNWgSJ6OQOZwluuBo2P9M5jDnnYrDuv0bTp4wo9Fr2vEOu6GB50Av(wHDWsY2Ss9BfMlzb3YYKMAInPxUcS1cf1MBtQoRet6SxmFoTJ6OQOdAFWTC6)ISR8qP0b3YP1Q8Tc7GLK9wH5swWTSmPPMyt6Lt6O9b3YP)lYUYdLshClNwRY3kSdwsgxrrzQWCjl4wwM0utSj9sTi0(GB50)fzxdmpAsBdgtTH2J2hClN(D8ZlRQM5Oxm4IlmxY4ZOoZM2XNbFYom6OJ)dgL5WeBK9l1cClAFWTC63Xp)fzxJMtVHdLMhkvH5sgFg1z20o(m4t2HrhD8FWOmhMyJSFPwGBr7dULt)o(5Vi76kXuvnZPWCjJpJ6mBAhFg8j7WOJo(pyuMdtSr2VulWTO9b3YPFh)8xKDvLELSxVZZC8yP2q7dULt)o(5Vi7ALWpHblBVcZLm(mQZSPD8zWNSdJo64)GrzomXgz)s9M3ccKLSK2g9jj5kQi0(GB50VJF(lYU6pwoDH5swLzTC8zWNSdJo64)Grzog)TsRYSwUkHFcdw2EogFqGQmRLRQM5Oxm4IDm(GajjCWjNHhLARKWbNCdMlfqGSKL02OpjjN0VjAFWTC63Xp)fzxJ3N4MEwARePPWtrfMlzwG9iZDY3IMtsv2nr7r7dULt)oUIIYKSYboJQIkSdwsgpWLjn)GlC8L9Kvy5qXqYcULLjn1eBsVuL)w5dcuWTSmPPMyt6r7dULt)oUIIY0fzxdnld(qy9S0C8S5r7dULt)oUIIY0fzx5ZGpzhgD0X)bJYq7dULt)oUIIY0fzx5bUmvyUKDgZ9LWHFtkDDyRol5GLThAFWTC63XvuuMUi76MuDwjM01HTwyUKjjluuBopgcJtLk0wWTK)oQJQIoGaTyuknM4LcShPTKLKZJFq7dULt)oUIIY0fzxzN2BMN010OcZLSdvzwlNkmQnT)K)0U3coyYk6w0(GB50VJROOmDr2vEPamCW(O9b3YPFhxrrz6ISRGLkLMpSSrFkKxmxrAlWEK9YkQWCjBnCM)cpEtJjpQLBnCM3Xg7I2hClN(DCffLPlYUwzmEjcxCH5s2IrP0yIxkWEK2swsop(beijzHIAZTjvNvIjD2lMpN2rDuv0beOZyUVeo8BsPRdB1zjhSS92EgZLTr4ou6QIOt2EU3coyYva0(GB50VJROOmDr2vEGltfMlzwOO2CEmegNkvOTGBj)DuhvfDq7dULt)oUIIY0fzxxQOblBp9B4emQWCjBnCM)cpEtJjpQLBnCM3Xg7I2hClN(DCffLPlYUUjvNvIjDDyRfMlzNXCBs1zLysxh2Qdtlm9LIQIabYcf1MBtQoRet6SxmFoTJ6OQOdAFWTC63XvuuMUi76tyFQn9Bz7viVyUI0wG9i7LvuH5swLzTCLtFc)6YupSomfCdTp4wo974kkktxKDLh4YuH5sgFg1z20UnP6SsmPRdB1Hj2i7xQLdCgvf54bUmP5h8otPJ2hClN(DCffLPlYU(grkTHdF0(GB50VJROOmDr21sb2FMUWCjZcf1MZim7RNLMAVWJyP2CuhvfDq7dULt)oUIIY0fzxFc7tTPFlBVc5fZvK2cShzVSIkmxYW0ctFPOQOTvM1YzPVEwARePFFkWU3coyYva0EjhjUpiXNSmQWiKG5dpcjwdgjUbt7nZtiHePriXGrc5D4BdgjamCcgHehgC2EiH849jUHeZcjSsesizgEkQqKGp(fJeuWlHedNZGXuZjKywiHvIqIGB50ir0hKi89P(GeAk8uesydsyLiKi4wons0bl5q7dULt)oUIIY0fzxzN2BMN010OcZLSdvzwlNkmQnT)K)0ogF0(GB50VJROOmDr2vC4Bdw)gobJkmxYouLzTCQWO20(t(t7y8r7r7dULt)o2Qo81BwP(nzpH9P20VLTxH5sMKoJ5Ec7tTPFlBpNLCWY2dTp4wo97yR6WxVzL63Ui76MuDwjM01HTwyUKTyuknM4LcShPTKLKZJFabsARHZ8x4XBAm5rTCRHZ8o2yxPSvAnTRP3K66WwDLhvyPI2EgZ9e2NAt)w2Eol5GLT32ZyUNW(uB63Y2ZHPfM(srvrGa10UMEtQRdB15xIWd700wjvzwlh70EZ8KEXGl2X4VDnCM)cpEtJjpQLBnCM3Xg7Udb3YPDGLkLMpSSrFC84nnM8OEhlGuq7dULt)o2Qo81BwP(TlYUYNbFYom6OJ)dgLH2hClN(DSvD4R3Ss9BxKDn0Sm4dH1ZsZXZMhTp4wo97yR6WxVzL63Ui76BeP0go8r7LCK4(GeFYYOcJqcMp8iKynyK4gmT3mpHesKgHedgjK3HVnyKaWWjyesCyWz7HeYJ3N4gsmlKWkriHKz4POcrc(4xmsqbVesmCodgtnNqIzHewjcjcULtJerFqIW3N6dsOPWtriHniHvIqIGB50irhSKdTp4wo97yR6WxVzL63Ui7k70EZ8KUMgvyUKvzwlh70EZ8KEXGl2Hj2i7FBt7A6nPUoSvNFjcpSttO9b3YPFhBvh(6nRu)2fzxblvknFyzJ(uyUKTgoZFHhVPXKh1YTgoZ7yJD3kTkZA5yN2BMN0lgCXU3coyYjFqGwdN5Ll4woTJDAVzEsxtJC85nPG2hClN(DSvD4R3Ss9BxKDDtQoRet66WwlmxYAAxtVj11HT6(s4WVj121WzEPEZB3EgZ9e2NAt)w2EomXgz)sTa7Oh)G2hClN(DSvD4R3Ss9BxKD9jSp1M(TS9kmxYW0ctFPOQOTsRPDn9Muxh2QR8Oclv0wjDgZ9LWHFtkDDyRol5GLThiqrbjCAKtfg1M2FYFAh1rvrhqGIcs40ixzQh2H51RO9Eh1rvrhPG2hClN(DSvD4R3Ss9BxKDLDAVzEsxtJkmxYQmRLJDAVzEsVyWf7y8bbAnCMxQ38wqGoJ5(s4WVjLUoSvNLCWY2dTp4wo97yR6WxVzL63Ui76tyFQn9Bz7vyUKHPfM(srvrO9b3YPFhBvh(6nRu)2fzx3KQZkXKUoS1cZLSM210BsDDyRUYJkSurBpJ5Ec7tTPFlBpNLCWY2deOM210BsDDyRo)seEyNMabQPDn9Muxh2Q7lHd)MuBxdN5LQ8VfThTp4wo97EtwOzzWhcRNLMJNnpAVKJe3hK4twgvyesW8HhHeRbJe3GP9M5jKqI0iKyWiH8o8TbJeagobJqIddoBpKqE8(e3qIzHewjcjKmdpfvisWh)Irck4LqIHZzWyQ5esmlKWkrirWTCAKi6dse((uFqcnfEkcjSbjSseseClNgj6GLCO9b3YPF3BxKDLDAVzEsxtJkmxYSqrT5Qj(86zP9XuXoQJQIoBRmRLJpd(KDy0rh)hmkZX4VvAvM1YXNbFYom6OJ)dgL5WeBK9lNh)acuLzTCvfdwplTfQPFhJ)2kZA5QkgSEwAlut)omXgz)Y5XpsbTp4wo97E7ISR4W3gS(nCcgvyUKzHIAZvt851Zs7JPIDuhvfD2wzwlhFg8j7WOJo(pyuMJXFR0QmRLJpd(KDy0rh)hmkZHj2i7xop(beOkZA5QkgSEwAlut)og)TvM1Yvvmy9S0wOM(DyInY(LZJFKcAFWTC6392fzxFc7tTPFlBVcZLSkZA5kN(e(1LPEyDyk422kZA5kN(e(1LPEyDyInY(LZJFq7dULt)U3Ui7kyPsP5dlB0NcZLS1Wz(l84nnM8OwU1WzEhBS7wPjjluuBUq5xk0(y6e2GDuhvfDabYcf1Mlu(LcTpMoHnyh1rvrNTlgLsJjEPa7rAlzj5kYj)D0JF2gfKWProFCYsLdLoBJjTCAh1rvrNTRHZ8x4XBAm5rTCfD7TGajPOGeonY5JtwQCO0zBmPLt7OoQk6SDnCM)cpEtJjpQL7gVvkO9b3YPF3BxKDDtQoRet66WwlmxYwdN5VWJ30yYJA5wdN5DSXUBL2IrP0yIxkWEK2swsop(beijDgZTjvNvIjDDyRol5GLT3wPvzwlh70EZ8KEXGl2DMnniqlgLsJjEPa7rAlzj52jN83rp(rksbTp4wo97E7ISRpH9P20VLTxH5swLzTCLtFc)6YupSomfCB7zm3tyFQn9Bz75WeBK9l3oTJE8diqsYcf1MRC6t4xxM6H1rDuv0zRKoJ5Ec7tTPFlBpNLCWY2BRKQmRLJpd(KDy0rh)hmkZX4J2hClN(DVDr21NW(uB63Y2RWCjdtlm9LIQI2kTOGeonYPcJAt7p5pTdhnysv6GaffKWProvyuBA)j)PDuhvfD2gfKWPrUYupSdZRxr79oQJQIoGajTOGeonYPcJAt7p5pTJ6OQOdiqrbjCAKRm1d7W86v0EVJ6OQOJu2knjffKWPrUQIbRNL2c10VJ6OQOdiqsYcf1MRM4ZRNL2htf7OoQk6acKKQmRLJpd(KDy0rh)hmkZX4lfPG2hClN(DVDr213isPnC4J2hClN(DVDr21sb2FMUWCjZcf1MZim7RNLMAVWJyP2CuhvfDq7dULt)U3Ui7kFg8j7WOJo(pyugAFWTC6392fzx5LcWWb7J2hClN(DVDr21LkAWY2t)gobJkmxYwdN5VWJ30yYJA5wdN5DSXUO9b3YPF3BxKDfSuP08HLn6tH5s2A4m)fE8MgtEul3A4mVJn2DR0QmRLJDAVzEsVyWf7El4Gj3obc0A4mVCb3YPDSt7nZt6AAKJpVjf0(GB50V7TlYUYoT3mpPRPrfMlzvM1YXoT3mpPxm4IDm(GajTOGeonY5JtwQCO0zBmPLt7OoQk6SvARHZ8x4XBAm5rTulQOBbbYcf1MRC6t4xxM6H1rDuv0z7A4mVul62BLIuabsAskkiHtJC(4KLkhkD2gtA50oQJQIoBL2A4m)fE8MgtEulvj7TGazHIAZvo9j8Rlt9W6OoQk6SDnCM)cpEtJjpQL6nERuKciqvM1YXNbFYom6OJ)dgL5y8r7dULt)U3Ui7ko8TbRFdNGrO9b3YPF3BxKD9jSp1M(TS9kmxYoJ5Ec7tTPFlBphMwy6lfvfTvsvM1YXNbFYom6OJ)dgL5y8r7dULt)U3Ui76MuDwjM01HTwyUKDgZTjvNvIjDDyRomTW0xkQkcThTp4wo972Ss9BYcnld(qy9S0C8S5r7dULt)UnRu)2fzx5ZGpzhgD0X)bJYq7LCK4(GeFYYOcJqcMp8iKynyK4gmT3mpHesKgHedgjK3HVnyKaWWjyesCyWz7HeYJ3N4gsmlKWkriHKz4POcrc(4xmsqbVesmCodgtnNqIzHewjcjcULtJerFqIW3N6dsOPWtriHniHvIqIGB50irhSKdTp4wo972Ss9BxKDLDAVzEsxtJkmxYIcs40i3MuDiCt)RFgC5SCOCuhvfD220UMEtQRdB1vEuHLkA7zm3tyFQn9Bz75WeBK9lvP7kAh94NTNXCpH9P20VLTNdtSr2VCfWj)D0JF2YNrDMnTBtQoRet66WwDyInY(LQ0DYFh94h0(GB50VBZk1VDr21nP6SsmPRdBTWCjBXOuAmXlfypsBjljNh)acK0wdN5VWJ30yYJA5wdN5DSXUszR0AAxtVj11HT6kpQWsfT9mM7jSp1M(TS9CwYblBVTNXCpH9P20VLTNdtlm9LIQIabQPDn9Muxh2QZVeHh2PPTsQYSwo2P9M5j9IbxSJXF7A4m)fE8MgtEul3A4mVJn2DhcULt7alvknFyzJ(44XBAm5r9owaPG2hClN(DBwP(TlYUcwQuA(WYg9PWCjBnCM)cpEtJjpQLBnCM3Xg7UTYSwol91ZsBLi97tb29wWbtUcSvAsYcf1Mlu(LcTpMoHnyh1rvrhqGQmRLJDAVzEsVyWf7El4GjN8bbAnCMxUGB50o2P9M5jDnnYXN3KcAFWTC63TzL63Ui7ko8TbRFdNGrfMlzNXCzBeUdLUQi6KTN7TGdMCfy7zm3xch(nP01HT6SKdw2EBLKfkQnh70EZ8KUMg5OoQk6G2hClN(DBwP(TlYUUjvNvIjDDyRfMlznTRP3K66WwDFjC43KABLzTCSt7nZt6fdUy3z20BLgFg1z20oWsLsZhw2OpomXgz)s1JFabAnCMxQ38wPSvsNXCpH9P20VLTNdtlm9LIQIq7dULt)UnRu)2fzxFJiL2WHpAFWTC63TzL63Ui76sfnyz7PFdNGrfMlzRHZ8x4XBAm5rTCRHZ8o2yx0(GB50VBZk1VDr21NW(uB63Y2RWCjRYSwUYPpHFDzQhwhMcUbceMwy6lfvfTvAsYcf1MJDAVzEsxtJCuhvfDabsswOO2CLtFc)6YupSoQJQIoGa10UMEtQRdB1vEuHLkARKoJ5(s4WVjLUoSvNLCWY2deOOGeonYPcJAt7p5pTJ6OQOdiqrbjCAKRm1d7W86v0EVJ6OQOdiqvM1YXoT3mpPxm4IDVfCWKjFPG2hClN(DBwP(TlYUwkW(Z0fMlzwOO2CgHzF9S0u7fEel1MJ6OQOdAFWTC63TzL63Ui7k70EZ8KUMgvyUKvzwlh70EZ8KEXGl2X4dc0A4mVuV5TGaDgZ9LWHFtkDDyRol5GLThAFWTC63TzL63Ui7ko8TbRFdNGrO9b3YPF3MvQF7ISRpH9P20VLTxH5sgMwy6lfvfH2hClN(DBwP(TlYUUjvNvIjDDyRfMlznTRP3K66WwDLhvyPI2EgZ9e2NAt)w2Eol5GLThiqnTRP3K66WwD(Li8Wonbcut7A6nPUoSv3xch(nP2UgoZlv5Fle49joeCPlF5dnObHa]] )

    
end