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

    
    spec:RegisterPack( "Frost Mage", 20201014, [[diK(SaqiLs4ruqPnPu1OOGCkus9kazwkjULsjPAxc(LsLHrbogqzzkL6zOennkO6AOeSnus6BuqX4qjHZPusSoLssmpucDpa2NsshuPKKwOsXdvkjLlQusvBeLe5KkLuzLuQUjkjQDQK6NkLu6PsAQkr7vQ)IQbJOdlAXi8yqtwOldTzI(mqgnq1PjTALskEnLcZMWTrXUP63QmCk54ukA5Q65inDfxNI2Us47OuJxPeDEa16PuA(uO9lXny9YUgZb71BBW2gaMbGz4bdmGLGTnl01bylSRwj0gjiSREYGDLv6p6uizLtqyxTsGfxg7LDLEMpe7k4Zyr3QSBhiDa3KiapMDuLXuKJEo8t5SJQmWDDLWufZwN3eDnMd2R32GTnamdaZWdgyalbBBW6AAoGFFxRkZwTUcUgJO3eDnIuyxnSfsw5eewizL(Jof7g2c5wlCoc8lKGXYvkKBBW2g0vHshAVSRiLIoeP9YEny9YUMWrpVRGmZpQPZpjpTf)BaVRONecm2B6PxVDVSRjC0Z7Q8GMumYtBXxhKtGjtxrpjeyS30tVML9YUMWrpVRmiZ9aZpjxyc1ip(yYq7k6jHaJ9ME61gEVSRjC0Z7kH4Ui)K8bCKJoYaCxrpjeyS30tVMf6LDnHJEExTmFvcS6G4eIKoDf9KqGXEtp9AwTx21eo65D9vllbYvNtTsi2v0tcbg7n90Rnm9YUIEsiWyVPRjC0Z7k8Ci6ZNdg5srYGDvOoYHXUYQ90Rzf9YUIEsiWyVPRWxh81SRt(GWjaoMIb8GfCkKRwizfguinASqo5dcNa4ykgWdwWPqYIfYTnOqA0yHuQGaF4pYKQtlKSyHCBd6Ach98U(yAPoiUuKmiTNE9wPx2v0tcbg7nDf(6GVMDLWukdpcTHaPuU8EigmT6Ach98UoGJCtN4m9ixEpe7PxdMb9YUMWrpVRSVxexGQZFKEE6qSRONecm2B6PNUgrzAkMEzVgSEzxt4ON3v4z6d(ului6k6jHaJ9ME61B3l7k6jHaJ9MUMWrpVRWui4jC0Z5cLoDvO0H7jd2vyK2tVML9YUIEsiWyVPRjC0Z7kmfcEch9CUqPtxfkD4EYGDfPu0HiTNETH3l7k6jHaJ9MUcFDWxZUMWrxGC0rgfPfYvbuizHUMWrpVRWui4jC0Z5cLoDvO0H7jd218WE61SqVSRONecm2B6k81bFn7AchDbYrhzuKwizXcjl01eo65DfMcbpHJEoxO0PRcLoCpzWUsNE61SAVSRONecm2B6Ach98UctHGNWrpNlu60vHshUNmyxzUfid6tp90vRhHhdro9YEny9YUMWrpVR5dth5QpOqGWPRONecm2B6PxVDVSRjC0Z7k7CWNJcKb9jfDf9KqGXEtp9Aw2l7Ach98Uk)JoeNy6k6jHaJ9ME6PR5H9YEny9YUMWrpVRY)SfD(9eDf9KqGXEtp96T7LDnHJEExjeQT2MFSRONecm2B6PxZYEzxrpjeyS30v4Rd(A2vdviFKjvxDqC2Qp4t5qWvHOqcOqAqH0OXczejmLYaB1h8PCi4QqeIhBVqY6c5(cPHkKwpUGdcgdGfqIZjoXuinASqsykLbIpvNlFeTfdpMWPqUVqsykLbP6GWNYpjx(hDcpMWPqcOqAqHK1DnHJEExLcZ)bUNETH3l7Ach98UQqK73ISRONecm2B6PxZc9YUMWrpVRWJbhoDUNPRONecm2B6PxZQ9YUIEsiWyVPRWxh81SReMszqQoi8P8tYL)rNWJjCkKgnwiJiHPugK)zl6Hhzs1PfYvlKZNlqbFugSqA0yH8rMuD1bXzR(GpLdbxfIc5(czejmLYaB1h8PCi4QqeEKjvNwixTqoFUaf8rzWUMWrpVRke5I0Hyp9AdtVSRjC0Z76Nrn9HtTY3gDf9KqGXEtp9AwrVSRjC0Z7kfCvoQdIBDSXVRONecm2B6PxVv6LDnHJEExz0)VNYpjFUNb9PRONecm2B6PxdMb9YUIEsiWyVPRWxh81SRVPJY7bHbqVsfaZvOcfyaTPPAzHXc5(c5KpiCccCbkkKSiGcPaxGIc5(czejmLYG8pBrpep2Ext4ON3v5F0H73ISNEnyG1l7k6jHaJ9MUcFDWxZU(MokVhegIkfQwc1Zhyo8yyspgqBAQwwySqUVqcVtep2EGWuk5rLcvlH65dmhEmmPhdpMrGlK7lKeMsziQuOAjupFG5WJHj9ixQpgIhBVRjC0Z7QuFKtis60tVgST7LDf9KqGXEtxHVo4RzxzspdwWPqUAHKLgui3xi3Ic5B6O8EqyaEIix(Npb0MMQLfglK7lKgQqUffY30r59GWG8r0w1bXzREKgqBAQwwySqA0yHKWukdYhrBvheNT6rAW0QqY6c5(c5B6O8EqyiQuOAjupFG5WJHj9yaTPPAzHXc5(cj8or8y7bctPKhvkuTeQNpWC4XWKEm8ygbUqUVqsykLHOsHQLq98bMdpgM0JC5F0jep2Ext4ON318HPJCClTehvpVNEnySSx21eo65DfjoN4etxrpjeyS30tVgmdVx21eo65Dv(hDioX0v0tcbg7n90txHrAVSxdwVSRONecm2B6k81bFn7Q1Jl4NuYbbJbfcmFbQoTqA0yHuQGaF4pYKQtlKSyHKLg01eo65D16g98E61B3l7k6jHaJ9MUcFDWxZUsptbH6Xa7KoOi9i36pRxXb4a6jHaJDnHJEExz0)VNYpjFUNb9PNEnl7LDnHJEExJyoGtCVJDf9KqGXEtp9AdVx2v0tcbg7nDf(6GVMDfENiES9GcbMVavNgEKjvNwixTqcglui3xijmLYWB6i)KCRJn(H4X27Ach98U(MoYpj36yJFp9AwOx2v0tcbg7nDf(6GVMDLWukdVPJ8tYTo24hIhBVRjC0Z7QcbMVavN2tVMv7LDf9KqGXEtxHVo4RzxFthL3dcddYyDFk4SZ3kG20uTSWyHCFHCugSqUAHemdkK7lKgQqA94c(jLCqWyqHaZxGQtlKgnwiLkiWh(JmP60cjlwizPbfsw31eo65DDugKZoFRE61gMEzxt4ON3vtkY1bzODf9KqGXEtp9AwrVSRjC0Z7kH4UixA(a3v0tcbg7n90R3k9YUMWrpVRe4tX3gQdQRONecm2B6PxdMb9YUMWrpVRcfe4dLV1ygbXG(0v0tcbg7n90RbdSEzxt4ON3vP(iH4UyxrpjeyS30tVgST7LDnHJEExthI05tbhMcrxrpjeyS30tVgmw2l7Ach98UsKG4NKpVcTbTRONecm2B6PNUsNEzVgSEzxrpjeyS30v4Rd(A2vdviFKjvxDqC2Qp4t5qWvHOqcOqAqH0OXczejmLYaB1h8PCi4QqeIhBVqY6c5(cPHkKwpUGdcgdGfqIZjoXuinASqsykLbIpvNlFeTfdpMWPqUVqAOcP1Jl4GGXayHpJA6dNALVnkKgnwiTECbhemgalasKqnfCQLAdSqA0yH06XfCqWyaSG8p6qCIPqA0yH0qfYisykLbg9)7P8tYN7zqFcMwfsJglKeMsza3sR0JyKBDd6JMIWJjCkKgnwijmLYG8r0w1bXzREKgmTkKSUqUVqsykLbP6GWNYpjx(hDcpMWPqcOqAqHK1fsw31eo65Dvkm)h4E61B3l7Ach98Uk)Zw053t0v0tcbg7n90RzzVSRONecm2B6k81bFn7kHPugKpI2Qoi(NQhmTkKgnwit4Olqo6iJI0c5QakKSSqA0yHmHJUa5OJmkslKRcOqUDHCFHClkKVPJY7bHb4jIC5F(eqBAQwwySRjC0Z7kHqT128J90Rn8EzxrpjeyS30v4Rd(A21hzs1vheNT6d(uoeCvikKakKGvi3xiJiHPugyR(GpLdbxfIWJmP60UMWrpVRFcm)KC5F0PNEnl0l7k6jHaJ9MUcFDWxZU(itQU6G4SvFWNYHGRcrHCFHmIeMszGT6d(uoeCvicpYKQtlKRwiHjD4JYGfsGkKZNlqbFugSRjC0Z7kirc1uWPwQnWE61SAVSRONecm2B6k81bFn76JmP6QdIZw9bFkhcUkefY9fYhzs1vheNT6d(uoeCvikKRwijmLYGuDq4t5NKl)JoHht4ui3xiJiHPugyR(GpLdbxfIWJmP60c5QfY5ZfOGpkd21eo65DvHixKoe7PxBy6LDnHJEExHhdoC6CptxrpjeyS30tVMv0l7Ach98UQqK73ISRONecm2B6PxVv6LDf9KqGXEtxHVo4RzxjmLYG8r0w1bXzREKgmTkK7lKjC0fihDKrrAHeqHeSUMWrpVRFg10ho1kFB0tVgmd6LDf9KqGXEtxHVo4RzxjmLYGuDq4t5NKl)JoHht4uinASqgrctPmi)Zw0dpYKQtlKRwiNpxGc(Omyxt4ON3vfICr6qSNEnyG1l7Ach98UIeNtCIPRONecm2B6Pxd229YUIEsiWyVPRWxh81SRgQqUffY30r59GWG8r0w1bXzREKgqBAQwwySqA0yHmHJUa5OJmkslKRcOqUDHK1fY9fsdvijmLYaXNQZLpI2IHht4uinASqsptbH6Xa8yiYHZGrDYrppGEsiWyHK1DnHJEEx)mQPpCQv(2ONEnySSx2v0tcbg7nDf(6GVMDnHJUa5OJmkslKRcOqYYUMWrpVRuWv5OoiU1Xg)E61Gz49YUIEsiWyVPRjC0Z7kfCvoQdIBDSXVRWxh81SRgQqsptbH6XGurrKFsoH4O0JHgqpjeySqA0yHKEMcc1Jbq)Ta5QVqbDFo65b0tcbglKSUqUVqAOc5wuiNuG(eEth5NKBDSXpGEsiWyH0OXcjHPugEth5NKBDSXpep2EHCFHeENiES9WB6i)KCRJn(Hhzs1PfYvlKGXQfsw3vH6ihg7kRAqp9AWyHEzxt4ON3vg9)7P8tYN7zqF6k6jHaJ9ME61GXQ9YUIEsiWyVPRWxh81SRVPJY7bHbqVsfaZvOcfyaTPPAzHXc5(c5KpiCccCbkkKSiGcPaxGIc5(czejmLYG8pBrpep2Ext4ON3v5F0H73ISNEnygMEzxrpjeyS30v4Rd(A2130r59GWquPq1sOE(aZHhdt6XaAtt1YcJfY9fs4DI4X2deMsjpQuOAjupFG5WJHj9y4XmcCHCFHKWukdrLcvlH65dmhEmmPh55dthdXJT31eo65DnFy6ih3slXr1Z7PxdgROx2v0tcbg7nDf(6GVMD9nDuEpimevkuTeQNpWC4XWKEmG20uTSWyHCFHeENiES9aHPuYJkfQwc1Zhyo8yyspgEmJaxi3xijmLYquPq1sOE(aZHhdt6rUuFmep2Ext4ON3vP(iNqK0PNEnyBLEzxrpjeyS30v4Rd(A2vctPmq8P6C5JOTy4XeoDnHJEExbjsOMco1sTb2tVEBd6LDnHJEExL)rhItmDf9KqGXEtp90vMBbYG(0l71G1l7k6jHaJ9MUcFDWxZUYClqg0NquPt6qSqUAHemd6Ach98Usiu3g90R3Ux2v0tcbg7nDf(6GVMDLWukdke5sXH0q8y7DnHJEExviYLIdP90RzzVSRONecm2B6k81bFn7kt6zWcofYvlKS0Gc5(czchDbYrhzuKwixfqHC7UMWrpVR5dth54wAjoQEEp9AdVx21eo65DvQpYjejD6k6jHaJ9ME61SqVSRjC0Z7QcrUiDi2v0tcbg7n90tpDDb(u98E92gSTbGzaySSRSZ3vheTRBDmw3pySqAykKjC0ZlKcLo0qXExPwiSxZQgExT(tQcSRg2cjRCcclKSs)rNIDdBHCRfohb(fsWy5kfYTnyBdk2l2nSfYT(TeHMdglKeO8ESqcpgICkKeii1PHc5wvieTgAH0pFRo45ZinffYeo650c55cGdf7jC0ZPbRhHhdroabyx(W0rU6dkeiCk2t4ONtdwpcpgICacWoQjdZ5C25Gphfid6tkk2t4ONtdwpcpgICacWo5F0H4etXEXUHTqU1VLi0CWyHexGpWfYrzWc5aowit4CFHuPfYCrQIKqGHI9eo65uaWZ0h8PwOquSNWrpNceGDWui4jC0Z5cLoR4jdcagPf7jC0ZPabyhmfcEch9CUqPZkEYGaqkfDisl2t4ONtbcWoyke8eo65CHsNv8KbbKhUIkbKWrxGC0rgfPRcGfk2t4ONtbcWoyke8eo65CHsNv8KbbqNvujGeo6cKJoYOiLfzHI9eo65uGaSdMcbpHJEoxO0zfpzqam3cKb9PyVypHJEonKhcq(NTOZVNOypHJEonKhceGDec1wBZpwSNWrpNgYdbcWoPW8FGxrLam0JmP6QdIZw9bFkhcUkeamWOXisykLb2Qp4t5qWvHiep2oR3BiRhxWbbJbWciX5eNymAKWukdeFQox(iAlgEmHZEctPmivhe(u(j5Y)Ot4XeoamG1f7jC0ZPH8qGaStHi3VfzXEch9CAipeia7GhdoC6CptXEch9CAipeia7uiYfPdXvujactPmivhe(u(j5Y)Ot4XeogngrctPmi)Zw0dpYKQtxD(Cbk4JYGgn(itQU6G4SvFWNYHGRcX(isykLb2Qp4t5qWvHi8itQoD15ZfOGpkdwSNWrpNgYdbcWUpJA6dNALVnk2t4ONtd5HabyhfCvoQdIBDSXVypHJEonKhceGDm6)3t5NKp3ZG(uSNWrpNgYdbcWo5F0H73ICfvc4nDuEpima6vQayUcvOadOnnvllmUFYheobbUafSiabUaf7JiHPugK)zl6H4X2l2t4ONtd5HabyNuFKtis6SIkb8MokVhegIkfQwc1Zhyo8yyspgqBAQwwyCp8or8y7bctPKhvkuTeQNpWC4XWKEm8ygbEpHPugIkfQwc1Zhyo8yyspYL6JH4X2l2t4ONtd5Habyx(W0roULwIJQNVIkbWKEgSGZQS0G9BXB6O8EqyaEIix(Npb0MMQLfg3BOT4nDuEpimiFeTvDqC2QhPb0MMQLfgnAKWukdYhrBvheNT6rAW0I17FthL3dcdrLcvlH65dmhEmmPhdOnnvllmUhENiES9aHPuYJkfQwc1Zhyo8yyspgEmJaVNWukdrLcvlH65dmhEmmPh5Y)OtiES9I9eo650qEiqa2HeNtCIPypHJEonKhceGDY)OdXjMI9I9eo650amsbyDJE(kQeG1Jl4NuYbbJbfcmFbQo1OrPcc8H)itQoLfzPbf7jC0ZPbyKceGDm6)3t5NKp3ZG(SIkbqptbH6Xa7KoOi9i36pRxXb4a6jHaJf7jC0ZPbyKceGDrmhWjU3XI9eo650amsbcWU30r(j5whB8xrLaG3jIhBpOqG5lq1PHhzs1PRcglSNWukdVPJ8tYTo24hIhBVypHJEonaJuGaStHaZxGQtxrLaimLYWB6i)KCRJn(H4X2l2t4ONtdWifia7gLb5SZ3Afvc4nDuEpimmiJ19PGZoFRaAtt1YcJ7hLbxfmd2BiRhxWpPKdcgdkey(cuDQrJsfe4d)rMuDklYsdyDXEch9CAagPabyNjf56Gm0I9eo650amsbcWocXDrU08bUypHJEonaJuGaSJaFk(2qDqf7jC0ZPbyKceGDcfe4dLV1ygbXG(uSNWrpNgGrkqa2j1hje3fl2t4ONtdWifia7shI05tbhMcrXEch9CAagPabyhrcIFs(8k0g0I9I9eo650asPOdrkaqM5h105NKN2I)nGxSNWrpNgqkfDisbcWo5bnPyKN2IVoiNatMI9eo650asPOdrkqa2XGm3dm)KCHjuJ84JjdTypHJEonGuk6qKceGDeI7I8tYhWro6idWf7jC0ZPbKsrhIuGaSZY8vjWQdItis6uSNWrpNgqkfDisbcWUxTSeixDo1kHyXEch9CAaPu0Hifia7GNdrF(CWixksgCfH6ihgbWQf7jC0ZPbKsrhIuGaS7X0sDqCPizq6kQeWKpiCcGJPyapybNvzfgy04KpiCcGJPyapybhwCBdmAuQGaF4pYKQtzXTnOypHJEonGuk6qKceGDd4i30jotpYL3dXvujactPm8i0gcKs5Y7HyW0QypHJEonGuk6qKceGDSVxexGQZFKEE6qSyVypHJEonWClqg0haec1TbpDGxrLayUfid6tiQ0jDiUkyguSNWrpNgyUfid6dqa2PqKlfhsxrLaimLYGcrUuCinep2EXEch9CAG5wGmOpabyx(W0roULwIJQNVIkbWKEgSGZQS0G9jC0fihDKrr6Qa2UypHJEonWClqg0hGaStQpYjejDk2t4ONtdm3cKb9bia7uiYfPdXI9I9eo650aDaifM)d8kQeGHEKjvxDqC2Qp4t5qWvHaGbgngrctPmWw9bFkhcUkeH4X2z9Edz94coiymawajoN4eJrJeMszG4t15YhrBXWJjC2BiRhxWbbJbWcFg10ho1kFBy0O1Jl4GGXaybqIeQPGtTuBGgnA94coiymawq(hDioXy0OHIiHPugy0)VNYpjFUNb9jyAz0iHPugWT0k9ig5w3G(OPi8ychJgjmLYG8r0w1bXzREKgmTy9EctPmivhe(u(j5Y)Ot4XeoamG1SUypHJEonqhGaSt(NTOZVNOypHJEonqhGaSJqO2AB(XvujactPmiFeTvDq8pvpyAz0ychDbYrhzuKUkawA0ychDbYrhzuKUkGT3VfVPJY7bHb4jIC5F(eqBAQwwySypHJEonqhGaS7tG5NKl)JoROsapYKQRoioB1h8PCi4QqaaS9rKWukdSvFWNYHGRcr4rMuDAXEch9CAGoabyhirc1uWPwQnWvujGhzs1vheNT6d(uoeCvi2hrctPmWw9bFkhcUkeHhzs1PRct6WhLbbA(Cbk4JYGf7jC0ZPb6aeGDke5I0H4kQeWJmP6QdIZw9bFkhcUke7FKjvxDqC2Qp4t5qWvHyvctPmivhe(u(j5Y)Ot4Xeo7JiHPugyR(GpLdbxfIWJmP60vNpxGc(OmyXEch9CAGoabyh8yWHtN7zk2t4ONtd0bia7uiY9BrwSNWrpNgOdqa29zutF4uR8TXkQeaHPugKpI2QoioB1J0GP1(eo6cKJoYOifayf7jC0ZPb6aeGDke5I0H4kQeaHPugKQdcFk)KC5F0j8ychJgJiHPugK)zl6Hhzs1PRoFUaf8rzWI9eo650aDacWoK4CItmf7jC0ZPb6aeGDFg10ho1kFBSIkbyOT4nDuEpimiFeTvDqC2QhPb0MMQLfgnAmHJUa5OJmksxfW2SEVHimLYaXNQZLpI2IHht4y0i9mfeQhdWJHihodg1jh98a6jHaJSUypHJEonqhGaSJcUkh1bXTo24VIkbKWrxGC0rgfPRcGLf7jC0ZPb6aeGDuWv5OoiU1Xg)veQJCyeaRAWkQeGHONPGq9yqQOiYpjNqCu6XqdONecmA0i9mfeQhdG(BbYvFHc6(C0ZdONecmY69gAlMuG(eEth5NKBDSXpGEsiWOrJeMsz4nDKFsU1Xg)q8y77H3jIhBp8MoYpj36yJF4rMuD6QGXQSUypHJEonqhGaSJr))Ek)K85Eg0NI9eo650aDacWo5F0H73ICfvc4nDuEpima6vQayUcvOadOnnvllmUFYheobbUafSiabUaf7JiHPugK)zl6H4X2l2t4ONtd0bia7YhMoYXT0sCu98vujG30r59GWquPq1sOE(aZHhdt6XaAtt1YcJ7H3jIhBpqykL8OsHQLq98bMdpgM0JHhZiW7jmLYquPq1sOE(aZHhdt6rE(W0Xq8y7f7jC0ZPb6aeGDs9roHiPZkQeWB6O8EqyiQuOAjupFG5WJHj9yaTPPAzHX9W7eXJThimLsEuPq1sOE(aZHhdt6XWJze49eMsziQuOAjupFG5WJHj9ixQpgIhBVypHJEonqhGaSdKiHAk4ul1g4kQeaHPugi(uDU8r0wm8ycNI9eo650aDacWo5F0H4etp90na]] )


end
