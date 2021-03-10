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
            duration = 12,
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


        -- Legendaries
        grisly_icicle = {
            id = 348007,
            duration = 8,
            max_stack = 1
        }
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
            if arcane_charges.current == 0 then
                removeBuff( "arcane_charge" )
            else
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end

        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then
                removeBuff( "arcane_charge" )
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
        if active_enemies > 2 or variable.prepull_evo == 1 or settings.am_spam == 1 then
            return 1
        end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then
            return 1
        end
        -- TODO:  Review this to make sure it holds up in longer fights.
        if state.combat > 0 and action.evocation.lastCast >= state.combat and not ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            return 1
        end
        if buff.arcane_power.down and ( action.arcane_power.lastCast >= state.combat or cooldown.arcane_power.remains > 0 ) and ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            return 1 end
        return 0
    end )


    spec:RegisterStateExpr( "tick_reduction", function ()
        return action.shifting_power.cdr / 4
    end )

    spec:RegisterStateExpr( "full_reduction", function ()
        return action.shifting_power.cdr
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
                gain( 1, "arcane_charges" )
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

            tick_time = function ()
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
            end,

            tick = function () if legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 1 ) end end,

            auras = {
                arcane_harmony = {
                    id = 332777,
                    duration = 3600,
                    max_stack = 18
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
                if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
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
                if legendary.triune_ward.enabled then
                    applyBuff( "blazing_barrier" )
                    applyBuff( "ice_barrier" )
                end
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
            cast = function () return 4 * haste end,
            channeled = true,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3636841,

            toggle = "essences",

            -- -action.shifting_power.execute_time%action.shifting_power.new_tick_time*(dbc.effect.815503.base_value%1000+conduit.discipline_of_the_grove.time_value)
            cdr = function ()
                return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
            end,

            full_reduction = function ()
                return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
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
                    duration = function () return 4 * haste end,
                    tick_time = function () return haste end,
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

        potion = "spectral_intellect",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20210310, [[dW0MdgqikqEeLsLlPIOI2eP0NOGgfjYPirTkkGYRuHmlku3IcOYUi8lvuggOQogPOLrPWZOuutJcGRPIW2ureFtfinokfX5OuKwhLsAEQGUhOSpqvoiLszHQO6HuG6IuaQpQIOsJufrvNufrALuiZKsjUjfq2Pks)KcOQHQculvfr5Pu0uvH6QuaYxvbcJvfWELYFjAWahg1IjPhd1KvvxgzZI8zr1OfLtdz1QiQWRjbZgKBRs7MQFlmCs1XPuQA5sEUunDfxxv2oLQVtjJhu58KcRxfiA(Kq7xPBA2oUz(5HANAd4BdnHVnRj8fAAtG)bvtBsZC0qNAM6mwboNAMoFPMPTvy2PMPoRbuW)2XnZE8km1mZMrVBRNDwoAYEQcCCpRJUpiEqHJlonN1rx8znt1hcAoPEtTz(5HANAd4BdnHVnRj8fAAtG)j5eNOz21jC70tInAMzO)N8MAZ8tDCZ0aX50cSTcZoTgzG4cNTanHVXlWgW3gAUgTgDYOByNwGDUqSkej4RSRZ3fG8fKy7rTGiTGondYZ7c(k768DbkHZiSclqJ4vlORt4fe6dk8UYI1idOoTGrdDeMHwGj6AWliJ9peYZxqKwaoJDNGwaYhQQN(GcFbiVpe)xqKwGHy2XeKKXdkCdfntiuF6TJBMzCDdxJ2XTt1SDCZKCwfI(TZBMmEqH3mj7bMhu4nZp1XfsFqH3mnG60cmGThyEqHVauAbwKHfTaOWAbHVGl78cy)VaEbhhJb6mB7GxGfY)H1cq9fGJlYZxWtVzIl0qfIBMx2zHoEwWHWwGMNybAxaocOFy5IjE4mzKKtgjVCosu0LrEFbhcBbkTacoc)gsoOlTGJwaJhu4IjE4mzKKtgjVCosqWr43qYbDPfO8c0UaCeq)WYfCHzNK6HfvIIUmY7l4qylqPfqWr43qYbDPfC0cy8GcxmXdNjJKCYi5LZrccoc)gsoOlTGJwaJhu4cUWSts9WIkbbhHFdjh0LwGYlq7cuFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hw(c0UadAb)yef)rSpYUoxkik6YiV3M2P2ODCZKCwfI(TZBMmEqH3mj7bMhu4nZp1XfsFqH3mnG60cmGThyEqHVauAbwKHfTaOWAbHVGl78cy)VaEbNS4GxGfY)H1cq9fGJlYZxWtVzIl0qfIBMx2zHoEwWHWwGnd)fODb4iG(HLlQNtYij1dlQefDzK3xWHWwGslGGJWVHKd6sl4OfW4bfUOEojJKupSOsqWr43qYbDPfO8c0UaCeq)WYft8WzYijNmsE5CKOOlJ8(coe2cuAbeCe(nKCqxAbhTagpOWf1ZjzKK6Hfvccoc)gsoOlTGJwaJhu4II)i2hzxNlfeeCe(nKCqxAbkVaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cmaWVnTtT52XntYzvi63oVz(PoUq6dk8M55pe0FbN8CDdxJf0hgRqFbPOwWKrl44ymqNzBh8cSq(pSAM4cnuH4MP6lLeCHzNKzCDdxdrFyScl4WfO(sjbxy2jzgx3W1qCz4K9HXkSaTlahb0pSCrXFe7JSRZLcIIUmY7l4qylqPfyJfC0cuAbeCe(nKCqxAbhTagpOWff)rSpYUoxkii4i8Bi5GU0cuEbkVaTlahb0pSCXepCMmsYjJKxohjk6YiVVGdHTaLwGnwWrlqPfqWr43qYbDPfC0cy8Gcxu8hX(i76CPGGGJWVHKd6sl4OfW4bfUyIhotgj5KrYlNJeeCe(nKCqxAbkVaLxG2fGJa6hwUGlm7KupSOsu0LrEFbhcBbkTaBSGJwGslGGJWVHKd6sl4OfW4bfUO4pI9r215sbbbhHFdjh0LwWrlGXdkCXepCMmsYjJKxohji4i8Bi5GU0coAbmEqHl4cZoj1dlQeeCe(nKCqxAbkVaLBM4mg5ntnBMmEqH3m5cZojVOEhbr920o1a0oUzsoRcr)25nZp1XfsFqH3mp)HG(l4KNRB4ASG(Wyf6lif1cMmAbNS4GxGfY)HvZexOHke3mvFPKGlm7KmJRB4Ai6dJvybhUa1xkj4cZojZ46gUgIldNSpmwHfODb4iG(HLlQNtYij1dlQefDzK3xWHWwGslWgl4OfO0ci4i8Bi5GU0coAbmEqHlQNtYij1dlQeeCe(nKCqxAbkVaLxG2fGJa6hwUO4pI9r215sbrrxg59fCiSfO0cSXcoAbkTacoc)gsoOlTGJwaJhu4I65Kmss9WIkbbhHFdjh0LwWrlGXdkCrXFe7JSRZLcccoc)gsoOlTaLxGYlq7cWra9dlxmXdNjJKCYi5LZrIIUmY7l4qylqPfyJfC0cuAbeCe(nKCqxAbhTagpOWf1ZjzKK6Hfvccoc)gsoOlTGJwaJhu4II)i2hzxNlfeeCe(nKCqxAbhTagpOWft8WzYijNmsE5CKGGJWVHKd6slq5fO8c0UaCeq)WYfCHzNK6HfvIIUmY7ntCgJ8MPMntgpOWBMCHzNKxuVJGOEBANEI2XntYzvi63oVz(PoUq6dk8M55pe0FbN8CDdxJf0hgRqFbPOwWKrlWzfO)cozMlWc5)WQzIl0qfIBMQVusWfMDsMX1nCne9HXkSGdxG6lLeCHzNKzCDdxdXLHt2hgRWc0UaCeq)WYff)rSpYUoxkik6YiVVGdHTaLwGnwWrlqPfqWr43qYbDPfC0cy8Gcxu8hX(i76CPGGGJWVHKd6slq5fO8c0UaCeq)WYfCHzNK6HfvIIUmY7laEWwGnd)fODb4iG(HLlQNtYij1dlQefDzK3xa8GTaBg(ntCgJ8MPMntgpOWBMCHzNKxuVJGOEBANEsAh3mjNvHOF78MjUqdviUzQ(sjbxy2jzgx3W1q0hgRWcGTa1xkj4cZojZ46gUgIldNSpmwHfODb4iG(HLlM4HZKrsozK8Y5irrxg59fC4ci4i8Bi5GU0c0UaCeq)WYfCHzNK6HfvIIUmY7l4qylqPfqWr43qYbDPfC0cy8GcxmXdNjJKCYi5LZrccoc)gsoOlTaLxG2fCzNf64zbWBbAEIMjJhu4nZI)i2hzxNlfAt70dA74Mj5Ske9BN3mXfAOcXnt1xkj4cZojZ46gUgI(WyfwaSfO(sjbxy2jzgx3W1qCz4K9HXkSaTlahb0pSCbxy2jPEyrLOOlJ8(coe2ci4i8Bi5GU0c0UGFmII)i2hzxNlfefDzK3BMmEqH3mN4HZKrsozK8Y5O20o1M0oUzsoRcr)25ntCHgQqCZu9LscUWStYmUUHRHOpmwHfaBbQVusWfMDsMX1nCnexgozFySclq7c(K6lLet8WzYijNmsE5CK4PVaTlq9LsI65Kmss9WIkXpS8MjJhu4ntUWSts9WIQ20o1M2oUzsoRcr)25ntCHgQqCZu9LscUWStYmUUHRHOpmwHfaBbQVusWfMDsMX1nCnexgozFySclq7cWra9dlxmXdNjJKCYi5LZrIIUmY7l4qylqPfqWr43qYbDPfC0cy8Gcxu8hX(i76CPGGGJWVHKd6slq5fODb4iG(HLl4cZoj1dlQefDzK3xa8wGba(lq7cUSZcD8Sa4bBb28jAMmEqH3mRNtYij1dlQAt7unHF74Mj5Ske9BN3mXfAOcXnt1xkj4cZojZ46gUgI(WyfwaSfO(sjbxy2jzgx3W1qCz4K9HXkSaTlahb0pSCXepCMmsYjJKxohjk6YiVVGdxabhHFdjh0LwG2fO(sjr9CsgjPEyrL4P3mz8GcVzw8hX(i76CPqBANQPMTJBMKZQq0VDEZexOHke3mvFPKGlm7KmJRB4Ai6dJvybWwG6lLeCHzNKzCDdxdXLHt2hgRWc0UaCeq)WYfCHzNK6HfvIIUmY7laElWaa)fODbQVusupNKrsQhwujE6lq7c(Xik(JyFKDDUuqu0LrEVzY4bfEZCIhotgj5KrYlNJAt7unTr74Mj5Ske9BN3mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(cG3c0e(lq7cWra9dlxWfMDsQhwujk6YiVVa4TaBg(lq7cuFPKGlm7KupSOs8dlVzY4bfEZSEojJKupSOQnTt10MBh3mjNvHOF78MjUqdviUzQ(sjbxy2jzgx3W1q0hgRWcGTa1xkj4cZojZ46gUgIldNSpmwHfODb4iG(HLl4cZoj1dlQefDzK3xa8GTaBCIfODb4iG(HLlQNtYij1dlQefDzK3xa8GTaBCIfODbQVusWfMDsMX1nCne9HXkSaylq9LscUWStYmUUHRH4YWj7dJvybAxWLDwOJNfapylqZt0mz8GcVzw8hX(i76CPqBANQPbODCZKCwfI(TZBMmEqH3m1lQtoMKrsEr(Vz(PoUq6dk8MPbuNwWbhgOf8FfYZxGTDWliQfCYIdEbwi)hw9fmXcuFiO)cWzCLt9fWPHQf86ipFb2wHzNwW5CvCo1mXfAOcXnt1xkj4cZojXzCLtI(WyfwWHlq9LscUWStsCgx5K4YWj7dJvybAxG6lLeCHzNK4mUYjrFySclaEla(lq7cuFPKGlm7KupSOsu0LrEFbkQ4cuFPKGlm7KeNXvoj6dJvybhUa1xkj4cZojXzCLtIldNSpmwHfODbQVusWfMDsIZ4kNe9HXkSa4Ta4VaTlq9LsI65Kmss9WIkrrxg59fODbFs9LsIjE4mzKKtgjVCosu0LrEVnTt18eTJBMKZQq0VDEZexOHke3mvFPKqVOo5ysgj5f5FXtVzY4bfEZKlm7KufI7tBANQ5jPDCZKCwfI(TZBM4cnuH4MP6lLeCHzNK4mUYjrFyScl4WfyJfODbQVusWfMDsQhwujE6ntgpOWBMCHzNKrP2M2PAEqBh3mjNvHOF78MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcoCb2ybAxGbTaLwaocOFy5cUWSts9WIkrrxg59fCiSfOj8xG2fGJa6hwUyIhotgj5KrYlNJefDzK3xWHWwGMWFbAxaocOFy5II)i2hzxNlfefDzK3xWHWwWjwGYntgpOWBMCHzNKrP2M2PAAtAh3mjNvHOF78MjJhu4ntUWStYlQ3rquVzIZyK3m1SzIl0qfIBMQVusWfMDsIZ4kNe9HXkSa4TanxG2fO(sjbxy2jzgx3W1q0hgRWcoCbQVusWfMDsMX1nCnexgozFyScTPDQM202XntYzvi63oVzY4bfEZKlm7K8I6Dee1BM4mg5ntnBM4cnuH4MjocOFy5cUWStYOuffDzK3xWHlWaSaTlq9LscUWStYmUUHRHOpmwHfC4cuFPKGlm7KmJRB4AiUmCY(WyfAt7uBa)2XntYzvi63oVzIl0qfIBMFs9LsII)i2hzxNlfK2FqovSkccnAi6dJvybWwGbOzY4bfEZKlm7KuLRIZP20o1gA2oUzsoRcr)25ntCHgQqCZ8hJO4pI9r215sbrrxg59fODbFs9LsIjE4mzKKtgjVCosu0LrEFbWBbeCe(nKCqxAbAxGsl4tQVusu8hX(i76CPG0(dYPIvrqOrdrFyScla2cG)cuuXf8j1xkjk(JyFKDDUuqA)b5uXQii0OHOpmwHfC4cmalq5MjJhu4ntUWStsviUpTPDQnSr74Mj5Ske9BN3mXfAOcXnZFmII)i2hzxNlfefDzK3xa8wWjwG2f8j1xkjk(JyFKDDUuqA)b5uXQii0OHOpmwHfaBbWFbAxG6lLe1ZjzKK6HfvIFy5ntgpOWBMCHzNKrP2M2P2WMBh3mjNvHOF78MjUqdviUz(Jru8hX(i76CPGOOlJ8(cG3ci4i8Bi5GU0c0UGpP(sjrXFe7JSRZLcs7piNkwfbHgne9HXkSa4Ta4VaTl4tQVusu8hX(i76CPG0(dYPIvrqOrdrFyScl4WfyawG2fO(sjr9CsgjPEyrL4hwEZKXdk8Mjxy2jPke3N20o1ggG2XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YWj7dJvybAxG6lLeCHzNKzCDdxdrFyScla2cuFPKGlm7KmJRB4AiUmCY(WyfAMmEqH3m5cZojv5Q4CQnTtTXjAh3mjNvHOF78MjUqdviUzEzNf64zbhUanprZKXdk8MjzpW8GcVnTtTXjPDCZKCwfI(TZBMmEqH3m5cZojvH4(0m)uhxi9bfEZ8GiJ8fOsJfr(cWra9dlFbwi)hwDJxGfTGWH0ybQpe0FbtSG0dcAb4mUYP(c40q1cEDKNVaBRWStlWaFP2mXfAOcXnt1xkj4cZojXzCLtI(Wyfwa8wGMTPDQnoOTJBMKZQq0VDEZKXdk8Mjxy2jPkxfNtnZp1XfsFqH3mpP3l9r8qqASGUo5)fCYZ1nCnwqFySc9fyLr(cuPXIiFb4iG(HLValK)dREZexOHke3mvFPKGlm7KmJRB4Ai6dJvybWBbWFbAxGbTaLwaocOFy5cUWSts9WIkrrxg59fCiSfOj8xG2fGJa6hwUyIhotgj5KrYlNJefDzK3xWHWwGMWFbAxaocOFy5II)i2hzxNlfefDzK3xWHWwWjwGYTPDQnSjTJBMKZQq0VDEZeNXiVzQzZKXdk8Mjxy2j5f17iiQ3M20mtOEgYZLHo5u1oUDQMTJBMKZQq0VDEZKXdk8MjzpW8GcVz(PoUq6dk8M5brg5lOEUJ88fqOjJQfmz0cmnxqul44dIfar5K)5crDJxGfTal2NfmXcmGThlqLsrrlyYOfCCmgOZSTdEbwi)hwIfya1PfGMfW9f0JWxa3xWjlo4fKX9fKqoQNr)feVAbwKH2Pf01jFwq8QfGZ4kN6ntCHgQqCZuPfupNsrLtIosplCzFI6kiNvHO)cuuXfupNsrLtIHU6rXqslU0fKZQq0FbkVaTlqPfO(sjr9CsgjPEyrL4hw(cuuXfOxKDzo(l0uWfMDsQYvX50cuEbAxaocOFy5I65Kmss9WIkrrxg5920o1gTJBMKZQq0VDEZKXdk8MjzpW8GcVz(PoUq6dk8M5jnTalYq70csih1ZO)cIxTaCeq)WYxGfY)HvFbS)xqxN8zbXRwaoJRCQB8c0luuObDqslWa2ESGWovlGStLgtgYZxab1PMjUqdviUzome5JOEojJKupSOsqoRcr)fODb4iG(HLlQNtYij1dlQefDzK3xG2fGJa6hwUGlm7KupSOsu0LrEFbAxG6lLeCHzNK6HfvIFy5lq7cuFPKOEojJKupSOs8dlFbAxGEr2L54Vqtbxy2jPkxfNtTPDQn3oUzsoRcr)25ntCHgQqCZSEoLIkNeFuhJ0HqoxAiXX9Y(xqoRcr)fODbQVus8rDmshc5CPHeh3l7FzQI(iE6ntgpOWBMjursviUpTPDQbODCZKCwfI(TZBM4cnuH4Mz9CkfvojYluhsdjcJWqKGCwfI(lq7cUSZcD8Sa4TaB6jAMmEqH3mtv0hPh2520o9eTJBMKZQq0VDEZexOHke3mnOfupNsrLtIosplCzFI6kiNvHOFZKXdk8M5N4jtnkNAt70ts74Mj5Ske9BN3mXfAOcXntCeq)WYf1ZjzKK6HfvII4VgntgpOWBMCHzNKrP2M2Ph02XntYzvi63oVzIl0qfIBM4iG(HLlQNtYij1dlQefXFnwG2fO(sjbxy2jjoJRCs0hgRWcoCbQVusWfMDsIZ4kNexgozFyScntgpOWBMCHzNKQqCFAt7uBs74MjJhu4nZ65Kmss9WIQMj5Ske9BN3M2P202XntYzvi63oVzY4bfEZKlm7K8I6Dee1BMFQJlK(GcVzEstlWImSOfWZcUmClOpmwH(cI0cmydEbS)xGfTGm2o5gol41P)cmqXXlqdAmEbVoTaEb9HXkSGjwGEr2jFwW954mKN3mXfAOcXnt1xkjWqexyUpipxueJNfODbQVusGHiUWCFqEUOpmwHfaBbQVusGHiUWCFqEU4YWj7dJvybAxaoSto7JWo5tMg1c0UaCeq)WYfxuvr1LrsorDjFefXFnAt7unHF74Mj5Ske9BN3mXfAOcXntdAbkTG65ukQCs0r6zHl7tuxb5Ske9xGIkUG65ukQCsm0vpkgsAXLUGCwfI(lq5M5N64cPpOWBMNg1LHG0ybw0c0zuTa9yqHVGxNwGfAYwGTDWgVa13Sa0Salee0cG4(SaOWZxa5XlpBbPOwGAmzlyYOfCYIdEbS)xGTDWlWc5)WQVGNdr9(cQN7ipFbtgTatZfe1co(Gybquo5FUquVzY4bfEZupgu4TPDQMA2oUzsoRcr)25ntCHgQqCZu9LsI65Kmss9WIkXpS8fOOIlqVi7YC8xOPGlm7KuLRIZPMjJhu4nZpXtMAuo1M2PAAJ2XntYzvi63oVzIl0qfIBMQVusupNKrsQhwuj(HLVafvCb6fzxMJ)cnfCHzNKQCvCo1mz8GcVzw8hX(i76CPqBANQPn3oUzsoRcr)25ntCHgQqCZu9LsI65Kmss9WIkXpS8fOOIlqVi7YC8xOPGlm7KuLRIZPMjJhu4nZlQQO6YijNOUKpTPDQMgG2XntYzvi63oVzIl0qfIBM6fzxMJ)cnft8WzYijNmsE5CuZKXdk8Mjxy2jPEyrvBANQ5jAh3mjNvHOF78MjJhu4nt9I6KJjzKKxK)BMFQJlK(GcVzAa1PfCWHbAbtSGUT)r0bjTa2xab3u8cSTcZoTGZH4(SG)RqE(cMmAbhhJb6mB7GxGfY)H1cEoe17lOEUJ88fyBfMDAbgW4SqSGtAAb2wHzNwGbmolwaQVGHHiFOVXlWIwaMDdNf860co4WaTal0KH8fmz0coogd0z22bValK)dRf8CiQ3xGfTaKpuvp9zbtgTaBZaTaCg7obz8c6XcSidHGwqNTtlanIMjUqdviUzAqlyyiYhbxy2jjHZcb5Ske9xG2f8j1xkjM4HZKrsozK8Y5iXtFbAxWNuFPKyIhotgj5KrYlNJefDzK3xWHWwGslGXdkCbxy2jPke3hbbhHFdjh0LwGb2cuFPKqVOo5ysgj5f5FXLHt2hgRWcuUnTt18K0oUzsoRcr)25ntgpOWBM6f1jhtYijVi)3m)uhxi9bfEZ8KMwWbhgOfKXD3WzbQe5l41P)c(Vc55lyYOfCCmgOfyH8Fyz8cSidHGwWRtlanlyIf0T9pIoiPfW(ci4MIxGTvy2PfCoe3NfG8fmz0cozXbFMTDWlWc5)Ws0mXfAOcXnt1xkj4cZoj1dlQep9fODbQVusupNKrsQhwujk6YiVVGdHTaLwaJhu4cUWStsviUpccoc)gsoOlTadSfO(sjHErDYXKmsYlY)IldNSpmwHfOCBANQ5bTDCZKCwfI(TZBM4cnuH4M5pgrXFe7JSRZLcIIUmY7laEl4elqrfxWNuFPKO4pI9r215sbP9hKtfRIGqJgI(Wyfwa8wa8BMmEqH3m5cZojvH4(0M2PAAtAh3mjNvHOF78MjJhu4ntUWStsvUkoNAMFQJlK(GcVzEqqlWI9zbtSGlRaTG(ROfyrliJTtlG84LNTGl78csrTGjJwa5dQOfyBh8cSq(pSmEbKDYxakTGjJkYW(c6dccAbd6slOOlJCKNVGWxWjloyXcoPJH9feoKglqLMHQfmXcuFLVGjwWbjvXcy)Vady7XcqPfup3rE(cMmAbMMliQfC8bXcGOCY)CHOUOzIl0qfIBM4iG(HLl4cZoj1dlQefXFnwG2fCzNf64zbhUaLwGba(l4OfO0c0e(lWaBb4Wo5Spcf0OqSVaLxGYlq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLHt2hgRWc0UadAb1ZPuu5KOJ0Zcx2NOUcYzvi6VaTlWGwq9Ckfvojg6QhfdjT4sxqoRcr)20ovtBA74Mj5Ske9BN3mz8GcVzYfMDsQYvX5uZ8tDCH0hu4ntdihI69fup3rE(cMmAb2wHzNwWjpx3W1ybquo5FU0W4fCoxfNtlONfpO)c8ywGkTGxN(lGNfmz0ci)VGiTaB7GxakTady7bMhu4la1xqKslahb0pS8fW9f8Rqxh55laNXvo1xGfccAbxwbAbOzbdRaTaOWZPAbtSa1x5lyYQ4LNTGIUmYrE(cUSZntCHgQqCZu9LscUWSts9WIkXtFbAxG6lLeCHzNK6HfvIIUmY7l4qylih)xG2fO0cQNtPOYjbxy2jjYtihnAiiNvHO)cuuXfGJa6hwUGShyEqHlk6YiVVaLBt7uBa)2XntYzvi63oVzY4bfEZKlm7KuLRIZPM5N64cPpOWBMNZvX50c6zXd6VagYI1OVavAbtgTaiUplaZ9zbiFbtgTGtwCWlWc5)WAbCFbhhJbAbwiiOfuuFIIwWKrlaNXvo1xqxN8PzIl0qfIBMQVusupNKrsQhwujE6lq7cuFPKGlm7KupSOs8dlFbAxG6lLe1ZjzKK6HfvIIUmY7l4qylih)Bt7uBOz74Mj5Ske9BN3mXzmYBMA2mjUG0qIZyKlrPMP6lLeyiIlm3hKNlXzS7eK4hwUwLuFPKGlm7KupSOs80vurLmOHHiFeHDQ0dlQOVwLuFPKOEojJKupSOs80vurCeq)WYfK9aZdkCrr8xdLvw5MjUqdviUz(j1xkjM4HZKrsozK8Y5iXtFbAxWWqKpcUWStscNfcYzvi6VaTlqPfO(sjXN4jtnkNe)WYxGIkUagpi7KKC6IO(cGTanxGYlq7c(K6lLet8WzYijNmsE5CKOOlJ8(cG3cy8GcxWfMDsEr9ocI6ccoc)gsoOl1mz8GcVzYfMDsEr9ocI6TPDQnSr74Mj5Ske9BN3m)uhxi9bfEZ0aVdPXc6dxZcEDKNVad2GxGTzGwGvg5lW2o4fKX9fOsKVGxN(ntCHgQqCZu9LscmeXfM7dYZffX4zbAxaocOFy5cUWSts9WIkrrxg59fODbkTa1xkjQNtYij1dlQep9fOOIlq9LscUWSts9WIkXtFbk3mXzmYBMA2mz8GcVzYfMDsEr9ocI6TPDQnS52XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLxgojoJRCQ3mz8GcVzYfMDsgLABANAddq74Mj5Ske9BN3mXfAOcXnt1xkjQNtYij1dlQep9fOOIl4Yol0XZcG3c08entgpOWBMCHzNKQqCFAt7uBCI2XntYzvi63oVzY4bfEZKShyEqH3mr(qv90hjk1mVSZcD8apy2Kt0mr(qv90hj6EPpIhQzQzZexOHke3mvFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5TPDQnojTJBMmEqH3m5cZojv5Q4CQzsoRcr)25TPnnZpL4h00oUDQMTJBMmEqH3mXXZhQ66eeuZKCwfI(TZBt7uB0oUzsoRcr)25nZqVz2PPzY4bfEZ0oxiwfIAM2zOh1m1SzIl0qfIBM25cXQqKiJTtYqNC6Vayla(lq7c0lYUmh)fAki7bMhu4lq7cmOfO0cQNtPOYjrhPNfUSprDfKZQq0FbkQ4cQNtPOYjXqx9OyiPfx6cYzvi6VaLBM25s68LAMzSDsg6Kt)20o1MBh3mjNvHOF78MzO3m700mz8GcVzANleRcrnt7m0JAMA2mXfAOcXnt7CHyvisKX2jzOto9xaSfa)fODbQVusWfMDsQhwuj(HLVaTlahb0pSCbxy2jPEyrLOOlJ8(c0UaLwq9Ckfvoj6i9SWL9jQRGCwfI(lqrfxq9Ckfvojg6QhfdjT4sxqoRcr)fOCZ0oxsNVuZmJTtYqNC63M2PgG2XntYzvi63oVzg6nZonntgpOWBM25cXQquZ0od9OMPMntCHgQqCZu9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq7cmOfO(sjr9GizKKtwrux80xG2fOg9(c0UGekpBKfDzK3xWHWwGslqPfCzNxWzlGXdkCbxy2jPke3hbo6ZcuEbgylGXdkCbxy2jPke3hbbhHFdjh0LwGYnt7CjD(snZeYziP6R820o9eTJBMKZQq0VDEZexOHke3mvAbddr(iihcLNnKtFb5Ske9xG2fCzNf64zbhcBb2e4VaTl4Yol0XZcGhSfCsoXcuEbkQ4cuAbg0cggI8rqoekpBiN(cYzvi6VaTl4Yol0XZcoe2cSjNybk3mz8GcVzEzNL50TnTtpjTJBMKZQq0VDEZexOHke3mvFPKGlm7KupSOs80BMmEqH3m1JbfEBANEqBh3mjNvHOF78MjUqdviUzwpNsrLtIHU6rXqslU0fKZQq0FbAxG6lLeeCz8RpOWfp9fODbkTaCeq)WYfCHzNK6HfvII4VglqrfxGA07lq7csO8Srw0LrEFbhcBbga4VaLBMmEqH3mh0LKwCP3M2P2K2XntYzvi63oVzIl0qfIBMQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkXpS8fODbFs9LsIjE4mzKKtgjVCos8dlVzY4bfEZecLNnD5jhVF(L8PnTtTPTJBMKZQq0VDEZexOHke3mvFPKGlm7KupSOs8dlFbAxG6lLe1ZjzKK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hwEZKXdk8MPkNlJKCkewHEBANQj8Bh3mjNvHOF78MjUqdviUzQ(sjbxy2jPEyrL4P3mz8GcVzQsvNkfqEEBANQPMTJBMKZQq0VDEZexOHke3mvFPKGlm7KupSOs80BMmEqH3mvHI4ltVsJ20ovtB0oUzsoRcr)25ntCHgQqCZu9LscUWSts9WIkXtVzY4bfEZmHksfkIFBANQPn3oUzsoRcr)25ntCHgQqCZu9LscUWSts9WIkXtVzY4bfEZKDm1NIHKygcQnTt10a0oUzsoRcr)25ntCHgQqCZu9LscUWSts9WIkXtVzY4bfEZ81jjAOBVnTt18eTJBMKZQq0VDEZKXdk8Mzoe)r8evxQY)CQzIl0qfIBMQVusWfMDsQhwujE6lqrfxaocOFy5cUWSts9WIkrrxg59fapyl4eNybAxWNuFPKyIhotgj5KrYlNJep9MjLseEKoFPMzoe)r8evxQY)CQnTt18K0oUzsoRcr)25ntgpOWBM0vxJIyizuFNDm1mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7l4qylWgWVz68LAM0vxJIyizuFNDm1M2PAEqBh3mjNvHOF78MjJhu4nZFr8pHksAN6DcQzIl0qfIBM4iG(HLl4cZoj1dlQefDzK3xa8GTaBa)fOOIlWGwGDUqSkejyDz4YxNwaSfO5cuuXfO0cg0LwaSfa)fODb25cXQqKiH6zipxg6Kt1cGTanxG2fupNsrLtIosplCzFI6kiNvHO)cuUz68LAM)I4FcvK0o17euBANQPnPDCZKCwfI(TZBMmEqH3m7XdsIYD0qvZexOHke3mXra9dlxWfMDsQhwujk6YiVVa4bBb2m8xGIkUadAb25cXQqKG1LHlFDAbWwGMntNVuZShpijk3rdvTPDQM202XntYzvi63oVzY4bfEZmhsd9mzKKCVJUiiEqH3mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7laEWwGnG)cuuXfyqlWoxiwfIeSUmC5Rtla2c0CbkQ4cuAbd6sla2cG)c0Ua7CHyvisKq9mKNldDYPAbWwGMlq7cQNtPOYjrhPNfUSprDfKZQq0Fbk3mD(snZCin0ZKrsY9o6IG4bfEBANAd43oUzsoRcr)25ntgpOWBMxgZQfj7zenY7RJWntCHgQqCZehb0pSCbxy2jPEyrLOOlJ8(coe2coXc0UaLwGbTa7CHyvisKq9mKNldDYPAbWwGMlqrfxWGU0cG3cSz4VaLBMoFPM5LXSArYEgrJ8(6iCBANAdnBh3mjNvHOF78MjJhu4nZlJz1IK9mIg591r4MjUqdviUzIJa6hwUGlm7KupSOsu0LrEFbhcBbNybAxGDUqSkejsOEgYZLHo5uTaylqZfODbQVusupNKrsQhwujE6lq7cuFPKOEojJKupSOsu0LrEFbhcBbkTanH)cmWTGtSadSfupNsrLtIosplCzFI6kiNvHO)cuEbAxWGU0coCb2m8BMoFPM5LXSArYEgrJ8(6iCBANAdB0oUzsoRcr)25ntCHgQqCZKXdYojjNUiQVa4TaB0m7tHWt7unBMmEqH3mXmeKKXdkCjeQpntiuFKoFPMjhuBANAdBUDCZKCwfI(TZBM4cnuH4MjoSto7Jqbnke7lq7cQNtPOYjbxy2jjYtihnAiiNvHO)c0UGHHiFe1ZjzKK6HfvcYzvi6VaTlWGwao8)dncUWSts9k(OCneKZQq0Vz2NcHN2PA2mz8GcVzIziijJhu4siuFAMqO(iD(snZmUUHRrBANAddq74Mj5Ske9BN3m)uhxi9bfEZ84mAbjupd55li0jNQfOs5iVVal0KTGtwCWlG9)csOEg1xqkQfyWg8c0Ra3xWel41Pf8FfYZxWXXyGoZ2o4MjJhu4ntmdbjz8GcxcH6tZSpfcpTt1SzIl0qfIBM25cXQqKiJTtYqNC6Vayla(lq7cSZfIvHirc1ZqEUm0jNQMjeQpsNVuZmH6zipxg6KtvBANAJt0oUzsoRcr)25ntCHgQqCZ0oxiwfIezSDsg6Kt)faBbWVz2NcHN2PA2mz8GcVzIziijJhu4siuFAMqO(iD(snZqNCQAt7uBCsAh3mjNvHOF78MjUqdviUz2PzqEExWxzxNVla2c0Sz2NcHN2PA2mz8GcVzIziijJhu4siuFAMqO(iD(snt(k768TnTtTXbTDCZKCwfI(TZBMmEqH3mXmeKKXdkCjeQpntiuFKoFPMjocOFy5920o1g2K2XntYzvi63oVzIl0qfIBM25cXQqKiHCgsQ(kFbWwa8BM9Pq4PDQMntgpOWBMygcsY4bfUec1NMjeQpsNVuZSIHhu4TPDQnSPTJBMKZQq0VDEZexOHke3mTZfIvHirc5mKu9v(cGTanBM9Pq4PDQMntgpOWBMygcsY4bfUec1NMjeQpsNVuZmHCgsQ(kVnTtTz43oUzsoRcr)25ntgpOWBMygcsY4bfUec1NMjeQpsNVuZ8g2Pl5tBAtZSIHhu4TJBNQz74Mj5Ske9BN3mz8GcVzs2dmpOWBMFQJlK(GcVzY4bfExuXWdk8JGDgMDmbjz8Gc3yucgJhu4cYEG5bfUaNXUtqipx7LDwOJh4bZMEcTkzq1ZPuu5KOJ0Zcx2NOUkQO6lLeDKEw4Y(e1v0hgRam1xkj6i9SWL9jQR4YWj7dJvq5MjUqdviUzEzNf64zbhcBb25cXQqKGShsD8SaTlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xWHWwaJhu4cYEG5bfUGGJWVHKd6slqrfxaocOFy5cUWSts9WIkrrxg59fCiSfW4bfUGShyEqHli4i8Bi5GU0cuuXfO0cggI8rupNKrsQhwujiNvHO)c0UaCeq)WYf1ZjzKK6HfvIIUmY7l4qylGXdkCbzpW8GcxqWr43qYbDPfO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq7cuFPKGlm7KupSOs8dlFbAxWNuFPKyIhotgj5KrYlNJe)WYxG2fyqlqVi7YC8xOPyIhotgj5KrYlNJAt7uB0oUzsoRcr)25ntCHgQqCZSEoLIkNeDKEw4Y(e1vqoRcr)fODb4iG(HLl4cZoj1dlQefDzK3xWHWwaJhu4cYEG5bfUGGJWVHKd6sntgpOWBMK9aZdk820o1MBh3mjNvHOF78MjJhu4ntUWStsvUkoNAMFQJlK(GcVzEoxfNtlaLwaAmSVGbDPfmXcEDAbtm3fW(Fbw0cYy70cMiwWLDnwaoJRCQ3mXfAOcXntCeq)WYft8WzYijNmsE5CKOi(RXc0UaLwG6lLeCHzNK4mUYjrFySclaElWoxiwfIetmx5LHtIZ4kN6lq7cWra9dlxWfMDsQhwujk6YiVVGdHTacoc)gsoOlTaTl4Yol0XZcG3cSZfIvHibRlVihDFx5LDwQJNfODbQVusupNKrsQhwuj(HLVaLBt7udq74Mj5Ske9BN3mXfAOcXntCeq)WYft8WzYijNmsE5CKOi(RXc0UaLwG6lLeCHzNK4mUYjrFySclaElWoxiwfIetmx5LHtIZ4kN6lq7cggI8rupNKrsQhwujiNvHO)c0UaCeq)WYf1ZjzKK6HfvIIUmY7l4qylGGJWVHKd6slq7cWra9dlxWfMDsQhwujk6YiVVa4Ta7CHyvismXCLxgo5NGynKPOKS(cuUzY4bfEZKlm7KuLRIZP20o9eTJBMKZQq0VDEZexOHke3mXra9dlxmXdNjJKCYi5LZrII4Vglq7cuAbQVusWfMDsIZ4kNe9HXkSa4Ta7CHyvismXCLxgojoJRCQVaTlqPfyqlyyiYhr9CsgjPEyrLGCwfI(lqrfxaocOFy5I65Kmss9WIkrrxg59faVfyNleRcrIjMR8YWj)eeRHmfLSc9fO8c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5LHt(jiwdzkkjRVaLBMmEqH3m5cZojv5Q4CQnTtpjTJBMKZQq0VDEZexOHke3m)K6lLef)rSpYUoxkiT)GCQyveeA0q0hgRWcGTGpP(sjrXFe7JSRZLcs7piNkwfbHgnexgozFySclq7cuAbQVusWfMDsQhwuj(HLVafvCbQVusWfMDsQhwujk6YiVVGdHTGC8FbkVaTlqPfO(sjr9CsgjPEyrL4hw(cuuXfO(sjr9CsgjPEyrLOOlJ8(coe2cYX)fOCZKXdk8Mjxy2jPkxfNtTPD6bTDCZKCwfI(TZBM4cnuH4M5pgrXFe7JSRZLcIIUmY7laElWMSafvCbkTGpP(sjrXFe7JSRZLcs7piNkwfbHgne9HXkSa4Ta4VaTl4tQVusu8hX(i76CPG0(dYPIvrqOrdrFyScl4Wf8j1xkjk(JyFKDDUuqA)b5uXQii0OH4YWj7dJvybk3mz8GcVzYfMDsQcX9PnTtTjTJBMKZQq0VDEZexOHke3mvFPKqVOo5ysgj5f5FXtFbAxWNuFPKyIhotgj5KrYlNJep9fODbFs9LsIjE4mzKKtgjVCosu0LrEFbhcBbmEqHl4cZojvH4(ii4i8Bi5GUuZKXdk8Mjxy2jPke3N20o1M2oUzsoRcr)25ntCgJ8MPMntIlinK4mg5suQzQ(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvujdAyiYhryNk9WIk6Rvj1xkjQNtYij1dlQepDfvehb0pSCbzpW8Gcxue)1qzLvUzIl0qfIBMFs9LsIjE4mzKKtgjVCos80xG2fmme5JGlm7KKWzHGCwfI(lq7cuAbQVus8jEYuJYjXpS8fOOIlGXdYojjNUiQVaylqZfO8c0UaLwWNuFPKyIhotgj5KrYlNJefDzK3xa8waJhu4cUWStYlQ3rquxqWr43qYbDPfOOIlahb0pSCHErDYXKmsYlY)IIUmY7lqrfxaoSto7Jqbnke7lq5MjJhu4ntUWStYlQ3rquVnTt1e(TJBMKZQq0VDEZexOHke3mvFPKadrCH5(G8CrrmEwG2fO(sjbbNo7F6l1JH8bXqINEZKXdk8Mjxy2j5f17iiQ3M2PAQz74Mj5Ske9BN3mz8GcVzYfMDsEr9ocI6ntCgJ8MPMntCHgQqCZu9LscmeXfM7dYZffX4zbAxGslq9LscUWSts9WIkXtFbkQ4cuFPKOEojJKupSOs80xGIkUGpP(sjXepCMmsYjJKxohjk6YiVVa4TagpOWfCHzNKxuVJGOUGGJWVHKd6slq520ovtB0oUzsoRcr)25ntgpOWBMCHzNKxuVJGOEZeNXiVzQzZexOHke3mvFPKadrCH5(G8CrrmEwG2fO(sjbgI4cZ9b55I(WyfwaSfO(sjbgI4cZ9b55IldNSpmwH20ovtBUDCZKCwfI(TZBMmEqH3m5cZojVOEhbr9MjoJrEZuZMjUqdviUzQ(sjbgI4cZ9b55IIy8SaTlq9LscmeXfM7dYZffDzK3xWHWwGslqPfO(sjbgI4cZ9b55I(WyfwGb2cy8GcxWfMDsEr9ocI6ccoc)gsoOlTaLxWrlih)xGYTPDQMgG2XntYzvi63oVzIl0qfIBMkTGIsf1ZyviAbkQ4cmOfmiScipFbkVaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq7cuFPKGlm7KupSOs8dlFbAxWNuFPKyIhotgj5KrYlNJe)WYBMmEqH3mDAYOso0vN6tBANQ5jAh3mjNvHOF78MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcoe2cSZfIvHiXeZvEz4K4mUYPEZKXdk8Mjxy2jzuQTPDQMNK2XntYzvi63oVzIl0qfIBMx2zHoEwWHWwGn9elq7cuFPKGlm7KupSOs8dlFbAxG6lLe1ZjzKK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hwEZKXdk8Mz)PtLh2520ovZdA74Mj5Ske9BN3mXfAOcXnt1xkjQhejJKCYkI6IN(c0Ua1xkj4cZojXzCLtI(Wyfwa8wGn3mz8GcVzYfMDsQcX9PnTt10M0oUzsoRcr)25ntCHgQqCZ8Yol0XZcoe2cSZfIvHiHkxfNtYl7Suhplq7cuFPKGlm7KupSOs8dlFbAxG6lLe1ZjzKK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hw(c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsCz4K9HXkSaTlahb0pSCbzpW8Gcxu0LrEVzY4bfEZKlm7KuLRIZP20ovtBA74Mj5Ske9BN3mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrL4hw(c0UGpP(sjXepCMmsYjJKxohj(HLVaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq7cggI8rWfMDsgLQGCwfI(lq7cWra9dlxWfMDsgLQOOlJ8(coe2cYX)fODbx2zHoEwWHWwGnf(lq7cWra9dlxq2dmpOWffDzK3BMmEqH3m5cZojv5Q4CQnTtTb8Bh3mjNvHOF78MjUqdviUzQ(sjbxy2jPEyrL4PVaTlq9LscUWSts9WIkrrxg59fCiSfKJ)lq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLHt2hgRWc0UaLwaocOFy5cYEG5bfUOOlJ8(cuuXfupNsrLtcUWStsKNqoA0qqoRcr)fOCZKXdk8Mjxy2jPkxfNtTPDQn0SDCZKCwfI(TZBM4cnuH4MP6lLe1ZjzKK6HfvIN(c0Ua1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrLOOlJ8(coe2cYX)fODbQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YWj7dJvybAxGslahb0pSCbzpW8Gcxu0LrEFbkQ4cQNtPOYjbxy2jjYtihnAiiNvHO)cuUzY4bfEZKlm7KuLRIZP20o1g2ODCZKCwfI(TZBM4cnuH4MP6lLeCHzNK6HfvIFy5lq7cuFPKOEojJKupSOs8dlFbAxWNuFPKyIhotgj5KrYlNJep9fODbFs9LsIjE4mzKKtgjVCosu0LrEFbhcBb54)c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsCz4K9HXk0mz8GcVzYfMDsQYvX5uBANAdBUDCZKCwfI(TZBM4cnuH4M5WvonImIHMmHoEwWHlWMpXc0Ua1xkj4cZojXzCLtI(Wyfwa8GTaLwaJhKDssoDruFbg4wGMlq5fODb1ZPuu5KGlm7KunUQC9VKpcYzvi6VaTlGXdYojjNUiQVa4TanxG2fO(sjXN4jtnkNe)WYBMmEqH3m5cZojv5Q4CQnTtTHbODCZKCwfI(TZBM4cnuH4M5WvonImIHMmHoEwWHlWMpXc0Ua1xkj4cZojXzCLtI(WyfwWHlq9LscUWStsCgx5K4YWj7dJvybAxq9Ckfvoj4cZojvJRkx)l5JGCwfI(lq7cy8GStsYPlI6laElqZfODbQVus8jEYuJYjXpS8MjJhu4ntUWStscoDOOJcVnTtTXjAh3mz8GcVzYfMDsQcX9PzsoRcr)25TPDQnojTJBMKZQq0VDEZexOHke3mvFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hwEZKXdk8MjzpW8GcVnTtTXbTDCZKXdk8Mjxy2jPkxfNtntYzvi63oVnTPzIJa6hwEVDC7unBh3mjNvHOF78MjJhu4nZuf9r6HDUz(PoUq6dk8M5bxOOqd6GKwWRJ88fKxOoKglaHryiAbwOjBbSUybgqDAbOzbwOjBbtm3fetgvwOojAM4cnuH4Mz9CkfvojYluhsdjcJWqKGCwfI(lq7cWra9dlxWfMDsQhwujk6YiVVa4TaBg(lq7cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0UaLwG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIetmx5LHtIZ4kN6lq7cuAbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cYX)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYldN8tqSgYuuswFbkVafvCbkTadAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5cUWSts9WIkrrxg59faVfyNleRcrIjMR8YWj)eeRHmfLK1xGYlqrfxaocOFy5cUWSts9WIkrrxg59fCiSfKJ)lq5fOCBANAJ2XntYzvi63oVzIl0qfIBM1ZPuu5KiVqDinKimcdrcYzvi6VaTlahb0pSCbxy2jPEyrLOOlJ8(cGTa4VaTlqPfyqlyyiYhb5qO8SHC6liNvHO)cuuXfO0cggI8rqoekpBiN(cYzvi6VaTl4Yol0XZcGhSfCqH)cuEbkVaTlqPfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7laElqt4VaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSayla(lq5fO8c0Ua1xkjQNtYij1dlQe)WYxG2fCzNf64zbWd2cSZfIvHibRlVihDFx5LDwQJNMjJhu4nZuf9r6HDUnTtT52XntYzvi63oVzIl0qfIBM1ZPuu5K4J6yKoeY5sdjoUx2)cYzvi6VaTlahb0pSCH6lLKFuhJ0HqoxAiXX9Y(xue)1ybAxG6lLeFuhJ0HqoxAiXX9Y(xMQOpIFy5lq7cuAbQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkXpS8fODbFs9LsIjE4mzKKtgjVCos8dlFbkVaTlahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq7cuAbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLxgojoJRCQVaTlqPfO0cggI8rupNKrsQhwujiNvHO)c0UaCeq)WYf1ZjzKK6HfvIIUmY7l4qylih)xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb25cXQqKyI5kVmCYpbXAitrjz9fO8cuuXfO0cmOfmme5JOEojJKupSOsqoRcr)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYldN8tqSgYuuswFbkVafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwqo(VaLxGYntgpOWBMPk6JAanTPDQbODCZKCwfI(TZBM4cnuH4Mz9Ckfvoj(OogPdHCU0qIJ7L9VGCwfI(lq7cWra9dlxO(sj5h1XiDiKZLgsCCVS)ffXFnwG2fO(sjXh1XiDiKZLgsCCVS)LjurIFy5lq7c0lYUmh)fAksv0h1aAAMmEqH3mtOIKQqCFAt70t0oUzsoRcr)25ntgpOWBMxuvr1LrsorDjFAMFQJlK(GcVzEWmQwGbkoEbwOjBb22bVauAbOXW(cWXf55l4PVGEeUybN00cqZcSqqqlqLwWRt)fyHMSfCCmgiJxaM7ZcqZc6qO8SbsJfOsPOOMjUqdviUzIJa6hwUyIhotgj5KrYlNJefDzK3xWHlWoxiwfIe3yK6fHj6lNyUsvnwGIkUaLwaocOFy5cUWSts9WIkrrxg59faVfyNleRcrIBmYldN8tqSgYuuswFbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqK4gJ8YWj)eeRHmfLCI5UaLBt70ts74Mj5Ske9BN3mXfAOcXntCeq)WYfCHzNK6HfvII4Vglq7cuAbg0cggI8rqoekpBiN(cYzvi6VafvCbkTGHHiFeKdHYZgYPVGCwfI(lq7cUSZcD8Sa4bBbhu4VaLxGYlq7cuAbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cG3cSZfIvHibRlVmCYpbXAitrjNyUlq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLHt2hgRWcuEbkQ4cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faBbWFbAxG6lLeCHzNK4mUYjrFyScla2cG)cuEbkVaTlq9LsI65Kmss9WIkXpS8fODbx2zHoEwa8GTa7CHyvisW6YlYr33vEzNL64PzY4bfEZ8IQkQUmsYjQl5tBANEqBh3mjNvHOF78MjJhu4nZpXtMAuo1m)uhxi9bfEZ02GSyn6l41Pf8jEYuJYPfyHMSfW6IfCstlyI5UauFbfXFnwa3xGfbbz8cUSc0c6VIwWelaZ9zbOzbQukkAbtmxrZexOHke3mXra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwWHWwGDUqSkejMyUYldNeNXvo1xG2fGJa6hwUGlm7KupSOsu0LrEFbhcBb54FBANAtAh3mjNvHOF78MjUqdviUzIJa6hwUGlm7KupSOsu0LrEFbWwa8xG2fO0cmOfmme5JGCiuE2qo9fKZQq0FbkQ4cuAbddr(iihcLNnKtFb5Ske9xG2fCzNf64zbWd2coOWFbkVaLxG2fO0cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faVfOj8xG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIldNSpmwHfO8cuuXfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwaSfa)fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq7cUSZcD8Sa4bBb25cXQqKG1LxKJUVR8Yol1XtZKXdk8M5N4jtnkNAt7uBA74Mj5Ske9BN3mz8GcVzw8hX(i76CPqZ8tDCH0hu4ntdOoTGUoxkSauAbtm3fW(FbS(c4Iwq4la)xa7)fyfUHZcuPf80xqkQfafEovlyYyFbtgTGld3c(eeRHXl4YkG88f0FfTalAbzSDAb8SaiI7ZcgRybCHzNwaoJRCQVa2)lyY4zbtm3fyXD3WzbNC86ZcED6lAM4cnuH4MjocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqKO6YldN8tqSgYuuYjM7c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIevxEz4KFcI1qMIsY6lq7cuAbddr(iQNtYij1dlQeKZQq0FbAxGslahb0pSCr9CsgjPEyrLOOlJ8(coCbeCe(nKCqxAbkQ4cWra9dlxupNKrsQhwujk6YiVVa4Ta7CHyvisuD5LHt(jiwdzkkzf6lq5fOOIlWGwWWqKpI65Kmss9WIkb5Ske9xGYlq7cuFPKGlm7KeNXvoj6dJvybWBb2ybAxWNuFPKyIhotgj5KrYlNJe)WYxG2fO(sjr9CsgjPEyrL4hw(c0Ua1xkj4cZoj1dlQe)WYBt7unHF74Mj5Ske9BN3mz8GcVzw8hX(i76CPqZ8tDCH0hu4ntdOoTGUoxkSal0KTawFbwzKVa9O3rQqKybN00cMyUla1xqr8xJfW9fyrqqgVGlRaTG(ROfmXcWCFwaAwGkLIIwWeZv0mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(coCbeCe(nKCqxAbAxG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIetmx5LHtIZ4kN6lq7cWra9dlxWfMDsQhwujk6YiVVGdxGslGGJWVHKd6sl4OfW4bfUyIhotgj5KrYlNJeeCe(nKCqxAbk3M2PAQz74Mj5Ske9BN3mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7l4WfqWr43qYbDPfODbkTaLwGbTGHHiFeKdHYZgYPVGCwfI(lqrfxGslyyiYhb5qO8SHC6liNvHO)c0UGl7SqhplaEWwWbf(lq5fO8c0UaLwGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YldN8tqSgYuuYjM7c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsCz4K9HXkSaLxGIkUaLwaocOFy5IjE4mzKKtgjVCosu0LrEFbWwa8xG2fO(sjbxy2jjoJRCs0hgRWcGTa4VaLxGYlq7cuFPKOEojJKupSOs8dlFbAxWLDwOJNfapylWoxiwfIeSU8IC09DLx2zPoEwGYntgpOWBMf)rSpYUoxk0M2PAAJ2XntYzvi63oVzY4bfEZCIhotgj5KrYlNJAMFQJlK(GcVzAa1PfmXCxGfAYwaRVauAbOXW(cSqtgYxWKrl4YWTGpbXAiwWjnTapgJxWRtlWcnzlOc9fGslyYOfmme5Zcq9fmScKB8cy)Va0yyFbwOjd5lyYOfCz4wWNGynentCHgQqCZu9LscUWStsCgx5KOpmwHfCiSfyNleRcrIjMR8YWjXzCLt9fODb4iG(HLl4cZoj1dlQefDzK3xWHWwabhHFdjh0LwG2fCzNf64zbWBb25cXQqKG1LxKJUVR8Yol1XZc0Ua1xkjQNtYij1dlQe)WYBt7unT52XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLxgojoJRCQVaTlyyiYhr9CsgjPEyrLGCwfI(lq7cWra9dlxupNKrsQhwujk6YiVVGdHTacoc)gsoOlTaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvEz4KFcI1qMIsY6lq7cWra9dlxWfMDsQhwujk6YiVVa4TanTrZKXdk8M5epCMmsYjJKxoh1M2PAAaAh3mjNvHOF78MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcoe2cSZfIvHiXeZvEz4K4mUYP(c0UaLwGbTGHHiFe1ZjzKK6HfvcYzvi6VafvCb4iG(HLlQNtYij1dlQefDzK3xa8wGDUqSkejMyUYldN8tqSgYuuYk0xGYlq7cWra9dlxWfMDsQhwujk6YiVVa4Ta7CHyvismXCLxgo5NGynKPOKSEZKXdk8M5epCMmsYjJKxoh1M2PAEI2XntYzvi63oVzY4bfEZKlm7KupSOQz(PoUq6dk8MPbuNwaRVauAbtm3fG6li8fG)lG9)cSc3WzbQ0cE6lif1cGcpNQfmzSVGjJwWLHBbFcI1W4fCzfqE(c6VIwWKXZcSOfKX2PfqE8YZwWLDEbS)xWKXZcMmQOfG6lWJzbmur8xJfWlOEoTGiTa9WIQf8dlx0mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(cG3cSZfIvHibRlVmCYpbXAitrjNyUlq7cuAbg0cWHDYzFe2jFY0OwGIkUaCeq)WYfxuvr1LrsorDjFefDzK3xa8wGDUqSkejyD5LHt(jiwdzkk5nMfO8c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsCz4K9HXkSaTlq9LsI65Kmss9WIkXpS8fODbx2zHoEwa8GTa7CHyvisW6YlYr33vEzNL64PnTt18K0oUzsoRcr)25ntgpOWBM1ZjzKK6HfvnZp1XfsFqH3mnG60cQqFbO0cMyUla1xq4la)xa7)fyfUHZcuPf80xqkQfafEovlyYyFbtgTGld3c(eeRHXl4YkG88f0FfTGjJkAbOUB4SagQi(RXc4fupNwWpS8fW(FbtgplG1xGv4golqLWXLwaBNrqSkeTG)RqE(cQNtIMjUqdviUzQ(sjbxy2jPEyrL4hw(c0UaLwaocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqKOcD5LHt(jiwdzkk5eZDbkQ4cWra9dlxWfMDsQhwujk6YiVVGdHTa7CHyvismXCLxgo5NGynKPOKS(cuEbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojUmCY(WyfwG2fGJa6hwUGlm7KupSOsu0LrEFbWBbAAJ20ovZdA74Mj5Ske9BN3mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fGJa6hwUGlm7KupSOsm1JKfDzK3xa8waJhu4IEgknipxQhwujW)AbAxG6lLe1ZjzKK6HfvIFy5lq7cWra9dlxupNKrsQhwujM6rYIUmY7laElGXdkCrpdLgKNl1dlQe4FTaTl4tQVusmXdNjJKCYi5LZrIFy5ntgpOWBM9muAqEUupSOQnTt10M0oUzsoRcr)25ntgpOWBM6f1jhtYijVi)3m)uhxi9bfEZ0aQtlqpUlyIf0T9pIoiPfW(ci4MIxaRUaKVGjJwGtWnlahb0pS8fyH8Fyz8cEoe17lqbnke7lyYiFbHdPXc(Vc55lGlm70c0dlQwW)rlyIfKfwl4YoVGSNNxASGI)i2Nf015sHfG6ntCHgQqCZCyiYhr9CsgjPEyrLGCwfI(lq7cuFPKGlm7KupSOs80xG2fO(sjr9CsgjPEyrLOOlJ8(coCb54V4YW1M2PAAtBh3mjNvHOF78MjUqdviUz(j1xkjM4HZKrsozK8Y5iXtFbAxWNuFPKyIhotgj5KrYlNJefDzK3xWHlGXdkCbxy2j5f17iiQli4i8Bi5GU0c0UadAb4Wo5Spcf0OqS3mz8GcVzQxuNCmjJK8I8FBANAd43oUzsoRcr)25ntCHgQqCZu9LsI65Kmss9WIkXtFbAxG6lLe1ZjzKK6HfvIIUmY7l4WfKJ)Ild3c0UaCeq)WYfK9aZdkCrr8xJfODb4iG(HLlM4HZKrsozK8Y5irrxg59fODbg0cWHDYzFekOrHyVzY4bfEZuVOo5ysgj5f5)20MM5nStxYN2XTt1SDCZKCwfI(TZBM4cnuH4M5nStxYhXh1h2X0cGhSfOj8BMmEqH3mvHqUcTPDQnAh3mz8GcVzQxuNCmjJK8I8FZKCwfI(TZBt7uBUDCZKCwfI(TZBM4cnuH4M5nStxYhXh1h2X0coCbAc)MjJhu4ntUWStYlQ3rquVnTtnaTJBMmEqH3m5cZojJsTzsoRcr)25TPD6jAh3mz8GcVzMqfjvH4(0mjNvHOF7820MMPEr44QYt742PA2oUzY4bfEZKlm7Ke5dbbr4PzsoRcr)25TPDQnAh3mz8GcVz2F3B4sUWStYeFrqiUAMKZQq0VDEBANAZTJBMmEqH3mXHFYXRi5LDwMt3Mj5Ske9BN3M2PgG2XntYzvi63oVzg6nZI600mz8GcVzANleRcrnt7CjD(snt(k768Tz(Pe)GMMzNMb55DbFLDD(2M2PNODCZKCwfI(TZBMHEZSOonntgpOWBM25cXQquZ0oxsNVuZKShsD80m)uIFqtZuZt0M2PNK2XntYzvi63oVzg6nZonntgpOWBM25cXQquZ0oxsNVuZuVi9heKKShntCHgQqCZuPfupNsrLtIosplCzFI6kiNvHO)c0Uagpi7KKC6IO(cG3c0CbhTaLwGMlWaBbkTadAb4Wo5SpcNWvaf1FbkVaLxGYnt7m0JKeuNAMWVzANHEuZuZ20o9G2oUzsoRcr)25nZqVz2PPzY4bfEZ0oxiwfIAM25s68LAMzSDsg6Kt)MjUqdviUzQ0cy8GStsYPlI6laElWglqrfxGDUqSkej0ls)bbjj7XcGTanxGIkUa7CHyvisWxzxNVla2c0Cbk3mTZqpssqDQzc)MPDg6rntnBt7uBs74Mj5Ske9BN3md9MzNMMjJhu4nt7CHyviQzANHEuZe(nt7CjD(snZeYziP6R820o1M2oUzsoRcr)25nZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzwD5LHt(jiwdzkk5eZTz(Pe)GMM5jAt7unHF74Mj5Ske9BN3md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPMz1Lxgo5NGynKPOKvO3m)uIFqtZ8eTPDQMA2oUzsoRcr)25nZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzwD5LHt(jiwdzkkjR3m)uIFqtZ0gWVnTt10gTJBMKZQq0VDEZm0BMf1PPzY4bfEZ0oxiwfIAM25s68LAM3yK6fHj6lNyUsvnAMFkXpOPzAZTPDQM2C74Mj5Ske9BN3md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPM5ng5LHt(jiwdzkk5eZTz(Pe)GMMPMWVnTt10a0oUzsoRcr)25nZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzEJrEz4KFcI1qMIsY6nZpL4h00m18eTPDQMNODCZKCwfI(TZBMHEZSOonntgpOWBM25cXQquZ0oxsNVuZK1Lxgo5NGynKPOKtm3M5Ns8dAAMAc)20ovZts74Mj5Ske9BN3md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPMjRlVmCYpbXAitrjVX0m)uIFqtZ0gWVnTt18G2oUzsoRcr)25nZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzwHU8YWj)eeRHmfLCI52m)uIFqtZ0gWVnTt10M0oUzsoRcr)25nZqVz2PPzY4bfEZ0oxiwfIAM25s68LAMtmx5LHt(jiwdzkkjR3mXfAOcXntLwaoSto7JWr5zJmX0cuuXfO0cWH)FOrWfMDsQxXhLRHGCwfI(lq7cy8GStsYPlI6l4WfyZlq5fOCZ0od9ijb1PM5jAM2zOh1m18eTPDQM202XntYzvi63oVzg6nZI600mz8GcVzANleRcrnt7CjD(snZjMR8YWj)eeRHmfLSc9M5Ns8dAAM2a(TPDQnGF74Mj5Ske9BN3md9MzNMMjJhu4nt7CHyviQzANHEuZ8Ka)fyGBbkTGl3hQ0qANHE0cmWwGMWh(lq5MjUqdviUzId7KZ(iCuE2itm1mTZL05l1mv5Q4CsEzNL64PnTtTHMTJBMKZQq0VDEZm0BMDAAMmEqH3mTZfIvHOMPDg6rntB6jwGbUfO0cUCFOsdPDg6rlWaBbAcF4VaLBM4cnuH4MjoSto7Jqbnke7nt7CjD(sntvUkoNKx2zPoEAt7uByJ2XntYzvi63oVzg6nZonntgpOWBM25cXQquZ0od9OMPnb(lWa3cuAbxUpuPH0od9OfyGTanHp8xGYntCHgQqCZ0oxiwfIeQCvCojVSZsD8Sayla(nt7CjD(sntvUkoNKx2zPoEAt7uByZTJBMKZQq0VDEZm0BMf1PPzY4bfEZ0oxiwfIAM25s68LAMSU8IC09DLx2zPoEAMFkXpOPzQ5jAt7uByaAh3mjNvHOF78MzO3mlQttZKXdk8MPDUqSke1mTZL05l1mNyUYldNeNXvo1BMFkXpOPzAJ20o1gNODCZKCwfI(TZBMHEZSOonntgpOWBM25cXQquZ0oxsNVuZKdsoXCLxgojoJRCQ3m)uIFqtZ0gTPDQnojTJBMKZQq0VDEZm0BMDAAMmEqH3mTZfIvHOMPDg6rntnxGb2cuAbKT)H01PVGU6AuedjJ67SJPfOOIlqPfmme5JOEojJKupSOsqoRcr)fODbkTGHHiFeCHzNKeoleKZQq0FbkQ4cmOfGd7KZ(iuqJcX(cuEbAxGslWGwaoSto7JWjCfqr9xGIkUagpi7KKC6IO(cGTanxGIkUG65ukQCs0r6zHl7tuxb5Ske9xGYlq5fOCZ0oxsNVuZmH6zipxg6KtvBANAJdA74Mj5Ske9BN3md9MzNMMjJhu4nt7CHyviQzANHEuZKS9pKUo9fxgZQfj7zenY7RJWlqrfxaz7FiDD6lYH4pINO6sv(Ntlqrfxaz7FiDD6lYH4pINO6Yl9ziiu4lqrfxaz7FiDD6l(CPWncx(jScs93uuhtoMwGIkUaY2)q660xG8oUEdRcrsB)J95DLFYoctlqrfxaz7FiDD6l6XdcIMb55Y6PQXcuuXfq2(hsxN(I(ZvHI4l5lnzA0NfOOIlGS9pKUo9fwScKtvxMQW)lqrfxaz7FiDD6lsq8LKrsQYZarnt7CjD(sntwxgU81P20o1g2K2XntYzvi63oVzg6nZI600mz8GcVzANleRcrnt7CjD(sntoi5eZvEz4K4mUYPEZ8tj(bnntB0M2P2WM2oUzsoRcr)25nZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzs2dPoEAMFkXpOPzQ5jAt7uBg(TJBMmEqH3mVOQIsIUCo1mjNvHOF7820o1M1SDCZKCwfI(TZBM4cnuH4MPbTa7CHyvisOxK(dcss2JfaBbAUaTlOEoLIkNeFuhJ0HqoxAiXX9Y(xqoRcr)MjJhu4nZuf9rnGM20o1MTr74Mj5Ske9BN3mXfAOcXntdAb25cXQqKqVi9heKKShla2c0CbAxGbTG65ukQCs8rDmshc5CPHeh3l7Fb5Ske9BMmEqH3m5cZojvH4(0M2P2Sn3oUzsoRcr)25ntCHgQqCZ0oxiwfIe6fP)GGKK9ybWwGMntgpOWBMK9aZdk820MMjFLDD(2oUDQMTJBMKZQq0VDEZKXdk8MjzpW8GcVz(PoUq6dk8MjJhu4DbFLDD(cdZoMGKmEqHBmkbJXdkCbzpW8GcxGZy3jiKNR9Yol0Xd8GztprZexOHke3mVSZcD8SGdHTa7CHyvisq2dPoEwG2fO0cWra9dlxmXdNjJKCYi5LZrIIUmY7l4qylGXdkCbzpW8GcxqWr43qYbDPfOOIlahb0pSCbxy2jPEyrLOOlJ8(coe2cy8Gcxq2dmpOWfeCe(nKCqxAbkQ4cuAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5I65Kmss9WIkrrxg59fCiSfW4bfUGShyEqHli4i8Bi5GU0cuEbkVaTlq9LsI65Kmss9WIkXpS8fODbQVusWfMDsQhwuj(HLVaTl4tQVusmXdNjJKCYi5LZrIFy5TPDQnAh3mjNvHOF78MjUqdviUzIJa6hwUGlm7KupSOsu0LrEFbWwa8xG2fO0cuFPKOEojJKupSOs8dlFbAxGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YldN8tqSgYuuYjM7cuuXfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fO8cuUzY4bfEZ8t8KPgLtTPDQn3oUzsoRcr)25ntCHgQqCZehb0pSCbxy2jPEyrLOOlJ8(cGTa4VaTlqPfO(sjr9CsgjPEyrL4hw(c0UaLwaocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqKG1Lxgo5NGynKPOKtm3fOOIlahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq5fOCZKXdk8M5fvvuDzKKtuxYN20o1a0oUzY4bfEZS4pI9r215sHMj5Ske9BN3M2PNODCZKCwfI(TZBM4cnuH4MP6lLeCHzNK6HfvIFy5lq7cWra9dlxWfMDsQhwujM6rYIUmY7laElGXdkCrpdLgKNl1dlQe4FTaTlq9LsI65Kmss9WIkXpS8fODb4iG(HLlQNtYij1dlQet9izrxg59faVfW4bfUONHsdYZL6Hfvc8VwG2f8j1xkjM4HZKrsozK8Y5iXpS8MjJhu4nZEgknipxQhwu1M2PNK2XntYzvi63oVzIl0qfIBMQVusupNKrsQhwuj(HLVaTlahb0pSCbxy2jPEyrLOOlJ8EZKXdk8Mz9CsgjPEyrvBANEqBh3mjNvHOF78MjUqdviUzQ0cWra9dlxWfMDsQhwujk6YiVVayla(lq7cuFPKOEojJKupSOs8dlFbkVafvCb6fzxMJ)cnf1ZjzKK6HfvntgpOWBMt8WzYijNmsE5CuBANAtAh3mjNvHOF78MjUqdviUzIJa6hwUGlm7KupSOsu0LrEFbhUGta)fODbQVusupNKrsQhwuj(HLVaTlG6DYXKWoQJcxgjPovjcpOWfKZQq0VzY4bfEZCIhotgj5KrYlNJAt7uBA74Mj5Ske9BN3mXfAOcXnt1xkjQNtYij1dlQe)WYxG2fGJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5LHt(jiwdzkk5eZTzY4bfEZKlm7KupSOQnTt1e(TJBMKZQq0VDEZexOHke3mvFPKGlm7KupSOs80xG2fO(sjbxy2jPEyrLOOlJ8(coe2cy8GcxWfMDsEr9ocI6ccoc)gsoOlTaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFyScntgpOWBMCHzNKQCvCo1M2PAQz74Mj5Ske9BN3mXfAOcXnt1xkj4cZojXzCLtI(WyfwWHlq9LscUWStsCgx5K4YWj7dJvybAxG6lLe1ZjzKK6HfvIFy5lq7cuFPKGlm7KupSOs8dlFbAxWNuFPKyIhotgj5KrYlNJe)WYBMmEqH3m5cZojJsTnTt10gTJBMKZQq0VDEZexOHke3mvFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hw(c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsCz4K9HXk0mz8GcVzYfMDsQYvX5uBANQPn3oUzsoRcr)25ntCgJ8MPMntIlinK4mg5suQzQ(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvu9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnuUzIl0qfIBMQVusGHiUWCFqEUOigpntgpOWBMCHzNKxuVJGOEBANQPbODCZKCwfI(TZBM4mg5ntnBMexqAiXzmYLOuZu9LscmeXfM7dYZL4m2Dcs8dlxRsQVusWfMDsQhwujE6kQO6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AOCZexOHke3mnOfWhKuHgsWfMDsQ)Uxcc55cYzvi6VafvCbQVusGHiUWCFqEUeNXUtqIFy5ntgpOWBMCHzNKxuVJGOEBANQ5jAh3mjNvHOF78MjUqdviUzQ(sjr9CsgjPEyrL4hw(c0Ua1xkj4cZoj1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS8MjJhu4ntYEG5bfEBANQ5jPDCZKCwfI(TZBM4cnuH4MP6lLeCHzNK4mUYjrFyScl4WfO(sjbxy2jjoJRCsCz4K9HXk0mz8GcVzYfMDsgLABANQ5bTDCZKXdk8Mjxy2jPkxfNtntYzvi63oVnTt10M0oUzY4bfEZKlm7KufI7tZKCwfI(TZBtBAMCqTJBNQz74Mj5Ske9BN3mXfAOcXnZ65ukQCs8rDmshc5CPHeh3l7Fb5Ske9xG2fGJa6hwUq9LsYpQJr6qiNlnK44Ez)lkI)ASaTlq9LsIpQJr6qiNlnK44Ez)ltv0hXpS8fODbkTa1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrL4hw(c0UGpP(sjXepCMmsYjJKxohj(HLVaLxG2fGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbkTa1xkj4cZojXzCLtI(WyfwWHWwGDUqSkej4GKtmx5LHtIZ4kN6lq7cuAbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cYX)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYldN8tqSgYuuswFbkVafvCbkTadAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5cUWSts9WIkrrxg59faVfyNleRcrIjMR8YWj)eeRHmfLK1xGYlqrfxaocOFy5cUWSts9WIkrrxg59fCiSfKJ)lq5fOCZKXdk8MzQI(OgqtBANAJ2XntYzvi63oVzIl0qfIBMkTG65ukQCs8rDmshc5CPHeh3l7Fb5Ske9xG2fGJa6hwUq9LsYpQJr6qiNlnK44Ez)lkI)ASaTlq9LsIpQJr6qiNlnK44Ez)ltOIe)WYxG2fOxKDzo(l0uKQOpQb0SaLxGIkUaLwq9Ckfvoj(OogPdHCU0qIJ7L9VGCwfI(lq7cg0LwWHlqZfOCZKXdk8MzcvKufI7tBANAZTJBMKZQq0VDEZexOHke3mRNtPOYjrEH6qAiryegIeKZQq0FbAxaocOFy5cUWSts9WIkrrxg59faVfyZWFbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbWwa8xG2fO0cuFPKGlm7KeNXvoj6dJvybhcBb25cXQqKGdsoXCLxgojoJRCQVaTlqPfO0cggI8rupNKrsQhwujiNvHO)c0UaCeq)WYf1ZjzKK6HfvIIUmY7l4qylih)xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb25cXQqKyI5kVmCYpbXAitrjz9fO8cuuXfO0cmOfmme5JOEojJKupSOsqoRcr)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYldN8tqSgYuuswFbkVafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwqo(VaLxGYntgpOWBMPk6J0d7CBANAaAh3mjNvHOF78MjUqdviUzwpNsrLtI8c1H0qIWimejiNvHO)c0UaCeq)WYfCHzNK6HfvIIUmY7la2cG)c0UaLwGslqPfGJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5LHt(jiwdzkk5eZDbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojUmCY(WyfwGYlqrfxGslahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq7cuFPKGlm7KeNXvoj6dJvybhcBb25cXQqKGdsoXCLxgojoJRCQVaLxGYlq7cuFPKOEojJKupSOs8dlFbk3mz8GcVzMQOpspSZTPD6jAh3mjNvHOF78MjUqdviUzwpNsrLtIosplCzFI6kiNvHO)c0Ua9ISlZXFHMcYEG5bfEZKXdk8M5epCMmsYjJKxoh1M2PNK2XntYzvi63oVzIl0qfIBM1ZPuu5KOJ0Zcx2NOUcYzvi6VaTlqPfOxKDzo(l0uq2dmpOWxGIkUa9ISlZXFHMIjE4mzKKtgjVCoAbk3mz8GcVzYfMDsQhwu1M2Ph02XntYzvi63oVzIl0qfIBMd6slaElWMH)c0UG65ukQCs0r6zHl7tuxb5Ske9xG2fO(sjbxy2jjoJRCs0hgRWcoe2cSZfIvHibhKCI5kVmCsCgx5uFbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbWwa8xG2fGJa6hwUGlm7KupSOsu0LrEFbhcBb54FZKXdk8MjzpW8GcVnTtTjTJBMKZQq0VDEZKXdk8MjzpW8GcVzI8HQ6PpsuQzQ(sjrhPNfUSprDf9HXkat9LsIosplCzFI6kUmCY(WyfAMiFOQE6JeDV0hXd1m1SzIl0qfIBMd6slaElWMH)c0UG65ukQCs0r6zHl7tuxb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWwa8xG2fO0cuAbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cG3cSZfIvHibRlVmCYpbXAitrjNyUlq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLHt2hgRWcuEbkQ4cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faBbWFbAxG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIeCqYjMR8YWjXzCLt9fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq520o1M2oUzsoRcr)25ntCHgQqCZuPfGJa6hwUGlm7KupSOsu0LrEFbWBbgGtSafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwGnVaLxG2fGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbkTa1xkj4cZojXzCLtI(WyfwWHWwGDUqSkej4GKtmx5LHtIZ4kN6lq7cuAbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cYX)fODb4iG(HLl4cZoj1dlQefDzK3xa8wWjwGYlqrfxGslWGwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWBbNybkVafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwqo(VaLxGYntgpOWBMxuvr1LrsorDjFAt7unHF74Mj5Ske9BN3mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(coCbeCe(nKCqxAbAxGslq9LscUWStsCgx5KOpmwHfCiSfyNleRcrcoi5eZvEz4K4mUYP(c0UaLwGslyyiYhr9CsgjPEyrLGCwfI(lq7cWra9dlxupNKrsQhwujk6YiVVGdHTGC8FbAxaocOFy5cUWSts9WIkrrxg59faVfyNleRcrIjMR8YWj)eeRHmfLK1xGYlqrfxGslWGwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb25cXQqKyI5kVmCYpbXAitrjz9fO8cuuXfGJa6hwUGlm7KupSOsu0LrEFbhcBb54)cuEbk3mz8GcVzw8hX(i76CPqBANQPMTJBMKZQq0VDEZexOHke3mXra9dlxWfMDsQhwujk6YiVVGdxabhHFdjh0LwG2fO0cuAbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cG3cSZfIvHibRlVmCYpbXAitrjNyUlq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLHt2hgRWcuEbkQ4cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faBbWFbAxG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIeCqYjMR8YWjXzCLt9fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq5MjJhu4nZI)i2hzxNlfAt7unTr74Mj5Ske9BN3mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7la2cG)c0UaLwGslqPfGJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5LHt(jiwdzkk5eZDbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojUmCY(WyfwGYlqrfxGslahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq7cuFPKGlm7KeNXvoj6dJvybhcBb25cXQqKGdsoXCLxgojoJRCQVaLxGYlq7cuFPKOEojJKupSOs8dlFbk3mz8GcVz(jEYuJYP20ovtBUDCZKCwfI(TZBM4cnuH4MP6lLeCHzNK4mUYjrFyScl4qylWoxiwfIeCqYjMR8YWjXzCLt9fODbkTaLwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUOEojJKupSOsu0LrEFbhcBb54)c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5LHt(jiwdzkkjRVaLxGIkUaLwGbTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvEz4KFcI1qMIsY6lq5fOOIlahb0pSCbxy2jPEyrLOOlJ8(coe2cYX)fOCZKXdk8M5epCMmsYjJKxoh1M2PAAaAh3mjNvHOF78MjUqdviUzQ0cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faVfyNleRcrcwxEz4KFcI1qMIsoXCxG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIldNSpmwHfO8cuuXfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwWHWwGDUqSkej4GKtmx5LHtIZ4kN6lq5fO8c0Ua1xkjQNtYij1dlQe)WYBMmEqH3m5cZoj1dlQAt7unpr74Mj5Ske9BN3mXfAOcXnt1xkjQNtYij1dlQe)WYxG2fO0cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faVfyd4VaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYldNeNXvo1xGYlq5fODbkTaCeq)WYfCHzNK6HfvIIUmY7laElqtBSafvCbFs9LsIjE4mzKKtgjVCos80xGYntgpOWBM1ZjzKK6HfvTPDQMNK2XntYzvi63oVzIl0qfIBM4iG(HLl4cZojJsvu0LrEFbWBbNybkQ4cmOfmme5JGlm7Kmkvb5Ske9BMmEqH3m7zO0G8CPEyrvBANQ5bTDCZKCwfI(TZBM4cnuH4MP6lLeFINm1OCs80xG2f8j1xkjM4HZKrsozK8Y5iXtFbAxWNuFPKyIhotgj5KrYlNJefDzK3xWHWwG6lLe6f1jhtYijVi)lUmCY(WyfwGb2cy8GcxWfMDsQcX9rqWr43qYbDPfODbkTaLwWWqKpII6HZoMeKZQq0FbAxaJhKDssoDruFbhUadWcuEbkQ4cy8GStsYPlI6l4WfCIfO8c0UaLwGbTG65ukQCsWfMDsQgxvU(xYhb5Ske9xGIkUGHRCAezednzcD8Sa4TaB(elq5MjJhu4nt9I6KJjzKKxK)Bt7unTjTJBMKZQq0VDEZexOHke3mvFPK4t8KPgLtIN(c0UaLwGslyyiYhrr9WzhtcYzvi6VaTlGXdYojjNUiQVGdxGbybkVafvCbmEq2jj50fr9fC4coXcuEbAxGslWGwq9Ckfvoj4cZojvJRkx)l5JGCwfI(lqrfxWWvonImIHMmHoEwa8wGnFIfOCZKXdk8Mjxy2jPke3N20ovtBA74MjJhu4nZ(tNkpSZntYzvi63oVnTtTb8Bh3mjNvHOF78MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcGhSfO0cy8GStsYPlI6lWa3c0CbkVaTlOEoLIkNeCHzNKQXvLR)L8rqoRcr)fODbdx50iYigAYe64zbhUaB(entgpOWBMCHzNKQCvCo1M2P2qZ2XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YWj7dJvOzY4bfEZKlm7KuLRIZP20o1g2ODCZKCwfI(TZBM4cnuH4MP6lLeCHzNK4mUYjrFyScla2cGFZKXdk8Mjxy2jzuQTPDQnS52XntYzvi63oVzIl0qfIBMkTGIsf1ZyviAbkQ4cmOfmiScipFbkVaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFyScntgpOWBMonzujh6Qt9PnTtTHbODCZKCwfI(TZBM4cnuH4MP6lLeyiIlm3hKNlkIXZc0UG65ukQCsWfMDsI8eYrJgcYzvi6VaTlqPfO0cggI8rWxDiucH5bfUGCwfI(lq7cy8GStsYPlI6l4WfytwGYlqrfxaJhKDssoDruFbhUGtSaLBMmEqH3m5cZojVOEhbr920o1gNODCZKCwfI(TZBM4cnuH4MP6lLeyiIlm3hKNlkIXZc0UGHHiFeCHzNKeoleKZQq0FbAxWNuFPKyIhotgj5KrYlNJep9fODbkTGHHiFe8vhcLqyEqHliNvHO)cuuXfW4bzNKKtxe1xWHlWMUaLBMmEqH3m5cZojVOEhbr920o1gNK2XntYzvi63oVzIl0qfIBMQVusGHiUWCFqEUOigplq7cggI8rWxDiucH5bfUGCwfI(lq7cy8GStsYPlI6l4WfyaAMmEqH3m5cZojVOEhbr920o1gh02XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdxG6lLeCHzNK4mUYjXLHt2hgRqZKXdk8Mjxy2jjbNou0rH3M2P2WM0oUzsoRcr)25ntCHgQqCZu9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNexgozFySclq7c0lYUmh)fAk4cZojv5Q4CQzY4bfEZKlm7KKGthk6OWBt7uBytBh3mr(qv90hjk1mVSZcD8apy20t0mr(qv90hj6EPpIhQzQzZKXdk8MjzpW8GcVzsoRcr)25TPnnZqNCQAh3ovZ2XntYzvi63oVzIl0qfIBM1ZPuu5K4J6yKoeY5sdjoUx2)cYzvi6VaTlq9LsIpQJr6qiNlnK44Ez)ltv0hXtVzY4bfEZmHksQcX9PnTtTr74Mj5Ske9BN3mXfAOcXnZ65ukQCsKxOoKgsegHHib5Ske9xG2fCzNf64zbWBb20t0mz8GcVzMQOpspSZTPDQn3oUzY4bfEZ8t8KPgLtntYzvi63oVnTtnaTJBMKZQq0VDEZexOHke3mVSZcD8Sa4Tada8BMmEqH3ml(JyFKDDUuOnTtpr74Mj5Ske9BN3mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fGJa6hwUGlm7KupSOsu0LrEVzY4bfEZSNHsdYZL6HfvTPD6jPDCZKXdk8M5fvvuDzKKtuxYNMj5Ske9BN3M2Ph02XntgpOWBMt8WzYijNmsE5CuZKCwfI(TZBt7uBs74MjJhu4ntUWSts9WIQMj5Ske9BN3M2P202XntYzvi63oVzIl0qfIBMQVusupNKrsQhwuj(HL3mz8GcVzwpNKrsQhwu1M2PAc)2XntYzvi63oVzY4bfEZuVOo5ysgj5f5)M5N64cPpOWBMgqDAbhCyGwWelOB7FeDqslG9fqWnfVaBRWStl4CiUpl4)kKNVGjJwWXXyGoZ2o4fyH8FyTGNdr9(cQN7ipFb2wHzNwGbmolel4KMwGTvy2PfyaJZIfG6lyyiYh6B8cSOfGz3WzbVoTGdomqlWcnziFbtgTGJJXaDMTDWlWc5)WAbphI69fyrla5dv1tFwWKrlW2mqlaNXUtqgVGESalYqiOf0z70cqJOzIl0qfIBMg0cggI8rWfMDss4SqqoRcr)fODbFs9LsIjE4mzKKtgjVCos80xG2f8j1xkjM4HZKrsozK8Y5irrxg59fCiSfO0cy8GcxWfMDsQcX9rqWr43qYbDPfyGTa1xkj0lQtoMKrsEr(xCz4K9HXkSaLBt7un1SDCZKCwfI(TZBMmEqH3m1lQtoMKrsEr(Vz(PoUq6dk8M5jnTGdomqliJ7UHZcujYxWRt)f8FfYZxWKrl44ymqlWc5)WY4fyrgcbTGxNwaAwWelOB7FeDqslG9fqWnfVaBRWStl4CiUpla5lyYOfCYId(mB7GxGfY)HLOzIl0qfIBM)yef)rSpYUoxkik6YiVVa4TGtSafvCbFs9LsII)i2hzxNlfK2FqovSkccnAi6dJvybWBbWVnTt10gTJBMKZQq0VDEZexOHke3mvFPKqVOo5ysgj5f5FXtFbAxWNuFPKyIhotgj5KrYlNJep9fODbFs9LsIjE4mzKKtgjVCosu0LrEFbhcBbmEqHl4cZojvH4(ii4i8Bi5GUuZKXdk8Mjxy2jPke3N20ovtBUDCZKCwfI(TZBMmEqH3m5cZojv5Q4CQz(PoUq6dk8MPTbzXA0xW5CvCoTaEwWKrlG8)cI0cSTdEbwzKVG65oYZxWKrlW2km70co556gUglaIYj)ZLgntCHgQqCZu9LscUWSts9WIkXtFbAxG6lLeCHzNK6HfvIIUmY7l4WfKJ)lq7cQNtPOYjbxy2jjYtihnAiiNvHOFBANQPbODCZKCwfI(TZBMmEqH3m5cZojv5Q4CQz(PoUq6dk8MPTbzXA0xW5CvCoTaEwWKrlG8)cI0cMmAbNS4GxGfY)H1cSYiFb1ZDKNVGjJwGTvy2PfCYZ1nCnwaeLt(NlnAM4cnuH4MP6lLe1ZjzKK6HfvIN(c0Ua1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrLOOlJ8(coe2cYX)fODb1ZPuu5KGlm7Ke5jKJgneKZQq0VnTt18eTJBMKZQq0VDEZeNXiVzQzZK4csdjoJrUeLAMQVusGHiUWCFqEUeNXUtqIFy5Avs9LscUWSts9WIkXtxrfvYGggI8re2PspSOI(Avs9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnuwzLBM4cnuH4M5NuFPKyIhotgj5KrYlNJep9fODbddr(i4cZojjCwiiNvHO)c0UaLwG6lLeFINm1OCs8dlFbkQ4cy8GStsYPlI6la2c0CbkVaTl4tQVusmXdNjJKCYi5LZrIIUmY7laElGXdkCbxy2j5f17iiQli4i8Bi5GUuZKXdk8Mjxy2j5f17iiQ3M2PAEsAh3mjNvHOF78MjJhu4ntUWStYlQ3rquVzIZyK3m1SzIl0qfIBMQVusGHiUWCFqEUOigpTPDQMh02XntYzvi63oVzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLxgojoJRCQ3mz8GcVzYfMDsgLABANQPnPDCZKCwfI(TZBM4cnuH4MP6lLe1ZjzKK6HfvIN(cuuXfCzNf64zbWBbAEIMjJhu4ntUWStsviUpTPDQM202XntYzvi63oVzY4bfEZKShyEqH3mr(qv90hjk1mVSZcD8apy2Kt0mr(qv90hj6EPpIhQzQzZexOHke3mvFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5TPDQnGF74MjJhu4ntUWStsvUkoNAMKZQq0VDEBAtZmHCgsQ(kVDC7unBh3mjNvHOF78MjJhu4ntUWStYlQ3rquVzIZyK3m1SzIl0qfIBMQVusGHiUWCFqEUOigpTPDQnAh3mz8GcVzYfMDsQcX9PzsoRcr)25TPDQn3oUzY4bfEZKlm7KuLRIZPMj5Ske9BN3M20MMPDQ6OWBNAd4BdnHVnd)dQqZMPfxoYZ7nZdcB7KD6j90tU26cwWXz0cqx9OMfKIAbgMq9mKNldDYPYWfuKT)Hk6VGECPfWVjU8q)fGZypN6I1iBb50c00wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKnGtzXAKTGCAb2WwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsAcNYI1iBb50cSzBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50cma26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL0eoLfRr2cYPfCcBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxaplWa2aVTSaL0eoLfRr2cYPfOj8T1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkzd4uwSgzliNwGMNWwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsAcNYI1iBb50c00MyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGM2eBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxaplWa2aVTSaL0eoLfRr2cYPfOPn1wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTaBOPTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL0eoLfRrRrhe22j70t6PNCT1fSGJZOfGU6rnlif1cmm0jNkdxqr2(hQO)c6XLwa)M4Yd9xaoJ9CQlwJSfKtlqtBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50cSHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXAKTGCAbAcFBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPjCklwJSfKtlqtB2wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfWZcmGnWBllqjnHtzXAKTGCAbAAaS1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCb8Sadyd82Ycust4uwSgzliNwGMNWwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsAcNYI1O1OdcB7KD6j90tU26cwWXz0cqx9OMfKIAbgwXWdkCdxqr2(hQO)c6XLwa)M4Yd9xaoJ9CQlwJSfKtlqtBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPjCklwJSfKtlWg26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL0eoLfRr2cYPfyaS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKMWPSynYwqoTGtyRlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjnHtzXAKTGCAb2uBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPjCklwJSfKtlqtBQTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL0eoLfRr2cYPfyd4BRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGn00wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTaByZ26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL0eoLfRr2cYPfyddGTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXA0A0bHTDYo9KE6jxBDbl44mAbOREuZcsrTad)uIFqJHlOiB)dv0Fb94slGFtC5H(laNXEo1fRr2cYPfydBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGs2aoLfRr2cYPfyZ26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaLSbCklwJSfKtlWayRlWGd3ovd9xGj6AWlORHpmCl4KZfmXcSLhVGpYoQJcFbHov8e1cu6mLxGsAcNYI1iBb50coHTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSbCklwJSfKtl4GARlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGMhuBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50c00MARlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGn00wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTaByZ26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cust4uwSgzliNwGnSzBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50cSHnBRlWGd3ovd9xGH4W)p0ioGHlyIfyio8)dnIdiiNvHOVHlGNfyaBG3wwGsAcNYI1O1OdcB7KD6j90tU26cwWXz0cqx9OMfKIAbgQxeoUQ8y4ckY2)qf9xqpU0c43exEO)cWzSNtDXAKTGCAbNeBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50c00MyRlWGd3ovd9xGH4W)p0ioGHlyIfyio8)dnIdiiNvHOVHlqjnHtzXAKTGCAb24KyRlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjBaNYI1iBb50cSXjXwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTaBwtBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxaplWa2aVTSaL0eoLfRr2cYPfyZ2WwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfWZcmGnWBllqjnHtzXA0A0bHTDYo9KE6jxBDbl44mAbOREuZcsrTadXra9dlVB4ckY2)qf9xqpU0c43exEO)cWzSNtDXAKTGCAbAARlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjBaNYI1iBb50c00wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTaByRlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjBaNYI1iBb50cSHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXAKTGCAb2STUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSbCklwJSfKtlWMT1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPjCklwJSfKtlWayRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwWjXwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGs2aoLfRr2cYPfytS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnGtzXAKTGCAb2uBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkzd4uwSgzliNwGMAARlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjBaNYI1iBb50c00MT1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKMWPSynYwqoTanna26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cust4uwSgzliNwGM2eBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPjCklwJwJoiSTt2PN0tp5ARlybhNrlaD1JAwqkQfyihKHlOiB)dv0Fb94slGFtC5H(laNXEo1fRr2cYPfOPTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSbCklwJSfKtlqtBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50cSHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjBaNYI1iBb50cSzBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkzd4uwSgzliNwGnBRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGbWwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTGtyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwWjXwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKMWPSynYwqoTGdQTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXAKTGCAb2eBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsAcNYI1iBb50cSP26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cuYgWPSynYwqoTanHVTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSbCklwJSfKtlqtB2wxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGs2aoLfRr2cYPfO5jXwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxaplWa2aVTSaL0eoLfRr2cYPfO5b1wxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsAcNYI1iBb50c08GARlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cust4uwSgzliNwGM2eBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPjCklwJSfKtlqtBITUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXAKTGCAb2a(26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL0eoLfRr2cYPfyddGTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL0eoLfRr2cYPfyddGTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnHtzXAKTGCAb24e26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cuYgWPSynYwqoTaBCsS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKMWPSynAn6GW2ozNEsp9KRTUGfCCgTa0vpQzbPOwGH8v215RHlOiB)dv0Fb94slGFtC5H(laNXEo1fRr2cYPfOPTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL0eoLfRrRrN0REud9xGMAUagpOWxaeQpDXAuZKFtwuntt09bXdkCdU400m1RiHGOMPTZ2TadeNtlW2km70AKTZ2Tadex4SfOj8nEb2a(2qZ1O1iBNTBbNm6g2PfyNleRcrc(k768DbiFbj2EulislOtZG88UGVYUoFxGs4mcRWc0iE1c66eEbH(GcVRSynY2z7wGbuNwWOHocZqlWeDn4fKX(hc55lislaNXUtqla5dv1tFqHVaK3hI)lislWqm7ycsY4bfUHI1O1igpOW7c9IWXvLNJGDgxy2jjYhccIWZAeJhu4DHEr44QYZrWoJlm7KmXxeeIR1igpOW7c9IWXvLNJGDgo8toEfjVSZYC6UgX4bfExOxeoUQ8CeSZSZfIvHiJD(sW4RSRZxJdDyf1PX4pL4h0aRtZG88UGVYUoFxJy8GcVl0lchxvEoc2z25cXQqKXoFjyK9qQJhJdDyf1PX4pL4h0atZtSgX4bfExOxeoUQ8CeSZSZfIvHiJD(sW0ls)bbjj7HXHoSongJsWuQEoLIkNeDKEw4Y(e1vlJhKDssoDruhEAEKsAAGPKbHd7KZ(iCcxbuuFLvwzJTZqpcMMgBNHEKKG6em4VgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWYy7Km0jN(gh6W60ymkbtjgpi7KKC6IOo8SHIkANleRcrc9I0FqqsYEattfv0oxiwfIe8v215lmnv2y7m0JGPPX2zOhjjOobd(RrmEqH3f6fHJRkphb7m7CHyviYyNVeSeYziP6RCJdDyDAm2od9iyWFnIXdk8UqViCCv55iyNzNleRcrg78LGvD5LHt(jiwdzkk5eZ14qhwrDAm(tj(bnWoXAeJhu4DHEr44QYZrWoZoxiwfIm25lbR6YldN8tqSgYuuYk0no0HvuNgJ)uIFqdStSgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWQU8YWj)eeRHmfLK1no0HvuNgJ)uIFqdmBa)1igpOW7c9IWXvLNJGDMDUqSkezSZxc2ngPEryI(YjMRuvdJdDyf1PX4pL4h0aZMxJy8GcVl0lchxvEoc2z25cXQqKXoFjy3yKxgo5NGynKPOKtmxJdDyf1PX4pL4h0att4VgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWUXiVmCYpbXAitrjzDJdDyf1PX4pL4h0atZtSgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWyD5LHt(jiwdzkk5eZ14qhwrDAm(tj(bnW0e(RrmEqH3f6fHJRkphb7m7CHyviYyNVemwxEz4KFcI1qMIsEJX4qhwrDAm(tj(bnWSb8xJy8GcVl0lchxvEoc2z25cXQqKXoFjyvOlVmCYpbXAitrjNyUgh6WkQtJXFkXpObMnG)AeJhu4DHEr44QYZrWoZoxiwfIm25lbBI5kVmCYpbXAitrjzDJdDyDAmgLGPeoSto7JWr5zJmXKIkQeo8)dncUWSts9k(OCn0Y4bzNKKtxe1p0MvwzJTZqpcMMNWy7m0JKeuNGDI1igpOW7c9IWXvLNJGDMDUqSkezSZxc2eZvEz4KFcI1qMIswHUXHoSI60y8Ns8dAGzd4VgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWu5Q4CsEzNL64X4qhwNgJrjy4Wo5SpchLNnYetgBNHEeStc8nWP0L7dvAiTZqpYatt4dFLxJy8GcVl0lchxvEoc2z25cXQqKXoFjyQCvCojVSZsD8yCOdRtJXOemCyNC2hHcAui2n2od9iy20tyGtPl3hQ0qANHEKbMMWh(kVgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWu5Q4CsEzNL64X4qhwNgJrjy25cXQqKqLRIZj5LDwQJhyW3y7m0JGztGVboLUCFOsdPDg6rgyAcF4R8AeJhu4DHEr44QYZrWoZoxiwfIm25lbJ1LxKJUVR8Yol1XJXHoSI60y8Ns8dAGP5jwJy8GcVl0lchxvEoc2z25cXQqKXoFjytmx5LHtIZ4kN6gh6WkQtJXFkXpObMnwJy8GcVl0lchxvEoc2z25cXQqKXoFjyCqYjMR8YWjXzCLtDJdDyf1PX4pL4h0aZgRrmEqH3f6fHJRkphb7m7CHyviYyNVeSeQNH8CzOtovgh6W60ySDg6rW00atjY2)q660xqxDnkIHKr9D2XKIkQ0WqKpI65Kmss9WIkTknme5JGlm7KKWzHIkAq4Wo5Spcf0OqSRSwLmiCyNC2hHt4kGI6ROImEq2jj50frDyAQOI1ZPuu5KOJ0Zcx2NOUkRSYRrmEqH3f6fHJRkphb7m7CHyviYyNVemwxgU81jJdDyDAm2od9iyKT)H01PV4YywTizpJOrEFDewrfjB)dPRtFroe)r8evxQY)CsrfjB)dPRtFroe)r8evxEPpdbHcxrfjB)dPRtFXNlfUr4YpHvqQ)MI6yYXKIks2(hsxN(cK3X1ByvisA7FSpVR8t2rysrfjB)dPRtFrpEqq0mipxwpvnuurY2)q660x0FUkueFjFPjtJ(OOIKT)H01PVWIvGCQ6Yuf(xrfjB)dPRtFrcIVKmssvEgiAnIXdk8UqViCCv55iyNzNleRcrg78LGXbjNyUYldNeNXvo1no0HvuNgJ)uIFqdmBSgX4bfExOxeoUQ8CeSZSZfIvHiJD(sWi7Huhpgh6WkQtJXFkXpObMMNynIXdk8UqViCCv55iyNDrvfLeD5CAnIXdk8UqViCCv55iyNLQOpQb0ymkbZGSZfIvHiHEr6piijzpGPP265ukQCs8rDmshc5CPHeh3l7)1igpOW7c9IWXvLNJGDgxy2jPke3hJrjygKDUqSkej0ls)bbjj7bmn1Aq1ZPuu5K4J6yKoeY5sdjoUx2)RrmEqH3f6fHJRkphb7mYEG5bfUXOem7CHyvisOxK(dcss2dyAUgTgX4bfE)iyNHJNpu11jiO1igpOW7hb7m7CHyviYyNVeSm2ojdDYPVXHoSongBNHEemnngLGzNleRcrIm2ojdDYPpm4RvVi7YC8xOPGShyEqHR1GuQEoLIkNeDKEw4Y(e1vrfRNtPOYjXqx9OyiPfx6kVgX4bfE)iyNzNleRcrg78LGLX2jzOto9no0H1PXy7m0JGPPXOem7CHyvisKX2jzOto9HbFTQVusWfMDsQhwuj(HLRfhb0pSCbxy2jPEyrLOOlJ8UwLQNtPOYjrhPNfUSprDvuX65ukQCsm0vpkgsAXLUYRrmEqH3pc2z25cXQqKXoFjyjKZqs1x5gh6W60ySDg6rW00yucM6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(Wyf0AqQVusupisgj5Kve1fpDTQrVRnHYZgzrxg59dHPKsx25toz8GcxWfMDsQcX9rGJ(OSbgJhu4cUWStsviUpccoc)gsoOlP8AeJhu49JGD2RtYl7SmNUgJsWuAyiYhb5qO8SHC6R9Yol0XZHWSjWx7LDwOJh4b7KCcLvurLmOHHiFeKdHYZgYPV2l7SqhphcZMCcLxJy8GcVFeSZ0JbfUXOem1xkj4cZoj1dlQep91igpOW7hb7SbDjPfx6gJsWQNtPOYjXqx9OyiPfx6AvFPKGGlJF9bfU4PRvjCeq)WYfCHzNK6HfvII4VgkQOA07AtO8Srw0LrE)qyga4R8AeJhu49JGDgekpB6YtoE)8l5JXOem1xkj4cZoj1dlQe)WY1Q(sjr9CsgjPEyrL4hwU2pP(sjXepCMmsYjJKxohj(HLVgX4bfE)iyNPY5YijNcHvOBmkbt9LscUWSts9WIkXpSCTQVusupNKrsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5RrmEqH3pc2zQu1PsbKNBmkbt9LscUWSts9WIkXtFnIXdk8(rWotfkIVm9knmgLGP(sjbxy2jPEyrL4PVgX4bfE)iyNLqfPcfX3yucM6lLeCHzNK6HfvIN(AeJhu49JGDg7yQpfdjXmeKXOem1xkj4cZoj1dlQep91igpOW7hb7SxNKOHUDJrjyQVusWfMDsQhwujE6RrmEqH3pc2zVojrdDnMsjcpsNVeSCi(J4jQUuL)5KXOem1xkj4cZoj1dlQepDfvehb0pSCbxy2jPEyrLOOlJ8o8GDItO9tQVusmXdNjJKCYi5LZrIN(AeJhu49JGD2Rts0qxJD(sWORUgfXqYO(o7yYyucgocOFy5cUWSts9WIkrrxg59dHzd4VgX4bfE)iyN96Ken01yNVeSFr8pHksAN6DcYyucgocOFy5cUWSts9WIkrrxg5D4bZgWxrfni7CHyvisW6YWLVobttfvuPbDjyWxRDUqSkejsOEgYZLHo5ubttT1ZPuu5KOJ0Zcx2NOUkVgX4bfE)iyN96Ken01yNVeSE8GKOChnuzmkbdhb0pSCbxy2jPEyrLOOlJ8o8GzZWxrfni7CHyvisW6YWLVobtZ1igpOW7hb7SxNKOHUg78LGLdPHEMmssU3rxeepOWngLGHJa6hwUGlm7KupSOsu0LrEhEWSb8vurdYoxiwfIeSUmC5RtW0urfvAqxcg81ANleRcrIeQNH8CzOtovW0uB9Ckfvoj6i9SWL9jQRYRrmEqH3pc2zVojrdDn25lb7YywTizpJOrEFDe2yucgocOFy5cUWSts9WIkrrxg59dHDcTkzq25cXQqKiH6zipxg6KtfmnvuXbDj4zZWx51igpOW7hb7SxNKOHUg78LGDzmRwKSNr0iVVocBmkbdhb0pSCbxy2jPEyrLOOlJ8(HWoHw7CHyvisKq9mKNldDYPcMMAvFPKOEojJKupSOs801Q(sjr9CsgjPEyrLOOlJ8(HWust4BG7egy1ZPuu5KOJ0Zcx2NOUkRDqx6qBg(RrmEqH3pc2zygcsY4bfUec1hJD(sW4GmUpfcpW00yucgJhKDssoDruhE2ynIXdk8(rWodZqqsgpOWLqO(ySZxcwgx3W1W4(ui8attJrjy4Wo5Spcf0OqSRTEoLIkNeCHzNKipHC0OH2HHiFe1ZjzKK6HfvAniC4)hAeCHzNK6v8r5ASgz7wWXz0csOEgYZxqOtovlqLYrEFbwOjBbNS4Gxa7)fKq9mQVGuulWGn4fOxbUVGjwWRtl4)kKNVGJJXaDMTDWRrmEqH3pc2zygcsY4bfUec1hJD(sWsOEgYZLHo5uzCFkeEGPPXOem7CHyvisKX2jzOto9HbFT25cXQqKiH6zipxg6Kt1AeJhu49JGDgMHGKmEqHlHq9XyNVeSqNCQmUpfcpW00yucMDUqSkejYy7Km0jN(WG)AeJhu49JGDgMHGKmEqHlHq9XyNVem(k76814(ui8attJrjyDAgKN3f8v215lmnxJy8GcVFeSZWmeKKXdkCjeQpg78LGHJa6hwEFnIXdk8(rWodZqqsgpOWLqO(ySZxcwfdpOWnUpfcpW00yucMDUqSkejsiNHKQVYHb)1igpOW7hb7mmdbjz8GcxcH6JXoFjyjKZqs1x5g3NcHhyAAmkbZoxiwfIejKZqs1x5W0CnIXdk8(rWodZqqsgpOWLqO(ySZxc2nStxYN1O1iB3cy8GcVl4RSRZxyy2XeKKXdkCJrjymEqHli7bMhu4cCg7obH8CTx2zHoEGhmB6jwJy8GcVl4RSRZ3JGDgzpW8Gc3yuc2LDwOJNdHzNleRcrcYEi1XJwLWra9dlxmXdNjJKCYi5LZrIIUmY7hcJXdkCbzpW8GcxqWr43qYbDjfvehb0pSCbxy2jPEyrLOOlJ8(HWy8Gcxq2dmpOWfeCe(nKCqxsrfvAyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hcJXdkCbzpW8GcxqWr43qYbDjLvwR6lLe1ZjzKK6HfvIFy5AvFPKGlm7KupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WYxJy8GcVl4RSRZ3JGD2N4jtnkNmgLGHJa6hwUGlm7KupSOsu0LrEhg81QK6lLe1ZjzKK6HfvIFy5Avchb0pSCXepCMmsYjJKxohjk6YiVdp7CHyvisW6YldN8tqSgYuuYjMRIkIJa6hwUyIhotgj5KrYlNJefDzK3HbFLvEnIXdk8UGVYUoFpc2zxuvr1LrsorDjFmgLGHJa6hwUGlm7KupSOsu0LrEhg81QK6lLe1ZjzKK6HfvIFy5Avchb0pSCXepCMmsYjJKxohjk6YiVdp7CHyvisW6YldN8tqSgYuuYjMRIkIJa6hwUyIhotgj5KrYlNJefDzK3HbFLvEnIXdk8UGVYUoFpc2zf)rSpYUoxkSgX4bfExWxzxNVhb7SEgknipxQhwuzmkbt9LscUWSts9WIkXpSCT4iG(HLl4cZoj1dlQet9izrxg5D4X4bfUONHsdYZL6Hfvc8V0Q(sjr9CsgjPEyrL4hwUwCeq)WYf1ZjzKK6HfvIPEKSOlJ8o8y8Gcx0ZqPb55s9WIkb(xA)K6lLet8WzYijNmsE5CK4hw(AeJhu4DbFLDD(EeSZQNtYij1dlQmgLGP(sjr9CsgjPEyrL4hwUwCeq)WYfCHzNK6HfvIIUmY7RrmEqH3f8v2157rWoBIhotgj5KrYlNJmgLGPeocOFy5cUWSts9WIkrrxg5DyWxR6lLe1ZjzKK6HfvIFy5kROI6fzxMJ)cnf1ZjzKK6HfvRrmEqH3f8v2157rWoBIhotgj5KrYlNJmgLGHJa6hwUGlm7KupSOsu0LrE)WtaFTQVusupNKrsQhwuj(HLRL6DYXKWoQJcxgjPovjcpOWfKZQq0FnIXdk8UGVYUoFpc2zCHzNK6HfvgJsWuFPKOEojJKupSOs8dlxlocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lxgo5NGynKPOKtm31igpOW7c(k7689iyNXfMDsQYvX5KXOem1xkj4cZoj1dlQepDTQVusWfMDsQhwujk6YiVFimgpOWfCHzNKxuVJGOUGGJWVHKd6sAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRWAeJhu4DbFLDD(EeSZ4cZojJs1yucM6lLeCHzNK4mUYjrFySchQ(sjbxy2jjoJRCsCz4K9HXkOv9LsI65Kmss9WIkXpSCTQVusWfMDsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5RrmEqH3f8v2157rWoJlm7KuLRIZjJrjyQVusupNKrsQhwuj(HLRv9LscUWSts9WIkXpSCTFs9LsIjE4mzKKtgjVCos8dlxR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(WyfwJy8GcVl4RSRZ3JGDgxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4XyCgJCyAAmXfKgsCgJCjkbt9LscmeXfM7dYZL4m2Dcs8dlxRsQVusWfMDsQhwujE6kQO6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AO8AeJhu4DbFLDD(EeSZ4cZojVOEhbrDJrjygeFqsfAibxy2jP(7EjiKNliNvHOVIkQ(sjbgI4cZ9b55sCg7obj(HLBmoJromnnM4csdjoJrUeLGP(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvu9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnuEnIXdk8UGVYUoFpc2zK9aZdkCJrjyQVusupNKrsQhwuj(HLRv9LscUWSts9WIkXpSCTFs9LsIjE4mzKKtgjVCos8dlFnIXdk8UGVYUoFpc2zCHzNKrPAmkbt9LscUWStsCgx5KOpmwHdvFPKGlm7KeNXvojUmCY(WyfwJy8GcVl4RSRZ3JGDgxy2jPkxfNtRrmEqH3f8v2157rWoJlm7KufI7ZA0AeJhu4DbheSuf9rnGgJrjy1ZPuu5K4J6yKoeY5sdjoUx2)AXra9dlxO(sj5h1XiDiKZLgsCCVS)ffXFn0Q(sjXh1XiDiKZLgsCCVS)LPk6J4hwUwLuFPKGlm7KupSOs8dlxR6lLe1ZjzKK6HfvIFy5A)K6lLet8WzYijNmsE5CK4hwUYAXra9dlxmXdNjJKCYi5LZrIIUmY7WGVwLuFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLxgojoJRCQRvjLggI8rupNKrsQhwuPfhb0pSCr9CsgjPEyrLOOlJ8(HWYXFT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYldN8tqSgYuuswxzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRRSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExWbDeSZsOIKQqCFmgLGPu9Ckfvoj(OogPdHCU0qIJ7L9VwCeq)WYfQVus(rDmshc5CPHeh3l7Frr8xdTQVus8rDmshc5CPHeh3l7FzcvK4hwUw9ISlZXFHMIuf9rnGgLvurLQNtPOYjXh1XiDiKZLgsCCVS)1oOlDOMkVgX4bfExWbDeSZsv0hPh2zJrjy1ZPuu5KiVqDinKimcdrAXra9dlxWfMDsQhwujk6YiVdpBg(AXra9dlxmXdNjJKCYi5LZrIIUmY7WGVwLuFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLxgojoJRCQRvjLggI8rupNKrsQhwuPfhb0pSCr9CsgjPEyrLOOlJ8(HWYXFT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYldN8tqSgYuuswxzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRRSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExWbDeSZsv0hPh2zJrjy1ZPuu5KiVqDinKimcdrAXra9dlxWfMDsQhwujk6YiVdd(AvsjLWra9dlxmXdNjJKCYi5LZrIIUmY7WZoxiwfIeSU8YWj)eeRHmfLCI5Qv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNexgozFySckROIkHJa6hwUyIhotgj5KrYlNJefDzK3HbFTQVusWfMDsIZ4kNe9HXkCim7CHyvisWbjNyUYldNeNXvo1vwzTQVusupNKrsQhwuj(HLR8AeJhu4Dbh0rWoBIhotgj5KrYlNJmgLGvpNsrLtIosplCzFI6QvVi7YC8xOPGShyEqHVgX4bfExWbDeSZ4cZoj1dlQmgLGvpNsrLtIosplCzFI6Qvj9ISlZXFHMcYEG5bfUIkQxKDzo(l0umXdNjJKCYi5LZrkVgX4bfExWbDeSZi7bMhu4gJsWg0LGNndFT1ZPuu5KOJ0Zcx2NOUAvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLxgojoJRCQRfhb0pSCXepCMmsYjJKxohjk6YiVdd(AXra9dlxWfMDsQhwujk6YiVFiSC8FnIXdk8UGd6iyNr2dmpOWngLGnOlbpBg(ARNtPOYjrhPNfUSprD1IJa6hwUGlm7KupSOsu0LrEhg81QKskHJa6hwUyIhotgj5KrYlNJefDzK3HNDUqSkejyD5LHt(jiwdzkk5eZvR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLxgojoJRCQRSYAvFPKOEojJKupSOs8dlxzJr(qv90hjkbt9LsIosplCzFI6k6dJvaM6lLeDKEw4Y(e1vCz4K9HXkymYhQQN(ir3l9r8qW0CnIXdk8UGd6iyNDrvfvxgj5e1L8XyucMs4iG(HLl4cZoj1dlQefDzK3HNb4ekQiocOFy5cUWSts9WIkrrxg59dHzZkRfhb0pSCXepCMmsYjJKxohjk6YiVdd(Avs9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvEz4K4mUYPUwLuAyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hclh)1IJa6hwUGlm7KupSOsu0LrEhENqzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7W7ekROI4iG(HLl4cZoj1dlQefDzK3pewo(RSYRrmEqH3fCqhb7SI)i2hzxNlfmgLGHJa6hwUyIhotgj5KrYlNJefDzK3pKGJWVHKd6sAvs9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvEz4K4mUYPUwLuAyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hclh)1IJa6hwUGlm7KupSOsu0LrEhE25cXQqKyI5kVmCYpbXAitrjzDLvurLmOHHiFe1ZjzKK6HfvAXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLxgo5NGynKPOKSUYkQiocOFy5cUWSts9WIkrrxg59dHLJ)kR8AeJhu4Dbh0rWoR4pI9r215sbJrjy4iG(HLl4cZoj1dlQefDzK3pKGJWVHKd6sAvsjLWra9dlxmXdNjJKCYi5LZrIIUmY7WZoxiwfIeSU8YWj)eeRHmfLCI5Qv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNexgozFySckROIkHJa6hwUyIhotgj5KrYlNJefDzK3HbFTQVusWfMDsIZ4kNe9HXkCim7CHyvisWbjNyUYldNeNXvo1vwzTQVusupNKrsQhwuj(HLR8AeJhu4Dbh0rWo7t8KPgLtgJsWWra9dlxWfMDsQhwujk6YiVdd(AvsjLWra9dlxmXdNjJKCYi5LZrIIUmY7WZoxiwfIeSU8YWj)eeRHmfLCI5Qv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNexgozFySckROIkHJa6hwUyIhotgj5KrYlNJefDzK3HbFTQVusWfMDsIZ4kNe9HXkCim7CHyvisWbjNyUYldNeNXvo1vwzTQVusupNKrsQhwuj(HLR8AeJhu4Dbh0rWoBIhotgj5KrYlNJmgLGP(sjbxy2jjoJRCs0hgRWHWSZfIvHibhKCI5kVmCsCgx5uxRsknme5JOEojJKupSOslocOFy5I65Kmss9WIkrrxg59dHLJ)AXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLxgo5NGynKPOKSUYkQOsg0WqKpI65Kmss9WIkT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYldN8tqSgYuuswxzfvehb0pSCbxy2jPEyrLOOlJ8(HWYXFLxJy8GcVl4Goc2zCHzNK6HfvgJsWusjCeq)WYft8WzYijNmsE5CKOOlJ8o8SZfIvHibRlVmCYpbXAitrjNyUAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRGYkQOs4iG(HLlM4HZKrsozK8Y5irrxg5DyWxR6lLeCHzNK4mUYjrFySchcZoxiwfIeCqYjMR8YWjXzCLtDLvwR6lLe1ZjzKK6HfvIFy5RrmEqH3fCqhb7S65Kmss9WIkJrjyQVusupNKrsQhwuj(HLRvjLWra9dlxmXdNjJKCYi5LZrIIUmY7WZgWxR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLxgojoJRCQRSYAvchb0pSCbxy2jPEyrLOOlJ8o800gkQ4NuFPKyIhotgj5KrYlNJepDLxJy8GcVl4Goc2z9muAqEUupSOYyucgocOFy5cUWStYOuffDzK3H3juurdAyiYhbxy2jzuQRrmEqH3fCqhb7m9I6KJjzKKxK)ngLGP(sjXN4jtnkNepDTFs9LsIjE4mzKKtgjVCos801(j1xkjM4HZKrsozK8Y5irrxg59dHP(sjHErDYXKmsYlY)IldNSpmwbdmgpOWfCHzNKQqCFeeCe(nKCqxsRsknme5JOOE4SJjTmEq2jj50fr9dnakROImEq2jj50fr9dpHYAvYGQNtPOYjbxy2jPACv56FjFuuXHRCAezednzcD8apB(ekVgX4bfExWbDeSZ4cZojvH4(ymkbt9LsIpXtMAuojE6AvsPHHiFef1dNDmPLXdYojjNUiQFObqzfvKXdYojjNUiQF4juwRsgu9Ckfvoj4cZojvJRkx)l5JIkoCLtJiJyOjtOJh4zZNq51igpOW7coOJGDw)PtLh251igpOW7coOJGDgxy2jPkxfNtgJsWuFPKGlm7KeNXvoj6dJvaEWuIXdYojjNUiQBGttL1wpNsrLtcUWSts14QY1)s(OD4kNgrgXqtMqhphAZNynIXdk8UGd6iyNXfMDsQYvX5KXOem1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsCz4K9HXkSgX4bfExWbDeSZ4cZojJs1yucM6lLeCHzNK4mUYjrFyScWG)AeJhu4Dbh0rWoZPjJk5qxDQpgJsWuQOur9mwfIuurdAqyfqEUYAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRWAeJhu4Dbh0rWoJlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8OTEoLIkNeCHzNKipHC0OHwLuAyiYhbF1HqjeMhu4Az8GStsYPlI6hAtuwrfz8GStsYPlI6hEcLxJy8GcVl4Goc2zCHzNKxuVJGOUXOem1xkjWqexyUpipxueJhTddr(i4cZojjCwO9tQVusmXdNjJKCYi5LZrINUwLggI8rWxDiucH5bfUIkY4bzNKKtxe1p0MQ8AeJhu4Dbh0rWoJlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8ODyiYhbF1HqjeMhu4Az8GStsYPlI6hAawJy8GcVl4Goc2zCHzNKeC6qrhfUXOem1xkj4cZojXzCLtI(Wyfou9LscUWStsCgx5K4YWj7dJvynIXdk8UGd6iyNXfMDssWPdfDu4gJsWuFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRGw9ISlZXFHMcUWStsvUkoNwJy8GcVl4Goc2zK9aZdkCJr(qv90hjkb7Yol0Xd8GztpHXiFOQE6JeDV0hXdbtZ1O1iB3co4cffAqhK0cEDKNVG8c1H0ybimcdrlWcnzlG1flWaQtlanlWcnzlyI5UGyYOYc1jXAeJhu4DbocOFy5DyPk6J0d7SXOeS65ukQCsKxOoKgsegHHiT4iG(HLl4cZoj1dlQefDzK3HNndFT4iG(HLlM4HZKrsozK8Y5irrxg5DyWxRsQVusWfMDsIZ4kNe9HXkCim7CHyvismXCLxgojoJRCQRvjLggI8rupNKrsQhwuPfhb0pSCr9CsgjPEyrLOOlJ8(HWYXFT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYldN8tqSgYuuswxzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRRSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExGJa6hwE)iyNLQOpspSZgJsWQNtPOYjrEH6qAiryegI0IJa6hwUGlm7KupSOsu0LrEhg81QKbnme5JGCiuE2qo9vurLggI8rqoekpBiN(AVSZcD8apyhu4RSYAvsjCeq)WYft8WzYijNmsE5CKOOlJ8o80e(AvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRGYkQOs4iG(HLlM4HZKrsozK8Y5irrxg5DyWxR6lLeCHzNK4mUYjrFyScWGVYkRv9LsI65Kmss9WIkXpSCTx2zHoEGhm7CHyvisW6YlYr33vEzNL64znIXdk8Uahb0pS8(rWolvrFudOXyucw9Ckfvoj(OogPdHCU0qIJ7L9VwCeq)WYfQVus(rDmshc5CPHeh3l7Frr8xdTQVus8rDmshc5CPHeh3l7FzQI(i(HLRvj1xkj4cZoj1dlQe)WY1Q(sjr9CsgjPEyrL4hwU2pP(sjXepCMmsYjJKxohj(HLRSwCeq)WYft8WzYijNmsE5CKOOlJ8om4Rvj1xkj4cZojXzCLtI(WyfoeMDUqSkejMyUYldNeNXvo11QKsddr(iQNtYij1dlQ0IJa6hwUOEojJKupSOsu0LrE)qy54VwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRRSIkQKbnme5JOEojJKupSOslocOFy5cUWSts9WIkrrxg5D4zNleRcrIjMR8YWj)eeRHmfLK1vwrfXra9dlxWfMDsQhwujk6YiVFiSC8xzLxJy8GcVlWra9dlVFeSZsOIKQqCFmgLGvpNsrLtIpQJr6qiNlnK44Ez)Rfhb0pSCH6lLKFuhJ0HqoxAiXX9Y(xue)1qR6lLeFuhJ0HqoxAiXX9Y(xMqfj(HLRvVi7YC8xOPivrFudOznY2TGdMr1cmqXXlWcnzlW2o4fGslang2xaoUipFbp9f0JWfl4KMwaAwGfccAbQ0cED6Val0KTGJJXaz8cWCFwaAwqhcLNnqASavkffTgX4bfExGJa6hwE)iyNDrvfvxgj5e1L8XyucgocOFy5IjE4mzKKtgjVCosu0LrE)q7CHyvisCJrQxeMOVCI5kv1qrfvchb0pSCbxy2jPEyrLOOlJ8o8SZfIvHiXng5LHt(jiwdzkkjRRfhb0pSCXepCMmsYjJKxohjk6YiVdp7CHyvisCJrEz4KFcI1qMIsoXCvEnIXdk8Uahb0pS8(rWo7IQkQUmsYjQl5JXOemCeq)WYfCHzNK6HfvII4VgAvYGggI8rqoekpBiN(kQOsddr(iihcLNnKtFTx2zHoEGhSdk8vwzTkPeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lxgo5NGynKPOKtmxTQVusWfMDsIZ4kNe9HXkat9LscUWStsCgx5K4YWj7dJvqzfvujCeq)WYft8WzYijNmsE5CKOOlJ8om4Rv9LscUWStsCgx5KOpmwbyWxzL1Q(sjr9CsgjPEyrL4hwU2l7SqhpWdMDUqSkejyD5f5O77kVSZsD8Sgz7wGTbzXA0xWRtl4t8KPgLtlWcnzlG1fl4KMwWeZDbO(ckI)ASaUValccY4fCzfOf0FfTGjwaM7ZcqZcuPuu0cMyUI1igpOW7cCeq)WY7hb7SpXtMAuozmkbdhb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJv4qy25cXQqKyI5kVmCsCgx5uxlocOFy5cUWSts9WIkrrxg59dHLJ)RrmEqH3f4iG(HL3pc2zFINm1OCYyucgocOFy5cUWSts9WIkrrxg5DyWxRsg0WqKpcYHq5zd50xrfvAyiYhb5qO8SHC6R9Yol0Xd8GDqHVYkRvjLWra9dlxmXdNjJKCYi5LZrIIUmY7Wtt4Rv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNexgozFySckROIkHJa6hwUyIhotgj5KrYlNJefDzK3HbFTQVusWfMDsIZ4kNe9HXkad(kRSw1xkjQNtYij1dlQe)WY1EzNf64bEWSZfIvHibRlVihDFx5LDwQJN1iB3cmG60c66CPWcqPfmXCxa7)fW6lGlAbHVa8FbS)xGv4golqLwWtFbPOwau45uTGjJ9fmz0cUmCl4tqSggVGlRaYZxq)v0cSOfKX2PfWZcGiUplySIfWfMDAb4mUYP(cy)VGjJNfmXCxGf3DdNfCYXRpl41PVynIXdk8Uahb0pS8(rWoR4pI9r215sbJrjy4iG(HLlM4HZKrsozK8Y5irrxg5D4zNleRcrIQlVmCYpbXAitrjNyUAXra9dlxWfMDsQhwujk6YiVdp7CHyvisuD5LHt(jiwdzkkjRRvPHHiFe1ZjzKK6HfvAvchb0pSCr9CsgjPEyrLOOlJ8(HeCe(nKCqxsrfXra9dlxupNKrsQhwujk6YiVdp7CHyvisuD5LHt(jiwdzkkzf6kROIg0WqKpI65Kmss9WIkL1Q(sjbxy2jjoJRCs0hgRa8SH2pP(sjXepCMmsYjJKxohj(HLRv9LsI65Kmss9WIkXpSCTQVusWfMDsQhwuj(HLVgz7wGbuNwqxNlfwGfAYwaRVaRmYxGE07ivisSGtAAbtm3fG6lOi(RXc4(cSiiiJxWLvGwq)v0cMybyUplanlqLsrrlyI5kwJy8GcVlWra9dlVFeSZk(JyFKDDUuWyucgocOFy5IjE4mzKKtgjVCosu0LrE)qcoc)gsoOlPv9LscUWStsCgx5KOpmwHdHzNleRcrIjMR8YWjXzCLtDT4iG(HLl4cZoj1dlQefDzK3pujcoc)gsoOlDeJhu4IjE4mzKKtgjVCosqWr43qYbDjLxJy8GcVlWra9dlVFeSZk(JyFKDDUuWyucgocOFy5cUWSts9WIkrrxg59dj4i8Bi5GUKwLuYGggI8rqoekpBiN(kQOsddr(iihcLNnKtFTx2zHoEGhSdk8vwzTkPeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lxgo5NGynKPOKtmxTQVusWfMDsIZ4kNe9HXkat9LscUWStsCgx5K4YWj7dJvqzfvujCeq)WYft8WzYijNmsE5CKOOlJ8om4Rv9LscUWStsCgx5KOpmwbyWxzL1Q(sjr9CsgjPEyrL4hwU2l7SqhpWdMDUqSkejyD5f5O77kVSZsD8O8AKTBbgqDAbtm3fyHMSfW6laLwaAmSVal0KH8fmz0cUmCl4tqSgIfCstlWJX4f860cSqt2cQqFbO0cMmAbddr(SauFbdRa5gVa2)lang2xGfAYq(cMmAbxgUf8jiwdXAeJhu4DbocOFy59JGD2epCMmsYjJKxohzmkbt9LscUWStsCgx5KOpmwHdHzNleRcrIjMR8YWjXzCLtDT4iG(HLl4cZoj1dlQefDzK3pegbhHFdjh0L0EzNf64bE25cXQqKG1LxKJUVR8Yol1XJw1xkjQNtYij1dlQe)WYxJy8GcVlWra9dlVFeSZM4HZKrsozK8Y5iJrjyQVusWfMDsIZ4kNe9HXkCim7CHyvismXCLxgojoJRCQRDyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hcJGJWVHKd6sAXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLxgo5NGynKPOKSUwCeq)WYfCHzNK6HfvIIUmY7WttBSgX4bfExGJa6hwE)iyNnXdNjJKCYi5LZrgJsWuFPKGlm7KeNXvoj6dJv4qy25cXQqKyI5kVmCsCgx5uxRsg0WqKpI65Kmss9WIkfvehb0pSCr9CsgjPEyrLOOlJ8o8SZfIvHiXeZvEz4KFcI1qMIswHUYAXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLxgo5NGynKPOKS(AKTBbgqDAbS(cqPfmXCxaQVGWxa(Va2)lWkCdNfOsl4PVGuulak8CQwWKX(cMmAbxgUf8jiwdJxWLva55lO)kAbtgplWIwqgBNwa5XlpBbx25fW(FbtgplyYOIwaQVapMfWqfXFnwaVG650cI0c0dlQwWpSCXAeJhu4DbocOFy59JGDgxy2jPEyrLXOemCeq)WYft8WzYijNmsE5CKOOlJ8o8SZfIvHibRlVmCYpbXAitrjNyUAvYGWHDYzFe2jFY0OuurCeq)WYfxuvr1LrsorDjFefDzK3HNDUqSkejyD5LHt(jiwdzkk5ngL1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIldNSpmwbTQVusupNKrsQhwuj(HLR9Yol0Xd8GzNleRcrcwxEro6(UYl7SuhpRr2Ufya1PfuH(cqPfmXCxaQVGWxa(Va2)lWkCdNfOsl4PVGuulak8CQwWKX(cMmAbxgUf8jiwdJxWLva55lO)kAbtgv0cqD3Wzbmur8xJfWlOEoTGFy5lG9)cMmEwaRVaRWnCwGkHJlTa2oJGyviAb)xH88fupNeRrmEqH3f4iG(HL3pc2z1ZjzKK6HfvgJsWuFPKGlm7KupSOs8dlxRs4iG(HLlM4HZKrsozK8Y5irrxg5D4zNleRcrIk0Lxgo5NGynKPOKtmxfvehb0pSCbxy2jPEyrLOOlJ8(HWSZfIvHiXeZvEz4KFcI1qMIsY6kRv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNexgozFyScAXra9dlxWfMDsQhwujk6YiVdpnTXAeJhu4DbocOFy59JGDwpdLgKNl1dlQmgLGP(sjbxy2jPEyrL4hwUwCeq)WYfCHzNK6HfvIPEKSOlJ8o8y8Gcx0ZqPb55s9WIkb(xAvFPKOEojJKupSOs8dlxlocOFy5I65Kmss9WIkXupsw0LrEhEmEqHl6zO0G8CPEyrLa)lTFs9LsIjE4mzKKtgjVCos8dlFnY2TadOoTa94UGjwq32)i6GKwa7lGGBkEbS6cq(cMmAbob3SaCeq)WYxGfY)HLXl45quVVaf0OqSVGjJ8feoKgl4)kKNVaUWStlqpSOAb)hTGjwqwyTGl78cYEEEPXck(JyFwqxNlfwaQVgX4bfExGJa6hwE)iyNPxuNCmjJK8I8VXOeSHHiFe1ZjzKK6HfvAvFPKGlm7KupSOs801Q(sjr9CsgjPEyrLOOlJ8(H54V4YWTgX4bfExGJa6hwE)iyNPxuNCmjJK8I8VXOeSpP(sjXepCMmsYjJKxohjE6A)K6lLet8WzYijNmsE5CKOOlJ8(HmEqHl4cZojVOEhbrDbbhHFdjh0L0Aq4Wo5Spcf0OqSVgX4bfExGJa6hwE)iyNPxuNCmjJK8I8VXOem1xkjQNtYij1dlQepDTQVusupNKrsQhwujk6YiVFyo(lUmCAXra9dlxq2dmpOWffXFn0IJa6hwUyIhotgj5KrYlNJefDzK31Aq4Wo5Spcf0OqSVgTgX4bfExKqodjvFLFeSZ4cZojVOEhbrDJrjyQVusGHiUWCFqEUOigpgJZyKdtZ1igpOW7IeYziP6R8JGDgxy2jPke3N1igpOW7IeYziP6R8JGDgxy2jPkxfNtRrRr2UfCqKr(cQN7ipFbeAYOAbtgTatZfe1co(Gybquo5FUqu34fyrlWI9zbtSady7XcuPuu0cMmAbhhJb6mB7GxGfY)HLybgqDAbOzbCFb9i8fW9fCYIdEbzCFbjKJ6z0FbXRwGfzODAbDDYNfeVAb4mUYP(AeJhu4Drc1ZqEUm0jNkyK9aZdkCJrjykvpNsrLtIosplCzFI6QOI1ZPuu5KyOREumK0IlDL1QK6lLe1ZjzKK6HfvIFy5kQOEr2L54Vqtbxy2jPkxfNtkRfhb0pSCr9CsgjPEyrLOOlJ8(AKTBbN00cSidTtliHCupJ(liE1cWra9dlFbwi)hw9fW(FbDDYNfeVAb4mUYPUXlqVqrHg0bjTady7Xcc7uTaYovAmzipFbeuNwJy8GcVlsOEgYZLHo5uDeSZi7bMhu4gJsWggI8rupNKrsQhwuPfhb0pSCr9CsgjPEyrLOOlJ8UwCeq)WYfCHzNK6HfvIIUmY7AvFPKGlm7KupSOs8dlxR6lLe1ZjzKK6HfvIFy5A1lYUmh)fAk4cZojv5Q4CAnIXdk8UiH6zipxg6Kt1rWolHksQcX9Xyucw9Ckfvoj(OogPdHCU0qIJ7L9Vw1xkj(OogPdHCU0qIJ7L9VmvrFep91igpOW7IeQNH8CzOtovhb7Suf9r6HD2yucw9CkfvojYluhsdjcJWqK2l7SqhpWZMEI1igpOW7IeQNH8CzOtovhb7SpXtMAuozmkbZGQNtPOYjrhPNfUSprDxJy8GcVlsOEgYZLHo5uDeSZ4cZojJs1yucgocOFy5I65Kmss9WIkrr8xJ1igpOW7IeQNH8CzOtovhb7mUWStsviUpgJsWWra9dlxupNKrsQhwujkI)AOv9LscUWStsCgx5KOpmwHdvFPKGlm7KeNXvojUmCY(WyfwJy8GcVlsOEgYZLHo5uDeSZQNtYij1dlQwJSDl4KMwGfzyrlGNfCz4wqFySc9fePfyWg8cy)ValAbzSDYnCwWRt)fyGIJxGg0y8cEDAb8c6dJvybtSa9ISt(SG7ZXzipFnIXdk8UiH6zipxg6Kt1rWoJlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8Ov9LscmeXfM7dYZf9HXkat9LscmeXfM7dYZfxgozFyScAXHDYzFe2jFY0O0IJa6hwU4IQkQUmsYjQl5JOi(RXAKTBbNg1LHG0ybw0c0zuTa9yqHVGxNwGfAYwGTDWgVa13Sa0Salee0cG4(SaOWZxa5XlpBbPOwGAmzlyYOfCYIdEbS)xGTDWlWc5)WQVGNdr9(cQN7ipFbtgTatZfe1co(Gybquo5FUquFnIXdk8UiH6zipxg6Kt1rWotpgu4gJsWmiLQNtPOYjrhPNfUSprDvuX65ukQCsm0vpkgsAXLUYRrmEqH3fjupd55YqNCQoc2zFINm1OCYyucM6lLe1ZjzKK6HfvIFy5kQOEr2L54Vqtbxy2jPkxfNtRrmEqH3fjupd55YqNCQoc2zf)rSpYUoxkymkbt9LsI65Kmss9WIkXpSCfvuVi7YC8xOPGlm7KuLRIZP1igpOW7IeQNH8CzOtovhb7SlQQO6YijNOUKpgJsWuFPKOEojJKupSOs8dlxrf1lYUmh)fAk4cZojv5Q4CAncpOW7IeQNH8CzOtovhb7SjE4mzKKtgjVCoYyucM6lLe1ZjzKK6HfvIFy5kQOEr2L54Vqtbxy2jPkxfNtkQOEr2L54VqtXfvvuDzKKtuxYhfvuVi7YC8xOPO4pI9r215sbfvuVi7YC8xOP4t8KPgLtRrmEqH3fjupd55YqNCQoc2zCHzNK6HfvgJsW0lYUmh)fAkM4HZKrsozK8Y5O1iB3cmG60co4WaTGjwq32)i6GKwa7lGGBkEb2wHzNwW5qCFwW)vipFbtgTGJJXaDMTDWlWc5)WAbphI69fup3rE(cSTcZoTadyCwiwWjnTaBRWStlWagNfla1xWWqKp034fyrlaZUHZcEDAbhCyGwGfAYq(cMmAbhhJb6mB7GxGfY)H1cEoe17lWIwaYhQQN(SGjJwGTzGwaoJDNGmEb9ybwKHqqlOZ2PfGgXAeJhu4Drc1ZqEUm0jNQJGDMErDYXKmsYlY)gJsWmOHHiFeCHzNKeol0(j1xkjM4HZKrsozK8Y5iXtx7NuFPKyIhotgj5KrYlNJefDzK3peMsmEqHl4cZojvH4(ii4i8Bi5GUKbM6lLe6f1jhtYijVi)lUmCY(WyfuEnY2TGtAAbhCyGwqg3DdNfOsKVGxN(l4)kKNVGjJwWXXyGwGfY)HLXlWImecAbVoTa0SGjwq32)i6GKwa7lGGBkEb2wHzNwW5qCFwaYxWKrl4Kfh8z22bValK)dlXAeJhu4Drc1ZqEUm0jNQJGDMErDYXKmsYlY)gJsWuFPKGlm7KupSOs801Q(sjr9CsgjPEyrLOOlJ8(HWuIXdkCbxy2jPke3hbbhHFdjh0LmWuFPKqVOo5ysgj5f5FXLHt2hgRGYRrmEqH3fjupd55YqNCQoc2zCHzNKQqCFmgLG9Jru8hX(i76CPGOOlJ8o8oHIk(j1xkjk(JyFKDDUuqA)b5uXQii0OHOpmwb4b)1iB3coiOfyX(SGjwWLvGwq)v0cSOfKX2PfqE8YZwWLDEbPOwWKrlG8bv0cSTdEbwi)hwgVaYo5laLwWKrfzyFb9bbbTGbDPfu0LroYZxq4l4KfhSybN0XW(cchsJfOsZq1cMybQVYxWel4GKQybS)xGbS9ybO0cQN7ipFbtgTatZfe1co(Gybquo5FUquxSgX4bfExKq9mKNldDYP6iyNXfMDsQYvX5KXOemCeq)WYfCHzNK6HfvII4VgAVSZcD8COsga4FKsAcFdmCyNC2hHcAui2vwzTQVusWfMDsIZ4kNe9HXkat9LscUWStsCgx5K4YWj7dJvqRbvpNsrLtIosplCzFI6Q1GQNtPOYjXqx9OyiPfx6Rr2Ufya5quVVG65oYZxWKrlW2km70co556gUglaIYj)ZLggVGZ5Q4CAb9S4b9xGhZcuPf860Fb8SGjJwa5)fePfyBh8cqPfyaBpW8GcFbO(cIuAb4iG(HLVaUVGFf66ipFb4mUYP(cSqqql4YkqlanlyyfOfafEovlyIfO(kFbtwfV8Sfu0LroYZxWLDEnIXdk8UiH6zipxg6Kt1rWoJlm7KuLRIZjJrjyQVusWfMDsQhwujE6AvFPKGlm7KupSOsu0LrE)qy54VwLQNtPOYjbxy2jjYtihnAOOI4iG(HLli7bMhu4IIUmY7kVgz7wW5CvCoTGEw8G(lGHSyn6lqLwWKrlaI7ZcWCFwaYxWKrl4Kfh8cSq(pSwa3xWXXyGwGfccAbf1NOOfmz0cWzCLt9f01jFwJy8GcVlsOEgYZLHo5uDeSZ4cZojv5Q4CYyucM6lLe1ZjzKK6HfvINUw1xkj4cZoj1dlQe)WY1Q(sjr9CsgjPEyrLOOlJ8(HWYX)1igpOW7IeQNH8CzOtovhb7mUWStYlQ3rqu3yuc2NuFPKyIhotgj5KrYlNJepDTddr(i4cZojjCwOvj1xkj(epzQr5K4hwUIkY4bzNKKtxe1HPPYA)K6lLet8WzYijNmsE5CKOOlJ8o8y8GcxWfMDsEr9ocI6ccoc)gsoOlzmoJromnnM4csdjoJrUeLGP(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvujdAyiYhryNk9WIk6Rvj1xkjQNtYij1dlQepDfvehb0pSCbzpW8Gcxue)1qzLvEnY2Tad8oKglOpCnl41rE(cmydEb2MbAbwzKVaB7Gxqg3xGkr(cED6VgX4bfExKq9mKNldDYP6iyNXfMDsEr9ocI6gJsWuFPKadrCH5(G8CrrmE0IJa6hwUGlm7KupSOsu0LrExRsQVusupNKrsQhwujE6kQO6lLeCHzNK6HfvINUYgJZyKdtZ1igpOW7IeQNH8CzOtovhb7mUWStYOungLGP(sjbxy2jjoJRCs0hgRWHWSZfIvHiXeZvEz4K4mUYP(AeJhu4Drc1ZqEUm0jNQJGDgxy2jPke3hJrjyQVusupNKrsQhwujE6kQ4LDwOJh4P5jwJy8GcVlsOEgYZLHo5uDeSZi7bMhu4gJsWuFPKOEojJKupSOs8dlxR6lLeCHzNK6HfvIFy5gJ8HQ6Ppsuc2LDwOJh4bZMCcJr(qv90hj6EPpIhcMMRrmEqH3fjupd55YqNCQoc2zCHzNKQCvCoTgTgz7waJhu4Drgx3W1agMDmbjz8Gc3yucgJhu4cYEG5bfUaNXUtqipx7LDwOJh4bZMEI1iB3cmG60cmGThyEqHVauAbwKHfTaOWAbHVGl78cy)VaEbhhJb6mB7GxGfY)H1cq9fGJlYZxWtFnIXdk8UiJRB4ACeSZi7bMhu4gJsWUSZcD8CimnpHwCeq)WYft8WzYijNmsE5CKOOlJ8(HWuIGJWVHKd6shX4bfUyIhotgj5KrYlNJeeCe(nKCqxszT4iG(HLl4cZoj1dlQefDzK3peMseCe(nKCqx6igpOWft8WzYijNmsE5CKGGJWVHKd6shX4bfUGlm7KupSOsqWr43qYbDjL1Q(sjr9CsgjPEyrL4hwUw1xkj4cZoj1dlQe)WY1(j1xkjM4HZKrsozK8Y5iXpSCTg0pgrXFe7JSRZLcIIUmY7Rr2Ufya1PfyaBpW8GcFbO0cSidlAbqH1ccFbx25fW(Fb8cozXbValK)dRfG6lahxKNVGN(AeJhu4Drgx3W14iyNr2dmpOWngLGDzNf645qy2m81IJa6hwUOEojJKupSOsu0LrE)qykrWr43qYbDPJy8GcxupNKrsQhwuji4i8Bi5GUKYAXra9dlxmXdNjJKCYi5LZrIIUmY7hctjcoc)gsoOlDeJhu4I65Kmss9WIkbbhHFdjh0LoIXdkCrXFe7JSRZLcccoc)gsoOlPSwCeq)WYfCHzNK6HfvIIUmY7WZaa)1iB3co)HG(l4KNRB4ASG(Wyf6lif1cMmAbhhJb6mB7GxGfY)H1AeJhu4Drgx3W14iyNXfMDsEr9ocI6gJsWuFPKGlm7KmJRB4Ai6dJv4q1xkj4cZojZ46gUgIldNSpmwbT4iG(HLlk(JyFKDDUuqu0LrE)qykzJJuIGJWVHKd6shX4bfUO4pI9r215sbbbhHFdjh0LuwzT4iG(HLlM4HZKrsozK8Y5irrxg59dHPKnosjcoc)gsoOlDeJhu4II)i2hzxNlfeeCe(nKCqx6igpOWft8WzYijNmsE5CKGGJWVHKd6skRSwCeq)WYfCHzNK6HfvIIUmY7hctjBCKseCe(nKCqx6igpOWff)rSpYUoxkii4i8Bi5GU0rmEqHlM4HZKrsozK8Y5ibbhHFdjh0LoIXdkCbxy2jPEyrLGGJWVHKd6skRSX4mg5W0CnY2TGZFiO)co556gUglOpmwH(csrTGjJwWjlo4fyH8FyTgX4bfExKX1nCnoc2zCHzNKxuVJGOUXOem1xkj4cZojZ46gUgI(Wyfou9LscUWStYmUUHRH4YWj7dJvqlocOFy5I65Kmss9WIkrrxg59dHPKnosjcoc)gsoOlDeJhu4I65Kmss9WIkbbhHFdjh0LuwzT4iG(HLlk(JyFKDDUuqu0LrE)qykzJJuIGJWVHKd6shX4bfUOEojJKupSOsqWr43qYbDPJy8Gcxu8hX(i76CPGGGJWVHKd6skRSwCeq)WYft8WzYijNmsE5CKOOlJ8(HWuYghPebhHFdjh0LoIXdkCr9CsgjPEyrLGGJWVHKd6shX4bfUO4pI9r215sbbbhHFdjh0LoIXdkCXepCMmsYjJKxohji4i8Bi5GUKYkRfhb0pSCbxy2jPEyrLOOlJ8UX4mg5W0CnY2TGZFiO)co556gUglOpmwH(csrTGjJwGZkq)fCYmxGfY)H1AeJhu4Drgx3W14iyNXfMDsEr9ocI6gJsWuFPKGlm7KmJRB4Ai6dJv4q1xkj4cZojZ46gUgIldNSpmwbT4iG(HLlk(JyFKDDUuqu0LrE)qykzJJuIGJWVHKd6shX4bfUO4pI9r215sbbbhHFdjh0LuwzT4iG(HLl4cZoj1dlQefDzK3HhmBg(AXra9dlxupNKrsQhwujk6YiVdpy2m8ngNXihMMRrmEqH3fzCDdxJJGDwXFe7JSRZLcgJsWuFPKGlm7KmJRB4Ai6dJvaM6lLeCHzNKzCDdxdXLHt2hgRGwCeq)WYft8WzYijNmsE5CKOOlJ8(HeCe(nKCqxslocOFy5cUWSts9WIkrrxg59dHPebhHFdjh0LoIXdkCXepCMmsYjJKxohji4i8Bi5GUKYAVSZcD8apnpXAeJhu4Drgx3W14iyNnXdNjJKCYi5LZrgJsWuFPKGlm7KmJRB4Ai6dJvaM6lLeCHzNKzCDdxdXLHt2hgRGwCeq)WYfCHzNK6HfvIIUmY7hcJGJWVHKd6sA)Xik(JyFKDDUuqu0LrEFnIXdk8UiJRB4ACeSZ4cZoj1dlQmgLGP(sjbxy2jzgx3W1q0hgRam1xkj4cZojZ46gUgIldNSpmwbTFs9LsIjE4mzKKtgjVCos801Q(sjr9CsgjPEyrL4hw(AeJhu4Drgx3W14iyNvpNKrsQhwuzmkbt9LscUWStYmUUHRHOpmwbyQVusWfMDsMX1nCnexgozFyScAXra9dlxmXdNjJKCYi5LZrIIUmY7hctjcoc)gsoOlDeJhu4II)i2hzxNlfeeCe(nKCqxszT4iG(HLl4cZoj1dlQefDzK3HNba(AVSZcD8apy28jwJy8GcVlY46gUghb7SI)i2hzxNlfmgLGP(sjbxy2jzgx3W1q0hgRam1xkj4cZojZ46gUgIldNSpmwbT4iG(HLlM4HZKrsozK8Y5irrxg59dj4i8Bi5GUKw1xkjQNtYij1dlQep91igpOW7ImUUHRXrWoBIhotgj5KrYlNJmgLGP(sjbxy2jzgx3W1q0hgRam1xkj4cZojZ46gUgIldNSpmwbT4iG(HLl4cZoj1dlQefDzK3HNba(AvFPKOEojJKupSOs801(Jru8hX(i76CPGOOlJ8(AeJhu4Drgx3W14iyNvpNKrsQhwuzmkbdhb0pSCXepCMmsYjJKxohjk6YiVdpnHVwCeq)WYfCHzNK6HfvIIUmY7WZMHVw1xkj4cZoj1dlQe)WYxJy8GcVlY46gUghb7SI)i2hzxNlfmgLGP(sjbxy2jzgx3W1q0hgRam1xkj4cZojZ46gUgIldNSpmwbT4iG(HLl4cZoj1dlQefDzK3HhmBCcT4iG(HLlQNtYij1dlQefDzK3HhmBCcTQVusWfMDsMX1nCne9HXkat9LscUWStYmUUHRH4YWj7dJvq7LDwOJh4btZtSgz7wGbuNwWbhgOf8FfYZxGTDWliQfCYIdEbwi)hw9fmXcuFiO)cWzCLt9fWPHQf86ipFb2wHzNwW5CvCoTgX4bfExKX1nCnoc2z6f1jhtYijVi)Bmkbt9LscUWStsCgx5KOpmwHdvFPKGlm7KeNXvojUmCY(Wyf0Q(sjbxy2jjoJRCs0hgRa8GVw1xkj4cZoj1dlQefDzK3vur1xkj4cZojXzCLtI(Wyfou9LscUWStsCgx5K4YWj7dJvqR6lLeCHzNK4mUYjrFyScWd(AvFPKOEojJKupSOsu0LrEx7NuFPKyIhotgj5KrYlNJefDzK3xJy8GcVlY46gUghb7mUWStsviUpgJsWuFPKqVOo5ysgj5f5FXtFnIXdk8UiJRB4ACeSZ4cZojJs1yucM6lLeCHzNK4mUYjrFySchAdTQVusWfMDsQhwujE6RrmEqH3fzCDdxJJGDgxy2jzuQgJsWuFPKGlm7KeNXvoj6dJv4qBO1Guchb0pSCbxy2jPEyrLOOlJ8(HW0e(AXra9dlxmXdNjJKCYi5LZrIIUmY7hctt4Rfhb0pSCrXFe7JSRZLcIIUmY7hc7ekVgX4bfExKX1nCnoc2zCHzNKxuVJGOUXOem1xkj4cZojXzCLtI(WyfGNMAvFPKGlm7KmJRB4Ai6dJv4q1xkj4cZojZ46gUgIldNSpmwbJXzmYHP5AeJhu4Drgx3W14iyNXfMDsEr9ocI6gJsWWra9dlxWfMDsgLQOOlJ8(HgaTQVusWfMDsMX1nCne9HXkCO6lLeCHzNKzCDdxdXLHt2hgRGX4mg5W0CnIXdk8UiJRB4ACeSZ4cZojv5Q4CYyuc2NuFPKO4pI9r215sbP9hKtfRIGqJgI(WyfGzawJy8GcVlY46gUghb7mUWStsviUpgJsW(Xik(JyFKDDUuqu0LrEx7NuFPKyIhotgj5KrYlNJefDzK3HhbhHFdjh0L0Q0NuFPKO4pI9r215sbP9hKtfRIGqJgI(WyfGbFfv8tQVusu8hX(i76CPG0(dYPIvrqOrdrFySchAauEnIXdk8UiJRB4ACeSZ4cZojJs1yuc2pgrXFe7JSRZLcIIUmY7W7eA)K6lLef)rSpYUoxkiT)GCQyveeA0q0hgRam4Rv9LsI65Kmss9WIkXpS81igpOW7ImUUHRXrWoJlm7KufI7JXOeSFmII)i2hzxNlfefDzK3HhbhHFdjh0L0(j1xkjk(JyFKDDUuqA)b5uXQii0OHOpmwb4bFTFs9LsII)i2hzxNlfK2FqovSkccnAi6dJv4qdGw1xkjQNtYij1dlQe)WYxJy8GcVlY46gUghb7mUWStsvUkoNmgLGP(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIldNSpmwbTQVusWfMDsMX1nCne9HXkat9LscUWStYmUUHRH4YWj7dJvynIXdk8UiJRB4ACeSZi7bMhu4gJsWUSZcD8COMNynY2TGdImYxGknwe5lahb0pS8fyH8Fy1nEbw0cchsJfO(qq)fmXcspiOfGZ4kN6lGtdvl41rE(cSTcZoTad8L6AeJhu4Drgx3W14iyNXfMDsQcX9XyucM6lLeCHzNK4mUYjrFyScWtZ1iB3coP3l9r8qqASGUo5)fCYZ1nCnwqFySc9fyLr(cuPXIiFb4iG(HLValK)dR(AeJhu4Drgx3W14iyNXfMDsQYvX5KXOem1xkj4cZojZ46gUgI(WyfGh81AqkHJa6hwUGlm7KupSOsu0LrE)qyAcFT4iG(HLlM4HZKrsozK8Y5irrxg59dHPj81IJa6hwUO4pI9r215sbrrxg59dHDcLxJy8GcVlY46gUghb7mUWStYlQ3rqu3yCgJCyAUgTgX4bfExCd70L85iyNPcHCfKSRHXOeSByNUKpIpQpSJj4btt4VgX4bfExCd70L85iyNPxuNCmjJK8I8)AeJhu4DXnStxYNJGDgxy2j5f17iiQBmkb7g2Pl5J4J6d7y6qnH)AeJhu4DXnStxYNJGDgxy2jzuQRrmEqH3f3WoDjFoc2zjursviUpRrRrmEqH3fHo5ublHksQcX9Xyucw9Ckfvoj(OogPdHCU0qIJ7L9Vw1xkj(OogPdHCU0qIJ7L9VmvrFep91igpOW7IqNCQoc2zPk6J0d7SXOeS65ukQCsKxOoKgsegHHiTx2zHoEGNn9eRrmEqH3fHo5uDeSZ(epzQr50AeJhu4DrOtovhb7SI)i2hzxNlfmgLGDzNf64bEga4VgX4bfExe6Kt1rWoRNHsdYZL6HfvgJsWuFPKGlm7KupSOs8dlxlocOFy5cUWSts9WIkrrxg591igpOW7IqNCQoc2zxuvr1LrsorDjFwJy8GcVlcDYP6iyNnXdNjJKCYi5LZrRrmEqH3fHo5uDeSZ4cZoj1dlQwJy8GcVlcDYP6iyNvpNKrsQhwuzmkbt9LsI65Kmss9WIkXpS81iB3cmG60co4WaTGjwq32)i6GKwa7lGGBkEb2wHzNwW5qCFwW)vipFbtgTGJJXaDMTDWlWc5)WAbphI69fup3rE(cSTcZoTadyCwiwWjnTaBRWStlWagNfla1xWWqKp034fyrlaZUHZcEDAbhCyGwGfAYq(cMmAbhhJb6mB7GxGfY)H1cEoe17lWIwaYhQQN(SGjJwGTzGwaoJDNGmEb9ybwKHqqlOZ2PfGgXAeJhu4DrOtovhb7m9I6KJjzKKxK)ngLGzqddr(i4cZojjCwO9tQVusmXdNjJKCYi5LZrINU2pP(sjXepCMmsYjJKxohjk6YiVFimLy8GcxWfMDsQcX9rqWr43qYbDjdm1xkj0lQtoMKrsEr(xCz4K9HXkO8AKTBbN00co4WaTGmU7golqLiFbVo9xW)vipFbtgTGJJXaTalK)dlJxGfzie0cEDAbOzbtSGUT)r0bjTa2xab3u8cSTcZoTGZH4(SaKVGjJwWjlo4ZSTdEbwi)hwI1igpOW7IqNCQoc2z6f1jhtYijVi)Bmkbt9LscUWSts9WIkXtxR6lLe1ZjzKK6HfvIIUmY7hctjgpOWfCHzNKQqCFeeCe(nKCqxYat9Lsc9I6KJjzKKxK)fxgozFySckZ4bfExe6Kt1rWoJlm7KufI7JXOeSFmII)i2hzxNlfefDzK3H3juuXpP(sjrXFe7JSRZLcs7piNkwfbHgne9HXkap4VgX4bfExe6Kt1rWoJlm7KufI7JXOem1xkj0lQtoMKrsEr(x801(j1xkjM4HZKrsozK8Y5iXtx7NuFPKyIhotgj5KrYlNJefDzK3pegJhu4cUWStsviUpccoc)gsoOlTgz7wGTbzXA0xW5CvCoTaEwWKrlG8)cI0cSTdEbwzKVG65oYZxWKrlW2km70co556gUglaIYj)ZLgRrmEqH3fHo5uDeSZ4cZojv5Q4CYyucM6lLeCHzNK6HfvINUw1xkj4cZoj1dlQefDzK3pmh)1wpNsrLtcUWStsKNqoA0ynY2TaBdYI1OVGZ5Q4CAb8SGjJwa5)fePfmz0cozXbValK)dRfyLr(cQN7ipFbtgTaBRWStl4KNRB4ASaikN8pxASgX4bfExe6Kt1rWoJlm7KuLRIZjJrjyQVusupNKrsQhwujE6AvFPKGlm7KupSOs8dlxR6lLe1ZjzKK6HfvIIUmY7hclh)1wpNsrLtcUWStsKNqoA0ynIXdk8Ui0jNQJGDgxy2j5f17iiQBmkb7tQVusmXdNjJKCYi5LZrINU2HHiFeCHzNKeol0QK6lLeFINm1OCs8dlxrfz8GStsYPlI6W0uzTFs9LsIjE4mzKKtgjVCosu0LrEhEmEqHl4cZojVOEhbrDbbhHFdjh0LmgNXihMMgtCbPHeNXixIsWuFPKadrCH5(G8CjoJDNGe)WY1QK6lLeCHzNK6HfvINUIkQKbnme5JiStLEyrf91QK6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AOSYkVgX4bfExe6Kt1rWoJlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8ymoJromnxJy8GcVlcDYP6iyNXfMDsgLQXOem1xkj4cZojXzCLtI(WyfoeMDUqSkejMyUYldNeNXvo1xJy8GcVlcDYP6iyNXfMDsQcX9XyucM6lLe1ZjzKK6HfvINUIkEzNf64bEAEI1igpOW7IqNCQoc2zK9aZdkCJrjyQVusupNKrsQhwuj(HLRv9LscUWSts9WIkXpSCJr(qv90hjkb7Yol0Xd8GztoHXiFOQE6JeDV0hXdbtZ1igpOW7IqNCQoc2zCHzNKQCvCoTgTgz7waJhu4DrfdpOWpc2zy2XeKKXdkCJrjymEqHli7bMhu4cCg7obH8CTx2zHoEGhmB6j0QKbvpNsrLtIosplCzFI6QOIQVus0r6zHl7tuxrFyScWuFPKOJ0Zcx2NOUIldNSpmwbLxJy8GcVlQy4bf(rWoJShyEqHBmkb7Yol0XZHWSZfIvHibzpK64rRs4iG(HLlM4HZKrsozK8Y5irrxg59dHX4bfUGShyEqHli4i8Bi5GUKIkIJa6hwUGlm7KupSOsu0LrE)qymEqHli7bMhu4ccoc)gsoOlPOIknme5JOEojJKupSOslocOFy5I65Kmss9WIkrrxg59dHX4bfUGShyEqHli4i8Bi5GUKYkRv9LsI65Kmss9WIkXpSCTQVusWfMDsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5Ani9ISlZXFHMIjE4mzKKtgjVCoAnIXdk8UOIHhu4hb7mYEG5bfUXOeS65ukQCs0r6zHl7tuxT4iG(HLl4cZoj1dlQefDzK3pegJhu4cYEG5bfUGGJWVHKd6sRr2UfCoxfNtlaLwaAmSVGbDPfmXcEDAbtm3fW(Fbw0cYy70cMiwWLDnwaoJRCQVgX4bfExuXWdk8JGDgxy2jPkxfNtgJsWWra9dlxmXdNjJKCYi5LZrII4VgAvs9LscUWStsCgx5KOpmwb4zNleRcrIjMR8YWjXzCLtDT4iG(HLl4cZoj1dlQefDzK3pegbhHFdjh0L0EzNf64bE25cXQqKG1LxKJUVR8Yol1XJw1xkjQNtYij1dlQe)WYvEnIXdk8UOIHhu4hb7mUWStsvUkoNmgLGHJa6hwUyIhotgj5KrYlNJefXFn0QK6lLeCHzNK4mUYjrFyScWZoxiwfIetmx5LHtIZ4kN6AhgI8rupNKrsQhwuPfhb0pSCr9CsgjPEyrLOOlJ8(HWi4i8Bi5GUKwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRR8AeJhu4DrfdpOWpc2zCHzNKQCvCozmkbdhb0pSCXepCMmsYjJKxohjkI)AOvj1xkj4cZojXzCLtI(WyfGNDUqSkejMyUYldNeNXvo11QKbnme5JOEojJKupSOsrfXra9dlxupNKrsQhwujk6YiVdp7CHyvismXCLxgo5NGynKPOKvORSwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5LHt(jiwdzkkjRR8AeJhu4DrfdpOWpc2zCHzNKQCvCozmkb7tQVusu8hX(i76CPG0(dYPIvrqOrdrFyScW(K6lLef)rSpYUoxkiT)GCQyveeA0qCz4K9HXkOvj1xkj4cZoj1dlQe)WYvur1xkj4cZoj1dlQefDzK3pewo(RSwLuFPKOEojJKupSOs8dlxrfvFPKOEojJKupSOsu0LrE)qy54VYRrmEqH3fvm8Gc)iyNXfMDsQcX9Xyuc2pgrXFe7JSRZLcIIUmY7WZMOOIk9j1xkjk(JyFKDDUuqA)b5uXQii0OHOpmwb4bFTFs9LsII)i2hzxNlfK2FqovSkccnAi6dJv4WpP(sjrXFe7JSRZLcs7piNkwfbHgnexgozFySckVgX4bfExuXWdk8JGDgxy2jPke3hJrjyQVusOxuNCmjJK8I8V4PR9tQVusmXdNjJKCYi5LZrINU2pP(sjXepCMmsYjJKxohjk6YiVFimgpOWfCHzNKQqCFeeCe(nKCqxAnIXdk8UOIHhu4hb7mUWStYlQ3rqu3yuc2NuFPKyIhotgj5KrYlNJepDTddr(i4cZojjCwOvj1xkj(epzQr5K4hwUIkY4bzNKKtxe1HPPYAv6tQVusmXdNjJKCYi5LZrIIUmY7WJXdkCbxy2j5f17iiQli4i8Bi5GUKIkIJa6hwUqVOo5ysgj5f5Frrxg5Dfveh2jN9rOGgfIDLngNXihMMgtCbPHeNXixIsWuFPKadrCH5(G8CjoJDNGe)WY1QK6lLeCHzNK6HfvINUIkQKbnme5JiStLEyrf91QK6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AOSYkVgX4bfExuXWdk8JGDgxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4rR6lLeeC6S)PVupgYhedjE6RrmEqH3fvm8Gc)iyNXfMDsEr9ocI6gJsWuFPKadrCH5(G8CrrmE0QK6lLeCHzNK6HfvINUIkQ(sjr9CsgjPEyrL4PROIFs9LsIjE4mzKKtgjVCosu0LrEhEmEqHl4cZojVOEhbrDbbhHFdjh0Lu2yCgJCyAUgX4bfExuXWdk8JGDgxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4rR6lLeyiIlm3hKNl6dJvaM6lLeyiIlm3hKNlUmCY(WyfmgNXihMMRrmEqH3fvm8Gc)iyNXfMDsEr9ocI6gJsWuFPKadrCH5(G8CrrmE0Q(sjbgI4cZ9b55IIUmY7hctjLuFPKadrCH5(G8CrFyScgymEqHl4cZojVOEhbrDbbhHFdjh0Lu(OC8xzJXzmYHP5AeJhu4DrfdpOWpc2zonzujh6Qt9XyucMsfLkQNXQqKIkAqdcRaYZvwR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(Wyf0Q(sjbxy2jPEyrL4hwU2pP(sjXepCMmsYjJKxohj(HLVgX4bfExuXWdk8JGDgxy2jzuQgJsWuFPKGlm7KeNXvoj6dJv4qy25cXQqKyI5kVmCsCgx5uFnIXdk8UOIHhu4hb7S(tNkpSZgJsWUSZcD8CimB6j0Q(sjbxy2jPEyrL4hwUw1xkjQNtYij1dlQe)WY1(j1xkjM4HZKrsozK8Y5iXpS81igpOW7IkgEqHFeSZ4cZojvH4(ymkbt9LsI6brYijNSIOU4PRv9LscUWStsCgx5KOpmwb4zZRrmEqH3fvm8Gc)iyNXfMDsQYvX5KXOeSl7SqhphcZoxiwfIeQCvCojVSZsD8Ov9LscUWSts9WIkXpSCTQVusupNKrsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5AvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLHt2hgRGwCeq)WYfK9aZdkCrrxg591igpOW7IkgEqHFeSZ4cZojv5Q4CYyucM6lLeCHzNK6HfvIFy5AvFPKOEojJKupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WY1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIldNSpmwbTddr(i4cZojJsvlocOFy5cUWStYOuffDzK3pewo(R9Yol0XZHWSPWxlocOFy5cYEG5bfUOOlJ8(AeJhu4DrfdpOWpc2zCHzNKQCvCozmkbt9LscUWSts9WIkXtxR6lLeCHzNK6HfvIIUmY7hclh)1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIldNSpmwbTkHJa6hwUGShyEqHlk6YiVROI1ZPuu5KGlm7Ke5jKJgnuEnIXdk8UOIHhu4hb7mUWStsvUkoNmgLGP(sjr9CsgjPEyrL4PRv9LscUWSts9WIkXpSCTQVusupNKrsQhwujk6YiVFiSC8xR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojUmCY(Wyf0QeocOFy5cYEG5bfUOOlJ8UIkwpNsrLtcUWStsKNqoA0q51igpOW7IkgEqHFeSZ4cZojv5Q4CYyucM6lLeCHzNK6HfvIFy5AvFPKOEojJKupSOs8dlx7NuFPKyIhotgj5KrYlNJepDTFs9LsIjE4mzKKtgjVCosu0LrE)qy54Vw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsCz4K9HXkSgX4bfExuXWdk8JGDgxy2jPkxfNtgJsWgUYPrKrm0Kj0XZH28j0Q(sjbxy2jjoJRCs0hgRa8GPeJhKDssoDru3aNMkRTEoLIkNeCHzNKQXvLR)L8rlJhKDssoDruhEAQv9LsIpXtMAuoj(HLVgX4bfExuXWdk8JGDgxy2jjbNou0rHBmkbB4kNgrgXqtMqhphAZNqR6lLeCHzNK4mUYjrFySchQ(sjbxy2jjoJRCsCz4K9HXkOTEoLIkNeCHzNKQXvLR)L8rlJhKDssoDruhEAQv9LsIpXtMAuoj(HLVgX4bfExuXWdk8JGDgxy2jPke3N1igpOW7IkgEqHFeSZi7bMhu4gJsWuFPKOEojJKupSOs8dlxR6lLeCHzNK6HfvIFy5A)K6lLet8WzYijNmsE5CK4hw(AeJhu4DrfdpOWpc2zCHzNKQCvCo1M20Aa]] )


end
