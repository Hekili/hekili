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

    
    spec:RegisterPack( "Frost Mage", 20190728, [[dSextbqicrEKkjTjKkFsjKgLkPCkvs1RqQAweu3sjuSls9lKOHjKYXqswgHKNPeyAeI6AcPABkHQVPeuJtjeNJqiRJqQAEQK4EeyFQu5GkbXcrs9qLG0ejeQCrcP0gvPkFujuYijeQQtsifRuiMjHuXnvPQyNiHFQsvPHsiOLQsv1tvQPQeDvcPsFLqOSxi)LKbJYHfTyf9yOMSkUmyZc(SsA0QeNwYQvcL61cjZMOBlu7MQFl1WrkhNqOklhXZr10PCDfSDfQVtOgpHaNNGSEvkZxHSFvnIk0s0(KgGOqurJkru0wyrTiAQw4OVWurfABcrdqBAjoQCfqBpJb0(EKMBp7(KRaAtlfs25bTeT59abdO9fZOXf9us5AzxgMAChtjVIhKPvTJjzWOKxXykr75qjnrJJMO9jnarHOIgvIOOTWIAr0uTWrFHJ2IG25GDPjO9UIxOO9L6Cahnr7dWXO9vF29in3E29jxHpYvF2fZOXf9us5AzxgMAChtjVIhKPvTJjzWOKxXyk)ix9zrgKc9mrTic)mrfnQerpBX8mQIMOFblYh5JC1NTqVK(kWf9FKR(SfZZeD5WZwuRIbL1Qtbl6ZkNBqEEwhE2IAjzfmTvXGYA1PGf9zHM8mzYTNXbC7NNTqfX9SbEUc6pYvF2I5z3hGScp7EKMBp7(KRWZwiIqrh(ZU2m5W5zT)SvWbsAnH)SYFghRIZvqJPr76OTS4ghTeT5LVkb0sefuHwI2GNtjCquJ2yszaPs0g3T80IDDHbL3JtnbYJqpJUNDG5qiOfxUbeUcFPKs9an0oXw1oAxyq594ezikefAjAdEoLWbrnAJjLbKkrBsBPvTR5w6NKCq7eBv7OnoLsvITQDLS4gAllUP8mgqBE5RsqXT0pj5GmeflaTeTbpNs4GOgTXKYasLOnPT0Q21ERkmOKPJb0oXw1oAJtPuLyRAxjlUH2YIBkpJb0Mx(QeuERKPJbKHOqKrlrBWZPeoiQrBmPmGujAtAlTQDDG03ax1KjANyRAhTXPuQsSvTRKf3qBzXnLNXaAZlFvcQMmrgIIOJwI2j2Q2r7cdkVhNOn45uche1idrXIJwI2GNtjCquJ2j2Q2rBRoa3AsSc3hqeG2yszaPs0Eoec6clKAmuoxFAX(ZO7zZHqqtgCq1bfTwmq0NwSJ2EgdOTvhGBnjwH7dicqgIIfgTeTbpNs4GOgTtSvTJ20ACuGXRBWrH7yAdwAv7QdmUWaAJjLbKkr75qiOlSqQXq5C9Pf7pJUNnhcbnzWbvhu0AXarFAXoAdHaGnLNXaAJfclBJ0EHvtzYnKHOyrqlr7eBv7ODG0CB2sdTbpNs4GOgzikerOLOn45uche1ODITQD0gNsPkXw1UswCdTLf3uEgdODCpgIb3qgIcQIgAjANyRAhTlmOKPJb0g8CkHdIAKHm0g4CWXahTerbvOLOn45uche1OnMugqQeTNdHGMm4GQdkATyGOpTy)zJg9SeB1yqboexa)z39SfG2j2Q2r7qJh4WrL3aszGAczmYquik0s0g8CkHdIA0gtkdivI2j2QXGcCiUa(ZUYZI(ZO7zx7zZHqqx4clbUMBjoQNDfbpJQNnA0ZePNzPeCtVktCLsfNwffObpNs48SR)m6EgUB5Pf76aPVbUQjtnbIZY5p7UNrv0q7eBv7ODme3eHuDqjhW1rDiqgZrgIIfGwI2GNtjCquJ2yszaPs0(ApZsj4MEvM4kLkoTkkqdEoLW5z09S5qiOlCHLaxZTeh1Ze8SO)m6E21E2Cie0tswUkqa4gOjqITNnA0ZOrGXQv8rtLgMTpBP9SR)SR)SrJE21E21EwITAmOahIlG)S7E2cE2OrptKEMLsWn9QmXvkvCAvuGg8CkHZZU(ZO7zx7z0iWy1k(OPshi9nWvnz(SrJE2kPh8JkBqhi9nWvnzQjqCwo)z39SO)SR)SRJ2j2Q2r7PS7JQdk7cOahIfczikez0s0g8CkHdIA0gtkdivI2ZHqqtgCq1bfTwmq0NwS)SrJEwITAmOahIlG)S7E2cq7eBv7OnTbsfeQ8v1uMCdzikIoAjAdEoLWbrnAJjLbKkr75qiOjdoO6GIwlgi6tl2F2OrplXwnguGdXfWF2DpBbODITQD0Mu0Ojbv5koTedidrXIJwI2GNtjCquJ2j2Q2rBC7yWnsAWrfKzmG2yszaPs0EoecAYGdQoOO1IbI(0ID0wwoOWh0EXrgIIfgTeTbpNs4GOgTXKYasLO9Cie0eahLe4CvOjyqpqdTtSvTJ22fqn4ZEWpQqtWaYquSiOLOn45uche1OnMugqQeTNdHGMm4GQdkATyGOpTy)zJg9SeB1yqboexa)z39SfG2j2Q2rBXnrEgdLRiaV90XaYqgAZlFvckUL(jjh0sefuHwI2GNtjCquJ2yszaPs02sj4MgMTpBPPbpNs48m6EgncmwTIpAQ0WS9zlTNr3ZU2ZePNzPeCtVktCLsfNwffObpNs48SrJE2Cie0fUWsGR5wIJ6zx5zI8Zgn6zZHqqpjz5QabGBGMaj2E21r7eBv7ODqoqicHmefIcTeTbpNs4GOgTXKYasLOTLsWn9QmXvkvCAvuGg8CkHZZO7z0iWy1k(OPsVktCLsfNwff8m6E2Cie0tswUkqa4gOjqIn0oXw1oAhKdeIqidrXcqlrBWZPeoiQrBmPmGujAtJaJvR4JMkDG0CB2s7z09S5qiONKSCvGaWnqtGeBpJUNDTNjspZsj4MEvM4kLkoTkkqdEoLW5zJg9S5qiOlCHLaxZTeh1ZUYZe5NDD0oXw1oAhKdeIqidrHiJwI2GNtjCquJ2j2Q2rBCkLQeBv7kzXn0wwCt5zmG2aNdog4idrr0rlr7eBv7ODG03ax1KjAdEoLWbrnYquS4OLOn45uche1OnMugqQeTtSvJbf4qCb8ND3Ze1Zgn6zj2QXGcCiUa(ZU7zu9m6Ego5MYQy4zcEw0EgDpBoec6q5RaHR6GkqAUPjqITNDLNjk0oXw1oApL1TBj5GmeflmAjAdEoLWbrnAJjLbKkr75qiOdLVceUQdQaP5MMaj2q7eBv7ODHbLmDmGmeflcAjANyRAhTXDmykU1Ky0g8CkHdIAKHOqeHwI2j2Q2rBy2(SLgAdEoLWbrnYquqv0qlrBWZPeoiQrBmPmGujAlsplXw1Uoq6BGRAYuxUkiR1l2ZO7zRKEWpQSbDG03ax1KPMaXz58Nj4zrdTtSvTJ2KuivhubsZnKHOGkQqlrBWZPeoiQrBmPmGujAJtUPSkgEMGNfTNnA0ZsSvJbf4qCb8ND3ZOcTtSvTJ2tzD7wsoidrbvIcTeTbpNs4GOgTXKYasLO9Cie0tswUkqa4gOjqITNnA0ZOrGXQv8rtLgMTpBP9SrJEwITAmOahIlG)S7EgvpJUNzPeCtZPjlZkFvvyqdEoLWbTtSvTJ2RYexPuXPvrbidzOnV8vjOAYeTerbvOLOn45uche1ODITQD0gNsPkXw1UswCdTLf3uEgdOnW5GJbUQjtKHOquOLODITQD0oq6BGRAYeTbpNs4GOgzikwaAjAdEoLWbrnAJjLbKkrBAeySAfF0uPHz7ZwApJUNnhcb9KKLRceaUbAcKydTtSvTJ2b5aHieYquiYOLOn45uche1OnMugqQeTtSvJbf4qCb8ND3Ze1Zgn6zj2QXGcCiUa(ZU7zu9m6Ego5MYQy4zcEw0q7eBv7O9uw3ULKdYqueD0s0g8CkHdIA0gtkdivI2ZHqqhkFfiCvhubsZnnbsS9m6EgUB5Pf76aPVbUQjtnbIZY5p7UNf9NnA0ZMdHGou(kq4QoOcKMBAcKy7zcEMOq7eBv7ODHbLmDmGmefloAjAdEoLWbrnAJjLbKkrBCYnLvXWZe8SOH2j2Q2r7PSUDljhKHOyHrlrBWZPeoiQrBmPmGujAtJaJvR4JMknmBF2sdTtSvTJ2b5aHieYquSiOLOn45uche1OnMugqQeTNdHGEsYYvbca3anbsS9m6E21EgncmwTIpAQ0bsZTzlTNnA0ZoWCie00sCuWrvyqtG4SC(ZU7zGiaWdgOSkgEg9plXw1UUWGsMog0gjhdsLvXWZUoANyRAhTdYbcriKHOqeHwI2j2Q2rBChdMIBnjgTbpNs4GOgzikOkAOLODITQD0gMTpBPH2GNtjCquJmefurfAjAdEoLWbrnANyRAhTjPqQoOcKMBOD5gqid0mvfq75qiOdLVceUQdQaP5MMaj2eik0UCdiKbAMQIJHtLgG2uH2yszaPs0(aZHqqtlXrbhvHb9anKHOGkrHwI2j2Q2r7PSUDljh0g8CkHdIAKHm02sj4MI00qlruqfAjAdEoLWbrnAJjLbKkrBlLGB6vzIRuQ40QOan45ucNNr3ZMdHGUWfwcCn3sCuptWZI(ZO7zx7zZHqqpjz5QabGBGMaj2E2OrpZsj4MgMTpBPPbpNs48m6EgUB5Pf7Ay2(SLMMaXz58NDLNHtUPSkgE21r7eBv7OnzWbvhu0AXabzikefAjAdEoLWbrnAJjLbKkrBr6zwkb30RYexPuXPvrbAWZPeopJUNDTNzPeCtdZ2NT00GNtjCEgDpd3T80IDnmBF2sttG4SC(ZUYZWj3uwfdpB0ONzPeCtJ7yWuCRjXAWZPeopJUNH7wEAXUg3XGP4wtI1eiolN)SR8mCYnLvXWZgn6zwkb30KuivhubsZnn45ucNNr3ZWDlpTyxtsHuDqfin30eiolN)SR8mCYnLvXWZgn6z4ljzf4QajXw1EkF2DpJkTi6zxhTtSvTJ2KbhuDqrRfdeKHm0g4CWXax1KjAjIcQqlrBWZPeoiQrBmPmGujAphcbnzWbvhu0AXarFAX(ZO7zhyoecAAjok4OkmOpTy)zJg9SeB1yqboexa)z39SfG2j2Q2r7qJh4WrL3aszGAczmYquik0s0g8CkHdIA0gtkdivI2j2QXGcCiUa(ZUYZI(ZO7zhyoecAAjok4OkmOpTy)z09mC3Ytl21bsFdCvtMAceNLZF2Dpl6pJUNjsplXw1Uoq6BGRAYuxUkiR1l2ZO7zRKEWpQSbDG03ax1KPMaXz58Nj4zrdTtSvTJ2XqCtes1bLCaxh1HazmhzikwaAjAdEoLWbrnAJjLbKkrBAeySAfF0uPdK(g4QMmF2OrpBL0d(rLnOdK(g4QMm1eiolN)S7Ew0r7eBv7O9u29r1bLDbuGdXcHmefImAjAdEoLWbrnAJjLbKkr75qiOjdoO6GIwlgi6tl2FgDp7aZHqqtlXrbhvHb9Pf7pB0ONLyRgdkWH4c4p7UNTa0oXw1oAtBGubHkFvnLj3qgIIOJwI2GNtjCquJ2yszaPs0EoecAYGdQoOO1IbI(0I9Nr3ZoWCie00sCuWrvyqFAX(Zgn6zj2QXGcCiUa(ZU7zlaTtSvTJ2KIgnjOkxXPLyazikwC0s0g8CkHdIA0oXw1oAJBhdUrsdoQGmJb0gtkdivI2ZHqqtgCq1bfTwmq0NwS)m6E2bMdHGMwIJcoQcd6tl2rBz5GcFq7fhzikwy0s0g8CkHdIA0gtkdivI2ZHqqtaCusGZvHMGb9an0oXw1oABxa1Gp7b)OcnbdidrXIGwI2GNtjCquJ2yszaPs0EoecAYGdQoOO1IbI(0I9Nr3ZoWCie00sCuWrvyqFAX(Zgn6zj2QXGcCiUa(ZU7zlaTtSvTJ2IBI8mgkxraE7PJbKHm0(aHCqAOLikOcTeTtSvTJ24EWnGWPbsjAdEoLWbrnYquik0s0g8CkHdIA0gtkdivI2I0ZiTLw1U2BvHbLmDm8m6EgncmwTIpAQ0b5aHi0ZO7zI0ZMdHGou(kq4QoOcKMBAcKydTtSvTJ2fguY0XaYquSa0s0g8CkHdIA0oXw1oAJtPuLyRAxjlUH2YIBkpJb0g3T80IDoYquiYOLOn45uche1OnMugqQeTtSvJbf4qCb8ND3ZwWZO7zwkb30bca3kFvrYY1GNtjCE2OrplXwnguGdXfWF2DptKr7eBv7OnoLsvITQDLS4gAllUP8mgq7SbKHOi6OLOn45uche1ODITQD0gNsPkXw1UswCdTLf3uEgdOnV8vjGmKH20iaUJNPHwIOGk0s0g8CkHdIAKHOquOLOn45uche1idrXcqlrBWZPeoiQrgIcrgTeTtSvTJ2jbNoOk3aPeWgAdEoLWbrnYqueD0s0oXw1oAlonGOajedULs0g8CkHdIAKHOyXrlrBWZPeoiQrgIIfgTeTbpNs4GOgT9mgq78g)sssUk0UP6GIwlgiODITQD0oVXVKKKRcTBQoOO1IbcYquSiOLODITQD0oUiKMOQ4CfqBWZPeoiQrgIcreAjANyRAhTP1w1oAdEoLWbrnYquqv0qlr7eBv7ODG0CB2sdTbpNs4GOgzidTZgqlruqfAjANyRAhTdK(g4QMmrBWZPeoiQrgIcrHwI2j2Q2r7PSUDljh0g8CkHdIAKHOybOLOn45uche1ODITQD0gNsPkXw1UswCdTLf3uEgdOnW5GJboYquiYOLODITQD0g3XGP4wtIrBWZPeoiQrgIIOJwI2j2Q2r7cdkVhNOn45uche1idrXIJwI2GNtjCquJ2yszaPs0MgbgRwXhnvAy2(SL2Zgn6zZHqqpjz5QabGBGMaj2EgDp7ApJgbgRwXhnv6aP52SL2ZO7zx7zZHqqx4clbUMBjoQNDLNjYpB0ONjspZsj4MEvM4kLkoTkkqdEoLW5zx)zJg9mAeySAfF0uPxLjUsPItRIcE21r7eBv7ODqoqicHmeflmAjAdEoLWbrnAJjLbKkr75qiOdLVceUQdQaP5MMaj2q7eBv7ODHbLmDmGmeflcAjANyRAhTjPqQoOcKMBOn45uche1idrHicTeTtSvTJ2WS9zln0g8CkHdIAKHOGQOHwI2j2Q2r7vzIRuQ40QOa0g8CkHdIAKHOGkQqlr7eBv7OnUDq1bfULh0g8CkHdIAKHOGkrHwI2GNtjCquJ2j2Q2rBRoa3AsSc3hqeG2yszaPs0Eoec6clKAmuoxFAX(ZO7zZHqqtgCq1bfTwmq0NwSJ2EgdOTvhGBnjwH7dicqgIcQwaAjAdEoLWbrnANyRAhTP14OaJx3GJc3X0gS0Q2vhyCHb0gtkdivI2ZHqqxyHuJHY56tl2FgDpBoecAYGdQoOO1IbI(0ID0gcbaBkpJb0glew2gP9cRMYKBidrbvImAjANyRAhTdKMBZwAOn45uche1idrbvrhTeTbpNs4GOgTtSvTJ24ukvj2Q2vYIBOTS4MYZyaTJ7Xqm4gYquq1IJwI2j2Q2r7cdkz6yaTbpNs4GOgzidTXDlpTyNJwIOGk0s0oXw1oAVoKKtLUQdQ8gqA7cAdEoLWbrnYquik0s0oXw1oAxyHuJHY5On45uche1idrXcqlr7eBv7ODCrinrvX5kG2GNtjCquJmefImAjAdEoLWbrnAJjLbKkrBAeySAfF0uPdK(g4QMmF2OrpZQyqzT6uWZU7zufTNr)ZWj3uwfdpJUNzvmOSwDk4zx5zIkAODITQD0Mm4GQdkATyGGmefrhTeTbpNs4GOgTXKYasLOTLsWnnzWbvhu0AXardEoLW5z09SeB1yqboexa)zcEgvpJUNH7wEAXUMm4GQdkATyGOddsPIa4ljzfuwfdp7kpd3T80IDDG03ax1KPMaXz5C0oXw1oAJtPuLyRAxjlUH2YIBkpJb02sj4MI00qgIIfhTeTbpNs4GOgTXKYasLOnncmwTIpAQ0fwi1yOC(Zgn6zwfdkRvNcE2vE2cIgANyRAhTP1w1oYquSWOLODITQD0EGdQYGyoAdEoLWbrnYquSiOLODITQD0Ek7(OcdeHqBWZPeoiQrgIcreAjANyRAhTNaHdKOkFfTbpNs4GOgzikOkAOLODITQD0wwRxmUAXE4SgdUH2GNtjCquJmefurfAjANyRAhTdfbMYUpOn45uche1idrbvIcTeTtSvTJ2PJbUrsPcNsjAdEoLWbrnYqgAZlFvckVvY0XaAjIcQqlrBWZPeoiQrBmPmGujABPeCtdZ2NT00GNtjCEgDpJgbgRwXhnvAy2(SL2ZO7zZHqqpjz5QabGBGMaj2q7eBv7ODqoqicHmefIcTeTbpNs4GOgTXKYasLOnncmwTIpAQ0RYexPuXPvrbpJUNnhcb9KKLRceaUbAcKydTtSvTJ2b5aHieYquSa0s0g8CkHdIA0oXw1oAJtPuLyRAxjlUH2YIBkpJb0g4CWXahzikez0s0oXw1oAhi9nWvnzI2GNtjCquJmefrhTeTbpNs4GOgTXKYasLODITAmOahIlG)S7EMOE2OrplXwnguGdXfWF2DpJQNr3ZePNzPeCtZPjlZkFvvyqdEoLWbTtSvTJ2tzD7wsoidrXIJwI2j2Q2rBChdMIBnjgTbpNs4GOgzikwy0s0g8CkHdIA0gtkdivI2ZHqqx4clbUMBjoQNj4zr)z09mr6zZHqqpjz5QabGBGMaj2q7eBv7OnmBF2sdzikwe0s0g8CkHdIA0gtkdivI2ZHqqpjz5QabGBGMaj2E2OrpJgbgRwXhnvAy2(SL2Zgn6zwkb30LJt3acxfKTyn45ucNNr3ZWj3uwfdpJ(NzKCmivwfdp7UNvooDdiCvq2IvwfdkR1rxpq7z09mCYnLvXWZO)zgjhdsLvXWZUYZkhNUbeUkiBXkRIbL1ArwFAXoANyRAhTxLjUsPItRIcqgYq74EmedUHwIOGk0s0g8CkHdIA0gtkdivI2X9yigCtFkULogE2DpJQOH2j2Q2r7PS8OuPleYquik0s0g8CkHdIA0gtkdivI2ZHqqxyqfKnW1NwSJ2j2Q2r7cdQGSboYqgYq7XaHxTJOqurJkru0wyrjk0wCs8Yx5OTi2c5(Pq0qXILO)zpB5f4zvmTMypl0KNTOX9yigCBrFgbeXBOiW5z8ogEwoyDCAW5z4lPVcC9hr0PC4zuj6FMORZhOrRjgCEwITQ9NTOtz5rPsxOfv)r(iIMyAnXGZZOsuplXw1(ZKf346pcAZPbyeflUiJ20iDOKaAF1NDpsZTNDFYv4JC1NDXmACrpLuUw2LHPg3XuYR4bzAv7ysgmk5vmMYpYvFwKbPqptulIWpturJkr0ZwmpJQOj6xWI8r(ix9zl0lPVcCr)h5QpBX8mrxo8Sf1QyqzT6uWI(SY5gKNN1HNTOwswbtBvmOSwDkyrFwOjptMC7zCa3(5zlurCpBGNRG(JC1NTyE29biRWZUhP52ZUp5k8SfIiu0H)SRntoCEw7pBfCGKwt4pR8NXXQ4Cf0yA0U(h5JC1NjAfbaEWGZZMqOjWZWD8mTNnH1Y56NTqWyGMXFM3(I5ssIddYNLyRAN)S2LcP)ij2Q25AAea3XZ0eeKjpQpsITQDUMgbWD8mn6fqzO7ZhjXw1oxtJa4oEMg9cOmhwJb3sRA)JKyRANRPraChptJEbuMeC6GQCdKsaBFKeBv7CnncG74zA0lGs(qCC7kXPbefiHyWTu(rsSvTZ10iaUJNPrVak5EsJFPnf3sJ)rsSvTZ10iaUJNPrVakh4GQmiwypJbb5n(LKKCvODt1bfTwmq(ij2Q25AAea3XZ0OxaLXfH0evfNRWhjXw1oxtJa4oEMg9cOKwBv7FKeBv7CnncG74zA0lGYaP52SL2h5JC1NjAfbaEWGZZGXarONzvm8m7c8SeBn5zf)z54SK5uc6psITQDUaCp4gq40aP8JC1NjAcpZUaploxHNDj5p7E99EwgmG8mCYTYxFw5ClD7z3toqicj8ZedpdN(ZoGmf6z2f4zIgm8mrN0XWZs)8Sbo8S2UaKNDPwV8mAKQjLj0ZsSvTl8ZQWZYXzjZPe0FKeBv7C6fqzHbLmDmiCfeisK2sRAx7TQWGsMogOJgbgRwXhnv6GCGqeIorAoec6q5RaHR6GkqAUPjqITpsITQDo9cOeNsPkXw1UswCtypJbb4ULNwSZ)ix9zlVapZsYkypZUqa(LwEEwX9f1EgicsSPFg1Gjga)zlyXe9NzjzfmUWpZUap7uHaqahd8Nnbtma(ZSlWZ2lFw6NNTqAr7ZsSvT)mzXn(Zsc8msAxaYZ4XPuQFMi(Tyymqe(z3JaWTYxF29NL)mAeiae(Zg4LV(SfslAFwITQ9NjlU9mE3oqEwYFwzpBcoekJ)SvcKMuONfiD8ZSlWZUuRxEgns1KYe6zulRB3sY5zj2Q21FKeBv7C6fqjoLsvITQDLS4MWEgdcYgeUccsSvJbf4qCb87waDwkb30bca3kFvrYY1GNtjCgnkXwnguGdXfWVtK)ij2Q250lGsCkLQeBv7kzXnH9mgeWlFvcFKpYvFMiwzxE29iaCR81ND)z5c)SYwu(ZMGza5zw)mAKQjLv3GNnWlF9z3J03a)z3xY8zIVa(ZMTD5z37((S0ppJAzD7wsopljWZ6q4z4ULNwSRFMiwzx6b7z3JaWTYxF29NLl8ZSlWZWTpgiC4zf)zgzaEwkTl9W6LNzxGNDQqaiGJHNv8NfxEXXds4zdUvYNngic9Sl16LNzjzfSNH7b346psITQDUoBqqG03ax1K5hjXw1oxNnqVakNY62TKC(ij2Q256Sb6fqjoLsvITQDLS4MWEgdcaohCmW)ij2Q256Sb6fqjUJbtXTMe)rsSvTZ1zd0lGYcdkVhNFKR(SDfttwHcop7EYbcrONHB)uw1o)zbsh)m7c8S9YNLyRA)zYIB6NTlhdpZUaploxHNv8NTcoqsR81NfsYZKaN)mQjz5p7EeaUbpdFjjRax4NzxGNbIGeBpd3(PSQ9NDbiWZkUVO2ZsP8z2L0EwftRjw6M(JKyRANRZgOxaLb5aHiKWvqancmwTIpAQ0WS9zlTrJMdHGEsYYvbca3anbsSr31OrGXQv8rtLoqAUnBPr31MdHGUWfwcCn3sCuxrKhnsKSucUPxLjUsPItRIc0GNtjCU(Or0iWy1k(OPsVktCLsfNwffC9psITQDUoBGEbuwyqjthdcxbbZHqqhkFfiCvhubsZnnbsS9rU6ZwEbEwCUcptCjLpBfCGKsPqpBcpBfCGKw5RplFMSTN1HNDV(EpdFjjRa)zIVa(Zg4LV(m7c8SfslAFwITQ9NjlUPF2sIqLV(mRF2bKPqp7(tHEwhE29in3E2GBL8z2fGapljWZ8(z3RV3ZWxsYkWFw6NN59ZsSvJHNDpsFd8NDFjt(Ze3dYZZKqEEM1pRSN5T9Sju(6Zg4W5zP9Suk1FKeBv7CD2a9cOKKcP6GkqAU9rsSvTZ1zd0lGsy2(SL2hjXw1oxNnqVakxLjUsPItRIc(ix9zIU8YxF2cTD4zD4zl0wEEwXFwCZnPqpteNiC)mhgmskFM4YU8m7c8SfslAFMLKvWEMDHa8lT8W1pt0ypRDPqpBc4og4p7ayWTNTML)mXLD5zKEy9IuONTWpRjplUjWZSKScgx)rsSvTZ1zd0lGsC7GQdkClpFKeBv7CD2a9cOCGdQYGyH9mgey1b4wtIv4(aIaHRGG5qiOlSqQXq5C9Pf70nhcbnzWbvhu0AXarFAX(hjXw1oxNnqVakh4GQmiwyieaSP8mgeGfclBJ0EHvtzYnHRGG5qiOlSqQXq5C9Pf70nhcbnzWbvhu0AXarFAX(hjXw1oxNnqVakdKMBZwAFKeBv7CD2a9cOeNsPkXw1UswCtypJbbX9yigC7JKyRANRZgOxaLfguY0XWh5JKyRANRXDlpTyNlyDijNkDvhu5nG02LpsITQDUg3T80IDo9cOSWcPgdLZ)ij2Q25AC3Ytl250lGY4IqAIQIZv4JC1ND)do8So8mrylgipR4plLItH4pBGdNNjUSlp7EK(g4p7(sM6NTqCHEMecwpgipdFjjRa)zP9m7c8mWppRdpZUapluRxSNXV0dYZZMWZg4Wr4NvhiLsHEwfEMDbE2S58NDAG7lQ9StbpR8NzxGNfxNJeEwhEMDbE29p4WZMdHG(JKyRANRXDlpTyNtVakjdoO6GIwlgicxbb0iWy1k(OPshi9nWvnzoAKvXGYA1PG7OkA0JtUPSkgOZQyqzT6uWvev0(ix9z3x)z8YxLWZSKSc2Zc16fJl8ZSlWZWDlpTy)zD4z3)GdpRdpte2IbYZk(ZKTyG8m7s6pZUapd3T80I9N1HNDpsFd8NDFjtHFMDP4pBTgd8NbIaJKp7(hC4zD4zIWwmqEg(sswb(ZSlP9m(LEqEE2eE2ahoptCzxEwITAm8mlLGBCHFwfEgTMZRPe0FKeBv7CnUB5Pf7C6fqjoLsvITQDLS4MWEgdcSucUPinnHRGalLGBAYGdQoOO1IbIg8CkHdDj2QXGcCiUaUaQOd3T80IDnzWbvhu0AXarhgKsfbWxsYkOSkgUcUB5Pf76aPVbUQjtnbIZY5FKeBv7CnUB5Pf7C6fqjT2Q2fUccOrGXQv8rtLUWcPgdLZhnYQyqzT6uWvwq0(ij2Q25AC3Ytl250lGYboOkdI5FKeBv7CnUB5Pf7C6fq5u29rfgic9rsSvTZ14ULNwSZPxaLtGWbsuLV(rsSvTZ14ULNwSZPxaLYA9IXvl2dN1yWTpsITQDUg3T80IDo9cOmueyk7(8rsSvTZ14ULNwSZPxaLPJbUrsPcNs5h5JC1NjA5CWXa)z0ivtktONfAYZiTLw1UMBPFsY5zPFEgPT0Q21ERkmOKPJb9hjXw1oxdCo4yGli04boCu5nGugOMqglCfemhcbnzWbvhu0AXarFAX(Orj2QXGcCiUa(Dl4JKyRANRbohCmWPxaLXqCtes1bLCaxh1Hazmx4kiiXwnguGdXfWVs0P7AZHqqx4clbUMBjoQRiGQrJejlLGB6vzIRuQ40QOan45ucNRthUB5Pf76aPVbUQjtnbIZY53rv0(ij2Q25AGZbhdC6fq5u29r1bLDbuGdXcjCfeCnlLGB6vzIRuQ40QOan45uch6MdHGUWfwcCn3sCucIoDxBoec6jjlxfiaCd0eiX2Or0iWy1k(OPsdZ2NT0U(1hn6AxlXwnguGdXfWVBbJgjswkb30RYexPuXPvrbAWZPeoxNURrJaJvR4JMkDG03ax1K5OrRKEWpQSbDG03ax1KPMaXz587I(1V(hjXw1oxdCo4yGtVakPnqQGqLVQMYKBcxbbZHqqtgCq1bfTwmq0NwSpAuITAmOahIlGF3c(ij2Q25AGZbhdC6fqjPOrtcQYvCAjgeUccMdHGMm4GQdkATyGOpTyF0OeB1yqboexa)Uf8rsSvTZ1aNdog40lGsC7yWnsAWrfKzmiSSCqHpcwCHRGG5qiOjdoO6GIwlgi6tl2)ij2Q25AGZbhdC6fqPDbud(Sh8Jk0emiCfemhcbnbWrjboxfAcg0d0(ij2Q25AGZbhdC6fqP4MipJHYveG3E6yq4kiyoecAYGdQoOO1IbI(0I9rJsSvJbf4qCb87wWh5JC1NjA5CWXa)z0ivtktONfAYZiTLw1Uoq6BGRAY8JKyRANRbohCmWvnzki04boCu5nGugOMqglCfemhcbnzWbvhu0AXarFAXoDhyoecAAjok4OkmOpTyF0OeB1yqboexa)Uf8rsSvTZ1aNdog4QMmPxaLXqCtes1bLCaxh1Hazmx4kiiXwnguGdXfWVs0P7aZHqqtlXrbhvHb9Pf70H7wEAXUoq6BGRAYutG4SC(DrNorkXw1Uoq6BGRAYuxUkiR1lgDRKEWpQSbDG03ax1KPMaXz5Cbr7JKyRANRbohCmWvnzsVakNYUpQoOSlGcCiwiHRGaAeySAfF0uPdK(g4QMmhnAL0d(rLnOdK(g4QMm1eiolNFx0)ij2Q25AGZbhdCvtM0lGsAdKkiu5RQPm5MWvqWCie0KbhuDqrRfde9Pf70DG5qiOPL4OGJQWG(0I9rJsSvJbf4qCb87wWhjXw1oxdCo4yGRAYKEbuskA0KGQCfNwIbHRGG5qiOjdoO6GIwlgi6tl2P7aZHqqtlXrbhvHb9Pf7JgLyRgdkWH4c43TGpsITQDUg4CWXax1Kj9cOe3ogCJKgCubzgdcllhu4JGfx4kiyoecAYGdQoOO1IbI(0ID6oWCie00sCuWrvyqFAX(hjXw1oxdCo4yGRAYKEbuAxa1Gp7b)OcnbdcxbbZHqqtaCusGZvHMGb9aTpsITQDUg4CWXax1Kj9cOuCtKNXq5kcWBpDmiCfemhcbnzWbvhu0AXarFAXoDhyoecAAjok4OkmOpTyF0OeB1yqboexa)Uf8r(ij2Q2564EmedUjyklpkv6cjCfee3JHyWn9P4w6y4oQI2hjXw1oxh3JHyWn6fqzHbvq2ax4kiyoec6cdQGSbU(0I9pYh5QpBx(QeE2YKSc2ZeHKQjLj0Zcn5zK2sRAxZT0pj58SMMvTR)ij2Q25AE5RsqXT0pj5qVakdYbcriHRGalLGBAy2(SLMg8CkHdD0iWy1k(OPsdZ2NT0O7AIKLsWn9QmXvkvCAvuGg8CkHZOrZHqqx4clbUMBjoQRiYJgnhcb9KKLRceaUbAcKy76FKeBv7CnV8vjO4w6NKCOxaLb5aHiKWvqGLsWn9QmXvkvCAvuGg8CkHdD0iWy1k(OPsVktCLsfNwffq3Cie0tswUkqa4gOjqITpsITQDUMx(QeuCl9tso0lGYGCGqes4kiGgbgRwXhnv6aP52SLgDZHqqpjz5QabGBGMaj2O7AIKLsWn9QmXvkvCAvuGg8CkHZOrZHqqx4clbUMBjoQRiYx)JKyRANR5LVkbf3s)KKd9cOeNsPkXw1UswCtypJbbaNdog4FKeBv7CnV8vjO4w6NKCOxaLbsFdCvtMFKeBv7CnV8vjO4w6NKCOxaLtzD7wsocxbbj2QXGcCiUa(DIA0OeB1yqboexa)oQOdNCtzvmiiA0nhcbDO8vGWvDqfin30eiX2ve1hjXw1oxZlFvckUL(jjh6fqzHbLmDmiCfemhcbDO8vGWvDqfin30eiX2hjXw1oxZlFvckUL(jjh6fqjUJbtXTMe)rsSvTZ18YxLGIBPFsYHEbucZ2NT0(ij2Q25AE5RsqXT0pj5qVakjPqQoOcKMBcxbbIuITQDDG03ax1KPUCvqwRxm6wj9GFuzd6aPVbUQjtnbIZY5cI2hjXw1oxZlFvckUL(jjh6fq5uw3ULKJWvqao5MYQyqq0gnkXwnguGdXfWVJQpsITQDUMx(QeuCl9tso0lGYvzIRuQ40QOaHRGG5qiONKSCvGaWnqtGeBJgrJaJvR4JMknmBF2sB0OeB1yqboexa)oQOZsj4MMttwMv(QQWGg8CkHZh5JC1NTlFvcpBzswb7zIqs1KYe6zHM8m7c8msBPvTR9wvyqjthdpRPzv76psITQDUMx(QeuERKPJb6fqzqoqicjCfeyPeCtdZ2NT00GNtjCOJgbgRwXhnvAy2(SLgDZHqqpjz5QabGBGMaj2(ij2Q25AE5Rsq5TsMogOxaLb5aHiKWvqancmwTIpAQ0RYexPuXPvrb0nhcb9KKLRceaUbAcKy7JKyRANR5LVkbL3kz6yGEbuItPuLyRAxjlUjSNXGaGZbhd8psITQDUMx(QeuERKPJb6fqzG03ax1K5hjXw1oxZlFvckVvY0Xa9cOCkRB3sYr4kiiXwnguGdXfWVtuJgLyRgdkWH4c43rfDIKLsWnnNMSmR8vvHbn45ucNpsITQDUMx(QeuERKPJb6fqjUJbtXTMe)rsSvTZ18YxLGYBLmDmqVakHz7ZwAcxbbZHqqx4clbUMBjokbrNorAoec6jjlxfiaCd0eiX2hjXw1oxZlFvckVvY0Xa9cOCvM4kLkoTkkq4kiyoec6jjlxfiaCd0eiX2Or0iWy1k(OPsdZ2NT0gnYsj4MUCC6gq4QGSfRbpNs4qho5MYQyGEJKJbPYQy4UYXPBaHRcYwSYQyqzTo66bA0HtUPSkgO3i5yqQSkgUs540nGWvbzlwzvmOSwlY6tl2)iFKR(SD5Rs4zltYkyptesQMuMqpl0KNzxGNrAlTQDDG03ax1K5ZAAw1U(JKyRANR5LVkbvtM0lGsCkLQeBv7kzXnH9mgeaCo4yGRAY8JKyRANR5LVkbvtM0lGYaPVbUQjZpsITQDUMx(QeunzsVakdYbcriHRGaAeySAfF0uPHz7ZwA0nhcb9KKLRceaUbAcKy7JKyRANR5LVkbvtM0lGYPSUDljhHRGGeB1yqboexa)ornAuITAmOahIlGFhv0HtUPSkgeeTpsITQDUMx(QeunzsVaklmOKPJbHRGG5qiOdLVceUQdQaP5MMaj2Od3T80IDDG03ax1KPMaXz587I(OrZHqqhkFfiCvhubsZnnbsSjquFKeBv7CnV8vjOAYKEbuoL1TBj5iCfeGtUPSkgeeTpsITQDUMx(QeunzsVakdYbcriHRGaAeySAfF0uPHz7ZwAFKeBv7CnV8vjOAYKEbugKdeIqcxbbZHqqpjz5QabGBGMaj2O7A0iWy1k(OPshin3MT0gn6aZHqqtlXrbhvHbnbIZY53bIaapyGYQyG(eBv76cdkz6yqBKCmivwfdx)JKyRANR5LVkbvtM0lGsChdMIBnj(JKyRANR5LVkbvtM0lGsy2(SL2hjXw1oxZlFvcQMmPxaLKuivhubsZnHRGGdmhcbnTehfCufg0d0eUCdiKbAMQccMdHGou(kq4QoOcKMBAcKytGOeUCdiKbAMQIJHtLgiGQpsITQDUMx(QeunzsVakNY62TKC(iFKR(mrJ)mEhdpJx2qAv7CHFMq9WZWP)m(L0mG8mrdgEgf948zWyWFwgmG8SusG8i0ZWj3kF9z3toqic9S0ppt0GHNj6Kog0p7(AxaI4IdpZUu8NLyRA)zf)zdC48mXxa)z2f4zX5k8Slj)z3RV3ZYGbKNHtUv(6ZUNCGqes4NXb4z5Shd6psITQDUMx(Qeeuyq594u4kia3T80IDDHbL3JtnbYJq0DG5qiOfxUbeUcFPKs9aTpsITQDUMx(QeOxaL4ukvj2Q2vYIBc7zmiGx(QeuCl9tsocxbbK2sRAxZT0pj58rsSvTZ18YxLa9cOeNsPkXw1UswCtypJbb8YxLGYBLmDmiCfeqAlTQDT3Qcdkz6y4JKyRANR5LVkb6fqjoLsvITQDLS4MWEgdc4LVkbvtMcxbbK2sRAxhi9nWvnz(rsSvTZ18YxLa9cOSWGY7X5hjXw1oxZlFvc0lGYboOkdIf2ZyqGvhGBnjwH7diceUccMdHGUWcPgdLZ1NwSt3Cie0KbhuDqrRfde9Pf7FKeBv7CnV8vjqVakh4GQmiwyieaSP8mgeGfclBJ0EHvtzYnHRGG5qiOlSqQXq5C9Pf70nhcbnzWbvhu0AXarFAX(hjXw1oxZlFvc0lGYaP52SL2hjXw1oxZlFvc0lGsCkLQeBv7kzXnH9mgee3JHyWTpsITQDUMx(QeOxaLfguY0XWh5JC1NjIv2LNTyjtCLYNTPvrbc)S7FWHN1HNjcBXa5z8l9G88Sj8SboCEgPwVypBcHMapZUapBXsM4kLpBtRIcEgUJN9ZUwPb9Zex2LNf9NjAWfwc8NL(5z5ZOMKL)S7ra4gCD9ZeXUa(ZeTZ2NT0EwXFwhcpd3T80IDHF29p4WZ6WZeHTyG8mC6plL8(zt4zdC48Sf7bU9mXLD5zr)zIgCHLax)rsSvTZ1wkb3uKMMaYGdQoOO1IbIWvqGLsWn9QmXvkvCAvuGg8CkHdDZHqqx4clbUMBjokbrNURnhcb9KKLRceaUbAcKyB0ilLGBAy2(SLMg8CkHdD4ULNwSRHz7ZwAAceNLZVco5MYQy46FKR(mrSYU0d2ZwSKjUs5Z20QOaHF29p4WZ6WZeHTyG8m(LEqEE2eE2ahopBcHMaplDHE2SwxbYZWDlpTy)zxt0oBF2st4NTq7yWE22AsSWp7(tHEwhE29in3U(ZAYZeFb8ND)do8So8mrylgipR4plN9G9mRFgbs8LNjQNHVKKvGR)ij2Q25AlLGBkstJEbusgCq1bfTwmqeUccejlLGB6vzIRuQ40QOan45uch6UMLsWnnmBF2stdEoLWHoC3Ytl21WS9zlnnbIZY5xbNCtzvmmAKLsWnnUJbtXTMeRbpNs4qhUB5Pf7AChdMIBnjwtG4SC(vWj3uwfdJgzPeCttsHuDqfin30GNtjCOd3T80IDnjfs1bvG0CttG4SC(vWj3uwfdJgHVKKvGRcKeBv7P8oQ0IORJmKHqa]] )


end
