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
        active_comet_storm = {
            duration = 2.6,
            max_stack = 1,
            generate = function( t )
                if query_time - action.comet_storm.lastCast < 2.6 then
                    t.count = 1
                    t.applied = action.comet_storm.lastCast
                    t.expires = t.applied + 2.6
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
                expires = function( t )
                    return t.spell.expires
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

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
    end, false )

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

    spec:RegisterStateExpr( "comet_storm_remains", function () return buff.active_comet_storm.remains end )


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

        if set_bonus.tier28_2pc > 0 then
            local timeSince = now - lastAutoComet
            if timeSince < 20 then
                setCooldown( "frost_storm", lastAutoComet + 20 - now )

                if timeSince < 2.6 then
                    applyBuff( "active_comet_storm", 2.6 - timeSince )
                end
            end
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
                applyBuff( "active_comet_storm" )
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

    spec:RegisterPack( "Frost Mage", 20220523, [[dOeqlbqijv5rKuytIuFcjgfsPtHu8ksQMLKk3IKIyxO6xIqdJKshtszzIKEMKitdkfxdPsTnKk5BsIQghuk15iPOwhusZtsv19GI9PkvhusvPfkcEisftekLKlkPQWgLuv0hLev6KqPeRuentOuDtjrXorQ6NKuKAOqPKAPsIkEkunvuIVkjkzSOK2lH)kXGrCyflwv9yIMSOUmyZu1NvfJws60cRMKIKxdLy2K62Ky3u(TsdhjDCjrPwUkpNktxQRJITJs9DvjJxvkNxKy9scZNKSFilQjyrGNNge0NQAtnv1s3PwjEn1s3y7A0LaVtHkiWPosSmpGa3gfqGxFERRrKkZ8acCQtk6DYcwe4UL5KGaVA3uDynXeFIUkZNlxLeDHcJE6yn5n(orxOituG)zcDJTyIVappniOpv1MAQQLUtTs8AQLUX21Wgb(W0v3tGJhk0rGxnYzWeFbEgCsbELzEaeP(8wxJswzMuqKuRuDisQQn1urjrjPt1XEahwrjvtqeSvRrPrKWKAMmGijOddlisyisLzzdkG1is9fBn2reAPUUOJ1c7brchImicv9KcCisgKHlwJgus1eePYmybqe3QaicfF8uTlhOmH5OGiG1xaoezOsvNcI0lI8xNdr8Xt12HiRPtHlW1HRDcwe4zWpm6wWIG(Acwe4GnFnKfjiWLx0WfJaVEiYXyGFVhGNdNmOQdBUukYvrzSmhS5RHmIKgrYWNX75YX1H9WzOIiPrKm8z8EUCCDyp8duMWCis9Ji1qevQqe5U68(Y4FgVVKdNmOQdBUukYvrzSm)GjNcIKgr(mEpphozqvh2CPuKRIYy5YCYXaEEFzc8r2XAcC5YynCoQGwlAb9PkyrGd281qwKGaFKDSMaxoADzKDSwrhUwGRdxxSrbe4YSt0c6RKGfboyZxdzrcc8r2XAcC5O1Lr2XAfD4AbUoCDXgfqGdohysWjAb9yJGfboyZxdzrccC5fnCXiWhzhSHcyGsaoe5DmisLe4U(czlOVMaFKDSMaxoADzKDSwrhUwGRdxxSrbe4ZcIwqpDlyrGd281qwKGaxErdxmc8r2bBOagOeGdrQFePscCxFHSf0xtGpYowtGlhTUmYowROdxlW1HRl2OacCxlAb90LGfboyZxdzrcc8r2XAcC5O1Lr2XAfD4AbUoCDXgfqGRSSbfWArlAbo1dKRYFAblc6RjyrGpYowtGpNCmOewdAniBboyZxdzrcIwqFQcwe4JSJ1e4VMgUcObfW6rlWbB(Ailsq0c6RKGfb(i7ynbUxdUQYB8TahS5RHSibrlOhBeSiWbB(AilsqGlVOHlgb(i7GnuaducWHiVJbrsvGpYowtG)1rfvmxw0c6PBblcCWMVgYIee4YlA4IrGpYoydfWaLaCicgePMaFKDSMa3FRR)RUfTOf4Zccwe0xtWIaFKDSMa3FBfGv27lWbB(Ailsq0c6tvWIahS5RHSibbU8IgUye4FgVNNHPR(3ZaEEFziIkvis9qKJXa)Epapdtx1v8txDv4GnFnKrevQqKpJ3Z9have2t5MW4murevQqKr2bBOagOeGdrEhdIqxc8r2XAc8VoQOI5YIwqFLeSiWbB(AilsqGlVOHlgb(NX75zy6Q)9mGZqfrsJiJSd2qbmqjahIGbrOBejnIqlI0JgSM7paQiSNYnHXbB(AiJiQuHi9ObR5)1GISAO1H9WbB(AiJiQuHiY1YmrZDvd2Wf2trUhWbB(AiJiQuHi1drogd879aC5QZf)TwZbB(AiJi0iWhzhRjW)6OIkMllAb9yJGfboyZxdzrccC5fnCXiW)mEppdtx9VNbCgQisAezKDWgkGbkb4qemic2GiPreArKE0G1C)bqfH9uUjmoyZxdzerLkePhnyn)VguKvdToShoyZxdzejnIixlZen3vnydxypf5EahS5RHmIOsfIupe5ymWV3dWLRox83AnhS5RHmIKgrQhICmg437b4oDiXsjKahS5RHmIqJaFKDSMa)RJkQyUSOf0t3cwe4GnFnKfjiWLx0WfJa)Z498mmD1)EgWzOIiPrKr2bBOagOeGdrQFmisLqK0is9qKJXa)Epa3PdjwkHe4GnFnKrK0is9qKJXa)EpaxU6CXFR1CWMVgYisAerUwMjAURAWgUWEkY9aoyZxdzejnIqlI0JgSM7paQiSNYnHXbB(AiJiQuHi9ObR5)1GISAO1H9WbB(AiJi0iWhzhRjW)6OIkMllAb90LGfboyZxdzrccC5fnCXiWPfroqzclSNYRWA4Cfz1qRremiIArevQqKm8z8E(RWA4Cfz1qR559LHi0GiPreAreQhWU8iZ8AC4V2F1nIOsfI8z8E()MWk(dGka(bJSrK0iYNX75(WEGZvwFXFRR5hmYgrWGiQfrOrGpYowtG71m3LIOf0x5fSiWhzhRjWdjuSL9iWbB(Ailsq0c6X2cwe4JSJ1e4Yvb6IR3trGd281qwKGOf0RMfSiWbB(AilsqGlVOHlgbUBz0)WYC2RE6qdf3QzdwZbB(AiJiPrKpJ3ZzV6PdnuCRMnyDPkJYyBK559LjWdRH7yO2LWlWRjWdRH7yO2LqrbYX0GaVMaFKDSMa3Rbxv5n(wGhwd3XqTlp69pAbEnrlOVMAfSiWbB(AilsqGlVOHlgb(XyGFVhGNHPR6k(PRUkCWMVgYisAeHwe5ymWV3dWLRox83AnhS5RHmIOsfICmg437b4oDiXsjKahS5RHmIqdIKgr(mEppdtx9VNb8duMWCiY7iICCDPdfaruhr6Byd6shkGaFKDSMa3FRR)RUfTG(A1eSiWbB(AilsqGlVOHlgb(bktyH9uEfwdNRiRgAnIGbrQHiPre5QaDX17PuoqzcZHiVJiJSJ14Hek6XKaVVHnOlDOac8r2XAcC)TU(V6w0c6RLQGfboyZxdzrccC5fnCXiW)mEp3h2dCUY6l(BDn)Gr2iIkvisg(mEp3FBfGXpqzcZHiVJi9nSbDPdfaruPcroqzclSNYRWA4Cfz1qRrK0isg(mEp)vynCUISAO18duMWCiY7isFdBqx6qbe4JSJ1e4Hek6XKGOf0xRscwe4GnFnKfjiWLx0WfJa3Tm6FyzUCv(txuGC0thRXbB(AilWhzhRjWVjhJ1fh15WIOf0xdBeSiWhzhRjWvI72ZvwFP3tbSwGd281qwKGOf0xJUfSiWhzhRjWDvdFh2tH6(coboyZxdzrcIwqFn6sWIahS5RHSibbU8IgUye4hJb(9EaEoCYGQoS5sPixfLXYCWMVgYisAerURoVVm(NX7l5WjdQ6WMlLICvuglZpyYPGiPrKpJ3ZZHtgu1Hnxkf5QOmwU4Jd459LjWhzhRjW9XbLVECTOf0xRYlyrGd281qwKGaxErdxmcCLXgovzJiVJivsTisAezKDWgkGbkb4qK3XGi0fIKgrQhICmg437b4p6rgJU4V5rbS2XbB(AilWhzhRjWNtoguG3OQxxSMOf0xdBlyrGpYowtGd)1(RUf4GnFnKfjiAb91uZcwe4GnFnKfjiWLx0WfJa)ymWV3dWF0JmgDXFZJcyTJd281qgrsJi0Ii9ObR5oQ6O7WEkHe4GnFnKrevQqKr2bBOagOeGdrEhdIq3icnisAePVHnOlDOais9Jip3Yy5YSa)RJkQyUm)aLjmNaFKDSMapKqrpMeeTG(uvRGfb(i7ynbU)wx)xDlWbB(Ailsq0IwGlZoblc6RjyrGd281qwKGaFKDSMa3vDY7lix27xwFP3tbSwGlVOHlgb(NX75hJbL1xOUVGJN3xMa3gfqG7Qo59fKl79lRV07PawlAb9PkyrGd281qwKGaxErdxmcCQhWUSEF5rM5HmLcBimhIOsfI8xNdrsJi(4PAxoqzcZHi1pIuj1kWhzhRjWPUDSMOf0xjblc8r2XAc8mmD1)EgiWbB(Ailsq0c6XgblcCWMVgYIee4YlA4IrGpYoydfWaLaCis9JivcrsJi0IiY1YmrZDb1QRb5IYOdjWbB(AiJiQuHiULr)dlZFnUg0JLluVL6fqNchS5RHmIqdIKgr(mEp)Ftyf)bqfa)Gr2icgerTc8r2XAcCL4U9CL1x69uaRfTGE6wWIahS5RHSibbU8IgUye4YD159LXdzkf2qyo(bktyoe5DePwQisAe5Z498JXGY6lu3xWXZ7ltGpYowtGFmguwFH6(corlONUeSiWbB(AilsqGlVOHlgb(NX75hJbL1xOUVGJN3xgIKgrOfr(mEppKPuydH5459LHiQuHi9ObR5hJbL1xOUVGJd281qgrObrsJi0IiFgVN70HelLqc88(YqevQqe5AzMO5HmLc1BPYODXACWMVgYisAeHwePhnynxUkqxC9EkCWMVgYiIkviId6YFnghVd4sfBxsLQerObruPcrgzhSHcyGsaoe5DmisQicnc8r2XAc8qMsHneMt0c6R8cwe4GnFnKfjiWLx0WfJa)ymWV3dWBqH6EJU8AoQCWMVgYisAe5Z49C4TQdJRJ14murK0icTic1dyxwVV8iZ8qMsHneMdruPcr(RZHiPreF8uTlhOmH5qK6hrWg1Ii0iWhzhRjW7qbkVMJQOf0JTfSiWhzhRjWzCqjAqXjWbB(Ailsq0c6vZcwe4JSJ1e4F9U5IN5srGd281qwKGOf0xtTcwe4JSJ1e4F4CWHLWEe4GnFnKfjiAb91QjyrGpYowtGRJNQTROMIj)OawlWbB(Ailsq0c6RLQGfb(i7ynbUpo4R3nlWbB(Ailsq0c6Rvjblc8r2XAc8XKGRVrxKJwlWbB(Ailsq0c6RHncwe4JSJ1e4)5PS(sFHeloboyZxdzrcIw0cCxlyrqFnblcCWMVgYIee4YlA4IrGtlICGYewypLxH1W5kYQHwJiyqe1IiQuHiz4Z498xH1W5kYQHwZZ7ldrObrsJi0IiupGD5rM514WFT)QBerLke5Z498)nHv8hava8dgzJiPreAreQhWU8iZ8A8h9iJrxCudSaiIkvic1dyxEKzEnU)wx)xDJiPreArK6HiY1YmrZJdkRV0vHY4KGLHmhS5RHmIOsfIi3vN3xg)MCmwxCuNdl8duMWCiIkviYXyGFVhG7paQiSNYRWYooyZxdzeHgerLkeH6bSlpYmVg)MCmwxCuNdliIkviYNX75(WEGZvwFXFRR5hmYgrWGiQfrsJi0Iiz4Z49CL4U9CL1x69uaR5murevQqKpJ3Z9have2t5vyzhNHkIOsfI8z8Eo8g1XYqUqDBW6y08dgzJi0Gi0Gi0iWhzhRjW9AM7sr0c6tvWIaFKDSMa3FBfGv27lWbB(Ailsq0c6RKGfboyZxdzrccC5fnCXiWpqzclSNYRWA4Cfz1qRf4JSJ1e4Yvb6IR3tr0c6XgblcCWMVgYIee4YlA4IrG3JgSM7OQJUd7PesGd281qgrsJi9ObR5YQtyLdgzhRXbB(AiJiPrKpJ3Z9H9aNRS(I)wxZpyKnIGbr(mEp3h2dCUY6l(BDnxzER46rIfb(i7ynbEiHIEmjiAb90TGfboyZxdzrccC5fnCXiWpgd879a8mmDvxXpD1vHd281qgrsJi0IihJb(9EaUC15I)wR5GnFnKrevQqKJXa)Epa3PdjwkHe4GnFnKreAqK0iYNX75zy6Q)9mGFGYeMdrEhrKJRlDOaiI6isFdBqx6qbqK0iYi7GnuaducWHiVJbrsvGpYowtG7V11)v3IwqpDjyrGd281qwKGaxErdxmcCArK6HihJb(9EaUthsSucjWbB(AiJiQuHi1drKRLzIMhYukuVLkJ2fRXbB(AiJiPrKpJ3ZZW0v)7zapVVmeHgejnImYoydfWaLaCiY7yqKuf4JSJ1e4FDurfZLfTG(kVGfboyZxdzrccC5fnCXiWpqzclSNYRWA4Cfz1qRremisnejnIKHpJ3ZFfwdNRiRgAn)aLjmNaFKDSMa)MukRV4V11Iwqp2wWIahS5RHSibbU8IgUye4hOmHf2t5vynCUISAO1isAejdFgVN)kSgoxrwn0A(bktyoe5DeroUU0HcGiQJi9nSbDPdfqGpYowtG)Ohzm6IJAGfq0c6vZcwe4GnFnKfjiWLx0WfJa)aLjSWEkVcRHZvKvdTgrWGi1qK0iICvGU469ukhOmH5qK3rKr2XA8qcf9ysG33Wg0Louab(i7ynbU)wx)xDlAb91uRGfboyZxdzrccC5fnCXiWpqzclSNYRWA4Cfz1qRrK0iYbktyH9uEfwdNRiRgAnI8oI8z8EUpSh4CL1x836A(bJSrK0isg(mEp)vynCUISAO18duMWCiY7isFdBqx6qbe4JSJ1e4Hek6XKGOf0xRMGfb(i7ynbEiHITShboyZxdzrcIwqFTufSiWbB(AilsqGlVOHlgb(NX75(dGkc7P8kSSJZqfrsJiJSd2qbmqjahIGbrQjWhzhRjWVjhJ1fh15WIOf0xRscwe4GnFnKfjiWLx0WfJa)Z498)nHv8hava8dgzJiPrKE0G18h9iJrxCudSaCWMVgYisAerUwMjAECqz9LUkugNeSmK5GnFnKrK0iYNX75HmKAWXD9iXcI8ogebBe4JSJ1e43KJX6IJ6Cyr0c6RHncwe4GnFnKfjiWLx0WfJa)Z49CFypW5kRV4V118dgzJiQuHiz4Z49C)Tvag)aLjmhI8oI03Wg0Louab(i7ynbEiHIEmjiAb91OBblc8r2XAcC4V2F1TahS5RHSibrlOVgDjyrGd281qwKGaxErdxmcCArK6Hi9ObR5p6rgJU4Ogyb4GnFnKrevQqK6HiY1YmrZJdkRV0vHY4KGLHmhS5RHmIqdIKgrOfrQhICmg437b4(dGkc7P8kSSJd281qgruPcrgzhSHcyGsaoe5DmisQicnisAe5Z498)nHv8hava8dgzlWhzhRjWVjhJ1fh15WIOf0xRYlyrGpYowtGRe3TNRS(sVNcyTahS5RHSibrlOVg2wWIahS5RHSibbU8IgUye4FgVNFmguwFH6(coEEFzisAeHwe5ymWV3dWRcZ1L1x6QqXpahS5RHmIOsfI4wg9pSm)5w2qjm2XZEthRXbB(AiJiQuHiULr)dlZ9bOZL1x(615wfhhS5RHmIOsfICmg437b4(dGkc7P8kSSJd281qgrsJiFgVN7paQiSNYRWYoEEFziIkviYi7GnuaducWHiVJbrsfrOrGpYowtG7Qg(oSNc19fCIwqFn1SGfboyZxdzrccC5fnCXiWpgd879a8C4KbvDyZLsrUkkJL5GnFnKrK0iICxDEFz8pJ3xYHtgu1Hnxkf5QOmwMFWKtbrsJiFgVNNdNmOQdBUukYvrzSCzo5yapVVmb(i7ynb(CYXGc8gv96I1eTG(uvRGfboyZxdzrccC5fnCXiWpgd879a8C4KbvDyZLsrUkkJL5GnFnKrK0iICxDEFz8pJ3xYHtgu1Hnxkf5QOmwMFWKtbrsJiFgVNNdNmOQdBUukYvrzSCXhhWZ7ltGpYowtG7JdkF94ArlOp1Acwe4GnFnKfjiWLx0WfJa)Z498)nHv8hava8dgzlWhzhRjWF0JmgDXrnWciAb9PMQGfboyZxdzrccC5fnCXiWDlJ(hwMZE1thAO4wnBWAoyZxdzejnI8z8Eo7vpDOHIB1SbRlvzugBJmpVVmbEynChd1UeEbEnbEynChd1UekkqoMge41e4JSJ1e4En4QkVX3c8WA4ogQD5rV)rlWRjAb9Pwjblc8r2XAcC)TU(V6wGd281qwKGOfTaxzzdkG1cwe0xtWIahS5RHSibbU8IgUye4FgVNhsO41l4459LjWhzhRjWdju86fCIwqFQcwe4GnFnKfjiWLx0WfJaxzSHtv2iY7isLulIKgrgzhSHcyGsaoe5DmisQc8r2XAc85KJbf4nQ61fRjAb9vsWIaFKDSMa3hhu(6X1cCWMVgYIeeTGESrWIaFKDSMapKqrpMee4GnFnKfjiArlAboB4CXAc6tvTPMQAXMAvEb(R5SWECc8kR6BLd9yl0x5IvebryPkGiHc19AeXVhIqjd(Hr3uqKdQSzIdYiIBvaezy6vzAiJiYQJ9aookj2ddqKAyfrOZASHRHmIq5ymWV3dWzLcI0lIq5ymWV3dWzLd281qMcIqBT3OHJsIswzvFRCOhBH(kxSIiiclvbejuOUxJi(9qekZcuqKdQSzIdYiIBvaezy6vzAiJiYQJ9aookj2ddqKuXkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfeH2AVrdhLe7HbisLWkIqN1ydxdzeHspAWAoRuqKErek9ObR5SYbB(AitbrOn13OHJsI9WaePsyfrOZASHRHmIq5ymWV3dWzLcI0lIq5ymWV3dWzLd281qMcIqBT3OHJsI9WaePsyfrOZASHRHmIqrUwMjAoRuqKErekY1YmrZzLd281qMcIqBT3OHJsI9WaebBWkIqN1ydxdzeHspAWAoRuqKErek9ObR5SYbB(AitbrOn13OHJsI9WaebBWkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfeH2uFJgokj2ddqeSbRicDwJnCnKrekY1YmrZzLcI0lIqrUwMjAoRCWMVgYuqeAR9gnCusShgGi0nwre6SgB4AiJiu6rdwZzLcI0lIqPhnynNvoyZxdzkicTP(gnCusShgGi0nwre6SgB4AiJiuogd879aCwPGi9Iiuogd879aCw5GnFnKPGi0M6B0WrjXEyaIq3yfrOZASHRHmIqrUwMjAoRuqKErekY1YmrZzLd281qMcIqBT3OHJsI9WaernJveHoRXgUgYicf3YO)HL5Ssbr6frO4wg9pSmNvoyZxdzkicT1EJgokj2ddqKAQfRicDwJnCnKrekhJb(9EaoRuqKErekhJb(9EaoRCWMVgYuqeAt9nA4OKypmarQPwSIi0zn2W1qgrOCmg437b4Ssbr6frOCmg437b4SYbB(AitbrOT2B0WrjXEyaIuRsyfrOZASHRHmIqXTm6FyzoRuqKErekULr)dlZzLd281qMcImnIuFOMg7icT1EJgokj2ddqKA0fwre6SgB4AiJiuogd879aCwPGi9Iiuogd879aCw5GnFnKPGi0w7nA4OKypmarQv5XkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfezAeP(qnn2reAR9gnCusShgGi1uZyfrOZASHRHmIqPhnynNvkisVicLE0G1Cw5GnFnKPGi0w7nA4OKypmarQPMXkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfeH2AVrdhLeLSYQ(w5qp2c9vUyfrqewQcisOqDVgr87HiuKzhfe5GkBM4GmI4wfargMEvMgYiIS6ypGJJsI9WaebBWkIqN1ydxdzeHICTmt0CwPGi9IiuKRLzIMZkhS5RHmfeH2AVrdhLe7Hbic2GveHoRXgUgYicf3YO)HL5Ssbr6frO4wg9pSmNvoyZxdzkicT1EJgokj2ddqe6cRicDwJnCnKrek9ObR5Ssbr6frO0JgSMZkhS5RHmfeH2uFJgokj2ddqe6cRicDwJnCnKrekY1YmrZzLcI0lIqrUwMjAoRCWMVgYuqeAR9gnCusShgGivESIi0zn2W1qgrOCmg437b4Ssbr6frOCmg437b4SYbB(AitbrOT2B0WrjrjRSQVvo0JTqFLlwreeHLQaIeku3Rre)EicfxtbroOYMjoiJiUvbqKHPxLPHmIiRo2d44OKypmarQHveHoRXgUgYicLJXa)EpaNvkisVicLJXa)EpaNvoyZxdzkicT1EJgokj2ddqKAyfrOZASHRHmIqrUwMjAoRuqKErekY1YmrZzLd281qMcIqBT3OHJsI9WaebBWkIqN1ydxdzeHspAWAoRuqKErek9ObR5SYbB(AitbrOn13OHJsI9WaeHUXkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfeH2uFJgokj2ddqe6gRicDwJnCnKrekhJb(9EaoRuqKErekhJb(9EaoRCWMVgYuqeAR9gnCusShgGi0fwre6SgB4AiJiuogd879aCwPGi9Iiuogd879aCw5GnFnKPGi0w7nA4OKypmarOlSIi0zn2W1qgrOixlZenNvkisVicf5AzMO5SYbB(AitbrOT2B0WrjXEyaIuRsyfrOZASHRHmIqPhnynNvkisVicLE0G1Cw5GnFnKPGi0w7nA4OKypmarQvjSIi0zn2W1qgrOixlZenNvkisVicf5AzMO5SYbB(AitbrOT2B0WrjXEyaIuJUWkIqN1ydxdzeHspAWAoRuqKErek9ObR5SYbB(AitbrOT2B0WrjXEyaIuJUWkIqN1ydxdzeHYXyGFVhGZkfePxeHYXyGFVhGZkhS5RHmfeH2AVrdhLe7Hbisn6cRicDwJnCnKrekY1YmrZzLcI0lIqrUwMjAoRCWMVgYuqeAR9gnCusShgGi1W2yfrOZASHRHmIq5ymWV3dWzLcI0lIq5ymWV3dWzLd281qMcIqBQVrdhLe7HbisnSnwre6SgB4AiJiuClJ(hwMZkfePxeHIBz0)WYCw5GnFnKPGi0M6B0WrjXEyaIutnJveHoRXgUgYicLJXa)EpaNvkisVicLJXa)EpaNvoyZxdzkicT1EJgokj2ddqKuvlwre6SgB4AiJiuogd879aCwPGi9Iiuogd879aCw5GnFnKPGi0w7nA4OKypmarsnvSIi0zn2W1qgrO4wg9pSmNvkisVicf3YO)HL5SYbB(AitbrOT2B0WrjrjXwuOUxdzeHUqKr2XAiIoCTJJskWDubPGE6cBe4uV1hAqGRgQbIuzMharQpV11OKQHAGivMjfej1kvhIKQAtnvusus1qnqe6uDShWHvus1qnqe1eebB1AuAejmPMjdisc6WWcIegIuzw2GcynIuFXwJDeHwQRl6yTWEqKWHidIqvpPahIKbz4I1ObLunudernbrQmdwaeXTkaIqXhpv7Ybktyokicy9fGdrgQu1PGi9Ii)15qeF8uTDiYA6u4OKOKQHAGi1hVbsMgYiYh87biICv(tJiF4jmhhrQVsjqTDiITMAs15u8mAezKDSMdrwtNchLCKDSMJt9a5Q8NwDmjoNCmOewdAniBuYr2XAoo1dKRYFA1XKOJrrzTYRPHRaAqbSE0OKJSJ1CCQhixL)0QJjrVgCvL34BuYr2XAoo1dKRYFA1XK4xhvuXC56cpMr2bBOagOeG7DmPIsoYowZXPEGCv(tRoMe9366)Q76cpMr2bBOagOeGdtnusus1qnqK6J3ajtdzebydxkishkaI0vbezK9Eis4qKH9e65Rbok5i7ynhg5YynCoQGwxx4XuVJXa)Epaphozqvh2CPuKRIYy50z4Z49C546WE4mutNHpJ3ZLJRd7HFGYeMR(RPsLCxDEFz8pJ3xYHtgu1Hnxkf5QOmwMFWKtj9NX755WjdQ6WMlLICvuglxMtogWZ7ldLCKDSMtDmjkhTUmYowROdxxNnkagz2HsoYowZPoMeLJwxgzhRv0HRRZgfad4CGjbhk5i7ynN6ysuoADzKDSwrhUUoBuamZc156lKnMA1fEmJSd2qbmqja37yQek5i7ynN6ysuoADzKDSwrhUUoBuamUUoxFHSXuRUWJzKDWgkGbkb4Q)kHsoYowZPoMeLJwxgzhRv0HRRZgfaJYYguaRrjrjhzhR54Zcy83wbyL9(OKJSJ1C8zb1XK4xhvuXC56cpMpJ3ZZW0v)7zapVVmvQQ3XyGFVhGNHPR6k(PRUkQu9z8EU)aOIWEk3egNHQkvJSd2qbmqja37yOluYr2XAo(SG6ys8RJkQyUCDHhZNX75zy6Q)9mGZqn9i7GnuaducWHHUttBpAWAU)aOIWEk3eMkv9ObR5)1GISAO1H9OsLCTmt0Cx1GnCH9uK7bQuvVJXa)EpaxU6CXFR10GsoYowZXNfuhtIFDurfZLRl8y(mEppdtx9VNbCgQPhzhSHcyGsaomytAA7rdwZ9have2t5MWuPQhnyn)VguKvdToSN0Y1YmrZDvd2Wf2trUhOsv9ogd879aC5QZf)TwNUEhJb(9EaUthsSucjqdk5i7ynhFwqDmj(1rfvmxUUWJ5Z498mmD1)EgWzOMEKDWgkGbkb4QFmvkD9ogd879aCNoKyPesiD9ogd879aC5QZf)TwNwUwMjAURAWgUWEkY9G002JgSM7paQiSNYnHPsvpAWA(FnOiRgADyp0GsoYowZXNfuhtIEnZDPux4Xq7bktyH9uEfwdNRiRgAng1Qsvg(mEp)vynCUISAO188(YOjnTupGD5rM514WFT)QBvQ(mEp)Ftyf)bqfa)Gr2P)mEp3h2dCUY6l(BDn)Gr2yulnOKJSJ1C8zb1XKyiHITShuYr2XAo(SG6ysuUkqxC9EkOKJSJ1C8zb1XKOxdUQYB8DDHhJBz0)WYC2RE6qdf3QzdwN(Z49C2RE6qdf3QzdwxQYOm2gzEEFz1fwd3XqTlHIcKJPbm1QlSgUJHAxE07F0yQvxynChd1UeEm1qjhzhR54ZcQJjr)TU(V6UUWJ5ymWV3dWZW0vDf)0vxL00Emg437b4YvNl(BTwLQJXa)Epa3PdjwkHeOj9NX75zy6Q)9mGFGYeM7D546shkG69nSbDPdfaLCKDSMJplOoMe9366)Q76cpMduMWc7P8kSgoxrwn0Am1slxfOlUEpLYbktyU3hzhRXdju0JjbEFdBqx6qbqjhzhR54ZcQJjXqcf9ysOUWJ5Z49CFypW5kRV4V118dgzRsvg(mEp3FBfGXpqzcZ9EFdBqx6qbuP6aLjSWEkVcRHZvKvdToDg(mEp)vynCUISAO18duMWCV33Wg0LouauYr2XAo(SG6ys8MCmwxCuNdl1fEmULr)dlZLRYF6IcKJE6ynuYr2XAo(SG6ysujUBpxz9LEpfWAuYr2XAo(SG6ys0vn8DypfQ7l4qjhzhR54ZcQJjrFCq5Rhxxx4XCmg437b45WjdQ6WMlLICvuglNwURoVVm(NX7l5WjdQ6WMlLICvuglZpyYPK(Z498C4KbvDyZLsrUkkJLl(4aEEFzOKJSJ1C8zb1XK4CYXGc8gv96I1Ql8yugB4uL97vsTPhzhSHcyGsaU3XqxPR3XyGFVhG)Ohzm6I)MhfWAhk5i7ynhFwqDmjc)1(RUrjhzhR54ZcQJjXqcf9ysOUWJ5ymWV3dWF0JmgDXFZJcyTlnT9ObR5oQ6O7WEkHeuPAKDWgkGbkb4EhdDtt6(g2GU0Hcu)p3Yy5YSa)RJkQyUm)aLjmhkPAOgiI6iYi7ynhFwqDmj(AIUohiXOwET6cpMJXa)Epa)rpYy0f)npkG1U017ymWV3dWZW0vDf)0vxL00wVE0G1C5QaDX17PKEKDWgkGbkb4EhdDRs1i7GnuaducW9og6IguYr2XAo(SG6ys0FRR)RUrjrjhzhR54YSddJdkrdk1zJcGXvDY7lix27xwFP3tbSUUWJ5Z498JXGY6lu3xWXZ7ldLCKDSMJlZo1XKi1TJ1Ql8yOEa7Y69LhzMhYukSHWCQu9xNlTpEQ2LduMWC1FLulk5i7ynhxMDQJjXmmD1)EgGsoYowZXLzN6ysujUBpxz9LEpfW66cpMr2bBOagOeGR(RuAALRLzIM7cQvxdYfLrhsqLk3YO)HL5Vgxd6XYfQ3s9cOtHM0FgVN)VjSI)aOcGFWiBmQfLCKDSMJlZo1XK4Xyqz9fQ7l4Ql8yK7QZ7lJhYukSHWC8duMWCVxl10FgVNFmguwFH6(coEEFzOKJSJ1CCz2PoMedzkf2qyU6cpMpJ3ZpgdkRVqDFbhpVVS00(z8EEitPWgcZXZ7ltLQE0G18JXGY6lu3xWrtAA)mEp3PdjwkHe459LPsLCTmt08qMsH6Tuz0UyT002JgSMlxfOlUEpfvQCqx(RX44DaxQy7sQuL0Os1i7GnuaducW9oMuPbLCKDSMJlZo1XKyhkq51CuRl8yogd879a8guOU3OlVMJA6pJ3ZH3QomUowJZqnnTupGDz9(YJmZdzkf2qyovQ(RZL2hpv7YbktyU6hBulnOKJSJ1CCz2PoMezCqjAqXHsoYowZXLzN6ys8R3nx8mxkOKJSJ1CCz2PoMe)W5GdlH9GsoYowZXLzN6ysuhpvBxrnft(rbSgLCKDSMJlZo1XKOpo4R3nJsoYowZXLzN6ysCmj46B0f5O1OKJSJ1CCz2PoMe)Ztz9L(cjwCOKOKQHAGiyRc381qgr(GCyCaIKGomSKiE1qrboejCiYGiu1tkWHiYQBibokPAOgiYi7ynhxzzdkG1y(6WWszSuQl8yuw2GcynphUEmj8En1IsoYowZXvw2GcyT6ysmKqXRxWvx4X8z8EEiHIxVGJN3xgk5i7ynhxzzdkG1QJjX5KJbf4nQ61fRvx4XOm2WPk73RKAtpYoydfWaLaCVJjvuYr2XAoUYYguaRvhtI(4GYxpUgLCKDSMJRSSbfWA1XKyiHIEmjGsIsoYowZXDngVM5UuQl8yO9aLjSWEkVcRHZvKvdTgJAvPkdFgVN)kSgoxrwn0AEEFz0KMwQhWU8iZ8AC4V2F1TkvFgVN)VjSI)aOcGFWi700s9a2LhzMxJ)Ohzm6IJAGfqLkQhWU8iZ8AC)TU(V6onT1tUwMjAECqz9LUkugNeSmKvPsURoVVm(n5ySU4Oohw4hOmH5uP6ymWV3dW9have2t5vyzhnQur9a2LhzMxJFtogRloQZHfvQ(mEp3h2dCUY6l(BDn)Gr2yuBAAZWNX75kXD75kRV07PawZzOQs1NX75(dGkc7P8kSSJZqvLQpJ3ZH3OowgYfQBdwhJMFWiBAOHguYr2XAoURvhtI(BRaSYEFuYr2XAoURvhtIYvb6IR3tPUWJ5aLjSWEkVcRHZvKvdTgLCKDSMJ7A1XKyiHIEmjux4X0JgSM7OQJUd7PesiDpAWAUS6ew5Gr2XAP)mEp3h2dCUY6l(BDn)Gr2y(mEp3h2dCUY6l(BDnxzER46rIfuYr2XAoURvhtI(BD9F1DDHhZXyGFVhGNHPR6k(PRUkPP9ymWV3dWLRox83ATkvhJb(9EaUthsSucjqt6pJ3ZZW0v)7za)aLjm37YX1Loua17Byd6shkq6r2bBOagOeG7DmPIsoYowZXDT6ys8RJkQyUCDHhdT17ymWV3dWD6qILsibvQQNCTmt08qMsH6Tuz0UyT0FgVNNHPR(3ZaEEFz0KEKDWgkGbkb4EhtQOKJSJ1CCxRoMeVjLY6l(BDDDHhZbktyH9uEfwdNRiRgAnMAPZWNX75VcRHZvKvdTMFGYeMdLCKDSMJ7A1XK4JEKXOloQbwG6cpMduMWc7P8kSgoxrwn060z4Z498xH1W5kYQHwZpqzcZ9UCCDPdfq9(g2GU0HcGsoYowZXDT6ys0FRR)RURl8yoqzclSNYRWA4Cfz1qRXulTCvGU469ukhOmH5EFKDSgpKqrpMe49nSbDPdfaLCKDSMJ7A1XKyiHIEmjux4XCGYewypLxH1W5kYQHwN(aLjSWEkVcRHZvKvdT(9pJ3Z9H9aNRS(I)wxZpyKD6m8z8E(RWA4Cfz1qR5hOmH5EVVHnOlDOaOKJSJ1CCxRoMedjuSL9GsoYowZXDT6ys8MCmwxCuNdl1fEmFgVN7paQiSNYRWYood10JSd2qbmqjahMAOKJSJ1CCxRoMeVjhJ1fh15WsDHhZNX75)BcR4paQa4hmYoDpAWA(JEKXOloQbwG0Y1YmrZJdkRV0vHY4KGLHC6pJ3Zdzi1GJ76rIL3XGnOKJSJ1CCxRoMedju0JjH6cpMpJ3Z9H9aNRS(I)wxZpyKTkvz4Z49C)Tvag)aLjm379nSbDPdfaLCKDSMJ7A1XKi8x7V6gLCKDSMJ7A1XK4n5ySU4OohwQl8yOTE9ObR5p6rgJU4OgybuPQEY1YmrZJdkRV0vHY4KGLHmnPPTEhJb(9EaU)aOIWEkVcl7uPAKDWgkGbkb4EhtQ0K(Z498)nHv8hava8dgzJsoYowZXDT6ysujUBpxz9LEpfWAuYr2XAoURvhtIUQHVd7PqDFbxDHhZNX75hJbL1xOUVGJN3xwAApgd879a8QWCDz9LUku8dOsLBz0)WY8NBzdLWyhp7nDSMkvULr)dlZ9bOZL1x(615wfNkvhJb(9EaU)aOIWEkVcl7s)z8EU)aOIWEkVcl7459LPs1i7GnuaducW9oMuPbLCKDSMJ7A1XK4CYXGc8gv96I1Ql8yogd879a8C4KbvDyZLsrUkkJLtl3vN3xg)Z49LC4KbvDyZLsrUkkJL5hm5us)z8EEoCYGQoS5sPixfLXYL5KJb88(YqjhzhR54UwDmj6JdkF9466cpMJXa)Epaphozqvh2CPuKRIYy50YD159LX)mEFjhozqvh2CPuKRIYyz(btoL0FgVNNdNmOQdBUukYvrzSCXhhWZ7ldLCKDSMJ7A1XK4JEKXOloQbwG6cpMpJ3Z)3ewXFaubWpyKnk5i7ynh31QJjrVgCvL3476cpg3YO)HL5Sx90HgkUvZgSo9NX75Sx90HgkUvZgSUuLrzSnY88(YQlSgUJHAxcffihtdyQvxynChd1U8O3)OXuRUWA4ogQDj8yQHsoYowZXDT6ys0FRR)RUfTOfca]] )


end
