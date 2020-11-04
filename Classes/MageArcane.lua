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

    spec:RegisterResource( Enum.PowerType.Mana ) --[[, {
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
    } ) ]]

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
            tick_time = function () return haste end,
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


    local clearcasting_consumed = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
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
            
            elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
                -- Clearcasting was consumed.
                clearcasting_consumed = GetTime()
            end
        end
    end )


    spec:RegisterVariable( "have_opened", function ()
        if settings.am_spam then return 1 end
        if active_enemies > 2 or variable.prepull_evo == 1 then return 1 end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then return 1 end
        return 0
    end )


    local abs = math.abs

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
            -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
            burn_info.__start = 0
        end

        if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
            applyBuff( "clearcasting_channel", buff.casting.remains )
        end

        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        fake_mana_gem = nil

        incanters_flow.reset()
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
                if buff.rule_of_threes.up or buff.clearcasting.up then return 0 end
                return 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            aura = function () return buff.clearcasting_channel.up and "clearcasting_channel" or "casting" end,
            breakchannel = function ()
                removeBuff( "clearcasting_channel" )
            end,

            tick_time = function()
                if buff.clearcasting_channel.up then return buff.clearcasting_channel.tick_time end
                return 0.5 * haste
            end,

            start = function ()
                if buff.clearcasting.up then
                    removeStack( "clearcasting" )
                    applyBuff( "clearcasting_channel" )
                elseif buff.rule_of_threes.up then removeBuff( "rule_of_threes" ) end

                if buff.expanded_potential.up then removeBuff( "expanded_potential" ) end

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
                },
                clearcasting_channel = {
                    duration = function () return 2.5 * haste end,
                    tick_time = function () return ( 2.5 / 6 ) * haste end,
                    max_stack = 1,
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
            cast = function () return 6 * haste end,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,

            aura = "evocation",
            tick_time = function () return haste end,

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

                mana.regen = mana.regen * 8.5 / haste
            end,

            tick = function ()
                if legendary.siphon_storm.enabled then
                    addStack( "siphon_storm", nil, 1 )
                end
            end,

            finish = function ()
                mana.regen = mana.regen / 8.5 * haste
            end,

            breakchannel = function ()
                removeBuff( "evocation" )
                mana.regen = mana.regen / 8.5 * haste
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

            cdr = function ()
                return action.shifting_power.tick_time * ( 1 - ( conduit.discipline_of_the_grove.mod ) )
            end,

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
                    tick_time = function () return 1.5 * haste end,
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


    spec:RegisterPack( "Arcane", 20201101, [[dWuAgeqirfArkjkpsjHYLiOIuBIaFsubJIc5uKOwLscv9kLuMfjYTiOIs7cXVusAyuOoMOQwgbfpturMgbv5AeuABkjsFJGknocQQZPKqwNsIQ5Pe5EsyFkbhujryHkP6HIkk(OscvmscQiPtkQOKvkQ0ljOIQzkQOQBsqff7ujQHsqfjwQOIs9usAQkHUQsIOVQKqLglbvyVI8xOgmPomyXq6XQAYk1LrTzk9zjA0IYPrA1eur8AsWSL0Tv0UP63cdNqhxjblxQNRW0v56qSDk47u04jHoVOkRxurL5tq2prNYpTysDdhNwwymwymo)8noNictozCoj8e2K6LNiNufHxbOKtQom5K6kr)GZjvriVAa70Ij1rG0pNuZUtCSYxD1s6LHGs(yU6GorQWrd)BWERoOZF1KkkcTE5S8eAsDdhNwwymwymo)8noNictozCoj8YPK6qK)0YRuHjPMr3B2tOj1np(K6kMulCgOKL6vI(bNL5UIj1lhg4jk3sD(kj1cJXcJXYCL5UIj15S5zyGLAdqtb0ktGjEictPM6sTfmeTuhwPEW3r9YbbM4HimLAJ(m(vqQZlqAPEiYVuhIhn8HYezURys9kP4goEl1u)42HQuNb(Us9sPoSsTbOPaALjzGbghISZBP(cPgLL68LAZm2L6bFh1lheyIhIWuQlK68jYCxXK6vYbl1xEI0hQsTkDMZi1zGVRuVuQdRu)zG7CvQP(XDJiE0WLAQpog2sDyL6C4b)5kg(JgEoqsQv64gPftQHi7CNwmTC(PftQSdOvENwpPgIj1bFjv4pA4jvdqtb0kNunaveoPMFs9B6XnfsQInBax(Bs(e2q8WrdpPAaASdtoPMbgyCiYoVtxAzHjTysLDaTY706j1VPh3uiP2ioBJUKjB64PIvQdDE4pMtW3eEfqOII8wQfi1OiwlzthpvSsDOZd)XCc(gB7yCeeXKk8hn8KQL2mgTcJlDPLZP0Ijv2b0kVtRNu)MECtHKAJ4Sn6sMu20rnpm9PFLj8kGqff5TulqQNGdeX)K6fK6vKWMuH)OHNuTDmoShgG0Lww4LwmPc)rdpPoPDh9ahw8f9K9lPYoGw5DA90LwwytlMuH)OHNu3mCzOr7CsLDaTY706PlT8knTysLDaTY706j1VPh3uiPobhiI)j1li1cpJtQWF0WtQnSPGF4Hi0kKU0Yc30Ijv2b0kVtRNu)MECtHKk8hnCYiJApQxIfdtUjFg4oxPEPulqQl)nP5jq9Huxi1gNuH)OHNuFWFUIH)OHNU0Yc)0Ijv2b0kVtRNu)MECtHK6iqQOuFtSuUUXHfJwJXiMdc7aAL3jv4pA4j1rg1EuVelgMCNU0YRO0Ijv4pA4j1lq(mCyXxgJNqjnPYoGw5DA90LwoFJtlMuH)OHNuH(bNXIHj3jv2b0kVtRNU0Y5NFAXKk7aAL3P1tQFtpUPqsffXAjnIZ4WIfdtUj7W0tQWF0WtQnIZ4WIfdtUtxA58fM0Ijv4pA4jvXMhS)moS4j13jv2b0kVtRNU0Y5NtPftQSdOvENwpP(n94Mcj1DCKg2uWp8qeAfinpbQpK6fKAHvQfsiPEZOiwlPHnf8dpeHwbSbKQZnGsR0lpY4GxbPEbP24Kk8hn8Kk0p4mgTcJlDPLZx4LwmPYoGw5DA9K630JBkKurrSwIyZd2Fghw8K6BcIOulqQ3mkI1sUa5ZWHfFzmEcLucIOulqQ3mkI1sUa5ZWHfFzmEcLusZtG6dPEPcPg(Jgob6hCgJwHXryf5h5y8rNCsf(JgEsf6hCgJwHXLU0Y5lSPftQSdOvENwpP(n94McjvueRLa9doJfdtUjiIsTaPgfXAjq)GZyXWKBsZtG6dPEPcPU83sTaPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4viPc)rdpPc9doJrHUHsoDPLZFLMwmPYoGw5DA9Kk8hn8Kk0p4mEshdALhj1pdOEsn)K630JBkKu3mkI1sUa5ZWHfFzmEcLucIOulqQpOY(rG(bNX8Nfe2b0kVLAbsnkI1s2mCzOr7mzhMUulqQ3mkI1sUa5ZWHfFzmEcLusZtG6dPEbPg(Jgob6hCgpPJbTYdcRi)ihJp6KLAbsTrsDok1qoh30Jjq)GZyrK5KRuVKWoGw5TulKqsnkI1s(kd9dJJ6L4pdCNRKDy6sTYPlTC(c30Ijv2b0kVtRNuH)OHNuH(bNXt6yqR8iP(za1tQ5Nu)MECtHKkkI1s(kd9dJJ6LKMH)sxA58f(PftQSdOvENwpP(n94McjvueRLa9doJ)mOlzY4GxbPEPcP2a0uaTYKlUjEckI)mOl5HulqQnsQ)iQ7W0jq)GZyXWKBsZtG6dPEbPoFJLAHesQH)Ogym78KYdPEPcPwyKALtQWF0WtQq)GZ4OrtxA58xrPftQSdOvENwpP(n94McjvueRL0ioJdlwmm5MGik1cjKupbhiI)j1li15lSjv4pA4jvOFWzmAfgx6sllmgNwmPYoGw5DA9Kk8hn8KkBiE4OHNuP(XDJiEyQnPobhiI)TqHWxytQu)4UrepmDo5nfooPMFs9B6XnfsQOiwlPrCghwSyyYnzhME6sllm5NwmPc)rdpPc9doJrHUHsoPYoGw5DA90LUKkpgS)8iTyA58tlMuzhqR8oTEs9B6XnfsQFe1Dy6Klq(mCyXxgJNqjL08eO(qQlKAJLAbsnkI1sG(bNXFg0LmzCWRGuVuHuBaAkGwzYf3epbfXFg0L8qQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVuHux(BPwiHKAlTm7WnpbQpK6LK6pI6omDc0p4mwmm5M08eO(iPc)rdpPIwJyJdl(Yym78mV0LwwyslMuzhqR8oTEs9B6XnfsQFe1Dy6eOFWzSyyYnP5jq9Huxi1gl1cKAJK6CuQpOY(ryVslZo25nHDaTYBPwiHKAJK6dQSFe2R0YSJDEtyhqR8wQfi1tWbI4Fs9cfsTW1yPwiHK6bFh1lheyIhIWuQlK68LALLALLAbsTrsTrs9hrDhMo5cKpdhw8LX4jusjnpbQpK6fKAdqtb0ktar8eueV5kKNulqQnsQrrSwc0p4m(ZGUKjJdEfK6cPgfXAjq)GZ4pd6sMmbfXJdEfKAHesQh8DuVCqGjEictPUqQZxQvwQvwQfsiP2iP(JOUdtNCbYNHdl(Yy8ekPKMNa1hsDHuBSulqQrrSwc0p4m(ZGUKjJdEfK6cP2yPwzPwzPwGuJIyTKgXzCyXIHj3KDy6sTaPEcoqe)tQxOqQnanfqRmbeXtQtNit8eCal(xsf(JgEsfTgXghw8LXy25zEPlTCoLwmPYoGw5DA9K630JBkKu)iQ7W0jq)GZyXWKBsZtG6dPEHcPwynwQfi1Fe1Dy6Klq(mCyXxgJNqjL08eO(qQxQqQl)TulqQrrSwc0p4m(ZGUKjJdEfK6LkKAdqtb0ktU4M4jOi(ZGUKhsTaP(Gk7hPrCghwSyyYnHDaTYBPwGu)ru3HPtAeNXHflgMCtAEcuFi1lvi1L)wQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuBaAkGwzYf3epbfXBUc5LuH)OHNunJUUnWuh38iCWFoDPLfEPftQSdOvENwpP(n94Mcj1pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRm5IBINGI4pd6sEi1cK6pI6omDc0p4mwmm5M08eO(qQxQqQl)TulKqsTLwMD4MNa1hs9ss9hrDhMob6hCglgMCtAEcuFKuH)OHNunJUUnWuh38iCWFoDPLf20Ijv2b0kVtRNu)MECtHK6hrDhMob6hCglgMCtAEcuFi1fsTXsTaP2iPohL6dQSFe2R0YSJDEtyhqR8wQfsiP2iP(Gk7hH9kTm7yN3e2b0kVLAbs9eCGi(NuVqHulCnwQfsiPEW3r9YbbM4HimL6cPoFPwzPwzPwGuBKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPEbP2a0uaTYeqepbfXBUc5j1cKAJKAueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxbPwiHK6bFh1lheyIhIWuQlK68LALLALLAHesQnsQ)iQ7W0jxG8z4WIVmgpHskP5jq9Huxi1gl1cKAueRLa9doJ)mOlzY4GxbPUqQnwQvwQvwQfi1OiwlPrCghwSyyYnzhMUulqQNGdeX)K6fkKAdqtb0ktar8K60jYepbhWI)LuH)OHNunJUUnWuh38iCWFoDPLxPPftQSdOvENwpP(n94Mcj1pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRm5IBINGI4pd6sEi1cK6pI6omDc0p4mwmm5M08eO(qQxQqQl)TulKqsTLwMD4MNa1hs9ss9hrDhMob6hCglgMCtAEcuFKuH)OHNulrGEtbhhwmKZXDCzPlTSWnTysLDaTY706j1VPh3uiP(ru3HPtG(bNXIHj3KMNa1hsDHuBSulqQnsQZrP(Gk7hH9kTm7yN3e2b0kVLAHesQnsQpOY(ryVslZo25nHDaTYBPwGupbhiI)j1lui1cxJLAHesQh8DuVCqGjEictPUqQZxQvwQvwQfi1gj1gj1Fe1Dy6Klq(mCyXxgJNqjL08eO(qQxqQnanfqRmbeXtqr8MRqEsTaP2iPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4vqQfsiPEW3r9YbbM4HimL6cPoFPwzPwzPwiHKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQlKAJLALLALLAbsnkI1sAeNXHflgMCt2HPl1cK6j4ar8pPEHcP2a0uaTYeqepPoDImXtWbS4Fjv4pA4j1seO3uWXHfd5CChxw6sll8tlMuzhqR8oTEsf(JgEs9d)z)A44n2wHjNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPl1cK6j4a5OtgFbEckk1lui1SI8JCm(OtoPwPoJ)DsDLMU0YRO0Ijv2b0kVtRNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPl1cK6j4a5OtgFbEckk1lui1SI8JCm(OtoPc)rdpP2mis9sSTctEKU0Y5BCAXKk7aAL3P1tQFtpUPqsffXAjq)GZyXWKBYomDPwGuJIyTKgXzCyXIHj3KDy6sTaPEZOiwl5cKpdhw8LX4jusj7W0tQWF0WtQ24rg8gd5CCtpgJYWmDPLZp)0Ijv2b0kVtRNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPNuH)OHNufrAQnpQxIrRW4sxA58fM0Ijv2b0kVtRNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPNuH)OHNuBQOyLXuhpeHNtxA58ZP0Ijv2b0kVtRNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPNuH)OHNuVmgJ4ObIVX2OFoDPLZx4LwmPYoGw5DA9K630JBkKurrSwc0p4mwmm5MSdtxQfi1OiwlPrCghwSyyYnzhMUulqQ3mkI1sUa5ZWHfFzmEcLuYom9Kk8hn8K6KNrNhoS4kYt34DZWCKU0Lu)iQ7W0hPftlNFAXKk7aAL3P1tQFtpUPqsTrC2gDjtkB6OMhM(0VYeEfqOII8wQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuNtgl1cK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaP2iPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRm5IBINGI4pd6sEi1cKAJKAJK6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMoPrCghwSyyYnP5jq9HuVuHux(BPwGu)ru3HPtG(bNXIHj3KMNa1hs9csTbOPaALjxCt8eueV5kKNuRSulKqsTrsDok1huz)inIZ4WIfdtUjSdOvEl1cK6pI6omDc0p4mwmm5M08eO(qQxqQnanfqRm5IBINGI4nxH8KALLAHesQ)iQ7W0jq)GZyXWKBsZtG6dPEPcPU83sTYsTYjv4pA4jvBhJd7HbiDPLfM0Ijv2b0kVtRNu)MECtHKAJ4Sn6sMu20rnpm9PFLj8kGqff5TulqQ)iQ7W0jq)GZyXWKBsZtG6dPUqQnwQfi1gj15OuFqL9JWELwMDSZBc7aAL3sTqcj1gj1huz)iSxPLzh78MWoGw5TulqQNGdeX)K6fkKAHRXsTYsTYsTaP2iP2iP(JOUdtNCbYNHdl(Yy8ekPKMNa1hs9csD(gl1cKAueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxbPwzPwiHKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQlKAJLALLALLAbsnkI1sAeNXHflgMCt2HPl1cK6j4ar8pPEHcP2a0uaTYeqepPoDImXtWbS4Fjv4pA4jvBhJd7HbiDPLZP0Ijv2b0kVtRNu)MECtHKAJ4Sn6sMSPJNkwPo05H)yobFt4vaHkkYBPwGu)ru3HPtqrSw8MoEQyL6qNh(J5e8nPzyNNulqQrrSwYMoEQyL6qNh(J5e8n22X4i7W0LAbsTrsnkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPl1kl1cK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaP2iPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRm5IBINGI4pd6sEi1cKAJKAJK6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMoPrCghwSyyYnP5jq9HuVuHux(BPwGu)ru3HPtG(bNXIHj3KMNa1hs9csTbOPaALjxCt8eueV5kKNuRSulKqsTrsDok1huz)inIZ4WIfdtUjSdOvEl1cK6pI6omDc0p4mwmm5M08eO(qQxqQnanfqRm5IBINGI4nxH8KALLAHesQ)iQ7W0jq)GZyXWKBsZtG6dPEPcPU83sTYsTYjv4pA4jvBhJdnQx6sll8slMuzhqR8oTEs9B6XnfsQnIZ2OlzYMoEQyL6qNh(J5e8nHxbeQOiVLAbs9hrDhMobfXAXB64PIvQdDE4pMtW3KMHDEsTaPgfXAjB64PIvQdDE4pMtW3ylTzYomDPwGul2SbC5Vj5tSDmo0OEjv4pA4jvlTzmAfgx6sllSPftQSdOvENwpP(n94Mcj1pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRm5IBINGI4pd6sEi1cK6pI6omDc0p4mwmm5M08eO(qQxQqQl)Dsf(JgEsDs7o6boS4l6j7x6slVstlMuzhqR8oTEs9B6XnfsQFe1Dy6eOFWzSyyYnP5jq9Huxi1gl1cKAJK6CuQpOY(ryVslZo25nHDaTYBPwiHKAJK6dQSFe2R0YSJDEtyhqR8wQfi1tWbI4Fs9cfsTW1yPwzPwzPwGuBKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPEbP2a0uaTYeqepbfXBUc5j1cKAueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxbPwzPwiHKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQlKAJLALLALLAbsnkI1sAeNXHflgMCt2HPl1cK6j4ar8pPEHcP2a0uaTYeqepPoDImXtWbS4Fjv4pA4j1jT7Oh4WIVONSFPlTSWnTysLDaTY706j1VPh3uiP(ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjxCt8eue)zqxYdPwGu)ru3HPtG(bNXIHj3KMNa1hs9sfsD5VtQWF0WtQBgUm0ODoDPLf(PftQSdOvENwpP(n94Mcj1pI6omDc0p4mwmm5M08eO(qQlKAJLAbsTrsDok1huz)iSxPLzh78MWoGw5TulKqsTrs9bv2pc7vAz2XoVjSdOvEl1cK6j4ar8pPEHcPw4ASuRSuRSulqQnsQnsQ)iQ7W0jxG8z4WIVmgpHskP5jq9HuVGuNVXsTaPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4vqQvwQfsiP2iP(JOUdtNCbYNHdl(Yy8ekPKMNa1hsDHuBSulqQrrSwc0p4m(ZGUKjJdEfK6cP2yPwzPwzPwGuJIyTKgXzCyXIHj3KDy6sTaPEcoqe)tQxOqQnanfqRmbeXtQtNit8eCal(xsf(JgEsDZWLHgTZPlT8kkTysLDaTY706j1VPh3uiP(ru3HPtUa5ZWHfFzmEcLusZtG6dPEbP2a0uaTYKEGNGI4nxH8KAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvM0d8eueV5kKNulqQnsQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsD5VLAHesQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9csTbOPaALj9apbfXBUc5j1cjKuNJs9bv2psJ4moSyXWKBc7aAL3sTYsTaPgfXAjq)GZ4pd6sMmo4vqQxqQfgPwGuVzueRLCbYNHdl(Yy8ekPKDy6jv4pA4j1g2uWp8qeAfsxA58noTysLDaTY706j1VPh3uiP(ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjxCt8eue)zqxYdPwGu)ru3HPtG(bNXIHj3KMNa1hs9sfsD5VtQWF0WtQnSPGF4Hi0kKU0Y5NFAXKk7aAL3P1tQFtpUPqs9JOUdtNa9doJfdtUjnpbQpK6cP2yPwGuBKuBKuNJs9bv2pc7vAz2XoVjSdOvEl1cjKuBKuFqL9JWELwMDSZBc7aAL3sTaPEcoqe)tQxOqQfUgl1kl1kl1cKAJKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1li1gGMcOvMaI4jOiEZvipPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8ki1kl1cjKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcsDHuBSuRSuRSulqQrrSwsJ4moSyXWKBYomDPwGupbhiI)j1lui1gGMcOvMaI4j1PtKjEcoGf)tQvoPc)rdpP2WMc(HhIqRq6slNVWKwmPYoGw5DA9K630JBkKu)iQ7W0jq)GZyXWKBsZtG6dPEjPwynwQfi18yW(Zed0bnCCyXICB5)OHtMup6Kk8hn8K6fiFgoS4lJXtOKMU0Y5NtPftQSdOvENwpP(n94McjvueRLa9doJ)mOlzY4GxbPEPcP2a0uaTYKlUjEckI)mOl5HulqQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsD5VLAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvMCXnXtqr8MRqEsTaP(ddSd(ruiVMcUulqQ)iQ7W0jnSPGF4Hi0kqAEcuFi1lvi1c)Kk8hn8K6fiFgoS4lJXtOKMU0Y5l8slMuzhqR8oTEs9B6XnfsQOiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjxCt8eue)zqxYdPwGuFqL9J0ioJdlwmm5MWoGw5TulqQ)iQ7W0jnIZ4WIfdtUjnpbQpK6LkK6YFl1cK6pI6omDc0p4mwmm5M08eO(qQxqQnanfqRm5IBINGI4nxH8KAbsDok1FyGDWpIc51uWtQWF0WtQxG8z4WIVmgpHsA6slNVWMwmPYoGw5DA9K630JBkKurrSwc0p4m(ZGUKjJdEfK6LkKAdqtb0ktU4M4jOi(ZGUKhsTaPohL6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvMCXnXtqr8MRqEjv4pA4j1lq(mCyXxgJNqjnDPLZFLMwmPYoGw5DA9K630JBkKurrSwc0p4m(ZGUKjJdEfK6LkKAdqtb0ktU4M4jOi(ZGUKhsTaP(JOUdtNa9doJfdtUjnpbQpK6LkK6YFNuH)OHNuVa5ZWHfFzmEcL00LwoFHBAXKk7aAL3P1tQFtpUPqs1iPohL6dQSFe2R0YSJDEtyhqR8wQfsiP2iP(Gk7hH9kTm7yN3e2b0kVLAbs9eCGi(NuVqHulCnwQvwQvwQfi1Fe1Dy6Klq(mCyXxgJNqjL08eO(qQxqQnanfqRmbeXtqr8MRqEsTaPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4vqQfi1OiwlPrCghwSyyYnzhMUulqQNGdeX)K6fkKAdqtb0ktar8K60jYepbhWI)LuH)OHNuH(bNXIHj3PlTC(c)0Ijv2b0kVtRNu)MECtHKkkI1sAeNXHflgMCt2HPl1cK6pI6omDYfiFgoS4lJXtOKsAEcuFi1li1gGMcOvM0HiEckI3CfYtQfi1Oiwlb6hCg)zqxYKXbVcsDHuJIyTeOFWz8NbDjtMGI4XbVcsTaP2iP(JOUdtNa9doJfdtUjnpbQpK6fK68fwPwiHK6nJIyTKlq(mCyXxgJNqjLGik1kNuH)OHNuBeNXHflgMCNU0Y5VIslMuzhqR8oTEs9B6XnfsQOiwlb6hCg)zqxYKXbVcsDHuBSulqQ)Wa7GFefYRPGNuH)OHNufBEW(Z4WINuFNU0YcJXPftQSdOvENwpP(n94Mcj1nJIyTKlq(mCyXxgJNqjLGik1cK6CuQ)Wa7GFefYRPGNuH)OHNufBEW(Z4WINuFNU0Lu74GJgEAX0Y5NwmPYoGw5DA9K630JBkKu)iQ7W0jxG8z4WIVmgpHskP5jq9Huxi1gl1cKAJKAueRLa9doJ)mOlzY4GxbPEbP2a0uaTYKlUjEckI)mOl5HulqQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsD5VLAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvMCXnXtqr8MRqEsTaP(ddSd(ruiVMcUulqQ)iQ7W0jnSPGF4Hi0kqAEcuFi1lvi1cFPw5Kk8hn8Kk0p4mgf6gk50LwwyslMuzhqR8oTEs9B6XnfsQFe1Dy6Klq(mCyXxgJNqjL08eO(qQlKAJLAbsTrsnkI1sG(bNXFg0LmzCWRGuVGuBaAkGwzYf3epbfXFg0L8qQfi1huz)inIZ4WIfdtUjSdOvEl1cK6pI6omDsJ4moSyXWKBsZtG6dPEPcPU83sTaP(JOUdtNa9doJfdtUjnpbQpK6fKAdqtb0ktU4M4jOiEZvipPwGuNJs9hgyh8JOqEnfCPw5Kk8hn8Kk0p4mgf6gk50LwoNslMuzhqR8oTEs9B6XnfsQFe1Dy6Klq(mCyXxgJNqjL08eO(qQlKAJLAbsTrsnkI1sG(bNXFg0LmzCWRGuVGuBaAkGwzYf3epbfXFg0L8qQfi15OuFqL9J0ioJdlwmm5MWoGw5TulqQ)iQ7W0jq)GZyXWKBsZtG6dPEbP2a0uaTYKlUjEckI3CfYtQvoPc)rdpPc9doJrHUHsoDPLfEPftQSdOvENwpP(n94Mcj1pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaP2iPgfXAjq)GZ4pd6sMmo4vqQxqQnanfqRm5IBINGI4pd6sEi1cK6pI6omDc0p4mwmm5M08eO(qQxQqQl)TuRCsf(JgEsf6hCgJcDdLC6sllSPftQSdOvENwpP(n94Mcj1nJIyTKg2uWp8qeAfWgqQo3akTsV8iJdEfK6cPEZOiwlPHnf8dpeHwbSbKQZnGsR0lpYeuepo4vqQfi1gj1Oiwlb6hCglgMCt2HPl1cjKuJIyTeOFWzSyyYnP5jq9HuVuHux(BPwzPwGuBKuJIyTKgXzCyXIHj3KDy6sTqcj1OiwlPrCghwSyyYnP5jq9HuVuHux(BPw5Kk8hn8Kk0p4mgf6gk50LwELMwmPYoGw5DA9K630JBkKu3XrAytb)WdrOvG08eO(qQxqQfwPwiHK6nJIyTKg2uWp8qeAfWgqQo3akTsV8iJdEfK6fKAJtQWF0WtQq)GZy0kmU0Lww4MwmPYoGw5DA9K630JBkKurrSwIyZd2Fghw8K6BcIOulqQ3mkI1sUa5ZWHfFzmEcLucIOulqQ3mkI1sUa5ZWHfFzmEcLusZtG6dPEPcPg(Jgob6hCgJwHXryf5h5y8rNCsf(JgEsf6hCgJwHXLU0Yc)0Ijv2b0kVtRNuH)OHNuH(bNXt6yqR8iP(za1tQ5Nu)MECtHK6MrrSwYfiFgoS4lJXtOKsqeLAbs9bv2pc0p4mM)SGWoGw5TulqQrrSwYMHldnANj7W0LAbsTrs9MrrSwYfiFgoS4lJXtOKsAEcuFi1li1WF0Wjq)GZ4jDmOvEqyf5h5y8rNSulKqs9hrDhMorS5b7pJdlEs9nP5jq9HuVGuBSulKqs9hgyh8JOqEnfCPwzPwGuBKuNJsnKZXn9yc0p4mwezo5k1ljSdOvEl1cjKuJIyTKVYq)W4OEj(Za35kzhMUuRC6slVIslMuzhqR8oTEs9B6XnfsQOiwl5Rm0pmoQxsAg(tQfi1OiwlHvue8nVXIXX(rHkbrmPc)rdpPc9doJN0XGw5r6slNVXPftQSdOvENwpPc)rdpPc9doJN0XGw5rs9ZaQNuZpP(n94McjvueRL8vg6hgh1ljnd)j1cKAJKAueRLa9doJfdtUjiIsTqcj1OiwlPrCghwSyyYnbruQfsiPEZOiwl5cKpdhw8LX4jusjnpbQpK6fKA4pA4eOFWz8Kog0kpiSI8JCm(OtwQvoDPLZp)0Ijv2b0kVtRNuH)OHNuH(bNXt6yqR8iP(za1tQ5Nu)MECtHKkkI1s(kd9dJJ6LKMH)KAbsnkI1s(kd9dJJ6LKXbVcsDHuJIyTKVYq)W4OEjzckIhh8kKU0Y5lmPftQSdOvENwpPc)rdpPc9doJN0XGw5rs9ZaQNuZpP(n94McjvueRL8vg6hgh1ljnd)j1cKAueRL8vg6hgh1ljnpbQpK6LkKAJKAJKAueRL8vg6hgh1ljJdEfK6v8sn8hnCc0p4mEshdALhewr(rogF0jl1kl1Rj1L)wQvoDPLZpNslMuzhqR8oTEs9B6XnfsQgj1nBBEKbOvwQfsiPohL6J(kq9sPwzPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8ki1cKAueRLa9doJfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPNuH)OHNuD(Y4gF8uKhx6slNVWlTysLDaTY706j1VPh3uiPIIyTeOFWz8NbDjtgh8ki1lvi1gGMcOvMCXnXtqr8NbDjpsQWF0WtQq)GZ4OrtxA58f20Ijv2b0kVtRNu)MECtHK6eCGi(NuVuHuVIewPwGuJIyTeOFWzSyyYnzhMUulqQrrSwsJ4moSyXWKBYomDPwGuVzueRLCbYNHdl(Yy8ekPKDy6jv4pA4j1bIi3EyasxA58xPPftQSdOvENwpP(n94McjvueRLa9doJfdtUj7W0LAbsnkI1sAeNXHflgMCt2HPl1cK6nJIyTKlq(mCyXxgJNqjLSdtxQfi1Fe1Dy6e2q8WrdN08eO(qQxqQnwQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuBSulqQ)iQ7W0jxG8z4WIVmgpHskP5jq9HuVGuBSulqQnsQZrP(Gk7hPrCghwSyyYnHDaTYBPwiHKAJK6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMoPrCghwSyyYnP5jq9HuVGuBSuRSuRCsf(JgEsDKrTh1lXIHj3PlTC(c30Ijv2b0kVtRNu)MECtHKkkI1sAKkJdl(YAMheerPwGuJIyTeOFWz8NbDjtgh8ki1li15usf(JgEsf6hCgJwHXLU0Y5l8tlMuzhqR8oTEs9B6XnfsQtWbI4Fs9ssTbOPaALjOq3qjJNGdyX)KAbs9hrDhMoHnepC0WjnpbQpK6fKAJLAbsnkI1sG(bNXIHj3KDy6sTaPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4vqQfi18yW(Zed0bnCCyXICB5)OHtMup6Kk8hn8Kk0p4mgf6gk50Lwo)vuAXKk7aAL3P1tQFtpUPqs9JOUdtNCbYNHdl(Yy8ekPKMNa1hsDHuBSulqQnsQ)iQ7W0jnIZ4WIfdtUjnpbQpK6cP2yPwiHK6pI6omDc0p4mwmm5M08eO(qQlKAJLALLAbsnkI1sG(bNXFg0LmzCWRGuxi1Oiwlb6hCg)zqxYKjOiECWRqsf(JgEsf6hCgJcDdLC6sllmgNwmPYoGw5DA9K630JBkKuNGdeX)K6LkKAdqtb0ktqHUHsgpbhWI)j1cKAueRLa9doJfdtUj7W0LAbsnkI1sAeNXHflgMCt2HPl1cK6nJIyTKlq(mCyXxgJNqjLSdtxQfi1Oiwlb6hCg)zqxYKXbVcsDHuJIyTeOFWz8NbDjtMGI4XbVcsTaP(JOUdtNWgIhoA4KMNa1hs9csTXjv4pA4jvOFWzmk0nuYPlTSWKFAXKk7aAL3P1tQFtpUPqsffXAjq)GZyXWKBYomDPwGuJIyTKgXzCyXIHj3KDy6sTaPEZOiwl5cKpdhw8LX4jusj7W0LAbsnkI1sG(bNXFg0LmzCWRGuxi1Oiwlb6hCg)zqxYKjOiECWRGulqQpOY(rG(bNXrJsyhqR8wQfi1Fe1Dy6eOFWzC0OKMNa1hs9sfsD5VLAbs9eCGi(NuVuHuVImwQfi1Fe1Dy6e2q8WrdN08eO(qQxqQnoPc)rdpPc9doJrHUHsoDPLfgHjTysLDaTY706j1VPh3uiPIIyTeOFWzSyyYnbruQfi1Oiwlb6hCglgMCtAEcuFi1lvi1L)wQfi1Oiwlb6hCg)zqxYKXbVcsDHuJIyTeOFWz8NbDjtMGI4XbVcjv4pA4jvOFWzmk0nuYPlTSWKtPftQSdOvENwpP(n94McjvueRL0ioJdlwmm5MGik1cKAueRL0ioJdlwmm5M08eO(qQxQqQl)TulqQrrSwc0p4m(ZGUKjJdEfK6cPgfXAjq)GZ4pd6sMmbfXJdEfsQWF0WtQq)GZyuOBOKtxAzHr4LwmPYoGw5DA9K630JBkKurrSwc0p4mwmm5MSdtxQfi1OiwlPrCghwSyyYnzhMUulqQ3mkI1sUa5ZWHfFzmEcLucIOulqQ3mkI1sUa5ZWHfFzmEcLusZtG6dPEPcPU83sTaPgfXAjq)GZ4pd6sMmo4vqQlKAueRLa9doJ)mOlzYeuepo4viPc)rdpPc9doJrHUHsoDPLfgHnTysf(JgEsf6hCgJwHXLuzhqR8oTE6sllmR00IjvQFC3iIhMAtQtWbI4Flui8f2Kk1pUBeXdtNtEtHJtQ5NuH)OHNuzdXdhn8Kk7aAL3P1txAzHr4MwmPc)rdpPc9doJrHUHsoPYoGw5DA90Lwwye(PftQSdOvENwpPgIj1bFjv4pA4jvdqtb0kNunaveoPMFs9B6XnfsQOiwlb6hCg)zqxYKXbVcsDHuJIyTeOFWz8NbDjtMGI4XbVcsTaPohLAueRL0ivghw8L1mpiiIsTaP2slZoCZtG6dPEPcP2iP2iPEcoi1Rk1WF0Wjq)GZy0kmoYhJtQvwQxXl1WF0Wjq)GZy0kmocRi)ihJp6KLALtQgGg7WKtQwQdvmks7PlDjvyIhIWmTyA58tlMuzhqR8oTEs9B6XnfsQtWbI4Fs9sfsTbOPaALjWepeHjMneyX)KAbsTrs9hrDhMo5cKpdhw8LX4jusjnpbQpK6LkKA4pA4e2q8WrdNWkYpYX4JozPwiHK6pI6omDc0p4mwmm5M08eO(qQxQqQH)OHtydXdhnCcRi)ihJp6KLAHesQnsQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsn8hnCcBiE4OHtyf5h5y8rNSuRSuRSulqQrrSwsJ4moSyXWKBYomDPwGuJIyTeOFWzSyyYnzhMUulqQ3mkI1sUa5ZWHfFzmEcLuYom9Kk1pUBeXdtTj1j4ar8VfkwrcBsL6h3nI4HPZjVPWXj18tQWF0WtQSH4HJgE6sllmPftQSdOvENwpP(n94McjvueRL0ioJdlwmm5MSdtxQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuBCsf(JgEsTrCghwSyyYD6slNtPftQSdOvENwpP(n94McjvJK6pI6omDc0p4mwmm5M08eO(qQlKAJLAbsnkI1sAeNXHflgMCt2HPl1kl1cjKul2SbC5Vj5tAeNXHflgMCNuH)OHNuVa5ZWHfFzmEcL00Lww4LwmPYoGw5DA9K630JBkKu)iQ7W0jq)GZyXWKBsZtG6dPEjPwynwQfi1OiwlPrCghwSyyYnzhMUulqQ5XG9NjgOdA44WIf52Y)rdNWoGw5Dsf(JgEs9cKpdhw8LX4justxAzHnTysLDaTY706j1VPh3uiPIIyTKgXzCyXIHj3KDy6sTaP(JOUdtNCbYNHdl(Yy8ekPKMNa1hs9csTbOPaALjGiEckI3CfYlPc)rdpPc9doJfdtUtxA5vAAXKk7aAL3P1tQFtpUPqsffXAjq)GZyXWKBcIOulqQrrSwc0p4mwmm5M08eO(qQxQqQH)OHtG(bNXt6yqR8GWkYpYX4JozPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8kKuH)OHNuH(bNXOq3qjNU0Yc30Ijv2b0kVtRNu)MECtHKkkI1sG(bNXFg0LmzCWRGuVKuJIyTeOFWz8NbDjtMGI4XbVcsTaPgfXAjnIZ4WIfdtUj7W0LAbsnkI1sG(bNXIHj3KDy6sTaPEZOiwl5cKpdhw8LX4jusj7W0tQWF0WtQq)GZ4OrtxAzHFAXKk7aAL3P1tQFtpUPqsffXAjnIZ4WIfdtUj7W0LAbsnkI1sG(bNXIHj3KDy6sTaPEZOiwl5cKpdhw8LX4jusj7W0LAbsnkI1sG(bNXFg0LmzCWRGuxi1Oiwlb6hCg)zqxYKjOiECWRqsf(JgEsf6hCgJcDdLC6slVIslMuzhqR8oTEs9ZaQNuZpPYqxZd)za1XuBsffXAjFLH(HXr9s8NbUZvYomDbgHIyTeOFWzSyyYnbruiHqrSwsJ4moSyXWKBcIOqc9ru3HPtydXdhnCsZWopLtQFtpUPqsffXAjFLH(HXr9ssZWFjv4pA4jvOFWz8Kog0kpsxA58noTysLDaTY706j1pdOEsn)KkdDnp8NbuhtTjvueRL8vg6hgh1lXFg4oxj7W0fyekI1sG(bNXIHj3eerHecfXAjnIZ4WIfdtUjiIcj0hrDhMoHnepC0Wjnd78uoP(n94Mcj1CuQHCoUPhtG(bNXIiZjxPEjHDaTYBPwiHKAueRL8vg6hgh1lXFg4oxj7W0tQWF0WtQq)GZ4jDmOvEKU0Y5NFAXKk7aAL3P1tQFtpUPqsffXAjnIZ4WIfdtUj7W0LAbsnkI1sG(bNXIHj3KDy6sTaPEZOiwl5cKpdhw8LX4jusj7W0tQWF0WtQSH4HJgE6slNVWKwmPYoGw5DA9K630JBkKurrSwc0p4m(ZGUKjJdEfK6LKAueRLa9doJ)mOlzYeuepo4viPc)rdpPc9doJJgnDPLZpNslMuH)OHNuH(bNXOq3qjNuzhqR8oTE6slNVWlTysf(JgEsf6hCgJwHXLuzhqR8oTE6sxsDgg4j7xAX0Y5NwmPYoGw5DA9K630JBkKuNHbEY(r20Xb(Zs9cfsD(gNuH)OHNurRuxH0LwwyslMuH)OHNufBEW(Z4WINuFNuzhqR8oTE6slNtPftQSdOvENwpP(n94Mcj1zyGNSFKnDCG)SuVKuNVXjv4pA4jvOFWz8Kog0kpsxAzHxAXKk8hn8Kk0p4moA0Kk7aAL3P1txAzHnTysf(JgEs1sBgJwHXLuzhqR8oTE6sxsvS5pMOWLwmTC(PftQSdOvENwpPgIj1Mh8LuH)OHNunanfqRCs1a0yhMCsvSzrKAfZgIK6MTas9sQgNU0YctAXKk7aAL3P1tQHysDWxsf(JgEs1a0uaTYjvdqfHtQ5Nu)MECtHKQbOPaALjInlIuRy2qi1fsTXsTaPUrC2gDjtguXSWXJl6jHxbeQOiVLAbsn8h1aJzNNuEi1li1cts1a0yhMCsvSzrKAfZgI0LwoNslMuzhqR8oTEsnetQd(sQWF0WtQgGMcOvoPAaQiCsn)K630JBkKunanfqRmrSzrKAfZgcPUqQnwQfi1nIZ2OlzYGkMfoECrpj8kGqff5TulqQ)Wa7GFeN)oQrVLAbsn8h1aJzNNuEi1li15Nunan2HjNufBwePwXSHiDPLfEPftQSdOvENwpPgIj1bFjv4pA4jvdqtb0kNunaveoPMFs9B6XnfsQgGMcOvMi2SisTIzdHuxi1gl1cK6gXzB0LmzqfZchpUONeEfqOII8wQfi1FyGDWpItlZoSf4KQbOXom5KQyZIi1kMnePlTSWMwmPYoGw5DA9KAiMuBEWxsf(JgEs1a0uaTYjvdqJDyYj1mWaJdr25DsDZwaPEjvJtxA5vAAXKk7aAL3P1tQHysDWxsf(JgEs1a0uaTYjvdqfHtQ5Nu)MECtHKQbOPaALjzGbghISZBPUqQnwQfi1WFudmMDEs5HuVGulmjvdqJDyYj1mWaJdr25D6sllCtlMuzhqR8oTEsnetQd(sQWF0WtQgGMcOvoPAaQiCsn)K630JBkKunanfqRmjdmW4qKDEl1fsTXsTaP2a0uaTYeXMfrQvmBiK6cPo)KQbOXom5KAgyGXHi78oDPLf(PftQSdOvENwpPgIj1bFjv4pA4jvdqtb0kNunaveoPACs1a0yhMCs1sDOIrrApDPLxrPftQSdOvENwpPgIj1Mh8LuH)OHNunanfqRCs1a0yhMCsTh4jOiEZviVK6MTas9sQcB6slNVXPftQSdOvENwpPgIj1Mh8LuH)OHNunanfqRCs1a0yhMCsfeXtqr8MRqEj1nBbK6LuZ340Lwo)8tlMuzhqR8oTEsnetQnp4lPc)rdpPAaAkGw5KQbOXom5KAhI4jOiEZviVK6MTas9sQcJXPlTC(ctAXKk7aAL3P1tQHysT5bFjv4pA4jvdqtb0kNunan2HjNuV4M4jOiEZviVK6MTas9sQcB6slNFoLwmPYoGw5DA9KAiMuh8LuH)OHNunanfqRCs1aur4KAoLu)MECtHKQbOPaALjxCt8eueV5kKNuxi1cRulqQBeNTrxYKnD8uXk1Hop8hZj4BcVciurrENunan2HjNuV4M4jOiEZviV0LwoFHxAXKk7aAL3P1tQHysDWxsf(JgEs1a0uaTYjvdqfHtQ5lSj1VPh3uiPAaAkGwzYf3epbfXBUc5j1fsTWk1cK6pmWo4hXPLzh2cCs1a0yhMCs9IBINGI4nxH8sxA58f20Ijv2b0kVtRNudXK6GVKk8hn8KQbOPaALtQgGkcNuZxytQFtpUPqs1a0uaTYKlUjEckI3CfYtQlKAHvQfi1F4Be6rG(bNXIDSPL5ryhqR8wQfi1WFudmMDEs5HuVKuNtjvdqJDyYj1lUjEckI3CfYlDPLZFLMwmPYoGw5DA9KAiMuh8LuH)OHNunanfqRCs1aur4KAozCs9B6XnfsQgGMcOvMCXnXtqr8MRqEsDHulSsTaPMhd2FMyGoOHJdlwKBl)hnCYK6rNunan2HjNuV4M4jOiEZviV0LwoFHBAXKk7aAL3P1tQHysT5bFjv4pA4jvdqtb0kNunan2HjNurHUHsgpbhWI)Lu3SfqQxsv4AC6slNVWpTysLDaTY706j1qmPo4lPc)rdpPAaAkGw5KQbOIWjvHNXj1VPh3uiPAaAkGwzck0nuY4j4aw8pPUqQfUgl1cK6pmWo4hXPLzh2cCs1a0yhMCsff6gkz8eCal(x6slN)kkTysLDaTY706j1qmP28GVKk8hn8KQbOPaALtQgGg7WKtQGiEsD6ezINGdyX)sQB2ci1lPMtgNU0YcJXPftQSdOvENwpPgIj1bFjv4pA4jvdqtb0kNunaveoPkSgNu)MECtHKQbOPaALjGiEsD6ezINGdyX)K6cPoNmwQfi1nIZ2OlzYMoEQyL6qNh(J5e8nHxbeQOiVtQgGg7WKtQGiEsD6ezINGdyX)sxAzHj)0Ijv2b0kVtRNudXK6GVKk8hn8KQbOPaALtQgGkcNufwJtQFtpUPqs1a0uaTYeqepPoDImXtWbS4FsDHuNtgl1cK6gXzB0LmPSPJAEy6t)kt4vaHkkY7KQbOXom5KkiINuNorM4j4aw8V0LwwyeM0Ijv2b0kVtRNudXKAZd(sQWF0WtQgGMcOvoPAaASdtoPEXnXtqr8NbDjpsQB2ci1lPkmPlTSWKtPftQSdOvENwpPgIj1Mh8LuH)OHNunanfqRCs1a0yhMCsfcgFXnXtqr8NbDjpsQB2ci1lPkmPlTSWi8slMuzhqR8oTEsnetQd(sQWF0WtQgGMcOvoPAaQiCsn)K630JBkKunanfqRmjdmW4qKDEl1fsTXsTaPEW3r9YbbM4HimL6cPo)KQbOXom5KAgyGXHi78oDPLfgHnTysLDaTY706j1qmP28GVKk8hn8KQbOPaALtQgGg7WKtQWepeHjMneyX)sQB2ci1lPMVWMU0YcZknTysLDaTY706PlTSWiCtlMuzhqR8oTE6sllmc)0Ijv2b0kVtRNU0YcZkkTysf(JgEsDGmNHJH(bNXwysRuOtQSdOvENwpDPLZjJtlMuH)OHNuH(bNXu)4AL)lPYoGw5DA90LwoNYpTysf(JgEs9dx4eKMXtWbCjptQSdOvENwpDPLZjHjTysLDaTY706PlTCoLtPftQWF0WtQtA3rJPtOKtQSdOvENwpDPLZjHxAXKk7aAL3P1tQFtpUPqs1a0uaTYeXMfrQvmBiK6LkKAJtQWF0WtQ2oghAuV0LwoNe20Ijv2b0kVtRNu)MECtHKQbOPaALjInlIuRy2qi1li1gNuH)OHNuzdXdhn80LUKkeCAX0Y5NwmPYoGw5DA9K630JBkKuBeNTrxYKnD8uXk1Hop8hZj4BcVciurrEl1cK6pI6omDckI1I30XtfRuh68WFmNGVjnd78KAbsnkI1s20XtfRuh68WFmNGVX2oghzhMUulqQnsQrrSwc0p4mwmm5MSdtxQfi1OiwlPrCghwSyyYnzhMUulqQ3mkI1sUa5ZWHfFzmEcLuYomDPwzPwGu)ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1gj1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjqW4lUjEckI)mOl5HulqQnsQnsQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsD5VLAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvMCXnXtqr8MRqEsTYsTqcj1gj15OuFqL9J0ioJdlwmm5MWoGw5TulqQ)iQ7W0jq)GZyXWKBsZtG6dPEbP2a0uaTYKlUjEckI3CfYtQvwQfsiP(JOUdtNa9doJfdtUjnpbQpK6LkK6YFl1kl1kNuH)OHNuTDmo0OEPlTSWKwmPYoGw5DA9K630JBkKunsQBeNTrxYKnD8uXk1Hop8hZj4BcVciurrEl1cK6pI6omDckI1I30XtfRuh68WFmNGVjnd78KAbsnkI1s20XtfRuh68WFmNGVXwAZKDy6sTaPwSzd4YFtYNy7yCOr9KALLAHesQnsQBeNTrxYKnD8uXk1Hop8hZj4BcVciurrEl1cK6JozPUqQnwQvoPc)rdpPAPnJrRW4sxA5CkTysLDaTY706j1VPh3uiP2ioBJUKjLnDuZdtF6xzcVciurrEl1cK6pI6omDc0p4mwmm5M08eO(qQxqQZjJLAbs9hrDhMo5cKpdhw8LX4jusjnpbQpK6cP2yPwGuBKuJIyTeOFWz8NbDjtgh8ki1lvi1gGMcOvMabJV4M4jOi(ZGUKhsTaP2iP2iP(Gk7hPrCghwSyyYnHDaTYBPwGu)ru3HPtAeNXHflgMCtAEcuFi1lvi1L)wQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuBaAkGwzYf3epbfXBUc5j1kl1cjKuBKuNJs9bv2psJ4moSyXWKBc7aAL3sTaP(JOUdtNa9doJfdtUjnpbQpK6fKAdqtb0ktU4M4jOiEZvipPwzPwiHK6pI6omDc0p4mwmm5M08eO(qQxQqQl)TuRSuRCsf(JgEs12X4WEyasxAzHxAXKk7aAL3P1tQFtpUPqsTrC2gDjtkB6OMhM(0VYeEfqOII8wQfi1Fe1Dy6eOFWzSyyYnP5jq9Huxi1gl1cKAJKAJKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1li1gGMcOvMaI4jOiEZvipPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8ki1kl1cjKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjqW4lUjEckI)mOl5HuRSuRSulqQrrSwsJ4moSyXWKBYomDPw5Kk8hn8KQTJXH9WaKU0YcBAXKk7aAL3P1tQFtpUPqsTrC2gDjtguXSWXJl6jHxbeQOiVLAbsTyZgWL)MKpHnepC0WtQWF0WtQxG8z4WIVmgpHsA6slVstlMuzhqR8oTEs9B6XnfsQnIZ2OlzYGkMfoECrpj8kGqff5TulqQnsQfB2aU83K8jSH4HJgUulKqsTyZgWL)MKp5cKpdhw8LX4jusLALtQWF0WtQq)GZyXWK70Lww4MwmPYoGw5DA9K630JBkKup6KL6fK6CYyPwGu3ioBJUKjdQyw44Xf9KWRacvuK3sTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRmbcgFXnXtqr8NbDjpKAbs9hrDhMo5cKpdhw8LX4jusjnpbQpK6cP2yPwGu)ru3HPtG(bNXIHj3KMNa1hs9sfsD5VtQWF0WtQSH4HJgE6sll8tlMuzhqR8oTEsf(JgEsLnepC0WtQu)4Urepm1MurrSwYGkMfoECrpjJdEfkqrSwYGkMfoECrpjtqr84GxHKk1pUBeXdtNtEtHJtQ5Nu)MECtHK6rNSuVGuNtgl1cK6gXzB0LmzqfZchpUONeEfqOII8wQfi1Fe1Dy6eOFWzSyyYnP5jq9Huxi1gl1cKAJKAJKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1li1gGMcOvMaI4jOiEZvipPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8ki1kl1cjKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjqW4lUjEckI)mOl5HuRSuRSulqQrrSwsJ4moSyXWKBYomDPw50LwEfLwmPYoGw5DA9K630JBkKunsQ)iQ7W0jq)GZyXWKBsZtG6dPEbPw4jSsTqcj1Fe1Dy6eOFWzSyyYnP5jq9HuVuHuNtsTYsTaP(JOUdtNCbYNHdl(Yy8ekPKMNa1hsDHuBSulqQnsQrrSwc0p4m(ZGUKjJdEfK6LkKAdqtb0ktGGXxCt8eue)zqxYdPwGuBKuBKuFqL9J0ioJdlwmm5MWoGw5TulqQ)iQ7W0jnIZ4WIfdtUjnpbQpK6LkK6YFl1cK6pI6omDc0p4mwmm5M08eO(qQxqQfwPwzPwiHKAJK6CuQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGulSsTYsTqcj1Fe1Dy6eOFWzSyyYnP5jq9HuVuHux(BPwzPw5Kk8hn8K6K2D0dCyXx0t2V0LwoFJtlMuzhqR8oTEs9B6XnfsQFe1Dy6Klq(mCyXxgJNqjL08eO(qQxqQnanfqRmPh4jOiEZvipPwGu)ru3HPtG(bNXIHj3KMNa1hs9csTbOPaALj9apbfXBUc5j1cKAJK6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMoPrCghwSyyYnP5jq9HuVuHux(BPwiHK6dQSFKgXzCyXIHj3e2b0kVLAbs9hrDhMoPrCghwSyyYnP5jq9HuVGuBaAkGwzspWtqr8MRqEsTqcj15OuFqL9J0ioJdlwmm5MWoGw5TuRSulqQrrSwc0p4m(ZGUKjJdEfK6LkKAdqtb0ktGGXxCt8eue)zqxYdPwGuVzueRLCbYNHdl(Yy8ekPKDy6jv4pA4j1g2uWp8qeAfsxA58ZpTysLDaTY706j1VPh3uiP(ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1gj1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjqW4lUjEckI)mOl5HulqQnsQnsQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9sfsD5VLAbs9hrDhMob6hCglgMCtAEcuFi1li1gGMcOvMCXnXtqr8MRqEsTYsTqcj1gj15OuFqL9J0ioJdlwmm5MWoGw5TulqQ)iQ7W0jq)GZyXWKBsZtG6dPEbP2a0uaTYKlUjEckI3CfYtQvwQfsiP(JOUdtNa9doJfdtUjnpbQpK6LkK6YFl1kl1kNuH)OHNuBytb)WdrOviDPLZxyslMuzhqR8oTEs9B6XnfsQFe1Dy6eOFWzSyyYnP5jq9Huxi1gl1cKAJKAJKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1li1gGMcOvMaI4jOiEZvipPwGuJIyTeOFWz8NbDjtgh8ki1fsnkI1sG(bNXFg0LmzckIhh8ki1kl1cjKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPUqQnwQfi1Oiwlb6hCg)zqxYKXbVcs9sfsTbOPaALjqW4lUjEckI)mOl5HuRSuRSulqQrrSwsJ4moSyXWKBYomDPw5Kk8hn8KAdBk4hEicTcPlTC(5uAXKk7aAL3P1tQFtpUPqs9JOUdtNa9doJfdtUjnpbQpK6cP2yPwGuBKuBKuBKu)ru3HPtUa5ZWHfFzmEcLusZtG6dPEbP2a0uaTYeqepbfXBUc5j1cKAueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxbPwzPwiHKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRmbcgFXnXtqr8NbDjpKALLALLAbsnkI1sAeNXHflgMCt2HPl1kNuH)OHNu3mCzOr7C6slNVWlTysLDaTY706j1VPh3uiPIIyTeOFWz8NbDjtgh8ki1lvi1gGMcOvMabJV4M4jOi(ZGUKhsTaP2iP2iP(Gk7hPrCghwSyyYnHDaTYBPwGu)ru3HPtAeNXHflgMCtAEcuFi1lvi1L)wQfi1Fe1Dy6eOFWzSyyYnP5jq9HuVGuBaAkGwzYf3epbfXBUc5j1kl1cjKuBKuNJs9bv2psJ4moSyXWKBc7aAL3sTaP(JOUdtNa9doJfdtUjnpbQpK6fKAdqtb0ktU4M4jOiEZvipPwzPwiHK6pI6omDc0p4mwmm5M08eO(qQxQqQl)TuRCsf(JgEs9cKpdhw8LX4justxA58f20Ijv2b0kVtRNu)MECtHKQrsTrs9hrDhMo5cKpdhw8LX4jusjnpbQpK6fKAdqtb0ktar8eueV5kKNulqQrrSwc0p4m(ZGUKjJdEfK6cPgfXAjq)GZ4pd6sMmbfXJdEfKALLAHesQnsQ)iQ7W0jxG8z4WIVmgpHskP5jq9Huxi1gl1cKAueRLa9doJ)mOlzY4GxbPEPcP2a0uaTYeiy8f3epbfXFg0L8qQvwQvwQfi1OiwlPrCghwSyyYnzhMEsf(JgEsf6hCglgMCNU0Y5VstlMuzhqR8oTEs9B6XnfsQOiwlPrCghwSyyYnzhMUulqQnsQnsQ)iQ7W0jxG8z4WIVmgpHskP5jq9HuVGulmgl1cKAueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxbPwzPwiHKAJK6pI6omDYfiFgoS4lJXtOKsAEcuFi1fsTXsTaPgfXAjq)GZ4pd6sMmo4vqQxQqQnanfqRmbcgFXnXtqr8NbDjpKALLALLAbsTrs9hrDhMob6hCglgMCtAEcuFi1li15lSsTqcj1BgfXAjxG8z4WIVmgpHskbruQvoPc)rdpP2ioJdlwmm5oDPLZx4MwmPYoGw5DA9K630JBkKurrSwYMHldnANjiIsTaPEZOiwl5cKpdhw8LX4jusjiIsTaPEZOiwl5cKpdhw8LX4jusjnpbQpK6LkKAueRLi28G9NXHfpP(MmbfXJdEfK6v8sn8hnCc0p4mgTcJJWkYpYX4Jo5Kk8hn8KQyZd2Fghw8K670LwoFHFAXKk7aAL3P1tQFtpUPqsffXAjBgUm0ODMGik1cKAJKAJK6dQSFKMhHd(Ze2b0kVLAbsn8h1aJzNNuEi1lj1cpPwzPwiHKA4pQbgZopP8qQxsQfwPw5Kk8hn8Kk0p4mgTcJlDPLZFfLwmPc)rdpPoqe52ddqsLDaTY706PlTSWyCAXKk7aAL3P1tQFtpUPqsffXAjq)GZ4pd6sMmo4vqQlKAJtQWF0WtQq)GZ4OrtxAzHj)0Ijv2b0kVtRNu)MECtHKQrsDZ2MhzaALLAHesQZrP(OVcuVuQvwQfi1Oiwlb6hCg)zqxYKXbVcsDHuJIyTeOFWz8NbDjtMGI4XbVcjv4pA4jvNVmUXhpf5XLU0YcJWKwmPYoGw5DA9K630JBkKurrSwc0p4mwmm5MSdtxQfi1OiwlPrCghwSyyYnzhMUulqQ3mkI1sUa5ZWHfFzmEcLuYomDPwGu)ru3HPtG(bNXIHj3KMNa1hs9csTXsTaP(JOUdtNCbYNHdl(Yy8ekPKMNa1hs9csTXsTaP2iPohL6dQSFKgXzCyXIHj3e2b0kVLAHesQnsQpOY(rAeNXHflgMCtyhqR8wQfi1Fe1Dy6KgXzCyXIHj3KMNa1hs9csTXsTYsTYjv4pA4j1rg1EuVelgMCNU0YctoLwmPYoGw5DA9K630JBkKurrSwYxzOFyCuVK0m8NulqQBeNTrxYeOFWzm1TuNE5r4vaHkkYBPwGuFqL9JatXk1sF4OHtyhqR8wQfi1WFudmMDEs5HuVKuVIsQWF0WtQq)GZ4jDmOvEKU0YcJWlTysLDaTY706j1VPh3uiPIIyTKVYq)W4OEjPz4pPwGu3ioBJUKjq)GZyQBPo9YJWRacvuK3sTaPg(JAGXSZtkpK6LK6vAsf(JgEsf6hCgpPJbTYJ0Lwwye20Ijv2b0kVtRNu)MECtHKkkI1sG(bNXFg0LmzCWRGuVKuJIyTeOFWz8NbDjtMGI4XbVcjv4pA4jvOFWzmROyng0WtxAzHzLMwmPYoGw5DA9K630JBkKurrSwc0p4m(ZGUKjJdEfK6cPgfXAjq)GZ4pd6sMmbfXJdEfKAbsTyZgWL)MKpb6hCgJcDdLCsf(JgEsf6hCgZkkwJbn80LwwyeUPftQSdOvENwpP(n94McjvueRLa9doJ)mOlzY4GxbPUqQrrSwc0p4m(ZGUKjtqr84GxHKk8hn8Kk0p4mgf6gk50Lwwye(PftQu)4Urepm1MuNGdeX)wOq4lSjvQFC3iIhMoN8MchNuZpPc)rdpPYgIhoA4jv2b0kVtRNU0LuhzqZB8VhPftlNFAXKk7aAL3P1tQFtpUPqs1iP(Gk7hH9kTm7yN3e2b0kVLAbs9eCGi(NuVuHul8nwQfi1tWbI4Fs9cfs9kvyLALLAHesQnsQZrP(Gk7hH9kTm7yN3e2b0kVLAbs9eCGi(NuVuHul8fwPw5Kk8hn8K6eCaxYZ0LwwyslMuzhqR8oTEs9B6XnfsQOiwlb6hCglgMCtqetQWF0WtQidgtpEosxA5CkTysLDaTY706j1VPh3uiPIIyTeOFWzSyyYnbrmPc)rdpPkghn80Lww4LwmPYoGw5DA9K630JBkKuBeNTrxYKJNIrdvSj0IeEfqOII8wQfi1OiwlHvmdqghnCcIysf(JgEs9OtgBcTy6sllSPftQSdOvENwpP(n94McjvueRLa9doJfdtUj7W0LAbsnkI1sAeNXHflgMCt2HPl1cK6nJIyTKlq(mCyXxgJNqjLSdtpPc)rdpPwPLz3alCcYUCY(LU0YR00Ijv2b0kVtRNu)MECtHKkkI1sG(bNXIHj3KDy6sTaPgfXAjnIZ4WIfdtUj7W0LAbs9MrrSwYfiFgoS4lJXtOKs2HPNuH)OHNurHsCyXxtFfgPlTSWnTysLDaTY706j1VPh3uiPIIyTeOFWzSyyYnbrmPc)rdpPIY9GBfOEz6sll8tlMuzhqR8oTEs9B6XnfsQOiwlb6hCglgMCtqetQWF0WtQO1i2ylsNx6slVIslMuzhqR8oTEs9B6XnfsQOiwlb6hCglgMCtqetQWF0WtQwAZO1i2PlTC(gNwmPYoGw5DA9K630JBkKurrSwc0p4mwmm5MGiMuH)OHNub)5X1qf)qTMU0Lu3SfqQxAX0Y5NwmPYoGw5DA9K630JBkKupOl5JSzueRL8W4OEjPz4VKk8hn8K6hi(X9qKR10LwwyslMuzhqR8oTEsf(JgEs9HAfd)rdhxPJlPwPJd7WKtQJmO5n(3J0LwoNslMuzhqR8oTEsf(JgEs9HAfd)rdhxPJlPwPJd7WKtQ8yW(ZJ0Lww4LwmPYoGw5DA9K630JBkKuH)Ogym78KYdPEbPwysQWF0WtQpuRy4pA44kDCj1kDCyhMCsfcoDPLf20Ijv2b0kVtRNu)MECtHKQbOPaALjzGbghISZBPEPcP24Kk8hn8K6d1kg(JgoUshxsTshh2HjNudr25oDPLxPPftQSdOvENwpP(n94Mcj1bFh1lheyIhIWuQlK68tQWF0WtQpuRy4pA44kDCj1kDCyhMCsfM4HimtxAzHBAXKk7aAL3P1tQWF0WtQpuRy4pA44kDCj1kDCyhMCs9JOUdtFKU0Yc)0Ijv2b0kVtRNu)MECtHKQbOPaALjwQdvmks7sDHuBCsf(JgEs9HAfd)rdhxPJlPwPJd7WKtQDCWrdpDPLxrPftQSdOvENwpP(n94Mcjvdqtb0ktSuhQyuK2L6cPo)Kk8hn8K6d1kg(JgoUshxsTshh2HjNuTuhQyuK2txA58noTysLDaTY706jv4pA4j1hQvm8hnCCLoUKALooSdtoPodd8K9lDPlPAPouXOiTNwmTC(PftQSdOvENwpPc)rdpPc9doJN0XGw5rs9ZaQNuZpP(n94McjvueRL8vg6hgh1ljnd)LU0YctAXKk8hn8Kk0p4mgTcJlPYoGw5DA90LwoNslMuH)OHNuH(bNXOq3qjNuzhqR8oTE6sx6sQg4EqdpTSWySWyC(glmcVKQj0o1lhj1vCxjYzVCoRLxXzLl1s9IzSutNIrFsTnAPoh64GJgEoi1nVci0M3s9iMSudixmHJ3s9NbEjpiYCZ5Pol15VYL6CMWnW9XBPoh(Wa7GFeHdc7aAL35GuFHuNdFyGDWpIWroi1gLVIktK5MZtDwQfMvUuNZeUbUpEl15Whgyh8JiCqyhqR8ohK6lK6C4ddSd(reoYbP2O8vuzIm3CEQZsTWFLl15mHBG7J3sDo8Hb2b)iche2b0kVZbP(cPoh(Wa7GFeHJCqQnkFfvMiZnNN6Sulmc)vUuNZeUbUpEl1Q0zoJupYZpqrPw40s9fsDopci1BQb6GgUuhICdx0sTrRQSuBu(kQmrMRm3vCxjYzVCoRLxXzLl1s9IzSutNIrFsTnAPoheB(JjkC5Gu38kGqBEl1JyYsnGCXeoEl1Fg4L8GiZnNN6SuNtRCPoNjCdCF8wQZHpmWo4hr4GWoGw5Doi1xi15Whgyh8JiCKdsTr5ROYezU58uNLAH3kxQZzc3a3hVL6C4ddSd(reoiSdOvENds9fsDo8Hb2b)ich5GuBu(kQmrMBop1zPoFH3kxQZzc3a3hVL6C4ddSd(reoiSdOvENds9fsDo8Hb2b)ich5GuBu(kQmrMBop1zPoFH)kxQZzc3a3hVL6C4ddSd(reoiSdOvENds9fsDo8Hb2b)ich5GuBu(kQmrMRm3vCxjYzVCoRLxXzLl1s9IzSutNIrFsTnAPoh(iQ7W0h5Gu38kGqBEl1JyYsnGCXeoEl1Fg4L8GiZnNN6SuNFoTYL6CMWnW9XBPoh(Wa7GFeHdc7aAL35GuFHuNdFyGDWpIWroi1gLVIktK5MZtDwQZx4TYL6CMWnW9XBPoh(Wa7GFeHdc7aAL35GuFHuNdFyGDWpIWroi1gLVIktK5MZtDwQZFfTYL6CMWnW9XBPoh(Wa7GFeHdc7aAL35GuFHuNdFyGDWpIWroi1gLVIktK5MZtDwQfgJx5sDot4g4(4TuNdFyGDWpIWbHDaTY7CqQVqQZHpmWo4hr4ihKAJYxrLjYCL5MZAkg9XBPo)8LA4pA4sDLoUbrMBsvSdlTYj1vmPw4mqjl1Re9dolZDftQxomWtuUL68vsQfgJfgJL5kZDftQZzZZWal1gGMcOvMat8qeMsn1LAlyiAPoSs9GVJ6LdcmXdryk1g9z8RGuNxG0s9qKFPoepA4dLjYCxXK6vsXnC8wQP(XTdvPod8DL6LsDyLAdqtb0ktYadmoezN3s9fsnkl15l1MzSl1d(oQxoiWepeHPuxi15tK5UIj1RKdwQV8ePpuLAv6mNrQZaFxPEPuhwP(Za35Qut9J7gr8OHl1uFCmSL6Wk15Wd(Zvm8hn8CGiZvMl8hn8brS5pMOWTwXQgGMcOvwjhMCHyZIi1kMnekfIfnp4tPnBbK6vySmx4pA4dIyZFmrHBTIvnanfqRSsom5cXMfrQvmBiukelg8PKbOIWf5Re1wyaAkGwzIyZIi1kMnefglOrC2gDjtguXSWXJl6jHxbeQOiVfa)rnWy25jLhlimYCH)OHpiIn)XefU1kw1a0uaTYk5WKleBwePwXSHqPqSyWNsgGkcxKVsuBHbOPaALjInlIuRy2quySGgXzB0LmzqfZchpUONeEfqOII8wWhgyh8J483rn6nHDaTYBbWFudmMDEs5Xc5lZf(Jg(Gi28htu4wRyvdqtb0kRKdtUqSzrKAfZgcLcXIbFkzaQiCr(krTfgGMcOvMi2SisTIzdrHXcAeNTrxYKbvmlC84IEs4vaHkkYBbFyGDWpItlZoSfyc7aAL3YCH)OHpiIn)XefU1kw1a0uaTYk5WKlYadmoezN3kfIfnp4tPnBbK6vySmx4pA4dIyZFmrHBTIvnanfqRSsom5ImWaJdr25TsHyXGpLmaveUiFLO2cdqtb0ktYadmoezN3fgla(JAGXSZtkpwqyK5c)rdFqeB(JjkCRvSQbOPaALvYHjxKbgyCiYoVvkelg8PKbOIWf5Re1wyaAkGwzsgyGXHi78UWybgGMcOvMi2SisTIzdrr(YCH)OHpiIn)XefU1kw1a0uaTYk5WKlSuhQyuK2vkelg8PKbOIWfglZf(Jg(Gi28htu4wRyvdqtb0kRKdtUOh4jOiEZvipLcXIMh8P0MTas9kewzUWF0WheXM)yIc3AfRAaAkGwzLCyYfGiEckI3CfYtPqSO5bFkTzlGuVI8nwMl8hn8brS5pMOWTwXQgGMcOvwjhMCrhI4jOiEZvipLcXIMh8P0MTas9kegJL5c)rdFqeB(JjkCRvSQbOPaALvYHjxCXnXtqr8MRqEkfIfnp4tPnBbK6viSYCH)OHpiIn)XefU1kw1a0uaTYk5WKlU4M4jOiEZvipLcXIbFkzaQiCroPe1wyaAkGwzYf3epbfXBUc5viScAeNTrxYKnD8uXk1Hop8hZj4BcVciurrElZf(Jg(Gi28htu4wRyvdqtb0kRKdtU4IBINGI4nxH8ukelg8PKbOIWf5lSkrTfgGMcOvMCXnXtqr8MRqEfcRGpmWo4hXPLzh2cmHDaTYBzUWF0WheXM)yIc3AfRAaAkGwzLCyYfxCt8eueV5kKNsHyXGpLmaveUiFHvjQTWa0uaTYKlUjEckI3CfYRqyf8HVrOhb6hCgl2XMwMhHDaTYBbWFudmMDEs5Xs5Kmx4pA4dIyZFmrHBTIvnanfqRSsom5IlUjEckI3CfYtPqSyWNsgGkcxKtgRe1wyaAkGwzYf3epbfXBUc5viSc4XG9NjgOdA44WIf52Y)rdNmPE0YCH)OHpiIn)XefU1kw1a0uaTYk5WKlqHUHsgpbhWI)Puiw08GpL2SfqQxHW1yzUWF0WheXM)yIc3AfRAaAkGwzLCyYfOq3qjJNGdyX)ukelg8PKbOIWfcpJvIAlmanfqRmbf6gkz8eCal(xHW1ybFyGDWpItlZoSfyc7aAL3YCH)OHpiIn)XefU1kw1a0uaTYk5WKlar8K60jYepbhWI)Puiw08GpL2SfqQxrozSmx4pA4dIyZFmrHBTIvnanfqRSsom5cqepPoDImXtWbS4FkfIfd(uYaur4cH1yLO2cdqtb0ktar8K60jYepbhWI)vKtglOrC2gDjt20XtfRuh68WFmNGVj8kGqff5Tmx4pA4dIyZFmrHBTIvnanfqRSsom5cqepPoDImXtWbS4FkfIfd(uYaur4cH1yLO2cdqtb0ktar8K60jYepbhWI)vKtglOrC2gDjtkB6OMhM(0VYeEfqOII8wMl8hn8brS5pMOWTwXQgGMcOvwjhMCXf3epbfXFg0L8qPqSO5bFkTzlGuVcHrMl8hn8brS5pMOWTwXQgGMcOvwjhMCbem(IBINGI4pd6sEOuiw08GpL2SfqQxHWiZf(Jg(Gi28htu4wRyvdqtb0kRKdtUidmW4qKDERuiwm4tjdqfHlYxjQTWa0uaTYKmWaJdr25DHXcg8DuVCqGjEicZI8L5c)rdFqeB(JjkCRvSQbOPaALvYHjxat8qeMy2qGf)tPqSO5bFkTzlGuVI8fwzUWF0WheXM)yIc3AfRARWqbzUWF0WheXM)yIc3AfRAJylZf(Jg(Gi28htu4wRyvaPCY(bhnCzUWF0WheXM)yIc3AfRc9doJTWKwPqlZf(Jg(Gi28htu4wRyvOFWzm1pUw5)K5c)rdFqeB(JjkCRvS6hUWjinJNGd4sEkZf(Jg(Gi28htu4wRy1HdIJS4WJdUHmx4pA4dIyZFmrHBTIvN0UJgtNqjlZf(Jg(Gi28htu4wRyvBhJdnQNsuBHbOPaALjInlIuRy2qSuHXYCH)OHpiIn)XefU1kwLnepC0WvIAlmanfqRmrSzrKAfZgIfmwMRmx4pA4J1kw9de)4EiY1QsuBXbDjFKnJIyTKhgh1ljnd)jZf(Jg(yTIvFOwXWF0WXv64uYHjxmYGM34FpK5c)rdFSwXQpuRy4pA44kDCk5WKl4XG9NhYCH)OHpwRy1hQvm8hnCCLooLCyYfqWkrTfWFudmMDEs5XccJmx4pA4J1kw9HAfd)rdhxPJtjhMCriYo3krTfgGMcOvMKbgyCiYoVxQWyzUWF0WhRvS6d1kg(JgoUshNsom5cyIhIWujQTyW3r9YbbM4HimlYxMl8hn8XAfR(qTIH)OHJR0XPKdtU4JOUdtFiZf(Jg(yTIvFOwXWF0WXv64uYHjx0XbhnCLO2cdqtb0ktSuhQyuK2lmwMl8hn8XAfR(qTIH)OHJR0XPKdtUWsDOIrrAxjQTWa0uaTYel1HkgfP9I8L5c)rdFSwXQpuRy4pA44kDCk5WKlMHbEY(jZvMl8hn8bzKbnVX)ESwXQidgpbhWL8ujQTWOdQSFe2R0YSJDEtyhqR8wWeCGi(3sfcFJfmbhiI)TqXkvyvwiHmkhpOY(ryVslZo25nHDaTYBbtWbI4Flvi8fwLL5c)rdFqgzqZB8VhRvSkYGX0JNdLO2cueRLa9doJfdtUjiIYCH)OHpiJmO5n(3J1kwvmoA4krTfOiwlb6hCglgMCtqeL5c)rdFqgzqZB8VhRvS6rNm2eArLO2IgXzB0Lm54Py0qfBcTiHxbeQOiVfGIyTewXmazC0WjiIYCH)OHpiJmO5n(3J1kwTslZUbw4eKD5K9tjQTafXAjq)GZyXWKBYomDbOiwlPrCghwSyyYnzhMUGnJIyTKlq(mCyXxgJNqjLSdtxMl8hn8bzKbnVX)ESwXQOqjoS4RPVcdLO2cueRLa9doJfdtUj7W0fGIyTKgXzCyXIHj3KDy6c2mkI1sUa5ZWHfFzmEcLuYomDzUWF0WhKrg08g)7XAfRIY9GBfOEPsuBbkI1sG(bNXIHj3eerzUWF0WhKrg08g)7XAfRIwJyJTiDEkrTfOiwlb6hCglgMCtqeL5c)rdFqgzqZB8VhRvSQL2mAnITsuBbkI1sG(bNXIHj3eerzUWF0WhKrg08g)7XAfRc(ZJRHk(HAvjQTafXAjq)GZyXWKBcIOmxzUWF0WheEmy)5XAfRIwJyJdl(Yym78mpLO2IpI6omDYfiFgoS4lJXtOKsAEcuFuySaueRLa9doJ)mOlzY4GxHLkmanfqRm5IBINGI4pd6sEi4JOUdtNa9doJfdtUjnpbQpwQO83cjKLwMD4MNa1hl9ru3HPtG(bNXIHj3KMNa1hYCH)OHpi8yW(ZJ1kwfTgXghw8LXy25zEkrTfFe1Dy6eOFWzSyyYnP5jq9rHXcmkhpOY(ryVslZo25nHDaTYBHeYOdQSFe2R0YSJDEtyhqR8wWeCGi(3cfcxJfsObFh1lheyIhIWSiFLvwGrg9ru3HPtUa5ZWHfFzmEcLusZtG6JfmanfqRmbeXtqr8MRqEcmcfXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfesObFh1lheyIhIWSiFLvwiHm6JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vOWyLvwakI1sAeNXHflgMCt2HPlycoqe)BHcdqtb0ktar8K60jYepbhWI)jZf(Jg(GWJb7ppwRyvZORBdm1Xnpch8NvIAl(iQ7W0jq)GZyXWKBsZtG6JfkewJf8ru3HPtUa5ZWHfFzmEcLusZtG6JLkk)TaueRLa9doJ)mOlzY4GxHLkmanfqRm5IBINGI4pd6sEi4Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEYCH)OHpi8yW(ZJ1kw1m662atDCZJWb)zLO2IpI6omDYfiFgoS4lJXtOKsAEcuFuySaueRLa9doJ)mOlzY4GxHLkmanfqRm5IBINGI4pd6sEi4JOUdtNa9doJfdtUjnpbQpwQO83cjKLwMD4MNa1hl9ru3HPtG(bNXIHj3KMNa1hYCH)OHpi8yW(ZJ1kw1m662atDCZJWb)zLO2IpI6omDc0p4mwmm5M08eO(OWybgLJhuz)iSxPLzh78MWoGw5Tqcz0bv2pc7vAz2XoVjSdOvElycoqe)BHcHRXcj0GVJ6LdcmXdrywKVYklWiJ(iQ7W0jxG8z4WIVmgpHskP5jq9XcgGMcOvMaI4jOiEZvipbgHIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVccj0GVJ6LdcmXdrywKVYklKqg9ru3HPtUa5ZWHfFzmEcLusZtG6JcJfGIyTeOFWz8NbDjtgh8kuySYklafXAjnIZ4WIfdtUj7W0fmbhiI)TqHbOPaALjGiEsD6ezINGdyX)K5c)rdFq4XG9NhRvSAjc0Bk44WIHCoUJltjQT4JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vyPcdqtb0ktU4M4jOi(ZGUKhc(iQ7W0jq)GZyXWKBsZtG6JLkk)TqczPLzhU5jq9XsFe1Dy6eOFWzSyyYnP5jq9Hmx4pA4dcpgS)8yTIvlrGEtbhhwmKZXDCzkrTfFe1Dy6eOFWzSyyYnP5jq9rHXcmkhpOY(ryVslZo25nHDaTYBHeYOdQSFe2R0YSJDEtyhqR8wWeCGi(3cfcxJfsObFh1lheyIhIWSiFLvwGrg9ru3HPtUa5ZWHfFzmEcLusZtG6JfmanfqRmbeXtqr8MRqEcmcfXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfesObFh1lheyIhIWSiFLvwiHm6JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vOWyLvwakI1sAeNXHflgMCt2HPlycoqe)BHcdqtb0ktar8K60jYepbhWI)jZf(Jg(GWJb7ppwRy1p8N9RHJ3yBfMSsvQZ4FxSsvIAlqrSwc0p4mwmm5MSdtxakI1sAeNXHflgMCt2HPlyZOiwl5cKpdhw8LX4jusj7W0fmbhihDY4lWtqXfkyf5h5y8rNSmx4pA4dcpgS)8yTIvBgePEj2wHjpuIAlqrSwc0p4mwmm5MSdtxakI1sAeNXHflgMCt2HPlyZOiwl5cKpdhw8LX4jusj7W0fmbhihDY4lWtqXfkyf5h5y8rNSmx4pA4dcpgS)8yTIvTXJm4ngY54MEmgLHPsuBbkI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUmx4pA4dcpgS)8yTIvfrAQnpQxIrRW4uIAlqrSwc0p4mwmm5MSdtxakI1sAeNXHflgMCt2HPlyZOiwl5cKpdhw8LX4jusj7W0L5c)rdFq4XG9NhRvSAtffRmM64Hi8SsuBbkI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUmx4pA4dcpgS)8yTIvVmgJ4ObIVX2OFwjQTafXAjq)GZyXWKBYomDbOiwlPrCghwSyyYnzhMUGnJIyTKlq(mCyXxgJNqjLSdtxMl8hn8bHhd2FESwXQtEgDE4WIRipDJ3ndZHsuBbkI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUmxzUWF0WhKqKDUxRyvdqtb0kRKdtUidmW4qKDERuiwm4tjdqfHlYxjQTqSzd4YFtYNWgIhoA4YCH)OHpiHi7CVwXQwAZy0kmoLO2IgXzB0LmzthpvSsDOZd)XCc(MWRacvuK3cqrSwYMoEQyL6qNh(J5e8n22X4iiIYCH)OHpiHi7CVwXQ2ogh2ddGsuBrJ4Sn6sMu20rnpm9PFLj8kGqff5TGj4ar8VfwrcRmx4pA4dsiYo3RvS6K2D0dCyXx0t2pzUWF0WhKqKDUxRy1ndxgA0olZf(Jg(GeISZ9AfR2WMc(HhIqRGsuBXeCGi(3ccpJL5c)rdFqcr25ETIvFWFUIH)OHRe1wa)rdNmYO2J6LyXWKBYNbUZvQxkO83KMNa1hfglZf(Jg(GeISZ9AfRoYO2J6LyXWKBLO2IrGurP(MyPCDJdlgTgJrmhe2b0kVL5c)rdFqcr25ETIvVa5ZWHfFzmEcLuzUWF0WhKqKDUxRyvOFWzSyyYTmx4pA4dsiYo3RvSAJ4moSyXWKBLO2cueRL0ioJdlwmm5MSdtxMl8hn8bjezN71kwvS5b7pJdlEs9Tmx4pA4dsiYo3RvSk0p4mgTcJtjQTyhhPHnf8dpeHwbsZtG6JfewHeAZOiwlPHnf8dpeHwbSbKQZnGsR0lpY4GxHfmwMl8hn8bjezN71kwf6hCgJwHXPe1wGIyTeXMhS)moS4j13eerbBgfXAjxG8z4WIVmgpHskbruWMrrSwYfiFgoS4lJXtOKsAEcuFSub8hnCc0p4mgTcJJWkYpYX4JozzUWF0WhKqKDUxRyvOFWzmk0nuYkrTfOiwlb6hCglgMCtqefGIyTeOFWzSyyYnP5jq9XsfL)wakI1sG(bNXFg0LmzCWRqbkI1sG(bNXFg0LmzckIhh8kiZf(Jg(GeISZ9AfRc9doJN0XGw5HsuBXMrrSwYfiFgoS4lJXtOKsqefCqL9Ja9doJ5pliSdOvElafXAjBgUm0ODMSdtxWMrrSwYfiFgoS4lJXtOKsAEcuFSa8hnCc0p4mEshdALhewr(rogF0jlWOCeY54MEmb6hCglImNCL6Le2b0kVfsiueRL8vg6hgh1lXFg4oxj7W0vwPpdOEr(YCH)OHpiHi7CVwXQq)GZ4jDmOvEOe1wGIyTKVYq)W4OEjPz4pL(mG6f5lZf(Jg(GeISZ9AfRc9doJJgvjQTafXAjq)GZ4pd6sMmo4vyPcdqtb0ktU4M4jOi(ZGUKhcm6JOUdtNa9doJfdtUjnpbQpwiFJfsi4pQbgZopP8yPcHrzzUWF0WhKqKDUxRyvOFWzmAfgNsuBbkI1sAeNXHflgMCtqefsOj4ar8VfYxyL5c)rdFqcr25ETIvzdXdhnCLO2cueRL0ioJdlwmm5MSdtxjQFC3iIhMAlMGdeX)wOq4lSkr9J7gr8W05K3u44I8L5c)rdFqcr25ETIvH(bNXOq3qjlZvMl8hn8b5JOUdtFSwXQ2ogh2ddGsuBrJ4Sn6sMu20rnpm9PFLj8kGqff5TGpI6omDc0p4mwmm5M08eO(yHCYybFe1Dy6Klq(mCyXxgJNqjL08eO(OWybgHIyTeOFWz8NbDjtgh8kSuHbOPaALjxCt8eue)zqxYdbgz0bv2psJ4moSyXWKBc7aAL3c(iQ7W0jnIZ4WIfdtUjnpbQpwQO83c(iQ7W0jq)GZyXWKBsZtG6JfmanfqRm5IBINGI4nxH8uwiHmkhpOY(rAeNXHflgMCtyhqR8wWhrDhMob6hCglgMCtAEcuFSGbOPaALjxCt8eueV5kKNYcj0hrDhMob6hCglgMCtAEcuFSur5Vvw5vMss9kt4uAA00JMZXsnYG6LsDzth18KA6t)kl1M0ltQbrIuVsoyPMEsTj9YK6lUPuhxg3M0btK5c)rdFq(iQ7W0hRvSQTJXH9WaOe1w0ioBJUKjLnDuZdtF6xzcVciurrEl4JOUdtNa9doJfdtUjnpbQpkmwGr54bv2pc7vAz2XoVjSdOvElKqgDqL9JWELwMDSZBc7aAL3cMGdeX)wOq4ASYklWiJ(iQ7W0jxG8z4WIVmgpHskP5jq9Xc5BSaueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqzHeYOpI6omDYfiFgoS4lJXtOKsAEcuFuySaueRLa9doJ)mOlzY4GxHcJvwzbOiwlPrCghwSyyYnzhMUGj4ar8VfkmanfqRmbeXtQtNit8eCal(Nmx4pA4dYhrDhM(yTIvTDmo0OEkrTfnIZ2OlzYMoEQyL6qNh(J5e8nHxbeQOiVf8ru3HPtqrSw8MoEQyL6qNh(J5e8nPzyNNaueRLSPJNkwPo05H)yobFJTDmoYomDbgHIyTeOFWzSyyYnzhMUaueRL0ioJdlwmm5MSdtxWMrrSwYfiFgoS4lJXtOKs2HPRSGpI6omDYfiFgoS4lJXtOKsAEcuFuySaJqrSwc0p4m(ZGUKjJdEfwQWa0uaTYKlUjEckI)mOl5HaJm6Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEklKqgLJhuz)inIZ4WIfdtUjSdOvEl4JOUdtNa9doJfdtUjnpbQpwWa0uaTYKlUjEckI3CfYtzHe6JOUdtNa9doJfdtUjnpbQpwQO83kRSmx4pA4dYhrDhM(yTIvT0MXOvyCkrTfnIZ2OlzYMoEQyL6qNh(J5e8nHxbeQOiVf8ru3HPtqrSw8MoEQyL6qNh(J5e8nPzyNNaueRLSPJNkwPo05H)yobFJT0Mj7W0fi2SbC5Vj5tSDmo0OEYCH)OHpiFe1Dy6J1kwDs7o6boS4l6j7NsuBXhrDhMo5cKpdhw8LX4jusjnpbQpkmwakI1sG(bNXFg0LmzCWRWsfgGMcOvMCXnXtqr8NbDjpe8ru3HPtG(bNXIHj3KMNa1hlvu(7vMss9kBLOAc5nKAKbl1tA3rpKAt6Lj1GirQZzzL6lUPuthsDZWopPggsTjxRkj1tqbwQhinl1xi1pmoPMEsnkBJML6lUjrMl8hn8b5JOUdtFSwXQtA3rpWHfFrpz)uIAl(iQ7W0jq)GZyXWKBsZtG6JcJfyuoEqL9JWELwMDSZBc7aAL3cjKrhuz)iSxPLzh78MWoGw5TGj4ar8VfkeUgRSYcmYOpI6omDYfiFgoS4lJXtOKsAEcuFSGbOPaALjGiEckI3CfYtakI1sG(bNXFg0LmzCWRqbkI1sG(bNXFg0LmzckIhh8kOSqcz0hrDhMo5cKpdhw8LX4jusjnpbQpkmwakI1sG(bNXFg0LmzCWRqHXkRSaueRL0ioJdlwmm5MSdtxWeCGi(3cfgGMcOvMaI4j1PtKjEcoGf)tMl8hn8b5JOUdtFSwXQBgUm0ODwjQT4JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vyPcdqtb0ktU4M4jOi(ZGUKhc(iQ7W0jq)GZyXWKBsZtG6JLkk)9ktjPELTsunH8gsnYGL6ndxgA0ol1M0ltQbrIuNZYk1xCtPMoK6MHDEsnmKAtUwvsQNGcSupqAwQVqQFyCsn9KAu2gnl1xCtImx4pA4dYhrDhM(yTIv3mCzOr7SsuBXhrDhMob6hCglgMCtAEcuFuySaJYXdQSFe2R0YSJDEtyhqR8wiHm6Gk7hH9kTm7yN3e2b0kVfmbhiI)TqHW1yLvwGrg9ru3HPtUa5ZWHfFzmEcLusZtG6JfY3ybOiwlb6hCg)zqxYKXbVcfOiwlb6hCg)zqxYKjOiECWRGYcjKrFe1Dy6Klq(mCyXxgJNqjL08eO(OWybOiwlb6hCg)zqxYKXbVcfgRSYcqrSwsJ4moSyXWKBYomDbtWbI4FluyaAkGwzciINuNorM4j4aw8pzUWF0WhKpI6om9XAfR2WMc(HhIqRGsuBXhrDhMo5cKpdhw8LX4jusjnpbQpwWa0uaTYKEGNGI4nxH8e8ru3HPtG(bNXIHj3KMNa1hlyaAkGwzspWtqr8MRqEcm6Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BHe6Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlyaAkGwzspWtqr8MRqEcjuoEqL9J0ioJdlwmm5MWoGw5TYcqrSwc0p4m(ZGUKjJdEfwqyeSzueRLCbYNHdl(Yy8ekPKDy6RmLK6v2k5GL6Hi0ki1uRuFXnLAW3snik1qZsD4s9VLAW3sTz45Wj1OSuJik12OL6A4LCl1xg4s9LXs9euuQ3CfYtjPEckq9sPEG0SuBYsDgyGLA4K6kdJtQpZqQH(bNL6pd6sEi1GVL6ldoP(IBk1MWWZHtQfobzCsnYG3ezUWF0WhKpI6om9XAfR2WMc(HhIqRGsuBXhrDhMo5cKpdhw8LX4jusjnpbQpkmwakI1sG(bNXFg0LmzCWRWsfgGMcOvMCXnXtqr8NbDjpe8ru3HPtG(bNXIHj3KMNa1hlvu(7vMss9kBLCWs9qeAfKAt6Lj1GOuBMXUulgJbfTYePoNLvQV4MsnDi1nd78KAyi1MCTQKupbfyPEG0SuFHu)W4KA6j1OSnAwQV4MezUWF0WhKpI6om9XAfR2WMc(HhIqRGsuBXhrDhMob6hCglgMCtAEcuFuySaJmkhpOY(ryVslZo25nHDaTYBHeYOdQSFe2R0YSJDEtyhqR8wWeCGi(3cfcxJvwzbgz0hrDhMo5cKpdhw8LX4jusjnpbQpwWa0uaTYeqepbfXBUc5jafXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfuwiHm6JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vOWyLvwakI1sAeNXHflgMCt2HPlycoqe)BHcdqtb0ktar8K60jYepbhWI)PSmx4pA4dYhrDhM(yTIvVa5ZWHfFzmEcLuLO2IpI6omDc0p4mwmm5M08eO(yjH1yb8yW(Zed0bnCCyXICB5)OHtMupAzUWF0WhKpI6om9XAfREbYNHdl(Yy8ekPkrTfOiwlb6hCg)zqxYKXbVclvyaAkGwzYf3epbfXFg0L8qWbv2psJ4moSyXWKBc7aAL3c(iQ7W0jnIZ4WIfdtUjnpbQpwQO83c(iQ7W0jq)GZyXWKBsZtG6JfmanfqRm5IBINGI4nxH8e8Hb2b)ikKxtbNWoGw5TGpI6omDsdBk4hEicTcKMNa1hlvi8xzkj1RmHZZRPGVYL6vYbl1xCtPMALAquQPdPoCP(3sn4BP2m8C4KAuwQreLAB0sDn8sUL6ldCP(YyPEckk1BUc5rK6vIkT0LAt6Lj1Dik1uRuFzSuFqL9tQPdP(afyNi1cNAu3sni1O0tQVqQNGcSupqAwQnzP(bxQZzRk105K3u44AEsnypUL6lUPuZ(EiZf(Jg(G8ru3HPpwRy1lq(mCyXxgJNqjvjQTafXAjq)GZ4pd6sMmo4vyPcdqtb0ktU4M4jOi(ZGUKhcoOY(rAeNXHflgMCtyhqR8wWhrDhMoPrCghwSyyYnP5jq9XsfL)wWhrDhMob6hCglgMCtAEcuFSGbOPaALjxCt8eueV5kKNGC8ddSd(ruiVMcoHDaTY7vMss9kB5WfoRW551uWx5s9k5GL6lUPutTsnik10HuhUu)BPg8TuBgEoCsnkl1iIsTnAPUgEj3s9LbUuFzSupbfL6nxH8is9krLw6sTj9YK6oeLAQvQVmwQpOY(j10HuFGcStK5c)rdFq(iQ7W0hRvS6fiFgoS4lJXtOKQe1wGIyTeOFWz8NbDjtgh8kSuHbOPaALjxCt8eue)zqxYdb54bv2psJ4moSyXWKBc7aAL3c(iQ7W0jq)GZyXWKBsZtG6JfmanfqRm5IBINGI4nxH8K5c)rdFq(iQ7W0hRvS6fiFgoS4lJXtOKQe1wGIyTeOFWz8NbDjtgh8kSuHbOPaALjxCt8eue)zqxYdbFe1Dy6eOFWzSyyYnP5jq9XsfL)wMl8hn8b5JOUdtFSwXQq)GZyXWKBLO2cJYXdQSFe2R0YSJDEtyhqR8wiHm6Gk7hH9kTm7yN3e2b0kVfmbhiI)TqHW1yLvwWhrDhMo5cKpdhw8LX4jusjnpbQpwWa0uaTYeqepbfXBUc5jafXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfeGIyTKgXzCyXIHj3KDy6cMGdeX)wOWa0uaTYeqepPoDImXtWbS4FRmLK6v2k5GLAquQPwP(IBk10HuhUu)BPg8TuBgEoCsnkl1iIsTnAPUgEj3s9LbUuFzSupbfL6nxH8usQNGcuVuQhinl1xgCsTjl1zGbwQzpqkZK6j4Gud(wQVm4K6lJBwQPdP2JtQHAZWopPgK6gXzPoSsTyyYTuVdtNiZf(Jg(G8ru3HPpwRy1gXzCyXIHj3krTfOiwlPrCghwSyyYnzhMUGpI6omDYfiFgoS4lJXtOKsAEcuFSGbOPaALjDiINGI4nxH8eGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVccm6JOUdtNa9doJfdtUjnpbQpwiFHviH2mkI1sUa5ZWHfFzmEcLucIOYRmLK6v2k5GL6oeLAQvQV4MsnDi1Hl1)wQbFl1MHNdNuJYsnIOuBJwQRHxYTuFzGl1xgl1tqrPEZvipLK6jOa1lL6bsZs9LXnl10HNdNud1MHDEsni1nIZs9omDPg8TuFzWj1GOuBgEoCsnk)XKLAWaqRaALL6nst9sPUrCMiZf(Jg(G8ru3HPpwRyvXMhS)moS4j13krTfOiwlb6hCg)zqxYKXbVcfgl4ddSd(ruiVMcoHDaTY7vMss9kt488Ak4RCPoNTQuths9eCqQZq8YopPg8TuVsSUWBi1qZs9fHuZkkY(GAGL6lKAKbl1IXuQVqQhRacZ5CSudUuZkEni1aQutDP(YyP(IBk1MuFhMePoNNVCyi1idwQPNuFHupbfyPUgMs9NbDjl1ReRpKAQpoWpImx4pA4dYhrDhM(yTIvfBEW(Z4WINuFRe1wSzueRLCbYNHdl(Yy8ekPeerb54hgyh8JOqEnfCc7aAL3RmLK6v2YHlCwHZZRPGVYL6vYbl1IXuQVqQhRacZ5CSudUuZkEni1aQutDP(YyP(IBk1MuFhMezUYCH)OHpiDCWrdFTIvH(bNXOq3qjRe1w8ru3HPtUa5ZWHfFzmEcLusZtG6JcJfyekI1sG(bNXFg0LmzCWRWcgGMcOvMCXnXtqr8NbDjpeCqL9J0ioJdlwmm5MWoGw5TGpI6omDsJ4moSyXWKBsZtG6JLkk)TGpI6omDc0p4mwmm5M08eO(ybdqtb0ktU4M4jOiEZvipbFyGDWpIc51uWjSdOvEl4JOUdtN0WMc(HhIqRaP5jq9XsfcFLL5c)rdFq64GJg(AfRc9doJrHUHswjQT4JOUdtNCbYNHdl(Yy8ekPKMNa1hfglWiueRLa9doJ)mOlzY4GxHfmanfqRm5IBINGI4pd6sEi4Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEcYXpmWo4hrH8Ak4e2b0kVvwMl8hn8bPJdoA4RvSk0p4mgf6gkzLO2IpI6omDYfiFgoS4lJXtOKsAEcuFuySaJqrSwc0p4m(ZGUKjJdEfwWa0uaTYKlUjEckI)mOl5HGC8Gk7hPrCghwSyyYnHDaTYBbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEklZf(Jg(G0Xbhn81kwf6hCgJcDdLSsuBXhrDhMo5cKpdhw8LX4jusjnpbQpkmwGrOiwlb6hCg)zqxYKXbVclyaAkGwzYf3epbfXFg0L8qWhrDhMob6hCglgMCtAEcuFSur5VvwM7kMuVmZBP(cPMofR8K9tQhxt)tQh8kGW(ZdPoAPgfHw3sn4snupUD4OgyPoJBMiZDftQH)OHpiDCWrdFTIvhxt)dp4vaH9NvIAl2mkI1sAytb)WdrOvaBaP6CdO0k9YJmo4vOyZOiwlPHnf8dpeHwbSbKQZnGsR0lpYeuepo4vqakI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDLCyYfvyC4Hi0kGhh8kSYH(bNXOvyCRCOFWzmk0nuYYCH)OHpiDCWrdFTIvH(bNXOq3qjRe1wSzueRL0WMc(HhIqRa2as15gqPv6LhzCWRqXMrrSwsdBk4hEicTcydivNBaLwPxEKjOiECWRGaJqrSwc0p4mwmm5MSdtxiHqrSwc0p4mwmm5M08eO(yPIYFRSaJqrSwsJ4moSyXWKBYomDHecfXAjnIZ4WIfdtUjnpbQpwQO83klZf(Jg(G0Xbhn81kwf6hCgJwHXPe1wSJJ0WMc(HhIqRaP5jq9XccRqcTzueRL0WMc(HhIqRa2as15gqPv6LhzCWRWcglZf(Jg(G0Xbhn81kwf6hCgJwHXPe1wGIyTeXMhS)moS4j13eerbBgfXAjxG8z4WIVmgpHskbruWMrrSwYfiFgoS4lJXtOKsAEcuFSub8hnCc0p4mgTcJJWkYpYX4JozzUWF0WhKoo4OHVwXQq)GZ4jDmOvEOe1wSzueRLCbYNHdl(Yy8ekPeerbhuz)iq)GZy(Zcc7aAL3cqrSwYMHldnANj7W0fy0MrrSwYfiFgoS4lJXtOKsAEcuFSa8hnCc0p4mEshdALhewr(rogF0jlKqFe1Dy6eXMhS)moS4j13KMNa1hlySqc9Hb2b)ikKxtbNWoGw5TYcmkhHCoUPhtG(bNXIiZjxPEjHDaTYBHecfXAjFLH(HXr9s8NbUZvYomDLv6ZaQxKVmx4pA4dshhC0WxRyvOFWz8Kog0kpuIAlqrSwYxzOFyCuVK0m8NaueRLWkkc(M3yX4y)OqLGikZf(Jg(G0Xbhn81kwf6hCgpPJbTYdLO2cueRL8vg6hgh1ljnd)jWiueRLa9doJfdtUjiIcjekI1sAeNXHflgMCtqefsOnJIyTKlq(mCyXxgJNqjL08eO(yb4pA4eOFWz8Kog0kpiSI8JCm(OtwzL(mG6f5lZf(Jg(G0Xbhn81kwf6hCgpPJbTYdLO2cueRL8vg6hgh1ljnd)jafXAjFLH(HXr9sY4GxHcueRL8vg6hgh1ljtqr84GxbL(mG6f5lZf(Jg(G0Xbhn81kwf6hCgpPJbTYdLO2cueRL8vg6hgh1ljnd)jafXAjFLH(HXr9ssZtG6JLkmYiueRL8vg6hgh1ljJdEfwXd)rdNa9doJN0XGw5bHvKFKJXhDYkVw5VvwPpdOEr(YCH)OHpiDCWrdFTIvD(Y4gF8uKhNsuBHrnBBEKbOvwiHYXJ(kq9sLfGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVccqrSwc0p4mwmm5MSdtxWMrrSwYfiFgoS4lJXtOKs2HPlZf(Jg(G0Xbhn81kwf6hCghnQsuBbkI1sG(bNXFg0LmzCWRWsfgGMcOvMCXnXtqr8NbDjpK5c)rdFq64GJg(AfRoqe52ddGsuBXeCGi(3sfRiHvakI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUmx4pA4dshhC0WxRy1rg1EuVelgMCRe1wGIyTeOFWzSyyYnzhMUaueRL0ioJdlwmm5MSdtxWMrrSwYfiFgoS4lJXtOKs2HPl4JOUdtNWgIhoA4KMNa1hlySGpI6omDc0p4mwmm5M08eO(ybJf8ru3HPtUa5ZWHfFzmEcLusZtG6JfmwGr54bv2psJ4moSyXWKBc7aAL3cjKrhuz)inIZ4WIfdtUjSdOvEl4JOUdtN0ioJdlwmm5M08eO(ybJvwzzUWF0WhKoo4OHVwXQq)GZy0kmoLO2cueRL0ivghw8L1mpiiIcqrSwc0p4m(ZGUKjJdEfwiNK5c)rdFq64GJg(AfRc9doJrHUHswjQTycoqe)Bjdqtb0ktqHUHsgpbhWI)j4JOUdtNWgIhoA4KMNa1hlySaueRLa9doJfdtUj7W0fGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVcc4XG9NjgOdA44WIf52Y)rdNmPE0YCH)OHpiDCWrdFTIvH(bNXOq3qjRe1w8ru3HPtUa5ZWHfFzmEcLusZtG6JcJfy0hrDhMoPrCghwSyyYnP5jq9rHXcj0hrDhMob6hCglgMCtAEcuFuySYcqrSwc0p4m(ZGUKjJdEfkqrSwc0p4m(ZGUKjtqr84GxbzUWF0WhKoo4OHVwXQq)GZyuOBOKvIAlMGdeX)wQWa0uaTYeuOBOKXtWbS4FcqrSwc0p4mwmm5MSdtxakI1sAeNXHflgMCt2HPlyZOiwl5cKpdhw8LX4jusj7W0fGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVcc(iQ7W0jSH4HJgoP5jq9XcglZf(Jg(G0Xbhn81kwf6hCgJcDdLSsuBbkI1sG(bNXIHj3KDy6cqrSwsJ4moSyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUaueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqWbv2pc0p4moAuc7aAL3c(iQ7W0jq)GZ4OrjnpbQpwQO83cMGdeX)wQyfzSGpI6omDcBiE4OHtAEcuFSGXYCH)OHpiDCWrdFTIvH(bNXOq3qjRe1wGIyTeOFWzSyyYnbruakI1sG(bNXIHj3KMNa1hlvu(BbOiwlb6hCg)zqxYKXbVcfOiwlb6hCg)zqxYKjOiECWRGmx4pA4dshhC0WxRyvOFWzmk0nuYkrTfOiwlPrCghwSyyYnbruakI1sAeNXHflgMCtAEcuFSur5VfGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVcYCH)OHpiDCWrdFTIvH(bNXOq3qjRe1wGIyTeOFWzSyyYnzhMUaueRL0ioJdlwmm5MSdtxWMrrSwYfiFgoS4lJXtOKsqefSzueRLCbYNHdl(Yy8ekPKMNa1hlvu(BbOiwlb6hCg)zqxYKXbVcfOiwlb6hCg)zqxYKjOiECWRGmx4pA4dshhC0WxRyvOFWzmAfgNmx4pA4dshhC0WxRyv2q8WrdxjQFC3iIhMAlMGdeX)wOq4lSkr9J7gr8W05K3u44I8L5c)rdFq64GJg(AfRc9doJrHUHswMl8hn8bPJdoA4RvSQbOPaALvYHjxyPouXOiTRuiwm4tjdqfHlYxjQTafXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfeKJOiwlPrQmoS4lRzEqqefyPLzhU5jq9Xsfgz0eCq40WF0Wjq)GZy0kmoYhJt5v8WF0Wjq)GZy0kmocRi)ihJp6KvwMRmx4pA4dIL6qfJI0(AfRc9doJN0XGw5HsuBbkI1s(kd9dJJ6LKMH)u6ZaQxKVmx4pA4dIL6qfJI0(AfRc9doJrRW4K5c)rdFqSuhQyuK2xRyvOFWzmk0nuYYCL5c)rdFqGGxRyvBhJdnQNsuBrJ4Sn6sMSPJNkwPo05H)yobFt4vaHkkYBbFe1Dy6eueRfVPJNkwPo05H)yobFtAg25jafXAjB64PIvQdDE4pMtW3yBhJJSdtxGrOiwlb6hCglgMCt2HPlafXAjnIZ4WIfdtUj7W0fSzueRLCbYNHdl(Yy8ekPKDy6kl4JOUdtNCbYNHdl(Yy8ekPKMNa1hfglWiueRLa9doJ)mOlzY4GxHLkmanfqRmbcgFXnXtqr8NbDjpeyKrhuz)inIZ4WIfdtUjSdOvEl4JOUdtN0ioJdlwmm5M08eO(yPIYFl4JOUdtNa9doJfdtUjnpbQpwWa0uaTYKlUjEckI3CfYtzHeYOC8Gk7hPrCghwSyyYnHDaTYBbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEklKqFe1Dy6eOFWzSyyYnP5jq9XsfL)wzLL5c)rdFqGGxRyvlTzmAfgNsuBHrnIZ2OlzYMoEQyL6qNh(J5e8nHxbeQOiVf8ru3HPtqrSw8MoEQyL6qNh(J5e8nPzyNNaueRLSPJNkwPo05H)yobFJT0Mj7W0fi2SbC5Vj5tSDmo0OEklKqg1ioBJUKjB64PIvQdDE4pMtW3eEfqOII8wWrNCHXklZf(Jg(GabVwXQ2ogh2ddGsuBrJ4Sn6sMu20rnpm9PFLj8kGqff5TGpI6omDc0p4mwmm5M08eO(yHCYybFe1Dy6Klq(mCyXxgJNqjL08eO(OWybgHIyTeOFWz8NbDjtgh8kSuHbOPaALjqW4lUjEckI)mOl5HaJm6Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEklKqgLJhuz)inIZ4WIfdtUjSdOvEl4JOUdtNa9doJfdtUjnpbQpwWa0uaTYKlUjEckI3CfYtzHe6JOUdtNa9doJfdtUjnpbQpwQO83kRSmx4pA4dce8AfRA7yCypmakrTfnIZ2Olzszth18W0N(vMWRacvuK3c(iQ7W0jq)GZyXWKBsZtG6JcJfyKrg9ru3HPtUa5ZWHfFzmEcLusZtG6JfmanfqRmbeXtqr8MRqEcqrSwc0p4m(ZGUKjJdEfkqrSwc0p4m(ZGUKjtqr84GxbLfsiJ(iQ7W0jxG8z4WIVmgpHskP5jq9rHXcqrSwc0p4m(ZGUKjJdEfwQWa0uaTYeiy8f3epbfXFg0L8qzLfGIyTKgXzCyXIHj3KDy6klZf(Jg(GabVwXQxG8z4WIVmgpHsQsuBrJ4Sn6sMmOIzHJhx0tcVciurrElqSzd4YFtYNWgIhoA4YCH)OHpiqWRvSk0p4mwmm5wjQTOrC2gDjtguXSWXJl6jHxbeQOiVfyKyZgWL)MKpHnepC0WfsiXMnGl)njFYfiFgoS4lJXtOKQSmx4pA4dce8AfRYgIhoA4krTfhDYlKtglOrC2gDjtguXSWXJl6jHxbeQOiVfGIyTeOFWz8NbDjtgh8kSuHbOPaALjqW4lUjEckI)mOl5HGpI6omDYfiFgoS4lJXtOKsAEcuFuySGpI6omDc0p4mwmm5M08eO(yPIYFlZf(Jg(GabVwXQSH4HJgUsuBXrN8c5KXcAeNTrxYKbvmlC84IEs4vaHkkYBbFe1Dy6eOFWzSyyYnP5jq9rHXcmYiJ(iQ7W0jxG8z4WIVmgpHskP5jq9XcgGMcOvMaI4jOiEZvipbOiwlb6hCg)zqxYKXbVcfOiwlb6hCg)zqxYKjOiECWRGYcjKrFe1Dy6Klq(mCyXxgJNqjL08eO(OWybOiwlb6hCg)zqxYKXbVclvyaAkGwzcem(IBINGI4pd6sEOSYcqrSwsJ4moSyXWKBYomDLvI6h3nI4HP2cueRLmOIzHJhx0tY4GxHcueRLmOIzHJhx0tYeuepo4vqjQFC3iIhMoN8MchxKVmx4pA4dce8AfRoPDh9ahw8f9K9tjQTWOpI6omDc0p4mwmm5M08eO(ybHNWkKqFe1Dy6eOFWzSyyYnP5jq9Xsf5KYc(iQ7W0jxG8z4WIVmgpHskP5jq9rHXcmcfXAjq)GZ4pd6sMmo4vyPcdqtb0ktGGXxCt8eue)zqxYdbgz0bv2psJ4moSyXWKBc7aAL3c(iQ7W0jnIZ4WIfdtUjnpbQpwQO83c(iQ7W0jq)GZyXWKBsZtG6JfewLfsiJYXdQSFKgXzCyXIHj3e2b0kVf8ru3HPtG(bNXIHj3KMNa1hliSklKqFe1Dy6eOFWzSyyYnP5jq9XsfL)wzLL5c)rdFqGGxRy1g2uWp8qeAfuIAl(iQ7W0jxG8z4WIVmgpHskP5jq9XcgGMcOvM0d8eueV5kKNGpI6omDc0p4mwmm5M08eO(ybdqtb0kt6bEckI3CfYtGrhuz)inIZ4WIfdtUjSdOvEl4JOUdtN0ioJdlwmm5M08eO(yPIYFlKqhuz)inIZ4WIfdtUjSdOvEl4JOUdtN0ioJdlwmm5M08eO(ybdqtb0kt6bEckI3CfYtiHYXdQSFKgXzCyXIHj3e2b0kVvwakI1sG(bNXFg0LmzCWRWsfgGMcOvMabJV4M4jOi(ZGUKhc2mkI1sUa5ZWHfFzmEcLuYomDzUWF0Whei41kwTHnf8dpeHwbLO2IpI6omDYfiFgoS4lJXtOKsAEcuFuySaJqrSwc0p4m(ZGUKjJdEfwQWa0uaTYeiy8f3epbfXFg0L8qGrgDqL9J0ioJdlwmm5MWoGw5TGpI6omDsJ4moSyXWKBsZtG6JLkk)TGpI6omDc0p4mwmm5M08eO(ybdqtb0ktU4M4jOiEZvipLfsiJYXdQSFKgXzCyXIHj3e2b0kVf8ru3HPtG(bNXIHj3KMNa1hlyaAkGwzYf3epbfXBUc5PSqc9ru3HPtG(bNXIHj3KMNa1hlvu(BLvwMl8hn8bbcETIvBytb)WdrOvqjQT4JOUdtNa9doJfdtUjnpbQpkmwGrgz0hrDhMo5cKpdhw8LX4jusjnpbQpwWa0uaTYeqepbfXBUc5jafXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfuwiHm6JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vyPcdqtb0ktGGXxCt8eue)zqxYdLvwakI1sAeNXHflgMCt2HPRSmx4pA4dce8AfRUz4YqJ2zLO2IpI6omDc0p4mwmm5M08eO(OWybgzKrFe1Dy6Klq(mCyXxgJNqjL08eO(ybdqtb0ktar8eueV5kKNaueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqzHeYOpI6omDYfiFgoS4lJXtOKsAEcuFuySaueRLa9doJ)mOlzY4GxHLkmanfqRmbcgFXnXtqr8NbDjpuwzbOiwlPrCghwSyyYnzhMUYYCH)OHpiqWRvS6fiFgoS4lJXtOKQe1wGIyTeOFWz8NbDjtgh8kSuHbOPaALjqW4lUjEckI)mOl5HaJm6Gk7hPrCghwSyyYnHDaTYBbFe1Dy6KgXzCyXIHj3KMNa1hlvu(BbFe1Dy6eOFWzSyyYnP5jq9XcgGMcOvMCXnXtqr8MRqEklKqgLJhuz)inIZ4WIfdtUjSdOvEl4JOUdtNa9doJfdtUjnpbQpwWa0uaTYKlUjEckI3CfYtzHe6JOUdtNa9doJfdtUjnpbQpwQO83klZf(Jg(GabVwXQq)GZyXWKBLO2cJm6JOUdtNCbYNHdl(Yy8ekPKMNa1hlyaAkGwzciINGI4nxH8eGIyTeOFWz8NbDjtgh8kuGIyTeOFWz8NbDjtMGI4XbVcklKqg9ru3HPtUa5ZWHfFzmEcLusZtG6JcJfGIyTeOFWz8NbDjtgh8kSuHbOPaALjqW4lUjEckI)mOl5HYklafXAjnIZ4WIfdtUj7W0L5c)rdFqGGxRy1gXzCyXIHj3krTfOiwlPrCghwSyyYnzhMUaJm6JOUdtNCbYNHdl(Yy8ekPKMNa1hlimglafXAjq)GZ4pd6sMmo4vOafXAjq)GZ4pd6sMmbfXJdEfuwiHm6JOUdtNCbYNHdl(Yy8ekPKMNa1hfglafXAjq)GZ4pd6sMmo4vyPcdqtb0ktGGXxCt8eue)zqxYdLvwGrFe1Dy6eOFWzSyyYnP5jq9Xc5lScj0MrrSwYfiFgoS4lJXtOKsqevwMl8hn8bbcETIvfBEW(Z4WINuFRe1wGIyTKndxgA0otqefSzueRLCbYNHdl(Yy8ekPeerbBgfXAjxG8z4WIVmgpHskP5jq9XsfOiwlrS5b7pJdlEs9nzckIhh8kSIh(Jgob6hCgJwHXryf5h5y8rNSmx4pA4dce8AfRc9doJrRW4uIAlqrSwYMHldnANjiIcmYOdQSFKMhHd(Ze2b0kVfa)rnWy25jLhlj8uwiHG)Ogym78KYJLewLL5c)rdFqGGxRy1bIi3EyaK5c)rdFqGGxRyvOFWzC0OkrTfOiwlb6hCg)zqxYKXbVcfglZf(Jg(GabVwXQoFzCJpEkYJtjQTWOMTnpYa0klKq54rFfOEPYcqrSwc0p4m(ZGUKjJdEfkqrSwc0p4m(ZGUKjtqr84GxbzUWF0Whei41kwDKrTh1lXIHj3krTfOiwlb6hCglgMCt2HPlafXAjnIZ4WIfdtUj7W0fSzueRLCbYNHdl(Yy8ekPKDy6c(iQ7W0jq)GZyXWKBsZtG6JfmwWhrDhMo5cKpdhw8LX4jusjnpbQpwWybgLJhuz)inIZ4WIfdtUjSdOvElKqgDqL9J0ioJdlwmm5MWoGw5TGpI6omDsJ4moSyXWKBsZtG6JfmwzLL5c)rdFqGGxRyvOFWz8Kog0kpuIAlqrSwYxzOFyCuVK0m8NGgXzB0Lmb6hCgtDl1PxEeEfqOII8wWbv2pcmfRul9HJgoHDaTYBbWFudmMDEs5XsRizUWF0Whei41kwf6hCgpPJbTYdLO2cueRL8vg6hgh1ljnd)jOrC2gDjtG(bNXu3sD6LhHxbeQOiVfa)rnWy25jLhlTsL5c)rdFqGGxRyvOFWzmROyng0WvIAlqrSwc0p4m(ZGUKjJdEfwcfXAjq)GZ4pd6sMmbfXJdEfK5c)rdFqGGxRyvOFWzmROyng0WvIAlqrSwc0p4m(ZGUKjJdEfkqrSwc0p4m(ZGUKjtqr84GxbbInBax(Bs(eOFWzmk0nuYYCH)OHpiqWRvSk0p4mgf6gkzLO2cueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqMl8hn8bbcETIvzdXdhnCLO(XDJiEyQTycoqe)BHcHVWQe1pUBeXdtNtEtHJlYxMRm3vmPg(Jg(Gat8qeMfp4pxXWF0WvIAlG)OHtydXdhnCYNbUZvQxkycoqe)BHIvKWkZf(Jg(Gat8qeMRvSkBiE4OHRe1pUBeXdtTftWbI4FluSIewLO(XDJiEy6CYBkCCr(krTftWbI4FlvyaAkGwzcmXdryIzdbw8pbg9ru3HPtUa5ZWHfFzmEcLusZtG6JLkG)OHtydXdhnCcRi)ihJp6KfsOpI6omDc0p4mwmm5M08eO(yPc4pA4e2q8WrdNWkYpYX4JozHeYOdQSFKgXzCyXIHj3e2b0kVf8ru3HPtAeNXHflgMCtAEcuFSub8hnCcBiE4OHtyf5h5y8rNSYklafXAjnIZ4WIfdtUj7W0fGIyTeOFWzSyyYnzhMUGnJIyTKlq(mCyXxgJNqjLSdtxMl8hn8bbM4HimxRy1gXzCyXIHj3krTfOiwlPrCghwSyyYnzhMUGpI6omDc0p4mwmm5M08eO(ybJL5c)rdFqGjEicZ1kw9cKpdhw8LX4jusvIAlm6JOUdtNa9doJfdtUjnpbQpkmwakI1sAeNXHflgMCt2HPRSqcj2SbC5Vj5tAeNXHflgMClZf(Jg(Gat8qeMRvS6fiFgoS4lJXtOKQe1w8ru3HPtG(bNXIHj3KMNa1hljSglafXAjnIZ4WIfdtUj7W0fWJb7ptmqh0WXHflYTL)JgoHDaTYBzUWF0WheyIhIWCTIvH(bNXIHj3krTfOiwlPrCghwSyyYnzhMUGpI6omDYfiFgoS4lJXtOKsAEcuFSGbOPaALjGiEckI3CfYtMl8hn8bbM4HimxRyvOFWzmk0nuYkrTfOiwlb6hCglgMCtqefGIyTeOFWzSyyYnP5jq9XsfWF0Wjq)GZ4jDmOvEqyf5h5y8rNSaueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqMl8hn8bbM4HimxRyvOFWzC0OkrTfOiwlb6hCg)zqxYKXbVclHIyTeOFWz8NbDjtMGI4XbVccqrSwsJ4moSyXWKBYomDbOiwlb6hCglgMCt2HPlyZOiwl5cKpdhw8LX4jusj7W0L5c)rdFqGjEicZ1kwf6hCgJcDdLSsuBbkI1sAeNXHflgMCt2HPlafXAjq)GZyXWKBYomDbBgfXAjxG8z4WIVmgpHskzhMUaueRLa9doJ)mOlzY4GxHcueRLa9doJ)mOlzYeuepo4vqMl8hn8bbM4HimxRyvOFWz8Kog0kpuIAlqrSwYxzOFyCuVK0m8NsFgq9I8vIHUMh(ZaQJP2cueRL8vg6hgh1lXFg4oxj7W0fyekI1sG(bNXIHj3eerHecfXAjnIZ4WIfdtUjiIcj0hrDhMoHnepC0Wjnd78uwMl8hn8bbM4HimxRyvOFWz8Kog0kpuIAlYriNJB6XeOFWzSiYCYvQxsyhqR8wiHqrSwYxzOFyCuVe)zG7CLSdtxPpdOEr(kXqxZd)za1XuBbkI1s(kd9dJJ6L4pdCNRKDy6cmcfXAjq)GZyXWKBcIOqcHIyTKgXzCyXIHj3eerHe6JOUdtNWgIhoA4KMHDEklZf(Jg(Gat8qeMRvSkBiE4OHRe1wGIyTKgXzCyXIHj3KDy6cqrSwc0p4mwmm5MSdtxWMrrSwYfiFgoS4lJXtOKs2HPlZf(Jg(Gat8qeMRvSk0p4moAuLO2cueRLa9doJ)mOlzY4GxHLqrSwc0p4m(ZGUKjtqr84GxbzUWF0WheyIhIWCTIvH(bNXOq3qjlZf(Jg(Gat8qeMRvSk0p4mgTcJtMRmx4pA4dYmmWt2V1kwfTsDfWGNNsuBXmmWt2pYMooWFEHI8nwMl8hn8bzgg4j73AfRk28G9NXHfpP(wMl8hn8bzgg4j73AfRc9doJN0XGw5HsuBXmmWt2pYMooWFEP8nwMl8hn8bzgg4j73AfRc9doJJgvMl8hn8bzgg4j73AfRAPnJrRW4sQaYLfDsvLorQWrdpNPb7LU0Lsa]] )


end
