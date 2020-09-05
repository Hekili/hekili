-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindUnitBuffByID = ns.FindUnitBuffByID


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
            duration = function () return talent.thermal_void.enabled and 30 or 20 end,
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
            duration = 3600,
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
        time_warp = {
            id = 80353,
            duration = 40,
            type = "Magic",
            max_stack = 1,
        },
        winters_chill = {
            id = 228358,
            duration = 1,
            type = "Magic",
            max_stack = 1,
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
    } )


    spec:RegisterStateExpr( "fingers_of_frost_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "fingers_of_frost", function( active )
        fingers_of_frost_active = active
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

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            if spellID == 44614 then
                frost_info.real_brain_freeze = FindUnitBuffByID( "player", 190446 ) ~= nil
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return frost_info.virtual_brain_freeze
    end )


    spec:RegisterStateTable( "rotation", setmetatable( {},
    {
        __index = function( t, k )
            if k == "standard" and state.settings.rotation == "standard" then return true
            elseif k == "no_ice_lance" and state.settings.rotation == "no_ice_lance" then return true
            elseif k == "frozen_orb" and state.settings.rotation == "frozen_orb" then return true end
        
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


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        frost_info.last_target_virtual = frost_info.last_target_actual
        frost_info.virtual_brain_freeze = frost_info.real_brain_freeze

        incanters_flow.reset()
    end )


    spec:RegisterTotem( "rune_of_power", 609815 )

    -- Abilities
    spec:RegisterAbilities( {
        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

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
            charges = function () return talent.shimmer.enabled and 2 or 1 end,
            cooldown = function () return talent.shimmer.enabled and 20 or 15 end,
            recharge = function () return talent.shimmer.enabled and 20 or 15 end,
            gcd = "off",

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
            cooldown = 300,
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
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

            handler = function ()
                if buff.brain_freeze.up then
                    applyDebuff( "target", "winters_chill" )
                    removeBuff( "brain_freeze" )
                    frost_info.virtual_brain_freeze = true
                else
                    frost_info.virtual_brain_freeze = false
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )
            end,
        },


        focus_magic = {
            id = 321358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
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
            end,
        },


        frostbolt = {
            id = 116,
            cast = 2,
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

            handler = function ()
                addStack( "fingers_of_frost", nil, 1 )
                if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
                applyBuff( "frozen_orb" )
                applyDebuff( "target", "frozen_orb_snare" )
            end,
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
            end,
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
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
            end,
        },


        invisibility = {
            id = 66,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,

            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",

            handler = function ()
                applyBuff( "mirror_image", nil, 3 )
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

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

            channeled = true,

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

        potion = "potion_of_focused_resolve",

        package = "Frost Mage",
    } )


    spec:RegisterSetting( "rotation", "standard", {
        name = "Preferred Priority",
        desc = "This sets the |cFFFFD100rotation.X|r value, selecting between one of three integrated SimC builds.",
        type = "select",
        width = 1.5,
        values = {
            standard = "Standard",
            no_ice_lance = "No Ice Lance",
            frozen_orb = "Frozen Orb"
        }
    } )

    
    spec:RegisterPack( "Frost Mage", 20200903, [[dSKXKbqiuu6rajTjGQpPKOgLssoLssTkuuP4vesZcf6wOOk7sOFrigMschdfSmcv9msLAAeQ4Aaj2gkQ4BKkjJdfvY5ivIwhHkP5bKQ7rq7JqXbjujwikYdrrrMiqkLlIIQAJek9rsLWirrLsNeifRuj1mjvs1nrrLQDIs1pbsjdfff1svsKNcyQaLRcKs1xjuP2ls)LKbRQdt1IvXJrmzv6YqBwWNvQgnPQtlz1KkP8AsfZMOBRe7w0VLA4OKLd65OA6uUoPSDG47ey8OOW5rPSELsZxPy)kMYafmkW1nKYU4xH4xXk0LRq3rXZad6kXZafWyJfsby5eD8DKcK(csbelS528m39DKcWYzt2(LcgfG3Aqcsb0BglU4QiISxMETtK0lIWRfnPBvNeOhmr41crekWrRKgOjPhkW1nKYU4xH4xXk0LRq3rXZad6kXtbCntFdPaa1cZefqFDVyspuGlYjuaqDEXcBUnpZDFhN1G68aildxoiCEDZ48IFfIFfZ6znOopZKEp3rU46SguNN5npODoo)kB1cQSwDlCLNVsUH(D(om)kBoChTOvlOYA1TWvE(qdNx6CBEos68opZeOT514(ogN1G68mV5xj82ZZcwnSm2Mp0qD4ZhA48W2CR6mYnpVo8ksa2BXu1WJizRkcQKEsWifqwCJtbJcWRCxIuWOSZafmkaM(rIxktuacSmewofG0T82cYyrqv2G4ri6x2Mh85V4rleIcQ0qixr0xszuJffWjw1jfOiOkBqCQrzx8uWOay6hjEPmrbiWYqy5uayBUvDg5MNxhEPaCdweJYoduaNyvNuaIlLkNyvNkzXnkGS4Mk9fKcWRCxIkU551HxQrzx3uWOay6hjEPmrbiWYqy5uayBUvDgZwveuj9KGuaUblIrzNbkGtSQtkaXLsLtSQtLS4gfqwCtL(csb4vUlrv2kPNeKAu2fhkyuam9JeVuMOaeyziSCkaSn3QoJbyVftvdpuaUblIrzNbkGtSQtkaXLsLtSQtLS4gfqwCtL(csb4vUlrvdpuJYoOqbJc4eR6KcueuLniofat)iXlLjQrzN5qbJcGPFK4LYefWjw1jfWQlYTgUOi9fzguacSmewof4OfcXIWMceSsE82cY5bF(JwieHAjQ6GIvlaHXBliPaPVGuaRUi3A4II0xKzqnk76kkyuam9JeVuMOaoXQoPae2iY2GDwe1r6CJcqGLHWYPahTqiwe2uGGvYJ3wqop4ZF0cHiulrvhuSAbimEBbjfadbKyQ0xqkaHnISnyNfrDKo3OgLDMlkyuaNyvNuGaS52PLgfat)iXlLjQrzxxsbJcGPFK4LYefWjw1jfG4sPYjw1PswCJcilUPsFbPalni4cMg1OSZWkOGrbCIvDsbkcQKEsqkaM(rIxktuJAuaKZXKGCkyu2zGcgfat)iXlLjkabwgclNcaBZTQZya2BXu1WdfGBWIyu2zGc4eR6KcqCPu5eR6ujlUrbKf3uPVGuaKZXKGCvdpuJYU4PGrbW0ps8szIcqGLHWYPam78W2CR6mgG9wmvn8qb4gSigLDgOaoXQoPaexkvoXQovYIBuazXnv6lifa5CmjixDXGRjnQrnkaVYDjQ4MNxhEPGrzNbkyuam9JeVuMOaeyziSCkG5smTiE680slIPFK4DEWNNfebrTtUrgI4PZtlT5bF(vnpZoV5smT4U0jLlvCwLoyet)iX78B2m)rleIfPisKh5Mt0zEqFEXz(nBM)OfcXd0RufGiUfJq0j28RMc4eR6KceKAqiBuJYU4PGrbW0ps8szIcqGLHWYPaMlX0I7sNuUuXzv6Grm9JeVZd(8SGiiQDYnYqCx6KYLkoRshCEWN)OfcXd0RufGiUfJq0jgfWjw1jfii1Gq2OgLDDtbJcGPFK4LYefGaldHLtbybrqu7KBKHya2C70sBEWN)OfcXd0RufGiUfJq0j28Gp)QMNzN3CjMwCx6KYLkoRshmIPFK4D(nBM)OfcXIuejYJCZj6mpOpV4m)QPaoXQoPabPgeYg1OSlouWOay6hjEPmrbCIvDsbiUuQCIvDQKf3OaYIBQ0xqkaY5ysqo1OSdkuWOaoXQoPabyVftvdpuam9JeVuMOgLDMdfmkaM(rIxktuacSmewofWjwbcQWexkKpVyMx8ZVzZ8oXkqqfM4sH85fZ8mmp4ZtCUPSAbNx48RyEWN)OfcXqL7iKR6GkaBUfHOtS5b95fpfWjw1jf4iRTBD4LAu21vuWOay6hjEPmrbiWYqy5uGJwiedvUJqUQdQaS5weIoXOaoXQoPafbvspji1OSZCrbJc4eR6Kcq6f0uCRHluam9JeVuMOgLDDjfmkGtSQtkaE680sJcGPFK4LYe1OSZWkOGrbW0ps8szIcqGLHWYPam78oXQoJbyVftvdpXkvbzTR3Mh853HTwEvEJXaS3IPQHNiex8k5ZlC(vqbCIvDsbGoBQoOcWMBuJYodmqbJcGPFK4LYefGaldHLtbio3uwTGZlC(vm)MnZ7eRabvyIlfYNxmZZafWjw1jf4iRTBD4LAu2zq8uWOay6hjEPmrbiWYqy5uGJwiepqVsvaI4wmcrNyZVzZ8SGiiQDYnYqepDEAPn)MnZ7eRabvyIlfYNxmZZW8GpV5smTiNLSmRYDvrWiM(rIxkGtSQtkWU0jLlvCwLoi1OgfWCjMMc2SOGrzNbkyuam9JeVuMOaeyziSCkWrleIqTevDqXQfGW4TfKZd(8MlX0I7sNuUuXzv6Grm9JeVZd(8hTqiwKIirEKBorN5fopOmp4ZVQ5pAHq8a9kvbiIBXieDIn)MnZBUetlINopT0Iy6hjENh85jDlVTGmINopT0IqCXRKppOppX5MYQfC(vtbCIvDsbGAjQ6GIvlaHuJYU4PGrbW0ps8szIcqGLHWYPahTqic1su1bfRwacJ3wqop4ZZSZBUetlUlDs5sfNvPdgX0ps8op4ZVQ5nxIPfXtNNwArm9JeVZd(8KUL3wqgXtNNwAriU4vYNh0NN4Ctz1co)MnZBUetls6f0uCRHlrm9JeVZd(8KUL3wqgj9cAkU1WLiex8k5Zd6ZtCUPSAbNFZM5nxIPfHoBQoOcWMBrm9JeVZd(8KUL3wqgHoBQoOcWMBriU4vYNh0NN4Ctz1co)MnZt07WDKRcqNyvNUCEXmpdrD58RMc4eR6Kca1su1bfRwacPg1Oa8k3LOQHhkyu2zGcgfat)iXlLjkGtSQtkaXLsLtSQtLS4gfqwCtL(csbqohtcYPgLDXtbJc4eR6KceG9wmvn8qbW0ps8szIAu21nfmkaM(rIxktuacSmewofGfebrTtUrgI4PZtlT5bF(JwiepqVsvaI4wmcrNyuaNyvNuGGudczJAu2fhkyuam9JeVuMOaeyziSCkGtSceuHjUuiFEXmV4NFZM5DIvGGkmXLc5ZlM5zyEWNN4Ctz1coVW5xbfWjw1jf4iRTBD4LAu2bfkyuam9JeVuMOaeyziSCkWrleIHk3rix1bva2ClcrNyZd(8KUL3wqgdWElMQgEIqCXRKpVyMhuMFZM5pAHqmu5oc5QoOcWMBri6eBEHZlEkGtSQtkqrqL0tcsnk7mhkyuam9JeVuMOaeyziSCkaX5MYQfCEHZVckGtSQtkWrwB36Wl1OSRROGrbW0ps8szIcqGLHWYPaSGiiQDYnYqepDEAPrbCIvDsbcsniKnQrzN5Icgfat)iXlLjkabwgclNcC0cH4b6vQcqe3Iri6eBEWNFvZZcIGO2j3idXaS52PL28B2m)fpAHqKLt0bVQIGriU4vYNxmZJmdKOzOYQfCErN3jw1zSiOs6jbJg0bbLkRwW5xnfWjw1jfii1Gq2OgLDDjfmkGtSQtkaPxqtXTgUqbW0ps8szIAu2zyfuWOaoXQoPa4PZtlnkaM(rIxktuJYodmqbJcGPFK4LYefWjw1jfa6SP6GkaBUrbQ0qiuJLPQaf4OfcXqL7iKR6GkaBUfHOtmHINcuPHqOgltvll4TCdPamqbiWYqy5uGlE0cHilNOdEvfbJASOgLDgepfmkGtSQtkWrwB36Wlfat)iXlLjQrnkaY5ysqU6IbxtAuWOSZafmkaM(rIxktuacSmewof4OfcrOwIQoOy1cqy82cY53SzENyfiOctCPq(8IzEDtbCIvDsbcnrJJxLVfHLHQd6luJYU4PGrbW0ps8szIcqGLHWYPaoXkqqfM4sH85b95bL5bF(vn)rleIfPisKh5Mt0zEqx48mm)MnZZSZBUetlUlDs5sfNvPdgX0ps8o)QNh85jDlVTGmgG9wmvn8eH4IxjFEXmpdRyEWNFvZZSZdBZTQZi3886W78B2mpZoVtSQZya2BXu1WtSsvqw76T5bF(DyRLxL3yma7TyQA4jcXfVs(8cNFfZVAkGtSQtkWcU0q2uDqj1i1vDHOVWPgLDDtbJcGPFK4LYefGaldHLtbw18MlX0I7sNuUuXzv6Grm9JeVZd(8hTqiwKIirEKBorN5fopOmp4ZVQ5pAHq8a9kvbiIBXieDIn)MnZZcIGO2j3idr805PL28RE(vp)MnZVQ5x18oXkqqfM4sH85fZ86E(nBMNzN3CjMwCx6KYLkoRshmIPFK4D(vpp4ZVQ5zbrqu7KBKHya2BXu1WZ8B2m)oS1YRYBmgG9wmvn8eH4IxjFEXmpOm)QNF1uaNyvNuGJS7RQdktpQWexyJAu2fhkyuam9JeVuMOaeyziSCkWrleIqTevDqXQfGW4TfKZVzZ8oXkqqfM4sH85fZ86Mc4eR6KcWsdwb2QCxDKo3OgLDqHcgfat)iXlLjkabwgclNcC0cHiulrvhuSAbimEBb58B2mVtSceuHjUuiFEXmVUPaoXQoPaWIfljQQuXz5eKAu2zouWOay6hjEPmrbCIvDsbiDsW0GUHxvq6lifGaldHLtboAHqeQLOQdkwTaegVTGKciRevKlfG5qnk76kkyuam9JeVuMOaeyziSCkWrleIqTevDqXQfGW4TfKuaNyvNuai6SQCxfK(cYPgLDMlkyuam9JeVuMOaeyziSCkWrleIqKOJe5CvOHemQXIc4eR6Kcy6rLwEAT8QcnKGuJYUUKcgfat)iXlLjkabwgclNcC0cHiulrvhuSAbimEBb58B2mVtSceuHjUuiFEXmVUPaoXQoPacAO8ccwPcI8o9KGuJAuaEL7suLTs6jbPGrzNbkyuam9JeVuMOaeyziSCkG5smTiE680slIPFK4DEWNNfebrTtUrgI4PZtlT5bF(JwiepqVsvaI4wmcrNyuaNyvNuGGudczJAu2fpfmkaM(rIxktuacSmewofGfebrTtUrgI7sNuUuXzv6GZd(8hTqiEGELQaeXTyeIoXOaoXQoPabPgeYg1OSRBkyuam9JeVuMOaoXQoPaexkvoXQovYIBuazXnv6lifa5CmjiNAu2fhkyuaNyvNuGaS3IPQHhkaM(rIxktuJYoOqbJcGPFK4LYefGaldHLtbCIvGGkmXLc5ZlM5f)8B2mVtSceuHjUuiFEXmpdZd(8m78MlX0ICwYYSk3vfbJy6hjEPaoXQoPahzTDRdVuJYoZHcgfWjw1jfG0lOP4wdxOay6hjEPmrnk76kkyuam9JeVuMOaeyziSCkWrleIfPisKh5Mt0zEHZdkZd(8m78hTqiEGELQaeXTyeIoXOaoXQoPa4PZtlnQrzN5Icgfat)iXlLjkabwgclNcC0cH4b6vQcqe3Iri6eBEWNFvZF0cHyOYDeYvDqfGn3Iq0j28B2mplicIANCJmedsniKT5x98Gp)QM)OfcXIuejYJloZqXnNOZ8mV5pAHqSifrI8i3CIoZV65zUzENyvNXaS52PLwezgirZqLvl48IoVtSQZ4U0jLlvCwLoyK4Ctz1coVOZ7eR6mUlDs5sfNvPdgnOdckvwTGZd6ZxjXtdHCvq2cuwTGkRJGs0t2Mh85pAHqCbxAiBQoOKAK6QUq0x4XBliPaoXQoPafbvspji1OSRlPGrbW0ps8szIcqGLHWYPahTqiEGELQaeXTyeIoXMFZM5zbrqu7KBKHiE680sB(nBM3CjMwSsINgc5QGSfeX0ps8op4ZtCUPSAbNx05nOdckvwTGZlM5RK4PHqUkiBbkRwqL1rqjQXAEWNN4Ctz1coVOZBqheuQSAbNh0NVsINgc5QGSfOSAbvwhfN4TfKuaNyvNuGDPtkxQ4SkDqQrnkWsdcUGPrbJYoduWOay6hjEPmrbiWYqy5uGLgeCbtlElU5jbNxmZZWkOaoXQoPahzL6qnk7INcgfat)iXlLjkabwgclNcC0cHyrqvq2ipEBbjfWjw1jfOiOkiBKtnQrbybrsVCCJcgLDgOGrbCIvDsbCiXtuvPHsjsmkaM(rIxktuJYU4PGrbCIvDsbe4gcvOexW0Cjfat)iXlLjQrzx3uWOay6hjEPmrbsFbPa(wUEh6CvOtt1bfRwacPaoXQoPa(wUEh6CvOtt1bfRwacPgLDXHcgfWjw1jfyPGWgQQfFhPay6hjEPmrnk7GcfmkGtSQtkaR2QoPay6hjEPmrnk7mhkyuaNyvNuGaS52PLgfat)iXlLjQrnkG3ifmk7mqbJc4eR6KceG9wmvn8qbW0ps8szIAu2fpfmkGtSQtkWrwB36Wlfat)iXlLjQrzx3uWOay6hjEPmrbCIvDsbiUuQCIvDQKf3OaYIBQ0xqkaY5ysqo1OSlouWOaoXQoPaKEbnf3A4cfat)iXlLjQrzhuOGrbCIvDsbkcQYgeNcGPFK4LYe1OSZCOGrbW0ps8szIcqGLHWYPaSGiiQDYnYqepDEAPn)MnZF0cH4b6vQcqe3Iri6eBEWNFvZZcIGO2j3idXaS52PL28Gp)QM)OfcXIuejYJCZj6mpOpV4m)MnZZSZBUetlUlDs5sfNvPdgX0ps8o)QNFZM5zbrqu7KBKH4U0jLlvCwLo48RMc4eR6KceKAqiBuJYUUIcgfat)iXlLjkabwgclNcC0cHyOYDeYvDqfGn3Iq0jgfWjw1jfOiOs6jbPgLDMlkyuaNyvNuaOZMQdQaS5gfat)iXlLjQrzxxsbJc4eR6KcGNopT0Oay6hjEPmrnk7mSckyuaNyvNuGDPtkxQ4SkDqkaM(rIxktuJYodmqbJc4eR6Kcq6evDqrA5LcGPFK4LYe1OSZG4PGrbW0ps8szIc4eR6Kcy1f5wdxuK(ImdkabwgclNcC0cHyrytbcwjpEBb58Gp)rleIqTevDqXQfGW4TfKuG0xqkGvxKBnCrr6lYmOgLDg0nfmkaM(rIxktuaNyvNuacBezBWolI6iDUrbiWYqy5uGJwielcBkqWk5XBliNh85pAHqeQLOQdkwTaegVTGKcGHasmv6lifGWgr2gSZIOosNBuJYodIdfmkGtSQtkqa2C70sJcGPFK4LYe1OSZaOqbJcGPFK4LYefWjw1jfG4sPYjw1PswCJcilUPsFbPalni4cMg1OSZaZHcgfWjw1jfOiOs6jbPay6hjEPmrnQrbiDlVTGKtbJYoduWOaoXQoPa7Ao8wEQ6GY3IW20tbW0ps8szIAu2fpfmkGtSQtka0VLNMIZYH6qbW0ps8szIAu21nfmkGtSQtkWfDt)PHjsbW0ps8szIAu2fhkyuaNyvNuGIWMceSsofat)iXlLjQrzhuOGrbCIvDsbwkiSHQAX3rkaM(rIxktuJYoZHcgfat)iXlLjkabwgclNcC0cHiulrvhuSAbimEBb58Gp)QMNfebrTtUrgIbyVftvdpZVzZ8wTGkRv3cNxmZZWkMx05jo3uwTGZd(8wTGkRv3cNh0Nx8Ry(vtbCIvDsbGAjQ6GIvlaHuJYUUIcgfat)iXlLjkabwgclNcyUetlc1su1bfRwacJy6hjENh85DIvGGkmXLc5ZlCEgMh85jDlVTGmc1su1bfRwacJbnPubrIEhUJkRwW5b95jDlVTGmgG9wmvn8eH4IxjNc4eR6KcqCPu5eR6ujlUrbKf3uPVGuaZLyAkyZIAu2zUOGrbW0ps8szIcqGLHWYPaSGiiQDYnYqSiSPabRKp)MnZB1cQSwDlCEqFEDVckGtSQtkaR2QoPgLDDjfmkaM(rIxktuaNyvNuGJlXqbr1b6jrpfGaldHLtby25nxIPf3LoPCPIZQ0bJy6hjENFZM5pAHq8a9kvbiIBXieDInp4ZZcIGO2j3idXDPtkxQ4SkDqkq6lif44smuquDGEs0tnk7mSckyuaNyvNuanoQkdx4uam9JeVuMOgLDgyGcgfWjw1jf4i7(QcAq2Oay6hjEPmrnk7miEkyuaNyvNuGdc5iuNk3Pay6hjEPmrnk7mOBkyuaNyvNuazTR34kDnT7(cMgfat)iXlLjQrzNbXHcgfWjw1jfiuq8i7(sbW0ps8szIAu2zauOGrbCIvDsb8KGCd6sfXLskaM(rIxktuJYodmhkyuaNyvNuGJVR6GYGfrhofat)iXlLjQrnkaY5ysqUQHhkyu2zGcgfat)iXlLjkabwgclNcC0cHiulrvhuSAbimEBb58Gp)fpAHqKLt0bVQIGXBliNFZM5DIvGGkmXLc5ZlM51nfWjw1jfi0enoEv(wewgQoOVqnk7INcgfat)iXlLjkabwgclNc4eRabvyIlfYNh0NhuMh85V4rleISCIo4vvemEBb58GppPB5TfKXaS3IPQHNiex8k5ZlM5bL5bFEMDENyvNXaS3IPQHNyLQGS21BZd(87WwlVkVXya2BXu1WteIlEL85fo)kOaoXQoPal4sdzt1bLuJux1fI(cNAu21nfmkaM(rIxktuacSmewofGfebrTtUrgIbyVftvdpZVzZ87WwlVkVXya2BXu1WteIlEL85fZ8GcfWjw1jf4i7(Q6GY0JkmXf2OgLDXHcgfat)iXlLjkabwgclNcC0cHiulrvhuSAbimEBb58Gp)fpAHqKLt0bVQIGXBliNFZM5DIvGGkmXLc5ZlM51nfWjw1jfGLgScSv5U6iDUrnk7GcfmkaM(rIxktuacSmewof4OfcrOwIQoOy1cqy82cY5bF(lE0cHilNOdEvfbJ3wqo)MnZ7eRabvyIlfYNxmZRBkGtSQtkaSyXsIQkvCwobPgLDMdfmkaM(rIxktuaNyvNuasNemnOB4vfK(csbiWYqy5uGJwieHAjQ6GIvlaHXBliNh85V4rleISCIo4vvemEBbjfqwjQixkaZHAu21vuWOay6hjEPmrbiWYqy5uGJwieHAjQ6GIvlaHXBliNh85V4rleISCIo4vvemEBbjfWjw1jfaIoRk3vbPVGCQrzN5Icgfat)iXlLjkabwgclNcC0cHiej6iroxfAibJASOaoXQoPaMEuPLNwlVQqdji1OSRlPGrbW0ps8szIcqGLHWYPahTqic1su1bfRwacJ3wqop4ZFXJwiez5eDWRQiy82cY5bFEs3YBliJbyVftvdpriU4vYNh0NxCMFZM5DIvGGkmXLc5ZlM51nfWjw1jfqqdLxqWkvqK3PNeKAuJcCXGRjnkyu2zGcgfWjw1jfG0APHqolukPay6hjEPmrnk7INcgfat)iXlLjkabwgclNcWSZdBZTQZy2QIGkPNeCEWNNfebrTtUrgIbPgeY28GppZo)rleIHk3rix1bva2ClcrNyuaNyvNuGIGkPNeKAu21nfmkaM(rIxktuaNyvNuaIlLkNyvNkzXnkGS4Mk9fKcq6wEBbjNAu2fhkyuam9JeVuMOaeyziSCkGtSceuHjUuiFEXmVUNh85nxIPfdqe3w5Uc6vgX0ps8o)MnZ7eRabvyIlfYNxmZlouaNyvNuaIlLkNyvNkzXnkGS4Mk9fKc4nsnk7GcfmkaM(rIxktuaNyvNuaIlLkNyvNkzXnkGS4Mk9fKcWRCxIuJAuJcacc5vNu2f)ke)kwbOiEqHciWHzL7CkaOzHvdn8opd6EENyvNZllUXJZAkalyhkjsba15flS528m39DCwdQZR3mwCXvrezVm9ANiPxeHxlAs3QojqpyIWRfIiZAqDEaKLHlheoVUzCEXVcXVIz9SguNNzsVN7ixCDwdQZZ8Mh0ohNFLTAbvwRUfUYZxj3q)oFhMFLnhUJw0QfuzT6w4kpFOHZlDUnphjDENNzc028ACFhJZAqDEM38ReE75zbRgwgBZhAOo85dnCEyBUvDg5MNxhEfja7TyQA4rKSvfbvspjyCwpRb15z(mdKOz4D(dgAiopPxoUn)b3RKhNxCHqqwgF(StMNEhUe0KZ7eR6KpFNs2IZAqDENyvN8ilis6LJBcdsNRZSguN3jw1jpYcIKE54MOcfj09DwdQZ7eR6KhzbrsVCCtuHI4A7lyAUvDoRDIvDYJSGiPxoUjQqrCiXtuvPHsjsSzTtSQtEKfej9YXnrfkcxBzPtLa3qOcL4cMMlN1G68oXQo5rwqK0lh3evOi80zX13MIBUXN1oXQo5rwqK0lh3evOiACuvgUWy6lOqFlxVdDUk0PP6GIvlaHZANyvN8ilis6LJBIkuKLccBOQw8DCw7eR6KhzbrsVCCtuHIWQTQZzTtSQtEKfej9YXnrfksa2C70sBwpRb15z(mdKOz4DEeeeY28wTGZB6X5DI1W5l(8oiEj9JeJZANyvNCHKwlneYzHs5SguNh0eM30JZV47486D(8ITf78EWq48eNBvUpFLCZtBEXk1Gq2yCEb48epN)IsNT5n948GgcoVUUNeCEpVZRXX5BtpcNxFTRFEwWQHLX28oXQozC(kmVdIxs)iX4S2jw1jxuHIueuj9KGmwbHmlSn3QoJzRkcQKEsqWzbrqu7KBKHyqQbHSboZE0cHyOYDeYvDqfGn3Iq0j2S2jw1jxuHIqCPu5eR6ujlUXy6lOqs3YBli5ZAqDEW0JZBoChT5n9qKRVL35lEUY28iZWjwCEMqtaI586M5bkZBoChnoJZB6X5VviGqmjiF(dAcqmN30JZda28EENxCPz(Z7eR6CEzXn(8oeNh6MEeopFXLY48m32cqqqiJZlwiIBRCF(vYRCEwqmGq(8A8k3NxCPz(Z7eR6CEzXT55DNiCENpFzZFWedLXNFhIUjzB(aSxM30JZRV21pply1WYyBEMK12To8oVtSQZ4S2jw1jxuHIqCPu5eR6ujlUXy6lOqVrgRGqNyfiOctCPqUy0n4MlX0IbiIBRCxb9kJy6hjE3SXjwbcQWexkKlgXzw7eR6KlQqriUuQCIvDQKf3ym9fuiVYDjoRN1G68I7Y0pVyHiUTY95xjVsgNVSvMp)bndHZB98SGvdlR2IZRXRCFEXc7TyopOf8mVa9yo)Pn9ZlwqR598optYA7whEN3H48DimpPB5TfKX5f3LPV1S5fleXTvUp)k5vY48MECEsNGGqooFXN3GA48U003A76N30JZFRqaHysW5l(8lvwCIMeNxlTsopiiKT51x76N3C4oAZtAT04XzTtSQtE0Buya2BXu1WZS2jw1jp6nkQqroYA7whEN1oXQo5rVrrfkcXLsLtSQtLS4gJPVGcrohtcYN1oXQo5rVrrfkcPxqtXTgUmRDIvDYJEJIkuKIGQSbXN1G68a1clzfk8oVyLAqiBZt68ww1jF(aSxM30JZda28oXQoNxwClopqLeCEtpo)IVJZx853XeHUv5(8bhoVe585zc6voVyHiUfNNO3H7iNX5n948iZWj28KoVLvDoVEeIZx8CLT5DPCEtVBZxlSAO5PfN1oXQo5rVrrfksqQbHSXyfeYcIGO2j3idr805PL2MnhTqiEGELQaeXTyeIoXaFvSGiiQDYnYqmaBUDAPb(QoAHqSifrI8i3CIoGU4SzdZAUetlUlDs5sfNvPdgX0ps8U6nBybrqu7KBKH4U0jLlvCwLo4QN1oXQo5rVrrfksrqL0tcYyfeE0cHyOYDeYvDqfGn3Iq0j2SguNhm948l(ooVGskNFhte6sjBZFW53XeHUv5(8(8Y2MVdZl2wSZt07WDKpVa9yoVgVY95n948IlnZFENyvNZllUfNhmiBvUpV1ZFrPZ28RKZ28DyEXcBUnVwALCEtpcX5DioF2Zl2wSZt07WDKpVN35ZEENyfi48If2BXCEql4HpVGwtENxI(DERNVS5Z2M)GvUpVghVZ728UugN1oXQo5rVrrfkc0zt1bva2CBw7eR6Kh9gfvOi4PZtlTzTtSQtE0BuuHISlDs5sfNvPdoRb15bTZRCFEMPoX57W8mtT8oFXNFP5MKT5bTXmdmFIAg0LZlOm9ZB6X5fxAM)8Md3rBEtpe56B5LhNh0yZ3PKT5piPxq(8xKGPn)Ux58ckt)8WwBxVKT51vZ3W5xAioV5WD04XzTtSQtE0BuuHIq6evDqrA5Dw7eR6Kh9gfvOiACuvgUWy6lOqRUi3A4II0xKzWyfeE0cHyrytbcwjpEBbj4hTqic1su1bfRwacJ3wqoRDIvDYJEJIkuenoQkdxyedbKyQ0xqHe2iY2GDwe1r6CJXki8OfcXIWMceSsE82csWpAHqeQLOQdkwTaegVTGCw7eR6Kh9gfvOibyZTtlTzTtSQtE0BuuHIqCPu5eR6ujlUXy6lOWLgeCbtBw7eR6Kh9gfvOifbvspj4SEw7eR6KhjDlVTGKlCxZH3Ytvhu(we2M(zTtSQtEK0T82csUOcfb63YttXz5qDM1oXQo5rs3YBli5IkuKl6M(tdtCw7eR6KhjDlVTGKlQqrkcBkqWk5ZANyvN8iPB5TfKCrfkYsbHnuvl(ooRb15xjTeNVdZZm3cq48fFExkWzJpVghVZlOm9ZlwyVfZ5bTGN48IljBZlXG1GGW5j6D4oYN3T5n948yENVdZB6X5d1UEBEU(wtEN)GZRXXlJZxx0Ls2MVcZB6X5pnNp)TrEUY283cNVY5n948l19kX57W8MEC(vslX5pAHqCw7eR6KhjDlVTGKlQqrGAjQ6GIvlaHmwbHhTqic1su1bfRwacJ3wqc(Qybrqu7KBKHya2BXu1WZMnwTGkRv3cfddRquIZnLvli4wTGkRv3cbDXVIvpRb15bTY55vUlX5nhUJ28HAxVXzCEtpopPB5TfKZ3H5xjTeNVdZZm3cq48fFEzlaHZB69CEtpopPB5TfKZ3H5flS3I58GwWdJZB6l(87fiiFEKzyqF(vslX57W8mZTaeoprVd3r(8ME3MNRV1K35p48AC8oVGY0pVtSceCEZLyACgNVcZZQ586iX4S2jw1jps6wEBbjxuHIqCPu5eR6ujlUXy6lOqZLyAkyZIXki0CjMweQLOQdkwTaegX0ps8cUtSceuHjUuixidGt6wEBbzeQLOQdkwTaegdAsPcIe9oChvwTGGoPB5TfKXaS3IPQHNiex8k5ZANyvN8iPB5TfKCrfkcR2QozScczbrqu7KBKHyrytbcwjFZgRwqL1QBHGUUxXS2jw1jps6wEBbjxuHIOXrvz4cJPVGcpUedfevhONe9mwbHmR5smT4U0jLlvCwLoyet)iX7MnhTqiEGELQaeXTyeIoXaNfebrTtUrgI7sNuUuXzv6GZANyvN8iPB5TfKCrfkIghvLHl8zTtSQtEK0T82csUOcf5i7(QcAq2M1oXQo5rs3YBli5IkuKdc5iuNk3N1oXQo5rs3YBli5IkuezTR34kDnT7(cM2S2jw1jps6wEBbjxuHIekiEKDFN1oXQo5rs3YBli5Ikuepji3GUurCPCw7eR6KhjDlVTGKlQqro(UQdkdweD4Z6znOopZNZXKGCX15bmpVo8oVN35zVNh0qW5119KGZANyvN8iY5ysqU6IbxtAcdnrJJxLVfHLHQd6lmwbHhTqic1su1bfRwacJ3wqUzJtSceuHjUuixm6Ew7eR6KhrohtcYvxm4AstuHISGlnKnvhusnsDvxi6lCgRGqNyfiOctCPqoOdkGVQJwielsrKipYnNOdOlKHnBywZLyAXDPtkxQ4SkDWiM(rI3vdoPB5TfKXaS3IPQHNiex8k5IHHva(QywyBUvDg5MNxhE3SHzDIvDgdWElMQgEIvQcYAxVb(oS1YRYBmgG9wmvn8eH4Ixjx4kw9S2jw1jpICoMeKRUyW1KMOcf5i7(Q6GY0JkmXf2ySccxL5smT4U0jLlvCwLoyet)iXl4hTqiwKIirEKBorhHGc4R6OfcXd0RufGiUfJq0j2MnSGiiQDYnYqepDEAPT6vVzZQwLtSceuHjUuixm6EZgM1CjMwCx6KYLkoRshmIPFK4D1GVkwqee1o5gzigG9wmvn8SzZoS1YRYBmgG9wmvn8eH4IxjxmGYQx9S2jw1jpICoMeKRUyW1KMOcfHLgScSv5U6iDUXyfeE0cHiulrvhuSAbimEBb5MnoXkqqfM4sHCXO7zTtSQtEe5CmjixDXGRjnrfkcSyXsIQkvCwobzSccpAHqeQLOQdkwTaegVTGCZgNyfiOctCPqUy09S2jw1jpICoMeKRUyW1KMOcfH0jbtd6gEvbPVGmkRevKRqMdJvq4rleIqTevDqXQfGW4TfKZANyvN8iY5ysqU6IbxtAIkuei6SQCxfK(cYzSccpAHqeQLOQdkwTaegVTGCw7eR6KhrohtcYvxm4AstuHIy6rLwEAT8QcnKGmwbHhTqicrIosKZvHgsWOgRzTtSQtEe5CmjixDXGRjnrfkIGgkVGGvQGiVtpjiJvq4rleIqTevDqXQfGW4TfKB24eRabvyIlfYfJUN1ZAqDEMpNJjb5IRZlwyVfZ5bTGNzTtSQtEe5Cmjix1WJOcfj0enoEv(wewgQoOVWyfeE0cHiulrvhuSAbimEBbj4x8Ofcrworh8QkcgVTGCZgNyfiOctCPqUy09S2jw1jpICoMeKRA4ruHISGlnKnvhusnsDvxi6lCgRGqNyfiOctCPqoOdkGFXJwiez5eDWRQiy82csWjDlVTGmgG9wmvn8eH4IxjxmGc4mRtSQZya2BXu1WtSsvqw76nW3HTwEvEJXaS3IPQHNiex8k5cxXS2jw1jpICoMeKRA4ruHICKDFvDqz6rfM4cBmwbHSGiiQDYnYqma7TyQA4zZMDyRLxL3yma7TyQA4jcXfVsUyaLzTtSQtEe5Cmjix1WJOcfHLgScSv5U6iDUXyfeE0cHiulrvhuSAbimEBbj4x8Ofcrworh8QkcgVTGCZgNyfiOctCPqUy09S2jw1jpICoMeKRA4ruHIalwSKOQsfNLtqgRGWJwieHAjQ6GIvlaHXBlib)IhTqiYYj6GxvrW4TfKB24eRabvyIlfYfJUN1oXQo5rKZXKGCvdpIkuesNemnOB4vfK(cYOSsurUczomwbHhTqic1su1bfRwacJ3wqc(fpAHqKLt0bVQIGXBliN1oXQo5rKZXKGCvdpIkuei6SQCxfK(cYzSccpAHqeQLOQdkwTaegVTGe8lE0cHilNOdEvfbJ3wqoRDIvDYJiNJjb5QgEevOiMEuPLNwlVQqdjiJvq4rleIqKOJe5CvOHemQXAw7eR6KhrohtcYvn8iQqre0q5feSsfe5D6jbzSccpAHqeQLOQdkwTaegVTGe8lE0cHilNOdEvfbJ3wqcoPB5TfKXaS3IPQHNiex8k5GU4SzJtSceuHjUuixm6EwpRDIvDYJiNJjb5cjUuQCIvDQKf3yKBWIyczGX0xqHiNJjb5QgEySccHT5w1zma7TyQA4zw7eR6KhrohtcYfvOiexkvoXQovYIBmYnyrmHmWy6lOqKZXKGC1fdUM0yScczwyBUvDgdWElMQgEM1ZANyvN84sdcUGPj8iRuhLNSXyfeU0GGlyAXBXnpjOyyyfZANyvN84sdcUGPjQqrkcQcYg5mwbHhTqiweufKnYJ3wqoRN1G68avUlX5bZH7OnRb15f3LPV1S51famopZ)05PL28fFExkWzJppxVBgcXBCEXDz6NxxaW48m)tNNwAZx8556DZqiENVcZx28cAn5DEbo3W5zc6voVyHiUfNNO3H748RQIyCEb6XCEtpo)IVJZZnhA85jo3QCFEM)PZtlT5fuM(5zc6voVyHiUfN3jwbcU65B48c0J58hu2cMxCMh0qkIe5ZVQkmpZ)05PL28fFEIZT5fOhZ5n948l(ooVENpV4W8aL5bnKIiroJZx2kZN)GMHW5TEEnooVPhNNjOx58IfI4wC(aSxMVS57CEDH0jLlNhGvPdU64S2jw1jpYRCxIkU551HxHbPgeYgJvqO5smTiE680slIPFK4fCwqee1o5gziINopT0aFvmR5smT4U0jLlvCwLoyet)iX7MnhTqiwKIirEKBorhqxC2S5OfcXd0RufGiUfJq0j2QN1G686cPtkxopaRshC(IpVlf4SXNNR3ndH4noRDIvDYJ8k3LOIBEED4vuHIeKAqiBmwbHMlX0I7sNuUuXzv6Grm9JeVGZcIGO2j3idXDPtkxQ4SkDqWpAHq8a9kvbiIBXieDInRb15f3LPV1S51famoVPhNFX3X5110428gSq(8wppxVBgcN35ZV4jBZlwyZTtln(8oFEwnNxhjgNxCxM(51famoVPhNFX3X57uY28C9UziKpVyHn3oT0M30728cAn5DEwA28MECzE3MNbMNUNh0qkIeNNBorhECEqBviGqmj48h0eGyopxVBgcRCFEXcBUDAPnVGY0ppdmpDppOHuejYN3Z78mW8eN5bnKIir(8fFE(IlLmo)rZMNbMNUN3W8YN365p48h0meoFLZV0qCEEzAUvDYNFvMECE91UEeoVUay(RV4748fNX5n948lneNVS5LON85TwGdV85zG5P7vhNxSnKu5(8C9UziC(oNxSWMBNwAZx855wjLZ7ZZxCPC(DVsgNN3Zx85Z2MN4Wk3N3pTMnVyBXgNh0qW5119KGZx85TUNxa66mV1ZlWHqpT5VO0zRY95zc6voVyHiUfNxSsniKT4S2jw1jpYRCxIkU551HxrfksqQbHSXyfeYcIGO2j3idXaS52PLg4hTqiEGELQaeXTyeIoXaFvmR5smT4U0jLlvCwLoyet)iX7MnhTqiwKIirEKBorhqxCw9S2jw1jpYRCxIkU551HxrfkcXLsLtSQtLS4gJPVGcrohtcYN1oXQo5rEL7suXnpVo8kQqrcWElMQgEM1G68I7Y0pVyHiUTY95xjVY598oVBZlrNBZl(5nhUJgNX5zswB36W78jIx(8wp)bNxJJ35fuM(51x76r48SGvdlJT5TE(fxhCEUgeNNTwBEINZhkB(tB6NVsU5PnptYA7whE5ZxP1Z7ZZRCxIZlwiIBRCF(vYRmopG5qRY95fuM(5n9qeN3C4oACgNNjzTDRdVZlrheKpVPhNx2cMNfSAyzSnFOKseopSL48EENV4ZRXX78DopPB5TfKZVkpVZRRPXT5xCDQCFEUgeNpBBERNxGZnCEMGELZlwiIBX5j6D4oYx98ckt)8nCEbLPV1S5fleXTvUp)k5vgN1oXQo5rEL7suXnpVo8kQqroYA7whEzSccDIvGGkmXLc5Ir8B24eRabvyIlfYfddGtCUPSAbfUcWpAHqmu5oc5QoOcWMBri6ed0f)SguNhmiBvUpV1ZZQB58e9oCh5Z3H5fBl25dnCEpzZ0x5(8fpxzBEbn00pFzX5bTZX5n94Y8oFEtpY28KEbJZANyvN8iVYDjQ4MNxhEfvOifbvspjiJvq4rleIHk3rix1bva2ClcrNyZANyvN8iVYDjQ4MNxhEfvOiKEbnf3A4YS2jw1jpYRCxIkU551HxrfkcE680sBwdQZVsoBZ3H5flS528fFEnoEN3dgcN3LY5fBL7iKpFhMxSWMBZt07WDKpVEheC(dI58AC8oVN35n9ieNV45kBZ7eRabNxSWElMZdAbpZB6DBEsRjVZVJjcDdNFPHyCEW0x85l(8DkzBEFE(IlLZV7voVV7vYT5x0KwXsIZBoChnoJZ785xjNT57W8If2CB(INRSnV1981clNybnzCw7eR6Kh5vUlrf3886WROcfb6SP6GkaBUXyfeYSoXQoJbyVftvdpXkvbzTR3aFh2A5v5ngdWElMQgEIqCXRKlCfZAqDEMK12To8oFXNxJJ35D(8YwW8SGvdlJT5dLuIW59DVsUnV4N3C4oA848IB9yoVgVY95fleXTvUp)k5vY48LTY8595xWBPTm)Ux58wpVghN30JZxj380MNjzTDRdVZJGG58(Uxj3M3NNx5UeN3C4oAmopYzHKYLs2Mxqz6Nx2cMFX5gczloRDIvDYJ8k3LOIBEED4vuHICK12To8YyfesCUPSAbfUInBCIvGGkmXLc5IHHznOoVUq6KYLZdWQ0bNV4ZRXX78c0J58MEeIRmFEFEMGELZlwiIBX5zbBY8oXkqW5xvfX48DkzBEb6XC(YMN458hCEUE3meI3vhNhm9fF(IpVppFXLY5TE(f8wAlZV7voFLZV0CBEEzAUvDYJZRR3cMFX5gczBEj6jFERf4WlFEnEL7Zx28c0J58oiEj9JeJZlU1J58A8k3NhGLSmRY95bneCEpVZR3bPY959Sn9iCEZH7OnFIo8WgJZx2kZNNlRD9MKT5pOziCERNxJJZRlaMxGEmN3bXlPFKiJZ785n948CK05DEZH7On)TrEUY28hmXqzZhG9Y8C9UziSY95n948lELZBoChT4S2jw1jpYRCxIkU551HxrfkYU0jLlvCwLoiJvq4rleIhOxPkarClgHOtSnBybrqu7KBKHiE680sBZgNyfiOctCPqUyyaCZLyArolzzwL7QIGrm9JeVZ6zTtSQtEKx5UevzRKEsqHbPgeYgJvqO5smTiE680slIPFK4fCwqee1o5gziINopT0a)OfcXd0RufGiUfJq0j2S2jw1jpYRCxIQSvspjOOcfji1Gq2yScczbrqu7KBKH4U0jLlvCwLoi4hTqiEGELQaeXTyeIoXM1oXQo5rEL7suLTs6jbfvOiexkvoXQovYIBmM(cke5CmjiFw7eR6Kh5vUlrv2kPNeuuHIeG9wmvn8mRDIvDYJ8k3LOkBL0tckQqroYA7whEzSccDIvGGkmXLc5Ir8B24eRabvyIlfYfddGZSMlX0ICwYYSk3vfbJy6hjEN1oXQo5rEL7suLTs6jbfvOiKEbnf3A4YS2jw1jpYRCxIQSvspjOOcfbpDEAPXyfeE0cHyrkIe5rU5eDeckGZShTqiEGELQaeXTyeIoXM1oXQo5rEL7suLTs6jbfvOifbvspjiJvq4rleIhOxPkarClgHOtmWx1rleIHk3rix1bva2ClcrNyB2WcIGO2j3idXGudczB1GVQJwielsrKipU4mdf3CIomVJwielsrKipYnNOZQzUXjw1zmaBUDAPfrMbs0muz1ckQtSQZ4U0jLlvCwLoyK4Ctz1ckQtSQZ4U0jLlvCwLoy0GoiOuz1cc6vs80qixfKTaLvlOY6iOe9KnWpAHqCbxAiBQoOKAK6QUq0x4XBliN1oXQo5rEL7suLTs6jbfvOi7sNuUuXzv6GmwbHhTqiEGELQaeXTyeIoX2SHfebrTtUrgI4PZtlTnBmxIPfRK4PHqUkiBbrm9JeVGtCUPSAbf1GoiOuz1ckMkjEAiKRcYwGYQfuzDeuIASaN4Ctz1ckQbDqqPYQfe0RK4PHqUkiBbkRwqL1rXjEBb5SEw7eR6Kh5vUlrvdpcjUuQCIvDQKf3ym9fuiY5ysq(S2jw1jpYRCxIQgEevOibyVftvdpZANyvN8iVYDjQA4ruHIeKAqiBmwbHSGiiQDYnYqepDEAPb(rleIhOxPkarClgHOtSzTtSQtEKx5Uevn8iQqroYA7whEzSccDIvGGkmXLc5Ir8B24eRabvyIlfYfddGtCUPSAbfUIzTtSQtEKx5Uevn8iQqrkcQKEsqgRGWJwiedvUJqUQdQaS5weIoXaN0T82cYya2BXu1WteIlELCXakB2C0cHyOYDeYvDqfGn3Iq0jMqXpRDIvDYJ8k3LOQHhrfkYrwB36WlJvqiX5MYQfu4kM1oXQo5rEL7su1WJOcfji1Gq2yScczbrqu7KBKHiE680sBw7eR6Kh5vUlrvdpIkuKGudczJXki8OfcXd0RufGiUfJq0jg4RIfebrTtUrgIbyZTtlTnBU4rleISCIo4vvemcXfVsUyqMbs0muz1ckQtSQZyrqL0tcgnOdckvwTGREw7eR6Kh5vUlrvdpIkuesVGMIBnCzw7eR6Kh5vUlrvdpIkue805PL2S2jw1jpYRCxIQgEevOiqNnvhubyZngRGWlE0cHilNOdEvfbJASySsdHqnwMQccpAHqmu5oc5QoOcWMBri6etO4zSsdHqnwMQwwWB5gkKHzTtSQtEKx5Uevn8iQqroYA7whEN1ZAqDEqtopVxW55LP5w1jNX5zR1MN458C9UziCEqdbNN9geFEeemN3dgcN3Lq0VSnpX5wL7ZlwPgeY28EENh0qW5119KGX5bTm9iuqXX5n9fFENyvNZx85144DEb6XCEtpo)IVJZR35Zl2wSZ7bdHZtCUv5(8IvQbHSX48CeN3pniyCw7eR6Kh5vUlrHfbvzdIZyfes6wEBbzSiOkBq8ie9lBGFXJwiefuPHqUIOVKYOgRzTtSQtEKx5UefvOiexkvoXQovYIBmYnyrmHmWy6lOqEL7suXnpVo8YyfecBZTQZi3886W7S2jw1jpYRCxIIkueIlLkNyvNkzXng5gSiMqgym9fuiVYDjQYwj9KGmwbHW2CR6mMTQiOs6jbN1oXQo5rEL7suuHIqCPu5eR6ujlUXi3GfXeYaJPVGc5vUlrvdpmwbHW2CR6mgG9wmvn8mRDIvDYJ8k3LOOcfPiOkBq8zTtSQtEKx5UefvOiACuvgUWy6lOqRUi3A4II0xKzWyfeE0cHyrytbcwjpEBbj4hTqic1su1bfRwacJ3wqoRDIvDYJ8k3LOOcfrJJQYWfgXqajMk9fuiHnISnyNfrDKo3ySccpAHqSiSPabRKhVTGe8JwieHAjQ6GIvlaHXBliN1oXQo5rEL7suuHIeGn3oT0M1oXQo5rEL7suuHIqCPu5eR6ujlUXy6lOWLgeCbtBw7eR6Kh5vUlrrfksrqL0tcoRN1G68I7Y0pVUq6KYLZdWQ0bzC(vslX57W8mZTaeopxFRjVZFW5144DEyTR3M)GHgIZB6X51fsNuUCEawLo48KE50ZVQkIX5fuM(5bL5bnKIir(8EEN3NNjOx58IfI4wC1X5f36XCEM)PZtlT5l(8DimpPB5TfKmo)kPL48DyEM5wacNN458UK3ZFW5144DEDnnUnVGY0ppOmpOHuejYJZANyvN8O5smnfSzjeQLOQdkwTaeYyfeE0cHiulrvhuSAbimEBbj4MlX0I7sNuUuXzv6Grm9JeVGF0cHyrkIe5rU5eDeckGVQJwiepqVsvaI4wmcrNyB2yUetlINopT0Iy6hjEbN0T82cYiE680slcXfVsoOtCUPSAbx9SguNxCxM(wZMxxiDs5Y5byv6Gmo)kPL48DyEM5wacNNRV1K35p48AC8o)bdneN3t2M)u77iCEs3YBliNFvm)tNNwAmopZuVG28awdxyC(vYzB(omVyHn3w98nCEb6XC(vslX57W8mZTaeoFXN3pTMnV1ZdrNOFEXpprVd3rECw7eR6KhnxIPPGnlrfkculrvhuSAbiKXki8OfcrOwIQoOy1cqy82csWzwZLyAXDPtkxQ4SkDWiM(rIxWxL5smTiE680slIPFK4fCs3YBliJ4PZtlTiex8k5GoX5MYQfCZgZLyArsVGMIBnCjIPFK4fCs3YBliJKEbnf3A4seIlELCqN4Ctz1cUzJ5smTi0zt1bva2ClIPFK4fCs3YBliJqNnvhubyZTiex8k5GoX5MYQfCZgIEhUJCva6eR60LIHHOUC1uaolKqzN5iouJAuka]] )


end
