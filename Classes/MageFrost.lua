-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindUnitBuffByID = ns.FindUnitBuffByID


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 64, true )

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
        focus_magic = 22445, -- 321358
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
        burst_of_cold = 633, -- 206431
        chilled_to_the_bone = 66, -- 198126
        concentrated_coolness = 632, -- 198148
        dampened_magic = 57, -- 236788
        deep_shatter = 68, -- 198123
        frostbite = 67, -- 198120
        ice_form = 634, -- 198144
        kleptomania = 58, -- 198100
        netherwind_armor = 3443, -- 198062
        prismatic_cloak = 3532, -- 198064
    } )

    -- Auras
    spec:RegisterAuras( {
        alter_time = {
            id = 110909,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        active_blizzard = {
            duration = function () return 8 * haste end,
            max_stack = 1,
            generate = function( t )
                if query_time - action.blizzard.lastCast < 8 * haste then
                    t.count = 1
                    t.applied = action.blizzard.lastCast
                    t.expires = t.applied + ( 8 * haste )
                    t.caster = "player"
                    return
                end

                t.count = 0
                t.applied = 0
                t.expires = 0
                t.caster = "nobody"
            end,
        },
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
        blizzard = {
            id = 12486,
            duration = 3,
            max_stack = 1,
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
            max_stack = 5,
        },
        chilled = {
            id = 205708,
            duration = 8,
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
        focus_magic = {
            id = 321358,
            duration = 1800,
            max_stack = 1,
            friendly = true,
        },
        focus_magic_buff = {
            id = 321363,
            duration = 10,
            max_stack = 1,
        },
        freezing_rain = {
            id = 270232,
            duration = 12,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 10,
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
        frozen_orb_snare = {
            id = 289308,
            duration = 3,
            max_stack = 1,
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
            duration = 60,
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
                stack = function() return state.incanters_flow_stacks end,
                stacks = function() return state.incanters_flow_stacks end,
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
    } )


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
        } ),

        blizzard = setmetatable( {}, {
            __index = setfenv( function( t, k )
                if k == "remains" then return buff.active_blizzard.remains end
            end, state )
        } )
    } )

    spec:RegisterStateTable( "frost_info", {
        last_target_actual = "nobody",
        last_target_virtual = "nobody",
        watching = true,

        real_brain_freeze = false,
        virtual_brain_freeze = false
    } )

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            if spellID == 44614 then
                frost_info.real_brain_freeze = FindUnitBuffByID( "player", 190446 ) ~= nil
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return frost_info.virtual_brain_freeze
    end )


    spec:RegisterStateTable( "rotation", setmetatable( {},
    {
        __index = function( t, k )
            if k == "standard" and state.settings.rotation == "standard" then return true
            elseif k == "no_ice_lance" and state.settings.rotation == "no_ice_lance" then return true
            elseif k == "frozen_orb" and state.settings.rotation == "frozen_orb" then return true end
        
            return false
        end,
    } ) )


    spec:RegisterStateTable( "incanters_flow", {
        changed = 0,
        count = 0,
        direction = 0,
        
        startCount = 0,
        startTime = 0,
        startIndex = 0,

        values = {
            [0] = { 0, 1 },
            { 1, 1 },
            { 2, 1 },
            { 3, 1 },
            { 4, 1 },
            { 5, 0 },
            { 5, -1 },
            { 4, -1 },
            { 3, -1 },
            { 2, -1 },
            { 1, 0 }
        },

        f = CreateFrame("Frame"),
        fRegistered = false,

        reset = setfenv( function ()
            if talent.incanters_flow.enabled then
                if not incanters_flow.fRegistered then
                    -- One-time setup.
                    incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                    incanters_flow.f:SetScript( "OnEvent", function ()
                        -- Check to see if IF changed.
                        if state.talent.incanters_flow.enabled then
                            local flow = state.incanters_flow
                            local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                            local now = GetTime()
                
                            if name then
                                if count ~= flow.count then
                                    if count == 1 then flow.direction = 0
                                    elseif count == 5 then flow.direction = 0
                                    else flow.direction = ( count > flow.count ) and 1 or -1 end

                                    flow.changed = GetTime()
                                    flow.count = count
                                end
                            else
                                flow.count = 0
                                flow.changed = GetTime()
                                flow.direction = 0
                            end
                        end
                    end )

                    incanters_flow.fRegistered = true
                end

                if now - incanters_flow.changed >= 1 then
                    if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                        incanters_flow.direction = 1
                        incanters_flow.changed = incanters_flow.changed + 1
                    elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                        incanters_flow.direction = -1
                        incanters_flow.changed = incanters_flow.changed + 1
                    end
                end
    
                if incanters_flow.count == 0 then
                    incanters_flow.startCount = 0
                    incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                    incanters_flow.startIndex = 0
                else
                    incanters_flow.startCount = incanters_flow.count
                    incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                    incanters_flow.startIndex = 0
                    
                    for i, val in ipairs( incanters_flow.values ) do
                        if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                    end
                end
            else
                incanters_flow.count = 0
                incanters_flow.changed = 0
                incanters_flow.direction = 0
            end
        end, state ),
    } )


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        frost_info.last_target_virtual = frost_info.last_target_actual
        frost_info.virtual_brain_freeze = frost_info.real_brain_freeze

        incanters_flow.reset()
    end )


    spec:RegisterTotem( "rune_of_power", 609815 )

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
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or 1 end,
            cooldown = function () return talent.shimmer.enabled and 20 or 15 end,
            recharge = function () return talent.shimmer.enabled and 20 or 15 end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
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
                applyDebuff( "target", "blizzard" )
                applyBuff( "active_blizzard" )
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

            velocity = 30,

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
                    frost_info.virtual_brain_freeze = true
                else
                    frost_info.virtual_brain_freeze = false
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )
            end,
        },


        focus_magic = {
            id = 321358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135754,

            talent = "focus_magic",
            
            usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
            handler = function ()
                applyBuff( "focus_magic" )
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
                applyBuff( "frozen_orb" )
                applyDebuff( "target", "frozen_orb_snare" )
            end,

            copy = 198149
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

            velocity = 40,

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

                if buff.fingers_of_frost.up or debuff.frozen.up then
                    if talent.chain_reaction.enabled then addStack( "chain_reaction", nil, 1 ) end
                    if talent.thermal_void.enabled and buff.icy_veins.up then buff.icy_veins.expires = buff.icy_veins.expires + 1 end
                end

                removeStack( "fingers_of_frost" )

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

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

            handler = function ()
                applyBuff( "mirror_image", nil, 3 )
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
            channeled = true,
            cooldown = 75,
            gcd = "spell",

            channeled = true,

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1698700,

            talent = "ray_of_frost",

            start = function ()
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

            debuff = "dispellable_curse",
            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
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

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
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
            nomounted = true,

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

        potion = "potion_of_focused_resolve",

        package = "Frost Mage",
    } )


    spec:RegisterSetting( "rotation", "standard", {
        name = "Preferred Priority",
        desc = "This sets the |cFFFFD100rotation.X|r value, selecting between one of three integrated SimC builds.",
        type = "select",
        width = 1.5,
        values = {
            standard = "Standard",
            no_ice_lance = "No Ice Lance",
            frozen_orb = "Frozen Orb"
        }
    } )

    
    spec:RegisterPack( "Frost Mage", 20200926, [[dSeTJbqiqr9iQG2ek0NOcrJsrKtbkyvGIu8kcywOGBPiK2fP(fHYWOc1XavTmQaptrutJqIRPiyBkc13ueIXrfsDocjzDGIKyEGcDpcAFeOoibs1crrEiOivteuKsxKkKSrcP(ivimsqrs6KeiSsfYmjqkUjbsPDII6NeiQHsGilfuepvLMkOYvbfj1xjKu7fXFjzWQ6WclwfpgPjdYLH2mv9zf1OPIoTOvdks8AcvZMOBRGDl53snCuYYbEoQMoLRtL2oO03rPgpbsopHy9ksZxHA)knbEcCKluyiHzh4yh4yhlQCWeRHhEh7ONm5AIWcjxwbv8ygj3kgqYv0GMB7lOnMrYLviISdicCKlVDbuKCDAglomvetS50C6E00EqmEo4kdl7IccVjgphOIrUh3uAcIICixOWqcZoWXoWXowu5Gjwdp8o2r7arHCdxZzdi3BoatNCDMqqyroKleYPKRd3xqBmJ7lAqZTDKd3)ISmC4GG9DWeZW(oWXoWXKRm5gNah5ICowuKRAWHahHz4jWrUyfhjcryICPG0qqgK7X171a3cvTxXQzJanuZU2NX9HWJR3RzfuXrivsrnuZU2F849dQLWIkSWHe57l49Nm5gul7IC9n1LJqQykcsdvhmgigHzhqGJCXkoseIWe5sbPHGmi3GAjSOclCir((W4(tyFg3hcpUEVMvqfhHujf1qn7AFg3N2TeQzxApONILQbhnahIS47l49NW(mUpmVFqTSlTh0tXs1GJolLxMZoT9zC)zq7wqQOrTh0tXs1GJgGdrw89fUVJj3GAzxK7ao0aruTxjDPjKccGXaNyeMNmboYfR4irictKlfKgcYGCzbqyvZuin8ApONILQbN9hpE)zq7wqQOrTh0tXs1GJgGdrw89f8(tGCdQLDrUhz3qQ2RmNOclCqeIrywuiWrUyfhjcryICPG0qqgK7X171a3cvTxXQzJanuZU2NX9HWJR3RzfuXrivsrnuZU2F849dQLWIkSWHe57l49Nm5gul7ICz5csViznRoYGBeJW8eiWrUyfhjcryICPG0qqgK7X171a3cvTxXQzJanuZU2NX9HWJR3RzfuXrivsrnuZU2F849dQLWIkSWHe57l49Nm5gul7ICbjlwsuLLIZkOiXimpXe4ixSIJeHimrUb1YUixAxuSmqyiKYlJbKCPG0qqgK7X171a3cvTxXQzJanuZU2NX9HWJR3RzfuXrivsrnuZUixzwOIcrUtmXimpriWrUyfhjcryICPG0qqgK7X171a3cvTxXQzJanuZU2NX9HWJR3RzfuXrivsrnuZUi3GAzxKladwznR8Yya5eJWSJMah5IvCKieHjYLcsdbzqUhxVxdqQ4sKZv(gqrTllYnOw2f5AorLBDA3cs5BafjgHzrfboYfR4irictKlfKgcYGCpUEVg4wOQ9kwnBeOHA21(mUpeEC9EnRGkocPskQHA21(mUpTBjuZU0EqpflvdoAaoezX3hg3xu2F849dQLWIkSWHe57l49Nm5gul7ICz3ajeSywkaY7kkksmIrUiNJff5e4imdpboYfR4irictKlfKgcYGCpUEVg4wOQ9kwnBeOHA21(JhVFqTewuHfoKiFFbV)Kj3GAzxKRVPUCesftrqAO6GXaXim7acCKlwXrIqeMixkineKb5gulHfvyHdjY3hg3Fc7Z4(tA)JR3RtAsLixZTGk((WOW9HF)XJ3hM33cjwMEwg0mKkoRuCuJvCKi0(WW(mUpTBjuZU0EqpflvdoAaoezX3xW7dVJ3NX9N0(W8(G2cl7sZTOGca0(JhVpmVFqTSlTh0tXs1GJolLxMZoT9zC)zq7wqQOrTh0tXs1GJgGdrw89fUVJ3hgi3GAzxK7ao0aruTxjDPjKccGXaNyeMNmboYfR4irictKlfKgcYGCN0(wiXY0ZYGMHuXzLIJASIJeH2NX9pUEVoPjvICn3cQ47lC)jSpJ7pP9pUEV(aISuEaItrnadQT)4X7ZcGWQMPqA414PRtlT9HH9HH9hpE)jT)K2pOwclQWchsKVVG3FY7pE8(W8(wiXY0ZYGMHuXzLIJASIJeH2hg2NX9N0(SaiSQzkKgETh0tXs1GZ(JhV)mODliv0O2d6PyPAWrdWHil((cE)jSpmSpmqUb1YUi3JSBiv7vMtuHfoicXimlke4ixSIJeHimrUuqAiidY9469AGBHQ2Ry1SrGgQzx7pE8(b1syrfw4qI89f8(tMCdQLDrUSCbPxKSMvhzWnIryEce4ixSIJeHimrUuqAiidY9469AGBHQ2Ry1SrGgQzx7pE8(b1syrfw4qI89f8(tMCdQLDrUGKfljQYsXzfuKyeMNycCKlwXrIqeMi3GAzxKlTlkwgimes5LXasUuqAiidY9469AGBHQ2Ry1SrGgQzxKRmlurHi3jMyeMNie4ixSIJeHimrUuqAiidY9469AGBHQ2Ry1SrGgQzxKBqTSlYfGbRSMvEzmGCIry2rtGJCXkoseIWe5sbPHGmi3JR3RbivCjY5kFdOO2Lf5gul7ICnNOYToTBbP8nGIeJWSOIah5IvCKieHjYLcsdbzqUhxVxdClu1EfRMnc0qn7A)XJ3pOwclQWchsKVVG3FYKBqTSlYLDdKqWIzPaiVROOiXig5YZAwIkUffuaGiWrygEcCKlwXrIqeMixkineKb5AHeltJNUoT00yfhjcTpJ7ZcGWQMPqA414PRtlT9zC)jTpmVVfsSm9SmOzivCwP4OgR4irO9hpE)JR3RtAsLixZTGk((W4(IY(JhV)X171hqKLYdqCkQbyqT9HbYnOw2f56LUaGieJWSdiWrUyfhjcryICPG0qqgKRfsSm9SmOzivCwP4OgR4irO9zCFwaew1mfsdVEwg0mKkoRuCCFg3)4696diYs5biof1amOg5gul7IC9sxaqeIryEYe4ixSIJeHimrUuqAiidYLfaHvntH0WR9GMBNwA7Z4(hxVxFarwkpaXPOgGb12NX9N0(W8(wiXY0ZYGMHuXzLIJASIJeH2F849pUEVoPjvICn3cQ47dJ7lk7ddKBqTSlY1lDbarigHzrHah5IvCKieHjYLBGKAeMHNCdQLDrU0qkvb1YUuYKBKRm5MQIbKCrohlkYjgH5jqGJCdQLDrUEqpflvdoKlwXrIqeMigH5jMah5IvCKieHjYLcsdbzqUb1syrfw4qI89f8(oy)XJ3pOwclQWchsKVVG3h(9zCFAWnLLd4(c33X7Z4(hxVx7ZAgbCv7vEqZnnadQTpmUVdi3GAzxK7rMtNgaiIryEIqGJCXkoseIWe5sbPHGmi3JR3R9znJaUQ9kpO5MgGb1i3GAzxKBsrLmkksmcZoAcCKBqTSlYL2dOP4wdgixSIJeHimrmcZIkcCKBqTSlYfpDDAPrUyfhjcryIyeMH3Xe4ixSIJeHimrUuqAiidYfM3pOw2L2d6PyPAWrNLYlZzN2(mU)mODliv0O2d6PyPAWrdWHil((c33XKBqTSlYfeIOAVYdAUrmcZWdpboYfR4irictKlfKgcYGCPb3uwoG7lCFhV)4X7hulHfvyHdjY3xW7dp5gul7ICpYC60aarmcZW7acCKlwXrIqeMixkineKb5EC9E9bezP8aeNIAaguB)XJ3NfaHvntH0WRXtxNwA7pE8(b1syrfw4qI89f8(WVpJ7BHeltZzjtZYAwLuuJvCKie5gul7ICNLbndPIZkfhjgXixEwZsu1GdbocZWtGJCXkoseIWe5YnqsncZWtUb1YUixAiLQGAzxkzYnYvMCtvXasUiNJff5QgCigHzhqGJCdQLDrUEqpflvdoKlwXrIqeMigH5jtGJCXkoseIWe5sbPHGmixwaew1mfsdVgpDDAPTpJ7FC9E9bezP8aeNIAaguJCdQLDrUEPlaicXimlke4ixSIJeHimrUuqAiidYnOwclQWchsKVVG33b7pE8(b1syrfw4qI89f8(WVpJ7tdUPSCa3x4(oMCdQLDrUhzoDAaGigH5jqGJCXkoseIWe5sbPHGmi3JR3R9znJaUQ9kpO5MgGb12NX9PDlHA2L2d6PyPAWrdWHil((cE)jS)4X7FC9ETpRzeWvTx5bn30amO2(c33bKBqTSlYnPOsgffjgH5jMah5IvCKieHjYLcsdbzqU0GBklhW9fUVJj3GAzxK7rMtNgaiIryEIqGJCXkoseIWe5sbPHGmixwaew1mfsdVgpDDAPrUb1YUixV0faeHyeMD0e4ixSIJeHimrUuqAiidY94696diYs5biof1amO2(mU)K2NfaHvntH0WR9GMBNwA7pE8(q4X171ScQ4iKkPOgGdrw89f8(OGcPUgQSCa3xG9dQLDPtkQKrrrTbcyrPYYbCFyGCdQLDrUEPlaicXimlQiWrUb1YUixApGMIBnyGCXkoseIWeXimdVJjWrUb1YUix801PLg5IvCKieHjIrygE4jWrUyfhjcryICdQLDrUGqev7vEqZnYnldbaxwMk9K7X171(SMrax1ELh0CtdWGAcDa5MLHaGlltLddiuggsUWtUuqAiidYfcpUEVMvqfhHujf1USigHz4DaboYnOw2f5EK50PbaICXkoseIWeXig5AHeltbAwe4imdpboYfR4irictKlfKgcYGCpUEVg4wOQ9kwnBeOHA21(mUVfsSm9SmOzivCwP4OgR4irO9zC)JR3RtAsLixZTGk((c3Fc7Z4(tA)JR3RpGilLhG4uudWGA7pE8(wiXY04PRtlnnwXrIq7Z4(0ULqn7sJNUoT00aCiYIVpmUpn4MYYbCFyGCdQLDrUa3cvTxXQzJaIry2be4ixSIJeHimrUuqAiidY9469AGBHQ2Ry1SrGgQzx7Z4(W8(wiXY0ZYGMHuXzLIJASIJeH2NX9N0(wiXY04PRtlnnwXrIq7Z4(0ULqn7sJNUoT00aCiYIVpmUpn4MYYbC)XJ33cjwMM2dOP4wdg0yfhjcTpJ7t7wc1SlnThqtXTgmOb4qKfFFyCFAWnLLd4(JhVVfsSmnier1ELh0CtJvCKi0(mUpTBjuZU0Gqev7vEqZnnahIS47dJ7tdUPSCa3F849PodWmYvEqqTSRqUVG3hETOAFyGCdQLDrUa3cvTxXQzJaIrmYLN1SejWrygEcCKlwXrIqeMixkineKb5s7wc1SlDsrv1WgAagqISpJ7dHhxVxZoldbCf1zkLAxwKBqTSlYnPOQAydIry2be4ixSIJeHimrUuqAiidYf0wyzxAUffuaGixUbsQrygEYnOw2f5sdPuful7sjtUrUYKBQkgqYLN1SevClkOaarmcZtMah5IvCKieHjYLcsdbzqUG2cl7sxTkPOsgffjxUbsQrygEYnOw2f5sdPuful7sjtUrUYKBQkgqYLN1SevvRKrrrIrywuiWrUyfhjcryICPG0qqgKlOTWYU0EqpflvdoKl3aj1imdp5gul7ICPHuQcQLDPKj3ixzYnvfdi5YZAwIQgCigH5jqGJCdQLDrUjfvvdBqUyfhjcryIyeMNycCKlwXrIqeMi3GAzxKRLqi3AWGI2qOGICPG0qqgK7X171jvefSywCnuZU2NX9pUEVg4wOQ9kwnBeOHA2f5wXasUwcHCRbdkAdHckIryEIqGJCXkoseIWe5gul7ICPIqLTb6kPQJm4g5sbPHGmi3JR3RtQikyXS4AOMDTpJ7FC9EnWTqv7vSA2iqd1SlYf9EKAQkgqYLkcv2gORKQoYGBeJWSJMah5gul7IC9GMBNwAKlwXrIqeMigHzrfboYfR4irictKBqTSlYLgsPkOw2LsMCJCLj3uvmGK7qdloGLrmcZW7ycCKBqTSlYnPOsgffjxSIJeHimrmIrUdnS4awgbocZWtGJCXkoseIWe5sbPHGmi3HgwCaltdLClkkUVG3hEhtUb1YUi3JmlXjgHzhqGJCXkoseIWe5sbPHGmi3JR3RtkQ8Yg5AOMDrUb1YUi3KIkVSroXig5YcG0E4egbocZWtGJCdQLDrUbGgfQYYqPePg5IvCKieHjIry2be4i3GAzxKl7WqGcL4awwijxSIJeHimrmcZtMah5IvCKieHjYTIbKCJPCNbi4kFxMQ9kwnBeqUb1YUi3yk3zacUY3LPAVIvZgbeJWSOqGJCdQLDrUdja0avoeZi5IvCKieHjIryEce4i3GAzxKlR2YUixSIJeHimrmcZtmboYnOw2f56bn3oT0ixSIJeHimrmIrUrJe4imdpboYnOw2f56b9uSun4qUyfhjcryIyeMDaboYnOw2f5EK50PbaICXkoseIWeXimpzcCKlwXrIqeMixkineKb5cZ7dAlSSlTh0tXs1Gd5YnqsncZWtUb1YUixAiLQGAzxkzYnYvMCtvXasUiNJff5eJWSOqGJCXkoseIWe5sbPHGmixqBHLDP9GEkwQgCixUbsQrygEYnOw2f5sdPuful7sjtUrUYKBQkgqYf5CSOix1GdXimpbcCKBqTSlYL2dOP4wdgixSIJeHimrmcZtmboYnOw2f5MuuvnSb5IvCKieHjIryEIqGJCXkoseIWe5sbPHGmixwaew1mfsdVgpDDAPT)4X7FC9E9bezP8aeNIAaguBFg3Fs7ZcGWQMPqA41EqZTtlT9zC)jT)X171jnPsKR5wqfFFyCFrz)XJ3hM33cjwMEwg0mKkoRuCuJvCKi0(WW(JhVplacRAMcPHxpldAgsfNvkoUpmqUb1YUixV0faeHyeMD0e4ixSIJeHimrUuqAiidY9469AFwZiGRAVYdAUPbyqnYnOw2f5MuujJIIeJWSOIah5gul7ICbHiQ2R8GMBKlwXrIqeMigHz4DmboYnOw2f5INUoT0ixSIJeHimrmcZWdpboYnOw2f5oldAgsfNvkosUyfhjcryIyeMH3be4i3GAzxKlTlu1EfTLqKlwXrIqeMigHz4NmboYfR4irictKBqTSlY1siKBnyqrBiuqrUuqAiidY94696KkIcwmlUgQzx7Z4(hxVxdClu1EfRMnc0qn7ICRyajxlHqU1GbfTHqbfXimdVOqGJCXkoseIWe5gul7ICPIqLTb6kPQJm4g5sbPHGmi3JR3RtQikyXS4AOMDTpJ7FC9EnWTqv7vSA2iqd1SlYf9EKAQkgqYLkcv2gORKQoYGBeJWm8tGah5gul7IC9GMBNwAKlwXrIqeMigHz4NycCKlwXrIqeMi3GAzxKlnKsvqTSlLm5g5ktUPQyaj3HgwCalJyeMHFIqGJCdQLDrUjfvYOOi5IvCKieHjIrmYL2TeQzxCcCeMHNah5IvCKieHjYLcsdbzqUW8(G2cl7s7b9uSun4S)4X7t7wc1SlTh0tXs1GJgGdrw89HX9Na5gul7ICNDdaugLQ9QykcAZjXim7acCKBqTSlYfeqzuMIZkaItUyfhjcryIyeMNmboYnOw2f5cHH580GcjxSIJeHimrmcZIcboYfR4irictKlfKgcYGCH59bTfw2L2d6PyPAWz)XJ3N2TeQzxApONILQbhnahIS47dJ7pbYnOw2f5MuruWIzXjgH5jqGJCdQLDrUdja0avoeZi5IvCKieHjIryEIjWrUb1YUi3HeaAax1EL1GbSmYfR4iricteJW8eHah5gul7IC5otVL1SIvZgbKlwXrIqeMigHzhnboYfR4irictKlfKgcYGCpUEVg4wOQ9kwnBeOHA21(mU)K2NfaHvntH0WR9GEkwQgC2F849TamJM2YbuzTckX9f8(W749fyFAWnLLd4(mUVfGz00woGkRvqjUpmUVdC8(Wa5gul7ICbUfQAVIvZgbeJWSOIah5IvCKieHjYLcsdbzqUwiXY0a3cvTxXQzJanwXrIq7Z4(b1syrfw4qI89fUp87Z4(0ULqn7sdClu1EfRMnc0ExPubqQZamJklhW9HX9PDlHA2L2d6PyPAWrdWHilo5gul7ICPHuQcQLDPKj3ixzYnvfdi5AHeltbAweJWm8oMah5IvCKieHjYLcsdbzqUSaiSQzkKgEDsfrblMfF)XJ33cWmAAlhqL1kOe3hg3FYoMCdQLDrUSAl7IyeMHhEcCKlwXrIqeMi3GAzxK7jKOpbO6aII6KCPG0qqgKlmVVfsSm9SmOzivCwP4OgR4irO9hpE)JR3RpGilLhG4uudWGA7Z4(SaiSQzkKgE9SmOzivCwP4i5wXasUNqI(eGQdikQtIrygEhqGJCdQLDrUUCuLgoWjxSIJeHimrmcZWpzcCKBqTSlY9i7gs5DbIqUyfhjcryIyeMHxuiWrUb1YUi3dc4iq8SMjxSIJeHimrmcZWpbcCKBqTSlYvMZonUcMIl08awg5IvCKieHjIryg(jMah5gul7IC9japYUHixSIJeHimrmcZWpriWrUb1YUi3OOi3aHurdPKCXkoseIWeXimdVJMah5gul7ICpXSQ9kdKuX5KlwXrIqeMigXixEwZsuvTkLe4imdpboYfR4irictKlfKgcYGCTqILPXtxNwAASIJeH2NX9zbqyvZuin8A801PL2(mU)X171hqKLYdqCkQbyqnYnOw2f56LUaGieJWSdiWrUyfhjcryICPG0qqgKllacRAMcPHxpldAgsfNvkoUpJ7FC9E9bezP8aeNIAaguJCdQLDrUEPlaicXimpzcCKlwXrIqeMixUbsQrygEYnOw2f5sdPuful7sjtUrUYKBQkgqYf5CSOiNyeMffcCKBqTSlY1d6PyPAWHCXkoseIWeXimpbcCKlwXrIqeMixkineKb5gulHfvyHdjY3xW77G9hpE)GAjSOclCir((cEF43NX9H59TqILP5SKPzznRskQXkoseICdQLDrUhzoDAaGigH5jMah5gul7ICP9aAkU1GbYfR4iricteJW8eHah5IvCKieHjYLcsdbzqUhxVxN0KkrUMBbv89fU)e2NX9H59pUEV(aISuEaItrnadQrUb1YUix801PLgXim7OjWrUyfhjcryICPG0qqgK7X171hqKLYdqCkQbyqT9zC)jT)X171(SMrax1ELh0CtdWGA7pE8(SaiSQzkKgETx6caISpmSpJ7pP9pUEVoPjvIC9qiOuClOIV)eD)JR3RtAsLixZTGk((WW(W0SFqTSlTh0C70stJckK6AOYYbCFb2pOw2LEwg0mKkoRuCutdUPSCa3xG9dQLDPNLbndPIZkfh1giGfLklhW9HX9ZIgLHaUYlB2klhqL16jOJsK9zC)JR3RhWHgiIQ9kPlnHuqamg4AOMDrUb1YUi3KIkzuuKyeMfve4ixSIJeHimrUuqAiidY94696diYs5biof1amO2(JhVplacRAMcPHxJNUoT02F849TqILPZIgLHaUYlB2ASIJeH2NX9Pb3uwoG7lW(giGfLklhW9f8(zrJYqax5LnBLLdOYA9e0US2NX9Pb3uwoG7lW(giGfLklhW9HX9ZIgLHaUYlB2klhqL1Arrd1SlYnOw2f5oldAgsfNvkosmIrUqOpCLgbocZWtGJCdQLDrU02TmeWzHsj5IvCKieHjIry2be4ixSIJeHimrUuqAiidYLfaHvntH0WR9sxaqK9zCFyE)JR3R9znJaUQ9kpO5MgGb1i3GAzxKBsrLmkksmcZtMah5IvCKieHjYnOw2f5sdPuful7sjtUrUYKBQkgqYL2TeQzxCIrywuiWrUyfhjcryICPG0qqgKBqTewuHfoKiFFbV)K3NX9TqILP9aeNM1ScezPXkoseA)XJ3pOwclQWchsKVVG3xui3GAzxKlnKsvqTSlLm5g5ktUPQyaj3OrIryEce4ixSIJeHimrUb1YUixAiLQGAzxkzYnYvMCtvXasU8SMLiXigXixyrap7IWSdCSdCSJfvoEYKl7auznZjxbXaRgyi0(W7G9dQLDTVm5gxVJixwG2NsKCD4(cAJzCFrdAUTJC4(xKLHdheSVdMyg23bo2boEhTJC4(okbfsDneA)d6BaUpThoHT)bNZIR3xqNsrwgF)QRjQZam4DL7hul7IVFxsr07ihUFqTSlUMfaP9WjmHEzWfFh5W9dQLDX1SaiThoHjGqX8DdTJC4(b1YU4AwaK2dNWeqOyH78awwyzx7OGAzxCnlas7HtyciuSaqJcvzzOuIuBhful7IRzbqApCctaHIXDhg6sXomeOqjoGLfYDKd3pOw2fxZcG0E4eMacfJxblUZ2uClm(okOw2fxZcG0E4eMacfZLJQ0WbgQyafgt5odqWv(Umv7vSA2iyhful7IRzbqApCctaHInKaqdu5qmJ7OGAzxCnlas7HtyciumwTLDTJcQLDX1SaiThoHjGqX8GMBNwA7ODuqTSlUqA7wgc4SqPCh5W9fe(9nN4(dXmUVZGVVOBrVF4neSpn4wwZ7Nf3IY2x0sxaqeg2NnUpnQ9HqziY(MtCFbbf3xqtuuC)OG23LJ73MteSVZC25(SazdstK9dQLDXW(PF)a2iLXrI6DuqTSlUacflPOsgffzi9czbqyvZuin8AV0faeHry(469AFwZiGRAVYdAUPbyqTDuqTSlUacfJgsPkOw2LsMCJHkgqH0ULqn7IVJcQLDXfqOy0qkvb1YUuYKBmuXakmAKH0lmOwclQWchsKl4jZOfsSmThG40SMvGilnwXrIqJhhulHfvyHdjYfSOSJC4(W5e33cWmA7Bobi3zlH2p5LJ02hfub107ZeASrS2FYt0jSVfGz04mSV5e3hk9EeGff57FqJnI1(MtC)lC7hf0(c6TJA)GAzx7ltUX3pa4(GWCIG95dHuQ3roCFyQ2Sryrad7lAaItZAEFysK1(SaOhb89D5znVVGE7O2pOw21(YKB7Z7UqW(bF)02)Gf6tJV)madtkY(EqpSV5e33zo7CFwGSbPjY(mjZPtda0(b1YU07OGAzxCbekgnKsvqTSlLm5gdvmGc5znlXD0oYH7lQtZz7A77iUmSVJ601PL2(jF)qYoeHVp3zygcqi9(I60CUVJ4YW(oQtxNwA7N895odZqacTF63pT9z3UsO9zhCd3NjqK1(IgG4uCFQZamJ7pPuJ69z7eR9nN4oYH7peZ4(ClagFFAWTSM33rD660sBF2P5CFMarw7lAaItX9dQLWIWW(nyF2oXA)dkB27lk7liOjvI89Nu633rD660sB)KVpn42(SDI1(MtC)Hyg33zW3xuMOtyFbbnPsKZWoYH7NMJKV)bndb7B9(UCCFZjUptGiR9fnaXP4(EqpSFA731(oczqZqU)Lvkocd6DuqTSlUMN1SevClkOaajGqV0faeHH0l0cjwMgpDDAPPXkoseIrwaew1mfsdVgpDDAPX4KGzlKyz6zzqZqQ4SsXrnwXrIqJhFC9EDstQe5AUfuXHrrz84JR3RpGilLhG4uudWGAWWoYH77iKbnd5(xwP44(jF)qYoeHVp3zygcqi9okOw2fxZZAwIkUffuaGeqOx6caIWq6fAHeltpldAgsfNvkoQXkoseIrwaew1mfsdVEwg0mKkoRuCKXJR3RpGilLhG4uudWGA7ihUVOonNTRTVJ4YW(MtC)Hyg3hMIl323ajY33695odZqW(bF)HOezFrdAUDAPX3p47ZQ588ir9(I60CUVJ4YW(MtC)Hyg3VlPi7ZDgMHa((Ig0C70sBFZzy7ZUDLq7ihUplxBFZjoSFy7d)eDY7liOjvI7ZTGkoxVpmTP3JaSO4(h0yJyTp3zygcYAEFrdAUDAPTp70CUp8t0jVVGGMujY3pkO9HFIkk7liOjvI89t((8Hqkzy)JRTp8t0jVVHfeFh5W9TE)dU)bndb7N1(dna3NNMByzx89NK5e33zo7eb77iU7dfdXmUFYzyFZjU)qdW9tBFjgfFFRzhai((WprNmmO3x0nGM18(CNHziy)U2x0GMBNwA7N895wkL7ihUFSpFiKY9NJSyyFEVFY3VABFAaYAE)40U2(IUfTEFbbf3xqtuuC)KVV19(SXq89TEF2baeLTpekdrYAEFMarw7lAaItX9fT0faerVJcQLDX18SMLOIBrbfaibe6LUaGimKEHSaiSQzkKgETh0C70sJXJR3RpGilLhG4uudWGAmojy2cjwMEwg0mKkoRuCuJvCKi04XhxVxN0KkrUMBbvCyuuGHDuqTSlUMN1SevClkOaajGqAiLQGAzxkzYng4giPMq4zOIbuiY5yrr(okOw2fxZZAwIkUffuaGeqOh0tXs1GZoYH7lQtZ5(IgG40SM3hMezTFuq7h2(sm42(oyFlaZOXzyFMK50PbaA)cri((wV)b33LJq7ZonN77mNDIG9zbYgKMi7B9(dH44(CxaUViT7(0O23N2(N2CUFwClkBFMK50PbaIVJC4(zz9(X(8SML4(IgG40SM3hMezP3)AbWYAEF2P5CFZjaX9TamJgNH9zsMtNgaO9LyalY33CI7lB27ZcKninr23Nsjc2h0sC)OG2p577YrO97AFA3sOMDT)KIcAFykUCB)Hq8SM3roCFUla3VABFR3NDWnCFMarw7lAaItX9PodWmYHH9zNMZ9BW(StZz7A7lAaItZAEFysKLEhful7IR5znlrf3Ickaqci8iZPtdaedPxyqTewuHfoKixWoy84GAjSOclCirUGHNrAWnLLdOqhZ4X171(SMrax1ELh0CtdWGAWOd2roCF4aIK18(wVpRUL7tDgGzKVF73x0TO333G9JseZzwZ7N8YrA7ZUbMZ9ttVpm1CCFZjoSFW33CIISpThq9okOw2fxZZAwIkUffuaGeqysrLmkkYq6fEC9ETpRzeWvTx5bn30amO2okOw2fxZZAwIkUffuaGeqiThqtXTgmSJcQLDX18SMLOIBrbfaibeINUoT02roCFysiY(TFFrdAUTFY33LJq7hEdb7hs5(IoRzeW3V97lAqZT9PodWmY33zalU)bXAFxocTFuq7BoraUFYlhPTFqTewCFrd6PyTVGm4SV5mS9PTReA)zSqqy4(dna17ihUpCot((jF)UKISFSpFiKY9NJS2pMJS42(dUslzjX9TamJgNH9d((WKqK9B)(Ig0CB)KxosBFR79Zbwb18Us9okOw2fxZZAwIkUffuaGeqiier1ELh0CJH0leMdQLDP9GEkwQgC0zP8YC2PX4mODliv0O2d6PyPAWrdWHilUqhVJC4(mjZPtda0(jFFxocTFW3x2S3NfiBqAISVpLseSFmhzXT9DW(waMrJR3xu7eR9D5znVVObionR59HjrwmSFAos((X(diu6oS)CK1(wVVlh33CI7Nf3IY2NjzoDAaG2hHfRDKd3pMJS42(X(8SML4(waMrJH9rolKMHukY(StZ5(YM9(db3qGi6DuqTSlUMN1SevClkOaajGWJmNonaqmKEH0GBklhqHoE84GAjSOclCirUGHFh5W9DeYGMHC)lRuCC)KVVlhH2NTtS23CIa0rY3p2NjqK1(IgG4uCFwGMUFqTewC)jLAuVFxsr2NTtS2pT9PrT)b3N7mmdbiemO3hoNjF)KVFSpFiKY9TE)bekDh2FoYAh5W9ZA)HMB7ZtZnSSlUEFbnn79hcUHar2xIrX33A2baIVVlpR59tBF2oXA)a2iLXrI69f1oXAFxEwZ7FzjtZYAEFbbf3pkO9DgWM18(r1MteSVfGz02VWaCeHHDKd3pnhjFFUmNDAsr2)GMHG9TEFxoUVJ4UpBNyTFaBKY4irg2p47BoX95iTlO9TamJ2(qnYlhPT)bl0N2(EqpSp3zygcYAEFZjU)qK1(waMrtVJcQLDX18SMLOIBrbfaibeoldAgsfNvkoYq6fEC9E9bezP8aeNIAaguB8ywaew1mfsdVgpDDAPnECqTewuHfoKixWWZOfsSmnNLmnlRzvsrnwXrIq7ODuqTSlUMN1SevvRsPacfZlDbaryi9cTqILPXtxNwAASIJeHyKfaHvntH0WRXtxNwAmEC9E9bezP8aeNIAaguBhful7IR5znlrv1QukGqX8sxaqegsVqwaew1mfsdVEwg0mKkoRuCKXJR3RpGilLhG4uudWGA7OGAzxCnpRzjQQwLsbekgnKsvqTSlLm5gdCdKuti8muXake5CSOiFhful7IR5znlrv1QukGqX8GEkwQgC2rb1YU4AEwZsuvTkLciuSJmNonaqmKEHb1syrfw4qICb7GXJdQLWIkSWHe5cgEgHzlKyzAolzAwwZQKIASIJeH2rb1YU4AEwZsuvTkLciumApGMIBnyyhful7IR5znlrv1QukGqXWtxNwAmKEHhxVxN0KkrUMBbvCHtGry(4696diYs5biof1amO2okOw2fxZZAwIQQvPuaHILuujJIImKEHhxVxFarwkpaXPOgGb1yCshxVx7ZAgbCv7vEqZnnadQnEmlacRAMcPHx7LUaGiWaJt64696KMujY1dHGsXTGk(e94696KMujY1ClOIddW0eul7s7bn3oT00OGcPUgQSCafiOw2LEwg0mKkoRuCutdUPSCafiOw2LEwg0mKkoRuCuBGawuQSCaHXSOrziGR8YMTYYbuzTEc6OeHXJR3RhWHgiIQ9kPlnHuqamg4AOMDTJcQLDX18SMLOQAvkfqOyZYGMHuXzLIJmKEHhxVxFarwkpaXPOgGb1gpMfaHvntH0WRXtxNwAJhBHeltNfnkdbCLx2S1yfhjcXin4MYYbuadeWIsLLdOGZIgLHaUYlB2klhqL16jODzXin4MYYbuadeWIsLLdimMfnkdbCLx2SvwoGkR1IIgQzx7ODuqTSlUMN1Sevn4iGqXOHuQcQLDPKj3yGBGKAcHNHkgqHiNJff5QgC2rb1YU4AEwZsu1GJacfZd6PyPAWzhful7IR5znlrvdociumV0faeHH0lKfaHvntH0WRXtxNwAmEC9E9bezP8aeNIAaguBhful7IR5znlrvdociuSJmNonaqmKEHb1syrfw4qICb7GXJdQLWIkSWHe5cgEgPb3uwoGcD8okOw2fxZZAwIQgCeqOyjfvYOOidPx4X171(SMrax1ELh0CtdWGAms7wc1SlTh0tXs1GJgGdrwCbpHXJpUEV2N1mc4Q2R8GMBAagutOd2rb1YU4AEwZsu1GJacf7iZPtdaedPxin4MYYbuOJ3rb1YU4AEwZsu1GJacfZlDbaryi9czbqyvZuin8A801PL2okOw2fxZZAwIQgCeqOyEPlaicdPx4X171hqKLYdqCkQbyqngNelacRAMcPHx7bn3oT0gpgcpUEVMvqfhHujf1aCiYIlyuqHuxdvwoGceul7sNuujJIIAdeWIsLLdimSJcQLDX18SMLOQbhbekgThqtXTgmSJcQLDX18SMLOQbhbekgE660sBhful7IR5znlrvdociumqiIQ9kpO5gdPxieEC9EnRGkocPskQDzXqwgcaUSmv6fEC9ETpRzeWvTx5bn30amOMqhWqwgcaUSmvomGqzyOq43rb1YU4AEwZsu1GJacf7iZPtda0oAh5W9fe1(8Ea3NNMByzxCg2xK2DFAu7ZDgMHG9feuCFMByJ9ryXA)WBiy)qcWasK9Pb3YAEFrlDbar2pkO9feuCFbnrrr9oYH7liBora7KJ7Bot((b1YU2p577YrO9z7eR9nN4(dXmUVZGVVOBrVF4neSpn4wwZ7lAPlaicd7ZrC)40WI6DuqTSlUMN1SefMuuvnSbdPxiTBjuZU0jfvvdBObyajcJq4X171SZYqaxrDMsP2L1okOw2fxZZAwIciumAiLQGAzxkzYng4giPMq4zOIbuipRzjQ4wuqbaIH0le0wyzxAUffuaG2rb1YU4AEwZsuaHIrdPuful7sjtUXa3aj1ecpdvmGc5znlrv1kzuuKH0le0wyzx6QvjfvYOO4okOw2fxZZAwIciumAiLQGAzxkzYng4giPMq4zOIbuipRzjQAWHH0le0wyzxApONILQbNDuqTSlUMN1SefqOyjfvvdBSJcQLDX18SMLOacfZLJQ0WbgQyafAjeYTgmOOnekOyi9cpUEVoPIOGfZIRHA2fJhxVxdClu1EfRMnc0qn7Ahful7IR5znlrbekMlhvPHdmGEpsnvfdOqQiuzBGUsQ6idUXq6fEC9EDsfrblMfxd1SlgpUEVg4wOQ9kwnBeOHA21okOw2fxZZAwIciumpO52PL2okOw2fxZZAwIciumAiLQGAzxkzYngQyafo0WIdyz7OGAzxCnpRzjkGqXskQKrrXD0oYH7lQtZ5(IgG40SM3hMezXW(P5i57FqZqW(wVplq2G0YP4(U8SM3x0GEkw7lido7Z2jw7FAZ5(IwqE)OG2NjzoDAaG2pa4(T3VpTBjuZU07ihUVOonNTRTVObionR59HjrwmSV5e3N2fSiGJ7N89nGlUFinNT7SZ9nN4(qP3JaSO4(jF)HSso1vI77wwk3hweiY(oZzN7BbygT9PTBzC9okOw2fxhnkGqX8GEkwQgC2rb1YU46Orbek2rMtNgaODuqTSlUoAuaHIrdPuful7sjtUXqfdOqKZXIICg4giPMq4zi9cHzqBHLDP9GEkwQgC2rb1YU46OrbekgnKsvqTSlLm5gdvmGcrohlkYvn4Wa3aj1ecpdPxiOTWYU0Eqpflvdo7OGAzxCD0OacfJ2dOP4wdg2rb1YU46Orbekwsrv1Wg7ihU)nhyjtFIq7lAPlaiY(0UGsl7IVVh0d7BoX9VWTFqTSR9Lj307FZII7BoX9hIzC)KV)mwiiSSM33hG9LiNVptGiR9fnaXP4(uNbyg5mSV5e3hfub12roCFAxqPLDTVteG7N8YrA7hs5(MZW2phy1alktVJcQLDX1rJciumV0faeHH0lKfaHvntH0WRXtxNwAJhFC9E9bezP8aeNIAaguJXjXcGWQMPqA41EqZTtlngN0X171jnPsKR5wqfhgfLXJHzlKyz6zzqZqQ4SsXrnwXrIqWW4XSaiSQzkKgE9SmOzivCwP4imSJcQLDX1rJciuSKIkzuuKH0l8469AFwZiGRAVYdAUPbyqTDKd3hoN4(dXmUp7uk3FgleesPi7FW9NXcbHL18(X(Y22V97l6w07tDgGzKVpBNyTVlpR59nN4(c6TJA)GAzx7ltUP3hoGiznVV17dHYqK9HjHi73(9fnO52oYH77wwk33CIaC)aG7x9(IUf9(uNbyg57hf0(vVFqTewCFrd6PyTVGm4W3ND7kH2xIb0(wVFA7xTT)bZAEFxocTFy7hsPEhful7IRJgfqOyGqev7vEqZTDuqTSlUoAuaHIHNUoT02rb1YU46Orbek2SmOzivCwP44oYH7dtnpR59HP3fUF73hMElH2p57p0CtkY(W0kiD3VqxdeY9zNMZ9nN4(c6TJAFlaZOTV5eGCNTeIR3xqy73LuK9piThq((qiflB)5iR9zNMZ9bT7StPi7pr2Vb7p0aCFlaZOX17OGAzxCD0OacfJ2fQAVI2sODuqTSlUoAuaHI5YrvA4advmGcTec5wdgu0gcfumKEHhxVxNuruWIzX1qn7IXJR3RbUfQAVIvZgbAOMDTJcQLDX1rJciumxoQsdhya9EKAQkgqHurOY2aDLu1rgCJH0l84696KkIcwmlUgQzxmEC9EnWTqv7vSA2iqd1SRDuqTSlUoAuaHI5bn3oT02rb1YU46OrbekgnKsvqTSlLm5gdvmGchAyXbSSDuqTSlUoAuaHILuujJII7ODuqTSlUM2TeQzxCbek2SBaGYOuTxftrqBozi9cHzqBHLDP9GEkwQgCgpM2TeQzxApONILQbhnahIS4W4e2rb1YU4AA3sOMDXfqOyGakJYuCwbq8DuqTSlUM2TeQzxCbekgegMZtdkChful7IRPDlHA2fxaHILuruWIzXzi9cHzqBHLDP9GEkwQgCgpM2TeQzxApONILQbhnahIS4W4e2rb1YU4AA3sOMDXfqOydja0avoeZ4okOw2fxt7wc1SlUacfBibGgWvTxznyalBhful7IRPDlHA2fxaHIXDMElRzfRMnc2roCFyIBH73(9fKA2iy)KVFizhIW33LJq7ZonN7lAqpfR9fKbh9(c6Li7lrV1WIG9PodWmY3pS9nN4(ybTF733CI77ZzN2(CNTReA)dUVlhHyy)ecdPuKDKd3p97BoX9pnNVpuJ8YrA7dL4(zTV5e3FiHGK4(TFFZjUpmXTW9pUEVEhful7IRPDlHA2fxaHIbClu1EfRMncyi9cpUEVg4wOQ9kwnBeOHA2fJtIfaHvntH0WR9GEkwQgCgp2cWmAAlhqL1kOefm8owaAWnLLdiJwaMrtB5aQSwbLim6ahdd7ihUVGCTppRzjUVfGz023NZonod7BoX9PDlHA21(TFFyIBH73(9fKA2iy)KVVSzJG9nNrTV5e3N2TeQzx73(9fnONI1(cYGdd7Bot((ZjSiFh5W9rbLbI9HjUfUF73xqQzJG9PodWmY33Cg2(CNTReA)dUVlhH2NDAo3pOwclUVfsSmod7N(9z1CEEKOEhful7IRPDlHA2fxaHIrdPuful7sjtUXqfdOqlKyzkqZIH0l0cjwMg4wOQ9kwnBeOXkoseIXGAjSOclCirUq4zK2TeQzxAGBHQ2Ry1SrG27kLkasDgGzuz5acJ0ULqn7s7b9uSun4Ob4qKfFhful7IRPDlHA2fxaHIXQTSlgsVqwaew1mfsdVoPIOGfZIpESfGz00woGkRvqjcJt2X7OGAzxCnTBjuZU4ciumxoQsdhyOIbu4jKOpbO6aII6KH0leMTqILPNLbndPIZkfh1yfhjcnE8X171hqKLYdqCkQbyqngzbqyvZuin86zzqZqQ4SsXXDuqTSlUM2TeQzxCbekMlhvPHd8DuqTSlUM2TeQzxCbek2r2nKY7cezhful7IRPDlHA2fxaHIDqahbIN18okOw2fxt7wc1SlUacftMZonUcMIl08aw2okOw2fxt7wc1SlUacfZNa8i7gAhful7IRPDlHA2fxaHIfff5giKkAiL7OGAzxCnTBjuZU4ciuStmRAVYajvC(oAhful7IRrohlkYfqOy(M6YrivmfbPHQdgdmKEHhxVxdClu1EfRMnc0qn7A84GAjSOclCirUGN8okOw2fxJCowuKlGqXgWHgiIQ9kPlnHuqamg4mKEHb1syrfw4qICyCcmoPJR3RtAsLixZTGkomke(XJHzlKyz6zzqZqQ4SsXrnwXrIqWaJ0ULqn7s7b9uSun4Ob4qKfxWW7ygNemdAlSSln3IckaqJhdZb1YU0Eqpflvdo6SuEzo70yCg0UfKkAu7b9uSun4Ob4qKfxOJHHDuqTSlUg5CSOixaHIDKDdPAVYCIkSWbryi9cNKfsSm9SmOzivCwP4OgR4irigpUEVoPjvICn3cQ4cNaJt64696diYs5biof1amO24XSaiSQzkKgEnE660sdgGHXJN0KcQLWIkSWHe5cEYJhdZwiXY0ZYGMHuXzLIJASIJeHGbgNelacRAMcPHx7b9uSun4mE8mODliv0O2d6PyPAWrdWHilUGNamad7OGAzxCnY5yrrUacfJLli9IK1S6idUXq6fEC9EnWTqv7vSA2iqd1SRXJdQLWIkSWHe5cEY7OGAzxCnY5yrrUacfdKSyjrvwkoRGImKEHhxVxdClu1EfRMnc0qn7A84GAjSOclCirUGN8okOw2fxJCowuKlGqXODrXYaHHqkVmgqgKzHkkKWjMH0l8469AGBHQ2Ry1SrGgQzx7OGAzxCnY5yrrUacfdGbRSMvEzmGCgsVWJR3RbUfQAVIvZgbAOMDTJcQLDX1iNJff5ciumZjQCRt7wqkFdOidPx4X171aKkUe5CLVbuu7YAhful7IRrohlkYfqOySBGecwmlfa5Dfffzi9cpUEVg4wOQ9kwnBeOHA214Xb1syrfw4qICbp5D0okOw2fxJCowuKRAWraHI5BQlhHuXueKgQoymWq6fEC9EnWTqv7vSA2iqd1SlgHWJR3RzfuXrivsrnuZUgpoOwclQWchsKl4jVJcQLDX1iNJff5QgCeqOyd4qder1EL0LMqkiagdCgsVWGAjSOclCiromobgHWJR3RzfuXrivsrnuZUyK2TeQzxApONILQbhnahIS4cEcmcZb1YU0Eqpflvdo6SuEzo70yCg0UfKkAu7b9uSun4Ob4qKfxOJ3rb1YU4AKZXIICvdociuSJSBiv7vMtuHfoicdPxilacRAMcPHx7b9uSun4mE8mODliv0O2d6PyPAWrdWHilUGNWokOw2fxJCowuKRAWraHIXYfKErYAwDKb3yi9cpUEVg4wOQ9kwnBeOHA2fJq4X171ScQ4iKkPOgQzxJhhulHfvyHdjYf8K3rb1YU4AKZXIICvdociumqYILevzP4SckYq6fEC9EnWTqv7vSA2iqd1SlgHWJR3RzfuXrivsrnuZUgpoOwclQWchsKl4jVJcQLDX1iNJff5QgCeqOy0UOyzGWqiLxgdidYSqffs4eZq6fEC9EnWTqv7vSA2iqd1SlgHWJR3RzfuXrivsrnuZU2rb1YU4AKZXIICvdociumagSYAw5LXaYzi9cpUEVg4wOQ9kwnBeOHA2fJq4X171ScQ4iKkPOgQzx7OGAzxCnY5yrrUQbhbekM5evU1PDliLVbuKH0l8469AasfxICUY3akQDzTJcQLDX1iNJff5QgCeqOySBGecwmlfa5Dfffzi9cpUEVg4wOQ9kwnBeOHA2fJq4X171ScQ4iKkPOgQzxms7wc1SlTh0tXs1GJgGdrwCyuugpoOwclQWchsKl4jVJ2roCFrDAo33ridAgY9VSsXrg2hM4w4(TFFbPMnc2N7SDLq7FW9D5i0(GC2PT)b9na33CI77iKbnd5(xwP44(0E407pPuJ69zNMZ9NW(ccAsLiF)OG2p2NjqK1(IgG4ueg07ihUVO2jw77OoDDAPTFY3V9(9PDlHA2fd7dtClC)2VVGuZgb7tJA)qY79p4(UCeAFykUCBF2P5C)jSVGGMujY17OGAzxCTfsSmfOzjGqXaUfQAVIvZgbmKEHhxVxdClu1EfRMnc0qn7IrlKyz6zzqZqQ4SsXrnwXrIqmEC9EDstQe5AUfuXfobgN0X171hqKLYdqCkQbyqTXJTqILPXtxNwAASIJeHyK2TeQzxA801PLMgGdrwCyKgCtz5acd7ihUVOonNTRTVJqg0mK7FzLIJmSpmXTW9B)(csnBeSp3z7kH2)G77YrO9pOVb4(rjY(NCEgb7t7wc1SR9NKJ601PLgd7dtVhqB)R1Gbg2hMeISF73x0GMBWW(nyh5W9z7eR9HjUfUF73xqQzJG9t((XPDT9TEFaguN77G9PodWmY17OGAzxCTfsSmfOzjGqXaUfQAVIvZgbmKEHhxVxdClu1EfRMnc0qn7Iry2cjwMEwg0mKkoRuCuJvCKieJtYcjwMgpDDAPPXkoseIrA3sOMDPXtxNwAAaoezXHrAWnLLd44XwiXY00Eanf3AWGgR4irigPDlHA2LM2dOP4wdg0aCiYIdJ0GBklhWXJTqILPbHiQ2R8GMBASIJeHyK2TeQzxAqiIQ9kpO5MgGdrwCyKgCtz5aoEm1zaMrUYdcQLDfsbdVwubd7ODuqTSlUEOHfhWYeqOyhzwIRIsegsVWHgwCaltdLClkkky4D8okOw2fxp0WIdyzciuSKIkVSrodPx4X171jfvEzJCnuZUixolKsyEIffIrmcba]] )


end
