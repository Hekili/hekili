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

    
    spec:RegisterPack( "Frost Mage", 20201117, [[deuwRaqiaQupcLq2eqzuuk5uuk1RaWSOuClusvzxI8lLsdJc6yaXYuO6zkuAAOe5Aku02qjLVbqvJtHcNdLqTousvmpucUNs1(aiheLuLwOsXdrjvvxeGkzJOKkojavyLuIBIsQ0ovipvutLs1EL8xcdgrhwyXi8yqtwjxgAZe9zanAG0PjTAaQOxJsYSr1TrXUP63QmCfCCaklxvphPPl11POTJs9Dk04rjQZduTEkW8PK2VIUaPSx5v0ynACdh3qqabKXibcl2WXA44vUbFaR8qazvaeRShmyLzD(J2tsw3aiw5HaC(fRYELPN5dXkdA3duwpB3cuBqnjsWJzlvzm5rRNd)q2BPkdCBLjmvEd4WlIkVIgRrJB44gcciGmgjqyXgo(yogvomBqVVYzLH1FLbvxl0lIkVqkSYSOjjRBaeNKSo)r7Pfw0KC0XgziWFsccG3Mj54goUHvMR0Mw2RmsPOdrAzVgbszVYbS1ZRmqZ4xA4ItkcdW)AqRm6bbhx1MQRrJx2RCaB98klpOjfxIWa81gfeyWuz0dcoUQnvxJgBzVYbS1ZRmdYCp4Itk4MqDjwpgm0kJEqWXvTP6Aelv2RCaB98ktWVBjoPObffOJmGxz0dcoUQnvxJgZYELdyRNx5bZxLGRoqbbpODLrpi44Q2uDnI1k7voGTEELFDyGJc1f0HaIvg9GGJRAt11iaFzVYOheCCvBQCaB98kdphIE)rJlHKhmyL5QJc4QYSw11OXOSxz0dcoUQnvg(AJVgvUJhi2jqXG3GMgG9KeqtYXWWjPvRtYoEGyNafdEdAAa2tswysoUHtsRwNKsfiOT4rMqD6KKfMKJByLdyRNx5hJb1bkK8GbPvxJyXL9kJEqWXvTPYWxB81OYeMsz6riR4iLkK3dXK5qLdyRNx5guuy6eNPVeY7Hy11iqmSSx5a265v2498fBuDXJ0ZdhIvg9GGJRAt1vx5fkdtEx2RrGu2RCaB98kdptVXNoGCELrpi44Q2uDnA8YELrpi44Q2u5a265vggCUiGTEUGR0UYCL2cpyWkdx0QRrJTSxz0dcoUQnvoGTEELHbNlcyRNl4kTRmxPTWdgSYiLIoePvxJyPYELrpi44Q2uz4Rn(Au5a2kBuGoYOiDscO9jjlv5a265vggCUiGTEUGR0UYCL2cpyWkhhwDnAml7vg9GGJRAtLHV24RrLdyRSrb6iJI0jjlmjzPkhWwpVYWGZfbS1ZfCL2vMR0w4bdwzAxDnI1k7vg9GGJRAtLdyRNxzyW5Ia265cUs7kZvAl8GbRmZXgzqVRU6kp8i8yiIUSxJaPSx5a265voEy4Oq9g5Ce2vg9GGJRAt11OXl7voGTEELngn(cKJmO3bVYOheCCvBQUgn2YELdyRNxz5F0M44DLrpi44Q2uD1vooSSxJaPSx5a265vw(NbOlUNOYOheCCvBQUgnEzVYbS1ZRmbxnWG4xvg9GGJRAt11OXw2Rm6bbhx1MkdFTXxJkBRj5JmH6Qduyu9gFQacQY5tY9jPHtsRwNKlKWuktgvVXNkGGQCEADg9jPTNKGnjT1KC4r2cGWvcKesCoXX7jPvRtsctPmr8H6c5JOby6Xa2tsWMKeMszsQoq8PItkK)r70JbSNK7tsdNK2UYbS1ZRSKB(p4vxJyPYELdyRNxzfIc)yhvg9GGJRAt11OXSSx5a265vgEmylO99mvg9GGJRAt11iwRSxz0dcoUQnvg(AJVgvMWukts1bIpvCsH8pANEmG9K0Q1j5cjmLYK8pdqp9itOoDscOjz)bBKlALbNKwTojFKjuxDGcJQ34tfqqvoFsc2KCHeMszYO6n(ubeuLZtpYeQtNKaAs2FWg5IwzWkhWwpVYkef8WHy11iaFzVYbS1ZR8hln8wqhINvvg9GGJRAt11OXOSx5a265vMcQkB1bkgoJ4xz0dcoUQnvxJyXL9khWwpVYm6)3tfNu03ZGExz0dcoUQnvxJaXWYELrpi44Q2uz4Rn(Au530r59aXeWxPCWfkuHCmHaMPomGRjjytYoEGyN4iBKpjzH9jjhzJ8jjytYfsykLj5FgGEADg9khWwpVYY)OTWp2r11iqaPSxz0dcoUQnvg(AJVgv(nDuEpqmTukuh4Qhp4c4XWe(kHaMPomGRjjyts4D81z0teMsPyPuOoWvpEWfWJHj8v6Xyb(KeSjjHPuMwkfQdC1JhCb8yycFjK6JP1z0RCaB98kl1hfe8G2vxJaz8YELrpi44Q2uz4Rn(AuzMWJ0aSNKaAsowdNKGnjdyRSrb6iJI0jjG2NKSwLdyRNx54HHJcKLh4hvpV6AeiJTSx5a265vgjoN44DLrpi44Q2uDncewQSxz0dcoUQnvg(AJVgv(nDuEpqmbKhqn4c5hazqVPjeWm1HbCnjbBs2bh9orh4A3QduOqmHEqWX1KeSjz)bBKlALbNKSWKe4FM(sehMi4Qbge)k9itOoTYbS1ZRScrbpCiwDncKXSSx5a265vw(hTjoExz0dcoUQnvxDLHlAzVgbszVYOheCCvBQm81gFnQ8WJSfNukacxjfcUGnQoDsA16KuQabTfpYeQtNKSWKCSgw5a265vE4A98QRrJx2Rm6bbhx1MkdFTXxJktptoH6RKXG2ip8Ly4VHxXg8e6bbhxvoGTEELz0)VNkoPOVNb9U6A0yl7voGTEELxy0GsCVJvg9GGJRAt11iwQSxz0dcoUQnvg(AJVgvgEhFDg9KcbxWgvNMEKjuNojb0KeKXNKGnjjmLY0B6O4KIHZi(P1z0RCaB98k)MokoPy4mIF11OXSSxz0dcoUQnvg(AJVgvMWuktVPJItkgoJ4NwNrVYbS1ZRScbxWgvNwDnI1k7vg9GGJRAtLHV24RrLFthL3detnYmCFWfgJFiHaMPomGRjjytsBnjPh)MKwTojjmLYeYYGgM0wppzomjT9KeSjPTMKdpYwCsPaiCLui4c2O60jPvRtsPce0w8itOoDsYctYXA4K02voGTEELBLbfgJFO6AeGVSx5a265v2KIcTrgALrpi44Q2uDnAmk7voGTEELj43TesZh8kJEqWXvTP6AelUSx5a265vMaFk(SsDGvg9GGJRAt11iqmSSx5a265vMRabTPcaNMlGmO3vg9GGJRAt11iqaPSx5a265vwQpsWVBvz0dcoUQnvxJaz8YELdyRNx5WHiT)GlGbNxz0dcoUQnvxJazSL9khWwpVYebqXjf9RqwrRm6bbhx1MQRUY0USxJaPSxz0dcoUQnvg(AJVgv2wtYhzc1vhOWO6n(ubeuLZNK7tsdNKwTojxiHPuMmQEJpvabv5806m6tsBpjbBsARj5WJSfaHReijK4CIJ3tsRwNKeMszI4d1fYhrdW0JbSNKGnjT1KC4r2cGWvcKeqEa1GlOdkRWjPvRtYHhzlacxjqsY)OnXX7jPvRtYHhzlacxjqsFS0WBbDiEwnjTADssykLjP6aXNkoPq(hTtpgWEsUpjnCsc2K0wtYfsykLjg9)7PItk67zqVtMdtsRwNKeMszs(iAG6afgvFrtMdtsRwNKeMszcz5HWx4smCn6Tg80JbSNK2EsA7jPTRCaB98kl5M)dE11OXl7voGTEELL)za6I7jQm6bbhx1MQRrJTSxz0dcoUQnvg(AJVgvMWuktYhrduhO4d1tMdtsRwNKbSv2OaDKrr6Keq7tYXRCaB98ktWvdmi(v11iwQSxz0dcoUQnvg(AJVgv(rMqD1bkmQEJpvabv58j5(KeKjjytYfsykLjJQ34tfqqvop9itOoTYbS1ZR8hGloPq(hTRUgnML9kJEqWXvTPYWxB81OYpYeQRoqHr1B8PciOkNpjbBsUqctPmzu9gFQacQY5Phzc1PtsanjHbTfTYGtsaMK9hSrUOvgSYbS1ZRmqEa1GlOdkRWQRrSwzVYOheCCvBQm81gFnQ8JmH6Qduyu9gFQacQY5tsWMKpYeQRoqHr1B8PciOkNpjb0KKWukts1bIpvCsH8pANEmG9KeSj5cjmLYKr1B8PciOkNNEKjuNojb0KS)GnYfTYGvoGTEELvik4HdXQRra(YELdyRNxz4XGTG23Zuz0dcoUQnvxJgJYELdyRNxzfIc)yhvg9GGJRAt11iwCzVYOheCCvBQm81gFnQmHPuMKpIgOoqHr1x0K5WKeSjzaBLnkqhzuKoj3NKGu5a265v(JLgElOdXZQQRrGyyzVYOheCCvBQm81gFnQmHPuMKQdeFQ4Kc5F0o9ya7jPvRtYfsykLj5FgGE6rMqD6KeqtY(d2ix0kdw5a265vwHOGhoeRUgbciL9khWwpVYiX5ehVRm6bbhx1MQRrGmEzVYOheCCvBQm81gFnQSTMKaUNKVPJY7bIj5JObQduyu9fnHaMPomGRjPvRtYa2kBuGoYOiDscO9j54tsBpjbBssykLjIpuxiFenatpgWUYbS1ZR8hln8wqhINvvxJazSL9khWwpVYm6)3tfNu03ZGExz0dcoUQnvxJaHLk7vg9GGJRAtLHV24RrLjmLY0B6O4KIHZi(P1z0NKGnjT1KKEMCc1xjG)XgfQZwbEF065j0dcoUMKwTojPNjNq9vsQiFjoPGGFu6XqtOheCCnjTADsgWwzJc0rgfPtsaTpjhFsA7khWwpVYuqvzRoqXWze)QRrGmML9kJEqWXvTPYWxB81OYVPJY7bIjGVs5GluOc5ycbmtDyaxtsWMKD8aXoXr2iFsYc7tsoYg5tsWMKlKWuktY)ma906m6voGTEELL)rBHFSJQRrGWAL9kJEqWXvTPYWxB81OYVPJY7bIPLsH6ax94bxapgMWxjeWm1HbCnjbBscVJVoJEIWukflLc1bU6XdUaEmmHVspglWNKGnjjmLY0sPqDGRE8GlGhdt4lr8WWX06m6voGTEELJhgokqwEGFu98QRrGa4l7vg9GGJRAtLHV24RrLFthL3detlLc1bU6XdUaEmmHVsiGzQdd4Asc2KeEhFDg9eHPukwkfQdC1JhCb8yycFLEmwGpjbBssykLPLsH6ax94bxapgMWxcP(yADg9khWwpVYs9rbbpOD11iqgJYELrpi44Q2uz4Rn(AuzctPmr8H6c5JOby6Xa2voGTEELbYdOgCbDqzfwDncewCzVYbS1ZRS8pAtC8UYOheCCvBQU6kZCSrg07YEncKYELrpi44Q2uz4Rn(AuzMJnYGENwkTdhItsanjbXWkhWwpVYeC1zv11OXl7vg9GGJRAtLHV24RrLjmLYKcrHKFinToJELdyRNxzfIcj)qA11OXw2Rm6bbhx1MkdFTXxJkZeEKgG9KeqtYXA4KeSjzaBLnkqhzuKojb0(KC8khWwpVYXddhfilpWpQEE11iwQSx5a265vwQpki4bTRm6bbhx1MQRrJzzVYbS1ZRScrbpCiwz0dcoUQnvxD1vMn(u98A04goUHGaciSuLngVRoqALbCWmCFJRjjGFsgWwpFsYvAtttlvMoGWAeRXsvE4pPYXkZIMKSUbqCsY68hTNwyrtYrhBKHa)jjiaEBMKJB44goTmTWIMKaUyzeA24AssGY7Xjj8yiIEssGavNMMKSEHqCOPts)CwFGgpJ0KpjdyRNtNKNZbpnTeWwpNMgEeEmerdW(24HHJc1BKZrypTeWwpNMgEeEmerdW(wQjdZ5cJrJVa5id6DWNwcyRNttdpcpgIObyFR8pAtC8EAzAHfnjbCXYi0SX1KezJp4tYwzWjzdkojdyF)KuPtYGDO8GGJPPLa2650D4z6n(0bKZNwcyRNtbyFlm4CraB9CbxPTnEWG7WfDAjGTEofG9TWGZfbS1ZfCL224bdUJuk6qKoTeWwpNcW(wyW5Ia265cUsBB8Gb3JdTrL7bSv2OaDKrrkG2zPPLa265ua23cdoxeWwpxWvABJhm4oTTrL7bSv2OaDKrrklWstlbS1ZPaSVfgCUiGTEUGR02gpyWDMJnYGEpTmTeWwpNMId3L)za6I7jMwcyRNttXHaSVLGRgyq8RPLa2650uCia7BLCZ)b3gvUBRhzc1vhOWO6n(ubeuLZ3n0Q1fsykLjJQ34tfqqvopToJUTbZwdpYwaeUsGKqIZjoEB1kHPuMi(qDH8r0am9yaBWimLYKuDG4tfNui)J2PhdyVBOTNwcyRNttXHaSVvHOWp2X0saB9CAkoeG9TWJbBbTVNzAjGTEonfhcW(wfIcE4q0gvUtykLjP6aXNkoPq(hTtpgW2Q1fsykLj5FgGE6rMqDkG6pyJCrRmOvRpYeQRoqHr1B8PciOkNd2cjmLYKr1B8PciOkNNEKjuNcO(d2ix0kdoTeWwpNMIdbyF7hln8wqhINvtlbS1ZPP4qa23sbvLT6afdNr8NwcyRNttXHaSVLr))EQ4KI(Eg07PLa2650uCia7BL)rBHFSdBu5(B6O8EGyc4Ruo4cfQqoMqaZuhgWfyD8aXoXr2iNf25iBKd2cjmLYK8pdqpToJ(0saB9CAkoeG9Ts9rbbpOTnQC)nDuEpqmTukuh4Qhp4c4XWe(kHaMPomGlWG3XxNrprykLILsH6ax94bxapgMWxPhJf4GrykLPLsH6ax94bxapgMWxcP(yADg9PLa2650uCia7BJhgokqwEGFu9CBu5ot4rAa2aASgcwaBLnkqhzuKcODwBAjGTEonfhcW(wK4CIJ3tlbS1ZPP4qa23QquWdhI2OY930r59aXeqEa1GlKFaKb9MMqaZuhgWfyDWrVt0bU2T6afketOheCCbw)bBKlALbzbG)z6lrCyIGRgyq8R0JmH60Pfw0KmGTEonfhcW(wJH22qr4UHjqSrL7VPJY7bIjG8aQbxi)aid6nnHaMPomGlW6GJENOdCTB1bkuiMqpi44AAjGTEonfhcW(w5F0M4490Y0saB9CAcUO7dxRNBJk3hEKT4Ksbq4kPqWfSr1PwTkvGG2Ihzc1PSWynCAjGTEonbxua23YO)FpvCsrFpd6TnQCNEMCc1xjJbTrE4lXWFdVIn4j0dcoUMwcyRNttWffG9TlmAqjU3XPLa2650eCrbyF7B6O4KIHZi(2OYD4D81z0tkeCbBuDA6rMqDkGazCWimLY0B6O4KIHZi(P1z0NwcyRNttWffG9TkeCbBuDQnQCNWuktVPJItkgoJ4NwNrFAjGTEonbxua232kdkmg)GnQC)nDuEpqm1iZW9bxym(HecyM6WaUaZw0JFwTsykLjKLbnmPTEEYCW2GzRHhzloPuaeUskeCbBuDQvRsfiOT4rMqDklmwdT90saB9CAcUOaSV1KIcTrg60saB9CAcUOaSVLGF3sinFWNwcyRNttWffG9Te4tXNvQdCAjGTEonbxua23YvGG2ubGtZfqg07PLa2650eCrbyFRuFKGF3AAjGTEonbxua23goeP9hCbm48PLa2650eCrbyFlrauCsr)kKv0PLPLa2650esPOdr6oqZ4xA4ItkcdW)AqNwcyRNttiLIoePaSVvEqtkUeHb4RnkiWGzAjGTEonHuk6qKcW(wgK5EWfNuWnH6sSEmyOtlbS1ZPjKsrhIua23sWVBjoPObffOJmGpTeWwpNMqkfDisbyF7G5RsWvhOGGh0EAjGTEonHuk6qKcW(2xhg4OqDbDiG40saB9CAcPu0HifG9TWZHO3F04si5bdAdxDuax7S20saB9CAcPu0HifG9TpgdQdui5bdsTrL7D8aXobkg8g00aSb0yyOvRD8aXobkg8g00aSzHXn0QvPce0w8itOoLfg3WPLa2650esPOdrka7BBqrHPtCM(siVhI2OYDctPm9iKvCKsfY7HyYCyAjGTEonHuk6qKcW(wJ3ZxSr1fpsppCioTmTeWwpNMyo2id69obxDwjchCBu5oZXgzqVtlL2HdrabIHtlbS1ZPjMJnYGEdW(wfIcj)qQnQCNWuktkefs(H006m6tlbS1ZPjMJnYGEdW(24HHJcKLh4hvp3gvUZeEKgGnGgRHGfWwzJc0rgfPaAF8PLa2650eZXgzqVbyFRuFuqWdApTeWwpNMyo2id6na7Bvik4HdXPLPLa2650eT3LCZ)b3gvUBRhzc1vhOWO6n(ubeuLZ3n0Q1fsykLjJQ34tfqqvopToJUTbZwdpYwaeUsGKqIZjoEB1kHPuMi(qDH8r0am9yaBWS1WJSfaHReijG8aQbxqhuwHwTo8iBbq4kbss(hTjoEB16WJSfaHReiPpwA4TGoepRSALWukts1bIpvCsH8pANEmG9UHGzRfsykLjg9)7PItk67zqVtMdwTsykLj5JObQduyu9fnzoy1kHPuMqwEi8fUedxJERbp9yaBBBBBpTeWwpNMOna7BL)za6I7jMwcyRNtt0gG9TeC1adIFzJk3jmLYK8r0a1bk(q9K5GvRbSv2OaDKrrkG2hFAjGTEonrBa23(b4ItkK)rBBu5(JmH6Qduyu9gFQacQY57Ga2cjmLYKr1B8PciOkNNEKjuNoTeWwpNMOna7BbYdOgCbDqzfAJk3FKjuxDGcJQ34tfqqvohSfsykLjJQ34tfqqvop9itOofqWG2Iwzqa6pyJCrRm40saB9CAI2aSVvHOGhoeTrL7pYeQRoqHr1B8PciOkNd2JmH6Qduyu9gFQacQY5aIWukts1bIpvCsH8pANEmGnylKWuktgvVXNkGGQCE6rMqDkG6pyJCrRm40saB9CAI2aSVfEmylO99mtlbS1ZPjAdW(wfIc)yhtlbS1ZPjAdW(2pwA4TGoepRSrL7eMszs(iAG6afgvFrtMdGfWwzJc0rgfP7GmTeWwpNMOna7Bvik4HdrBu5oHPuMKQdeFQ4Kc5F0o9yaBRwxiHPuMK)za6Phzc1PaQ)GnYfTYGtlbS1ZPjAdW(wK4CIJ3tlbS1ZPjAdW(2pwA4TGoepRSrL72cW9B6O8EGys(iAG6afgvFrtiGzQdd4YQ1a2kBuGoYOifq7JBBWimLYeXhQlKpIgGPhdypTeWwpNMOna7Bz0)VNkoPOVNb9EAjGTEonrBa23sbvLT6afdNr8TrL7eMsz6nDuCsXWze)06m6Gzl6zYjuFLa(hBuOoBf49rRNNqpi44YQv6zYjuFLKkYxItki4hLEm0e6bbhxwTgWwzJc0rgfPaAFCBpTeWwpNMOna7BL)rBHFSdBu5(B6O8EGyc4Ruo4cfQqoMqaZuhgWfyD8aXoXr2iNf25iBKd2cjmLYK8pdqpToJ(0saB9CAI2aSVnEy4Oaz5b(r1ZTrL7VPJY7bIPLsH6ax94bxapgMWxjeWm1HbCbg8o(6m6jctPuSukuh4Qhp4c4XWe(k9ySahmctPmTukuh4Qhp4c4XWe(sepmCmToJ(0saB9CAI2aSVvQpki4bTTrL7VPJY7bIPLsH6ax94bxapgMWxjeWm1HbCbg8o(6m6jctPuSukuh4Qhp4c4XWe(k9ySahmctPmTukuh4Qhp4c4XWe(si1htRZOpTeWwpNMOna7BbYdOgCbDqzfAJk3jmLYeXhQlKpIgGPhdypTeWwpNMOna7BL)rBIJ3vxDva]] )


end
