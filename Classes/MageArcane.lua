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


    spec:RegisterPack( "Arcane", 20201020, [[d0Kc5dqiQkYIiOGhPKq0LiOkkBIaFIQcgff0POaRIGIIxPKYSirUfbvr1Uq8lLKggjQJPeSmLe9mQk00iOQUgbL2Msc13iOIXrqLohvfvRJGImpLOUNuSpQQ6GkjKwOsQEivffFujHqJKGIs5KeuLSsQk9sLecMjvfLUjbvrANkr(jbvrmuckkvlLGIQEkjnvLqxLGQuFLGIsglbfAVu5VqnysDyWIH4XQAYk1LrTzk9zP0OPkNgPvtqrLxtqMTuDBf2TOFlmCcDCLeSCjpxrtxLRdPTtH(ofnEsW5PQY6jOkmFsO9t0UfCl6u3WXULwPYRu5fuELktwWN7JR0hfUo1Zpr2PkcVqql7utyWo1v06HKDQIGF9a2UfDQZaTE2P6DN4uyA1vBPNhkc5JXQt6aTdhnYVa7T6Ko(vDQiO0(j8kDio1nCSBPvQ8kvEbLxPYKf85(4k9XfCQtr(DlTIxPt1JU3C6qCQBE(o1vKsTWtHwwQxrRhsw67ksPw4j)fiCj1RuzLK6vQ8kv2P2PZB6w0PgICYLBr3sl4w0PYjG05TBDNAi6uN85uH)Or6uncffq6St1i0rzN6co1VOhxuWPkwSrC7VjlqyJXdhnsNQrOWjmyNQhyKXHiN82DULwPBrNkNasN3U1DQFrpUOGtTqt2gvlt205tf70ek)WFmgqUj8kGsff5TulqQrqTwYMoFQyNMq5h(JXaYn2wX8iOIov4pAKovlTymshMN7Cl5JUfDQCciDE7w3P(f94Ico1cnzBuTmPTOZUFy6t)ot4vaLkkYBPwGupGeiI)j1(l1(CH1Pc)rJ0PARyE4mmcUZTKW3TOtf(JgPtDqRkQjoS4lQbNNtLtaPZB36UZTKW6w0Pc)rJ0PUz48qIkzNkNasN3U1DNBPvSBrNkNasN3U1DQFrpUOGtDajqe)tQ9xQf(k7uH)Or6ulytH8WtrOeYDULeoUfDQCciDE7w3P(f94Icov4pAKKPh1E0SflgMCrEpitUtZwPwGu3(BsXdGMtPUrQv2Pc)rJ0P(q(Chd)rJ0DULeUUfDQCciDE7w3P(f94Ico1zG2rO5MyPCFJdlgPhZzmMeobKoVDQWF0iDQtpQ9Ozlwmm5YDUL85UfDQWF0iDQxG(E4WIppgpGwQtLtaPZB36UZT0ck7w0Pc)rJ0Pc1djJfdtUCQCciDE7w3DULwyb3IovobKoVDR7u)IECrbNkcQ1sk0KXHflgMCr2Hz6uH)Or6ul0KXHflgMC5o3slSs3Iov4pAKovXINC(moS4bn3ovobKoVDR7o3sl4JUfDQCciDE7w3P(f94Ico1DCKc2uip8uekHifpaAoLA)LAHvQvurPEZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8GxiP2FPwzNk8hnsNkupKmgPdZZDULwq47w0PYjG05TBDN6x0Jlk4urqTwIyXtoFghw8GMBcQOulqQ3mcQ1sUa99WHfFEmEaTucQOulqQ3mcQ1sUa99WHfFEmEaTusXdGMtPE5gPg(JgjbQhsgJ0H5ryf4h9y8rhStf(JgPtfQhsgJ0H55o3sliSUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIsTaPgb1Ajq9qYyXWKlsXdGMtPE5gPU93sTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fYPc)rJ0Pc1djJrGQGw2DULwyf7w0PYjG05TBDNk8hnsNkupKmEqNtANNo13dOPtDbN6x0Jlk4u3mcQ1sUa99WHfFEmEaTucQOulqQpOZ5rG6HKX87feobKoVLAbsncQ1s2mCEirLmzhMPulqQ3mcQ1sUa99WHfFEmEaTusXdGMtP2FPg(JgjbQhsgpOZjTZtcRa)OhJp6GDNBPfeoUfDQCciDE7w3Pc)rJ0Pc1djJh05K25Pt99aA6uxWP(f94IcoveuRL8DgQhMhnBjfd)5o3sliCDl6u5eq682TUt9l6XffCQiOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjxCd8aua)Eq1YtPwGuBOu)r03HzsG6HKXIHjxKIhanNsT)s9ckl1kQOud)rnYyo5bLNs9Yns9kLAdCQWF0iDQq9qY4OqCNBPf85UfDQCciDE7w3P(f94IcoveuRLuOjJdlwmm5IGkk1kQOupGeiI)j1(l1liSov4pAKovOEizmshMN7ClTsLDl6u5eq682TUtf(JgPtLngpC0iDQ084Qqfpm16uhqceX)8Vr4kSovAECvOIhMog8Mch7uxWP(f94IcoveuRLuOjJdlwmm5ISdZ0DULw5cUfDQWF0iDQq9qYyeOkOLDQCciDE7w3DUZPYZjNppDl6wAb3IovobKoVDR7u)IECrbN6hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)wQvurP2sB9oCXdGMtPEzP(JOVdZKa1djJfdtUifpaAoDQWF0iDQi9i24WIppgZjp8ZDULwPBrNkNasN3U1DQFrpUOGt9JOVdZKa1djJfdtUifpaAoL6gPwzPwGuBOu7ts9bDopcNDAR3XjVjCciDEl1kQOuBOuFqNZJWzN26DCYBcNasN3sTaPEajqe)tQ9VrQfokl1kQOuBekkG0zcmWtryi1ns9csTbsTbsTaP2qP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsT)sTrOOasNjGiEakG3Ch8tQfi1gk1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqsTIkk1gHIciDMad8uegsDJuVGuBGuBGuROIsTHs9hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuJGATeOEiz87bvltMh8cj1nsTYsTbsTbsTaPgb1AjfAY4WIfdtUi7WmLAbs9asGi(Nu7FJuBekkG0zciIh0Koqh4bKaw8pNk8hnsNkspInoS4ZJXCYd)CNBjF0TOtLtaPZB36o1VOhxuWP(r03HzsG6HKXIHjxKIhanNsT)nsTWQSulqQ)i67WmjxG(E4WIppgpGwkP4bqZPuVCJu3(BPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8ZPc)rJ0PAgvFBKPjU4zKq(S7Clj8Dl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zYf3apafWVhuT8uQfi1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BPwrfLAlT17WfpaAoL6LL6pI(omtcupKmwmm5Iu8aO50Pc)rJ0PAgvFBKPjU4zKq(S7CljSUfDQCciDE7w3P(f94Ico1pI(omtcupKmwmm5Iu8aO5uQBKALLAbsTHsTpj1h058iC2PTEhN8MWjG05TuROIsTHs9bDopcNDAR3XjVjCciDEl1cK6bKar8pP2)gPw4OSuROIsTrOOasNjWapfHHu3i1li1gi1gi1cKAdLAdL6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1gHIciDMaI4bOaEZDWpPwGuBOuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1kQOuBekkG0zcmWtryi1ns9csTbsTbsTIkk1gk1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsncQ1sG6HKXVhuTmzEWlKu3i1kl1gi1gi1cKAeuRLuOjJdlwmm5ISdZuQfi1dibI4FsT)nsTrOOasNjGiEqt6aDGhqcyX)CQWF0iDQMr13gzAIlEgjKp7o3sRy3IovobKoVDR7u)IECrbN6hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9hrFhMjbQhsglgMCrkEa0Ck1l3i1T)wQvurP2sB9oCXdGMtPEzP(JOVdZKa1djJfdtUifpaAoDQWF0iDQTOqTPqIdlgeEWvCEUZTKWXTOtLtaPZB36o1VOhxuWP(r03HzsG6HKXIHjxKIhanNsDJuRSulqQnuQ9jP(GoNhHZoT174K3eobKoVLAfvuQnuQpOZ5r4StB9oo5nHtaPZBPwGupGeiI)j1(3i1chLLAfvuQncffq6mbg4PimK6gPEbP2aP2aPwGuBOuBOu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAdLAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiPwrfLAJqrbKotGbEkcdPUrQxqQnqQnqQvurP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQrqTwcupKm(9GQLjZdEHK6gPwzP2aP2aPwGuJGATKcnzCyXIHjxKDyMsTaPEajqe)tQ9VrQncffq6mbeXdAshOd8asal(Ntf(JgPtTffQnfsCyXGWdUIZZDULeUUfDQCciDE7w3Pc)rJ0P(r(CEfC8gB7WGDQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLAbs9asGC0bJVapafKA)BKAwb(rpgF0b7u70KX)2PUIDNBjFUBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLAbs9asGC0bJVapafKA)BKAwb(rpgF0b7uH)Or6ulgePzl22HbpDNBPfu2TOtLtaPZB36o1VOhxuWPIGATeOEizSyyYfzhMPulqQrqTwsHMmoSyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMov4pAKovB8OtEJbHhCrpgJWWWDULwyb3IovobKoVDR7u)IECrbNkcQ1sG6HKXIHjxKDyMsTaPgb1AjfAY4WIfdtUi7WmLAbs9MrqTwYfOVhoS4ZJXdOLs2Hz6uH)Or6ufrlQ1pA2Ir6W8CNBPfwPBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmDQWF0iDQfvuSZyAINIWZUZT0c(OBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmDQWF0iDQNhJrtKan3yBup7o3sli8Dl6u5eq682TUt9l6XffCQiOwlbQhsglgMCr2Hzk1cKAeuRLuOjJdlwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPtf(JgPtDWJO8dhwCh9PB8UyymDN7CQFe9DyMt3IULwWTOtLtaPZB36o1VOhxuWPwOjBJQLjTfD29dtF63zcVcOurrEl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQ9rLLAbs9hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuBOuJGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbsTHsTHs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8tQnqQvurP2qP2NK6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gHIciDMCXnWdqb8M7GFsTbsTIkk1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BP2aP2aNk8hnsNQTI5HZWi4o3sR0TOtLtaPZB36o1VOhxuWPwOjBJQLjTfD29dtF63zcVcOurrEl1cK6pI(omtcupKmwmm5Iu8aO5uQBKALLAbsTHsTpj1h058iC2PTEhN8MWjG05TuROIsTHs9bDopcNDAR3XjVjCciDEl1cK6bKar8pP2)gPw4OSuBGuBGulqQnuQnuQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuVGYsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQnqQvurP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQrqTwcupKm(9GQLjZdEHK6gPwzP2aP2aPwGuJGATKcnzCyXIHjxKDyMsTaPEajqe)tQ9VrQncffq6mbeXdAshOd8asal(Ntf(JgPt1wX8WzyeCNBjF0TOtLtaPZB36o1VOhxuWPwOjBJQLjB68PIDAcLF4pgdi3eEfqPII8wQfi1Fe9DyMeeuRfVPZNk2Pju(H)ymGCtkg2(j1cKAeuRLSPZNk2Pju(H)ymGCJTvmpYomtPwGuBOuJGATeOEizSyyYfzhMPulqQrqTwsHMmoSyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMsTbsTaP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQnuQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotU4g4bOa(9GQLNsTaP2qP2qP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1gi1kQOuBOu7ts9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpP2aPwrfL6pI(omtcupKmwmm5Iu8aO5uQxUrQB)TuBGuBGtf(JgPt1wX8qI(5o3scF3IovobKoVDR7u)IECrbNAHMSnQwMSPZNk2Pju(H)ymGCt4vaLkkYBPwGu)r03HzsqqTw8MoFQyNMq5h(JXaYnPyy7NulqQrqTwYMoFQyNMq5h(JXaYn2slMSdZuQfi1IfBe3(BYceBfZdj6Ntf(JgPt1slgJ0H55o3scRBrNkNasN3U1DQFrpUOGt9JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotU4g4bOa(9GQLNsTaP(JOVdZKa1djJfdtUifpaAoL6LBK62F7uH)Or6uh0QIAIdl(IAW55o3sRy3IovobKoVDR7u)IECrbN6hrFhMjbQhsglgMCrkEa0Ck1nsTYsTaP2qP2NK6d6CEeo70wVJtEt4eq68wQvurP2qP(GoNhHZoT174K3eobKoVLAbs9asGi(Nu7FJulCuwQnqQnqQfi1gk1gk1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mbeXdqb8M7GFsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQnqQvurP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQrqTwcupKm(9GQLjZdEHK6gPwzP2aP2aPwGuJGATKcnzCyXIHjxKDyMsTaPEajqe)tQ9VrQncffq6mbeXdAshOd8asal(Ntf(JgPtDqRkQjoS4lQbNN7CljCCl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zYf3apafWVhuT8uQfi1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BNk8hnsN6MHZdjQKDNBjHRBrNkNasN3U1DQFrpUOGt9JOVdZKa1djJfdtUifpaAoL6gPwzPwGuBOu7ts9bDopcNDAR3XjVjCciDEl1kQOuBOuFqNZJWzN26DCYBcNasN3sTaPEajqe)tQ9VrQfokl1gi1gi1cKAdLAdL6pI(omtYfOVhoS4ZJXdOLskEa0Ck1(l1lOSulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAdKAfvuQnuQ)i67WmjxG(E4WIppgpGwkP4bqZPu3i1kl1cKAeuRLa1djJFpOAzY8GxiPUrQvwQnqQnqQfi1iOwlPqtghwSyyYfzhMPulqQhqceX)KA)BKAJqrbKotar8GM0b6apGeWI)5uH)Or6u3mCEirLS7Cl5ZDl6u5eq682TUt9l6XffCQFe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mPM4bOaEZDWpPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNj1epafWBUd(j1cKAdL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPuVCJu3(BPwrfL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPu7VuBekkG0zsnXdqb8M7GFsTIkk1(KuFqNZJuOjJdlwmm5IWjG05TuBGulqQrqTwcupKm(9GQLjZdEHKA)L6vk1cK6nJGATKlqFpCyXNhJhqlLSdZ0Pc)rJ0PwWMc5HNIqjK7ClTGYUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTYsTaPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6m5IBGhGc43dQwEk1cK6pI(omtcupKmwmm5Iu8aO5uQxUrQB)Ttf(JgPtTGnfYdpfHsi35wAHfCl6u5eq682TUt9l6XffCQFe9DyMeOEizSyyYfP4bqZPu3i1kl1cKAdLAdLAFsQpOZ5r4StB9oo5nHtaPZBPwrfLAdL6d6CEeo70wVJtEt4eq68wQfi1dibI4FsT)nsTWrzP2aP2aPwGuBOuBOu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiP2aPwrfLAdL6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTYsTaPgb1Ajq9qY43dQwMmp4fsQBKALLAdKAdKAbsncQ1sk0KXHflgMCr2Hzk1cK6bKar8pP2)gP2iuuaPZeqepOjDGoWdibS4FsTbov4pAKo1c2uip8uekHCNBPfwPBrNkNasN3U1DQFrpUOGt9JOVdZKa1djJfdtUifpaAoL6LLAHvzPwGuZZjNptmsN0iXHflYLL)JgjzqZOCQWF0iDQxG(E4WIppgpGwQ7ClTGp6w0PYjG05TBDN6x0Jlk4urqTwcupKm(9GQLjZdEHK6LBKAJqrbKotU4g4bOa(9GQLNsTaP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1cK6pmYjKhri)kkKsTaP(JOVdZKuWMc5HNIqjeP4bqZPuVCJulCDQWF0iDQxG(E4WIppgpGwQ7ClTGW3TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpLAbs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8tQfi1(Ku)HroH8ic5xrH0Pc)rJ0PEb67Hdl(8y8aAPUZT0ccRBrNkNasN3U1DQFrpUOGtfb1Ajq9qY43dQwMmp4fsQxUrQncffq6m5IBGhGc43dQwEk1cKAFsQpOZ5rk0KXHflgMCr4eq68wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(5uH)Or6uVa99WHfFEmEaTu35wAHvSBrNkNasN3U1DQFrpUOGtfb1Ajq9qY43dQwMmp4fsQxUrQncffq6m5IBGhGc43dQwEk1cK6pI(omtcupKmwmm5Iu8aO5uQxUrQB)Ttf(JgPt9c03dhw85X4b0sDNBPfeoUfDQCciDE7w3P(f94IcovdLAFsQpOZ5r4StB9oo5nHtaPZBPwrfLAdL6d6CEeo70wVJtEt4eq68wQfi1dibI4FsT)nsTWrzP2aP2aPwGu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiPwGuJGATKcnzCyXIHjxKDyMsTaPEajqe)tQ9VrQncffq6mbeXdAshOd8asal(Ntf(JgPtfQhsglgMC5o3sliCDl6u5eq682TUt9l6XffCQiOwlPqtghwSyyYfzhMPulqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zsfI4bOaEZDWpPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1cKAdL6pI(omtcupKmwmm5Iu8aO5uQ9xQxqyLAfvuQ3mcQ1sUa99WHfFEmEaTucQOuBGtf(JgPtTqtghwSyyYL7ClTGp3TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1nsTYsTaP(dJCc5reYVIcPtf(JgPtvS4jNpJdlEqZT7ClTsLDl6u5eq682TUt9l6XffCQBgb1AjxG(E4WIppgpGwkbvuQfi1(Ku)HroH8ic5xrH0Pc)rJ0Pkw8KZNXHfpO52DUZPwXbhns3IULwWTOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYo1fCQFrpUOGtfb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQfi1(KuJGATKcTZ4WIpVI5jbvuQfi1wAR3HlEa0Ck1l3i1gk1gk1dibPEvPg(JgjbQhsgJ0H5r(yEsTbsTWmsn8hnscupKmgPdZJWkWp6X4JoyP2aNQrOWjmyNQLMqhJGwP7ClTs3IovobKoVDR7u)IECrbN6hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuBOuJGATeOEiz87bvltMh8cj1(l1gHIciDMCXnWdqb87bvlpLAbs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8tQfi1FyKtipIq(vuiLAbs9hrFhMjPGnfYdpfHsisXdGMtPE5gPw4k1g4uH)Or6uH6HKXiqvql7o3s(OBrNkNasN3U1DQFrpUOGt9JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQnuQrqTwcupKm(9GQLjZdEHKA)LAJqrbKotU4g4bOa(9GQLNsTaP(GoNhPqtghwSyyYfHtaPZBPwGu)r03Hzsk0KXHflgMCrkEa0Ck1l3i1T)wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1cKAFsQ)WiNqEeH8ROqk1g4uH)Or6uH6HKXiqvql7o3scF3IovobKoVDR7u)IECrbN6hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuBOuJGATeOEiz87bvltMh8cj1(l1gHIciDMCXnWdqb87bvlpLAbsTpj1h058ifAY4WIfdtUiCciDEl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KAdCQWF0iDQq9qYyeOkOLDNBjH1TOtLtaPZB36o1VOhxuWP(r03HzsUa99WHfFEmEaTusXdGMtPUrQvwQfi1gk1iOwlbQhsg)Eq1YK5bVqsT)sTrOOasNjxCd8aua)Eq1YtPwGu)r03HzsG6HKXIHjxKIhanNs9YnsD7VLAdCQWF0iDQq9qYyeOkOLDNBPvSBrNkNasN3U1DQFrpUOGtDZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8GxiPUrQ3mcQ1skytH8WtrOecBeTNCbi0o98JmafWZdEHKAbsTHsncQ1sG6HKXIHjxKDyMsTIkk1iOwlbQhsglgMCrkEa0Ck1l3i1T)wQnqQfi1gk1iOwlPqtghwSyyYfzhMPuROIsncQ1sk0KXHflgMCrkEa0Ck1l3i1T)wQnWPc)rJ0Pc1djJrGQGw2DULeoUfDQCciDE7w3P(f94Ico1DCKc2uip8uekHifpaAoLA)LAHvQvurPEZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8GxiP2FPwzNk8hnsNkupKmgPdZZDULeUUfDQCciDE7w3P(f94IcoveuRLiw8KZNXHfpO5MGkk1cK6nJGATKlqFpCyXNhJhqlLGkk1cK6nJGATKlqFpCyXNhJhqlLu8aO5uQxUrQH)OrsG6HKXiDyEewb(rpgF0b7uH)Or6uH6HKXiDyEUZTKp3TOtLtaPZB36ov4pAKovOEiz8GoN0opDQVhqtN6co1VOhxuWPUzeuRLCb67Hdl(8y8aAPeurPwGuFqNZJa1djJ53liCciDEl1cKAeuRLSz48qIkzYomtPwGuBOuVzeuRLCb67Hdl(8y8aAPKIhanNsT)sn8hnscupKmEqNtANNewb(rpgF0bl1kQOu)r03HzselEY5Z4WIh0CtkEa0Ck1(l1kl1kQOu)HroH8ic5xrHuQnWDULwqz3IovobKoVDR7u)IECrbNkcQ1s(od1dZJMTKIH)KAbsncQ1syfeHCZBSyCCEuOtqfDQWF0iDQq9qY4bDoPDE6o3slSGBrNkNasN3U1DQWF0iDQq9qY4bDoPDE6uFpGMo1fCQFrpUOGtfb1AjFNH6H5rZwsXWFsTaP2qPgb1Ajq9qYyXWKlcQOuROIsncQ1sk0KXHflgMCrqfLAfvuQ3mcQ1sUa99WHfFEmEaTusXdGMtP2FPg(JgjbQhsgpOZjTZtcRa)OhJp6GLAdCNBPfwPBrNkNasN3U1DQWF0iDQq9qY4bDoPDE6uFpGMo1fCQFrpUOGtfb1AjFNH6H5rZwsXWFsTaPgb1AjFNH6H5rZwY8GxiPUrQrqTwY3zOEyE0SLmafWZdEHCNBPf8r3IovobKoVDR7uH)Or6uH6HKXd6Cs780P(EanDQl4u)IECrbNkcQ1s(od1dZJMTKIH)KAbsncQ1s(od1dZJMTKIhanNs9YnsTHsTHsncQ1s(od1dZJMTK5bVqsTWmsn8hnscupKmEqNtANNewb(rpgF0bl1gi1Rj1T)wQnWDULwq47w0PYjG05TBDN6x0Jlk4unuQl2w80dq6SuROIsTpj1h9fIMTsTbsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQfi1iOwlbQhsglgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZ0Pc)rJ0PM85Xf(4Hipp35wAbH1TOtLtaPZB36o1VOhxuWPIGATeOEiz87bvltMh8cj1l3i1gHIciDMCXnWdqb87bvlpDQWF0iDQq9qY4OqCNBPfwXUfDQCciDE7w3P(f94Ico1bKar8pPE5gP2NlSsTaPgb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmDQWF0iDQturUYWi4o3sliCCl6u5eq682TUt9l6XffCQiOwlbQhsglgMCr2Hzk1cKAeuRLuOjJdlwmm5ISdZuQfi1Bgb1AjxG(E4WIppgpGwkzhMPulqQ)i67WmjSX4HJgjP4bqZPu7VuRSulqQ)i67Wmjq9qYyXWKlsXdGMtP2FPwzPwGu)r03HzsUa99WHfFEmEaTusXdGMtP2FPwzPwGuBOu7ts9bDopsHMmoSyXWKlcNasN3sTIkk1gk1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtP2FPwzP2aP2aNk8hnsN60JApA2IfdtUCNBPfeUUfDQCciDE7w3P(f94IcoveuRLuODghw85vmpjOIsTaPgb1Ajq9qY43dQwMmp4fsQ9xQ9rNk8hnsNkupKmgPdZZDULwWN7w0PYjG05TBDN6x0Jlk4uhqceX)K6LLAJqrbKotqGQGwgpGeWI)j1cK6pI(omtcBmE4OrskEa0Ck1(l1kl1cKAeuRLa1djJfdtUi7WmLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKulqQ55KZNjgPtAK4WIf5YY)rJKmOzuov4pAKovOEizmcuf0YUZT0kv2TOtLtaPZB36o1VOhxuWP(r03HzsUa99WHfFEmEaTusXdGMtPUrQvwQfi1gk1Fe9DyMKcnzCyXIHjxKIhanNsDJuRSuROIs9hrFhMjbQhsglgMCrkEa0Ck1nsTYsTbsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fYPc)rJ0Pc1djJrGQGw2DULw5cUfDQCciDE7w3P(f94Ico1bKar8pPE5gP2iuuaPZeeOkOLXdibS4FsTaPgb1Ajq9qYyXWKlYomtPwGuJGATKcnzCyXIHjxKDyMsTaPEZiOwl5c03dhw85X4b0sj7WmLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKulqQ)i67WmjSX4HJgjP4bqZPu7VuRStf(JgPtfQhsgJavbTS7ClTYv6w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5ISdZuQfi1iOwlPqtghwSyyYfzhMPulqQ3mcQ1sUa99WHfFEmEaTuYomtPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8cj1cK6d6CEeOEizCuieobKoVLAbs9hrFhMjbQhsghfcP4bqZPuVCJu3(BPwGupGeiI)j1l3i1(CLLAbs9hrFhMjHngpC0ijfpaAoLA)LALDQWF0iDQq9qYyeOkOLDNBPv6JUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIsTaPgb1Ajq9qYyXWKlsXdGMtPE5gPU93sTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fYPc)rJ0Pc1djJrGQGw2DULwPW3TOtLtaPZB36o1VOhxuWPIGATKcnzCyXIHjxeurPwGuJGATKcnzCyXIHjxKIhanNs9YnsD7VLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKtf(JgPtfQhsgJavbTS7ClTsH1TOtLtaPZB36o1VOhxuWPIGATeOEizSyyYfzhMPulqQrqTwsHMmoSyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPeurPwGuVzeuRLCb67Hdl(8y8aAPKIhanNs9YnsD7VLAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKtf(JgPtfQhsgJavbTS7ClTYvSBrNk8hnsNkupKmgPdZZPYjG05TBD35wALch3IovAECvOIhMADQdibI4F(3iCfwNknpUkuXdthdEtHJDQl4uH)Or6uzJXdhnsNkNasN3U1DNBPvkCDl6uH)Or6uH6HKXiqvql7u5eq682TU7CNtDeg5bNNBr3sl4w0PYjG05TBDN6x0Jlk4uhHrEW5r205b5ZsT)ns9ck7uH)Or6ur60ui35wALUfDQWF0iDQIfp58zCyXdAUDQCciDE7w3DUL8r3IovobKoVDR7u)IECrbN6imYdopYMopiFwQxwQxqzNk8hnsNkupKmEqNtANNUZTKW3TOtf(JgPtfQhsghfItLtaPZB36UZTKW6w0Pc)rJ0PAPfJr6W8CQCciDE7w3DUZPUzlG2p3IULwWTOtLtaPZB36o1VOhxuWPEq1YhzZiOwl5H5rZwsXWFov4pAKo1pqZJRPi37UZT0kDl6u5eq682TUtf(JgPt9HEhd)rJe3PZZP2PZdNWGDQtpO4n(3t35wYhDl6u5eq682TUtf(JgPt9HEhd)rJe3PZZP2PZdNWGDQ8CY5Zt35ws47w0PYjG05TBDN6x0Jlk4uH)OgzmN8GYtP2FPELov4pAKo1h6Dm8hnsCNopNANopCcd2Pcb7o3scRBrNkNasN3U1DQFrpUOGt1iuuaPZepWiJdro5TuVCJuRStf(JgPt9HEhd)rJe3PZZP2PZdNWGDQHiNC5o3sRy3IovobKoVDR7u)IECrbNQrOOasNjWapfHHu3i1l4uH)Or6uFO3XWF0iXD68CQD68WjmyNkmWtry4o3sch3IovobKoVDR7uH)Or6uFO3XWF0iXD68CQD68WjmyN6hrFhM50DULeUUfDQCciDE7w3P(f94IcovJqrbKotS0e6ye0kL6gPwzNk8hnsN6d9og(JgjUtNNtTtNhoHb7uR4GJgP7Cl5ZDl6u5eq682TUt9l6XffCQgHIciDMyPj0XiOvk1ns9cov4pAKo1h6Dm8hnsCNopNANopCcd2PAPj0XiOv6o3slOSBrNkNasN3U1DQWF0iDQp07y4pAK4oDEo1oDE4egStDeg5bNN7CNtvS4pgiW5w0T0cUfDQCciDE7w3PgIo1IN85uH)Or6uncffq6St1iu4egStvSyr0EhZgdN6MTaA)CQk7o3sR0TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYo1fCQFrpUOGt1iuuaPZeXIfr7DmBmK6gPwzPwGuxOjBJQLjtQOxK45f1GWRakvuK3sTaPg(JAKXCYdkpLA)L6v6uncfoHb7uflweT3XSXWDUL8r3IovobKoVDR7udrN6KpNk8hnsNQrOOasNDQgHok7uxWP(f94IcovJqrbKotelweT3XSXqQBKALLAbsDHMSnQwMmPIErINxudcVcOurrEl1cK6pmYjKhj5VIEuBPwGud)rnYyo5bLNsT)s9covJqHtyWovXIfr7DmBmCNBjHVBrNkNasN3U1DQHOtDYNtf(JgPt1iuuaPZovJqhLDQl4u)IECrbNQrOOasNjIflI27y2yi1nsTYsTaPUqt2gvltMurViXZlQbHxbuQOiVLAbs9hg5eYJK0wVdBb2PAekCcd2PkwSiAVJzJH7CljSUfDQCciDE7w3PgIo1IN85uH)Or6uncffq6St1iu4egSt1dmY4qKtE7u3Sfq7Ntvz35wAf7w0PYjG05TBDNAi6uN85uH)Or6uncffq6St1i0rzN6co1VOhxuWPAekkG0zIhyKXHiN8wQBKALLAbsn8h1iJ5KhuEk1(l1R0PAekCcd2P6bgzCiYjVDNBjHJBrNkNasN3U1DQHOtDYNtf(JgPt1iuuaPZovJqhLDQl4u)IECrbNQrOOasNjEGrghICYBPUrQvwQfi1gHIciDMiwSiAVJzJHu3i1l4uncfoHb7u9aJmoe5K3UZTKW1TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYovLDQgHcNWGDQwAcDmcALUZTKp3TOtLtaPZB36o1q0Pw8KpNk8hnsNQrOOasNDQgHcNWGDQ1epafWBUd(5u3Sfq7NtvyDNBPfu2TOtLtaPZB36o1q0Pw8KpNk8hnsNQrOOasNDQgHcNWGDQGiEakG3Ch8ZPUzlG2pN6ck7o3slSGBrNkNasN3U1DQHOtT4jFov4pAKovJqrbKo7uncfoHb7uRqepafWBUd(5u3Sfq7NtDLk7o3slSs3IovobKoVDR7udrNAXt(CQWF0iDQgHIciD2PAekCcd2PEXnWdqb8M7GFo1nBb0(5ufw35wAbF0TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYovF0P(f94IcovJqrbKotU4g4bOaEZDWpPUrQfwPwGuxOjBJQLjB68PIDAcLF4pgdi3eEfqPII82PAekCcd2PEXnWdqb8M7GFUZT0ccF3IovobKoVDR7udrN6KpNk8hnsNQrOOasNDQgHok7uxqyDQFrpUOGt1iuuaPZKlUbEakG3Ch8tQBKAHvQfi1FyKtipssB9oSfyNQrOWjmyN6f3apafWBUd(5o3sliSUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2PUGW6u)IECrbNQrOOasNjxCd8auaV5o4Nu3i1cRulqQ)i3O0Ja1djJfRytB9JWjG05TulqQH)OgzmN8GYtPEzP2hDQgHcNWGDQxCd8auaV5o4N7ClTWk2TOtLtaPZB36o1q0Po5ZPc)rJ0PAekkG0zNQrOJYovFuzN6x0Jlk4uncffq6m5IBGhGc4n3b)K6gPwyLAbsnpNC(mXiDsJehwSixw(pAKKbnJYPAekCcd2PEXnWdqb8M7GFUZT0cch3IovobKoVDR7udrNAXt(CQWF0iDQgHIciD2PAekCcd2PIavbTmEajGf)ZPUzlG2pNQWrz35wAbHRBrNkNasN3U1DQHOtDYNtf(JgPt1iuuaPZovJqhLDQcFLDQFrpUOGt1iuuaPZeeOkOLXdibS4FsDJulCuwQfi1FyKtipssB9oSfyNQrOWjmyNkcuf0Y4bKaw8p35wAbFUBrNkNasN3U1DQHOtT4jFov4pAKovJqrbKo7uncfoHb7ubr8GM0b6apGeWI)5u3Sfq7Nt1hv2DULwPYUfDQCciDE7w3PgIo1jFov4pAKovJqrbKo7uncDu2PkSk7u)IECrbNQrOOasNjGiEqt6aDGhqcyX)K6gP2hvwQfi1fAY2OAzYMoFQyNMq5h(JXaYnHxbuQOiVDQgHcNWGDQGiEqt6aDGhqcyX)CNBPvUGBrNkNasN3U1DQHOtDYNtf(JgPt1iuuaPZovJqhLDQcRYo1VOhxuWPAekkG0zciIh0Koqh4bKaw8pPUrQ9rLLAbsDHMSnQwM0w0z3pm9PFNj8kGsff5Tt1iu4egStfeXdAshOd8asal(N7ClTYv6w0PYjG05TBDNAi6ulEYNtf(JgPt1iuuaPZovJqHtyWo1lUbEakGFpOA5PtDZwaTFo1v6o3sR0hDl6u5eq682TUtneDQfp5ZPc)rJ0PAekkG0zNQrOWjmyNkem(IBGhGc43dQwE6u3Sfq7NtDLUZT0kf(UfDQCciDE7w3PgIo1IN85uH)Or6uncffq6St1iu4egStfg4PimCQB2cO9ZPo57Oz7Kad8uegUZT0kfw3IovobKoVDR7o3sRCf7w0PYjG05TBD35wALch3IovobKoVDR7o3sRu46w0Pc)rJ0PorhJiXq9qYylmODkuovobKoVDR7o3sR0N7w0Pc)rJ0Pc1djJP5X9o)NtLtaPZB36UZTKpQSBrNk8hnsN6hPWCOfJhqc4wE4u5eq682TU7Cl5Jl4w0PYjG05TBD35wYhxPBrNk8hnsN6Gwvuy6aAzNkNasN3U1DNBjF0hDl6u5eq682TUt9l6XffCQgHIciDMiwSiAVJzJHuVCJuRStf(JgPt1wX8qI(5o3s(OW3TOtLtaPZB36o1VOhxuWPAekkG0zIyXIO9oMngsT)sTYov4pAKov2y8WrJ0DUZPcb7w0T0cUfDQCciDE7w3P(f94Ico1cnzBuTmztNpvSttO8d)Xya5MWRakvuK3sTaP(JOVdZKGGAT4nD(uXonHYp8hJbKBsXW2pPwGuJGATKnD(uXonHYp8hJbKBSTI5r2Hzk1cKAdLAeuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZuQnqQfi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsTHsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1cKAdLAdL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPuVCJu3(BPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNjxCd8auaV5o4NuBGuROIsTHsTpj1h058ifAY4WIfdtUiCciDEl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KAdKAfvuQ)i67Wmjq9qYyXWKlsXdGMtPE5gPU93sTbsTbov4pAKovBfZdj6N7ClTs3IovobKoVDR7u)IECrbNQHsDHMSnQwMSPZNk2Pju(H)ymGCt4vaLkkYBPwGu)r03HzsqqTw8MoFQyNMq5h(JXaYnPyy7NulqQrqTwYMoFQyNMq5h(JXaYn2slMSdZuQfi1IfBe3(BYceBfZdj6NuBGuROIsTHsDHMSnQwMSPZNk2Pju(H)ymGCt4vaLkkYBPwGuF0bl1nsTYsTbov4pAKovlTymshMN7Cl5JUfDQCciDE7w3P(f94Ico1cnzBuTmPTOZUFy6t)ot4vaLkkYBPwGu)r03HzsG6HKXIHjxKIhanNsT)sTpQSulqQ)i67WmjxG(E4WIppgpGwkP4bqZPu3i1kl1cKAdLAeuRLa1djJFpOAzY8GxiPE5gP2iuuaPZeiy8f3apafWVhuT8uQfi1gk1gk1h058ifAY4WIfdtUiCciDEl1cK6pI(omtsHMmoSyXWKlsXdGMtPE5gPU93sTaP(JOVdZKa1djJfdtUifpaAoLA)LAJqrbKotU4g4bOaEZDWpP2aPwrfLAdLAFsQpOZ5rk0KXHflgMCr4eq68wQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuBekkG0zYf3apafWBUd(j1gi1kQOu)r03HzsG6HKXIHjxKIhanNs9YnsD7VLAdKAdCQWF0iDQ2kMhodJG7Clj8Dl6u5eq682TUt9l6XffCQfAY2OAzsBrND)W0N(DMWRakvuK3sTaP(JOVdZKa1djJfdtUifpaAoL6gPwzPwGuBOuBOuBOu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiP2aPwrfLAdL6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTYsTaPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6mbcgFXnWdqb87bvlpLAdKAdKAbsncQ1sk0KXHflgMCr2Hzk1g4uH)Or6uTvmpCggb35wsyDl6u5eq682TUt9l6XffCQfAY2OAzYKk6fjEErni8kGsff5TulqQfl2iU93KfiSX4HJgPtf(JgPt9c03dhw85X4b0sDNBPvSBrNkNasN3U1DQFrpUOGtTqt2gvltMurViXZlQbHxbuQOiVLAbsTHsTyXgXT)MSaHngpC0iLAfvuQfl2iU93KfixG(E4WIppgpGwQuBGtf(JgPtfQhsglgMC5o3sch3IovobKoVDR7u)IECrbN6rhSu7Vu7Jkl1cK6cnzBuTmzsf9IepVOgeEfqPII8wQfi1iOwlbQhsg)Eq1YK5bVqs9YnsTrOOasNjqW4lUbEakGFpOA5PulqQ)i67WmjxG(E4WIppgpGwkP4bqZPu3i1kl1cK6pI(omtcupKmwmm5Iu8aO5uQxUrQB)Ttf(JgPtLngpC0iDNBjHRBrNkNasN3U1DQWF0iDQSX4HJgPtLMhxfQ4HPwNkcQ1sMurViXZlQbzEWludcQ1sMurViXZlQbzakGNh8c5uP5XvHkEy6yWBkCStDbN6x0Jlk4up6GLA)LAFuzPwGuxOjBJQLjtQOxK45f1GWRakvuK3sTaP(JOVdZKa1djJfdtUifpaAoL6gPwzPwGuBOuBOuBOu)r03HzsUa99WHfFEmEaTusXdGMtP2FP2iuuaPZeqepafWBUd(j1cKAeuRLa1djJFpOAzY8GxiPUrQrqTwcupKm(9GQLjdqb88GxiP2aPwrfLAdL6pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTYsTaPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6mbcgFXnWdqb87bvlpLAdKAdKAbsncQ1sk0KXHflgMCr2Hzk1g4o3s(C3IovobKoVDR7u)IECrbNQHs9hrFhMjbQhsglgMCrkEa0Ck1(l1cFHvQvurP(JOVdZKa1djJfdtUifpaAoL6LBKAFuQnqQfi1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsTHsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1cKAdLAdL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPuVCJu3(BPwGu)r03HzsG6HKXIHjxKIhanNsT)sTWk1gi1kQOuBOu7ts9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKa1djJfdtUifpaAoLA)LAHvQnqQvurP(JOVdZKa1djJfdtUifpaAoL6LBK62Fl1gi1g4uH)Or6uh0QIAIdl(IAW55o3slOSBrNkNasN3U1DQFrpUOGt9JOVdZKCb67Hdl(8y8aAPKIhanNsT)sTrOOasNj1epafWBUd(j1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6mPM4bOaEZDWpPwGuBOuFqNZJuOjJdlwmm5IWjG05TulqQ)i67WmjfAY4WIfdtUifpaAoL6LBK62Fl1kQOuFqNZJuOjJdlwmm5IWjG05TulqQ)i67WmjfAY4WIfdtUifpaAoLA)LAJqrbKotQjEakG3Ch8tQvurP2NK6d6CEKcnzCyXIHjxeobKoVLAdKAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1cK6nJGATKlqFpCyXNhJhqlLSdZ0Pc)rJ0PwWMc5HNIqjK7ClTWcUfDQCciDE7w3P(f94Ico1pI(omtYfOVhoS4ZJXdOLskEa0Ck1nsTYsTaP2qPgb1Ajq9qY43dQwMmp4fsQxUrQncffq6mbcgFXnWdqb87bvlpLAbsTHsTHs9bDopsHMmoSyXWKlcNasN3sTaP(JOVdZKuOjJdlwmm5Iu8aO5uQxUrQB)TulqQ)i67Wmjq9qYyXWKlsXdGMtP2FP2iuuaPZKlUbEakG3Ch8tQnqQvurP2qP2NK6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjbQhsglgMCrkEa0Ck1(l1gHIciDMCXnWdqb8M7GFsTbsTIkk1Fe9DyMeOEizSyyYfP4bqZPuVCJu3(BP2aP2aNk8hnsNAbBkKhEkcLqUZT0cR0TOtLtaPZB36o1VOhxuWP(r03HzsG6HKXIHjxKIhanNsDJuRSulqQnuQnuQnuQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuBekkG0zciIhGc4n3b)KAbsncQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKuBGuROIsTHs9hrFhMj5c03dhw85X4b0sjfpaAoL6gPwzPwGuJGATeOEiz87bvltMh8cj1l3i1gHIciDMabJV4g4bOa(9GQLNsTbsTbsTaPgb1AjfAY4WIfdtUi7WmLAdCQWF0iDQfSPqE4Piuc5o3sl4JUfDQCciDE7w3P(f94Ico1pI(omtcupKmwmm5Iu8aO5uQBKALLAbsTHsTHsTHs9hrFhMj5c03dhw85X4b0sjfpaAoLA)LAJqrbKotar8auaV5o4NulqQrqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAdKAfvuQnuQ)i67WmjxG(E4WIppgpGwkP4bqZPu3i1kl1cKAeuRLa1djJFpOAzY8GxiPE5gP2iuuaPZeiy8f3apafWVhuT8uQnqQnqQfi1iOwlPqtghwSyyYfzhMPuBGtf(JgPtDZW5HevYUZT0ccF3IovobKoVDR7u)IECrbNkcQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1cKAdLAdL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPuVCJu3(BPwGu)r03HzsG6HKXIHjxKIhanNsT)sTrOOasNjxCd8auaV5o4NuBGuROIsTHsTpj1h058ifAY4WIfdtUiCciDEl1cK6pI(omtcupKmwmm5Iu8aO5uQ9xQncffq6m5IBGhGc4n3b)KAdKAfvuQ)i67Wmjq9qYyXWKlsXdGMtPE5gPU93sTbov4pAKo1lqFpCyXNhJhql1DULwqyDl6u5eq682TUt9l6XffCQgk1gk1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQ9xQncffq6mbeXdqb8M7GFsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fsQnqQvurP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsDJuRSulqQrqTwcupKm(9GQLjZdEHK6LBKAJqrbKotGGXxCd8aua)Eq1YtP2aP2aPwGuJGATKcnzCyXIHjxKDyMov4pAKovOEizSyyYL7ClTWk2TOtLtaPZB36o1VOhxuWPIGATKcnzCyXIHjxKDyMsTaP2qP2qP(JOVdZKCb67Hdl(8y8aAPKIhanNsT)s9kvwQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqsTbsTIkk1gk1Fe9DyMKlqFpCyXNhJhqlLu8aO5uQBKALLAbsncQ1sG6HKXVhuTmzEWlKuVCJuBekkG0zcem(IBGhGc43dQwEk1gi1gi1cKAdL6pI(omtcupKmwmm5Iu8aO5uQ9xQxqyLAfvuQ3mcQ1sUa99WHfFEmEaTucQOuBGtf(JgPtTqtghwSyyYL7ClTGWXTOtLtaPZB36o1VOhxuWPIGATKndNhsujtqfLAbs9MrqTwYfOVhoS4ZJXdOLsqfLAbs9MrqTwYfOVhoS4ZJXdOLskEa0Ck1l3i1iOwlrS4jNpJdlEqZnzakGNh8cj1cZi1WF0ijq9qYyKompcRa)OhJp6GDQWF0iDQIfp58zCyXdAUDNBPfeUUfDQCciDE7w3P(f94IcoveuRLSz48qIkzcQOulqQnuQnuQpOZ5rkEgjKpt4eq68wQfi1WFuJmMtEq5PuVSul8LAdKAfvuQH)OgzmN8GYtPEzPwyLAdCQWF0iDQq9qYyKomp35wAbFUBrNk8hnsN6evKRmmcovobKoVDR7o3sRuz3IovobKoVDR7u)IECrbNkcQ1sG6HKXVhuTmzEWlKu3i1k7uH)Or6uH6HKXrH4o3sRCb3IovobKoVDR7u)IECrbNQHsDX2INEasNLAfvuQ9jP(OVq0SvQnqQfi1iOwlbQhsg)Eq1YK5bVqsDJuJGATeOEiz87bvltgGc45bVqov4pAKo1KppUWhpe555o3sRCLUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUi7WmLAbsncQ1sk0KXHflgMCr2Hzk1cK6nJGATKlqFpCyXNhJhqlLSdZuQfi1Fe9DyMeOEizSyyYfP4bqZPu7VuRSulqQ)i67WmjxG(E4WIppgpGwkP4bqZPu7VuRSulqQnuQ9jP(GoNhPqtghwSyyYfHtaPZBPwrfLAdL6d6CEKcnzCyXIHjxeobKoVLAbs9hrFhMjPqtghwSyyYfP4bqZPu7VuRSuBGuBGtf(JgPtD6rThnBXIHjxUZT0k9r3IovobKoVDR7u)IECrbNkcQ1s(od1dZJMTKIH)KAbsDHMSnQwMa1djJPPLM0ZpcVcOurrEl1cK6d6CEeyi2Pw6dhnscNasN3sTaPg(JAKXCYdkpL6LLAFUtf(JgPtfQhsgpOZjTZt35wALcF3IovobKoVDR7u)IECrbNkcQ1s(od1dZJMTKIH)KAbsDHMSnQwMa1djJPPLM0ZpcVcOurrEl1cKA4pQrgZjpO8uQxwQxXov4pAKovOEiz8GoN0opDNBPvkSUfDQCciDE7w3P(f94IcoveuRLa1djJFpOAzY8GxiPEzPgb1Ajq9qY43dQwMmafWZdEHCQWF0iDQq9qYywbXEmPr6o3sRCf7w0PYjG05TBDN6x0Jlk4urqTwcupKm(9GQLjZdEHK6gPgb1Ajq9qY43dQwMmafWZdEHKAbsTyXgXT)MSabQhsgJavbTStf(JgPtfQhsgZki2Jjns35wALch3IovobKoVDR7u)IECrbNkcQ1sG6HKXVhuTmzEWlKu3i1iOwlbQhsg)Eq1YKbOaEEWlKtf(JgPtfQhsgJavbTS7ClTsHRBrNknpUkuXdtTo1bKar8p)BeUcRtLMhxfQ4HPJbVPWXo1fCQWF0iDQSX4HJgPtLtaPZB36UZDo1Phu8g)7PBr3sl4w0PYjG05TBDN6x0Jlk4unuQpOZ5r4StB9oo5nHtaPZBPwGupGeiI)j1l3i1cxLLAbs9asGi(Nu7FJuVIfwP2aPwrfLAdLAFsQpOZ5r4StB9oo5nHtaPZBPwGupGeiI)j1l3i1cxHvQnWPc)rJ0PoGeWT8WDULwPBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlcQOtf(JgPtfDYy6XJP7Cl5JUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIov4pAKovX4Or6o3scF3IovobKoVDR7u)IECrbNAHMSnQwMC8qmkOJnHsKWRakvuK3sTaPgb1AjScEa68OrsqfDQWF0iDQhDWytOeDNBjH1TOtLtaPZB36o1VOhxuWPIGATeOEizSyyYfzhMPulqQrqTwsHMmoSyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMov4pAKo1oT17MyH5q3Tdop35wAf7w0PYjG05TBDN6x0Jlk4urqTwcupKmwmm5ISdZuQfi1iOwlPqtghwSyyYfzhMPulqQ3mcQ1sUa99WHfFEmEaTuYomtNk8hnsNkc0Idl(k6l00DULeoUfDQCciDE7w3P(f94IcoveuRLa1djJfdtUiOIov4pAKoveUMCjenBDNBjHRBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlcQOtf(JgPtfPhXgBrl)CNBjFUBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlcQOtf(JgPt1slgPhX2DULwqz3IovobKoVDR7u)IECrbNkcQ1sG6HKXIHjxeurNk8hnsNkKppVc64h6D35oNkmWtry4w0T0cUfDQCciDE7w3P(f94IcovdL6pI(omtcupKmwmm5Iu8aO5uQBKALLAfvuQ)i67WmjfAY4WIfdtUifpaAoL6LBK62Fl1gi1cKAeuRLuOjJdlwmm5ISdZ0Pc)rJ0PEb67Hdl(8y8aAPUZT0kDl6u5eq682TUt9l6XffCQiOwlPqtghwSyyYfzhMPtf(JgPtfQhsglgMC5o3s(OBrNkNasN3U1DQFrpUOGtfb1AjfAY4WIfdtUi7WmDQWF0iDQfAY4WIfdtUCNBjHVBrNkNasN3U1DQFrpUOGtfb1Ajq9qYyXWKlcQOulqQrqTwcupKmwmm5Iu8aO5uQxUrQH)OrsG6HKXd6Cs78KWkWp6X4JoyPwGuJGATeOEiz87bvltMh8cj1nsncQ1sG6HKXVhuTmzakGNh8c5uH)Or6uH6HKXiqvql7o3scRBrNkNasN3U1DQFrpUOGtfb1Ajq9qY43dQwMmp4fsQxwQrqTwcupKm(9GQLjdqb88GxiPwGuJGATKcnzCyXIHjxKDyMsTaPgb1Ajq9qYyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMov4pAKovOEizCuiUZT0k2TOtLtaPZB36o1VOhxuWPIGATKcnzCyXIHjxKDyMsTaPgb1Ajq9qYyXWKlYomtPwGuVzeuRLCb67Hdl(8y8aAPKDyMsTaPgb1Ajq9qY43dQwMmp4fsQBKAeuRLa1djJFpOAzYauapp4fYPc)rJ0Pc1djJrGQGw2DULeoUfDQCciDE7w3P(EanDQl4uH)Or6uH6HKXd6Cs780DULeUUfDQ084Qqfpm16uhqceX)8Vr4kSovAECvOIhMog8Mch7uxWPc)rJ0PYgJhoAKovobKoVDR7o3s(C3IovobKoVDR7u)IECrbNkcQ1sG6HKXVhuTmzEWlKuVSuJGATeOEiz87bvltgGc45bVqov4pAKovOEizCuiUZT0ck7w0Pc)rJ0Pc1djJrGQGw2PYjG05TBD35wAHfCl6uH)Or6uH6HKXiDyEovobKoVDR7o35uT0e6ye0kDl6wAb3IovobKoVDR7uH)Or6uH6HKXd6Cs780P(EanDQl4u)IECrbNkcQ1s(od1dZJMTKIH)CNBPv6w0Pc)rJ0Pc1djJr6W8CQCciDE7w3DUL8r3Iov4pAKovOEizmcuf0YovobKoVDR7o35oNQrUM0iDlTsLxPYlO8kv2PAcvsZ2PtvywROcZVKWRLwruysQL6f9yPMoeJ6KABusTpuXbhnsFqQlEfqPfVL6zmyPgqVyahVL63dYwEsK(6ZstwQxqysQ9zI0ixhVLAv6WNrQN(LhOGul8mP(cP2NffK6n1iDsJuQdrUGlkP2WvnqQnCbfmGi91NLMSuVsHjP2NjsJCD8wQ9HpmYjKhryKWjG05Tpi1xi1(Whg5eYJim6dsTHlOGbePV(S0KLAFuysQ9zI0ixhVLAF4dJCc5regjCciDE7ds9fsTp8HroH8icJ(GuB4ckyar6RplnzP2Nlmj1(mrAKRJ3sTp8HroH8icJeobKoV9bP(cP2h(WiNqEeHrFqQnCbfmGi9v6RWSwrfMFjHxlTIOWKul1l6XsnDig1j12OKAFqS4pgiW5dsDXRakT4TupJbl1a6fd44Tu)Eq2YtI0xFwAYsTpkmj1(mrAKRJ3sTp8HroH8icJeobKoV9bP(cP2h(WiNqEeHrFqQnCbfmGi91NLMSul8fMKAFMinY1XBP2h(WiNqEeHrcNasN3(GuFHu7dFyKtipIWOpi1gUGcgqK(6ZstwQxq4lmj1(mrAKRJ3sTp8HroH8icJeobKoV9bP(cP2h(WiNqEeHrFqQnCbfmGi91NLMSuVGWvysQ9zI0ixhVLAF4dJCc5regjCciDE7ds9fsTp8HroH8icJ(GuB4ckyar6R0xHzTIkm)scVwAfrHjPwQx0JLA6qmQtQTrj1(WhrFhM50hK6IxbuAXBPEgdwQb0lgWXBP(9GSLNePV(S0KL6f8rHjP2NjsJCD8wQ9HpmYjKhryKWjG05Tpi1xi1(Whg5eYJim6dsTHlOGbePV(S0KL6fe(ctsTptKg564Tu7dFyKtipIWiHtaPZBFqQVqQ9HpmYjKhry0hKAdxqbdisF9zPjl1l4ZfMKAFMinY1XBP2h(WiNqEeHrcNasN3(GuFHu7dFyKtipIWOpi1gUGcgqK(6ZstwQxPYctsTptKg564Tu7dFyKtipIWiHtaPZBFqQVqQ9HpmYjKhry0hKAdxqbdisFL(k8Aig1XBPEHfKA4pAKsDNoVjr6RtvSclTZo1vKsTWtHwwQxrRhsw67ksPw4j)fiCj1RuzLK6vQ8kvw6R0x4pAKtIyXFmqGBTMvncffq6Ssjm4gXIfr7DmBmukeBkEYNsB2cO9RrzPVWF0iNeXI)yGa3AnRAekkG0zLsyWnIflI27y2yOui2m5tjJqhLBwqjQTXiuuaPZeXIfr7DmBmAuwqHMSnQwMmPIErINxudcVcOurrEla(JAKXCYdkp9FLsFH)OrojIf)XabU1Aw1iuuaPZkLWGBelweT3XSXqPqSzYNsgHok3SGsuBJrOOasNjIflI27y2y0OSGcnzBuTmzsf9IepVOgeEfqPII8wWhg5eYJK8xrpQnHtaPZBbWFuJmMtEq5P)li9f(Jg5Kiw8hde4wRzvJqrbKoRucdUrSyr0EhZgdLcXMjFkze6OCZckrTngHIciDMiwSiAVJzJrJYck0KTr1YKjv0ls88IAq4vaLkkYBbFyKtipssB9oSfycNasN3sFH)OrojIf)XabU1Aw1iuuaPZkLWGB8aJmoe5K3kfInfp5tPnBb0(1OS0x4pAKtIyXFmqGBTMvncffq6Ssjm4gpWiJdro5TsHyZKpLmcDuUzbLO2gJqrbKot8aJmoe5K3nkla(JAKXCYdkp9FLsFH)OrojIf)XabU1Aw1iuuaPZkLWGB8aJmoe5K3kfInt(uYi0r5MfuIABmcffq6mXdmY4qKtE3OSaJqrbKotelweT3XSXOzbPVWF0iNeXI)yGa3AnRAekkG0zLsyWnwAcDmcALkfInt(uYi0r5gLL(c)rJCsel(JbcCR1SQrOOasNvkHb3ut8auaV5o4NsHytXt(uAZwaTFncR0x4pAKtIyXFmqGBTMvncffq6Ssjm4gqepafWBUd(Pui2u8KpL2Sfq7xZckl9f(Jg5Kiw8hde4wRzvJqrbKoRucdUPcr8auaV5o4NsHytXt(uAZwaTFnRuzPVWF0iNeXI)yGa3AnRAekkG0zLsyWnxCd8auaV5o4NsHytXt(uAZwaTFncR0x4pAKtIyXFmqGBTMvncffq6Ssjm4MlUbEakG3Ch8tPqSzYNsgHok34JkrTngHIciDMCXnWdqb8M7GFncRGcnzBuTmztNpvSttO8d)Xya5MWRakvuK3sFH)OrojIf)XabU1Aw1iuuaPZkLWGBU4g4bOaEZDWpLcXMjFkze6OCZccRsuBJrOOasNjxCd8auaV5o4xJWk4dJCc5rsAR3HTat4eq68w6l8hnYjrS4pgiWTwZQgHIciDwPegCZf3apafWBUd(Pui2m5tjJqhLBwqyvIABmcffq6m5IBGhGc4n3b)AewbFKBu6rG6HKXIvSPT(r4eq68wa8h1iJ5KhuEUSpk9f(Jg5Kiw8hde4wRzvJqrbKoRucdU5IBGhGc4n3b)ukeBM8PKrOJYn(OYkrTngHIciDMCXnWdqb8M7GFncRaEo58zIr6KgjoSyrUS8F0ijdAgL0x4pAKtIyXFmqGBTMvncffq6Ssjm4geOkOLXdibS4FkfInfp5tPnBb0(1iCuw6l8hnYjrS4pgiWTwZQgHIciDwPegCdcuf0Y4bKaw8pLcXMjFkze6OCJWxzLO2gJqrbKotqGQGwgpGeWI)1iCuwWhg5eYJK0wVdBbMWjG05T0x4pAKtIyXFmqGBTMvncffq6Ssjm4gqepOjDGoWdibS4FkfInfp5tPnBb0(14Jkl9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbeXdAshOd8asal(NsHyZKpLmcDuUryvwjQTXiuuaPZeqepOjDGoWdibS4Fn(OYck0KTr1YKnD(uXonHYp8hJbKBcVcOurrEl9f(Jg5Kiw8hde4wRzvJqrbKoRucdUbeXdAshOd8asal(NsHyZKpLmcDuUryvwjQTXiuuaPZeqepOjDGoWdibS4Fn(OYck0KTr1YK2Io7(HPp97mHxbuQOiVL(c)rJCsel(JbcCR1SQrOOasNvkHb3CXnWdqb87bvlpvkeBkEYNsB2cO9RzLsFH)OrojIf)XabU1Aw1iuuaPZkLWGBGGXxCd8aua)Eq1YtLcXMIN8P0MTaA)AwP0x4pAKtIyXFmqGBTMvncffq6Ssjm4gyGNIWqPqSP4jFkTzlG2VMjFhnBNeyGNIWq6l8hnYjrS4pgiWTwZQ2omfs6l8hnYjrS4pgiWTwZQ2i2sFH)OrojIf)XabU1AwfqBhCEWrJu6l8hnYjrS4pgiWTwZQq9qYylmODkusFH)OrojIf)XabU1AwfQhsgtZJ7D(pPVWF0iNeXI)yGa3AnR(rkmhAX4bKaULhsFH)OrojIf)XabU1AwDMG40lo88GBk9f(Jg5Kiw8hde4wRz1bTQOW0b0YsFH)OrojIf)XabU1Aw1wX8qI(Pe12yekkG0zIyXIO9oMngl3OS0x4pAKtIyXFmqGBTMvzJXdhnsLO2gJqrbKotelweT3XSXWFLL(k9f(Jg5CTMv)anpUMICVRe12Cq1YhzZiOwl5H5rZwsXWFsFH)OroxRz1h6Dm8hnsCNopLsyWntpO4n(3tPVWF0iNR1S6d9og(JgjUtNNsjm4gEo585P0x4pAKZ1Aw9HEhd)rJe3PZtPegCdeSsuBd8h1iJ5KhuE6)kL(c)rJCUwZQp07y4pAK4oDEkLWGBcro5sjQTXiuuaPZepWiJdro59Ynkl9f(Jg5CTMvFO3XWF0iXD68ukHb3ad8uegkrTngHIciDMad8uegnli9f(Jg5CTMvFO3XWF0iXD68ukHb38r03HzoL(c)rJCUwZQp07y4pAK4oDEkLWGBQ4GJgPsuBJrOOasNjwAcDmcALnkl9f(Jg5CTMvFO3XWF0iXD68ukHb3yPj0XiOvQe12yekkG0zILMqhJGwzZcsFH)OroxRz1h6Dm8hnsCNopLsyWnJWip48K(k9f(Jg5Km9GI34FpxRzv0jJhqc4wEOe12y4bDopcNDAR3XjVjCciDElyajqe)B5gHRYcgqceX)8VzflSgOOIg6th058iC2PTEhN8MWjG05TGbKar8VLBeUcRbsFH)OrojtpO4n(3Z1AwfDYy6XJPsuBdcQ1sG6HKXIHjxeurPVWF0iNKPhu8g)75AnRkghnsLO2geuRLa1djJfdtUiOIsFH)OrojtpO4n(3Z1Aw9OdgBcLOsuBtHMSnQwMC8qmkOJnHsKWRakvuK3cqqTwcRGhGopAKeurPVWF0iNKPhu8g)75AnR2PTE3elmh6UDW5Pe12GGATeOEizSyyYfzhMPaeuRLuOjJdlwmm5ISdZuWMrqTwYfOVhoS4ZJXdOLs2Hzk9f(Jg5Km9GI34FpxRzveOfhw8v0xOPsuBdcQ1sG6HKXIHjxKDyMcqqTwsHMmoSyXWKlYomtbBgb1AjxG(E4WIppgpGwkzhMP0x4pAKtY0dkEJ)9CTMvr4AYLq0SvjQTbb1Ajq9qYyXWKlcQO0x4pAKtY0dkEJ)9CTMvr6rSXw0YpLO2geuRLa1djJfdtUiOIsFH)OrojtpO4n(3Z1Aw1slgPhXwjQTbb1Ajq9qYyXWKlcQO0x4pAKtY0dkEJ)9CTMvH855vqh)qVRe12GGATeOEizSyyYfbvu6R0x4pAKtcpNC(8CTMvr6rSXHfFEmMtE4NsuBZhrFhMj5c03dhw85X4b0sjfpaAoBuwacQ1sG6HKXVhuTmzEWl0YngHIciDMCXnWdqb87bvlpf8r03HzsG6HKXIHjxKIhanNl30(Bfv0sB9oCXdGMZL)i67Wmjq9qYyXWKlsXdGMtPVWF0iNeEo5855AnRI0JyJdl(8ymN8WpLO2MpI(omtcupKmwmm5Iu8aO5Srzbg6th058iC2PTEhN8MWjG05TIkA4bDopcNDAR3XjVjCciDElyajqe)Z)gHJYkQOrOOasNjWapfHrZcgyGadn8JOVdZKCb67Hdl(8y8aAPKIhanN(BekkG0zciIhGc4n3b)eyicQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8cPOIgHIciDMad8uegnlyGbkQOHFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbiOwlbQhsg)Eq1YK5bVqnkBGbcqqTwsHMmoSyXWKlYomtbdibI4F(3yekkG0zciIh0Koqh4bKaw8pPVWF0iNeEo5855AnRAgvFBKPjU4zKq(SsuBZhrFhMjbQhsglgMCrkEa0C6FJWQSGpI(omtYfOVhoS4ZJXdOLskEa0CUCt7VfGGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1Ytbh058ifAY4WIfdtUiCciDEl4JOVdZKuOjJdlwmm5Iu8aO5C5M2Fl4JOVdZKa1djJfdtUifpaAo93iuuaPZKlUbEakG3Ch8t6l8hnYjHNtoFEUwZQMr13gzAIlEgjKpRe128r03HzsUa99WHfFEmEaTusXdGMZgLfGGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1YtbFe9DyMeOEizSyyYfP4bqZ5YnT)wrfT0wVdx8aO5C5pI(omtcupKmwmm5Iu8aO5u6l8hnYjHNtoFEUwZQMr13gzAIlEgjKpRe128r03HzsG6HKXIHjxKIhanNnklWqF6GoNhHZoT174K3eobKoVvurdpOZ5r4StB9oo5nHtaPZBbdibI4F(3iCuwrfncffq6mbg4PimAwWadeyOHFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotar8auaV5o4NadrqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88Gxifv0iuuaPZeyGNIWOzbdmqrfn8JOVdZKCb67Hdl(8y8aAPKIhanNnklab1Ajq9qY43dQwMmp4fQrzdmqacQ1sk0KXHflgMCr2Hzkyajqe)Z)gJqrbKotar8GM0b6apGeWI)j9f(Jg5KWZjNppxRz1wuO2uiXHfdcp4kopLO2MpI(omtYfOVhoS4ZJXdOLskEa0C2OSaeuRLa1djJFpOAzY8GxOLBmcffq6m5IBGhGc43dQwEk4JOVdZKa1djJfdtUifpaAoxUP93kQOL26D4IhanNl)r03HzsG6HKXIHjxKIhanNsFH)Oroj8CY5ZZ1AwTffQnfsCyXGWdUIZtjQT5JOVdZKa1djJfdtUifpaAoBuwGH(0bDopcNDAR3XjVjCciDEROIgEqNZJWzN26DCYBcNasN3cgqceX)8Vr4OSIkAekkG0zcmWtry0SGbgiWqd)i67WmjxG(E4WIppgpGwkP4bqZP)gHIciDMaI4bOaEZDWpbgIGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqkQOrOOasNjWapfHrZcgyGIkA4hrFhMj5c03dhw85X4b0sjfpaAoBuwacQ1sG6HKXVhuTmzEWluJYgyGaeuRLuOjJdlwmm5ISdZuWasGi(N)ngHIciDMaI4bnPd0bEajGf)t6l8hnYjHNtoFEUwZQFKpNxbhVX2omyL60KX)UzfRe12GGATeOEizSyyYfzhMPaeuRLuOjJdlwmm5ISdZuWMrqTwYfOVhoS4ZJXdOLs2Hzkyajqo6GXxGhGc(3WkWp6X4JoyPVWF0iNeEo5855AnRwmisZwSTddEQe12GGATeOEizSyyYfzhMPaeuRLuOjJdlwmm5ISdZuWMrqTwYfOVhoS4ZJXdOLs2Hzkyajqo6GXxGhGc(3WkWp6X4JoyPVWF0iNeEo5855AnRAJhDYBmi8Gl6XyeggkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMsFH)Oroj8CY5ZZ1AwveTOw)OzlgPdZtjQTbb1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZu6l8hnYjHNtoFEUwZQfvuSZyAINIWZkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMsFH)Oroj8CY5ZZ1Aw98ymAIeO5gBJ6zLO2geuRLa1djJfdtUi7WmfGGATKcnzCyXIHjxKDyMc2mcQ1sUa99WHfFEmEaTuYomtPVWF0iNeEo5855AnRo4ru(HdlUJ(0nExmmMkrTniOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMsFL(c)rJCscro5ATMvncffq6Ssjm4gpWiJdro5TsHyZKpLmcDuUzbLO2gXInIB)nzbcBmE4Ork9f(Jg5KeICY1AnRAPfJr6W8uIABk0KTr1YKnD(uXonHYp8hJbKBcVcOurrElab1AjB68PIDAcLF4pgdi3yBfZJGkk9f(Jg5KeICY1AnRARyE4mmckrTnfAY2OAzsBrND)W0N(DMWRakvuK3cgqceX)83NlSsFH)OrojHiNCTwZQdAvrnXHfFrn48K(c)rJCscro5ATMv3mCEirLS0x4pAKtsiYjxR1SAbBkKhEkcLqkrTndibI4F(l8vw6l8hnYjje5KR1Aw9H85og(JgPsuBd8hnsY0JApA2IfdtUiVhKj3PzRG2FtkEa0C2OS0x4pAKtsiYjxR1S60JApA2IfdtUuIABMbAhHMBILY9noSyKEmNXys4eq68w6l8hnYjje5KR1Aw9c03dhw85X4b0sL(c)rJCscro5ATMvH6HKXIHjxsFH)OrojHiNCTwZQfAY4WIfdtUuIABqqTwsHMmoSyXWKlYomtPVWF0iNKqKtUwRzvXINC(moS4bn3sFH)OrojHiNCTwZQq9qYyKompLO2MDCKc2uip8uekHifpaAo9xyvuXnJGATKc2uip8uekHWgr7jxacTtp)iZdEH8xzPVWF0iNKqKtUwRzvOEizmshMNsuBdcQ1selEY5Z4WIh0CtqffSzeuRLCb67Hdl(8y8aAPeurbBgb1AjxG(E4WIppgpGwkP4bqZ5YnWF0ijq9qYyKompcRa)OhJp6GL(c)rJCscro5ATMvH6HKXiqvqlRe12GGATeOEizSyyYfbvuacQ1sG6HKXIHjxKIhanNl30(BbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlK0x4pAKtsiYjxR1SkupKmEqNtANNkrTnBgb1AjxG(E4WIppgpGwkbvuWbDopcupKmMFVGWjG05TaeuRLSz48qIkzYomtbBgb1AjxG(E4WIppgpGwkP4bqZP)WF0ijq9qY4bDoPDEsyf4h9y8rhSsVhqZMfK(c)rJCscro5ATMvH6HKXd6Cs78ujQTbb1AjFNH6H5rZwsXWFk9EanBwq6l8hnYjje5KR1AwfQhsghfIsuBdcQ1sG6HKXVhuTmzEWl0YngHIciDMCXnWdqb87bvlpfy4hrFhMjbQhsglgMCrkEa0C6)ckROIWFuJmMtEq55YnR0aPVWF0iNKqKtUwRzvOEizmshMNsuBdcQ1sk0KXHflgMCrqfvuXbKar8p)xqyL(c)rJCscro5ATMvzJXdhnsLO2geuRLuOjJdlwmm5ISdZujAECvOIhMABgqceX)8Vr4kSkrZJRcv8W0XG3u44MfK(c)rJCscro5ATMvH6HKXiqvqll9v6l8hnYj5JOVdZCUwZQ2kMhodJGsuBtHMSnQwM0w0z3pm9PFNj8kGsff5TGpI(omtcupKmwmm5Iu8aO50FFuzbFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbgIGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1YtbgA4bDopsHMmoSyXWKlcNasN3c(i67WmjfAY4WIfdtUifpaAoxUP93c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)mqrfn0NoOZ5rk0KXHflgMCr4eq68wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NbkQ4hrFhMjbQhsglgMCrkEa0CUCt7VnWaHbLKAHbHzVOrrpQWdwQrN0SvQBl6S7NutF63zP2KEEsnisKAH3twQPNuBsppP(IBi1X5XLjDYePVWF0iNKpI(omZ5AnRARyE4mmckrTnfAY2OAzsBrND)W0N(DMWRakvuK3c(i67Wmjq9qYyXWKlsXdGMZgLfyOpDqNZJWzN26DCYBcNasN3kQOHh058iC2PTEhN8MWjG05TGbKar8p)BeokBGbcm0WpI(omtYfOVhoS4ZJXdOLskEa0C6)cklab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHmqrfn8JOVdZKCb67Hdl(8y8aAPKIhanNnklab1Ajq9qY43dQwMmp4fQrzdmqacQ1sk0KXHflgMCr2Hzkyajqe)Z)gJqrbKotar8GM0b6apGeWI)j9f(Jg5K8r03HzoxRzvBfZdj6NsuBtHMSnQwMSPZNk2Pju(H)ymGCt4vaLkkYBbFe9DyMeeuRfVPZNk2Pju(H)ymGCtkg2(jab1AjB68PIDAcLF4pgdi3yBfZJSdZuGHiOwlbQhsglgMCr2Hzkab1AjfAY4WIfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMgi4JOVdZKCb67Hdl(8y8aAPKIhanNnklWqeuRLa1djJFpOAzY8GxOLBmcffq6m5IBGhGc43dQwEkWqdpOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZ5YnT)wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NbkQOH(0bDopsHMmoSyXWKlcNasN3c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)mqrf)i67Wmjq9qYyXWKlsXdGMZLBA)Tbgi9f(Jg5K8r03HzoxRzvlTymshMNsuBtHMSnQwMSPZNk2Pju(H)ymGCt4vaLkkYBbFe9DyMeeuRfVPZNk2Pju(H)ymGCtkg2(jab1AjB68PIDAcLF4pgdi3ylTyYomtbIfBe3(BYceBfZdj6N0x4pAKtYhrFhM5CTMvh0QIAIdl(IAW5Pe128r03HzsUa99WHfFEmEaTusXdGMZgLfGGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1YtbFe9DyMeOEizSyyYfP4bqZ5YnT)wyqjPwyyfTBc(nLA0jl1dAvrnLAt65j1GirQfEzL6lUHutNsDXW2pPgMsTj37kj1dqiwQNOfl1xi1pmpPMEsncBJIL6lUbr6l8hnYj5JOVdZCUwZQdAvrnXHfFrn48uIAB(i67Wmjq9qYyXWKlsXdGMZgLfyOpDqNZJWzN26DCYBcNasN3kQOHh058iC2PTEhN8MWjG05TGbKar8p)BeokBGbcm0WpI(omtYfOVhoS4ZJXdOLskEa0C6VrOOasNjGiEakG3Ch8tacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8czGIkA4hrFhMj5c03dhw85X4b0sjfpaAoBuwacQ1sG6HKXVhuTmzEWluJYgyGaeuRLuOjJdlwmm5ISdZuWasGi(N)ngHIciDMaI4bnPd0bEajGf)t6l8hnYj5JOVdZCUwZQBgopKOswjQT5JOVdZKCb67Hdl(8y8aAPKIhanNnklab1Ajq9qY43dQwMmp4fA5gJqrbKotU4g4bOa(9GQLNc(i67Wmjq9qYyXWKlsXdGMZLBA)TWGssTWWkA3e8Bk1OtwQ3mCEirLSuBsppPgejsTWlRuFXnKA6uQlg2(j1WuQn5ExjPEacXs9eTyP(cP(H5j10tQryBuSuFXnisFH)OrojFe9DyMZ1AwDZW5HevYkrTnFe9DyMeOEizSyyYfP4bqZzJYcm0NoOZ5r4StB9oo5nHtaPZBfv0Wd6CEeo70wVJtEt4eq68wWasGi(N)nchLnWabgA4hrFhMj5c03dhw85X4b0sjfpaAo9FbLfGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqgOOIg(r03HzsUa99WHfFEmEaTusXdGMZgLfGGATeOEiz87bvltMh8c1OSbgiab1AjfAY4WIfdtUi7WmfmGeiI)5FJrOOasNjGiEqt6aDGhqcyX)K(c)rJCs(i67WmNR1SAbBkKhEkcLqkrTnFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotQjEakG3Ch8tWhrFhMjbQhsglgMCrkEa0C6VrOOasNj1epafWBUd(jWWd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7VvuXd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0C6VrOOasNj1epafWBUd(POI(0bDopsHMmoSyXWKlcNasN3giab1Ajq9qY43dQwMmp4fY)vkyZiOwl5c03dhw85X4b0sj7WmfgusQfgeEpzPEkcLqsn1k1xCdPgYTudIsnuSuhPu)BPgYTuBgPpCsncl1OIsTnkPUhzlxs95bPuFESupafK6n3b)usQhGq0SvQNOfl1MSu7bgzPgoPUZW8K6ZmKAOEizP(9GQLNsnKBP(8GtQV4gsTjmtF4KAH5qNNuJo5nr6l8hnYj5JOVdZCUwZQfSPqE4PiucPe128r03HzsUa99WHfFEmEaTusXdGMZgLfGGATeOEiz87bvltMh8cTCJrOOasNjxCd8aua)Eq1YtbFe9DyMeOEizSyyYfP4bqZ5YnT)wyqjPwyq49KL6Piucj1M0ZtQbrP20JtPwmMtksNjsTWlRuFXnKA6uQlg2(j1WuQn5ExjPEacXs9eTyP(cP(H5j10tQryBuSuFXnisFH)OrojFe9DyMZ1AwTGnfYdpfHsiLO2MpI(omtcupKmwmm5Iu8aO5SrzbgAOpDqNZJWzN26DCYBcNasN3kQOHh058iC2PTEhN8MWjG05TGbKar8p)BeokBGbcm0WpI(omtYfOVhoS4ZJXdOLskEa0C6VrOOasNjGiEakG3Ch8tacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8czGIkA4hrFhMj5c03dhw85X4b0sjfpaAoBuwacQ1sG6HKXVhuTmzEWluJYgyGaeuRLuOjJdlwmm5ISdZuWasGi(N)ngHIciDMaI4bnPd0bEajGf)ZaPVWF0iNKpI(omZ5AnREb67Hdl(8y8aAPkrTnFe9DyMeOEizSyyYfP4bqZ5YcRYc45KZNjgPtAK4WIf5YY)rJKmOzusFH)OrojFe9DyMZ1Aw9c03dhw85X4b0svIABqqTwcupKm(9GQLjZdEHwUXiuuaPZKlUbEakGFpOA5PGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(j4dJCc5reYVIcjHtaPZBbFe9DyMKc2uip8uekHifpaAoxUr4kmOKulmSIGFffsHjPw49KL6lUHutTsnik10PuhPu)BPgYTuBgPpCsncl1OIsTnkPUhzlxs95bPuFESupafK6n3b)is9kAN2MsTj98K6keLAQvQppwQpOZ5j10PuFGqCsKAHzl6BPgKAe6j1xi1dqiwQNOfl1MSu)qk1cZRk10XG3u44UFsnypUK6lUHuZ5Ek9f(Jg5K8r03HzoxRz1lqFpCyXNhJhqlvjQTbb1Ajq9qY43dQwMmp4fA5gJqrbKotU4g4bOa(9GQLNcoOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZ5YnT)wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NaF6dJCc5reYVIcjHtaPZBHbLKAHHLIu45Ri4xrHuysQfEpzP(IBi1uRudIsnDk1rk1)wQHCl1Mr6dNuJWsnQOuBJsQ7r2YLuFEqk1Nhl1dqbPEZDWpIuVI2PTPuBsppPUcrPMAL6ZJL6d6CEsnDk1hieNePVWF0iNKpI(omZ5AnREb67Hdl(8y8aAPkrTniOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uGpDqNZJuOjJdlwmm5IWjG05TGpI(omtcupKmwmm5Iu8aO50FJqrbKotU4g4bOaEZDWpPVWF0iNKpI(omZ5AnREb67Hdl(8y8aAPkrTniOwlbQhsg)Eq1YK5bVql3yekkG0zYf3apafWVhuT8uWhrFhMjbQhsglgMCrkEa0CUCt7VL(c)rJCs(i67WmNR1SkupKmwmm5sjQTXqF6GoNhHZoT174K3eobKoVvurdpOZ5r4StB9oo5nHtaPZBbdibI4F(3iCu2ade8r03HzsUa99WHfFEmEaTusXdGMt)ncffq6mbeXdqb8M7GFcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxibiOwlPqtghwSyyYfzhMPGbKar8p)Bmcffq6mbeXdAshOd8asal(NWGssTWGW7jl1GOutTs9f3qQPtPosP(3snKBP2msF4KAewQrfLABusDpYwUK6ZdsP(8yPEaki1BUd(PKupaHOzRuprlwQpp4KAtwQ9aJSuZzG26j1dibPgYTuFEWj1NhxSutNsDgNud9IHTFsni1fAYsDyLAXWKlPEhMjr6l8hnYj5JOVdZCUwZQfAY4WIfdtUuIABqqTwsHMmoSyXWKlYomtbFe9DyMKlqFpCyXNhJhqlLu8aO50FJqrbKotQqepafWBUd(jab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHey4hrFhMjbQhsglgMCrkEa0C6)ccRIkUzeuRLCb67Hdl(8y8aAPeurdegusQfgeEpzPUcrPMAL6lUHutNsDKs9VLAi3sTzK(Wj1iSuJkk12OK6EKTCj1NhKs95Xs9auqQ3Ch8tjPEacrZwPEIwSuFECXsnDM(Wj1qVyy7NudsDHMSuVdZuQHCl1NhCsnik1Mr6dNuJWFmyPgmc0oG0zPEJw0SvQl0KjsFH)OrojFe9DyMZ1AwvS4jNpJdlEqZTsuBdcQ1sG6HKXVhuTmzEWluJYc(WiNqEeH8ROqs4eq68wyqjPwyyfb)kkKctsTW8QsnDk1dibP2dnBl)KAi3s9k66c)Pudfl1xesnRGiNtQrwQVqQrNSulgdP(cPEUcOml8GLAiLAwHRaPgqKAAk1Nhl1xCdP2KM7WKi1(S85dtPgDYsn9K6lK6biel19WuQFpOAzPEfD9PutZ5b5rK(c)rJCs(i67WmNR1SQyXtoFghw8GMBLO2MnJGATKlqFpCyXNhJhqlLGkkWN(WiNqEeH8ROqs4eq68wyqjPwyyPifE(kc(vuifMKAH3twQfJHuFHupxbuMfEWsnKsnRWvGudisnnL6ZJL6lUHuBsZDysK(k9f(Jg5KuXbhnY1Aw1iuuaPZkLWGBS0e6ye0kvkeBM8PKrOJYnlOe12GGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqc8jeuRLuODghw85vmpjOIcS0wVdx8aO5C5gdnCaji8m4pAKeOEizmshMh5J5zGWmWF0ijq9qYyKompcRa)OhJp6Gnq6l8hnYjPIdoAKR1SkupKmgbQcAzLO2MpI(omtYfOVhoS4ZJXdOLskEa0C2OSadrqTwcupKm(9GQLjZdEH83iuuaPZKlUbEakGFpOA5PGd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(BekkG0zYf3apafWBUd(j4dJCc5reYVIcjHtaPZBbFe9DyMKc2uip8uekHifpaAoxUr4AG0x4pAKtsfhC0ixRzvOEizmcuf0YkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbgIGATeOEiz87bvltMh8c5VrOOasNjxCd8aua)Eq1Ytbh058ifAY4WIfdtUiCciDEl4JOVdZKuOjJdlwmm5Iu8aO5C5M2Fl4JOVdZKa1djJfdtUifpaAo93iuuaPZKlUbEakG3Ch8tGp9HroH8ic5xrHKWjG05TbsFH)OrojvCWrJCTMvH6HKXiqvqlRe128r03HzsUa99WHfFEmEaTusXdGMZgLfyicQ1sG6HKXVhuTmzEWlK)gHIciDMCXnWdqb87bvlpf4th058ifAY4WIfdtUiCciDEl4JOVdZKa1djJfdtUifpaAo93iuuaPZKlUbEakG3Ch8ZaPVWF0iNKko4OrUwZQq9qYyeOkOLvIAB(i67WmjxG(E4WIppgpGwkP4bqZzJYcmeb1Ajq9qY43dQwMmp4fYFJqrbKotU4g4bOa(9GQLNc(i67Wmjq9qYyXWKlsXdGMZLBA)TbsFxrk1lX8wQVqQPdXop48K65v0)K6jVcOC(8uQJsQrqP9TudPud9JReoQrwQ94IjsFxrk1WF0iNKko4OrUwZQZRO)HN8kGY5ZkrTnBgb1AjfSPqE4PiucHnI2tUaeANE(rMh8c1SzeuRLuWMc5HNIqje2iAp5cqOD65hzakGNh8cjab1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPsjm4Momp8uekHWZdEHeMG6HKXiDyEctq9qYyeOkOLL(c)rJCsQ4GJg5AnRc1djJrGQGwwjQTzZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8GxOMnJGATKc2uip8uekHWgr7jxacTtp)idqb88GxibgIGATeOEizSyyYfzhMPIkIGATeOEizSyyYfP4bqZ5YnT)2abgIGATKcnzCyXIHjxKDyMkQicQ1sk0KXHflgMCrkEa0CUCt7Vnq6l8hnYjPIdoAKR1SkupKmgPdZtjQTzhhPGnfYdpfHsisXdGMt)fwfvCZiOwlPGnfYdpfHsiSr0EYfGq70ZpY8Gxi)vw6l8hnYjPIdoAKR1SkupKmgPdZtjQTbb1AjIfp58zCyXdAUjOIc2mcQ1sUa99WHfFEmEaTucQOGnJGATKlqFpCyXNhJhqlLu8aO5C5g4pAKeOEizmshMhHvGF0JXhDWsFH)OrojvCWrJCTMvH6HKXd6Cs78ujQTzZiOwl5c03dhw85X4b0sjOIcoOZ5rG6HKX87feobKoVfGGATKndNhsujt2HzkWWnJGATKlqFpCyXNhJhqlLu8aO50F4pAKeOEiz8GoN0opjSc8JEm(Odwrf)i67WmjIfp58zCyXdAUjfpaAo9xzfv8dJCc5reYVIcjHtaPZBdu69aA2SG0x4pAKtsfhC0ixRzvOEiz8GoN0opvIABqqTwY3zOEyE0SLum8NaeuRLWkic5M3yX448OqNGkk9f(Jg5KuXbhnY1AwfQhsgpOZjTZtLO2geuRL8DgQhMhnBjfd)jWqeuRLa1djJfdtUiOIkQicQ1sk0KXHflgMCrqfvuXnJGATKlqFpCyXNhJhqlLu8aO50F4pAKeOEiz8GoN0opjSc8JEm(Od2aLEpGMnli9f(Jg5KuXbhnY1AwfQhsgpOZjTZtLO2geuRL8DgQhMhnBjfd)jab1AjFNH6H5rZwY8GxOgeuRL8DgQhMhnBjdqb88GxiLEpGMnli9f(Jg5KuXbhnY1AwfQhsgpOZjTZtLO2geuRL8DgQhMhnBjfd)jab1AjFNH6H5rZwsXdGMZLBm0qeuRL8DgQhMhnBjZdEHeMb(JgjbQhsgpOZjTZtcRa)OhJp6GnyT2FBGsVhqZMfK(c)rJCsQ4GJg5AnRM85Xf(4HippLO2gdl2w80dq6SIk6th9fIMTgiab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHeGGATeOEizSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZu6l8hnYjPIdoAKR1SkupKmokeLO2geuRLa1djJFpOAzY8GxOLBmcffq6m5IBGhGc43dQwEk9f(Jg5KuXbhnY1AwDIkYvggbLO2MbKar8VLB85cRaeuRLa1djJfdtUi7WmfGGATKcnzCyXIHjxKDyMc2mcQ1sUa99WHfFEmEaTuYomtPVWF0iNKko4OrUwZQtpQ9Ozlwmm5sjQTbb1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZuWhrFhMjHngpC0ijfpaAo9xzbFe9DyMeOEizSyyYfP4bqZP)kl4JOVdZKCb67Hdl(8y8aAPKIhanN(RSad9Pd6CEKcnzCyXIHjxeobKoVvurdpOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZP)kBGbsFH)OrojvCWrJCTMvH6HKXiDyEkrTniOwlPq7moS4ZRyEsqffGGATeOEiz87bvltMh8c5Vpk9f(Jg5KuXbhnY1AwfQhsgJavbTSsuBZasGi(3YgHIciDMGavbTmEajGf)tWhrFhMjHngpC0ijfpaAo9xzbiOwlbQhsglgMCr2Hzkab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHeWZjNptmsN0iXHflYLL)JgjzqZOK(c)rJCsQ4GJg5AnRc1djJrGQGwwjQT5JOVdZKCb67Hdl(8y8aAPKIhanNnklWWpI(omtsHMmoSyXWKlsXdGMZgLvuXpI(omtcupKmwmm5Iu8aO5SrzdeGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqsFH)OrojvCWrJCTMvH6HKXiqvqlRe12mGeiI)TCJrOOasNjiqvqlJhqcyX)eGGATeOEizSyyYfzhMPaeuRLuOjJdlwmm5ISdZuWMrqTwYfOVhoS4ZJXdOLs2Hzkab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHe8r03HzsyJXdhnssXdGMt)vw6l8hnYjPIdoAKR1SkupKmgbQcAzLO2geuRLa1djJfdtUi7WmfGGATKcnzCyXIHjxKDyMc2mcQ1sUa99WHfFEmEaTuYomtbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKGd6CEeOEizCuieobKoVf8r03HzsG6HKXrHqkEa0CUCt7VfmGeiI)TCJpxzbFe9DyMe2y8WrJKu8aO50FLL(c)rJCsQ4GJg5AnRc1djJrGQGwwjQTbb1Ajq9qYyXWKlcQOaeuRLa1djJfdtUifpaAoxUP93cqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiPVWF0iNKko4OrUwZQq9qYyeOkOLvIABqqTwsHMmoSyXWKlcQOaeuRLuOjJdlwmm5Iu8aO5C5M2Flab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHK(c)rJCsQ4GJg5AnRc1djJrGQGwwjQTbb1Ajq9qYyXWKlYomtbiOwlPqtghwSyyYfzhMPGnJGATKlqFpCyXNhJhqlLGkkyZiOwl5c03dhw85X4b0sjfpaAoxUP93cqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiPVWF0iNKko4OrUwZQq9qYyKompPVWF0iNKko4OrUwZQSX4HJgPs084Qqfpm12mGeiI)5FJWvyvIMhxfQ4HPJbVPWXnli9f(Jg5KuXbhnY1AwfQhsgJavbTS0xPVWF0iNelnHogbTY1AwfQhsgpOZjTZtLO2geuRL8DgQhMhnBjfd)P07b0SzbPVWF0iNelnHogbTY1AwfQhsgJ0H5j9f(Jg5KyPj0XiOvUwZQq9qYyeOkOLL(k9f(Jg5KabVwZQ2kMhs0pLO2McnzBuTmztNpvSttO8d)Xya5MWRakvuK3c(i67WmjiOwlEtNpvSttO8d)Xya5MumS9tacQ1s205tf70ek)WFmgqUX2kMhzhMPadrqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzkyZiOwl5c03dhw85X4b0sj7WmnqWhrFhMj5c03dhw85X4b0sjfpaAoBuwGHiOwlbQhsg)Eq1YK5bVql3yekkG0zcem(IBGhGc43dQwEkWqdpOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZ5YnT)wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NbkQOH(0bDopsHMmoSyXWKlcNasN3c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)mqrf)i67Wmjq9qYyXWKlsXdGMZLBA)Tbgi9f(Jg5KabVwZQwAXyKompLO2gdl0KTr1YKnD(uXonHYp8hJbKBcVcOurrEl4JOVdZKGGAT4nD(uXonHYp8hJbKBsXW2pbiOwlztNpvSttO8d)Xya5gBPft2HzkqSyJ42FtwGyRyEir)mqrfnSqt2gvlt205tf70ek)WFmgqUj8kGsff5TGJo4gLnq6l8hnYjbcETMvTvmpCggbLO2McnzBuTmPTOZUFy6t)ot4vaLkkYBbFe9DyMeOEizSyyYfP4bqZP)(OYc(i67WmjxG(E4WIppgpGwkP4bqZzJYcmeb1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtbgA4bDopsHMmoSyXWKlcNasN3c(i67WmjfAY4WIfdtUifpaAoxUP93c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)mqrfn0NoOZ5rk0KXHflgMCr4eq68wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NbkQ4hrFhMjbQhsglgMCrkEa0CUCt7VnWaPVWF0iNei41Aw1wX8WzyeuIABk0KTr1YK2Io7(HPp97mHxbuQOiVf8r03HzsG6HKXIHjxKIhanNnklWqdn8JOVdZKCb67Hdl(8y8aAPKIhanN(BekkG0zciIhGc4n3b)eGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqgOOIg(r03HzsUa99WHfFEmEaTusXdGMZgLfGGATeOEiz87bvltMh8cTCJrOOasNjqW4lUbEakGFpOA5Pbgiab1AjfAY4WIfdtUi7Wmnq6l8hnYjbcETMvVa99WHfFEmEaTuLO2McnzBuTmzsf9IepVOgeEfqPII8wGyXgXT)MSaHngpC0iL(c)rJCsGGxRzvOEizSyyYLsuBtHMSnQwMmPIErINxudcVcOurrElWqXInIB)nzbcBmE4OrQOIIfBe3(BYcKlqFpCyXNhJhql1aPVWF0iNei41AwLngpC0ivIABo6G93hvwqHMSnQwMmPIErINxudcVcOurrElab1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtbFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbFe9DyMeOEizSyyYfP4bqZ5YnT)w6l8hnYjbcETMvzJXdhnsLO2MJoy)9rLfuOjBJQLjtQOxK45f1GWRakvuK3c(i67Wmjq9qYyXWKlsXdGMZgLfyOHg(r03HzsUa99WHfFEmEaTusXdGMt)ncffq6mbeXdqb8M7GFcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88Gxiduurd)i67WmjxG(E4WIppgpGwkP4bqZzJYcqqTwcupKm(9GQLjZdEHwUXiuuaPZeiy8f3apafWVhuT80adeGGATKcnzCyXIHjxKDyMgOenpUkuXdtTniOwlzsf9IepVOgK5bVqniOwlzsf9IepVOgKbOaEEWlKs084QqfpmDm4nfoUzbPVWF0iNei41AwDqRkQjoS4lQbNNsuBJHFe9DyMeOEizSyyYfP4bqZP)cFHvrf)i67Wmjq9qYyXWKlsXdGMZLB8rde8r03HzsUa99WHfFEmEaTusXdGMZgLfyicQ1sG6HKXVhuTmzEWl0YngHIciDMabJV4g4bOa(9GQLNcm0Wd6CEKcnzCyXIHjxeobKoVf8r03Hzsk0KXHflgMCrkEa0CUCt7Vf8r03HzsG6HKXIHjxKIhanN(lSgOOIg6th058ifAY4WIfdtUiCciDEl4JOVdZKa1djJfdtUifpaAo9xynqrf)i67Wmjq9qYyXWKlsXdGMZLBA)Tbgi9f(Jg5KabVwZQfSPqE4PiucPe128r03HzsUa99WHfFEmEaTusXdGMt)ncffq6mPM4bOaEZDWpbFe9DyMeOEizSyyYfP4bqZP)gHIciDMut8auaV5o4NadpOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZ5YnT)wrfpOZ5rk0KXHflgMCr4eq68wWhrFhMjPqtghwSyyYfP4bqZP)gHIciDMut8auaV5o4NIk6th058ifAY4WIfdtUiCciDEBGaeuRLa1djJFpOAzY8GxOLBmcffq6mbcgFXnWdqb87bvlpfSzeuRLCb67Hdl(8y8aAPKDyMsFH)OrojqWR1SAbBkKhEkcLqkrTnFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbgIGATeOEiz87bvltMh8cTCJrOOasNjqW4lUbEakGFpOA5Padn8GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanNl30(BbFe9DyMeOEizSyyYfP4bqZP)gHIciDMCXnWdqb8M7GFgOOIg6th058ifAY4WIfdtUiCciDEl4JOVdZKa1djJfdtUifpaAo93iuuaPZKlUbEakG3Ch8Zafv8JOVdZKa1djJfdtUifpaAoxUP93gyG0x4pAKtce8AnRwWMc5HNIqjKsuBZhrFhMjbQhsglgMCrkEa0C2OSadn0WpI(omtYfOVhoS4ZJXdOLskEa0C6VrOOasNjGiEakG3Ch8tacQ1sG6HKXVhuTmzEWludcQ1sG6HKXVhuTmzakGNh8czGIkA4hrFhMj5c03dhw85X4b0sjfpaAoBuwacQ1sG6HKXVhuTmzEWl0YngHIciDMabJV4g4bOa(9GQLNgyGaeuRLuOjJdlwmm5ISdZ0aPVWF0iNei41AwDZW5HevYkrTnFe9DyMeOEizSyyYfP4bqZzJYcm0qd)i67WmjxG(E4WIppgpGwkP4bqZP)gHIciDMaI4bOaEZDWpbiOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlKbkQOHFe9DyMKlqFpCyXNhJhqlLu8aO5SrzbiOwlbQhsg)Eq1YK5bVql3yekkG0zcem(IBGhGc43dQwEAGbcqqTwsHMmoSyXWKlYomtdK(c)rJCsGGxRz1lqFpCyXNhJhqlvjQTbb1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtbgA4bDopsHMmoSyXWKlcNasN3c(i67WmjfAY4WIfdtUifpaAoxUP93c(i67Wmjq9qYyXWKlsXdGMt)ncffq6m5IBGhGc4n3b)mqrfn0NoOZ5rk0KXHflgMCr4eq68wWhrFhMjbQhsglgMCrkEa0C6VrOOasNjxCd8auaV5o4NbkQ4hrFhMjbQhsglgMCrkEa0CUCt7Vnq6l8hnYjbcETMvH6HKXIHjxkrTngA4hrFhMj5c03dhw85X4b0sjfpaAo93iuuaPZeqepafWBUd(jab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHmqrfn8JOVdZKCb67Hdl(8y8aAPKIhanNnklab1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtdmqacQ1sk0KXHflgMCr2Hzk9f(Jg5KabVwZQfAY4WIfdtUuIABqqTwsHMmoSyXWKlYomtbgA4hrFhMj5c03dhw85X4b0sjfpaAo9FLklab1Ajq9qY43dQwMmp4fQbb1Ajq9qY43dQwMmafWZdEHmqrfn8JOVdZKCb67Hdl(8y8aAPKIhanNnklab1Ajq9qY43dQwMmp4fA5gJqrbKotGGXxCd8aua)Eq1YtdmqGHFe9DyMeOEizSyyYfP4bqZP)liSkQ4MrqTwYfOVhoS4ZJXdOLsqfnq6l8hnYjbcETMvflEY5Z4WIh0CRe12GGATKndNhsujtqffSzeuRLCb67Hdl(8y8aAPeurbBgb1AjxG(E4WIppgpGwkP4bqZ5YniOwlrS4jNpJdlEqZnzakGNh8cjmd8hnscupKmgPdZJWkWp6X4JoyPVWF0iNei41AwfQhsgJ0H5Pe12GGATKndNhsujtqffyOHh058ifpJeYNjCciDEla(JAKXCYdkpxw4BGIkc)rnYyo5bLNllSgi9f(Jg5KabVwZQturUYWii9f(Jg5KabVwZQq9qY4OquIABqqTwcupKm(9GQLjZdEHAuw6l8hnYjbcETMvt(84cF8qKNNsuBJHfBlE6biDwrf9PJ(crZwdeGGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqsFH)OrojqWR1S60JApA2IfdtUuIABqqTwcupKmwmm5ISdZuacQ1sk0KXHflgMCr2HzkyZiOwl5c03dhw85X4b0sj7Wmf8r03HzsG6HKXIHjxKIhanN(RSGpI(omtYfOVhoS4ZJXdOLskEa0C6VYcm0NoOZ5rk0KXHflgMCr4eq68wrfn8GoNhPqtghwSyyYfHtaPZBbFe9DyMKcnzCyXIHjxKIhanN(RSbgi9f(Jg5KabVwZQq9qY4bDoPDEQe12GGATKVZq9W8OzlPy4pbfAY2OAzcupKmMMwAsp)i8kGsff5TGd6CEeyi2Pw6dhnscNasN3cG)OgzmN8GYZL95sFH)OrojqWR1SkupKmEqNtANNkrTniOwl57mupmpA2skg(tqHMSnQwMa1djJPPLM0ZpcVcOurrEla(JAKXCYdkpxEfl9f(Jg5KabVwZQq9qYywbXEmPrQe12GGATeOEiz87bvltMh8cTmcQ1sG6HKXVhuTmzakGNh8cj9f(Jg5KabVwZQq9qYywbXEmPrQe12GGATeOEiz87bvltMh8c1GGATeOEiz87bvltgGc45bVqcel2iU93Kfiq9qYyeOkOLL(c)rJCsGGxRzvOEizmcuf0YkrTniOwlbQhsg)Eq1YK5bVqniOwlbQhsg)Eq1YKbOaEEWlK0x4pAKtce8AnRYgJhoAKkrZJRcv8WuBZasGi(N)ncxHvjAECvOIhMog8Mch3SG0xPVWF0iNeyGNIWyTMvVa99WHfFEmEaTuLO2gd)i67Wmjq9qYyXWKlsXdGMZgLvuXpI(omtsHMmoSyXWKlsXdGMZLBA)TbcqqTwsHMmoSyXWKlYomtPVWF0iNeyGNIWyTMvH6HKXIHjxkrTniOwlPqtghwSyyYfzhMP0x4pAKtcmWtrySwZQfAY4WIfdtUuIABqqTwsHMmoSyXWKlYomtPVWF0iNeyGNIWyTMvH6HKXiqvqlRe12GGATeOEizSyyYfbvuacQ1sG6HKXIHjxKIhanNl3a)rJKa1djJh05K25jHvGF0JXhDWcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiPVWF0iNeyGNIWyTMvH6HKXrHOe12GGATeOEiz87bvltMh8cTmcQ1sG6HKXVhuTmzakGNh8cjab1AjfAY4WIfdtUi7WmfGGATeOEizSyyYfzhMPGnJGATKlqFpCyXNhJhqlLSdZu6l8hnYjbg4PimwRzvOEizmcuf0YkrTniOwlPqtghwSyyYfzhMPaeuRLa1djJfdtUi7WmfSzeuRLCb67Hdl(8y8aAPKDyMcqqTwcupKm(9GQLjZdEHAqqTwcupKm(9GQLjdqb88GxiPVWF0iNeyGNIWyTMvH6HKXd6Cs78uP3dOzZcsFH)OrojWapfHXAnRYgJhoAKkrZJRcv8WuBZasGi(N)ncxHvjAECvOIhMog8Mch3SG0x4pAKtcmWtrySwZQq9qY4OquIABqqTwcupKm(9GQLjZdEHwgb1Ajq9qY43dQwMmafWZdEHK(c)rJCsGbEkcJ1AwfQhsgJavbTS0x4pAKtcmWtrySwZQq9qYyKompPVsFH)OrojJWip48wRzvKonfcdPFkrTnJWip48iB68G8z)BwqzPVWF0iNKryKhCER1SQyXtoFghw8GMBPVWF0iNKryKhCER1SkupKmEqNtANNkrTnJWip48iB68G85LxqzPVWF0iNKryKhCER1SkupKmokePVWF0iNKryKhCER1SQLwmgPdZZPcONxuovv6aTdhnsFMcSN7CNZb]] )


end
