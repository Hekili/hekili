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

    
    spec:RegisterPack( "Frost Mage", 20190803.1530, [[dOeKsbqicrEKsGnHe9jcHmkvL4uQkPxraZIGClLqyxK6xQQAyesDmKKLPq4zesMgHGRPq02uvk(MsqACkH05ieQ1HecZtju3dPSpKGdQeuwisQhQeunrKqKlsiQ2OQs1hvcrnsLGOojHOSsHYmvcrUPQsj7Ka9tvLsnuKqAPiHYtvQPQeDvLGiFvjiSxi)LKbJYHfTyf9yOMSQCzWMf8zL0OvvCAjRgje1RvinBIUTq2nv)wQHJuTCephvtNY1vW2vO(oHA8iHQZtqTEvvMVq1(vzevOLO9lnaj4ienvIyrVOIwuAQgPOebrGk02eMoG20t8O5kG2EgbO93jn3o23kxb0MEkSSZhAjAZ7bcgq7pMrNtr8))AzFgMACh9NxrdY0Q2XKmy)5ve(pAphkPjYC0eTFPbibhHOPsel6fv0Ist1ifLiikraTZb7ttq7DfTWr7p17boAI2pGJr7fCSVtAUDSVvUcxSfCSpMrNtr8))AzFgMACh9NxrdY0Q2XKmy)5ve()fBbhl2Gu4JnIfvOJncrtLi(ylIJrLOPie1IEXUyl4yl8pPVcCkIl2co2I4ylK4WXerwfbkRvVcerhRCUb57yD4yIiljRGPTkcuwREfiIowOjhtMC7yCa3(7ylCkshBGNRG(ITGJTio23ciRWX(oP52X(w5kCSfgfDrIFSVmto8ow7hBfCGKwt4hR8JXXQOCf0y60)kAllUXrlrBGZbhdCvtMOLibPcTeTbpNs4HOgTXKYasLO9Cie0KbhuDqrVfde9Rf7hJYJ9G5qiOPN4rHNQWG(1I9Jfp(XsSvJbf4qub8JrHJjk0oXw1oAhA8ahEQ8hqkdutiJqgsWrGwI2GNtj8quJ2yszaPs0oXwnguGdrfWp2Ip2ipgLh7bZHqqtpXJcpvHb9Rf7hJYJH7w(AXUoq6FGRAYutGOSC(XOWXg5XO8yI0XsSvTRdK(h4QMm1LRcYA9JDmkp2kPh8NkBqhi9pWvnzQjquwo)y0oMOr7eBv7ODee1eHvDqjhW1t9iqgXrgsqrHwI2GNtj8quJ2yszaPs0MobgRwXpnv6aP)bUQjZJfp(Xwj9G)uzd6aP)bUQjtnbIYY5hJchBKODITQD0Ek7(P6GY(akWHiHrgsqraTeTbpNs4HOgTXKYasLO9Cie0KbhuDqrVfde9Rf7hJYJ9G5qiOPN4rHNQWG(1I9Jfp(XsSvJbf4qub8JrHJjk0oXw1oAtFGubHlFvnLj3qgsWrIwI2GNtj8quJ2yszaPs0EoecAYGdQoOO3IbI(1I9Jr5XEWCie00t8OWtvyq)AX(XIh)yj2QXGcCiQa(XOWXefANyRAhTjfD6sqvUItpXaYqc(nOLOn45ucpe1ODITQD0g3ogCJKg8ubzgbOnMugqQeTNdHGMm4GQdk6TyGOFTy)yuEShmhcbn9epk8ufg0VwSJ2YYbf(H2FdYqcUqrlrBWZPeEiQrBmPmGujAphcbnbWJkboxfAcg0d0r7eBv7OT9bud(Sh8Nk0emGmKGlkAjAdEoLWdrnAJjLbKkr75qiOjdoO6GIElgi6xl2pgLh7bZHqqtpXJcpvHb9Rf7hlE8JLyRgdkWHOc4hJchtuODITQD0wCtKVXq5kcWBpDmGmKH2aNdog4OLibPcTeTbpNs4HOgTXKYasLO9Cie0KbhuDqrVfde9Rf7hlE8JLyRgdkWHOc4hJchtuODITQD0o04bo8u5pGugOMqgHmKGJaTeTbpNs4HOgTXKYasLODITAmOahIkGFSfFSrEmkp2xo2Cie0fUWsGR5wIh9ylM2XO6yXJFmr6ywkb30RYexPuXPxJcAWZPeEh7RhJYJH7w(AXUoq6FGRAYutGOSC(XOWXOs0ODITQD0ocIAIWQoOKd46PEeiJ4idjOOqlrBWZPeEiQrBmPmGujA)LJzPeCtVktCLsfNEnkObpNs4Dmkp2Cie0fUWsGR5wIh9y0o2ipgLh7lhBoec6jjlxfia8d0eiX2XIh)y0jWy1k(PPsdZ2NT0o2xp2xpw84h7lh7lhlXwnguGdrfWpgfoMOow84htKoMLsWn9QmXvkvC61OGg8CkH3X(6XO8yF5y0jWy1k(PPshi9pWvnzES4Xp2kPh8NkBqhi9pWvnzQjquwo)yu4yJ8yF9yFfTtSvTJ2tz3pvhu2hqboejmYqckcOLOn45ucpe1OnMugqQeTNdHGMm4GQdk6TyGOFTy)yXJFSeB1yqboeva)yu4yIcTtSvTJ20hivq4YxvtzYnKHeCKOLOn45ucpe1OnMugqQeTNdHGMm4GQdk6TyGOFTy)yXJFSeB1yqboeva)yu4yIcTtSvTJ2KIoDjOkxXPNyazib)g0s0g8CkHhIA0oXw1oAJBhdUrsdEQGmJa0gtkdivI2ZHqqtgCq1bf9wmq0VwSJ2YYbf(H2FdYqcUqrlrBWZPeEiQrBmPmGujAphcbnbWJkboxfAcg0d0r7eBv7OT9bud(Sh8Nk0emGmKGlkAjAdEoLWdrnAJjLbKkr75qiOjdoO6GIElgi6xl2pw84hlXwnguGdrfWpgfoMOq7eBv7OT4MiFJHYveG3E6yazidT5LVkbf3s)LKhAjsqQqlrBWZPeEiQrBmPmGujABPeCtdZ2NT00GNtj8ogLhJobgRwXpnvAy2(SL2XO8yF5yI0XSucUPxLjUsPItVgf0GNtj8ow84hBoec6cxyjW1ClXJESfFmr4yXJFS5qiONKSCvGaWpqtGeBh7RODITQD0oihieHrgsWrGwI2GNtj8quJ2yszaPs02sj4MEvM4kLko9AuqdEoLW7yuEm6eySAf)0uPxLjUsPItVgfogLhBoec6jjlxfia8d0eiXgANyRAhTdYbcryKHeuuOLOn45ucpe1OnMugqQeTPtGXQv8ttLoqAUnBPDmkp2Cie0tswUkqa4hOjqITJr5X(YXePJzPeCtVktCLsfNEnkObpNs4DS4Xp2Cie0fUWsGR5wIh9yl(yIWX(kANyRAhTdYbcryKHeueqlrBWZPeEiQr7eBv7OnoLsvITQDLS4gAllUP8mcqBGZbhdCKHeCKOLODITQD0oq6FGRAYeTbpNs4HOgzib)g0s0g8CkHhIA0gtkdivI2j2QXGcCiQa(XOWXgXXIh)yj2QXGcCiQa(XOWXO6yuEmCYnLvrWXODmrFmkp2Cie0HYxbcx1bvG0CttGeBhBXhBeODITQD0EkRF)sYdzibxOOLOn45ucpe1OnMugqQeTNdHGou(kq4QoOcKMBAcKydTtSvTJ2fguY0XaYqcUOOLODITQD0g3rGP4wtIqBWZPeEiQrgsqrmAjANyRAhTHz7ZwAOn45ucpe1idjivIgTeTbpNs4HOgTXKYasLOTiDSeBv76aP)bUQjtD5QGSw)yhJYJTs6b)PYg0bs)dCvtMAceLLZpgTJjA0oXw1oAtsHvDqfin3qgsqQOcTeTbpNs4HOgTXKYasLOno5MYQi4y0oMOpw84hlXwnguGdrfWpgfogvODITQD0EkRF)sYdzibPAeOLOn45ucpe1OnMugqQeTNdHGEsYYvbca)anbsSDS4XpgDcmwTIFAQ0WS9zlTJfp(XsSvJbf4qub8JrHJr1XO8ywkb30C6YYSYxvfg0GNtj8q7eBv7O9QmXvkvC61OaYqgAZlFvcQMmrlrcsfAjAdEoLWdrnANyRAhTXPuQsSvTRKf3qBzXnLNraAdCo4yGRAYezibhbAjANyRAhTdK(h4QMmrBWZPeEiQrgsqrHwI2GNtj8quJ2yszaPs0MobgRwXpnvAy2(SL2XO8yZHqqpjz5QabGFGMaj2q7eBv7ODqoqicJmKGIaAjAdEoLWdrnAJjLbKkr7eB1yqboeva)yu4yJ4yXJFSeB1yqboeva)yu4yuDmkpgo5MYQi4y0oMOr7eBv7O9uw)(LKhYqcos0s0g8CkHhIA0gtkdivI2ZHqqhkFfiCvhubsZnnbsSDmkpgUB5Rf76aP)bUQjtnbIYY5hJchBKhlE8JnhcbDO8vGWvDqfin30eiX2XODSrG2j2Q2r7cdkz6yazib)g0s0g8CkHhIA0gtkdivI24KBkRIGJr7yIgTtSvTJ2tz97xsEidj4cfTeTbpNs4HOgTXKYasLOnDcmwTIFAQ0WS9zln0oXw1oAhKdeIWidj4IIwI2GNtj8quJ2yszaPs0Eoec6jjlxfia8d0eiX2XO8yF5y0jWy1k(PPshin3MT0ow84h7bZHqqtpXJcpvHbnbIYY5hJchdO4aEWaLvrWXe4yj2Q21fguY0XG2i5yqQSkco2xr7eBv7ODqoqicJmKGIy0s0oXw1oAJ7iWuCRjrOn45ucpe1idjivIgTeTtSvTJ2WS9zln0g8CkHhIAKHeKkQqlrBWZPeEiQr7eBv7Onjfw1bvG0CdTl3aczGUPQaAphcbDO8vGWvDqfin30eiXgTrG2LBaHmq3uvue8Q0a0Mk0gtkdivI2pyoecA6jEu4PkmOhOJmKGunc0s0oXw1oApL1VFj5H2GNtj8quJmKH2wkb3uKMoAjsqQqlrBWZPeEiQrBmPmGujABPeCtVktCLsfNEnkObpNs4Dmkp2Cie0fUWsGR5wIh9y0o2ipgLh7lhBoec6jjlxfia8d0eiX2XIh)ywkb30WS9zlnn45ucVJr5XWDlFTyxdZ2NT00eiklNFSfFmCYnLvrWX(kANyRAhTjdoO6GIElgiidj4iqlrBWZPeEiQrBmPmGujAlshZsj4MEvM4kLko9AuqdEoLW7yuESVCmlLGBAy2(SLMg8CkH3XO8y4ULVwSRHz7ZwAAceLLZp2Ipgo5MYQi4yXJFmlLGBAChbMIBnjsdEoLW7yuEmC3Yxl214ocmf3AsKMarz58JT4JHtUPSkcow84hZsj4MMKcR6GkqAUPbpNs4DmkpgUB5Rf7AskSQdQaP5MMarz58JT4JHtUPSkcow84hd)jjRaxfij2Q2t5XOWXOslIp2xr7eBv7OnzWbvhu0BXabzidT5LVkbL3kz6yaTejivOLOn45ucpe1OnMugqQeTTucUPHz7ZwAAWZPeEhJYJrNaJvR4NMknmBF2s7yuES5qiONKSCvGaWpqtGeBODITQD0oihieHrgsWrGwI2GNtj8quJ2yszaPs0MobgRwXpnv6vzIRuQ40RrHJr5XMdHGEsYYvbca)anbsSH2j2Q2r7GCGqegzibffAjAdEoLWdrnANyRAhTXPuQsSvTRKf3qBzXnLNraAdCo4yGJmKGIaAjANyRAhTdK(h4QMmrBWZPeEiQrgsWrIwI2GNtj8quJ2yszaPs0oXwnguGdrfWpgfo2iow84hlXwnguGdrfWpgfogvhJYJjshZsj4MMtxwMv(QQWGg8CkHhANyRAhTNY63VK8qgsWVbTeTtSvTJ24ocmf3AseAdEoLWdrnYqcUqrlrBWZPeEiQrBmPmGujAphcbDHlSe4AUL4rpgTJnYJr5XePJnhcb9KKLRcea(bAcKydTtSvTJ2WS9zlnKHeCrrlrBWZPeEiQrBmPmGujAphcb9KKLRcea(bAcKy7yXJFm6eySAf)0uPHz7ZwAhlE8JzPeCtxooDdiCvq2I1GNtj8ogLhdNCtzveCmboMrYXGuzveCmkCSYXPBaHRcYwSYQiqzTEK6b6hJYJHtUPSkcoMahZi5yqQSkco2Ipw540nGWvbzlwzveOSwlc6xl2r7eBv7O9QmXvkvC61OaYqgAh1JHiWn0sKGuHwI2GNtj8quJ2yszaPs0Eoec6cdQGSbU(1ID0oXw1oAxyqfKnWrgYqB6ea3rZ0qlrcsfAjANyRAhTtcoDqvUbsjGn0g8CkHhIAKHeCeOLODITQD0wCAarbsicClLOn45ucpe1idjOOqlrBWZPeEiQrBpJa0o)X)KKKRcTBQoOO3IbcANyRAhTZF8pjj5Qq7MQdk6TyGGmKGIaAjANyRAhTJkcPjQkkxb0g8CkHhIAKHeCKOLODITQD0MEBv7On45ucpe1idj43GwI2j2Q2r7aP52SLgAdEoLWdrnYqgANnGwIeKk0s0oXw1oAhi9pWvnzI2GNtj8quJmKGJaTeTtSvTJ2tz97xsEOn45ucpe1idjOOqlrBWZPeEiQr7eBv7OnoLsvITQDLS4gAllUP8mcqBGZbhdCKHeueqlr7eBv7OnUJatXTMeH2GNtj8quJmKGJeTeTtSvTJ2fguEporBWZPeEiQrgsWVbTeTbpNs4HOgTXKYasLOnDcmwTIFAQ0WS9zlTJfp(XMdHGEsYYvbca)anbsSDmkp2xogDcmwTIFAQ0bsZTzlTJr5X(YXMdHGUWfwcCn3s8OhBXhteow84htKoMLsWn9QmXvkvC61OGg8CkH3X(6XIh)y0jWy1k(PPsVktCLsfNEnkCSVI2j2Q2r7GCGqegzibxOOLOn45ucpe1OnMugqQeTNdHGou(kq4QoOcKMBAcKydTtSvTJ2fguY0XaYqcUOOLODITQD0MKcR6GkqAUH2GNtj8quJmKGIy0s0oXw1oAdZ2NT0qBWZPeEiQrgsqQenAjANyRAhTxLjUsPItVgfqBWZPeEiQrgsqQOcTeTtSvTJ242bvhu4w(qBWZPeEiQrgsqQgbAjAdEoLWdrnANyRAhTT6bCRjrkC)akoAJjLbKkr75qiOlSWQXq5C9Rf7hJYJnhcbnzWbvhu0BXar)AXoA7zeG2w9aU1KifUFafhzibPsuOLOn45ucpe1ODITQD0glmw2gP9cRMYKBOnMugqQeTNdHGUWcRgdLZ1VwSFmkp2Cie0KbhuDqrVfde9Rf7Oneca2uEgbOnwySSns7fwnLj3qgsqQeb0s0oXw1oAhin3MT0qBWZPeEiQrgsqQgjAjAdEoLWdrnANyRAhTXPuQsSvTRKf3qBzXnLNraAh1JHiWnKHeKQVbTeTtSvTJ2fguY0XaAdEoLWdrnYqgAJ7w(AXohTejivOLODITQD0EDijVkDvhu5pG02h0g8CkHhIAKHeCeOLODITQD0UWcRgdLZrBWZPeEiQrgsqrHwI2j2Q2r7OIqAIQIYvaTbpNs4HOgzibfb0s0g8CkHhIA0gtkdivI20jWy1k(PPshi9pWvnzES4XpMvrGYA1RGJrHJrLOpMahdNCtzveCmkpMvrGYA1RGJT4JncrJ2j2Q2rBYGdQoOO3IbcYqcos0s0g8CkHhIA0gtkdivI2wkb30KbhuDqrVfden45ucVJr5XsSvJbf4qub8Jr7yuDmkpgUB5Rf7AYGdQoOO3IbIomiLkcG)KKvqzveCSfFmC3Yxl21bs)dCvtMAceLLZr7eBv7OnoLsvITQDLS4gAllUP8mcqBlLGBksthzib)g0s0g8CkHhIA0gtkdivI20jWy1k(PPsxyHvJHY5hlE8JzveOSw9k4yl(yIs0ODITQD0MEBv7idj4cfTeTtSvTJ2dCqvgeXrBWZPeEiQrgsWffTeTtSvTJ2tz3pvyGimAdEoLWdrnYqckIrlr7eBv7O9eiCGmA5ROn45ucpe1idjivIgTeTtSvTJ2YA9JXvuKhERrGBOn45ucpe1idjivuHwI2j2Q2r7qrGPS7hAdEoLWdrnYqcs1iqlr7eBv7OD6yGBKuQWPuI2GNtj8quJmKH28YxLaAjsqQqlrBWZPeEiQrBmPmGujAJ7w(AXUUWGY7XPMa5t4Jr5XEWCie0Il3acxH)usPEGoANyRAhTlmO8ECImKGJaTeTbpNs4HOgTXKYasLOnPT0Q21Cl9xsEODITQD0gNsPkXw1UswCdTLf3uEgbOnV8vjO4w6VK8qgsqrHwI2GNtj8quJ2yszaPs0M0wAv7AVvfguY0XaANyRAhTXPuQsSvTRKf3qBzXnLNraAZlFvckVvY0XaYqckcOLOn45ucpe1OnMugqQeTjTLw1Uoq6FGRAYeTtSvTJ24ukvj2Q2vYIBOTS4MYZiaT5LVkbvtMidj4irlr7eBv7ODHbL3Jt0g8CkHhIAKHe8BqlrBWZPeEiQr7eBv7OTvpGBnjsH7hqXrBmPmGujAphcbDHfwngkNRFTy)yuES5qiOjdoO6GIElgi6xl2rBpJa02QhWTMePW9dO4idj4cfTeTbpNs4HOgTtSvTJ2yHXY2iTxy1uMCdTXKYasLO9Cie0fwy1yOCU(1I9Jr5XMdHGMm4GQdk6TyGOFTyhTHqaWMYZiaTXcJLTrAVWQPm5gYqcUOOLODITQD0oqAUnBPH2GNtj8quJmKGIy0s0g8CkHhIA0gtkdivI2r94Yxr7eBv7OnoLsvITQDLS4gAllUP8mcq7OEmebUHmKGujA0s0oXw1oAxyqjthdOn45ucpe1idzO9dc5G0qlrcsfAjANyRAhTX9GBaHthKs0g8CkHhIAKHeCeOLOn45ucpe1OnMugqQeTfPJrAlTQDT3Qcdkz6y4yuEm6eySAf)0uPdYbcr4Jr5XePJnhcbDO8vGWvDqfin30eiXgANyRAhTlmOKPJbKHeuuOLOn45ucpe1ODITQD0gNsPkXw1UswCdTLf3uEgbOnUB5Rf7CKHeueqlrBWZPeEiQrBmPmGujANyRgdkWHOc4hJchtuhJYJzPeCthia8R8vfjlxdEoLW7yXJFSeB1yqboeva)yu4yIaANyRAhTXPuQsSvTRKf3qBzXnLNraANnGmKGJeTeTbpNs4HOgTtSvTJ24ukvj2Q2vYIBOTS4MYZiaT5LVkbKHmKH2JbcVAhj4ienvIyrVOIwuOT4K4LVYrBrwe9MyW7yunIJLyRA)yYIBC9fdT50bmsWVreqB6KousaTxWX(oP52X(w5kCXwWX(ygDofX))RL9zyQXD0FEfnitRAhtYG9Nxr4)xSfCSydsHp2iwuHo2ienvI4JTiogvIMIqul6f7ITGJTW)K(kWPiUyl4ylIJTqIdhtezveOSw9kqeDSY5gKVJ1HJjISKScM2QiqzT6vGi6yHMCmzYTJXbC7VJTWPiDSbEUc6l2co2I4yFlGSch77KMBh7BLRWXwyu0fj(X(Ym5W7yTFSvWbsAnHFSYpghRIYvqJPt)RxSl2coMiNId4bdEhBcHMahd3rZ0o2ewlNRp2cdJb6g)yE7lIpjjkmipwITQD(XAxkS(ITGJLyRANRPtaChntJwqM8rVyl4yj2Q25A6ea3rZ0eG2)q3Vl2cowITQDUMobWD0mnbO9phwJa3sRA)ILyRANRPtaChnttaA)tcoDqvUbsjGTlwITQDUMobWD0mnbO9Npef1UsCAarbsicClLxSfCSeBv7CnDcG7OzAcq7p3t68pTP4wA8lwITQDUMobWD0mnbO9FGdQYGiH8mcOL)4FssYvH2nvhu0BXa5ILyRANRPtaChnttaA)JkcPjQkkxHlwITQDUMobWD0mnbO9NEBv7xSeBv7CnDcG7OzAcq7FG0CB2s7IDXwWXe5uCapyW7yWyGi8XSkcoM9bowITMCSIFSCCwYCkb9flXw1oNgUhCdiC6GuEXwWXezHJzFGJfLRWX(K8J99(7hldgqogo5w5RhRCULUDSVlhieHf6yIHJHt)ypqMcFm7dCmrggo2Iu6y4yP)o2ahowBFaYX(uRFogDs1KYe(yj2Q2f6yv4y54SK5uc6lwITQDUa0(xyqjthdcvbAIePT0Q21ERkmOKPJbkPtGXQv8ttLoihieHPuKMdHGou(kq4QoOcKMBAcKy7ILyRANlaT)4ukvj2Q2vYIBc5zeqd3T81ID(fBbhB5h4ywswb7y2hcW)0Y3XkUlISJbu8eB6JrnyIbWpMOweJ8ywswbJl0XSpWXEviaeWXa)ytWedGFm7dCS9YJL(7ylSwKFSeBv7htwCJFSKahJK2hGCmEukL6JTqUfdJbIqh77ea(v(6XOyz5hJobcaHFSbE5RhBH1I8JLyRA)yYIBhJ3TdKJL8Jv2XMGdHY4hBLaPjf(ybshDm7dCSp16NJrNunPmHpg1Y63VK8owITQD9flXw1oxaA)XPuQsSvTRKf3eYZiGw2GqvGwITAmOahIkGtbrrPLsWnDGaWVYxvKSCn45ucV4XtSvJbf4qubCkicxSeBv7CbO9hNsPkXw1UswCtipJaA8YxLWf7ITGJTqu2NJ9Dca)kF9yuSSCHowzIi(XMGza5ywFm6KQjLv)GJnWlF9yFN0)a)yFBY8yI)a(XMT95yF)BFS0FhJAz97xsEhljWX6q4y4ULVwSRp2crzF6b7yFNaWVYxpgfllxOJzFGJHBFmq4WXk(XmYaCSuAF6H1phZ(ah7vHaqahdhR4hlQ8IJhKWXgCRKhBmqe(yFQ1phZsYkyhd3dUX1xSeBv7CD2aTaP)bUQjZlwITQDUoBqaA)NY63VK8Uyj2Q256SbbO9hNsPkXw1UswCtipJaAaNdog4xSeBv7CD2Ga0(J7iWuCRjrxSeBv7CD2Ga0(xyq5948ITGJTRi6YkuW7yFxoqicFmC7VYQ25hlq6OJzFGJTxESeBv7htwCtFSD5y4y2h4yr5kCSIFSvWbsALVESqsoMe48Jrnjl)yFNaWp4y4pjzf4cDm7dCmGINy7y42FLvTFSpabowXDrKDSukpM9jTJvr0BILUPVyj2Q256SbbO9pihieHfQc0OtGXQv8ttLgMTpBPfp(Cie0tswUkqa4hOjqInk)cDcmwTIFAQ0bsZTzlnk)YCie0fUWsGR5wIhDXIq84IKLsWn9QmXvkvC61OGg8CkH3xJhNobgRwXpnv6vzIRuQ40RrHVEXsSvTZ1zdcq7FHbLmDmiufOnhcbDO8vGWvDqfin30eiX2fBbhB5h4yr5kCmXLuESvWbskLcFSjCSvWbsALVES8yY2owho237VFm8NKSc8Jj(d4hBGx(6XSpWXwyTi)yj2Q2pMS4M(yljcx(6XS(ypqMcFmkwk8X6WX(oP52XgCRKhZ(ae4yjboM3h7793pg(tswb(Xs)DmVpwITAmCSVt6FGFSVnzYpM4Eq(oMeY3XS(yLDmVTJnHYxp2ahEhlTJLsP(ILyRANRZgeG2FskSQdQaP52flXw1oxNniaT)WS9zlTlwITQDUoBqaA)xLjUsPItVgfUyl4ylK4LVESfE7WX6WXw4T8DSIFSOMBsHpgfjk6(yomyKuEmXL95y2h4ylSwKFmljRGDm7db4FA5JRpMiZow7sHp2eWDeWp2dWGBhBnl)yIl7ZXi9W6hPWhBHESMCSOMahZsYkyC9flXw1oxNniaT)42bvhu4w(Uyj2Q256SbbO9FGdQYGiH8mcOz1d4wtIu4(buCHQaT5qiOlSWQXq5C9Rf7uohcbnzWbvhu0BXar)AX(flXw1oxNniaT)dCqvgejeeca2uEgb0WcJLTrAVWQPm5MqvG2Cie0fwy1yOCU(1IDkNdHGMm4GQdk6TyGOFTy)ILyRANRZgeG2)aP52SL2flXw1oxNniaT)4ukvj2Q2vYIBc5zeqlQhdrGBxSeBv7CD2Ga0(xyqjthdxSlwITQDUg3T81IDoT1HK8Q0vDqL)asBFUyj2Q25AC3Yxl25cq7FHfwngkNFXsSvTZ14ULVwSZfG2)OIqAIQIYv4ITGJrXgC4yD4yu0wmqowXpwkfNcZp2ahEhtCzFo23j9pWp23Mm1hBH5cFmjeSEmqog(tswb(Xs7y2h4yG)owhoM9bowOw)yhJ)PhKVJnHJnWHNqhREqkLcFSkCm7dCSzZ5h71a3fr2XEfCSYpM9bowu9Es4yD4y2h4yuSbho2Cie0xSeBv7CnUB5Rf7CbO9Nm4GQdk6TyGiufOrNaJvR4NMkDG0)ax1Kz84wfbkRvVcOavIwaCYnLvraLwfbkRvVcw8ie9fBbh7B7hJx(QeoMLKvWowOw)yCHoM9bogUB5Rf7hRdhJIn4WX6WXOOTyGCSIFmzlgihZ(K(XSpWXWDlFTy)yD4yFN0)a)yFBYuOJzFk(XwRXa)yaf3i5XOydoCSoCmkAlgihd)jjRa)y2N0og)tpiFhBchBGdVJjUSphlXwngoMLsWnUqhRchJEZ51uc6lwITQDUg3T81IDUa0(JtPuLyRAxjlUjKNranlLGBkstxOkqZsj4MMm4GQdk6TyGObpNs4rzITAmOahIkGtJkkXDlFTyxtgCq1bf9wmq0HbPura8NKSckRIGfJ7w(AXUoq6FGRAYutGOSC(flXw1oxJ7w(AXoxaA)P3w1UqvGgDcmwTIFAQ0fwy1yOCE84wfbkRvVcwSOe9flXw1oxJ7w(AXoxaA)h4GQmiIFXsSvTZ14ULVwSZfG2)PS7Nkmqe(ILyRANRXDlFTyNlaT)tGWbYOLVEXsSvTZ14ULVwSZfG2FzT(X4kkYdV1iWTlwITQDUg3T81IDUa0(hkcmLD)Uyj2Q25AC3Yxl25cq7F6yGBKuQWPuEXUyl4yICohCmWpgDs1KYe(yHMCmsBPvTR5w6VK8ow6VJrAlTQDT3Qcdkz6yqFXsSvTZ1aNdog40cnEGdpv(diLbQjKrcvbAZHqqtgCq1bf9wmq0VwShpEITAmOahIkGtbrDXsSvTZ1aNdog4cq7Fee1eHvDqjhW1t9iqgXfQc0sSvJbf4qub8fpsk)YCie0fUWsGR5wIhDX0OkECrYsj4MEvM4kLko9AuqdEoLW7RuI7w(AXUoq6FGRAYutGOSCofOs0xSeBv7CnW5GJbUa0(pLD)uDqzFaf4qKWcvbAFXsj4MEvM4kLko9AuqdEoLWJY5qiOlCHLaxZTepkTrs5xMdHGEsYYvbca)anbsSfpoDcmwTIFAQ0WS9zlTV(14X)YxsSvJbf4qubCkiQ4XfjlLGB6vzIRuQ40Rrbn45ucVVs5xOtGXQv8ttLoq6FGRAYmE8vsp4pv2Goq6FGRAYutGOSCofg5x)6flXw1oxdCo4yGlaT)0hivq4YxvtzYnHQaT5qiOjdoO6GIElgi6xl2JhpXwnguGdrfWPGOUyj2Q25AGZbhdCbO9Nu0Plbv5ko9edcvbAZHqqtgCq1bf9wmq0VwShpEITAmOahIkGtbrDXsSvTZ1aNdog4cq7pUDm4gjn4PcYmceswoOWpAFJqvG2Cie0KbhuDqrVfde9Rf7xSeBv7CnW5GJbUa0(BFa1Gp7b)PcnbdcvbAZHqqta8OsGZvHMGb9a9lwITQDUg4CWXaxaA)f3e5BmuUIa82thdcvbAZHqqtgCq1bf9wmq0VwShpEITAmOahIkGtbrDXUyl4yICohCmWpgDs1KYe(yHMCmsBPvTRdK(h4QMmVyj2Q25AGZbhdCvtM0cnEGdpv(diLbQjKrcvbAZHqqtgCq1bf9wmq0VwSt5dMdHGMEIhfEQcd6xl2JhpXwnguGdrfWPGOUyj2Q25AGZbhdCvtMcq7Fee1eHvDqjhW1t9iqgXfQc0sSvJbf4qub8fpskFWCie00t8OWtvyq)AXoL4ULVwSRdK(h4QMm1eiklNtHrsPiLyRAxhi9pWvnzQlxfK16hJYvsp4pv2Goq6FGRAYutGOSConrFXsSvTZ1aNdog4QMmfG2)PS7NQdk7dOahIewOkqJobgRwXpnv6aP)bUQjZ4Xxj9G)uzd6aP)bUQjtnbIYY5uyKxSeBv7CnW5GJbUQjtbO9N(aPccx(QAktUjufOnhcbnzWbvhu0BXar)AXoLpyoecA6jEu4PkmOFTypE8eB1yqboevaNcI6ILyRANRbohCmWvnzkaT)KIoDjOkxXPNyqOkqBoecAYGdQoOO3IbI(1IDkFWCie00t8OWtvyq)AXE84j2QXGcCiQaofe1flXw1oxdCo4yGRAYuaA)XTJb3iPbpvqMrGqYYbf(r7BeQc0MdHGMm4GQdk6TyGOFTyNYhmhcbn9epk8ufg0VwSFXsSvTZ1aNdog4QMmfG2F7dOg8zp4pvOjyqOkqBoecAcGhvcCUk0emOhOFXsSvTZ1aNdog4QMmfG2FXnr(gdLRiaV90XGqvG2Cie0KbhuDqrVfde9Rf7u(G5qiOPN4rHNQWG(1I94XtSvJbf4qubCkiQl2fBbhlXw1oxh1JHiWnAtz5JkufOf1JHiWn9R4w6yGcuj6l2cowITQDUoQhdrGBcq7p)tffbeHQaTOEmebUPFf3shduGkrFXsSvTZ1r9yicCtaA)lmOcYg4cvbAZHqqxyqfKnW1VwSFXUyl4y7YxLWXwMKvWogfLunPmHpwOjhJ0wAv7AUL(ljVJ10TQD9flXw1oxZlFvckUL(ljpbO9pihieHfQc0SucUPHz7ZwAAWZPeEusNaJvR4NMknmBF2sJYViswkb30RYexPuXPxJcAWZPeEXJphcbDHlSe4AUL4rxSiep(Cie0tswUkqa4hOjqITVEXsSvTZ18YxLGIBP)sYtaA)dYbcryHQanlLGB6vzIRuQ40Rrbn45ucpkPtGXQv8ttLEvM4kLko9AuGY5qiONKSCvGaWpqtGeBxSeBv7CnV8vjO4w6VK8eG2)GCGqewOkqJobgRwXpnv6aP52SLgLZHqqpjz5QabGFGMaj2O8lIKLsWn9QmXvkvC61OGg8CkHx84ZHqqx4clbUMBjE0flcF9ILyRANR5LVkbf3s)LKNa0(JtPuLyRAxjlUjKNranGZbhd8lwITQDUMx(QeuCl9xsEcq7FG0)ax1K5flXw1oxZlFvckUL(ljpbO9FkRF)sYtOkqlXwnguGdrfWPWiIhpXwnguGdrfWPavuItUPSkcOjAkNdHGou(kq4QoOcKMBAcKyBXJ4ILyRANR5LVkbf3s)LKNa0(xyqjthdcvbAZHqqhkFfiCvhubsZnnbsSDXsSvTZ18YxLGIBP)sYtaA)XDeykU1KOlwITQDUMx(QeuCl9xsEcq7pmBF2s7ILyRANR5LVkbf3s)LKNa0(tsHvDqfin3eQc0ePeBv76aP)bUQjtD5QGSw)yuUs6b)PYg0bs)dCvtMAceLLZPj6lwITQDUMx(QeuCl9xsEcq7)uw)(LKNqvGgo5MYQiGMOJhpXwnguGdrfWPavxSeBv7CnV8vjO4w6VK8eG2)vzIRuQ40RrbHQaT5qiONKSCvGaWpqtGeBXJtNaJvR4NMknmBF2slE8eB1yqboevaNcurPLsWnnNUSmR8vvHbn45ucVl2fBbhBx(Qeo2YKSc2XOOKQjLj8Xcn5y2h4yK2sRAx7TQWGsMogowt3Q21xSeBv7CnV8vjO8wjthdcq7FqoqiclufOzPeCtdZ2NT00GNtj8OKobgRwXpnvAy2(SLgLZHqqpjz5QabGFGMaj2Uyj2Q25AE5Rsq5TsMogeG2)GCGqewOkqJobgRwXpnv6vzIRuQ40RrbkNdHGEsYYvbca)anbsSDXsSvTZ18YxLGYBLmDmiaT)4ukvj2Q2vYIBc5zeqd4CWXa)ILyRANR5LVkbL3kz6yqaA)dK(h4QMmVyj2Q25AE5Rsq5TsMogeG2)PS(9ljpHQaTeB1yqboevaNcJiE8eB1yqboevaNcurPizPeCtZPllZkFvvyqdEoLW7ILyRANR5LVkbL3kz6yqaA)XDeykU1KOlwITQDUMx(QeuERKPJbbO9hMTpBPjufOnhcbDHlSe4AUL4rPnskfP5qiONKSCvGaWpqtGeBxSeBv7CnV8vjO8wjthdcq7)QmXvkvC61OGqvG2Cie0tswUkqa4hOjqIT4XPtGXQv8ttLgMTpBPfpULsWnD540nGWvbzlwdEoLWJsCYnLvrGagjhdsLvrafkhNUbeUkiBXkRIaL16rQhOtjo5MYQiqaJKJbPYQiyXLJt3acxfKTyLvrGYATiOFTy)IDXwWX2LVkHJTmjRGDmkkPAszcFSqtoM9bogPT0Q21bs)dCvtMhRPBv76lwITQDUMx(QeunzkaT)4ukvj2Q2vYIBc5zeqd4CWXax1K5flXw1oxZlFvcQMmfG2)aP)bUQjZlwITQDUMx(QeunzkaT)b5aHiSqvGgDcmwTIFAQ0WS9zlnkNdHGEsYYvbca)anbsSDXsSvTZ18YxLGQjtbO9FkRF)sYtOkqlXwnguGdrfWPWiIhpXwnguGdrfWPavuItUPSkcOj6lwITQDUMx(QeunzkaT)fguY0XGqvG2Cie0HYxbcx1bvG0CttGeBuI7w(AXUoq6FGRAYutGOSCofgz84ZHqqhkFfiCvhubsZnnbsSrBexSeBv7CnV8vjOAYuaA)NY63VK8eQc0Wj3uwfb0e9flXw1oxZlFvcQMmfG2)GCGqewOkqJobgRwXpnvAy2(SL2flXw1oxZlFvcQMmfG2)GCGqewOkqBoec6jjlxfia8d0eiXgLFHobgRwXpnv6aP52SLw84pyoecA6jEu4PkmOjquwoNcafhWdgOSkceiXw1UUWGsMog0gjhdsLvrWxVyj2Q25AE5Rsq1KPa0(J7iWuCRjrxSeBv7CnV8vjOAYuaA)Hz7ZwAxSeBv7CnV8vjOAYuaA)jPWQoOcKMBcvbApyoecA6jEu4PkmOhOlu5gqid0nvfOnhcbDO8vGWvDqfin30eiXgTriu5gqid0nvffbVknGgvxSeBv7CnV8vjOAYuaA)NY63VK8UyxSfCmrMFmEhbhJx2qAv7CHoMW9WXWPFm(N0mGCmrggoMG948yWyWpwgmGCSusG8j8XWj3kF9yFxoqicFS0FhtKHHJTiLog0h7BBFaI4IdhZ(u8JLyRA)yf)ydC4DmXFa)y2h4yr5kCSpj)yFV)(XYGbKJHtUv(6X(UCGqewOJXb4y5Shd6lwITQDUMx(QeOvyq594uOkqd3T81IDDHbL3JtnbYNWu(G5qiOfxUbeUc)PKs9a9lwITQDUMx(QeeG2FCkLQeBv7kzXnH8mcOXlFvckUL(ljpHQansBPvTR5w6VK8Uyj2Q25AE5RsqaA)XPuQsSvTRKf3eYZiGgV8vjO8wjthdcvbAK2sRAx7TQWGsMogUyj2Q25AE5RsqaA)XPuQsSvTRKf3eYZiGgV8vjOAYuOkqJ0wAv76aP)bUQjZlwITQDUMx(QeeG2)cdkVhNxSeBv7CnV8vjiaT)dCqvgejKNranREa3AsKc3pGIlufOnhcbDHfwngkNRFTyNY5qiOjdoO6GIElgi6xl2Vyj2Q25AE5RsqaA)h4GQmisiieaSP8mcOHfglBJ0EHvtzYnHQaT5qiOlSWQXq5C9Rf7uohcbnzWbvhu0BXar)AX(flXw1oxZlFvccq7FG0CB2s7ILyRANR5LVkbbO9hNsPkXw1UswCtipJaAr9yicCtOkqlQhx(6flXw1oxZlFvccq7FHbLmDmCXUyl4yleL95ylYYexP8yB61OGqhJIn4WX6WXOOTyGCm(NEq(o2eo2ahEhJuRFSJnHqtGJzFGJTiltCLYJTPxJchd3rZ(yFP0G(yIl7ZXg5Xez4clb(Xs)DS8yutYYp23ja8d(Q(yleFa)yI8z7ZwAhR4hRdHJH7w(AXUqhJIn4WX6WXOOTyGCmC6hlL8(yt4ydC4DmkYdC7yIl7ZXg5Xez4clbU(ILyRANRTucUPinDAKbhuDqrVfdeHQanlLGB6vzIRuQ40Rrbn45ucpkNdHGUWfwcCn3s8O0gjLFzoec6jjlxfia8d0eiXw84wkb30WS9zlnn45ucpkXDlFTyxdZ2NT00eiklNVyCYnLvrWxVyl4yleL9PhSJTiltCLYJTPxJccDmk2GdhRdhJI2IbYX4F6b57yt4ydC4DSjeAcCS0f(yZADfihd3T81I9J9fr(S9zlnHo2cVJa7yBRjrcDmkwk8X6WX(oP52xpwtoM4pGFmk2GdhRdhJI2IbYXk(XYzpyhZ6JrGe)5yJ4y4pjzf46lwITQDU2sj4MI00fG2FYGdQoOO3IbIqvGMizPeCtVktCLsfNEnkObpNs4r5xSucUPHz7ZwAAWZPeEuI7w(AXUgMTpBPPjquwoFX4KBkRIG4XTucUPXDeykU1Kin45ucpkXDlFTyxJ7iWuCRjrAceLLZxmo5MYQiiEClLGBAskSQdQaP5Mg8CkHhL4ULVwSRjPWQoOcKMBAceLLZxmo5MYQiiEC8NKScCvGKyRApLuGkTi(Ridzie]] )


end
