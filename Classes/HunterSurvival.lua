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
            duration = 12,
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
        latent_poison = {
            id = 273286,
            duration = 20,
            max_stack = 10
        }
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

                removeDebuff( "target", "latent_poison" )

                if azerite.wilderness_survival.enabled then
                    gainChargeTime( "wildfire_bomb", 1 )
                    if talent.wildfire_infusion.enabled then
                        gainChargeTime( "shrapnel_bomb", 1 )
                        gainChargeTime( "pheromone_bomb", 1 )
                        gainChargeTime( "volatile_bomb", 1 )
                    end
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
    
        potion = "potion_of_bursting_blood",

        package = "Survival"
    } )


    spec:RegisterPack( "Survival", 20180918.1308, [[dOuukbqiIcpcLKUKksH2KkQpPIuAuQi5uQaTkuO4va0SiQ6wuvv2fv(faggkPogrPLPc4zuvX0urQUgvvzBOq6BOqLXruuNdfQADefP5ru5EOu7JQkDqQQQAHOepeLe5IOqjFufPGgjkjQtIcLYkvHMPksrDtIIyNOGHsvvLLIscpvLMkGCvuOu5ROqPQ9c6VKAWKCyHflQhJQjRuxgAZk5ZuLrtv50sTAvKI8Aa1SjCBG2TIFlz4I44Qify5i9CvnDkxNiBxK67IKXRc68QiwpkeZhfTFedLfce8UddHmCawlRmZAgVSYStw)WAz(aYcV2jji8MeCGdpeENaeH3RenDNoeWBsCIOInei49ljkhHxFML8YuaaWRnFszhVab4BqjryDnCASma(gKdqwuzaYRW)2yAasO1Qf4dG)JISIO3pa(pwHMvwAmKQVs00D6q4(gKdVzPwym2gygE3HHqgoaRLvMznJxwz2jRFynJ70z8W7NGCidhWF(dE34ZHxwLOUs00D6qquSYsJHuYrwLO8zwYltbaaV28jLD8ceGVbLeH11WPXYa4BqoazrLbiVc)BJPbiHwRwGpa(pkYkIE)a4)yfAwzPXqQ(krt3PdH7Bqo5iRsuxmXqWmsjkzLz5jQdWAzLzIY)ikzLPS(0jk)NmHCKCKvjkwjFX4HVmLCKvjk)JO8)7nUjkzIeJWicKOSIO24kKegrfCRRHOe9BoYrwLO8pIIvYxmE4MOSG6HMUxefEycf)VR5jkRik(jCbQTG6H27ihzvIY)ikzsT7vJBIIh00OMVPeLvevQIcmrbwuKOW4BXjevQ28ruMpKOI9UMt7tunyIabXXcRRHOQfrLoODKfOdEtO1Qfi8YQe1vIMUthcIIvwAmKsoYQeLpZsEzkaa41MpPSJxGa8nOKiSUgonwgaFdYbilQma5v4FBmnaj0A1c8bW)rrwr07ha)hRqZklngs1xjA6oDiCFdYjhzvI6IjgcMrkrjRmlprDawlRmtu(hrjRmL1Nor5)KjKJKJSkrXk5lgp8LPKJSkr5FeL)FVXnrjtKyegrGeLve1gxHKWiQGBDneLOFZroYQeL)ruSs(IXd3eLfup009IOWdtO4)DnprzfrXpHlqTfup0Eh5iRsu(hrjtQDVACtu8GMg18nLOSIOsvuGjkWIIefgFloHOs1MpIY8HevS31CAFIQbteiiowyDnevTiQ0bTJSaDKJKJSkrXyDiYLmCtuzCvuKO4fyomIkJE98oIY)Z5yI9e1uJ)5lOGljbrfCRR5jQAeN4ihdU118UekYlWCySxI4bMCm4wxZ7sOiVaZHbiBacjpqCSW6AihdU118UekYlWCyaYgGvvBYXGBDnVlHI8cmhgGSb4LabRrNGg5iRsu3jsEFLru0O3evwATWnr9wyprLXvrrIIxG5WiQm61ZtuXSjQek6FjLz94ru9tu7Aqh5yWTUM3LqrEbMddq2a8tK8(kt)wyp5yWTUM3LqrEbMddq2aKuwxd5yWTUM3LqrEbMddq2a8gIcTrJeYXGBDnVlHI8cmhgGSbWxqtQAihjhzvIIX6qKlz4MOW0i9eIYAqKOmFirfCROev)evKoArKfOJCm4wxZZoKSshMfCGjhdU118aYgaqjgHrei5yWTUMhq2ai9OUne8jhdU118aYgaEie6GBDnAr)M8taIS57NCm4wxZdiBa4HqOdU11Of9BYpbiYo1Q1VjFVyhCRtJACqWgF5oWzle4yUuTyVAkQ7zj9DnoCISa3NpLmSqGJ5crIVqNqXDyf1HtKf4MjtzyHahZbwJxvpQZTHoCISa3hKCm4wxZdiBa4HqOdU11Of9BYpbiYgmRJeDQvRFt(EXo4wNg14GGn(YDGZwiWXCPAXE1uu3Zs67AC4ezbUpBHahZfIeFHoHI7WkQdNilW9zle4yoWA8Q6rDUn0HtKf4MCm4wxZdiBa4HqOdU11Of9BYpbiY(n57f7GBDAuJdc24l3boldle4yUuTyVAkQ7zj9DnoCISa3KJb36AEazdapecDWTUgTOFt(jar2CbgPr57f7GBDAuJdc247xzjhdU118aYgGGYJb1wrP4yKJKJb36AEhF)SZIQ26Le9e57fBEvIDLAC8QO7Ecd364)qsyokcg98(1pSMCm4wxZ747hq2aedhFJgcnpec57fBEvIDLAC8QO7Ecd364)qsyokcg98(1pSMCm4wxZ747hq2aSAkMfvTLVxS5vj2vQXXRIU7jmCRJ)djH5Oiy0Z7x)WAYXGBDnVJVFazdGO98zV(0K02dehJCm4wxZ747hq2aKr6JuG7Xt(EXMxLyxPghVk6UNWWTo(pKeMJIGrpVFzuwZKP1GO2k9Ur5KvwYXGBDnVJVFazdqszDnY3l2zP1YXRIU7jmCRJ)djH5KsoFQS0A5Yi9rkW945KsyYmlTwUSOQTEjrpXjLWKPmObhDgTeIZYGgC0vu(bzY0AquBLE3OChGrjhdU118o((bKnaXNGCtxlT5d1y4jq57fBlOEO529BXWr)YMrjhjhdU118oUaJ0i70bTJSaLFcqKnpOPrnFtLVsy)OjF6qiHSdU1PrnoiyJVC(7CWTonQXbbB8zY0FKJb36AEhxGrAeq2aeAqj6gP6AP50k1togCRR5DCbgPrazdaVk6UNWWTo(pKeg5yWTUM3XfyKgbKna8GMgLVxS3L5EF0izqHoxGzN1CG7XJCm4wxZ74cmsJaYgGuTyVAkQZfyw(EXwgwiWXCEsiL2crOTGBn)D4ezbUzYCjjeAkY9fupuBnikNhFtogCRR5DCbgPrazdaynEv9Oo3gkp)eUa1wq9q7zlR89I9gZsRLtegoMoP6Vg3Bbhy2YYAYXGBDnVJlWinciBa4(cGPb4togCRR5DCbgPrazdaWTqO5fiymB55NWfO2cQhApBzLVxSxfx6bKhVPPOhoYTkU07aJdjhdU118oUaJ0iGSbilzCFi9e57f7LKqOPi3xq9qT1GOCE8ntMYWcboMlvl2RMI6EwsFxJdNilWntM7YCVpAKmOqNlWSZAoW94DExMRhdPti0zbI7E8CVfCGLZpKJb36AEhxGrAeq2aWdAAu(EX2cboMZtcP0wicTfCR5VdNilWn5yWTUM3XfyKgbKnalrma3JN(nAdmkFVyVkU0dipEttrpCKBvCP3bghsogCRR5DCbgPrazdqQwSxnf15cmlFVyVlZLQf7vtrDUaZokUO47lYcKjtle4yUuTyVAkQ7zj9DnoCISa3KJb36AEhxGrAeq2a8inbht)wpEYZpHlqTfup0E2YkFVyNLwlx6obPVonofOtkHCm4wxZ74cmsJaYgaEqtJY3l28Qe7k14s1I9QPOoxGzhfbJEE)MoODKfOJh00OMVPNgpa5yWTUM3XfyKgbKnaVHOqB0iHCm4wxZ74cmsJaYgaFbnPQr(EX2cboMZqk4RRLghVWdbXXC4ezbUjhdU118oUaJ0iGSb4rAcoM(TE8KNFcxGAlOEO9SLv(EXMIlk((ISapNLwlN1j6APnFO(tWG6El4alNFihzvIcOIO(gusegsusF4He1QOeLmPgVQEKOyPnKOkkrXkIeROe11OnWirTLO94ru()pb5grvlIY8HefJv4jq5jkELCcrHb3hrvCUeLIdhjQAruMpKOcU11quXSjQijbNnrPXWtGeLveL5djQGBDne1eGOJCm4wxZ74cmsJaYgaWA8Q6rDUnuE(jCbQTG6H2ZwwYXGBDnVJlWinciBaOrIvu9B0gyuE(jCbQTG6H2ZwwYrYXGBDnVdmRJeDQvRFJ9J0eCm9B94jFVylJDzUhPj4y636XZznh4E8ihdU118oWSos0PwT(nazdqQwSxnf15cmlFVyVKecnf5(cQhQTgeLZJVzY8uRIl9aYJ30u0dh5wfx6DGXHh88Pg8qtNQ15cm7sxIWAbEExM7rAcoM(TE8CwZbUhVZ7YCpstWX0V1JNJIlk((ISazYCWdnDQwNlWSlXhslWAWZYilTwoWA8Q6r9sIEItk58Q4spG84nnf9WrUvXLEhyCO)fCRRXbCleAEbcgZ2XJ30u0dhgJFoi5yWTUM3bM1rIo1Q1VbiBa4vr39egU1X)HKWihdU118oWSos0PwT(nazdqObLOBKQRLMtRup5yWTUM3bM1rIo1Q1VbiBaEdrH2Orc5iRsuave13GsIWqIs6dpKOwfLOKj14v1JeflTHevrjkwrKyfLOUgTbgjQTeThpIY))ji3iQAruMpKOyScpbkprXRKtikm4(iQIZLOuC4irvlIY8HevWTUgIkMnrfjj4SjkngEcKOSIOmFirfCRRHOMaeDKJb36AEhywhj6uRw)gGSbaSgVQEuNBdLVxSZsRLdSgVQEuVKON4Oiy0ZFEWdnDQwNlWSlXhslWAqYXGBDnVdmRJeDQvRFdq2aaCleAEbcgZw(EXEvCPhqE8MMIE4i3Q4sVdmo88PYsRLdSgVQEuVKON4El4alN)yYCvCPxUGBDnoWA8Q6rDUn0XR3oi5yWTUM3bM1rIo1Q1VbiBas1I9QPOoxGz57f7bp00PADUaZU3hnsguCEvCP3VmkRpVlZ9inbht)wpEokcg98(1pmgp(MCm4wxZ7aZ6irNA163aKnapstWX0V1JN89IDwATCP7eK(604uGoPeMmP4IIVVilWZNsgwiWXCG14v1J6CBOdNilWntMYWcboMlDNG0xNgNc0HtKf4MjZbp00PADUaZU0LiSwGNLXUm37Jgjdk05cm7SMdCpEmzgmcsBdDIWWX0jv)14WjYcCZKzWiiTn0LgNcSKE9kgV3HtKf4(GKJb36AEhywhj6uRw)gGSbaSgVQEuNBdLVxSZsRLdSgVQEuVKON4KsyYCvCP3VmkRzYCxM79rJKbf6CbMDwZbUhpYXGBDnVdmRJeDQvRFdq2a8inbht)wpEY3l2uCrX3xKfi5yWTUM3bM1rIo1Q1VbiBas1I9QPOoxGz57f7bp00PADUaZU0LiSwGN3L5EKMGJPFRhpN1CG7XJjZbp00PADUaZUeFiTaRbzYCWdnDQwNlWS79rJKbfNxfx69R)yn5i5yWTUM39g7qdkr3ivxlnNwPEYXGBDnV7nazdaVk6UNWWTo(pKeg5yWTUM39gGSbivl2RMI6CbMLVxSxscHMICFb1d1wdIY5X3NTqGJ5crIVqNqXDyf1HtKf4MCm4wxZ7Edq2a8inbht)wpEY3l2uCrX3xKf45S0A5aRXRQh1lj6jU3coWS93zle4yUqK4l0juChwrD4ezbUjhzvIcOIO(gusegsusF4He1QOeLmPgVQEKOyPnKOkkrXkIeROe11OnWirTLO94ru()pb5grvlIY8HefJv4jq5jkELCcrHb3hrvCUeLIdhjQAruMpKOcU11quXSjQijbNnrPXWtGeLveL5djQGBDne1eGOJCm4wxZ7Edq2aawJxvpQZTHY3l2zP1YbwJxvpQxs0tCVfCGz7VZwiWXCHiXxOtO4oSI6WjYcCtogCRR5DVbiBaOrIvu9B0gyu(EX2cboMl309RRLoHIN4WjYcCFolTwoEv0DpHHBD8FijmNuY5tLLwlhVk6UNWWTo(pKeMJIGrpVCE8ntMzP1YLfsuDT0wiQ5DsjNZsRLllKO6APTquZ7Oiy0ZlNhFFqYXGBDnV7nazdaynEv9Oo3gkFVyBHahZLB6(11sNqXtC4ezbUpNLwlhVk6UNWWTo(pKeMtk58PYsRLJxfD3ty4wh)hscZrrWONxop(MjZS0A5YcjQUwAle18oPKZzP1YLfsuDT0wiQ5Duem65LZJVpi5yWTUM39gGSba4wi08cemMT89I9Q4spG84nnf9WrUvXLEhyC45S0A5SorxlT5d1Fcgu3Bbhy58d5yWTUM39gGSbG7laMgGp5yWTUM39gGSb4nefAJgjKJb36AE3BaYgGuTyVAkQZfyw(EXEvCPhqE8MMIE4i3Q4sVdmo88PwscHMICFb1d1wdIY5X3mzUlZLQf7vtrDUaZokUO47lYc8CwATCG14v1J6Le9e3UsnhKCm4wxZ7Edq2a4lOjvnY3l2wiWXCgsbFDT044fEiioMdNilWntMbJG02qNuIMlQh1XS1ji9RjeoCISa3KJb36AE3BaYgGLigG7Xt)gTbgLVxSxfx6bKhVPPOhoYTkU07aJdjhdU118U3aKnapstWX0V1JN89IDwATCP7eK(604uGoPeMmP4IIVVilWZNsgwiWXCG14v1J6CBOdNilWntMYWcboMlDNG0xNgNc0HtKf4MjZGrqABOtegoMoP6VghorwGBMmdgbPTHU04uGL0RxX49oCISa3hKCm4wxZ7Edq2aawJxvpQZTHY3l2zP1YbwJxvpQxs0tCsjmzUkU07xgL1KJb36AE3BaYgaAKyfv)gTbgjhdU118U3aKnaPAXE1uuNlWS89I9UmxQwSxnf15cm7O4IIVVilqYXGBDnV7nazdWJ0eCm9B94jFVytXffFFrwGKJKJb36AExQvRFJDObLOBKQRLMtRup5yWTUM3LA163aKna8QO7Ecd364)qsyKJSkrburuFdkjcdjkPp8qIAvuIsMuJxvpsuS0gsufLOyfrIvuI6A0gyKO2s0E8ik))NGCJOQfrz(qIIXk8eO8efVsoHOWG7JOkoxIsXHJevTikZhsub36AiQy2evKKGZMO0y4jqIYkIY8HevWTUgIAcq0rogCRR5DPwT(nazdaynEv9Oo3gkFVyhmcsBdDPAXgPd(V(LOP70HWHtKf4(8GhA6uToxGzx6sewlWZ7YCpstWX0V1JNJIGrpVFpGtwgJhFFExM7rAcoM(TE8Cuem65LZpo)Xy847Z8Qe7k14s1I9QPOoxGzhfbJEE)EaN)ymE8n5yWTUM3LA163aKnaPAXE1uuNlWS89I9ssi0uK7lOEO2Aquop(MjZtTkU0dipEttrpCKBvCP3bghEWZNAWdnDQwNlWSlDjcRf45DzUhPj4y636XZznh4E8oVlZ9inbht)wpEokUO47lYcKjZbp00PADUaZUeFiTaRbplJS0A5aRXRQh1lj6joPKZRIl9aYJ30u0dh5wfx6DGXH(xWTUghWTqO5fiymBhpEttrpCym(5GKJb36AExQvRFdq2aaCleAEbcgZw(EXEvCPhqE8MMIE4i3Q4sVdmo8CwATCwNORL28H6pbdQ7TGdSC(58PKHfcCmxis8f6ekUdROoCISa3mzMLwlhynEv9OEjrpX9wWbwo)XK5Q4sVCb36ACG14v1J6CBOJxVDqYXGBDnVl1Q1VbiBaOrIvu9B0gyu(EXExMRhdPti0zbI7E8CVfCGLZpN3L5EF0izqHoxGzN1CG7X7SmSqGJ5aRXRQh152qhorwGBYXGBDnVl1Q1VbiBas1I9QPOoxGz57f7bp00PADUaZU3hnsguColTwoWA8Q6r9sIEIBxPMZNIxLyxPghWTqO5fiymBhfbJEE)6X3mzUkU07xgL1h8Sm2L5EKMGJPFRhphfxu89fzbsogCRR5DPwT(nazdWBik0gnsihdU118UuRw)gGSbyjIb4E80VrBGr57f7vXLEa5XBAk6HJCRIl9oW4qYXGBDnVl1Q1VbiBaEKMGJPFRhp57f7S0A5s3ji91PXPaDsjmzsXffFFrwGNpLmSqGJ5aRXRQh152qhorwGBMmLHfcCmx6obPVonofOdNilWntMdEOPt16CbMDPlryTaplJDzU3hnsguOZfy2znh4E8yYmyeK2g6eHHJPtQ(RXHtKf4MjZGrqABOlnofyj96vmEVdNilWntMzP1YbwJxvpQxs0tCVfCGz7VdsogCRR5DPwT(nazdGVGMu1iFVyBHahZzif811sJJx4HG4yoCISa3mzgmcsBdDsjAUOEuhZwNG0VMq4WjYcCtogCRR5DPwT(nazdaynEv9Oo3gkFVyNLwlhynEv9OEjrpXjLWK5Q4sVFzuwZK5Um37Jgjdk05cm7SMdCpEKJb36AExQvRFdq2aqJeRO63OnWi5yWTUM3LA163aKnapstWX0V1JN89Infxu89fzbsogCRR5DPwT(nazdqQwSxnf15cmlFVyp4HMovRZfy2LUeH1c88Um3J0eCm9B945SMdCpEmzo4HMovRZfy2L4dPfynitMdEOPt16CbMDVpAKmO48Q4sVF9hRH30i97AGmCawlRmZAgpR9JJ1mE)Da4nvqNE8E4LXE)pRGbgBmCAOmLOikG8HevdMuuJOwfLOoTBCfsc70suu80aPMIBI6lqKOcjRadd3ef3xmE47ihpn3dsuYktjkg7MxkjPOgUjQGBDne1PnKSshMfCGpToYrYrgBGjf1WnrX4iQGBDneLOF7DKJWROF7HabVPwT(niqqgKfce8gCRRbEdnOeDJuDT0CAL6HxCISa3qwGgKHdabcEdU11aV8QO7Ecd364)qsyWlorwGBilqdYGFGabV4ezbUHSaVCABiTd4nyeK2g6s1Insh8F9lrt3PdHdNilWnrDMOg8qtNQ15cm7sxIWAbsuNjQDzUhPj4y636XZrrWONNO8lrDaNSefJHO84BI6mrTlZ9inbht)wpEokcg98eLCeLFC(JOymeLhFtuNjkEvIDLACPAXE1uuNlWSJIGrppr5xI6ao)rumgIYJVH3GBDnWlynEv9Oo3gcnidNoei4fNilWnKf4LtBdPDaVljHqtrUVG6HARbrIsoIYJVjkMmjQtruRIl9efGefpEttrpCik5iQvXLEhyCirDqI6mrDkIAWdnDQwNlWSlDjcRfirDMO2L5EKMGJPFRhpN1CG7XJOotu7YCpstWX0V1JNJIlk((ISajkMmjQbp00PADUaZUeFiTaRbjQZeLmiQS0A5aRXRQh1lj6joPeI6mrTkU0tuasu84nnf9WHOKJOwfx6DGXHeL)rub36ACa3cHMxGGXSD84nnf9WHOymeLFiQdcVb36AG3uTyVAkQZfygAqg8hei4fNilWnKf4LtBdPDaVRIl9efGefpEttrpCik5iQvXLEhyCirDMOYsRLZ6eDT0Mpu)jyqDVfCGjk5ik)quNjQtruYGOSqGJ5crIVqNqXDyf1HtKf4MOyYKOYsRLdSgVQEuVKON4El4atuYru(JOyYKOwfx6jk5iQGBDnoWA8Q6rDUn0XR3iQdcVb36AGxGBHqZlqWy2qdYaJcbcEXjYcCdzbE502qAhW7UmxpgsNqOZce3945El4atuYru(HOotu7YCVpAKmOqNlWSZAoW94ruNjkzquwiWXCG14v1J6CBOdNilWn8gCRRbEPrIvu9B0gyeAqgyCqGGxCISa3qwGxoTnK2b8o4HMovRZfy29(OrYGcI6mrLLwlhynEv9OEjrpXTRudrDMOofrXRsSRuJd4wi08cemMTJIGrppr5xIYJVjkMmjQvXLEIYVefJYAI6Ge1zIsge1Um3J0eCm9B945O4IIVVilq4n4wxd8MQf7vtrDUaZqdYGmdbcEdU11aVVHOqB0ibEXjYcCdzbAqgy8qGGxCISa3qwGxoTnK2b8UkU0tuasu84nnf9WHOKJOwfx6DGXHWBWTUg4DjIb4E80VrBGrObzqwwdbcEXjYcCdzbE502qAhWBwATCP7eK(604uGoPeIIjtIIIlk((ISajQZe1PikzquwiWXCG14v1J6CBOdNilWnrXKjrjdIYcboMlDNG0xNgNc0HtKf4MOyYKOg8qtNQ15cm7sxIWAbsuNjkzqu7YCVpAKmOqNlWSZAoW94rumzsubJG02qNimCmDs1FnoCISa3eftMevWiiTn0LgNcSKE9kgV3HtKf4MOyYKOYsRLdSgVQEuVKON4El4atuSjk)ruheEdU11aVpstWX0V1Jh0GmiRSqGGxCISa3qwGxoTnK2b8AHahZzif811sJJx4HG4yoCISa3eftMevWiiTn0jLO5I6rDmBDcs)AcHdNilWn8gCRRbE9f0KQgObzq2dabcEXjYcCdzbE502qAhWBwATCG14v1J6Le9eNucrXKjrTkU0tu(LOyuwtumzsu7YCVpAKmOqNlWSZAoW94bVb36AGxWA8Q6rDUneAqgK1pqGG3GBDnWlnsSIQFJ2aJWlorwGBilqdYGSNoei4fNilWnKf4LtBdPDaVuCrX3xKfi8gCRRbEFKMGJPFRhpObzqw)bbcEXjYcCdzbE502qAhW7GhA6uToxGzx6sewlqI6mrTlZ9inbht)wpEoR5a3JhrXKjrn4HMovRZfy2L4dPfynirXKjrn4HMovRZfy29(OrYGcI6mrTkU0tu(LO8hRH3GBDnWBQwSxnf15cmdnObVBCfscdceKbzHabVb36AG3qYkDywWbgEXjYcCdzbAqgoaei4n4wxd8ckXimIaHxCISa3qwGgKb)abcEdU11aVspQBdbF4fNilWnKfObz40HabV4ezbUHSaVb36AGxEie6GBDnAr)g8k630taIWlF)qdYG)GabV4ezbUHSaVCABiTd4n4wNg14GGn(eLCe1biQZeLfcCmxQwSxnf19SK(UghorwGBI6mrDkIsgeLfcCmxis8f6ekUdROoCISa3eftMeLmikle4yoWA8Q6rDUn0HtKf4MOoi8gCRRbE5HqOdU11Of9BWROFtpbicVPwT(nObzGrHabV4ezbUHSaVCABiTd4n4wNg14GGn(eLCe1biQZeLfcCmxQwSxnf19SK(UghorwGBI6mrzHahZfIeFHoHI7WkQdNilWnrDMOSqGJ5aRXRQh152qhorwGB4n4wxd8YdHqhCRRrl63Gxr)MEcqeEbZ6irNA163GgKbghei4fNilWnKf4LtBdPDaVb360OgheSXNOKJOoarDMOKbrzHahZLQf7vtrDplPVRXHtKf4gEdU11aV8qi0b36A0I(n4v0VPNaeH33GgKbzgce8ItKf4gYc8YPTH0oG3GBDAuJdc24tu(LOKfEdU11aV8qi0b36A0I(n4v0VPNaeHxUaJ0i0GmW4HabVb36AG3GYJb1wrP4yWlorwGBilqdAWBcf5fyomiqqgKfce8ItKf4gYc0GmCaiqWlorwGBilqdYGFGabV4ezbUHSanidNoei4n4wxd8(sGG1OtqdEXjYcCdzbAqg8hei4fNilWnKfObzGrHabVb36AG3KY6AGxCISa3qwGgKbghei4n4wxd8(gIcTrJe4fNilWnKfObzqMHabVb36AGxFbnPQbEXjYcCdzbAqdE5cmsJqGGmilei4fNilWnKf4TsG3hn4n4wxd8MoODKfi8Moesi8gCRtJACqWgFIsoIYFe1zIk4wNg14GGn(eftMeL)G30bvpbicV8GMg18nfAqgoaei4n4wxd8gAqj6gP6AP50k1dV4ezbUHSanid(bce8gCRRbE5vr39egU1X)HKWGxCISa3qwGgKHthce8ItKf4gYc8YPTH0oG3DzU3hnsguOZfy2znh4E8G3GBDnWlpOPrObzWFqGGxCISa3qwGxoTnK2b8kdIYcboMZtcP0wicTfCR5VdNilWnrXKjrTKecnf5(cQhQTgejk5ikp(gEdU11aVPAXE1uuNlWm0GmWOqGGxCISa3qwG3GBDnWlynEv9Oo3gcVCABiTd4DJzP1YjcdhtNu9xJ7TGdmrXMOKL1Wl)eUa1wq9q7Hmil0GmW4GabVb36AGxUVayAa(WlorwGBilqdYGmdbcEXjYcCdzbEdU11aVa3cHMxGGXSHxoTnK2b8UkU0tuasu84nnf9WHOKJOwfx6DGXHWl)eUa1wq9q7Hmil0GmW4HabV4ezbUHSaVCABiTd4DjjeAkY9fupuBnisuYruE8nrXKjrjdIYcboMlvl2RMI6EwsFxJdNilWnrXKjrTlZ9(OrYGcDUaZoR5a3JhrDMO2L56Xq6ecDwG4Uhp3BbhyIsoIYpWBWTUg4nlzCFi9eObzqwwdbcEXjYcCdzbE502qAhWRfcCmNNesPTqeAl4wZFhorwGB4n4wxd8YdAAeAqgKvwiqWlorwGBilWlN2gs7aExfx6jkajkE8MMIE4quYruRIl9oW4q4n4wxd8UeXaCpE63OnWi0Gmi7bGabV4ezbUHSaVCABiTd4DxMlvl2RMI6CbMDuCrX3xKfirXKjrzHahZLQf7vtrDplPVRXHtKf4gEdU11aVPAXE1uuNlWm0GmiRFGabV4ezbUHSaVb36AG3hPj4y636XdE502qAhWBwATCP7eK(604uGoPe4LFcxGAlOEO9qgKfAqgK90HabV4ezbUHSaVCABiTd4LxLyxPgxQwSxnf15cm7Oiy0Ztu(LOsh0oYc0XdAAuZ3uI60irDa4n4wxd8YdAAeAqgK1FqGG3GBDnW7Bik0gnsGxCISa3qwGgKbzzuiqWlorwGBilWlN2gs7aETqGJ5mKc(6APXXl8qqCmhorwGB4n4wxd86lOjvnqdYGSmoiqWlorwGBilWBWTUg49rAcoM(TE8GxoTnK2b8sXffFFrwGe1zIklTwoRt01sB(q9NGb19wWbMOKJO8d8YpHlqTfup0EidYcnidYkZqGGxCISa3qwG3GBDnWlynEv9Oo3gcV8t4cuBb1dThYGSqdYGSmEiqWlorwGBilWBWTUg4Lgjwr1VrBGr4LFcxGAlOEO9qgKfAqdE57hceKbzHabV4ezbUHSaVCABiTd4LxLyxPghVk6UNWWTo(pKeMJIGrppr5xIYpSgEdU11aVzrvB9sIEc0GmCaiqWlorwGBilWlN2gs7aE5vj2vQXXRIU7jmCRJ)djH5Oiy0Ztu(LO8dRH3GBDnWBmC8nAi08qiGgKb)abcEXjYcCdzbE502qAhWlVkXUsnoEv0DpHHBD8FijmhfbJEEIYVeLFyn8gCRRbExnfZIQ2qdYWPdbcEdU11aVI2ZN96ttsBpqCm4fNilWnKfObzWFqGGxCISa3qwGxoTnK2b8YRsSRuJJxfD3ty4wh)hscZrrWONNO8lrXOSMOyYKOSge1wP3nsuYruYkl8gCRRbEZi9rkW94bnidmkei4fNilWnKf4LtBdPDaVzP1YXRIU7jmCRJ)djH5KsiQZe1PiQS0A5Yi9rkW945KsikMmjQS0A5YIQ26Le9eNucrXKjrjdIIgC0z0siiQZeLmikAWrxr5e1bjkMmjkRbrTv6DJeLCe1byu4n4wxd8Muwxd0GmW4GabV4ezbUHSaVCABiTd41cQhAUD)wmCKO8lBIIrH3GBDnWB8ji301sB(qngEceAqdEbZ6irNA163GabzqwiqWlorwGBilWlN2gs7aELbrTlZ9inbht)wpEoR5a3Jh8gCRRbEFKMGJPFRhpObz4aqGGxCISa3qwGxoTnK2b8UKecnf5(cQhQTgejk5ikp(MOyYKOofrTkU0tuasu84nnf9WHOKJOwfx6DGXHe1bjQZe1PiQbp00PADUaZU0LiSwGe1zIAxM7rAcoM(TE8CwZbUhpI6mrTlZ9inbht)wpEokUO47lYcKOyYKOg8qtNQ15cm7s8H0cSgKOotuYGOYsRLdSgVQEuVKON4KsiQZe1Q4sprbirXJ30u0dhIsoIAvCP3bghsu(hrfCRRXbCleAEbcgZ2XJ30u0dhIIXqu(HOoi8gCRRbEt1I9QPOoxGzObzWpqGG3GBDnWlVk6UNWWTo(pKeg8ItKf4gYc0GmC6qGG3GBDnWBObLOBKQRLMtRup8ItKf4gYc0Gm4piqWBWTUg49nefAJgjWlorwGBilqdYaJcbcEXjYcCdzbE502qAhWBwATCG14v1J6Le9ehfbJEEI6mrn4HMovRZfy2L4dPfyni8gCRRbEbRXRQh152qObzGXbbcEXjYcCdzbE502qAhW7Q4sprbirXJ30u0dhIsoIAvCP3bghsuNjQtruzP1YbwJxvpQxs0tCVfCGjk5ik)rumzsuRIl9eLCevWTUghynEv9Oo3g641Be1bH3GBDnWlWTqO5fiymBObzqMHabV4ezbUHSaVCABiTd4DWdnDQwNlWS79rJKbfe1zIAvCPNO8lrXOSMOotu7YCpstWX0V1JNJIGrppr5xIYpefJHO84B4n4wxd8MQf7vtrDUaZqdYaJhce8ItKf4gYc8YPTH0oG3S0A5s3ji91PXPaDsjeftMeffxu89fzbsuNjQtruYGOSqGJ5aRXRQh152qhorwGBIIjtIsgeLfcCmx6obPVonofOdNilWnrXKjrn4HMovRZfy2LUeH1cKOotuYGO2L5EF0izqHoxGzN1CG7XJOyYKOcgbPTHory4y6KQ)AC4ezbUjkMmjQGrqABOlnofyj96vmEVdNilWnrDq4n4wxd8(inbht)wpEqdYGSSgce8ItKf4gYc8YPTH0oG3S0A5aRXRQh1lj6joPeIIjtIAvCPNO8lrXOSMOyYKO2L5EF0izqHoxGzN1CG7XdEdU11aVG14v1J6CBi0GmiRSqGGxCISa3qwGxoTnK2b8sXffFFrwGWBWTUg49rAcoM(TE8GgKbzpaei4fNilWnKf4LtBdPDaVdEOPt16CbMDPlryTajQZe1Um3J0eCm9B945SMdCpEeftMe1GhA6uToxGzxIpKwG1GeftMe1GhA6uToxGz37JgjdkiQZe1Q4spr5xIYFSgEdU11aVPAXE1uuNlWm0Gg8(geiidYcbcEdU11aVHguIUrQUwAoTs9WlorwGBilqdYWbGabVb36AGxEv0DpHHBD8Fijm4fNilWnKfObzWpqGGxCISa3qwGxoTnK2b8UKecnf5(cQhQTgejk5ikp(MOotuwiWXCHiXxOtO4oSI6WjYcCdVb36AG3uTyVAkQZfygAqgoDiqWlorwGBilWlN2gs7aEP4IIVVilqI6mrLLwlhynEv9OEjrpX9wWbMOytu(JOotuwiWXCHiXxOtO4oSI6WjYcCdVb36AG3hPj4y636XdAqg8hei4fNilWnKf4LtBdPDaVzP1YbwJxvpQxs0tCVfCGjk2eL)iQZeLfcCmxis8f6ekUdROoCISa3WBWTUg4fSgVQEuNBdHgKbgfce8ItKf4gYc8YPTH0oGxle4yUCt3VUw6ekEIdNilWnrDMOYsRLJxfD3ty4wh)hscZjLquNjQtruzP1YXRIU7jmCRJ)djH5Oiy0ZtuYruE8nrXKjrLLwlxwir11sBHOM3jLquNjQS0A5YcjQUwAle18okcg98eLCeLhFtuheEdU11aV0iXkQ(nAdmcnidmoiqWlorwGBilWlN2gs7aETqGJ5YnD)6APtO4joCISa3e1zIklTwoEv0DpHHBD8FijmNucrDMOofrLLwlhVk6UNWWTo(pKeMJIGrpprjhr5X3eftMevwATCzHevxlTfIAENucrDMOYsRLllKO6APTquZ7Oiy0ZtuYruE8nrDq4n4wxd8cwJxvpQZTHqdYGmdbcEXjYcCdzbE502qAhW7Q4sprbirXJ30u0dhIsoIAvCP3bghsuNjQS0A5SorxlT5d1Fcgu3BbhyIsoIYpWBWTUg4f4wi08cemMn0GmW4HabVb36AGxUVayAa(WlorwGBilqdYGSSgce8gCRRbEFdrH2Orc8ItKf4gYc0GmiRSqGGxCISa3qwGxoTnK2b8UkU0tuasu84nnf9WHOKJOwfx6DGXHe1zI6ue1ssi0uK7lOEO2AqKOKJO84BIIjtIAxMlvl2RMI6CbMDuCrX3xKfirDMOYsRLdSgVQEuVKON42vQHOoi8gCRRbEt1I9QPOoxGzObzq2dabcEXjYcCdzbE502qAhWRfcCmNHuWxxlnoEHhcIJ5WjYcCtumzsubJG02qNuIMlQh1XS1ji9RjeoCISa3WBWTUg41xqtQAGgKbz9dei4fNilWnKf4LtBdPDaVRIl9efGefpEttrpCik5iQvXLEhyCi8gCRRbExIyaUhp9B0gyeAqgK90HabV4ezbUHSaVCABiTd4nlTwU0DcsFDACkqNucrXKjrrXffFFrwGe1zI6ueLmikle4yoWA8Q6rDUn0HtKf4MOyYKOKbrzHahZLUtq6RtJtb6WjYcCtumzsubJG02qNimCmDs1FnoCISa3eftMevWiiTn0LgNcSKE9kgV3HtKf4MOoi8gCRRbEFKMGJPFRhpObzqw)bbcEXjYcCdzbE502qAhWBwATCG14v1J6Le9eNucrXKjrTkU0tu(LOyuwdVb36AGxWA8Q6rDUneAqgKLrHabVb36AGxAKyfv)gTbgHxCISa3qwGgKbzzCqGGxCISa3qwGxoTnK2b8UlZLQf7vtrDUaZokUO47lYceEdU11aVPAXE1uuNlWm0GmiRmdbcEXjYcCdzbE502qAhWlfxu89fzbcVb36AG3hPj4y636XdAqdAWBiz(kk8EBqjryDnSs0yzqdAqi]] )

end