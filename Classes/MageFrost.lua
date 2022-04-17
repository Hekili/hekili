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

    spec:RegisterPack( "Frost Mage", 20220417, [[dOKalbqivj1JqQuBsK6tiPrHu6uifVseAwQsClsvc7cv)semmsvCmjXYKu8mjLAAqbDnjLyBivY3uLKghPkvNJuL06GImpOaUhuAFQs1bjvPSqsv9qKkMiuGYfvLeSrvjH(OKsQojuGSsr0mHI6MQsI2jsv)KuLOgkuGQLkPKYtHQPIs8vjLeJfL0Ej8xjgmIdRyXQQht0Kf1LbBMQ(SQy0ssNwy1KQe51qHMnj3Mu2nLFR0WrIJlPK0Yv55uz6sDDuSDuQVlPA8Qs58IKwViX8jv2pKfveSiWZtdc6Rrp1uJEWWkVkVYRwl0LEQrG3Psbe4ugjgNhqGBJgiWFfV11iYRCEaboLjv1ozblcC3YCsqGxTBkomLqcprxL5ZLRwcUqJrnDSM8gFNGl0KjiW)mHQXGmXxGNNge0xJEQPg9GHvEvELxTwOl9urGpmD19e44HgDe4vJCgmXxGNbNuG)kNharEfV11OK6nkxOqKkV6lisn6PMAqjrjPt1XEahMqj1lqemyRrTrKWKkMmGi6RcdJisyiYRCzdAG1iIEddoMreAPSUOJ1c7brchImicf1KkCisgKHlwJgus9ce5voyeqe3QbicvF8uTlhOnH5OIiG1xaoezOqrLkI0lI8xNdr8Xt12HiRPsLlWvHRDcwe4zWpmQwWIG(kcwe4GnFfKf6lWLx0WfJa)1iYXyGFVhGNdNmOOcBUulYvtBSmhS5RGmIKgrYWNX75YX1H9WzOGiPrKm8z8EUCCDyp8d0MWCicgarQGi60HiYDv5TUX)mEFjhozqrf2CPwKRM2yz(btovejnI8z8EEoCYGIkS5sTixnTXYL5KJb88w3e4JSJ1e4YLXA4CuaLs0c6RrWIahS5RGSqFb(i7ynbUCuQYi7yTIkCTaxfUUyJgiWLzNOf0xBblcCWMVcYc9f4JSJ1e4YrPkJSJ1kQW1cCv46InAGahCoWKGt0c6XqblcCWMVcYc9f4YlA4IrGpYoydfWaTaCiY7yrKAlWD9fYwqFfb(i7ynbUCuQYi7yTIkCTaxfUUyJgiWNfeTG(ArWIahS5RGSqFbU8IgUye4JSd2qbmqlahIGbqKAlWD9fYwqFfb(i7ynbUCuQYi7yTIkCTaxfUUyJgiWDTOf0txcwe4GnFfKf6lWhzhRjWLJsvgzhRvuHRf4QW1fB0abU2Yg0aRfTOf4uoqUA)PfSiOVIGfb(i7ynb(CYXGsynOuGSf4GnFfKf6lAb91iyrGpYowtGxFA4kGc0aRhLahS5RGSqFrlOV2cwe4JSJ1e4Ef4QkVX3cCWMVcYc9fTGEmuWIahS5RGSqFbU8IgUye4JSd2qbmqlahI8owePgb(i7ynb(xfPKYCzrlOVweSiWbB(kil0xGlVOHlgb(i7Gnuad0cWHiyrKkc8r2XAcC)TU(VQw0IwGpliyrqFfblc8r2XAcC)TPawzVVahS5RGSqFrlOVgblcCWMVcYc9f4YlA4IrG)z8EEgMU6Fpd45TUHi60HiVgrogd879a8mmDvxXpD1vJd28vqgr0Pdr(mEp3FaKsypLBcJZqbr0PdrgzhSHcyGwaoe5DSicDjWhzhRjW)QiLuMllAb91wWIahS5RGSqFbU8IgUye4FgVNNHPR(3ZaodfejnImYoydfWaTaCicwePwqK0icTispkWAU)aiLWEk3eghS5RGmIOthI0JcSM)xdkYQHsf2dhS5RGmIOthIixlZen3vnydxypf5EahS5RGmIOthI8Ae5ymWV3dWLRkx83AnhS5RGmIqJaFKDSMa)RIuszUSOf0JHcwe4GnFfKf6lWLx0WfJa)Z498mmD1)EgWzOGiPrKr2bBOagOfGdrWIiyiIKgrOfr6rbwZ9haPe2t5MW4GnFfKreD6qKEuG18)AqrwnuQWE4GnFfKrK0iICTmt0Cx1GnCH9uK7bCWMVcYiIoDiYRrKJXa)EpaxUQCXFR1CWMVcYisAe51iYXyGFVhG7uHeJLqcCWMVcYicnc8r2XAc8VksjL5YIwqFTiyrGd28vqwOVaxErdxmc8pJ3ZZW0v)7zaNHcIKgrgzhSHcyGwaoebdGfrQnIKgrEnICmg437b4oviXyjKahS5RGmIKgrEnICmg437b4YvLl(BTMd28vqgrsJiY1YmrZDvd2Wf2trUhWbB(kiJiPreArKEuG1C)bqkH9uUjmoyZxbzerNoePhfyn)VguKvdLkShoyZxbzeHgb(i7ynb(xfPKYCzrlONUeSiWbB(kil0xGlVOHlgboTiYbAtyH9uQhwdNRiRgkfIGfr0dIOthIKHpJ3ZRhwdNRiRgkfpV1neHgejnIqlIq5a2LhzMxHd)1(RQreD6qKpJ3Z)3ewXFaKcWpyKnIKgr(mEp3h2dCUY6l(BDn)Gr2icwerpicnc8r2XAcCVI5UufTG(xvWIaFKDSMapKqXw2JahS5RGSqFrlOxVlyrGpYowtGlxnOlUEpnboyZxbzH(IwqVEvWIahS5RGSqFbU8IgUye4ULr9dlZzVQPdfuCRInynhS5RGmIKgr(mEpN9QMouqXTk2G1LQmAJTrMN36MapSgUJHsxcVaVIapSgUJHsxcnnihtdc8kc8r2XAcCVcCvL34BbEynChdLU8O2)Oe4veTG(k6rWIahS5RGSqFbU8IgUye4hJb(9EaEgMUQR4NU6QXbB(kiJiPreArKJXa)EpaxUQCXFR1CWMVcYiIoDiYXyGFVhG7uHeJLqcCWMVcYicnisAe5Z498mmD1)EgWpqBcZHiVJiYX1Lo0aejrePVHnOkDObc8r2XAcC)TU(VQw0c6RurWIahS5RGSqFbU8IgUye4hOnHf2tPEynCUISAOuicwePcIKgrKRg0fxVNw5aTjmhI8oImYowJhsOOgtc8(g2GQ0HgiWhzhRjW9366)QArlOVsncwe4GnFfKf6lWLx0WfJa)Z49CFypW5kRV4V118dgzJi60Hiz4Z49C)TPag)aTjmhI8oI03WguLo0aerNoe5aTjSWEk1dRHZvKvdLcrsJiz4Z4986H1W5kYQHsXpqBcZHiVJi9nSbvPdnqGpYowtGhsOOgtcIwqFLAlyrGd28vqwOVaxErdxmcC3YO(HL5Yv7pDrdYrpDSghS5RGSaFKDSMa)MCmwxCuMdJIwqFfmuWIaFKDSMaxlUBpxz9LEpnWAboyZxbzH(IwqFLArWIaFKDSMa3vn8DypfkBD4e4GnFfKf6lAb9vOlblcCWMVcYc9f4YlA4IrGFmg437b45WjdkQWMl1IC10glZbB(kiJiPre5UQ8w34FgVVKdNmOOcBUulYvtBSm)GjNkIKgr(mEpphozqrf2CPwKRM2y5IpoGN36MaFKDSMa3hhu(QX1IwqFLxvWIahS5RGSqFbU8IgUye4AJnCkYgrEhrQTEqK0iYi7Gnuad0cWHiVJfrOlejnI8Ae5ymWV3dWFuJmgvXFZJgyTJd28vqwGpYowtGpNCmOaVrrTUynrlOVIExWIaFKDSMah(R9xvlWbB(kil0x0c6ROxfSiWbB(kil0xGlVOHlgb(XyGFVhG)OgzmQI)MhnWAhhS5RGmIKgrOfr6rbwZDuur3H9ucjWbB(kiJi60HiJSd2qbmqlahI8owePwqeAqK0isFdBqv6qdqemaI8ClJLlZc8VksjL5Y8d0MWCc8r2XAc8qcf1ysq0c6Rrpcwe4JSJ1e4(BD9FvTahS5RGSqFrlAbUm7eSiOVIGfboyZxbzH(c8r2XAcCx1jV1HCzVFz9LEpnWAbU8IgUye4FgVNFmguwFHYwhoEERBcCB0abUR6K36qUS3VS(sVNgyTOf0xJGfboyZxbzH(cC5fnCXiWPCa7Y69LhzMhYulSHWCiIoDiYFDoejnI4JNQD5aTjmhIGbqKARhb(i7ynboLTJ1eTG(AlyrGpYowtGNHPR(3ZaboyZxbzH(IwqpgkyrGd28vqwOVaxErdxmc8r2bBOagOfGdrWaisTrK0icTiICTmt0CxqP6AqUOnQqcCWMVcYiIoDiIBzu)WY86JRb1y5cLBPCb0PYbB(kiJi0GiPrKpJ3Z)3ewXFaKcWpyKnIGfr0JaFKDSMaxlUBpxz9LEpnWArlOVweSiWbB(kil0xGlVOHlgbUCxvERB8qMAHneMJFG2eMdrEhrQudIKgr(mEp)ymOS(cLToC88w3e4JSJ1e4hJbL1xOS1Ht0c6PlblcCWMVcYc9f4YlA4IrG)z8E(Xyqz9fkBD445TUHiPreArKpJ3ZdzQf2qyoEERBiIoDispkWA(Xyqz9fkBD44GnFfKreAqK0icTiYNX75oviXyjKapV1nerNoerUwMjAEitTq5wkmkxSghS5RGmIKgrOfr6rbwZLRg0fxVNghS5RGmIOthI4GU8xJXX7aUA07LAOireAqeD6qKr2bBOagOfGdrEhlIudIqJaFKDSMapKPwydH5eTG(xvWIahS5RGSqFbU8IgUye4hJb(9EaEdAu2BuL6ZrHd28vqgrsJiFgVNdVvDyCDSgNHcIKgrOfrOCa7Y69LhzMhYulSHWCiIoDiYFDoejnI4JNQD5aTjmhIGbqemupicnc8r2XAc8o0Gs95OiAb96Dblc8r2XAcCghuIg0CcCWMVcYc9fTGE9QGfb(i7ynb(xTBU4zUuf4GnFfKf6lAb9v0JGfb(i7ynb(hohCymShboyZxbzH(IwqFLkcwe4JSJ1e4Q4PA7k6LyYpAG1cCWMVcYc9fTG(k1iyrGpYowtG7Jd(QDZcCWMVcYc9fTG(k1wWIaFKDSMaFmj46Buf5OucCWMVcYc9fTG(kyOGfb(i7ynb(FEkRV0xiXOtGd28vqwOVOfTa31cwe0xrWIahS5RGSqFbU8IgUye40IihOnHf2tPEynCUISAOuicwerpiIoDisg(mEpVEynCUISAOu88w3qeAqK0icTicLdyxEKzEfo8x7VQgr0Pdr(mEp)Ftyf)bqka)Gr2isAeHweHYbSlpYmVc)rnYyufhLaJaIOthIq5a2LhzMxH7V11)v1isAeHwe51iICTmt084GY6lDvOmojyziZbB(kiJi60HiYDv5TUXVjhJ1fhL5Wi)aTjmhIOthICmg437b4(dGuc7PupSSJd28vqgrObr0PdrOCa7YJmZRWVjhJ1fhL5WiIOthI8z8EUpSh4CL1x836A(bJSreSiIEqK0icTisg(mEpxlUBpxz9LEpnWAodferNoe5Z49C)bqkH9uQhw2XzOGi60HiFgVNdVrzSmKlu2gSogf)Gr2icnicnicnc8r2XAcCVI5UufTG(AeSiWhzhRjW93McyL9(cCWMVcYc9fTG(AlyrGd28vqwOVaxErdxmc8d0MWc7PupSgoxrwnukb(i7ynbUC1GU4690eTGEmuWIahS5RGSqFbU8IgUye49OaR5okQO7WEkHe4GnFfKrK0ispkWAUS6ew5Gr2XACWMVcYisAe5Z49CFypW5kRV4V118dgzJiyrKpJ3Z9H9aNRS(I)wxZ1M3kUEKyuGpYowtGhsOOgtcIwqFTiyrGd28vqwOVaxErdxmc8JXa)Epapdtx1v8txD14GnFfKrK0icTiYXyGFVhGlxvU4V1AoyZxbzerNoe5ymWV3dWDQqIXsiboyZxbzeHgejnI8z8EEgMU6Fpd4hOnH5qK3re546shAaIKiI03WguLo0aejnImYoydfWaTaCiY7yrKAe4JSJ1e4(BD9FvTOf0txcwe4GnFfKf6lWLx0WfJaNwe51iYXyGFVhG7uHeJLqcCWMVcYiIoDiYRre5AzMO5Hm1cLBPWOCXACWMVcYisAe5Z498mmD1)EgWZBDdrObrsJiJSd2qbmqlahI8owePgb(i7ynb(xfPKYCzrlO)vfSiWbB(kil0xGlVOHlgb(bAtyH9uQhwdNRiRgkfIGfrQGiPrKm8z8EE9WA4Cfz1qP4hOnH5e4JSJ1e43KAz9f)TUw0c617cwe4GnFfKf6lWLx0WfJa)aTjSWEk1dRHZvKvdLcrsJiz4Z4986H1W5kYQHsXpqBcZHiVJiYX1Lo0aejrePVHnOkDObc8r2XAc8h1iJrvCucmcIwqVEvWIahS5RGSqFbU8IgUye4hOnHf2tPEynCUISAOuicwePcIKgrKRg0fxVNw5aTjmhI8oImYowJhsOOgtc8(g2GQ0HgiWhzhRjW9366)QArlOVIEeSiWbB(kil0xGlVOHlgb(bAtyH9uQhwdNRiRgkfIKgroqBclSNs9WA4Cfz1qPqK3rKpJ3Z9H9aNRS(I)wxZpyKnIKgrYWNX751dRHZvKvdLIFG2eMdrEhr6BydQshAGaFKDSMapKqrnMeeTG(kveSiWhzhRjWdjuSL9iWbB(kil0x0c6RuJGfboyZxbzH(cC5fnCXiW)mEp3FaKsypL6HLDCgkisAezKDWgkGbAb4qeSisfb(i7ynb(n5ySU4OmhgfTG(k1wWIahS5RGSqFbU8IgUye4FgVN)VjSI)aifGFWiBejnI0JcSM)OgzmQIJsGrGd28vqgrsJiY1YmrZJdkRV0vHY4KGLHmhS5RGmIKgr(mEppKHuboURhjgrK3XIiyOaFKDSMa)MCmwxCuMdJIwqFfmuWIahS5RGSqFbU8IgUye4FgVN7d7boxz9f)TUMFWiBerNoejdFgVN7VnfW4hOnH5qK3rK(g2GQ0HgiWhzhRjWdjuuJjbrlOVsTiyrGpYowtGd)1(RQf4GnFfKf6lAb9vOlblcCWMVcYc9f4YlA4IrGtlI8AePhfyn)rnYyufhLaJahS5RGmIOthI8AerUwMjAECqz9LUkugNeSmK5GnFfKreAqK0icTiYRrKJXa)Epa3FaKsypL6HLDCWMVcYiIoDiYi7Gnuad0cWHiVJfrQbrObrsJiFgVN)VjSI)aifGFWiBb(i7ynb(n5ySU4OmhgfTG(kVQGfb(i7ynbUwC3EUY6l9EAG1cCWMVcYc9fTG(k6DblcCWMVcYc9f4YlA4IrG)z8E(Xyqz9fkBD445TUHiPreArKJXa)EpaVkmxxwFPRcf)aCWMVcYiIoDiIBzu)WY8NBzdLWyhp7nDSghS5RGmIOthI4wg1pSm3hGkxwF5RwNB1CCWMVcYiIoDiYXyGFVhG7pasjSNs9WYooyZxbzejnI8z8EU)aiLWEk1dl745TUHi60HiJSd2qbmqlahI8owePgeHgb(i7ynbURA47WEku26WjAb9v0Rcwe4GnFfKf6lWLx0WfJa)ymWV3dWZHtguuHnxQf5QPnwMd28vqgrsJiYDv5TUX)mEFjhozqrf2CPwKRM2yz(btovejnI8z8EEoCYGIkS5sTixnTXYL5KJb88w3e4JSJ1e4ZjhdkWBuuRlwt0c6Rrpcwe4GnFfKf6lWLx0WfJa)ymWV3dWZHtguuHnxQf5QPnwMd28vqgrsJiYDv5TUX)mEFjhozqrf2CPwKRM2yz(btovejnI8z8EEoCYGIkS5sTixnTXYfFCapV1nb(i7ynbUpoO8vJRfTG(AQiyrGd28vqwOVaxErdxmc8pJ3Z)3ewXFaKcWpyKTaFKDSMa)rnYyufhLaJGOf0xtncwe4GnFfKf6lWLx0WfJa3TmQFyzo7vnDOGIBvSbR5GnFfKrK0iYNX75Sx10HckUvXgSUuLrBSnY88w3e4H1WDmu6s4f4ve4H1WDmu6sOPb5yAqGxrGpYowtG7vGRQ8gFlWdRH7yO0Lh1(hLaVIOf0xtTfSiWhzhRjW9366)QAboyZxbzH(Iw0cCTLnObwlyrqFfblcCWMVcYc9f4YlA4IrG)z8EEiHIxTGJN36MaFKDSMapKqXRwWjAb91iyrGd28vqwOVaxErdxmcCTXgofzJiVJi1wpisAezKDWgkGbAb4qK3XIi1iWhzhRjWNtoguG3OOwxSMOf0xBblc8r2XAcCFCq5RgxlWbB(kil0x0c6Xqblc8r2XAc8qcf1ysqGd28vqwOVOfTOf4SHZfRjOVg9utn6bd1ZRkWRpNf2JtGxRO3Q1OhdI(ADmHiiclvbej0OSxJi(9qeQzWpmQMkICqTktCqgrCRgGidtVAtdzerwDShWXrjXCyaIubticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYureAR8gnCusuYAf9wTg9yq0xRJjebryPkGiHgL9AeXVhIqDwGkICqTktCqgrCRgGidtVAtdzerwDShWXrjXCyaIudMqe6SgB4AiJiupgd879aCwPIi9Iiupgd879aCw5GnFfKPIi0w5nA4OKyomarQnMqe6SgB4AiJiu7rbwZzLkI0lIqThfynNvoyZxbzQicT18gnCusmhgGi1gticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYureAR8gnCusmhgGi1gticDwJnCnKreQY1YmrZzLkI0lIqvUwMjAoRCWMVcYureAR8gnCusmhgGiyiMqe6SgB4AiJiu7rbwZzLkI0lIqThfynNvoyZxbzQicT18gnCusmhgGiyiMqe6SgB4AiJiupgd879aCwPIi9Iiupgd879aCw5GnFfKPIi0wZB0WrjXCyaIGHycrOZASHRHmIqvUwMjAoRurKEreQY1YmrZzLd28vqMkIqBL3OHJsI5WaePwWeIqN1ydxdzeHApkWAoRurKEreQ9OaR5SYbB(kitfrOTM3OHJsI5WaePwWeIqN1ydxdzeH6XyGFVhGZkvePxeH6XyGFVhGZkhS5RGmveH2AEJgokjMddqKAbticDwJnCnKreQY1YmrZzLkI0lIqvUwMjAoRCWMVcYureAR8gnCusmhgGi6vmHi0zn2W1qgrO6wg1pSmNvQisVicv3YO(HL5SYbB(kitfrOTYB0WrjXCyaIurpycrOZASHRHmIq9ymWV3dWzLkI0lIq9ymWV3dWzLd28vqMkIqBnVrdhLeZHbisf9GjeHoRXgUgYic1JXa)EpaNvQisVic1JXa)EpaNvoyZxbzQicTvEJgokjMddqKk1gticDwJnCnKreQULr9dlZzLkI0lIq1TmQFyzoRCWMVcYurKPrKxb9YygrOTYB0WrjXCyaIuHUWeIqN1ydxdzeH6XyGFVhGZkvePxeH6XyGFVhGZkhS5RGmveH2kVrdhLeZHbisLxfticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYurKPrKxb9YygrOTYB0WrjXCyaIurVIjeHoRXgUgYic1EuG1CwPIi9Iiu7rbwZzLd28vqMkIqBL3OHJsI5WaePIEfticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYureAR8gnCusuYAf9wTg9yq0xRJjebryPkGiHgL9AeXVhIqvMDurKdQvzIdYiIB1aezy6vBAiJiYQJ9aookjMddqemeticDwJnCnKreQY1YmrZzLkI0lIqvUwMjAoRCWMVcYureAR8gnCusmhgGiyiMqe6SgB4AiJiuDlJ6hwMZkvePxeHQBzu)WYCw5GnFfKPIi0w5nA4OKyomarOlmHi0zn2W1qgrO2JcSMZkvePxeHApkWAoRCWMVcYureAR5nA4OKyomarOlmHi0zn2W1qgrOkxlZenNvQisVicv5AzMO5SYbB(kitfrOTYB0WrjXCyaI8QycrOZASHRHmIq9ymWV3dWzLkI0lIq9ymWV3dWzLd28vqMkIqBL3OHJsIswRO3Q1OhdI(ADmHiiclvbej0OSxJi(9qeQUMkICqTktCqgrCRgGidtVAtdzerwDShWXrjXCyaIubticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYureAR8gnCusmhgGivWeIqN1ydxdzeHQCTmt0CwPIi9IiuLRLzIMZkhS5RGmveH2kVrdhLeZHbicgIjeHoRXgUgYic1EuG1CwPIi9Iiu7rbwZzLd28vqMkIqBnVrdhLeZHbisTGjeHoRXgUgYic1JXa)EpaNvQisVic1JXa)EpaNvoyZxbzQicT18gnCusmhgGi1cMqe6SgB4AiJiupgd879aCwPIi9Iiupgd879aCw5GnFfKPIi0w5nA4OKyomarOlmHi0zn2W1qgrOEmg437b4Ssfr6frOEmg437b4SYbB(kitfrOTYB0WrjXCyaIqxycrOZASHRHmIqvUwMjAoRurKEreQY1YmrZzLd28vqMkIqBL3OHJsI5WaePsTXeIqN1ydxdzeHApkWAoRurKEreQ9OaR5SYbB(kitfrOTYB0WrjXCyaIuP2ycrOZASHRHmIqvUwMjAoRurKEreQY1YmrZzLd28vqMkIqBL3OHJsI5WaePcDHjeHoRXgUgYic1EuG1CwPIi9Iiu7rbwZzLd28vqMkIqBL3OHJsI5WaePcDHjeHoRXgUgYic1JXa)EpaNvQisVic1JXa)EpaNvoyZxbzQicTvEJgokjMddqKk0fMqe6SgB4AiJiuLRLzIMZkvePxeHQCTmt0Cw5GnFfKPIi0w5nA4OKyomarQO3XeIqN1ydxdzeH6XyGFVhGZkvePxeH6XyGFVhGZkhS5RGmveH2AEJgokjMddqKk6DmHi0zn2W1qgrO6wg1pSmNvQisVicv3YO(HL5SYbB(kitfrOTM3OHJsI5WaePIEfticDwJnCnKreQhJb(9EaoRurKEreQhJb(9EaoRCWMVcYureAR8gnCusmhgGi1OhmHi0zn2W1qgrOEmg437b4Ssfr6frOEmg437b4SYbB(kitfrOTYB0WrjXCyaIutnycrOZASHRHmIq1TmQFyzoRurKEreQULr9dlZzLd28vqMkIqBL3OHJsIsIbPrzVgYicDHiJSJ1qev4AhhLuGt5wFOaboDt3iYRCEae5v8wxJss30nIO3OCHcrQ8QVGi1ONAQbLeLKUPBeHovh7bCycLKUPBerVarWGTg1grctQyYaIOVkmmIiHHiVYLnObwJi6nm4ygrOLY6IowlShejCiYGiuutQWHizqgUynAqjPB6gr0lqKx5GrarCRgGiu9Xt1UCG2eMJkIawFb4qKHcfvQisViYFDoeXhpvBhISMkvokjkjDt3iYRWBGKPHmI8b)EaIixT)0iYhEcZXre9MucuAhIyRPxuDonpJcrgzhR5qK1uPYrjhzhR54uoqUA)PteBcZjhdkH1GsbYgLCKDSMJt5a5Q9NorSj4y00wRuFA4kGc0aRhfk5i7ynhNYbYv7pDIytWRaxv5n(gLCKDSMJt5a5Q9NorSj8vrkPmx(LWJDKDWgkGbAb4EhBnOKJSJ1CCkhixT)0jInb)TU(VQ(LWJDKDWgkGbAb4WwbLeLKUPBe5v4nqY0qgra2WLkI0HgGiDvargzVhIeoezypHA(kGJsoYowZHvUmwdNJcOuVeESV(ymWV3dWZHtguuHnxQf5QPnwoDg(mEpxoUoShodL0z4Z49C546WE4hOnH5Wav0PtURkV1n(NX7l5WjdkQWMl1IC10glZpyYPM(Z498C4KbfvyZLArUAAJLlZjhd45TUHsoYowZLi2eKJsvgzhRvuHRFXgnaRm7qjhzhR5seBcYrPkJSJ1kQW1VyJgGfCoWKGdLCKDSMlrSjihLQmYowROcx)InAa2zHxC9fYgBLxcp2r2bBOagOfG7DS1gLCKDSMlrSjihLQmYowROcx)InAawx)IRVq2yR8s4XoYoydfWaTaCyGAJsoYowZLi2eKJsvgzhRvuHRFXgnaR2Yg0aRrjrjhzhR54Zcy93McyL9(OKJSJ1C8zHeXMWxfPKYC5xcp2pJ3ZZW0v)7zapV1nD6E9XyGFVhGNHPR6k(PRUA609z8EU)aiLWEk3egNHIoDJSd2qbmqla37yPluYr2XAo(SqIyt4RIuszU8lHh7NX75zy6Q)9mGZqj9i7Gnuad0cWHTwstBpkWAU)aiLWEk3eMoD9OaR5)1GISAOuH9OtNCTmt0Cx1GnCH9uK7b6096JXa)EpaxUQCXFR10GsoYowZXNfseBcFvKskZLFj8y)mEppdtx9VNbCgkPhzhSHcyGwaoSyyAA7rbwZ9haPe2t5MW0PRhfyn)VguKvdLkSN0Y1YmrZDvd2Wf2trUhOt3Rpgd879aC5QYf)TwN(1hJb(9EaUtfsmwcjqdk5i7ynhFwirSj8vrkPmx(LWJ9Z498mmD1)EgWzOKEKDWgkGbAb4WayRD6xFmg437b4oviXyjKq6xFmg437b4YvLl(BToTCTmt0Cx1GnCH9uK7bPPThfyn3FaKsypLBctNUEuG18)AqrwnuQWEObLCKDSMJplKi2e8kM7s9LWJL2d0MWc7PupSgoxrwnukS6rNUm8z8EE9WA4Cfz1qP45TUrtAAPCa7YJmZRWH)A)v1609z8E()MWk(dGua(bJSt)z8EUpSh4CL1x836A(bJSXQhAqjhzhR54ZcjInHqcfBzpOKJSJ1C8zHeXMGC1GU4690qjhzhR54ZcjInbVcCvL347xcpw3YO(HL5Sx10HckUvXgSo9NX75Sx10HckUvXgSUuLrBSnY88w3EjSgUJHsxcnnihtdyR8synChdLU8O2)OWw5LWA4ogkDj8yRGsoYowZXNfseBc(BD9Fv9lHh7XyGFVhGNHPR6k(PRUAPP9ymWV3dWLRkx83AToDhJb(9EaUtfsmwcjqt6pJ3ZZW0v)7za)aTjm37YX1Lo0Ge7BydQshAak5i7ynhFwirSj4V11)v1VeEShOnHf2tPEynCUISAOuyRKwUAqxC9EALd0MWCVpYowJhsOOgtc8(g2GQ0HgGsoYowZXNfseBcHekQXKWlHh7NX75(WEGZvwFXFRR5hmYwNUm8z8EU)2uaJFG2eM79(g2GQ0HgOt3bAtyH9uQhwdNRiRgkv6m8z8EE9WA4Cfz1qP4hOnH5EVVHnOkDObOKJSJ1C8zHeXMWn5ySU4OmhgFj8yDlJ6hwMlxT)0fnih90XAOKJSJ1C8zHeXMGwC3EUY6l9EAG1OKJSJ1C8zHeXMGRA47WEku26WHsoYowZXNfseBc(4GYxnU(LWJ9ymWV3dWZHtguuHnxQf5QPnwoTCxvERB8pJ3xYHtguuHnxQf5QPnwMFWKtn9NX755WjdkQWMl1IC10glx8Xb88w3qjhzhR54ZcjInH5KJbf4nkQ1fR9s4XQn2WPi73RTEspYoydfWaTaCVJLUs)6JXa)Epa)rnYyuf)npAG1ouYr2XAo(SqIyta(R9xvJsoYowZXNfseBcHekQXKWlHh7XyGFVhG)OgzmQI)MhnWAxAA7rbwZDuur3H9ucjOt3i7Gnuad0cW9o2AHM09nSbvPdnad8ClJLlZc8VksjL5Y8d0MWCOK0nDJiJSJ1C8zHeXMq9j6xCGeRE4vEj8ypgd879a8h1iJrv838Obw7s3JcSM7OOIUd7PesaLCKDSMJplKi2e8366)QAusuYr2XAoUm7WY4Gs0G2l2ObyDvN8whYL9(L1x690aRFj8y)mEp)ymOS(cLToC88w3qjhzhR54YSlrSjqz7yTxcpwkhWUSEF5rM5Hm1cBimNoD)15s7JNQD5aTjmhgO26bLCKDSMJlZUeXMqgMU6FpdqjhzhR54YSlrSjOf3TNRS(sVNgy9lHh7i7Gnuad0cWHbQDAALRLzIM7ckvxdYfTrfsqNo3YO(HL51hxdQXYfk3s5cOtLM0FgVN)VjSI)aifGFWiBS6bLCKDSMJlZUeXMWXyqz9fkBD4Ej8yL7QYBDJhYulSHWC8d0MWCVxPM0FgVNFmguwFHYwhoEERBOKJSJ1CCz2Li2eczQf2qyUxcp2pJ3ZpgdkRVqzRdhpV1T00(z8EEitTWgcZXZBDtNUEuG18JXGY6lu26WrtAA)mEp3PcjglHe45TUPtNCTmt08qMAHYTuyuUyT002JcSMlxnOlUEpnD6Cqx(RX44Daxn69snuK0Ot3i7Gnuad0cW9o2AObLCKDSMJlZUeXMqhAqP(CuEj8ypgd879a8g0OS3Ok1NJs6pJ3ZH3QomUowJZqjnTuoGDz9(YJmZdzQf2qyoD6(RZL2hpv7YbAtyomagQhAqjhzhR54YSlrSjW4Gs0GMdLCKDSMJlZUeXMWxTBU4zUurjhzhR54YSlrSj8HZbhgd7bLCKDSMJlZUeXMGkEQ2UIEjM8Jgynk5i7ynhxMDjInbFCWxTBgLCKDSMJlZUeXMWysW13OkYrPqjhzhR54YSlrSj8NNY6l9fsm6qjrjPB6grWGfU5RGmI8b5W4aerFvyymb8QHMgCis4qKbrOOMuHdrKv3qcCus6MUrKr2XAoU2Yg0aRX(vHHXYyP(s4XQTSbnWAEoC9ys49k6bLCKDSMJRTSbnW6eXMqiHIxTG7LWJ9Z498qcfVAbhpV1nuYr2XAoU2Yg0aRteBcZjhdkWBuuRlw7LWJvBSHtr2VxB9KEKDWgkGbAb4EhBnOKJSJ1CCTLnObwNi2e8XbLVACnk5i7ynhxBzdAG1jInHqcf1ysaLeLCKDSMJ7ASEfZDP(s4Xs7bAtyH9uQhwdNRiRgkfw9Otxg(mEpVEynCUISAOu88w3OjnTuoGD5rM5v4WFT)QAD6(mEp)Ftyf)bqka)Gr2PPLYbSlpYmVc)rnYyufhLaJGoDuoGD5rM5v4(BD9FvDAAFTCTmt084GY6lDvOmojyziRtNCxvERB8BYXyDXrzomYpqBcZPt3XyGFVhG7pasjSNs9WYoA0PJYbSlpYmVc)MCmwxCuMdJ609z8EUpSh4CL1x836A(bJSXQN00MHpJ3Z1I72ZvwFP3tdSMZqrNUpJ3Z9haPe2tPEyzhNHIoDFgVNdVrzSmKlu2gSogf)Gr20qdnOKJSJ1CCxNi2e83McyL9(OKJSJ1CCxNi2eKRg0fxVN2lHh7bAtyH9uQhwdNRiRgkfk5i7ynh31jInHqcf1ys4LWJThfyn3rrfDh2tjKq6EuG1Cz1jSYbJSJ1s)z8EUpSh4CL1x836A(bJSX(z8EUpSh4CL1x836AU28wX1JeJOKJSJ1CCxNi2e8366)Q6xcp2JXa)Epapdtx1v8txD1st7XyGFVhGlxvU4V1AD6ogd879aCNkKySesGM0FgVNNHPR(3Za(bAtyU3LJRlDObj23WguLo0G0JSd2qbmqla37yRbLCKDSMJ76eXMWxfPKYC5xcpwAF9XyGFVhG7uHeJLqc609A5AzMO5Hm1cLBPWOCXAP)mEppdtx9VNb88w3Oj9i7Gnuad0cW9o2AqjhzhR54UorSjCtQL1x8366xcp2d0MWc7PupSgoxrwnukSvsNHpJ3ZRhwdNRiRgkf)aTjmhk5i7ynh31jInHh1iJrvCucmcVeEShOnHf2tPEynCUISAOuPZWNX751dRHZvKvdLIFG2eM7D546shAqI9nSbvPdnaLCKDSMJ76eXMG)wx)xv)s4XEG2ewypL6H1W5kYQHsHTsA5QbDX17PvoqBcZ9(i7ynEiHIAmjW7BydQshAak5i7ynh31jInHqcf1ys4LWJ9aTjSWEk1dRHZvKvdLk9bAtyH9uQhwdNRiRgk17FgVN7d7boxz9f)TUMFWi70z4Z4986H1W5kYQHsXpqBcZ9EFdBqv6qdqjhzhR54UorSjesOyl7bLCKDSMJ76eXMWn5ySU4OmhgFj8y)mEp3FaKsypL6HLDCgkPhzhSHcyGwaoSvqjhzhR54UorSjCtogRlokZHXxcp2pJ3Z)3ewXFaKcWpyKD6EuG18h1iJrvCucmcPLRLzIMhhuwFPRcLXjbld50FgVNhYqQah31JeJVJfdrjhzhR54UorSjesOOgtcVeESFgVN7d7boxz9f)TUMFWiBD6YWNX75(Btbm(bAtyU37BydQshAak5i7ynh31jInb4V2Fvnk5i7ynh31jInHBYXyDXrzom(s4Xs7R7rbwZFuJmgvXrjWiOt3RLRLzIMhhuwFPRcLXjbldzAst7Rpgd879aC)bqkH9uQhw2Pt3i7Gnuad0cW9o2AOj9NX75)BcR4pasb4hmYgLCKDSMJ76eXMGwC3EUY6l9EAG1OKJSJ1CCxNi2eCvdFh2tHYwhUxcp2pJ3ZpgdkRVqzRdhpV1T00Emg437b4vH56Y6lDvO4hqNo3YO(HL5p3YgkHXoE2B6ynD6ClJ6hwM7dqLlRV8vRZTAoD6ogd879aC)bqkH9uQhw2L(Z49C)bqkH9uQhw2XZBDtNUr2bBOagOfG7DS1qdk5i7ynh31jInH5KJbf4nkQ1fR9s4XEmg437b45WjdkQWMl1IC10glNwURkV1n(NX7l5WjdkQWMl1IC10glZpyYPM(Z498C4KbfvyZLArUAAJLlZjhd45TUHsoYowZXDDIytWhhu(QX1VeEShJb(9EaEoCYGIkS5sTixnTXYPL7QYBDJ)z8(soCYGIkS5sTixnTXY8dMCQP)mEpphozqrf2CPwKRM2y5IpoGN36gk5i7ynh31jInHh1iJrvCucmcVeESFgVN)VjSI)aifGFWiBuYr2XAoURteBcEf4QkVX3VeESULr9dlZzVQPdfuCRInyD6pJ3ZzVQPdfuCRInyDPkJ2yBK55TU9synChdLUeAAqoMgWw5LWA4ogkD5rT)rHTYlH1WDmu6s4XwbLCKDSMJ76eXMG)wx)xvlWDuaPGE6cdfTOfca]] )


end
