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

    
    spec:RegisterPack( "Frost Mage", 20201216, [[dKK0UaqirjXJqvQAtQO(KuLrjvYPKk6virZsQk3cuPu7IKFHegMkKJrrwMuPEgQsMgsP6Asvv2gOs(MOKY4eLKohOs16eLY8qkL7bk7duXbLQQQfcQ6HsvLjkvvLUiOsXgrvk5JOkL6KIsQwjQQzkkv3evPWovr(jOsjlfvPONQstvf8vuLknwvO2lWFfzWu6WswmipgLjlLldTzs9zr1OrkoTWQLQQIxlkXSjCBuz3u9BvnCK0XrvQy5k9CIMUIRtHTJu9DkQXJuY5rvSEPcZxuSFedmboaUTAqWPUpQ7Jm1Tj4sDuwL2H7Dd3b3HhQi4sTyzPYrW1loeC5T2xoelVrLJGl1IhXxnWbWv(gldbxAMHQmBuqrEm0yaPyphfYGZqut8oBl9qHm4yuaUqgHyY6oacCB1GGtDFu3hzQBtWL6OSkTd372e4wgdn)cU3GRFGlnrRHoacCBOKbU8EIL3OYrIL3AF5q4Z7j2(xKHCq4sSMGR(i2UpQ7Jaxrihj4a42qDzigWbWjtGdGBXM4DWL9g(GRKkkeGl6fKaBa4bd4u3GdGl6fKaBa4b3InX7GlReIuXM49KiKd4kc5K8IdbxwtcgWjEboaUOxqcSbGhCl2eVdUSsisfBI3tIqoGRiKtYloeCrPeDgkbd4eTdoaUOxqcSbGhCzBm4gf4wSjOJj0rUaLelCGrS8cCl2eVdUSsisfBI3tIqoGRiKtYloeCRhbd4u)boaUOxqcSbGhCzBm4gf4wSjOJj0rUaLelTrS8cCl2eVdUSsisfBI3tIqoGRiKtYloeCLdyaNGlWbWf9csGna8GBXM4DWLvcrQyt8EseYbCfHCsEXHGl3th5qFadyaxQlYEoOAahaNmboaUfBI3b3AzLJPWhuiq2aUOxqcSbGhmGtDdoaUfBI3bxZ1GBcfih6tjax0lib2aWdgWjEboaUfBI3bx9(Yb6fd4IEbjWgaEWagWTEeCaCYe4a4wSjEhC173b6PFHax0lib2aWdgWPUbha3InX7GlKi6OJABGl6fKaBa4bd4eVahax0lib2aWdUSngCJcC7IyxKRcp88K5WhCLjgnHqqSWi2Ji2mzi2gczO1kZHp4ktmAcHq1EZoX2jXEMy7IyPUi9uoRPmPqO3HEXqSzYqSqgATcARWt6fXoq1IfBi2ZelKHwR0HNJRm96KEF5OwSydXcJypIy7eCl2eVdUAHXU8agWjAhCaCl2eVdUbdt(tVax0lib2aWdgWP(dCaCl2eVdUSNdNKC(LdCrVGeydapyaNGlWbWf9csGna8GlBJb3OaxidTwPdphxz61j9(YrTyXgIntgITHqgATsVFhORwKRcxsSWHyNTOJI0eCiXMjdXUixfE45jZHp4ktmAcHGyptSneYqRvMdFWvMy0ecHArUkCjXchID2IokstWHGBXM4DWnyysuodbd4uwdCaCl2eVdUB1IYNKKATzbCrVGeydapyaNYQGdGBXM4DWLl29xz61P5xo0hWf9csGna8GbCcUdoaUfBI3bxjnHEcppr9nJl4IEbjWgaEWaoz6iWbWf9csGna8GlBJb3Oa31Wr9V5OkFdPGNuWcMavOxqcSrSNj2P2CCucKokiwAdgXkq6OGyptSneYqRv697aDv7n7GBXM4DWvVVCs(tVad4KjtGdGl6fKaBa4bx2gdUrbURHJ6FZrvlKSGQi8A5jXEoUYBk0lib2i2Zel7Fr7n7kidTo1cjlOkcVwEsSNJR8MAXQXdXEMyHm0AvlKSGQi8A5jXEoUYBjDSOQ9MDWTyt8o4QJftqIsoGbCYu3GdGl6fKaBa4bx2gdUrbUCLxkQSHyHdXYRJi2ZeBXMGoMqh5cusSWbgXcxe7zInRqSRHJ6FZrvUOyrjs6TY5qFKk0lib2a3InX7GBTSYXeslQIxgVdgWjt8cCaCl2eVdUi07qVyax0lib2aWdgWjt0o4a4IEbjWgaEWLTXGBuG7A4O(3CuLlkwuIKERCo0hPc9csGnI9mXoLa9rjPkIzcppfmuHEbjWgXEMyNTOJI0eCiXsBeB((gElvpQGerhDuBtTixfUeCl2eVdUbdtIYziyaNm1FGdGl6fKaBa4bxjYa3JuMa3InX7GR5kgWLTXGBuG7A4O(3CuLlkwuIKERCo0hPc9csGnI9mXoLa9rjPkIzcppfmuHEbjWgyaNmbxGdGBXM4DWvVVCGEXaUOxqcSbGhmGbCznj4a4KjWbWf9csGna8GlBJb3OaxQlsp9ADkN1ubJNeDmCjXMjdXQJCAM0ICv4sIL2iwEDe4wSjEhCP(t8oyaN6gCaCl2eVdUnSgAG(1rWf9csGna8GbCIxGdGl6fKaBa4bx2gdUrbUfBc6ycDKlqjXsBelVi2ZeBxel79MrmkzqLM3XwIRebdvOxqcSrSzYqSY3qafEtzUKdkkVLOUp1nWHhf6fKaBeBNGBXM4DWLl29xz61P5xo0hWaor7GdGl6fKaBa4bx2gdUrbUS)fT3SRcgpj6y4s1ICv4sIfoeRPUj2ZelKHwRwdhtVor9nJRQ9MDWTyt8o4UgoMEDI6BgxWao1FGdGl6fKaBa4bx2gdUrbUqgATAnCm96e13mUQ2B2b3InX7GBW4jrhdxcgWj4cCaCrVGeydap4Y2yWnkWDnCu)BoQgKJ6VLizUwQk0lib2i2ZelKHwRqArtziN4DLbvI9mX2fXsDr6PxRt5SMky8KOJHlj2mziwDKtZKwKRcxsS0gXYRJi2ob3InX7G7eCyYCTubd4uwdCaCl2eVdUgsmfdYjbx0lib2aWdgWPSk4a4wSjEhCHe)3sAJLhWf9csGna8GbCcUdoaUfBI3bxiCL4MLWZbx0lib2aWdgWjthboaUfBI3bxrKtZit9pgTCo0hWf9csGna8GbCYKjWbWTyt8o4QJfHe)3ax0lib2aWdgWjtDdoaUfBI3b3YzOC2sKyLqaUOxqcSbGhmGtM4f4a4wSjEhCHQ80RtZgSSibx0lib2aWdgWaUYbCaCYe4a4IEbjWgaEWLTXGBuGBxe7ICv4HNNmh(GRmXOjecIfgXEeXMjdX2qidTwzo8bxzIrtieQ2B2j2oj2ZeBxel1fPNYznLjfc9o0lgIntgIfYqRvqBfEsVi2bQwSydXEMy7IyPUi9uoRPmPYfflkrssnYcsSzYqSuxKEkN1uMu69Ld0lgI9mX2fXMviw27nJyuXIPxNgAWujzO3WMc9csGnIntgIL9VO9MD1wTO8jjPwBwulYvHlj2mzi21Wr9V5OsVi2r45jZH3Kk0lib2i2oj2mziwQlspLZAktQTAr5tssT2SqSzYqSqgATshEoUY0Rt69LJAXInelmI9iI9mX2fX2qidTwXf7(Rm9608lh6JYGkXMjdXczO1k9IyhHNNmhEtQmOsSzYqSqgATcPf1YBylr9h0NOeQfl2qSDsSDsSDcUfBI3bxTWyxEad4u3GdGBXM4DWvVFhON(fcCrVGeydapyaN4f4a4IEbjWgaEWLTXGBuGlKHwR0lIDeEEARWvguj2mzi2InbDmHoYfOKyHdmITBIntgIDnCu)BoQYfflkrsVvoh6JuHEbjWgXEMyxKRcp88K5WhCLjgnHqqSWi2Ub3InX7GlKi6OJABGbCI2bhax0lib2aWdUSngCJcCxKRcp88K5WhCLjgnHqqSWiwte7zITHqgATYC4dUYeJMqiulYvHlb3InX7G7w8KEDsVVCad4u)boaUOxqcSbGhCzBm4gf4UixfE45jZHp4ktmAcHGyptSneYqRvMdFWvMy0ecHArUkCjXchILvYjnbhsSusSZw0rrAcoeCl2eVdU5IIfLijPgzbbd4eCboaUOxqcSbGhCzBm4gf4UixfE45jZHp4ktmAcHGyptSlYvHhEEYC4dUYeJMqiiw4qSqgATshEoUY0Rt69LJAXIne7zITHqgATYC4dUYeJMqiulYvHljw4qSZw0rrAcoeCl2eVdUbdtIYziyaNYAGdGBXM4DWL9C4KKZVCGl6fKaBa4bd4uwfCaCl2eVdUbdt(tVax0lib2aWdgWj4o4a4IEbjWgaEWLTXGBuGlKHwR0lIDeEEYC4nPYGkXEMyl2e0Xe6ixGsIfgXAcCl2eVdUB1IYNKKATzbmGtMocCaCrVGeydap4Y2yWnkWfYqRv6WZXvMEDsVVCulwSHyZKHyBiKHwR073b6Qf5QWLelCi2zl6OinbhcUfBI3b3GHjr5memGtMmboaUfBI3bxe6DOxmGl6fKaBa4bd4KPUbhax0lib2aWdUSngCJcC7IyZke7A4O(3CuPxe7i88K5WBsf6fKaBeBMmeBXMGoMqh5cusSWbgX2nX2jXEMyHm0Af0wHN0lIDGQfl2aUfBI3b3TAr5tssT2SagWjt8cCaCl2eVdUCXU)ktVon)YH(aUOxqcSbGhmGtMODWbWf9csGna8GlBJb3OaxidTwTgoMEDI6Bgxv7n7e7zITlIv(gcOWBQ89PJPWPh5)wt8Uc9csGnIntgIv(gcOWBkDGIw61jiXlLpNuHEbjWgXMjdXwSjOJj0rUaLelCGrSDtSDcUfBI3bxjnHEcppr9nJlyaNm1FGdGl6fKaBa4bx2gdUrbURHJ6FZrv(gsbpPGfmbQqVGeyJyptStT54OeiDuqS0gmIvG0rbXEMyBiKHwR073b6Q2B2b3InX7GREF5K8NEbgWjtWf4a4IEbjWgaEWLTXGBuG7A4O(3Cu1cjlOkcVwEsSNJR8Mc9csGnI9mXY(x0EZUcYqRtTqYcQIWRLNe754kVPwSA8qSNjwidTw1cjlOkcVwEsSNJR8wQww5OQ9MDWTyt8o4wlRCmH0IQ4LX7GbCYuwdCaCrVGeydap4Y2yWnkWDnCu)BoQAHKfufHxlpj2ZXvEtHEbjWgXEMyz)lAVzxbzO1Pwizbvr41YtI9CCL3ulwnEi2ZelKHwRAHKfufHxlpj2ZXvElPJfvT3SdUfBI3bxDSycsuYbmGtMYQGdGl6fKaBa4bx2gdUrbUqgATcARWt6fXoq1IfBa3InX7GBUOyrjssQrwqWaozcUdoaUfBI3bx9(Yb6fd4IEbjWgaEWagWL7PJCOpGdGtMahax0lib2aWdUSngCJcC5E6ih6JQfYPCgsSWHynDe4wSjEhCHeHNfWao1n4a4IEbjWgaEWLTXGBuGlKHwRcgM0IhLQ2B2b3InX7GBWWKw8OemGt8cCaCrVGeydap4Y2yWnkWLR8srLnelCiwEDeXEMyl2e0Xe6ixGsIfoWi2Ub3InX7GBTSYXeslQIxgVdgWjAhCaCl2eVdU6yXeKOKd4IEbjWgaEWao1FGdGBXM4DWnyysuodbx0lib2aWdgWagWLoUY4DWPUpQ7Jm19rMaxZ16HNlbxE3(pV5PS(jE7SrSe7bAqIn4O(7qS6Fj2E1J9i2f5DmIfBeR85qITmMNRgSrSmAkphLkc)ShosSMokBeB)ENoUd2i2ERHJ6FZr1X9i25j2ERHJ6FZr1Xk0lib26rSDzIwDQi8ZE4iXAYu2i2(9oDChSrS9wdh1)MJQJ7rSZtS9wdh1)MJQJvOxqcS1Jy7YeT6ur4N9WrI1u3zJy7370XDWgX2BnCu)BoQoUhXopX2BnCu)BoQowHEbjWwpITgIfUbUv2j2UmrRove(zpCKynr7zJy7370XDWgX2Bkb6J64Ee78eBVPeOpQJvOxqcS1Jy7YeT6ur4N9WrI1eTNnITFVth3bBeBV1Wr9V5O64Ee78eBV1Wr9V5O6yf6fKaB9i2UmrRove(zpCKyn1FzJy7370XDWgX2Bkb6J64Ee78eBVPeOpQJvOxqcS1JyRHyHBGBLDITlt0QtfHF2dhjwt9x2i2(9oDChSrS9wdh1)MJQJ7rSZtS9wdh1)MJQJvOxqcS1Jy7YeT6ur4t4Z72)5npL1pXBNnILypqdsSbh1FhIv)lX2J1K9i2f5DmIfBeR85qITmMNRgSrSmAkphLkc)ShosS8kBeB)ENoUd2i2ES3BgXOoUhXopX2J9EZig1Xk0lib26rSDzIwDQi8ZE4iXYRSrS97D64oyJy7jFdbu4n1X9i25j2EY3qafEtDSc9csGTEeBxMOvNkc)ShosSWv2i2(9oDChSrS9wdh1)MJQJ7rSZtS9wdh1)MJQJvOxqcS1Jy7YeT6ur4t4Z72)5npL1pXBNnILypqdsSbh1FhIv)lX2to9i2f5DmIfBeR85qITmMNRgSrSmAkphLkc)ShosSMYgX2V3PJ7GnIT3A4O(3CuDCpIDEIT3A4O(3CuDSc9csGTEeBxMOvNkc)ShosSMYgX2V3PJ7GnITh79MrmQJ7rSZtS9yV3mIrDSc9csGTEeBxMOvNkc)ShosS8kBeB)ENoUd2i2ERHJ6FZr1X9i25j2ERHJ6FZr1Xk0lib26rSDzIwDQi8ZE4iXAQ7SrS97D64oyJy7TgoQ)nhvh3JyNNy7TgoQ)nhvhRqVGeyRhX2LjA1PIWp7HJeRjApBeB)ENoUd2i2EY3qafEtDCpIDEITN8neqH3uhRqVGeyRhX2v30QtfHF2dhjwt9x2i2(9oDChSrS9wdh1)MJQJ7rSZtS9wdh1)MJQJvOxqcS1Jy7YeT6ur4N9WrI1eCLnITFVth3bBeBV1Wr9V5O64Ee78eBV1Wr9V5O6yf6fKaB9i2UmrRove(zpCKynL1YgX2V3PJ7GnIT3A4O(3CuDCpIDEIT3A4O(3CuDSc9csGTEeBxMOvNkcFc)Soh1FhSrSWfXwSjENyfHCKkcFWL6(6qGGlVNy5nQCKy5T2xoe(8EIT)fziheUeRj4QpIT7J6(icFcFEpXc3qlKzmyJyHq9ViXYEoOAiwimpCPIy7)mgsDKeR)oCBAQLtBii2InX7sI9Dbpkc)InX7sf1fzphunucJIAzLJPWhuiq2q4xSjExQOUi75GQHsyuin44EpzUgCtOa5qFkbHFXM4DPI6ISNdQgkHrHEF5a9IHWNWN3tSWn0czgd2iwKoU8qStWHe7qdsSfB(LydjXw0Rquqcur4xSjExcJ9g(GRKkkee(fBI3LucJcwjePInX7jriN(8IdHXAsc)InX7skHrbReIuXM49KiKtFEXHWqPeDgkj8l2eVlPegfSsisfBI3tIqo95fhcRESVqdRytqhtOJCbkHdmEr4xSjExsjmkyLqKk2eVNeHC6ZloeMC6l0Wk2e0Xe6ixGsAJxe(fBI3LucJcwjePInX7jriN(8IdHX90ro0hcFc)InX7sv9im9(DGE6xic)InX7sv9iLWOaseD0rTnc)InX7sv9iLWOqlm2LN(cnSUwKRcp88K5WhCLjgnHqa7OmzAiKHwRmh(GRmXOjecv7n7DEUlQlspLZAktke6DOxmzYazO1kOTcpPxe7avlwS5mKHwR0HNJRm96KEF5OwSydSJ6KWVyt8UuvpsjmkcgM8NEr4xSjExQQhPegfSNdNKC(LJWVyt8UuvpsjmkcgMeLZW(cnmidTwPdphxz61j9(YrTyXMmzAiKHwR073b6Qf5QWLWz2IokstWHzYSixfE45jZHp4ktmAcH4CdHm0AL5WhCLjgnHqOwKRcxcNzl6Oinbhs4xSjExQQhPegfB1IYNKKATzHWVyt8Uuvpsjmk4ID)vMEDA(Ld9HWVyt8UuvpsjmkK0e6j88e13mUe(fBI3LQ6rkHrHEF5K8NE1xOHTgoQ)nhv5Bif8KcwWe45P2CCucKokOnycKoko3qidTwP3Vd0vT3St4xSjExQQhPegf6yXeKOKtFHg2A4O(3Cu1cjlOkcVwEsSNJR82z2)I2B2vqgADQfswqveET8Kyphx5n1IvJNZqgATQfswqveET8Kyphx5TKowu1EZoHFXM4DPQEKsyuulRCmH0IQ4LX79fAyCLxkQSbo86OZfBc6ycDKlqjCGbxNZkRHJ6FZrvUOyrjs6TY5qFKe(fBI3LQ6rkHrbc9o0lgc)InX7sv9iLWOiyysuod7l0Wwdh1)MJQCrXIsK0BLZH(ippLa9rjPkIzcppfm88SfDuKMGdPT89n8wQEubjIo6O2MArUkCjHFXM4DPQEKsyuyUIPpjYGDKYuFHg2A4O(3CuLlkwuIKERCo0h55PeOpkjvrmt45PGHe(fBI3LQ6rkHrHEF5a9IHWNWVyt8UuXAsyu)jEVVqdJ6I0tVwNYznvW4jrhdxMjJoYPzslYvHlPnEDeHFXM4DPI1KucJIgwdnq)6iHFXM4DPI1KucJcUy3FLPxNMF5qF6l0Wk2e0Xe6ixGsAJxN7I9EZigLmOsZ7ylXvIGHzYiFdbu4nL5soOO8wI6(u3ahE6KWVyt8UuXAskHrXA4y61jQVzC7l0Wy)lAVzxfmEs0XWLQf5QWLWXu3NHm0A1A4y61jQVzCvT3St4xSjExQynjLWOiy8KOJHl7l0WGm0A1A4y61jQVzCvT3St4xSjExQynjLWOycomzUwQ9fAyRHJ6FZr1GCu)TejZ1s9mKHwRqArtziN4DLb1ZDrDr6PxRt5SMky8KOJHlZKrh50mPf5QWL0gVoQtc)InX7sfRjPegfgsmfdYjj8l2eVlvSMKsyuaj(VL0glpe(fBI3LkwtsjmkGWvIBwcpNWVyt8UuXAskHrHiYPzKP(hJwoh6dHFXM4DPI1KucJcDSiK4)gHFXM4DPI1KucJIYzOC2sKyLqq4xSjExQynjLWOaQYtVonBWYIKWNWVyt8UuX90ro0hyqIWZsQCE6l0W4E6ih6JQfYPCgchthr4xSjExQ4E6ih6dLWOiyyslEu2xOHbzO1QGHjT4rPQ9MDc)InX7sf3th5qFOegf1YkhtiTOkEz8EFHggx5LIkBGdVo6CXMGoMqh5cuchyDt4xSjExQ4E6ih6dLWOqhlMGeLCi8l2eVlvCpDKd9HsyuemmjkNHe(e(fBI3Lk5atlm2LN(cnSUwKRcp88K5WhCLjgnHqa7OmzAiKHwRmh(GRmXOjecv7n7DEUlQlspLZAktke6DOxmzYazO1kOTcpPxe7avlwS5CxuxKEkN1uMu5IIfLijPgzbZKH6I0t5SMYKsVVCGEXCURSc79MrmQyX0RtdnyQKm0Byltg2)I2B2vB1IYNKKATzrTixfUmtM1Wr9V5OsVi2r45jZH3KDMjd1fPNYznLj1wTO8jjPwBwYKbYqRv6WZXvMEDsVVCulwSb2rN7QHqgATIl29xz61P5xo0hLb1mzGm0ALErSJWZtMdVjvguZKbYqRviTOwEdBjQ)G(eLqTyXMo7Stc)InX7sLCOegf697a90Vqe(fBI3Lk5qjmkGerhDuBRVqddYqRv6fXocppTv4kdQzYuSjOJj0rUaLWbw3zYSgoQ)nhv5IIfLiP3kNd9rEErUk8WZtMdFWvMy0ecbSUj8l2eVlvYHsyuSfpPxN07lN(cnSf5QWdppzo8bxzIrtieWmDUHqgATYC4dUYeJMqiulYvHlj8l2eVlvYHsyuKlkwuIKKAKfSVqdBrUk8WZtMdFWvMy0ecX5gczO1kZHp4ktmAcHqTixfUeoSsoPj4qkNTOJI0eCiHFXM4DPsoucJIGHjr5mSVqdBrUk8WZtMdFWvMy0ecX5f5QWdppzo8bxzIrtieWbYqRv6WZXvMEDsVVCulwS5CdHm0AL5WhCLjgnHqOwKRcxcNzl6Oinbhs4xSjExQKdLWOG9C4KKZVCe(fBI3Lk5qjmkcgM8NEr4xSjExQKdLWOyRwu(KKuRnl9fAyqgATsVi2r45jZH3KkdQNl2e0Xe6ixGsyMi8l2eVlvYHsyuemmjkNH9fAyqgATshEoUY0Rt69LJAXInzY0qidTwP3Vd0vlYvHlHZSfDuKMGdj8l2eVlvYHsyuGqVd9IHWVyt8UujhkHrXwTO8jjPwBw6l0W6kRSgoQ)nhv6fXocppzo8MmtMInbDmHoYfOeoW6UZZqgATcARWt6fXoq1IfBi8l2eVlvYHsyuWf7(Rm9608lh6dHFXM4DPsoucJcjnHEcppr9nJBFHggKHwRwdhtVor9nJRQ9M9ZDjFdbu4nv((0Xu40J8FRjEptg5BiGcVP0bkAPxNGeVu(CYmzk2e0Xe6ixGs4aR7oj8l2eVlvYHsyuO3xoj)Px9fAyRHJ6FZrv(gsbpPGfmbEEQnhhLaPJcAdMaPJIZneYqRv697aDv7n7e(fBI3Lk5qjmkQLvoMqArv8Y49(cnS1Wr9V5OQfswqveET8Kyphx5TZS)fT3SRGm06ulKSGQi8A5jXEoUYBQfRgpNHm0AvlKSGQi8A5jXEoUYBPAzLJQ2B2j8l2eVlvYHsyuOJftqIso9fAyRHJ6FZrvlKSGQi8A5jXEoUYBNz)lAVzxbzO1Pwizbvr41YtI9CCL3ulwnEodzO1Qwizbvr41YtI9CCL3s6yrv7n7e(fBI3Lk5qjmkYfflkrssnYc2xOHbzO1kOTcpPxe7avlwSHWVyt8UujhkHrHEF5a9IbCLurg4eCr7Gbmaaa]] )


end
