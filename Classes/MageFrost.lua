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



    spec:RegisterStateExpr( "incanters_flow_stacks", function ()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end
        
        return incanters_flow.values[ index ][ 1 ]
    end )

    spec:RegisterStateExpr( "incanters_flow_dir", function()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end

        return incanters_flow.values[ index ][ 2 ]
    end )

    -- Seemingly, a very silly way to track Incanter's Flow...
    local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
        __index = function( t, k )
            if not state.talent.incanters_flow.enabled then return 0 end

            local stack = t.__stack
            local ticks = #state.incanters_flow.values

            local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

            local low_pos, high_pos

            if k == "up" then low_pos = 5
            elseif k == "down" then high_pos = 6 end

            local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

            for i = 0, 10 do
                local index = ( start + i )
                if index > 10 then index = index % 10 end

                local values = state.incanters_flow.values[ index ]

                if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                    return max( 0, i - time_since )
                end
            end

            return 0
        end
    } )

    spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
        __index = function( t, k )
            incanters_flow_time_obj.__stack = tonumber( k ) or 0
            return incanters_flow_time_obj
        end
    } ) )

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
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

        potion = "potion_of_unbridled_fury",

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

    
    spec:RegisterPack( "Frost Mage", 20190810, [[dOuXtbqiKI6rkjAtiHpruqJsLIoLkfEfrywej3sjjSls9lvQggrPogs0Yik6zcbtJOexti02ussFtjHmoIc15ikK1HuiMNssDpKQ9PsPdQKaleP0dvsOMisHQUirj1grk4JifQmsLeuDsIsYkviZujjYnrku2jr0prkKgksrSuKI0tvQPQK6QkjO8vLeK9c5VKmyuoSOfROhd1KvXLbBwWNvIrRsCAjRwjjQxlenBc3wO2nLFl1WrslhXZr10P66ky7kuFNOA8ef48ePwVkP5lK2VQgrjAnAFshqsktztPms2YykLTwMrqMYuwqBxAQaAtnXrMlaABzmG20aP5(ZOXYfaTPMsl68GwJ28EGGb0(I7u50i3VVu(LHPg3X35v8Gi9Qnmjd(DEfJVJ2ZHs4Ykdnr7t6asszkBkLrYwgtPS1YmcYuMricODo4xAcAVR4vmAFPohWqt0(aCmAVYNrdKM7pJglxGF0kF2f3PYPrUFFP8ldtnUJVZR4br6vBysg878kgF)hTYNTcgwg4(ZOu2s9mzkBkLrpBv8mzkBAezgXF0pALpBfFjTfGtJ8Jw5ZwfpBfghEMm0Ryq5T6uGm8zLXDippRdptg6jzbCTxXGYB1Paz4Zcn5zIK7pJd42opBftJ)zd8Cb0)Ov(SvXZOXaYc8mAG0C)z0y5c8SvanzvI)SBotoCEwBpBbmGKEt4pRSNXXQ4Cb0yQuVbAlkUZrRrBEzlcaTgjjLO1Ony5uaheTOnMuoqQeTXDloTCtxyqz94utG8i9ZO4zhyoecA5L5aHRWxkHqpqfTtSxTH2fguwporosszIwJ2GLtbCq0I2ys5aPs0M0E6vBAUN2jjh0oXE1gAJtHqLyVAtjkUJ2II7klJb0Mx2IauCpTtsoihjzeqRrBWYPaoiArBmPCGujAtAp9QnT1QcdkrAyaTtSxTH24uiuj2R2uII7OTO4UYYyaT5LTiaL1krAya5ijLf0A0gSCkGdIw0gtkhivI2K2tVAthi9vWunzI2j2R2qBCkeQe7vBkrXD0wuCxzzmG28YweGQjtKJKmIO1ODI9Qn0UWGY6XjAdwofWbrlYrsUQO1Ony5uaheTODI9Qn02RdW9MeRW9bKbOnMuoqQeTNdHGUWsRgdLX1NwU9mkE2Cie0KbduDqrTLde9PLBOTLXaA71b4EtIv4(aYaKJKCfHwJ2GLtbCq0I2j2R2qBS0yr7K2kSAksUJ2ys5aPs0Eoec6clTAmugxFA52ZO4zZHqqtgmq1bf1woq0NwUH2qiayxzzmG2yPXI2jTvy1uKCh5ijLXO1ODI9Qn0oqAUpBHJ2GLtbCq0ICKKYi0A0gSCkGdIw0gtkhivI2X94Ywq7e7vBOnofcvI9QnLO4oAlkURSmgq74EmedMJCKKukB0A0oXE1gAxyqjsddOny5uaheTih5OnW5GHboAnsskrRrBWYPaoiArBmPCGujAphcbnzWavhuuB5arFA52ZIg9zj2RXGcmiUa(ZU9zraTtSxTH2HgpWHJkVcKYb1eYyKJKuMO1Ony5uaheTOnMuoqQeTtSxJbfyqCb8NT6NfXNrXZU5ZMdHGUWfwaCn3tCKpB10FgLplA0NrZpZtbyUErK4kfko1ksqdwofW5z34zu8mC3Itl30bsFfmvtMAceNLXF2TpJszJ2j2R2q7yiUjsR6GsmGRJ6qGmMJCKKraTgTblNc4GOfTXKYbsLO9nFMNcWC9IiXvkuCQvKGgSCkGZZO4zZHqqx4claUM7joYNr)zr8zu8SB(S5qiONKSmvGaWvqtGe7plA0NrLaJvl4JMsnmBB2c)z34z34zrJ(SB(SB(Se71yqbgexa)z3(Si8SOrFgn)mpfG56frIRuO4uRibny5uaNNDJNrXZU5ZOsGXQf8rtPoq6RGPAY8zrJ(Sfspyhv2Goq6RGPAYutG4Sm(ZU9zr8z34z3aTtSxTH2tr3hvhu(fqbgelnYrsklO1Ony5uaheTOnMuoqQeTNdHGMmyGQdkQTCGOpTC7zrJ(Se71yqbgexa)z3(SiG2j2R2qBQdKkiDzlQPi5oYrsgr0A0gSCkGdIw0gtkhivI2ZHqqtgmq1bf1woq0NwU9SOrFwI9AmOadIlG)SBFweq7e7vBOnPOsvaQYuCQjgqosYvfTgTblNc4GOfTtSxTH242WG5K0HJkiYyaTXKYbsLO9Cie0KbduDqrTLde9PLBOTOmqHpO9QICKKRi0A0gSCkGdIw0gtkhivI2ZHqqtaCKcGZvHMGb9av0oXE1gA7xa1Gn7b7OcnbdihjPmgTgTblNc4GOfTXKYbsLO9Cie0KbduDqrTLde9PLBplA0NLyVgdkWG4c4p72Nfb0oXE1gAlVjIZyOmfb4TLggqoYrBEzlcqX90oj5GwJKKs0A0gSCkGdIw0gtkhivI2EkaZ1WSTzlCny5uaNNrXZOsGXQf8rtPgMTnBH)mkE2nFgn)mpfG56frIRuO4uRibny5uaNNfn6ZMdHGUWfwaCn3tCKpB1ptwEw0OpBoec6jjltfiaCf0eiX(ZUbANyVAdTdIbcrAKJKuMO1Ony5uaheTOnMuoqQeT9uaMRxejUsHItTIe0GLtbCEgfpJkbgRwWhnL6frIRuO4uRiHNrXZMdHGEsYYubcaxbnbsSJ2j2R2q7GyGqKg5ijJaAnAdwofWbrlAJjLdKkrBQeySAbF0uQdKM7Zw4pJINnhcb9KKLPceaUcAcKy)zu8SB(mA(zEkaZ1lIexPqXPwrcAWYPaoplA0NnhcbDHlSa4AUN4iF2QFMS8SBG2j2R2q7GyGqKg5ijLf0A0gSCkGdIw0oXE1gAJtHqLyVAtjkUJ2II7klJb0g4CWWah5ijJiAnANyVAdTdK(kyQMmrBWYPaoiArosYvfTgTblNc4GOfTXKYbsLODI9AmOadIlG)SBFMmFw0OplXEnguGbXfWF2TpJYNrXZWj3vEfdpJ(ZK9ZO4zZHqqhkBbiCvhubsZDnbsS)Sv)mzI2j2R2q7POUEnjhKJKCfHwJ2GLtbCq0I2ys5aPs0Eoec6qzlaHR6GkqAURjqID0oXE1gAxyqjsddihjPmgTgTtSxTH24ogCf3BsmAdwofWbrlYrskJqRr7e7vBOnmBB2chTblNc4GOf5ijPu2O1Ony5uaheTOnMuoqQeTP5NLyVAthi9vWunzQltfe1Yf)zu8Sfspyhv2Goq6RGPAYutG4Sm(ZO)mzJ2j2R2qBskTQdQaP5oYrssjLO1Ony5uaheTOnMuoqQeTXj3vEfdpJ(ZK9ZIg9zj2RXGcmiUa(ZU9zuI2j2R2q7POUEnjhKJKKszIwJ2GLtbCq0I2ys5aPs0Eoec6jjltfiaCf0eiX(ZIg9zujWy1c(OPudZ2MTWFw0OplXEnguGbXfWF2TpJYNrXZ8uaMR5ufL7LTOkmOblNc4G2j2R2q7frIRuO4uRibKJC0Mx2IaunzIwJKKs0A0gSCkGdIw0oXE1gAJtHqLyVAtjkUJ2II7klJb0g4CWWax1KjYrskt0A0oXE1gAhi9vWunzI2GLtbCq0ICKKraTgTblNc4GOfTXKYbsLOnvcmwTGpAk1WSTzl8NrXZMdHGEsYYubcaxbnbsSJ2j2R2q7GyGqKg5ijLf0A0gSCkGdIw0gtkhivI2j2RXGcmiUa(ZU9zY8zrJ(Se71yqbgexa)z3(mkFgfpdNCx5vm8m6pt2ODI9Qn0EkQRxtYb5ijJiAnAdwofWbrlAJjLdKkr75qiOdLTaeUQdQaP5UMaj2Fgfpd3T40YnDG0xbt1KPMaXzz8ND7ZI4ZIg9zZHqqhkBbiCvhubsZDnbsS)m6ptMODI9Qn0UWGsKggqosYvfTgTblNc4GOfTXKYbsLOno5UYRy4z0FMSr7e7vBO9uuxVMKdYrsUIqRrBWYPaoiArBmPCGujAtLaJvl4JMsnmBB2chTtSxTH2bXaHinYrskJrRrBWYPaoiArBmPCGujAphcb9KKLPceaUcAcKy)zu8SB(mQeySAbF0uQdKM7Zw4plA0NDG5qiOPM4iHJQWGMaXzz8ND7ZazaGhCq5vm8mjEwI9QnDHbLinmODsogekVIHNDd0oXE1gAhedeI0ihjPmcTgTtSxTH24ogCf3BsmAdwofWbrlYrssPSrRr7e7vBOnmBB2chTblNc4GOf5ijPKs0A0gSCkGdIw0oXE1gAtsPvDqfin3r7YCGqgO6QkG2ZHqqhkBbiCvhubsZDnbsStxMODzoqiduDvfhdNkDaTPeTXKYbsLO9bMdHGMAIJeoQcd6bQihjjLYeTgTtSxTH2trD9AsoOny5uaheTih5OTNcWCfPPIwJKKs0A0gSCkGdIw0gtkhivI2EkaZ1lIexPqXPwrcAWYPaopJINnhcbDHlSa4AUN4iFg9NfXNrXZU5ZMdHGEsYYubcaxbnbsS)SOrFMNcWCnmBB2cxdwofW5zu8mC3Itl30WSTzlCnbIZY4pB1pdNCx5vm8SBG2j2R2qBYGbQoOO2YbcYrskt0A0gSCkGdIw0gtkhivI208Z8uaMRxejUsHItTIe0GLtbCEgfp7MpZtbyUgMTnBHRblNc48mkEgUBXPLBAy22SfUMaXzz8NT6NHtUR8kgEw0OpZtbyUg3XGR4EtI1GLtbCEgfpd3T40YnnUJbxX9MeRjqCwg)zR(z4K7kVIHNfn6Z8uaMRjP0QoOcKM7AWYPaopJINH7wCA5MMKsR6GkqAURjqCwg)zR(z4K7kVIHNfn6ZWxsYcWvbsI9QTu8SBFgLAz0ZUbANyVAdTjdgO6GIAlhiih5OnW5GHbUQjt0AKKuIwJ2GLtbCq0I2ys5aPs0EoecAYGbQoOO2YbI(0YTNrXZoWCie0utCKWrvyqFA52ZIg9zj2RXGcmiUa(ZU9zraTtSxTH2HgpWHJkVcKYb1eYyKJKuMO1Ony5uaheTOnMuoqQeTtSxJbfyqCb8NT6NfXNrXZoWCie0utCKWrvyqFA52ZO4z4UfNwUPdK(kyQMm1eiolJ)SBFweFgfpJMFwI9QnDG0xbt1KPUmvqulx8NrXZwi9GDuzd6aPVcMQjtnbIZY4pJ(ZKnANyVAdTJH4MiTQdkXaUoQdbYyoYrsgb0A0gSCkGdIw0gtkhivI2ujWy1c(OPuhi9vWunz(SOrF2cPhSJkBqhi9vWunzQjqCwg)z3(SiI2j2R2q7PO7JQdk)cOadILg5ijLf0A0gSCkGdIw0gtkhivI2ZHqqtgmq1bf1woq0NwU9mkE2bMdHGMAIJeoQcd6tl3Ew0OplXEnguGbXfWF2TplcODI9Qn0M6aPcsx2IAksUJCKKreTgTblNc4GOfTXKYbsLO9Cie0KbduDqrTLde9PLBpJINDG5qiOPM4iHJQWG(0YTNfn6ZsSxJbfyqCb8ND7ZIaANyVAdTjfvQcqvMItnXaYrsUQO1Ony5uaheTODI9Qn0g3ggmNKoCubrgdOnMuoqQeTNdHGMmyGQdkQTCGOpTC7zu8Sdmhcbn1ehjCufg0NwUH2IYaf(G2RkYrsUIqRrBWYPaoiArBmPCGujAphcbnbWrkaoxfAcg0dur7e7vBOTFbud2ShSJk0emGCKKYy0A0gSCkGdIw0gtkhivI2ZHqqtgmq1bf1woq0NwU9mkE2bMdHGMAIJeoQcd6tl3Ew0OplXEnguGbXfWF2TplcODI9Qn0wEteNXqzkcWBlnmGCKJ2hiKdchTgjjLO1ODI9Qn0g3dMdeovqiqBWYPaoiArosszIwJ2GLtbCq0I2ys5aPs0MMFgP90R20wRkmOePHHNrXZOsGXQf8rtPoigiePFgfpJMF2Cie0HYwacx1bvG0CxtGe7ODI9Qn0UWGsKggqosYiGwJ2GLtbCq0I2j2R2qBCkeQe7vBkrXD0wuCxzzmG24UfNwUXrosszbTgTblNc4GOfTXKYbsLODI9AmOadIlG)SBFweEgfpZtbyUoqa4AzlkswMgSCkGZZIg9zj2RXGcmiUa(ZU9zYcANyVAdTXPqOsSxTPef3rBrXDLLXaANnGCKKreTgTblNc4GOfTtSxTH24uiuj2R2uII7OTO4UYYyaT5LTiaKJC0MkbWD8mD0AKKuIwJ2j2R2q7KGtduL5GqayhTblNc4GOf5ijLjAnANyVAdTLNoquGaIbZtbAdwofWbrlYrsgb0A0gSCkGdIw02YyaTZR8ljj5QqBUQdkQTCGG2j2R2q78k)sssUk0MR6GIAlhiihjPSGwJ2j2R2q74IqAIQIZfaTblNc4GOf5ijJiAnANyVAdTP2E1gAdwofWbrlYrsUQO1ODI9Qn0oqAUpBHJ2GLtbCq0ICKJ2zdO1ijPeTgTtSxTH2bsFfmvtMOny5uaheTihjPmrRr7e7vBO9uuxVMKdAdwofWbrlYrsgb0A0gSCkGdIw0oXE1gAJtHqLyVAtjkUJ2II7klJb0g4CWWah5ijLf0A0oXE1gAJ7yWvCVjXOny5uaheTihjzerRr7e7vBODHbL1Jt0gSCkGdIwKJKCvrRrBWYPaoiArBmPCGujAtLaJvl4JMsnmBB2c)zrJ(S5qiONKSmvGaWvqtGe7pJINDZNrLaJvl4JMsDG0CF2c)zu8SB(S5qiOlCHfaxZ9eh5Zw9ZKLNfn6ZO5N5PamxVisCLcfNAfjOblNc48SB8SOrFgvcmwTGpAk1lIexPqXPwrcp7gODI9Qn0oigieProsYveAnAdwofWbrlAJjLdKkr75qiOdLTaeUQdQaP5UMaj2r7e7vBODHbLinmGCKKYy0A0oXE1gAtsPvDqfin3rBWYPaoiArosszeAnANyVAdTHzBZw4Ony5uaheTihjjLYgTgTtSxTH2lIexPqXPwrcOny5uaheTihjjLuIwJ2j2R2qBCBGQdkCloOny5uaheTihjjLYeTgTblNc4GOfTtSxTH2EDaU3KyfUpGmaTXKYbsLO9Cie0fwA1yOmU(0YTNrXZMdHGMmyGQdkQTCGOpTCdTTmgqBVoa3BsSc3hqgGCKKugb0A0gSCkGdIw0oXE1gAJLglAN0wHvtrYD0gtkhivI2ZHqqxyPvJHY46tl3EgfpBoecAYGbQoOO2YbI(0Yn0gcba7klJb0glnw0oPTcRMIK7ihjjLYcAnANyVAdTdKM7Zw4Ony5uaheTihjjLreTgTblNc4GOfTtSxTH24uiuj2R2uII7OTO4UYYyaTJ7XqmyoYrss5QIwJ2j2R2q7cdkrAyaTblNc4GOf5ihTXDloTCJJwJKKs0A0oXE1gAVmKKtLMQdQ8kqA)cAdwofWbrlYrskt0A0oXE1gAxyPvJHY4Ony5uaheTihjzeqRr7e7vBODCrinrvX5cG2GLtbCq0ICKKYcAnAdwofWbrlAJjLdKkrBQeySAbF0uQdK(kyQMmFw0OpZRyq5T6uWZU9zuk7NjXZWj3vEfdpJIN5vmO8wDk4zR(zYu2ODI9Qn0MmyGQdkQTCGGCKKreTgTblNc4GOfTXKYbsLOTNcWCnzWavhuuB5ardwofW5zu8Se71yqbgexa)z0FgLpJINH7wCA5MMmyGQdkQTCGOddcHIa4ljzbuEfdpB1pd3T40YnDG0xbt1KPMaXzzC0oXE1gAJtHqLyVAtjkUJ2II7klJb02tbyUI0urosYvfTgTblNc4GOfTXKYbsLOnvcmwTGpAk1fwA1yOm(ZIg9zEfdkVvNcE2QFweKnANyVAdTP2E1gYrsUIqRrBWYPaoiAr7e7vBO9mfqOiGAssdFbTXKYbsLOnn)mpfG56frIRuO4uRibny5uaNNfn6ZMdHGEsYYubcaxbnbsS)mkEgvcmwTGpAk1lIexPqXPwrcOTLXaAptbekcOMK0WxqosszmAnANyVAdTh4GQCiMJ2GLtbCq0ICKKYi0A0oXE1gApfDFuHbI0Ony5uaheTihjjLYgTgTtSxTH2tGWbsKLTG2GLtbCq0ICKKusjAnANyVAdTf1YfNRwLholXG5Ony5uaheTihjjLYeTgTtSxTH2HIatr3h0gSCkGdIwKJKKYiGwJ2j2R2q70Wa3jPqHtHaTblNc4GOf5ihT5LTiaL1krAyaTgjjLO1Ony5uaheTOnMuoqQeT9uaMRHzBZw4AWYPaopJINrLaJvl4JMsnmBB2c)zu8S5qiONKSmvGaWvqtGe7ODI9Qn0oigieProsszIwJ2GLtbCq0I2ys5aPs0MkbgRwWhnL6frIRuO4uRiHNrXZMdHGEsYYubcaxbnbsSJ2j2R2q7GyGqKg5ijJaAnAdwofWbrlANyVAdTXPqOsSxTPef3rBrXDLLXaAdCoyyGJCKKYcAnANyVAdTdK(kyQMmrBWYPaoiArosYiIwJ2GLtbCq0I2ys5aPs0oXEnguGbXfWF2TptMplA0NLyVgdkWG4c4p72Nr5ZO4z08Z8uaMR5ufL7LTOkmOblNc4G2j2R2q7POUEnjhKJKCvrRr7e7vBOnUJbxX9MeJ2GLtbCq0ICKKRi0A0gSCkGdIw0gtkhivI2ZHqqx4claUM7joYNr)zr8zu8mA(zZHqqpjzzQabGRGMaj2r7e7vBOnmBB2ch5ijLXO1Ony5uaheTOnMuoqQeTNdHGEsYYubcaxbnbsS)SOrFgvcmwTGpAk1WSTzl8Nfn6Z8uaMRldNMdeUkiA5AWYPaopJINHtUR8kgEMepZj5yqO8kgE2TpRmCAoq4QGOLR8kguERJOEG6ZO4z4K7kVIHNjXZCsogekVIHNT6NvgonhiCvq0YvEfdkV1YI(0Yn0oXE1gAVisCLcfNAfjGCKJ2X9yigmhTgjjLO1Ony5uaheTOnMuoqQeTNdHGUWGkiAGRpTCdTtSxTH2fgubrdCKJCKJ2JbcVAdjPmLnLYizlJLDe0ugXiG2YtIv2chTLvXuBIdNNrPmFwI9QTNjkUZ1)i0MtfWijxvzbTPs6qja0ELpJgin3FgnwUa)Ov(SlUtLtJC)(s5xgMAChFNxXdI0R2WKm435vm((pALpBfmSmW9NrPSL6zYu2ukJE2Q4zYu20iYmI)OF0kF2k(sAlaNg5hTYNTkE2kmo8mzOxXGYB1Paz4ZkJ7qEEwhEMm0tYc4AVIbL3QtbYWNfAYZej3FghWTDE2kMg)Zg45cO)rR8zRINrJbKf4z0aP5(ZOXYf4zRaAYQe)z3CMC48S2E2cyaj9MWFwzpJJvX5cOXuPEJF0pALptwlda8GdNNnHqtGNH74z6pBclLX1pBfGXavN)mRTvXLKehgeplXE1g)zTjKw)Jw5ZsSxTX1ujaUJNPtpisEK)Ov(Se7vBCnvcG74z6sq)EO7ZpALplXE1gxtLa4oEMUe0VNdlXG5PxT9JsSxTX1ujaUJNPlb97jbNgOkZbHaW(pkXE1gxtLa4oEMUe0VZhIJBtjpDGOabedMNIF0kFwI9QnUMkbWD8mDjOFNBjv(L2vCpD(pkXE1gxtLa4oEMUe0VpWbv5qSuwgd0ZR8ljj5QqBUQdkQTCG8JsSxTX1ujaUJNPlb97XfH0evfNlWpkXE1gxtLa4oEMUe0VtT9QTFuI9QnUMkbWD8mDjOFpqAUpBH)J(rR8zYAzaGhC48mymqK(zEfdpZVaplXEtEwXFwoolrofG(hLyVAJth3dMdeovqi(rR8zYQWZ8lWZIZf4zxs(ZOHMgEwgCG8mCY9YwEwzCpn)z0GyGqKwQNjhEgoTNDark9Z8lWZKvy4zRsPHHNL25zdC4zTFbip7sTC5zujvtkx6NLyVAtQNvHNLJZsKtbO)rj2R24sq)EHbLinmivfOtZK2tVAtBTQWGsKggOGkbgRwWhnL6GyGqKMcAEoec6qzlaHR6GkqAURjqI9FuI9QnUe0VJtHqLyVAtjkUlLLXaDC3Itl34)Ov(S1xGN5jzb8N5xia)slopR4Mm0FgidsSRFgTGlha7zryveXN5jzbCUupZVap7uHaqadd8Nnbxoa2Z8lWZ2RFwANNTcAz9ZsSxT9mrXD(Zsc8ms6xaYZ4XPqOF2k8womgis9mAGaW1YwEgnnl7zujqai8NnWlB5zRGww)Se7vBptuC)z8UnG8SK)SYF2emiuo)zleiDH0plq64N5xGNDPwU8mQKQjLl9ZOvuxVMKZZsSxTP)rj2R24sq)oofcvI9QnLO4Uuwgd0ZgKQc0tSxJbfyqCb8BJafEkaZ1bcaxlBrrYY0GLtbCIgnXEnguGbXfWVvw(rj2R24sq)oofcvI9QnLO4Uuwgd05LTiGF0pALpBfQ8lpJgiaCTSLNrtZYK6zLld5pBcUdKN59ZOsQMuEDfE2aVSLNrdK(kypJgLmFM8lG9Sz7xEgnqJ(S0opJwrD9AsopljWZ6q4z4UfNwUPF2ku5x6b)z0abGRLT8mAAwMupZVapd32yGWHNv8N5Kb4zPWV0dlxEMFbE2PcbGaggEwXFwCzfhpiGNnyEjE2yGi9ZUulxEMNKfWFgUhmNR)rj2R246Sb6bsFfmvtM)Oe7vBCD2Ge0Vpf11Rj58JsSxTX1zdsq)oofcvI9QnLO4Uuwgd0bohmmW)rj2R246SbjOFh3XGR4EtI)rj2R246SbjOFVWGY6X5pALpBxXufvOGZZObXaHi9ZWTDkVAJ)SaPJFMFbE2E9ZsSxT9mrXD9Z2LHHN5xGNfNlWZk(ZwadiPx2YZcj5zcGZFgTKSSNrdeaUcpdFjjlaxQN5xGNbYGe7pd32P8QTNDbiWZkUjd9NLcXZ8lP)SkMAt80C9pkXE1gxNnib97bXaHiTuvGovcmwTGpAk1WSTzl8OrNdHGEsYYubcaxbnbsStXnPsGXQf8rtPoqAUpBHtXnNdHGUWfwaCn3tCKRwwIgLM9uaMRxejUsHItTIe0GLtbCUr0OujWy1c(OPuVisCLcfNAfjCJFuI9QnUoBqc63lmOePHbPQa95qiOdLTaeUQdQaP5UMaj2)rR8zRVaploxGNjVeINTagqsHq6NnHNTagqsVSLNLpt0(Z6WZOHMgEg(sswa(ZKFbSNnWlB5z(f4zRGww)Se7vBptuCx)S1ePlB5zE)SdisPFgnnL(zD4z0aP5(ZgmVepZVae4zjbEM1pJgAA4z4ljzb4plTZZS(zj2RXWZObsFfSNrJsM8NjVheNNjG88mVFw5pZA)ztOSLNnWHZZs)zPqO)rj2R246SbjOFNKsR6GkqAU)JsSxTX1zdsq)omBB2c)hLyVAJRZgKG(9frIRuO4uRiHF0kF2kmEzlpBf3g8So8SvClopR4plU5Uq6NrJNMSFMbdojfptE5xEMFbE2kOL1pZtYc4pZVqa(LwC46NjR8N1Mq6NnbChd8NDamy(ZwYYEM8YV8mspSCri9ZwrpRjplUjWZ8KSaox)JsSxTX1zdsq)oUnq1bfUfNFuI9QnUoBqc63h4GQCiwklJb6EDaU3KyfUpGmqQkqFoec6clTAmugxFA5gfZHqqtgmq1bf1woq0NwU9JsSxTX1zdsq)(ahuLdXsbHaGDLLXaDS0yr7K2kSAksUlvfOphcbDHLwngkJRpTCJI5qiOjdgO6GIAlhi6tl3(rj2R246SbjOFpqAUpBH)JsSxTX1zdsq)oofcvI9QnLO4Uuwgd0J7Xqmy(pkXE1gxNnib97fguI0WWp6hLyVAJRXDloTCJtFzijNknvhu5vG0(LFuI9QnUg3T40YnUe0VxyPvJHY4)Oe7vBCnUBXPLBCjOFpUiKMOQ4Cb(rR8z00bdEwhEgnPLdKNv8NLc5P08NnWHZZKx(LNrdK(kypJgLm1pBfys)mbe8EmqEg(sswa(Zs)z(f4zGDEwhEMFbEwOwU4pJFPheNNnHNnWHJupRoqkes)Sk8m)c8SzZ5p70a3KH(Zof8SYEMFbEwCDoc4zD4z(f4z00bdE2Cie0)Oe7vBCnUBXPLBCjOFNmyGQdkQTCGivfOtLaJvl4JMsDG0xbt1Kz0OEfdkVvNcULszlbo5UYRyGcVIbL3QtbRwMY(hTYNrJApJx2IaEMNKfWFwOwU4CPEMFbEgUBXPLBpRdpJMoyWZ6WZOjTCG8SI)mrlhipZVK2Z8lWZWDloTC7zD4z0aPVc2ZOrjtPEMFP4pBPgd8NbYaNKpJMoyWZ6WZOjTCG8m8LKSa8N5xs)z8l9G48Sj8SboCEM8YV8Se71y4zEkaZ5s9Sk8mQnNxtbO)rj2R24AC3Itl34sq)oofcvI9QnLO4Uuwgd09uaMRinvPQaDpfG5AYGbQoOO2YbIgSCkGdfj2RXGcmiUaoDkPa3T40YnnzWavhuuB5arhgecfbWxsYcO8kgwnUBXPLB6aPVcMQjtnbIZY4)Oe7vBCnUBXPLBCjOFNA7vBsvb6ujWy1c(OPuxyPvJHY4rJ6vmO8wDky1rq2)Oe7vBCnUBXPLBCjOFFGdQYHyPSmgOptbekcOMK0WxKQc0PzpfG56frIRuO4uRibny5uaNOrNdHGEsYYubcaxbnbsStbvcmwTGpAk1lIexPqXPwrc)Oe7vBCnUBXPLBCjOFFGdQYHy(pkXE1gxJ7wCA5gxc63NIUpQWar6FuI9QnUg3T40YnUe0Vpbchirw2YpkXE1gxJ7wCA5gxc63f1YfNRwLholXG5)Oe7vBCnUBXPLBCjOFpueyk6(8JsSxTX14UfNwUXLG(90Wa3jPqHtH4h9Jw5ZK1CoyyG)mQKQjLl9Zcn5zK2tVAtZ90oj58S0opJ0E6vBARvfguI0WG(hLyVAJRbohmmWPhA8ahoQ8kqkhutiJLQc0NdHGMmyGQdkQTCGOpTClA0e71yqbgexa)2i8JsSxTX1aNdgg4sq)Eme3ePvDqjgW1rDiqgZLQc0tSxJbfyqCb8vhrkU5Cie0fUWcGR5EIJC10PmAuA2tbyUErK4kfko1ksqdwofW5guG7wCA5Moq6RGPAYutG4Sm(Tuk7FuI9QnUg4CWWaxc63NIUpQoO8lGcmiwAPQa9B6PamxVisCLcfNAfjOblNc4qXCie0fUWcGR5EIJKEeP4MZHqqpjzzQabGRGMaj2JgLkbgRwWhnLAy22Sf(nUr0O38Mj2RXGcmiUa(TriAuA2tbyUErK4kfko1ksqdwofW5guCtQeySAbF0uQdK(kyQMmJgDH0d2rLnOdK(kyQMm1eiolJFBeVXn(rj2R24AGZbddCjOFN6aPcsx2IAksUlvfOphcbnzWavhuuB5arFA5w0Oj2RXGcmiUa(Tr4hLyVAJRbohmmWLG(DsrLQauLP4utmivfOphcbnzWavhuuB5arFA5w0Oj2RXGcmiUa(Tr4hLyVAJRbohmmWLG(DCByWCs6WrfezmiLOmqHp0xvPQa95qiOjdgO6GIAlhi6tl3(rj2R24AGZbddCjOF3VaQbB2d2rfAcgKQc0NdHGMa4ifaNRcnbd6bQ)Oe7vBCnW5GHbUe0VlVjIZyOmfb4TLggKQc0NdHGMmyGQdkQTCGOpTClA0e71yqbgexa)2i8J(rR8zYAohmmWFgvs1KYL(zHM8ms7PxTPdK(kyQMm)rj2R24AGZbddCvtM0dnEGdhvEfiLdQjKXsvb6ZHqqtgmq1bf1woq0NwUrXbMdHGMAIJeoQcd6tl3IgnXEnguGbXfWVnc)Oe7vBCnW5GHbUQjtjOFpgIBI0QoOed46OoeiJ5svb6j2RXGcmiUa(QJifhyoecAQjos4OkmOpTCJcC3Itl30bsFfmvtMAceNLXVnIuqZj2R20bsFfmvtM6YubrTCXPyH0d2rLnOdK(kyQMm1eiolJtx2)Oe7vBCnW5GHbUQjtjOFFk6(O6GYVakWGyPLQc0PsGXQf8rtPoq6RGPAYmA0fspyhv2Goq6RGPAYutG4Sm(Tr8hLyVAJRbohmmWvnzkb97uhivq6YwutrYDPQa95qiOjdgO6GIAlhi6tl3O4aZHqqtnXrchvHb9PLBrJMyVgdkWG4c43gHFuI9QnUg4CWWax1KPe0VtkQufGQmfNAIbPQa95qiOjdgO6GIAlhi6tl3O4aZHqqtnXrchvHb9PLBrJMyVgdkWG4c43gHFuI9QnUg4CWWax1KPe0VJBddMtshoQGiJbPeLbk8H(QkvfOphcbnzWavhuuB5arFA5gfhyoecAQjos4OkmOpTC7hLyVAJRbohmmWvnzkb97(fqnyZEWoQqtWGuvG(Cie0eahPa4CvOjyqpq9hLyVAJRbohmmWvnzkb97YBI4mgktraEBPHbPQa95qiOjdgO6GIAlhi6tl3O4aZHqqtnXrchvHb9PLBrJMyVgdkWG4c43gHF0pALplXE1gxh3JHyWC6trzrkvfOh3JHyWC9P4EAy4wkL9pALplXE1gxh3JHyWCjOFNFPIJbIuvGECpgIbZ1NI7PHHBPu2)Oe7vBCDCpgIbZLG(9cdQGObUuvG(Cie0fgubrdC9PLB)OF0kF2USfb8S1jzb8Nrtivtkx6NfAYZiTNE1MM7PDsY5znvVAt)JsSxTX18YweGI7PDsYrc63dIbcrAPQaDpfG5Ay22SfUgSCkGdfujWy1c(OPudZ2MTWP4M0SNcWC9IiXvkuCQvKGgSCkGt0OZHqqx4claUM7joYvllrJohcb9KKLPceaUcAcKy)g)Oe7vBCnVSfbO4EANKCKG(9GyGqKwQkq3tbyUErK4kfko1ksqdwofWHcQeySAbF0uQxejUsHItTIeOyoec6jjltfiaCf0eiX(pkXE1gxZlBrakUN2jjhjOFpigiePLQc0PsGXQf8rtPoqAUpBHtXCie0tswMkqa4kOjqIDkUjn7PamxVisCLcfNAfjOblNc4en6Cie0fUWcGR5EIJC1YYn(rj2R24AEzlcqX90oj5ib974uiuj2R2uII7szzmqh4CWWa)hLyVAJR5LTiaf3t7KKJe0Vhi9vWunz(JsSxTX18YweGI7PDsYrc63NI661KCKQc0tSxJbfyqCb8BLz0Oj2RXGcmiUa(Tusbo5UYRyGUSPyoec6qzlaHR6GkqAURjqI9vlZFuI9QnUMx2IauCpTtsosq)EHbLinmivfOphcbDOSfGWvDqfin31eiX(pkXE1gxZlBrakUN2jjhjOFh3XGR4EtI)rj2R24AEzlcqX90oj5ib97WSTzl8FuI9QnUMx2IauCpTtsosq)ojLw1bvG0CxQkqNMtSxTPdK(kyQMm1LPcIA5ItXcPhSJkBqhi9vWunzQjqCwgNUS)rj2R24AEzlcqX90oj5ib97trD9Asosvb64K7kVIb6YoA0e71yqbgexa)wk)rj2R24AEzlcqX90oj5ib97lIexPqXPwrcsvb6ZHqqpjzzQabGRGMaj2JgLkbgRwWhnLAy22SfE0Oj2RXGcmiUa(TusHNcWCnNQOCVSfvHbny5uaNF0pALpBx2IaE26KSa(ZOjKQjLl9Zcn5z(f4zK2tVAtBTQWGsKggEwt1R20)Oe7vBCnVSfbOSwjsddsq)EqmqislvfO7PamxdZ2MTW1GLtbCOGkbgRwWhnLAy22SfofZHqqpjzzQabGRGMaj2)rj2R24AEzlcqzTsKggKG(9GyGqKwQkqNkbgRwWhnL6frIRuO4uRibkMdHGEsYYubcaxbnbsS)JsSxTX18YweGYALinmib974uiuj2R2uII7szzmqh4CWWa)hLyVAJR5LTiaL1krAyqc63dK(kyQMm)rj2R24AEzlcqzTsKggKG(9POUEnjhPQa9e71yqbgexa)wzgnAI9AmOadIlGFlLuqZEkaZ1CQIY9Ywufg0GLtbC(rj2R24AEzlcqzTsKggKG(DChdUI7nj(hLyVAJR5LTiaL1krAyqc63HzBZw4svb6ZHqqx4claUM7jos6rKcAEoec6jjltfiaCf0eiX(pkXE1gxZlBrakRvI0WGe0VVisCLcfNAfjivfOphcb9KKLPceaUcAcKypAuQeySAbF0uQHzBZw4rJ6PamxxgonhiCvq0Y1GLtbCOaNCx5vmiHtYXGq5vmCBz40CGWvbrlx5vmO8whr9avkWj3vEfds4KCmiuEfdRUmCAoq4QGOLR8kguERLf9PLB)OF0kF2USfb8S1jzb8Nrtivtkx6NfAYZ8lWZiTNE1Moq6RGPAY8znvVAt)JsSxTX18YweGQjtjOFhNcHkXE1MsuCxklJb6aNdgg4QMm)rj2R24AEzlcq1KPe0Vhi9vWunz(JsSxTX18YweGQjtjOFpigiePLQc0PsGXQf8rtPgMTnBHtXCie0tswMkqa4kOjqI9FuI9QnUMx2Iaunzkb97trD9Asosvb6j2RXGcmiUa(TYmA0e71yqbgexa)wkPaNCx5vmqx2)Oe7vBCnVSfbOAYuc63lmOePHbPQa95qiOdLTaeUQdQaP5UMaj2Pa3T40YnDG0xbt1KPMaXzz8BJy0OZHqqhkBbiCvhubsZDnbsStxM)Oe7vBCnVSfbOAYuc63NI661KCKQc0Xj3vEfd0L9pkXE1gxZlBraQMmLG(9GyGqKwQkqNkbgRwWhnLAy22Sf(pkXE1gxZlBraQMmLG(9GyGqKwQkqFoec6jjltfiaCf0eiXof3KkbgRwWhnL6aP5(SfE0OhyoecAQjos4OkmOjqCwg)wqga4bhuEfdsKyVAtxyqjsddANKJbHYRy4g)Oe7vBCnVSfbOAYuc63XDm4kU3K4FuI9QnUMx2Iaunzkb97WSTzl8FuI9QnUMx2Iaunzkb97KuAvhubsZDPQa9dmhcbn1ehjCufg0duLQmhiKbQUQc0NdHGou2cq4QoOcKM7AcKyNUmLQmhiKbQUQIJHtLoqNYFuI9QnUMx2Iaunzkb97trD9Aso)OF0kFMSYEgVJHNXlFi9QnUupt6E4z40Eg)s6oqEMScdptYEC(mymypldoqEwkiqEK(z4K7LT8mAqmqis)S0optwHHNTkLgg0pJg1Vae5fhEMFP4plXE12Zk(Zg4W5zYVa2Z8lWZIZf4zxs(ZOHMgEwgCG8mCY9YwEgnigiePL6zCaEwo7XG(hLyVAJR5LTia6fguwpoLQc0XDloTCtxyqz94utG8infhyoecA5L5aHRWxkHqpq9hLyVAJR5LTiajOFhNcHkXE1MsuCxklJb68YweGI7PDsYrQkqN0E6vBAUN2jjNFuI9QnUMx2IaKG(DCkeQe7vBkrXDPSmgOZlBrakRvI0WGuvGoP90R20wRkmOePHHFuI9QnUMx2IaKG(DCkeQe7vBkrXDPSmgOZlBraQMmLQc0jTNE1Moq6RGPAY8hLyVAJR5LTiajOFVWGY6X5pkXE1gxZlBrasq)(ahuLdXszzmq3RdW9MeRW9bKbsvb6ZHqqxyPvJHY46tl3OyoecAYGbQoOO2YbI(0YTFuI9QnUMx2IaKG(9boOkhILccba7klJb6yPXI2jTvy1uKCxQkqFoec6clTAmugxFA5gfZHqqtgmq1bf1woq0NwU9JsSxTX18YweGe0Vhin3NTW)rj2R24AEzlcqc63XPqOsSxTPef3LYYyGECpgIbZLQc0J7XLT8JsSxTX18YweGe0Vxyqjsdd)OF0kF2ku5xEgnorIRu8Sn1ksqQNrthm4zD4z0KwoqEg)spiopBcpBGdNNrQLl(ZMqOjWZ8lWZOXjsCLINTPwrcpd3XZ(z3S0G(zYl)YZI4ZKv4cla(Zs78S8z0sYYEgnqa4kCd9ZwHUa2ZK1Z2MTWFwXFwhcpd3T40YnPEgnDWGN1HNrtA5a5z40Ewk49ZMWZg4W5zRYdC)zYl)YZI4ZKv4claU(hLyVAJR9uaMRinv6KbduDqrTLdePQaDpfG56frIRuO4uRibny5uahkMdHGUWfwaCn3tCK0Jif3Coec6jjltfiaCf0eiXE0OEkaZ1WSTzlCny5uahkWDloTCtdZ2MTW1eiolJVACYDLxXWn(rR8zRqLFPh8NrJtK4kfpBtTIeK6z00bdEwhEgnPLdKNXV0dIZZMWZg4W5zti0e4zPj9ZM1YcqEgUBXPLBp7MY6zBZw4s9SvChd(Z2EtIL6z00u6N1HNrdKM734zn5zYVa2ZOPdg8So8mAslhipR4plN9G)mVFgbs8LNjZNHVKKfGR)rj2R24ApfG5kstvc63jdgO6GIAlhisvb60SNcWC9IiXvkuCQvKGgSCkGdf30tbyUgMTnBHRblNc4qbUBXPLBAy22SfUMaXzz8vJtUR8kgIg1tbyUg3XGR4EtI1GLtbCOa3T40YnnUJbxX9MeRjqCwgF14K7kVIHOr9uaMRjP0QoOcKM7AWYPaouG7wCA5MMKsR6GkqAURjqCwgF14K7kVIHOrXxsYcWvbsI9QTuClLAz0nqoYria]] )


end
