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

    spec:RegisterSetting( "am_spam", 1, {
        type = "toggle",
        name = "Use |T136096:0|t Arcane Missiles Spam",
        icon = 136096,
        width = "full",
        get = function () return Hekili.DB.profile.specs[ 62 ].settings.am_spam == 1 end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 62 ].settings.am_spam = val and 1 or 0
        end,
        order = 2,
    })

    
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


    spec:RegisterPack( "Arcane", 20201020, [[d0Kc5dqiQkYIiOGhPKqPlrqvPSjc8jQkyuuGtrIAveuu8kLuMfjYTiOQuTle)sjPHrbDmLGLPKONrvHMgbv5AeuABkjKVrqfJJGkDoLe06iOiZtjQ7jf7JQQoOscvlujvpujb8rLekAKeuukNKGQkRKQsVujHcZujb6Meuvs7ujYpjOQedLGIs1sjOOQNsstvj0vjOQQVsqrjJLGcTxQ8xOgmPomyXq8yvnzL6YO2mL(SuA0uLtJ0QjOOYRjiZwQUTc7w0VfgoHoovf1YL8CfnDvUoK2of67u04jbNNQkRNGQI5tcTFI2TGBrN6go2T0knCLgUGHR0qYccpFCL(4k0PE(jYovr4fcAzNAcd2PUIxpKStve8RhW2TOtDgO1ZovV7eNctRUAl98qriFmwDshOD4Or(fyVvN0XVQtfbL2pHFPdXPUHJDlTsdxPHly4knKSGWBLcxFCf5uNI87wAfTsNQhDV50H4u388DQRyLAHVcTSuVIxpKS03vSsTWx(lq4sQxWhvsQxPHR0qNANoVPBrNAiYjxUfDlTGBrNkNasN3U1DQHOtDYNtf(JgPt1iuuaPZovJqhLDQl4u)IECrbNQyXgXT)MSaHngpC0iDQgHcNWGDQEGrghICYB35wALUfDQCciDE7w3P(f94Ico1cnzBuTmztNpvSttO8d)Xya5MW(mkvuK3sTaPgb1AjB68PIDAcLF4pgdi3yBfZJGk6uH)Or6uT0IXiDyEUZTKp6w0PYjG05TBDN6x0Jlk4ul0KTr1YK2Io7(HPp97mH9zuQOiVLAbs9asGi(Nu7VuVcfwNk8hnsNQTI5HZWi4o3scp3Iov4pAKo1bTQOM4WIVOgCEovobKoVDR7o3scRBrNk8hnsN6MHZdjQKDQCciDE7w3DULwrUfDQCciDE7w3P(f94Ico1bKar8pP2FPw4zOtf(JgPtTGnfYdpfHsi35ws44w0PYjG05TBDN6x0Jlk4uH)OrsMEu7rZwSyyYf59Gm5onBLAbsD7VjfpaAoL6gP2qNk8hnsN6d5ZDm8hns35ws46w0PYjG05TBDN6x0Jlk4uNbAhHMBILY9noSyKEmNXys4eq682Pc)rJ0Po9O2JMTyXWKl35wAf6w0Pc)rJ0PEb67Hdl(8y8aAPovobKoVDR7o3slyOBrNk8hnsNkupKmwmm5YPYjG05TBD35wAHfCl6u5eq682TUt9l6XffCQiOwlPqtghwSyyYfzhMPtf(JgPtTqtghwSyyYL7ClTWkDl6uH)Or6uflEY5Z4WIh0C7u5eq682TU7ClTGp6w0PYjG05TBDN6x0Jlk4u3XrkytH8WtrOeIu8aO5uQ9xQfwPwrfL6nJGATKc2uip8uekHWgr7jxacTtp)iZdEHKA)LAdDQWF0iDQq9qYyKomp35wAbHNBrNkNasN3U1DQFrpUOGtfb1AjIfp58zCyXdAUjOIsTaPEZiOwl5c03dhw85X4b0sjOIsTaPEZiOwl5c03dhw85X4b0sjfpaAoL6LBKA4pAKeOEizmshMhHvGF0JXhDWov4pAKovOEizmshMN7ClTGW6w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5IGkk1cKAeuRLa1djJfdtUifpaAoL6LBK62Fl1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiNk8hnsNkupKmgbQcAz35wAHvKBrNkNasN3U1DQWF0iDQq9qY4bDoPDE6uFpGMo1fCQFrpUOGtDZiOwl5c03dhw85X4b0sjOIsTaP(GoNhbQhsgZVxq4eq68wQfi1iOwlzZW5HevYKDyMsTaPEZiOwl5c03dhw85X4b0sjfpaAoLA)LA4pAKeOEiz8GoN0opjSc8JEm(Od2DULwq44w0PYjG05TBDNk8hnsNkupKmEqNtANNo13dOPtDbN6x0Jlk4urqTwY3zOEyE0SLum8N7ClTGW1TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbsTbs9hrFhMjbQhsglgMCrkEa0Ck1(l1lyOuROIsn8h1iJ5KhuEk1l3i1RuQv2Pc)rJ0Pc1djJJcXDULwyf6w0PYjG05TBDN6x0Jlk4urqTwsHMmoSyXWKlcQOuROIs9asGi(Nu7VuVGW6uH)Or6uH6HKXiDyEUZT0kn0TOtLtaPZB36ov4pAKov2y8WrJ0PsZJRcv8WuRtDajqe)Z)gHRW6uP5XvHkEy6yWBkCStDbN6x0Jlk4urqTwsHMmoSyXWKlYomt35wALl4w0Pc)rJ0Pc1djJrGQGw2PYjG05TBD35oNkpNC(80TOBPfCl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQBKAdLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zYf3apafWVhuT8uQfi1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BPwrfLAlT17WfpaAoL6LL6pI(omtcupKmwmm5Iu8aO50Pc)rJ0PI0JyJdl(8ymN8Wp35wALUfDQCciDE7w3P(f94Ico1pI(omtcupKmwmm5Iu8aO5uQBKAdLAbsTbsTpj1h058iC2PTEhN8MWjG05TuROIsTbs9bDopcNDAR3XjVjCciDEl1cK6bKar8pP2)gPw4yOuROIsTrOOasNjWapfHHu3i1li1kl1kl1cKAdKAdK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gHIciDMaI4bOaEZDWpPwGuBGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1kQOuBekkG0zcmWtryi1ns9csTYsTYsTIkk1gi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKAdLAbsncQ1sG6HKXVhuTmzEWlKu3i1gk1kl1kl1cKAeuRLuOjJdlwmm5ISdZuQfi1dibI4FsT)nsTrOOasNjGiEqt6aDGhqcyX)CQWF0iDQi9i24WIppgZjp8ZDUL8r3IovobKoVDR7u)IECrbN6hrFhMjbQhsglgMCrkEa0Ck1(3i1cRHsTaP(JOVdZKCb67Hdl(8y8aAPKIhanNs9YnsD7VLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zYf3apafWVhuT8uQfi1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtPE5gPU93sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpNk8hnsNQzu9TrMM4INrc5ZUZTKWZTOtLtaPZB36o1VOhxuWP(r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjxCd8aua)Eq1YtPwGu)r03HzsG6HKXIHjxKIhanNs9YnsD7VLAfvuQT0wVdx8aO5uQxwQ)i67Wmjq9qYyXWKlsXdGMtNk8hnsNQzu9TrMM4INrc5ZUZTKW6w0PYjG05TBDN6x0Jlk4u)i67Wmjq9qYyXWKlsXdGMtPUrQnuQfi1gi1(KuFqNZJWzN26DCYBcNasN3sTIkk1gi1h058iC2PTEhN8MWjG05TulqQhqceX)KA)BKAHJHsTIkk1gHIciDMad8uegsDJuVGuRSuRSulqQnqQnqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zciIhGc4n3b)KAbsTbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKuROIsTrOOasNjWapfHHu3i1li1kl1kl1kQOuBGu)r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqsDJuBOuRSuRSulqQrqTwsHMmoSyXWKlYomtPwGupGeiI)j1(3i1gHIciDMaI4bnPd0bEajGf)ZPc)rJ0PAgvFBKPjU4zKq(S7ClTICl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQBKAdLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zYf3apafWVhuT8uQfi1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BPwrfLAlT17WfpaAoL6LL6pI(omtcupKmwmm5Iu8aO50Pc)rJ0P2Ic1McjoSyq4dxX55o3sch3IovobKoVDR7u)IECrbN6hrFhMjbQhsglgMCrkEa0Ck1nsTHsTaP2aP2NK6d6CEeo70wVJtEt4eq68wQvurP2aP(GoNhHZoT174K3eobKoVLAbs9asGi(Nu7FJulCmuQvurP2iuuaPZeyGNIWqQBK6fKALLALLAbsTbsTbs9hrFhMj5c03dhw85X4b0sjfpaAoLA)LAJqrbKotar8auaV5o4NulqQnqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAfvuQncffq6mbg4PimK6gPEbPwzPwzPwrfLAdK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaPgb1Ajq9qY43dQwMmp4fsQBKAdLALLALLAbsncQ1sk0KXHflgMCr2Hzk1cK6bKar8pP2)gP2iuuaPZeqepOjDGoWdibS4Fov4pAKo1wuO2uiXHfdcF4kop35ws46w0PYjG05TBDNk8hnsN6h5Z5vWXBSTdd2P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZuQfi1dibYrhm(c8auqQ9VrQzf4h9y8rhStTttg)BN6kYDULwHUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZuQfi1dibYrhm(c8auqQ9VrQzf4h9y8rhStf(JgPtTyqKMTyBhg80DULwWq3IovobKoVDR7u)IECrbNkcQ1sG6HKXIHjxKDyMsTaPgb1AjfAY4WIfdtUi7WmLAbs9MrqTwYfOVhoS4ZJXdOLs2Hz6uH)Or6uTXJo5nge(Wf9ymcdd35wAHfCl6u5eq682TUt9l6XffCQiOwlbQhsglgMCr2Hzk1cKAeuRLuOjJdlwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPtf(JgPtveTOw)OzlgPdZZDULwyLUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZ0Pc)rJ0PwurXoJPjEkcp7o3sl4JUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZ0Pc)rJ0PEEmgnrc0CJTr9S7ClTGWZTOtLtaPZB36o1VOhxuWPIGATeOEizSyyYfzhMPulqQrqTwsHMmoSyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMov4pAKo1bpIYpCyXD0NUX7IHX0DUZPcd8uegUfDlTGBrNkNasN3U1DQFrpUOGt1aP(JOVdZKa1djJfdtUifpaAoL6gP2qPwrfL6pI(omtsHMmoSyXWKlsXdGMtPE5gPU93sTYsTaPgb1AjfAY4WIfdtUi7WmDQWF0iDQxG(E4WIppgpGwQ7ClTs3IovobKoVDR7u)IECrbNkcQ1sk0KXHflgMCr2Hz6uH)Or6uH6HKXIHjxUZTKp6w0PYjG05TBDN6x0Jlk4urqTwsHMmoSyXWKlYomtNk8hnsNAHMmoSyXWKl35ws45w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5IGkk1cKAeuRLa1djJfdtUifpaAoL6LBKA4pAKeOEiz8GoN0opjSc8JEm(OdwQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqov4pAKovOEizmcuf0YUZTKW6w0PYjG05TBDN6x0Jlk4urqTwcupKm(9GQLjZdEHK6LLAeuRLa1djJFpOAzYauapp4fsQfi1iOwlPqtghwSyyYfzhMPulqQrqTwcupKmwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPtf(JgPtfQhsghfI7ClTICl6u5eq682TUt9l6XffCQiOwlPqtghwSyyYfzhMPulqQrqTwcupKmwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHCQWF0iDQq9qYyeOkOLDNBjHJBrNkNasN3U1DQVhqtN6cov4pAKovOEiz8GoN0opDNBjHRBrNknpUkuXdtTo1bKar8p)BeUcRtLMhxfQ4HPJbVPWXo1fCQWF0iDQSX4HJgPtLtaPZB36UZT0k0TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1ll1iOwlbQhsg)Eq1YKbOaEEWlKtf(JgPtfQhsghfI7ClTGHUfDQWF0iDQq9qYyeOkOLDQCciDE7w3DULwyb3Iov4pAKovOEizmshMNtLtaPZB36UZDo1ko4Or6w0T0cUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2PUGt9l6XffCQiOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqsTaP2NKAeuRLuODghw85vmpjOIsTaP2sB9oCXdGMtPE5gP2aP2aPEaji1Rk1WF0ijq9qYyKompYhZtQvwQfMrQH)OrsG6HKXiDyEewb(rpgF0bl1k7uncfoHb7uT0e6ye0kDNBPv6w0PYjG05TBDN6x0Jlk4u)i67WmjxG(E4WIppgpGwkP4bqZPu3i1gk1cKAdKAeuRLa1djJFpOAzY8GxiP2FP2iuuaPZKlUbEakGFpOA5PulqQpOZ5rk0KXHflgMCr4eq68wQfi1Fe9DyMKcnzCyXIHjxKIhanNs9YnsD7VLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gHIciDMCXnWdqb8M7GFsTaP(dJCc5reYVIcPulqQ)i67WmjfSPqE4PiucrkEa0Ck1l3i1cxPwzNk8hnsNkupKmgbQcAz35wYhDl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQBKAdLAbsTbsncQ1sG6HKXVhuTmzEWlKu7VuBekkG0zYf3apafWVhuT8uQfi1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtPE5gPU93sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpPwGu7ts9hg5eYJiKFffsPwzNk8hnsNkupKmgbQcAz35ws45w0PYjG05TBDN6x0Jlk4u)i67WmjxG(E4WIppgpGwkP4bqZPu3i1gk1cKAdKAeuRLa1djJFpOAzY8GxiP2FP2iuuaPZKlUbEakGFpOA5PulqQ9jP(GoNhPqtghwSyyYfHtaPZBPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNjxCd8auaV5o4NuRStf(JgPtfQhsgJavbTS7CljSUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaP2aPgb1Ajq9qY43dQwMmp4fsQ9xQncffq6m5IBGhGc43dQwEk1cK6pI(omtcupKmwmm5Iu8aO5uQxUrQB)TuRStf(JgPtfQhsgJavbTS7ClTICl6u5eq682TUt9l6XffCQBgb1AjfSPqE4PiucHnI2tUaeANE(rMh8cj1ns9MrqTwsbBkKhEkcLqyJO9KlaH2PNFKbOaEEWlKulqQnqQrqTwcupKmwmm5ISdZuQvurPgb1Ajq9qYyXWKlsXdGMtPE5gPU93sTYsTaP2aPgb1AjfAY4WIfdtUi7WmLAfvuQrqTwsHMmoSyXWKlsXdGMtPE5gPU93sTYov4pAKovOEizmcuf0YUZTKWXTOtLtaPZB36o1VOhxuWPUJJuWMc5HNIqjeP4bqZPu7VulSsTIkk1Bgb1AjfSPqE4PiucHnI2tUaeANE(rMh8cj1(l1g6uH)Or6uH6HKXiDyEUZTKW1TOtLtaPZB36o1VOhxuWPIGATeXINC(moS4bn3eurPwGuVzeuRLCb67Hdl(8y8aAPeurPwGuVzeuRLCb67Hdl(8y8aAPKIhanNs9Ynsn8hnscupKmgPdZJWkWp6X4JoyNk8hnsNkupKmgPdZZDULwHUfDQCciDE7w3Pc)rJ0Pc1djJh05K25Pt99aA6uxWP(f94Ico1nJGATKlqFpCyXNhJhqlLGkk1cK6d6CEeOEizm)EbHtaPZBPwGuJGATKndNhsujt2Hzk1cKAdK6nJGATKlqFpCyXNhJhqlLu8aO5uQ9xQH)OrsG6HKXd6Cs78KWkWp6X4JoyPwrfL6pI(omtIyXtoFghw8GMBsXdGMtP2FP2qPwrfL6pmYjKhri)kkKsTYUZT0cg6w0PYjG05TBDN6x0Jlk4urqTwY3zOEyE0SLum8NulqQrqTwcRGiKBEJfJJZJcDcQOtf(JgPtfQhsgpOZjTZt35wAHfCl6u5eq682TUtf(JgPtfQhsgpOZjTZtN67b00PUGt9l6XffCQiOwl57mupmpA2skg(tQfi1gi1iOwlbQhsglgMCrqfLAfvuQrqTwsHMmoSyXWKlcQOuROIs9MrqTwYfOVhoS4ZJXdOLskEa0Ck1(l1WF0ijq9qY4bDoPDEsyf4h9y8rhSuRS7ClTWkDl6u5eq682TUtf(JgPtfQhsgpOZjTZtN67b00PUGt9l6XffCQiOwl57mupmpA2skg(tQfi1iOwl57mupmpA2sMh8cj1nsncQ1s(od1dZJMTKbOaEEWlK7ClTGp6w0PYjG05TBDNk8hnsNkupKmEqNtANNo13dOPtDbN6x0Jlk4urqTwY3zOEyE0SLum8NulqQrqTwY3zOEyE0SLu8aO5uQxUrQnqQnqQrqTwY3zOEyE0SLmp4fsQfMrQH)OrsG6HKXd6Cs78KWkWp6X4JoyPwzPEnPU93sTYUZT0ccp3IovobKoVDR7u)IECrbNQbsDX2INEasNLAfvuQ9jP(OVq0SvQvwQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqsTaPgb1Ajq9qYyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMov4pAKo1KppUWhpe555o3sliSUfDQCciDE7w3P(f94IcoveuRLa1djJFpOAzY8GxiPE5gP2iuuaPZKlUbEakGFpOA5Ptf(JgPtfQhsghfI7ClTWkYTOtLtaPZB36o1VOhxuWPoGeiI)j1l3i1RqHvQfi1iOwlbQhsglgMCr2Hzk1cKAeuRLuOjJdlwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPtf(JgPtDIkYvggb35wAbHJBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLAbs9hrFhMjHngpC0ijfpaAoLA)LAdLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gk1cK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gk1cKAdKAFsQpOZ5rk0KXHflgMCr4eq68wQvurP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1(l1gk1kl1k7uH)Or6uNEu7rZwSyyYL7ClTGW1TOtLtaPZB36o1VOhxuWPIGATKcTZ4WIpVI5jbvuQfi1iOwlbQhsg)Eq1YK5bVqsT)sTp6uH)Or6uH6HKXiDyEUZT0cRq3IovobKoVDR7u)IECrbN6asGi(NuVSuBekkG0zccuf0Y4bKaw8pPwGu)r03HzsyJXdhnssXdGMtP2FP2qPwGuJGATeOEizSyyYfzhMPulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAbsnpNC(mXiDsJehwSixw(pAKKbnJYPc)rJ0Pc1djJrGQGw2DULwPHUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaP2aP(JOVdZKuOjJdlwmm5Iu8aO5uQBKAdLAfvuQ)i67Wmjq9qYyXWKlsXdGMtPUrQnuQvwQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqov4pAKovOEizmcuf0YUZT0kxWTOtLtaPZB36o1VOhxuWPoGeiI)j1l3i1gHIciDMGavbTmEajGf)tQfi1iOwlbQhsglgMCr2Hzk1cKAeuRLuOjJdlwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAbs9hrFhMjHngpC0ijfpaAoLA)LAdDQWF0iDQq9qYyeOkOLDNBPvUs3IovobKoVDR7u)IECrbNkcQ1sG6HKXIHjxKDyMsTaPgb1AjfAY4WIfdtUi7WmLAbs9MrqTwYfOVhoS4ZJXdOLs2Hzk1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiPwGuFqNZJa1djJJcHWjG05TulqQ)i67Wmjq9qY4OqifpaAoL6LBK62Fl1cK6bKar8pPE5gPEfAOulqQ)i67WmjSX4HJgjP4bqZPu7VuBOtf(JgPtfQhsgJavbTS7ClTsF0TOtLtaPZB36o1VOhxuWPIGATeOEizSyyYfbvuQfi1iOwlbQhsglgMCrkEa0Ck1l3i1T)wQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqov4pAKovOEizmcuf0YUZT0kfEUfDQCciDE7w3P(f94IcoveuRLuOjJdlwmm5IGkk1cKAeuRLuOjJdlwmm5Iu8aO5uQxUrQB)TulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHCQWF0iDQq9qYyeOkOLDNBPvkSUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLGkk1cK6nJGATKlqFpCyXNhJhqlLu8aO5uQxUrQB)TulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHCQWF0iDQq9qYyeOkOLDNBPvUICl6uH)Or6uH6HKXiDyEovobKoVDR7o3sRu44w0PsZJRcv8WuRtDajqe)Z)gHRW6uP5XvHkEy6yWBkCStDbNk8hnsNkBmE4Or6u5eq682TU7ClTsHRBrNk8hnsNkupKmgbQcAzNkNasN3U1DN7CQJWip48Cl6wAb3IovobKoVDR7u)IECrbN6imYdopYMopiFwQ9VrQxWqNk8hnsNksNMc5o3sR0TOtf(JgPtvS4jNpJdlEqZTtLtaPZB36UZTKp6w0PYjG05TBDN6x0Jlk4uhHrEW5r205b5Zs9Ys9cg6uH)Or6uH6HKXd6Cs780DULeEUfDQWF0iDQq9qY4OqCQCciDE7w3DULew3Iov4pAKovlTymshMNtLtaPZB36UZDo1nBb0(5w0T0cUfDQCciDE7w3P(f94Ico1dQw(iBgb1AjpmpA2skg(ZPc)rJ0P(bAECnf5E3DULwPBrNkNasN3U1DQWF0iDQp07y4pAK4oDEo1oDE4egStD6bfVX)E6o3s(OBrNkNasN3U1DQWF0iDQp07y4pAK4oDEo1oDE4egStLNtoFE6o3scp3IovobKoVDR7u)IECrbNk8h1iJ5KhuEk1(l1R0Pc)rJ0P(qVJH)OrI7055u705HtyWoviy35wsyDl6u5eq682TUt9l6XffCQgHIciDM4bgzCiYjVL6LBKAdDQWF0iDQp07y4pAK4oDEo1oDE4egStne5Kl35wAf5w0PYjG05TBDN6x0Jlk4uncffq6mbg4PimK6gPEbNk8hnsN6d9og(JgjUtNNtTtNhoHb7uHbEkcd35ws44w0PYjG05TBDNk8hnsN6d9og(JgjUtNNtTtNhoHb7u)i67WmNUZTKW1TOtLtaPZB36o1VOhxuWPAekkG0zILMqhJGwPu3i1g6uH)Or6uFO3XWF0iXD68CQD68WjmyNAfhC0iDNBPvOBrNkNasN3U1DQFrpUOGt1iuuaPZelnHogbTsPUrQxWPc)rJ0P(qVJH)OrI7055u705HtyWovlnHogbTs35wAbdDl6u5eq682TUtf(JgPt9HEhd)rJe3PZZP2PZdNWGDQJWip48CN7CQIf)Xabo3IULwWTOtLtaPZB36o1q0Pw8KpNk8hnsNQrOOasNDQgHcNWGDQIflI27y2y4u3Sfq7Nt1q35wALUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2PUGt9l6XffCQgHIciDMiwSiAVJzJHu3i1gk1cK6cnzBuTmzsf9IepVOge2NrPII8wQfi1WFuJmMtEq5Pu7VuVsNQrOWjmyNQyXIO9oMngUZTKp6w0PYjG05TBDNAi6uN85uH)Or6uncffq6St1i0rzN6co1VOhxuWPAekkG0zIyXIO9oMngsDJuBOulqQl0KTr1YKjv0ls88IAqyFgLkkYBPwGu)HroH8ij)v0JAl1cKA4pQrgZjpO8uQ9xQxWPAekCcd2PkwSiAVJzJH7Clj8Cl6u5eq682TUtneDQt(CQWF0iDQgHIciD2PAe6OStDbN6x0Jlk4uncffq6mrSyr0EhZgdPUrQnuQfi1fAY2OAzYKk6fjEErniSpJsff5TulqQ)WiNqEKK26DylWovJqHtyWovXIfr7DmBmCNBjH1TOtLtaPZB36o1q0Pw8KpNk8hnsNQrOOasNDQgHcNWGDQEGrghICYBN6MTaA)CQg6o3sRi3IovobKoVDR7udrN6KpNk8hnsNQrOOasNDQgHok7uxWP(f94IcovJqrbKot8aJmoe5K3sDJuBOulqQH)OgzmN8GYtP2FPELovJqHtyWovpWiJdro5T7CljCCl6u5eq682TUtneDQt(CQWF0iDQgHIciD2PAe6OStDbN6x0Jlk4uncffq6mXdmY4qKtEl1nsTHsTaP2iuuaPZeXIfr7DmBmK6gPEbNQrOWjmyNQhyKXHiN82DULeUUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2PAOt1iu4egSt1stOJrqR0DULwHUfDQCciDE7w3PgIo1IN85uH)Or6uncffq6St1iu4egStTM4bOaEZDWpN6MTaA)CQcR7ClTGHUfDQCciDE7w3PgIo1IN85uH)Or6uncffq6St1iu4egStfeXdqb8M7GFo1nBb0(5uxWq35wAHfCl6u5eq682TUtneDQfp5ZPc)rJ0PAekkG0zNQrOWjmyNAfI4bOaEZDWpN6MTaA)CQR0q35wAHv6w0PYjG05TBDNAi6ulEYNtf(JgPt1iuuaPZovJqHtyWo1lUbEakG3Ch8ZPUzlG2pNQW6o3sl4JUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2P6Jo1VOhxuWPAekkG0zYf3apafWBUd(j1nsTWk1cK6cnzBuTmztNpvSttO8d)Xya5MW(mkvuK3ovJqHtyWo1lUbEakG3Ch8ZDULwq45w0PYjG05TBDNAi6uN85uH)Or6uncffq6St1i0rzN6ccRt9l6XffCQgHIciDMCXnWdqb8M7GFsDJulSsTaP(dJCc5rsAR3HTa7uncfoHb7uV4g4bOaEZDWp35wAbH1TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYo1fewN6x0Jlk4uncffq6m5IBGhGc4n3b)K6gPwyLAbs9h5gLEeOEizSyfBARFeobKoVLAbsn8h1iJ5KhuEk1ll1(Ot1iu4egSt9IBGhGc4n3b)CNBPfwrUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2P6Jg6u)IECrbNQrOOasNjxCd8auaV5o4Nu3i1cRulqQ55KZNjgPtAK4WIf5YY)rJKmOzuovJqHtyWo1lUbEakG3Ch8ZDULwq44w0PYjG05TBDNAi6ulEYNtf(JgPt1iuuaPZovJqHtyWoveOkOLXdibS4Fo1nBb0(5ufog6o3sliCDl6u5eq682TUtneDQt(CQWF0iDQgHIciD2PAe6OStv4zOt9l6XffCQgHIciDMGavbTmEajGf)tQBKAHJHsTaP(dJCc5rsAR3HTa7uncfoHb7urGQGwgpGeWI)5o3slScDl6u5eq682TUtneDQfp5ZPc)rJ0PAekkG0zNQrOWjmyNkiIh0Koqh4bKaw8pN6MTaA)CQ(OHUZT0kn0TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYovH1qN6x0Jlk4uncffq6mbeXdAshOd8asal(Nu3i1(OHsTaPUqt2gvlt205tf70ek)WFmgqUjSpJsff5Tt1iu4egStfeXdAshOd8asal(N7ClTYfCl6u5eq682TUtneDQt(CQWF0iDQgHIciD2PAe6OStvyn0P(f94IcovJqrbKotar8GM0b6apGeWI)j1nsTpAOulqQl0KTr1YK2Io7(HPp97mH9zuQOiVDQgHcNWGDQGiEqt6aDGhqcyX)CNBPvUs3IovobKoVDR7udrNAXt(CQWF0iDQgHIciD2PAekCcd2PEXnWdqb87bvlpDQB2cO9ZPUs35wAL(OBrNkNasN3U1DQHOtT4jFov4pAKovJqrbKo7uncfoHb7uHGXxCd8aua)Eq1YtN6MTaA)CQR0DULwPWZTOtLtaPZB36o1q0Pw8KpNk8hnsNQrOOasNDQgHcNWGDQWapfHHtDZwaTFo1jFhnBNeyGNIWWDULwPW6w0PYjG05TBD35wALRi3IovobKoVDR7o3sRu44w0PYjG05TBD35wALcx3Iov4pAKo1j6yejgQhsgBHbTtHYPYjG05TBD35wALRq3Iov4pAKovOEizmnpU35)CQCciDE7w3DUL8rdDl6uH)Or6u)ifMdTy8asa3YdNkNasN3U1DNBjFCb3IovobKoVDR7o3s(4kDl6uH)Or6uh0QIcthql7u5eq682TU7Cl5J(OBrNkNasN3U1DQFrpUOGt1iuuaPZeXIfr7DmBmK6LBKAdDQWF0iDQ2kMhs0p35wYhfEUfDQCciDE7w3P(f94IcovJqrbKotelweT3XSXqQ9xQn0Pc)rJ0PYgJhoAKUZDo1pI(omZPBr3sl4w0PYjG05TBDN6x0Jlk4ul0KTr1YK2Io7(HPp97mH9zuQOiVLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1(OHsTaP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuBOulqQnqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotU4g4bOa(9GQLNsTaP2aP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1kl1kQOuBGu7ts9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpPwzPwrfL6pI(omtcupKmwmm5Iu8aO5uQxUrQB)TuRSuRStf(JgPt1wX8WzyeCNBPv6w0PYjG05TBDN6x0Jlk4ul0KTr1YK2Io7(HPp97mH9zuQOiVLAbs9hrFhMjbQhsglgMCrkEa0Ck1nsTHsTaP2aP2NK6d6CEeo70wVJtEt4eq68wQvurP2aP(GoNhHZoT174K3eobKoVLAbs9asGi(Nu7FJulCmuQvwQvwQfi1gi1gi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQxWqPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1kl1kQOuBGu)r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqsDJuBOuRSuRSulqQrqTwsHMmoSyXWKlYomtPwGupGeiI)j1(3i1gHIciDMaI4bnPd0bEajGf)ZPc)rJ0PARyE4mmcUZTKp6w0PYjG05TBDN6x0Jlk4ul0KTr1YKnD(uXonHYp8hJbKBc7ZOurrEl1cK6pI(omtccQ1I305tf70ek)WFmgqUjfdB)KAbsncQ1s205tf70ek)WFmgqUX2kMhzhMPulqQnqQrqTwcupKmwmm5ISdZuQfi1iOwlPqtghwSyyYfzhMPulqQ3mcQ1sUa99WHfFEmEaTuYomtPwzPwGu)r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1gi1iOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjxCd8aua)Eq1YtPwGuBGuBGuFqNZJuOjJdlwmm5IWjG05TulqQ)i67WmjfAY4WIfdtUifpaAoL6LBK62Fl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KALLAfvuQnqQ9jP(GoNhPqtghwSyyYfHtaPZBPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNjxCd8auaV5o4NuRSuROIs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)wQvwQv2Pc)rJ0PARyEir)CNBjHNBrNkNasN3U1DQFrpUOGtTqt2gvlt205tf70ek)WFmgqUjSpJsff5TulqQ)i67WmjiOwlEtNpvSttO8d)Xya5MumS9tQfi1iOwlztNpvSttO8d)Xya5gBPft2Hzk1cKAXInIB)nzbITI5He9ZPc)rJ0PAPfJr6W8CNBjH1TOtLtaPZB36o1VOhxuWP(r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjxCd8aua)Eq1YtPwGu)r03HzsG6HKXIHjxKIhanNs9YnsD7VDQWF0iDQdAvrnXHfFrn48CNBPvKBrNkNasN3U1DQFrpUOGt9JOVdZKa1djJfdtUifpaAoL6gP2qPwGuBGu7ts9bDopcNDAR3XjVjCciDEl1kQOuBGuFqNZJWzN26DCYBcNasN3sTaPEajqe)tQ9VrQfogk1kl1kl1cKAdKAdK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gHIciDMaI4bOaEZDWpPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1kl1kQOuBGu)r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqsDJuBOuRSuRSulqQrqTwsHMmoSyXWKlYomtPwGupGeiI)j1(3i1gHIciDMaI4bnPd0bEajGf)ZPc)rJ0PoOvf1ehw8f1GZZDULeoUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6m5IBGhGc43dQwEk1cK6pI(omtcupKmwmm5Iu8aO5uQxUrQB)Ttf(JgPtDZW5HevYUZTKW1TOtLtaPZB36o1VOhxuWP(r03HzsG6HKXIHjxKIhanNsDJuBOulqQnqQ9jP(GoNhHZoT174K3eobKoVLAfvuQnqQpOZ5r4StB9oo5nHtaPZBPwGupGeiI)j1(3i1chdLALLALLAbsTbsTbs9hrFhMj5c03dhw85X4b0sjfpaAoLA)L6fmuQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqsTYsTIkk1gi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKAdLAbsncQ1sG6HKXVhuTmzEWlKu3i1gk1kl1kl1cKAeuRLuOjJdlwmm5ISdZuQfi1dibI4FsT)nsTrOOasNjGiEqt6aDGhqcyX)CQWF0iDQBgopKOs2DULwHUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gHIciDMut8auaV5o4NulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKAIhGc4n3b)KAbsTbs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TuROIs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQ9xQncffq6mPM4bOaEZDWpPwrfLAFsQpOZ5rk0KXHflgMCr4eq68wQvwQfi1iOwlbQhsg)Eq1YK5bVqsT)s9kLAbs9MrqTwYfOVhoS4ZJXdOLs2Hz6uH)Or6ulytH8WtrOeYDULwWq3IovobKoVDR7u)IECrbN6hrFhMj5c03dhw85X4b0sjfpaAoL6gP2qPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)2Pc)rJ0PwWMc5HNIqjK7ClTWcUfDQCciDE7w3P(f94Ico1pI(omtcupKmwmm5Iu8aO5uQBKAdLAbsTbsTbsTpj1h058iC2PTEhN8MWjG05TuROIsTbs9bDopcNDAR3XjVjCciDEl1cK6bKar8pP2)gPw4yOuRSuRSulqQnqQnqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zciIhGc4n3b)KAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKuRSuROIsTbs9hrFhMj5c03dhw85X4b0sjfpaAoL6gP2qPwGuJGATeOEiz87bvltMh8cj1nsTHsTYsTYsTaPgb1AjfAY4WIfdtUi7WmLAbs9asGi(Nu7FJuBekkG0zciIh0Koqh4bKaw8pPwzNk8hnsNAbBkKhEkcLqUZT0cR0TOtLtaPZB36o1VOhxuWP(r03HzsG6HKXIHjxKIhanNs9YsTWAOulqQ55KZNjgPtAK4WIf5YY)rJKmOzuov4pAKo1lqFpCyXNhJhql1DULwWhDl6u5eq682TUt9l6XffCQiOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjxCd8aua)Eq1YtPwGuFqNZJuOjJdlwmm5IWjG05TulqQ)i67WmjfAY4WIfdtUifpaAoL6LBK62Fl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KAbs9hg5eYJiKFffsPwGu)r03HzskytH8WtrOeIu8aO5uQxUrQfUov4pAKo1lqFpCyXNhJhql1DULwq45w0PYjG05TBDN6x0Jlk4urqTwcupKm(9GQLjZdEHK6LBKAJqrbKotU4g4bOa(9GQLNsTaP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1cKAFsQ)WiNqEeH8ROq6uH)Or6uVa99WHfFEmEaTu35wAbH1TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbsTpj1h058ifAY4WIfdtUiCciDEl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)CQWF0iDQxG(E4WIppgpGwQ7ClTWkYTOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)2Pc)rJ0PEb67Hdl(8y8aAPUZT0cch3IovobKoVDR7u)IECrbNQbsTpj1h058iC2PTEhN8MWjG05TuROIsTbs9bDopcNDAR3XjVjCciDEl1cK6bKar8pP2)gPw4yOuRSuRSulqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zciIhGc4n3b)KAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKulqQrqTwsHMmoSyXWKlYomtPwGupGeiI)j1(3i1gHIciDMaI4bnPd0bEajGf)ZPc)rJ0Pc1djJfdtUCNBPfeUUfDQCciDE7w3P(f94IcoveuRLuOjJdlwmm5ISdZuQfi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mPcr8auaV5o4NulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAbsTbs9hrFhMjbQhsglgMCrkEa0Ck1(l1liSsTIkk1Bgb1AjxG(E4WIppgpGwkbvuQv2Pc)rJ0PwOjJdlwmm5YDULwyf6w0PYjG05TBDN6x0Jlk4urqTwcupKm(9GQLjZdEHK6gP2qPwGu)HroH8ic5xrH0Pc)rJ0Pkw8KZNXHfpO52DULwPHUfDQCciDE7w3P(f94Ico1nJGATKlqFpCyXNhJhqlLGkk1cKAFsQ)WiNqEeH8ROq6uH)Or6uflEY5Z4WIh0C7o35uNEqXB8VNUfDlTGBrNkNasN3U1DQFrpUOGt1aP(GoNhHZoT174K3eobKoVLAbs9asGi(NuVCJulCnuQfi1dibI4FsT)ns9ksyLALLAfvuQnqQ9jP(GoNhHZoT174K3eobKoVLAbs9asGi(NuVCJulCfwPwzNk8hnsN6asa3Yd35wALUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIov4pAKov0jJPhpMUZTKp6w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5IGk6uH)Or6ufJJgP7Clj8Cl6u5eq682TUt9l6XffCQfAY2OAzYXdXOGo2ekrc7ZOurrEl1cKAeuRLWk4bOZJgjbv0Pc)rJ0PE0bJnHs0DULew3IovobKoVDR7u)IECrbNkcQ1sG6HKXIHjxKDyMsTaPgb1AjfAY4WIfdtUi7WmLAbs9MrqTwYfOVhoS4ZJXdOLs2Hz6uH)Or6u70wVBIfMdD3o48CNBPvKBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmDQWF0iDQiqloS4ROVqt35ws44w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5IGk6uH)Or6ur4AYLq0S1DULeUUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIov4pAKovKEeBSfT8ZDULwHUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIov4pAKovlTyKEeB35wAbdDl6u5eq682TUt9l6XffCQiOwlbQhsglgMCrqfDQWF0iDQq(88kOJFO3DN7CQqWUfDlTGBrNkNasN3U1DQFrpUOGtTqt2gvlt205tf70ek)WFmgqUjSpJsff5TulqQ)i67WmjiOwlEtNpvSttO8d)Xya5MumS9tQfi1iOwlztNpvSttO8d)Xya5gBRyEKDyMsTaP2aPgb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLALLAbs9hrFhMj5c03dhw85X4b0sjfpaAoL6gP2qPwGuBGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTaP2aP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1kl1kQOuBGu7ts9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpPwzPwrfL6pI(omtcupKmwmm5Iu8aO5uQxUrQB)TuRSuRStf(JgPt1wX8qI(5o3sR0TOtLtaPZB36o1VOhxuWPAGuxOjBJQLjB68PIDAcLF4pgdi3e2NrPII8wQfi1Fe9DyMeeuRfVPZNk2Pju(H)ymGCtkg2(j1cKAeuRLSPZNk2Pju(H)ymGCJT0Ij7WmLAbsTyXgXT)MSaXwX8qI(j1kl1kQOuBGuxOjBJQLjB68PIDAcLF4pgdi3e2NrPII8wQfi1hDWsDJuBOuRStf(JgPt1slgJ0H55o3s(OBrNkNasN3U1DQFrpUOGtTqt2gvltAl6S7hM(0VZe2NrPII8wQfi1Fe9DyMeOEizSyyYfP4bqZPu7Vu7Jgk1cK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaP2aPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6mbcgFXnWdqb87bvlpLAbsTbsTbs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8tQvwQvurP2aP2NK6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gHIciDMCXnWdqb8M7GFsTYsTIkk1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BPwzPwzNk8hnsNQTI5HZWi4o3scp3IovobKoVDR7u)IECrbNAHMSnQwM0w0z3pm9PFNjSpJsff5TulqQ)i67Wmjq9qYyXWKlsXdGMtPUrQnuQfi1gi1gi1gi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mbeXdqb8M7GFsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQvwQvurP2aP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuBOulqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotGGXxCd8aua)Eq1YtPwzPwzPwGuJGATKcnzCyXIHjxKDyMsTYov4pAKovBfZdNHrWDULew3IovobKoVDR7u)IECrbNAHMSnQwMmPIErINxudc7ZOurrEl1cKAXInIB)nzbcBmE4Or6uH)Or6uVa99WHfFEmEaTu35wAf5w0PYjG05TBDN6x0Jlk4ul0KTr1YKjv0ls88IAqyFgLkkYBPwGuBGulwSrC7VjlqyJXdhnsPwrfLAXInIB)nzbYfOVhoS4ZJXdOLk1k7uH)Or6uH6HKXIHjxUZTKWXTOtLtaPZB36o1VOhxuWPE0bl1(l1(OHsTaPUqt2gvltMurViXZlQbH9zuQOiVLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1cK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaP(JOVdZKa1djJfdtUifpaAoL6LBK62F7uH)Or6uzJXdhns35ws46w0PYjG05TBDNk8hnsNkBmE4Or6uP5XvHkEyQ1PIGATKjv0ls88IAqMh8c1GGATKjv0ls88IAqgGc45bVqovAECvOIhMog8Mch7uxWP(f94Ico1JoyP2FP2hnuQfi1fAY2OAzYKk6fjEErniSpJsff5TulqQ)i67Wmjq9qYyXWKlsXdGMtPUrQnuQfi1gi1gi1gi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mbeXdqb8M7GFsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQvwQvurP2aP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuBOulqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotGGXxCd8aua)Eq1YtPwzPwzPwGuJGATKcnzCyXIHjxKDyMsTYUZT0k0TOtLtaPZB36o1VOhxuWPAGu)r03HzsG6HKXIHjxKIhanNsT)sTWtyLAfvuQ)i67Wmjq9qYyXWKlsXdGMtPE5gP2hLALLAbs9hrFhMj5c03dhw85X4b0sjfpaAoL6gP2qPwGuBGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTaP2aP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VulSsTYsTIkk1gi1(KuFqNZJuOjJdlwmm5IWjG05TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FPwyLALLAfvuQ)i67Wmjq9qYyXWKlsXdGMtPE5gPU93sTYsTYov4pAKo1bTQOM4WIVOgCEUZT0cg6w0PYjG05TBDN6x0Jlk4u)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zsnXdqb8M7GFsTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotQjEakG3Ch8tQfi1gi1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtPE5gPU93sTIkk1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtP2FP2iuuaPZKAIhGc4n3b)KAfvuQ9jP(GoNhPqtghwSyyYfHtaPZBPwzPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTaPEZiOwl5c03dhw85X4b0sj7WmDQWF0iDQfSPqE4Piuc5o3slSGBrNkNasN3U1DQFrpUOGt9JOVdZKCb67Hdl(8y8aAPKIhanNsDJuBOulqQnqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotGGXxCd8aua)Eq1YtPwGuBGuBGuFqNZJuOjJdlwmm5IWjG05TulqQ)i67WmjfAY4WIfdtUifpaAoL6LBK62Fl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KALLAfvuQnqQ9jP(GoNhPqtghwSyyYfHtaPZBPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNjxCd8auaV5o4NuRSuROIs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)wQvwQv2Pc)rJ0PwWMc5HNIqjK7ClTWkDl6u5eq682TUt9l6XffCQFe9DyMeOEizSyyYfP4bqZPu3i1gk1cKAdKAdKAdK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gHIciDMaI4bOaEZDWpPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1kl1kQOuBGu)r03HzsUa99WHfFEmEaTusXdGMtPUrQnuQfi1iOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjqW4lUbEakGFpOA5PuRSuRSulqQrqTwsHMmoSyXWKlYomtPwzNk8hnsNAbBkKhEkcLqUZT0c(OBrNkNasN3U1DQFrpUOGt9JOVdZKa1djJfdtUifpaAoL6gP2qPwGuBGuBGuBGu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiPwzPwrfLAdK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTHsTaPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6mbcgFXnWdqb87bvlpLALLALLAbsncQ1sk0KXHflgMCr2Hzk1k7uH)Or6u3mCEirLS7ClTGWZTOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTaP2aP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1kl1kQOuBGu7ts9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpPwzPwrfL6pI(omtcupKmwmm5Iu8aO5uQxUrQB)TuRStf(JgPt9c03dhw85X4b0sDNBPfew3IovobKoVDR7u)IECrbNQbsTbs9hrFhMj5c03dhw85X4b0sjfpaAoLA)LAJqrbKotar8auaV5o4NulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKALLAfvuQnqQ)i67WmjxG(E4WIppgpGwkP4bqZPu3i1gk1cKAeuRLa1djJFpOAzY8GxiPE5gP2iuuaPZeiy8f3apafWVhuT8uQvwQvwQfi1iOwlPqtghwSyyYfzhMPtf(JgPtfQhsglgMC5o3slSICl6u5eq682TUt9l6XffCQiOwlPqtghwSyyYfzhMPulqQnqQnqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuVsdLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKuRSuROIsTbs9hrFhMj5c03dhw85X4b0sjfpaAoL6gP2qPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTYsTYsTaP2aP(JOVdZKa1djJfdtUifpaAoLA)L6fewPwrfL6nJGATKlqFpCyXNhJhqlLGkk1k7uH)Or6ul0KXHflgMC5o3sliCCl6u5eq682TUt9l6XffCQiOwlzZW5HevYeurPwGuVzeuRLCb67Hdl(8y8aAPeurPwGuVzeuRLCb67Hdl(8y8aAPKIhanNs9YnsncQ1selEY5Z4WIh0CtgGc45bVqsTWmsn8hnscupKmgPdZJWkWp6X4JoyNk8hnsNQyXtoFghw8GMB35wAbHRBrNkNasN3U1DQFrpUOGtfb1AjBgopKOsMGkk1cKAdKAdK6d6CEKINrc5ZeobKoVLAbsn8h1iJ5KhuEk1ll1cpPwzPwrfLA4pQrgZjpO8uQxwQfwPwzNk8hnsNkupKmgPdZZDULwyf6w0Pc)rJ0Porf5kdJGtLtaPZB36UZT0kn0TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1nsTHov4pAKovOEizCuiUZT0kxWTOtLtaPZB36o1VOhxuWPAGuxST4PhG0zPwrfLAFsQp6lenBLALLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKtf(JgPtn5ZJl8XdrEEUZT0kxPBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gk1cK6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gk1cKAdKAFsQpOZ5rk0KXHflgMCr4eq68wQvurP2aP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1(l1gk1kl1k7uH)Or6uNEu7rZwSyyYL7ClTsF0TOtLtaPZB36o1VOhxuWPIGATKVZq9W8OzlPy4pPwGuxOjBJQLjq9qYyAAPj98JW(mkvuK3sTaP(GoNhbgIDQL(WrJKWjG05TulqQH)OgzmN8GYtPEzPEf6uH)Or6uH6HKXd6Cs780DULwPWZTOtLtaPZB36o1VOhxuWPIGATKVZq9W8OzlPy4pPwGuxOjBJQLjq9qYyAAPj98JW(mkvuK3sTaPg(JAKXCYdkpL6LL6vKtf(JgPtfQhsgpOZjTZt35wALcRBrNkNasN3U1DQFrpUOGtfb1Ajq9qY43dQwMmp4fsQxwQrqTwcupKm(9GQLjdqb88GxiNk8hnsNkupKmMvqShtAKUZT0kxrUfDQCciDE7w3P(f94IcoveuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiPwGulwSrC7VjlqG6HKXiqvql7uH)Or6uH6HKXScI9ysJ0DULwPWXTOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8c5uH)Or6uH6HKXiqvql7o3sRu46w0PsZJRcv8WuRtDajqe)Z)gHRW6uP5XvHkEy6yWBkCStDbNk8hnsNkBmE4Or6u5eq682TU7CNt1stOJrqR0TOBPfCl6u5eq682TUtf(JgPtfQhsgpOZjTZtN67b00PUGt9l6XffCQiOwl57mupmpA2skg(ZDULwPBrNk8hnsNkupKmgPdZZPYjG05TBD35wYhDl6uH)Or6uH6HKXiqvql7u5eq682TU7CN7CQg5AsJ0T0knCLgUGHlSICQMqL0SD6ufM1kUW8lj8BPvmfMKAPErpwQPdXOoP2gLu7dvCWrJ0hK6I9zuAXBPEgdwQb0lgWXBP(9GSLNePVRG0KL6feMK6vGinY1XBPwLowbK6PF5bki1cFtQVqQxbrbPEtnsN0iL6qKl4IsQnyvLLAdwqbLjsFxbPjl1RuysQxbI0ixhVLAF4dJCc5regjCciDE7ds9fsTp8HroH8icJ(GuBWckOmr67kinzP2hfMK6vGinY1XBP2h(WiNqEeHrcNasN3(GuFHu7dFyKtipIWOpi1gSGcktK(UcstwQxHcts9kqKg564Tu7dFyKtipIWiHtaPZBFqQVqQ9HpmYjKhry0hKAdwqbLjsFL(kmRvCH5xs43sRykmj1s9IESuthIrDsTnkP2hel(JbcC(GuxSpJslEl1ZyWsnGEXaoEl1VhKT8Ki9DfKMSu7Jcts9kqKg564Tu7dFyKtipIWiHtaPZBFqQVqQ9HpmYjKhry0hKAdwqbLjsFxbPjl1cpHjPEfisJCD8wQ9HpmYjKhryKWjG05Tpi1xi1(Whg5eYJim6dsTblOGYePVRG0KL6feEcts9kqKg564Tu7dFyKtipIWiHtaPZBFqQVqQ9HpmYjKhry0hKAdwqbLjsFxbPjl1liCfMK6vGinY1XBP2h(WiNqEeHrcNasN3(GuFHu7dFyKtipIWOpi1gSGcktK(k9vywR4cZVKWVLwXuysQL6f9yPMoeJ6KABusTp8r03Hzo9bPUyFgLw8wQNXGLAa9IbC8wQFpiB5jr67kinzPEbFuysQxbI0ixhVLAF4dJCc5regjCciDE7ds9fsTp8HroH8icJ(GuBWckOmr67kinzPEbHNWKuVcePrUoEl1(Whg5eYJims4eq682hK6lKAF4dJCc5reg9bP2GfuqzI03vqAYs9cRqHjPEfisJCD8wQ9HpmYjKhryKWjG05Tpi1xi1(Whg5eYJim6dsTblOGYePVRG0KL6vAOWKuVcePrUoEl1(Whg5eYJims4eq682hK6lKAF4dJCc5reg9bP2GfuqzI0xPVc)gIrD8wQxybPg(JgPu3PZBsK(6ufRWs7StDfRul8vOLL6v86HKL(UIvQf(YFbcxs9knujPELgUsdL(k9f(Jg5Kiw8hde4wRzvJqrbKoRucdUrSyr0EhZgdLcXMIN8P0MTaA)Amu6l8hnYjrS4pgiWTwZQgHIciDwPegCJyXIO9oMngkfInt(uYi0r5MfuIABmcffq6mrSyr0EhZgJgdfuOjBJQLjtQOxK45f1GW(mkvuK3cG)OgzmN8GYt)xP0x4pAKtIyXFmqGBTMvncffq6Ssjm4gXIfr7DmBmukeBM8PKrOJYnlOe12yekkG0zIyXIO9oMngngkOqt2gvltMurViXZlQbH9zuQOiVf8HroH8ij)v0JAt4eq68wa8h1iJ5KhuE6)csFH)OrojIf)XabU1Aw1iuuaPZkLWGBelweT3XSXqPqSzYNsgHok3SGsuBJrOOasNjIflI27y2y0yOGcnzBuTmzsf9IepVOge2NrPII8wWhg5eYJK0wVdBbMWjG05T0x4pAKtIyXFmqGBTMvncffq6Ssjm4gpWiJdro5TsHytXt(uAZwaTFngk9f(Jg5Kiw8hde4wRzvJqrbKoRucdUXdmY4qKtERui2m5tjJqhLBwqjQTXiuuaPZepWiJdro5DJHcG)OgzmN8GYt)xP0x4pAKtIyXFmqGBTMvncffq6Ssjm4gpWiJdro5TsHyZKpLmcDuUzbLO2gJqrbKot8aJmoe5K3ngkWiuuaPZeXIfr7DmBmAwq6l8hnYjrS4pgiWTwZQgHIciDwPegCJLMqhJGwPsHyZKpLmcDuUXqPVWF0iNeXI)yGa3AnRAekkG0zLsyWn1epafWBUd(Pui2u8KpL2Sfq7xJWk9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbeXdqb8M7GFkfInfp5tPnBb0(1SGHsFH)OrojIf)XabU1Aw1iuuaPZkLWGBQqepafWBUd(Pui2u8KpL2Sfq7xZknu6l8hnYjrS4pgiWTwZQgHIciDwPegCZf3apafWBUd(Pui2u8KpL2Sfq7xJWk9f(Jg5Kiw8hde4wRzvJqrbKoRucdU5IBGhGc4n3b)ukeBM8PKrOJYn(OsuBJrOOasNjxCd8auaV5o4xJWkOqt2gvlt205tf70ek)WFmgqUjSpJsff5T0x4pAKtIyXFmqGBTMvncffq6Ssjm4MlUbEakG3Ch8tPqSzYNsgHok3SGWQe12yekkG0zYf3apafWBUd(1iSc(WiNqEKK26DylWeobKoVL(c)rJCsel(JbcCR1SQrOOasNvkHb3CXnWdqb8M7GFkfInt(uYi0r5MfewLO2gJqrbKotU4g4bOaEZDWVgHvWh5gLEeOEizSyfBARFeobKoVfa)rnYyo5bLNl7JsFH)OrojIf)XabU1Aw1iuuaPZkLWGBU4g4bOaEZDWpLcXMjFkze6OCJpAOsuBJrOOasNjxCd8auaV5o4xJWkGNtoFMyKoPrIdlwKll)hnsYGMrj9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbbQcAz8asal(NsHytXt(uAZwaTFnchdL(c)rJCsel(JbcCR1SQrOOasNvkHb3GavbTmEajGf)tPqSzYNsgHok3i8mujQTXiuuaPZeeOkOLXdibS4Fnchdf8HroH8ijT17WwGjCciDEl9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbeXdAshOd8asal(NsHytXt(uAZwaTFn(OHsFH)OrojIf)XabU1Aw1iuuaPZkLWGBar8GM0b6apGeWI)Pui2m5tjJqhLBewdvIABmcffq6mbeXdAshOd8asal(xJpAOGcnzBuTmztNpvSttO8d)Xya5MW(mkvuK3sFH)OrojIf)XabU1Aw1iuuaPZkLWGBar8GM0b6apGeWI)Pui2m5tjJqhLBewdvIABmcffq6mbeXdAshOd8asal(xJpAOGcnzBuTmPTOZUFy6t)otyFgLkkYBPVWF0iNeXI)yGa3AnRAekkG0zLsyWnxCd8aua)Eq1YtLcXMIN8P0MTaA)AwP0x4pAKtIyXFmqGBTMvncffq6Ssjm4giy8f3apafWVhuT8uPqSP4jFkTzlG2VMvk9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbg4PimukeBkEYNsB2cO9RzY3rZ2jbg4PimK(c)rJCsel(JbcCR1SQTdtHK(c)rJCsel(JbcCR1SQnIT0x4pAKtIyXFmqGBTMvb02bNhC0iL(c)rJCsel(JbcCR1SkupKm2cdANcL0x4pAKtIyXFmqGBTMvH6HKX084EN)t6l8hnYjrS4pgiWTwZQFKcZHwmEajGB5H0x4pAKtIyXFmqGBTMvNjio9Idpp4MsFH)OrojIf)XabU1AwDqRkkmDaTS0x4pAKtIyXFmqGBTMvTvmpKOFkrTngHIciDMiwSiAVJzJXYngk9f(Jg5Kiw8hde4wRzv2y8WrJujQTXiuuaPZeXIfr7DmBm83qPVsFH)OroxRz1pqZJRPi37krTnhuT8r2mcQ1sEyE0SLum8N0x4pAKZ1Aw9HEhd)rJe3PZtPegCZ0dkEJ)9u6l8hnY5AnR(qVJH)OrI705PucdUHNtoFEk9f(Jg5CTMvFO3XWF0iXD68ukHb3abRe12a)rnYyo5bLN(VsPVWF0iNR1S6d9og(JgjUtNNsjm4MqKtUuIABmcffq6mXdmY4qKtEVCJHsFH)OroxRz1h6Dm8hnsCNopLsyWnWapfHHsuBJrOOasNjWapfHrZcsFH)OroxRz1h6Dm8hnsCNopLsyWnFe9DyMtPVWF0iNR1S6d9og(JgjUtNNsjm4Mko4OrQe12yekkG0zILMqhJGwzJHsFH)OroxRz1h6Dm8hnsCNopLsyWnwAcDmcALkrTngHIciDMyPj0XiOv2SG0x4pAKZ1Aw9HEhd)rJe3PZtPegCZimYdopPVsFH)OrojtpO4n(3Z1AwfDY4bKaULhkrTngCqNZJWzN26DCYBcNasN3cgqceX)wUr4AOGbKar8p)BwrcRYkQOb(0bDopcNDAR3XjVjCciDElyajqe)B5gHRWQS0x4pAKtY0dkEJ)9CTMvrNmME8yQe12GGATeOEizSyyYfbvu6l8hnYjz6bfVX)EUwZQIXrJujQTbb1Ajq9qYyXWKlcQO0x4pAKtY0dkEJ)9CTMvp6GXMqjQe12uOjBJQLjhpeJc6ytOejSpJsff5TaeuRLWk4bOZJgjbvu6l8hnYjz6bfVX)EUwZQDAR3nXcZHUBhCEkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMsFH)OrojtpO4n(3Z1AwfbAXHfFf9fAQe12GGATeOEizSyyYfzhMPaeuRLuOjJdlwmm5ISdZuWMrqTwYfOVhoS4ZJXdOLs2Hzk9f(Jg5Km9GI34FpxRzveUMCjenBvIABqqTwcupKmwmm5IGkk9f(Jg5Km9GI34FpxRzvKEeBSfT8tjQTbb1Ajq9qYyXWKlcQO0x4pAKtY0dkEJ)9CTMvT0Ir6rSvIABqqTwcupKmwmm5IGkk9f(Jg5Km9GI34FpxRzviFEEf0Xp07krTniOwlbQhsglgMCrqfL(k9f(Jg5KWZjNppxRzvKEeBCyXNhJ5Kh(Pe128r03HzsUa99WHfFEmEaTusXdGMZgdfGGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1YtbFe9DyMeOEizSyyYfP4bqZ5YnT)wrfT0wVdx8aO5C5pI(omtcupKmwmm5Iu8aO5u6l8hnYjHNtoFEUwZQi9i24WIppgZjp8tjQT5JOVdZKa1djJfdtUifpaAoBmuGb(0bDopcNDAR3XjVjCciDEROIgCqNZJWzN26DCYBcNasN3cgqceX)8Vr4yOIkAekkG0zcmWtry0SGYklWad(i67WmjxG(E4WIppgpGwkP4bqZP)gHIciDMaI4bOaEZDWpbgGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqkQOrOOasNjWapfHrZckRSIkAWhrFhMj5c03dhw85X4b0sjfpaAoBmuacQ1sG6HKXVhuTmzEWluJHkRSaeuRLuOjJdlwmm5ISdZuWasGi(N)ngHIciDMaI4bnPd0bEajGf)t6l8hnYjHNtoFEUwZQMr13gzAIlEgjKpRe128r03HzsG6HKXIHjxKIhanN(3iSgk4JOVdZKCb67Hdl(8y8aAPKIhanNl30(BbiOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uWbDopsHMmoSyXWKlcNasN3c(i67WmjfAY4WIfdtUifpaAoxUP93c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)K(c)rJCs45KZNNR1SQzu9TrMM4INrc5ZkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbiOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uWhrFhMjbQhsglgMCrkEa0CUCt7VvurlT17WfpaAox(JOVdZKa1djJfdtUifpaAoL(c)rJCs45KZNNR1SQzu9TrMM4INrc5ZkrTnFe9DyMeOEizSyyYfP4bqZzJHcmWNoOZ5r4StB9oo5nHtaPZBfv0Gd6CEeo70wVJtEt4eq68wWasGi(N)nchdvurJqrbKotGbEkcJMfuwzbgyWhrFhMj5c03dhw85X4b0sjfpaAo93iuuaPZeqepafWBUd(jWaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fsrfncffq6mbg4PimAwqzLvurd(i67WmjxG(E4WIppgpGwkP4bqZzJHcqqTwcupKm(9GQLjZdEHAmuzLfGGATKcnzCyXIHjxKDyMcgqceX)8VXiuuaPZeqepOjDGoWdibS4FsFH)Oroj8CY5ZZ1AwTffQnfsCyXGWhUIZtjQT5JOVdZKCb67Hdl(8y8aAPKIhanNngkab1Ajq9qY43dQwMmp4fA5gJqrbKotU4g4bOa(9GQLNc(i67Wmjq9qYyXWKlsXdGMZLBA)TIkAPTEhU4bqZ5YFe9DyMeOEizSyyYfP4bqZP0x4pAKtcpNC(8CTMvBrHAtHehwmi8HR48uIAB(i67Wmjq9qYyXWKlsXdGMZgdfyGpDqNZJWzN26DCYBcNasN3kQObh058iC2PTEhN8MWjG05TGbKar8p)BeogQOIgHIciDMad8uegnlOSYcmWGpI(omtYfOVhoS4ZJXdOLskEa0C6VrOOasNjGiEakG3Ch8tGbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKIkAekkG0zcmWtry0SGYkROIg8r03HzsUa99WHfFEmEaTusXdGMZgdfGGATeOEiz87bvltMh8c1yOYklab1AjfAY4WIfdtUi7WmfmGeiI)5FJrOOasNjGiEqt6aDGhqcyX)K(c)rJCs45KZNNR1S6h5Z5vWXBSTddwPonz8VBwrkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMcgqcKJoy8f4bOG)nSc8JEm(Odw6l8hnYjHNtoFEUwZQfdI0SfB7WGNkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMcgqcKJoy8f4bOG)nSc8JEm(Odw6l8hnYjHNtoFEUwZQ24rN8gdcF4IEmgHHHsuBdcQ1sG6HKXIHjxKDyMcqqTwsHMmoSyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMP0x4pAKtcpNC(8CTMvfrlQ1pA2Ir6W8uIABqqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzkyZiOwl5c03dhw85X4b0sj7WmL(c)rJCs45KZNNR1SArff7mMM4Pi8SsuBdcQ1sG6HKXIHjxKDyMcqqTwsHMmoSyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMP0x4pAKtcpNC(8CTMvppgJMibAUX2OEwjQTbb1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZu6l8hnYjHNtoFEUwZQdEeLF4WI7OpDJ3fdJPsuBdcQ1sG6HKXIHjxKDyMcqqTwsHMmoSyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMP0xPVWF0iNKqKtUwRzvJqrbKoRucdUXdmY4qKtERui2m5tjJqhLBwqjQTrSyJ42FtwGWgJhoAKsFH)OrojHiNCTwZQwAXyKompLO2McnzBuTmztNpvSttO8d)Xya5MW(mkvuK3cqqTwYMoFQyNMq5h(JXaYn2wX8iOIsFH)OrojHiNCTwZQ2kMhodJGsuBtHMSnQwM0w0z3pm9PFNjSpJsff5TGbKar8p)xHcR0x4pAKtsiYjxR1S6GwvutCyXxudopPVWF0iNKqKtUwRz1ndNhsujl9f(Jg5KeICY1AnRwWMc5HNIqjKsuBZasGi(N)cpdL(c)rJCscro5ATMvFiFUJH)OrQe12a)rJKm9O2JMTyXWKlY7bzYDA2kO93KIhanNngk9f(Jg5KeICY1AnRo9O2JMTyXWKlLO2MzG2rO5MyPCFJdlgPhZzmMeobKoVL(c)rJCscro5ATMvVa99WHfFEmEaTuPVWF0iNKqKtUwRzvOEizSyyYL0x4pAKtsiYjxR1SAHMmoSyXWKlLO2geuRLuOjJdlwmm5ISdZu6l8hnYjje5KR1AwvS4jNpJdlEqZT0x4pAKtsiYjxR1SkupKmgPdZtjQTzhhPGnfYdpfHsisXdGMt)fwfvCZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8Gxi)nu6l8hnYjje5KR1AwfQhsgJ0H5Pe12GGATeXINC(moS4bn3eurbBgb1AjxG(E4WIppgpGwkbvuWMrqTwYfOVhoS4ZJXdOLskEa0CUCd8hnscupKmgPdZJWkWp6X4JoyPVWF0iNKqKtUwRzvOEizmcuf0YkrTniOwlbQhsglgMCrqffGGATeOEizSyyYfP4bqZ5YnT)wacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8cj9f(Jg5KeICY1AnRc1djJh05K25PsuBZMrqTwYfOVhoS4ZJXdOLsqffCqNZJa1djJ53liCciDElab1AjBgopKOsMSdZuWMrqTwYfOVhoS4ZJXdOLskEa0C6p8hnscupKmEqNtANNewb(rpgF0bR07b0SzbPVWF0iNKqKtUwRzvOEiz8GoN0opvIABqqTwY3zOEyE0SLum8NsVhqZMfK(c)rJCscro5ATMvH6HKXrHOe12GGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1Ytbg8r03HzsG6HKXIHjxKIhanN(VGHkQi8h1iJ5KhuEUCZkvw6l8hnYjje5KR1AwfQhsgJ0H5Pe12GGATKcnzCyXIHjxeurfvCajqe)Z)fewPVWF0iNKqKtUwRzv2y8WrJujQTbb1AjfAY4WIfdtUi7WmvIMhxfQ4HP2MbKar8p)BeUcRs084QqfpmDm4nfoUzbPVWF0iNKqKtUwRzvOEizmcuf0YsFL(c)rJCs(i67WmNR1SQTI5HZWiOe12uOjBJQLjTfD29dtF63zc7ZOurrEl4JOVdZKa1djJfdtUifpaAo93hnuWhrFhMj5c03dhw85X4b0sjfpaAoBmuGbiOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uGbgCqNZJuOjJdlwmm5IWjG05TGpI(omtsHMmoSyXWKlsXdGMZLBA)TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpLvurd8Pd6CEKcnzCyXIHjxeobKoVf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(PSIk(r03HzsG6HKXIHjxKIhanNl30(BLvwyqjPwyqy2lAu0Jk8HLA0jnBL62Io7(j10N(DwQnPNNudIePw4)KLA6j1M0ZtQV4gsDCECzsNmr6l8hnYj5JOVdZCUwZQ2kMhodJGsuBtHMSnQwM0w0z3pm9PFNjSpJsff5TGpI(omtcupKmwmm5Iu8aO5SXqbg4th058iC2PTEhN8MWjG05TIkAWbDopcNDAR3XjVjCciDElyajqe)Z)gHJHkRSadm4JOVdZKCb67Hdl(8y8aAPKIhanN(VGHcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiLvurd(i67WmjxG(E4WIppgpGwkP4bqZzJHcqqTwcupKm(9GQLjZdEHAmuzLfGGATKcnzCyXIHjxKDyMcgqceX)8VXiuuaPZeqepOjDGoWdibS4FsFH)OrojFe9DyMZ1Aw1wX8qI(Pe12uOjBJQLjB68PIDAcLF4pgdi3e2NrPII8wWhrFhMjbb1AXB68PIDAcLF4pgdi3KIHTFcqqTwYMoFQyNMq5h(JXaYn2wX8i7WmfyacQ1sG6HKXIHjxKDyMcqqTwsHMmoSyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMPYc(i67WmjxG(E4WIppgpGwkP4bqZzJHcmab1Ajq9qY43dQwMmp4fA5gJqrbKotU4g4bOa(9GQLNcmWGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(PSIkAGpDqNZJuOjJdlwmm5IWjG05TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpLvuXpI(omtcupKmwmm5Iu8aO5C5M2FRSYsFH)OrojFe9DyMZ1Aw1slgJ0H5Pe12uOjBJQLjB68PIDAcLF4pgdi3e2NrPII8wWhrFhMjbb1AXB68PIDAcLF4pgdi3KIHTFcqqTwYMoFQyNMq5h(JXaYn2slMSdZuGyXgXT)MSaXwX8qI(j9f(Jg5K8r03HzoxRz1bTQOM4WIVOgCEkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbiOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uWhrFhMjbQhsglgMCrkEa0CUCt7VfgusQfgwX7MGFtPgDYs9GwvutP2KEEsnisKAHFwP(IBi10PuxmS9tQHPuBY9Uss9aeIL6jAXs9fs9dZtQPNuJW2OyP(IBqK(c)rJCs(i67WmNR1S6GwvutCyXxudopLO2MpI(omtcupKmwmm5Iu8aO5SXqbg4th058iC2PTEhN8MWjG05TIkAWbDopcNDAR3XjVjCciDElyajqe)Z)gHJHkRSadm4JOVdZKCb67Hdl(8y8aAPKIhanN(BekkG0zciIhGc4n3b)eGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqkROIg8r03HzsUa99WHfFEmEaTusXdGMZgdfGGATeOEiz87bvltMh8c1yOYklab1AjfAY4WIfdtUi7WmfmGeiI)5FJrOOasNjGiEqt6aDGhqcyX)K(c)rJCs(i67WmNR1S6MHZdjQKvIAB(i67WmjxG(E4WIppgpGwkP4bqZzJHcqqTwcupKm(9GQLjZdEHwUXiuuaPZKlUbEakGFpOA5PGpI(omtcupKmwmm5Iu8aO5C5M2FlmOKulmSI3nb)Msn6KL6ndNhsujl1M0ZtQbrIul8Zk1xCdPMoL6IHTFsnmLAtU3vsQhGqSuprlwQVqQFyEsn9KAe2gfl1xCdI0x4pAKtYhrFhM5CTMv3mCEirLSsuBZhrFhMjbQhsglgMCrkEa0C2yOad8Pd6CEeo70wVJtEt4eq68wrfn4GoNhHZoT174K3eobKoVfmGeiI)5FJWXqLvwGbg8r03HzsUa99WHfFEmEaTusXdGMt)xWqbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKYkQObFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbiOwlbQhsg)Eq1YK5bVqngQSYcqqTwsHMmoSyXWKlYomtbdibI4F(3yekkG0zciIh0Koqh4bKaw8pPVWF0iNKpI(omZ5AnRwWMc5HNIqjKsuBZhrFhMj5c03dhw85X4b0sjfpaAo93iuuaPZKAIhGc4n3b)e8r03HzsG6HKXIHjxKIhanN(BekkG0zsnXdqb8M7GFcm4GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanNl30(Bfv8GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanN(BekkG0zsnXdqb8M7GFkQOpDqNZJuOjJdlwmm5IWjG05TYcqqTwcupKm(9GQLjZdEH8FLc2mcQ1sUa99WHfFEmEaTuYomtHbLKAHbH)twQNIqjKutTs9f3qQHCl1GOudfl1rk1)wQHCl1Mr6dNuJWsnQOuBJsQ7r2YLuFEqk1Nhl1dqbPEZDWpLK6bienBL6jAXsTjl1EGrwQHtQ7mmpP(mdPgQhswQFpOA5Pud5wQpp4K6lUHuBcZ0hoPwyo05j1OtEtK(c)rJCs(i67WmNR1SAbBkKhEkcLqkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbiOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uWhrFhMjbQhsglgMCrkEa0CUCt7VfgusQfge(pzPEkcLqsTj98KAquQn94uQfJ5KI0zIul8Zk1xCdPMoL6IHTFsnmLAtU3vsQhGqSuprlwQVqQFyEsn9KAe2gfl1xCdI0x4pAKtYhrFhM5CTMvlytH8WtrOesjQT5JOVdZKa1djJfdtUifpaAoBmuGbg4th058iC2PTEhN8MWjG05TIkAWbDopcNDAR3XjVjCciDElyajqe)Z)gHJHkRSadm4JOVdZKCb67Hdl(8y8aAPKIhanN(BekkG0zciIhGc4n3b)eGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqkROIg8r03HzsUa99WHfFEmEaTusXdGMZgdfGGATeOEiz87bvltMh8c1yOYklab1AjfAY4WIfdtUi7WmfmGeiI)5FJrOOasNjGiEqt6aDGhqcyX)uw6l8hnYj5JOVdZCUwZQxG(E4WIppgpGwQsuBZhrFhMjbQhsglgMCrkEa0CUSWAOaEo58zIr6KgjoSyrUS8F0ijdAgL0x4pAKtYhrFhM5CTMvVa99WHfFEmEaTuLO2geuRLa1djJFpOAzY8GxOLBmcffq6m5IBGhGc43dQwEk4GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanNl30(BbFe9DyMeOEizSyyYfP4bqZP)gHIciDMCXnWdqb8M7GFc(WiNqEeH8ROqs4eq68wWhrFhMjPGnfYdpfHsisXdGMZLBeUcdkj1cdRy4xrHuysQf(pzP(IBi1uRudIsnDk1rk1)wQHCl1Mr6dNuJWsnQOuBJsQ7r2YLuFEqk1Nhl1dqbPEZDWpIuVI3PTPuBsppPUcrPMAL6ZJL6d6CEsnDk1hieNePwy2I(wQbPgHEs9fs9aeIL6jAXsTjl1pKsTW8QsnDm4nfoU7Nud2JlP(IBi1CUNsFH)OrojFe9DyMZ1Aw9c03dhw85X4b0svIABqqTwcupKm(9GQLjZdEHwUXiuuaPZKlUbEakGFpOA5PGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(jWN(WiNqEeH8ROqs4eq68wyqjPwyyPif((kg(vuifMKAH)twQV4gsn1k1GOutNsDKs9VLAi3sTzK(Wj1iSuJkk12OK6EKTCj1NhKs95Xs9auqQ3Ch8Ji1R4DABk1M0ZtQRquQPwP(8yP(GoNNutNs9bcXjr6l8hnYj5JOVdZCUwZQxG(E4WIppgpGwQsuBdcQ1sG6HKXVhuTmzEWl0YngHIciDMCXnWdqb87bvlpf4th058ifAY4WIfdtUiCciDEl4JOVdZKa1djJfdtUifpaAo93iuuaPZKlUbEakG3Ch8t6l8hnYj5JOVdZCUwZQxG(E4WIppgpGwQsuBdcQ1sG6HKXVhuTmzEWl0YngHIciDMCXnWdqb87bvlpf8r03HzsG6HKXIHjxKIhanNl30(BPVWF0iNKpI(omZ5AnRc1djJfdtUuIABmWNoOZ5r4StB9oo5nHtaPZBfv0Gd6CEeo70wVJtEt4eq68wWasGi(N)nchdvwzbFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotar8auaV5o4NaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fsacQ1sk0KXHflgMCr2Hzkyajqe)Z)gJqrbKotar8GM0b6apGeWI)jmOKulmi8FYsnik1uRuFXnKA6uQJuQ)Tud5wQnJ0hoPgHLAurP2gLu3JSLlP(8GuQppwQhGcs9M7GFkj1dqiA2k1t0IL6ZdoP2KLApWil1CgOTEs9asqQHCl1NhCs95Xfl10PuNXj1qVyy7NudsDHMSuhwPwmm5sQ3HzsK(c)rJCs(i67WmNR1SAHMmoSyXWKlLO2geuRLuOjJdlwmm5ISdZuWhrFhMj5c03dhw85X4b0sjfpaAo93iuuaPZKkeXdqb8M7GFcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88Gxibg8r03HzsG6HKXIHjxKIhanN(VGWQOIBgb1AjxG(E4WIppgpGwkbvuzHbLKAHbH)twQRquQPwP(IBi10PuhPu)BPgYTuBgPpCsncl1OIsTnkPUhzlxs95bPuFESupafK6n3b)usQhGq0SvQNOfl1NhxSutNPpCsn0lg2(j1GuxOjl17WmLAi3s95bNudIsTzK(Wj1i8hdwQbJaTdiDwQ3OfnBL6cnzI0x4pAKtYhrFhM5CTMvflEY5Z4WIh0CRe12GGATeOEiz87bvltMh8c1yOGpmYjKhri)kkKeobKoVfgusQfgwXWVIcPWKulmVQutNs9asqQ9qZ2YpPgYTuVIVUWBk1qXs9fHuZkiY5KAKL6lKA0jl1IXqQVqQN(mkZcFyPgsPMv4kqQbePMMs95Xs9f3qQnP5omjs9kiF(WuQrNSutpP(cPEacXsDpmL63dQwwQxXxFk10CEqEePVWF0iNKpI(omZ5AnRkw8KZNXHfpO5wjQTzZiOwl5c03dhw85X4b0sjOIc8PpmYjKhri)kkKeobKoVfgusQfgwksHVVIHFffsHjPw4)KLAXyi1xi1tFgLzHpSudPuZkCfi1aIuttP(8yP(IBi1M0ChMePVsFH)OrojvCWrJCTMvncffq6Ssjm4glnHogbTsLcXMjFkze6OCZckrTniOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKaFcb1AjfANXHfFEfZtcQOalT17WfpaAoxUXadgqccFd(JgjbQhsgJ0H5r(yEklmd8hnscupKmgPdZJWkWp6X4JoyLL(c)rJCsQ4GJg5AnRc1djJrGQGwwjQT5JOVdZKCb67Hdl(8y8aAPKIhanNngkWaeuRLa1djJFpOAzY8Gxi)ncffq6m5IBGhGc43dQwEk4GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanNl30(BbFe9DyMeOEizSyyYfP4bqZP)gHIciDMCXnWdqb8M7GFc(WiNqEeH8ROqs4eq68wWhrFhMjPGnfYdpfHsisXdGMZLBeUkl9f(Jg5KuXbhnY1AwfQhsgJavbTSsuBZhrFhMj5c03dhw85X4b0sjfpaAoBmuGbiOwlbQhsg)Eq1YK5bVq(BekkG0zYf3apafWVhuT8uWbDopsHMmoSyXWKlcNasN3c(i67WmjfAY4WIfdtUifpaAoxUP93c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)e4tFyKtipIq(vuijCciDERS0x4pAKtsfhC0ixRzvOEizmcuf0YkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbgGGATeOEiz87bvltMh8c5VrOOasNjxCd8aua)Eq1Ytb(0bDopsHMmoSyXWKlcNasN3c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)uw6l8hnYjPIdoAKR1SkupKmgbQcAzLO2MpI(omtYfOVhoS4ZJXdOLskEa0C2yOadqqTwcupKm(9GQLjZdEH83iuuaPZKlUbEakGFpOA5PGpI(omtcupKmwmm5Iu8aO5C5M2FRS03vSs9smVL6lKA6qSZdopPEEf9pPEY(mkNppL6OKAeuAFl1qk1q)4kHJAKLApUyI03vSsn8hnYjPIdoAKR1S68k6F4j7ZOC(SsuBZMrqTwsbBkKhEkcLqyJO9KlaH2PNFK5bVqnBgb1AjfSPqE4PiucHnI2tUaeANE(rgGc45bVqcqqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzQucdUPdZdpfHsi88GxiHjOEizmshMNWeupKmgbQcAzPVWF0iNKko4OrUwZQq9qYyeOkOLvIAB2mcQ1skytH8WtrOecBeTNCbi0o98Jmp4fQzZiOwlPGnfYdpfHsiSr0EYfGq70ZpYauapp4fsGbiOwlbQhsglgMCr2HzQOIiOwlbQhsglgMCrkEa0CUCt7VvwGbiOwlPqtghwSyyYfzhMPIkIGATKcnzCyXIHjxKIhanNl30(BLL(c)rJCsQ4GJg5AnRc1djJr6W8uIAB2XrkytH8WtrOeIu8aO50FHvrf3mcQ1skytH8WtrOecBeTNCbi0o98Jmp4fYFdL(c)rJCsQ4GJg5AnRc1djJr6W8uIABqqTwIyXtoFghw8GMBcQOGnJGATKlqFpCyXNhJhqlLGkkyZiOwl5c03dhw85X4b0sjfpaAoxUb(JgjbQhsgJ0H5ryf4h9y8rhS0x4pAKtsfhC0ixRzvOEiz8GoN0opvIAB2mcQ1sUa99WHfFEmEaTucQOGd6CEeOEizm)EbHtaPZBbiOwlzZW5HevYKDyMcmyZiOwl5c03dhw85X4b0sjfpaAo9h(JgjbQhsgpOZjTZtcRa)OhJp6GvuXpI(omtIyXtoFghw8GMBsXdGMt)nurf)WiNqEeH8ROqs4eq68wzLEpGMnli9f(Jg5KuXbhnY1AwfQhsgpOZjTZtLO2geuRL8DgQhMhnBjfd)jab1AjScIqU5nwmoopk0jOIsFH)OrojvCWrJCTMvH6HKXd6Cs78ujQTbb1AjFNH6H5rZwsXWFcmab1Ajq9qYyXWKlcQOIkIGATKcnzCyXIHjxeurfvCZiOwl5c03dhw85X4b0sjfpaAo9h(JgjbQhsgpOZjTZtcRa)OhJp6GvwP3dOzZcsFH)OrojvCWrJCTMvH6HKXd6Cs78ujQTbb1AjFNH6H5rZwsXWFcqqTwY3zOEyE0SLmp4fQbb1AjFNH6H5rZwYauapp4fsP3dOzZcsFH)OrojvCWrJCTMvH6HKXd6Cs78ujQTbb1AjFNH6H5rZwsXWFcqqTwY3zOEyE0SLu8aO5C5gdmab1AjFNH6H5rZwY8GxiHzG)OrsG6HKXd6Cs78KWkWp6X4JoyLxR93kR07b0SzbPVWF0iNKko4OrUwZQjFECHpEiYZtjQTXGITfp9aKoROI(0rFHOzRYcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxibiOwlbQhsglgMCr2HzkyZiOwl5c03dhw85X4b0sj7WmL(c)rJCsQ4GJg5AnRc1djJJcrjQTbb1Ajq9qY43dQwMmp4fA5gJqrbKotU4g4bOa(9GQLNsFH)OrojvCWrJCTMvNOICLHrqjQTzajqe)B5MvOWkab1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZu6l8hnYjPIdoAKR1S60JApA2IfdtUuIABqqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzkyZiOwl5c03dhw85X4b0sj7Wmf8r03HzsyJXdhnssXdGMt)nuWhrFhMjbQhsglgMCrkEa0C6VHc(i67WmjxG(E4WIppgpGwkP4bqZP)gkWaF6GoNhPqtghwSyyYfHtaPZBfv0Gd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0C6VHkRS0x4pAKtsfhC0ixRzvOEizmshMNsuBdcQ1sk0oJdl(8kMNeurbiOwlbQhsg)Eq1YK5bVq(7JsFH)OrojvCWrJCTMvH6HKXiqvqlRe12mGeiI)TSrOOasNjiqvqlJhqcyX)e8r03HzsyJXdhnssXdGMt)nuacQ1sG6HKXIHjxKDyMcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88Gxib8CY5ZeJ0jnsCyXICz5)Orsg0mkPVWF0iNKko4OrUwZQq9qYyeOkOLvIAB(i67WmjxG(E4WIppgpGwkP4bqZzJHcm4JOVdZKuOjJdlwmm5Iu8aO5SXqfv8JOVdZKa1djJfdtUifpaAoBmuzbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlK0x4pAKtsfhC0ixRzvOEizmcuf0YkrTndibI4Fl3yekkG0zccuf0Y4bKaw8pbiOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxibFe9DyMe2y8WrJKu8aO50FdL(c)rJCsQ4GJg5AnRc1djJrGQGwwjQTbb1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZuacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8cj4GoNhbQhsghfcHtaPZBbFe9DyMeOEizCuiKIhanNl30(BbdibI4Fl3ScnuWhrFhMjHngpC0ijfpaAo93qPVWF0iNKko4OrUwZQq9qYyeOkOLvIABqqTwcupKmwmm5IGkkab1Ajq9qYyXWKlsXdGMZLBA)TaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fs6l8hnYjPIdoAKR1SkupKmgbQcAzLO2geuRLuOjJdlwmm5IGkkab1AjfAY4WIfdtUifpaAoxUP93cqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiPVWF0iNKko4OrUwZQq9qYyeOkOLvIABqqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzkyZiOwl5c03dhw85X4b0sjOIc2mcQ1sUa99WHfFEmEaTusXdGMZLBA)TaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fs6l8hnYjPIdoAKR1SkupKmgPdZt6l8hnYjPIdoAKR1SkBmE4OrQenpUkuXdtTndibI4F(3iCfwLO5XvHkEy6yWBkCCZcsFH)OrojvCWrJCTMvH6HKXiqvqll9v6l8hnYjXstOJrqRCTMvH6HKXd6Cs78ujQTbb1AjFNH6H5rZwsXWFk9EanBwq6l8hnYjXstOJrqRCTMvH6HKXiDyEsFH)OrojwAcDmcALR1SkupKmgbQcAzPVsFH)OrojqWR1SQTI5He9tjQTPqt2gvlt205tf70ek)WFmgqUjSpJsff5TGpI(omtccQ1I305tf70ek)WFmgqUjfdB)eGGATKnD(uXonHYp8hJbKBSTI5r2HzkWaeuRLa1djJfdtUi7WmfGGATKcnzCyXIHjxKDyMc2mcQ1sUa99WHfFEmEaTuYomtLf8r03HzsUa99WHfFEmEaTusXdGMZgdfyacQ1sG6HKXVhuTmzEWl0YngHIciDMabJV4g4bOa(9GQLNcmWGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(PSIkAGpDqNZJuOjJdlwmm5IWjG05TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpLvuXpI(omtcupKmwmm5Iu8aO5C5M2FRSYsFH)OrojqWR1SQLwmgPdZtjQTXGcnzBuTmztNpvSttO8d)Xya5MW(mkvuK3c(i67WmjiOwlEtNpvSttO8d)Xya5MumS9tacQ1s205tf70ek)WFmgqUXwAXKDyMcel2iU93Kfi2kMhs0pLvurdk0KTr1YKnD(uXonHYp8hJbKBc7ZOurrEl4OdUXqLL(c)rJCsGGxRzvBfZdNHrqjQTPqt2gvltAl6S7hM(0VZe2NrPII8wWhrFhMjbQhsglgMCrkEa0C6VpAOGpI(omtYfOVhoS4ZJXdOLskEa0C2yOadqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT8uGbgCqNZJuOjJdlwmm5IWjG05TGpI(omtsHMmoSyXWKlsXdGMZLBA)TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpLvurd8Pd6CEKcnzCyXIHjxeobKoVf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(PSIk(r03HzsG6HKXIHjxKIhanNl30(BLvw6l8hnYjbcETMvTvmpCggbLO2McnzBuTmPTOZUFy6t)otyFgLkkYBbFe9DyMeOEizSyyYfP4bqZzJHcmWad(i67WmjxG(E4WIppgpGwkP4bqZP)gHIciDMaI4bOaEZDWpbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKYkQObFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbiOwlbQhsg)Eq1YK5bVql3yekkG0zcem(IBGhGc43dQwEQSYcqqTwsHMmoSyXWKlYomtLL(c)rJCsGGxRz1lqFpCyXNhJhqlvjQTPqt2gvltMurViXZlQbH9zuQOiVfiwSrC7VjlqyJXdhnsPVWF0iNei41AwfQhsglgMCPe12uOjBJQLjtQOxK45f1GW(mkvuK3cmqSyJ42FtwGWgJhoAKkQOyXgXT)MSa5c03dhw85X4b0svw6l8hnYjbcETMvzJXdhnsLO2MJoy)9rdfuOjBJQLjtQOxK45f1GW(mkvuK3cqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT8uWhrFhMj5c03dhw85X4b0sjfpaAoBmuWhrFhMjbQhsglgMCrkEa0CUCt7VL(c)rJCsGGxRzv2y8WrJujQT5Od2FF0qbfAY2OAzYKk6fjEErniSpJsff5TGpI(omtcupKmwmm5Iu8aO5SXqbgyGbFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotar8auaV5o4NaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fszfv0GpI(omtYfOVhoS4ZJXdOLskEa0C2yOaeuRLa1djJFpOAzY8GxOLBmcffq6mbcgFXnWdqb87bvlpvwzbiOwlPqtghwSyyYfzhMPYkrZJRcv8WuBdcQ1sMurViXZlQbzEWludcQ1sMurViXZlQbzakGNh8cPenpUkuXdthdEtHJBwq6l8hnYjbcETMvh0QIAIdl(IAW5Pe12yWhrFhMjbQhsglgMCrkEa0C6VWtyvuXpI(omtcupKmwmm5Iu8aO5C5gFuzbFe9DyMKlqFpCyXNhJhqlLu8aO5SXqbgGGATeOEiz87bvltMh8cTCJrOOasNjqW4lUbEakGFpOA5Padm4GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanNl30(BbFe9DyMeOEizSyyYfP4bqZP)cRYkQOb(0bDopsHMmoSyXWKlcNasN3c(i67Wmjq9qYyXWKlsXdGMt)fwLvuXpI(omtcupKmwmm5Iu8aO5C5M2FRSYsFH)OrojqWR1SAbBkKhEkcLqkrTnFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotQjEakG3Ch8tWhrFhMjbQhsglgMCrkEa0C6VrOOasNj1epafWBUd(jWGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7VvuXd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0C6VrOOasNj1epafWBUd(POI(0bDopsHMmoSyXWKlcNasN3klab1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtbBgb1AjxG(E4WIppgpGwkzhMP0x4pAKtce8AnRwWMc5HNIqjKsuBZhrFhMj5c03dhw85X4b0sjfpaAoBmuGbiOwlbQhsg)Eq1YK5bVql3yekkG0zcem(IBGhGc43dQwEkWadoOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZ5YnT)wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NYkQOb(0bDopsHMmoSyXWKlcNasN3c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)uwrf)i67Wmjq9qYyXWKlsXdGMZLBA)TYkl9f(Jg5KabVwZQfSPqE4PiucPe128r03HzsG6HKXIHjxKIhanNngkWadm4JOVdZKCb67Hdl(8y8aAPKIhanN(BekkG0zciIhGc4n3b)eGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqkROIg8r03HzsUa99WHfFEmEaTusXdGMZgdfGGATeOEiz87bvltMh8cTCJrOOasNjqW4lUbEakGFpOA5PYklab1AjfAY4WIfdtUi7Wmvw6l8hnYjbcETMv3mCEirLSsuBZhrFhMjbQhsglgMCrkEa0C2yOadmWGpI(omtYfOVhoS4ZJXdOLskEa0C6VrOOasNjGiEakG3Ch8tacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8cPSIkAWhrFhMj5c03dhw85X4b0sjfpaAoBmuacQ1sG6HKXVhuTmzEWl0YngHIciDMabJV4g4bOa(9GQLNkRSaeuRLuOjJdlwmm5ISdZuzPVWF0iNei41Aw9c03dhw85X4b0svIABqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT8uGbgCqNZJuOjJdlwmm5IWjG05TGpI(omtsHMmoSyXWKlsXdGMZLBA)TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpLvurd8Pd6CEKcnzCyXIHjxeobKoVf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(PSIk(r03HzsG6HKXIHjxKIhanNl30(BLL(c)rJCsGGxRzvOEizSyyYLsuBJbg8r03HzsUa99WHfFEmEaTusXdGMt)ncffq6mbeXdqb8M7GFcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiLvurd(i67WmjxG(E4WIppgpGwkP4bqZzJHcqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT8uzLfGGATKcnzCyXIHjxKDyMsFH)OrojqWR1SAHMmoSyXWKlLO2geuRLuOjJdlwmm5ISdZuGbg8r03HzsUa99WHfFEmEaTusXdGMt)xPHcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiLvurd(i67WmjxG(E4WIppgpGwkP4bqZzJHcqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT8uzLfyWhrFhMjbQhsglgMCrkEa0C6)ccRIkUzeuRLCb67Hdl(8y8aAPeurLL(c)rJCsGGxRzvXINC(moS4bn3krTniOwlzZW5HevYeurbBgb1AjxG(E4WIppgpGwkbvuWMrqTwYfOVhoS4ZJXdOLskEa0CUCdcQ1selEY5Z4WIh0CtgGc45bVqcZa)rJKa1djJr6W8iSc8JEm(Odw6l8hnYjbcETMvH6HKXiDyEkrTniOwlzZW5HevYeurbgyWbDopsXZiH8zcNasN3cG)OgzmN8GYZLfEkROIWFuJmMtEq55YcRYsFH)OrojqWR1S6evKRmmcsFH)OrojqWR1SkupKmokeLO2geuRLa1djJFpOAzY8GxOgdL(c)rJCsGGxRz1KppUWhpe55Pe12yqX2INEasNvurF6OVq0SvzbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlK0x4pAKtce8AnRo9O2JMTyXWKlLO2geuRLa1djJfdtUi7WmfGGATKcnzCyXIHjxKDyMc2mcQ1sUa99WHfFEmEaTuYomtbFe9DyMeOEizSyyYfP4bqZP)gk4JOVdZKCb67Hdl(8y8aAPKIhanN(BOad8Pd6CEKcnzCyXIHjxeobKoVvurdoOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZP)gQSYsFH)OrojqWR1SkupKmEqNtANNkrTniOwl57mupmpA2skg(tqHMSnQwMa1djJPPLM0Zpc7ZOurrEl4GoNhbgIDQL(WrJKWjG05Ta4pQrgZjpO8C5vO0x4pAKtce8AnRc1djJh05K25PsuBdcQ1s(od1dZJMTKIH)euOjBJQLjq9qYyAAPj98JW(mkvuK3cG)OgzmN8GYZLxrsFH)OrojqWR1SkupKmMvqShtAKkrTniOwlbQhsg)Eq1YK5bVqlJGATeOEiz87bvltgGc45bVqsFH)OrojqWR1SkupKmMvqShtAKkrTniOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKaXInIB)nzbcupKmgbQcAzPVWF0iNei41AwfQhsgJavbTSsuBdcQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8cj9f(Jg5KabVwZQSX4HJgPs084Qqfpm12mGeiI)5FJWvyvIMhxfQ4HPJbVPWXnli9v6l8hnYjbg4PimwRz1lqFpCyXNhJhqlvjQTXGpI(omtcupKmwmm5Iu8aO5SXqfv8JOVdZKuOjJdlwmm5Iu8aO5C5M2FRSaeuRLuOjJdlwmm5ISdZu6l8hnYjbg4PimwRzvOEizSyyYLsuBdcQ1sk0KXHflgMCr2Hzk9f(Jg5Kad8uegR1SAHMmoSyXWKlLO2geuRLuOjJdlwmm5ISdZu6l8hnYjbg4PimwRzvOEizmcuf0YkrTniOwlbQhsglgMCrqffGGATeOEizSyyYfP4bqZ5YnWF0ijq9qY4bDoPDEsyf4h9y8rhSaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fs6l8hnYjbg4PimwRzvOEizCuikrTniOwlbQhsg)Eq1YK5bVqlJGATeOEiz87bvltgGc45bVqcqqTwsHMmoSyXWKlYomtbiOwlbQhsglgMCr2HzkyZiOwl5c03dhw85X4b0sj7WmL(c)rJCsGbEkcJ1AwfQhsgJavbTSsuBdcQ1sk0KXHflgMCr2Hzkab1Ajq9qYyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMPaeuRLa1djJFpOAzY8GxOgeuRLa1djJFpOAzYauapp4fs6l8hnYjbg4PimwRzvOEiz8GoN0opv69aA2SG0x4pAKtcmWtrySwZQSX4HJgPs084Qqfpm12mGeiI)5FJWvyvIMhxfQ4HPJbVPWXnli9f(Jg5Kad8uegR1SkupKmokeLO2geuRLa1djJFpOAzY8GxOLrqTwcupKm(9GQLjdqb88GxiPVWF0iNeyGNIWyTMvH6HKXiqvqll9f(Jg5Kad8uegR1SkupKmgPdZt6R0x4pAKtYimYdoV1AwfPttHWq6NsuBZimYdopYMopiF2)Mfmu6l8hnYjzeg5bN3AnRkw8KZNXHfpO5w6l8hnYjzeg5bN3AnRc1djJh05K25PsuBZimYdopYMopiFE5fmu6l8hnYjzeg5bN3AnRc1djJJcr6l8hnYjzeg5bN3AnRAPfJr6W8CQa65fLtvLoq7WrJCfOa75o35C]] )


end
