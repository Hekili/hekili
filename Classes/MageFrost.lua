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


    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return buff.brain_freeze.up
    end )

    -- azerite power.
    spec:RegisterStateExpr( "winters_reach_active", function ()
        return buff.winters_reach.up
    end )

    spec:RegisterStateExpr( "fingers_of_frost_active", function ()
        return buff.fingers_of_frost.up
    end )
    -- spec:RegisterStateExpr( "")


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


    spec:RegisterStateTable( "frostbolt_info", {
        last_target_actual = "nobody",
        last_target_virtual = "nobody",
        watching = true,
    } )

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 116 then
            frostbolt_info.last_target_actual = destGUID
        end
    end )


    spec:RegisterHook( "reset_precast", function ()
        frostbolt_info.last_target_virtual = frostbolt_info.last_target_actual
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
            charges = function () return talent.ice_ward.enabled and 2 or 1 end,
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
                    if frostbolt_info.last_target_virtual == target.unit then
                        addStack( "tunnel_of_ice", nil, 1 )
                    else
                        removeBuff( "tunnel_of_ice" )
                    end
                    frostbolt_info.last_target_virtual = target.unit
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
            
            toggle = "cooldowns",

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
    
        package = "Frost Mage",
    } )


    spec:RegisterPack( "Frost Mage", 20180812.2244, [[dOKAZaqieKEKsk2ePOpjkkJsLsDkvk5vKsnlsj3cbr7sP(fPWWusLJPeTmespdHOPPsrxdbvBJuf8nsvKXPKQ6CIIK1jksP5PsH7jI2NskDqLufluf6HiiyIkPk1fjvP2iPQ(OOigPOifNeHWkvcZebHUPOiv7eH6NKQqdLuf1srq5PqAQQGRQKQKVsQs2ls)vvnykhwyXQYJrzYi6YGndXNfPrRIoTKvlkQ8ArHzJQBlQ2TIFl1WjvwoupNKPt11vjBxu67IW4ffvDEvQwVsY8rG9tmDj9afLmCGsmrx3Y1FDR)sIUjkrV5nj66tr976akQUGLrKcu0jYbkQ(4w5ILPhPafvxCN3bj9afv1xygqrpDxNktRgAKw(51BZ6Cnuv(fp8QhgoqCnuvotJhVFA8qccjjKvdD4gP4GsJdfGj6snoq0L)m9if(6JBLVvvoJI(UkUted9rrjdhOet01TC9x36VKOBIs0BEZ1rukAC5NnMIIw5ecuusqXOOholLyLsSqmDblJifeRrelyE1Jy8s5kXqASyzAGmkETPO8s5k6bkQQMuoqpqjEj9affM4Xbs6rkkdxoGRGIY6Mt2jMDXG)0zJngcY7IPPyKW7cbzNOghWQp7S489LokAW8QhkAXG)0zdQtjMO0duuyIhhiPhPOmC5aUckkHkMhCy8DkpyvW)kDvgWgM4XbsX0uSBlMomK9NYi3l3WRNxZDXiGaXExii7hoQ5JGbyfSXqWCX0umDyi7pLrUxUrWTYFn3f7wu0G5vpuue(fgFN6uIjs6bkkmXJdK0JuugUCaxbf1dom(oLhSk4FLUkdydt84aPyAk27cbz)WrnFemaRGngcMlMMIDBX0HHS)ug5E5gb3k)1Cxmnf7DHGSlwX4GAR8GLHy3qSBkgbeiMomK9NYi3l3P8Gvb)R0vzaIrabIPddz)PmY9Yn8651CxSBrrdMx9qrr4xy8DQtj(M0du0G5vpuueCVcMFJFuuyIhhiPhPoLycNEGIct84aj9ifLHlhWvqrdMxzHpmqEbkXwRyevmciqSG5vw4ddKxGsS1k2sX0umwO8Vx5GyjfBDIPPyVleKnsnPaw9BKpcUv(gdbZf7gIrukAW8Qhk6JxRwfysQtjwpqpqrHjECGKEKIYWLd4kOOVleKnsnPaw9BKpcUv(gdbZPObZREOOfd(8yya1PeRNOhOObZREOOSoh8VYBCoffM4Xbs6rQtjE9PhOOWepoqspsrz4YbCfuucvmp4W47uEWQG)v6QmGnmXJdKIrabI9Uqq2fRyCqTvEWYqSKIr4IPPyeQyVleK9dh18rWaSc2yiyofnyE1dffE98AUtDkXzk6bkkmXJdK0JuugUCaxbfLqflyE1Zgb3RG5343UMpcVspDX0uSuCFnK)OHncUxbZVXVngYJAuILuS1rrdMx9qrXX9FJ8rWTYPoL4LRJEGIct84aj9ifLHlhWvqrzHY)ELdILuS1jgbeiwW8kl8HbYlqj2AfBjfnyE1df9XRvRcmj1PeVCj9affM4Xbs6rkkdxoGRGI(Uqq2pCuZhbdWkyJHG5IrabIPddz)PmY9Yn8651CxmciqSG5vw4ddKxGsS1k2sX0ump4W4BLoE5EnP)IbByIhhiPObZREOOP8Gvb)R0vzauNs8sIspqrdMx9qrlg8NoBqrHjECGKEK6uIxsK0duuyIhhiPhPOmC5aUckAScWLd7e14aw9XqWo3WepoqkMMIrOI9Uqq2pCuZhbdWkyJHG5IPPyVleKDIACaR(yiyNBmemNIgmV6HIIWVW47uNs8YBspqrdMx9qrrWTYFn3POWepoqspsDkXljC6bkkmXJdK0Ju0G5vpuuwW5)G5vpFEPCkkVu(FICGIM3zHCyCQtjEPEGEGIgmV6HIwm4ZJHbuuyIhhiPhPo1POKasCXD6bkXlPhOObZREOOS(ACaR0bCoffM4Xbs6rQtjMO0duuyIhhiPhPOmC5aUckQomK9NYi3l3i8lm(UyAk2dh18rWaSc(bZRSGyAkgHk27cbzJutkGv)g5JGBLVXqWCkAW8QhkAXGppggqDkXej9affM4Xbs6rkAW8Qhkkl48FW8QNpVuofLxk)proqrzDZj7eJI6uIVj9affM4Xbs6rkkdxoGRGIgmVYcFyG8cuITwXisX0ump4W4BemaRQj9JJA2WepoqkgbeiwW8kl8HbYlqj2Af7Mu0G5vpuuwW5)G5vpFEPCkkVu(FICGIgnqDkXeo9affM4Xbs6rkAW8Qhkkl48FW8QNpVuofLxk)proqrv1KYbQtDkQomW68x40duIxspqrHjECGKEK6uIjk9affM4Xbs6rQtjMiPhOOWepoqspsDkX3KEGIgmV6HIgywmWVgh4CG5uuyIhhiPhPoLycNEGIgmV6HIMiCa)boKdJhCkkmXJdK0JuNsSEGEGIct84aj9i1PeRNOhOObZREOO5fg34FLhPaffM4Xbs6rQtjE9PhOObZREOO6AV6HIct84aj9i1PeNPOhOObZREOOi4w5VM7uuyIhhiPhPo1POSU5KDIrrpqjEj9afnyE1dfTy3)zHAuuuyIhhiPhPoLyIspqrdMx9qrZlmUX)kpsbkkmXJdK0JuNsmrspqrHjECGKEKIYWLd4kOOELdFV)Kfi2AfB56etBXyHY)ELdIPPyELdFV)Kfi2neJOeofnyE1dffFnWVr(66eaM6uIVj9affM4Xbs6rkkdxoGRGIgmVYcFyG8cuILuSLIPPyEWHX3P8Gvb)R0vzaByIhhifttXExii7IvmoO2kpyziwsXiCX0uSBl27cbz)WrnFemaRGngcMlgbeiMhCy8n8651CFdt84aPyAkgRBozNy2WRNxZ9ngYJAuIDdXyHY)ELdIDlkAW8Qhkk(AGFJ811jam1Pet40duuyIhhiPhPOmC5aUckAW8kl8HbYlqjwsXwkMMIrOI5bhgFNYdwf8VsxLbSHjECGumnf72IPddz)PmY9YncUxbZVXpXiGaX8GdJVHxpVM7ByIhhifttXyDZj7eZgE98AUVXqEuJsSBiglu(3RCqmciqmp4W4BwNd(x5noFdt84aPyAkgRBozNy2Soh8VYBC(gd5rnkXUHySq5FVYbXiGaX8GdJVXX9FJ8rWTY3WepoqkMMIX6Mt2jMnoU)BKpcUv(gd5rnkXUHySq5FVYbXiGaXyNbofuFeCW8QNGl2AfB5otj2TOObZREOO4Rb(nYxxNaWuNsSEGEGIct84aj9ifLHlhWvqrdMxzHpmqEbkXwRylfttX0HHS)ug5E5gb3RG534hfnyE1dffFnWVr(66eaM6uI1t0duuyIhhiPhPOmC5aUckQomK9NYi3l3f7(pluJsmciqmpWPGV9kh(E)jlqSBiMEADu0G5vpuuDTx9qDkXRp9afnyE1df9sb)YHCfffM4Xbs6rQtjotrpqrdMx9qrF8Uj)ix47uuyIhhiPhPoL4LRJEGIgmV6HI(aScWzutkffM4Xbs6rQtjE5s6bkAW8QhkkVspD1pZDrMMdJtrHjECGKEK6uIxsu6bkAW8QhkksHHhVBskkmXJdK0JuNs8sIKEGIgmV6HIgdduoo4FwW5uuyIhhiPhPo1POrd0duIxspqrdMx9qrrW9ky(n(rrHjECGKEK6uIjk9afnyE1df9XRvRcmjffM4Xbs6rQtjMiPhOObZREOOSoh8VYBCoffM4Xbs6rQtj(M0du0G5vpu0Ib)PZguuyIhhiPhPoLycNEGIct84aj9ifLHlhWvqr1HHS)ug5E5gE98AUlgbei27cbz)WrnFemaRGngcMlMMIDBX0HHS)ug5E5gb3k)1Cxmnf72I9Uqq2fRyCqTvEWYqSBi2nfJaceJqfZdom(oLhSk4FLUkdydt84aPy3smciqmDyi7pLrUxUt5bRc(xPRYae7wu0G5vpuue(fgFN6uI1d0duuyIhhiPhPOmC5aUck67cbzJutkGv)g5JGBLVXqWCkAW8QhkAXGppggqDkX6j6bkAW8QhkkoU)BKpcUvoffM4Xbs6rQtjE9PhOObZREOOWRNxZDkkmXJdK0JuNsCMIEGIgmV6HIMYdwf8VsxLbqrHjECGKEK6uIxUo6bkAW8QhkkRh43iFwZjPOWepoqspsDkXlxspqrdMx9qrrWTYFn3POWepoqspsDkXljk9affM4Xbs6rkAW8Qhkkl48FW8QNpVuofLxk)proqrZ7Sqomo1PeVKiPhOObZREOOfd(8yyaffM4Xbs6rQtDkAENfYHXPhOeVKEGIct84aj9ifLHlhWvqrZ7Sqom(MSuEmmqS1k2Y1rrdMx9qrF8AYG6uIjk9affM4Xbs6rkkdxoGRGI(Uqq2fd(i8guBYoXqrdMx9qrlg8r4nOOo1PofnrGNAsvuuIixxJDGum9GybZREeJxkxTLfuuLoGrjwpCtkQoCJuCGIUgX07mpWUCGuShG0yqmwN)cxShKwJAl26HXaDUsSPhc5zGZrU4IfmV6rjwp87BzrW8Qh1whgyD(l8Ki8qLHSiyE1JARddSo)fU2j1aPBszrW8Qh1whgyD(lCTtQrCLMdJhE1JSiyE1JARddSo)fU2j1iWSyGFnoW5aZLfbZREuBDyG15VW1oPgjchWFGd5W4bxwemV6rT1HbwN)cx7KAOMqN6S9VYdxjlcMx9O26WaRZFHRDsnYlmUX)kpsbzrW8Qh1whgyD(lCTtQHU2REKfbZREuBDyG15VW1oPgi4w5VM7YczXAetVZ8a7YbsXGSa(UyELdI5NGybZBSyLsSiBu84XHTSiyE1JkjRVghWkDaNllwJyebIy(jiwEKcIDgkX0V1xSaXbSySq51Kkwnkpgxm95xy8DTelbiglgXibECxm)eeJiyGyeIXWaXIHuSlfiw7NawSZk9umD4QXLFxSG5vpAjwHiwKnkE84WwwemV6rPDsnkg85XWaTkKK6Wq2FkJCVCJWVW47A(WrnFemaRGFW8klOjH(Uqq2i1Kcy1Vr(i4w5BmemxwemV6rPDsnybN)dMx985LY1AICijRBozNyuYI1i2HtqmpWPGlMFIb1zZjfRutM5Ibz(G5BXocEcagXiscjHlMh4uWvAjMFcIrwiiagggOe7bEcagX8tqm0dIfdPyRNwVflyE1Jy8s5kXcmigo8talMkp48TyzA6eqwaRLy6JbyvnPIryrnIPddiawj2LQMuXwpTElwW8QhX4LYft19ayXcLyLl2dgaPCLyPyiC(DXqWDUy(ji2zLEkMoC14YVl2rETAvGjflyE1ZwwemV6rPDsnybN)dMx985LY1AICiz0GwfsYG5vw4ddKxGATePMEWHX3iyawvt6hh1SHjECGKaccMxzHpmqEbQ1EtzrW8QhL2j1GfC(pyE1ZNxkxRjYHKQAs5GSqwSgX0RYpftFmaRQjvmclQrlXkpZuI9a3bSyElMoC14YRvGyxQAsftFCVcgX0J4NyjoHrSx7NIPVEuSyif7iVwTkWKIfyqSgbrmw3CYoXSftVk)SVCX0hdWQAsfJWIA0sm)eeJ1twaRaXkLyo(cel4(zFLEkMFcIrwiiagggiwPelVMsXU4GyxJxCXYc47IDwPNI5bofCXy914QTSiyE1JAhnKeb3RG534NSiyE1JAhnODsnE8A1QatklcMx9O2rdANudwNd(x5noxwemV6rTJg0oPgfd(tNnKfRrm0kxhVqkGum95xy8DXy9qwE1JsmeCNlMFcIHEqSG5vpIXlLVfdTggiMFcILhPGyLsSuyaC41KkgsGfJdkLyhXrnIPpgGvGySZaNckTeZpbXGmFWCXy9qwE1JyNageRutM5IfCUy(z4Iv56AShJVLfbZREu7ObTtQbc)cJVRvHKuhgY(tzK7LB41ZR5obe8Uqq2pCuZhbdWkyJHG5AEBDyi7pLrUxUrWTYFn3182VleKDXkghuBLhSmUXnjGac1dom(oLhSk4FLUkdydt84a5TiGaDyi7pLrUxUt5bRc(xPRYaULSiyE1JAhnODsnkg85XWaTkKKVleKnsnPaw9BKpcUv(gdbZLfRrSdNGy5rkiwIIZflfgahC(DXEGyPWa4WRjvSqmE7I1iIPFRVySZaNckXsCcJyxQAsfZpbXwpTElwW8QhX4LY3IDaFVMuX8wmsGh3fJWI7I1iIPpUvUyxJxCX8tadIfyqSPft)wFXyNbofuIfdPytlwW8kliM(4EfmIPhXpLyj6loPyCiifZBXkxSPDXEqnPIDPasXcxSGZ3YIG5vpQD0G2j1ah3)nYhb3kxwemV6rTJg0oPgWRNxZDzrW8Qh1oAq7KAKYdwf8VsxLbilwJyRxQAsfJqOhqSgrmcHMtkwPelVvo)UyR36zuXg4YXbxSeLFkMFcITEA9wmpWPGlMFIb1zZjvBXicxSE43f7bSohuIrcmyCXsJAelr5NIH7R0t(DX0tI1yXYBmiMh4uWvBzrW8Qh1oAq7KAW6b(nYN1CszrW8Qh1oAq7KAGGBL)AUllcMx9O2rdANudwW5)G5vpFEPCTMihsM3zHCyCzrW8Qh1oAq7KAum4ZJHbYczXAcMx9O2SU5KDIrL0RC4NiW6KfbZREuBw3CYoXOswS7)SqnkzrW8Qh1M1nNStmkTtQrEHXn(x5rkilcMx9O2SU5KDIrPDsnWxd8BKVUobG1Qqs6vo89(twWAxUoTzHY)ELdA6vo89(twWnikHllwJy6v5NILj8GvbxmuDvgGwIryxdiwJiMEUtayXuN9fNuShi2LcifdxPNUypaPXGy(jiwMWdwfCXq1vzaIX68xl2TRnSflr5NIr4IreSIXbLyXqkwi2rCuJy6JbyfCRTy61jmIP3VEEn3fRuI1iiIX6Mt2jgTeJWUgqSgrm9CNaWIXIrSGRAXEGyxkGuSm3LYflr5NIr4IreSIXb1wwemV6rTzDZj7eJs7KAGVg43iFDDcaRvHKmyELf(Wa5fOsUutp4W47uEWQG)v6QmGnmXJdKA(Uqq2fRyCqTvEWYijHR5TFxii7hoQ5JGbyfSXqWCciWdom(gE98AUVHjECGutw3CYoXSHxpVM7BmKh1OUblu(3RC4wYI1iMEv(zF5ILj8GvbxmuDvgGwIryxdiwJiMEUtayXuN9fNuShi2Lcif7bingelM7I9Q0ualgRBozNye726J7vWiMEe)0sm9(1ZR5UwIri05GlgQ34CTeJWI7I1iIPpUv(TeRXIL4egXiSRbeRretp3jaSyLsS41xUyElggc2Pyevm2zGtb1wwemV6rTzDZj7eJs7KAGVg43iFDDcaRvHKmyELf(Wa5fOsUutc1dom(oLhSk4FLUkdydt84aPM3whgY(tzK7LBeCVcMFJFeqGhCy8n8651CFdt84aPMSU5KDIzdVEEn33yipQrDdwO8Vx5abe4bhgFZ6CW)kVX5ByIhhi1K1nNStmBwNd(x5noFJH8Og1nyHY)ELdeqGhCy8noU)BKpcUv(gM4XbsnzDZj7eZgh3)nYhb3kFJH8Og1nyHY)ELdeqa7mWPG6JGdMx9e81UCNPULSynIPxLFkgrfRXIL3yqmpWPGR0sSlfigHDnGynIy65obGfdY8m(LQYc87ILO8tX0h3RGrm9i(Tf7WzPeRuI5NGySqbIbzHrSeLFkwMWdwfCXq1vzaBzrW8Qh1M1nNStmkTtQb(AGFJ811jaSwfsYG5vw4ddKxGATl1uhgY(tzK7LBeCVcMFJFYIG5vpQnRBozNyuANudDTx9OvHKuhgY(tzK7L7ID)NfQrrabEGtbF7vo89(twWn0tRtwemV6rTzDZj7eJs7KACPGF5qUswemV6rTzDZj7eJs7KA84Dt(rUW3LfbZREuBw3CYoXO0oPgpaRaCg1KklcMx9O2SU5KDIrPDsn4v6PR(zUlY0CyCzrW8Qh1M1nNStmkTtQbsHHhVBszrW8Qh1M1nNStmkTtQrmmq54G)zbNllKfbZREu78olKdJN8XRjdTkKK5DwihgFtwkpggS2LRtwemV6rTZ7SqomU2j1OyWhH3GsRcj57cbzxm4JWBqTj7eJSqwSgXiIrmvNdIPk)k8QhLwIDVVeJfJyQZWDalgrWaXiUZgIbzHrSaXbSybhdb5DXyHYRjvm95xy8DXIHumIGbIrigdd2IPh9taNOuGy(zPelyE1JyLsSlfqkwItyeZpbXYJuqSZqjM(T(IfioGfJfkVMuX0NFHX31smfaIfVolSLfbZREuBvnPCizXG)0zdTkKKSU5KDIzxm4pD2yJHG8UMKW7cbzNOghWQp7S489LozXAetVk)SVCXYeuTeZpbXYJuqSm3LYfZXfOeZBXuNH7awSqjwEm3ftFCR8xZDLyXqkME)651CxjwOetxRu1JdBX0VXSAsftDgUdyX6rm9XTYFn3fRuIP8IZfletLhCUyPrnAjMQfRuInTlglW1Kkw86lxm9B93IremqmcXyyGyLsmVBXsargI5TyjcmogxmsGh3RjvSJ4OgX0hdWkqm95xy89TSiyE1JARQjLdANude(fgFxRcjjH6bhgFNYdwf8VsxLbSHjECGuZBRddz)PmY9Yn8651CNacExii7hoQ5JGbyfSXqWCn1HHS)ug5E5gb3k)1C)wYI1iMEv(PyzcQwI5NGy5rkiwp87IPod3bSsm9XTYFn3fZpdxSe9fNumDxUy(jKlw4ITKqsKIreSIXbXuEWYqPLy69RNxZDXkeXkxSe9fNuSeHYbXoIJAetFmaRaXyNbofe721g2IL4egX8tqS8ifet5b2vIXcLxtQy69RNxZDXsu(PyhXrnIPpgGvGybZRSWTelgsXAeXy9fwbILj8GvbxmuDvgWwS17cbbWWWaXEGNaGrm1z4oGRjvm9XTYFn3flr5NITKqsKIreSIXbLyXqk2sc5nfJiyfJdkXkLyQ8GZ1sS3Ll2scjrkMddPsmVf7bI9a3bSy1iwEJbXuLFfE1JsSB7NGyNv6jGfltqfJmYJuqSsPLy(jiwEJbXkxmoeJsmVteysLyljKe5T2YIG5vpQTQMuoODsnq4xy8DTkKKEWHX3P8Gvb)R0vzaByIhhi18DHGSF4OMpcgGvWgdbZ1826Wq2FkJCVCJGBL)AUR57cbzxSIXb1w5blJBCtciqhgY(tzK7L7uEWQG)v6QmaciqhgY(tzK7LB41ZR5(TKfbZREuBvnPCq7KAGG7vW8B8twSgX0RYpftFmaRQjvmclQrSyiflCX4qOCXiQyEGtbxPLyh51QvbMuSbasLyEl2de7sbKILO8tXoR0talMoC14YVlM3ILhzaIPUWGy37lXyXigs5I9A)uSAuEmUyh51QvbMujwnElwiMQMuoiM(yawvtQyewuZwmupWEnPILO8tX8tmaI5bofCLwIDKxRwfysX4qKfuI5NGy8oHy6WvJl)UyifNdyXWnhelgsXkLyxkGuSEeJ1nNStmID7yiflZDPCXYJmQjvm1fgeBAxmVflrOCqSJ4OgX0hdWkqm2zGtb1Telr5NI1yXsu(zF5IPpgGv1KkgHf1SLfbZREuBvnPCq7KA841QvbMuRcjzW8kl8HbYlqTwIsabbZRSWhgiVa1AxQjlu(3RCi5608DHGSrQjfWQFJ8rWTY3yiy(niQSynIDaFVMuX8wmDDZfJDg4uqjwJiM(T(IH0yXI5UFwtQyLAYmxSen2pfR8TyRxkqm)eYfluI5NWDXyDoSLfbZREuBvnPCq7KAum4ZJHbAvijFxiiBKAsbS63iFeCR8ngcMllcMx9O2QAs5G2j1G15G)vEJZLfRrm9Q8Z(Yfltq1sm9(1ZR5UyLsSlfqkwpIX6Mt2jMTy6v5NILjOAjME)651CxSsjwp87IDPasX8wmKIZfRgX8tqShpMmetPRDLyjoHrmKsDwtQyinwSqSJ4OgX0hdWkqmD4MPLy1g2I5NGy5rkiggc2jOeJWfJiyfJdkXExUykV4CXiBqnzMl2zKfele7ioQrm9XaScethUzBzrW8Qh1wvtkh0oPgWRNxZDTkKKeQhCy8DkpyvW)kDvgWgM4Xbsci4DHGSlwX4GAR8GLrscxtc9DHGSF4OMpcgGvWgdbZLfRrmclUlwJiM(4w5IvkXUuaPybIdyXcoxm9RjfWkXAeX0h3kxm2zGtbLyNrwqShaJyxkGuSyifZpbmiwPMmZflyELfetFCVcgX0J4Ny(z4IX6loPyPWa4WbXYBmSf7WzPeRuI1d)UyHyQ8GZflnQrSinQr5ILFX9shheZdCk4kTeluIryXDXAeX0h3kxSsnzMlM3TyvUUG5ix8TSiyE1JARQjLdANudCC)3iFeCRCTkKKeAW8QNncUxbZVXVDnFeELE6AMI7RH8hnSrW9ky(n(TXqEuJk56KfRrSJ8A1QatkwPe7sbKIfkX4DcX0HRgx(DXqkohWIfPrnkxmIkMh4uWvBX0Rtye7svtQy6JbyvnPIryrnAjw5zMsSqSCGSUYflnQrmVf7sbI5NGy1O8yCXoYRvRcmPyqwyelsJAuUyHyQAs5GyEGtbxlXaLoGvbNFxSeLFkgVtiwEOCaFFllcMx9O2QAs5G2j14XRvRcmPwfsswO8Vx5qY1rabbZRSWhgiVa1AxklwJyzcpyvWfdvxLbiwPe7sbKIL4egX8tadzMsSqSJ4OgX0hdWkqmD4MjwW8kli2TRnSfRh(DXsCcJyLlglgXEGyQZWDadK3Al2HZsjwPeletLhCUyElwoqwx5ILg1iwnIL3kxmv5xHx9O2Iri2jelpuoGVlghIrjM3jcmPsSlvnPIvUyjoHrSiBu84XHTy61jmIDPQjvmuD8Y9AsfJiyGyXqk2zKTMuXIP9talMh4uWfBGa)URLyLNzkXu8k9053f7bUdyX8wSlfiwMGkwItyelYgfpECqlXcLy(jiMcy9qkMh4uWfJSb1KzUypyaKYfdb35IPod3bCnPI5NGy5rnI5bof8TSiyE1JARQjLdANuJuEWQG)v6QmaTkKKVleK9dh18rWaSc2yiyobeOddz)PmY9Yn8651CNaccMxzHpmqEbQ1Uutp4W4BLoE5EnP)IbByIhhiLfbZREuBvnPCq7KAum4pD2qwemV6rTv1KYbTtQbc)cJVRvHKmwb4YHDIACaR(yiyNByIhhi1KqFxii7hoQ5JGbyfSXqWCnFxii7e14aw9XqWo3yiyUSiyE1JARQjLdANudeCR8xZDzrW8Qh1wvtkh0oPgSGZ)bZRE(8s5AnroKmVZc5W4YIG5vpQTQMuoODsnkg85XWaQtDkfa]] )


end
