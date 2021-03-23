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
    
    spec:RegisterPack( "Frost Mage", 20210323, [[dOuq2aqirQQhPkfBss6tIWOOO6uuuEfHywQcDlvrk7IKFHuAyirDmjXYuf1ZqImncjUMQizBQIOVjsvmovrW5iKuRdPQMhsvCpK0(aLCqcjzHivEOivMOQiKlIuLYgrQs1hrQs6KIuLwjfzMesDtvPKDck(PQivnuvrOwQQuQEkitvvYxvLszSQc2lI)kXGr1HLAXQQhJYKf1LH2mL(SKA0iHtlSAvrQ8AvPA2K62eSBQ(TsdhuDCKQelxLNt00vCDkSDc13frJhuQZJuSErkZxKSFGjviViq5Eqcmpt5NRqzk9mLuuwuxHsp1tGan0ahjqWB27DnsG8wajq073kha)T6AKabVPrVDM8IajxJJHeikMbUK(0sBDmuy8vSvGwziyO7jwNDTDOvgcmAjqFJqpPxN8jq5Eqcmpt5NRqzk9mLuuwuxHsp1ZeO2yOypceuiKocefroJo5tGYOKrGERUgbC69BLdW0B1hJca)zk9iG)mLFUcWeWu6OO9AusFGPNgG)eTEIbWdNPnYiGtNo83b8Wb83AfJcOpaUO6jw0aU5WxzmX6Hxd4HeWBahUUPbpapJSqgRBgW0tdWFR(DeWLRac4jSrnft5qHoCzcah95cuc4nC4AAa8zb8)kLaUnQPyKa(6AAueiDihj5fbkJ22qpKxeyQqErGqV)AmtOJaXUyWlAcu6d4NHJ29QrvoKSaUo8(OPWwbH2Zk07VgZaEvapJFdRvXA5eETYaoGxfWZ43WAvSwoHxRouOdxc40dGxbWtLcWz7QZBsx9nS2soKSaUo8(OPWwbH2ZQd7mnaEva)ByTQCizbCD49rtHTccTNl9XAhv5nPtGA2eRtGyRHp4jHJAnziW8m5fbc9(RXmHocuZMyDceR16sZMy9IoKdbshYP4TasGyzjziWqjYlce69xJzcDeOMnX6eiwR1LMnX6fDihcKoKtXBbKaHsj6musgcmIc5fbc9(RXmHoce7IbVOjqnBcXybDuiqjGdlQaoLiqnBI1jqSwRlnBI1l6qoeiDiNI3cibQxKmeyEkYlce69xJzcDei2fdErtGA2eIXc6OqGsaNEaCkrGA2eRtGyTwxA2eRx0HCiq6qofVfqcKCidbMNK8IaHE)1yMqhbQztSobI1ADPztSErhYHaPd5u8wajqcRyua9HmKHab)q2k87H8IatfYlcuZMyDcuFS2Xs4dQ1iBiqO3FnMj0rgcmptErGA2eRtGs2dEfuJcOpTMaHE)1yMqhziWqjYlce69xJzcDei2fdErtGA2eIXc6OqGsahwub8NjqnBI1jqFDKwA9LjdbgrH8IaHE)1yMqhbIDXGx0eOMnHySGokeOeWPc4viqnBI1jq2BLZF1dzidbQxK8IatfYlcuZMyDcK920qVS3NaHE)1yMqhziW8m5fbQztSob6RJ0sRVmbc9(RXmHoYqGHsKxei07VgZe6iqSlg8IMazoGFOqhE41LKHp4jlmkcTgWPc4ugWtLcWZ43WAvjdFWtwyueATkVjDa3maVkGBoGd)qXLAwwvrH)1)REa8uPa8VH1Q(xhEXEiMgQoSzdGxfW)gwRYgEnEYYAl2BLJ6WMnaovaNYaUzeOMnX6eiR24oAidbgrH8Ia1SjwNafmS4R4MaHE)1yMqhziW8uKxeOMnX6ei2kGtro7jqGqV)AmtOJmeyEsYlce69xJzcDei2fdErtG(gwRYgEnEYYAl2BLJ6WMnaEQuaEg)gwRYEBAORouOdxc4WcWNRfJ6YeciGNkfGFOqhE41LKHp4jlmkcTgWRc4z8ByTQKHp4jlmkcTwDOqhUeWHfGpxlg1LjeqcuZMyDcuWWIUDgsgcmPhYlce69xJzcDei2fdErtGKRH(hEwXwHFpfbmhtpX6k07VgZeOMnX6eORZr7trcVV3jdbMNa5fbQztSobsiUBpzzTLzpb0hce69xJzcDKHaJOM8Ia1SjwNajPiSt41f4Bs8iqO3FnMj0rgcmvOm5fbc9(RXmHoce7IbVOjqNHJ29Qrv9fsnnLGfmnQqV)Amd4vb8PVACuAumQbC6HkGRrXOgWRc4z8ByTk7TPHUkVjDcuZMyDcK9w5u8vCtgcmvQqErGqV)AmtOJaXUyWlAc0z4ODVAuLdjlGRdVpAkSvqO9Sc9(RXmGxfWz7QZBsx9nS2soKSaUo8(OPWwbH2ZQd7mnaEva)ByTQCizbCD49rtHTccTNl24qvEt6eOMnX6eiBCy5RB5qgcmvEM8IaHE)1yMqhbIDXGx0eiH2BfC2a4WcWPeLb8QaEZMqmwqhfcuc4WIkG)KaEvap9b8ZWr7E1OQw3SO1f711cOpsf69xJzcuZMyDcuFS2XccB46vgRtgcmvOe5fbQztSobc)R)x9qGqV)AmtOJmeyQikKxei07VgZe6iqSlg8IMaDgoA3Rgv16MfTUyVUwa9rQqV)Amd4vb8P1OpkjCDmt41LGHk07VgZaEvaFUwmQltiGao9a413A45sVO6RJ0sRVS6qHoCjbQztSobkyyr3odjdbMkpf5fbQztSobYERC(REiqO3FnMj0rgYqGyzj5fbMkKxei07VgZe6iqSlg8IMab)qXL1Al1SSky0ueJHlb8uPa8)kLaEva3g1umLdf6WLao9a4uIYeOMnX6ei47eRtgcmptErGA2eRtGYypu83Zrce69xJzcDKHadLiViqO3FnMj0rGyxm4fnbQztiglOJcbkbC6bWPeGxfWnhWzRNnIrjd4uSoMlcToyOc9(RXmGNkfGlxd9p8Skzlhu3EUa)w4xGdnk07VgZaUzeOMnX6eiH4U9KL1wM9eqFidbgrH8IaHE)1yMqhbIDXGx0ei2U68M0vbJMIymCP6qHoCjGdlaVYZaEva)ByTQZWXYAlW3K4PYBsNa1SjwNaDgowwBb(MepYqG5PiViqO3FnMj0rGyxm4fnb6ByTQZWXYAlW3K4PYBshWRc4Md4FdRvfmAkIXWLQ8M0b8uPa8P1OpQZWXYAlW3K4PqV)Amd4Mb4vbCZb8VH1QK6G9EjyOkVjDapvkaVztiglOJcbkbCyrfWFgWnJa1SjwNafmAkIXWLKHaZtsErGqV)AmtOJaXUyWlAc0z4ODVAunOa89ADjzFWvO3FnMb8Qa(3WAviSPOnKtSUYaoGxfWnhWHFO4YATLAwwfmAkIXWLaEQua(FLsaVkGBJAkMYHcD4saNEaCrHYaUzeOMnX6eOjeWsY(GtgcmPhYlcuZMyDcKHelXGcsce69xJzcDKHaZtG8Ia1SjwNa917MlwJJgce69xJzcDKHaJOM8Ia1SjwNa9XtI37HxtGqV)AmtOJmeyQqzYlcuZMyDcKoQPyKLNoJCTa6dbc9(RXmHoYqGPsfYlcuZMyDcKno8R3ntGqV)AmtOJmeyQ8m5fbQztSobQDgkNR1fwR1ei07VgZe6idbMkuI8Ia1SjwNa976YAlZfS3Lei07VgZe6idziqYH8IatfYlce69xJzcDei2fdErtGmhWpuOdp86sYWh8KfgfHwd4ubCkd4Psb4z8ByTQKHp4jlmkcTwL3KoGBgGxfWnhWHFO4snlRQOW)6)vpaEQua(3WAv)RdVypetdvh2SbWRc4Md4WpuCPMLvvu16MfTUiHhVJaEQuao8dfxQzzvfL9w58x9a4vbCZb80hWzRNnIrfhwwBzOalTKHEgZk07VgZaEQuaoBxDEt6QRZr7trcVV3vhk0Hlb8uPa8ZWr7E1OYEiMw41LKHNLk07VgZaUzaEQuao8dfxQzzvf115O9PiH337aEQua(3WAv2WRXtwwBXERCuh2SbWPc4ugWRc4Md4z8ByTkH4U9KL1wM9eqFugWb8uPa8VH1QShIPfEDjz4zPYaoGNkfG)nSwfcB4TNXCb(oOprRvh2SbWndWndWnJa1SjwNaz1g3rdziW8m5fbQztSobYEBAOx27tGqV)AmtOJmeyOe5fbc9(RXmHoce7IbVOjqFdRvzpetl86Y1HRmGd4Psb4nBcXybDuiqjGdlQa(ZeOMnX6eOVoslT(YKHaJOqErGqV)AmtOJaXUyWlAc0HcD4Hxxsg(GNSWOi0AaNkGxbWRc4z8ByTQKHp4jlmkcTwDOqhUKa1SjwNaDnnL1wS3khYqG5PiViqO3FnMj0rGyxm4fnb6qHo8WRljdFWtwyueAnGxfWZ43WAvjdFWtwyueAT6qHoCjGdlaN1YPmHac4Ia4Z1IrDzcbKa1SjwNavRBw06IeE8osgcmpj5fbc9(RXmHoce7IbVOjqhk0HhEDjz4dEYcJIqRb8Qa(HcD4Hxxsg(GNSWOi0Aahwa(3WAv2WRXtwwBXERCuh2SbWRc4z8ByTQKHp4jlmkcTwDOqhUeWHfGpxlg1LjeqcuZMyDcuWWIUDgsgcmPhYlcuZMyDceBfWPiN9eiqO3FnMj0rgcmpbYlcuZMyDcuWWIVIBce69xJzcDKHaJOM8IaHE)1yMqhbIDXGx0eOVH1QShIPfEDjz4zPYaoGxfWB2eIXc6OqGsaNkGxHa1SjwNaDDoAFks499oziWuHYKxei07VgZe6iqSlg8IMa9nSw1)6Wl2dX0q1HnBa8Qa(0A0hvTUzrRls4X7Oc9(RXmGxfWzRNnIrfhwwBzOalTKHEgZk07VgZaEva)ByTQGfmnkvYPzVd4WIkGlkeOMnX6eORZr7trcVV3jdbMkviViqO3FnMj0rGyxm4fnb6ByTkB414jlRTyVvoQdB2a4Psb4z8ByTk7TPHU6qHoCjGdlaFUwmQltiGeOMnX6eOGHfD7mKmeyQ8m5fbQztSobc)R)x9qGqV)AmtOJmeyQqjYlce69xJzcDei2fdErtGmhWtFaFAn6JQw3SO1fj84DuHE)1ygWtLcWtFaNTE2igvCyzTLHcS0sg6zmRqV)Amd4Mb4vbCZb80hWpdhT7vJk7HyAHxxsgEwQqV)Amd4Psb4nBcXybDuiqjGdlQa(ZaUzaEva)ByTQ)1HxShIPHQdB2qGA2eRtGUohTpfj8(ENmeyQikKxeOMnX6eiH4U9KL1wM9eqFiqO3FnMj0rgcmvEkYlce69xJzcDei2fdErtG(gwR6mCSS2c8njEQ8M0b8QaU5aUCn0)WZQ6BfJLWfh171tSUc9(RXmGNkfGlxd9p8SYgOoxwB5RxPCfKk07VgZaEQua(z4ODVAuzpetl86sYWZsf69xJzaVkG)nSwL9qmTWRljdplv5nPd4Psb4nBcXybDuiqjGdlQa(ZaUzeOMnX6eijfHDcVUaFtIhziWu5jjViqO3FnMj0rGyxm4fnb6mC0UxnQQVqQPPeSGPrf69xJzaVkGp9vJJsJIrnGtpubCnkg1aEvapJFdRvzVnn0v5nPtGA2eRtGS3kNIVIBYqGPs6H8IaHE)1yMqhbIDXGx0eOZWr7E1OkhswaxhEF0uyRGq7zf69xJzaVkGZ2vN3KU6ByTLCizbCD49rtHTccTNvh2zAa8Qa(3WAv5qYc46W7JMcBfeApx6J1oQYBsNa1SjwNa1hRDSGWgUELX6KHatLNa5fbc9(RXmHoce7IbVOjqNHJ29QrvoKSaUo8(OPWwbH2Zk07VgZaEvaNTRoVjD13WAl5qYc46W7JMcBfeApRoSZ0a4vb8VH1QYHKfW1H3hnf2ki0EUyJdv5nPtGA2eRtGSXHLVULdziWurutErGqV)AmtOJaXUyWlAc03WAv)RdVypetdvh2SHa1SjwNavRBw06IeE8osgcmptzYlcuZMyDcK9w58x9qGqV)AmtOJmKHajSIrb0hYlcmviViqO3FnMj0rGyxm4fnb6ByTQGHfRErPkVjDcuZMyDcuWWIvVOKmeyEM8IaHE)1yMqhbIDXGx0eiH2BfC2a4WcWPeLb8QaEZMqmwqhfcuc4WIkG)mbQztSobQpw7ybHnC9kJ1jdbgkrErGA2eRtGSXHLVULdbc9(RXmHoYqGruiViqnBI1jqbdl62zibc9(RXmHoYqgYqGeJNmwNaZZu(5kuMsve1eOK95HxljqVnr1BhM0lm0R0hWb8xuGaEiaFVbWT7b4jYOTn0tca)q6fJ4WmGlxbeWBJzf6bZaoJI2RrPcys0HJaEf6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmbm92evVDysVWqVsFahWFrbc4Ha89ga3UhGNOxmbGFi9IrCygWLRac4TXSc9GzaNrr71Oubmj6Wrap9qFapDRlgVbZaEc5AO)HNvpKaWNfWtixd9p8S6bf69xJ5eaEpao92tVObCZRaBZuatIoCeWRqz6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmj6WraVsf6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmj6WraVYZ0hWt36IXBWmGN4mC0UxnQEibGplGN4mC0UxnQEqHE)1yobG3dGtV90lAa38kW2mfWKOdhb8kIc9b80TUy8gmd4jMwJ(OEibGplGNyAn6J6bf69xJ5eaU5vGTzkGjrhoc4vef6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmbm92evVDysVWqVsFahWFrbc4Ha89ga3UhGNGLLja8dPxmIdZaUCfqaVnMvOhmd4mkAVgLkGjrhoc4uI(aE6wxmEdMb8eS1ZgXOEibGplGNGTE2ig1dk07VgZjaCZRaBZuatIoCeWPe9b80TUy8gmd4jKRH(hEw9qcaFwapHCn0)WZQhuO3FnMta4Mxb2MPaMeD4iG)u0hWt36IXBWmGNyAn6J6Hea(SaEIP1OpQhuO3FnMta4Mxb2MPaMeD4iG)K0hWt36IXBWmGN4mC0UxnQEibGplGN4mC0UxnQEqHE)1yobGBEfyBMcycy6TjQE7WKEHHEL(aoG)IceWdb47naUDpapHCsa4hsVyehMbC5kGaEBmRqpygWzu0EnkvatIoCeWRqFapDRlgVbZaEIZWr7E1O6Hea(SaEIZWr7E1O6bf69xJ5eaU5vGTzkGjrhoc4vOpGNU1fJ3GzapbB9SrmQhsa4Zc4jyRNnIr9Gc9(RXCca38kW2mfWKOdhb8kuM(aE6wxmEdMb8etRrFupKaWNfWtmTg9r9Gc9(RXCca38kW2mfWKOdhb8kuM(aE6wxmEdMb8eS1ZgXOEibGplGNGTE2ig1dk07VgZjaCZRaBZuatIoCeWRqj6d4PBDX4nygWtmTg9r9qcaFwapX0A0h1dk07VgZjaCZRaBZuatIoCeWRqj6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmj6WraVcLOpGNU1fJ3GzapbB9SrmQhsa4Zc4jyRNnIr9Gc9(RXCca38kW2mfWKOdhb8kpf9b80TUy8gmd4jodhT7vJQhsa4Zc4jodhT7vJQhuO3FnMta4Mxb2MPaMeD4iGx5POpGNU1fJ3GzapHCn0)WZQhsa4Zc4jKRH(hEw9Gc9(RXCca38NHTzkGjrhoc4vEs6d4PBDX4nygWtCgoA3RgvpKaWNfWtCgoA3RgvpOqV)AmNaWnVcSntbmj6WraVs6H(aE6wxmEdMb8eNHJ29Qr1dja8zb8eNHJ29Qr1dk07VgZjaCZRaBZuatIoCeWR8eOpGNU1fJ3GzapXz4ODVAu9qcaFwapXz4ODVAu9Gc9(RXCca38kW2mfWeWu6va(EdMb8NeWB2eRd46qosfWebc(T2qJeO38ga)T6AeWP3VvoatV5na(B1hJca)zk9iG)mLFUcWeW0BEdGNokAVgL0hy6nVbWFAa(t06jgapCM2iJaoD6WFhWdhWFRvmkG(a4IQNyrd4MdFLXeRhEnGhsaVbC46Mg8a8mYczSUzatV5na(tdWFR(DeWLRac4jSrnft5qHoCzcah95cuc4nC4AAa8zb8)kLaUnQPyKa(6AAuatatV5nao9gSrMXGza)J29qaNTc)Ea8pwhUub4IkgdHpsa3x)PrrFcwdnG3Sjwxc4RRPrbm1SjwxQGFiBf(9icvA7J1owcFqTgzdWuZMyDPc(HSv43JiuPvAiiSEjzp4vqnkG(0AGPMnX6sf8dzRWVhrOs7xhPLwF5hdl1MnHySGokeOewuFgyQztSUub)q2k87reQ0AVvo)vppgwQnBcXybDuiqj1katatV5nao9gSrMXGzahfJhna(eciGpuGaEZM9a8qc4T4o09xJkGPMnX6sQS1Wh8KWrT(XWsn9pdhT7vJQCizbCD49rtHTccTNRMXVH1QyTCcVwzaVAg)gwRI1Yj8A1HcD4s6PsQuSD15nPR(gwBjhswaxhEF0uyRGq7z1HDMMQFdRvLdjlGRdVpAkSvqO9CPpw7OkVjDGPMnX6srOslR16sZMy9IoKZJElGuzzjWuZMyDPiuPL1ADPztSErhY5rVfqQOuIodLatnBI1LIqLwwR1LMnX6fDiNh9waP2l(yyP2SjeJf0rHaLWIkLaMA2eRlfHkTSwRlnBI1l6qop6TasvopgwQnBcXybDuiqj9qjGPMnX6srOslR16sZMy9IoKZJElGufwXOa6dWeWuZMyDPQxKQ920qVS3hyQztSUu1lkcvA)6iT06ldm1SjwxQ6ffHkTwTXD08yyPA(HcD4Hxxsg(GNSWOi0AQuovQm(nSwvYWh8KfgfHwRYBs3SQMd)qXLAwwvrH)1)REsL6ByTQ)1HxShIPHQdB2u9ByTkB414jlRTyVvoQdB2qLYMbm1SjwxQ6ffHkTbdl(kUbMA2eRlv9IIqLw2kGtro7jam1SjwxQ6ffHkTbdl62z4JHL63WAv2WRXtwwBXERCuh2SjvQm(nSwL920qxDOqhUewZ1IrDzcbmvQdf6WdVUKm8bpzHrrO1vZ43WAvjdFWtwyueAT6qHoCjSMRfJ6YeciWuZMyDPQxueQ0EDoAFks499(JHLQCn0)WZk2k87PiG5y6jwhyQztSUu1lkcvAfI72twwBz2ta9byQztSUu1lkcvALue2j86c8njEatnBI1LQErrOsR9w5u8vC)yyPEgoA3Rgv1xi10ucwW0y1PVACuAumQPhQAumQRMXVH1QS3Mg6Q8M0bMA2eRlv9IIqLwBCy5RB58yyPEgoA3Rgv5qYc46W7JMcBfeApxLTRoVjD13WAl5qYc46W7JMcBfeApRoSZ0u9ByTQCizbCD49rtHTccTNl24qvEt6atnBI1LQErrOsBFS2XccB46vgR)yyPk0ERGZgyrjkxTztiglOJcbkHf1NSA6FgoA3Rgv16MfTUyVUwa9rcm1SjwxQ6ffHkT4F9)QhGPMnX6svVOiuPnyyr3odFmSupdhT7vJQADZIwxSxxlG(iRoTg9rjHRJzcVUemS6CTyuxMqaPN6Bn8CPxu91rAP1xwDOqhUey6nVbWB2eRlv9IIqL2KDmpkrgvkRQ8yyPEgoA3Rgv16MfTUyVUwa9rwDAn6JscxhZeEDjyiWuZMyDPQxueQ0AVvo)vpatatnBI1Lkwwsf(oX6pgwQWpuCzT2snlRcgnfXy4YuP(Ruw1g1umLdf6WL0dLOmWuZMyDPILLIqL2m2df)9CeyQztSUuXYsrOsRqC3EYYAlZEcOppgwQnBcXybDuiqj9qPQMZwpBeJsgWPyDmxeADWWuPKRH(hEwLSLdQBpxGFl8lWHgZaMA2eRlvSSueQ0EgowwBb(MeVhdlv2U68M0vbJMIymCP6qHoCjSQ8C1VH1QodhlRTaFtINkVjDGPMnX6sfllfHkTbJMIymC5JHL63WAvNHJL1wGVjXtL3KEvZ)gwRky0ueJHlv5nPNk10A0h1z4yzTf4Bs8mRQ5FdRvj1b79sWqvEt6Ps1SjeJf0rHaLWI6ZMbm1SjwxQyzPiuPDcbSKSp4pgwQNHJ29Qr1GcW3R1LK9bV63WAviSPOnKtSUYaEvZHFO4YATLAwwfmAkIXWLPs9xPSQnQPykhk0HlPhrHYMbm1SjwxQyzPiuP1qILyqbjWuZMyDPILLIqL2VE3CXAC0am1SjwxQyzPiuP9JNeV3dVgyQztSUuXYsrOsRoQPyKLNoJCTa6dWuZMyDPILLIqLwBC4xVBgyQztSUuXYsrOsB7muoxRlSwRbMA2eRlvSSueQ0(76YAlZfS3LatatV5na(tui7VgZa(hzTHebC60H)oTquecc4b4HeWBahUUPbpaNrXgmubm9M3a4nBI1LkHvmkG(q9Rd)9s708yyPkSIrb0hvoKt7mewvOmWuZMyDPsyfJcOpIqL2GHfREr5JHL63WAvbdlw9IsvEt6atnBI1LkHvmkG(icvA7J1owqydxVYy9hdlvH2BfC2alkr5QnBcXybDuiqjSO(mWuZMyDPsyfJcOpIqLwBCy5RB5am1SjwxQewXOa6JiuPnyyr3odbMaMA2eRlvYHQvBChnpgwQMFOqhE41LKHp4jlmkcTMkLtLkJFdRvLm8bpzHrrO1Q8M0nRQ5WpuCPMLvvu4F9)QNuP(gwR6FD4f7HyAO6WMnvnh(HIl1SSQIQw3SO1fj84Dmvk4hkUuZYQkk7TY5V6PQ5PpB9SrmQ4WYAldfyPLm0Zyovk2U68M0vxNJ2NIeEFVRouOdxMk1z4ODVAuzpetl86sYWZsZsLc(HIl1SSQI66C0(uKW779uP(gwRYgEnEYYAl2BLJ6WMnuPCvZZ43WAvcXD7jlRTm7jG(OmGNk13WAv2dX0cVUKm8SuzapvQVH1QqydV9mMlW3b9jAT6WMnMzMzatnBI1Lk5icvAT3Mg6L9(atnBI1Lk5icvA)6iT06l)yyP(nSwL9qmTWRlxhUYaEQunBcXybDuiqjSO(mWuZMyDPsoIqL2RPPS2I9w58yyPEOqhE41LKHp4jlmkcTMALQz8ByTQKHp4jlmkcTwDOqhUeyQztSUujhrOsBTUzrRls4X74JHL6HcD4Hxxsg(GNSWOi06Qz8ByTQKHp4jlmkcTwDOqhUewSwoLjeqrMRfJ6YeciWuZMyDPsoIqL2GHfD7m8XWs9qHo8WRljdFWtwyueAD1df6WdVUKm8bpzHrrO1W6ByTkB414jlRTyVvoQdB2unJFdRvLm8bpzHrrO1Qdf6WLWAUwmQltiGatnBI1Lk5icvAzRaof5SNaWuZMyDPsoIqL2GHfFf3atnBI1Lk5icvAVohTpfj8(E)XWs9ByTk7HyAHxxsgEwQmGxTztiglOJcbkPwbyQztSUujhrOs715O9PiH337pgwQFdRv9Vo8I9qmnuDyZMQtRrFu16MfTUiHhVJvzRNnIrfhwwBzOalTKHEgZv)gwRkybtJsLCA27WIQOam1SjwxQKJiuPnyyr3odFmSu)gwRYgEnEYYAl2BLJ6WMnPsLXVH1QS3Mg6Qdf6WLWAUwmQltiGatnBI1Lk5icvAX)6)vpatnBI1Lk5icvAVohTpfj8(E)XWs180FAn6JQw3SO1fj84DmvQ0NTE2igvCyzTLHcS0sg6zmBwvZt)ZWr7E1OYEiMw41LKHNLPs1SjeJf0rHaLWI6ZMv9ByTQ)1HxShIPHQdB2am1SjwxQKJiuPviUBpzzTLzpb0hGPMnX6sLCeHkTskc7eEDb(MeVhdl1VH1QodhlRTaFtINkVj9QMlxd9p8SQ(wXyjCXr9E9eRNkLCn0)WZkBG6CzTLVELYvqMk1z4ODVAuzpetl86sYWZYQFdRvzpetl86sYWZsvEt6Ps1SjeJf0rHaLWI6ZMbm1SjwxQKJiuP1ERCk(kUFmSupdhT7vJQ6lKAAkblyAS60xnoknkg10dvnkg1vZ43WAv2BtdDvEt6atnBI1Lk5icvA7J1owqydxVYy9hdl1ZWr7E1OkhswaxhEF0uyRGq75QSD15nPR(gwBjhswaxhEF0uyRGq7z1HDMMQFdRvLdjlGRdVpAkSvqO9CPpw7OkVjDGPMnX6sLCeHkT24WYx3Y5XWs9mC0UxnQYHKfW1H3hnf2ki0EUkBxDEt6QVH1wYHKfW1H3hnf2ki0EwDyNPP63WAv5qYc46W7JMcBfeApxSXHQ8M0bMA2eRlvYreQ0wRBw06IeE8o(yyP(nSw1)6Wl2dX0q1HnBaMA2eRlvYreQ0AVvo)vpeijCKrG5jffYqgcba]] )


end
