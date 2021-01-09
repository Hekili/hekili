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
    
    spec:RegisterPack( "Frost Mage", 20210109, [[dGKAWaqiKk4rQsWMuf(KuLrjv4usf9kKuZsQk3sQu0Ui1VqcddeCmQOLjvvpdjY0qQKRHuP2gvaFtQuyCQsuDovjY6KkX8qQO7bs7de6GubQfcIEOujDrvjkBuvc5JubsNuQuQvIQmtPs1nPce7uvQFQkHQLkvk5PQQPQk6RivOgRQK2lWFf1Gj5WswmOEmktwkxgAZu1NfPrJKCAHvRkHYRPcA2eUnQSBk)wLHJuoosfYYv65enDfxNkTDuvFxegpsuNhPQ1tfA(IO9JyGtWtWVvdcE3pe63jeCcHxs7KUPeDrPxc8h6PHGpTI5WkfbFR4qW)fTNCikhKkfbFAf9IRAGNGV8Cxgc(undnzxOGI0yOYfwZookKbNROM4m2w(HczWXOa8HDdX0Tnam43QbbV7hc97ecoHWlPDs3uIUOeDd(L7q1TG)p46k4tv0AObGb)gkzG)lquoivksuVO9KdH3lqu8kZTw6jQxQpIQFi0VtcpcVxGO6kvLLIscVxGO6MeLdU1WgrjXzclLOMJOAHSGfirbPiC0XABevh(94iQx0IOJHLsuDRkSojQWikzyPcSBo1MIdrTi744qRvtCMud(IqosWtWVH(YvmGNG3obpb)InXzGp7CTbxjnuiaF0kyb2aqcgW7(bpbF0kyb2aqc(fBIZaFwje5InXzzrihWxeYjBfhc(SMemG3uc8e8rRGfydaj4xSjod8zLqKl2eNLfHCaFriNSvCi4JsjAmucgWB6c8e8rRGfydaj4Z2yWnkWVytWhZOHCbkjkicLOOe4xSjod8zLqKl2eNLfHCaFriNSvCi4xhcgWB6g8e8rRGfydaj4Z2yWnkWVytWhZOHCbkjk6KOOe4xSjod8zLqKl2eNLfHCaFriNSvCi4lhWaE7aGNGpAfSaBaib)InXzGpReICXM4SSiKd4lc5KTIdbFUJpYH2agWa(0wKDCW1aEcE7e8e8l2eNb(1YkdZHnOqGSb8rRGfydajyaV7h8e8l2eNb(jQb3mkqo0Msa(OvWcSbGemG3uc8e8l2eNb((9Kd8jgWhTcwGnaKGbmGFDi4j4TtWtWVytCg473Zr0Y3cd(OvWcSbGemG39dEc(fBIZaFyr4OJ12aF0kyb2aqcgWBkbEc(OvWcSbGe8zBm4gf43brTixfwyP5eHn4kZmQcHGOGsuqGOsMKOAiSR3Rte2GRmZOkecD7syevNe1dIQdII2I8ZPSM2PgHpd(edrLmjrb769A4Tcl7xeDe1lwSHOEquWUEV2hwkUY85Z(9KJEXInefuIccevNGFXM4mW3lC3LEWaEtxGNGFXM4mWpyy2o(f4JwblWgasWaEt3GNGFXM4mWNDC4KLZTCGpAfSaBaibd4TdaEc(OvWcSbGe8zBm4gf4d769AFyP4kZNp73to6fl2qujtsune2171(9Cen9ICvysIcIe1SfFuKNGdjQKjjQf5QWclnNiSbxzMrviee1dIQHWUEVorydUYmJQqi0lYvHjjkisuZw8rrEcoe8l2eNb(bdZIYyiyaV7gGNGFXM4mWFRwu2KL0Q1HGpAfSaBaibd49lh8e8l2eNb(CXU3kZNpp3YH2a(OvWcSbGemG3Ve4j4xSjod8Luf(jS0mTlbUGpAfSaBaibd4TtiaEc(OvWcSbGe8zBm4gf4VUg6Vnf1PBif0NdwWeOgTcwGnI6brn1MIJwG8rbrrNqjkbYhfe1dIQHWUEV2VNJOPBxcd8l2eNb((9Kt2o(fyaVD6e8e8rRGfydaj4Z2yWnkWFDn0FBkQBHKf0eHvl9z2XXvwtJwblWgr9GOy3jAxctd7695wizbnry1sFMDCCL10lwn6jQhefSR3RBHKf0eHvl9z2XXvwl7Jf1TlHb(fBIZaFFSygwuYbmG3o7h8e8rRGfydaj4Z2yWnkWNRSstJnefejkkbbI6brvSj4Jz0qUaLefeHsuoar9GOOde16AO)2uuNkkwuISFRuo0gPgTcwGnWVytCg4xlRmmJuMM4KXzGb82jLapb)InXzGpcFg8jgWhTcwGnaKGb82jDbEc(OvWcSbGe8zBm4gf4VUg6Vnf1PIIfLi73kLdTrQrRGfyJOEqutjqB0sAIyMWsZbd1OvWcSrupiQzl(Oipbhsu0jrLUNR1Y1HAyr4OJ120lYvHjb)InXzGFWWSOmgcgWBN0n4j4JwblWgasWxImWhcANGFXM4mWprfd4Z2yWnkWFDn0FBkQtfflkr2VvkhAJuJwblWgr9GOMsG2OL0eXmHLMdgQrRGfydmG3oDaWtWVytCg473toWNyaF0kyb2aqcgWa(SMe8e82j4j4JwblWgasWNTXGBuGpTf5NpVpNYA6GrFMpgMKOsMKO8rkvtErUkmjrrNefLGa4xSjod8PDtCgyaV7h8e8l2eNb(nSgQGV1qWhTcwGnaKGb8MsGNGpAfSaBaibF2gdUrb(fBc(ygnKlqjrrNefLiQhevhef7SMBmAzqJQZWwMRebd1OvWcSrujtsuYZvahwtNOKdkkRLPThTnWHEnAfSaBevNGFXM4mWNl29wz(855wo0gWaEtxGNGpAfSaBaibF2gdUrb(S7eTlHPdg9z(yys9ICvysIcIeLZ(jQhefSR3RxxdZNpt7sGRUDjmWVytCg4VUgMpFM2LaxWaEt3GNGpAfSaBaibF2gdUrb(WUEVEDnmF(mTlbU62LWiQhevhefSR3RLIG5WCWqD7syevYKevXMGpMrd5cusuqekr1pr1j4xSjod8dg9z(yysWaE7aGNGpAfSaBaibF2gdUrb(RRH(Btr9GC0UTe5e1stJwblWgr9GOGD9EnszQkx5eNPDPrupiQoikAlYpFEFoL10bJ(mFmmjrLmjr5JuQM8ICvysIIojkkbbIQtWVytCg4pbhMtulnWaE3napb)InXzGVReZXGCsWhTcwGnaKGb8(LdEc(fBIZaFyXDTS3DPh8rRGfydajyaVFjWtWVytCg4dJRexhgwk4JwblWgasWaE7ecGNGFXM4mWxePunY8lMBlLdTb8rRGfydajyaVD6e8e8l2eNb((yryXDnWhTcwGnaKGb82z)GNGFXM4mWVmgkNTezwjeGpAfSaBaibd4TtkbEc(fBIZaF4knF(8SbZHsWhTcwGnaKGbmGVCapbVDcEc(OvWcSbGe8zBm4gf43brTixfwyP5eHn4kZmQcHGOGsuqGOsMKOAiSR3Rte2GRmZOkecD7syevNe1dIQdII2I8ZPSM2PgHpd(edrLmjrb769A4Tcl7xeDe1lwSHOEquDqu0wKFoL10o1PIIfLilPfoejQKjjkAlYpNYAANA)EYb(edr9GO6GOOdef7SMBm6yX85ZdvyUKm0AytJwblWgrLmjrXUt0UeMERwu2KL0Q1H6f5QWKevYKe16AO)2uu7xeDmS0CIWAsnAfSaBevNevYKefTf5NtznTt9wTOSjlPvRdjQKjjkyxVx7dlfxz(8z)EYrVyXgIckrbbI6br1br1qyxVxZf7ERmF(8ClhAJ2LgrLmjrb769A)IOJHLMtewtQDPrujtsuWUEVgPmTYAylt7g0MOe6fl2quDsuDsuDc(fBIZaFVWDx6bd4D)GNGFXM4mW3VNJOLVfg8rRGfydajyaVPe4j4JwblWgasWNTXGBuGpSR3R9lIogwAERW0U0iQhefDGOK4mHLk1rQDlM9lIogwAERWYYHOsMKOk2e8XmAixGsIcIqjQ(jQKjjQ11q)TPOovuSOez)wPCOnsnAfSaBe1dIArUkSWsZjcBWvMzufcbrbLO6h8l2eNb(WIWrhRTbgWB6c8e8rRGfydaj4Z2yWnkWFrUkSWsZjcBWvMzufcbrbLOCsupiQgc7696eHn4kZmQcHqVixfMe8l2eNb(BrF(8z)EYbmG30n4j4JwblWgasWNTXGBuG)ICvyHLMte2GRmZOkecI6br1qyxVxNiSbxzMrvie6f5QWKefejkwjN8eCirrnrnBXhf5j4qWVytCg4NkkwuISKw4qemG3oa4j4JwblWgasWNTXGBuG)ICvyHLMte2GRmZOkecI6brTixfwyP5eHn4kZmQcHGOGirb769AFyP4kZNp73to6fl2qupiQgc7696eHn4kZmQcHqVixfMKOGirnBXhf5j4qWVytCg4hmmlkJHGb8UBaEc(fBIZaF2XHtwo3Yb(OvWcSbGemG3VCWtWVytCg4hmmBh)c8rRGfydajyaVFjWtWhTcwGnaKGpBJb3OaFyxVx7xeDmS0CIWAsTlnI6brvSj4Jz0qUaLefuIYj4xSjod83QfLnzjTADiyaVDcbWtWhTcwGnaKGpBJb3OaFyxVx7dlfxz(8z)EYrVyXgIkzsIQHWUEV2VNJOPxKRctsuqKOMT4JI8eCi4xSjod8dgMfLXqWaE70j4j4xSjod8r4ZGpXa(OvWcSbGemG3o7h8e8rRGfydaj4Z2yWnkWVdIIoquRRH(BtrTFr0XWsZjcRj1OvWcSrujtsufBc(ygnKlqjrbrOev)evNe1dIc2171WBfw2Vi6iQxSyd4xSjod83QfLnzjTADiyaVDsjWtWVytCg4Zf7ERmF(8ClhAd4JwblWgasWaE7KUapbF0kyb2aqc(SngCJc8HD9E96Ay(8zAxcC1TlHrupiQoik55kGdRPt3JpMdJFKEBnXzA0kyb2iQKjjk55kGdRP9bkA5ZNHfNuECsnAfSaBevYKevXMGpMrd5cusuqekr1pr1j4xSjod8Luf(jS0mTlbUGb82jDdEc(OvWcSbGe8zBm4gf4VUg6Vnf1PBif0NdwWeOgTcwGnI6brn1MIJwG8rbrrNqjkbYhfe1dIQHWUEV2VNJOPBxcd8l2eNb((9Kt2o(fyaVD6aGNGpAfSaBaibF2gdUrb(RRH(BtrDlKSGMiSAPpZooUYAA0kyb2iQhef7or7syAyxVp3cjlOjcRw6ZSJJRSMEXQrpr9GOGD9EDlKSGMiSAPpZooUYA5AzLH62LWa)InXzGFTSYWmszAItgNbgWBNDdWtWhTcwGnaKGpBJb3Oa)11q)TPOUfswqtewT0NzhhxznnAfSaBe1dIIDNODjmnSR3NBHKf0eHvl9z2XXvwtVy1ONOEquWUEVUfswqtewT0NzhhxzTSpwu3Ueg4xSjod89XIzyrjhWaE78LdEc(OvWcSbGe8zBm4gf4d769A4Tcl7xeDe1lwSb8l2eNb(PIIfLilPfoebd4TZxc8e8l2eNb((9Kd8jgWhTcwGnaKGbmGp3Xh5qBapbVDcEc(OvWcSbGe8zBm4gf4ZD8ro0gDlKtzmKOGir5ecGFXM4mWhweMdbd4D)GNGpAfSaBaibF2gdUrb(WUEVoyy2louQBxcd8l2eNb(bdZEXHsWaEtjWtWhTcwGnaKGpBJb3OaFUYknn2quqKOOeeiQhevXMGpMrd5cusuqekr1p4xSjod8RLvgMrkttCY4mWaEtxGNGFXM4mW3hlMHfLCaF0kyb2aqcgWB6g8e8l2eNb(bdZIYyi4JwblWgasWagWa(8XvgNbE3pe6hco73Pda(jQ1clvc(0Xo4U17U9Bh0Uque1tQqIk4OD7qu(BjQE1H9iQfPJCJfBeL84qIQCNJRgSrumQklfLAcVUhgsuoHqxiQUEgFChSru9wxd93MI6x7ruZru9wxd93MI6x1OvWcS1JO6WjL7ut419WqIYPZUquD9m(4oyJO6TUg6Vnf1V2JOMJO6TUg6Vnf1VQrRGfyRhr1Htk3PMWR7HHeLZ(7cr11Z4J7GnIQ36AO)2uu)ApIAoIQ36AO)2uu)QgTcwGTEevne1l7fV7evhoPCNAcVUhgsuoPRUquD9m(4oyJO6nLaTr)ApIAoIQ3uc0g9RA0kyb26ruD4KYDQj86Eyir5KU6cr11Z4J7GnIQ36AO)2uu)ApIAoIQ36AO)2uu)QgTcwGTEevhoPCNAcVUhgsuoP7UquD9m(4oyJO6nLaTr)ApIAoIQ3uc0g9RA0kyb26ru1quVSx8UtuD4KYDQj86Eyir5KU7cr11Z4J7GnIQ36AO)2uu)ApIAoIQ36AO)2uu)QgTcwGTEevhoPCNAcpcp6yhC36D3(TdAxikI6jvirfC0UDik)Tevpwt2JOwKoYnwSruYJdjQYDoUAWgrXOQSuuQj86EyirrPUquD9m(4oyJO6XoR5gJ(1Ee1Cevp2zn3y0VQrRGfyRhr1Htk3PMWR7HHefL6cr11Z4J7GnIQN8CfWH10V2JOMJO6jpxbCyn9RA0kyb26ruD4KYDQj86Eyir5aDHO66z8XDWgr1BDn0FBkQFThrnhr1BDn0FBkQFvJwblWwpIQdNuUtnHhHhDSdUB9UB)2bTlefr9KkKOcoA3oeL)wIQNC6rulsh5gl2ik5XHev5ohxnyJOyuvwkk1eEDpmKOC2fIQRNXh3bBevV11q)TPO(1Ee1CevV11q)TPO(vnAfSaB9iQoCs5o1eEDpmKOC2fIQRNXh3bBevp2zn3y0V2JOMJO6XoR5gJ(vnAfSaB9iQoCs5o1eEDpmKOOuxiQUEgFChSru9wxd93MI6x7ruZru9wxd93MI6x1OvWcS1JO6WjL7ut419WqIYz)DHO66z8XDWgr1BDn0FBkQFThrnhr1BDn0FBkQFvJwblWwpIQdNuUtnHx3ddjkN0vxiQUEgFChSru9KNRaoSM(1Ee1Cevp55kGdRPFvJwblWwpIQJ(PCNAcVUhgsuoP7UquD9m(4oyJO6TUg6Vnf1V2JOMJO6TUg6Vnf1VQrRGfyRhr1Htk3PMWR7HHeLthOlevxpJpUd2iQERRH(Btr9R9iQ5iQERRH(Btr9RA0kyb26ruD4KYDQj86Eyir5SB0fIQRNXh3bBevV11q)TPO(1Ee1CevV11q)TPO(vnAfSaB9iQoCs5o1eEeEDBoA3oyJOCaIQytCgrjc5i1eEGpT98Hab)xGOCqQuKOEr7jhcVxGO4vMBT0tuVuFev)qOFNeEeEVar1vQklfLeEVar1njkhCRHnIsIZewkrnhr1czblqIcsr4OJ12iQo87XruVOfrhdlLO6wvyDsuHruYWsfy3CQnfhIAr2XXHwRM4mPMWJW7fiQxgLrM7GnIcg93Ief74GRHOGX0WKAIYbZyiTrsu2zDtQQLZ7kiQInXzsI6mb9AcVInXzsnTfzhhCnudLIAzLH5Wguiq2q4vSjotQPTi74GRHAOuiD54olNOgCZOa5qBkbHxXM4mPM2ISJdUgQHsHFp5aFIHWJW7fiQxgLrM7GnIc5Jl9e1eCirnuHevXMBjQqsuf)kefSa1eEfBIZKqzNRn4kPHcbHxXM4mj1qPGvcrUytCwweYPpR4qOSMKWRytCMKAOuWkHixSjollc50NvCiuukrJHscVInXzsQHsbReICXM4SSiKtFwXHqRd7l8ql2e8XmAixGsicLseEfBIZKudLcwje5InXzzriN(SIdHkN(cp0InbFmJgYfOKoPeHxXM4mj1qPGvcrUytCwweYPpR4qOChFKdTHWJWRytCMuxhc1VNJOLVfMWRytCMuxhsnukGfHJowBJWRytCMuxhsnuk8c3DPVVWdTJf5QWclnNiSbxzMrvieqHqYKne2171jcBWvMzufcHUDjSoF0bTf5NtznTtncFg8jMKjHD9En8wHL9lIoI6fl28a2171(WsXvMpF2VNC0lwSbke6KWRytCMuxhsnukcgMTJFr4vSjotQRdPgkfSJdNSCULJWRytCMuxhsnukcgMfLXW(cpuyxVx7dlfxz(8z)EYrVyXMKjBiSR3R975iA6f5QWKqC2IpkYtWHjtUixfwyP5eHn4kZmQcH4rdHD9EDIWgCLzgvHqOxKRctcXzl(Oipbhs4vSjotQRdPgkfB1IYMSKwToKWRytCMuxhsnuk4IDVvMpFEULdTHWRytCMuxhsnukKuf(jS0mTlbUeEfBIZK66qQHsHFp5KTJF1x4HUUg6Vnf1PBif0NdwWe4JP2uC0cKpkOtOcKpkE0qyxVx73Zr00TlHr4vSjotQRdPgkf(yXmSOKtFHh66AO)2uu3cjlOjcRw6ZSJJRS2d2DI2LW0WUEFUfswqtewT0Nzhhxzn9IvJ(hWUEVUfswqtewT0NzhhxzTSpwu3UegHxXM4mPUoKAOuulRmmJuMM4KXz9fEOCLvAASbIuccpk2e8XmAixGsic1bEqhwxd93MI6urXIsK9BLYH2ij8k2eNj11HudLce(m4tmeEfBIZK66qQHsrWWSOmg2x4HUUg6Vnf1PIIfLi73kLdTr(ykbAJwsteZewAoy4Jzl(OipbhsNP75ATCDOgweo6yTn9ICvyscVInXzsDDi1qPirftFsKbfcAN9fEORRH(BtrDQOyrjY(Ts5qBKpMsG2OL0eXmHLMdgs4vSjotQRdPgkf(9Kd8jgcpcVInXzsnRjHs7M4S(cpuAlYpFEFoL10bJ(mFmmzYK(iLQjVixfMKoPeei8k2eNj1SMKAOu0WAOc(wdj8k2eNj1SMKAOuWf7ERmF(8ClhAtFHhAXMGpMrd5cusNu6rhSZAUXOLbnQodBzUsemmzs55kGdRPtuYbfL1Y02J2g4qFNeEfBIZKAwtsnukwxdZNpt7sGBFHhk7or7sy6GrFMpgMuVixfMeIo7)bSR3RxxdZNpt7sGRUDjmcVInXzsnRjPgkfbJ(mFmmzFHhkSR3RxxdZNpt7sGRUDjShDa769APiyomhmu3UewYKfBc(ygnKlqjeH2FNeEfBIZKAwtsnukMGdZjQLwFHh66AO)2uupihTBlrorT0Ea769AKYuvUYjot7s7rh0wKF(8(CkRPdg9z(yyYKj9rkvtErUkmjDsji0jHxXM4mPM1KudLcxjMJb5KeEfBIZKAwtsnukGf31YE3LEcVInXzsnRjPgkfW4kX1HHLs4vSjotQznj1qPqePunY8lMBlLdTHWRytCMuZAsQHsHpwewCxJWRytCMuZAsQHsrzmuoBjYSsii8k2eNj1SMKAOuaxP5ZNNnyous4r4vSjotQ5o(ihAduyryomxg99fEOChFKdTr3c5ugdHOtiq4vSjotQ5o(ihAd1qPiyy2lou2x4Hc7696GHzV4qPUDjmcVInXzsn3Xh5qBOgkf1YkdZiLPjozCwFHhkxzLMgBGiLGWJInbFmJgYfOeIq7NWRytCMuZD8ro0gQHsHpwmdlk5q4vSjotQ5o(ihAd1qPiyywugdj8i8k2eNj1YbQx4Ul99fEODSixfwyP5eHn4kZmQcHakesMSHWUEVorydUYmJQqi0TlH15JoOTi)CkRPDQr4ZGpXKmjSR3RH3kSSFr0ruVyXMhDqBr(5uwt7uNkkwuISKw4qmzsAlYpNYAANA)EYb(eZJoOdSZAUXOJfZNppuH5sYqRHTKjz3jAxctVvlkBYsA16q9ICvyYKjxxd93MIA)IOJHLMtewt2zYK0wKFoL10o1B1IYMSKwTomzsyxVx7dlfxz(8z)EYrVyXgOq4rhne2171CXU3kZNpp3YH2ODPLmjSR3R9lIogwAorynP2LwYKWUEVgPmTYAylt7g0MOe6fl20zNDs4vSjotQLd1qPWVNJOLVfMWRytCMulhQHsbSiC0XAB9fEOWUEV2Vi6yyP5Tct7s7bDqIZewQuhP2Ty2Vi6yyP5TcllNKjl2e8XmAixGsicT)Kjxxd93MI6urXIsK9BLYH2iFSixfwyP5eHn4kZmQcHaA)eEfBIZKA5qnuk2I(85Z(9KtFHh6ICvyHLMte2GRmZOkecOoF0qyxVxNiSbxzMrvie6f5QWKeEfBIZKA5qnuksfflkrwslCi2x4HUixfwyP5eHn4kZmQcH4rdHD9EDIWgCLzgvHqOxKRctcrwjN8eCi1Zw8rrEcoKWRytCMulhQHsrWWSOmg2x4HUixfwyP5eHn4kZmQcH4XICvyHLMte2GRmZOkecic769AFyP4kZNp73to6fl28OHWUEVorydUYmJQqi0lYvHjH4SfFuKNGdj8k2eNj1YHAOuWooCYY5wocVInXzsTCOgkfbdZ2XVi8k2eNj1YHAOuSvlkBYsA16W(cpuyxVx7xeDmS0CIWAsTlThfBc(ygnKlqjuNeEfBIZKA5qnukcgMfLXW(cpuyxVx7dlfxz(8z)EYrVyXMKjBiSR3R975iA6f5QWKqC2IpkYtWHeEfBIZKA5qnukq4ZGpXq4vSjotQLd1qPyRwu2KL0Q1H9fEODqhwxd93MIA)IOJHLMtewtMmzXMGpMrd5cucrO935dyxVxdVvyz)IOJOEXIneEfBIZKA5qnuk4IDVvMpFEULdTHWRytCMulhQHsHKQWpHLMPDjWTVWdf2171RRH5ZNPDjWv3Ue2JoKNRaoSMoDp(yom(r6T1eNLmP8CfWH10(afT85ZWItkpozYKfBc(ygnKlqjeH2FNeEfBIZKA5qnuk87jNSD8R(cp011q)TPOoDdPG(CWcMaFm1MIJwG8rbDcvG8rXJgc769A)EoIMUDjmcVInXzsTCOgkf1YkdZiLPjozCwFHh66AO)2uu3cjlOjcRw6ZSJJRS2d2DI2LW0WUEFUfswqtewT0Nzhhxzn9IvJ(hWUEVUfswqtewT0NzhhxzTCTSYqD7syeEfBIZKA5qnuk8XIzyrjN(cp011q)TPOUfswqtewT0NzhhxzThS7eTlHPHD9(ClKSGMiSAPpZooUYA6fRg9pGD9EDlKSGMiSAPpZooUYAzFSOUDjmcVInXzsTCOgkfPIIfLilPfoe7l8qHD9En8wHL9lIoI6fl2q4vSjotQLd1qPWVNCGpXa(sAid82bOlWagaa]] )


end
