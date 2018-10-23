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


    spec:RegisterPack( "Survival", 20181022.2047, [[dyKQjbqiIipcfPUKicYMuH(KicQrjIYPerAvQOWRaOzru1Ter0UOYVaWWiI6yQalJOINruPPrKsxtevBtfL(gksmovuX5urLADQOOMhrY9ik7JivhuffzHeHhIIK6IOijJueboPkQewPkYnjsr7ef1pvrLOHkIqlLifEQknva1Eb9xsgmHdlSyr9yunzL6YiBwjFMQmArYPLA1QOs61aYSj1TbA3k(TKHtvTCOEUQMoLRJsBxK67IW4vbDEueRxfvnFuy)qgEaey4Dhgbzwos(GZ5ajlh54KJKLwMIKpl8AmXNGx)Gdu4rW7eGe8EzXP70HgE9dMORydbgE)IfZj4nLz()zgaa8AlfB2Xlqa(gKvhwxdhhldGVb5aK1vgG8ksYnLgaFCTAn9aKeXK0i69dqsuAOscyhJWQlloDNo0UVb5WBMT125IbMH3DyeKz5i5doNdKSCKJtoswAzkswoW77tCiZYj5jhEt17nnWm8UPNdVmnsCzXP70HgjscyhJWOtmnsKYm))mdaaETLIn74fiaFdYQdRRHJJLbW3GCaY6kdqEfj5MsdGpUwTMEasIysAe9(bijknujbSJry1LfNUthA33GC0jMgjoxYTktyKqoYrEKqos(GZbjssK4CoZs7zrIKO0eDcDIPrcM6uX4r)zgDIPrIKejot7nTrcPj75pVMqcRqInTcwTHeb36AqcD)MdDIPrIKejyQtfJhTrclWEKP6fsqh6JP)7AEKWkKGZeUMuwG9i7DOtmnsKKiH0S29QPnsWdCAsX3yKWkKirHbcjalmHeu8TMjirI2sHewkcjI9UMKWps0G(AcKglSUgKOwir6a3rwto41hxRwtWltJexwC6oDOrIKa2Xim6etJePmZ)pZaaGxBPyZoEbcW3GS6W6A44yza8nihGSUYaKxrsUP0a4JRvRPhGKiMKgrVFasIsdvsa7yewDzXP70H29nihDIPrIZLCRYegjKJCKhjKJKp4CqIKejoNZS0EwKijknrNqNyAKGPovmE0FMrNyAKijrIZ0EtBKqAYE(ZRjKWkKytRGvBirWTUgKq3V5qNyAKijrcM6uX4rBKWcShzQEHe0H(y6)UMhjScj4mHRjLfypYEh6etJejjsinRDVAAJe8aNMu8ngjScjsuyGqcWctibfFRzcsKOTuiHLIqIyVRjj8JenOVMaPXcRRbjQfsKoWDK1KdDcDIPrcMQdjoRrBKitRctibVaZHHezYRN3HeNjoN8ThjMAsYubgCXQrIGBDnpsuJMjo0PGBDnVZht8cmhMSLoEGqNcU118oFmXlWCyakdGG1dKglSUg0PGBDnVZht8cmhgGYayv1gDk4wxZ78XeVaZHbOmaEwqWAu(KHoX0iXDc)pvzibo6nsKzxlAJeVf2JezAvycj4fyomKitE98irmBKWhtjPFzwpEir)iXUgYHofCRR5D(yIxG5Wauga)e(FQYuVf2JofCRR5D(yIxG5Wauga(L11GofCRR5D(yIxG5WaugaVrKwz4WhDk4wxZ78XeVaZHbOmasfy)Qg0j0jMgjyQoK4SgTrcknHzcsyniHewkcjcUvyKOFKishToYAYHofCRR5LbYE(ZRj0PGBDnpGYaG9jvBe4JofCRR5buga8qRvb36Au6(n5NaKKX3p6uWTUMhqzaWdTwfCRRrP73KFcqsgywf(QeRw9M89swWTonPOHaB6LsUhTqtJ5s069QXKQNf7314OjYAAF0cnnMl0(PcLpM2Hvyhnrwt7JwOPXCG14v1tQCBKJMiRPn6uWTUMhqzaWdTwfCRRrP73KFcqswIvREt(Ejl4wNMu0qGn9sj3JwOPXCjA9E1ys1ZI97AC0eznTrNcU118akdaEO1QGBDnkD)M8tasYEt(Ejl4wNMu0qGn9sjh0PGBDnpGYaGhATk4wxJs3Vj)eGKmUMI0K89swWTonPOHaB6L(bOtb36AEaLbqG5XqkRWyAm0j0PGBDnVJVFzzDvB1IfZe57LmEv6DLyC8QW7EcJ2Q4)GvBombg98sxUsgDk4wxZ747hqzaedNEdhAfp0A57LmEv6DLyC8QW7EcJ2Q4)GvBombg98sxUsgDk4wxZ747hqzaSAmL1vTLVxY4vP3vIXXRcV7jmARI)dwT5Wey0ZlD5kz0PGBDnVJVFaLbGU9szV6CLD7bsJHofCRR5D89dOmaYe(jmq94jFVKXRsVReJJxfE3ty0wf)hSAZHjWONx6NvYmyyniPSsTBsQdoaDk4wxZ747hqza4xwxJ89swMDTC8QW7EcJ2Q4)GvBow)JjlZUwUmHFcdupEowFgmYSRLlRRARwSyM4y9zWqs4GtodxA9rjHdo5kmpPmyyniPSsTBsk5Cw0PGBDnVJVFaLbq8(e3u1szPiffEAs(EjZcShzUD)wmCs6Yol6e6uWTUM3X1uKMKLoWDK1K8tasY4bonP4BS8LVSNm5thAwswWTonPOHaB6LEYpMCgmcU1Pjfneytp6uWTUM3X1uKMaugaHcKfVjSQwkoUs8Otb36AEhxtrAcqzaWRcV7jmARI)dwTHofCRR5DCnfPjaLbapWPj57LSDzUpfo8hsRYfy2znhOE8qNcU118oUMI0eGYairR3RgtQCbMLVxYKKfAAmNhlHXTwhkl4wZFhnrwtBgmwSATct8ub2Juwdss5X3Otb36AEhxtrAcqzaawJxvpPYTrY3lzBkZUwoDy0yk)Q)ACVfCGKDGKrNcU118oUMI0eGYaGNkachGp6uWTUM3X1uKMaugaa1ATIxGGXSLNZeUMuwG9i7LDG89s2Q4SpG84nfM8OrQvXzFhyCi6uWTUM3X1uKMaugazwJNIWmr(EjBXQ1kmXtfypsznijLhFZGHKSqtJ5s069QXKQNf7314OjYAAZGXUm3Nch(dPv5cm7SMdupEh3L56Xi8eAvwt0Uhp3BbhiPKl6uWTUM3X1uKMauga8aNMKVxYSqtJ58yjmU16qzb3A(7OjYAAJofCRR5DCnfPjaLbWshdq94PEd3arY3lzRIZ(aYJ3uyYJgPwfN9DGXHOtb36AEhxtrAcqzaKO17vJjvUaZY3lz7YCjA9E1ysLlWSdtlm9PISMyWWcnnMlrR3RgtQEwSFxJJMiRPn6uWTUM3X1uKMaugapH9PXuV1JN8CMW1KYcShzVSdKVxYYSRLlD7t4xLMMc0X6JofCRR5DCnfPjaLbapWPj57LmEv6DLyCjA9E1ysLlWSdtGrpV0th4oYAYXdCAsX34KqYbDk4wxZ74AkstakdG3isRmC4JofCRR5DCnfPjaLbqQa7x1iFVKzHMgZzeg8v1srJx4rG0yoAISM2Otb36AEhxtrAcqza8e2Ngt9wpEYZzcxtklWEK9Yoq(Ejdtlm9PISMoMzxlN1(QAPSuK69Pa7El4ajLCrNyAKa4cj(gKvhgHeSF4riXQWiH0SgVQEcjKOncjkmsincFRWiX1WnqesSzX94HeNP3N4gsulKWsribtv4Pj5rcE5ZeKGcEkKO4CwmMgoHe1cjSueseCRRbjIzJeHVpnBKqrHNMqcRqclfHeb36AqIjajh6uWTUM3X1uKMaugaG14v1tQCBK89s2MYSRLthgnMYV6VghRp6uWTUM3X1uKMauga4W3kS6nCdejFVKTPm7A50HrJP8R(RXX6JoHofCRR5DGzv4RsSA1BYEc7tJPERhp57LmjTlZ9e2Ngt9wpEoR5a1Jh6uWTUM3bMvHVkXQvVbOmas069QXKkxGz57LSfRwRWepvG9iL1GKuE8ndgjBvC2hqE8MctE0i1Q4SVdmomPht2qhAQeTkxGzx6shwRPJ7YCpH9PXuV1JNZAoq94DCxM7jSpnM6TE8CyAHPpvK1edgdDOPs0QCbMD(PiCbwdDusz21YbwJxvpPwSyM4y9pUko7dipEtHjpAKAvC23bghMKb36ACa1ATIxGGXSD84nfM8O5mKBsrNcU118oWSk8vjwT6naLbaVk8UNWOTk(py1g6uWTUM3bMvHVkXQvVbOmacfilEtyvTuCCL4rNcU118oWSk8vjwT6naLbWBePvgo8rNyAKa4cj(gKvhgHeSF4riXQWiH0SgVQEcjKOncjkmsincFRWiX1WnqesSzX94HeNP3N4gsulKWsribtv4Pj5rcE5ZeKGcEkKO4CwmMgoHe1cjSueseCRRbjIzJeHVpnBKqrHNMqcRqclfHeb36AqIjajh6uWTUM3bMvHVkXQvVbOmaaRXRQNu52i57LSm7A5aRXRQNulwmtCycm65po0HMkrRYfy25NIWfyne6uWTUM3bMvHVkXQvVbOmaaQ1AfVabJzlFVKTko7dipEtHjpAKAvC23bghEmzz21YbwJxvpPwSyM4El4ajvYzWyvC2xQGBDnoWA8Q6jvUnYXR3sk6uWTUM3bMvHVkXQvVbOmas069QXKkxGz57LSHo0ujAvUaZUpfo8hsFCvC2x6NvYh3L5Ec7tJPERhphMaJEEPl3ZWJVrNcU118oWSk8vjwT6naLbWtyFAm1B94jFVKLzxlx62NWVknnfOJ1NbdmTW0NkYA6yYKKfAAmhynEv9Kk3g5OjYAAZGHKSqtJ5s3(e(vPPPaD0eznTzWyOdnvIwLlWSlDPdR10rjTlZ9PWH)qAvUaZoR5a1JhdgX5jCBKthgnMYV6VghnrwtBgmIZt42ixAAkWI9vRy8Ehnrwt7KIofCRR5DGzv4RsSA1BakdaWA8Q6jvUns(EjlZUwoWA8Q6j1IfZehRpdgRIZ(s)SsMbJDzUpfo8hsRYfy2znhOE8qNcU118oWSk8vjwT6naLbWtyFAm1B94jFVKHPfM(urwtOtb36AEhywf(QeRw9gGYairR3RgtQCbMLVxYg6qtLOv5cm7sx6WAnDCxM7jSpnM6TE8CwZbQhpgmg6qtLOv5cm78tr4cSgIbJHo0ujAvUaZUpfo8hsFCvC2x6jxYOtOtb36AE3BYcfilEtyvTuCCL4rNyAKa4cj(gKvhgHeSF4riXQWiH0SgVQEcjKOncjkmsincFRWiX1WnqesSzX94HeNP3N4gsulKWsribtv4Pj5rcE5ZeKGcEkKO4CwmMgoHe1cjSueseCRRbjIzJeHVpnBKqrHNMqcRqclfHeb36AqIjajh6uWTUM39gGYaaSgVQEsLBJKVxYSqtJ5YnE)QAP8XetC0eznTpMzxlhVk8UNWOTk(py1MJ1)yYYSRLJxfE3ty0wf)hSAZHjWONxkp(MbJm7A5YAwSQwkl018ow)Jz21YL1SyvTuwOR5Dycm65LYJVtk6uWTUM39gGYaah(wHvVHBGi57Lml00yUCJ3VQwkFmXehnrwt7Jz21YXRcV7jmARI)dwT5y9pMSm7A54vH39egTvX)bR2Cycm65LYJVzWiZUwUSMfRQLYcDnVJ1)yMDTCznlwvlLf6AEhMaJEEP847KIofCRR5DVbOmaEc7tJPERhp57LSm7A5s3(e(vPPPaDS(hZSRLlD7t4xLMMc0HjWONxkp(gDk4wxZ7EdqzaauR1kEbcgZw(EjBvC2hqE8MctE0i1Q4SVdmo8yYKKfAAmxO9tfkFmTdRWoAISM2mySy1AfM4PcShPSgKKYJVtk6uWTUM39gGYairR3RgtQCbMLVxYwfN9bKhVPWKhnsTko77aJdpMSfRwRWepvG9iL1GKuE8ndgsAxMlrR3RgtQCbMDwZbQhVJjlZUwoWA8Q6j1IfZe3UsmmySy1AfM4PcShPSgKKsADj)m847KMu0PGBDnV7naLbWtyFAm1B94jFVKLzxlx62NWVknnfOJ1)4Um3tyFAm1B945Wey0ZlL0EgE8ndgsYcnnMlD7t4xLMMc0rtK10(OK2L5Ec7tJPERhpN1CG6X7OKYSRLJxfE3ty0wf)hSAZX6ZGbMwy6tfznDmzX5jCBKthgnMYV6VghnrwtBgmIZt42ixAAkWI9vRy8Ehnrwt7KIofCRR5DVbOmaEJiTYWHp6uWTUM39gGYaivG9RAKVxYSqtJ5mcd(QAPOXl8iqAmhnrwtBgmIZt42ihRVIRRNuXSv(e(Rj0oAISM2Otb36AE3BakdaEv4DpHrBv8FWQn0PGBDnV7naLbapvaeoaF0PGBDnV7naLbWshdq94PEd3arY3lzRIZ(aYJ3uyYJgPwfN9DGXHOtb36AE3BakdaGATwXlqWy2Y3lzRIZ(aYJ3uyYJgPwfN9DGXHhtwMDTCG14v1tQflMjU3coqsjTmySko7lvWTUghynEv9Kk3g541BjfDk4wxZ7EdqzaawJxvpPYTrY3lzz21YbwJxvpPwSyM4y9zWyvC2x6NvYOtb36AE3BakdaC4Bfw9gUbIqNcU118U3augapH9PXuV1JN89s2Um3tyFAm1B945W0ctFQiRPJskZUwoEv4DpHrBv8FWQnhRp6uWTUM39gGYairR3RgtQCbMLVxY2L5s069QXKkxGzhMwy6tfznHoHofCRR5DjwT6nzHcKfVjSQwkoUs8Otb36AExIvREdqzaWRcV7jmARI)dwTHoX0ibWfs8niRomcjy)WJqIvHrcPznEv9esirBesuyKqAe(wHrIRHBGiKyZI7XdjotVpXnKOwiHLIqcMQWttYJe8YNjibf8uirX5SymnCcjQfsyPiKi4wxdseZgjcFFA2iHIcpnHewHewkcjcU11Getaso0PGBDnVlXQvVbOmaaRXRQNu52i57LS48eUnYLO1Bcp0)QNfNUthAhnrwt7JdDOPs0QCbMDPlDyTMoUlZ9e2Ngt9wpEombg98sxoUdodp((4Um3tyFAm1B945Wey0ZlLCDj)m847J8Q07kX4s069QXKkxGzhMaJEEPlhxYpdp(gDk4wxZ7sSA1BakdGeTEVAmPYfyw(EjBXQ1kmXtfypsznijLhFZGrYwfN9bKhVPWKhnsTko77aJdt6XKn0HMkrRYfy2LU0H1A64Um3tyFAm1B945SMdupEh3L5Ec7tJPERhphMwy6tfznXGXqhAQeTkxGzNFkcxG1qhLuMDTCG14v1tQflMjow)JRIZ(aYJ3uyYJgPwfN9DGXHjzWTUghqTwR4fiymBhpEtHjpAod5Mu0PGBDnVlXQvVbOmaaQ1AfVabJzlFVKTko7dipEtHjpAKAvC23bghEmZUwoR9v1szPi17tb29wWbsk5EmzsYcnnMl0(PcLpM2HvyhnrwtBgmYSRLdSgVQEsTyXmX9wWbsQKZGXQ4SVub36ACG14v1tQCBKJxVLu0PGBDnVlXQvVbOmaWHVvy1B4gis(EjBxMRhJWtOvznr7E8CVfCGKsUh3L5(u4WFiTkxGzN1CG6X7OKSqtJ5aRXRQNu52ihnrwtB0PGBDnVlXQvVbOmas069QXKkxGz57LSHo0ujAvUaZUpfo8hsFmZUwoWA8Q6j1IfZe3UsmhtgVk9UsmoGATwXlqWy2ombg98s3JVzWyvC2x6NvYj9OK2L5Ec7tJPERhphMwy6tfznHofCRR5DjwT6naLbWBePvgo8rNcU118UeRw9gGYayPJbOE8uVHBGi57LSvXzFa5XBkm5rJuRIZ(oW4q0PGBDnVlXQvVbOmaEc7tJPERhp57LSm7A5s3(e(vPPPaDS(myGPfM(urwthtMKSqtJ5aRXRQNu52ihnrwtBgmKKfAAmx62NWVknnfOJMiRPndgdDOPs0QCbMDPlDyTMokPDzUpfo8hsRYfy2znhOE8yWiopHBJC6WOXu(v)14OjYAAZGrCEc3g5sttbwSVAfJ37OjYAAZGrMDTCG14v1tQflMjU3coqYsEsrNcU118UeRw9gGYaivG9RAKVxYSqtJ5mcd(QAPOXl8iqAmhnrwtBgmIZt42ihRVIRRNuXSv(e(Rj0oAISM2Otb36AExIvREdqzaawJxvpPYTrY3lzz21YbwJxvpPwSyM4y9zWyvC2x6NvYmySlZ9PWH)qAvUaZoR5a1Jh6uWTUM3Ly1Q3auga4W3kS6nCdeHofCRR5DjwT6naLbWtyFAm1B94jFVKHPfM(urwtOtb36AExIvREdqzaKO17vJjvUaZY3lzdDOPs0QCbMDPlDyTMoUlZ9e2Ngt9wpEoR5a1JhdgdDOPs0QCbMD(PiCbwdXGXqhAQeTkxGz3Nch(dPpUko7l9Klz4nnH)UgiZYrYhCos(Clxj7oqUhCa8MiWtpEp8EUa0VWgTrcMcseCRRbj09BVdDcEdwlvHH3BdYQdRRHPghldE19Bpey4nXQvVbbgY8bqGH3GBDnWBOazXBcRQLIJRep8stK10gkb0GmlhiWWBWTUg4LxfE3ty0wf)hSAdEPjYAAdLaAqMLley4LMiRPnuc4LJBJWDaVX5jCBKlrR3eEO)vploDNo0oAISM2iXrKyOdnvIwLlWSlDPdR1esCej2L5Ec7tJPERhphMaJEEKq6iHCChGeNbs4X3iXrKyxM7jSpnM6TE8Cycm65rcPqc56sosCgiHhFJehrcEv6DLyCjA9E1ysLlWSdtGrppsiDKqoUKJeNbs4X3WBWTUg4fSgVQEsLBJGgKzPfcm8stK10gkb8YXTr4oG3fRwRWepvG9iL1Gesifs4X3ibdgirYqIvXzFKaqKGhVPWKhniHuiXQ4SVdmoejsksCejsgsm0HMkrRYfy2LU0H1AcjoIe7YCpH9PXuV1JNZAoq94HehrIDzUNW(0yQ36XZHPfM(urwtibdgiXqhAQeTkxGzNFkcxG1qiXrKqsirMDTCG14v1tQflMjowFK4isSko7JeaIe84nfM8ObjKcjwfN9DGXHirsIeb36ACa1ATIxGGXSD84nfM8ObjodKqUirsH3GBDnWBIwVxnMu5cmdniZjhcm8stK10gkb8YXTr4oG3vXzFKaqKGhVPWKhniHuiXQ4SVdmoejoIez21YzTVQwklfPEFkWU3coqiHuiHCrIJirYqcjHewOPXCH2pvO8X0oSc7OjYAAJemyGez21YbwJxvpPwSyM4El4aHesHejhjyWajwfN9rcPqIGBDnoWA8Q6jvUnYXR3qIKcVb36AGxGATwXlqWy2qdY8zHadV0eznTHsaVCCBeUd4DxMRhJWtOvznr7E8CVfCGqcPqc5IehrIDzUpfo8hsRYfy2znhOE8qIJiHKqcl00yoWA8Q6jvUnYrtK10gEdU11aV4W3kS6nCdebniZmfiWWlnrwtBOeWlh3gH7aEh6qtLOv5cm7(u4WFinsCejYSRLdSgVQEsTyXmXTRedsCejsgsWRsVReJdOwRv8cemMTdtGrppsiDKWJVrcgmqIvXzFKq6iXzLmsKuK4isijKyxM7jSpnM6TE8CyAHPpvK1e8gCRRbEt069QXKkxGzObz(CGadVb36AG33isRmC4dV0eznTHsaniZNBiWWlnrwtBOeWlh3gH7aExfN9rcarcE8MctE0GesHeRIZ(oW4q4n4wxd8U0XaupEQ3Wnqe0GmFGKHadV0eznTHsaVCCBeUd4nZUwU0TpHFvAAkqhRpsWGbsGPfM(urwtiXrKiziHKqcl00yoWA8Q6jvUnYrtK10gjyWajKesyHMgZLU9j8Rsttb6OjYAAJemyGedDOPs0QCbMDPlDyTMqIJiHKqIDzUpfo8hsRYfy2znhOE8qcgmqI48eUnYPdJgt5x9xJJMiRPnsWGbseNNWTrU00uGf7RwX49oAISM2ibdgirMDTCG14v1tQflMjU3coqiHmKi5irsH3GBDnW7tyFAm1B94bniZhCaey4LMiRPnuc4LJBJWDaVwOPXCgHbFvTu04fEeinMJMiRPnsWGbseNNWTrowFfxxpPIzR8j8xtOD0eznTH3GBDnWBQa7x1aniZhihiWWlnrwtBOeWlh3gH7aEZSRLdSgVQEsTyXmXX6JemyGeRIZ(iH0rIZkzKGbdKyxM7tHd)H0QCbMDwZbQhp4n4wxd8cwJxvpPYTrqdY8bYfcm8gCRRbEXHVvy1B4gicEPjYAAdLaAqMpqAHadV0eznTHsaVCCBeUd4ftlm9PISMG3GBDnW7tyFAm1B94bniZhKCiWWlnrwtBOeWlh3gH7aEh6qtLOv5cm7sx6WAnHehrIDzUNW(0yQ36XZznhOE8qcgmqIHo0ujAvUaZo)ueUaRHqcgmqIHo0ujAvUaZUpfo8hsJehrIvXzFKq6irYLm8gCRRbEt069QXKkxGzObn4DtRGvBqGHmFaey4n4wxd8cYE(ZRj4LMiRPnucObzwoqGH3GBDnWl7tQ2iWhEPjYAAdLaAqMLley4LMiRPnuc4n4wxd8YdTwfCRRrP73GxD)MAcqcE57hAqMLwiWWlnrwtBOeWlh3gH7aEdU1PjfneytpsifsixK4isyHMgZLO17vJjvpl2VRXrtK10gjoIewOPXCH2pvO8X0oSc7OjYAAJehrcl00yoWA8Q6jvUnYrtK10gEdU11aV8qRvb36Au6(n4v3VPMaKGxWSk8vjwT6nObzo5qGHxAISM2qjGxoUnc3b8gCRttkAiWMEKqkKqUiXrKWcnnMlrR3RgtQEwSFxJJMiRPn8gCRRbE5HwRcU11O09BWRUFtnbibVjwT6nObz(SqGHxAISM2qjGxoUnc3b8gCRttkAiWMEKqkKqoWBWTUg4LhATk4wxJs3VbV6(n1eGe8(g0GmZuGadV0eznTHsaVCCBeUd4n4wNMu0qGn9iH0rIdG3GBDnWlp0AvWTUgLUFdE19BQjaj4LRPinbniZNdey4n4wxd8gyEmKYkmMgdEPjYAAdLaAqdE9XeVaZHbbgY8bqGHxAISM2qjGgKz5abgEPjYAAdLaAqMLley4LMiRPnucObzwAHadVb36AG3NfeSgLpzWlnrwtBOeqdYCYHadV0eznTHsaniZNfcm8gCRRbE9lRRbEPjYAAdLaAqMzkqGH3GBDnW7BePvgo8HxAISM2qjGgK5Zbcm8gCRRbEtfy)Qg4LMiRPnucObn4fmRcFvIvREdcmK5dGadV0eznTHsaVCCBeUd4vsiXUm3tyFAm1B945SMdupEWBWTUg49jSpnM6TE8GgKz5abgEPjYAAdLaE542iChW7IvRvyINkWEKYAqcjKcj84BKGbdKiziXQ4SpsaisWJ3uyYJgKqkKyvC23bghIejfjoIejdjg6qtLOv5cm7sx6WAnHehrIDzUNW(0yQ36XZznhOE8qIJiXUm3tyFAm1B945W0ctFQiRjKGbdKyOdnvIwLlWSZpfHlWAiK4isijKiZUwoWA8Q6j1IfZehRpsCejwfN9rcarcE8MctE0GesHeRIZ(oW4qKijrIGBDnoGATwXlqWy2oE8MctE0GeNbsixKiPWBWTUg4nrR3RgtQCbMHgKz5cbgEdU11aV8QW7EcJ2Q4)GvBWlnrwtBOeqdYS0cbgEdU11aVHcKfVjSQwkoUs8WlnrwtBOeqdYCYHadVb36AG33isRmC4dV0eznTHsaniZNfcm8stK10gkb8YXTr4oG3m7A5aRXRQNulwmtCycm65rIJiXqhAQeTkxGzNFkcxG1qWBWTUg4fSgVQEsLBJGgKzMcey4LMiRPnuc4LJBJWDaVRIZ(ibGibpEtHjpAqcPqIvXzFhyCisCejsgsKzxlhynEv9KAXIzI7TGdesifsKCKGbdKyvC2hjKcjcU114aRXRQNu52ihVEdjsk8gCRRbEbQ1AfVabJzdniZNdey4LMiRPnuc4LJBJWDaVdDOPs0QCbMDFkC4pKgjoIeRIZ(iH0rIZkzK4isSlZ9e2Ngt9wpEombg98iH0rc5IeNbs4X3WBWTUg4nrR3RgtQCbMHgK5Zney4LMiRPnuc4LJBJWDaVz21YLU9j8Rsttb6y9rcgmqcmTW0NkYAcjoIejdjKesyHMgZbwJxvpPYTroAISM2ibdgiHKqcl00yU0TpHFvAAkqhnrwtBKGbdKyOdnvIwLlWSlDPdR1esCejKesSlZ9PWH)qAvUaZoR5a1JhsWGbseNNWTroDy0yk)Q)AC0eznTrcgmqI48eUnYLMMcSyF1kgV3rtK10gjsk8gCRRbEFc7tJPERhpObz(ajdbgEPjYAAdLaE542iChWBMDTCG14v1tQflMjowFKGbdKyvC2hjKosCwjJemyGe7YCFkC4pKwLlWSZAoq94bVb36AGxWA8Q6jvUncAqMp4aiWWlnrwtBOeWlh3gH7aEX0ctFQiRj4n4wxd8(e2Ngt9wpEqdY8bYbcm8stK10gkb8YXTr4oG3Ho0ujAvUaZU0LoSwtiXrKyxM7jSpnM6TE8CwZbQhpKGbdKyOdnvIwLlWSZpfHlWAiKGbdKyOdnvIwLlWS7tHd)H0iXrKyvC2hjKosKCjdVb36AG3eTEVAmPYfygAqdE57hcmK5dGadV0eznTHsaVCCBeUd4LxLExjghVk8UNWOTk(py1MdtGrppsiDKqUsgEdU11aVzDvB1IfZeObzwoqGHxAISM2qjGxoUnc3b8YRsVReJJxfE3ty0wf)hSAZHjWONhjKosixjdVb36AG3y40B4qR4HwdniZYfcm8stK10gkb8YXTr4oGxEv6DLyC8QW7EcJ2Q4)GvBombg98iH0rc5kz4n4wxd8UAmL1vTHgKzPfcm8gCRRbE1Txk7vNRSBpqAm4LMiRPnucObzo5qGHxAISM2qjGxoUnc3b8YRsVReJJxfE3ty0wf)hSAZHjWONhjKosCwjJemyGewdskRu7MqcPqIdoaEdU11aVzc)egOE8GgK5ZcbgEPjYAAdLaE542iChWBMDTC8QW7EcJ2Q4)GvBowFK4isKmKiZUwUmHFcdupEowFKGbdKiZUwUSUQTAXIzIJ1hjyWajKesGdo5mCP1iXrKqsibo4KRWCKiPibdgiH1GKYk1UjKqkKqoNfEdU11aV(L11aniZmfiWWlnrwtBOeWlh3gH7aETa7rMB3VfdNqcPldjol8gCRRbEJ3N4MQwklfPOWttqdAW7BqGHmFaey4n4wxd8gkqw8MWQAP44kXdV0eznTHsaniZYbcm8stK10gkb8YXTr4oGxl00yUCJ3VQwkFmXehnrwtBK4isKzxlhVk8UNWOTk(py1MJ1hjoIejdjYSRLJxfE3ty0wf)hSAZHjWONhjKcj84BKGbdKiZUwUSMfRQLYcDnVJ1hjoIez21YL1SyvTuwOR5Dycm65rcPqcp(gjsk8gCRRbEbRXRQNu52iObzwUqGHxAISM2qjGxoUnc3b8AHMgZLB8(v1s5JjM4OjYAAJehrIm7A54vH39egTvX)bR2CS(iXrKizirMDTC8QW7EcJ2Q4)GvBombg98iHuiHhFJemyGez21YL1SyvTuwOR5DS(iXrKiZUwUSMfRQLYcDnVdtGrppsifs4X3irsH3GBDnWlo8TcREd3arqdYS0cbgEPjYAAdLaE542iChWBMDTCPBFc)Q00uGowFK4isKzxlx62NWVknnfOdtGrppsifs4X3WBWTUg49jSpnM6TE8GgK5KdbgEPjYAAdLaE542iChW7Q4SpsaisWJ3uyYJgKqkKyvC23bghIehrIKHescjSqtJ5cTFQq5JPDyf2rtK10gjyWajwSATct8ub2JuwdsiHuiHhFJejfEdU11aVa1ATIxGGXSHgK5ZcbgEPjYAAdLaE542iChW7Q4SpsaisWJ3uyYJgKqkKyvC23bghIehrIKHelwTwHjEQa7rkRbjKqkKWJVrcgmqcjHe7YCjA9E1ysLlWSZAoq94HehrIKHez21YbwJxvpPwSyM42vIbjyWajwSATct8ub2JuwdsiHuiH06sosCgiHhFJejfjsk8gCRRbEt069QXKkxGzObzMPabgEPjYAAdLaE542iChWBMDTCPBFc)Q00uGowFK4isSlZ9e2Ngt9wpEombg98iHuiH0IeNbs4X3ibdgiHKqcl00yU0TpHFvAAkqhnrwtBK4isijKyxM7jSpnM6TE8CwZbQhpK4isijKiZUwoEv4DpHrBv8FWQnhRpsWGbsGPfM(urwtiXrKizirCEc3g50HrJP8R(RXrtK10gjyWajIZt42ixAAkWI9vRy8EhnrwtBKiPWBWTUg49jSpnM6TE8GgK5Zbcm8gCRRbEFJiTYWHp8stK10gkb0GmFUHadV0eznTHsaVCCBeUd41cnnMZim4RQLIgVWJaPXC0eznTrcgmqI48eUnYX6R466jvmBLpH)AcTJMiRPn8gCRRbEtfy)QgObz(ajdbgEdU11aV8QW7EcJ2Q4)GvBWlnrwtBOeqdY8bhabgEdU11aV8ubq4a8HxAISM2qjGgK5dKdey4LMiRPnuc4LJBJWDaVRIZ(ibGibpEtHjpAqcPqIvXzFhyCi8gCRRbEx6yaQhp1B4gicAqMpqUqGHxAISM2qjGxoUnc3b8Uko7JeaIe84nfM8ObjKcjwfN9DGXHiXrKizirMDTCG14v1tQflMjU3coqiHuiH0IemyGeRIZ(iHuirWTUghynEv9Kk3g541BirsH3GBDnWlqTwR4fiymBObz(aPfcm8stK10gkb8YXTr4oG3m7A5aRXRQNulwmtCS(ibdgiXQ4SpsiDK4SsgEdU11aVG14v1tQCBe0GmFqYHadVb36AGxC4Bfw9gUbIGxAISM2qjGgK5doley4LMiRPnuc4LJBJWDaV7YCpH9PXuV1JNdtlm9PISMqIJiHKqIm7A54vH39egTvX)bR2CS(WBWTUg49jSpnM6TE8GgK5dykqGHxAISM2qjGxoUnc3b8UlZLO17vJjvUaZomTW0NkYAcEdU11aVjA9E1ysLlWm0Gg8Y1uKMGadz(aiWWlnrwtBOeWB5dVpzWBWTUg4nDG7iRj4nDOzj4n4wNMu0qGn9iH0rIKJehrIKJemyGeb360KIgcSPhEthy1eGe8YdCAsX3yObzwoqGH3GBDnWBOazXBcRQLIJRep8stK10gkb0GmlxiWWBWTUg4LxfE3ty0wf)hSAdEPjYAAdLaAqMLwiWWlnrwtBOeWlh3gH7aE3L5(u4WFiTkxGzN1CG6XdEdU11aV8aNMGgK5KdbgEPjYAAdLaE542iChWRKqcl00yopwcJBTouwWTM)oAISM2ibdgiXIvRvyINkWEKYAqcjKcj84B4n4wxd8MO17vJjvUaZqdY8zHadV0eznTHsaVCCBeUd4Dtz21YPdJgt5x9xJ7TGdesidjoqYWBWTUg4fSgVQEsLBJGgKzMcey4n4wxd8YtfaHdWhEPjYAAdLaAqMphiWWlnrwtBOeWBWTUg4fOwRv8cemMn8YXTr4oG3vXzFKaqKGhVPWKhniHuiXQ4SVdmoeE5mHRjLfypYEiZhaniZNBiWWlnrwtBOeWlh3gH7aExSATct8ub2JuwdsiHuiHhFJemyGescjSqtJ5s069QXKQNf7314OjYAAJemyGe7YCFkC4pKwLlWSZAoq94HehrIDzUEmcpHwL1eT7XZ9wWbcjKcjKl8gCRRbEZSgpfHzc0GmFGKHadV0eznTHsaVCCBeUd41cnnMZJLW4wRdLfCR5VJMiRPn8gCRRbE5bonbniZhCaey4LMiRPnuc4LJBJWDaVRIZ(ibGibpEtHjpAqcPqIvXzFhyCi8gCRRbEx6yaQhp1B4gicAqMpqoqGHxAISM2qjGxoUnc3b8UlZLO17vJjvUaZomTW0NkYAcjyWajSqtJ5s069QXKQNf7314OjYAAdVb36AG3eTEVAmPYfygAqMpqUqGHxAISM2qjG3GBDnW7tyFAm1B94bVCCBeUd4nZUwU0TpHFvAAkqhRp8YzcxtklWEK9qMpaAqMpqAHadV0eznTHsaVCCBeUd4LxLExjgxIwVxnMu5cm7Wey0ZJeshjsh4oYAYXdCAsX3yKijesih4n4wxd8YdCAcAqMpi5qGH3GBDnW7BePvgo8HxAISM2qjGgK5doley4LMiRPnuc4LJBJWDaVwOPXCgHbFvTu04fEeinMJMiRPn8gCRRbEtfy)QgObz(aMcey4LMiRPnuc4n4wxd8(e2Ngt9wpEWlh3gH7aEX0ctFQiRjK4isKzxlN1(QAPSuK69Pa7El4aHesHeYfE5mHRjLfypYEiZhaniZhCoqGHxAISM2qjGxoUnc3b8UPm7A50HrJP8R(RXX6dVb36AGxWA8Q6jvUncAqMp4CdbgEPjYAAdLaE542iChW7MYSRLthgnMYV6VghRp8gCRRbEXHVvy1B4gicAqdAqdAqi]] )

    
end