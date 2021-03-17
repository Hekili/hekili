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
            max_stack = 30
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
                    if buff.cold_front.stack == 30 then
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
    
    spec:RegisterPack( "Frost Mage", 20210317, [[dOKXZaqiKuPhHOWMuf(KuXOePCkruVcPQzjvQBjvs1Ui1VqknmKuogf1Yuf1ZOizAue6AIizBuKY3KkjJJIu15KkPSokIMhsQ6EiX(qu6Gue0crkEOujMifPIlkIuTrksL(ifbCsrKYkjuZueXnruKDQk1pPiqdfrrPLIOO6PQQPQk5RiPcJvvK9c6VIAWO6WswmcpgLjlLldTzk9zPQrJKCAQwnIIIxJuPztYTjy3c)wPHJihhjv0Yv55enDfxNcBNq(UimEKkopIQ1ls18fj7hyOz4l4VvdcF)m1E2m1mL5UsB20tTNtQUg8pKtcHFsfJUvpc)rjGWVP7TYbWjtvpc)KkYvB1GVGF5ACme(PAgsstslT9(qLbHMTc0kDbdvn(gSRSdTsxGrl8ty4QjPfqc4VvdcF)m1E2m1mL5UsB20tTNtktd(lJHQ9G)Vl0f4NkV1Wasa)nuYGFYu1JaUP7TYbiMmvhJka3Cx1nG)m1E2mqmqCxOQIEuAsG4UoGB6SrNbW9GPmAiGtJYd6c4Ea4KPvekGXa4MqYSjbWtJ0k9X3WJEa3LaEb4Kuf54b4nK5sFJKbI76aozQOlc4Yvab8owVNQjFOq5HSdGJXCokb8Iejf5a(SaoXkLaU17PAKa(gkY1WVYLJe(c(BOTmud8f8Tz4l4hJIqHninWp78bpVGFQlGFgbA3Rh1nxYCskpQJ8mBfeQOPXOiuydWFa4nKWWA1SsoE0Rnib4pa8gsyyTAwjhp61hkuEibCQhWnd4Psb4SDvTnrOjmS2CZLmNKYJ6ipZwbHkA6dRg5a(daNWWA1nxYCskpQJ8mBfeQOLRJvbQBBIa(l24Ba)S1ig8KKqLcoW3pdFb)yuekSbPb(l24Ba)SsPYfB8nYkxoWVYLtokbe(znjCGVnf8f8JrrOWgKg4VyJVb8ZkLkxSX3iRC5a)kxo5Oeq4hLsmyOeoW3Mi8f8JrrOWgKg4ND(GNxWFXgxeMXafCuc4KLcGBk4VyJVb8ZkLkxSX3iRC5a)kxo5Oeq4VweoW3jf8f8JrrOWgKg4ND(GNxWFXgxeMXafCuc4upGBk4VyJVb8ZkLkxSX3iRC5a)kxo5Oeq4xoWb(20GVGFmkcf2G0a)fB8nGFwPu5In(gzLlh4x5YjhLac)cRiuaJboWb(jDiBfiQb(c(2m8f8xSX3a(RJvbM9yqLczd8JrrOWgKg4aF)m8f8xSX3a(tudEzuHcymLc(XOiuydsdCGVnf8f8JrrOWgKg4ND(GNxWFXgxeMXafCuc4KLcG)m8xSX3a(juE6PxxdoW3Mi8f8JrrOWgKg4ND(GNxWFXgxeMXafCuc4uaCZWFXgFd43ERCiw1ah4a)1IWxW3MHVG)In(gWV920XiVhb8JrrOWgKg4aF)m8f8xSX3a(juE6Pxxd(XOiuydsdCGVnf8f8JrrOWgKg4ND(GNxWFAa(HcLhE0Nt4XGNmZOYvkaNcGtnapvkaVHegwRoHhdEYmJkxP0Tnra4jd4pa80aCshkk3ZAAZAKydIvnaEQuaoHH1QjUYJS9qmDuFyXga)bGtyyTARh94jZRnBVvo6dl2a4uaCQb4jd)fB8nGFRY4oYHd8TjcFb)fB8nGFNH5yfvWpgfHcBqAGd8DsbFb)fB8nGF2kGtwo7ja)yuekSbPboW3Mg8f8JrrOWgKg4ND(GNxWpHH1QTE0JNmV2S9w5OpSydGNkfG3qcdRvBVnDm0hkuEibCYc4ZvIqvECbeWtLcWpuO8WJ(Ccpg8KzgvUsb4pa8gsyyT6eEm4jZmQCLsFOq5HeWjlGpxjcv5Xfq4VyJVb87mmRQGHWb(URGVGFmkcf2G0a)SZh88c(LRHIWJMMTce1KfWMp14BOXOiuyd(l24Ba)x18kMSKuD0foW3ME4l4VyJVb8l43TNmV28SNagd8JrrOWgKg4aF31GVG)In(gWVKk3oE0NjTjWd(XOiuydsdCGVntn4l4hJIqHninWp78bpVG)Ziq7E9OU)CPI8SZCMc1yuekSb4pa8PUEC0kueQaCQNcGRqrOcWFa4nKWWA12BthdDBteWFXgFd43ERCYXkQGd8TzZWxWpgfHcBqAGF25dEEb)NrG296rDZLmNKYJ6ipZwbHkAAmkcf2a8haoBxvBteAcdRn3CjZjP8OoYZSvqOIM(WQroG)aWjmSwDZLmNKYJ6ipZwbHkAzRFOUTjc4VyJVb8B9dZeQsoWb(28ZWxWpgfHcBqAGF25dEEb)cvuAsSbWjlGBkQb4pa8InUimJbk4OeWjlfa30a8hao1fWpJaT71J6EvX8sLTx1lGXi1yuekSb)fB8nG)6yvGzKoKuR03aoW3Mnf8f8xSX3a(rIniw1a)yuekSbPboW3Mnr4l4hJIqHninWp78bpVG)Ziq7E9OUxvmVuz7v9cymsngfHcBa(daFkfgJwss5Z4rF2zOgJIqHna)bGpxjcv5XfqaN6b8(BnIwUwutO80tVUM(qHYdj8xSX3a(DgMvvWq4aFBoPGVGFmkcf2G0a)sKb)utBg(l24Ba)jkFGF25dEEb)NrG296rDVQyEPY2R6fWyKAmkcf2a8ha(ukmgTKKYNXJ(SZqngfHcBWb(2SPbFb)fB8nGF7TYHyvd8JrrOWgKg4ah4N1KWxW3MHVGFmkcf2G0a)SZh88c(jDOO8AT5Ewt7mYZIqpKaEQuaoXkLa(da369un5dfkpKao1d4MIAWFXgFd4N0o(gWb((z4l4VyJVb83WAOIyVaHFmkcf2G0ah4BtbFb)yuekSbPb(zNp45f8xSXfHzmqbhLao1d4McWFa4Pb4SnAg(OLojQ2aBzHs5muJrrOWgGNkfGlxdfHhnDIsoOQIwM0TKohhY1yuekSb4jd)fB8nGFb)U9K51MN9eWyGd8TjcFb)yuekSbPb(zNp45f8Z2v12eH2zKNfHEi1hkuEibCYc4MFgWFa4egwR(mcmV2mPnbE62MiG)In(gW)zeyETzsBc8Gd8DsbFb)yuekSbPb(zNp45f8tyyT6ZiW8AZK2e4PBBIaWFa4Pb4egwR2zKNfHEi1Tnra4Psb4tPWy0NrG51MjTjWtJrrOWgGNmG)aWtdWjmSwTu5m6MDgQBBIaWtLcWl24IWmgOGJsaNSua8Nb8KH)In(gWVZiplc9qch4Btd(c(XOiuydsd8ZoFWZl4)mc0UxpQhuG0ELkNOosAmkcf2a8haoHH1Qr6qvzihFdTbja)bGNgGt6qr51AZ9SM2zKNfHEib8uPaCIvkb8haU17PAYhkuEibCQhWnrQb4jd)fB8nG)XfWCI6ibh47Uc(c(l24Ba)gsm7dkiHFmkcf2G0ah4Btp8f8xSX3a(ju72YwJJC4hJIqHninWb(URbFb)fB8nGFc8K4rxp6HFmkcf2G0ah4BZud(c(l24Ba)kVNQrMjZy06fWyGFmkcf2G0ah4BZMHVG)In(gWV1pKqTBd(XOiuydsdCGVn)m8f8xSX3a(RGHY5kvMvkf8JrrOWgKg4aFB2uWxWFXgFd4NO6ZRnpNZORe(XOiuydsdCGd8lh4l4BZWxWpgfHcBqAGF25dEEb)Pb4hkuE4rFoHhdEYmJkxPaCkao1a8uPa8gsyyT6eEm4jZmQCLs32ebGNmG)aWtdWjDOOCpRPnRrIniw1a4Psb4egwRM4kpY2dX0r9HfBa8haEAaoPdfL7znTzDVQyEPYssoDrapvkaN0HIY9SM2S2ERCiw1a4pa80aCQlGZ2Oz4J2pmV28qfMljdJg20yuekSb4Psb4SDvTnrOVQ5vmzjP6OR(qHYdjGNkfGFgbA3Rh12dX09OpNWJMuJrrOWgGNmGNkfGt6qr5EwtBwFvZRyYss1rxapvkaNWWA1wp6XtMxB2ERC0hwSbWPa4udWFa4Pb4nKWWA1c(D7jZRnp7jGXOnib4Psb4egwR2EiMUh95eE0KAdsaEQuaoHH1Qr6qQIg2YK2bJXlL(WInaEYaEYaEYWFXgFd43QmUJC4aF)m8f8xSX3a(T3Mog59iGFmkcf2G0ah4BtbFb)yuekSbPb(zNp45f8tyyTA7Hy6E0NVYdTbjapvkaVyJlcZyGcokbCYsbWFg(l24Ba)ekp90RRbh4Bte(c(XOiuydsd8ZoFWZl4)qHYdp6Zj8yWtMzu5kfGtbWnd4pa8gsyyT6eEm4jZmQCLsFOq5He(l24Ba)xrEETz7TYboW3jf8f8JrrOWgKg4ND(GNxW)HcLhE0Nt4XGNmZOYvka)bG3qcdRvNWJbpzMrLRu6dfkpKaozbCwjN84ciGtpGpxjcv5Xfq4VyJVb83RkMxQSKKtxeoW3Mg8f8JrrOWgKg4ND(GNxW)HcLhE0Nt4XGNmZOYvka)bGFOq5Hh95eEm4jZmQCLcWjlGtyyTARh94jZRnBVvo6dl2a4pa8gsyyT6eEm4jZmQCLsFOq5HeWjlGpxjcv5Xfq4VyJVb87mmRQGHWb(URGVG)In(gWpBfWjlN9eGFmkcf2G0ah4Btp8f8xSX3a(DgMJvub)yuekSbPboW3Dn4l4hJIqHninWp78bpVGFcdRvBpet3J(CcpAsTbja)bGxSXfHzmqbhLaofa3m8xSX3a(VQ5vmzjP6OlCGVntn4l4hJIqHninWp78bpVGFcdRvB9OhpzETz7TYrFyXgapvkaVHegwR2EB6yOpuO8qc4KfWNReHQ84ci8xSX3a(DgMvvWq4aFB2m8f8xSX3a(rIniw1a)yuekSbPboW3MFg(c(XOiuydsd8ZoFWZl4pnaN6c4NrG296rT9qmDp6Zj8Oj1yuekSb4Psb4fBCrygduWrjGtwka(ZaEYa(daNWWA1ex5r2EiMoQpSyd8xSX3a(VQ5vmzjP6OlCGVnBk4l4VyJVb8l43TNmV28SNagd8JrrOWgKg4aFB2eHVGFmkcf2G0a)SZh88c(jmSw9zeyETzsBc80Tnra4pa80aC5AOi8OP7VveM9qK3Vxn(gAmkcf2a8uPaC5AOi8OPToQA51MjuRuUcsngfHcBaEQuaEXgxeMXafCuc4KLcG)mGNm8xSX3a(Lu52XJ(mPnbEWb(2CsbFb)yuekSbPb(zNp45f8FgbA3Rh19NlvKNDMZuOgJIqHna)bGp11JJwHIqfGt9uaCfkcva(daVHegwR2EB6yOBBIa(l24Ba)2BLtowrfCGVnBAWxWpgfHcBqAGF25dEEb)NrG296rDZLmNKYJ6ipZwbHkAAmkcf2a8haoBxvBteAcdRn3CjZjP8OoYZSvqOIM(WQroG)aWjmSwDZLmNKYJ6ipZwbHkA56yvG62MiG)In(gWFDSkWmshsQv6Bah4BZDf8f8JrrOWgKg4ND(GNxW)zeODVEu3CjZjP8OoYZSvqOIMgJIqHna)bGZ2v12eHMWWAZnxYCskpQJ8mBfeQOPpSAKd4paCcdRv3CjZjP8OoYZSvqOIw26hQBBIa(l24Ba)w)WmHQKdCGVnB6HVGFmkcf2G0a)SZh88c(jmSwnXvEKThIPJ6dl2a)fB8nG)EvX8sLLKC6IWb(2Cxd(c(l24Ba)2BLdXQg4hJIqHninWboWVWkcfWyGVGVndFb)yuekSbPb(zNp45f8tyyTANHzRArPUTjc4VyJVb87mmBvlkHd89ZWxWpgfHcBqAGF25dEEb)cvuAsSbWjlGBkQb4pa8InUimJbk4OeWjlfa)z4VyJVb8xhRcmJ0HKAL(gWb(2uWxWFXgFd436hMjuLCGFmkcf2G0ah4Bte(c(l24Ba)odZQkyi8JrrOWgKg4ah4a)IWt6BaF)m1E2m1mf16k4prDHh9s4N6WesM)oP92eWKaoG)IkeWDbs7naUDpaVtdTLHA6a4hsDA4h2aC5kGaEzmRqnydWzuvrpk1aXjXdeWnBsaVlBicVbBaENZiq7E9O(Poa(SaENZiq7E9O(jngfHcBDa80mtNK1aXaXuhMqY83jT3MaMeWb8xuHaUlqAVbWT7b4DQf7a4hsDA4h2aC5kGaEzmRqnydWzuvrpk1aXjXdeW7ktc4Dzdr4nydW7ixdfHhn9tDa8zb8oY1qr4rt)KgJIqHToaEnaEs3emjaEAMPtYAG4K4bc4MPMjb8USHi8gSb4DoJaT71J6N6a4Zc4DoJaT71J6N0yuekS1bWtZmDswdeNepqa3Sztc4Dzdr4nydW7CgbA3Rh1p1bWNfW7CgbA3Rh1pPXOiuyRdGNMz6KSgiojEGaU5NnjG3LneH3GnaVZzeODVEu)uhaFwaVZzeODVEu)KgJIqHToaEnaEs3emjaEAMPtYAG4K4bc4Mnrtc4Dzdr4nydW7mLcJr)uhaFwaVZukmg9tAmkcf26a4PzMojRbItIhiGB2enjG3LneH3GnaVZzeODVEu)uhaFwaVZzeODVEu)KgJIqHToaEAMPtYAG4K4bc4Mtktc4Dzdr4nydW7mLcJr)uhaFwaVZukmg9tAmkcf26a41a4jDtWKa4PzMojRbItIhiGBoPmjG3LneH3GnaVZzeODVEu)uhaFwaVZzeODVEu)KgJIqHToaEAMPtYAGyGyQdtiz(7K2Btatc4a(lQqa3fiT3a429a8oSMSdGFi1PHFydWLRac4LXSc1GnaNrvf9OudeNepqa3uMeW7YgIWBWgG3HTrZWh9tDa8zb8oSnAg(OFsJrrOWwhapnZ0jznqCs8abCtzsaVlBicVbBaEh5AOi8OPFQdGplG3rUgkcpA6N0yuekS1bWtZmDswdeNepqapPmjG3LneH3GnaVZukmg9tDa8zb8otPWy0pPXOiuyRdGNMz6KSgiojEGaUPzsaVlBicVbBaENZiq7E9O(Poa(SaENZiq7E9O(jngfHcBDa80mtNK1aXaXuhMqY83jT3MaMeWb8xuHaUlqAVbWT7b4DKtha)qQtd)WgGlxbeWlJzfQbBaoJQk6rPgiojEGaUztc4Dzdr4nydW7CgbA3Rh1p1bWNfW7CgbA3Rh1pPXOiuyRdGNMz6KSgiojEGaUztc4Dzdr4nydW7W2Oz4J(Poa(SaEh2gndF0pPXOiuyRdGNMz6KSgiojEGaU5NnjG3LneH3GnaVZzeODVEu)uhaFwaVZzeODVEu)KgJIqHToaEAMPtYAG4K4bc4Mnrtc4Dzdr4nydW7ixdfHhn9tDa8zb8oY1qr4rt)KgJIqHToaEAptNK1aXjXdeWnNuMeW7YgIWBWgG35mc0UxpQFQdGplG35mc0UxpQFsJrrOWwhapnZ0jznqCs8abCZMMjb8USHi8gSb4DoJaT71J6N6a4Zc4DoJaT71J6N0yuekS1bWtZmDswdeNepqa3CxzsaVlBicVbBaENZiq7E9O(Poa(SaENZiq7E9O(jngfHcBDa80mtNK1aXaXjnbs7nydWnnaVyJVbGRC5i1aXWVKeYGVnnte(jDR1vi8tgKbGtMQEeWnDVvoaXKbza4KP6yub4M7QUb8NP2ZMbIbIjdYaW7cvv0JstcetgKbG31bCtNn6maUhmLrdbCAuEqxa3daNmTIqbmga3esMnjaEAKwPp(gE0d4UeWlaNKQihpaVHmx6BKmqmzqgaExhWjtfDraxUciG3X69un5dfkpKDaCmMZrjGxKiPihWNfWjwPeWTEpvJeW3qrUgigiMmidapPthKzmydWjq7EiGZwbIAaCcS3dPgWnHmgsAKaESrxNQ6eSgkaVyJVHeW3qrUgiUyJVHut6q2kqud9uOTowfy2JbvkKnaXfB8nKAshYwbIAONcTsdbHnYjQbVmQqbmMsbexSX3qQjDiBfiQHEk0sO80tVUw3ULsXgxeMXafCuswkpdexSX3qQjDiBfiQHEk0AVvoeRA62Tuk24IWmgOGJskMbIbIjdYaWt60bzgd2aCueEKd4JlGa(qfc4fB2dWDjGxIkxvekudexSX3qsHTgXGNKeQuD7wku3Ziq7E9OU5sMts5rDKNzRGqfThnKWWA1SsoE0Rni9OHegwRMvYXJE9HcLhsQ3CQuSDvTnrOjmS2CZLmNKYJ6ipZwbHkA6dRg5pimSwDZLmNKYJ6ipZwbHkA56yvG62MiaIl24BiPNcTSsPYfB8nYkxoDhLasH1KaXfB8nK0tHwwPu5In(gzLlNUJsaPGsjgmucexSX3qspfAzLsLl24BKvUC6okbKsTy3ULsXgxeMXafCuswkMciUyJVHKEk0YkLkxSX3iRC50Ducif50TBPuSXfHzmqbhLuVPaIl24BiPNcTSsPYfB8nYkxoDhLasryfHcymaXaXfB8nK6Ark2BthJ8EeaXfB8nK6Ar6PqlHYtp96AaXfB8nK6Ar6PqRvzCh5D7wkPDOq5Hh95eEm4jZmQCLIc1sLQHegwRoHhdEYmJkxP0TnrK8J0iDOOCpRPnRrIniw1KkfHH1QjUYJS9qmDuFyXMhegwR26rpEY8AZ2BLJ(WInuOwYaXfB8nK6Ar6PqRZWCSIkG4In(gsDTi9uOLTc4KLZEcaXfB8nK6Ar6PqRZWSQcg2TBPqyyTARh94jZRnBVvo6dl2KkvdjmSwT920XqFOq5HKSZvIqvECbmvQdfkp8OpNWJbpzMrLRupAiHH1Qt4XGNmZOYvk9HcLhsYoxjcv5XfqG4In(gsDTi9uO9QMxXKLKQJUD7wkY1qr4rtZwbIAYcyZNA8naIl24Bi11I0tHwb)U9K51MN9eWyaIl24Bi11I0tHwjvUD8OptAtGhqCXgFdPUwKEk0AVvo5yfvD7wkNrG296rD)5sf5zN5mf(yQRhhTcfHkQNIcfHQhnKWWA12BthdDBteaXfB8nK6Ar6PqR1pmtOk50TBPCgbA3Rh1nxYCskpQJ8mBfeQO9GTRQTjcnHH1MBUK5KuEuh5z2kiurtFy1i)bHH1QBUK5KuEuh5z2kiurlB9d1TnraexSX3qQRfPNcT1XQaZiDiPwPVr3ULIqfLMeBiRPO2JInUimJbk4OKSumThu3Ziq7E9OUxvmVuz7v9cymsG4In(gsDTi9uOfj2GyvdqCXgFdPUwKEk06mmRQGHD7wkNrG296rDVQyEPY2R6fWyKpMsHXOLKu(mE0NDg(yUseQYJlGuF)TgrlxlQjuE6PxxtFOq5HeiUyJVHuxlspfAtu(0TezuOM2C3ULYzeODVEu3RkMxQS9QEbmg5JPuymAjjLpJh9zNHaXfB8nK6Ar6PqR9w5qSQbigiUyJVHuZAskK2X3OB3sH0HIYR1M7znTZiplc9qMkfXkLpSEpvt(qHYdj1BkQbexSX3qQznj9uOTH1qfXEbcexSX3qQznj9uOvWVBpzET5zpbmMUDlLInUimJbk4OK6n1J0yB0m8rlDsuTb2YcLYzyQuY1qr4rtNOKdQQOLjDlPZXH8KbIl24Bi1SMKEk0EgbMxBM0MaVUDlf2UQ2Mi0oJ8Si0dP(qHYdjzn)8dcdRvFgbMxBM0MapDBteaXfB8nKAwtspfADg5zrOhYUDlfcdRvFgbMxBM0MapDBtepsJWWA1oJ8Si0dPUTjIuPMsHXOpJaZRntAtGxYpsJWWA1sLZOB2zOUTjIuPk24IWmgOGJsYs55KbIl24Bi1SMKEk0oUaMtuhPUDlLZiq7E9OEqbs7vQCI6i9GWWA1iDOQmKJVH2G0J0iDOO8AT5Ewt7mYZIqpKPsrSs5dR3t1KpuO8qs9Mi1sgiUyJVHuZAs6PqRHeZ(GcsG4In(gsnRjPNcTeQDBzRXroqCXgFdPM1K0tHwc8K4rxp6bIl24Bi1SMKEk0Q8EQgzMmJrRxaJbiUyJVHuZAs6PqR1pKqTBdiUyJVHuZAs6PqBfmuoxPYSsPaIl24Bi1SMKEk0su951MNZz0vcedetgKbGB64YIqHnaNazLHebCAuEqxA)u5cc4b4UeWlaNKQihpaNr16mudetgKbGxSX3qQfwrOagdfcLh0nxb5D7wkcRiuaJr3C5ubdjRzQbexSX3qQfwrOagd9uO1zy2Qwu2TBPqyyTANHzRArPUTjcG4In(gsTWkcfWyONcT1XQaZiDiPwPVr3ULIqfLMeBiRPO2JInUimJbk4OKSuEgiUyJVHulSIqbmg6PqR1pmtOk5aexSX3qQfwrOagd9uO1zywvbdbIbIl24Bi1YHIvzCh5D7wkPDOq5Hh95eEm4jZmQCLIc1sLQHegwRoHhdEYmJkxP0TnrK8J0iDOOCpRPnRrIniw1KkfHH1QjUYJS9qmDuFyXMhPr6qr5EwtBw3RkMxQSKKtxmvkshkk3ZAAZA7TYHyvZJ0OUSnAg(O9dZRnpuH5sYWOHTuPy7QABIqFvZRyYss1rx9HcLhYuPoJaT71JA7Hy6E0Nt4rtMCQuKouuUN10M1x18kMSKuD0nvkcdRvB9OhpzETz7TYrFyXgku7rAnKWWA1c(D7jZRnp7jGXOniLkfHH1QThIP7rFoHhnP2GuQuegwRgPdPkAyltAhmgVu6dl2KCYjdexSX3qQLd9uO1EB6yK3JaiUyJVHulh6PqlHYtp96AD7wkegwR2EiMUh95R8qBqkvQInUimJbk4OKSuEgiUyJVHulh6Pq7vKNxB2ERC62TuouO8WJ(Ccpg8KzgvUsrX8JgsyyT6eEm4jZmQCLsFOq5HeiUyJVHulh6PqBVQyEPYssoDXUDlLdfkp8OpNWJbpzMrLRupAiHH1Qt4XGNmZOYvk9HcLhsYYk5KhxaPFUseQYJlGaXfB8nKA5qpfADgMvvWWUDlLdfkp8OpNWJbpzMrLRupouO8WJ(Ccpg8KzgvUsrwcdRvB9OhpzETz7TYrFyXMhnKWWA1j8yWtMzu5kL(qHYdjzNReHQ84ciqCXgFdPwo0tHw2kGtwo7jaexSX3qQLd9uO1zyowrfqCXgFdPwo0tH2RAEftwsQo62TBPqyyTA7Hy6E0Nt4rtQni9OyJlcZyGcokPygiUyJVHulh6PqRZWSQcg2TBPqyyTARh94jZRnBVvo6dl2KkvdjmSwT920XqFOq5HKSZvIqvECbeiUyJVHulh6PqlsSbXQgG4In(gsTCONcTx18kMSKuD0TB3sjnQ7zeODVEuBpet3J(CcpAYuPk24IWmgOGJsYs55KFqyyTAIR8iBpeth1hwSbiUyJVHulh6PqRGF3EY8AZZEcymaXfB8nKA5qpfALu52XJ(mPnbED7wkegwR(mcmV2mPnbE62MiEKMCnueE0093kcZEiY73RgFJuPKRHIWJM26OQLxBMqTs5kitLQyJlcZyGcokjlLNtgiUyJVHulh6PqR9w5KJvu1TBPCgbA3Rh19NlvKNDMZu4JPUEC0kueQOEkkueQE0qcdRvBVnDm0TnraexSX3qQLd9uOTowfygPdj1k9n62TuoJaT71J6MlzojLh1rEMTccv0EW2v12eHMWWAZnxYCskpQJ8mBfeQOPpSAK)GWWA1nxYCskpQJ8mBfeQOLRJvbQBBIaiUyJVHulh6PqR1pmtOk50TBPCgbA3Rh1nxYCskpQJ8mBfeQO9GTRQTjcnHH1MBUK5KuEuh5z2kiurtFy1i)bHH1QBUK5KuEuh5z2kiurlB9d1TnraexSX3qQLd9uOTxvmVuzjjNUy3ULcHH1QjUYJS9qmDuFyXgG4In(gsTCONcT2BLdXQg4ahiea]] )


end
