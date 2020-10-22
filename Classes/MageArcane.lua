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


    spec:RegisterPack( "Arcane", 20201021, [[d00I9dqiHcwebf5rcfP6seufvBIaFsOqJIcCksuRIGcYRus1SirUfbvrzxi(LssdJc6ykbltjQEMqrnncQ01iO02uIs9ncQyCeuvNtjkzDeuO5PK4EsX(eQCqckWcvs5HcfjFuOiLgjbfu1jjOkzLcLEPqrkMPqr0njOkIDQe5NeufPHsqbvwkbvHEkjnvLqxLGQuFLGckJLGIAVc(ludMuhgSyiESQMSsDzuBMsFwknAHCAKwnbvbVMGmBP62kSBQ(TOHtOJReflxYZv00v56qA7uOVtrJNeCEHQwVqry(Kq7NOdlewmOUHJdlTCdxUHly4YxGS8ywyfUlSSdQx8ICqveEHGwoO6WGdQcdQhCoOkcX3tyhwmOot065GA0DItHXvxTLErOiKphRoPd0oC00)cS3Qt64xnOIGs7NWlpGeu3WXHLwUHl3WfmC5lqwEmlSc3fwEqDkYFyPL9YdQr09M9asqDZZpOgtxQfEc0YsTWG6bNLXgtxQfE6Fjcxs9YxqjPE5gUCddQD68MHfdQPi7CfwmS0cHfdQSdiDEhwlOMIb1jFbv4pA6bvJqrbKohuncDuoOUqq9l6XffcQIfBe3(BYce2y(WrtpOAekSddoOgbgzCkYoVdxyPLhwmOYoG05DyTG6x0JlkeuluNTz1YKnD(uXo1HkE8NJb4BcVmOurrEl1cKAeuRLSPZNk2PouXJ)CmaFJTvopcQyqf(JMEq1slgJ0H5fUWsXCyXGk7asN3H1cQFrpUOqqTqD2MvltAl6ShpM(0VZeEzqPII8wQfi1dWbI4FsDCs9YsydQWF00dQ2kNh2tJq4cljCdlguH)OPhuh0QYAItl(YAW(fuzhq68oSw4cljSHfdQWF00dQBgUiKSCoOYoG05DyTWfwAzhwmOYoG05DyTG6x0JlkeuhGdeX)K64KAHRHbv4pA6b1c2uWp8uekHcxyjHtyXGk7asN3H1cQFrpUOqqf(JMozgrTh1BXIPjxKpcCN7uVvQfi1T)Mu8aO(uQBKAddQWF00dQp4p3XWF00dxyjHFyXGk7asN3H1cQFrpUOqqDMODeQVjwk3340Ir65CMJjHDaPZ7Gk8hn9G6mIApQ3IfttUcxyPLvyXGk8hn9G6LOFeoT4lIXdOLguzhq68oSw4clTGHHfdQWF00dQq9GZyX0KRGk7asN3H1cxyPfwiSyqLDaPZ7WAb1VOhxuiOIGATKc1zCAXIPjxKDA6bv4pA6b1c1zCAXIPjxHlS0clpSyqf(JMEqvS4j7pJtlEq9DqLDaPZ7WAHlS0cXCyXGk7asN3H1cQFrpUOqqDNhPGnf8dpfHsisXdG6tPooPwyLAfvuQ3mcQ1skytb)WtrOecBeT7Cbi0o9INmp4fsQJtQnmOc)rtpOc1doJr6W8cxyPfeUHfdQSdiDEhwlO(f94IcbveuRLiw8K9NXPfpO(MGkk1cK6nJGATKlr)iCAXxeJhqlLGkk1cK6nJGATKlr)iCAXxeJhqlLu8aO(uQxPrQH)OPtG6bNXiDyEewb(rpgF0bhuH)OPhuH6bNXiDyEHlS0ccByXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlcQOulqQrqTwcup4mwmn5Iu8aO(uQxPrQB)TulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHcQWF00dQq9GZyeOkOLdxyPfw2HfdQSdiDEhwlOc)rtpOc1doJh05K25zq9JaQhuxiO(f94Icb1nJGATKlr)iCAXxeJhqlLGkk1cK6d6SFeOEWzm)rjHDaPZBPwGuJGATKndxeswot2PPl1cK6nJGATKlr)iCAXxeJhqlLu8aO(uQJtQH)OPtG6bNXd6Cs78KWkWp6X4JoyPwGuBGuhdsnetWf9ycup4mweDm4o1BjSdiDEl1kQOuJGATKVZq9W8OEl(Ja35ozNMUuRC4clTGWjSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOIGATKVZq9W8OElPy4VWfwAbHFyXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cKAdK6pZ(onDcup4mwmn5Iu8aO(uQJtQxWqPwrfLA4pQrgZopO8uQxPrQxUuRCqf(JMEqfQhCgNfs4clTWYkSyqLDaPZ7WAb1VOhxuiOIGATKc1zCAXIPjxeurPwrfL6b4ar8pPooPEbHnOc)rtpOc1doJr6W8cxyPLByyXGk7asN3H1cQWF00dQSX8HJMEqL6hxfQ4HP2G6aCGi(xCncFHnOs9JRcv8W0XG3u44G6cb1VOhxuiOIGATKc1zCAXIPjxKDA6HlS0YxiSyqf(JMEqfQhCgJavbTCqLDaPZ7WAHlCbvEoz)5zyXWslewmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZKlVbEakG)iOA5PulqQ)m7700jq9GZyX0KlsXdG6tPELgPU93sTIkk1wAB0HlEauFk1Ri1FM9DA6eOEWzSyAYfP4bq9zqf(JMEqfPN5gNw8fXy25r8HlS0Ydlguzhq68oSwq9l6XffcQFM9DA6eOEWzSyAYfP4bq9Pu3i1gk1cKAdK6yqQpOZ(ryVtBJo25nHDaPZBPwrfLAdK6d6SFe2702OJDEtyhq68wQfi1dWbI4FsDCnsTWXqPwrfLAJqrbKotGbEkcdPUrQxqQvwQvwQfi1gi1gi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mbeXdqb8M7q8sTaP2aPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQvurP2iuuaPZeyGNIWqQBK6fKALLALLAfvuQnqQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAeuRLa1doJ)iOAzY8GxiPUrQnuQvwQvwQfi1iOwlPqDgNwSyAYfzNMUulqQhGdeX)K64AKAJqrbKotar8G60b6apahWI)fuH)OPhur6zUXPfFrmMDEeF4clfZHfdQSdiDEhwlO(f94Icb1pZ(onDcup4mwmn5Iu8aO(uQJRrQfwdLAbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6vAK62Fl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZKlVbEakG)iOA5PulqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8bv4pA6bvZS6BJm1Xfpth8NdxyjHByXGk7asN3H1cQFrpUOqq9ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNsTaP(ZSVttNa1doJfttUifpaQpL6vAK62Fl1kQOuBPTrhU4bq9PuVIu)z23PPtG6bNXIPjxKIha1Nbv4pA6bvZS6BJm1Xfpth8NdxyjHnSyqLDaPZ7WAb1VOhxuiO(z23PPtG6bNXIPjxKIha1NsDJuBOulqQnqQJbP(Go7hH9oTn6yN3e2bKoVLAfvuQnqQpOZ(ryVtBJo25nHDaPZBPwGupahiI)j1X1i1chdLAfvuQncffq6mbg4PimK6gPEbPwzPwzPwGuBGuBGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAdKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiPwrfLAJqrbKotGbEkcdPUrQxqQvwQvwQvurP2aP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQrqTwcup4m(JGQLjZdEHK6gP2qPwzPwzPwGuJGATKc1zCAXIPjxKDA6sTaPEaoqe)tQJRrQncffq6mbeXdQthOd8aCal(xqf(JMEq1mR(2itDCXZ0b)5WfwAzhwmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZKlVbEakG)iOA5PulqQ)m7700jq9GZyX0KlsXdG6tPELgPU93sTIkk1wAB0HlEauFk1Ri1FM9DA6eOEWzSyAYfP4bq9zqf(JMEqTffQnfCCAXqmbx5ffUWscNWIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1nsTHsTaP2aPogK6d6SFe2702OJDEtyhq68wQvurP2aP(Go7hH9oTn6yN3e2bKoVLAbs9aCGi(NuhxJulCmuQvurP2iuuaPZeyGNIWqQBK6fKALLALLAbsTbsTbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL64KAJqrbKotar8auaV5oeVulqQnqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAfvuQncffq6mbg4PimK6gPEbPwzPwzPwrfLAdK6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTHsTaPgb1Ajq9GZ4pcQwMmp4fsQBKAdLALLALLAbsncQ1skuNXPflMMCr2PPl1cK6b4ar8pPoUgP2iuuaPZeqepOoDGoWdWbS4Fbv4pA6b1wuO2uWXPfdXeCLxu4clj8dlguzhq68oSwqf(JMEq9t)z)k44n22Hbhu)IECrHGkcQ1sG6bNXIPjxKDA6sTaPgb1AjfQZ40IfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPl1cK6b4a5OdgFjEaki1X1i1Sc8JEm(OdoO2PoJ)DqDzhUWslRWIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxKDA6sTaPgb1AjfQZ40IfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPl1cK6b4a5OdgFjEaki1X1i1Sc8JEm(OdoOc)rtpOwmis9wSTddEgUWslyyyXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700dQWF00dQ28rN8gdXeCrpgJWWiCHLwyHWIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxKDA6sTaPgb1AjfQZ40IfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPhuH)OPhufrlQnEQ3Ir6W8cxyPfwEyXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700dQWF00dQfvuSZyQJNIWZHlS0cXCyXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700dQWF00dQxeJrDKe13yBwphUWsliCdlguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMEqf(JMEqDWJSIhNwCh9PB8Uyymdx4cQFM9DA6ZWIHLwiSyqLDaPZ7WAb1VOhxuiOwOoBZQLjTfD2JhtF63zcVmOurrEl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQJzdLAbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6gP2qPwGuBGuJGATeOEWz8hbvltMh8cj1R0i1gHIciDMC5nWdqb8hbvlpLAbsTbsTbs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQvwQvurP2aPogK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTYsTIkk1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(BPwzPw5Gk8hn9GQTY5H90ieUWslpSyqLDaPZ7WAb1VOhxuiOwOoBZQLjTfD2JhtF63zcVmOurrEl1cK6pZ(onDcup4mwmn5Iu8aO(uQBKAdLAbsTbsDmi1h0z)iS3PTrh78MWoG05TuROIsTbs9bD2pc7DAB0XoVjSdiDEl1cK6b4ar8pPoUgPw4yOuRSuRSulqQnqQnqQ)m7700jxI(r40IVigpGwkP4bq9PuhNuVGHsTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQvwQvurP2aP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQrqTwcup4m(JGQLjZdEHK6gP2qPwzPwzPwGuJGATKc1zCAXIPjxKDA6sTaPEaoqe)tQJRrQncffq6mbeXdQthOd8aCal(xqf(JMEq1w58WEAecxyPyoSyqLDaPZ7WAb1VOhxuiOwOoBZQLjB68PIDQdv84phdW3eEzqPII8wQfi1FM9DA6eeuRfVPZNk2PouXJ)CmaFtkg2Xl1cKAeuRLSPZNk2PouXJ)CmaFJTvopYonDPwGuBGuJGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6sTYsTaP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQnqQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNsTaP2aP2aP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtkuNXPflMMCrkEauFk1R0i1T)wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1kl1kQOuBGuhds9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNa1doJfttUifpaQpL64KAJqrbKotU8g4bOaEZDiEPwzPwrfL6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)TuRSuRCqf(JMEq1w58qY(fUWsc3WIbv2bKoVdRfu)IECrHGAH6SnRwMSPZNk2PouXJ)CmaFt4LbLkkYBPwGu)z23PPtqqTw8MoFQyN6qfp(ZXa8nPyyhVulqQrqTwYMoFQyN6qfp(ZXa8n2slMSttxQfi1IfBe3(BYceBLZdj7xqf(JMEq1slgJ0H5fUWscByXGk7asN3H1cQFrpUOqq9ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNsTaP(ZSVttNa1doJfttUifpaQpL6vAK62FhuH)OPhuh0QYAItl(YAW(fUWsl7WIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1nsTHsTaP2aPogK6d6SFe2702OJDEtyhq68wQvurP2aP(Go7hH9oTn6yN3e2bKoVLAbs9aCGi(NuhxJulCmuQvwQvwQfi1gi1gi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mbeXdqb8M7q8sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQvwQvurP2aP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQrqTwcup4m(JGQLjZdEHK6gP2qPwzPwzPwGuJGATKc1zCAXIPjxKDA6sTaPEaoqe)tQJRrQncffq6mbeXdQthOd8aCal(xqf(JMEqDqRkRjoT4lRb7x4cljCclguzhq68oSwq9l6XffcQFM9DA6Klr)iCAXxeJhqlLu8aO(uQBKAdLAbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zYL3apafWFeuT8uQfi1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(7Gk8hn9G6MHlcjlNdxyjHFyXGk7asN3H1cQFrpUOqq9ZSVttNa1doJfttUifpaQpL6gP2qPwGuBGuhds9bD2pc7DAB0XoVjSdiDEl1kQOuBGuFqN9JWEN2gDSZBc7asN3sTaPEaoqe)tQJRrQfogk1kl1kl1cKAdKAdK6pZ(onDYLOFeoT4lIXdOLskEauFk1Xj1lyOulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKALLAfvuQnqQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAeuRLa1doJ)iOAzY8GxiPUrQnuQvwQvwQfi1iOwlPqDgNwSyAYfzNMUulqQhGdeX)K64AKAJqrbKotar8G60b6apahWI)fuH)OPhu3mCriz5C4clTSclguzhq68oSwq9l6XffcQFM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mPM4bOaEZDiEPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNj1epafWBUdXl1cKAdK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwrfL6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuhNuBekkG0zsnXdqb8M7q8sTIkk1XGuFqN9JuOoJtlwmn5IWoG05TuRSulqQrqTwcup4m(JGQLjZdEHK64K6Ll1cK6nJGATKlr)iCAXxeJhqlLSttpOc)rtpOwWMc(HNIqju4clTGHHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1nsTHsTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)Dqf(JMEqTGnf8dpfHsOWfwAHfclguzhq68oSwq9l6XffcQFM9DA6eOEWzSyAYfP4bq9Pu3i1gk1cKAdKAdK6yqQpOZ(ryVtBJo25nHDaPZBPwrfLAdK6d6SFe2702OJDEtyhq68wQfi1dWbI4FsDCnsTWXqPwzPwzPwGuBGuBGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiPwzPwrfLAdK6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTHsTaPgb1Ajq9GZ4pcQwMmp4fsQBKAdLALLALLAbsncQ1skuNXPflMMCr2PPl1cK6b4ar8pPoUgP2iuuaPZeqepOoDGoWdWbS4FsTYbv4pA6b1c2uWp8uekHcxyPfwEyXGk7asN3H1cQFrpUOqq9ZSVttNa1doJfttUifpaQpL6vKAH1qPwGuZZj7ptmsN00XPflYLL)JMozq9ScQWF00dQxI(r40IVigpGwA4clTqmhwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNsTaP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtkuNXPflMMCrkEauFk1R0i1T)wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1cK6pnYo4hrO4lk4sTaP(ZSVttNuWMc(HNIqjeP4bq9PuVsJul8dQWF00dQxI(r40IVigpGwA4clTGWnSyqLDaPZ7WAb1VOhxuiOIGATeOEWz8hbvltMh8cj1R0i1gHIciDMC5nWdqb8hbvlpLAbs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQfi1XGu)Pr2b)icfFrbpOc)rtpOEj6hHtl(Iy8aAPHlS0ccByXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6yqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXhuH)OPhuVe9JWPfFrmEaT0WfwAHLDyXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)Dqf(JMEq9s0pcNw8fX4b0sdxyPfeoHfdQSdiDEhwlO(f94IcbvdK6yqQpOZ(ryVtBJo25nHDaPZBPwrfLAdK6d6SFe2702OJDEtyhq68wQfi1dWbI4FsDCnsTWXqPwzPwzPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiPwGuJGATKc1zCAXIPjxKDA6sTaPEaoqe)tQJRrQncffq6mbeXdQthOd8aCal(xqf(JMEqfQhCglMMCfUWsli8dlguzhq68oSwq9l6XffcQiOwlPqDgNwSyAYfzNMUulqQ)m7700jxI(r40IVigpGwkP4bq9PuhNuBekkG0zsLI4bOaEZDiEPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1cKAdK6pZ(onDcup4mwmn5Iu8aO(uQJtQxqyLAfvuQ3mcQ1sUe9JWPfFrmEaTucQOuRCqf(JMEqTqDgNwSyAYv4clTWYkSyqLDaPZ7WAb1VOhxuiOIGATeOEWz8hbvltMh8cj1nsTHsTaP(tJSd(rek(IcEqf(JMEqvS4j7pJtlEq9D4clTCddlguzhq68oSwq9l6XffcQBgb1AjxI(r40IVigpGwkbvuQfi1XGu)Pr2b)icfFrbpOc)rtpOkw8K9NXPfpO(oCHlOw5bhn9WIHLwiSyqLDaPZ7WAb1umOo5lOc)rtpOAekkG05GQrOJYb1fcQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQfi1XGuJGATKcTZ40IVOI5jbvuQfi1wAB0HlEauFk1R0i1gi1gi1dWbPEvPg(JMobQhCgJ0H5r(CEsTYsTWqsn8hnDcup4mgPdZJWkWp6X4JoyPw5GQrOWom4GQL6qhJGwE4clT8WIbv2bKoVdRfu)IECrHG6NzFNMo5s0pcNw8fX4b0sjfpaQpL6gP2qPwGuBGuJGATeOEWz8hbvltMh8cj1Xj1gHIciDMC5nWdqb8hbvlpLAbs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQfi1FAKDWpIqXxuWLAbs9NzFNMoPGnf8dpfHsisXdG6tPELgPw4l1khuH)OPhuH6bNXiqvqlhUWsXCyXGk7asN3H1cQFrpUOqq9ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuBOulqQnqQrqTwcup4m(JGQLjZdEHK64KAJqrbKotU8g4bOa(JGQLNsTaP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtkuNXPflMMCrkEauFk1R0i1T)wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1cK6yqQ)0i7GFeHIVOGl1khuH)OPhuH6bNXiqvqlhUWsc3WIbv2bKoVdRfu)IECrHG6NzFNMo5s0pcNw8fX4b0sjfpaQpL6gP2qPwGuBGuJGATeOEWz8hbvltMh8cj1Xj1gHIciDMC5nWdqb8hbvlpLAbsDmi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQncffq6m5YBGhGc4n3H4LALdQWF00dQq9GZyeOkOLdxyjHnSyqLDaPZ7WAb1VOhxuiO(z23PPtUe9JWPfFrmEaTusXdG6tPUrQnuQfi1gi1iOwlbQhCg)rq1YK5bVqsDCsTrOOasNjxEd8aua)rq1YtPwGu)z23PPtG6bNXIPjxKIha1Ns9knsD7VLALdQWF00dQq9GZyeOkOLdxyPLDyXGk7asN3H1cQFrpUOqqDZiOwlPGnf8dpfHsiSr0UZfGq70lEY8GxiPUrQ3mcQ1skytb)WtrOecBeT7Cbi0o9INmafWZdEHKAbsTbsncQ1sG6bNXIPjxKDA6sTIkk1iOwlbQhCglMMCrkEauFk1R0i1T)wQvwQfi1gi1iOwlPqDgNwSyAYfzNMUuROIsncQ1skuNXPflMMCrkEauFk1R0i1T)wQvoOc)rtpOc1doJrGQGwoCHLeoHfdQSdiDEhwlO(f94Icb1DEKc2uWp8uekHifpaQpL64KAHvQvurPEZiOwlPGnf8dpfHsiSr0UZfGq70lEY8GxiPooP2WGk8hn9Gkup4mgPdZlCHLe(HfdQSdiDEhwlO(f94IcbveuRLiw8K9NXPfpO(MGkk1cK6nJGATKlr)iCAXxeJhqlLGkk1cK6nJGATKlr)iCAXxeJhqlLu8aO(uQxPrQH)OPtG6bNXiDyEewb(rpgF0bhuH)OPhuH6bNXiDyEHlS0YkSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOUzeuRLCj6hHtl(Iy8aAPeurPwGuFqN9Ja1doJ5pkjSdiDEl1cKAeuRLSz4IqYYzYonDPwGuBGuVzeuRLCj6hHtl(Iy8aAPKIha1NsDCsn8hnDcup4mEqNtANNewb(rpgF0bl1kQOu)z23PPtelEY(Z40IhuFtkEauFk1Xj1gk1kQOu)Pr2b)icfFrbxQvwQfi1gi1XGudXeCrpMa1doJfrhdUt9wc7asN3sTIkk1iOwl57mupmpQ3I)iWDUt2PPl1khUWslyyyXGk7asN3H1cQFrpUOqqfb1AjFNH6H5r9wsXWFsTaPgb1AjScIGV5nwmp2pk0jOIbv4pA6bvOEWz8GoN0opdxyPfwiSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOIGATKVZq9W8OElPy4pPwGuBGuJGATeOEWzSyAYfbvuQvurPgb1AjfQZ40IfttUiOIsTIkk1Bgb1AjxI(r40IVigpGwkP4bq9PuhNud)rtNa1doJh05K25jHvGF0JXhDWsTYHlS0clpSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOIGATKVZq9W8OElPy4pPwGuJGATKVZq9W8OElzEWlKu3i1iOwl57mupmpQ3sgGc45bVqHlS0cXCyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqfb1AjFNH6H5r9wsXWFsTaPgb1AjFNH6H5r9wsXdG6tPELgP2aP2aPgb1AjFNH6H5r9wY8GxiPwyiPg(JMobQhCgpOZjTZtcRa)OhJp6GLALL61L62Fl1khUWsliCdlguzhq68oSwq9l6XffcQgi1fBlEgbiDwQvurPogK6J(cr9wPwzPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1cKAeuRLa1doJfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPhuH)OPhuD(I4cF8qKNx4clTGWgwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNbv4pA6bvOEWzCwiHlS0cl7WIbv2bKoVdRfu)IECrHG6aCGi(NuVsJuVSewPwGuJGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6bv4pA6b1jQixEAecxyPfeoHfdQSdiDEhwlO(f94IcbveuRLa1doJfttUi700LAbsncQ1skuNXPflMMCr2PPl1cK6nJGATKlr)iCAXxeJhqlLSttxQfi1FM9DA6e2y(WrtNu8aO(uQJtQnuQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBOulqQ)m7700jxI(r40IVigpGwkP4bq9PuhNuBOulqQnqQJbP(Go7hPqDgNwSyAYfHDaPZBPwrfLAdK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuhNuBOuRSuRCqf(JMEqDgrTh1BXIPjxHlS0cc)WIbv2bKoVdRfu)IECrHGkcQ1sk0oJtl(IkMNeurPwGuJGATeOEWz8hbvltMh8cj1Xj1XCqf(JMEqfQhCgJ0H5fUWslSSclguzhq68oSwq9l6XffcQdWbI4Fs9ksTrOOasNjiqvqlJhGdyX)KAbs9NzFNMoHnMpC00jfpaQpL64KAdLAbsncQ1sG6bNXIPjxKDA6sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQfi18CY(ZeJ0jnDCAXICz5)OPtgupRGk8hn9Gkup4mgbQcA5WfwA5ggwmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAdK6pZ(onDsH6moTyX0KlsXdG6tPUrQnuQvurP(ZSVttNa1doJfttUifpaQpL6gP2qPwzPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cfuH)OPhuH6bNXiqvqlhUWslFHWIbv2bKoVdRfu)IECrHG6aCGi(NuVsJuBekkG0zccuf0Y4b4aw8pPwGuJGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQfi1FM9DA6e2y(WrtNu8aO(uQJtQnmOc)rtpOc1doJrGQGwoCHLw(Ydlguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMUulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAbs9bD2pcup4molec7asN3sTaP(ZSVttNa1doJZcHu8aO(uQxPrQB)TulqQhGdeX)K6vAK6LLHsTaP(ZSVttNWgZhoA6KIha1NsDCsTHbv4pA6bvOEWzmcuf0YHlS0YJ5WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeurPwGuJGATeOEWzSyAYfP4bq9PuVsJu3(BPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cfuH)OPhuH6bNXiqvqlhUWslx4gwmOYoG05DyTG6x0JlkeurqTwsH6moTyX0KlcQOulqQrqTwsH6moTyX0KlsXdG6tPELgPU93sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fkOc)rtpOc1doJrGQGwoCHLwUWgwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTucQOulqQ3mcQ1sUe9JWPfFrmEaTusXdG6tPELgPU93sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fkOc)rtpOc1doJrGQGwoCHLw(YoSyqf(JMEqfQhCgJ0H5fuzhq68oSw4clTCHtyXGk1pUkuXdtTb1b4ar8V4Ae(cBqL6hxfQ4HPJbVPWXb1fcQWF00dQSX8HJMEqLDaPZ7WAHlS0Yf(HfdQWF00dQq9GZyeOkOLdQSdiDEhwlCHlOcd8uegHfdlTqyXGk7asN3H1cQFrpUOqqfb1AjfQZ40IfttUi700LAbs9NzFNMobQhCglMMCrkEauFk1Xj1gguH)OPhuluNXPflMMCfUWslpSyqLDaPZ7WAb1VOhxuiOAGu)z23PPtG6bNXIPjxKIha1NsDJuBOulqQrqTwsH6moTyX0KlYonDPwzPwrfLAXInIB)nzbsH6moTyX0KRGk8hn9G6LOFeoT4lIXdOLgUWsXCyXGk7asN3H1cQFrpUOqq9ZSVttNa1doJfttUifpaQpL6vKAH1qPwGuJGATKc1zCAXIPjxKDA6sTaPMNt2FMyKoPPJtlwKll)hnDc7asN3bv4pA6b1lr)iCAXxeJhqlnCHLeUHfdQSdiDEhwlO(f94IcbveuRLuOoJtlwmn5ISttxQfi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mbeXdqb8M7q8bv4pA6bvOEWzSyAYv4cljSHfdQSdiDEhwlO(f94IcbveuRLa1doJfttUiOIsTaPgb1Ajq9GZyX0KlsXdG6tPELgPg(JMobQhCgpOZjTZtcRa)OhJp6GLAbsncQ1sG6bNXFeuTmzEWlKu3i1iOwlbQhCg)rq1YKbOaEEWluqf(JMEqfQhCgJavbTC4clTSdlguzhq68oSwq9l6XffcQiOwlbQhCg)rq1YK5bVqs9ksncQ1sG6bNXFeuTmzakGNh8cj1cKAeuRLuOoJtlwmn5ISttxQfi1iOwlbQhCglMMCr2PPl1cK6nJGATKlr)iCAXxeJhqlLSttpOc)rtpOc1doJZcjCHLeoHfdQSdiDEhwlO(f94IcbveuRLuOoJtlwmn5ISttxQfi1iOwlbQhCglMMCr2PPl1cK6nJGATKlr)iCAXxeJhqlLSttxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqbv4pA6bvOEWzmcuf0YHlSKWpSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOIGATKVZq9W8OElPy4VWfwAzfwmOYoG05DyTGk8hn9Gkup4mEqNtANNb1pcOEqDHG6x0JlkeuJbPgIj4IEmbQhCglIogCN6Te2bKoVLAfvuQrqTwY3zOEyEuVf)rG7CNSttpCHLwWWWIbv2bKoVdRfu)IECrHGk8hnDcBmF4OPt(iWDUt9wPwGupahiI)j1X1i1llHnOc)rtpO(G)Chd)rtpCHLwyHWIbv4pA6bv2y(WrtpOYoG05DyTWfwAHLhwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vKAeuRLa1doJ)iOAzYauapp4fkOc)rtpOc1doJZcjCHLwiMdlguH)OPhuH6bNXiqvqlhuzhq68oSw4clTGWnSyqf(JMEqfQhCgJ0H5fuzhq68oSw4cxqDZwaTFHfdlTqyXGk7asN3H1cQFrpUOqq9GQLpYMrqTwYdZJ6TKIH)cQWF00dQFI6hxtrU3dxyPLhwmOYoG05DyTGk8hn9G6d9og(JMoUtNxqTtNh2HbhuNrqXB8VNHlSumhwmOYoG05DyTGk8hn9G6d9og(JMoUtNxqTtNh2Hbhu55K9NNHlSKWnSyqLDaPZ7WAb1VOhxuiOc)rnYy25bLNsDCs9YdQWF00dQp07y4pA64oDEb1oDEyhgCqfsoCHLe2WIbv2bKoVdRfu)IECrHGQrOOasNjrGrgNISZBPELgP2WGk8hn9G6d9og(JMoUtNxqTtNh2Hbhutr25kCHLw2HfdQSdiDEhwlO(f94IcbvJqrbKotGbEkcdPUrQxiOc)rtpO(qVJH)OPJ705fu705HDyWbvyGNIWiCHLeoHfdQSdiDEhwlOc)rtpO(qVJH)OPJ705fu705HDyWb1pZ(on9z4clj8dlguzhq68oSwq9l6XffcQgHIciDMyPo0XiOLl1nsTHbv4pA6b1h6Dm8hnDCNoVGANopSddoOw5bhn9WfwAzfwmOYoG05DyTG6x0Jlkeuncffq6mXsDOJrqlxQBK6fcQWF00dQp07y4pA64oDEb1oDEyhgCq1sDOJrqlpCHLwWWWIbv2bKoVdRfuH)OPhuFO3XWF00XD68cQD68Wom4G6inYd2VWfUGQyXFoqGlSyyPfclguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GQyXIO9oMnMb1nBb0(funmCHLwEyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQleu)IECrHGQrOOasNjIflI27y2yk1nsTHsTaPUqD2MvltMuXO0XZlRbHxguQOiVLAbsn8h1iJzNhuEk1Xj1lpOAekSddoOkwSiAVJzJz4clfZHfdQSdiDEhwlOMIb1jFbv4pA6bvJqrbKohuncDuoOUqq9l6XffcQgHIciDMiwSiAVJzJPu3i1gk1cK6c1zBwTmzsfJshpVSgeEzqPII8wQfi1FAKDWpIZFL9S2sTaPg(JAKXSZdkpL64K6fcQgHc7WGdQIflI27y2ygUWsc3WIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhuxiO(f94IcbvJqrbKotelweT3XSXuQBKAdLAbsDH6SnRwMmPIrPJNxwdcVmOurrEl1cK6pnYo4hXPTrh2cCq1iuyhgCqvSyr0EhZgZWfwsydlguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GAeyKXPi78oOUzlG2VGQHHlS0YoSyqLDaPZ7WAb1umOo5lOc)rtpOAekkG05GQrOJYb1fcQFrpUOqq1iuuaPZKiWiJtr25Tu3i1gk1cKA4pQrgZopO8uQJtQxEq1iuyhgCqncmY4uKDEhUWscNWIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhuxiO(f94IcbvJqrbKotIaJmofzN3sDJuBOulqQncffq6mrSyr0EhZgtPUrQxiOAekSddoOgbgzCkYoVdxyjHFyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQgguncf2HbhuTuh6ye0YdxyPLvyXGk7asN3H1cQPyqT4jFbv4pA6bvJqrbKohuncf2HbhuRjEakG3ChIpOUzlG2VGQWgUWslyyyXGk7asN3H1cQPyqT4jFbv4pA6bvJqrbKohuncf2Hbhubr8auaV5oeFqDZwaTFb1fmmCHLwyHWIbv2bKoVdRfutXGAXt(cQWF00dQgHIciDoOAekSddoOwPiEakG3ChIpOUzlG2VG6YnmCHLwy5HfdQSdiDEhwlOMIb1IN8fuH)OPhuncffq6Cq1iuyhgCq9YBGhGc4n3H4dQB2cO9lOkSHlS0cXCyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQXCq9l6XffcQgHIciDMC5nWdqb8M7q8sDJulSsTaPUqD2Mvlt205tf7uhQ4XFogGVj8YGsff5Dq1iuyhgCq9YBGhGc4n3H4dxyPfeUHfdQSdiDEhwlOMIb1jFbv4pA6bvJqrbKohuncDuoOUGWgu)IECrHGQrOOasNjxEd8auaV5oeVu3i1cRulqQ)0i7GFeN2gDylWbvJqHDyWb1lVbEakG3ChIpCHLwqydlguzhq68oSwqnfdQt(cQWF00dQgHIciDoOAe6OCqDbHnO(f94IcbvJqrbKotU8g4bOaEZDiEPUrQfwPwGu)PVrPhbQhCglw5M2gpHDaPZBPwGud)rnYy25bLNs9ksDmhuncf2HbhuV8g4bOaEZDi(WfwAHLDyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQXSHb1VOhxuiOAekkG0zYL3apafWBUdXl1nsTWk1cKAEoz)zIr6KMooTyrUS8F00jdQNvq1iuyhgCq9YBGhGc4n3H4dxyPfeoHfdQSdiDEhwlOMIb1IN8fuH)OPhuncffq6Cq1iuyhgCqfbQcAz8aCal(xqDZwaTFbvHJHHlS0cc)WIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhufUggu)IECrHGQrOOasNjiqvqlJhGdyX)K6gPw4yOulqQ)0i7GFeN2gDylWbvJqHDyWbveOkOLXdWbS4FHlS0clRWIbv2bKoVdRfutXGAXt(cQWF00dQgHIciDoOAekSddoOcI4b1Pd0bEaoGf)lOUzlG2VGAmBy4clTCddlguzhq68oSwqnfdQt(cQWF00dQgHIciDoOAe6OCqvynmO(f94IcbvJqrbKotar8G60b6apahWI)j1nsDmBOulqQluNTz1YKnD(uXo1HkE8NJb4BcVmOurrEhuncf2Hbhubr8G60b6apahWI)fUWslFHWIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhufwddQFrpUOqq1iuuaPZeqepOoDGoWdWbS4FsDJuhZgk1cK6c1zBwTmPTOZE8y6t)ot4LbLkkY7GQrOWom4GkiIhuNoqh4b4aw8VWfwA5lpSyqLDaPZ7WAb1umOw8KVGk8hn9GQrOOasNdQgHc7WGdQxEd8aua)rq1YZG6MTaA)cQlpCHLwEmhwmOYoG05DyTGAkgulEYxqf(JMEq1iuuaPZbvJqHDyWbviz8L3apafWFeuT8mOUzlG2VG6YdxyPLlCdlguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GkmWtryeu3Sfq7xqDY3r92jbg4PimcxyPLlSHfdQSdiDEhwlCHLw(YoSyqLDaPZ7WAHlS0YfoHfdQSdiDEhwlCHLwUWpSyqf(JMEqDIogPJH6bNXwyq7uOcQSdiDEhwlCHLw(YkSyqf(JMEqfQhCgt9J7D(VGk7asN3H1cxyPy2WWIbv4pA6b1pDHhqlgpahWT8iOYoG05DyTWfwkMxiSyqLDaPZ7WAHlSumV8WIbv4pA6b1bTQSW0b0Ybv2bKoVdRfUWsXCmhwmOYoG05DyTG6x0Jlkeuncffq6mrSyr0EhZgtPELgP2WGk8hn9GQTY5HK9lCHLIzHByXGk7asN3H1cQFrpUOqq1iuuaPZeXIfr7DmBmL64KAddQWF00dQSX8HJME4cxqfsoSyyPfclguzhq68oSwq9l6XffcQfQZ2SAzYMoFQyN6qfp(ZXa8nHxguQOiVLAbs9NzFNMobb1AXB68PIDQdv84phdW3KIHD8sTaPgb1AjB68PIDQdv84phdW3yBLZJSttxQfi1gi1iOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMUuRSulqQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAdKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQfi1gi1gi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPELgPU93sTaP(ZSVttNa1doJfttUifpaQpL64KAJqrbKotU8g4bOaEZDiEPwzPwrfLAdK6yqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1kl1kQOu)z23PPtG6bNXIPjxKIha1Ns9knsD7VLALLALdQWF00dQ2kNhs2VWfwA5HfdQSdiDEhwlO(f94IcbvdK6c1zBwTmztNpvStDOIh)5ya(MWldkvuK3sTaP(ZSVttNGGAT4nD(uXo1HkE8NJb4BsXWoEPwGuJGATKnD(uXo1HkE8NJb4BSLwmzNMUulqQfl2iU93Kfi2kNhs2pPwzPwrfLAdK6c1zBwTmztNpvStDOIh)5ya(MWldkvuK3sTaP(OdwQBKAdLALdQWF00dQwAXyKomVWfwkMdlguzhq68oSwq9l6XffcQfQZ2SAzsBrN94X0N(DMWldkvuK3sTaP(ZSVttNa1doJfttUifpaQpL64K6y2qPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQnuQfi1gi1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PulqQnqQnqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTYsTIkk1gi1XGuFqN9JuOoJtlwmn5IWoG05TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQvwQvurP(ZSVttNa1doJfttUifpaQpL6vAK62Fl1kl1khuH)OPhuTvopSNgHWfws4gwmOYoG05DyTG6x0JlkeuluNTz1YK2Io7XJPp97mHxguQOiVLAbs9NzFNMobQhCglMMCrkEauFk1nsTHsTaP2aP2aP2aP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTrOOasNjGiEakG3ChIxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqsTYsTIkk1gi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQBKAdLAbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zcKm(YBGhGc4pcQwEk1kl1kl1cKAeuRLuOoJtlwmn5ISttxQvoOc)rtpOARCEypncHlSKWgwmOYoG05DyTG6x0JlkeuluNTz1YKjvmkD88YAq4LbLkkYBPwGulwSrC7VjlqyJ5dhn9Gk8hn9G6LOFeoT4lIXdOLgUWsl7WIbv2bKoVdRfu)IECrHGAH6SnRwMmPIrPJNxwdcVmOurrEl1cKAdKAXInIB)nzbcBmF4OPl1kQOulwSrC7VjlqUe9JWPfFrmEaTuPw5Gk8hn9Gkup4mwmn5kCHLeoHfdQSdiDEhwlO(f94Icb1JoyPooPoMnuQfi1fQZ2SAzYKkgLoEEzni8YGsff5TulqQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotGKXxEd8aua)rq1YtPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQnuQfi1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(7Gk8hn9GkBmF4OPhUWsc)WIbv2bKoVdRfuH)OPhuzJ5dhn9Gk1pUkuXdtTbveuRLmPIrPJNxwdY8GxOgeuRLmPIrPJNxwdYauapp4fkOs9JRcv8W0XG3u44G6cb1VOhxuiOE0bl1Xj1XSHsTaPUqD2MvltMuXO0XZlRbHxguQOiVLAbs9NzFNMobQhCglMMCrkEauFk1nsTHsTaP2aP2aP2aP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTrOOasNjGiEakG3ChIxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqsTYsTIkk1gi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQBKAdLAbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zcKm(YBGhGc4pcQwEk1kl1kl1cKAeuRLuOoJtlwmn5ISttxQvoCHLwwHfdQSdiDEhwlO(f94IcbvdK6pZ(onDcup4mwmn5Iu8aO(uQJtQfUcRuROIs9NzFNMobQhCglMMCrkEauFk1R0i1XSuRSulqQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAdKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQfi1gi1gi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPELgPU93sTaP(ZSVttNa1doJfttUifpaQpL64KAHvQvwQvurP2aPogK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMobQhCglMMCrkEauFk1Xj1cRuRSuROIs9NzFNMobQhCglMMCrkEauFk1R0i1T)wQvwQvoOc)rtpOoOvL1eNw8L1G9lCHLwWWWIbv2bKoVdRfu)IECrHG6NzFNMo5s0pcNw8fX4b0sjfpaQpL64KAJqrbKotQjEakG3ChIxQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zsnXdqb8M7q8sTaP2aP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtkuNXPflMMCrkEauFk1R0i1T)wQvurP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtkuNXPflMMCrkEauFk1Xj1gHIciDMut8auaV5oeVuROIsDmi1h0z)ifQZ40IfttUiSdiDEl1kl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQfi1Bgb1AjxI(r40IVigpGwkzNMEqf(JMEqTGnf8dpfHsOWfwAHfclguzhq68oSwq9l6XffcQFM9DA6Klr)iCAXxeJhqlLu8aO(uQBKAdLAbsTbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zcKm(YBGhGc4pcQwEk1cKAdKAdK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeVuRSuROIsTbsDmi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQncffq6m5YBGhGc4n3H4LALLAfvuQ)m7700jq9GZyX0KlsXdG6tPELgPU93sTYsTYbv4pA6b1c2uWp8uekHcxyPfwEyXGk7asN3H1cQFrpUOqq9ZSVttNa1doJfttUifpaQpL6gP2qPwGuBGuBGuBGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiPwzPwrfLAdK6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTHsTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6mbsgF5nWdqb8hbvlpLALLALLAbsncQ1skuNXPflMMCr2PPl1khuH)OPhulytb)WtrOekCHLwiMdlguzhq68oSwq9l6XffcQFM9DA6eOEWzSyAYfP4bq9Pu3i1gk1cKAdKAdKAdK6pZ(onDYLOFeoT4lIXdOLskEauFk1Xj1gHIciDMaI4bOaEZDiEPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1kl1kQOuBGu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQnuQfi1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PuRSuRSulqQrqTwsH6moTyX0KlYonDPw5Gk8hn9G6MHlcjlNdxyPfeUHfdQSdiDEhwlO(f94IcbveuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQfi1gi1gi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPELgPU93sTaP(ZSVttNa1doJfttUifpaQpL64KAJqrbKotU8g4bOaEZDiEPwzPwrfLAdK6yqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1kl1kQOu)z23PPtG6bNXIPjxKIha1Ns9knsD7VLALdQWF00dQxI(r40IVigpGwA4clTGWgwmOYoG05DyTG6x0JlkeunqQnqQ)m7700jxI(r40IVigpGwkP4bq9PuhNuBekkG0zciIhGc4n3H4LAbsncQ1sG6bNXFeuTmzEWlKu3i1iOwlbQhCg)rq1YKbOaEEWlKuRSuROIsTbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6gP2qPwGuJGATeOEWz8hbvltMh8cj1R0i1gHIciDMajJV8g4bOa(JGQLNsTYsTYsTaPgb1AjfQZ40IfttUi700dQWF00dQq9GZyX0KRWfwAHLDyXGk7asN3H1cQFrpUOqqfb1AjfQZ40IfttUi700LAbsTbsTbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL64K6LBOulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKALLAfvuQnqQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1gk1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQvwQvwQfi1gi1FM9DA6eOEWzSyAYfP4bq9PuhNuVGWk1kQOuVzeuRLCj6hHtl(Iy8aAPeurPw5Gk8hn9GAH6moTyX0KRWfwAbHtyXGk7asN3H1cQFrpUOqqfb1AjBgUiKSCMGkk1cK6nJGATKlr)iCAXxeJhqlLGkk1cK6nJGATKlr)iCAXxeJhqlLu8aO(uQxPrQrqTwIyXt2FgNw8G6BYauapp4fsQfgsQH)OPtG6bNXiDyEewb(rpgF0bhuH)OPhuflEY(Z40IhuFhUWsli8dlguzhq68oSwq9l6XffcQiOwlzZWfHKLZeurPwGuBGuBGuFqN9Ju8mDWFMWoG05TulqQH)Ogzm78GYtPEfPw4k1kl1kQOud)rnYy25bLNs9ksTWk1khuH)OPhuH6bNXiDyEHlS0clRWIbv4pA6b1jQixEAecQSdiDEhwlCHLwUHHfdQSdiDEhwlO(f94IcbveuRLa1doJ)iOAzY8GxiPUrQnmOc)rtpOc1doJZcjCHLw(cHfdQSdiDEhwlO(f94IcbvdK6ITfpJaKol1kQOuhds9rFHOERuRSulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHcQWF00dQoFrCHpEiYZlCHLw(Ydlguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMUulqQ)m7700jq9GZyX0KlsXdG6tPooP2qPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2qPwGuBGuhds9bD2psH6moTyX0Klc7asN3sTIkk1gi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPooP2qPwzPw5Gk8hn9G6mIApQ3IfttUcxyPLhZHfdQSdiDEhwlO(f94IcbveuRL8DgQhMh1Bjfd)j1cK6c1zBwTmbQhCgtDl1Px8eEzqPII8wQfi1h0z)iWqStT0hoA6e2bKoVLAbsn8h1iJzNhuEk1Ri1lRGk8hn9Gkup4mEqNtANNHlS0YfUHfdQSdiDEhwlO(f94IcbveuRL8DgQhMh1Bjfd)j1cK6c1zBwTmbQhCgtDl1Px8eEzqPII8wQfi1WFuJmMDEq5PuVIuVSdQWF00dQq9GZ4bDoPDEgUWslxydlguzhq68oSwq9l6XffcQiOwlbQhCg)rq1YK5bVqs9ksncQ1sG6bNXFeuTmzakGNh8cfuH)OPhuH6bNXScI9CstpCHLw(YoSyqLDaPZ7WAb1VOhxuiOIGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1cKAXInIB)nzbcup4mgbQcA5Gk8hn9Gkup4mMvqSNtA6HlS0YfoHfdQSdiDEhwlO(f94IcbveuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxOGk8hn9Gkup4mgbQcA5WfwA5c)WIbvQFCvOIhMAdQdWbI4FX1i8f2Gk1pUkuXdthdEtHJdQleuH)OPhuzJ5dhn9Gk7asN3H1cx4cQZiO4n(3ZWIHLwiSyqLDaPZ7WAb1VOhxuiOAGuFqN9JWEN2gDSZBc7asN3sTaPEaoqe)tQxPrQf(gk1cK6b4ar8pPoUgPEzlSsTYsTIkk1gi1XGuFqN9JWEN2gDSZBc7asN3sTaPEaoqe)tQxPrQf(cRuRCqf(JMEqDaoGB5r4clT8WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeuXGk8hn9Gk6KX0JhZWfwkMdlguzhq68oSwq9l6XffcQiOwlbQhCglMMCrqfdQWF00dQI5rtpCHLeUHfdQSdiDEhwlO(f94Icb1c1zBwTm54HywqhBcLiHxguQOiVLAbsncQ1syfIa05rtNGkguH)OPhup6GXMqjgUWscByXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700dQWF00dQDAB0nXcpGUBhSFHlS0YoSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6bv4pA6bveOfNw8v0xOz4cljCclguzhq68oSwq9l6XffcQiOwlbQhCglMMCrqfdQWF00dQiCn5siQ3gUWsc)WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeuXGk8hn9GkspZn2IwXhUWslRWIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeuXGk8hn9GQLwmspZD4clTGHHfdQSdiDEhwlO(f94IcbveuRLa1doJfttUiOIbv4pA6bvWFEEf0Xp07HlCb1rAKhSFHfdlTqyXGk7asN3H1cQFrpUOqqDKg5b7hztNh4pl1X1i1lyyqf(JMEqfPtDHcxyPLhwmOc)rtpOkw8K9NXPfpO(oOYoG05DyTWfwkMdlguzhq68oSwq9l6XffcQJ0ipy)iB68a)zPEfPEbddQWF00dQq9GZ4bDoPDEgUWsc3WIbv4pA6bvOEWzCwibv2bKoVdRfUWscByXGk8hn9GQLwmgPdZlOYoG05DyTWfUGQL6qhJGwEyXWslewmOYoG05DyTGk8hn9Gkup4mEqNtANNb1pcOEqDHG6x0JlkeurqTwY3zOEyEuVLum8x4clT8WIbv4pA6bvOEWzmshMxqLDaPZ7WAHlSumhwmOc)rtpOc1doJrGQGwoOYoG05DyTWfUWfunY1KMEyPLB4YnCbdxUHbvtOCQ3odQcdtyGWJlj8APyAfgLAPEXiwQPdXSoP2MLuhJvEWrtpgL6IxguAXBPEMdwQb0lhWXBP(JaVLNezSXKuNL6fegL6yQ0nY1XBPwLoIPK6z8(bki1cpxQVuQJjrbPEtnsN00L6uKl4YsQnyvLLAdwqbLjYyJjPol1lxyuQJPs3ixhVL6y8tJSd(reMjSdiDEhJs9LsDm(Pr2b)icZXOuBWckOmrgBmj1zPoMfgL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gSGcktKXgtsDwQxwcJsDmv6g564TuhJFAKDWpIWmHDaPZ7yuQVuQJXpnYo4hryogLAdwqbLjYyLXkmmHbcpUKWRLIPvyuQL6fJyPMoeZ6KABwsDmkw8Nde4IrPU4LbLw8wQN5GLAa9YbC8wQ)iWB5jrgBmj1zPoMfgL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gSGcktKXgtsDwQfUcJsDmv6g564TuhJFAKDWpIWmHDaPZ7yuQVuQJXpnYo4hryogLAdwqbLjYyJjPol1liCfgL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gSGcktKXgtsDwQxq4lmk1XuPBKRJ3sDm(Pr2b)icZe2bKoVJrP(sPog)0i7GFeH5yuQnybfuMiJvgRWWegi84scVwkMwHrPwQxmILA6qmRtQTzj1X4NzFNM(mgL6IxguAXBPEMdwQb0lhWXBP(JaVLNezSXKuNL6fIzHrPoMkDJCD8wQJXpnYo4hryMWoG05Dmk1xk1X4Ngzh8JimhJsTblOGYezSXKuNL6feUcJsDmv6g564TuhJFAKDWpIWmHDaPZ7yuQVuQJXpnYo4hryogLAdwqbLjYyJjPol1lSSegL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gSGcktKXgtsDwQxUHcJsDmv6g564TuhJFAKDWpIWmHDaPZ7yuQVuQJXpnYo4hryogLAdwqbLjYyLXk8AiM1XBPEHfKA4pA6sDNoVjrgBqfqVOScQQ0bAhoA6XufyVGQyLwANdQX0LAHNaTSulmOEWzzSX0LAHN(xIWLuV8fusQxUHl3qzSYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBelweT3XSXuPuSP4jFkTzlG2VgdLXc)rtFsel(ZbcCR3SQrOOasNvYHb3iwSiAVJzJPsPyZKpLmcDuUzbLO2gJqrbKotelweT3XSXSXqbfQZ2SAzYKkgLoEEzni8YGsff5Ta4pQrgZopO8mULlJf(JM(Kiw8Nde4wVzvJqrbKoRKddUrSyr0EhZgtLsXMjFkze6OCZckrTngHIciDMiwSiAVJzJzJHckuNTz1YKjvmkD88YAq4LbLkkYBbFAKDWpIZFL9S2e2bKoVfa)rnYy25bLNXTGmw4pA6tIyXFoqGB9Mvncffq6Ssom4gXIfr7DmBmvkfBM8PKrOJYnlOe12yekkG0zIyXIO9oMnMngkOqD2MvltMuXO0XZlRbHxguQOiVf8Pr2b)ioTn6WwGjSdiDElJf(JM(Kiw8Nde4wVzvJqrbKoRKddUjcmY4uKDERuk2u8KpL2Sfq7xJHYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBIaJmofzN3kLInt(uYi0r5MfuIABmcffq6mjcmY4uKDE3yOa4pQrgZopO8mULlJf(JM(Kiw8Nde4wVzvJqrbKoRKddUjcmY4uKDERuk2m5tjJqhLBwqjQTXiuuaPZKiWiJtr25DJHcmcffq6mrSyr0EhZgZMfKXc)rtFsel(ZbcCR3SQrOOasNvYHb3yPo0XiOLRuk2m5tjJqhLBmugl8hn9jrS4phiWTEZQgHIciDwjhgCtnXdqb8M7q8kLInfp5tPnBb0(1iSYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBar8auaV5oeVsPytXt(uAZwaTFnlyOmw4pA6tIyXFoqGB9Mvncffq6Ssom4MkfXdqb8M7q8kLInfp5tPnBb0(1SCdLXc)rtFsel(ZbcCR3SQrOOasNvYHb3C5nWdqb8M7q8kLInfp5tPnBb0(1iSYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBU8g4bOaEZDiELsXMjFkze6OCtmRe12yekkG0zYL3apafWBUdX3iSckuNTz1YKnD(uXo1HkE8NJb4BcVmOurrElJf(JM(Kiw8Nde4wVzvJqrbKoRKddU5YBGhGc4n3H4vkfBM8PKrOJYnliSkrTngHIciDMC5nWdqb8M7q8ncRGpnYo4hXPTrh2cmHDaPZBzSWF00NeXI)CGa36nRAekkG0zLCyWnxEd8auaV5oeVsPyZKpLmcDuUzbHvjQTXiuuaPZKlVbEakG3ChIVryf8PVrPhbQhCglw5M2gpHDaPZBbWFuJmMDEq55kXSmw4pA6tIyXFoqGB9Mvncffq6Ssom4MlVbEakG3ChIxPuSzYNsgHok3eZgQe12yekkG0zYL3apafWBUdX3iSc45K9NjgPtA640If5YY)rtNmOEwYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBqGQGwgpahWI)Puk2u8KpL2Sfq7xJWXqzSWF00NeXI)CGa36nRAekkG0zLCyWniqvqlJhGdyX)ukfBM8PKrOJYncxdvIABmcffq6mbbQcAz8aCal(xJWXqbFAKDWpItBJoSfyc7asN3YyH)OPpjIf)5abU1Bw1iuuaPZk5WGBar8G60b6apahWI)Puk2u8KpL2Sfq7xtmBOmw4pA6tIyXFoqGB9Mvncffq6Ssom4gqepOoDGoWdWbS4FkLInt(uYi0r5gH1qLO2gJqrbKotar8G60b6apahWI)1eZgkOqD2Mvlt205tf7uhQ4XFogGVj8YGsff5Tmw4pA6tIyXFoqGB9Mvncffq6Ssom4gqepOoDGoWdWbS4FkLInt(uYi0r5gH1qLO2gJqrbKotar8G60b6apahWI)1eZgkOqD2MvltAl6ShpM(0VZeEzqPII8wgl8hn9jrS4phiWTEZQgHIciDwjhgCZL3apafWFeuT8uPuSP4jFkTzlG2VMLlJf(JM(Kiw8Nde4wVzvJqrbKoRKddUbsgF5nWdqb8hbvlpvkfBkEYNsB2cO9Rz5YyH)OPpjIf)5abU1Bw1iuuaPZk5WGBGbEkcdLsXMIN8P0MTaA)AM8DuVDsGbEkcdzSWF00NeXI)CGa36nRA7WuizSWF00NeXI)CGa36nRAZClJf(JM(Kiw8Nde4wVzvaTDW(bhnDzSWF00NeXI)CGa36nRc1doJTWG2PqjJf(JM(Kiw8Nde4wVzvOEWzm1pU35)KXc)rtFsel(ZbcCR3S6NUWdOfJhGd4wEiJf(JM(Kiw8Nde4wVz1PdIZO8WZdUPmw4pA6tIyXFoqGB9Mvh0QYcthqllJf(JM(Kiw8Nde4wVzvBLZdj7NsuBJrOOasNjIflI27y2yUsJHYyH)OPpjIf)5abU1BwLnMpC00vIABmcffq6mrSyr0EhZgZ4mugRmw4pA6Z1Bw9tu)4AkY9UsuBZbvlFKnJGATKhMh1Bjfd)jJf(JM(C9MvFO3XWF00XD68uYHb3mJGI34FpLXc)rtFUEZQp07y4pA64oDEk5WGB45K9NNYyH)OPpxVz1h6Dm8hnDCNopLCyWnqYkrTnWFuJmMDEq5zClxgl8hn956nR(qVJH)OPJ705PKddUjfzNlLO2gJqrbKotIaJmofzN3R0yOmw4pA6Z1Bw9HEhd)rth3PZtjhgCdmWtryOe12yekkG0zcmWtry0SGmw4pA6Z1Bw9HEhd)rth3PZtjhgCZNzFNM(ugl8hn956nR(qVJH)OPJ705PKddUPYdoA6krTngHIciDMyPo0XiOL3yOmw4pA6Z1Bw9HEhd)rth3PZtjhgCJL6qhJGwUsuBJrOOasNjwQdDmcA5nliJf(JM(C9MvFO3XWF00XD68uYHb3msJ8G9tgRmw4pA6tYmckEJ)9C9MvrNmEaoGB5HsuBJbh0z)iS3PTrh78MWoG05TGb4ar8VvAe(gkyaoqe)lUMLTWQSIkAqmCqN9JWEN2gDSZBc7asN3cgGdeX)wPr4lSklJf(JM(KmJGI34FpxVzv0jJPhpMkrTniOwlbQhCglMMCrqfLXc)rtFsMrqXB8VNR3SQyE00vIABqqTwcup4mwmn5IGkkJf(JM(KmJGI34FpxVz1JoySjuIkrTnfQZ2SAzYXdXSGo2ekrcVmOurrElab1AjScra68OPtqfLXc)rtFsMrqXB8VNR3SAN2gDtSWdO72b7NsuBdcQ1sG6bNXIPjxKDA6cqqTwsH6moTyX0KlYonDbBgb1AjxI(r40IVigpGwkzNMUmw4pA6tYmckEJ)9C9MvrGwCAXxrFHMkrTniOwlbQhCglMMCr2PPlab1AjfQZ40IfttUi700fSzeuRLCj6hHtl(Iy8aAPKDA6YyH)OPpjZiO4n(3Z1BwfHRjxcr9wLO2geuRLa1doJfttUiOIYyH)OPpjZiO4n(3Z1BwfPN5gBrR4vIABqqTwcup4mwmn5IGkkJf(JM(KmJGI34FpxVzvlTyKEMBLO2geuRLa1doJfttUiOIYyH)OPpjZiO4n(3Z1Bwf8NNxbD8d9UsuBdcQ1sG6bNXIPjxeurzSYyH)OPpj8CY(ZZ1BwfPN5gNw8fXy25r8krTnFM9DA6Klr)iCAXxeJhqlLu8aO(SXqbiOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VvurlTn6WfpaQpx5ZSVttNa1doJfttUifpaQpLXc)rtFs45K9NNR3SkspZnoT4lIXSZJ4vIAB(m7700jq9GZyX0KlsXdG6ZgdfyqmCqN9JWEN2gDSZBc7asN3kQObh0z)iS3PTrh78MWoG05TGb4ar8V4AeogQOIgHIciDMad8uegnlOSYcmWGpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxGbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKIkAekkG0zcmWtry0SGYkROIg8z23PPtUe9JWPfFrmEaTusXdG6ZgdfGGATeOEWz8hbvltMh8c1yOYklab1AjfQZ40IfttUi700fmahiI)fxJrOOasNjGiEqD6aDGhGdyX)KXc)rtFs45K9NNR3SQzw9TrM64INPd(ZkrTnFM9DA6eOEWzSyAYfP4bq9zCncRHc(m7700jxI(r40IVigpGwkP4bq95knT)wacQ1sG6bNXFeuTmzEWl0kngHIciDMC5nWdqb8hbvlpfCqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEzSWF00NeEoz)556nRAMvFBKPoU4z6G)SsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpBmuacQ1sG6bNXFeuTmzEWl0kngHIciDMC5nWdqb8hbvlpf8z23PPtG6bNXIPjxKIha1NR00(Bfv0sBJoCXdG6Zv(m7700jq9GZyX0KlsXdG6tzSWF00NeEoz)556nRAMvFBKPoU4z6G)SsuBZNzFNMobQhCglMMCrkEauF2yOadIHd6SFe2702OJDEtyhq68wrfn4Go7hH9oTn6yN3e2bKoVfmahiI)fxJWXqfv0iuuaPZeyGNIWOzbLvwGbg8z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cmab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHuurJqrbKotGbEkcJMfuwzfv0GpZ(onDYLOFeoT4lIXdOLskEauF2yOaeuRLa1doJ)iOAzY8GxOgdvwzbiOwlPqDgNwSyAYfzNMUGb4ar8V4Amcffq6mbeXdQthOd8aCal(Nmw4pA6tcpNS)8C9MvBrHAtbhNwmetWvErkrTnFM9DA6Klr)iCAXxeJhqlLu8aO(SXqbiOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VvurlTn6WfpaQpx5ZSVttNa1doJfttUifpaQpLXc)rtFs45K9NNR3SAlkuBk440IHycUYlsjQT5ZSVttNa1doJfttUifpaQpBmuGbXWbD2pc7DAB0XoVjSdiDEROIgCqN9JWEN2gDSZBc7asN3cgGdeX)IRr4yOIkAekkG0zcmWtry0SGYklWad(m7700jxI(r40IVigpGwkP4bq9zCgHIciDMaI4bOaEZDiEbgGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqkQOrOOasNjWapfHrZckRSIkAWNzFNMo5s0pcNw8fX4b0sjfpaQpBmuacQ1sG6bNXFeuTmzEWluJHkRSaeuRLuOoJtlwmn5ISttxWaCGi(xCngHIciDMaI4b1Pd0bEaoGf)tgl8hn9jHNt2FEUEZQF6p7xbhVX2omyL6uNX)UzzRe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlyaoqo6GXxIhGcX1WkWp6X4JoyzSWF00NeEoz)556nRwmis9wSTddEQe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlyaoqo6GXxIhGcX1WkWp6X4JoyzSWF00NeEoz)556nRAZhDYBmetWf9ymcddLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDzSWF00NeEoz)556nRkIwuB8uVfJ0H5Pe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlJf(JM(KWZj7ppxVz1Ikk2zm1Xtr4zLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDzSWF00NeEoz)556nRErmg1rsuFJTz9SsuBdcQ1sG6bNXIPjxKDA6cqqTwsH6moTyX0KlYonDbBgb1AjxI(r40IVigpGwkzNMUmw4pA6tcpNS)8C9Mvh8iR4XPf3rF6gVlggtLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDzSYyH)OPpjPi7CTEZQgHIciDwjhgCteyKXPi78wPuSzYNsgHok3SGsuBJyXgXT)MSaHnMpC00LXc)rtFssr25A9MvT0IXiDyEkrTnfQZ2SAzYMoFQyN6qfp(ZXa8nHxguQOiVfGGATKnD(uXo1HkE8NJb4BSTY5rqfLXc)rtFssr25A9MvTvopSNgbLO2Mc1zBwTmPTOZE8y6t)ot4LbLkkYBbdWbI4FXTSewzSWF00NKuKDUwVz1bTQSM40IVSgSFYyH)OPpjPi7CTEZQBgUiKSCwgl8hn9jjfzNR1BwTGnf8dpfHsiLO2Mb4ar8V4eUgkJf(JM(KKISZ16nR(G)Chd)rtxjQTb(JMozgrTh1BXIPjxKpcCN7uVvq7VjfpaQpBmugl8hn9jjfzNR1BwDgrTh1BXIPjxkrTnZeTJq9nXs5(gNwmspNZCmjSdiDElJf(JM(KKISZ16nREj6hHtl(Iy8aAPYyH)OPpjPi7CTEZQq9GZyX0KlzSWF00NKuKDUwVz1c1zCAXIPjxkrTniOwlPqDgNwSyAYfzNMUmw4pA6tskYoxR3SQyXt2FgNw8G6BzSWF00NKuKDUwVzvOEWzmshMNsuBZopsbBk4hEkcLqKIha1NXjSkQ4MrqTwsbBk4hEkcLqyJODNlaH2Px8K5bVqXzOmw4pA6tskYoxR3Skup4mgPdZtjQTbb1AjIfpz)zCAXdQVjOIc2mcQ1sUe9JWPfFrmEaTucQOGnJGATKlr)iCAXxeJhqlLu8aO(CLg4pA6eOEWzmshMhHvGF0JXhDWYyH)OPpjPi7CTEZQq9GZyeOkOLvIABqqTwcup4mwmn5IGkkab1Ajq9GZyX0KlsXdG6ZvAA)TaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fsgl8hn9jjfzNR1BwfQhCgpOZjTZtLO2MnJGATKlr)iCAXxeJhqlLGkk4Go7hbQhCgZFusyhq68wacQ1s2mCriz5mzNMUGnJGATKlr)iCAXxeJhqlLu8aO(mo4pA6eOEWz8GoN0opjSc8JEm(OdwGbXaetWf9ycup4mweDm4o1BjSdiDEROIiOwl57mupmpQ3I)iWDUt2PPRSsFeq9MfKXc)rtFssr25A9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFk9ra1Bwqgl8hn9jjfzNR1BwfQhCgNfIsuBdcQ1sG6bNXFeuTmzEWl0kngHIciDMC5nWdqb8hbvlpfyWNzFNMobQhCglMMCrkEauFg3cgQOIWFuJmMDEq55knlxzzSWF00NKuKDUwVzvOEWzmshMNsuBdcQ1skuNXPflMMCrqfvuXb4ar8V4wqyLXc)rtFssr25A9MvzJ5dhnDLO2geuRLuOoJtlwmn5ISttxjQFCvOIhMABgGdeX)IRr4lSkr9JRcv8W0XG3u44MfKXc)rtFssr25A9MvH6bNXiqvqllJvgl8hn9j5ZSVttFUEZQ2kNh2tJGsuBtH6SnRwM0w0zpEm9PFNj8YGsff5TGpZ(onDcup4mwmn5Iu8aO(mUy2qbFM9DA6Klr)iCAXxeJhqlLu8aO(SXqbgGGATeOEWz8hbvltMh8cTsJrOOasNjxEd8aua)rq1YtbgyWbD2psH6moTyX0Klc7asN3c(m7700jfQZ40IfttUifpaQpxPP93c(m7700jq9GZyX0KlsXdG6Z4mcffq6m5YBGhGc4n3H4vwrfnigoOZ(rkuNXPflMMCryhq68wWNzFNMobQhCglMMCrkEauFgNrOOasNjxEd8auaV5oeVYkQ4NzFNMobQhCglMMCrkEauFUst7VvwzHjLKAHjHHROzrpAmbl1OtQ3k1TfD2JxQPp97SuBsViPgejsTW7jl10tQnPxKuF5nK68I4YKozImw4pA6tYNzFNM(C9MvTvopSNgbLO2Mc1zBwTmPTOZE8y6t)ot4LbLkkYBbFM9DA6eOEWzSyAYfP4bq9zJHcmigoOZ(ryVtBJo25nHDaPZBfv0Gd6SFe2702OJDEtyhq68wWaCGi(xCnchdvwzbgyWNzFNMo5s0pcNw8fX4b0sjfpaQpJBbdfGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqkROIg8z23PPtUe9JWPfFrmEaTusXdG6ZgdfGGATeOEWz8hbvltMh8c1yOYklab1AjfQZ40IfttUi700fmahiI)fxJrOOasNjGiEqD6aDGhGdyX)KXc)rtFs(m7700NR3SQTY5HK9tjQTPqD2Mvlt205tf7uhQ4XFogGVj8YGsff5TGpZ(onDccQ1I305tf7uhQ4XFogGVjfd74fGGATKnD(uXo1HkE8NJb4BSTY5r2PPlWaeuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDLf8z23PPtUe9JWPfFrmEaTusXdG6ZgdfyacQ1sG6bNXFeuTmzEWl0kngHIciDMC5nWdqb8hbvlpfyGbh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(CLM2Fl4ZSVttNa1doJfttUifpaQpJZiuuaPZKlVbEakG3ChIxzfv0Gy4Go7hPqDgNwSyAYfHDaPZBbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8kROIFM9DA6eOEWzSyAYfP4bq95knT)wzLLXc)rtFs(m7700NR3SQLwmgPdZtjQTPqD2Mvlt205tf7uhQ4XFogGVj8YGsff5TGpZ(onDccQ1I305tf7uhQ4XFogGVjfd74fGGATKnD(uXo1HkE8NJb4BSLwmzNMUaXInIB)nzbITY5HK9tgl8hn9j5ZSVttFUEZQdAvznXPfFzny)uIAB(m7700jxI(r40IVigpGwkP4bq9zJHcqqTwcup4m(JGQLjZdEHwPXiuuaPZKlVbEakG)iOA5PGpZ(onDcup4mwmn5Iu8aO(CLM2FlmPKulmjmOBcXpLA0jl1dAvznLAt6fj1GirQfEzL6lVHutNsDXWoEPgMsTj37kj1dqiwQNOfl1xk1pmpPMEsncBZIL6lVbrgl8hn9j5ZSVttFUEZQdAvznXPfFzny)uIAB(m7700jq9GZyX0KlsXdG6ZgdfyqmCqN9JWEN2gDSZBc7asN3kQObh0z)iS3PTrh78MWoG05TGb4ar8V4AeogQSYcmWGpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cPSIkAWNzFNMo5s0pcNw8fX4b0sjfpaQpBmuacQ1sG6bNXFeuTmzEWluJHkRSaeuRLuOoJtlwmn5ISttxWaCGi(xCngHIciDMaI4b1Pd0bEaoGf)tgl8hn9j5ZSVttFUEZQBgUiKSCwjQT5ZSVttNCj6hHtl(Iy8aAPKIha1Nngkab1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNc(m7700jq9GZyX0KlsXdG6ZvAA)TWKssTWKWGUje)uQrNSuVz4IqYYzP2KErsnisKAHxwP(YBi10PuxmSJxQHPuBY9Uss9aeIL6jAXs9Ls9dZtQPNuJW2SyP(YBqKXc)rtFs(m7700NR3S6MHlcjlNvIAB(m7700jq9GZyX0KlsXdG6ZgdfyqmCqN9JWEN2gDSZBc7asN3kQObh0z)iS3PTrh78MWoG05TGb4ar8V4AeogQSYcmWGpZ(onDYLOFeoT4lIXdOLskEauFg3cgkab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHuwrfn4ZSVttNCj6hHtl(Iy8aAPKIha1Nngkab1Ajq9GZ4pcQwMmp4fQXqLvwacQ1skuNXPflMMCr2PPlyaoqe)lUgJqrbKotar8G60b6apahWI)jJf(JM(K8z23PPpxVz1c2uWp8uekHuIAB(m7700jxI(r40IVigpGwkP4bq9zCgHIciDMut8auaV5oeVGpZ(onDcup4mwmn5Iu8aO(moJqrbKotQjEakG3ChIxGbh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(CLM2FROIh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(moJqrbKotQjEakG3ChIxrfJHd6SFKc1zCAXIPjxe2bKoVvwacQ1sG6bNXFeuTmzEWluClxWMrqTwYLOFeoT4lIXdOLs2PPlmPKulmj8EYs9uekHKAQvQV8gsn4BPgeLAOyPoDP(3sn4BP2m9y8KAewQrfLABwsDp9wUK6lcCP(IyPEaki1BUdXRKupaHOERuprlwQnzPocmYsnCsDNH5j1Nzk1q9GZs9hbvlpLAW3s9fbNuF5nKAty6X4j1cpGopPgDYBImw4pA6tYNzFNM(C9Mvlytb)WtrOesjQT5ZSVttNCj6hHtl(Iy8aAPKIha1Nngkab1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNc(m7700jq9GZyX0KlsXdG6ZvAA)TWKssTWKW7jl1trOesQnPxKudIsTze7sTyoNuKotKAHxwP(YBi10PuxmSJxQHPuBY9Uss9aeIL6jAXs9Ls9dZtQPNuJW2SyP(YBqKXc)rtFs(m7700NR3SAbBk4hEkcLqkrTnFM9DA6eOEWzSyAYfP4bq9zJHcmWGy4Go7hH9oTn6yN3e2bKoVvurdoOZ(ryVtBJo25nHDaPZBbdWbI4FX1iCmuzLfyGbFM9DA6Klr)iCAXxeJhqlLu8aO(moJqrbKotar8auaV5oeVaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fszfv0GpZ(onDYLOFeoT4lIXdOLskEauF2yOaeuRLa1doJ)iOAzY8GxOgdvwzbiOwlPqDgNwSyAYfzNMUGb4ar8V4Amcffq6mbeXdQthOd8aCal(NYYyH)OPpjFM9DA6Z1Bw9s0pcNw8fX4b0svIAB(m7700jq9GZyX0KlsXdG6ZvewdfWZj7ptmsN00XPflYLL)JMozq9SKXc)rtFs(m7700NR3S6LOFeoT4lIXdOLQe12GGATeOEWz8hbvltMh8cTsJrOOasNjxEd8aua)rq1Ytbh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(CLM2Fl4ZSVttNa1doJfttUifpaQpJZiuuaPZKlVbEakG3ChIxWNgzh8Jiu8ffCc7asN3c(m7700jfSPGF4PiucrkEauFUsJWxysjPwykMM4lk4cJsTW7jl1xEdPMALAquQPtPoDP(3sn4BP2m9y8KAewQrfLABwsDp9wUK6lcCP(IyPEaki1BUdXtKAHbDARl1M0lsQRuuQPwP(IyP(Go7NutNs9bcXorQfg(SVLAqQrONuFPupaHyPEIwSuBYs9dUul8OQuthdEtHJ7Xl1G94sQV8gsn77Pmw4pA6tYNzFNM(C9MvVe9JWPfFrmEaTuLO2geuRLa1doJ)iOAzY8GxOvAmcffq6m5YBGhGc4pcQwEk4Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(BbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8cIHpnYo4hrO4lk4e2bKoVfMusQfMwkDHNftt8ffCHrPw49KL6lVHutTsnik10PuNUu)BPg8TuBMEmEsncl1OIsTnlPUNElxs9fbUuFrSupafK6n3H4jsTWGoT1LAt6fj1vkk1uRuFrSuFqN9tQPtP(aHyNiJf(JM(K8z23PPpxVz1lr)iCAXxeJhqlvjQTbb1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNcIHd6SFKc1zCAXIPjxe2bKoVf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXlJf(JM(K8z23PPpxVz1lr)iCAXxeJhqlvjQTbb1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNc(m7700jq9GZyX0KlsXdG6ZvAA)Tmw4pA6tYNzFNM(C9MvH6bNXIPjxkrTngedh0z)iS3PTrh78MWoG05TIkAWbD2pc7DAB0XoVjSdiDElyaoqe)lUgHJHkRSGpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cjab1AjfQZ40IfttUi700fmahiI)fxJrOOasNjGiEqD6aDGhGdyX)eMusQfMeEpzPgeLAQvQV8gsnDk1Pl1)wQbFl1MPhJNuJWsnQOuBZsQ7P3YLuFrGl1xel1dqbPEZDiELK6bie1BL6jAXs9fbNuBYsDeyKLA2t02iPEaoi1GVL6lcoP(I4ILA6uQ98KAOxmSJxQbPUqDwQtRulMMCj1700jYyH)OPpjFM9DA6Z1BwTqDgNwSyAYLsuBdcQ1skuNXPflMMCr2PPl4ZSVttNCj6hHtl(Iy8aAPKIha1NXzekkG0zsLI4bOaEZDiEbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKad(m7700jq9GZyX0KlsXdG6Z4wqyvuXnJGATKlr)iCAXxeJhqlLGkQSWKssTWKW7jl1vkk1uRuF5nKA6uQtxQ)Tud(wQntpgpPgHLAurP2MLu3tVLlP(IaxQViwQhGcs9M7q8kj1dqiQ3k1t0IL6lIlwQPtpgpPg6fd74LAqQluNL6DA6sn4BP(IGtQbrP2m9y8KAe(Zbl1GrG2bKol1B0I6TsDH6mrgl8hn9j5ZSVttFUEZQIfpz)zCAXdQVvIABqqTwcup4m(JGQLjZdEHAmuWNgzh8Jiu8ffCc7asN3ctkj1ctX0eFrbxyuQfEuvQPtPEaoi1rOEBfVud(wQfgSMWDk1qXs9LPuZkiY(KAKL6lLA0jl1I5qQVuQNldkZXeSudUuZkCfi1aIutDP(IyP(YBi1MuFNMePoMKVyCk1OtwQPNuFPupaHyPUNMs9hbvll1cdwBk1uFEGFezSWF00NKpZ(on956nRkw8K9NXPfpO(wjQTzZiOwl5s0pcNw8fX4b0sjOIcIHpnYo4hrO4lk4e2bKoVfMusQfMwkDHNftt8ffCHrPw49KLAXCi1xk1ZLbL5ycwQbxQzfUcKAarQPUuFrSuF5nKAtQVttImwzSWF00NKkp4OPVEZQgHIciDwjhgCJL6qhJGwUsPyZKpLmcDuUzbLO2geuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fsqmGGATKcTZ40IVOI5jbvuGL2gD4Iha1NR0yGbdWbHNd)rtNa1doJr6W8iFopLfgc(JMobQhCgJ0H5ryf4h9y8rhSYYyH)OPpjvEWrtF9MvH6bNXiqvqlRe128z23PPtUe9JWPfFrmEaTusXdG6ZgdfyacQ1sG6bNXFeuTmzEWluCgHIciDMC5nWdqb8hbvlpfCqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEbFAKDWpIqXxuWjSdiDEl4ZSVttNuWMc(HNIqjeP4bq95kncFLLXc)rtFsQ8GJM(6nRc1doJrGQGwwjQT5ZSVttNCj6hHtl(Iy8aAPKIha1NngkWaeuRLa1doJ)iOAzY8GxO4mcffq6m5YBGhGc4pcQwEk4Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(BbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8cIHpnYo4hrO4lk4e2bKoVvwgl8hn9jPYdoA6R3Skup4mgbQcAzLO2MpZ(onDYLOFeoT4lIXdOLskEauF2yOadqqTwcup4m(JGQLjZdEHIZiuuaPZKlVbEakG)iOA5PGy4Go7hPqDgNwSyAYfHDaPZBbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8klJf(JM(Ku5bhn91BwfQhCgJavbTSsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpBmuGbiOwlbQhCg)rq1YK5bVqXzekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VvwgBmDPEjM3s9LsnDi25b7NupVI(Nup5LbL9NNsDwsnckTVLAWLAOFC5WrnYsDexmrgBmDPg(JM(Ku5bhn91BwDEf9p8Kxgu2FwjQTzZiOwlPGnf8dpfHsiSr0UZfGq70lEY8GxOMnJGATKc2uWp8uekHWgr7oxacTtV4jdqb88GxibiOwlbQhCglMMCr2PPlab1AjfQZ40IfttUi700vYHb30H5HNIqjeEEWlKWiup4mgPdZtyeQhCgJavbTSmw4pA6tsLhC00xVzvOEWzmcuf0YkrTnBgb1AjfSPGF4PiucHnI2DUaeANEXtMh8c1SzeuRLuWMc(HNIqje2iA35cqOD6fpzakGNh8cjWaeuRLa1doJfttUi700vureuRLa1doJfttUifpaQpxPP93klWaeuRLuOoJtlwmn5ISttxrfrqTwsH6moTyX0KlsXdG6ZvAA)TYYyH)OPpjvEWrtF9MvH6bNXiDyEkrTn78ifSPGF4PiucrkEauFgNWQOIBgb1AjfSPGF4PiucHnI2DUaeANEXtMh8cfNHYyH)OPpjvEWrtF9MvH6bNXiDyEkrTniOwlrS4j7pJtlEq9nbvuWMrqTwYLOFeoT4lIXdOLsqffSzeuRLCj6hHtl(Iy8aAPKIha1NR0a)rtNa1doJr6W8iSc8JEm(Odwgl8hn9jPYdoA6R3Skup4mEqNtANNkrTnBgb1AjxI(r40IVigpGwkbvuWbD2pcup4mM)OKWoG05TaeuRLSz4IqYYzYonDbgSzeuRLCj6hHtl(Iy8aAPKIha1NXb)rtNa1doJh05K25jHvGF0JXhDWkQ4NzFNMorS4j7pJtlEq9nP4bq9zCgQOIFAKDWpIqXxuWjSdiDERSadIbiMGl6XeOEWzSi6yWDQ3syhq68wrfrqTwY3zOEyEuVf)rG7CNSttxzL(iG6nliJf(JM(Ku5bhn91BwfQhCgpOZjTZtLO2geuRL8DgQhMh1Bjfd)jab1AjScIGV5nwmp2pk0jOIYyH)OPpjvEWrtF9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFcmab1Ajq9GZyX0KlcQOIkIGATKc1zCAXIPjxeurfvCZiOwl5s0pcNw8fX4b0sjfpaQpJd(JMobQhCgpOZjTZtcRa)OhJp6GvwPpcOEZcYyH)OPpjvEWrtF9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFcqqTwY3zOEyEuVLmp4fQbb1AjFNH6H5r9wYauapp4fsPpcOEZcYyH)OPpjvEWrtF9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFcqqTwY3zOEyEuVLu8aO(CLgdmab1AjFNH6H5r9wY8GxiHHG)OPtG6bNXd6Cs78KWkWp6X4JoyLxV93kR0hbuVzbzSWF00NKkp4OPVEZQoFrCHpEiYZtjQTXGITfpJaKoROIXWrFHOERYcqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxibiOwlbQhCglMMCr2PPlyZiOwl5s0pcNw8fX4b0sj700LXc)rtFsQ8GJM(6nRc1doJZcrjQTbb1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNYyH)OPpjvEWrtF9MvNOIC5PrqjQTzaoqe)BLMLLWkab1Ajq9GZyX0KlYonDbiOwlPqDgNwSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxgl8hn9jPYdoA6R3S6mIApQ3IfttUuIABqqTwcup4mwmn5ISttxacQ1skuNXPflMMCr2PPlyZiOwl5s0pcNw8fX4b0sj700f8z23PPtyJ5dhnDsXdG6Z4muWNzFNMobQhCglMMCrkEauFgNHc(m7700jxI(r40IVigpGwkP4bq9zCgkWGy4Go7hPqDgNwSyAYfHDaPZBfv0Gd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFgNHkRSmw4pA6tsLhC00xVzvOEWzmshMNsuBdcQ1sk0oJtl(IkMNeurbiOwlbQhCg)rq1YK5bVqXfZYyH)OPpjvEWrtF9MvH6bNXiqvqlRe12mahiI)TIrOOasNjiqvqlJhGdyX)e8z23PPtyJ5dhnDsXdG6Z4muacQ1sG6bNXIPjxKDA6cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88Gxib8CY(ZeJ0jnDCAXICz5)OPtguplzSWF00NKkp4OPVEZQq9GZyeOkOLvIAB(m7700jxI(r40IVigpGwkP4bq9zJHcm4ZSVttNuOoJtlwmn5Iu8aO(SXqfv8ZSVttNa1doJfttUifpaQpBmuzbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKmw4pA6tsLhC00xVzvOEWzmcuf0YkrTndWbI4FR0yekkG0zccuf0Y4b4aw8pbiOwlbQhCglMMCr2PPlab1AjfQZ40IfttUi700fSzeuRLCj6hHtl(Iy8aAPKDA6cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxibFM9DA6e2y(WrtNu8aO(modLXc)rtFsQ8GJM(6nRc1doJrGQGwwjQTbb1Ajq9GZyX0KlYonDbiOwlPqDgNwSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cj4Go7hbQhCgNfcHDaPZBbFM9DA6eOEWzCwiKIha1NR00(BbdWbI4FR0SSmuWNzFNMoHnMpC00jfpaQpJZqzSWF00NKkp4OPVEZQq9GZyeOkOLvIABqqTwcup4mwmn5IGkkab1Ajq9GZyX0KlsXdG6ZvAA)TaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fsgl8hn9jPYdoA6R3Skup4mgbQcAzLO2geuRLuOoJtlwmn5IGkkab1AjfQZ40IfttUifpaQpxPP93cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00NKkp4OPVEZQq9GZyeOkOLvIABqqTwcup4mwmn5ISttxacQ1skuNXPflMMCr2PPlyZiOwl5s0pcNw8fX4b0sjOIc2mcQ1sUe9JWPfFrmEaTusXdG6ZvAA)TaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fsgl8hn9jPYdoA6R3Skup4mgPdZtgl8hn9jPYdoA6R3SkBmF4OPRe1pUkuXdtTndWbI4FX1i8fwLO(XvHkEy6yWBkCCZcYyH)OPpjvEWrtF9MvH6bNXiqvqllJvgl8hn9jXsDOJrqlF9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFk9ra1Bwqgl8hn9jXsDOJrqlF9MvH6bNXiDyEYyH)OPpjwQdDmcA5R3Skup4mgbQcAzzSYyH)OPpjqYR3SQTY5HK9tjQTPqD2Mvlt205tf7uhQ4XFogGVj8YGsff5TGpZ(onDccQ1I305tf7uhQ4XFogGVjfd74fGGATKnD(uXo1HkE8NJb4BSTY5r2PPlWaeuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDLf8z23PPtUe9JWPfFrmEaTusXdG6ZgdfyacQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNcmWGd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7Vf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXRSIkAqmCqN9JuOoJtlwmn5IWoG05TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiELvuXpZ(onDcup4mwmn5Iu8aO(CLM2FRSYYyH)OPpjqYR3SQLwmgPdZtjQTXGc1zBwTmztNpvStDOIh)5ya(MWldkvuK3c(m7700jiOwlEtNpvStDOIh)5ya(MumSJxacQ1s205tf7uhQ4XFogGVXwAXKDA6cel2iU93Kfi2kNhs2pLvurdkuNTz1YKnD(uXo1HkE8NJb4BcVmOurrEl4OdUXqLLXc)rtFsGKxVzvBLZd7PrqjQTPqD2MvltAl6ShpM(0VZeEzqPII8wWNzFNMobQhCglMMCrkEauFgxmBOGpZ(onDYLOFeoT4lIXdOLskEauF2yOadqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uGbgCqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiELvurdIHd6SFKc1zCAXIPjxe2bKoVf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXRSIk(z23PPtG6bNXIPjxKIha1NR00(BLvwgl8hn9jbsE9MvTvopSNgbLO2Mc1zBwTmPTOZE8y6t)ot4LbLkkYBbFM9DA6eOEWzSyAYfP4bq9zJHcmWad(m7700jxI(r40IVigpGwkP4bq9zCgHIciDMaI4bOaEZDiEbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKYkQObFM9DA6Klr)iCAXxeJhqlLu8aO(SXqbiOwlbQhCg)rq1YK5bVqR0yekkG0zcKm(YBGhGc4pcQwEQSYcqqTwsH6moTyX0KlYonDLLXc)rtFsGKxVz1lr)iCAXxeJhqlvjQTPqD2MvltMuXO0XZlRbHxguQOiVfiwSrC7VjlqyJ5dhnDzSWF00Nei51BwfQhCglMMCPe12uOoBZQLjtQyu645L1GWldkvuK3cmqSyJ42FtwGWgZhoA6kQOyXgXT)MSa5s0pcNw8fX4b0svwgl8hn9jbsE9MvzJ5dhnDLO2MJo44IzdfuOoBZQLjtQyu645L1GWldkvuK3cqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uWNzFNMo5s0pcNw8fX4b0sjfpaQpBmuWNzFNMobQhCglMMCrkEauFUst7VLXc)rtFsGKxVzv2y(WrtxjQT5OdoUy2qbfQZ2SAzYKkgLoEEzni8YGsff5TGpZ(onDcup4mwmn5Iu8aO(SXqbgyGbFM9DA6Klr)iCAXxeJhqlLu8aO(moJqrbKotar8auaV5oeVaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fszfv0GpZ(onDYLOFeoT4lIXdOLskEauF2yOaeuRLa1doJ)iOAzY8GxOvAmcffq6mbsgF5nWdqb8hbvlpvwzbiOwlPqDgNwSyAYfzNMUYkr9JRcv8WuBdcQ1sMuXO0XZlRbzEWludcQ1sMuXO0XZlRbzakGNh8cPe1pUkuXdthdEtHJBwqgl8hn9jbsE9Mvh0QYAItl(YAW(Pe12yWNzFNMobQhCglMMCrkEauFgNWvyvuXpZ(onDcup4mwmn5Iu8aO(CLMywzbFM9DA6Klr)iCAXxeJhqlLu8aO(SXqbgGGATeOEWz8hbvltMh8cTsJrOOasNjqY4lVbEakG)iOA5Padm4Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(BbFM9DA6eOEWzSyAYfP4bq9zCcRYkQObXWbD2psH6moTyX0Klc7asN3c(m7700jq9GZyX0KlsXdG6Z4ewLvuXpZ(onDcup4mwmn5Iu8aO(CLM2FRSYYyH)OPpjqYR3SAbBk4hEkcLqkrTnFM9DA6Klr)iCAXxeJhqlLu8aO(moJqrbKotQjEakG3ChIxWNzFNMobQhCglMMCrkEauFgNrOOasNj1epafWBUdXlWGd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7VvuXd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFgNrOOasNj1epafWBUdXROIXWbD2psH6moTyX0Klc7asN3klab1Ajq9GZ4pcQwMmp4fALgJqrbKotGKXxEd8aua)rq1YtbBgb1AjxI(r40IVigpGwkzNMUmw4pA6tcK86nRwWMc(HNIqjKsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpBmuGbiOwlbQhCg)rq1YK5bVqR0yekkG0zcKm(YBGhGc4pcQwEkWadoOZ(rkuNXPflMMCryhq68wWNzFNMoPqDgNwSyAYfP4bq95knT)wWNzFNMobQhCglMMCrkEauFgNrOOasNjxEd8auaV5oeVYkQObXWbD2psH6moTyX0Klc7asN3c(m7700jq9GZyX0KlsXdG6Z4mcffq6m5YBGhGc4n3H4vwrf)m7700jq9GZyX0KlsXdG6ZvAA)TYklJf(JM(KajVEZQfSPGF4PiucPe128z23PPtG6bNXIPjxKIha1NngkWadm4ZSVttNCj6hHtl(Iy8aAPKIha1NXzekkG0zciIhGc4n3H4fGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqkROIg8z23PPtUe9JWPfFrmEaTusXdG6ZgdfGGATeOEWz8hbvltMh8cTsJrOOasNjqY4lVbEakG)iOA5PYklab1AjfQZ40IfttUi700vwgl8hn9jbsE9Mv3mCriz5SsuBZNzFNMobQhCglMMCrkEauF2yOadmWGpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cPSIkAWNzFNMo5s0pcNw8fX4b0sjfpaQpBmuacQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNkRSaeuRLuOoJtlwmn5ISttxzzSWF00Nei51Bw9s0pcNw8fX4b0svIABqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uGbgCqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiELvurdIHd6SFKc1zCAXIPjxe2bKoVf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXRSIk(z23PPtG6bNXIPjxKIha1NR00(BLLXc)rtFsGKxVzvOEWzSyAYLsuBJbg8z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxiLvurd(m7700jxI(r40IVigpGwkP4bq9zJHcqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uzLfGGATKc1zCAXIPjxKDA6YyH)OPpjqYR3SAH6moTyX0KlLO2geuRLuOoJtlwmn5ISttxGbg8z23PPtUe9JWPfFrmEaTusXdG6Z4wUHcqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxiLvurd(m7700jxI(r40IVigpGwkP4bq9zJHcqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uzLfyWNzFNMobQhCglMMCrkEauFg3ccRIkUzeuRLCj6hHtl(Iy8aAPeurLLXc)rtFsGKxVzvXINS)moT4b13krTniOwlzZWfHKLZeurbBgb1AjxI(r40IVigpGwkbvuWMrqTwYLOFeoT4lIXdOLskEauFUsdcQ1selEY(Z40IhuFtgGc45bVqcdb)rtNa1doJr6W8iSc8JEm(Odwgl8hn9jbsE9MvH6bNXiDyEkrTniOwlzZWfHKLZeurbgyWbD2psXZ0b)zc7asN3cG)Ogzm78GYZveUkROIWFuJmMDEq55kcRYYyH)OPpjqYR3S6evKlpncYyH)OPpjqYR3Skup4moleLO2geuRLa1doJ)iOAzY8GxOgdLXc)rtFsGKxVzvNViUWhpe55Pe12yqX2INrasNvuXy4OVquVvzbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKmw4pA6tcK86nRoJO2J6TyX0KlLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDbFM9DA6eOEWzSyAYfP4bq9zCgk4ZSVttNCj6hHtl(Iy8aAPKIha1NXzOadIHd6SFKc1zCAXIPjxe2bKoVvurdoOZ(rkuNXPflMMCryhq68wWNzFNMoPqDgNwSyAYfP4bq9zCgQSYYyH)OPpjqYR3Skup4mEqNtANNkrTniOwl57mupmpQ3skg(tqH6SnRwMa1doJPUL60lEcVmOurrEl4Go7hbgIDQL(WrtNWoG05Ta4pQrgZopO8CLLLmw4pA6tcK86nRc1doJh05K25PsuBdcQ1s(od1dZJ6TKIH)euOoBZQLjq9GZyQBPo9INWldkvuK3cG)Ogzm78GYZvw2YyH)OPpjqYR3Skup4mMvqSNtA6krTniOwlbQhCg)rq1YK5bVqRGGATeOEWz8hbvltgGc45bVqYyH)OPpjqYR3Skup4mMvqSNtA6krTniOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKaXInIB)nzbcup4mgbQcAzzSWF00Nei51BwfQhCgJavbTSsuBdcQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cjJf(JM(KajVEZQSX8HJMUsu)4Qqfpm12mahiI)fxJWxyvI6hxfQ4HPJbVPWXnliJvgl8hn9jbg4PimAkuNXPflMMCPe12GGATKc1zCAXIPjxKDA6c(m7700jq9GZyX0KlsXdG6Z4mugl8hn9jbg4PimwVz1lr)iCAXxeJhqlvjQTXGpZ(onDcup4mwmn5Iu8aO(SXqbiOwlPqDgNwSyAYfzNMUYkQOyXgXT)MSaPqDgNwSyAYLmw4pA6tcmWtrySEZQxI(r40IVigpGwQsuBZNzFNMobQhCglMMCrkEauFUIWAOaeuRLuOoJtlwmn5ISttxapNS)mXiDsthNwSixw(pA6e2bKoVLXc)rtFsGbEkcJ1BwfQhCglMMCPe12GGATKc1zCAXIPjxKDA6c(m7700jxI(r40IVigpGwkP4bq9zCgHIciDMaI4bOaEZDiEzSWF00NeyGNIWy9MvH6bNXiqvqlRe12GGATeOEWzSyAYfbvuacQ1sG6bNXIPjxKIha1NR0a)rtNa1doJh05K25jHvGF0JXhDWcqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00NeyGNIWy9MvH6bNXzHOe12GGATeOEWz8hbvltMh8cTccQ1sG6bNXFeuTmzakGNh8cjab1AjfQZ40IfttUi700fGGATeOEWzSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxgl8hn9jbg4PimwVzvOEWzmcuf0YkrTniOwlPqDgNwSyAYfzNMUaeuRLa1doJfttUi700fSzeuRLCj6hHtl(Iy8aAPKDA6cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00NeyGNIWy9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFk9ra1Bwqgl8hn9jbg4PimwVzvOEWz8GoN0opvIABIbiMGl6XeOEWzSi6yWDQ3syhq68wrfrqTwY3zOEyEuVf)rG7CNSttxPpcOEZcYyH)OPpjWapfHX6nR(G)Chd)rtxjQTb(JMoHnMpC00jFe4o3PERGb4ar8V4AwwcRmw4pA6tcmWtrySEZQSX8HJMUmw4pA6tcmWtrySEZQq9GZ4SquIABqqTwcup4m(JGQLjZdEHwbb1Ajq9GZ4pcQwMmafWZdEHKXc)rtFsGbEkcJ1BwfQhCgJavbTSmw4pA6tcmWtrySEZQq9GZyKompzSYyH)OPpjJ0ipy)wVzvKo1fcdE8krTnJ0ipy)iB68a)54AwWqzSWF00NKrAKhSFR3SQyXt2FgNw8G6BzSWF00NKrAKhSFR3Skup4mEqNtANNkrTnJ0ipy)iB68a)5vwWqzSWF00NKrAKhSFR3Skup4molezSWF00NKrAKhSFR3SQLwmgPdZlCHleaa]] )


end
