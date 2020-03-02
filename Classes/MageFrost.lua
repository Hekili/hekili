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

    
    spec:RegisterPack( "Frost Mage", 20200301, [[dWuD5aqisc9isQAterFIOugLIqNsrKvPkLkVcj1SikULIOyxu1VuLmmssDmKOLruLNrsY0uLQUgjrBtru9nIs04uLs5CkIsRJKaZtvkUhrAFev1bjjOfseEirjmrsQuUirj1gve8rvPsnsvPKQtQkvSsQOzQkLQUPQus2js4NKujdLOKSusQ4PQ0uvuDvvPs(QQuI9c5VKAWioSWIvXJHAYQQld2ScFwvmAQWPLA1KuP61KuMnQUnj2TKFlA4iLJRkLuwokpNW0PCDQ02vK(os14jkvNhjz9evMVIY(vAeLO5O7pmarH8uT8uTQvLQP0tPkvPSuvYs01OIgGU0cSAXdGUvOaO7eyPWwYBv8aOlTGkEgF0C0vKUmmGUomJMqf861tBoCpECQ8s0kU8W6SWSyyVeTc(f6ECBU9of6GU)WaefYt1Yt1QwvQMspLQuLYsvjp0nCnhjdDVTISaDD0)puOd6(bbgDv)sMalf2sERIhyDQ(L4WmAcvWRxpT5W94XPYlrR4YdRZcZIH9s0k4xRt1VKjahMBWOAjYBYLzjYt1Yt1RZ1P6xISWrupGqfSov)sMml5DjGLiBwRaAl1)gKTL0LWG4VKCSezZc2dyERvaTL6FdY2sgjBj8qylra4S(lrwOUTexr8aE0L3ctGMJUIUE4aAoIckrZrxOIdh(ijqxmRnG1b6IZK)t6LVXGUYPHNbXNQLi5s(WXDm807YaMqJD0CU3Lg6gyRZcDBmORCAGmefYdnhDHkoC4JKaDXS2awhORfCOmpCY6KCZdvC4WFjsUeAmyQ(b)9u6HtwNKBlrYLCChd)HfDPhmaKd8miWg6gyRZcDhCxgJkKHOqvO5OluXHdFKeOlM1gW6aDPXGP6h83tP)Hh4o4AbTwnyjsUKJ7y4pSOl9GbGCGNbb2q3aBDwO7G7YyuHmefVhnhDHkoC4JKaDdS1zHU4GZ1b26S08wyOlVfMUcfaDbHakmiqgIcvIMJUb26Sq3blLdkDYoOluXHdFKeidrXKJMJUqfho8rsGUywBaRd0nWwpf0qbkniwI8xI8wYSzljWwpf0qbkniwI8xcLlrYLOIlXcouMxqJ3M11JUXGhQ4WHp6gyRZcDp8wo5c2hzikKLO5OBGTol0fNkGPfwYuqxOIdh(ijqgII3gAo6cvC4Whjb6IzTbSoq3J7y4BCJ5GWlSaR2sKUevUejxIkUKJ7y4pSOl9GbGCGNbb2q3aBDwOlCY6KCdzikMSO5OluXHdFKeOlM1gW6aDpUJH)WIU0dgaYbEgeyBjsUKjUKJ7y4hD9amHoh6blfMNbb2wYSzlHgdMQFWFpL(b3LXOAjtAjsUKjUKJ7y4BCJ5GWReYUwybwTLmzwYXDm8nUXCq4fwGvBjtAjVDljWwNLFWsHDsU5bzhWUgOTwbwc1ljWwNL)Hh4o4AbTwnWJdHPTwbwc1ljWwNL)Hh4o4AbTwnWBSykW1wRal5nlPlCugWe6bpPRTwb0w6vPpkQwIKl54ogEfqjzuPZHM7I7V(ZGqr4)j9cDdS1zHUng08OWaYquqPQrZrxOIdh(ijqxmRnG1b6EChd)HfDPhmaKd8miW2sMnBj0yWu9d(7P0dNSoj3wYSzlXcouMVlCugWe6bpP7HkoC4VejxcoeM2AfyjuVeJftbU2AfyjYFjDHJYaMqp4jDT1kG2sVk9U0wIKlbhctBTcSeQxIXIPaxBTcSK3SKUWrzatOh8KU2AfqBP)9(FsVq3aBDwO7dpWDW1cATAaYquqjLO5OBGTol0TXGUYPb6cvC4WhjbYquqP8qZrxOIdh(ijq3aBDwOR1FqyjtrJZpi7OlM1gW6aDpUJHVXuPNcDj8)KETejxYXDm8m3c05qtlPdm)pPxOBfka6A9hewYu048dYoYquqPQqZrxOIdh(ijq3aBDwOlMkmpnwwnwF4HWqxmRnG1b6EChdFJPspf6s4)j9AjsUKJ7y4zUfOZHMwshy(FsVqxymaSPRqbqxmvyEASSAS(WdHHmefu(E0C0nWwNf6oyPWoj3qxOIdh(ijqgIckvjAo6cvC4Whjb6gyRZcDXbNRdS1zP5TWqxElmDfka6QKtbfOmKHOGYjhnhDdS1zHUng08OWa6cvC4WhjbYqg6ccbuyqGMJOGs0C0fQ4WHpsc0fZAdyDGUh3XWZClqNdnTKoW8)KETKzZwsGTEkOHcuAqSe5VevHUb26Sq3rIDfWxhYbS2a9bcfKHOqEO5OluXHdFKeOlM1gW6aDdS1tbnuGsdIL8MLOYLi5sM4soUJHVXnMdcVWcSAl5nsxcLlz2SLOIlXcouM)Hh4o4AbTwnWdvC4WFjtAjsUeCM8FsV8dwkhu6KD8mqj6sSe5Vekvn6gyRZcDvaLKrLohAUlU)6pdcfbYquOk0C0fQ4WHpsc0fZAdyDGUtCjwWHY8p8a3bxlO1QbEOIdh(lrYLCChdFJBmheEHfy1wI0LOYLi5sM4soUJH)WIU0dgaYbEgeyBjZMTeAmyQ(b)9u6HtwNKBlzslzslz2SLmXLmXLeyRNcAOaLgelr(lrvlz2SLOIlXcouM)Hh4o4AbTwnWdvC4WFjtAjsUKjUeAmyQ(b)9u6hSuoO0j7SKzZwYdlDRVosWpyPCqPt2XZaLOlXsK)su5sM0sMe6gyRZcDp8m)6COnhGgkqHkKHO49O5OluXHdFKeOlM1gW6aDpUJHN5wGohAAjDG5)j9AjZMTKaB9uqdfO0GyjYFjQcDdS1zHU0Cz9GQUE0hEimKHOqLO5OluXHdFKeOlM1gW6aDpUJHN5wGohAAjDG5)j9AjZMTKaB9uqdfO0GyjYFjQcDdS1zHUSMgnoO7slOfyazikMC0C0fQ4WHpsc0nWwNf6IZcdLXcd(6bpua0fZAdyDGUh3XWZClqNdnTKoW8)KEHU8Uan(JUtoYquilrZrxOIdh(ijqxmRnG1b6EChdpZTaDo00s6aZ)t6f6gyRZcDzqqRRh9GhkGazikEBO5OluXHdFKeOlM1gW6aDpUJHNby14GqOhjddExAOBGTol01CaA36KU1xpsggqgIIjlAo6cvC4Whjb6IzTbSoq3J7y4zUfOZHMwshy(FsVwYSzljWwpf0qbkniwI8xIQq3aBDwOl9KX)tHU0mqKvuyazidD)WiC5gAoIckrZr3aBDwOloDldycAaNJUqfho8rsGmefYdnhDHkoC4JKaDdS1zHU4GZ1b26S08wyOlVfMUcfaDXzY)j9sGmefQcnhDHkoC4JKaDXS2awhOBGTEkOHcuAqSe5VevTejxIfCOm)GbGCD9OzrxEOIdh(lz2SLeyRNcAOaLgelr(l59OBGTol0fhCUoWwNLM3cdD5TW0vOaOBKaYqu8E0C0fQ4WHpsc0nWwNf6IdoxhyRZsZBHHU8wy6kua0v01dhqgYqxAmaNkNWqZruqjAo6gyRZcDdgokq3LbCoGn0fQ4WHpscKHOqEO5OBGTol0LEyatdCqbkl4OluXHdFKeidrHQqZrxOIdh(ijq3kua0nKt4iyHqpYY05qtlPdm0nWwNf6gYjCeSqOhzz6COPL0bgYqu8E0C0nWwNf6Q0mwY0Ts8aOluXHdFKeidrHkrZr3aBDwOlT06SqxOIdh(ijqgIIjhnhDdS1zHUdwkStYn0fQ4WHpscKHm0nsanhrbLO5OBGTol0DWs5GsNSd6cvC4WhjbYquip0C0nWwNf6E4TCYfSp6cvC4WhjbYquOk0C0fQ4WHpsc0nWwNf6IdoxhyRZsZBHHU8wy6kua0fecOWGazikEpAo6gyRZcDXPcyAHLmf0fQ4WHpscKHOqLO5OBGTol0TXGUYPb6cvC4WhjbYqum5O5OluXHdFKeOlM1gW6aDPXGP6h83tPhozDsUTKzZwYXDm8hw0LEWaqoWZGaBlrYLmXLqJbt1p4VNs)GLc7KCBjsUKjUKJ7y4BCJ5GWlSaR2sEZsE)sMnBjQ4sSGdL5F4bUdUwqRvd8qfho8xYKwYSzlHgdMQFWFpL(hEG7GRf0A1GLmj0nWwNf6o4UmgvidrHSenhDHkoC4JKaDXS2awhO7XDm8JUEaMqNd9GLcZZGaBOBGTol0TXGMhfgqgII3gAo6gyRZcDzbv6COhSuyOluXHdFKeidrXKfnhDdS1zHUWjRtYn0fQ4WHpscKHOGsvJMJUb26Sq3hEG7GRf0A1a0fQ4WHpscKHOGskrZr3aBDwOlolqNdno5F0fQ4WHpscKHOGs5HMJUqfho8rsGUb26SqxR)GWsMIgNFq2rxmRnG1b6EChdFJPspf6s4)j9AjsUKJ7y4zUfOZHMwshy(FsVq3kua016piSKPOX5hKDKHOGsvHMJUqfho8rsGUb26SqxmvyEASSAS(WdHHUywBaRd094og(gtLEk0LW)t61sKCjh3XWZClqNdnTKoW8)KEHUWyaytxHcGUyQW80yz1y9HhcdzikO89O5OBGTol0DWsHDsUHUqfho8rsGmefuQs0C0fQ4WHpsc0nWwNf6IdoxhyRZsZBHHU8wy6kua0vjNckqzidrbLtoAo6gyRZcDBmO5rHb0fQ4WHpscKHm0fNj)N0lbAoIckrZr3aBDwO7JBW(Du6COd5awAoqxOIdh(ijqgIc5HMJUb26Sq3gtLEk0LaDHkoC4JKazikufAo6gyRZcDvAglz6wjEa0fQ4WHpscKHO49O5OluXHdFKeOlM1gW6aDPXGP6h83tPFWs5GsNSZsMnBjwRaAl1)gwI8xcLQEjuVeCimT1kWsKCjwRaAl1)gwYBwI8un6gyRZcDzUfOZHMwshyidrHkrZrxOIdh(ijqxmRnG1b6AbhkZZClqNdnTKoW8qfho8xIKljWwpf0qbkniwI0Lq5sKCj4m5)KE5zUfOZHMwshy(HlNRza2rWEaT1kWsEZsWzY)j9YpyPCqPt2XZaLOlb6gyRZcDXbNRdS1zP5TWqxElmDfka6AbhktZsAidrXKJMJUqfho8rsGUywBaRd0LgdMQFWFpL(gtLEk0LyjZMTeRvaTL6Fdl5nlrvQgDdS1zHU0sRZczikKLO5OluXHdFKeOBGTol09eCy0mqFyrHDGUywBaRd0vfxIfCOm)dpWDW1cATAGhQ4WH)sMnBjh3XWFyrx6bda5apdcSTejxcngmv)G)Ek9p8a3bxlO1QbOBfka6EcomAgOpSOWoqgII3gAo6gyRZcDDfGUnqrGUqfho8rsGmeftw0C0nWwNf6E4z(1dxgvOluXHdFKeidrbLQgnhDdS1zHUhGjaMAD9GUqfho8rsGmefusjAo6gyRZcD59JdtOv3D)pkqzOluXHdFKeidrbLYdnhDdS1zHUJMbhEMF0fQ4WHpscKHOGsvHMJUb26Sq3OWGWybxJdohDHkoC4JKazikO89O5OBGTol09ep6COnwJvtGUqfho8rsGmKHUwWHY0SKgAoIckrZrxOIdh(ijqxmRnG1b6AbhkZ)WdChCTGwRg4HkoC4VejxYXDm8nUXCq4fwGvBjsxIkxIKlzIl54og(dl6spyaih4zqGTLmB2sSGdL5HtwNKBEOIdh(lrYLGZK)t6LhozDsU5zGs0LyjVzj4qyARvGLmj0nWwNf6YClqNdnTKoWqgIc5HMJUqfho8rsGUywBaRd0vfxIfCOm)dpWDW1cATAGhQ4WH)sKCjtCjwWHY8WjRtYnpuXHd)Li5sWzY)j9YdNSoj38mqj6sSK3SeCimT1kWsMnBjwWHY84ubmTWsMIhQ4WH)sKCj4m5)KE5XPcyAHLmfpduIUel5nlbhctBTcSKzZwIfCOmplOsNd9GLcZdvC4WFjsUeCM8FsV8SGkDo0dwkmpduIUel5nlbhctBTcSKzZwc2rWEaHEWcS1zf8Li)LqPFYUKjHUb26SqxMBb6COPL0bgYqg6QKtbfOm0CefuIMJUqfho8rsGUywBaRd0vjNckqz(FlSOWWsK)sOu1OBGTol09W7snDuuHmefYdnhDHkoC4JKaDXS2awhO7XDm8ng0dEcc)pPxOBGTol0TXGEWtqGmKHm0DkWeDwikKNQLNQvnLY79Ol9GvD9iq33IkuDO4DO4DRcwYsM7awsRqlz2sgjBjYMsofuGYKTLWG3AUnd(lrKkWscxlvcd(lb7iQhq4xNV9DblHsvWsExLWLgTKzWFjb26SwISD4DPMokQKn)6CD(ok0sMb)L82wsGToRLWBHj8Rt0vqdWikM83JU0y5O5a6Q(LmbwkSL8wfpW6u9lXHz0eQGxVEAZH7XJtLxIwXLhwNfMfd7LOvWVwNQFjtaom3Gr1sK3KlZsKNQLNQxNRt1VezHJOEaHkyDQ(LmzwY7salr2Swb0wQ)niBlPlHbXFj5yjYMfShW8wRaAl1)gKTLms2s4HWwIaWz9xISqDBjUI4b8RZ1P6xISw2bSRb)LCGrYGLGtLtyl5apDj8lrfIXantSKkRjJJGPmC5ljWwNLyjzXPYVov)scS1zj80yaovoHjDWdHARt1VKaBDwcpngGtLtyul91iZ)6u9ljWwNLWtJb4u5eg1sFfUpkqzH1zTodS1zj80yaovoHrT0xbdhfO7YaohW26mWwNLWtJb4u5eg1sFjCvuYstpmGPboOaLf81P6xsGTolHNgdWPYjmQL(subnHJ00clmX6mWwNLWtJb4u5eg1sF5kaDBGImvOasd5eocwi0JSmDo00s6aBDgyRZs4PXaCQCcJAPVuAglz6wjEG1zGTolHNgdWPYjmQL(IwADwRZaBDwcpngGtLtyul91GLc7KCBDUov)sK1YoGDn4VeykWOAjwRalXCaljWwYwslwsmnAEC4GFDgyRZsifNULbmbnGZxNb26Seul9fo4CDGTolnVfMmvOasXzY)j9sSov)sM7awIfShWwI5Gbchj)VKwuYMTeq2dS5xIeGrhGAjQAYOYLyb7bmHmlXCal53JbWGcdILCaJoa1smhWsUZxsu)LOctz9scS1zTeElmXscgSewyoa2sekbN7xYB9KomfyYSKjWaqUUEwI6eDTeAmyamXsCfD9SevykRxsGToRLWBHTerMfWwsiwsBl5afmAtSKhgegNQLmyPYsmhWsC0powcnwNS2OAjsWB5Kly)LeyRZYVodS1zjOw6lCW56aBDwAElmzQqbKgjitpKgyRNcAOaLgeYxvsAbhkZpyaixxpAw0LhQ4WH)Szb26PGgkqPbH8F)6mWwNLGAPVWbNRdS1zP5TWKPcfqQORhoSoxNQFjVL2CSKjWaqUUEwI6eDjZsAt2el5aMbSLy5sOX6K1wlhSexrxplzcSuoOwI6IDwcDhqTKtAowYeuxljQ)sKG3YjxW(ljyWsYXyj4m5)KE5xYBPnhPRTKjWaqUUEwI6eDjZsmhWsWznfycyjTyjgZfwsWnhP7JJLyoGL87XayqHHL0ILO0vlWUCyjUL18LmfyuTeh9JJLyb7bSLGt3Ye(1zGTolHpsq6GLYbLozN1zGTolHpsGAPVo8wo5c2FDgyRZs4JeOw6lCW56aBDwAElmzQqbKccbuyqSodS1zj8rcul9fovatlSKPSodS1zj8rcul9vJbDLtJ1P6xYTvOX7rd)LmbUlJr1sWz9BRZsSKblvwI5awYD(scS1zTeElm)sUDHHLyoGLOepWsAXsEGcyH11ZsgbBjCqiwIeSORLmbgaYblb7iypGqMLyoGLaYEGTLGZ63wN1sCamyjTOKnBjbNVeZrylPvOLmlkZVodS1zj8rcul91G7YyujtpKsJbt1p4VNspCY6KCB2SJ7y4pSOl9GbGCGNbb2KCI0yWu9d(7P0pyPWoj3KCIh3XW34gZbHxybwT38(zZurl4qz(hEG7GRf0A1apuXHd)jnBgngmv)G)Ek9p8a3bxlO1QbtADgyRZs4JeOw6RgdAEuyqMEi94og(rxpatOZHEWsH5zqGT1P6xYChWsuIhyj0BoFjpqbSGZPAjhyjpqbSW66zjXs4PTKCSKjKtyjyhb7belHUdOwIRORNLyoGLOctz9scS1zTeElm)sMZOQRNLy5s(apOAjQtq1sYXsMalf2sClR5lXCamyjbdwsLlzc5ewc2rWEaXsI6VKkxsGTEkSKjWs5GAjQl2rSe6Pl)Veoe)Ly5sABjvAl5aD9Sexb8xsylj4C)6mWwNLWhjqT0xSGkDo0dwkS1zGTolHpsGAPVGtwNKBRZaBDwcFKa1sF9WdChCTGwRgSov)sExIUEwISilyj5yjYIK)xslwIskmovlrDtwDxsbUgl4lHEBowI5awIkmL1lXc2dylXCWaHJK)f(L8o2sYIt1soaovaXs(agkBjprxlHEBowclDFCWPAjYYLKSLOKmyjwWEat4xNb26Se(ibQL(cNfOZHgN8)6mWwNLWhjqT0xUcq3gOitfkGuR)GWsMIgNFq2LPhspUJHVXuPNcDj8)KEj5XDm8m3c05qtlPdm)pPxRZaBDwcFKa1sF5kaDBGImWyaytxHciftfMNglRgRp8qyY0dPh3XW3yQ0tHUe(FsVK84ogEMBb6COPL0bM)N0R1zGTolHpsGAPVgSuyNKBRZaBDwcFKa1sFHdoxhyRZsZBHjtfkGuLCkOaLTodS1zj8rcul9vJbnpkmSoxNb26SeECM8FsVesFCd2VJsNdDihWsZX6mWwNLWJZK)t6LGAPVAmv6PqxI1zGTolHhNj)N0lb1sFP0mwY0Ts8aRt1Ve1XTGLKJLiRs6aBjTyjbNEqLyjUc4Ve6T5yjtGLYb1suxSJFjQWIQLWHHLtb2sWoc2diwsylXCalbQ)sYXsmhWsg9JdBjchPl)VKdSexb8Lzj9hcoNQL0JLyoGLCsHyj)eeLSzl53Ws6AjMdyjk9)ZHLKJLyoGLOoUfSKJ7y4xNb26SeECM8FsVeul9fZTaDo00s6atMEiLgdMQFWFpL(blLdkDYoZMzTcOTu)Bq(uQAQXHW0wRasATcOTu)B4nYt1Rt1Ve1vTerxpCyjwWEaBjJ(XHjKzjMdyj4m5)KETKCSe1XTGLKJLiRs6aBjTyj8KoWwI5iQLyoGLGZK)t61sYXsMalLdQLOUyhzwI5Ofl5PNcILaYUXILOoUfSKCSezvshylb7iypGyjMJWwIWr6Y)l5alXva)LqVnhljWwpfwIfCOmHmlPhlHwke9Hd(1zGTolHhNj)N0lb1sFHdoxhyRZsZBHjtfkGul4qzAwstMEi1couMN5wGohAAjDG5HkoC4lzGTEkOHcuAqiLsjXzY)j9YZClqNdnTKoW8dxoxZaSJG9aARvG3GZK)t6LFWs5GsNSJNbkrxI1zGTolHhNj)N0lb1sFrlTolz6HuAmyQ(b)9u6Bmv6PqxIzZSwb0wQ)n8gvP61zGTolHhNj)N0lb1sF5kaDBGImvOaspbhgnd0hwuyhY0dPQOfCOm)dpWDW1cATAGhQ4WH)Szh3XWFyrx6bda5apdcSjjngmv)G)Ek9p8a3bxlO1QbRZaBDwcpot(pPxcQL(Yva62afX6mWwNLWJZK)t6LGAPVo8m)6HlJQ1zGTolHhNj)N0lb1sFDaMayQ11Z6mWwNLWJZK)t6LGAPV49JdtOv3D)pkqzRZaBDwcpot(pPxcQL(A0m4WZ8VodS1zj84m5)KEjOw6ROWGWybxJdoFDgyRZs4XzY)j9sqT0xN4rNdTXASAI156mWwNLWdcbuyqiDKyxb81HCaRnqFGqrMEi94ogEMBb6COPL0bM)N0RzZcS1tbnuGsdc5RQ1zGTolHhecOWGGAPVuaLKrLohAUlU)6pdcfHm9qAGTEkOHcuAq8gvk5epUJHVXnMdcVWcSAVrkLZMPIwWHY8p8a3bxlO1QbEOIdh(tssCM8FsV8dwkhu6KD8mqj6siFkv96mWwNLWdcbuyqqT0xhEMFDo0MdqdfOqLm9q6eTGdL5F4bUdUwqRvd8qfho8L84og(g3yoi8clWQjvLsoXJ7y4pSOl9GbGCGNbb2MnJgdMQFWFpLE4K1j52KM0SztCIb26PGgkqPbH8v1SzQOfCOm)dpWDW1cATAGhQ4WH)KKCI0yWu9d(7P0pyPCqPt2z2Shw6wFDKGFWs5GsNSJNbkrxc5RYjnP1zGTolHhecOWGGAPVO5Y6bvD9Op8qyY0dPh3XWZClqNdnTKoW8)KEnBwGTEkOHcuAqiFvTodS1zj8Gqafgeul9fRPrJd6U0cAbgKPhspUJHN5wGohAAjDG5)j9A2SaB9uqdfO0Gq(QADgyRZs4bHakmiOw6lCwyOmwyWxp4HcidVlqJ)sNCz6H0J7y4zUfOZHMwshy(FsVwNb26SeEqiGcdcQL(IbbTUE0dEOacz6H0J7y4zUfOZHMwshy(FsVwNb26SeEqiGcdcQL(YCaA36KU1xpsggKPhspUJHNby14GqOhjddExARZaBDwcpieqHbb1sFrpz8)uOlndezffgKPhspUJHN5wGohAAjDG5)j9A2SaB9uqdfO0Gq(QADUodS1zj8k5uqbkt6H3LA6OOsMEivjNckqz(FlSOWG8Pu1RZaBDwcVsofuGYOw6Rgd6bpbHm9q6XDm8ng0dEcc)pPxRZ1P6xY7ulrKkWseT5gwNLqMLqv6UeCulr4imdyl5DWWsOiNglbMc1sIHbSLeCgeFQwcoewxplzcCxgJQLe1FjVdgwYBFuyWVe1L5ay0BbSeZrlwsGToRL0IL4kG)sO7aQLyoGLOepWsCeILmHCcljggWwcoewxplzcCxgJkzwIaGLeNCk4xNb26SeErxpCqAJbDLtdz6HuCM8FsV8ng0von8mi(uj5hoUJHNExgWeASJMZ9U0wNb26SeErxpCGAPVgCxgJkz6Hul4qzE4K1j5MhQ4WHVK0yWu9d(7P0dNSoj3K84og(dl6spyaih4zqGT1zGTolHx01dhOw6Rb3LXOsMEiLgdMQFWFpL(hEG7GRf0A1ajpUJH)WIU0dgaYbEgeyBDgyRZs4fD9WbQL(chCUoWwNLM3ctMkuaPGqafgeRZaBDwcVORhoqT0xdwkhu6KDwNb26SeErxpCGAPVo8wo5c2xMEinWwpf0qbkniKV8MnlWwpf0qbkniKpLsQIwWHY8cA82SUE0ng8qfho8xNb26SeErxpCGAPVWPcyAHLmL1zGTolHx01dhOw6l4K1j5Mm9q6XDm8nUXCq4fwGvtQkLufpUJH)WIU0dgaYbEgeyBDgyRZs4fD9WbQL(QXGMhfgKPhspUJH)WIU0dgaYbEgeytYjEChd)ORhGj05qpyPW8miW2Sz0yWu9d(7P0p4UmgvtsYjEChdFJBmheELq21clWQnzoUJHVXnMdcVWcSAt6TlWwNLFWsHDsU5bzhWUgOTwbOoWwNL)Hh4o4AbTwnWJdHPTwbOoWwNL)Hh4o4AbTwnWBSykW1wRaVPlCugWe6bpPRTwb0w6vPpkQK84ogEfqjzuPZHM7I7V(ZGqr4)j9ADgyRZs4fD9WbQL(6Hh4o4AbTwnqMEi94og(dl6spyaih4zqGTzZOXGP6h83tPhozDsUnBMfCOmFx4OmGj0dEs3dvC4WxsCimT1ka1glMcCT1kG87chLbmHEWt6ARvaTLEv6DPjjoeM2AfGAJftbU2Af4nDHJYaMqp4jDT1kG2s)79)KETodS1zj8IUE4a1sF1yqx50yDgyRZs4fD9WbQL(Yva62afzQqbKA9hewYu048dYUm9q6XDm8nMk9uOlH)N0ljpUJHN5wGohAAjDG5)j9ADgyRZs4fD9WbQL(Yva62afzGXaWMUcfqkMkmpnwwnwF4HWKPhspUJHVXuPNcDj8)KEj5XDm8m3c05qtlPdm)pPxRZaBDwcVORhoqT0xdwkStYT1zGTolHx01dhOw6lCW56aBDwAElmzQqbKQKtbfOS1zGTolHx01dhOw6RgdAEuyyDUov)sElT5yjVBEG7GVKlTwnqMLOoUfSKCSezvshylr4iD5)LCGL4kG)sy9JdBjhyKmyjMdyjVBEG7GVKlTwnyj4u5KlzITh8lHEBowIkxY7GBmheljQ)sILibl6AjtGbGCWK8l5T4aQLiRpzDsUTKwSKCmwcot(pPxYSe1XTGLKJLiRs6aBj4OwsWf5soWsCfWFjQ7UcBj0BZXsu5sEhCJ5GWVodS1zj8wWHY0SKMuMBb6COPL0bMm9qQfCOm)dpWDW1cATAGhQ4WHVKh3XW34gZbHxybwnPQuYjEChd)HfDPhmaKd8miW2SzwWHY8WjRtYnpuXHdFjXzY)j9YdNSoj38mqj6s8gCimT1kWKwNQFjVL2CKU2sE38a3bFjxATAGmlrDClyj5yjYQKoWwIWr6Y)l5alXva)LCGrYGLefvl50ppaBj4m5)KETKjkRpzDsUjZsKfPcyl5AjtrMLOobvljhlzcSuytAjjBj0Da1suh3cwsowISkPdSL0ILeN01wILlHbb2XsK3sWoc2di8RZaBDwcVfCOmnlPrT0xm3c05qtlPdmz6Huv0couM)Hh4o4AbTwnWdvC4WxYjAbhkZdNSoj38qfho8LeNj)N0lpCY6KCZZaLOlXBWHW0wRaZMzbhkZJtfW0clzkEOIdh(sIZK)t6LhNkGPfwYu8mqj6s8gCimT1kWSzwWHY8SGkDo0dwkmpuXHdFjXzY)j9YZcQ05qpyPW8mqj6s8gCimT1kWSzyhb7be6blWwNvWLpL(j7KqgYqia]] )


end
