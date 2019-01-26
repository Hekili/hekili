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


    spec:RegisterPack( "Survival", 20181211.0857, [[dyuvkbqiuqpIirxIQIuTjvOpHcqnkIkofrQwLkk8kaAwevDlrk1UOYVaWWis5yuvAzuv4zevAAIuY1ePyBOa9nIemoQkQZrvrY6qbW8iIUhrzFejDqvuulKi8qIeQjsvrkxefqgjrc5KOaeRuf5MQOi7efAOOaQLsvr8uvAQaQ9c6VKmychwyXI6XOAYk1Lr2Ss(mvz0IKtlz1OaKEnGmBsDBG2TIFl1WfXYH65QA6uUokTDvW3PQA8IuDEvuTEvuA(OO9dzOVqGH3DyeKrFinF9zF9HV(6KMpNgPG08fETZti4nj4afEe8obibVxw8H6qOH3K4CDhBiWW73SyobVPml5zaaaaVYsXMD8geGVaz1Hv9WXXYa4lqoazDNbiVI0Ethaib3RstpamWyYNe1(bGb2NOKIyhJWQll(qDi0UVa5WBMT0gdidmdV7WiiJ(qA(6Z(6dF91jnFon(qUW7NqCiJ(inPbEtv7nnWm8UPNdVsjsCzXhQdHgjKIyhJWOtsjsKYSKNbaaa8klfB2XBqa(cKvhw1dhhldGVa5aK1DgG8ks7nDaGeCVkn9aWaJjFsu7hagyFIskIDmcRUS4d1Hq7(cKJojLiHpnItGzcJe(6R8iHpKMV(msK2iH08zgG04d0j0jPejKItfJh9maOtsjsK2iXzEVPnsCMyp7z1esynsSPvWQnKi4w1dsOR3COtsjsK2iHuCQy8Onsyb2JmvTqck9em9F1ZJewJe8Z5Aszb2JS3HojLirAJeNPExRI2ibpWhifFJrcRrc)ngiKaSXesqXx6Zrc)LLcjSuese7DpmGFKOat0einwyvpirVqIdbUISMCWBcUxLMGxPejUS4d1HqJesrSJry0jPejszwYZaaaaELLIn74niaFbYQdR6HJJLbWxGCaY6odqEfP9MoaqcUxLMEayGXKpjQ9dadSprjfXogHvxw8H6qODFbYrNKsKWNgXjWmHrcF9vEKWhsZxFgjsBKqA(mdqA8b6e6KuIesXPIXJEga0jPejsBK4mV30gjotSN9SAcjSgj20ky1gseCR6bj01Bo0jPejsBKqkovmE0gjSa7rMQwibLEcM(V65rcRrc(5CnPSa7r27qNKsKiTrIZuVRvrBKGh4dKIVXiH1iH)gdesa2ycjO4l95iH)YsHewkcjI9UhgWpsuGjAcKglSQhKOxiXHaxrwto0j0jPejyGsN4SgTrImTAmHe8gmhgsKjVAEhsCM5CkXEKy6jTtfyWfRgjcUv98irp6ZDOtb3QEExcM4nyomzlD8aHofCR65DjyI3G5WaugabRhinwyvpOtb3QEExcM4nyomaLbWQ7n6uWTQN3LGjEdMddqza8SGG9OsidDskrI7ejFQ2qcCuBKiZUw0gjElShjY0QXesWBWCyirM8Q5rIy2ircMs7K2SA8qI6rIDpKdDk4w1Z7sWeVbZHbOma(js(uTPElShDk4w1Z7sWeVbZHbOmasAR6bDk4w1Z7sWeVbZHbOmaEJiTYWrc6uWTQN3LGjEdMddqzaKkWjDpOtOtsjsWaLoXznAJe0bcFosyfiHewkcjcU1yKOEKioeLoYAYHofCR65LbYE2ZQj0PGBvppGYaG9jvze4JofCR65buga8qRvb3QEu66n5NaKKX3p6uWTQNhqzaWdTwfCR6rPR3KFcqsgywfjk)Rs9M81swWT6aPOHal6LuUhTqtJ58x69QWKQMf7x94OjYAAF0cnnMl0jPcvcM2H1yhnrwt7JwOPXCG9419tQCzKJMiRPn6uWTQNhqzaWdTwfCR6rPR3KFcqsM)vPEt(Ajl4wDGu0qGf9sk3JwOPXC(l9EvysvZI9REC0eznTrNcUv98akdaEO1QGBvpkD9M8tasYEt(Ajl4wDGu0qGf9s6d0PGBvppGYaGhATk4w1JsxVj)eGKmUMIdK81swWT6aPOHal6LQVOtb3QEEaLbqG5XqkRXyAm0j0PGBvpVJVFzzD3B1IfFU81sgVB9U9poE34DnHrBv8FWQnhMaJAEPkxPHofCR65D89dOmaIHtVHdTIhAT81sgVB9U9poE34DnHrBv8FWQnhMaJAEPkxPHofCR65D89dOmawfMY6U3Yxlz8U172)44DJ31egTvX)bR2CycmQ5LQCLg6uWTQN3X3pGYaqxEPSxXak72dKgdDk4w1Z747hqzaKj8tyGQXt(AjJ3TE3(hhVB8UMWOTk(py1MdtGrnVuzqPXKPvGKYA1Uij91x0PGBvpVJVFaLbqsBvpYxlzz21YX7gVRjmARI)dwT5ytokNm7A5Ye(jmq145ytyYmZUwUSU7TAXIp3XMWKjdXbNCgU16JmehCY1yU0zY0kqszTAxKK(GbrNcUv98o((bugaXNqCt1lLLIuu4Pj5RLmlWEK521BXWjPkJbrNqNcUv98oUMIdKSdbUISMKFcqsgpWhifFJLVtK9Kj)HqZsYcUvhifneyrVutZX0WKzWT6aPOHal6rNcUv98oUMIdeGYaiuGS4nHv9sXXT)hDk4w1Z74AkoqakdaE34DnHrBv8FWQn0PGBvpVJRP4abOma4b(ajFTKTBZ9PWrYqAvUbZoR4avJh6uWTQN3X1uCGauga(l9EvysLBWS81sgdTqtJ58yjmU06qzb3k(7OjYAAZK5IvRvyINkWEKYkqssp(gDk4w1Z74AkoqakdaWE86(jvUms(AjBtz21YPdJgtL013J7TGdKmFLg6uWTQN3X1uCGauga8ubq4a8rNcUv98oUMIdeGYaaOsRv8gemMT88Z5Aszb2JSxMVYxlzRMZ(aYJ3uyYJgjxnN9DGr6Otb3QEEhxtXbcqzaKznEkcFU81s2IvRvyINkWEKYkqssp(MjtgAHMgZ5V07vHjvnl2V6XrtK10MjZDBUpfosgsRYny2zfhOA8oUBZvJr4j0QSMODnEU3coqskx0PGBvpVJRP4abOma4b(ajFTKzHMgZ5XsyCP1HYcUv83rtK10gDk4w1Z74AkoqakdGLogGQXt9gUaIKVwYwnN9bKhVPWKhnsUAo77aJ0rNcUv98oUMIdeGYaWFP3RctQCdMLVwY2T58x69QWKk3GzhMwy6tfznXKPfAAmN)sVxfMu1Sy)QhhnrwtB0PGBvpVJRP4abOmaEcNqJPERgp55NZ1KYcShzVmFLVwYYSRL7qLq4xDGMg0HPGBOtb3QEEhxtXbcqzaWd8bs(AjJ3TE3(hN)sVxfMu5gm7WeyuZl1dbUISMC8aFGu8n2NUpqNcUv98oUMIdeGYa4nI0kdhjOtb3QEEhxtXbcqzaKkWjDpYxlzwOPXCgHbFvVu04fEeinMJMiRPn6uWTQN3X1uCGaugapHtOXuVvJN88Z5Aszb2JSxMVYxlzyAHPpvK10Xm7A5Skr1lLLIuFcfy3BbhijLl6KuIea3iXxGS6WiKG9dpcjwngjot9419tiHeLrirJrcFsKyngjUgUaIqInlUgpK4m)je3qIEHewkcjyGcpnjpsW7KZrck4PqIMZzXyA4es0lKWsrirWTQhKiMnsejj0SrcffEAcjSgjSueseCR6bjMaKCOtb3QEEhxtXbcqzaa2Jx3pPYLrYxlzBkZUwoDy0yQKU(ECSjOtb3QEEhxtXbcqzaGJeRXQ3WfqK81s2MYSRLthgnMkPRVhhBc6e6uWTQN3bMvrIY)QuVj7jCcnM6TA8KVwYy4Un3t4eAm1B145SIdunEOtb3QEEhywfjk)Rs9gGYaWFP3RctQCdMLVwYwSATct8ub2Juwbss6X3mzkNvZzFa5XBkm5rJKRMZ(oWiDPFuodLUP8xQCdMDhADyLMoUBZ9eoHgt9wnEoR4avJ3XDBUNWj0yQ3QXZHPfM(urwtmzou6MYFPYny2LKIWnyp0rgMzxlhypED)KAXIp3XMCC1C2hqE8MctE0i5Q5SVdmspTdUv94aQ0AfVbbJz74XBkm5rZzixPJofCR65DGzvKO8Vk1BakdaE34DnHrBv8FWQn0PGBvpVdmRIeL)vPEdqzaekqw8MWQEP442)JofCR65DGzvKO8Vk1BakdG3isRmCKGojLibWns8fiRomcjy)WJqIvJrIZupED)esirzes0yKWNejwJrIRHlGiKyZIRXdjoZFcXnKOxiHLIqcgOWttYJe8o5CKGcEkKO5CwmMgoHe9cjSueseCR6bjIzJerscnBKqrHNMqcRrclfHeb3QEqIjajh6uWTQN3bMvrIY)QuVbOmaa7XR7Nu5Yi5RLSm7A5a7XR7Nulw85ombg18hhkDt5Vu5gm7ssr4gShcDk4w1Z7aZQir5FvQ3augaavATI3GGXSLVwYwnN9bKhVPWKhnsUAo77aJ0pkNm7A5a7XR7Nulw85U3coqsMgMmxnN9Lm4w1JdShVUFsLlJC8(nPJofCR65DGzvKO8Vk1Bakda)LEVkmPYnyw(AjBO0nL)sLBWS7tHJKH0hxnN9LkdkTJ72CpHtOXuVvJNdtGrnVuL7z4X3Otb3QEEhywfjk)Rs9gGYa4jCcnM6TA8KVwYW0ctFQiRPJYzO0nL)sLBWS7qRdR00rgUBZ9PWrYqAvUbZoR4avJhtMXzjCzKthgnMkPRVhhnrwtBMmJZs4Yi3bAAWM9vRy8EhnrwtBPJofCR65DGzvKO8Vk1BakdaWE86(jvUms(AjlZUwoWE86(j1IfFUJnHjZvZzFPYGsJjZDBUpfosgsRYny2zfhOA8qNcUv98oWSksu(xL6naLbWt4eAm1B14jFTKHPfM(urwtOtb3QEEhywfjk)Rs9gGYaWFP3RctQCdMLVwYgkDt5Vu5gm7o06WknDC3M7jCcnM6TA8CwXbQgpMmhkDt5Vu5gm7ssr4gShIjZHs3u(lvUbZUpfosgsFC1C2xQPrAOtOtb3QEE3BYcfilEtyvVuCC7)rNKsKa4gj(cKvhgHeSF4riXQXiXzQhVUFcjKOmcjAms4tIeRXiX1WfqesSzX14HeN5pH4gs0lKWsribdu4Pj5rcENCosqbpfs0ColgtdNqIEHewkcjcUv9GeXSrIijHMnsOOWttiH1iHLIqIGBvpiXeGKdDk4w1Z7Edqzaa2Jx3pPYLrYxlzwOPXC5cVFvVujy6Chnrwt7Jz21YX7gVRjmARI)dwT5ytokNm7A54DJ31egTvX)bR2CycmQ5L0JVzYmZUwUSMfR6LYcDpVJn5yMDTCznlw1lLf6EEhMaJAEj94BPJofCR65DVbOmaWrI1y1B4cis(AjZcnnMlx49R6LkbtN7OjYAAFmZUwoE34DnHrBv8FWQnhBYr5KzxlhVB8UMWOTk(py1MdtGrnVKE8ntMz21YL1SyvVuwO75DSjhZSRLlRzXQEPSq3Z7WeyuZlPhFlD0PGBvpV7naLbWt4eAm1B14jFTKLzxl3HkHWV6annOdtb3oMzxl3HkHWV6annOdtGrnVKE8n6uWTQN39gGYaaOsRv8gemMT81s2Q5SpG84nfM8OrYvZzFhyK(r5Wql00yUqNKkujyAhwJD0eznTzYCXQ1kmXtfypszfijPhFlD0PGBvpV7naLbG)sVxfMu5gmlFTKTAo7dipEtHjpAKC1C23bgPFuolwTwHjEQa7rkRajj94BMmz4UnN)sVxfMu5gm7SIdunEhLtMDTCG9419tQfl(C3U9pmzUy1AfM4PcShPScKKmTCP5m84BPlD0PGBvpV7naLbWt4eAm1B14jFTKLzxl3HkHWV6annOdtb3oUBZ9eoHgt9wnEombg18sMwNHhFZKjdTqtJ5ouje(vhOPbD0eznTpYWDBUNWj0yQ3QXZzfhOA8oYWm7A54DJ31egTvX)bR2CSjOtb3QEE3BakdGNWj0yQ3QXt(Ajdtlm9PISMokN4SeUmYPdJgtL013Jdhdqs1hmzgNLWLroDy0yQKU(EC0eznTpgNLWLrUd00Gn7RwX49oAISM2mzkN4SeUmYPdJgtL013JJMiRPntMXzjCzK7annyZ(QvmEVJMiRPT0pkhggNLWLrUSMfR6LYcDpVJMiRPntMm0cnnMlx49R6LkbtN7OjYAAZKjdZSRLJ3nExty0wf)hSAZXMiDPJofCR65DVbOmaEJiTYWrc6uWTQN39gGYaivGt6EKVwYSqtJ5mcd(QEPOXl8iqAmhnrwtB0PGBvpV7naLbaVB8UMWOTk(py1g6uWTQN39gGYaGNkachGp6uWTQN39gGYayPJbOA8uVHlGi5RLSvZzFa5XBkm5rJKRMZ(oWiD0PGBvpV7naLbaqLwR4niymB5RLSvZzFa5XBkm5rJKRMZ(oWi9JYjZUwoWE86(j1IfFU7TGdKKPftMRMZ(sgCR6Xb2Jx3pPYLroE)M0rNcUv98U3augaG9419tQCzK81swMDTCG9419tQfl(ChBctMRMZ(sLbLg6uWTQN39gGYaahjwJvVHlGi0PGBvpV7naLbWt4eAm1B14jFTKTBZ9eoHgt9wnEomTW0NkYA6idZSRLJ3nExty0wf)hSAZXMGofCR65DVbOma8x69QWKk3Gz5RLSDBo)LEVkmPYny2HPfM(urwtOtOtb3QEEN)vPEtwOazXBcR6LIJB)p6uWTQN35FvQ3auga8UX7AcJ2Q4)GvBOtsjsaCJeFbYQdJqc2p8iKy1yK4m1Jx3pHesugHengj8jrI1yK4A4cicj2S4A8qIZ8NqCdj6fsyPiKGbk80K8ibVtohjOGNcjAoNfJPHtirVqclfHeb3QEqIy2irKKqZgjuu4PjKWAKWsrirWTQhKycqYHofCR65D(xL6naLbaypED)KkxgjFTKfNLWLro)LEt4H(x9S4d1Hq7OjYAAFCO0nL)sLBWS7qRdR00XDBUNWj0yQ3QXZHjWOMxQ(W57z4X3h3T5EcNqJPERgphMaJAEjLRlnNHhFFK3TE3(hN)sVxfMu5gm7WeyuZlvF4sZz4X3Otb3QEEN)vPEdqza4V07vHjvUbZYxlzlwTwHjEQa7rkRajj94BMmLZQ5SpG84nfM8OrYvZzFhyKU0pkNHs3u(lvUbZUdToSsth3T5EcNqJPERgpNvCGQX74Un3t4eAm1B145W0ctFQiRjMmhkDt5Vu5gm7ssr4gSh6idZSRLdShVUFsTyXN7ytoUAo7dipEtHjpAKC1C23bgPN2b3QECavATI3GGXSD84nfM8O5mKR0rNcUv98o)Rs9gGYaaOsRv8gemMT81s2Q5SpG84nfM8OrYvZzFhyK(Xm7A5Skr1lLLIuFcfy3BbhijL7r5Wql00yUqNKkujyAhwJD0eznTzYmZUwoWE86(j1IfFU7TGdKKPHjZvZzFjdUv94a7XR7Nu5YihVFt6Otb3QEEN)vPEdqzaGJeRXQ3WfqK81s2UnxngHNqRYAI2145El4ajPCpUBZ9PWrYqAvUbZoR4avJ3rgAHMgZb2Jx3pPYLroAISM2Otb3QEEN)vPEdqza4V07vHjvUbZYxlzdLUP8xQCdMDFkCKmK(yMDTCG9419tQfl(C3U9phLdVB9U9poGkTwXBqWy2ombg18s1JVzYC1C2xQmO0K(rgUBZ9eoHgt9wnEomTW0NkYAcDk4w1Z78Vk1BakdG3isRmCKGofCR65D(xL6naLbWshdq14PEdxarYxlzRMZ(aYJ3uyYJgjxnN9DGr6Otb3QEEN)vPEdqza8eoHgt9wnEYxlzz21YDOsi8Roqtd6WuWnMmX0ctFQiRPJYHHwOPXCG9419tQCzKJMiRPntMm0cnnM7qLq4xDGMg0rtK10MjZHs3u(lvUbZUdToSsthz4Un3NchjdPv5gm7SIdunEmzgNLWLroDy0yQKU(EC0eznTzYmolHlJChOPbB2xTIX7D0eznTzYmZUwoWE86(j1IfFU7TGdKS0iD0PGBvpVZ)QuVbOmasf4KUh5RLml00yoJWGVQxkA8cpcKgZrtK10gDk4w1Z78Vk1BakdaWE86(jvUms(AjlZUwoWE86(j1IfFUJnHjZvZzFPYGsJjZDBUpfosgsRYny2zfhOA8qNcUv98o)Rs9gGYaahjwJvVHlGi0PGBvpVZ)QuVbOmaEcNqJPERgp5RLmmTW0NkYAcDk4w1Z78Vk1Bakda)LEVkmPYnyw(AjBO0nL)sLBWS7qRdR00XDBUNWj0yQ3QXZzfhOA8yYCO0nL)sLBWSljfHBWEiMmhkDt5Vu5gm7(u4izi9XvZzFPMgPbVhi8x9az0hsZxF2xP5dF48H0slPa86pWtnEp8YacysJnAJesbKi4w1dsOR3Eh6e8QR3EiWWR)vPEdcmKrFHadVb3QEG3qbYI3ew1lfh3(F4LMiRPnucObz0hqGH3GBvpWlVB8UMWOTk(py1g8stK10gkb0GmkxiWWlnrwtBOeWlhxgHRaEJZs4YiN)sVj8q)REw8H6qOD0eznTrIJiXqPBk)Lk3Gz3HwhwPjK4isSBZ9eoHgt9wnEombg18iHurcF48fjodKWJVrIJiXUn3t4eAm1B145WeyuZJesIeY1LgK4mqcp(gjoIe8U172)48x69QWKk3GzhMaJAEKqQiHpCPbjodKWJVH3GBvpWlypED)KkxgbniJPfey4LMiRPnuc4LJlJWvaVlwTwHjEQa7rkRajKqsKWJVrcMmrc5GeRMZ(ibGibpEtHjpAqcjrIvZzFhyKosiDK4isihKyO0nL)sLBWS7qRdR0esCej2T5EcNqJPERgpNvCGQXdjoIe72CpHtOXuVvJNdtlm9PISMqcMmrIHs3u(lvUbZUKueUb7HqIJibdrIm7A5a7XR7Nulw85o2eK4isSAo7JeaIe84nfM8ObjKejwnN9DGr6irAJeb3QECavATI3GGXSD84nfM8ObjodKqUiH0H3GBvpWR)sVxfMu5gmdniJPbcm8stK10gkb8YXLr4kG3vZzFKaqKGhVPWKhniHKiXQ5SVdmshjoIez21YzvIQxklfP(ekWU3coqiHKiHCrIJiHCqcgIewOPXCHojvOsW0oSg7OjYAAJemzIez21Yb2Jx3pPwS4ZDVfCGqcjrI0GemzIeRMZ(iHKirWTQhhypED)Kkxg549BiH0H3GBvpWlqLwR4niymBObzKbHadV0eznTHsaVCCzeUc4D3MRgJWtOvznr7A8CVfCGqcjrc5IehrIDBUpfosgsRYny2zfhOA8qIJibdrcl00yoWE86(jvUmYrtK10gEdUv9aV4iXAS6nCbebniJsbiWWlnrwtBOeWlhxgHRaEhkDt5Vu5gm7(u4izinsCejYSRLdShVUFsTyXN72T)bjoIeYbj4DR3T)XbuP1kEdcgZ2HjWOMhjKks4X3ibtMiXQ5SpsivKGbLgsiDK4isWqKy3M7jCcnM6TA8CyAHPpvK1e8gCR6bE9x69QWKk3GzObz0NHadVb3QEG33isRmCKaV0eznTHsaniJ(uqGHxAISM2qjGxoUmcxb8UAo7JeaIe84nfM8ObjKejwnN9DGr6WBWTQh4DPJbOA8uVHlGiObz0xPbbgEPjYAAdLaE54YiCfWBMDTChQec)Qd00GomfCdjyYejW0ctFQiRjK4isihKGHiHfAAmhypED)Kkxg5OjYAAJemzIemejSqtJ5ouje(vhOPbD0eznTrcMmrIHs3u(lvUbZUdToSstiXrKGHiXUn3NchjdPv5gm7SIdunEibtMirCwcxg50HrJPs667XrtK10gjyYejIZs4Yi3bAAWM9vRy8EhnrwtBKGjtKiZUwoWE86(j1IfFU7TGdesidjsdsiD4n4w1d8(eoHgt9wnEqdYOV(cbgEPjYAAdLaE54YiCfWRfAAmNryWx1lfnEHhbsJ5OjYAAdVb3QEG3uboP7bAqg91hqGHxAISM2qjGxoUmcxb8MzxlhypED)KAXIp3XMGemzIeRMZ(iHurcguAibtMiXUn3NchjdPv5gm7SIdunEWBWTQh4fShVUFsLlJGgKrFLley4n4w1d8IJeRXQ3Wfqe8stK10gkb0Gm6BAbbgEPjYAAdLaE54YiCfWlMwy6tfznbVb3QEG3NWj0yQ3QXdAqg9nnqGHxAISM2qjGxoUmcxb8ou6MYFPYny2DO1HvAcjoIe72CpHtOXuVvJNZkoq14HemzIedLUP8xQCdMDjPiCd2dHemzIedLUP8xQCdMDFkCKmKgjoIeRMZ(iHurI0in4n4w1d86V07vHjvUbZqdAW7MwbR2Gadz0xiWWBWTQh4fK9SNvtWlnrwtBOeqdYOpGadVb3QEGx2NuLrGp8stK10gkb0GmkxiWWlnrwtBOeWBWTQh4LhATk4w1JsxVbV66n1eGe8Y3p0GmMwqGHxAISM2qjGxoUmcxb8gCRoqkAiWIEKqsKqUiXrKWcnnMZFP3RctQAwSF1JJMiRPnsCejSqtJ5cDsQqLGPDyn2rtK10gjoIewOPXCG9419tQCzKJMiRPn8gCR6bE5HwRcUv9O01BWRUEtnbibVGzvKO8Vk1BqdYyAGadV0eznTHsaVCCzeUc4n4wDGu0qGf9iHKiHCrIJiHfAAmN)sVxfMu1Sy)QhhnrwtB4n4w1d8YdTwfCR6rPR3GxD9MAcqcE9Vk1BqdYidcbgEPjYAAdLaE54YiCfWBWT6aPOHal6rcjrcFaVb3QEGxEO1QGBvpkD9g8QR3utasW7BqdYOuacm8stK10gkb8YXLr4kG3GB1bsrdbw0Jesfj8fEdUv9aV8qRvb3QEu66n4vxVPMaKGxUMIde0Gm6ZqGH3GBvpWBG5XqkRXyAm4LMiRPnucObn4nbt8gmhgeyiJ(cbgEPjYAAdLaAqg9bey4LMiRPnucObzuUqGHxAISM2qjGgKX0ccm8gCR6bEFwqWEujKbV0eznTHsaniJPbcm8stK10gkb0GmYGqGH3GBvpWBsBvpWlnrwtBOeqdYOuacm8gCR6bEFJiTYWrc8stK10gkb0Gm6ZqGH3GBvpWBQaN09aV0eznTHsanObVCnfhiiWqg9fcm8stK10gkb82jW7tg8gCR6bEpe4kYAcEpeAwcEdUvhifneyrpsivKiniXrKinibtMirWT6aPOHal6H3dbwnbibV8aFGu8ngAqg9bey4n4w1d8gkqw8MWQEP442)dV0eznTHsaniJYfcm8gCR6bE5DJ31egTvX)bR2GxAISM2qjGgKX0ccm8stK10gkb8YXLr4kG3DBUpfosgsRYny2zfhOA8G3GBvpWlpWhiObzmnqGHxAISM2qjGxoUmcxb8YqKWcnnMZJLW4sRdLfCR4VJMiRPnsWKjsSy1AfM4PcShPScKqcjrcp(gEdUv9aV(l9EvysLBWm0GmYGqGHxAISM2qjGxoUmcxb8UPm7A50HrJPs667X9wWbcjKHe(kn4n4w1d8c2Jx3pPYLrqdYOuacm8gCR6bE5PcGWb4dV0eznTHsaniJ(mey4LMiRPnuc4n4w1d8cuP1kEdcgZgE54YiCfW7Q5SpsaisWJ3uyYJgKqsKy1C23bgPdV8Z5Aszb2JShYOVqdYOpfey4LMiRPnuc4LJlJWvaVlwTwHjEQa7rkRajKqsKWJVrcMmrcgIewOPXC(l9EvysvZI9REC0eznTrcMmrIDBUpfosgsRYny2zfhOA8qIJiXUnxngHNqRYAI2145El4aHesIeYfEdUv9aVzwJNIWNdniJ(kniWWlnrwtBOeWlhxgHRaETqtJ58yjmU06qzb3k(7OjYAAdVb3QEGxEGpqqdYOV(cbgEPjYAAdLaE54YiCfW7Q5SpsaisWJ3uyYJgKqsKy1C23bgPdVb3QEG3LogGQXt9gUaIGgKrF9bey4LMiRPnuc4LJlJWvaV72C(l9EvysLBWSdtlm9PISMqcMmrcl00yo)LEVkmPQzX(vpoAISM2WBWTQh41FP3RctQCdMHgKrFLley4LMiRPnuc4n4w1d8(eoHgt9wnEWlhxgHRaEZSRL7qLq4xDGMg0HPGBWl)CUMuwG9i7Hm6l0Gm6BAbbgEPjYAAdLaE54YiCfWlVB9U9po)LEVkmPYny2HjWOMhjKksCiWvK1KJh4dKIVXiHpDKWhWBWTQh4Lh4de0Gm6BAGadVb3QEG33isRmCKaV0eznTHsaniJ(YGqGHxAISM2qjGxoUmcxb8AHMgZzeg8v9srJx4rG0yoAISM2WBWTQh4nvGt6EGgKrFLcqGHxAISM2qjG3GBvpW7t4eAm1B14bVCCzeUc4ftlm9PISMqIJirMDTCwLO6LYsrQpHcS7TGdesijsix4LFoxtklWEK9qg9fAqg91NHadV0eznTHsaVCCzeUc4Dtz21YPdJgtL013JJnbEdUv9aVG9419tQCze0Gm6Rpfey4LMiRPnuc4LJlJWvaVBkZUwoDy0yQKU(ECSjWBWTQh4fhjwJvVHlGiObn4LVFiWqg9fcm8stK10gkb8YXLr4kGxE36D7FC8UX7AcJ2Q4)GvBombg18iHurc5kn4n4w1d8M1DVvlw85qdYOpGadV0eznTHsaVCCzeUc4L3TE3(hhVB8UMWOTk(py1MdtGrnpsivKqUsdEdUv9aVXWP3WHwXdTgAqgLley4LMiRPnuc4LJlJWvaV8U172)44DJ31egTvX)bR2CycmQ5rcPIeYvAWBWTQh4DvykR7EdniJPfey4n4w1d8QlVu2RyaLD7bsJbV0eznTHsaniJPbcm8stK10gkb8YXLr4kGxE36D7FC8UX7AcJ2Q4)GvBombg18iHurcguAibtMiHvGKYA1UiKqsKWxFH3GBvpWBMWpHbQgpObzKbHadV0eznTHsaVCCzeUc4nZUwoE34DnHrBv8FWQnhBcsCejKdsKzxlxMWpHbQgphBcsWKjsKzxlxw39wTyXN7ytqcMmrcgIe4Gtod3AnsCejyisGdo5AmhjKosWKjsyfiPSwTlcjKej8bdcVb3QEG3K2QEGgKrPaey4LMiRPnuc4LJlJWvaVwG9iZTR3IHtiHuLHemi8gCR6bEJpH4MQxklfPOWttqdAW7BqGHm6ley4n4w1d8gkqw8MWQEP442)dV0eznTHsaniJ(acm8stK10gkb8YXLr4kGxl00yUCH3VQxQemDUJMiRPnsCejYSRLJ3nExty0wf)hSAZXMGehrc5Gez21YX7gVRjmARI)dwT5WeyuZJesIeE8nsWKjsKzxlxwZIv9szHUN3XMGehrIm7A5YAwSQxkl098ombg18iHKiHhFJeshEdUv9aVG9419tQCze0GmkxiWWlnrwtBOeWlhxgHRaETqtJ5YfE)QEPsW05oAISM2iXrKiZUwoE34DnHrBv8FWQnhBcsCejKdsKzxlhVB8UMWOTk(py1MdtGrnpsijs4X3ibtMirMDTCznlw1lLf6EEhBcsCejYSRLlRzXQEPSq3Z7WeyuZJesIeE8nsiD4n4w1d8IJeRXQ3Wfqe0GmMwqGHxAISM2qjGxoUmcxb8Mzxl3HkHWV6annOdtb3qIJirMDTChQec)Qd00Gombg18iHKiHhFdVb3QEG3NWj0yQ3QXdAqgtdey4LMiRPnuc4LJlJWvaVRMZ(ibGibpEtHjpAqcjrIvZzFhyKosCejKdsWqKWcnnMl0jPcvcM2H1yhnrwtBKGjtKyXQ1kmXtfypszfiHesIeE8nsiD4n4w1d8cuP1kEdcgZgAqgzqiWWlnrwtBOeWlhxgHRaExnN9rcarcE8MctE0GesIeRMZ(oWiDK4isihKyXQ1kmXtfypszfiHesIeE8nsWKjsWqKy3MZFP3RctQCdMDwXbQgpK4isihKiZUwoWE86(j1IfFUB3(hKGjtKyXQ1kmXtfypszfiHesIePLlniXzGeE8nsiDKq6WBWTQh41FP3RctQCdMHgKrPaey4LMiRPnuc4LJlJWvaVz21YDOsi8Roqtd6WuWnK4isSBZ9eoHgt9wnEombg18iHKirAHeNbs4X3ibtMibdrcl00yUdvcHF1bAAqhnrwtBK4isWqKy3M7jCcnM6TA8CwXbQgpK4isWqKiZUwoE34DnHrBv8FWQnhBc8gCR6bEFcNqJPERgpObz0NHadV0eznTHsaVCCzeUc4ftlm9PISMqIJiHCqI4SeUmYPdJgtL013JdhdqiHurcFGemzIeXzjCzKthgnMkPRVhhnrwtBK4iseNLWLrUd00Gn7RwX49oAISM2ibtMiHCqI4SeUmYPdJgtL013JJMiRPnsWKjseNLWLrUd00Gn7RwX49oAISM2iH0rIJiHCqcgIeXzjCzKlRzXQEPSq3Z7OjYAAJemzIemejSqtJ5YfE)QEPsW05oAISM2ibtMibdrIm7A54DJ31egTvX)bR2CSjiH0rcPdVb3QEG3NWj0yQ3QXdAqg9PGadVb3QEG33isRmCKaV0eznTHsaniJ(kniWWlnrwtBOeWlhxgHRaETqtJ5mcd(QEPOXl8iqAmhnrwtB4n4w1d8MkWjDpqdYOV(cbgEdUv9aV8UX7AcJ2Q4)GvBWlnrwtBOeqdYOV(acm8gCR6bE5PcGWb4dV0eznTHsaniJ(kxiWWlnrwtBOeWlhxgHRaExnN9rcarcE8MctE0GesIeRMZ(oWiD4n4w1d8U0XaunEQ3Wfqe0Gm6BAbbgEPjYAAdLaE54YiCfW7Q5SpsaisWJ3uyYJgKqsKy1C23bgPJehrc5Gez21Yb2Jx3pPwS4ZDVfCGqcjrI0cjyYejwnN9rcjrIGBvpoWE86(jvUmYX73qcPdVb3QEGxGkTwXBqWy2qdYOVPbcm8stK10gkb8YXLr4kG3m7A5a7XR7Nulw85o2eKGjtKy1C2hjKksWGsdEdUv9aVG9419tQCze0Gm6ldcbgEdUv9aV4iXAS6nCbebV0eznTHsaniJ(kfGadV0eznTHsaVCCzeUc4D3M7jCcnM6TA8CyAHPpvK1esCejyisKzxlhVB8UMWOTk(py1MJnbEdUv9aVpHtOXuVvJh0Gm6RpdbgEPjYAAdLaE54YiCfW7UnN)sVxfMu5gm7W0ctFQiRj4n4w1d86V07vHjvUbZqdAWlywfjk)Rs9geyiJ(cbgEPjYAAdLaE54YiCfWldrIDBUNWj0yQ3QXZzfhOA8G3GBvpW7t4eAm1B14bniJ(acm8stK10gkb8YXLr4kG3fRwRWepvG9iLvGesijs4X3ibtMiHCqIvZzFKaqKGhVPWKhniHKiXQ5SVdmshjKosCejKdsmu6MYFPYny2DO1HvAcjoIe72CpHtOXuVvJNZkoq14HehrIDBUNWj0yQ3QXZHPfM(urwtibtMiXqPBk)Lk3Gzxskc3G9qiXrKGHirMDTCG9419tQfl(ChBcsCejwnN9rcarcE8MctE0GesIeRMZ(oWiDKiTrIGBvpoGkTwXBqWy2oE8MctE0GeNbsixKq6WBWTQh41FP3RctQCdMHgKr5cbgEdUv9aV8UX7AcJ2Q4)GvBWlnrwtBOeqdYyAbbgEdUv9aVHcKfVjSQxkoU9)WlnrwtBOeqdYyAGadVb3QEG33isRmCKaV0eznTHsaniJmiey4LMiRPnuc4LJlJWvaVz21Yb2Jx3pPwS4ZDycmQ5rIJiXqPBk)Lk3Gzxskc3G9qWBWTQh4fShVUFsLlJGgKrPaey4LMiRPnuc4LJlJWvaVRMZ(ibGibpEtHjpAqcjrIvZzFhyKosCejKdsKzxlhypED)KAXIp39wWbcjKejsdsWKjsSAo7JesIeb3QECG9419tQCzKJ3VHeshEdUv9aVavATI3GGXSHgKrFgcm8stK10gkb8YXLr4kG3Hs3u(lvUbZUpfosgsJehrIvZzFKqQibdknK4isSBZ9eoHgt9wnEombg18iHurc5IeNbs4X3WBWTQh41FP3RctQCdMHgKrFkiWWlnrwtBOeWlhxgHRaEX0ctFQiRjK4isihKyO0nL)sLBWS7qRdR0esCejyisSBZ9PWrYqAvUbZoR4avJhsWKjseNLWLroDy0yQKU(EC0eznTrcMmrI4SeUmYDGMgSzF1kgV3rtK10gjKo8gCR6bEFcNqJPERgpObz0xPbbgEPjYAAdLaE54YiCfWBMDTCG9419tQfl(ChBcsWKjsSAo7JesfjyqPHemzIe72CFkCKmKwLBWSZkoq14bVb3QEGxWE86(jvUmcAqg91xiWWlnrwtBOeWlhxgHRaEX0ctFQiRj4n4w1d8(eoHgt9wnEqdYOV(acm8stK10gkb8YXLr4kG3Hs3u(lvUbZUdToSstiXrKy3M7jCcnM6TA8CwXbQgpKGjtKyO0nL)sLBWSljfHBWEiKGjtKyO0nL)sLBWS7tHJKH0iXrKy1C2hjKksKgPbVb3QEGx)LEVkmPYnygAqdAWBWAPAm8ElqwDyvpsX4yzqdAqia]] )

    
end