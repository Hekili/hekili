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
    
    spec:RegisterPack( "Frost Mage", 20210213, [[dOKmXaqiQKOhjcSjvP(KuPrjcDkrIxHuAwsfDlQek7Iu)cjAyibhJk1Yuf8mqLMgvcUgvs12OskFJkjzCsfIZHufzDujAEivP7bk7duXbPssTqqvpuQGjsLeCrPcvBuQq6JujHoPuHYkrLMPiOBIufStvj)KkHQHIufQLsLq6PQQPQk6RujeJvvO9c8xrnychwYIb5XOmzPCzOntvFwQA0ifNMYQrQc51iv1Sj62OQDl8BLgos64ivrTCvEojtxX1PITJk(UiA8iHopsL1lsA(Iu7hXa3GNGFRge86bk8GBk8GB4QDdx46cuW1b)HoQi4tTy0V6rWpkEe87O3QgIGEO6rWNArNCRg4j4RwNJHGpnZqv5skPS3gACG0SLNsLX7iRX2GDLFOuz8mkbFihtoDSaab(TAqWRhOWdUPWdUHR2nCHlCD9oc4xodn7b(FJVdGpnwRHbac8BOIb(jibeb9q1Jerh9w1q4MGeqeDue6CQJoIWnC7KiEGcp4MWLWnbjGi6anv0Jkxs4MGeqeUyeHRWgDhIWcM0PHeb8slOprybrqpSCqEmgIWvtpoHerIuxLn2gw0teMIikIGQSOdpIOHmtzBKc4ln1Oapb)g6lh5aEcE5g8e8l2yBa(S1jg8uurPe8XOGKydapyaVEa8e8XOGKydap4xSX2a8zLuMl2yBKLMAaFPPMCu8i4ZAkWaEbxWtWhJcsIna8GFXgBdWNvszUyJTrwAQb8LMAYrXJGpQuyWqfyaVCbWtWhJcsIna8Gp7SbpRa)InghmJbYBOIiGdmIaUGFXgBdWNvszUyJTrwAQb8LMAYrXJGFTiyaVCDWtWhJcsIna8Gp7SbpRa)InghmJbYBOIiOxIaUGFXgBdWNvszUyJTrwAQb8LMAYrXJGVAad4LRbEc(yuqsSbGh8l2yBa(SskZfBSnYstnGV0utokEe85xoipgdyad4t9q2Ydvd4j4LBWtWVyJTb4xhRcmBXGsjYgWhJcsIna8Gb86bWtWVyJTb4NSg8YOe5Xykj4JrbjXgaEWaEbxWtWhJcsIna8Gp7SbpRa)InghmJbYBOIiGdmI4bWVyJTb4djTutTUgyaVCbWtWhJcsIna8Gp7SbpRa)InghmJbYBOIiGreUb)In2gGV)w1aTYbmGb8RfbpbVCdEc(fBSnaF)TPIrEpiWhJcsIna8Gb86bWtWVyJTb4djTutTUg4JrbjXgaEWaEbxWtWhJcsIna8Gp7SbpRa)ejId5llSOpN0IbpvMrJjLebmIGcer60erdHC8EDslg8uzgnMuQBBYGisHiEtejseupKtUN10U1i0gqRCiI0PjcihVxdDLfz)HyQO(WIneXBIaYX71El6XtLxF2FRA0hwSHiGreuGisb8l2yBa(EPZD0bgWlxa8e8l2yBa(gdZXYPaFmkij2aWdgWlxh8e8l2yBa(SLhNSA2Jh8XOGKydapyaVCnWtWhJcsIna8Gp7SbpRaFihVx7TOhpvE9z)TQrFyXgIiDAIOHqoEV2FBQyOpKVSqreWHiMR4GY8y8irKonrCiFzHf95Kwm4PYmAmPKiEteneYX71jTyWtLz0ysP(q(YcfrahIyUIdkZJXJGFXgBdW3yywwbdbd4LRc8e8XOGKydap4ZoBWZkWxTosilAA2YdvtMhB2uJTHgJcsInWVyJTb4FvZQyYkQ1rFWaE1rapb)In2gGpVD3EQ86ZZE8ymGpgfKeBa4bd4f9e4j4xSX2a8v0y(XI(m1njEGpgfKeBa4bd4LBkaEc(yuqsSbGh8zNn4zf4Fob63Rh19NPK0LnMXKOgJcsInI4nrm11JJwICqjrqVWicjYbLeXBIOHqoEV2FBQyOBBYa8l2yBa((BvtowofyaVC7g8e8XOGKydap4ZoBWZkW)Cc0VxpQBMIzuLwuhDz2YZxrtJrbjXgr8Miy7kBBYqd5495MPygvPf1rxMT88v00hwn6iI3ebKJ3RBMIzuLwuhDz2YZxrl7Td1Tnza(fBSnaFVDygswQbmGxUFa8e8XOGKydap4ZoBWZkWNVIstLnebCic4sbI4nruSX4GzmqEdvebCGreUgr8MiCLeX5eOFVEu3llMvYS)QEEmgLgJcsInWVyJTb4xhRcmJuKQCv2gGb8YnCbpb)In2gGpcTb0khWhJcsIna8Gb8YTlaEc(yuqsSbGh8zNn4zf4Fob63Rh19YIzLm7VQNhJrPXOGKyJiEtetjXy0kQsBgl6Zgd1yuqsSreVjI5koOmpgpse0lr0FRt0Y1IAiPLAQ110hYxwOa)In2gGVXWSScgcgWl3Uo4j4JrbjXgaEWxHmWNcA3GFXgBdWpzzd4ZoBWZkW)Cc0VxpQ7LfZkz2FvppgJsJrbjXgr8MiMsIXOvuL2mw0NngQXOGKydmGxUDnWtWVyJTb47VvnqRCaFmkij2aWdgWa(SMc8e8Yn4j4JrbjXgaEWND2GNvGp1d5KxVp3ZAAJrxMdAHIisNMi8wpnt(q(YcfrqVebCPa4xSX2a8PUJTbyaVEa8e8l2yBa(nSgAG2lqWhJcsIna8Gb8cUGNGpgfKeBa4bF2zdEwb(fBmoygdK3qfrqVebCjI3erIebBJMJnALrLMnWwMVKgd1yuqsSrePtteQ1rczrtNSudkROLPEl1ZWHongfKeBerkGFXgBdWN3UBpvE95zpEmgWaE5cGNGpgfKeBa4bF2zdEwb(SDLTnzOngDzoOfk9H8LfkIaoeH7hiI3ebKJ3RpNaZRptDtINUTjdWVyJTb4FobMxFM6MepWaE56GNGpgfKeBa4bF2zdEwb(qoEV(CcmV(m1njE62MmiI3erIebKJ3RngDzoOfkDBtger60eXusmg95eyE9zQBs80yuqsSrePqeVjIejcihVxRKgJ(zJH62MmiI0PjIInghmJbYBOIiGdmI4bIifWVyJTb4Bm6YCqluGb8Y1apbFmkij2aWd(SZg8Sc8pNa971J6b5PUxjZjRJQgJcsInI4nra549AKI0uoQX2q7qLiEtejseupKtE9(CpRPngDzoOfkIiDAIWB90m5d5llueb9seWLcerkGFXgBdWFmEmNSoQGb8YvbEc(fBSnaFhfMTb5vGpgfKeBa4bd4vhb8e8l2yBa(qYDBzVZrh4JrbjXgaEWaErpbEc(fBSnaFi8u4rFl6bFmkij2aWdgWl3ua8e8l2yBa(sRNMrLPh5065XyaFmkij2aWdgWl3Ubpb)In2gGV3oesUBd8XOGKydapyaVC)a4j4xSX2a8RGHQ5kzMvsj4JrbjXgaEWaE5gUGNGFXgBdWhQ6ZRppNXOVc8XOGKydapyad4RgWtWl3GNGpgfKeBa4bF2zdEwb(jsehYxwyrFoPfdEQmJgtkjcyebfiI0PjIgc5496Kwm4PYmAmPu32KbrKcr8MisKiOEiNCpRPDRrOnGw5qePtteqoEVg6klY(dXur9HfBiI3erIeb1d5K7znTBDVSywjZkQg9rIiDAIG6HCY9SM2T2FRAGw5qeVjIejcxjrW2O5yJ2omV(8qdMlfdJg20yuqsSrePtteSDLTnzOVQzvmzf16OV(q(YcfrKonrCob63Rh1(dXuTOpN0IMsJrbjXgrKcrKonrq9qo5Ewt7wFvZQyYkQ1rFIiDAIaYX71El6XtLxF2FRA0hwSHiGreuGiEtejseneYX7182D7PYRpp7XJXODOsePtteqoEV2FiMQf95Kw0uAhQer60ebKJ3RrksTIg2Yu3bJXkP(WInerkerkerkGFXgBdW3lDUJoWaE9a4j4xSX2a893Mkg59GaFmkij2aWdgWl4cEc(yuqsSbGh8zNn4zf4d549A)HyQw0NVYcTdvIiDAIOyJXbZyG8gQic4aJiEa8l2yBa(qsl1uRRbgWlxa8e8XOGKydap4ZoBWZkW)q(Ycl6ZjTyWtLz0ysjraJiCteVjIgc5496Kwm4PYmAmPuFiFzHc8l2yBa(xrxE9z)TQbmGxUo4j4JrbjXgaEWND2GNvG)H8Lfw0NtAXGNkZOXKsI4nr0qihVxN0IbpvMrJjL6d5lluebCicwPM8y8irqlrmxXbL5X4rWVyJTb43llMvYSIQrFemGxUg4j4JrbjXgaEWND2GNvG)H8Lfw0NtAXGNkZOXKsI4nrCiFzHf95Kwm4PYmAmPKiGdra549AVf94PYRp7Vvn6dl2qeVjIgc5496Kwm4PYmAmPuFiFzHIiGdrmxXbL5X4rWVyJTb4BmmlRGHGb8YvbEc(fBSnaF2YJtwn7Xd(yuqsSbGhmGxDeWtWVyJTb4BmmhlNc8XOGKydapyaVONapbFmkij2aWd(SZg8Sc8HC8ET)qmvl6ZjTOP0oujI3erXgJdMXa5nureWic3GFXgBdW)QMvXKvuRJ(Gb8YnfapbFmkij2aWd(SZg8Sc8HC8ET3IE8u51N93Qg9HfBiI0PjIgc549A)TPIH(q(YcfrahIyUIdkZJXJGFXgBdW3yywwbdbd4LB3GNGFXgBdWhH2aALd4JrbjXgaEWaE5(bWtWhJcsIna8Gp7SbpRa)ejcxjrCob63Rh1(dXuTOpN0IMsJrbjXgrKonruSX4GzmqEdvebCGrepqePqeVjcihVxdDLfz)HyQO(WInGFXgBdW)QMvXKvuRJ(Gb8YnCbpb)In2gGpVD3EQ86ZZE8ymGpgfKeBa4bd4LBxa8e8XOGKydap4ZoBWZkWhYX71NtG51NPUjXt32Kbr8MisKiuRJeYIMU)woy2cow)E1yBOXOGKyJisNMiuRJeYIM2BOSLxFgsUk1YR0yuqsSrePttefBmoygdK3qfrahyeXderkGFXgBdWxrJ5hl6Zu3K4bgWl3Uo4j4JrbjXgaEWND2GNvG)5eOFVEu3FMssx2ygtIAmkij2iI3eXuxpoAjYbLeb9cJiKihuseVjIgc549A)TPIHUTjdWVyJTb47Vvn5y5uGb8YTRbEc(yuqsSbGh8zNn4zf4Fob63Rh1ntXmQslQJUmB55ROPXOGKyJiEteSDLTnzOHC8(CZumJQ0I6OlZwE(kA6dRgDeXBIaYX71ntXmQslQJUmB55ROLRJvbQBBYa8l2yBa(1XQaZifPkxLTbyaVC7QapbFmkij2aWd(SZg8Sc8pNa971J6MPygvPf1rxMT88v00yuqsSreVjc2UY2Mm0qoEFUzkMrvArD0LzlpFfn9HvJoI4nra5496MPygvPf1rxMT88v0YE7qDBtgGFXgBdW3BhMHKLAad4L7oc4j4JrbjXgaEWND2GNvGpKJ3RHUYIS)qmvuFyXgWVyJTb43llMvYSIQrFemGxUPNapb)In2gGV)w1aTYb8XOGKydapyad4ZVCqEmgWtWl3GNGpgfKeBa4bF2zdEwb(qoEV2yy2lxuPBBYa8l2yBa(gdZE5IkWaE9a4j4JrbjXgaEWND2GNvGpFfLMkBic4qeWLceXBIOyJXbZyG8gQic4aJiEa8l2yBa(1XQaZifPkxLTbyaVGl4j4xSX2a892HzizPgWhJcsIna8Gb8Yfapb)In2gGVXWSScgc(yuqsSbGhmGbmGph8u2gGxpqHhCtHhOqhb8twxyrVc8DrC1UOV6yVCfDjrqepPbjcJN6Edr43Ji6wl2LioKE2XoSreQLhjIYzw(AWgrWOPIEuPjCtOfir4QCjr0Hn4G3GnIORADKqw00p2LiMLi6QwhjKfn9JAmkij26se1qeDCx8esej6MIPOjCtOfir4McUKi6WgCWBWgr09Cc0VxpQFSlrmlr09Cc0VxpQFuJrbjXwxIir3umfnHBcTajc3UDjr0Hn4G3GnIO75eOFVEu)yxIywIO75eOFVEu)OgJcsITUerIUPykAc3eAbseUFWLerh2GdEd2iIUNtG(96r9JDjIzjIUNtG(96r9JAmkij26se1qeDCx8esej6MIPOjCtOfir42fCjr0Hn4G3GnIO7usmg9JDjIzjIUtjXy0pQXOGKyRlrKOBkMIMWnHwGeHBxWLerh2GdEd2iIUNtG(96r9JDjIzjIUNtG(96r9JAmkij26sej6MIPOjCtOfir421Djr0Hn4G3GnIO7usmg9JDjIzjIUtjXy0pQXOGKyRlrudr0XDXtirKOBkMIMWnHwGeHBx3Lerh2GdEd2iIUNtG(96r9JDjIzjIUNtG(96r9JAmkij26sej6MIPOjCjCDrC1UOV6yVCfDjrqepPbjcJN6Edr43Ji6YAQUeXH0Zo2HnIqT8iruoZYxd2icgnv0JknHBcTajc46sIOdBWbVbBerx2gnhB0p2LiMLi6Y2O5yJ(rngfKeBDjIeDtXu0eUj0cKiGRljIoSbh8gSreDvRJeYIM(XUeXSerx16iHSOPFuJrbjXwxIir3umfnHBcTajcx3Lerh2GdEd2iIUtjXy0p2LiMLi6oLeJr)OgJcsITUerIUPykAc3eAbseUMljIoSbh8gSreDpNa971J6h7seZseDpNa971J6h1yuqsS1Lis0nftrt4s46I4QDrF1XE5k6sIGiEsdsegp19gIWVhr0vnDjIdPNDSdBeHA5rIOCMLVgSremAQOhvAc3eAbseUDjr0Hn4G3GnIO75eOFVEu)yxIywIO75eOFVEu)OgJcsITUerIUPykAc3eAbseUDjr0Hn4G3GnIOlBJMJn6h7seZseDzB0CSr)OgJcsITUerIUPykAc3eAbseUFWLerh2GdEd2iIUNtG(96r9JDjIzjIUNtG(96r9JAmkij26sej6MIPOjCtOfir42fCjr0Hn4G3GnIORADKqw00p2LiMLi6QwhjKfn9JAmkij26sej(aftrt4MqlqIWTR7sIOdBWbVbBer3Zjq)E9O(XUeXSer3Zjq)E9O(rngfKeBDjIeDtXu0eUj0cKiC7AUKi6WgCWBWgr09Cc0VxpQFSlrmlr09Cc0VxpQFuJrbjXwxIir3umfnHBcTajc3UkxseDydo4nyJi6Eob63Rh1p2LiMLi6Eob63Rh1pQXOGKyRlrKOBkMIMWLWTJXtDVbBeHRrefBSnicPPgLMWf8vurg4LR5cGp1B9Meb)eKaIGEO6rIOJERAiCtqciIokcDo1rhr4gUDsepqHhCt4s4MGeqeDGMk6rLljCtqcicxmIWvyJUdrybt60qIaEPf0NiSGiOhwoipgdr4QPhNqIirQRYgBdl6jctrefrqvw0Hhr0qMPSnsHWLWnbjGi64uezod2ici0VhseSLhQgIac7TqPjcxnJHuhfreB4IrtD8EhjruSX2qreBiPtt4wSX2qPPEiB5HQHwyuwhRcmBXGsjYgc3In2gkn1dzlpun0cJsLdp)g5K1GxgLipgtjjCl2yBO0upKT8q1qlmkHKwQPwxRtZdRyJXbZyG8gQGdShiCl2yBO0upKT8q1qlmk93QgOvoDAEyfBmoygdK3qfm3eUeUjiberhNIiZzWgrGCWJoIymEKigAqIOyZEeHPiIItzYcsIAc3In2gkyS1jg8uurPKWTyJTHIwyuYkPmxSX2iln10zu8imwtr4wSX2qrlmkzLuMl2yBKLMA6mkEegQuyWqfHBXgBdfTWOKvszUyJTrwAQPZO4ry1IDAEyfBmoygdK3qfCGbxc3In2gkAHrjRKYCXgBJS0utNrXJWutNMhwXgJdMXa5nurVWLWTyJTHIwyuYkPmxSX2iln10zu8im(LdYJXq4s4wSX2qPRfH5VnvmY7br4wSX2qPRfPfgLqsl1uRRr4wSX2qPRfPfgLEPZD01P5HL4H8Lfw0NtAXGNkZOXKsyuiD6gc5496Kwm4PYmAmPu32KrkVtK6HCY9SM2TgH2aALt60qoEVg6klY(dXur9HfBEd549AVf94PYRp7Vvn6dl2aJcPq4wSX2qPRfPfgLgdZXYPiCl2yBO01I0cJs2YJtwn7Xt4wSX2qPRfPfgLgdZYkyyNMhgKJ3R9w0JNkV(S)w1OpSyt60neYX71(Btfd9H8Lfk4mxXbL5X4X0PpKVSWI(Cslg8uzgnMu(UHqoEVoPfdEQmJgtk1hYxwOGZCfhuMhJhjCl2yBO01I0cJYRAwftwrTo63P5HPwhjKfnnB5HQjZJnBQX2GWTyJTHsxlslmk5T72tLxFE2JhJHWTyJTHsxlslmkv0y(XI(m1njEeUfBSnu6ArAHrP)w1KJLt1P5HDob63Rh19NPK0LnMXK47PUEC0sKdkPxysKdkF3qihVx7Vnvm0Tnzq4wSX2qPRfPfgLE7WmKSutNMh25eOFVEu3mfZOkTOo6YSLNVI2B2UY2Mm0qoEFUzkMrvArD0LzlpFfn9HvJU3qoEVUzkMrvArD0LzlpFfTS3ou32KbHBXgBdLUwKwyuwhRcmJuKQCv2gDAEy8vuAQSboWLcVl2yCWmgiVHk4aZ1E7kpNa971J6EzXSsM9x1ZJXOiCl2yBO01I0cJseAdOvoeUfBSnu6ArAHrPXWSScg2P5HDob63Rh19YIzLm7VQNhJr9EkjgJwrvAZyrF2y475koOmpgpsV936eTCTOgsAPMADn9H8Lfkc3In2gkDTiTWOmzztNkKbJcA3DAEyNtG(96rDVSywjZ(R65XyuVNsIXOvuL2mw0Nngs4wSX2qPRfPfgL(Bvd0khcxc3In2gknRPGrDhBJonpmQhYjVEFUN10gJUmh0cv60ERNMjFiFzHIEHlfiCl2yBO0SMIwyu2WAObAVajCl2yBO0SMIwyuYB3TNkV(8ShpgtNMhwXgJdMXa5nurVW9DISnAo2OvgvA2aBz(sAmmDA16iHSOPtwQbLv0YuVL6z4qxkeUfBSnuAwtrlmkpNaZRptDtIxNMhgBxzBtgAJrxMdAHsFiFzHcoUF4nKJ3RpNaZRptDtINUTjdc3In2gknRPOfgLgJUmh0cvNMhgKJ3RpNaZRptDtINUTjJ3jc549AJrxMdAHs32Kr60tjXy0NtG51NPUjXlL3jc549AL0y0pBmu32Kr60fBmoygdK3qfCG9qkeUfBSnuAwtrlmkhJhZjRJANMh25eOFVEupip19kzozDuFd549AKI0uoQX2q7q9DIupKtE9(CpRPngDzoOfQ0P9wpnt(q(Ycf9cxkKcHBXgBdLM1u0cJshfMTb5veUfBSnuAwtrlmkHK72YENJoc3In2gknRPOfgLq4PWJ(w0t4wSX2qPznfTWOuA90mQm9iNwppgdHBXgBdLM1u0cJsVDiKC3gHBXgBdLM1u0cJYkyOAUsMzLus4wSX2qPznfTWOeQ6ZRppNXOVIWLWnbjGiCfmvbjXgraHSYrHeb8slOpLFAmEE8ictrefrqvw0HhrWOzngQjCtqciIIn2gkn)Yb5XyGbjTG(5kORtZdJF5G8ym6MPMkyiCCtbc3In2gkn)Yb5XyOfgLgdZE5IQonpmihVxBmm7LlQ0Tnzq4wSX2qP5xoipgdTWOSowfygPiv5QSn608W4RO0uzdCGlfExSX4GzmqEdvWb2deUfBSnuA(LdYJXqlmk92HzizPgc3In2gkn)Yb5XyOfgLgdZYkyiHlHBXgBdLwnW8sN7ORtZdlXd5llSOpN0IbpvMrJjLWOq60neYX71jTyWtLz0ysPUTjJuENi1d5K7znTBncTb0kN0PHC8En0vwK9hIPI6dl28orQhYj3ZAA36EzXSsMvun6JPtt9qo5Ewt7w7VvnqRCENORKTrZXgTDyE95HgmxkggnSLonBxzBtg6RAwftwrTo6RpKVSqLo95eOFVEu7pet1I(CslAQusNM6HCY9SM2T(QMvXKvuRJ(Ptd549AVf94PYRp7Vvn6dl2aJcVtSHqoEVM3UBpvE95zpEmgTd10PHC8ET)qmvl6ZjTOP0outNgYX71ifPwrdBzQ7GXyLuFyXMusjfc3In2gkTAOfgL(BtfJ8EqeUfBSnuA1qlmkHKwQPwxRtZddYX71(dXuTOpFLfAhQPtxSX4GzmqEdvWb2deUfBSnuA1qlmkVIU86Z(BvtNMh2H8Lfw0NtAXGNkZOXKsyUF3qihVxN0IbpvMrJjL6d5llueUfBSnuA1qlmk7LfZkzwr1Op2P5HDiFzHf95Kwm4PYmAmP8DdHC8EDslg8uzgnMuQpKVSqbhwPM8y8iTZvCqzEmEKWTyJTHsRgAHrPXWSScg2P5HDiFzHf95Kwm4PYmAmP89H8Lfw0NtAXGNkZOXKs4a549AVf94PYRp7Vvn6dl28UHqoEVoPfdEQmJgtk1hYxwOGZCfhuMhJhjCl2yBO0QHwyuYwECYQzpEc3In2gkTAOfgLgdZXYPiCl2yBO0QHwyuEvZQyYkQ1r)onpmihVx7pet1I(CslAkTd13fBmoygdK3qfm3eUfBSnuA1qlmkngMLvWWonpmihVx7TOhpvE9z)TQrFyXM0PBiKJ3R93Mkg6d5lluWzUIdkZJXJeUfBSnuA1qlmkrOnGw5q4wSX2qPvdTWO8QMvXKvuRJ(DAEyj6kpNa971JA)HyQw0NtArtLoDXgJdMXa5nubhypKYBihVxdDLfz)HyQO(WIneUfBSnuA1qlmk5T72tLxFE2JhJHWTyJTHsRgAHrPIgZpw0NPUjXRtZddYX71NtG51NPUjXt32KX7evRJeYIMU)woy2cow)E1yBKoTADKqw00EdLT86ZqYvPwEv60fBmoygdK3qfCG9qkeUfBSnuA1qlmk93QMCSCQonpSZjq)E9OU)mLKUSXmMeFp11JJwICqj9ctICq57gc549A)TPIHUTjdc3In2gkTAOfgL1XQaZifPkxLTrNMh25eOFVEu3mfZOkTOo6YSLNVI2B2UY2Mm0qoEFUzkMrvArD0LzlpFfn9HvJU3qoEVUzkMrvArD0LzlpFfTCDSkqDBtgeUfBSnuA1qlmk92HzizPMonpSZjq)E9OUzkMrvArD0LzlpFfT3SDLTnzOHC8(CZumJQ0I6OlZwE(kA6dRgDVHC8EDZumJQ0I6OlZwE(kAzVDOUTjdc3In2gkTAOfgL9YIzLmROA0h708WGC8En0vwK9hIPI6dl2q4wSX2qPvdTWO0FRAGw5agWaa]] )


end
