-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 64 )

    -- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        bone_chilling = 22457, -- 205027
        lonely_winter = 22460, -- 205024
        ice_nova = 22463, -- 157997

        glacial_insulation = 22442, -- 235297
        shimmer = 22443, -- 212653
        ice_floes = 23073, -- 108839

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        frozen_touch = 22452, -- 205030
        chain_reaction = 22466, -- 278309
        ebonbolt = 22469, -- 257537

        frigid_winds = 22446, -- 235224
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        freezing_rain = 22454, -- 270233
        splitting_ice = 23176, -- 56377
        comet_storm = 22473, -- 153595

        thermal_void = 21632, -- 155149
        ray_of_frost = 22309, -- 205021
        glacial_spike = 21634, -- 199786
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3584, -- 214027
        relentless = 3585, -- 196029
        gladiators_medallion = 3586, -- 208683

        deep_shatter = 68, -- 198123
        frostbite = 67, -- 198120
        chilled_to_the_bone = 66, -- 198126
        kleptomania = 58, -- 198100
        dampened_magic = 57, -- 236788
        prismatic_cloak = 3532, -- 198064
        temporal_shield = 3516, -- 198111
        ice_form = 634, -- 198144
        burst_of_cold = 633, -- 206431
        netherwind_armor = 3443, -- 198062
        concentrated_coolness = 632, -- 198148
    } )

    -- Auras
    spec:RegisterAuras( {
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        blink = {
            id = 1953,
        },
        bone_chilling = {
            id = 205766,
            duration = 8,
            max_stack = 10,
        },
        brain_freeze = {
            id = 190446,
            duration = 15,
            max_stack = 1,
        },
        chain_reaction = {
            id = 278310,
            duration = 10,
            max_stack = 1,
        },
        chilled = {
            id = 205708,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        cone_of_cold = {
            id = 212792,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },
        fingers_of_frost = {
            id = 44544,
            duration = 15,
            max_stack = 2,
        },
        flurry = {
            id = 228354,
            duration = 1,
            type = "Magic",
            max_stack = 1,
        },
        freezing_rain = {
            id = 270232,
            duration = 12,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        frostbolt = {
            id = 59638,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        frozen_orb = {
            duration = 10,
            max_stack = 1,
            generate = function ()
                local fo = buff.frozen_orb

                if query_time - action.frozen_orb.lastCast < 10 then
                    fo.count = 1
                    fo.applied = action.frozen_orb.lastCast
                    fo.expires = fo.applied + 10
                    fo.caster = "player"
                    return
                end

                fo.count = 0
                fo.applied = 0
                fo.expires = 0
                fo.caster = "nobody"
            end,
        },
        glacial_spike = {
            id = 228600,
            duration = 4,
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_barrier = {
            id = 11426,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        ice_floes = {
            id = 108839,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        ice_nova = {
            id = 157997,
            duration = 2,
            type = "Magic",
            max_stack = 1,
        },
        icicles = {
            id = 205473,
            duration = 61,
            max_stack = 5,
        },
        icy_veins = {
            id = 12472,
            duration = function () return talent.thermal_void.enabled and 30 or 20 end,
            type = "Magic",
            max_stack = 1,
        },
        incanters_flow = {
            id = 116267,
            duration = 3600,
            max_stack = 5,
            meta = {
            }
        },
        preinvisibility = {
            id = 66,
            duration = 3,
            max_stack = 1,
        },
        invisibility = {
            id = 32612,
            duration = 20,
            max_stack = 1
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        polymorph = {
            id = 118,
            duration = 60,
            max_stack = 1
        },
        ray_of_frost = {
            id = 205021,
            duration = 5,
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 3600,
            max_stack = 1,
        },
        shatter = {
            id = 12982,
        },
        shimmer = {
            id = 212653,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        temporal_displacement = {
            id = 80354,
            duration = 600,
            max_stack = 1,
        },
        time_warp = {
            id = 80353,
            duration = 40,
            type = "Magic",
            max_stack = 1,
        },
        winters_chill = {
            id = 228358,
            duration = 1,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers (overrides)
        frigid_grasp = {
            id = 279684,
            duration = 20,
            max_stack = 1,
        },
        overwhelming_power = {
            id = 266180,
            duration = 25,
            max_stack = 25,
        },
        tunnel_of_ice = {
            id = 277904,
            duration = 300,
            max_stack = 3
        },
        winters_reach = {
            id = 273347,
            duration = 15,
            max_stack = 1,
        },
    } )


    -- azerite power.
    spec:RegisterStateExpr( "winters_reach_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "winters_reach", function( active )
        winters_reach_active = active
    end )


    spec:RegisterStateExpr( "fingers_of_frost_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "fingers_of_frost", function( active )
        fingers_of_frost_active = active
    end )


    spec:RegisterStateTable( "ground_aoe", {
        frozen_orb = setmetatable( {}, {
            __index = setfenv( function( t, k )
                if k == "remains" then
                    return buff.frozen_orb.remains
                end
            end, state )
        } )
    } )


    spec:RegisterStateTable( "incanters_flow", {
        changed = 0,
        count = 0,
        direction = "+",
    } )


    local FindUnitBuffByID = ns.FindUnitBuffByID


    spec:RegisterEvent( "UNIT_AURA", function( event, unit )
        if UnitIsUnit( unit, "player" ) and state.talent.incanters_flow.enabled then
            -- Check to see if IF changed.
            local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )

            if name and count ~= state.incanters_flow.count and state.combat > 0 then
                if count == 1 then
                    state.incanters_flow.direction = "+"
                elseif count == 5 then
                    state.incanters_flow.direction = "-"
                elseif count > state.incanters_flow.count then
                    state.incanters_flow.direction = "+"
                elseif count < state.incanters_flow.count then
                    state.incanters_flow.direction = "-"
                end

                state.incanters_flow.count = count
                state.incanters_flow.changed = GetTime()
            end
        end
    end )


    spec:RegisterStateTable( "frost_info", {
        last_target_actual = "nobody",
        last_target_virtual = "nobody",
        watching = true,

        had_brain_freeze = false,
    } )

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            if spellID == 44614 and FindUnitBuffByID( "player", 205766 ) then
                frost_info.had_brain_freeze = true
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return debuff.winters_chill.up or ( prev_gcd[1].flurry and frost_info.had_brain_freeze )
    end )

    spec:RegisterHook( "reset_precast", function ()
        frost_info.last_target_virtual = frost_info.last_target_actual
    end )


    -- Abilities
    spec:RegisterAbilities( {
        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,
            
            startsCombat = false,
            texture = 135932,
           
            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },
        

        blink = {
            id = 1953,
            cast = 0,
            charges = 1,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135736,

            notalent = "shimmer",
            
            handler = function ()
                -- applies blink (1953)
            end,
        },
        

        blizzard = {
            id = 190356,
            cast = function () return buff.freezing_rain.up and 0 or 2 * haste end,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135857,

            velocity = 20,
            
            handler = function ()
                applyDebuff( "target", "chilled" )
            end,
        },
        

        cold_snap = {
            id = 235219,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135865,
            
            handler = function ()
                setCooldown( "ice_barrier", 0 )
                setCooldown( "frost_nova", 0 )
                setCooldown( "cone_of_cold", 0 )
                setCooldown( "ice_block", 0 )
            end,
        },
        

        comet_storm = {
            id = 153595,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 2126034,

            talent = "comet_storm",
            
            handler = function ()
            end,
        },
        

        cone_of_cold = {
            id = 120,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135852,
            
            usable = function ()
                return target.distance <= 12
            end,
            handler = function ()
                applyDebuff( "target", "cone_of_cold" )
                active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )
            end,
        },
        

        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 134029,
            
            handler = function ()
            end,
        }, ]]
        

        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135856,

            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        ebonbolt = {
            id = 257537,
            cast = 2.5,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1392551,
            
            handler = function ()
                applyBuff( "brain_freeze" )
            end,
        },
        

        flurry = {
            id = 44614,
            cast = function ()
                if buff.brain_freeze.up then return 0 end
                return 3 * haste
            end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1506795,
            
            handler = function ()
                if buff.brain_freeze.up then
                    applyDebuff( "target", "winters_chill" )
                    removeBuff( "brain_freeze" )
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )

                removeBuff( "winters_reach" )
            end,
        },
        

        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135848,
            
            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },
        

        frostbolt = {
            id = 116,
            cast = 2,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135846,
            
            handler = function ()
                addStack( "icicles", nil, 1 )
                applyDebuff( "target", "chilled" )
                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )

                if azerite.tunnel_of_ice.enabled then
                    if frost_info.last_target_virtual == target.unit then
                        addStack( "tunnel_of_ice", nil, 1 )
                    else
                        removeBuff( "tunnel_of_ice" )
                    end
                    frost_info.last_target_virtual = target.unit
                end
            end,
        },
        

        frozen_orb = {
            id = 84714,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 629077,
            
            handler = function ()
                addStack( "fingers_of_frost", nil, 1 )
                if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
            end,
        },
        

        glacial_spike = {
            id = 199786,
            cast = 3,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1698699,

            talent = "glacial_spike",
            
            usable = function () return buff.icicles.stack >= 5 end,
            handler = function ()
                removeBuff( "icicles" )
                applyDebuff( "target", "glacial_spike" )
            end,
        },
        

        ice_barrier = {
            id = 11426,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135988,
            
            handler = function ()
                applyBuff( "ice_barrier" )
            end,
        },
        

        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,
            
            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },
        

        ice_floes = {
            id = 108839,
            cast = 0,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            startsCombat = false,
            texture = 610877,

            talent = "ice_floes",
            
            handler = function ()
                applyBuff( "ice_floes" )
            end,
        },
        

        ice_lance = {
            id = 30455,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135844,

            velocity = 47,
            
            handler = function ()
                if not talent.glacial_spike.enabled then removeStack( "icicles" ) end
                removeStack( "fingers_of_frost" )

                if talent.chain_reaction.enabled then
                    addStack( "chain_reaction", nil, 1 )
                end

                applyDebuff( "target", "chilled" )
                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end

                if azerite.whiteout.enabled then
                    cooldown.frozen_orb.expires = max( 0, cooldown.frozen_orb.expires - 0.5 )
                end 
            end,
        },
        

        ice_nova = {
            id = 157997,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1033909,

            talent = "ice_nova",
            
            handler = function ()
                applyDebuff( "target", "ice_nova" )
            end,
        },
        

        icy_veins = {
            id = 12472,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135838,
            
            handler = function ()
                applyBuff( "icy_veins" )
                stat.haste = stat.haste + 0.30

                if azerite.frigid_grasp.enabled then
                    applyBuff( "frigid_grasp", 10 )
                    addStack( "fingers_of_frost", nil, 1 )
                end
            end,
        },
        

        invisibility = {
            id = 66,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,
            
            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
            end,
        },
        

        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",
            
            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },
        

        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136071,
            
            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },
        

        ray_of_frost = {
            id = 205021,
            cast = 5,
            cooldown = 75,
            gcd = "spell",

            channeled = true,
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1698700,

            talent = "ray_of_frost",
            
            handler = function ()
                applyDebuff( "target", "ray_of_frost" )
            end,
        },
        

        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136082,
            
            handler = function ()
            end,
        },
        

        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.08,
            spendType = "mana",
            
            startsCombat = true,
            texture = 464484,

            talent = "ring_of_frost",
            
            handler = function ()                
            end,
        },
        

        rune_of_power = {
            id = 116011,
            cast = 1.5,
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",
            
            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",
            
            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },
        

        shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135739,

            talent = "shimmer",
            
            handler = function ()
                -- applies shimmer (212653)
            end,
        },
        

        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135992,
            
            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },
        

        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.21,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135729,
            
            handler = function ()
            end,
        },
        

        water_elemental = {
            id = 31687,
            cast = 1.5,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135862,
            
            notalent = "lonely_winter",

            usable = function () return not pet.alive end,
            handler = function ()
                summonPet( "water_elemental" )
            end,

            copy = "summon_water_elemental"
        },
        

        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",
            
            spend = 0.04,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,
            
            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",
        
        package = "Frost Mage",
    } )


    spec:RegisterPack( "Frost Mage", 20181022.2052, [[dOe)1aqisj1JiLQnjc(KOKmkiqNcc4vIiZIu0TerXUuQFPsmmsPCmi0YGiEgPKmnLOCnisTnruQVbbX4uIKZrkrToLivZtjI7jk2heuhueLSqvQEieKAIkrkCrrjAJIqFuusnsLifDsiswPsyMqqYnjLi7Ku4NkrvdLuclvevpfHPQs6Qkrk9vrjSxu(lKgmLdlSyv5XKmzeDzWMvvFwKgTs60swTsuPxlk1Sr62IQDR43snCsLLd1Zr10P66QW2vr(oPQXRevCEvkRxf18HO2pXmezxzeKHdmnqI2qCPquBibjBKOnKgjlBzmc)MoGrOluzhPaJyICGrKiU5UyAPifye6IB0oizxze8(aRagXQ764l9lxslF94TvD(fELFqdV6rHJVFHx5QlpA)U8(rYqcNUOd3)Ic8lAbgsEuK8lArYr1srkGMiU5(Mx5kgX7OOosnShJGmCGPbs0gIlfIAdjizJeTH0izzmI4WxBmJGOYrOzeRfjjmShJGe4kgH2flrCZDX0srkil0UyRURJV0VCjT81J3w15x4v(bn8Qhfo((fELRU8O97Y7hjdjC6IoC)lkWVOfyi5rrYVOfjhvlfPaAI4M7BELRKfAxSLx59dWIHeKOPyirBiUuILmITulDKgrX0cTeJGwCNZUYi41Ksb2vMgiYUYiGjEuGKDNrOWLd4kyeQUPKT(zxkaD6tXgdb5nXsqms4D8)B914aMJQwlkDFOJrekV6HrukaD6tbZzAGe2vgbmXJcKS7mcfUCaxbJWdkm(gE98AQVHjEuGuSeethgoHMQi3iUHxpVM6ILGyiOyATyEqHX3P0qvbfLRRYg2WepkqkgYil274)3LQuuGV5EOYwSLi2YedzKf7D8)7hoQb9Jb4mSXqOCXqagrO8QhgXNEGX3yotdTIDLrat8Oaj7oJqHlhWvWi8GcJVtPHQckkxxLnSHjEuGuSeethgoHMQi3iUtPHQckkxxLniwcI9o()9dh1G(XaCg2yiuoJiuE1dJ4tpW4BmNPXYyxzeWepkqYUZiu4YbCfmcDy4eAQICJ4(JBU)AQlwcI9o()9dh1G(XaCg2yiuUyjigckMwlMhuy8Dknuvqr56QSHnmXJcKIHmYI9o()DPkff4BUhQSfBjITmXqagrO8QhgXNEGX3yotdKMDLrekV6Hr8X9zyqB8Jrat8Oaj7oZzAKSzxzeWepkqYUZiu4YbCfmIq51jafgiVaUyiSyirmKrwSq51jafgiVaUyiSyikwcIPcUJ6voiwgX0Myji274)3)AsbmhT)OFCZ9ngcLl2sedjmIq5vpmIhToFoWKmNPbcHDLrat8Oaj7oJqHlhWvWiEh))(xtkG5O9h9JBUVXqOCgrO8QhgrPauAmkG5mnwk2vgrO8QhgHQZbhL7noNrat8Oaj7oZzAOLzxzeHYREyeWRNxtDgbmXJcKS7mNPbIAJDLrat8Oaj7oJqHlhWvWi0AXcLx9S)4(mmOn(TRb9tR0vxSeelf3hdjA0W(J7ZWG243gd5rnCXYiM2yeHYREye44gA)r)4M7mNPbIiYUYiGjEuGKDNrOWLd4kyeQG7OELdILrmTjgYilwO86eGcdKxaxmewmezeHYREyepAD(CGjzotderc7kJaM4rbs2DgHcxoGRGr8o()9dh1G(XaCg2yiuUyiJSy6WWj0uf5gXn8651uxmKrwSq51jafgiVaUyiSyikwcI5bfgFZ1rl3RjfTuWgM4rbsgrO8Qhgrknuvqr56QSbMZ0arTIDLrekV6HrukaD6tbJaM4rbs2DMZ0aXLXUYiGjEuGKDNrOWLd4kyeXzaxoS1xJdyokgc16gM4rbsXsqmTwS3X)VF4Og0pgGZWgdHYflbXEh))wFnoG5OyiuRBmekNrekV6Hr8Phy8nMZ0arKMDLrekV6Hr8Xn3Fn1zeWepkqYUZCMgiMSzxzeWepkqYUZicLx9WiubLIgkV6bLwCNrqlUJoroWiY7tqomoZzAGicHDLrekV6HrukaLgJcyeWepkqYUZCMZiiHFCqD2vMgiYUYicLx9Wiu9X4aMRdOugbmXJcKS7mNPbsyxzeWepkqYUZiu4YbCfmcDy4eAQICJ4(tpW4BILGypCud6hdWzanuEDcelbX0AXEh))(xtkG5O9h9JBUVXqOCgrO8QhgrPauAmkG5mn0k2vgbmXJcKS7mIq5vpmcvqPOHYREqPf3ze0I7OtKdmcv3uYw)WzotJLXUYiGjEuGKDNrOWLd4kyeHYRtakmqEbCXqyX0kXsqmpOW47pgGZ1KIIJA2WepkqkgYilwO86eGcdKxaxmewSLXicLx9WiubLIgkV6bLwCNrqlUJoroWiIgyotdKMDLrat8Oaj7oJiuE1dJqfukAO8QhuAXDgbT4o6e5aJGxtkfyoZze6WGQZFHZUY0ar2vgbmXJcKS7mNPbsyxzeWepkqYUZCMgAf7kJaM4rbs2DMZ0yzSRmIq5vpmIaRIbqRXbkfuoJaM4rbs2DMZ0aPzxzeHYREye6dhWOafYHXdkJaM4rbs2DMZ0izZUYiGjEuGKDN5mnqiSRmIq5vpmI8cJBmALhPaJaM4rbs2DMZ0yPyxzeHYREye6AV6Hrat8Oaj7oZzAOLzxzeHYREyeFCZ9xtDgbmXJcKS7mN5mcv3uYw)WzxzAGi7kJiuE1dJOu3qpb1WzeWepkqYUZCMgiHDLrekV6HrKxyCJrR8ifyeWepkqYUZCMgAf7kJaM4rbs2DgHcxoGRGrOddNqtvKBe3FCFgg0g)edzKfZRCa1BuYcedHfdrTjwsIPcUJ6voiwcI5voG6nkzbITeXqI2yeHYREye4Jbq7pQUwpGzotJLXUYiGjEuGKDNrOWLd4kyeEqHX34Jbq7pQUwpG3WepkqkwcIfkVobOWa5fWflJyikwcIP6Ms26Nn(ya0(JQR1d49)GsrXGAnWPaQx5Gylrmv3uYw)S)4(mmOn(TXqEudNrekV6HrOckfnuE1dkT4oJGwChDICGr4bfghf36yotdKMDLrat8Oaj7oJqHlhWvWi0HHtOPkYnI7sDd9eudxmKrwmpWPGV9khq9gLSaXwIyieTXicLx9Wi01E1dZzAKSzxzeHYREyehCaTCiNZiGjEuGKDN5mnqiSRmIq5vpmIhTBs0)b(gJaM4rbs2DMZ0yPyxzeHYREyepaZbC21KYiGjEuGKDN5mn0YSRmIq5vpmcALU6C0L7bzAomoJaM4rbs2DMZ0arTXUYicLx9Wi(fgE0UjzeWepkqYUZCMgiIi7kJiuE1dJigfWDCqrvbLYiGjEuGKDN5mNrenWUY0ar2vgrO8QhgXh3NHbTXpgbmXJcKS7mNPbsyxzeHYREyepAD(CGjzeWepkqYUZCMgAf7kJiuE1dJq15GJY9gNZiGjEuGKDN5mnwg7kJiuE1dJOua60NcgbmXJcKS7mNPbsZUYiGjEuGKDNrOWLd4kye6WWj0uf5gXn8651uxmKrwS3X)VF4Og0pgGZWgdHYflbXqqX0HHtOPkYnI7pU5(RPUyjigck274)3LQuuGV5EOYwSLi2YedzKftRfZdkm(oLgQkOOCDv2WgM4rbsXqaXqgzX0HHtOPkYnI7uAOQGIY1vzdIHamIq5vpmIp9aJVXCMgjB2vgbmXJcKS7mcfUCaxbJ4D8)7FnPaMJ2F0pU5(gdHYzeHYREyeLcqPXOaMZ0aHWUYicLx9WiWXn0(J(Xn3zeWepkqYUZCMglf7kJiuE1dJaE98AQZiGjEuGKDN5mn0YSRmIq5vpmIuAOQGIY1vzdmcyIhfiz3zotde1g7kJiuE1dJq1dG2FuvtjzeWepkqYUZCMgiIi7kJiuE1dJ4JBU)AQZiGjEuGKDN5mnqejSRmcyIhfiz3zeHYREyeQGsrdLx9GslUZiOf3rNihye59jihgN5mnquRyxzeHYREyeLcqPXOagbmXJcKS7mN5mcpOW4O4wh7ktdezxzeWepkqYUZiu4YbCfmcpOW47uAOQGIY1vzdByIhfiflbXEh))UuLIc8n3dv2ILrmKwSeedbf7D8)7hoQb9Jb4mSXqOCXqgzX8GcJVHxpVM6ByIhfiflbXuDtjB9ZgE98AQVXqEudxSLiMk4oQx5GyiaJiuE1dJaFmaA)r116bmZzAGe2vgbmXJcKS7mcfUCaxbJqRfZdkm(oLgQkOOCDv2WgM4rbsXsqmeumpOW4B41ZRP(gM4rbsXsqmv3uYw)SHxpVM6BmKh1WfBjIPcUJ6voigYilMhuy8TQZbhL7noFdt8OaPyjiMQBkzRF2QohCuU348ngYJA4ITeXub3r9khedzKfZdkm(gh3q7p6h3CFdt8OaPyjiMQBkzRF244gA)r)4M7BmKh1WfBjIPcUJ6voigYilMAnWPah9JdLx9euXqyXqCRLfdbyeHYREye4Jbq7pQUwpGzoZze59jihgNDLPbISRmcyIhfiz3zekC5aUcgrEFcYHX3Kf3JrbIHWIHO2yeHYREyepAnzZCMgiHDLrat8Oaj7oJqHlhWvWiEh))Uua6N2aFt26hgrO8QhgrPa0pTboZzoZzeNamV6HPbs0gIlL20YAL22iIq0gsZi0h4PMuoJaPY11yhifdHiwO8QhXOf35BzbJGRdumns2lJrOd3)IcmcTlwI4M7IPLIuqwODXwDxhFPF5sA5RhVTQZVWR8dA4vpkC89l8kxD5r73L3psgs40fD4(xuGFrlWqYJIKFrlsoQwksb0eXn338kxjl0UylVY7hGfdjirtXqI2qCPelzeBPw6inIIPfAjzHSq7ILLlhqD4aPyp43yqmvN)cxShKwdFlwYsPaDoxSPNKznW5)dQyHYRE4I1d92wwekV6HV1HbvN)cpZNg8SLfHYRE4BDyq15VWtkZLF3KYIq5vp8TomO68x4jL5sCKMdJhE1JSiuE1dFRddQo)fEszUeyvmaAnoqPGYLfHYRE4BDyq15VWtkZf9HdyuGc5W4bvwekV6HV1HbvN)cpPmx4tOJV2ok3dNllcLx9W36WGQZFHNuMl5fg3y0kpsbzrO8Qh(whguD(l8KYCrx7vpYIq5vp8TomO68x4jL5Yh3C)1uxwil0Uyz5YbuhoqkgCcW3eZRCqmFfeluEJfR4IfNIIgpkSLfHYRE4zu9X4aMRdOuzH2fdP(I5RGy5rki2AWflXorXIVdyXub3RjvSA4EmUyjspW4BAkMEqmvmIrc04My(kigsPaXqOIrbIfdPyhCqS2xbSyRv6Qy6WvJl)MyHYRE0uS6lwCkkA8OWwwekV6HNuMlLcqPXOanRFgDy4eAQICJ4(tpW4Bj8WrnOFmaNb0q51jibT(D8)7FnPaMJ2F0pU5(gdHYLfHYRE4jL5IkOu0q5vpO0I7AoroKr1nLS1pCzH2f76kiMh4uWfZxXaFTPKIv8jRCXGLtO8Ty3bxpaJyAvYG0I5bofCUMI5RGyK1)dyyuaxSh46byeZxbXiUkwmKILS6SuSq5vpIrlUZflWGy4WxbSy88Gs3IT0S1dNaSMILigGZ1KkwYJAethg(aMl2bVMuXswDwkwO8QhXOf3fJ39ayXcUyLl2dg4xoxSumeo9MyFCNlMVcITwPRIPdxnU8BIDNwNphysXcLx9SLfHYRE4jL5IkOu0q5vpO0I7AoroKjAqZ6NjuEDcqHbYlGJWAvcEqHX3FmaNRjffh1SHjEuGezKdLxNauyG8c4i8YKfHYRE4jL5IkOu0q5vpO0I7AoroKHxtkfKfYcTlwwu(QyjIb4CnPIL8OgnfR8SIl2dChWI5Ty6WvJlVodIDWRjvSeX9zyeB5XpX0VcJyV2xflXLxSyif7oToFoWKIfyqS()ft1nLS1pBXYIYx7dxSeXaCUMuXsEuJMI5RGyQEobyoiwXfZXhGyb1x7J0vX8vqmY6)bmmkqSIlwEnfxDqbXogVOIDcW3eBTsxfZdCk4IP6JX5BzrO8Qh(oAiZh3NHbTXpzrO8Qh(oAiPmxE0685atklcLx9W3rdjL5IQZbhL7noxwekV6HVJgskZLsbOtFkKfAxmIkxhT(fqkwI0dm(MyQEilV6Hl2h35I5RGyexfluE1Jy0I7BXiQrbI5RGy5rkiwXflfgahEnPI9dSyuGZf7ooQrSeXaCgetTg4uGRPy(kigSCcLlMQhYYREeBfWGyfFYkxSGsfZxdxSkxxJ9y8TSiuE1dFhnKuMlF6bgFtZ6NrhgoHMQi3iUHxpVM6iJ874)3pCud6hdWzyJHq5jGG6WWj0uf5gX9h3C)1upbe8D8)7svkkW3CpuzVKLHmYAThuy8Dknuvqr56QSHnmXJcKiaYiRddNqtvKBe3P0qvbfLRRYgqazrO8Qh(oAiPmxkfGsJrbAw)mVJ)F)RjfWC0(J(Xn33yiuUSq7IDDfelpsbX0xuQyPWa4GsVj2delfgahEnPIfIrBxS(lwIDIIPwdCkWft)kmIDWRjvmFfelz1zPyHYREeJwCFl2v8TAsfZBXibACtSKh3eR)ILiU5UyhJxuX8vadIfyqSPflXorXuRbof4IfdPytlwO86eiwI4(mmIT84hxm99bLumkeKI5TyLl20UypOMuXo4aPyHlwqPBzrO8Qh(oAiPmxWXn0(J(Xn3LfHYRE47OHKYCbE98AQllcLx9W3rdjL5sknuvqr56QSbzH2fBPLxtQyi09aI1FXqOBkPyfxS8M70BIT0qlieBGdhhuX0x(Qy(kiwYQZsX8aNcUy(kg4RnLKVfdPCX6HEtShO6CGlgjOGXflnQrm9LVkgUpsxP3edHiwJflVXGyEGtbNVLfHYRE47OHKYCr1dG2FuvtjLfHYRE47OHKYC5JBU)AQllcLx9W3rdjL5IkOu0q5vpO0I7AoroKjVpb5W4YIq5vp8D0qszUukaLgJcKfYIq5vp8TQBkzRF4zk1n0tqnCzrO8Qh(w1nLS1p8KYCjVW4gJw5rkil0Uyj)yaX6VyArRhWIvCXcQ(4gxSdoqkM(YxflrCFggXwE8BlwYAUjgf(EFcWIPwdCkWflCX8vqmyifR)I5RGy)kD1fJV2husXEGyhCGutXksiO0BIvFX8vqSxZ5Ir2aFYkxmYceRgX8vqS8IKKcI1FX8vqSKFmGyVJ)FllcLx9W3QUPKT(HNuMl4Jbq7pQUwpG1S(z0HHtOPkYnI7pUpddAJFiJSx5aQ3OKfGWiQTKub3r9khsWRCa1BuYcwcs0MSq7IT8Jy8AsPGyEGtbxSFLU6CnfZxbXuDtjB9Jy9xSKFmGy9xmTO1dyXkUy0wpGfZxJrmFfet1nLS1pI1FXse3NHrSLh)0umFT4ILwNaUyWYXXHyj)yaX6VyArRhWIPwdCkWfZxdxm(AFqjf7bIDWbsX0x(QyHYRtGyEqHX5Akw9ftxZ51JcBzrO8Qh(w1nLS1p8KYCrfukAO8QhuAXDnNihY4bfghf360S(z8GcJVXhdG2FuDTEaVHjEuGmHq51jafgiVaEgetq1nLS1pB8XaO9hvxRhW7)bLIIb1AGtbuVYHLO6Ms26N9h3NHbTXVngYJA4YIq5vp8TQBkzRF4jL5IU2RE0S(z0HHtOPkYnI7sDd9eudhzK9aNc(2RCa1BuYcwccrBYIq5vp8TQBkzRF4jL5YbhqlhY5YIq5vp8TQBkzRF4jL5YJ2nj6)aFtwekV6HVvDtjB9dpPmxEaMd4SRjvwekV6HVvDtjB9dpPmxOv6QZrxUhKP5W4YIq5vp8TQBkzRF4jL5YVWWJ2nPSiuE1dFR6Ms26hEszUeJc4ooOOQGsLfYIq5vp8DEFcYHXZ8O1KTM1ptEFcYHX3Kf3JrbimIAtwekV6HVZ7tqomEszUuka9tBGRz9Z8o()DPa0pTb(MS1pYczH2fdPgX4DoigV8JWRE4Ak2T(qmvmIXxd3bSyiLcetJ(uigCcgXIVdyXckgcYBIPcUxtQyjspW4BIfdPyiLcedHkgfSfB59vaRV4Gy(AXfluE1JyfxSdoqkM(vyeZxbXYJuqS1GlwIDIIfFhWIPcUxtQyjspW4BAkghaXIxFc2YIq5vp8nVMukKPua60NcnRFgv3uYw)SlfGo9PyJHG8wcKW74)36RXbmhvTwu6(qNSq7ILfLV2hUyznHMILLVEEn1fR4Ifu9XnUy81WDadKBXYIYxflRj0uSS81ZRPUyfxm(A4oGbsXQVyLlM((GskM(G7Gy3XrnILigGZGyQ1aNcIHG1g2IPFfgX8vqS8ifeJ7b25IPcUxtQyz5RNxtDX0x(Qy3XrnILigGZGyHYRtaciwJft)kmI9aARxSLjgsPkff4IHG1xSS81ZRPUyfxmvWDX0VcJy(kiwEKcITgCXwwYG0IHuQsrbUMIvEwXf7bUdyX8wSdoiMVcIDhh1iwIyaodI9XDUyLlwpIL10qvbvmcDv2acSLfHYRE4BEnPuiPmx(0dm(MM1pJhuy8n8651uFdt8Oazc6WWj0uf5gXn8651upbeuR9GcJVtPHQckkxxLnSHjEuGezKFh))UuLIc8n3dv2lzziJ874)3pCud6hdWzyJHq5iGSq7IL10qvbvmcDv2GyfxSGQpUXfJVgUdyGCllcLx9W38AsPqszU8Phy8nnRFgpOW47uAOQGIY1vzdByIhfitqhgoHMQi3iUtPHQckkxxLnKW74)3pCud6hdWzyJHq5YcTlwwu(AF4IL1eAkMVcILhPGyl3dUlMJlGlM3IXxd3bSybxS8yUjwI4M7VM6CXcUy6AoVEuylwwu(QyznHMI5RGy5rkiwp0BIXxd3bmxSeXn3Fn1fZxdxm99bLumDhUy(kKlw4IHyYOvIHuQsrbX4EOYMVfBPr9)aggfi2dC9amIXxd3bCnPILiU5(RPUy6lFvmetgTsmKsvkkWflgsXqmzwMyiLQuuGlwXfJNhuQMI9oCXqmz0kXCyi5I5TypqSh4oGfRgXYBmigV8JWRE4IHG(ki2ALUcyXYAcXiJ8ifeR4AkMVcIL3yqSYfJcXWfZB9bMKlgIjJwHaBXsSXQAsfJVgUdyX6rSeXn3Fn1fR4IX9IsfleJNhuQyPrnAkgVfR4InTlMkW1Kkw86dxSe7e3IHukqmeQyuGyfxmVBX0dr2I5Ty6dmogxmsGg3QjvS74OgXsedWzqSePhy8TTSiuE1dFZRjLcjL5YNEGX30S(z0HHtOPkYnI7pU5(RPEcVJ)F)WrnOFmaNHngcLNacQ1EqHX3P0qvbfLRRYg2WepkqImYVJ)FxQsrb(M7Hk7LSmeqwekV6HV51KsHKYC5J7ZWG24NSq7ILfLVkwIyaoxtQyjpQrSyiflCXOqWDXqIyEGtbNRPy3P15ZbMuSbasUyEl2de7GdKIPV8vXwR0valMoC14YVjM3ILhzdIXpWGy36dXuXi2VCXETVkwnCpgxS70685atYfRgVfleJxtkfelrmaNRjvSKh1SfJWdSxtQy6lFvmFfdGyEGtbNRPy3P15ZbMumkeNaUy(kigT1lMoC14YVj2VOualgUPGyXqkwXf7GdKI1JyQUPKT(rmemgsXwUhCxS8i7AsfJFGbXM2fZBX0hChe7ooQrSeXaCgetTg4uGJaIPV8vXASy6lFTpCXsedW5Asfl5rnBzrO8Qh(MxtkfskZLhToFoWKAw)mHYRtakmqEbCegjiJCO86eGcdKxahHrmbvWDuVYHmAlH3X)V)1KcyoA)r)4M7BmekFjirwODXUIVvtQyElMUUPIPwdCkWfR)ILyNOy)glwm381AsfR4tw5IPVX(QyLVfBPLdI5RqUybxmFfUjMQZHTSiuE1dFZRjLcjL5sPauAmkqZ6N5D8)7FnPaMJ2F0pU5(gdHYLfHYRE4BEnPuiPmxuDo4OCVX5YIq5vp8nVMukKuMlWRNxtDzH2fl5XnX6VyjIBUlwXf7GdKIfFhWIfuQyjwtkG5I1FXse3Cxm1AGtbUyRXjqShaJyhCGuSyifZxbmiwXNSYfluEDcelrCFggXwE8tmFnCXu9bLuSuyaC4Gy5ng2IDDT4IvCX6HEtSqmEEqPILg1iwKg1WDXYpOEPJcI5bofCUMIfCXsECtS(lwI4M7Iv8jRCX8UfRY1fk)Fq3YIq5vp8nVMukKuMl44gA)r)4M7Aw)mADO8QN9h3NHbTXVDnOFALU6jKI7JHenAy)X9zyqB8BJH8OgEgTjl0Uy3P15ZbMuSIl2bhifl4IrB9IPdxnU8BI9lkfWIfPrnCxmKiMh4uW5BXYIvye7GxtQyjIb4CnPIL8OgnfR8SIlwiwoqwh5ILg1iM3IDWbX8vqSA4EmUy3P15ZbMum4emIfPrnCxSqmEnPuqmpWPGRPyaxhOQGsVjM(YxfJ26flp4oGVTLfHYRE4BEnPuiPmxE0685atQz9ZOcUJ6voKrBiJCO86eGcdKxahHruwODXYAAOQGkgHUkBqSIl2bhift)kmI5RagYkUyHy3XrnILigGZGy6WTsSq51jqmeS2WwSEO3et)kmIvUyQye7bIXxd3bmqIaBXUUwCXkUyHy88GsfZBXYbY6ixS0OgXQrS8M7IXl)i8Qh(wmeQwVy5b3b8nXOqmCX8wFGj5IDWRjvSYft)kmIfNIIgpkSfllwHrSdEnPIrOJwUxtQyiLcelgsXwJt1KkwmTVcyX8aNcUyde43nnfR8SIlgNwPRo9MypWDalM3IDWbXYAcX0VcJyXPOOXJcAkwWfZxbX4GQhsX8aNcUyKnWNSYf7bd8lxSpUZfJVgUd4AsfZxbXYJAeZdCk4BzrO8Qh(MxtkfskZLuAOQGIY1vzdAw)mVJ)F)WrnOFmaNHngcLJmY6WWj0uf5gXn8651uhzKdLxNauyG8c4imIj4bfgFZ1rl3RjfTuWgM4rbszrO8Qh(MxtkfskZLsbOtFkKfHYRE4BEnPuiPmx(0dm(MM1ptCgWLdB914aMJIHqTUHjEuGmbT(D8)7hoQb9Jb4mSXqO8eEh))wFnoG5OyiuRBmekxwekV6HV51KsHKYC5JBU)AQllcLx9W38AsPqszUOckfnuE1dkT4UMtKdzY7tqomUSiuE1dFZRjLcjL5sPauAmkqwil0Uyzr5RIL10qvbvmcDv2GMIL8JbeR)IPfTEalgFTpOKI9aXo4aPy4kD1f7b)gdI5RGyznnuvqfJqxLniMQZFTyiyTHTy6lFvmKwmKsvkkWflgsXcXUJJAelrmaNbeylwwScJyz5RNxtDXkUy9)lMQBkzRF0uSKFmGy9xmTO1dyXuXiwq5TypqSdoqk2Y9G7IPV8vXqAXqkvPOaFllcLx9W3EqHXrXTUm4Jbq7pQUwpG1S(z8GcJVtPHQckkxxLnSHjEuGmH3X)VlvPOaFZ9qLDgKobe8D8)7hoQb9Jb4mSXqOCKr2dkm(gE98AQVHjEuGmbv3uYw)SHxpVM6BmKh1WxIk4oQx5acil0Uyzr5R9HlwwtdvfuXi0vzdAkwYpgqS(lMw06bSy81(Gsk2de7GdKI9GFJbXI5MyVknfWIP6Ms26hXqWS81ZRPUMIHq35GlgH34Cnfl5XnX6VyjIBUJaI1yX0VcJyj)yaX6VyArRhWIvCXIxF4I5TyyiuRIHeXuRbof4BzrO8Qh(2dkmokU1LuMl4Jbq7pQUwpG1S(z0ApOW47uAOQGIY1vzdByIhfitab9GcJVHxpVM6ByIhfitq1nLS1pB41ZRP(gd5rn8LOcUJ6voGmYEqHX3QohCuU348nmXJcKjO6Ms26NTQZbhL7noFJH8Og(sub3r9khqgzpOW4BCCdT)OFCZ9nmXJcKjO6Ms26NnoUH2F0pU5(gd5rn8LOcUJ6voGmYQ1aNcC0pouE1tqrye3AzeG5mNXaa]] )


end
