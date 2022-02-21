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

    local lastCometCast = 0
    local lastAutoComet = 0

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

            if ( spellID == 153595 or spellID == 153596 ) then
                local t = GetTime()
    
                if subtype == "SPELL_CAST_SUCCESS" then
                    lastCometCast = t
                elseif subtype == "SPELL_DAMAGE" and t - lastCometCast > 3 and t - lastAutoComet > 3 then
                    -- TODO:  Revisit strategy for detecting auto comets.
                    lastAutoComet = t
                end
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

        f = CreateFrame( "Frame" ),
        fRegistered = false,

        reset = setfenv( function ()
            if talent.incanters_flow.enabled then
                if not incanters_flow.fRegistered then
                    Hekili:ProfileFrame( "Incanters_Flow_Frost", incanters_flow.f )
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 363535, "tier28_4pc", 364544 )
    -- 2-Set - Frost Storm - Your spells have a 25% chance to call down a Comet Storm on your target enemy. This effect cannot occur more than once every 20 sec.
    -- 4-Set - Frost Storm - Enemies hit by Comet Storm take 2% increased damage from your Frost Spells, up to 10% for 8 sec.
    spec:RegisterAura( "frost_storm", {
        id = 363544,
        duration = 8,
        max_stack = 5,
    } )

    -- Track ICD?
    spec:RegisterAbility( "frost_storm", {
        cast = 0,
        cooldown = 20,
        gcd = "off",

        unlisted = true,
        known = function () return set_bonus.tier28_2pc > 0 end,
    } )


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

        if set_bonus.tier28_3pc > 0 and now - lastAutoComet < 20 then
            setCooldown( "frost_storm", lastAutoComet + 20 - now )
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
            cooldown = function () return level > 53 and 270 or 300 end,
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
                if set_bonus.tier28_4pc > 0 then
                    applyDebuff( "target", "frost_storm" )
                    active_dot.frost_storm = max( 1, active_enemies )
                end
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
    
    spec:RegisterPack( "Frost Mage", 20211123, [[dO063aqijr1JufvBsv4tIuJsK0PejEfHYSKKClqiSls(fsXWqQ4yKQwMQipdPktdeQRPkkTnjr5BeQOXbcjNdeIwhsvnpKk19aP9bcoiHk1crk9qjrMiHk0frQeTrvrr(isLuNuvuyLKkZKqv3KqLStvj)ees1qvff1srQeEkOMki6ReQGXkj1Er8xrnyuDyPwSQ6XOmzjUm0MP0NLuJwvQtlSAqiLxJKy2uCBc2nv)wPHJehhPsYYv55enDfxNu2oH8Dr04rs68iPwVKW8fH9dmrpbscCPhK86j68KE96FIEQN0tp690ZsGhQPGeyknJkDnsG9wajWpt3khaxC11ibMstTz7cbscSC1ogsGFpdfj9PHM6yER9vSvGgziOz6jwNDTDOrgcmAiWFTWmpdN8jWLEqYRNOZt61R)j6PEsp9O3t6jWT28EpcmCiujc87OuqN8jWfuYiWIRUgb8NPBLdq3Rvek8XdW1tVQa8NOZt6b6a6Q072Rrj9b6GiaCXX1tpaE4mJwbbCAnHtfapCaxCTIqb0haxC)mlEapvkRmMy9WRb8qc4nGtX0uJhGxqwiJ1tbOdIaWfxnvqaxUciGN2g1VN8HcD4Y0ao6ZfOeWBkumud4Zc4)vkbCBu)EKa(6gQveytihjbscCbTTMziqsEPNajbg9(BWcHwcm7IbVOjWvoGFAoA3RgvLqYckMW7J6mBfeAVOqV)gSa4pa8c(1SwfRLt41knka(daVGFnRvXA5eET6qHoCjGt3aUEaprcaNTRPSjD1xZAZLqYckMW7J6mBfeAVOoSlud4pa8VM1QkHKfumH3h1z2ki0Ej3hRDuv2KobUztSobMTA(GNKcAmKH86jcKey07VbleAjWnBI1jWS2yYnBI1ZMqoeytiNS3cibMvKKH8IEeijWO3Fdwi0sGB2eRtGzTXKB2eRNnHCiWMqozVfqcmkLOZqjziVGycKey07VbleAjWSlg8IMa3SjeHz0rHaLaoeGc40JalNlyd5LEcCZMyDcmRnMCZMy9SjKdb2eYj7TasG7fjd51ZsGKaJE)nyHqlbMDXGx0e4MnHimJokeOeWPBaNEey5CbBiV0tGB2eRtGzTXKB2eRNnHCiWMqozVfqcSCid5vLrGKaJE)nyHqlbUztSobM1gtUztSE2eYHaBc5K9wajWcRiua9HmKHat5q2k87Haj5LEcKe4MnX6e4(yTJ5Wh0yq2qGrV)gSqOLmKxprGKa3SjwNaNSh8YObfqFAdbg9(BWcHwYqErpcKey07VbleAjWSlg8IMa3SjeHz0rHaLaoeGc4prGB2eRtG)MOIk6RqgYliMajbg9(BWcHwcm7IbVOjWnBcrygDuiqjGdfW1tGB2eRtGT3kN)AgYqgcCVibsYl9eijWnBI1jW2BRa98EFcm693GfcTKH86jcKe4MnX6e4VjQOI(key07VbleAjd5f9iqsGrV)gSqOLaZUyWlAcCQa(HcD4HxNtg(GNmZEhgdGdfWPdGNibGxWVM1Qsg(GNmZEhgJQSjDapfa)bGNkGt5qr5AwrPxH)1)Rza8eja8VM1Q(xhE2EiwbQoSzdG)aW)AwRYgEnEY8AZ2BLJ6WMnaouaNoaEke4MnX6eyRr7oQjd5fetGKa3SjwNahmm7ROMaJE)nyHqlziVEwcKe4MnX6ey2kGtwo7jqGrV)gSqOLmKxvgbscm693GfcTey2fdErtG)AwRYgEnEY8AZ2BLJ6WMnaEIeaEb)AwRYEBfORouOdxc4qaWNRfHM8eciGNibGFOqhE415KHp4jZS3HXa4pa8c(1SwvYWh8Kz27Wyuhk0HlbCia4Z1IqtEcbKa3SjwNahmmBANHKH8sCsGKaJE)nyHqlbMDXGx0ey5Qz(HxuSv43twalX0tSUc9(BWcbUztSob(6s0(KLu6JkKH8cIIajbUztSobwiUBpzET5zpb0hcm693GfcTKH8cIKajbUztSobw(oSt41zkBs8iWO3Fdwi0sgYl90Hajbg9(BWcHwcm7IbVOjWNMJ29Qrv9fsd15GfmdQqV)gSa4pa8PVACugueAaC6gkGBqrObWFa4f8RzTk7TvGUQSjDcCZMyDcS9w5K9vutgYl96jqsGrV)gSqOLaZUyWlAc8P5ODVAuvcjlOycVpQZSvqO9Ic9(BWcG)aWz7AkBsx91S2CjKSGIj8(OoZwbH2lQd7c1a(da)RzTQsizbft49rDMTccTxY24qvzt6e4MnX6eyBCy(BA5qgYl9prGKaJE)nyHqlbMDXGx0eyH2Bff2a4qaWPhDa8haEZMqeMrhfcuc4qakGxza(daVYb8tZr7E1OQ20SOnz711cOpsf693GfcCZMyDcCFS2XmsvkMvgRtgYl90JajbUztSobg)R)xZqGrV)gSqOLmKx6HycKey07VbleAjWSlg8IMaFAoA3Rgv1MMfTjBVUwa9rQqV)gSa4pa8ub8PnOpkjftmt415GHk07VblaEIeaEZMqeMrhfcuc4qakG)SaEka(daFUweAYtiGaoDd413Q5LCVO6BIkQOVI6qHoCjbUztSoboyy20odjd5L(NLajbUztSob2ERC(RziWO3Fdwi0sgYqGzfjbsYl9eijWO3Fdwi0sGB2eRtGLV7YMel59(51MN9eqFiWSlg8IMa)1Sw1P5yETzkBs8uLnPtG9wajWY3DztIL8E)8AZZEcOpKH86jcKey07VbleAjWSlg8IMat5qr51AZ1SIkyuNfHHlb8eja8)kLa(da3g1VN8HcD4saNUbC6rhcCZMyDcmLDI1jd5f9iqsGB2eRtGlypV)75ibg9(BWcHwYqEbXeijWO3Fdwi0sGzxm4fnbUzticZOJcbkbC6gWPhG)aWtfWzRx0IrjdkVxhlzH2emuHE)nybWtKaWLRM5hErLSLdAAVKPClLlWHAf693Gfapfa)bG)1Sw1)6WZ2dXkq1HnBaCOaoDiWnBI1jWcXD7jZRnp7jG(qgYRNLajbg9(BWcHwcm7IbVOjWSDnLnPRcg1zry4s1HcD4sahcaU(Na8ha(xZAvNMJ51MPSjXtv2KobUztSob(0CmV2mLnjEKH8QYiqsGrV)gSqOLaZUyWlAc8xZAvNMJ51MPSjXtv2KoG)aWtfW)AwRkyuNfHHlvLnPd4jsa4tBqFuNMJ51MPSjXtHE)nybWtbWFa4Pc4FnRvjnbJk5GHQYM0b8eja8MnHimJokeOeWHaua)japfcCZMyDcCWOolcdxsgYlXjbscm693GfcTey2fdErtGpnhT7vJQbfOSxBYj7JIc9(BWcG)aW)AwRcP67wtoX6knka(dapvaNYHIYR1MRzfvWOolcdxc4jsa4)vkb8haUnQFp5df6WLaoDd4qmDa8uiWnBI1jWtiG5K9rHmKxqueijWnBI1jWAsmhdkijWO3Fdwi0sgYliscKe4MnX6e4Vz3s2QDutGrV)gSqOLmKx6PdbscCZMyDc8hpjEuj8Acm693GfcTKH8sVEcKe4MnX6eytu)EKziAALAb0hcm693GfcTKH8s)teijWnBI1jW24WVz3cbg9(BWcHwYqEPNEeijWnBI1jWTZq5CTjZAJHaJE)nyHqlziV0dXeijWnBI1jW)UoV28CbJkscm693GfcTKHmey5qGK8spbscm693GfcTey2fdErtGtfWpuOdp86CYWh8Kz27WyaCOaoDa8eja8c(1SwvYWh8Kz27WyuLnPd4Pa4pa8ubCkhkkxZkk9k8V(FndGNibG)1Sw1)6WZ2dXkq1HnBa8haEQaoLdfLRzfLEvTPzrBYskbvqaprcaNYHIY1SIsVYERC(Rza8haEQaELd4S1lAXOIdZRnpVXClzOxWIc9(BWcGNibGZ21u2KU66s0(KLu6JkQdf6WLaEIea(P5ODVAuzpeRi86CYWlsf693GfapfaprcaNYHIY1SIsV66s0(KLu6JkaEIea(xZAv2WRXtMxB2ERCuh2SbWHc40bWFa4Pc4f8RzTkH4U9K51MN9eqFuAua8eja8VM1QShIveEDoz4fPsJcGNibG)1SwfsvkTxWsMYoOprBuh2SbWtbWtbWtHa3SjwNaBnA3rnziVEIajbUztSob2EBfON37tGrV)gSqOLmKx0Jajbg9(BWcHwcm7IbVOjWFnRvzpeRi8681HR0Oa4jsa4nBcrygDuiqjGdbOa(te4MnX6e4VjQOI(kKH8cIjqsGrV)gSqOLaZUyWlAc8HcD4HxNtg(GNmZEhgdGdfW1d4pa8c(1SwvYWh8Kz27Wyuhk0HljWnBI1jWxtDETz7TYHmKxplbscm693GfcTey2fdErtGpuOdp86CYWh8Kz27Wya8haEb)AwRkz4dEYm7DymQdf6WLaoeaCwlN8eciGlgGpxlcn5jeqcCZMyDcCTPzrBYskbvqYqEvzeijWO3Fdwi0sGzxm4fnb(qHo8WRZjdFWtMzVdJbWFa4hk0HhEDoz4dEYm7Dymaoea8VM1QSHxJNmV2S9w5OoSzdG)aWl4xZAvjdFWtMzVdJrDOqhUeWHaGpxlcn5jeqcCZMyDcCWWSPDgsgYlXjbscCZMyDcmBfWjlN9eiWO3Fdwi0sgYlikcKe4MnX6e4GHzFf1ey07VbleAjd5fejbscm693GfcTey2fdErtG)AwRYEiwr415KHxKknka(daVzticZOJcbkbCOaUEcCZMyDc81LO9jlP0hvid5LE6qGKaJE)nyHqlbMDXGx0e4VM1Q(xhE2EiwbQoSzdG)aWN2G(OQnnlAtwsjOcQqV)gSa4paC26fTyuXH51MN3yULm0lyrHE)nybWFa4FnRvfSGzqPsonJkaoeGc4qmbUztSob(6s0(KLu6JkKH8sVEcKey07VbleAjWSlg8IMa)1SwLn8A8K51MT3kh1HnBa8eja8c(1SwL92kqxDOqhUeWHaGpxlcn5jeqcCZMyDcCWWSPDgsgYl9prGKa3SjwNaJ)1)RziWO3Fdwi0sgYl90Jajbg9(BWcHwcm7IbVOjWPc4voGpTb9rvBAw0MSKsqfuHE)nybWtKaWRCaNTErlgvCyET55nMBjd9cwuO3Fdwa8ua8haEQaELd4NMJ29QrL9qSIWRZjdVivO3Fdwa8eja8MnHimJokeOeWHaua)japfa)bG)1Sw1)6WZ2dXkq1HnBiWnBI1jWxxI2NSKsFuHmKx6HycKe4MnX6eyH4U9K51MN9eqFiWO3Fdwi0sgYl9plbscm693GfcTey2fdErtG)AwR60CmV2mLnjEQYM0b8haEQa(P5ODVAu9g7BYRnpVXSTrf693GfaprcaxUAMF4fv9TIWC4II696jwxHE)nybWtKaWLRM5hErzd0uYRn)nRuUcsf693Gfaprca)0C0UxnQShIveEDoz4fPc9(BWcG)aW)AwRYEiwr415KHxKQYM0b8eja8MnHimJokeOeWHaua)japfcCZMyDcS8DyNWRZu2K4rgYl9vgbscm693GfcTey2fdErtGpnhT7vJQ6lKgQZblyguHE)nybWFa4tF14OmOi0a40nua3GIqdG)aWl4xZAv2BRaDvzt6e4MnX6ey7TYj7ROMmKx6fNeijWO3Fdwi0sGzxm4fnb(0C0UxnQkHKfumH3h1z2ki0ErHE)nybWFa4SDnLnPR(AwBUeswqXeEFuNzRGq7f1HDHAa)bG)1SwvjKSGIj8(OoZwbH2l5(yTJQYM0jWnBI1jW9XAhZivPywzSoziV0drrGKaJE)nyHqlbMDXGx0e4tZr7E1OQeswqXeEFuNzRGq7ff693Gfa)bGZ21u2KU6RzT5sizbft49rDMTccTxuh2fQb8ha(xZAvLqYckMW7J6mBfeAVKTXHQYM0jWnBI1jW24W830YHmKx6HijqsGrV)gSqOLaZUyWlAc8xZAv)RdpBpeRavh2SHa3SjwNaxBAw0MSKsqfKmKxprhcKe4MnX6ey7TY5VMHaJE)nyHqlzidbwyfHcOpeijV0tGKaJE)nyHqlbMDXGx0e4VM1QcgMTMfLQYM0jWnBI1jWbdZwZIsYqE9ebscm693GfcTey2fdErtGfAVvuydGdbaNE0bWFa4nBcrygDuiqjGdbOa(te4MnX6e4(yTJzKQumRmwNmKx0JajbUztSob2ghM)Mwoey07VbleAjd5fetGKa3SjwNahmmBANHey07VbleAjdzidbweEYyDYRNOZt6PdeP(kJaNSpp8AjbwCqCtx86z8IUM(aoGd5BeWdbk7naUDpapDbTTMzsd4hsxPfhwaC5kGaERnRqpybWzVBVgLkGoXhoc46PpGxP1fH3Gfap9P5ODVAuvDAaFwap9P5ODVAuvTc9(BWsAapv9unffqhqN4G4MU41Z4fDn9bCahY3iGhcu2BaC7EaE6EX0a(H0vAXHfaxUciG3AZk0dwaC272RrPcOt8HJaU4K(aELwxeEdwa80YvZ8dVOQonGplGNwUAMF4fv1k07VblPb8EaC6si6IhWtvpvtrb0j(WraxpDOpGxP1fH3Gfap9P5ODVAuvDAaFwap9P5ODVAuvTc9(BWsAapv9unffqN4dhbC96PpGxP1fH3Gfap9P5ODVAuvDAaFwap9P5ODVAuvTc9(BWsAapv9unffqN4dhbC9prFaVsRlcVblaE6tZr7E1OQ60a(SaE6tZr7E1OQAf693GL0aEpaoDjeDXd4PQNQPOa6eF4iGRhIPpGxP1fH3Gfap90g0hv1Pb8zb80tBqFuvRqV)gSKgWtvpvtrb0j(WraxpetFaVsRlcVblaE6tZr7E1OQ60a(SaE6tZr7E1OQAf693GL0aEQ6PAkkGoGoXbXnDXRNXl6A6d4aoKVrapeOS3a429a80SImnGFiDLwCybWLRac4T2Sc9GfaN9U9AuQa6eF4iGdX0hWR06IWBWcGNMTErlgv1Pb8zb80S1lAXOQwHE)nyjnGNQEQMIcOt8HJaoetFaVsRlcVblaEA5Qz(HxuvNgWNfWtlxnZp8IQAf693GL0aEQ6PAkkGoXhoc4vg9b8kTUi8gSa4PN2G(OQonGplGNEAd6JQAf693GL0aEQ6PAkkGoXhoc4It6d4vADr4nybWtFAoA3RgvvNgWNfWtFAoA3RgvvRqV)gSKgWtvpvtrb0b0joiUPlE9mErxtFahWH8nc4HaL9ga3UhGNwoPb8dPR0IdlaUCfqaV1MvOhSa4S3TxJsfqN4dhbC90hWR06IWBWcGN(0C0UxnQQonGplGN(0C0UxnQQwHE)nyjnGNQEQMIcOt8HJaUE6d4vADr4nybWtZwVOfJQ60a(SaEA26fTyuvRqV)gSKgWtvpvtrb0j(WraxpDOpGxP1fH3Gfap90g0hv1Pb8zb80tBqFuvRqV)gSKgWtvpvtrb0j(WraxpDOpGxP1fH3GfapnB9IwmQQtd4Zc4PzRx0IrvTc9(BWsAapv9unffqN4dhbC90J(aELwxeEdwa80tBqFuvNgWNfWtpTb9rvTc9(BWsAapv9unffqN4dhbC90J(aELwxeEdwa80NMJ29Qrv1Pb8zb80NMJ29Qrv1k07VblPb8u1t1uuaDIpCeW1tp6d4vADr4nybWtZwVOfJQ60a(SaEA26fTyuvRqV)gSKgWtvpvtrb0j(Wrax)ZsFaVsRlcVblaE6tZr7E1OQ60a(SaE6tZr7E1OQAf693GL0aEQpr1uuaDIpCeW1)S0hWR06IWBWcGNwUAMF4fv1Pb8zb80YvZ8dVOQwHE)nyjnGN6tunffqN4dhbC9vg9b8kTUi8gSa4PpnhT7vJQQtd4Zc4PpnhT7vJQQvO3Fdwsd4PQNQPOa6eF4iGRxCsFaVsRlcVblaE6tZr7E1OQ60a(SaE6tZr7E1OQAf693GL0aEQ6PAkkGoXhoc46HOOpGxP1fH3Gfap9P5ODVAuvDAaFwap9P5ODVAuvTc9(BWsAapv9unffqhq3ZqGYEdwa8kdWB2eRd4MqosfqhbwsbzKxvgetGPCRnmib(5phWfxDnc4pt3khGUN)Ca)1kcf(4b46Pxva(t05j9aDaDp)5aELE3EnkPpq3ZFoGdra4IJRNEa8WzgTcc40AcNkaE4aU4AfHcOpaU4(zw8aEQuwzmX6Hxd4HeWBaNIPPgpaVGSqgRNcq3ZFoGdra4IRMkiGlxbeWtBJ63t(qHoCzAah95cuc4nfkgQb8zb8)kLaUnQFpsaFDd1kGoGUN)CaNUKQitBWcG)r7EiGZwHFpa(hRdxQaCXnJHugjG7Rdr8UpbRMbWB2eRlb81nuRa6A2eRlvuoKTc)Eedkn9XAhZHpOXGSbORztSUur5q2k87rmO0i1eewpNSh8YObfqFAdqxZMyDPIYHSv43JyqP5BIkQOVsvHfAZMqeMrhfcucbOpb01SjwxQOCiBf(9iguAS3kN)AMQcl0MnHimJokeOeQEGoGUN)CaNUKQitBWcGJIWJAaFcbeWN3iG3SzpapKaElQdt)nOcORztSUekB18bpjf0yQkSqR8tZr7E1OQeswqXeEFuNzRGq7Lhf8RzTkwlNWRvAuEuWVM1QyTCcVwDOqhUKU1NibBxtzt6QVM1MlHKfumH3h1z2ki0ErDyxO(XxZAvLqYckMW7J6mBfeAVK7J1oQkBshORztSUumO0WAJj3SjwpBc5uL3ciuwrc01SjwxkguAyTXKB2eRNnHCQYBbekkLOZqjqxZMyDPyqPH1gtUztSE2eYPkVfqO9IvjNlydu9vfwOnBcrygDuiqjeGspGUMnX6sXGsdRnMCZMy9SjKtvElGqLtvY5c2avFvHfAZMqeMrhfcus30dORztSUumO0WAJj3SjwpBc5uL3ciuHvekG(a0b01SjwxQ6fHAVTc0Z79b6A2eRlv9IIbLMVjQOI(kaDnBI1LQErXGsJ1ODh1vfwOPEOqhE415KHp4jZS3HXaLojsuWVM1Qsg(GNmZEhgJQSj9uEKkLdfLRzfLEf(x)VMjrIVM1Q(xhE2EiwbQoSzZJVM1QSHxJNmV2S9w5OoSzdu6KcqxZMyDPQxumO0emm7ROgORztSUu1lkguAyRaoz5SNaqxZMyDPQxumO0emmBANHvfwOFnRvzdVgpzETz7TYrDyZMejk4xZAv2BRaD1HcD4simxlcn5jeWejouOdp86CYWh8Kz27WyEuWVM1Qsg(GNmZEhgJ6qHoCjeMRfHM8eciqxZMyDPQxumO0CDjAFYsk9rLQclu5Qz(HxuSv43twalX0tSoqxZMyDPQxumO0ie3TNmV28SNa6dqxZMyDPQxumO0iFh2j86mLnjEaDnBI1LQErXGsJ9w5K9vuxvyHEAoA3Rgv1xinuNdwWm4JPVACugueAOBOgueAEuWVM1QS3wb6QYM0b6A2eRlv9IIbLgBCy(BA5uvyHEAoA3RgvLqYckMW7J6mBfeAV8GTRPSjD1xZAZLqYckMW7J6mBfeAVOoSlu)4RzTQsizbft49rDMTccTxY24qvzt6aDnBI1LQErXGstFS2XmsvkMvgRxvyHk0EROWgiqp68OzticZOJcbkHa0k7rLFAoA3Rgv1MMfTjBVUwa9rc01SjwxQ6ffdkn4F9)AgGUMnX6svVOyqPjyy20odRkSqpnhT7vJQAtZI2KTxxlG(iFK60g0hLKIjMj86CWWejA2eIWm6OqGsia9zt5XCTi0KNqaP76B18sUxu9nrfv0xrDOqhUeO75phWB2eRlv9IIbLMKDmvjrgu6O0xvyHEAoA3Rgv1MMfTjBVUwa9r(yAd6JssXeZeEDoyiqxZMyDPQxumO0yVvo)1maDaDnBI1LkwrcvtI5yqHQ8waHkF3LnjwY79ZRnp7jG(uvyH(1Sw1P5yETzkBs8uLnPd01SjwxQyfPyqPHYoX6vfwOuouuET2CnROcg1zry4Yej(Ru(Wg1VN8HcD4s6ME0bORztSUuXksXGstb759Fphb6A2eRlvSIumO0ie3TNmV28SNa6tvHfAZMqeMrhfcus307rQS1lAXOKbL3RJLSqBcgMiHC1m)WlQKTCqt7LmLBPCbouNYJVM1Q(xhE2EiwbQoSzdu6a01SjwxQyfPyqP50CmV2mLnjEvfwOSDnLnPRcg1zry4s1HcD4siO)PhFnRvDAoMxBMYMepvzt6aDnBI1LkwrkguAcg1zry4YQcl0VM1QonhZRntztINQSj9hP(1SwvWOolcdxQkBsprIPnOpQtZX8AZu2K4LYJu)AwRsAcgvYbdvLnPNirZMqeMrhfcucbOpLcqxZMyDPIvKIbLMjeWCY(OuvyHEAoA3RgvdkqzV2Kt2hLhFnRvHu9DRjNyDLgLhPs5qr51AZ1SIkyuNfHHltK4Vs5dBu)EYhk0HlPBiMoPa01SjwxQyfPyqPrtI5yqbjqxZMyDPIvKIbLMVz3s2QDud01SjwxQyfPyqP5JNepQeEnqxZMyDPIvKIbLgtu)EKziAALAb0hGUMnX6sfRifdkn24WVz3cqxZMyDPIvKIbLM2zOCU2KzTXa01SjwxQyfPyqP53151MNlyurc0b098Nd4IJHS)gSa4FK1AseWP1eovOb(DiiGhGhsaVbCkMMA8aC27nyOcO75phWB2eRlvcRiua9b63eovYTtDvHfQWkcfqFuLqoTZqiONoaDnBI1LkHvekG(iguAcgMTMfLvfwOFnRvfmmBnlkvLnPd01SjwxQewrOa6JyqPPpw7ygPkfZkJ1RkSqfAVvuydeOhDE0SjeHz0rHaLqa6taDnBI1LkHvekG(iguASXH5VPLdqxZMyDPsyfHcOpIbLMGHzt7meOdORztSUujhOwJ2DuxvyHM6HcD4HxNtg(GNmZEhgdu6Kirb)AwRkz4dEYm7DymQYM0t5rQuouuUMvu6v4F9)AMej(AwR6FD4z7HyfO6WMnpsLYHIY1SIsVQ20SOnzjLGkyIeuouuUMvu6v2BLZFnZJuRC26fTyuXH51MN3yULm0lyjrc2UMYM0vxxI2NSKsFurDOqhUmrItZr7E1OYEiwr415KHxKPKibLdfLRzfLE11LO9jlP0hvsK4RzTkB414jZRnBVvoQdB2aLopsTGFnRvje3TNmV28SNa6JsJsIeFnRvzpeRi86CYWlsLgLej(AwRcPkL2lyjtzh0NOnQdB2KskPa01SjwxQKJyqPXEBfON37d01SjwxQKJyqP5BIkQOVsvHf6xZAv2dXkcVoFD4knkjs0SjeHz0rHaLqa6taDnBI1Lk5iguAUM68AZ2BLtvHf6HcD4HxNtg(GNmZEhgdu9pk4xZAvjdFWtMzVdJrDOqhUeORztSUujhXGstTPzrBYskbvWQcl0df6WdVoNm8bpzM9omMhf8RzTQKHp4jZS3HXOouOdxcbwlN8ecOyZ1IqtEcbeORztSUujhXGstWWSPDgwvyHEOqhE415KHp4jZS3HX84qHo8WRZjdFWtMzVdJbcFnRvzdVgpzETz7TYrDyZMhf8RzTQKHp4jZS3HXOouOdxcH5ArOjpHac01SjwxQKJyqPHTc4KLZEcaDnBI1Lk5iguAcgM9vud01SjwxQKJyqP56s0(KLu6JkvfwOFnRvzpeRi86CYWlsLgLhnBcrygDuiqju9aDnBI1Lk5iguAUUeTpzjL(OsvHf6xZAv)RdpBpeRavh2S5X0g0hvTPzrBYskbvWhS1lAXOIdZRnpVXClzOxWYJVM1QcwWmOujNMrfiafIb6A2eRlvYrmO0emmBANHvfwOFnRvzdVgpzETz7TYrDyZMejk4xZAv2BRaD1HcD4simxlcn5jeqGUMnX6sLCedkn4F9)AgGUMnX6sLCedknxxI2NSKsFuPQWcn1kFAd6JQ20SOnzjLGkyIevoB9IwmQ4W8AZZBm3sg6fSKYJuR8tZr7E1OYEiwr415KHxKjs0SjeHz0rHaLqa6tP84RzTQ)1HNThIvGQdB2a01SjwxQKJyqPriUBpzET5zpb0hGUMnX6sLCedknY3HDcVotztIxvHf6xZAvNMJ51MPSjXtv2K(JupnhT7vJQ3yFtET55nMTnMiHC1m)WlQ6BfH5Wff171tSEIeYvZ8dVOSbAk51M)MvkxbzIeNMJ29QrL9qSIWRZjdViF81SwL9qSIWRZjdVivLnPNirZMqeMrhfcucbOpLcqxZMyDPsoIbLg7TYj7ROUQWc90C0UxnQQVqAOohSGzWhtF14OmOi0q3qnOi08OGFnRvzVTc0vLnPd01SjwxQKJyqPPpw7ygPkfZkJ1RkSqpnhT7vJQsizbft49rDMTccTxEW21u2KU6RzT5sizbft49rDMTccTxuh2fQF81SwvjKSGIj8(OoZwbH2l5(yTJQYM0b6A2eRlvYrmO0yJdZFtlNQcl0tZr7E1OQeswqXeEFuNzRGq7LhSDnLnPR(AwBUeswqXeEFuNzRGq7f1HDH6hFnRvvcjlOycVpQZSvqO9s2ghQkBshORztSUujhXGstTPzrBYskbvWQcl0VM1Q(xhE2EiwbQoSzdqxZMyDPsoIbLg7TY5VMHmKHqa]] )


end
