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
            duration = 12,
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
        winters_chill = {
            id = 228358,
            duration = 6,
            type = "Magic",
            max_stack = 2,
        },

        frozen = {
            duration = 1,
    
            meta = {
                spell = function( t )
                    if debuff.winters_chill.up and remaining_winters_chill > 0 then return debuff.winters_chill end
                    return debuff.frost_nova
                end,

                up = function( t )
                    return t.spell.up
                end,
                down = function( t )
                    return t.spell.down
                end,
                applied = function( t )
                    return t.spell.applied
                end,
                remains = function( t )
                    return t.spell.remains
                end,
                count = function(t )
                    return t.spell.count
                end,
                stack = function( t )
                    return t.spell.stack
                end,
                stacks = function( t )
                    return t.spell.stacks
                end,
            }
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
        slick_ice = {
            id = 327509,
            duration = 60,
            max_stack = 10
        }
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
                if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
            end,
        },


        frostbolt = {
            id = 116,
            cast = function () return 2 * ( 1 - 0.02 * buff.slick_ice.stack ) * haste end,
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

                if legendary.slick_ice.enabled then
                    addStack( "slick_ice", nil, 1 )
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
                if legendary.triune_ward.enabled then
                    applyBuff( "blazing_barrier" )
                    applyBuff( "prismatic_barrier" )
                end
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

                if talent.rune_of_power.enabled then
                    applyBuff( "rune_of_power" )
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

        potion = "phantom_fire",

        package = "Frost Mage",
    } )


    spec:RegisterSetting( "ignore_freezing_rain_st", true, {
        name = "Ignore |T629077:0|t Freezing Rain in Single-Target",
        desc = "If checked, the default action list will not recommend using |T135857:0|t Blizzard in single-target due to the |T629077:0|t Freezing Rain talent proc.",
        type = "toggle",
        width = "full",
    } ) 
    
    spec:RegisterPack( "Frost Mage", 20210130, [[dGehVaqirj4rIsYMuH(KIYOeL6uIkEfs0Suu5wifjTls(fOQHPIQJrQAzIQ6zGknnrj11eLOTHuuFtucnofvvDofvvwNOsMhQsCpqzFGkoisr0crcpurvUisryJkQk8ruLuoPIQsRev1mfvQBIQKQDQI8tKIelfPi1tvPPQc(kQsIXQIYEb(RidMIdlzXG8yuMScxgAZu6ZkYOrkDAHvROQOxJQuZMWTrLDt1VvA4iPJJQK0Yv1ZjA6sDDsz7ivFNuz8ifopQI1lQY8ff7hXa9GdG7OAeCk)ZZx)56H75k9WfU5NFwcUnpurWLAX4DnHGRxCi4oF8RSjgE9AcbxQfpITgGdGRC1EgcU02nvzUGh(POPvdsXwo4LbNMO6yD2x2gEzWXGhCH0crpFDae4oQgbNY)881FUE4EUspCHB(5Np4wAnT7dU3GBEGlTXyGoacChOKbUzvwrm861esmZh)kBc)SkRig(LRvppet(08Cet(NNVEWveYwcoaUd0wAIgCaCsp4a4wSowhCzRM34lPIcb4IEbjWbGcqdoLp4a4IEbjWbGcWTyDSo4YkHivSowpjczdUIq2jV4qWLnKGgCcUGdGl6fKahaka3I1X6GlReIuX6y9KiKn4kczN8IdbxukrNHsqdoL1GdGl6fKahakax2hn(rbUfRd6ycDKlqjXahyedCb3I1X6GlReIuX6y9KiKn4kczN8Idb3ArqdoLLGdGl6fKahakax2hn(rbUfRd6ycDKlqjXWledCb3I1X6GlReIuX6y9KiKn4kczN8IdbxzdAWjAgCaCrVGe4aqb4wSowhCzLqKkwhRNeHSbxri7KxCi4YT0ro0BqdAWL6JSLdQAWbWj9GdGBX6yDWTEw5yk8gfcK1Gl6fKahakan4u(GdGBX6yDWvx14NqbYHExcWf9csGdafGgCcUGdGBX6yDW1(RSHwrdUOxqcCaOa0GgCRfbhaN0doaUfRJ1bx7V5HEAFiWf9csGdafGgCkFWbWTyDSo4cjI8YR(b4IEbjWbGcqdobxWbWf9csGdafGl7Jg)Oa3SjMh5QWdFkPl8gFzIrBieedmI5CIjtgIzGqAwRsx4n(YeJ2qiuJvNtm5qmhjMSjgQpspnXgk9keADOv0etMmedKM1QG(k8K9rmpu9yXAI5iXaPzTkB4t4ltRnz)v2QhlwtmWiMZjMCa3I1X6GRvO9ppGgCkRbha3I1X6GBWWKV0lWf9csGdafGgCklbha3I1X6GlB5Woj795ax0liboauaAWjAgCaCrVGe4aqb4Y(OXpkWfsZAv2WNWxMwBY(RSvpwSMyYKHygiKM1QS)Mh6Qh5QWLedCiM(l6Oi1bhsmzYqmpYvHh(usx4n(YeJ2qiiMJeZaH0SwLUWB8LjgTHqOEKRcxsmWHy6VOJIuhCi4wSowhCdgMeLZqqdoLfbha3I1X6G7xJO8ojPwpVbx0liboauaAWP5p4a4wSowhC5I)3xMwBQ3Nd9gCrVGe4aqbObNMFGdGBX6yDWvsBy7WNsuxD4dUOxqcCaOa0Gt6phCaCrVGe4aqb4Y(OXpkW91C0U)eQM(qk4jfSGjqf6fKaheZrIPRFcBLaPJcIHxGrmcKokiMJeZaH0SwL938qxnwDo4wSowhCT)k7KV0lqdoPxp4a4IEbjWbGcWL9rJFuG7R5OD)juncjlOkcVEEsSLJR8Hc9csGdI5iXW2vmwDUcsZAtJqYcQIWRNNeB54kFOESg8qmhjginRvncjlOkcVEEsSLJR8rYgpQgRohClwhRdU24XeKOKnObN0Np4a4IEbjWbGcWL9rJFuGlx5LIkRjg4qmW9CI5iXuSoOJj0rUaLedCGrm0mXCKyYceZR5OD)junjkwuIK9Rjo0BPc9csGdWTyDSo4wpRCmH0GQyLX6GgCspCbha3I1X6GlcTo0kAWf9csGdafGgCsFwdoaUOxqcCaOaCzF04hf4(AoA3FcvtIIfLiz)AId9wQqVGe4GyosmDjqVvsQIO7WNsbdvOxqcCqmhjM(l6Oi1bhsm8cXm9RMps1IkirKxE1pupYvHlb3I1X6GBWWKOCgcAWj9zj4a4IEbjWbGcWvImW9CLEWTyDSo4QRIgCzF04hf4(AoA3FcvtIIfLiz)AId9wQqVGe4GyosmDjqVvsQIO7WNsbdvOxqcCaAWj90m4a4wSowhCT)kBOv0Gl6fKahakanObx2qcoaoPhCaCrVGe4aqb4Y(OXpkWL6J0tR1MMydvW4jrhdxsmzYqm2yI2o9ixfUKy4fIbUNdUfRJ1bxQBhRdAWP8bha3I1X6G7aRMwO9DeCrVGe4aqbObNGl4a4IEbjWbGcWL9rJFuGBX6GoMqh5cusm8cXaxI5iXKnXWwFOfTsguPDDCK4krWqf6fKahetMmeJC1eqHpu6kzJIYhjQ)s9dS5rHEbjWbXKd4wSowhC5I)3xMwBQ3Nd9g0Gtzn4a4IEbjWbGcWL9rJFuGlBxXy15QGXtIogUu9ixfUKyGdXOpFI5iXaPzTQxZX0AtuxD4RgRohClwhRdUVMJP1MOU6Wh0Gtzj4a4IEbjWbGcWL9rJFuGlKM1QEnhtRnrD1HVAS6CI5iXKnXaPzTQGXtIogUunwDoXKjdX0La9w9AoMwBI6QdFf6fKahetoeZrIjBIbsZAvsrW4DkyOAS6CIjtgIPyDqhtOJCbkjg4aJyYNyYbClwhRdUbJNeDmCjObNOzWbWf9csGdafGl7Jg)Oa3xZr7(tOQroQ7xIKU6PQqVGe4GyosmqAwRcPbTLMSJ1vAujMJet2ed1hPNwRnnXgQGXtIogUKyYKHySXeTD6rUkCjXWledCpNyYbClwhRdUDWHjD1tf0GtzrWbWTyDSo4QjXu0iNeCrVGe4aqbObNM)GdGBX6yDWfsS7iz1EEax0liboauaAWP5h4a4wSowhCHWxIpVdFcCrVGe4aqbObN0Fo4a4wSowhCfXeTTmnFQnM4qVbx0liboauaAWj96bha3I1X6GRnEesS7aCrVGe4aqbObN0Np4a4wSowhClNHY(lrIvcb4IEbjWbGcqdoPhUGdGBX6yDWfQMsRn1FW4TeCrVGe4aqbObn4kBWbWj9GdGl6fKahakax2hn(rbUztmpYvHh(usx4n(YeJ2qiigyeZ5etMmeZaH0SwLUWB8LjgTHqOgRoNyYHyosmztmuFKEAInu6vi06qROjMmziginRvb9v4j7JyEO6XI1eZrIjBIH6J0ttSHsVAsuSOejj1G3iXKjdXq9r6Pj2qPxz)v2qROjMJet2etwGyyRp0IwfpMwBQPftLKH(ahk0liboiMmzig2UIXQZvFnIY7KKA98w9ixfUKyYKHyEnhT7pHk7JyEHpL0f(qQqVGe4GyYHyYKHyO(i90eBO0R(AeL3jj165nXKjdXaPzTkB4t4ltRnz)v2QhlwtmWiMZjMJet2eZaH0Swfx8)(Y0At9(CO3knQetMmedKM1QSpI5f(usx4dPsJkXKjdXaPzTkKgulFGJe1TrVJsOESynXKdXKdXKd4wSowhCTcT)5b0Gt5doaUfRJ1bx7V5HEAFiWf9csGdafGgCcUGdGl6fKahakax2hn(rbUqAwRY(iMx4tPVcxPrLyYKHykwh0Xe6ixGsIboWiM8b3I1X6GlKiYlV6hGgCkRbhax0liboauaUSpA8JcCFKRcp8PKUWB8LjgTHqqmWig9eZrIzGqAwRsx4n(YeJ2qiupYvHlb3I1X6G7x8KwBY(RSbn4uwcoaUOxqcCaOaCzF04hf4(ixfE4tjDH34ltmAdHGyosmdesZAv6cVXxMy0gcH6rUkCjXahIHvYo1bhsmusm9x0rrQdoeClwhRdUtIIfLijPg8gbn4endoaUOxqcCaOaCzF04hf4(ixfE4tjDH34ltmAdHGyosmpYvHh(usx4n(YeJ2qiig4qmqAwRYg(e(Y0At2FLT6XI1eZrIzGqAwRsx4n(YeJ2qiupYvHljg4qm9x0rrQdoeClwhRdUbdtIYziObNYIGdGBX6yDWLTCyNK9(CGl6fKahakan408hCaClwhRdUbdt(sVax0liboauaAWP5h4a4IEbjWbGcWL9rJFuGlKM1QSpI5f(usx4dPsJkXCKykwh0Xe6ixGsIbgXOhClwhRdUFnIY7KKA98g0Gt6phCaCrVGe4aqb4Y(OXpkWfsZAv2WNWxMwBY(RSvpwSMyYKHygiKM1QS)Mh6Qh5QWLedCiM(l6Oi1bhcUfRJ1b3GHjr5me0Gt61doaUfRJ1bxeADOv0Gl6fKahakan4K(8bhax0liboauaUSpA8JcCZMyYceZR5OD)juzFeZl8PKUWhsf6fKahetMmetX6GoMqh5cusmWbgXKpXKdXCKyG0Swf0xHNSpI5HQhlwdUfRJ1b3Vgr5DssTEEdAWj9WfCaClwhRdUCX)7ltRn17ZHEdUOxqcCaOa0Gt6ZAWbWf9csGdafGl7Jg)OaxinRv9AoMwBI6QdF1y15eZrIjBIrUAcOWhQPFPJPWPht7xDSUc9csGdIjtgIrUAcOWhkBGIrATjiXkLlNuHEbjWbXKjdXuSoOJj0rUaLedCGrm5tm5aUfRJ1bxjTHTdFkrD1HpObN0NLGdGl6fKahakax2hn(rbUVMJ29Nq10hsbpPGfmbQqVGe4GyosmD9tyReiDuqm8cmIrG0rbXCKygiKM1QS)Mh6QXQZb3I1X6GR9xzN8LEbAWj90m4a4IEbjWbGcWL9rJFuG7R5OD)juncjlOkcVEEsSLJR8Hc9csGdI5iXW2vmwDUcsZAtJqYcQIWRNNeB54kFOESg8qmhjginRvncjlOkcVEEsSLJR8rQEw5OAS6CWTyDSo4wpRCmH0GQyLX6GgCsFweCaCrVGe4aqb4Y(OXpkW91C0U)eQgHKfufHxppj2YXv(qHEbjWbXCKyy7kgRoxbPzTPrizbvr41ZtITCCLpupwdEiMJedKM1QgHKfufHxppj2YXv(izJhvJvNdUfRJ1bxB8ycsuYg0Gt6N)GdGl6fKahakax2hn(rbUqAwRc6RWt2hX8q1JfRb3I1X6G7KOyrjssQbVrqdoPF(boaUfRJ1bx7VYgAfn4IEbjWbGcqdAWLBPJCO3GdGt6bhax0liboauaUSpA8JcC5w6ih6TAeYUCgsmWHy0Fo4wSowhCHeHZBqdoLp4a4IEbjWbGcWL9rJFuGlKM1QcgMSIfLQXQZb3I1X6GBWWKvSOe0GtWfCaCrVGe4aqb4Y(OXpkWLR8srL1edCig4EoXCKykwh0Xe6ixGsIboWiM8b3I1X6GB9SYXesdQIvgRdAWPSgCaClwhRdU24XeKOKn4IEbjWbGcqdoLLGdGBX6yDWnyysuodbx0liboauaAqdAWLo(YyDWP8ppF9NRxFweC1vVh(KeC5vOjPPpnFpXRLlIHyoqlsmbh19BIXUpXmRwCgX8iVQw84GyKlhsmLwVCvJdIHrB5tOur4N7WrIr)55IyM360XVXbXm71C0U)eQoBgX0lXm71C0U)eQotHEbjWXmIjB90ihfHFUdhjg96ZfXmV1PJFJdIz2R5OD)juD2mIPxIz2R5OD)juDMc9csGJzet26Prokc)Chosm6ZpxeZ8wNo(noiMzVMJ29Nq1zZiMEjMzVMJ29Nq1zk0liboMrmvtm0e0uYnXKTEAKJIWp3HJeJ(SoxeZ8wNo(noiMzDjqVvNnJy6LyM1La9wDMc9csGJzet26Prokc)Chosm6Z6CrmZBD6434GyM9AoA3FcvNnJy6LyM9AoA3FcvNPqVGe4ygXKTEAKJIWp3HJeJ(SmxeZ8wNo(noiMzDjqVvNnJy6LyM1La9wDMc9csGJzet1ednbnLCtmzRNg5Oi8ZD4iXOplZfXmV1PJFJdIz2R5OD)juD2mIPxIz2R5OD)juDMc9csGJzet26ProkcFcFEfAsA6tZ3t8A5IyiMd0IetWrD)MyS7tmZyd5mI5rEvT4XbXixoKykTE5QghedJ2YNqPIWp3HJedCZfXmV1PJFJdIzgB9Hw0QZMrm9smZyRp0IwDMc9csGJzet26Prokc)ChosmWnxeZ8wNo(noiMzYvtaf(qD2mIPxIzMC1eqHpuNPqVGe4ygXKTEAKJIWp3HJetwMlIzERth)gheZSUeO3QZMrm9smZ6sGERotHEbjWXmIjB90ihfHFUdhjgAoxeZ8wNo(noiMzVMJ29Nq1zZiMEjMzVMJ29Nq1zk0liboMrmzRNg5Oi8j85vOjPPpnFpXRLlIHyoqlsmbh19BIXUpXmt2ZiMh5v1IhheJC5qIP06LRACqmmAlFcLkc)Chosm6ZfXmV1PJFJdIz2R5OD)juD2mIPxIz2R5OD)juDMc9csGJzet26Prokc)Chosm6ZfXmV1PJFJdIzgB9Hw0QZMrm9smZyRp0IwDMc9csGJzet26Prokc)Chosm6ZpxeZ8wNo(noiMzVMJ29Nq1zZiMEjMzVMJ29Nq1zk0liboMrmzRNg5Oi8ZD4iXOpRZfXmV1PJFJdIzMC1eqHpuNnJy6LyMjxnbu4d1zk0liboMrmzNpnYrr4N7WrIrFwMlIzERth)gheZSxZr7(tO6SzetVeZSxZr7(tO6mf6fKahZiMS1tJCue(5oCKy0tZ5IyM360XVXbXm71C0U)eQoBgX0lXm71C0U)eQotHEbjWXmIjB90ihfHFUdhjg9zXCrmZBD6434GyM9AoA3FcvNnJy6LyM9AoA3FcvNPqVGe4ygXKTEAKJIWNWF(YrD)ghedntmfRJ1jgriBPIWhCP(Rnei4MvzfXWRxtiXmF8RSj8ZQSIy4xUw98qm5tZZrm5FE(6j8j8ZQSIyOjObY0ACqmqODFKyylhu1edeofUurm0KmgsTLeJVonvARNZQjiMI1X6sIzDbpkc)I1X6sf1hzlhu1ucd(6zLJPWBuiqwt4xSowxQO(iB5GQMsyWl144wpPRA8tOa5qVlbHFX6yDPI6JSLdQAkHbV9xzdTIMWNWpRYkIHMGgitRXbXG0XNhIPdoKyAArIPy9(etijMIEfIcsGkc)I1X6sySvZB8LurHGWVyDSUKsyWZkHivSowpjczpNxCim2qs4xSowxsjm4zLqKkwhRNeHSNZloegkLOZqjHFX6yDjLWGNvcrQyDSEseYEoV4qy1IZfwyfRd6ycDKlqjCGbxc)I1X6skHbpReIuX6y9KiK9CEXHWK9CHfwX6GoMqh5cuYlWLWVyDSUKsyWZkHivSowpjczpNxCimULoYHEt4t4xSowxQQfHz)np0t7dr4xSowxQQfPeg8qIiV8QFq4xSowxQQfPeg8wH2)8mxyHL9JCv4HpL0fEJVmXOnecyNNjZaH0SwLUWB8LjgTHqOgRopNJzt9r6Pj2qPxHqRdTIotginRvb9v4j7JyEO6XI1hH0SwLn8j8LP1MS)kB1JfRHDEoe(fRJ1LQArkHbFWWKV0lc)I1X6svTiLWGNTCyNK9(Ce(fRJ1LQArkHbFWWKOCgoxyHbPzTkB4t4ltRnz)v2QhlwNjZaH0SwL938qx9ixfUeo9x0rrQdomtMh5QWdFkPl8gFzIrBiehhiKM1Q0fEJVmXOnec1JCv4s40FrhfPo4qc)I1X6svTiLWG)RruENKuRN3e(fRJ1LQArkHbpx8)(Y0At9(CO3e(fRJ1LQArkHbVK2W2HpLOU6WNWVyDSUuvlsjm4T)k7KV0R5clSxZr7(tOA6dPGNuWcMap21pHTsG0rbVatG0rXXbcPzTk7V5HUAS6Cc)I1X6svTiLWG3gpMGeLSNlSWEnhT7pHQrizbvr41ZtITCCLpoY2vmwDUcsZAtJqYcQIWRNNeB54kFOESg8CesZAvJqYcQIWRNNeB54kFKSXJQXQZj8lwhRlv1Iucd(6zLJjKgufRmwFUWcJR8srL1WbUNFSyDqhtOJCbkHdmA(yw41C0U)eQMeflkrY(1eh6TKWVyDSUuvlsjm4rO1Hwrt4xSowxQQfPeg8bdtIYz4CHf2R5OD)junjkwuIK9Rjo0B5XUeO3kjvr0D4tPGHh7VOJIuhCiVm9RMps1IkirKxE1pupYvHlj8lwhRlv1IucdEDv0ZjrgSZv6NlSWEnhT7pHQjrXIsKSFnXHElp2La9wjPkIUdFkfmKWVyDSUuvlsjm4T)kBOv0e(e(fRJ1Lk2qcJ62X6ZfwyuFKEAT20eBOcgpj6y4YmzSXeTD6rUkCjVa3Zj8lwhRlvSHKsyWpWQPfAFhj8lwhRlvSHKsyWZf)VVmT2uVph69CHfwX6GoMqh5cuYlW9y2S1hArRKbvAxhhjUsemmtg5QjGcFO0vYgfLpsu)L6hyZtoe(fRJ1Lk2qsjm4FnhtRnrD1H)CHfgBxXy15QGXtIogUu9ixfUeo6Z)iKM1QEnhtRnrD1HVAS6Cc)I1X6sfBiPeg8bJNeDmC5CHfgKM1QEnhtRnrD1HVAS68JzdPzTQGXtIogUunwDEMmDjqVvVMJP1MOU6WpNJzdPzTkPiy8ofmunwDEMmfRd6ycDKlqjCGLFoe(fRJ1Lk2qsjm47Gdt6QN6CHf2R5OD)ju1ih19lrsx9upcPzTkKg0wAYowxPr9y2uFKEAT20eBOcgpj6y4YmzSXeTD6rUkCjVa3ZZHWVyDSUuXgskHbVMetrJCsc)I1X6sfBiPeg8qIDhjR2ZdHFX6yDPInKucdEi8L4Z7WNi8lwhRlvSHKsyWlIjABzA(uBmXHEt4xSowxQydjLWG3gpcj2Dq4xSowxQydjLWGVCgk7Vejwjee(fRJ1Lk2qsjm4HQP0At9hmElj8j8lwhRlvClDKd9ggKiCENkNN5clmULoYHERgHSlNHWr)5e(fRJ1LkULoYHEtjm4dgMSIfLZfwyqAwRkyyYkwuQgRoNWVyDSUuXT0ro0BkHbF9SYXesdQIvgRpxyHXvEPOYA4a3ZpwSoOJj0rUaLWbw(e(fRJ1LkULoYHEtjm4TXJjirjBc)I1X6sf3sh5qVPeg8bdtIYziHpHFX6yDPs2WScT)5zUWcl7h5QWdFkPl8gFzIrBieWoptMbcPzTkDH34ltmAdHqnwDEohZM6J0ttSHsVcHwhAfDMmqAwRc6RWt2hX8q1JfRpMn1hPNMydLE1KOyrjssQbVXmzO(i90eBO0RS)kBOv0hZolWwFOfTkEmT2utlMkjd9boYKHTRyS6C1xJO8ojPwpVvpYvHlZK51C0U)eQSpI5f(usx4dzozYq9r6Pj2qPx91ikVtsQ1Z7mzG0SwLn8j8LP1MS)kB1JfRHD(XShiKM1Q4I)3xMwBQ3Nd9wPrntginRvzFeZl8PKUWhsLg1mzG0SwfsdQLpWrI62O3rjupwSoNCYHWVyDSUujBkHbV938qpTpeHFX6yDPs2ucdEirKxE1pMlSWG0SwL9rmVWNsFfUsJAMmfRd6ycDKlqjCGLpHFX6yDPs2ucd(V4jT2K9xzpxyH9ixfE4tjDH34ltmAdHaM(JdesZAv6cVXxMy0gcH6rUkCjHFX6yDPs2ucd(jrXIsKKudEJZfwypYvHh(usx4n(YeJ2qiooqinRvPl8gFzIrBieQh5QWLWHvYo1bhsz)fDuK6Gdj8lwhRlvYMsyWhmmjkNHZfwypYvHh(usx4n(YeJ2qio(ixfE4tjDH34ltmAdHaoqAwRYg(e(Y0At2FLT6XI1hhiKM1Q0fEJVmXOnec1JCv4s40FrhfPo4qc)I1X6sLSPeg8SLd7KS3NJWVyDSUujBkHbFWWKV0lc)I1X6sLSPeg8FnIY7KKA98EUWcdsZAv2hX8cFkPl8HuPr9yX6GoMqh5cuctpHFX6yDPs2ucd(GHjr5mCUWcdsZAv2WNWxMwBY(RSvpwSotMbcPzTk7V5HU6rUkCjC6VOJIuhCiHFX6yDPs2ucdEeADOv0e(fRJ1Lkztjm4)AeL3jj1659CHfw2zHxZr7(tOY(iMx4tjDHpKzYuSoOJj0rUaLWbw(5CesZAvqFfEY(iMhQESynHFX6yDPs2ucdEU4)9LP1M695qVj8lwhRlvYMsyWlPnSD4tjQRo8NlSWG0Sw1R5yATjQRo8vJvNFmB5QjGcFOM(LoMcNEmTF1X6zYixnbu4dLnqXiT2eKyLYLtMjtX6GoMqh5cuchy5NdHFX6yDPs2ucdE7VYo5l9AUWc71C0U)eQM(qk4jfSGjWJD9tyReiDuWlWeiDuCCGqAwRY(BEORgRoNWVyDSUujBkHbF9SYXesdQIvgRpxyH9AoA3FcvJqYcQIWRNNeB54kFCKTRyS6CfKM1MgHKfufHxppj2YXv(q9yn45iKM1QgHKfufHxppj2YXv(ivpRCunwDoHFX6yDPs2ucdEB8ycsuYEUWc71C0U)eQgHKfufHxppj2YXv(4iBxXy15kinRnncjlOkcVEEsSLJR8H6XAWZrinRvncjlOkcVEEsSLJR8rYgpQgRoNWVyDSUujBkHb)KOyrjssQbVX5clminRvb9v4j7JyEO6XI1e(fRJ1Lkztjm4T)kBOv0GRKkYaNO5Sg0Ggaa]] )


end
