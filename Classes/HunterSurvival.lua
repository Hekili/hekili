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


    spec:RegisterStateExpr( "current_wildfire_bomb", function () return "wildfire_bomb" end )
    -- current_wildfire_bomb = "wildfire_bomb"

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell

    spec:RegisterHook( "reset_precast", function()
        if talent.wildfire_infusion.enabled then
            if IsActiveSpell( 270335 ) then current_wildfire_bomb = "shrapnel_bomb"
            elseif IsActiveSpell( 270323 ) then current_wildfire_bomb = "pheromone_bomb"
            elseif IsActiveSpell( 271045 ) then current_wildfire_bomb = "volatile_bomb"
            else current_wildfire_bomb = "wildfire_bomb" end                
        else
            current_wildfire_bomb = "wildfire_bomb"
        end

        if now - action.harpoon.lastCast < 1.5 then
            setDistance( 5 )
        end
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
                removeBuff( "butchers_bone_apron" )

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

            cycle = function () return talent.bloodseeker.enabled and "bloodseeker" or nil end,
            
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

            usable = function () return target.casting end,            
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
                if not current_wildfire_bomb or current_wildfire_bomb == "wildfire_bomb" then return 2065634 end
                return action[ current_wildfire_bomb ].texture
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
    
        package = "Survival"
    } )


    spec:RegisterPack( "Survival", 20180903.0952, [[dOKK6aqiviEeGuxIOOsBcq9jviPrbi5uajwfqv1RaWSiQClIszxc(LkYWikCmHultiXZaQmnvi11ikzBef5BefLXruQohqvzDaj18iQ6EeX(es6GavXcbkpequDrar5JaIOgjGiDsaryLIOzciICtGQ0obOHQcjwkqsEQknvvuxLOOI(krrvTxv9xknykomvlwkpgLjlQlJSzP6Zc1OfItRy1efv51aXSjCBuz3k9BjdxKoorrfwoKNdA6KUoQA7IW3vbJhi15vHA9acZNiTFO(J(p)3SR0dyuKr0YUmaFYaCbza(Kv0Ysw)vpoL(BQZaXJP)Uoh93lpkXKWf)n1pwuE(p)xyXJy0FJOAkeuF6u8Or4BbwXDcoC8cxNAziVRNGdh7utuTtTUlBzkXPuu1hbbpDuqeOYNm80rbuzbs5xLq2lpkXKWfb4WX(BJFekqI9B)n7k9agfzeTSldWNmaxqgGVJokh9FHPe7bmkYsw)ntq2FbAS5YJsmjCb2aKYVkHWjbASjIQPqq9PtXJgHVfyf3j4WXlCDQLH8UEcoCStnr1o16USLPeNsrvFee80rbrGkFYWthfqLfiLFvczV8OetcxeGdhdNeOXMlLQexJqyd4KdBIImIw2XgzdBaFGAWjdSb8aEXjXjbASbipIVXeeuJtc0yJSHnGNCMYyd4LhiacbHnAHnzQ78cfBCMo1InIbQbCsGgBKnSbipIVXugBuhftQD6ydb6uebHtTqSrlSHDmtqw1rXKcd4Kan2iByd4TYtFOm2WCucYYYiSrlS5qHabB4keHnKdhXXyZHrJGnAecB8CU2JkeBgUubXrR66ul2uDSjHJgVjOWFtrvFe0FbAS5YJsmjCb2aKYVkHWjbASjIQPqq9PtXJgHVfyf3j4WXlCDQLH8UEcoCStnr1o16USLPeNsrvFee80rbrGkFYWthfqLfiLFvczV8OetcxeGdhdNeOXMlLQexJqyd4KdBIImIw2XgzdBaFGAWjdSb8aEXjXjbASbipIVXeeuJtc0yJSHnGNCMYyd4LhiacbHnAHnzQ78cfBCMo1InIbQbCsGgBKnSbipIVXugBuhftQD6ydb6uebHtTqSrlSHDmtqw1rXKcd4Kan2iByd4TYtFOm2WCucYYYiSrlS5qHabB4keHnKdhXXyZHrJGnAecB8CU2JkeBgUubXrR66ul2uDSjHJgVjOaojojqJnazGMy8kLXMg1leHnSIR5k20O4zHbSb8WyuQcXMTwzlIJ468cSXz6uleBQvCCaN0z6ulmKIiwX1Cvsx4qqWjDMo1cdPiIvCnxbqYjNpMJw11PwCsNPtTWqkIyfxZvaKCQxvgN0z6ulmKIiwX1CfajNG8CC1AtjfNeOXM76PWiLIniFYytJV3Pm2avxHytJ6fIWgwX1CfBAu8SqSX3m2KIizlTuD2ySzGytUwkGt6mDQfgsreR4AUcGKtW1tHrk1cvxH4KotNAHHueXkUMRai5uAPtT4KotNAHHueXkUMRai5eujsyvKNIt6mDQfgsreR4AUcGKtrCuAvlojojqJnazGMy8kLXgkbHogB0HJWgncHnotle2mqSXt4JWBckGt6mDQfkX51Y6Q6mqWjDMo1cbqYjoEGaieeoPZ0PwiasoXdj7OeheN0z6uleajNyUqyDMo1AfduLBDoscldXjDMo1cbqYjMlewNPtTwXav5wNJKCOpwOk30L4mDsqwAjUHGYhfGvxqRgomICFqKD2opCQnqR3eugN0z6uleajNyUqyDMo1AfduLBDoscuLB6sCMojilTe3qq5JcWhrDbTA4WiY9br2z78WP2aTEtqzCsNPtTqaKCI5cH1z6uRvmqvU15ijmb5ji5MUeNPtcYslXnemQrJt6mDQfcGKtoI5lz1cHOvXjXjDMo1cdSmusJqqcbYSXYnDjSQe56WgyvHYZ6kLToe68cnGioFwyubNmWjDMo1cdSmeajNAIQY2op6y5MUewvICDydSQq5zDLYwhcDEHgqeNplmQGtg4KotNAHbwgcGKt(YiOICHL5cHCtxcRkrUoSbwvO8SUszRdHoVqdiIZNfgvWjdCsNPtTWaldbqYP(GOMOQSCtxcRkrUoSbwvO8SUszRdHoVqdiIZNfgvWjdCsNPtTWaldbqYjXehrHwzE85yoAvCsNPtTWaldbqYP0sNALB6sA89EGvfkpRRu26qOZl0aFkWavJV3dncbjeiZgh4tLkTX37HMOQSTZJooWNkv6rqoJckQecGpcYzuOqmqbN0z6ulmWYqaKCYHPetTv3Qril5XcsUPlrDumPH8avFzuuLit4K4KotNAHbMG8eKKeoA8MGKBDoscZrjillJKRsLajvUeUGNK4mDsqwAjUHGYllGDMojilTe3qqPsLfoPZ0PwyGjipbbGKtULJhLjKT6wgQoaXjDMo1cdmb5jiaKCIvfkpRRu26qOZluCsNPtTWatqEccajNyokbj30LKlnaJG80Le2wX1c6Waz2yCsNPtTWatqEccajNomICFqKTvCn5MUKJOUGwneZti0ieUvDMomyGwVjOSuPDEHWIiwehftwD4i5JzzCsNPtTWatqEccajNyrCqqoheN0z6ulmWeKNGaqYjqgHWYkooFZYXoMjiR6OysHsIwUPlPxmEiamhQweftR89IXddCoOXjDMo1cdmb5jiaKCQXRSie6y5MUKoVqyrelIJIjRoCK8XSSuPhrDbTA4WiY9br2z78WP2aTEtqzPsZLgGrqE6scBR4AbDyGmBmW5sdZQeADHTjikpBCaQode5bhoPZ0PwyGjipbbGKtmhLGKB6suxqRgI5jeAec3QothgmqR3eugN0z6ulmWeKNGaqYPUWxqMn2cv0acj30L0lgpeaMdvlIIPv(EX4Hboh04KotNAHbMG8eeasoDye5(GiBR4AYnDj5sdhgrUpiY2kUwarDebJ4nbjvQ6cA1WHrK7dISZ25HtTbA9MGY4KotNAHbMG8eeasobjukTQfQZglh7yMGSQJIjfkjA5MUKgFVhsmPecAtqBXf4tXjDMo1cdmb5jiaKCI5OeKCtxcRkrUoSHdJi3hezBfxlGioFwyut4OXBckWCucYYYizUrbN0z6ulmWeKNGaqYjOsKWQipfN0z6ulmWeKNGaqYPiokTQvUPlrDbTAqjeh0wDlTXEmXrRgO1BckJt6mDQfgycYtqai5eKqP0QwOoBSCSJzcYQokMuOKOLB6squhrWiEtqa3479GoP2QB1iKfMsokavNbI8GdNeOXMZf2ahoEHRe2Wd9ycB6fcBaV1gxfKWgWgLWMcHnGkpvle2Cv0acHnzE0SXyd4bMsmfBQo2OriSbiZJfKCydRspgBiNfbBkgJhHOLryt1XgncHnotNAXgFZyJNMsBgBSKhliSrlSrJqyJZ0PwSzDokGt6mDQfgycYtqai5exTXvbjBBucN0z6ulmWeKNGaqYjKNQfYcv0acHtIt6mDQfgGQe3YXJYeYwDldvhG4KotNAHbOcGKtSQq5zDLYwhcDEHIt6mDQfgGkasoDye5(GiBR4AYnDjDEHWIiwehftwD4i5JzzGvxqRgCrAe3MIOSRfkqR3eugN0z6ulmavaKCcsOuAvluNnwUPlbrDebJ4nbbCJV3dC1gxfKSDE0XbO6mqKilGvxqRgCrAe3MIOSRfkqR3eugNeOXMZf2ahoEHRe2Wd9ycB6fcBaV1gxfKWgWgLWMcHnGkpvle2Cv0acHnzE0SXyd4bMsmfBQo2OriSbiZJfKCydRspgBiNfbBkgJhHOLryt1XgncHnotNAXgFZyJNMsBgBSKhliSrlSrJqyJZ0PwSzDokGt6mDQfgGkasoXvBCvqY2gLKB6sA89EGR24QGKTZJooavNbIezbS6cA1GlsJ42ueLDTqbA9MGY4KotNAHbOcGKtipvlKfQObesUPlrDbTAOnOm0wDBkIooqR3eug4gFVhyvHYZ6kLToe68cnWNcmq1479aRkuEwxPS1HqNxObeX5ZcLpMLLkTX37HMGhzRUvDrTWaFkWn(Ep0e8iB1TQlQfgqeNplu(ywguWjDMo1cdqfajN4QnUkizBJsYnDjQlOvdTbLH2QBtr0XbA9MGYa3479aRkuEwxPS1HqNxOb(uGbQgFVhyvHYZ6kLToe68cnGioFwO8XSSuPn(Ep0e8iB1TQlQfg4tbUX37HMGhzRUvDrTWaI48zHYhZYGcoPZ0PwyaQai5eiJqyzfhNVz5MUKEX4HaWCOArumTY3lgpmW5Gg4gFVh0j1wDRgHSWuYrbO6mqKhC4KotNAHbOcGKtSioiiNdIt6mDQfgGkasobvIewf5P4KotNAHbOcGKthgrUpiY2kUMCtxsVy8qayouTikMw57fJhg4Cqdmq15fclIyrCumz1HJKpMLLknxA4WiY9br2wX1ciQJiyeVjiGB89EGR24QGKTZJooKRdlOGt6mDQfgGkasofXrPvTYnDjQlOvdkH4G2QBPn2JjoA1aTEtqzPsDGGqJsb(ultuqY6B2MsiyTUiqR3eugN0z6ulmavaKCQl8fKzJTqfnGqYnDj9IXdbG5q1IOyALVxmEyGZbnoPZ0PwyaQai5eKqP0QwOoBSCtxsJV3djMucbTjOT4c8PsLIOoIGr8MGagOoI6cA1axTXvbjBBukqR3euwQ0JOUGwnKysje0MG2IlqR3euwQuhii0Ouq4kTQnTgyTbA9MGYsL6abHgLcjOT4kEOT7BmmqR3euguWjDMo1cdqfajN4QnUkizBJsYnDjn(EpWvBCvqY25rhh4tLkTxmEyuLjzGt6mDQfgGkasoH8uTqwOIgqiCsNPtTWaubqYPdJi3hezBfxtUPljxA4WiY9br2wX1ciQJiyeVjiCsNPtTWaubqYjiHsPvTqD2y5MUee1remI3eeojoPZ0Pwy4qFSqvIB54rzczRULHQdqCsNPtTWWH(yHkasoXQcLN1vkBDi05fkojqJnNlSboC8cxjSHh6Xe20le2aERnUkiHnGnkHnfcBavEQwiS5QObecBY8OzJXgWdmLyk2uDSrJqydqMhli5WgwLEm2qolc2umgpcrlJWMQJnAecBCMo1In(MXgpnL2m2yjpwqyJwyJgHWgNPtTyZ6CuaN0z6ulmCOpwOcGKtC1gxfKSTrj5MUehii0Ou4WiYeAji0c5rjMeUiqR3eug4LaTApm2wX1cjkHRJGaoxAasOuAvluNnoGioFwyuJsiAWFmldCU0aKqP0QwOoBCarC(Sq5bxqwG)ywgywvICDydhgrUpiY2kUwarC(SWOgLGSa)XSmoPZ0Pwy4qFSqfajNomICFqKTvCn5MUKoVqyrelIJIjRoCK8XSSuPavVy8qayouTikMw57fJhg4CqdkadulbA1EySTIRfsucxhbbCU0aKqP0QwOoBCqhgiZgdCU0aKqP0QwOoBCarDebJ4nbjv6sGwThgBR4AH0ieQ4QLa(in(EpWvBCvqY25rhh4tbUxmEiamhQweftR89IXddCoOLnNPtTbqgHWYkooFZbMdvlIIPf8doqbN0z6ulmCOpwOcGKtGmcHLvCC(MLB6s6fJhcaZHQfrX0kFVy8WaNdAGB89EqNuB1TAeYctjhfGQZarEWbmqDe1f0QbxKgXTPik7AHc06nbLLkTX37bUAJRcs2op64auDgiYllPs7fJhkVZ0P2axTXvbjBBukWkOck4KotNAHHd9XcvaKCc5PAHSqfnGqYnDj5sdZQeADHTjikpBCaQode5bhW5sdWiipDjHTvCTGomqMng4JOUGwnWvBCvqY2gLc06nbLXjDMo1cdh6JfQai50HrK7dISTIRj30LSeOv7HX2kUwagb5PljaUX37bUAJRcs2op64qUoSaduSQe56WgazeclR448nhqeNplmQXSSuP9IXdJQmjdqb4JKlnajukTQfQZghquhrWiEtq4KotNAHHd9XcvaKCcQejSkYtXjDMo1cdh6JfQai5ux4liZgBHkAaHKB6s6fJhcaZHQfrX0kFVy8WaNdACsNPtTWWH(yHkasobjukTQfQZgl30L0479qIjLqqBcAlUaFQuPiQJiyeVjiGbQJOUGwnWvBCvqY2gLc06nbLLk9iQlOvdjMucbTjOT4c06nbLLkDjqR2dJTvCTqIs46iiGpsU0amcYtxsyBfxlOddKzJLk1bccnkfeUsRAtRbwBGwVjOSuPoqqOrPqcAlUIhA7(gdd06nbLLkTX37bUAJRcs2op64auDgisKfOGt6mDQfgo0hlubqYPiokTQvUPlrDbTAqjeh0wDlTXEmXrRgO1BcklvQdeeAukWNAzIcswFZ2ucbR1fbA9MGY4KotNAHHd9XcvaKCIR24QGKTnkj30L0479axTXvbjBNhDCGpvQ0EX4HrvMKHuP5sdWiipDjHTvCTGomqMngN0z6ulmCOpwOcGKtipvlKfQObecN0z6ulmCOpwOcGKtqcLsRAH6SXYnDjiQJiyeVjiCsNPtTWWH(yHkasoDye5(GiBR4AYnDjlbA1EySTIRfsucxhbbCU0aKqP0QwOoBCqhgiZglv6sGwThgBR4AH0ieQ4QLKkDjqR2dJTvCTamcYtxsaCVy8WOklz83eeco1(agfzeTSldzxgrhIokrj6)EWr7SXW)kZh8aQaeibGajdQXgS5CecBgU0cPytVqyZrntDNxOhvSbrYCWpikJnWIJWgNxloxPm2WI4Bmbd4KajnlHnrdQXgzoxiFAAHukJnotNAXMJQZRL1v1zGCud4K4Kaj4slKszSrMWgNPtTyJyGkmGt(xXav4F(Vh6JfQ)5hWO)Z)1z6u7FDlhpktiB1TmuDa(xA9MGYpyV(agL)8FDMo1(xwvO8SUszRdHoVq)lTEtq5hSxFab3F(V06nbLFW(ldnkHg)VoqqOrPWHrKj0sqOfYJsmjCrGwVjOm2am2SeOv7HX2kUwirjCDee2am2KlnajukTQfQZghqeNpleBIk2eLq0yd4hBIzzSbySjxAasOuAvluNnoGioFwi2ip2aUGSWgWp2eZYydWydRkrUoSHdJi3hezBfxlGioFwi2evSjkbzHnGFSjML)RZ0P2)YvBCvqY2gLE9b8O)Z)LwVjO8d2FzOrj04)TZleweXI4OyYQdhHnYJnXSm2ivk2auytVy8qSbaSH5q1IOyAXg5XMEX4Hboh0ydOGnaJnaf2SeOv7HX2kUwirjCDee2am2KlnajukTQfQZgh0HbYSXydWytU0aKqP0QwOoBCarDebJ4nbHnsLInlbA1EySTIRfsJqOIRwcBagBoc20479axTXvbjBNhDCGpfBagB6fJhInaGnmhQweftl2ip20lgpmW5GgBKnSXz6uBaKriSSIJZ3CG5q1IOyAXgWp2aoSbu(RZ0P2)Eye5(GiBR4AV(akR)8FP1Bck)G9xgAucn(F7fJhInaGnmhQweftl2ip20lgpmW5GgBagBA89EqNuB1TAeYctjhfGQZabBKhBah2am2auyZrWg1f0QbxKgXTPik7AHc06nbLXgPsXMgFVh4QnUkiz78OJdq1zGGnYJnYcBKkfB6fJhInYJnotNAdC1gxfKSTrPaRGk2ak)1z6u7FbzeclR448n)6dOm9N)lTEtq5hS)YqJsOX)BU0WSkHwxyBcIYZghGQZabBKhBah2am2KlnaJG80Le2wX1c6Waz2ySbyS5iyJ6cA1axTXvbjBBukqR3eu(VotNA)lYt1czHkAaHE9buM9N)lTEtq5hS)YqJsOX)7sGwThgBR4AbyeKNUKaBagBA89EGR24QGKTZJooKRdl2am2auydRkrUoSbqgHWYkooFZbeX5ZcXMOInXSm2ivk20lgpeBIk2itYaBafSbyS5iytU0aKqP0QwOoBCarDebJ4nb9xNPtT)9WiY9br2wX1E9bu2)Z)1z6u7FHkrcRI80)sR3eu(b71hqW3F(V06nbLFW(ldnkHg)V9IXdXgaWgMdvlIIPfBKhB6fJhg4Cq)xNPtT)Tl8fKzJTqfnGqV(agTm(Z)LwVjO8d2FzOrj04)TX37HetkHG2e0wCb(uSrQuSbrDebJ4nbHnaJnaf2CeSrDbTAGR24QGKTnkfO1BckJnsLInhbBuxqRgsmPecAtqBXfO1BckJnsLInlbA1EySTIRfsucxhbHnaJnhbBYLgGrqE6scBR4AbDyGmBm2ivk24abHgLccxPvTP1aRnqR3eugBKkfBCGGqJsHe0wCfp029nggO1BckJnsLInn(EpWvBCvqY25rhhGQZabBKGnYcBaL)6mDQ9VqcLsRAH6SXV(agD0)5)sR3eu(b7Vm0OeA8)QUGwnOeIdARUL2ypM4Ovd06nbLXgPsXghii0OuGp1YefKS(MTPecwRlc06nbL)RZ0P2)gXrPvTV(agDu(Z)LwVjO8d2FzOrj04)TX37bUAJRcs2op64aFk2ivk20lgpeBIk2itYaBKkfBYLgGrqE6scBR4AbDyGmB8FDMo1(xUAJRcs22O0RpGrdU)8FDMo1(xKNQfYcv0ac9xA9MGYpyV(ag9r)N)lTEtq5hS)YqJsOX)lI6icgXBc6VotNA)lKqP0QwOoB8RpGrlR)8FP1Bck)G9xgAucn(Fxc0Q9WyBfxlKOeUoccBagBYLgGekLw1c1zJd6Waz2ySrQuSzjqR2dJTvCTqAecvC1syJuPyZsGwThgBR4AbyeKNUKaBagB6fJhInrfBKLm(RZ0P2)Eye5(GiBR4AV(6FZu35f6F(bm6)8FDMo1(xNxlRRQZa5V06nbLFWE9bmk)5)6mDQ9VC8abqiO)sR3eu(b71hqW9N)RZ0P2)Ydj7Oeh8V06nbLFWE9b8O)Z)LwVjO8d2FDMo1(xMlewNPtTwXa1)kgOAxNJ(lldF9buw)5)sR3eu(b7Vm0OeA8)6mDsqwAjUHGyJ8ytuWgGXg1f0QHdJi3hezNTZdNAd06nbL)RZ0P2)YCHW6mDQ1kgO(xXav76C0Fp0hluF9buM(Z)LwVjO8d2FzOrj04)1z6KGS0sCdbXg5XMOGnaJnhbBuxqRgomICFqKD2opCQnqR3eu(VotNA)lZfcRZ0PwRyG6FfduTRZr)fQV(akZ(Z)LwVjO8d2FzOrj04)1z6KGS0sCdbXMOInr)xNPtT)L5cH1z6uRvmq9VIbQ215O)YeKNGE9bu2)Z)1z6u7FDeZxYQfcrR(xA9MGYpyV(6FtreR4AU(NFaJ(p)xA9MGYpyV(agL)8FP1Bck)G96di4(Z)LwVjO8d2RpGh9F(VotNA)lKNJRwBkP)LwVjO8d2RpGY6p)xA9MGYpyV(akt)5)6mDQ9VPLo1(xA9MGYpyV(akZ(Z)1z6u7FHkrcRI80)sR3eu(b71hqz)p)xNPtT)nIJsRA)lTEtq5hSxF9VSm8p)ag9F(V06nbLFW(ldnkHg)VSQe56WgyvHYZ6kLToe68cnGioFwi2evSbCY4VotNA)BJqqcbYSXV(agL)8FP1Bck)G9xgAucn(FzvjY1HnWQcLN1vkBDi05fAarC(SqSjQyd4KXFDMo1(3MOQSTZJo(1hqW9N)lTEtq5hS)YqJsOX)lRkrUoSbwvO8SUszRdHoVqdiIZNfInrfBaNm(RZ0P2)6lJGkYfwMleV(aE0)5)sR3eu(b7Vm0OeA8)YQsKRdBGvfkpRRu26qOZl0aI48zHytuXgWjJ)6mDQ9V9brnrv5xFaL1F(VotNA)RyIJOqRmp(CmhT6FP1Bck)G96dOm9N)lTEtq5hS)YqJsOX)BJV3dSQq5zDLYwhcDEHg4tXgGXgGcBA89EOriiHaz24aFk2ivk20479qtuv225rhh4tXgPsXMJGniNrbfvcb2am2CeSb5mkuig2ak)1z6u7FtlDQ91hqz2F(V06nbLFW(ldnkHg)VQJIjnKhO6lJWMOkbBKP)6mDQ9VomLyQT6wnczjpwqV(6FH6F(bm6)8FDMo1(x3YXJYeYwDldvhG)LwVjO8d2RpGr5p)xNPtT)LvfkpRRu26qOZl0)sR3eu(b71hqW9N)lTEtq5hS)YqJsOX)BNxiSiIfXrXKvhocBKhBIzzSbySrDbTAWfPrCBkIYUwOaTEtq5)6mDQ9VhgrUpiY2kU2RpGh9F(V06nbLFW(ldnkHg)ViQJiyeVjiSbySPX37bUAJRcs2op64auDgiyJeSrwydWyJ6cA1GlsJ42ueLDTqbA9MGY)1z6u7FHekLw1c1zJF9buw)5)sR3eu(b7Vm0OeA8)2479axTXvbjBNhDCaQodeSrc2ilSbySrDbTAWfPrCBkIYUwOaTEtq5)6mDQ9VC1gxfKSTrPxFaLP)8FP1Bck)G9xgAucn(FvxqRgAdkdTv3MIOJd06nbLXgGXMgFVhyvHYZ6kLToe68cnWNInaJnaf20479aRkuEwxPS1HqNxObeX5ZcXg5XMywgBKkfBA89EOj4r2QBvxulmWNInaJnn(Ep0e8iB1TQlQfgqeNpleBKhBIzzSbu(RZ0P2)I8uTqwOIgqOxFaLz)5)sR3eu(b7Vm0OeA8)QUGwn0gugARUnfrhhO1BckJnaJnn(EpWQcLN1vkBDi05fAGpfBagBakSPX37bwvO8SUszRdHoVqdiIZNfInYJnXSm2ivk20479qtWJSv3QUOwyGpfBagBA89EOj4r2QBvxulmGioFwi2ip2eZYydO8xNPtT)LR24QGKTnk96dOS)N)lTEtq5hS)YqJsOX)BVy8qSbaSH5q1IOyAXg5XMEX4Hboh0ydWytJV3d6KARUvJqwyk5OauDgiyJ8yd4(RZ0P2)cYiewwXX5B(1hqW3F(VotNA)llIdcY5G)LwVjO8d2RpGrlJ)8FDMo1(xOsKWQip9V06nbLFWE9bm6O)Z)LwVjO8d2FzOrj04)TxmEi2aa2WCOArumTyJ8ytVy8WaNdASbySbOWMoVqyrelIJIjRoCe2ip2eZYyJuPytU0WHrK7dISTIRfquhrWiEtqydWytJV3dC1gxfKSDE0XHCDyXgq5VotNA)7HrK7dISTIR96dy0r5p)xA9MGYpy)LHgLqJ)x1f0QbLqCqB1T0g7XehTAGwVjOm2ivk24abHgLc8PwMOGK13SnLqWADrGwVjO8FDMo1(3iokTQ91hWOb3F(V06nbLFW(ldnkHg)V9IXdXgaWgMdvlIIPfBKhB6fJhg4Cq)xNPtT)Tl8fKzJTqfnGqV(ag9r)N)lTEtq5hS)YqJsOX)BJV3djMucbTjOT4c8PyJuPydI6icgXBccBagBakS5iyJ6cA1axTXvbjBBukqR3eugBKkfBoc2OUGwnKysje0MG2IlqR3eugBKkfBCGGqJsbHR0Q20AG1gO1BckJnsLInoqqOrPqcAlUIhA7(gdd06nbLXgq5VotNA)lKqP0QwOoB8RpGrlR)8FP1Bck)G9xgAucn(FB89EGR24QGKTZJooWNInsLIn9IXdXMOInYKm(RZ0P2)YvBCvqY2gLE9bmAz6p)xNPtT)f5PAHSqfnGq)LwVjO8d2RpGrlZ(Z)LwVjO8d2FzOrj04)nxA4WiY9br2wX1ciQJiyeVjO)6mDQ9VhgrUpiY2kU2RpGrl7)5)sR3eu(b7Vm0OeA8)IOoIGr8MG(RZ0P2)cjukTQfQZg)6R)Ljipb9NFaJ(p)xA9MGYpy)Ts)lK0)6mDQ9VjC04nb93eUGN(RZ0jbzPL4gcInYJnYcBagBCMojilTe3qqSrQuSrw)nHJSRZr)L5OeKLLrV(agL)8FDMo1(x3YXJYeYwDldvhG)LwVjO8d2RpGG7p)xNPtT)LvfkpRRu26qOZl0)sR3eu(b71hWJ(p)xA9MGYpy)LHgLqJ)3CPbyeKNUKW2kUwqhgiZg)xNPtT)L5Oe0RpGY6p)xA9MGYpy)LHgLqJ)3JGnQlOvdX8ecncHBvNPddgO1BckJnsLInDEHWIiwehftwD4iSrESjML)RZ0P2)Eye5(GiBR4AV(akt)5)6mDQ9VSioiiNd(xA9MGYpyV(akZ(Z)LwVjO8d2FDMo1(xqgHWYkooFZ)LHgLqJ)3EX4HydaydZHQfrX0InYJn9IXddCoO)l7yMGSQJIjf(ag9RpGY(F(V06nbLFW(ldnkHg)VDEHWIiwehftwD4iSrESjMLXgPsXMJGnQlOvdhgrUpiYoBNho1gO1BckJnsLIn5sdWiipDjHTvCTGomqMngBagBYLgMvj06cBtquE24auDgiyJ8yd4(RZ0P2)24vwecD8RpGGV)8FP1Bck)G9xgAucn(FvxqRgI5jeAec3QothgmqR3eu(VotNA)lZrjOxFaJwg)5)sR3eu(b7Vm0OeA8)2lgpeBaaByouTikMwSrESPxmEyGZb9FDMo1(3UWxqMn2cv0ac96dy0r)N)lTEtq5hS)YqJsOX)BU0WHrK7dISTIRfquhrWiEtqyJuPyJ6cA1WHrK7dISZ25HtTbA9MGY)1z6u7FpmICFqKTvCTxFaJok)5)sR3eu(b7VotNA)lKqP0QwOoB8FzOrj04)TX37HetkHG2e0wCb(0)YoMjiR6OysHpGr)6dy0G7p)xA9MGYpy)LHgLqJ)xwvICDydhgrUpiY2kUwarC(SqSjQytchnEtqbMJsqwwgHnYCXMO8xNPtT)L5Oe0RpGrF0)5)6mDQ9VqLiHvrE6FP1Bck)G96dy0Y6p)xA9MGYpy)LHgLqJ)x1f0QbLqCqB1T0g7XehTAGwVjO8FDMo1(3iokTQ91hWOLP)8FP1Bck)G9xNPtT)fsOuAvluNn(Vm0OeA8)IOoIGr8MGWgGXMgFVh0j1wDRgHSWuYrbO6mqWg5XgW9x2Xmbzvhftk8bm6xFaJwM9N)RZ0P2)YvBCvqY2gL(lTEtq5hSxFaJw2)Z)1z6u7FrEQwilurdi0FP1Bck)G96RV(xNxJuO)EhoEHRtTa5iVRV(6)a]] )

end