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

    spec:RegisterPack( "Frost Mage", 20220403, [[dOuk4aqijvXJKuvBss5tIuJse1PerEfsvZssYTuLsAxK8lKsddjPJjswMKkpJujttvkUMKOSnjvPVHKQACQsPCojrL1rQO5rQG7bs7tvQoisQyHivEOKitKuH0fjvi2OQucFejvYjLevTsc1mjvQBsQqTtq4NQsPQHQkLOLIKk1tb1ubrFfjvXyLKAVi(ROgmQoSulwv9yuMSexgAZu6ZQIrRk50cRwvkvEnsIztXTjy3u9BLgosCCKuLwUkpNOPR46KY2jKVlcJhjLZJuSEjH5tQA)atsrGKax6bjquhvRRoQ(gQQlvQkxDPQmQpbEOHcsGP0mQ0pib2BbKa)wCRCaCDC)GeyknnMTleijWYv7yib(1muK6KwAFI5L2xXwbALHGMPNyD212HwziWOLa)1cZu5DYNax6bjquhvRRoQ(gQQlvQkxDPQmDrGBT51Eey4qOse4xrPGo5tGlOKrG1X9dc4Vf3khGyQdLlmaEQQa86OAD1bedexPxT)GsDce)wbCD01tpaE4mJwbbC6mHtfapCaxhVIqb0haN68wQBapzkRmMy9WFa8qc4nGtX00GhGxqwiJ1tci(Tc464MkiGlxbeWtBJNxt(qHoCzAah95cuc4nfkgAa8zb8)kLaUnEEnsaFDdnkcSjKJKajbUG2wZmeijqKIajbg9(BWcHocm7IbVOjW1dGFAoA37bvLqYckMW7JMmBfeAVOqV)gSa41a8c(1SwfRLt4pknkaEnaVGFnRvXA5e(J6qHoCjGRdaEkaxVEaNTRPSjC1xZAZLqYckMW7JMmBfeAVOoSl0a41a8VM1QkHKfumH3hnz2ki0Ej3hRDuv2eobUztSobMTA(GNKcAmKHarDeijWO3Fdwi0rGB2eRtGzTXKB2eRNnHCiWMqozVfqcmRijdbcDrGKaJE)nyHqhbUztSobM1gtUztSE2eYHaBc5K9wajWOuIodLKHaXBiqsGrV)gSqOJaZUyWlAcCZMqeMrhfcuc4VdfW1fbwoxWgcePiWnBI1jWS2yYnBI1ZMqoeytiNS3cibUxKmeiQmcKey07Vble6iWSlg8IMa3SjeHz0rHaLaUoa46IalNlydbIue4MnX6eywBm5MnX6ztihcSjKt2BbKalhYqGOEjqsGrV)gSqOJa3SjwNaZAJj3SjwpBc5qGnHCYElGeyHvekG(qgYqGPCiBf(9qGKarkcKe4MnX6e4(yTJ5Wh0yq2qGrV)gSqOJmeiQJajbUztSoborp4LrdkG(0gcm693GfcDKHaHUiqsGB2eRtGTgu(IDTDiWO3Fdwi0rgceVHajbg9(BWcHocm7IbVOjWnBcrygDuiqjG)ouaVocCZMyDc83evurFfYqGOYiqsGrV)gSqOJaZUyWlAcCZMqeMrhfcuc4qb8ue4MnX6ey7TY5VMHmKHa3lsGKarkcKe4MnX6ey7TvGEEVpbg9(BWcHoYqGOocKe4MnX6e4VjQOI(key07Vble6idbcDrGKaJE)nyHqhbMDXGx0e4Kb8df6Wd)jNi8bpzM9kmgahkGtvaxVEaVGFnRvLi8bpzM9kmgvzt4aEsaEnapzaNYHIYpSIkLc)R)xZa461d4FnRv9Vo8S9qScuDyZgaVgG)1SwLn8h8K51MT3kh1HnBaCOaovb8KiWnBI1jWwJ2D0qgceVHajbUztSoboyy2xrnbg9(BWcHoYqGOYiqsGB2eRtGzRaoz5SNabg9(BWcHoYqGOEjqsGrV)gSqOJaZUyWlAc8xZAv2WFWtMxB2ERCuh2SbW1RhWl4xZAv2BRaD1HcD4sa)DaFUweAYtiGaUE9a(HcD4H)Kte(GNmZEfgdGxdWl4xZAvjcFWtMzVcJrDOqhUeWFhWNRfHM8ecibUztSoboyy20odjdbcQpbscm693GfcDey2fdErtGLRM5hErXwHFpzbSetpX6k07Vble4MnX6e4Rlr7twsPpQqgceVncKe4MnX6eyH4U9K51MN9eqFiWO3Fdwi0rgcevocKe4MnX6ey5RWoH)KPSjWJaJE)nyHqhziqKIQeijWO3Fdwi0rGzxm4fnb(0C0U3dQEUqAOjhSGzqf693GfaVgGp99GJYGIqdGRdqbCdkcnaEnaVGFnRvzVTc0vLnHtGB2eRtGT3kNSVIAYqGivkcKey07Vble6iWSlg8IMaFAoA37bvLqYckMW7JMmBfeAVOqV)gSa41aC2UMYMWvFnRnxcjlOycVpAYSvqO9I6WUqdGxdW)AwRQeswqXeEF0KzRGq7LSnouv2eobUztSob2ghM)MwoKHarQ6iqsGrV)gSqOJaZUyWlAcSq7TIcBa83bCDrvaVgG3SjeHz0rHaLa(7qb86fWRb41dGFAoA37bvpMMfTjBV(ra9rQqV)gSqGB2eRtG7J1oMrQrXSYyDYqGiLUiqsGB2eRtGX)6)1mey07Vble6idbIuVHajbg9(BWcHocm7IbVOjWNMJ29Eq1JPzrBY2RFeqFKk07VblaEnapzaFAd6JssXeZe(toyOc9(BWcGRxpG3SjeHz0rHaLa(7qb8kdWtcWRb4Z1IqtEcbeW1ba)5wnVK7fvFturf9vuhk0HljWnBI1jWbdZM2ziziqKQYiqsGB2eRtGT3kN)Agcm693GfcDKHmeywrsGKarkcKey07Vble6iWnBI1jWYxDztGL8E)8AZZEcOpey2fdErtG)AwR60CmV2mLnbEQYMWjWElGey5RUSjWsEVFET5zpb0hYqGOocKey07Vble6iWSlg8IMat5qr51AZpSIky0KfHHlbC96b8)kLaEna3gpVM8HcD4saxhaCDrvcCZMyDcmLDI1jdbcDrGKa3SjwNaxWEE93Zrcm693GfcDKHaXBiqsGrV)gSqOJaZUyWlAcCZMqeMrhfcuc46aGRlaVgGNmGZwVOfJsguETowYcTjyOc9(BWcGRxpGlxnZp8Ikrlh00Ejt5wkxGdnk07VblaEsaEna)RzTQ)1HNThIvGQdB2a4qbCQsGB2eRtGfI72tMxBE2ta9HmeiQmcKey07Vble6iWSlg8IMaZ21u2eUky0KfHHlvhk0Hlb83b8u1b41a8VM1QonhZRntztGNQSjCcCZMyDc8P5yETzkBc8idbI6Lajbg9(BWcHocm7IbVOjWFnRvDAoMxBMYMapvzt4aEnapza)RzTQGrtwegUuv2eoGRxpGpTb9rDAoMxBMYMapf693GfapjaVgGNmG)1SwL0emQKdgQkBchW1RhWB2eIWm6OqGsa)DOaEDaEse4MnX6e4GrtwegUKmeiO(eijWO3Fdwi0rGzxm4fnb(0C0U3dQguGYETjNOpkk07VblaEna)RzTkKAVAn5eRR0Oa41a8KbCkhkkVwB(HvubJMSimCjGRxpG)xPeWRb42451KpuOdxc46aG)gQc4jrGB2eRtGNqaZj6Jcziq82iqsGB2eRtG1KyoguqsGrV)gSqOJmeiQCeijWnBI1jWFZULSv7OHaJE)nyHqhziqKIQeijWnBI1jWF8K4rLWFiWO3Fdwi0rgcePsrGKa3SjwNaBINxJm)2PvEeqFiWO3Fdwi0rgcePQJajbUztSob2gh(n7wiWO3Fdwi0rgceP0fbscCZMyDcC7muoxBYS2yiWO3Fdwi0rgcePEdbscCZMyDc8VFYRnpxWOIKaJE)nyHqhzidbwoeijqKIajbg9(BWcHocm7IbVOjWjd4hk0Hh(tor4dEYm7vymaouaNQaUE9aEb)AwRkr4dEYm7vymQYMWb8Ka8AaEYaoLdfLFyfvkf(x)VMbW1RhW)AwR6FD4z7HyfO6WMnaEnapzaNYHIYpSIkL6X0SOnzjLGkiGRxpGt5qr5hwrLszVvo)1maEnapzaVEaC26fTyuXH51MNxyULm0lyrHE)nybW1RhWz7AkBcxDDjAFYsk9rf1HcD4saxVEa)0C0U3dQShIve(tor4fPc9(BWcGNeGRxpGt5qr5hwrLsDDjAFYsk9rfaxVEa)RzTkB4p4jZRnBVvoQdB2a4qbCQc41a8Kb8c(1SwLqC3EY8AZZEcOpknkaUE9a(xZAv2dXkc)jNi8IuPrbW1RhW)AwRcPgL2lyjtzh0NOnQdB2a4jb4jb4jrGB2eRtGTgT7OHmeiQJajbUztSob2EBfON37tGrV)gSqOJmei0fbscm693GfcDey2fdErtG)AwRYEiwr4p5RdxPrbW1RhWB2eIWm6OqGsa)DOaEDe4MnX6e4VjQOI(kKHaXBiqsGrV)gSqOJaZUyWlAc8HcD4H)Kte(GNmZEfgdGdfWtb41a8c(1SwvIWh8Kz2RWyuhk0HljWnBI1jWxttETz7TYHmeiQmcKey07Vble6iWSlg8IMaFOqhE4p5eHp4jZSxHXa41a8c(1SwvIWh8Kz2RWyuhk0Hlb83bCwlN8eciGtpGpxlcn5jeqcCZMyDc8JPzrBYskbvqYqGOEjqsGrV)gSqOJaZUyWlAc8HcD4H)Kte(GNmZEfgdGxdWpuOdp8NCIWh8Kz2RWya83b8VM1QSH)GNmV2S9w5OoSzdGxdWl4xZAvjcFWtMzVcJrDOqhUeWFhWNRfHM8ecibUztSoboyy20odjdbcQpbscCZMyDcmBfWjlN9eiWO3Fdwi0rgceVncKe4MnX6e4GHzFf1ey07Vble6idbIkhbscm693GfcDey2fdErtG)AwRYEiwr4p5eHxKknkaEnaVzticZOJcbkbCOaEkcCZMyDc81LO9jlP0hvidbIuuLajbg9(BWcHocm7IbVOjWFnRv9Vo8S9qScuDyZgaVgGpTb9r9yAw0MSKsqfuHE)nybWRb4S1lAXOIdZRnpVWClzOxWIc9(BWcGxdW)AwRkybZGsLCAgva83Hc4VHa3SjwNaFDjAFYsk9rfYqGivkcKey07Vble6iWSlg8IMa)1SwLn8h8K51MT3kh1HnBaC96b8c(1SwL92kqxDOqhUeWFhWNRfHM8ecibUztSoboyy20odjdbIu1rGKa3SjwNaJ)1)RziWO3Fdwi0rgceP0fbscm693GfcDey2fdErtGtgWRhaFAd6J6X0SOnzjLGkOc9(BWcGRxpGxpaoB9IwmQ4W8AZZlm3sg6fSOqV)gSa4jb41a8Kb86bWpnhT79Gk7HyfH)KteErQqV)gSa461d4nBcrygDuiqjG)ouaVoapjaVgG)1Sw1)6WZ2dXkq1HnBiWnBI1jWxxI2NSKsFuHmeis9gcKe4MnX6eyH4U9K51MN9eqFiWO3Fdwi0rgcePQmcKey07Vble6iWSlg8IMa)1Sw1P5yETzkBc8uLnHd41a8Kb8tZr7EpO6f23KxBEEHzBJk07VblaUE9aUC1m)WlQNBfH5Wffp71tSUc9(BWcGRxpGlxnZp8IYgOPKxB(BwPCfKk07VblaUE9a(P5ODVhuzpeRi8NCIWlsf693GfaVgG)1SwL9qSIWFYjcVivLnHd461d4nBcrygDuiqjG)ouaVoapjcCZMyDcS8vyNWFYu2e4rgcePQxcKey07Vble6iWSlg8IMaFAoA37bvpxin0KdwWmOc9(BWcGxdWN(EWrzqrObW1bOaUbfHgaVgGxWVM1QS3wb6QYMWjWnBI1jW2BLt2xrnziqKI6tGKaJE)nyHqhbMDXGx0e4tZr7EpOQeswqXeEF0KzRGq7ff693GfaVgGZ21u2eU6RzT5sizbft49rtMTccTxuh2fAa8Aa(xZAvLqYckMW7JMmBfeAVK7J1oQkBcNa3SjwNa3hRDmJuJIzLX6KHarQ3gbscm693GfcDey2fdErtGpnhT79GQsizbft49rtMTccTxuO3Fdwa8AaoBxtzt4QVM1MlHKfumH3hnz2ki0ErDyxObWRb4FnRvvcjlOycVpAYSvqO9s2ghQkBcNa3SjwNaBJdZFtlhYqGivLJajbg9(BWcHocm7IbVOjWFnRv9Vo8S9qScuDyZgcCZMyDc8JPzrBYskbvqYqGOoQsGKa3SjwNaBVvo)1mey07Vble6idziWcRiua9HajbIueijWO3Fdwi0rGzxm4fnb(RzTQGHzRzrPQSjCcCZMyDcCWWS1SOKmeiQJajbg9(BWcHocm7IbVOjWcT3kkSbWFhW1fvb8AaEZMqeMrhfcuc4VdfWRJa3SjwNa3hRDmJuJIzLX6KHaHUiqsGB2eRtGTXH5VPLdbg9(BWcHoYqG4neijWnBI1jWbdZM2zibg9(BWcHoYqgYqGfHNmwNarDuTUuPsvNUiWj6Zd)rsGPEOou3qu5HG6sNaoGd5leWdbk7naUDpapDbTTMzsd4hs9QfhwaC5kGaERnRqpybWzVA)bLkGyDhoc4P0jGxP1fH3Gfap9P5ODVhuvDAaFwap9P5ODVhuvTc9(BWsAap5uuljfqmqm1d1H6gIkpeux6eWbCiFHaEiqzVbWT7b4P7ftd4hs9QfhwaC5kGaERnRqpybWzVA)bLkGyDhoc4uFDc4vADr4nybWtlxnZp8IQ60a(SaEA5Qz(HxuvRqV)gSKgW7bW1rE71nGNCkQLKciw3HJaEkQQtaVsRlcVblaE6tZr7EpOQ60a(SaE6tZr7EpOQAf693GL0aEYPOwskGyDhoc4PsPtaVsRlcVblaE6tZr7EpOQ60a(SaE6tZr7EpOQAf693GL0aEYPOwskGyDhoc4PQtNaELwxeEdwa80NMJ29Eqv1Pb8zb80NMJ29Eqv1k07VblPb8EaCDK3EDd4jNIAjPaI1D4iGN6n6eWR06IWBWcGNEAd6JQ60a(SaE6PnOpQQvO3Fdwsd4jNIAjPaI1D4iGN6n6eWR06IWBWcGN(0C0U3dQQonGplGN(0C0U3dQQwHE)nyjnGNCkQLKcigiM6H6qDdrLhcQlDc4aoKVqapeOS3a429a80SImnGFi1RwCybWLRac4T2Sc9GfaN9Q9huQaI1D4iG)gDc4vADr4nybWtZwVOfJQ60a(SaEA26fTyuvRqV)gSKgWtof1ssbeR7Wra)n6eWR06IWBWcGNwUAMF4fv1Pb8zb80YvZ8dVOQwHE)nyjnGNCkQLKciw3HJaE9QtaVsRlcVblaE6PnOpQQtd4Zc4PN2G(OQwHE)nyjnGNCkQLKciw3HJao1xNaELwxeEdwa80NMJ29Eqv1Pb8zb80NMJ29Eqv1k07VblPb8KtrTKuaXaXupuhQBiQ8qqDPtahWH8fc4HaL9ga3UhGNwoPb8dPE1IdlaUCfqaV1MvOhSa4SxT)GsfqSUdhb8u6eWR06IWBWcGN(0C0U3dQQonGplGN(0C0U3dQQwHE)nyjnGNCkQLKciw3HJaEkDc4vADr4nybWtZwVOfJQ60a(SaEA26fTyuvRqV)gSKgWtof1ssbeR7Wrapfv1jGxP1fH3Gfap90g0hv1Pb8zb80tBqFuvRqV)gSKgWtof1ssbeR7Wrapfv1jGxP1fH3GfapnB9IwmQQtd4Zc4PzRx0IrvTc9(BWsAap5uuljfqSUdhb8u6sNaELwxeEdwa80tBqFuvNgWNfWtpTb9rvTc9(BWsAap5uuljfqSUdhb8u6sNaELwxeEdwa80NMJ29Eqv1Pb8zb80NMJ29Eqv1k07VblPb8KtrTKuaX6oCeWtPlDc4vADr4nybWtZwVOfJQ60a(SaEA26fTyuvRqV)gSKgWtof1ssbeR7WrapvLPtaVsRlcVblaE6tZr7EpOQ60a(SaE6tZr7EpOQAf693GL0aEY1rTKuaX6oCeWtvz6eWR06IWBWcGNwUAMF4fv1Pb8zb80YvZ8dVOQwHE)nyjnGNCDuljfqSUdhb8u1Rob8kTUi8gSa4PpnhT79GQQtd4Zc4PpnhT79GQQvO3Fdwsd4jNIAjPaI1D4iGNI6RtaVsRlcVblaE6tZr7EpOQ60a(SaE6tZr7EpOQAf693GL0aEYPOwskGyDhoc4PEB6eWR06IWBWcGN(0C0U3dQQonGplGN(0C0U3dQQwHE)nyjnGNCkQLKcigiUYlqzVblaE9c4nBI1bCtihPciMalPGmce17BiWuU1ggKax)6d464(bb83IBLdqC9RpGtDOCHbWtvfGxhvRRoGyG46xFaVsVA)bL6eiU(1hWFRaUo66PhapCMrRGaoDMWPcGhoGRJxrOa6dGtDEl1nGNmLvgtSE4paEib8gWPyAAWdWlilKX6jbex)6d4Vvaxh3ubbC5kGaEAB88AYhk0Hltd4OpxGsaVPqXqdGplG)xPeWTXZRrc4RBOrbedex)6d46iudzAdwa8pA3dbC2k87bW)4t4sfGtDymKYibCF936R(eSAgaVztSUeWx3qJciUztSUur5q2k87HEO02hRDmh(GgdYgG4MnX6sfLdzRWVh6HsRutqy9CIEWlJgua9PnaXnBI1LkkhYwHFp0dLwRbLVyxBhG4MnX6sfLdzRWVh6Hs73evurFLQcl0MnHimJokeO8DO1be3SjwxQOCiBf(9qpuAT3kN)AMQcl0MnHimJokeOeAkGyG46xFaxhHAitBWcGJIWJgaFcbeWNxiG3SzpapKaElQdt)nOciUztSUekB18bpjf0yQkSqRNtZr7EpOQeswqXeEF0KzRGq7LAf8RzTkwlNWFuAuQvWVM1QyTCc)rDOqhUuhsPxpBxtzt4QVM1MlHKfumH3hnz2ki0ErDyxOP2xZAvLqYckMW7JMmBfeAVK7J1oQkBchiUztSUKEO0YAJj3SjwpBc5uL3ciuwrce3SjwxspuAzTXKB2eRNnHCQYBbekkLOZqjqCZMyDj9qPL1gtUztSE2eYPkVfqO9IvjNlyd0uvfwOnBcrygDuiq57q1fqCZMyDj9qPL1gtUztSE2eYPkVfqOYPk5CbBGMQQWcTzticZOJcbk1bDbe3SjwxspuAzTXKB2eRNnHCQYBbeQWkcfqFaIbIB2eRlv9IqT3wb659(aXnBI1LQEr6Hs73evurFfG4MnX6svVi9qP1A0UJMQcl0KpuOdp8NCIWh8Kz2RWyGsv96l4xZAvjcFWtMzVcJrv2eEs1sMYHIYpSIkLc)R)xZOx)xZAv)RdpBpeRavh2SP2xZAv2WFWtMxB2ERCuh2SbkvtciUztSUu1lspuAdgM9vude3SjwxQ6fPhkTSvaNSC2taiUztSUu1lspuAdgMnTZWQcl0VM1QSH)GNmV2S9w5OoSzJE9f8RzTk7TvGU6qHoC57Z1IqtEcbuV(df6Wd)jNi8bpzM9kmMAf8RzTQeHp4jZSxHXOouOdx((CTi0KNqabIB2eRlv9I0dL2Rlr7twsPpQuvyHkxnZp8IITc)EYcyjMEI1bIB2eRlv9I0dLwH4U9K51MN9eqFaIB2eRlv9I0dLw5RWoH)KPSjWdiUztSUu1lspuAT3kNSVI6Qcl0tZr7EpO65cPHMCWcMbRn99GJYGIqJoa1GIqtTc(1SwL92kqxv2eoqCZMyDPQxKEO0AJdZFtlNQcl0tZr7EpOQeswqXeEF0KzRGq7LASDnLnHR(AwBUeswqXeEF0KzRGq7f1HDHMAFnRvvcjlOycVpAYSvqO9s2ghQkBchiUztSUu1lspuA7J1oMrQrXSYy9QcluH2Bff28UUOATMnHimJokeO8DO1BT650C0U3dQEmnlAt2E9Ja6JeiUztSUu1lspuAX)6)1maXnBI1LQEr6HsBWWSPDgwvyHEAoA37bvpMMfTjBV(ra9rwl5PnOpkjftmt4p5GH613SjeHz0rHaLVdTYsQ2CTi0KNqa1HNB18sUxu9nrfv0xrDOqhUeiU(1hWB2eRlv9I0dL2eDmvjrguQQsvvyHEAoA37bvpMMfTjBV(ra9rwBAd6JssXeZe(toyiqCZMyDPQxKEO0AVvo)1maXaXnBI1LkwrcvtI5yqHQ8waHkF1LnbwY79ZRnp7jG(uvyH(1Sw1P5yETzkBc8uLnHde3SjwxQyfj9qPLYoX6vfwOuouuET28dROcgnzry4s96)RuwZgpVM8HcD4sDqxufiUztSUuXks6HsBb751FphbIB2eRlvSIKEO0ke3TNmV28SNa6tvHfAZMqeMrhfcuQd6QwYS1lAXOKbLxRJLSqBcgQxVC1m)WlQeTCqt7LmLBPCbo0KuTVM1Q(xhE2EiwbQoSzduQce3SjwxQyfj9qP90CmV2mLnbEvfwOSDnLnHRcgnzry4s1HcD4Y3tvxTVM1QonhZRntztGNQSjCG4MnX6sfRiPhkTbJMSimCzvHf6xZAvNMJ51MPSjWtv2eETK)AwRky0KfHHlvLnHRx)0g0h1P5yETzkBc8sQwYFnRvjnbJk5GHQYMW1RVzticZOJcbkFhADjbe3SjwxQyfj9qPDcbmNOpkvfwONMJ29Eq1Gcu2Rn5e9rP2xZAvi1E1AYjwxPrPwYuouuET28dROcgnzry4s96)RuwZgpVM8HcD4sD4nunjG4MnX6sfRiPhkTAsmhdkibIB2eRlvSIKEO0(n7wYwTJgG4MnX6sfRiPhkTF8K4rLWFaIB2eRlvSIKEO0AINxJm)2PvEeqFaIB2eRlvSIKEO0AJd)MDlaXnBI1LkwrspuABNHY5AtM1gdqCZMyDPIvK0dL2F)KxBEUGrfjqmqC9RpGRJgY(BWcG)rwRjraNot4uHw4xHGaEaEib8gWPyAAWdWzV2GHkG46xFaVztSUujSIqb0hOFt4uj3onvfwOcRiua9rvc50odFpfvbIB2eRlvcRiua9HEO0gmmBnlkRkSq)AwRkyy2AwuQkBchiUztSUujSIqb0h6HsBFS2XmsnkMvgRxvyHk0EROWM31fvR1SjeHz0rHaLVdToG4MnX6sLWkcfqFOhkT24W830YbiUztSUujSIqb0h6HsBWWSPDgcede3SjwxQKduRr7oAQkSqt(qHo8WFYjcFWtMzVcJbkv1RVGFnRvLi8bpzM9kmgvzt4jvlzkhkk)WkQuk8V(FnJE9FnRv9Vo8S9qScuDyZMAjt5qr5hwrLs9yAw0MSKsqfuVEkhkk)WkQuk7TY5VMPwY1dB9IwmQ4W8AZZlm3sg6fSOxpBxtzt4QRlr7twsPpQOouOdxQx)P5ODVhuzpeRi8NCIWlYK0RNYHIYpSIkL66s0(KLu6Jk61)1SwLn8h8K51MT3kh1HnBGs1AjxWVM1QeI72tMxBE2ta9rPrrV(VM1QShIve(tor4fPsJIE9FnRvHuJs7fSKPSd6t0g1HnBskPKaIB2eRlvYHEO0AVTc0Z79bIB2eRlvYHEO0(nrfv0xPQWc9RzTk7HyfH)KVoCLgf96B2eIWm6OqGY3HwhqCZMyDPso0dL2RPjV2S9w5uvyHEOqhE4p5eHp4jZSxHXanvTc(1SwvIWh8Kz2RWyuhk0HlbIB2eRlvYHEO0(yAw0MSKsqfSQWc9qHo8WFYjcFWtMzVcJPwb)AwRkr4dEYm7vymQdf6WLVZA5KNqaPFUweAYtiGaXnBI1Lk5qpuAdgMnTZWQcl0df6Wd)jNi8bpzM9kmMAhk0Hh(tor4dEYm7vymV)1SwLn8h8K51MT3kh1HnBQvWVM1Qse(GNmZEfgJ6qHoC57Z1IqtEcbeiUztSUujh6HslBfWjlN9eaIB2eRlvYHEO0gmm7ROgiUztSUujh6Hs71LO9jlP0hvQkSq)AwRYEiwr4p5eHxKknk1A2eIWm6OqGsOPaIB2eRlvYHEO0EDjAFYsk9rLQcl0VM1Q(xhE2EiwbQoSztTPnOpQhtZI2KLucQG1yRx0IrfhMxBEEH5wYqVGLAFnRvfSGzqPsonJkVd9naXnBI1Lk5qpuAdgMnTZWQcl0VM1QSH)GNmV2S9w5OoSzJE9f8RzTk7TvGU6qHoC57Z1IqtEcbeiUztSUujh6Hsl(x)VMbiUztSUujh6Hs71LO9jlP0hvQkSqtUEM2G(OEmnlAtwsjOcQxF9WwVOfJkomV288cZTKHEbljvl5650C0U3dQShIve(tor4fPE9nBcrygDuiq57qRlPAFnRv9Vo8S9qScuDyZgG4MnX6sLCOhkTcXD7jZRnp7jG(ae3SjwxQKd9qPv(kSt4pzkBc8QkSq)AwR60CmV2mLnbEQYMWRL8P5ODVhu9c7BYRnpVWSTr96LRM5hEr9CRimhUO4zVEI11RxUAMF4fLnqtjV283Ss5ki1R)0C0U3dQShIve(tor4fzTVM1QShIve(tor4fPQSjC96B2eIWm6OqGY3HwxsaXnBI1Lk5qpuAT3kNSVI6Qcl0tZr7EpO65cPHMCWcMbRn99GJYGIqJoa1GIqtTc(1SwL92kqxv2eoqCZMyDPso0dL2(yTJzKAumRmwVQWc90C0U3dQkHKfumH3hnz2ki0EPgBxtzt4QVM1MlHKfumH3hnz2ki0ErDyxOP2xZAvLqYckMW7JMmBfeAVK7J1oQkBchiUztSUujh6HsRnom)nTCQkSqpnhT79GQsizbft49rtMTccTxQX21u2eU6RzT5sizbft49rtMTccTxuh2fAQ91SwvjKSGIj8(OjZwbH2lzBCOQSjCG4MnX6sLCOhkTpMMfTjlPeubRkSq)AwR6FD4z7HyfO6WMnaXnBI1Lk5qpuAT3kN)AgYqgcb]] )


end
