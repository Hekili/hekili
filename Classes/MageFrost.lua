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

    
    spec:RegisterPack( "Frost Mage", 20200124, [[dOusvbqicfEKcQ2esYNiuuJsjPoLssEfsQzrqUfHQWUOYVuPAyeQCmc0Yiu6zkOmncqxtjHTPsr(MsI04iuLohHISoLeH5PsH7Hu2NkLoOsIQfIu5HkjktuLIsxKqvzJeaFujrKrQKiQtsOQALkWmvPO4MQuuTtKQ(jbegkbuwkbKEQsnvLuxLaI8vcvr7fYFjzWOCyHfROhd1KvXLbBMuFwjgTkXPLSAciQxRGmBIUnvz3u(TudhjwoINJQPl66uvBxH67eY4jGQZtqTEvsZxHSFvnsq0A0(ejGOxSItSItCckwb0joXKaoSviEr7uykaAtjWdflaABHhG2caP55ZU5XcG2ucHLDCqRrBE7tWaAFjtk8vI73xQ8I)0HBV78YZxgz1gMe68oV8W3r7PFjtXVHMO9jsarVyfNyfN4euScOtCIjbCyRqSOD4NxAcAVlVvgAFPohWqt0(aCmAp8NjaKMNp7MhlWpy4p7sMu4Re3VVu5f)Pd3E35LNVmYQnmj05DE5HV)dg(ZgeMFqe(zIvqHEMyfNyf3p4hm8NTYUe2cWxj(bd)zIhptGehEMyolpqLT6uGy(zLXtiopR1ptmNbzbsxwEGkB1PaX8Z0n5zYGNpJd42opBLDZ(mFESaUFWWFM4XZU5azbEMaqAE(SBESapBLlWUz4pB1ZGdNN12Zwadir2e(Zk7zCSYlwahMcLvH2YINC0A0Mx2IeqRr0liAnAdwmLWbrhAJjvcKkqBC3YtlYCfguwpoCeioc)mQE2bM(ATtuzjq4k8LskD(uq7aNvBODHbL1JduIOxSO1OnyXucheDOnMujqQaTjDgz1MJNHDcYbTdCwTH24qkvboR2uYINOTS4PYcpaT5LTibfpd7eKdkr0pm0A0gSykHdIo0gtQeivG2KoJSAZzTQWGsgggq7aNvBOnoKsvGZQnLS4jAllEQSWdqBEzlsqzTsgggqjIEbeTgTblMs4GOdTXKkbsfOnPZiR2CAsFfmvtMODGZQn0ghsPkWz1Msw8eTLfpvw4bOnVSfjOAYeLi6xbAnAh4SAdTlmOSECG2GftjCq0Hse93eAnAdwmLWbrhAh4SAdTZ6a8SjEkCFaboAJjvcKkq7PVw7kSWQXqzC3PfzpJQNn91AhX3avRvuAraXDArgABHhG2zDaE2epfUpGahLi6xPO1OnyXucheDODGZQn0glmw2jPTcRMYGNOnMujqQaTN(ATRWcRgdLXDNwK9mQE20xRDeFduTwrPfbe3PfzOnO1aovw4bOnwySStsBfwnLbprjIEXlAnAh4SAdT1KMNZwMOnyXucheDOerVycTgTblMs4GOdTXKkbsfOTxpUSf0oWz1gAJdPuf4SAtjlEI2YINkl8a02RhdEGLOerVGIdTgTdCwTH2fguYWWaAdwmLWbrhkrjAdCoyyGJwJOxq0A0gSykHdIo0gtQeivG2tFT2r8nq1AfLweqCNwK9SrJEwGZAmOad8kG)SBF2Wq7aNvBOTUX(C4OIRaPsqnHWdLi6flAnAdwmLWbrhAJjvcKkq7aN1yqbg4va)z34zR4zu9Sv)SPVw7kCHLa3XZap0ZUbTNj4Zgn6zIXZYqcw6wKbUcPItPgcCGftjCE2QEgvpd3T80ImNM0xbt1KPJaErz8ND7ZeuCODGZQn02d8AIWQwRK(46Ooei84Oer)WqRrBWIPeoi6qBmPsGubAV6NLHeS0TidCfsfNsne4alMs48mQE20xRDfUWsG74zGh6z0E2kEgvpB1pB6R1UjjktPjaCfCeiW5Zgn6zuiWy1c(4e0bZ2MTmF2QE2QE2OrpB1pB1plWznguGbEfWF2TpBypB0ONjgpldjyPBrg4kKkoLAiWbwmLW5zR6zu9Sv)mkeySAbFCc60K(kyQMmF2OrpBH0(2rfn40K(kyQMmDeWlkJ)SBF2kE2QE2Qq7aNvBO9u29r1AvEbuGbEcJse9ciAnAdwmLWbrhAJjvcKkq7PVw7i(gOATIslciUtlYE2OrplWznguGbEfWF2TpByODGZQn0MIpP0cx2IAkdEIse9RaTgTblMs4GOdTXKkbsfO90xRDeFduTwrPfbe3PfzpB0ONf4SgdkWaVc4p72Nnm0oWz1gAtkkuKGQmfNsGbuIO)MqRrBWIPeoi6q7aNvBOnUnmyjjs4O0YWdqBmPsGubAp91AhX3avRvuAraXDArgAlldu4dAFtOer)kfTgTblMs4GOdTXKkbsfO90xRDeFduTwrPfbe3PfzODGZQn0MabLYwuAz4bCuIOx8IwJ2GftjCq0H2ysLaPc0E6R1ocGhscCUs3em48PG2boR2q78cO8Tz7BhLUjyaLi6ftO1OnyXucheDOnMujqQaTN(ATJ4BGQ1kkTiG4oTi7zJg9SaN1yqbg4va)z3(SHH2boR2qBrnrEgdLPiaVTWWakrjAZlBrckEg2jih0Ae9cIwJ2GftjCq0H2ysLaPc0odjyPdMTnBz6alMs48mQEgfcmwTGpobDWSTzlZNr1Zw9ZeJNLHeS0TidCfsfNsne4alMs48SrJE20xRDfUWsG74zGh6z34zc4Zgn6ztFT2njrzknbGRGJaboF2Qq7aNvBOTw6ticJse9IfTgTblMs4GOdTXKkbsfODgsWs3ImWvivCk1qGdSykHZZO6zuiWy1c(4e0TidCfsfNsne8mQE20xRDtsuMsta4k4iqGt0oWz1gARL(eIWOer)WqRrBWIPeoi6qBmPsGubAtHaJvl4JtqNM08C2Y8zu9SPVw7MKOmLMaWvWrGaNpJQNT6NjgpldjyPBrg4kKkoLAiWbwmLW5zJg9SPVw7kCHLa3XZap0ZUXZeWNTk0oWz1gARL(eIWOerVaIwJ2GftjCq0H2boR2qBCiLQaNvBkzXt0ww8uzHhG2aNdgg4Oer)kqRr7aNvBOTM0xbt1KjAdwmLWbrhkr0FtO1OnyXucheDOnMujqQaTdCwJbfyGxb8ND7Ze7Zgn6zboRXGcmWRa(ZU9zc(mQEgo4Pklp4z0EM4EgvpB6R1oDzlaHRATstAE6iqGZNDJNjw0oWz1gApL11Rb5Gse9Ru0A0gSykHdIo0gtQeivG2tFT2PlBbiCvRvAsZthbcCI2boR2q7cdkzyyaLi6fVO1ODGZQn0g3EqQ4zt8qBWIPeoi6qjIEXeAnAh4SAdTHzBZwMOnyXucheDOerVGIdTgTblMs4GOdTXKkbsfOTy8SaNvBonPVcMQjtxzkTSwUKpJQNTqAF7OIgCAsFfmvtMoc4fLXFgTNjo0oWz1gAtcHvTwPjnprjIEbfeTgTblMs4GOdTXKkbsfOno4Pklp4z0EM4E2OrplWznguGbEfWF2Tptq0oWz1gApL11Rb5Gse9ckw0A0gSykHdIo0gtQeivG2tFT2njrzknbGRGJaboF2OrpJcbgRwWhNGoy22SL5Zgn6zboRXGcmWRa(ZU9zc(mQEwgsWshNISYSSfvHbhyXuch0oWz1gAVidCfsfNsneGsuI28YwKGQjt0Ae9cIwJ2GftjCq0H2boR2qBCiLQaNvBkzXt0ww8uzHhG2aNdgg4QMmrjIEXIwJ2boR2qBnPVcMQjt0gSykHdIouIOFyO1OnyXucheDOnMujqQaTPqGXQf8XjOdMTnBz(mQE20xRDtsuMsta4k4iqGt0oWz1gARL(eIWOerVaIwJ2GftjCq0H2ysLaPc0oWznguGbEfWF2TptSpB0ONf4SgdkWaVc4p72Nj4ZO6z4GNQS8GNr7zIdTdCwTH2tzD9AqoOer)kqRrBWIPeoi6qBmPsGubAp91ANUSfGWvTwPjnpDeiW5ZO6z4ULNwK50K(kyQMmDeWlkJ)SBF2kE2OrpB6R1oDzlaHRATstAE6iqGZNr7zIfTdCwTH2fguYWWakr0FtO1OnyXucheDOnMujqQaTXbpvz5bpJ2ZehAh4SAdTNY661GCqjI(vkAnAdwmLWbrhAJjvcKkqBkeySAbFCc6GzBZwMODGZQn0wl9jeHrjIEXlAnAdwmLWbrhAJjvcKkq7PVw7MKOmLMaWvWrGaNpJQNT6NrHaJvl4JtqNM08C2Y8zJg9Sdm91AhLapeCufgCeWlkJ)SBFgiWbSFcQS8GNr9ZcCwT5kmOKHHbxsIXGuLLh8SvH2boR2qBT0NqegLi6ftO1ODGZQn0g3EqQ4zt8qBWIPeoi6qjIEbfhAnAh4SAdTHzBZwMOnyXucheDOerVGcIwJ2GftjCq0H2boR2qBsiSQ1knP5jAxwceIpLuvA0E6R1oDzlaHRATstAE6iqGtAIfTllbcXNsQkpp4urcOTGOnMujqQaTpW0xRDuc8qWrvyW5tbLi6fuSO1ODGZQn0EkRRxdYbTblMs4GOdLOeT5LTibL1kzyyaTgrVGO1OnyXucheDOnMujqQaTZqcw6GzBZwMoWIPeopJQNrHaJvl4JtqhmBB2Y8zu9SPVw7MKOmLMaWvWrGaNODGZQn0wl9jeHrjIEXIwJ2GftjCq0H2ysLaPc0McbgRwWhNGUfzGRqQ4uQHGNr1ZM(ATBsIYuAcaxbhbcCI2boR2qBT0NqegLi6hgAnAdwmLWbrhAh4SAdTXHuQcCwTPKfprBzXtLfEaAdCoyyGJse9ciAnAh4SAdT1K(kyQMmrBWIPeoi6qjI(vGwJ2GftjCq0H2ysLaPc0oWznguGbEfWF2TptSpB0ONf4SgdkWaVc4p72Nj4ZO6zIXZYqcw64uKvMLTOkm4alMs4G2boR2q7PSUEnihuIO)MqRr7aNvBOnU9GuXZM4H2GftjCq0Hse9Ru0A0gSykHdIo0gtQeivG2tFT2v4clbUJNbEONr7zR4zu9mX4ztFT2njrzknbGRGJabor7aNvBOnmBB2YeLi6fVO1OnyXucheDOnMujqQaTN(ATBsIYuAcaxbhbcC(SrJEgfcmwTGpobDWSTzlZNnA0ZYqcw6kdhwceUslBroWIPeopJQNHdEQYYdEg1pljXyqQYYdE2TpRmCyjq4kTSfPYYduz7wHZNYZO6z4GNQS8GNr9ZssmgKQS8GNDJNvgoSeiCLw2Iuz5bQSDcO70Im0oWz1gAVidCfsfNsneGsuI2E9yWdSeTgrVGO1OnyXucheDOnMujqQaTN(ATRWGslBG7oTidTdCwTH2fguAzdCuIs0(a6WxMO1i6feTgTdCwTH2423sGWPasjAdwmLWbrhkr0lw0A0gSykHdIo0gtQeivG2IXZiDgz1MZAvHbLmmm8mQEgfcmwTGpobDAPpHi8ZO6zIXZM(ATtx2cq4QwR0KMNoce4eTdCwTH2fguYWWakr0pm0A0gSykHdIo0oWz1gAJdPuf4SAtjlEI2YINkl8a0g3T80Imokr0lGO1OnyXucheDOnMujqQaTdCwJbfyGxb8ND7Zg2ZO6zziblDAcaxlBrrIYCGftjCE2OrplWznguGbEfWF2Tptar7aNvBOnoKsvGZQnLS4jAllEQSWdq7ObuIOFfO1OnyXucheDODGZQn0ghsPkWz1Msw8eTLfpvw4bOnVSfjGsuI2uiaU9MrIwJOxq0A0oWz1gAheCyGQSeKsaNOnyXucheDOerVyrRr7aNvBOTOibIcKGhyzirBWIPeoi6qjI(HHwJ2GftjCq0H2w4bODCLFjibxPBlvTwrPfbe0oWz1gAhx5xcsWv62svRvuArabLi6fq0A0oWz1gA7vestuLxSaOnyXucheDOer)kqRr7aNvBOnLoR2qBWIPeoi6qjI(BcTgTdCwTH2AsZZzlt0gSykHdIouIs0oAaTgrVGO1ODGZQn0wt6RGPAYeTblMs4GOdLi6flAnAh4SAdTNY661GCqBWIPeoi6qjI(HHwJ2GftjCq0H2boR2qBCiLQaNvBkzXt0ww8uzHhG2aNdgg4OerVaIwJ2boR2qBC7bPINnXdTblMs4GOdLi6xbAnAh4SAdTlmOSECG2GftjCq0Hse93eAnAdwmLWbrhAJjvcKkqBkeySAbFCc6GzBZwMpB0ONn91A3KeLP0eaUcoce48zu9Sv)mkeySAbFCc60KMNZwMpJQNT6Nn91AxHlSe4oEg4HE2nEMa(SrJEMy8SmKGLUfzGRqQ4uQHahyXucNNTQNnA0ZOqGXQf8XjOBrg4kKkoLAi4zRcTdCwTH2APpHimkr0VsrRrBWIPeoi6qBmPsGubAp91ANUSfGWvTwPjnpDeiWjAh4SAdTlmOKHHbuIOx8IwJ2boR2qBsiSQ1knP5jAdwmLWbrhkr0lMqRr7aNvBOnmBB2YeTblMs4GOdLi6fuCO1ODGZQn0Erg4kKkoLAiaTblMs4GOdLi6fuq0A0oWz1gAJBduTwHB5bTblMs4GOdLi6fuSO1OnyXucheDODGZQn0oRdWZM4PW9be4OnMujqQaTN(ATRWcRgdLXDNwK9mQE20xRDeFduTwrPfbe3PfzOTfEaAN1b4zt8u4(acCuIOxWHHwJ2GftjCq0H2boR2qBSWyzNK2kSAkdEI2ysLaPc0E6R1UclSAmug3DAr2ZO6ztFT2r8nq1AfLweqCNwKH2Gwd4uzHhG2yHXYojTvy1ug8eLi6fuarRr7aNvBOTM08C2YeTblMs4GOdLi6fCfO1OnyXucheDODGZQn0ghsPkWz1Msw8eTLfpvw4bOTxpg8alrjIEbVj0A0oWz1gAxyqjdddOnyXucheDOeLOnUB5PfzC0Ae9cIwJ2boR2q7f)GCQWuTwfxbsNxqBWIPeoi6qjIEXIwJ2boR2q7clSAmughTblMs4GOdLi6hgAnAh4SAdT9kcPjQYlwa0gSykHdIouIOxarRrBWIPeoi6qBmPsGubAtHaJvl4JtqNM0xbt1K5Zgn6zz5bQSvNcE2TptqX9mQFgo4Pklp4zu9SS8av2Qtbp7gptSIdTdCwTH2eFduTwrPfbeuIOFfO1OnyXucheDOnMujqQaTZqcw6i(gOATIslcioWIPeopJQNf4SgdkWaVc4pJ2Ze8zu9mC3YtlYCeFduTwrPfbeN2xkveaFjilGklp4z34z4ULNwK50K(kyQMmDeWlkJJ2boR2qBCiLQaNvBkzXt0ww8uzHhG2ziblvKMckr0FtO1OnyXucheDOnMujqQaTPqGXQf8XjORWcRgdLXF2OrpllpqLT6uWZUXZgM4q7aNvBOnLoR2qjI(vkAnAdwmLWbrhAh4SAdTNHe0fbutsy4lOnMujqQaTfJNLHeS0TidCfsfNsne4alMs48SrJE20xRDtsuMsta4k4iqGZNr1ZOqGXQf8XjOBrg4kKkoLAiaTTWdq7zibDra1Keg(ckr0lErRr7aNvBOTphuvcEC0gSykHdIouIOxmHwJ2boR2q7PS7Js7tegTblMs4GOdLi6fuCO1ODGZQn0EceoqgQSf0gSykHdIouIOxqbrRr7aNvBOTSwUKCLaz)ZIhyjAdwmLWbrhkr0lOyrRr7aNvBOTUiWu29bTblMs4GOdLi6fCyO1ODGZQn0ommWtsiv4qkrBWIPeoi6qjIEbfq0A0oWz1gApJfvRvjPWdXrBWIPeoi6qjkrBGZbddCvtMO1i6feTgTblMs4GOdTXKkbsfO90xRDeFduTwrPfbe3PfzpJQNDGPVw7Oe4HGJQWG70ISNnA0ZcCwJbfyGxb8ND7ZggAh4SAdT1n2NdhvCfivcQjeEOerVyrRrBWIPeoi6qBmPsGubAh4SgdkWaVc4p7gpBfpJQNDGPVw7Oe4HGJQWG70ISNr1ZWDlpTiZPj9vWunz6iGxug)z3(Sv8mQEMy8SaNvBonPVcMQjtxzkTSwUKpJQNTqAF7OIgCAsFfmvtMoc4fLXFgTNjo0oWz1gA7bEnryvRvsFCDuhceECuIOFyO1OnyXucheDOnMujqQaTPqGXQf8XjOtt6RGPAY8zJg9Sfs7Bhv0Gtt6RGPAY0raVOm(ZU9zRaTdCwTH2tz3hvRv5fqbg4jmkr0lGO1OnyXucheDOnMujqQaTN(ATJ4BGQ1kkTiG4oTi7zu9Sdm91AhLapeCufgCNwK9SrJEwGZAmOad8kG)SBF2Wq7aNvBOnfFsPfUSf1ug8eLi6xbAnAdwmLWbrhAJjvcKkq7PVw7i(gOATIslciUtlYEgvp7atFT2rjWdbhvHb3PfzpB0ONf4SgdkWaVc4p72Nnm0oWz1gAtkkuKGQmfNsGbuIO)MqRrBWIPeoi6q7aNvBOnUnmyjjs4O0YWdqBmPsGubAp91AhX3avRvuAraXDAr2ZO6zhy6R1okbEi4Okm4oTidTLLbk8bTVjuIOFLIwJ2GftjCq0H2ysLaPc0E6R1oIVbQwRO0IaI70ISNr1ZoW0xRDuc8qWrvyWDArgAh4SAdTjqqPSfLwgEahLi6fVO1OnyXucheDOnMujqQaTN(ATJa4HKaNR0nbdoFkODGZQn0oVakFB2(2rPBcgqjIEXeAnAdwmLWbrhAJjvcKkq7PVw7i(gOATIslciUtlYEgvp7atFT2rjWdbhvHb3PfzpB0ONf4SgdkWaVc4p72Nnm0oWz1gAlQjYZyOmfb4Tfggqjkr7mKGLkstbTgrVGO1OnyXucheDOnMujqQaTZqcw6wKbUcPItPgcCGftjCEgvpB6R1UcxyjWD8mWd9mApBfpJQNT6Nn91A3KeLP0eaUcoce48zJg9SmKGLoy22SLPdSykHZZO6z4ULNwK5GzBZwMoc4fLXF2nEgo4Pklp4zRcTdCwTH2eFduTwrPfbeuIOxSO1OnyXucheDOnMujqQaTfJNLHeS0TidCfsfNsne4alMs48mQE2QFwgsWshmBB2Y0bwmLW5zu9mC3YtlYCWSTzlthb8IY4p7gpdh8uLLh8SrJEwgsWshU9GuXZM45alMs48mQEgUB5PfzoC7bPINnXZraVOm(ZUXZWbpvz5bpB0ONLHeS0rcHvTwPjnpDGftjCEgvpd3T80Imhjew1ALM080raVOm(ZUXZWbpvz5bpB0ONHVeKfGR0KaNvBH8z3(mbDIPNTk0oWz1gAt8nq1AfLweqqjkrjApgi8Qne9IvCckMeN4vqXH2IcIv2chTf)EuAscNNjOyFwGZQTNjlEYD)a0McP1Leq7H)mbG088z38yb(bd)zxYKcFL4(9LkV4pD427oV88LrwTHjHoVZlp89FWWF2GW8dIWptSck0ZeR4eR4(b)GH)Sv2LWwa(kXpy4pt84zcK4WZeZz5bQSvNceZpRmEcX5zT(zI5milq6YYduzRofiMFMUjptg88zCa325zRSB2N5ZJfW9dg(ZepE2nhilWZeasZZNDZJf4zRCb2nd)zREgC48S2E2cyajYMWFwzpJJvEXc4WuOSQFWpy4pt8jWbSFcNNnbDtGNHBVzKpBclLXDpBLJXaLK)mRnXJlbXt7lFwGZQn(ZAtkS7hm8Nf4SAJ7OqaC7nJKMwg8H(bd)zboR24okea3EZiPM2DD3NFWWFwGZQnUJcbWT3msQPDp8x8alJSA7he4SAJ7OqaC7nJKAA3dcomqvwcsjGZFqGZQnUJcbWT3msQPDN7751MsuKarbsWdSmK)GH)SaNvBChfcGBVzKut7o3ck8lDQ4zK8FqGZQnUJcbWT3msQPD3NdQkbpHSWdOfx5xcsWv62svRvuAra5he4SAJ7OqaC7nJKAA39kcPjQYlwGFqGZQnUJcbWT3msQPDNsNvB)GaNvBChfcGBVzKut7UM08C2Y8h8dg(ZeFcCa7NW5zWyGi8ZYYdEwEbEwGZM8SI)SyCuYykb3piWz1gNgU9TeiCkGu(dg(Ze)6NLxGN5flWZUe8NjaTa8SqNa5z4GNLT8SY4zy5ZeaPpHiSqpte8mCyp7aYq4NLxGNj(XWZUzcddplSZZ85WZ68cqE2LA5YZOqQMuPWplWz1MqpR0plghLmMsW9dcCwTXPM29cdkzyyqOsttmiDgz1MZAvHbLmmmqffcmwTGpobDAPpHimvIX0xRD6Ywacx1ALM080rGaN)GaNvBCQPDhhsPkWz1Msw8uil8aA4ULNwKX)bd)zRVapldYcKplVqa(LwEEwXnXC(mqGh409m6Guea2ZgM4XkEwgKfi5c9S8c8StP1abmmWF2esrayplVapBV(zHDE2kVfFplWz12ZKfp5pliWZirEbipJ7fsP7zRKBrWyGi0ZeacaxlB5zc0OSNrHaAGWFMpVSLNTYBX3ZcCwT9mzXZNX72aYZc(ZQ8ztWaDL8NTqGiLc)mnP9EwEbE2LA5YZOqQMuPWpJozD9AqoplWz1M7he4SAJtnT74qkvboR2uYINczHhqlAqOstlWznguGbEfWVDyuLHeS0PjaCTSffjkZbwmLWz0OaN1yqbg4va)wb8he4SAJtnT74qkvboR2uYINczHhqJx2Ie(b)GH)mXZkV8mbGaW1YwEManktONvPyM)SjKjqEw2pJcPAsL1v4z(8YwEMaq6RG9mbcY8zIUa2ZMDE5zcGaXZc78m6K11Rb58SGapR16NH7wEArM7zINvEP9ZNjaeaUw2YZeOrzc9S8c8mCBJbchEwXFws8HNfY8s7VC5z5f4zNsRbcyy4zf)zELvCSVeEMVLL8zJbIWp7sTC5zzqwG8z423sU7he4SAJ7IgOPj9vWunz(dcCwTXDrdut7(uwxVgKZpiWz1g3fnqnT74qkvboR2uYINczHhqd4CWWa)he4SAJ7IgOM2DC7bPINnX7he4SAJ7IgOM29cdkRhh)GH)SD5rrw6coptaK(eIWpd32PYQn(Z0K27z5f4z71plWz12ZKfpDpBxggEwEbEMxSapR4pBbmGezzlpthKNjbo)z0rIYEMaqa4k8m8LGSaCHEwEbEgiWdC(mCBNkR2E2fGapR4MyoFwiLplVe5ZkpknjdlD)GaNvBCx0a10URL(eIWcvAAuiWy1c(4e0bZ2MTmhnA6R1UjjktPjaCfCeiWjvRMcbgRwWhNGonP55SLjvRE6R1UcxyjWD8mWdDdbC0iXidjyPBrg4kKkoLAiWbwmLWzvJgrHaJvl4Jtq3ImWvivCk1qWQ(bboR24UObQPDVWGsgggeQ00M(ATtx2cq4QwR0KMNoce48hm8NT(c8mVybEMOskF2cyajKsHF2eE2cyajYYwEw8mzNpR1ptaAb4z4lbzb4pt0fWEMpVSLNLxGNTYBX3ZcCwT9mzXt3ZwteUSLNL9ZoGme(zc0q4N16NjaKMNpZ3Ys(S8cqGNfe4zw)mbOfGNHVeKfG)SWopZ6Nf4Sgdptai9vWEMabzYFMO2xEEMeIZZY(zv(mRZNnHYwEMphoplYNfsP7he4SAJ7IgOM2DsiSQ1knP55piWz1g3fnqnT7WSTzlZFqGZQnUlAGAA3xKbUcPItPgc(bd)zcK4LT8SvwBWZA9ZwzT88SI)mVMNsHF2nRaB)md8tsiFMOkV8S8c8SvEl(EwgKfiFwEHa8lT8WDpt8NpRnPWpBc42d4p7ayWYNTeL9mrvE5zK2F5Iu4NTsFwtEMxtGNLbzbsU7he4SAJ7IgOM2DCBGQ1kClp)GaNvBCx0a10U7ZbvLGNqw4b0Y6a8SjEkCFabUqLM20xRDfwy1yOmU70ImQM(ATJ4BGQ1kkTiG4oTi7he4SAJ7IgOM2DFoOQe8ec0AaNkl8aAyHXYojTvy1ug8uOstB6R1UclSAmug3DArgvtFT2r8nq1AfLweqCNwK9dcCwTXDrdut7UM08C2Y8he4SAJ7IgOM2DCiLQaNvBkzXtHSWdO51JbpWYFqGZQnUlAGAA3lmOKHHHFWpiWz1g3H7wEArgN2IFqovyQwRIRaPZl)GaNvBChUB5PfzCQPDVWcRgdLX)bboR24oC3YtlY4ut7UxrinrvEXc8dg(ZeO(g8Sw)mbwlcipR4plKIcH5pZNdNNjQYlptai9vWEMabz6E2k3e(zsqN9yG8m8LGSa8Nf5ZYlWZa78Sw)S8c8mDTCjFg)s7lppBcpZNdhHEwDGqkf(zL(z5f4zZMZF2PbUjMZNDk4zL9S8c8mV6CKWZA9ZYlWZeO(g8SPVw7(bboR24oC3YtlY4ut7oX3avRvuArarOstJcbgRwWhNGonPVcMQjZrJYYduzRofCRGIJACWtvwEavz5bQSvNcUHyf3py4ptGWEgVSfj8Smilq(mDTCj5c9S8c8mC3YtlYEwRFMa13GN16NjWAra5zf)zYweqEwEjSNLxGNH7wEAr2ZA9ZeasFfSNjqqMc9S8sXF2sng4pde4jjEMa13GN16NjWAra5z4lbzb4plVe5Z4xAF55zt4z(C48mrvE5zboRXWZYqcwYf6zL(zuAoVMsW9dcCwTXD4ULNwKXPM2DCiLQaNvBkzXtHSWdOLHeSurAkcvAAziblDeFduTwrPfbehyXuchQcCwJbfyGxbCAcsfUB5PfzoIVbQwRO0IaIt7lLkcGVeKfqLLhCdC3YtlYCAsFfmvtMoc4fLX)bboR24oC3YtlY4ut7oLoR2eQ00OqGXQf8XjORWcRgdLXhnklpqLT6uWngM4(bboR24oC3YtlY4ut7UphuvcEczHhqBgsqxeqnjHHViuPPjgziblDlYaxHuXPudboWIPeoJgn91A3KeLP0eaUcoce4KkkeySAbFCc6wKbUcPItPgc(bboR24oC3YtlY4ut7UphuvcE8FqGZQnUd3T80Imo10UpLDFuAFIW)GaNvBChUB5PfzCQPDFceoqgQSLFqGZQnUd3T80Imo10UlRLljxjq2)S4bw(dcCwTXD4ULNwKXPM2DDrGPS7ZpiWz1g3H7wEArgNAA3ddd8KesfoKYFqGZQnUd3T80Imo10UpJfvRvjPWdX)b)GH)mXhNdgg4pJcPAsLc)mDtEgPZiR2C8mStqoplSZZiDgz1MZAvHbLmmm4(bboR24oGZbddCA6g7ZHJkUcKkb1ecpHknTPVw7i(gOATIslciUtlYgnkWznguGbEfWVDy)GaNvBChW5GHbo10U7bEnryvRvsFCDuhceECHknTaN1yqbg4va)gRGQvp91AxHlSe4oEg4HUbnbhnsmYqcw6wKbUcPItPgcCGftjCwfv4ULNwK50K(kyQMmDeWlkJFRGI7he4SAJ7aohmmWPM29PS7JQ1Q8cOad8ewOstB1ziblDlYaxHuXPudboWIPeoun91AxHlSe4oEg4HOTcQw90xRDtsuMsta4k4iqGZrJOqGXQf8XjOdMTnBzUQvnA0QxDGZAmOad8kGF7WgnsmYqcw6wKbUcPItPgcCGftjCwfvRMcbgRwWhNGonPVcMQjZrJwiTVDurdonPVcMQjthb8IY43UIvTQFqGZQnUd4CWWaNAA3P4tkTWLTOMYGNcvAAtFT2r8nq1AfLweqCNwKnAuGZAmOad8kGF7W(bboR24oGZbddCQPDNuuOibvzkoLadcvAAtFT2r8nq1AfLweqCNwKnAuGZAmOad8kGF7W(bboR24oGZbddCQPDh3ggSKejCuAz4bcjldu4dTBsOstB6R1oIVbQwRO0IaI70ISFqGZQnUd4CWWaNAA3jqqPSfLwgEaxOstB6R1oIVbQwRO0IaI70ISFqGZQnUd4CWWaNAA3ZlGY3MTVDu6MGbHknTPVw7iaEijW5kDtWGZNYpiWz1g3bCoyyGtnT7IAI8mgktraEBHHbHknTPVw7i(gOATIslciUtlYgnkWznguGbEfWVDy)GFWWFM4JZbdd8NrHunPsHFMUjpJ0zKvBonPVcMQjZFqGZQnUd4CWWax1KjnDJ95WrfxbsLGAcHNqLM20xRDeFduTwrPfbe3PfzuDGPVw7Oe4HGJQWG70ISrJcCwJbfyGxb8Bh2piWz1g3bCoyyGRAYKAA39aVMiSQ1kPpUoQdbcpUqLMwGZAmOad8kGFJvq1bM(ATJsGhcoQcdUtlYOc3T80ImNM0xbt1KPJaErz8BxbvIrGZQnNM0xbt1KPRmLwwlxsQwiTVDurdonPVcMQjthb8IY40e3piWz1g3bCoyyGRAYKAA3NYUpQwRYlGcmWtyHknnkeySAbFCc60K(kyQMmhnAH0(2rfn40K(kyQMmDeWlkJF7k(bboR24oGZbddCvtMut7ofFsPfUSf1ug8uOstB6R1oIVbQwRO0IaI70ImQoW0xRDuc8qWrvyWDAr2OrboRXGcmWRa(Td7he4SAJ7aohmmWvnzsnT7KIcfjOktXPeyqOstB6R1oIVbQwRO0IaI70ImQoW0xRDuc8qWrvyWDAr2OrboRXGcmWRa(Td7he4SAJ7aohmmWvnzsnT742WGLKiHJsldpqizzGcFODtcvAAtFT2r8nq1AfLweqCNwKr1bM(ATJsGhcoQcdUtlY(bboR24oGZbddCvtMut7obckLTO0YWd4cvAAtFT2r8nq1AfLweqCNwKr1bM(ATJsGhcoQcdUtlY(bboR24oGZbddCvtMut7EEbu(2S9TJs3emiuPPn91AhbWdjboxPBcgC(u(bboR24oGZbddCvtMut7UOMipJHYueG3wyyqOstB6R1oIVbQwRO0IaI70ImQoW0xRDuc8qWrvyWDAr2OrboRXGcmWRa(Td7h8dg(ZcCwTXDE9yWdSK2uw2qcvAAE9yWdS0DkEgggUvqX9dg(ZcCwTXDE9yWdSKAA35xkppGiuPP51JbpWs3P4zyy4wbf3piWz1g351JbpWsQPDVWGslBGluPPn91AxHbLw2a3DAr2p4hm8NTlBrcpBDqwG8zcms1Kkf(z6M8msNrwT54zyNGCEwtjR2C)GaNvBChVSfjO4zyNGCOM2DT0NqewOstldjyPdMTnBz6alMs4qffcmwTGpobDWSTzltQwTyKHeS0TidCfsfNsne4alMs4mA00xRDfUWsG74zGh6gc4OrtFT2njrzknbGRGJabox1piWz1g3XlBrckEg2jihQPDxl9jeHfQ00Yqcw6wKbUcPItPgcCGftjCOIcbgRwWhNGUfzGRqQ4uQHaQM(ATBsIYuAcaxbhbcC(dcCwTXD8YwKGINHDcYHAA31sFcryHknnkeySAbFCc60KMNZwMun91A3KeLP0eaUcoce4KQvlgziblDlYaxHuXPudboWIPeoJgn91AxHlSe4oEg4HUHaUQFqGZQnUJx2Ieu8mStqout7ooKsvGZQnLS4Pqw4b0aohmmW)bboR24oEzlsqXZWob5qnT7AsFfmvtM)GaNvBChVSfjO4zyNGCOM29PSUEnihHknTaN1yqbg4va)wXoAuGZAmOad8kGFRGuHdEQYYdOjoQM(ATtx2cq4QwR0KMNoce48gI9he4SAJ74LTibfpd7eKd10UxyqjdddcvAAtFT2PlBbiCvRvAsZthbcC(dcCwTXD8YwKGINHDcYHAA3XThKkE2eVFqGZQnUJx2Ieu8mStqout7omBB2Y8he4SAJ74LTibfpd7eKd10UtcHvTwPjnpfQ00eJaNvBonPVcMQjtxzkTSwUKuTqAF7OIgCAsFfmvtMoc4fLXPjUFqGZQnUJx2Ieu8mStqout7(uwxVgKJqLMgo4PklpGM4gnkWznguGbEfWVvWFqGZQnUJx2Ieu8mStqout7(ImWvivCk1qGqLM20xRDtsuMsta4k4iqGZrJOqGXQf8XjOdMTnBzoAuGZAmOad8kGFRGuLHeS0XPiRmlBrvyWbwmLW5h8dg(Z2LTiHNToilq(mbgPAsLc)mDtEwEbEgPZiR2CwRkmOKHHHN1uYQn3piWz1g3XlBrckRvYWWa10URL(eIWcvAAziblDWSTzlthyXuchQOqGXQf8XjOdMTnBzs10xRDtsuMsta4k4iqGZFqGZQnUJx2IeuwRKHHbQPDxl9jeHfQ00OqGXQf8XjOBrg4kKkoLAiGQPVw7MKOmLMaWvWrGaN)GaNvBChVSfjOSwjdddut7ooKsvGZQnLS4Pqw4b0aohmmW)bboR24oEzlsqzTsgggOM2DnPVcMQjZFqGZQnUJx2IeuwRKHHbQPDFkRRxdYrOstlWznguGbEfWVvSJgf4SgdkWaVc43kivIrgsWshNISYSSfvHbhyXucNFqGZQnUJx2IeuwRKHHbQPDh3EqQ4zt8(bboR24oEzlsqzTsgggOM2Dy22SLPqLM20xRDfUWsG74zGhI2kOsmM(ATBsIYuAcaxbhbcC(dcCwTXD8YwKGYALmmmqnT7lYaxHuXPudbcvAAtFT2njrzknbGRGJabohnIcbgRwWhNGoy22SL5OrziblDLHdlbcxPLTihyXuchQWbpvz5buNKymivz5b3wgoSeiCLw2Iuz5bQSDRW5tHkCWtvwEa1jjgdsvwEWnkdhwceUslBrQS8av2ob0DAr2p4hm8NTlBrcpBDqwG8zcms1Kkf(z6M8S8c8msNrwT50K(kyQMmFwtjR2C)GaNvBChVSfjOAYKAA3XHuQcCwTPKfpfYcpGgW5GHbUQjZFqGZQnUJx2IeunzsnT7AsFfmvtM)GaNvBChVSfjOAYKAA31sFcryHknnkeySAbFCc6GzBZwMun91A3KeLP0eaUcoce48he4SAJ74LTibvtMut7(uwxVgKJqLMwGZAmOad8kGFRyhnkWznguGbEfWVvqQWbpvz5b0e3piWz1g3XlBrcQMmPM29cdkzyyqOstB6R1oDzlaHRATstAE6iqGtQWDlpTiZPj9vWunz6iGxug)2vmA00xRD6Ywacx1ALM080rGaN0e7piWz1g3XlBrcQMmPM29PSUEnihHknnCWtvwEanX9dcCwTXD8YwKGQjtQPDxl9jeHfQ00OqGXQf8XjOdMTnBz(dcCwTXD8YwKGQjtQPDxl9jeHfQ00M(ATBsIYuAcaxbhbcCs1QPqGXQf8XjOttAEoBzoA0bM(ATJsGhcoQcdoc4fLXVfe4a2pbvwEa1boR2CfguYWWGljXyqQYYdw1piWz1g3XlBrcQMmPM2DC7bPINnX7he4SAJ74LTibvtMut7omBB2Y8he4SAJ74LTibvtMut7ojew1ALM08uOst7atFT2rjWdbhvHbNpfHklbcXNsQknTPVw70LTaeUQ1knP5PJaboPjwHklbcXNsQkpp4urc0e8he4SAJ74LTibvtMut7(uwxVgKZp4hm8Nj(TNXBp4z8k9JSAJl0ZeU9FgoSNXVezcKNj(XWZOVhhpdgd2ZcDcKNfscehHFgo4zzlptaK(eIWplSZZe)y4z3mHHb3ZeiYlaruXHNLxk(ZcCwT9SI)mFoCEMOlG9S8c8mVybE2LG)mbOfGNf6eipdh8SSLNjasFcryHEghGNfZEm4(bboR24oEzlsGwHbL1JdHknnC3YtlYCfguwpoCeioct1bM(ATtuzjq4k8LskD(u(bboR24oEzlsGAA3XHuQcCwTPKfpfYcpGgVSfjO4zyNGCeQ00iDgz1MJNHDcY5he4SAJ74LTibQPDhhsPkWz1Msw8uil8aA8YwKGYALmmmiuPPr6mYQnN1Qcdkzyy4he4SAJ74LTibQPDhhsPkWz1Msw8uil8aA8YwKGQjtHknnsNrwT50K(kyQMm)bboR24oEzlsGAA3lmOSEC8dcCwTXD8YwKa10U7ZbvLGNqw4b0Y6a8SjEkCFabUqLM20xRDfwy1yOmU70ImQM(ATJ4BGQ1kkTiG4oTi7he4SAJ74LTibQPD3NdQkbpHaTgWPYcpGgwySStsBfwnLbpfQ00M(ATRWcRgdLXDNwKr10xRDeFduTwrPfbe3Pfz)GaNvBChVSfjqnT7AsZZzlZFqGZQnUJx2IeOM2DCiLQaNvBkzXtHSWdO51JbpWsHknnVECzl)GaNvBChVSfjqnT7fguYWWWp4hm8NjEw5LNTssg4kKpBtPgce6zcuFdEwRFMaRfbKNXV0(YZZMWZ85W5zKA5s(SjOBc8S8c8SvsYaxH8zBk1qWZWT3SF2Qlh4EMOkV8Sv8mXpUWsG)SWoplEgDKOSNjaeaUcRY9mXZlG9mX3STzlZNv8N1A9ZWDlpTitONjq9n4zT(zcSweqEgoSNfsE)Sj8mFoCEMazFE(mrvE5zR4zIFCHLa39dcCwTXDziblvKMcnIVbQwRO0IaIqLMwgsWs3ImWvivCk1qGdSykHdvtFT2v4clbUJNbEiARGQvp91A3KeLP0eaUcoce4C0OmKGLoy22SLPdSykHdv4ULNwK5GzBZwMoc4fLXVbo4Pklpyv)GH)mXZkV0(5ZwjjdCfYNTPudbc9mbQVbpR1ptG1IaYZ4xAF55zt4z(C48SjOBc8SWe(zZAzbipd3T80ISNTAX3STzltHE2kR9G8z7SjEc9mbAi8ZA9ZeasZZv9SM8mrxa7zcuFdEwRFMaRfbKNv8NfZ2pFw2pJab(YZe7ZWxcYcWD)GaNvBCxgsWsfPPqnT7eFduTwrPfbeHknnXidjyPBrg4kKkoLAiWbwmLWHQvNHeS0bZ2MTmDGftjCOc3T80ImhmBB2Y0raVOm(nWbpvz5bJgLHeS0HBpiv8SjEoWIPeouH7wEArMd3EqQ4zt8CeWlkJFdCWtvwEWOrziblDKqyvRvAsZthyXuchQWDlpTiZrcHvTwPjnpDeWlkJFdCWtvwEWOr4lbzb4knjWz1wiVvqNyAvOnNcGr0Ftcikrjcb]] )


end
