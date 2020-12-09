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

    
    spec:RegisterPack( "Frost Mage", 20201201, [[dK0XWaqivvu9ijiztiHpHKAuQk6uQk8kvvnlvHULeKk7sOFPQ0WufCmbzzQQ0ZienncGRjbLTri4BeczCsqvNtvfX6uvH5ra6EGyFijoOQkkluv0drsYevvrQlkbbBucI6JecLtkbvwjbntKK6MsqKDkr9tjivTuji0tv0uLqFLqOASeq7vP)sYGv4WIwmOEmIjlPldTzs9zvPrJeDAQwTQksEnHuZMOBJu7MYVvz4G0XLGuwoWZrz6sDDb2oH67cQXti58eO1lbMVez)O6n0wCN1SXT8Vp87dH(9HqXqcWdpia7SfekUtOjr05lUtlPXDwidowZhfs5lUtOPGYlRBXDYUaab3jLDdL9JVFF9MYa4i5O)YC6az2(zeqQ7VmNM8DNWbUSlC2cVZA24w(3h(9Hq)(qOyib4Hh(vK7mdAkpWoNonvTtk9AfTfENvKr2zHIpkKYxKpkKbhR5clu8XpnsqAyeWhHEKp(9HFFyNsN1ST4orgdncY2IB5qBXDMK2pBNVbjO6PPoTklabxt5orlHLyDFU9w(3T4ots7NTt9rcyyvLfGaVrfmM07eTewI1952BzrUf3zsA)SDsJ0hqq1PvYaIxvvaM0SDIwclX6(C7TSaSf3zsA)SDclVRQoTQPevOH0cUt0syjw3NBVLlST4ots7NTtObaxlOBVkyzY6DIwclX6(C7TSiSf3zsA)SDcCOqLOYnfdAsWDIwclX6(C7TSiAlUt0syjw3N7mjTF2ojNrqRbzJvLwM04oLUHksDNIW2B5c)wCNjP9Z2jatOU9Q0YKgz7eTewI1952B5FYwCNOLWsSUp3jb4nc8CNWbADeGerlrgtPpabJbq3zsA)SD2uIQad(cSQsFacU9wo0dBXDMK2pBNHpGSkgDtbq2zPrWDIwclX6(C7TCOqBXDMK2pBNuIjOviJHgb3jAjSeR7ZT3ENvuNbYElULdTf3zsA)SDsUaRradkkL7eTewI1952B5F3I7eTewI195ots7NTtskLQK0(zkPZ6DkDwRSKg3jPY2EllYT4orlHLyDFUZK0(z7KKsPkjTFMs6SENsN1klPXDImgAeKT9wwa2I7eTewI195ojaVrGN7mjTlgvOH0oY4dQaHpe5ots7NTtskLQK0(zkPZ6DkDwRSKg3zE42B5cBlUt0syjw3N7Ka8gbEUZK0UyuHgs7iJpeq(qK7mjTF2ojPuQss7NPKoR3P0zTYsACNSE7TSiSf3jAjSeR7ZDMK2pBNKukvjP9ZusN17u6SwzjnUt6tmsJwV927ekajhnC2BXTCOT4ots7NTZeqsdvU1OuIKENOLWsSUp3El)7wCNjP9Z2z4SrGcLinADk3jAjSeR7ZT3YIClUZK0(z7udowdFYENOLWsSUp3E7DMhUf3YH2I7mjTF2o1GRa0uhaENOLWsSUp3El)7wCNjP9Z2jS0lOGeu3jAjSeR7ZT3YIClUt0syjw3N7Ka8gbEUZp5dasNU52RkSBncykcLUuYhq4Jh4JsL4JkchO1XWU1iGPiu6szSEHn(4d(Gc(4t(akafREj1yOicFg8jB(Ouj(aoqRJWG0nLgGybyeGjP5dk4d4aToQD7fbm1PvAWX6iatsZhq4Jh4Jp2zsA)SDQLbaGGBVLfGT4ots7NTtNGk7eN7eTewI1952B5cBlUZK0(z7KC0yRy9bO3jAjSeR7ZT3YIWwCNOLWsSUp3jb4nc8CNWbADu72lcyQtR0GJ1raMKMpkvIpQiCGwh1GRa0IaKoDJXhuHpAqkgLQ2Pr(Ouj(aG0PBU9Qc7wJaMIqPlL8bf8rfHd06yy3AeWuekDPmcq60ngFqf(ObPyuQANg3zsA)SD6eujtJGBVLfrBXDMK2pBNGS6P1kg0ei6DIwclX6(C7TCHFlUZK0(z7K2bGdWuNw1hGgTENOLWsSUp3El)t2I7mjTF2ozu662Txf0lmc2jAjSeR7ZT3YHEylUt0syjw3N7Ka8gbEUtqGH6d8IXxGZKcQCItKyeTewIv(Gc(OtWl2rjkgL8HacHpKOyuYhuWhveoqRJAWvaAX6f22zsA)SDQbhRv2jo3Elhk0wCNOLWsSUp3jb4nc8CNGad1h4fJvNrCOs3sGGkYrtNwnIwclXkFqbFqUtwVWweoqRvvNrCOs3sGGkYrtNwncWSkiFqbFahO1XQZiouPBjqqf5OPtRQ0oaJ1lSTZK0(z7u7aubltwV9wo0VBXDIwclX6(CNeG3iWZDsNwgHsA(Gk8HiFGpOGpss7IrfAiTJm(Gkq4dryNjP9Z2zciPHkuuqLhZpB7TCirUf3zsA)SDIWNbFYENOLWsSUp3Elhsa2I7eTewI195ojaVrGN7eeyO(aVy8vMepLkniFPrRzr0syjw5dk4JoLO1rguP3TBVkNGr0syjw5dk4JgKIrPQDAKpeq(4fCbwvLhgHLEbfKGAeG0PBSDMK2pBNobvY0i42B5qf2wCNOLWsSUp3jdj78HyODMK2pBNHtV3jb4nc8CNGad1h4fJVYK4PuPb5lnAnlIwclXkFqbF0PeToYGk9UD7v5emIwclX62B5qIWwCNjP9Z2PgCSg(K9orlHLyDFU927KuzBXTCOT4orlHLyDFUtcWBe45oHcqXQtRvVKA0jcQeJUX4JsL4dT)szRaiD6gJpeq(qKpSZK0(z7e61(zBVL)DlUZK0(z7SIztj8bmCNOLWsSUp3EllYT4orlHLyDFUtcWBe45ots7IrfAiTJm(qa5drYhuWhFYhKZQbEhzoukpdRk6u6emIwclXkFuQeFWUajSB1y4K1OmTQck4GcCSfKp(yNjP9Z2jTdahGPoTQpanA92BzbylUt0syjw3N7Ka8gbEUtYDY6f2IorqLy0nweG0PBm(Gk8rOF5dk4d4aToccmuDAf0lmcI1lSTZK0(z7eeyO60kOxyeS9wUW2I7eTewI195ojaVrGN7eoqRJGadvNwb9cJGy9cB7mjTF2oDIGkXOBST3YIWwCNOLWsSUp3jb4nc8CNGad1h4fJnsd9aPufobqJOLWsSYhuWhWbADeffLzaR9ZIbq5dk4Jp5dOauS60A1lPgDIGkXOBm(Ouj(q7Vu2kasNUX4dbKpe5d8Xh7mjTF2oBNgvHta0T3YIOT4ots7NTZagQ8gPz7eTewI1952B5c)wCNjP9Z2jS8UQshaeCNOLWsSUp3El)t2I7mjTF2oHradbI2T3DIwclX6(C7TCOh2I7mjTF2oL(lLnt9tfuFPrR3jAjSeR7ZT3YHcTf3zsA)SDQDaclVRUt0syjw3NBVLd97wCNjP9Z2zAeK1GuQiPuUt0syjw3NBVLdjYT4ots7NTt48vDAvdCIOz7eTewI1952BVtwVf3YH2I7eTewI195ojaVrGN78t(aG0PBU9Qc7wJaMIqPlL8be(4b(Ouj(OIWbADmSBncykcLUugRxyJp(GpOGp(KpGcqXQxsngkIWNbFYMpkvIpGd06imiDtPbiwagbysA(Gc(4t(akafREj1yO4RmjEkvmOUOr(Ouj(akafREj1yOOgCSg(KnFqbF8jF8Z5dYz1aVJoavNw1uIQKrqRI1iAjSeR8rPs8b5oz9cBrqw90AfdAceDeG0PBm(Ouj(aeyO(aVyudqSa3EvHDRYIOLWsSYhFWhLkXhqbOy1lPgdfbz1tRvmOjq08rPs8bCGwh1U9IaM60kn4yDeGjP5di8Xd8bf8XN8rfHd06iTdahGPoTQpanADmakFuQeFahO1rnaXcC7vf2TklgaLpkvIpGd06ikkOPvXQc61O1EkJamjnF8bF8bF8Xots7NTtTmaaeC7T8VBXDMK2pBNAWvaAQdaVt0syjw3NBVLf5wCNOLWsSUp3jb4nc8CNWbADudqSa3EvG0Tyau(Ouj(ijTlgvOH0oY4dQaHp(DNjP9Z2jS0lOGeu3EllaBXDIwclX6(CNeG3iWZDcq60n3EvHDRratrO0Ls(acFeIpOGpQiCGwhd7wJaMIqPlLrasNUX2zsA)SDcsbvNwPbhR3ElxyBXDIwclX6(CNeG3iWZDcq60n3EvHDRratrO0Ls(Gc(OIWbADmSBncykcLUugbiD6gJpOcFqswRANg5J)8rdsXOu1onUZK0(z78vMepLkgux042BzrylUt0syjw3N7Ka8gbEUtasNU52RkSBncykcLUuYhuWhaKoDZTxvy3AeWuekDPKpOcFahO1rTBViGPoTsdowhbysA(Gc(OIWbADmSBncykcLUugbiD6gJpOcF0GumkvTtJ7mjTF2oDcQKPrWT3YIOT4ots7NTtYrJTI1hGENOLWsSUp3Elx43I7mjTF2oDcQStCUt0syjw3NBVL)jBXDIwclX6(CNeG3iWZDchO1rnaXcC7vf2TklgaLpOGpss7IrfAiTJm(acFeANjP9Z2jiREATIbnbIE7TCOh2I7eTewI195ojaVrGN7eoqRJA3EratDALgCSocWK08rPs8rfHd06OgCfGweG0PBm(Gk8rdsXOu1onUZK0(z70jOsMgb3Elhk0wCNjP9Z2jcFg8j7DIwclX6(C7TCOF3I7eTewI195ojaVrGN78t(4NZhGad1h4fJAaIf42RkSBvweTewIv(Ouj(ijTlgvOH0oY4dQaHp(Lp(GpOGpGd06imiDtPbiwagbys6DMK2pBNGS6P1kg0ei6T3YHe5wCNjP9Z2jTdahGPoTQpanA9orlHLyDFU9woKaSf3jAjSeR7ZDsaEJap3jCGwhbbgQoTc6fgbX6f24dk4Jp5d2fiHDRgFbNyu5My)9az7NXhLkXhSlqc7wnQDuwvNwblpg7Oz8rPs8rsAxmQqdPDKXhubcF8lF8Xots7NTtgLUUD7vb9cJGT3YHkST4orlHLyDFUtcWBe45obbgQpWlgFbotkOYjorIr0syjw5dk4JobVyhLOyuYhcie(qIIrjFqbFur4aToQbxbOfRxyBNjP9Z2PgCSwzN4C7TCirylUt0syjw3N7Ka8gbEUtqGH6d8IXQZiouPBjqqf5OPtRgrlHLyLpOGpi3jRxylchO1QQZiouPBjqqf5OPtRgbywfKpOGpGd06y1zehQ0TeiOIC00PvvjGKggRxyBNjP9Z2zciPHkuuqLhZpB7TCir0wCNOLWsSUp3jb4nc8CNGad1h4fJvNrCOs3sGGkYrtNwnIwclXkFqbFqUtwVWweoqRvvNrCOs3sGGkYrtNwncWSkiFqbFahO1XQZiouPBjqqf5OPtRQ0oaJ1lSTZK0(z7u7aubltwV9wouHFlUt0syjw3N7Ka8gbEUt4aTocds3uAaIfGraMKENjP9Z25RmjEkvmOUOXT3YH(jBXDMK2pBNAWXA4t27eTewI1952BVt6tmsJwVf3YH2I7eTewI195ojaVrGN7K(eJ0O1XQZ60iiFqf(i0d7mjTF2oHLUj6T3Y)Uf3jAjSeR7ZDsaEJap3jCGwhDcQ0YdzX6f22zsA)SD6euPLhY2EllYT4orlHLyDFUtcWBe45oPtlJqjnFqf(qKpWhuWhjPDXOcnK2rgFqfi8XV7mjTF2otajnuHIcQ8y(zBVLfGT4ots7NTtTdqfSmz9orlHLyDFU9wUW2I7mjTF2oDcQKPrWDIwclX6(C7T3ENIraZpBl)7d)(qOq)ka7mCcm3Ez7ue)NviwUWvwe7h8bFuKsKpCAOhO5d9b4dQZdPMpayHwGdWkFWoAKpYG(OZgR8bHY0ErwKlKQDd5Jqp8d(GQotmcASYhudcmuFGxmkqQ5J(4dQbbgQpWlgfyeTewIvQ5JpdjQpICHuTBiFek0p4dQ6mXiOXkFqniWq9bEXOaPMp6JpOgeyO(aVyuGr0syjwPMp(mKO(iYfs1UH8rib4h8bvDMye0yLpOUtjADuGuZh9Xhu3PeTokWiAjSeRuZhFgsuFe5cPA3q(iKa8d(GQotmcASYhudcmuFGxmkqQ5J(4dQbbgQpWlgfyeTewIvQ5JpdjQpICHuTBiFeQW(bFqvNjgbnw5dQ7uIwhfi18rF8b1DkrRJcmIwclXk18r28rHqHEQMp(mKO(iYfs1UH8rOc7h8bvDMye0yLpOgeyO(aVyuGuZh9XhudcmuFGxmkWiAjSeRuZhFgsuFe5c5cfX)zfILlCLfX(bFWhfPe5dNg6bA(qFa(GAsLrnFaWcTahGv(GD0iFKb9rNnw5dcLP9ISixiv7gYhI8h8bvDMye0yLpOMCwnW7OaPMp6JpOMCwnW7OaJOLWsSsnF8zir9rKlKQDd5dr4h8bvDMye0yLpOgeyO(aVyuGuZh9XhudcmuFGxmkWiAjSeRuZhFgsuFe5c5cfX)zfILlCLfX(bFWhfPe5dNg6bA(qFa(GAwtnFaWcTahGv(GD0iFKb9rNnw5dcLP9ISixiv7gYhH(bFqvNjgbnw5dQbbgQpWlgfi18rF8b1Gad1h4fJcmIwclXk18XNHe1hrUqQ2nKpc9d(GQotmcASYhutoRg4DuGuZh9XhutoRg4DuGr0syjwPMp(mKO(iYfs1UH8rOF)bFqvNjgbnw5dQbbgQpWlgfi18rF8b1Gad1h4fJcmIwclXk18XNHe1hrUqQ2nKpcvy)GpOQZeJGgR8b1Gad1h4fJcKA(Op(GAqGH6d8IrbgrlHLyLA(4ZqI6Jixiv7gYhHeHFWhu1zIrqJv(GAqGH6d8IrbsnF0hFqniWq9bEXOaJOLWsSsnF8zir9rKlKQDd5JqIOFWhu1zIrqJv(GAqGH6d8IrbsnF0hFqniWq9bEXOaJOLWsSsnF8zir9rKlKlSWrd9anw5dreFKK2pJpKoRzrUWDcfCAxI7SqXhfs5lYhfYGJ1CHfk(4Ngjinmc4JqpYh)(WVpWfYfwO4JcbrHKGgR8bmQpaYhKJgoB(agFDJf5JFgHGqBgFyNvOJYeqRdK8rsA)mgFCMuWixysA)mwekajhnC2)H8nbK0qLBnkLiP5cts7NXIqbi5OHZ(pKVSaA6ZuHZgbkuI0O1PKlmjTFglcfGKJgo7)q(QbhRHpzZfYfwO4JcbrHKGgR8bkgbcYhTtJ8rtjYhjPpaF4m(ifNUmHLyKlmjTFgdc5cSgbmOOuYfMK2pJ9hYxskLQK0(zkPZ6hTKgHqQmUWK0(zS)q(ssPuLK2ptjDw)OL0ieKXqJGmUWK0(zS)q(ssPuLK2ptjDw)OL0iK8WhDnKK0UyuHgs7iJkqejxysA)m2FiFjPuQss7NPKoRF0sAecRF01qss7IrfAiTJmbuKCHjP9Zy)H8LKsPkjTFMs6S(rlPri0NyKgTMlKlmjTFglMhcrdUcqtDayUWK0(zSyE4FiFHLEbfKGkxysA)mwmp8pKVAzaai4JUgYNaKoDZTxvy3AeWuekDPeYdLkvr4aTog2TgbmfHsxkJ1lS9bfFcfGIvVKAmueHpd(KDPsWbADegKUP0aelaJamjnfWbADu72lcyQtR0GJ1raMKgYdFWfMK2pJfZd)d5RtqLDItUWK0(zSyE4FiFjhn2kwFaAUWK0(zSyE4FiFDcQKPrWhDne4aToQD7fbm1PvAWX6iatsxQufHd06OgCfGweG0PBmQ0GumkvTtJLkbq60n3EvHDRratrO0LskQiCGwhd7wJaMIqPlLrasNUXOsdsXOu1onYfMK2pJfZd)d5liREATIbnbIMlmjTFglMh(hYxAhaoatDAvFaA0AUWK0(zSyE4FiFzu662Txf0lmc4cts7NXI5H)H8vdowRStC(ORHacmuFGxm(cCMuqLtCIePOtWl2rjkgLciejkgLuur4aToQbxbOfRxyJlmjTFglMh(hYxTdqfSmz9JUgciWq9bEXy1zehQ0TeiOIC00PvPGCNSEHTiCGwRQoJ4qLULabvKJMoTAeGzvqkGd06y1zehQ0TeiOIC00PvvAhGX6f24cts7NXI5H)H8nbK0qfkkOYJ5N9ORHqNwgHsAQiYhOijTlgvOH0oYOcerGlmjTFglMh(hYxe(m4t2CHjP9ZyX8W)q(6eujtJGp6AiGad1h4fJVYK4PuPb5lnAnJIoLO1rguP3TBVkNGu0GumkvTtJc4l4cSQkpmcl9ckib1iaPt3yCHjP9ZyX8W)q(go9(rgsG8qm0JUgciWq9bEX4RmjEkvAq(sJwZOOtjADKbv6D72RYjixysA)mwmp8pKVAWXA4t2CHCHjP9ZyrsLbb61(zp6AiqbOy1P1Qxsn6ebvIr3yLkP9xkBfaPt3ycOiFGlmjTFglsQS)q(wXSPe(agYfMK2pJfjv2FiFPDa4am1Pv9bOrRF01qss7IrfAiTJmbuKu8j5SAG3rMdLYZWQIoLoblvIDbsy3QXWjRrzAvfuWbf4yl4hCHjP9ZyrsL9hYxqGHQtRGEHrWJUgc5oz9cBrNiOsm6glcq60ngvc9lfWbADeeyO60kOxyeeRxyJlmjTFglsQS)q(6ebvIr3yp6AiWbADeeyO60kOxyeeRxyJlmjTFglsQS)q(2onQcNaOp6AiGad1h4fJnsd9aPufobqPaoqRJOOOmdyTFwmakfFcfGIvNwREj1OteujgDJvQK2FPSvaKoDJjGI8Hp4cts7NXIKk7pKVbmu5nsZ4cts7NXIKk7pKVWY7QkDaqqUWK0(zSiPY(d5lmcyiq0U9YfMK2pJfjv2FiFL(lLnt9tfuFPrR5cts7NXIKk7pKVAhGWY7QCHjP9ZyrsL9hY30iiRbPursPKlmjTFglsQS)q(cNVQtRAGtenJlKlmjTFglImgAeKb5nibvpn1Pvzbi4Ak5cts7NXIiJHgbz)H8vFKagwvzbiWBubJjnxysA)mwezm0ii7pKV0i9beuDALmG4vvfGjnJlmjTFglImgAeK9hYxy5Dv1PvnLOcnKwqUWK0(zSiYyOrq2FiFHgaCTGU9QGLjR5cts7NXIiJHgbz)H8f4qHkrLBkg0KGCHjP9ZyrKXqJGS)q(soJGwdYgRkTmPXhLUHksfIiWfMK2pJfrgdncY(d5latOU9Q0YKgzCHjP9ZyrKXqJGS)q(2uIQad(cSQsFac(ORHahO1raseTezmL(aemgaLlmjTFglImgAeK9hY3WhqwfJUPai7S0iixysA)mwezm0ii7pKVuIjOviJHgb5c5cts7NXI0NyKgTgcS0nrRstWhDne6tmsJwhRoRtJGuj0dCHjP9Zyr6tmsJw)hYxNGkT8q2JUgcCGwhDcQ0YdzX6f24cts7NXI0NyKgT(pKVjGKgQqrbvEm)ShDne60Yiustfr(afjPDXOcnK2rgvG8lxysA)mwK(eJ0O1)H8v7aubltwZfMK2pJfPpXinA9FiFDcQKPrqUqUWK0(zSiRHOLbaGGp6AiFcq60n3EvHDRratrO0LsipuQufHd06yy3AeWuekDPmwVW2hu8juakw9sQXqre(m4t2LkbhO1ryq6MsdqSamcWK0u8juakw9sQXqXxzs8uQyqDrJLkbfGIvVKAmuudowdFYMIp)5KZQbEhDaQoTQPevjJGwfRLkrUtwVWweKvpTwXGMarhbiD6gRujqGH6d8IrnaXcC7vf2Tk7JsLGcqXQxsngkcYQNwRyqtGOlvcoqRJA3EratDALgCSocWK0qEGIpRiCGwhPDa4am1Pv9bOrRJbqlvcoqRJAaIf42RkSBvwmaAPsWbADeff00Qyvb9A0ApLraMK(Jp(GlmjTFglY6)q(QbxbOPoamxysA)mwK1)H8fw6fuqcQp6AiWbADudqSa3EvG0Tya0sLss7IrfAiTJmQa5xUWK0(zSiR)d5lifuDALgCS(rxdbG0PBU9Qc7wJaMIqPlLqcrrfHd06yy3AeWuekDPmcq60ngxysA)mwK1)H89vMepLkgux04JUgcaPt3C7vf2TgbmfHsxkPOIWbADmSBncykcLUugbiD6gJkKK1Q2PX)nifJsv70ixysA)mwK1)H81jOsMgbF01qaiD6MBVQWU1iGPiu6sjfaKoDZTxvy3AeWuekDPKkWbADu72lcyQtR0GJ1raMKMIkchO1XWU1iGPiu6szeG0PBmQ0GumkvTtJCHjP9Zyrw)hYxYrJTI1hGMlmjTFglY6)q(6euzN4KlmjTFglY6)q(cYQNwRyqtGOF01qGd06OgGybU9Qc7wLfdGsrsAxmQqdPDKbjexysA)mwK1)H81jOsMgbF01qGd06O2TxeWuNwPbhRJamjDPsveoqRJAWvaArasNUXOsdsXOu1onYfMK2pJfz9FiFr4ZGpzZfMK2pJfz9FiFbz1tRvmOjq0p6AiF(ZbbgQpWlg1aelWTxvy3QSsLss7IrfAiTJmQa53pOaoqRJWG0nLgGybyeGjP5cts7NXIS(pKV0oaCaM60Q(a0O1CHjP9Zyrw)hYxgLUUD7vb9cJGhDne4aToccmuDAf0lmcI1lSrXNSlqc7wn(coXOYnX(7bY2pRuj2fiHDRg1okRQtRGLhJD0SsLss7IrfAiTJmQa53p4cts7NXIS(pKVAWXALDIZhDneqGH6d8IXxGZKcQCItKifDcEXokrXOuaHirXOKIkchO1rn4kaTy9cBCHjP9Zyrw)hY3eqsdvOOGkpMF2JUgciWq9bEXy1zehQ0TeiOIC00PvPGCNSEHTiCGwRQoJ4qLULabvKJMoTAeGzvqkGd06y1zehQ0TeiOIC00PvvjGKggRxyJlmjTFglY6)q(QDaQGLjRF01qabgQpWlgRoJ4qLULabvKJMoTkfK7K1lSfHd0Av1zehQ0TeiOIC00PvJamRcsbCGwhRoJ4qLULabvKJMoTQs7amwVWgxysA)mwK1)H89vMepLkgux04JUgcCGwhHbPBknaXcWiatsZfMK2pJfz9FiF1GJ1WNS3jdks2YIGaS927c]] )


end
