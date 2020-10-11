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

    
    spec:RegisterPack( "Frost Mage", 20201011, [[diumTaqiaGhrPG2eankkcNcLuVcqMLsIBbaPAxc(LsPHrr6yaQLbGEgkjtJsHUgkr2gkr9nucmouc6CaqSoaiX8qj09uQ2NssheasAHkfpeas5IaqvBKsbCsaOYkPuDtkfODQK6NaqPNkXuvI2Ru)fvdgrhw0Ir4XGMSqxgAZe9zGA0aPttA1aqXRPiA2eUnk2nv)wLHtjhNsrlxvphPPR46uy7kHVJsnEaqNhiwpLsZNIA)s6g4EzxI5G9AaAkanfytbg4aWSawXkwbWUmGyHDXkHMmbJDXtgSl2a)rNkPnycg7IvcI4YyVSl0Z4HyxaDglkakB3cwhqnicWJzlvzme5ONd)uoBPkdCBximuXaGZBIUeZb71a0uaAkWMcmWDjngqVVlfLbaTUaQgJO3eDjIuyxSHvsBWemwjTb(Jov72Wkjaw4Ce4xjbg4vQKa0uaAAxekDO9YUGuk6qK2l71a3l7sch98Ua2i)OMo)K80w8Vb0UGEsiWyVPNEna7LDjHJEExKh0GIrEAl(6GCcmz6c6jHaJ9ME61SQx2Leo65DHbzUhe(j5cdOg5XhtgAxqpjeyS30tV2g7LDjHJEExie3f5NKpGIC0rgq6c6jHaJ9ME61SuVSljC0Z7ILXRsquhmNqK0PlONecm2B6PxZY9YUKWrpVlVAzjqU6CQvcXUGEsiWyVPNEnlOx2f0tcbg7nDjHJEExGNdrF(CWixksgSlc1rom2fwUNEnlSx2f0tcbg7nDb(6GVMDzYhmobqXumGgSGtLC1kjl00kPzZvYjFW4eaftXaAWcovswSscqtRKMnxjLkyqh(JmP60kjlwjbOPDjHJEExEmTuhmxksgK2tVgaPx2f0tcbg7nDb(6GVMDHWqkdpcnPaPuU8EigmS6sch98UmGICdN4m8ixEpe7PxdSP9YUKWrpVlSVxexGQZFKEE6qSlONecm2B6PNUerzAiMEzVg4Ezxs4ON3f4z4d(ului6c6jHaJ9ME61aSx2f0tcbg7nDjHJEExGPqWt4ONZfkD6IqPd3tgSlWiTNEnR6LDb9KqGXEtxs4ON3fyke8eo65CHsNUiu6W9Kb7csPOdrAp9ABSx2f0tcbg7nDb(6GVMDjHJUa5OJmksRKRUxjzPUKWrpVlWui4jC0Z5cLoDrO0H7jd2L8WE61SuVSlONecm2B6c81bFn7schDbYrhzuKwjzXkjl1Leo65DbMcbpHJEoxO0PlcLoCpzWUqNE61SCVSlONecm2B6sch98UatHGNWrpNlu60fHshUNmyxyUfid6tp90fRhHhdro9YEnW9YUKWrpVl5dth5QpOqGWPlONecm2B6PxdWEzxs4ON3f25Gphfid6tk6c6jHaJ9ME61SQx2Leo65DX6g98UGEsiWyVPNETn2l7sch98Ui)JoeNy6c6jHaJ9ME6Pl5H9YEnW9YUKWrpVlY)SfD(9eDb9KqGXEtp9Aa2l7sch98UqiuBTn)yxqpjeyS30tVMv9YUGEsiWyVPlWxh81SlMOs(itQU6G5SvFWNYHGQcrLCVsAAL0S5kzejmKYaB1h8PCiOQqeIhBVsY6kjGvstujTECbhmmgaoGeNtCIPsA2CLKWqkdeFQox(iAlgEmHtLeWkjHHugKQdgFk)KC5F0j8ycNk5EL00kjR7sch98Uifg)dsp9ABSx2Leo65DrHi3VfzxqpjeyS30tVML6LDjHJEExGhdoC6CptxqpjeyS30tVML7LDb9KqGXEtxGVo4RzximKYGuDW4t5NKl)JoHht4ujnBUsgrcdPmi)Zw0dpYKQtRKRwjNpxGc(OmyL0S5k5JmP6QdMZw9bFkhcQkevsaRKrKWqkdSvFWNYHGQcr4rMuDALC1k585cuWhLb7sch98UOqKlshI90Rzb9YUKWrpVlFg10ho1kFt2f0tcbg7n90RzH9YUKWrpVluqv5OoyU1Xg)UGEsiWyVPNEnasVSljC0Z7cJ()9u(j5Z9mOpDb9KqGXEtp9AGnTx2f0tcbg7nDb(6GVMD5nCuEpyma(vQaeUcvOadOnnullmwjbSso5dgNGaxGIkjlUxjf4cuujbSsgrcdPmi)Zw0dXJT3Leo65Dr(hD4(Ti7PxdmW9YUGEsiWyVPlWxh81SlVHJY7bJHOsHQLq98bHdpgM0Jb0MgQLfgRKawjH3jIhBpqyiL8OsHQLq98bHdpgM0JHhZiivsaRKegsziQuOAjupFq4WJHj9ixQpgIhBVljC0Z7IuFKtis60tVgya2l7c6jHaJ9MUaFDWxZUWKEgSGtLC1kjRmTscyLeaujFdhL3dgdWte5Y)8jG20qTSWyLeWkPjQKaGk5B4O8EWyq(iAR6G5SvpsdOnnullmwjnBUssyiLb5JOTQdMZw9inyyvjzDLeWk5B4O8EWyiQuOAjupFq4WJHj9yaTPHAzHXkjGvs4DI4X2degsjpQuOAjupFq4WJHj9y4XmcsLeWkjHHugIkfQwc1Zheo8yyspYL)rNq8y7DjHJEExYhMoYraOL4O6590RbMv9YUKWrpVliX5eNy6c6jHaJ9ME61aBJ9YUKWrpVlY)OdXjMUGEsiWyVPNE6cms7L9AG7LDb9KqGXEtxGVo4RzxONHGq9yGDshuKEKB9N1R4asa9KqGXUKWrpVlm6)3t5NKp3ZG(0tVgG9YUKWrpVlrmhqjU3XUGEsiWyVPNEnR6LDb9KqGXEtxGVo4RzxG3jIhBpOqq4lq1PHhzs1PvYvRKaZsvsaRKegsz4nCKFsU1Xg)q8y7DjHJEExEdh5NKBDSXVNETn2l7c6jHaJ9MUaFDWxZUqyiLH3Wr(j5whB8dXJT3Leo65DrHGWxGQt7PxZs9YUGEsiWyVPlWxh81SlVHJY7bJHbzSUpfC25BfqBAOwwySscyLCugSsUALeytRKawjnrL06Xf8tk5GHXGcbHVavNwjnBUskvWGo8hzs1PvswSsYktRKSUljC0Z7YOmiND(w90Rz5EzxqpjeyS30f4Rd(A2fRhxWpPKdggdkee(cuDAL0S5kPubd6WFKjvNwjzXkjRmTljC0Z7I1n6590Rzb9YUKWrpVlguKRdYq7c6jHaJ9ME61SWEzxs4ON3fcXDrU04bPlONecm2B6PxdG0l7sch98UqGpfFtQo4UGEsiWyVPNEnWM2l7sch98UiuWGouoagJiyg0NUGEsiWyVPNEnWa3l7sch98Ui1hje3f7c6jHaJ9ME61adWEzxs4ON3L0HiD(uWHPq0f0tcbg7n90RbMv9YUKWrpVlejy(j5ZRqts7c6jHaJ9ME6Pl0Px2RbUx2f0tcbg7nDb(6GVMDXevYhzs1vhmNT6d(uoeuviQK7vstRKMnxjJiHHugyR(GpLdbvfIq8y7vswxjbSsAIkP1Jl4GHXaWbK4CItmvsZMRKegszG4t15YhrBXWJjCQKawjnrL06XfCWWya4WNrn9HtTY3KvsZMRKwpUGdggdahalsOMco1snjwjnBUsA94coyymaCq(hDioXujnBUsAIkzejmKYaJ()9u(j5Z9mOpbdRkPzZvscdPmGaqR0JyKBDd6JMIWJjCQKMnxjjmKYG8r0w1bZzREKgmSQKSUscyLKWqkds1bJpLFsU8p6eEmHtLCVsAALK1vsw3Leo65Drkm(hKE61aSx2Leo65Dr(NTOZVNOlONecm2B6PxZQEzxqpjeyS30f4Rd(A2fcdPmiFeTvDW8pvpyyvjnBUsMWrxGC0rgfPvYv3RKSQsA2CLmHJUa5OJmksRKRUxjbyLeWkjaOs(gokVhmgGNiYL)5taTPHAzHXUKWrpVlec1wBZp2tV2g7LDb9KqGXEtxGVo4RzxEKjvxDWC2Qp4t5qqvHOsUxjbUscyLmIegszGT6d(uoeuvicpYKQt7sch98U8ji8tYL)rNE61SuVSlONecm2B6c81bFn7YJmP6QdMZw9bFkhcQkevsaRKrKWqkdSvFWNYHGQcr4rMuDALC1kjmPdFugSscuLC(Cbk4JYGDjHJEExalsOMco1snj2tVML7LDb9KqGXEtxGVo4RzxEKjvxDWC2Qp4t5qqvHOscyL8rMuD1bZzR(GpLdbvfIk5QvscdPmivhm(u(j5Y)Ot4XeovsaRKrKWqkdSvFWNYHGQcr4rMuDALC1k585cuWhLb7sch98UOqKlshI90Rzb9YUKWrpVlWJbhoDUNPlONecm2B6PxZc7LDjHJEExuiY9Br2f0tcbg7n90Rbq6LDb9KqGXEtxGVo4RzximKYG8r0w1bZzREKgmSQKawjt4Olqo6iJI0k5ELe4UKWrpVlFg10ho1kFt2tVgyt7LDb9KqGXEtxGVo4RzximKYGuDW4t5NKl)JoHht4ujnBUsgrcdPmi)Zw0dpYKQtRKRwjNpxGc(Omyxs4ON3ffICr6qSNEnWa3l7sch98UGeNtCIPlONecm2B6Pxdma7LDb9KqGXEtxGVo4RzxmrLeaujFdhL3dgdYhrBvhmNT6rAaTPHAzHXkPzZvYeo6cKJoYOiTsU6ELeGvswxjbSsAIkjHHugi(uDU8r0wm8ycNkPzZvs6ziiupgGhdroCgmQto65b0tcbgRKSUljC0Z7YNrn9HtTY3K90RbMv9YUGEsiWyVPlWxh81SljC0fihDKrrALC19kjR6sch98UqbvLJ6G5whB87PxdSn2l7c6jHaJ9MUKWrpVluqv5OoyU1Xg)UaFDWxZUyIkj9meeQhdsffr(j5eIJspgAa9KqGXkPzZvs6ziiupga)3cKR(cf895ONhqpjeySsY6kjGvstujbavYjfOpH3Wr(j5whB8dONecmwjnBUssyiLH3Wr(j5whB8dXJTxjbSscVtep2E4nCKFsU1Xg)WJmP60k5QvsGz5kjR7IqDKdJDHLnTNEnWSuVSljC0Z7cJ()9u(j5Z9mOpDb9KqGXEtp9AGz5EzxqpjeyS30f4Rd(A2L3Wr59GXa4xPcq4kuHcmG20qTSWyLeWk5KpyCccCbkQKS4ELuGlqrLeWkzejmKYG8pBrpep2Exs4ON3f5F0H73ISNEnWSGEzxqpjeyS30f4Rd(A2L3Wr59GXquPq1sOE(GWHhdt6XaAtd1YcJvsaRKW7eXJThimKsEuPq1sOE(GWHhdt6XWJzeKkjGvscdPmevkuTeQNpiC4XWKEKNpmDmep2Exs4ON3L8HPJCeaAjoQEEp9AGzH9YUGEsiWyVPlWxh81SlVHJY7bJHOsHQLq98bHdpgM0Jb0MgQLfgRKawjH3jIhBpqyiL8OsHQLq98bHdpgM0JHhZiivsaRKegsziQuOAjupFq4WJHj9ixQpgIhBVljC0Z7IuFKtis60tVgyaKEzxqpjeyS30f4Rd(A2fcdPmq8P6C5JOTy4XeoDjHJEExalsOMco1snj2tVgGM2l7sch98Ui)JoeNy6c6jHaJ9ME6Plm3cKb9Px2RbUx2f0tcbg7nDb(6GVMDH5wGmOpHOsN0HyLC1kjWM2Leo65DHqOUj7PxdWEzxqpjeyS30f4Rd(A2fcdPmOqKlfhsdXJT3Leo65DrHixkoK2tVMv9YUGEsiWyVPlWxh81SlmPNbl4ujxTsYktRKawjt4Olqo6iJI0k5Q7vsa2Leo65DjFy6ihbGwIJQN3tV2g7LDjHJEExK6JCcrsNUGEsiWyVPNEnl1l7sch98UOqKlshIDb9KqGXEtp90txwGpvpVxdqtbOPaBkWa3f257QdM2faCmw3pySsYcQKjC0ZRKcLo0q1ExOwiSxZY2yxS(tQcSl2WkPnycgRK2a)rNQDByLealCoc8RKad8kvsaAkanTAVA3gwjbWdarOXGXkjbkVhRKWJHiNkjbcwDAOscGkeIwdTs6NdGoO5ZinevYeo650k55cqcv7jC0ZPbRhHhdroaTVnFy6ix9bfceov7jC0ZPbRhHhdroaTVLAWWCoNDo4ZrbYG(KIQ9eo650G1JWJHihG23ADJEE1Ech9CAW6r4XqKdq7BL)rhItmv7v72WkjaEaicngmwjXf4dsLCugSsoGIvYeo3xjvALmxKQijeyOApHJEoDhEg(Gp1cfIQ9eo65uG23ctHGNWrpNlu6SINm4omsR2t4ONtbAFlmfcEch9CUqPZkEYG7iLIoePv7jC0ZPaTVfMcbpHJEoxO0zfpzW98Wvu5EchDbYrhzuKU6olvTNWrpNc0(wyke8eo65CHsNv8Kb3PZkQCpHJUa5OJmkszrwQApHJEofO9TWui4jC0Z5cLoR4jdUZClqg0NQ9Q9eo650qE4U8pBrNFpr1Ech9CAipeO9Tec1wBZpwTNWrpNgYdbAFRuy8piROYDt8itQU6G5SvFWNYHGQcXUPMnhrcdPmWw9bFkhcQkeH4X2znGMW6XfCWWya4asCoXjgZMjmKYaXNQZLpI2IHht4aiHHugKQdgFk)KC5F0j8ycNDtzD1Ech9CAipeO9Tke5(TiR2t4ONtd5HaTVfEm4WPZ9mv7jC0ZPH8qG23QqKlshIROYDcdPmivhm(u(j5Y)Ot4XeoMnhrcdPmi)Zw0dpYKQtxD(Cbk4JYGMn)itQU6G5SvFWNYHGQcbGrKWqkdSvFWNYHGQcr4rMuD6QZNlqbFugSApHJEonKhc0(2pJA6dNALVjR2t4ONtd5HaTVLcQkh1bZTo24xTNWrpNgYdbAFlJ()9u(j5Z9mOpv7jC0ZPH8qG23k)JoC)wKROY93Wr59GXa4xPcq4kuHcmG20qTSWiGt(GXjiWfOGf3f4cuayejmKYG8pBrpep2E1Ech9CAipeO9Ts9roHiPZkQC)nCuEpymevkuTeQNpiC4XWKEmG20qTSWiGW7eXJThimKsEuPq1sOE(GWHhdt6XWJzeeajmKYquPq1sOE(GWHhdt6rUuFmep2E1Ech9CAipeO9T5dth5ia0sCu98vu5ot6zWcoRYktbea8gokVhmgGNiYL)5taTPHAzHranba4nCuEpymiFeTvDWC2QhPb0MgQLfgnBMWqkdYhrBvhmNT6rAWWI1a(gokVhmgIkfQwc1Zheo8yyspgqBAOwwyeq4DI4X2degsjpQuOAjupFq4WJHj9y4XmccGegsziQuOAjupFq4WJHj9ix(hDcXJTxTNWrpNgYdbAFlsCoXjMQ9eo650qEiq7BL)rhItmv7v7jC0ZPbyKUZO)FpLFs(Cpd6ZkQCNEgcc1Jb2jDqr6rU1FwVIdib0tcbgR2t4ONtdWifO9TrmhqjU3XQ9eo650amsbAF7B4i)KCRJn(ROYD4DI4X2dkee(cuDA4rMuD6QaZsasyiLH3Wr(j5whB8dXJTxTNWrpNgGrkq7Bvii8fO60vu5oHHugEdh5NKBDSXpep2E1Ech9CAagPaTVDugKZoFRvu5(B4O8EWyyqgR7tbND(wb0MgQLfgbCugCvGnfqty94c(jLCWWyqHGWxGQtnBwQGbD4pYKQtzrwzkRR2t4ONtdWifO9Tw3ONVIk3TECb)KsoyymOqq4lq1PMnlvWGo8hzs1PSiRmTApHJEonaJuG23AqrUoidTApHJEonaJuG23siUlYLgpiv7jC0ZPbyKc0(wc8P4Bs1bxTNWrpNgGrkq7BfkyqhkhaJremd6t1Ech9CAagPaTVvQpsiUlwTNWrpNgGrkq7BthI05tbhMcr1Ech9CAagPaTVLibZpjFEfAsA1E1Ech9CAaPu0HiDhSr(rnD(j5PT4FdOv7jC0ZPbKsrhIuG23kpObfJ80w81b5eyYuTNWrpNgqkfDisbAFldYCpi8tYfgqnYJpMm0Q9eo650asPOdrkq7Bje3f5NKpGIC0rgqQ2t4ONtdiLIoePaTV1Y4vjiQdMtis6uTNWrpNgqkfDisbAF7RwwcKRoNALqSApHJEonGuk6qKc0(w45q0NphmYLIKbxrOoYHXDwUApHJEonGuk6qKc0(2htl1bZLIKbPROY9jFW4eaftXaAWcoRYcn1S5jFW4eaftXaAWcoSian1SzPcg0H)itQoLfbOPv7jC0ZPbKsrhIuG23oGICdN4m8ixEpexrL7egsz4rOjfiLYL3dXGHv1Ech9CAaPu0HifO9TSVxexGQZFKEE6qSAVApHJEonWClqg0NDcH6MKNoiROYDMBbYG(eIkDshIRcSPv7jC0ZPbMBbYG(a0(wfICP4q6kQCNWqkdke5sXH0q8y7v7jC0ZPbMBbYG(a0(28HPJCeaAjoQE(kQCNj9mybNvzLPaMWrxGC0rgfPRUdWQ9eo650aZTazqFaAFRuFKtis6uTNWrpNgyUfid6dq7BviYfPdXQ9Q9eo650aD2LcJ)bzfvUBIhzs1vhmNT6d(uoeuvi2n1S5isyiLb2Qp4t5qqvHiep2oRb0ewpUGdggdahqIZjoXy2mHHugi(uDU8r0wm8ychanH1Jl4GHXaWHpJA6dNALVjnB26XfCWWya4ayrc1uWPwQjrZMTECbhmmgaoi)JoeNymB2erKWqkdm6)3t5NKp3ZG(emSmBMWqkdia0k9ig5w3G(OPi8ychZMjmKYG8r0w1bZzREKgmSynGegszqQoy8P8tYL)rNWJjC2nL1SUApHJEonqhG23k)Zw053tuTNWrpNgOdq7BjeQT2MFCfvUtyiLb5JOTQdM)P6bdlZMt4Olqo6iJI0v3zLzZjC0fihDKrr6Q7aeqaWB4O8EWyaEIix(Npb0MgQLfgR2t4ONtd0bO9TFcc)KC5F0zfvU)itQU6G5SvFWNYHGQcXoWagrcdPmWw9bFkhcQkeHhzs1Pv7jC0ZPb6a0(wWIeQPGtTutIROY9hzs1vhmNT6d(uoeuviamIegszGT6d(uoeuvicpYKQtxfM0Hpkdc085cuWhLbR2t4ONtd0bO9Tke5I0H4kQC)rMuD1bZzR(GpLdbvfcaFKjvxDWC2Qp4t5qqvHyvcdPmivhm(u(j5Y)Ot4XeoagrcdPmWw9bFkhcQkeHhzs1PRoFUaf8rzWQ9eo650aDaAFl8yWHtN7zQ2t4ONtd0bO9Tke5(TiR2t4ONtd0bO9TFg10ho1kFtUIk3jmKYG8r0w1bZzREKgmSamHJUa5OJmks3bUApHJEonqhG23QqKlshIROYDcdPmivhm(u(j5Y)Ot4XeoMnhrcdPmi)Zw0dpYKQtxD(Cbk4JYGv7jC0ZPb6a0(wK4CItmv7jC0ZPb6a0(2pJA6dNALVjxrL7Maa8gokVhmgKpI2QoyoB1J0aAtd1YcJMnNWrxGC0rgfPRUdqwdOjimKYaXNQZLpI2IHht4y2m9meeQhdWJHihodg1jh98a6jHaJSUApHJEonqhG23sbvLJ6G5whB8xrL7jC0fihDKrr6Q7SQApHJEonqhG23sbvLJ6G5whB8xrOoYHXDw20vu5UjONHGq9yqQOiYpjNqCu6XqdONecmA2m9meeQhdG)BbYvFHc((C0ZdONecmYAanbaysb6t4nCKFsU1Xg)a6jHaJMntyiLH3Wr(j5whB8dXJTdi8or8y7H3Wr(j5whB8dpYKQtxfywM1v7jC0ZPb6a0(wg9)7P8tYN7zqFQ2t4ONtd0bO9TY)Od3Vf5kQC)nCuEpyma(vQaeUcvOadOnnullmc4KpyCccCbkyXDbUafagrcdPmi)Zw0dXJTxTNWrpNgOdq7BZhMoYraOL4O65ROY93Wr59GXquPq1sOE(GWHhdt6XaAtd1YcJacVtep2EGWqk5rLcvlH65dchEmmPhdpMrqaKWqkdrLcvlH65dchEmmPh55dthdXJTxTNWrpNgOdq7BL6JCcrsNvu5(B4O8EWyiQuOAjupFq4WJHj9yaTPHAzHraH3jIhBpqyiL8OsHQLq98bHdpgM0JHhZiiasyiLHOsHQLq98bHdpgM0JCP(yiES9Q9eo650aDaAFlyrc1uWPwQjXvu5oHHugi(uDU8r0wm8ycNQ9eo650aDaAFR8p6qCIPNE6ga]] )


end
