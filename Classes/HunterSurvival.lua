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


    spec:RegisterPack( "Survival", 20190211.1337, [[dGKdobqicKhbkQlPIa1Mur9jveiJIQsofHQwLkI8kq0SOQ4weQ0UOYVaHHrvPogHYYKi1ZiqnncvCnjs2gOqFtfrnoqr6CesyDGIW8ie3JG2hHuhKqIwib8qcjXfbfrBufbyKessNufbPvQcMPkcIBQIq2jO0qvrOwkHK6PQ0ubj7f4VKAWKCyHflPhJQjRuxgzZk5ZuLrtv1PfTAveuVgKA2eDBuSBf)wQHlHJRIaA5q9CvnDkxhL2Uk03LOgVksNxIy9GcMpOA)qgigakWDhgbGT0(wmrHVlTyI5etWIJyIjkaxRKccClco0HhbUtWqG7LfFmpgsWTikr2Xgaf4(nlMtGRFZkEyciGWln)SvhVzG4tgwzyzpCCSmi(KHdrv2viQRqC30rikW9kL0dXjgtI6i3peNyrTwuLDmcRVS4J5Xq6(KHdUv2uANqhqfC3HraylTVftu47slMyoXeSGpzX5Kb3G183yW9MmSYWYEevWXYax)5EtdOcUB65GlmJuxw8X8yirkrv2Xim6amJu(nR4HjGacV08ZwD8MbIpzyLHL9WXXYG4tgoevzxHOUcXDthHOa3RuspeNymjQJC)qCIf1Arv2XiS(YIpMhdP7tgo6amJuNaOkMnWLGuIjMpivP9TyIcKsCrkXemmHGpz0b0bygPev8hJh9WeOdWmsjUiLOCVPnsDIyHbyqsiL1i1MwbR0qQGBzpiLmFZHoaZiL4IuIk(JXJ2iLfypY05cPOtlW0)zppsznsXlHljTfypYEh6amJuIlsDI6DUsAJu8aFK08ngPSgPk3yOrkMgtiffFklbPkNMFKY8tivS39Cc6rQKPqsm0yHL9Gu9cPog4mQsYHoaZiL4IuIY9M2ifRLY0kbPeLN4tioWvMV9aOa3YRu)gakaSIbGcCdUL9aUHMHfVjSUxAoUl)GlnrvsBGaadaBPbqbUb3YEaxE34DoHrBD8FWknWLMOkPnqaGbGvWaOaxAIQK2abaxooncNb4gWaHtJCLt5MWd9V(zXhZJH0rtuL0gPoJudDQPlN6AZuDhBzyPKqQZi1Un3t4cAm9B545WetKZJuIgPkTtmK6Kqkp(gPoJu72CpHlOX0VLJNdtmropsjcsjyxPqQtcP84BK6msX7wU7YJRCk3Ret6AZuDyIjY5rkrJuL2vkK6Kqkp(gCdUL9aUm9419t6AAeWaWkoaOaxAIQK2abaxooncNb4UyLsnM4(dShPTKHqkrqkp(gPGdhP8fsTAo7JuqIu84nnM8ObPebPwnN9DmXPiL4rQZiLVqQHo10LtDTzQUJTmSusi1zKA3M7jCbnM(TC8CwYHohpK6msTBZ9eUGgt)woEomTW07pQscPGdhPg6utxo11MP6k8t4MPhcPoJuccPQSRLJPhVUFsVyXL4ylqQZi1Q5SpsbjsXJ30yYJgKseKA1C23XeNIuIlsfCl7XbDkLAEZWeZ2XJ30yYJgK6KqkbJuIhCdUL9aULt5ELysxBMkWaWwkauGlnrvsBGaGlhNgHZaCxnN9rkirkE8MgtE0GuIGuRMZ(oM4uK6msvzxlNLf6EPn)K(lOa7El4qJuIGucgPoJu(cPeeszHKgZfYc)HUat7WASJMOkPnsbhosvzxlhtpED)KEXIlX9wWHgPebPkfsbhosTAo7JuIGub3YECm9419t6AAKJ3VHuIhCdUL9aUqNsPM3mmXSbgawyeaf4stuL0gia4YXPr4ma3DBUCmcpHuxLeTZXZ9wWHgPebPemsDgP2T5E)4OyiPU2mvNLCOZXdPoJuccPSqsJ5y6XR7N010ihnrvsBWn4w2d4IJcRX63Wj0eWaWEYaOaxAIQK2abaxooncNb4o0PMUCQRnt19(XrXqsK6msvzxlhtpED)KEXIlXT7YdsDgP8fsX7wU7YJd6uk18MHjMTdtmropsjAKYJVrk4WrQvZzFKs0ifm6BKs8i1zKsqi1Un3t4cAm9B545W0ctV)OkjWn4w2d4woL7vIjDTzQadalmfaf4gCl7bCFJiP2Wrb4stuL0giaWaWkkaqbU0evjTbcaUCCAeodWD1C2hPGeP4XBAm5rdsjcsTAo77yItb3GBzpG7sgd054PFdNqtadaRy(gaf4stuL0gia4YXPr4ma3k7A5oMfe(1hPPzCyk4gsbhosHPfME)rvsi1zKYxiLGqklK0yoME86(jDnnYrtuL0gPGdhPeeszHKgZDmli8RpstZ4OjQsAJuWHJudDQPlN6AZuDhBzyPKqQZiLGqQDBU3pokgsQRnt1zjh6C8qk4WrQagiCAKtggnMUOZVhhnrvsBKcoCKkGbcNg5ostZ0SVEfJ37OjQsAJuWHJuv21YX0Jx3pPxS4sCVfCOrkHivPqkXdUb3YEa3NWf0y63YXdyayftmauGlnrvsBGaGlhNgHZaCTqsJ5mcZ86EPPXl8igAmhnrvsBWn4w2d46pWfDpadaRyLgaf4stuL0gia4YXPr4ma3k7A5y6XR7N0lwCjo2cKcoCKA1C2hPensbJ(gPGdhP2T5E)4OyiPU2mvNLCOZXdCdUL9aUm9419t6AAeWaWkMGbqbUb3YEaxCuynw)goHMaxAIQK2abagawXehauGlnrvsBGaGlhNgHZaCX0ctV)OkjWn4w2d4(eUGgt)woEadaRyLcaf4stuL0gia4YXPr4ma3Ho10LtDTzQUJTmSusi1zKA3M7jCbnM(TC8CwYHohpKcoCKAOtnD5uxBMQRWpHBMEiKcoCKAOtnD5uxBMQ79JJIHKi1zKA1C2hPensvkFdUb3YEa3YPCVsmPRntfyadC5skosaOaWkgakWLMOkPnqaWTla3NmWn4w2d4EmWzuLe4EmKSe4gClpsAAiMKEKs0ivPqQZivPqk4WrQGB5rstdXK0dUhdSEcgcC5b(iP5BmWaWwAauGBWTShWn0mS4nH19sZXD5hCPjQsAdeayayfmakWn4w2d4Y7gVZjmARJ)dwPbU0evjTbcamaSIdakWLMOkPnqaWLJtJWzaU72CVFCumKuxBMQZso054bUb3YEaxEGpsadaBPaqbU0evjTbcaUCCAeodWvqiLfsAmNhlHXPugAl4wYFhnrvsBKcoCKAXkLAmX9hypsBjdHuIGuE8n4gCl7bClNY9kXKU2mvGbGfgbqbU0evjTbcaUCCAeodWDtv21YjdJgtx053J7TGdnsjePeZ3GBWTShWLPhVUFsxtJaga2tgaf4gCl7bC5(dOXbZdU0evjTbcamaSWuauGlnrvsBGaGBWTShWf6uk18MHjMn4YXPr4ma3vZzFKcsKIhVPXKhniLii1Q5SVJjofC5LWLK2cShzpawXagawrbakWLMOkPnqaWLJtJWzaUlwPuJjU)a7rAlziKseKYJVrk4WrkbHuwiPXCLt5ELysNZI9ZEC0evjTrk4WrQDBU3pokgsQRnt1zjh6C8qQZi1UnxogHNqQRsI2545El4qJuIGucgCdUL9aUvwJ7NWLamaSI5BauGlnrvsBGaGlhNgHZaCTqsJ58yjmoLYqBb3s(7OjQsAdUb3YEaxEGpsadaRyIbGcCPjQsAdeaC540iCgG7Q5SpsbjsXJ30yYJgKseKA1C23XeNcUb3YEa3LmgOZXt)goHMagawXknakWLMOkPnqaWLJtJWzaU72CLt5ELysxBMQdtlm9(JQKqk4WrklK0yUYPCVsmPZzX(zpoAIQK2GBWTShWTCk3Ret6AZubgawXemakWLMOkPnqaWn4w2d4(eUGgt)woEGlhNgHZaCRSRL7ywq4xFKMMXHPGBGlVeUK0wG9i7bWkgWaWkM4aGcCPjQsAdeaC540iCgGlVB5UlpUYPCVsmPRnt1HjMiNhPensDmWzuLKJh4JKMVXi1jyKQ0GBWTShWLh4JeWaWkwPaqbUb3YEa33isQnCuaU0evjTbcamaSIbJaOaxAIQK2abaxooncNb4AHKgZzeM519stJx4rm0yoAIQK2GBWTShW1FGl6EagawXozauGlnrvsBGaGBWTShW9jCbnM(TC8axooncNb4IPfME)rvsi1zKQYUwoll09sB(j9xqb29wWHgPebPem4YlHljTfypYEaSIbmaSIbtbqbU0evjTbcaUCCAeodWDtv21YjdJgtx053JJTaCdUL9aUm9419t6AAeWaWkMOaaf4stuL0gia4YXPr4ma3nvzxlNmmAmDrNFpo2cWn4w2d4IJcRX63Wj0eWag4UPvWknauayfdaf4stuL0gia4YXPr4ma3nvzxlhpElhphBbsbhosTPk7A525xqszuLKMj8sUJTaPGdhP2uLDTC78liPmQsstdo8ihBb4gCl7bC5HuQdUL9OL5BGRmFtpbdbUSwktReGbGT0aOa3GBzpGl7t60iMhCPjQsAdeayayfmakWLMOkPnqaWn4w2d4YdPuhCl7rlZ3axz(MEcgcC57hyayfhauGlnrvsBGaGlhNgHZaCdULhjnnetspsjcsjyK6mszHKgZvoL7vIjDol2p7XrtuL0gPoJuwiPXCHSWFOlW0oSg7OjQsAJuNrklK0yoME86(jDnnYrtuL0gCdUL9aU8qk1b3YE0Y8nWvMVPNGHaxMQok0LxP(nGbGTuaOaxAIQK2abaxooncNb4gClpsAAiMKEKseKsWi1zKYcjnMRCk3Ret6CwSF2JJMOkPn4gCl7bC5HuQdUL9OL5BGRmFtpbdbULxP(nGbGfgbqbU0evjTbcaUCCAeodWn4wEK00qmj9iLiivPb3GBzpGlpKsDWTShTmFdCL5B6jyiW9nGbG9KbqbU0evjTbcaUCCAeodWn4wEK00qmj9iLOrkXa3GBzpGlpKsDWTShTmFdCL5B6jyiWLlP4ibmaSWuauGBWTShWnW8yiT1ymng4stuL0giaWag4wGjEZuddafawXaqbU0evjTbcamaSLgaf4stuL0giaWaWkyauGlnrvsBGaadaR4aGcCdUL9aUpldtp6cYaxAIQK2abaga2sbGcCPjQsAdeayayHrauGBWTShWTOTShWLMOkPnqaGbG9KbqbUb3YEa33isQnCuaU0evjTbcamaSWuauGBWTShW1FGl6EaxAIQK2abagWa33aqbGvmauGBWTShWn0mS4nH19sZXD5hCPjQsAdeayaylnakWLMOkPnqaWLJtJWzaUwiPXC1eVFDV0fyQehnrvsBK6msvzxlhVB8oNWOTo(pyLMJTaPoJu(cPQSRLJ3nENty0wh)hSsZHjMiNhPebP84BKcoCKQYUwUQKfR7L2czpVJTaPoJuv21YvLSyDV0wi75DyIjY5rkrqkp(gPep4gCl7bCz6XR7N010iGbGvWaOaxAIQK2abaxooncNb4AHKgZvt8(19sxGPsC0evjTrQZivLDTC8UX7CcJ264)GvAo2cK6ms5lKQYUwoE34DoHrBD8FWknhMyICEKseKYJVrk4WrQk7A5QswSUxAlK98o2cK6msvzxlxvYI19sBHSN3HjMiNhPebP84BKs8GBWTShWfhfwJ1VHtOjGbGvCaqbU0evjTbcaUCCAeodWTYUwUJzbHF9rAAghMcUHuNrQk7A5oMfe(1hPPzCyIjY5rkrqkp(gCdUL9aUpHlOX0VLJhWaWwkauGlnrvsBGaGlhNgHZaCxnN9rkirkE8MgtE0GuIGuRMZ(oM4uK6ms5lKsqiLfsAmxil8h6cmTdRXoAIQK2ifC4i1Ivk1yI7pWEK2sgcPebP84BKs8GBWTShWf6uk18MHjMnWaWcJaOaxAIQK2abaxooncNb4UAo7JuqIu84nnM8ObPebPwnN9DmXPi1zKYxi1Ivk1yI7pWEK2sgcPebP84BKcoCKsqi1Unx5uUxjM01MP6SKdDoEi1zKYxivLDTCm9419t6flUe3UlpifC4i1Ivk1yI7pWEK2sgcPebPehxPqQtcP84BKs8iL4b3GBzpGB5uUxjM01MPcmaSNmakWLMOkPnqaWLJtJWzaUv21YDmli8RpstZ4WuWnK6msTBZ9eUGgt)woEomXe58iLiiL4GuNes5X3ifC4iLGqklK0yUJzbHF9rAAghnrvsBK6msjiKA3M7jCbnM(TC8CwYHohpK6msjiKQYUwoE34DoHrBD8FWknhBb4gCl7bCFcxqJPFlhpGbGfMcGcCPjQsAdeaC540iCgGlMwy69hvjHuNrkFHubmq40iNmmAmDrNFpoCmqJuIgPknsbhosfWaHtJCYWOX0fD(94OjQsAJuNrQagiCAK7inntZ(6vmEVJMOkPnsbhos5lKkGbcNg5KHrJPl687XrtuL0gPGdhPcyGWPrUJ00mn7RxX49oAIQK2iL4rQZiLVqkbHubmq40ixvYI19sBHSN3rtuL0gPGdhPeeszHKgZvt8(19sxGPsC0evjTrk4WrkbHuv21YX7gVZjmARJ)dwP5ylqkXJuIhCdUL9aUpHlOX0VLJhWaWkkaqbUb3YEa33isQnCuaU0evjTbcamaSI5BauGlnrvsBGaGlhNgHZaCTqsJ5mcZ86EPPXl8igAmhnrvsBWn4w2d46pWfDpadaRyIbGcCdUL9aU8UX7CcJ264)GvAGlnrvsBGaadaRyLgaf4gCl7bC5(dOXbZdU0evjTbcamaSIjyauGlnrvsBGaGlhNgHZaCxnN9rkirkE8MgtE0GuIGuRMZ(oM4uWn4w2d4UKXaDoE63Wj0eWaWkM4aGcCPjQsAdeaC540iCgG7Q5SpsbjsXJ30yYJgKseKA1C23XeNIuNrkFHuv21YX0Jx3pPxS4sCVfCOrkrqkXbPGdhPwnN9rkrqQGBzpoME86(jDnnYX73qkXdUb3YEaxOtPuZBgMy2adaRyLcaf4stuL0gia4YXPr4ma3k7A5y6XR7N0lwCjo2cKcoCKA1C2hPensbJ(gCdUL9aUm9419t6AAeWaWkgmcGcCdUL9aU4OWAS(nCcnbU0evjTbcamaSIDYaOaxAIQK2abaxooncNb4UBZ9eUGgt)woEomTW07pQscPoJuccPQSRLJ3nENty0wh)hSsZXwaUb3YEa3NWf0y63YXdyayfdMcGcCPjQsAdeaC540iCgG7Unx5uUxjM01MP6W0ctV)OkjWn4w2d4woL7vIjDTzQadyGlF)aOaWkgakWLMOkPnqaWLJtJWzaU8UL7U844DJ35egT1X)bR0CyIjY5rkrJuc23GBWTShWTk7ERxS4saga2sdGcCPjQsAdeaC540iCgGlVB5UlpoE34DoHrBD8FWknhMyICEKs0iLG9n4gCl7bCJHtVHdPMhsjWaWkyauGlnrvsBGaGlhNgHZaC5Dl3D5XX7gVZjmARJ)dwP5WetKZJuIgPeSVb3GBzpG7kXuv29gyayfhauGBWTShWvME(TxFcZU9yOXaxAIQK2abaga2sbGcCPjQsAdeaC540iCgGlVB5UlpoE34DoHrBD8FWknhMyICEKs0ifm6BKcoCKYsgsBTENesjcsjMyGBWTShWTs4NWqNJhWaWcJaOaxAIQK2abaxooncNb4wzxlhVB8oNWOTo(pyLMJTaPoJu(cPQSRLRs4NWqNJNJTaPGdhPQSRLRk7ERxS4sCSfifC4iLGqkCWjNHBPePoJuccPWbNCnMJuIhPGdhPSKH0wR3jHuIGuLggb3GBzpGBrBzpada7jdGcCPjQsAdeaC540iCgGRfypYC78Ty4esjAHifmcUb3YEa34liUP7L28tAk8KeWag4Yu1rHU8k1VbGcaRyaOaxAIQK2abaxooncNb4kiKA3M7jCbnM(TC8CwYHohpWn4w2d4(eUGgt)woEadaBPbqbU0evjTbcaUCCAeodWDXkLAmX9hypsBjdHuIGuE8nsbhos5lKA1C2hPGeP4XBAm5rdsjcsTAo77yItrkXJuNrkFHudDQPlN6AZuDhBzyPKqQZi1Un3t4cAm9B545SKdDoEi1zKA3M7jCbnM(TC8CyAHP3FuLesbhosn0PMUCQRnt1v4NWntpesDgPeesvzxlhtpED)KEXIlXXwGuNrQvZzFKcsKIhVPXKhniLii1Q5SVJjofPexKk4w2Jd6uk18MHjMTJhVPXKhni1jHucgPep4gCl7bClNY9kXKU2mvGbGvWaOa3GBzpGlVB8oNWOTo(pyLg4stuL0giaWaWkoaOa3GBzpGBOzyXBcR7LMJ7Yp4stuL0giaWaWwkauGBWTShW9nIKAdhfGlnrvsBGaadalmcGcCPjQsAdeaC540iCgGBLDTCm9419t6flUehMyICEK6msn0PMUCQRnt1v4NWntpe4gCl7bCz6XR7N010iGbG9KbqbU0evjTbcaUCCAeodWD1C2hPGeP4XBAm5rdsjcsTAo77yItrQZiLVqQk7A5y6XR7N0lwCjU3co0iLiivPqk4WrQvZzFKseKk4w2JJPhVUFsxtJC8(nKs8GBWTShWf6uk18MHjMnWaWctbqbU0evjTbcaUCCAeodWDOtnD5uxBMQ79JJIHKi1zKA1C2hPensbJ(gPoJu72CpHlOX0VLJNdtmropsjAKsWi1jHuE8n4gCl7bClNY9kXKU2mvGbGvuaGcCPjQsAdeaC540iCgGlMwy69hvjHuNrkFHudDQPlN6AZuDhBzyPKqQZiLGqQDBU3pokgsQRnt1zjh6C8qk4WrQagiCAKtggnMUOZVhhnrvsBKcoCKkGbcNg5ostZ0SVEfJ37OjQsAJuIhCdUL9aUpHlOX0VLJhWaWkMVbqbU0evjTbcaUCCAeodWTYUwoME86(j9IfxIJTaPGdhPwnN9rkrJuWOVrk4WrQDBU3pokgsQRnt1zjh6C8a3GBzpGltpED)KUMgbmaSIjgakWLMOkPnqaWLJtJWzaUyAHP3FuLe4gCl7bCFcxqJPFlhpGbGvSsdGcCPjQsAdeaC540iCgG7qNA6YPU2mv3XwgwkjK6msTBZ9eUGgt)woEol5qNJhsbhosn0PMUCQRnt1v4NWntpesbhosn0PMUCQRnt19(XrXqsK6msTAo7JuIgPkLVb3GBzpGB5uUxjM01MPcmGbUSwktReauayfdaf4gCl7bCzyHbyqsGlnrvsBGaadaBPbqbUb3YEa3NW0Kwj6n7BGlnrvsBGaadaRGbqbUb3YEa3VOXKMlB2n4stuL0giaWaWkoaOa3GBzpG73T5phpD5Wim4stuL0giaWaWwkauGBWTShW97j56QmEdCPjQsAdeayayHrauGBWTShWDiZpH1V)Mdn4stuL0giaWaWEYaOa3GBzpGl3FEcNV2WXCcKnLPvc4stuL0giaWaWctbqbUb3YEa3ViXPPF)nhAWLMOkPnqaGbGvuaGcCdUL9aUtySy61E4GtGlnrvsBGaadyadCps4p7baBP9TyWuXkTyI58nmTuNm4woWtoEp4EcLPOXgTrkyksfCl7bPK5BVdDaClW9kLe4cZi1LfFmpgsKsuLDmcJoaZiLFZkEyciGWln)SvhVzG4tgwzyzpCCSmi(KHdrv2viQRqC30rikW9kL0dXjgtI6i3peNyrTwuLDmcRVS4J5Xq6(KHJoaZi1jaQIzdCjiLyI5dsvAFlMOaPexKsmbdti4tgDaDaMrkrf)X4rpmb6amJuIlsjk3BAJuNiwyagKesznsTPvWknKk4w2dsjZ3COdWmsjUiLOI)y8Onszb2JmDUqk60cm9F2ZJuwJu8s4ssBb2JS3HoaZiL4IuNOENRK2ifpWhjnFJrkRrQYngAKIPXesrXNYsqQYP5hPm)esf7DpNGEKkzkKednwyzpivVqQJboJQKCOdWmsjUiLOCVPnsXAPmTsqkr5j(eIdDaDaMrkyYtjoRrBKQsRgtifVzQHHuvYlN3HuIsoNkShPMEex)bMzXkrQGBzpps1JSeh6qWTSN3vGjEZudt4sgp0Odb3YEExbM4ntnmifcrW6XqJfw2d6qWTSN3vGjEZuddsHqS6EJoeCl75DfyI3m1WGuiepldtp6cYqhGzK6orX7VnKch5gPQSRfTrQ3c7rQkTAmHu8MPggsvjVCEKkMnsvGjXTOnlhpKkFKA3d5qhcUL98UcmXBMAyqkeIFII3FB63c7rhcUL98UcmXBMAyqkeII2YEqhcUL98UcmXBMAyqkeI3isQnCuGoeCl75DfyI3m1WGuie(dCr3d6a6qWTSN3XAPmTseYWcdWGKqhcUL98owlLPvcKcH4jmnPvIEZ(g6qWTSN3XAPmTsGuieFrJjnx2SB0HGBzpVJ1szALaPqi(Un)54PlhgHrhcUL98owlLPvcKcH47j56QmEdDi4w2Z7yTuMwjqkeIHm)ew)(Bo0Odb3YEEhRLY0kbsHqW9NNW5RnCmNaztzALGoeCl75DSwktReifcXxK400V)Mdn6qWTSN3XAPmTsGuietySy61E4GtOdOdWmsbtEkXznAJu0rcxcszjdHuMFcPcU1yKkFKkogPmQsYHoeCl75fYdPuhCl7rlZ38zcgsiRLY0kXNCjCtv21YXJ3YXZXwah(MQSRLBNFbjLrvsAMWl5o2c4W3uLDTC78liPmQsstdo8ihBb6a6qWTSNhsHqW(KonI5rhcUL98qkecEiL6GBzpAz(MptWqc57hDi4w2ZdPqi4HuQdUL9OL5B(mbdjKPQJcD5vQFZNCjm4wEK00qmj9Ii4ZwiPXCLt5ELysNZI9ZEC0evjTpBHKgZfYc)HUat7WASJMOkP9zlK0yoME86(jDnnYrtuL0gDi4w2ZdPqi4HuQdUL9OL5B(mbdjS8k1V5tUegClpsAAiMKEre8zlK0yUYPCVsmPZzX(zpoAIQK2Odb3YEEifcbpKsDWTShTmFZNjyiHV5tUegClpsAAiMKErkn6qWTSNhsHqWdPuhCl7rlZ38zcgsixsXrYNCjm4wEK00qmj9Iwm0HGBzppKcHiW8yiT1ymng6a6qWTSN3X3VWQS7TEXIlXNCjK3TC3LhhVB8oNWOTo(pyLMdtmroVOfSVrhcUL98o((HuieXWP3WHuZdP0NCjK3TC3LhhVB8oNWOTo(pyLMdtmroVOfSVrhcUL98o((HuieRetvz3BFYLqE3YDxEC8UX7CcJ264)GvAomXe58IwW(gDi4w2Z747hsHqitp)2RpHz3Em0yOdb3YEEhF)qkeIkHFcdDoE(KlH8UL7U844DJ35egT1X)bR0CyIjY5fnm6B4WTKH0wR3jjIyIHoeCl75D89dPqikAl7XNCjSYUwoE34DoHrBD8FWknhBXzFvzxlxLWpHHohphBbC4v21YvLDV1lwCjo2c4Wfeo4KZWTuEwq4GtUgZfpC4wYqAR17KeP0Wi6qWTSN3X3pKcHi(cIB6EPn)KMcpj5tUeAb2Jm3oFlgojAHWi6a6qWTSN3XLuCKeEmWzuLKptWqc5b(iP5BSpDHWNmFogswsyWT8iPPHys6fDPoxk4WdULhjnnetsp6qWTSN3XLuCKGuieHMHfVjSUxAoUl)Odb3YEEhxsXrcsHqW7gVZjmARJ)dwPHoeCl75DCjfhjifcbpWhjFYLWDBU3pokgsQRnt1zjh6C8qhcUL98oUKIJeKcHOCk3Ret6AZu9jxcfKfsAmNhlHXPugAl4wYFhnrvsB4WxSsPgtC)b2J0wYqI4X3Odb3YEEhxsXrcsHqW0Jx3pPRPr(KlHBQYUwozy0y6Io)ECVfCOfkMVrhcUL98oUKIJeKcHG7pGghmp6qWTSN3XLuCKGuieqNsPM3mmXS9HxcxsAlWEK9cfZNCjC1C2hsE8MgtE0iYQ5SVJjofDi4w2Z74skosqkeIkRX9t4s8jxcxSsPgtC)b2J0wYqI4X3WHlilK0yUYPCVsmPZzX(zpoAIQK2WHVBZ9(XrXqsDTzQol5qNJ35DBUCmcpHuxLeTZXZ9wWHwebJoeCl75DCjfhjifcbpWhjFYLqlK0yopwcJtPm0wWTK)oAIQK2Odb3YEEhxsXrcsHqSKXaDoE63Wj0Kp5s4Q5SpK84nnM8OrKvZzFhtCk6qWTSN3XLuCKGuieLt5ELysxBMQp5s4Unx5uUxjM01MP6W0ctV)Okj4WTqsJ5kNY9kXKoNf7N94OjQsAJoeCl75DCjfhjifcXt4cAm9B545dVeUK0wG9i7fkMp5syLDTChZcc)6J00momfCdDi4w2Z74skosqkecEGps(KlH8UL7U84kNY9kXKU2mvhMyICErFmWzuLKJh4JKMVXNGln6qWTSN3XLuCKGuieVrKuB4OaDi4w2Z74skosqkec)bUO7XNCj0cjnMZimZR7LMgVWJyOXC0evjTrhcUL98oUKIJeKcH4jCbnM(TC88HxcxsAlWEK9cfZNCjetlm9(JQKoxzxlNLf6EPn)K(lOa7El4qlIGrhGzKcQgP(KHvggHuSF4ri1QXi1jQhVUFcPeincPAmsjQJcRXi11Wj0esTzX54HuIYVG4gs1lKY8tifmz4jjFqkExucsrb3ps1ColgtdNqQEHuMFcPcUL9GuXSrQOOGMnsPPWtsiL1iL5NqQGBzpi1emKdDi4w2Z74skosqkecME86(jDnnYNCjCtv21YjdJgtx053JJTaDi4w2Z74skosqkecCuynw)goHM8jxc3uLDTCYWOX0fD(94ylqhqhcUL98oMQok0LxP(nHpHlOX0VLJNp5sOG2T5EcxqJPFlhpNLCOZXdDi4w2Z7yQ6OqxEL63GuieLt5ELysxBMQp5s4Ivk1yI7pWEK2sgsep(goCFTAo7djpEtJjpAez1C23XeNk(Z(AOtnD5uxBMQ7yldlL05DBUNWf0y63YXZzjh6C8oVBZ9eUGgt)woEomTW07pQsco8Ho10LtDTzQUc)eUz6HolOk7A5y6XR7N0lwCjo2IZRMZ(qYJ30yYJgrwnN9DmXPIBWTShh0PuQ5ndtmBhpEtJjpAojblE0HGBzpVJPQJcD5vQFdsHqW7gVZjmARJ)dwPHoeCl75DmvDuOlVs9BqkeIqZWI3ew3lnh3LF0HGBzpVJPQJcD5vQFdsHq8grsTHJc0bygPGQrQpzyLHrif7hEesTAmsDI6XR7NqkbsJqQgJuI6OWAmsDnCcnHuBwCoEiLO8liUHu9cPm)esbtgEsYhKI3fLGuuW9JunNZIX0WjKQxiL5NqQGBzpivmBKkkkOzJuAk8Kesznsz(jKk4w2dsnbd5qhcUL98oMQok0LxP(nifcbtpED)KUMg5tUewzxlhtpED)KEXIlXHjMiN)8qNA6YPU2mvxHFc3m9qOdb3YEEhtvhf6YRu)gKcHa6uk18MHjMTp5s4Q5SpK84nnM8OrKvZzFhtC6zFvzxlhtpED)KEXIlX9wWHwKsbh(Q5SVib3YECm9419t6AAKJ3VjE0HGBzpVJPQJcD5vQFdsHquoL7vIjDTzQ(KlHdDQPlN6AZuDVFCumK88Q5SVOHrFFE3M7jCbnM(TC8CyIjY5fTGpjp(gDi4w2Z7yQ6OqxEL63GuiepHlOX0VLJNp5siMwy69hvjD2xdDQPlN6AZuDhBzyPKolODBU3pokgsQRnt1zjh6C8GdpGbcNg5KHrJPl687XrtuL0go8agiCAK7inntZ(6vmEVJMOkPT4rhcUL98oMQok0LxP(nifcbtpED)KUMg5tUewzxlhtpED)KEXIlXXwah(Q5SVOHrFdh(Un37hhfdj11MP6SKdDoEOdb3YEEhtvhf6YRu)gKcH4jCbnM(TC88jxcX0ctV)Okj0HGBzpVJPQJcD5vQFdsHquoL7vIjDTzQ(KlHdDQPlN6AZuDhBzyPKoVBZ9eUGgt)woEol5qNJhC4dDQPlN6AZuDf(jCZ0dbh(qNA6YPU2mv37hhfdjpVAo7l6s5B0b0HGBzpV7nHHMHfVjSUxAoUl)OdWmsbvJuFYWkdJqk2p8iKA1yK6e1Jx3pHucKgHungPe1rH1yK6A4eAcP2S4C8qkr5xqCdP6fsz(jKcMm8KKpifVlkbPOG7hPAoNfJPHtivVqkZpHub3YEqQy2ivuuqZgP0u4jjKYAKY8tivWTShKAcgYHoeCl75DVbPqiy6XR7N010iFYLqlK0yUAI3VUx6cmvIJMOkP95k7A54DJ35egT1X)bR0CSfN9vLDTC8UX7CcJ264)GvAomXe58I4X3WHxzxlxvYI19sBHSN3XwCUYUwUQKfR7L2czpVdtmroViE8T4rhcUL98U3Guie4OWAS(nCcn5tUeAHKgZvt8(19sxGPsC0evjTpxzxlhVB8oNWOTo(pyLMJT4SVQSRLJ3nENty0wh)hSsZHjMiNxep(go8k7A5QswSUxAlK98o2IZv21YvLSyDV0wi75DyIjY5fXJVfp6qWTSN39gKcH4jCbnM(TC88jxcRSRL7ywq4xFKMMXHPGBNRSRL7ywq4xFKMMXHjMiNxep(gDi4w2Z7EdsHqaDkLAEZWeZ2NCjC1C2hsE8MgtE0iYQ5SVJjo9SVeKfsAmxil8h6cmTdRXoAIQK2WHVyLsnM4(dShPTKHeXJVfp6qWTSN39gKcHOCk3Ret6AZu9jxcxnN9HKhVPXKhnISAo77yItp7RfRuQXe3FG9iTLmKiE8nC4cA3MRCk3Ret6AZuDwYHohVZ(QYUwoME86(j9IfxIB3Lh4WxSsPgtC)b2J0wYqIioUsDsE8T4fp6qWTSN39gKcH4jCbnM(TC88jxcRSRL7ywq4xFKMMXHPGBN3T5EcxqJPFlhphMyICEreNtYJVHdxqwiPXChZcc)6J00moAIQK2Nf0Un3t4cAm9B545SKdDoENfuLDTC8UX7CcJ264)GvAo2c0HGBzpV7nifcXt4cAm9B545tUeIPfME)rvsN9vadeonYjdJgtx053Jdhd0IU0WHhWaHtJCYWOX0fD(94OjQsAFoGbcNg5ostZ0SVEfJ37OjQsAdhUVcyGWProzy0y6Io)EC0evjTHdpGbcNg5ostZ0SVEfJ37OjQsAl(Z(sqbmq40ixvYI19sBHSN3rtuL0goCbzHKgZvt8(19sxGPsC0evjTHdxqv21YX7gVZjmARJ)dwP5yleV4rhcUL98U3GuieVrKuB4OaDi4w2Z7EdsHq4pWfDp(KlHwiPXCgHzEDV004fEednMJMOkPn6qWTSN39gKcHG3nENty0wh)hSsdDi4w2Z7EdsHqW9hqJdMhDi4w2Z7EdsHqSKXaDoE63Wj0Kp5s4Q5SpK84nnM8OrKvZzFhtCk6qWTSN39gKcHa6uk18MHjMTp5s4Q5SpK84nnM8OrKvZzFhtC6zFvzxlhtpED)KEXIlX9wWHweXbo8vZzFrcUL94y6XR7N010ihVFt8Odb3YEE3BqkecME86(jDnnYNCjSYUwoME86(j9IfxIJTao8vZzFrdJ(gDi4w2Z7EdsHqGJcRX63Wj0e6qWTSN39gKcH4jCbnM(TC88jxc3T5EcxqJPFlhphMwy69hvjDwqv21YX7gVZjmARJ)dwP5ylqhcUL98U3GuieLt5ELysxBMQp5s4Unx5uUxjM01MP6W0ctV)Okj0b0HGBzpVR8k1Vjm0mS4nH19sZXD5hDi4w2Z7kVs9BqkecE34DoHrBD8FWkn0bygPGQrQpzyLHrif7hEesTAmsDI6XR7NqkbsJqQgJuI6OWAmsDnCcnHuBwCoEiLO8liUHu9cPm)esbtgEsYhKI3fLGuuW9JunNZIX0WjKQxiL5NqQGBzpivmBKkkkOzJuAk8Kesznsz(jKk4w2dsnbd5qhcUL98UYRu)gKcHGPhVUFsxtJ8jxcdyGWPrUYPCt4H(x)S4J5Xq6OjQsAFEOtnD5uxBMQ7yldlL05DBUNWf0y63YXZHjMiNx0L2j2j5X3N3T5EcxqJPFlhphMyICEreSRuNKhFFM3TC3Lhx5uUxjM01MP6WetKZl6s7k1j5X3Odb3YEEx5vQFdsHquoL7vIjDTzQ(KlHlwPuJjU)a7rAlzir84B4W91Q5SpK84nnM8OrKvZzFhtCQ4p7RHo10LtDTzQUJTmSusN3T5EcxqJPFlhpNLCOZX78Un3t4cAm9B545W0ctV)Okj4Wh6utxo11MP6k8t4MPh6SGQSRLJPhVUFsVyXL4yloVAo7djpEtJjpAez1C23XeNkUb3YECqNsPM3mmXSD84nnM8O5KeS4rhcUL98UYRu)gKcHa6uk18MHjMTp5s4Q5SpK84nnM8OrKvZzFhtC65k7A5SSq3lT5N0Fbfy3BbhAre8zFjilK0yUqw4p0fyAhwJD0evjTHdVYUwoME86(j9IfxI7TGdTiLco8vZzFrcUL94y6XR7N010ihVFt8Odb3YEEx5vQFdsHqGJcRX63Wj0Kp5s4UnxogHNqQRsI2545El4qlIGpVBZ9(XrXqsDTzQol5qNJ3zbzHKgZX0Jx3pPRProAIQK2Odb3YEEx5vQFdsHquoL7vIjDTzQ(KlHdDQPlN6AZuDVFCumK8CLDTCm9419t6flUe3UlpN9fVB5UlpoOtPuZBgMy2omXe58I2JVHdF1C2x0WOVf)zbTBZ9eUGgt)woEomTW07pQscDi4w2Z7kVs9BqkeI3isQnCuGoeCl75DLxP(nifcXsgd054PFdNqt(KlHRMZ(qYJ30yYJgrwnN9DmXPOdb3YEEx5vQFdsHq8eUGgt)woE(KlHv21YDmli8RpstZ4WuWn4WX0ctV)OkPZ(sqwiPXCm9419t6AAKJMOkPnC4cYcjnM7ywq4xFKMMXrtuL0go8Ho10LtDTzQUJTmSusNf0Un37hhfdj11MP6SKdDoEWHhWaHtJCYWOX0fD(94OjQsAdhEadeonYDKMMPzF9kgV3rtuL0go8k7A5y6XR7N0lwCjU3co0clL4rhcUL98UYRu)gKcHWFGl6E8jxcTqsJ5mcZ86EPPXl8igAmhnrvsB0HGBzpVR8k1VbPqiy6XR7N010iFYLWk7A5y6XR7N0lwCjo2c4WxnN9fnm6B4W3T5E)4OyiPU2mvNLCOZXdDi4w2Z7kVs9BqkecCuynw)goHMqhcUL98UYRu)gKcH4jCbnM(TC88jxcX0ctV)Okj0HGBzpVR8k1VbPqikNY9kXKU2mvFYLWHo10LtDTzQUJTmSusN3T5EcxqJPFlhpNLCOZXdo8Ho10LtDTzQUc)eUz6HGdFOtnD5uxBMQ79JJIHKNxnN9fDP8n4(fehaBPlvPagWaaa]] )

    
end