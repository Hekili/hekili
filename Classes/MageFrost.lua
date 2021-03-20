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
    
    spec:RegisterPack( "Frost Mage", 20210319, [[dOus3aqijP4rGs1MaWNOqJse6uIeVIaMfa5wssL2fr)cPYWqkCmr0YaOEgsvnncKUMiiBtsk9nqPyCssvDocewhsvMhsrDpKyFGIoOiOSqKspueyIIGQUOKuLnsGO(isrYjLKkwjfmtcu3eukTta1pfbvgksrOLIue9uqMkG8vcezSss2lI)kXGr1HLAXa9yuMSOUm0MP0NLuJgj50cRgPi41GsMnPUnH2nv)wPHdQoosrQLRYZjz6kUofTDc67IuJhu48iPwViP5lj2VQMKKaebk3dsagW0aWjPb9tkiKaM(jeSjj9jqd1Wrce8MbRUgjqElIeib5BvZZHTDnsGG3uR3otaIaPwZJHeiQMbUIE0rxDmuzckzRiDQq0u3tSo7A7qNkez0rGand9uDCcibk3dsagW0aWjPb9tkiKaM(jeSHgjebQnhQ2JabfIjGarvKZOtajqzuXiqW2UgFUG8TQ5naB7Jr1Ztkia0ZbmnaCY3WBibu1EnQO3BO6(8e(1noppCM2mJpNwD4W65H)Cy7kefrFEEcJMOGFEIWxvmX6Hx)8q98(5W1n1498mYcvSEkVHQ7ZHTnSWNRwr85gTrnvt5qXoCLXNJ(CbQEEdhUM6Np7ZbxL652OMQr9811uljq6qnkcqeOmABt9qaIaCscqei0BqnMj0sGyxm4fnbQAE(z6ODVAuMdflGRdVpQlSvuS9Se9guJ5NdWZZiOP1kzTAcVwAc)5a88mcAATswRMWRLhk2HREon)8KpVsLNZ2vN30Ue00Al5qXc46W7J6cBffBplpSZu)CaEoOP1kZHIfW1H3h1f2kk2EU0hRDuM30obQztSobITM(GNcoQ1KHamGjarGqVb1yMqlbQztSobI1ADPztSErhQHaPd1u8wejqSSImeGPpbice6nOgZeAjqnBI1jqSwRlnBI1l6qneiDOMI3Iibcvk0zOImeGfucqei0BqnMj0sGyxm4fnbQztielOJIbQEomP8C6tGA2eRtGyTwxA2eRx0HAiq6qnfVfrcuViziaNqeGiqO3GAmtOLaXUyWlAcuZMqiwqhfdu9CA(50Na1SjwNaXATU0SjwVOd1qG0HAkElIei1qgcWvlbice6nOgZeAjqnBI1jqSwRlnBI1l6qneiDOMI3IibsCfIIOpKHmei4hYwrWEiaraojbicuZMyDcuFS2Xs4dQ1iBiqO3GAmtOLmeGbmbicuZMyDcu6EWRGAue9P1ei0BqnMj0sgcW0Naebc9guJzcTei2fdErtGA2ecXc6OyGQNdtkphWeOMnX6eiqDKAQ9LjdbybLaebc9guJzcTei2fdErtGA2ecXc6OyGQNt55jjqnBI1jq2Bvd4QhYqgcuVibicWjjarGA2eRtGS3Mk6L9ajqO3GAmtOLmeGbmbicuZMyDceOosn1(Yei0BqnMj0sgcW0Naebc9guJzcTei2fdErtGs85hk2HhEDjD4dEQcJQqRFoLNtJNxPYZZiOP1kth(GNQWOk0AzEt7ppLNdWZt85WpuyPMLLjLi46GREEELkph00ALGxhEXEiMkkpSzZZb45GMwR0gEnEQYAl2BvJ8WMnpNYZPXZtHa1SjwNaz1M3rnzialOeGiqnBI1jqbdl(kSjqO3GAmtOLmeGticqeOMnX6ei2kItrn7jsGqVb1yMqlziaxTeGiqO3GAmtOLaXUyWlAceOP1kTHxJNQS2I9w1ipSzZZRu55ze00AL2BtfD5HID4QNdZNpxle1LjeXNxPYZpuSdp86s6Wh8ufgvHw)CaEEgbnTwz6Wh8ufgvHwlpuSdx9Cy(85AHOUmHisGA2eRtGcgw0TZqYqag2qaIaHEdQXmHwce7IbVOjqQ1udgEwYwrWEkIyoMEI1LO3GAmtGA2eRtGUohTpff8(Gfziax9jarGA2eRtGeJ72tvwBz2te9HaHEdQXmHwYqawqqaIa1SjwNaPOkSt41f4BA8iqO3GAmtOLmeGtsdcqei0BqnMj0sGyxm4fnb6mD0UxnkRVqPPUeSGPrj6nOgZphGNp9vJJuJcr9ZPzkpxJcr9Zb45ze00AL2BtfDzEt7eOMnX6ei7TQP4RWMmeGtMKaebc9guJzcTei2fdErtGothT7vJYCOybCD49rDHTIITNLO3GAm)CaEoBxDEt7sqtRTKdflGRdVpQlSvuS9S8Wot9Zb45GMwRmhkwaxhEFuxyROy75InouM30obQztSobYghwa1TAidb4KaMaebc9guJzcTei2fdErtGeBVLWzZZH5ZPpnEoapVztielOJIbQEomP88Q95a88Q55NPJ29QrzTUzrRl2RRfrFus0BqnMjqnBI1jq9XAhlimGRxvSoziaNK(eGiqnBI1jqi46GREiqO3GAmtOLmeGtkOeGiqO3GAmtOLaXUyWlAc0z6ODVAuwRBw06I96Ar0hLe9guJ5NdWZNwJ(ivW1XmHxxcgkrVb1y(5a885AHOUmHi(CA(513A65sVOeuhPMAFz5HID4kcuZMyDcuWWIUDgsgcWjticqei0BqnMj0sGuiJardzscuZMyDcu6ogce7IbVOjqNPJ29QrzTUzrRl2RRfrFus0BqnMFoapFAn6JubxhZeEDjyOe9guJzYqaoz1saIa1SjwNazVvnGREiqO3GAmtOLmKHaXYkcqeGtsaIaHEdQXmHwce7IbVOjqWpuyzT2snlldg1fHy4QNxPYZbxL65a8CBut1uouSdx9CA(50NgeOMnX6ei47eRtgcWaMaebQztSobkJ9qf4EosGqVb1yMqlziatFcqei0BqnMj0sGyxm4fnbQztielOJIbQEon)C6)CaEEIpNTE2mgPkGt16yUi26GHs0BqnMFELkpxTMAWWZY0TAqD75c8BHFboulrVb1y(5PqGA2eRtGeJ72tvwBz2te9HmeGfucqei0BqnMj0sGyxm4fnbITRoVPDzWOUiedxjpuSdx9Cy(8Ka(5a8CqtRvEMowwBb(MgpzEt7eOMnX6eOZ0XYAlW304rgcWjebice6nOgZeAjqSlg8IMabAATYZ0XYAlW304jZBA)5a88eFoOP1kdg1fHy4kzEt7pVsLNpTg9rEMowwBb(Mgpj6nOgZppLNdWZt85GMwRuPdgSkbdL5nT)8kvEEZMqiwqhfdu9Cys55a(5PqGA2eRtGcg1fHy4kYqaUAjarGqVb1yMqlbIDXGx0eOZ0r7E1OCqr4716s6(GlrVb1y(5a8CqtRvIWGQ2unX6st4phGNN4ZHFOWYATLAwwgmQlcXWvpVsLNdUk1Zb452OMQPCOyhU6508ZfuA88uiqnBI1jqtiIL09bNmeGHneGiqnBI1jqMkSedkQiqO3GAmtOLmeGR(eGiqnBI1jqG6DZfR5rnbc9guJzcTKHaSGGaebQztSobcepfEWk8Ace6nOgZeAjdb4K0GaebQztSobsh1unQcnbZCTi6dbc9guJzcTKHaCYKeGiqnBI1jq24qq9Uzce6nOgZeAjdb4KaMaebQztSobQDgQMR1fwR1ei0BqnMj0sgcWjPpbicuZMyDceyxxwBzUGblfbc9guJzcTKHmei1qaIaCscqei0BqnMj0sGyxm4fnbkXNFOyhE41L0Hp4PkmQcT(5uEonEELkppJGMwRmD4dEQcJQqRL5nT)8uEoappXNd)qHLAwwMuIGRdU655vQ8CqtRvcED4f7HyQO8WMnphGNN4ZHFOWsnlltkR1nlADrbpGf(8kvEo8dfwQzzzsP9w1aU655a88eFE18C26zZyKXHL1wgQWsRyONXSe9guJ5NxPYZz7QZBAxEDoAFkk49bl5HID4QNxPYZpthT7vJs7HyQHxxshEwjrVb1y(5P88kvEo8dfwQzzzs515O9POG3hSEELkph00AL2WRXtvwBXERAKh2S55uEonEoappXNNrqtRvkg3TNQS2YSNi6J0e(ZRu55GMwR0EiMA41L0HNvst4pVsLNdAATsegWBpJ5c8DqFIwlpSzZZt55P88uiqnBI1jqwT5DutgcWaMaebQztSobYEBQOx2dKaHEdQXmHwYqaM(eGiqO3GAmtOLaXUyWlAceOP1kThIPgED56WLMWFELkpVztielOJIbQEomP8CatGA2eRtGa1rQP2xMmeGfucqei0BqnMj0sGyxm4fnb6qXo8WRlPdFWtvyufA9ZP88KphGNNrqtRvMo8bpvHrvO1Ydf7WveOMnX6eORPUS2I9w1qgcWjebice6nOgZeAjqSlg8IMaDOyhE41L0Hp4PkmQcT(5a88mcAATY0Hp4PkmQcTwEOyhU65W85SwnLjeXNlWZNRfI6YeIibQztSobQw3SO1ff8awiziaxTeGiqO3GAmtOLaXUyWlAc0HID4Hxxsh(GNQWOk06NdWZpuSdp86s6Wh8ufgvHw)Cy(CqtRvAdVgpvzTf7TQrEyZMNdWZZiOP1kth(GNQWOk0A5HID4QNdZNpxle1LjercuZMyDcuWWIUDgsgcWWgcqeOMnX6ei2kItrn7jsGqVb1yMqlziax9jarGA2eRtGcgw8vytGqVb1yMqlzialiiarGqVb1yMqlbIDXGx0eiqtRvApetn86s6WZkPj8NdWZB2ecXc6OyGQNt55jjqnBI1jqxNJ2NIcEFWImeGtsdcqei0BqnMj0sGyxm4fnbc00ALGxhEXEiMkkpSzZZb45tRrFK16MfTUOGhWcLO3GAm)CaEoB9SzmY4WYAldvyPvm0ZywIEdQX8Zb45GMwRmybtJkPAAgSEomP8CbLa1SjwNaDDoAFkk49blYqaozscqei0BqnMj0sGyxm4fnbc00AL2WRXtvwBXERAKh2S55vQ88mcAATs7TPIU8qXoC1ZH5ZNRfI6YeIibQztSobkyyr3odjdb4KaMaebQztSobcbxhC1dbc9guJzcTKHaCs6taIaHEdQXmHwce7IbVOjqj(8Q55tRrFK16MfTUOGhWcLO3GAm)8kvEE18C26zZyKXHL1wgQWsRyONXSe9guJ5NNYZb45j(8Q55NPJ29QrP9qm1WRlPdpRKO3GAm)8kvEEZMqiwqhfdu9Cys55a(5P8CaEoOP1kbVo8I9qmvuEyZgcuZMyDc015O9POG3hSidb4KckbicuZMyDcKyC3EQYAlZEIOpei0BqnMj0sgcWjticqei0BqnMj0sGyxm4fnbc00ALNPJL1wGVPXtM30(Zb45j(C1AQbdplRVviwcxyuVxpX6s0BqnMFELkpxTMAWWZsBG6CzTfq9QuROsIEdQX8ZRu55NPJ29QrP9qm1WRlPdpRKO3GAm)CaEoOP1kThIPgEDjD4zLmVP9NxPYZB2ecXc6OyGQNdtkphWppfcuZMyDcKIQWoHxxGVPXJmeGtwTeGiqO3GAmtOLaXUyWlAc0z6ODVAuwFHstDjybtJs0BqnMFoapF6RghPgfI6NtZuEUgfI6NdWZZiOP1kT3Mk6Y8M2jqnBI1jq2BvtXxHnziaNe2qaIaHEdQXmHwce7IbVOjqNPJ29QrzouSaUo8(OUWwrX2Zs0BqnMFoapNTRoVPDjOP1wYHIfW1H3h1f2kk2EwEyNP(5a8CqtRvMdflGRdVpQlSvuS9CPpw7OmVPDcuZMyDcuFS2Xccd46vfRtgcWjR(eGiqO3GAmtOLaXUyWlAc0z6ODVAuMdflGRdVpQlSvuS9Se9guJ5NdWZz7QZBAxcAATLCOybCD49rDHTIITNLh2zQFoaph00AL5qXc46W7J6cBffBpxSXHY8M2jqnBI1jq24WcOUvdziaNuqqaIaHEdQXmHwce7IbVOjqGMwRe86Wl2dXur5HnBiqnBI1jq16MfTUOGhWcjdbyatdcqeOMnX6ei7TQbC1dbc9guJzcTKHmeiXvikI(qaIaCscqei0BqnMj0sGyxm4fnbc00ALbdlw9IkzEt7eOMnX6eOGHfRErfziadycqei0BqnMj0sGyxm4fnbsS9wcNnphMpN(045a88MnHqSGokgO65WKYZbmbQztSobQpw7ybHbC9QI1jdby6taIa1SjwNazJdlG6wnei0BqnMj0sgcWckbicuZMyDcuWWIUDgsGqVb1yMqlzidziqcXtfRtagW0aWjPb9tcBiqP7ZdVwrGeKsy0KaxDaMMIEp)5arf(8qe(EZZT79CJz02M6X4ZpKM2mom)C1kIpVnNvShm)CgvTxJk5BqWHJppj9EEcwxiEdMFUXZ0r7E1OSkJpF2NB8mD0UxnkRsIEdQXSXNNysyKI8n8geKsy0KaxDaMMIEp)5arf(8qe(EZZT79CJ9IgF(H00MXH5NRwr85T5SI9G5NZOQ9AujFdcoC85Wg698eSUq8gm)CJQ1udgEwwLXNp7ZnQwtny4zzvs0BqnMn(8EEE1lHtWppXKWif5BqWHJppjnO3ZtW6cXBW8ZnEMoA3RgLvz85Z(CJNPJ29Qrzvs0BqnMn(8etcJuKVbbho(8KjP3ZtW6cXBW8ZnEMoA3RgLvz85Z(CJNPJ29Qrzvs0BqnMn(8etcJuKVbbho(8KaMEppbRleVbZp34z6ODVAuwLXNp7ZnEMoA3RgLvjrVb1y24Z755vVeob)8etcJuKVbbho(8Kck9EEcwxiEdMFUXP1OpYQm(8zFUXP1OpYQKO3GAmB85jMegPiFdcoC85jfu698eSUq8gm)CJNPJ29QrzvgF(Sp34z6ODVAuwLe9guJzJppXKWif5BqWHJppzcrVNNG1fI3G5NBCAn6JSkJpF2NBCAn6JSkj6nOgZgFEppV6LWj4NNysyKI8ni4WXNNmHO3ZtW6cXBW8ZnEMoA3RgLvz85Z(CJNPJ29Qrzvs0BqnMn(8etcJuKVH3GGucJMe4QdW0u075phiQWNhIW3BEUDVNBKLvgF(H00MXH5NRwr85T5SI9G5NZOQ9AujFdcoC850NEppbRleVbZp3iB9SzmYQm(8zFUr26zZyKvjrVb1y24Ztmjmsr(geC44ZPp9EEcwxiEdMFUr1AQbdplRY4ZN95gvRPgm8SSkj6nOgZgFEIjHrkY3GGdhFEcrVNNG1fI3G5NBCAn6JSkJpF2NBCAn6JSkj6nOgZgFEIjHrkY3GGdhFE1sVNNG1fI3G5NB8mD0UxnkRY4ZN95gpthT7vJYQKO3GAmB85jMegPiFdVbbPegnjWvhGPPO3ZFoquHppeHV38C7Ep3OAm(8dPPnJdZpxTI4ZBZzf7bZpNrv71Os(geC44ZtsVNNG1fI3G5NB8mD0UxnkRY4ZN95gpthT7vJYQKO3GAmB85jMegPiFdcoC85jP3ZtW6cXBW8ZnYwpBgJSkJpF2NBKTE2mgzvs0BqnMn(8etcJuKVbbho(8K0GEppbRleVbZp340A0hzvgF(Sp340A0hzvs0BqnMn(8etcJuKVbbho(8K0GEppbRleVbZp3iB9SzmYQm(8zFUr26zZyKvjrVb1y24Ztmjmsr(geC44ZtsF698eSUq8gm)CJtRrFKvz85Z(CJtRrFKvjrVb1y24Ztmjmsr(geC44ZtsF698eSUq8gm)CJNPJ29QrzvgF(Sp34z6ODVAuwLe9guJzJppXKWif5BqWHJppj9P3ZtW6cXBW8ZnYwpBgJSkJpF2NBKTE2mgzvs0BqnMn(8etcJuKVbbho(8Kje9EEcwxiEdMFUXZ0r7E1OSkJpF2NB8mD0UxnkRsIEdQXSXNNysyKI8ni4WXNNmHO3ZtW6cXBW8ZnQwtny4zzvgF(Sp3OAn1GHNLvjrVb1y24ZteWWif5BqWHJppz1sVNNG1fI3G5NB8mD0UxnkRY4ZN95gpthT7vJYQKO3GAmB85jMegPiFdcoC85jHn075jyDH4ny(5gpthT7vJYQm(8zFUXZ0r7E1OSkj6nOgZgFEIjHrkY3GGdhFEYQp9EEcwxiEdMFUXZ0r7E1OSkJpF2NB8mD0UxnkRsIEdQXSXNNysyKI8n8gQoIW3BW8ZR2N3Sjw)56qnk5BGaPGJmcWvRGsGGFRn0ibc2H9NdB7A85cY3QM3aSd7ph22hJQNNuqaONdyAa4KVH3aSd7ppbu1EnQO3Ba2H9NxDFEc)6gNNhotBMXNtRoCy98WFoSDfIIOpppHrtuWppr4RkMy9WRFEOEE)C46MA8EEgzHkwpL3aSd7pV6(CyBdl85QveFUrBut1uouSdxz85OpxGQN3WHRP(5Z(CWvPEUnQPAupFDn1Y3WBa2H9Nx9GbYmhm)Cq0Uh(C2kc2ZZbX6WvYNNWyme(OEUVE1LQ(eTM6N3Sjwx9811ulFdnBI1vs4hYwrWEeGcD9XAhlHpOwJS5n0SjwxjHFiBfb7rak0PmffxVKUh8kOgfrFA9BOztSUsc)q2kc2JauOduhPMAFzafwknBcHybDumqfmPa43qZMyDLe(HSveShbOqN9w1aU6bqHLsZMqiwqhfdurj5B4na7W(ZREWazMdMFokepQF(eI4ZhQWN3SzVNhQN3c7q3GAu(gA2eRROWwtFWtbh1AafwkvZz6ODVAuMdflGRdVpQlSvuS9maze00ALSwnHxlnHdqgbnTwjRvt41Ydf7Wv0CYkvy7QZBAxcAATLCOybCD49rDHTIITNLh2zQba00AL5qXc46W7J6cBffBpx6J1okZBA)n0Sjwxjaf6yTwxA2eRx0HAaK3Iifww9gA2eRReGcDSwRlnBI1l6qnaYBrKcQuOZq1BOztSUsak0XATU0SjwVOd1aiVfrk9IakSuA2ecXc6OyGkysH(VHMnX6kbOqhR16sZMy9IoudG8wePOgafwknBcHybDumqfnt)3qZMyDLauOJ1ADPztSErhQbqElIuexHOi6ZB4n0Sjwxj7fPyVnv0l7b(gA2eRRK9IcqHoqDKAQ9LFdnBI1vYErbOqNvBEh1akSus8qXo8WRlPdFWtvyufAnfAuPsgbnTwz6Wh8ufgvHwlZBApfase(Hcl1SSmPebxhC1tLkGMwRe86Wl2dXur5HnBaa00AL2WRXtvwBXERAKh2SHcns5n0Sjwxj7ffGcDbdl(kSFdnBI1vYErbOqhBfXPOM9eFdnBI1vYErbOqxWWIUDgcOWsb00AL2WRXtvwBXERAKh2SPsLmcAATs7TPIU8qXoCfmNRfI6YeIyLkhk2HhEDjD4dEQcJQqRbiJGMwRmD4dEQcJQqRLhk2HRG5CTquxMqeFdnBI1vYErbOq315O9POG3hSauyPOwtny4zjBfb7PiI5y6jw)n0Sjwxj7ffGcDIXD7PkRTm7jI(8gA2eRRK9IcqHofvHDcVUaFtJ3BOztSUs2lkaf6S3QMIVcBafwkNPJ29Qrz9fkn1LGfmncW0xnosnke10mfnke1aKrqtRvAVnv0L5nT)gA2eRRK9IcqHoBCybu3QbqHLYz6ODVAuMdflGRdVpQlSvuS9maSD15nTlbnT2souSaUo8(OUWwrX2ZYd7m1aaAATYCOybCD49rDHTIITNl24qzEt7VHMnX6kzVOauORpw7ybHbC9QI1buyPi2ElHZgysFAaqZMqiwqhfdubtkvlavZz6ODVAuwRBw06I96Ar0h1BOztSUs2lkaf6qW1bx98gA2eRRK9IcqHUGHfD7meqHLYz6ODVAuwRBw06I96Ar0hfatRrFKk46yMWRlbdbyUwiQltiI0C9TMEU0lkb1rQP2xwEOyhU6n0Sjwxj7ffGcDP7yaKczuOHmjGclLZ0r7E1OSw3SO1f711IOpkaMwJ(ivW1XmHxxcg(gA2eRRK9IcqHo7TQbC1ZB4n0Sjwxjzzff47eRdOWsb(HclR1wQzzzWOUiedxvPc4QuayJAQMYHID4kAM(04n0SjwxjzzLauOlJ9qf4Eo(gA2eRRKSSsak0jg3TNQS2YSNi6dGclLMnHqSGokgOIMPpajYwpBgJufWPADmxeBDWWkvuRPgm8SmDRgu3EUa)w4xGd1P8gA2eRRKSSsak0DMowwBb(MgpafwkSD15nTldg1fHy4k5HID4kyMeWaaAATYZ0XYAlW304jZBA)n0SjwxjzzLauOlyuxeIHRauyPaAATYZ0XYAlW304jZBAhGebnTwzWOUiedxjZBAVsLP1OpYZ0XYAlW304LcajcAATsLoyWQemuM30ELknBcHybDumqfmPa4uEdnBI1vswwjaf6MqelP7doGclLZ0r7E1OCqr4716s6(GdaOP1kryqvBQMyDPjCase(HclR1wQzzzWOUiedxvPc4QuayJAQMYHID4kAwqPrkVHMnX6kjlReGcDMkSedkQEdnBI1vswwjaf6a17MlwZJ63qZMyDLKLvcqHoq8u4bRWRFdnBI1vswwjaf60rnvJQqtWmxlI(8gA2eRRKSSsak0zJdb17MFdnBI1vswwjaf6ANHQ5ADH1A9BOztSUsYYkbOqhyxxwBzUGbl1B4na7W(Zt4dvdQX8ZbrwBQWNtRoCyrhevHOiEppupVFoCDtnEpNr1gmu(gGDy)5nBI1vsXvikI(qbuhoSkTtnGclfXvikI(iZHAANHWmjnEdnBI1vsXvikI(iaf6cgwS6fvakSuanTwzWWIvVOsM30(BOztSUskUcrr0hbOqxFS2Xccd46vfRdOWsrS9wcNnWK(0aGMnHqSGokgOcMua8BOztSUskUcrr0hbOqNnoSaQB18gA2eRRKIRque9rak0fmSOBNHVH3qZMyDLunuSAZ7OgqHLsIhk2HhEDjD4dEQcJQqRPqJkvYiOP1kth(GNQWOk0AzEt7PaqIWpuyPMLLjLi46GREQub00ALGxhEXEiMkkpSzdajc)qHLAwwMuwRBw06IcEalSsf4hkSuZYYKs7TQbC1dajwnS1ZMXiJdlRTmuHLwXqpJ5kvy7QZBAxEDoAFkk49bl5HID4QkvothT7vJs7HyQHxxshEwLsLkWpuyPMLLjLxNJ2NIcEFWQsfqtRvAdVgpvzTf7TQrEyZgk0aGeZiOP1kfJ72tvwBz2te9rAcVsfqtRvApetn86s6WZkPj8kvanTwjcd4TNXCb(oOprRLh2SjLus5n0SjwxjvJauOZEBQOx2d8n0SjwxjvJauOduhPMAFzafwkGMwR0EiMA41LRdxAcVsLMnHqSGokgOcMua8BOztSUsQgbOq31uxwBXERAauyPCOyhE41L0Hp4PkmQcTMssaYiOP1kth(GNQWOk0A5HID4Q3qZMyDLuncqHUADZIwxuWdyHakSuouSdp86s6Wh8ufgvHwdqgbnTwz6Wh8ufgvHwlpuSdxbtwRMYeIOaZ1crDzcr8n0SjwxjvJauOlyyr3odbuyPCOyhE41L0Hp4PkmQcTgGdf7WdVUKo8bpvHrvO1We00AL2WRXtvwBXERAKh2SbGmcAATY0Hp4PkmQcTwEOyhUcMZ1crDzcr8n0SjwxjvJauOJTI4uuZEIVHMnX6kPAeGcDbdl(kSFdnBI1vs1iaf6UohTpff8(GfGclfqtRvApetn86s6WZkPjCaA2ecXc6OyGkkjFdnBI1vs1iaf6UohTpff8(GfGclfqtRvcED4f7HyQO8WMnamTg9rwRBw06IcEalea26zZyKXHL1wgQWsRyONXmaGMwRmybtJkPAAgSGjfb9n0SjwxjvJauOlyyr3odbuyPaAATsB414PkRTyVvnYdB2uPsgbnTwP92urxEOyhUcMZ1crDzcr8n0SjwxjvJauOdbxhC1ZBOztSUsQgbOq315O9POG3hSauyPKy1mTg9rwRBw06IcEalSsLQHTE2mgzCyzTLHkS0kg6zmNcajwnNPJ29QrP9qm1WRlPdpRQuPztielOJIbQGjfaNcaGMwRe86Wl2dXur5HnBEdnBI1vs1iaf6eJ72tvwBz2te95n0SjwxjvJauOtrvyNWRlW304bOWsb00ALNPJL1wGVPXtM30oajQwtny4zz9TcXs4cJ696jwVsf1AQbdplTbQZL1wa1RsTIQkvothT7vJs7HyQHxxshEwbaOP1kThIPgEDjD4zLmVP9kvA2ecXc6OyGkysbWP8gA2eRRKQrak0zVvnfFf2akSuothT7vJY6luAQlblyAeGPVACKAuiQPzkAuiQbiJGMwR0EBQOlZBA)n0SjwxjvJauORpw7ybHbC9QI1buyPCMoA3RgL5qXc46W7J6cBffBpdaBxDEt7sqtRTKdflGRdVpQlSvuS9S8WotnaGMwRmhkwaxhEFuxyROy75sFS2rzEt7VHMnX6kPAeGcD24WcOUvdGclLZ0r7E1OmhkwaxhEFuxyROy7zay7QZBAxcAATLCOybCD49rDHTIITNLh2zQba00AL5qXc46W7J6cBffBpxSXHY8M2FdnBI1vs1iaf6Q1nlADrbpGfcOWsb00ALGxhEXEiMkkpSzZBOztSUsQgbOqN9w1aU6HmKHqa]] )


end
