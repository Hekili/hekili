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

    spec:RegisterSetting( "am_spam", 0, {
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


    spec:RegisterPack( "Arcane", 20210523, [[d0uLUgqike9ijrPlPIQs1MifFIuQrrbDkkWQKefVssywuuDljPO2fHFrcmmsOogPKLrrXZiHyAssvxtfv2MkQIVjjfghfLQZrcPwhfsnpjj3duTpsqhusuTqqPEifsUOkQsFufvLmssi5KQOQALuOEjfLYmPq4Muus7euYpPOenujPYsLKs9ukzQQOCvkkHVkjfzSsISxP6VenyGdJAXK0JHAYQ0Lr2SeFwfgTK60qwTkQkLxRImBqUTQA3u9BHHtQoUKuYYf9CPmDfxxv2of57uQXdkopjY6vrvX8jrTFLURv)SU1LhQdlZOyZOLIpNzueHIv0NtrR4Zt3AusN6w6m(eFqDlN)u3QYtm7u3sNvck4B)SUvlEjM6w1ZO3mAfOGd0u)uf44RGg6)G4bfoo5YOGg6Jvq3s9HGMZV3v7wxEOoSmJInJwk(CMrrekwrFofD3QPt4oSopMPBvJUxY7QDRl1WDlZkFqlOYtm70ASzLvAbMrrmFbMrXMrR1414Qn9dt0cmXjIvHib)LnD(VaKVGcBkYfeLf0Ozq(rtWFztN)lWqCnHpTaLIxUGMoHxqOpOWBgiwJnlA0cgL0rygAbwOVrTGA2Vqi)ybrzb4A2DcAbiFOmF6dk8fG82q8DbrzbAJzhtqsgpOW1w0TGqTP1pRBvZ5pCL6N1HLw9Z6wKZQq0Td7UfJhu4DlYuG5bfE36snCI0hu4DlZIgTGZRPaZdk8fGklWM0oPfaf2li8f8zNxa73fWl4SymRkOYRUfyJ8ByVauBb44J8Jf807w4enuI4U1NDwOJNfuf8fO15wGMfGJa6g2UyIhUwgf5utYpFGej9zK3wqvWxGHlGGHWVHKd6tlOIfW4bfUyIhUwgf5utYpFGeeme(nKCqFAbgSanlahb0nSDbNy2jPEytPiPpJ82cQc(cmCbeme(nKCqFAbvSagpOWft8W1YOiNAs(5dKGGHWVHKd6tlOIfW4bfUGtm7KupSPuqWq43qYb9PfyWc0Sa1xPiYNtYOi1dBkf3W2xGMfO(kfbNy2jPEytP4g2(c0SGlP(kfXepCTmkYPMKF(ajUHTVanlWixWngrYxe7JSPZ5jrsFg5T(0HLz6N1TiNvHOBh2DlgpOW7wKPaZdk8U1LA4ePpOW7wMfnAbNxtbMhu4lavwGnPDslakSxq4l4ZoVa2VlGxq1oQUfyJ8ByVauBb44J8Jf807w4enuI4U1NDwOJNfuf8fOikEbAwaocOBy7I85Kmks9WMsrsFg5Tfuf8fy4ciyi8Bi5G(0cQybmEqHlYNtYOi1dBkfeme(nKCqFAbgSanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGQGVadxabdHFdjh0NwqflGXdkCr(CsgfPEytPGGHWVHKd6tlOIfW4bfUi5lI9r2058KGGHWVHKd6tlWGfOzb4iGUHTl4eZoj1dBkfj9zK3wGcxq1R4(0HLI0pRBroRcr3oS7w4enuI4UfocOBy7IKVi2hztNZtIK(mYBlOk4lWmlOYSGd8DbvSatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbAwaocOBy7IjE4AzuKtnj)8bsK0NrEBbvbFbM4eXQqKWSPOK6j1ggFc5hYb9PfuXciyi8Bi5G(0cQybmEqHls(IyFKnDopjiyi8Bi5G(0c0SaCeq3W2fCIzNK6HnLIK(mYBlOk4lWeNiwfIeMnfLupP2W4ti)qoOpTGkwabdHFdjh0NwqflGXdkCrYxe7JSPZ5jbbdHFdjh0NwqflGXdkCXepCTmkYPMKF(ajiyi8Bi5G(0c0Sa1xPi4eZojX1CEqI2W4tlqHlqRfOzbQVsrWjMDsIR58GeTHXNwqvlO6xGMfyKlah(9HgbNy2jPEgx0HscYzvi62Ty8GcVBXjMDsQcXTPpDyv99Z6wKZQq0Td7UfordLiUBHJa6g2UiFojJIupSPuK0NrEBbvbFbMzbvMfCGVlOIfyIteRcrcZMIsQNuBy8jKFih0NwqflGGHWVHKd6tlOIfW4bfUiFojJIupSPuqWq43qYb9PfOzb4iGUHTls(IyFKnDopjs6ZiVTGQGVatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbvSagpOWf5ZjzuK6HnLccgc)gsoOpTanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGQGVatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbvSagpOWf5ZjzuK6HnLccgc)gsoOpTGkwaJhu4IKVi2hztNZtccgc)gsoOpTanlahb0nSDbNy2jPEytPiPpJ82c0Sa1xPi4eZojX1CEqI2W4tlqHlqRfOzbQVsrWjMDsIR58GeTHXNwqvlO6xGMfyKlah(9HgbNy2jPEgx0HscYzvi62Ty8GcVBXjMDsQcXTPpDyDU(zDlYzvi62HD3cNOHse3TWraDdBxK8fX(iB6CEsK0NrEBbvbFbMzbvMfCGVlOIfyIteRcrcZMIsQNuBy8jKFih0NwGMfGJa6g2UGtm7KupSPuK0NrEBbke(cuefVanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGkwGIO4fuf8fGJa6g2UGtm7KupSPuK0NrEBbAwaocOBy7I85Kmks9WMsrsFg5TfuXcuefVGQGVaCeq3W2fCIzNK6HnLIK(mYBlqZcuFLIGtm7KexZ5bjAdJpTafUaTwGMfO(kfbNy2jjUMZds0ggFAbvTGQFbAwGrUaC43hAeCIzNK6zCrhkjiNvHOB3IXdk8UfNy2jPke3M(0H15PFw3ICwfIUDy3TWjAOeXDlCeq3W2fjFrSpYMoNNej9zK3wqvWxWb(UGkwGjorSkejmBkkPEsTHXNq(HCqFAbvSacgc)gsoOpTanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGQGVatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbvSagpOWfjFrSpYMoNNeeme(nKCqFAbAwaocOBy7coXSts9WMsrsFg5Tfuf8fyIteRcrcZMIsQNuBy8jKFih0NwqflGGHWVHKd6tlOIfW4bfUi5lI9r2058KGGHWVHKd6tlOIfW4bfUyIhUwgf5utYpFGeeme(nKCqFAbAwG6RueCIzNK4AopirBy8PfOWfOv3IXdk8UfNy2jPkNjFq9PdRQr)SUf5SkeD7WUBHt0qjI7w4iGUHTlYNtYOi1dBkfj9zK3wqvWxWb(UGkwGjorSkejmBkkPEsTHXNq(HCqFAbvSacgc)gsoOpTGkwaJhu4I85Kmks9WMsbbdHFdjh0NwGMfGJa6g2Ui5lI9r2058KiPpJ82cQc(cmXjIvHiHztrj1tQnm(eYpKd6tlOIfqWq43qYb9PfuXcy8GcxKpNKrrQh2ukiyi8Bi5G(0c0SaCeq3W2ft8W1YOiNAs(5dKiPpJ82cQc(cmXjIvHiHztrj1tQnm(eYpKd6tlOIfqWq43qYb9PfuXcy8GcxKpNKrrQh2ukiyi8Bi5G(0cQybmEqHls(IyFKnDopjiyi8Bi5G(0c0SaCeq3W2fCIzNK6HnLIK(mYBlqZcuFLIGtm7KexZ5bjAdJpTafUaT6wmEqH3T4eZojv5m5dQpDyz27N1TiNvHOBh2DlCIgkrC3chb0nSDrYxe7JSPZ5jrsFg5Tfuf8fCGVlOIfyIteRcrcZMIsQNuBy8jKFih0NwGMfGJa6g2UGtm7KupSPuK0NrEBbke(cuefVanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGkwGIO4fuf8fGJa6g2UGtm7KupSPuK0NrEBbAwaocOBy7I85Kmks9WMsrsFg5TfuXcuefVGQGVaCeq3W2fCIzNK6HnLIK(mYBlqZcuFLIGtm7KexZ5bjAdJpTafUaTwGMfyKlah(9HgbNy2jPEgx0HscYzvi62Ty8GcVBXjMDsQYzYhuF6Wsr3pRBroRcr3oS7wxQHtK(GcVBb7hc6UaffN)WvAbTHXNAlOe5cMAAbNfJzvbvE1TaBKFd7UfordLiUBP(kfbNy2jznN)Wvs0ggFAbvTa1xPi4eZojR58hUsIpdJSnm(0c0SaCeq3W2fjFrSpYMoNNej9zK3wqvWxGjorSkejmBkkPEsTHXNq(HCqFAbvSacgc)gsoOpTanlahb0nSDXepCTmkYPMKF(ajs6ZiVTGQGVatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbvSagpOWfjFrSpYMoNNeeme(nKCqFAbAwaocOBy7coXSts9WMsrsFg5Tfuf8fyIteRcrcZMIsQNuBy8jKFih0NwqflGGHWVHKd6tlOIfW4bfUi5lI9r2058KGGHWVHKd6tlOIfW4bfUyIhUwgf5utYpFGeeme(nKCqFQBHRzK3T0QBX4bfE3Itm7K8JAnee16thwAP4(zDlYzvi62HD36snCI0hu4Dly)qq3fOO48hUslOnm(uBbLixWutlOAhv3cSr(nS7w4enuI4UL6RueCIzNK1C(dxjrBy8Pfu1cuFLIGtm7KSMZF4kj(mmY2W4tlqZcWraDdBxKpNKrrQh2uks6ZiVTGQGVatCIyvisy2uus9KAdJpH8d5G(0cQybeme(nKCqFAbvSagpOWf5ZjzuK6HnLccgc)gsoOpTanlahb0nSDrYxe7JSPZ5jrsFg5Tfuf8fyIteRcrcZMIsQNuBy8jKFih0NwqflGGHWVHKd6tlOIfW4bfUiFojJIupSPuqWq43qYb9PfOzb4iGUHTlM4HRLrro1K8ZhirsFg5Tfuf8fyIteRcrcZMIsQNuBy8jKFih0NwqflGGHWVHKd6tlOIfW4bfUiFojJIupSPuqWq43qYb9PfuXcy8GcxK8fX(iB6CEsqWq43qYb9PfOzb4iGUHTl4eZoj1dBkfj9zK36w4Ag5DlT6wmEqH3T4eZoj)OwdbrT(0HLwA1pRBroRcr3oS7wxQHtK(GcVBb7hc6UaffN)WvAbTHXNAlOe5cMAAboFIUlOABTaBKFd7UfordLiUBP(kfbNy2jznN)Wvs0ggFAbvTa1xPi4eZojR58hUsIpdJSnm(0c0SaCeq3W2fjFrSpYMoNNej9zK3wqvWxGjorSkejmBkkPEsTHXNq(HCqFAbvSacgc)gsoOpTGkwaJhu4IKVi2hztNZtccgc)gsoOpTanlahb0nSDbNy2jPEytPiPpJ82cui8fOikEbAwaocOBy7I85Kmks9WMsrsFg5TfOq4lqru8c0SaJCb4WVp0i4eZoj1Z4IousqoRcr3UfUMrE3sRUfJhu4DloXStYpQ1qquRpDyPLz6N1TiNvHOBh2DlCIgkrC3s9vkcoXStsCnNhKOnm(0cQAbMzbAwG6RueCIzNK1C(dxjrBy8PfaFbQVsrWjMDswZ5pCLeFggzBy8PfOzb4iGUHTlM4HRLrro1K8ZhirsFg5Tfu1ciyi8Bi5G(0c0SaCeq3W2fCIzNK6HnLIK(mYBlOk4lWWfqWq43qYb9PfuXcy8GcxmXdxlJICQj5Npqccgc)gsoOpTadwGMf8zNf64zbkCbADUUfJhu4DRKVi2hztNZt9PdlTuK(zDlYzvi62HD3cNOHse3TuFLIGtm7KexZ5bjAdJpTGQwGzwGMfO(kfbNy2jznN)Wvs0ggFAbWxG6RueCIzNK1C(dxjXNHr2ggFAbAwaocOBy7coXSts9WMsrsFg5Tfuf8fqWq43qYb9PfOzb3yejFrSpYMoNNej9zK36wmEqH3TM4HRLrro1K8ZhO(0HLwvF)SUf5SkeD7WUBHt0qjI7wQVsrWjMDswZ5pCLeTHXNwa8fO(kfbNy2jznN)Wvs8zyKTHXNwGMfCj1xPiM4HRLrro1K8ZhiXtFbAwG6Rue5ZjzuK6HnLIBy7DlgpOW7wCIzNK6HnL9PdlTox)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsIR58GeTHXNwqvlWmlqZcuFLIGtm7KSMZF4kjAdJpTa4lq9vkcoXStYAo)HRK4ZWiBdJpTanlahb0nSDrYxe7JSPZ5jrsFg5Tfuf8fqWq43qYb9PfOzb4iGUHTlM4HRLrro1K8ZhirsFg5Tfuf8fy4ciyi8Bi5G(0cQybmEqHls(IyFKnDopjiyi8Bi5G(0cmybAwaocOBy7coXSts9WMsrsFg5TfOWfu9NBbvSatCIyvisy2uuYlbXkbH(Orw5v3c0SGp7SqhplqHWxGICUUfJhu4DR85Kmks9WMY(0HLwNN(zDlYzvi62HD3cNOHse3TuFLIGtm7KexZ5bjAdJpTGQwGzwGMfO(kfbNy2jznN)Wvs0ggFAbWxG6RueCIzNK1C(dxjXNHr2ggFAbAwaocOBy7IjE4AzuKtnj)8bsK0NrEBbvTacgc)gsoOpTanlq9vkI85Kmks9WMsXtVBX4bfE3k5lI9r2058uF6WsRQr)SUf5SkeD7WUBHt0qjI7wQVsrWjMDswZ5pCLeTHXNwa8fO(kfbNy2jznN)Wvs8zyKTHXNwGMfO(kfr(CsgfPEytP4PVanl4gJi5lI9r2058KiPpJ8w3IXdk8U1epCTmkYPMKF(a1NoS0YS3pRBroRcr3oS7w4enuI4ULHlahb0nSDXepCTmkYPMKF(ajs6ZiVTGkwq1FUfyWcQc(cWraDdBxWjMDsQh2uks6ZiVTanlq9vkcoXSts9WMsXnS9fOzbg5cWHFFOrWjMDsQNXfDOKGCwfIUDlgpOW7w5ZjzuK6HnL9PdlTu09Z6wKZQq0Td7UfordLiUBP(kfbNy2jznN)Wvs0ggFAbWxG6RueCIzNK1C(dxjXNHr2ggFAbAwaocOBy7coXSts9WMsrsFg5TfOq4lqru8c0SaCeq3W2ft8W1YOiNAs(5dKiPpJ82cQybkIIxqvWxaocOBy7coXSts9WMsrsFg5TfOzb4iGUHTlYNtYOi1dBkfj9zK3wqflqru8cQc(cWraDdBxWjMDsQh2uks6ZiVTanl4Zol0XZcui8fO15wGMfyKlah(9HgbNy2jPEgx0HscYzvi62Ty8GcVBL8fX(iB6CEQpDyzgf3pRBroRcr3oS7w4enuI4U1ngrYxe7JSPZ5jrsFg5TfOWfCUfOzbxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNwa8fO4fOzbQVsrKpNKrrQh2ukUHT3Ty8GcVBXjMDsgPAF6WYmA1pRBroRcr3oS7w4enuI4U1LuFLIi5lI9r2058K00dYPKvrqOrjrBy8PfaFbvF3IXdk8UfNy2jPkNjFq9PdlZyM(zDlYzvi62HD3cNOHse3TUXis(IyFKnDopjs6ZiVTanl4sQVsrmXdxlJICQj5NpqIK(mYBlqHlGGHWVHKd6tlqZcmCbxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNwa8fO4fOSYl4sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(0cQAbv)cmybAwGrUa9KmjpWxHwcoXStsvot(G6wmEqH3T4eZojvH420NoSmJI0pRBroRcr3oS7w4enuI4U1ngrYxe7JSPZ5jrsFg5TfOWfqWq43qYb9PfOzbxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNwGcxGIxGMfCj1xPis(IyFKnDopjn9GCkzveeAus0ggFAbvTGQFbAwG6Rue5ZjzuK6HnLIBy7DlgpOW7wCIzNKQqCB6thwMP67N1TiNvHOBh2DlCIgkrC3s9vkcoXStsCnNhKOnm(0cQAbMzbAwG6RueCIzNK6HnLINE3IXdk8UfNy2jzKQ9PdlZCU(zDlYzvi62HD3IXdk8UfNy2j5h1AiiQ1TW1mY7wA1TWjAOeXDl1xPiWqeNyUni)qKeJNfOzbQVsrWjMDsQh2ukE69PdlZCE6N1TiNvHOBh2DlgpOW7w6j1ihtYOi)i)2TUudNi9bfE3YSOrlO6cZ6cUVe5hlOYRUfe5cQ2r1TaBKFd72cMybQpe0Db4AopO2c4Yq5cEnKFSGkpXStla2CM8b1TWjAOeXDl1xPi4eZojX1CEqI2W4tlOQfO(kfbNy2jjUMZds8zyKTHXNwGMfO(kfbNy2jjUMZds0ggFAbkCbkEbAwG6RueCIzNK6HnLIK(mYBlqzLxG6RueCIzNK4AopirBy8Pfu1cuFLIGtm7KexZ5bj(mmY2W4tlqZcuFLIGtm7KexZ5bjAdJpTafUafVanlq9vkI85Kmks9WMsrsFg5TfOzbxs9vkIjE4AzuKtnj)8bsK0NrERpDyzMQr)SUf5SkeD7WUBHt0qjI7wQVsrONuJCmjJI8J8R4PVanlq9vkcoXStsCnNhKOnm(0cu4c0QBX4bfE3Itm7KufIBtF6WYmM9(zDlYzvi62HD3cNOHse3TuFLIGtm7KexZ5bjAdJpTGQwGzwGMfGJa6g2UGtm7KupSPuK0NrEBbke(cmJIxq18cm7lOYSGd8DbAwGrUadxaocOBy7IKVi2hztNZtIK(mYBlOk4lqlfVanlahb0nSDbNy2jPEytPiPpJ82cui8funo3cmOBX4bfE3Itm7Kms1(0HLzu09Z6wKZQq0Td7UfordLiUBP(kfbNy2jjUMZds0ggFAbvTaZSanlahb0nSDbNy2jPEytPiPpJ82cui8fygfVGQ5fy2xqLzbh47c0SaC43hAeCIzNK6zCrhkjiNvHOB3IXdk8UfNy2jzKQ9PdlfrX9Z6wKZQq0Td7UfJhu4DloXStYpQ1qquRBHRzK3T0QBHt0qjI7wQVsrWjMDsIR58GeTHXNwGcxGwlqZcuFLIGtm7KSMZF4kjAdJpTGQwG6RueCIzNK1C(dxjXNHr2ggFQpDyPiA1pRBroRcr3oS7wmEqH3T4eZoj)OwdbrTUfUMrE3sRUfordLiUBHJa6g2UGtm7KmsvrsFg5Tfu1cQ(fOzbQVsrWjMDswZ5pCLeTHXNwqvlq9vkcoXStYAo)HRK4ZWiBdJp1NoSueZ0pRBroRcr3oS7w4enuI4UL6RueCIzNK4AopirBy8PfaFbQVsrWjMDsIR58GeFggzBy8PfOzbQVsrWjMDswZ5pCLeTHXNwa8fO(kfbNy2jznN)Wvs8zyKTHXN6wmEqH3T4eZojv5m5dQpDyPiks)SUf5SkeD7WUBHt0qjI7wF2zHoEwqvlqRZ1Ty8GcVBrMcmpOW7thwks13pRBroRcr3oS7wmEqH3T4eZojvH420TUudNi9bfE3QAQM8fOsJnr(cWraDdBFb2i)g2nZxGnTGWHuAbQpe0DbtSGYdcAb4AopO2c4Yq5cEnKFSGkpXStlWSmv7w4enuI4UL6RueCIzNK4AopirBy8PfOWfOvF6Wsrox)SUf5SkeD7WUBHRzK3T0QBX4bfE3Itm7K8JAnee16tF6wfuRg5hYqNCk7N1HLw9Z6wKZQq0Td7UfJhu4DlYuG5bfE36snCI0hu4DRQPAYxq(Ch5hlGqtnLlyQPfyzTGixWzvtlaIoi)YjIAMVaBAb2SplyIfCEnflqLkrslyQPfCwmMvfu5v3cSr(nSflWSOrlanlGBlOfHVaUTGQDuDlOMBlOGCuRMUliE5cSjTnrlOPt(SG4LlaxZ5b16w4enuI4ULHliFovI8GenKED4Y2e5xqoRcr3fOSYliFovI8Ged91JKHK2CQliNvHO7cmybAwGHlq9vkI85Kmks9WMsXnS9fOSYlqpjtYd8vOLGtm7KuLZKpOfyWc0SaCeq3W2f5ZjzuK6HnLIK(mYB9PdlZ0pRBroRcr3oS7wmEqH3TitbMhu4DRl1WjsFqH3To)LfytABIwqb5OwnDxq8YfGJa6g2(cSr(nSBlG97cA6KpliE5cW1CEqnZxGEIIenOZhAbNxtXcctuUaYeLkn1i)ybeuJ6w4enuI4U1WqKpI85Kmks9WMsb5SkeDxGMfGJa6g2UiFojJIupSPuK0NrEBbAwaocOBy7coXSts9WMsrsFg5TfOzbQVsrWjMDsQh2ukUHTVanlq9vkI85Kmks9WMsXnS9fOzb6jzsEGVcTeCIzNKQCM8b1NoSuK(zDlYzvi62HD3cNOHse3TYNtLipiXf1WiDiKZPssC8)SFfKZQq0DbAwG6RuexudJ0HqoNkjXX)Z(vwYOnINE3IXdk8UvbLKufIBtF6WQ67N1TiNvHOBh2DlCIgkrC3kFovI8GehjQbPKeHryisqoRcr3fOzbF2zHoEwGcxGI(CDlgpOW7wLmAJ0dtCF6W6C9Z6wKZQq0Td7UfordLiUBzKliFovI8GenKED4Y2e5xqoRcr3fOzbg5cYNtLipiXqF9iziPnN6cYzvi62Ty8GcVBDjEQvJ0P(0H15PFw3ICwfIUDy3TWjAOeXDlCeq3W2f5ZjzuK6HnLIK4RsDlgpOW7wCIzNKrQ2NoSQg9Z6wKZQq0Td7UfordLiUBHJa6g2UiFojJIupSPuKeFvAbAwG6RueCIzNK4AopirBy8Pfu1cuFLIGtm7KexZ5bj(mmY2W4tDlgpOW7wCIzNKQqCB6thwM9(zDlgpOW7w5ZjzuK6HnLDlYzvi62HDF6Wsr3pRBroRcr3oS7wmEqH3T4eZoj)OwdbrTU1LA4ePpOW7wN)YcSjTtAb8SGpdZcAdJp1wquwGrzulG97cSPfuZMix7zbVgDxGznoBbkrJ5l41OfWlOnm(0cMyb6jzI8zb)NJRr(r3cNOHse3TuFLIadrCI52G8drsmEwGMfO(kfbgI4eZTb5hI2W4tla(cuFLIadrCI52G8dXNHr2ggFAbAwaomro7JWe5tTs5c0SaCeq3W2fFuMr2Krror(jFejXxL6thwAP4(zDlYzvi62HD3cNOHse3TmYfy4cYNtLipirdPxhUSnr(fKZQq0DbkR8cYNtLipiXqF9iziPnN6cYzvi6Uad6wxQHtK(GcVBbRi)meKslWMwGoJYfOhdk8f8A0cSrt9cQ8QZ8fO(MfGMfyJGGwae3Mfaf(XcipEh1lOe5cuJPEbtnTGQDuDlG97cQ8QBb2i)g2Tf8CiQ1wq(Ch5hlyQPfyzTGixWzvtlaIoi)YjIADlgpOW7w6XGcVpDyPLw9Z6wKZQq0Td7UfordLiUBP(kfr(CsgfPEytP4g2(cuw5fONKj5b(k0sWjMDsQYzYhu3IXdk8U1L4PwnsN6thwAzM(zDlYzvi62HD3cNOHse3TuFLIiFojJIupSPuCdBFbkR8c0tYK8aFfAj4eZojv5m5dQBX4bfE3k5lI9r2058uF6WslfPFw3ICwfIUDy3TWjAOeXDl1xPiYNtYOi1dBkf3W2xGYkVa9KmjpWxHwcoXStsvot(G6wmEqH3T(OmJSjJICI8t(0NoS0Q67N1TiNvHOBh2DlCIgkrC3s9vkI85Kmks9WMsXnS9fOSYlqpjtYd8vOLGtm7KuLZKpOfOSYlqpjtYd8vOL4JYmYMmkYjYp5Zcuw5fONKj5b(k0sK8fX(iB6CEAbkR8c0tYK8aFfAjUep1Qr6u3IXdk8U1epCTmkYPMKF(a1NoS06C9Z6wKZQq0Td7UfordLiUBPNKj5b(k0smXdxlJICQj5NpqDlgpOW7wCIzNK6HnL9PdlTop9Z6wKZQq0Td7UfJhu4Dl9KAKJjzuKFKF7wxQHtK(GcVBzw0OfuDHzDbtSGw16r05dTa2xabZK8cQ8eZoTaydXTzb3xI8Jfm10colgZQcQ8QBb2i)g2l45quRTG85oYpwqLNy2PfCEX1HybN)YcQ8eZoTGZlUowaQTGHHiFOR5lWMwaMDTNf8A0cQUWSUaB0uJ8fm10colgZQcQ8QBb2i)g2l45quRTaBAbiFOmF6ZcMAAbvUzDb4A2DcY8f0IfytAdbTGgBIwaAeDlCIgkrC3YixWWqKpcoXStscxhcYzvi6Uanl4sQVsrmXdxlJICQj5NpqIN(c0SGlP(kfXepCTmkYPMKF(ajs6ZiVTGQGVadxaJhu4coXStsviUnccgc)gsoOpTGkZcuFLIqpPg5ysgf5h5xXNHr2ggFAbg0NoS0QA0pRBroRcr3oS7wmEqH3T0tQroMKrr(r(TBDPgor6dk8U15VSGQlmRlOMBU2ZcujYxWRr3fCFjYpwWutl4SymRlWg53W28fytAdbTGxJwaAwWelOvTEeD(qlG9fqWmjVGkpXStla2qCBwaYxWutlOAhvNcQ8QBb2i)g2IUfordLiUBP(kfbNy2jPEytP4PVanlq9vkI85Kmks9WMsrsFg5Tfuf8fy4cy8GcxWjMDsQcXTrqWq43qYb9PfuzwG6Rue6j1ihtYOi)i)k(mmY2W4tlWG(0HLwM9(zDlYzvi62HD3cNOHse3TUXis(IyFKnDopjs6ZiVTafUGZTaLvEbxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNwGcxGI7wmEqH3T4eZojvH420NoS0sr3pRBroRcr3oS7wmEqH3T4eZojv5m5dQBDPgor6dk8Uv1eTaB2NfmXc(8jAbTxslWMwqnBIwa5X7OEbF25fuICbtnTaYhuslOYRUfyJ8ByB(citKVauzbtnLK2Tf0gee0cg0NwqsFg5i)ybHVGQDuDIfC(hTBliCiLwGkndLlyIfO(sFbtSGZhkJfW(DbNxtXcqLfKp3r(XcMAAbwwliYfCw10cGOdYVCIOMOBHt0qjI7w4iGUHTl4eZoj1dBkfjXxLwGMf8zNf64zbvTadxq1R4fuXcmCbAP4fuzwaomro7J4KsjI9fyWcmybAwG6RueCIzNK4AopirBy8PfaFbQVsrWjMDsIR58GeFggzBy8PfOzbg5cYNtLipirdPxhUSnr(fKZQq0DbAwGrUG85ujYdsm0xpsgsAZPUGCwfIU9PdlZO4(zDlYzvi62HD3IXdk8UfNy2jPkNjFqDRl1WjsFqH3TmlCiQ1wq(Ch5hlyQPfu5jMDAbkko)HR0cGOdYVCQK5la2CM8bTGwD8GUlWJzbQ0cEn6UaEwWutlG87cIYcQ8QBbOYcoVMcmpOWxaQTGOuwaocOBy7lGBl4MHUoYpwaUMZdQTaBee0c(8jAbOzbdFIwau4huUGjwG6l9fm1z8oQxqsFg5i)ybF25UfordLiUBP(kfbNy2jPEytP4PVanlq9vkcoXSts9WMsrsFg5Tfuf8fCGVlqZcmCb5ZPsKhKGtm7Ke5fKJgLeKZQq0DbkR8cWraDdBxqMcmpOWfj9zK3wGb9PdlZOv)SUf5SkeD7WUBX4bfE3Itm7KuLZKpOU1LA4ePpOW7wWMZKpOf0QJh0DbmKnRuBbQ0cMAAbqCBwaMBZcq(cMAAbv7O6wGnYVH9c42colgZ6cSrqqliP2ejTGPMwaUMZdQTGMo5t3cNOHse3TuFLIiFojJIupSPu80xGMfO(kfbNy2jPEytP4g2(c0Sa1xPiYNtYOi1dBkfj9zK3wqvWxWb(2NoSmJz6N1TiNvHOBh2DlCnJ8ULwDlItiLK4Ag5suPBP(kfbgI4eZTb5hsCn7objUHTRXq1xPi4eZoj1dBkfpDLv2qJCyiYhryIs9WMs6QXq1xPiYNtYOi1dBkfpDLvghb0nSDbzkW8GcxKeFvYadmOBHt0qjI7wxs9vkIjE4AzuKtnj)8bs80xGMfmme5JGtm7KKW1HGCwfIUlqZcmCbQVsrCjEQvJ0jXnS9fOSYlGXdYejjN(iQTa4lqRfyWc0SGlP(kfXepCTmkYPMKF(ajs6ZiVTafUagpOWfCIzNKFuRHGOMGGHWVHKd6tDlgpOW7wCIzNKFuRHGOwF6WYmks)SUf5SkeD7WUBDPgor6dk8ULzPdP0cAdNZcEnKFSaJYOwqLBwxGDn5lOYRUfuZTfOsKVGxJUDlCIgkrC3s9vkcmeXjMBdYpejX4zbAwaocOBy7coXSts9WMsrsFg5TfOzbgUa1xPiYNtYOi1dBkfp9fOSYlq9vkcoXSts9WMsXtFbg0TW1mY7wA1Ty8GcVBXjMDs(rTgcIA9PdlZu99Z6wKZQq0Td7UfordLiUBP(kfbNy2jjUMZds0ggFAbvbFbM4eXQqKyI5l)mmsCnNhuRBX4bfE3Itm7Kms1(0HLzox)SUf5SkeD7WUBHt0qjI7wQVsrKpNKrrQh2ukE6lqzLxWNDwOJNfOWfO156wmEqH3T4eZojvH420NoSmZ5PFw3ICwfIUDy3Ty8GcVBrMcmpOW7wiFOmF6Jev6wF2zHoEuiCZ(56wiFOmF6Je9)0fXd1T0QBHt0qjI7wQVsrKpNKrrQh2ukUHTVanlq9vkcoXSts9WMsXnS9(0HLzQg9Z6wmEqH3T4eZojv5m5dQBroRcr3oS7tF6wxQWpOPFwhwA1pRBX4bfE3chpFOSPtqqDlYzvi62HDF6WYm9Z6wKZQq0Td7UvO3TA00Ty8GcVBzIteRcrDltm0J6wA1TWjAOeXDltCIyvisuZMizOtoDxa8fO4fOzb6jzsEGVcTeKPaZdk8fOzbg5cmCb5ZPsKhKOH0Rdx2Mi)cYzvi6UaLvEb5ZPsKhKyOVEKmK0MtDb5SkeDxGbDltCkD(tDRA2ejdDYPBF6Wsr6N1TiNvHOBh2DRqVB1OPBX4bfE3YeNiwfI6wMyOh1T0QBHt0qjI7wM4eXQqKOMnrYqNC6Ua4lqXlqZcuFLIGtm7KupSPuCdBFbAwaocOBy7coXSts9WMsrsFg5TfOzbgUG85ujYds0q61HlBtKFb5SkeDxGYkVG85ujYdsm0xpsgsAZPUGCwfIUlWGULjoLo)PUvnBIKHo50TpDyv99Z6wKZQq0Td7UvO3TA00Ty8GcVBzIteRcrDltm0J6wA1TWjAOeXDl1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tlqZcmYfO(kfr(GizuKtDsut80xGMfOgT2c0SGc6OEKj9zK3wqvWxGHlWWf8zNxGcwaJhu4coXStsviUncC0MfyWcQmlGXdkCbNy2jPke3gbbdHFdjh0NwGbDltCkD(tDRcYziP6l9(0H156N1TiNvHOBh2DlCIgkrC3YWfmme5JGCi0r9qoDfKZQq0DbAwWNDwOJNfuf8fy2v8c0SGp7SqhplqHWxW55ClWGfOSYlWWfyKlyyiYhb5qOJ6HC6kiNvHO7c0SGp7SqhplOk4lWSFUfyq3IXdk8U1NDwEq)(0H15PFw3ICwfIUDy3TWjAOeXDl1xPi4eZoj1dBkfp9UfJhu4Dl9yqH3NoSQg9Z6wKZQq0Td7UfordLiUBLpNkrEqIH(6rYqsBo1fKZQq0DbAwG6Rueem18RnOWfp9fOzbgUaCeq3W2fCIzNK6HnLIK4RslqzLxGA0AlqZckOJ6rM0NrEBbvbFbvVIxGbDlgpOW7wd6tsBo17thwM9(zDlYzvi62HD3cNOHse3TuFLIGtm7KupSPuCdBFbAwG6Rue5ZjzuK6HnLIBy7lqZcUK6Ruet8W1YOiNAs(5dK4g2E3IXdk8Ufe6OEAYZ3E3Jp5tF6Wsr3pRBroRcr3oS7w4enuI4UL6RueCIzNK6HnLIBy7lqZcuFLIiFojJIupSPuCdBFbAwWLuFLIyIhUwgf5utYpFGe3W27wmEqH3Tu5dzuKtIWNA9PdlTuC)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsQh2ukE6DlgpOW7wQu2O8eYp6thwAPv)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsQh2ukE6DlgpOW7wQqrCLLxQuF6WslZ0pRBroRcr3oS7w4enuI4UL6RueCIzNK6HnLINE3IXdk8UvbLKkue3(0HLwks)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsQh2ukE6DlgpOW7wSJP2KmKeZqq9PdlTQ((zDlYzvi62HD3cNOHse3TuFLIGtm7KupSPu807wmEqH3TEnsIg636thwADU(zDlYzvi62HD3IXdk8U1beFr8eztQY3dQBHt0qjI7wQVsrWjMDsQh2ukE6lqzLxaocOBy7coXSts9WMsrsFg5TfOq4l4CNBbAwWLuFLIyIhUwgf5utYpFGep9UfvkeEKo)PU1beFr8eztQY3dQpDyP15PFw3ICwfIUDy3Ty8GcVBrFDLsIHKrED2Xu3cNOHse3TWraDdBxWjMDsQh2uks6ZiVTGQGVadxGwkYcQybvJfuzwGjorSkejyDz4YxJwGbDlN)u3I(6kLedjJ86SJP(0HLwvJ(zDlYzvi62HD3IXdk8U1nj(wqjjnrTgb1TWjAOeXDlCeq3W2fCIzNK6HnLIK(mYBlqHWxGzu8cuw5fyKlWeNiwfIeSUmC5Rrla(c0AbkR8cmCbd6tla(cu8c0SatCIyvisuqTAKFidDYPCbWxGwlqZcYNtLipirdPxhUSnr(fKZQq0Dbg0TC(tDRBs8TGssAIAncQpDyPLzVFw3ICwfIUDy3Ty8GcVB1IhKeD4OHYUfordLiUBHJa6g2UGtm7KupSPuK0NrEBbke(cuefVaLvEbg5cmXjIvHibRldx(A0cGVaT6wo)PUvlEqs0HJgk7thwAPO7N1TiNvHOBh2DlgpOW7whqkPxlJIKBn0hbXdk8UfordLiUBHJa6g2UGtm7KupSPuK0NrEBbke(cmJIxGYkVaJCbM4eXQqKG1LHlFnAbWxGwlqzLxGHlyqFAbWxGIxGMfyIteRcrIcQvJ8dzOtoLla(c0AbAwq(CQe5bjAi96WLTjYVGCwfIUlWGULZFQBDaPKETmksU1qFeepOW7thwMrX9Z6wKZQq0Td7UfJhu4DRpJz1KKTAIg5)1q4UfordLiUBHJa6g2UGtm7KupSPuK0NrEBbvbFbNBbAwGHlWixGjorSkejkOwnYpKHo5uUa4lqRfOSYlyqFAbkCbkIIxGbDlN)u36ZywnjzRMOr(FneUpDyzgT6N1TiNvHOBh2DlgpOW7wFgZQjjB1enY)RHWDlCIgkrC3chb0nSDbNy2jPEytPiPpJ82cQc(co3c0SatCIyvisuqTAKFidDYPCbWxGwlqZcuFLIiFojJIupSPu80xGMfO(kfr(CsgfPEytPiPpJ82cQc(cmCbAP4funVGZTGkZcYNtLipirdPxhUSnr(fKZQq0DbgSanlyqFAbvTafrXDlN)u36ZywnjzRMOr(FneUpDyzgZ0pRBroRcr3oS7w4enuI4UfJhKjsso9ruBbkCbMPB1MeHNoS0QBX4bfE3cZqqsgpOWLqO20TGqTr68N6wCq9PdlZOi9Z6wKZQq0Td7UfordLiUBHdtKZ(ioPuIyFbAwq(CQe5bj4eZojrEb5Orjb5SkeDxGMfmme5JiFojJIupSPuqoRcr3UvBseE6WsRUfJhu4Dlmdbjz8GcxcHAt3cc1gPZFQBvZ5pCL6thwMP67N1TiNvHOBh2DRl1WjsFqH3ToRMwqb1Qr(XccDYPCbQ0bYBlWgn1lOAhv3cy)UGcQvtTfuICbgLrTa9mWTfmXcEnAb3xI8JfCwmMvfu5vx3IXdk8UfMHGKmEqHlHqTPB1MeHNoS0QBHt0qjI7wM4eXQqKOMnrYqNC6Ua4lqXlqZcmXjIvHirb1Qr(Hm0jNYUfeQnsN)u3QGA1i)qg6KtzF6WYmNRFw3ICwfIUDy3TWjAOeXDltCIyvisuZMizOtoDxa8fO4UvBseE6WsRUfJhu4Dlmdbjz8GcxcHAt3cc1gPZFQBf6KtzF6WYmNN(zDlYzvi62HD3cNOHse3TA0mi)Oj4VSPZ)faFbA1TAtIWthwA1Ty8GcVBHziijJhu4siuB6wqO2iD(tDl(lB68VpDyzMQr)SUf5SkeD7WUBX4bfE3cZqqsgpOWLqO20TGqTr68N6w4iGUHT36thwMXS3pRBroRcr3oS7w4enuI4ULjorSkejkiNHKQV0xa8fO4UvBseE6WsRUfJhu4Dlmdbjz8GcxcHAt3cc1gPZFQBLXWdk8(0HLzu09Z6wKZQq0Td7UfordLiUBzIteRcrIcYziP6l9faFbA1TAtIWthwA1Ty8GcVBHziijJhu4siuB6wqO2iD(tDRcYziP6l9(0HLIO4(zDlYzvi62HD3IXdk8UfMHGKmEqHlHqTPBbHAJ05p1T(Hj6t(0N(0TYy4bfE)SoS0QFw3ICwfIUDy3Ty8GcVBrMcmpOW7wxQHtK(GcVBX4bfEtKXWdk8kGRam7ycsY4bfU5OcCgpOWfKPaZdkCbUMDNGq(HMp7SqhpkeUI(CAm0iZNtLipirdPxhUSnr(vwz1xPiAi96WLTjYVOnm(eC1xPiAi96WLTjYV4ZWiBdJpzq3cNOHse3T(SZcD8SGQGVatCIyvisqMcPoEwGMfy4cWraDdBxmXdxlJICQj5NpqIK(mYBlOk4lGXdkCbzkW8GcxqWq43qYb9PfOSYlahb0nSDbNy2jPEytPiPpJ82cQc(cy8GcxqMcmpOWfeme(nKCqFAbkR8cmCbddr(iYNtYOi1dBkfKZQq0DbAwaocOBy7I85Kmks9WMsrsFg5Tfuf8fW4bfUGmfyEqHliyi8Bi5G(0cmybgSanlq9vkI85Kmks9WMsXnS9fOzbQVsrWjMDsQh2ukUHTVanl4sQVsrmXdxlJICQj5NpqIBy7lqZcmYfONKj5b(k0smXdxlJICQj5Npq9PdlZ0pRBroRcr3oS7w4enuI4Uv(CQe5bjAi96WLTjYVGCwfIUlqZcWraDdBxWjMDsQh2uks6ZiVTGQGVagpOWfKPaZdkCbbdHFdjh0N6wmEqH3TitbMhu49PdlfPFw3ICwfIUDy3Ty8GcVBXjMDsQYzYhu36snCI0hu4DlyZzYh0cqLfGgTBlyqFAbtSGxJwWeZFbSFxGnTGA2eTGjIf8zxPfGR58GADlCIgkrC3chb0nSDXepCTmkYPMKF(ajsIVkTanlWWfO(kfbNy2jjUMZds0ggFAbkCbM4eXQqKyI5l)mmsCnNhuBbAwaocOBy7coXSts9WMsrsFg5Tfuf8fqWq43qYb9PfOzbF2zHoEwGcxGjorSkejyD5h5O)7l)SZsD8Sanlq9vkI85Kmks9WMsXnS9fyqF6WQ67N1TiNvHOBh2DlCIgkrC3chb0nSDXepCTmkYPMKF(ajsIVkTanlWWfO(kfbNy2jjUMZds0ggFAbkCbM4eXQqKyI5l)mmsCnNhuBbAwWWqKpI85Kmks9WMsb5SkeDxGMfGJa6g2UiFojJIupSPuK0NrEBbvbFbeme(nKCqFAbAwaocOBy7coXSts9WMsrsFg5TfOWfyIteRcrIjMV8ZWiVeeRKSePK1xGbDlgpOW7wCIzNKQCM8b1NoSox)SUf5SkeD7WUBHt0qjI7w4iGUHTlM4HRLrro1K8Zhirs8vPfOzbgUa1xPi4eZojX1CEqI2W4tlqHlWeNiwfIetmF5NHrIR58GAlqZcmCbg5cggI8rKpNKrrQh2ukiNvHO7cuw5fGJa6g2UiFojJIupSPuK0NrEBbkCbM4eXQqKyI5l)mmYlbXkjlrkZqFbgSanlahb0nSDbNy2jPEytPiPpJ82cu4cmXjIvHiXeZx(zyKxcIvswIuY6lWGUfJhu4DloXStsvot(G6thwNN(zDlYzvi62HD3cNOHse3TUK6RuejFrSpYMoNNKMEqoLSkccnkjAdJpTa4l4sQVsrK8fX(iB6CEsA6b5uYQii0OK4ZWiBdJpTanlWWfO(kfbNy2jPEytP4g2(cuw5fO(kfbNy2jPEytPiPpJ82cQc(coW3fyWc0SadxG6Rue5ZjzuK6HnLIBy7lqzLxG6Rue5ZjzuK6HnLIK(mYBlOk4l4aFxGbDlgpOW7wCIzNKQCM8b1NoSQg9Z6wKZQq0Td7UfordLiUBDJrK8fX(iB6CEsK0NrEBbkCbM9fOSYlWWfCj1xPis(IyFKnDopjn9GCkzveeAus0ggFAbkCbkEbAwWLuFLIi5lI9r2058K00dYPKvrqOrjrBy8Pfu1cUK6RuejFrSpYMoNNKMEqoLSkccnkj(mmY2W4tlWGUfJhu4DloXStsviUn9PdlZE)SUf5SkeD7WUBHt0qjI7wQVsrONuJCmjJI8J8R4PVanl4sQVsrmXdxlJICQj5NpqIN(c0SGlP(kfXepCTmkYPMKF(ajs6ZiVTGQGVagpOWfCIzNKQqCBeeme(nKCqFQBX4bfE3Itm7KufIBtF6Wsr3pRBroRcr3oS7w4Ag5DlT6weNqkjX1mYLOs3s9vkcmeXjMBdYpK4A2DcsCdBxJHQVsrWjMDsQh2ukE6kRSHg5WqKpIWeL6HnL0vJHQVsrKpNKrrQh2ukE6kRmocOBy7cYuG5bfUij(QKbgyq3cNOHse3TUK6Ruet8W1YOiNAs(5dK4PVanlyyiYhbNy2jjHRdb5SkeDxGMfy4cuFLI4s8uRgPtIBy7lqzLxaJhKjsso9ruBbWxGwlWGfOzbgUGlP(kfXepCTmkYPMKF(ajs6ZiVTafUagpOWfCIzNKFuRHGOMGGHWVHKd6tlqzLxaocOBy7c9KAKJjzuKFKFfj9zK3wGYkVaCyIC2hXjLse7lWGUfJhu4DloXStYpQ1qquRpDyPLI7N1TiNvHOBh2DlCIgkrC3s9vkcmeXjMBdYpejX4zbAwG6Rueem6SFPRupgYhedjE6DlgpOW7wCIzNKFuRHGOwF6WslT6N1TiNvHOBh2DlgpOW7wCIzNKFuRHGOw3cxZiVBPv3cNOHse3TuFLIadrCI52G8drsmEwGMfy4cuFLIGtm7KupSPu80xGYkVa1xPiYNtYOi1dBkfp9fOSYl4sQVsrmXdxlJICQj5NpqIK(mYBlqHlGXdkCbNy2j5h1AiiQjiyi8Bi5G(0cmOpDyPLz6N1TiNvHOBh2DlgpOW7wCIzNKFuRHGOw3cxZiVBPv3cNOHse3TuFLIadrCI52G8drsmEwGMfO(kfbgI4eZTb5hI2W4tla(cuFLIadrCI52G8dXNHr2ggFQpDyPLI0pRBroRcr3oS7wmEqH3T4eZoj)OwdbrTUfUMrE3sRUfordLiUBP(kfbgI4eZTb5hIKy8Sanlq9vkcmeXjMBdYpej9zK3wqvWxGHlWWfO(kfbgI4eZTb5hI2W4tlOYSagpOWfCIzNKFuRHGOMGGHWVHKd6tlWGfuXcoW3fyqF6WsRQVFw3ICwfIUDy3TWjAOeXDldxqsLKA1SkeTaLvEbg5cge(eYpwGblqZcuFLIGtm7KexZ5bjAdJpTa4lq9vkcoXStsCnNhK4ZWiBdJpTanlq9vkcoXSts9WMsXnS9fOzbxs9vkIjE4AzuKtnj)8bsCdBVBX4bfE3YPPMs5qFDQn9PdlTox)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsIR58GeTHXNwqvWxGjorSkejMy(YpdJexZ5b16wmEqH3T4eZojJuTpDyP15PFw3ICwfIUDy3TWjAOeXDRp7SqhplOk4lqrFUfOzbQVsrWjMDsQh2ukUHTVanlq9vkI85Kmks9WMsXnS9fOzbxs9vkIjE4AzuKtnj)8bsCdBVBX4bfE3Q90P0dtCF6WsRQr)SUf5SkeD7WUBHt0qjI7wQVsrKpisgf5uNe1ep9fOzbQVsrWjMDsIR58GeTHXNwGcxGI0Ty8GcVBXjMDsQcXTPpDyPLzVFw3ICwfIUDy3TWjAOeXDRp7SqhplOk4lWeNiwfIeQCM8bj)SZsD8Sanlq9vkcoXSts9WMsXnS9fOzbQVsrKpNKrrQh2ukUHTVanl4sQVsrmXdxlJICQj5NpqIBy7lqZcuFLIGtm7KexZ5bjAdJpTa4lq9vkcoXStsCnNhK4ZWiBdJpTanlahb0nSDbzkW8GcxK0NrERBX4bfE3Itm7KuLZKpO(0HLwk6(zDlYzvi62HD3cNOHse3TuFLIGtm7KupSPuCdBFbAwG6Rue5ZjzuK6HnLIBy7lqZcUK6Ruet8W1YOiNAs(5dK4g2(c0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tlqZcggI8rWjMDsgPQGCwfIUlqZcWraDdBxWjMDsgPQiPpJ82cQc(coW3fOzbF2zHoEwqvWxGIwXlqZcWraDdBxqMcmpOWfj9zK36wmEqH3T4eZojv5m5dQpDyzgf3pRBroRcr3oS7w4enuI4UL6RueCIzNK6HnLIN(c0Sa1xPi4eZoj1dBkfj9zK3wqvWxWb(Uanlq9vkcoXStsCnNhKOnm(0cGVa1xPi4eZojX1CEqIpdJSnm(0c0SadxaocOBy7cYuG5bfUiPpJ82cuw5fKpNkrEqcoXStsKxqoAusqoRcr3fyq3IXdk8UfNy2jPkNjFq9PdlZOv)SUf5SkeD7WUBHt0qjI7wQVsrKpNKrrQh2ukE6lqZcuFLIGtm7KupSPuCdBFbAwG6Rue5ZjzuK6HnLIK(mYBlOk4l4aFxGMfO(kfbNy2jjUMZds0ggFAbWxG6RueCIzNK4AopiXNHr2ggFAbAwGHlahb0nSDbzkW8GcxK0NrEBbkR8cYNtLipibNy2jjYlihnkjiNvHO7cmOBX4bfE3Itm7KuLZKpO(0HLzmt)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsQh2ukUHTVanlq9vkI85Kmks9WMsXnS9fOzbxs9vkIjE4AzuKtnj)8bs80xGMfCj1xPiM4HRLrro1K8ZhirsFg5Tfuf8fCGVlqZcuFLIGtm7KexZ5bjAdJpTa4lq9vkcoXStsCnNhK4ZWiBdJp1Ty8GcVBXjMDsQYzYhuF6WYmks)SUf5SkeD7WUBHt0qjI7wdNh0iQjgAQf64zbvTaf5ClqZcuFLIGtm7KexZ5bjAdJpTafcFbgUagpitKKC6JO2cQMxGwlWGfOzb5ZPsKhKGtm7Kun(QCE)KpcYzvi6UanlGXdYejjN(iQTafUaTwGMfO(kfXL4PwnsNe3W27wmEqH3T4eZojv5m5dQpDyzMQVFw3ICwfIUDy3TWjAOeXDRHZdAe1edn1cD8SGQwGICUfOzbQVsrWjMDsIR58GeTHXNwqvlq9vkcoXStsCnNhK4ZWiBdJpTanliFovI8GeCIzNKQXxLZ7N8rqoRcr3fOzbmEqMij50hrTfOWfO1c0Sa1xPiUep1Qr6K4g2E3IXdk8UfNy2jjbJou0qH3NoSmZ56N1Ty8GcVBXjMDsQcXTPBroRcr3oS7thwM580pRBroRcr3oS7w4enuI4UL6Rue5ZjzuK6HnLIBy7lqZcuFLIGtm7KupSPuCdBFbAwWLuFLIyIhUwgf5utYpFGe3W27wmEqH3TitbMhu49PdlZun6N1Ty8GcVBXjMDsQYzYhu3ICwfIUDy3N(0TWraDdBV1pRdlT6N1TiNvHOBh2DlgpOW7wLmAJ0dtC36snCI0hu4DRQlrrIg05dTGxd5hl4irniLwacJWq0cSrt9cyDXcmlA0cqZcSrt9cMy(liMAkTrns0TWjAOeXDR85ujYdsCKOgKssegHHib5SkeDxGMfGJa6g2UGtm7KupSPuK0NrEBbkCbkIIxGMfGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fOzbgUa1xPi4eZojX1CEqI2W4tlOk4lWeNiwfIetmF5NHrIR58GAlqZcmCbgUGHHiFe5ZjzuK6HnLcYzvi6Uanlahb0nSDr(CsgfPEytPiPpJ82cQc(coW3fOzb4iGUHTl4eZoj1dBkfj9zK3wGcxGjorSkejMy(YpdJ8sqSsYsKswFbgSaLvEbgUaJCbddr(iYNtYOi1dBkfKZQq0DbAwaocOBy7coXSts9WMsrsFg5TfOWfyIteRcrIjMV8ZWiVeeRKSePK1xGblqzLxaocOBy7coXSts9WMsrsFg5Tfuf8fCGVlWGfyqF6WYm9Z6wKZQq0Td7UfordLiUBLpNkrEqIJe1GusIWimejiNvHO7c0SaCeq3W2fCIzNK6HnLIK(mYBla(cu8c0SadxGrUGHHiFeKdHoQhYPRGCwfIUlqzLxGHlyyiYhb5qOJ6HC6kiNvHO7c0SGp7SqhplqHWxq1qXlWGfyWc0SadxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTafUaTu8c0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tlWGfOSYlWWfGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fOzbQVsrWjMDsIR58GeTHXNwa8fO4fyWcmybAwG6Rue5ZjzuK6HnLIBy7lqZc(SZcD8SafcFbM4eXQqKG1LFKJ(VV8Zol1Xt3IXdk8UvjJ2i9We3NoSuK(zDlYzvi62HD3cNOHse3TYNtLipiXf1WiDiKZPssC8)SFfKZQq0DbAwaocOBy7c1xPiVOggPdHCovsIJ)N9Rij(Q0c0Sa1xPiUOggPdHCovsIJ)N9RSKrBe3W2xGMfy4cuFLIGtm7KupSPuCdBFbAwG6Rue5ZjzuK6HnLIBy7lqZcUK6Ruet8W1YOiNAs(5dK4g2(cmybAwaocOBy7IjE4AzuKtnj)8bsK0NrEBbWxGIxGMfy4cuFLIGtm7KexZ5bjAdJpTGQGVatCIyvismX8LFggjUMZdQTanlWWfy4cggI8rKpNKrrQh2ukiNvHO7c0SaCeq3W2f5ZjzuK6HnLIK(mYBlOk4l4aFxGMfGJa6g2UGtm7KupSPuK0NrEBbkCbM4eXQqKyI5l)mmYlbXkjlrkz9fyWcuw5fy4cmYfmme5JiFojJIupSPuqoRcr3fOzb4iGUHTl4eZoj1dBkfj9zK3wGcxGjorSkejMy(YpdJ8sqSsYsKswFbgSaLvEb4iGUHTl4eZoj1dBkfj9zK3wqvWxWb(UadwGbDlgpOW7wLmAJAan9PdRQVFw3ICwfIUDy3TWjAOeXDR85ujYdsCrnmshc5CQKeh)p7xb5SkeDxGMfGJa6g2Uq9vkYlQHr6qiNtLK44)z)ksIVkTanlq9vkIlQHr6qiNtLK44)z)klOKe3W2xGMfONKj5b(k0suYOnQb00Ty8GcVBvqjjvH420NoSox)SUf5SkeD7WUBX4bfE36JYmYMmkYjYp5t36snCI0hu4DRQJr5cmRXzlWgn1lOYRUfGklanA3wao(i)ybp9f0IWfl48xwaAwGnccAbQ0cEn6UaB0uVGZIXSA(cWCBwaAwqdcDupqkTavQej1TWjAOeXDlCeq3W2ft8W1YOiNAs(5dKiPpJ82cQAbM4eXQqK4hJupjmrx5eZxQQ0cuw5fy4cWraDdBxWjMDsQh2uks6ZiVTafUatCIyvis8Jr(zyKxcIvswIuY6lqZcWraDdBxmXdxlJICQj5NpqIK(mYBlqHlWeNiwfIe)yKFgg5LGyLKLiLtm)fyqF6W680pRBroRcr3oS7w4enuI4UfocOBy7coXSts9WMsrs8vPfOzbgUaJCbddr(iihcDupKtxb5SkeDxGYkVadxWWqKpcYHqh1d50vqoRcr3fOzbF2zHoEwGcHVGQHIxGblWGfOzbgUadxaocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbM4eXQqKG1LFgg5LGyLKLiLtm)fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTa4lqXlWGfyWc0Sa1xPiYNtYOi1dBkf3W2xGMf8zNf64zbke(cmXjIvHibRl)ih9FF5NDwQJNUfJhu4DRpkZiBYOiNi)Kp9PdRQr)SUf5SkeD7WUBX4bfE36s8uRgPtDRl1WjsFqH3TQCiBwP2cEnAbxINA1iDAb2OPEbSUybN)YcMy(la1wqs8vPfWTfytqqMVGpFIwq7L0cMybyUnlanlqLkrslyI5l6w4enuI4UfocOBy7IjE4AzuKtnj)8bsK0NrEBbWxGIxGMfO(kfbNy2jjUMZds0ggFAbvbFbM4eXQqKyI5l)mmsCnNhuBbAwaocOBy7coXSts9WMsrsFg5Tfuf8fCGV9PdlZE)SUf5SkeD7WUBHt0qjI7w4iGUHTl4eZoj1dBkfj9zK3wa8fO4fOzbgUaJCbddr(iihcDupKtxb5SkeDxGYkVadxWWqKpcYHqh1d50vqoRcr3fOzbF2zHoEwGcHVGQHIxGblWGfOzbgUadxaocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbAP4fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTa4lqXlWGfyWc0Sa1xPiYNtYOi1dBkf3W2xGMf8zNf64zbke(cmXjIvHibRl)ih9FF5NDwQJNUfJhu4DRlXtTAKo1NoSu09Z6wKZQq0Td7UfJhu4DRKVi2hztNZtDRl1WjsFqH3TmlA0cA6CEAbOYcMy(lG97cy9fWjTGWxa(Ua2VlWoCTNfOsl4PVGsKlak8dkxWuZ(cMAAbFgMfCjiwjZxWNpH8Jf0EjTaBAb1SjAb8SaiIBZcg7ybCIzNwaUMZdQTa2VlyQ5zbtm)fyZnx7zbNV9AZcEn6k6w4enuI4UfocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbM4eXQqKiBYpdJ8sqSsYsKYjM)c0SaCeq3W2fCIzNK6HnLIK(mYBlqHlWeNiwfIezt(zyKxcIvswIuY6lqZcmCbddr(iYNtYOi1dBkfKZQq0DbAwGHlahb0nSDr(CsgfPEytPiPpJ82cQAbeme(nKCqFAbkR8cWraDdBxKpNKrrQh2uks6ZiVTafUatCIyvisKn5NHrEjiwjzjszg6lWGfOSYlWixWWqKpI85Kmks9WMsb5SkeDxGblqZcuFLIGtm7KexZ5bjAdJpTafUaZSanl4sQVsrmXdxlJICQj5NpqIBy7lqZcuFLIiFojJIupSPuCdBFbAwG6RueCIzNK6HnLIBy79PdlTuC)SUf5SkeD7WUBX4bfE3k5lI9r2058u36snCI0hu4DlZIgTGMoNNwGnAQxaRVa7AYxGE0AivisSGZFzbtm)fGAlij(Q0c42cSjiiZxWNprlO9sAbtSam3MfGMfOsLiPfmX8fDlCIgkrC3chb0nSDXepCTmkYPMKF(ajs6ZiVTGQwabdHFdjh0NwGMfO(kfbNy2jjUMZds0ggFAbvbFbM4eXQqKyI5l)mmsCnNhuBbAwaocOBy7coXSts9WMsrsFg5Tfu1cmCbeme(nKCqFAbvSagpOWft8W1YOiNAs(5dKGGHWVHKd6tlWG(0HLwA1pRBroRcr3oS7w4enuI4UfocOBy7coXSts9WMsrsFg5Tfu1ciyi8Bi5G(0c0SadxGHlWixWWqKpcYHqh1d50vqoRcr3fOSYlWWfmme5JGCi0r9qoDfKZQq0DbAwWNDwOJNfOq4lOAO4fyWcmybAwGHlWWfGJa6g2UyIhUwgf5utYpFGej9zK3wGcxGjorSkejyD5NHrEjiwjzjs5eZFbAwG6RueCIzNK4AopirBy8PfaFbQVsrWjMDsIR58GeFggzBy8PfyWcuw5fy4cWraDdBxmXdxlJICQj5NpqIK(mYBla(cu8c0Sa1xPi4eZojX1CEqI2W4tla(cu8cmybgSanlq9vkI85Kmks9WMsXnS9fOzbF2zHoEwGcHVatCIyvisW6YpYr)3x(zNL64zbg0Ty8GcVBL8fX(iB6CEQpDyPLz6N1TiNvHOBh2DlgpOW7wt8W1YOiNAs(5du36snCI0hu4DlZIgTGjM)cSrt9cy9fGklanA3wGnAQr(cMAAbFgMfCjiwjXco)Lf4Xy(cEnAb2OPEbzOVauzbtnTGHHiFwaQTGHprU5lG97cqJ2TfyJMAKVGPMwWNHzbxcIvs0TWjAOeXDl1xPi4eZojX1CEqI2W4tlOk4lWeNiwfIetmF5NHrIR58GAlqZcWraDdBxWjMDsQh2uks6ZiVTGQGVacgc)gsoOpTanl4Zol0XZcu4cmXjIvHibRl)ih9FF5NDwQJNfOzbQVsrKpNKrrQh2ukUHT3NoS0sr6N1TiNvHOBh2DlCIgkrC3s9vkcoXStsCnNhKOnm(0cQc(cmXjIvHiXeZx(zyK4AopO2c0SGHHiFe5ZjzuK6HnLcYzvi6Uanlahb0nSDr(CsgfPEytPiPpJ82cQc(ciyi8Bi5G(0c0SaCeq3W2fCIzNK6HnLIK(mYBlqHlWeNiwfIetmF5NHrEjiwjzjsjRVanlahb0nSDbNy2jPEytPiPpJ82cu4c0YmDlgpOW7wt8W1YOiNAs(5duF6WsRQVFw3ICwfIUDy3TWjAOeXDl1xPi4eZojX1CEqI2W4tlOk4lWeNiwfIetmF5NHrIR58GAlqZcmCbg5cggI8rKpNKrrQh2ukiNvHO7cuw5fGJa6g2UiFojJIupSPuK0NrEBbkCbM4eXQqKyI5l)mmYlbXkjlrkZqFbgSanlahb0nSDbNy2jPEytPiPpJ82cu4cmXjIvHiXeZx(zyKxcIvswIuY6DlgpOW7wt8W1YOiNAs(5duF6WsRZ1pRBroRcr3oS7wmEqH3T4eZoj1dBk7wxQHtK(GcVBzw0OfW6lavwWeZFbO2ccFb47cy)Ua7W1EwGkTGN(ckrUaOWpOCbtn7lyQPf8zywWLGyLmFbF(eYpwq7L0cMAEwGnTGA2eTaYJ3r9c(SZlG97cMAEwWutjTauBbEmlGHsIVkTaEb5ZPfeLfOh2uUGBy7IUfordLiUBHJa6g2UyIhUwgf5utYpFGej9zK3wGcxGjorSkejyD5NHrEjiwjzjs5eZFbAwGHlWixaomro7JWe5tTs5cuw5fGJa6g2U4JYmYMmkYjYp5JiPpJ82cu4cmXjIvHibRl)mmYlbXkjlrk)XSadwGMfO(kfbNy2jjUMZds0ggFAbWxG6RueCIzNK4AopiXNHr2ggFAbAwG6Rue5ZjzuK6HnLIBy7lqZc(SZcD8SafcFbM4eXQqKG1LFKJ(VV8Zol1XtF6WsRZt)SUf5SkeD7WUBX4bfE3kFojJIupSPSBDPgor6dk8ULzrJwqg6lavwWeZFbO2ccFb47cy)Ua7W1EwGkTGN(ckrUaOWpOCbtn7lyQPf8zywWLGyLmFbF(eYpwq7L0cMAkPfGAU2ZcyOK4RslGxq(CAb3W2xa73fm18SawFb2HR9SavchFAbSjgbXQq0cUVe5hliFoj6w4enuI4UL6RueCIzNK6HnLIBy7lqZcmCb4iGUHTlM4HRLrro1K8ZhirsFg5TfOWfyIteRcrIm0LFgg5LGyLKLiLtm)fOSYlahb0nSDbNy2jPEytPiPpJ82cQc(cmXjIvHiXeZx(zyKxcIvswIuY6lWGfOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGMfGJa6g2UGtm7KupSPuK0NrEBbkCbAzM(0HLwvJ(zDlYzvi62HD3cNOHse3TuFLIGtm7KupSPuCdBFbAwaocOBy7coXSts9WMsXKpsM0NrEBbkCbmEqHlA1OYG8dPEytPaFZfOzbQVsrKpNKrrQh2ukUHTVanlahb0nSDr(CsgfPEytPyYhjt6ZiVTafUagpOWfTAuzq(HupSPuGV5c0SGlP(kfXepCTmkYPMKF(ajUHT3Ty8GcVB1QrLb5hs9WMY(0HLwM9(zDlYzvi62HD3IXdk8ULEsnYXKmkYpYVDRl1WjsFqH3TmlA0c0J)cMybTQ1JOZhAbSVacMj5fWQla5lyQPf4emZcWraDdBFb2i)g2MVGNdrT2coPuIyFbtn5liCiLwW9Li)ybCIzNwGEyt5cUpAbtSG6WEbF25fu)8JuPfK8fX(SGMoNNwaQ1TWjAOeXDRHHiFe5ZjzuK6HnLcYzvi6Uanlq9vkcoXSts9WMsXtFbAwG6Rue5ZjzuK6HnLIK(mYBlOQfCGVIpdtF6WslfD)SUf5SkeD7WUBHt0qjI7wxs9vkIjE4AzuKtnj)8bs80xGMfCj1xPiM4HRLrro1K8ZhirsFg5Tfu1cy8GcxWjMDs(rTgcIAccgc)gsoOpTanlWixaomro7J4KsjI9UfJhu4Dl9KAKJjzuKFKF7thwMrX9Z6wKZQq0Td7UfordLiUBP(kfr(CsgfPEytP4PVanlq9vkI85Kmks9WMsrsFg5Tfu1coWxXNHzbAwaocOBy7cYuG5bfUij(Q0c0SaCeq3W2ft8W1YOiNAs(5dKiPpJ82c0SaJCb4We5SpItkLi27wmEqH3T0tQroMKrr(r(Tp9PB9dt0N8PFwhwA1pRBroRcr3oS7w4enuI4U1pmrFYhXf1g2X0cui8fOLI7wmEqH3TuHq(P(0HLz6N1Ty8GcVBPNuJCmjJI8J8B3ICwfIUDy3NoSuK(zDlYzvi62HD3cNOHse3T(Hj6t(iUO2WoMwqvlqlf3Ty8GcVBXjMDs(rTgcIA9PdRQVFw3IXdk8UfNy2jzKQDlYzvi62HDF6W6C9Z6wmEqH3TkOKKQqCB6wKZQq0Td7(0NULEs44RYt)SoS0QFw3IXdk8UfNy2jjYhccIWt3ICwfIUDy3NoSmt)SUfJhu4DR27)dxYjMDsw4pccXz3ICwfIUDy3NoSuK(zDlgpOW7w4WpF7LK8ZolpOF3ICwfIUDy3NoSQ((zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6w8x205F36sf(bnDRgndYpAc(lB68VpDyDU(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wKPqQJNU1Lk8dA6wADU(0H15PFw3ICwfIUDy3Tc9UvJMUfJhu4DltCIyviQBzItPZFQBPNK(dcssMIUfordLiUBz4cYNtLipirdPxhUSnr(fKZQq0DbAwaJhKjsso9ruBbkCbATGkwGHlqRfuzwGHlWixaomro7JWjCgqrExGblWGfyq3Yed9ijb1OULI7wMyOh1T0QpDyvn6N1TiNvHOBh2DRqVB1OPBX4bfE3YeNiwfI6wM4u68N6w1Sjsg6Kt3UfordLiUBz4cy8GmrsYPpIAlqHlWmlqzLxGjorSkej0ts)bbjjtXcGVaTwGYkVatCIyvisWFztN)la(c0Abg0TmXqpssqnQBP4ULjg6rDlT6thwM9(zDlYzvi62HD3k07wnA6wmEqH3TmXjIvHOULjg6rDlf3TmXP05p1TkiNHKQV07thwk6(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wMnfL8sqSsqOpAKvE11TUuHFqt3sRZ1NoS0sX9Z6wKZQq0Td7UvO3TsQrt3IXdk8ULjorSke1TmXP05p1TmBkkPEsTHXNq(HCqFQBDPc)GMULIUpDyPLw9Z6wKZQq0Td7UvO3TsQrt3IXdk8ULjorSke1TmXP05p1TmBkkPzz1g2LiR2wYlbXk1TUuHFqt3slf3NoS0Ym9Z6wKZQq0Td7UvO3TsQrt3IXdk8ULjorSke1TmXP05p1TYM8ZWiVeeRKSePCI53TUuHFqt36C9PdlTuK(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wzt(zyKxcIvswIuMHE36sf(bnDRZ1NoS0Q67N1TiNvHOBh2DRqVBLuJMUfJhu4DltCIyviQBzItPZFQBLn5NHrEjiwjzjsjR3TUuHFqt3YmkUpDyP156N1TiNvHOBh2DRqVBLuJMUfJhu4DltCIyviQBzItPZFQB9JrQNeMORCI5lvvQBDPc)GMULI0NoS0680pRBroRcr3oS7wHE3kPgnDlgpOW7wM4eXQqu3YeNsN)u36hJ8ZWiVeeRKSePCI53TUuHFqt3slf3NoS0QA0pRBroRcr3oS7wHE3kPgnDlgpOW7wM4eXQqu3YeNsN)u36hJ8ZWiVeeRKSePK17wxQWpOPBP156thwAz27N1TiNvHOBh2DRqVBLuJMUfJhu4DltCIyviQBzItPZFQBX6YpdJ8sqSsYsKYjMF36sf(bnDlTuCF6WslfD)SUf5SkeD7WUBf6DRKA00Ty8GcVBzIteRcrDltCkD(tDlwx(zyKxcIvswIu(JPBDPc)GMULzuCF6WYmkUFw3ICwfIUDy3Tc9UvJMUfJhu4DltCIyviQBzIHEu3YmkEbvZlWWfCUfuzwao87dncoXSts9mUOdLeKZQq0Dbg0TmXP05p1TYqx(zyKxcIvswIuoX87thwMrR(zDlYzvi62HD3k07wnA6wmEqH3TmXjIvHOULjg6rDRZTGkwGwkEbvMfy4cWHjYzFeo6OEKfMwGYkVadxao87dncoXSts9mUOdLeKZQq0DbAwaJhKjsso9ruBbvTafzbgSadwqflqRZTGkZcmCb4We5SpItkLi2xGMfKpNkrEqcoXStsKxqoAusqoRcr3fOzbmEqMij50hrTfOWfyMfyq3YeNsN)u3AI5l)mmYlbXkjlrkz9(0HLzmt)SUf5SkeD7WUBf6DRgnDlgpOW7wM4eXQqu3Yed9OULzu8cQMxGHlWSVGkZcWHFFOrWjMDsQNXfDOKGCwfIUlWGULjoLo)PU1eZx(zyKxcIvswIuMHEF6WYmks)SUf5SkeD7WUBf6DRgnDlgpOW7wM4eXQqu3Yed9OU15rXlOAEbgUGp3gkvsAIHE0cQmlqlfR4fyq3cNOHse3TWHjYzFeo6OEKfM6wM4u68N6wQCM8bj)SZsD80NoSmt13pRBroRcr3oS7wHE3Qrt3IXdk8ULjorSke1TmXqpQBPOp3cQMxGHl4ZTHsLKMyOhTGkZc0sXkEbg0TWjAOeXDlCyIC2hXjLse7DltCkD(tDlvot(GKF2zPoE6thwM5C9Z6wKZQq0Td7UvO3TA00Ty8GcVBzIteRcrDltm0J6wMDfVGQ5fy4c(CBOujPjg6rlOYSaTuSIxGbDlCIgkrC3YeNiwfIeQCM8bj)SZsD8Sa4lqXDltCkD(tDlvot(GKF2zPoE6thwM580pRBroRcr3oS7wHE3kPgnDlgpOW7wM4eXQqu3YeNsN)u3I1LFKJ(VV8Zol1Xt36sf(bnDlToxF6WYmvJ(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wtmF5NHrIR58GADRlv4h00TmtF6WYmM9(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wCqYjMV8ZWiX1CEqTU1Lk8dA6wMPpDyzgfD)SUf5SkeD7WUBf6DRgnDlgpOW7wM4eXQqu3Yed9OULwlOYSadxavTEiDD6kOVUsjXqYiVo7yAbkR8cmCbddr(iYNtYOi1dBkfKZQq0DbAwGHlyyiYhbNy2jjHRdb5SkeDxGYkVaJCb4We5SpItkLi2xGblqZcmCbg5cWHjYzFeoHZakY7cuw5fW4bzIKKtFe1wa8fO1cuw5fKpNkrEqIgsVoCzBI8liNvHO7cmybgSad6wM4u68N6wfuRg5hYqNCk7thwkII7N1TiNvHOBh2DRqVB1OPBX4bfE3YeNiwfI6wMyOh1TOQ1dPRtxXNXSAsYwnrJ8)Ai8cuw5fqvRhsxNUIdi(I4jYMuLVh0cuw5fqvRhsxNUIdi(I4jYM8txgccf(cuw5fqvRhsxNUIlNN(r4YlHpj1Ftsnm5yAbkR8cOQ1dPRtxbYB48nSkejRwp2N3xEjtimTaLvEbu16H01PROfpiiAgKFiZNQslqzLxavTEiDD6kApxfkIRK)0uRuBwGYkVaQA9q660vyZNiNYMSKHFxGYkVaQA9q660vuG4pjJIuLNbI6wM4u68N6wSUmC5Rr9PdlfrR(zDlYzvi62HD3k07wj1OPBX4bfE3YeNiwfI6wM4u68N6wCqYjMV8ZWiX1CEqTU1Lk8dA6wMPpDyPiMPFw3ICwfIUDy3Tc9UvsnA6wmEqH3TmXjIvHOULjoLo)PUfzkK64PBDPc)GMULwNRpDyPiks)SUfJhu4DRpkZiLOpFqDlYzvi62HDF6WsrQ((zDlYzvi62HD3cNOHse3TmYfyIteRcrc9K0FqqsYuSa4lqRfOzb5ZPsKhK4IAyKoeY5ujjo(F2VcYzvi62Ty8GcVBvYOnQb00NoSuKZ1pRBroRcr3oS7w4enuI4ULrUatCIyvisONK(dcssMIfaFbATanlWixq(CQe5bjUOggPdHCovsIJ)N9RGCwfIUDlgpOW7wCIzNKQqCB6thwkY5PFw3ICwfIUDy3TWjAOeXDltCIyvisONK(dcssMIfaFbA1Ty8GcVBrMcmpOW7tF6w8x205F)SoS0QFw3ICwfIUDy3Ty8GcVBrMcmpOW7wxQHtK(GcVBX4bfEtWFztN)WXSJjijJhu4MJkWz8GcxqMcmpOWf4A2Dcc5hA(SZcD8Oq4k6Z1TWjAOeXDRp7SqhplOk4lWeNiwfIeKPqQJNfOzbgUaCeq3W2ft8W1YOiNAs(5dKiPpJ82cQc(cy8GcxqMcmpOWfeme(nKCqFAbkR8cWraDdBxWjMDsQh2uks6ZiVTGQGVagpOWfKPaZdkCbbdHFdjh0NwGYkVadxWWqKpI85Kmks9WMsb5SkeDxGMfGJa6g2UiFojJIupSPuK0NrEBbvbFbmEqHlitbMhu4ccgc)gsoOpTadwGblqZcuFLIiFojJIupSPuCdBFbAwG6RueCIzNK6HnLIBy7lqZcUK6Ruet8W1YOiNAs(5dK4g2EF6WYm9Z6wKZQq0Td7UfordLiUBHJa6g2UGtm7KupSPuK0NrEBbWxGIxGMfy4cuFLIiFojJIupSPuCdBFbAwGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTafUatCIyvisW6YpdJ8sqSsYsKYjM)cuw5fGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fyWcmOBX4bfE36s8uRgPt9PdlfPFw3ICwfIUDy3TWjAOeXDlCeq3W2fCIzNK6HnLIK(mYBla(cu8c0SadxG6Rue5ZjzuK6HnLIBy7lqZcmCb4iGUHTlM4HRLrro1K8ZhirsFg5TfOWfyIteRcrcwx(zyKxcIvswIuoX8xGYkVaCeq3W2ft8W1YOiNAs(5dKiPpJ82cGVafVadwGbDlgpOW7wFuMr2Krror(jF6thwvF)SUfJhu4DRKVi2hztNZtDlYzvi62HDF6W6C9Z6wKZQq0Td7UfordLiUBP(kfbNy2jPEytP4g2(c0SaCeq3W2fCIzNK6HnLIjFKmPpJ82cu4cy8Gcx0QrLb5hs9WMsb(MlqZcuFLIiFojJIupSPuCdBFbAwaocOBy7I85Kmks9WMsXKpsM0NrEBbkCbmEqHlA1OYG8dPEytPaFZfOzbxs9vkIjE4AzuKtnj)8bsCdBVBX4bfE3QvJkdYpK6HnL9PdRZt)SUf5SkeD7WUBHt0qjI7wQVsrKpNKrrQh2ukUHTVanlahb0nSDbNy2jPEytPiPpJ8w3IXdk8Uv(CsgfPEytzF6WQA0pRBroRcr3oS7w4enuI4ULHlahb0nSDbNy2jPEytPiPpJ82cGVafVanlq9vkI85Kmks9WMsXnS9fyWcuw5fONKj5b(k0sKpNKrrQh2u2Ty8GcVBnXdxlJICQj5Npq9PdlZE)SUf5SkeD7WUBHt0qjI7w4iGUHTl4eZoj1dBkfj9zK3wqvl4CkEbAwG6Rue5ZjzuK6HnLIBy7lqZcOwJCmjmHAOWLrrQtzHWdkCb5SkeD7wmEqH3TM4HRLrro1K8ZhO(0HLIUFw3ICwfIUDy3TWjAOeXDl1xPiYNtYOi1dBkf3W2xGMfGJa6g2UyIhUwgf5utYpFGej9zK3wGcxGjorSkejyD5NHrEjiwjzjs5eZVBX4bfE3Itm7KupSPSpDyPLI7N1TiNvHOBh2DlCIgkrC3s9vkcoXSts9WMsXtFbAwG6RueCIzNK6HnLIK(mYBlOk4lGXdkCbNy2j5h1AiiQjiyi8Bi5G(0c0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tDlgpOW7wCIzNKQCM8b1NoS0sR(zDlYzvi62HD3cNOHse3TuFLIGtm7KexZ5bjAdJpTGQwG6RueCIzNK4AopiXNHr2ggFAbAwG6Rue5ZjzuK6HnLIBy7lqZcuFLIGtm7KupSPuCdBFbAwWLuFLIyIhUwgf5utYpFGe3W27wmEqH3T4eZojJuTpDyPLz6N1TiNvHOBh2DlCIgkrC3s9vkI85Kmks9WMsXnS9fOzbQVsrWjMDsQh2ukUHTVanl4sQVsrmXdxlJICQj5NpqIBy7lqZcuFLIGtm7KexZ5bjAdJpTa4lq9vkcoXStsCnNhK4ZWiBdJp1Ty8GcVBXjMDsQYzYhuF6WslfPFw3ICwfIUDy3TW1mY7wA1TioHusIRzKlrLUL6RueyiItm3gKFiX1S7eK4g2UgdvFLIGtm7KupSPu80vwz1xPiYNtYOi1dBkfpDLvghb0nSDbzkW8GcxKeFvYGUfordLiUBP(kfbgI4eZTb5hIKy80Ty8GcVBXjMDs(rTgcIA9PdlTQ((zDlYzvi62HD3cxZiVBPv3I4esjjUMrUev6wQVsrGHioXCBq(HexZUtqIBy7Amu9vkcoXSts9WMsXtxzLvFLIiFojJIupSPu80vwzCeq3W2fKPaZdkCrs8vjd6w4enuI4ULrUa(8Hs0qcoXSts93)tqi)qqoRcr3fOSYlq9vkcmeXjMBdYpK4A2DcsCdBVBX4bfE3Itm7K8JAnee16thwADU(zDlYzvi62HD3cNOHse3TuFLIiFojJIupSPuCdBFbAwG6RueCIzNK6HnLIBy7lqZcUK6Ruet8W1YOiNAs(5dK4g2E3IXdk8UfzkW8GcVpDyP15PFw3ICwfIUDy3TWjAOeXDl1xPi4eZojX1CEqI2W4tlOQfO(kfbNy2jjUMZds8zyKTHXN6wmEqH3T4eZojJuTpDyPv1OFw3IXdk8UfNy2jPkNjFqDlYzvi62HDF6WslZE)SUfJhu4DloXStsviUnDlYzvi62HDF6t3IdQFwhwA1pRBroRcr3oS7w4enuI4Uv(CQe5bjUOggPdHCovsIJ)N9RGCwfIUlqZcWraDdBxO(kf5f1WiDiKZPssC8)SFfjXxLwGMfO(kfXf1WiDiKZPssC8)SFLLmAJ4g2(c0SadxG6RueCIzNK6HnLIBy7lqZcuFLIiFojJIupSPuCdBFbAwWLuFLIyIhUwgf5utYpFGe3W2xGblqZcWraDdBxmXdxlJICQj5NpqIK(mYBla(cu8c0SadxG6RueCIzNK4AopirBy8Pfuf8fyIteRcrcoi5eZx(zyK4AopO2c0SadxGHlyyiYhr(CsgfPEytPGCwfIUlqZcWraDdBxKpNKrrQh2uks6ZiVTGQGVGd8DbAwaocOBy7coXSts9WMsrsFg5TfOWfyIteRcrIjMV8ZWiVeeRKSePK1xGblqzLxGHlWixWWqKpI85Kmks9WMsb5SkeDxGMfGJa6g2UGtm7KupSPuK0NrEBbkCbM4eXQqKyI5l)mmYlbXkjlrkz9fyWcuw5fGJa6g2UGtm7KupSPuK0NrEBbvbFbh47cmybg0Ty8GcVBvYOnQb00NoSmt)SUf5SkeD7WUBHt0qjI7wgUG85ujYdsCrnmshc5CQKeh)p7xb5SkeDxGMfGJa6g2Uq9vkYlQHr6qiNtLK44)z)ksIVkTanlq9vkIlQHr6qiNtLK44)z)klOKe3W2xGMfONKj5b(k0suYOnQb0SadwGYkVadxq(CQe5bjUOggPdHCovsIJ)N9RGCwfIUlqZcg0NwqvlqRfyq3IXdk8UvbLKufIBtF6Wsr6N1TiNvHOBh2DlCIgkrC3kFovI8GehjQbPKeHryisqoRcr3fOzb4iGUHTl4eZoj1dBkfj9zK3wGcxGIO4fOzb4iGUHTlM4HRLrro1K8ZhirsFg5TfaFbkEbAwGHlq9vkcoXStsCnNhKOnm(0cQc(cmXjIvHibhKCI5l)mmsCnNhuBbAwGHlWWfmme5JiFojJIupSPuqoRcr3fOzb4iGUHTlYNtYOi1dBkfj9zK3wqvWxWb(Uanlahb0nSDbNy2jPEytPiPpJ82cu4cmXjIvHiXeZx(zyKxcIvswIuY6lWGfOSYlWWfyKlyyiYhr(CsgfPEytPGCwfIUlqZcWraDdBxWjMDsQh2uks6ZiVTafUatCIyvismX8LFgg5LGyLKLiLS(cmybkR8cWraDdBxWjMDsQh2uks6ZiVTGQGVGd8DbgSad6wmEqH3Tkz0gPhM4(0Hv13pRBroRcr3oS7w4enuI4Uv(CQe5bjosudsjjcJWqKGCwfIUlqZcWraDdBxWjMDsQh2uks6ZiVTa4lqXlqZcmCbgUadxaocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbM4eXQqKG1LFgg5LGyLKLiLtm)fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGblWGfOzbQVsrKpNKrrQh2ukUHTVad6wmEqH3Tkz0gPhM4(0H156N1TiNvHOBh2DlCIgkrC3kFovI8GenKED4Y2e5xqoRcr3fOzb6jzsEGVcTeKPaZdk8UfJhu4DRjE4AzuKtnj)8bQpDyDE6N1TiNvHOBh2DlCIgkrC3kFovI8GenKED4Y2e5xqoRcr3fOzbgUa9KmjpWxHwcYuG5bf(cuw5fONKj5b(k0smXdxlJICQj5NpqlWGUfJhu4DloXSts9WMY(0Hv1OFw3ICwfIUDy3TWjAOeXDRb9PfOWfOikEbAwq(CQe5bjAi96WLTjYVGCwfIUlqZcuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGMfGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fOzb4iGUHTl4eZoj1dBkfj9zK3wqvWxWb(2Ty8GcVBrMcmpOW7thwM9(zDlYzvi62HD3IXdk8UfzkW8GcVBH8HY8PpsuPBP(kfrdPxhUSnr(fTHXNGR(kfrdPxhUSnr(fFggzBy8PUfYhkZN(ir)pDr8qDlT6w4enuI4U1G(0cu4cuefVanliFovI8GenKED4Y2e5xqoRcr3fOzb4iGUHTl4eZoj1dBkfj9zK3wa8fO4fOzbgUadxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTafUatCIyvisW6YpdJ8sqSsYsKYjM)c0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tlWGfOSYlWWfGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fOzbQVsrWjMDsIR58GeTHXNwqvWxGjorSkej4GKtmF5NHrIR58GAlWGfyWc0Sa1xPiYNtYOi1dBkf3W2xGb9PdlfD)SUf5SkeD7WUBHt0qjI7wgUaCeq3W2fCIzNK6HnLIK(mYBlqHlO6p3cuw5fGJa6g2UGtm7KupSPuK0NrEBbvbFbkYcmybAwaocOBy7IjE4AzuKtnj)8bsK0NrEBbWxGIxGMfy4cuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGMfy4cmCbddr(iYNtYOi1dBkfKZQq0DbAwaocOBy7I85Kmks9WMsrsFg5Tfuf8fCGVlqZcWraDdBxWjMDsQh2uks6ZiVTafUGZTadwGYkVadxGrUGHHiFe5ZjzuK6HnLcYzvi6Uanlahb0nSDbNy2jPEytPiPpJ82cu4co3cmybkR8cWraDdBxWjMDsQh2uks6ZiVTGQGVGd8DbgSad6wmEqH3T(OmJSjJICI8t(0NoS0sX9Z6wKZQq0Td7UfordLiUBHJa6g2UyIhUwgf5utYpFGej9zK3wqvlGGHWVHKd6tlqZcmCbgUGHHiFe5ZjzuK6HnLcYzvi6Uanlahb0nSDr(CsgfPEytPiPpJ82cQc(coW3fOzb4iGUHTl4eZoj1dBkfj9zK3wGcxGjorSkejMy(YpdJ8sqSsYsKswFbgSaLvEbgUaJCbddr(iYNtYOi1dBkfKZQq0DbAwaocOBy7coXSts9WMsrsFg5TfOWfyIteRcrIjMV8ZWiVeeRKSePK1xGblqzLxaocOBy7coXSts9WMsrsFg5Tfuf8fCGVlWGUfJhu4DRKVi2hztNZt9PdlT0QFw3ICwfIUDy3TWjAOeXDlCeq3W2fCIzNK6HnLIK(mYBlOQfqWq43qYb9PfOzbgUadxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTafUatCIyvisW6YpdJ8sqSsYsKYjM)c0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tlWGfOSYlWWfGJa6g2UyIhUwgf5utYpFGej9zK3wa8fO4fOzbQVsrWjMDsIR58GeTHXNwqvWxGjorSkej4GKtmF5NHrIR58GAlWGfyWc0Sa1xPiYNtYOi1dBkf3W2xGbDlgpOW7wjFrSpYMoNN6thwAzM(zDlYzvi62HD3cNOHse3TWraDdBxWjMDsQh2uks6ZiVTa4lqXlqZcmCbgUadxaocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbM4eXQqKG1LFgg5LGyLKLiLtm)fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGblWGfOzbQVsrKpNKrrQh2ukUHTVad6wmEqH3TUep1Qr6uF6WslfPFw3ICwfIUDy3TWjAOeXDldxG6RueCIzNK4AopirBy8Pfuf8fyIteRcrcoi5eZx(zyK4AopO2cuw5fONKj5b(k0sK8fX(iB6CEAbgSanlWWfy4cggI8rKpNKrrQh2ukiNvHO7c0SaCeq3W2f5ZjzuK6HnLIK(mYBlOk4l4aFxGMfGJa6g2UGtm7KupSPuK0NrEBbkCbM4eXQqKyI5l)mmYlbXkjlrkz9fyWcuw5fy4cmYfmme5JiFojJIupSPuqoRcr3fOzb4iGUHTl4eZoj1dBkfj9zK3wGcxGjorSkejMy(YpdJ8sqSsYsKswFbgSaLvEb4iGUHTl4eZoj1dBkfj9zK3wqvWxWb(Uad6wmEqH3TM4HRLrro1K8ZhO(0HLwvF)SUf5SkeD7WUBHt0qjI7wgUadxaocOBy7IjE4AzuKtnj)8bsK0NrEBbkCbM4eXQqKG1LFgg5LGyLKLiLtm)fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGblWGfOzbQVsrKpNKrrQh2ukUHT3Ty8GcVBXjMDsQh2u2NoS06C9Z6wKZQq0Td7UfordLiUBP(kfr(CsgfPEytP4g2(c0SadxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTafUaZO4fOzbQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXNwGblqzLxGHlahb0nSDXepCTmkYPMKF(ajs6ZiVTa4lqXlqZcuFLIGtm7KexZ5bjAdJpTGQGVatCIyvisWbjNy(YpdJexZ5b1wGblWGfOzbgUaCeq3W2fCIzNK6HnLIK(mYBlqHlqlZSaLvEbxs9vkIjE4AzuKtnj)8bs80xGbDlgpOW7w5ZjzuK6HnL9PdlTop9Z6wKZQq0Td7UfordLiUBHJa6g2UGtm7KmsvrsFg5TfOWfCUfOSYlWixWWqKpcoXStYivfKZQq0TBX4bfE3QvJkdYpK6HnL9PdlTQg9Z6wKZQq0Td7UfordLiUBHdtKZ(ioPuIyFbAwq(CQe5bj4eZojrEb5Orjb5SkeDxGMfO(kfbNy2jPEytP4PVanl4sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(0cGVGQFbAwGEsMKh4RqlbNy2jzKQlqZcy8GmrsYPpIAlOQfun6wmEqH3T4eZojvH420NoS0YS3pRBroRcr3oS7w4enuI4Ufomro7J4KsjI9fOzb5ZPsKhKGtm7Ke5fKJgLeKZQq0DbAwG6RueCIzNK6HnLIN(c0SGlP(kfrYxe7JSPZ5jPPhKtjRIGqJsI2W4tla(cQ(UfJhu4DloXStsvot(G6thwAPO7N1TiNvHOBh2DlCIgkrC3chMiN9rCsPeX(c0SG85ujYdsWjMDsI8cYrJscYzvi6Uanlq9vkcoXSts9WMsXtFbAwGHl4gJi5lI9r2058KiPpJ82cu4coplqzLxWLuFLIi5lI9r2058K00dYPKvrqOrjXtFbgSanl4sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(0cQAbv)c0SagpitKKC6JO2cGVafPBX4bfE3Itm7KufIBtF6WYmkUFw3ICwfIUDy3TWjAOeXDlCyIC2hXjLse7lqZcYNtLipibNy2jjYlihnkjiNvHO7c0Sa1xPi4eZoj1dBkfp9fOzbxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNwa8fOiDlgpOW7wCIzNKrQ2NoSmJw9Z6wKZQq0Td7UfordLiUBHdtKZ(ioPuIyFbAwq(CQe5bj4eZojrEb5Orjb5SkeDxGMfO(kfbNy2jPEytP4PVanl4sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(0cGVaZ0Ty8GcVBXjMDsQYzYhuF6WYmMPFw3ICwfIUDy3TWjAOeXDlCyIC2hXjLse7lqZcYNtLipibNy2jjYlihnkjiNvHO7c0Sa1xPi4eZoj1dBkfp9fOzb6jzsEGVcZis(IyFKnDopTanlGXdYejjN(iQTafUafPBX4bfE3Itm7KKGrhkAOW7thwMrr6N1TiNvHOBh2DlCIgkrC3chMiN9rCsPeX(c0SG85ujYdsWjMDsI8cYrJscYzvi6Uanlq9vkcoXSts9WMsXtFbAwWLuFLIi5lI9r2058K00dYPKvrqOrjrBy8PfaFbATanlGXdYejjN(iQTafUafPBX4bfE3Itm7KKGrhkAOW7thwMP67N1TiNvHOBh2DlCIgkrC3s9vkIlXtTAKojE6lqZcUK6Ruet8W1YOiNAs(5dK4PVanl4sQVsrmXdxlJICQj5NpqIK(mYBlOk4lq9vkc9KAKJjzuKFKFfFggzBy8PfuzwaJhu4coXStsviUnccgc)gsoOpTanlWWfy4cggI8rKulC2XKGCwfIUlqZcy8GmrsYPpIAlOQfu9lWGfOSYlGXdYejjN(iQTGQwW5wGblqZcmCbg5cYNtLipibNy2jPA8v58(jFeKZQq0DbkR8cgopOrutm0ul0XZcu4cuKZTad6wmEqH3T0tQroMKrr(r(TpDyzMZ1pRBroRcr3oS7w4enuI4UL6RuexINA1iDs80xGMfy4cmCbddr(isQfo7ysqoRcr3fOzbmEqMij50hrTfu1cQ(fyWcuw5fW4bzIKKtFe1wqvl4ClWGfOzbgUaJCb5ZPsKhKGtm7Kun(QCE)KpcYzvi6UaLvEbdNh0iQjgAQf64zbkCbkY5wGbDlgpOW7wCIzNKQqCB6thwM580pRBX4bfE3Q90P0dtC3ICwfIUDy3NoSmt1OFw3ICwfIUDy3TWjAOeXDl1xPi4eZojX1CEqI2W4tlqHWxGHlGXdYejjN(iQTGQ5fO1cmybAwq(CQe5bj4eZojvJVkN3p5JGCwfIUlqZcgopOrutm0ul0XZcQAbkY56wmEqH3T4eZojv5m5dQpDyzgZE)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsIR58GeTHXNwa8fO(kfbNy2jjUMZds8zyKTHXN6wmEqH3T4eZojv5m5dQpDyzgfD)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsIR58GeTHXNwa8fO4UfJhu4DloXStYiv7thwkII7N1TiNvHOBh2DlCIgkrC3YWfKujPwnRcrlqzLxGrUGbHpH8JfyWc0Sa1xPi4eZojX1CEqI2W4tla(cuFLIGtm7KexZ5bj(mmY2W4tDlgpOW7won1ukh6RtTPpDyPiA1pRBroRcr3oS7w4enuI4UL6RueyiItm3gKFisIXZc0SG85ujYdsWjMDsI8cYrJscYzvi6UanlWWfy4cggI8rWFDiubH5bfUGCwfIUlqZcy8GmrsYPpIAlOQfy2xGblqzLxaJhKjsso9ruBbvTGZTad6wmEqH3T4eZoj)OwdbrT(0HLIyM(zDlYzvi62HD3cNOHse3TuFLIadrCI52G8drsmEwGMfmme5JGtm7KKW1HGCwfIUlqZcUK6Ruet8W1YOiNAs(5dK4PVanlWWfmme5JG)6qOccZdkCb5SkeDxGYkVagpitKKC6JO2cQAbk6fyq3IXdk8UfNy2j5h1AiiQ1NoSuefPFw3ICwfIUDy3TWjAOeXDl1xPiWqeNyUni)qKeJNfOzbddr(i4VoeQGW8GcxqoRcr3fOzbmEqMij50hrTfu1cQ(UfJhu4DloXStYpQ1qquRpDyPivF)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsIR58GeTHXNwqvlq9vkcoXStsCnNhK4ZWiBdJp1Ty8GcVBXjMDssWOdfnu49Pdlf5C9Z6wKZQq0Td7UfordLiUBP(kfbNy2jjUMZds0ggFAbWxG6RueCIzNK4AopiXNHr2ggFAbAwGEsMKh4RqlbNy2jPkNjFqDlgpOW7wCIzNKem6qrdfEF6Wsrop9Z6wiFOmF6Jev6wF2zHoEuiCf956wiFOmF6Je9)0fXd1T0QBX4bfE3ImfyEqH3TiNvHOBh29PpDRqNCk7N1HLw9Z6wKZQq0Td7UfordLiUBLpNkrEqIlQHr6qiNtLK44)z)kiNvHO7c0Sa1xPiUOggPdHCovsIJ)N9RSKrBep9UfJhu4DRckjPke3M(0HLz6N1TiNvHOBh2DlCIgkrC3kFovI8GehjQbPKeHryisqoRcr3fOzbF2zHoEwGcxGI(CDlgpOW7wLmAJ0dtCF6Wsr6N1Ty8GcVBDjEQvJ0PUf5SkeD7WUpDyv99Z6wKZQq0Td7UfordLiUB9zNf64zbkCbvVI7wmEqH3Ts(IyFKnDop1NoSox)SUf5SkeD7WUBHt0qjI7wQVsrWjMDsQh2ukUHTVanlahb0nSDbNy2jPEytPiPpJ8w3IXdk8UvRgvgKFi1dBk7thwNN(zDlgpOW7wFuMr2Krror(jF6wKZQq0Td7(0Hv1OFw3IXdk8U1epCTmkYPMKF(a1TiNvHOBh29PdlZE)SUfJhu4DloXSts9WMYUf5SkeD7WUpDyPO7N1TiNvHOBh2DlCIgkrC3s9vkI85Kmks9WMsXnS9UfJhu4DR85Kmks9WMY(0HLwkUFw3ICwfIUDy3Ty8GcVBPNuJCmjJI8J8B36snCI0hu4DlZIgTGQlmRlyIf0QwpIoFOfW(ciyMKxqLNy2PfaBiUnl4(sKFSGPMwWzXywvqLxDlWg53WEbphIATfKp3r(XcQ8eZoTGZlUoel48xwqLNy2PfCEX1XcqTfmme5dDnFb20cWSR9SGxJwq1fM1fyJMAKVGPMwWzXywvqLxDlWg53WEbphIATfytla5dL5tFwWutlOYnRlaxZUtqMVGwSaBsBiOf0yt0cqJOBHt0qjI7wg5cggI8rWjMDss46qqoRcr3fOzbxs9vkIjE4AzuKtnj)8bs80xGMfCj1xPiM4HRLrro1K8ZhirsFg5Tfuf8fy4cy8GcxWjMDsQcXTrqWq43qYb9PfuzwG6Rue6j1ihtYOi)i)k(mmY2W4tlWG(0HLwA1pRBroRcr3oS7wmEqH3T0tQroMKrr(r(TBDPgor6dk8U15VSGQlmRlOMBU2ZcujYxWRr3fCFjYpwWutl4SymRlWg53W28fytAdbTGxJwaAwWelOvTEeD(qlG9fqWmjVGkpXStla2qCBwaYxWutlOAhvNcQ8QBb2i)g2IUfordLiUBDJrK8fX(iB6CEsK0NrEBbkCbNBbkR8cUK6RuejFrSpYMoNNKMEqoLSkccnkjAdJpTafUaf3NoS0Ym9Z6wKZQq0Td7UfordLiUBP(kfHEsnYXKmkYpYVIN(c0SGlP(kfXepCTmkYPMKF(ajE6lqZcUK6Ruet8W1YOiNAs(5dKiPpJ82cQc(cy8GcxWjMDsQcXTrqWq43qYb9PUfJhu4DloXStsviUn9PdlTuK(zDlYzvi62HD3IXdk8UfNy2jPkNjFqDRl1WjsFqH3TQCiBwP2cGnNjFqlGNfm10ci)UGOSGkV6wGDn5liFUJ8Jfm10cQ8eZoTaffN)WvAbq0b5xovQBHt0qjI7wQVsrWjMDsQh2ukE6lqZcuFLIGtm7KupSPuK0NrEBbvTGd8DbAwq(CQe5bj4eZojrEb5Orjb5SkeD7thwAv99Z6wKZQq0Td7UfJhu4DloXStsvot(G6wxQHtK(GcVBv5q2SsTfaBot(GwaplyQPfq(DbrzbtnTGQDuDlWg53WEb21KVG85oYpwWutlOYtm70cuuC(dxPfarhKF5uPUfordLiUBP(kfr(CsgfPEytP4PVanlq9vkcoXSts9WMsXnS9fOzbQVsrKpNKrrQh2uks6ZiVTGQGVGd8DbAwq(CQe5bj4eZojrEb5Orjb5SkeD7thwADU(zDlYzvi62HD3cxZiVBPv3I4esjjUMrUev6wQVsrGHioXCBq(HexZUtqIBy7Amu9vkcoXSts9WMsXtxzLn0ihgI8reMOupSPKUAmu9vkI85Kmks9WMsXtxzLXraDdBxqMcmpOWfjXxLmWad6w4enuI4U1LuFLIyIhUwgf5utYpFGep9fOzbddr(i4eZojjCDiiNvHO7c0SadxG6RuexINA1iDsCdBFbkR8cy8GmrsYPpIAla(c0AbgSanl4sQVsrmXdxlJICQj5NpqIK(mYBlqHlGXdkCbNy2j5h1AiiQjiyi8Bi5G(u3IXdk8UfNy2j5h1AiiQ1NoS0680pRBroRcr3oS7wmEqH3T4eZoj)OwdbrTUfUMrE3sRUfordLiUBP(kfbgI4eZTb5hIKy80NoS0QA0pRBroRcr3oS7w4enuI4UL6RueCIzNK4AopirBy8Pfuf8fyIteRcrIjMV8ZWiX1CEqTUfJhu4DloXStYiv7thwAz27N1TiNvHOBh2DlCIgkrC3s9vkI85Kmks9WMsXtFbkR8c(SZcD8SafUaTox3IXdk8UfNy2jPke3M(0HLwk6(zDlYzvi62HD3IXdk8UfzkW8GcVBH8HY8PpsuPB9zNf64rHWn7NRBH8HY8Pps0)txepu3sRUfordLiUBP(kfr(CsgfPEytP4g2(c0Sa1xPi4eZoj1dBkf3W27thwMrX9Z6wmEqH3T4eZojv5m5dQBroRcr3oS7tF6wfKZqs1x69Z6WsR(zDlYzvi62HD3IXdk8UfNy2j5h1AiiQ1TW1mY7wA1TWjAOeXDl1xPiWqeNyUni)qKeJN(0HLz6N1Ty8GcVBXjMDsQcXTPBroRcr3oS7thwks)SUfJhu4DloXStsvot(G6wKZQq0Td7(0N(0TmrzdfEhwMrXMrlfFofBMULnNoYpADRQPkVAdRZpSoFz0lybNvtla91JCwqjYfODnN)Wvs7fKu16Hs6UGw8PfWVj(8q3fGRz)GAI1yJa50cueJEbgv4MOCO7c0gh(9HgrL0EbtSaTXHFFOrujb5SkeD1Eb8SGZRzPrSad1cgdeRXgbYPfu9g9cmQWnr5q3fOno87dnIkP9cMybAJd)(qJOscYzvi6Q9c4zbNxZsJybgQfmgiwJncKtl4Cg9cmQWnr5q3fOno87dnIkP9cMybAJd)(qJOscYzvi6Q9c4zbNxZsJybgQfmgiwJncKtlWSB0lWOc3eLdDxG24WVp0iQK2lyIfOno87dnIkjiNvHOR2lGNfCEnlnIfyOwWyGyn2iqoTaT0YOxGrfUjkh6UaTXHFFOrujTxWelqBC43hAevsqoRcrxTxapl48AwAelWqTGXaXASrGCAbAz2n6fyuHBIYHUlqBC43hAevs7fmXc0gh(9HgrLeKZQq0v7fWZcoVMLgXcmulymqSgBeiNwGwkAJEbgv4MOCO7c0gh(9HgrL0EbtSaTXHFFOrujb5SkeD1Eb8SGZRzPrSad1cgdeRXgbYPfygfTrVaJkCtuo0DbAJd)(qJOsAVGjwG24WVp0iQKGCwfIUAVaEwW51S0iwGHAbJbI1414QPkVAdRZpSoFz0lybNvtla91JCwqjYfODb1Qr(Hm0jNsTxqsvRhkP7cAXNwa)M4ZdDxaUM9dQjwJncKtlqlJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHMbgdeRXgbYPfygJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgQfmgiwJncKtlqrm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlO6n6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtl4Cg9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfCoJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxapl48AwAelWqTGXaXASrGCAbAPyJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHMbgdeRXgbYPfO15XOxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHAbJbI1yJa50c0srB0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGwkAJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxapl48AwAelWqTGXaXASrGCAbMrXg9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfygZy0lWOc3eLdDxG2ddr(iQK2lyIfO9WqKpIkjiNvHOR2lWqTGXaXA8AC1uLxTH15hwNVm6fSGZQPfG(6rolOe5c0o0jNsTxqsvRhkP7cAXNwa)M4ZdDxaUM9dQjwJncKtlqlJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50cmJrVaJkCtuo0DbANpNkrEqIkP9cMybANpNkrEqIkjiNvHOR2lWqTGXaXASrGCAbAPyJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgQfmgiwJncKtlqlfXOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fWZcoVMLgXcmulymqSgBeiNwGwvVrVaJkCtuo0DbANpNkrEqIkP9cMybANpNkrEqIkjiNvHOR2lGNfCEnlnIfyOwWyGyn2iqoTaToNrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVad1cgdeRXRXvtvE1gwNFyD(YOxWcoRMwa6Rh5SGsKlq7mgEqHR9csQA9qjDxql(0c43eFEO7cW1SFqnXASrGCAbAz0lWOc3eLdDxG2ddr(iQK2lyIfO9WqKpIkjiNvHOR2lWqTGXaXASrGCAbMXOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTGQ3OxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHAbJbI1yJa50coNrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVad1cgdeRXgbYPfOOn6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOwWyGyn2iqoTaTu0g9cmQWnr5q3fO9WqKpIkP9cMybApme5JOscYzvi6Q9cmulymqSgBeiNwGzuSrVaJkCtuo0DbANpNkrEqIkP9cMybANpNkrEqIkjiNvHOR2lWqTGXaXASrGCAbMrlJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50cmJIy0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGzQEJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1414QPkVAdRZpSoFz0lybNvtla91JCwqjYfO9Lk8dA0EbjvTEOKUlOfFAb8BIpp0Db4A2pOMyn2iqoTaZy0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cm0mWyGyn2iqoTafXOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOzGXaXASrGCAbvVrVaJkCtuo0DbwOVrTGMs(WWSGZ3xWelWiE8cUitOgk8fe6uYtKlWqfyWcmulymqSgBeiNwW5m6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbvdJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50c0QAy0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGwkAJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50cmJwg9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfygfXOxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxapl48AwAelWqTGXaXASrGCAbMrrm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJxJRMQ8QnSo)W68LrVGfCwnTa0xpYzbLixG26jHJVkpAVGKQwpus3f0IpTa(nXNh6UaCn7hutSgBeiNwW5XOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTaZOyJEbgv4MOCO7c0gh(9HgrL0EbtSaTXHFFOrujb5SkeD1EbgQfmgiwJncKtlWmAz0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGz0YOxGrfUjkh6UaTXHFFOrujTxWelqBC43hAevsqoRcrxTxGHAbJbI1yJa50cmJzm6fyuHBIYHUlqBC43hAevs7fmXc0gh(9HgrLeKZQq0v7fyOwWyGyn2iqoTaZOOn6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbMrrB0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGIu9g9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVaEwW51S0iwGHAbJbI1yJa50cuKZz0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9c4zbNxZsJybgQfmgiwJxJRMQ8QnSo)W68LrVGfCwnTa0xpYzbLixG24iGUHT30EbjvTEOKUlOfFAb8BIpp0Db4A2pOMyn2iqoTaTm6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbAz0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGzm6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbMXOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTafXOxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHMbgdeRXgbYPfOig9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfu9g9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfCEm6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbMDJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgAgymqSgBeiNwGI2OxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHMbgdeRXgbYPfOLwg9cmQWnr5q3fO9WqKpIkP9cMybApme5JOscYzvi6Q9cm0mWyGyn2iqoTaTueJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgQfmgiwJncKtlqRQ3OxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHAbJbI1yJa50c0YSB0lWOc3eLdDxG2ddr(iQK2lyIfO9WqKpIkjiNvHOR2lWqTGXaXA8AC1uLxTH15hwNVm6fSGZQPfG(6rolOe5c0Mds7fKu16Hs6UGw8PfWVj(8q3fGRz)GAI1yJa50c0YOxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHMbgdeRXgbYPfOLrVaJkCtuo0DbANpNkrEqIkP9cMybANpNkrEqIkjiNvHOR2lWqTGXaXASrGCAbMXOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOzGXaXASrGCAbkIrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVadndmgiwJncKtlqrm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlO6n6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtl4Cg9cmQWnr5q3fOD(CQe5bjQK2lyIfOD(CQe5bjQKGCwfIUAVad1cgdeRXgbYPfCEm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlOAy0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGz3OxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTafTrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVadndmgiwJncKtlqlfB0lWOc3eLdDxG2ddr(iQK2lyIfO9WqKpIkjiNvHOR2lWqZaJbI1yJa50c0srm6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fyOzGXaXASrGCAbADEm6fyuHBIYHUlq7HHiFevs7fmXc0EyiYhrLeKZQq0v7fWZcoVMLgXcmulymqSgBeiNwGwvdJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50c0YSB0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGwkAJEbgv4MOCO7c0oFovI8Gevs7fmXc0oFovI8GevsqoRcrxTxGHAbJbI1yJa50cmJIn6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlWmAz0lWOc3eLdDxG25ZPsKhKOsAVGjwG25ZPsKhKOscYzvi6Q9cmulymqSgBeiNwGzmJrVaJkCtuo0DbANpNkrEqIkP9cMybANpNkrEqIkjiNvHOR2lWqTGXaXASrGCAbMrrm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlWmvVrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVad1cgdeRXgbYPfyMQ3OxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTaZCoJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgQfmgiwJncKtlWmNZOxGrfUjkh6UaTZNtLipirL0EbtSaTZNtLipirLeKZQq0v7fyOwWyGyn2iqoTaZunm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlqr0YOxGrfUjkh6UaThgI8rujTxWelq7HHiFevsqoRcrxTxGHAbJbI1yJa50cueTm6fyuHBIYHUlq785ujYdsujTxWelq785ujYdsujb5SkeD1EbgQfmgiwJncKtlqrmJrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVadndmgiwJncKtlqrueJEbgv4MOCO7c0EyiYhrL0EbtSaThgI8rujb5SkeD1EbgQfmgiwJxJRMQ8QnSo)W68LrVGfCwnTa0xpYzbLixG28x205V2liPQ1dL0DbT4tlGFt85HUlaxZ(b1eRXgbYPfOLrVaJkCtuo0DbApme5JOsAVGjwG2ddr(iQKGCwfIUAVad1cgdeRXRXN)VEKdDxGwATagpOWxaeQnnXAC3spJccI6wv2k7cmR8bTGkpXStRXv2k7cmRSslWmkI5lWmk2mATgVgxzRSlOAt)WeTatCIyvisWFztN)la5lOWMICbrzbnAgKF0e8x205)cmext4tlqP4LlOPt4fe6dk8MbI14kBLDbMfnAbJs6imdTal03Owqn7xiKFSGOSaCn7obTaKpuMp9bf(cqEBi(UGOSaTXSJjijJhu4AlwJxJz8GcVj0tchFvEQaUc4eZojr(qqqeEwJz8GcVj0tchFvEQaUc4eZojl8hbH4CnMXdk8MqpjC8v5Pc4kah(5BVKKF2z5b9xJz8GcVj0tchFvEQaUcmXjIvHiZD(tW5VSPZFZdD4j1OX8lv4h0aVrZG8JMG)YMo)xJz8GcVj0tchFvEQaUcmXjIvHiZD(tWjtHuhpMh6WtQrJ5xQWpObUwNBnMXdk8MqpjC8v5Pc4kWeNiwfIm35pbxpj9heKKmfMh6WB0yoQa3W85ujYds0q61HlBtKFnmEqMij50hrnfQvfgQvLXqJehMiN9r4eodOiVgyGbMBIHEeCTm3ed9ijb1i4kEnMXdk8MqpjC8v5Pc4kWeNiwfIm35pbVMnrYqNC6AEOdVrJ5OcCdz8GmrsYPpIAk0mkRSjorSkej0ts)bbjjtbCTuwztCIyvisWFztN)W1YaZnXqpcUwMBIHEKKGAeCfVgZ4bfEtONeo(Q8ubCfyIteRcrM78NGxqodjvFPBEOdVrJ5MyOhbxXRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4MnfL8sqSsqOpAKvE1zEOdpPgnMFPc)Gg4ADU1ygpOWBc9KWXxLNkGRatCIyviYCN)eCZMIsQNuBy8jKFih0Nmp0HNuJgZVuHFqdCf9AmJhu4nHEs44RYtfWvGjorSkezUZFcUztrjnlR2WUez12sEjiwjZdD4j1OX8lv4h0axlfVgZ4bfEtONeo(Q8ubCfyIteRcrM78NGNn5NHrEjiwjzjs5eZ38qhEsnAm)sf(bnWp3AmJhu4nHEs44RYtfWvGjorSkezUZFcE2KFgg5LGyLKLiLzOBEOdpPgnMFPc)Gg4NBnMXdk8MqpjC8v5Pc4kWeNiwfIm35pbpBYpdJ8sqSsYsKsw38qhEsnAm)sf(bnWnJIxJz8GcVj0tchFvEQaUcmXjIvHiZD(tW)Xi1tct0voX8LQkzEOdpPgnMFPc)Gg4kYAmJhu4nHEs44RYtfWvGjorSkezUZFc(pg5NHrEjiwjzjs5eZ38qhEsnAm)sf(bnW1sXRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4)yKFgg5LGyLKLiLSU5Ho8KA0y(Lk8dAGR15wJz8GcVj0tchFvEQaUcmXjIvHiZD(tWzD5NHrEjiwjzjs5eZ38qhEsnAm)sf(bnW1sXRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4SU8ZWiVeeRKSeP8hJ5Ho8KA0y(Lk8dAGBgfVgZ4bfEtONeo(Q8ubCfyIteRcrM78NGNHU8ZWiVeeRKSePCI5BEOdVrJ5MyOhb3mkUA2WZvzWHFFOrWjMDsQNXfDOKbRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4tmF5NHrEjiwjzjsjRBEOdVrJ5MyOhb)CvOLIRmgIdtKZ(iC0r9ilmPSYgId)(qJGtm7KupJl6qjnmEqMij50hrTQuedmOcToxLXqCyIC2hXjLse7AYNtLipibNy2jjYlihnkPHXdYejjN(iQPqZyWAmJhu4nHEs44RYtfWvGjorSkezUZFc(eZx(zyKxcIvswIuMHU5Ho8gnMBIHEeCZO4Qzdn7vgC43hAeCIzNK6zCrhkzWAmJhu4nHEs44RYtfWvGjorSkezUZFcUkNjFqYp7SuhpMh6WB0yoQahhMiN9r4OJ6rwyYCtm0JGFEuC1SHFUnuQK0ed9OkJwkwXgSgZ4bfEtONeo(Q8ubCfyIteRcrM78NGRYzYhK8Zol1XJ5Ho8gnMJkWXHjYzFeNukrSBUjg6rWv0NRA2Wp3gkvsAIHEuLrlfRydwJz8GcVj0tchFvEQaUcmXjIvHiZD(tWv5m5ds(zNL64X8qhEJgZrf4M4eXQqKqLZKpi5NDwQJh4k2Ctm0JGB2vC1SHFUnuQK0ed9OkJwkwXgSgZ4bfEtONeo(Q8ubCfyIteRcrM78NGZ6YpYr)3x(zNL64X8qhEsnAm)sf(bnW16CRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4tmF5NHrIR58GAMh6WtQrJ5xQWpObUzwJz8GcVj0tchFvEQaUcmXjIvHiZD(tW5GKtmF5NHrIR58GAMh6WtQrJ5xQWpObUzwJz8GcVj0tchFvEQaUcmXjIvHiZD(tWlOwnYpKHo5uAEOdVrJ5MyOhbxRkJHu16H01PRG(6kLedjJ86SJjLv2WHHiFe5ZjzuK6HnLAmCyiYhbNy2jjHRdLv2iXHjYzFeNukrSBGgdnsCyIC2hHt4mGI8QSYmEqMij50hrn4APSY5ZPsKhKOH0Rdx2Mi)gyGbRXRXmEqH3e6jHJVkpvaxbM4eXQqK5o)j4SUmC5RrMh6WB0yUjg6rWPQ1dPRtxXNXSAsYwnrJ8)AiSYktvRhsxNUIdi(I4jYMuLVhKYktvRhsxNUIdi(I4jYM8txgccfUYktvRhsxNUIlNN(r4YlHpj1Ftsnm5yszLPQ1dPRtxbYB48nSkejRwp2N3xEjtimPSYu16H01PROfpiiAgKFiZNQskRmvTEiDD6kApxfkIRK)0uRuBuwzQA9q660vyZNiNYMSKHFvwzQA9q660vuG4pjJIuLNbIwJz8GcVj0tchFvEQaUcmXjIvHiZD(tW5GKtmF5NHrIR58GAMh6WtQrJ5xQWpObUzwJz8GcVj0tchFvEQaUcmXjIvHiZD(tWjtHuhpMh6WtQrJ5xQWpObUwNBnMXdk8MqpjC8v5Pc4k4JYmsj6Zh0AmJhu4nHEs44RYtfWvqjJ2OgqJ5OcCJ0eNiwfIe6jP)GGKKPaUwAYNtLipiXf1WiDiKZPssC8)SFxJz8GcVj0tchFvEQaUc4eZojvH42yoQa3inXjIvHiHEs6piijzkGRLgJmFovI8GexudJ0HqoNkjXX)Z(DnMXdk8MqpjC8v5Pc4kGmfyEqHBoQa3eNiwfIe6jP)GGKKPaUwRXRXmEqH3QaUcWXZhkB6ee0AmJhu4TkGRatCIyviYCN)e8A2ejdDYPR5Ho8gnMBIHEeCTmhvGBIteRcrIA2ejdDYPlCfRrpjtYd8vOLGmfyEqHRXinmFovI8GenKED4Y2e5xzLZNtLipiXqF9iziPnN6gSgZ4bfERc4kWeNiwfIm35pbVMnrYqNC6AEOdVrJ5MyOhbxlZrf4M4eXQqKOMnrYqNC6cxXAuFLIGtm7KupSPuCdBxdocOBy7coXSts9WMsrsFg5nngMpNkrEqIgsVoCzBI8RSY5ZPsKhKyOVEKmK0MtDdwJz8GcVvbCfyIteRcrM78NGxqodjvFPBEOdVrJ5MyOhbxlZrf4QVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXN0yKQVsrKpisgf5uNe1epDnQrRPPGoQhzsFg5TQGBOHF25Z3z8GcxWjMDsQcXTrGJ2yqLHXdkCbNy2jPke3gbbdHFdjh0NmynMXdk8wfWvWRrYp7S8G(MJkWnCyiYhb5qOJ6HC6Q5Zol0XtvWn7kwZNDwOJhfc)8CoduwzdnYHHiFeKdHoQhYPRMp7Sqhpvb3SFodwJz8GcVvbCfOhdkCZrf4QVsrWjMDsQh2ukE6RXmEqH3QaUcg0NK2CQBoQapFovI8Ged91JKHK2CQRr9vkccMA(1gu4INUgdXraDdBxWjMDsQh2uksIVkPSYQrRPPGoQhzsFg5TQGx9k2G1ygpOWBvaxbqOJ6PjpF7Dp(KpMJkWvFLIGtm7KupSPuCdBxJ6Rue5ZjzuK6HnLIBy7AUK6Ruet8W1YOiNAs(5dK4g2(AmJhu4TkGRav(qgf5Ki8PM5OcC1xPi4eZoj1dBkf3W21O(kfr(CsgfPEytP4g2UMlP(kfXepCTmkYPMKF(ajUHTVgZ4bfERc4kqLYgLNq(H5OcC1xPi4eZoj1dBkfp91ygpOWBvaxbQqrCLLxQK5OcC1xPi4eZoj1dBkfp91ygpOWBvaxbfusQqrCnhvGR(kfbNy2jPEytP4PVgZ4bfERc4kGDm1MKHKygcYCubU6RueCIzNK6HnLIN(AmJhu4TkGRGxJKOH(nZrf4QVsrWjMDsQh2ukE6RXmEqH3QaUcEnsIg6BovkeEKo)j4hq8fXtKnPkFpiZrf4QVsrWjMDsQh2ukE6kRmocOBy7coXSts9WMsrsFg5nfc)CNtZLuFLIyIhUwgf5utYpFGep91ygpOWBvaxbVgjrd9n35pbN(6kLedjJ86SJjZrf44iGUHTl4eZoj1dBkfj9zK3QcUHAPivunQmM4eXQqKG1LHlFnYG1ygpOWBvaxbVgjrd9n35pb)MeFlOKKMOwJGmhvGJJa6g2UGtm7KupSPuK0NrEtHWnJIvwzJ0eNiwfIeSUmC5RrW1szLnCqFcUI1yIteRcrIcQvJ8dzOtoLW1st(CQe5bjAi96WLTjYVbRXmEqH3QaUcEnsIg6BUZFcElEqs0HJgknhvGJJa6g2UGtm7KupSPuK0NrEtHWvefRSYgPjorSkejyDz4YxJGR1AmJhu4TkGRGxJKOH(M78NGFaPKETmksU1qFeepOWnhvGJJa6g2UGtm7KupSPuK0NrEtHWnJIvwzJ0eNiwfIeSUmC5RrW1szLnCqFcUI1yIteRcrIcQvJ8dzOtoLW1st(CQe5bjAi96WLTjYVbRXmEqH3QaUcEnsIg6BUZFc(NXSAsYwnrJ8)AiS5OcCCeq3W2fCIzNK6HnLIK(mYBvb)CAm0inXjIvHirb1Qr(Hm0jNs4APSYd6tkuruSbRXmEqH3QaUcEnsIg6BUZFc(NXSAsYwnrJ8)AiS5OcCCeq3W2fCIzNK6HnLIK(mYBvb)CAmXjIvHirb1Qr(Hm0jNs4APr9vkI85Kmks9WMsXtxJ6Rue5ZjzuK6HnLIK(mYBvb3qTuC185Qm5ZPsKhKOH0Rdx2Mi)gOzqFQkfrXRXmEqH3QaUcWmeKKXdkCjeQnM78NGZbzEBseEGRL5OcCgpitKKC6JOMcnZAmJhu4TkGRamdbjz8GcxcHAJ5o)j41C(dxjZBtIWdCTmhvGJdtKZ(ioPuIyxt(CQe5bj4eZojrEb5Orjnddr(iYNtYOi1dBkxJRSl4SAAbfuRg5hli0jNYfOshiVTaB0uVGQDuDlG97ckOwn1wqjYfyug1c0Za3wWel41OfCFjYpwWzXywvqLxDRXmEqH3QaUcWmeKKXdkCjeQnM78NGxqTAKFidDYP082Ki8axlZrf4M4eXQqKOMnrYqNC6cxXAmXjIvHirb1Qr(Hm0jNY1ygpOWBvaxbygcsY4bfUec1gZD(tWdDYP082Ki8axlZrf4M4eXQqKOMnrYqNC6cxXRXmEqH3QaUcWmeKKXdkCjeQnM78NGZFztN)M3MeHh4AzoQaVrZG8JMG)YMo)HR1AmJhu4TkGRamdbjz8GcxcHAJ5o)j44iGUHT3wJz8GcVvbCfGziijJhu4siuBm35pbpJHhu4M3MeHh4AzoQa3eNiwfIefKZqs1x6Wv8AmJhu4TkGRamdbjz8GcxcHAJ5o)j4fKZqs1x6M3MeHh4AzoQa3eNiwfIefKZqs1x6W1AnMXdk8wfWvaMHGKmEqHlHqTXCN)e8FyI(KpRXRXv2fW4bfEtWFztN)WXSJjijJhu4MJkWz8GcxqMcmpOWf4A2Dcc5hA(SZcD8Oq4k6ZTgZ4bfEtWFztN)vaxbKPaZdkCZrf4F2zHoEQcUjorSkejitHuhpAmehb0nSDXepCTmkYPMKF(ajs6ZiVvfCgpOWfKPaZdkCbbdHFdjh0NuwzCeq3W2fCIzNK6HnLIK(mYBvbNXdkCbzkW8GcxqWq43qYb9jLv2WHHiFe5ZjzuK6HnLAWraDdBxKpNKrrQh2uks6ZiVvfCgpOWfKPaZdkCbbdHFdjh0NmWanQVsrKpNKrrQh2ukUHTRr9vkcoXSts9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBFnMXdk8MG)YMo)RaUcUep1Qr6K5OcCCeq3W2fCIzNK6HnLIK(mYBWvSgdvFLIiFojJIupSPuCdBxJH4iGUHTlM4HRLrro1K8ZhirsFg5nfAIteRcrcwx(zyKxcIvswIuoX8vwzCeq3W2ft8W1YOiNAs(5dKiPpJ8gCfBGbRXmEqH3e8x205FfWvWhLzKnzuKtKFYhZrf44iGUHTl4eZoj1dBkfj9zK3GRyngQ(kfr(CsgfPEytP4g2UgdXraDdBxmXdxlJICQj5NpqIK(mYBk0eNiwfIeSU8ZWiVeeRKSePCI5RSY4iGUHTlM4HRLrro1K8ZhirsFg5n4k2adwJz8GcVj4VSPZ)kGRGKVi2hztNZtRXmEqH3e8x205FfWvqRgvgKFi1dBknhvGR(kfbNy2jPEytP4g2UgCeq3W2fCIzNK6HnLIjFKmPpJ8Mcz8Gcx0QrLb5hs9WMsb(MAuFLIiFojJIupSPuCdBxdocOBy7I85Kmks9WMsXKpsM0NrEtHmEqHlA1OYG8dPEytPaFtnxs9vkIjE4AzuKtnj)8bsCdBFnMXdk8MG)YMo)RaUcYNtYOi1dBknhvGR(kfr(CsgfPEytP4g2UgCeq3W2fCIzNK6HnLIK(mYBRXmEqH3e8x205FfWvWepCTmkYPMKF(azoQa3qCeq3W2fCIzNK6HnLIK(mYBWvSg1xPiYNtYOi1dBkf3W2nqzL1tYK8aFfAjYNtYOi1dBkxJz8GcVj4VSPZ)kGRGjE4AzuKtnj)8bYCuboocOBy7coXSts9WMsrsFg5TQoNI1O(kfr(CsgfPEytP4g2UgQ1ihtctOgkCzuK6uwi8GcxqoRcr31ygpOWBc(lB68Vc4kGtm7KupSP0CubU6Rue5ZjzuK6HnLIBy7AWraDdBxmXdxlJICQj5NpqIK(mYBk0eNiwfIeSU8ZWiVeeRKSePCI5VgZ4bfEtWFztN)vaxbCIzNKQCM8bzoQax9vkcoXSts9WMsXtxJ6RueCIzNK6HnLIK(mYBvbNXdkCbNy2j5h1AiiQjiyi8Bi5G(Kg1xPi4eZojX1CEqI2W4tWvFLIGtm7KexZ5bj(mmY2W4tRXmEqH3e8x205FfWvaNy2jzKQMJkWvFLIGtm7KexZ5bjAdJpvL6RueCIzNK4AopiXNHr2ggFsJ6Rue5ZjzuK6HnLIBy7AuFLIGtm7KupSPuCdBxZLuFLIyIhUwgf5utYpFGe3W2xJz8GcVj4VSPZ)kGRaoXStsvot(GmhvGR(kfr(CsgfPEytP4g2Ug1xPi4eZoj1dBkf3W21Cj1xPiM4HRLrro1K8ZhiXnSDnQVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXNwJz8GcVj4VSPZ)kGRaoXStYpQ1qquZCubU6RueyiItm3gKFisIXJ54Ag5W1YCItiLK4Ag5subU6RueyiItm3gKFiX1S7eK4g2UgdvFLIGtm7KupSPu80vwz1xPiYNtYOi1dBkfpDLvghb0nSDbzkW8GcxKeFvYG1ygpOWBc(lB68Vc4kGtm7K8JAnee1mhvGBK85dLOHeCIzNK6V)NGq(HGCwfIUkRS6RueyiItm3gKFiX1S7eK4g2U54Ag5W1YCItiLK4Ag5subU6RueyiItm3gKFiX1S7eK4g2UgdvFLIGtm7KupSPu80vwz1xPiYNtYOi1dBkfpDLvghb0nSDbzkW8GcxKeFvYG1ygpOWBc(lB68Vc4kGmfyEqHBoQax9vkI85Kmks9WMsXnSDnQVsrWjMDsQh2ukUHTR5sQVsrmXdxlJICQj5NpqIBy7RXmEqH3e8x205FfWvaNy2jzKQMJkWvFLIGtm7KexZ5bjAdJpvL6RueCIzNK4AopiXNHr2ggFAnMXdk8MG)YMo)RaUc4eZojv5m5dAnMXdk8MG)YMo)RaUc4eZojvH42SgVgZ4bfEtWbbVKrBudOXCubE(CQe5bjUOggPdHCovsIJ)N9RgCeq3W2fQVsrErnmshc5CQKeh)p7xrs8vjnQVsrCrnmshc5CQKeh)p7xzjJ2iUHTRXq1xPi4eZoj1dBkf3W21O(kfr(CsgfPEytP4g2UMlP(kfXepCTmkYPMKF(ajUHTBGgCeq3W2ft8W1YOiNAs(5dKiPpJ8gCfRXq1xPi4eZojX1CEqI2W4tvb3eNiwfIeCqYjMV8ZWiX1CEqnngA4WqKpI85Kmks9WMsn4iGUHTlYNtYOi1dBkfj9zK3Qc(b(Qbhb0nSDbNy2jPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuY6gOSYgAKddr(iYNtYOi1dBk1GJa6g2UGtm7KupSPuK0NrEtHM4eXQqKyI5l)mmYlbXkjlrkzDduwzCeq3W2fCIzNK6HnLIK(mYBvb)aFnWG1ygpOWBcoOkGRGckjPke3gZrf4gMpNkrEqIlQHr6qiNtLK44)z)Qbhb0nSDH6RuKxudJ0HqoNkjXX)Z(vKeFvsJ6RuexudJ0HqoNkjXX)Z(vwqjjUHTRrpjtYd8vOLOKrBudOXaLv2W85ujYdsCrnmshc5CQKeh)p7xnd6tvPLbRXmEqH3eCqvaxbLmAJ0dtS5Oc885ujYdsCKOgKssegHHin4iGUHTl4eZoj1dBkfj9zK3uOIOyn4iGUHTlM4HRLrro1K8ZhirsFg5n4kwJHQVsrWjMDsIR58GeTHXNQcUjorSkej4GKtmF5NHrIR58GAAm0WHHiFe5ZjzuK6HnLAWraDdBxKpNKrrQh2uks6ZiVvf8d8vdocOBy7coXSts9WMsrsFg5nfAIteRcrIjMV8ZWiVeeRKSePK1nqzLn0ihgI8rKpNKrrQh2uQbhb0nSDbNy2jPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuY6gOSY4iGUHTl4eZoj1dBkfj9zK3Qc(b(AGbRXmEqH3eCqvaxbLmAJ0dtS5Oc885ujYdsCKOgKssegHHin4iGUHTl4eZoj1dBkfj9zK3GRyngAOH4iGUHTlM4HRLrro1K8ZhirsFg5nfAIteRcrcwx(zyKxcIvswIuoX81O(kfbNy2jjUMZds0ggFcU6RueCIzNK4AopiXNHr2ggFYaLv2qCeq3W2ft8W1YOiNAs(5dKiPpJ8gCfRr9vkcoXStsCnNhKOnm(uvWnXjIvHibhKCI5l)mmsCnNhuZad0O(kfr(CsgfPEytP4g2UbRXmEqH3eCqvaxbt8W1YOiNAs(5dK5Oc885ujYds0q61HlBtKFn6jzsEGVcTeKPaZdk81ygpOWBcoOkGRaoXSts9WMsZrf45ZPsKhKOH0Rdx2Mi)AmupjtYd8vOLGmfyEqHRSY6jzsEGVcTet8W1YOiNAs(5dKbRXmEqH3eCqvaxbKPaZdkCZrf4d6tkuruSM85ujYds0q61HlBtKFnQVsrWjMDsIR58GeTHXNQcUjorSkej4GKtmF5NHrIR58GAAWraDdBxmXdxlJICQj5NpqIK(mYBWvSgCeq3W2fCIzNK6HnLIK(mYBvb)aFxJz8GcVj4GQaUcitbMhu4MJkWh0NuOIOyn5ZPsKhKOH0Rdx2Mi)AWraDdBxWjMDsQh2uks6ZiVbxXAm0qdXraDdBxmXdxlJICQj5NpqIK(mYBk0eNiwfIeSU8ZWiVeeRKSePCI5Rr9vkcoXStsCnNhKOnm(eC1xPi4eZojX1CEqIpdJSnm(KbkRSH4iGUHTlM4HRLrro1K8ZhirsFg5n4kwJ6RueCIzNK4AopirBy8PQGBIteRcrcoi5eZx(zyK4AopOMbgOr9vkI85Kmks9WMsXnSDdmh5dL5tFKOcC1xPiAi96WLTjYVOnm(eC1xPiAi96WLTjYV4ZWiBdJpzoYhkZN(ir)pDr8qW1AnMXdk8MGdQc4k4JYmYMmkYjYp5J5OcCdXraDdBxWjMDsQh2uks6ZiVPWQ)CkRmocOBy7coXSts9WMsrsFg5TQGRigObhb0nSDXepCTmkYPMKF(ajs6ZiVbxXAmu9vkcoXStsCnNhKOnm(uvWnXjIvHibhKCI5l)mmsCnNhutJHgome5JiFojJIupSPudocOBy7I85Kmks9WMsrsFg5TQGFGVAWraDdBxWjMDsQh2uks6ZiVPWZzGYkBOrome5JiFojJIupSPudocOBy7coXSts9WMsrsFg5nfEoduwzCeq3W2fCIzNK6HnLIK(mYBvb)aFnWG1ygpOWBcoOkGRGKVi2hztNZtMJkWXraDdBxmXdxlJICQj5NpqIK(mYBvrWq43qYb9jngA4WqKpI85Kmks9WMsn4iGUHTlYNtYOi1dBkfj9zK3Qc(b(Qbhb0nSDbNy2jPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuY6gOSYgAKddr(iYNtYOi1dBk1GJa6g2UGtm7KupSPuK0NrEtHM4eXQqKyI5l)mmYlbXkjlrkzDduwzCeq3W2fCIzNK6HnLIK(mYBvb)aFnynMXdk8MGdQc4ki5lI9r2058K5OcCCeq3W2fCIzNK6HnLIK(mYBvrWq43qYb9jngAOH4iGUHTlM4HRLrro1K8ZhirsFg5nfAIteRcrcwx(zyKxcIvswIuoX81O(kfbNy2jjUMZds0ggFcU6RueCIzNK4AopiXNHr2ggFYaLv2qCeq3W2ft8W1YOiNAs(5dKiPpJ8gCfRr9vkcoXStsCnNhKOnm(uvWnXjIvHibhKCI5l)mmsCnNhuZad0O(kfr(CsgfPEytP4g2UbRXmEqH3eCqvaxbxINA1iDYCuboocOBy7coXSts9WMsrsFg5n4kwJHgAiocOBy7IjE4AzuKtnj)8bsK0NrEtHM4eXQqKG1LFgg5LGyLKLiLtmFnQVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXNmqzLnehb0nSDXepCTmkYPMKF(ajs6ZiVbxXAuFLIGtm7KexZ5bjAdJpvfCtCIyvisWbjNy(YpdJexZ5b1mWanQVsrKpNKrrQh2ukUHTBWAmJhu4nbhufWvWepCTmkYPMKF(azoQa3q1xPi4eZojX1CEqI2W4tvb3eNiwfIeCqYjMV8ZWiX1CEqnLvwpjtYd8vOLi5lI9r2058KbAm0WHHiFe5ZjzuK6HnLAWraDdBxKpNKrrQh2uks6ZiVvf8d8vdocOBy7coXSts9WMsrsFg5nfAIteRcrIjMV8ZWiVeeRKSePK1nqzLn0ihgI8rKpNKrrQh2uQbhb0nSDbNy2jPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuY6gOSY4iGUHTl4eZoj1dBkfj9zK3Qc(b(AWAmJhu4nbhufWvaNy2jPEytP5OcCdnehb0nSDXepCTmkYPMKF(ajs6ZiVPqtCIyvisW6YpdJ8sqSsYsKYjMVg1xPi4eZojX1CEqI2W4tWvFLIGtm7KexZ5bj(mmY2W4tgOSYgIJa6g2UyIhUwgf5utYpFGej9zK3GRynQVsrWjMDsIR58GeTHXNQcUjorSkej4GKtmF5NHrIR58GAgyGg1xPiYNtYOi1dBkf3W2xJz8GcVj4GQaUcYNtYOi1dBknhvGR(kfr(CsgfPEytP4g2Ugdnehb0nSDXepCTmkYPMKF(ajs6ZiVPqZOynQVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXNmqzLnehb0nSDXepCTmkYPMKF(ajs6ZiVbxXAuFLIGtm7KexZ5bjAdJpvfCtCIyvisWbjNy(YpdJexZ5b1mWangIJa6g2UGtm7KupSPuK0NrEtHAzgLv(sQVsrmXdxlJICQj5NpqINUbRXmEqH3eCqvaxbTAuzq(HupSP0CuboocOBy7coXStYivfj9zK3u45uwzJCyiYhbNy2jzKQRXmEqH3eCqvaxbCIzNKQqCBmhvGJdtKZ(ioPuIyxt(CQe5bj4eZojrEb5OrjnQVsrWjMDsQh2ukE6AUK6RuejFrSpYMoNNKMEqoLSkccnkjAdJpbV61ONKj5b(k0sWjMDsgPQggpitKKC6JOwvvJ1ygpOWBcoOkGRaoXStsvot(GmhvGJdtKZ(ioPuIyxt(CQe5bj4eZojrEb5OrjnQVsrWjMDsQh2ukE6AUK6RuejFrSpYMoNNKMEqoLSkccnkjAdJpbV6xJz8GcVj4GQaUc4eZojvH42yoQahhMiN9rCsPeXUM85ujYdsWjMDsI8cYrJsAuFLIGtm7KupSPu801y4ngrYxe7JSPZ5jrsFg5nfEEuw5lP(kfrYxe7JSPZ5jPPhKtjRIGqJsINUbAUK6RuejFrSpYMoNNKMEqoLSkccnkjAdJpvv1RHXdYejjN(iQbxrwJz8GcVj4GQaUc4eZojJu1Cuboomro7J4KsjIDn5ZPsKhKGtm7Ke5fKJgL0O(kfbNy2jPEytP4PR5sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(eCfznMXdk8MGdQc4kGtm7KuLZKpiZrf44We5SpItkLi21KpNkrEqcoXStsKxqoAusJ6RueCIzNK6HnLINUMlP(kfrYxe7JSPZ5jPPhKtjRIGqJsI2W4tWnZAmJhu4nbhufWvaNy2jjbJou0qHBoQahhMiN9rCsPeXUM85ujYdsWjMDsI8cYrJsAuFLIGtm7KupSPu801ONKj5b(kmJi5lI9r2058KggpitKKC6JOMcvK1ygpOWBcoOkGRaoXStscgDOOHc3Cuboomro7J4KsjIDn5ZPsKhKGtm7Ke5fKJgL0O(kfbNy2jPEytP4PR5sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(eCT0W4bzIKKtFe1uOISgZ4bfEtWbvbCfONuJCmjJI8J8R5OcC1xPiUep1Qr6K4PR5sQVsrmXdxlJICQj5NpqINUMlP(kfXepCTmkYPMKF(ajs6ZiVvfC1xPi0tQroMKrr(r(v8zyKTHXNQmmEqHl4eZojvH42iiyi8Bi5G(KgdnCyiYhrsTWzhtAy8GmrsYPpIAvv9gOSYmEqMij50hrTQoNbAm0iZNtLipibNy2jPA8v58(jFuw5HZdAe1edn1cD8Oqf5CgSgZ4bfEtWbvbCfWjMDsQcXTXCubU6RuexINA1iDs801yOHddr(isQfo7ysdJhKjsso9ruRQQ3aLvMXdYejjN(iQv15mqJHgz(CQe5bj4eZojvJVkN3p5JYkpCEqJOMyOPwOJhfQiNZG1ygpOWBcoOkGRG2tNspmXRXmEqH3eCqvaxbCIzNKQCM8bzoQax9vkcoXStsCnNhKOnm(KcHBiJhKjsso9ruRAwld0KpNkrEqcoXSts14RY59t(Oz48GgrnXqtTqhpvPiNBnMXdk8MGdQc4kGtm7KuLZKpiZrf4QVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXNwJz8GcVj4GQaUc4eZojJu1CubU6RueCIzNK4AopirBy8j4kEnMXdk8MGdQc4kWPPMs5qFDQnMJkWnmPssTAwfIuwzJCq4ti)WanQVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXNwJz8GcVj4GQaUc4eZoj)OwdbrnZrf4QVsrGHioXCBq(HijgpAYNtLipibNy2jjYlihnkPXqdhgI8rWFDiubH5bfUggpitKKC6JOwvMDduwzgpitKKC6JOwvNZG1ygpOWBcoOkGRaoXStYpQ1qquZCubU6RueyiItm3gKFisIXJMHHiFeCIzNKeUo0Cj1xPiM4HRLrro1K8ZhiXtxJHddr(i4VoeQGW8GcxzLz8GmrsYPpIAvPOnynMXdk8MGdQc4kGtm7K8JAnee1mhvGR(kfbgI4eZTb5hIKy8OzyiYhb)1HqfeMhu4Ay8GmrsYPpIAvv9RXmEqH3eCqvaxbCIzNKem6qrdfU5OcC1xPi4eZojX1CEqI2W4tvP(kfbNy2jjUMZds8zyKTHXNwJz8GcVj4GQaUc4eZojjy0HIgkCZrf4QVsrWjMDsIR58GeTHXNGR(kfbNy2jjUMZds8zyKTHXN0ONKj5b(k0sWjMDsQYzYh0AmJhu4nbhufWvazkW8Gc3CKpuMp9rIkW)SZcD8Oq4k6ZzoYhkZN(ir)pDr8qW1AnEnUYUGQlrrIg05dTGxd5hl4irniLwacJWq0cSrt9cyDXcmlA0cqZcSrt9cMy(liMAkTrnsSgZ4bfEtGJa6g2EdEjJ2i9WeBoQapFovI8GehjQbPKeHryisdocOBy7coXSts9WMsrsFg5nfQikwdocOBy7IjE4AzuKtnj)8bsK0NrEdUI1yO6RueCIzNK4AopirBy8PQGBIteRcrIjMV8ZWiX1CEqnngA4WqKpI85Kmks9WMsn4iGUHTlYNtYOi1dBkfj9zK3Qc(b(Qbhb0nSDbNy2jPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuY6gOSYgAKddr(iYNtYOi1dBk1GJa6g2UGtm7KupSPuK0NrEtHM4eXQqKyI5l)mmYlbXkjlrkzDduwzCeq3W2fCIzNK6HnLIK(mYBvb)aFnWG1ygpOWBcCeq3W2BvaxbLmAJ0dtS5Oc885ujYdsCKOgKssegHHin4iGUHTl4eZoj1dBkfj9zK3GRyngAKddr(iihcDupKtxLv2WHHiFeKdHoQhYPRMp7SqhpkeE1qXgyGgdnehb0nSDXepCTmkYPMKF(ajs6ZiVPqTuSg1xPi4eZojX1CEqI2W4tWvFLIGtm7KexZ5bj(mmY2W4tgOSYgIJa6g2UyIhUwgf5utYpFGej9zK3GRynQVsrWjMDsIR58GeTHXNGRydmqJ6Rue5ZjzuK6HnLIBy7A(SZcD8Oq4M4eXQqKG1LFKJ(VV8Zol1XZAmJhu4nbocOBy7TkGRGsgTrnGgZrf45ZPsKhK4IAyKoeY5ujjo(F2VAWraDdBxO(kf5f1WiDiKZPssC8)SFfjXxL0O(kfXf1WiDiKZPssC8)SFLLmAJ4g2UgdvFLIGtm7KupSPuCdBxJ6Rue5ZjzuK6HnLIBy7AUK6Ruet8W1YOiNAs(5dK4g2UbAWraDdBxmXdxlJICQj5NpqIK(mYBWvSgdvFLIGtm7KexZ5bjAdJpvfCtCIyvismX8LFggjUMZdQPXqdhgI8rKpNKrrQh2uQbhb0nSDr(CsgfPEytPiPpJ8wvWpWxn4iGUHTl4eZoj1dBkfj9zK3uOjorSkejMy(YpdJ8sqSsYsKsw3aLv2qJCyiYhr(CsgfPEytPgCeq3W2fCIzNK6HnLIK(mYBk0eNiwfIetmF5NHrEjiwjzjsjRBGYkJJa6g2UGtm7KupSPuK0NrERk4h4RbgSgZ4bfEtGJa6g2ERc4kOGssQcXTXCubE(CQe5bjUOggPdHCovsIJ)N9RgCeq3W2fQVsrErnmshc5CQKeh)p7xrs8vjnQVsrCrnmshc5CQKeh)p7xzbLK4g2Ug9KmjpWxHwIsgTrnGM14k7cQogLlWSgNTaB0uVGkV6waQSa0ODBb44J8Jf80xqlcxSGZFzbOzb2iiOfOsl41O7cSrt9colgZQ5laZTzbOzbni0r9aP0cuPsK0AmJhu4nbocOBy7TkGRGpkZiBYOiNi)KpMJkWXraDdBxmXdxlJICQj5NpqIK(mYBvzIteRcrIFms9KWeDLtmFPQskRSH4iGUHTl4eZoj1dBkfj9zK3uOjorSkej(Xi)mmYlbXkjlrkzDn4iGUHTlM4HRLrro1K8ZhirsFg5nfAIteRcrIFmYpdJ8sqSsYsKYjMVbRXmEqH3e4iGUHT3QaUc(OmJSjJICI8t(yoQahhb0nSDbNy2jPEytPij(QKgdnYHHiFeKdHoQhYPRYkB4WqKpcYHqh1d50vZNDwOJhfcVAOydmqJHgIJa6g2UyIhUwgf5utYpFGej9zK3uOjorSkejyD5NHrEjiwjzjs5eZxJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jduwzdXraDdBxmXdxlJICQj5NpqIK(mYBWvSg1xPi4eZojX1CEqI2W4tWvSbgOr9vkI85Kmks9WMsXnSDnF2zHoEuiCtCIyvisW6YpYr)3x(zNL64znUYUGkhYMvQTGxJwWL4PwnsNwGnAQxaRlwW5VSGjM)cqTfKeFvAbCBb2eeK5l4ZNOf0EjTGjwaMBZcqZcuPsK0cMy(I1ygpOWBcCeq3W2BvaxbxINA1iDYCuboocOBy7IjE4AzuKtnj)8bsK0NrEdUI1O(kfbNy2jjUMZds0ggFQk4M4eXQqKyI5l)mmsCnNhutdocOBy7coXSts9WMsrsFg5TQGFGVRXmEqH3e4iGUHT3QaUcUep1Qr6K5OcCCeq3W2fCIzNK6HnLIK(mYBWvSgdnYHHiFeKdHoQhYPRYkB4WqKpcYHqh1d50vZNDwOJhfcVAOydmqJHgIJa6g2UyIhUwgf5utYpFGej9zK3uOwkwJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jduwzdXraDdBxmXdxlJICQj5NpqIK(mYBWvSg1xPi4eZojX1CEqI2W4tWvSbgOr9vkI85Kmks9WMsXnSDnF2zHoEuiCtCIyvisW6YpYr)3x(zNL64znUYUaZIgTGMoNNwaQSGjM)cy)UawFbCsli8fGVlG97cSdx7zbQ0cE6lOe5cGc)GYfm1SVGPMwWNHzbxcIvY8f85ti)ybTxslWMwqnBIwaplaI42SGXowaNy2PfGR58GAlG97cMAEwWeZFb2CZ1EwW5BV2SGxJUI1ygpOWBcCeq3W2BvaxbjFrSpYMoNNmhvGJJa6g2UyIhUwgf5utYpFGej9zK3uOjorSkejYM8ZWiVeeRKSePCI5Rbhb0nSDbNy2jPEytPiPpJ8McnXjIvHir2KFgg5LGyLKLiLSUgdhgI8rKpNKrrQh2uQXqCeq3W2f5ZjzuK6HnLIK(mYBvrWq43qYb9jLvghb0nSDr(CsgfPEytPiPpJ8McnXjIvHir2KFgg5LGyLKLiLzOBGYkBKddr(iYNtYOi1dBknqJ6RueCIzNK4AopirBy8jfAgnxs9vkIjE4AzuKtnj)8bsCdBxJ6Rue5ZjzuK6HnLIBy7AuFLIGtm7KupSPuCdBFnUYUaZIgTGMoNNwGnAQxaRVa7AYxGE0AivisSGZFzbtm)fGAlij(Q0c42cSjiiZxWNprlO9sAbtSam3MfGMfOsLiPfmX8fRXmEqH3e4iGUHT3QaUcs(IyFKnDopzoQahhb0nSDXepCTmkYPMKF(ajs6ZiVvfbdHFdjh0N0O(kfbNy2jjUMZds0ggFQk4M4eXQqKyI5l)mmsCnNhutdocOBy7coXSts9WMsrsFg5TQmKGHWVHKd6tvW4bfUyIhUwgf5utYpFGeeme(nKCqFYG1ygpOWBcCeq3W2BvaxbjFrSpYMoNNmhvGJJa6g2UGtm7KupSPuK0NrERkcgc)gsoOpPXqdnYHHiFeKdHoQhYPRYkB4WqKpcYHqh1d50vZNDwOJhfcVAOydmqJHgIJa6g2UyIhUwgf5utYpFGej9zK3uOjorSkejyD5NHrEjiwjzjs5eZxJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jduwzdXraDdBxmXdxlJICQj5NpqIK(mYBWvSg1xPi4eZojX1CEqI2W4tWvSbgOr9vkI85Kmks9WMsXnSDnF2zHoEuiCtCIyvisW6YpYr)3x(zNL64XG14k7cmlA0cMy(lWgn1lG1xaQSa0ODBb2OPg5lyQPf8zywWLGyLel48xwGhJ5l41OfyJM6fKH(cqLfm10cggI8zbO2cg(e5MVa2VlanA3wGnAQr(cMAAbFgMfCjiwjXAmJhu4nbocOBy7TkGRGjE4AzuKtnj)8bYCubU6RueCIzNK4AopirBy8PQGBIteRcrIjMV8ZWiX1CEqnn4iGUHTl4eZoj1dBkfj9zK3QcobdHFdjh0N08zNf64rHM4eXQqKG1LFKJ(VV8Zol1XJg1xPiYNtYOi1dBkf3W2xJz8GcVjWraDdBVvbCfmXdxlJICQj5NpqMJkWvFLIGtm7KexZ5bjAdJpvfCtCIyvismX8LFggjUMZdQPzyiYhr(CsgfPEytPgCeq3W2f5ZjzuK6HnLIK(mYBvbNGHWVHKd6tAWraDdBxWjMDsQh2uks6ZiVPqtCIyvismX8LFgg5LGyLKLiLSUgCeq3W2fCIzNK6HnLIK(mYBkulZSgZ4bfEtGJa6g2ERc4kyIhUwgf5utYpFGmhvGR(kfbNy2jjUMZds0ggFQk4M4eXQqKyI5l)mmsCnNhutJHg5WqKpI85Kmks9WMsLvghb0nSDr(CsgfPEytPiPpJ8McnXjIvHiXeZx(zyKxcIvswIuMHUbAWraDdBxWjMDsQh2uks6ZiVPqtCIyvismX8LFgg5LGyLKLiLS(ACLDbMfnAbS(cqLfmX8xaQTGWxa(Ua2VlWoCTNfOsl4PVGsKlak8dkxWuZ(cMAAbFgMfCjiwjZxWNpH8Jf0EjTGPMNfytlOMnrlG84DuVGp78cy)UGPMNfm1usla1wGhZcyOK4RslGxq(CAbrzb6HnLl4g2UynMXdk8Mahb0nS9wfWvaNy2jPEytP5OcCCeq3W2ft8W1YOiNAs(5dKiPpJ8McnXjIvHibRl)mmYlbXkjlrkNy(Am0iXHjYzFeMiFQvkvwzCeq3W2fFuMr2Krror(jFej9zK3uOjorSkejyD5NHrEjiwjzjs5pgd0O(kfbNy2jjUMZds0ggFcU6RueCIzNK4AopiXNHr2ggFsJ6Rue5ZjzuK6HnLIBy7A(SZcD8Oq4M4eXQqKG1LFKJ(VV8Zol1XZACLDbMfnAbzOVauzbtm)fGAli8fGVlG97cSdx7zbQ0cE6lOe5cGc)GYfm1SVGPMwWNHzbxcIvY8f85ti)ybTxslyQPKwaQ5AplGHsIVkTaEb5ZPfCdBFbSFxWuZZcy9fyhU2ZcujC8PfWMyeeRcrl4(sKFSG85KynMXdk8Mahb0nS9wfWvq(CsgfPEytP5OcC1xPi4eZoj1dBkf3W21yiocOBy7IjE4AzuKtnj)8bsK0NrEtHM4eXQqKidD5NHrEjiwjzjs5eZxzLXraDdBxWjMDsQh2uks6ZiVvfCtCIyvismX8LFgg5LGyLKLiLSUbAuFLIGtm7KexZ5bjAdJpbx9vkcoXStsCnNhK4ZWiBdJpPbhb0nSDbNy2jPEytPiPpJ8Mc1YmRXmEqH3e4iGUHT3QaUcA1OYG8dPEytP5OcC1xPi4eZoj1dBkf3W21GJa6g2UGtm7KupSPum5JKj9zK3uiJhu4IwnQmi)qQh2ukW3uJ6Rue5ZjzuK6HnLIBy7AWraDdBxKpNKrrQh2ukM8rYK(mYBkKXdkCrRgvgKFi1dBkf4BQ5sQVsrmXdxlJICQj5NpqIBy7RXv2fyw0OfOh)fmXcAvRhrNp0cyFbemtYlGvxaYxWutlWjyMfGJa6g2(cSr(nSnFbphIATfCsPeX(cMAYxq4qkTG7lr(Xc4eZoTa9WMYfCF0cMyb1H9c(SZlO(5hPsli5lI9zbnDopTauBnMXdk8Mahb0nS9wfWvGEsnYXKmkYpYVMJkWhgI8rKpNKrrQh2uQr9vkcoXSts9WMsXtxJ6Rue5ZjzuK6HnLIK(mYBvDGVIpdZAmJhu4nbocOBy7TkGRa9KAKJjzuKFKFnhvGFj1xPiM4HRLrro1K8ZhiXtxZLuFLIyIhUwgf5utYpFGej9zK3QIXdkCbNy2j5h1AiiQjiyi8Bi5G(KgJehMiN9rCsPeX(AmJhu4nbocOBy7TkGRa9KAKJjzuKFKFnhvGR(kfr(CsgfPEytP4PRr9vkI85Kmks9WMsrsFg5TQoWxXNHrdocOBy7cYuG5bfUij(QKgCeq3W2ft8W1YOiNAs(5dKiPpJ8MgJehMiN9rCsPeX(A8AmJhu4nrb5mKu9LEfWvaNy2j5h1AiiQzoQax9vkcmeXjMBdYpejX4XCCnJC4ATgZ4bfEtuqodjvFPxbCfWjMDsQcXTznMXdk8MOGCgsQ(sVc4kGtm7KuLZKpO1414k7cQMQjFb5ZDKFSacn1uUGPMwGL1cICbNvnTai6G8lNiQz(cSPfyZ(SGjwW51uSavQejTGPMwWzXywvqLxDlWg53WwSaZIgTa0SaUTGwe(c42cQ2r1TGAUTGcYrTA6UG4LlWM02eTGMo5ZcIxUaCnNhuBnMXdk8MOGA1i)qg6KtjCYuG5bfU5OcCdZNtLipirdPxhUSnr(vw585ujYdsm0xpsgsAZPUbAmu9vkI85Kmks9WMsXnSDLvwpjtYd8vOLGtm7KuLZKpid0GJa6g2UiFojJIupSPuK0NrEBnUYUGZFzb2K2MOfuqoQvt3feVCb4iGUHTVaBKFd72cy)UGMo5ZcIxUaCnNhuZ8fONOird68HwW51uSGWeLlGmrPstnYpwab1O1ygpOWBIcQvJ8dzOtoLvaxbKPaZdkCZrf4ddr(iYNtYOi1dBk1GJa6g2UiFojJIupSPuK0NrEtdocOBy7coXSts9WMsrsFg5nnQVsrWjMDsQh2ukUHTRr9vkI85Kmks9WMsXnSDn6jzsEGVcTeCIzNKQCM8bTgZ4bfEtuqTAKFidDYPSc4kOGssQcXTXCubE(CQe5bjUOggPdHCovsIJ)N9Rg1xPiUOggPdHCovsIJ)N9RSKrBep91ygpOWBIcQvJ8dzOtoLvaxbLmAJ0dtS5Oc885ujYdsCKOgKssegHHinF2zHoEuOI(CRXmEqH3efuRg5hYqNCkRaUcUep1Qr6K5OcCJmFovI8GenKED4Y2e5xJrMpNkrEqIH(6rYqsBo1xJz8GcVjkOwnYpKHo5uwbCfWjMDsgPQ5OcCCeq3W2f5ZjzuK6HnLIK4RsRXmEqH3efuRg5hYqNCkRaUc4eZojvH42yoQahhb0nSDr(CsgfPEytPij(QKg1xPi4eZojX1CEqI2W4tvP(kfbNy2jjUMZds8zyKTHXNwJz8GcVjkOwnYpKHo5uwbCfKpNKrrQh2uUgxzxW5VSaBs7Kwapl4ZWSG2W4tTfeLfyug1cy)UaBAb1SjY1EwWRr3fywJZwGs0y(cEnAb8cAdJpTGjwGEsMiFwW)54AKFSgZ4bfEtuqTAKFidDYPSc4kGtm7K8JAnee1mhvGR(kfbgI4eZTb5hIKy8Or9vkcmeXjMBdYpeTHXNGR(kfbgI4eZTb5hIpdJSnm(KgCyIC2hHjYNALsn4iGUHTl(OmJSjJICI8t(isIVkTgxzxaSI8ZqqkTaBAb6mkxGEmOWxWRrlWgn1lOYRoZxG6BwaAwGnccAbqCBwau4hlG84DuVGsKlqnM6fm10cQ2r1Ta2VlOYRUfyJ8By3wWZHOwBb5ZDKFSGPMwGL1cICbNvnTai6G8lNiQTgZ4bfEtuqTAKFidDYPSc4kqpgu4MJkWnsdZNtLipirdPxhUSnr(vw585ujYdsm0xpsgsAZPUbRXmEqH3efuRg5hYqNCkRaUcUep1Qr6K5OcC1xPiYNtYOi1dBkf3W2vwz9KmjpWxHwcoXStsvot(GwJz8GcVjkOwnYpKHo5uwbCfK8fX(iB6CEYCubU6Rue5ZjzuK6HnLIBy7kRSEsMKh4RqlbNy2jPkNjFqRXmEqH3efuRg5hYqNCkRaUc(OmJSjJICI8t(yoQax9vkI85Kmks9WMsXnSDLvwpjtYd8vOLGtm7KuLZKpO1ygpOWBIcQvJ8dzOtoLvaxbt8W1YOiNAs(5dK5OcC1xPiYNtYOi1dBkf3W2vwz9KmjpWxHwcoXStsvot(Guwz9KmjpWxHwIpkZiBYOiNi)KpkRSEsMKh4RqlrYxe7JSPZ5jLvwpjtYd8vOL4s8uRgPtRXmEqH3efuRg5hYqNCkRaUc4eZoj1dBknhvGRNKj5b(k0smXdxlJICQj5NpqRXv2fyw0OfuDHzDbtSGw16r05dTa2xabZK8cQ8eZoTaydXTzb3xI8Jfm10colgZQcQ8QBb2i)g2l45quRTG85oYpwqLNy2PfCEX1HybN)YcQ8eZoTGZlUowaQTGHHiFOR5lWMwaMDTNf8A0cQUWSUaB0uJ8fm10colgZQcQ8QBb2i)g2l45quRTaBAbiFOmF6ZcMAAbvUzDb4A2DcY8f0IfytAdbTGgBIwaAeRXmEqH3efuRg5hYqNCkRaUc0tQroMKrr(r(1CubUrome5JGtm7KKW1HMlP(kfXepCTmkYPMKF(ajE6AUK6Ruet8W1YOiNAs(5dKiPpJ8wvWnKXdkCbNy2jPke3gbbdHFdjh0NQmQVsrONuJCmjJI8J8R4ZWiBdJpzWACLDbN)YcQUWSUGAU5AplqLiFbVgDxW9Li)ybtnTGZIXSUaBKFdBZxGnPne0cEnAbOzbtSGw16r05dTa2xabZK8cQ8eZoTaydXTzbiFbtnTGQDuDkOYRUfyJ8BylwJz8GcVjkOwnYpKHo5uwbCfONuJCmjJI8J8R5OcC1xPi4eZoj1dBkfpDnQVsrKpNKrrQh2uks6ZiVvfCdz8GcxWjMDsQcXTrqWq43qYb9PkJ6Rue6j1ihtYOi)i)k(mmY2W4tgSgZ4bfEtuqTAKFidDYPSc4kGtm7KufIBJ5Oc8BmIKVi2hztNZtIK(mYBk8CkR8LuFLIi5lI9r2058K00dYPKvrqOrjrBy8jfQ414k7cQMOfyZ(SGjwWNprlO9sAb20cQzt0cipEh1l4ZoVGsKlyQPfq(GsAbvE1TaBKFdBZxazI8fGklyQPK0UTG2GGGwWG(0cs6Zih5hli8fuTJQtSGZ)ODBbHdP0cuPzOCbtSa1x6lyIfC(qzSa2Vl48AkwaQSG85oYpwWutlWYAbrUGZQMwaeDq(Lte1eRXmEqH3efuRg5hYqNCkRaUc4eZojv5m5dYCuboocOBy7coXSts9WMsrs8vjnF2zHoEQYWQxXvyOwkUYGdtKZ(ioPuIy3ad0O(kfbNy2jjUMZds0ggFcU6RueCIzNK4AopiXNHr2ggFsJrMpNkrEqIgsVoCzBI8RXiZNtLipiXqF9iziPnN6RXv2fyw4quRTG85oYpwWutlOYtm70cuuC(dxPfarhKF5ujZxaS5m5dAbT64bDxGhZcuPf8A0Db8SGPMwa53feLfu5v3cqLfCEnfyEqHVauBbrPSaCeq3W2xa3wWndDDKFSaCnNhuBb2iiOf85t0cqZcg(eTaOWpOCbtSa1x6lyQZ4DuVGK(mYr(Xc(SZRXmEqH3efuRg5hYqNCkRaUc4eZojv5m5dYCubU6RueCIzNK6HnLINUg1xPi4eZoj1dBkfj9zK3Qc(b(QXW85ujYdsWjMDsI8cYrJskRmocOBy7cYuG5bfUiPpJ8MbRXv2faBot(GwqRoEq3fWq2SsTfOslyQPfaXTzbyUnla5lyQPfuTJQBb2i)g2lGBl4SymRlWgbbTGKAtK0cMAAb4AopO2cA6KpRXmEqH3efuRg5hYqNCkRaUc4eZojv5m5dYCubU6Rue5ZjzuK6HnLINUg1xPi4eZoj1dBkf3W21O(kfr(CsgfPEytPiPpJ8wvWpW31ygpOWBIcQvJ8dzOtoLvaxbCIzNKFuRHGOM5Oc8lP(kfXepCTmkYPMKF(ajE6AggI8rWjMDss46qJHQVsrCjEQvJ0jXnSDLvMXdYejjN(iQbxld0Cj1xPiM4HRLrro1K8ZhirsFg5nfY4bfUGtm7K8JAnee1eeme(nKCqFYCCnJC4AzoXjKssCnJCjQax9vkcmeXjMBdYpK4A2DcsCdBxJHQVsrWjMDsQh2ukE6kRSHg5WqKpIWeL6HnL0vJHQVsrKpNKrrQh2ukE6kRmocOBy7cYuG5bfUij(QKbgyWACLDbMLoKslOnCol41q(XcmkJAbvUzDb21KVGkV6wqn3wGkr(cEn6UgZ4bfEtuqTAKFidDYPSc4kGtm7K8JAnee1mhvGR(kfbgI4eZTb5hIKy8Obhb0nSDbNy2jPEytPiPpJ8MgdvFLIiFojJIupSPu80vwz1xPi4eZoj1dBkfpDdmhxZihUwRXmEqH3efuRg5hYqNCkRaUc4eZojJu1CubU6RueCIzNK4AopirBy8PQGBIteRcrIjMV8ZWiX1CEqT1ygpOWBIcQvJ8dzOtoLvaxbCIzNKQqCBmhvGR(kfr(CsgfPEytP4PRSYF2zHoEuOwNBnMXdk8MOGA1i)qg6KtzfWvazkW8Gc3CubU6Rue5ZjzuK6HnLIBy7AuFLIGtm7KupSPuCdB3CKpuMp9rIkW)SZcD8Oq4M9ZzoYhkZN(ir)pDr8qW1AnMXdk8MOGA1i)qg6KtzfWvaNy2jPkNjFqRXRXv2k7cy8GcVjQ58hUsWXSJjijJhu4MJkWz8GcxqMcmpOWf4A2Dcc5hA(SZcD8Oq4k6ZTgxzxGzrJwW51uG5bf(cqLfytAN0cGc7fe(c(SZlG97c4fCwmMvfu5v3cSr(nSxaQTaC8r(XcE6RXmEqH3e1C(dxPkGRaYuG5bfU5Oc8p7SqhpvbxRZPbhb0nSDXepCTmkYPMKF(ajs6ZiVvfCdjyi8Bi5G(ufmEqHlM4HRLrro1K8ZhibbdHFdjh0NmqdocOBy7coXSts9WMsrsFg5TQGBibdHFdjh0NQGXdkCXepCTmkYPMKF(ajiyi8Bi5G(ufmEqHl4eZoj1dBkfeme(nKCqFYanQVsrKpNKrrQh2ukUHTRr9vkcoXSts9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBxJrEJrK8fX(iB6CEsK0NrEBnUYUaZIgTGZRPaZdk8fGklWM0oPfaf2li8f8zNxa73fWlOAhv3cSr(nSxaQTaC8r(XcE6RXmEqH3e1C(dxPkGRaYuG5bfU5Oc8p7SqhpvbxruSgCeq3W2f5ZjzuK6HnLIK(mYBvb3qcgc)gsoOpvbJhu4I85Kmks9WMsbbdHFdjh0NmqdocOBy7IjE4AzuKtnj)8bsK0NrERk4gsWq43qYb9Pky8GcxKpNKrrQh2ukiyi8Bi5G(ufmEqHls(IyFKnDopjiyi8Bi5G(KbAWraDdBxWjMDsQh2uks6ZiVPWQxXRXmEqH3e1C(dxPkGRaoXStsviUnMJkWXraDdBxK8fX(iB6CEsK0NrERk4MPYCGVvyIteRcrcZMIsQNuBy8jKFih0NQGGHWVHKd6tAWraDdBxmXdxlJICQj5NpqIK(mYBvb3eNiwfIeMnfLupP2W4ti)qoOpvbbdHFdjh0NQGXdkCrYxe7JSPZ5jbbdHFdjh0N0GJa6g2UGtm7KupSPuK0NrERk4M4eXQqKWSPOK6j1ggFc5hYb9Pkiyi8Bi5G(ufmEqHls(IyFKnDopjiyi8Bi5G(ufmEqHlM4HRLrro1K8ZhibbdHFdjh0N0O(kfbNy2jjUMZds0ggFsHAPr9vkcoXStsCnNhKOnm(uvvVgJeh(9HgbNy2jPEgx0HsRXmEqH3e1C(dxPkGRaoXStsviUnMJkWXraDdBxKpNKrrQh2uks6ZiVvfCZuzoW3kmXjIvHiHztrj1tQnm(eYpKd6tvqWq43qYb9Pky8GcxKpNKrrQh2ukiyi8Bi5G(KgCeq3W2fjFrSpYMoNNej9zK3QcUjorSkejmBkkPEsTHXNq(HCqFQccgc)gsoOpvbJhu4I85Kmks9WMsbbdHFdjh0N0GJa6g2UyIhUwgf5utYpFGej9zK3QcUjorSkejmBkkPEsTHXNq(HCqFQccgc)gsoOpvbJhu4I85Kmks9WMsbbdHFdjh0NQGXdkCrYxe7JSPZ5jbbdHFdjh0N0GJa6g2UGtm7KupSPuK0NrEtJ6RueCIzNK4AopirBy8jfQLg1xPi4eZojX1CEqI2W4tvv9AmsC43hAeCIzNK6zCrhkTgZ4bfEtuZ5pCLQaUc4eZojvH42yoQahhb0nSDrYxe7JSPZ5jrsFg5TQGBMkZb(wHjorSkejmBkkPEsTHXNq(HCqFsdocOBy7coXSts9WMsrsFg5nfcxruSgCeq3W2ft8W1YOiNAs(5dKiPpJ8wfkIIRcoocOBy7coXSts9WMsrsFg5nn4iGUHTlYNtYOi1dBkfj9zK3QqruCvWXraDdBxWjMDsQh2uks6ZiVPr9vkcoXStsCnNhKOnm(Kc1sJ6RueCIzNK4AopirBy8PQQEngjo87dncoXSts9mUOdLwJz8GcVjQ58hUsvaxbCIzNKQCM8bzoQahhb0nSDrYxe7JSPZ5jrsFg5TQGFGVvyIteRcrcZMIsQNuBy8jKFih0NQGGHWVHKd6tAWraDdBxmXdxlJICQj5NpqIK(mYBvb3eNiwfIeMnfLupP2W4ti)qoOpvbbdHFdjh0NQGXdkCrYxe7JSPZ5jbbdHFdjh0N0GJa6g2UGtm7KupSPuK0NrERk4M4eXQqKWSPOK6j1ggFc5hYb9Pkiyi8Bi5G(ufmEqHls(IyFKnDopjiyi8Bi5G(ufmEqHlM4HRLrro1K8ZhibbdHFdjh0N0O(kfbNy2jjUMZds0ggFsHATgZ4bfEtuZ5pCLQaUc4eZojv5m5dYCuboocOBy7I85Kmks9WMsrsFg5TQGFGVvyIteRcrcZMIsQNuBy8jKFih0NQGGHWVHKd6tvW4bfUiFojJIupSPuqWq43qYb9jn4iGUHTls(IyFKnDopjs6ZiVvfCtCIyvisy2uus9KAdJpH8d5G(ufeme(nKCqFQcgpOWf5ZjzuK6HnLccgc)gsoOpPbhb0nSDXepCTmkYPMKF(ajs6ZiVvfCtCIyvisy2uus9KAdJpH8d5G(ufeme(nKCqFQcgpOWf5ZjzuK6HnLccgc)gsoOpvbJhu4IKVi2hztNZtccgc)gsoOpPbhb0nSDbNy2jPEytPiPpJ8Mg1xPi4eZojX1CEqI2W4tkuR1ygpOWBIAo)HRufWvaNy2jPkNjFqMJkWXraDdBxK8fX(iB6CEsK0NrERk4h4BfM4eXQqKWSPOK6j1ggFc5hYb9jn4iGUHTl4eZoj1dBkfj9zK3uiCfrXAWraDdBxmXdxlJICQj5NpqIK(mYBvOikUk44iGUHTl4eZoj1dBkfj9zK30GJa6g2UiFojJIupSPuK0NrERcfrXvbhhb0nSDbNy2jPEytPiPpJ8Mg1xPi4eZojX1CEqI2W4tkulngjo87dncoXSts9mUOdLwJRSla2pe0Dbkko)HR0cAdJp1wqjYfm10colgZQcQ8QBb2i)g2RXmEqH3e1C(dxPkGRaoXStYpQ1qquZCubU6RueCIzNK1C(dxjrBy8PQuFLIGtm7KSMZF4kj(mmY2W4tAWraDdBxK8fX(iB6CEsK0NrERk4M4eXQqKWSPOK6j1ggFc5hYb9Pkiyi8Bi5G(KgCeq3W2ft8W1YOiNAs(5dKiPpJ8wvWnXjIvHiHztrj1tQnm(eYpKd6tvqWq43qYb9Pky8GcxK8fX(iB6CEsqWq43qYb9jn4iGUHTl4eZoj1dBkfj9zK3QcUjorSkejmBkkPEsTHXNq(HCqFQccgc)gsoOpvbJhu4IKVi2hztNZtccgc)gsoOpvbJhu4IjE4AzuKtnj)8bsqWq43qYb9jZX1mYHR1ACLDbW(HGUlqrX5pCLwqBy8P2ckrUGPMwq1oQUfyJ8ByVgZ4bfEtuZ5pCLQaUc4eZoj)OwdbrnZrf4QVsrWjMDswZ5pCLeTHXNQs9vkcoXStYAo)HRK4ZWiBdJpPbhb0nSDr(CsgfPEytPiPpJ8wvWnXjIvHiHztrj1tQnm(eYpKd6tvqWq43qYb9Pky8GcxKpNKrrQh2ukiyi8Bi5G(KgCeq3W2fjFrSpYMoNNej9zK3QcUjorSkejmBkkPEsTHXNq(HCqFQccgc)gsoOpvbJhu4I85Kmks9WMsbbdHFdjh0N0GJa6g2UyIhUwgf5utYpFGej9zK3QcUjorSkejmBkkPEsTHXNq(HCqFQccgc)gsoOpvbJhu4I85Kmks9WMsbbdHFdjh0NQGXdkCrYxe7JSPZ5jbbdHFdjh0N0GJa6g2UGtm7KupSPuK0NrEZCCnJC4ATgxzxaSFiO7cuuC(dxPf0ggFQTGsKlyQPf48j6UGQT1cSr(nSxJz8GcVjQ58hUsvaxbCIzNKFuRHGOM5OcC1xPi4eZojR58hUsI2W4tvP(kfbNy2jznN)Wvs8zyKTHXN0GJa6g2Ui5lI9r2058KiPpJ8wvWnXjIvHiHztrj1tQnm(eYpKd6tvqWq43qYb9Pky8GcxK8fX(iB6CEsqWq43qYb9jn4iGUHTl4eZoj1dBkfj9zK3uiCfrXAWraDdBxKpNKrrQh2uks6ZiVPq4kII1yK4WVp0i4eZoj1Z4IouYCCnJC4ATgZ4bfEtuZ5pCLQaUcs(IyFKnDopzoQax9vkcoXStsCnNhKOnm(uvMrJ6RueCIzNK1C(dxjrBy8j4QVsrWjMDswZ5pCLeFggzBy8jn4iGUHTlM4HRLrro1K8ZhirsFg5TQiyi8Bi5G(KgCeq3W2fCIzNK6HnLIK(mYBvb3qcgc)gsoOpvbJhu4IjE4AzuKtnj)8bsqWq43qYb9jd08zNf64rHADU1ygpOWBIAo)HRufWvWepCTmkYPMKF(azoQax9vkcoXStsCnNhKOnm(uvMrJ6RueCIzNK1C(dxjrBy8j4QVsrWjMDswZ5pCLeFggzBy8jn4iGUHTl4eZoj1dBkfj9zK3QcobdHFdjh0N0CJrK8fX(iB6CEsK0NrEBnMXdk8MOMZF4kvbCfWjMDsQh2uAoQax9vkcoXStYAo)HRKOnm(eC1xPi4eZojR58hUsIpdJSnm(KMlP(kfXepCTmkYPMKF(ajE6AuFLIiFojJIupSPuCdBFnMXdk8MOMZF4kvbCfKpNKrrQh2uAoQax9vkcoXStsCnNhKOnm(uvMrJ6RueCIzNK1C(dxjrBy8j4QVsrWjMDswZ5pCLeFggzBy8jn4iGUHTls(IyFKnDopjs6ZiVvfCcgc)gsoOpPbhb0nSDXepCTmkYPMKF(ajs6ZiVvfCdjyi8Bi5G(ufmEqHls(IyFKnDopjiyi8Bi5G(KbAWraDdBxWjMDsQh2uks6ZiVPWQ)CvyIteRcrcZMIsEjiwji0hnYkV608zNf64rHWvKZTgZ4bfEtuZ5pCLQaUcs(IyFKnDopzoQax9vkcoXStsCnNhKOnm(uvMrJ6RueCIzNK1C(dxjrBy8j4QVsrWjMDswZ5pCLeFggzBy8jn4iGUHTlM4HRLrro1K8ZhirsFg5TQiyi8Bi5G(Kg1xPiYNtYOi1dBkfp91ygpOWBIAo)HRufWvWepCTmkYPMKF(azoQax9vkcoXStYAo)HRKOnm(eC1xPi4eZojR58hUsIpdJSnm(Kg1xPiYNtYOi1dBkfpDn3yejFrSpYMoNNej9zK3wJz8GcVjQ58hUsvaxb5ZjzuK6HnLMJkWnehb0nSDXepCTmkYPMKF(ajs6ZiVvr1FodQcoocOBy7coXSts9WMsrsFg5nnQVsrWjMDsQh2ukUHTRXiXHFFOrWjMDsQNXfDO0AmJhu4nrnN)WvQc4ki5lI9r2058K5OcC1xPi4eZojR58hUsI2W4tWvFLIGtm7KSMZF4kj(mmY2W4tAWraDdBxWjMDsQh2uks6ZiVPq4kII1GJa6g2UyIhUwgf5utYpFGej9zK3QqruCvWXraDdBxWjMDsQh2uks6ZiVPbhb0nSDr(CsgfPEytPiPpJ8wfkIIRcoocOBy7coXSts9WMsrsFg5nnF2zHoEuiCToNgJeh(9HgbNy2jPEgx0HsRXmEqH3e1C(dxPkGRaoXStYivnhvGFJrK8fX(iB6CEsK0NrEtHNtZLuFLIi5lI9r2058K00dYPKvrqOrjrBy8j4kwJ6Rue5ZjzuK6HnLIBy7RXmEqH3e1C(dxPkGRaoXStsvot(GmhvGFj1xPis(IyFKnDopjn9GCkzveeAus0ggFcE1VgZ4bfEtuZ5pCLQaUc4eZojvH42yoQa)gJi5lI9r2058KiPpJ8MMlP(kfXepCTmkYPMKF(ajs6ZiVPqcgc)gsoOpPXWlP(kfrYxe7JSPZ5jPPhKtjRIGqJsI2W4tWvSYkFj1xPis(IyFKnDopjn9GCkzveeAus0ggFQQQ3angPEsMKh4RqlbNy2jPkNjFqRXmEqH3e1C(dxPkGRaoXStsviUnMJkWVXis(IyFKnDopjs6ZiVPqcgc)gsoOpP5sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(KcvSMlP(kfrYxe7JSPZ5jPPhKtjRIGqJsI2W4tvv9AuFLIiFojJIupSPuCdBFnMXdk8MOMZF4kvbCfWjMDsgPQ5OcC1xPi4eZojX1CEqI2W4tvzgnQVsrWjMDsQh2ukE6RXmEqH3e1C(dxPkGRaoXStYpQ1qquZCubU6RueyiItm3gKFisIXJg1xPi4eZoj1dBkfpDZX1mYHR1ACLDbMfnAbvxywxW9Li)ybvE1TGixq1oQUfyJ8By3wWelq9HGUlaxZ5b1waxgkxWRH8Jfu5jMDAbWMZKpO1ygpOWBIAo)HRufWvGEsnYXKmkYpYVMJkWvFLIGtm7KexZ5bjAdJpvL6RueCIzNK4AopiXNHr2ggFsJ6RueCIzNK4AopirBy8jfQynQVsrWjMDsQh2uks6ZiVPSYQVsrWjMDsIR58GeTHXNQs9vkcoXStsCnNhK4ZWiBdJpPr9vkcoXStsCnNhKOnm(KcvSg1xPiYNtYOi1dBkfj9zK30Cj1xPiM4HRLrro1K8ZhirsFg5T1ygpOWBIAo)HRufWvaNy2jPke3gZrf4QVsrONuJCmjJI8J8R4PRr9vkcoXStsCnNhKOnm(Kc1AnMXdk8MOMZF4kvbCfWjMDsgPQ5OcC1xPi4eZojX1CEqI2W4tvzgn4iGUHTl4eZoj1dBkfj9zK3uiCZO4QzZEL5aF1yKgIJa6g2Ui5lI9r2058KiPpJ8wvW1sXAWraDdBxWjMDsQh2uks6ZiVPq4vJZzWAmJhu4nrnN)WvQc4kGtm7KmsvZrf4QVsrWjMDsIR58GeTHXNQYmAWraDdBxWjMDsQh2uks6ZiVPq4MrXvZM9kZb(Qbh(9HgbNy2jPEgx0HsRXmEqH3e1C(dxPkGRaoXStYpQ1qquZCubU6RueCIzNK4AopirBy8jfQLg1xPi4eZojR58hUsI2W4tvP(kfbNy2jznN)Wvs8zyKTHXNmhxZihUwRXmEqH3e1C(dxPkGRaoXStYpQ1qquZCuboocOBy7coXStYivfj9zK3QQ61O(kfbNy2jznN)Wvs0ggFQk1xPi4eZojR58hUsIpdJSnm(K54Ag5W1AnMXdk8MOMZF4kvbCfWjMDsQYzYhK5OcC1xPi4eZojX1CEqI2W4tWvFLIGtm7KexZ5bj(mmY2W4tAuFLIGtm7KSMZF4kjAdJpbx9vkcoXStYAo)HRK4ZWiBdJpTgZ4bfEtuZ5pCLQaUcitbMhu4MJkW)SZcD8uLwNBnUYUGQPAYxGkn2e5lahb0nS9fyJ8By3mFb20cchsPfO(qq3fmXckpiOfGR58GAlGldLl41q(XcQ8eZoTaZYuDnMXdk8MOMZF4kvbCfWjMDsQcXTXCubU6RueCIzNK4AopirBy8jfQ1AmJhu4nrnN)WvQc4kGtm7K8JAnee1mhxZihUwRXRXmEqH3e)We9jFQaUcuHq(jj7kzoQa)hMOp5J4IAd7ysHW1sXRXmEqH3e)We9jFQaUc0tQroMKrr(r(DnMXdk8M4hMOp5tfWvaNy2j5h1AiiQzoQa)hMOp5J4IAd7yQkTu8AmJhu4nXpmrFYNkGRaoXStYivxJz8GcVj(Hj6t(ubCfuqjjvH42SgVgZ4bfEte6Ktj8ckjPke3gZrf45ZPsKhK4IAyKoeY5ujjo(F2VAuFLI4IAyKoeY5ujjo(F2VYsgTr80xJz8GcVjcDYPSc4kOKrBKEyInhvGNpNkrEqIJe1GusIWimeP5Zol0XJcv0NBnMXdk8Mi0jNYkGRGlXtTAKoTgZ4bfEte6KtzfWvqYxe7JSPZ5jZrf4F2zHoEuy1R41ygpOWBIqNCkRaUcA1OYG8dPEytP5OcC1xPi4eZoj1dBkf3W21GJa6g2UGtm7KupSPuK0NrEBnMXdk8Mi0jNYkGRGpkZiBYOiNi)KpRXmEqH3eHo5uwbCfmXdxlJICQj5NpqRXmEqH3eHo5uwbCfWjMDsQh2uUgZ4bfEte6KtzfWvq(CsgfPEytP5OcC1xPiYNtYOi1dBkf3W2xJRSlWSOrlO6cZ6cMybTQ1JOZhAbSVacMj5fu5jMDAbWgIBZcUVe5hlyQPfCwmMvfu5v3cSr(nSxWZHOwBb5ZDKFSGkpXStl48IRdXco)Lfu5jMDAbNxCDSauBbddr(qxZxGnTam7Apl41OfuDHzDb2OPg5lyQPfCwmMvfu5v3cSr(nSxWZHOwBb20cq(qz(0Nfm10cQCZ6cW1S7eK5lOflWM0gcAbn2eTa0iwJz8GcVjcDYPSc4kqpPg5ysgf5h5xZrf4g5WqKpcoXStscxhAUK6Ruet8W1YOiNAs(5dK4PR5sQVsrmXdxlJICQj5NpqIK(mYBvb3qgpOWfCIzNKQqCBeeme(nKCqFQYO(kfHEsnYXKmkYpYVIpdJSnm(KbRXv2fC(llO6cZ6cQ5MR9SavI8f8A0Db3xI8Jfm10colgZ6cSr(nSnFb2K2qql41OfGMfmXcAvRhrNp0cyFbemtYlOYtm70cGne3MfG8fm10cQ2r1PGkV6wGnYVHTynMXdk8Mi0jNYkGRa9KAKJjzuKFKFnhvGR(kfbNy2jPEytP4PRr9vkI85Kmks9WMsrsFg5TQGBiJhu4coXStsviUnccgc)gsoOpvzuFLIqpPg5ysgf5h5xXNHr2ggFYagpOWBIqNCkRaUc4eZojvH42yoQa)gJi5lI9r2058KiPpJ8McpNYkFj1xPis(IyFKnDopjn9GCkzveeAus0ggFsHkEnMXdk8Mi0jNYkGRaoXStsviUnMJkWvFLIqpPg5ysgf5h5xXtxZLuFLIyIhUwgf5utYpFGepDnxs9vkIjE4AzuKtnj)8bsK0NrERk4mEqHl4eZojvH42iiyi8Bi5G(0ACLDbvoKnRuBbWMZKpOfWZcMAAbKFxquwqLxDlWUM8fKp3r(XcMAAbvEIzNwGIIZF4kTai6G8lNkTgZ4bfEte6KtzfWvaNy2jPkNjFqMJkWvFLIGtm7KupSPu801O(kfbNy2jPEytPiPpJ8wvh4RM85ujYdsWjMDsI8cYrJsRXv2fu5q2SsTfaBot(GwaplyQPfq(DbrzbtnTGQDuDlWg53WEb21KVG85oYpwWutlOYtm70cuuC(dxPfarhKF5uP1ygpOWBIqNCkRaUc4eZojv5m5dYCubU6Rue5ZjzuK6HnLINUg1xPi4eZoj1dBkf3W21O(kfr(CsgfPEytPiPpJ8wvWpWxn5ZPsKhKGtm7Ke5fKJgLwJz8GcVjcDYPSc4kGtm7K8JAnee1mhvGFj1xPiM4HRLrro1K8ZhiXtxZWqKpcoXStscxhAmu9vkIlXtTAKojUHTRSYmEqMij50hrn4AzGMlP(kfXepCTmkYPMKF(ajs6ZiVPqgpOWfCIzNKFuRHGOMGGHWVHKd6tMJRzKdxlZjoHusIRzKlrf4QVsrGHioXCBq(HexZUtqIBy7Amu9vkcoXSts9WMsXtxzLn0ihgI8reMOupSPKUAmu9vkI85Kmks9WMsXtxzLXraDdBxqMcmpOWfjXxLmWadwJz8GcVjcDYPSc4kGtm7K8JAnee1mhvGR(kfbgI4eZTb5hIKy8yoUMroCTwJz8GcVjcDYPSc4kGtm7KmsvZrf4QVsrWjMDsIR58GeTHXNQcUjorSkejMy(YpdJexZ5b1wJz8GcVjcDYPSc4kGtm7KufIBJ5OcC1xPiYNtYOi1dBkfpDLv(Zol0XJc16CRXmEqH3eHo5uwbCfqMcmpOWnhvGR(kfr(CsgfPEytP4g2Ug1xPi4eZoj1dBkf3W2nh5dL5tFKOc8p7SqhpkeUz)CMJ8HY8Pps0)txepeCTwJz8GcVjcDYPSc4kGtm7KuLZKpO1414k7cy8GcVjYy4bfEfWvaMDmbjz8Gc3CuboJhu4cYuG5bfUaxZUtqi)qZNDwOJhfcxrFongAK5ZPsKhKOH0Rdx2Mi)kRS6RuenKED4Y2e5x0ggFcU6RuenKED4Y2e5x8zyKTHXNmynMXdk8MiJHhu4vaxbKPaZdkCZrf4F2zHoEQcUjorSkejitHuhpAmehb0nSDXepCTmkYPMKF(ajs6ZiVvfCgpOWfKPaZdkCbbdHFdjh0NuwzCeq3W2fCIzNK6HnLIK(mYBvbNXdkCbzkW8GcxqWq43qYb9jLv2WHHiFe5ZjzuK6HnLAWraDdBxKpNKrrQh2uks6ZiVvfCgpOWfKPaZdkCbbdHFdjh0NmWanQVsrKpNKrrQh2ukUHTRr9vkcoXSts9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBxJrQNKj5b(k0smXdxlJICQj5NpqRXmEqH3ezm8GcVc4kGmfyEqHBoQapFovI8GenKED4Y2e5xdocOBy7coXSts9WMsrsFg5TQGZ4bfUGmfyEqHliyi8Bi5G(0ACLDbWMZKpOfGklanA3wWG(0cMybVgTGjM)cy)UaBAb1SjAbtel4ZUslaxZ5b1wJz8GcVjYy4bfEfWvaNy2jPkNjFqMJkWXraDdBxmXdxlJICQj5NpqIK4RsAmu9vkcoXStsCnNhKOnm(KcnXjIvHiXeZx(zyK4AopOMgCeq3W2fCIzNK6HnLIK(mYBvbNGHWVHKd6tA(SZcD8OqtCIyvisW6YpYr)3x(zNL64rJ6Rue5ZjzuK6HnLIBy7gSgZ4bfEtKXWdk8kGRaoXStsvot(GmhvGJJa6g2UyIhUwgf5utYpFGejXxL0yO6RueCIzNK4AopirBy8jfAIteRcrIjMV8ZWiX1CEqnnddr(iYNtYOi1dBk1GJa6g2UiFojJIupSPuK0NrERk4eme(nKCqFsdocOBy7coXSts9WMsrsFg5nfAIteRcrIjMV8ZWiVeeRKSePK1nynMXdk8MiJHhu4vaxbCIzNKQCM8bzoQahhb0nSDXepCTmkYPMKF(ajsIVkPXq1xPi4eZojX1CEqI2W4tk0eNiwfIetmF5NHrIR58GAAm0ihgI8rKpNKrrQh2uQSY4iGUHTlYNtYOi1dBkfj9zK3uOjorSkejMy(YpdJ8sqSsYsKYm0nqdocOBy7coXSts9WMsrsFg5nfAIteRcrIjMV8ZWiVeeRKSePK1nynMXdk8MiJHhu4vaxbCIzNKQCM8bzoQa)sQVsrK8fX(iB6CEsA6b5uYQii0OKOnm(e8lP(kfrYxe7JSPZ5jPPhKtjRIGqJsIpdJSnm(KgdvFLIGtm7KupSPuCdBxzLvFLIGtm7KupSPuK0NrERk4h4RbAmu9vkI85Kmks9WMsXnSDLvw9vkI85Kmks9WMsrsFg5TQGFGVgSgZ4bfEtKXWdk8kGRaoXStsviUnMJkWVXis(IyFKnDopjs6ZiVPqZUYkB4LuFLIi5lI9r2058K00dYPKvrqOrjrBy8jfQynxs9vkIKVi2hztNZtstpiNswfbHgLeTHXNQ6sQVsrK8fX(iB6CEsA6b5uYQii0OK4ZWiBdJpzWAmJhu4nrgdpOWRaUc4eZojvH42yoQax9vkc9KAKJjzuKFKFfpDnxs9vkIjE4AzuKtnj)8bs801Cj1xPiM4HRLrro1K8ZhirsFg5TQGZ4bfUGtm7KufIBJGGHWVHKd6tRXmEqH3ezm8GcVc4kGtm7K8JAnee1mhvGFj1xPiM4HRLrro1K8ZhiXtxZWqKpcoXStscxhAmu9vkIlXtTAKojUHTRSYmEqMij50hrn4AzGgdVK6Ruet8W1YOiNAs(5dKiPpJ8Mcz8GcxWjMDs(rTgcIAccgc)gsoOpPSY4iGUHTl0tQroMKrr(r(vK0NrEtzLXHjYzFeNukrSBG54Ag5W1YCItiLK4Ag5subU6RueyiItm3gKFiX1S7eK4g2UgdvFLIGtm7KupSPu80vwzdnYHHiFeHjk1dBkPRgdvFLIiFojJIupSPu80vwzCeq3W2fKPaZdkCrs8vjdmWG1ygpOWBImgEqHxbCfWjMDs(rTgcIAMJkWvFLIadrCI52G8drsmE0O(kfbbJo7x6k1JH8bXqIN(AmJhu4nrgdpOWRaUc4eZoj)OwdbrnZrf4QVsrGHioXCBq(HijgpAmu9vkcoXSts9WMsXtxzLvFLIiFojJIupSPu80vw5lP(kfXepCTmkYPMKF(ajs6ZiVPqgpOWfCIzNKFuRHGOMGGHWVHKd6tgyoUMroCTwJz8GcVjYy4bfEfWvaNy2j5h1AiiQzoQax9vkcmeXjMBdYpejX4rJ6RueyiItm3gKFiAdJpbx9vkcmeXjMBdYpeFggzBy8jZX1mYHR1AmJhu4nrgdpOWRaUc4eZoj)OwdbrnZrf4QVsrGHioXCBq(HijgpAuFLIadrCI52G8drsFg5TQGBOHQVsrGHioXCBq(HOnm(uLHXdkCbNy2j5h1AiiQjiyi8Bi5G(KbvCGVgyoUMroCTwJz8GcVjYy4bfEfWvGttnLYH(6uBmhvGBysLKA1SkePSYg5GWNq(HbAuFLIGtm7KexZ5bjAdJpbx9vkcoXStsCnNhK4ZWiBdJpPr9vkcoXSts9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBFnMXdk8MiJHhu4vaxbCIzNKrQAoQax9vkcoXStsCnNhKOnm(uvWnXjIvHiXeZx(zyK4AopO2AmJhu4nrgdpOWRaUcApDk9WeBoQa)Zol0XtvWv0NtJ6RueCIzNK6HnLIBy7AuFLIiFojJIupSPuCdBxZLuFLIyIhUwgf5utYpFGe3W2xJz8GcVjYy4bfEfWvaNy2jPke3gZrf4QVsrKpisgf5uNe1epDnQVsrWjMDsIR58GeTHXNuOISgZ4bfEtKXWdk8kGRaoXStsvot(GmhvG)zNf64Pk4M4eXQqKqLZKpi5NDwQJhnQVsrWjMDsQh2ukUHTRr9vkI85Kmks9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBxJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jn4iGUHTlitbMhu4IK(mYBRXmEqH3ezm8GcVc4kGtm7KuLZKpiZrf4QVsrWjMDsQh2ukUHTRr9vkI85Kmks9WMsXnSDnxs9vkIjE4AzuKtnj)8bsCdBxJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jnddr(i4eZojJuvdocOBy7coXStYivfj9zK3Qc(b(Q5Zol0XtvWv0kwdocOBy7cYuG5bfUiPpJ82AmJhu4nrgdpOWRaUc4eZojv5m5dYCubU6RueCIzNK6HnLINUg1xPi4eZoj1dBkfj9zK3Qc(b(Qr9vkcoXStsCnNhKOnm(eC1xPi4eZojX1CEqIpdJSnm(KgdXraDdBxqMcmpOWfj9zK3uw585ujYdsWjMDsI8cYrJsgSgZ4bfEtKXWdk8kGRaoXStsvot(GmhvGR(kfr(CsgfPEytP4PRr9vkcoXSts9WMsXnSDnQVsrKpNKrrQh2uks6ZiVvf8d8vJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8jngIJa6g2UGmfyEqHls6ZiVPSY5ZPsKhKGtm7Ke5fKJgLmynMXdk8MiJHhu4vaxbCIzNKQCM8bzoQax9vkcoXSts9WMsXnSDnQVsrKpNKrrQh2ukUHTR5sQVsrmXdxlJICQj5NpqINUMlP(kfXepCTmkYPMKF(ajs6ZiVvf8d8vJ6RueCIzNK4AopirBy8j4QVsrWjMDsIR58GeFggzBy8P1ygpOWBImgEqHxbCfWjMDsQYzYhK5Oc8HZdAe1edn1cD8uLIConQVsrWjMDsIR58GeTHXNuiCdz8GmrsYPpIAvZAzGM85ujYdsWjMDsQgFvoVFYhnmEqMij50hrnfQLg1xPiUep1Qr6K4g2(AmJhu4nrgdpOWRaUc4eZojjy0HIgkCZrf4dNh0iQjgAQf64Pkf5CAuFLIGtm7KexZ5bjAdJpvL6RueCIzNK4AopiXNHr2ggFst(CQe5bj4eZojvJVkN3p5JggpitKKC6JOMc1sJ6RuexINA1iDsCdBFnMXdk8MiJHhu4vaxbCIzNKQqCBwJz8GcVjYy4bfEfWvazkW8Gc3CubU6Rue5ZjzuK6HnLIBy7AuFLIGtm7KupSPuCdBxZLuFLIyIhUwgf5utYpFGe3W2xJz8GcVjYy4bfEfWvaNy2jPkNjFqDl(n1r2TSq)hepOWnQKltF6tVda]] )

    
end