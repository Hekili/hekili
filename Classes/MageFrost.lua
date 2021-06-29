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
                        if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 3 ) end
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
    
    spec:RegisterPack( "Frost Mage", 20210628, [[dOus3aqijvXJuLInjP8jrYOeroLiQxHu1SKu5wsQsTls(fsXWqQ4ysILjj5zKkzAsQQRPkLABIu03ivugNQuY5ivewhPcZdPsDpKyFQs1bfPGfIu6HIuAIKksDrsfjBusvIpIuj5KIuOvskMjPsDtsfv7eu6NivcnujvjTuKkPEkitfu8vKkrJvsQ9I4VIAWO6WsTyv1JrzYsCzOntPpRkgTQKtlSAKkbVgjXSP42eSBQ(TsdhuDCsfrlxLNt00vCDcTDsPVtQA8ijDEKuRxKQ5lc7hysfcmeOspib2QOtvvOtAw1BPQsxvv)3Ukc0qnCKabVzuPFqcK3cibQE5w5a468(bjqWBQnBxiWqGKR4Xqc0RzGl1bn08eZlXVITc0idbrtpX6SRTdnYqGrdb6lgMjn6KpbQ0dsGTk6uvf6KMv9wQQ0vv1V(VfbQfNx7rGGcH0sGEfLc6KpbQGsgbsN3piGxVCRCaA0i6iGx1BvhGxfDQQcqdqtAF1(dk1bqt9gW1Pxp1a4HZmIfeWP1eova8WbCD(QffqFa80q9QUb8KGVYyI1d)bWdjG3aoCttnEaEbzHmwpzGM6nGRZBQGaUCfqapLnEEn5df6WLPaC0NlqjG3WHBOgWNfW)Ruc42451ib81nuRiqMqoscmeOcABrZqGHaBfcmei07VbleAjqSlg8IMavpa(j6ODVhuvcjlGBcVpQZSvqO9Ic9(BWcGxdWl4x0AvSwoH)OeHd41a8c(fTwfRLt4pQdf6WLaoDd4va8ejaC2UMYQ3vFrRnxcjlGBcVpQZSvqO9I6WUqnGxdW)IwRQeswa3eEFuNzRGq7LCFS2rvz17eOMnX6ei2k6dEs4OXqgcSvrGHaHE)nyHqlbQztSobI1gtUztSE2eYHazc5K9wajqSIKmey1fbgce693GfcTeOMnX6eiwBm5MnX6ztihcKjKt2BbKaHsj6musgcS1Nadbc9(BWcHwce7IbVOjqnBcTygDuiqjG)ofaxxeOMnX6eiwBm5MnX6ztihcKjKt2BbKa1lsgcSVnbgce693GfcTei2fdErtGA2eAXm6OqGsaNUbCDrGA2eRtGyTXKB2eRNnHCiqMqozVfqcKCidb20Kadbc9(BWcHwcuZMyDceRnMCZMy9SjKdbYeYj7TasGewTOa6dzidbc(HSv43dbgcSviWqGA2eRtG6J1oMdFqJbzdbc9(BWcHwYqGTkcmeOMnX6ei99GxgnOa6tBiqO3Fdwi0sgcS6Iadbc9(BWcHwce7IbVOjqnBcTygDuiqjG)ofaVkcuZMyDc03ePNEFfYqGT(eyiqO3Fdwi0sGyxm4fnbQztOfZOJcbkbCkaEfcuZMyDcK9w58xZqgYqG6fjWqGTcbgcuZMyDcK920rpV3NaHE)nyHqlziWwfbgcuZMyDc03ePNEFfce693GfcTKHaRUiWqGqV)gSqOLaXUyWlAcusa(HcD4H)K1h(GNmZEfgdGtbWPdGNibGxWVO1Q0h(GNmZEfgJQS6DapzaVgGNeGd)qT5hwrvrH)1)Rza8eja8VO1Q(xhE2EiMoQoSzdGxdW)IwRYg(dEY8AZ2BLJ6WMnaofaNoaEYeOMnX6eiRr8oQjdb26tGHa1SjwNafmm7R2MaHE)nyHqlziW(2eyiqnBI1jqSvaNSC2tGaHE)nyHqlziWMMeyiqO3Fdwi0sGyxm4fnb6lATkB4p4jZRnBVvoQdB2a4jsa4f8lATk7TPJU6qHoCjG)oGpxRfn5jeqaprca)qHo8WFY6dFWtMzVcJbWRb4f8lATk9Hp4jZSxHXOouOdxc4Vd4Z1ArtEcbKa1SjwNafmmBANHKHaRoJadbc9(BWcHwce7IbVOjqYv08dVOyRWVNSawIPNyDf693GfcuZMyDc01LO9jlH3hvidb23IadbQztSobsiUBpzET5zpb0hce693GfcTKHaRobbgcuZMyDcK8vyNWFYWx94rGqV)gSqOLmeyRqhcmei07VbleAjqSlg8IMaDIoA37bvpxinuNdwWmOc9(BWcGxdWN(EWrzqTObWPBkaUb1IgaVgGxWVO1QS3Mo6QYQ3jqnBI1jq2BLt2xTnziWwPcbgce693GfcTei2fdErtGorhT79GQsizbCt49rDMTccTxuO3Fdwa8AaoBxtz17QVO1MlHKfWnH3h1z2ki0ErDyxOgWRb4FrRvvcjlGBcVpQZSvqO9s2ghQkRENa1SjwNazJdZFtlhYqGTsveyiqO3Fdwi0sGyxm4fnbsO9wbNna(7aUUOdGxdWB2eAXm6OqGsa)DkaEAc41a86bWprhT79GQhtZI2KTx)iG(ivO3FdwiqnBI1jq9XAhZivHBwzSoziWwrxeyiqnBI1jq4F9)Agce693GfcTKHaBL6tGHaHE)nyHqlbIDXGx0eOt0r7EpO6X0SOnz71pcOpsf693GfaVgGpTb9rjHBIzc)jhmuHE)nybWRb4Z1ArtEcbeWPBa)5wrVK7fvFtKE69vuhk0HljqnBI1jqbdZM2ziziWw5TjWqGA2eRtGS3kN)Agce693GfcTKHmeiwrsGHaBfcmei07VbleAjqnBI1jqYxDz1JL8E)8AZZEcOpei2fdErtG(IwR6eDmV2m8vpEQYQ3jqElGei5RUS6XsEVFET5zpb0hYqGTkcmei07VbleAjqSlg8IMab)qT51AZpSIkyuN1IHlb8eja8)kLaEna3gpVM8HcD4saNUbCDrhcuZMyDce8DI1jdbwDrGHa1SjwNavWEE93Zrce693GfcTKHaB9jWqGqV)gSqOLaXUyWlAcuZMqlMrhfcuc40nGRlaVgGNeGZwVigJsgWFTowYcTjyOc9(BWcGNibGlxrZp8IsFlh00Ejd)w4xGd1k07VblaEYeOMnX6eiH4U9K51MN9eqFidb23Madbc9(BWcHwce7IbVOjqSDnLvVRcg1zTy4s1HcD4sa)DaVsvaEna)lATQt0X8AZWx94PkRENa1SjwNaDIoMxBg(QhpYqGnnjWqGqV)gSqOLaXUyWlAc0x0AvNOJ51MHV6Xtvw9oGxdWtcW)IwRkyuN1IHlvLvVd4jsa4tBqFuNOJ51MHV6XtHE)nybWtgWRb4jb4FrRvjnbJk5GHQYQ3b8eja8MnHwmJokeOeWFNcGxfGNmbQztSobkyuN1IHljdbwDgbgce693GfcTei2fdErtGorhT79GQbfGVxBY67dUc9(BWcGxdW)IwRcP6RwuoX6kr4aEnapjah(HAZR1MFyfvWOoRfdxc4jsa4)vkb8AaUnEEn5df6WLaoDd41NoaEYeOMnX6eOjeWS((GtgcSVfbgcuZMyDcKOeZXGcsce693GfcTKHaRobbgcuZMyDc03SBjBfpQjqO3Fdwi0sgcSvOdbgcuZMyDc0hpjEuj8hce693GfcTKHaBLkeyiqnBI1jqM451iZ0felpcOpei07VbleAjdb2kvrGHa1SjwNazJd)MDlei07VbleAjdb2k6IadbQztSobQDgkNRnzwBmei07VbleAjdb2k1NadbQztSob63p51MNlyursGqV)gSqOLmKHajhcmeyRqGHaHE)nyHqlbIDXGx0eOKa8df6Wd)jRp8bpzM9kmgaNcGthaprcaVGFrRvPp8bpzM9kmgvz17aEYaEnapjah(HAZpSIQIc)R)xZa4jsa4FrRv9Vo8S9qmDuDyZgaVgGNeGd)qT5hwrvr9yAw0MSeEqfeWtKaWHFO28dROQOS3kN)AgaVgGNeGxpaoB9IymQ4W8AZZlm3sg6fSOqV)gSa4jsa4SDnLvVRUUeTpzj8(OI6qHoCjGNibGFIoA37bv2dX0d)jRp8IuHE)nybWtgWtKaWHFO28dROQOUUeTpzj8(OcGNibG)fTwLn8h8K51MT3kh1HnBaCkaoDa8AaEsaEb)IwRsiUBpzET5zpb0hLiCaprca)lATk7Hy6H)K1hErQeHd4jsa4FrRvHufE7fSKHVd6t0g1HnBa8Kb8Kb8KjqnBI1jqwJ4DutgcSvrGHa1SjwNazVnD0Z79jqO3Fdwi0sgcS6Iadbc9(BWcHwce7IbVOjqFrRvzpetp8N81HReHd4jsa4nBcTygDuiqjG)ofaVkcuZMyDc03ePNEFfYqGT(eyiqO3Fdwi0sGyxm4fnb6qHo8WFY6dFWtMzVcJbWPa4va8AaEb)IwRsF4dEYm7vymQdf6WLeOMnX6eORPoV2S9w5qgcSVnbgce693GfcTei2fdErtGouOdp8NS(Wh8Kz2RWya8AaEb)IwRsF4dEYm7vymQdf6WLa(7aoRLtEcbeWPhWNR1IM8ecibQztSob6X0SOnzj8GkiziWMMeyiqO3Fdwi0sGyxm4fnb6qHo8WFY6dFWtMzVcJbWRb4hk0Hh(twF4dEYm7vyma(7a(x0Av2WFWtMxB2ERCuh2SbWRb4f8lATk9Hp4jZSxHXOouOdxc4Vd4Z1ArtEcbKa1SjwNafmmBANHKHaRoJadbQztSobITc4KLZEcei07VbleAjdb23IadbQztSobkyy2xTnbc9(BWcHwYqGvNGadbc9(BWcHwce7IbVOjqFrRvzpetp8NS(WlsLiCaVgG3Sj0Iz0rHaLaofaVcbQztSob66s0(KLW7JkKHaBf6qGHaHE)nyHqlbIDXGx0eOVO1Q(xhE2EiMoQoSzdGxdWN2G(OEmnlAtwcpOcQqV)gSa41aC26fXyuXH51MNxyULm0lyrHE)nybWRb4FrRvfSGzqPsonJka(7ua86tGA2eRtGUUeTpzj8(OcziWwPcbgce693GfcTei2fdErtG(IwRYg(dEY8AZ2BLJ6WMnaEIeaEb)IwRYEB6ORouOdxc4Vd4Z1ArtEcbKa1SjwNafmmBANHKHaBLQiWqGA2eRtGW)6)1mei07VbleAjdb2k6Iadbc9(BWcHwce7IbVOjqjb41dGpTb9r9yAw0MSeEqfuHE)nybWtKaWRhaNTErmgvCyET55fMBjd9cwuO3Fdwa8Kb8AaEsaE9a4NOJ29EqL9qm9WFY6dVivO3Fdwa8eja8MnHwmJokeOeWFNcGxfGNmGxdW)IwR6FD4z7Hy6O6WMneOMnX6eORlr7twcVpQqgcSvQpbgcuZMyDcKqC3EY8AZZEcOpei07VbleAjdb2kVnbgce693GfcTei2fdErtG(IwR6eDmV2m8vpEQYQ3b8AaEsa(j6ODVhu9c7BYRnpVWSTrf693GfaprcaxUIMF4f1ZTAXC4AJN96jwxHE)nybWtKaWLRO5hErzd0uYRn)nRuUcsf693Gfaprca)eD0U3dQShIPh(twF4fPc9(BWcGxdW)IwRYEiME4pz9HxKQYQ3b8eja8MnHwmJokeOeWFNcGxfGNmbQztSobs(kSt4pz4RE8idb2kPjbgce693GfcTei2fdErtGorhT79GQNlKgQZblyguHE)nybWRb4tFp4OmOw0a40nfa3GArdGxdWl4x0Av2BthDvz17eOMnX6ei7TYj7R2MmeyROZiWqGqV)gSqOLaXUyWlAc0j6ODVhuvcjlGBcVpQZSvqO9Ic9(BWcGxdWz7AkREx9fT2CjKSaUj8(OoZwbH2lQd7c1aEna)lATQsizbCt49rDMTccTxY9XAhvLvVtGA2eRtG6J1oMrQc3SYyDYqGTYBrGHaHE)nyHqlbIDXGx0eOt0r7EpOQeswa3eEFuNzRGq7ff693GfaVgGZ21uw9U6lAT5sizbCt49rDMTccTxuh2fQb8Aa(x0AvLqYc4MW7J6mBfeAVKTXHQYQ3jqnBI1jq24W830YHmeyROtqGHaHE)nyHqlbIDXGx0eOVO1Q(xhE2EiMoQoSzdbQztSob6X0SOnzj8GkiziWwfDiWqGA2eRtGS3kN)Agce693GfcTKHmeiHvlkG(qGHaBfcmei07VbleAjqSlg8IMa9fTwvWWS1SOuvw9obQztSobkyy2AwusgcSvrGHaHE)nyHqlbIDXGx0eiH2BfC2a4Vd46IoaEnaVztOfZOJcbkb83Pa4vrGA2eRtG6J1oMrQc3SYyDYqGvxeyiqnBI1jq24W830YHaHE)nyHqlziWwFcmeOMnX6eOGHzt7mKaHE)nyHqlzidziqAXtgRtGTk6uvf6ORQ0fbsFFE4psceDzAGUg20iS0v6aWbCyEHaEiaFVbWT7b4PkOTfntka)qDsX4WcGlxbeWBXzf6blao7v7pOub0O7WraVIoa80UUw8gSa4PorhT79GQQtb4Zc4PorhT79GQQvO3Fdwsb4jvHQjRaAaAOltd01WMgHLUshaoGdZleWdb47naUDpapvVyka)qDsX4WcGlxbeWBXzf6blao7v7pOub0O7WraxNPdapTRRfVblaEk5kA(HxuvNcWNfWtjxrZp8IQAf693GLuaEpaUofDrDd4jvHQjRaA0D4iGxHo6aWt76AXBWcGN6eD0U3dQQofGplGN6eD0U3dQQwHE)nyjfGNufQMScOr3HJaELk6aWt76AXBWcGN6eD0U3dQQofGplGN6eD0U3dQQwHE)nyjfGNufQMScOr3HJaELQ0bGN211I3Gfap1j6ODVhuvDkaFwap1j6ODVhuvTc9(BWskaVhaxNIUOUb8KQq1Kvan6oCeWRuFDa4PDDT4nybWtnTb9rvDkaFwap10g0hv1k07VblPa8KQq1Kvan6oCeWRuFDa4PDDT4nybWtDIoA37bvvNcWNfWtDIoA37bvvRqV)gSKcWtQcvtwb0a0qxMgORHnnclDLoaCahMxiGhcW3BaC7EaEkwrMcWpuNumoSa4Yvab8wCwHEWcGZE1(dkvan6oCeWRVoa80UUw8gSa4PyRxeJrvDkaFwapfB9IymQQvO3Fdwsb4jvHQjRaA0D4iGxFDa4PDDT4nybWtjxrZp8IQ6ua(SaEk5kA(HxuvRqV)gSKcWtQcvtwb0O7Wrapn1bGN211I3Gfap10g0hv1Pa8zb8utBqFuvRqV)gSKcWtQcvtwb0O7WraxNPdapTRRfVblaEQt0r7EpOQ6ua(SaEQt0r7EpOQAf693GLuaEsvOAYkGgGg6Y0aDnSPryPR0bGd4W8cb8qa(EdGB3dWtjNua(H6KIXHfaxUciG3IZk0dwaC2R2FqPcOr3HJaEfDa4PDDT4nybWtDIoA37bvvNcWNfWtDIoA37bvvRqV)gSKcWtQcvtwb0O7WraVIoa80UUw8gSa4PyRxeJrvDkaFwapfB9IymQQvO3Fdwsb4jvHQjRaA0D4iGxHo6aWt76AXBWcGNAAd6JQ6ua(SaEQPnOpQQvO3Fdwsb4jvHQjRaA0D4iGxHo6aWt76AXBWcGNITErmgv1Pa8zb8uS1lIXOQwHE)nyjfGNufQMScOr3HJaEfDPdapTRRfVblaEQPnOpQQtb4Zc4PM2G(OQwHE)nyjfGNufQMScOr3HJaEfDPdapTRRfVblaEQt0r7EpOQ6ua(SaEQt0r7EpOQAf693GLuaEsvOAYkGgDhoc4v0Loa80UUw8gSa4PyRxeJrvDkaFwapfB9IymQQvO3Fdwsb4jvHQjRaA0D4iGx5T1bGN211I3Gfap1j6ODVhuvDkaFwap1j6ODVhuvTc9(BWskapPQOAYkGgDhoc4vEBDa4PDDT4nybWtjxrZp8IQ6ua(SaEk5kA(HxuvRqV)gSKcWtQkQMScOr3HJaEL0uhaEAxxlEdwa8uNOJ29Eqv1Pa8zb8uNOJ29Eqv1k07VblPa8KQq1Kvan6oCeWROZ0bGN211I3Gfap1j6ODVhuvDkaFwap1j6ODVhuvTc9(BWskapPkunzfqJUdhb8kVLoa80UUw8gSa4PorhT79GQQtb4Zc4PorhT79GQQvO3Fdwsb4jvHQjRaAaAsJcW3BWcGNMaEZMyDa3eYrQaAiqs4iJaBAwFce8BTHbjqV5naUoVFqaVE5w5a08M3a4AeDeWR6TQdWRIovvbObO5nVbWt7R2FqPoaAEZBa86nGRtVEQbWdNzeliGtRjCQa4Hd468vlkG(a4PH6vDd4jbFLXeRh(dGhsaVbC4MMA8a8cYczSEYanV5naE9gW15nvqaxUciGNYgpVM8HcD4Yuao6ZfOeWB4Wnud4Zc4)vkbCB88AKa(6gQvananV5naUofvrM4Gfa)J29qaNTc)Ea8p(eUub4PbgdHpsa3xVE)QpbRObWB2eRlb81nuRaAA2eRlvWpKTc)EONcn9XAhZHpOXGSbOPztSUub)q2k87HEk0iffewpRVh8YObfqFAdqtZMyDPc(HSv43d9uO5BI0tVVsDHLsZMqlMrhfcu(oLQaAA2eRlvWpKTc)EONcn2BLZFntDHLsZMqlMrhfcusPcqdqZBEdGRtrvKjoybWrT4rnGpHac4ZleWB2ShGhsaV12HP)gub00SjwxsHTI(GNeoAm1fwk1Zj6ODVhuvcjlGBcVpQZSvqO9sTc(fTwfRLt4pkr41k4x0AvSwoH)OouOdxs3vsKGTRPS6D1x0AZLqYc4MW7J6mBfeAVOoSlux7lATQsizbCt49rDMTccTxY9XAhvLvVd00SjwxspfAyTXKB2eRNnHCQZBbKcRibAA2eRlPNcnS2yYnBI1ZMqo15TasbLs0zOeOPztSUKEk0WAJj3SjwpBc5uN3ciLEX6clLMnHwmJokeO8Dk6cOPztSUKEk0WAJj3SjwpBc5uN3cif5uxyP0Sj0Iz0rHaL0TUaAA2eRlPNcnS2yYnBI1ZMqo15Tasry1IcOpanannBI1LQErk2Bth98EFGMMnX6svVi9uO5BI0tVVcqtZMyDPQxKEk0ynI3rDDHLsshk0Hh(twF4dEYm7vymuOtIef8lATk9Hp4jZSxHXOkREp5Ajb)qT5hwrvrH)1)RzsK4lATQ)1HNThIPJQdB2u7lATkB4p4jZRnBVvoQdB2qHojd00SjwxQ6fPNcnbdZ(QTbAA2eRlv9I0tHg2kGtwo7ja00SjwxQ6fPNcnbdZM2zyDHLYx0Av2WFWtMxB2ERCuh2SjrIc(fTwL920rxDOqhU895ATOjpHaMiXHcD4H)K1h(GNmZEfgtTc(fTwL(Wh8Kz2RWyuhk0HlFFUwlAYtiGannBI1LQEr6PqZ1LO9jlH3hvQlSuKRO5hErXwHFpzbSetpX6annBI1LQEr6PqJqC3EY8AZZEcOpannBI1LQEr6PqJ8vyNWFYWx94b00SjwxQ6fPNcn2BLt2xTDDHLYj6ODVhu9CH0qDoybZG1M(EWrzqTOHUPyqTOPwb)IwRYEB6ORkREhOPztSUu1lspfASXH5VPLtDHLYj6ODVhuvcjlGBcVpQZSvqO9sn2UMYQ3vFrRnxcjlGBcVpQZSvqO9I6WUqDTVO1QkHKfWnH3h1z2ki0EjBJdvLvVd00SjwxQ6fPNcn9XAhZivHBwzSEDHLIq7TcoBExx0PwZMqlMrhfcu(oL0Sw9CIoA37bvpMMfTjBV(ra9rc00SjwxQ6fPNcn4F9)AgGMMnX6svVi9uOjyy20odRlSuorhT79GQhtZI2KTx)iG(iRnTb9rjHBIzc)jhmS2CTw0KNqaP7NBf9sUxu9nr6P3xrDOqhUeO5nVbWB2eRlv9I0tHg9Dm1jrgf6OQuxyPCIoA37bvpMMfTjBV(ra9rwBAd6Jsc3eZe(toyiqtZMyDPQxKEk0yVvo)1manannBI1LkwrsruI5yqH68waPiF1LvpwY79ZRnp7jG(uxyP8fTw1j6yETz4RE8uLvVd00SjwxQyfj9uOb(oX61fwkWpuBET28dROcg1zTy4Yej(RuwZgpVM8HcD4s6wx0bOPztSUuXks6Pqtb751FphbAA2eRlvSIKEk0ie3TNmV28SNa6tDHLsZMqlMrhfcus36QwsS1lIXOKb8xRJLSqBcgMiHCfn)Wlk9TCqt7Lm8BHFbouNmqtZMyDPIvK0tHMt0X8AZWx94vxyPW21uw9UkyuN1IHlvhk0HlFVsv1(IwR6eDmV2m8vpEQYQ3bAA2eRlvSIKEk0emQZAXWL1fwkFrRvDIoMxBg(Qhpvz171s6lATQGrDwlgUuvw9EIetBqFuNOJ51MHV6Xl5Aj9fTwL0emQKdgQkREprIMnHwmJokeO8DkvLmqtZMyDPIvK0tHMjeWS((GxxyPCIoA37bvdkaFV2K13h8AFrRvHu9vlkNyDLi8Ajb)qT51AZpSIkyuN1IHltK4VsznB88AYhk0HlP76tNKbAA2eRlvSIKEk0ikXCmOGeOPztSUuXks6PqZ3SBjBfpQbAA2eRlvSIKEk08XtIhvc)bOPztSUuXks6PqJjEEnYmDbXYJa6dqtZMyDPIvK0tHgBC43SBbOPztSUuXks6Pqt7muoxBYS2yaAA2eRlvSIKEk087N8AZZfmQibAaAEZBaCD6q2Fdwa8pYArjc40AcNk0a9keeWdWdjG3aoCttnEao71gmub08M3a4nBI1LkHvlkG(q5BcNk52PUUWsry1IcOpQsiN2z47vOdqtZMyDPsy1IcOp0tHMGHzRzrzDHLYx0AvbdZwZIsvz17annBI1LkHvlkG(qpfA6J1oMrQc3SYy96clfH2BfC28UUOtTMnHwmJokeO8Dkvb00SjwxQewTOa6d9uOXghM)MwoannBI1LkHvlkG(qpfAcgMnTZqGgGMMnX6sLCOynI3rDDHLsshk0Hh(twF4dEYm7vymuOtIef8lATk9Hp4jZSxHXOkREp5Ajb)qT5hwrvrH)1)RzsK4lATQ)1HNThIPJQdB2ulj4hQn)WkQkQhtZI2KLWdQGjsa)qT5hwrvrzVvo)1m1sQEyRxeJrfhMxBEEH5wYqVGLejy7AkRExDDjAFYs49rf1HcD4YejorhT79Gk7Hy6H)K1hErMCIeWpuB(HvuvuxxI2NSeEFujrIVO1QSH)GNmV2S9w5OoSzdf6ulPc(fTwLqC3EY8AZZEcOpkr4js8fTwL9qm9WFY6dVivIWtK4lATkKQWBVGLm8DqFI2OoSztYjNmqtZMyDPso0tHg7TPJEEVpqtZMyDPso0tHMVjsp9(k1fwkFrRvzpetp8N81HReHNirZMqlMrhfcu(oLQaAA2eRlvYHEk0Cn151MT3kN6clLdf6Wd)jRp8bpzM9kmgkvQvWVO1Q0h(GNmZEfgJ6qHoCjqtZMyDPso0tHMhtZI2KLWdQG1fwkhk0Hh(twF4dEYm7vym1k4x0Av6dFWtMzVcJrDOqhU8DwlN8eci9Z1ArtEcbeOPztSUujh6PqtWWSPDgwxyPCOqhE4pz9Hp4jZSxHXu7qHo8WFY6dFWtMzVcJ59VO1QSH)GNmV2S9w5OoSztTc(fTwL(Wh8Kz2RWyuhk0HlFFUwlAYtiGannBI1Lk5qpfAyRaoz5SNaqtZMyDPso0tHMGHzF12annBI1Lk5qpfAUUeTpzj8(OsDHLYx0Av2dX0d)jRp8IujcVwZMqlMrhfcusPcqtZMyDPso0tHMRlr7twcVpQuxyP8fTw1)6WZ2dX0r1HnBQnTb9r9yAw0MSeEqfSgB9IymQ4W8AZZlm3sg6fSu7lATQGfmdkvYPzu5Dk1hOPztSUujh6PqtWWSPDgwxyP8fTwLn8h8K51MT3kh1HnBsKOGFrRvzVnD0vhk0HlFFUwlAYtiGannBI1Lk5qpfAW)6)1mannBI1Lk5qpfAUUeTpzj8(OsDHLss1Z0g0h1JPzrBYs4bvWejQh26fXyuXH51MNxyULm0lyj5AjvpNOJ29EqL9qm9WFY6dVitKOztOfZOJcbkFNsvjx7lATQ)1HNThIPJQdB2a00SjwxQKd9uOriUBpzET5zpb0hGMMnX6sLCONcnYxHDc)jdF1JxDHLYx0AvNOJ51MHV6Xtvw9ETKorhT79GQxyFtET55fMTnMiHCfn)WlQNB1I5W1gp71tSEIeYv08dVOSbAk51M)MvkxbzIeNOJ29EqL9qm9WFY6dViR9fTwL9qm9WFY6dVivLvVNirZMqlMrhfcu(oLQsgOPztSUujh6PqJ9w5K9vBxxyPCIoA37bvpxinuNdwWmyTPVhCugulAOBkgulAQvWVO1QS3Mo6QYQ3bAA2eRlvYHEk00hRDmJufUzLX61fwkNOJ29EqvjKSaUj8(OoZwbH2l1y7AkREx9fT2CjKSaUj8(OoZwbH2lQd7c11(IwRQeswa3eEFuNzRGq7LCFS2rvz17annBI1Lk5qpfASXH5VPLtDHLYj6ODVhuvcjlGBcVpQZSvqO9sn2UMYQ3vFrRnxcjlGBcVpQZSvqO9I6WUqDTVO1QkHKfWnH3h1z2ki0EjBJdvLvVd00SjwxQKd9uO5X0SOnzj8GkyDHLYx0Av)RdpBpethvh2SbOPztSUujh6PqJ9w58xZqgYqia]] )


end
