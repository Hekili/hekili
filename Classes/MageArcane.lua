-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] arcane_prodigy
-- [-] artifice_of_the_archmage
-- [-] magis_brand
-- [x] nether_precision

-- Covenant
-- [-] ire_of_the_ascended
-- [x] siphoned_malice
-- [x] gift_of_the_lich
-- [x] discipline_of_the_grove

-- Endurance
-- [-] cryofreeze
-- [-] diverted_energy
-- [x] tempest_barrier

-- Finesse
-- [x] flow_of_time
-- [x] incantation_of_swiftness
-- [x] winters_protection
-- [x] grounding_surge


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 62, true )

    spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
        arcane_orb = {
            aura = "arcane_orb",

            last = function ()
                local app = state.buff.arcane_orb.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.5,
            value = function () return state.active_enemies end,
        },
    } )

    spec:RegisterResource( Enum.PowerType.Mana, {
        evocation = {
            aura = "evocation",

            last = function ()
                local app = state.buff.evocation.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.1,
            value = function () return state.mana.regen * 0.1 end,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        amplification = 22458, -- 236628
        rule_of_threes = 22461, -- 264354
        arcane_familiar = 22464, -- 205022

        master_of_time = 23072, -- 342249
        shimmer = 22443, -- 212653
        slipstream = 16025, -- 236457

        incanters_flow = 22444, -- 1463
        focus_magic = 22445, -- 321358
        rune_of_power = 22447, -- 116011

        resonance = 22453, -- 205028
        arcane_echo = 22467, -- 342231
        nether_tempest = 22470, -- 114923

        chrono_shift = 22907, -- 235711
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        reverberate = 22455, -- 281482
        arcane_orb = 22449, -- 153626
        supernova = 22474, -- 157980

        overpowered = 21630, -- 155147
        time_anomaly = 21144, -- 210805
        enlightened = 21145, -- 321387
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        arcane_empowerment = 61, -- 276741
        dampened_magic = 3523, -- 236788
        kleptomania = 3529, -- 198100
        mass_invisibility = 637, -- 198158
        master_of_escape = 635, -- 210476
        netherwind_armor = 3442, -- 198062
        prismatic_cloak = 3531, -- 198064
        temporal_shield = 3517, -- 198111
        torment_the_weak = 62, -- 198151
    } )

    -- Auras
    spec:RegisterAuras( {
        alter_time = {
            id = 342246,
            duration = 10,
            max_stack = 1,
        },
        arcane_charge = {
            duration = 3600,
            max_stack = 4,
            generate = function ()
                local ac = buff.arcane_charge

                if arcane_charges.current > 0 then
                    ac.count = arcane_charges.current
                    ac.applied = query_time
                    ac.expires = query_time + 3600
                    ac.caster = "player"
                    return
                end

                ac.count = 0
                ac.applied = 0
                ac.expires = 0
                ac.caster = "nobody"
            end,
        },
        arcane_familiar = {
            id = 210126,
            duration = 3600,
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        arcane_orb = {
            duration = 2.5,
            max_stack = 1,
            --[[ generate = function ()
                local last = action.arcane_orb.lastCast
                local ao = buff.arcane_orb

                if query_time - last < 2.5 then
                    ao.count = 1
                    ao.applied = last
                    ao.expires = last + 2.5
                    ao.caster = "player"
                    return
                end

                ao.count = 0
                ao.applied = 0
                ao.expires = 0
                ao.caster = "nobody"
            end, ]]
        },
        arcane_power = {
            id = 12042,
            duration = function () return level > 55 and 15 or 10 end,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        chilled = {
            id = 205708,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        chrono_shift_buff = {
            id = 236298,
            duration = 5,
            max_stack = 1,
        },
        chrono_shift = {
            id = 236299,
            duration = 5,
            max_stack = 1,
        },
        clearcasting = {
            id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
            duration = 15,
            type = "Magic",
            max_stack = function () return pvptalent.arcane_empowerment.enabled and 5 or 1 end,
            copy = { 263725, 276743 }
        },
        enlightened = {
            id = 321390,
            duration = 3600,
            max_stack = 1,
        },
        evocation = {
            id = 12051,
            duration = function () return 6 * haste end,
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
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        greater_invisibility = {
            id = 110960,
            duration = 20,
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
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
        mirrors_of_torment = {
            id = 314793,
            duration = 20,
            type = "Magic",
            max_stack = 3,
        },
        nether_tempest = {
            id = 114923,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        presence_of_mind = {
            id = 205025,
            duration = 3600,
            max_stack = function () return level > 53 and 3 or 2 end,
        },
        prismatic_barrier = {
            id = 235450,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        radiant_spark = {
            id = 307443,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        radiant_spark_vulnerability = {
            id = 307454,
            duration = 3.707,
            max_stack = 4,
        },
        ring_of_frost = {
            id = 82691,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        rule_of_threes = {
            id = 264774,
            duration = 15,
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 15,
            max_stack = 1,
        },
        shimmer = {
            id = 212653,
        },
        slow = {
            id = 31589,
            duration = 15,
            type = "Magic",
            max_stack = 1,
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
        touch_of_the_magi = {
            id = 210824,
            duration = 8,
            max_stack = 1,
        },

        -- Azerite Powers
        brain_storm = {
            id = 273330,
            duration = 30,
            max_stack = 1,
        },

        equipoise = {
            id = 264352,
            duration = 3600,
            max_stack = 1,
        },


        -- Conduits
        nether_precision = {
            id = 336889,
            duration = 10,
            max_stack = 2
        },
    } )


    do
        -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.

        function Hekili:EmbedDisciplinaryCommand( x )
            local file_id = x.id

            x:RegisterAuras( {
                disciplinary_command = {
                    id = 327371,
                    duration = 20,
                },

                disciplinary_command_arcane = {
                    duration = 10,
                    max_stack = 1,
                },

                disciplinary_command_frost = {
                    duration = 10,
                    max_stack = 1,
                },

                disciplinary_command_fire = {
                    duration = 10,
                    max_stack = 1,
                }
            } )

            local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0

            x:RegisterHook( "reset_precast", function ()
                if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
                if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
                if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end
        
                if now - __last_disciplinary_command < 30 then
                    setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
                end
            end )

            x:RegisterStateFunction( "update_disciplinary_command", function( elem )
                if not legendary.disciplinary_command.enabled then return end

                if elem == "arcane" then applyBuff( "disciplinary_command_arcane" ) end
                if elem == "fire"   then applyBuff( "disciplinary_command_fire" ) end
                if elem == "frost"  then applyBuff( "disciplinary_command_frost" ) end
        
                if cooldown.buff_disciplinary_command.remains == 0 and buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                    applyBuff( "disciplinary_command" )
                    setCooldown( "buff_disciplinary_command", 30 )
                end
            end )
        
            x:RegisterHook( "runHandler", function( action )
                local a = class.abilities[ action ]
        
                if a then
                    update_disciplinary_command( a.discipline or state.spec.key )
                end
            end )

            x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
                if sourceGUID == GUID then
                    if subtype == "SPELL_CAST_SUCCESS" then
                        local ability = class.abilities[ spellID ]
        
                        if ability then
                            if ability.discipline == "frost" then
                                __last_frost  = GetTime()
                            elseif ability.discipline == "fire" then
                                __last_fire   = GetTime()
                            else
                                __last_arcane = GetTime()
                            end
                        end
                    elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                        __last_disciplinary_command = GetTime()
                    end
                end
            end )

            x:RegisterAbility( "buff_disciplinary_command", {
                cooldown_special = function ()
                    local remains = ( now + offset ) - __last_disciplinary_command
                    
                    if remains < 30 then
                        return __last_disciplinary_command, 30
                    end
    
                    return 0, 0
                end,
                unlisted = true,
    
                cast = 0,
                cooldown = 30,
                gcd = "off",
            
                handler = function()
                    applyBuff( "disciplinary_command" )
                end,
            } )
        end

        Hekili:EmbedDisciplinaryCommand( spec )
    end


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else
                if talent.rule_of_threes.enabled and arcane_charges.current >= 3 and arcane_charges.current - amt < 3 then
                    applyBuff( "rule_of_threes" )
                end
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end
        end
    end )


    spec:RegisterStateTable( "burn_info", setmetatable( {
        __start = 0,
        start = 0,
        __average = 20,
        average = 20,
        n = 1,
        __n = 1,
    }, {
        __index = function( t, k )
            if k == "active" then
                return t.start > 0
            end
        end,
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )


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

    spec:RegisterStateExpr( "incanters_flow_stacks", function ()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end
        
        return incanters_flow.values[ index ][ 1 ]
    end )

    spec:RegisterStateExpr( "incanters_flow_dir", function()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end

        return incanters_flow.values[ index ][ 2 ]
    end )

    -- Seemingly, a very silly way to track Incanter's Flow...
    local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
        __index = function( t, k )
            if not state.talent.incanters_flow.enabled then return 0 end

            local stack = t.__stack
            local ticks = #state.incanters_flow.values

            local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

            local low_pos, high_pos

            if k == "up" then low_pos = 5
            elseif k == "down" then high_pos = 6 end

            local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

            for i = 0, 10 do
                local index = ( start + i )
                if index > 10 then index = index % 10 end

                local values = state.incanters_flow.values[ index ]

                if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                    return max( 0, i - time_since )
                end
            end

            return 0
        end
    } )

    spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
        __index = function( t, k )
            incanters_flow_time_obj.__stack = tonumber( k ) or 0
            return incanters_flow_time_obj
        end
    } ) )


    spec:RegisterStateExpr( "fake_mana_gem", function ()
        return false
    end )


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
            -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
            burn_info.__start = 0
        end

        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        fake_mana_gem = nil

        incanters_flow.reset()
    end )


    spec:RegisterStateFunction( "start_burn_phase", function ()
        burn_info.start = query_time
    end )


    spec:RegisterStateFunction( "stop_burn_phase", function ()
        if burn_info.start > 0 then
            burn_info.average = burn_info.average * burn_info.n
            burn_info.average = burn_info.average + ( query_time - burn_info.start )
            burn_info.n = burn_info.n + 1

            burn_info.average = burn_info.average / burn_info.n
            burn_info.start = 0
        end
    end )


    spec:RegisterStateExpr( "burn_phase", function ()
        return burn_info.start > 0
    end )

    spec:RegisterStateExpr( "average_burn_length", function ()
        return burn_info.average or 15
    end )


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 12042 then
                burn_info.__start = GetTime()
                Hekili:Print( "Burn phase started." )
            elseif spellID == 12051 and burn_info.__start > 0 then
                burn_info.__average = burn_info.__average * burn_info.__n
                burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                burn_info.__n = burn_info.__n + 1

                burn_info.__average = burn_info.__average / burn_info.__n
                burn_info.__start = 0
                Hekili:Print( "Burn phase ended." )
            end
        end
    end )


    spec:RegisterVariable( "have_opened", function ()
        if active_enemies > 2 or variable.prepull_evo == 1 then return 1 end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then return 1 end
        return 0
    end )


    -- Abilities
    spec:RegisterAbilities( {
        alter_time = {
            id = function () return buff.alter_time.down and 342247 or 342245 end,
            cast = 0,
            cooldown = function () return talent.master_of_time.enabled and 30 or 60 end,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 609811,
            
            handler = function ()
                if buff.alter_time.down then
                    applyBuff( "alter_time" )
                else
                    removeBuff( "alter_time" )                   
                    if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
                end
            end,

            copy = 342247,
        },


        arcane_barrage = {
            id = 44425,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236205,

            -- velocity = 24, -- ignore this, bc charges are consumed on cast.

            handler = function ()
                if level > 51 then gain( 0.02 * mana.max * arcane_charges.current, "mana" ) end

                spend( arcane_charges.current, "arcane_charges" )
                removeBuff( "arcane_harmony" )

                if talent.chrono_shift.enabled then
                    applyBuff( "chrono_shift_buff" )
                    applyDebuff( "target", "chrono_shift" )
                end
            end,
        },


        arcane_blast = {
            id = 30451,
            cast = function () 
                if buff.presence_of_mind.up then return 0 end
                return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
                if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
                return mana.modmax * mult
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 135735,

            handler = function ()
                if buff.presence_of_mind.up then
                    removeStack( "presence_of_mind" )
                    if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
                end
                removeBuff( "rule_of_threes" )
                removeStack( "nether_precision" )
                if arcane_charges.current < arcane_charges.max then gain( 1, "arcane_charges" ) end
            end,
        },


        arcane_explosion = {
            id = 1449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

            spend = function ()
                if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
                return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 136116,

            usable = function () return not state.spec.arcane or target.distance < 10, "target out of range" end,
            handler = function ()
                if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                else removeStack( "clearcasting" ) end
                gain( 1, "arcane_charges" )
            end,
        },


        summon_arcane_familiar = {
            id = 205022,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,
            texture = 1041232,

            nobuff = "arcane_familiar",
            essential = true,

            handler = function ()
                if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
                applyBuff( "arcane_familiar" )
            end,

            copy = "arcane_familiar"
        },


        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        arcane_missiles = {
            id = 5143,
            cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                return buff.clearcasting.up and 0 or 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            start = function ()
                if buff.rule_of_threes.up then removeBuff( "rule_of_threes" )
                else
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeStack( "clearcasting" ) end
                end

                if conduit.arcane_prodigy.enabled and cooldown.arcane_power.remains > 0 then
                    reduceCooldown( "arcane_power", conduit.arcane_prodigy.mod * 0.1 )
                end

                if legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 5 ) end
            end,

            auras = {
                arcane_harmony = {
                    id = 332777,
                    duration = 3600,
                    max_stack = 30
                }
            }
        },


        arcane_orb = {
            id = 153626,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 1033906,

            talent = "arcane_orb",

            handler = function ()
                gain( 1, "arcane_charges" )
                applyBuff( "arcane_orb" )
            end,
        },


        arcane_power = {
            id = 12042,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",
            nobuff = "arcane_power", -- don't overwrite a free proc.

            startsCombat = true,
            texture = 136048,

            handler = function ()
                applyBuff( "arcane_power" )
                if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
                start_burn_phase()
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or nil end,
            cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 end,
            recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 ) or nil ) end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if conduit.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
            end,

            copy = { 212653, 1953, "shimmer", "blink_any" },

            auras = {
                tempest_barrier = {
                    id = 337299,
                    duration = 15,
                    max_stack = 1
                }
            }
        },
        

        conjure_mana_gem = {
            id = 759,
            cast = 3,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = false,
            texture = 134132,
            
            usable = function ()
                if GetItemCount( 36799 ) ~= 0 or fake_mana_gem then return false, "already has a mana_gem" end
                return true
            end,

            handler = function ()
                fake_mana_gem = true
            end,
        },


        mana_gem = {
            name = "|cff00ccff[Mana Gem]|r",
            known = function ()
                return IsUsableItem( 36799 ) or state.fake_mana_gem
            end,
            cast = 0,
            cooldown = 120,
            gcd = "off",
    
            startsCombat = false,
            texture = 134132,

            item = 36799,
            bagItem = true,
    
            usable = function ()
                if GetItemCount( 36799 ) == 0 and not fake_mana_gem then return false, "requires mana_gem in bags" end
                return true
            end,
    
            readyTime = function ()
                local start, duration = GetItemCooldown( 36799 )            
                return max( 0, start + duration - query_time )
            end,
    
            handler = function ()
                gain( 0.25 * health.max, "health" )
            end,

            copy = "use_mana_gem"
        },


        --[[ shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135739,

            talent = "shimmer",

            handler = function ()
                -- applies shimmer (212653)
            end,
        }, ]]


        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 134029,

            handler = function ()
            end,
        }, ]]


        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end, -- Assume always successful.
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        evocation = {
            id = 12051,
            cast = 6,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,

            start = function ()
                stop_burn_phase()
                applyBuff( "evocation" )
                if azerite.brain_storm.enabled then
                    gain( 2, "arcane_charges" )
                    applyBuff( "brain_storm" ) 
                end

                if legendary.siphon_storm.enabled then
                    applyBuff( "siphon_storm" )
                end
            end,

            tick = function ()
                if legendary.siphon_storm.enabled then
                    addStack( "siphon_storm", nil, 1 )
                end
            end,

            auras = {
                -- Legendary
                siphon_storm = {
                    id = 332934,
                    duration = 30,
                    max_stack = 5
                }
            }
        },


        fire_blast = {
            id = 319836,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            discipline = "fire",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135807,
            
            handler = function ()
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


        frostbolt = {
            id = 116,
            cast = 1.874,
            cooldown = 0,
            gcd = "spell",

            discipline = "frost",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135846,
            
            handler = function ()
                applyDebuff( "target", "chilled" )
            end,
        },


        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            discipline = "frost",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },


        greater_invisibility = {
            id = 110959,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 575584,

            handler = function ()
                applyBuff( "greater_invisibility" )
                if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
            end,

            auras = {
                -- Conduit
                incantation_of_swiftness = {
                    id = 337278,
                    duration = 6,
                    max_stack = 1
                }
            }
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


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            handler = function ()
                applyBuff( "mirror_image", nil, 3 )
            end,
        },


        nether_tempest = {
            id = 114923,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 610471,

            handler = function ()
                applyDebuff( "target", "nether_tempest" )
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        presence_of_mind = {
            id = 205025,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136031,

            nobuff = "presence_of_mind",

            handler = function ()
                applyBuff( "presence_of_mind", nil, level > 53 and 3 or 2 )
            end,
        },


        prismatic_barrier = {
            id = 235450,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,

            spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135991,

            handler = function ()
                applyBuff( "prismatic_barrier" )
            end,
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
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

            spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
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


        slow = {
            id = 31589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136091,

            handler = function ()
                applyDebuff( "target", "slow" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
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

            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
            end,
        },


        supernova = {
            id = 157980,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1033912,

            talent = "supernova",

            handler = function ()
            end,
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },


        touch_of_the_magi = {
            id = 321507,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1033909,
            
            handler = function ()
                applyDebuff( "target", "touch_of_the_magi")
                if level > 45 then gain( 4, "arcane_charges" ) end
            end,
        },


        -- Mage - Kyrian    - 307443 - radiant_spark        (Radiant Spark)
        -- TODO: Increase vulnerability stack on direct damage spells.
        radiant_spark = {
            id = 307443,
            cast = 1.5,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 3565446,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "radiant_spark" )
                applyDebuff( "target", "radiant_spark_vulnerability" )
            end,

            auras = {
                radiant_spark = {
                    id = 307443,
                    duration = 8,
                    max_stack = 1
                },
                radiant_spark_vulnerability = {
                    id = 307454,
                    duration = 8,
                    max_stack = 4
                }
            }
        },

        -- Mage - Necrolord - 324220 - deathborne           (Deathborne)
        deathborne = {
            id = 324220,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3578226,

            toggle = "essences", -- maybe should be cooldowns.

            handler = function ()
                applyBuff( "deathborne" )
            end,

            auras = {
                deathborne = {
                    id = 324220,
                    duration = function () return 20 + ( conduit.gift_of_the_lich.mod * 0.001 ) end,
                    max_stack = 1,
                },
            }
        },

        -- Mage - Night Fae - 314791 - shifting_power       (Shifting Power)
        shifting_power = {
            id = 314791,
            cast = function () return 4 * haste * ( 1 - ( conduit.discipline_of_the_grove.mod * 0.01 ) ) end,
            channeled = true,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3636841,

            toggle = "essences",

            start = function ()
                applyBuff( "shifting_power" )
            end,
            
            tick  = function ()
                -- TODO: Identify which abilities have their CDs reduced.
            end,

            finish = function ()
                removeBuff( "shifting_power" )
            end,

            auras = {
                shifting_power = {
                    id = 314791,
                    duration = function () return 4 * haste * ( 1 - ( conduit.discipline_of_the_grove.mod * 0.01 ) ) end,
                    max_stack = 1,
                },
            }
        },

        -- Mage - Venthyr   - 314793 - mirrors_of_torment   (Mirrors of Torment)
        -- TODO:  Get spell ID of the snare, root, silence.
        mirrors_of_torment = {
            id = 314793,
            cast = 1.5,
            cooldown = 90,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 3565720,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "mirrors_of_torment", nil, 3 )
            end,

            auras = {
                mirrors_of_torment = {
                    id = 314793,
                    duration = 20,
                    max_stack = 3, -- ???
                },
                -- Conduit
                siphoned_malice = {
                    id = 337090,
                    duration = 10,
                    max_stack = 3
                }
            },
        },
    } )


    spec:RegisterSetting( "arcane_info", nil, {
        type = "description",
        name = "The Arcane Mage module treats combat as one of two phases.  The 'Burn' phase begins when you have used Arcane Power and begun aggressively burning mana.  The 'Conserve' phase starts when you've completed a burn phase and used Evocation to refill your mana bar.  This phase is less " ..
            "aggressive with mana expenditure, so that you will be ready when it is time to start another burn phase.",
        width = "full",
        fontSize = "medium",
        order = 1,
    } )

    
    --[[ spec:RegisterSetting( "conserve_mana", 75, { -- NYI
            type = "range",
            name = "Minimum Mana (Conserve Phase)",
            desc = "Specify the amount of mana (%) that should be conserved when conserving mana before a burn phase.",

            min = 25,
            max = 100,
            step = 1,

            width = "full",
            order = 2,
        }
    } ) ]]


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_focused_resolve",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20201016, [[d4eeLdqiku6ruOOlrquvTjc8jku1OiHofjYQiiv6vkunlsu3IGa1Uq8lfkdJc6ysuwgfONrHktJcqxJGKTrHcFJGughbrohbbTocczEkKUNOAFsehKcaluH4HeeWejiQIUibrv4JeeinscIQuNKGuLvsH8scsfntka6MeevLDkr1pjivyOeevjlLGq5PK0uLiDvcsv9vcceJLGOSxr(lsdMuhgAXa9yvnzLCzuBMsFwbJwcNg0QjiQ8AcQzlPBRu7MQFlmCcDCkGwUupxrtxLRdy7IIVtrJxuQZlkz9eeQMpjy)eDQSuPj1fECQCdAObnSmdlZyqkZaAyzguimPEzjYjvr8fgh4KQJBoPAa0p6CsveZQg4kvAsDga9Zj1I7eNcrJn2a8kaajFShBc3av8GH)nAVXMW9pwsfeawpHEEcmPUWJtLBqdnOHLzyzgdszgqdlZGcvsDkYFQCJHbtQfW1I9eysDXZpPAmLAH8HdSuBa0p6S0iJPul0XFbi3sDzgNYsTbn0GgMuRW5ntLMudr25ovAQ8YsLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMEsf)dgEsTchkUjvihWAyZ(LUu5gmvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnzfMUulqQbbSwsd4mnSuXWKBYkmDPwGuVyqaRLCbWxqdl9ky6ghGKvy6jv8py4jvqCGgw61Wx4z6sLBCPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjaIjv8py4j1hRvk(hmCAfoVKAfopQJBoPcpEptxQCdyQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsvmoy4PlvUqLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNub5EYTWqFiDPYngPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjaIjv8py4jvWAelQfOZkDPYfAPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjaIjv8py4jvlSzWAeR0LkxiLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNur)551yL(yTMUu5cHPstQSJGvELgjP(n84gIj1gWzB0dmzbNpuScDSZI(XEJ(IWgiauuKxsTaPgeWAjl48HIvOJDw0p2B0xuBhZJaiMuX)GHNuTWMPGvCEPlvEzgMknPYocw5vAKK63WJBiMuBaNTrpWKHgoRzrHp8RmHnqaOOiVKAbs9gDKi(NuxIulekujv8py4jvBhZJ6rgmDPYlRSuPjv8py4j1nS7ON0WsVO3SFjv2rWkVsJKUu5LzWuPjv8py4j1fJxby0oNuzhbR8kns6sLxMXLknPYocw5vAKK63WJBiMu3OJeX)K6sKAdOHjv8py4j1gxq0p6ueBHtxQ8YmGPstQSJGvELgjP(n84gIjv8py4Kzb0EqFGkgMCt(c0DUc9bPwGup8lsZBe6tPoxQnmPI)bdpP(O)CLI)bdpDPYltOsLMuzhbR8knss9B4XnetQZaOcc9fXc56IgwkynMZypjSJGvELuX)GHNuNfq7b9bQyyYD6sLxMXivAsf)dgEs9cGVGgw6vW0noatQSJGvELgjDPYltOLknPI)bdpPI9JotfdtUtQSJGvELgjDPYltiLknPYocw5vAKK63WJBiMubbSwsd4mnSuXWKBYkm9Kk(hm8KAd4mnSuXWK70LkVmHWuPjv2rWkVsJKu)gECdXKQIs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPE0CPwizOulqQ3OJeX)K6sYLAJHqj1kj1kOGuROuBSs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPE0CPwijusTsjv8py4j1n6iDG3PlvUbnmvAsLDeSYR0ij1VHh3qmP2aoBJEGjhVfJgRutSfjSbcaff5vsf)dgEs9GBMAITy6sLBWYsLMuzhbR8knss9B4XnetQlgeWAjxa8f0WsVcMUXbibquQfi1lgeWAjxa8f0WsVcMUXbiP5nc9PupAUudcyTeXMNS)mnS0n0xKnMnDE4lSul0vQX)GHtW(rNPGvCEeoB(boMEWnNuX)GHNufBEY(Z0Ws3qFLUu5g0GPstQSJGvELgjP(n84gIj1vCKgxq0p6ueBHjnVrOpL6sKAHsQvqbPEXGawlPXfe9JofXwyAgGQZnccRWllY8WxyPUeP2WKk(hm8Kk2p6mfSIZlDPYnOXLknPYocw5vAKK63WJBiMubbSwIyZt2FMgw6g6lcGOulqQxmiG1sUa4lOHLEfmDJdqcGOulqQxmiG1sUa4lOHLEfmDJdqsZBe6tPE0CPg)dgob7hDMcwX5r4S5h4y6b3Csf)dgEsf7hDMcwX5LUu5g0aMknPYocw5vAKK63WJBiMubbSwc2p6mvmm5Maik1cKAqaRLG9JotfdtUjnVrOpL6rZL6HFj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68Wx4Kk(hm8Kk2p6mfe7gh40Lk3GcvQ0Kk7iyLxPrsQ4FWWtQy)OZ0nCoHvEMu)ce6j1YsQFdpUHysDXGawl5cGVGgw6vW0noajaIsTaP(Wk7hb7hDMYFrqyhbR8sQfi1GawlzX4vagTZKvy6sTaPEXGawl5cGVGgw6vW0noajnVrOpL6sKA8py4eSF0z6goNWkpjC28dCm9GBoDPYnOXivAsLDeSYR0ijv8py4jvSF0z6goNWkptQFbc9KAzj1VHh3qmPccyTKVYy)48G(aPz8V0Lk3GcTuPjv2rWkVsJKu)gECdXKkiG1sW(rNPFb2dmzE4lSupAUuBqPwGuROu)ruxHPtW(rNPIHj3KM3i0NsDjsDzgk1kOGuJ)bZWu25nKNs9O5sTbLALsQ4FWWtQy)OZ0ObtxQCdkKsLMuzhbR8knss9B4XnetQGawlPbCMgwQyyYnbquQvqbPEJose)tQlrQltOsQ4FWWtQy)OZuWkoV0Lk3GcHPstQSJGvELgjPI)bdpPYzIhpy4jvOFC3aIhfAtQB0rI4FLKlKeQKk0pUBaXJc3BEbXJtQLLu)gECdXKkiG1sAaNPHLkgMCtwHPNUu5gNHPstQ4FWWtQy)OZuqSBCGtQSJGvELgjDPlPYZj7pptLMkVSuPjv2rWkVsJKu)gECdXK6hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGudcyTeSF0z6xG9atMh(cl1JMl1guQfi1Fe1vy6eSF0zQyyYnP5nc9PupAUup8lPwbfK6d7b(ihCZ0lOlil1Jk1Fe1vy6eSF0zQyyYnP5nc9zsf)dgEsfSgXIgw6vWu25DwPlvUbtLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gk1cKAfLAJvQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsDj5sTqZqPwjPwjPwGuROuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPUePUmdLAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGudcyTeSF0z6xG9atMh(cl15sTHsTssTssTaPgeWAjnGZ0WsfdtUjRW0LAbs9gDKi(NuxsUuNbBicwzcks3qhUb20n6iv8VKk(hm8KkynIfnS0RGPSZ7SsxQCJlvAsLDeSYR0ij1VHh3qmP(ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnuQfi1Gawlb7hDM(fypWK5HVWs9O5sTbLAbs9hrDfMob7hDMkgMCtAEJqFk1JMl1d)sQvqbP(WEGpYb3m9c6cYs9Os9hrDfMob7hDMkgMCtAEJqFMuX)GHNunJUUYWqN28mC0FoDPYnGPstQSJGvELgjP(n84gIj1pI6kmDc2p6mvmm5M08gH(uQZLAdLAbsTIsTXk1hwz)iSxHdfh78IWocw5LuRGcsTIs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPUKCPwOzOuRKuRKulqQvuQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuxMHsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYgZMop8fwQvsQvqbPwrP(JOUctNCbWxqdl9ky6ghGKM3i0NsDUuBOulqQbbSwc2p6m9lWEGjZdFHL6CP2qPwjPwjPwGudcyTKgWzAyPIHj3Kvy6sTaPEJose)tQljxQZGnebRmbfPBOd3aB6gDKk(xsf)dgEs1m66kddDAZZWr)50LkxOsLMuzhbR8knss9B4XnetQFe1vy6Kla(cAyPxbt34aK08gH(uQZLAdLAbsniG1sW(rNPFb2dmzE4lSupAUuBqPwGu)ruxHPtW(rNPIHj3KM3i0Ns9O5s9WVKAfuqQpSh4JCWntVGUGSupQu)ruxHPtW(rNPIHj3KM3i0Njv8py4j1baSxq0PHLIcX5oUI0Lk3yKknPYocw5vAKK63WJBiMu)iQRW0jy)OZuXWKBsZBe6tPoxQnuQfi1kk1gRuFyL9JWEfouCSZlc7iyLxsTcki1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6sYLAHMHsTssTssTaPwrPwrP(JOUctNCbWxqdl9ky6ghGKM3i0NsDjsDzgk1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68WxyPwjPwbfKAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTHsTaPgeWAjy)OZ0Va7bMmp8fwQZLAdLALKALKAbsniG1sAaNPHLkgMCtwHPl1cK6n6ir8pPUKCPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4j1baSxq0PHLIcX5oUI0LkxOLknPYocw5vAKKk(hm8K6h(Z(14XlQTIBoP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQfi1B0rYb3m9c6gZwQljxQ5S5h4y6b3CsTcDM(RKQXiDPYfsPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQfi1B0rYb3m9c6gZwQljxQ5S5h4y6b3Csf)dgEsTzue6duBf38mDPYfctLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMEsf)dgEs1gpWKxuuio3WJPGmUtxQ8YmmvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnzfMUulqQbbSwsd4mnSuXWKBYkmDPwGuVyqaRLCbWxqdl9ky6ghGKvy6jv8py4jvrGgAZc6duWkoV0LkVSYsLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMEsf)dgEsTHIIvMcD6ueFoDPYlZGPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpPEfmfWbdaFrTr)C6sLxMXLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MSctxQfi1GawlPbCMgwQyyYnzfMUulqQxmiG1sUa4lOHLEfmDJdqYkm9Kk(hm8K6M3rNfnS0kWdx0vZ4EMU0Lu74WdgEQ0u5LLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KAzj1VHh3qmPccyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJztNh(cl1cKAJvQbbSwsduzAyPxrZ8Kaik1cK6d7b(ihCZ0lOlil1JMl1kk1kk1B0rPEmPg)dgob7hDMcwX5r(yEsTssTqxPg)dgob7hDMcwX5r4S5h4y6b3SuRusnd2uh3Cs1cDSsbbApDPYnyQ0Kk7iyLxPrsQFdpUHysDXGawlPXfe9JofXwyAgGQZnccRWllY8WxyPoxQxmiG1sACbr)OtrSfMMbO6CJGWk8YISXSPZdFHLAbsTIsniG1sW(rNPIHj3Kvy6sTcki1Gawlb7hDMkgMCtAEJqFk1JMl1d)sQvsQfi1kk1GawlPbCMgwQyyYnzfMUuRGcsniG1sAaNPHLkgMCtAEJqFk1JMl1d)sQvkPI)bdpPI9JotbXUXboDPYnUuPjv2rWkVsJKu)gECdXK6kosJli6hDkITWKM3i0NsDjsTqj1kOGuVyqaRL04cI(rNIylmndq15gbHv4LfzE4lSuxIuBysf)dgEsf7hDMcwX5LUu5gWuPjv2rWkVsJKu)gECdXKkiG1seBEY(Z0Ws3qFraeLAbs9IbbSwYfaFbnS0RGPBCasaeLAbs9IbbSwYfaFbnS0RGPBCasAEJqFk1JMl14FWWjy)OZuWkopcNn)ahtp4MtQ4FWWtQy)OZuWkoV0LkxOsLMuzhbR8knssf)dgEsf7hDMUHZjSYZK6xGqpPwws9B4XnetQlgeWAjxa8f0WsVcMUXbibquQfi1hwz)iy)OZu(lcc7iyLxsTaPgeWAjlgVcWODMSctxQfi1kk1lgeWAjxa8f0WsVcMUXbiP5nc9PuxIuJ)bdNG9Jot3W5ew5jHZMFGJPhCZsTcki1Fe1vy6eXMNS)mnS0n0xKM3i0NsDjsTHsTcki1FKHD0pIWz1q0LALsxQCJrQ0Kk7iyLxPrsQFdpUHysfeWAjFLX(X5b9bsZ4FsTaPgeWAjC2IOV4fvmo2piwjaIjv8py4jvSF0z6goNWkptxQCHwQ0Kk7iyLxPrsQ4FWWtQy)OZ0nCoHvEMu)ce6j1YsQFdpUHysfeWAjFLX(X5b9bsZ4FsTaPwrPgeWAjy)OZuXWKBcGOuRGcsniG1sAaNPHLkgMCtaeLAfuqQxmiG1sUa4lOHLEfmDJdqsZBe6tPUePg)dgob7hDMUHZjSYtcNn)ahtp4MLALsxQCHuQ0Kk7iyLxPrsQ4FWWtQy)OZ0nCoHvEMu)ce6j1YsQFdpUHysfeWAjFLX(X5b9bsZ4FsTaPgeWAjFLX(X5b9bY8WxyPoxQbbSwYxzSFCEqFGSXSPZdFHtxQCHWuPjv2rWkVsJKuX)GHNuX(rNPB4CcR8mP(fi0tQLLu)gECdXKkiG1s(kJ9JZd6dKMX)KAbsniG1s(kJ9JZd6dKM3i0Ns9O5sTIsTIsniG1s(kJ9JZd6dK5HVWsTqxPg)dgob7hDMUHZjSYtcNn)ahtp4MLALK6XL6HFj1kLUu5LzyQ0Kk7iyLxPrsQFdpUHysvrPUzBZZceSYsTcki1gRuFWxyOpi1kj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68WxyPwGudcyTeSF0zQyyYnzfMUulqQxmiG1sUa4lOHLEfmDJdqYkm9Kk(hm8KQZxb30J3I88sxQ8YklvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl1JMl1gmPI)bdpPI9JotJgmDPYlZGPstQSJGvELgjP(n84gIj1n6ir8pPE0CPwiuOKAbsniG1sW(rNPIHj3Kvy6sTaPgeWAjnGZ0WsfdtUjRW0LAbs9IbbSwYfaFbnS0RGPBCaswHPNuX)GHNuNaIC7rgmDPYlZ4sLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMUulqQ)iQRW0jCM4XdgoP5nc9PuxIuBOulqQ)iQRW0jy)OZuXWKBsZBe6tPUeP2qPwGu)ruxHPtUa4lOHLEfmDJdqsZBe6tPUeP2qPwGuROuBSs9Hv2psd4mnSuXWKBc7iyLxsTcki1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPUeP2qPwjPwPKk(hm8K6SaApOpqfdtUtxQ8YmGPstQSJGvELgjP(n84gIjvqaRL0avMgw6v0mpjaIsTaPgeWAjy)OZ0Va7bMmp8fwQlrQnUKk(hm8Kk2p6mfSIZlDPYltOsLMuzhbR8knss9B4XnetQB0rI4Fs9OsDgSHiyLjGy34at3OJuX)KAbs9hrDfMoHZepEWWjnVrOpL6sKAdLAbsniG1sW(rNPIHj3Kvy6sTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYgZMop8fwQfi18CY(ZKmWjmCAyPICB5)GHt2qp6Kk(hm8Kk2p6mfe7gh40LkVmJrQ0Kk7iyLxPrsQFdpUHys9JOUctNCbWxqdl9ky6ghGKM3i0NsDUuBOulqQvuQ)iQRW0jnGZ0WsfdtUjnVrOpL6CP2qPwbfK6pI6kmDc2p6mvmm5M08gH(uQZLAdLALKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lCsf)dgEsf7hDMcIDJdC6sLxMqlvAsLDeSYR0ij1VHh3qmPUrhjI)j1JMl1zWgIGvMaIDJdmDJosf)tQfi1Gawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMUulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLAbs9hrDfMoHZepEWWjnVrOpL6sKAdtQ4FWWtQy)OZuqSBCGtxQ8YesPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2y205HVWsTaP(Wk7hb7hDMgniHDeSYlPwGu)ruxHPtW(rNPrdsAEJqFk1JMl1d)sQfi1B0rI4Fs9O5sTqOHsTaP(JOUctNWzIhpy4KM3i0NsDjsTHjv8py4jvSF0zki2noWPlvEzcHPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjaIsTaPgeWAjy)OZuXWKBsZBe6tPE0CPE4xsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYgZMop8foPI)bdpPI9JotbXUXboDPYnOHPstQSJGvELgjP(n84gIjvqaRL0aotdlvmm5Maik1cKAqaRL0aotdlvmm5M08gH(uQhnxQh(LulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHtQ4FWWtQy)OZuqSBCGtxQCdwwQ0Kk(hm8Kk2p6mfSIZlPYocw5vAK0Lk3GgmvAsf6h3nG4rH2K6gDKi(xj5cjHkPc9J7gq8OW9Mxq84KAzjv8py4jvot84bdpPYocw5vAK0Lk3GgxQ0Kk(hm8Kk2p6mfe7gh4Kk7iyLxPrsx6sQFe1vy6ZuPPYllvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnzfMUulqQbbSwsd4mnSuXWKBYkmDPwGuVyqaRLCbWxqdl9ky6ghGKvy6jv8py4j1kCO4MuHCaRHn7x6sLBWuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3Kvy6sTaPgeWAjnGZ0WsfdtUjRW0LAbs9IbbSwYfaFbnS0RGPBCaswHPNuX)GHNubXbAyPxdFHNPlvUXLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNuFSwP4FWWPv48sQv48OoU5Kk849mDPYnGPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjaIjv8py4jvX4GHNUu5cvQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsfK7j3cd9H0Lk3yKknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNubRrSOwGoR0LkxOLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNuTWMbRrSsxQCHuQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsf9NNxJv6J1A6sLleMknPYocw5vAKK63WJBiMuBaNTrpWKHgoRzrHp8RmHnqaOOiVKAbs9hrDfMob7hDMkgMCtAEJqFk1Li1gNHsTaP(JOUctNCbWxqdl9ky6ghGKM3i0NsDUuBOulqQvuQbbSwc2p6m9lWEGjZdFHL6rZLAdk1cKAfLAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsDjsDgSHiyLjxCB6gZMU4kMLuRKuRGcsTIsTXk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDc2p6mvmm5M08gH(uQlrQZGnebRm5IBt3y20fxXSKALKAfuqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTssTsjv8py4jvBhZJ6rgmDPYlZWuPjv2rWkVsJKu)gECdXKAd4Sn6bMm0Wznlk8HFLjSbcaff5LulqQ)iQRW0jy)OZuXWKBsZBe6tPoxQnuQfi1kk1gRuFyL9JWEfouCSZlc7iyLxsTcki1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6sYLAHMHsTssTssTaPwrPwrP(JOUctNCbWxqdl9ky6ghGKM3i0NsDjsDzgk1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68WxyPwjPwbfKAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTHsTaPgeWAjy)OZ0Va7bMmp8fwQZLAdLALKALKAbsniG1sAaNPHLkgMCtwHPl1cK6n6ir8pPUKCPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4jvBhZJ6rgmDPYlRSuPjv2rWkVsJKu)gECdXKAd4Sn6bMSGZhkwHo2zr)yVrFrydeakkYlPwGu)ruxHPtabSw6coFOyf6yNf9J9g9fPzCLLulqQbbSwYcoFOyf6yNf9J9g9f12X8iRW0LAbsTIsniG1sW(rNPIHj3Kvy6sTaPgeWAjnGZ0WsfdtUjRW0LAbs9IbbSwYfaFbnS0RGPBCaswHPl1kj1cK6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTHsTaPwrPgeWAjy)OZ0Va7bMmp8fwQhnxQnOulqQvuQvuQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6KgWzAyPIHj3KM3i0Ns9O5s9WVKAbs9hrDfMob7hDMkgMCtAEJqFk1Li1zWgIGvMCXTPBmB6IRywsTssTcki1kk1gRuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jy)OZuXWKBsZBe6tPUePod2qeSYKlUnDJztxCfZsQvsQvqbP(JOUctNG9JotfdtUjnVrOpL6rZL6HFj1kj1kLuX)GHNuTDmpWOEPlvEzgmvAsLDeSYR0ij1VHh3qmP2aoBJEGjl48HIvOJDw0p2B0xe2abGII8sQfi1Fe1vy6eqaRLUGZhkwHo2zr)yVrFrAgxzj1cKAqaRLSGZhkwHo2zr)yVrFrTWMjRW0LAbsTyZzOd)IugX2X8aJ6LuX)GHNuTWMPGvCEPlvEzgxQ0Kk7iyLxPrsQFdpUHys9JOUctNCbWxqdl9ky6ghGKM3i0NsDUuBOulqQbbSwc2p6m9lWEGjZdFHL6rZLAdk1cK6pI6kmDc2p6mvmm5M08gH(uQhnxQh(vsf)dgEsDd7o6jnS0l6n7x6sLxMbmvAsLDeSYR0ij1VHh3qmP(ruxHPtW(rNPIHj3KM3i0NsDUuBOulqQvuQnwP(Wk7hH9kCO4yNxe2rWkVKAfuqQvuQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1LKl1cndLALKALKAbsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6sK6mydrWktqr6gZMU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAqaRLG9Jot)cShyY8WxyPoxQnuQvsQvsQfi1GawlPbCMgwQyyYnzfMUulqQ3OJeX)K6sYL6mydrWktqr6g6WnWMUrhPI)LuX)GHNu3WUJEsdl9IEZ(LUu5LjuPstQSJGvELgjP(n84gIj1pI6kmDYfaFbnS0RGPBCasAEJqFk15sTHsTaPgeWAjy)OZ0Va7bMmp8fwQhnxQnOulqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xjv8py4j1fJxby0oNUu5LzmsLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gk1cKAfLAJvQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsDj5sTqZqPwjPwjPwGuROuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPUePUmdLAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGudcyTeSF0z6xG9atMh(cl15sTHsTssTssTaPgeWAjnGZ0WsfdtUjRW0LAbs9gDKi(NuxsUuNbBicwzcks3qhUb20n6iv8VKk(hm8K6IXRamANtxQ8YeAPstQSJGvELgjP(n84gIj1pI6kmDYfaFbnS0RGPBCasAEJqFk1Li1zWgIGvM0t6gZMU4kMLulqQ)iQRW0jy)OZuXWKBsZBe6tPUePod2qeSYKEs3y20fxXSKAbsTIs9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctN0aotdlvmm5M08gH(uQhnxQh(LuRGcs9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctN0aotdlvmm5M08gH(uQlrQZGnebRmPN0nMnDXvmlPwbfKAJvQpSY(rAaNPHLkgMCtyhbR8sQvsQfi1Gawlb7hDM(fypWK5HVWsDjsTbLAbs9IbbSwYfaFbnS0RGPBCaswHPNuX)GHNuBCbr)OtrSfoDPYltiLknPYocw5vAKK63WJBiMu)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAqaRLG9Jot)cShyY8WxyPE0CP2GsTaP(JOUctNG9JotfdtUjnVrOpL6rZL6HFLuX)GHNuBCbr)OtrSfoDPYltimvAsLDeSYR0ij1VHh3qmP(ruxHPtW(rNPIHj3KM3i0NsDUuBOulqQvuQvuQnwP(Wk7hH9kCO4yNxe2rWkVKAfuqQvuQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1LKl1cndLALKALKAbsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6sK6mydrWktqr6gZMU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAqaRLG9Jot)cShyY8WxyPoxQnuQvsQvsQfi1GawlPbCMgwQyyYnzfMUulqQ3OJeX)K6sYL6mydrWktqr6g6WnWMUrhPI)j1kLuX)GHNuBCbr)OtrSfoDPYnOHPstQSJGvELgjP(n84gIjvqaRLG9Jot)cShyY8WxyPE0CP2GsTaP(Wk7hPbCMgwQyyYnHDeSYlPwGu)ruxHPtAaNPHLkgMCtAEJqFk1JMl1d)sQfi1Fe1vy6eSF0zQyyYnP5nc9PuxIuNbBicwzYf3MUXSPlUIzj1cK6pYWo6hr4SAi6sTaP(JOUctN04cI(rNIylmP5nc9PupAUulKsQ4FWWtQxa8f0WsVcMUXby6sLBWYsLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWs9O5sTbLAbs9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctN0aotdlvmm5M08gH(uQhnxQh(LulqQ)iQRW0jy)OZuXWKBsZBe6tPUePod2qeSYKlUnDJztxCfZsQfi1gRu)rg2r)icNvdrpPI)bdpPEbWxqdl9ky6ghGPlvUbnyQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQhnxQnOulqQnwP(Wk7hPbCMgwQyyYnHDeSYlPwGu)ruxHPtW(rNPIHj3KM3i0NsDjsDgSHiyLjxCB6gZMU4kMvsf)dgEs9cGVGgw6vW0noatxQCdACPstQSJGvELgjP(n84gIjvqaRLG9Jot)cShyY8WxyPE0CP2GsTaP(JOUctNG9JotfdtUjnVrOpL6rZL6HFLuX)GHNuVa4lOHLEfmDJdW0Lk3GgWuPjv2rWkVsJKu)gECdXKQIsTXk1hwz)iSxHdfh78IWocw5LuRGcsTIs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPUKCPwOzOuRKuRKulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuNbBicwzcks3y20fxXSKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lSulqQbbSwsd4mnSuXWKBYkmDPwGuVrhjI)j1LKl1zWgIGvMGI0n0HBGnDJosf)lPI)bdpPI9JotfdtUtxQCdkuPstQSJGvELgjP(n84gIjvqaRL0aotdlvmm5MSctxQfi1Fe1vy6Kla(cAyPxbt34aK08gH(uQlrQZGnebRmPdr6gZMU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLAbsTIs9hrDfMob7hDMkgMCtAEJqFk1Li1LjusTcki1lgeWAjxa8f0WsVcMUXbibquQvkPI)bdpP2aotdlvmm5oDPYnOXivAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl15sTHsTaP(JmSJ(reoRgIEsf)dgEsvS5j7ptdlDd9v6sLBqHwQ0Kk7iyLxPrsQFdpUHysDXGawl5cGVGgw6vW0noajaIsTaP2yL6pYWo6hr4SAi6jv8py4jvXMNS)mnS0n0xPlvUbfsPstQSJGvELgjP(n84gIj1pI6kmDcNjE8GHtAEJqFk1Li1gk1cKAfLAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9O5sTqYqPwGuVrhjI)j1LKl1gdHsQvsQvqbPwrP2yL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9O5sTqsOKALKALsQ4FWWtQB0r6aVtx6sQl2Ia1lvAQ8YsLMuzhbR8knss9B4XnetQh2d8rwmiG1sECEqFG0m(xsf)dgEs9da)4EkY1A6sLBWuPjv2rWkVsJKuX)GHNuFSwP4FWWPv48sQv48OoU5KkpNS)8mDPYnUuPjv2rWkVsJKu)gECdXKk(hmdtzN3qEk1Li1gmPI)bdpP(yTsX)GHtRW5LuRW5rDCZjvm40Lk3aMknPYocw5vAKK63WJBiMuZGnebRmPaZW0qKDEj15sTHjv8py4j1hRvk(hmCAfoVKAfopQJBoPgISZD6sLluPstQSJGvELgjPI)bdpP(yTsX)GHtRW5LuRW5rDCZj1pI6km9z6sLBmsLMuzhbR8knss9B4XnetQzWgIGvMyHowPGaTl15sTHjv8py4j1hRvk(hmCAfoVKAfopQJBoP2XHhm80LkxOLknPYocw5vAKK63WJBiMuZGnebRmXcDSsbbAxQZL6YsQ4FWWtQpwRu8py40kCEj1kCEuh3Cs1cDSsbbApDPYfsPstQSJGvELgjPI)bdpP(yTsX)GHtRW5LuRW5rDCZj1DKH3SFPlDjvXM)ydIxQ0u5LLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQHj1mytDCZjvXMfbQvkNjsxQCdMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KAzj1VHh3qmP2aoBJEGjtOyr405f9MWgiauuKxsTaPg)dMHPSZBipL6sKAdMuZGn1XnNufBweOwPCMiDPYnUuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNullP(n84gIj1gWzB0dmzcflcNoVO3e2abGII8sQfi1FKHD0pIZFh1OxsTaPg)dMHPSZBipL6sK6YsQzWM64MtQInlcuRuotKUu5gWuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNullP(n84gIj1gWzB0dmzcflcNoVO3e2abGII8sQfi1FKHD0pIdhkoQf5KAgSPoU5KQyZIa1kLZePlvUqLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQHj1mytDCZjvl0XkfeO90Lk3yKknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQqLuZGn1XnNu7jDJztxCfZkDPYfAPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwMHj1mytDCZjvuKUXSPlUIzLUu5cPuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNunOHj1mytDCZj1oePBmB6IRywPlvUqyQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQcvsnd2uh3Cs9IBt3y20fxXSsxQ8YmmvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvJlP(n84gIj1gWzB0dmzbNpuScDSZI(XEJ(IWgiauuKxj1mytDCZj1lUnDJztxCfZkDPYlRSuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNultOsQFdpUHys9JmSJ(rC4qXrTiNuZGn1XnNuV420nMnDXvmR0LkVmdMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KAzcvs9B4XnetQF4la4rW(rNPIDSGdzryhbR8sQfi14FWmmLDEd5PupQuBCj1mytDCZj1lUnDJztxCfZkDPYlZ4sLMuzhbR8knssnetQt(sQ4FWWtQzWgIGvoPMbRaCs14mmP(n84gIjvEoz)zsg4egonSurUT8FWWjBOhDsnd2uh3Cs9IBt3y20fxXSsxQ8YmGPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPkeAysnd2uh3Csfe7ghy6gDKk(x6sLxMqLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQqYWK63WJBiMu)id7OFehouCulYj1mytDCZjvqSBCGPB0rQ4FPlvEzgJuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNunodtQzWM64MtQOiDdD4gyt3OJuX)sxQ8YeAPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPkugMu)gECdXKAd4Sn6bMSGZhkwHo2zr)yVrFrydeakkYRKAgSPoU5Kkks3qhUb20n6iv8V0LkVmHuQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQcLHj1VHh3qmP2aoBJEGjdnCwZIcF4xzcBGaqrrELuZGn1XnNurr6g6WnWMUrhPI)LUu5LjeMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQbtQzWM64MtQyW0lUn9lWEGNPlvUbnmvAsf)dgEsDcS3HtX(rNPwCdRqStQSJGvELgjDPYnyzPstQ4FWWtQy)OZuOFCTY)LuzhbR8kns6sLBqdMknPI)bdpP(HlKdOz6gDKoW7Kk7iyLxPrsxQCdACPstQ4FWWtQBy3rtHBCGtQSJGvELgjDPYnObmvAsLDeSYR0ij1VHh3qmPMbBicwzIyZIa1kLZesDUuBOulqQBaNTrpWKfC(qXk0Xol6h7n6lcBGaqrrEj1cK6pI6kmDciG1sxW5dfRqh7SOFS3OVinJRSKAbsniG1swW5dfRqh7SOFS3OVO2oMhzfMEsf)dgEs12X8aJ6LUu5guOsLMuzhbR8knss9B4XnetQzWgIGvMi2SiqTs5mHuNl1LLuX)GHNu5mXJhm80LUKkgCQ0u5LLknPYocw5vAKK63WJBiMuvuQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1JMl1cjdLAbs9gDKi(NuxsUuBmekPwjPwbfKAfLAJvQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1JMl1cjHsQvkPI)bdpPUrhPd8oDPYnyQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBYkm9Kk(hm8KAfouCtQqoG1WM9lDPYnUuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3Kvy6jv8py4jvqCGgw61Wx4z6sLBatLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQpwRu8py40kCEj1kCEuh3CsfE8EMUu5cvQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsvmoy4PlvUXivAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpPcY9KBHH(q6sLl0sLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQG1iwulqNv6sLlKsLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQwyZG1iwPlvUqyQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsf9NNxJv6J1A6sLxMHPstQSJGvELgjP(n84gIj1gWzB0dm54Ty0yLAITiHnqaOOiVKAbsTIs9mQHuRGcsniG1s4SlqG5bdNaik1kLuX)GHNup4MPMylMUu5LvwQ0Kk7iyLxPrsQFdpUHysTbC2g9atwW5dfRqh7SOFS3OViSbcaff5LulqQ)iQRW0jGawlDbNpuScDSZI(XEJ(I0mUYsQfi1GawlzbNpuScDSZI(XEJ(IA7yEKvy6sTaPwrPgeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0LALKAbs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGuROudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cKAfLAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsDjsDgSHiyLjxCB6gZMU4kMLuRKuRGcsTIsTXk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDc2p6mvmm5M08gH(uQlrQZGnebRm5IBt3y20fxXSKALKAfuqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTssTsjv8py4jvBhZdmQx6sLxMbtLMuzhbR8knss9B4XnetQkk1nGZ2OhyYcoFOyf6yNf9J9g9fHnqaOOiVKAbs9hrDfMobeWAPl48HIvOJDw0p2B0xKMXvwsTaPgeWAjl48HIvOJDw0p2B0xulSzYkmDPwGul2Cg6WViLrSDmpWOEsTssTcki1kk1nGZ2OhyYcoFOyf6yNf9J9g9fHnqaOOiVKAbs9b3SuNl1gk1kLuX)GHNuTWMPGvCEPlvEzgxQ0Kk7iyLxPrsQFdpUHysTbC2g9atgA4SMff(WVYe2abGII8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuxIuBCgk1cK6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTHsTaPwrPgeWAjy)OZ0Va7bMmp8fwQhnxQZGnebRmbdMEXTPFb2d8uQfi1kk1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPE0CPE4xsTaP(JOUctNG9JotfdtUjnVrOpL6sK6mydrWktU420nMnDXvmlPwjPwbfKAfLAJvQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuxIuNbBicwzYf3MUXSPlUIzj1kj1kOGu)ruxHPtW(rNPIHj3KM3i0Ns9O5s9WVKALKALsQ4FWWtQ2oMh1Jmy6sLxMbmvAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcBGaqrrEj1cK6pI6kmDc2p6mvmm5M08gH(uQZLAdLAbsTIsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6sK6mydrWktqr6gZMU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwjPwjPwGudcyTKgWzAyPIHj3Kvy6sTsjv8py4jvBhZJ6rgmDPYltOsLMuzhbR8knss9B4XnetQnGZ2OhyYekweoDErVjSbcaff5LulqQfBodD4xKYiCM4XdgEsf)dgEs9cGVGgw6vW0noatxQ8YmgPstQSJGvELgjP(n84gIj1gWzB0dmzcflcNoVO3e2abGII8sQfi1kk1InNHo8lszeot84bdxQvqbPwS5m0HFrkJCbWxqdl9ky6ghGsTsjv8py4jvSF0zQyyYD6sLxMqlvAsLDeSYR0ij1VHh3qmPEWnl1Li1gNHsTaPUbC2g9atMqXIWPZl6nHnqaOOiVKAbsniG1sW(rNPFb2dmzE4lSupAUuNbBicwzcgm9IBt)cSh4PulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cK6pI6kmDc2p6mvmm5M08gH(uQhnxQh(vsf)dgEsLZepEWWtxQ8YesPstQSJGvELgjPI)bdpPYzIhpy4jvOFC3aIhfAtQGawlzcflcNoVO3K5HVW5GawlzcflcNoVO3KnMnDE4lCsf6h3nG4rH7nVG4Xj1YsQFdpUHys9GBwQlrQnodLAbsDd4Sn6bMmHIfHtNx0BcBGaqrrEj1cK6pI6kmDc2p6mvmm5M08gH(uQZLAdLAbsTIsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6sK6mydrWktqr6gZMU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXSPZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwjPwjPwGudcyTKgWzAyPIHj3Kvy6sTsPlvEzcHPstQSJGvELgjP(n84gIjvfL6pI6kmDc2p6mvmm5M08gH(uQlrQnGcLuRGcs9hrDfMob7hDMkgMCtAEJqFk1JMl1gNuRKulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gk1cKAfLAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwGuROuROuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jnGZ0WsfdtUjnVrOpL6rZL6HFj1cK6pI6kmDc2p6mvmm5M08gH(uQlrQfkPwjPwbfKAfLAJvQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuxIulusTssTcki1Fe1vy6eSF0zQyyYnP5nc9PupAUup8lPwjPwPKk(hm8K6g2D0tAyPx0B2V0Lk3GgMknPYocw5vAKK63WJBiMu)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuNbBicwzspPBmB6IRywsTaP(JOUctNG9JotfdtUjnVrOpL6sK6mydrWkt6jDJztxCfZsQfi1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPE0CPE4xsTcki1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPUePod2qeSYKEs3y20fxXSKAfuqQnwP(Wk7hPbCMgwQyyYnHDeSYlPwjPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpP24cI(rNIylC6sLBWYsLMuzhbR8knss9B4XnetQFe1vy6Kla(cAyPxbt34aK08gH(uQZLAdLAbsTIsniG1sW(rNPFb2dmzE4lSupAUuNbBicwzcgm9IBt)cSh4PulqQvuQvuQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6KgWzAyPIHj3KM3i0Ns9O5s9WVKAbs9hrDfMob7hDMkgMCtAEJqFk1Li1zWgIGvMCXTPBmB6IRywsTssTcki1kk1gRuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jy)OZuXWKBsZBe6tPUePod2qeSYKlUnDJztxCfZsQvsQvqbP(JOUctNG9JotfdtUjnVrOpL6rZL6HFj1kj1kLuX)GHNuBCbr)OtrSfoDPYnObtLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gk1cKAfLAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1Li1zWgIGvMGI0nMnDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJztNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnuQfi1Gawlb7hDM(fypWK5HVWs9O5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfdtUjRW0LALsQ4FWWtQnUGOF0Pi2cNUu5g04sLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gk1cKAfLAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1Li1zWgIGvMGI0nMnDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJztNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnuQfi1Gawlb7hDM(fypWK5HVWs9O5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfdtUjRW0LALsQ4FWWtQlgVcWODoDPYnObmvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cKAfLAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsDjsDgSHiyLjxCB6gZMU4kMLuRKuRGcsTIsTXk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDc2p6mvmm5M08gH(uQlrQZGnebRm5IBt3y20fxXSKALKAfuqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTsjv8py4j1la(cAyPxbt34amDPYnOqLknPYocw5vAKK63WJBiMuvuQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuNbBicwzcks3y20fxXSKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1kj1kj1cKAqaRL0aotdlvmm5MSctpPI)bdpPI9JotfdtUtxQCdAmsLMuzhbR8knss9B4XnetQGawlPbCMgwQyyYnzfMUulqQvuQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuBqdLAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnMnDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2qPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1kj1kj1cKAfL6pI6kmDc2p6mvmm5M08gH(uQlrQltOKAfuqQxmiG1sUa4lOHLEfmDJdqcGOuRusf)dgEsTbCMgwQyyYD6sLBqHwQ0Kk7iyLxPrsQFdpUHysfeWAjlgVcWODMaik1cK6fdcyTKla(cAyPxbt34aKaik1cK6fdcyTKla(cAyPxbt34aK08gH(uQhnxQbbSwIyZt2FMgw6g6lYgZMop8fwQf6k14FWWjy)OZuWkopcNn)ahtp4MtQ4FWWtQInpz)zAyPBOVsxQCdkKsLMuzhbR8knss9B4XnetQGawlzX4vagTZearPwGuROuROuFyL9J08mC0FMWocw5LulqQX)Gzyk78gYtPEuP2ak1kj1kOGuJ)bZWu25nKNs9OsTqj1kLuX)GHNuX(rNPGvCEPlvUbfctLMuX)GHNuNaIC7rgmPYocw5vAK0Lk34mmvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl15sTHjv8py4jvSF0zA0GPlvUXvwQ0Kk7iyLxPrsQFdpUHysvrPUzBZZceSYsTcki1gRuFWxyOpi1kj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68Wx4Kk(hm8KQZxb30J3I88sxQCJZGPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQfi1Fe1vy6eSF0zQyyYnP5nc9PuxIuBOulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuxIuBOulqQvuQnwP(Wk7hPbCMgwQyyYnHDeSYlPwbfKAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PuxIuBOuRKuRusf)dgEsDwaTh0hOIHj3PlvUXzCPstQSJGvELgjP(n84gIjvqaRL8vg7hNh0hinJ)j1cK6gWzB0dmb7hDMcDl0Hxwe2abGII8sQfi1hwz)i4wScTWhpy4e2rWkVKAbsn(hmdtzN3qEk1Jk1gJKk(hm8Kk2p6mDdNtyLNPlvUXzatLMuzhbR8knss9B4XnetQGawl5Rm2popOpqAg)tQfi1nGZ2Ohyc2p6mf6wOdVSiSbcaff5LulqQX)Gzyk78gYtPEuP2aMuX)GHNuX(rNPB4CcR8mDPYnoHkvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl1Jk1Gawlb7hDM(fypWKnMnDE4lCsf)dgEsf7hDMYzlwJjm80Lk34mgPstQSJGvELgjP(n84gIjvqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBmB68WxyPwGul2Cg6WViLrW(rNPGy34aNuX)GHNuX(rNPC2I1ycdpDPYnoHwQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYgZMop8foPI)bdpPI9JotbXUXboDPYnoHuQ0Kk0pUBaXJcTj1n6ir8VsYfscvsf6h3nG4rH7nVG4Xj1YsQ4FWWtQCM4XdgEsLDeSYR0iPlDjv4X7zQ0u5LLknPI)bdpPcmzk849mPYocw5vAK0LUK6oYWB2VuPPYllvAsLDeSYR0ij1VHh3qmPUJm8M9JSGZd9NL6sYL6YmmPI)bdpPcwHUWPlvUbtLMuX)GHNufBEY(Z0Ws3qFLuzhbR8kns6sLBCPstQSJGvELgjP(n84gIj1DKH3SFKfCEO)SupQuxMHjv8py4jvSF0z6goNWkptxQCdyQ0Kk(hm8Kk2p6mnAWKk7iyLxPrsxQCHkvAsf)dgEs1cBMcwX5LuzhbR8kns6sxs1cDSsbbApvAQ8YsLMuzhbR8knssf)dgEsf7hDMUHZjSYZK6xGqpPwws9B4XnetQGawl5Rm2popOpqAg)lDPYnyQ0Kk(hm8Kk2p6mfSIZlPYocw5vAK0Lk34sLMuX)GHNuX(rNPGy34aNuzhbR8kns6sx6sQz4EcdpvUbn0GgwMHLzatQMy7qFyMufcIbGqSYf6vUqqfIKAPU0cwQHBXOpP2gTuB8DC4bd34L6MnqayZlPEgBwQrGl24XlP(lqFGNePrgGqNL6YeIKAHaHNH7JxsTkCleqQNz5hMTulKFP(cP2aeaL6fmdCcdxQdrUXlAPwXXusQvSSSvIinYae6SulucrsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kww2krKgjnsiigacXkxOx5cbvisQL6slyPgUfJ(KAB0sTXl28hBq8mEPUzdea28sQNXMLAe4InE8sQ)c0h4jrAKbi0zP24eIKAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvSSSvIinYae6SuBafIKAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvSSSvIinYae6SuxwzcrsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kww2krKgzacDwQltOeIKAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvSSSvIinsAKqqmaeIvUqVYfcQqKul1LwWsnClg9j12OLAJ)JOUctFA8sDZgiaS5LupJnl1iWfB84Lu)fOpWtI0idqOZsTbnuisQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYYwjI0idqOZsTbltisQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYYwjI0idqOZsTbngcrsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kww2krKgzacDwQnOqtisQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYYwjI0iPrc92IrF8sQlZqPg)dgUuxHZBsKgLuf7WcRCs1yk1c5dhyP2aOF0zPrgtPwOJ)cqUL6Ymgkl1g0qdAO0iPr4FWWNeXM)ydIxEgSHiyLv2XnNl2SiqTs5mHYHy(KpLZGvao3qPr4FWWNeXM)ydI345JLbBicwzLDCZ5InlcuRuotOCiMp5t5myfGZltzOnVbC2g9atMqXIWPZl6nHnqaOOiVeG)bZWu25nKNLyqPr4FWWNeXM)ydI345JLbBicwzLDCZ5InlcuRuotOCiMp5t5myfGZltzOnVbC2g9atMqXIWPZl6nHnqaOOiVe8rg2r)io)DuJEryhbR8sa(hmdtzN3qEwszsJW)GHpjIn)XgeVXZhld2qeSYk74MZfBweOwPCMq5qmFYNYzWkaNxMYqBEd4Sn6bMmHIfHtNx0BcBGaqrrEj4JmSJ(rC4qXrTityhbR8sAKXuQX)GHpjIn)XgeVXZhld2qeSYk74MZlWmmnezNxkhI5t(uodwb4CdLgzmLA8py4tIyZFSbXB88XYGnebRSYoU58cmdtdr25LYHy(KpLZGvaoVmLH2C8pygMYoVH8SedknYyk14FWWNeXM)ydI345JLbBicwzLDCZ5fygMgISZlLdX8jFkNbRaCEzkdT5zWgIGvMi2SiqTs5mrEzsJW)GHpjIn)XgeVXZhld2qeSYk74MZTqhRuqG2voeZN8PCgScW5gknc)dg(Ki28hBq8gpFSmydrWkRSJBoVN0nMnDXvmlLdX8jFkNbRaCUqjnc)dg(Ki28hBq8gpFSmydrWkRSJBohfPBmB6IRywkhI5t(uodwb48YmuAe(hm8jrS5p2G4nE(yzWgIGvwzh3CEhI0nMnDXvmlLdX8jFkNbRaCUbnuAe(hm8jrS5p2G4nE(yzWgIGvwzh3C(f3MUXSPlUIzPCiMp5t5myfGZfkPr4FWWNeXM)ydI345JLbBicwzLDCZ5xCB6gZMU4kMLYHy(KpLZGvao34ugAZBaNTrpWKfC(qXk0Xol6h7n6lcBGaqrrEjnc)dg(Ki28hBq8gpFSmydrWkRSJBo)IBt3y20fxXSuoeZN8PCgScW5LjukdT5FKHD0pIdhkoQfzc7iyLxsJW)GHpjIn)XgeVXZhld2qeSYk74MZV420nMnDXvmlLdX8jFkNbRaCEzcLYqB(h(caEeSF0zQyhl4qwe2rWkVeG)bZWu25nKNJACsJmMs9iwdaPwiyPwigVJmSuBaIh3sJW)GHpjIn)XgeVXZhld2qeSYk74MZV420nMnDXvmlLdX8jFkNbRaCUXzOYqBopNS)mjdCcdNgwQi3w(py4Kn0JwAe(hm8jrS5p2G4nE(yzWgIGvwzh3Coi2noW0n6iv8pLdX8jFkNbRaCUqOHsJW)GHpjIn)XgeVXZhld2qeSYk74MZbXUXbMUrhPI)PCiMp5t5myfGZfsgQm0M)rg2r)ioCO4OwKjSJGvEjnc)dg(Ki28hBq8gpFSmydrWkRSJBohfPBOd3aB6gDKk(NYHy(KpLZGvao34muAe(hm8jrS5p2G4nE(yzWgIGvwzh3Coks3qhUb20n6iv8pLdX8jFkNbRaCUqzOYqBEd4Sn6bMSGZhkwHo2zr)yVrFrydeakkYlPr4FWWNeXM)ydI345JLbBicwzLDCZ5OiDdD4gyt3OJuX)uoeZN8PCgScW5cLHkdT5nGZ2OhyYqdN1SOWh(vMWgiauuKxsJW)GHpjIn)XgeVXZhld2qeSYk74MZXGPxCB6xG9apvoeZN8PCgScW5guAe(hm8jrS5p2G4nE(yy)OZulUHvi2sJW)GHpjIn)XgeVXZhd7hDMc9JRv(pPr4FWWNeXM)ydI345J9HlKdOz6gDKoWBPr4FWWNeXM)ydI345JTHDhnfUXbwAe(hm8jrS5p2G4nE(y2oMhyupLH28mydrWkteBweOwPCMi3qbnGZ2OhyYcoFOyf6yNf9J9g9fHnqaOOiVe8ruxHPtabSw6coFOyf6yNf9J9g9fPzCLLaqaRLSGZhkwHo2zr)yVrFrTDmpYkmDPr4FWWNeXM)ydI345JXzIhpy4kdT5zWgIGvMi2SiqTs5mrEzsJKgzmLAH8iB(boEj1CgUZsQp4ML6RGLA8VOLA4uQXmiSIGvMinc)dg(m)da)4EkY1QYqB(H9aFKfdcyTKhNh0hinJ)jnYyk1JynaKAHGLAHy8oYWsTbiEClnc)dg(C88XESwP4FWWPv48u2XnNZZj7ppLgH)bdFoE(ypwRu8py40kCEk74MZXGvgAZX)Gzyk78gYZsmO0i8py4ZXZh7XALI)bdNwHZtzh3CEiYo3kdT5zWgIGvMuGzyAiYoVYnuAe(hm8545J9yTsX)GHtRW5PSJBo)JOUctFknc)dg(C88XESwP4FWWPv48u2XnN3XHhmCLH28mydrWktSqhRuqG2ZnuAe(hm8545J9yTsX)GHtRW5PSJBo3cDSsbbAxzOnpd2qeSYel0XkfeO98YKgH)bdFoE(ypwRu8py40kCEk74MZ3rgEZ(jnsAe(hm8jbdohyY0n6iDG3kdT5kEyL9JWEfouCSZlc7iyLxc2OJeX)gnxizOGn6ir8VsYngcLskOGIg7Hv2pc7v4qXXoViSJGvEjyJose)B0CHKqPK0i8py4tcg845JvHdf3KkKdynSz)ugAZbbSwc2p6mvmm5MSctxAe(hm8jbdE88XaXbAyPxdFHNkdT5Gawlb7hDMkgMCtwHPlnc)dg(KGbpE(ypwRu8py40kCEk74MZHhVNkdT5Gawlb7hDMkgMCtaeLgH)bdFsWGhpFmX4GHRm0MdcyTeSF0zQyyYnbquAe(hm8jbdE88Xa5EYTWqFqzOnheWAjy)OZuXWKBcGO0i8py4tcg845JbwJyrTaDwkdT5Gawlb7hDMkgMCtaeLgH)bdFsWGhpFmlSzWAelLH2CqaRLG9JotfdtUjaIsJW)GHpjyWJNpg6ppVgR0hRvLH2CqaRLG9JotfdtUjaIsJW)GHpjyWJNp2b3m1eBrLH28gWzB0dm54Ty0yLAITiHnqaOOiVeO4mQHckacyTeo7ceyEWWjaIkjnc)dg(KGbpE(y2oMhyupLH28gWzB0dmzbNpuScDSZI(XEJ(IWgiauuKxc(iQRW0jGawlDbNpuScDSZI(XEJ(I0mUYsaiG1swW5dfRqh7SOFS3OVO2oMhzfMUafbbSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0vsWhrDfMo5cGVGgw6vW0noajnVrOpZnuGIGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4Pafv8Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NJMp8lbFe1vy6eSF0zQyyYnP5nc9zjzWgIGvMCXTPBmB6IRywkPGckAShwz)inGZ0WsfdtUjSJGvEj4JOUctNG9JotfdtUjnVrOpljd2qeSYKlUnDJztxCfZsjfu4JOUctNG9JotfdtUjnVrOphnF4xkPK0i8py4tcg845JzHntbR48ugAZvSbC2g9atwW5dfRqh7SOFS3OViSbcaff5LGpI6kmDciG1sxW5dfRqh7SOFS3OVinJRSeacyTKfC(qXk0Xol6h7n6lQf2mzfMUaXMZqh(fPmITJ5bg1tjfuqXgWzB0dmzbNpuScDSZI(XEJ(IWgiauuKxco4MZnujPr4FWWNem4XZhZ2X8OEKbvgAZBaNTrpWKHgoRzrHp8RmHnqaOOiVe8ruxHPtW(rNPIHj3KM3i0NLyCgk4JOUctNCbWxqdl9ky6ghGKM3i0N5gkqrqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8uGIkEyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZrZh(LGpI6kmDc2p6mvmm5M08gH(SKmydrWktU420nMnDXvmlLuqbfn2dRSFKgWzAyPIHj3e2rWkVe8ruxHPtW(rNPIHj3KM3i0NLKbBicwzYf3MUXSPlUIzPKck8ruxHPtW(rNPIHj3KM3i0NJMp8lLusAe(hm8jbdE88XSDmpQhzqLH28gWzB0dmzOHZAwu4d)ktydeakkYlbFe1vy6eSF0zQyyYnP5nc9zUHcuurf)iQRW0jxa8f0WsVcMUXbiP5nc9zjzWgIGvMGI0nMnDXvmlbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSskOGIFe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4PskjaeWAjnGZ0WsfdtUjRW0vsAKXuQlvOdH8uOdHiPwiqLrxQbeL6RGNSuRQk1CMqQRqNNsJW)GHpjyWJNp2faFbnS0RGPBCaQm0M3aoBJEGjtOyr405f9MWgiauuKxceBodD4xKYiCM4XdgU0i8py4tcg845JH9JotfdtUvgAZBaNTrpWKjuSiC68IEtydeakkYlbkk2Cg6WViLr4mXJhmCfuqS5m0HFrkJCbWxqdl9ky6ghGkjnc)dg(KGbpE(yCM4XdgUYqB(b3CjgNHcAaNTrpWKjuSiC68IEtydeakkYlbGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4PGpI6kmDYfaFbnS0RGPBCasAEJqFMBOGpI6kmDc2p6mvmm5M08gH(C08HFjnc)dg(KGbpE(yCM4XdgUYqB(b3CjgNHcAaNTrpWKjuSiC68IEtydeakkYlbFe1vy6eSF0zQyyYnP5nc9zUHcuurf)iQRW0jxa8f0WsVcMUXbiP5nc9zjzWgIGvMGI0nMnDXvmlbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSskOGIFe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4PskjaeWAjnGZ0WsfdtUjRW0vszOFC3aIhfAZbbSwYekweoDErVjZdFHZbbSwYekweoDErVjBmB68WxyLH(XDdiEu4EZliECEzsJW)GHpjyWJNp2g2D0tAyPx0B2pLH2Cf)iQRW0jy)OZuXWKBsZBe6ZsmGcLck8ruxHPtW(rNPIHj3KM3i0NJMBCkj4JOUctNCbWxqdl9ky6ghGKM3i0N5gkqrqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8uGIkEyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZrZh(LGpI6kmDc2p6mvmm5M08gH(SeHsjfuqrJ9Wk7hPbCMgwQyyYnHDeSYlbFe1vy6eSF0zQyyYnP5nc9zjcLskOWhrDfMob7hDMkgMCtAEJqFoA(WVusjPr4FWWNem4XZhRXfe9JofXwyLH28pI6kmDYfaFbnS0RGPBCasAEJqFwsgSHiyLj9KUXSPlUIzj4JOUctNG9JotfdtUjnVrOpljd2qeSYKEs3y20fxXSeO4Hv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xkOWHv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOpljd2qeSYKEs3y20fxXSuqbJ9Wk7hPbCMgwQyyYnHDeSYlLeacyTeSF0z6xG9atMh(cpAEgSHiyLjyW0lUn9lWEGNcwmiG1sUa4lOHLEfmDJdqYkmDPr4FWWNem4XZhRXfe9JofXwyLH28pI6kmDYfaFbnS0RGPBCasAEJqFMBOafbbSwc2p6m9lWEGjZdFHhnpd2qeSYemy6f3M(fypWtbkQ4Hv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xc(iQRW0jy)OZuXWKBsZBe6ZsYGnebRm5IBt3y20fxXSusbfu0ypSY(rAaNPHLkgMCtyhbR8sWhrDfMob7hDMkgMCtAEJqFwsgSHiyLjxCB6gZMU4kMLskOWhrDfMob7hDMkgMCtAEJqFoA(WVusjPr4FWWNem4XZhRXfe9JofXwyLH28pI6kmDc2p6mvmm5M08gH(m3qbkQOIFe1vy6Kla(cAyPxbt34aK08gH(SKmydrWktqr6gZMU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYgZMop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBOaqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8ujLeacyTKgWzAyPIHj3Kvy6kjnc)dg(KGbpE(ylgVcWODwzOn)JOUctNG9JotfdtUjnVrOpZnuGIkQ4hrDfMo5cGVGgw6vW0noajnVrOpljd2qeSYeuKUXSPlUIzjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXSPZdFHvsbfu8JOUctNCbWxqdl9ky6ghGKM3i0N5gkaeWAjy)OZ0Va7bMmp8fE08mydrWktWGPxCB6xG9apvsjbGawlPbCMgwQyyYnzfMUssJW)GHpjyWJNp2faFbnS0RGPBCaQm0MdcyTeSF0z6xG9atMh(cpAEgSHiyLjyW0lUn9lWEGNcuuXdRSFKgWzAyPIHj3e2rWkVe8ruxHPtAaNPHLkgMCtAEJqFoA(WVe8ruxHPtW(rNPIHj3KM3i0NLKbBicwzYf3MUXSPlUIzPKckOOXEyL9J0aotdlvmm5MWocw5LGpI6kmDc2p6mvmm5M08gH(SKmydrWktU420nMnDXvmlLuqHpI6kmDc2p6mvmm5M08gH(C08HFPK0i8py4tcg845JH9JotfdtUvgAZvuXpI6kmDYfaFbnS0RGPBCasAEJqFwsgSHiyLjOiDJztxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJztNh(cRKckO4hrDfMo5cGVGgw6vW0noajnVrOpZnuaiG1sW(rNPFb2dmzE4l8O5zWgIGvMGbtV420Va7bEQKscabSwsd4mnSuXWKBYkmDPr4FWWNem4XZhRbCMgwQyyYTYqBoiG1sAaNPHLkgMCtwHPlqrf)iQRW0jxa8f0WsVcMUXbiP5nc9zjg0qbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSskOGIFe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4PskjqXpI6kmDc2p6mvmm5M08gH(SKYekfuyXGawl5cGVGgw6vW0noajaIkjnc)dg(KGbpE(yInpz)zAyPBOVugAZbbSwYIXRamANjaIcwmiG1sUa4lOHLEfmDJdqcGOGfdcyTKla(cAyPxbt34aK08gH(C0CqaRLi28K9NPHLUH(ISXSPZdFHf6I)bdNG9JotbR48iC28dCm9GBwAe(hm8jbdE88XW(rNPGvCEkdT5GawlzX4vagTZearbkQ4Hv2psZZWr)zc7iyLxcW)Gzyk78gYZrnGkPGc4FWmmLDEd55OcLssJW)GHpjyWJNp2eqKBpYGsJW)GHpjyWJNpg2p6mnAqLH2CqaRLG9Jot)cShyY8Wx4CdLgH)bdFsWGhpFmNVcUPhVf55Pm0MRyZ2MNfiyLvqbJ9GVWqFqjbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lS0i8py4tcg845JnlG2d6duXWKBLH2CqaRLG9JotfdtUjRW0facyTKgWzAyPIHj3Kvy6cwmiG1sUa4lOHLEfmDJdqYkmDbFe1vy6eSF0zQyyYnP5nc9zjgk4JOUctNCbWxqdl9ky6ghGKM3i0NLyOafn2dRSFKgWzAyPIHj3e2rWkVuqbfpSY(rAaNPHLkgMCtyhbR8sWhrDfMoPbCMgwQyyYnP5nc9zjgQKssJW)GHpjyWJNpg2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)tqd4Sn6bMG9JotHUf6WllcBGaqrrEj4Wk7hb3IvOf(4bdNWocw5La8pygMYoVH8CuJH0i8py4tcg845JH9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)e0aoBJEGjy)OZuOBHo8YIWgiauuKxcW)Gzyk78gYZrnGsJW)GHpjyWJNpg2p6mLZwSgty4kdT5Gawlb7hDM(fypWK5HVWJccyTeSF0z6xG9at2y205HVWsJW)GHpjyWJNpg2p6mLZwSgty4kdT5Gawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSaXMZqh(fPmc2p6mfe7ghyPr4FWWNem4XZhd7hDMcIDJdSYqBoiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJztNh(clnc)dg(KGbpE(yCM4XdgUYq)4Ubepk0MVrhjI)vsUqsOug6h3nG4rH7nVG4X5LjnsAe(hm8j5JOUctFMxHdf3KkKdynSz)ugAZbbSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0LgH)bdFs(iQRW0NJNpgioqdl9A4l8uzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8j5JOUctFoE(ypwRu8py40kCEk74MZHhVNkdT5Gawlb7hDMkgMCtaeLgH)bdFs(iQRW0NJNpMyCWWvgAZbbSwc2p6mvmm5Maiknc)dg(K8ruxHPphpFmqUNClm0hugAZbbSwc2p6mvmm5Maiknc)dg(K8ruxHPphpFmWAelQfOZszOnheWAjy)OZuXWKBcGO0i8py4tYhrDfM(C88XSWMbRrSugAZbbSwc2p6mvmm5Maiknc)dg(K8ruxHPphpFm0FEEnwPpwRkdT5Gawlb7hDMkgMCtaeLgzmLAH8QHrdpOqCwQbMqFqQhA4SMLudF4xzP2eEfsnksKAH(twQHNuBcVcP(IBl1XvWTjCYePwAe(hm8j5JOUctFoE(y2oMh1JmOYqBEd4Sn6bMm0Wznlk8HFLjSbcaff5LGpI6kmDc2p6mvmm5M08gH(SeJZqbFe1vy6Kla(cAyPxbt34aK08gH(m3qbkccyTeSF0z6xG9atMh(cpAUbfOOIhwz)inGZ0WsfdtUjSJGvEj4JOUctN0aotdlvmm5M08gH(C08HFj4JOUctNG9JotfdtUjnVrOpljd2qeSYKlUnDJztxCfZsjfuqrJ9Wk7hPbCMgwQyyYnHDeSYlbFe1vy6eSF0zQyyYnP5nc9zjzWgIGvMCXTPBmB6IRywkPGcFe1vy6eSF0zQyyYnP5nc95O5d)sjLKgH)bdFs(iQRW0NJNpMTJ5r9idQm0M3aoBJEGjdnCwZIcF4xzcBGaqrrEj4JOUctNG9JotfdtUjnVrOpZnuGIg7Hv2pc7v4qXXoViSJGvEPGckEyL9JWEfouCSZlc7iyLxc2OJeX)kjxOzOskjqrf)iQRW0jxa8f0WsVcMUXbiP5nc9zjLzOaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYgZMop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBOaqaRLG9Jot)cShyY8Wx4CdvsjbGawlPbCMgwQyyYnzfMUGn6ir8VsYZGnebRmbfPBOd3aB6gDKk(N0i8py4tYhrDfM(C88XSDmpWOEkdT5nGZ2OhyYcoFOyf6yNf9J9g9fHnqaOOiVe8ruxHPtabSw6coFOyf6yNf9J9g9fPzCLLaqaRLSGZhkwHo2zr)yVrFrTDmpYkmDbkccyTeSF0zQyyYnzfMUaqaRL0aotdlvmm5MSctxWIbbSwYfaFbnS0RGPBCaswHPRKGpI6kmDYfaFbnS0RGPBCasAEJqFMBOafbbSwc2p6m9lWEGjZdFHhn3GcuuXdRSFKgWzAyPIHj3e2rWkVe8ruxHPtAaNPHLkgMCtAEJqFoA(WVe8ruxHPtW(rNPIHj3KM3i0NLKbBicwzYf3MUXSPlUIzPKckOOXEyL9J0aotdlvmm5MWocw5LGpI6kmDc2p6mvmm5M08gH(SKmydrWktU420nMnDXvmlLuqHpI6kmDc2p6mvmm5M08gH(C08HFPKssJW)GHpjFe1vy6ZXZhZcBMcwX5Pm0M3aoBJEGjl48HIvOJDw0p2B0xe2abGII8sWhrDfMobeWAPl48HIvOJDw0p2B0xKMXvwcabSwYcoFOyf6yNf9J9g9f1cBMSctxGyZzOd)IugX2X8aJ6jnYyk1gavtmRPudmzPEd7o6PuBcVcPgfjsTqpRuFXTLA4uQBgxzj14uQn5AvzPEJcZs9eOzP(cP(X5j1WtQbzB0SuFXTjsJW)GHpjFe1vy6ZXZhBd7o6jnS0l6n7NYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnuaiG1sW(rNPFb2dmzE4l8O5guWhrDfMob7hDMkgMCtAEJqFoA(WVKgH)bdFs(iQRW0NJNp2g2D0tAyPx0B2pLH28pI6kmDc2p6mvmm5M08gH(m3qbkAShwz)iSxHdfh78IWocw5LckO4Hv2pc7v4qXXoViSJGvEjyJose)RKCHMHkPKafv8JOUctNCbWxqdl9ky6ghGKM3i0NLKbBicwzcks3y20fxXSeacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2y205HVWkPGck(ruxHPtUa4lOHLEfmDJdqsZBe6ZCdfacyTeSF0z6xG9atMh(cNBOskjaeWAjnGZ0WsfdtUjRW0fSrhjI)vsEgSHiyLjOiDdD4gyt3OJuX)KgzmLAdGQjM1uQbMSuVy8kaJ2zP2eEfsnksKAHEwP(IBl1WPu3mUYsQXPuBY1QYs9gfML6jqZs9fs9JZtQHNudY2OzP(IBtKgH)bdFs(iQRW0NJNp2IXRamANvgAZ)iQRW0jxa8f0WsVcMUXbiP5nc9zUHcabSwc2p6m9lWEGjZdFHhn3Gc(iQRW0jy)OZuXWKBsZBe6ZrZh(L0i8py4tYhrDfM(C88XwmEfGr7SYqB(hrDfMob7hDMkgMCtAEJqFMBOafn2dRSFe2RWHIJDEryhbR8sbfu8Wk7hH9kCO4yNxe2rWkVeSrhjI)vsUqZqLusGIk(ruxHPtUa4lOHLEfmDJdqsZBe6ZskZqbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSskOGIFe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVW5gQKscabSwsd4mnSuXWKBYkmDbB0rI4FLKNbBicwzcks3qhUb20n6iv8pPrgtPwO)KL6Pi2cl1qRuFXTLA0xsnkk1yZsD4s9VKA0xsTz4g)j1GSudik12OL6A4dCl1xb6s9vWs9gZwQxCfZszPEJcd9bPEc0SuBYsDbMHLA8K6kJZtQpZqQX(rNL6Va7bEk1OVK6RapP(IBl1M40n(tQfYbmpPgyYlI0i8py4tYhrDfM(C88XACbr)OtrSfwzOn)JOUctNCbWxqdl9ky6ghGKM3i0NLKbBicwzspPBmB6IRywc(iQRW0jy)OZuXWKBsZBe6ZsYGnebRmPN0nMnDXvmlbkEyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZrZh(LckCyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZsYGnebRmPN0nMnDXvmlfuWypSY(rAaNPHLkgMCtyhbR8sjbGawlb7hDM(fypWK5HVWLyqblgeWAjxa8f0WsVcMUXbizfMU0iJPul0FYs9ueBHLAt4vi1OOuBwWUulgZjeSYePwONvQV42snCk1nJRSKACk1MCTQSuVrHzPEc0SuFHu)48KA4j1GSnAwQV42ePr4FWWNKpI6km9545J14cI(rNIylSYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnuaiG1sW(rNPFb2dmzE4l8O5guWhrDfMob7hDMkgMCtAEJqFoA(WVKgH)bdFs(iQRW0NJNpwJli6hDkITWkdT5Fe1vy6eSF0zQyyYnP5nc9zUHcuurJ9Wk7hH9kCO4yNxe2rWkVuqbfpSY(ryVchko25fHDeSYlbB0rI4FLKl0mujLeOOIFe1vy6Kla(cAyPxbt34aK08gH(SKmydrWktqr6gZMU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYgZMop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBOaqaRLG9Jot)cShyY8Wx4CdvsjbGawlPbCMgwQyyYnzfMUGn6ir8VsYZGnebRmbfPBOd3aB6gDKk(NssJmMsTqNz1q0fIKAH(twQV42sn0k1OOudNsD4s9VKA0xsTz4g)j1GSudik12OL6A4dCl1xb6s9vWs9gZwQxCfZIi1gav4Gl1MWRqQ7quQHwP(kyP(Wk7NudNs9HcZorQfY7OUKAuQbHNuFHuVrHzPEc0SuBYs9JUuletvQH7nVG4X1SKA0ECl1xCBPM91uAe(hm8j5JOUctFoE(yxa8f0WsVcMUXbOYqBoiG1sW(rNPFb2dmzE4l8O5guWHv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xc(iQRW0jy)OZuXWKBsZBe6ZsYGnebRm5IBt3y20fxXSe8rg2r)icNvdrNWocw5LGpI6kmDsJli6hDkITWKM3i0NJMlKKgzmL6YdxiyHoZQHOlej1c9NSuFXTLAOvQrrPgoL6WL6Fj1OVKAZWn(tQbzPgquQTrl11Wh4wQVc0L6RGL6nMTuV4kMfrQnaQWbxQnHxHu3HOudTs9vWs9Hv2pPgoL6dfMDI0i8py4tYhrDfM(C88XUa4lOHLEfmDJdqLH2CqaRLG9Jot)cShyY8Wx4rZnOGdRSFKgWzAyPIHj3e2rWkVe8ruxHPtAaNPHLkgMCtAEJqFoA(WVe8ruxHPtW(rNPIHj3KM3i0NLKbBicwzYf3MUXSPlUIzjWy)id7OFeHZQHOtyhbR8sAe(hm8j5JOUctFoE(yxa8f0WsVcMUXbOYqBoiG1sW(rNPFb2dmzE4l8O5guGXEyL9J0aotdlvmm5MWocw5LGpI6kmDc2p6mvmm5M08gH(SKmydrWktU420nMnDXvmlPr4FWWNKpI6km9545JDbWxqdl9ky6ghGkdT5Gawlb7hDM(fypWK5HVWJMBqbFe1vy6eSF0zQyyYnP5nc95O5d)sAKXuQf6pzPgfLAOvQV42snCk1Hl1)sQrFj1MHB8NudYsnGOuBJwQRHpWTuFfOl1xbl1BmBPEXvmlLL6nkm0hK6jqZs9vGNuBYsDbMHLA2dGHcPEJok1OVK6RapP(k4MLA4uQ94KAS2mUYsQrPUbCwQdRulgMCl1RW0jsJW)GHpjFe1vy6ZXZhd7hDMkgMCRm0MROXEyL9JWEfouCSZlc7iyLxkOGIhwz)iSxHdfh78IWocw5LGn6ir8VsYfAgQKsc(iQRW0jxa8f0WsVcMUXbiP5nc9zjzWgIGvMGI0nMnDXvmlbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSaqaRL0aotdlvmm5MSctxWgDKi(xj5zWgIGvMGI0n0HBGnDJosf)tAKXuQf6pzPUdrPgAL6lUTudNsD4s9VKA0xsTz4g)j1GSudik12OL6A4dCl1xb6s9vWs9gZwQxCfZszPEJcd9bPEc0SuFfCZsnC6g)j1yTzCLLuJsDd4SuVctxQrFj1xbEsnkk1MHB8NudYFSzPgZGWkcwzPEb0qFqQBaNjsJW)GHpjFe1vy6ZXZhRbCMgwQyyYTYqBoiG1sAaNPHLkgMCtwHPl4JOUctNCbWxqdl9ky6ghGKM3i0NLKbBicwzshI0nMnDXvmlbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSaf)iQRW0jy)OZuXWKBsZBe6ZsktOuqHfdcyTKla(cAyPxbt34aKaiQK0iJPul0zwneDHiPwiMQudNs9gDuQla8HolPg9LuBamIbCk1yZs9fHuZzlY(eMHL6lKAGjl1IXwQVqQNgiaZcXzPgDPMZ(AuQrqPg6s9vWs9f3wQnH(kmjsTbiFg)uQbMSudpP(cPEJcZsDnmL6Va7bwQnagzk1qFEOFePr4FWWNKpI6km9545Jj28K9NPHLUH(szOnheWAjy)OZ0Va7bMmp8fo3qbFKHD0pIWz1q0jSJGvEjnYyk1LhUqWcDMvdrxisQf6pzPwm2s9fs90abywiol1Ol1C2xJsnck1qxQVcwQV42sTj0xHjrAe(hm8j5JOUctFoE(yInpz)zAyPBOVugAZxmiG1sUa4lOHLEfmDJdqcGOaJ9JmSJ(reoRgIoHDeSYlPr4FWWNKpI6km9545Jbmz6gDKoWBLH28pI6kmDcNjE8GHtAEJqFwIHcuuXdRSFe2RWHIJDEryhbR8sWgDKi(3O5cjdfSrhjI)vsUXqOusbfu0ypSY(ryVchko25fHDeSYlbB0rI4FJMlKekLusAK0iJPupI1aqQfcwQfIX7idl1gG4XT0i8py4tcpNS)8mhSgXIgw6vWu25DwkdT5Fe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVWJMBqbFe1vy6eSF0zQyyYnP5nc95O5d)sbfoSh4JCWntVGUG8OFe1vy6eSF0zQyyYnP5nc9P0i8py4tcpNS)8C88XaRrSOHLEfmLDENLYqB(hrDfMob7hDMkgMCtAEJqFMBOafn2dRSFe2RWHIJDEryhbR8sbfu8Wk7hH9kCO4yNxe2rWkVeSrhjI)vsUqZqLusGIk(ruxHPtUa4lOHLEfmDJdqsZBe6ZskZqbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lSskOGIFe1vy6Kla(cAyPxbt34aK08gH(m3qbGawlb7hDM(fypWK5HVW5gQKscabSwsd4mnSuXWKBYkmDbB0rI4FLKNbBicwzcks3qhUb20n6iv8pPr4FWWNeEoz)5545JzgDDLHHoT5z4O)SYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnuaiG1sW(rNPFb2dmzE4l8O5guWhrDfMob7hDMkgMCtAEJqFoA(WVuqHd7b(ihCZ0lOlip6hrDfMob7hDMkgMCtAEJqFknc)dg(KWZj7pphpFmZORRmm0Pnpdh9NvgAZ)iQRW0jy)OZuXWKBsZBe6ZCdfOOXEyL9JWEfouCSZlc7iyLxkOGIhwz)iSxHdfh78IWocw5LGn6ir8VsYfAgQKscuuXpI6kmDYfaFbnS0RGPBCasAEJqFwszgkaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXSPZdFHvsbfu8JOUctNCbWxqdl9ky6ghGKM3i0N5gkaeWAjy)OZ0Va7bMmp8fo3qLusaiG1sAaNPHLkgMCtwHPlyJose)RK8mydrWktqr6g6WnWMUrhPI)jnc)dg(KWZj7pphpFSbaSxq0PHLIcX5oUcLH28pI6kmDYfaFbnS0RGPBCasAEJqFMBOaqaRLG9Jot)cShyY8Wx4rZnOGpI6kmDc2p6mvmm5M08gH(C08HFPGch2d8ro4MPxqxqE0pI6kmDc2p6mvmm5M08gH(uAe(hm8jHNt2FEoE(ydayVGOtdlffIZDCfkdT5Fe1vy6eSF0zQyyYnP5nc9zUHcu0ypSY(ryVchko25fHDeSYlfuqXdRSFe2RWHIJDEryhbR8sWgDKi(xj5cndvsjbkQ4hrDfMo5cGVGgw6vW0noajnVrOplPmdfacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2y205HVWkPGck(ruxHPtUa4lOHLEfmDJdqsZBe6ZCdfacyTeSF0z6xG9atMh(cNBOskjaeWAjnGZ0WsfdtUjRW0fSrhjI)vsEgSHiyLjOiDdD4gyt3OJuX)KgH)bdFs45K9NNJNp2h(Z(14XlQTIBw5k0z6VYngkdT5Gawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6c2OJKdUz6f0nMDj5C28dCm9GBwAe(hm8jHNt2FEoE(ynJIqFGAR4MNkdT5Gawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6c2OJKdUz6f0nMDj5C28dCm9GBwAe(hm8jHNt2FEoE(y24bM8IIcX5gEmfKXTYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMU0i8py4tcpNS)8C88XebAOnlOpqbR48ugAZbbSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0LgH)bdFs45K9NNJNpwdffRmf60Pi(SYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMU0i8py4tcpNS)8C88XUcMc4GbGVO2OFwzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8jHNt2FEoE(yBEhDw0WsRapCrxnJ7PYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMU0iPr4FWWNel0XkfeO9CSF0z6goNWkpvgAZbbSwYxzSFCEqFG0m(NYFbc98YKgH)bdFsSqhRuqG2hpFmSF0zkyfNN0i8py4tIf6yLcc0(45JH9JotbXUXbwAK0i8py4tc849mhyYu4X7P0iPr4FWWNKDKH3SF5GvOlmf9SugAZ3rgEZ(rwW5H(ZLKxMHsJW)GHpj7idVz)gpFmXMNS)mnS0n0xsJW)GHpj7idVz)gpFmSF0z6goNWkpvgAZ3rgEZ(rwW5H(ZJwMHsJW)GHpj7idVz)gpFmSF0zA0GsJW)GHpj7idVz)gpFmlSzkyfNN0iPrgtPg)dg(KeISZDEgSHiyLv2XnNxGzyAiYoVuoeZN8PCgScW5LPm0Ml2Cg6WViLr4mXJhmCPr4FWWNKqKDUhpFSkCO4MuHCaRHn7NYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMU0i8py4tsiYo3JNpgioqdl9A4l8uzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8jjezN7XZh7XALI)bdNwHZtzh3Co849uzOnheWAjy)OZuXWKBcGO0i8py4tsiYo3JNpMyCWWvgAZbbSwc2p6mvmm5Maiknc)dg(KeISZ945JbY9KBHH(GYqBoiG1sW(rNPIHj3earPr4FWWNKqKDUhpFmWAelQfOZszOnheWAjy)OZuXWKBcGO0i8py4tsiYo3JNpMf2mynILYqBoiG1sW(rNPIHj3earPr4FWWNKqKDUhpFm0FEEnwPpwRkdT5Gawlb7hDMkgMCtaeLgH)bdFscr25E88XSWMPGvCEkdT5nGZ2OhyYcoFOyf6yNf9J9g9fHnqaOOiVeacyTKfC(qXk0Xol6h7n6lQTJ5raeLgH)bdFscr25E88XSDmpQhzqLH28gWzB0dmzOHZAwu4d)ktydeakkYlbB0rI4FLiekusJW)GHpjHi7CpE(yBy3rpPHLErVz)KgH)bdFscr25E88XwmEfGr7S0i8py4tsiYo3JNpwJli6hDkITWkdT5B0rI4FLyanuAe(hm8jjezN7XZh7r)5kf)dgUYqBo(hmCYSaApOpqfdtUjFb6oxH(GGHFrAEJqFMBO0i8py4tsiYo3JNp2SaApOpqfdtUvgAZNbqfe6lIfY1fnSuWAmNXEsyhbR8sAe(hm8jjezN7XZh7cGVGgw6vW0noaLgH)bdFscr25E88XW(rNPIHj3sJW)GHpjHi7CpE(ynGZ0WsfdtUvgAZbbSwsd4mnSuXWKBYkmDPr4FWWNKqKDUhpFmGjt3OJ0bERm0MR4Hv2pc7v4qXXoViSJGvEjyJose)B0CHKHc2OJeX)kj3yiukPGckAShwz)iSxHdfh78IWocw5LGn6ir8VrZfscLssJW)GHpjHi7CpE(yhCZutSfvgAZBaNTrpWKJ3IrJvQj2Ie2abGII8sAe(hm8jjezN7XZhtS5j7ptdlDd9LYqB(IbbSwYfaFbnS0RGPBCasaefSyqaRLCbWxqdl9ky6ghGKM3i0NJMdcyTeXMNS)mnS0n0xKnMnDE4lSqx8py4eSF0zkyfNhHZMFGJPhCZsJW)GHpjHi7CpE(yy)OZuWkopLH28vCKgxq0p6ueBHjnVrOplrOuqHfdcyTKgxq0p6ueBHPzaQo3iiScVSiZdFHlXqPr4FWWNKqKDUhpFmSF0zkyfNNYqBoiG1seBEY(Z0Ws3qFraefSyqaRLCbWxqdl9ky6ghGearblgeWAjxa8f0WsVcMUXbiP5nc95O54FWWjy)OZuWkopcNn)ahtp4MLgH)bdFscr25E88XW(rNPGy34aRm0MdcyTeSF0zQyyYnbquaiG1sW(rNPIHj3KM3i0NJMp8lbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lS0i8py4tsiYo3JNpg2p6mDdNtyLNkdT5lgeWAjxa8f0WsVcMUXbibquWHv2pc2p6mL)IGWocw5LaqaRLSy8kaJ2zYkmDblgeWAjxa8f0WsVcMUXbiP5nc9zj4FWWjy)OZ0nCoHvEs4S5h4y6b3SYFbc98YKgH)bdFscr25E88XW(rNPB4CcR8uzOnheWAjFLX(X5b9bsZ4Fk)fi0ZltAe(hm8jjezN7XZhd7hDMgnOYqBoiG1sW(rNPFb2dmzE4l8O5guGIFe1vy6eSF0zQyyYnP5nc9zjLzOckG)bZWu25nKNJMBqLKgH)bdFscr25E88XW(rNPGvCEkdT5GawlPbCMgwQyyYnbqubf2OJeX)kPmHsAe(hm8jjezN7XZhJZepEWWvgAZbbSwsd4mnSuXWKBYkmDLH(XDdiEuOnFJose)RKCHKqPm0pUBaXJc3BEbXJZltAe(hm8jjezN7XZhd7hDMcIDJdS0iPr4FWWNKoo8GHNNbBicwzLDCZ5wOJvkiq7khI5t(uodwb48YugAZbbSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBmB68WxybgliG1sAGktdl9kAMNearbh2d8ro4MPxqxqE0CfvCJokKF8py4eSF0zkyfNh5J5PKqx8py4eSF0zkyfNhHZMFGJPhCZkjnYyk14FWWNKoo8GHpE(yZRH)rNSbcW(ZkdT5lgeWAjnUGOF0Pi2ctZauDUrqyfEzrMh(cNVyqaRL04cI(rNIylmndq15gbHv4LfzJztNh(claeWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUYoU58kop6ueBHPZdFHfIW(rNPGvCEcry)OZuqSBCGLgH)bdFs64Wdg(45JH9JotbXUXbwzOnFXGawlPXfe9JofXwyAgGQZnccRWllY8Wx48fdcyTKgxq0p6ueBHPzaQo3iiScVSiBmB68WxybkccyTeSF0zQyyYnzfMUckacyTeSF0zQyyYnP5nc95O5d)sjbkccyTKgWzAyPIHj3Kvy6kOaiG1sAaNPHLkgMCtAEJqFoA(WVusAe(hm8jPJdpy4JNpg2p6mfSIZtzOnFfhPXfe9JofXwysZBe6ZsekfuyXGawlPXfe9JofXwyAgGQZnccRWllY8Wx4smuAe(hm8jPJdpy4JNpg2p6mfSIZtzOnheWAjInpz)zAyPBOViaIcwmiG1sUa4lOHLEfmDJdqcGOGfdcyTKla(cAyPxbt34aK08gH(C0C8py4eSF0zkyfNhHZMFGJPhCZsJW)GHpjDC4bdF88XW(rNPB4CcR8uzOnFXGawl5cGVGgw6vW0noajaIcoSY(rW(rNP8xee2rWkVeacyTKfJxby0otwHPlqXfdcyTKla(cAyPxbt34aK08gH(Se8py4eSF0z6goNWkpjC28dCm9GBwbf(iQRW0jInpz)zAyPBOVinVrOplXqfu4JmSJ(reoRgIoHDeSYlLu(lqONxM0i8py4tshhEWWhpFmSF0z6goNWkpvgAZbbSwYxzSFCEqFG0m(NaqaRLWzlI(IxuX4y)GyLaiknc)dg(K0XHhm8XZhd7hDMUHZjSYtLH2CqaRL8vg7hNh0hinJ)jqrqaRLG9JotfdtUjaIkOaiG1sAaNPHLkgMCtaevqHfdcyTKla(cAyPxbt34aK08gH(Se8py4eSF0z6goNWkpjC28dCm9GBwjL)ce65Ljnc)dg(K0XHhm8XZhd7hDMUHZjSYtLH2CqaRL8vg7hNh0hinJ)jaeWAjFLX(X5b9bY8Wx4CqaRL8vg7hNh0hiBmB68WxyL)ce65Ljnc)dg(K0XHhm8XZhd7hDMUHZjSYtLH2CqaRL8vg7hNh0hinJ)jaeWAjFLX(X5b9bsZBe6ZrZvurqaRL8vg7hNh0hiZdFHf6I)bdNG9Jot3W5ew5jHZMFGJPhCZkn(WVus5VaHEEzsJW)GHpjDC4bdF88XC(k4ME8wKNNYqBUInBBEwGGvwbfm2d(cd9bLeacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2y205HVWcabSwc2p6mvmm5MSctxWIbbSwYfaFbnS0RGPBCaswHPlnc)dg(K0XHhm8XZhd7hDMgnOYqBoiG1sW(rNPFb2dmzE4l8O5guAe(hm8jPJdpy4JNp2eqKBpYGkdT5B0rI4FJMlekucabSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0LgH)bdFs64Wdg(45JnlG2d6duXWKBLH2CqaRLG9JotfdtUjRW0facyTKgWzAyPIHj3Kvy6cwmiG1sUa4lOHLEfmDJdqYkmDbFe1vy6eot84bdN08gH(Sedf8ruxHPtW(rNPIHj3KM3i0NLyOGpI6kmDYfaFbnS0RGPBCasAEJqFwIHcu0ypSY(rAaNPHLkgMCtyhbR8sbfu8Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NLyOskjnc)dg(K0XHhm8XZhd7hDMcwX5Pm0MdcyTKgOY0WsVIM5jbquaiG1sW(rNPFb2dmzE4lCjgN0iJPupI1aqQfcwQfIX7idl1gG4XT0i8py4tshhEWWhpFmSF0zki2noWkdT5B0rI4FJMbBicwzci2noW0n6iv8pbFe1vy6eot84bdN08gH(SedfacyTeSF0zQyyYnzfMUaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYgZMop8fwapNS)mjdCcdNgwQi3w(py4Kn0JwAe(hm8jPJdpy4JNpg2p6mfe7ghyLH28pI6kmDYfaFbnS0RGPBCasAEJqFMBOaf)iQRW0jnGZ0WsfdtUjnVrOpZnubf(iQRW0jy)OZuXWKBsZBe6ZCdvsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJztNh(clnc)dg(K0XHhm8XZhd7hDMcIDJdSYqB(gDKi(3O5zWgIGvMaIDJdmDJosf)taiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMUaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYgZMop8fwWhrDfMoHZepEWWjnVrOplXqPr4FWWNKoo8GHpE(yy)OZuqSBCGvgAZbbSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0facyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2y205HVWcoSY(rW(rNPrdsyhbR8sWhrDfMob7hDMgniP5nc95O5d)sWgDKi(3O5cHgk4JOUctNWzIhpy4KM3i0NLyO0i8py4tshhEWWhpFmSF0zki2noWkdT5Gawlb7hDMkgMCtaefacyTeSF0zQyyYnP5nc95O5d)saiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJztNh(clnc)dg(K0XHhm8XZhd7hDMcIDJdSYqBoiG1sAaNPHLkgMCtaefacyTKgWzAyPIHj3KM3i0NJMp8lbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnMnDE4lS0i8py4tshhEWWhpFmSF0zkyfNN0i8py4tshhEWWhpFmot84bdxzOFC3aIhfAZ3OJeX)kjxijukd9J7gq8OW9Mxq848YKgH)bdFs64Wdg(45JH9JotbXUXboPIaxr0jvv4gOIhmCHanAV0LUuca]] )


end
