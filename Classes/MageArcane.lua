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


    spec:RegisterPack( "Arcane", 20201024, [[d00pbeqiHcwKsKYJiibxIGefBIaFsOiJIcCksuRsjIsVsjLzrIClcsu1Uq8lLKggf0XeQAzeeEMqrnncs5AeeTnLiX3iiPXrqQoNqHADkrsZtjX9KW(ucoOsevlujvpujI0hjiHyKeKqQtkuiSsHkVuOqKzQerCtcsuzNkr9tcsuAOeKqYsvIO4PK0uvcDvcsKVkuiQXQePAVc(ludMuhgSyi9yvnzL6YO2mL(SenAHCAKwnbjuVMGA2kCBfTBQ(TOHtOJReHLl1ZL00v56qSDk03POXtcDEHsRxOqA(KG9t0H4dlgu3WXHLfcdfcdJ3qHqOrIp(yogl0wkb1lwroOkcVWqjhuDyYb1L8(bNdQIqSJe2HfdQ1ePFoOgDNyDPU6QL0lcbL85C1kDImGJM(3G9wTsN)Qbvue64Ir4b0G6gooSSqyOqyy8gkecns8XhZX4ywOguRI8hwEPieb1i6EZEanOU56hufki1cLdkzPEjVFWzzCcfKAHY(xIYTulecHssTqyOqyOmozCcfK6Lm8mnYsTrOPa6GjWexfHPutDP2cgZwQtRux57OEzLatCveMsTbFe)cl1XMiTuxf5xQtXJMEvzImoHcsTqjXnC8wQP(XTddPoc89G6LsDALAJqtb0btIaJmofzN3s9Lsnkl1Xl1MrSl1v(oQxwjWexfHPuxi1XtcQdA9QHfdQPi7ChwmSC8HfdQSdOdEhwpOMIb1kFbv4pA6bvJqtb0bhuncdeoOgFq9B6XnfcQInBex(Bs8e2y(WrtpOAeASdtoOgbgzCkYoVdxyzHiSyqLDaDW7W6b1VPh3uiO2ioBZUKjBA9PIdQdDS4pNtW3eEjqOII8wQfi1OiwlztRpvCqDOJf)5Cc(gB7SEeeXGk8hn9GQL2mgDa1lCHLJ5WIbv2b0bVdRhu)MECtHGAJ4Sn7sMu206iwm9P)Gj8sGqff5TulqQNGdeX)K6fK6ySqguH)OPhuTDwpSNgHWfwwOfwmOc)rtpOoPDNDfNw8L9K9lOYoGo4Dy9WfwwidlguH)OPhu3mCrOz7CqLDaDW7W6HlS8sjSyqLDaDW7W6b1VPh3uiOobhiI)j1li1cnddQWF00dQnSPGF4Qi0chUWYc1WIbv2b0bVdRhu)MECtHGk8hnDsnIApQxIfttUjFe4opOEPulqQl)nP5jq9Quxi1gguH)OPhuFWFEGH)OPhUWYc9WIbv2b0bVdRhu)MECtHGAnrgOuFtSuESXPfJoYAnNvc7a6G3bv4pA6b1Ae1EuVelMMChUWYX4WIbv4pA6b1lr(iCAXxeJNqjnOYoGo4Dy9WfwoEddlguH)OPhuH(bNXIPj3bv2b0bVdRhUWYXhFyXGk7a6G3H1dQFtpUPqqffXAjnIZ40IfttUj700dQWF00dQnIZ40IfttUdxy54fIWIbv4pA6bvXMRS)moT4j13bv2b0bVdRhUWYXhZHfdQSdOdEhwpO(n94Mcb1DEKg2uWpCveAHjnpbQxL6fKAHuQvqbPEZOiwlPHnf8dxfHwySrKHZnGsh0lws9GxyPEbP2WGk8hn9Gk0p4mgDa1lCHLJxOfwmOYoGo4Dy9G630JBkeurrSwIyZv2FgNw8K6BcIOulqQ3mkI1sUe5JWPfFrmEcLucIOulqQ3mkI1sUe5JWPfFrmEcLusZtG6vPELcPg(JMob6hCgJoG6ryf5h5y8rNCqf(JMEqf6hCgJoG6fUWYXlKHfdQSdOdEhwpO(n94McbvueRLa9doJfttUjiIsTaPgfXAjq)GZyX0KBsZtG6vPELcPU83sTaPgfXAjq)GZ4pc6sMup4fwQlKAueRLa9doJ)iOlzYeuexp4foOc)rtpOc9doJrHUHsoCHLJFPewmOYoGo4Dy9Gk8hn9Gk0p4mEsRv6GRb1pcOEqn(G630JBkeu3mkI1sUe5JWPfFrmEcLucIOulqQpyW(rG(bNX8hLe2b0bVLAbsnkI1s2mCrOz7mzNMUulqQ3mkI1sUe5JWPfFrmEcLusZtG6vPEbPg(JMob6hCgpP1kDWvcRi)ihJp6KLAbsTbsDmi1qmk30Jjq)GZyrK5KhuVKWoGo4TuRGcsnkI1s(bd9d1J6L4pcCNhKDA6sTYHlSC8c1WIbv2b0bVdRhuH)OPhuH(bNXtATshCnO(ra1dQXhu)MECtHGkkI1s(bd9d1J6LKMH)cxy54f6HfdQSdOdEhwpO(n94McbvueRLa9doJ)iOlzs9GxyPELcP2i0uaDWKlVjEckI)iOl5QulqQnqQ)mh700jq)GZyX0KBsZtG6vPEbPoEdLAfuqQH)Ogzm78KYvPELcPwiKALdQWF00dQq)GZ4Srdxy54JXHfdQSdOdEhwpO(n94McbvueRL0ioJtlwmn5MGik1kOGupbhiI)j1li1XlKbv4pA6bvOFWzm6aQx4clleggwmOYoGo4Dy9Gk8hn9GkBmF4OPhuP(XDJiEyQnOobhiI)TqHqxidQu)4UrepmDo5nfooOgFq9B6XnfcQOiwlPrCgNwSyAYnzNME4clleXhwmOc)rtpOc9doJrHUHsoOYoGo4Dy9WfUGkxRS)CnSyy54dlguzhqh8oSEq9B6XnfcQFMJDA6Klr(iCAXxeJNqjL08eOEvQlKAdLAbsnkI1sG(bNXFe0LmPEWlSuVsHuBeAkGoyYL3epbfXFe0LCvQfi1FMJDA6eOFWzSyAYnP5jq9QuVsHux(BPwbfKAlTm6WnpbQxL6vK6pZXonDc0p4mwmn5M08eOEnOc)rtpOIoYCJtl(Iym78m2Wfwwiclguzhqh8oSEq9B6XnfcQFMJDA6eOFWzSyAYnP5jq9Quxi1gk1cKAdK6yqQpyW(ryFqlJo25nHDaDWBPwbfKAdK6dgSFe2h0YOJDEtyhqh8wQfi1tWbI4Fs9cfsTq1qPwbfK6kFh1lReyIRIWuQlK64LALLALLAbsTbsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0btar8eueV5beRulqQnqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLAfuqQR8DuVSsGjUkctPUqQJxQvwQvwQvqbP2aP(ZCSttNCjYhHtl(Iy8ekPKMNa1RsDHuBOulqQrrSwc0p4m(JGUKj1dEHL6cP2qPwzPwzPwGuJIyTKgXzCAXIPj3KDA6sTaPEcoqe)tQxOqQncnfqhmbeXtQtNit8eCal(xqf(JMEqfDK5gNw8fXy25zSHlSCmhwmOYoGo4Dy9G630JBkeu)mh700jq)GZyX0KBsZtG6vPEHcPwinuQfi1FMJDA6Klr(iCAXxeJNqjL08eOEvQxPqQl)TulqQrrSwc0p4m(JGUKj1dEHL6vkKAJqtb0btU8M4jOi(JGUKRsTaP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtAeNXPflMMCtAEcuVk1Rui1L)wQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoyYL3epbfXBEaXguH)OPhunZESnYuh3CnDWFoCHLfAHfdQSdOdEhwpO(n94Mcb1pZXonDYLiFeoT4lIXtOKsAEcuVk1fsTHsTaPgfXAjq)GZ4pc6sMup4fwQxPqQncnfqhm5YBINGI4pc6sUk1cK6pZXonDc0p4mwmn5M08eOEvQxPqQl)TuRGcsTLwgD4MNa1Rs9ks9N5yNMob6hCglMMCtAEcuVguH)OPhunZESnYuh3CnDWFoCHLfYWIbv2b0bVdRhu)MECtHG6N5yNMob6hCglMMCtAEcuVk1fsTHsTaP2aPogK6dgSFe2h0YOJDEtyhqh8wQvqbP2aP(Gb7hH9bTm6yN3e2b0bVLAbs9eCGi(NuVqHulunuQvqbPUY3r9YkbM4QimL6cPoEPwzPwzPwGuBGuBGu)zo2PPtUe5JWPfFrmEcLusZtG6vPEbP2i0uaDWeqepbfXBEaXk1cKAdKAueRLa9doJ)iOlzs9GxyPUqQrrSwc0p4m(JGUKjtqrC9GxyPwbfK6kFh1lReyIRIWuQlK64LALLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPUqQnuQvwQvwQfi1OiwlPrCgNwSyAYnzNMUulqQNGdeX)K6fkKAJqtb0btar8K60jYepbhWI)fuH)OPhunZESnYuh3CnDWFoCHLxkHfdQSdOdEhwpO(n94Mcb1pZXonDYLiFeoT4lIXtOKsAEcuVk1fsTHsTaPgfXAjq)GZ4pc6sMup4fwQxPqQncnfqhm5YBINGI4pc6sUk1cK6pZXonDc0p4mwmn5M08eOEvQxPqQl)TuRGcsTLwgD4MNa1Rs9ks9N5yNMob6hCglMMCtAEcuVguH)OPhulrGEtbhNwmeJYDErHlSSqnSyqLDaDW7W6b1VPh3uiO(zo2PPtG(bNXIPj3KMNa1RsDHuBOulqQnqQJbP(Gb7hH9bTm6yN3e2b0bVLAfuqQnqQpyW(ryFqlJo25nHDaDWBPwGupbhiI)j1lui1cvdLAfuqQR8DuVSsGjUkctPUqQJxQvwQvwQfi1gi1gi1FMJDA6Klr(iCAXxeJNqjL08eOEvQxqQncnfqhmbeXtqr8MhqSsTaP2aPgfXAjq)GZ4pc6sMup4fwQlKAueRLa9doJ)iOlzYeuexp4fwQvqbPUY3r9YkbM4QimL6cPoEPwzPwzPwbfKAdK6pZXonDYLiFeoT4lIXtOKsAEcuVk1fsTHsTaPgfXAjq)GZ4pc6sMup4fwQlKAdLALLALLAbsnkI1sAeNXPflMMCt2PPl1cK6j4ar8pPEHcP2i0uaDWeqepPoDImXtWbS4Fbv4pA6b1seO3uWXPfdXOCNxu4cll0dlguzhqh8oSEqf(JMEq9t)z)A44n2oGjhu)MECtHGkkI1sG(bNXIPj3KDA6sTaPgfXAjnIZ40IfttUj700LAbs9MrrSwYLiFeoT4lIXtOKs2PPl1cK6j4a5OtgFjEckk1lui1SI8JCm(OtoOoOoJ)DqDPeUWYX4WIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3KDA6sTaPgfXAjnIZ40IfttUj700LAbs9MrrSwYLiFeoT4lIXtOKs2PPl1cK6j4a5OtgFjEckk1lui1SI8JCm(OtoOc)rtpO2mis9sSDatUgUWYXByyXGk7a6G3H1dQFtpUPqqffXAjq)GZyX0KBYonDPwGuJIyTKgXzCAXIPj3KDA6sTaPEZOiwl5sKpcNw8fX4jusj700dQWF00dQ28rQ8gdXOCtpgJYWmCHLJp(WIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3KDA6sTaPgfXAjnIZ40IfttUj700LAbs9MrrSwYLiFeoT4lIXtOKs2PPhuH)OPhufrAQnwQxIrhq9cxy54fIWIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3KDA6sTaPgfXAjnIZ40IfttUj700LAbs9MrrSwYLiFeoT4lIXtOKs2PPhuH)OPhuBQO4GXuhxfHNdxy54J5WIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3KDA6sTaPgfXAjnIZ40IfttUj700LAbs9MrrSwYLiFeoT4lIXtOKs2PPhuH)OPhuVigJ4OjIVX2SFoCHLJxOfwmOYoGo4Dy9G630JBkeurrSwc0p4mwmn5MSttxQfi1OiwlPrCgNwSyAYnzNMUulqQ3mkI1sUe5JWPfFrmEcLuYon9Gk8hn9G6KNzhloT4bYt34DZWSgUWfuHjUkcZWIHLJpSyqLDaDW7W6b1VPh3uiOIIyTKgXzCAXIPj3KDA6sTaP(ZCSttNa9doJfttUjnpbQxL6fKAddQWF00dQnIZ40IfttUdxyzHiSyqLDaDW7W6b1VPh3uiOAGu)zo2PPtG(bNXIPj3KMNa1RsDHuBOulqQrrSwsJ4moTyX0KBYonDPwzPwbfKAXMnIl)njEsJ4moTyX0K7Gk8hn9G6LiFeoT4lIXtOKgUWYXCyXGk7a6G3H1dQFtpUPqq9ZCSttNa9doJfttUjnpbQxL6vKAH0qPwGuJIyTKgXzCAXIPj3KDA6sTaPMRv2FMyKwPPJtlwKBl)hnDc7a6G3bv4pA6b1lr(iCAXxeJNqjnCHLfAHfdQSdOdEhwpO(n94McbvueRL0ioJtlwmn5MSttxQfi1FMJDA6Klr(iCAXxeJNqjL08eOEvQxqQncnfqhmbeXtqr8MhqSbv4pA6bvOFWzSyAYD4cllKHfdQSdOdEhwpO(n94McbvueRLa9doJfttUjiIsTaPgfXAjq)GZyX0KBsZtG6vPELcPg(JMob6hCgpP1kDWvcRi)ihJp6KLAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlCqf(JMEqf6hCgJcDdLC4clVuclguzhqh8oSEq9B6XnfcQOiwlb6hCg)rqxYK6bVWs9ksnkI1sG(bNXFe0LmzckIRh8cl1cKAueRL0ioJtlwmn5MSttxQfi1Oiwlb6hCglMMCt2PPl1cK6nJIyTKlr(iCAXxeJNqjLSttpOc)rtpOc9doJZgnCHLfQHfdQSdOdEhwpO(n94McbvueRL0ioJtlwmn5MSttxQfi1Oiwlb6hCglMMCt2PPl1cK6nJIyTKlr(iCAXxeJNqjLSttxQfi1Oiwlb6hCg)rqxYK6bVWsDHuJIyTeOFWz8hbDjtMGI46bVWbv4pA6bvOFWzmk0nuYHlSSqpSyqLDaDW7W6b1pcOEqn(Gkd9iw8hbuhtTbvueRL8dg6hQh1lXFe4opi700fyakI1sG(bNXIPj3eerfuafXAjnIZ40IfttUjiIkOWN5yNMoHnMpC00jnd7yvoO(n94McbvueRL8dg6hQh1ljnd)fuH)OPhuH(bNXtATshCnCHLJXHfdQSdOdEhwpO(ra1dQXhuzOhXI)iG6yQnOIIyTKFWq)q9OEj(Ja35bzNMUadqrSwc0p4mwmn5MGiQGcOiwlPrCgNwSyAYnbrubf(mh700jSX8HJMoPzyhRYb1VPh3uiOgdsneJYn9yc0p4mwezo5b1ljSdOdEl1kOGuJIyTKFWq)q9OEj(Ja35bzNMEqf(JMEqf6hCgpP1kDW1WfwoEddlguP(XDJiEyQnOobhiI)TqrmwidQu)4UrepmDo5nfooOgFqf(JMEqLnMpC00dQSdOdEhwpCHLJp(WIbv2b0bVdRhu)MECtHGkkI1sG(bNXFe0LmPEWlSuVIuJIyTeOFWz8hbDjtMGI46bVWbv4pA6bvOFWzC2OHlSC8cryXGk8hn9Gk0p4mgf6gk5Gk7a6G3H1dxy54J5WIbv4pA6bvOFWzm6aQxqLDaDW7W6HlCb1op4OPhwmSC8HfdQSdOdEhwpO(n94Mcb1pZXonDYLiFeoT4lIXtOKsAEcuVk1fsTHsTaP2aPgfXAjq)GZ4pc6sMup4fwQxqQncnfqhm5YBINGI4pc6sUk1cK6dgSFKgXzCAXIPj3e2b0bVLAbs9N5yNMoPrCgNwSyAYnP5jq9QuVsHux(BPwGu)zo2PPtG(bNXIPj3KMNa1Rs9csTrOPa6GjxEt8eueV5beRulqQ)0i7GFeHJTPGl1cK6pZXonDsdBk4hUkcTWKMNa1Rs9kfsTqxQvoOc)rtpOc9doJrHUHsoCHLfIWIbv2b0bVdRhu)MECtHG6N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuBGuJIyTeOFWz8hbDjtQh8cl1li1gHMcOdMC5nXtqr8hbDjxLAbs9bd2psJ4moTyX0KBc7a6G3sTaP(ZCSttN0ioJtlwmn5M08eOEvQxPqQl)TulqQ)mh700jq)GZyX0KBsZtG6vPEbP2i0uaDWKlVjEckI38aIvQfi1XGu)Pr2b)ichBtbxQvoOc)rtpOc9doJrHUHsoCHLJ5WIbv2b0bVdRhu)MECtHG6N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuBGuJIyTeOFWz8hbDjtQh8cl1li1gHMcOdMC5nXtqr8hbDjxLAbsDmi1hmy)inIZ40IfttUjSdOdEl1cK6pZXonDc0p4mwmn5M08eOEvQxqQncnfqhm5YBINGI4npGyLALdQWF00dQq)GZyuOBOKdxyzHwyXGk7a6G3H1dQFtpUPqq9ZCSttNCjYhHtl(Iy8ekPKMNa1RsDHuBOulqQnqQrrSwc0p4m(JGUKj1dEHL6fKAJqtb0btU8M4jOi(JGUKRsTaP(ZCSttNa9doJfttUjnpbQxL6vkK6YFl1khuH)OPhuH(bNXOq3qjhUWYczyXGk7a6G3H1dQFtpUPqqDZOiwlPHnf8dxfHwySrKHZnGsh0lws9GxyPUqQ3mkI1sAytb)WvrOfgBez4CdO0b9ILmbfX1dEHLAbsTbsnkI1sG(bNXIPj3KDA6sTcki1Oiwlb6hCglMMCtAEcuVk1Rui1L)wQvwQfi1gi1OiwlPrCgNwSyAYnzNMUuRGcsnkI1sAeNXPflMMCtAEcuVk1Rui1L)wQvoOc)rtpOc9doJrHUHsoCHLxkHfdQSdOdEhwpO(n94Mcb1DEKg2uWpCveAHjnpbQxL6fKAHuQvqbPEZOiwlPHnf8dxfHwySrKHZnGsh0lws9GxyPEbP2WGk8hn9Gk0p4mgDa1lCHLfQHfdQSdOdEhwpO(n94McbvueRLi2CL9NXPfpP(MGik1cK6nJIyTKlr(iCAXxeJNqjLGik1cK6nJIyTKlr(iCAXxeJNqjL08eOEvQxPqQH)OPtG(bNXOdOEewr(rogF0jhuH)OPhuH(bNXOdOEHlSSqpSyqLDaDW7W6bv4pA6bvOFWz8KwR0bxdQFeq9GA8b1VPh3uiOUzueRLCjYhHtl(Iy8ekPeerPwGuFWG9Ja9doJ5pkjSdOdEl1cKAueRLSz4IqZ2zYonDPwGuBGuVzueRLCjYhHtl(Iy8ekPKMNa1Rs9csn8hnDc0p4mEsRv6GRewr(rogF0jl1kOGu)zo2PPteBUY(Z40INuFtAEcuVk1li1gk1kOGu)Pr2b)ichBtbxQvwQfi1gi1XGudXOCtpMa9doJfrMtEq9sc7a6G3sTcki1Oiwl5hm0pupQxI)iWDEq2PPl1khUWYX4WIbv2b0bVdRhu)MECtHGkkI1s(bd9d1J6LKMH)KAbsnkI1syffbFZBSyESFuyqqedQWF00dQq)GZ4jTwPdUgUWYXByyXGk7a6G3H1dQWF00dQq)GZ4jTwPdUgu)iG6b14dQFtpUPqqffXAj)GH(H6r9ssZWFsTaP2aPgfXAjq)GZyX0KBcIOuRGcsnkI1sAeNXPflMMCtqeLAfuqQ3mkI1sUe5JWPfFrmEcLusZtG6vPEbPg(JMob6hCgpP1kDWvcRi)ihJp6KLALdxy54JpSyqLDaDW7W6bv4pA6bvOFWz8KwR0bxdQFeq9GA8b1VPh3uiOIIyTKFWq)q9OEjPz4pPwGuJIyTKFWq)q9OEjPEWlSuxi1Oiwl5hm0pupQxsMGI46bVWHlSC8cryXGk7a6G3H1dQWF00dQq)GZ4jTwPdUgu)iG6b14dQFtpUPqqffXAj)GH(H6r9ssZWFsTaPgfXAj)GH(H6r9ssZtG6vPELcP2aP2aPgfXAj)GH(H6r9ss9GxyPEjRud)rtNa9doJN0ALo4kHvKFKJXhDYsTYs9AsD5VLALdxy54J5WIbv2b0bVdRhu)MECtHGQbsDZ2MRra6GLAfuqQJbP(OVWuVuQvwQfi1Oiwlb6hCg)rqxYK6bVWsDHuJIyTeOFWz8hbDjtMGI46bVWsTaPgfXAjq)GZyX0KBYonDPwGuVzueRLCjYhHtl(Iy8ekPKDA6bv4pA6bvNViUXhpf56fUWYXl0clguzhqh8oSEq9B6XnfcQOiwlb6hCg)rqxYK6bVWs9kfsTrOPa6GjxEt8eue)rqxY1Gk8hn9Gk0p4moB0WfwoEHmSyqLDaDW7W6b1VPh3uiOobhiI)j1Rui1XyHuQfi1Oiwlb6hCglMMCt2PPl1cKAueRL0ioJtlwmn5MSttxQfi1BgfXAjxI8r40IVigpHskzNMEqf(JMEqTIiYTNgHWfwo(LsyXGk7a6G3H1dQFtpUPqqffXAjq)GZyX0KBYonDPwGuJIyTKgXzCAXIPj3KDA6sTaPEZOiwl5sKpcNw8fX4jusj700LAbs9N5yNMoHnMpC00jnpbQxL6fKAdLAbs9N5yNMob6hCglMMCtAEcuVk1li1gk1cK6pZXonDYLiFeoT4lIXtOKsAEcuVk1li1gk1cKAdK6yqQpyW(rAeNXPflMMCtyhqh8wQvqbP2aP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtAeNXPflMMCtAEcuVk1li1gk1kl1khuH)OPhuRru7r9sSyAYD4clhVqnSyqLDaDW7W6b1VPh3uiOIIyTKgzW40IVOM5kbruQfi1Oiwlb6hCg)rqxYK6bVWs9csDmhuH)OPhuH(bNXOdOEHlSC8c9WIbv2b0bVdRhu)MECtHG6eCGi(NuVIuBeAkGoyck0nuY4j4aw8pPwGu)zo2PPtyJ5dhnDsZtG6vPEbP2qPwGuJIyTeOFWzSyAYnzNMUulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLAbsnxRS)mXiTsthNwSi3w(pA6Kj1ZoOc)rtpOc9doJrHUHsoCHLJpghwmOYoGo4Dy9G630JBkeu)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAdK6pZXonDsJ4moTyX0KBsZtG6vPUqQnuQvqbP(ZCSttNa9doJfttUjnpbQxL6cP2qPwzPwGuJIyTeOFWz8hbDjtQh8cl1fsnkI1sG(bNXFe0LmzckIRh8chuH)OPhuH(bNXOq3qjhUWYcHHHfdQSdOdEhwpO(n94Mcb1j4ar8pPELcP2i0uaDWeuOBOKXtWbS4FsTaPgfXAjq)GZyX0KBYonDPwGuJIyTKgXzCAXIPj3KDA6sTaPEZOiwl5sKpcNw8fX4jusj700LAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlSulqQ)mh700jSX8HJMoP5jq9QuVGuByqf(JMEqf6hCgJcDdLC4clleXhwmOYoGo4Dy9G630JBkeurrSwc0p4mwmn5MSttxQfi1OiwlPrCgNwSyAYnzNMUulqQ3mkI1sUe5JWPfFrmEcLuYonDPwGuJIyTeOFWz8hbDjtQh8cl1fsnkI1sG(bNXFe0LmzckIRh8cl1cK6dgSFeOFWzC2Oe2b0bVLAbs9N5yNMob6hCgNnkP5jq9QuVsHux(BPwGupbhiI)j1Rui1XydLAbs9N5yNMoHnMpC00jnpbQxL6fKAddQWF00dQq)GZyuOBOKdxyzHqiclguzhqh8oSEq9B6XnfcQOiwlb6hCglMMCtqeLAbsnkI1sG(bNXIPj3KMNa1Rs9kfsD5VLAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlCqf(JMEqf6hCgJcDdLC4clleXCyXGk7a6G3H1dQFtpUPqqffXAjnIZ40IfttUjiIsTaPgfXAjnIZ40IfttUjnpbQxL6vkK6YFl1cKAueRLa9doJ)iOlzs9GxyPUqQrrSwc0p4m(JGUKjtqrC9Gx4Gk8hn9Gk0p4mgf6gk5WfwwieAHfdQSdOdEhwpO(n94McbvueRLa9doJfttUj700LAbsnkI1sAeNXPflMMCt2PPl1cK6nJIyTKlr(iCAXxeJNqjLGik1cK6nJIyTKlr(iCAXxeJNqjL08eOEvQxPqQl)TulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHdQWF00dQq)GZyuOBOKdxyzHqidlguH)OPhuH(bNXOdOEbv2b0bVdRhUWYcXsjSyqL6h3nI4HP2G6eCGi(3cfcDHmOs9J7gr8W05K3u44GA8bv4pA6bv2y(WrtpOYoGo4Dy9WfwwieQHfdQWF00dQq)GZyuOBOKdQSdOdEhwpCHLfcHEyXGk7a6G3H1dQPyqTYxqf(JMEq1i0uaDWbvJWaHdQXhu)MECtHGkkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlSulqQJbPgfXAjnYGXPfFrnZvcIOulqQT0YOd38eOEvQxPqQnqQnqQNGds9Qsn8hnDc0p4mgDa1J8z9KALL6LSsn8hnDc0p4mgDa1JWkYpYX4JozPw5GQrOXom5GQL6WaJI0E4cxqfsoSyy54dlguzhqh8oSEq9B6XnfcQnIZ2SlzYMwFQ4G6qhl(Z5e8nHxceQOiVLAbs9N5yNMobfXAXBA9PIdQdDS4pNtW3KMHDSsTaPgfXAjBA9PIdQdDS4pNtW3yBN1JSttxQfi1gi1Oiwlb6hCglMMCt2PPl1cKAueRL0ioJtlwmn5MSttxQfi1BgfXAjxI8r40IVigpHskzNMUuRSulqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAdKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWeiz8L3epbfXFe0LCvQfi1gi1gi1hmy)inIZ40IfttUjSdOdEl1cK6pZXonDsJ4moTyX0KBsZtG6vPELcPU83sTaP(ZCSttNa9doJfttUjnpbQxL6fKAJqtb0btU8M4jOiEZdiwPwzPwbfKAdK6yqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoyYL3epbfXBEaXk1kl1kOGu)zo2PPtG(bNXIPj3KMNa1Rs9kfsD5VLALLALdQWF00dQ2oRhAoUWfwwiclguzhqh8oSEq9B6XnfcQgi1nIZ2SlzYMwFQ4G6qhl(Z5e8nHxceQOiVLAbs9N5yNMobfXAXBA9PIdQdDS4pNtW3KMHDSsTaPgfXAjBA9PIdQdDS4pNtW3ylTzYonDPwGul2SrC5VjXtSDwp0CCsTYsTcki1gi1nIZ2SlzYMwFQ4G6qhl(Z5e8nHxceQOiVLAbs9rNSuxi1gk1khuH)OPhuT0MXOdOEHlSCmhwmOYoGo4Dy9G630JBkeuBeNTzxYKYMwhXIPp9hmHxceQOiVLAbs9N5yNMob6hCglMMCtAEcuVk1li1XSHsTaP(ZCSttNCjYhHtl(Iy8ekPKMNa1RsDHuBOulqQnqQrrSwc0p4m(JGUKj1dEHL6vkKAJqtb0btGKXxEt8eue)rqxYvPwGuBGuBGuFWG9J0ioJtlwmn5MWoGo4TulqQ)mh700jnIZ40IfttUjnpbQxL6vkK6YFl1cK6pZXonDc0p4mwmn5M08eOEvQxqQncnfqhm5YBINGI4npGyLALLAfuqQnqQJbP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtG(bNXIPj3KMNa1Rs9csTrOPa6GjxEt8eueV5beRuRSuRGcs9N5yNMob6hCglMMCtAEcuVk1Rui1L)wQvwQvoOc)rtpOA7SEypncHlSSqlSyqLDaDW7W6b1VPh3uiO2ioBZUKjLnToIftF6pycVeiurrEl1cK6pZXonDc0p4mwmn5M08eOEvQlKAdLAbsTbsTbsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0btar8eueV5beRulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWeiz8L3epbfXFe0LCvQvwQvwQfi1OiwlPrCgNwSyAYnzNMUuRCqf(JMEq12z9WEAecxyzHmSyqLDaDW7W6b1VPh3uiO2ioBZUKjvQyu646L9KWlbcvuK3sTaPwSzJ4YFtINWgZhoA6bv4pA6b1lr(iCAXxeJNqjnCHLxkHfdQSdOdEhwpO(n94Mcb1gXzB2LmPsfJshxVSNeEjqOII8wQfi1gi1InBex(Bs8e2y(WrtxQvqbPwSzJ4YFtINCjYhHtl(Iy8ekPsTYbv4pA6bvOFWzSyAYD4clludlguzhqh8oSEq9B6XnfcQhDYs9csDmBOulqQBeNTzxYKkvmkDC9YEs4LaHkkYBPwGuJIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMajJV8M4jOi(JGUKRsTaP(ZCSttNCjYhHtl(Iy8ekPKMNa1RsDHuBOulqQ)mh700jq)GZyX0KBsZtG6vPELcPU83bv4pA6bv2y(WrtpCHLf6HfdQSdOdEhwpOc)rtpOYgZhoA6bvQFC3iIhMAdQOiwlPsfJshxVSNK6bVWfOiwlPsfJshxVSNKjOiUEWlCqL6h3nI4HPZjVPWXb14dQFtpUPqq9OtwQxqQJzdLAbsDJ4Sn7sMuPIrPJRx2tcVeiurrEl1cK6pZXonDc0p4mwmn5M08eOEvQlKAdLAbsTbsTbsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0btar8eueV5beRulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWeiz8L3epbfXFe0LCvQvwQvwQfi1OiwlPrCgNwSyAYnzNMUuRC4clhJdlguzhqh8oSEq9B6XnfcQgi1FMJDA6eOFWzSyAYnP5jq9QuVGul0esPwbfK6pZXonDc0p4mwmn5M08eOEvQxPqQJzPwzPwGu)zo2PPtUe5JWPfFrmEcLusZtG6vPUqQnuQfi1gi1Oiwlb6hCg)rqxYK6bVWs9kfsTrOPa6GjqY4lVjEckI)iOl5QulqQnqQnqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6KgXzCAXIPj3KMNa1Rs9kfsD5VLAbs9N5yNMob6hCglMMCtAEcuVk1li1cPuRSuRGcsTbsDmi1hmy)inIZ40IfttUjSdOdEl1cK6pZXonDc0p4mwmn5M08eOEvQxqQfsPwzPwbfK6pZXonDc0p4mwmn5M08eOEvQxPqQl)TuRSuRCqf(JMEqDs7o7koT4l7j7x4clhVHHfdQSdOdEhwpO(n94Mcb1pZXonDYLiFeoT4lIXtOKsAEcuVk1li1gHMcOdM0v8eueV5beRulqQ)mh700jq)GZyX0KBsZtG6vPEbP2i0uaDWKUINGI4npGyLAbsTbs9bd2psJ4moTyX0KBc7a6G3sTaP(ZCSttN0ioJtlwmn5M08eOEvQxPqQl)TuRGcs9bd2psJ4moTyX0KBc7a6G3sTaP(ZCSttN0ioJtlwmn5M08eOEvQxqQncnfqhmPR4jOiEZdiwPwbfK6yqQpyW(rAeNXPflMMCtyhqh8wQvwQfi1Oiwlb6hCg)rqxYK6bVWs9kfsTrOPa6GjqY4lVjEckI)iOl5QulqQ3mkI1sUe5JWPfFrmEcLuYon9Gk8hn9GAdBk4hUkcTWHlSC8XhwmOYoGo4Dy9G630JBkeu)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAdKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWeiz8L3epbfXFe0LCvQfi1gi1gi1hmy)inIZ40IfttUjSdOdEl1cK6pZXonDsJ4moTyX0KBsZtG6vPELcPU83sTaP(ZCSttNa9doJfttUjnpbQxL6fKAJqtb0btU8M4jOiEZdiwPwzPwbfKAdK6yqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoyYL3epbfXBEaXk1kl1kOGu)zo2PPtG(bNXIPj3KMNa1Rs9kfsD5VLALLALdQWF00dQnSPGF4Qi0chUWYXleHfdQSdOdEhwpO(n94Mcb1pZXonDc0p4mwmn5M08eOEvQlKAdLAbsTbsTbsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0btar8eueV5beRulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWeiz8L3epbfXFe0LCvQvwQvwQfi1OiwlPrCgNwSyAYnzNMUuRCqf(JMEqTHnf8dxfHw4Wfwo(yoSyqLDaDW7W6b1VPh3uiO(zo2PPtG(bNXIPj3KMNa1RsDHuBOulqQnqQnqQnqQ)mh700jxI8r40IVigpHskP5jq9QuVGuBeAkGoyciINGI4npGyLAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlSuRSuRGcsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuJIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMajJV8M4jOi(JGUKRsTYsTYsTaPgfXAjnIZ40IfttUj700LALdQWF00dQBgUi0SDoCHLJxOfwmOYoGo4Dy9G630JBkeurrSwc0p4m(JGUKj1dEHL6vkKAJqtb0btGKXxEt8eue)rqxYvPwGuBGuBGuFWG9J0ioJtlwmn5MWoGo4TulqQ)mh700jnIZ40IfttUjnpbQxL6vkK6YFl1cK6pZXonDc0p4mwmn5M08eOEvQxqQncnfqhm5YBINGI4npGyLALLAfuqQnqQJbP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtG(bNXIPj3KMNa1Rs9csTrOPa6GjxEt8eueV5beRuRSuRGcs9N5yNMob6hCglMMCtAEcuVk1Rui1L)wQvoOc)rtpOEjYhHtl(Iy8ekPHlSC8czyXGk7a6G3H1dQFtpUPqq1aP2aP(ZCSttNCjYhHtl(Iy8ekPKMNa1Rs9csTrOPa6GjGiEckI38aIvQfi1Oiwlb6hCg)rqxYK6bVWsDHuJIyTeOFWz8hbDjtMGI46bVWsTYsTcki1gi1FMJDA6Klr(iCAXxeJNqjL08eOEvQlKAdLAbsnkI1sG(bNXFe0LmPEWlSuVsHuBeAkGoycKm(YBINGI4pc6sUk1kl1kl1cKAueRL0ioJtlwmn5MSttpOc)rtpOc9doJfttUdxy54xkHfdQSdOdEhwpO(n94McbvueRL0ioJtlwmn5MSttxQfi1gi1gi1FMJDA6Klr(iCAXxeJNqjL08eOEvQxqQfcdLAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlSuRSuRGcsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuJIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMajJV8M4jOi(JGUKRsTYsTYsTaP2aP(ZCSttNa9doJfttUjnpbQxL6fK64fsPwbfK6nJIyTKlr(iCAXxeJNqjLGik1khuH)OPhuBeNXPflMMChUWYXludlguzhqh8oSEq9B6XnfcQOiwlzZWfHMTZeerPwGuVzueRLCjYhHtl(Iy8ekPeerPwGuVzueRLCjYhHtl(Iy8ekPKMNa1Rs9kfsnkI1seBUY(Z40INuFtMGI46bVWs9swPg(JMob6hCgJoG6ryf5h5y8rNCqf(JMEqvS5k7pJtlEs9D4clhVqpSyqLDaDW7W6b1VPh3uiOIIyTKndxeA2otqeLAbsTbsTbs9bd2psZ10b)zc7a6G3sTaPg(JAKXSZtkxL6vKAHMuRSuRGcsn8h1iJzNNuUk1Ri1cPuRCqf(JMEqf6hCgJoG6fUWYXhJdlguH)OPhuRiIC7PriOYoGo4Dy9WfwwimmSyqLDaDW7W6b1VPh3uiOIIyTeOFWz8hbDjtQh8cl1fsTHbv4pA6bvOFWzC2OHlSSqeFyXGk7a6G3H1dQFtpUPqq1aPUzBZ1iaDWsTcki1XGuF0xyQxk1kl1cKAueRLa9doJ)iOlzs9GxyPUqQrrSwc0p4m(JGUKjtqrC9Gx4Gk8hn9GQZxe34JNIC9cxyzHqiclguzhqh8oSEq9B6XnfcQOiwlb6hCglMMCt2PPl1cKAueRL0ioJtlwmn5MSttxQfi1BgfXAjxI8r40IVigpHskzNMUulqQ)mh700jq)GZyX0KBsZtG6vPEbP2qPwGu)zo2PPtUe5JWPfFrmEcLusZtG6vPEbP2qPwGuBGuhds9bd2psJ4moTyX0KBc7a6G3sTcki1gi1hmy)inIZ40IfttUjSdOdEl1cK6pZXonDsJ4moTyX0KBsZtG6vPEbP2qPwzPw5Gk8hn9GAnIApQxIfttUdxyzHiMdlguzhqh8oSEq9B6XnfcQOiwl5hm0pupQxsAg(tQfi1nIZ2Slzc0p4mM6wQtVyj8sGqff5TulqQpyW(rGP4GAPpC00jSdOdEl1cKA4pQrgZopPCvQxrQJXbv4pA6bvOFWz8KwR0bxdxyzHqOfwmOYoGo4Dy9G630JBkeurrSwYpyOFOEuVK0m8NulqQBeNTzxYeOFWzm1TuNEXs4LaHkkYBPwGud)rnYy25jLRs9ks9sjOc)rtpOc9doJN0ALo4A4clleczyXGk7a6G3H1dQFtpUPqqffXAjq)GZ4pc6sMup4fwQxrQrrSwc0p4m(JGUKjtqrC9Gx4Gk8hn9Gk0p4mMvuCKvA6HlSSqSuclguzhqh8oSEq9B6XnfcQOiwlb6hCg)rqxYK6bVWsDHuJIyTeOFWz8hbDjtMGI46bVWsTaPwSzJ4YFtINa9doJrHUHsoOc)rtpOc9doJzffhzLME4cllec1WIbv2b0bVdRhu)MECtHGkkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlCqf(JMEqf6hCgJcDdLC4cllec9WIbvQFC3iIhMAdQtWbI4Flui0fYGk1pUBeXdtNtEtHJdQXhuH)OPhuzJ5dhn9Gk7a6G3H1dx4cQB2ciJlSyy54dlguzhqh8oSEq9B6XnfcQh0L8r2mkI1sEOEuVK0m8xqf(JMEq9te)4UkYJr4clleHfdQSdOdEhwpOc)rtpO(WyGH)OPJh06fuh06HDyYb1Ae08g)7A4clhZHfdQSdOdEhwpOc)rtpO(WyGH)OPJh06fuh06HDyYbvUwz)5A4cll0clguzhqh8oSEq9B6XnfcQWFuJmMDEs5QuVGulebv4pA6b1hgdm8hnD8GwVG6GwpSdtoOcjhUWYczyXGk7a6G3H1dQFtpUPqq1i0uaDWKiWiJtr25TuVsHuByqf(JMEq9HXad)rthpO1lOoO1d7WKdQPi7ChUWYlLWIbv2b0bVdRhu)MECtHGALVJ6LvcmXvryk1fsD8bv4pA6b1hgdm8hnD8GwVG6GwpSdtoOctCveMHlSSqnSyqLDaDW7W6bv4pA6b1hgdm8hnD8GwVG6GwpSdtoO(zo2PPxdxyzHEyXGk7a6G3H1dQFtpUPqq1i0uaDWel1HbgfPDPUqQnmOc)rtpO(WyGH)OPJh06fuh06HDyYb1op4OPhUWYX4WIbv2b0bVdRhu)MECtHGQrOPa6GjwQddmks7sDHuhFqf(JMEq9HXad)rthpO1lOoO1d7WKdQwQddmks7HlSC8ggwmOYoGo4Dy9Gk8hn9G6dJbg(JMoEqRxqDqRh2HjhuNPrEY(fUWfufB(ZjkCHfdlhFyXGk7a6G3H1dQPyqT5kFbv4pA6bvJqtb0bhuncn2HjhufBwezmWSXmOUzlGmUGQHHlSSqewmOYoGo4Dy9GAkguR8fuH)OPhuncnfqhCq1imq4GA8b1VPh3uiOAeAkGoyIyZIiJbMnMsDHuBOulqQBeNTzxYKkvmkDC9YEs4LaHkkYBPwGud)rnYy25jLRs9csTqeuncn2HjhufBwezmWSXmCHLJ5WIbv2b0bVdRhutXGALVGk8hn9GQrOPa6GdQgHbchuJpO(n94McbvJqtb0bteBwezmWSXuQlKAdLAbsDJ4Sn7sMuPIrPJRx2tcVeiurrEl1cK6pnYo4hX5VZr2BPwGud)rnYy25jLRs9csD8bvJqJDyYbvXMfrgdmBmdxyzHwyXGk7a6G3H1dQPyqTYxqf(JMEq1i0uaDWbvJWaHdQXhu)MECtHGQrOPa6GjInlImgy2yk1fsTHsTaPUrC2MDjtQuXO0X1l7jHxceQOiVLAbs9Ngzh8J40YOdBboOAeASdtoOk2SiYyGzJz4cllKHfdQSdOdEhwpOMIb1MR8fuH)OPhuncnfqhCq1i0yhMCqncmY4uKDEhu3Sfqgxq1WWfwEPewmOYoGo4Dy9GAkguR8fuH)OPhuncnfqhCq1imq4GA8b1VPh3uiOAeAkGoyseyKXPi78wQlKAdLAbsn8h1iJzNNuUk1li1crq1i0yhMCqncmY4uKDEhUWYc1WIbv2b0bVdRhutXGALVGk8hn9GQrOPa6GdQgHbchuJpO(n94McbvJqtb0btIaJmofzN3sDHuBOulqQncnfqhmrSzrKXaZgtPUqQJpOAeASdtoOgbgzCkYoVdxyzHEyXGk7a6G3H1dQPyqTYxqf(JMEq1i0uaDWbvJWaHdQgguncn2HjhuTuhgyuK2dxy5yCyXGk7a6G3H1dQPyqT5kFbv4pA6bvJqtb0bhuncn2Hjhu7kEckI38aInOUzlGmUGQqgUWYXByyXGk7a6G3H1dQPyqT5kFbv4pA6bvJqtb0bhuncn2Hjhubr8eueV5beBqDZwazCb14nmCHLJp(WIbv2b0bVdRhutXGAZv(cQWF00dQgHMcOdoOAeASdtoO2PiEckI38aInOUzlGmUGQqyy4clhVqewmOYoGo4Dy9GAkguBUYxqf(JMEq1i0uaDWbvJqJDyYb1lVjEckI38aInOUzlGmUGQqgUWYXhZHfdQSdOdEhwpOMIb1kFbv4pA6bvJqtb0bhuncdeoOgZb1VPh3uiOAeAkGoyYL3epbfXBEaXk1fsTqk1cK6gXzB2LmztRpvCqDOJf)5Cc(MWlbcvuK3bvJqJDyYb1lVjEckI38aInCHLJxOfwmOYoGo4Dy9GAkguR8fuH)OPhuncnfqhCq1imq4GA8czq9B6XnfcQgHMcOdMC5nXtqr8MhqSsDHulKsTaP(tJSd(rCAz0HTahuncn2HjhuV8M4jOiEZdi2WfwoEHmSyqLDaDW7W6b1umOw5lOc)rtpOAeAkGo4GQryGWb14fYG630JBkeuncnfqhm5YBINGI4npGyL6cPwiLAbs9N(gHEeOFWzSyNBAzSe2b0bVLAbsn8h1iJzNNuUk1Ri1XCq1i0yhMCq9YBINGI4npGydxy54xkHfdQSdOdEhwpOMIb1kFbv4pA6bvJqtb0bhuncdeoOgZggu)MECtHGQrOPa6GjxEt8eueV5beRuxi1cPulqQ5AL9NjgPvA640If52Y)rtNmPE2bvJqJDyYb1lVjEckI38aInCHLJxOgwmOYoGo4Dy9GAkguBUYxqf(JMEq1i0uaDWbvJqJDyYbvuOBOKXtWbS4Fb1nBbKXfufQggUWYXl0dlguzhqh8oSEqnfdQv(cQWF00dQgHMcOdoOAegiCqvOzyq9B6XnfcQgHMcOdMGcDdLmEcoGf)tQlKAHQHsTaP(tJSd(rCAz0HTahuncn2HjhurHUHsgpbhWI)fUWYXhJdlguzhqh8oSEqnfdQnx5lOc)rtpOAeAkGo4GQrOXom5GkiINuNorM4j4aw8VG6MTaY4cQXSHHlSSqyyyXGk7a6G3H1dQPyqTYxqf(JMEq1i0uaDWbvJWaHdQcPHb1VPh3uiOAeAkGoyciINuNorM4j4aw8pPUqQJzdLAbsDJ4Sn7sMSP1NkoOo0XI)CobFt4LaHkkY7GQrOXom5GkiINuNorM4j4aw8VWfwwiIpSyqLDaDW7W6b1umOw5lOc)rtpOAeAkGo4GQryGWbvH0WG630JBkeuncnfqhmbeXtQtNit8eCal(Nuxi1XSHsTaPUrC2MDjtkBADelM(0FWeEjqOII8oOAeASdtoOcI4j1PtKjEcoGf)lCHLfcHiSyqLDaDW7W6b1umO2CLVGk8hn9GQrOPa6GdQgHg7WKdQxEt8eue)rqxY1G6MTaY4cQcr4clleXCyXGk7a6G3H1dQPyqT5kFbv4pA6bvJqtb0bhuncn2HjhuHKXxEt8eue)rqxY1G6MTaY4cQcr4cllecTWIbv2b0bVdRhutXGALVGk8hn9GQrOPa6GdQgHbchuJpO(n94McbvJqtb0btIaJmofzN3sDHuBOulqQR8DuVSsGjUkctPUqQJpOAeASdtoOgbgzCkYoVdxyzHqidlguzhqh8oSE4cllelLWIbv2b0bVdRhUWYcHqnSyqLDaDW7W6HlSSqi0dlguH)OPhuRiZz6yOFWzSfM0bf6Gk7a6G3H1dxyzHighwmOc)rtpOc9doJP(XJb)xqLDaDW7W6HlSCmByyXGk8hn9G6NUqXinJNGd4sEguzhqh8oSE4clhZXhwmOYoGo4Dy9WfwoMfIWIbv4pA6b1jT7SX0juYbv2b0bVdRhUWYXCmhwmOYoGo4Dy9G630JBkeuncnfqhmrSzrKXaZgtPELcP2WGk8hn9GQTZ6HMJlCHLJzHwyXGk7a6G3H1dQFtpUPqq1i0uaDWeXMfrgdmBmL6fKAddQWF00dQSX8HJME4cxq9ZCSttVgwmSC8HfdQSdOdEhwpO(n94Mcb1gXzB2LmPSP1rSy6t)bt4LaHkkYBPwGu)zo2PPtG(bNXIPj3KMNa1Rs9csDmBOulqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAdKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWKlVjEckI)iOl5QulqQnqQnqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6KgXzCAXIPj3KMNa1Rs9kfsD5VLAbs9N5yNMob6hCglMMCtAEcuVk1li1gHMcOdMC5nXtqr8MhqSsTYsTcki1gi1XGuFWG9J0ioJtlwmn5MWoGo4TulqQ)mh700jq)GZyX0KBsZtG6vPEbP2i0uaDWKlVjEckI38aIvQvwQvqbP(ZCSttNa9doJfttUjnpbQxL6vkK6YFl1kl1khuH)OPhuTDwpSNgHWfwwiclguzhqh8oSEq9B6XnfcQnIZ2SlzsztRJyX0N(dMWlbcvuK3sTaP(ZCSttNa9doJfttUjnpbQxL6cP2qPwGuBGuhds9bd2pc7dAz0XoVjSdOdEl1kOGuBGuFWG9JW(GwgDSZBc7a6G3sTaPEcoqe)tQxOqQfQgk1kl1kl1cKAdKAdK6pZXonDYLiFeoT4lIXtOKsAEcuVk1li1XBOulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPUqQnuQvwQvwQfi1OiwlPrCgNwSyAYnzNMUulqQNGdeX)K6fkKAJqtb0btar8K60jYepbhWI)fuH)OPhuTDwpSNgHWfwoMdlguzhqh8oSEq9B6XnfcQnIZ2SlzYMwFQ4G6qhl(Z5e8nHxceQOiVLAbs9N5yNMobfXAXBA9PIdQdDS4pNtW3KMHDSsTaPgfXAjBA9PIdQdDS4pNtW3yBN1JSttxQfi1gi1Oiwlb6hCglMMCt2PPl1cKAueRL0ioJtlwmn5MSttxQfi1BgfXAjxI8r40IVigpHskzNMUuRSulqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAdKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWKlVjEckI)iOl5QulqQnqQnqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6KgXzCAXIPj3KMNa1Rs9kfsD5VLAbs9N5yNMob6hCglMMCtAEcuVk1li1gHMcOdMC5nXtqr8MhqSsTYsTcki1gi1XGuFWG9J0ioJtlwmn5MWoGo4TulqQ)mh700jq)GZyX0KBsZtG6vPEbP2i0uaDWKlVjEckI38aIvQvwQvqbP(ZCSttNa9doJfttUjnpbQxL6vkK6YFl1kl1khuH)OPhuTDwp0CCHlSSqlSyqLDaDW7W6b1VPh3uiO2ioBZUKjBA9PIdQdDS4pNtW3eEjqOII8wQfi1FMJDA6eueRfVP1NkoOo0XI)CobFtAg2Xk1cKAueRLSP1NkoOo0XI)CobFJT0Mj700LAbsTyZgXL)MepX2z9qZXfuH)OPhuT0MXOdOEHlSSqgwmOYoGo4Dy9G630JBkeu)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPELcP2i0uaDWKlVjEckI)iOl5QulqQ)mh700jq)GZyX0KBsZtG6vPELcPU83bv4pA6b1jT7SR40IVSNSFHlS8sjSyqLDaDW7W6b1VPh3uiO(zo2PPtG(bNXIPj3KMNa1RsDHuBOulqQnqQJbP(Gb7hH9bTm6yN3e2b0bVLAfuqQnqQpyW(ryFqlJo25nHDaDWBPwGupbhiI)j1lui1cvdLALLALLAbsTbsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0btar8eueV5beRulqQrrSwc0p4m(JGUKj1dEHL6cPgfXAjq)GZ4pc6sMmbfX1dEHLALLAfuqQnqQ)mh700jxI8r40IVigpHskP5jq9Quxi1gk1cKAueRLa9doJ)iOlzs9GxyPUqQnuQvwQvwQfi1OiwlPrCgNwSyAYnzNMUulqQNGdeX)K6fkKAJqtb0btar8K60jYepbhWI)fuH)OPhuN0UZUItl(YEY(fUWYc1WIbv2b0bVdRhu)MECtHG6N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuJIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMC5nXtqr8hbDjxLAbs9N5yNMob6hCglMMCtAEcuVk1Rui1L)oOc)rtpOUz4IqZ25WfwwOhwmOYoGo4Dy9G630JBkeu)mh700jq)GZyX0KBsZtG6vPUqQnuQfi1gi1XGuFWG9JW(GwgDSZBc7a6G3sTcki1gi1hmy)iSpOLrh78MWoGo4TulqQNGdeX)K6fkKAHQHsTYsTYsTaP2aP2aP(ZCSttNCjYhHtl(Iy8ekPKMNa1Rs9csD8gk1cKAueRLa9doJ)iOlzs9GxyPUqQrrSwc0p4m(JGUKjtqrC9GxyPwzPwbfKAdK6pZXonDYLiFeoT4lIXtOKsAEcuVk1fsTHsTaPgfXAjq)GZ4pc6sMup4fwQlKAdLALLALLAbsnkI1sAeNXPflMMCt2PPl1cK6j4ar8pPEHcP2i0uaDWeqepPoDImXtWbS4Fbv4pA6b1ndxeA2ohUWYX4WIbv2b0bVdRhu)MECtHG6N5yNMo5sKpcNw8fX4jusjnpbQxL6fKAJqtb0bt6kEckI38aIvQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoysxXtqr8MhqSsTaP2aP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtAeNXPflMMCtAEcuVk1Rui1L)wQvqbP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtAeNXPflMMCtAEcuVk1li1gHMcOdM0v8eueV5beRuRGcsDmi1hmy)inIZ40IfttUjSdOdEl1kl1cKAueRLa9doJ)iOlzs9GxyPEbPwiKAbs9MrrSwYLiFeoT4lIXtOKs2PPhuH)OPhuBytb)WvrOfoCHLJ3WWIbv2b0bVdRhu)MECtHG6N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuJIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMC5nXtqr8hbDjxLAbs9N5yNMob6hCglMMCtAEcuVk1Rui1L)oOc)rtpO2WMc(HRIqlC4clhF8HfdQSdOdEhwpO(n94Mcb1pZXonDc0p4mwmn5M08eOEvQlKAdLAbsTbsTbsDmi1hmy)iSpOLrh78MWoGo4TuRGcsTbs9bd2pc7dAz0XoVjSdOdEl1cK6j4ar8pPEHcPwOAOuRSuRSulqQnqQnqQ)mh700jxI8r40IVigpHskP5jq9QuVGuBeAkGoyciINGI4npGyLAbsnkI1sG(bNXFe0LmPEWlSuxi1Oiwlb6hCg)rqxYKjOiUEWlSuRSuRGcsTbs9N5yNMo5sKpcNw8fX4jusjnpbQxL6cP2qPwGuJIyTeOFWz8hbDjtQh8cl1fsTHsTYsTYsTaPgfXAjnIZ40IfttUj700LAbs9eCGi(NuVqHuBeAkGoyciINuNorM4j4aw8pPw5Gk8hn9GAdBk4hUkcTWHlSC8cryXGk7a6G3H1dQFtpUPqq9ZCSttNa9doJfttUjnpbQxL6vKAH0qPwGuZ1k7ptmsR00XPflYTL)JMozs9SdQWF00dQxI8r40IVigpHsA4clhFmhwmOYoGo4Dy9G630JBkeurrSwc0p4m(JGUKj1dEHL6vkKAJqtb0btU8M4jOi(JGUKRsTaP(Gb7hPrCgNwSyAYnHDaDWBPwGu)zo2PPtAeNXPflMMCtAEcuVk1Rui1L)wQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoyYL3epbfXBEaXk1cK6pnYo4hr4yBk4sTaP(ZCSttN0WMc(HRIqlmP5jq9QuVsHul0dQWF00dQxI8r40IVigpHsA4clhVqlSyqLDaDW7W6b1VPh3uiOIIyTeOFWz8hbDjtQh8cl1Rui1gHMcOdMC5nXtqr8hbDjxLAbs9bd2psJ4moTyX0KBc7a6G3sTaP(ZCSttN0ioJtlwmn5M08eOEvQxPqQl)TulqQ)mh700jq)GZyX0KBsZtG6vPEbP2i0uaDWKlVjEckI38aIvQfi1XGu)Pr2b)ichBtbpOc)rtpOEjYhHtl(Iy8ekPHlSC8czyXGk7a6G3H1dQFtpUPqqffXAjq)GZ4pc6sMup4fwQxPqQncnfqhm5YBINGI4pc6sUk1cK6yqQpyW(rAeNXPflMMCtyhqh8wQfi1FMJDA6eOFWzSyAYnP5jq9QuVGuBeAkGoyYL3epbfXBEaXguH)OPhuVe5JWPfFrmEcL0Wfwo(LsyXGk7a6G3H1dQFtpUPqqffXAjq)GZ4pc6sMup4fwQxPqQncnfqhm5YBINGI4pc6sUk1cK6pZXonDc0p4mwmn5M08eOEvQxPqQl)Dqf(JMEq9sKpcNw8fX4jusdxy54fQHfdQSdOdEhwpO(n94McbvdK6yqQpyW(ryFqlJo25nHDaDWBPwbfKAdK6dgSFe2h0YOJDEtyhqh8wQfi1tWbI4Fs9cfsTq1qPwzPwzPwGu)zo2PPtUe5JWPfFrmEcLusZtG6vPEbP2i0uaDWeqepbfXBEaXk1cKAueRLa9doJ)iOlzs9GxyPUqQrrSwc0p4m(JGUKjtqrC9GxyPwGuJIyTKgXzCAXIPj3KDA6sTaPEcoqe)tQxOqQncnfqhmbeXtQtNit8eCal(xqf(JMEqf6hCglMMChUWYXl0dlguzhqh8oSEq9B6XnfcQOiwlPrCgNwSyAYnzNMUulqQ)mh700jxI8r40IVigpHskP5jq9QuVGuBeAkGoysNI4jOiEZdiwPwGuJIyTeOFWz8hbDjtQh8cl1fsnkI1sG(bNXFe0LmzckIRh8cl1cKAdK6pZXonDc0p4mwmn5M08eOEvQxqQJxiLAfuqQ3mkI1sUe5JWPfFrmEcLucIOuRCqf(JMEqTrCgNwSyAYD4clhFmoSyqLDaDW7W6b1VPh3uiOIIyTeOFWz8hbDjtQh8cl1fsTHsTaP(tJSd(reo2McEqf(JMEqvS5k7pJtlEs9D4clleggwmOYoGo4Dy9G630JBkeu3mkI1sUe5JWPfFrmEcLucIOulqQJbP(tJSd(reo2McEqf(JMEqvS5k7pJtlEs9D4cxqTgbnVX)UgwmSC8HfdQSdOdEhwpO(n94McbvdK6dgSFe2h0YOJDEtyhqh8wQfi1tWbI4Fs9kfsTq3qPwGupbhiI)j1lui1lfHuQvwQvqbP2aPogK6dgSFe2h0YOJDEtyhqh8wQfi1tWbI4Fs9kfsTqxiLALdQWF00dQtWbCjpdxyzHiSyqLDaDW7W6b1VPh3uiOIIyTeOFWzSyAYnbrmOc)rtpOIuzm94znCHLJ5WIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3eeXGk8hn9GQyE00dxyzHwyXGk7a6G3H1dQFtpUPqqTrC2MDjtoEkMnmWMqls4LaHkkYBPwGuJIyTewXiaPE00jiIbv4pA6b1JozSj0IHlSSqgwmOYoGo4Dy9G630JBkeurrSwc0p4mwmn5MSttxQfi1OiwlPrCgNwSyAYnzNMUulqQ3mkI1sUe5JWPfFrmEcLuYon9Gk8hn9G6GwgDvSqXi7Yj7x4clVuclguzhqh8oSEq9B6XnfcQOiwlb6hCglMMCt2PPl1cKAueRL0ioJtlwmn5MSttxQfi1BgfXAjxI8r40IVigpHskzNMEqf(JMEqffkXPfFn9fUgUWYc1WIbv2b0bVdRhu)MECtHGkkI1sG(bNXIPj3eeXGk8hn9Gkk3vUfM6LHlSSqpSyqLDaDW7W6b1VPh3uiOIIyTeOFWzSyAYnbrmOc)rtpOIoYCJTiDSHlSCmoSyqLDaDW7W6b1VPh3uiOIIyTeOFWzSyAYnbrmOc)rtpOAPnJoYChUWYXByyXGk7a6G3H1dQFtpUPqqffXAjq)GZyX0KBcIyqf(JMEqf8NRxdd8dJr4cxqDMg5j7xyXWYXhwmOYoGo4Dy9G630JBkeuNPrEY(r206b(Zs9cfsD8gguH)OPhurhux4WfwwiclguH)OPhufBUY(Z40INuFhuzhqh8oSE4clhZHfdQSdOdEhwpO(n94Mcb1zAKNSFKnTEG)SuVIuhVHbv4pA6bvOFWz8KwR0bxdxyzHwyXGk8hn9Gk0p4moB0Gk7a6G3H1dxyzHmSyqf(JMEq1sBgJoG6fuzhqh8oSE4cxq1sDyGrrApSyy54dlguzhqh8oSEqf(JMEqf6hCgpP1kDW1G6hbupOgFq9B6XnfcQOiwl5hm0pupQxsAg(lCHLfIWIbv4pA6bvOFWzm6aQxqLDaDW7W6HlSCmhwmOc)rtpOc9doJrHUHsoOYoGo4Dy9WfUWfunYDLMEyzHWqHWW4nuiI5GQj0o1lRb1yKxYxYSCmILfkYsvQL6fJyPMofZ(KAB2sDm15bhn9ysQBEjqOnVL6AozPgqUCchVL6pc8sUsKXTKqDwQJFPk1lPPBK7J3sDm9Pr2b)ilDc7a6G3XKuFPuhtFAKDWpYspMKAdIxrLjY4wsOol1cXsvQxst3i3hVL6y6tJSd(rw6e2b0bVJjP(sPoM(0i7GFKLEmj1geVIktKXTKqDwQf6lvPEjnDJCF8wQJPpnYo4hzPtyhqh8oMK6lL6y6tJSd(rw6XKuBq8kQmrg3sc1zPwie6lvPEjnDJCF8wQvPZLuPUgRFGIsTqzK6lL6LeeqQ3uJ0knDPof5gUSLAdwvzP2G4vuzImozCXiVKVKz5yelluKLQul1lgXsnDkM9j12SL6ysS5pNOWftsDZlbcT5TuxZjl1aYLt44Tu)rGxYvImULeQZsDmVuL6L00nY9XBPoM(0i7GFKLoHDaDW7ysQVuQJPpnYo4hzPhtsTbXROYezCljuNLAH2svQxst3i3hVL6y6tJSd(rw6e2b0bVJjP(sPoM(0i7GFKLEmj1geVIktKXTKqDwQJxOTuL6L00nY9XBPoM(0i7GFKLoHDaDW7ysQVuQJPpnYo4hzPhtsTbXROYezCljuNL64f6lvPEjnDJCF8wQJPpnYo4hzPtyhqh8oMK6lL6y6tJSd(rw6XKuBq8kQmrgNmUyKxYxYSCmILfkYsvQL6fJyPMofZ(KAB2sDm9zo2PPxJjPU5LaH28wQR5KLAa5YjC8wQ)iWl5krg3sc1zPo(yEPk1lPPBK7J3sDm9Pr2b)ilDc7a6G3XKuFPuhtFAKDWpYspMKAdIxrLjY4wsOol1Xl0wQs9sA6g5(4TuhtFAKDWpYsNWoGo4Dmj1xk1X0Ngzh8JS0JjP2G4vuzImULeQZsD8X4LQuVKMUrUpEl1X0Ngzh8JS0jSdOdEhts9LsDm9Pr2b)il9ysQniEfvMiJBjH6SulegUuL6L00nY9XBPoM(0i7GFKLoHDaDW7ysQVuQJPpnYo4hzPhtsTbXROYezCY4IrmfZ(4TuhF8sn8hnDPEqRxLiJlOcixu2bvv6ezahn9L0gSxqvStlDWbvHcsTq5GswQxY7hCwgNqbPwOS)LOCl1cHqtjPwimuimugNmoHcs9sgEMgzP2i0uaDWeyIRIWuQPUuBbJzl1PvQR8DuVSsGjUkctP2GpIFHL6ytKwQRI8l1P4rtVQmrgNqbPwOK4goEl1u)42HHuhb(Eq9sPoTsTrOPa6GjrGrgNISZBP(sPgLL64LAZi2L6kFh1lReyIRIWuQlK64jY4KXb)rtVseB(ZjkCRvSQrOPa6GvYHjxi2SiYyGzJPsPyrZv(uAZwazCfgkJd(JMELi28Ntu4wRyvJqtb0bRKdtUqSzrKXaZgtLsXIkFkzegiCr8krTfgHMcOdMi2SiYyGzJzHHcAeNTzxYKkvmkDC9YEs4LaHkkYBbWFuJmMDEs56ccHmo4pA6vIyZForHBTIvncnfqhSsom5cXMfrgdmBmvkflQ8PKryGWfXRe1wyeAkGoyIyZIiJbMnMfgkOrC2MDjtQuXO0X1l7jHxceQOiVf8Pr2b)io)DoYEtyhqh8wa8h1iJzNNuUUq8Y4G)OPxjIn)5efU1kw1i0uaDWk5WKleBwezmWSXuPuSOYNsgHbcxeVsuBHrOPa6GjInlImgy2ywyOGgXzB2LmPsfJshxVSNeEjqOII8wWNgzh8J40YOdBbMWoGo4Tmo4pA6vIyZForHBTIvncnfqhSsom5IiWiJtr25TsPyrZv(uAZwazCfgkJd(JMELi28Ntu4wRyvJqtb0bRKdtUicmY4uKDERukwu5tjJWaHlIxjQTWi0uaDWKiWiJtr25DHHcG)Ogzm78KY1feczCWF00ReXM)CIc3AfRAeAkGoyLCyYfrGrgNISZBLsXIkFkzegiCr8krTfgHMcOdMebgzCkYoVlmuGrOPa6GjInlImgy2yweVmo4pA6vIyZForHBTIvncnfqhSsom5cl1HbgfPDLsXIkFkzegiCHHY4G)OPxjIn)5efU1kw1i0uaDWk5WKl6kEckI38aIvPuSO5kFkTzlGmUcHugh8hn9krS5pNOWTwXQgHMcOdwjhMCbiINGI4npGyvkflAUYNsB2ciJRiEdLXb)rtVseB(ZjkCRvSQrOPa6GvYHjx0PiEckI38aIvPuSO5kFkTzlGmUcHWqzCWF00ReXM)CIc3AfRAeAkGoyLCyYfxEt8eueV5beRsPyrZv(uAZwazCfcPmo4pA6vIyZForHBTIvncnfqhSsom5IlVjEckI38aIvPuSOYNsgHbcxeZkrTfgHMcOdMC5nXtqr8MhqSfcPGgXzB2LmztRpvCqDOJf)5Cc(MWlbcvuK3Y4G)OPxjIn)5efU1kw1i0uaDWk5WKlU8M4jOiEZdiwLsXIkFkzegiCr8cPsuBHrOPa6GjxEt8eueV5beBHqk4tJSd(rCAz0HTatyhqh8wgh8hn9krS5pNOWTwXQgHMcOdwjhMCXL3epbfXBEaXQukwu5tjJWaHlIxivIAlmcnfqhm5YBINGI4npGylesbF6Be6rG(bNXIDUPLXsyhqh8wa8h1iJzNNuUUsmlJd(JMELi28Ntu4wRyvJqtb0bRKdtU4YBINGI4npGyvkflQ8PKryGWfXSHkrTfgHMcOdMC5nXtqr8MhqSfcPaUwz)zIrALMooTyrUT8F00jtQNTmo4pA6vIyZForHBTIvncnfqhSsom5cuOBOKXtWbS4FkLIfnx5tPnBbKXviunugh8hn9krS5pNOWTwXQgHMcOdwjhMCbk0nuY4j4aw8pLsXIkFkzegiCHqZqLO2cJqtb0btqHUHsgpbhWI)viunuWNgzh8J40YOdBbMWoGo4Tmo4pA6vIyZForHBTIvncnfqhSsom5cqepPoDImXtWbS4FkLIfnx5tPnBbKXveZgkJd(JMELi28Ntu4wRyvJqtb0bRKdtUaeXtQtNit8eCal(NsPyrLpLmcdeUqinujQTWi0uaDWeqepPoDImXtWbS4FfXSHcAeNTzxYKnT(uXb1How8NZj4BcVeiurrElJd(JMELi28Ntu4wRyvJqtb0bRKdtUaeXtQtNit8eCal(NsPyrLpLmcdeUqinujQTWi0uaDWeqepPoDImXtWbS4FfXSHcAeNTzxYKYMwhXIPp9hmHxceQOiVLXb)rtVseB(ZjkCRvSQrOPa6GvYHjxC5nXtqr8hbDjxvkflAUYNsB2ciJRqiKXb)rtVseB(ZjkCRvSQrOPa6GvYHjxajJV8M4jOi(JGUKRkLIfnx5tPnBbKXvieY4G)OPxjIn)5efU1kw1i0uaDWk5WKlIaJmofzN3kLIfv(uYimq4I4vIAlmcnfqhmjcmY4uKDExyOGkFh1lReyIRIWSiEzCWF00ReXM)CIc3AfRAhqvyzCWF00ReXM)CIc3AfRAZClJd(JMELi28Ntu4wRyvaPCY(bhnDzCWF00ReXM)CIc3AfRc9doJTWKoOqlJd(JMELi28Ntu4wRyvOFWzm1pEm4)KXb)rtVseB(ZjkCRvS6NUqXinJNGd4sEkJd(JMELi28Ntu4wRy1QdI1O8W1dUQmo4pA6vIyZForHBTIvN0UZgtNqjlJd(JMELi28Ntu4wRyvBN1dnhNsuBHrOPa6GjInlImgy2yUsHHY4G)OPxjIn)5efU1kwLnMpC00vIAlmcnfqhmrSzrKXaZgZfmugNmo4pA611kw9te)4UkYJHsuBXbDjFKnJIyTKhQh1ljnd)jJd(JMEDTIvFymWWF00XdA9uYHjxuJGM34FxLXb)rtVUwXQpmgy4pA64bTEk5WKl4AL9NRY4G)OPxxRy1hgdm8hnD8GwpLCyYfqYkrTfWFuJmMDEs56ccHmo4pA611kw9HXad)rthpO1tjhMCrkYo3krTfgHMcOdMebgzCkYoVxPWqzCWF00RRvS6dJbg(JMoEqRNsom5cyIRIWujQTOY3r9YkbM4QimlIxgh8hn96AfR(WyGH)OPJh06PKdtU4ZCSttVkJd(JMEDTIvFymWWF00XdA9uYHjx05bhnDLO2cJqtb0btSuhgyuK2lmugh8hn96AfR(WyGH)OPJh06PKdtUWsDyGrrAxjQTWi0uaDWel1HbgfP9I4LXb)rtVUwXQpmgy4pA64bTEk5WKlMPrEY(jJtgh8hn9kPgbnVX)UUwXQivgpbhWL8ujQTWGdgSFe2h0YOJDEtyhqh8wWeCGi(3kfcDdfmbhiI)TqXsrivwbfmigoyW(ryFqlJo25nHDaDWBbtWbI4FRui0fsLLXb)rtVsQrqZB8VRRvSksLX0JNvLO2cueRLa9doJfttUjiIY4G)OPxj1iO5n(311kwvmpA6krTfOiwlb6hCglMMCtqeLXb)rtVsQrqZB8VRRvS6rNm2eArLO2IgXzB2Lm54Py2WaBcTiHxceQOiVfGIyTewXiaPE00jiIY4G)OPxj1iO5n(311kwDqlJUkwOyKD5K9tjQTafXAjq)GZyX0KBYonDbOiwlPrCgNwSyAYnzNMUGnJIyTKlr(iCAXxeJNqjLSttxgh8hn9kPgbnVX)UUwXQOqjoT4RPVWvLO2cueRLa9doJfttUj700fGIyTKgXzCAXIPj3KDA6c2mkI1sUe5JWPfFrmEcLuYonDzCWF00RKAe08g)76AfRIYDLBHPEPsuBbkI1sG(bNXIPj3eerzCWF00RKAe08g)76AfRIoYCJTiDSkrTfOiwlb6hCglMMCtqeLXb)rtVsQrqZB8VRRvSQL2m6iZTsuBbkI1sG(bNXIPj3eerzCWF00RKAe08g)76AfRc(Z1RHb(HXqjQTafXAjq)GZyX0KBcIOmozCWF00ReUwz)56AfRIoYCJtl(Iym78mwLO2IpZXonDYLiFeoT4lIXtOKsAEcuVwyOaueRLa9doJ)iOlzs9Gx4vkmcnfqhm5YBINGI4pc6sUk4ZCSttNa9doJfttUjnpbQxxPO83kOGLwgD4MNa1RR8zo2PPtG(bNXIPj3KMNa1RY4G)OPxjCTY(Z11kwfDK5gNw8fXy25zSkrTfFMJDA6eOFWzSyAYnP5jq9AHHcmigoyW(ryFqlJo25nHDaDWBfuWGdgSFe2h0YOJDEtyhqh8wWeCGi(3cfcvdvqHkFh1lReyIRIWSiELvwGbg8zo2PPtUe5JWPfFrmEcLusZtG61fmcnfqhmbeXtqr8MhqScmafXAjq)GZ4pc6sMup4fUafXAjq)GZ4pc6sMmbfX1dEHvqHkFh1lReyIRIWSiELvwbfm4ZCSttNCjYhHtl(Iy8ekPKMNa1RfgkafXAjq)GZ4pc6sMup4fUWqLvwakI1sAeNXPflMMCt2PPlycoqe)BHcJqtb0btar8K60jYepbhWI)jJd(JMELW1k7pxxRyvZShBJm1Xnxth8NvIAl(mh700jq)GZyX0KBsZtG61fkesdf8zo2PPtUe5JWPfFrmEcLusZtG61vkk)TaueRLa9doJ)iOlzs9Gx4vkmcnfqhm5YBINGI4pc6sUk4Gb7hPrCgNwSyAYnHDaDWBbFMJDA6KgXzCAXIPj3KMNa1RRuu(BbFMJDA6eOFWzSyAYnP5jq96cgHMcOdMC5nXtqr8MhqSY4G)OPxjCTY(Z11kw1m7X2itDCZ10b)zLO2IpZXonDYLiFeoT4lIXtOKsAEcuVwyOaueRLa9doJ)iOlzs9Gx4vkmcnfqhm5YBINGI4pc6sUk4ZCSttNa9doJfttUjnpbQxxPO83kOGLwgD4MNa1RR8zo2PPtG(bNXIPj3KMNa1RY4G)OPxjCTY(Z11kw1m7X2itDCZ10b)zLO2IpZXonDc0p4mwmn5M08eOETWqbgedhmy)iSpOLrh78MWoGo4TckyWbd2pc7dAz0XoVjSdOdElycoqe)BHcHQHkOqLVJ6LvcmXvryweVYklWad(mh700jxI8r40IVigpHskP5jq96cgHMcOdMaI4jOiEZdiwbgGIyTeOFWz8hbDjtQh8cxGIyTeOFWz8hbDjtMGI46bVWkOqLVJ6LvcmXvryweVYkRGcg8zo2PPtUe5JWPfFrmEcLusZtG61cdfGIyTeOFWz8hbDjtQh8cxyOYklafXAjnIZ40IfttUj700fmbhiI)TqHrOPa6GjGiEsD6ezINGdyX)KXb)rtVs4AL9NRRvSAjc0Bk440IHyuUZlsjQT4ZCSttNCjYhHtl(Iy8ekPKMNa1RfgkafXAjq)GZ4pc6sMup4fELcJqtb0btU8M4jOi(JGUKRc(mh700jq)GZyX0KBsZtG61vkk)TckyPLrhU5jq96kFMJDA6eOFWzSyAYnP5jq9Qmo4pA6vcxRS)CDTIvlrGEtbhNwmeJYDErkrTfFMJDA6eOFWzSyAYnP5jq9AHHcmigoyW(ryFqlJo25nHDaDWBfuWGdgSFe2h0YOJDEtyhqh8wWeCGi(3cfcvdvqHkFh1lReyIRIWSiELvwGbg8zo2PPtUe5JWPfFrmEcLusZtG61fmcnfqhmbeXtqr8MhqScmafXAjq)GZ4pc6sMup4fUafXAjq)GZ4pc6sMmbfX1dEHvqHkFh1lReyIRIWSiELvwbfm4ZCSttNCjYhHtl(Iy8ekPKMNa1RfgkafXAjq)GZ4pc6sMup4fUWqLvwakI1sAeNXPflMMCt2PPlycoqe)BHcJqtb0btar8K60jYepbhWI)jJd(JMELW1k7pxxRy1p9N9RHJ3y7aMSsdQZ4FxSuuIAlqrSwc0p4mwmn5MSttxakI1sAeNXPflMMCt2PPlyZOiwl5sKpcNw8fX4jusj700fmbhihDY4lXtqXfkyf5h5y8rNSmo4pA6vcxRS)CDTIvBgePEj2oGjxvIAlqrSwc0p4mwmn5MSttxakI1sAeNXPflMMCt2PPlyZOiwl5sKpcNw8fX4jusj700fmbhihDY4lXtqXfkyf5h5y8rNSmo4pA6vcxRS)CDTIvT5Ju5ngIr5MEmgLHPsuBbkI1sG(bNXIPj3KDA6cqrSwsJ4moTyX0KBYonDbBgfXAjxI8r40IVigpHskzNMUmo4pA6vcxRS)CDTIvfrAQnwQxIrhq9uIAlqrSwc0p4mwmn5MSttxakI1sAeNXPflMMCt2PPlyZOiwl5sKpcNw8fX4jusj700LXb)rtVs4AL9NRRvSAtffhmM64Qi8SsuBbkI1sG(bNXIPj3KDA6cqrSwsJ4moTyX0KBYonDbBgfXAjxI8r40IVigpHskzNMUmo4pA6vcxRS)CDTIvVigJ4OjIVX2SFwjQTafXAjq)GZyX0KBYonDbOiwlPrCgNwSyAYnzNMUGnJIyTKlr(iCAXxeJNqjLSttxgh8hn9kHRv2FUUwXQtEMDS40IhipDJ3ndZQsuBbkI1sG(bNXIPj3KDA6cqrSwsJ4moTyX0KBYonDbBgfXAjxI8r40IVigpHskzNMUmozCWF00RKuKDUxRyvJqtb0bRKdtUicmY4uKDERukwu5tjJWaHlIxjQTqSzJ4YFtINWgZhoA6Y4G)OPxjPi7CVwXQwAZy0bupLO2IgXzB2LmztRpvCqDOJf)5Cc(MWlbcvuK3cqrSwYMwFQ4G6qhl(Z5e8n22z9iiIY4G)OPxjPi7CVwXQ2oRh2tJGsuBrJ4Sn7sMu206iwm9P)Gj8sGqff5TGj4ar8VfIXcPmo4pA6vskYo3RvS6K2D2vCAXx2t2pzCWF00RKuKDUxRy1ndxeA2olJd(JMELKISZ9AfR2WMc(HRIqlSsuBXeCGi(3ccndLXb)rtVssr25ETIvFWFEGH)OPRe1wa)rtNuJO2J6LyX0KBYhbUZdQxkO83KMNa1RfgkJd(JMELKISZ9AfRwJO2J6LyX0KBLO2IAImqP(MyP8yJtlgDK1AoRe2b0bVLXb)rtVssr25ETIvVe5JWPfFrmEcLuzCWF00RKuKDUxRyvOFWzSyAYTmo4pA6vskYo3RvSAJ4moTyX0KBLO2cueRL0ioJtlwmn5MSttxgh8hn9kjfzN71kwvS5k7pJtlEs9Tmo4pA6vskYo3RvSk0p4mgDa1tjQTyNhPHnf8dxfHwysZtG61fesfuyZOiwlPHnf8dxfHwySrKHZnGsh0lws9Gx4fmugh8hn9kjfzN71kwf6hCgJoG6Pe1wGIyTeXMRS)moT4j13eerbBgfXAjxI8r40IVigpHskbruWMrrSwYLiFeoT4lIXtOKsAEcuVUsb8hnDc0p4mgDa1JWkYpYX4JozzCWF00RKuKDUxRyvOFWzmk0nuYkrTfOiwlb6hCglMMCtqefGIyTeOFWzSyAYnP5jq96kfL)wakI1sG(bNXFe0LmPEWlCbkI1sG(bNXFe0LmzckIRh8clJd(JMELKISZ9AfRc9doJN0ALo4QsuBXMrrSwYLiFeoT4lIXtOKsqefCWG9Ja9doJ5pkjSdOdElafXAjBgUi0SDMSttxWMrrSwYLiFeoT4lIXtOKsAEcuVUa8hnDc0p4mEsRv6GRewr(rogF0jlWGyaIr5MEmb6hCglImN8G6Le2b0bVvqbueRL8dg6hQh1lXFe4opi700vwPpcOEr8Y4G)OPxjPi7CVwXQq)GZ4jTwPdUQe1wGIyTKFWq)q9OEjPz4pL(iG6fXlJd(JMELKISZ9AfRc9doJZgvjQTafXAjq)GZ4pc6sMup4fELcJqtb0btU8M4jOi(JGUKRcm4ZCSttNa9doJfttUjnpbQxxiEdvqb4pQrgZopPCDLcHqzzCWF00RKuKDUxRyvOFWzm6aQNsuBbkI1sAeNXPflMMCtqevqHj4ar8VfIxiLXb)rtVssr25ETIvzJ5dhnDLO2cueRL0ioJtlwmn5MSttxjQFC3iIhMAlMGdeX)wOqOlKkr9J7gr8W05K3u44I4LXb)rtVssr25ETIvH(bNXOq3qjlJtgh8hn9k5ZCSttVUwXQ2oRh2tJGsuBrJ4Sn7sMu206iwm9P)Gj8sGqff5TGpZXonDc0p4mwmn5M08eOEDHy2qbFMJDA6Klr(iCAXxeJNqjL08eOETWqbgGIyTeOFWz8hbDjtQh8cVsHrOPa6GjxEt8eue)rqxYvbgyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyvwbfmigoyW(rAeNXPflMMCtyhqh8wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRYkOWN5yNMob6hCglMMCtAEcuVUsr5Vvw5LMss9stOOAA20JgJYsnsL6LsDztRJyLA6t)bl1M0lsQbrIuluQYsn9KAt6fj1xEtPoViUnPvMiJd(JMEL8zo2PPxxRyvBN1d7PrqjQTOrC2MDjtkBADelM(0FWeEjqOII8wWN5yNMob6hCglMMCtAEcuVwyOadIHdgSFe2h0YOJDEtyhqh8wbfm4Gb7hH9bTm6yN3e2b0bVfmbhiI)TqHq1qLvwGbg8zo2PPtUe5JWPfFrmEcLusZtG61fI3qbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSYkOGbFMJDA6Klr(iCAXxeJNqjL08eOETWqbOiwlb6hCg)rqxYK6bVWfgQSYcqrSwsJ4moTyX0KBYonDbtWbI4FluyeAkGoyciINuNorM4j4aw8pzCWF00RKpZXon96AfRA7SEO54uIAlAeNTzxYKnT(uXb1How8NZj4BcVeiurrEl4ZCSttNGIyT4nT(uXb1How8NZj4BsZWowbOiwlztRpvCqDOJf)5Cc(gB7SEKDA6cmafXAjq)GZyX0KBYonDbOiwlPrCgNwSyAYnzNMUGnJIyTKlr(iCAXxeJNqjLSttxzbFMJDA6Klr(iCAXxeJNqjL08eOETWqbgGIyTeOFWz8hbDjtQh8cVsHrOPa6GjxEt8eue)rqxYvbgyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyvwbfmigoyW(rAeNXPflMMCtyhqh8wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRYkOWN5yNMob6hCglMMCtAEcuVUsr5VvwzzCWF00RKpZXon96AfRAPnJrhq9uIAlAeNTzxYKnT(uXb1How8NZj4BcVeiurrEl4ZCSttNGIyT4nT(uXb1How8NZj4BsZWowbOiwlztRpvCqDOJf)5Cc(gBPnt2PPlqSzJ4YFtINy7SEO54KXb)rtVs(mh700RRvS6K2D2vCAXx2t2pLO2IpZXonDYLiFeoT4lIXtOKsAEcuVwyOaueRLa9doJ)iOlzs9Gx4vkmcnfqhm5YBINGI4pc6sUk4ZCSttNa9doJfttUjnpbQxxPO83lnLK6L2s(WeITk1ivwQN0UZUk1M0lsQbrIuhJWk1xEtPMwL6MHDSsnuLAtEmusQNGWSuxrAwQVuQFOEsn9KAu2Mnl1xEtImo4pA6vYN5yNMEDTIvN0UZUItl(YEY(Pe1w8zo2PPtG(bNXIPj3KMNa1RfgkWGy4Gb7hH9bTm6yN3e2b0bVvqbdoyW(ryFqlJo25nHDaDWBbtWbI4FluiunuzLfyGbFMJDA6Klr(iCAXxeJNqjL08eOEDbJqtb0btar8eueV5beRaueRLa9doJ)iOlzs9Gx4cueRLa9doJ)iOlzYeuexp4fwzfuWGpZXonDYLiFeoT4lIXtOKsAEcuVwyOaueRLa9doJ)iOlzs9Gx4cdvwzbOiwlPrCgNwSyAYnzNMUGj4ar8VfkmcnfqhmbeXtQtNit8eCal(Nmo4pA6vYN5yNMEDTIv3mCrOz7SsuBXN5yNMo5sKpcNw8fX4jusjnpbQxlmuakI1sG(bNXFe0LmPEWl8kfgHMcOdMC5nXtqr8hbDjxf8zo2PPtG(bNXIPj3KMNa1RRuu(7LMss9sBjFycXwLAKkl1BgUi0SDwQnPxKudIePogHvQV8MsnTk1nd7yLAOk1M8yOKupbHzPUI0SuFPu)q9KA6j1OSnBwQV8MezCWF00RKpZXon96AfRUz4IqZ2zLO2IpZXonDc0p4mwmn5M08eOETWqbgedhmy)iSpOLrh78MWoGo4TckyWbd2pc7dAz0XoVjSdOdElycoqe)BHcHQHkRSadm4ZCSttNCjYhHtl(Iy8ekPKMNa1RleVHcqrSwc0p4m(JGUKj1dEHlqrSwc0p4m(JGUKjtqrC9GxyLvqbd(mh700jxI8r40IVigpHskP5jq9AHHcqrSwc0p4m(JGUKj1dEHlmuzLfGIyTKgXzCAXIPj3KDA6cMGdeX)wOWi0uaDWeqepPoDImXtWbS4FY4G)OPxjFMJDA611kwTHnf8dxfHwyLO2IpZXonDYLiFeoT4lIXtOKsAEcuVUGrOPa6GjDfpbfXBEaXk4ZCSttNa9doJfttUjnpbQxxWi0uaDWKUINGI4npGyfyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83kOWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxWi0uaDWKUINGI4npGyvqHy4Gb7hPrCgNwSyAYnHDaDWBLfGIyTeOFWz8hbDjtQh8cVGqiyZOiwl5sKpcNw8fX4jusj700xAkj1lnHsvwQRIqlSutTs9L3uQbFl1GOudnl1Pl1)wQbFl1MPhtNuJYsnIOuBZwQhPxYTuFrGl1xel1tqrPEZdiwLK6jim1lL6ksZsTjl1rGrwQHtQhmupP(mtPg6hCwQ)iOl5Qud(wQVi4K6lVPuBcvpMoPwOyK6j1ivEtKXb)rtVs(mh700RRvSAdBk4hUkcTWkrTfFMJDA6Klr(iCAXxeJNqjL08eOETWqbOiwlb6hCg)rqxYK6bVWRuyeAkGoyYL3epbfXFe0LCvWN5yNMob6hCglMMCtAEcuVUsr5VxAkj1lnHsvwQRIqlSuBsViPgeLAZi2LAXSwPOdMi1XiSs9L3uQPvPUzyhRudvP2KhdLK6jiml1vKML6lL6hQNutpPgLTzZs9L3KiJd(JMEL8zo2PPxxRy1g2uWpCveAHvIAl(mh700jq)GZyX0KBsZtG61cdfyGbXWbd2pc7dAz0XoVjSdOdERGcgCWG9JW(GwgDSZBc7a6G3cMGdeX)wOqOAOYklWad(mh700jxI8r40IVigpHskP5jq96cgHMcOdMaI4jOiEZdiwbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSYkOGbFMJDA6Klr(iCAXxeJNqjL08eOETWqbOiwlb6hCg)rqxYK6bVWfgQSYcqrSwsJ4moTyX0KBYonDbtWbI4FluyeAkGoyciINuNorM4j4aw8pLLXb)rtVs(mh700RRvS6LiFeoT4lIXtOKQe1w8zo2PPtG(bNXIPj3KMNa1RRiKgkGRv2FMyKwPPJtlwKBl)hnDYK6zlJd(JMEL8zo2PPxxRy1lr(iCAXxeJNqjvjQTafXAjq)GZ4pc6sMup4fELcJqtb0btU8M4jOi(JGUKRcoyW(rAeNXPflMMCtyhqh8wWN5yNMoPrCgNwSyAYnP5jq96kfL)wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRGpnYo4hr4yBk4e2b0bVf8zo2PPtAytb)WvrOfM08eOEDLcH(stjPEPfJuSnf8LQuluQYs9L3uQPwPgeLAAvQtxQ)Tud(wQntpMoPgLLAerP2MTupsVKBP(IaxQViwQNGIs9MhqSePEjFqlDP2KErsDNIsn1k1xel1hmy)KAAvQpqy2jsTqrNJTudsnk9K6lL6jiml1vKMLAtwQFWL6LmQsnDo5nfoEeRud2JBP(YBk1SVRY4G)OPxjFMJDA611kw9sKpcNw8fX4jusvIAlqrSwc0p4m(JGUKj1dEHxPWi0uaDWKlVjEckI)iOl5QGdgSFKgXzCAXIPj3e2b0bVf8zo2PPtAeNXPflMMCtAEcuVUsr5Vf8zo2PPtG(bNXIPj3KMNa1RlyeAkGoyYL3epbfXBEaXkig(0i7GFeHJTPGtyhqh8EPPKuV0woDHYhJuSnf8LQuluQYs9L3uQPwPgeLAAvQtxQ)Tud(wQntpMoPgLLAerP2MTupsVKBP(IaxQViwQNGIs9MhqSePEjFqlDP2KErsDNIsn1k1xel1hmy)KAAvQpqy2jY4G)OPxjFMJDA611kw9sKpcNw8fX4jusvIAlqrSwc0p4m(JGUKj1dEHxPWi0uaDWKlVjEckI)iOl5QGy4Gb7hPrCgNwSyAYnHDaDWBbFMJDA6eOFWzSyAYnP5jq96cgHMcOdMC5nXtqr8MhqSY4G)OPxjFMJDA611kw9sKpcNw8fX4jusvIAlqrSwc0p4m(JGUKj1dEHxPWi0uaDWKlVjEckI)iOl5QGpZXonDc0p4mwmn5M08eOEDLIYFlJd(JMEL8zo2PPxxRyvOFWzSyAYTsuBHbXWbd2pc7dAz0XoVjSdOdERGcgCWG9JW(GwgDSZBc7a6G3cMGdeX)wOqOAOYkl4ZCSttNCjYhHtl(Iy8ekPKMNa1RlyeAkGoyciINGI4npGyfGIyTeOFWz8hbDjtQh8cxGIyTeOFWz8hbDjtMGI46bVWcqrSwsJ4moTyX0KBYonDbtWbI4FluyeAkGoyciINuNorM4j4aw8VLMss9stOuLLAquQPwP(YBk10QuNUu)BPg8TuBMEmDsnkl1iIsTnBPEKEj3s9fbUuFrSupbfL6npGyvsQNGWuVuQRinl1xeCsTjl1rGrwQzprkJK6j4Gud(wQVi4K6lIBwQPvP2ZtQHrZWowPgK6gXzPoTsTyAYTuVttNiJd(JMEL8zo2PPxxRy1gXzCAXIPj3krTfOiwlPrCgNwSyAYnzNMUGpZXonDYLiFeoT4lIXtOKsAEcuVUGrOPa6GjDkINGI4npGyfGIyTeOFWz8hbDjtQh8cxGIyTeOFWz8hbDjtMGI46bVWcm4ZCSttNa9doJfttUjnpbQxxiEHubf2mkI1sUe5JWPfFrmEcLucIOYlnLK6LMqPkl1Dkk1uRuF5nLAAvQtxQ)Tud(wQntpMoPgLLAerP2MTupsVKBP(IaxQViwQNGIs9MhqSkj1tqyQxk1vKML6lIBwQPvpMoPggnd7yLAqQBeNL6DA6sn4BP(IGtQbrP2m9y6KAu(Zjl1GrGoa0bl1BKM6LsDJ4mrgh8hn9k5ZCSttVUwXQInxz)zCAXtQVvIAlqrSwc0p4m(JGUKj1dEHlmuWNgzh8JiCSnfCc7a6G3lnLK6LwmsX2uWxQs9sgvPMwL6j4GuhH4LDSsn4BPEjFDHwvQHML6ltPMvuK9k1il1xk1ivwQfZPuFPuxxceMJrzPgCPMv8AqQbuPM6s9fXs9L3uQnP(onjs9scFXuvQrQSutpP(sPEccZs9inL6pc6swQxYxVk1uVEGFezCWF00RKpZXon96AfRk2CL9NXPfpP(wjQTyZOiwl5sKpcNw8fX4jusjiIcIHpnYo4hr4yBk4e2b0bVxAkj1lTLtxO8XifBtbFPk1cLQSulMtP(sPUUeimhJYsn4snR41GudOsn1L6lIL6lVPuBs9DAsKXjJd(JMEL05bhn91kwf6hCgJcDdLSsuBXN5yNMo5sKpcNw8fX4jusjnpbQxlmuGbOiwlb6hCg)rqxYK6bVWlyeAkGoyYL3epbfXFe0LCvWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyf8Pr2b)ichBtbNWoGo4TGpZXonDsdBk4hUkcTWKMNa1RRui0vwgh8hn9kPZdoA6RvSk0p4mgf6gkzLO2IpZXonDYLiFeoT4lIXtOKsAEcuVwyOadqrSwc0p4m(JGUKj1dEHxWi0uaDWKlVjEckI)iOl5QGdgSFKgXzCAXIPj3e2b0bVf8zo2PPtAeNXPflMMCtAEcuVUsr5Vf8zo2PPtG(bNXIPj3KMNa1RlyeAkGoyYL3epbfXBEaXkig(0i7GFeHJTPGtyhqh8wzzCWF00RKop4OPVwXQq)GZyuOBOKvIAl(mh700jxI8r40IVigpHskP5jq9AHHcmafXAjq)GZ4pc6sMup4fEbJqtb0btU8M4jOi(JGUKRcIHdgSFKgXzCAXIPj3e2b0bVf8zo2PPtG(bNXIPj3KMNa1RlyeAkGoyYL3epbfXBEaXQSmo4pA6vsNhC00xRyvOFWzmk0nuYkrTfFMJDA6Klr(iCAXxeJNqjL08eOETWqbgGIyTeOFWz8hbDjtQh8cVGrOPa6GjxEt8eue)rqxYvbFMJDA6eOFWzSyAYnP5jq96kfL)wzzCcfK6LzEl1xk10P4GNSFsD9A6FsDLxce2FUk1zl1Oi0XwQbxQHXXTdh1il1rCZezCcfKA4pA6vsNhC00xRy1610)WvEjqy)zLO2InJIyTKg2uWpCveAHXgrgo3akDqVyj1dEHl2mkI1sAytb)WvrOfgBez4CdO0b9ILmbfX1dEHfGIyTeOFWzSyAYnzNMUaueRL0ioJtlwmn5MSttxjhMCXaQhUkcTW46bVWlvOFWzm6aQ3sf6hCgJcDdLSmo4pA6vsNhC00xRyvOFWzmk0nuYkrTfBgfXAjnSPGF4Qi0cJnImCUbu6GEXsQh8cxSzueRL0WMc(HRIqlm2iYW5gqPd6flzckIRh8clWaueRLa9doJfttUj700vqbueRLa9doJfttUjnpbQxxPO83klWaueRL0ioJtlwmn5MSttxbfqrSwsJ4moTyX0KBsZtG61vkk)TYY4G)OPxjDEWrtFTIvH(bNXOdOEkrTf78inSPGF4Qi0ctAEcuVUGqQGcBgfXAjnSPGF4Qi0cJnImCUbu6GEXsQh8cVGHY4G)OPxjDEWrtFTIvH(bNXOdOEkrTfOiwlrS5k7pJtlEs9nbruWMrrSwYLiFeoT4lIXtOKsqefSzueRLCjYhHtl(Iy8ekPKMNa1RRua)rtNa9doJrhq9iSI8JCm(Otwgh8hn9kPZdoA6RvSk0p4mEsRv6GRkrTfBgfXAjxI8r40IVigpHskbruWbd2pc0p4mM)OKWoGo4TaueRLSz4IqZ2zYonDbgSzueRLCjYhHtl(Iy8ekPKMNa1Rla)rtNa9doJN0ALo4kHvKFKJXhDYkOWN5yNMorS5k7pJtlEs9nP5jq96cgQGcFAKDWpIWX2uWjSdOdERSadIbigLB6XeOFWzSiYCYdQxsyhqh8wbfqrSwYpyOFOEuVe)rG78GSttxzL(iG6fXlJd(JMEL05bhn91kwf6hCgpP1kDWvLO2cueRL8dg6hQh1ljnd)jafXAjSIIGV5nwmp2pkmiiIY4G)OPxjDEWrtFTIvH(bNXtATshCvjQTafXAj)GH(H6r9ssZWFcmafXAjq)GZyX0KBcIOckGIyTKgXzCAXIPj3eerfuyZOiwl5sKpcNw8fX4jusjnpbQxxa(JMob6hCgpP1kDWvcRi)ihJp6KvwPpcOEr8Y4G)OPxjDEWrtFTIvH(bNXtATshCvjQTafXAj)GH(H6r9ssZWFcqrSwYpyOFOEuVKup4fUafXAj)GH(H6r9sYeuexp4fwPpcOEr8Y4G)OPxjDEWrtFTIvH(bNXtATshCvjQTafXAj)GH(H6r9ssZWFcqrSwYpyOFOEuVK08eOEDLcdmafXAj)GH(H6r9ss9Gx4LSWF00jq)GZ4jTwPdUsyf5h5y8rNSYRv(BLv6JaQxeVmo4pA6vsNhC00xRyvNViUXhpf56Pe1wyqZ2MRra6GvqHy4OVWuVuzbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSaueRLa9doJfttUj700fSzueRLCjYhHtl(Iy8ekPKDA6Y4G)OPxjDEWrtFTIvH(bNXzJQe1wGIyTeOFWz8hbDjtQh8cVsHrOPa6GjxEt8eue)rqxYvzCWF00RKop4OPVwXQverU90iOe1wmbhiI)TsrmwifGIyTeOFWzSyAYnzNMUaueRL0ioJtlwmn5MSttxWMrrSwYLiFeoT4lIXtOKs2PPlJd(JMEL05bhn91kwTgrTh1lXIPj3krTfOiwlb6hCglMMCt2PPlafXAjnIZ40IfttUj700fSzueRLCjYhHtl(Iy8ekPKDA6c(mh700jSX8HJMoP5jq96cgk4ZCSttNa9doJfttUjnpbQxxWqbFMJDA6Klr(iCAXxeJNqjL08eOEDbdfyqmCWG9J0ioJtlwmn5MWoGo4TckyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxWqLvwgh8hn9kPZdoA6RvSk0p4mgDa1tjQTafXAjnYGXPfFrnZvcIOaueRLa9doJ)iOlzs9Gx4fIzzCWF00RKop4OPVwXQq)GZyuOBOKvIAlMGdeX)wXi0uaDWeuOBOKXtWbS4Fc(mh700jSX8HJMoP5jq96cgkafXAjq)GZyX0KBYonDbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSaUwz)zIrALMooTyrUT8F00jtQNTmo4pA6vsNhC00xRyvOFWzmk0nuYkrTfFMJDA6Klr(iCAXxeJNqjL08eOETWqbg8zo2PPtAeNXPflMMCtAEcuVwyOck8zo2PPtG(bNXIPj3KMNa1RfgQSaueRLa9doJ)iOlzs9Gx4cueRLa9doJ)iOlzYeuexp4fwgh8hn9kPZdoA6RvSk0p4mgf6gkzLO2Ij4ar8Vvkmcnfqhmbf6gkz8eCal(NaueRLa9doJfttUj700fGIyTKgXzCAXIPj3KDA6c2mkI1sUe5JWPfFrmEcLuYonDbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSGpZXonDcBmF4OPtAEcuVUGHY4G)OPxjDEWrtFTIvH(bNXOq3qjRe1wGIyTeOFWzSyAYnzNMUaueRL0ioJtlwmn5MSttxWMrrSwYLiFeoT4lIXtOKs2PPlafXAjq)GZ4pc6sMup4fUafXAjq)GZ4pc6sMmbfX1dEHfCWG9Ja9doJZgLWoGo4TGpZXonDc0p4moBusZtG61vkk)TGj4ar8VvkIXgk4ZCSttNWgZhoA6KMNa1RlyOmo4pA6vsNhC00xRyvOFWzmk0nuYkrTfOiwlb6hCglMMCtqefGIyTeOFWzSyAYnP5jq96kfL)wakI1sG(bNXFe0LmPEWlCbkI1sG(bNXFe0LmzckIRh8clJd(JMEL05bhn91kwf6hCgJcDdLSsuBbkI1sAeNXPflMMCtqefGIyTKgXzCAXIPj3KMNa1RRuu(BbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSmo4pA6vsNhC00xRyvOFWzmk0nuYkrTfOiwlb6hCglMMCt2PPlafXAjnIZ40IfttUj700fSzueRLCjYhHtl(Iy8ekPeerbBgfXAjxI8r40IVigpHskP5jq96kfL)wakI1sG(bNXFe0LmPEWlCbkI1sG(bNXFe0LmzckIRh8clJd(JMEL05bhn91kwf6hCgJoG6jJd(JMEL05bhn91kwLnMpC00vI6h3nI4HP2Ij4ar8Vfke6cPsu)4UrepmDo5nfoUiEzCWF00RKop4OPVwXQq)GZyuOBOKLXb)rtVs68GJM(AfRAeAkGoyLCyYfwQddmks7kLIfv(uYimq4I4vIAlqrSwc0p4m(JGUKj1dEHlqrSwc0p4m(JGUKjtqrC9GxybXakI1sAKbJtl(IAMReerbwAz0HBEcuVUsHbgmbhekd8hnDc0p4mgDa1J8z9uEjl8hnDc0p4mgDa1JWkYpYX4JozLLXjJd(JMELyPomWOiTVwXQq)GZ4jTwPdUQe1wGIyTKFWq)q9OEjPz4pL(iG6fXlJd(JMELyPomWOiTVwXQq)GZy0bupzCWF00Rel1HbgfP91kwf6hCgJcDdLSmozCWF00Rei51kw12z9qZXPe1w0ioBZUKjBA9PIdQdDS4pNtW3eEjqOII8wWN5yNMobfXAXBA9PIdQdDS4pNtW3KMHDScqrSwYMwFQ4G6qhl(Z5e8n22z9i700fyakI1sG(bNXIPj3KDA6cqrSwsJ4moTyX0KBYonDbBgfXAjxI8r40IVigpHskzNMUYc(mh700jxI8r40IVigpHskP5jq9AHHcmafXAjq)GZ4pc6sMup4fELcJqtb0btGKXxEt8eue)rqxYvbgyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyvwbfmigoyW(rAeNXPflMMCtyhqh8wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRYkOWN5yNMob6hCglMMCtAEcuVUsr5VvwzzCWF00Rei51kw1sBgJoG6Pe1wyqJ4Sn7sMSP1NkoOo0XI)CobFt4LaHkkYBbFMJDA6eueRfVP1NkoOo0XI)CobFtAg2XkafXAjBA9PIdQdDS4pNtW3ylTzYonDbInBex(Bs8eBN1dnhNYkOGbnIZ2SlzYMwFQ4G6qhl(Z5e8nHxceQOiVfC0jxyOYY4G)OPxjqYRvSQTZ6H90iOe1w0ioBZUKjLnToIftF6pycVeiurrEl4ZCSttNa9doJfttUjnpbQxxiMnuWN5yNMo5sKpcNw8fX4jusjnpbQxlmuGbOiwlb6hCg)rqxYK6bVWRuyeAkGoycKm(YBINGI4pc6sUkWadoyW(rAeNXPflMMCtyhqh8wWN5yNMoPrCgNwSyAYnP5jq96kfL)wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRYkOGbXWbd2psJ4moTyX0KBc7a6G3c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyvwbf(mh700jq)GZyX0KBsZtG61vkk)TYklJd(JMELajVwXQ2oRh2tJGsuBrJ4Sn7sMu206iwm9P)Gj8sGqff5TGpZXonDc0p4mwmn5M08eOETWqbgyGbFMJDA6Klr(iCAXxeJNqjL08eOEDbJqtb0btar8eueV5beRaueRLa9doJ)iOlzs9Gx4cueRLa9doJ)iOlzYeuexp4fwzfuWGpZXonDYLiFeoT4lIXtOKsAEcuVwyOaueRLa9doJ)iOlzs9Gx4vkmcnfqhmbsgF5nXtqr8hbDjxvwzbOiwlPrCgNwSyAYnzNMUYY4G)OPxjqYRvS6LiFeoT4lIXtOKQe1w0ioBZUKjvQyu646L9KWlbcvuK3ceB2iU83K4jSX8HJMUmo4pA6vcK8AfRc9doJfttUvIAlAeNTzxYKkvmkDC9YEs4LaHkkYBbgi2SrC5VjXtyJ5dhnDfuqSzJ4YFtINCjYhHtl(Iy8ekPklJd(JMELajVwXQSX8HJMUsuBXrN8cXSHcAeNTzxYKkvmkDC9YEs4LaHkkYBbOiwlb6hCg)rqxYK6bVWRuyeAkGoycKm(YBINGI4pc6sUk4ZCSttNCjYhHtl(Iy8ekPKMNa1Rfgk4ZCSttNa9doJfttUjnpbQxxPO83Y4G)OPxjqYRvSkBmF4OPRe1wC0jVqmBOGgXzB2LmPsfJshxVSNeEjqOII8wWN5yNMob6hCglMMCtAEcuVwyOadmWGpZXonDYLiFeoT4lIXtOKsAEcuVUGrOPa6GjGiEckI38aIvakI1sG(bNXFe0LmPEWlCbkI1sG(bNXFe0LmzckIRh8cRSckyWN5yNMo5sKpcNw8fX4jusjnpbQxlmuakI1sG(bNXFe0LmPEWl8kfgHMcOdMajJV8M4jOi(JGUKRkRSaueRL0ioJtlwmn5MSttxzLO(XDJiEyQTafXAjvQyu646L9Kup4fUafXAjvQyu646L9KmbfX1dEHvI6h3nI4HPZjVPWXfXlJd(JMELajVwXQtA3zxXPfFzpz)uIAlm4ZCSttNa9doJfttUjnpbQxxqOjKkOWN5yNMob6hCglMMCtAEcuVUsrmRSGpZXonDYLiFeoT4lIXtOKsAEcuVwyOadqrSwc0p4m(JGUKj1dEHxPWi0uaDWeiz8L3epbfXFe0LCvGbgCWG9J0ioJtlwmn5MWoGo4TGpZXonDsJ4moTyX0KBsZtG61vkk)TGpZXonDc0p4mwmn5M08eOEDbHuzfuWGy4Gb7hPrCgNwSyAYnHDaDWBbFMJDA6eOFWzSyAYnP5jq96ccPYkOWN5yNMob6hCglMMCtAEcuVUsr5VvwzzCWF00Rei51kwTHnf8dxfHwyLO2IpZXonDYLiFeoT4lIXtOKsAEcuVUGrOPa6GjDfpbfXBEaXk4ZCSttNa9doJfttUjnpbQxxWi0uaDWKUINGI4npGyfyWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxPO83kOWbd2psJ4moTyX0KBc7a6G3c(mh700jnIZ40IfttUjnpbQxxWi0uaDWKUINGI4npGyvqHy4Gb7hPrCgNwSyAYnHDaDWBLfGIyTeOFWz8hbDjtQh8cVsHrOPa6GjqY4lVjEckI)iOl5QGnJIyTKlr(iCAXxeJNqjLSttxgh8hn9kbsETIvBytb)WvrOfwjQT4ZCSttNCjYhHtl(Iy8ekPKMNa1RfgkWaueRLa9doJ)iOlzs9Gx4vkmcnfqhmbsgF5nXtqr8hbDjxfyGbhmy)inIZ40IfttUjSdOdEl4ZCSttN0ioJtlwmn5M08eOEDLIYFl4ZCSttNa9doJfttUjnpbQxxWi0uaDWKlVjEckI38aIvzfuWGy4Gb7hPrCgNwSyAYnHDaDWBbFMJDA6eOFWzSyAYnP5jq96cgHMcOdMC5nXtqr8MhqSkRGcFMJDA6eOFWzSyAYnP5jq96kfL)wzLLXb)rtVsGKxRy1g2uWpCveAHvIAl(mh700jq)GZyX0KBsZtG61cdfyGbg8zo2PPtUe5JWPfFrmEcLusZtG61fmcnfqhmbeXtqr8MhqScqrSwc0p4m(JGUKj1dEHlqrSwc0p4m(JGUKjtqrC9GxyLvqbd(mh700jxI8r40IVigpHskP5jq9AHHcqrSwc0p4m(JGUKj1dEHxPWi0uaDWeiz8L3epbfXFe0LCvzLfGIyTKgXzCAXIPj3KDA6klJd(JMELajVwXQBgUi0SDwjQT4ZCSttNa9doJfttUjnpbQxlmuGbgyWN5yNMo5sKpcNw8fX4jusjnpbQxxWi0uaDWeqepbfXBEaXkafXAjq)GZ4pc6sMup4fUafXAjq)GZ4pc6sMmbfX1dEHvwbfm4ZCSttNCjYhHtl(Iy8ekPKMNa1RfgkafXAjq)GZ4pc6sMup4fELcJqtb0btGKXxEt8eue)rqxYvLvwakI1sAeNXPflMMCt2PPRSmo4pA6vcK8AfREjYhHtl(Iy8ekPkrTfOiwlb6hCg)rqxYK6bVWRuyeAkGoycKm(YBINGI4pc6sUkWadoyW(rAeNXPflMMCtyhqh8wWN5yNMoPrCgNwSyAYnP5jq96kfL)wWN5yNMob6hCglMMCtAEcuVUGrOPa6GjxEt8eueV5beRYkOGbXWbd2psJ4moTyX0KBc7a6G3c(mh700jq)GZyX0KBsZtG61fmcnfqhm5YBINGI4npGyvwbf(mh700jq)GZyX0KBsZtG61vkk)TYY4G)OPxjqYRvSk0p4mwmn5wjQTWad(mh700jxI8r40IVigpHskP5jq96cgHMcOdMaI4jOiEZdiwbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSYkOGbFMJDA6Klr(iCAXxeJNqjL08eOETWqbOiwlb6hCg)rqxYK6bVWRuyeAkGoycKm(YBINGI4pc6sUQSYcqrSwsJ4moTyX0KBYonDzCWF00Rei51kwTrCgNwSyAYTsuBbkI1sAeNXPflMMCt2PPlWad(mh700jxI8r40IVigpHskP5jq96ccHHcqrSwc0p4m(JGUKj1dEHlqrSwc0p4m(JGUKjtqrC9GxyLvqbd(mh700jxI8r40IVigpHskP5jq9AHHcqrSwc0p4m(JGUKj1dEHxPWi0uaDWeiz8L3epbfXFe0LCvzLfyWN5yNMob6hCglMMCtAEcuVUq8cPckSzueRLCjYhHtl(Iy8ekPeerLLXb)rtVsGKxRyvXMRS)moT4j13krTfOiwlzZWfHMTZeerbBgfXAjxI8r40IVigpHskbruWMrrSwYLiFeoT4lIXtOKsAEcuVUsbkI1seBUY(Z40INuFtMGI46bVWlzH)OPtG(bNXOdOEewr(rogF0jlJd(JMELajVwXQq)GZy0bupLO2cueRLSz4IqZ2zcIOadm4Gb7hP5A6G)mHDaDWBbWFuJmMDEs56kcnLvqb4pQrgZopPCDfHuzzCWF00Rei51kwTIiYTNgbzCWF00Rei51kwf6hCgNnQsuBbkI1sG(bNXFe0LmPEWlCHHY4G)OPxjqYRvSQZxe34JNIC9uIAlmOzBZ1iaDWkOqmC0xyQxQSaueRLa9doJ)iOlzs9Gx4cueRLa9doJ)iOlzYeuexp4fwgh8hn9kbsETIvRru7r9sSyAYTsuBbkI1sG(bNXIPj3KDA6cqrSwsJ4moTyX0KBYonDbBgfXAjxI8r40IVigpHskzNMUGpZXonDc0p4mwmn5M08eOEDbdf8zo2PPtUe5JWPfFrmEcLusZtG61fmuGbXWbd2psJ4moTyX0KBc7a6G3kOGbhmy)inIZ40IfttUjSdOdEl4ZCSttN0ioJtlwmn5M08eOEDbdvwzzCWF00Rei51kwf6hCgpP1kDWvLO2cueRL8dg6hQh1ljnd)jOrC2MDjtG(bNXu3sD6flHxceQOiVfCWG9JatXb1sF4OPtyhqh8wa8h1iJzNNuUUsmwgh8hn9kbsETIvH(bNXtATshCvjQTafXAj)GH(H6r9ssZWFcAeNTzxYeOFWzm1TuNEXs4LaHkkYBbWFuJmMDEs56klfzCWF00Rei51kwf6hCgZkkoYknDLO2cueRLa9doJ)iOlzs9Gx4vqrSwc0p4m(JGUKjtqrC9GxyzCWF00Rei51kwf6hCgZkkoYknDLO2cueRLa9doJ)iOlzs9Gx4cueRLa9doJ)iOlzYeuexp4fwGyZgXL)Mepb6hCgJcDdLSmo4pA6vcK8AfRc9doJrHUHswjQTafXAjq)GZ4pc6sMup4fUafXAjq)GZ4pc6sMmbfX1dEHLXb)rtVsGKxRyv2y(WrtxjQFC3iIhMAlMGdeX)wOqOlKkr9J7gr8W05K3u44I4LXjJd(JMELatCveMfnIZ40IfttUvIAlqrSwsJ4moTyX0KBYonDbFMJDA6eOFWzSyAYnP5jq96cgkJd(JMELatCveMRvS6LiFeoT4lIXtOKQe1wyWN5yNMob6hCglMMCtAEcuVwyOaueRL0ioJtlwmn5MSttxzfuqSzJ4YFtIN0ioJtlwmn5wgh8hn9kbM4QimxRy1lr(iCAXxeJNqjvjQT4ZCSttNa9doJfttUjnpbQxxrinuakI1sAeNXPflMMCt2PPlGRv2FMyKwPPJtlwKBl)hnDc7a6G3Y4G)OPxjWexfH5AfRc9doJfttUvIAlqrSwsJ4moTyX0KBYonDbFMJDA6Klr(iCAXxeJNqjL08eOEDbJqtb0btar8eueV5beRmo4pA6vcmXvryUwXQq)GZyuOBOKvIAlqrSwc0p4mwmn5MGikafXAjq)GZyX0KBsZtG61vkG)OPtG(bNXtATshCLWkYpYX4JozbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSmo4pA6vcmXvryUwXQq)GZ4SrvIAlqrSwc0p4m(JGUKj1dEHxbfXAjq)GZ4pc6sMmbfX1dEHfGIyTKgXzCAXIPj3KDA6cqrSwc0p4mwmn5MSttxWMrrSwYLiFeoT4lIXtOKs2PPlJd(JMELatCveMRvSk0p4mgf6gkzLO2cueRL0ioJtlwmn5MSttxakI1sG(bNXIPj3KDA6c2mkI1sUe5JWPfFrmEcLuYonDbOiwlb6hCg)rqxYK6bVWfOiwlb6hCg)rqxYKjOiUEWlSmo4pA6vcmXvryUwXQq)GZ4jTwPdUQe1wGIyTKFWq)q9OEjPz4pL(iG6fXRed9iw8hbuhtTfOiwl5hm0pupQxI)iWDEq2PPlWaueRLa9doJfttUjiIkOakI1sAeNXPflMMCtqevqHpZXonDcBmF4OPtAg2XQSmo4pA6vcmXvryUwXQq)GZ4jTwPdUQe1wedqmk30Jjq)GZyrK5KhuVKWoGo4TckGIyTKFWq)q9OEj(Ja35bzNMUsFeq9I4vIHEel(JaQJP2cueRL8dg6hQh1lXFe4opi700fyakI1sG(bNXIPj3eerfuafXAjnIZ40IfttUjiIkOWN5yNMoHnMpC00jnd7yvwgNqbPg(JMELatCveMRvS6d(Zdm8hnDLO2c4pA6e2y(WrtN8rG78G6LcMGdeX)wOiglKY4G)OPxjWexfH5AfRYgZhoA6kr9J7gr8WuBXeCGi(3cfXyHujQFC3iIhMoN8MchxeVmo4pA6vcmXvryUwXQq)GZ4SrvIAlqrSwc0p4m(JGUKj1dEHxbfXAjq)GZ4pc6sMmbfX1dEHLXb)rtVsGjUkcZ1kwf6hCgJcDdLSmo4pA6vcmXvryUwXQq)GZy0bupzCY4G)OPxjZ0ipz)wRyv0b1fgdESkrTfZ0ipz)iBA9a)5fkI3qzCWF00RKzAKNSFRvSQyZv2FgNw8K6BzCWF00RKzAKNSFRvSk0p4mEsRv6GRkrTfZ0ipz)iBA9a)5vI3qzCWF00RKzAKNSFRvSk0p4moBuzCWF00RKzAKNSFRvSQL2mgDa1lCHlea]] )


end
