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
    
    spec:RegisterPack( "Frost Mage", 20210117, [[dG0jWaqiKs0JevbBsv4tsvgLOItjk1RqIMLuvDluLiTls(fOQHPkPJrrTmPQ8mKsnnuL01evrBtuI(MOQQXjQQ4COkH1jkP5Hus3du2hOIdIucwis4HIQYfrkH2iQsuFuuc1jfvvALOQMPOkDtrvi7uvQFIQeXsfLqEQQAQQI(QOeySQsSxG)kYGj1HLSyqEmktwkxgAZu6ZsLrJuCAHvlQc1RrvQzt42OYUP63QmCK0XfLGwUspNOPR46uy7ivFNImEqLopQI1lQ08ff7hXaZGNGFRge8UVx7Z8RMnN)Qx5f8AF0g8hEOIGp1IX7QdbFV4qWNxEp5q05rvhc(ulEex1apbF5zSme8PzgQYScp8DXqJbKIDCWldodrnX5STSd8YGJbp4dzeIj)6aiWVvdcE33R9z(vZMZF1R8cETV(YpGFzm0Cl4)dU8b(0eTg6aiWVHsg4Nhi68OQdjAE59KdHFEGO5xUrT8q0MZ)(j6(ETpZGViKJe8e8BOTmed4j4TzWtWVytCo4ZodFWvsffcWh9csGnafGb8UpWtWh9csGnafGFXM4CWNvcrQytCEseYb8fHCsEXHGpRjbd4nTbpbF0lib2aua(fBIZbFwjePInX5jrihWxeYj5fhc(OuIodLGb8MxbpbF0lib2aua(SngCJc8l2e0Xe6ixGsIgoWiAAd(fBIZbFwjePInX5jrihWxeYj5fhc(1HGb8opbpbF0lib2aua(SngCJc8l2e0Xe6ixGsIMwjAAd(fBIZbFwjePInX5jrihWxeYj5fhc(YbmG3zj4j4JEbjWgGcWVytCo4ZkHivSjopjc5a(IqojV4qWN7OJCOpGbmGp1fzhhunGNG3Mbpb)InX5GFTSYXu4dkeiBaF0lib2auagW7(apb)InX5GVPAWnHcKd9PeGp6fKaBakad4nTbpb)InX5GVDp5aDIb8rVGeydqbyad4xhcEcEBg8e8l2eNd(29Yf90TqGp6fKaBakad4DFGNGFXM4CWhse5MBTnWh9csGnafGb8M2GNGp6fKaBakaF2gdUrb(5q0lYvHhExYu4dUYeJMqiiAye9ReDMmeDdHmSwLPWhCLjgnHqOANjNOZMOFq05q0uxKEQJ1uMvi05qNyi6mziAidRvbTv4j7IyUOAXIne9dIgYWAv2W7WvMoBYUNCulwSHOHr0Vs0zd(fBIZbFRWyxEad4nVcEc(fBIZb)GHj)OxGp6fKaBakad4DEcEc(fBIZbF2XHtso3Yb(OxqcSbOamG3zj4j4JEbjWgGcWNTXGBuGpKH1QSH3HRmD2KDp5OwSydrNjdr3qidRvz3lx0vlYvHljA4q0Zw0rrAcoKOZKHOxKRcp8UKPWhCLjgnHqq0pi6gczyTktHp4ktmAcHqTixfUKOHdrpBrhfPj4qWVytCo4hmmjkNHGb8o)bpb)InX5G)wTO8jjPwlVbF0lib2auagW78d4j4xSjoh85IDVvMoBAULd9b8rVGeydqbyaV5fGNGFXM4CWxstyNW7supt4c(OxqcSbOamG3MFf8e8rVGeydqb4Z2yWnkWFnC0EBhQ62qk4jfSGjqf6fKaBe9dIEQTdhLaPJcIMwHr0cKoki6heDdHmSwLDVCrx1oto4xSjoh8T7jNKF0lWaEB2m4j4JEbjWgGcWNTXGBuG)A4O92ou1cjlOkcVwEsSJJR8Mc9csGnI(brZUt0otUcYWAtTqYcQIWRLNe744kVPwSA8q0piAidRv1cjlOkcVwEsSJJR8wYglQANjh8l2eNd(2yXeKOKdyaVn3h4j4JEbjWgGcWNTXGBuGpx5LIkBiA4q00(vI(brxSjOJj0rUaLenCGr0zjr)GOPLe9A4O92ou1jkwuIKDRoo0hPc9csGnWVytCo4xlRCmHWLQ4KX5Gb82mTbpb)InX5GpcDo0jgWh9csGnafGb82mVcEc(OxqcSbOa8zBm4gf4VgoAVTdvDIIfLiz3QJd9rQqVGeyJOFq0tjqFusQIyMW7sbdvOxqcSr0pi6zl6Oinbhs00kr3TNH3s1HkirKBU12ulYvHlb)InX5GFWWKOCgcgWBZ5j4j4JEbjWgGcWxImW)vLzWVytCo4BQIb8zBm4gf4VgoAVTdvDIIfLiz3QJd9rQqVGeyJOFq0tjqFusQIyMW7sbdvOxqcSbgWBZzj4j4xSjoh8T7jhOtmGp6fKaBakadyaFwtcEcEBg8e8rVGeydqb4Z2yWnkWN6I0tN1M6ynvW4jrhdxs0zYq02OJMjTixfUKOPvIM2Vc(fBIZbFQ3eNdgW7(apb)InX5GFdRHgOBDe8rVGeydqbyaVPn4j4JEbjWgGcWNTXGBuGFXMGoMqh5cus00krtBI(brNdrZoVzeJsguP5CSL4krWqf6fKaBeDMmeT8meqH3uMk5GIYBjQ7rDdC4rHEbjWgrNn4xSjoh85IDVvMoBAULd9bmG38k4j4JEbjWgGcWNTXGBuGp7or7m5QGXtIogUuTixfUKOHdrBUpI(brdzyTQ1WX0ztupt4QANjh8l2eNd(RHJPZMOEMWfmG35j4j4JEbjWgGcWNTXGBuGpKH1QwdhtNnr9mHRQDMCI(brNdrdzyTQGXtIogUu1otorNjdrpLa9rTgoMoBI6zcxf6fKaBeD2e9dIohIgYWAvsrW4DkyOQDMCIotgIUytqhtOJCbkjA4aJO7JOZg8l2eNd(bJNeDmCjyaVZsWtWh9csGnafGpBJb3Oa)1Wr7TDOAqoQ3wIKPAPQqVGeyJOFq0qgwRcHlnLHCIZvguj6heDoen1fPNoRn1XAQGXtIogUKOZKHOTrhntArUkCjrtRenTFLOZg8l2eNd(tWHjt1sfmG35p4j4xSjoh8nKykgKtc(OxqcSbOamG35hWtWVytCo4djURLSglpGp6fKaBakad4nVa8e8l2eNd(q4kXL3H3b(OxqcSbOamG3MFf8e8l2eNd(IOJMrMYJnADCOpGp6fKaBakad4TzZGNGFXM4CW3glcjURb(OxqcSbOamG3M7d8e8l2eNd(LZq5SLiXkHa8rVGeydqbyaVntBWtWVytCo4dvDPZMMny8wc(OxqcSbOamGb8Ld4j4TzWtWh9csGnafGpBJb3Oa)Ci6f5QWdVlzk8bxzIrtieenmI(vIotgIUHqgwRYu4dUYeJMqiuTZKt0zt0pi6CiAQlsp1XAkZke6COtmeDMmenKH1QG2k8KDrmxuTyXgI(brNdrtDr6Powtzw1jkwuIKKAWBKOZKHOPUi9uhRPmRS7jhOtme9dIohIMws0SZBgXOIftNnn0GPsYqVHnf6fKaBeDMmen7or7m5QTAr5tssTwERwKRcxs0zYq0RHJ2B7qLDrm3W7sMcVjvOxqcSr0zt0zYq0uxKEQJ1uMvB1IYNKKAT8MOZKHOHmSwLn8oCLPZMS7jh1IfBiAye9Re9dIohIUHqgwRIl29wz6SP5wo0hLbvIotgIgYWAv2fXCdVlzk8MuzqLOZKHOHmSwfcxQL3WwI6nOprjulwSHOZMOZMOZg8l2eNd(wHXU8agW7(apb)InX5GVDVCrpDle4JEbjWgGcWaEtBWtWh9csGnafGpBJb3OaFidRvzxeZn8U0wHRmOs0piAAjrlXzcVtQIo)wmzxeZn8U0wHNKdrNjdrxSjOJj0rUaLenCGr09r0zYq0RHJ2B7qvNOyrjs2T64qFKk0lib2i6he9ICv4H3Lmf(GRmXOjecIggr3h4xSjoh8HerU5wBdmG38k4j4JEbjWgGcWNTXGBuG)ICv4H3Lmf(GRmXOjecIggrBMOFq0neYWAvMcFWvMy0ecHArUkCj4xSjoh83IN0zt29KdyaVZtWtWh9csGnafGpBJb3Oa)f5QWdVlzk8bxzIrtiee9dIUHqgwRYu4dUYeJMqiulYvHljA4q0SsoPj4qIMsIE2IokstWHGFXM4CWVtuSOejj1G3iyaVZsWtWh9csGnafGpBJb3Oa)f5QWdVlzk8bxzIrtiee9dIErUk8W7sMcFWvMy0ecbrdhIgYWAv2W7WvMoBYUNCulwSHOFq0neYWAvMcFWvMy0ecHArUkCjrdhIE2IokstWHGFXM4CWpyysuodbd4D(dEc(fBIZbF2XHtso3Yb(OxqcSbOamG35hWtWVytCo4hmm5h9c8rVGeydqbyaV5fGNGp6fKaBakaF2gdUrb(qgwRYUiMB4DjtH3KkdQe9dIUytqhtOJCbkjAyeTzWVytCo4VvlkFssQ1YBWaEB(vWtWh9csGnafGpBJb3OaFidRvzdVdxz6Sj7EYrTyXgIotgIUHqgwRYUxUORwKRcxs0WHONTOJI0eCi4xSjoh8dgMeLZqWaEB2m4j4xSjoh8rOZHoXa(OxqcSbOamG3M7d8e8rVGeydqb4Z2yWnkWphIMws0RHJ2B7qLDrm3W7sMcVjvOxqcSr0zYq0fBc6ycDKlqjrdhyeDFeD2e9dIgYWAvqBfEYUiMlQwSyd4xSjoh83QfLpjj1A5nyaVntBWtWVytCo4Zf7ERmD20Clh6d4JEbjWgGcWaEBMxbpbF0lib2aua(SngCJc8HmSw1A4y6SjQNjCvTZKt0pi6CiA5ziGcVP62JoMcNE0DBnX5k0lib2i6mziA5ziGcVPSbkAPZMGeNuECsf6fKaBeDMmeDXMGoMqh5cus0Wbgr3hrNn4xSjoh8L0e2j8Ue1ZeUGb82CEcEc(OxqcSbOa8zBm4gf4VgoAVTdvDBif8KcwWeOc9csGnI(brp12HJsG0rbrtRWiAbshfe9dIUHqgwRYUxUORANjh8l2eNd(29KtYp6fyaVnNLGNGp6fKaBakaF2gdUrb(RHJ2B7qvlKSGQi8A5jXooUYBk0lib2i6hen7or7m5kidRn1cjlOkcVwEsSJJR8MAXQXdr)GOHmSwvlKSGQi8A5jXooUYBPAzLJQ2zYb)InX5GFTSYXecxQItgNdgWBZ5p4j4JEbjWgGcWNTXGBuG)A4O92ou1cjlOkcVwEsSJJR8Mc9csGnI(brZUt0otUcYWAtTqYcQIWRLNe744kVPwSA8q0piAidRv1cjlOkcVwEsSJJR8wYglQANjh8l2eNd(2yXeKOKdyaVnNFapbF0lib2aua(SngCJc8HmSwf0wHNSlI5IQfl2a(fBIZb)orXIsKKudEJGb82mVa8e8l2eNd(29Kd0jgWh9csGnafGbmGp3rh5qFapbVndEc(OxqcSbOa8zBm4gf4ZD0ro0hvlKt5mKOHdrB(vWVytCo4djcN3Gb8UpWtWh9csGnafGpBJb3OaFidRvfmmzfhkvTZKd(fBIZb)GHjR4qjyaVPn4j4JEbjWgGcWNTXGBuGpx5LIkBiA4q00(vI(brxSjOJj0rUaLenCGr09b(fBIZb)AzLJjeUufNmohmG38k4j4xSjoh8TXIjirjhWh9csGnafGb8opbpb)InX5GFWWKOCgc(OxqcSbOamGbmGpDCLX5G399AFMF18R8cW3uTE4DsWplGwil6D(9DwCwjAI(jnirhCuVDiA7TeDV6WEe9IzHgXInIwECirxgZXvd2iAgnL3HsfHFEdhjAZVMvIoFNth3bBeDV1Wr7TDO6LEe9CeDV1Wr7TDO6ff6fKaB9i6Cmd3Sve(5nCKOnBoReD(oNoUd2i6ERHJ2B7q1l9i65i6ERHJ2B7q1lk0lib26r05ygUzRi8ZB4irBUVSs057C64oyJO7TgoAVTdvV0JONJO7TgoAVTdvVOqVGeyRhrxdrtlYljVeDoMHB2kc)8gos0M51Ss057C64oyJO7nLa9r9spIEoIU3uc0h1lk0lib26r05ygUzRi8ZB4irBMxZkrNVZPJ7GnIU3A4O92ou9spIEoIU3A4O92ou9Ic9csGTEeDoMHB2kc)8gos0MZZSs057C64oyJO7nLa9r9spIEoIU3uc0h1lk0lib26r01q00I8sYlrNJz4MTIWpVHJeT58mReD(oNoUd2i6ERHJ2B7q1l9i65i6ERHJ2B7q1lk0lib26r05ygUzRi8j8ZcOfYIENFFNfNvIMOFsds0bh1BhI2Elr3J1K9i6fZcnIfBeT84qIUmMJRgSr0mAkVdLkc)8gos00oReD(oNoUd2i6ESZBgXOEPhrphr3JDEZig1lk0lib26r05ygUzRi8ZB4irt7Ss057C64oyJO7jpdbu4n1l9i65i6EYZqafEt9Ic9csGTEeDoMHB2kc)8gos05zwj68DoDChSr09MsG(OEPhrphr3Bkb6J6ff6fKaB9i6Cmd3Sve(5nCKOZYSs057C64oyJO7TgoAVTdvV0JONJO7TgoAVTdvVOqVGeyRhrNJz4MTIWNWplGwil6D(9DwCwjAI(jnirhCuVDiA7TeDp50JOxml0iwSr0YJdj6YyoUAWgrZOP8ouQi8ZB4irBoReD(oNoUd2i6ERHJ2B7q1l9i65i6ERHJ2B7q1lk0lib26r05ygUzRi8ZB4irBoReD(oNoUd2i6ESZBgXOEPhrphr3JDEZig1lk0lib26r05ygUzRi8ZB4irt7Ss057C64oyJO7TgoAVTdvV0JONJO7TgoAVTdvVOqVGeyRhrNJz4MTIWpVHJeT5(YkrNVZPJ7GnIU3A4O92ou9spIEoIU3A4O92ou9Ic9csGTEeDoMHB2kc)8gos0M51Ss057C64oyJO7jpdbu4n1l9i65i6EYZqafEt9Ic9csGTEeDo9b3Sve(5nCKOnNNzLOZ350XDWgr3BnC0EBhQEPhrphr3BnC0EBhQErHEbjWwpIohZWnBfHFEdhjAZzzwj68DoDChSr09wdhT32HQx6r0Zr09wdhT32HQxuOxqcS1JOZXmCZwr4N3WrI2C(NvIoFNth3bBeDV1Wr7TDO6LEe9CeDV1Wr7TDO6ff6fKaB9i6Cmd3Sve(e(5xoQ3oyJOZsIUytCorlc5ive(Gp19SHab)8arNhvDirZlVNCi8Zden)YnQLhI2C(3pr33R9zMWNWppq00IWfzgd2iAi0Els0SJdQgIgc7cxQiAAbgdPosI2pNxkn1YzneeDXM4CjrFUGhfHFXM4CPI6ISJdQgkHbFTSYXu4dkeiBi8l2eNlvuxKDCq1qjm4LgCCNNmvdUjuGCOpLGWVytCUurDr2XbvdLWG3UNCGoXq4t4NhiAAr4ImJbBenshxEi6j4qIEObj6In3s0HKOl6vikibQi8l2eNlHXodFWvsffcc)InX5skHbpReIuXM48KiKt)EXHWynjHFXM4CjLWGNvcrQytCEseYPFV4qyOuIodLe(fBIZLucdEwjePInX5jriN(9IdHvh2FyHvSjOJj0rUaLWbgTj8l2eNlPeg8SsisfBIZtIqo97fhcto9hwyfBc6ycDKlqjTsBc)InX5skHbpReIuXM48KiKt)EXHW4o6ih6dHpHFXM4CPQoeMDVCrpDleHFXM4CPQoKsyWdjICZT2gHFXM4CPQoKsyWBfg7Yt)HfwolYvHhExYu4dUYeJMqiG9AMmneYWAvMcFWvMy0ecHQDM8SFKd1fPN6ynLzfcDo0jMmzGmSwf0wHNSlI5IQfl28aYWAv2W7WvMoBYUNCulwSb2Rzt4xSjoxQQdPeg8bdt(rVi8l2eNlv1HucdE2XHtso3Yr4xSjoxQQdPeg8bdtIYzy)HfgKH1QSH3HRmD2KDp5OwSytMmneYWAv29YfD1ICv4s4mBrhfPj4WmzwKRcp8UKPWhCLjgnHq8OHqgwRYu4dUYeJMqiulYvHlHZSfDuKMGdj8l2eNlv1Hucd(TAr5tssTwEt4xSjoxQQdPeg8CXU3ktNnn3YH(q4xSjoxQQdPeg8sAc7eExI6zcxc)InX5svDiLWG3UNCs(rV6pSWwdhT32HQUnKcEsblyc8XuBhokbshf0kmbshfpAiKH1QS7Ll6Q2zYj8l2eNlv1HucdEBSycsuYP)WcBnC0EBhQAHKfufHxlpj2XXvE7b7or7m5kidRn1cjlOkcVwEsSJJR8MAXQXZdidRv1cjlOkcVwEsSJJR8wYglQANjNWVytCUuvhsjm4RLvoMq4svCY48(dlmUYlfv2ahA)6JInbDmHoYfOeoWYYh0Y1Wr7TDOQtuSOej7wDCOpsc)InX5svDiLWGhHoh6edHFXM4CPQoKsyWhmmjkNH9hwyRHJ2B7qvNOyrjs2T64qFKpMsG(OKufXmH3Lcg(y2IokstWH0A3EgElvhQGerU5wBtTixfUKWVytCUuvhsjm4nvX0VezWEvzU)WcBnC0EBhQ6eflkrYUvhh6J8Xuc0hLKQiMj8UuWqc)InX5svDiLWG3UNCGoXq4t4xSjoxQynjmQ3eN3FyHrDr6PZAtDSMky8KOJHlZKXgD0mPf5QWL0kTFLWVytCUuXAskHbFdRHgOBDKWVytCUuXAskHbpxS7TY0ztZTCOp9hwyfBc6ycDKlqjTs7h5WoVzeJsguP5CSL4krWWmzKNHak8MYujhuuElrDpQBGdpzt4xSjoxQynjLWGFnCmD2e1ZeU9hwyS7eTZKRcgpj6y4s1ICv4s4yUVhqgwRAnCmD2e1ZeUQ2zYj8l2eNlvSMKsyWhmEs0XWL9hwyqgwRAnCmD2e1ZeUQ2zYFKdKH1Qcgpj6y4sv7m5zYmLa9rTgoMoBI6zc3SFKdKH1QKIGX7uWqv7m5zYuSjOJj0rUaLWbwFzt4xSjoxQynjLWGFcomzQwQ9hwyRHJ2B7q1GCuVTejt1s9bKH1Qq4stziN4CLb1h5qDr6PZAtDSMky8KOJHlZKXgD0mPf5QWL0kTFnBc)InX5sfRjPeg8gsmfdYjj8l2eNlvSMKsyWdjURLSglpe(fBIZLkwtsjm4HWvIlVdVJWVytCUuXAskHbVi6OzKP8yJwhh6dHFXM4CPI1KucdEBSiK4UgHFXM4CPI1Kucd(YzOC2sKyLqq4xSjoxQynjLWGhQ6sNnnBW4TKWNWVytCUuXD0ro0hyqIW5DQCE6pSW4o6ih6JQfYPCgchZVs4xSjoxQ4o6ih6dLWGpyyYkou2FyHbzyTQGHjR4qPQDMCc)InX5sf3rh5qFOeg81YkhtiCPkozCE)Hfgx5LIkBGdTF9rXMGoMqh5cuchy9r4xSjoxQ4o6ih6dLWG3glMGeLCi8l2eNlvChDKd9HsyWhmmjkNHe(e(fBIZLk5aZkm2LN(dlSCwKRcp8UKPWhCLjgnHqa71mzAiKH1Qmf(GRmXOjecv7m5z)ihQlsp1XAkZke6COtmzYazyTkOTcpzxeZfvlwS5rouxKEQJ1uMvDIIfLijPg8gZKH6I0tDSMYSYUNCGoX8ihAj78MrmQyX0ztdnyQKm0Byltg2DI2zYvB1IYNKKAT8wTixfUmtM1Wr7TDOYUiMB4DjtH3KzNjd1fPN6ynLz1wTO8jjPwlVZKbYWAv2W7WvMoBYUNCulwSb2RpYPHqgwRIl29wz6SP5wo0hLb1mzGmSwLDrm3W7sMcVjvguZKbYWAviCPwEdBjQ3G(eLqTyXMSZoBc)InX5sLCOeg829Yf90Tqe(fBIZLk5qjm4HerU5wBR)WcdYWAv2fXCdVlTv4kdQpOLsCMW7KQOZVft2fXCdVlTv4j5KjtXMGoMqh5cuchy9LjZA4O92ou1jkwuIKDRoo0h5Jf5QWdVlzk8bxzIrtieW6JWVytCUujhkHb)w8KoBYUNC6pSWwKRcp8UKPWhCLjgnHqaZ8JgczyTktHp4ktmAcHqTixfUKWVytCUujhkHbFNOyrjssQbVX(dlSf5QWdVlzk8bxzIrtiepAiKH1Qmf(GRmXOjec1ICv4s4Wk5KMGdPC2IokstWHe(fBIZLk5qjm4dgMeLZW(dlSf5QWdVlzk8bxzIrtiepwKRcp8UKPWhCLjgnHqahidRvzdVdxz6Sj7EYrTyXMhneYWAvMcFWvMy0ecHArUkCjCMTOJI0eCiHFXM4CPsoucdE2XHtso3Yr4xSjoxQKdLWGpyyYp6fHFXM4CPsoucd(TAr5tssTwE3FyHbzyTk7IyUH3LmfEtQmO(OytqhtOJCbkHzMWVytCUujhkHbFWWKOCg2FyHbzyTkB4D4ktNnz3toQfl2KjtdHmSwLDVCrxTixfUeoZw0rrAcoKWVytCUujhkHbpcDo0jgc)InX5sLCOeg8B1IYNKKAT8U)WclhA5A4O92ouzxeZn8UKPWBYmzk2e0Xe6ixGs4aRVSFazyTkOTcpzxeZfvlwSHWVytCUujhkHbpxS7TY0ztZTCOpe(fBIZLk5qjm4L0e2j8Ue1ZeU9hwyqgwRAnCmD2e1ZeUQ2zYFKJ8meqH3uD7rhtHtp6UTM48mzKNHak8MYgOOLoBcsCs5XjZKPytqhtOJCbkHdS(YMWVytCUujhkHbVDp5K8JE1FyHTgoAVTdvDBif8KcwWe4JP2oCucKokOvycKokE0qidRvz3lx0vTZKt4xSjoxQKdLWGVww5ycHlvXjJZ7pSWwdhT32HQwizbvr41YtIDCCL3EWUt0otUcYWAtTqYcQIWRLNe744kVPwSA88aYWAvTqYcQIWRLNe744kVLQLvoQANjNWVytCUujhkHbVnwmbjk50FyHTgoAVTdvTqYcQIWRLNe744kV9GDNODMCfKH1MAHKfufHxlpj2XXvEtTy145bKH1QAHKfufHxlpj2XXvElzJfvTZKt4xSjoxQKdLWGVtuSOejj1G3y)HfgKH1QG2k8KDrmxuTyXgc)InX5sLCOeg829Kd0jgWxsfzG3zjVcgWaaa]] )


end
