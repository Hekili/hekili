-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindUnitBuffByID = ns.FindUnitBuffByID

local abs = math.abs


-- Conduits
-- [-] ice_bite
-- [-] icy_propulsion
-- [-] shivering_core
-- [-] unrelenting_cold


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
        freeze = {
            id = 33395,
            duration = 8,
            max_stack = 1
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
            duration = 15,
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
            duration = 6,
            type = "Magic",
            max_stack = 2,
        },

        frozen = {
            alias = { "freeze", "frost_nova", "winters_chill" },
            aliasMode = "first",
            aliasType = "debuff",
        },

        roll_the_bones = {
            alias = rtb_buff_list,
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = 30,
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


        -- Legendaries
        expanded_potential = {
            id = 327495,
            duration = 300,
            max_stack = 1
        },
        freezing_winds = {
            id = 327478,
            duration = 30,
            max_stack = 1
        },        
    } )


    spec:RegisterTotem( "rune_of_power", 609815 )


    spec:RegisterStateExpr( "fingers_of_frost_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "fingers_of_frost", function( active )
        fingers_of_frost_active = active
    end )

    spec:RegisterStateExpr( "remaining_winters_chill", function ()
        if debuff.winters_chill.down then return 0 end
        return max( 0, debuff.winters_chill.stack - ( state:IsInFlight( "ice_lance" ) and 1 or 0 ) )
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


    local brain_freeze_removed = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 116 then
                    frost_info.last_target_actual = destGUID
                end

                if spellID == 44614 then
                    frost_info.real_brain_freeze = FindUnitBuffByID( "player", 190446 ) ~= nil
                end
            elseif subtype == "SPELL_AURA_REMOVED" and spellID == 190446 then
                brain_freeze_removed = GetTime()
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return frost_info.virtual_brain_freeze
    end )


    spec:RegisterStateTable( "rotation", setmetatable( {},
    {
        __index = function( t, k )
            if k == "standard" then return true end
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


    spec:RegisterStateExpr( "bf_flurry", function () return false end )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        frost_info.last_target_virtual = frost_info.last_target_actual
        frost_info.virtual_brain_freeze = frost_info.real_brain_freeze

        -- Icicles take a second to get used.
        if now - action.ice_lance.lastCast < gcd.execute then removeBuff( "icicles" ) end
        if abs( now - brain_freeze_removed ) < 1 then applyDebuff( "target", "winters_chill" ) end

        incanters_flow.reset()
    end )

    
    Hekili:EmbedDisciplinaryCommand( spec )


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
            charges = function () return talent.shimmer.enabled and 2 or nil end,
            cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 end,
            recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 ) or nil ) end,
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
            cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
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

            velocity = 50,

            handler = function ()
                if buff.brain_freeze.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeBuff( "brain_freeze" ) end
                    frost_info.virtual_brain_freeze = true
                else
                    frost_info.virtual_brain_freeze = false
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )
            end,

            impact = function ()
                if frost_info.virtual_brain_freeze then
                    applyDebuff( "target", "winters_chill" )
                    frost_info.virtual_brain_freeze = false
                end
            end
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
            cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) end,
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

            impact = function ()
                if debuff.winters_chill.up then
                    if debuff.winters_chill.stack > 1 then debuff.winters_chill.stack = debuff.winters_chill.stack - 1
                    else removeDebuff( "target", "winters_chill" ) end
                end
            end
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
                if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
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

    
    spec:RegisterPack( "Frost Mage", 20201013, [[diK(SaqiLK0JOuqBsPQrrb5uOK6vaYSusClkfQAxc(LsLHrbogqzzkL6zOennLK4AOK02qj03qjW4qjOZrPqwhLcfZdLe3dG9PuYbPuO0cvkEiLcvUOssvTrkfWjvsQYkPuDtkfODQK6Nkjv6PsAQkr7vQ)IQbJOdlAXi8yqtwOldTzI(mqgnq1PjTALKkEnfuZMWTrXUP63QmCk54ukA5Q65inDfxNI2Us47OuJxjPCEa16PuA(uO9lXny9YUgZb71BBW2gaMbGXYGbgWswWQWIDDa2c7QvcnCcc7QNmyxTb(JofsBWee2vReyXLXEzxPN5dXUc(mwuBm72bshWnjcWJzhvzmf5ONd)uo7OkdCxxjmvXS65nrxJ5G96TnyBdaZaWyzWadyjlyBBuxtZb877AvzSX1vW1ye9MORrKc7QnSqAdMGWcPnWF0Py3gwixDHZrGFHemwUsHCBd22GUku6q7LDfPu0HiTx2RbRx21eo65DfKz(rnD(j5PT4Fd4Df9KqGXEtp96T7LDnHJEExLh0KIrEAl(6GCcmz6k6jHaJ9ME61SSx21eo65DLbzUhy(j5ctOg5XhtgAxrpjeyS30tVEv6LDnHJEExje3f5NKpGJC0rgG7k6jHaJ9ME61SAVSRjC0Z7QL5RsGvheNqK0PRONecm2B6PxZI9YUMWrpVRVAzjqU6CQvcXUIEsiWyVPNEnlOx2v0tcbg7nDnHJEExHNdrF(CWixksgSRc1rom2vwSNEnlSx2v0tcbg7nDf(6GVMDDYheobWXumGhSGtHCRcjl0GcPrJfYjFq4eahtXaEWcofswPqUTbfsJglKsfe4d)rMuDAHKvkKBBqxt4ON31htl1bXLIKbP90RTr9YUIEsiWyVPRWxh81SReMsz4rOHfiLYL3dXGPvxt4ON31bCKB6eNPh5Y7Hyp9AWmOx21eo65DL99I4cuD(J0ZthIDf9KqGXEtp901ikttX0l71G1l7Ach98UcptFWNAHcrxrpjeyS30tVE7EzxrpjeyS301eo65DfMcbpHJEoxO0PRcLoCpzWUcJ0E61SSx2v0tcbg7nDnHJEExHPqWt4ONZfkD6QqPd3tgSRiLIoeP90RxLEzxrpjeyS30v4Rd(A21eo6cKJoYOiTqUfGcjR21eo65DfMcbpHJEoxO0PRcLoCpzWUMh2tVMv7LDf9KqGXEtxHVo4Rzxt4Olqo6iJI0cjRuiz1UMWrpVRWui4jC0Z5cLoDvO0H7jd2v60tVMf7LDf9KqGXEtxt4ON3vyke8eo65CHsNUku6W9Kb7kZTazqF6PNUA9i8yiYPx2RbRx21eo65DnFy6ix9bfceoDf9KqGXEtp96T7LDnHJEExzNd(CuGmOpPORONecm2B6PxZYEzxt4ON3v5F0H4etxrpjeyS30tpDnpSx2RbRx21eo65Dv(NTOZVNORONecm2B6PxVDVSRjC0Z7kHqT128JDf9KqGXEtp9Aw2l7k6jHaJ9MUcFDWxZUAOc5JmP6QdIZw9bFkhcUkefsafsdkKgnwiJiHPugyR(GpLdbxfIq8y7fswxi3xinuH06XfCqWyaSasCoXjMcPrJfsctPmq8P6C5JOTy4XeofY9fsctPmivhe(u(j5Y)Ot4XeofsafsdkKSURjC0Z7Quy(pW90RxLEzxt4ON3vfIC)wKDf9KqGXEtp9AwTx21eo65DfEm4WPZ9mDf9KqGXEtp9AwSx2v0tcbg7nDf(6GVMDLWukds1bHpLFsU8p6eEmHtH0OXczejmLYG8pBrp8itQoTqUvHC(Cbk4JYGfsJglKpYKQRoioB1h8PCi4Qqui3xiJiHPugyR(GpLdbxfIWJmP60c5wfY5ZfOGpkd21eo65DvHixKoe7PxZc6LDnHJEEx)mQPpCQv(gURONecm2B6PxZc7LDnHJEExPGRYrDqCRJn(Df9KqGXEtp9ABuVSRjC0Z7kJ()9u(j5Z9mOpDf9KqGXEtp9AWmOx2v0tcbg7nDf(6GVMD9nDuEpima6vQayUcvOadOnnvllmwi3xiN8bHtqGlqrHKvauif4cuui3xiJiHPugK)zl6H4X27Ach98Uk)JoC)wK90RbdSEzxrpjeyS30v4Rd(A2130r59GWquPq1sOE(aZHhdt6XaAtt1YcJfY9fs4DI4X2deMsjpQuOAjupFG5WJHj9y4XmcCHCFHKWukdrLcvlH65dmhEmmPh5s9Xq8y7DnHJEExL6JCcrsNE61GTDVSRONecm2B6k81bFn7kt6zWcofYTkKS0Gc5(c5QwiFthL3dcdWte5Y)8jG20uTSWyHCFH0qfYvTq(MokVhegKpI2QoioB1J0aAtt1YcJfsJglKeMszq(iAR6G4SvpsdMwfswxi3xiFthL3dcdrLcvlH65dmhEmmPhdOnnvllmwi3xiH3jIhBpqykL8OsHQLq98bMdpgM0JHhZiWfY9fsctPmevkuTeQNpWC4XWKEKl)JoH4X27Ach98UMpmDKJRML4O6590RbJL9YUMWrpVRiX5eNy6k6jHaJ9ME61GTk9YUMWrpVRY)OdXjMUIEsiWyVPNE6kms7L9AW6LDf9KqGXEtxHVo4RzxTECb)KsoiymOqG5lq1PfsJglKsfe4d)rMuDAHKvkKS0GUMWrpVRw3ON3tVE7EzxrpjeyS30v4Rd(A2v6zkiupgyN0bfPh5w)z9koahqpjeySRjC0Z7kJ()9u(j5Z9mOp90RzzVSRjC0Z7AeZbCI7DSRONecm2B6PxVk9YUIEsiWyVPRWxh81SRW7eXJThuiW8fO60WJmP60c5wfsWy1c5(cjHPugEth5NKBDSXpep2Ext4ON3130r(j5whB87PxZQ9YUIEsiWyVPRWxh81SReMsz4nDKFsU1Xg)q8y7DnHJEExviW8fO60E61SyVSRONecm2B6k81bFn76B6O8EqyyqgR7tbND(wb0MMQLfglK7lKJYGfYTkKGzqHCFH0qfsRhxWpPKdcgdkey(cuDAH0OXcPubb(WFKjvNwizLcjlnOqY6UMWrpVRJYGC25B1tVMf0l7Ach98UAsrUoidTRONecm2B6PxZc7LDnHJEExje3f5sZh4UIEsiWyVPNETnQx21eo65DLaFk(gwDqDf9KqGXEtp9AWmOx21eo65DvOGaFO8vhZiig0NUIEsiWyVPNEnyG1l7Ach98Uk1hje3f7k6jHaJ9ME61GTDVSRjC0Z7A6qKoFk4Wui6k6jHaJ9ME61GXYEzxt4ON3vIee)K85vOHPDf9KqGXEtp90v60l71G1l7k6jHaJ9MUcFDWxZUAOc5JmP6QdIZw9bFkhcUkefsafsdkKgnwiJiHPugyR(GpLdbxfIq8y7fswxi3xinuH06XfCqWyaSasCoXjMcPrJfsctPmq8P6C5JOTy4XeofY9fsdviTECbhemgal8zutF4uR8nCH0OXcP1Jl4GGXaybqIeQPGtTudJfsJglKwpUGdcgdGfK)rhItmfsJglKgQqgrctPmWO)FpLFs(Cpd6tW0QqA0yHKWukd4QzLEeJCRBqF0ueEmHtH0OXcjHPugKpI2QoioB1J0GPvHK1fY9fsctPmivhe(u(j5Y)Ot4XeofsafsdkKSUqY6UMWrpVRsH5)a3tVE7Ezxt4ON3v5F2Io)EIUIEsiWyVPNEnl7LDf9KqGXEtxHVo4RzxjmLYG8r0w1bX)u9GPvH0OXczchDbYrhzuKwi3cqHKLfsJglKjC0fihDKrrAHClafYTlK7lKRAH8nDuEpimaprKl)ZNaAtt1YcJDnHJEExjeQT2MFSNE9Q0l7k6jHaJ9MUcFDWxZU(itQU6G4SvFWNYHGRcrHeqHeSc5(czejmLYaB1h8PCi4QqeEKjvN21eo65D9tG5NKl)Jo90Rz1EzxrpjeyS30v4Rd(A21hzs1vheNT6d(uoeCvikK7lKrKWukdSvFWNYHGRcr4rMuDAHCRcjmPdFugSqcuHC(Cbk4JYGDnHJEExbjsOMco1snm2tVMf7LDf9KqGXEtxHVo4RzxFKjvxDqC2Qp4t5qWvHOqUVq(itQU6G4SvFWNYHGRcrHCRcjHPugKQdcFk)KC5F0j8ycNc5(czejmLYaB1h8PCi4QqeEKjvNwi3QqoFUaf8rzWUMWrpVRke5I0Hyp9AwqVSRjC0Z7k8yWHtN7z6k6jHaJ9ME61SWEzxt4ON3vfIC)wKDf9KqGXEtp9ABuVSRONecm2B6k81bFn7kHPugKpI2QoioB1J0GPvHCFHmHJUa5OJmkslKakKG11eo65D9ZOM(WPw5B4E61GzqVSRONecm2B6k81bFn7kHPugKQdcFk)KC5F0j8ycNcPrJfYisykLb5F2IE4rMuDAHCRc585cuWhLb7Ach98UQqKlshI90RbdSEzxt4ON3vK4CItmDf9KqGXEtp9AW2Ux2v0tcbg7nDf(6GVMD1qfYvTq(MokVhegKpI2QoioB1J0aAtt1YcJfsJglKjC0fihDKrrAHClafYTlKSUqUVqAOcjHPugi(uDU8r0wm8ycNcPrJfs6zkiupgGhdroCgmQto65b0tcbglKSURjC0Z76Nrn9HtTY3W90RbJL9YUIEsiWyVPRWxh81SRjC0fihDKrrAHClafsw21eo65DLcUkh1bXTo243tVgSvPx2v0tcbg7nDnHJEExPGRYrDqCRJn(Df(6GVMD1qfs6zkiupgKkkI8tYjehLEm0a6jHaJfsJglK0ZuqOEma6Vfix9fkO7ZrppGEsiWyHK1fY9fsdvix1c5Kc0NWB6i)KCRJn(b0tcbglKgnwijmLYWB6i)KCRJn(H4X2lK7lKW7eXJThEth5NKBDSXp8itQoTqUvHemwSqY6Ukuh5Wyxzrd6PxdgR2l7Ach98UYO)FpLFs(Cpd6txrpjeyS30tVgmwSx2v0tcbg7nDf(6GVMD9nDuEpima6vQayUcvOadOnnvllmwi3xiN8bHtqGlqrHKvauif4cuui3xiJiHPugK)zl6H4X27Ach98Uk)JoC)wK90RbJf0l7k6jHaJ9MUcFDWxZU(MokVhegIkfQwc1Zhyo8yyspgqBAQwwySqUVqcVtep2EGWuk5rLcvlH65dmhEmmPhdpMrGlK7lKeMsziQuOAjupFG5WJHj9ipFy6yiES9UMWrpVR5dth54QzjoQEEp9AWyH9YUIEsiWyVPRWxh81SRVPJY7bHHOsHQLq98bMdpgM0Jb0MMQLfglK7lKW7eXJThimLsEuPq1sOE(aZHhdt6XWJze4c5(cjHPugIkfQwc1Zhyo8yyspYL6JH4X27Ach98Uk1h5eIKo90RbZg1l7k6jHaJ9MUcFDWxZUsykLbIpvNlFeTfdpMWPRjC0Z7kirc1uWPwQHXE61BBqVSRjC0Z7Q8p6qCIPRONecm2B6PNUYClqg0NEzVgSEzxrpjeyS30v4Rd(A2vMBbYG(eIkDshIfYTkKGzqxt4ON3vcH6gUNE929YUIEsiWyVPRWxh81SReMszqHixkoKgIhBVRjC0Z7QcrUuCiTNEnl7LDf9KqGXEtxHVo4RzxzspdwWPqUvHKLgui3xit4Olqo6iJI0c5wakKB31eo65DnFy6ihxnlXr1Z7PxVk9YUMWrpVRs9roHiPtxrpjeyS30tVMv7LDnHJEExviYfPdXUIEsiWyVPNE6PRlWNQN3R32GTnamdadSUYoFxDq0UU6XyD)GXcjlOqMWrpVqku6qdf7D16pPkWUAdlK2GjiSqAd8hDk2THfYvx4Ce4xibJLRui32GTnOyVy3gwix9xneAoySqsGY7Xcj8yiYPqsGGuNgkK2yHq0AOfs)CB8GNpJ0uuit4ONtlKNlaouSNWrpNgSEeEme5aeGD5dth5QpOqGWPypHJEony9i8yiYbia7OMmmNZzNd(CuGmOpPOypHJEony9i8yiYbia7K)rhItmf7f72Wc5Q)QHqZbJfsCb(axihLblKd4yHmHZ9fsLwiZfPkscbgk2t4ONtbaptFWNAHcrXEch9Ckqa2btHGNWrpNlu6SINmiayKwSNWrpNceGDWui4jC0Z5cLoR4jdcaPu0HiTypHJEofia7GPqWt4ONZfkDwXtgeqE4kQeqchDbYrhzuKUfawTypHJEofia7GPqWt4ONZfkDwXtgeaDwrLas4Olqo6iJIuwHvl2t4ONtbcWoyke8eo65CHsNv8KbbWClqg0NI9I9eo650qEia5F2Io)EII9eo650qEiqa2riuBTn)yXEch9CAipeia7KcZ)bEfvcWqpYKQRoioB1h8PCi4QqaWaJgJiHPugyR(GpLdbxfIq8y7SEVHSECbhemgalGeNtCIXOrctPmq8P6C5JOTy4Xeo7jmLYGuDq4t5NKl)JoHht4aWawxSNWrpNgYdbcWofIC)wKf7jC0ZPH8qGaSdEm4WPZ9mf7jC0ZPH8qGaStHixKoexrLaimLYGuDq4t5NKl)JoHht4y0yejmLYG8pBrp8itQoDR5ZfOGpkdA04JmP6QdIZw9bFkhcUke7JiHPugyR(GpLdbxfIWJmP60TMpxGc(OmyXEch9CAipeia7(mQPpCQv(gUypHJEonKhceGDuWv5OoiU1Xg)I9eo650qEiqa2XO)FpLFs(Cpd6tXEch9CAipeia7K)rhUFlYvujG30r59GWaOxPcG5kuHcmG20uTSW4(jFq4ee4cuWkae4cuSpIeMszq(NTOhIhBVypHJEonKhceGDs9roHiPZkQeWB6O8EqyiQuOAjupFG5WJHj9yaTPPAzHX9W7eXJThimLsEuPq1sOE(aZHhdt6XWJze49eMsziQuOAjupFG5WJHj9ixQpgIhBVypHJEonKhceGD5dth54QzjoQE(kQeat6zWcoBXsd2VQVPJY7bHb4jIC5F(eqBAQwwyCVHw130r59GWG8r0w1bXzREKgqBAQwwy0OrctPmiFeTvDqC2QhPbtlwV)nDuEpimevkuTeQNpWC4XWKEmG20uTSW4E4DI4X2deMsjpQuOAjupFG5WJHj9y4Xmc8EctPmevkuTeQNpWC4XWKEKl)JoH4X2l2t4ONtd5HabyhsCoXjMI9eo650qEiqa2j)JoeNyk2l2t4ONtdWifG1n65ROsawpUGFsjhemguiW8fO6uJgLkiWh(JmP6uwHLguSNWrpNgGrkqa2XO)FpLFs(Cpd6ZkQea9mfeQhdSt6GI0JCR)SEfhGdONecmwSNWrpNgGrkqa2fXCaN4Ehl2t4ONtdWifia7Eth5NKBDSXFfvcaENiES9GcbMVavNgEKjvNUfyS6EctPm8MoYpj36yJFiES9I9eo650amsbcWofcmFbQoDfvcGWukdVPJ8tYTo24hIhBVypHJEonaJuGaSBugKZoFRvujG30r59GWWGmw3Nco78TcOnnvllmUFugClWmyVHSECb)KsoiymOqG5lq1PgnkvqGp8hzs1PSclnG1f7jC0ZPbyKceGDMuKRdYql2t4ONtdWifia7ie3f5sZh4I9eo650amsbcWoc8P4By1bvSNWrpNgGrkqa2juqGpu(QJzeed6tXEch9CAagPabyNuFKqCxSypHJEonaJuGaSlDisNpfCykef7jC0ZPbyKceGDeji(j5ZRqdtl2l2t4ONtdiLIoePaazMFutNFsEAl(3aEXEch9CAaPu0Hifia7Kh0KIrEAl(6GCcmzk2t4ONtdiLIoePabyhdYCpW8tYfMqnYJpMm0I9eo650asPOdrkqa2riUlYpjFah5OJmaxSNWrpNgqkfDisbcWolZxLaRoioHiPtXEch9CAaPu0Hifia7E1YsGC15uReIf7jC0ZPbKsrhIuGaSdEoe95ZbJCPizWveQJCyealwSNWrpNgqkfDisbcWUhtl1bXLIKbPROsat(GWjaoMIb8GfC2IfAGrJt(GWjaoMIb8GfCyLTnWOrPcc8H)itQoLv22GI9eo650asPOdrkqa2nGJCtN4m9ixEpexrLaimLYWJqdlqkLlVhIbtRI9eo650asPOdrkqa2X(ErCbQo)r65PdXI9I9eo650aZTazqFaqiu3W80bEfvcG5wGmOpHOsN0H4wGzqXEch9CAG5wGmOpabyNcrUuCiDfvcGWukdke5sXH0q8y7f7jC0ZPbMBbYG(aeGD5dth54QzjoQE(kQeat6zWcoBXsd2NWrxGC0rgfPBby7I9eo650aZTazqFacWoP(iNqK0PypHJEonWClqg0hGaStHixKoel2l2t4ONtd0bGuy(pWROsag6rMuD1bXzR(GpLdbxfcagy0yejmLYaB1h8PCi4QqeIhBN17nK1Jl4GGXaybK4CItmgnsykLbIpvNlFeTfdpMWzVHSECbhemgal8zutF4uR8nSrJwpUGdcgdGfajsOMco1snmA0O1Jl4GGXayb5F0H4eJrJgkIeMszGr))Ek)K85Eg0NGPLrJeMszaxnR0JyKBDd6JMIWJjCmAKWukdYhrBvheNT6rAW0I17jmLYGuDq4t5NKl)JoHht4aWawZ6I9eo650aDacWo5F2Io)EII9eo650aDacWocHART5hxrLaimLYG8r0w1bX)u9GPLrJjC0fihDKrr6wayPrJjC0fihDKrr6wa2E)Q(MokVhegGNiYL)5taTPPAzHXI9eo650aDacWUpbMFsU8p6SIkb8itQU6G4SvFWNYHGRcbaW2hrctPmWw9bFkhcUkeHhzs1Pf7jC0ZPb6aeGDGejutbNAPggxrLaEKjvxDqC2Qp4t5qWvHyFejmLYaB1h8PCi4QqeEKjvNUfmPdFugeO5ZfOGpkdwSNWrpNgOdqa2PqKlshIROsapYKQRoioB1h8PCi4QqS)rMuD1bXzR(GpLdbxfITimLYGuDq4t5NKl)JoHht4SpIeMszGT6d(uoeCvicpYKQt3A(Cbk4JYGf7jC0ZPb6aeGDWJbhoDUNPypHJEonqhGaStHi3VfzXEch9CAGoaby3Nrn9HtTY3WROsaeMszq(iAR6G4SvpsdMw7t4Olqo6iJIuaGvSNWrpNgOdqa2PqKlshIROsaeMszqQoi8P8tYL)rNWJjCmAmIeMszq(NTOhEKjvNU185cuWhLbl2t4ONtd0bia7qIZjoXuSNWrpNgOdqa29zutF4uR8n8kQeGHw130r59GWG8r0w1bXzREKgqBAQwwy0OXeo6cKJoYOiDlaBZ69gIWukdeFQox(iAlgEmHJrJ0ZuqOEmapgIC4myuNC0ZdONecmY6I9eo650aDacWok4QCuhe36yJ)kQeqchDbYrhzuKUfawwSNWrpNgOdqa2rbxLJ6G4whB8xrOoYHraSObROsagIEMcc1JbPIIi)KCcXrPhdnGEsiWOrJ0ZuqOEma6Vfix9fkO7ZrppGEsiWiR3BOvDsb6t4nDKFsU1Xg)a6jHaJgnsykLH30r(j5whB8dXJTVhENiES9WB6i)KCRJn(Hhzs1PBbglY6I9eo650aDacWog9)7P8tYN7zqFk2t4ONtd0bia7K)rhUFlYvujG30r59GWaOxPcG5kuHcmG20uTSW4(jFq4ee4cuWkae4cuSpIeMszq(NTOhIhBVypHJEonqhGaSlFy6ihxnlXr1ZxrLaEthL3dcdrLcvlH65dmhEmmPhdOnnvllmUhENiES9aHPuYJkfQwc1Zhyo8yyspgEmJaVNWukdrLcvlH65dmhEmmPh55dthdXJTxSNWrpNgOdqa2j1h5eIKoROsaVPJY7bHHOsHQLq98bMdpgM0Jb0MMQLfg3dVtep2EGWuk5rLcvlH65dmhEmmPhdpMrG3tykLHOsHQLq98bMdpgM0JCP(yiES9I9eo650aDacWoqIeQPGtTudJROsaeMszG4t15YhrBXWJjCk2t4ONtd0bia7K)rhItmDLAHWEnlUk90t3a]] )


end
