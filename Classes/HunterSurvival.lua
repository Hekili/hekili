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


    spec:RegisterPack( "Survival", 20190217.0012, [[dSuYsbqiIOEevfCjvcK2Ks4tQeOgfrOtrezvuvLELkPzrvLBrvH2fv(LkLHPs0XikTmLiEgvfnnQQIRPePTrKkFJiGXPsOoNkbToIanpII7ruTpIuoirQQfsK8qIuLUirq1gvjG6JQeqAKQeGtseuALkPMPkHOBsKQyNaPHQsiTuIG8uatvLQVQsaXyvjqSxi)LudMWHfwSKEmQMSkUmYMvQptvgTe50IwTkHWRbIztYTrXUL63kgUeoorqXYH65QA6uUokTDjQVRKmELOopvLwpvv18bQ9dAKSO7iGtyec0LCPSx4LlrwjG7YlLDj(ZfIamFlieqrWbj8ieqhmecaGfxolhkeqr4RAId6oc4hwmNqaLmR4LG3U5Lwj2QJpm3(KHvfwonhhB72Nm8Bv1uVv3HpEOY3kWZov0F7IIjjuKN)2fvcPVayBJWAawC5SCOCFYWrav2uzsyBufbCcJqGUKlL9cVCjYkbCxEPSlXFUyeqWALgmcaizyvHLtl9IJTHakLNd1Okc4qphb4dqbalUCwouqXfaBBegU2hGIsMv8sWB38sReB1XhMBFYWQclNMJJTD7tg(TQAQ3Q7Whpu5Bf4zNk6VDrXKekYZF7IkH0xaSTrynalUCwouUpz4W1(auCbMQy2a7luiReWpOyjxk7fcf(iuC5LsWlVq4A4AFakKElfTh9sq4AFak8rOq6Fo0bkyTuLMVqH0)IEr6GR9bOWhHcP3sr7rhOWcShz6Cdf0Yfy6)C6hkSbk4(YvK2cShzVdU2hGcFekKEMtUt6af8axM08dgkSbkwnyqGcMbtqbfFQ8fkwLwjOWkrqrCotFb)qrYuOigQTWYPHIzdfLdCgvf5qaQ8ThDhbSAN63q3rGkl6oci4wonci0mS4dH1ZwZXZQhbqDuv0bjfYqGUe0DeqWTCAeaFg8j7WOJo(pyvgcG6OQOdskKHa1NO7iaQJQIoiPqaCCAeodeq4FcNg5wLQdHB6F9ZIlNLdLJ6OQOduSakAAztVk11HP6kpQWsfbflGIZyUNWfuB63Y2ZHjMi7hkKguSeNSqH)cfE8duSakoJ5EcxqTPFlBphMyISFOqgOWNULcf(lu4XpqXcOGpJ6mRA3QuD2jM01HP6WetK9dfsdkwIBPqH)cfE8dci4woncGzAVzEsxtJqgcu)bDhbqDuv0bjfcGJtJWzGa2SkLgt8sb2J0wYqqHmqHh)afGbdfsek2dN9HIRqbpEtJjpQHczGI9WzFhtSmuijOybuirOOPLn9QuxhMQR8OclveuSakoJ5EcxqTPFlBpNLCqY2dkwafNXCpHlO20VLTNdtBm9LIQIGcWGHIMw20RsDDyQUIseEyMMGIfqHKHIk7E7yM2BMN0BwSVo2cOybuSho7dfxHcE8MgtEudfYaf7HZ(oMyzOWhHIGB50oqsLsZhgMOpoE8MgtEudf(lu4tOqsiGGB50iGvP6StmPRdtfziqxk6ocG6OQOdskeahNgHZabSho7dfxHcE8MgtEudfYaf7HZ(oMyzOybuuz3BNLf6zRTsK(lOa7El4GafYaf(ekwafsekKmuyHIAZfQIsHUatNWgSJ6OQOduagmuuz3BhZ0EZ8KEZI919wWbbkKbkwkuagmuSho7dfYafb3YPDmt7nZt6AAKJpVbfscbeClNgbasQuA(WWe9bziqLo0Dea1rvrhKuiaooncNbc4mMlBJWDO0vfrNS9CVfCqGczGcFcflGIZyUVeokAsPRdt1zjhKS9GIfqHKHcluuBoMP9M5jDnnYrDuv0bbeClNgbGJcBW63WjieYqGkbq3rauhvfDqsHa440iCgiGMw20RsDDyQUVeokAsbflGIk7E7yM2BMN0BwSVUZSQHIfqHeHc(mQZSQDGKkLMpmmrFCyIjY(HcPbfE8duagmuSho7dfsdkKUlHcjbflGcjdfNXCpHlO20VLTNdtBm9LIQIqab3YPraRs1zNysxhMkYqGEXO7iGGB50iG3isPnCuGaOoQk6GKcziqVq0Dea1rvrhKuiaooncNbcypC2hkUcf84nnM8OgkKbk2dN9DmXYiGGB50iGTkAqY2t)gobHqgcuzVeDhbqDuv0bjfcGJtJWzGaQS7TRCwq4xxM6HXHPGBqbyWqbM2y6lfvfbflGcjcfsgkSqrT5yM2BMN010ih1rvrhOamyOqYqHfkQnx5SGWVUm1dJJ6OQOduagmu00YMEvQRdt1vEuHLkckwafsgkoJ5(s4OOjLUomvNLCqY2dkadgkc)t40iNkmQnDXK)0oQJQIoqbyWqr4FcNg5kt9WmSVEhT37OoQk6afGbdfv292XmT3mpP3SyFDVfCqGc5qXsHcjHacULtJaEcxqTPFlBpKHavwzr3rauhvfDqsHa440iCgialuuBoJWmVE2AQ9cpIHAZrDuv0bbeClNgbukWfZ0idbQSlbDhbqDuv0bjfcGJtJWzGaQS7TJzAVzEsVzX(6ylGcWGHI9WzFOqAqH0DjuagmuCgZ9LWrrtkDDyQol5GKThci4woncGzAVzEsxtJqgcuz9j6oci4woncahf2G1VHtqiea1rvrhKuidbQS(d6ocG6OQOdskeahNgHZabGPnM(srvriGGB50iGNWfuB63Y2dziqLDPO7iaQJQIoiPqaCCAeodeqtlB6vPUomvx5rfwQiOybuCgZ9eUGAt)w2Eol5GKThuagmu00YMEvQRdt1vuIWdZ0euagmu00YMEvQRdt19LWrrtkOybuSho7dfsdkw6LiGGB50iGvP6StmPRdtfzidbWvuuMq3rGkl6ocG6OQOdskeWuGaEYqab3YPraLdCgvfHakhkwcbeClltAQjMKEOqAqXsHIfqXsHcWGHIGBzzstnXK0JakhyDhmecGh4YKMFWidb6sq3rab3YPraHMHfFiSE2AoEw9iaQJQIoiPqgcuFIUJacULtJa4ZGpzhgD0X)bRYqauhvfDqsHmeO(d6ocG6OQOdskeahNgHZabCgZ9LWrrtkDDyQol5GKThci4woncGh4YeYqGUu0Dea1rvrhKuiaooncNbcqYqHfkQnNhlHXPsfAl4wYFh1rvrhOamyOyZQuAmXlfypsBjdbfYafE8dci4woncyvQo7et66WurgcuPdDhbqDuv0bjfci4woncGzAVzEsxtJqaCCAeodeWHQS7Ttfg1MUyYFA3BbheOqoui7LiaUVCfPTa7r2JavwKHavcGUJacULtJa4LcqWbZJaOoQk6GKcziqVy0Dea1rvrhKuiGGB50iaqsLsZhgMOpiaooncNbcypC2hkUcf84nnM8OgkKbk2dN9DmXYiaUVCfPTa7r2JavwKHa9cr3rauhvfDqsHa440iCgiGnRsPXeVuG9iTLmeuidu4XpqbyWqHKHcluuBUvP6StmPZEZ(50oQJQIoqbyWqXzm3xchfnP01HP6SKds2EqXcO4mMlBJWDO0vfrNS9CVfCqGczGcFIacULtJaQSgVeH9fziqL9s0Dea1rvrhKuiaooncNbcWcf1MZJLW4uPcTfCl5VJ6OQOdci4woncGh4YeYqGkRSO7iaQJQIoiPqaCCAeodeWE4SpuCfk4XBAm5rnuiduSho77yILrab3YPraBv0GKTN(nCccHmeOYUe0Dea1rvrhKuiaooncNbc4mMBvQo7et66WuDyAJPVuuveuagmuyHIAZTkvNDIjD2B2pN2rDuv0bbeClNgbSkvNDIjDDyQidbQS(eDhbqDuv0bjfci4wonc4jCb1M(TS9qaCCAeodeqLDVDLZcc)6YupmomfCdbW9LRiTfypYEeOYImeOY6pO7iaQJQIoiPqaCCAeodeaFg1zw1UvP6StmPRdt1HjMi7hkKguuoWzuvKJh4YKMFWqXfuOyjiGGB50iaEGltidbQSlfDhbeClNgb8grkTHJcea1rvrhKuidbQSsh6ocG6OQOdskeahNgHZabyHIAZzeM51ZwtTx4rmuBoQJQIoiGGB50iGsbUyMgziqLvcGUJaOoQk6GKcbeClNgb8eUGAt)w2EiaooncNbcatBm9LIQIGIfqrLDVDwwONT2kr6VGcS7TGdcuidu4tea3xUI0wG9i7rGklYqGk7fJUJaOoQk6GKcbWXPr4mqaiGGB50iaMP9M5jDnncziqL9cr3rauhvfDqsHa440iCgiaeqWTCAeaokSbRFdNGqidziGdTdwLHUJavw0Dea1rvrhKuiaooncNbc4qv292XJ3Y2ZXwafGbdfhQYU3Ut(fKsfvfPzcVK7ylGcWGHIdvz3B3j)csPIQI0uJdpYXwGacULtJa4HsPdULtRv5Biav(MUdgcbWAPknFrgc0LGUJacULtJayFsNgX8iaQJQIoiPqgcuFIUJaOoQk6GKcbeClNgbWdLshClNwRY3qaQ8nDhmecGFEKHa1Fq3rauhvfDqsHa440iCgiGGBzzstnXK0dfYaf(ekwafwOO2CRs1zNysN9M9ZPDuhvfDGIfqHfkQnxOkkf6cmDcBWoQJQIoqXcOWcf1MJzAVzEsxtJCuhvfDqab3YPra8qP0b3YP1Q8neGkFt3bdHayQ6OqVAN63qgc0LIUJaOoQk6GKcbWXPr4mqab3YYKMAIjPhkKbk8juSakSqrT5wLQZoXKo7n7Nt7OoQk6GacULtJa4HsPdULtRv5Biav(MUdgcbSAN63qgcuPdDhbqDuv0bjfcGJtJWzGacULLjn1etspuiduSeOamyOi8pHtJCvflwpBTfQPFh1rvrhOybuyHIAZvt851ZwxGjFDuhvfDGIfqrLDVD8zWNSdJo64)Gvzo2ceqWTCAeapukDWTCATkFdbOY30DWqiG3qgcuja6ocG6OQOdskeahNgHZabeClltAQjMKEOqAqHSiGGB50iaEOu6GB50Av(gcqLVP7GHqaCffLjKHa9Ir3rab3YPrabMhnPTbJP2qauhvfDqsHmKHakWeFyQHHUJavw0Dea1rvrhKuidb6sq3rauhvfDqsHmeO(eDhbqDuv0bjfYqG6pO7iGGB50iGNLHzADbziaQJQIoiPqgc0LIUJaOoQk6GKcziqLo0DeqWTCAeqXy50iaQJQIoiPqgcuja6oci4wonc4nIuAdhfiaQJQIoiPqgc0lgDhbeClNgbukWfZ0iaQJQIoiPqgYqaVHUJavw0DeqWTCAeqOzyXhcRNTMJNvpcG6OQOdskKHaDjO7iaQJQIoiPqaCCAeodeGfkQnxnXNxpBDbM81rDuv0bkwafv292XNbFYom6OJ)dwL5ylGIfqHeHIk7E74ZGpzhgD0X)bRYCyIjY(HczGcp(bkadgkQS7TRQyX6zRTqn97ylGIfqrLDVDvflwpBTfQPFhMyISFOqgOWJFGcjHacULtJayM2BMN010iKHa1NO7iaQJQIoiPqaCCAeodeGfkQnxnXNxpBDbM81rDuv0bkwafv292XNbFYom6OJ)dwL5ylGIfqHeHIk7E74ZGpzhgD0X)bRYCyIjY(HczGcp(bkadgkQS7TRQyX6zRTqn97ylGIfqrLDVDvflwpBTfQPFhMyISFOqgOWJFGcjHacULtJaWrHny9B4eecziq9h0Dea1rvrhKuiaooncNbcOYU3UYzbHFDzQhghMcUbflGIk7E7kNfe(1LPEyCyIjY(HczGcp(bbeClNgb8eUGAt)w2Eidb6sr3rauhvfDqsHa440iCgiG9WzFO4kuWJ30yYJAOqgOypC23XeldflGcjcfsgkSqrT5cvrPqxGPtyd2rDuv0bkadgkSqrT5cvrPqxGPtyd2rDuv0bkwafBwLsJjEPa7rAlziOqgOqw3sHc)fk84hOybue(NWPrUcCYqLdLoBJnTCAh1rvrhOybuSho7dfxHcE8MgtEudfYafYE5LqbyWqHKHIW)eonYvGtgQCO0zBSPLt7OoQk6aflGI9WzFO4kuWJ30yYJAOqgO4IVekKeci4woncaKuP08HHj6dYqGkDO7iaQJQIoiPqaCCAeodeWE4SpuCfk4XBAm5rnuiduSho77yILHIfqHeHInRsPXeVuG9iTLmeuidu4XpqbyWqHKHIZyUvP6StmPRdt1zjhKS9GIfqHeHIk7E7yM2BMN0BwSVUZSQHcWGHInRsPXeVuG9iTLmeuidu4pULcf(lu4XpqHKGcjHacULtJawLQZoXKUomvKHavcGUJaOoQk6GKcbWXPr4mqav292voli8Rlt9W4WuWnOybuCgZ9eUGAt)w2EomXez)qHmqH)af(lu4XpqbyWqHKHcluuBUYzbHFDzQhgh1rvrhOybuizO4mM7jCb1M(TS9CwYbjBpOybuizOOYU3o(m4t2HrhD8FWQmhBbci4wonc4jCb1M(TS9qgc0lgDhbqDuv0bjfcGJtJWzGaW0gtFPOQiOybuirOi8pHtJCQWO20ft(t7WrdcuinOyjqbyWqr4FcNg5uHrTPlM8N2rDuv0bkwafH)jCAKRm1dZW(6D0EVJ6OQOduagmuirOi8pHtJCQWO20ft(t7OoQk6afGbdfH)jCAKRm1dZW(6D0EVJ6OQOduijOybuirOqYqr4FcNg5QkwSE2Alut)oQJQIoqbyWqHKHcluuBUAIpVE26cm5RJ6OQOduagmuizOOYU3o(m4t2HrhD8FWQmhBbuijOqsiGGB50iGNWfuB63Y2dziqVq0DeqWTCAeWBeP0gokqauhvfDqsHmeOYEj6ocG6OQOdskeahNgHZabyHIAZzeM51ZwtTx4rmuBoQJQIoiGGB50iGsbUyMgziqLvw0DeqWTCAeaFg8j7WOJo(pyvgcG6OQOdskKHav2LGUJacULtJa4LcqWbZJaOoQk6GKcziqL1NO7iaQJQIoiPqaCCAeodeWE4SpuCfk4XBAm5rnuiduSho77yILrab3YPraBv0GKTN(nCccHmeOY6pO7iaQJQIoiPqaCCAeodeWE4SpuCfk4XBAm5rnuiduSho77yILHIfqHeHIk7E7yM2BMN0BwSVU3coiqHmqH)afGbdf7HZ(qHmqrWTCAhZ0EZ8KUMg54ZBqHKqab3YPraGKkLMpmmrFqgcuzxk6ocG6OQOdskeahNgHZabuz3BhZ0EZ8KEZI91XwafGbdfsekc)t40ixbozOYHsNTXMwoTJ6OQOduSakKiuSho7dfxHcE8MgtEudfsdkKv2lHcWGHcluuBUYzbHFDzQhgh1rvrhOybuSho7dfsdkK9YlHcjbfsckadgkKiuizOi8pHtJCf4KHkhkD2gBA50oQJQIoqXcOqIqXE4SpuCfk4XBAm5rnuinO4cVekadgkSqrT5kNfe(1LPEyCuhvfDGIfqXE4SpuCfk4XBAm5rnuinO4IVekKeuijOamyOOYU3o(m4t2HrhD8FWQmhBbci4woncGzAVzEsxtJqgcuzLo0DeqWTCAeaokSbRFdNGqiaQJQIoiPqgcuzLaO7iaQJQIoiPqaCCAeodeWzm3t4cQn9Bz75W0gtFPOQiOybuizOOYU3o(m4t2HrhD8FWQmhBbci4wonc4jCb1M(TS9qgcuzVy0Dea1rvrhKuiaooncNbc4mMBvQo7et66WuDyAJPVuuveci4woncyvQo7et66WurgYqa8ZJUJavw0Dea1rvrhKuiaooncNbcGpJ6mRAhFg8j7WOJo(pyvMdtmr2puinOWNxIacULtJaQQzo6nl2xKHaDjO7iaQJQIoiPqaCCAeodeaFg1zw1o(m4t2HrhD8FWQmhMyISFOqAqHpVebeClNgbenNEdhknpukKHa1NO7iaQJQIoiPqaCCAeodeaFg1zw1o(m4t2HrhD8FWQmhMyISFOqAqHpVebeClNgbStmvvZCqgcu)bDhbeClNgbOsVs2RViypEmuBiaQJQIoiPqgc0LIUJaOoQk6GKcbWXPr4mqa8zuNzv74ZGpzhgD0X)bRYCyIjY(HcPbfs3LqbyWqHLmK2g9jjOqgOqwFIacULtJaQe(jmiz7HmeOsh6ocG6OQOdskeahNgHZabuz3BhFg8j7WOJo(pyvMJTakwafsekQS7TRs4NWGKTNJTakadgkQS7TRQM5O3SyFDSfqbyWqHKHcCWjNHhLckwafsgkWbNCdMdfsckadgkSKH02OpjbfYaflr6qab3YPrafJLtJmeOsa0Dea1rvrhKuiaooncNbcWcShzUt(w0CckKMCOq6qab3YPraXxqCtpBTvI0u4PiKHmeatvhf6v7u)g6ocuzr3rauhvfDqsHa440iCgiajdfNXCpHlO20VLTNZsoiz7HacULtJaEcxqTPFlBpKHaDjO7iaQJQIoiPqaCCAeodeWMvP0yIxkWEK2sgckKbk84hOamyOqIqXE4SpuCfk4XBAm5rnuiduSho77yILHcjbflGcjcfnTSPxL66WuDLhvyPIGIfqXzm3t4cQn9Bz75SKds2EqXcO4mM7jCb1M(TS9CyAJPVuuveuagmu00YMEvQRdt1vuIWdZ0euSakKmuuz3BhZ0EZ8KEZI91XwaflGI9WzFO4kuWJ30yYJAOqgOypC23Xeldf(iueClN2bsQuA(WWe9XXJ30yYJAOWFHcFcfscbeClNgbSkvNDIjDDyQidbQpr3rab3YPra8zWNSdJo64)GvziaQJQIoiPqgcu)bDhbeClNgbeAgw8HW6zR54z1JaOoQk6GKcziqxk6oci4wonc4nIuAdhfiaQJQIoiPqgcuPdDhbqDuv0bjfcGJtJWzGaQS7TJzAVzEsVzX(6WetK9dflGIMw20RsDDyQUIseEyMMqab3YPramt7nZt6AAeYqGkbq3rauhvfDqsHa440iCgiG9WzFO4kuWJ30yYJAOqgOypC23XeldflGcjcfv292XmT3mpP3SyFDVfCqGczGILcfGbdf7HZ(qHmqrWTCAhZ0EZ8KUMg54ZBqHKqab3YPraGKkLMpmmrFqgc0lgDhbqDuv0bjfcGJtJWzGaAAztVk11HP6(s4OOjfuSak2dN9HcPbfs3LqXcO4mM7jCb1M(TS9CyIjY(HcPbf(ek8xOWJFqab3YPraRs1zNysxhMkYqGEHO7iaQJQIoiPqaCCAeodeaM2y6lfvfbflGcjcfnTSPxL66WuDLhvyPIGIfqHKHIZyUVeokAsPRdt1zjhKS9GcWGHIW)eonYPcJAtxm5pTJ6OQOduagmue(NWPrUYupmd7R3r79oQJQIoqHKqab3YPrapHlO20VLThYqGk7LO7iaQJQIoiPqaCCAeodeqLDVDmt7nZt6nl2xhBbuagmuSho7dfsdkKUlHcWGHIZyUVeokAsPRdt1zjhKS9qab3YPramt7nZt6AAeYqGkRSO7iaQJQIoiPqaCCAeodeaM2y6lfvfHacULtJaEcxqTPFlBpKHav2LGUJaOoQk6GKcbWXPr4mqanTSPxL66WuDLhvyPIGIfqXzm3t4cQn9Bz75SKds2EqbyWqrtlB6vPUomvxrjcpmttqbyWqrtlB6vPUomv3xchfnPGIfqXE4SpuinOyPxIacULtJawLQZoXKUomvKHmeaRLQ08fDhbQSO7iGGB50iagw)7FfHaOoQk6GKcziqxc6oci4wonc4jm1P5R(W(gcG6OQOdskKHa1NO7iGGB50iGVyWKMRg2dcG6OQOdskKHa1Fq3rab3YPra)mwPS90RcJWiaQJQIoiPqgc0LIUJacULtJa(PtUUQI3qauhvfDqsHmeOsh6oci4woncOjReH1FPHdccG6OQOdskKHavcGUJacULtJa4LYlI81goAjmSPknFrauhvfDqsHmeOxm6oci4wonc4lsCA6V0WbbbqDuv0bjfYqGEHO7iGGB50iGomwm9ApCWjea1rvrhKuidzidbuMWFonc0LCPSx4LlrwzDY6tFkbqaRcCNT3JaUar6lHavclOxGkbHcO4EjcksMIbBqXEWqXfmxrrz6cgkWKeg2ethO4hgckcwBycJoqbVu0E07GRViZMGczVyjiuiHiMPmDGcMyzj4feOGxI4GafsShdkIYrQIQIGISHcIHvfwoTKGcF0hHcjk7YsYbxFrMnbfYEHsqOqcrmtz6afmXYsWliqbVeXbbkKypgueLJufvfbfzdfedRkSCAjbf(Opcfsu2LLKdUgUwcltXGn6afxmueClNgku5BVdUgbuGNDQieGpafaS4Yz5qbfxaSTry4AFakkzwXlbVDZlTsSvhFyU9jdRkSCAoo22Tpz43QQPERUdF8qLVvGNDQO)2fftsOip)TlQesFbW2gH1aS4Yz5q5(KHdx7dqXfyQIzdSVqHSsa)GILCPSxiu4JqXLxkbV8cHRHR9bOq6Tu0E0lbHR9bOWhHcP)5qhOG1svA(cfs)l6fPdU2hGcFekKElfThDGclWEKPZnuqlxGP)ZPFOWgOG7lxrAlWEK9o4AFak8rOq6zo5oPduWdCzsZpyOWgOy1Gbbkygmbfu8PYxOyvALGcRebfX5m9f8dfjtHIyO2clNgkMnuuoWzuvKdUgU2hGcj8LjoRrhOOs7btqbFyQHbfvYl73bfsFoNkShk6P9XsbMzZQGIGB50pumTYxhCDWTC63vGj(Wudt(wfpiW1b3YPFxbM4dtnSRYVfSEmuBHLtdxhClN(DfyIpm1WUk)2EMdCDWTC63vGj(Wud7Q8BpldZ06cYGR9bOaOJIV0yqboYduuz3B6afVf2dfvApyck4dtnmOOsEz)qr0hOOat(yXyw2Eqr(qXzAYbxhClN(DfyIpm1WUk)23rXxAm9BH9W1b3YPFxbM4dtnSRYVvmwonCDWTC63vGj(Wud7Q8BVrKsB4OaUo4wo97kWeFyQHDv(TsbUyMgUgUo4wo97yTuLMVYzy9V)veCDWTC63XAPknFVk)2tyQtZx9H9n46GB50VJ1svA(Ev(TVyWKMRg2dCDWTC63XAPknFVk)2pJvkBp9QWimCDWTC63XAPknFVk)2pDY1vv8gCDWTC63XAPknFVk)wtwjcR)sdhe46GB50VJ1svA(Ev(nEP8IiFTHJwcdBQsZx46GB50VJ1svA(Ev(TViXPP)sdhe46GB50VJ1svA(Ev(Tomwm9ApCWj4A4AFakKWxM4SgDGcQmH9fkSKHGcRebfb3gmuKpueLJufvf5GRdULt)Y5HsPdULtRv5B(1bdjN1svA(6xULFOk7E74XBz75ylad(qv292DYVGuQOQint4LChBbyWhQYU3Ut(fKsfvfPPghEKJTaUgUo4wo9Fv(n2N0PrmpCDWTC6)Q8B8qP0b3YP1Q8n)6GHKZppCDWTC6)Q8B8qP0b3YP1Q8n)6GHKZu1rHE1o1V5xULhClltAQjMKEz85cluuBUvP6StmPZEZ(50oQJQIolSqrT5cvrPqxGPtyd2rDuv0zHfkQnhZ0EZ8KUMg5OoQk6axhClN(Vk)gpukDWTCATkFZVoyi5R2P(n)YT8GBzzstnXK0lJpxyHIAZTkvNDIjD2B2pN2rDuv0bUo4wo9Fv(nEOu6GB50Av(MFDWqYFZVClp4wwM0utmj9YSeWGd)t40ixvXI1ZwBHA63rDuv0zHfkQnxnXNxpBDbM81rDuv0zrLDVD8zWNSdJo64)Gvzo2c46GB50)v534HsPdULtRv5B(1bdjNROOm5xULhClltAQjMKEPjlCDWTC6)Q8BbMhnPTbJP2GRHRdULt)o(5LxvZC0BwSV(LB58zuNzv74ZGpzhgD0X)bRYCyIjY(LMpVeUo4wo974N)Q8BrZP3WHsZdLYVClNpJ6mRAhFg8j7WOJo(pyvMdtmr2V085LW1b3YPFh)8xLFBNyQQM54xULZNrDMvTJpd(KDy0rh)hSkZHjMi7xA(8s46GB50VJF(RYVPsVs2RViypEmuBW1b3YPFh)8xLFRs4NWGKTNF5woFg1zw1o(m4t2HrhD8FWQmhMyISFPjDxcgSLmK2g9jjzK1NW1b3YPFh)8xLFRySCA)YT8k7E74ZGpzhgD0X)bRYCSflKyLDVDvc)egKS9CSfGbxz3BxvnZrVzX(6yladwY4Gtodpk1cjJdo5gmxsGbBjdPTrFssMLiDW1b3YPFh)8xLFl(cIB6zRTsKMcpf5xULBb2Jm3jFlAojn5shCnCDWTC63XvuuMKxoWzuvKFDWqY5bUmP5hSFtH8Nm)khkwsEWTSmPPMys6L2sxSuWGdULLjn1etspCDWTC63XvuuMUk)wOzyXhcRNTMJNvpCDWTC63XvuuMUk)gFg8j7WOJo(pyvgCDWTC63XvuuMUk)gpWLj)YT8ZyUVeokAsPRdt1zjhKS9GRdULt)oUIIY0v53wLQZoXKUomv)YTCjBHIAZ5XsyCQuH2cUL83rDuv0bm4nRsPXeVuG9iTLmKmE8dCDWTC63XvuuMUk)gZ0EZ8KUMg5h3xUI0wG9i7LlRF5w(HQS7Ttfg1MUyYFA3Bbhe5YEjCDWTC63XvuuMUk)gVuacoyE46GB50VJROOmDv(nqsLsZhgMOp(X9LRiTfypYE5Y6xULVho7FLhVPXKh1YSho77yILHRdULt)oUIIY0v53QSgVeH91VClFZQuAmXlfypsBjdjJh)agSKTqrT5wLQZoXKo7n7Nt7OoQk6ag8zm3xchfnP01HP6SKds2EloJ5Y2iChkDvr0jBp3Bbhez8jCDWTC63XvuuMUk)gpWLj)YTCluuBopwcJtLk0wWTK)oQJQIoW1b3YPFhxrrz6Q8BBv0GKTN(nCcc5xULVho7FLhVPXKh1YSho77yILHRdULt)oUIIY0v53wLQZoXKUomv)YT8ZyUvP6StmPRdt1HPnM(srvrGbBHIAZTkvNDIjD2B2pN2rDuv0bUo4wo974kkktxLF7jCb1M(TS98J7lxrAlWEK9YL1VClVYU3UYzbHFDzQhghMcUbxhClN(DCffLPRYVXdCzYVClNpJ6mRA3QuD2jM01HP6WetK9lTYboJQIC8axM08d(c6sGRdULt)oUIIY0v53EJiL2WrbCDWTC63XvuuMUk)wPaxmt7xULBHIAZzeM51ZwtTx4rmuBoQJQIoW1b3YPFhxrrz6Q8BpHlO20VLTNFCF5ksBb2JSxUS(LB5yAJPVuuv0Ik7E7SSqpBTvI0Fbfy3Bbhez8jCTpaf3hO4tgwvyeuW(Hhbf7bdfspt7nZtqHuPrqXGHcjuuydgkamCccbfhwC2EqH0)liUbfZgkSseuiHhEkYpOGpf(cfuWlbfdNZIXuZjOy2qHvIGIGB50qr0hOikkO(afAk8ueuyduyLiOi4wonu0bd5GRdULt)oUIIY0v53yM2BMN010i)Sa7rMo3YzILLGhQYU3ovyuB6Ij)PDVfCqGRdULt)oUIIY0v53WrHny9B4eeYplWEKPZTCMyzj4HQS7Ttfg1MUyYFA3Bbhe4A46GB50VJPQJc9QDQFt(t4cQn9Bz75xULl5ZyUNWfuB63Y2ZzjhKS9GRdULt)oMQok0R2P(TRYVTkvNDIjDDyQ(LB5BwLsJjEPa7rAlziz84hWGL4E4S)vE8MgtEulZE4SVJjwwslKytlB6vPUomvx5rfwQOfNXCpHlO20VLTNZsoiz7T4mM7jCb1M(TS9CyAJPVuuveyWnTSPxL66WuDfLi8WmnTqYv292XmT3mpP3SyFDSfl2dN9VYJ30yYJAz2dN9DmXY(yWTCAhiPsP5ddt0hhpEtJjpQ9xFkj46GB50VJPQJc9QDQF7Q8B8zWNSdJo64)GvzW1b3YPFhtvhf6v7u)2v53cndl(qy9S1C8S6HRdULt)oMQok0R2P(TRYV9grkTHJc4AFakUpqXNmSQWiOG9dpck2dgkKEM2BMNGcPsJGIbdfsOOWgmuay4eeckoS4S9GcP)xqCdkMnuyLiOqcp8uKFqbFk8fkOGxckgoNfJPMtqXSHcRebfb3YPHIOpqruuq9bk0u4PiOWgOWkrqrWTCAOOdgYbxhClN(DmvDuOxTt9BxLFJzAVzEsxtJ8l3YRS7TJzAVzEsVzX(6WetK9VOPLn9QuxhMQROeHhMPj46GB50VJPQJc9QDQF7Q8BGKkLMpmmrF8l3Y3dN9VYJ30yYJAz2dN9DmXYlKyLDVDmt7nZt6nl2x3BbhezwkyW7HZ(YeClN2XmT3mpPRPro(8MKGRdULt)oMQok0R2P(TRYVTkvNDIjDDyQ(LB5nTSPxL66WuDFjCu0KAXE4SV0KUlxCgZ9eUGAt)w2EomXez)sZN(Rh)axhClN(DmvDuOxTt9BxLF7jCb1M(TS98l3YX0gtFPOQOfsSPLn9QuxhMQR8Oclv0cjFgZ9LWrrtkDDyQol5GKThyWH)jCAKtfg1MUyYFAh1rvrhWGd)t40ixzQhMH917O9Eh1rvrhjbxhClN(DmvDuOxTt9BxLFJzAVzEsxtJ8l3YRS7TJzAVzEsVzX(6yladEpC2xAs3LGbFgZ9LWrrtkDDyQol5GKThCDWTC63Xu1rHE1o1VDv(TNWfuB63Y2ZVClhtBm9LIQIGRdULt)oMQok0R2P(TRYVTkvNDIjDDyQ(LB5nTSPxL66WuDLhvyPIwCgZ9eUGAt)w2Eol5GKThyWnTSPxL66WuDfLi8WmnbgCtlB6vPUomv3xchfnPwSho7lTLEjCnCDWTC639M8qZWIpewpBnhpRE4AFakUpqXNmSQWiOG9dpck2dgkKEM2BMNGcPsJGIbdfsOOWgmuay4eeckoS4S9GcP)xqCdkMnuyLiOqcp8uKFqbFk8fkOGxckgoNfJPMtqXSHcRebfb3YPHIOpqruuq9bk0u4PiOWgOWkrqrWTCAOOdgYbxhClN(DVDv(nMP9M5jDnnYVCl3cf1MRM4ZRNTUat(6OoQk6SOYU3o(m4t2HrhD8FWQmhBXcjwz3BhFg8j7WOJo(pyvMdtmr2VmE8dyWv292vvSy9S1wOM(DSflQS7TRQyX6zRTqn97WetK9lJh)ij46GB50V7TRYVHJcBW63WjiKF5wUfkQnxnXNxpBDbM81rDuv0zrLDVD8zWNSdJo64)Gvzo2IfsSYU3o(m4t2HrhD8FWQmhMyISFz84hWGRS7TRQyX6zRTqn97ylwuz3BxvXI1ZwBHA63HjMi7xgp(rsW1b3YPF3BxLF7jCb1M(TS98l3YRS7TRCwq4xxM6HXHPGBlQS7TRCwq4xxM6HXHjMi7xgp(bUo4wo97E7Q8BGKkLMpmmrF8l3Y3dN9VYJ30yYJAz2dN9DmXYlKOKTqrT5cvrPqxGPtyd2rDuv0bmyluuBUqvuk0fy6e2GDuhvfDwSzvknM4LcShPTKHKrw3s9xp(zr4FcNg5kWjdvou6Sn20YPDuhvfDwSho7FLhVPXKh1Yi7LxcgSKd)t40ixbozOYHsNTXMwoTJ6OQOZI9Wz)R84nnM8OwMl(sjbxhClN(DVDv(TvP6StmPRdt1VClFpC2)kpEtJjpQLzpC23XelVqIBwLsJjEPa7rAlziz84hWGL8zm3QuD2jM01HP6SKds2ElKyLDVDmt7nZt6nl2x3zw1GbVzvknM4LcShPTKHKXFCl1F94hjjj46GB50V7TRYV9eUGAt)w2E(LB5v292voli8Rlt9W4WuWTfNXCpHlO20VLTNdtmr2Vm(J)6XpGblzluuBUYzbHFDzQhgh1rvrNfs(mM7jCb1M(TS9CwYbjBVfsUYU3o(m4t2HrhD8FWQmhBbCDWTC6392v53EcxqTPFlBp)YTCmTX0xkQkAHed)t40iNkmQnDXK)0oC0GiTLagC4FcNg5uHrTPlM8N2rDuv0zr4FcNg5kt9WmSVEhT37OoQk6agSed)t40iNkmQnDXK)0oQJQIoGbh(NWPrUYupmd7R3r79oQJQIosAHeLC4FcNg5QkwSE2Alut)oQJQIoGblzluuBUAIpVE26cm5RJ6OQOdyWsUYU3o(m4t2HrhD8FWQmhBHKKeCDWTC6392v53EJiL2WrbCDWTC6392v53kf4IzA)YTCluuBoJWmVE2AQ9cpIHAZrDuv0bUo4wo97E7Q8B8zWNSdJo64)GvzW1b3YPF3BxLFJxkabhmpCDWTC6392v532QObjBp9B4eeYVClFpC2)kpEtJjpQLzpC23XeldxhClN(DVDv(nqsLsZhgMOp(LB57HZ(x5XBAm5rTm7HZ(oMy5fsSYU3oMP9M5j9Mf7R7TGdIm(dyW7HZ(YeClN2XmT3mpPRPro(8MKGRdULt)U3Uk)gZ0EZ8KUMg5xULxz3BhZ0EZ8KEZI91XwagSed)t40ixbozOYHsNTXMwoTJ6OQOZcjUho7FLhVPXKh1stwzVemyluuBUYzbHFDzQhgh1rvrNf7HZ(st2lVusscmyjk5W)eonYvGtgQCO0zBSPLt7OoQk6SqI7HZ(x5XBAm5rT0UWlbd2cf1MRCwq4xxM6HXrDuv0zXE4S)vE8MgtEulTl(sjjjWGRS7TJpd(KDy0rh)hSkZXwaxhClN(DVDv(nCuydw)gobHGRdULt)U3Uk)2t4cQn9Bz75xULFgZ9eUGAt)w2EomTX0xkQkAHKRS7TJpd(KDy0rh)hSkZXwaxhClN(DVDv(TvP6StmPRdt1VCl)mMBvQo7et66WuDyAJPVuuveCnCDWTC63TAN63KhAgw8HW6zR54z1dxhClN(DR2P(TRYVXNbFYom6OJ)dwLbx7dqX9bk(KHvfgbfSF4rqXEWqH0Z0EZ8euivAeumyOqcff2GHcadNGqqXHfNThui9)cIBqXSHcRebfs4HNI8dk4tHVqbf8sqXW5Sym1CckMnuyLiOi4wonue9bkIIcQpqHMcpfbf2afwjckcULtdfDWqo46GB50VB1o1VDv(nMP9M5jDnnYVClp8pHtJCRs1HWn9V(zXLZYHYrDuv0zrtlB6vPUomvx5rfwQOfNXCpHlO20VLTNdtmr2V0wItw)1JFwCgZ9eUGAt)w2EomXez)Y4t3s9xp(zbFg1zw1UvP6StmPRdt1HjMi7xAlXTu)1JFGRdULt)Uv7u)2v53wLQZoXKUomv)YT8nRsPXeVuG9iTLmKmE8dyWsCpC2)kpEtJjpQLzpC23XellPfsSPLn9QuxhMQR8Oclv0IZyUNWfuB63Y2ZzjhKS9wCgZ9eUGAt)w2EomTX0xkQkcm4Mw20RsDDyQUIseEyMMwi5k7E7yM2BMN0BwSVo2If7HZ(x5XBAm5rTm7HZ(oMyzFm4woTdKuP08HHj6JJhVPXKh1(RpLeCDWTC63TAN63Uk)giPsP5ddt0h)YT89Wz)R84nnM8OwM9WzFhtS8Ik7E7SSqpBTvI0Fbfy3Bbhez85cjkzluuBUqvuk0fy6e2GDuhvfDadUYU3oMP9M5j9Mf7R7TGdImlfm49WzFzcULt7yM2BMN010ihFEtsW1b3YPF3QDQF7Q8B4OWgS(nCcc5xULFgZLTr4ou6QIOt2EU3coiY4ZfNXCFjCu0KsxhMQZsoiz7TqYwOO2Cmt7nZt6AAKJ6OQOdCDWTC63TAN63Uk)2QuD2jM01HP6xUL30YMEvQRdt19LWrrtQfv292XmT3mpP3SyFDNzvVqI8zuNzv7ajvknFyyI(4WetK9lnp(bm49WzFPjDxkPfs(mM7jCb1M(TS9CyAJPVuuveCDWTC63TAN63Uk)2BeP0gokGRdULt)Uv7u)2v532QObjBp9B4eeYVClFpC2)kpEtJjpQLzpC23XeldxhClN(DR2P(TRYV9eUGAt)w2E(LB5v292voli8Rlt9W4WuWnWGX0gtFPOQOfsuYwOO2Cmt7nZt6AAKJ6OQOdyWs2cf1MRCwq4xxM6HXrDuv0bm4Mw20RsDDyQUYJkSurlK8zm3xchfnP01HP6SKds2EGbh(NWProvyuB6Ij)PDuhvfDado8pHtJCLPEyg2xVJ27DuhvfDadUYU3oMP9M5j9Mf7R7TGdI8Lkj46GB50VB1o1VDv(TsbUyM2VCl3cf1MZimZRNTMAVWJyO2CuhvfDGRdULt)Uv7u)2v53yM2BMN010i)YT8k7E7yM2BMN0BwSVo2cWG3dN9LM0DjyWNXCFjCu0KsxhMQZsoiz7bxhClN(DR2P(TRYVHJcBW63WjieCDWTC63TAN63Uk)2t4cQn9Bz75xULJPnM(srvrW1b3YPF3QDQF7Q8BRs1zNysxhMQF5wEtlB6vPUomvx5rfwQOfNXCpHlO20VLTNZsoiz7bgCtlB6vPUomvxrjcpmttGb30YMEvQRdt19LWrrtQf7HZ(sBPxIa(cIJaDjlDPidzie]] )

    
end