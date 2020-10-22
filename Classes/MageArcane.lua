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


    spec:RegisterPack( "Arcane", 20201022, [[d00I9dqiHcwebf5rcfP6seufvBIaFsOqJIc6uuGvrqb5vkPAwKi3IGQOSle)sjPHrI6ykbltjsptjctJGkDnckTnLiQVrqfJJGQ6CkrK1rqHMNsI7jf7tOYbjOalujLhkuK8rHIuAKeuqvNKGQKvku6LcfPyMcfr3KGQi2Psu)KGQinuckOYsjOk0tjPPQe6QeuL6ReuqzSeuu7vWFHAWK6WGfdXJv1KvQlJAZu6ZsPrlKtJ0QjOk41eKzlv3wHDt1VfnCcDCHIA5sEUIMUkxhsBNc9DkA8KGZlu16fkcZNeA)eDyHWIb1nCCy5LQ8svEbLx6sjkRSYlzHBq9IxKdQIWle0YbvhgCqvyq9GZbvri(Ec7WIb1zIwphuJUtCkmU6QT0lcfH85y1jDG2HJM(xG9wDsh)QbveuA)eE5bKG6gooS8svEPkVGYlDPeLvw5L8siCdQtr(dlVKxAqnIU3ShqcQBE(b1y6sTWtGwwQfgup4Sm2y6sTWt)lr4sQx6svsQxQYlv5GANoVzyXGAkYoxHfdlVqyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQleu)IECrHGQyXgXT)MSaHnMpC00dQgHc7WGdQrGrgNISZ7WfwEPHfdQSdiDEhwlO(f94Icb1c1zBwTmztNpvStDOIh)5ya(MWXmkvuK3sTaPgb1AjB68PIDQdv84phdW3yBLZJGkguH)OPhuT0IXiDyEHlS8sewmOYoG05DyTG6x0JlkeuluNTz1YK2Io7XJPp97mHJzuQOiVLAbs9aCGi(NuhNuVKe2Gk8hn9GQTY5H90ieUWYc3WIbv4pA6b1bTQSM40IVSgSFbv2bKoVdRfUWYcByXGk8hn9G6MHlcjlNdQSdiDEhwlCHLxYHfdQSdiDEhwlO(f94Icb1b4ar8pPooPw4QCqf(JMEqTGnf8dpfHsOWfww4ewmOYoG05DyTG6x0JlkeuH)OPtMru7r9wSyAYf5Ja35o1BLAbsD7VjfpaQpL6gPw5Gk8hn9G6d(ZDm8hn9Wfww4hwmOYoG05DyTG6x0JlkeuNjAhH6BILY9noTyKEoN5ysyhq68oOc)rtpOoJO2J6TyX0KRWfwEjfwmOc)rtpOEj6hHtl(Iy8aAPbv2bKoVdRfUWYlOCyXGk8hn9Gkup4mwmn5kOYoG05DyTWfwEHfclguzhq68oSwq9l6XffcQiOwlPqDgNwSyAYfzNMEqf(JMEqTqDgNwSyAYv4clVWsdlguH)OPhuflEY(Z40IhuFhuzhq68oSw4clVWsewmOYoG05DyTG6x0Jlkeu35rkytb)WtrOeIu8aO(uQJtQfwPwrfL6nJGATKc2uWp8uekHWgr7oxacTtV4jZdEHK64KALdQWF00dQq9GZyKomVWfwEbHByXGk7asN3H1cQFrpUOqqfb1AjIfpz)zCAXdQVjOIsTaPEZiOwl5s0pcNw8fX4b0sjOIsTaPEZiOwl5s0pcNw8fX4b0sjfpaQpL6vAKA4pA6eOEWzmshMhHvGF0JXhDWbv4pA6bvOEWzmshMx4clVGWgwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5IGkk1cKAeuRLa1doJfttUifpaQpL6vAK62Fl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxOGk8hn9Gkup4mgbQcA5WfwEHLCyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqDZiOwl5s0pcNw8fX4b0sjOIsTaP(Go7hbQhCgZFusyhq68wQfi1iOwlzZWfHKLZKDA6sTaPEZiOwl5s0pcNw8fX4b0sjfpaQpL64KA4pA6eOEWz8GoN0opjSc8JEm(OdwQfi1gk1XGudXeCrpMa1doJfrhdUt9wc7asN3sTIkk1iOwl57mupmpQ3I)iWDUt2PPl1geUWYliCclguzhq68oSwqf(JMEqfQhCgpOZjTZZG6hbupOUqq9l6XffcQiOwl57mupmpQ3skg(lCHLxq4hwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNsTaP2qP(ZSVttNa1doJfttUifpaQpL64K6fuwQvurPg(JAKXSZdkpL6vAK6Lk1geuH)OPhuH6bNXzHeUWYlSKclguzhq68oSwq9l6XffcQiOwlPqDgNwSyAYfbvuQvurPEaoqe)tQJtQxqydQWF00dQq9GZyKomVWfwEPkhwmOYoG05DyTGk8hn9GkBmF4OPhuP(XvHkEyQnOoahiI)fxJWxydQu)4QqfpmDm4nfooOUqq9l6XffcQiOwlPqDgNwSyAYfzNME4clV0fclguH)OPhuH6bNXiqvqlhuzhq68oSw4cxqLNt2FEgwmS8cHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)TuROIsTL2gD4Iha1Ns9ks9NzFNMobQhCglMMCrkEauFguH)OPhur6zUXPfFrmMDEeF4clV0WIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1nsTYsTaP2qPogK6d6SFe2702OJDEtyhq68wQvurP2qP(Go7hH9oTn6yN3e2bKoVLAbs9aCGi(NuhxJulCuwQvurP2iuuaPZeyGNIWqQBK6fKAdKAdKAbsTHsTHs9NzFNMo5s0pcNw8fX4b0sjfpaQpL64KAJqrbKotar8auaV5oeVulqQnuQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAfvuQncffq6mbg4PimK6gPEbP2aP2aPwrfLAdL6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaPgb1Ajq9GZ4pcQwMmp4fsQBKALLAdKAdKAbsncQ1skuNXPflMMCr2PPl1cK6b4ar8pPoUgP2iuuaPZeqepOoDGoWdWbS4Fbv4pA6bvKEMBCAXxeJzNhXhUWYlryXGk7asN3H1cQFrpUOqq9ZSVttNa1doJfttUifpaQpL64AKAHvzPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPELgPU93sTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeFqf(JMEq1mR(2itDCXZ0b)5Wfww4gwmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZKlVbEakG)iOA5PulqQ)m7700jq9GZyX0KlsXdG6tPELgPU93sTIkk1wAB0HlEauFk1Ri1FM9DA6eOEWzSyAYfP4bq9zqf(JMEq1mR(2itDCXZ0b)5Wfwwydlguzhq68oSwq9l6XffcQFM9DA6eOEWzSyAYfP4bq9Pu3i1kl1cKAdL6yqQpOZ(ryVtBJo25nHDaPZBPwrfLAdL6d6SFe2702OJDEtyhq68wQfi1dWbI4FsDCnsTWrzPwrfLAJqrbKotGbEkcdPUrQxqQnqQnqQfi1gk1gk1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mbeXdqb8M7q8sTaP2qPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQvurP2iuuaPZeyGNIWqQBK6fKAdKAdKAfvuQnuQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAeuRLa1doJ)iOAzY8GxiPUrQvwQnqQnqQfi1iOwlPqDgNwSyAYfzNMUulqQhGdeX)K64AKAJqrbKotar8G60b6apahWI)fuH)OPhunZQVnYuhx8mDWFoCHLxYHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)TuROIsTL2gD4Iha1Ns9ks9NzFNMobQhCglMMCrkEauFguH)OPhuBrHAtbhNwmetWvErHlSSWjSyqLDaPZ7WAb1VOhxuiO(z23PPtG6bNXIPjxKIha1NsDJuRSulqQnuQJbP(Go7hH9oTn6yN3e2bKoVLAfvuQnuQpOZ(ryVtBJo25nHDaPZBPwGupahiI)j1X1i1chLLAfvuQncffq6mbg4PimK6gPEbP2aP2aPwGuBOuBOu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAdLAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiPwrfLAJqrbKotGbEkcdPUrQxqQnqQnqQvurP2qP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuRSulqQrqTwcup4m(JGQLjZdEHK6gPwzP2aP2aPwGuJGATKc1zCAXIPjxKDA6sTaPEaoqe)tQJRrQncffq6mbeXdQthOd8aCal(xqf(JMEqTffQnfCCAXqmbx5ffUWYc)WIbv2bKoVdRfuH)OPhu)0F2VcoEJTDyWb1VOhxuiOIGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6sTaPEaoqo6GXxIhGcsDCnsnRa)OhJp6GdQDQZ4FhuxYHlS8skSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6sTaPEaoqo6GXxIhGcsDCnsnRa)OhJp6GdQWF00dQfdIuVfB7WGNHlS8ckhwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9GQnF0jVXqmbx0JXimmcxy5fwiSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfzNMUulqQrqTwsH6moTyX0KlYonDPwGuVzeuRLCj6hHtl(Iy8aAPKDA6bv4pA6bvr0IAJN6TyKomVWfwEHLgwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9GArff7mM64Pi8C4clVWsewmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9G6fXyuhjr9n2M1ZHlS8cc3WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxKDA6sTaPgb1AjfQZ40IfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPhuH)OPhuh8iR4XPf3rF6gVlggZWfUGkKCyXWYlewmOYoG05DyTG6x0JlkeuluNTz1YKnD(uXo1HkE8NJb4BchZOurrEl1cK6pZ(onDccQ1I305tf7uhQ4XFogGVjfd74LAbsncQ1s205tf7uhQ4XFogGVX2kNhzNMUulqQnuQrqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYonDP2aPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQvwQfi1gk1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PulqQnuQnuQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTbsTIkk1gk1XGuFqN9JuOoJtlwmn5IWoG05TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQnqQvurP(ZSVttNa1doJfttUifpaQpL6vAK62Fl1gi1geuH)OPhuTvopKSFHlS8sdlguzhq68oSwq9l6XffcQgk1fQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVLAbs9NzFNMobb1AXB68PIDQdv84phdW3KIHD8sTaPgb1AjB68PIDQdv84phdW3ylTyYonDPwGulwSrC7VjlqSvopKSFsTbsTIkk1gk1fQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVLAbs9rhSu3i1kl1geuH)OPhuT0IXiDyEHlS8sewmOYoG05DyTG6x0JlkeuluNTz1YK2Io7XJPp97mHJzuQOiVLAbs9NzFNMobQhCglMMCrkEauFk1Xj1lHYsTaP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuRSulqQnuQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotGKXxEd8aua)rq1YtPwGuBOuBOuFqN9JuOoJtlwmn5IWoG05TulqQ)m7700jfQZ40IfttUifpaQpL6vAK62Fl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQncffq6m5YBGhGc4n3H4LAdKAfvuQnuQJbP(Go7hPqDgNwSyAYfHDaPZBPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeVuBGuROIs9NzFNMobQhCglMMCrkEauFk1R0i1T)wQnqQniOc)rtpOARCEypncHlSSWnSyqLDaPZ7WAb1VOhxuiOwOoBZQLjTfD2JhtF63zchZOurrEl1cK6pZ(onDcup4mwmn5Iu8aO(uQBKALLAbsTHsTHsTHs9NzFNMo5s0pcNw8fX4b0sjfpaQpL64KAJqrbKotar8auaV5oeVulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAdKAfvuQnuQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQnqQnqQfi1iOwlPqDgNwSyAYfzNMUuBqqf(JMEq1w58WEAecxyzHnSyqLDaPZ7WAb1VOhxuiOwOoBZQLjtQyu645L1GWXmkvuK3sTaPwSyJ42FtwGWgZhoA6bv4pA6b1lr)iCAXxeJhqlnCHLxYHfdQSdiDEhwlO(f94Icb1c1zBwTmzsfJshpVSgeoMrPII8wQfi1gk1IfBe3(BYce2y(WrtxQvurPwSyJ42FtwGCj6hHtl(Iy8aAPsTbbv4pA6bvOEWzSyAYv4cllCclguzhq68oSwq9l6XffcQhDWsDCs9sOSulqQluNTz1YKjvmkD88YAq4ygLkkYBPwGuJGATeOEWz8hbvltMh8cj1R0i1gHIciDMajJV8g4bOa(JGQLNsTaP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuRSulqQ)m7700jq9GZyX0KlsXdG6tPELgPU93bv4pA6bv2y(WrtpCHLf(HfdQSdiDEhwlOc)rtpOYgZhoA6bvQFCvOIhMAdQiOwlzsfJshpVSgK5bVqniOwlzsfJshpVSgKbOaEEWluqL6hxfQ4HPJbVPWXb1fcQFrpUOqq9OdwQJtQxcLLAbsDH6SnRwMmPIrPJNxwdchZOurrEl1cK6pZ(onDcup4mwmn5Iu8aO(uQBKALLAbsTHsTHsTHs9NzFNMo5s0pcNw8fX4b0sjfpaQpL64KAJqrbKotar8auaV5oeVulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAdKAfvuQnuQ)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQnqQnqQfi1iOwlPqDgNwSyAYfzNMUuBq4clVKclguzhq68oSwq9l6XffcQgk1FM9DA6eOEWzSyAYfP4bq9PuhNulCfwPwrfL6pZ(onDcup4mwmn5Iu8aO(uQxPrQxcP2aPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQvwQfi1gk1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PulqQnuQnuQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1cRuBGuROIsTHsDmi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQfwP2aPwrfL6pZ(onDcup4mwmn5Iu8aO(uQxPrQB)TuBGuBqqf(JMEqDqRkRjoT4lRb7x4clVGYHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1Xj1gHIciDMut8auaV5oeVulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKAIhGc4n3H4LAbsTHs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TuROIs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQJtQncffq6mPM4bOaEZDiEPwrfL6yqQpOZ(rkuNXPflMMCryhq68wQnqQfi1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9GAbBk4hEkcLqHlS8clewmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAdLAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZeiz8L3apafWFeuT8uQfi1gk1gk1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPELgPU93sTaP(ZSVttNa1doJfttUifpaQpL64KAJqrbKotU8g4bOaEZDiEP2aPwrfLAdL6yqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1gi1kQOu)z23PPtG6bNXIPjxKIha1Ns9knsD7VLAdKAdcQWF00dQfSPGF4PiucfUWYlS0WIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1nsTYsTaP2qP2qP2qP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTrOOasNjGiEakG3ChIxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqsTbsTIkk1gk1FM9DA6Klr)iCAXxeJhqlLu8aO(uQBKALLAbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zcKm(YBGhGc4pcQwEk1gi1gi1cKAeuRLuOoJtlwmn5ISttxQniOc)rtpOwWMc(HNIqju4clVWsewmOYoG05DyTG6x0Jlkeu)m7700jq9GZyX0KlsXdG6tPUrQvwQfi1gk1gk1gk1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQncffq6mbeXdqb8M7q8sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQnqQvurP2qP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDJuRSulqQrqTwcup4m(JGQLjZdEHK6vAKAJqrbKotGKXxEd8aua)rq1YtP2aP2aPwGuJGATKc1zCAXIPjxKDA6sTbbv4pA6b1ndxeswohUWYliCdlguzhq68oSwq9l6XffcQiOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PulqQnuQnuQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTbsTIkk1gk1XGuFqN9JuOoJtlwmn5IWoG05TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQnqQvurP(ZSVttNa1doJfttUifpaQpL6vAK62Fl1geuH)OPhuVe9JWPfFrmEaT0WfwEbHnSyqLDaPZ7WAb1VOhxuiOAOuBOu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZeqepafWBUdXl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxiP2aPwrfLAdL6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6mbsgF5nWdqb8hbvlpLAdKAdKAbsncQ1skuNXPflMMCr2PPhuH)OPhuH6bNXIPjxHlS8cl5WIbv2bKoVdRfu)IECrHGkcQ1skuNXPflMMCr2PPl1cKAdLAdL6pZ(onDYLOFeoT4lIXdOLskEauFk1Xj1lvzPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1gi1kQOuBOu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQvwQfi1iOwlbQhCg)rq1YK5bVqs9knsTrOOasNjqY4lVbEakG)iOA5PuBGuBGulqQnuQ)m7700jq9GZyX0KlsXdG6tPooPEbHvQvurPEZiOwl5s0pcNw8fX4b0sjOIsTbbv4pA6b1c1zCAXIPjxHlS8ccNWIbv2bKoVdRfu)IECrHGkcQ1s2mCriz5mbvuQfi1Bgb1AjxI(r40IVigpGwkbvuQfi1Bgb1AjxI(r40IVigpGwkP4bq9PuVsJuJGATeXINS)moT4b13KbOaEEWlKulmKud)rtNa1doJr6W8iSc8JEm(OdoOc)rtpOkw8K9NXPfpO(oCHLxq4hwmOYoG05DyTG6x0JlkeurqTwYMHlcjlNjOIsTaP2qP2qP(Go7hP4z6G)mHDaPZBPwGud)rnYy25bLNs9ksTWvQnqQvurPg(JAKXSZdkpL6vKAHvQniOc)rtpOc1doJr6W8cxy5fwsHfdQWF00dQturU80ieuzhq68oSw4clVuLdlguzhq68oSwq9l6XffcQiOwlbQhCg)rq1YK5bVqsDJuRCqf(JMEqfQhCgNfs4clV0fclguzhq68oSwq9l6XffcQgk1fBlEgbiDwQvurPogK6J(cr9wP2aPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cfuH)OPhuD(I4cF8qKNx4clV0LgwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYonDPwGu)z23PPtG6bNXIPjxKIha1NsDCsTYsTaP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTYsTaP2qPogK6d6SFKc1zCAXIPjxe2bKoVLAfvuQnuQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1NsDCsTYsTbsTbbv4pA6b1ze1EuVflMMCfUWYlDjclguzhq68oSwq9l6XffcQiOwl57mupmpQ3skg(tQfi1fQZ2SAzcup4mM6wQtV4jCmJsff5TulqQpOZ(rGHyNAPpC00jSdiDEl1cKA4pQrgZopO8uQxrQxsbv4pA6bvOEWz8GoN0opdxy5LkCdlguzhq68oSwq9l6XffcQiOwl57mupmpQ3skg(tQfi1fQZ2SAzcup4mM6wQtV4jCmJsff5TulqQH)Ogzm78GYtPEfPEjhuH)OPhuH6bNXd6Cs78mCHLxQWgwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vKAeuRLa1doJ)iOAzYauapp4fkOc)rtpOc1doJzfe75KME4clV0LCyXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQfi1IfBe3(BYceOEWzmcuf0Ybv4pA6bvOEWzmRGypN00dxy5LkCclguzhq68oSwq9l6XffcQiOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqbv4pA6bvOEWzmcuf0YHlS8sf(HfdQu)4Qqfpm1guhGdeX)IRr4lSbvQFCvOIhMog8MchhuxiOc)rtpOYgZhoA6bv2bKoVdRfUWfuR8GJMEyXWYlewmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAdLAeuRLa1doJ)iOAzY8GxiPooP2iuuaPZKlVbEakG)iOA5PulqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6Kc1zCAXIPjxKIha1Ns9knsD7VLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTaP(tJSd(rek(IcUulqQ)m7700jfSPGF4PiucrkEauFk1R0i1cFP2GGk8hn9Gkup4mgbQcA5WfwEPHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaP2qPgb1Ajq9GZ4pcQwMmp4fsQJtQncffq6m5YBGhGc4pcQwEk1cK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeVulqQJbP(tJSd(rek(IcUuBqqf(JMEqfQhCgJavbTC4clVeHfdQSdiDEhwlO(f94Icb1pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaP2qPgb1Ajq9GZ4pcQwMmp4fsQJtQncffq6m5YBGhGc4pcQwEk1cK6yqQpOZ(rkuNXPflMMCryhq68wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuBekkG0zYL3apafWBUdXl1geuH)OPhuH6bNXiqvqlhUWYc3WIbv2bKoVdRfu)IECrHG6NzFNMo5s0pcNw8fX4b0sjfpaQpL6gPwzPwGuBOuJGATeOEWz8hbvltMh8cj1Xj1gHIciDMC5nWdqb8hbvlpLAbs9NzFNMobQhCglMMCrkEauFk1R0i1T)wQniOc)rtpOc1doJrGQGwoCHLf2WIbv2bKoVdRfu)IECrHG6MrqTwsbBk4hEkcLqyJODNlaH2Px8K5bVqsDJuVzeuRLuWMc(HNIqje2iA35cqOD6fpzakGNh8cj1cKAdLAeuRLa1doJfttUi700LAfvuQrqTwcup4mwmn5Iu8aO(uQxPrQB)TuBGulqQnuQrqTwsH6moTyX0KlYonDPwrfLAeuRLuOoJtlwmn5Iu8aO(uQxPrQB)TuBqqf(JMEqfQhCgJavbTC4clVKdlguzhq68oSwq9l6XffcQ78ifSPGF4PiucrkEauFk1Xj1cRuROIs9MrqTwsbBk4hEkcLqyJODNlaH2Px8K5bVqsDCsTYbv4pA6bvOEWzmshMx4cllCclguzhq68oSwq9l6XffcQiOwlrS4j7pJtlEq9nbvuQfi1Bgb1AjxI(r40IVigpGwkbvuQfi1Bgb1AjxI(r40IVigpGwkP4bq9PuVsJud)rtNa1doJr6W8iSc8JEm(OdoOc)rtpOc1doJr6W8cxyzHFyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqDZiOwl5s0pcNw8fX4b0sjOIsTaP(Go7hbQhCgZFusyhq68wQfi1iOwlzZWfHKLZKDA6sTaP2qPEZiOwl5s0pcNw8fX4b0sjfpaQpL64KA4pA6eOEWz8GoN0opjSc8JEm(OdwQvurP(ZSVttNiw8K9NXPfpO(Mu8aO(uQJtQvwQvurP(tJSd(rek(IcUuBGulqQnuQJbPgIj4IEmbQhCglIogCN6Te2bKoVLAfvuQrqTwY3zOEyEuVf)rG7CNSttxQniCHLxsHfdQSdiDEhwlO(f94IcbveuRL8DgQhMh1Bjfd)j1cKAeuRLWkic(M3yX8y)OqNGkguH)OPhuH6bNXd6Cs78mCHLxq5WIbv2bKoVdRfuH)OPhuH6bNXd6Cs78mO(ra1dQleu)IECrHGkcQ1s(od1dZJ6TKIH)KAbsTHsncQ1sG6bNXIPjxeurPwrfLAeuRLuOoJtlwmn5IGkk1kQOuVzeuRLCj6hHtl(Iy8aAPKIha1NsDCsn8hnDcup4mEqNtANNewb(rpgF0bl1geUWYlSqyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqfb1AjFNH6H5r9wsXWFsTaPgb1AjFNH6H5r9wY8GxiPUrQrqTwY3zOEyEuVLmafWZdEHcxy5fwAyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqfb1AjFNH6H5r9wsXWFsTaPgb1AjFNH6H5r9wsXdG6tPELgP2qP2qPgb1AjFNH6H5r9wY8GxiPwyiPg(JMobQhCgpOZjTZtcRa)OhJp6GLAdK61L62Fl1geUWYlSeHfdQSdiDEhwlO(f94IcbvdL6ITfpJaKol1kQOuhds9rFHOERuBGulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAbsncQ1sG6bNXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700dQWF00dQoFrCHpEiYZlCHLxq4gwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vAKAJqrbKotU8g4bOa(JGQLNbv4pA6bvOEWzCwiHlS8ccByXGk7asN3H1cQFrpUOqqDaoqe)tQxPrQxscRulqQrqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9G6evKlpncHlS8cl5WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxKDA6sTaPgb1AjfQZ40IfttUi700LAbs9MrqTwYLOFeoT4lIXdOLs2PPl1cK6pZ(onDcBmF4OPtkEauFk1Xj1kl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQvwQfi1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQvwQfi1gk1XGuFqN9JuOoJtlwmn5IWoG05TuROIsTHs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQJtQvwQnqQniOc)rtpOoJO2J6TyX0KRWfwEbHtyXGk7asN3H1cQFrpUOqqfb1AjfANXPfFrfZtcQOulqQrqTwcup4m(JGQLjZdEHK64K6LiOc)rtpOc1doJr6W8cxy5fe(HfdQSdiDEhwlO(f94Icb1b4ar8pPEfP2iuuaPZeeOkOLXdWbS4FsTaP(ZSVttNWgZhoA6KIha1NsDCsTYsTaPgb1Ajq9GZyX0KlYonDPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1cKAEoz)zIr6KMooTyrUS8F00jdQNvqf(JMEqfQhCgJavbTC4clVWskSyqLDaPZ7WAb1VOhxuiO(z23PPtUe9JWPfFrmEaTusXdG6tPUrQvwQfi1gk1FM9DA6Kc1zCAXIPjxKIha1NsDJuRSuROIs9NzFNMobQhCglMMCrkEauFk1nsTYsTbsTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fkOc)rtpOc1doJrGQGwoCHLxQYHfdQSdiDEhwlO(f94Icb1b4ar8pPELgP2iuuaPZeeOkOLXdWbS4FsTaPgb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700LAbsncQ1sG6bNXFeuTmzEWlKu3i1iOwlbQhCg)rq1YKbOaEEWlKulqQ)m7700jSX8HJMoP4bq9PuhNuRCqf(JMEqfQhCgJavbTC4clV0fclguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMUulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAbs9bD2pcup4molec7asN3sTaP(ZSVttNa1doJZcHu8aO(uQxPrQB)TulqQhGdeX)K6vAK6LKYsTaP(ZSVttNWgZhoA6KIha1NsDCsTYbv4pA6bvOEWzmcuf0YHlS8sxAyXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlcQOulqQrqTwcup4mwmn5Iu8aO(uQxPrQB)TulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHcQWF00dQq9GZyeOkOLdxy5LUeHfdQSdiDEhwlO(f94IcbveuRLuOoJtlwmn5IGkk1cKAeuRLuOoJtlwmn5Iu8aO(uQxPrQB)TulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHcQWF00dQq9GZyeOkOLdxy5LkCdlguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkbvuQfi1Bgb1AjxI(r40IVigpGwkP4bq9PuVsJu3(BPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cfuH)OPhuH6bNXiqvqlhUWYlvydlguH)OPhuH6bNXiDyEbv2bKoVdRfUWYlDjhwmOs9JRcv8WuBqDaoqe)lUgHVWguP(XvHkEy6yWBkCCqDHGk8hn9GkBmF4OPhuzhq68oSw4clVuHtyXGk8hn9Gkup4mgbQcA5Gk7asN3H1cxy5Lk8dlguzhq68oSwqnfdQt(cQWF00dQgHIciDoOAe6OCqDHG6x0JlkeurqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHKAbsDmi1iOwlPq7moT4lQyEsqfLAbsTL2gD4Iha1Ns9knsTHsTHs9aCqQxvQH)OPtG6bNXiDyEKpNNuBGulmKud)rtNa1doJr6W8iSc8JEm(OdwQniOAekSddoOAPo0XiOLhUWfu)m7700NHfdlVqyXGk7asN3H1cQFrpUOqqTqD2MvltAl6ShpM(0VZeoMrPII8wQfi1FM9DA6eOEWzSyAYfP4bq9PuhNuVekl1cK6pZ(onDYLOFeoT4lIXdOLskEauFk1nsTYsTaP2qPgb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cKAdLAdL6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeVuBGuROIsTHsDmi1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQncffq6m5YBGhGc4n3H4LAdKAfvuQ)m7700jq9GZyX0KlsXdG6tPELgPU93sTbsTbbv4pA6bvBLZd7PriCHLxAyXGk7asN3H1cQFrpUOqqTqD2MvltAl6ShpM(0VZeoMrPII8wQfi1FM9DA6eOEWzSyAYfP4bq9Pu3i1kl1cKAdL6yqQpOZ(ryVtBJo25nHDaPZBPwrfLAdL6d6SFe2702OJDEtyhq68wQfi1dWbI4FsDCnsTWrzP2aP2aPwGuBOuBOu)z23PPtUe9JWPfFrmEaTusXdG6tPooPEbLLAbsncQ1sG6bNXFeuTmzEWlKu3i1iOwlbQhCg)rq1YKbOaEEWlKuBGuROIsTHs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6gPwzPwGuJGATeOEWz8hbvltMh8cj1nsTYsTbsTbsTaPgb1AjfQZ40IfttUi700LAbs9aCGi(NuhxJuBekkG0zciIhuNoqh4b4aw8VGk8hn9GQTY5H90ieUWYlryXGk7asN3H1cQFrpUOqqTqD2Mvlt205tf7uhQ4XFogGVjCmJsff5TulqQ)m7700jiOwlEtNpvStDOIh)5ya(MumSJxQfi1iOwlztNpvStDOIh)5ya(gBRCEKDA6sTaP2qPgb1Ajq9GZyX0KlYonDPwGuJGATKc1zCAXIPjxKDA6sTaPEZiOwl5s0pcNw8fX4b0sj700LAdKAbs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6gPwzPwGuBOuJGATeOEWz8hbvltMh8cj1R0i1gHIciDMC5nWdqb8hbvlpLAbsTHsTHs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQnqQvurP2qPogK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMobQhCglMMCrkEauFk1Xj1gHIciDMC5nWdqb8M7q8sTbsTIkk1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(BP2aP2GGk8hn9GQTY5HK9lCHLfUHfdQSdiDEhwlO(f94Icb1c1zBwTmztNpvStDOIh)5ya(MWXmkvuK3sTaP(ZSVttNGGAT4nD(uXo1HkE8NJb4BsXWoEPwGuJGATKnD(uXo1HkE8NJb4BSLwmzNMUulqQfl2iU93Kfi2kNhs2VGk8hn9GQLwmgPdZlCHLf2WIbv2bKoVdRfu)IECrHG6NzFNMo5s0pcNw8fX4b0sjfpaQpL6gPwzPwGuJGATeOEWz8hbvltMh8cj1R0i1gHIciDMC5nWdqb8hbvlpLAbs9NzFNMobQhCglMMCrkEauFk1R0i1T)oOc)rtpOoOvL1eNw8L1G9lCHLxYHfdQSdiDEhwlO(f94Icb1pZ(onDcup4mwmn5Iu8aO(uQBKALLAbsTHsDmi1h0z)iS3PTrh78MWoG05TuROIsTHs9bD2pc7DAB0XoVjSdiDEl1cK6b4ar8pPoUgPw4OSuBGuBGulqQnuQnuQ)m7700jxI(r40IVigpGwkP4bq9PuhNuBekkG0zciIhGc4n3H4LAbsncQ1sG6bNXFeuTmzEWlKu3i1iOwlbQhCg)rq1YKbOaEEWlKuBGuROIsTHs9NzFNMo5s0pcNw8fX4b0sjfpaQpL6gPwzPwGuJGATeOEWz8hbvltMh8cj1nsTYsTbsTbsTaPgb1AjfQZ40IfttUi700LAbs9aCGi(NuhxJuBekkG0zciIhuNoqh4b4aw8VGk8hn9G6GwvwtCAXxwd2VWfww4ewmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9Pu3i1kl1cKAeuRLa1doJ)iOAzY8GxiPELgP2iuuaPZKlVbEakG)iOA5PulqQ)m7700jq9GZyX0KlsXdG6tPELgPU93bv4pA6b1ndxeswohUWYc)WIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1nsTYsTaP2qPogK6d6SFe2702OJDEtyhq68wQvurP2qP(Go7hH9oTn6yN3e2bKoVLAbs9aCGi(NuhxJulCuwQnqQnqQfi1gk1gk1FM9DA6Klr)iCAXxeJhqlLu8aO(uQJtQxqzPwGuJGATeOEWz8hbvltMh8cj1nsncQ1sG6bNXFeuTmzakGNh8cj1gi1kQOuBOu)z23PPtUe9JWPfFrmEaTusXdG6tPUrQvwQfi1iOwlbQhCg)rq1YK5bVqsDJuRSuBGuBGulqQrqTwsH6moTyX0KlYonDPwGupahiI)j1X1i1gHIciDMaI4b1Pd0bEaoGf)lOc)rtpOUz4IqYY5WfwEjfwmOYoG05DyTG6x0Jlkeu)m7700jxI(r40IVigpGwkP4bq9PuhNuBekkG0zsnXdqb8M7q8sTaP(ZSVttNa1doJfttUifpaQpL64KAJqrbKotQjEakG3ChIxQfi1gk1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPELgPU93sTIkk1h0z)ifQZ40IfttUiSdiDEl1cK6pZ(onDsH6moTyX0KlsXdG6tPooP2iuuaPZKAIhGc4n3H4LAfvuQJbP(Go7hPqDgNwSyAYfHDaPZBP2aPwGuJGATeOEWz8hbvltMh8cj1Xj1lvQfi1Bgb1AjxI(r40IVigpGwkzNMEqf(JMEqTGnf8dpfHsOWfwEbLdlguzhq68oSwq9l6XffcQFM9DA6Klr)iCAXxeJhqlLu8aO(uQBKALLAbsncQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zYL3apafWFeuT8uQfi1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(7Gk8hn9GAbBk4hEkcLqHlS8clewmOYoG05DyTG6x0Jlkeu)m7700jq9GZyX0KlsXdG6tPUrQvwQfi1gk1gk1XGuFqN9JWEN2gDSZBc7asN3sTIkk1gk1h0z)iS3PTrh78MWoG05TulqQhGdeX)K64AKAHJYsTbsTbsTaP2qP2qP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTrOOasNjGiEakG3ChIxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqsTbsTIkk1gk1FM9DA6Klr)iCAXxeJhqlLu8aO(uQBKALLAbsncQ1sG6bNXFeuTmzEWlKu3i1kl1gi1gi1cKAeuRLuOoJtlwmn5ISttxQfi1dWbI4FsDCnsTrOOasNjGiEqD6aDGhGdyX)KAdcQWF00dQfSPGF4PiucfUWYlS0WIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1Ri1cRYsTaPMNt2FMyKoPPJtlwKll)hnDYG6zfuH)OPhuVe9JWPfFrmEaT0WfwEHLiSyqLDaPZ7WAb1VOhxuiOIGATeOEWz8hbvltMh8cj1R0i1gHIciDMC5nWdqb8hbvlpLAbs9bD2psH6moTyX0Klc7asN3sTaP(ZSVttNuOoJtlwmn5Iu8aO(uQxPrQB)TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIxQfi1FAKDWpIqXxuWLAbs9NzFNMoPGnf8dpfHsisXdG6tPELgPw4huH)OPhuVe9JWPfFrmEaT0WfwEbHByXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQxPrQncffq6m5YBGhGc4pcQwEk1cK6d6SFKc1zCAXIPjxe2bKoVLAbs9NzFNMoPqDgNwSyAYfP4bq9PuVsJu3(BPwGu)z23PPtG6bNXIPjxKIha1NsDCsTrOOasNjxEd8auaV5oeVulqQJbP(tJSd(rek(IcEqf(JMEq9s0pcNw8fX4b0sdxy5fe2WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zYL3apafWFeuT8uQfi1XGuFqN9JuOoJtlwmn5IWoG05TulqQ)m7700jq9GZyX0KlsXdG6tPooP2iuuaPZKlVbEakG3ChIpOc)rtpOEj6hHtl(Iy8aAPHlS8cl5WIbv2bKoVdRfu)IECrHGkcQ1sG6bNXFeuTmzEWlKuVsJuBekkG0zYL3apafWFeuT8uQfi1FM9DA6eOEWzSyAYfP4bq9PuVsJu3(7Gk8hn9G6LOFeoT4lIXdOLgUWYliCclguzhq68oSwq9l6XffcQgk1XGuFqN9JWEN2gDSZBc7asN3sTIkk1gk1h0z)iS3PTrh78MWoG05TulqQhGdeX)K64AKAHJYsTbsTbsTaP(ZSVttNCj6hHtl(Iy8aAPKIha1NsDCsTrOOasNjGiEakG3ChIxQfi1iOwlbQhCg)rq1YK5bVqsDJuJGATeOEWz8hbvltgGc45bVqsTaPgb1AjfQZ40IfttUi700LAbs9aCGi(NuhxJuBekkG0zciIhuNoqh4b4aw8VGk8hn9Gkup4mwmn5kCHLxq4hwmOYoG05DyTG6x0JlkeurqTwsH6moTyX0KlYonDPwGu)z23PPtUe9JWPfFrmEaTusXdG6tPooP2iuuaPZKkfXdqb8M7q8sTaPgb1Ajq9GZ4pcQwMmp4fsQBKAeuRLa1doJ)iOAzYauapp4fsQfi1gk1FM9DA6eOEWzSyAYfP4bq9PuhNuVGWk1kQOuVzeuRLCj6hHtl(Iy8aAPeurP2GGk8hn9GAH6moTyX0KRWfwEHLuyXGk7asN3H1cQFrpUOqqfb1Ajq9GZ4pcQwMmp4fsQBKALLAbs9Ngzh8Jiu8ff8Gk8hn9GQyXt2FgNw8G67WfwEPkhwmOYoG05DyTG6x0Jlkeu3mcQ1sUe9JWPfFrmEaTucQOulqQJbP(tJSd(rek(IcEqf(JMEqvS4j7pJtlEq9D4cxqDZwaTFHfdlVqyXGk7asN3H1cQFrpUOqq9GQLpYMrqTwYdZJ6TKIH)cQWF00dQFI6hxtrU3dxy5LgwmOYoG05DyTGk8hn9G6d9og(JMoUtNxqTtNh2HbhuNrqXB8VNHlS8sewmOYoG05DyTGk8hn9G6d9og(JMoUtNxqTtNh2Hbhu55K9NNHlSSWnSyqLDaPZ7WAb1VOhxuiOc)rnYy25bLNsDCs9sdQWF00dQp07y4pA64oDEb1oDEyhgCqfsoCHLf2WIbv2bKoVdRfu)IECrHGQrOOasNjrGrgNISZBPELgPw5Gk8hn9G6d9og(JMoUtNxqTtNh2Hbhutr25kCHLxYHfdQSdiDEhwlO(f94IcbvJqrbKotGbEkcdPUrQxiOc)rtpO(qVJH)OPJ705fu705HDyWbvyGNIWiCHLfoHfdQSdiDEhwlOc)rtpO(qVJH)OPJ705fu705HDyWb1pZ(on9z4cll8dlguzhq68oSwq9l6XffcQgHIciDMyPo0XiOLl1nsTYbv4pA6b1h6Dm8hnDCNoVGANopSddoOw5bhn9WfwEjfwmOYoG05DyTG6x0Jlkeuncffq6mXsDOJrqlxQBK6fcQWF00dQp07y4pA64oDEb1oDEyhgCq1sDOJrqlpCHLxq5WIbv2bKoVdRfuH)OPhuFO3XWF00XD68cQD68Wom4G6inYd2VWfUGQyXFoqGlSyy5fclguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GQyXIO9oMnMb1nBb0(fuvoCHLxAyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQleu)IECrHGQrOOasNjIflI27y2yk1nsTYsTaPUqD2MvltMuXO0XZlRbHJzuQOiVLAbsn8h1iJzNhuEk1Xj1lnOAekSddoOkwSiAVJzJz4clVeHfdQSdiDEhwlOMIb1jFbv4pA6bvJqrbKohuncDuoOUqq9l6XffcQgHIciDMiwSiAVJzJPu3i1kl1cK6c1zBwTmzsfJshpVSgeoMrPII8wQfi1FAKDWpIZFL9S2sTaPg(JAKXSZdkpL64K6fcQgHc7WGdQIflI27y2ygUWYc3WIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhuxiO(f94IcbvJqrbKotelweT3XSXuQBKALLAbsDH6SnRwMmPIrPJNxwdchZOurrEl1cK6pnYo4hXPTrh2cCq1iuyhgCqvSyr0EhZgZWfwwydlguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GAeyKXPi78oOUzlG2VGQYHlS8soSyqLDaPZ7WAb1umOo5lOc)rtpOAekkG05GQrOJYb1fcQFrpUOqq1iuuaPZKiWiJtr25Tu3i1kl1cKA4pQrgZopO8uQJtQxAq1iuyhgCqncmY4uKDEhUWYcNWIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhuxiO(f94IcbvJqrbKotIaJmofzN3sDJuRSulqQncffq6mrSyr0EhZgtPUrQxiOAekSddoOgbgzCkYoVdxyzHFyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQkhuncf2HbhuTuh6ye0Ydxy5LuyXGk7asN3H1cQPyqT4jFbv4pA6bvJqrbKohuncf2HbhuRjEakG3ChIpOUzlG2VGQWgUWYlOCyXGk7asN3H1cQPyqT4jFbv4pA6bvJqrbKohuncf2Hbhubr8auaV5oeFqDZwaTFb1fuoCHLxyHWIbv2bKoVdRfutXGAXt(cQWF00dQgHIciDoOAekSddoOwPiEakG3ChIpOUzlG2VG6svoCHLxyPHfdQSdiDEhwlOMIb1IN8fuH)OPhuncffq6Cq1iuyhgCq9YBGhGc4n3H4dQB2cO9lOkSHlS8clryXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQlrq9l6XffcQgHIciDMC5nWdqb8M7q8sDJulSsTaPUqD2Mvlt205tf7uhQ4XFogGVjCmJsff5Dq1iuyhgCq9YBGhGc4n3H4dxy5feUHfdQSdiDEhwlOMIb1jFbv4pA6bvJqrbKohuncDuoOUGWgu)IECrHGQrOOasNjxEd8auaV5oeVu3i1cRulqQ)0i7GFeN2gDylWbvJqHDyWb1lVbEakG3ChIpCHLxqydlguzhq68oSwqnfdQt(cQWF00dQgHIciDoOAe6OCqDbHnO(f94IcbvJqrbKotU8g4bOaEZDiEPUrQfwPwGu)PVrPhbQhCglw5M2gpHDaPZBPwGud)rnYy25bLNs9ks9seuncf2HbhuV8g4bOaEZDi(WfwEHLCyXGk7asN3H1cQPyqDYxqf(JMEq1iuuaPZbvJqhLdQlHYb1VOhxuiOAekkG0zYL3apafWBUdXl1nsTWk1cKAEoz)zIr6KMooTyrUS8F00jdQNvq1iuyhgCq9YBGhGc4n3H4dxy5feoHfdQSdiDEhwlOMIb1IN8fuH)OPhuncffq6Cq1iuyhgCqfbQcAz8aCal(xqDZwaTFbvHJYHlS8cc)WIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhufUkhu)IECrHGQrOOasNjiqvqlJhGdyX)K6gPw4OSulqQ)0i7GFeN2gDylWbvJqHDyWbveOkOLXdWbS4FHlS8clPWIbv2bKoVdRfutXGAXt(cQWF00dQgHIciDoOAekSddoOcI4b1Pd0bEaoGf)lOUzlG2VG6sOC4clVuLdlguzhq68oSwqnfdQt(cQWF00dQgHIciDoOAe6OCqvyvoO(f94IcbvJqrbKotar8G60b6apahWI)j1ns9sOSulqQluNTz1YKnD(uXo1HkE8NJb4BchZOurrEhuncf2Hbhubr8G60b6apahWI)fUWYlDHWIbv2bKoVdRfutXG6KVGk8hn9GQrOOasNdQgHokhufwLdQFrpUOqq1iuuaPZeqepOoDGoWdWbS4FsDJuVekl1cK6c1zBwTmPTOZE8y6t)ot4ygLkkY7GQrOWom4GkiIhuNoqh4b4aw8VWfwEPlnSyqLDaPZ7WAb1umOw8KVGk8hn9GQrOOasNdQgHc7WGdQxEd8aua)rq1YZG6MTaA)cQlnCHLx6sewmOYoG05DyTGAkgulEYxqf(JMEq1iuuaPZbvJqHDyWbviz8L3apafWFeuT8mOUzlG2VG6sdxy5LkCdlguzhq68oSwqnfdQfp5lOc)rtpOAekkG05GQrOWom4GkmWtryeu3Sfq7xqDY3r92jbg4Pimcxy5LkSHfdQSdiDEhwlCHLx6soSyqLDaPZ7WAHlS8sfoHfdQSdiDEhwlCHLxQWpSyqf(JMEqDIogPJH6bNXwyq7uOcQSdiDEhwlCHLx6skSyqf(JMEqfQhCgt9J7D(VGk7asN3H1cxy5Lq5WIbv4pA6b1pDHhqlgpahWT8iOYoG05DyTWfwEjwiSyqLDaPZ7WAHlS8sS0WIbv4pA6b1bTQSW0b0Ybv2bKoVdRfUWYlXsewmOYoG05DyTG6x0Jlkeuncffq6mrSyr0EhZgtPELgPw5Gk8hn9GQTY5HK9lCHLxcHByXGk7asN3H1cQFrpUOqq1iuuaPZeXIfr7DmBmL64KALdQWF00dQSX8HJME4cxqfg4PimclgwEHWIbv2bKoVdRfu)IECrHGkcQ1skuNXPflMMCr2PPl1cK6pZ(onDcup4mwmn5Iu8aO(uQJtQvoOc)rtpOwOoJtlwmn5kCHLxAyXGk7asN3H1cQFrpUOqq1qP(ZSVttNa1doJfttUifpaQpL6gPwzPwGuJGATKc1zCAXIPjxKDA6sTbsTIkk1IfBe3(BYcKc1zCAXIPjxbv4pA6b1lr)iCAXxeJhqlnCHLxIWIbv2bKoVdRfu)IECrHG6NzFNMobQhCglMMCrkEauFk1Ri1cRYsTaPgb1AjfQZ40IfttUi700LAbsnpNS)mXiDsthNwSixw(pA6e2bKoVdQWF00dQxI(r40IVigpGwA4cllCdlguzhq68oSwq9l6XffcQiOwlPqDgNwSyAYfzNMUulqQ)m7700jxI(r40IVigpGwkP4bq9PuhNuBekkG0zciIhGc4n3H4dQWF00dQq9GZyX0KRWfwwydlguzhq68oSwq9l6XffcQiOwlbQhCglMMCrqfLAbsncQ1sG6bNXIPjxKIha1Ns9knsn8hnDcup4mEqNtANNewb(rpgF0bl1cKAeuRLa1doJ)iOAzY8GxiPUrQrqTwcup4m(JGQLjdqb88GxOGk8hn9Gkup4mgbQcA5WfwEjhwmOYoG05DyTG6x0JlkeurqTwcup4m(JGQLjZdEHK6vKAeuRLa1doJ)iOAzYauapp4fsQfi1iOwlPqDgNwSyAYfzNMUulqQrqTwcup4mwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMEqf(JMEqfQhCgNfs4cllCclguzhq68oSwq9l6XffcQiOwlPqDgNwSyAYfzNMUulqQrqTwcup4mwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMUulqQrqTwcup4m(JGQLjZdEHK6gPgb1Ajq9GZ4pcQwMmafWZdEHcQWF00dQq9GZyeOkOLdxyzHFyXGk7asN3H1cQWF00dQq9GZ4bDoPDEgu)iG6b1fcQFrpUOqqfb1AjFNH6H5r9wsXWFHlS8skSyqLDaPZ7WAbv4pA6bvOEWz8GoN0opdQFeq9G6cb1VOhxuiOgdsnetWf9ycup4mweDm4o1BjSdiDEl1kQOuJGATKVZq9W8OEl(Ja35ozNME4clVGYHfdQSdiDEhwlO(f94Icbv4pA6e2y(WrtN8rG7CN6TsTaPEaoqe)tQJRrQxscBqf(JMEq9b)5og(JME4clVWcHfdQWF00dQSX8HJMEqLDaPZ7WAHlS8clnSyqLDaPZ7WAb1VOhxuiOIGATeOEWz8hbvltMh8cj1Ri1iOwlbQhCg)rq1YKbOaEEWluqf(JMEqfQhCgNfs4clVWsewmOc)rtpOc1doJrGQGwoOYoG05DyTWfwEbHByXGk8hn9Gkup4mgPdZlOYoG05DyTWfUG6mckEJ)9mSyy5fclguzhq68oSwq9l6XffcQgk1h0z)iS3PTrh78MWoG05TulqQhGdeX)K6vAKAHVYsTaPEaoqe)tQJRrQxYcRuBGuROIsTHsDmi1h0z)iS3PTrh78MWoG05TulqQhGdeX)K6vAKAHVWk1geuH)OPhuhGd4wEeUWYlnSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfbvmOc)rtpOIozm94XmCHLxIWIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeuXGk8hn9GQyE00dxyzHByXGk7asN3H1cQFrpUOqqTqD2MvltoEiMf0XMqjs4ygLkkYBPwGuJGATewHiaDE00jOIbv4pA6b1JoySjuIHlSSWgwmOYoG05DyTG6x0JlkeurqTwcup4mwmn5ISttxQfi1iOwlPqDgNwSyAYfzNMUulqQ3mcQ1sUe9JWPfFrmEaTuYon9Gk8hn9GAN2gDtSWdO72b7x4clVKdlguzhq68oSwq9l6XffcQiOwlbQhCglMMCr2PPl1cKAeuRLuOoJtlwmn5ISttxQfi1Bgb1AjxI(r40IVigpGwkzNMEqf(JMEqfbAXPfFf9fAgUWYcNWIbv2bKoVdRfu)IECrHGkcQ1sG6bNXIPjxeuXGk8hn9GkcxtUeI6THlSSWpSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfbvmOc)rtpOI0ZCJTOv8HlS8skSyqLDaPZ7WAb1VOhxuiOIGATeOEWzSyAYfbvmOc)rtpOAPfJ0ZChUWYlOCyXGk7asN3H1cQFrpUOqqfb1Ajq9GZyX0KlcQyqf(JMEqf8NNxbD8d9E4cxqDKg5b7xyXWYlewmOYoG05DyTG6x0JlkeuhPrEW(r205b(ZsDCns9ckhuH)OPhur6uxOWfwEPHfdQWF00dQIfpz)zCAXdQVdQSdiDEhwlCHLxIWIbv2bKoVdRfu)IECrHG6inYd2pYMopWFwQxrQxq5Gk8hn9Gkup4mEqNtANNHlSSWnSyqf(JMEqfQhCgNfsqLDaPZ7WAHlSSWgwmOc)rtpOAPfJr6W8cQSdiDEhwlCHlOAPo0XiOLhwmS8cHfdQSdiDEhwlOc)rtpOc1doJh05K25zq9JaQhuxiO(f94IcbveuRL8DgQhMh1Bjfd)fUWYlnSyqf(JMEqfQhCgJ0H5fuzhq68oSw4clVeHfdQWF00dQq9GZyeOkOLdQSdiDEhwlCHlCbvJCnPPhwEPkVuLxq5LUqq1ekN6TZGQWWegi84YcVwoMwHrPwQxmILA6qmRtQTzj1XyLhC00JrPU4ygLw8wQN5GLAa9YbC8wQ)iWB5jrgBmj1zPEbHrPoMkDJCD8wQJXpnYo4hryMWoG05Dmk1xk1X4Ngzh8JimhJsTHlOGbezSXKuNL6Lkmk1XuPBKRJ3sDm(Pr2b)icZe2bKoVJrP(sPog)0i7GFeH5yuQnCbfmGiJnMK6Sul8fgL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gUGcgqKXgtsDwQxQWxyuQJPs3ixhVLAv6iMsQNX7hOGul8CP(sPoMefK6n1iDstxQtrUGllP2WvnqQnCbfmGiJvgRWWegi84YcVwoMwHrPwQxmILA6qmRtQTzj1XOyXFoqGlgL6IJzuAXBPEMdwQb0lhWXBP(JaVLNezSXKuNL6LqyuQJPs3ixhVL6y8tJSd(reMjSdiDEhJs9LsDm(Pr2b)icZXOuB4ckyargBmj1zPw4kmk1XuPBKRJ3sDm(Pr2b)icZe2bKoVJrP(sPog)0i7GFeH5yuQnCbfmGiJnMK6SuVGWvyuQJPs3ixhVL6y8tJSd(reMjSdiDEhJs9LsDm(Pr2b)icZXOuB4ckyargBmj1zPEbHVWOuhtLUrUoEl1X4Ngzh8Jimtyhq68ogL6lL6y8tJSd(reMJrP2WfuWaImwzScdtyGWJll8A5yAfgLAPEXiwQPdXSoP2MLuhJFM9DA6ZyuQloMrPfVL6zoyPgqVCahVL6pc8wEsKXgtsDwQxyjegL6yQ0nY1XBPog)0i7GFeHzc7asN3XOuFPuhJFAKDWpIWCmk1gUGcgqKXgtsDwQxq4kmk1XuPBKRJ3sDm(Pr2b)icZe2bKoVJrP(sPog)0i7GFeH5yuQnCbfmGiJnMK6SuVWssyuQJPs3ixhVL6y8tJSd(reMjSdiDEhJs9LsDm(Pr2b)icZXOuB4ckyargBmj1zPEPklmk1XuPBKRJ3sDm(Pr2b)icZe2bKoVJrP(sPog)0i7GFeH5yuQnCbfmGiJvgRWRHywhVL6fwqQH)OPl1D68MezSbva9IYkOQshOD4OPhtvG9cQIvAPDoOgtxQfEc0YsTWG6bNLXgtxQfE6Fjcxs9sxQss9svEPklJvgl8hn9jrS4phiWTEZQgHIciDwjhgCJyXIO9oMnMkLInfp5tPnBb0(1OSmw4pA6tIyXFoqGB9Mvncffq6Ssom4gXIfr7DmBmvkfBM8PKrOJYnlOe12yekkG0zIyXIO9oMnMnklOqD2MvltMuXO0XZlRbHJzuQOiVfa)rnYy25bLNXTuzSWF00NeXI)CGa36nRAekkG0zLCyWnIflI27y2yQuk2m5tjJqhLBwqjQTXiuuaPZeXIfr7DmBmBuwqH6SnRwMmPIrPJNxwdchZOurrEl4tJSd(rC(RSN1MWoG05Ta4pQrgZopO8mUfKXc)rtFsel(ZbcCR3SQrOOasNvYHb3iwSiAVJzJPsPyZKpLmcDuUzbLO2gJqrbKotelweT3XSXSrzbfQZ2SAzYKkgLoEEzniCmJsff5TGpnYo4hXPTrh2cmHDaPZBzSWF00NeXI)CGa36nRAekkG0zLCyWnrGrgNISZBLsXMIN8P0MTaA)Auwgl8hn9jrS4phiWTEZQgHIciDwjhgCteyKXPi78wPuSzYNsgHok3SGsuBJrOOasNjrGrgNISZ7gLfa)rnYy25bLNXTuzSWF00NeXI)CGa36nRAekkG0zLCyWnrGrgNISZBLsXMjFkze6OCZckrTngHIciDMebgzCkYoVBuwGrOOasNjIflI27y2y2SGmw4pA6tIyXFoqGB9Mvncffq6Ssom4gl1HogbTCLsXMjFkze6OCJYYyH)OPpjIf)5abU1Bw1iuuaPZk5WGBQjEakG3ChIxPuSP4jFkTzlG2VgHvgl8hn9jrS4phiWTEZQgHIciDwjhgCdiIhGc4n3H4vkfBkEYNsB2cO9RzbLLXc)rtFsel(ZbcCR3SQrOOasNvYHb3uPiEakG3ChIxPuSP4jFkTzlG2VMLQSmw4pA6tIyXFoqGB9Mvncffq6Ssom4MlVbEakG3ChIxPuSP4jFkTzlG2VgHvgl8hn9jrS4phiWTEZQgHIciDwjhgCZL3apafWBUdXRuk2m5tjJqhLBwcLO2gJqrbKotU8g4bOaEZDi(gHvqH6SnRwMSPZNk2PouXJ)CmaFt4ygLkkYBzSWF00NeXI)CGa36nRAekkG0zLCyWnxEd8auaV5oeVsPyZKpLmcDuUzbHvjQTXiuuaPZKlVbEakG3ChIVryf8Pr2b)ioTn6WwGjSdiDElJf(JM(Kiw8Nde4wVzvJqrbKoRKddU5YBGhGc4n3H4vkfBM8PKrOJYnliSkrTngHIciDMC5nWdqb8M7q8ncRGp9nk9iq9GZyXk3024jSdiDEla(JAKXSZdkpxzjKXc)rtFsel(ZbcCR3SQrOOasNvYHb3C5nWdqb8M7q8kLInt(uYi0r5MLqzLO2gJqrbKotU8g4bOaEZDi(gHvapNS)mXiDsthNwSixw(pA6Kb1Zsgl8hn9jrS4phiWTEZQgHIciDwjhgCdcuf0Y4b4aw8pLsXMIN8P0MTaA)AeoklJf(JM(Kiw8Nde4wVzvJqrbKoRKddUbbQcAz8aCal(NsPyZKpLmcDuUr4QSsuBJrOOasNjiqvqlJhGdyX)Aeokl4tJSd(rCAB0HTatyhq68wgl8hn9jrS4phiWTEZQgHIciDwjhgCdiIhuNoqh4b4aw8pLsXMIN8P0MTaA)AwcLLXc)rtFsel(ZbcCR3SQrOOasNvYHb3aI4b1Pd0bEaoGf)tPuSzYNsgHok3iSkRe12yekkG0zciIhuNoqh4b4aw8VMLqzbfQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVLXc)rtFsel(ZbcCR3SQrOOasNvYHb3aI4b1Pd0bEaoGf)tPuSzYNsgHok3iSkRe12yekkG0zciIhuNoqh4b4aw8VMLqzbfQZ2SAzsBrN94X0N(DMWXmkvuK3YyH)OPpjIf)5abU1Bw1iuuaPZk5WGBU8g4bOa(JGQLNkLInfp5tPnBb0(1SuzSWF00NeXI)CGa36nRAekkG0zLCyWnqY4lVbEakG)iOA5PsPytXt(uAZwaTFnlvgl8hn9jrS4phiWTEZQgHIciDwjhgCdmWtryOuk2u8KpL2Sfq7xZKVJ6TtcmWtryiJf(JM(Kiw8Nde4wVzvBhMcjJf(JM(Kiw8Nde4wVzvBMBzSWF00NeXI)CGa36nRcOTd2p4OPlJf(JM(Kiw8Nde4wVzvOEWzSfg0ofkzSWF00NeXI)CGa36nRc1doJP(X9o)Nmw4pA6tIyXFoqGB9Mv)0fEaTy8aCa3YdzSWF00NeXI)CGa36nRoDqCgLhEEWnLXc)rtFsel(ZbcCR3S6Gwvwy6aAzzSWF00NeXI)CGa36nRARCEiz)uIABmcffq6mrSyr0EhZgZvAuwgl8hn9jrS4phiWTEZQSX8HJMUsuBJrOOasNjIflI27y2ygNYYyLXc)rtFUEZQFI6hxtrU3vIABoOA5JSzeuRL8W8OElPy4pzSWF00NR3S6d9og(JMoUtNNsom4Mzeu8g)7Pmw4pA6Z1Bw9HEhd)rth3PZtjhgCdpNS)8ugl8hn956nR(qVJH)OPJ705PKddUbswjQTb(JAKXSZdkpJBPYyH)OPpxVz1h6Dm8hnDCNopLCyWnPi7CPe12yekkG0zseyKXPi78ELgLLXc)rtFUEZQp07y4pA64oDEk5WGBGbEkcdLO2gJqrbKotGbEkcJMfKXc)rtFUEZQp07y4pA64oDEk5WGB(m7700NYyH)OPpxVz1h6Dm8hnDCNopLCyWnvEWrtxjQTXiuuaPZel1HogbT8gLLXc)rtFUEZQp07y4pA64oDEk5WGBSuh6ye0YvIABmcffq6mXsDOJrqlVzbzSWF00NR3S6d9og(JMoUtNNsom4MrAKhSFYyLXc)rtFsMrqXB8VNR3Sk6KXdWbClpuIABm8Go7hH9oTn6yN3e2bKoVfmahiI)TsJWxzbdWbI4FX1SKfwduurdJHd6SFe2702OJDEtyhq68wWaCGi(3kncFH1azSWF00NKzeu8g)756nRIozm94XujQTbb1Ajq9GZyX0KlcQOmw4pA6tYmckEJ)9C9MvfZJMUsuBdcQ1sG6bNXIPjxeurzSWF00NKzeu8g)756nRE0bJnHsujQTPqD2MvltoEiMf0XMqjs4ygLkkYBbiOwlHvicqNhnDcQOmw4pA6tYmckEJ)9C9Mv702OBIfEaD3oy)uIABqqTwcup4mwmn5ISttxacQ1skuNXPflMMCr2PPlyZiOwl5s0pcNw8fX4b0sj700LXc)rtFsMrqXB8VNR3Skc0Itl(k6l0ujQTbb1Ajq9GZyX0KlYonDbiOwlPqDgNwSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxgl8hn9jzgbfVX)EUEZQiCn5siQ3Qe12GGATeOEWzSyAYfbvugl8hn9jzgbfVX)EUEZQi9m3ylAfVsuBdcQ1sG6bNXIPjxeurzSWF00NKzeu8g)756nRAPfJ0ZCRe12GGATeOEWzSyAYfbvugl8hn9jzgbfVX)EUEZQG)88kOJFO3vIABqqTwcup4mwmn5IGkkJvgl8hn9jHNt2FEUEZQi9m340IVigZopIxjQT5ZSVttNCj6hHtl(Iy8aAPKIha1Nnklab1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNc(m7700jq9GZyX0KlsXdG6ZvAA)TIkAPTrhU4bq95kFM9DA6eOEWzSyAYfP4bq9Pmw4pA6tcpNS)8C9Mvr6zUXPfFrmMDEeVsuBZNzFNMobQhCglMMCrkEauF2OSadJHd6SFe2702OJDEtyhq68wrfn8Go7hH9oTn6yN3e2bKoVfmahiI)fxJWrzfv0iuuaPZeyGNIWOzbdmqGHg(z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cmeb1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHuurJqrbKotGbEkcJMfmWafv0WpZ(onDYLOFeoT4lIXdOLskEauF2OSaeuRLa1doJ)iOAzY8GxOgLnWabiOwlPqDgNwSyAYfzNMUGb4ar8V4Amcffq6mbeXdQthOd8aCal(Nmw4pA6tcpNS)8C9MvnZQVnYuhx8mDWFwjQT5ZSVttNa1doJfttUifpaQpJRryvwWNzFNMo5s0pcNw8fX4b0sjfpaQpxPP93cqqTwcup4m(JGQLjZdEHwPXiuuaPZKlVbEakG)iOA5PGd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7Vf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXlJf(JM(KWZj7ppxVzvZS6BJm1Xfpth8NvIAB(m7700jxI(r40IVigpGwkP4bq9zJYcqqTwcup4m(JGQLjZdEHwPXiuuaPZKlVbEakG)iOA5PGpZ(onDcup4mwmn5Iu8aO(CLM2FROIwAB0HlEauFUYNzFNMobQhCglMMCrkEauFkJf(JM(KWZj7ppxVzvZS6BJm1Xfpth8NvIAB(m7700jq9GZyX0KlsXdG6ZgLfyymCqN9JWEN2gDSZBc7asN3kQOHh0z)iS3PTrh78MWoG05TGb4ar8V4AeokROIgHIciDMad8uegnlyGbcm0WpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxGHiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKIkAekkG0zcmWtry0SGbgOOIg(z23PPtUe9JWPfFrmEaTusXdG6ZgLfGGATeOEWz8hbvltMh8c1OSbgiab1AjfQZ40IfttUi700fmahiI)fxJrOOasNjGiEqD6aDGhGdyX)KXc)rtFs45K9NNR3SAlkuBk440IHycUYlsjQT5ZSVttNCj6hHtl(Iy8aAPKIha1Nnklab1Ajq9GZ4pcQwMmp4fALgJqrbKotU8g4bOa(JGQLNc(m7700jq9GZyX0KlsXdG6ZvAA)TIkAPTrhU4bq95kFM9DA6eOEWzSyAYfP4bq9Pmw4pA6tcpNS)8C9MvBrHAtbhNwmetWvErkrTnFM9DA6eOEWzSyAYfP4bq9zJYcmmgoOZ(ryVtBJo25nHDaPZBfv0Wd6SFe2702OJDEtyhq68wWaCGi(xCnchLvurJqrbKotGbEkcJMfmWabgA4NzFNMo5s0pcNw8fX4b0sjfpaQpJZiuuaPZeqepafWBUdXlWqeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fsrfncffq6mbg4PimAwWaduurd)m7700jxI(r40IVigpGwkP4bq9zJYcqqTwcup4m(JGQLjZdEHAu2adeGGATKc1zCAXIPjxKDA6cgGdeX)IRXiuuaPZeqepOoDGoWdWbS4FYyH)OPpj8CY(ZZ1Bw9t)z)k44n22HbRuN6m(3nlzLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDbdWbYrhm(s8auiUgwb(rpgF0blJf(JM(KWZj7ppxVz1IbrQ3ITDyWtLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDbdWbYrhm(s8auiUgwb(rpgF0blJf(JM(KWZj7ppxVzvB(OtEJHycUOhJryyOe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlJf(JM(KWZj7ppxVzvr0IAJN6TyKompLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDzSWF00NeEoz)556nRwurXoJPoEkcpRe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlJf(JM(KWZj7ppxVz1lIXOosI6BSnRNvIABqqTwcup4mwmn5ISttxacQ1skuNXPflMMCr2PPlyZiOwl5s0pcNw8fX4b0sj700LXc)rtFs45K9NNR3S6GhzfpoT4o6t34DXWyQe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlJvgl8hn9jjfzNR1Bw1iuuaPZk5WGBIaJmofzN3kLInt(uYi0r5MfuIABel2iU93KfiSX8HJMUmw4pA6tskYoxR3SQLwmgPdZtjQTPqD2Mvlt205tf7uhQ4XFogGVjCmJsff5TaeuRLSPZNk2PouXJ)CmaFJTvopcQOmw4pA6tskYoxR3SQTY5H90iOe12uOoBZQLjTfD2JhtF63zchZOurrElyaoqe)lULKWkJf(JM(KKISZ16nRoOvL1eNw8L1G9tgl8hn9jjfzNR1BwDZWfHKLZYyH)OPpjPi7CTEZQfSPGF4PiucPe12mahiI)fNWvzzSWF00NKuKDUwVz1h8N7y4pA6krTnWF00jZiQ9OElwmn5I8rG7CN6TcA)nP4bq9zJYYyH)OPpjPi7CTEZQZiQ9OElwmn5sjQTzMODeQVjwk3340Ir65CMJjHDaPZBzSWF00NKuKDUwVz1lr)iCAXxeJhqlvgl8hn9jjfzNR1BwfQhCglMMCjJf(JM(KKISZ16nRwOoJtlwmn5sjQTbb1AjfQZ40IfttUi700LXc)rtFssr25A9MvflEY(Z40IhuFlJf(JM(KKISZ16nRc1doJr6W8uIAB25rkytb)WtrOeIu8aO(moHvrf3mcQ1skytb)WtrOecBeT7Cbi0o9INmp4fkoLLXc)rtFssr25A9MvH6bNXiDyEkrTniOwlrS4j7pJtlEq9nbvuWMrqTwYLOFeoT4lIXdOLsqffSzeuRLCj6hHtl(Iy8aAPKIha1NR0a)rtNa1doJr6W8iSc8JEm(Odwgl8hn9jjfzNR1BwfQhCgJavbTSsuBdcQ1sG6bNXIPjxeurbiOwlbQhCglMMCrkEauFUst7VfGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqYyH)OPpjPi7CTEZQq9GZ4bDoPDEQe12SzeuRLCj6hHtl(Iy8aAPeurbh0z)iq9GZy(Jsc7asN3cqqTwYMHlcjlNj700fSzeuRLCj6hHtl(Iy8aAPKIha1NXb)rtNa1doJh05K25jHvGF0JXhDWcmmgGycUOhtG6bNXIOJb3PElHDaPZBfveb1AjFNH6H5r9w8hbUZDYonDdu6JaQ3SGmw4pA6tskYoxR3Skup4mEqNtANNkrTniOwl57mupmpQ3skg(tPpcOEZcYyH)OPpjPi7CTEZQq9GZ4SquIABqqTwcup4m(JGQLjZdEHwPXiuuaPZKlVbEakG)iOA5Pad)m7700jq9GZyX0KlsXdG6Z4wqzfve(JAKXSZdkpxPzPgiJf(JM(KKISZ16nRc1doJr6W8uIABqqTwsH6moTyX0KlcQOIkoahiI)f3ccRmw4pA6tskYoxR3SkBmF4OPRe12GGATKc1zCAXIPjxKDA6kr9JRcv8WuBZaCGi(xCncFHvjQFCvOIhMog8Mch3SGmw4pA6tskYoxR3Skup4mgbQcAzzSYyH)OPpjFM9DA6Z1Bw1w58WEAeuIABkuNTz1YK2Io7XJPp97mHJzuQOiVf8z23PPtG6bNXIPjxKIha1NXTekl4ZSVttNCj6hHtl(Iy8aAPKIha1NnklWqeuRLa1doJ)iOAzY8GxOvAmcffq6m5YBGhGc4pcQwEkWqdpOZ(rkuNXPflMMCryhq68wWNzFNMoPqDgNwSyAYfP4bq95knT)wWNzFNMobQhCglMMCrkEauFgNrOOasNjxEd8auaV5oeVbkQOHXWbD2psH6moTyX0Klc7asN3c(m7700jq9GZyX0KlsXdG6Z4mcffq6m5YBGhGc4n3H4nqrf)m7700jq9GZyX0KlsXdG6ZvAA)TbgimPKulmjmCfnl6rJjyPgDs9wPUTOZE8sn9PFNLAt6fj1GirQfEpzPMEsTj9IK6lVHuNxexM0jtKXc)rtFs(m7700NR3SQTY5H90iOe12uOoBZQLjTfD2JhtF63zchZOurrEl4ZSVttNa1doJfttUifpaQpBuwGHXWbD2pc7DAB0XoVjSdiDEROIgEqN9JWEN2gDSZBc7asN3cgGdeX)IRr4OSbgiWqd)m7700jxI(r40IVigpGwkP4bq9zClOSaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fYafv0WpZ(onDYLOFeoT4lIXdOLskEauF2OSaeuRLa1doJ)iOAzY8GxOgLnWabiOwlPqDgNwSyAYfzNMUGb4ar8V4Amcffq6mbeXdQthOd8aCal(Nmw4pA6tYNzFNM(C9MvTvopKSFkrTnfQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVf8z23PPtqqTw8MoFQyN6qfp(ZXa8nPyyhVaeuRLSPZNk2PouXJ)CmaFJTvopYonDbgIGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPBGGpZ(onDYLOFeoT4lIXdOLskEauF2OSadrqTwcup4m(JGQLjZdEHwPXiuuaPZKlVbEakG)iOA5Padn8Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(BbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8gOOIggdh0z)ifQZ40IfttUiSdiDEl4ZSVttNa1doJfttUifpaQpJZiuuaPZKlVbEakG3ChI3afv8ZSVttNa1doJfttUifpaQpxPP93gyGmw4pA6tYNzFNM(C9MvT0IXiDyEkrTnfQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVf8z23PPtqqTw8MoFQyN6qfp(ZXa8nPyyhVaeuRLSPZNk2PouXJ)CmaFJT0Ij700fiwSrC7VjlqSvopKSFYyH)OPpjFM9DA6Z1BwDqRkRjoT4lRb7NsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpBuwacQ1sG6bNXFeuTmzEWl0kngHIciDMC5nWdqb8hbvlpf8z23PPtG6bNXIPjxKIha1NR00(BHjLKAHjHbDti(PuJozPEqRkRPuBsViPgejsTWlRuF5nKA6uQlg2Xl1WuQn5ExjPEacXs9eTyP(sP(H5j10tQryBwSuF5niYyH)OPpjFM9DA6Z1BwDqRkRjoT4lRb7NsuBZNzFNMobQhCglMMCrkEauF2OSadJHd6SFe2702OJDEtyhq68wrfn8Go7hH9oTn6yN3e2bKoVfmahiI)fxJWrzdmqGHg(z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88Gxiduurd)m7700jxI(r40IVigpGwkP4bq9zJYcqqTwcup4m(JGQLjZdEHAu2adeGGATKc1zCAXIPjxKDA6cgGdeX)IRXiuuaPZeqepOoDGoWdWbS4FYyH)OPpjFM9DA6Z1BwDZWfHKLZkrTnFM9DA6Klr)iCAXxeJhqlLu8aO(SrzbiOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VfMusQfMeg0nH4Nsn6KL6ndxeswol1M0lsQbrIul8Yk1xEdPMoL6IHD8snmLAtU3vsQhGqSuprlwQVuQFyEsn9KAe2Mfl1xEdImw4pA6tYNzFNM(C9Mv3mCriz5SsuBZNzFNMobQhCglMMCrkEauF2OSadJHd6SFe2702OJDEtyhq68wrfn8Go7hH9oTn6yN3e2bKoVfmahiI)fxJWrzdmqGHg(z23PPtUe9JWPfFrmEaTusXdG6Z4wqzbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKbkQOHFM9DA6Klr)iCAXxeJhqlLu8aO(SrzbiOwlbQhCg)rq1YK5bVqnkBGbcqqTwsH6moTyX0KlYonDbdWbI4FX1yekkG0zciIhuNoqh4b4aw8pzSWF00NKpZ(on956nRwWMc(HNIqjKsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpJZiuuaPZKAIhGc4n3H4f8z23PPtG6bNXIPjxKIha1NXzekkG0zsnXdqb8M7q8cm8Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(Bfv8Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NXzekkG0zsnXdqb8M7q8kQymCqN9JuOoJtlwmn5IWoG05TbcqqTwcup4m(JGQLjZdEHIBPc2mcQ1sUe9JWPfFrmEaTuYonDHjLKAHjH3twQNIqjKutTs9L3qQbFl1GOudfl1Pl1)wQbFl1MPhJNuJWsnQOuBZsQ7P3YLuFrGl1xel1dqbPEZDiELK6bie1BL6jAXsTjl1rGrwQHtQ7mmpP(mtPgQhCwQ)iOA5Pud(wQVi4K6lVHuBctpgpPw4b05j1OtEtKXc)rtFs(m7700NR3SAbBk4hEkcLqkrTnFM9DA6Klr)iCAXxeJhqlLu8aO(SrzbiOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VfMusQfMeEpzPEkcLqsTj9IKAquQnJyxQfZ5KI0zIul8Yk1xEdPMoL6IHD8snmLAtU3vsQhGqSuprlwQVuQFyEsn9KAe2Mfl1xEdImw4pA6tYNzFNM(C9Mvlytb)WtrOesjQT5ZSVttNa1doJfttUifpaQpBuwGHggdh0z)iS3PTrh78MWoG05TIkA4bD2pc7DAB0XoVjSdiDElyaoqe)lUgHJYgyGadn8ZSVttNCj6hHtl(Iy8aAPKIha1NXzekkG0zciIhGc4n3H4fGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqgOOIg(z23PPtUe9JWPfFrmEaTusXdG6ZgLfGGATeOEWz8hbvltMh8c1OSbgiab1AjfQZ40IfttUi700fmahiI)fxJrOOasNjGiEqD6aDGhGdyX)mqgl8hn9j5ZSVttFUEZQxI(r40IVigpGwQsuBZNzFNMobQhCglMMCrkEauFUIWQSaEoz)zIr6KMooTyrUS8F00jdQNLmw4pA6tYNzFNM(C9MvVe9JWPfFrmEaTuLO2geuRLa1doJ)iOAzY8GxOvAmcffq6m5YBGhGc4pcQwEk4Go7hPqDgNwSyAYfHDaPZBbFM9DA6Kc1zCAXIPjxKIha1NR00(BbFM9DA6eOEWzSyAYfP4bq9zCgHIciDMC5nWdqb8M7q8c(0i7GFeHIVOGtyhq68wWNzFNMoPGnf8dpfHsisXdG6ZvAe(ctkj1ctX0eFrbxyuQfEpzP(YBi1uRudIsnDk1Pl1)wQbFl1MPhJNuJWsnQOuBZsQ7P3YLuFrGl1xel1dqbPEZDiEIulmOtBDP2KErsDLIsn1k1xel1h0z)KA6uQpqi2jsTWWN9Tudsnc9K6lL6biel1t0ILAtwQFWLAHhvLA6yWBkCCpEPgShxs9L3qQzFpLXc)rtFs(m7700NR3S6LOFeoT4lIXdOLQe12GGATeOEWz8hbvltMh8cTsJrOOasNjxEd8aua)rq1Ytbh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(CLM2Fl4ZSVttNa1doJfttUifpaQpJZiuuaPZKlVbEakG3ChIxqm8Pr2b)icfFrbNWoG05TWKssTW0YPl8SyAIVOGlmk1cVNSuF5nKAQvQbrPMoL60L6Fl1GVLAZ0JXtQryPgvuQTzj190B5sQViWL6lIL6bOGuV5oeprQfg0PTUuBsViPUsrPMAL6lIL6d6SFsnDk1hie7ezSWF00NKpZ(on956nREj6hHtl(Iy8aAPkrTniOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uqmCqN9JuOoJtlwmn5IWoG05TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEzSWF00NKpZ(on956nREj6hHtl(Iy8aAPkrTniOwlbQhCg)rq1YK5bVqR0yekkG0zYL3apafWFeuT8uWNzFNMobQhCglMMCrkEauFUst7VLXc)rtFs(m7700NR3Skup4mwmn5sjQTXWy4Go7hH9oTn6yN3e2bKoVvurdpOZ(ryVtBJo25nHDaPZBbdWbI4FX1iCu2ade8z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxibiOwlPqDgNwSyAYfzNMUGb4ar8V4Amcffq6mbeXdQthOd8aCal(NWKssTWKW7jl1GOutTs9L3qQPtPoDP(3sn4BP2m9y8KAewQrfLABwsDp9wUK6lcCP(IyPEaki1BUdXRKupaHOERuprlwQVi4KAtwQJaJSuZEI2gj1dWbPg8TuFrWj1xexSutNsTNNud9IHD8sni1fQZsDALAX0KlPENMorgl8hn9j5ZSVttFUEZQfQZ40IfttUuIABqqTwsH6moTyX0KlYonDbFM9DA6Klr)iCAXxeJhqlLu8aO(moJqrbKotQuepafWBUdXlab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHey4NzFNMobQhCglMMCrkEauFg3ccRIkUzeuRLCj6hHtl(Iy8aAPeurdeMusQfMeEpzPUsrPMAL6lVHutNsD6s9VLAW3sTz6X4j1iSuJkk12SK6E6TCj1xe4s9fXs9auqQ3ChIxjPEacr9wPEIwSuFrCXsnD6X4j1qVyyhVudsDH6SuVttxQbFl1xeCsnik1MPhJNuJWFoyPgmc0oG0zPEJwuVvQluNjYyH)OPpjFM9DA6Z1BwvS4j7pJtlEq9TsuBdcQ1sG6bNXFeuTmzEWluJYc(0i7GFeHIVOGtyhq68wysjPwykMM4lk4cJsTWJQsnDk1dWbPoc1BR4LAW3sTWG1eUtPgkwQVmLAwbr2NuJSuFPuJozPwmhs9Ls9mMrzoMGLAWLAwHRaPgqKAQl1xel1xEdP2K670Ki1XK8fJtPgDYsn9K6lL6biel190uQ)iOAzPwyWAtPM6Zd8JiJf(JM(K8z23PPpxVzvXINS)moT4b13krTnBgb1AjxI(r40IVigpGwkbvuqm8Pr2b)icfFrbNWoG05TWKssTW0YPl8SyAIVOGlmk1cVNSulMdP(sPEgZOmhtWsn4snRWvGudisn1L6lIL6lVHuBs9DAsKXkJf(JM(Ku5bhn91BwfQhCgJavbTSsuBZNzFNMo5s0pcNw8fX4b0sjfpaQpBuwGHiOwlbQhCg)rq1YK5bVqXzekkG0zYL3apafWFeuT8uWbD2psH6moTyX0Klc7asN3c(m7700jfQZ40IfttUifpaQpxPP93c(m7700jq9GZyX0KlsXdG6Z4mcffq6m5YBGhGc4n3H4f8Pr2b)icfFrbNWoG05TGpZ(onDsbBk4hEkcLqKIha1NR0i8nqgl8hn9jPYdoA6R3Skup4mgbQcAzLO2MpZ(onDYLOFeoT4lIXdOLskEauF2OSadrqTwcup4m(JGQLjZdEHIZiuuaPZKlVbEakG)iOA5PGd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7Vf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXlig(0i7GFeHIVOGtyhq682azSWF00NKkp4OPVEZQq9GZyeOkOLvIAB(m7700jxI(r40IVigpGwkP4bq9zJYcmeb1Ajq9GZ4pcQwMmp4fkoJqrbKotU8g4bOa(JGQLNcIHd6SFKc1zCAXIPjxe2bKoVf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXBGmw4pA6tsLhC00xVzvOEWzmcuf0YkrTnFM9DA6Klr)iCAXxeJhqlLu8aO(SrzbgIGATeOEWz8hbvltMh8cfNrOOasNjxEd8aua)rq1YtbFM9DA6eOEWzSyAYfP4bq95knT)2azSX0L6LzEl1xk10HyNhSFs98k6Fs9KJzu2FEk1zj1iO0(wQbxQH(XLdh1il1rCXezSX0LA4pA6tsLhC00xVz15v0)WtoMrz)zLO2MnJGATKc2uWp8uekHWgr7oxacTtV4jZdEHA2mcQ1skytb)WtrOecBeT7Cbi0o9INmafWZdEHeGGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxjhgCthMhEkcLq45bVqcJq9GZyKompHrOEWzmcuf0YYyH)OPpjvEWrtF9MvH6bNXiqvqlRe12SzeuRLuWMc(HNIqje2iA35cqOD6fpzEWluZMrqTwsbBk4hEkcLqyJODNlaH2Px8KbOaEEWlKadrqTwcup4mwmn5ISttxrfrqTwcup4mwmn5Iu8aO(CLM2FBGadrqTwsH6moTyX0KlYonDfveb1AjfQZ40IfttUifpaQpxPP93giJf(JM(Ku5bhn91BwfQhCgJ0H5Pe12SZJuWMc(HNIqjeP4bq9zCcRIkUzeuRLuWMc(HNIqje2iA35cqOD6fpzEWluCklJf(JM(Ku5bhn91BwfQhCgJ0H5Pe12GGATeXINS)moT4b13eurbBgb1AjxI(r40IVigpGwkbvuWMrqTwYLOFeoT4lIXdOLskEauFUsd8hnDcup4mgPdZJWkWp6X4JoyzSWF00NKkp4OPVEZQq9GZ4bDoPDEQe12SzeuRLCj6hHtl(Iy8aAPeurbh0z)iq9GZy(Jsc7asN3cqqTwYMHlcjlNj700fy4MrqTwYLOFeoT4lIXdOLskEauFgh8hnDcup4mEqNtANNewb(rpgF0bROIFM9DA6eXINS)moT4b13KIha1NXPSIk(Pr2b)icfFrbNWoG05TbcmmgGycUOhtG6bNXIOJb3PElHDaPZBfveb1AjFNH6H5r9w8hbUZDYonDdu6JaQ3SGmw4pA6tsLhC00xVzvOEWz8GoN0opvIABqqTwY3zOEyEuVLum8NaeuRLWkic(M3yX8y)OqNGkkJf(JM(Ku5bhn91BwfQhCgpOZjTZtLO2geuRL8DgQhMh1Bjfd)jWqeuRLa1doJfttUiOIkQicQ1skuNXPflMMCrqfvuXnJGATKlr)iCAXxeJhqlLu8aO(mo4pA6eOEWz8GoN0opjSc8JEm(Od2aL(iG6nliJf(JM(Ku5bhn91BwfQhCgpOZjTZtLO2geuRL8DgQhMh1Bjfd)jab1AjFNH6H5r9wY8GxOgeuRL8DgQhMh1Bjdqb88GxiL(iG6nliJf(JM(Ku5bhn91BwfQhCgpOZjTZtLO2geuRL8DgQhMh1Bjfd)jab1AjFNH6H5r9wsXdG6ZvAm0qeuRL8DgQhMh1BjZdEHegc(JMobQhCgpOZjTZtcRa)OhJp6Gny92FBGsFeq9MfKXc)rtFsQ8GJM(6nR68fXf(4HippLO2gdl2w8mcq6SIkgdh9fI6Tgiab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHeGGATeOEWzSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxgl8hn9jPYdoA6R3Skup4moleLO2geuRLa1doJ)iOAzY8GxOvAmcffq6m5YBGhGc4pcQwEkJf(JM(Ku5bhn91BwDIkYLNgbLO2Mb4ar8VvAwscRaeuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDzSWF00NKkp4OPVEZQZiQ9OElwmn5sjQTbb1Ajq9GZyX0KlYonDbiOwlPqDgNwSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxWNzFNMoHnMpC00jfpaQpJtzbFM9DA6eOEWzSyAYfP4bq9zCkl4ZSVttNCj6hHtl(Iy8aAPKIha1NXPSadJHd6SFKc1zCAXIPjxe2bKoVvurdpOZ(rkuNXPflMMCryhq68wWNzFNMoPqDgNwSyAYfP4bq9zCkBGbYyH)OPpjvEWrtF9MvH6bNXiDyEkrTniOwlPq7moT4lQyEsqffGGATeOEWz8hbvltMh8cf3siJf(JM(Ku5bhn91BwfQhCgJavbTSsuBZaCGi(3kgHIciDMGavbTmEaoGf)tWNzFNMoHnMpC00jfpaQpJtzbiOwlbQhCglMMCr2PPlab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHeWZj7ptmsN00XPflYLL)JMozq9SKXc)rtFsQ8GJM(6nRc1doJrGQGwwjQT5ZSVttNCj6hHtl(Iy8aAPKIha1NnklWWpZ(onDsH6moTyX0KlsXdG6ZgLvuXpZ(onDcup4mwmn5Iu8aO(SrzdeGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqYyH)OPpjvEWrtF9MvH6bNXiqvqlRe12mahiI)TsJrOOasNjiqvqlJhGdyX)eGGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPlab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHe8z23PPtyJ5dhnDsXdG6Z4uwgl8hn9jPYdoA6R3Skup4mgbQcAzLO2geuRLa1doJfttUi700fGGATKc1zCAXIPjxKDA6c2mcQ1sUe9JWPfFrmEaTuYonDbiOwlbQhCg)rq1YK5bVqniOwlbQhCg)rq1YKbOaEEWlKGd6SFeOEWzCwie2bKoVf8z23PPtG6bNXzHqkEauFUst7VfmahiI)TsZsszbFM9DA6e2y(WrtNu8aO(moLLXc)rtFsQ8GJM(6nRc1doJrGQGwwjQTbb1Ajq9GZyX0KlcQOaeuRLa1doJfttUifpaQpxPP93cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00NKkp4OPVEZQq9GZyeOkOLvIABqqTwsH6moTyX0KlcQOaeuRLuOoJtlwmn5Iu8aO(CLM2Flab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHKXc)rtFsQ8GJM(6nRc1doJrGQGwwjQTbb1Ajq9GZyX0KlYonDbiOwlPqDgNwSyAYfzNMUGnJGATKlr)iCAXxeJhqlLGkkyZiOwl5s0pcNw8fX4b0sjfpaQpxPP93cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00NKkp4OPVEZQq9GZyKompzSWF00NKkp4OPVEZQSX8HJMUsu)4Qqfpm12mahiI)fxJWxyvI6hxfQ4HPJbVPWXnliJf(JM(Ku5bhn91BwfQhCgJavbTSmw4pA6tsLhC00xVzvJqrbKoRKddUXsDOJrqlxPuSzYNsgHok3SGsuBdcQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cjigqqTwsH2zCAXxuX8KGkkWsBJoCXdG6ZvAm0Wb4GWZH)OPtG6bNXiDyEKpNNbcdb)rtNa1doJr6W8iSc8JEm(Od2azSYyH)OPpjwQdDmcA5R3Skup4mEqNtANNkrTniOwl57mupmpQ3skg(tPpcOEZcYyH)OPpjwQdDmcA5R3Skup4mgPdZtgl8hn9jXsDOJrqlF9MvH6bNXiqvqllJvgl8hn9jbsE9MvTvopKSFkrTnfQZ2SAzYMoFQyN6qfp(ZXa8nHJzuQOiVf8z23PPtqqTw8MoFQyN6qfp(ZXa8nPyyhVaeuRLSPZNk2PouXJ)CmaFJTvopYonDbgIGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPBGGpZ(onDYLOFeoT4lIXdOLskEauF2OSadrqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT8uGHgEqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEduurdJHd6SFKc1zCAXIPjxe2bKoVf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXBGIk(z23PPtG6bNXIPjxKIha1NR00(Bdmqgl8hn9jbsE9MvT0IXiDyEkrTngwOoBZQLjB68PIDQdv84phdW3eoMrPII8wWNzFNMobb1AXB68PIDQdv84phdW3KIHD8cqqTwYMoFQyN6qfp(ZXa8n2slMSttxGyXgXT)MSaXw58qY(zGIkAyH6SnRwMSPZNk2PouXJ)CmaFt4ygLkkYBbhDWnkBGmw4pA6tcK86nRARCEypnckrTnfQZ2SAzsBrN94X0N(DMWXmkvuK3c(m7700jq9GZyX0KlsXdG6Z4wcLf8z23PPtUe9JWPfFrmEaTusXdG6ZgLfyicQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNcm0Wd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7Vf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXBGIkAymCqN9JuOoJtlwmn5IWoG05TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEduuXpZ(onDcup4mwmn5Iu8aO(CLM2FBGbYyH)OPpjqYR3SQTY5H90iOe12uOoBZQLjTfD2JhtF63zchZOurrEl4ZSVttNa1doJfttUifpaQpBuwGHgA4NzFNMo5s0pcNw8fX4b0sjfpaQpJZiuuaPZeqepafWBUdXlab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHmqrfn8ZSVttNCj6hHtl(Iy8aAPKIha1Nnklab1Ajq9GZ4pcQwMmp4fALgJqrbKotGKXxEd8aua)rq1YtdmqacQ1skuNXPflMMCr2PPBGmw4pA6tcK86nREj6hHtl(Iy8aAPkrTnfQZ2SAzYKkgLoEEzniCmJsff5TaXInIB)nzbcBmF4OPlJf(JM(KajVEZQq9GZyX0KlLO2Mc1zBwTmzsfJshpVSgeoMrPII8wGHIfBe3(BYce2y(Wrtxrffl2iU93KfixI(r40IVigpGwQbYyH)OPpjqYR3SkBmF4OPRe12C0bh3sOSGc1zBwTmzsfJshpVSgeoMrPII8wacQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNc(m7700jxI(r40IVigpGwkP4bq9zJYc(m7700jq9GZyX0KlsXdG6ZvAA)Tmw4pA6tcK86nRYgZhoA6krTnhDWXTeklOqD2MvltMuXO0XZlRbHJzuQOiVf8z23PPtG6bNXIPjxKIha1NnklWqdn8ZSVttNCj6hHtl(Iy8aAPKIha1NXzekkG0zciIhGc4n3H4fGGATeOEWz8hbvltMh8c1GGATeOEWz8hbvltgGc45bVqgOOIg(z23PPtUe9JWPfFrmEaTusXdG6ZgLfGGATeOEWz8hbvltMh8cTsJrOOasNjqY4lVbEakG)iOA5Pbgiab1AjfQZ40IfttUi700nqjQFCvOIhMABqqTwYKkgLoEEzniZdEHAqqTwYKkgLoEEznidqb88GxiLO(XvHkEy6yWBkCCZcYyH)OPpjqYR3S6GwvwtCAXxwd2pLO2gd)m7700jq9GZyX0KlsXdG6Z4eUcRIk(z23PPtG6bNXIPjxKIha1NR0Segi4ZSVttNCj6hHtl(Iy8aAPKIha1NnklWqeuRLa1doJ)iOAzY8GxOvAmcffq6mbsgF5nWdqb8hbvlpfyOHh0z)ifQZ40IfttUiSdiDEl4ZSVttNuOoJtlwmn5Iu8aO(CLM2Fl4ZSVttNa1doJfttUifpaQpJtynqrfnmgoOZ(rkuNXPflMMCryhq68wWNzFNMobQhCglMMCrkEauFgNWAGIk(z23PPtG6bNXIPjxKIha1NR00(Bdmqgl8hn9jbsE9Mvlytb)WtrOesjQT5ZSVttNCj6hHtl(Iy8aAPKIha1NXzekkG0zsnXdqb8M7q8c(m7700jq9GZyX0KlsXdG6Z4mcffq6mPM4bOaEZDiEbgEqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6ZvAA)TIkEqN9JuOoJtlwmn5IWoG05TGpZ(onDsH6moTyX0KlsXdG6Z4mcffq6mPM4bOaEZDiEfvmgoOZ(rkuNXPflMMCryhq682abiOwlbQhCg)rq1YK5bVqR0yekkG0zcKm(YBGhGc4pcQwEkyZiOwl5s0pcNw8fX4b0sj700LXc)rtFsGKxVz1c2uWp8uekHuIAB(m7700jxI(r40IVigpGwkP4bq9zJYcmeb1Ajq9GZ4pcQwMmp4fALgJqrbKotGKXxEd8aua)rq1YtbgA4bD2psH6moTyX0Klc7asN3c(m7700jfQZ40IfttUifpaQpxPP93c(m7700jq9GZyX0KlsXdG6Z4mcffq6m5YBGhGc4n3H4nqrfnmgoOZ(rkuNXPflMMCryhq68wWNzFNMobQhCglMMCrkEauFgNrOOasNjxEd8auaV5oeVbkQ4NzFNMobQhCglMMCrkEauFUst7VnWazSWF00Nei51BwTGnf8dpfHsiLO2MpZ(onDcup4mwmn5Iu8aO(SrzbgAOHFM9DA6Klr)iCAXxeJhqlLu8aO(moJqrbKotar8auaV5oeVaeuRLa1doJ)iOAzY8GxOgeuRLa1doJ)iOAzYauapp4fYafv0WpZ(onDYLOFeoT4lIXdOLskEauF2OSaeuRLa1doJ)iOAzY8GxOvAmcffq6mbsgF5nWdqb8hbvlpnWabiOwlPqDgNwSyAYfzNMUbYyH)OPpjqYR3S6MHlcjlNvIAB(m7700jq9GZyX0KlsXdG6ZgLfyOHg(z23PPtUe9JWPfFrmEaTusXdG6Z4mcffq6mbeXdqb8M7q8cqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88Gxiduurd)m7700jxI(r40IVigpGwkP4bq9zJYcqqTwcup4m(JGQLjZdEHwPXiuuaPZeiz8L3apafWFeuT80adeGGATKc1zCAXIPjxKDA6giJf(JM(KajVEZQxI(r40IVigpGwQsuBdcQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNcm0Wd6SFKc1zCAXIPjxe2bKoVf8z23PPtkuNXPflMMCrkEauFUst7Vf8z23PPtG6bNXIPjxKIha1NXzekkG0zYL3apafWBUdXBGIkAymCqN9JuOoJtlwmn5IWoG05TGpZ(onDcup4mwmn5Iu8aO(moJqrbKotU8g4bOaEZDiEduuXpZ(onDcup4mwmn5Iu8aO(CLM2FBGmw4pA6tcK86nRc1doJfttUuIABm0WpZ(onDYLOFeoT4lIXdOLskEauFgNrOOasNjGiEakG3ChIxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8czGIkA4NzFNMo5s0pcNw8fX4b0sjfpaQpBuwacQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNgyGaeuRLuOoJtlwmn5ISttxgl8hn9jbsE9MvluNXPflMMCPe12GGATKc1zCAXIPjxKDA6cm0WpZ(onDYLOFeoT4lIXdOLskEauFg3svwacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8czGIkA4NzFNMo5s0pcNw8fX4b0sjfpaQpBuwacQ1sG6bNXFeuTmzEWl0kngHIciDMajJV8g4bOa(JGQLNgyGad)m7700jq9GZyX0KlsXdG6Z4wqyvuXnJGATKlr)iCAXxeJhqlLGkAGmw4pA6tcK86nRkw8K9NXPfpO(wjQTbb1AjBgUiKSCMGkkyZiOwl5s0pcNw8fX4b0sjOIc2mcQ1sUe9JWPfFrmEaTusXdG6ZvAqqTwIyXt2FgNw8G6BYauapp4fsyi4pA6eOEWzmshMhHvGF0JXhDWYyH)OPpjqYR3Skup4mgPdZtjQTbb1AjBgUiKSCMGkkWqdpOZ(rkEMo4ptyhq68wa8h1iJzNhuEUIW1afve(JAKXSZdkpxrynqgl8hn9jbsE9MvNOIC5Prqgl8hn9jbsE9MvH6bNXzHOe12GGATeOEWz8hbvltMh8c1OSmw4pA6tcK86nR68fXf(4HippLO2gdl2w8mcq6SIkgdh9fI6Tgiab1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHKXc)rtFsGKxVz1ze1EuVflMMCPe12GGATeOEWzSyAYfzNMUaeuRLuOoJtlwmn5ISttxWMrqTwYLOFeoT4lIXdOLs2PPl4ZSVttNa1doJfttUifpaQpJtzbFM9DA6Klr)iCAXxeJhqlLu8aO(moLfyymCqN9JuOoJtlwmn5IWoG05TIkA4bD2psH6moTyX0Klc7asN3c(m7700jfQZ40IfttUifpaQpJtzdmqgl8hn9jbsE9MvH6bNXd6Cs78ujQTbb1AjFNH6H5r9wsXWFckuNTz1YeOEWzm1TuNEXt4ygLkkYBbh0z)iWqStT0hoA6e2bKoVfa)rnYy25bLNRSKKXc)rtFsGKxVzvOEWz8GoN0opvIABqqTwY3zOEyEuVLum8NGc1zBwTmbQhCgtDl1Px8eoMrPII8wa8h1iJzNhuEUYswgl8hn9jbsE9MvH6bNXScI9CstxjQTbb1Ajq9GZ4pcQwMmp4fAfeuRLa1doJ)iOAzYauapp4fsgl8hn9jbsE9MvH6bNXScI9CstxjQTbb1Ajq9GZ4pcQwMmp4fQbb1Ajq9GZ4pcQwMmafWZdEHeiwSrC7VjlqG6bNXiqvqllJf(JM(KajVEZQq9GZyeOkOLvIABqqTwcup4m(JGQLjZdEHAqqTwcup4m(JGQLjdqb88GxizSWF00Nei51BwLnMpC00vI6hxfQ4HP2Mb4ar8V4Ae(cRsu)4QqfpmDm4nfoUzbzSYyH)OPpjWapfHrtH6moTyX0KlLO2geuRLuOoJtlwmn5ISttxWNzFNMobQhCglMMCrkEauFgNYYyH)OPpjWapfHX6nREj6hHtl(Iy8aAPkrTng(z23PPtG6bNXIPjxKIha1Nnklab1AjfQZ40IfttUi700nqrffl2iU93KfifQZ40IfttUKXc)rtFsGbEkcJ1Bw9s0pcNw8fX4b0svIAB(m7700jq9GZyX0KlsXdG6ZvewLfGGATKc1zCAXIPjxKDA6c45K9NjgPtA640If5YY)rtNWoG05Tmw4pA6tcmWtrySEZQq9GZyX0KlLO2geuRLuOoJtlwmn5ISttxWNzFNMo5s0pcNw8fX4b0sjfpaQpJZiuuaPZeqepafWBUdXlJf(JM(Kad8uegR3Skup4mgbQcAzLO2geuRLa1doJfttUiOIcqqTwcup4mwmn5Iu8aO(CLg4pA6eOEWz8GoN0opjSc8JEm(OdwacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cjJf(JM(Kad8uegR3Skup4moleLO2geuRLa1doJ)iOAzY8GxOvqqTwcup4m(JGQLjdqb88GxibiOwlPqDgNwSyAYfzNMUaeuRLa1doJfttUi700fSzeuRLCj6hHtl(Iy8aAPKDA6YyH)OPpjWapfHX6nRc1doJrGQGwwjQTbb1AjfQZ40IfttUi700fGGATeOEWzSyAYfzNMUGnJGATKlr)iCAXxeJhqlLSttxacQ1sG6bNXFeuTmzEWludcQ1sG6bNXFeuTmzakGNh8cjJf(JM(Kad8uegR3Skup4mEqNtANNkrTniOwl57mupmpQ3skg(tPpcOEZcYyH)OPpjWapfHX6nRc1doJh05K25PsuBtmaXeCrpMa1doJfrhdUt9wc7asN3kQicQ1s(od1dZJ6T4pcCN7KDA6k9ra1Bwqgl8hn9jbg4PimwVz1h8N7y4pA6krTnWF00jSX8HJMo5Ja35o1BfmahiI)fxZssyLXc)rtFsGbEkcJ1BwLnMpC00LXc)rtFsGbEkcJ1BwfQhCgNfIsuBdcQ1sG6bNXFeuTmzEWl0kiOwlbQhCg)rq1YKbOaEEWlKmw4pA6tcmWtrySEZQq9GZyeOkOLLXc)rtFsGbEkcJ1BwfQhCgJ0H5jJvgl8hn9jzKg5b736nRI0PUqyWJxjQTzKg5b7hztNh4phxZcklJf(JM(KmsJ8G9B9MvflEY(Z40IhuFlJf(JM(KmsJ8G9B9MvH6bNXd6Cs78ujQTzKg5b7hztNh4pVYcklJf(JM(KmsJ8G9B9MvH6bNXzHiJf(JM(KmsJ8G9B9MvT0IXiDyEHlCHa]] )


end
