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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

            interrupt = true,
            toggle = function ()
                if runeforge.disciplinary_command.enabled then return end
                return "interrupts"
            end,

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = function ()
                if runeforge.disciplinary_command.enabled then return end
                return "casting"
            end,
            readyTime = function ()
                if runeforge.disciplinary_command.enabled then return end
                return state.timeToInterrupt()
            end,

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
            
            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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
    
    spec:RegisterPack( "Frost Mage", 20210307, [[dOeXZaqiKuPhHOKnPk6tsfJse6uIuEfsvZsQu3sQK0Ui1VqknmKuoMizzQcEgsLMgfPCnkIABIG8nrqnoeLsNJIiSoksMhsQ6EiX(quCqkI0crkEOujMifPIlkvsSrkIOpIKk6KuKQwjHAMIa3uQKANQs9tksLgkIsrlfjv4PQQPQk5RikvgRQq7f0Ff1Gr1HLSyeEmktwkxgAZu6ZsvJgr1PPA1ikfEnfHztYTjy3c)wPHJihhrPQLRYZjA6kUof2oH8DkQXJuX5rswVivZxeTFGHPGVG)wni89du7HuuJUulH1p8GjNWM8dW)qfje(jvmtu9i8hLac)MK3khaVRREe(jvuP2QbFb)Y14yi8t(mKKMIwA79HCdcnBfOv6cgQA8nyxzhALUaJw4NWWvJPpGeWFRge((bQ9qkQrxQLW6hEWKtytJUWFzmKVh8)DHUa)K7Tggqc4VHsg831vpc4MK3khG4UUog5aEc3nG)a1EifqmqCxiVIEuAkG4UkGB6SrNbW9GPmAiGtJYdta4Ea4D9kcfWyaCtkzZea4jsAL(4B4rpG7saVaCsQIk8a8gYCPVrAaXDvaVRltGaUCfqaVJ17jFYhkuEi7a4ymNJsaVirsrfGplGtSsjGB9EYhjGVHIkn8RC5iHVG)gAld1aFbFNc(c(XOiuydsd8ZoFWZl4N6c4NrG296rDZLmNKYJ6OkZwbHkAAmkcf2a8NaEdjmSwnRKJh9Adsa(taVHegwRMvYXJE9HcLhsaN6b8uaEYKaoBxvBnhAcdRn3CjZjP8OoQYSvqOIM(WQrfG)eWjmSwDZLmNKYJ6OkZwbHkA56yvG62AoG)In(gWpBnIbpjjuPGd89dWxWpgfHcBqAG)In(gWpRuQCXgFJSYLd8RC5KJsaHFwtch4B6cFb)yuekSbPb(l24Ba)SsPYfB8nYkxoWVYLtokbe(rPedgkHd8TPbFb)yuekSbPb(zNp45f8xSXfHzmqbhLaozOa40f(l24Ba)SsPYfB8nYkxoWVYLtokbe(RfHd8TjdFb)yuekSbPb(zNp45f8xSXfHzmqbhLao1d40f(l24Ba)SsPYfB8nYkxoWVYLtokbe(LdCGVti4l4hJIqHninWFXgFd4NvkvUyJVrw5Yb(vUCYrjGWVWkcfWyGdCGFshYwbIAGVGVtbFb)fB8nG)6yvGzpguPq2a)yuekSbPboW3paFb)fB8nGFZ1GxgvOagtPGFmkcf2G0ah4B6cFb)yuekSbPb(zNp45f8xSXfHzmqbhLaozOa4pa)fB8nGFcLNE611Gd8TPbFb)yuekSbPb(zNp45f8xSXfHzmqbhLaofapf8xSX3a(T3khIvnWboWFTi8f8Dk4l4VyJVb8BVnDmY7ra)yuekSbPboW3paFb)fB8nGFcLNE611GFmkcf2G0ah4B6cFb)yuekSbPb(zNp45f8NiGFOq5Hh9zZEm4jZmYDLcWPa4udWtMeWBiHH1Qn7XGNmZi3vkDBnhaEAa(tapraN0HIY9SMoLgj2GyvdGNmjGtyyTAIR8iBpeth1hwSbWFc4egwR26rpEY8AZ2BLJ(WInaofaNAaEAWFXgFd43QmUJk4aFBAWxWFXgFd43zyowrf8JrrOWgKg4aFBYWxWFXgFd4NTc4KLZEcWpgfHcBqAGd8DcbFb)yuekSbPb(zNp45f8tyyTARh94jZRnBVvo6dl2a4jtc4nKWWA12Bthd9HcLhsaNma(CLiuLhxab8Kjb8dfkp8OpB2JbpzMrURua(taVHegwR2ShdEYmJCxP0hkuEibCYa4ZvIqvECbe(l24Ba)odZQkyiCGVty4l4hJIqHninWp78bpVGF5AOi8OPzRarnzbS5tn(gAmkcf2G)In(gW)vnVIjljvNjGd8nzl8f8xSX3a(f872tMxBE2taJb(XOiuydsdCGVnjGVG)In(gWVKC3oE0NjTMXd(XOiuydsdCGVtrn4l4hJIqHninWp78bpVG)Ziq7E9OU)CPIQSZCMc1yuekSb4pb8PUEC0kueQaCQNcGRqrOcWFc4nKWWA12BthdDBnhWFXgFd43ERCYXkQGd8DQuWxWpgfHcBqAGF25dEEb)NrG296rDZLmNKYJ6OkZwbHkAAmkcf2a8NaoBxvBnhAcdRn3CjZjP8OoQYSvqOIM(WQrfG)eWjmSwDZLmNKYJ6OkZwbHkAzRFOUTMd4VyJVb8B9dZeQsoWb(o1dWxWpgfHcBqAGF25dEEb)cvuAsSbWjdGtxQb4pb8InUimJbk4OeWjdfapHa8Nao1fWpJaT71J6EvX8sLTx1lGXi1yuekSb)fB8nG)6yvGzKoKuR03aoW3POl8f8xSX3a(rIniw1a)yuekSbPboW3Pmn4l4hJIqHninWp78bpVG)Ziq7E9OUxvmVuz7v9cymsngfHcBa(taFkfgJwss5Z4rF2zOgJIqHna)jGpxjcv5XfqaN6b8(BnIwUwutO80tVUM(qHYdj8xSX3a(DgMvvWq4aFNYKHVGFmkcf2G0a)sKb)utNc(l24Ba)MlFGF25dEEb)NrG296rDVQyEPY2R6fWyKAmkcf2a8Na(ukmgTKKYNXJ(SZqngfHcBWb(ovcbFb)fB8nGF7TYHyvd8JrrOWgKg4ah4N1KWxW3PGVGFmkcf2G0a)SZh88c(jDOO8AT5Ewt7mQYIqpKaEYKaoXkLa(ta369Kp5dfkpKao1d40LAWFXgFd4N0o(gWb((b4l4VyJVb83WAiNyVaHFmkcf2G0ah4B6cFb)yuekSbPb(zNp45f8xSXfHzmqbhLao1d40fWFc4jc4SnAg(OLojY3aBzHs5muJrrOWgGNmjGlxdfHhnT5soOQIwM0TKohhQ0yuekSb4Pb)fB8nGFb)U9K51MN9eWyGd8TPbFb)yuekSbPb(zNp45f8Z2v1wZH2zuLfHEi1hkuEibCYa4PEaWFc4egwR(mcmV2mP1mE62AoG)In(gW)zeyETzsRz8Gd8TjdFb)yuekSbPb(zNp45f8tyyT6ZiW8AZKwZ4PBR5aWFc4jc4egwR2zuLfHEi1T1Ca4jtc4tPWy0NrG51MjTMXtJrrOWgGNgG)eWteWjmSwTu5mtKDgQBR5aWtMeWl24IWmgOGJsaNmua8ha80G)In(gWVZOklc9qch47ec(c(XOiuydsd8ZoFWZl4)mc0UxpQhuG0ELkBUosAmkcf2a8NaoHH1Qr6qEzihFdTbja)jGNiGt6qr51AZ9SM2zuLfHEib8KjbCIvkb8NaU17jFYhkuEibCQhWPl1a80G)In(gW)4cy2CDKGd8DcdFb)fB8nGFdjM9bfKWpgfHcBqAGd8nzl8f8xSX3a(ju72YwJJk4hJIqHninWb(2Ka(c(l24Ba)e4jXZeE0d)yuekSbPboW3POg8f8xSX3a(vEp5Jmt2WO1lGXa)yuekSbPboW3PsbFb)fB8nGFRFiHA3g8JrrOWgKg4aFN6b4l4VyJVb8xbdLZvQmRuk4hJIqHninWb(ofDHVG)In(gWpr1NxBEoNzcj8JrrOWgKg4ah4xoWxW3PGVGFmkcf2G0a)SZh88c(teWpuO8WJ(Szpg8Kzg5Usb4uaCQb4jtc4nKWWA1M9yWtMzK7kLUTMdapna)jGNiGt6qr5EwtNsJeBqSQbWtMeWjmSwnXvEKThIPJ6dl2a4pb8ebCshkk3ZA6u6EvX8sLLKCtGaEYKaoPdfL7znDkT9w5qSQbWFc4jc4uxaNTrZWhTFyET5HCmxsggnSPXOiuydWtMeWz7QAR5qFvZRyYss1zc9HcLhsapzsa)mc0UxpQThIP7rF2ShnPgJIqHnapnapzsaN0HIY9SMoL(QMxXKLKQZeaEYKaoHH1QTE0JNmV2S9w5OpSydGtbWPgG)eWteWBiHH1Qf872tMxBE2taJrBqcWtMeWjmSwT9qmDp6ZM9Oj1gKa8KjbCcdRvJ0HufnSLjTdgJxk9HfBa80a80a80G)In(gWVvzChvWb((b4l4VyJVb8BVnDmY7ra)yuekSbPboW30f(c(XOiuydsd8ZoFWZl4NWWA12dX09OpFLhAdsaEYKaEXgxeMXafCuc4KHcG)a8xSX3a(juE6PxxdoW3Mg8f8JrrOWgKg4ND(GNxW)HcLhE0Nn7XGNmZi3vkaNcGNcWFc4nKWWA1M9yWtMzK7kL(qHYdj8xSX3a(VIQ8AZ2BLdCGVnz4l4hJIqHninWp78bpVG)dfkp8OpB2JbpzMrURua(taVHegwR2ShdEYmJCxP0hkuEibCYa4Sso5XfqaNEaFUseQYJlGWFXgFd4VxvmVuzjj3eiCGVti4l4hJIqHninWp78bpVG)dfkp8OpB2JbpzMrURua(ta)qHYdp6ZM9yWtMzK7kfGtgaNWWA1wp6XtMxB2ERC0hwSbWFc4nKWWA1M9yWtMzK7kL(qHYdjGtgaFUseQYJlGWFXgFd43zywvbdHd8DcdFb)fB8nGF2kGtwo7ja)yuekSbPboW3KTWxWFXgFd43zyowrf8JrrOWgKg4aFBsaFb)yuekSbPb(zNp45f8tyyTA7Hy6E0Nn7rtQnib4pb8InUimJbk4OeWPa4PG)In(gW)vnVIjljvNjGd8DkQbFb)yuekSbPb(zNp45f8tyyTARh94jZRnBVvo6dl2a4jtc4nKWWA12Bthd9HcLhsaNma(CLiuLhxaH)In(gWVZWSQcgch47uPGVG)In(gWpsSbXQg4hJIqHninWb(o1dWxWpgfHcBqAGF25dEEb)jc4uxa)mc0UxpQThIP7rF2ShnPgJIqHnapzsaVyJlcZyGcokbCYqbWFaWtdWFc4egwRM4kpY2dX0r9HfBG)In(gW)vnVIjljvNjGd8Dk6cFb)fB8nGFb)U9K51MN9eWyGFmkcf2G0ah47uMg8f8JrrOWgKg4ND(GNxWpHH1QpJaZRntAnJNUTMda)jGNiGlxdfHhnD)TIWShI8(9QX3qJrrOWgGNmjGlxdfHhnT1rvlV2mHALYvqQXOiuydWtMeWl24IWmgOGJsaNmua8ha80G)In(gWVKC3oE0NjTMXdoW3Pmz4l4hJIqHninWp78bpVG)Ziq7E9OU)CPIQSZCMc1yuekSb4pb8PUEC0kueQaCQNcGRqrOcWFc4nKWWA12BthdDBnhWFXgFd43ERCYXkQGd8DQec(c(XOiuydsd8ZoFWZl4)mc0UxpQBUK5KuEuhvz2kiurtJrrOWgG)eWz7QAR5qtyyT5MlzojLh1rvMTccv00hwnQa8NaoHH1QBUK5KuEuhvz2kiurlxhRcu3wZb8xSX3a(RJvbMr6qsTsFd4aFNkHHVGFmkcf2G0a)SZh88c(pJaT71J6MlzojLh1rvMTccv00yuekSb4pbC2UQ2Ao0egwBU5sMts5rDuLzRGqfn9HvJka)jGtyyT6MlzojLh1rvMTccv0Yw)qDBnhWFXgFd436hMjuLCGd8DkYw4l4hJIqHninWp78bpVGFcdRvtCLhz7Hy6O(WInWFXgFd4VxvmVuzjj3eiCGVtzsaFb)fB8nGF7TYHyvd8JrrOWgKg4ah4xyfHcymWxW3PGVGFmkcf2G0a)SZh88c(jmSwTZWSvTOu3wZb8xSX3a(DgMTQfLWb((b4l4hJIqHninWp78bpVGFHkknj2a4KbWPl1a8NaEXgxeMXafCuc4KHcG)a8xSX3a(RJvbMr6qsTsFd4aFtx4l4VyJVb8B9dZeQsoWpgfHcBqAGd8TPbFb)fB8nGFNHzvfme(XOiuydsdCGdCGFr4j9nGVFGApKIApKIUWV56cp6LWpzNjL64TP)n1PPaCa)f5iG7cK2BaC7EaENgAld10bWpKS3WpSb4Yvab8YywHAWgGZiVIEuQbItGhiGNYuaEx2qeEd2a8oNrG296r9JDa8zb8oNrG296r9JAmkcf26a4jMIoPPbIbIj7mPuhVn9VPonfGd4VihbCxG0EdGB3dW7ul2bWpKS3WpSb4Yvab8YywHAWgGZiVIEuQbItGhiGNWMcW7YgIWBWgG3rUgkcpA6h7a4Zc4DKRHIWJM(rngfHcBDa8Aa8UIPBca8etrN00aXjWdeWtrntb4Dzdr4nydW7CgbA3Rh1p2bWNfW7CgbA3Rh1pQXOiuyRdGNyk6KMgiobEGaEQuMcW7YgIWBWgG35mc0UxpQFSdGplG35mc0UxpQFuJrrOWwhapXu0jnnqCc8ab8upykaVlBicVbBaENZiq7E9O(Xoa(SaENZiq7E9O(rngfHcBDa8Aa8UIPBca8etrN00aXjWdeWtzAMcW7YgIWBWgG3zkfgJ(Xoa(SaENPuym6h1yuekS1bWtmfDstdeNapqapLPzkaVlBicVbBaENZiq7E9O(Xoa(SaENZiq7E9O(rngfHcBDa8etrN00aXjWdeWtzYMcW7YgIWBWgG3zkfgJ(Xoa(SaENPuym6h1yuekS1bWRbW7kMUjaWtmfDstdeNapqapLjBkaVlBicVbBaENZiq7E9O(Xoa(SaENZiq7E9O(rngfHcBDa8etrN00aXaXKDMuQJ3M(3uNMcWb8xKJaUlqAVbWT7b4Dynzha)qYEd)WgGlxbeWlJzfQbBaoJ8k6rPgiobEGaoDnfG3LneH3GnaVdBJMHp6h7a4Zc4DyB0m8r)OgJIqHToaEIPOtAAG4e4bc401uaEx2qeEd2a8oY1qr4rt)yhaFwaVJCnueE00pQXOiuyRdGNyk6KMgiobEGaUjBkaVlBicVbBaENPuym6h7a4Zc4DMsHXOFuJrrOWwhapXu0jnnqCc8ab8eYuaEx2qeEd2a8oNrG296r9JDa8zb8oNrG296r9JAmkcf26a4jMIoPPbIbIj7mPuhVn9VPonfGd4VihbCxG0EdGB3dW7iNoa(HK9g(HnaxUciGxgZkud2aCg5v0JsnqCc8ab8uMcW7YgIWBWgG35mc0UxpQFSdGplG35mc0UxpQFuJrrOWwhapXu0jnnqCc8ab8uMcW7YgIWBWgG3HTrZWh9JDa8zb8oSnAg(OFuJrrOWwhapXu0jnnqCc8ab8upykaVlBicVbBaENZiq7E9O(Xoa(SaENZiq7E9O(rngfHcBDa8etrN00aXjWdeWtzAMcW7YgIWBWgG3rUgkcpA6h7a4Zc4DKRHIWJM(rngfHcBDa8eFGoPPbItGhiGNYKnfG3LneH3GnaVZzeODVEu)yhaFwaVZzeODVEu)OgJIqHToaEIPOtAAG4e4bc4Psitb4Dzdr4nydW7CgbA3Rh1p2bWNfW7CgbA3Rh1pQXOiuyRdGNyk6KMgiobEGaEQe2uaEx2qeEd2a8oNrG296r9JDa8zb8oNrG296r9JAmkcf26a4jMIoPPbIbIn9cK2BWgGNqaEXgFdax5YrQbIHFjjKbFNqMg8t6wRRq4NSilaVRREeWnjVvoaXKfzb4DDDmYb8eUBa)bQ9qkGyGyYISa8UqEf9O0uaXKfzb4Dva30zJodG7btz0qaNgLhMaW9aW76vekGXa4MuYMjaWtK0k9X3WJEa3LaEb4Kufv4b4nK5sFJ0aIjlYcW7QaExxMabC5kGaEhR3t(KpuO8q2bWXyohLaErIKIkaFwaNyLsa369KpsaFdfvAGyGyYISa8UcDqMXGnaNaT7HaoBfiQbWjWEpKAa3KYyiPrc4XgDvYRtWAOa8In(gsaFdfvAG4In(gsnPdzRarn0tH26yvGzpguPq2aexSX3qQjDiBfiQHEk0knee2iBUg8YOcfWykfqCXgFdPM0HSvGOg6PqlHYtp96AD7wkfBCrygduWrjzO8aqCXgFdPM0HSvGOg6PqR9w5qSQPB3sPyJlcZyGcokPKcigiMSilaVRqhKzmydWrr4rfGpUac4d5iGxSzpa3LaEjQCvrOqnqCXgFdjf2AedEssOs1TBPqDpJaT71J6MlzojLh1rvMTccv0E2qcdRvZk54rV2G0ZgsyyTAwjhp61hkuEiP(ujtY2v1wZHMWWAZnxYCskpQJQmBfeQOPpSAu9KWWA1nxYCskpQJQmBfeQOLRJvbQBR5aiUyJVHKEk0YkLkxSX3iRC50DucifwtcexSX3qspfAzLsLl24BKvUC6okbKckLyWqjqCXgFdj9uOLvkvUyJVrw5YP7Oeqk1ID7wkfBCrygduWrjzOqxG4In(gs6PqlRuQCXgFJSYLt3rjGuKt3ULsXgxeMXafCus90fiUyJVHKEk0YkLkxSX3iRC50DucifHvekGXaedexSX3qQRfPyVnDmY7raexSX3qQRfPNcTekp90RRbexSX3qQRfPNcTwLXDu1TBPK4HcLhE0Nn7XGNmZi3vkkulzYgsyyTAZEm4jZmYDLs3wZrAptK0HIY9SMoLgj2GyvtYKegwRM4kpY2dX0r9HfBEsyyTARh94jZRnBVvo6dl2qHAPbexSX3qQRfPNcTodZXkQaIl24Bi11I0tHw2kGtwo7jaexSX3qQRfPNcTodZQkyy3ULcHH1QTE0JNmV2S9w5OpSytYKnKWWA12Bthd9HcLhsYmxjcv5XfWKjpuO8WJ(Szpg8Kzg5Us9SHegwR2ShdEYmJCxP0hkuEijZCLiuLhxabIl24Bi11I0tH2RAEftwsQot0TBPixdfHhnnBfiQjlGnFQX3aiUyJVHuxlspfAf872tMxBE2taJbiUyJVHuxlspfALK72XJ(mP1mEaXfB8nK6Ar6PqR9w5KJvu1TBPCgbA3Rh19NlvuLDMZu4ZPUEC0kueQOEkkueQE2qcdRvBVnDm0T1CaexSX3qQRfPNcTw)WmHQKt3ULYzeODVEu3CjZjP8OoQYSvqOI2t2UQ2Ao0egwBU5sMts5rDuLzRGqfn9HvJQNegwRU5sMts5rDuLzRGqfTS1pu3wZbqCXgFdPUwKEk0whRcmJ0HKAL(gD7wkcvuAsSHm0LApl24IWmgOGJsYqjHEsDpJaT71J6EvX8sLTx1lGXibIl24Bi11I0tHwKydIvnaXfB8nK6Ar6PqRZWSQcg2TBPCgbA3Rh19QI5LkBVQxaJr(CkfgJwss5Z4rF2z4Z5krOkpUas993AeTCTOMq5PNEDn9HcLhsG4In(gsDTi9uO1C5t3sKrHA6uD7wkNrG296rDVQyEPY2R6fWyKpNsHXOLKu(mE0NDgcexSX3qQRfPNcT2BLdXQgGyG4In(gsnRjPqAhFJUDlfshkkVwBUN10oJQSi0dzYKeRu(069Kp5dfkpKupDPgqCXgFdPM1K0tH2gwd5e7fiqCXgFdPM1K0tHwb)U9K51MN9eWy62Tuk24IWmgOGJsQNUptKTrZWhT0jr(gyllukNHjtkxdfHhnT5soOQIwM0TKohhQsdiUyJVHuZAs6Pq7zeyETzsRz862Tuy7QAR5q7mQYIqpK6dfkpKKj1dpjmSw9zeyETzsRz80T1CaexSX3qQznj9uO1zuLfHEi72TuimSw9zeyETzsRz80T1C8mrcdRv7mQYIqpK62AosMCkfgJ(mcmV2mP1mEP9mrcdRvlvoZezNH62AosMSyJlcZyGcokjdLhsdiUyJVHuZAs6Pq74cy2CDK62TuoJaT71J6bfiTxPYMRJ0tcdRvJ0H8Yqo(gAdsptK0HIYR1M7znTZOklc9qMmjXkLpTEp5t(qHYdj1txQLgqCXgFdPM1K0tHwdjM9bfKaXfB8nKAwtspfAju72YwJJkG4In(gsnRjPNcTe4jXZeE0dexSX3qQznj9uOv59KpYmzdJwVagdqCXgFdPM1K0tHwRFiHA3gqCXgFdPM1K0tH2kyOCUsLzLsbexSX3qQznj9uOLO6ZRnpNZmHeigiMSila30XLfHcBaobYkdjc40O8We0(j3feWdWDjGxaojvrfEaoJ81zOgiMSilaVyJVHulSIqbmgkekpmrUcQ62TuewrOagJU5YPcgsMuudiUyJVHulSIqbmg6PqRZWSvTOSB3sHWWA1odZw1IsDBnhaXfB8nKAHvekGXqpfARJvbMr6qsTsFJUDlfHkknj2qg6sTNfBCrygduWrjzO8aqCXgFdPwyfHcym0tHwRFyMqvYbiUyJVHulSIqbmg6PqRZWSQcgcedexSX3qQLdfRY4oQ62Tus8qHYdp6ZM9yWtMzK7kffQLmzdjmSwTzpg8Kzg5UsPBR5iTNjs6qr5EwtNsJeBqSQjzscdRvtCLhz7Hy6O(WInptK0HIY9SMoLUxvmVuzjj3eyYKKouuUN10P02BLdXQMNjsDzB0m8r7hMxBEihZLKHrdBjtY2v1wZH(QMxXKLKQZe6dfkpKjtEgbA3Rh12dX09OpB2JMmTKjjDOOCpRPtPVQ5vmzjP6mrYKegwR26rpEY8AZ2BLJ(WInuO2ZeBiHH1Qf872tMxBE2taJrBqkzscdRvBpet3J(SzpAsTbPKjjmSwnshsv0WwM0oymEP0hwSjT0sdiUyJVHulh6PqR920XiVhbqCXgFdPwo0tHwcLNE61162TuimSwT9qmDp6Zx5H2GuYKfBCrygduWrjzO8aqCXgFdPwo0tH2ROkV2S9w50TBPCOq5Hh9zZEm4jZmYDLIsQNnKWWA1M9yWtMzK7kL(qHYdjqCXgFdPwo0tH2EvX8sLLKCtGD7wkhkuE4rF2ShdEYmJCxPE2qcdRvB2JbpzMrURu6dfkpKKHvYjpUas)CLiuLhxabIl24Bi1YHEk06mmRQGHD7wkhkuE4rF2ShdEYmJCxPEEOq5Hh9zZEm4jZmYDLImegwR26rpEY8AZ2BLJ(WInpBiHH1Qn7XGNmZi3vk9HcLhsYmxjcv5XfqG4In(gsTCONcTSvaNSC2taiUyJVHulh6PqRZWCSIkG4In(gsTCONcTx18kMSKuDMOB3sHWWA12dX09OpB2JMuBq6zXgxeMXafCusjfqCXgFdPwo0tHwNHzvfmSB3sHWWA1wp6XtMxB2ERC0hwSjzYgsyyTA7TPJH(qHYdjzMReHQ84ciqCXgFdPwo0tHwKydIvnaXfB8nKA5qpfAVQ5vmzjP6mr3ULsIu3Ziq7E9O2EiMUh9zZE0KjtwSXfHzmqbhLKHYdP9KWWA1ex5r2EiMoQpSydqCXgFdPwo0tHwb)U9K51MN9eWyaIl24Bi1YHEk0kj3TJh9zsRz862TuimSw9zeyETzsRz80T1C8mr5AOi8OP7VveM9qK3Vxn(gjtkxdfHhnT1rvlV2mHALYvqMmzXgxeMXafCusgkpKgqCXgFdPwo0tHw7TYjhROQB3s5mc0UxpQ7pxQOk7mNPWNtD94OvOiur9uuOiu9SHegwR2EB6yOBR5aiUyJVHulh6PqBDSkWmshsQv6B0TBPCgbA3Rh1nxYCskpQJQmBfeQO9KTRQTMdnHH1MBUK5KuEuhvz2kiurtFy1O6jHH1QBUK5KuEuhvz2kiurlxhRcu3wZbqCXgFdPwo0tHwRFyMqvYPB3s5mc0UxpQBUK5KuEuhvz2kiur7jBxvBnhAcdRn3CjZjP8OoQYSvqOIM(WQr1tcdRv3CjZjP8OoQYSvqOIw26hQBR5aiUyJVHulh6PqBVQyEPYssUjWUDlfcdRvtCLhz7Hy6O(WInaXfB8nKA5qpfAT3khIvnWboqi]] )


end
