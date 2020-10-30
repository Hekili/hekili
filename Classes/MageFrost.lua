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
            duration = function () return talent.thermal_void.enabled and 30 or 20 + ( level > 55 and 3 or 0 ) end,
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
        cold_front = {
            id = 327327,
            duration = 30,
            max_stack = 15
        },
        cold_front_ready = {
            id = 327330,
            duration = 30,
            max_stack = 1
        },
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

        if prev_gcd[1].flurry and now - action.flurry.lastCast < gcd.execute and debuff.winters_chill.up then debuff.winters_chill.count = 2 end

        incanters_flow.reset()

        if Hekili.ActiveDebug then
            Hekili:Debug( "Ice Lance in-flight?  %s\nWinter's Chill Actual Stacks?  %d\nremaining_winters_chill:  %d", state:IsInFlight( "ice_lance" ) and "Yes" or "No", state.debuff.winters_chill.stack, state.remaining_winters_chill )
        end
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
            cooldown = function () return leel > 53 and 270 or 300 end,
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

                removeBuff( "cold_front_ready" )

                if legendary.cold_front.enabled then
                    addStack( "cold_front" )
                    if buff.cold_front.stack == 15 then
                        removeBuff( "cold_front" )
                        applyBuff( "cold_front_ready" )
                    end
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )
            end,

            impact = function ()
                if frost_info.virtual_brain_freeze then
                    applyDebuff( "target", "winters_chill", nil, 2 )
                    frost_info.virtual_brain_freeze = false
                end
            end,

            copy = 228354 -- ID of the Flurry impact.
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

                removeBuff( "cold_front_ready" )

                if legendary.cold_front.enabled then
                    addStack( "cold_front" )
                    if buff.cold_front.stack == 15 then
                        removeBuff( "cold_front" )
                        applyBuff( "cold_front_ready" )
                    end
                end

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

            velocity = 20,

            handler = function ()
                if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
                applyBuff( "frozen_orb" )
            end,                


            --[[ Not modeling because you can throw it off in a random direction and get no procs.  Just react.
            impact = function ()
                addStack( "fingers_of_frost", nil, 1 )
                applyDebuff( "target", "frozen_orb_snare" )
            end, ]]

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
                    if debuff.winters_chill.stack > 1 then removeDebuffStack( "target", "winters_chill", 1 )
                    else removeDebuff( "target", "winters_chill" ) end
                end
            end,

            copy = 228598
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

    
    spec:RegisterPack( "Frost Mage", 20201016, [[die(TaqiLK0JOOqBsPYOqj5uOK6vaXSusClLKs1Ue8lLsdJsPJbuTmucpJIsttjjUMsv12uQkFdLinouI4CkjfRtjPeZdLOUha7tPkhujPKwOsXdvskLlQKuLnsrbDsLKkwjLQBsrb2PsQFQKuvpvstvjAVs9xunyeDyrlgHhdAYcDzOnt0Nb0ObkNM0QvsQ0RPOQzt42Oy3u9BvgoLCCkQSCv9CKMUIRtHTRe(ok14POOZdKwpLI5tr2Ve3G3l7AmhSxZcBzHTGBl47laUzxfwklyjDDa1c7QvcnFce7QNmyxnd)JofsZGei2vReuXLXEzxPNXdXUc2mw0vlB3cuhWmicWJzlvzme5ONd)uoBPkdCBxjmuXS64nrxJ5G9AwyllSfCBbFFbWn7QS)9310ya7(UwvMvBDfmngrVj6AePWUAglKMbjqSqAg(hDk2nJfYvF4Ce4xibFFRuizHTSW2Uku6q7LDfPu0HiTx2RbVx21eo65DfOr(rnD(j5Pn4FdyDf9KqGXEtp9Aw0l7Ach98UkpObfJ80g81b5eyY0v0tcbg7n90RnBVSRjC0Z7kdYCpO8tYfgqnYJpMm0UIEsiWyVPNE9Q0l7Ach98UsiUlYpjFad5OJmG2v0tcbg7n90R3FVSRjC0Z7QLXRsqvhiNqK0PRONecm2B6PxVVEzxt4ON31xTSeixDo1kHyxrpjeyS30tVML2l7k6jHaJ9MUMWrpVRWZHOpFoyKlfjd2vH6ihg76(6PxZs6LDf9KqGXEtxHVo4RzxN8bItammfdybl4ui3RqYsSTqAYuHCYhiobWWumGfSGtHKLlKSW2cPjtfsPceSH)itQoTqYYfswyBxt4ON31htl1bYLIKbP90Rxn9YUIEsiWyVPRWxh81SRegsz4rO5fiLYL3dXGHvxt4ON31bmKB4eNHh5Y7Hyp9AWTTx21eo65DL99I4cuD(J0ZthIDf9KqGXEtp901iktdX0l71G3l7Ach98UcpdFWNAHcrxrpjeyS30tVMf9YUIEsiWyVPRjC0Z7kmfcEch9CUqPtxfkD4EYGDfgP90RnBVSRONecm2B6Ach98UctHGNWrpNlu60vHshUNmyxrkfDis7PxVk9YUIEsiWyVPRWxh81SRjC0fihDKrrAHCpafY931eo65DfMcbpHJEoxO0PRcLoCpzWUMh2tVE)9YUIEsiWyVPRWxh81SRjC0fihDKrrAHKLlK7VRjC0Z7kmfcEch9CUqPtxfkD4EYGDLo90R3xVSRONecm2B6Ach98UctHGNWrpNlu60vHshUNmyxzUfid6tp90vRhHhdro9YEn49YUMWrpVR5dth5QpOqGWPRONecm2B6PxZIEzxt4ON3v25Gphfid6tk6k6jHaJ9ME61MTx21eo65Dv(hDioX0v0tcbg7n90txZd7L9AW7LDnHJEExL)zd687j6k6jHaJ9ME61SOx21eo65DLqO2yt(XUIEsiWyVPNETz7LDf9KqGXEtxHVo4RzxzvH8rMuD1bYzR(GpLdbtfIcjGcPTfstMkKrKWqkdSvFWNYHGPcriES9cjRlK7kKSQqA94coqymaEajoN4etH0KPcjHHugi(uDU8r0gm8ycNc5UcjHHugKQdeFk)KC5F0j8ycNcjGcPTfsw31eo65Dvkm(h0E61RsVSRjC0Z7QcrUFlYUIEsiWyVPNE9(7LDnHJEExHhdoC6CptxrpjeyS30tVEF9YUIEsiWyVPRWxh81SRegszqQoq8P8tYL)rNWJjCkKMmviJiHHugK)zd6Hhzs1PfY9kKZNlqbFugSqAYuH8rMuD1bYzR(GpLdbtfIc5UczejmKYaB1h8PCiyQqeEKjvNwi3RqoFUaf8rzWUMWrpVRke5I0Hyp9AwAVSRjC0Z76Nrn9HtTY38Df9KqGXEtp9AwsVSRjC0Z7kfmvoQdKBDSXVRONecm2B6PxVA6LDnHJEExz0)VNYpjFUNb9PRONecm2B6PxdUT9YUIEsiWyVPRWxh81SRVHJY7bIbGVsfGYvOcfyanNHAzHXc5Uc5KpqCccCbkkKSmGcPaxGIc5UczejmKYG8pBqpep2Ext4ON3v5F0H73ISNEn4G3l7k6jHaJ9MUcFDWxZU(gokVhigIkfQwc1Zhuo8yyspgqZzOwwySqURqcVtep2EGWqk5rLcvlH65dkhEmmPhdpMrqlK7kKegsziQuOAjupFq5WJHj9ixQpgIhBVRjC0Z7QuFKtis60tVgCw0l7k6jHaJ9MUcFDWxZUYKEgSGtHCVcPzTTqURqUQfY3Wr59aXa8erU8pFcO5mullmwi3vizvHCvlKVHJY7bIb5JOnQdKZw9inGMZqTSWyH0KPcjHHugKpI2OoqoB1J0GHvHK1fYDfY3Wr59aXquPq1sOE(GYHhdt6XaAod1YcJfYDfs4DI4X2degsjpQuOAjupFq5WJHj9y4XmcAHCxHKWqkdrLcvlH65dkhEmmPh5Y)OtiES9UMWrpVR5dth5OzAjoQEEp9AWnBVSRjC0Z7ksCoXjMUIEsiWyVPNEn4RsVSRONecm2B6k81bFn76B4O8EGyaOiHAk4YpbYG(qdO5mullmwi3viNuG(eOwcDg1bYvigqpjeySRjC0Z7QcrUiDi2tVg893l7Ach98Uk)JoeNy6k6jHaJ9ME6PRWiTx2RbVx2v0tcbg7nDf(6GVMD16Xf8tk5aHXGcbLVavNwinzQqkvGGn8hzs1PfswUqAwB7Ach98UADJEEp9Aw0l7k6jHaJ9MUcFDWxZUspdbH6Xa7KoOi9i36pRxXb0a6jHaJDnHJEExz0)VNYpjFUNb9PNETz7LDnHJEExJyoGrCVJDf9KqGXEtp96vPx2v0tcbg7nDf(6GVMDfENiES9GcbLVavNgEKjvNwi3Rqc((lK7kKegsz4nCKFsU1Xg)q8y7DnHJEExFdh5NKBDSXVNE9(7LDf9KqGXEtxHVo4RzxjmKYWB4i)KCRJn(H4X27Ach98UQqq5lq1P90R3xVSRONecm2B6k81bFn76B4O8EGyyqgR7tbND(wb0CgQLfglK7kKSQqspXvinzQqsyiLb0mblnOJEEWWQqY6c5UcjRkKwpUGFsjhimguiO8fO60cPjtfsPceSH)itQoTqYYfsZABHK1DnHJEExhLb5SZ3QNEnlTx21eo65D1GICDqgAxrpjeyS30tVML0l7Ach98UsiUlYLgpODf9KqGXEtp96vtVSRjC0Z7kb(u8nV6a7k6jHaJ9ME61GBBVSRjC0Z7Qqbc2q5RUgrGmOpDf9KqGXEtp9AWbVx21eo65DvQpsiUl2v0tcbg7n90RbNf9YUMWrpVRPdr68PGdtHORONecm2B6PxdUz7LDnHJEExjsG8tYNxHMN2v0tcbg7n90txPtVSxdEVSRONecm2B6k81bFn7kRkKpYKQRoqoB1h8PCiyQquibuiTTqAYuHmIegszGT6d(uoemvicXJTxizDHCxHKvfsRhxWbcJbWdiX5eNykKMmvijmKYaXNQZLpI2GHht4ui3vizvH06XfCGWya8WNrn9HtTY38fstMkKwpUGdegdGhaksOMco1snpwinzQqA94coqymaEq(hDioXuinzQqYQczejmKYaJ()9u(j5Z9mOpbdRcPjtfscdPmGMPv6rmYTUb9rtr4XeofstMkKegszq(iAJ6a5Svpsdgwfswxi3vijmKYGuDG4t5NKl)JoHht4uibuiTTqY6cjR7Ach98Ukfg)dAp9Aw0l7Ach98Uk)Zg053t0v0tcbg7n90RnBVSRONecm2B6k81bFn7kHHugKpI2Ooq(NQhmSkKMmvit4Olqo6iJI0c5EakKMTqAYuHmHJUa5OJmkslK7bOqYIc5Uc5QwiFdhL3dedWte5Y)8jGMZqTSWyxt4ON3vcHAJn5h7PxVk9YUIEsiWyVPRWxh81SRpYKQRoqoB1h8PCiyQquibuibVqURqgrcdPmWw9bFkhcMkeHhzs1PDnHJEEx)eu(j5Y)Otp9693l7k6jHaJ9MUcFDWxZU(itQU6a5SvFWNYHGPcrHCxHmIegszGT6d(uoemvicpYKQtlK7viHjD4JYGfsqkKZNlqbFugSRjC0Z7kqrc1uWPwQ5XE617Rx2v0tcbg7nDf(6GVMD9rMuD1bYzR(GpLdbtfIc5Uc5JmP6QdKZw9bFkhcMkefY9kKegszqQoq8P8tYL)rNWJjCkK7kKrKWqkdSvFWNYHGPcr4rMuDAHCVc585cuWhLb7Ach98UQqKlshI90RzP9YUMWrpVRWJbhoDUNPRONecm2B6PxZs6LDnHJEExviY9Br2v0tcbg7n90Rxn9YUIEsiWyVPRWxh81SRegszq(iAJ6a5SvpsdgwfYDfYeo6cKJoYOiTqcOqcExt4ON31pJA6dNALV57PxdUT9YUIEsiWyVPRWxh81SRegszqQoq8P8tYL)rNWJjCkKMmviJiHHugK)zd6Hhzs1PfY9kKZNlqbFugSRjC0Z7QcrUiDi2tVgCW7LDnHJEExrIZjoX0v0tcbg7n90RbNf9YUIEsiWyVPRWxh81SRSQqUQfY3Wr59aXG8r0g1bYzREKgqZzOwwySqAYuHmHJUa5OJmkslK7bOqYIcjRlK7kKSQqsyiLbIpvNlFeTbdpMWPqAYuHKEgcc1Jb4XqKdNbJ6KJEEa9KqGXcjR7Ach98U(zutF4uR8nFp9AWnBVSRONecm2B6k81bFn7AchDbYrhzuKwi3dqH0SDnHJEExPGPYrDGCRJn(90RbFv6LDf9KqGXEtxt4ON3vkyQCuhi36yJFxHVo4RzxzvHKEgcc1JbPIIi)KCcXrPhdnGEsiWyH0KPcj9meeQhda)BbYvFHc8(C0ZdONecmwizDHCxHKvfYvTqoPa9j8goYpj36yJFa9KqGXcPjtfscdPm8goYpj36yJFiES9c5Ucj8or8y7H3Wr(j5whB8dpYKQtlK7vibFFfsw3vH6ihg76(STNEn47Vx21eo65DLr))Ek)K85Eg0NUIEsiWyVPNEn47Rx2v0tcbg7nDf(6GVMD9nCuEpqma8vQauUcvOadO5mullmwi3viN8bItqGlqrHKLbuif4cuui3viJiHHugK)zd6H4X27Ach98Uk)JoC)wK90RbNL2l7k6jHaJ9MUcFDWxZU(gokVhigIkfQwc1Zhuo8yyspgqZzOwwySqURqcVtep2EGWqk5rLcvlH65dkhEmmPhdpMrqlK7kKegsziQuOAjupFq5WJHj9ipFy6yiES9UMWrpVR5dth5OzAjoQEEp9AWzj9YUIEsiWyVPRWxh81SRVHJY7bIHOsHQLq98bLdpgM0Jb0CgQLfglK7kKW7eXJThimKsEuPq1sOE(GYHhdt6XWJze0c5UcjHHugIkfQwc1Zhuo8yyspYL6JH4X27Ach98Uk1h5eIKo90RbF10l7k6jHaJ9MUcFDWxZUsyiLbIpvNlFeTbdpMWPRjC0Z7kqrc1uWPwQ5XE61SW2Ezxt4ON3v5F0H4etxrpjeyS30tpDL5wGmOp9YEn49YUIEsiWyVPRWxh81SRm3cKb9jev6KoelK7vib32UMWrpVRec1nFp9Aw0l7k6jHaJ9MUcFDWxZUsyiLbfICP4qAiES9UMWrpVRke5sXH0E61MTx2v0tcbg7nDf(6GVMDLj9mybNc5EfsZABHCxHmHJUa5OJmkslK7bOqYIUMWrpVR5dth5OzAjoQEEp96vPx21eo65DvQpYjejD6k6jHaJ9ME617Vx21eo65DvHixKoe7k6jHaJ9ME6PNUUaFQEEVMf2YcBb3wWxLUYoFxDG0UU6WyD)GXcjlTqMWrpVqku6qdf7DLAHWE9(wLUA9NufyxnJfsZGeiwind)Jof7MXc5QpCoc8lKGVVvkKSWwwyBXEXUzSqU6zMi0yWyHKaL3Jfs4XqKtHKabQonuixTcHO1qlK(5R2blFgPHOqMWrpNwipxaAOypHJEony9i8yiYbeaBZhMoYvFqHaHtXEch9CAW6r4XqKdia2snyyoNZoh85OazqFsrXEch9CAW6r4XqKdia2k)JoeNyk2l2nJfYvpZeHgdglK4c8bTqokdwihWWczcN7lKkTqMlsvKecmuSNWrpNcaEg(Gp1cfII9eo65uqaSfMcbpHJEoxO0zfpzqaWiTypHJEofeaBHPqWt4ONZfkDwXtgeasPOdrAXEch9Ckia2ctHGNWrpNlu6SINmiG8WvujGeo6cKJoYOiDpa7VypHJEofeaBHPqWt4ONZfkDwXtgeaDwrLas4Olqo6iJIuwE)f7jC0ZPGaylmfcEch9CUqPZkEYGayUfid6tXEXEch9CAipeG8pBqNFprXEch9CAipeeaBjeQn2KFSypHJEonKhccGTsHX)GUIkbWQhzs1vhiNT6d(uoemviayRjtrKWqkdSvFWNYHGPcriESDwVJvwpUGdegdGhqIZjoXyYeHHugi(uDU8r0gm8ycNDegszqQoq8P8tYL)rNWJjCaylRl2t4ONtd5HGayRcrUFlYI9eo650qEiia2cpgC405EMI9eo650qEiia2QqKlshIROsaegszqQoq8P8tYL)rNWJjCmzkIegszq(NnOhEKjvNU385cuWhLbnz6rMuD1bYzR(GpLdbtfIDrKWqkdSvFWNYHGPcr4rMuD6EZNlqbFugSypHJEonKhccGTFg10ho1kFZxSNWrpNgYdbbWwkyQCuhi36yJFXEch9CAipeeaBz0)VNYpjFUNb9PypHJEonKhccGTY)Od3Vf5kQeWB4O8EGya4RubOCfQqbgqZzOwwyC3KpqCccCbkyzacCbk2frcdPmi)Zg0dXJTxSNWrpNgYdbbWwP(iNqK0zfvc4nCuEpqmevkuTeQNpOC4XWKEmGMZqTSW4o4DI4X2degsjpQuOAjupFq5WJHj9y4Xmc6ocdPmevkuTeQNpOC4XWKEKl1hdXJTxSNWrpNgYdbbW28HPJC0mTehvpFfvcGj9mybN9mRT7w13Wr59aXa8erU8pFcO5mullmUJvR6B4O8EGyq(iAJ6a5SvpsdO5mullmAYeHHugKpI2OoqoB1J0GHfR39gokVhigIkfQwc1Zhuo8yyspgqZzOwwyCh8or8y7bcdPKhvkuTeQNpOC4XWKEm8ygbDhHHugIkfQwc1Zhuo8yyspYL)rNq8y7f7jC0ZPH8qqaSfjoN4etXEch9CAipeeaBviYfPdXvujG3Wr59aXaqrc1uWLFcKb9HgqZzOwwyC3Kc0Na1sOZOoqUcXa6jHaJf7jC0ZPH8qqaSv(hDioXuSxSNWrpNgGrkaRB0ZxrLaSECb)KsoqymOqq5lq1PMmjvGGn8hzs1PSSzTTypHJEonaJuqaSLr))Ek)K85Eg0Nvuja6ziiupgyN0bfPh5w)z9koGgqpjeySypHJEonaJuqaSnI5agX9owSNWrpNgGrkia2(goYpj36yJ)kQea8or8y7bfckFbQon8itQoDpW3)ocdPm8goYpj36yJFiES9I9eo650amsbbWwfckFbQoDfvcGWqkdVHJ8tYTo24hIhBVypHJEonaJuqaSDugKZoFRvujG3Wr59aXWGmw3Nco78TcO5mullmUJv0tCMmryiLb0mblnOJEEWWI17yL1Jl4NuYbcJbfckFbQo1KjPceSH)itQoLLnRTSUypHJEonaJuqaS1GICDqgAXEch9CAagPGaylH4UixA8GwSNWrpNgGrkia2sGpfFZRoWI9eo650amsbbWwHceSHYxDnIazqFk2t4ONtdWifeaBL6JeI7If7jC0ZPbyKccGTPdr68PGdtHOypHJEonaJuqaSLibYpjFEfAEAXEXEch9CAaPu0HifaqJ8JA68tYtBW)gWk2t4ONtdiLIoePGayR8GgumYtBWxhKtGjtXEch9CAaPu0HifeaBzqM7bLFsUWaQrE8XKHwSNWrpNgqkfDisbbWwcXDr(j5dyihDKb0I9eo650asPOdrkia2Az8Qeu1bYjejDk2t4ONtdiLIoePGay7RwwcKRoNALqSypHJEonGuk6qKccGTWZHOpFoyKlfjdUIqDKdJa2xXEch9CAaPu0HifeaBFmTuhixksgKUIkbm5deNayykgWcwWzpwITMmn5deNayykgWcwWHLzHTMmjvGGn8hzs1PSmlSTypHJEonGuk6qKccGTdyi3WjodpYL3dXvujacdPm8i08cKs5Y7HyWWQypHJEonGuk6qKccGTSVxexGQZFKEE6qSyVypHJEonWClqg0haec1nppDqxrLayUfid6tiQ0jDiUh42wSNWrpNgyUfid6dia2QqKlfhsxrLaimKYGcrUuCinep2EXEch9CAG5wGmOpGayB(W0roAMwIJQNVIkbWKEgSGZEM12DjC0fihDKrr6EayrXEch9CAG5wGmOpGayRuFKtis6uSNWrpNgyUfid6dia2QqKlshIf7f7jC0ZPb6aqkm(h0vujaw9itQU6a5SvFWNYHGPcbaBnzkIegszGT6d(uoemvicXJTZ6DSY6XfCGWya8asCoXjgtMimKYaXNQZLpI2GHht4SJvwpUGdegdGh(mQPpCQv(M3KjRhxWbcJbWdafjutbNAPMhnzY6XfCGWya8G8p6qCIXKjwfrcdPmWO)FpLFs(Cpd6tWWYKjcdPmGMPv6rmYTUb9rtr4XeoMmryiLb5JOnQdKZw9inyyX6DegszqQoq8P8tYL)rNWJjCaylRzDXEch9CAGoGayR8pBqNFprXEch9CAGoGaylHqTXM8JROsaegszq(iAJ6a5FQEWWYKPeo6cKJoYOiDpaM1KPeo6cKJoYOiDpaSy3Q(gokVhigGNiYL)5tanNHAzHXI9eo650aDabW2pbLFsU8p6SIkb8itQU6a5SvFWNYHGPcbaW3frcdPmWw9bFkhcMkeHhzs1Pf7jC0ZPb6acGTafjutbNAPMhxrLaEKjvxDGC2Qp4t5qWuHyxejmKYaB1h8PCiyQqeEKjvNUhmPdFugeK5ZfOGpkdwSNWrpNgOdia2QqKlshIROsapYKQRoqoB1h8PCiyQqS7rMuD1bYzR(GpLdbtfI9imKYGuDG4t5NKl)JoHht4SlIegszGT6d(uoemvicpYKQt3B(Cbk4JYGf7jC0ZPb6acGTWJbhoDUNPypHJEonqhqaSvHi3VfzXEch9CAGoGay7Nrn9HtTY38ROsaegszq(iAJ6a5Svpsdgw7s4Olqo6iJIuaGxSNWrpNgOdia2QqKlshIROsaegszqQoq8P8tYL)rNWJjCmzkIegszq(NnOhEKjvNU385cuWhLbl2t4ONtd0beaBrIZjoXuSNWrpNgOdia2(zutF4uR8n)kQeaRw13Wr59aXG8r0g1bYzREKgqZzOwwy0KPeo6cKJoYOiDpaSG17yfHHugi(uDU8r0gm8ychtMONHGq9yaEme5WzWOo5ONhqpjeyK1f7jC0ZPb6acGTuWu5OoqU1Xg)vujGeo6cKJoYOiDpaMTypHJEonqhqaSLcMkh1bYTo24VIqDKdJa2NTROsaSIEgcc1JbPIIi)KCcXrPhdnGEsiWOjt0ZqqOEma8Vfix9fkW7ZrppGEsiWiR3XQvDsb6t4nCKFsU1Xg)a6jHaJMmryiLH3Wr(j5whB8dXJTVdENiES9WB4i)KCRJn(Hhzs1P7b((yDXEch9CAGoGaylJ()9u(j5Z9mOpf7jC0ZPb6acGTY)Od3Vf5kQeWB4O8EGya4RubOCfQqbgqZzOwwyC3KpqCccCbkyzacCbk2frcdPmi)Zg0dXJTxSNWrpNgOdia2MpmDKJMPL4O65ROsaVHJY7bIHOsHQLq98bLdpgM0Jb0CgQLfg3bVtep2EGWqk5rLcvlH65dkhEmmPhdpMrq3ryiLHOsHQLq98bLdpgM0J88HPJH4X2l2t4ONtd0beaBL6JCcrsNvujG3Wr59aXquPq1sOE(GYHhdt6XaAod1YcJ7G3jIhBpqyiL8OsHQLq98bLdpgM0JHhZiO7imKYquPq1sOE(GYHhdt6rUuFmep2EXEch9CAGoGaylqrc1uWPwQ5XvujacdPmq8P6C5JOny4Xeof7jC0ZPb6acGTY)OdXjME6PBa]] )


end
