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

    
    spec:RegisterPack( "Frost Mage", 20201114, [[deunSaqius4rOeLnbiJIsOtjvIxbGzjvQBjvsP2LGFPuAysv5yaLLbqEMuvzAOe6AOeSnPsY3qjQgNuvLZHsIwNujLmpuICpLQ9bqDqPsQyHkfpuQKkDrPQQ0gLkP4KsLu1kPuUPuvvTtPkpvktvQyVs(lHbJOdlAXi8yqtwOldTzI(mqgnq1PjTAPQQ41OKA2O62Oy3u9BvgofDCkblxvphPPR46uy7uQ(ok14rjPZdOwpLO5tjTFLCbw1PAXCWQhG6dq9bgyGXIbW6paXcSiRSAdWMy1mtiRtqy18KbRwxZF0zr2)tqy1mtG5xgRovJEgpeRg4Zys7ATDliDa3GiapMTuLXGNJEo8t5SLQmWTvJWq5txVxevlMdw9auFaQpWadmwmaw)biwGf7QQLgd43xTMY01TAGRXi6fr1Iifwnw2IS)NGWfzxZF0zzJLTi7D2rgc8xKGXIDVibuFaQVQXv6qRovdPu0HiT6u9aR6uTeo65vdKr(rnDXjfPL4Fd4vd9KGJXAtnvpavDQwch98QjpObfJI0s81bfeyYun0tcogRn1u96x1PAjC0ZRgdYCpWItk4gqnkIpMm0QHEsWXyTPMQhlwDQwch98QrWVlkoPyahfOJmaxn0tcogRn1u9yHQt1s4ONxntJxLaRoibbpPt1qpj4yS2ut1RRQovlHJEE1E10KJc1fuZeIvd9KGJXAtnvpwE1PAONeCmwBQwch98QbphI(85GrHKNmy14QJcySADvnvV(R6un0tcogRnvd(6GVMvBYheobWXKpGhmHZIeWlY(RVfPvRlYjFq4eaht(aEWeolswArcO(wKwTUiLkiWhXJmP60fjlTibuFvlHJEE1EmnvhKqYtgKwt1JvwDQg6jbhJ1MQbFDWxZQryiLHhHSMJuQqEpedgMvlHJEE1gWrHHtCgEuiVhI1u9aRVQt1s4ONxn23ZJ2r1fpsppDiwn0tcogRn1ut1IOmn4t1P6bw1PAjC0ZRg8m8bFQjY5vd9KGJXAtnvpavDQg6jbhJ1MQLWrpVAWKZfjC0ZfCLovJR0r4jdwnyKwt1RFvNQHEsWXyTPAjC0ZRgm5Crch9CbxPt14kDeEYGvdPu0HiTMQhlwDQg6jbhJ1MQbFDWxZQLWrTJc0rgfPlsaVVizHQLWrpVAWKZfjC0ZfCLovJR0r4jdwT8WAQESq1PAONeCmwBQg81bFnRwch1okqhzuKUizPfjluTeo65vdMCUiHJEUGR0PACLocpzWQrNAQEDv1PAONeCmwBQwch98QbtoxKWrpxWv6unUshHNmy1yo7id6tn1unZhHhdrovNQhyvNQLWrpVA5dthfQpiNJWPAONeCmwBQP6bOQt1s4ONxn25GVa5id6tYRg6jbhJ1MAQE9R6uTeo65vt(hDio(un0tcogRn1ut1YdRovpWQovlHJEE1K)zj6I7jQg6jbhJ1MAQEaQ6uTeo65vJGRwAz(XQHEsWXyTPMQx)Qovd9KGJXAt1GVo4Rz1S4I8rMuD1bjyR(Gpvabx58f5(ISVfPvRlYisyiLb2Qp4tfqWvopep2(ISllsGwKwCrA(ODbiymawajoN44ZI0Q1fjHHugi(uDH8r0sm8ycNfjqlscdPmivhe(uXjfY)Ot4XeolY9fzFlYUuTeo65vtYn(h4AQESy1PAjC0ZRMcrHF2ZQHEsWXyTPMQhluDQwch98QbpgCe05EMQHEsWXyTPMQxxvDQg6jbhJ1MQbFDWxZQryiLbP6GWNkoPq(hDcpMWzrA16ImIegszq(NLOhEKjvNUib8IC(0oYfJYGlsRwxKpYKQRoibB1h8Pci4kNVibArgrcdPmWw9bFQacUY5Hhzs1PlsaViNpTJCXOmy1s4ONxnfIcE6qSMQhlV6uTeo65v7ZOM(iOM5Z6QHEsWXyTPMQx)vDQwch98QrbxLJ6GeMhB8Rg6jbhJ1MAQESYQt1s4ONxng9)7PItkM7zqFQg6jbhJ1MAQEG1x1PAONeCmwBQg81bFnR2B4O8Eqya0RuoWcfQqogqlyOMMyCrc0ICYheoboAh5lswAFrYr7iFrc0ImIegszq(NLOhIhBVAjC0ZRM8p6i8ZEwt1dmWQovd9KGJXAt1GVo4Rz1EdhL3dcdrLcvtU65dSaEmmPhdOfmuttmUibArcVJhp2EGWqkfrLcvtU65dSaEmmPhdpMrGxKaTijmKYquPq1KRE(alGhdt6rHuFmep2E1s4ONxnP(OGGN0PMQhyaQ6un0tcogRnvd(6GVMvJj9mycNfjGxK9RVfjqlswXI8nCuEpimapEui)ZNaAbd10eJlsGwKwCrYkwKVHJY7bHb5JOLQdsWw9inGwWqnnX4I0Q1fjHHugKpIwQoibB1J0GH5ISllsGwKVHJY7bHHOsHQjx98bwapgM0Jb0cgQPjgxKaTiH3XJhBpqyiLIOsHQjx98bwapgM0JHhZiWlsGwKegsziQuOAYvpFGfWJHj9Oq(hDcXJTxTeo65vlFy6Oazvt(r1ZRP6bw)QovlHJEE1qIZjo(un0tcogRn1u9aJfRovd9KGJXAt1GVo4Rz1EdhL3dcdG4jutUq(jig0hAaTGHAAIXfjqlYj5OpbQjxNrDqcfIb0tcogRwch98QPquWthI1u9aJfQovlHJEE1K)rhIJpvd9KGJXAtn1unyKwDQEGvDQg6jbhJ1MQbFDWxZQz(ODXjLcqWyqHalSJQtxKwTUiLkiWhXJmP60fjlTi7xFvlHJEE1mVrpVMQhGQovd9KGJXAt1GVo4Rz1ONbNq9yGDshKNEuy(N5R4aCa9KGJXQLWrpVAm6)3tfNum3ZG(ut1RFvNQLWrpVArmhWjU3XQHEsWXyTPMQhlwDQg6jbhJ1MQbFDWxZQbVJhp2EqHalSJQtdpYKQtxKaErcglSibArsyiLH3WrXjfMhB8dXJTxTeo65v7nCuCsH5Xg)AQESq1PAONeCmwBQg81bFnRgHHugEdhfNuyESXpep2E1s4ONxnfcSWoQoTMQxxvDQg6jbhJ1MQbFDWxZQ9gokVheggKX8(KlyNVzaTGHAAIXfjqlslUiPh)wKwTUijmKYaYQGNg0rppyyUi7YIeOfPfxKMpAxCsPaemguiWc7O60fPvRlsPcc8r8itQoDrYslY(13ISlvlHJEE1gLbfSZ3SMQhlV6uTeo65vZGIcDqgA1qpj4yS2ut1R)QovlHJEE1i43ffsJh4QHEsWXyTPMQhRS6uTeo65vJaFk(SwDqvd9KGJXAtnvpW6R6uTeo65vJRGaFOI(hJiig0NQHEsWXyTPMQhyGvDQwch98Qj1hj43fRg6jbhJ1MAQEGbOQt1s4ONxT0HiD(KlGjNxn0tcogRn1u9aRFvNQLWrpVAejiXjfZRqwtRg6jbhJ1MAQPA0P6u9aR6un0tcogRnvd(6GVMvZIlYhzs1vhKGT6d(ubeCLZxK7lY(wKwTUiJiHHugyR(Gpvabx58q8y7lYUSibArAXfP5J2fGGXaybK4CIJplsRwxKegszG4t1fYhrlXWJjCwKaTiT4I08r7cqWyaSaiEc1KlOMkRXfPvRlsZhTlabJbWcY)OdXXNfPvRlsZhTlabJbWcFg10hb1mFwViTADrsyiLbP6GWNkoPq(hDcpMWzrUVi7Brc0I0IlYisyiLbg9)7PItkM7zqFcgMlsRwxKegszq(iAP6GeSvpsdgMlsRwxKegszazvZ0JyuyEd6JM8WJjCwKDzr2LfzxQwch98Qj5g)dCnvpavDQwch98Qj)Zs0f3tun0tcogRn1u96x1PAONeCmwBQg81bFnRgHHugKpIwQoiXNQhmmxKwTUit4O2rb6iJI0fjG3xKaQAjC0ZRgbxT0Y8J1u9yXQt1qpj4yS2un4Rd(AwThzs1vhKGT6d(ubeCLZxK7lsWwKaTiJiHHugyR(Gpvabx58WJmP60QLWrpVAFcS4Kc5F0PMQhluDQg6jbhJ1MQbFDWxZQ9itQU6GeSvFWNkGGRC(IeOfzejmKYaB1h8Pci4kNhEKjvNUib8IeM0rmkdUibyroFAh5IrzWQLWrpVAG4jutUGAQSgRP61vvNQHEsWXyTPAWxh81SApYKQRoibB1h8Pci4kNVibAr(itQU6GeSvFWNkGGRC(IeWlscdPmivhe(uXjfY)Ot4XeolsGwKrKWqkdSvFWNkGGRCE4rMuD6IeWlY5t7ixmkdwTeo65vtHOGNoeRP6XYRovlHJEE1Ghdoc6Cpt1qpj4yS2ut1R)QovlHJEE1uik8ZEwn0tcogRn1u9yLvNQHEsWXyTPAWxh81SAegszq(iAP6GeSvpsdgMlsGwKjCu7OaDKrr6ICFrcw1s4ONxTpJA6JGAMpRRP6bwFvNQHEsWXyTPAWxh81SAegszqQoi8PItkK)rNWJjCwKwTUiJiHHugK)zj6Hhzs1PlsaViNpTJCXOmy1s4ONxnfIcE6qSMQhyGvDQwch98QHeNtC8PAONeCmwBQP6bgGQovd9KGJXAt1GVo4Rz1S4IKvSiFdhL3dcdYhrlvhKGT6rAaTGHAAIXfPvRlYeoQDuGoYOiDrc49fjGwKDzrc0IKWqkdeFQUq(iAjgEmHt1s4ONxTpJA6JGAMpRRP6bw)QovlHJEE1y0)VNkoPyUNb9PAONeCmwBQP6bglwDQg6jbhJ1MQbFDWxZQryiLH3WrXjfMhB8dXJTVibArAXfj9m4eQhdG(Zoku3Uc6(C0ZdONeCmUiTADrspdoH6XGurEuCsbb)O0JHgqpj4yCrA16ImHJAhfOJmksxKaEFrcOfzxQwch98QrbxLJ6GeMhB8RP6bgluDQg6jbhJ1MQbFDWxZQ9gokVhega9kLdSqHkKJb0cgQPjgxKaTiN8bHtGJ2r(IKL2xKC0oYxKaTiJiHHugK)zj6H4X2Rwch98Qj)Joc)SN1u9aRRQovd9KGJXAt1GVo4Rz1EdhL3dcdrLcvtU65dSaEmmPhdOfmuttmUibArcVJhp2EGWqkfrLcvtU65dSaEmmPhdpMrGxKaTijmKYquPq1KRE(alGhdt6rr(W0Xq8y7vlHJEE1YhMokqw1KFu98AQEGXYRovd9KGJXAt1GVo4Rz1EdhL3dcdrLcvtU65dSaEmmPhdOfmuttmUibArcVJhp2EGWqkfrLcvtU65dSaEmmPhdpMrGxKaTijmKYquPq1KRE(alGhdt6rHuFmep2E1s4ONxnP(OGGN0PMQhy9x1PAONeCmwBQg81bFnRgHHugi(uDH8r0sm8ycNQLWrpVAG4jutUGAQSgRP6bgRS6uTeo65vt(hDio(un0tcogRn1ut1yo7id6t1P6bw1PAONeCmwBQg81bFnRgZzhzqFcrLoPdXfjGxKG1x1s4ONxncU6SUMQhGQovd9KGJXAt1GVo4Rz1imKYGcrHKFinep2E1s4ONxnfIcj)qAnvV(vDQg6jbhJ1MQbFDWxZQXKEgmHZIeWlY(13IeOfzch1okqhzuKUib8(IeqvlHJEE1YhMokqw1KFu98AQESy1PAjC0ZRMuFuqWt6un0tcogRn1u9yHQt1s4ONxnfIcE6qSAONeCmwBQPMAQMD8P65vpa1hG6dmWadSQXoFxDq0Q11ZyE)GXfjlFrMWrpFrYv6qdlBvJAIWQxxXIvZ8pPYXQXYwK9)eeUi7A(JolBSSfzVZoYqG)IemwS7fjG6dq9TSTSXYwK9VSkcngmUijq594IeEme5SijqqQtdlYUoqiAo0fPFExBWZNrAWxKjC0ZPlYZ5ahw2s4ONtdMpcpgICayFB(W0rH6dY5iCw2s4ONtdMpcpgICayFl1GH5Cb7CWxGCKb9j5lBjC0ZPbZhHhdroaSVv(hDio(SSTSXYwK9VSkcngmUir74d8ICugCroGJlYeo3Viv6ImTNkpj4yyzlHJEoDhEg(Gp1e58LTeo65ua23ctoxKWrpxWv60TNm4omsx2s4ONtbyFlm5Crch9CbxPt3EYG7iLIoePlBjC0ZPaSVfMCUiHJEUGR0PBpzW98WUv5Ech1okqhzuKc4DwyzlHJEofG9TWKZfjC0ZfCLoD7jdUtNUv5Ech1okqhzuKYsSWYwch9Cka7BHjNls4ONl4kD62tgCN5SJmOplBlBjC0ZPH8WD5FwIU4EILTeo650qEia7Bj4QLwMFCzlHJEonKhcW(wj34FG7wL7w8rMuD1bjyR(Gpvabx589(SAnIegszGT6d(ubeCLZdXJT3fGSO5J2fGGXaybK4CIJpwTsyiLbIpvxiFeTedpMWbicdPmivhe(uXjfY)Ot4Xeo791LLTeo650qEia7Bvik8ZEUSLWrpNgYdbyFl8yWrqN7zw2s4ONtd5HaSVvHOGNoe7wL7egszqQoi8PItkK)rNWJjCSAnIegszq(NLOhEKjvNc45t7ixmkdA16JmP6QdsWw9bFQacUY5afrcdPmWw9bFQacUY5Hhzs1PaE(0oYfJYGlBjC0ZPH8qa23(zutFeuZ8z9Ywch9CAipeG9TuWv5OoiH5Xg)LTeo650qEia7Bz0)VNkoPyUNb9zzlHJEonKhcW(w5F0r4N9SBvU)gokVhega9kLdSqHkKJb0cgQPjgbAYheoboAh5S0ohTJCGIiHHugK)zj6H4X2x2s4ONtd5HaSVvQpki4jD6wL7VHJY7bHHOsHQjx98bwapgM0Jb0cgQPjgbcEhpES9aHHukIkfQMC1Zhyb8yyspgEmJadeHHugIkfQMC1Zhyb8yyspkK6JH4X2x2s4ONtd5HaSVnFy6Oazvt(r1Z7wL7mPNbt4a4(1hqSI3Wr59GWa84rH8pFcOfmuttmcKfzfVHJY7bHb5JOLQdsWw9inGwWqnnXOvRegszq(iAP6GeSvpsdgMDbO3Wr59GWquPq1KRE(alGhdt6XaAbd10eJabVJhp2EGWqkfrLcvtU65dSaEmmPhdpMrGbIWqkdrLcvtU65dSaEmmPhfY)OtiES9LTeo650qEia7BrIZjo(SSLWrpNgYdbyFRcrbpDi2Tk3FdhL3dcdG4jutUq(jig0hAaTGHAAIrGMKJ(eOMCDg1bjuigqpj4yCzlHJEonKhcW(w5F0H44ZY2Ywch9CAagP7M3ON3Tk3nF0U4KsbiymOqGf2r1PwTkvqGpIhzs1PSu)6BzlHJEonaJua23YO)FpvCsXCpd6t3QCNEgCc1Jb2jDqE6rH5FMVIdWb0tcogx2s4ONtdWifG9TrmhWjU3XLTeo650amsbyF7B4O4KcZJn(DRYD4D84X2dkeyHDuDA4rMuDkGbJfaIWqkdVHJItkmp24hIhBFzlHJEonaJua23QqGf2r1PDRYDcdPm8gokoPW8yJFiES9LTeo650amsbyF7OmOGD(MDRY93Wr59GWWGmM3NCb78ndOfmuttmcKfPh)SALWqkdiRcEAqh98GHzxaYIMpAxCsPaemguiWc7O6uRwLkiWhXJmP6uwQF91LLTeo650amsbyFRbff6Gm0LTeo650amsbyFlb)UOqA8aVSLWrpNgGrka7BjWNIpRvh0Ywch9CAagPaSVLRGaFOI(hJiig0NLTeo650amsbyFRuFKGFxCzlHJEonaJua23MoePZNCbm58LTeo650amsbyFlrcsCsX8kK10LTLTeo650asPOdr6oiJ8JA6ItkslX)gWx2s4ONtdiLIoePaSVvEqdkgfPL4RdkiWKzzlHJEonGuk6qKcW(wgK5EGfNuWnGAueFmzOlBjC0ZPbKsrhIua23sWVlkoPyahfOJmaVSLWrpNgqkfDisbyFRPXRsGvhKGGN0zzlHJEonGuk6qKcW(2xnn5OqDb1mH4Ywch9CAaPu0HifG9TWZHOpFoyui5jd2nxDuaJ7D1Ywch9CAaPu0HifG9TpMMQdsi5jds7wL7t(GWjaoM8b8GjCaC)1NvRt(GWjaoM8b8GjCyja1NvRsfe4J4rMuDklbO(w2s4ONtdiLIoePaSVDahfgoXz4rH8Ei2Tk3jmKYWJqwZrkviVhIbdZLTeo650asPOdrka7BzFppAhvx8i980H4Y2Ywch9CAG5SJmOp7eC1zTiDG7wL7mNDKb9jev6Koebmy9TSLWrpNgyo7id6da7BvikK8dPDRYDcdPmOqui5hsdXJTVSLWrpNgyo7id6da7BZhMokqw1KFu98Uv5ot6zWeoaUF9buch1okqhzuKc4DaTSLWrpNgyo7id6da7BL6JccEsNLTeo650aZzhzqFayFRcrbpDiUSTSLWrpNgOZUKB8pWDRYDl(itQU6GeSvFWNkGGRC(EFwTgrcdPmWw9bFQacUY5H4X27cqw08r7cqWyaSasCoXXhRwjmKYaXNQlKpIwIHht4aKfnF0UaemgalaINqn5cQPYA0QvZhTlabJbWcY)OdXXhRwnF0Uaemgal8zutFeuZ8zTvRegszqQoi8PItkK)rNWJjC27dilgrcdPmWO)FpvCsXCpd6tWW0QvcdPmiFeTuDqc2QhPbdtRwjmKYaYQMPhXOW8g0hn5Hht40LU0LLTeo650aDayFR8plrxCpXYwch9CAGoaSVLGRwAz(XUv5oHHugKpIwQoiXNQhmmTAnHJAhfOJmksb8oGw2s4ONtd0bG9TFcS4Kc5F0PBvU)itQU6GeSvFWNkGGRC(oyafrcdPmWw9bFQacUY5Hhzs1PlBjC0ZPb6aW(wq8eQjxqnvwJDRY9hzs1vhKGT6d(ubeCLZbkIegszGT6d(ubeCLZdpYKQtbmmPJyugeG5t7ixmkdUSLWrpNgOda7Bvik4PdXUv5(JmP6QdsWw9bFQacUY5a9itQU6GeSvFWNkGGRCoGjmKYGuDq4tfNui)JoHht4auejmKYaB1h8Pci4kNhEKjvNc45t7ixmkdUSLWrpNgOda7BHhdoc6CpZYwch9CAGoaSVvHOWp75Ywch9CAGoaSV9ZOM(iOM5Z6Uv5oHHugKpIwQoibB1J0GHjqjCu7OaDKrr6oylBjC0ZPb6aW(wfIcE6qSBvUtyiLbP6GWNkoPq(hDcpMWXQ1isyiLb5FwIE4rMuDkGNpTJCXOm4Ywch9CAGoaSVfjoN44ZYwch9CAGoaSV9ZOM(iOM5Z6Uv5UfzfVHJY7bHb5JOLQdsWw9inGwWqnnXOvRjCu7OaDKrrkG3buxaIWqkdeFQUq(iAjgEmHZYwch9CAGoaSVLr))EQ4KI5Eg0NLTeo650aDayFlfCvoQdsyESXVBvUtyiLH3WrXjfMhB8dXJTdKfPNbNq9ya0F2rH62vq3NJEEa9KGJrRwPNbNq9yqQipkoPGGFu6XqdONeCmA1Ach1okqhzuKc4Da1LLTeo650aDayFR8p6i8ZE2Tk3FdhL3dcdGELYbwOqfYXaAbd10eJan5dcNahTJCwANJ2roqrKWqkdY)Se9q8y7lBjC0ZPb6aW(28HPJcKvn5hvpVBvU)gokVhegIkfQMC1Zhyb8yyspgqlyOMMyei4D84X2degsPiQuOAYvpFGfWJHj9y4XmcmqegsziQuOAYvpFGfWJHj9OiFy6yiES9LTeo650aDayFRuFuqWt60Tk3FdhL3dcdrLcvtU65dSaEmmPhdOfmuttmce8oE8y7bcdPuevkun5QNpWc4XWKEm8ygbgicdPmevkun5QNpWc4XWKEui1hdXJTVSLWrpNgOda7BbXtOMCb1uzn2Tk3jmKYaXNQlKpIwIHht4SSLWrpNgOda7BL)rhIJp1utva]] )


end
