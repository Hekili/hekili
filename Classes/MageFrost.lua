-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
        }        
    } )

    spec:RegisterStateExpr( "incanters_flow_stacks", function ()
        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end
        
        return incanters_flow.values[ index ][ 1 ]
    end )

    spec:RegisterStateExpr( "incanters_flow_dir", function()
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

    spec:RegisterEvent( "UNIT_AURA", function( event, unit )
        if UnitIsUnit( unit, "player" ) and state.talent.incanters_flow.enabled then
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
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        frost_info.last_target_virtual = frost_info.last_target_actual
        frost_info.virtual_brain_freeze = frost_info.real_brain_freeze

        if talent.incanters_flow.enabled then
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
        end
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

    
    spec:RegisterPack( "Frost Mage", 20190722, [[dSuWKbqicv1JiLytiv9jLIQrbjvNcjfVIqAwij3cjLSlL8lKkdtPqhdjSmsj9mLImncvCnij2gKu6Bek04GKcNJqbRdjLQ5rOO7rq7JqPdIKszHirpeskAIeQKCrcvQnIKQpsOkgjHkP6KkfyLcQzcjjDtcvIDsi(PsbzOqsILQuuEQQAQqQUQsbLVsOknwcvszVi(ljdwLdl1IH4Xqnzv5YGnl0NvQgnP40uTALcQEnPuZMOBlWUf9BjdhPSCuEoQMoLRtQ2UG8DcmEij15HuwVsP5dj2VIjuqqN8FTber06gPqmSrXOw16AJBevehk2e5BOrdiFAnw7Ehi)SdaYN6SIBZjU07a5tRrtw9JGo5ZlDggiFnMrJtTthD7UPrhzHRa64EGUSnVsmRJgDCpath5JO7sBdscc5)AdiIO1nsHyyJIrTQ11g3iQioBCtKFRBAkg5)9autYxJ)Eqsqi)hWXKVwMJ6SIBZjU07WewlZPXmACQD6OB3nn6ilCfqh3d0LT5vIzD0OJ7by6MWAzUW6s0MtRuq1CADJuigMJAnNwPGAFJADcpH1YCOMA6Ch4u7tyTmh1AUnmom3MBEaOSs9CyZNZtUb9BUko3MBnBhSL5bGYk1ZHnFUyXMt2CBooGR8nhQP4Q5059oSMWAzoQ1CIlaBhMJ6SIBZjU07WCuBOkOQ81ewlZrTMBZGGkemhUk5ReKlmAyzzSkDScr2CBoSgaRnFr(sNBCc6KFSuCp3LabDIiuqqN8HSrKWJqj5JzUbmVjFCvYxjixoguzfQxmOFOnh9Z9ae9yCjWtdyCfwJlLlDAKFJnVsY3XGkRqnXiIOvc6KpKnIeEekj)gBELKpULsvJnVsL05g5lDUPYoai)yPaohsmWjgrKnrqN8BS5vs(rwTfsvXqiFiBej8iusmIiIdbDYhYgrcpcLKpM5gW8M8PXGqQD8BrXcqQePK2C0phIEmUqyTNQidGTWIbn2i)gBELKFuQZyOrmIiOcbDYhYgrcpcLKpM5gW8M8BS5HafKqGd85e7CADouqzUgBEiqbje4aFoXohfZr)C4MBkZdG5eo3gj)gBELKpI03UTzpIreb1sqN8HSrKWJqj5JzUbmVjFe9yCf9ChyCvfvrwXTfdASnh9ZHRs(kb5kYQTqQkgYIbbTN85e7COYCOGYCi6X4k65oW4QkQISIBlg0yBoHZPvYVXMxj57yqj7edeJiIyKGo5dzJiHhHsYhZCdyEt(4MBkZdG5eo3gj)gBELKpI03UTzpIreb1GGo5dzJiHhHsYhZCdyEt(0yqi1o(TOybivIusJ8BS5vs(rPoJHgXiIigiOt(q2is4rOK8Xm3aM3KpIEmUqyTNQidGTWIbn2MJ(5q95OXGqQD8BrXkYkUHusBouqzUhGOhJlAnwB4PCmSyqq7jFoXohGQbSUbkZdG5eDUgBELlhdkzNyyzSoeivMhaZrnKFJnVsYpk1zm0igrek2ibDYVXMxj5JRaWuCRybKpKnIeEekjgrekOGGo53yZRK8bKkrkPr(q2is4rOKyerOqRe0jFiBej8ius(n28kjFwJMQIQiR4g57PbmMont5rYhrpgxrp3bgxvrvKvCBXGgBc1k57PbmMont5bbWZBdiFkiFmZnG5n5)ae9yCrRXAdpLJHLonIreHInrqN8BS5vs(isF72M9iFiBej8iusmIiuioe0j)gBELKVJbvwHAYhYgrcpcLeJicfOcbDYhYgrcpcLKFJnVsY38hWTIfOW1dq1KpM5gW8M8r0JXLJrtfc8KVELGCo6Ndrpgxm9euvurReaS1ReKKF2ba5B(d4wXcu46bOAIreHculbDYhYgrcpcLKFJnVsYNwH1gmUVfEkCfqt3AZRu9GqogiFmZnG5n5JOhJlhJMke4jF9kb5C0phIEmUy6jOQOIwjayRxjij)SdaYNwH1gmUVfEkCfqt3AZRu9GqogigrekeJe0j)gBELKFKvCdPKg5dzJiHhHsIreHcudc6KpKnIeEekj)gBELKpULsvJnVsL05g5lDUPYoai)GkeeaPrmIiuigiOt(n28kjFhdkzNyG8HSrKWJqjXig5dCoKyGtqNicfe0jFiBej8ius(yMBaZBYhrpgxm9euvurReaS1ReKZHckZ1yZdbkiHah4Zj252e53yZRK8JfwNdpvVfyUbkeOdigreTsqN8HSrKWJqj5JzUbmVj)gBEiqbje4aFoXCouzo6Nd1Ndrpgxo2XsGV4wJ1EoXu4CumhkOmN4pN1siT1USXElvCAU2WcYgrcV5OM5OFoCvYxjixrwTfsvXqwmiO9KpNyNJInoh9Zj(Z1yZRCfz1wivfdz5Pkk9Dn2C0p3oR0ZNQlyfz1wivfdzXGG2t(CcNBJKFJnVsYpackgAQkQK6y)PEmOd4eJiYMiOt(q2is4rOK8Xm3aM3KpQpN1siT1USXElvCAU2WcYgrcV5OFoe9yC5yhlb(IBnw75eohQmh9ZH6ZHOhJlew7PkYaylSyqJT5qbL5OXGqQD8BrXcqQePK2CuZCuZCOGYCO(CO(Cn28qGcsiWb(CIDUnnhkOmN4pN1siT1USXElvCAU2WcYgrcV5OM5OFouFoAmiKAh)wuSISAlKQIHmhkOm3oR0ZNQlyfz1wivfdzXGG2t(CIDouzoQzoQH8BS5vs(iYQEQkQmnGcsianIrerCiOt(q2is4rOK8Xm3aM3KpIEmUy6jOQOIwjayRxjiNdfuMRXMhcuqcboWNtSZTjYVXMxj5ttN5r08CxHiBUrmIiOcbDYhYgrcpcLKpM5gW8M8r0JXftpbvfv0kbaB9kb5COGYCn28qGcsiWb(CIDUnr(n28kjFMtJMeuEQ40AmqmIiOwc6KpKnIeEekj)gBELKpUsmKgRn4PIYoaiFmZnG5n5JOhJlMEcQkQOvca26vcsYx6jOWpYh1smIiIrc6KpKnIeEekjFmZnG5n5JOhJlgG1wcCUkwmmS0Pr(n28kjFtdO0tKspFQyXWaXiIGAqqN8HSrKWJqj5JzUbmVjFe9yCX0tqvrfTsaWwVsqohkOmxJnpeOGecCGpNyNBtKFJnVsYxqXKVqGNkgWRStmqmIr(zPCPI75UeiOteHcc6KpKnIeEekjFmZnG5n5JRs(kb5YXGkRq9Ib9dT5OFUhGOhJlbEAaJRWACPCPtJ8BS5vs(oguzfQjgreTsqN8HSrKWJqj5JzUbmVjFRLqAlaPsKsAliBej8MJ(5OXGqQD8BrXcqQePK2C0phIEmUqyTNQidGTWIbn2i)gBELKFuQZyOrmIiBIGo5dzJiHhHsYhZCdyEt(0yqi1o(TOyTlBS3sfNMRnmh9ZHOhJlew7PkYaylSyqJnYVXMxj5hL6mgAeJiI4qqN8HSrKWJqj53yZRK8XTuQAS5vQKo3iFPZnv2ba5dCoKyGtmIiOcbDYVXMxj5hz1wivfdH8HSrKWJqjXiIGAjOt(q2is4rOK8Xm3aM3KFJnpeOGecCGpNyNtRZHckZ1yZdbkiHah4Zj25Oyo6Nt8NZAjK2Itt6M55UYXWcYgrcpYVXMxj5Ji9TBB2JyereJe0j)gBELKpUcatXTIfq(q2is4rOKyerqniOt(q2is4rOK8Xm3aM3KpIEmUCSJLaFXTgR9CcNdvMJ(5e)5q0JXfcR9ufzaSfwmOX2C0phIEmUcGGIHMQIkPo2FQhd6a(6vcsYVXMxj5divIusJyerede0jFiBej8ius(yMBaZBYhrpgxiS2tvKbWwyXGgBZHckZrJbHu743IIfGujsjnYVXMxj5VlBS3sfNMRnqmIiuSrc6KFJnVsY3XGkRqn5dzJiHhHsIreHckiOt(q2is4rOK8BS5vs(M)aUvSafUEaQM8Xm3aM3KpIEmUCmAQqGN81ReKZr)Ci6X4IPNGQIkALaGTELGK8ZoaiFZFa3kwGcxpavtmIiuOvc6KpKnIeEekj)gBELKpTcRnyCFl8u4kGMU1MxP6bHCmq(yMBaZBYhrpgxognviWt(6vcY5OFoe9yCX0tqvrfTsaWwVsqs(zhaKpTcRnyCFl8u4kGMU1MxP6bHCmqmIiuSjc6KFJnVsYpYkUHusJ8HSrKWJqjXiIqH4qqN8HSrKWJqj53yZRK8XTuQAS5vQKo3iFPZnv2ba5huHGainIreHcuHGo53yZRK8DmOKDIbYhYgrcpcLeJyKFSuaNdjg4e0jIqbbDYhYgrcpcLKpM5gW8M8r0JXftpbvfv0kbaB9kb5C0p3dq0JXfTgRn8uogwVsqohkOmxJnpeOGecCGpNyNBtKFJnVsYpwyDo8u9wG5gOqGoGyer0kbDYhYgrcpcLKpM5gW8M8BS5HafKqGd85eZ5qL5OFUhGOhJlAnwB4PCmSELGCo6NdxL8vcYvKvBHuvmKfdcAp5Zj25qL5OFoXFUgBELRiR2cPQyilpvrPVRXMJ(52zLE(uDbRiR2cPQyilge0EYNt4CBK8BS5vs(bqqXqtvrLuh7p1JbDaNyer2ebDYhYgrcpcLKpM5gW8M8PXGqQD8BrXkYQTqQkgYCOGYC7SspFQUGvKvBHuvmKfdcAp5Zj25qfYVXMxj5JiR6PQOY0akiHa0igreXHGo5dzJiHhHsYhZCdyEt(i6X4IPNGQIkALaGTELGCo6N7bi6X4IwJ1gEkhdRxjiNdfuMRXMhcuqcboWNtSZTjYVXMxj5ttN5r08CxHiBUrmIiOcbDYhYgrcpcLKpM5gW8M8r0JXftpbvfv0kbaB9kb5C0p3dq0JXfTgRn8uogwVsqohkOmxJnpeOGecCGpNyNBtKFJnVsYN50OjbLNkoTgdeJicQLGo5dzJiHhHsYVXMxj5JRedPXAdEQOSdaYhZCdyEt(i6X4IPNGQIkALaGTELGCo6N7bi6X4IwJ1gEkhdRxjijFPNGc)iFulXiIigjOt(q2is4rOK8Xm3aM3KpIEmUyawBjW5QyXWWsNg53yZRK8nnGsprk98PIfddeJicQbbDYhYgrcpcLKpM5gW8M8r0JXftpbvfv0kbaB9kb5C0p3dq0JXfTgRn8uogwVsqohkOmxJnpeOGecCGpNyNBtKFJnVsYxqXKVqGNkgWRStmqmIr(wlH0uSIgbDIiuqqN8HSrKWJqj5JzUbmVjFRLqARDzJ9wQ40CTHfKnIeEZr)Ci6X4YXowc8f3AS2ZjCouzo6Nd1NdrpgxiS2tvKbWwyXGgBZHckZzTesBbivIusBbzJiH3C0phUk5ReKlaPsKsAlge0EYNtmNd3CtzEamh1q(n28kjFMEcQkQOvcagXiIOvc6KpKnIeEekjFmZnG5n5l(ZzTesBTlBS3sfNMRnSGSrKWBo6Nd1NZAjK2cqQePK2cYgrcV5OFoCvYxjixasLiL0wmiO9KpNyohU5MY8ayouqzoRLqAlCfaMIBflybzJiH3C0phUk5ReKlCfaMIBflyXGG2t(CI5C4MBkZdG5qbL5SwcPTynAQkQISIBliBej8MJ(5WvjFLGCXA0uvufzf3wmiO9KpNyohU5MY8ayouqzoSMMTdCvK1yZRSLZj25OyjgMJAi)gBELKptpbvfv0kbaJyeJ8dQqqaKgbDIiuqqN8HSrKWJqj5JzUbmVjFe9yC5yqfLfWxVsqs(n28kjFhdQOSaoXig5tJb4kaPnc6erOGGo53yZRK8BgUtq5PbsjGnYhYgrcpcLeJiIwjOt(n28kjFbTbmfiHaiTws(q2is4rOKyer2ebDYhYgrcpcLKF2ba53B5AAwZvXknvfv0kbaJ8BS5vs(9wUMM1CvSstvrfTsaWigreXHGo53yZRK8dCgRykpO3bYhYgrcpcLeJicQqqN8BS5vs(0kZRK8HSrKWJqjXiIGAjOt(n28kj)iR4gsjnYhYgrcpcLeJyKFxabDIiuqqN8BS5vs(rwTfsvXqiFiBej8iusmIiALGo53yZRK8rK(2Tn7r(q2is4rOKyer2ebDYhYgrcpcLKFJnVsYh3sPQXMxPs6CJ8Lo3uzhaKpW5qIboXiIioe0j)gBELKpUcatXTIfq(q2is4rOKyerqfc6KFJnVsY3XGkRqn5dzJiHhHsIreb1sqN8HSrKWJqj5JzUbmVjFAmiKAh)wuSaKkrkPnhkOmhIEmUqyTNQidGTWIbn2MJ(5q95OXGqQD8BrXkYkUHusBo6Nd1Ndrpgxo2XsGV4wJ1EoXCoXzouqzoXFoRLqARDzJ9wQ40CTHfKnIeEZrnZHckZrJbHu743II1USXElvCAU2WCud53yZRK8JsDgdnIrermsqN8HSrKWJqj5JzUbmVjFe9yCf9ChyCvfvrwXTfdASr(n28kjFhdkzNyGyerqniOt(n28kjFwJMQIQiR4g5dzJiHhHsIrermqqN8BS5vs(asLiL0iFiBej8iusmIiuSrc6KFJnVsYFx2yVLkonxBG8HSrKWJqjXiIqbfe0j)gBELKpUsqvrfUKpYhYgrcpcLeJicfALGo5dzJiHhHsYVXMxj5B(d4wXcu46bOAYhZCdyEt(i6X4YXOPcbEYxVsqoh9ZHOhJlMEcQkQOvca26vcsYp7aG8n)bCRybkC9aunXiIqXMiOt(q2is4rOK8BS5vs(0kS2GX9TWtHRaA6wBELQheYXa5JzUbmVjFe9yC5y0uHap5RxjiNJ(5q0JXftpbvfv0kbaB9kbj5dXiGnv2ba5JrdllJvPJviYMBeJicfIdbDYVXMxj5hzf3qkPr(q2is4rOKyerOaviOt(q2is4rOK8BS5vs(4wkvn28kvsNBKV05Mk7aG8dQqqaKgXiIqbQLGo53yZRK8DmOKDIbYhYgrcpcLeJyKpUk5ReKCc6erOGGo53yZRK831B2Z7uvrvVfyLPH8HSrKWJqjXiIOvc6KFJnVsY3XOPcbEYjFiBej8iusmIiBIGo53yZRK8dCgRykpO3bYhYgrcpcLeJiI4qqN8HSrKWJqj5JzUbmVjFAmiKAh)wuSISAlKQIHmhkOmN5bGYk1ZH5e7CuSX5eDoCZnL5bWC0pN5bGYk1ZH5eZ506gj)gBELKptpbvfv0kbaJyerqfc6KpKnIeEekjFmZnG5n5BTesBX0tqvrfTsaWwq2is4nh9Z1yZdbkiHah4ZjCokMJ(5WvjFLGCX0tqvrfTsaWwrDPuXaSMMTdkZdG5eZ5WvjFLGCfz1wivfdzXGG2to53yZRK8XTuQAS5vQKo3iFPZnv2ba5BTestXkAeJicQLGo5dzJiHhHsYhZCdyEt(0yqi1o(TOy5y0uHap5ZHckZzEaOSs9CyoXCUnTrYVXMxj5tRmVsIrermsqN8BS5vs(6Cq5geWjFiBej8iusmIiOge0jFiBej8ius(zhaKpTcRnyCFl8u4kGMU1MxP6bHCmq(n28kjFAfwBW4(w4PWvanDRnVs1dc5yGyerede0j)gBELKpISQNkQZqJ8HSrKWJqjXiIqXgjOt(n28kjFeGXbM2EUt(q2is4rOKyerOGcc6KFJnVsYx67AmUAdx)ThaPr(q2is4rOKyerOqRe0j)gBELKF0zaISQh5dzJiHhHsIreHInrqN8BS5vs(DIbUXAPc3sj5dzJiHhHsIrmY)bXwxAe0jIqbbDYVXMxj5Jl90agNgiLKpKnIeEekjgreTsqN8HSrKWJqj5JzUbmVjFAmiKAh)wuSIsDgdT5OFoXFoe9yCf9ChyCvfvrwXTfdASr(n28kjFhdkzNyGyer2ebDYhYgrcpcLKFJnVsYh3sPQXMxPs6CJ8Lo3uzhaKpUk5ReKCIrerCiOt(q2is4rOK8Xm3aM3KFJnpeOGecCGpNyNBtZr)CwlH0wrgaB9CxXApxq2is4nhkOmxJnpeOGecCGpNyNtCi)gBELKpULsvJnVsL05g5lDUPYoai)UaIrebviOt(q2is4rOK8Xm3aM3KpRS28kxrwTfsvXqi)gBELKpULsvJnVsL05g5lDUPYoai)yP4EUlbIreb1sqN8HSrKWJqj5JzUbmVjFwzT5vUYs5yqj7edKFJnVsYh3sPQXMxPs6CJ8Lo3uzhaKFwkxQ4EUlbIrermsqN8HSrKWJqj5JzUbmVjFwzT5vU4wNVM9i)gBELKpULsvJnVsL05g5lDUPYoaiFUN7sGyeJ85EUlbc6erOGGo5dzJiHhHsYhZCdyEt(4QKVsqUCmOYkuVyq)qBo6N7bi6X4sGNgW4kSgxkx60i)gBELKVJbvwHAIrerRe0jFiBej8ius(yMBaZBY3AjK2cqQePK2cYgrcV5OFoAmiKAh)wuSaKkrkPnh9ZH6Zj(ZzTesBTlBS3sfNMRnSGSrKWBouqzoe9yC5yhlb(IBnw75eZ5eN5qbL5q0JXfcR9ufzaSfwmOX2Cud53yZRK8JsDgdnIrezte0jFiBej8ius(yMBaZBY3AjK2Ax2yVLkonxBybzJiH3C0phngesTJFlkw7Yg7TuXP5AdZr)Ci6X4cH1EQIma2clg0yJ8BS5vs(rPoJHgXiIioe0jFiBej8ius(yMBaZBYNgdcP2XVffRiR4gsjT5OFoe9yCHWApvrgaBHfdASnh9ZH6Zj(ZzTesBTlBS3sfNMRnSGSrKWBouqzoe9yC5yhlb(IBnw75eZ5eN5OgYVXMxj5hL6mgAeJicQqqN8HSrKWJqj53yZRK8XTuQAS5vQKo3iFPZnv2ba5dCoKyGtmIiOwc6KFJnVsYpYQTqQkgc5dzJiHhHsIrermsqN8HSrKWJqj5JzUbmVj)gBEiqbje4aFoXoNwNdfuMRXMhcuqcboWNtSZrXC0phU5MY8ayoHZTX5OFoe9yCf9ChyCvfvrwXTfdASnNyoNwj)gBELKpI03UTzpIreb1GGo5dzJiHhHsYhZCdyEt(i6X4k65oW4QkQISIBlg0yJ8BS5vs(oguYoXaXiIigiOt(n28kjFCfaMIBflG8HSrKWJqjXiIqXgjOt(n28kjFaPsKsAKpKnIeEekjgrekOGGo5dzJiHhHsYhZCdyEt(I)Cn28kxrwTfsvXqwEQIsFxJnh9ZTZk98P6cwrwTfsvXqwmiO9KpNW52i53yZRK8znAQkQISIBeJicfALGo5dzJiHhHsYhZCdyEt(4MBkZdG5eo3gNdfuMRXMhcuqcboWNtSZrb53yZRK8rK(2Tn7rmIiuSjc6KpKnIeEekjFmZnG5n5JOhJlew7PkYaylSyqJT5qbL5OXGqQD8BrXcqQePK2COGYCn28qGcsiWb(CIDokMJ(5SwcPT40KUzEURCmSGSrKWJ8BS5vs(7Yg7TuXP5AdeJicfIdbDYVXMxj57yqLvOM8HSrKWJqjXiIqbQqqN8HSrKWJqj53yZRK8n)bCRybkC9aun5JzUbmVjFe9yC5y0uHap5RxjiNJ(5q0JXftpbvfv0kbaB9kbj5NDaq(M)aUvSafUEaQMyerOa1sqN8HSrKWJqj53yZRK8PvyTbJ7BHNcxb00T28kvpiKJbYhZCdyEt(i6X4YXOPcbEYxVsqoh9ZHOhJlMEcQkQOvca26vcsYhIraBQSdaYhJgwwgRshRqKn3igrekeJe0j)gBELKFKvCdPKg5dzJiHhHsIreHcudc6KpKnIeEekj)gBELKpULsvJnVsL05g5lDUPYoai)GkeeaPrmIiuigiOt(n28kjFhdkzNyG8HSrKWJqjXigXi)qaJ7vserRBKcXWgfJBumSOavehuH8f0S0ZDo5Vbb0kMbV5OGI5AS5voN05gFnHjFonateb1koKpnwfDjq(AzoQZkUnN4sVdtyTmNgZOXP2PJUD30OJSWvaDCpqx2MxjM1rJoUhGPBcRL5cRlrBoTsbvZP1nsHyyoQ1CALcQ9nQ1j8ewlZHAQPZDGtTpH1YCuR52W4WCBU5bGYk1ZHnFop5g0V5Q4CBU1SDWwMhakRuph285IfBozZT54aUY3COMIRMtN37WAcRL5OwZjUaSDyoQZkUnN4sVdZrTHQGQYxtyTmh1AUndcQqWC4QKVsqUWOHLLXQ0XkezZT5WAaS281eEcRL5e3OAaRBWBoeiwmyoCfG02CiWUN81CuBymqZ4ZLvsT00SGOUCUgBEL85QuI2AcRL5AS5vYx0yaUcqAtyu2CTNWAzUgBEL8fngGRaK2eviDXQEtyTmxJnVs(IgdWvasBIkKUwFpasRnVYjCJnVs(IgdWvasBIkKUMH7euEAGucyBc3yZRKVOXaCfG0MOcPJRheuPsqBatbsiasRLtyTmxJnVs(IgdWvasBIkKoE204AktXT24t4gBEL8fngGRaK2eviD6Cq5geqv2bGWElxtZAUkwPPQOIwjayt4gBEL8fngGRaK2eviDboJvmLh07WeUXMxjFrJb4kaPnrfshTY8kNWn28k5lAmaxbiTjQq6ISIBiL0MWtyTmN4gvdyDdEZbHagAZzEamNPbMRXwXMZ5Z1HAx2isynHBS5vYfIl90agNgiLtyTm3geNZ0aZf07WCAA(CuVO(CD0a2C4MBEUpNNCRtBoQl1zm0OAobWC4oN7bYgT5mnWCBagMdvTtmmxNV505WCLPbyZPX31mhnMxm3qBUgBELunNhNRd1USrKWAc3yZRKlQq6CmOKDIbQ8OqAmiKAh)wuSIsDgdn6fFe9yCf9ChyCvfvrwXTfdASnHBS5vYfviD4wkvn28kvsNBuLDaiexL8vcs(ewlZHUgyoRz7GnNPHbCnL8nNZZn3Mdq1n2wZrjycaiNBtuluzoRz7GXPAotdm3ZJrGbjg4ZHaMaaY5mnWCF0NRZ3CuBL4EUgBELZjDUXNRzWCS20aS54bTuUMtC9saecyunh1zaS1Z952S2Z5OXGiW4ZPZ9CFoQTsCpxJnVY5Ko3MJxvcS5A(CUnhcKq0n(C7mOnjAZfzvWCMgyon(UM5OX8I5gAZrP03UTzV5AS5vUMWn28k5IkKoClLQgBELkPZnQYoae2fqLhf2yZdbkiHah4IDt0BTesBfzaS1ZDfR9CbzJiHhkO0yZdbkiHah4IvCMWn28k5IkKoClLQgBELkPZnQYoaeglf3ZDjqLhfYkRnVYvKvBHuvmKjCJnVsUOcPd3sPQXMxPs6CJQSdaHzPCPI75UeOYJczL1Mx5klLJbLStmmHBS5vYfviD4wkvn28kvsNBuLDaiK75UeOYJczL1Mx5IBD(A2BcpH1YCIx30mh1zaS1Z952S2tQMZTnNphcygWMZQ5OX8I5MVfMtN75(CuNvBHCUnedzobAGCoKY0mh13qZ15BokL(2Tn7nxZG5QyCoCvYxjixZjEDttPBZrDgaB9CFUnR9KQ5mnWC4kdbmomNZNZy6WCT00u67AMZ0aZ98yeyqIH5C(CbE6CSUeMtpnxoxiGH2CA8DnZznBhS5WLEA81eUXMxjF1fimYQTqQkgYeUXMxjF1fiQq6qK(2Tn7nHBS5vYxDbIkKoClLQgBELkPZnQYoaecCoKyGpHBS5vYxDbIkKoCfaMIBflyc3yZRKV6ceviDoguzfQNWAzUVhqt6rhEZrDPoJH2C4kFU5vYNlYQG5mnWCF0NRXMx5CsNBR5(EIH5mnWCb9omNZNBhsG1MN7ZfB2CsGZNJsw75CuNbWwyoSMMTdCQMZ0aZbO6gBZHR85Mx5CAagmNZZn3MRLY5mnTnNhqRywN2Ac3yZRKV6ceviDrPoJHgvEuingesTJFlkwasLiL0qbfe9yCHWApvrgaBHfdASrpQtJbHu743IIvKvCdPKg9OoIEmUCSJLaFXTgRTykoOGI4BTesBTlBS3sfNMRnSGSrKWJAqbfAmiKAh)wuS2Ln2BPItZ1gOMjCJnVs(QlquH05yqj7edu5rHi6X4k65oW4QkQISIBlg0yBcRL5qxdmxqVdZjWLY52HeyTuI2CiWC7qcS28CFUEozzZvX5OEr95WAA2oWNtGgiNtN75(CMgyoQTsCpxJnVY5Ko3wZHodnp3NZQ5EGSrBUnRrBUkoh1zf3MtpnxoNPbyWCndMlR5OEr95WAA2oWNRZ3CznxJnpemh1z1wiNBdXq4ZjO0LV5Kq)MZQ5CBUSS5qap3NtNdV5ABUwkxt4gBEL8vxGOcPJ1OPQOkYkUnHBS5vYxDbIkKoaPsKsAt4gBEL8vxGOcPBx2yVLkonxBycRL52W4EUphQzLWCvCouZs(MZ5ZfuCtI2CIRqv(ZLGUXA5CcCtZCMgyoQTsCpN1SDWMZ0WaUMs(4R52aBUkLOnhcGRaGp3dWqAZT3EoNa30mhR031irBoX4CfBUGIbZznBhm(Ac3yZRKV6ceviD4kbvfv4s(MWn28k5RUarfsNohuUbbuLDai08hWTIfOW1dq1u5rHi6X4YXOPcbEYxVsqspIEmUy6jOQOIwjayRxjiNWn28k5RUarfsNohuUbbubXiGnv2bGqmAyzzSkDScr2CJkpkerpgxognviWt(6vcs6r0JXftpbvfv0kbaB9kb5eUXMxjF1fiQq6ISIBiL0MWn28k5RUarfshULsvJnVsL05gvzhacdQqqaK2eUXMxjF1fiQq6CmOKDIHj8eUXMxjFHRs(kbjx4UEZEENQkQ6TaRmnt4gBEL8fUk5ReKCrfsNJrtfc8KpHBS5vYx4QKVsqYfviDboJvmLh07WewlZTz6jmxfNdvPeaS5C(CTuqJgFoDo8MtGBAMJ6SAlKZTHyiR5O2s0MtcrRcbS5WAA2oWNRT5mnWCq(MRIZzAG5I(UgBoUMsx(MdbMtNdpQMZFqlLOnNhNZ0aZHuC(CVc45MBZ9CyopNZ0aZf4VNeMRIZzAG52m9eMdrpgxt4gBEL8fUk5ReKCrfshtpbvfv0kbaJkpkKgdcP2XVffRiR2cPQyiOGI5bGYk1ZbXsXgff3CtzEaqV5bGYk1ZbXuRBCcRL52q5CCp3LWCwZ2bBUOVRX4unNPbMdxL8vcY5Q4CBMEcZvX5qvkbaBoNpNSeaS5mnDoNPbMdxL8vcY5Q4CuNvBHCUnedHQ5mnoFUDpeWNdq1gRNBZ0tyUkohQsjayZH10SDGpNPPT54AkD5BoeyoDo8MtGBAMRXMhcMZAjKgNQ584C0ko3rKWAc3yZRKVWvjFLGKlQq6WTuQAS5vQKo3Ok7aqO1sinfROrLhfATesBX0tqvrfTsaWwq2is4rFJnpeOGecCGlKc6XvjFLGCX0tqvrfTsaWwrDPuXaSMMTdkZdaXexL8vcYvKvBHuvmKfdcAp5t4gBEL8fUk5ReKCrfshTY8kPYJcPXGqQD8BrXYXOPcbEYrbfZdaLvQNdI5M24eUXMxjFHRs(kbjxuH0PZbLBqaFc3yZRKVWvjFLGKlQq605GYniGQSdaH0kS2GX9TWtHRaA6wBELQheYXWeUXMxjFHRs(kbjxuH0HiR6PI6m0MWn28k5lCvYxji5IkKoeGXbM2EUpHBS5vYx4QKVsqYfviDsFxJXvB46V9aiTjCJnVs(cxL8vcsUOcPl6marw1Bc3yZRKVWvjFLGKlQq66edCJ1sfULYj8eUXMxjFbCoKyGlmwyDo8u9wG5gOqGoGkpkerpgxm9euvurReaS1ReKOGsJnpeOGecCGl2nnHBS5vYxaNdjg4IkKUaiOyOPQOsQJ9N6XGoGtLhf2yZdbkiHah4IjQqpQJOhJlh7yjWxCRXAlMcPafueFRLqARDzJ9wQ40CTHfKnIeEud94QKVsqUISAlKQIHSyqq7jxSuSr6f)gBELRiR2cPQyilpvrPVRXOFNv65t1fSISAlKQIHSyqq7jx4gNWn28k5lGZHedCrfshISQNQIktdOGecqJkpke1TwcPT2Ln2BPItZ1gwq2is4rpIEmUCSJLaFXTgRTquHEuhrpgxiS2tvKbWwyXGgBOGcngesTJFlkwasLiL0OgQbfuqDuVXMhcuqcboWf7MqbfX3AjK2Ax2yVLkonxBybzJiHh1qpQtJbHu743IIvKvBHuvmeuqzNv65t1fSISAlKQIHSyqq7jxSOc1qnt4gBEL8fW5qIbUOcPJMoZJO55Ucr2CJkpkerpgxm9euvurReaS1ReKOGsJnpeOGecCGl2nnHBS5vYxaNdjg4IkKoMtJMeuEQ40AmqLhfIOhJlMEcQkQOvca26vcsuqPXMhcuqcboWf7MMWn28k5lGZHedCrfshUsmKgRn4PIYoaOs6jOWpHOwQ8Oqe9yCX0tqvrfTsaWwVsqoHBS5vYxaNdjg4IkKotdO0tKspFQyXWavEuiIEmUyawBjW5QyXWWsN2eUXMxjFbCoKyGlQq6eum5le4PIb8k7edu5rHi6X4IPNGQIkALaGTELGefuAS5HafKqGdCXUPj8eUXMxjFflfW5qIbUWyH15Wt1BbMBGcb6aQ8Oqe9yCX0tqvrfTsaWwVsqs)dq0JXfTgRn8uogwVsqIckn28qGcsiWbUy30eUXMxjFflfW5qIbUOcPlackgAQkQK6y)PEmOd4u5rHn28qGcsiWbUyIk0)ae9yCrRXAdpLJH1ReK0JRs(kb5kYQTqQkgYIbbTNCXIk0l(n28kxrwTfsvXqwEQIsFxJr)oR0ZNQlyfz1wivfdzXGG2tUWnoHBS5vYxXsbCoKyGlQq6qKv9uvuzAafKqaAu5rH0yqi1o(TOyfz1wivfdbfu2zLE(uDbRiR2cPQyilge0EYflQmHBS5vYxXsbCoKyGlQq6OPZ8iAEURqKn3OYJcr0JXftpbvfv0kbaB9kbj9parpgx0AS2Wt5yy9kbjkO0yZdbkiHah4IDtt4gBEL8vSuaNdjg4IkKoMtJMeuEQ40AmqLhfIOhJlMEcQkQOvca26vcs6FaIEmUO1yTHNYXW6vcsuqPXMhcuqcboWf7MMWn28k5RyPaohsmWfviD4kXqAS2GNkk7aGkPNGc)eIAPYJcr0JXftpbvfv0kbaB9kbj9parpgx0AS2Wt5yy9kb5eUXMxjFflfW5qIbUOcPZ0ak9eP0ZNkwmmqLhfIOhJlgG1wcCUkwmmS0PnHBS5vYxXsbCoKyGlQq6eum5le4PIb8k7edu5rHi6X4IPNGQIkALaGTELGK(hGOhJlAnwB4PCmSELGefuAS5HafKqGdCXUPj8ewlZ1yZRKVcQqqaKMqUgpiayu5rHbviiasB9CU1jgelfBCcRL5AS5vYxbviiastuH0Hi9uBQ8OWGkeeaPTEo36edILInoHBS5vYxbviiastuH05yqfLfWPYJcr0JXLJbvuwaF9kb5eEcRL5OoR2c5CBigYCFp3LWewlZTb5C8kaMJ7MEBELCQMdTsFoCNZX10MbS52ammNivOEoieKZ1rdyZ1sg0p0Md3CZZ95OUuNXqBUoFZTbyyou1oXWAUnKPbycComNPX5Z1yZRCoNpNohEZjqdKZzAG5c6DyonnFoQxuFUoAaBoCZnp3NJ6sDgdnQMJdWCnsfcwt4gBEL8vSuCp3LGqhdQSc1u5rH4QKVsqUCmOYkuVyq)qJ(hGOhJlbEAaJRWACPCPtBc3yZRKVILI75UeeviD4wkvn28kvsNBuLDaimwkGZHed8jCJnVs(kwkUN7squH0fz1wivfdzc3yZRKVILI75UeeviDrPoJHgvEuingesTJFlkwasLiL0OhrpgxiS2tvKbWwyXGgBt4gBEL8vSuCp3LGOcPdr6B32ShvEuyJnpeOGecCGlwTIckn28qGcsiWbUyPGECZnL5bGWnoHBS5vYxXsX9CxcIkKohdkzNyGkpkerpgxrp3bgxvrvKvCBXGgB0JRs(kb5kYQTqQkgYIbbTNCXIkOGcIEmUIEUdmUQIQiR42Ibn2eQ1jCJnVs(kwkUN7squH0Hi9TBB2Jkpke3CtzEaiCJt4gBEL8vSuCp3LGOcPlk1zm0OYJcPXGqQD8BrXcqQePK2eUXMxjFflf3ZDjiQq6IsDgdnQ8Oqe9yCHWApvrgaBHfdASrpQtJbHu743IIvKvCdPKgkO8ae9yCrRXAdpLJHfdcAp5Ifq1aw3aL5bGOn28kxoguYoXWYyDiqQmpaOMjCJnVs(kwkUN7squH0HRaWuCRybt4gBEL8vSuCp3LGOcPdqQePK2eUXMxjFflf3ZDjiQq6ynAQkQISIBu5rHparpgx0AS2Wt5yyPtJkpnGX0Pzkpkerpgxrp3bgxvrvKvCBXGgBc1kvEAaJPtZuEqa882aHumHBS5vYxXsX9CxcIkKoePVDBZEt4gBEL8vSuCp3LGOcPZXGkRq9eUXMxjFflf3ZDjiQq605GYniGQSdaHM)aUvSafUEaQMkpkerpgxognviWt(6vcs6r0JXftpbvfv0kbaB9kb5eUXMxjFflf3ZDjiQq605GYniGQSdaH0kS2GX9TWtHRaA6wBELQheYXavEuiIEmUCmAQqGN81ReK0JOhJlMEcQkQOvca26vcYjCJnVs(kwkUN7squH0fzf3qkPnHBS5vYxXsX9CxcIkKoClLQgBELkPZnQYoaeguHGaiTjCJnVs(kwkUN7squH05yqj7edt4jSwMtKAUnadZHQ2jgM775UeMWAzUniNJxbWCC30BZRKt1COv6ZH7CoUM2mGn3gGH5ePc1ZbHGCUoAaBUwYG(H2C4MBEUph1L6mgAZ15BUnadZHQ2jgwZTHmnatGZH5mnoFUgBELZ58505WBobAGCotdmxqVdZPP5Zr9I6Z1rdyZHBU55(CuxQZyOr1CCaMRrQqWAc3yZRKVYs5sf3ZDji0XGkRqnvEuiUk5ReKlhdQSc1lg0p0O)bi6X4sGNgW4kSgxkx60MWn28k5RSuUuX9CxcIkKUOuNXqJkpk0AjK2cqQePK2cYgrcp6PXGqQD8BrXcqQePKg9i6X4cH1EQIma2clg0yBc3yZRKVYs5sf3ZDjiQq6IsDgdnQ8OqAmiKAh)wuS2Ln2BPItZ1gOhrpgxiS2tvKbWwyXGgBt4gBEL8vwkxQ4EUlbrfshULsvJnVsL05gvzhacbohsmWNWn28k5RSuUuX9CxcIkKUiR2cPQyit4gBEL8vwkxQ4EUlbrfshI03UTzpQ8OWgBEiqbje4axSAffuAS5HafKqGdCXsb9IV1siTfNM0nZZDLJHfKnIeEt4gBEL8vwkxQ4EUlbrfshUcatXTIfmHBS5vYxzPCPI75UeeviDasLiL0OYJcr0JXLJDSe4lU1yTfIk0l(i6X4cH1EQIma2clg0yJEe9yCfabfdnvfvsDS)upg0b81ReKtyTm3gghMZ0485QedZzSoeivMhaZ15BopXDAaJRIYsGY8aqz1sCT5C(CEanjeaPbV1ewlZ1yZRKVYs5sf3ZDjiQq62Ln2BPItZ1gOYJcr0JXfcR9ufzaSfwmOXgkOqJbHu743IIfGujsjnuqXAjK2YtCNgW4QOSeSGSrKWJECZnL5bGOgRdbsL5bGy9e3PbmUkklbkZdaLvluzPtJECZnL5bGOgRdbsL5bGy6jUtdyCvuwcuMhakRwIZ6vcYjCJnVs(klLlvCp3LGOcPBx2yVLkonxBGkpkerpgxiS2tvKbWwyXGgBOGcngesTJFlkwasLiL0MWn28k5RSuUuX9CxcIkKohdQSc1t4gBEL8vwkxQ4EUlbrfsNohuUbbuLDai08hWTIfOW1dq1u5rHi6X4YXOPcbEYxVsqspIEmUy6jOQOIwjayRxjiNWn28k5RSuUuX9CxcIkKoDoOCdcOk7aqiTcRnyCFl8u4kGMU1MxP6bHCmqLhfIOhJlhJMke4jF9kbj9i6X4IPNGQIkALaGTELGCc3yZRKVYs5sf3ZDjiQq6ISIBiL0MWn28k5RSuUuX9CxcIkKoClLQgBELkPZnQYoaeguHGaiTjCJnVs(klLlvCp3LGOcPZXGs2jgMWtyTm33681S3CFp3LWewlZTb5C8kaMJ7MEBELCQMdTsFoCNZX10MbS52ammNivOEoieKZ1rdyZ1sg0p0Md3CZZ95OUuNXqBUoFZTbyyou1oXWAUnKPbycComNPX5Z1yZRCoNpNohEZjqdKZzAG5c6DyonnFoQxuFUoAaBoCZnp3NJ6sDgdnQMJdWCnsfcwt4gBEL8f3ZDji0XGkRqnvEuiUk5ReKlhdQSc1lg0p0O)bi6X4sGNgW4kSgxkx60MWAzoXRBAkDBoXZNQ5e3ivIusBoNpxlf0OXNJRPndyWBnN41nnZjE(unN4gPsKsAZ5854AAZag8MZJZ52CckD5Bobn3G5OK1Eoh1zaSfMdRPz7WCOUVG1Cc0a5CMgyUGEhMJBnZ4ZHBU55(CIBKkrkPnNa30mhLS2Z5OodGTWCn28qa1mxXMtGgiNdbKLG5eN52aSJLaFou3JZjUrQePK2CoFoCZT5eObY5mnWCb9omNMMpN4qTqL52aSJLaNQ5CBZ5ZHaMbS5SAoDomNPbMJsw75CuNbWwyUiRcMZT5QCoXJSXElN7tZ1gOM1eUXMxjFX9CxcIkKUOuNXqJkpk0AjK2cqQePK2cYgrcp6PXGqQD8BrXcqQePKg9OU4BTesBTlBS3sfNMRnSGSrKWdfuq0JXLJDSe4lU1yTftXbfuq0JXfcR9ufzaSfwmOXg1mH1YCIhzJ9wo3NMRnmNZNRLcA04ZX10Mbm4TMWn28k5lUN7squH0fL6mgAu5rHwlH0w7Yg7TuXP5AdliBej8ONgdcP2XVffRDzJ9wQ40CTb6r0JXfcR9ufzaSfwmOX2ewlZjEDttPBZjE(unNPbMlO3H52W152CgZb(CwnhxtBgWMR5Zf0jAZrDwXnKsA85A(C0ko3rKWAoXRBAMt88PAotdmxqVdZvPeT54AAZagFoQZkUHusBottBZjO0LV5OPBZzAGG5ABokOwBAUna7yjmh3AS281CIR8yeyqIH5qataa5CCnTzaZZ95OoR4gsjT5e4MM5OGATP52aSJLaFUoFZrb1sCMBdWowc85C(C8GwkPAoeDBokOwBAodYhFoRMdbMdbmdyZ55CbfdMJ7MEBEL85qDtdmNgFxdWMt88N71b9omNZPAotdmxqXG5CBoj0jFoRe0ShFokOwBIAwZr9IH9CFoUM2mGnxLZrDwXnKsAZ5854MlLZ1ZXdAPCU92tQMJxZ585YYMd3mp3NRrkDBoQxuFn3gGH5qv7edZ585SQMta0ApNvZjOzSoT5EGSrZZ95OK1Eoh1zaSfMJ6sDgdT1eUXMxjFX9CxcIkKUOuNXqJkpkKgdcP2XVffRiR4gsjn6r0JXfcR9ufzaSfwmOXg9OU4BTesBTlBS3sfNMRnSGSrKWdfuq0JXLJDSe4lU1yTftXHAMWn28k5lUN7squH0HBPu1yZRujDUrv2bGqGZHed8jCJnVs(I75UeeviDrwTfsvXqMWAzoXRBAMJ6ma265(CBw75CD(MRT5KqZT506CwZ2bJt1Cuk9TBB2BUeGhFoRMdbMtNdV5e4MM5047Aa2C0yEXCdT5SAUGwByoUodMdTsFoCNZfDBoKY0mNNCRtBokL(2Tn7XNZtRMRNJ75UeMJ6ma265(CBw75AUV1mZZ95e4MM5mnmaMZA2oyCQMJsPVDBZEZjHoeWNZ0aZjlbZrJ5fZn0Ml6sjWMJvsyUoFZ58505WBUkNdxL8vcY5q9oFZTHRZT5cAT9CFoUodMllBoRMtqZnyokzTNZrDgaBH5WAA2oWPM5e4MM5k2CcCttPBZrDgaB9CFUnR9CnHBS5vYxCp3LGOcPdr6B32ShvEuyJnpeOGecCGlwTIckn28qGcsiWbUyPGECZnL5bGWnspIEmUIEUdmUQIQiR42Ibn2etToH1YCOZqZZ95SAoAvjNdRPz7aFUkoh1lQpxSyZ1jAMgp3NZ55MBZjOyMM5CBn3gghMZ0abZ185mnaAZHRaynHBS5vYxCp3LGOcPZXGs2jgOYJcr0JXv0ZDGXvvufzf3wmOX2eUXMxjFX9CxcIkKoCfaMIBflyc3yZRKV4EUlbrfshGujsjTjSwMBZA0MRIZrDwXT5C(C6C4nxhnGnxlLZrDp3bgFUkoh1zf3MdRPz7aFonDiyoeaY505WBUoFZzAagmNZZn3MRXMhcMJ6SAlKZTHyiZzAABoCPlFZTdjWAdMlOyWAo01485C(CvkrBUEoEqlLZT3EoxV3EYT5c0LMttcZznBhmovZ1852SgT5Q4CuNvCBoNNBUnNv1CEaTgBrD5Ac3yZRKV4EUlbrfshRrtvrvKvCJkpku8BS5vUISAlKQIHS8ufL(UgJ(DwPNpvxWkYQTqQkgYIbbTNCHBCcRL5Ou6B32S3CoFoDo8MR5ZjlbZrJ5fZn0Ml6sjWMR3Bp52CADoRz7GXxZjE1a5C6Cp3NJ6ma265(CBw7jvZ52MZNRNlaEUEWC7TNZz1C6CyotdmNNCRtBokL(2Tn7nhecY5692tUnxph3ZDjmN1SDWOAoGtdWElLOnNa30mNSemxqZnGH2Ac3yZRKV4EUlbrfshI03UTzpQ8OqCZnL5bGWnIckn28qGcsiWbUyPycRL5epYg7TCUpnxByoNpNohEZjqdKZzAagS58565OK1Eoh1zaSfMJgRWZ1yZdbZH6(cwZvPeT5eObY5CBoCNZHaZX10Mbm4rnR5qxJZNZ5Z1ZXdAPCoRMlaEUEWC7TNZ55Cbf3MJ7MEBEL81COQLG5cAUbm0MtcDYNZkbn7XNtN75(CUnNanqoxhQDzJiH1CIxnqoNo3Z95(0KUzEUp3gGH568nNMoKN7Z1zzAa2CwZ2bBUeAgcAunNBBoFoU031ys0MdbmdyZz1C6CyoXZFobAGCUou7YgrcunxZNZ0aZXbCLV5SMTd2CVc45MBZHajeDBUiRcMJRPndyEUpNPbMlO9CoRz7GTMWn28k5lUN7squH0TlBS3sfNMRnqLhfIOhJlew7PkYaylSyqJnuqHgdcP2XVfflaPsKsAOGsJnpeOGecCGlwkO3AjK2Itt6M55UYXWcYgrcVjCJnVs(I75UeeviDoguzfQNWn28k5lUN7squH0PZbLBqavzhacn)bCRybkC9aunvEuiIEmUCmAQqGN81ReK0JOhJlMEcQkQOvca26vcYjCJnVs(I75UeeviD6Cq5geqfeJa2uzhacXOHLLXQ0XkezZnQ8Oqe9yC5y0uHap5RxjiPhrpgxm9euvurReaS1ReKt4gBEL8f3ZDjiQq6ISIBiL0MWn28k5lUN7squH0HBPu1yZRujDUrv2bGWGkeeaPnHBS5vYxCp3LGOcPZXGs2jgMWtyTmN41nnZjEKn2B5CFAU2avZTz6jmxfNdvPeaS54AkD5BoeyoDo8MJ57AS5qGyXG5mnWCIhzJ9wo3NMRnmhUcqQ5qDFbR5e4MM5qL52aSJLaFUoFZ1ZrjR9CoQZaylqnR5eVAGCoXnsLiL0MZ5ZvX4C4QKVsqs1CBMEcZvX5qvkbaBoCNZ1sEnhcmNohEZTHRZT5e4MM5qL52aSJLaFnHBS5vYxwlH0uSIMqMEcQkQOvcagvEuO1siT1USXElvCAU2WcYgrcp6r0JXLJDSe4lU1yTfIk0J6i6X4cH1EQIma2clg0ydfuSwcPTaKkrkPTGSrKWJECvYxjixasLiL0wmiO9KlM4MBkZdaQzcRL5eVUPP0T5epYg7TCUpnxBGQ52m9eMRIZHQuca2CCnLU8nhcmNohEZHaXIbZ1jAZH477aBoCvYxjiNd1f3ivIusJQ5qnRaWM7BflGQ52SgT5Q4CuNvCJAMRyZjqdKZTz6jmxfNdvPeaS5C(CnsPBZz1CmOXAMtRZH10SDGVMWn28k5lRLqAkwrtuH0X0tqvrfTsaWOYJcfFRLqARDzJ9wQ40CTHfKnIeE0J6wlH0wasLiL0wq2is4rpUk5ReKlaPsKsAlge0EYftCZnL5bakOyTesBHRaWuCRybliBej8OhxL8vcYfUcatXTIfSyqq7jxmXn3uMhaOGI1siTfRrtvrvKvCBbzJiHh94QKVsqUynAQkQISIBlge0EYftCZnL5bakOG10SDGRISgBELTuSuSedudXigHaa]] )


end
