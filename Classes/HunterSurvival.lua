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

    spec:RegisterStateTable( "next_wi_bomb", setmetatable( {}, {
        __index = function( t, k )
            if k == "shrapnel" then return state.current_wildfire_bomb == "shrapnel_bomb"
            elseif k == "pheromone" then return state.current_wildfire_bomb == "pheromone_bomb"
            elseif k == "volatile" then return state.current_wildfire_bomb == "volatile_bomb" end
            return false
        end
    } ) )

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

                if debuff.pheromone_bomb.up then gainCharges( "kill_command", 1 ) end
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


    spec:RegisterPack( "Survival", 20180801.1221, [[dSK0FaqiOs1JijvxcrPQnrs5tcvzuqvDkOkRIKK8kLkZIKQBHOyxG8lG0WechdiwgjXZeQmnLsvxdQu2MsP8nHsmoHQ6CkLkRtPK5jeDpsyFcfhKKeSqeXdjjPUijjQnIOu0hrukmsssKtkuQwjPyMik5MikvANqflLKuEQknvLQUkIsjFfrPuJvOK2lK)cQbRQdtzXq5XinzLCzuBwfFMunAsPtl1QjjHETsXSfCBa7wXVLmCG64ikvSCcpNOPt11ry7KOVJinEOsopIQ1lukZxiTFrJabThDxMZiCujcqIFeXpcqGarfvIa3Ip66KdMrxWgDJPZO7yam6EjekBLwaDbBKhkBH2JUYIqqz0vR7GLBbkO6TRLadIwaGkBaIG5DnuHDCqLnafuSqHbk2XiZIvckyrD6albDFZcvab09QacSQeX4Sa(siu2kTaKSbOOlgrh8yFqyO7YCgHJkras8Ji(raceiQaY2fx8rxjyMIWrfCd3q3flPO7ETTm)wMVLpyJUX058Rt(g17AYp0sxM)Pe5RkXB6qdLAsnXE(cgOuYR8DTC(xgSwIyJmcoyoVYNwZQ9Ugz(hrbKpzxIyl2cS65tmEhY3Y)q4ecoFmIoSY31AE8cH8LeGbxcp)2ZhOeC(gLsimNdKdHUGf1Pdm6Q65VxBlZFXhJi45BuVRjFWIUeTtE(Hw653Y8ncVamVPwiqE(ubBoVYhZK8k)AYN8IqKpvRjmQZcOuJQNFS753Y8T8n3zaWE(ELpyrPSxC(Kxe5tA7AZ3Y3OExt(Hw657Anp)wMpw5AZx2aGdC(2SYhSWOEtnSaREQr1ZNuTDGZxWsIG3JE(9KVLpaBtp6hIq(2SYxVQv(YgGiyExdu(XUNpGrE(t55lyjrWZVN8DTC(gMSceohipFTTUww65dUKYglW5ValHsnQE(KnzoK)rWC(ELpVAx98TLb2Z3Mv(nayrPKZV989kFYlcr(fPt(dZljuQr1Z)2aebZ7Au1c7453Y8TaPg5Y8dvTPh98pLiFcWlZzz(2SYVbalkLmapUmFVY31Y5V4Jre88nQ31KFOLUek1KAu98vLXftjCELpgFkbNpTaWmpFmwVhju(Qcukd2L5p1qgTMa4qeY3OExJm)AcKdLAmQ31iHalyAbGzUItWKBsng17AKqGfmTaWmFNcqncDaECZ7Asng17AKqGfmTaWmFNcqpvTsng17AKqGfmTaWmFNcqLeaa1adM9uJQN)DmWsTLNVW6v(yeNdVYx6MlZhJpLGZNwayMNpgR3JmFBw5dwWKbC5Ep653Y8x1WqPgJ6DnsiWcMwayMVtbOYXal1woS0nxMAmQ31iHalyAbGz(ofGcU8UMuJr9UgjeybtlamZ3PauPZCa2fg4uJr9UgjeybtlamZ3PauTMaCvtQj1O65RkJlMs48kFwjlipFVb48DTC(g1lr(TmFtP1bdlWqPgJ6DnsfgHxWM7gDtQXOExJCNcqbiITylWPgJ6DnYDkaLqYWTZaYuJr9Ug5ofGIXcjl20JU69rbTQWQiDGOvjw9yoVGnP0icoKGbSEKXexePgJ6DnYDkaflu1c(qiix9(OGwvyvKoq0QeREmNxWMuAebhsWawpYyIlIuJr9Ug5ofGAdLLUWcWuleuVpkOvfwfPdeTkXQhZ5fSjLgrWHemG1JmM4Ii1yuVRrUtbONwWyHQwQ3hf0QcRI0bIwLy1J58c2KsJi4qcgW6rgtCrKAmQ31i3Pa0qRR1LWQIelDaE8uJr9Ug5ofGAcQnmSxcbpU69rbTQWQiDG20HamTaaSzbjyaRhzm60feGHl1ofLqgPI4Ii1yuVRrUtbOGlVRr9(OaJ4CGOvjw9yoVGnP0icoeby1WhJ4CGWyHKfB6rhIaC0OyeNdewOQf8Hqqoeb4OrXDHrzixuHGA4UWOmujO4LAmQ31i3PauLMOnSaR(yaScQnW60L6kTabRa3DlWJdbuJEvsggRDgIhdlWROrXiohiGA0RsYWhcb5qRI0jAu8XiohiGA0RsYWhcb5qcgW6rsg8XhFmIZbcOg9QKm8HqqoKGbSEKQQtrjKqcwNNDNIsiXJS3OExdeqn6vjzyS2ziAjD8uv60feGHl8IrNUGamCHxQXOExJCNcqLoZbyxyGtng17AK7uaQbdqiwSaUoWurrQm1yuVRrUtbO0QeREmNxWMuAebp1yuVRrUtbOuT2gHbivVpkmQ3kzyEyGMLXasQXOExJCNcq30HamTaaSzPUBcD2H7JcGE2clu1sY8gwajyaRhP69rXPOeYDut6WcwNNipfLqcby4snmIZbYBWW1b21YWsWSjGKUr3ezCQzuVvYW8WanlJuLuJr9Ug5ofGsAhwNwWWyfaM69rb(NIsi3rnPdlyDEI8uucjeGHROrnQ3kzyEyGMLXacEQH)QCis7W60cggRaWGe8rWsTgwGvdJ4CGaQrVkjdFieKdTksNOrpeHaSGPAnHod7nahPoDHxQXOExJCNcq30HamTaaSzPUBcD2H7JcGE2clu1sY8gwajyaRhP69rXPOeYDut6WcwNNipfLqcby4snmIZbYBWW1b21YWsWSjGKUr3ezCPgJ6DnYDkafJWPAzb5Q3hf4J7Uf4XHiTdRtly4EoeYUgiEmSaVIg9qecWcMQ1e6mS3aCK60fEQzuVvYW8WanlJjUOrXFvoKuRWapCagRaWG8MUPhD1wLd1JZIXcWybMx9OdjDJUjY4Wl1yuVRrUtbOswaMhhw69OREFuGVr9wjdZdd0SmsvutWhbl1Aybwn8XiohiGA0RsYWhcb5qRI0jAu8vAI2Wcme1gyD6snC3TapoKYgmlKWk5PaG4XWc8cp8WlAumIZbszdMfsyL8uaqeGtng17AK7uak1ekz17JcJ6TsgMhgOzzmQOg(g1BLmmpmqZYi3MAg1BLmmpmqZYD60vK0QcRI0bI0oSoTGHXkamibdy9iJgf32PtxrsRkSkshis7W60cggRaWGemG1JeVuJr9Ug5ofGQ1eGRAuVpkClWJd5SaqcxhyE0nDgGhhIhdlWRuJr9Ug5ofGEc2SPhDyPl6nCQXOExJCNcqPATncdqMAmQ31i3PaujlaZJdl9E0v3nHo7W9rbqpBjyaRhP69rHGpcwQ1WcSAyeNdeqn6vjz4dHGCOvr6enkgX5aPSbZcjSsEkaicWPgJ6DnYDka1KGzQdxhyxldZMEGvVpkCtOZo0QLUnuogfBl1yuVRrUtbOa1OxLKHXANHztpWQ7MqND4(OaONTwLd1JZIXcWybMx9OdjDJUr9(OaJ4CGaQrVkjdFieKdraoA0trjKXSTisng17AK7uakqn6vjzyS2z1DtOZoCFua0ZwRYH6XzXybySaZRE0HKUr3OEFuGrCoqa1OxLKHpecYHiahn6POeYy2wePgJ6DnYDkafJWPAzb5Q3hfg1BLmmpmqZYyaj1yuVRrUtbOcdSxcyPl6nmmB6bwD3e6Sd3hfa9S1QCOECwmwaglW8QhDiPB0nPgJ6DnYDkavyG9salDrVHv3nHo7W9rbqpBTkhQhNfJfGXcmV6rhs6gDd6QKfYUgeoQebiXpIybKybkcq2E0Lutm9OlrxY2QcQgoXooKn2k)83RLZVbaxcp)tjYpEl(yebpE5lyYoeTGx5llaoFJWlaZ5v(uT2OZsOudz1dNpiBLpzRrsagCjCELVr9UM8JNr4fS5Ur3epOudz1dN)2Tv(Q6AuYcNx5hpD6ccWWv8Y3R8JNoDfV8XheCHhuQHS6HZheq2kFvDnkzHZR8JNoDbby4kE57v(XtNUIx(4RcUWdk1qw9W5dY22kFvJbkL8kFGE2kwZNQLPBYh)P88nLwhmSaNFp5ZaebZ7AWlFYqM8XheCHhuQHS6HZhK4Vv(Qgduk5v(a9SvSMpvlt3Kp(t55BkToyybo)EYNbicM31Gx(KHm5Jpi4cpOudz1dNVk42w5RAmqPKx5d0ZwXA(uTmDt(4pLNVP06GHf487jFgGiyExdE5tgYKp(GGl8GsnKvpC(QelBLVQXaLsELpqpBfR5t1Y0n5J)uE(MsRdgwGZVN8zaIG5Dn4Lpzit(4dcUWdk1qw9W5Rs83kFvJbkL8kFGE2kwZNQLPBYh)P88nLwhmSaNFp5ZaebZ7AWlFYqM8XheCHhuQHS6HZpUi2kFvJbkL8kFGE2kwZNQLPBYh)P88nLwhmSaNFp5ZaebZ7AWlFYqM8XheCHhuQHS6HZpoq2kFvJbkL8kFGE2kwZNQLPBYh)P88nLwhmSaNFp5ZaebZ7AWlFYqM8XheCHhuQj1e7aGlHZR8vjFJ6Dn5hAPlHsnORr4Alb6EBaIG5DnQAHDC0n0sxI2JUl(yebhThHdiO9ORr9Ug01i8c2C3OBqxEmSaVqKGCeoQG2JUg17AqxaIyl2cm6YJHf4fIeKJWjo0E01OExd6siz42zaj6YJHf4fIeKJWz7r7rxEmSaVqKGUur7SOn0LwvyvKoq0QeREmNxWMuAebhsWawpY8Jj)4IaDnQ31GUySqYIn9OJCeo4gAp6YJHf4fIe0LkANfTHU0QcRI0bIwLy1J58c2KsJi4qcgW6rMFm5hxeORr9Ug0flu1c(qiih5iC2gAp6YJHf4fIe0LkANfTHU0QcRI0bIwLy1J58c2KsJi4qcgW6rMFm5hxeORr9Ug01gklDHfGPwiGCeoXcAp6YJHf4fIe0LkANfTHU0QcRI0bIwLy1J58c2KsJi4qcgW6rMFm5hxeORr9Ug090cglu1c5iCIpAp6AuVRbDdTUwxcRksS0b4XrxEmSaVqKGCeoBhAp6YJHf4fIe0LkANfTHU0QcRI0bAthcW0caWMfKGbSEK5ht(60v(QL)POeY8Jur(Xfb6AuVRbDnb1gg2lHGhh5iCajc0E0LhdlWlejOlv0olAdDXiohiAvIvpMZlytknIGdraoF1Yh)8XiohimwizXME0HiaNF0O5JrCoqyHQwWhcb5qeGZpA08X98fgLHCrfc5Rw(4E(cJYqLGMpEORr9Ug0fC5DnihHdiGG2JU8yybEHibDvAbcgDX98DlWJdbuJEvsggRDgIhdlWR8JgnFmIZbcOg9QKm8Hqqo0QiDYpA08XpFmIZbcOg9QKm8HqqoKGbSEK5tM8XpF8Zh)8XiohiGA0RsYWhcb5qcgW6rMVQk)trjKqcwNN83L)POeY8XlFY(8nQ31abuJEvsggRDgIwspF8YxvLVoDLpE5ht(60v(4HUg17AqxLMOnSaJUknb8yam6sTbwNUqochqubThDnQ31GUsN5aSlmWOlpgwGxisqochqIdThDnQ31GUgmaHyXc46atffPs0LhdlWlejihHdiBpAp6AuVRbDPvjw9yoVGnP0ico6YJHf4fIeKJWbeCdThD5XWc8crc6sfTZI2qxJ6TsgMhgOzz(XKpiORr9Ug0LQ12imajYr4aY2q7rxEmSaVqKGUg17Aq3nDiatlaaBwOlv0olAdDpfLqM)U8PM0HfSop5hz(NIsiHamCLVA5JrCoqEdgUoWUwgwcMnbK0n6M8Jm)4YxT8nQ3kzyEyGML5hz(QGUUj0zhUpOlYr4asSG2JU8yybEHibDPI2zrBOl(5FkkHm)D5tnPdlyDEYpY8pfLqcby4k)OrZ3OERKH5HbAwMFm5ds(4LVA5JF(RYHiTdRtlyyScadsWhbl1AyboF1YhJ4CGaQrVkjdFieKdTksN8Jgn)drialyQwtOZWEdW5hz(60v(4HUg17Aqxs7W60cggRaWqochqIpAp6YJHf4fIe01OExd6UPdbyAbayZcDPI2zrBO7POeY83Lp1KoSG15j)iZ)uucjeGHR8vlFmIZbYBWW1b21YWsWSjGKUr3KFK5hh66MqND4(GUihHdiBhAp6YJHf4fIe0LkANfTHU4NpUNVBbECis7W60cgUNdHSRbIhdlWR8Jgn)drialyQwtOZWEdW5hz(60v(4LVA5BuVvYW8WanlZpM8Jl)OrZh)8xLdj1kmWdhGXkamiVPB6rpF1YFvoupolglaJfyE1JoK0n6M8Jm)4Yhp01OExd6Ir4uTSGCKJWrLiq7rxEmSaVqKGUur7SOn0f)8nQ3kzyEyGML5hz(QKVA5l4JGLAnSaNVA5JF(yeNdeqn6vjz4dHGCOvr6KF0O5JF(knrBybgIAdSoDLVA5J757wGhhszdMfsyL8uaq8yybELpE5Jx(4LF0O5JrCoqkBWSqcRKNcaIam6AuVRbDLSampoS07rh5iCube0E0LhdlWlejOlv0olAdDnQ3kzyEyGML5ht(QKVA5JF(g1BLmmpmqZY8Jm)TLVA5BuVvYW8WanlZFx(60v(rMpTQWQiDGiTdRtlyyScadsWawpY8JgnFCl)D5Rtx5hz(0QcRI0bI0oSoTGHXkamibdy9iZhp01OExd6snHsg5iCurf0E0LhdlWlejOlv0olAdDDlWJd5SaqcxhyE0nDgGhhIhdlWl01OExd6Q1eGRAqochvIdThDnQ31GUNGnB6rhw6IEdJU8yybEHib5iCuz7r7rxJ6DnOlvRTryas0LhdlWlejihHJk4gAp6YJHf4fIe01OExd6kzbyECyP3Jo6sfTZI2qxbFeSuRHf48vlFmIZbcOg9QKm8Hqqo0QiDYpA08XiohiLnywiHvYtbaragDDtOZoCFqxKJWrLTH2JU8yybEHibDPI2zrBORBcD2HwT0THY5hJI83g6AuVRbDnjyM6W1b21YWSPhyKJWrLybThD5XWc8crc6AuVRbDbQrVkjdJ1oJUur7SOn0fJ4CGaQrVkjdFieKdrao)OrZ)uucz(XK)2IaDDtOZoCFqxKJWrL4J2JU8yybEHibDnQ31GUa1OxLKHXANrxQODw0g6IrCoqa1OxLKHpecYHiaNF0O5FkkHm)yYFBrGUUj0zhUpOlYr4OY2H2JU8yybEHibDPI2zrBORr9wjdZdd0Sm)yYhe01OExd6Ir4uTSGCKJWjUiq7rxEmSaVqKGUur7SOn0fDnQ31GUcdSxcyPl6nmYr4ehiO9OlpgwGxisqxQODw0g6IUg17AqxHb2lbS0f9gg5ihDblyAbGzoApchqq7rxEmSaVqKGCeoQG2JU8yybEHib5iCIdThD5XWc8crcYr4S9O9ORr9Ug0vsaaudmy2rxEmSaVqKGCeo4gAp6YJHf4fIeKJWzBO9ORr9Ug0fC5DnOlpgwGxisqocNybThDnQ31GUsN5aSlmWOlpgwGxisqocN4J2JUg17AqxTMaCvd6YJHf4fIeKJCKJCKJq]] )

end