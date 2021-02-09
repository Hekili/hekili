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
    
    spec:RegisterPack( "Frost Mage", 20210208, [[dKugVaqiKQQEeOqBsvYNuugLOOtjQ4vifZsrLBjkKQDrYVaLgMQOoMO0Yuu1ZqQY0efQRjQuTnKu5BIkfJdjv5CIcX6evY8qQk3duTpqrheuqwisYdfvvtuuiLlckO2iOa(isvfNuuP0krvntrv5MiPQStvP(jOazPiPQ6PQQPQk8vrHKXQkYEb(RidMuhwYIb5XOmzfUm0MP0NvKrJu60cRguG61IcMnHBJk7MQFR0WrIJJuvPLRYZjA6sDDkSDuLVtrgpskNhPY6fvz(uu7hXGSGhG)OAe8E(NNp7ZZ)m1tLnJqpQ7zQd8B6OGGpLILHAcbFV4qWhg4wzt0uF1ec(uk6eBnapaF5ACme8PTBkYCblStrtRbKITCWkdodr1X6SRSnSYGJbl4dzeIo36aiWFuncEp)ZZN955FM6PYMrOh19m9a)YOPDpW)hC5h8Pngd0bqG)aLmWhgHrIM6RMqIgg4wzt4dJWirddGqNrD0r0uV5i65FE(SGViKTe8a8hOTmen4b4DwWdWVyDSo4ZwdVXtsbfcWh9csGdavGg8EEWdWh9csGdavGFX6yDWNvcrQyDSEseYg8fHStEXHGpBibn4n9apaF0liboaub(fRJ1bFwjePI1X6jriBWxeYo5fhc(OuIodLGg8oJbpaF0liboaub(SlA8Ic8lwh8We6ixGsIgMWjA6b(fRJ1bFwjePI1X6jriBWxeYo5fhc(1IGg8o3bpaF0liboaub(SlA8Ic8lwh8We6ixGsIM(iA6b(fRJ1bFwjePI1X6jriBWxeYo5fhc(Yg0G3uh4b4JEbjWbGkWVyDSo4ZkHivSowpjczd(Iq2jV4qWNB5HCO3Gg0GpLdzlhu1GhG3zbpa)I1X6GFDSYXu4nkeiRbF0liboaubAW75bpa)I1X6GVPQXlHcKd9UeGp6fKahaQan4n9apa)I1X6GV9wzdTIg8rVGe4aqfObn4xlcEaENf8a8lwhRd(2BZd90EqGp6fKahaQan498GhGFX6yDWhse5LxDdWh9csGdavGg8MEGhGp6fKahaQaF2fnErb(zs0hYvHh(uYu4nEYeJ2qiiA4e9ZeTzZe9aHmSwLPWB8KjgTHqOgRjNOZHOFr0zs0uoKxAInuzvi06qROjAZMjAidRvbDv4j7HyEO6WI1e9lIgYWAv2WNWtMwBYERSvhwSMOHt0pt05a(fRJ1bFRW4o6an4DgdEa(fRJ1b)GHjF5vGp6fKahaQan4DUdEa(fRJ1bF2YHDs27Xb(OxqcCaOc0G3uh4b4JEbjWbGkWNDrJxuGpKH1QSHpHNmT2K9wzRoSynrB2mrpqidRvzVnp0vhYvHljAys09v8qrQdoKOnBMOpKRcp8PKPWB8KjgTHqq0Vi6bczyTktH34jtmAdHqDixfUKOHjr3xXdfPo4qWVyDSo4hmmjkNHGg8o3aEa(fRJ1b)Rgr5DssPUma(OxqcCaOc0G3upWdWVyDSo4Zf3TNmT2uVhh6n4JEbjWbGkqdENrapa)I1X6GVK2W2HpLOSMWd8rVGe4aqfObVZ(m4b4JEbjWbGkWNDrJxuG)z4ODVjunDHuqxkybtGk0liboi6xeDx3e2kbYdfen9bNOfipuq0Vi6bczyTk7T5HUASMCWVyDSo4BVv2jF5vGg8oBwWdWh9csGdavGp7IgVOa)ZWr7EtOAeswqreED0Lylhx5df6fKahe9lIMTRySMCfKH1MgHKfueHxhDj2YXv(qDynOJOFr0qgwRAeswqreED0Lylhx5JKnounwto4xSowh8TXHjirjBqdENDEWdWh9csGdavGp7IgVOaFUYlffwt0WKOP3Ze9lIUyDWdtOJCbkjAycNOPoI(frt)j6ZWr7EtOAsuSOej7vtCO3sf6fKahGFX6yDWVow5ycPgfXkJ1bn4Dw6bEa(fRJ1bFeADOv0Gp6fKahaQan4D2mg8a8rVGe4aqf4ZUOXlkW)mC0U3eQMeflkrYE1eh6TuHEbjWbr)IO7sGERKuer3HpLcgQqVGe4GOFr09v8qrQdoKOPpIE6wdFKQfvqIiV8QBOoKRcxc(fRJ1b)GHjr5me0G3zZDWdWh9csGdavGVezG)ZQSGFX6yDW3ufn4ZUOXlkW)mC0U3eQMeflkrYE1eh6TuHEbjWbr)IO7sGERKuer3HpLcgQqVGe4a0G3zPoWdWVyDSo4BVv2qRObF0liboaubAqd(SHe8a8ol4b4JEbjWbGkWNDrJxuGpLd5LwRnnXgQGrxIhgUKOnBMOTXeTD6qUkCjrtFen9Eg8lwhRd(u2owh0G3ZdEa(fRJ1b)bwnTq75i4JEbjWbGkqdEtpWdWh9csGdavGp7IgVOa)I1bpmHoYfOKOPpIMEe9lIotIMT(WiALmOq764iXvIGHk0liboiAZMjA5AiGcFOmvYgfLpsuULYfytNc9csGdIohWVyDSo4Zf3TNmT2uVhh6nObVZyWdWh9csGdavGp7IgVOaF2UIXAYvbJUepmCP6qUkCjrdtIo78e9lIgYWAvNHJP1MOSMWtnwto4xSowh8pdhtRnrznHhObVZDWdWh9csGdavGp7IgVOaFidRvDgoMwBIYAcp1yn5e9lIotIgYWAvbJUepmCPASMCI2SzIUlb6T6mCmT2eL1eEk0liboi6Ci6xeDMenKH1QKIGLHuWq1yn5eTzZeDX6GhMqh5cus0WeorpprNd4xSowh8dgDjEy4sqdEtDGhGp6fKahaQaF2fnErb(NHJ29MqvJCu2Rejt1rrHEbjWbr)IOHmSwfsnAldzhRRmOq0Vi6mjAkhYlTwBAInubJUepmCjrB2mrBJjA70HCv4sIM(iA69mrNd4xSowh87GdtMQJcObVZnGhGFX6yDW3qIPOroj4JEbjWbGkqdEt9apa)I1X6GpKy3rYAC0b(OxqcCaOc0G3zeWdWVyDSo4dHNeVme(e4JEbjWbGkqdEN9zWdWVyDSo4lIjABzcgSXyId9g8rVGe4aqfObVZMf8a8lwhRd(24qiXUdWh9csGdavGg8o78GhGFX6yDWVCgk7RejwjeGp6fKahaQan4Dw6bEa(fRJ1bFOAkT2uFbldsWh9csGdavGg0GVSbpaVZcEa(OxqcCaOc8zx04ff4NjrFixfE4tjtH34jtmAdHGOHt0pt0Mnt0deYWAvMcVXtMy0gcHASMCIohI(frNjrt5qEPj2qLvHqRdTIMOnBMOHmSwf0vHNShI5HQdlwt0Vi6mjAkhYlnXgQSQjrXIsKKuImGeTzZenLd5LMydvwL9wzdTIMOFr0zs00FIMT(WiAvCyATPMwmvsg6dCOqVGe4GOnBMOz7kgRjxD1ikVtsk1Lb1HCv4sI2SzI(mC0U3eQShI5f(uYu4dPc9csGdIohI2SzIMYH8stSHkR6QruENKuQldeTzZenKH1QSHpHNmT2K9wzRoSynrdNOFMOFr0zs0deYWAvCXD7jtRn17XHERmOq0Mnt0qgwRYEiMx4tjtHpKkdkeTzZenKH1QqQrP8bosu2g9okH6WI1eDoeDoeDoGFX6yDW3kmUJoqdEpp4b4xSowh8T3Mh6P9GaF0liboaubAWB6bEa(OxqcCaOc8zx04ff4dzyTk7HyEHpLUkCLbfI2SzIUyDWdtOJCbkjAycNONh8lwhRd(qIiV8QBaAW7mg8a8rVGe4aqf4ZUOXlkW)qUk8WNsMcVXtMy0gcbrdNOZs0Vi6bczyTktH34jtmAdHqDixfUe8lwhRd(xrxATj7TYg0G35o4b4JEbjWbGkWNDrJxuG)HCv4HpLmfEJNmXOnecI(frpqidRvzk8gpzIrBieQd5QWLenmjAwj7uhCirtdr3xXdfPo4qWVyDSo4pjkwuIKKsKbe0G3uh4b4JEbjWbGkWNDrJxuG)HCv4HpLmfEJNmXOnecI(frFixfE4tjtH34jtmAdHGOHjrdzyTkB4t4jtRnzVv2Qdlwt0Vi6bczyTktH34jtmAdHqDixfUKOHjr3xXdfPo4qWVyDSo4hmmjkNHGg8o3aEa(fRJ1bF2YHDs27Xb(OxqcCaOc0G3upWdWVyDSo4hmm5lVc8rVGe4aqfObVZiGhGp6fKahaQaF2fnErb(qgwRYEiMx4tjtHpKkdke9lIUyDWdtOJCbkjA4eDwWVyDSo4F1ikVtsk1LbqdEN9zWdWh9csGdavGp7IgVOaFidRvzdFcpzATj7TYwDyXAI2SzIEGqgwRYEBEORoKRcxs0WKO7R4HIuhCi4xSowh8dgMeLZqqdENnl4b4xSowh8rO1Hwrd(OxqcCaOc0G3zNh8a8rVGe4aqf4ZUOXlkWptIM(t0NHJ29MqL9qmVWNsMcFivOxqcCq0Mnt0fRdEycDKlqjrdt4e98eDoe9lIgYWAvqxfEYEiMhQoSyn4xSowh8VAeL3jjL6YaObVZspWdWVyDSo4Zf3TNmT2uVhh6n4JEbjWbGkqdENnJbpaF0liboaub(SlA8Ic8HmSw1z4yATjkRj8uJ1Kt0Vi6mjA5AiGcFOMULhMcNxmTx1X6k0liboiAZMjA5AiGcFOSbkgP1MGeRuUCsf6fKaheTzZeDX6GhMqh5cus0WeorpprNd4xSowh8L0g2o8PeL1eEGg8oBUdEa(OxqcCaOc8zx04ff4FgoA3Bcvtxif0LcwWeOc9csGdI(fr31nHTsG8qbrtFWjAbYdfe9lIEGqgwRYEBEORgRjh8lwhRd(2BLDYxEfObVZsDGhGp6fKahaQaF2fnErb(NHJ29Mq1iKSGIi86OlXwoUYhk0liboi6xenBxXyn5kidRnncjlOicVo6sSLJR8H6WAqhr)IOHmSw1iKSGIi86OlXwoUYhP6yLJQXAYb)I1X6GFDSYXesnkIvgRdAW7S5gWdWh9csGdavGp7IgVOa)ZWr7EtOAeswqreED0Lylhx5df6fKahe9lIMTRySMCfKH1MgHKfueHxhDj2YXv(qDynOJOFr0qgwRAeswqreED0Lylhx5JKnounwto4xSowh8TXHjirjBqdENL6bEa(OxqcCaOc8zx04ff4dzyTkORcpzpeZdvhwSg8lwhRd(tIIfLijPezabn4D2mc4b4xSowh8T3kBOv0Gp6fKahaQanObFULhYHEdEaENf8a8rVGe4aqf4ZUOXlkWhYWAvbdtwXIs1yn5GFX6yDWpyyYkwucAW75bpaF0liboaub(SlA8Ic85kVuuynrdtIMEpt0Vi6I1bpmHoYfOKOHjCIEEWVyDSo4xhRCmHuJIyLX6Gg8MEGhGFX6yDW3ghMGeLSbF0liboaubAW7mg8a8lwhRd(bdtIYzi4JEbjWbGkqdAqd(8WtgRdEp)ZZN95S07zW3uDE4tsWpJcgI6)DU9n9tUiAI(bTirhCu2RjA7Ee9SAXze9H0VgXHdIwUCirxg9YvnoiAgTLpHsfHF(chj6SpNlIo)RZdVghe9SZWr7EtO6PzeDVe9SZWr7EtO6jf6fKahZi6mZsTCue(5lCKOZMnxeD(xNhEnoi6zNHJ29Mq1tZi6Ej6zNHJ29Mq1tk0liboMr0zMLA5Oi8Zx4irND(Cr05FDE414GONDgoA3BcvpnJO7LONDgoA3BcvpPqVGe4ygrxnrddddkFeDMzPwokc)8fos0zZ4Cr05FDE414GON1La9w90mIUxIEwxc0B1tk0liboMr0zMLA5Oi8Zx4irNnJZfrN)15HxJdIE2z4ODVju90mIUxIE2z4ODVju9Kc9csGJzeDMzPwokc)8fos0zZ9Cr05FDE414GON1La9w90mIUxIEwxc0B1tk0liboMr0vt0WWWGYhrNzwQLJIWpFHJeD2CpxeD(xNhEnoi6zNHJ29Mq1tZi6Ej6zNHJ29Mq1tk0liboMr0zMLA5Oi8j8ZOGHO(FNBFt)KlIMOFqls0bhL9AI2UhrpJnKZi6dPFnIdheTC5qIUm6LRACq0mAlFcLkc)8fos00lxeD(xNhEnoi6zS1hgrREAgr3lrpJT(WiA1tk0liboMr0zMLA5Oi8Zx4irtVCr05FDE414GONjxdbu4d1tZi6Ej6zY1qaf(q9Kc9csGJzeDMzPwokc)8fos05EUi68Vop8ACq0Z6sGEREAgr3lrpRlb6T6jf6fKahZi6mZsTCue(5lCKOPUCr05FDE414GONDgoA3BcvpnJO7LONDgoA3BcvpPqVGe4ygrNzwQLJIWNWpJcgI6)DU9n9tUiAI(bTirhCu2RjA7Ee9mzpJOpK(1ioCq0YLdj6YOxUQXbrZOT8juQi8Zx4irNnxeD(xNhEnoi6zNHJ29Mq1tZi6Ej6zNHJ29Mq1tk0liboMr0zMLA5Oi8Zx4irNnxeD(xNhEnoi6zS1hgrREAgr3lrpJT(WiA1tk0liboMr0zMLA5Oi8Zx4irND(Cr05FDE414GONDgoA3BcvpnJO7LONDgoA3BcvpPqVGe4ygrNzwQLJIWpFHJeD2moxeD(xNhEnoi6zY1qaf(q90mIUxIEMCneqHpupPqVGe4ygrN58ulhfHF(chj6S5EUi68Vop8ACq0ZodhT7nHQNMr09s0ZodhT7nHQNuOxqcCmJOZml1Yrr4NVWrIol1LlIo)RZdVghe9SZWr7EtO6PzeDVe9SZWr7EtO6jf6fKahZi6mZsTCue(5lCKOZMBYfrN)15HxJdIE2z4ODVju90mIUxIE2z4ODVju9Kc9csGJzeDMzPwokcFc)ClhL9ACq0uhrxSowNOfHSLkcFWxsbzG3uxgd(uU1gce8HryKOP(QjKOHbUv2e(Wims0Wai0zuhDen1BoIE(NNplHpHpmcJenmm1qMrJdIgcT7HenB5GQMOHWPWLkIggIXqkTKO91ZOtBDCwdbrxSowxs0RlOtr4xSowxQOCiB5GQMg4WwhRCmfEJcbYAc)I1X6sfLdzlhu10ahwPbh36jtvJxcfih6Dji8lwhRlvuoKTCqvtdCyT3kBOv0e(e(Wims0WWudzgnoiAKhE0r0DWHeDtls0fR3JOdjrx8Qquqcur4xSowxcNTgEJNKckee(fRJ1L0ahwwjePI1X6jri758IdHZgsc)I1X6sAGdlReIuX6y9KiK9CEXHWrPeDgkj8lwhRlPboSSsisfRJ1tIq2Z5fhcVwCUWcVyDWdtOJCbkHjC6r4xSowxsdCyzLqKkwhRNeHSNZloeUSNlSWlwh8We6ixGs6JEe(fRJ1L0ahwwjePI1X6jri758IdHZT8qo0BcFc)I1X6svTiC7T5HEApic)I1X6svTinWHfse5LxDdc)I1X6svTinWH1kmUJU5cl8mpKRcp8PKPWB8KjgTHqa)zZMhiKH1QmfEJNmXOnec1yn558ktkhYlnXgQSkeADOv0MndzyTkORcpzpeZdvhwS(fKH1QSHpHNmT2K9wzRoSyn8NZHWVyDSUuvlsdCydgM8Lxr4xSowxQQfPboSSLd7KS3JJWVyDSUuvlsdCydgMeLZW5clCidRvzdFcpzATj7TYwDyXAZMhiKH1QS3Mh6Qd5QWLWSVIhksDWHMnFixfE4tjtH34jtmAdH41aHmSwLPWB8KjgTHqOoKRcxcZ(kEOi1bhs4xSowxQQfPboSxnIY7KKsDzGWVyDSUuvlsdCy5I72tMwBQ3Jd9MWVyDSUuvlsdCyL0g2o8PeL1eEe(fRJ1LQArAGdR9wzN8LxnxyHFgoA3Bcvtxif0LcwWe4RUUjSvcKhkOp4cKhkEnqidRvzVnp0vJ1Kt4xSowxQQfPboS24WeKOK9CHf(z4ODVjuncjlOicVo6sSLJR8Xl2UIXAYvqgwBAeswqreED0Lylhx5d1H1GUxqgwRAeswqreED0Lylhx5JKnounwtoHFX6yDPQwKg4WwhRCmHuJIyLX6Zfw4CLxkkSgM075xfRdEycDKlqjmHtDVO)NHJ29Mq1KOyrjs2RM4qVLe(fRJ1LQArAGdlcTo0kAc)I1X6svTinWHnyysuodNlSWpdhT7nHQjrXIsKSxnXHElF1La9wjPiIUdFkfm8vFfpuK6GdPVPBn8rQwubjI8YRUH6qUkCjHFX6yDPQwKg4WAQIEojYG)Sk7CHf(z4ODVjunjkwuIK9Qjo0B5RUeO3kjfr0D4tPGHe(fRJ1LQArAGdR9wzdTIMWNWVyDSUuXgs4u2owFUWcNYH8sR1MMydvWOlXddxA2SnMOTthYvHlPp69mHFX6yDPInK0ah2bwnTq75iHFX6yDPInK0ahwU4U9KP1M694qVNlSWlwh8We6ixGs6JEVYKT(WiALmOq764iXvIGHMnlxdbu4dLPs2OO8rIYTuUaB6YHWVyDSUuXgsAGd7z4yATjkRj8MlSWz7kgRjxfm6s8WWLQd5QWLWm78VGmSw1z4yATjkRj8uJ1Kt4xSowxQydjnWHny0L4HHlNlSWHmSw1z4yATjkRj8uJ1K)ktidRvfm6s8WWLQXAYnBUlb6T6mCmT2eL1eE58ktidRvjfbldPGHQXAYnBUyDWdtOJCbkHj85ZHWVyDSUuXgsAGdBhCyYuDuMlSWpdhT7nHQg5OSxjsMQJYlidRvHuJ2Yq2X6kdkVYKYH8sR1MMydvWOlXddxA2SnMOTthYvHlPp69Coe(fRJ1Lk2qsdCynKykAKts4xSowxQydjnWHfsS7izno6i8lwhRlvSHKg4WcHNeVme(eHFX6yDPInK0ahwrmrBltWGngtCO3e(fRJ1Lk2qsdCyTXHqIDhe(fRJ1Lk2qsdCylNHY(krIvcbHFX6yDPInK0ahwOAkT2uFbldscFcFyegj6mAHSGe4GOHqwzirIMkr4za2pTbhhEeDij6IOPik6WJOz0Ubdve(Wims0fRJ1LkULhYHEdhseEgsLt3CHfo3Yd5qVvJq2LZqyM9zc)I1X6sf3Yd5qVPboSbdtwXIY5clCidRvfmmzflkvJ1Kt4xSowxQ4wEih6nnWHTow5ycPgfXkJ1NlSW5kVuuynmP3ZVkwh8We6ixGsycFEc)I1X6sf3Yd5qVPboS24WeKOKnHFX6yDPIB5HCO30ah2GHjr5mKWNWVyDSUujB4wHXD0nxyHN5HCv4HpLmfEJNmXOnec4pB28aHmSwLPWB8KjgTHqOgRjpNxzs5qEPj2qLvHqRdTI2SzidRvbDv4j7HyEO6WI1VYKYH8stSHkRAsuSOejjLidOzZuoKxAInuzv2BLn0k6xzs)zRpmIwfhMwBQPftLKH(ahMnZ2vmwtU6QruENKuQldQd5QWLMnFgoA3Bcv2dX8cFkzk8HmhZMPCiV0eBOYQUAeL3jjL6YGzZqgwRYg(eEY0At2BLT6WI1WF(vMdeYWAvCXD7jtRn17XHERmOy2mKH1QShI5f(uYu4dPYGIzZqgwRcPgLYh4irzB07OeQdlwNto5q4xSowxQKnnWH1EBEON2dIWVyDSUujBAGdlKiYlV6gZfw4qgwRYEiMx4tPRcxzqXS5I1bpmHoYfOeMWNNWVyDSUujBAGd7v0LwBYERSNlSWpKRcp8PKPWB8KjgTHqap7RbczyTktH34jtmAdHqDixfUKWVyDSUujBAGd7KOyrjsskrgW5cl8d5QWdFkzk8gpzIrBieVgiKH1QmfEJNmXOnec1HCv4syYkzN6GdPPVIhksDWHe(fRJ1LkztdCydgMeLZW5cl8d5QWdFkzk8gpzIrBieVoKRcp8PKPWB8KjgTHqatidRvzdFcpzATj7TYwDyX6xdeYWAvMcVXtMy0gcH6qUkCjm7R4HIuhCiHFX6yDPs20ahw2YHDs27Xr4xSowxQKnnWHnyyYxEfHFX6yDPs20ah2Rgr5DssPUmmxyHdzyTk7HyEHpLmf(qQmO8QyDWdtOJCbkHNLWVyDSUujBAGdBWWKOCgoxyHdzyTkB4t4jtRnzVv2QdlwB28aHmSwL928qxDixfUeM9v8qrQdoKWVyDSUujBAGdlcTo0kAc)I1X6sLSPboSxnIY7KKsDzyUWcpt6)z4ODVjuzpeZl8PKPWhsZMlwh8We6ixGsycF(CEbzyTkORcpzpeZdvhwSMWVyDSUujBAGdlxC3EY0At9ECO3e(fRJ1LkztdCyL0g2o8PeL1eEZfw4qgwR6mCmT2eL1eEQXAYFLPCneqHput3YdtHZlM2R6yDZMLRHak8HYgOyKwBcsSs5YjnBUyDWdtOJCbkHj85ZHWVyDSUujBAGdR9wzN8LxnxyHFgoA3Bcvtxif0LcwWe4RUUjSvcKhkOp4cKhkEnqidRvzVnp0vJ1Kt4xSowxQKnnWHTow5ycPgfXkJ1NlSWpdhT7nHQrizbfr41rxITCCLpEX2vmwtUcYWAtJqYckIWRJUeB54kFOoSg09cYWAvJqYckIWRJUeB54kFKQJvoQgRjNWVyDSUujBAGdRnombjkzpxyHFgoA3BcvJqYckIWRJUeB54kF8ITRySMCfKH1MgHKfueHxhDj2YXv(qDynO7fKH1QgHKfueHxhDj2YXv(izJdvJ1Kt4xSowxQKnnWHDsuSOejjLid4CHfoKH1QGUk8K9qmpuDyXAc)I1X6sLSPboS2BLn0kAqdAaaa]] )


end
