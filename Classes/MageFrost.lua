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

    spec:RegisterPack( "Frost Mage", 20220407, [[dOeKbbqivu6rqvLnjj(ermkIuNIi5vKunlvOUfuvf7IWVirnmKkoMkyzQqEgvvAAuvvxJejBJQk8nvuyCuvfohvvPwhuH5rIu3dk2huvoiuvvlKK0djrmrvuuUivvr2ivvr9rQQO6KQOiRKQYmrQ0nPQkzNqL(juvLAOQOOAPuvr8uKmvOkFLQksJLKYEr5VsmyehwQfRspgvtwOld2mv(SKA0QiNw0QHQQKxdv0Sj1TPk7MYVvA4qPJtvfLLRQNly6kUorTDs47ssJxfvNNKy9ivnFKY(Hm7adpgvShGH7r05OJOJ)PZzio4VpYp8pJAublWOW2CC21aJYApGr5p)Byqe)vxdmkSTk6TJm8yuHv(5aJ60myd4qzLRZ5K8vWxpLdPNSUNCn(3Ur5q6XvMrDLt9CMm2Lrf7by4EeDo6i64F6CgId(7J8d)QumQwEoTpJIk9ucJ6ugJGXUmQie4mk)vxdiI)8VHb5d)J9tnICghJihrNJoc5d5tjNARgc4a5d)broZwtYGiPX1YraruvNgorK0qe)1Qa8aBqe8)zoDrePXUHCY1sRgrYaI0icwDRc8ise4zixtkKp8heXF14eqKW6biIexwFAkp41PfKGiGnFcbePXIvRcImlIC3qarCz9PjGiRPvrWO0zycm8yurW1Y6HHhd3dm8yuG1xnezQYO4FoWNnJ6SiYlBGB)AqeZapXQtRFvk81ZRTOaS(QHiIubrIWv25e8omPvlKXIivqKiCLDobVdtA1Ih860ciIsJihqeA0qe(U64w1exzNReZapXQtRFvk81ZRTO4HoQcIubrUYoNiMbEIvNw)Qu4RNxBXs)82arCRAmQMp5Amk(kBd8bSGwZggUhXWJrbwF1qKPkJQ5tUgJI3ADP5tUwrNHHrPZWuS2dyu8yGnmC9ldpgfy9vdrMQmQMp5AmkER1LMp5AfDgggLodtXApGrbHayCiWggU(NHhJcS(QHitvgf)Zb(SzunFsfqbmWlHaIGpmiIFzuH5t(WW9aJQ5tUgJI3ADP5tUwrNHHrPZWuS2dyu9cSHHRsXWJrbwF1qKPkJI)5aF2mQMpPcOag4LqaruAeXVmQW8jFy4EGr18jxJrXBTU08jxROZWWO0zykw7bmQWWggU(bdpgfy9vdrMQmQMp5AmkER1LMp5AfDgggLodtXApGr5TkapWg2Wggf2h4R3ThgEmCpWWJr18jxJr1pVnOK2aAnWhgfy9vdrMQSHH7rm8yunFY1yuv7b(cObpWMwZOaRVAiYuLnmC9ldpgvZNCngLtdHt8VDdJcS(QHitv2WW1)m8yuG1xnezQYO4FoWNnJQ5tQakGbEjeqe8HbroIr18jxJrD1j903FKnmCvkgEmkW6RgImvzu8ph4ZMr18jvafWaVecicge5aJQ5tUgJY9ByUREydByu9cm8y4EGHhJQ5tUgJY9l9Gv2)YOaRVAiYuLnmCpIHhJcS(QHitvgf)Zb(SzuxzNteHEoD33arCRAicnAiYzrKx2a3(1Gic9CkuC9CA9eG1xnereA0qKRSZjCpa0NwD570eYyreA0qKMpPcOag4LqarWhgeXpyunFY1yuxDsp99hzddx)YWJrbwF1qKPkJI)5aF2mQRSZjIqpNU7BGqglIubrA(KkGcyGxcbebdIOuisferAezAnyJW9aqFA1LVttawF1qerOrdrMwd2iURbf(PuRtRwawF1qerOrdr4RfLZreoLkGpT6cFFqawF1qerOrdrolI8Yg42Vge8vhlUFTrawF1qerKIr18jxJrD1j903FKnmC9pdpgfy9vdrMQmk(Nd8zZOUYoNic9C6UVbczSisfeP5tQakGbEjeqemiI)rKkiI0iY0AWgH7bG(0QlFNMaS(QHiIqJgImTgSrCxdk8tPwNwTaS(QHiIubr4RfLZreoLkGpT6cFFqawF1qerOrdrolI8Yg42Vge8vhlUFTrawF1qerQGiNfrEzdC7xdIGo54SKCqawF1qerKIr18jxJrD1j903FKnmCvkgEmkW6RgImvzu8ph4ZMrDLDore650DFdeYyrKkisZNubuad8siGikngeXVisfe5SiYlBGB)Aqe0jhNLKdcW6RgIisfe5SiYlBGB)AqWxDS4(1gby9vdrePcIWxlkNJiCkvaFA1f((GaS(QHiIubrKgrMwd2iCpa0NwD570eG1xnereA0qKP1GnI7AqHFk160QfG1xnerePyunFY1yuxDsp99hzddx)GHhJcS(QHitvgf)Zb(SzusJip41PLwDPAAd8Hc)uQ1icgeHoicnAiseUYoNOAAd8Hc)uQ1I4w1qePqKkiI0ic2huuQ5rXbbCx7U6brOrdrUYoN4(DAf3da9G4HMpisfe5k7CcxA1WhkRR4(nmIhA(Giyqe6GisXOA(KRXOCA5)vHnmCpdgEmQMp5AmQKdfBv0mkW6RgImvzddx)bdpgvZNCngfF9GPeM99yuG1xnezQYggU(BgEmkW6RgImvzu8ph4ZMrDLDoHlTA4dL1vC)ggXdnFqeA0qKiCLDoH7x6bt8GxNwarWhImFRa0Lj9aeHgne5bVoT0QlvtBGpu4NsTgrQGir4k7CIQPnWhk8tPwlEWRtlGi4drMVva6YKEaJQ5tUgJk5qr3ghydd3d0HHhJcS(QHitvgf)Zb(SzuHvwFtlk4R3TNIheZPNCnby9vdrgvZNCng13XSTPeW2pozdd3dhy4XOA(KRXO8Y)3puwxz23dSHrbwF1qKPkBy4E4igEmQMp5AmQWP0nPvxWUvHNrbwF1qKPkBy4EWVm8yuG1xnezQYO4FoWNnJ6LnWTFniQ)mOvPK8KRbby9vdrePcIm9xdJqdkanIO0yqenOa0isfejcxzNt4(LEWeXTQXOA(KRXOC)gMITkA2WW9G)z4XOaRVAiYuLrX)CGpBg1lBGB)AqeZapXQtRFvk81ZRTOaS(QHiIubr47QJBvtCLDUsmd8eRoT(vPWxpV2IIh6Okisfe5k7CIyg4jwDA9RsHVEETflU8brCRAmQMp5Amkx(q5Q7WWggUhukgEmkW6RgImvzu8ph4ZMr51wlWYhebFiIFPdIubrA(KkGcyGxcbebFyqe)arQGiNfrEzdC7xdIADZZwxCFx7b2eeG1xnezunFY1yu9ZBdkW5y1BixJnmCp4hm8yunFY1yuWDT7Qhgfy9vdrMQSHH7HZGHhJcS(QHitvgf)Zb(SzuVSbU9RbrTU5zRlUVR9aBccW6RgIisferAezAnyJiGvNZKwDj5GaS(QHiIqJgI08jvafWaVecic(WGikfIifIubrMVva6YKEaIO0is9VYwS0liU6KE67pkEWRtlWOA(KRXOsou0TXb2WW9G)GHhJQ5tUgJY9ByUREyuG1xnezQYg2WO4XadpgUhy4XOaRVAiYuLr18jxJrfo1XTkel7FlRRm77b2WO4FoWNnJ6k7CIx2GY6ky3QWlIBvJrzThWOcN64wfIL9VL1vM99aBydd3Jy4XOaRVAiYuLrX)CGpBgf2huuwNRuZJIKRsrbKwarOrdrUBiGivqexwFAkp41PfqeLgr8lDyunFY1yuy3jxJnmC9ldpgvZNCngve650DFdyuG1xnezQYggU(NHhJcS(QHitvgf)Zb(SzunFsfqbmWlHaIO0iIFrKkiI0icFTOCoIqI90AqS416KdcW6RgIicnAisyL130IIQDyaDBXc2FX(jmQiaRVAiIisHivqKRSZjUFNwX9aqpiEO5dIGbrOdJQ5tUgJYl)F)qzDLzFpWg2WWvPy4XOaRVAiYuLrX)CGpBgfFxDCRAIKRsrbKwq8GxNwarWhIC4iePcICLDoXlBqzDfSBv4fXTQXOA(KRXOEzdkRRGDRcpBy46hm8yuG1xnezQYO4FoWNnJ6k7CIx2GY6ky3QWlIBvdrQGisJixzNtKCvkkG0cI4w1qeA0qKP1GnIx2GY6ky3QWlaRVAiIisHivqePrKRSZjc6KJZsYbrCRAicnAicFTOCoIKRsb7VyL1HCnby9vdrePcIinImTgSrWxpykHzFpby9vdreHgnejat5UMCqmj8h5pkhHLJisHi0OHinFsfqbmWlHaIGpmiYriIumQMp5AmQKRsrbKwGnmCpdgEmkW6RgImvzu8ph4ZMr9Yg42Vged4HD)wxQ2pwby9vdrePcICLDobC(Pwom5AczSisferAeb7dkkRZvQ5rrYvPOaslGi0OHi3neqKkiIlRpnLh860ciIsJi(NoiIumQMp5AmQj9Gs1(XYggU(dgEmQMp5Amk5auYb8cmkW6RgImvzddx)ndpgvZNCng1vVBS4KFvyuG1xnezQYggUhOddpgvZNCng1f(a84mTAgfy9vdrMQSHH7Hdm8yunFY1yu6S(0ek4VKJ1EGnmkW6RgImvzdd3dhXWJr18jxJr5YhU6DJmkW6RgImvzdd3d(LHhJQ5tUgJQnoeMV1fER1mkW6RgImvzdd3d(NHhJQ5tUgJ621L1vMp54mWOaRVAiYuLnSHrfggEmCpWWJrbwF1qKPkJI)5aF2mkPrKh860sRUunTb(qHFk1AebdIqheHgnejcxzNtunTb(qHFk1ArCRAiIuisferAeb7dkk18O4GaURDx9Gi0OHixzNtC)oTI7bGEq8qZhePcIinIG9bfLAEuCquRBE26saBItarOrdrW(GIsnpkoiC)gM7QhePcIinICweHVwuohr(qzDL5eu6ahSiefG1xnereA0qe(U64w1eFhZ2MsaB)4u8GxNwarOrdrEzdC7xdc3da9PvxQMwmiaRVAiIisHi0OHiyFqrPMhfheFhZ2MsaB)4erOrdrUYoNWLwn8HY6kUFdJ4HMpicgeHoisferAejcxzNt4L)VFOSUYSVhyJqglIqJgICLDoH7bG(0QlvtlgeYyreA0qKRSZjGZX2weIfS7a2KTw8qZherkerkerkgvZNCngLtl)VkSHH7rm8yunFY1yuUFPhSY(xgfy9vdrMQSHHRFz4XOaRVAiYuLrX)CGpBg1v25eUha6tRU8DAczSicnAisZNubuad8siGi4ddICeJQ5tUgJ6Qt6PV)iBy46FgEmkW6RgImvzu8ph4ZMr9GxNwA1LQPnWhk8tPwJiyqKdisfejcxzNtunTb(qHFk1AXdEDAbgvZNCng13QuwxX9ByyddxLIHhJcS(QHitvgf)Zb(Szup41PLwDPAAd8Hc)uQ1isfejcxzNtunTb(qHFk1AXdEDAbebFicVdtzsparuhrMVva6YKEaJQ5tUgJQw38S1La2eNaBy46hm8yuG1xnezQYO4FoWNnJ6bVoT0QlvtBGpu4NsTgrQGip41PLwDPAAd8Hc)uQ1ic(qKRSZjCPvdFOSUI73WiEO5dIubrIWv25evtBGpu4NsTw8GxNwarWhImFRa0Lj9agvZNCngvYHIUnoWggUNbdpgvZNCngfF9GPeM99yuG1xnezQYggU(dgEmQMp5AmQKdfBv0mkW6RgImvzddx)ndpgfy9vdrMQmk(Nd8zZOUYoNW9aqFA1LQPfdczSisfeP5tQakGbEjeqemiYbgvZNCng13XSTPeW2pozdd3d0HHhJcS(QHitvgf)Zb(SzuxzNtC)oTI7bGEq8qZhePcImTgSruRBE26saBItqawF1qerQGi81IY5iYhkRRmNGsh4GfHOaS(QHiIubrUYoNi5jxdbryAoore8Hbr8pJQ5tUgJ67y22ucy7hNSHH7Hdm8yuG1xnezQYO4FoWNnJ6k7CcxA1WhkRR4(nmIhA(Gi0OHir4k7Cc3V0dM4bVoTaIGpez(wbOlt6bmQMp5AmQKdfDBCGnmCpCedpgvZNCngfCx7U6HrbwF1qKPkBy4EWVm8yuG1xnezQYO4FoWNnJsAe5SiY0AWgrTU5zRlbSjobby9vdreHgne5SicFTOCoI8HY6kZjO0boyrikaRVAiIisHivqePrKZIiVSbU9RbH7bG(0QlvtlgeG1xnereA0qKMpPcOag4LqarWhge5ierkePcICLDoX970kUha6bXdnFyunFY1yuFhZ2MsaB)4KnmCp4FgEmQMp5AmkV8)9dL1vM99aByuG1xnezQYggUhukgEmkW6RgImvzu8ph4ZMrDLDoXlBqzDfSBv4fXTQHivqePrKx2a3(1G4e0)uwxzobfxdcW6RgIicnAisyL130II6FvaL0uK173tUMaS(QHiIqJgIewz9nTOWLGowwx5Q3qy9ccW6RgIicnAiYlBGB)Aq4EaOpT6s10Ibby9vdrePcICLDoH7bG(0QlvtlgeXTQHi0OHinFsfqbmWlHaIGpmiYriIumQMp5AmQWP0nPvxWUvHNnmCp4hm8yuG1xnezQYO4FoWNnJ6LnWTFniQ)mOvPK8KRbby9vdrePcIm9xdJqdkanIO0yqenOa0isfejcxzNt4(LEWeXTQXOA(KRXOC)gMITkA2WW9WzWWJrbwF1qKPkJI)5aF2mQx2a3(1GiMbEIvNw)Qu4RNxBrby9vdrePcIW3vh3QM4k7CLyg4jwDA9RsHVEETffp0rvqKkiYv25eXmWtS606xLcF98Alw6N3giIBvJr18jxJr1pVnOaNJvVHCn2WW9G)GHhJcS(QHitvgf)Zb(SzuVSbU9Rbrmd8eRoT(vPWxpV2IcW6RgIisfeHVRoUvnXv25kXmWtS606xLcF98AlkEOJQGivqKRSZjIzGNy1P1Vkf(651wS4YheXTQXOA(KRXOC5dLRUddBy4EWFZWJrbwF1qKPkJI)5aF2mQRSZjUFNwX9aqpiEO5dJQ5tUgJQw38S1La2eNaBy4EeDy4XOA(KRXOC)gM7Qhgfy9vdrMQSHnmkVvb4b2WWJH7bgEmkW6RgImvzu8ph4ZMrDLDorYHItVqqe3QgJQ5tUgJk5qXPxiWggUhXWJrbwF1qKPkJI)5aF2mkV2Abw(Gi4dr8lDqKkisZNubuad8siGi4ddICeJQ5tUgJQFEBqbohREd5ASHHRFz4XOA(KRXOC5dLRUddJcS(QHitv2WW1)m8yunFY1yujhk624aJcS(QHitv2Wg2WOuaFixJH7r05OJOJ)PJFzuv73sRoWO8tX)(j4EMW1phhicIG3jarspS7piIBFerseCTSEKGip4NjNperKW6bislpRxpqer4NARgccKp6MgGihWbIOK1ua)arerYlBGB)AqOMeezwerYlBGB)AqOMaS(QHOeer6dNlLa5d5Zpf)7NG7zcx)CCGiicENaej9WU)GiU9rej9csqKh8ZKZhIisy9aePLN1RhiIi8tTvdbbYhDtdqKJWbIOK1ua)arerYlBGB)AqOMeezwerYlBGB)AqOMaS(QHOeer6dNlLa5JUPbiIFXbIOK1ua)arerY0AWgHAsqKzrejtRbBeQjaRVAikbrK(OZLsG8r30aeXV4aruYAkGFGiIi5LnWTFniutcImlIi5LnWTFniutawF1qucIi9HZLsG8r30aeXV4aruYAkGFGiIiHVwuohHAsqKzrej81IY5iutawF1qucIi9HZLsG8r30aeX)4aruYAkGFGiIizAnyJqnjiYSiIKP1Gnc1eG1xneLGisF05sjq(OBAaI4FCGikznfWpqerK8Yg42VgeQjbrMfrK8Yg42VgeQjaRVAikbrK(OZLsG8r30aeX)4aruYAkGFGiIiHVwuohHAsqKzrej81IY5iutawF1qucIi9HZLsG8r30aerPWbIOK1ua)arerY0AWgHAsqKzrejtRbBeQjaRVAikbrK(OZLsG8r30aerPWbIOK1ua)arerYlBGB)AqOMeezwerYlBGB)AqOMaS(QHOeer6JoxkbYhDtdqeLchiIswtb8derej81IY5iutcImlIiHVwuohHAcW6RgIsqePpCUucKp6MgGihOdoqeLSMc4hiIiscRS(MwuOMeezwersyL130Ic1eG1xneLGi9Gi(t4VPlIi9HZLsG8r30ae5GFXbIOK1ua)arerYlBGB)AqOMeezwerYlBGB)AqOMaS(QHOeer6dNlLa5JUPbiYb)JderjRPa(bIiIKx2a3(1GqnjiYSiIKx2a3(1Gqnby9vdrjiI0hoxkbYhDtdqKdkfoqeLSMc4hiIisEzdC7xdc1KGiZIisEzdC7xdc1eG1xneLGi9Gi(t4VPlIi9HZLsG8r30ae5WzGderjRPa(bIiIKP1Gnc1KGiZIisMwd2iutawF1qucIi9HZLsG8r30ae5WzGderjRPa(bIiIKx2a3(1GqnjiYSiIKx2a3(1Gqnby9vdrjiI0hoxkbYhYNFk(3pb3ZeU(54arqe8obis6HD)brC7Jis4XGee5b)m58HiIewparA5z96bIic)uB1qqG8r30aeX)4aruYAkGFGiIiHVwuohHAsqKzrej81IY5iutawF1qucIi9HZLsG8r30aeX)4aruYAkGFGiIijSY6BArHAsqKzrejHvwFtlkutawF1qucIi9HZLsG8r30aeXpWbIOK1ua)arerY0AWgHAsqKzrejtRbBeQjaRVAikbrK(OZLsG8r30aeXpWbIOK1ua)arercFTOCoc1KGiZIis4RfLZrOMaS(QHOeer6dNlLa5JUPbiYzGderjRPa(bIiIKx2a3(1GqnjiYSiIKx2a3(1Gqnby9vdrjiI0hoxkbYhYNFk(3pb3ZeU(54arqe8obis6HD)brC7JiscJee5b)m58HiIewparA5z96bIic)uB1qqG8r30ae5aoqeLSMc4hiIisEzdC7xdc1KGiZIisEzdC7xdc1eG1xneLGisF4CPeiF0nnaroGderjRPa(bIiIe(Ar5CeQjbrMfrKWxlkNJqnby9vdrjiI0hoxkbYhDtdqKd0bhiIswtb8derejtRbBeQjbrMfrKmTgSrOMaS(QHOeer6dNlLa5JUPbiYb6GderjRPa(bIiIe(Ar5CeQjbrMfrKWxlkNJqnby9vdrjiI0hoxkbYhDtdqKd(fhiIswtb8derejtRbBeQjbrMfrKmTgSrOMaS(QHOeer6dNlLa5JUPbiYb)IderjRPa(bIiIKx2a3(1GqnjiYSiIKx2a3(1Gqnby9vdrjiI0hoxkbYhDtdqKd(fhiIswtb8derej81IY5iutcImlIiHVwuohHAcW6RgIsqePpCUucKp6MgGihukCGikznfWpqerK8Yg42VgeQjbrMfrK8Yg42VgeQjaRVAikbrK(OZLsG8r30ae5GsHderjRPa(bIiIKWkRVPffQjbrMfrKewz9nTOqnby9vdrjiI0hDUucKp6MgGih8dCGikznfWpqerK8Yg42VgeQjbrMfrK8Yg42VgeQjaRVAikbrK(W5sjq(OBAaIC4mWbIOK1ua)arerYlBGB)AqOMeezwerYlBGB)AqOMaS(QHOeer6dNlLa5JUPbiYb)boqeLSMc4hiIisEzdC7xdc1KGiZIisEzdC7xdc1eG1xneLGisF4CPeiFiFNjpS7pqer8deP5tUgIOZWeeiFmQawGZW1p8pJc7VUudmk8d)qe)vxdiI)8VHb5d)Wpeb)J9tnICghJihrNJoc5d5d)WperjNARgc4a5d)Wpeb)broZwtYGiPX1YraruvNgorK0qe)1Qa8aBqe8)zoDrePXUHCY1sRgrYaI0icwDRc8ise4zixtkKp8d)qe8heXF14eqKW6biIexwFAkp41PfKGiGnFcbePXIvRcImlIC3qarCz9PjGiRPvrG8H8HF4hI4pDoWLhiIixWTpGi8172dICH60cceb)Z5a2jGi2A4pN63ZjRrKMp5AbeznTkcKVMp5Abb2h4R3Th1XOC)82GsAdO1aFq(A(KRfeyFGVE3EuhJYbzpV1kv7b(cObpWMwJ818jxliW(aF9U9OogLDAiCI)TBq(A(KRfeyFGVE3EuhJYxDsp99hpoDyA(KkGcyGxcb8H5iKVMp5Abb2h4R3Th1XOS73WCx9CC6W08jvafWaVecyoG8H8HF4hI4pDoWLhiIiGc4vbrM0dqK5eGinF2hrYaI0k6u3xniq(A(KRfWWxzBGpGf06JthMZ(Yg42VgeXmWtS606xLcF98AlwjcxzNtW7WKwTqgBLiCLDobVdtA1Ih860ck9bA047QJBvtCLDUsmd8eRoT(vPWxpV2IIh6OkvUYoNiMbEIvNw)Qu4RNxBXs)82arCRAiFnFY1cQJrzER1LMp5AfDgMJT2dWWJbKVMp5Ab1XOmV16sZNCTIodZXw7byGqamoeq(A(KRfuhJY8wRlnFY1k6mmhBThGPx44W8jFWC440HP5tQakGbEjeWhg)I818jxlOogL5TwxA(KRv0zyo2ApatyoomFYhmhooDyA(KkGcyGxcbL2ViFnFY1cQJrzER1LMp5AfDgMJT2dW4TkapWgKpKVMp5AbrVag3V0dwz)lYxZNCTGOxqDmkF1j903F840H5k7CIi0ZP7(giIBvJgTZ(Yg42VgerONtHIRNtRhnAxzNt4EaOpT6Y3PjKXsJwZNubuad8siGpm(bYxZNCTGOxqDmkF1j903F840H5k7CIi0ZP7(giKXwP5tQakGbEjeWOuvKEAnyJW9aqFA1LVtJgTP1GnI7AqHFk160QPrJVwuohr4uQa(0Ql89bA0o7lBGB)AqWxDS4(1gPq(A(KRfe9cQJr5RoPN((JhNomxzNteHEoD33aHm2knFsfqbmWlHag)xr6P1Gnc3da9Pvx(onA0Mwd2iURbf(PuRtRUcFTOCoIWPub8Pvx47d0OD2x2a3(1GGV6yX9Rnvo7lBGB)Aqe0jhNLKdsH818jxli6fuhJYxDsp99hpoDyUYoNic9C6UVbczSvA(KkGcyGxcbLgJFRC2x2a3(1GiOtooljhQC2x2a3(1GGV6yX9Rnv4RfLZreoLkGpT6cFFOI0tRbBeUha6tRU8DA0OnTgSrCxdk8tPwNwTuiFnFY1cIEb1XOStl)VkhNoms)GxNwA1LQPnWhk8tPwJHo0OfHRSZjQM2aFOWpLATiUvnPQin2huuQ5rXbbCx7U6HgTRSZjUFNwX9aqpiEO5tLRSZjCPvdFOSUI73WiEO5dg6ifYxZNCTGOxqDmkNCOyRIg5R5tUwq0lOogL5RhmLWSVhYxZNCTGOxqDmkNCOOBJdhNomxzNt4sRg(qzDf3VHr8qZhA0IWv25eUFPhmXdEDAb8nFRa0Lj9aA0EWRtlT6s10g4df(PuRReHRSZjQM2aFOWpLAT4bVoTa(MVva6YKEaYxZNCTGOxqDmk)DmBBkbS9JZJthMWkRVPff8172tXdI50tUgYxZNCTGOxqDmk7L)VFOSUYSVhydYxZNCTGOxqDmkhoLUjT6c2Tk8iFnFY1cIEb1XOS73WuSvrFC6W8Yg42Vge1Fg0QusEY1qLP)AyeAqbOvAmAqbOReHRSZjC)spyI4w1q(A(KRfe9cQJrzx(q5Q7WCC6W8Yg42VgeXmWtS606xLcF98AlwHVRoUvnXv25kXmWtS606xLcF98AlkEOJQu5k7CIyg4jwDA9RsHVEETflU8brCRAiFnFY1cIEb1XOC)82GcCow9gY1ooDy8ARfy5d(8lDQ08jvafWaVec4dJFu5SVSbU9RbrTU5zRlUVR9aBciFnFY1cIEb1XOmCx7U6b5R5tUwq0lOogLtou0TXHJthMx2a3(1GOw38S1f331EGnHkspTgSreWQZzsRUKCGgTMpPcOag4LqaFyukPQmFRa0Lj9aLU(xzlw6fexDsp99hfp41Pfq(Wp8drA(KRfe9cQJr5QDohhaog6ioCC6W8Yg42Vge16MNTU4(U2dSjuzAnyJiGvNZKwDj5aYxZNCTGOxqDmk7(nm3vpiFiFnFY1ccEmGroaLCaVJT2dWeo1XTkel7FlRRm77b2CC6WCLDoXlBqzDfSBv4fXTQH818jxli4XG6yug7o5AhNomyFqrzDUsnpksUkffqAbA0UBiuXL1NMYdEDAbL2V0b5R5tUwqWJb1XOCe650DFdq(A(KRfe8yqDmk7L)VFOSUYSVhyZXPdtZNubuad8siO0(TI081IY5icj2tRbXIxRtoqJwyL130IIQDyaDBXc2FX(jmQivLRSZjUFNwX9aqpiEO5dg6G818jxli4XG6yu(LnOSUc2Tk8hNom8D1XTQjsUkffqAbXdEDAb8D4OkxzNt8Yguwxb7wfErCRAiFnFY1ccEmOogLtUkffqAHJthMRSZjEzdkRRGDRcViUvTksFLDorYvPOasliIBvJgTP1GnIx2GY6ky3QWlvfPVYoNiOtooljheXTQrJgFTOCoIKRsb7VyL1HCTkspTgSrWxpykHzFpA0cWuURjhetc)r(JYry5srJwZNubuad8siGpmhjfYxZNCTGGhdQJr5j9Gs1(XEC6W8Yg42Vged4HD)wxQ2p2kxzNtaNFQLdtUMqgBfPX(GIY6CLAEuKCvkkG0c0OD3qOIlRpnLh860ckT)PJuiFnFY1ccEmOogLLdqjhWlG818jxli4XG6yu(Q3nwCYVkiFnFY1ccEmOogLVWhGhNPvJ818jxli4XG6yuwN1NMqb)LCS2dSb5R5tUwqWJb1XOSlF4Q3nI818jxli4XG6yuUnoeMV1fER1iFnFY1ccEmOogLVDDzDL5toodiFiF4h(HiNzzOVAiIixG3YbaruvNgovM6u65bpIKbePreS6wf4re(Pn5Ga5d)WpeP5tUwq4TkapWgmxDA4S0MkhNomERcWdSreZW0ghW3b6G818jxli8wfGhyJ6yuo5qXPxiCC6WCLDorYHItVqqe3QgYxZNCTGWBvaEGnQJr5(5Tbf4CS6nKRDC6W41wlWYh85x6uP5tQakGbEjeWhMJq(A(KRfeERcWdSrDmk7YhkxDhgKVMp5AbH3Qa8aBuhJYjhk624aYhYxZNCTGimyCA5)v540Hr6h860sRUunTb(qHFk1Am0HgTiCLDor10g4df(PuRfXTQjvfPX(GIsnpkoiG7A3vp0ODLDoX970kUha6bXdnFQin2huuQ5rXbrTU5zRlbSjobA0W(GIsnpkoiC)gM7QNksFw(Ar5Ce5dL1vMtqPdCWIqKgn(U64w1eFhZ2MsaB)4u8GxNwGgTx2a3(1GW9aqFA1LQPfdsrJg2huuQ5rXbX3XSTPeW2poPr7k7CcxA1WhkRR4(nmIhA(GHovKocxzNt4L)VFOSUYSVhyJqglnAxzNt4EaOpT6s10IbHmwA0UYoNaohBBriwWUdyt2AXdnFKskPq(A(KRfeHrDmk7(LEWk7Fr(A(KRfeHrDmkF1j903F840H5k7Cc3da9Pvx(onHmwA0A(KkGcyGxcb8H5iKVMp5AbryuhJYFRszDf3VH540H5bVoT0QlvtBGpu4NsTgZHkr4k7CIQPnWhk8tPwlEWRtlG818jxlicJ6yuUw38S1La2eNWXPdZdEDAPvxQM2aFOWpLADLiCLDor10g4df(PuRfp41PfWhVdtzspq95BfGUmPhG818jxlicJ6yuo5qr3ghooDyEWRtlT6s10g4df(PuRR8GxNwA1LQPnWhk8tPwJVRSZjCPvdFOSUI73WiEO5tLiCLDor10g4df(PuRfp41PfW38TcqxM0dq(A(KRfeHrDmkZxpykHzFpKVMp5AbryuhJYjhk2QOr(A(KRfeHrDmk)DmBBkbS9JZJthMRSZjCpa0NwDPAAXGqgBLMpPcOag4LqaZbKVMp5AbryuhJYFhZ2MsaB)4840H5k7CI73PvCpa0dIhA(uzAnyJOw38S1La2eNqf(Ar5Ce5dL1vMtqPdCWIqSYv25ejp5AiictZXj(W4FKVMp5AbryuhJYjhk624WXPdZv25eU0QHpuwxX9Byep08HgTiCLDoH7x6bt8GxNwaFZ3kaDzspa5R5tUwqeg1XOmCx7U6b5R5tUwqeg1XO83XSTPeW2popoDyK(StRbBe16MNTUeWM4eOr7S81IY5iYhkRRmNGsh4GfHOuvK(SVSbU9RbH7bG(0QlvtlgOrR5tQakGbEjeWhMJKQYv25e3VtR4EaOhep08b5R5tUwqeg1XOSx()(HY6kZ(EGniFnFY1cIWOogLdNs3KwDb7wf(JthMRSZjEzdkRRGDRcViUvTks)Yg42VgeNG(NY6kZjO4AGgTWkRVPff1)QakPPiR3VNCnA0cRS(Mwu4sqhlRRC1BiSEbA0EzdC7xdc3da9PvxQMwmu5k7Cc3da9PvxQMwmiIBvJgTMpPcOag4LqaFyoskKVMp5AbryuhJYUFdtXwf9XPdZlBGB)Aqu)zqRsj5jxdvM(RHrObfGwPXObfGUseUYoNW9l9GjIBvd5R5tUwqeg1XOC)82GcCow9gY1ooDyEzdC7xdIyg4jwDA9RsHVEETfRW3vh3QM4k7CLyg4jwDA9RsHVEETffp0rvQCLDormd8eRoT(vPWxpV2IL(5TbI4w1q(A(KRfeHrDmk7YhkxDhMJthMx2a3(1GiMbEIvNw)Qu4RNxBXk8D1XTQjUYoxjMbEIvNw)Qu4RNxBrXdDuLkxzNteZapXQtRFvk81ZRTyXLpiIBvd5R5tUwqeg1XOCTU5zRlbSjoHJthMRSZjUFNwX9aqpiEO5dYxZNCTGimQJrz3VH5U6HnSHXa]] )


end
