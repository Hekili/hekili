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

    
    spec:RegisterPack( "Frost Mage", 20201123, [[dGusWaqivLI8ivLsBcj6teOrHeCkKqVceMLKQULGsk7sOFPkAyQk5ycYYKu5zeknnKuCnKuABij13qsIXjOuDobLY6uvQMhsQCpvv7djXbrsswOQIhsOWfvvkSrbLKpIKK6KiPkRKGMjHIUPGsyNsk)uqjvlvqj6PkmvjPVIKQQXsOYEv6VumyjoSOfdQhJyYk6YqBMsFwvA0GOtt1QvvkQxlOy2eDBKA3K(TkdhKoosQklh45OmDPUUaBNq(UKy8eQ68eW6funFvH9JQ3qB1DmZg3A19vDFfkuDIngIARJQdTJwaO4oGMKWKV4o0Kg3ryf4ynVewKV4oGMciVCUv3b7caeChq2nu23F(81BidGJKJ(jZPdKz7NsaPTFYCAYZDah4YM6Pl8oMzJBT6(QUVcfQoXgdrT1rTuBD7idAipWogoTySdi95e1fEhtKr2X3YlHf5lYlHvGJ1CHFlVu7eH0WiGxQtS1Zl19vDFXfYf(T8c1JxsAErIPixF5LVbJHkbz8IR8sG2UKxsWfOtEj0ZqpR7R6(IxcujYy8c7OXgsxF5fuYqEbAadsKXl0iV0hVmpEX74oKoRzB1DGmgQeKTv3AH2Q7ijTF6oEdsW0t1CwtgocUgYDGAclX5(z7TwDB1DKK2pDh2JeWWPjdhbEJgymP3bQjSeN7NT3AIDRUJK0(P7GgPpGaMZAKbeFAMamPz7a1ewIZ9Z2BnQzRUJK0(P7awE30CwtdjAqfPfyhOMWsCUF2ERrTB1DKK2pDhqdaUvaxFnWYK17a1ewIZ9Z2BnQERUJK0(P7a4qHkrJRgg0KG7a1ewIZ9Z2BnQYwDhOMWsCUF2rsA)0DqoLGAdYgNgRmPXDiDfnK5oO6T3AH9T6oss7NUdaMqD91yLjnY2bQjSeN7NT3AHTT6oqnHL4C)SdcWBe45oGdS2iajHrImMXEacgdGUJK0(P7OHenbk8fOtJ9aeC7TwOV2Q7ijTF6oQCa5ue6QbGSttLG7a1ewIZ9Z2BTqH2Q7ijTF6oGetqBqgdvcUdutyjo3pBV9oMOndK9wDRfARUJK0(P7GCbAJaguuk3bQjSeN7NT3A1Tv3bQjSeN7NDKK2pDhKuknjP9tnsN17q6S2OjnUdYKT9wtSB1DGAclX5(zhjP9t3bjLstsA)uJ0z9oKoRnAsJ7azmujiB7Tg1Sv3bQjSeN7NDqaEJap3rsAxeAqfPDKXlu5NxOMDKK2pDhKuknjP9tnsN17q6S2OjnUJ8WT3Au7wDhOMWsCUF2bb4nc8ChjPDrObvK2rgVqD8c1SJK0(P7GKsPjjTFQr6SEhsN1gnPXDW6T3Au9wDhOMWsCUF2rsA)0DqsP0KK2p1iDwVdPZAJM04oOprinQ92BVdOaKC0WzVv3AH2Q7ijTF6osajv04AJsjs6DGAclX5(z7TwDB1DKK2pDhvYgbguI0O2PChOMWsCUF2ERj2T6oss7NUdl4yn8j7DGAclX5(z7T3rE4wDRfARUJK0(P7WcUWr1Ca4DGAclX5(z7TwDB1DKK2pDhWsp8WtWChOMWsCUF2ERj2T6oqnHL4C)SdcWBe45oOaVaq60vxFnvCTraZqG0LsE5Nx(IxE8GxMiCG1gR4AJaMHaPlLX5vr5fkYluYluGxGcqrMxYmgkIWNcFYMxE8GxGdS2imiD1ybigogbysAEHsEboWAJwxFraZCwJfCSocWK08YpV8fVqXDKK2pDhwzaaiW2BnQzRUJK0(P7WjOrpr5oqnHL4C)S9wJA3Q7ijTF6oihn2gwFa6DGAclX5(z7TgvVv3bQjSeN7NDqaEJap3bCG1gTU(IaM5Sgl4yDeGjP5Lhp4LjchyTrl4ch1iaPtxz8cv4LgKIqPPDAKxE8GxaiD6QRVMkU2iGziq6sjVqjVmr4aRnwX1gbmdbsxkJaKoDLXluHxAqkcLM2PXDKK2pDhobnYuj42BnQYwDhjP9t3biNEQTHbnbHzhOMWsCUF2ERf23Q7ijTF6oODa4amZzn9bOrT3bQjSeN7NT3AHTT6oss7NUdgKUTD91a9QGGDGAclX5(z7TwOV2Q7a1ewIZ9ZoiaVrGN7aeOO9aVy8f4mPagN4ejgrnHL4KxOKx6e8IDuIIqjVqD)8IefHsEHsEzIWbwB0cUWrnoVk6oss7NUdl4yTrpr52BTqH2Q7a1ewIZ9ZoiaVrGN7aeOO9aVyC6mIdv6AceWqoA6uNrutyjo5fk5fYDY5vrJWbwRz6mIdv6AceWqoA6uNraMtb4fk5f4aRnoDgXHkDnbcyihnDQtJ1byCEv0DKK2pDhwhGgyzY6T3AHQBRUdutyjo3p7Ga8gbEUd6uZiusZluHxe7x8cL8ssAxeAqfPDKXlu5NxO6DKK2pDhjGKkAqXdvEm)0T3AHe7wDhjP9t3bcFk8j7DGAclX5(z7TwiQzRUdutyjo3p7Ga8gbEUdqGI2d8IXxzs8uASG8Lg1MfrnHL4KxOKx6uIAhzqLE3U(ACcgrnHL4KxOKxAqkcLM2PrEH64LxWfOttEyew6HhEcMrasNUY2rsA)0D4e0itLGBV1crTB1DGAclX5(zhmKSJVIH2rsA)0Duj9EheG3iWZDacu0EGxm(ktINsJfKV0O2SiQjSeN8cL8sNsu7idQ0721xJtWiQjSeNBV1cr1B1DKK2pDhwWXA4t27a1ewIZ9Z2BVdYKTv3AH2Q7a1ewIZ9ZoiaVrGN7akafzoR18sMrNiGre6kJxE8GxS(lKTbG0PRmEH64fX(1oss7NUdOx7NU9wRUT6oss7NUJjMnKWhqXDGAclX5(z7TMy3Q7a1ewIZ9ZoiaVrGN7ijTlcnOI0oY4fQJxelVqjVqbEHC6mW7iZHc5P40qNsNGrutyjo5Lhp4f2fiHDDgRKSgLPonqbhuGJTa8cf3rsA)0Dq7aWbyMZA6dqJAV9wJA2Q7a1ewIZ9ZoiaVrGN7GCNCEv0OteWicDLfbiD6kJxOcVeQoEHsEboWAJGafnN1a9QGG48QO7ijTF6oabkAoRb6vbbBV1O2T6oqnHL4C)SdcWBe45oGdS2iiqrZznqVkiioVk6oss7NUdNiGre6kB7TgvVv3bQjSeN7NDqaEJap3biqr7bEXyJ0qpqknvsa0iQjSeN8cL8cCG1grXdzgWA)0yauEHsEHc8cuakYCwR5LmJoraJi0vgV84bVy9xiBdaPtxz8c1XlI9lEHI7ijTF6oANgnvsa0T3AuLT6oss7NUJagA8gPz7a1ewIZ9Z2BTW(wDhjP9t3bS8UPXgaeyhOMWsCUF2ERf22Q7ijTF6oGradbHX13DGAclX5(z7TwOV2Q7ijTF6oK(lKnZ8nhmFPrT3bQjSeN7NT3AHcTv3rsA)0DyDaclVBUdutyjo3pBV1cv3wDhjP9t3rQeK1GuAiPuUdutyjo3pBV1cj2T6oss7NUd481CwtdCsyy7a1ewIZ9Z2BVdwVv3AH2Q7a1ewIZ9ZoiaVrGN7Gc8caPtxD91uX1gbmdbsxk5LFE5lE5XdEzIWbwBSIRncygcKUugNxfLxOiVqjVqbEbkafzEjZyOicFk8jBE5XdEboWAJWG0vJfGy4yeGjP5fk5fkWlqbOiZlzgdfFLjXtPHb1ddYlpEWlqbOiZlzgdfTGJ1WNS5Lhp4fOauK5LmJHIGC6P2gg0eegE5XdEboWAJwxFraZCwJfCSocWK08YpV8fVqjVqbEzIWbwBK2bGdWmN10hGg1ogaLxE8GxGdS2OfGy4U(AQ46KfdGYlpEWlWbwBefp0uN40a9AuBpLraMKMxOiVqrEHI7ijTF6oSYaaqGT3A1Tv3rsA)0Dybx4OAoa8oqnHL4C)S9wtSB1DGAclX5(zheG3iWZDahyTrlaXWD91asxJbq5Lhp4LK0Ui0Gks7iJxOYpVu3oss7NUdyPhE4jyU9wJA2Q7a1ewIZ9ZoiaVrGN7aG0PRU(AQ4AJaMHaPlL8YpVeIxOKxMiCG1gR4AJaMHaPlLrasNUY2rsA)0DasbmN1ybhR3ERrTB1DGAclX5(zheG3iWZDaq60vxFnvCTraZqG0LsEHsEzIWbwBSIRncygcKUugbiD6kJxOcVqswBANg5fi4LgKIqPPDAChjP9t3XRmjEknmOEyWT3Au9wDhOMWsCUF2bb4nc8ChaKoD11xtfxBeWmeiDPKxOKxaiD6QRVMkU2iGziq6sjVqfEboWAJwxFraZCwJfCSocWK08cL8YeHdS2yfxBeWmeiDPmcq60vgVqfEPbPiuAANg3rsA)0D4e0itLGBV1OkB1DKK2pDhKJgBdRpa9oqnHL4C)S9wlSVv3rsA)0D4e0ONOChOMWsCUF2ERf22Q7a1ewIZ9ZoiaVrGN7aoWAJwaIH76RPIRtwmakVqjVKK2fHgurAhz8YpVeAhjP9t3biNEQTHbnbHz7TwOV2Q7a1ewIZ9ZoiaVrGN7aoWAJwxFraZCwJfCSocWK08YJh8YeHdS2OfCHJAeG0PRmEHk8sdsrO00onUJK0(P7WjOrMkb3ERfk0wDhjP9t3bcFk8j7DGAclX5(z7TwO62Q7a1ewIZ9ZoiaVrGN7Gc8Y3eVacu0EGxmAbigURVMkUozrutyjo5Lhp4LK0Ui0Gks7iJxOYpVuhVqrEHsEboWAJWG0vJfGy4yeGjP3rsA)0DaYPNAByqtqy2ERfsSB1DKK2pDh0oaCaM5SM(a0O27a1ewIZ9Z2BTquZwDhOMWsCUF2bb4nc8ChWbwBeeOO5SgOxfeeNxfLxOKxOaVWUajSRZ4l4eHgxf5VhiB)uE5XdEHDbsyxNrRJYP5Sgy5XyhnJxE8Gxss7IqdQiTJmEHk)8sD8cf3rsA)0DWG0TTRVgOxfeS9wle1Uv3bQjSeN7NDqaEJap3biqr7bEX4lWzsbmoXjsmIAclXjVqjV0j4f7OefHsEH6(5fjkcL8cL8YeHdS2OfCHJACEv0DKK2pDhwWXAJEIYT3AHO6T6oqnHL4C)SdcWBe45oabkApWlgNoJ4qLUMabmKJMo1ze1ewItEHsEHCNCEv0iCG1AMoJ4qLUMabmKJMo1zeG5uaEHsEboWAJtNrCOsxtGagYrtN60KasQyCEv0DKK2pDhjGKkAqXdvEm)0T3AHOkB1DGAclX5(zheG3iWZDacu0EGxmoDgXHkDnbcyihnDQZiQjSeN8cL8c5o58QOr4aR1mDgXHkDnbcyihnDQZiaZPa8cL8cCG1gNoJ4qLUMabmKJMo1PX6amoVk6oss7NUdRdqdSmz92BTqH9T6oqnHL4C)SdcWBe45oGdS2imiD1ybigogbys6DKK2pDhVYK4P0WG6Hb3ERfkSTv3rsA)0DybhRHpzVdutyjo3pBV9oOprinQ9wDRfARUdutyjo3p7Ga8gbEUd6tesJAhNoRtLG8cv4LqFTJK0(P7aw6Ay2ERv3wDhOMWsCUF2bb4nc8ChWbwB0jOXkpKfNxfDhjP9t3HtqJvEiB7TMy3Q7a1ewIZ9ZoiaVrGN7Go1mcL08cv4fX(fVqjVKK2fHgurAhz8cv(5L62rsA)0DKasQObfpu5X8t3ERrnB1DKK2pDhwhGgyzY6DGAclX5(z7Tg1Uv3rsA)0D4e0itLG7a1ewIZ9Z2BV9oeHaMF6wRUVQ7RqHcrv2rLeOU(Y2b1pvvyznQxnQ6VZl8svirEXPHEGMxShGxempuqEbGuFboaN8c7OrEjd6JoBCYleit9fzrUqX0vKxc9135fX4uriOXjViiiqr7bEXO4eKx6JxeeeOO9aVyuCrutyjofKxOqiXtXixOy6kYlHc9DErmovecACYlcccu0EGxmkob5L(4fbbbkApWlgfxe1ewItb5fkes8umYfkMUI8siQ578IyCQie04KxeStjQDuCcYl9Xlc2Pe1okUiQjSeNcYluiK4PyKlumDf5LquZ35fX4uriOXjViiiqr7bEXO4eKx6JxeeeOO9aVyuCrutyjofKxOqiXtXixOy6kYlHO2VZlIXPIqqJtErWoLO2rXjiV0hViyNsu7O4IOMWsCkiVKnV8ncRlM8cfcjEkg5cftxrEje1(DErmovecACYlcccu0EGxmkob5L(4fbbbkApWlgfxe1ewItb5fkes8umYfYfs9tvfwwJ6vJQ(78cVufsKxCAOhO5f7b4fbjtMG8caP(cCao5f2rJ8sg0hD24KxiqM6lYICHIPRiVi2VZlIXPIqqJtErqYPZaVJItqEPpErqYPZaVJIlIAclXPG8cfcjEkg5cftxrEHQ)oVigNkcbno5fbbbkApWlgfNG8sF8IGGafTh4fJIlIAclXPG8cfcjEkg5c5cP(PQclRr9Qrv)DEHxQcjYlon0d08I9a8IGSwqEbGuFboaN8c7OrEjd6JoBCYleit9fzrUqX0vKxcv335fX4uriOXjViiiqr7bEXO4eKx6JxeeeOO9aVyuCrutyjofKxOqiXtXixOy6kYlHO2VZlIXPIqqJtErqqGI2d8IrXjiV0hViiiqr7bEXO4IOMWsCkiVqHqINIrUqX0vKxcr1FNxeJtfHGgN8IGGafTh4fJItqEPpErqqGI2d8IrXfrnHL4uqEHcHepfJCHIPRiVeIQ8DErmovecACYlcccu0EGxmkob5L(4fbbbkApWlgfxe1ewItb5fkes8umYfYfs9OHEGgN8cvHxss7NYlsN1Six4oyqrYwJQPMDafCwxI74B5LWI8f5LWkWXAUWVLxQDIqAyeWl1j265L6(QUV4c5c)wEH6XljnViXuKRV8Y3GXqLGmEXvEjqBxYlj4c0jVe6zON19vDFXlbQezmEHD0ydPRV8ckziVanGbjY4fAKx6JxMhV4DKlKl8B5LVH4rsqJtEbgTha5fYrdNnVaJVUYI8cvfHGqBgVONgwdYeqBdK8ssA)ugVCQuGixysA)uwekajhnC2q8)mbKurJRnkLiP5cts7NYIqbi5OHZgI)NSaA6tnvYgbguI0O2PKlmjTFklcfGKJgoBi(FAbhRHpzZfYf(T8Y3q8ijOXjVGIqGa8s70iV0qI8ss6dWloJxsrPltyjg5cts7NY(jxG2iGbfLsUWK0(Pmi(FssP0KK2p1iDwxVM04pzY4cts7NYG4)jjLstsA)uJ0zD9AsJ)iJHkbzCHjP9tzq8)KKsPjjTFQr6SUEnPX)8W6D7FsAxeAqfPDKrLFQHlmjTFkdI)NKuknjP9tnsN11Rjn(Z66D7FsAxeAqfPDKrDudxysA)uge)pjPuAss7NAKoRRxtA8N(eH0O2CHCHjP9tzX8WFl4chvZbG5cts7NYI5Hq8)ew6HhEcMCHjP9tzX8qi(FALbaGa172Fkaq60vxFnvCTraZqG0LY)VE8yIWbwBSIRncygcKUugNxfLIusbOauK5LmJHIi8PWNSF8aoWAJWG0vJfGy4yeGjPPeoWAJwxFraZCwJfCSocWK0)FrrUWK0(PSyEie)pDcA0tuYfMK2pLfZdH4)j5OX2W6dqZfMK2pLfZdH4)PtqJmvcwVB)HdS2O11xeWmN1ybhRJamj9JhteoWAJwWfoQrasNUYOsdsrO00on(4baPtxD91uX1gbmdbsxkPCIWbwBSIRncygcKUugbiD6kJknifHst70ixysA)uwmpeI)NGC6P2gg0eegUWK0(PSyEie)pPDa4amZzn9bOrT5cts7NYI5Hq8)KbPBBxFnqVkiGlmjTFklMhcX)tl4yTrprz9U9heOO9aVy8f4mPagN4ejszNGxSJsuekPUFjkcLuor4aRnAbx4OgNxfLlmjTFklMhcX)tRdqdSmzD9U9heOO9aVyC6mIdv6AceWqoA6uNusUtoVkAeoWAntNrCOsxtGagYrtN6mcWCkaLWbwBC6mIdv6AceWqoA6uNgRdW48QOCHjP9tzX8qi(FMasQObfpu5X8tR3T)0PMrOKMkI9lkts7IqdQiTJmQ8t1CHjP9tzX8qi(FIWNcFYMlmjTFklMhcX)tNGgzQeSE3(dcu0EGxm(ktINsJfKV0O2mk7uIAhzqLE3U(ACcszdsrO00onsDVGlqNM8WiS0dp8emJaKoDLXfMK2pLfZdH4)zL076zi5)RyO6D7piqr7bEX4RmjEknwq(sJAZOStjQDKbv6D76RXjixysA)uwmpeI)NwWXA4t2CHCHjP9tzrYK9d9A)06D7puakYCwR5LmJoraJi0v2Jhw)fY2aq60vg1j2V4cts7NYIKjdI)NtmBiHpGICHjP9tzrYKbX)tAhaoaZCwtFaAu76D7FsAxeAqfPDKrDILskqoDg4DK5qH8uCAOtPtWhpyxGe21zSsYAuM60afCqbo2cqrUWK0(PSizYG4)jiqrZznqVkiOE3(tUtoVkA0jcyeHUYIaKoDLrLq1rjCG1gbbkAoRb6vbbX5vr5cts7NYIKjdI)NoraJi0vw9U9hoWAJGafnN1a9QGG48QOCHjP9tzrYKbX)Z2PrtLeaTE3(dcu0EGxm2in0dKstLeaLs4aRnIIhYmG1(PXaOusbOauK5SwZlzgDIagrORShpS(lKTbG0PRmQtSFrrUWK0(PSizYG4)zadnEJ0mUWK0(PSizYG4)jS8UPXgaeGlmjTFklsMmi(FcJagccJRVCHjP9tzrYKbX)tP)czZmFZbZxAuBUWK0(PSizYG4)P1biS8UjxysA)uwKmzq8)mvcYAqknKuk5cts7NYIKjdI)NW5R5SMg4KWW4c5cts7NYIiJHkbz)Vbjy6PAoRjdhbxdjxysA)uwezmujidI)N2JeWWPjdhbEJgymP5cts7NYIiJHkbzq8)KgPpGaMZAKbeFAMamPzCHjP9tzrKXqLGmi(FclVBAoRPHenOI0cWfMK2pLfrgdvcYG4)j0aGBfW1xdSmznxysA)uwezmujidI)NahkujAC1WGMeKlmjTFklImgQeKbX)tYPeuBq240yLjnwV0v0qM)unxysA)uwezmujidI)NamH66RXktAKXfMK2pLfrgdvcYG4)zdjAcu4lqNg7biy9U9hoWAJaKegjYyg7biymakxysA)uwezmujidI)NvoGCkcD1aq2PPsqUWK0(PSiYyOsqge)pHetqBqgdvcYfYfMK2pLfPprinQ9pS01WysvG6D7p9jcPrTJtN1PsqQe6lUWK0(PSi9jcPrTH4)PtqJvEiRE3(dhyTrNGgR8qwCEvuUWK0(PSi9jcPrTH4)zciPIgu8qLhZpTE3(tNAgHsAQi2VOmjTlcnOI0oYOYFDCHjP9tzr6tesJAdX)tRdqdSmznxysA)uwK(eH0O2q8)0jOrMkb5c5cts7NYIS(3kdaabQ3T)uaG0PRU(AQ4AJaMHaPlL)F94XeHdS2yfxBeWmeiDPmoVkkfPKcqbOiZlzgdfr4tHpz)4bCG1gHbPRglaXWXiatstjfGcqrMxYmgk(ktINsddQhg8XdOauK5LmJHIwWXA4t2pEafGImVKzmueKtp12WGMGW84bCG1gTU(IaM5Sgl4yDeGjP))Iskmr4aRns7aWbyMZA6dqJAhdG(4bCG1gTaed31xtfxNSya0hpGdS2ikEOPoXPb61O2EkJamjnfPif5cts7NYISgI)NwWfoQMdaZfMK2pLfzne)pHLE4HNGz9U9hoWAJwaIH76RbKUgdG(4rsAxeAqfPDKrL)64cts7NYISgI)NGuaZznwWX66D7paPtxD91uX1gbmdbsxk)dr5eHdS2yfxBeWmeiDPmcq60vgxysA)uwK1q8)8vMepLggupmy9U9hG0PRU(AQ4AJaMHaPlLuor4aRnwX1gbmdbsxkJaKoDLrfsYAt70ienifHst70ixysA)uwK1q8)0jOrMkbR3T)aKoD11xtfxBeWmeiDPKsasNU66RPIRncygcKUusf4aRnAD9fbmZznwWX6iatst5eHdS2yfxBeWmeiDPmcq60vgvAqkcLM2PrUWK0(PSiRH4)j5OX2W6dqZfMK2pLfzne)pDcA0tuYfMK2pLfzne)pb50tTnmOjim172F4aRnAbigURVMkUozXaOuMK2fHgurAhz)H4cts7NYISgI)NobnYujy9U9hoWAJwxFraZCwJfCSocWK0pEmr4aRnAbx4OgbiD6kJknifHst70ixysA)uwK1q8)eHpf(KnxysA)uwK1q8)eKtp12WGMGWuVB)PW3eiqr7bEXOfGy4U(AQ46K94rsAxeAqfPDKrL)6OiLWbwBegKUASaedhJamjnxysA)uwK1q8)K2bGdWmN10hGg1MlmjTFklYAi(FYG0TTRVgOxfeuVB)HdS2iiqrZznqVkiioVkkLuGDbsyxNXxWjcnUkYFpq2(PpEWUajSRZO1r50CwdS8ySJM94rsAxeAqfPDKrL)6OixysA)uwK1q8)0cowB0tuwVB)bbkApWlgFbotkGXjorIu2j4f7OefHsQ7xIIqjLteoWAJwWfoQX5vr5cts7NYISgI)NjGKkAqXdvEm)06D7piqr7bEX40zehQ01eiGHC00PoPKCNCEv0iCG1AMoJ4qLUMabmKJMo1zeG5uakHdS240zehQ01eiGHC00PonjGKkgNxfLlmjTFklYAi(FADaAGLjRR3T)GafTh4fJtNrCOsxtGagYrtN6KsYDY5vrJWbwRz6mIdv6AceWqoA6uNraMtbOeoWAJtNrCOsxtGagYrtN60yDagNxfLlmjTFklYAi(F(ktINsddQhgSE3(dhyTryq6QXcqmCmcWK0CHjP9tzrwdX)tl4yn8j7T3Exa]] )


end
