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

        potion = "potion_of_focused_resolve",

        package = "Frost Mage",
    } )

    
    spec:RegisterPack( "Frost Mage", 20201124, [[dGuPXaqiKeYJqsKnbs9jKuJsvLoLQkELQQMLQi3cjbXUOQFPQyyQI6yukltvWZOuX0ufY1ie12iG8ncrmokvQohscSovHAEeqDpqSpKKoisc1cvv6HeaxKsLYgPuj5JuQK6KijQvsqZKa0nPujANIk)ejbPLsPs4PkAQIsFLqKmwcH9Q0FPyWICyjlgupgXKv4YqBMkFwvA0GKtlSAKeuVMqQzt0TrQDt63QmCK44eIulh45OA6sDDkz7eQVlkgpHKZtGwpLQMVOQ9JYRTn7ohvJBUhE(HNTz7Hh5FWo2e5hTZwqk4oPuerxV4o1Ig3PDf44nlzxwV4oPuckVASz3j)SaeCNq1nf(J)85nAOSG9KJ(dpOTKvhNsaLR)WdAYNDcBfYMkRl8ohvJBUhE(HNTz7Hh5FWo2EKi)ODwwnuhyNZGwa2juXyG6cVZbYj7KkXs2L1lYs2vGJ3mHujwk3jgPHral9WJEILE45hEMjKjKkXsuzwQOzjjwId9LLSBCoQeKZsHYswAhswQaNLoyjBFS95HNF4zwYsLiNZs8JgBOc9LLqjhzjkwCOqolrJSuFS04yPO97ug8MVz3jY5Osq(MDZzBZUZI0XP781QaJOuZ5mL9i4AO2jQfSeh73T3CpSz3zr640D6oIfhhMYEeenAGXIENOwWsCSF3EZzNn7olshNUtAK(acAoNrArIHzaWIMVtulyjo2VBV5E0MDNfPJt3jS8UH5CMgk0Gksl4orTGL4y)U9MtK3S7SiDC6oPybcNGH(AGLfV3jQfSeh73T3Cc0MDNfPJt3jiOqrIMqnCkfb3jQfSeh73T3CIKn7orTGL4y)UZI0XP7KCkb1gunomozrJ7ugkAiJDkqBV5S7B2DwKooDNaSOe6RXjlAKVtulyjo2VBV5Oc2S7e1cwIJ97ojGOrqu7e2Y58aKiAjY5g3biO3IYolshNUZgk0yPWNLomUdqWT3C2EEZUZI0XP7mZbKdXyOgaYpTucUtulyjo2VBV5SzBZUZI0XP7ekSaTb5Cuj4orTGL4y)U927CGUYs2B2nNTn7olshNUtYzPnc4uqPCNOwWsCSF3EZ9WMDNOwWsCSF3zr640DskP0uKoo1idEVtzWBJw04ojd(2Bo7Sz3jQfSeh73DwKooDNKsknfPJtnYG37ug82OfnUtKZrLG8T3CpAZUtulyjo2V7KaIgbrTZI0Hy0GkshiNLOkew6r7SiDC6ojLuAkshNAKbV3Pm4TrlACN1HBV5e5n7orTGL4y)UtciAee1olshIrdQiDGCwsGzPhTZI0XP7KusPPiDCQrg8ENYG3gTOXDY7T3Cc0MDNOwWsCSF3zr640DskP0uKoo1idEVtzWBJw04oPpXinQ92BVtkaKC0WvVz3C22S7SiDC6olaPu0eAJsjs6DIAblXX(D7n3dB2DwKooDNzQgbguI0O2LCNOwWsCSF3EZzNn7olshNUth44n8j7DIAblXX(D7T3zD4MDZzBZUZI0XP70bo7r1Ca4DIAblXX(D7n3dB2DwKooDNWYWE7lWyNOwWsCSF3EZzNn7orTGL4y)UtciAee1o)LLaiDfAOVMmH2iGBiqfsjlbHLEMLYNNLgiSLZ5ZeAJaUHaviL(XLrzPFyjOzPFzjkauS5Lm828i8PWNSzP85zjylNZddQqnoaI2JEawKMLGMLGTCoVl0xeWnNZ4ahV9aSinlbHLEML(zNfPJt3PtAbacU9M7rB2DwKooDNbbn6jU2jQfSeh73T3CI8MDNfPJt3j5OX2W7dqVtulyjo2VBV5eOn7orTGL4y)UtciAee1oHTCoVl0xeWnNZ4ahV9aSinlLpplnqylNZ7aN9O6biDfkNLOkl1GsmknDqJSu(8SeaPRqd91Kj0gbCdbQqkzjOzPbcB5C(mH2iGBiqfsPhG0vOCwIQSudkXO00bnUZI0XP7miOrwkb3EZjs2S7SiDC6ob1ikTnCkfq07e1cwIJ972Bo7(MDNfPJt3jDaahGBoNPpanQ9orTGL4y)U9MJkyZUZI0XP7Kdv46qFnuUmiyNOwWsCSF3EZz75n7orTGL4y)UtciAee1obwk6oWl6FbbxkOjibrIEulyjoyjOzPUaVy7LOyuYscmewsIIrjlbnlnqylNZ7aN9O6hxgDNfPJt3PdC82ON4A7nNnBB2DIAblXX(DNeq0iiQDcSu0DGx0pcojOidTacAihnDPdpQfSehSe0Se5o54YOEylNZmcojOidTacAihnDPdpaRHGSe0SeSLZ5hbNeuKHwabnKJMU0HXfa0pUm6olshNUtxaqdSS492BoBpSz3jQfSeh73DsarJGO2jDPLNcPzjQYs25zwcAwQiDignOI0bYzjQcHLeODwKooDNfGukAqrrrE840T3C2SZMDNfPJt3jcFk8j7DIAblXX(D7nNThTz3jQfSeh73DsarJGO2jWsr3bEr)RSirjnoq9sJAZ9OwWsCWsqZsDjrT9CkYO7qFnbb9OwWsCWsqZsnOeJsth0iljWS0l4S0HPo0dld7TVadpaPRq57SiDC6odcAKLsWT3C2e5n7orTGL4y)Utos25ZEB7SiDC6oZurVtciAee1obwk6oWl6FLfjkPXbQxAuBUh1cwIdwcAwQljQTNtrgDh6RjiOh1cwIJT3C2eOn7olshNUth44n8j7DIAblXX(D7T3jzW3SBoBB2DIAblXX(DNeq0iiQDsbGInNZzEjdFqe0igdLZs5ZZsU4fQ2aq6kuoljWSKDEENfPJt3jLRJt3EZ9WMDNfPJt35aRgk4dO4orTGL4y)U9MZoB2DIAblXX(DNeq0iiQDwKoeJgur6a5SKaZs2HLGML(LLiNoSI2ZdkqDkom0LmiOh1cwIdwkFEwIFws4qh(mfVrzPddfWrbeylil9ZolshNUt6aaoa3CotFaAu7T3CpAZUtulyjo2V7KaIgbrTtYDYXLr9brqJymuUhG0vOCwIQSKThyjOzjylNZdSu0CodLldc8JlJUZI0XP7eyPO5CgkxgeS9MtK3S7e1cwIJ97ojGOrqu7e2Y58alfnNZq5YGa)4YO7SiDC6odIGgXyO8T3Cc0MDNOwWsCSF3jbencIANalfDh4f9nst5aL0KPau8OwWsCWsqZsWwoNhffuLfVJt9wuyjOzPFzjkauS5CoZlz4dIGgXyOCwkFEwYfVq1gasxHYzjbMLSZZS0p7SiDC6o7GgnzkaLT3CIKn7olshNUtloAIgP57e1cwIJ972Bo7(MDNfPJt3jS8UHXzbeCNOwWsCSF3EZrfSz3zr640DcJaoceDOV7e1cwIJ972BoBpVz3zr640DkJxOAUHkS14Lg1ENOwWsCSF3EZzZ2MDNfPJt3PlaiS8UXorTGL4y)U9MZ2dB2DwKooDNLsqEdkPHus5orTGL4y)U9MZMD2S7SiDC6oHRxZ5mniiIMVtulyjo2VBV9o59MDZzBZUtulyjo2V7KaIgbrTZFzjasxHg6RjtOnc4gcuHuYsqyPNzP85zPbcB5C(mH2iGBiqfsPFCzuw6hwcAw6xwIcafBEjdVnpcFk8jBwkFEwc2Y58WGkuJdGO9OhGfPzjOzPFzjkauS5Lm828VYIeL0WPeIgzP85zjkauS5Lm828oWXB4t2Se0S0VSevelroDyfTpaO5CMgk0uCcQdC4rTGL4GLYNNLi3jhxg1dQruAB4ukGO9aKUcLZs5ZZsalfDh4f9oaI2h6RjtOdUh1cwIdw6hwkFEwIcafBEjdVnpOgrPTHtPaIMLYNNLGTCoVl0xeWnNZ4ahV9aSinlbHLEMLGML(LLgiSLZ5Pda4aCZ5m9bOrT9wuyP85zjylNZ7aiAFOVMmHo4ElkSu(8SeSLZ5rrrP0bomuUg1okPhGfPzPFyPFyPF2zr640D6KwaGGBV5EyZUZI0XP70bo7r1Ca4DIAblXX(D7nND2S7e1cwIJ97ojGOrqu7e2Y58oaI2h6RbuH6TOWs5ZZsfPdXObvKoqolrviS0d7SiDC6oHLH92xGX2BUhTz3jQfSeh73DsarJGO2jaPRqd91Kj0gbCdbQqkzjiSKnwcAwAGWwoNptOnc4gcuHu6biDfkFNfPJt3jOe0CoJdC8E7nNiVz3jQfSeh73DsarJGO2jaPRqd91Kj0gbCdbQqkzjOzPbcB5C(mH2iGBiqfsPhG0vOCwIQSeP4TPdAKL(ZsnOeJsth04olshNUZxzrIsA4ucrJBV5eOn7orTGL4y)UtciAee1obiDfAOVMmH2iGBiqfsjlbnlbq6k0qFnzcTra3qGkKswIQSeSLZ5DH(IaU5Cgh44ThGfPzjOzPbcB5C(mH2iGBiqfsPhG0vOCwIQSudkXO00bnUZI0XP7miOrwkb3EZjs2S7SiDC6ojhn2gEFa6DIAblXX(D7nNDFZUZI0XP7miOrpX1orTGL4y)U9MJkyZUtulyjo2V7KaIgbrTtylNZ7aiAFOVMmHo4ElkSe0Sur6qmAqfPdKZsqyjB7SiDC6ob1ikTnCkfq0BV5S98MDNOwWsCSF3jbencIANWwoN3f6lc4MZzCGJ3EawKMLYNNLgiSLZ5DGZEu9aKUcLZsuLLAqjgLMoOXDwKooDNbbnYsj42BoB22S7SiDC6or4tHpzVtulyjo2VBV5S9WMDNOwWsCSF3jbencIAN)YsurSeWsr3bErVdGO9H(AYe6G7rTGL4GLYNNLkshIrdQiDGCwIQqyPhyPFyjOzjylNZddQqnoaI2JEawKENfPJt3jOgrPTHtPaIE7nNn7Sz3zr640DshaWb4MZz6dqJAVtulyjo2VBV5S9On7orTGL4y)UtciAee1oHTCopWsrZ5muUmiWpUmklbnl9llXpljCOd)l4eJMqfhVhO64uwkFEwIFws4qhExGYH5Cgy5X5hnNLYNNLkshIrdQiDGCwIQqyPhyPF2zr640DYHkCDOVgkxgeS9MZMiVz3jQfSeh73DsarJGO2jWsr3bEr)li4sbnbjis0JAblXblbnl1f4fBVefJswsGHWssumkzjOzPbcB5CEh4Shv)4YO7SiDC6oDGJ3g9exBV5SjqB2DIAblXX(DNeq0iiQDcSu0DGx0pcojOidTacAihnDPdpQfSehSe0Se5o54YOEylNZmcojOidTacAihnDPdpaRHGSe0SeSLZ5hbNeuKHwabnKJMU0HPaKsr)4YO7SiDC6olaPu0GIII84XPBV5Sjs2S7e1cwIJ97ojGOrqu7eyPO7aVOFeCsqrgAbe0qoA6shEulyjoyjOzjYDYXLr9WwoNzeCsqrgAbe0qoA6shEawdbzjOzjylNZpcojOidTacAihnDPdJlaOFCz0DwKooDNUaGgyzX7T3C2S7B2DIAblXX(DNeq0iiQDcB5CEyqfQXbq0E0dWI07SiDC6oFLfjkPHtjenU9MZgvWMDNfPJt3PdC8g(K9orTGL4y)U927K(eJ0O2B2nNTn7orTGL4y)UtciAee1oPpXinQTFe8UucYsuLLS98olshNUtyzOIE7n3dB2DIAblXX(DNeq0iiQDcB5C(GGgN8qUFCz0DwKooDNbbno5H8T3C2zZUtulyjo2V7KaIgbrTt6slpfsZsuLLSZZSe0Sur6qmAqfPdKZsufcl9WolshNUZcqkfnOOOipEC62BUhTz3zr640D6caAGLfV3jQfSeh73T3CI8MDNfPJt3zqqJSucUtulyjo2VBV927umc4XPBUhE(HNTz7b7SZmfqd9LVtrkQy7ICu5C21pMLyPSqHSuqt5anl5oalrDDi1SeafPTcaoyj(rJSuz1hD14GLiqv6lY9mHcyOilz75hZscWPIrqJdwIAGLIUd8IErqnl1hlrnWsr3bErVi8OwWsCqnl9Rnr9JNjuadfzjB2EmljaNkgbnoyjQbwk6oWl6fb1SuFSe1alfDh4f9IWJAblXb1S0V2e1pEMqbmuKLS9OhZscWPIrqJdwI6UKO2Erqnl1hlrDxsuBVi8OwWsCqnl9Rnr9JNjuadfzjBp6XSKaCQye04GLOgyPO7aVOxeuZs9XsudSu0DGx0lcpQfSehuZs)Atu)4zcfWqrwYMi)ywsaovmcACWsu3Le12lcQzP(yjQ7sIA7fHh1cwIdQzPQzj7gvOcil9Rnr9JNjuadfzjBI8Jzjb4uXiOXblrnWsr3bErViOML6JLOgyPO7aVOxeEulyjoOML(1MO(XZeYeksrfBxKJkNZU(XSelLfkKLcAkhOzj3byjQjdo1SeafPTcaoyj(rJSuz1hD14GLiqv6lY9mHcyOilzNhZscWPIrqJdwIAYPdRO9IGAwQpwIAYPdRO9IWJAblXb1S0V2e1pEMqbmuKLeOhZscWPIrqJdwIAGLIUd8IErqnl1hlrnWsr3bErVi8OwWsCqnl9Rnr9JNjKjuKIk2UihvoND9Jzjwkluilf0uoqZsUdWsuZBQzjaksBfaCWs8JgzPYQp6QXblrGQ0xK7zcfWqrwY2Jzjb4uXiOXblrnWsr3bErViOML6JLOgyPO7aVOxeEulyjoOML(1MO(XZekGHISKThZscWPIrqJdwIAYPdRO9IGAwQpwIAYPdRO9IWJAblXb1S0V2e1pEMqbmuKLS9WJzjb4uXiOXblrnWsr3bErViOML6JLOgyPO7aVOxeEulyjoOML(1MO(XZekGHISKnr(XSKaCQye04GLOgyPO7aVOxeuZs9XsudSu0DGx0lcpQfSehuZs)Atu)4zcfWqrwYMa9ywsaovmcACWsudSu0DGx0lcQzP(yjQbwk6oWl6fHh1cwIdQzPFTjQF8mHcyOilztK8ywsaovmcACWsudSu0DGx0lcQzP(yjQbwk6oWl6fHh1cwIdQzPFTjQF8mHmHuzAkhOXbljsyPI0XPSKm4n3ZeUtofKS5eOhTtkGZfsCNujwYUSErwYUcC8MjKkXs5oXinmcyPhE0tS0dp)WZmHmHujwIkZsfnljXsCOVSKDJZrLGCwkuwYs7qYsf4S0blz7JTpp88dpZswQe5CwIF0ydvOVSek5ilrXIdfYzjAKL6JLghlfTNjKjKkXs2nrHeRghSem6oaYsKJgUAwcgFdL7zjQycbP0CwspLkeOkaTZsYsfPJt5S0Psb9mHfPJt5EkaKC0Wv)hYNcqkfnH2OuIKMjSiDCk3tbGKJgU6)q(WTOPp1KPAeyqjsJAxsMWI0XPCpfasoA4Q)d5JdC8g(KntitivILSBIcjwnoyjumceKL6GgzPgkKLksFawk4SujUczblrptyr64uoeYzPnc4uqPKjSiDCk)pKpKsknfPJtnYG3pPfncHm4mHfPJt5)H8HusPPiDCQrg8(jTOriiNJkb5mHfPJt5)H8HusPPiDCQrg8(jTOri1HpfoifPdXObvKoqovH8iMWI0XP8)q(qkP0uKoo1idE)Kw0ieE)u4GuKoeJgur6a5c8JyclshNY)d5dPKstr64uJm49tArJqOpXinQntityr64uUVoeIdC2JQ5aWmHfPJt5(6W)q(ald7TVadMWI0XPCFD4FiFCslaqWNchKFbiDfAOVMmH2iGBiqfsjKNZNFGWwoNptOnc4gcuHu6hxg9hO)LcafBEjdVnpcFk8j785HTCopmOc14aiAp6byrAOHTCoVl0xeWnNZ4ahV9aSinKN)HjSiDCk3xh(hYNGGg9exmHfPJt5(6W)q(qoASn8(a0mHfPJt5(6W)q(ee0ilLGpfoiWwoN3f6lc4MZzCGJ3EawKoF(bcB5CEh4ShvpaPRq5uTbLyuA6GgZNhG0vOH(AYeAJaUHaviLqpqylNZNj0gbCdbQqk9aKUcLt1guIrPPdAKjSiDCk3xh(hYhqnIsBdNsbentyr64uUVo8pKp0baCaU5CM(a0O2mHfPJt5(6W)q(WHkCDOVgkxgeWewKooL7Rd)d5JdC82ON46PWbbyPO7aVO)feCPGMGeejcDxGxS9sumkfyisumkHEGWwoN3bo7r1pUmktyr64uUVo8pKpUaGgyzX7NcheGLIUd8I(rWjbfzOfqqd5OPlDan5o54YOEylNZmcojOidTacAihnDPdpaRHGqdB5C(rWjbfzOfqqd5OPlDyCba9JlJYewKooL7Rd)d5tbiLIguuuKhpo9PWbHU0YtH0u1opdDr6qmAqfPdKtvicetyr64uUVo8pKpi8PWNSzclshNY91H)H8jiOrwkbFkCqawk6oWl6FLfjkPXbQxAuBo0DjrT9CkYO7qFnbbHUbLyuA6Ggf4xWzPdtDOhwg2BFbgEasxHYzclshNY91H)H8jtf9tCKa5zVTNcheGLIUd8I(xzrIsACG6Lg1MdDxsuBpNIm6o0xtqqMWI0XPCFD4FiFCGJ3WNSzczclshNY9KbhcLRJtFkCqOaqXMZ5mVKHpicAeJHYZN3fVq1gasxHYfy78mtyr64uUNm4)H8zGvdf8buKjSiDCk3tg8)q(qhaWb4MZz6dqJA)u4GuKoeJgur6a5cSDG(xYPdRO98GcuNIddDjdcMpp)SKWHo8zkEJYshgkGJciWwWFyclshNY9Kb)pKpalfnNZq5YGGNcheYDYXLr9brqJymuUhG0vOCQA7bOHTCopWsrZ5muUmiWpUmktyr64uUNm4)H8jicAeJHYFkCqGTCopWsrZ5muUmiWpUmktyr64uUNm4)H8PdA0KPauEkCqawk6oWl6BKMYbkPjtbOanSLZ5rrbvzX74uVffO)LcafBoNZ8sg(GiOrmgkpFEx8cvBaiDfkxGTZZ)WewKooL7jd(FiFS4OjAKMZewKooL7jd(FiFGL3nmolGGmHfPJt5EYG)hYhyeWrGOd9LjSiDCk3tg8)q(iJxOAUHkS14Lg1MjSiDCk3tg8)q(4caclVBWewKooL7jd(FiFkLG8gusdPKsMWI0XPCpzW)d5dC9AoNPbbr0CMqMWI0XPCpY5OsqoKxRcmIsnNZu2JGRHIjSiDCk3JCoQeK)hYh3rS44Wu2JGOrdmw0mHfPJt5EKZrLG8)q(qJ0hqqZ5mslsmmdaw0CMWI0XPCpY5Osq(FiFGL3nmNZ0qHgurAbzclshNY9iNJkb5)H8HIfiCcg6Rbww8MjSiDCk3JCoQeK)hYhqqHIenHA4ukcYewKooL7rohvcY)d5d5ucQnOACyCYIgFsgkAidicetyr64uUh5Cuji)pKpaSOe6RXjlAKZewKooL7rohvcY)d5tdfASu4Zshg3bi4tHdcSLZ5bir0sKZnUdqqVffMWI0XPCpY5Osq(FiFYCa5qmgQbG8tlLGmHfPJt5EKZrLG8)q(afwG2GCoQeKjKjSiDCk3tFIrAuBiWYqfTPubFkCqOpXinQTFe8UucsvBpZewKooL7PpXinQ9FiFccACYd5pfoiWwoNpiOXjpK7hxgLjSiDCk3tFIrAu7)q(uasPObfff5XJtFkCqOlT8uinvTZZqxKoeJgur6a5ufYdmHfPJt5E6tmsJA)hYhxaqdSS4ntyr64uUN(eJ0O2)H8jiOrwkbzczclshNY98gItAbac(u4G8laPRqd91Kj0gbCdbQqkH8C(8de2Y58zcTra3qGkKs)4YO)a9VuaOyZlz4T5r4tHpzNppSLZ5HbvOghar7rpalsd9VuaOyZlz4T5FLfjkPHtjenMppfak28sgEBEh44n8jBO)LkIC6WkAFaqZ5mnuOP4euh4iFEYDYXLr9GAeL2goLciApaPRq55ZdSu0DGx07aiAFOVMmHo4)Kppfak28sgEBEqnIsBdNsbeD(8WwoN3f6lc4MZzCGJ3EawKgYZq)7aHTCopDaahGBoNPpanQT3Is(8WwoN3bq0(qFnzcDW9wuYNh2Y58OOOu6ahgkxJAhL0dWI0)8ZpmHfPJt5EE)hYhh4ShvZbGzclshNY98(pKpWYWE7lW4PWbb2Y58oaI2h6RbuH6TOKpFr6qmAqfPdKtvipWewKooL759FiFaLGMZzCGJ3pfoiaKUcn0xtMqBeWneOcPeInOhiSLZ5ZeAJaUHaviLEasxHYzclshNY98(pKpVYIeL0WPeIgFkCqaiDfAOVMmH2iGBiqfsj0de2Y58zcTra3qGkKspaPRq5uLu820bn(VbLyuA6GgzclshNY98(pKpbbnYsj4tHdcaPRqd91Kj0gbCdbQqkHgG0vOH(AYeAJaUHaviLuf2Y58UqFra3CoJdC82dWI0qpqylNZNj0gbCdbQqk9aKUcLt1guIrPPdAKjSiDCk3Z7)q(qoASn8(a0mHfPJt5EE)hYNGGg9exmHfPJt5EE)hYhqnIsBdNsbe9tHdcSLZ5DaeTp0xtMqhCVffOlshIrdQiDGCi2yclshNY98(pKpbbnYsj4tHdcSLZ5DH(IaU5Cgh44ThGfPZNFGWwoN3bo7r1dq6kuovBqjgLMoOrMWI0XPCpV)d5dcFk8jBMWI0XPCpV)d5dOgrPTHtPaI(PWb5xQiGLIUd8IEhar7d91Kj0bpF(I0Hy0GkshiNQqE4hOHTCopmOc14aiAp6byrAMWI0XPCpV)d5dDaahGBoNPpanQntyr64uUN3)H8Hdv46qFnuUmi4PWbb2Y58alfnNZq5YGa)4YOq)l)SKWHo8VGtmAcvC8EGQJtZNNFws4qhExGYH5Cgy5X5hnpF(I0Hy0GkshiNQqE4hMWI0XPCpV)d5JdC82ON46PWbbyPO7aVO)feCPGMGeejcDxGxS9sumkfyisumkHEGWwoN3bo7r1pUmktyr64uUN3)H8PaKsrdkkkYJhN(u4GaSu0DGx0pcojOidTacAihnDPdOj3jhxg1dB5CMrWjbfzOfqqd5OPlD4byneeAylNZpcojOidTacAihnDPdtbiLI(XLrzclshNY98(pKpUaGgyzX7NcheGLIUd8I(rWjbfzOfqqd5OPlDan5o54YOEylNZmcojOidTacAihnDPdpaRHGqdB5C(rWjbfzOfqqd5OPlDyCba9JlJYewKooL759FiFELfjkPHtjen(u4GaB5CEyqfQXbq0E0dWI0mHfPJt5EE)hYhh44n8j7T3Ex]] )


end
