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
        deep_shatter = 68, -- 198123
        frostbite = 67, -- 198120
        ice_form = 634, -- 198144
        ice_wall = 5390, -- 352278
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
                    else
                        if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
                        removeBuff( "brain_freeze" )
                    end
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

            usable = function () return not state.spec.frost or target.distance < 12, "target out of range" end,
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
    
    spec:RegisterPack( "Frost Mage", 20210707, [[dO0G3aqijr5rQsYMKK(KizuscNse1RqQAwQcDlvrk7IOFHuAyQI6yIultvINPkIPPkPUgPIyBsIQVjIKXjIuDorKY6ivyEif19qI9HK4GKkklePYdLezIQIKCrsfjBKurQpIueoPQiXkjfZueXnjvuTtqPFQksvdvvKulfPi1tbzQGIVIuenwvb7fXFf1Gr1HLAXQQhJYKL4YqBMsFwsnAvPoTWQvfPYRrsA2uCBc2nv)wPHdQoosrYYv55KmDfxNqBNu67KQgpsHZJKA9KknFry)atstGHav6bjW(YZVK(5K65Ks(CslD60jfbAOgosGG3mQ21ibYBbKaPtFRAaCDExJei4n1MTleyiqQv8yib69mWv6GwARJ5T4xYwbAvHGOPNyD212HwviWOLa9fdZ8uCYNav6bjW(YZVK(5K65Ks(CslD60VqGAX59EeiOqOseO3rPGo5tGkOIrG05Dnc4603QgGgnIgQb8K6ra)LNFjnqdqtLE3EnQ0bqZtdWFQwp1a4HZmIfeWPZeovb8WbCD(QffqFaCD2tDsa8kGVQyI1dVgWdfG3aoCttnEaEbzHkwpzGMNgGRZBQIaUAfqapLnQFp5df6WvPaC0NlqfG3WHBOgWNfW)Rsb42O(9Oa81nuljqMqnkcmeOcABrZqGHaBAcmei07Vble6iqSlg8IMavza(j6ODVAuwcflGBcVpQZSvqO9Ie9(BWcGxfWl4x0ALSwnHxlfHd4vb8c(fTwjRvt41Ydf6Wvaond4Pb8ejaC2UMYQ3LFrRnxcflGBcVpQZSvqO9I8WUqnGxfW)IwRSekwa3eEFuNzRGq7LCFS2rzz17eOMnX6ei2k6dEk4OXqgcSVqGHaHE)nyHqhbQztSobI1gtUztSE2eQHazc1K9wajqSIImeyFcbgce693GfcDeOMnX6eiwBm5MnX6ztOgcKjut2BbKaHkf6murgcSVMadbc9(BWcHoce7IbVOjqnBcTygDuiqfGtfka(tiqnBI1jqS2yYnBI1ZMqneitOMS3cibQxKmey1jeyiqO3Fdwi0rGyxm4fnbQztOfZOJcbQaCAgWFcbQztSobI1gtUztSE2eQHazc1K9wajqQHmeyRCcmei07Vble6iqnBI1jqS2yYnBI1ZMqneitOMS3cibsy1IcOpKHmei4hYwHFpeyiWMMadbQztSobQpw7yo8bngKnei07Vble6idb2xiWqGA2eRtG03dEz0GcOpTHaHE)nyHqhziW(ecmei07Vble6iqSlg8IMa1Sj0Iz0rHavaovOa4VqGA2eRtG(MqxD7RqgcSVMadbc9(BWcHoce7IbVOjqnBcTygDuiqfGtbWttGA2eRtGS3QM)AgYqgcuVibgcSPjWqGA2eRtGS3Ql659(ei07Vble6idb2xiWqGA2eRtG(MqxD7RqGqV)gSqOJmeyFcbgce693GfcDei2fdErtGQaWpuOdp86S(Wh8uz27WyaCka(ZaEIeaEb)IwRuF4dEQm7DymYYQ3b8Kb8QaEfao8d1MRzfzAj(x)VMbWtKaW)IwR8FD4z7HOUO8WMnaEva)lATsB414PYRnBVvnYdB2a4ua8Nb8KjqnBI1jqwJ4DutgcSVMadbQztSobkyy2xTnbc9(BWcHoYqGvNqGHa1SjwNaXwbCYQzpbce693GfcDKHaBLtGHaHE)nyHqhbIDXGx0eOVO1kTHxJNkV2S9w1ipSzdGNibGxWVO1kT3Ql6Ydf6Wvaova85ATOjpHac4jsa4hk0HhEDwF4dEQm7DymaEvaVGFrRvQp8bpvM9omg5HcD4kaNka(CTw0KNqajqnBI1jqbdZM2ziziWMueyiqO3Fdwi0rGyxm4fnbsTIMF4fjBf(9KfWsm9eRlrV)gSqGA2eRtGUUeTpzf8(OkziWM0jWqGA2eRtGeI72tLxBE2ta9HaHE)nyHqhziWM0iWqGA2eRtGuVd7eEDg(Qhpce693GfcDKHaB6NjWqGqV)gSqOJaXUyWlAc0j6ODVAuwFHYqDoybZGs07VblaEvaF6RghPb1IgaNMPa4gulAa8QaEb)IwR0ERUOllRENa1SjwNazVvnzF12KHaB60eyiqO3Fdwi0rGyxm4fnb6eD0UxnklHIfWnH3h1z2ki0ErIE)nybWRc4SDnLvVl)IwBUekwa3eEFuNzRGq7f5HDHAaVkG)fTwzjuSaUj8(OoZwbH2lzBCOSS6DcuZMyDcKnom)nTAidb20VqGHaHE)nyHqhbIDXGx0eiH2BjC2a4ubWFYZaEvaVztOfZOJcbQaCQqbWRCaVkGxza(j6ODVAuwBAw0MS96Ab0hLe9(BWcbQztSobQpw7ygPbCZQI1jdb20pHadbQztSobc)R)xZqGqV)gSqOJmeyt)Acmei07Vble6iqSlg8IMaDIoA3RgL1MMfTjBVUwa9rjrV)gSa4vb8PnOpsfCtmt415GHs07VblaEvaFUwlAYtiGaond413k6LCVO8BcD1TVI8qHoCfbQztSobkyy20odjdb206ecmeOMnX6ei7TQ5VMHaHE)nyHqhzidbIvueyiWMMadbc9(BWcHocuZMyDcK6Dxw9yjV3pV28SNa6dbIDXGx0eOVO1kprhZRndF1JNSS6DcK3cibs9UlRESK37NxBE2ta9HmeyFHadbc9(BWcHoce7IbVOjqWpuBET2CnRidg1zTy4kaprca)VkfGxfWTr97jFOqhUcWPza)jptGA2eRtGGVtSoziW(ecmeOMnX6eOc2Z7)EosGqV)gSqOJmeyFnbgce693GfcDei2fdErtGA2eAXm6OqGkaNMb8Na4vb8kaC26fXyKQa(71XswOnbdLO3Fdwa8ejaC1kA(HxK6B1GM2lz43c)cCOwIE)nybWtgWRc4FrRv(Vo8S9quxuEyZgaNcG)mbQztSobsiUBpvET5zpb0hYqGvNqGHaHE)nyHqhbIDXGx0ei2UMYQ3LbJ6SwmCL8qHoCfGtfap9laEva)lATYt0X8AZWx94jlRENa1SjwNaDIoMxBg(QhpYqGTYjWqGqV)gSqOJaXUyWlAc0x0ALNOJ51MHV6Xtww9oGxfWRaW)IwRmyuN1IHRKLvVd4jsa4tBqFKNOJ51MHV6XtIE)nybWtgWRc4va4FrRvQmbJQ5GHYYQ3b8eja8MnHwmJokeOcWPcfa)fapzcuZMyDcuWOoRfdxrgcSjfbgce693GfcDei2fdErtGorhT7vJYbfGVxBY67dUe9(BWcGxfW)IwRePX7wunX6sr4aEvaVcah(HAZR1MRzfzWOoRfdxb4jsa4)vPa8QaUnQFp5df6Wvaond4V(zapzcuZMyDc0ecywFFWjdb2KobgcuZMyDcKOcZXGckce693GfcDKHaBsJadbQztSob6B2TKTIh1ei07Vble6idb20ptGHa1SjwNa9XtHhvdVMaHE)nyHqhziWMonbgcuZMyDcKjQFpQ8tNyPwa9HaHE)nyHqhziWM(fcmeOMnX6eiBC43SBHaHE)nyHqhziWM(jeyiqnBI1jqTZq1CTjZAJHaHE)nyHqhziWM(1eyiqnBI1jq)UoV28CbJQkce693GfcDKHmei1qGHaBAcmei07Vble6iqSlg8IMavbGFOqhE41z9Hp4PYS3HXa4ua8Nb8eja8c(fTwP(Wh8uz27WyKLvVd4jd4vb8kaC4hQnxZkY0s8V(FndGNibG)fTw5)6WZ2drDr5HnBa8QaEfao8d1MRzfzAzTPzrBYk4bvraprcah(HAZ1SImT0ERA(Rza8QaEfaELb4S1lIXiJdZRnpVXCRyOxWIe9(BWcGNibGZ21uw9U86s0(KvW7JQYdf6WvaEIea(j6ODVAuApe1n86S(Wlkj693Gfapzaprcah(HAZ1SImT86s0(KvW7JQaEIea(x0AL2WRXtLxB2ERAKh2SbWPa4pd4vb8ka8c(fTwPqC3EQ8AZZEcOpsr4aEIea(x0AL2drDdVoRp8IskchWtKaW)IwRePb82lyjdFh0NOnYdB2a4jd4jd4jtGA2eRtGSgX7OMmeyFHadbQztSobYERUON37tGqV)gSqOJmeyFcbgce693GfcDei2fdErtG(IwR0EiQB415RdxkchWtKaWB2eAXm6OqGkaNkua8xiqnBI1jqFtORU9vidb2xtGHaHE)nyHqhbIDXGx0eOdf6WdVoRp8bpvM9omgaNcGNgWRc4f8lATs9Hp4PYS3HXipuOdxrGA2eRtGUM68AZ2BvdziWQtiWqGqV)gSqOJaXUyWlAc0HcD4HxN1h(GNkZEhgdGxfWl4x0AL6dFWtLzVdJrEOqhUcWPcGZA1KNqabC6b85ATOjpHasGA2eRtGQnnlAtwbpOksgcSvobgce693GfcDei2fdErtGouOdp86S(Wh8uz27Wya8Qa(HcD4HxN1h(GNkZEhgdGtfa)lATsB414PYRnBVvnYdB2a4vb8c(fTwP(Wh8uz27WyKhk0HRaCQa4Z1ArtEcbKa1SjwNafmmBANHKHaBsrGHa1SjwNaXwbCYQzpbce693GfcDKHaBsNadbQztSobkyy2xTnbc9(BWcHoYqGnPrGHaHE)nyHqhbIDXGx0eOVO1kThI6gEDwF4fLueoGxfWB2eAXm6OqGkaNcGNMa1SjwNaDDjAFYk49rvYqGn9ZeyiqO3Fdwi0rGyxm4fnb6lATY)1HNThI6IYdB2a4vb8PnOpYAtZI2KvWdQIs07VblaEvaNTErmgzCyET55nMBfd9cwKO3Fdwa8Qa(x0ALblygujvtZOkGtfka(RjqnBI1jqxxI2NScEFuLmeytNMadbc9(BWcHoce7IbVOjqFrRvAdVgpvETz7TQrEyZgaprcaVGFrRvAVvx0Lhk0HRaCQa4Z1ArtEcbKa1SjwNafmmBANHKHaB6xiWqGA2eRtGW)6)1mei07Vble6idb20pHadbc9(BWcHoce7IbVOjqva4vgGpTb9rwBAw0MScEqvuIE)nybWtKaWRmaNTErmgzCyET55nMBfd9cwKO3Fdwa8Kb8QaEfaELb4NOJ29QrP9qu3WRZ6dVOKO3Fdwa8eja8MnHwmJokeOcWPcfa)fapzaVkG)fTw5)6WZ2drDr5HnBiqnBI1jqxxI2NScEFuLmeyt)AcmeOMnX6eiH4U9u51MN9eqFiqO3Fdwi0rgcSP1jeyiqO3Fdwi0rGyxm4fnb6lATYt0X8AZWx94jlREhWRc4va4NOJ29Qr5BSVjV288gZ2gLO3Fdwa8ejaC1kA(HxK13QfZHRnQ3RNyDj693GfaprcaxTIMF4fPnqtjV283Sk1kOKO3Fdwa8eja8t0r7E1O0EiQB41z9Hxus07VblaEva)lATs7HOUHxN1hErjlREhWtKaWB2eAXm6OqGkaNkua8xa8KjqnBI1jqQ3HDcVodF1JhziWMUYjWqGqV)gSqOJaXUyWlAc0j6ODVAuwFHYqDoybZGs07VblaEvaF6RghPb1IgaNMPa4gulAa8QaEb)IwR0ERUOllRENa1SjwNazVvnzF12KHaB6KIadbc9(BWcHoce7IbVOjqNOJ29QrzjuSaUj8(OoZwbH2ls07VblaEvaNTRPS6D5x0AZLqXc4MW7J6mBfeAVipSlud4vb8VO1klHIfWnH3h1z2ki0Ej3hRDuww9obQztSobQpw7ygPbCZQI1jdb20jDcmei07Vble6iqSlg8IMaDIoA3RgLLqXc4MW7J6mBfeAVirV)gSa4vbC2UMYQ3LFrRnxcflGBcVpQZSvqO9I8WUqnGxfW)IwRSekwa3eEFuNzRGq7LSnouww9obQztSobYghM)MwnKHaB6Kgbgce693GfcDei2fdErtG(IwR8FD4z7HOUO8WMneOMnX6eOAtZI2KvWdQIKHa7lptGHa1SjwNazVvn)1mei07Vble6idziqcRwua9Hadb20eyiqO3Fdwi0rGyxm4fnb6lATYGHzRzrLSS6DcuZMyDcuWWS1SOImeyFHadbc9(BWcHoce7IbVOjqcT3s4SbWPcG)KNb8QaEZMqlMrhfcub4uHcG)cbQztSobQpw7ygPbCZQI1jdb2NqGHa1SjwNazJdZFtRgce693GfcDKHa7RjWqGA2eRtGcgMnTZqce693GfcDKHmKHaPfpvSob2xE(L0px5VK0jq67ZdVwrGOj1z00W(uGLMqhaoGdZBeWdb47naUDpapvbTTOzsb4hstjghwaC1kGaEloRqpybWzVBVgvsGMKeoc4P1bGxP11I3Gfap1j6ODVAu(qkaFwap1j6ODVAu(Ge9(BWskaVI00izjqdqdnPoJMg2NcS0e6aWbCyEJaEiaFVbWT7b4P6ftb4hstjghwaC1kGaEloRqpybWzVBVgvsGMKeoc4jLoa8kTUw8gSa4PuRO5hEr(qkaFwapLAfn)WlYhKO3Fdwsb49a46up9jbWRinnswc0KKWrap9Z6aWR06AXBWcGN6eD0UxnkFifGplGN6eD0UxnkFqIE)nyjfGxrAAKSeOjjHJaE606aWR06AXBWcGN6eD0UxnkFifGplGN6eD0UxnkFqIE)nyjfGxrAAKSeOjjHJaE6x0bGxP11I3Gfap1j6ODVAu(qkaFwap1j6ODVAu(Ge9(BWskaVhaxN6PpjaEfPPrYsGMKeoc4PFToa8kTUw8gSa4PM2G(iFifGplGNAAd6J8bj693GLuaEfPPrYsGMKeoc4PFToa8kTUw8gSa4PorhT7vJYhsb4Zc4PorhT7vJYhKO3Fdwsb4vKMgjlbAaAOj1z00W(uGLMqhaoGdZBeWdb47naUDpapfROsb4hstjghwaC1kGaEloRqpybWzVBVgvsGMKeoc4VwhaELwxlEdwa8uS1lIXiFifGplGNITErmg5ds07VblPa8kstJKLanjjCeWFToa8kTUw8gSa4PuRO5hEr(qkaFwapLAfn)WlYhKO3Fdwsb4vKMgjlbAss4iGx56aWR06AXBWcGNAAd6J8Hua(SaEQPnOpYhKO3Fdwsb4vKMgjlbAss4iGNu6aWR06AXBWcGN6eD0UxnkFifGplGN6eD0UxnkFqIE)nyjfGxrAAKSeObOHMuNrtd7tbwAcDa4aomVrapeGV3a429a8uQjfGFinLyCybWvRac4T4Sc9GfaN9U9AujbAss4iGNwhaELwxlEdwa8uNOJ29Qr5dPa8zb8uNOJ29Qr5ds07VblPa8kstJKLanjjCeWtRdaVsRRfVblaEk26fXyKpKcWNfWtXwVigJ8bj693GLuaEfPPrYsGMKeoc4PFwhaELwxlEdwa8utBqFKpKcWNfWtnTb9r(Ge9(BWskaVI00izjqtschb80pRdaVsRRfVblaEk26fXyKpKcWNfWtXwVigJ8bj693GLuaEfPPrYsGMKeoc4PFIoa8kTUw8gSa4PM2G(iFifGplGNAAd6J8bj693GLuaEfPPrYsGMKeoc4PFIoa8kTUw8gSa4PorhT7vJYhsb4Zc4PorhT7vJYhKO3Fdwsb4vKMgjlbAss4iGN(j6aWR06AXBWcGNITErmg5dPa8zb8uS1lIXiFqIE)nyjfGxrAAKSeOjjHJaEADIoa8kTUw8gSa4PorhT7vJYhsb4Zc4PorhT7vJYhKO3Fdwsb4v8cnswc0KKWrapTorhaELwxlEdwa8uQv08dViFifGplGNsTIMF4f5ds07VblPa8kEHgjlbAss4iGNUY1bGxP11I3Gfap1j6ODVAu(qkaFwap1j6ODVAu(Ge9(BWskaVI00izjqtschb80jLoa8kTUw8gSa4PorhT7vJYhsb4Zc4PorhT7vJYhKO3Fdwsb4vKMgjlbAss4iGNoPRdaVsRRfVblaEQt0r7E1O8Hua(SaEQt0r7E1O8bj693GLuaEfPPrYsGgGMNIa89gSa4voG3SjwhWnHAusGgce8BTHbjqV6vaUoVRraxN(w1a08Qxb4Aenud4j1Ja(lp)sAGgGMx9kaVsVBVgv6aO5vVcWFAa(t16PgapCMrSGaoDMWPkGhoGRZxTOa6dGRZEQtcGxb8vftSE41aEOa8gWHBAQXdWliluX6jd08Qxb4pnaxN3ufbC1kGaEkBu)EYhk0HRsb4OpxGkaVHd3qnGplG)xLcWTr97rb4RBOwc0a08Qxb46u0azIdwa8pA3dbC2k87bW)yD4kjGRZyme(OaCF9N27(eSIgaVztSUcWx3qTeOPztSUsc)q2k87HEk02hRDmh(GgdYgGMMnX6kj8dzRWVh6PqRsuqy9S(EWlJgua9PnannBI1vs4hYwHFp0tH2Vj0v3(kpgwknBcTygDuiqfvO8cqtZMyDLe(HSv43d9uO1ERA(RzEmSuA2eAXm6OqGkkPbAaAE1RaCDkAGmXblaoQfpQb8jeqaFEJaEZM9a8qb4T2om93GsGMMnX6kkSv0h8uWrJ5XWsPYorhT7vJYsOybCt49rDMTccTxQwWVO1kzTAcVwkcVAb)IwRK1Qj8A5HcD4kAoDIeSDnLvVl)IwBUekwa3eEFuNzRGq7f5HDH6QFrRvwcflGBcVpQZSvqO9sUpw7OSS6DGMMnX6k6PqlRnMCZMy9SjuZJElGuyffqtZMyDf9uOL1gtUztSE2eQ5rVfqkOsHodvannBI1v0tHwwBm5MnX6ztOMh9waP0l(yyP0Sj0Iz0rHavuHYtaAA2eRRONcTS2yYnBI1ZMqnp6TasrnpgwknBcTygDuiqfn)eGMMnX6k6PqlRnMCZMy9SjuZJElGuewTOa6dqdqtZMyDLSxKI9wDrpV3hOPztSUs2lspfA)MqxD7Ra00Sjwxj7fPNcTwJ4Du)yyPuXHcD4HxN1h(GNkZEhgdLNtKOGFrRvQp8bpvM9omgzz17jxTc4hQnxZkY0s8V(FntIeFrRv(Vo8S9quxuEyZMQFrRvAdVgpvETz7TQrEyZgkpNmqtZMyDLSxKEk0gmm7R2gOPztSUs2lspfAzRaoz1SNaqtZMyDLSxKEk0gmmBANHpgwkFrRvAdVgpvETz7TQrEyZMejk4x0AL2B1fD5HcD4kQmxRfn5jeWejouOdp86S(Wh8uz27WyQwWVO1k1h(GNkZEhgJ8qHoCfvMR1IM8eciqtZMyDLSxKEk0EDjAFYk49r1hdlf1kA(HxKSv43twalX0tSoqtZMyDLSxKEk0ke3TNkV28SNa6dqtZMyDLSxKEk0QEh2j86m8vpEannBI1vYEr6PqR9w1K9vB)yyPCIoA3RgL1xOmuNdwWmy1PVACKgulAOzkgulAQwWVO1kT3Ql6YYQ3bAA2eRRK9I0tHwBCy(BA18yyPCIoA3RgLLqXc4MW7J6mBfeAVuLTRPS6D5x0AZLqXc4MW7J6mBfeAVipSlux9lATYsOybCt49rDMTccTxY24qzz17annBI1vYEr6PqBFS2Xmsd4MvfR)yyPi0ElHZgQ8KNR2Sj0Iz0rHavuHsLxTYorhT7vJYAtZI2KTxxlG(OaAA2eRRK9I0tHw8V(FndqtZMyDLSxKEk0gmmBANHpgwkNOJ29QrzTPzrBY2RRfqFuvN2G(ivWnXmHxNdgwDUwlAYtiG0C9TIEj3lk)MqxD7RipuOdxb08Qxb4nBI1vYEr6PqR(oMhviJYZY0pgwkNOJ29QrzTPzrBY2RRfqFuvN2G(ivWnXmHxNdgc00Sjwxj7fPNcT2BvZFndqdqtZMyDLKvuuevyogu4rVfqkQ3Dz1JL8E)8AZZEcOppgwkFrRvEIoMxBg(Qhpzz17annBI1vswrrpfAHVtS(JHLc8d1MxRnxZkYGrDwlgUkrI)QuvTr97jFOqhUIMFYZannBI1vswrrpfAlypV)75iqtZMyDLKvu0tHwH4U9u51MN9eqFEmSuA2eAXm6OqGkA(jvRGTErmgPkG)EDSKfAtWWejuRO5hErQVvdAAVKHFl8lWH6KR(fTw5)6WZ2drDr5HnBO8mqtZMyDLKvu0tH2t0X8AZWx949yyPW21uw9UmyuN1IHRKhk0HROs6xQ(fTw5j6yETz4RE8KLvVd00Sjwxjzff9uOnyuN1IHREmSu(IwR8eDmV2m8vpEYYQ3RwXx0ALbJ6SwmCLSS69ejM2G(iprhZRndF1JxYvR4lATsLjyunhmuww9EIenBcTygDuiqfvO8sYannBI1vswrrpfANqaZ67d(JHLYj6ODVAuoOa89AtwFFWR(fTwjsJ3TOAI1LIWRwb8d1MxRnxZkYGrDwlgUkrI)QuvTr97jFOqhUIMF9Zjd00Sjwxjzff9uOvuH5yqbfqtZMyDLKvu0tH2Vz3s2kEud00Sjwxjzff9uO9JNcpQgEnqtZMyDLKvu0tHwtu)Eu5NoXsTa6dqtZMyDLKvu0tHwBC43SBbOPztSUsYkk6PqB7munxBYS2yaAA2eRRKSIIEk0(768AZZfmQQaAaAE1Ra8NQq1Fdwa8pYArfc40zcNQ0c9oeeWdWdfG3aoCttnEao79gmuc08Qxb4nBI1vsHvlkG(q5BcNQ52P(XWsry1IcOpYsOM2zivs)mqtZMyDLuy1IcOp0tH2GHzRzr1JHLYx0ALbdZwZIkzz17annBI1vsHvlkG(qpfA7J1oMrAa3SQy9hdlfH2BjC2qLN8C1MnHwmJokeOIkuEbOPztSUskSArb0h6PqRnom)nTAaAA2eRRKcRwua9HEk0gmmBANHanannBI1vs1qXAeVJ6hdlLkouOdp86S(Wh8uz27WyO8CIef8lATs9Hp4PYS3HXilREp5Qva)qT5AwrMwI)1)RzsK4lATY)1HNThI6IYdB2uTc4hQnxZkY0YAtZI2KvWdQIjsa)qT5AwrMwAVvn)1mvROYyRxeJrghMxBEEJ5wXqVGLejy7AkRExEDjAFYk49rv5HcD4QejorhT7vJs7HOUHxN1hErLCIeWpuBUMvKPLxxI2NScEFunrIVO1kTHxJNkV2S9w1ipSzdLNRwrb)IwRuiUBpvET5zpb0hPi8ej(IwR0EiQB41z9Hxusr4js8fTwjsd4TxWsg(oOprBKh2Sj5KtgOPztSUsQg6PqR9wDrpV3hOPztSUsQg6Pq73e6QBFLhdlLVO1kThI6gED(6WLIWtKOztOfZOJcbQOcLxaAA2eRRKQHEk0En151MT3QMhdlLdf6WdVoRp8bpvM9omgkPRwWVO1k1h(GNkZEhgJ8qHoCfqtZMyDLun0tH2AtZI2KvWdQIpgwkhk0HhEDwF4dEQm7Dymvl4x0AL6dFWtLzVdJrEOqhUIkSwn5jeq6NR1IM8eciqtZMyDLun0tH2GHzt7m8XWs5qHo8WRZ6dFWtLzVdJP6HcD4HxN1h(GNkZEhgdv(IwR0gEnEQ8AZ2BvJ8WMnvl4x0AL6dFWtLzVdJrEOqhUIkZ1ArtEcbeOPztSUsQg6PqlBfWjRM9eaAA2eRRKQHEk0gmm7R2gOPztSUsQg6Pq71LO9jRG3hvFmSu(IwR0EiQB41z9Hxusr4vB2eAXm6OqGkkPbAA2eRRKQHEk0EDjAFYk49r1hdlLVO1k)xhE2EiQlkpSzt1PnOpYAtZI2KvWdQIvzRxeJrghMxBEEJ5wXqVGLQFrRvgSGzqLunnJQuHYRbAA2eRRKQHEk0gmmBANHpgwkFrRvAdVgpvETz7TQrEyZMejk4x0AL2B1fD5HcD4kQmxRfn5jeqGMMnX6kPAONcT4F9)AgGMMnX6kPAONcTxxI2NScEFu9XWsPIkBAd6JS20SOnzf8GQyIevgB9IymY4W8AZZBm3kg6fSKC1kQSt0r7E1O0EiQB41z9Hxujs0Sj0Iz0rHavuHYljx9lATY)1HNThI6IYdB2a00Sjwxjvd9uOviUBpvET5zpb0hGMMnX6kPAONcTQ3HDcVodF1J3JHLYx0ALNOJ51MHV6Xtww9E1korhT7vJY3yFtET55nMTnMiHAfn)WlY6B1I5W1g171tSEIeQv08dViTbAk51M)MvPwbvIeNOJ29QrP9qu3WRZ6dVOQ(fTwP9qu3WRZ6dVOKLvVNirZMqlMrhfcurfkVKmqtZMyDLun0tHw7TQj7R2(XWs5eD0UxnkRVqzOohSGzWQtF14inOw0qZumOw0uTGFrRvAVvx0LLvVd00Sjwxjvd9uOTpw7ygPbCZQI1FmSuorhT7vJYsOybCt49rDMTccTxQY21uw9U8lAT5sOybCt49rDMTccTxKh2fQR(fTwzjuSaUj8(OoZwbH2l5(yTJYYQ3bAA2eRRKQHEk0AJdZFtRMhdlLt0r7E1OSekwa3eEFuNzRGq7LQSDnLvVl)IwBUekwa3eEFuNzRGq7f5HDH6QFrRvwcflGBcVpQZSvqO9s2ghklREhOPztSUsQg6PqBTPzrBYk4bvXhdlLVO1k)xhE2EiQlkpSzdqtZMyDLun0tHw7TQ5VMHaPGJmcSv(Rjdzie]] )


end
