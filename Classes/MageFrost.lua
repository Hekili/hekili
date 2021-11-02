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
            id = function ()
                return pvptalent.ice_form.enabled and 198144 or 12472
            end,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,

            handler = function ()
                if pvptalent.ice_form.enabled then
                    applyBuff( "ice_form" )
                else
                    applyBuff( "icy_veins" )
                    stat.haste = stat.haste + 0.30
                end

                if azerite.frigid_grasp.enabled then
                    applyBuff( "frigid_grasp", 10 )
                    addStack( "fingers_of_frost", nil, 1 )
                end

                if talent.rune_of_power.enabled then
                    applyBuff( "rune_of_power" )
                end
            end,

            copy = { 12472, 198144, "ice_form" },

            auras = {
                ice_form = {
                    id = 198144,
                    duration = 22,
                    max_stack = 1,
                }
            }
        },


        ice_form = {
            id = 198144,
            known = 12472,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135838,

            pvptalent = "ice_form",

            handler = function ()
                applyBuff( "ice_form" )

                if azerite.frigid_grasp.enabled then
                    applyBuff( "frigid_grasp", 10 )
                    addStack( "fingers_of_frost", nil, 1 )
                end

                if talent.rune_of_power.enabled then
                    applyBuff( "rune_of_power" )
                end
            end,

            bind = "icy_veins"
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
    
    spec:RegisterPack( "Frost Mage", 20210916, [[dOuX3aqivr4rQIYMKK(Ki1OiuDkrKxrOmlvHULQiQDrYVqknmKKoMKyzijEMijttvKUMQOY2qsvFdjvmovrvohsv06qQQ5HuLUhsSpvPCqruYcrQ8qrsnrruOlkIc2OQiIpIKk5KIOuRKuzMIO6MIOODck9tvrv1qvfrAPiPs9uqMkO4RivbJvvWEr8xrnyuDyPwSQ6XOmzjUm0MP0NLuJwvYPfwTQOQ8AvPA2uCBc2nv)wPHdQoosvOLRYZjA6kUoPSDc57IW4rs58ifRxKy(KQ2pWKkeyiqLEqcSuHQuPcvPNvOEvf65tt1tPEc0qdCKabVzV31ibYBbKa9KCRCa8KzxJei4nnMTleyiqYv7yib61mWL0NwARJ5L2xXwbALHGMPNyD212HwziWOLa91cZKSDYNav6bjWsfQsLkuLEwH6vvONpnvpL6jqT28ApceuiKAc0ROuqN8jqfuYiqjZUgb8NKBLdqhecFqHpEaEfQ)raNkuLkva6a6s9R2Rrj9b6EYaEY46PhapCMrRGaoDMWFhWdhWtMRiua9bWtwpPjhWfh(kJjwp8AapKaEd4Wnnn4b4fKfYy9Ka6EYaEYSFhbC5kGaEABu)AYhk0Hltd4OpxGsaVHd3qdGplG)xPeWTr9Rrc4RBOrrGmHCKeyiqf02AMHadb2keyiqO3Fdwi0rGyxm4fnb6ja8tZr7E1OQeswa3eEF0KzRGq7ff693GfaVkGxWVM1QyTCcVwPbhWRc4f8RzTkwlNWRvhk0HlbC6fWRa461d4SDnLnHR(AwBUeswa3eEF0KzRGq7f1HDHgaVkG)1SwvjKSaUj8(OjZwbH2l5(yTJQYMWjqnBI1jqSvZh8KWrJHmeyPcbgce693GfcDeOMnX6eiwBm5MnX6ztihcKjKt2BbKaXksYqGnveyiqO3Fdwi0rGA2eRtGyTXKB2eRNnHCiqMqozVfqcekLOZqjziW(ucmei07Vble6iqSlg8IMa1SjeHz0rHaLa(Bua8urGA2eRtGyTXKB2eRNnHCiqMqozVfqcuViziW(CeyiqO3Fdwi0rGyxm4fnbQzticZOJcbkbC6fWtfbQztSobI1gtUztSE2eYHazc5K9wajqYHmeyPEcmei07Vble6iqnBI1jqS2yYnBI1ZMqoeitiNS3cibsyfHcOpKHmei4hYwHFpeyiWwHadbQztSobQpw7yo8bngKnei07Vble6idbwQqGHa1SjwNaLOh8YObfqFAdbc9(BWcHoYqGnveyiqO3Fdwi0rGyxm4fnbQzticZOJcbkb83Oa4uHa1SjwNa9nrkP0xHmeyFkbgce693GfcDei2fdErtGA2eIWm6OqGsaNcGxHa1SjwNazVvo)1mKHmeOErcmeyRqGHa1SjwNazVnf0Z79jqO3Fdwi0rgcSuHadbQztSob6BIusPVcbc9(BWcHoYqGnveyiqO3Fdwi0rGyxm4fnbsCa)qHo8WRZjcFWtMzVcJbWPa4ufW1RhWl4xZAvjcFWtMzVcJrv2eoGNeGxfWfhWHFOOCnROQOW)6)1maUE9a(xZAv)RdpBpetbvh2SbWRc4FnRvzdVgpzETz7TYrDyZgaNcGtvapjcuZMyDcK1ODhnKHa7tjWqGA2eRtGcgM9vutGqV)gSqOJmeyFocmeOMnX6ei2kGtwo7jqGqV)gSqOJmeyPEcmei07Vble6iqSlg8IMa91SwLn8A8K51MT3kh1HnBaC96b8c(1SwL92uqxDOqhUeWFdWNRfHM8eciGRxpGFOqhE415eHp4jZSxHXa4vb8c(1SwvIWh8Kz2RWyuhk0Hlb83a85ArOjpHasGA2eRtGcgMnTZqYqGL6qGHaHE)nyHqhbIDXGx0ei5Qz(HxuSv43twalX0tSUc9(BWcbQztSob66s0(KLW77DYqG95rGHa1SjwNaje3TNmV28SNa6dbc9(BWcHoYqGLEsGHa1SjwNajFf2j86m8nbEei07Vble6idb2kuLadbc9(BWcHoce7IbVOjqNMJ29Qrv9fsdn5GfmdQqV)gSa4vb8PVACugueAaC6LcGBqrObWRc4f8RzTk7TPGUQSjCcuZMyDcK9w5K9vutgcSvQqGHaHE)nyHqhbIDXGx0eOtZr7E1OQeswa3eEF0KzRGq7ff693GfaVkGZ21u2eU6RzT5sizbCt49rtMTccTxuh2fAa8Qa(xZAvLqYc4MW7JMmBfeAVKTXHQYMWjqnBI1jq24W830YHmeyRqfcmei07Vble6iqSlg8IMaj0ERGZga)napvufWRc4nBcrygDuiqjG)gfaN6b8Qa(ta4NMJ29QrvTPzrBY2RRfqFKk07VbleOMnX6eO(yTJzKAWnRmwNmeyRKkcmeOMnX6ei8V(Fndbc9(BWcHoYqGTYtjWqGqV)gSqOJaXUyWlAc0P5ODVAuvBAw0MS96Ab0hPc9(BWcGxfWfhWN2G(OKWnXmHxNdgQqV)gSa461d4nBcrygDuiqjG)gfa)5a8Ka8Qa(CTi0KNqabC6fWRVvZl5Er13ePKsFf1HcD4scuZMyDcuWWSPDgsgcSvEocmeOMnX6ei7TY5VMHaHE)nyHqhzidbIvKeyiWwHadbc9(BWcHocuZMyDcK8vx2eyjV3pV28SNa6dbIDXGx0eOVM1QonhZRndFtGNQSjCcK3cibs(QlBcSK37NxBE2ta9HmeyPcbgce693GfcDei2fdErtGGFOO8AT5AwrfmAYIWWLaUE9a(FLsaVkGBJ6xt(qHoCjGtVaEQOkbQztSobc(oX6KHaBQiWqGA2eRtGkypV(75ibc9(BWcHoYqG9PeyiqO3Fdwi0rGyxm4fnbQzticZOJcbkbC6fWtfGxfWfhWzRx0Irjd4VwhlzH2emuHE)nybW1RhWLRM5hErLOLdAAVKHFl8lWHgf693GfapjaVkG)1Sw1)6WZ2dXuq1HnBaCkaovjqnBI1jqcXD7jZRnp7jG(qgcSphbgce693GfcDei2fdErtGy7AkBcxfmAYIWWLQdf6WLa(BaEfQa4vb8VM1QonhZRndFtGNQSjCcuZMyDc0P5yETz4Bc8idbwQNadbc9(BWcHoce7IbVOjqFnRvDAoMxBg(Mapvzt4aEvaxCa)RzTQGrtwegUuv2eoGRxpGpTb9rDAoMxBg(Mapf693GfapjaVkGloG)1SwL0eS3ZbdvLnHd461d4nBcrygDuiqjG)gfaNkaEseOMnX6eOGrtwegUKmeyPoeyiqO3Fdwi0rGyxm4fnb60C0UxnQgua(ETjNOp4k07VblaEva)RzTkKAVAn5eRR0Gd4vbCXbC4hkkVwBUMvubJMSimCjGRxpG)xPeWRc42O(1KpuOdxc40lG)uQc4jrGA2eRtGMqaZj6doziW(8iWqGA2eRtG0KyoguqsGqV)gSqOJmeyPNeyiqnBI1jqFZULSv7OHaHE)nyHqhziWwHQeyiqnBI1jqF8K49E41ei07Vble6idb2kviWqGA2eRtGmr9RrMF(0k1cOpei07Vble6idb2kuHadbQztSobYgh(n7wiqO3Fdwi0rgcSvsfbgcuZMyDcu7muoxBYS2yiqO3Fdwi0rgcSvEkbgcuZMyDc0VRZRnpxWExsGqV)gSqOJmKHajhcmeyRqGHaHE)nyHqhbIDXGx0eiXb8df6WdVoNi8bpzM9kmgaNcGtvaxVEaVGFnRvLi8bpzM9kmgvzt4aEsaEvaxCah(HIY1SIQIc)R)xZa461d4FnRv9Vo8S9qmfuDyZgaVkGloGd)qr5AwrvrvBAw0MSeE8oc461d4WpuuUMvuvu2BLZFndGxfWfhWFcaNTErlgvCyET55fMBjd9cwuO3FdwaC96bC2UMYMWvxxI2NSeEFVRouOdxc461d4NMJ29QrL9qmLWRZjcVivO3Fdwa8KaC96bC4hkkxZkQkQRlr7twcVV3bC96b8VM1QSHxJNmV2S9w5OoSzdGtbWPkGxfWfhWl4xZAvcXD7jZRnp7jG(O0Gd461d4FnRvzpetj86CIWlsLgCaxVEa)RzTkKAWBVGLm8DqFI2OoSzdGNeGNeGNebQztSobYA0UJgYqGLkeyiqnBI1jq2Btb98EFce693GfcDKHaBQiWqGqV)gSqOJaXUyWlAc0xZAv2dXucVoFD4kn4aUE9aEZMqeMrhfcuc4VrbWPcbQztSob6BIusPVcziW(ucmei07Vble6iqSlg8IMaDOqhE415eHp4jZSxHXa4ua8kaEvaVGFnRvLi8bpzM9kmg1HcD4scuZMyDc010KxB2ERCidb2NJadbc9(BWcHoce7IbVOjqhk0HhEDor4dEYm7vymaEvaVGFnRvLi8bpzM9kmg1HcD4sa)naN1YjpHac4Ib4Z1IqtEcbKa1SjwNavBAw0MSeE8osgcSupbgce693GfcDei2fdErtGouOdp86CIWh8Kz2RWya8Qa(HcD4HxNte(GNmZEfgdG)gG)1SwLn8A8K51MT3kh1HnBa8QaEb)AwRkr4dEYm7vymQdf6WLa(Ba(CTi0KNqajqnBI1jqbdZM2ziziWsDiWqGA2eRtGyRaoz5SNabc9(BWcHoYqG95rGHa1SjwNafmm7ROMaHE)nyHqhziWspjWqGqV)gSqOJaXUyWlAc0xZAv2dXucVoNi8IuPbhWRc4nBcrygDuiqjGtbWRqGA2eRtGUUeTpzj8(ENmeyRqvcmei07Vble6iqSlg8IMa91Sw1)6WZ2dXuq1HnBa8Qa(0g0hvTPzrBYs4X7Oc9(BWcGxfWzRx0IrfhMxBEEH5wYqVGff693GfaVkG)1SwvWcMbLk50S3b83Oa4pLa1SjwNaDDjAFYs499oziWwPcbgce693GfcDei2fdErtG(AwRYgEnEY8AZ2BLJ6WMnaUE9aEb)AwRYEBkORouOdxc4Vb4Z1IqtEcbKa1SjwNafmmBANHKHaBfQqGHa1SjwNaH)1)RziqO3Fdwi0rgcSvsfbgce693GfcDei2fdErtGehWFcaFAd6JQ20SOnzj84DuHE)nybW1RhWFcaNTErlgvCyET55fMBjd9cwuO3Fdwa8Ka8QaU4a(ta4NMJ29QrL9qmLWRZjcVivO3FdwaC96b8MnHimJokeOeWFJcGtfapjaVkG)1Sw1)6WZ2dXuq1HnBiqnBI1jqxxI2NSeEFVtgcSvEkbgcuZMyDcKqC3EY8AZZEcOpei07Vble6idb2kphbgce693GfcDei2fdErtG(AwR60CmV2m8nbEQYMWb8QaU4a(P5ODVAu9c7BYRnpVWSTrf693GfaxVEaxUAMF4fv9TIWC4II696jwxHE)nybW1RhWLRM5hErzd0uYRn)nRuUcsf693GfaxVEa)0C0UxnQShIPeEDor4fPc9(BWcGxfW)AwRYEiMs415eHxKQYMWbC96b8MnHimJokeOeWFJcGtfapjcuZMyDcK8vyNWRZW3e4rgcSvOEcmei07Vble6iqSlg8IMaDAoA3Rgv1xin0KdwWmOc9(BWcGxfWN(QXrzqrObWPxkaUbfHgaVkGxWVM1QS3Mc6QYMWjqnBI1jq2BLt2xrnziWwH6qGHaHE)nyHqhbIDXGx0eOtZr7E1OQeswa3eEF0KzRGq7ff693GfaVkGZ21u2eU6RzT5sizbCt49rtMTccTxuh2fAa8Qa(xZAvLqYc4MW7JMmBfeAVK7J1oQkBcNa1SjwNa1hRDmJudUzLX6KHaBLNhbgce693GfcDei2fdErtGonhT7vJQsizbCt49rtMTccTxuO3Fdwa8QaoBxtzt4QVM1MlHKfWnH3hnz2ki0ErDyxObWRc4FnRvvcjlGBcVpAYSvqO9s2ghQkBcNa1SjwNazJdZFtlhYqGTc9Kadbc9(BWcHoce7IbVOjqFnRv9Vo8S9qmfuDyZgcuZMyDcuTPzrBYs4X7iziWsfQsGHa1SjwNazVvo)1mei07Vble6idziqcRiua9Hadb2keyiqO3Fdwi0rGyxm4fnb6RzTQGHzRzrPQSjCcuZMyDcuWWS1SOKmeyPcbgce693GfcDei2fdErtGeAVvWzdG)gGNkQc4vb8MnHimJokeOeWFJcGtfcuZMyDcuFS2Xmsn4MvgRtgcSPIadbQztSobYghM)Mwoei07Vble6idb2NsGHa1SjwNafmmBANHei07Vble6idzidbseEYyDcSuHQuPcvPouL6qGs0NhETKarpKSOUHnzdl1f9bCahMxiGhcW3BaC7EaE6cABnZKgWpKEuloSa4Yvab8wBwHEWcGZE1EnkvaDjpCeWRqFap1RlcVblaE6tZr7E1O6H0a(SaE6tZr7E1O6bf693GL0aU4vOwskGoGo6HKf1nSjByPUOpGd4W8cb8qa(EdGB3dWt3lMgWpKEuloSa4Yvab8wBwHEWcGZE1EnkvaDjpCeWPo0hWt96IWBWcGNwUAMF4f1dPb8zb80YvZ8dVOEqHE)nyjnG3dGNm88NCax8kuljfqxYdhb8kuL(aEQxxeEdwa80NMJ29Qr1dPb8zb80NMJ29Qr1dk07VblPbCXRqTKuaDjpCeWRuH(aEQxxeEdwa80NMJ29Qr1dPb8zb80NMJ29Qr1dk07VblPbCXRqTKuaDjpCeWRqf6d4PEDr4nybWtFAoA3RgvpKgWNfWtFAoA3RgvpOqV)gSKgW7bWtgE(toGlEfQLKcOl5HJaELNsFap1RlcVblaE6PnOpQhsd4Zc4PN2G(OEqHE)nyjnGlEfQLKcOl5HJaELNsFap1RlcVblaE6tZr7E1O6H0a(SaE6tZr7E1O6bf693GL0aU4vOwskGoGo6HKf1nSjByPUOpGd4W8cb8qa(EdGB3dWtZkY0a(H0JAXHfaxUciG3AZk0dwaC2R2RrPcOl5HJa(tPpGN61fH3GfapnB9IwmQhsd4Zc4PzRx0Ir9Gc9(BWsAax8kuljfqxYdhb8NsFap1RlcVblaEA5Qz(HxupKgWNfWtlxnZp8I6bf693GL0aU4vOwskGUKhoc4up9b8uVUi8gSa4PN2G(OEinGplGNEAd6J6bf693GL0aU4vOwskGUKhoc4uh6d4PEDr4nybWtFAoA3RgvpKgWNfWtFAoA3RgvpOqV)gSKgWfVc1ssb0b0rpKSOUHnzdl1f9bCahMxiGhcW3BaC7EaEA5KgWpKEuloSa4Yvab8wBwHEWcGZE1EnkvaDjpCeWRqFap1RlcVblaE6tZr7E1O6H0a(SaE6tZr7E1O6bf693GL0aU4vOwskGUKhoc4vOpGN61fH3GfapnB9IwmQhsd4Zc4PzRx0Ir9Gc9(BWsAax8kuljfqxYdhb8kuL(aEQxxeEdwa80tBqFupKgWNfWtpTb9r9Gc9(BWsAax8kuljfqxYdhb8kuL(aEQxxeEdwa80S1lAXOEinGplGNMTErlg1dk07VblPbCXRqTKuaDjpCeWRKk6d4PEDr4nybWtpTb9r9qAaFwap90g0h1dk07VblPbCXRqTKuaDjpCeWRKk6d4PEDr4nybWtFAoA3RgvpKgWNfWtFAoA3RgvpOqV)gSKgWfVc1ssb0L8WraVsQOpGN61fH3GfapnB9IwmQhsd4Zc4PzRx0Ir9Gc9(BWsAax8kuljfqxYdhb8kph9b8uVUi8gSa4PpnhT7vJQhsd4Zc4PpnhT7vJQhuO3Fdwsd4ItfQLKcOl5HJaELNJ(aEQxxeEdwa80YvZ8dVOEinGplGNwUAMF4f1dk07VblPbCXPc1ssb0L8WraVc1tFap1RlcVblaE6tZr7E1O6H0a(SaE6tZr7E1O6bf693GL0aU4vOwskGUKhoc4vOo0hWt96IWBWcGN(0C0UxnQEinGplGN(0C0UxnQEqHE)nyjnGlEfQLKcOl5HJaELNh9b8uVUi8gSa4PpnhT7vJQhsd4Zc4PpnhT7vJQhuO3Fdwsd4IxHAjPa6a6s2cW3BWcGt9aEZMyDa3eYrQa6iqWV1ggKa9SNb4jZUgb8NKBLdq3ZEgGdHWhu4JhGxH6FeWPcvPsfGoGUN9map1VAVgL0hO7zpdWFYaEY46PhapCMrRGaoDMWFhWdhWtMRiua9bWtwpPjhWfh(kJjwp8AapKaEd4Wnnn4b4fKfYy9Ka6E2Za8NmGNm73raxUciGN2g1VM8HcD4Y0ao6ZfOeWB4Wn0a4Zc4)vkbCBu)AKa(6gAuaDaDp7zaEYa1qM2Gfa)J29qaNTc)Ea8pwhUub4jlgdHpsa3x)j)QpbRMbWB2eRlb81n0Oa6A2eRlvWpKTc)EeJcT9XAhZHpOXGSbORztSUub)q2k87rmk0k1eewpNOh8YObfqFAdqxZMyDPc(HSv43JyuO9BIusPVYJHLsZMqeMrhfcu(gfQa01SjwxQGFiBf(9igfAT3kN)AMhdlLMnHimJokeOKsfGoGUN9mapzGAitBWcGJIWJgaFcbeWNxiG3SzpapKaElQdt)nOcORztSUKcB18bpjC0yEmSuEItZr7E1OQeswa3eEF0KzRGq7LQf8RzTkwlNWRvAWRwWVM1QyTCcVwDOqhUKEROxpBxtzt4QVM1MlHKfWnH3hnz2ki0ErDyxOP6xZAvLqYc4MW7JMmBfeAVK7J1oQkBchORztSUumk0YAJj3SjwpBc58O3cifwrc01SjwxkgfAzTXKB2eRNnHCE0BbKckLOZqjqxZMyDPyuOL1gtUztSE2eY5rVfqk9IpgwknBcrygDuiq5BusfqxZMyDPyuOL1gtUztSE2eY5rVfqkY5XWsPzticZOJcbkP3ub01SjwxkgfAzTXKB2eRNnHCE0BbKIWkcfqFa6a6A2eRlv9IuS3Mc659(aDnBI1LQErXOq73ePKsFfGUMnX6svVOyuO1A0UJMhdlfXpuOdp86CIWh8Kz2RWyOqv96l4xZAvjcFWtMzVcJrv2eEsvfh(HIY1SIQIc)R)xZOx)xZAv)RdpBpetbvh2SP6xZAv2WRXtMxB2ERCuh2SHcvtcORztSUu1lkgfAdgM9vud01SjwxQ6ffJcTSvaNSC2taORztSUu1lkgfAdgMnTZWhdlLVM1QSHxJNmV2S9w5OoSzJE9f8RzTk7TPGU6qHoC5BZ1IqtEcbuV(df6WdVoNi8bpzM9kmMQf8RzTQeHp4jZSxHXOouOdx(2CTi0KNqab6A2eRlv9IIrH2Rlr7twcVV3FmSuKRM5hErXwHFpzbSetpX6aDnBI1LQErXOqRqC3EY8AZZEcOpaDnBI1LQErXOqR8vyNWRZW3e4b01SjwxQ6ffJcT2BLt2xr9JHLYP5ODVAuvFH0qtoybZGvN(QXrzqrOHEPyqrOPAb)AwRYEBkORkBchORztSUu1lkgfATXH5VPLZJHLYP5ODVAuvcjlGBcVpAYSvqO9sv2UMYMWvFnRnxcjlGBcVpAYSvqO9I6WUqt1VM1QkHKfWnH3hnz2ki0EjBJdvLnHd01SjwxQ6ffJcT9XAhZi1GBwzS(JHLIq7TcoBElvuTAZMqeMrhfcu(gfQV6tCAoA3Rgv1MMfTjBVUwa9rc01SjwxQ6ffJcT4F9)AgGUMnX6svVOyuOnyy20odFmSuonhT7vJQAtZI2KTxxlG(iRk(0g0hLeUjMj86CWq96B2eIWm6OqGY3O8CjvDUweAYtiG0B9TAEj3lQ(MiLu6ROouOdxc09SNb4nBI1LQErXOqBIoMhLiJcvvvEmSuonhT7vJQAtZI2KTxxlG(iRoTb9rjHBIzcVohmeORztSUu1lkgfAT3kN)AgGoGUMnX6sfRiPOjXCmOWJElGuKV6YMal59(51MN9eqFEmSu(AwR60CmV2m8nbEQYMWb6A2eRlvSIumk0cFNy9hdlf4hkkVwBUMvubJMSimCPE9)vkRAJ6xt(qHoCj9MkQc01SjwxQyfPyuOTG986VNJaDnBI1LkwrkgfAfI72tMxBE2ta95XWsPzticZOJcbkP3uvvC26fTyuYa(R1XswOnbd1RxUAMF4fvIwoOP9sg(TWVahAsQ6xZAv)RdpBpetbvh2SHcvb6A2eRlvSIumk0EAoMxBg(MaVhdlf2UMYMWvbJMSimCP6qHoC5BvOs1VM1QonhZRndFtGNQSjCGUMnX6sfRifJcTbJMSimC5JHLYxZAvNMJ51MHVjWtv2eEvX)AwRky0KfHHlvLnHRx)0g0h1P5yETz4Bc8sQQ4FnRvjnb79CWqvzt4613SjeHz0rHaLVrHkjb01SjwxQyfPyuODcbmNOp4pgwkNMJ29Qr1GcW3Rn5e9bV6xZAvi1E1AYjwxPbVQ4WpuuET2CnROcgnzry4s96)Ruw1g1VM8HcD4s69PunjGUMnX6sfRifJcTAsmhdkib6A2eRlvSIumk0(n7wYwTJgGUMnX6sfRifJcTF8K49E41aDnBI1LkwrkgfAnr9RrMF(0k1cOpaDnBI1LkwrkgfATXHFZUfGUMnX6sfRifJcTTZq5CTjZAJbORztSUuXksXOq7VRZRnpxWExc0b09SNb4jJHS)gSa4FK1AseWPZe(70c9keeWdWdjG3aoCttdEao71gmub09SNb4nBI1LkHvekG(q5Bc)9C708yyPiSIqb0hvjKt7m8TkufORztSUujSIqb0hXOqBWWS1SO8XWs5RzTQGHzRzrPQSjCGUMnX6sLWkcfqFeJcT9XAhZi1GBwzS(JHLIq7TcoBElvuTAZMqeMrhfcu(gfQa01SjwxQewrOa6JyuO1ghM)MwoaDnBI1LkHvekG(igfAdgMnTZqGoGUMnX6sLCOynA3rZJHLI4hk0HhEDor4dEYm7vymuOQE9f8RzTQeHp4jZSxHXOkBcpPQId)qr5AwrvrH)1)Rz0R)RzTQ)1HNThIPGQdB2uvC4hkkxZkQkQAtZI2KLWJ3r96HFOOCnROQOS3kN)AMQI)eS1lAXOIdZRnpVWClzOxWIE9SDnLnHRUUeTpzj8(ExDOqhUuV(tZr7E1OYEiMs415eHxKjPxp8dfLRzfvf11LO9jlH33761)1SwLn8A8K51MT3kh1HnBOq1QIxWVM1QeI72tMxBE2ta9rPbxV(VM1QShIPeEDor4fPsdUE9FnRvHudE7fSKHVd6t0g1HnBskPKa6A2eRlvYrmk0AVnf0Z79b6A2eRlvYrmk0(nrkP0x5XWs5RzTk7HykHxNVoCLgC96B2eIWm6OqGY3OqfGUMnX6sLCeJcTxttETz7TY5XWs5qHo8WRZjcFWtMzVcJHsLQf8RzTQeHp4jZSxHXOouOdxc01SjwxQKJyuOT20SOnzj84D8XWs5qHo8WRZjcFWtMzVcJPAb)AwRkr4dEYm7vymQdf6WLVXA5KNqafBUweAYtiGaDnBI1Lk5igfAdgMnTZWhdlLdf6WdVoNi8bpzM9kmMQhk0HhEDor4dEYm7vymV91SwLn8A8K51MT3kh1HnBQwWVM1Qse(GNmZEfgJ6qHoC5BZ1IqtEcbeORztSUujhXOqlBfWjlN9ea6A2eRlvYrmk0gmm7ROgORztSUujhXOq71LO9jlH337pgwkFnRvzpetj86CIWlsLg8QnBcrygDuiqjLkaDnBI1Lk5igfAVUeTpzj8(E)XWs5RzTQ)1HNThIPGQdB2uDAd6JQ20SOnzj84DSkB9IwmQ4W8AZZlm3sg6fSu9RzTQGfmdkvYPzV)gLNc01SjwxQKJyuOnyy20odFmSu(AwRYgEnEY8AZ2BLJ6WMn61xWVM1QS3Mc6Qdf6WLVnxlcn5jeqGUMnX6sLCeJcT4F9)AgGUMnX6sLCeJcTxxI2NSeEFV)yyPi(tmTb9rvBAw0MSeE8oQx)tWwVOfJkomV288cZTKHEbljvv8N40C0UxnQShIPeEDor4fPE9nBcrygDuiq5BuOssv)AwR6FD4z7HykO6WMnaDnBI1Lk5igfAfI72tMxBE2ta9bORztSUujhXOqR8vyNWRZW3e49yyP81Sw1P5yETz4Bc8uLnHxv8tZr7E1O6f23KxBEEHzBJ61lxnZp8IQ(wryoCrr9E9eRRxVC1m)WlkBGMsET5VzLYvqQx)P5ODVAuzpetj86CIWlYQFnRvzpetj86CIWlsvzt4613SjeHz0rHaLVrHkjb01SjwxQKJyuO1ERCY(kQFmSuonhT7vJQ6lKgAYblygS60xnokdkcn0lfdkcnvl4xZAv2BtbDvzt4aDnBI1Lk5igfA7J1oMrQb3SYy9hdlLtZr7E1OQeswa3eEF0KzRGq7LQSDnLnHR(AwBUeswa3eEF0KzRGq7f1HDHMQFnRvvcjlGBcVpAYSvqO9sUpw7OQSjCGUMnX6sLCeJcT24W830Y5XWs50C0UxnQkHKfWnH3hnz2ki0EPkBxtzt4QVM1MlHKfWnH3hnz2ki0ErDyxOP6xZAvLqYc4MW7JMmBfeAVKTXHQYMWb6A2eRlvYrmk0wBAw0MSeE8o(yyP81Sw1)6WZ2dXuq1HnBa6A2eRlvYrmk0AVvo)1meijCKrGL6FkzidHaa]] )


end
