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


    spec:RegisterPack( "Arcane", 20210307, [[dWKB8fqikGEKir6suaeTjsPprHmksuNIezvIeWRubnlku3sKa1Ui8lvKggOQogPOLrb6zIKQPPIkDnvu12urf9nrsX4ejLoNirSorIAEQqUhOSpqvoOijTqvuEOiHUifG6JuaKgjfa1jPaWkPGMPijUPibTtve)uKazOQa1svrfEQiMQkuxLcq(Qkq0yvbSxP8xIgmWHrTys6Xqnzv1Lr2mL(SOA0IYPHSAkacVMemBqUTkTBQ(TWWjvhxfiTCjpxQMUIRRkBxK67u04bvopPW6vbcZNeA)kDtZ2XTKppu7edcFdQj8tD4NAegm1H)5t9Z3sgn0PwIoJvGZPwIZxQLKQfMDQLOZAaf8VDClPhVctTKSz07P8PNMJMSNQah3t7O7dIhu44ITZPD0fFAlr9HGgdaVP2s(8qTtmi8nOMWp1HFQryWuh(N3GPMwsxNWTtoNgSLKH(FYBQTKp1XTKuiNtlivlm70AykKlC2csngVadcFdQ5A4A45GUrAAbP5cXQqKGVYUoFxaYxGLth1cc7c60mipVl4RSRZ3fOmoJWkSanIxTGUoHxqOpOW7kjwdnG60cgn0rygAbjOBkUGm2)qipFbHDb4m2DcAbiFOQE6dk8fG8(q8FbHDbgHzhtqsgpOWns0sGq9P3oULKX1nCnAh3orZ2XTeYzvi63oRLW4bfElHshyEqH3s(uhxi9bfElXaQtlWaoDG5bf(cq2fysgv0cGcZfe(cUSZlG9)c4fCCmPWtt1dEbMi)hMla1xaoUipFbp9wcUqdviULCzNf64zbhbBbAE(fODb4iG(HPlM4HZKHvozK8Y5irrxg59fCeSfO8ci4i8Bi5GU0coCbmEqHlM4HZKHvozK8Y5ibbhHFdjh0LwGslq7cWra9dtxWfMDsQhMujk6YiVVGJGTaLxabhHFdjh0LwWHlGXdkCXepCMmSYjJKxohji4i8Bi5GU0coCbmEqHl4cZoj1dtQeeCe(nKCqxAbkTaTlq9zTI65KmSs9WKkXpm9fODbQpRvWfMDsQhMuj(HPVaTl4tQpRvmXdNjdRCYi5LZrIFy6lq7cmWf8Jru8hX(i76CPGOOlJ8EBANyW2XTeYzvi63oRLW4bfElHshyEqH3s(uhxi9bfElXaQtlWaoDG5bf(cq2fysgv0cGcZfe(cUSZlG9)c4fCoIdEbMi)hMla1xaoUipFbp9wcUqdviULCzNf64zbhbBbPo8xG2fGJa6hMUOEojdRupmPsu0LrEFbhbBbkVacoc)gsoOlTGdxaJhu4I65KmSs9WKkbbhHFdjh0LwGslq7cWra9dtxmXdNjdRCYi5LZrIIUmY7l4iylq5fqWr43qYbDPfC4cy8GcxupNKHvQhMuji4i8Bi5GU0coCbmEqHlk(JyFKDDUuqqWr43qYbDPfO0c0UaCeq)W0fCHzNK6HjvIIUmY7laEl4CHFBANK6TJBjKZQq0VDwl5tDCH0hu4TKZEiO)cmaZ1nCnwqFySc9fyJAbtgTGJJjfEAQEWlWe5)WSLGl0qfIBjQpRvWfMDsMX1nCne9HXkSGJwG6ZAfCHzNKzCDdxdXLHt2hgRWc0UaCeq)W0ff)rSpYUoxkik6YiVVGJGTaLxGbxWHlq5fqWr43qYbDPfC4cy8Gcxu8hX(i76CPGGGJWVHKd6slqPfO0c0UaCeq)W0ft8WzYWkNmsE5CKOOlJ8(coc2cuEbgCbhUaLxabhHFdjh0LwWHlGXdkCrXFe7JSRZLcccoc)gsoOlTGdxaJhu4IjE4mzyLtgjVCosqWr43qYbDPfO0cuAbAxaocOFy6cUWSts9WKkrrxg59fCeSfO8cm4coCbkVacoc)gsoOlTGdxaJhu4II)i2hzxNlfeeCe(nKCqxAbhUagpOWft8WzYWkNmsE5CKGGJWVHKd6sl4WfW4bfUGlm7KupmPsqWr43qYbDPfO0cuQLGZyK3s0SLW4bfElHlm7K8I6Dee1Bt7KZTDClHCwfI(TZAjFQJlK(GcVLC2db9xGbyUUHRXc6dJvOVaBulyYOfCoIdEbMi)hMTeCHgQqClr9zTcUWStYmUUHRHOpmwHfC0cuFwRGlm7KmJRB4AiUmCY(WyfwG2fGJa6hMUOEojdRupmPsu0LrEFbhbBbkVadUGdxGYlGGJWVHKd6sl4WfW4bfUOEojdRupmPsqWr43qYbDPfO0cuAbAxaocOFy6II)i2hzxNlfefDzK3xWrWwGYlWGl4WfO8ci4i8Bi5GU0coCbmEqHlQNtYWk1dtQeeCe(nKCqxAbhUagpOWff)rSpYUoxkii4i8Bi5GU0cuAbkTaTlahb0pmDXepCMmSYjJKxohjk6YiVVGJGTaLxGbxWHlq5fqWr43qYbDPfC4cy8GcxupNKHvQhMuji4i8Bi5GU0coCbmEqHlk(JyFKDDUuqqWr43qYbDPfC4cy8GcxmXdNjdRCYi5LZrccoc)gsoOlTaLwGslq7cWra9dtxWfMDsQhMujk6YiV3sWzmYBjA2sy8GcVLWfMDsEr9ocI6TPDY5Bh3siNvHOF7SwYN64cPpOWBjN9qq)fyaMRB4ASG(Wyf6lWg1cMmAboRa9xW5izbMi)hMTeCHgQqClr9zTcUWStYmUUHRHOpmwHfC0cuFwRGlm7KmJRB4AiUmCY(WyfwG2fGJa6hMUO4pI9r215sbrrxg59fCeSfO8cm4coCbkVacoc)gsoOlTGdxaJhu4II)i2hzxNlfeeCe(nKCqxAbkTaLwG2fGJa6hMUGlm7KupmPsu0LrEFbWd2csD4VaTlahb0pmDr9CsgwPEysLOOlJ8(cGhSfK6WVLGZyK3s0SLW4bfElHlm7K8I6Dee1Bt7KZz74wc5Ske9BN1sWfAOcXTe1N1k4cZojZ46gUgI(WyfwaSfO(Swbxy2jzgx3W1qCz4K9HXkSaTlahb0pmDXepCMmSYjJKxohjk6YiVVGJwabhHFdjh0LwG2fGJa6hMUGlm7KupmPsu0LrEFbhbBbkVacoc)gsoOlTGdxaJhu4IjE4mzyLtgjVCosqWr43qYbDPfO0c0UGl7SqhplaElqZZ3sy8GcVLu8hX(i76CPqBANKAAh3siNvHOF7SwcUqdviULO(Swbxy2jzgx3W1q0hgRWcGTa1N1k4cZojZ46gUgIldNSpmwHfODb4iG(HPl4cZoj1dtQefDzK3xWrWwabhHFdjh0LwG2f8Jru8hX(i76CPGOOlJ8ElHXdk8wYepCMmSYjJKxoh1M2jP22XTeYzvi63oRLGl0qfIBjQpRvWfMDsMX1nCne9HXkSaylq9zTcUWStYmUUHRH4YWj7dJvybAxWNuFwRyIhotgw5KrYlNJep9fODbQpRvupNKHvQhMuj(HP3sy8GcVLWfMDsQhMu1M2jPK2XTeYzvi63oRLGl0qfIBjQpRvWfMDsMX1nCne9HXkSaylq9zTcUWStYmUUHRH4YWj7dJvybAxaocOFy6IjE4mzyLtgjVCosu0LrEFbhbBbkVacoc)gsoOlTGdxaJhu4II)i2hzxNlfeeCe(nKCqxAbkTaTlahb0pmDbxy2jPEysLOOlJ8(cG3cox4VaTl4Yol0XZcGhSfK6NVLW4bfElPEojdRupmPQnTt0e(TJBjKZQq0VDwlbxOHke3suFwRGlm7KmJRB4Ai6dJvybWwG6ZAfCHzNKzCDdxdXLHt2hgRWc0UaCeq)W0ft8WzYWkNmsE5CKOOlJ8(coAbeCe(nKCqxAbAxG6ZAf1ZjzyL6HjvINElHXdk8wsXFe7JSRZLcTPDIMA2oULqoRcr)2zTeCHgQqClr9zTcUWStYmUUHRHOpmwHfaBbQpRvWfMDsMX1nCnexgozFySclq7cWra9dtxWfMDsQhMujk6YiVVa4TGZf(lq7cuFwROEojdRupmPs80xG2f8Jru8hX(i76CPGOOlJ8ElHXdk8wYepCMmSYjJKxoh1M2jAAW2XTeYzvi63oRLGl0qfIBj4iG(HPlM4HZKHvozK8Y5irrxg59faVfOj8xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbPo8xG2fO(Swbxy2jPEysL4hMElHXdk8ws9CsgwPEysvBANOzQ3oULqoRcr)2zTeCHgQqClr9zTcUWStYmUUHRHOpmwHfaBbQpRvWfMDsMX1nCnexgozFySclq7cWra9dtxWfMDsQhMujk6YiVVa4bBbg88lq7cWra9dtxupNKHvQhMujk6YiVVa4bBbg88lq7cuFwRGlm7KmJRB4Ai6dJvybWwG6ZAfCHzNKzCDdxdXLHt2hgRWc0UGl7SqhplaEWwGMNVLW4bfElP4pI9r215sH20orZZTDClHCwfI(TZAjmEqH3s0lQtoMKHvEr(VL8PoUq6dk8wIbuNwWbhPWf8FfYZxqQEWliQfCoIdEbMi)hM9fmXcuFiO)cWzCLt9fW2HQf86ipFbPAHzNwWzCvCo1sWfAOcXTe1N1k4cZojXzCLtI(WyfwWrlq9zTcUWStsCgx5K4YWj7dJvybAxG6ZAfCHzNK4mUYjrFySclaEla(lq7cuFwRGlm7KupmPsu0LrEFbkQ4cuFwRGlm7KeNXvoj6dJvybhTa1N1k4cZojXzCLtIldNSpmwHfODbQpRvWfMDsIZ4kNe9HXkSa4Ta4VaTlq9zTI65KmSs9WKkrrxg59fODbFs9zTIjE4mzyLtgjVCosu0LrEVnTt088TJBjKZQq0VDwlbxOHke3suFwRqVOo5ysgw5f5FXtVLW4bfElHlm7KufI7tBANO55SDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK4mUYjrFyScl4OfyWfODbQpRvWfMDsQhMujE6TegpOWBjCHzNKrP2M2jAMAAh3siNvHOF7SwcUqdviULO(Swbxy2jjoJRCs0hgRWcoAbgCbAxGbUaLxaocOFy6cUWSts9WKkrrxg59fCeSfOj8xG2fGJa6hMUyIhotgw5KrYlNJefDzK3xWrWwGMWFbAxaocOFy6II)i2hzxNlfefDzK3xWrWwW5xGsTegpOWBjCHzNKrP2M2jAMABh3siNvHOF7SwcJhu4TeUWStYlQ3rquVLGZyK3s0SLGl0qfIBjQpRvWfMDsIZ4kNe9HXkSa4TanxG2fO(Swbxy2jzgx3W1q0hgRWcoAbQpRvWfMDsMX1nCnexgozFyScTPDIMPK2XTeYzvi63oRLW4bfElHlm7K8I6Dee1Bj4mg5TenBj4cnuH4wcocOFy6cUWStYOuffDzK3xWrl4CxG2fO(Swbxy2jzgx3W1q0hgRWcoAbQpRvWfMDsMX1nCnexgozFyScTPDIbHF74wc5Ske9BN1sWfAOcXTKpP(SwrXFe7JSRZLcY0piNkwfbHgne9HXkSayl4CBjmEqH3s4cZojv5Q4CQnTtmOMTJBjKZQq0VDwlbxOHke3s(Xik(JyFKDDUuqu0LrEFbAxWNuFwRyIhotgw5KrYlNJefDzK3xa8wabhHFdjh0LwG2fO8c(K6ZAff)rSpYUoxkit)GCQyveeA0q0hgRWcGTa4VafvCbFs9zTII)i2hzxNlfKPFqovSkccnAi6dJvybhTGZDbk1sy8GcVLWfMDsQcX9PnTtmObBh3siNvHOF7SwcUqdviUL8Jru8hX(i76CPGOOlJ8(cG3co)c0UGpP(SwrXFe7JSRZLcY0piNkwfbHgne9HXkSayla(lq7cuFwROEojdRupmPs8dtVLW4bfElHlm7Kmk120oXGPE74wc5Ske9BN1sWfAOcXTKFmII)i2hzxNlfefDzK3xa8wabhHFdjh0LwG2f8j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwHfaVfa)fODbFs9zTII)i2hzxNlfKPFqovSkccnAi6dJvybhTGZDbAxG6ZAf1ZjzyL6HjvIFy6TegpOWBjCHzNKQqCFAt7edEUTJBjKZQq0VDwlbxOHke3suFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWc0Ua1N1k4cZojZ46gUgI(WyfwaSfO(Swbxy2jzgx3W1qCz4K9HXk0sy8GcVLWfMDsQYvX5uBANyWZ3oULqoRcr)2zTeCHgQqCl5Yol0XZcoAbAE(wcJhu4TekDG5bfEBANyWZz74wc5Ske9BN1sy8GcVLWfMDsQcX9PL8PoUq6dk8wYbzg5lqLgtI8fGJa6hM(cmr(pm7gVatAbHdPXcuFiO)cMyb2he0cWzCLt9fW2HQf86ipFbPAHzNwqkOsTLGl0qfIBjQpRvWfMDsIZ4kNe9HXkSa4TanBt7edMAAh3siNvHOF7SwcJhu4TeUWStsvUkoNAjFQJlK(GcVLyaCV0hXdbPXc66K)xGbyUUHRXc6dJvOVaZmYxGknMe5lahb0pm9fyI8Fy2Bj4cnuH4wI6ZAfCHzNKzCDdxdrFySclaEla(TPDIbtTTJBjKZQq0VDwlbNXiVLOzlHXdk8wcxy2j5f17iiQ3M20sSOEgYZLHo5u1oUDIMTJBjKZQq0VDwlHXdk8wcLoW8GcVL8PoUq6dk8wYbzg5lOEUJ88fqOjJQfmz0csswqul44dYfar5K)5crDJxGjTat2NfmXcmGthlqLSrrlyYOfCCmPWtt1dEbMi)hMIfya1PfGMfW9f0JWxa3xW5io4fKX9fyroQNr)feVAbMKrPPf01jFwq8QfGZ4kN6TeCHgQqClr5fupNSrLtIosplCzFI6kiNvHO)cuuXfupNSrLtIHU6rXqstU0fKZQq0FbkTaTlq5fO(Swr9CsgwPEysL4hM(cuuXfOxuAzo(l0uWfMDsQYvX50cuAbAxaocOFy6I65KmSs9WKkrrxg5920oXGTJBjKZQq0VDwlHXdk8wcLoW8GcVL8PoUq6dk8wIbGDbMKrPPfyroQNr)feVAb4iG(HPVatK)dZ(cy)VGUo5ZcIxTaCgx5u34fOxOOqd6GGwGbC6ybrAQwaLMknMmKNVacQtTeCHgQqClzyiYhr9CsgwPEysLGCwfI(lq7cWra9dtxupNKHvQhMujk6YiVVaTlahb0pmDbxy2jPEysLOOlJ8(c0Ua1N1k4cZoj1dtQe)W0xG2fO(Swr9CsgwPEysL4hM(c0Ua9IslZXFHMcUWStsvUkoNAt7KuVDClHCwfI(TZAj4cnuH4ws9CYgvoj(OogPdHCU0qIJ7L9VGCwfI(lq7cuFwR4J6yKoeY5sdjoUx2)sBf9r80BjmEqH3sSOIKQqCFAt7KZTDClHCwfI(TZAj4cnuH4ws9CYgvojYluhsdjcJWqKGCwfI(lq7cUSZcD8Sa4TGuY5BjmEqH3sSv0hPhP520o58TJBjKZQq0VDwlbxOHke3smWfupNSrLtIosplCzFI6kiNvHOFlHXdk8wYN4jtnkNAt7KZz74wc5Ske9BN1sWfAOcXTeCeq)W0f1ZjzyL6HjvII4VgTegpOWBjCHzNKrP2M2jPM2XTeYzvi63oRLGl0qfIBj4iG(HPlQNtYWk1dtQefXFnwG2fO(Swbxy2jjoJRCs0hgRWcoAbQpRvWfMDsIZ4kNexgozFyScTegpOWBjCHzNKQqCFAt7KuB74wcJhu4TK65KmSs9WKQwc5Ske9BN1M2jPK2XTeYzvi63oRLGl0qfIBjg4cuEb1ZjBu5KOJ0Zcx2NOUcYzvi6VafvCb1ZjBu5KyOREumK0KlDb5Ske9xGsTKp1XfsFqH3sojQldbPXcmPfOZOAb6XGcFbVoTat0KTGu9GnEbQVzbOzbMiiOfaX9zbqHNVaYJxE2cSrTa1yYwWKrl4Ceh8cy)VGu9GxGjY)HzFbphI69fup3rE(cMmAbjjliQfC8b5cGOCY)CHOElHXdk8wIEmOWBt7enHF74wc5Ske9BN1sWfAOcXTe1N1kQNtYWk1dtQe)W0xGIkUa9IslZXFHMcUWStsvUkoNAjmEqH3s(epzQr5uBANOPMTJBjKZQq0VDwlbxOHke3suFwROEojdRupmPs8dtFbkQ4c0lkTmh)fAk4cZojv5Q4CQLW4bfElP4pI9r215sH20ortd2oULqoRcr)2zTeCHgQqClr9zTI65KmSs9WKkXpm9fOOIlqVO0YC8xOPGlm7KuLRIZPwcJhu4TKlQQO6YWkNOUKpTPDIMPE74wc5Ske9BN1sWfAOcXTe9IslZXFHMIjE4mzyLtgjVCoQLW4bfElHlm7KupmPQnTt08CBh3siNvHOF7SwcJhu4Te9I6KJjzyLxK)BjFQJlK(GcVLya1PfCWrkCbtSG(b9r0bbTa2xab3u8cs1cZoTGZG4(SG)RqE(cMmAbhhtk80u9GxGjY)H5cEoe17lOEUJ88fKQfMDAbgW4SqSada7cs1cZoTadyCwSauFbddr(qFJxGjTam7gnl41PfCWrkCbMOjd5lyYOfCCmPWtt1dEbMi)hMl45quVVatAbiFOQE6ZcMmAbPAkCb4m2DcY4f0JfysgbbTGoNMwaAeTeCHgQqClXaxWWqKpcUWStscNfcYzvi6VaTl4tQpRvmXdNjdRCYi5LZrIN(c0UGpP(SwXepCMmSYjJKxohjk6YiVVGJGTaLxaJhu4cUWStsviUpccoc)gsoOlTGuGfO(SwHErDYXKmSYlY)IldNSpmwHfOuBANO55Bh3siNvHOF7SwcJhu4Te9I6KJjzyLxK)BjFQJlK(GcVLyayxWbhPWfKXD3OzbQe5l41P)c(Vc55lyYOfCCmPWfyI8FyA8cmjJGGwWRtlanlyIf0pOpIoiOfW(ci4MIxqQwy2PfCge3NfG8fmz0cohXbFAQEWlWe5)Wu0sWfAOcXTe1N1k4cZoj1dtQep9fODbQpRvupNKHvQhMujk6YiVVGJGTaLxaJhu4cUWStsviUpccoc)gsoOlTGuGfO(SwHErDYXKmSYlY)IldNSpmwHfOuBANO55SDClHCwfI(TZAj4cnuH4wYpgrXFe7JSRZLcIIUmY7laEl48lqrfxWNuFwRO4pI9r215sbz6hKtfRIGqJgI(Wyfwa8wa8BjmEqH3s4cZojvH4(0M2jAMAAh3siNvHOF7SwcJhu4TeUWStsvUkoNAjFQJlK(GcVLCqslWK9zbtSGlRaTG(ROfysliJttlG84LNTGl78cSrTGjJwa5dQOfKQh8cmr(pmnEbuAYxaYUGjJkYO(c6dccAbd6slOOlJCKNVGWxW5ioyXcmagJ6liCinwGkndvlyIfO(kFbtSGdcQIfW(FbgWPJfGSlOEUJ88fmz0csswqul44dYfar5K)5crDrlbxOHke3sWra9dtxWfMDsQhMujkI)ASaTl4Yol0XZcoAbkVGZf(l4WfO8c0e(lifyb4in5Spcf0OqSVaLwGslq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWc0UadCb1ZjBu5KOJ0Zcx2NOUcYzvi6VaTlWaxq9CYgvojg6Qhfdjn5sxqoRcr)20orZuB74wc5Ske9BN1sy8GcVLWfMDsQYvX5ul5tDCH0hu4TedihI69fup3rE(cMmAbPAHzNwGbyUUHRXcGOCY)CPHXl4mUkoNwqplEq)f4XSavAbVo9xaplyYOfq(FbHDbP6bVaKDbgWPdmpOWxaQVGWAxaocOFy6lG7l4xHUoYZxaoJRCQVatee0cUSc0cqZcgwbAbqHNt1cMybQVYxWKvXlpBbfDzKJ88fCzNBj4cnuH4wI6ZAfCHzNK6HjvIN(c0Ua1N1k4cZoj1dtQefDzK3xWrWwqo(VaTlq5fupNSrLtcUWStsKBroA0qqoRcr)fOOIlahb0pmDbLoW8Gcxu0LrEFbk1M2jAMsAh3siNvHOF7SwcJhu4TeUWStsvUkoNAjFQJlK(GcVLCgxfNtlONfpO)cyitwJ(cuPfmz0cG4(Sam3NfG8fmz0cohXbVatK)dZfW9fCCmPWfyIGGwqr9jkAbtgTaCgx5uFbDDYNwcUqdviULO(Swr9CsgwPEysL4PVaTlq9zTcUWSts9WKkXpm9fODbQpRvupNKHvQhMujk6YiVVGJGTGC8VnTtmi8Bh3siNvHOF7SwcoJrElrZwcXfKgsCgJCjY2suFwRadrCH5(G8CjoJDNGe)W01QS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91QS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)AOKsk1sWfAOcXTKpP(SwXepCMmSYjJKxohjE6lq7cggI8rWfMDss4SqqoRcr)fODbkVa1N1k(epzQr5K4hM(cuuXfW4bLMKKtxe1xaSfO5cuAbAxWNuFwRyIhotgw5KrYlNJefDzK3xa8waJhu4cUWStYlQ3rquxqWr43qYbDPwcJhu4TeUWStYlQ3rquVnTtmOMTJBjKZQq0VDwl5tDCH0hu4TKuqoKglOpCnl41rE(csXuCbPAkCbMzKVGu9Gxqg3xGkr(cED63sWfAOcXTe1N1kWqexyUpipxueJNfODb4iG(HPl4cZoj1dtQefDzK3xG2fO8cuFwROEojdRupmPs80xGIkUa1N1k4cZoj1dtQep9fOulbNXiVLOzlHXdk8wcxy2j5f17iiQ3M2jg0GTJBjKZQq0VDwlbxOHke3suFwRGlm7KeNXvoj6dJvybhbBbP5cXQqKyI5kVmCsCgx5uVLW4bfElHlm7Kmk120oXGPE74wc5Ske9BN1sWfAOcXTe1N1kQNtYWk1dtQep9fOOIl4Yol0XZcG3c088TegpOWBjCHzNKQqCFAt7edEUTJBjKZQq0VDwlHXdk8wcLoW8GcVLG8HQ6PpsKTLCzNf64bEWsTNVLG8HQ6Pps09sFepulrZwcUqdviULO(Swr9CsgwPEysL4hM(c0Ua1N1k4cZoj1dtQe)W0Bt7edE(2XTegpOWBjCHzNKQCvCo1siNvHOF7S20MwYnstxYN2XTt0SDClHCwfI(TZAj4cnuH4wYnstxYhXh1h2X0cGhSfOj8BjmEqH3suHqUcTPDIbBh3sy8GcVLOxuNCmjdR8I8FlHCwfI(TZAt7KuVDClHCwfI(TZAj4cnuH4wYnstxYhXh1h2X0coAbAc)wcJhu4TeUWStYlQ3rquVnTto32XTegpOWBjCHzNKrP2siNvHOF7S20o58TJBjmEqH3sSOIKQqCFAjKZQq0VDwBAtlPIHhu4TJBNOz74wc5Ske9BN1sy8GcVLqPdmpOWBjFQJlK(GcVLW4bfExuXWdk8dHDkMDmbjz8Gc3yKfgJhu4ckDG5bfUaNXUtqipx7LDwOJh4blLCETkBG1ZjBu5KOJ0Zcx2NOUkQO6ZAfDKEw4Y(e1v0hgRam1N1k6i9SWL9jQR4YWj7dJvqPwcUqdviULCzNf64zbhbBbP5cXQqKGshsD8SaTlq5fGJa6hMUyIhotgw5KrYlNJefDzK3xWrWwaJhu4ckDG5bfUGGJWVHKd6slqrfxaocOFy6cUWSts9WKkrrxg59fCeSfW4bfUGshyEqHli4i8Bi5GU0cuuXfO8cggI8rupNKHvQhMujiNvHO)c0UaCeq)W0f1ZjzyL6HjvIIUmY7l4iylGXdkCbLoW8GcxqWr43qYbDPfO0cuAbAxG6ZAf1ZjzyL6HjvIFy6lq7cuFwRGlm7KupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0xG2fyGlqVO0YC8xOPyIhotgw5KrYlNJAt7ed2oULqoRcr)2zTeCHgQqClPEozJkNeDKEw4Y(e1vqoRcr)fODb4iG(HPl4cZoj1dtQefDzK3xWrWwaJhu4ckDG5bfUGGJWVHKd6sTegpOWBju6aZdk820oj1Bh3siNvHOF7SwcJhu4TeUWStsvUkoNAjFQJlK(GcVLCgxfNtlazxaAmQVGbDPfmXcEDAbtm3fW(FbM0cY400cMiwWLDnwaoJRCQ3sWfAOcXTeCeq)W0ft8WzYWkNmsE5CKOi(RXc0UaLxG6ZAfCHzNK4mUYjrFySclaElinxiwfIetmx5LHtIZ4kN6lq7cWra9dtxWfMDsQhMujk6YiVVGJGTacoc)gsoOlTaTl4Yol0XZcG3csZfIvHibRlVihDFx5LDwQJNfODbQpRvupNKHvQhMuj(HPVaLAt7KZTDClHCwfI(TZAj4cnuH4wcocOFy6IjE4mzyLtgjVCosue)1ybAxGYlq9zTcUWStsCgx5KOpmwHfaVfKMleRcrIjMR8YWjXzCLt9fODbddr(iQNtYWk1dtQeKZQq0FbAxaocOFy6I65KmSs9WKkrrxg59fCeSfqWr43qYbDPfODb4iG(HPl4cZoj1dtQefDzK3xa8wqAUqSkejMyUYldN8tqSgsBuswFbk1sy8GcVLWfMDsQYvX5uBANC(2XTeYzvi63oRLGl0qfIBj4iG(HPlM4HZKHvozK8Y5irr8xJfODbkVa1N1k4cZojXzCLtI(Wyfwa8wqAUqSkejMyUYldNeNXvo1xG2fO8cmWfmme5JOEojdRupmPsqoRcr)fOOIlahb0pmDr9CsgwPEysLOOlJ8(cG3csZfIvHiXeZvEz4KFcI1qAJswH(cuAbAxaocOFy6cUWSts9WKkrrxg59faVfKMleRcrIjMR8YWj)eeRH0gLK1xGsTegpOWBjCHzNKQCvCo1M2jNZ2XTeYzvi63oRLGl0qfIBjFs9zTII)i2hzxNlfKPFqovSkccnAi6dJvybWwWNuFwRO4pI9r215sbz6hKtfRIGqJgIldNSpmwHfODbkVa1N1k4cZoj1dtQe)W0xGIkUa1N1k4cZoj1dtQefDzK3xWrWwqo(VaLwG2fO8cuFwROEojdRupmPs8dtFbkQ4cuFwROEojdRupmPsu0LrEFbhbBb54)cuQLW4bfElHlm7KuLRIZP20oj10oULqoRcr)2zTeCHgQqCl5hJO4pI9r215sbrrxg59faVfKAxGIkUaLxWNuFwRO4pI9r215sbz6hKtfRIGqJgI(Wyfwa8wa8xG2f8j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwHfC0c(K6ZAff)rSpYUoxkit)GCQyveeA0qCz4K9HXkSaLAjmEqH3s4cZojvH4(0M2jP22XTeYzvi63oRLGl0qfIBjQpRvOxuNCmjdR8I8V4PVaTl4tQpRvmXdNjdRCYi5LZrIN(c0UGpP(SwXepCMmSYjJKxohjk6YiVVGJGTagpOWfCHzNKQqCFeeCe(nKCqxQLW4bfElHlm7KufI7tBANKsAh3siNvHOF7SwcoJrElrZwcXfKgsCgJCjY2suFwRadrCH5(G8CjoJDNGe)W01QS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91QS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)AOKsk1sWfAOcXTKpP(SwXepCMmSYjJKxohjE6lq7cggI8rWfMDss4SqqoRcr)fODbkVa1N1k(epzQr5K4hM(cuuXfW4bLMKKtxe1xaSfO5cuAbAxGYl4tQpRvmXdNjdRCYi5LZrIIUmY7laElGXdkCbxy2j5f17iiQli4i8Bi5GU0cuuXfGJa6hMUqVOo5ysgw5f5Frrxg59fOOIlahPjN9rOGgfI9fOulHXdk8wcxy2j5f17iiQ3M2jAc)2XTeYzvi63oRLGl0qfIBjQpRvGHiUWCFqEUOigplq7cuFwRGGtN9p9L6Xq(GyiXtVLW4bfElHlm7K8I6Dee1Bt7en1SDClHCwfI(TZAjmEqH3s4cZojVOEhbr9wcoJrElrZwcUqdviULO(SwbgI4cZ9b55IIy8SaTlq5fO(Swbxy2jPEysL4PVafvCbQpRvupNKHvQhMujE6lqrfxWNuFwRyIhotgw5KrYlNJefDzK3xa8waJhu4cUWStYlQ3rquxqWr43qYbDPfOuBANOPbBh3siNvHOF7SwcJhu4TeUWStYlQ3rquVLGZyK3s0SLGl0qfIBjQpRvGHiUWCFqEUOigplq7cuFwRadrCH5(G8CrFyScla2cuFwRadrCH5(G8CXLHt2hgRqBANOzQ3oULqoRcr)2zTegpOWBjCHzNKxuVJGOElbNXiVLOzlbxOHke3suFwRadrCH5(G8CrrmEwG2fO(SwbgI4cZ9b55IIUmY7l4iylq5fO8cuFwRadrCH5(G8CrFySclifybmEqHl4cZojVOEhbrDbbhHFdjh0LwGsl4WfKJ)lqP20orZZTDClHCwfI(TZAj4cnuH4wIYlOiBr9mwfIwGIkUadCbdcRaYZxGslq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWc0Ua1N1k4cZoj1dtQe)W0xG2f8j1N1kM4HZKHvozK8Y5iXpm9wcJhu4TeNMmQKdD1P(0M2jAE(2XTeYzvi63oRLGl0qfIBjQpRvWfMDsIZ4kNe9HXkSGJGTG0CHyvismXCLxgojoJRCQ3sy8GcVLWfMDsgLABANO55SDClHCwfI(TZAj4cnuH4wYLDwOJNfCeSfKso)c0Ua1N1k4cZoj1dtQe)W0xG2fO(Swr9CsgwPEysL4hM(c0UGpP(SwXepCMmSYjJKxohj(HP3sy8GcVL0F6u5rAUnTt0m10oULqoRcr)2zTeCHgQqClr9zTI6brYWkNSIOU4PVaTlq9zTcUWStsCgx5KOpmwHfaVfK6TegpOWBjCHzNKQqCFAt7entTTJBjKZQq0VDwlbxOHke3sUSZcD8SGJGTG0CHyvisOYvX5K8Yol1XZc0Ua1N1k4cZoj1dtQe)W0xG2fO(Swr9CsgwPEysL4hM(c0UGpP(SwXepCMmSYjJKxohj(HPVaTlq9zTcUWStsCgx5KOpmwHfaBbQpRvWfMDsIZ4kNexgozFySclq7cWra9dtxqPdmpOWffDzK3BjmEqH3s4cZojv5Q4CQnTt0mL0oULqoRcr)2zTeCHgQqClr9zTcUWSts9WKkXpm9fODbQpRvupNKHvQhMuj(HPVaTl4tQpRvmXdNjdRCYi5LZrIFy6lq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWc0UGHHiFeCHzNKrPkiNvHO)c0UaCeq)W0fCHzNKrPkk6YiVVGJGTGC8FbAxWLDwOJNfCeSfKsG)c0UaCeq)W0fu6aZdkCrrxg59wcJhu4TeUWStsvUkoNAt7edc)2XTeYzvi63oRLGl0qfIBjQpRvWfMDsQhMujE6lq7cuFwRGlm7KupmPsu0LrEFbhbBb54)c0Ua1N1k4cZojXzCLtI(WyfwaSfO(Swbxy2jjoJRCsCz4K9HXkSaTlq5fGJa6hMUGshyEqHlk6YiVVafvCb1ZjBu5KGlm7Ke5wKJgneKZQq0Fbk1sy8GcVLWfMDsQYvX5uBANyqnBh3siNvHOF7SwcUqdviULO(Swr9CsgwPEysL4PVaTlq9zTcUWSts9WKkXpm9fODbQpRvupNKHvQhMujk6YiVVGJGTGC8FbAxG6ZAfCHzNK4mUYjrFyScla2cuFwRGlm7KeNXvojUmCY(WyfwG2fO8cWra9dtxqPdmpOWffDzK3xGIkUG65KnQCsWfMDsIClYrJgcYzvi6VaLAjmEqH3s4cZojv5Q4CQnTtmObBh3siNvHOF7SwcUqdviULO(Swbxy2jPEysL4hM(c0Ua1N1kQNtYWk1dtQe)W0xG2f8j1N1kM4HZKHvozK8Y5iXtFbAxWNuFwRyIhotgw5KrYlNJefDzK3xWrWwqo(VaTlq9zTcUWStsCgx5KOpmwHfaBbQpRvWfMDsIZ4kNexgozFyScTegpOWBjCHzNKQCvCo1M2jgm1Bh3siNvHOF7SwcUqdviULmCLtJiJyOjtOJNfC0cs9ZVaTlq9zTcUWStsCgx5KOpmwHfapylq5fW4bLMKKtxe1xqk4fO5cuAbAxq9CYgvoj4cZojvJRkx)l5JGCwfI(lq7cy8GstsYPlI6laElqZfODbQpRv8jEYuJYjXpm9wcJhu4TeUWStsvUkoNAt7edEUTJBjKZQq0VDwlbxOHke3sgUYPrKrm0Kj0XZcoAbP(5xG2fO(Swbxy2jjoJRCs0hgRWcoAbQpRvWfMDsIZ4kNexgozFySclq7cQNt2OYjbxy2jPACv56FjFeKZQq0FbAxaJhuAssoDruFbWBbAUaTlq9zTIpXtMAuoj(HP3sy8GcVLWfMDssWPdfDu4TPDIbpF74wcJhu4TeUWStsviUpTeYzvi63oRnTtm45SDClHCwfI(TZAj4cnuH4wI6ZAf1ZjzyL6HjvIFy6lq7cuFwRGlm7KupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0BjmEqH3sO0bMhu4TPDIbtnTJBjmEqH3s4cZojv5Q4CQLqoRcr)2zTPnTe(k768TDC7enBh3siNvHOF7SwcJhu4TekDG5bfEl5tDCH0hu4TegpOW7c(k768fgMDmbjz8Gc3yKfgJhu4ckDG5bfUaNXUtqipx7LDwOJh4blLC(wcUqdviULCzNf64zbhbBbP5cXQqKGshsD8SaTlq5fGJa6hMUyIhotgw5KrYlNJefDzK3xWrWwaJhu4ckDG5bfUGGJWVHKd6slqrfxaocOFy6cUWSts9WKkrrxg59fCeSfW4bfUGshyEqHli4i8Bi5GU0cuuXfO8cggI8rupNKHvQhMujiNvHO)c0UaCeq)W0f1ZjzyL6HjvIIUmY7l4iylGXdkCbLoW8GcxqWr43qYbDPfO0cuAbAxG6ZAf1ZjzyL6HjvIFy6lq7cuFwRGlm7KupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0Bt7ed2oULqoRcr)2zTeCHgQqClbhb0pmDbxy2jPEysLOOlJ8(cGTa4VaTlq5fO(Swr9CsgwPEysL4hM(c0UaLxaocOFy6IjE4mzyLtgjVCosu0LrEFbWBbP5cXQqKG1Lxgo5NGynK2OKtm3fOOIlahb0pmDXepCMmSYjJKxohjk6YiVVayla(lqPfOulHXdk8wYN4jtnkNAt7KuVDClHCwfI(TZAj4cnuH4wcocOFy6cUWSts9WKkrrxg59faBbWFbAxGYlq9zTI65KmSs9WKkXpm9fODbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3csZfIvHibRlVmCYpbXAiTrjNyUlqrfxaocOFy6IjE4mzyLtgjVCosu0LrEFbWwa8xGslqPwcJhu4TKlQQO6YWkNOUKpTPDY52oULW4bfElP4pI9r215sHwc5Ske9BN1M2jNVDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK6HjvIFy6lq7cWra9dtxWfMDsQhMujM6rYIUmY7laElGXdkCrpdzhKNl1dtQe4FTaTlq9zTI65KmSs9WKkXpm9fODb4iG(HPlQNtYWk1dtQet9izrxg59faVfW4bfUONHSdYZL6Hjvc8VwG2f8j1N1kM4HZKHvozK8Y5iXpm9wcJhu4TKEgYoipxQhMu1M2jNZ2XTeYzvi63oRLGl0qfIBjQpRvupNKHvQhMuj(HPVaTlahb0pmDbxy2jPEysLOOlJ8ElHXdk8ws9CsgwPEysvBANKAAh3siNvHOF7SwcUqdviULO8cWra9dtxWfMDsQhMujk6YiVVayla(lq7cuFwROEojdRupmPs8dtFbkTafvCb6fLwMJ)cnf1ZjzyL6HjvTegpOWBjt8WzYWkNmsE5CuBANKABh3siNvHOF7SwcUqdviULGJa6hMUGlm7KupmPsu0LrEFbhTGZd)fODbQpRvupNKHvQhMuj(HPVaTlG6DYXKinQJcxgwPovwcpOWfKZQq0VLW4bfElzIhotgw5KrYlNJAt7Kus74wc5Ske9BN1sWfAOcXTe1N1kQNtYWk1dtQe)W0xG2fGJa6hMUyIhotgw5KrYlNJefDzK3xa8wqAUqSkejyD5LHt(jiwdPnk5eZTLW4bfElHlm7KupmPQnTt0e(TJBjKZQq0VDwlbxOHke3suFwRGlm7KupmPs80xG2fO(Swbxy2jPEysLOOlJ8(coc2cy8GcxWfMDsEr9ocI6ccoc)gsoOlTaTlq9zTcUWStsCgx5KOpmwHfaBbQpRvWfMDsIZ4kNexgozFyScTegpOWBjCHzNKQCvCo1M2jAQz74wc5Ske9BN1sWfAOcXTe1N1k4cZojXzCLtI(WyfwWrlq9zTcUWStsCgx5K4YWj7dJvybAxG6ZAf1ZjzyL6HjvIFy6lq7cuFwRGlm7KupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0BjmEqH3s4cZojJsTnTt00GTJBjKZQq0VDwlbxOHke3suFwROEojdRupmPs8dtFbAxG6ZAfCHzNK6HjvIFy6lq7c(K6ZAft8WzYWkNmsE5CK4hM(c0Ua1N1k4cZojXzCLtI(WyfwaSfO(Swbxy2jjoJRCsCz4K9HXk0sy8GcVLWfMDsQYvX5uBANOzQ3oULqoRcr)2zTeCgJ8wIMTeIlinK4mg5sKTLO(SwbgI4cZ9b55sCg7obj(HPRvz1N1k4cZoj1dtQepDfvu9zTI65KmSs9WKkXtxrfXra9dtxqPdmpOWffXFnuQLGl0qfIBjQpRvGHiUWCFqEUOigpTegpOWBjCHzNKxuVJGOEBANO552oULqoRcr)2zTeCgJ8wIMTeIlinK4mg5sKTLO(SwbgI4cZ9b55sCg7obj(HPRvz1N1k4cZoj1dtQepDfvu9zTI65KmSs9WKkXtxrfXra9dtxqPdmpOWffXFnuQLGl0qfIBjg4c4dcQqdj4cZoj1F3lbH8Cb5Ske9xGIkUa1N1kWqexyUpipxIZy3jiXpm9wcJhu4TeUWStYlQ3rquVnTt088TJBjKZQq0VDwlbxOHke3suFwROEojdRupmPs8dtFbAxG6ZAfCHzNK6HjvIFy6lq7c(K6ZAft8WzYWkNmsE5CK4hMElHXdk8wcLoW8GcVnTt08C2oULqoRcr)2zTeCHgQqClr9zTcUWStsCgx5KOpmwHfC0cuFwRGlm7KeNXvojUmCY(WyfAjmEqH3s4cZojJsTnTt0m10oULW4bfElHlm7KuLRIZPwc5Ske9BN1M2jAMABh3sy8GcVLWfMDsQcX9PLqoRcr)2zTPnTKpz5h00oUDIMTJBjmEqH3sWXZhQ66eeulHCwfI(TZAt7ed2oULqoRcr)2zTKqVL0PPLW4bfEljnxiwfIAjPzOh1s0SLGl0qfIBjP5cXQqKiJttYqNC6Vayla(lq7c0lkTmh)fAkO0bMhu4lq7cmWfO8cQNt2OYjrhPNfUSprDfKZQq0FbkQ4cQNt2OYjXqx9OyiPjx6cYzvi6VaLAjP5s68LAjzCAsg6Kt)20oj1Bh3siNvHOF7SwsO3s600sy8GcVLKMleRcrTK0m0JAjA2sWfAOcXTK0CHyvisKXPjzOto9xaSfa)fODbQpRvWfMDsQhMuj(HPVaTlahb0pmDbxy2jPEysLOOlJ8(c0UaLxq9CYgvoj6i9SWL9jQRGCwfI(lqrfxq9CYgvojg6Qhfdjn5sxqoRcr)fOuljnxsNVuljJttYqNC63M2jNB74wc5Ske9BN1sc9wsNMwcJhu4TK0CHyviQLKMHEulrZwcUqdviULO(Swbxy2jjoJRCs0hgRWcGTa1N1k4cZojXzCLtIldNSpmwHfODbg4cuFwROEqKmSYjRiQlE6lq7cSO8Srw0LrEFbhbBbkVaLxWLDEbNUagpOWfCHzNKQqCFe4OplqPfKcSagpOWfCHzNKQqCFeeCe(nKCqxAbk1ssZL05l1sSiNHKQVYBt7KZ3oULqoRcr)2zTeCHgQqClr5fmme5JGCiuE2qo9fKZQq0FbAxWLDwOJNfCeSfKAH)c0UGl7SqhplaEWwW588lqPfOOIlq5fyGlyyiYhb5qO8SHC6liNvHO)c0UGl7Sqhpl4iyli1E(fOulHXdk8wYLDwMt320o5C2oULqoRcr)2zTeCHgQqClr9zTcUWSts9WKkXtVLW4bfElrpgu4TPDsQPDClHCwfI(TZAj4cnuH4ws9CYgvojg6Qhfdjn5sxqoRcr)fODbQpRvqWLXV(Gcx80xG2fO8cWra9dtxWfMDsQhMujkI)ASafvCbwuE2il6YiVVGJGTGZf(lqPwcJhu4TKbDjPjx6TPDsQTDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK6HjvIFy6lq7cuFwROEojdRupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0BjmEqH3sGq5ztxAaI3p)s(0M2jPK2XTeYzvi63oRLGl0qfIBjQpRvWfMDsQhMuj(HPVaTlq9zTI65KmSs9WKkXpm9fODbFs9zTIjE4mzyLtgjVCos8dtVLW4bfElrLZLHvofcRqVnTt0e(TJBjKZQq0VDwlbxOHke3suFwRGlm7KupmPs80BjmEqH3suPQtLcipVnTt0uZ2XTeYzvi63oRLGl0qfIBjQpRvWfMDsQhMujE6TegpOWBjQqr8L2xPrBANOPbBh3siNvHOF7SwcUqdviULO(Swbxy2jPEysL4P3sy8GcVLyrfPcfXVnTt0m1Bh3siNvHOF7SwcUqdviULO(Swbxy2jPEysL4P3sy8GcVLWoM6tXqsmdb1M2jAEUTJBjKZQq0VDwlbxOHke3suFwRGlm7KupmPs80BjmEqH3sEDsIg62Bt7enpF74wc5Ske9BN1sy8GcVLKdXFepr1LQ8pNAj4cnuH4wI6ZAfCHzNK6HjvIN(cuuXfGJa6hMUGlm7KupmPsu0LrEFbWd2co)5xG2f8j1N1kM4HZKHvozK8Y5iXtVLqwlHhPZxQLKdXFepr1LQ8pNAt7enpNTJBjKZQq0VDwlHXdk8wcD11Oigsg13zhtTeCHgQqClbhb0pmDbxy2jPEysLOOlJ8(coc2cmi8BjoFPwcD11Oigsg13zhtTPDIMPM2XTeYzvi63oRLW4bfEl5xe)TOIKPPENGAj4cnuH4wcocOFy6cUWSts9WKkrrxg59fapylWGWFbkQ4cmWfKMleRcrcwxgU81PfaBbAUafvCbkVGbDPfaBbWFbAxqAUqSkejSOEgYZLHo5uTaylqZfODb1ZjBu5KOJ0Zcx2NOUcYzvi6VaLAjoFPwYVi(Brfjtt9ob1M2jAMABh3siNvHOF7SwcJhu4TKE8GKOChnu1sWfAOcXTeCeq)W0fCHzNK6HjvIIUmY7laEWwqQd)fOOIlWaxqAUqSkejyDz4YxNwaSfOzlX5l1s6XdsIYD0qvBANOzkPDClHCwfI(TZAjmEqH3sYH0qptgwj37OlcIhu4TeCHgQqClbhb0pmDbxy2jPEysLOOlJ8(cGhSfyq4VafvCbg4csZfIvHibRldx(60cGTanxGIkUaLxWGU0cGTa4VaTlinxiwfIewupd55YqNCQwaSfO5c0UG65KnQCs0r6zHl7tuxb5Ske9xGsTeNVuljhsd9mzyLCVJUiiEqH3M2jge(TJBjKZQq0VDwlHXdk8wYLXSArYEgrJ8(6iClbxOHke3sWra9dtxWfMDsQhMujk6YiVVGJGTGZVaTlq5fyGlinxiwfIewupd55YqNCQwaSfO5cuuXfmOlTa4TGuh(lqPwIZxQLCzmRwKSNr0iVVoc3M2jguZ2XTeYzvi63oRLW4bfEl5YywTizpJOrEFDeULGl0qfIBj4iG(HPl4cZoj1dtQefDzK3xWrWwW5xG2fKMleRcrclQNH8CzOtovla2c0CbAxG6ZAf1ZjzyL6HjvIN(c0Ua1N1kQNtYWk1dtQefDzK3xWrWwGYlqt4VGuWl48lifyb1ZjBu5KOJ0Zcx2NOUcYzvi6VaLwG2fmOlTGJwqQd)wIZxQLCzmRwKSNr0iVVoc3M2jg0GTJBjKZQq0VDwlbxOHke3sy8GstsYPlI6laElWGTK(ui80orZwcJhu4Temdbjz8GcxcH6tlbc1hPZxQLWb1M2jgm1Bh3siNvHOF7SwcUqdviULGJ0KZ(iuqJcX(c0UG65KnQCsWfMDsIClYrJgcYzvi6VaTlyyiYhr9CsgwPEysLGCwfI(lq7cmWfGd))qJGlm7KuVIpkxdb5Ske9Bj9Pq4PDIMTegpOWBjygcsY4bfUec1NwceQpsNVuljJRB4A0M2jg8CBh3siNvHOF7SwYN64cPpOWBjhNrlWI6zipFbHo5uTavkh59fyIMSfCoIdEbS)xGf1ZO(cSrTGumfxGEf4(cMybVoTG)RqE(cooMu4PP6b3sy8GcVLGziijJhu4siuFAj9Pq4PDIMTeCHgQqCljnxiwfIezCAsg6Kt)faBbWFbAxqAUqSkejSOEgYZLHo5u1sGq9r68LAjwupd55YqNCQAt7edE(2XTeYzvi63oRLGl0qfIBjP5cXQqKiJttYqNC6Vayla(TK(ui80orZwcJhu4Temdbjz8GcxcH6tlbc1hPZxQLe6KtvBANyWZz74wc5Ske9BN1sWfAOcXTKondYZ7c(k768DbWwGMTK(ui80orZwcJhu4Temdbjz8GcxcH6tlbc1hPZxQLWxzxNVTPDIbtnTJBjKZQq0VDwlHXdk8wcMHGKmEqHlHq9PLaH6J05l1sWra9dtV3M2jgm12oULqoRcr)2zTeCHgQqCljnxiwfIewKZqs1x5la2cGFlPpfcpTt0SLW4bfElbZqqsgpOWLqO(0sGq9r68LAjvm8GcVnTtmykPDClHCwfI(TZAj4cnuH4wsAUqSkejSiNHKQVYxaSfOzlPpfcpTt0SLW4bfElbZqqsgpOWLqO(0sGq9r68LAjwKZqs1x5TPDsQd)2XTeYzvi63oRLW4bfElbZqqsgpOWLqO(0sGq9r68LAj3inDjFAtBAj6fHJRkpTJBNOz74wcJhu4TeUWStsKpeeeHNwc5Ske9BN1M2jgSDClHXdk8ws)DVHl5cZojT8fbH4QLqoRcr)2zTPDsQ3oULW4bfElbhUbiEfjVSZYC62siNvHOF7S20o5CBh3siNvHOF7SwsO3skQttlHXdk8wsAUqSke1ssZL05l1s4RSRZ3wYNS8dAAjDAgKN3f8v215BBANC(2XTeYzvi63oRLe6TKI600sy8GcVLKMleRcrTK0CjD(sTekDi1Xtl5tw(bnTenpFBANCoBh3siNvHOF7SwsO3s600sy8GcVLKMleRcrTK0CjD(sTe9I0FqqskD0sWfAOcXTeLxq9CYgvoj6i9SWL9jQRGCwfI(lq7cy8GstsYPlI6laElqZfC4cuEbAUGuGfO8cmWfGJ0KZ(iCcxbuu)fO0cuAbk1ssZqpssqDQLa)wsAg6rTenBt7Kut74wc5Ske9BN1sc9wsNMwcJhu4TK0CHyviQLKMlPZxQLKXPjzOto9Bj4cnuH4wIYlGXdknjjNUiQVa4TadUafvCbP5cXQqKqVi9heKKshla2c0CbkQ4csZfIvHibFLDD(UaylqZfOuljnd9ijb1Pwc8BjPzOh1s0SnTtsTTJBjKZQq0VDwlj0BjDAAjmEqH3ssZfIvHOwsAg6rTe43ssZL05l1sSiNHKQVYBt7Kus74wc5Ske9BN1sc9wsrDAAjmEqH3ssZfIvHOwsAUKoFPws1Lxgo5NGynK2OKtm3wYNS8dAAjNVnTt0e(TJBjKZQq0VDwlj0Bjf1PPLW4bfEljnxiwfIAjP5s68LAjvxEz4KFcI1qAJswHEl5tw(bnTKZ3M2jAQz74wc5Ske9BN1sc9wsrDAAjmEqH3ssZfIvHOwsAUKoFPws1Lxgo5NGynK2OKSEl5tw(bnTedc)20ortd2oULqoRcr)2zTKqVLuuNMwcJhu4TK0CHyviQLKMlPZxQLW6YldN8tqSgsBuYjMBl5tw(bnTenHFBANOzQ3oULqoRcr)2zTKqVLuuNMwcJhu4TK0CHyviQLKMlPZxQLuHU8YWj)eeRH0gLCI52s(KLFqtlXGWVnTt08CBh3siNvHOF7SwsO3s600sy8GcVLKMleRcrTK0CjD(sTKjMR8YWj)eeRH0gLK1Bj4cnuH4wIYlahPjN9r4O8SrAzAbkQ4cuEb4W)p0i4cZoj1R4JY1qqoRcr)fODbmEqPjj50fr9fC0cs9fO0cuQLKMHEKKG6ul58TK0m0JAjAE(20orZZ3oULqoRcr)2zTKqVLuuNMwcJhu4TK0CHyviQLKMlPZxQLmXCLxgo5NGynK2OKvO3s(KLFqtlXGWVnTt08C2oULqoRcr)2zTKqVL0PPLW4bfEljnxiwfIAjPzOh1soNWFbPGxGYl4Y9HknKPzOhTGuGfOj8H)cuQLGl0qfIBj4in5SpchLNnsltTK0CjD(sTevUkoNKx2zPoEAt7entnTJBjKZQq0VDwlj0BjDAAjmEqH3ssZfIvHOwsAg6rTKuY5xqk4fO8cUCFOsdzAg6rlifybAcF4VaLAj4cnuH4wcosto7Jqbnke7TK0CjD(sTevUkoNKx2zPoEAt7entTTJBjKZQq0VDwlj0BjDAAjmEqH3ssZfIvHOwsAg6rTKul8xqk4fO8cUCFOsdzAg6rlifybAcF4VaLAj4cnuH4wsAUqSkeju5Q4CsEzNL64zbWwa8BjP5s68LAjQCvCojVSZsD80M2jAMsAh3siNvHOF7SwsO3skQttlHXdk8wsAUqSke1ssZL05l1syD5f5O77kVSZsD80s(KLFqtlrZZ3M2jge(TJBjKZQq0VDwlj0Bjf1PPLW4bfEljnxiwfIAjP5s68LAjtmx5LHtIZ4kN6TKpz5h00smyBANyqnBh3siNvHOF7SwsO3skQttlHXdk8wsAUqSke1ssZL05l1s4GKtmx5LHtIZ4kN6TKpz5h00smyBANyqd2oULqoRcr)2zTKqVL0PPLW4bfEljnxiwfIAjPzOh1s0CbPalq5fqh0hsxN(c6QRrrmKmQVZoMwGIkUaLxWWqKpI65KmSs9WKkb5Ske9xG2fO8cggI8rWfMDss4SqqoRcr)fOOIlWaxaosto7Jqbnke7lqPfODbkVadCb4in5SpcNWvaf1FbkQ4cy8GstsYPlI6la2c0CbkQ4cQNt2OYjrhPNfUSprDfKZQq0FbkTaLwGsTK0CjD(sTelQNH8CzOtovTPDIbt92XTeYzvi63oRLe6TKonTegpOWBjP5cXQquljnd9OwcDqFiDD6lUmMvls2ZiAK3xhHxGIkUa6G(q660xKdXFepr1LQ8pNwGIkUa6G(q660xKdXFepr1Lx6ZqqOWxGIkUa6G(q660x85sHBeU8tyfK6VPOoMCmTafvCb0b9H01PVa5DC9gwfIKh0h7Z7k)uAeMwGIkUa6G(q660x0JheendYZL1tvJfOOIlGoOpKUo9f9NRcfXxYxAY0OplqrfxaDqFiDD6lmzfiNQU0wH)xGIkUa6G(q660xyH4ljdRuLNbIAjP5s68LAjSUmC5RtTPDIbp32XTeYzvi63oRLe6TKI600sy8GcVLKMleRcrTK0CjD(sTeoi5eZvEz4K4mUYPEl5tw(bnTed2M2jg88TJBjKZQq0VDwlj0Bjf1PPLW4bfEljnxiwfIAjP5s68LAju6qQJNwYNS8dAAjAE(20oXGNZ2XTegpOWBjxuvrjrxoNAjKZQq0VDwBANyWut74wc5Ske9BN1sWfAOcXTedCbP5cXQqKqVi9heKKshla2c0CbAxq9CYgvoj(OogPdHCU0qIJ7L9VGCwfI(TegpOWBj2k6JAanTPDIbtTTJBjKZQq0VDwlbxOHke3smWfKMleRcrc9I0FqqskDSaylqZfODbg4cQNt2OYjXh1XiDiKZLgsCCVS)fKZQq0VLW4bfElHlm7KufI7tBANyWus74wc5Ske9BN1sWfAOcXTK0CHyvisOxK(dcssPJfaBbA2sy8GcVLqPdmpOWBtBAj4iG(HP3Bh3orZ2XTeYzvi63oRLW4bfElXwrFKEKMBjFQJlK(GcVLCWfkk0GoiOf86ipFb5fQdPXcqyegIwGjAYwaRlwGbuNwaAwGjAYwWeZDbXKrLjQtIwcUqdviULupNSrLtI8c1H0qIWimejiNvHO)c0UaCeq)W0fCHzNK6HjvIIUmY7laEli1H)c0UaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cGTa4VaTlq5fO(Swbxy2jjoJRCs0hgRWcoc2csZfIvHiXeZvEz4K4mUYP(c0UaLxGYlyyiYhr9CsgwPEysLGCwfI(lq7cWra9dtxupNKHvQhMujk6YiVVGJGTGC8FbAxaocOFy6cUWSts9WKkrrxg59faVfKMleRcrIjMR8YWj)eeRH0gLK1xGslqrfxGYlWaxWWqKpI65KmSs9WKkb5Ske9xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbP5cXQqKyI5kVmCYpbXAiTrjz9fO0cuuXfGJa6hMUGlm7KupmPsu0LrEFbhbBb54)cuAbk1M2jgSDClHCwfI(TZAj4cnuH4ws9CYgvojYluhsdjcJWqKGCwfI(lq7cWra9dtxWfMDsQhMujk6YiVVayla(lq7cuEbg4cggI8rqoekpBiN(cYzvi6VafvCbkVGHHiFeKdHYZgYPVGCwfI(lq7cUSZcD8Sa4bBbPg4VaLwGslq7cuEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3c0e(lq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWcuAbkQ4cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faBbWFbAxG6ZAfCHzNK4mUYjrFyScla2cG)cuAbkTaTlq9zTI65KmSs9WKkXpm9fODbx2zHoEwa8GTG0CHyvisW6YlYr33vEzNL64PLW4bfElXwrFKEKMBt7KuVDClHCwfI(TZAj4cnuH4ws9CYgvoj(OogPdHCU0qIJ7L9VGCwfI(lq7cWra9dtxO(Sw5h1XiDiKZLgsCCVS)ffXFnwG2fO(SwXh1XiDiKZLgsCCVS)L2k6J4hM(c0UaLxG6ZAfCHzNK6HjvIFy6lq7cuFwROEojdRupmPs8dtFbAxWNuFwRyIhotgw5KrYlNJe)W0xGslq7cWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0UaLxG6ZAfCHzNK4mUYjrFyScl4iylinxiwfIetmx5LHtIZ4kN6lq7cuEbkVGHHiFe1ZjzyL6HjvcYzvi6VaTlahb0pmDr9CsgwPEysLOOlJ8(coc2cYX)fODb4iG(HPl4cZoj1dtQefDzK3xa8wqAUqSkejMyUYldN8tqSgsBuswFbkTafvCbkVadCbddr(iQNtYWk1dtQeKZQq0FbAxaocOFy6cUWSts9WKkrrxg59faVfKMleRcrIjMR8YWj)eeRH0gLK1xGslqrfxaocOFy6cUWSts9WKkrrxg59fCeSfKJ)lqPfOulHXdk8wITI(OgqtBANCUTJBjKZQq0VDwlbxOHke3sQNt2OYjXh1XiDiKZLgsCCVS)fKZQq0FbAxaocOFy6c1N1k)OogPdHCU0qIJ7L9VOi(RXc0Ua1N1k(OogPdHCU0qIJ7L9V0Iks8dtFbAxGErPL54VqtHTI(OgqtlHXdk8wIfvKufI7tBANC(2XTeYzvi63oRLW4bfEl5IQkQUmSYjQl5tl5tDCH0hu4TKKbbbTaZOua55li8fe6d6Ioi4bfEFb2OwWKrlWjZfKcJJnEbQVzb4xvKpqASGxh55lanli8fG)la1xGkndvlyYyFbzb0h55lWg1cy9fe1cEDKNVa0SGoekpBG0ybQKnkAbSElbxOHke3s0NQnTtoNTJBjKZQq0VDwlHXdk8wYfvvuDzyLtuxYNwYN64cPpOWBjPkKjRrFbVoTGlQQO6lWenzlG1flWaWUGjM7cq9fue)1ybCFbMeeKXl4YkqlO)kAbtSam3NfGMfOs2OOfmXCfTeCHgQqClXaxG(ulq7cWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0Ua1N1k4cZojXzCLtI(WyfwWrWwqAUqSkejMyUYldNeNXvo1xG2fGJa6hMUGlm7KupmPsu0LrEFbhbBb54FBANKAAh3siNvHOF7SwcUqdviULyGlqFQfODb4iG(HPl4cZoj1dtQefDzK3xaSfa)fODbkVadCbddr(iihcLNnKtFb5Ske9xGIkUaLxWWqKpcYHq5zd50xqoRcr)fODbx2zHoEwa8GTGud8xGslqPfODbkVaLxaocOFy6IjE4mzyLtgjVCosu0LrEFbWBbP5cXQqKG1Lxgo5NGynK2OKtm3fODbQpRvWfMDsIZ4kNe9HXkSaylq9zTcUWStsCgx5K4YWj7dJvybkTafvCbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cGTa4VaTlq9zTcUWStsCgx5KOpmwHfaBbWFbkTaLwG2fO(Swr9CsgwPEysL4hM(c0UGl7SqhplaEWwqAUqSkejyD5f5O77kVSZsD80sy8GcVLCrvfvxgw5e1L8PnTtsTTJBjKZQq0VDwlHXdk8wYN4jtnkNAjFQJlK(GcVLKQqMSg9f860c(epzQr50cmrt2cyDXcmaSlyI5UauFbfXFnwa3xGjbbz8cUSc0c6VIwWelaZ9zbOzbQKnkAbtmxrlbxOHke3sWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0Ua1N1k4cZojXzCLtI(WyfwWrWwqAUqSkejMyUYldNeNXvo1xG2fGJa6hMUGlm7KupmPsu0LrEFbhbBb54FBANKsAh3siNvHOF7SwcUqdviULGJa6hMUGlm7KupmPsu0LrEFbWwa8xG2fO8cmWfmme5JGCiuE2qo9fKZQq0FbkQ4cuEbddr(iihcLNnKtFb5Ske9xG2fCzNf64zbWd2csnWFbkTaLwG2fO8cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faVfOj8xG2fO(Swbxy2jjoJRCs0hgRWcGTa1N1k4cZojXzCLtIldNSpmwHfO0cuuXfO8cWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0Ua1N1k4cZojXzCLtI(WyfwaSfa)fO0cuAbAxG6ZAf1ZjzyL6HjvIFy6lq7cUSZcD8Sa4bBbP5cXQqKG1LxKJUVR8Yol1XtlHXdk8wYN4jtnkNAt7enHF74wc5Ske9BN1sy8GcVLu8hX(i76CPql5tDCH0hu4TedOoTGUoxkSaKDbtm3fW(FbS(c4Iwq4la)xa7)fygUrZcuPf80xGnQfafEovlyYyFbtgTGld3c(eeRHXl4YkG88f0FfTatAbzCAAb8SaiI7ZcgZybCHzNwaoJRCQVa2)lyY4zbtm3fyYD3OzbgG41Nf860x0sWfAOcXTeCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3csZfIvHir1Lxgo5NGynK2OKtm3fODb4iG(HPl4cZoj1dtQefDzK3xa8wqAUqSkejQU8YWj)eeRH0gLK1xG2fO8cggI8rupNKHvQhMujiNvHO)c0UaLxaocOFy6I65KmSs9WKkrrxg59fC0ci4i8Bi5GU0cuuXfGJa6hMUOEojdRupmPsu0LrEFbWBbP5cXQqKO6YldN8tqSgsBuYk0xGslqrfxGbUGHHiFe1ZjzyL6HjvcYzvi6VaLwG2fO(Swbxy2jjoJRCs0hgRWcG3cm4c0UGpP(SwXepCMmSYjJKxohj(HPVaTlq9zTI65KmSs9WKkXpm9fODbQpRvWfMDsQhMuj(HP3M2jAQz74wc5Ske9BN1sy8GcVLu8hX(i76CPql5tDCH0hu4TedOoTGUoxkSat0KTawFbMzKVa9O3rQqKybga2fmXCxaQVGI4VglG7lWKGGmEbxwbAb9xrlyIfG5(Sa0SavYgfTGjMROLGl0qfIBj4iG(HPlM4HZKHvozK8Y5irrxg59fC0ci4i8Bi5GU0c0Ua1N1k4cZojXzCLtI(WyfwWrWwqAUqSkejMyUYldNeNXvo1xG2fGJa6hMUGlm7KupmPsu0LrEFbhTaLxabhHFdjh0LwWHlGXdkCXepCMmSYjJKxohji4i8Bi5GU0cuQnTt00GTJBjKZQq0VDwlbxOHke3sWra9dtxWfMDsQhMujk6YiVVGJwabhHFdjh0LwG2fO8cuEbg4cggI8rqoekpBiN(cYzvi6VafvCbkVGHHiFeKdHYZgYPVGCwfI(lq7cUSZcD8Sa4bBbPg4VaLwGslq7cuEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3csZfIvHibRlVmCYpbXAiTrjNyUlq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWcuAbkQ4cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faBbWFbAxG6ZAfCHzNK4mUYjrFyScla2cG)cuAbkTaTlq9zTI65KmSs9WKkXpm9fODbx2zHoEwa8GTG0CHyvisW6YlYr33vEzNL64zbk1sy8GcVLu8hX(i76CPqBANOzQ3oULqoRcr)2zTegpOWBjt8WzYWkNmsE5Cul5tDCH0hu4TedOoTGjM7cmrt2cy9fGSlang1xGjAYq(cMmAbxgUf8jiwdXcmaSlWJX4f860cmrt2cQqFbi7cMmAbddr(SauFbdRa5gVa2)lang1xGjAYq(cMmAbxgUf8jiwdrlbxOHke3suFwRGlm7KeNXvoj6dJvybhbBbP5cXQqKyI5kVmCsCgx5uFbAxaocOFy6cUWSts9WKkrrxg59fCeSfqWr43qYbDPfODbx2zHoEwa8wqAUqSkejyD5f5O77kVSZsD8SaTlq9zTI65KmSs9WKkXpm920orZZTDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK4mUYjrFyScl4iylinxiwfIetmx5LHtIZ4kN6lq7cggI8rupNKHvQhMujiNvHO)c0UaCeq)W0f1ZjzyL6HjvIIUmY7l4iylGGJWVHKd6slq7cWra9dtxWfMDsQhMujk6YiVVa4TG0CHyvismXCLxgo5NGynK2OKS(c0UaCeq)W0fCHzNK6HjvIIUmY7laElqtd2sy8GcVLmXdNjdRCYi5LZrTPDIMNVDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK4mUYjrFyScl4iylinxiwfIetmx5LHtIZ4kN6lq7cuEbg4cggI8rupNKHvQhMujiNvHO)cuuXfGJa6hMUOEojdRupmPsu0LrEFbWBbP5cXQqKyI5kVmCYpbXAiTrjRqFbkTaTlahb0pmDbxy2jPEysLOOlJ8(cG3csZfIvHiXeZvEz4KFcI1qAJsY6TegpOWBjt8WzYWkNmsE5CuBANO55SDClHCwfI(TZAjmEqH3s4cZoj1dtQAjFQJlK(GcVLya1PfW6lazxWeZDbO(ccFb4)cy)VaZWnAwGkTGN(cSrTaOWZPAbtg7lyYOfCz4wWNGynmEbxwbKNVG(ROfmz8SatAbzCAAbKhV8SfCzNxa7)fmz8SGjJkAbO(c8ywadve)1yb8cQNtliSlqpmPAb)W0fTeCHgQqClbhb0pmDXepCMmSYjJKxohjk6YiVVa4TG0CHyvisW6YldN8tqSgsBuYjM7c0Ua1N1k4cZojXzCLtI(WyfwaSfO(Swbxy2jjoJRCsCz4K9HXkSaTlq9zTI65KmSs9WKkXpm9fODbx2zHoEwa8GTG0CHyvisW6YlYr33vEzNL64PnTt0m10oULqoRcr)2zTegpOWBj1ZjzyL6HjvTKp1XfsFqH3smG60cQqFbi7cMyUla1xq4la)xa7)fygUrZcuPf80xGnQfafEovlyYyFbtgTGld3c(eeRHXl4YkG88f0FfTGjJkAbOUB0SagQi(RXc4fupNwWpm9fW(FbtgplG1xGz4gnlqLWXLwaNMrqSkeTG)RqE(cQNtIwcUqdviULO(Swbxy2jPEysL4hM(c0UaLxaocOFy6IjE4mzyLtgjVCosu0LrEFbWBbP5cXQqKOcD5LHt(jiwdPnk5eZDbkQ4cWra9dtxWfMDsQhMujk6YiVVGJGTG0CHyvismXCLxgo5NGynK2OKS(cuAbAxG6ZAfCHzNK4mUYjrFyScla2cuFwRGlm7KeNXvojUmCY(WyfwG2fGJa6hMUGlm7KupmPsu0LrEFbWBbAAW20orZuB74wc5Ske9BN1sWfAOcXTe1N1k4cZoj1dtQe)W0xG2fGJa6hMUGlm7KupmPsm1JKfDzK3xa8waJhu4IEgYoipxQhMujW)AbAxG6ZAf1ZjzyL6HjvIFy6lq7cWra9dtxupNKHvQhMujM6rYIUmY7laElGXdkCrpdzhKNl1dtQe4FTaTl4tQpRvmXdNjdRCYi5LZrIFy6TegpOWBj9mKDqEUupmPQnTt0mL0oULqoRcr)2zTegpOWBj6f1jhtYWkVi)3s(uhxi9bfElXaQtlqpUlyIf0pOpIoiOfW(ci4MIxaRUaKVGjJwGtWnlahb0pm9fyI8FyA8cEoe17lqbnke7lyYiFbHdPXc(Vc55lGlm70c0dtQwW)rlyIfKfMl4YoVGSNNxASGI)i2Nf015sHfG6TeCHgQqClzyiYhr9CsgwPEysLGCwfI(lq7cuFwRGlm7KupmPs80xG2fO(Swr9CsgwPEysLOOlJ8(coAb54V4YW1M2jge(TJBjKZQq0VDwlbxOHke3s(K6ZAft8WzYWkNmsE5CK4PVaTl4tQpRvmXdNjdRCYi5LZrIIUmY7l4OfW4bfUGlm7K8I6Dee1feCe(nKCqxAbAxGbUaCKMC2hHcAui2BjmEqH3s0lQtoMKHvEr(VnTtmOMTJBjKZQq0VDwlbxOHke3suFwROEojdRupmPs80xG2fO(Swr9CsgwPEysLOOlJ8(coAb54V4YWTaTlahb0pmDbLoW8Gcxue)1ybAxaocOFy6IjE4mzyLtgjVCosu0LrEFbAxGbUaCKMC2hHcAui2BjmEqH3s0lQtoMKHvEr(VnTPLWb1oUDIMTJBjKZQq0VDwlbxOHke3sQNt2OYjXh1XiDiKZLgsCCVS)fKZQq0FbAxaocOFy6c1N1k)OogPdHCU0qIJ7L9VOi(RXc0Ua1N1k(OogPdHCU0qIJ7L9V0wrFe)W0xG2fO8cuFwRGlm7KupmPs8dtFbAxG6ZAf1ZjzyL6HjvIFy6lq7c(K6ZAft8WzYWkNmsE5CK4hM(cuAbAxaocOFy6IjE4mzyLtgjVCosu0LrEFbWwa8xG2fO8cuFwRGlm7KeNXvoj6dJvybhbBbP5cXQqKGdsoXCLxgojoJRCQVaTlq5fO8cggI8rupNKHvQhMujiNvHO)c0UaCeq)W0f1ZjzyL6HjvIIUmY7l4iylih)xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbP5cXQqKyI5kVmCYpbXAiTrjz9fO0cuuXfO8cmWfmme5JOEojdRupmPsqoRcr)fODb4iG(HPl4cZoj1dtQefDzK3xa8wqAUqSkejMyUYldN8tqSgsBuswFbkTafvCb4iG(HPl4cZoj1dtQefDzK3xWrWwqo(VaLwGsTegpOWBj2k6JAanTPDIbBh3siNvHOF7SwcUqdviULO8cQNt2OYjXh1XiDiKZLgsCCVS)fKZQq0FbAxaocOFy6c1N1k)OogPdHCU0qIJ7L9VOi(RXc0Ua1N1k(OogPdHCU0qIJ7L9V0Iks8dtFbAxGErPL54VqtHTI(OgqZcuAbkQ4cuEb1ZjBu5K4J6yKoeY5sdjoUx2)cYzvi6VaTlyqxAbhTanxGsTegpOWBjwursviUpTPDsQ3oULqoRcr)2zTeCHgQqClPEozJkNe5fQdPHeHryisqoRcr)fODb4iG(HPl4cZoj1dtQefDzK3xa8wqQd)fODb4iG(HPlM4HZKHvozK8Y5irrxg59faBbWFbAxGYlq9zTcUWStsCgx5KOpmwHfCeSfKMleRcrcoi5eZvEz4K4mUYP(c0UaLxGYlyyiYhr9CsgwPEysLGCwfI(lq7cWra9dtxupNKHvQhMujk6YiVVGJGTGC8FbAxaocOFy6cUWSts9WKkrrxg59faVfKMleRcrIjMR8YWj)eeRH0gLK1xGslqrfxGYlWaxWWqKpI65KmSs9WKkb5Ske9xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbP5cXQqKyI5kVmCYpbXAiTrjz9fO0cuuXfGJa6hMUGlm7KupmPsu0LrEFbhbBb54)cuAbk1sy8GcVLyROpspsZTPDY52oULqoRcr)2zTeCHgQqClPEozJkNe5fQdPHeHryisqoRcr)fODb4iG(HPl4cZoj1dtQefDzK3xaSfa)fODbkVaLxGYlahb0pmDXepCMmSYjJKxohjk6YiVVa4TG0CHyvisW6YldN8tqSgsBuYjM7c0Ua1N1k4cZojXzCLtI(WyfwaSfO(Swbxy2jjoJRCsCz4K9HXkSaLwGIkUaLxaocOFy6IjE4mzyLtgjVCosu0LrEFbWwa8xG2fO(Swbxy2jjoJRCs0hgRWcoc2csZfIvHibhKCI5kVmCsCgx5uFbkTaLwG2fO(Swr9CsgwPEysL4hM(cuQLW4bfElXwrFKEKMBt7KZ3oULqoRcr)2zTeCHgQqClPEozJkNeDKEw4Y(e1vqoRcr)fODb6fLwMJ)cnfu6aZdk8wcJhu4TKjE4mzyLtgjVCoQnTtoNTJBjKZQq0VDwlbxOHke3sQNt2OYjrhPNfUSprDfKZQq0FbAxGYlqVO0YC8xOPGshyEqHVafvCb6fLwMJ)cnft8WzYWkNmsE5C0cuQLW4bfElHlm7KupmPQnTtsnTJBjKZQq0VDwlbxOHke3sg0Lwa8wqQd)fODb1ZjBu5KOJ0Zcx2NOUcYzvi6VaTlq9zTcUWStsCgx5KOpmwHfCeSfKMleRcrcoi5eZvEz4K4mUYP(c0UaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cGTa4VaTlahb0pmDbxy2jPEysLOOlJ8(coc2cYX)wcJhu4TekDG5bfEBANKABh3siNvHOF7SwcJhu4TekDG5bfElb5dv1tFKiBlr9zTIosplCzFI6k6dJvaM6ZAfDKEw4Y(e1vCz4K9HXk0sq(qv90hj6EPpIhQLOzlbxOHke3sg0Lwa8wqQd)fODb1ZjBu5KOJ0Zcx2NOUcYzvi6VaTlahb0pmDbxy2jPEysLOOlJ8(cGTa4VaTlq5fO8cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faVfKMleRcrcwxEz4KFcI1qAJsoXCxG2fO(Swbxy2jjoJRCs0hgRWcGTa1N1k4cZojXzCLtIldNSpmwHfO0cuuXfO8cWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0Ua1N1k4cZojXzCLtI(WyfwWrWwqAUqSkej4GKtmx5LHtIZ4kN6lqPfO0c0Ua1N1kQNtYWk1dtQe)W0xGsTPDskPDClHCwfI(TZAj4cnuH4wIYlahb0pmDbxy2jPEysLOOlJ8(cG3co3ZVafvCb4iG(HPl4cZoj1dtQefDzK3xWrWwqQVaLwG2fGJa6hMUyIhotgw5KrYlNJefDzK3xaSfa)fODbkVa1N1k4cZojXzCLtI(WyfwWrWwqAUqSkej4GKtmx5LHtIZ4kN6lq7cuEbkVGHHiFe1ZjzyL6HjvcYzvi6VaTlahb0pmDr9CsgwPEysLOOlJ8(coc2cYX)fODb4iG(HPl4cZoj1dtQefDzK3xa8wW5xGslqrfxGYlWaxWWqKpI65KmSs9WKkb5Ske9xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbNFbkTafvCb4iG(HPl4cZoj1dtQefDzK3xWrWwqo(VaLwGsTegpOWBjxuvr1LHvorDjFAt7enHF74wc5Ske9BN1sWfAOcXTeCeq)W0ft8WzYWkNmsE5CKOOlJ8(coAbeCe(nKCqxAbAxGYlq9zTcUWStsCgx5KOpmwHfCeSfKMleRcrcoi5eZvEz4K4mUYP(c0UaLxGYlyyiYhr9CsgwPEysLGCwfI(lq7cWra9dtxupNKHvQhMujk6YiVVGJGTGC8FbAxaocOFy6cUWSts9WKkrrxg59faVfKMleRcrIjMR8YWj)eeRH0gLK1xGslqrfxGYlWaxWWqKpI65KmSs9WKkb5Ske9xG2fGJa6hMUGlm7KupmPsu0LrEFbWBbP5cXQqKyI5kVmCYpbXAiTrjz9fO0cuuXfGJa6hMUGlm7KupmPsu0LrEFbhbBb54)cuAbk1sy8GcVLu8hX(i76CPqBANOPMTJBjKZQq0VDwlbxOHke3sWra9dtxWfMDsQhMujk6YiVVGJwabhHFdjh0LwG2fO8cuEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3csZfIvHibRlVmCYpbXAiTrjNyUlq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWcuAbkQ4cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faBbWFbAxG6ZAfCHzNK4mUYjrFyScl4iylinxiwfIeCqYjMR8YWjXzCLt9fO0cuAbAxG6ZAf1ZjzyL6HjvIFy6lqPwcJhu4TKI)i2hzxNlfAt7enny74wc5Ske9BN1sWfAOcXTeCeq)W0fCHzNK6HjvIIUmY7la2cG)c0UaLxGYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3xa8wqAUqSkejyD5LHt(jiwdPnk5eZDbAxG6ZAfCHzNK4mUYjrFyScla2cuFwRGlm7KeNXvojUmCY(WyfwGslqrfxGYlahb0pmDXepCMmSYjJKxohjk6YiVVayla(lq7cuFwRGlm7KeNXvoj6dJvybhbBbP5cXQqKGdsoXCLxgojoJRCQVaLwGslq7cuFwROEojdRupmPs8dtFbk1sy8GcVL8jEYuJYP20orZuVDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK4mUYjrFyScl4iylinxiwfIeCqYjMR8YWjXzCLt9fODbkVaLxWWqKpI65KmSs9WKkb5Ske9xG2fGJa6hMUOEojdRupmPsu0LrEFbhbBb54)c0UaCeq)W0fCHzNK6HjvIIUmY7laElinxiwfIetmx5LHt(jiwdPnkjRVaLwGIkUaLxGbUGHHiFe1ZjzyL6HjvcYzvi6VaTlahb0pmDbxy2jPEysLOOlJ8(cG3csZfIvHiXeZvEz4KFcI1qAJsY6lqPfOOIlahb0pmDbxy2jPEysLOOlJ8(coc2cYX)fOulHXdk8wYepCMmSYjJKxoh1M2jAEUTJBjKZQq0VDwlbxOHke3suEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3csZfIvHibRlVmCYpbXAiTrjNyUlq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRWcuAbkQ4cuEb4iG(HPlM4HZKHvozK8Y5irrxg59faBbWFbAxG6ZAfCHzNK4mUYjrFyScl4iylinxiwfIeCqYjMR8YWjXzCLt9fO0cuAbAxG6ZAf1ZjzyL6HjvIFy6TegpOWBjCHzNK6HjvTPDIMNVDClHCwfI(TZAj4cnuH4wI6ZAf1ZjzyL6HjvIFy6lq7cuEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ8(cG3cmi8xG2fO(Swbxy2jjoJRCs0hgRWcGTa1N1k4cZojXzCLtIldNSpmwHfO0cuuXfO8cWra9dtxmXdNjdRCYi5LZrIIUmY7la2cG)c0Ua1N1k4cZojXzCLtI(WyfwWrWwqAUqSkej4GKtmx5LHtIZ4kN6lqPfO0c0UaLxaocOFy6cUWSts9WKkrrxg59faVfOPbxGIkUGpP(SwXepCMmSYjJKxohjE6lqPwcJhu4TK65KmSs9WKQ20orZZz74wc5Ske9BN1sWfAOcXTeCeq)W0fCHzNKrPkk6YiVVa4TGZVafvCbg4cggI8rWfMDsgLQGCwfI(TegpOWBj9mKDqEUupmPQnTt0m10oULqoRcr)2zTeCHgQqClr9zTIpXtMAuojE6lq7c(K6ZAft8WzYWkNmsE5CK4PVaTl4tQpRvmXdNjdRCYi5LZrIIUmY7l4iylq9zTc9I6KJjzyLxK)fxgozFySclifybmEqHl4cZojvH4(ii4i8Bi5GUulHXdk8wIErDYXKmSYlY)TPDIMP22XTeYzvi63oRLGl0qfIBjQpRv8jEYuJYjXtFbAxGYlq5fmme5JOOE4SJjb5Ske9xG2fW4bLMKKtxe1xWrl4CxGslqrfxaJhuAssoDruFbhTGZVaLwG2fO8cmWfupNSrLtcUWSts14QY1)s(iiNvHO)cuuXfmCLtJiJyOjtOJNfaVfK6NFbk1sy8GcVLWfMDsQcX9PnTt0mL0oULW4bfElP)0PYJ0ClHCwfI(TZAt7edc)2XTeYzvi63oRLGl0qfIBjQpRvWfMDsIZ4kNe9HXkSa4bBbkVagpO0KKC6IO(csbVanxGslq7cQNt2OYjbxy2jPACv56FjFeKZQq0FbAxWWvonImIHMmHoEwWrli1pFlHXdk8wcxy2jPkxfNtTPDIb1SDClHCwfI(TZAj4cnuH4wI6ZAfCHzNK4mUYjrFyScla2cuFwRGlm7KeNXvojUmCY(WyfAjmEqH3s4cZojv5Q4CQnTtmObBh3siNvHOF7SwcUqdviULO(Swbxy2jjoJRCs0hgRWcGTa43sy8GcVLWfMDsgLABANyWuVDClHCwfI(TZAj4cnuH4wIYlOiBr9mwfIwGIkUadCbdcRaYZxGslq7cuFwRGlm7KeNXvoj6dJvybWwG6ZAfCHzNK4mUYjXLHt2hgRqlHXdk8wIttgvYHU6uFAt7edEUTJBjKZQq0VDwlbxOHke3suFwRadrCH5(G8CrrmEwG2fupNSrLtcUWStsKBroA0qqoRcr)fODbkVaLxWWqKpc(QdHSimpOWfKZQq0FbAxaJhuAssoDruFbhTGu7cuAbkQ4cy8GstsYPlI6l4OfC(fOulHXdk8wcxy2j5f17iiQ3M2jg88TJBjKZQq0VDwlbxOHke3suFwRadrCH5(G8CrrmEwG2fmme5JGlm7KKWzHGCwfI(lq7c(K6ZAft8WzYWkNmsE5CK4PVaTlq5fmme5JGV6qilcZdkCb5Ske9xGIkUagpO0KKC6IO(coAbPKfOulHXdk8wcxy2j5f17iiQ3M2jg8C2oULqoRcr)2zTeCHgQqClr9zTcmeXfM7dYZffX4zbAxWWqKpc(QdHSimpOWfKZQq0FbAxaJhuAssoDruFbhTGZTLW4bfElHlm7K8I6Dee1Bt7edMAAh3siNvHOF7SwcUqdviULO(Swbxy2jjoJRCs0hgRWcoAbQpRvWfMDsIZ4kNexgozFyScTegpOWBjCHzNKeC6qrhfEBANyWuB74wc5Ske9BN1sWfAOcXTe1N1k4cZojXzCLtI(WyfwaSfO(Swbxy2jjoJRCsCz4K9HXkSaTlqVO0YC8xOPGlm7KuLRIZPwcJhu4TeUWStscoDOOJcVnTtmykPDClb5dv1tFKiBl5Yol0Xd8GLsoFlb5dv1tFKO7L(iEOwIMTegpOWBju6aZdk8wc5Ske9BN1M20scDYPQDC7enBh3siNvHOF7SwcUqdviULupNSrLtIpQJr6qiNlnK44Ez)liNvHO)c0Ua1N1k(OogPdHCU0qIJ7L9V0wrFep9wcJhu4TelQiPke3N20oXGTJBjKZQq0VDwlbxOHke3sQNt2OYjrEH6qAiryegIeKZQq0FbAxWLDwOJNfaVfKsoFlHXdk8wITI(i9in3M2jPE74wcJhu4TKpXtMAuo1siNvHOF7S20o5CBh3siNvHOF7SwcUqdviULCzNf64zbWBbNl8BjmEqH3sk(JyFKDDUuOnTtoF74wc5Ske9BN1sWfAOcXTe1N1k4cZoj1dtQe)W0xG2fGJa6hMUGlm7KupmPsu0LrEVLW4bfElPNHSdYZL6HjvTPDY5SDClHXdk8wYfvvuDzyLtuxYNwc5Ske9BN1M2jPM2XTegpOWBjt8WzYWkNmsE5CulHCwfI(TZAt7KuB74wcJhu4TeUWSts9WKQwc5Ske9BN1M2jPK2XTeYzvi63oRLGl0qfIBjQpRvupNKHvQhMuj(HP3sy8GcVLupNKHvQhMu1M2jAc)2XTeYzvi63oRLW4bfElrVOo5ysgw5f5)wYN64cPpOWBjgqDAbhCKcxWelOFqFeDqqlG9fqWnfVGuTWStl4miUpl4)kKNVGjJwWXXKcpnvp4fyI8FyUGNdr9(cQN7ipFbPAHzNwGbmolelWaWUGuTWStlWagNfla1xWWqKp034fyslaZUrZcEDAbhCKcxGjAYq(cMmAbhhtk80u9GxGjY)H5cEoe17lWKwaYhQQN(SGjJwqQMcxaoJDNGmEb9ybMKrqqlOZPPfGgrlbxOHke3smWfmme5JGlm7KKWzHGCwfI(lq7c(K6ZAft8WzYWkNmsE5CK4PVaTl4tQpRvmXdNjdRCYi5LZrIIUmY7l4iylq5fW4bfUGlm7KufI7JGGJWVHKd6slifybQpRvOxuNCmjdR8I8V4YWj7dJvybk1M2jAQz74wc5Ske9BN1sy8GcVLOxuNCmjdR8I8Fl5tDCH0hu4Teda7co4ifUGmU7gnlqLiFbVo9xW)vipFbtgTGJJjfUatK)dtJxGjzee0cEDAbOzbtSG(b9r0bbTa2xab3u8cs1cZoTGZG4(SaKVGjJwW5io4tt1dEbMi)hMIwcUqdviUL8Jru8hX(i76CPGOOlJ8(cG3co)cuuXf8j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwHfaVfa)20ortd2oULqoRcr)2zTeCHgQqClr9zTc9I6KJjzyLxK)fp9fODbFs9zTIjE4mzyLtgjVCos80xG2f8j1N1kM4HZKHvozK8Y5irrxg59fCeSfW4bfUGlm7KufI7JGGJWVHKd6sTegpOWBjCHzNKQqCFAt7ent92XTeYzvi63oRLW4bfElHlm7KuLRIZPwYN64cPpOWBjPkKjRrFbNXvX50c4zbtgTaY)liSlivp4fyMr(cQN7ipFbtgTGuTWStlWamx3W1ybquo5FU0OLGl0qfIBjQpRvWfMDsQhMujE6lq7cuFwRGlm7KupmPsu0LrEFbhTGC8FbAxq9CYgvoj4cZojrUf5Ordb5Ske9Bt7enp32XTeYzvi63oRLW4bfElHlm7KuLRIZPwYN64cPpOWBjPkKjRrFbNXvX50c4zbtgTaY)liSlyYOfCoIdEbMi)hMlWmJ8fup3rE(cMmAbPAHzNwGbyUUHRXcGOCY)CPrlbxOHke3suFwROEojdRupmPs80xG2fO(Swbxy2jPEysL4hM(c0Ua1N1kQNtYWk1dtQefDzK3xWrWwqo(VaTlOEozJkNeCHzNKi3IC0OHGCwfI(TPDIMNVDClHCwfI(TZAj4mg5TenBjexqAiXzmYLiBlr9zTcmeXfM7dYZL4m2Dcs8dtxRYQpRvWfMDsQhMujE6kQOYg4WqKpIinv6Hjv0xRYQpRvupNKHvQhMujE6kQiocOFy6ckDG5bfUOi(RHskPulbxOHke3s(K6ZAft8WzYWkNmsE5CK4PVaTlyyiYhbxy2jjHZcb5Ske9xG2fO8cuFwR4t8KPgLtIFy6lqrfxaJhuAssoDruFbWwGMlqPfODbFs9zTIjE4mzyLtgjVCosu0LrEFbWBbmEqHl4cZojVOEhbrDbbhHFdjh0LAjmEqH3s4cZojVOEhbr920orZZz74wc5Ske9BN1sy8GcVLWfMDsEr9ocI6TeCgJ8wIMTeCHgQqClr9zTcmeXfM7dYZffX4PnTt0m10oULqoRcr)2zTeCHgQqClr9zTcUWStsCgx5KOpmwHfCeSfKMleRcrIjMR8YWjXzCLt9wcJhu4TeUWStYOuBt7entTTJBjKZQq0VDwlbxOHke3suFwROEojdRupmPs80xGIkUGl7SqhplaElqZZ3sy8GcVLWfMDsQcX9PnTt0mL0oULqoRcr)2zTegpOWBju6aZdk8wcYhQQN(ir2wYLDwOJh4bl1E(wcYhQQN(ir3l9r8qTenBj4cnuH4wI6ZAf1ZjzyL6HjvIFy6lq7cuFwRGlm7KupmPs8dtVnTtmi8Bh3sy8GcVLWfMDsQYvX5ulHCwfI(TZAtBAjwKZqs1x5TJBNOz74wc5Ske9BN1sy8GcVLWfMDsEr9ocI6TeCgJ8wIMTeCHgQqClr9zTcmeXfM7dYZffX4PnTtmy74wcJhu4TeUWStsviUpTeYzvi63oRnTts92XTegpOWBjCHzNKQCvCo1siNvHOF7S20M20sstvhfE7edcFdQj810GNBlXKlh559wYbzQEooXa4edqt5fSGJZOfGU6rnlWg1cmYI6zipxg6KtLrlOOd6dv0Fb94slGFtC5H(laNXEo1fRHPcYPfOzkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzdcNsI1Wub50cmykVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1eoLeRHPcYPfK6P8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfCUP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfC(uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwaplWaofuQSaL1eoLeRHPcYPfKss5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkBq4usSgMkiNwGMNBkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1eoLeRHPcYPfOzQjLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOSMWPKynmvqoTantnP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaEwGbCkOuzbkRjCkjwdtfKtlqZuBkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbge(P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwt4usSgUgEqMQNJtmaoXa0uEbl44mAbOREuZcSrTaJcDYPYOfu0b9Hk6VGECPfWVjU8q)fGZypN6I1Wub50c0mLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOSMWPKynmvqoTadMYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwGMWpLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAcNsI1Wub50c0m1t5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAb8Sad4uqPYcuwt4usSgMkiNwGMNBkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlGNfyaNckvwGYAcNsI1Wub50c088P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwt4usSgUgEqMQNJtmaoXa0uEbl44mAbOREuZcSrTaJQy4bfUrlOOd6dv0Fb94slGFtC5H(laNXEo1fRHPcYPfOzkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1eoLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAcNsI1Wub50co3uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRjCkjwdtfKtl48P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwt4usSgMkiNwqkjLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAcNsI1Wub50c0mLKYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqznHtjXAyQGCAbge(P8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfyqnt5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRjCkjwdtfKtlWGPEkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbg8Ct5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRjCkjwdxdpit1ZXjgaNyaAkVGfCCgTa0vpQzb2OwGrFYYpOXOfu0b9Hk6VGECPfWVjU8q)fGZypN6I1Wub50cmykVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzdcNsI1Wub50cs9uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYgeoLeRHPcYPfCUP8csXWtt1q)fKGUP4c6A4dd3cma5cMybPYJxWhLg1rHVGqNkEIAbkFQslqznHtjXAyQGCAbNpLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfKAs5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRjCkjwdtfKtlqZutkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbAMss5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRjCkjwdtfKtlWGAMYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwGbt9uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRjCkjwdtfKtlWGPEkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbgm1t5fKIHNMQH(lWiC4)hAehWOfmXcmch()HgXbeKZQq03OfWZcmGtbLklqznHtjXA4A4bzQEooXa4edqt5fSGJZOfGU6rnlWg1cmsViCCv5XOfu0b9Hk6VGECPfWVjU8q)fGZypN6I1Wub50coNP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfO55MYlifdpnvd9xGr4W)p0ioGrlyIfyeo8)dnIdiiNvHOVrlqznHtjXAyQGCAbg0GP8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTadAWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAcNsI1Wub50cmyQjLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfWZcmGtbLklqznHtjXAyQGCAbgm1MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0c4zbgWPGsLfOSMWPKynCn8GmvphNyaCIbOP8cwWXz0cqx9OMfyJAbgHJa6hME3Ofu0b9Hk6VGECPfWVjU8q)fGZypN6I1Wub50c0mLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfOzkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbgmLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAcNsI1Wub50cs9uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwqQNYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwW5MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwqQjLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfKss5fKIHNMQH(lWOHHiFehWOfmXcmAyiYhXbeKZQq03OfOSbHtjXAyQGCAbAc)uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwGMgmLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfO55MYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqznHtjXAyQGCAbAE(uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRjCkjwdtfKtlqZuskVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1eoLeRHRHhKP654edGtmanLxWcooJwa6Qh1SaBulWioiJwqrh0hQO)c6XLwa)M4Yd9xaoJ9CQlwdtfKtlqZuEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwGMP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYgeoLeRHPcYPfK6P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTGupLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOSMWPKynmvqoTGZnLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOSMWPKynmvqoTGZNYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwW5mLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOSMWPKynmvqoTGutkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbP2uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAcNsI1Wub50csjP8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTanHFkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaLniCkjwdtfKtlqZupLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfO55mLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwaplWaofuQSaL1eoLeRHPcYPfOzQnLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAcNsI1Wub50c0m1MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwt4usSgMkiNwGbHFkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqznHtjXAyQGCAbg8Ct5fKIHNMQH(lWOHHiFehWOfmXcmAyiYhXbeKZQq03OfOSMWPKynmvqoTadEUP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1eoLeRHPcYPfyWZNYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqzdcNsI1Wub50cm45mLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAcNsI1W1WdYu9CCIbWjgGMYlybhNrlaD1JAwGnQfyeFLDD(A0ck6G(qf9xqpU0c43exEO)cWzSNtDXAyQGCAbAMYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqznHtjXA4AObWvpQH(lqtnxaJhu4lac1NUynSLOxHfbrTKuAkDbPqoNwqQwy2P1WuAkDbPqUWzli1y8cmi8nOMRHRHP0u6coh0nstlinxiwfIe8v2157cq(cSC6OwqyxqNMb55DbFLDD(UaLXzewHfOr8Qf01j8cc9bfExjXAyknLUadOoTGrdDeMHwqc6MIliJ9peYZxqyxaoJDNGwaYhQQN(GcFbiVpe)xqyxGry2XeKKXdkCJeRHRHmEqH3f6fHJRkphc7uUWStsKpeeeHN1qgpOW7c9IWXvLNdHDkxy2jPLViiexRHmEqH3f6fHJRkphc7uC4gG4vK8YolZP7AiJhu4DHEr44QYZHWonnxiwfIm25lbJVYUoFno0HvuNgJ)KLFqdSondYZ7c(k768DnKXdk8UqViCCv55qyNMMleRcrg78LGrPdPoEmo0HvuNgJ)KLFqdmnp)AiJhu4DHEr44QYZHWonnxiwfIm25lbtVi9heKKshgh6W60ymYct565KnQCs0r6zHl7tuxTmEqPjj50frD4P5HkRzkGYgiosto7JWjCfqr9vsjLmond9iyAACAg6rscQtWG)AiJhu4DHEr44QYZHWonnxiwfIm25lblJttYqNC6BCOdRtJXilmLz8GstsYPlI6WZGkQyAUqSkej0ls)bbjP0bmnvuX0CHyvisWxzxNVW0ujJtZqpcMMgNMHEKKG6em4VgY4bfExOxeoUQ8CiSttZfIvHiJD(sWSiNHKQVYno0H1PX40m0JGb)1qgpOW7c9IWXvLNdHDAAUqSkezSZxcw1Lxgo5NGynK2OKtmxJdDyf1PX4pz5h0a78RHmEqH3f6fHJRkphc700CHyviYyNVeSQlVmCYpbXAiTrjRq34qhwrDAm(tw(bnWo)AiJhu4DHEr44QYZHWonnxiwfIm25lbR6YldN8tqSgsBusw34qhwrDAm(tw(bnWmi8xdz8GcVl0lchxvEoe2PP5cXQqKXoFjySU8YWj)eeRH0gLCI5ACOdROong)jl)GgyAc)1qgpOW7c9IWXvLNdHDAAUqSkezSZxcwf6YldN8tqSgsBuYjMRXHoSI60y8NS8dAGzq4VgY4bfExOxeoUQ8CiSttZfIvHiJD(sWMyUYldN8tqSgsBusw34qhwNgJrwykJJ0KZ(iCuE2iTmPOIkJd))qJGlm7KuVIpkxdTmEqPjj50fr9JsDLuY40m0JGP55nond9ijb1jyNFnKXdk8UqViCCv55qyNMMleRcrg78LGnXCLxgo5NGynK2OKvOBCOdROong)jl)Ggyge(RHmEqH3f6fHJRkphc700CHyviYyNVemvUkoNKx2zPoEmo0H1PXyKfgosto7JWr5zJ0YKXPzOhb7Cc)uWkF5(qLgY0m0Jsb0e(WxP1qgpOW7c9IWXvLNdHDAAUqSkezSZxcMkxfNtYl7Suhpgh6W60ymYcdhPjN9rOGgfIDJtZqpcwk58PGv(Y9HknKPzOhLcOj8HVsRHmEqH3f6fHJRkphc700CHyviYyNVemvUkoNKx2zPoEmo0H1PXyKfwAUqSkeju5Q4CsEzNL64bg8nond9iyPw4Ncw5l3hQ0qMMHEukGMWh(kTgY4bfExOxeoUQ8CiSttZfIvHiJD(sWyD5f5O77kVSZsD8yCOdROong)jl)GgyAE(1qgpOW7c9IWXvLNdHDAAUqSkezSZxc2eZvEz4K4mUYPUXHoSI60y8NS8dAGzW1qgpOW7c9IWXvLNdHDAAUqSkezSZxcghKCI5kVmCsCgx5u34qhwrDAm(tw(bnWm4AiJhu4DHEr44QYZHWonnxiwfIm25lbZI6zipxg6KtLXHoSongNMHEemntbuMoOpKUo9f0vxJIyizuFNDmPOIkpme5JOEojdRupmPsRYddr(i4cZojjCwOOIgiosto7Jqbnke7kPvzdehPjN9r4eUcOO(kQiJhuAssoDruhMMkQy9CYgvoj6i9SWL9jQRskP0AiJhu4DHEr44QYZHWonnxiwfIm25lbJ1LHlFDY4qhwNgJtZqpcgDqFiDD6lUmMvls2ZiAK3xhHvur6G(q660xKdXFepr1LQ8pNuur6G(q660xKdXFepr1Lx6ZqqOWvur6G(q660x85sHBeU8tyfK6VPOoMCmPOI0b9H01PVa5DC9gwfIKh0h7Z7k)uAeMuur6G(q660x0JheendYZL1tvdfvKoOpKUo9f9NRcfXxYxAY0OpkQiDqFiDD6lmzfiNQU0wH)vur6G(q660xyH4ljdRuLNbIwdz8GcVl0lchxvEoe2PP5cXQqKXoFjyCqYjMR8YWjXzCLtDJdDyf1PX4pz5h0aZGRHmEqH3f6fHJRkphc700CHyviYyNVemkDi1XJXHoSI60y8NS8dAGP55xdz8GcVl0lchxvEoe2PxuvrjrxoNwdz8GcVl0lchxvEoe2P2k6JAangJSWmW0CHyvisOxK(dcssPdyAQTEozJkNeFuhJ0HqoxAiXX9Y(FnKXdk8UqViCCv55qyNYfMDsQcX9XyKfMbMMleRcrc9I0FqqskDattTgy9CYgvoj(OogPdHCU0qIJ7L9)AiJhu4DHEr44QYZHWoLshyEqHBmYclnxiwfIe6fP)GGKu6aMMRHRHmEqH3pe2P445dvDDccAnKXdk8(HWonnxiwfIm25lblJttYqNC6BCOdRtJXPzOhbttJrwyP5cXQqKiJttYqNC6dd(A1lkTmh)fAkO0bMhu4AnqLRNt2OYjrhPNfUSprDvuX65KnQCsm0vpkgsAYLUsRHmEqH3pe2PP5cXQqKXoFjyzCAsg6KtFJdDyDAmond9iyAAmYclnxiwfIezCAsg6KtFyWxR6ZAfCHzNK6HjvIFy6AXra9dtxWfMDsQhMujk6YiVRv565KnQCs0r6zHl7tuxfvSEozJkNedD1JIHKMCPR0AiJhu49dHDAAUqSkezSZxcMf5mKu9vUXHoSongNMHEemnngzHP(Swbxy2jjoJRCs0hgRam1N1k4cZojXzCLtIldNSpmwbTgO6ZAf1dIKHvozfrDXtxRfLNnYIUmY7hbtzLVSZgGKXdkCbxy2jPke3hbo6JsPamEqHl4cZojvH4(ii4i8Bi5GUKsRHmEqH3pe2PVojVSZYC6AmYct5HHiFeKdHYZgYPV2l7Sqhphbl1cFTx2zHoEGhSZ55vsrfv2ahgI8rqoekpBiN(AVSZcD8CeSu75vAnKXdk8(HWovpgu4gJSWuFwRGlm7KupmPs80xdz8GcVFiSth0LKMCPBmYcREozJkNedD1JIHKMCPRv9zTccUm(1hu4INUwLXra9dtxWfMDsQhMujkI)AOOIwuE2il6YiVFeSZf(kTgY4bfE)qyNcHYZMU0aeVF(L8XyKfM6ZAfCHzNK6HjvIFy6AvFwROEojdRupmPs8dtx7NuFwRyIhotgw5KrYlNJe)W0xdz8GcVFiStv5CzyLtHWk0ngzHP(Swbxy2jPEysL4hMUw1N1kQNtYWk1dtQe)W01(j1N1kM4HZKHvozK8Y5iXpm91qgpOW7hc7uvQ6uPaYZngzHP(Swbxy2jPEysL4PVgY4bfE)qyNQcfXxAFLggJSWuFwRGlm7KupmPs80xdz8GcVFiStTOIuHI4BmYct9zTcUWSts9WKkXtFnKXdk8(HWoLDm1NIHKygcYyKfM6ZAfCHzNK6HjvIN(AiJhu49dHD6Rts0q3UXilm1N1k4cZoj1dtQep91qgpOW7hc70xNKOHUgtwlHhPZxcwoe)r8evxQY)CYyKfM6ZAfCHzNK6HjvINUIkIJa6hMUGlm7KupmPsu0LrEhEWo)51(j1N1kM4HZKHvozK8Y5iXtFnKXdk8(HWo91jjAORXoFjy0vxJIyizuFNDmzmYcdhb0pmDbxy2jPEysLOOlJ8(rWmi8xdz8GcVFiStFDsIg6ASZxc2Vi(Brfjtt9obzmYcdhb0pmDbxy2jPEysLOOlJ8o8Gzq4ROIgyAUqSkejyDz4YxNGPPIkQ8GUem4RnnxiwfIewupd55YqNCQGPP265KnQCs0r6zHl7tuxLwdz8GcVFiStFDsIg6ASZxcwpEqsuUJgQmgzHHJa6hMUGlm7KupmPsu0LrEhEWsD4ROIgyAUqSkejyDz4YxNGP5AiJhu49dHD6Rts0qxJD(sWYH0qptgwj37OlcIhu4gJSWWra9dtxWfMDsQhMujk6YiVdpyge(kQObMMleRcrcwxgU81jyAQOIkpOlbd(AtZfIvHiHf1ZqEUm0jNkyAQTEozJkNeDKEw4Y(e1vP1qgpOW7hc70xNKOHUg78LGDzmRwKSNr0iVVocBmYcdhb0pmDbxy2jPEysLOOlJ8(rWoVwLnW0CHyvisyr9mKNldDYPcMMkQ4GUe8sD4R0AiJhu49dHD6Rts0qxJD(sWUmMvls2ZiAK3xhHngzHHJa6hMUGlm7KupmPsu0LrE)iyNxBAUqSkejSOEgYZLHo5ubttTQpRvupNKHvQhMujE6AvFwROEojdRupmPsu0LrE)iykRj8tbF(uG65KnQCs0r6zHl7tuxL0oOlDuQd)1qgpOW7hc7umdbjz8GcxcH6JXoFjyCqg3NcHhyAAmYcJXdknjjNUiQdpdUgY4bfE)qyNIziijJhu4siuFm25lblJRB4AyCFkeEGPPXilmCKMC2hHcAui21wpNSrLtcUWStsKBroA0q7WqKpI65KmSs9WKkTgio8)dncUWSts9k(OCnwdtPl44mAbwupd55li0jNQfOs5iVVat0KTGZrCWlG9)cSOEg1xGnQfKIP4c0Ra3xWel41Pf8FfYZxWXXKcpnvp41qgpOW7hc7umdbjz8GcxcH6JXoFjywupd55YqNCQmUpfcpW00yKfwAUqSkejY40Km0jN(WGV20CHyvisyr9mKNldDYPAnKXdk8(HWofZqqsgpOWLqO(ySZxcwOtovg3NcHhyAAmYclnxiwfIezCAsg6KtFyWFnKXdk8(HWofZqqsgpOWLqO(ySZxcgFLDD(ACFkeEGPPXilSondYZ7c(k768fMMRHmEqH3pe2PygcsY4bfUec1hJD(sWWra9dtVVgY4bfE)qyNIziijJhu4siuFm25lbRIHhu4g3NcHhyAAmYclnxiwfIewKZqs1x5WG)AiJhu49dHDkMHGKmEqHlHq9XyNVemlYziP6RCJ7tHWdmnngzHLMleRcrclYziP6RCyAUgY4bfE)qyNIziijJhu4siuFm25lb7gPPl5ZA4AykDbmEqH3f8v215lmm7ycsY4bfUXilmgpOWfu6aZdkCboJDNGqEU2l7SqhpWdwk58RHmEqH3f8v2157HWoLshyEqHBmYc7Yol0XZrWsZfIvHibLoK64rRY4iG(HPlM4HZKHvozK8Y5irrxg59JGX4bfUGshyEqHli4i8Bi5GUKIkIJa6hMUGlm7KupmPsu0LrE)iymEqHlO0bMhu4ccoc)gsoOlPOIkpme5JOEojdRupmPslocOFy6I65KmSs9WKkrrxg59JGX4bfUGshyEqHli4i8Bi5GUKskPv9zTI65KmSs9WKkXpmDTQpRvWfMDsQhMuj(HPR9tQpRvmXdNjdRCYi5LZrIFy6RHmEqH3f8v2157HWo9t8KPgLtgJSWWra9dtxWfMDsQhMujk6YiVdd(Avw9zTI65KmSs9WKkXpmDTkJJa6hMUyIhotgw5KrYlNJefDzK3HxAUqSkejyD5LHt(jiwdPnk5eZvrfXra9dtxmXdNjdRCYi5LZrIIUmY7WGVskTgY4bfExWxzxNVhc70lQQO6YWkNOUKpgJSWWra9dtxWfMDsQhMujk6YiVdd(Avw9zTI65KmSs9WKkXpmDTkJJa6hMUyIhotgw5KrYlNJefDzK3HxAUqSkejyD5LHt(jiwdPnk5eZvrfXra9dtxmXdNjdRCYi5LZrIIUmY7WGVskTgY4bfExWxzxNVhc70I)i2hzxNlfwdz8GcVl4RSRZ3dHDApdzhKNl1dtQmgzHP(Swbxy2jPEysL4hMUwCeq)W0fCHzNK6HjvIPEKSOlJ8o8y8Gcx0Zq2b55s9WKkb(xAvFwROEojdRupmPs8dtxlocOFy6I65KmSs9WKkXupsw0LrEhEmEqHl6zi7G8CPEysLa)lTFs9zTIjE4mzyLtgjVCos8dtFnKXdk8UGVYUoFpe2P1ZjzyL6HjvgJSWuFwROEojdRupmPs8dtxlocOFy6cUWSts9WKkrrxg591qgpOW7c(k7689qyNoXdNjdRCYi5LZrgJSWughb0pmDbxy2jPEysLOOlJ8om4Rv9zTI65KmSs9WKkXpmDLuur9IslZXFHMI65KmSs9WKQ1qgpOW7c(k7689qyNoXdNjdRCYi5LZrgJSWWra9dtxWfMDsQhMujk6YiVF05HVw1N1kQNtYWk1dtQe)W01s9o5ysKg1rHldRuNklHhu4cYzvi6VgY4bfExWxzxNVhc7uUWSts9WKkJrwyQpRvupNKHvQhMuj(HPRfhb0pmDXepCMmSYjJKxohjk6YiVdV0CHyvisW6YldN8tqSgsBuYjM7AiJhu4DbFLDD(EiSt5cZojv5Q4CYyKfM6ZAfCHzNK6HjvINUw1N1k4cZoj1dtQefDzK3pcgJhu4cUWStYlQ3rquxqWr43qYbDjTQpRvWfMDsIZ4kNe9HXkat9zTcUWStsCgx5K4YWj7dJvynKXdk8UGVYUoFpe2PCHzNKrPAmYct9zTcUWStsCgx5KOpmwHJuFwRGlm7KeNXvojUmCY(Wyf0Q(Swr9CsgwPEysL4hMUw1N1k4cZoj1dtQe)W01(j1N1kM4HZKHvozK8Y5iXpm91qgpOW7c(k7689qyNYfMDsQYvX5KXilm1N1kQNtYWk1dtQe)W01Q(Swbxy2jPEysL4hMU2pP(SwXepCMmSYjJKxohj(HPRv9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFyScRHmEqH3f8v2157HWoLlm7K8I6Dee1ngzHP(SwbgI4cZ9b55IIy8ymoJromnnM4csdjoJrUezHP(SwbgI4cZ9b55sCg7obj(HPRvz1N1k4cZoj1dtQepDfvu9zTI65KmSs9WKkXtxrfXra9dtxqPdmpOWffXFnuAnKXdk8UGVYUoFpe2PCHzNKxuVJGOUXilmdKpiOcnKGlm7Ku)DVeeYZfKZQq0xrfvFwRadrCH5(G8CjoJDNGe)W0ngNXihMMgtCbPHeNXixISWuFwRadrCH5(G8CjoJDNGe)W01QS6ZAfCHzNK6HjvINUIkQ(Swr9CsgwPEysL4PROI4iG(HPlO0bMhu4II4VgkTgY4bfExWxzxNVhc7ukDG5bfUXilm1N1kQNtYWk1dtQe)W01Q(Swbxy2jPEysL4hMU2pP(SwXepCMmSYjJKxohj(HPVgY4bfExWxzxNVhc7uUWStYOungzHP(Swbxy2jjoJRCs0hgRWrQpRvWfMDsIZ4kNexgozFyScRHmEqH3f8v2157HWoLlm7KuLRIZP1qgpOW7c(k7689qyNYfMDsQcX9znCnKXdk8UGdcMTI(OgqJXilS65KnQCs8rDmshc5CPHeh3l7FT4iG(HPluFwR8J6yKoeY5sdjoUx2)II4VgAvFwR4J6yKoeY5sdjoUx2)sBf9r8dtxRYQpRvWfMDsQhMuj(HPRv9zTI65KmSs9WKkXpmDTFs9zTIjE4mzyLtgjVCos8dtxjT4iG(HPlM4HZKHvozK8Y5irrxg5DyWxRYQpRvWfMDsIZ4kNe9HXkCeS0CHyvisWbjNyUYldNeNXvo11QSYddr(iQNtYWk1dtQ0IJa6hMUOEojdRupmPsu0LrE)iy54VwCeq)W0fCHzNK6HjvIIUmY7WlnxiwfIetmx5LHt(jiwdPnkjRRKIkQSbome5JOEojdRupmPslocOFy6cUWSts9WKkrrxg5D4LMleRcrIjMR8YWj)eeRH0gLK1vsrfXra9dtxWfMDsQhMujk6YiVFeSC8xjLwdz8GcVl4Goe2PwursviUpgJSWuUEozJkNeFuhJ0HqoxAiXX9Y(xlocOFy6c1N1k)OogPdHCU0qIJ7L9VOi(RHw1N1k(OogPdHCU0qIJ7L9V0Iks8dtxRErPL54VqtHTI(OgqJskQOY1ZjBu5K4J6yKoeY5sdjoUx2)Ah0LostLwdz8GcVl4Goe2P2k6J0J0SXilS65KnQCsKxOoKgsegHHiT4iG(HPl4cZoj1dtQefDzK3HxQdFT4iG(HPlM4HZKHvozK8Y5irrxg5DyWxRYQpRvWfMDsIZ4kNe9HXkCeS0CHyvisWbjNyUYldNeNXvo11QSYddr(iQNtYWk1dtQ0IJa6hMUOEojdRupmPsu0LrE)iy54VwCeq)W0fCHzNK6HjvIIUmY7WlnxiwfIetmx5LHt(jiwdPnkjRRKIkQSbome5JOEojdRupmPslocOFy6cUWSts9WKkrrxg5D4LMleRcrIjMR8YWj)eeRH0gLK1vsrfXra9dtxWfMDsQhMujk6YiVFeSC8xjLwdz8GcVl4Goe2P2k6J0J0SXilS65KnQCsKxOoKgsegHHiT4iG(HPl4cZoj1dtQefDzK3HbFTkRSY4iG(HPlM4HZKHvozK8Y5irrxg5D4LMleRcrcwxEz4KFcI1qAJsoXC1Q(Swbxy2jjoJRCs0hgRam1N1k4cZojXzCLtIldNSpmwbLuurLXra9dtxmXdNjdRCYi5LZrIIUmY7WGVw1N1k4cZojXzCLtI(WyfocwAUqSkej4GKtmx5LHtIZ4kN6kPKw1N1kQNtYWk1dtQe)W0vAnKXdk8UGd6qyNoXdNjdRCYi5LZrgJSWQNt2OYjrhPNfUSprD1QxuAzo(l0uqPdmpOWxdz8GcVl4Goe2PCHzNK6HjvgJSWQNt2OYjrhPNfUSprD1QSErPL54VqtbLoW8Gcxrf1lkTmh)fAkM4HZKHvozK8Y5iLwdz8GcVl4Goe2Pu6aZdkCJrwyd6sWl1HV265KnQCs0r6zHl7tuxTQpRvWfMDsIZ4kNe9HXkCeS0CHyvisWbjNyUYldNeNXvo11IJa6hMUyIhotgw5KrYlNJefDzK3HbFT4iG(HPl4cZoj1dtQefDzK3pcwo(VgY4bfExWbDiStP0bMhu4gJSWg0LGxQdFT1ZjBu5KOJ0Zcx2NOUAXra9dtxWfMDsQhMujk6YiVdd(AvwzLXra9dtxmXdNjdRCYi5LZrIIUmY7WlnxiwfIeSU8YWj)eeRH0gLCI5Qv9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFySckPOIkJJa6hMUyIhotgw5KrYlNJefDzK3HbFTQpRvWfMDsIZ4kNe9HXkCeS0CHyvisWbjNyUYldNeNXvo1vsjTQpRvupNKHvQhMuj(HPRKXiFOQE6JezHP(SwrhPNfUSprDf9HXkat9zTIosplCzFI6kUmCY(Wyfmg5dv1tFKO7L(iEiyAUgY4bfExWbDiStVOQIQldRCI6s(ymYctzCeq)W0fCHzNK6HjvIIUmY7W7CpVIkIJa6hMUGlm7KupmPsu0LrE)iyPUsAXra9dtxmXdNjdRCYi5LZrIIUmY7WGVwLvFwRGlm7KeNXvoj6dJv4iyP5cXQqKGdsoXCLxgojoJRCQRvzLhgI8rupNKHvQhMuPfhb0pmDr9CsgwPEysLOOlJ8(rWYXFT4iG(HPl4cZoj1dtQefDzK3H35vsrfv2ahgI8rupNKHvQhMuPfhb0pmDbxy2jPEysLOOlJ8o8oVskQiocOFy6cUWSts9WKkrrxg59JGLJ)kP0AiJhu4Dbh0HWoT4pI9r215sbJrwy4iG(HPlM4HZKHvozK8Y5irrxg59Ji4i8Bi5GUKwLvFwRGlm7KeNXvoj6dJv4iyP5cXQqKGdsoXCLxgojoJRCQRvzLhgI8rupNKHvQhMuPfhb0pmDr9CsgwPEysLOOlJ8(rWYXFT4iG(HPl4cZoj1dtQefDzK3HxAUqSkejMyUYldN8tqSgsBuswxjfvuzdCyiYhr9CsgwPEysLwCeq)W0fCHzNK6HjvIIUmY7WlnxiwfIetmx5LHt(jiwdPnkjRRKIkIJa6hMUGlm7KupmPsu0LrE)iy54VskTgY4bfExWbDiStl(JyFKDDUuWyKfgocOFy6cUWSts9WKkrrxg59Ji4i8Bi5GUKwLvwzCeq)W0ft8WzYWkNmsE5CKOOlJ8o8sZfIvHibRlVmCYpbXAiTrjNyUAvFwRGlm7KeNXvoj6dJvaM6ZAfCHzNK4mUYjXLHt2hgRGskQOY4iG(HPlM4HZKHvozK8Y5irrxg5DyWxR6ZAfCHzNK4mUYjrFySchblnxiwfIeCqYjMR8YWjXzCLtDLusR6ZAf1ZjzyL6HjvIFy6kTgY4bfExWbDiSt)epzQr5KXilmCeq)W0fCHzNK6HjvIIUmY7WGVwLvwzCeq)W0ft8WzYWkNmsE5CKOOlJ8o8sZfIvHibRlVmCYpbXAiTrjNyUAvFwRGlm7KeNXvoj6dJvaM6ZAfCHzNK4mUYjXLHt2hgRGskQOY4iG(HPlM4HZKHvozK8Y5irrxg5DyWxR6ZAfCHzNK4mUYjrFySchblnxiwfIeCqYjMR8YWjXzCLtDLusR6ZAf1ZjzyL6HjvIFy6kTgY4bfExWbDiStN4HZKHvozK8Y5iJrwyQpRvWfMDsIZ4kNe9HXkCeS0CHyvisWbjNyUYldNeNXvo11QSYddr(iQNtYWk1dtQ0IJa6hMUOEojdRupmPsu0LrE)iy54VwCeq)W0fCHzNK6HjvIIUmY7WlnxiwfIetmx5LHt(jiwdPnkjRRKIkQSbome5JOEojdRupmPslocOFy6cUWSts9WKkrrxg5D4LMleRcrIjMR8YWj)eeRH0gLK1vsrfXra9dtxWfMDsQhMujk6YiVFeSC8xP1qgpOW7coOdHDkxy2jPEysLXilmLvghb0pmDXepCMmSYjJKxohjk6YiVdV0CHyvisW6YldN8tqSgsBuYjMRw1N1k4cZojXzCLtI(WyfGP(Swbxy2jjoJRCsCz4K9HXkOKIkQmocOFy6IjE4mzyLtgjVCosu0LrEhg81Q(Swbxy2jjoJRCs0hgRWrWsZfIvHibhKCI5kVmCsCgx5uxjL0Q(Swr9CsgwPEysL4hM(AiJhu4Dbh0HWoTEojdRupmPYyKfM6ZAf1ZjzyL6HjvIFy6AvwzCeq)W0ft8WzYWkNmsE5CKOOlJ8o8mi81Q(Swbxy2jjoJRCs0hgRam1N1k4cZojXzCLtIldNSpmwbLuurLXra9dtxmXdNjdRCYi5LZrIIUmY7WGVw1N1k4cZojXzCLtI(WyfocwAUqSkej4GKtmx5LHtIZ4kN6kPKwLXra9dtxWfMDsQhMujk6YiVdpnnOIk(j1N1kM4HZKHvozK8Y5iXtxP1qgpOW7coOdHDApdzhKNl1dtQmgzHHJa6hMUGlm7Kmkvrrxg5D4DEfv0ahgI8rWfMDsgL6AiJhu4Dbh0HWovVOo5ysgw5f5FJrwyQpRv8jEYuJYjXtx7NuFwRyIhotgw5KrYlNJepDTFs9zTIjE4mzyLtgjVCosu0LrE)iyQpRvOxuNCmjdR8I8V4YWj7dJvifGXdkCbxy2jPke3hbbhHFdjh0Lwdz8GcVl4Goe2PCHzNKQqCFmgzHP(SwXN4jtnkNepDTkR8WqKpII6HZoM0Y4bLMKKtxe1p6Cvsrfz8GstsYPlI6hDEL0QSbwpNSrLtcUWSts14QY1)s(OOIdx50iYigAYe64bEP(5vAnKXdk8UGd6qyN2F6u5rAEnKXdk8UGd6qyNYfMDsQYvX5KXilm1N1k4cZojXzCLtI(WyfGhmLz8GstsYPlI6PG1ujT1ZjBu5KGlm7KunUQC9VKpAhUYPrKrm0Kj0XZrP(5xdz8GcVl4Goe2PCHzNKQCvCozmYct9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFyScRHmEqH3fCqhc7uUWStYOungzHP(Swbxy2jjoJRCs0hgRam4VgY4bfExWbDiStDAYOso0vN6JXilmLlYwupJvHifv0ahewbKNRKw1N1k4cZojXzCLtI(WyfGP(Swbxy2jjoJRCsCz4K9HXkSgY4bfExWbDiSt5cZojVOEhbrDJrwyQpRvGHiUWCFqEUOigpARNt2OYjbxy2jjYTihnAOvzLhgI8rWxDiKfH5bfUwgpO0KKC6IO(rPwLuurgpO0KKC6IO(rNxP1qgpOW7coOdHDkxy2j5f17iiQBmYct9zTcmeXfM7dYZffX4r7WqKpcUWStscNfA)K6ZAft8WzYWkNmsE5CK4PRv5HHiFe8vhczryEqHROImEqPjj50fr9JsjkTgY4bfExWbDiSt5cZojVOEhbrDJrwyQpRvGHiUWCFqEUOigpAhgI8rWxDiKfH5bfUwgpO0KKC6IO(rN7AiJhu4Dbh0HWoLlm7KKGthk6OWngzHP(Swbxy2jjoJRCs0hgRWrQpRvWfMDsIZ4kNexgozFyScRHmEqH3fCqhc7uUWStscoDOOJc3yKfM6ZAfCHzNK4mUYjrFyScWuFwRGlm7KeNXvojUmCY(Wyf0QxuAzo(l0uWfMDsQYvX50AiJhu4Dbh0HWoLshyEqHBmYhQQN(irwyx2zHoEGhSuY5ng5dv1tFKO7L(iEiyAUgUgMsxWbxOOqd6GGwWRJ88fKxOoKglaHryiAbMOjBbSUybgqDAbOzbMOjBbtm3fetgvMOojwdz8GcVlWra9dtVdZwrFKEKMngzHvpNSrLtI8c1H0qIWimePfhb0pmDbxy2jPEysLOOlJ8o8sD4Rfhb0pmDXepCMmSYjJKxohjk6YiVdd(Avw9zTcUWStsCgx5KOpmwHJGLMleRcrIjMR8YWjXzCLtDTkR8WqKpI65KmSs9WKkT4iG(HPlQNtYWk1dtQefDzK3pcwo(Rfhb0pmDbxy2jPEysLOOlJ8o8sZfIvHiXeZvEz4KFcI1qAJsY6kPOIkBGddr(iQNtYWk1dtQ0IJa6hMUGlm7KupmPsu0LrEhEP5cXQqKyI5kVmCYpbXAiTrjzDLuurCeq)W0fCHzNK6HjvIIUmY7hblh)vsP1qgpOW7cCeq)W07hc7uBf9r6rA2yKfw9CYgvojYluhsdjcJWqKwCeq)W0fCHzNK6HjvIIUmY7WGVwLnWHHiFeKdHYZgYPVIkQ8WqKpcYHq5zd50x7LDwOJh4bl1aFLusRYkJJa6hMUyIhotgw5KrYlNJefDzK3HNMWxR6ZAfCHzNK4mUYjrFyScWuFwRGlm7KeNXvojUmCY(Wyfusrfvghb0pmDXepCMmSYjJKxohjk6YiVdd(AvFwRGlm7KeNXvoj6dJvag8vsjTQpRvupNKHvQhMuj(HPR9Yol0Xd8GLMleRcrcwxEro6(UYl7SuhpRHmEqH3f4iG(HP3pe2P2k6JAangJSWQNt2OYjXh1XiDiKZLgsCCVS)1IJa6hMUq9zTYpQJr6qiNlnK44Ez)lkI)AOv9zTIpQJr6qiNlnK44Ez)lTv0hXpmDTkR(Swbxy2jPEysL4hMUw1N1kQNtYWk1dtQe)W01(j1N1kM4HZKHvozK8Y5iXpmDL0IJa6hMUyIhotgw5KrYlNJefDzK3HbFTkR(Swbxy2jjoJRCs0hgRWrWsZfIvHiXeZvEz4K4mUYPUwLvEyiYhr9CsgwPEysLwCeq)W0f1ZjzyL6HjvIIUmY7hblh)1IJa6hMUGlm7KupmPsu0LrEhEP5cXQqKyI5kVmCYpbXAiTrjzDLuurLnWHHiFe1ZjzyL6HjvAXra9dtxWfMDsQhMujk6YiVdV0CHyvismXCLxgo5NGynK2OKSUskQiocOFy6cUWSts9WKkrrxg59JGLJ)kP0AiJhu4DbocOFy69dHDQfvKufI7JXilS65KnQCs8rDmshc5CPHeh3l7FT4iG(HPluFwR8J6yKoeY5sdjoUx2)II4VgAvFwR4J6yKoeY5sdjoUx2)slQiXpmDT6fLwMJ)cnf2k6JAanRHP0fKmiiOfygLcipFbHVGqFqx0bbpOW7lWg1cMmAbozUGuyCSXlq9nla)QI8bsJf86ipFbOzbHVa8FbO(cuPzOAbtg7lilG(ipFb2OwaRVGOwWRJ88fGMf0Hq5zdKglqLSrrlG1xdz8GcVlWra9dtVFiStVOQIQldRCI6s(ymYctFQ1Wu6csvitwJ(cEDAbxuvr1xGjAYwaRlwGbGDbtm3fG6lOi(RXc4(cmjiiJxWLvGwq)v0cMybyUplanlqLSrrlyI5kwdz8GcVlWra9dtVFiStVOQIQldRCI6s(ymYcZa1NslocOFy6IjE4mzyLtgjVCosu0LrEhg81Q(Swbxy2jjoJRCs0hgRWrWsZfIvHiXeZvEz4K4mUYPUwCeq)W0fCHzNK6HjvIIUmY7hblh)xdz8GcVlWra9dtVFiStVOQIQldRCI6s(ymYcZa1NslocOFy6cUWSts9WKkrrxg5DyWxRYg4WqKpcYHq5zd50xrfvEyiYhb5qO8SHC6R9Yol0Xd8GLAGVskPvzLXra9dtxmXdNjdRCYi5LZrIIUmY7WlnxiwfIeSU8YWj)eeRH0gLCI5Qv9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFySckPOIkJJa6hMUyIhotgw5KrYlNJefDzK3HbFTQpRvWfMDsIZ4kNe9HXkad(kPKw1N1kQNtYWk1dtQe)W01EzNf64bEWsZfIvHibRlVihDFx5LDwQJN1Wu6csvitwJ(cEDAbFINm1OCAbMOjBbSUybga2fmXCxaQVGI4VglG7lWKGGmEbxwbAb9xrlyIfG5(Sa0SavYgfTGjMRynKXdk8Uahb0pm9(HWo9t8KPgLtgJSWWra9dtxmXdNjdRCYi5LZrIIUmY7WGVw1N1k4cZojXzCLtI(WyfocwAUqSkejMyUYldNeNXvo11IJa6hMUGlm7KupmPsu0LrE)iy54)AiJhu4DbocOFy69dHD6N4jtnkNmgzHHJa6hMUGlm7KupmPsu0LrEhg81QSbome5JGCiuE2qo9vurLhgI8rqoekpBiN(AVSZcD8apyPg4RKsAvwzCeq)W0ft8WzYWkNmsE5CKOOlJ8o80e(AvFwRGlm7KeNXvoj6dJvaM6ZAfCHzNK4mUYjXLHt2hgRGskQOY4iG(HPlM4HZKHvozK8Y5irrxg5DyWxR6ZAfCHzNK4mUYjrFyScWGVskPv9zTI65KmSs9WKkXpmDTx2zHoEGhS0CHyvisW6YlYr33vEzNL64znmLUadOoTGUoxkSaKDbtm3fW(FbS(c4Iwq4la)xa7)fygUrZcuPf80xGnQfafEovlyYyFbtgTGld3c(eeRHXl4YkG88f0FfTatAbzCAAb8SaiI7ZcgZybCHzNwaoJRCQVa2)lyY4zbtm3fyYD3OzbgG41Nf860xSgY4bfExGJa6hME)qyNw8hX(i76CPGXilmCeq)W0ft8WzYWkNmsE5CKOOlJ8o8sZfIvHir1Lxgo5NGynK2OKtmxT4iG(HPl4cZoj1dtQefDzK3HxAUqSkejQU8YWj)eeRH0gLK11Q8WqKpI65KmSs9WKkTkJJa6hMUOEojdRupmPsu0LrE)icoc)gsoOlPOI4iG(HPlQNtYWk1dtQefDzK3HxAUqSkejQU8YWj)eeRH0gLScDLuurdCyiYhr9CsgwPEysLsAvFwRGlm7KeNXvoj6dJvaEgu7NuFwRyIhotgw5KrYlNJe)W01Q(Swr9CsgwPEysL4hMUw1N1k4cZoj1dtQe)W0xdtPlWaQtlORZLclWenzlG1xGzg5lqp6DKkejwGbGDbtm3fG6lOi(RXc4(cmjiiJxWLvGwq)v0cMybyUplanlqLSrrlyI5kwdz8GcVlWra9dtVFiStl(JyFKDDUuWyKfgocOFy6IjE4mzyLtgjVCosu0LrE)icoc)gsoOlPv9zTcUWStsCgx5KOpmwHJGLMleRcrIjMR8YWjXzCLtDT4iG(HPl4cZoj1dtQefDzK3pszcoc)gsoOlDiJhu4IjE4mzyLtgjVCosqWr43qYbDjLwdz8GcVlWra9dtVFiStl(JyFKDDUuWyKfgocOFy6cUWSts9WKkrrxg59Ji4i8Bi5GUKwLv2ahgI8rqoekpBiN(kQOYddr(iihcLNnKtFTx2zHoEGhSud8vsjTkRmocOFy6IjE4mzyLtgjVCosu0LrEhEP5cXQqKG1Lxgo5NGynK2OKtmxTQpRvWfMDsIZ4kNe9HXkat9zTcUWStsCgx5K4YWj7dJvqjfvuzCeq)W0ft8WzYWkNmsE5CKOOlJ8om4Rv9zTcUWStsCgx5KOpmwbyWxjL0Q(Swr9CsgwPEysL4hMU2l7SqhpWdwAUqSkejyD5f5O77kVSZsD8O0AykDbgqDAbtm3fyIMSfW6lazxaAmQVat0KH8fmz0cUmCl4tqSgIfyayxGhJXl41PfyIMSfuH(cq2fmz0cggI8zbO(cgwbYnEbS)xaAmQVat0KH8fmz0cUmCl4tqSgI1qgpOW7cCeq)W07hc70jE4mzyLtgjVCoYyKfM6ZAfCHzNK4mUYjrFySchblnxiwfIetmx5LHtIZ4kN6AXra9dtxWfMDsQhMujk6YiVFemcoc)gsoOlP9Yol0Xd8sZfIvHibRlVihDFx5LDwQJhTQpRvupNKHvQhMuj(HPVgY4bfExGJa6hME)qyNoXdNjdRCYi5LZrgJSWuFwRGlm7KeNXvoj6dJv4iyP5cXQqKyI5kVmCsCgx5ux7WqKpI65KmSs9WKkT4iG(HPlQNtYWk1dtQefDzK3pcgbhHFdjh0L0IJa6hMUGlm7KupmPsu0LrEhEP5cXQqKyI5kVmCYpbXAiTrjzDT4iG(HPl4cZoj1dtQefDzK3HNMgCnKXdk8Uahb0pm9(HWoDIhotgw5KrYlNJmgzHP(Swbxy2jjoJRCs0hgRWrWsZfIvHiXeZvEz4K4mUYPUwLnWHHiFe1ZjzyL6HjvkQiocOFy6I65KmSs9WKkrrxg5D4LMleRcrIjMR8YWj)eeRH0gLScDL0IJa6hMUGlm7KupmPsu0LrEhEP5cXQqKyI5kVmCYpbXAiTrjz91Wu6cmG60cy9fGSlyI5UauFbHVa8FbS)xGz4gnlqLwWtFb2Owau45uTGjJ9fmz0cUmCl4tqSggVGlRaYZxq)v0cMmEwGjTGmonTaYJxE2cUSZlG9)cMmEwWKrfTauFbEmlGHkI)ASaEb1ZPfe2fOhMuTGFy6I1qgpOW7cCeq)W07hc7uUWSts9WKkJrwy4iG(HPlM4HZKHvozK8Y5irrxg5D4LMleRcrcwxEz4KFcI1qAJsoXC1Q(Swbxy2jjoJRCs0hgRam1N1k4cZojXzCLtIldNSpmwbTQpRvupNKHvQhMuj(HPR9Yol0Xd8GLMleRcrcwxEro6(UYl7SuhpRHP0fya1PfuH(cq2fmXCxaQVGWxa(Va2)lWmCJMfOsl4PVaBulak8CQwWKX(cMmAbxgUf8jiwdJxWLva55lO)kAbtgv0cqD3Ozbmur8xJfWlOEoTGFy6lG9)cMmEwaRVaZWnAwGkHJlTaonJGyviAb)xH88fupNeRHmEqH3f4iG(HP3pe2P1ZjzyL6HjvgJSWuFwRGlm7KupmPs8dtxRY4iG(HPlM4HZKHvozK8Y5irrxg5D4LMleRcrIk0Lxgo5NGynK2OKtmxfvehb0pmDbxy2jPEysLOOlJ8(rWsZfIvHiXeZvEz4KFcI1qAJsY6kPv9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFyScAXra9dtxWfMDsQhMujk6YiVdpnn4AiJhu4DbocOFy69dHDApdzhKNl1dtQmgzHP(Swbxy2jPEysL4hMUwCeq)W0fCHzNK6HjvIPEKSOlJ8o8y8Gcx0Zq2b55s9WKkb(xAvFwROEojdRupmPs8dtxlocOFy6I65KmSs9WKkXupsw0LrEhEmEqHl6zi7G8CPEysLa)lTFs9zTIjE4mzyLtgjVCos8dtFnmLUadOoTa94UGjwq)G(i6GGwa7lGGBkEbS6cq(cMmAbob3SaCeq)W0xGjY)HPXl45quVVaf0OqSVGjJ8feoKgl4)kKNVaUWStlqpmPAb)hTGjwqwyUGl78cYEEEPXck(JyFwqxNlfwaQVgY4bfExGJa6hME)qyNQxuNCmjdR8I8VXilSHHiFe1ZjzyL6HjvAvFwRGlm7KupmPs801Q(Swr9CsgwPEysLOOlJ8(r54V4YWTgY4bfExGJa6hME)qyNQxuNCmjdR8I8VXilSpP(SwXepCMmSYjJKxohjE6A)K6ZAft8WzYWkNmsE5CKOOlJ8(rmEqHl4cZojVOEhbrDbbhHFdjh0L0AG4in5Spcf0OqSVgY4bfExGJa6hME)qyNQxuNCmjdR8I8VXilm1N1kQNtYWk1dtQepDTQpRvupNKHvQhMujk6YiVFuo(lUmCAXra9dtxqPdmpOWffXFn0IJa6hMUyIhotgw5KrYlNJefDzK31AG4in5Spcf0OqSVgUgY4bfExyrodjvFLFiSt5cZojVOEhbrDJrwyQpRvGHiUWCFqEUOigpgJZyKdtZ1qgpOW7clYziP6R8dHDkxy2jPke3N1qgpOW7clYziP6R8dHDkxy2jPkxfNtRHRHP0fCqMr(cQN7ipFbeAYOAbtgTGKKfe1co(GCbquo5FUqu34fyslWK9zbtSad40XcujBu0cMmAbhhtk80u9GxGjY)HPybgqDAbOzbCFb9i8fW9fCoIdEbzCFbwKJ6z0FbXRwGjzuAAbDDYNfeVAb4mUYP(AiJhu4DHf1ZqEUm0jNkyu6aZdkCJrwykxpNSrLtIosplCzFI6QOI1ZjBu5KyOREumK0KlDL0QS6ZAf1ZjzyL6HjvIFy6kQOErPL54Vqtbxy2jPkxfNtkPfhb0pmDr9CsgwPEysLOOlJ8(AykDbga2fysgLMwGf5OEg9xq8QfGJa6hM(cmr(pm7lG9)c66KpliE1cWzCLtDJxGEHIcnOdcAbgWPJfePPAbuAQ0yYqE(ciOoTgY4bfExyr9mKNldDYP6qyNsPdmpOWngzHnme5JOEojdRupmPslocOFy6I65KmSs9WKkrrxg5DT4iG(HPl4cZoj1dtQefDzK31Q(Swbxy2jPEysL4hMUw1N1kQNtYWk1dtQe)W01QxuAzo(l0uWfMDsQYvX50AiJhu4DHf1ZqEUm0jNQdHDQfvKufI7JXilS65KnQCs8rDmshc5CPHeh3l7FTQpRv8rDmshc5CPHeh3l7FPTI(iE6RHmEqH3fwupd55YqNCQoe2P2k6J0J0SXilS65KnQCsKxOoKgsegHHiTx2zHoEGxk58RHmEqH3fwupd55YqNCQoe2PFINm1OCYyKfMbwpNSrLtIosplCzFI6UgY4bfExyr9mKNldDYP6qyNYfMDsgLQXilmCeq)W0f1ZjzyL6HjvII4VgRHmEqH3fwupd55YqNCQoe2PCHzNKQqCFmgzHHJa6hMUOEojdRupmPsue)1qR6ZAfCHzNK4mUYjrFySchP(Swbxy2jjoJRCsCz4K9HXkSgY4bfExyr9mKNldDYP6qyNwpNKHvQhMuTgMsxWjrDziinwGjTaDgvlqpgu4l41PfyIMSfKQhSXlq9nlanlWebbTaiUplak88fqE8YZwGnQfOgt2cMmAbNJ4Gxa7)fKQh8cmr(pm7l45quVVG65oYZxWKrlijzbrTGJpixaeLt(Nle1xdz8GcVlSOEgYZLHo5uDiSt1JbfUXilmdu565KnQCs0r6zHl7tuxfvSEozJkNedD1JIHKMCPR0AiJhu4DHf1ZqEUm0jNQdHD6N4jtnkNmgzHP(Swr9CsgwPEysL4hMUIkQxuAzo(l0uWfMDsQYvX50AiJhu4DHf1ZqEUm0jNQdHDAXFe7JSRZLcgJSWuFwROEojdRupmPs8dtxrf1lkTmh)fAk4cZojv5Q4CAnKXdk8UWI6zipxg6Kt1HWo9IQkQUmSYjQl5JXilm1N1kQNtYWk1dtQe)W0vur9IslZXFHMcUWStsvUkoNwdXdk8UWI6zipxg6Kt1HWoDIhotgw5KrYlNJmgzHP(Swr9CsgwPEysL4hMUIkQxuAzo(l0uWfMDsQYvX5KIkQxuAzo(l0uCrvfvxgw5e1L8rrf1lkTmh)fAkk(JyFKDDUuqrf1lkTmh)fAk(epzQr50AiJhu4DHf1ZqEUm0jNQdHDkxy2jPEysLXilm9IslZXFHMIjE4mzyLtgjVCoAnmLUadOoTGdosHlyIf0pOpIoiOfW(ci4MIxqQwy2PfCge3Nf8FfYZxWKrl44ysHNMQh8cmr(pmxWZHOEFb1ZDKNVGuTWStlWagNfIfyayxqQwy2PfyaJZIfG6lyyiYh6B8cmPfGz3OzbVoTGdosHlWenziFbtgTGJJjfEAQEWlWe5)WCbphI69fysla5dv1tFwWKrlivtHlaNXUtqgVGESatYiiOf0500cqJynKXdk8UWI6zipxg6Kt1HWovVOo5ysgw5f5FJrwyg4WqKpcUWStscNfA)K6ZAft8WzYWkNmsE5CK4PR9tQpRvmXdNjdRCYi5LZrIIUmY7hbtzgpOWfCHzNKQqCFeeCe(nKCqxkfq9zTc9I6KJjzyLxK)fxgozFySckTgMsxGbGDbhCKcxqg3DJMfOsKVGxN(l4)kKNVGjJwWXXKcxGjY)HPXlWKmccAbVoTa0SGjwq)G(i6GGwa7lGGBkEbPAHzNwWzqCFwaYxWKrl4Ceh8PP6bVatK)dtXAiJhu4DHf1ZqEUm0jNQdHDQErDYXKmSYlY)gJSWuFwRGlm7KupmPs801Q(Swr9CsgwPEysLOOlJ8(rWuMXdkCbxy2jPke3hbbhHFdjh0LsbuFwRqVOo5ysgw5f5FXLHt2hgRGsRHmEqH3fwupd55YqNCQoe2PCHzNKQqCFmgzH9Jru8hX(i76CPGOOlJ8o8oVIk(j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwb4b)1Wu6coiPfyY(SGjwWLvGwq)v0cmPfKXPPfqE8YZwWLDEb2OwWKrlG8bv0cs1dEbMi)hMgVakn5lazxWKrfzuFb9bbbTGbDPfu0LroYZxq4l4CehSybgaJr9feoKglqLMHQfmXcuFLVGjwWbbvXcy)Vad40Xcq2fup3rE(cMmAbjjliQfC8b5cGOCY)CHOUynKXdk8UWI6zipxg6Kt1HWoLlm7KuLRIZjJrwy4iG(HPl4cZoj1dtQefXFn0EzNf645iLpx4FOYAc)uaCKMC2hHcAui2vsjTQpRvWfMDsIZ4kNe9HXkat9zTcUWStsCgx5K4YWj7dJvqRbwpNSrLtIosplCzFI6Q1aRNt2OYjXqx9OyiPjx6RHP0fya5quVVG65oYZxWKrlivlm70cmaZ1nCnwaeLt(NlnmEbNXvX50c6zXd6VapMfOsl41P)c4zbtgTaY)liSlivp4fGSlWaoDG5bf(cq9few7cWra9dtFbCFb)k01rE(cWzCLt9fyIGGwWLvGwaAwWWkqlak8CQwWelq9v(cMSkE5zlOOlJCKNVGl78AiJhu4DHf1ZqEUm0jNQdHDkxy2jPkxfNtgJSWuFwRGlm7KupmPs801Q(Swbxy2jPEysLOOlJ8(rWYXFTkxpNSrLtcUWStsKBroA0qrfXra9dtxqPdmpOWffDzK3vAnmLUGZ4Q4CAb9S4b9xadzYA0xGkTGjJwae3NfG5(SaKVGjJwW5io4fyI8FyUaUVGJJjfUatee0ckQprrlyYOfGZ4kN6lORt(SgY4bfExyr9mKNldDYP6qyNYfMDsQYvX5KXilm1N1kQNtYWk1dtQepDTQpRvWfMDsQhMuj(HPRv9zTI65KmSs9WKkrrxg59JGLJ)RHmEqH3fwupd55YqNCQoe2PCHzNKxuVJGOUXilSpP(SwXepCMmSYjJKxohjE6AhgI8rWfMDss4SqRYQpRv8jEYuJYjXpmDfvKXdknjjNUiQdttL0(j1N1kM4HZKHvozK8Y5irrxg5D4X4bfUGlm7K8I6Dee1feCe(nKCqxYyCgJCyAAmXfKgsCgJCjYct9zTcmeXfM7dYZL4m2Dcs8dtxRYQpRvWfMDsQhMujE6kQOYg4WqKpIinv6Hjv0xRYQpRvupNKHvQhMujE6kQiocOFy6ckDG5bfUOi(RHskP0AykDbPGCinwqF4AwWRJ88fKIP4cs1u4cmZiFbP6bVGmUVavI8f860FnKXdk8UWI6zipxg6Kt1HWoLlm7K8I6Dee1ngzHP(SwbgI4cZ9b55IIy8Ofhb0pmDbxy2jPEysLOOlJ8UwLvFwROEojdRupmPs80vur1N1k4cZoj1dtQepDLmgNXihMMRHmEqH3fwupd55YqNCQoe2PCHzNKrPAmYct9zTcUWStsCgx5KOpmwHJGLMleRcrIjMR8YWjXzCLt91qgpOW7clQNH8CzOtovhc7uUWStsviUpgJSWuFwROEojdRupmPs80vuXl7SqhpWtZZVgY4bfExyr9mKNldDYP6qyNsPdmpOWngzHP(Swr9CsgwPEysL4hMUw1N1k4cZoj1dtQe)W0ng5dv1tFKilSl7SqhpWdwQ98gJ8HQ6Pps09sFepemnxdz8GcVlSOEgYZLHo5uDiSt5cZojv5Q4CAnCnmLUagpOW7ImUUHRbmm7ycsY4bfUXilmgpOWfu6aZdkCboJDNGqEU2l7SqhpWdwk58RHP0fya1PfyaNoW8GcFbi7cmjJkAbqH5ccFbx25fW(Fb8cooMu4PP6bVatK)dZfG6lahxKNVGN(AiJhu4Drgx3W14qyNsPdmpOWngzHDzNf645iyAEET4iG(HPlM4HZKHvozK8Y5irrxg59JGPmbhHFdjh0LoKXdkCXepCMmSYjJKxohji4i8Bi5GUKsAXra9dtxWfMDsQhMujk6YiVFemLj4i8Bi5GU0HmEqHlM4HZKHvozK8Y5ibbhHFdjh0LoKXdkCbxy2jPEysLGGJWVHKd6skPv9zTI65KmSs9WKkXpmDTQpRvWfMDsQhMuj(HPR9tQpRvmXdNjdRCYi5LZrIFy6AnWFmII)i2hzxNlfefDzK3xdtPlWaQtlWaoDG5bf(cq2fysgv0cGcZfe(cUSZlG9)c4fCoIdEbMi)hMla1xaoUipFbp91qgpOW7ImUUHRXHWoLshyEqHBmYc7Yol0XZrWsD4Rfhb0pmDr9CsgwPEysLOOlJ8(rWuMGJWVHKd6shY4bfUOEojdRupmPsqWr43qYbDjL0IJa6hMUyIhotgw5KrYlNJefDzK3pcMYeCe(nKCqx6qgpOWf1ZjzyL6Hjvccoc)gsoOlDiJhu4II)i2hzxNlfeeCe(nKCqxsjT4iG(HPl4cZoj1dtQefDzK3H35c)1Wu6co7HG(lWamx3W1yb9HXk0xGnQfmz0cooMu4PP6bVatK)dZ1qgpOW7ImUUHRXHWoLlm7K8I6Dee1ngzHP(Swbxy2jzgx3W1q0hgRWrQpRvWfMDsMX1nCnexgozFyScAXra9dtxu8hX(i76CPGOOlJ8(rWu2GhQmbhHFdjh0LoKXdkCrXFe7JSRZLcccoc)gsoOlPKsAXra9dtxmXdNjdRCYi5LZrIIUmY7hbtzdEOYeCe(nKCqx6qgpOWff)rSpYUoxkii4i8Bi5GU0HmEqHlM4HZKHvozK8Y5ibbhHFdjh0LusjT4iG(HPl4cZoj1dtQefDzK3pcMYg8qLj4i8Bi5GU0HmEqHlk(JyFKDDUuqqWr43qYbDPdz8GcxmXdNjdRCYi5LZrccoc)gsoOlDiJhu4cUWSts9WKkbbhHFdjh0LusjJXzmYHP5AykDbN9qq)fyaMRB4ASG(Wyf6lWg1cMmAbNJ4GxGjY)H5AiJhu4Drgx3W14qyNYfMDsEr9ocI6gJSWuFwRGlm7KmJRB4Ai6dJv4i1N1k4cZojZ46gUgIldNSpmwbT4iG(HPlQNtYWk1dtQefDzK3pcMYg8qLj4i8Bi5GU0HmEqHlQNtYWk1dtQeeCe(nKCqxsjL0IJa6hMUO4pI9r215sbrrxg59JGPSbpuzcoc)gsoOlDiJhu4I65KmSs9WKkbbhHFdjh0LoKXdkCrXFe7JSRZLcccoc)gsoOlPKsAXra9dtxmXdNjdRCYi5LZrIIUmY7hbtzdEOYeCe(nKCqx6qgpOWf1ZjzyL6Hjvccoc)gsoOlDiJhu4II)i2hzxNlfeeCe(nKCqx6qgpOWft8WzYWkNmsE5CKGGJWVHKd6skPKwCeq)W0fCHzNK6HjvIIUmY7gJZyKdtZ1Wu6co7HG(lWamx3W1yb9HXk0xGnQfmz0cCwb6VGZrYcmr(pmxdz8GcVlY46gUghc7uUWStYlQ3rqu3yKfM6ZAfCHzNKzCDdxdrFySchP(Swbxy2jzgx3W1qCz4K9HXkOfhb0pmDrXFe7JSRZLcIIUmY7hbtzdEOYeCe(nKCqx6qgpOWff)rSpYUoxkii4i8Bi5GUKskPfhb0pmDbxy2jPEysLOOlJ8o8GL6WxlocOFy6I65KmSs9WKkrrxg5D4bl1HVX4mg5W0CnKXdk8UiJRB4ACiStl(JyFKDDUuWyKfM6ZAfCHzNKzCDdxdrFyScWuFwRGlm7KmJRB4AiUmCY(Wyf0IJa6hMUyIhotgw5KrYlNJefDzK3pIGJWVHKd6sAXra9dtxWfMDsQhMujk6YiVFemLj4i8Bi5GU0HmEqHlM4HZKHvozK8Y5ibbhHFdjh0Lus7LDwOJh4P55xdz8GcVlY46gUghc70jE4mzyLtgjVCoYyKfM6ZAfCHzNKzCDdxdrFyScWuFwRGlm7KmJRB4AiUmCY(Wyf0IJa6hMUGlm7KupmPsu0LrE)iyeCe(nKCqxs7pgrXFe7JSRZLcIIUmY7RHmEqH3fzCDdxJdHDkxy2jPEysLXilm1N1k4cZojZ46gUgI(WyfGP(Swbxy2jzgx3W1qCz4K9HXkO9tQpRvmXdNjdRCYi5LZrINUw1N1kQNtYWk1dtQe)W0xdz8GcVlY46gUghc7065KmSs9WKkJrwyQpRvWfMDsMX1nCne9HXkat9zTcUWStYmUUHRH4YWj7dJvqlocOFy6IjE4mzyLtgjVCosu0LrE)iyktWr43qYbDPdz8Gcxu8hX(i76CPGGGJWVHKd6skPfhb0pmDbxy2jPEysLOOlJ8o8ox4R9Yol0Xd8GL6NFnKXdk8UiJRB4ACiStl(JyFKDDUuWyKfM6ZAfCHzNKzCDdxdrFyScWuFwRGlm7KmJRB4AiUmCY(Wyf0IJa6hMUyIhotgw5KrYlNJefDzK3pIGJWVHKd6sAvFwROEojdRupmPs80xdz8GcVlY46gUghc70jE4mzyLtgjVCoYyKfM6ZAfCHzNKzCDdxdrFyScWuFwRGlm7KmJRB4AiUmCY(Wyf0IJa6hMUGlm7KupmPsu0LrEhENl81Q(Swr9CsgwPEysL4PR9hJO4pI9r215sbrrxg591qgpOW7ImUUHRXHWoTEojdRupmPYyKfgocOFy6IjE4mzyLtgjVCosu0LrEhEAcFT4iG(HPl4cZoj1dtQefDzK3HxQdFTQpRvWfMDsQhMuj(HPVgY4bfExKX1nCnoe2Pf)rSpYUoxkymYct9zTcUWStYmUUHRHOpmwbyQpRvWfMDsMX1nCnexgozFyScAXra9dtxWfMDsQhMujk6YiVdpyg88AXra9dtxupNKHvQhMujk6YiVdpyg88AvFwRGlm7KmJRB4Ai6dJvaM6ZAfCHzNKzCDdxdXLHt2hgRG2l7SqhpWdMMNFnmLUadOoTGdosHl4)kKNVGu9Gxqul4Ceh8cmr(pm7lyIfO(qq)fGZ4kN6lGTdvl41rE(cs1cZoTGZ4Q4CAnKXdk8UiJRB4ACiSt1lQtoMKHvEr(3yKfM6ZAfCHzNK4mUYjrFySchP(Swbxy2jjoJRCsCz4K9HXkOv9zTcUWStsCgx5KOpmwb4bFTQpRvWfMDsQhMujk6YiVROIQpRvWfMDsIZ4kNe9HXkCK6ZAfCHzNK4mUYjXLHt2hgRGw1N1k4cZojXzCLtI(WyfGh81Q(Swr9CsgwPEysLOOlJ8U2pP(SwXepCMmSYjJKxohjk6YiVVgY4bfExKX1nCnoe2PCHzNKQqCFmgzHP(SwHErDYXKmSYlY)IN(AiJhu4Drgx3W14qyNYfMDsgLQXilm1N1k4cZojXzCLtI(WyfoYGAvFwRGlm7KupmPs80xdz8GcVlY46gUghc7uUWStYOungzHP(Swbxy2jjoJRCs0hgRWrguRbQmocOFy6cUWSts9WKkrrxg59JGPj81IJa6hMUyIhotgw5KrYlNJefDzK3pcMMWxlocOFy6II)i2hzxNlfefDzK3pc25vAnKXdk8UiJRB4ACiSt5cZojVOEhbrDJrwyQpRvWfMDsIZ4kNe9HXkapn1Q(Swbxy2jzgx3W1q0hgRWrQpRvWfMDsMX1nCnexgozFyScgJZyKdtZ1qgpOW7ImUUHRXHWoLlm7K8I6Dee1ngzHHJa6hMUGlm7Kmkvrrxg59JoxTQpRvWfMDsMX1nCne9HXkCK6ZAfCHzNKzCDdxdXLHt2hgRGX4mg5W0CnKXdk8UiJRB4ACiSt5cZojv5Q4CYyKf2NuFwRO4pI9r215sbz6hKtfRIGqJgI(WyfGDURHmEqH3fzCDdxJdHDkxy2jPke3hJrwy)yef)rSpYUoxkik6YiVR9tQpRvmXdNjdRCYi5LZrIIUmY7WJGJWVHKd6sAv(tQpRvu8hX(i76CPGm9dYPIvrqOrdrFyScWGVIk(j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwHJoxLwdz8GcVlY46gUghc7uUWStYOungzH9Jru8hX(i76CPGOOlJ8o8oV2pP(SwrXFe7JSRZLcY0piNkwfbHgne9HXkad(AvFwROEojdRupmPs8dtFnKXdk8UiJRB4ACiSt5cZojvH4(ymYc7hJO4pI9r215sbrrxg5D4rWr43qYbDjTFs9zTII)i2hzxNlfKPFqovSkccnAi6dJvaEWx7NuFwRO4pI9r215sbz6hKtfRIGqJgI(Wyfo6C1Q(Swr9CsgwPEysL4hM(AiJhu4Drgx3W14qyNYfMDsQYvX5KXilm1N1k4cZojXzCLtI(WyfGP(Swbxy2jjoJRCsCz4K9HXkOv9zTcUWStYmUUHRHOpmwbyQpRvWfMDsMX1nCnexgozFyScRHmEqH3fzCDdxJdHDkLoW8Gc3yKf2LDwOJNJ088RHP0fCqMr(cuPXKiFb4iG(HPVatK)dZUXlWKwq4qASa1hc6VGjwG9bbTaCgx5uFbSDOAbVoYZxqQwy2PfKcQuxdz8GcVlY46gUghc7uUWStsviUpgJSWuFwRGlm7KeNXvoj6dJvaEAUgMsxGbW9sFepeKglORt(FbgG56gUglOpmwH(cmZiFbQ0ysKVaCeq)W0xGjY)HzFnKXdk8UiJRB4ACiSt5cZojv5Q4CYyKfM6ZAfCHzNKzCDdxdrFyScWd(RHmEqH3fzCDdxJdHDkxy2j5f17iiQBmoJromnxdxdz8GcVlUrA6s(CiStvHqUcs21WyKf2nstxYhXh1h2Xe8GPj8xdz8GcVlUrA6s(CiSt1lQtoMKHvEr(FnKXdk8U4gPPl5ZHWoLlm7K8I6Dee1ngzHDJ00L8r8r9HDmDKMWFnKXdk8U4gPPl5ZHWoLlm7Kmk11qgpOW7IBKMUKphc7ulQiPke3N1W1qgpOW7IqNCQGzrfjvH4(ymYcREozJkNeFuhJ0HqoxAiXX9Y(xR6ZAfFuhJ0HqoxAiXX9Y(xAROpIN(AiJhu4DrOtovhc7uBf9r6rA2yKfw9CYgvojYluhsdjcJWqK2l7SqhpWlLC(1qgpOW7IqNCQoe2PFINm1OCAnKXdk8Ui0jNQdHDAXFe7JSRZLcgJSWUSZcD8aVZf(RHmEqH3fHo5uDiSt7zi7G8CPEysLXilm1N1k4cZoj1dtQe)W01IJa6hMUGlm7KupmPsu0LrEFnKXdk8Ui0jNQdHD6fvvuDzyLtuxYN1qgpOW7IqNCQoe2Pt8WzYWkNmsE5C0AiJhu4DrOtovhc7uUWSts9WKQ1qgpOW7IqNCQoe2P1ZjzyL6HjvgJSWuFwROEojdRupmPs8dtFnmLUadOoTGdosHlyIf0pOpIoiOfW(ci4MIxqQwy2PfCge3Nf8FfYZxWKrl44ysHNMQh8cmr(pmxWZHOEFb1ZDKNVGuTWStlWagNfIfyayxqQwy2PfyaJZIfG6lyyiYh6B8cmPfGz3OzbVoTGdosHlWenziFbtgTGJJjfEAQEWlWe5)WCbphI69fysla5dv1tFwWKrlivtHlaNXUtqgVGESatYiiOf0500cqJynKXdk8Ui0jNQdHDQErDYXKmSYlY)gJSWmWHHiFeCHzNKeol0(j1N1kM4HZKHvozK8Y5iXtx7NuFwRyIhotgw5KrYlNJefDzK3pcMYmEqHl4cZojvH4(ii4i8Bi5GUukG6ZAf6f1jhtYWkVi)lUmCY(WyfuAnmLUada7co4ifUGmU7gnlqLiFbVo9xW)vipFbtgTGJJjfUatK)dtJxGjzee0cEDAbOzbtSG(b9r0bbTa2xab3u8cs1cZoTGZG4(SaKVGjJwW5io4tt1dEbMi)hMI1qgpOW7IqNCQoe2P6f1jhtYWkVi)BmYct9zTcUWSts9WKkXtxR6ZAf1ZjzyL6HjvIIUmY7hbtzgpOWfCHzNKQqCFeeCe(nKCqxkfq9zTc9I6KJjzyLxK)fxgozFySckX4bfExe6Kt1HWoLlm7KufI7JXilSFmII)i2hzxNlfefDzK3H35vuXpP(SwrXFe7JSRZLcY0piNkwfbHgne9HXkap4VgY4bfExe6Kt1HWoLlm7KufI7JXilm1N1k0lQtoMKHvEr(x801(j1N1kM4HZKHvozK8Y5iXtx7NuFwRyIhotgw5KrYlNJefDzK3pcgJhu4cUWStsviUpccoc)gsoOlTgMsxqQczYA0xWzCvCoTaEwWKrlG8)cc7cs1dEbMzKVG65oYZxWKrlivlm70cmaZ1nCnwaeLt(Nlnwdz8GcVlcDYP6qyNYfMDsQYvX5KXilm1N1k4cZoj1dtQepDTQpRvWfMDsQhMujk6YiVFuo(RTEozJkNeCHzNKi3IC0OXAykDbPkKjRrFbNXvX50c4zbtgTaY)liSlyYOfCoIdEbMi)hMlWmJ8fup3rE(cMmAbPAHzNwGbyUUHRXcGOCY)CPXAiJhu4DrOtovhc7uUWStsvUkoNmgzHP(Swr9CsgwPEysL4PRv9zTcUWSts9WKkXpmDTQpRvupNKHvQhMujk6YiVFeSC8xB9CYgvoj4cZojrUf5OrJ1qgpOW7IqNCQoe2PCHzNKxuVJGOUXilSpP(SwXepCMmSYjJKxohjE6AhgI8rWfMDss4SqRYQpRv8jEYuJYjXpmDfvKXdknjjNUiQdttL0(j1N1kM4HZKHvozK8Y5irrxg5D4X4bfUGlm7K8I6Dee1feCe(nKCqxYyCgJCyAAmXfKgsCgJCjYct9zTcmeXfM7dYZL4m2Dcs8dtxRYQpRvWfMDsQhMujE6kQOYg4WqKpIinv6Hjv0xRYQpRvupNKHvQhMujE6kQiocOFy6ckDG5bfUOi(RHskP0AiJhu4DrOtovhc7uUWStYlQ3rqu3yKfM6ZAfyiIlm3hKNlkIXJX4mg5W0CnKXdk8Ui0jNQdHDkxy2jzuQgJSWuFwRGlm7KeNXvoj6dJv4iyP5cXQqKyI5kVmCsCgx5uFnKXdk8Ui0jNQdHDkxy2jPke3hJrwyQpRvupNKHvQhMujE6kQ4LDwOJh4P55xdz8GcVlcDYP6qyNsPdmpOWngzHP(Swr9CsgwPEysL4hMUw1N1k4cZoj1dtQe)W0ng5dv1tFKilSl7SqhpWdwQ98gJ8HQ6Pps09sFepemnxdz8GcVlcDYP6qyNYfMDsQYvX50A4AykDbmEqH3fvm8Gc)qyNIzhtqsgpOWngzHX4bfUGshyEqHlWzS7eeYZ1EzNf64bEWsjNxRYgy9CYgvoj6i9SWL9jQRIkQ(SwrhPNfUSprDf9HXkat9zTIosplCzFI6kUmCY(WyfuAnKXdk8UOIHhu4hc7ukDG5bfUXilSl7SqhphblnxiwfIeu6qQJhTkJJa6hMUyIhotgw5KrYlNJefDzK3pcgJhu4ckDG5bfUGGJWVHKd6skQiocOFy6cUWSts9WKkrrxg59JGX4bfUGshyEqHli4i8Bi5GUKIkQ8WqKpI65KmSs9WKkT4iG(HPlQNtYWk1dtQefDzK3pcgJhu4ckDG5bfUGGJWVHKd6skPKw1N1kQNtYWk1dtQe)W01Q(Swbxy2jPEysL4hMU2pP(SwXepCMmSYjJKxohj(HPR1a1lkTmh)fAkM4HZKHvozK8Y5O1qgpOW7IkgEqHFiStP0bMhu4gJSWQNt2OYjrhPNfUSprD1IJa6hMUGlm7KupmPsu0LrE)iymEqHlO0bMhu4ccoc)gsoOlTgMsxWzCvCoTaKDbOXO(cg0LwWel41PfmXCxa7)fysliJttlyIybx21yb4mUYP(AiJhu4DrfdpOWpe2PCHzNKQCvCozmYcdhb0pmDXepCMmSYjJKxohjkI)AOvz1N1k4cZojXzCLtI(WyfGxAUqSkejMyUYldNeNXvo11IJa6hMUGlm7KupmPsu0LrE)iyeCe(nKCqxs7LDwOJh4LMleRcrcwxEro6(UYl7SuhpAvFwROEojdRupmPs8dtxP1qgpOW7IkgEqHFiSt5cZojv5Q4CYyKfgocOFy6IjE4mzyLtgjVCosue)1qRYQpRvWfMDsIZ4kNe9HXkaV0CHyvismXCLxgojoJRCQRDyiYhr9CsgwPEysLwCeq)W0f1ZjzyL6HjvIIUmY7hbJGJWVHKd6sAXra9dtxWfMDsQhMujk6YiVdV0CHyvismXCLxgo5NGynK2OKSUsRHmEqH3fvm8Gc)qyNYfMDsQYvX5KXilmCeq)W0ft8WzYWkNmsE5CKOi(RHwLvFwRGlm7KeNXvoj6dJvaEP5cXQqKyI5kVmCsCgx5uxRYg4WqKpI65KmSs9WKkfvehb0pmDr9CsgwPEysLOOlJ8o8sZfIvHiXeZvEz4KFcI1qAJswHUsAXra9dtxWfMDsQhMujk6YiVdV0CHyvismXCLxgo5NGynK2OKSUsRHmEqH3fvm8Gc)qyNYfMDsQYvX5KXilSpP(SwrXFe7JSRZLcY0piNkwfbHgne9HXka7tQpRvu8hX(i76CPGm9dYPIvrqOrdXLHt2hgRGwLvFwRGlm7KupmPs8dtxrfvFwRGlm7KupmPsu0LrE)iy54VsAvw9zTI65KmSs9WKkXpmDfvu9zTI65KmSs9WKkrrxg59JGLJ)kTgY4bfExuXWdk8dHDkxy2jPke3hJrwy)yef)rSpYUoxkik6YiVdVuRIkQ8NuFwRO4pI9r215sbz6hKtfRIGqJgI(WyfGh81(j1N1kk(JyFKDDUuqM(b5uXQii0OHOpmwHJ(K6ZAff)rSpYUoxkit)GCQyveeA0qCz4K9HXkO0AiJhu4DrfdpOWpe2PCHzNKQqCFmgzHP(SwHErDYXKmSYlY)INU2pP(SwXepCMmSYjJKxohjE6A)K6ZAft8WzYWkNmsE5CKOOlJ8(rWy8GcxWfMDsQcX9rqWr43qYbDP1qgpOW7IkgEqHFiSt5cZojVOEhbrDJrwyFs9zTIjE4mzyLtgjVCos801ome5JGlm7KKWzHwLvFwR4t8KPgLtIFy6kQiJhuAssoDruhMMkPv5pP(SwXepCMmSYjJKxohjk6YiVdpgpOWfCHzNKxuVJGOUGGJWVHKd6skQiocOFy6c9I6KJjzyLxK)ffDzK3vurCKMC2hHcAui2vYyCgJCyAAmXfKgsCgJCjYct9zTcmeXfM7dYZL4m2Dcs8dtxRYQpRvWfMDsQhMujE6kQOYg4WqKpIinv6Hjv0xRYQpRvupNKHvQhMujE6kQiocOFy6ckDG5bfUOi(RHskP0AiJhu4DrfdpOWpe2PCHzNKxuVJGOUXilm1N1kWqexyUpipxueJhTQpRvqWPZ(N(s9yiFqmK4PVgY4bfExuXWdk8dHDkxy2j5f17iiQBmYct9zTcmeXfM7dYZffX4rRYQpRvWfMDsQhMujE6kQO6ZAf1ZjzyL6HjvINUIk(j1N1kM4HZKHvozK8Y5irrxg5D4X4bfUGlm7K8I6Dee1feCe(nKCqxsjJXzmYHP5AiJhu4DrfdpOWpe2PCHzNKxuVJGOUXilm1N1kWqexyUpipxueJhTQpRvGHiUWCFqEUOpmwbyQpRvGHiUWCFqEU4YWj7dJvWyCgJCyAUgY4bfExuXWdk8dHDkxy2j5f17iiQBmYct9zTcmeXfM7dYZffX4rR6ZAfyiIlm3hKNlk6YiVFemLvw9zTcmeXfM7dYZf9HXkKcW4bfUGlm7K8I6Dee1feCe(nKCqxsPdZXFLmgNXihMMRHmEqH3fvm8Gc)qyN60KrLCORo1hJrwykxKTOEgRcrkQOboiScipxjTQpRvWfMDsIZ4kNe9HXkat9zTcUWStsCgx5K4YWj7dJvqR6ZAfCHzNK6HjvIFy6A)K6ZAft8WzYWkNmsE5CK4hM(AiJhu4DrfdpOWpe2PCHzNKrPAmYct9zTcUWStsCgx5KOpmwHJGLMleRcrIjMR8YWjXzCLt91qgpOW7IkgEqHFiSt7pDQ8inBmYc7Yol0XZrWsjNxR6ZAfCHzNK6HjvIFy6AvFwROEojdRupmPs8dtx7NuFwRyIhotgw5KrYlNJe)W0xdz8GcVlQy4bf(HWoLlm7KufI7JXilm1N1kQhejdRCYkI6INUw1N1k4cZojXzCLtI(WyfGxQVgY4bfExuXWdk8dHDkxy2jPkxfNtgJSWUSZcD8CeS0CHyvisOYvX5K8Yol1XJw1N1k4cZoj1dtQe)W01Q(Swr9CsgwPEysL4hMU2pP(SwXepCMmSYjJKxohj(HPRv9zTcUWStsCgx5KOpmwbyQpRvWfMDsIZ4kNexgozFyScAXra9dtxqPdmpOWffDzK3xdz8GcVlQy4bf(HWoLlm7KuLRIZjJrwyQpRvWfMDsQhMuj(HPRv9zTI65KmSs9WKkXpmDTFs9zTIjE4mzyLtgjVCos8dtxR6ZAfCHzNK4mUYjrFyScWuFwRGlm7KeNXvojUmCY(Wyf0ome5JGlm7KmkvT4iG(HPl4cZojJsvu0LrE)iy54V2l7SqhphblLaFT4iG(HPlO0bMhu4IIUmY7RHmEqH3fvm8Gc)qyNYfMDsQYvX5KXilm1N1k4cZoj1dtQepDTQpRvWfMDsQhMujk6YiVFeSC8xR6ZAfCHzNK4mUYjrFyScWuFwRGlm7KeNXvojUmCY(Wyf0QmocOFy6ckDG5bfUOOlJ8UIkwpNSrLtcUWStsKBroA0qP1qgpOW7IkgEqHFiSt5cZojv5Q4CYyKfM6ZAf1ZjzyL6HjvINUw1N1k4cZoj1dtQe)W01Q(Swr9CsgwPEysLOOlJ8(rWYXFTQpRvWfMDsIZ4kNe9HXkat9zTcUWStsCgx5K4YWj7dJvqRY4iG(HPlO0bMhu4IIUmY7kQy9CYgvoj4cZojrUf5OrdLwdz8GcVlQy4bf(HWoLlm7KuLRIZjJrwyQpRvWfMDsQhMuj(HPRv9zTI65KmSs9WKkXpmDTFs9zTIjE4mzyLtgjVCos801(j1N1kM4HZKHvozK8Y5irrxg59JGLJ)AvFwRGlm7KeNXvoj6dJvaM6ZAfCHzNK4mUYjXLHt2hgRWAiJhu4DrfdpOWpe2PCHzNKQCvCozmYcB4kNgrgXqtMqhphL6NxR6ZAfCHzNK4mUYjrFyScWdMYmEqPjj50fr9uWAQK265KnQCsWfMDsQgxvU(xYhTmEqPjj50frD4PPw1N1k(epzQr5K4hM(AiJhu4DrfdpOWpe2PCHzNKeC6qrhfUXilSHRCAezednzcD8CuQFETQpRvWfMDsIZ4kNe9HXkCK6ZAfCHzNK4mUYjXLHt2hgRG265KnQCsWfMDsQgxvU(xYhTmEqPjj50frD4PPw1N1k(epzQr5K4hM(AiJhu4DrfdpOWpe2PCHzNKQqCFwdz8GcVlQy4bf(HWoLshyEqHBmYct9zTI65KmSs9WKkXpmDTQpRvWfMDsQhMuj(HPR9tQpRvmXdNjdRCYi5LZrIFy6RHmEqH3fvm8Gc)qyNYfMDsQYvX5ulHFtwuTKe09bXdk8uSy70M20A]] )


end
