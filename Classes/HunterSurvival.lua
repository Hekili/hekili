-- HunterSurvival.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
            duration = 15.599,
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
    } )


    spec:RegisterHook( "runHandler", function( action, pool )
        if buff.camouflage.up and action ~= "camouflage" then removeBuff( "camouflage" ) end
        if buff.feign_death.up and action ~= "feign_death" then removeBuff( "feign_death" ) end
    end )

    local current_wildfire_bomb = "wildfire_bomb"

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    spec:RegisterHook( "reset_precast", function()
        if talent.wildfire_infusion.enabled then
            if IsActiveSpell( 270335 ) then current_wildfire_bomb = "shrapnel_bomb"
            elseif IsActiveSpell( 270323 ) then current_wildfire_bomb = "pheromone_bomb"
            elseif IsActiveSpell( 271045 ) then current_wildfire_bomb = "volatile_bomb"
            else current_wildfire_bomb = "wildfire_bomb" end                
        else
            current_wildfire_bomb = "wildfire_bomb"
        end
    end )

    spec:RegisterStateTable( "bloodseeker", setmetatable( {}, {
        __index = function( t, k )
            if k == "count" then
                return state.active_dot.kill_command
            end

            return state.debuff.kill_command[ k ]
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

            recheck = function () return full_recharge_time - gcd, full_recharge_time end,            
            usable = function () return charges > 1 or active_enemies > 1 or target.time_to_die < ( 9 * haste ) end,
            handler = function ()
                removeBuff( "butchers_bone_apron" )

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

                if debuff.shrapnel_bomb.up then applyDebuff( "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end
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

            aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

            notalent = "butchery",
            
            handler = function ()
                removeBuff( "butchers_bone_apron" )

                gainChargeTime( "wildfire_bomb", min( 5, active_enemies ) )
                gainChargeTime( "shrapnel_bomb", min( 5, active_enemies ) )
                gainChargeTime( "volatile_bomb", min( 5, active_enemies ) )
                gainChargeTime( "pheromone_bomb", min( 5, active_enemies ) )

                if level < 116 and equipped.frizzos_fingertrap and active_dot.lacerate > 0 then
                    active_dot.lacerate = active_dot.lacerate + 1
                end

                if debuff.shrapnel_bomb.up then applyDebuff( "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

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
            charges = function () return talent.alpha_predator.enabled and 2 or 1 end,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132176,

            cycle = function () return talent.bloodseeker.enabled and "bloodseeker" or nil end,
            
            usable = function () return pet.alive end,
            handler = function ()
                if talent.bloodseeker.enabled then
                    applyBuff( "predator", 8 )
                    applyDebuff( "target", "kill_command", 8 )
                end
                if talent.tip_of_the_spear.enabled then addStack( "tip_of_the_spear", 20, 1 ) end

                if debuff.pheromone_bomb.up then gainCharges( "kill_command", 1 ) end
                if debuff.shrapnel_bomb.up then applyDebuff( "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

                gain( 15, "focus" )
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
            
            recheck = function () return focus.time_to_61 end,
            handler = function ()
                if buff.mongoose_fury.down then applyBuff( "mongoose_fury" )
                else applyBuff( "mongoose_fury", buff.mongoose_fury.remains, min( 5, buff.mongoose_fury.stack + 1 ) ) end
                if debuff.shrapnel_bomb.up then
                    if debuff.internal_bleeding.up then applyDebuff( "target", "internal_bleeding", 9, debuff.internal_bleeding.stack + 1 ) end
                end
            end,

            copy = "mongoose_bite_eagle"
        },
        

        muzzle = {
            id = 187707,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            startsCombat = true,
            texture = 1376045,

            toggle = "interrupts",

            usable = function () return target.casting end,            
            handler = function ()
                interrupt()
            end,
        },
        

        pheromone_bomb = {
            id = 270323,            
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or 1 end,
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
            end,

            copy = "raptor_strike_eagle"
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
            
            recheck = function () return remains - ( duration * 0.3 ), remains, buff.mongoose_fury.remains end,
            handler = function ()
                removeBuff( "vipers_venom" )
                applyDebuff( "target", "serpent_sting" )
            end,
        },
        

        shrapnel_bomb = {
            id = 270335,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or 1 end,
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
            charges = function () return talent.guerrilla_tactics.enabled and 2 or 1 end,
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
            charges = function () return talent.guerrilla_tactics.enabled and 2 or 1 end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = function ()
                if current_wildfire_bomb == "wildfire_bomb" then return 2065634 end
                return action[ current_wildfire_bomb ].texture
            end,
            
            aura = "wildfire_bomb",
            bind = function () return current_wildfire_bomb end,

            recheck = function () return full_recharge_time - gcd, full_recharge_time, buff.mongoose_fury.remains, remains - ( duration * 0.3 ), remains end,
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
    
        package = "Survival"
    } )


    spec:RegisterPack( "Survival", 20180717.0140, [[dmupyaqijv8icf6sGeLnraFcKiAuuGtrbTkcf8kbzwuuUfHsTlf9ljPHjOCmc0Yieptq10OOIRjPsBdKuFdKW4iuY5ajjRJIknpcv3JG2NKQoiirYcbupeKiCrqsyKGKOtcsuTsaCtqIu7eqEQqtvsSxv(RQAWeDyslwvEmIjRWLrTzj(SaJws50sTAqsQxdqZMs3gODR0VfnCqSCiphQPt11b12PiFhKA8uu15jKwpHIMpfA)i9j4v5Id15dirctqXkmOqqOygMGMJi1vWl6IcHVieLaOgWxCvq(IryKP2KAVievuBQJRYfXjmIWxSM7qWMB1QbTxd(njjyvCdcBvVZLG0Ixf3GKQpB(Q(kQypytvHGYsBzC1knJerWQverWpuj86m6hHrMAtQDIBqYfFWT1HY37DXH68bKiHjOyfguiiumdtqZjmrGIlIHWKdirQBDV4GXKlwPwJPYgtLkvcrjaQbmvMfQujENlvABSJPYsIOsOsgW22tkauaGYPsedMM4bv61yQmYqQblMInITQZdQKK7O9oxmvwqjivcLgwmftlBgvcVEBPsLklWomIPYhCBhuPxtDOKwlvIHHajrov2ovcMiMkvcbgPoBfDEriOS0w(IIrQeQW8mb25bv(4sIyQKKGp1PYhh0lEsLqPiegIJPYnxXUMIalWwQujENlMkZ1k6KcGs8ox8ecIjj4tDHfRIbKcGs8ox8ecIjj4t9qcRQWbG86Q35sbqjENlEcbXKe8PEiHvlzoOaOeVZfpHGysc(upKWQyyqWC)qyNcGyKkJRcbxlDQeP9GkFWLcpOsSRoMkFCjrmvssWN6u5Jd6ftL6oOsiiwSHKU3Bav2yQCKlpPaOeVZfpHGysc(upKWQ4vHGRL(h7QJPaOeVZfpHGysc(upKWQqsVZLcGs8ox8ecIjj4t9qcRIDMTFhPqOaOeVZfpHGysc(upKWQ1ueKmxkauaeJujuH5zcSZdQKnXirPsVbzQ0RXuPs8erLnMkvtAB1NLNuauI35IfQWE(v3vcGuauI35IdjSkiSykMwMcGs8oxCiHvHX8VDgetbqjENloKWQpgHzeG9gywxesY0osO3jjt0Ox15XxXyf26tedQ9IRp8WOaOeVZfhsy1NnZXVaJe1SUiKKPDKqVtsMOrVQZJVIXkS1Nigu7fxF4HrbqjENloKWQ6sySJu7NOwRzDrijt7iHENKmrJEvNhFfJvyRprmO2lU(WdJcGs8oxCiHvlnIF2mhM1fHKmTJe6DsYen6vDE8vmwHT(eXGAV46dpmkakX7CXHew12b1C8hQgEeaYRtbqjENloKWQqsVZ1SUi8bxktsMOrVQZJVIXkS1NWqeWGhCPmFmcZia7nycdXOXhCPmF2mh)cms0jmeJgRdsj80rP1kqDqkHNjIyifaL4DU4qcRAsrT(SSzRcYcj6(didZmPwywyDC1YRpbZnitm)FTZtE1NLhgn(GlLjyUbzI5Fbgj6CKqVgnAWdUuMG5gKjM)fyKOtedQ9IfBdmWGhCPmbZnitm)lWirNigu7flgkjbgprCaVHkjbgBiuMs8o3jyUbzI5)RDEssSBOyiGmMGQ5nS(aYycQM3qkakX7CXHewf7mB)osHqbqjENloKWQ6hegny0plFckHgtbqjENloKWQKmrJEvNhFfJvyRtbqjENloKWQKAkGifeBwxeQeVnXFEzWMX1lifaL4DU4qcRcyBTFsccQ7WmxrbS)7IqWEn3NnZbMzaz0eXGAVyZ6IWssGXHik2)ioGxXljbgpbvZlWdUuMEd5NLVxJ)yiSIMyxjakE4cOeVnXFEzWMXIlcfaL4DU4qcRcDBhLgX)xc(mRlcnOKeyCiII9pId4v8ssGXtq18gnQeVnXFEzWMX1lOHcyWi9j0TDuAe)Fj4BI4cIX10NLf4bxktWCdYeZ)cms05iHEnASaBTFetQPOa(7nilEazyifaL4DU4qcRcyBTFsccQ7WmxrbS)7IqWEn3NnZbMzaz0eXGAVyZ6IWssGXHik2)ioGxXljbgpbvZlWdUuMEd5NLVxJ)yiSIMyxjakE4uauI35IdjS6d2j1yKOM1fHguhxT86tOB7O0i(3Bbg35o5vFwEy0yb2A)iMutrb83Bqw8aYWqbuI3M4pVmyZ46d3OrdgPpX1qkKLT)xc(MEtaS3abgPp71z0Q2)ZY8O3Gj2vcGIhUHuauI35IdjSkMrq41)yV3aZ6IqduI3M4pVmyZyXfraexqmUM(SSag8GlLjyUbzI5Fbgj6CKqVgnAGjf16ZYtIU)aYqG64QLxFAQHWi83eVj4Kx9z5HHgAOrJp4szAQHWi83eVj4egcfaL4DU4qcRsuKj2SUiujEBI)8YGnJRxebmqjEBI)8YGnJfhQfqjEBI)8YGnJdfqgItY0osO3j0TDuAe)Fj4BIyqTxSrJ1nuaziojt7iHENq32rPr8)LGVjIb1EXgsbqjENloKWQ1ueKmxZ6IqxT86tNrG4Fw(8gObmiV(Kx9z5bfaL4DU4qcRwS6cyVbFSJAazkakX7CXHewLutbePGykakX7CXHewfZii86FS3BGzUIcy)3fHG9AUigu7fBwxeI4cIX10NLf4bxktWCdYeZ)cms05iHEnA8bxkttnegH)M4nbNWqOaOeVZfhsyvWCdYeZ)x7SzUIcy)3fHG9AUJ0N96mAv7)zzE0BWe7kbqZ6IWhCPmbZnitm)lWirNWqmASKeyC9qDyuauI35IdjS6d2j1yKOuauI35IdjSksH4j6JDudiBMROa2)DriyVM7i9zVoJw1(FwMh9gmXUsa8IMyeUZ9asKWeuScdkeSUtrcl8lcTI2EdWx8IkSxlrxm2GWw17CHsG0IFrBJD8v5IdUOWw)QCaj4v5IkX7CVOc75xDxjaErE1NLhhWNFajYv5IkX7CViiSykMw(I8QplpoGp)ak8RYfvI35Erym)BNbXxKx9z5Xb85hqMZv5I8QplpoGVib1oJA9IKmTJe6DsYen6vDE8vmwHT(eXGAVyQSEQm8WUOs8o3l(yeMra2BW5hq19QCrE1NLhhWxKGANrTErsM2rc9ojzIg9Qop(kgRWwFIyqTxmvwpvgEyxujEN7fF2mh)cms0ZpGG6RYf5vFwECaFrcQDg16fjzAhj07KKjA0R684RyScB9jIb1EXuz9uz4HDrL4DUxuxcJDKA)e1Ap)ackUkxKx9z5Xb8fjO2zuRxKKPDKqVtsMOrVQZJVIXkS1Nigu7ftL1tLHh2fvI35EXsJ4NnZX5hqI1v5IkX7CVOTdQ54pun8iaKx)I8QplpoGp)acQ6QCrE1NLhhWxKGANrTEXhCPmjzIg9Qop(kgRWwFcdHkfGknGkFWLY8XimJaS3GjmeQ0OrQ8bxkZNnZXVaJeDcdHknAKkRdvIucpDuATuPauzDOsKs4zIiuPHxujEN7fHKEN75hqcg2v5IMulmFX6qLUA51NG5gKjM)V25jV6ZYdQ0OrQ8bxktWCdYeZ)cms05iHEPsJgPsdOYhCPmbZnitm)lWirNigu7ftLInvAavAavAav(GlLjyUbzI5Fbgj6eXGAVyQumqLLKaJNioGxQmevwscmMknKkHYOsL4DUtWCdYeZ)x78KKyNknKkfduzazqLgsL1tLbKbvA4f5vFwECaFrL4DUx0KIA9z5lAsr)vb5ls09hqgNFajOGxLlQeVZ9IyNz73rkKlYR(S84a(8dibf5QCrL4DUxu)GWObJ(z5tqj04lYR(S84a(8dibd)QCrL4DUxKKjA0R684RyScB9lYR(S84a(8dibnNRYf5vFwECaFrcQDg16fvI3M4pVmyZyQSEQuWlQeVZ9IKAkGifeF(bKG19QCrE1NLhhWxKGANrTEXssGXuziQKOy)J4aEPsXPYssGXtq18uPau5dUuMEd5NLVxJ)yiSIMyxjasLItLHtLcqLkXBt8NxgSzmvkovkYfvI35EraBR9tsqqDhx0vua7)UCXNnZbMzaz0eXGAV4ZpGeeQVkxKx9z5Xb8fjO2zuRx0aQSKeymvgIkjk2)ioGxQuCQSKey8eunpvA0ivQeVnXFEzWMXuz9uPGuPHuPauPbu5i9j0TDuAe)Fj4BI4cIX10NLPsbOYhCPmbZnitm)lWirNJe6LknAKklWw7hXKAkkG)EdYuP4uzazqLgErL4DUxe62oknI)Ve8D(bKGqXv5I8QplpoGVib1oJA9ILKaJPYqujrX(hXb8sLItLLKaJNGQ5PsbOYhCPm9gYplFVg)XqyfnXUsaKkfNkd)IkX7CViGT1(jjiOUJl6kkG9FxU4ZM5aZmGmAIyqTx85hqckwxLlYR(S84a(Ieu7mQ1lAavwhQ0vlV(e62oknI)9wGXDUtE1NLhuPrJuzb2A)iMutrb83BqMkfNkdidQ0qQuaQujEBI)8YGnJPY6PYWPsJgPsdOYr6tCnKczz7)LGVP3ea7nGkfGkhPp71z0Q2)ZY8O3Gj2vcGuP4uz4uPHxujEN7fFWoPgJe98dibHQUkxKx9z5Xb8fjO2zuRx0aQujEBI)8YGnJPsXPsrOsbOsexqmUM(SmvkavAav(GlLjyUbzI5Fbgj6CKqVuPrJuPbuPjf16ZYtIU)aYGkfGkRdv6QLxFAQHWi83eVj4Kx9z5bvAivAivAivA0iv(GlLPPgcJWFt8MGtyixujEN7fXmccV(h79gC(bKiHDvUiV6ZYJd4lsqTZOwVOs82e)5LbBgtL1tLIqLcqLgqLkXBt8NxgSzmvkovc1uPauPs82e)5LbBgtLHOYaYGkfNkjzAhj07e62oknI)Ve8nrmO2lMknAKkRlvgIkdidQuCQKKPDKqVtOB7O0i()sW3eXGAVyQ0WlQeVZ9IefzIp)asebVkxKx9z5Xb8fjO2zuRx0vlV(0zei(NLpVbAadYRp5vFwECrL4DUxSMIGK5E(bKiICvUOs8o3lwS6cyVbFSJAa5lYR(S84a(8dirc)QCrL4DUxKutbePG4lYR(S84a(8dirmNRYf5vFwECaFrcQDg16frCbX4A6ZYuPau5dUuMG5gKjM)fyKOZrc9sLgnsLp4szAQHWi83eVj4egYfvI35ErmJGWR)XEVbx0vua7)UCredQ9Ip)asK6EvUiV6ZYJd4lsqTZOwV4dUuMG5gKjM)fyKOtyiuPrJuzjjWyQSEQeQd7IkX7CViyUbzI5)RD(IUIcy)3LlosF2RZOvT)NL5rVbtSReap)aseO(QCrL4DUx8b7KAms0lYR(S84a(8dirGIRYf5vFwECaFrcQDg16fhPp71z0Q2)ZY8O3Gj2vcGxujEN7frkeprFSJAa5Zp)IqqmjbFQFvoGe8QCrE1NLhhWNFajYv5I8QplpoGp)ak8RYf5vFwECaF(bK5CvUOs8o3lIHbbZ9dH9lYR(S84a(8dO6EvUiV6ZYJd4ZpGG6RYfvI35EriP35ErE1NLhhWNFabfxLlQeVZ9IyNz73rkKlYR(S84a(8diX6QCrL4DUxSMIGK5ErE1NLhhWNF(5NF(Da]] )

end