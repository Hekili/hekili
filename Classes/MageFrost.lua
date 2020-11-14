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

    
    spec:RegisterPack( "Frost Mage", 20201111, [[de0WSaqiuc8iusLnbKgLKGtrrvVcaZssLBjPkf7sWVuknmjrhdOSmGWZKeAAsQIRjPQ2gkr9nuczCOeQZjPkzDOKQY8qjY9a0(aIoikPQAHkfpusvkDrucsBeLG6KsQs1kPuUjkPk7us5PsmvjP9k1Fr1Gr0HfTyeEmOjl0LH2mrFwPA0avNM0QrjiEnfvMnHBJIDt1Vvz4uYXrjz5Q65inDfxNcBNs13rPgpkPCEaA9uuMpfz)k5gSUAxI5GDnqujiQemWadSaiQy9WY1Nf1LbqlSlwj0C5o2fpzWUWc)hDwKSE5o2fReqXLXUAxONXdXUa(mwuwFB3URd4geb4XSLQmgIC0ZHFkNTuLbUTlegQyQ39MOlXCWUgiQeevcgyGbwaevSEy56xXUKgd433LIYuVTlGRXi6nrxIif2fw3IK1l3Xfjl8F0zzJ1TiRD2rgc8xKGbwDlsqujiQSlcLo0UAxqkfDis7QDnW6QDjHJEEx2nYpQPZpjpnd)BaVlONecm2B6PRbIUAxs4ON3f5bnOyKNMHVoiNatMUGEsiWyVPNUwf7QDjHJEExyqM7bKFsUWaQrE8XKH2f0tcbg7n901QNUAxs4ON3fcXDr(j5d4ihDKbWUGEsiWyVPNUw97QDjHJEExSmEvcO67CcrsNUGEsiWyVPNUgl3v7sch98U8QLLa5QZPwje7c6jHaJ9ME6ASOUAxqpjeyS30Leo65DbEoe95ZbJCPizWUiuh5Wyxy5E6AS4UAxqpjeyS30f4Rd(A2Lj)DCcGJPyapybNfjixKS4kxKMmTiN83XjaoMIb8GfCwKS0IeevUinzArk1DWh(JmP60fjlTibrLDjHJEExEmTuFNlfjds7PRvV6QDb9KqGXEtxGVo4RzximKYWJqZjqkLlVhIbdRUKWrpVld4i3WjodpYL3dXE6AGvzxTljC0Z7c77fr7O68hPNNoe7c6jHaJ9ME6PlruMgIPR21aRR2Leo65DbEg(Gp1cfIUGEsiWyVPNUgi6QDb9KqGXEtxs4ON3fyke8eo65CHsNUiu6W9Kb7cms7PRvXUAxqpjeyS30Leo65DbMcbpHJEoxO0PlcLoCpzWUGuk6qK2txRE6QDb9KqGXEtxGVo4Rzxs4O2ro6iJI0fjibUiRFxs4ON3fyke8eo65CHsNUiu6W9Kb7sEypDT63v7c6jHaJ9MUaFDWxZUKWrTJC0rgfPlswArw)UKWrpVlWui4jC0Z5cLoDrO0H7jd2f60txJL7QDb9KqGXEtxs4ON3fyke8eo65CHsNUiu6W9Kb7cZzhzqF6PNUy9i8yiYPR21aRR2Leo65DjFy6ix9bfceoDb9KqGXEtpDnq0v7sch98UWoh85OazqFsrxqpjeyS30txRID1UKWrpVlY)OdXjMUGEsiWyVPNE6sEyxTRbwxTljC0Z7I8pZqNFprxqpjeyS30txdeD1UKWrpVlec1mZYp2f0tcbg7n901QyxTlONecm2B6c81bFn7sfwKpYKQR(oNT6d(uoeCviwKaxKvUinzArgrcdPmWw9bFkhcUkeH4X2xKMFrc6ISclsRhTZ3HXaybK4CItmlstMwKegszG4t15YhrZWWJjCwKGUijmKYGu9D8P8tYL)rNWJjCwKaxKvUinFxs4ON3fPW4Fa7PRvpD1UKWrpVlke5(zp7c6jHaJ9ME6A1VR2Leo65DbEm4WPZ9mDb9KqGXEtpDnwUR2f0tcbg7nDb(6GVMDHWqkds13XNYpjx(hDcpMWzrAY0ImIegszq(NzOhEKjvNUib5IC(0ok4JYGlstMwKpYKQR(oNT6d(uoeCviwKGUiJiHHugyR(GpLdbxfIWJmP60fjixKZN2rbFugSljC0Z7IcrUiDi2txJf1v7sch98U8zutF4uR8nxxqpjeyS30txJf3v7sch98UqbxLJ67CRJn(Db9KqGXEtpDT6vxTljC0Z7cJ()9u(j5Z9mOpDb9KqGXEtpDnWQSR2f0tcbg7nDb(6GVMD5nCuE)og2FLkaKRqfkWaYkd1YcJlsqxKt(74eeODuSizjGlsbAhflsqxKrKWqkdY)md9q8y7DjHJEExK)rhUF2ZE6AGbwxTlONecm2B6c81bFn7YB4O8(DmevkuTeQNpGC4XWKEmGSYqTSW4Ie0fj8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbCrc6IKWqkdrLcvlH65dihEmmPh5s9Xq8y7DjHJEExK6JCcrsNE6AGbIUAxqpjeyS30f4Rd(A2fM0ZGfCwKGCrwXkxKGUizblY3Wr597yaEIix(NpbKvgQLfgxKGUiRWIKfSiFdhL3VJb5JOzQVZzREKgqwzOwwyCrAY0IKWqkdYhrZuFNZw9inyyTin)Ie0f5B4O8(DmevkuTeQNpGC4XWKEmGSYqTSW4Ie0fj8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbCrc6IKWqkdrLcvlH65dihEmmPh5Y)OtiES9UKWrpVl5dth5iRzjoQEEpDnWQyxTljC0Z7csCoXjMUGEsiWyVPNUgy1txTlONecm2B6c81bFn7YB4O8(DmSlsOMcU8ZDg0hAazLHAzHXfjOlYjfOpbQLqNr9DUcXa6jHaJDjHJEExuiYfPdXE6AGv)UAxs4ON3f5F0H4etxqpjeyS30tpDbgPD1UgyD1UGEsiWyVPlWxh81SlwpANFsjFhgdkeqUDuD6I0KPfPu3bF4pYKQtxKS0ISIv2Leo65DX6g98E6AGOR2f0tcbg7nDb(6GVMDHEgcc1Jb2jDqr6rU1FwVIdGb0tcbg7sch98UWO)FpLFs(Cpd6tpDTk2v7sch98UeXCaN4Eh7c6jHaJ9ME6A1txTlONecm2B6c81bFn7c8or8y7bfci3oQon8itQoDrcYfjy1Frc6IKWqkdVHJ8tYTo24hIhBVljC0Z7YB4i)KCRJn(901QFxTlONecm2B6c81bFn7cHHugEdh5NKBDSXpep2Exs4ON3ffci3oQoTNUgl3v7c6jHaJ9MUaFDWxZU8gokVFhddYyDFk4SZ3kGSYqTSW4Ie0fzfwK0tClstMwKegszaznWtd6ONhmSwKMFrc6ISclsRhTZpPKVdJbfci3oQoDrAY0IuQ7Gp8hzs1PlswArwXkxKMVljC0Z7YOmiND(w901yrD1UKWrpVlguKRdYq7c6jHaJ9ME6AS4UAxs4ON3fcXDrU04bSlONecm2B6PRvV6QDjHJEExiWNIV5uFVlONecm2B6PRbwLD1UKWrpVlcDh8HYzHye3zqF6c6jHaJ9ME6AGbwxTljC0Z7IuFKqCxSlONecm2B6PRbgi6QDjHJEExshI05tbhMcrxqpjeyS30txdSk2v7sch98UqK78tYNxHMJ2f0tcbg7n90txOtxTRbwxTlONecm2B6c81bFn7sfwKpYKQR(oNT6d(uoeCviwKaxKvUinzArgrcdPmWw9bFkhcUkeH4X2xKMFrc6ISclsRhTZ3HXaybK4CItmlstMwKegszG4t15YhrZWWJjCwKGUiRWI06r78DymawyxKqnfCQLAoCrAY0I06r78Dymawq(hDioXSinzArA9OD(omgal8zutF4uR8n3I0KPfjHHugKQVJpLFsU8p6eEmHZIe4ISYfjOlYkSiJiHHugy0)VNYpjFUNb9jyyTinzArsyiLb5JOzQVZzREKgmSwKMmTijmKYaYAwPhXi36g0hnfHht4Sin)I08lsZ3Leo65Drkm(hWE6AGOR2Leo65Dr(NzOZVNOlONecm2B6PRvXUAxqpjeyS30f4Rd(A2fcdPmiFent9D(NQhmSwKMmTit4O2ro6iJI0fjibUibrxs4ON3fcHAMz5h7PRvpD1UGEsiWyVPlWxh81SlpYKQR(oNT6d(uoeCviwKaxKGTibDrgrcdPmWw9bFkhcUkeHhzs1PDjHJEEx(eq(j5Y)OtpDT63v7c6jHaJ9MUaFDWxZU8itQU67C2Qp4t5qWvHyrc6ImIegszGT6d(uoeCvicpYKQtxKGCrct6WhLbxKaSiNpTJc(Omyxs4ON3LDrc1uWPwQ5WE6ASCxTlONecm2B6c81bFn7YJmP6QVZzR(GpLdbxfIfjOlYhzs1vFNZw9bFkhcUkelsqUijmKYGu9D8P8tYL)rNWJjCwKGUiJiHHugyR(GpLdbxfIWJmP60fjixKZN2rbFugSljC0Z7IcrUiDi2txJf1v7sch98UapgC405EMUGEsiWyVPNUglUR2Leo65DrHi3p7zxqpjeyS30txRE1v7c6jHaJ9MUaFDWxZUqyiLb5JOzQVZzREKgmSwKGUit4O2ro6iJI0fjWfjyDjHJEEx(mQPpCQv(MRNUgyv2v7c6jHaJ9MUaFDWxZUqyiLbP674t5NKl)JoHht4SinzArgrcdPmi)Zm0dpYKQtxKGCroFAhf8rzWUKWrpVlke5I0HypDnWaRR2Leo65DbjoN4etxqpjeyS30txdmq0v7c6jHaJ9MUaFDWxZUuHfjlyr(gokVFhdYhrZuFNZw9inGSYqTSW4I0KPfzch1oYrhzuKUibjWfjiwKMFrc6IKWqkdeFQox(iAggEmHtxs4ON3LpJA6dNALV56PRbwf7QDjHJEExy0)VNYpjFUNb9PlONecm2B6PRbw90v7c6jHaJ9MUaFDWxZUqyiLH3Wr(j5whB8dXJTVibDrwHfjlyrcVtep2E4nCKFsU1Xg)WJzeWfPjtls6ziiupg2)ZoYv3UUFFo65b0tcbgxKMmTiPNHGq9yqQOiYpjNqCu6XqdONecmUinzAr(gokVFhdYhrZuFNZw9inGSYqTSW4I0KPfzch1oYrhzuKUibjWfjiwKMVljC0Z7cfCvoQVZTo243txdS63v7c6jHaJ9MUaFDWxZU8gokVFhd7VsfaYvOcfyazLHAzHXfjOlYj)DCcc0okwKSeWfPaTJIfjOlYisyiLb5FMHEiES9UKWrpVlY)Od3p7zpDnWy5UAxqpjeyS30f4Rd(A2L3Wr597yiQuOAjupFa5WJHj9yazLHAzHXfjOls4DI4X2degsjpQuOAjupFa5WJHj9y4Xmc4Ie0fjHHugIkfQwc1Zhqo8yyspYZhMogIhBVljC0Z7s(W0roYAwIJQN3txdmwuxTlONecm2B6c81bFn7YB4O8(DmevkuTeQNpGC4XWKEmGSYqTSW4Ie0fj8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbCrc6IKWqkdrLcvlH65dihEmmPh5s9Xq8y7DjHJEExK6JCcrsNE6AGXI7QDb9KqGXEtxGVo4RzximKYaXNQZLpIMHHht40Leo65DzxKqnfCQLAoSNUgy1RUAxs4ON3f5F0H4etxqpjeyS30tpDH5SJmOpD1UgyD1UGEsiWyVPlWxh81SlmNDKb9jev6KoexKGCrcwLDjHJEExieQBUE6AGOR2f0tcbg7nDb(6GVMDHWqkdke5sXH0q8y7DjHJEExuiYLIdP901QyxTlONecm2B6c81bFn7ct6zWcolsqUiRyLlsqxKjCu7ihDKrr6IeKaxKGOljC0Z7s(W0roYAwIJQN3txRE6QDjHJEExK6JCcrsNUGEsiWyVPNUw97QDjHJEExuiYfPdXUGEsiWyVPNE6Pl2XNQN31arLGOsWQemwUlSZ3vFN2L6DgR7hmUizrlYeo65lsHshAyzRlule21y56Plw)jvb2fw3IK1l3Xfjl8F0zzJ1TiRD2rgc8xKGbwDlsqujiQCzBzJ1TizHYAi0yW4IKaL3Jls4XqKZIKa3vNgwKS(Hq0AOls)86nGNpJ0qSit4ONtxKNlamSSLWrpNgSEeEme5aaWT5dth5QpOqGWzzlHJEony9i8yiYbaGBPgmmNZzNd(CuGmOpPyzlHJEony9i8yiYbaGBL)rhItmlBlBSUfjluwdHgdgxKOD8bCrokdUihWXfzcN7xKkDrM2tvKecmSSLWrpNceEg(Gp1cfILTeo65uaaUfMcbpHJEoxO0PopzqGWiDzlHJEofaGBHPqWt4ONZfkDQZtgeisPOdr6Ywch9Ckaa3ctHGNWrpNlu6uNNmiW8W6ujWeoQDKJoYOifKaR)Ywch9Ckaa3ctHGNWrpNlu6uNNmiq6uNkbMWrTJC0rgfPSu9x2s4ONtba4wyke8eo65CHsN68KbbYC2rg0NLTLTeo650qEiq5FMHo)EILTeo650qEiaa3siuZml)4Ywch9CAipeaGBLcJ)bSovcScpYKQR(oNT6d(uoeCviawPjtrKWqkdSvFWNYHGRcriESDZdAfSE0oFhgdGfqIZjoXyYeHHugi(uDU8r0mm8ychqjmKYGu9D8P8tYL)rNWJjCawP5x2s4ONtd5HaaCRcrUF2ZLTeo650qEiaa3cpgC405EMLTeo650qEiaa3QqKlshI1PsGegszqQ(o(u(j5Y)Ot4XeoMmfrcdPmi)Zm0dpYKQtb58PDuWhLbnz6rMuD135SvFWNYHGRcbOrKWqkdSvFWNYHGRcr4rMuDkiNpTJc(Om4Ywch9CAipeaGB)mQPpCQv(MBzlHJEonKhcaWTuWv5O(o36yJ)Ywch9CAipeaGBz0)VNYpjFUNb9zzlHJEonKhcaWTY)Od3p7zDQe4B4O8(DmS)kvaixHkuGbKvgQLfgbDYFhNGaTJcwcOaTJcqJiHHugK)zg6H4X2x2s4ONtd5HaaCRuFKtis6uNkb(gokVFhdrLcvlH65dihEmmPhdiRmullmck8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbeucdPmevkuTeQNpGC4XWKEKl1hdXJTVSLWrpNgYdba428HPJCK1SehvpVovcKj9mybhqwXkbLf8gokVFhdWte5Y)8jGSYqTSWiOvGf8gokVFhdYhrZuFNZw9inGSYqTSWOjtegszq(iAM67C2QhPbdlZd6B4O8(DmevkuTeQNpGC4XWKEmGSYqTSWiOW7eXJThimKsEuPq1sOE(aYHhdt6XWJzeqqjmKYquPq1sOE(aYHhdt6rU8p6eIhBFzlHJEonKhcaWTiX5eNyw2s4ONtd5HaaCRcrUiDiwNkb(gokVFhd7IeQPGl)CNb9HgqwzOwwye0jfOpbQLqNr9DUcXa6jHaJlBjC0ZPH8qaaUv(hDioXSSTSLWrpNgGrkqRB0ZRtLaTE0o)Ks(omguiGC7O6utMK6o4d)rMuDklvXkx2s4ONtdWifaGBz0)VNYpjFUNb9PovcKEgcc1Jb2jDqr6rU1FwVIdGb0tcbgx2s4ONtdWifaGBJyoGtCVJlBjC0ZPbyKcaWTVHJ8tYTo24xNkbcVtep2EqHaYTJQtdpYKQtbjy1hucdPm8goYpj36yJFiES9LTeo650amsba4wfci3oQoTovcKWqkdVHJ8tYTo24hIhBFzlHJEonaJuaaUDugKZoFR6ujW3Wr597yyqgR7tbND(wbKvgQLfgbTc0tCMmryiLbK1apnOJEEWWY8GwbRhTZpPKVdJbfci3oQo1KjPUd(WFKjvNYsvSsZVSLWrpNgGrkaa3AqrUoidDzlHJEonaJuaaULqCxKlnEax2s4ONtdWifaGBjWNIV5uFFzlHJEonaJuaaUvO7GpuoleJ4od6ZYwch9CAagPaaCRuFKqCxCzlHJEonaJuaaUnDisNpfCykelBjC0ZPbyKcaWTe5o)K85vO5OlBlBjC0ZPbKsrhIuG7g5h105NKNMH)nGVSLWrpNgqkfDisba4w5bnOyKNMHVoiNatMLTeo650asPOdrkaa3YGm3di)KCHbuJ84JjdDzlHJEonGuk6qKcaWTeI7I8tYhWro6idGlBjC0ZPbKsrhIuaaU1Y4vjGQVZjejDw2s4ONtdiLIoePaaC7RwwcKRoNALqCzlHJEonGuk6qKcaWTWZHOpFoyKlfjdwNqDKdJaz5LTeo650asPOdrkaa3(yAP(oxksgKwNkbo5VJtaCmfd4bl4aswCLMmn5VJtaCmfd4bl4WsGOstMK6o4d)rMuDklbIkx2s4ONtdiLIoePaaC7aoYnCIZWJC59qSovcKWqkdpcnNaPuU8EigmSw2s4ONtdiLIoePaaCl77fr7O68hPNNoex2w2s4ONtdmNDKb9biHqDZXthW6ujqMZoYG(eIkDshIGeSkx2s4ONtdmNDKb9baGBviYLIdP1PsGegszqHixkoKgIhBFzlHJEonWC2rg0haaUnFy6ihznlXr1ZRtLazspdwWbKvSsqt4O2ro6iJIuqceelBjC0ZPbMZoYG(aaWTs9roHiPZYwch9CAG5SJmOpaaCRcrUiDiUSTSLWrpNgOdqPW4FaRtLaRWJmP6QVZzR(GpLdbxfcGvAYuejmKYaB1h8PCi4QqeIhB38GwbRhTZ3HXaybK4CItmMmryiLbIpvNlFenddpMWb0ky9OD(omgalSlsOMco1snhAYK1J257WyaSG8p6qCIXKjRhTZ3HXayHpJA6dNALV5mzIWqkds13XNYpjx(hDcpMWbyLGwHisyiLbg9)7P8tYN7zqFcgwMmryiLb5JOzQVZzREKgmSmzIWqkdiRzLEeJCRBqF0ueEmHJ5nV5x2s4ONtd0baGBL)zg687jw2s4ONtd0baGBjeQzMLFSovcKWqkdYhrZuFN)P6bdltMs4O2ro6iJIuqceelBjC0ZPb6aaWTFci)KC5F0Povc8rMuD135SvFWNYHGRcbqWanIegszGT6d(uoeCvicpYKQtx2s4ONtd0baGB3fjutbNAPMdRtLaFKjvx9DoB1h8PCi4QqaAejmKYaB1h8PCi4QqeEKjvNcsysh(OmiaZN2rbFugCzlHJEonqhaaUvHixKoeRtLaFKjvx9DoB1h8PCi4Qqa6JmP6QVZzR(GpLdbxfcqsyiLbP674t5NKl)JoHht4aAejmKYaB1h8PCi4QqeEKjvNcY5t7OGpkdUSLWrpNgOdaa3cpgC405EMLTeo650aDaa4wfIC)SNlBjC0ZPb6aaWTFg10ho1kFZvNkbsyiLb5JOzQVZzREKgmSanHJAh5OJmksbc2Ywch9CAGoaaCRcrUiDiwNkbsyiLbP674t5NKl)JoHht4yYuejmKYG8pZqp8itQofKZN2rbFugCzlHJEonqhaaUfjoN4eZYwch9CAGoaaC7Nrn9HtTY3C1PsGvGf8gokVFhdYhrZuFNZw9inGSYqTSWOjtjCu7ihDKrrkibccZdkHHugi(uDU8r0mm8ycNLTeo650aDaa4wg9)7P8tYN7zqFw2s4ONtd0baGBPGRYr9DU1Xg)6ujqcdPm8goYpj36yJFiESDqRalaENiES9WB4i)KCRJn(HhZiGMmrpdbH6XW(F2rU62197ZrppGEsiWOjt0ZqqOEmivue5NKtiok9yOb0tcbgnz6nCuE)ogKpIMP(oNT6rAazLHAzHrtMs4O2ro6iJIuqceeMFzlHJEonqhaaUv(hD4(zpRtLaFdhL3VJH9xPca5kuHcmGSYqTSWiOt(74eeODuWsafODuaAejmKYG8pZqpep2(Ywch9CAGoaaCB(W0roYAwIJQNxNkb(gokVFhdrLcvlH65dihEmmPhdiRmullmck8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbeucdPmevkuTeQNpGC4XWKEKNpmDmep2(Ywch9CAGoaaCRuFKtis6uNkb(gokVFhdrLcvlH65dihEmmPhdiRmullmck8or8y7bcdPKhvkuTeQNpGC4XWKEm8ygbeucdPmevkuTeQNpGC4XWKEKl1hdXJTVSLWrpNgOdaa3UlsOMco1snhwNkbsyiLbIpvNlFenddpMWzzlHJEonqhaaUv(hDioX0tpDd]] )


end
