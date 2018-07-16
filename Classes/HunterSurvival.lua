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
            
            usable = function () return pet.alive end,
            handler = function ()
                if talent.bloodseeker.enabled then applyBuff( "predator", 8 ) end
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
            handler = function ()
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
            gcd = "spell",
            
            startsCombat = true,
            texture = 2065637,

            bind = "wildfire_bomb",
            
            handler = function ()
                applyDebuff( "target", "shrapnel_bomb" )
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
            gcd = "spell",
            
            startsCombat = true,
            texture = 2065636,

            bind = "wildfire_bomb",
            
            handler = function ()
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
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


    spec:RegisterPack( "Survival", 20180715.2030, [[deeDxaqiIqpsjvOlPKQytcPrHu6uifRcjkELqmlsKBHeL2LO(LsyykPCmqYYqs9mIQMgjkDnIGTHevFdjsJJefNtjv16usLyEer3dPAFevwii1dvsf1ivsf5KkPcwjimtLujTtLONkyQkj7vXFfzWK6WuwSs9yitwLUmQntLpluJMOCAvTALuLEnsy2u1Tb1Ub(TudNKoUsQulhXZHA6sUUk2oj8Dq04rI48ijRNevZNiTFcpqnRMW1kEws9AqPmRrPqjHm1Rr96tT8tOOsLNGQHOWI5jamyEcHdrXRW8tq1OY32DwnbCFiiEcYQsfVUSyr8xYo7mQHxGF4J3QVbiI5Qf4hgTy779ITZOSxwXcge)aEbYByCcUVhpJxGrjzhqXKmsvDDCDvckl1syc7Z7R1bWSNW1kEws9AqPmRrPqjHm1RbfLkpLobSkJMLulbjmHlJrtyLShl0pwOnHw1quyXSq3oH2q13aH2)4cl0UMi0RtmfV)ZtqL0U3ZtWq13aCwLWOgEBfD8bgUbjvUeqyO6BaoRsyudVTkc9f4IzFQiMQacdvFdWzvcJA4TvrOVqMru7giGqaHHQVby62P6KvLHOqaHHQVb4i0xaFuUY9SsVJoVUpVQkFZywv2r5jmJiCfTmsmxzKHRhehf1T)2qcY7JZLWSQSJYXjmJiCLpQrL4(4CzmRk7OCCcZicx5JQacdvFdWrOV4G50xmmwaHHQVb4i0xSzcMju8GyLEhDu3(BdjiJ6MCFGv8nzySD8vMWW2dWYj)Acimu9nahH(ITV7BYDiuP07OJ62FBibzu3K7dSIVjdJTJVYeg2Eawo5xtaHHQVb4i0xyaeJlI5tiZ7v6D0rD7VnKGmQBY9bwX3KHX2XxzcdBpalN8RjGWq13aCe6lCpH3(UVk9o6OU93gsqg1n5(aR4BYWy74RmHHThGLt(1eqyO6Baoc9f(pwwHtR3ZngMbLacdvFdWrOVqTRVbk9o67JZLrDtUpWk(Mmm2o(kFuJs7(4C5ntWmHIheNpQsLUpoxE77(MChcv5JQuP0krIH4CrAVpQejgIZnbrdncimu9nahH(cfg5TTNvcyWmDKbsXORskm)HPlXY8mOYWniUBmN2FXzgyBpFLkDFCUmCdI7gZj3Hqv(2qcKkL29X5YWniUBmNChcvzcdBpatzPLwA3hNld3G4UXCYDiuLjmS9amLX1Odot4ygeX1OdMM1JHQVbz4ge3nMt7V4mQXfnuMy0ndBucnYfJUzyJsOraHHQVb4i0xGlM9PIyQcimu9nahH(clbFixMKAxcrAiXcimu9nahH(cu3K7dSIVjdJTJVeqyO6Baoc9fizgfedgR07OBO6vWjgWWpJLtaHacdvFdWrOVyFkKmMqLsVJUHQxbNyad)mwoOIE59X5YyzetfW(0UH35JQacdvFdWrOVazefSsVJUHQxbNyad)mwoOIE59X5YyzetfW(0UH35JQacdvFdWrOVGyQvts4I8uWk9o6xEFCUmwgXubSpTB4D(OkGqaHHQVb4i0xqX79juddBGRsVJURrhCeKHReHJzGKUgDWzyJsIUpoxUE1u7sLmoHvzJKXLHOqs5JAO6vWjgWWpJLKAbegQ(gGJqFbKV)6EcN2n8wP3rNwxJo4iidxjchZajDn6GZWgLivQHQxbNyad)mwoOOjkT3UYq((R7jCA3W7mHDeglZ2Eo6(4Cz4ge3nMtUdHQ8THeivQ749jcJKzKyovpmlzm6sJacdvFdWrOVGI37tOgg2axLEhDxJo4iidxjchZajDn6GZWgLeDFCUC9QP2LkzCcRYgjJldrHKYlGWq13aCe6l2NcjJjuP07OtRelZZGkd57VUNWPh4o4VbzgyBpFLk1D8(eHrYmsmNQhMLmgDPjQHQxbNyad)mwo5LkL2BxzSmIPcyFA3W7C9ikEqC0Bx5humby(02Z89bXzCzikKuEAeqyO6Baoc9fyMOYGkHRheR07OtRHQxbNyad)mwsQJsyhHXYSTNJs7(4Cz4ge3nMtUdHQ8THeivkTkmYBBpNrgifJUrLyzEguzfVktWjfmOHZmW2E(sdn0iv6(4CzfVktWjfmOHZhvbegQ(gGJqFbYikyLEhDdvVcoXag(zSCuhLwdvVcoXag(zSKuEudvVcoXag(zCKy0vsu3(Bdjid57VUNWPDdVZeg2EawQujejgDLe1T)2qcYq((R7jCA3W7mHHThGPraHHQVb4i0xiZiQDdu6D0lZZGkxmbgNAxIbXwmdZGkZaB75RacdvFdWrOVW5nafpioHlYtblGWq13aCe6lqYmkigmwaHHQVb4i0xGzIkdQeUEqSsVJoHDeglZ2Eo6(4Cz4ge3nMtUdHQ8THeiv6(4CzfVktWjfmOHZhvbegQ(gGJqFbCdI7gZP9xSsiQqEovgjMlmDOu6D03hNld3G4UXCYDiuLpQsL6A0blhLVMacdvFdWrOVyFkKmMqLacdvFdWrOVGyQvts4I8uWkHOc55uzKyUW0HAckyc(BWSK61GszwJsHsczOKGYkHjaPrapigpHj4FCHNvt4Yo74Rz1SeQz1emu9nyc2P6KvLHOycmW2E(oqp1SK6z1eyGT98DGEciYxm5TjWR7ZRQY3mMvLDuEcZicxcDuHUmsmxzKHRhel0rfAu3(BdjiVpoxgZQYokhNWmIWv(Ok0rfAjk07JZLXSQSJYXjmJiCLpQtWq13GjaFuUY98uZs5NvtWq13GjCWC6lggpbgyBpFhONAwQSZQjWaB757a9eqKVyYBta1T)2qcYOUj3hyfFtggBhFLjmS9aSqlNql)AtWq13GjSzcMju8G4PMLsywnbgyBpFhONaI8ftEBcOU93gsqg1n5(aR4BYWy74RmHHThGfA5eA5xBcgQ(gmHTV7BYDiun1SKYNvtGb22Z3b6jGiFXK3MaQB)THeKrDtUpWk(Mmm2o(ktyy7byHwoHw(1MGHQVbtWaigxeZNqM3p1SKsNvtGb22Z3b6jGiFXK3MaQB)THeKrDtUpWk(Mmm2o(ktyy7byHwoHw(1MGHQVbtW9eE77(o1SuzMvtWq13Gj4)yzfoTEp3yygutGb22Z3b6PMLR)SAcmW2E(oqpbe5lM82e2hNlJ6MCFGv8nzySD8v(Ok0rfAAf69X5YBMGzcfpioFufAPsf69X5YBF33K7qOkFufAPsfAAfAjk0edX5I0EVqhvOLOqtmeNBcsOPrOPzcgQ(gmb1U(gm1SeQ1MvtqH5p8eKOqxMNbvgUbXDJ50(loZaB75RqlvQqVpoxgUbXDJ5K7qOkFBibcTuPcnTc9(4Cz4ge3nMtUdHQmHHThGfAkRqtRqtRqtRqVpoxgUbXDJ5K7qOktyy7byHMYi0UgDWzchZaHoIq7A0bl00i0RhH2q13GmCdI7gZP9xCg14sOPrOPmcDm6k00i0Yj0XORqtZeyGT98DGEcgQ(gmbfg5TTNNGcJKagmpbKbsXO7uZsOGAwnbdvFdMaUy2NkIPobgyBpFhONAwcf1ZQjyO6BWeSe8HCzsQDjePHepbgyBpFhONAwcL8ZQjyO6BWeqDtUpWk(Mmm2o(AcmW2E(oqp1SekLDwnbgyBpFhONaI8ftEBcgQEfCIbm8ZyHwUjyO6BWeqYmkigmEQzjusywnbgyBpFhONaI8ftEBcgQEfCIbm8ZyHwoHgkHoQqF59X5YyzetfW(0UH35J6emu9nyc7tHKXeQMAwcfLpRMadSTNVd0tar(IjVnbdvVcoXag(zSqlNqdLqhvOV8(4CzSmIPcyFA3W78rDcgQ(gmbKruWtnlHIsNvtGb22Z3b6jGiFXK3MWL3hNlJLrmva7t7gENpQtWq13Gjqm1QjjCrEk4PMLqPmZQjWaB757a9eqKVyYBtW1OdwOJi0idxjchZaHwsH21OdodBuIqhvO3hNlxVAQDPsgNWQSrY4Yqui0sk0Yl0rfAdvVcoXag(zSqlPqt9emu9nycu8EFc1WWg4o1SeQ1FwnbgyBpFhONaI8ftEBc0k0UgDWcDeHgz4kr4ygi0sk0UgDWzyJseAPsfAdvVcoXag(zSqlNqdLqtJqhvOPvOVDLH89x3t40UH3zc7imwMT9SqhvO3hNld3G4UXCYDiuLVnKaHwQuH2D8(eHrYmsmNQhMfAjf6y0vOPzcgQ(gmbiF)19eoTB49uZsQxBwnbgyBpFhONaI8ftEBcUgDWcDeHgz4kr4ygi0sk0UgDWzyJse6Oc9(4C56vtTlvY4ewLnsgxgIcHwsHw(jyO6BWeO49(eQHHnWDQzj1qnRMadSTNVd0tar(IjVnbAfAjk0L5zqLH89x3t40dCh83GmdSTNVcTuPcT749jcJKzKyovpml0sk0XORqtJqhvOnu9k4edy4NXcTCcT8cTuPcnTc9TRmwgXubSpTB4DUEefpiwOJk03UYpOycW8PTN57dIZ4Yqui0sk0Yl00mbdvFdMW(uizmHQPMLut9SAcmW2E(oqpbe5lM82eOvOnu9k4edy4NXcTKcn1cDuHMWocJLzBpl0rfAAf69X5YWniUBmNChcv5BdjqOLkvOPvOvyK32EoJmqkgDf6OcTef6Y8mOYkEvMGtkyqdNzGT98vOPrOPrOPrOLkvO3hNlR4vzcoPGbnC(OobdvFdMaMjQmOs46bXtnlPw(z1eyGT98DGEciYxm5TjyO6vWjgWWpJfA5eAQf6OcnTcTHQxbNyad)mwOLuOPCHoQqBO6vWjgWWpJf6icDm6k0sk0OU93gsqgY3FDpHt7gENjmS9aSqlvQqlbHoIqhJUcTKcnQB)THeKH89x3t40UH3zcdBpal00mbdvFdMaYik4PMLuRSZQjWaB757a9eqKVyYBtOmpdQCXeyCQDjgeBXmmdQmdSTNVtWq13GjiZiQDdMAwsTeMvtWq13Gj48gGIheNWf5PGNadSTNVd0tnlPMYNvtWq13GjGKzuqmy8eyGT98DGEQzj1u6SAcmW2E(oqpbe5lM82eiSJWyz22ZcDuHEFCUmCdI7gZj3Hqv(2qceAPsf69X5YkEvMGtkyqdNpQtWq13GjGzIkdQeUEq8uZsQvMz1eyGT98DGEciYxm5TjSpoxgUbXDJ5K7qOkFufAPsfAxJoyHwoHMYxBcgQ(gmb4ge3nMt7V4jGOc55uzKyUWZsOMAws96pRMGHQVbtyFkKmMq1eyGT98DGEQzP8RnRMadSTNVd0tWq13Gjqm1QjjCrEk4jGOc55uzKyUWZsOMAQjOsyudVTAwnlHAwnbdvFdMa(ad3GKkxtGb22Z3b6PMLupRMGHQVbtaxm7tfXuNadSTNVd0tnlLFwnbdvFdMGmJO2nycmW2E(oqp1utnb7uYAYecp8XB13G1zI5QPMAga]] )

end