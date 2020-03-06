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

    
    spec:RegisterPack( "Frost Mage", 20200305, [[dWunKbqiGk9iLKAtOiFIOQAuajofqsRcivsVIOYSqHUfrQYUe6xOKggPuogkyzkj8msPAAePY1usY2aQkFdiLmoGQKZruvADaPI5buX9iI9rKYbbQsTquIhcufnrGuPUiqv1gjQYhjsvnsGujCsGuSsLuZujrXnvsuANej)eiLAOavHLQKipfWubkxvjrLVsuvSxK(ljdwLdt1IvLhJyYQQldTzbFwPmAsXPLSALev9AsjZMWTvIDl63snCuQJdKkrlh0Zr10PCDs12bIVtugpqQ68OOwVsvZxPY(vmLbkyuGVBivQvOTvOnTPDTTQidYxTRngyGcymZgPaSDIw(gsbsFbPaYd2CBUvwFdPaSDMfT)PGrb4ToKGuanMXMd6WkRBLPr)fj9cR8Arx4w1jb6bJvETqyLc80lHbAs6Jc8DdPsTcTTcTPnTRTvfzq(QDTXafW1nnnKcaulGNuan1)Jj9rb(iNqbw9CYd2CBUvwFdN1REonMXMd6WkRBLPr)fj9cR8Arx4w1jb6bJvETqyDwV65wzDirZCRIX5wH2wH2M1Z6vph4Pgp3qoOZSE1Zj9MBLJJZj)wTGkRv)cL)5QKBO)NRdZj)Md3qlA1cQSw9lu(Nl0W5eo3MJJKo)ZbEc6EoDUVHXz9QNt6n3kH)Eo2WQHLX8CHgQfFUqdNd2MBvNrU553HFwdWEpMQg(ynBvrqLWtcgPaIIBCkyuaELBcuLTs4jbPGrLIbkyuam9Na)uwOaeyziSCkG5cmTi(681clIP)e4FoMMJnebrTr(rgI4RZxlS5yAUNEieFqVsvaI4EmcrNyuaNyvNuGGqhczMAuPwbfmkaM(tGFkluacSmewofGnebrTr(rgIBcNuUqXzxAHZX0Cp9qi(GELQaeX9yeIoXOaoXQoPabHoeYm1OsPDkyuam9Na)uwOaoXQoPaexiuoXQovIIBuarXnv6lifa5CmjiNAuPKokyuaNyvNuGaS3JPQHpkaM(tGFkluJk1QOGrbW0Fc8tzHcqGLHWYPaoXkqqfM4sH85K2CRyUD7MZjwbcQWexkKpN0MJH5yAoWDoZfyAroBrzwLBQIGrm9Na)uaNyvNuGNO2V3HFQrLc8rbJc4eR6Kcq6f0uCRHluam9Na)uwOgvkqlkyuam9Na)uwOaeyziSCkWtpeIfPicKh5Mt0AojZTQ5yAoWDUNEieFqVsvaI4EmcrNyuaNyvNua815Rfg1OsbErbJcGP)e4NYcfGaldHLtbE6Hq8b9kvbiI7XieDInhtZbkZ90dHyOYneYvDqfGn3Iq0j2C72nhBicIAJ8JmedcDiK55a15yAoqzUNEielsreipU4GEf3CIwZj9M7PhcXIuebYJCZjAnhOohORZ5eR6mgGn3ETWIiOhj6gQSAbNtU5CIvDg3eoPCHIZU0cJeNBkRwW5KBoNyvNXnHtkxO4SlTWObDqqHYQfCoWzUkjEAiKRcIwMYQfuzDCvrpzEoMM7PhcXfCPHmR6GsOtQV6drFHh)TSKc4eR6Kcueuj8KGuJkL8Lcgfat)jWpLfkabwgclNc80dH4d6vQcqe3Jri6eBUD7MJnebrTr(rgI4RZxlS52TBoZfyAXkjEAiKRcIwwet)jW)CmnhX5MYQfCo5MZGoiOqz1coN0MRsINgc5QGOLPSAbvwhxvuN9CmnhX5MYQfCo5MZGoiOqz1coh4mxLepneYvbrltz1cQSokDXFllPaoXQoPaBcNuUqXzxAHuJAuaKZXKGCkyuPyGcgfat)jWpLfkabwgclNcaBZTQZya27Xu1WhfGBWIyuagOaoXQoPaexiuoXQovIIBuarXnv6lifa5Cmjix1Wh1OsTckyuam9Na)uwOaeyziSCka4ohSn3QoJbyVhtvdFuaUblIrbyGc4eR6KcqCHq5eR6ujkUrbef3uPVGuaKZXKGC1hdUUWOg1Oa8k3eifmQumqbJcGP)e4NYcfGaldHLtbiDl(TSmweuLniEeI(N55yAUp(0dHOSkneYvenLqe1ztbCIvDsbkcQYgeNAuPwbfmkaM(tGFkluacSmewofa2MBvNrU553HFka3GfXOamqbCIvDsbiUqOCIvDQef3OaIIBQ0xqkaVYnbQ4MNFh(PgvkTtbJcGP)e4NYcfGaldHLtbGT5w1zmBvrqLWtcsb4gSigfGbkGtSQtkaXfcLtSQtLO4gfquCtL(csb4vUjqv2kHNeKAuPKokyuam9Na)uwOaeyziSCkaSn3QoJbyVhtvdFuaUblIrbyGc4eR6KcqCHq5eR6ujkUrbef3uPVGuaELBcu1Wh1OsTkkyuaNyvNuGIGQSbXPay6pb(PSqnQuGpkyuam9Na)uwOaoXQoPaw9rU1WffP)iONcqGLHWYPap9qiweMvGGvYJ)wwohtZ90dHiuprvhuSBzim(Bzjfi9fKcy1h5wdxuK(JGEQrLc0Icgfat)jWpLfkGtSQtkaHzIOnyNfr9eo3OaeyziSCkWtpeIfHzfiyL84VLLZX0Cp9qic1tu1bf7wgcJ)wwsbWqajMk9fKcqyMiAd2zrupHZnQrLc8IcgfWjw1jfiaBU9AHrbW0Fc8tzHAuPKVuWOay6pb(PSqbCIvDsbiUqOCIvDQef3OaIIBQ0xqkWsdcUGPrnQumOnkyuaNyvNuGIGkHNeKcGP)e4NYc1OgfGx5MavCZZVd)uWOsXafmkaM(tGFkluacSmewofWCbMweFD(AHfX0Fc8phtZXgIGO2i)idr815Rf2CmnhOmh4oN5cmT4MWjLluC2Lwyet)jW)C72n3tpeIfPicKh5Mt0AoWzoPBUD7M7PhcXh0RufGiUhJq0j2CGkfWjw1jfii0HqMPgvQvqbJcGP)e4NYcfGaldHLtbmxGPf3eoPCHIZU0cJy6pb(NJP5ydrquBKFKH4MWjLluC2Lw4Cmn3tpeIpOxPkarCpgHOtmkGtSQtkqqOdHmtnQuANcgfat)jWpLfkabwgclNcWgIGO2i)idXaS52Rf2Cmn3tpeIpOxPkarCpgHOtS5yAoqzoWDoZfyAXnHtkxO4SlTWiM(tG)52TBUNEielsreipYnNO1CGZCs3CGkfWjw1jfii0HqMPgvkPJcgfat)jWpLfkGtSQtkaXfcLtSQtLO4gfquCtL(csbqohtcYPgvQvrbJc4eR6KceG9Emvn8rbW0Fc8tzHAuPaFuWOay6pb(PSqbiWYqy5uaNyfiOctCPq(CsBUvm3UDZ5eRabvyIlfYNtAZXWCmnhX5MYQfCojZPT5yAUNEiedvUHqUQdQaS5weIoXMdCMBfuaNyvNuGNO2V3HFQrLc0Icgfat)jWpLfkabwgclNc80dHyOYneYvDqfGn3Iq0jgfWjw1jfOiOs4jbPgvkWlkyuaNyvNuasVGMIBnCHcGP)e4NYc1OsjFPGrbCIvDsbWxNVwyuam9Na)uwOgvkg0gfmkaM(tGFkluacSmewofaCNZjw1zma79yQA4lwPkiQnn2Cmn3gS1ZVYBmgG9Emvn8fH4IxjFojZPnkGtSQtka0zw1bva2CJAuPyGbkyuam9Na)uwOaeyziSCkaX5MYQfCojZPT52TBoNyfiOctCPq(CsBogOaoXQoPaprTFVd)uJkfdRGcgfat)jWpLfkabwgclNc80dH4d6vQcqe3Jri6eBUD7MJnebrTr(rgI4RZxlS52TBoNyfiOctCPq(CsBogMJP5mxGPf5SfLzvUPkcgX0Fc8tbCIvDsb2eoPCHIZU0cPg1Oa8k3eOQHpkyuPyGcgfat)jWpLfkGtSQtkaXfcLtSQtLO4gfquCtL(csbqohtcYPgvQvqbJc4eR6KceG9Emvn8rbW0Fc8tzHAuP0ofmkaM(tGFkluacSmewofGnebrTr(rgI4RZxlS5yAUNEieFqVsvaI4EmcrNyuaNyvNuGGqhczMAuPKokyuam9Na)uwOaeyziSCkGtSceuHjUuiFoPn3kMB3U5CIvGGkmXLc5ZjT5yyoMMJ4Ctz1coNK50gfWjw1jf4jQ97D4NAuPwffmkaM(tGFkluacSmewof4PhcXqLBiKR6GkaBUfHOtS5yAos3IFllJbyVhtvdFriU4vYNtAZTQ52TBUNEiedvUHqUQdQaS5weIoXMtYCRGc4eR6Kcueuj8KGuJkf4Jcgfat)jWpLfkabwgclNcqCUPSAbNtYCAJc4eR6Kc8e1(9o8tnQuGwuWOay6pb(PSqbiWYqy5ua2qee1g5hziIVoFTWOaoXQoPabHoeYm1OsbErbJcGP)e4NYcfGaldHLtbE6Hq8b9kvbiI7XieDInhtZbkZXgIGO2i)idXaS52Rf2C72n3hF6HqKTt0c)QIGriU4vYNtAZHGEKOBOYQfCo5MZjw1zSiOs4jbJg0bbfkRwW5avkGtSQtkqqOdHmtnQuYxkyuaNyvNuasVGMIBnCHcGP)e4NYc1OsXG2OGrbCIvDsbWxNVwyuam9Na)uwOgvkgyGcgfat)jWpLfkGtSQtka0zw1bva2CJcuPHqOoBtvbkWtpeIHk3qix1bva2ClcrNyswbfOsdHqD2MQwwWF5gsbyGcqGLHWYPaF8Phcr2orl8Rkcg1ztnQumSckyuaNyvNuGNO2V3HFkaM(tGFkluJAuGpgCDHrbJkfduWOaoXQoPaKwpneYzJcbfat)jWpLfQrLAfuWOay6pb(PSqbiWYqy5uaWDoyBUvDgZwveuj8KGZX0CSHiiQnYpYqmi0HqMNJP5a35E6Hqmu5gc5QoOcWMBri6eJc4eR6Kcueuj8KGuJkL2PGrbW0Fc8tzHc4eR6KcqCHq5eR6ujkUrbef3uPVGuas3IFll5uJkL0rbJcGP)e4NYcfGaldHLtbCIvGGkmXLc5ZjT50(CmnN5cmTyaI4(k3uqVYiM(tG)52TBoNyfiOctCPq(CsBoPJc4eR6KcqCHq5eR6ujkUrbef3uPVGuaVrQrLAvuWOay6pb(PSqbCIvDsbiUqOCIvDQef3OaIIBQ0xqkaVYnbsnQrb8gPGrLIbkyuaNyvNuGaS3JPQHpkaM(tGFkluJk1kOGrbCIvDsbEIA)Eh(Pay6pb(PSqnQuANcgfat)jWpLfkGtSQtkaXfcLtSQtLO4gfquCtL(csbqohtcYPgvkPJcgfWjw1jfG0lOP4wdxOay6pb(PSqnQuRIcgfWjw1jfOiOkBqCkaM(tGFkluJkf4Jcgfat)jWpLfkabwgclNcWgIGO2i)idr815Rf2C72n3tpeIpOxPkarCpgHOtS5yAoqzo2qee1g5hzigGn3ETWMJP5aL5E6HqSifrG8i3CIwZboZjDZTB3CG7CMlW0IBcNuUqXzxAHrm9Na)ZbQZTB3CSHiiQnYpYqCt4KYfko7slCoqLc4eR6Kcee6qiZuJkfOffmkaM(tGFkluacSmewof4PhcXqLBiKR6GkaBUfHOtmkGtSQtkqrqLWtcsnQuGxuWOaoXQoPaqNzvhubyZnkaM(tGFkluJkL8LcgfWjw1jfaFD(AHrbW0Fc8tzHAuPyqBuWOaoXQoPaBcNuUqXzxAHuam9Na)uwOgvkgyGcgfWjw1jfG0jQ6GI0Ipfat)jWpLfQrLIHvqbJcGP)e4NYcfWjw1jfWQpYTgUOi9hb9uacSmewof4PhcXIWSceSsE83YY5yAUNEieH6jQ6GIDldHXFllPaPVGuaR(i3A4II0Fe0tnQumODkyuam9Na)uwOaoXQoPaeMjI2GDwe1t4CJcqGLHWYPap9qiweMvGGvYJ)wwohtZ90dHiuprvhuSBzim(BzjfadbKyQ0xqkaHzIOnyNfr9eo3OgvkgKokyuaNyvNuGaS52Rfgfat)jWpLfQrLIHvrbJcGP)e4NYcfWjw1jfG4cHYjw1PsuCJcikUPsFbPalni4cMg1OsXa4JcgfWjw1jfOiOs4jbPay6pb(PSqnQrbwAqWfmnkyuPyGcgfat)jWpLfkabwgclNcS0GGlyAXFXnpj4CsBog0gfWjw1jf4jQulLNmtnQuRGcgfat)jWpLfkabwgclNc80dHyrqvq0ip(BzjfWjw1jfOiOkiAKtnQrbydrsV8CJcgvkgOGrbCIvDsbCiXtuvPHcbsmkaM(tGFkluJk1kOGrbCIvDsbK5gcvOaxW0Cbfat)jWpLfQrLs7uWOay6pb(PSqbsFbPa(EUgh6CvOtt1bf7wgcPaoXQoPa(EUgh6CvOtt1bf7wgcPgvkPJcgfWjw1jfyPGWgQQfFdPay6pb(PSqnQuRIcgfWjw1jfGDBvNuam9Na)uwOgvkWhfmkGtSQtkqa2C71cJcGP)e4NYc1OgfG0T43YsofmQumqbJc4eR6KcSP7WF5PQdkFpcBtdfat)jWpLfQrLAfuWOaoXQoPafHzfiyLCkaM(tGFkluJkL2PGrbCIvDsbwkiSHQAX3qkaM(tGFkluJkL0rbJcGP)e4NYcfGaldHLtbydrquBKFKHya27Xu1W3C72nNvlOYA1VW5K2CmOT5KBoIZnLvl4CmnNvlOYA1VW5aN5wH2OaoXQoPaq9evDqXULHqQrLAvuWOay6pb(PSqbiWYqy5uaZfyArOEIQoOy3Yqyet)jW)CmnNtSceuHjUuiFojZXWCmnhPBXVLLrOEIQoOy3YqymOlekis04Wnuz1coh4mhPBXVLLXaS3JPQHViex8k5uaNyvNuaIlekNyvNkrXnkGO4Mk9fKcyUattbB2uJkf4Jcgfat)jWpLfkabwgclNcWgIGO2i)idXIWSceSs(C72nNvlOYA1VW5aN50U2OaoXQoPaSBR6KAuPaTOGrbW0Fc8tzHc4eR6Kc8CbgkiQEqpjAOaeyziSCka4oN5cmT4MWjLluC2Lwyet)jW)C72n3tpeIpOxPkarCpgHOtS5yAo2qee1g5hziUjCs5cfNDPfsbsFbPapxGHcIQh0tIgQrLc8IcgfWjw1jfqNJQYWfofat)jWpLfQrLs(sbJc4eR6Kc8eD)vbDiZuam9Na)uwOgvkg0gfmkGtSQtkWdHCeQvLBuam9Na)uwOgvkgyGcgfWjw1jfquBAmUALx)VTGPrbW0Fc8tzHAuPyyfuWOaoXQoPaHcIpr3FkaM(tGFkluJkfdANcgfWjw1jfWtcYnOluexiOay6pb(PSqnQumiDuWOaoXQoPapFt1bLblIwCkaM(tGFkluJAuaKZXKGC1hdUUWOGrLIbkyuam9Na)uwOaeyziSCkWtpeIq9evDqXULHW4VLLZTB3CoXkqqfM4sH85K2CANc4eR6KceAIoh)kFpcldvp0xOgvQvqbJcGP)e4NYcfGaldHLtbCIvGGkmXLc5ZboZTQ5yAoqzUNEielsreipYnNO1CGJK5yyUD7MdCNZCbMwCt4KYfko7slmIP)e4FoqDoMMJ0T43YYya27Xu1WxeIlEL85K2CmOT5yAoqzoWDoyBUvDg5MNFh(NB3U5a35CIvDgdWEpMQg(IvQcIAtJnhtZTbB98R8gJbyVhtvdFriU4vYNtYCABoqLc4eR6KcSGlnKzvhucDs9vFi6lCQrLs7uWOay6pb(PSqbiWYqy5uaqzoZfyAXnHtkxO4SlTWiM(tG)5yAUNEielsreipYnNO1CsMBvZX0CGYCp9qi(GELQaeX9yeIoXMB3U5ydrquBKFKHi(681cBoqDoqDUD7MduMduMZjwbcQWexkKpN0Mt7ZTB3CG7CMlW0IBcNuUqXzxAHrm9Na)ZbQZX0CGYCSHiiQnYpYqma79yQA4BUD7MBd265x5ngdWEpMQg(IqCXRKpN0MBvZbQZbQuaNyvNuGNO7VQdktdQWexyMAuPKokyuam9Na)uwOaeyziSCkWtpeIq9evDqXULHW4VLLZTB3CoXkqqfM4sH85K2CANc4eR6KcWwhwbMRCt9eo3OgvQvrbJcGP)e4NYcfGaldHLtbE6HqeQNOQdk2Tmeg)TSCUD7MZjwbcQWexkKpN0Mt7uaNyvNuayXMTavvQ4SDcsnQuGpkyuam9Na)uwOaoXQoPaKojyAq3WVki8fKcqGLHWYPap9qic1tu1bf7wgcJ)wwsbevIkYNca(Ogvkqlkyuam9Na)uwOaeyziSCkWtpeIq9evDqXULHW4VLLuaNyvNuai6SRCtfe(cYPgvkWlkyuam9Na)uwOaeyziSCkWtpeIqKOLa5CvOHemQZMc4eR6KcyAqLE(A98RcnKGuJkL8Lcgfat)jWpLfkabwgclNc80dHiuprvhuSBzim(Bz5C72nNtSceuHjUuiFoPnN2PaoXQoPaYAO4dcwPcI8o9KGuJAuaKZXKGCvdFuWOsXafmkaM(tGFkluacSmewof4PhcrOEIQoOy3Yqy83YY5yAUp(0dHiBNOf(vfbJ)wwo3UDZ5eRabvyIlfYNtAZPDkGtSQtkqOj6C8R89iSmu9qFHAuPwbfmkaM(tGFkluacSmewofWjwbcQWexkKph4m3QMJP5(4tpeISDIw4xvem(Bz5CmnhPBXVLLXaS3JPQHViex8k5ZjT5w1Cmnh4oNtSQZya27Xu1WxSsvquBAS5yAUnyRNFL3yma79yQA4lcXfVs(CsMtBuaNyvNuGfCPHmR6GsOtQV6drFHtnQuANcgfat)jWpLfkabwgclNcWgIGO2i)idXaS3JPQHV52TBUnyRNFL3yma79yQA4lcXfVs(CsBUvrbCIvDsbEIU)QoOmnOctCHzQrLs6OGrbW0Fc8tzHcqGLHWYPap9qic1tu1bf7wgcJ)wwohtZ9XNEiez7eTWVQiy83YY52TBoNyfiOctCPq(CsBoTtbCIvDsbyRdRaZvUPEcNBuJk1QOGrbW0Fc8tzHcqGLHWYPap9qic1tu1bf7wgcJ)wwohtZ9XNEiez7eTWVQiy83YY52TBoNyfiOctCPq(CsBoTtbCIvDsbGfB2cuvPIZ2ji1Osb(OGrbW0Fc8tzHc4eR6Kcq6KGPbDd)QGWxqkabwgclNc80dHiuprvhuSBzim(Bz5Cmn3hF6HqKTt0c)QIGXFllPaIkrf5tbaFuJkfOffmkaM(tGFkluacSmewof4PhcrOEIQoOy3Yqy83YY5yAUp(0dHiBNOf(vfbJ)wwsbCIvDsbGOZUYnvq4liNAuPaVOGrbW0Fc8tzHcqGLHWYPap9qicrIwcKZvHgsWOoBkGtSQtkGPbv65R1ZVk0qcsnQuYxkyuam9Na)uwOaeyziSCkWtpeIq9evDqXULHW4VLLZX0CF8Phcr2orl8Rkcg)TSCoMMJ0T43YYya27Xu1WxeIlEL85aN5KU52TBoNyfiOctCPq(CsBoTtbCIvDsbK1qXheSsfe5D6jbPg1OaMlW0uWMnfmQumqbJcGP)e4NYcfGaldHLtbmxGPf3eoPCHIZU0cJy6pb(NJP5E6HqSifrG8i3CIwZjzUvnhtZbkZ90dH4d6vQcqe3Jri6eBUD7MZCbMweFD(AHfX0Fc8phtZr6w8BzzeFD(AHfH4IxjFoWzoIZnLvl4CGkfWjw1jfaQNOQdk2TmesnQuRGcgfat)jWpLfkabwgclNcaUZzUatlUjCs5cfNDPfgX0Fc8phtZbkZzUatlIVoFTWIy6pb(NJP5iDl(TSmIVoFTWIqCXRKph4mhX5MYQfCUD7MZCbMwK0lOP4wdxIy6pb(NJP5iDl(TSms6f0uCRHlriU4vYNdCMJ4Ctz1co3UDZzUatlcDMvDqfGn3Iy6pb(NJP5iDl(TSmcDMvDqfGn3IqCXRKph4mhX5MYQfCUD7MJOXHBixfGoXQoDXCsBogIY35avkGtSQtkauprvhuSBziKAuJAuaqqiV6Kk1k02k0M20U2yGciZHzLBCkG8b8ELKc0iL0h0zU5atdoxTWUH2CHgoN8V0GGlyAY)Cqe0L6fe)ZX7fCox36f3W)CenEUH84SELPsCogaDMBLl56Sz3qd)Z5eR6Co5)jQulLNml)Xz9Sg0SWUHg(NJbTpNtSQZ5ef34XznfGZgjuPaFshfGnSdLaPaREo5bBUn3kRVHZ6vpNgZyZbDyL1TY0O)IKEHvETOlCR6Ka9GXkVwiSoRx9CRSoKOzUvX4CRqBRqBZ6z9QNd8uJNBih0zwV65KEZTYXX5KFRwqL1QFHY)CvYn0)Z1H5KFZHBOfTAbvwR(fk)ZfA4CcNBZXrsN)5apbDpNo33W4SE1Zj9MBLWFphBy1WYyEUqd1IpxOHZbBZTQZi3887WpRbyVhtvdFSMTQiOs4jbJZ6z9QNd8d6rIUH)5EyOH4CKE552CpCRsECoWBcbzB85YoLEAC4sqxmNtSQt(CDkyooRx9CoXQo5r2qK0lp3KeeoxRz9QNZjw1jpYgIKE55MCsyn09FwV65CIvDYJSHiPxEUjNewD9Tfmn3QoN1oXQo5r2qK0lp3KtcRoK4jQQ0qHaj2S2jw1jpYgIKE55MCsyLRVS0PsMBiuHcCbtZfZ6vpNtSQtEKnej9YZn5KWkpD2CnTP4MB8zTtSQtEKnej9YZn5KWQohvLHlmM(ckX3Z14qNRcDAQoOy3Yq4S2jw1jpYgIKE55MCsyDPGWgQQfFdN1oXQo5r2qK0lp3KtcRSBR6Cw7eR6KhzdrsV8CtojSgGn3ETWM1Z6vph4h0JeDd)ZHGGqMNZQfCotdoNtSgoxXNZbXlH)eyCw7eR6KlH06PHqoBuiM1REoqtyotdo3IVHZPX5ZjVwEZ5bdHZrCUv52CvYnpT5KNqhczMX5KHZr8CUpkCMNZ0GZbAi4CRmEsW588pNohNRnniCon1MM5ydRgwgZZ5eR6KX5QWCoiEj8NaJZANyvNC5KWArqLWtcYyfKaUW2CR6mMTQiOs4jbzInebrTr(rgIbHoeYmtG7tpeIHk3qix1bva2ClcrNyZANyvNC5KWkXfcLtSQtLO4gJPVGsiDl(TSKpRx9CGPbNZC4gAZzAGixtl(Zv8u(T5qqVtS4CSGMmeZ50U0BvZzoCdnoJZzAW5(viGqmjiFUhAYqmNZ0GZba2CE(Nd8Ub)Z5eR6CorXn(CoeNd6MgeohFXfI4CGUOLHGGqgNtEqe3x52CRKx5CSHyaH8505vUnh4Dd(NZjw15CIIBZX7or4CoFUYM7HjgkJp3geDtW8CbyVmNPbNttTPzo2WQHLX8CSiQ97D4FoNyvNXzTtSQtUCsyL4cHYjw1PsuCJX0xqjEJmwbjoXkqqfM4sHCPPDMmxGPfdqe3x5Mc6vgX0Fc8VBNtSceuHjUuixAs3S2jw1jxojSsCHq5eR6ujkUXy6lOeELBcCwpRx9CYNY0mN8GiUVYT5wjVsgNRm5Np3dndHZz9CSHvdlR2JZPZRCBo5b79yohOn8nNmnyo3RnnZjpq7588phlIA)Eh(NZH4CDimhPBXVLLX5KpLPP1T5KheX9vUn3k5vY4CMgCosNGGqooxXNZG64CUW006BAMZ0GZ9RqaHysW5k(ClvwCIUaNtpTsmhiiK550uBAMZC4gAZrA904XzTtSQtE0Busa27Xu1W3S2jw1jp6nkNewFIA)Eh(N1oXQo5rVr5KWkXfcLtSQtLO4gJPVGsqohtcYN1oXQo5rVr5KWkPxqtXTgUmRDIvDYJEJYjH1IGQSbXN1REoGAHTOcf(NtEcDiK55iD(lR6Kpxa2lZzAW5aaBoNyvNZjkUfNdOscoNPbNBX3W5k(CByIq3QCBUGdNtGC(CSa9kNtEqe3JZr04WnKZ4CMgCoe07eBosN)YQoNtdcX5kEk)2CUqmNPXT5Qf2n080IZANyvN8O3OCsyni0HqMzScsydrquBKFKHi(681cB3UNEieFqVsvaI4EmcrNymbkSHiiQnYpYqmaBU9AHXeO80dHyrkIa5rU5eTahPB3oW1CbMwCt4KYfko7slmIP)e4hu3TJnebrTr(rgIBcNuUqXzxAHG6S2jw1jp6nkNewlcQeEsqgRGKNEiedvUHqUQdQaS5weIoXM1REoW0GZT4B4CYkHyUnmrOlemp3dNBdte6wLBZ5ZjABUomN8A5nhrJd3q(CY0G5C68k3MZ0GZbE3G)5CIvDoNO4wCoWGmx52Cwp3hfoZZTsoZZ1H5KhS52C6PvI5mnieNZH4CzpN8A5nhrJd3q(CE(Nl75CIvGGZjpyVhZ5aTHp(CYADXFob6)5SEUYMlBBUhw52C6C8pNBZ5crCw7eR6Kh9gLtcRqNzvhubyZTzTtSQtE0BuojSIVoFTWM1oXQo5rVr5KW6MWjLluC2Lw4SE1ZTYXRCBoWZoX56WCGNT4pxXNBP5MG55aDdEamxI6g0fZjRmnZzAW5aVBW)CMd3qBotde5AAXNhNd0yZ1PG55EiPxq(CFKGPn3Mx5CYktZCWwFtJG55aTMRHZT0qCoZHBOXJZANyvN8O3OCsyL0jQ6GI0I)S2jw1jp6nkNew15OQmCHX0xqjw9rU1WffP)iONXki5PhcXIWSceSsE83YsME6HqeQNOQdk2Tmeg)TSCw7eR6Kh9gLtcR6CuvgUWigciXuPVGsimteTb7SiQNW5gJvqYtpeIfHzfiyL84VLLm90dHiuprvhuSBzim(Bz5S2jw1jp6nkNewdWMBVwyZANyvN8O3OCsyL4cHYjw1PsuCJX0xqjlni4cM2S2jw1jp6nkNewlcQeEsWz9S2jw1jps6w8BzjxYMUd)LNQoO89iSnnZANyvN8iPBXVLLC5KWArywbcwjFw7eR6KhjDl(TSKlNewxkiSHQAX3Wz9QNBL0tCUomh4rldHZv85CHmNz(C6C8pNSY0mN8G9EmNd0g(IZbENmpNadwdccNJOXHBiFo3MZ0GZH5FUomNPbNluBAS54AADXFUhoNoh)mox9rxiyEUkmNPbN71C(C)g5P8BZ9lCUkNZ0GZTu)VaNRdZzAW5wj9eN7PhcXzTtSQtEK0T43YsUCsyfQNOQdk2TmeYyfKWgIGO2i)idXaS3JPQHVD7SAbvwR(fkng0MCeNBkRwqMSAbvwR(fcoRqBZ6vphODohVYnboN5Wn0MluBAmoJZzAW5iDl(TSCUom3kPN4CDyoWJwgcNR4ZjAziCotJNZzAW5iDl(TSCUomN8G9EmNd0g(yCottXNBRab5ZHGEd6ZTs6joxhMd8OLHW5iAC4gYNZ042CCnTU4p3dNtNJ)5KvMM5CIvGGZzUatJZ4Cvyo2nNxpbgN1oXQo5rs3IFll5YjHvIlekNyvNkrXngtFbLyUattbB2mwbjMlW0Iq9evDqXULHWiM(tGFMCIvGGkmXLc5syGjs3IFllJq9evDqXULHWyqxiuqKOXHBOYQfeCiDl(TSmgG9Emvn8fH4IxjFw7eR6KhjDl(TSKlNewz3w1jJvqcBicIAJ8JmelcZkqWk572z1cQSw9leC0U2M1oXQo5rs3IFll5YjHvDoQkdxym9fuYZfyOGO6b9KOHXkibCnxGPf3eoPCHIZU0cJy6pb(3T7PhcXh0RufGiUhJq0jgtSHiiQnYpYqCt4KYfko7slCw7eR6KhjDl(TSKlNew15OQmCHpRDIvDYJKUf)wwYLtcRpr3FvqhY8S2jw1jps6w8BzjxojS(qihHAv52S2jw1jps6w8BzjxojSkQnngxTYR)3wW0M1oXQo5rs3IFll5YjH1qbXNO7)S2jw1jps6w8BzjxojS6jb5g0fkIleZANyvN8iPBXVLLC5KW6Z3uDqzWIOfFwpRx9CGFohtcYbDMdW887W)CE(NtQEoqdbNBLXtcoRDIvDYJiNJjb5QpgCDHjj0eDo(v(EewgQEOVWyfK80dHiuprvhuSBzim(Bz5UDoXkqqfM4sHCPP9zTtSQtEe5Cmjix9XGRlm5KW6cU0qMvDqj0j1x9HOVWzScsCIvGGkmXLc5GZQycuE6HqSifrG8i3CIwGJeg2TdCnxGPf3eoPCHIZU0cJy6pb(bvMiDl(TSmgG9Emvn8fH4IxjxAmOnMafWf2MBvNrU553H)D7axNyvNXaS3JPQHVyLQGO20ymTbB98R8gJbyVhtvdFriU4vYLOnqDw7eR6KhrohtcYvFm46ctojS(eD)vDqzAqfM4cZmwbjGI5cmT4MWjLluC2Lwyet)jWptp9qiwKIiqEKBorljRIjq5PhcXh0RufGiUhJq0j2UDSHiiQnYpYqeFD(AHbQG6UDGcO4eRabvyIlfYLM23TdCnxGPf3eoPCHIZU0cJy6pb(bvMaf2qee1g5hzigG9Emvn8TB3gS1ZVYBmgG9Emvn8fH4IxjxARcub1zTtSQtEe5Cmjix9XGRlm5KWkBDyfyUYn1t4CJXki5PhcrOEIQoOy3Yqy83YYD7CIvGGkmXLc5st7ZANyvN8iY5ysqU6JbxxyYjHvyXMTavvQ4SDcYyfK80dHiuprvhuSBzim(Bz5UDoXkqqfM4sHCPP9zTtSQtEe5Cmjix9XGRlm5KWkPtcMg0n8RccFbzuujQiFjGpgRGKNEieH6jQ6GIDldHXFllN1oXQo5rKZXKGC1hdUUWKtcRq0zx5Mki8fKZyfK80dHiuprvhuSBzim(Bz5S2jw1jpICoMeKR(yW1fMCsy10Gk98165xfAibzScsE6HqeIeTeiNRcnKGrD2ZANyvN8iY5ysqU6JbxxyYjHvznu8bbRubrENEsqgRGKNEieH6jQ6GIDldHXFll3TZjwbcQWexkKlnTpRN1REoWpNJjb5GoZjpyVhZ5aTHVzTtSQtEe5Cmjix1WNCsyn0eDo(v(EewgQEOVWyfK80dHiuprvhuSBzim(BzjtF8Phcr2orl8Rkcg)TSC3oNyfiOctCPqU00(S2jw1jpICoMeKRA4tojSUGlnKzvhucDs9vFi6lCgRGeNyfiOctCPqo4SkM(4tpeISDIw4xvem(BzjtKUf)wwgdWEpMQg(IqCXRKlTvXe46eR6mgG9Emvn8fRufe1MgJPnyRNFL3yma79yQA4lcXfVsUeTnRDIvDYJiNJjb5Qg(KtcRpr3FvhuMguHjUWmJvqcBicIAJ8JmedWEpMQg(2TBd265x5ngdWEpMQg(IqCXRKlTvnRDIvDYJiNJjb5Qg(KtcRS1HvG5k3upHZngRGKNEieH6jQ6GIDldHXFllz6Jp9qiY2jAHFvrW4VLL725eRabvyIlfYLM2N1oXQo5rKZXKGCvdFYjHvyXMTavvQ4SDcYyfK80dHiuprvhuSBzim(BzjtF8Phcr2orl8Rkcg)TSC3oNyfiOctCPqU00(S2jw1jpICoMeKRA4tojSs6KGPbDd)QGWxqgfvIkYxc4JXki5PhcrOEIQoOy3Yqy83YsM(4tpeISDIw4xvem(Bz5S2jw1jpICoMeKRA4tojScrNDLBQGWxqoJvqYtpeIq9evDqXULHW4VLLm9XNEiez7eTWVQiy83YYzTtSQtEe5Cmjix1WNCsy10Gk98165xfAibzScsE6HqeIeTeiNRcnKGrD2ZANyvN8iY5ysqUQHp5KWQSgk(GGvQGiVtpjiJvqYtpeIq9evDqXULHW4VLLm9XNEiez7eTWVQiy83YsMiDl(TSmgG9Emvn8fH4IxjhCKUD7CIvGGkmXLc5st7Z6zTtSQtEe5CmjixcXfcLtSQtLO4gJCdwetcdmM(ckb5Cmjix1WhJvqcSn3QoJbyVhtvdFZANyvN8iY5ysqUCsyL4cHYjw1PsuCJrUblIjHbgtFbLGCoMeKR(yW1fgJvqc4cBZTQZya27Xu1W3SEw7eR6KhxAqWfmnjprLAP8KzgRGKLgeCbtl(lU5jbLgdABw7eR6KhxAqWfmn5KWArqvq0iNXki5PhcXIGQGOrE83YYz9SE1Zbu5MaNdmhUH2SE1ZjFkttRBZj9byCoW)RZxlS5k(CUqMZmFoUg3meI)4CYNY0mN0hGX5a)VoFTWMR4ZX14MHq8pxfMRS5K16I)CYCUHZXc0RCo5brCpohrJd3W5aLkIX5KPbZ5mn4Cl(goh3COXNJ4CRYT5a)VoFTWMtwzAMJfOx5CYdI4ECoNyfiiOoxdNtMgmN7HIw2Cs3CGgsreiFoqPcZb(FD(AHnxXNJ4CBozAWCotdo3IVHZPX5ZjDsVvnhOHuebYzCUYKF(Cp0meoN1ZPZX5mn4CSa9kNtEqe3JZfG9YCLnxNZj9foPCXCaSlTqqnoRDIvDYJ8k3eOIBE(D4xsqOdHmZyfKyUatlIVoFTWIy6pb(zInebrTr(rgI4RZxlmMafW1CbMwCt4KYfko7slmIP)e4F3UNEielsreipYnNOf4iD7290dH4d6vQcqe3Jri6eduN1REoPVWjLlMdGDPfoxXNZfYCM5ZX14MHq8hN1oXQo5rELBcuXnp)o8lNewdcDiKzgRGeZfyAXnHtkxO4SlTWiM(tGFMydrquBKFKH4MWjLluC2Lwitp9qi(GELQaeX9yeIoXM1REo5tzAADBoPpaJZzAW5w8nCUvEDUnNblKpN1ZX14MHW5C(ClEY8CYd2C71cJpNZNJDZ51tGX5KpLPzoPpaJZzAW5w8nCUofmphxJBgc5ZjpyZTxlS5mnUnNSwx8NJTUnNPbxMZT5yq6P95anKIiW54Mt0IhNd0Dfcietco3dnziMZX14MHWk3MtEWMBVwyZjRmnZXG0t7ZbAifrG8588phdspPBoqdPicKpxXNJV4cbJZ90T5yq6P95mm)85SEUho3dndHZv5ClneNJxMUBvN85aftdoNMAtdcNt6dm33x8nCUIZ4CMgCULgIZv2Cc0t(CwlZHF(Cmi90oOgNtEnKu52CCnUziCUoNtEWMBVwyZv854wjeZ5ZXxCHyUnVsgNJ3Zv85Y2MJ4Wk3MZFTUnN8A5fNd0qW5wz8KGZv85SUNtg6AnN1ZjZHqpT5(OWzUYT5yb6voN8GiUhNtEcDiK54S2jw1jpYRCtGkU553HF5KWAqOdHmZyfKWgIGO2i)idXaS52Rfgtp9qi(GELQaeX9yeIoXycuaxZfyAXnHtkxO4SlTWiM(tG)D7E6HqSifrG8i3CIwGJ0bQZANyvN8iVYnbQ4MNFh(LtcRexiuoXQovIIBmM(ckb5CmjiFw7eR6Kh5vUjqf3887WVCsyna79yQA4BwV65KpLPzo5brCFLBZTsELZ55Fo3MtGo3MBfZzoCdnoJZXIO2V3H)5se)85SEUhoNoh)ZjRmnZPP20GW5ydRgwgZZz9ClUw4CCDiohZT(CepNlu2CV20mxLCZtBowe1(9o8ZNRsRNZNJx5MaNtEqe3x52CRKxzCoaZHwLBZjRmnZzAGioN5Wn04mohlIA)Eh(NtGoiiFotdoNOLnhBy1WYyEUqjeiCoylW588pxXNtNJ)56Cos3IFllNdu88p3kVo3MBX1QYT546qCUST5SEozo3W5yb6voN8GiUhNJOXHBihuNtwzAMRHZjRmnTUnN8GiUVYT5wjVY4S2jw1jpYRCtGkU553HF5KW6tu737WpJvqItSceuHjUuixARy3oNyfiOctCPqU0yGjIZnLvlOeTX0tpeIHk3qix1bva2ClcrNyGZkM1REoWGmx52Cwph7UfZr04WnKpxhMtET8Ml0W58KzttLBZv8u(T5K1qtZCLfNBLJJZzAWL5C(CMgK55i9cgN1oXQo5rELBcuXnp)o8lNewlcQeEsqgRGKNEiedvUHqUQdQaS5weIoXM1oXQo5rELBcuXnp)o8lNewj9cAkU1WLzTtSQtEKx5MavCZZVd)YjHv815Rf2SE1ZTsoZZ1H5KhS52CfFoDo(NZdgcNZfI5KxLBiKpxhMtEWMBZr04WnKpNgheCUhI5C6C8pNN)5mnieNR4P8BZ5eRabNtEWEpMZbAdFZzACBosRl(ZTHjcDdNBPHyCoW0u85k(CDkyEoFo(IleZT5voNV5vYT5w0fwXwGZzoCdnoJZ585wjN556WCYd2CBUINYVnN19C1cBNybDrCw7eR6Kh5vUjqf3887WVCsyf6mR6GkaBUXyfKaUoXQoJbyVhtvdFXkvbrTPXyAd265x5ngdWEpMQg(IqCXRKlrBZ6vphlIA)Eh(NR4ZPZX)CoForlBo2WQHLX8CHsiq4C(Mxj3MBfZzoCdnECo5JgmNtNx52CYdI4(k3MBL8kzCUYKF(C(Cl4V0xMBZRCoRNtNJZzAW5QKBEAZXIO2V3H)5qqWCoFZRKBZ5ZXRCtGZzoCdngNd5Srs5cbZZjRmnZjAzZT4CdHmhN1oXQo5rELBcuXnp)o8lNewFIA)Eh(zScsio3uwTGs02UDoXkqqfM4sHCPXWSE1Zj9foPCXCaSlTW5k(C6C8pNmnyoNPbHO8ZNZNJfOx5CYdI4ECo2WMmNtSceCoqPIyCUofmpNmnyoxzZr8CUhohxJBgcXpOgNdmnfFUIpNphFXfI5SEUf8x6lZT5voxLZT0CBoEz6UvDYJZTY0YMBX5gczEob6jFoRL5WpFoDELBZv2CY0G5CoiEj8NaJZjF0G5C68k3MdGTOmRYT5aneCop)ZPXbPYT58SnniCoZHBOnxIo8XmJZvM8ZNJlQnnMG55EOziCoRNtNJZj9bMtMgmNZbXlH)eiJZ585mn4CCK05FoZHBOn3VrEk)2CpmXqzZfG9YCCnUziSYT5mn4ClELZzoCdT4S2jw1jpYRCtGkU553HF5KW6MWjLluC2LwiJvqYtpeIpOxPkarCpgHOtSD7ydrquBKFKHi(681cB3oNyfiOctCPqU0yGjZfyAroBrzwLBQIGrm9Na)Z6zTtSQtEKx5MavzReEsqjbHoeYmJvqI5cmTi(681clIP)e4Nj2qee1g5hziIVoFTWy6PhcXh0RufGiUhJq0j2S2jw1jpYRCtGQSvcpjOCsyni0HqMzScsydrquBKFKH4MWjLluC2Lwitp9qi(GELQaeX9yeIoXM1oXQo5rELBcuLTs4jbLtcRexiuoXQovIIBmM(ckb5CmjiFw7eR6Kh5vUjqv2kHNeuojSgG9Emvn8nRDIvDYJ8k3eOkBLWtckNewFIA)Eh(zScsCIvGGkmXLc5sBf725eRabvyIlfYLgdmbUMlW0IC2IYSk3ufbJy6pb(N1oXQo5rELBcuLTs4jbLtcRKEbnf3A4YS2jw1jpYRCtGQSvcpjOCsyfFD(AHXyfK80dHyrkIa5rU5eTKSkMa3NEieFqVsvaI4EmcrNyZANyvN8iVYnbQYwj8KGYjH1IGkHNeKXki5PhcXh0RufGiUhJq0jgtGYtpeIHk3qix1bva2ClcrNy72XgIGO2i)idXGqhczguzcuE6HqSifrG84Id6vCZjAj9E6HqSifrG8i3CIwGkORoXQoJbyZTxlSic6rIUHkRwq5CIvDg3eoPCHIZU0cJeNBkRwq5CIvDg3eoPCHIZU0cJg0bbfkRwqWPsINgc5QGOLPSAbvwhxv0tMz6PhcXfCPHmR6GsOtQV6drFHh)TSCw7eR6Kh5vUjqv2kHNeuojSUjCs5cfNDPfYyfK80dH4d6vQcqe3Jri6eB3o2qee1g5hziIVoFTW2TZCbMwSsINgc5QGOLfX0Fc8ZeX5MYQfuod6GGcLvlO0QK4PHqUkiAzkRwqL1Xvf1zZeX5MYQfuod6GGcLvli4ujXtdHCvq0YuwTGkRJsx83YYz9S2jw1jpYRCtGQg(KqCHq5eR6ujkUXy6lOeKZXKG8zTtSQtEKx5Mavn8jNewdWEpMQg(M1oXQo5rELBcu1WNCsyni0HqMzScsydrquBKFKHi(681cJPNEieFqVsvaI4EmcrNyZANyvN8iVYnbQA4tojS(e1(9o8ZyfK4eRabvyIlfYL2k2TZjwbcQWexkKlngyI4Ctz1ckrBZANyvN8iVYnbQA4tojSweuj8KGmwbjp9qigQCdHCvhubyZTieDIXePBXVLLXaS3JPQHViex8k5sBv7290dHyOYneYvDqfGn3Iq0jMKvmRDIvDYJ8k3eOQHp5KW6tu737WpJvqcX5MYQfuI2M1oXQo5rELBcu1WNCsyni0HqMzScsydrquBKFKHi(681cBw7eR6Kh5vUjqvdFYjH1GqhczMXki5PhcXh0RufGiUhJq0jgtGcBicIAJ8JmedWMBVwy729XNEiez7eTWVQiyeIlELCPHGEKOBOYQfuoNyvNXIGkHNemAqheuOSAbb1zTtSQtEKx5Mavn8jNewj9cAkU1WLzTtSQtEKx5Mavn8jNewXxNVwyZANyvN8iVYnbQA4tojScDMvDqfGn3yScs(4tpeISDIw4xvemQZMXknec1zBQki5PhcXqLBiKR6GkaBUfHOtmjRGXknec1zBQAzb)LBOegM1oXQo5rELBcu1WNCsy9jQ97D4FwpRx9CGMCoEVGZXlt3TQtoJZXCRphXZ54ACZq4CGgcoNuni(CiiyoNhmeoNlGO)zEoIZTk3MtEcDiK5588phOHGZTY4jbJZbABAqOSIJZzAk(CoXQoNR4ZPZX)CY0G5CMgCUfFdNtJZNtET8MZdgcNJ4CRYT5KNqhczMX54ioN)AqW4S2jw1jpYRCtGskcQYgeNXkiH0T43YYyrqv2G4ri6FMz6Jp9qikRsdHCfrtjerD2ZANyvN8iVYnbkNewjUqOCIvDQef3yKBWIysyGX0xqj8k3eOIBE(D4NXkib2MBvNrU553H)zTtSQtEKx5MaLtcRexiuoXQovIIBmYnyrmjmWy6lOeELBcuLTs4jbzScsGT5w1zmBvrqLWtcoRDIvDYJ8k3eOCsyL4cHYjw1PsuCJrUblIjHbgtFbLWRCtGQg(yScsGT5w1zma79yQA4Bw7eR6Kh5vUjq5KWArqv2G4ZANyvN8iVYnbkNew15OQmCHX0xqjw9rU1WffP)iONXki5PhcXIWSceSsE83YsME6HqeQNOQdk2Tmeg)TSCw7eR6Kh5vUjq5KWQohvLHlmIHasmv6lOecZerBWolI6jCUXyfK80dHyrywbcwjp(Bzjtp9qic1tu1bf7wgcJ)wwoRDIvDYJ8k3eOCsynaBU9AHnRDIvDYJ8k3eOCsyL4cHYjw1PsuCJX0xqjlni4cM2S2jw1jpYRCtGYjH1IGkHNeCwpRx9CYNY0mN0x4KYfZbWU0czCUvspX56WCGhTmeohxtRl(Z9W5054FoyTPXM7HHgIZzAW5K(cNuUyoa2Lw4CKE51ZbkveJZjRmnZTQ5anKIiq(CE(NZNJfOx5CYdI4EeuJZjF0G5CG)xNVwyZv856qyos3IFllzCUvspX56WCGhTmeohXZ5CbVN7HZPZX)CR86CBozLPzUvnhOHuebYJZANyvN8O5cmnfSzlbQNOQdk2TmeYyfKyUatlUjCs5cfNDPfgX0Fc8Z0tpeIfPicKh5Mt0sYQycuE6Hq8b9kvbiI7XieDITBN5cmTi(681clIP)e4Njs3IFllJ4RZxlSiex8k5GdX5MYQfeuN1REo5tzAADBoPVWjLlMdGDPfY4CRKEIZ1H5apAziCoUMwx8N7HZPZX)Cpm0qCopzEUxTTHW5iDl(TSCoqb8)681cJX5ap7f0MdWA4cJZTsoZZ1H5KhS5gOoxdNtMgmNBL0tCUomh4rldHZv858xRBZz9Cq0jAMBfZr04WnKhN1oXQo5rZfyAkyZwojSc1tu1bf7wgczScsaxZfyAXnHtkxO4SlTWiM(tGFMafZfyAr815Rfwet)jWptKUf)wwgXxNVwyriU4vYbhIZnLvl4UDMlW0IKEbnf3A4set)jWptKUf)wwgj9cAkU1WLiex8k5GdX5MYQfC3oZfyArOZSQdQaS5wet)jWptKUf)wwgHoZQoOcWMBriU4vYbhIZnLvl4UDenoCd5Qa0jw1PlKgdr5lOsnQrPa]] )


end
