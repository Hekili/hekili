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


    spec:RegisterPack( "Arcane", 20210419, [[d000IgqikeEKOsvxsfPs1MifFIcAuuGtrk1QevQ8krfZII0TevfAxe(fjWWiHCmsulJIWZiHQPjQQ6AQizBQiL(MOQKXrHuDosO06OiY8ev5Ea1(ibDqrLYcbs9qkKCrvKIpQIujJKekoPksvRKc1lPiQMjfIUjfrzNaj)KcP0qfvvwQOQupLsnvvexLcP4RIQcgROs2Ru9xIgmOdJAXK0JHAYQYLr2SiFwfgTOCAiRwfPs51aXSbCBvA3u9BHHtQoUOQOLl55sz6kUUQA7uuFNsgVkQZtkz9QivmFsK9R0DL7N0TF8qDqzcfzcLvu(RSIvOSr3ek2tP4D7rlDQBRZyq4dQB78L625wHzN626Swab)6N0TBXVWu3oBg9MjPafCGMSVQahxf0q3papOWXfNgf0qxSc62QFeWC69UA3(Xd1bLjuKjuwr5VYkwHYgDty0nr(3TB6eUdQtRj62zO3J8UA3(rnC32KXh0cZTcZoTgNB6fcyHkRynDHMqrMq514148nDdZ0cnZfIvbibFLnD(UqKVWeBoQfgPf2Ozq(rtWxztNVl0aCgHbzHAf)AHnDcVWqFqH30wSgB00OfoAPJWmWcTrxJAHzS)aq(XcJ0cXzS7eWcr(qv91hu4le5TH43cJ0cneZoMaKmEqHBOOBdGAtRFs3oJRB4A1pPdkL7N0TjNvbOxh0DBgpOW72K5aZdk8U9JA4cPpOW72gnnAHNgZbMhu4leLwOfzyrleiSwy4l8YoVq2FlKx4jXyYuqULFl0c5VWAHO2cXXf5hl8R3TXfAOcXD7l7SqhplmpWlu5tTqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqdwiDMW)HKd6slmNfY4bfUyIpotgj5KrYlFGe0zc)hsoOlTqTxOMfIJa4fwUGlm7KupSOsu0LrEBH5bEHgSq6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAH5SqgpOWfCHzNK6Hfvc6mH)djh0LwO2luZcv)PKO(ojJKupSOs8clFHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fw(c1SqJyHVyef)qSpYMoxGik6YiV1NoOmr)KUn5Ska96GUBZ4bfE3MmhyEqH3TFudxi9bfE32OPrl80yoW8GcFHO0cTidlAHaH1cdFHx25fY(BH8cZ3r(TqlK)cRfIAlehxKFSWVE3gxOHke3TVSZcD8SW8aVqfxrluZcXra8clxuFNKrsQhwujk6YiVTW8aVqdwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0c1EHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHgSq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQ9c1SqCeaVWYfCHzNK6HfvIIUmYBluHlm)vuF6GsX7N0TjNvbOxh0DBCHgQqC3ghbWlSCrXpe7JSPZfiIIUmYBlmpWl0elm3TWd8BH5SqZCHyvasyYvms9IAdJbb5hYbDPfMZcPZe(pKCqxAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHM5cXQaKWKRyK6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWl0mxiwfGeMCfJuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCrXpe7JSPZfic6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAHAwO6pLeCHzNK4mUoirBymiluHlu5fQzHQ)usWfMDsIZ46GeTHXGSW8wy(Vqnl0iwio83hncUWSts9kEOdTeKZQa0RBZ4bfE3Mlm7KufGBtF6Gk)7N0TjNvbOxh0DBCHgQqC3ghbWlSCr9DsgjPEyrLOOlJ82cZd8cnXcZDl8a)wyol0mxiwfGeMCfJuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfQzH4iaEHLlk(HyFKnDUaru0LrEBH5bEHM5cXQaKWKRyK6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlQVtYij1dlQe0zc)hsoOlTqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqZCHyvasyYvms9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWf13jzKK6Hfvc6mH)djh0LwyolKXdkCrXpe7JSPZfic6mH)djh0LwOMfIJa4fwUGlm7KupSOsu0LrEBHAwO6pLeCHzNK4mUoirBymiluHlu5fQzHQ)usWfMDsIZ46GeTHXGSW8wy(Vqnl0iwio83hncUWSts9kEOdTeKZQa0RBZ4bfE3Mlm7KufGBtF6G6u9t62KZQa0Rd6UnUqdviUBJJa4fwUO4hI9r205cerrxg5TfMh4fAIfM7w4b(TWCwOzUqSkajm5kgPErTHXGG8d5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHGxOIROfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMZcvCfTW8aVqCeaVWYfCHzNK6HfvIIUmYBluZcXra8clxuFNKrsQhwujk6YiVTWCwOIROfMh4fIJa4fwUGlm7KupSOsu0LrEBHAwO6pLeCHzNK4mUoirBymiluHlu5fQzHQ)usWfMDsIZ46GeTHXGSW8wy(Vqnl0iwio83hncUWSts9kEOdTeKZQa0RBZ4bfE3Mlm7KufGBtF6G602pPBtoRcqVoO724cnuH4UnocGxy5IIFi2hztNlqefDzK3wyEGx4b(TWCwOzUqSkajm5kgPErTHXGG8d5GU0cZzH0zc)hsoOlTqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqZCHyvasyYvms9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfMh4fAMleRcqctUIrQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6slmNfY4bfUyIpotgj5KrYlFGe0zc)hsoOlTqnlu9NscUWStsCgxhKOnmgKfQWfQC3MXdk8Unxy2jPkxfFq9PdQ8v)KUn5Ska96GUBJl0qfI724iaEHLlQVtYij1dlQefDzK3wyEGx4b(TWCwOzUqSkajm5kgPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4I67Kmss9WIkbDMW)HKd6sluZcXra8clxu8dX(iB6CbIOOlJ82cZd8cnZfIvbiHjxXi1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHM5cXQaKWKRyK6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlQVtYij1dlQe0zc)hsoOlTWCwiJhu4IIFi2hztNlqe0zc)hsoOlTqnlehbWlSCbxy2jPEyrLOOlJ82c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYDBgpOW72CHzNKQCv8b1NoOm69t62KZQa0Rd6UnUqdviUBJJa4fwUO4hI9r205cerrxg5TfMh4fEGFlmNfAMleRcqctUIrQxuBymii)qoOlTqnlehbWlSCbxy2jPEyrLOOlJ82cvi4fQ4kAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5SqfxrlmpWlehbWlSCbxy2jPEyrLOOlJ82c1SqCeaVWYf13jzKK6HfvIIUmYBlmNfQ4kAH5bEH4iaEHLl4cZoj1dlQefDzK3wOMfQ(tjbxy2jjoJRds0ggdYcv4cvEHAwOrSqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8Unxy2jPkxfFq9PdkfB)KUn5Ska96GUB)OgUq6dk8UnO)iG3cvmCDdxRf2ggdsBHPOw4Krl8Kymzki3YVfAH8xy1TXfAOcXDB1Fkj4cZojZ46gUwI2WyqwyElu9NscUWStYmUUHRL4YNLTHXGSqnlehbWlSCrXpe7JSPZfiIIUmYBlmpWl0mxiwfGeMCfJuVO2Wyqq(HCqxAH5Sq6mH)djh0LwOMfIJa4fwUyIpotgj5KrYlFGefDzK3wyEGxOzUqSkajm5kgPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4IIFi2hztNlqe0zc)hsoOlTqnlehbWlSCbxy2jPEyrLOOlJ82cZd8cnZfIvbiHjxXi1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfMZcz8GcxmXhNjJKCYi5Lpqc6mH)djh0L624mg5DBL72mEqH3T5cZojVOwdbqT(0bLYkQFs3MCwfGEDq3TFudxi9bfE3g0FeWBHkgUUHR1cBdJbPTWuulCYOfMVJ8BHwi)fwDBCHgQqC3w9NscUWStYmUUHRLOnmgKfM3cv)PKGlm7KmJRB4AjU8zzBymiluZcXra8clxuFNKrsQhwujk6YiVTW8aVqZCHyvasyYvms9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWf13jzKK6Hfvc6mH)djh0LwOMfIJa4fwUO4hI9r205cerrxg5TfMh4fAMleRcqctUIrQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnZfIvbiHjxXi1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TUnoJrE3w5UnJhu4DBUWStYlQ1qauRpDqPSY9t62KZQa0Rd6U9JA4cPpOW72G(JaEluXW1nCTwyBymiTfMIAHtgTqNbHElmFBVqlK)cRUnUqdviUBR(tjbxy2jzgx3W1s0ggdYcZBHQ)usWfMDsMX1nCTex(SSnmgKfQzH4iaEHLlk(HyFKnDUaru0LrEBH5bEHM5cXQaKWKRyK6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHGxOIROfQzH4iaEHLlQVtYij1dlQefDzK3wOcbVqfxrluZcnIfId)9rJGlm7KuVIh6qlb5Ska9624mg5DBL72mEqH3T5cZojVOwdbqT(0bLYMOFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEl0eluZcv)PKGlm7KmJRB4AjAdJbzHGxO6pLeCHzNKzCDdxlXLplBdJbzHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5Tq6mH)djh0LwOMfIJa4fwUGlm7KupSOsu0LrEBH5bEHgSq6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAHAVqnl8Yol0XZcv4cv(uDBgpOW72f)qSpYMoxG0NoOuwX7N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfM3cnXc1Sq1Fkj4cZojZ46gUwI2Wyqwi4fQ(tjbxy2jzgx3W1sC5ZY2WyqwOMfIJa4fwUGlm7KupSOsu0LrEBH5bEH0zc)hsoOlTqnl8fJO4hI9r205cerrxg5TUnJhu4D7j(4mzKKtgjV8bQpDqPC(3pPBtoRcqVoO724cnuH4UT6pLeCHzNKzCDdxlrBymile8cv)PKGlm7KmJRB4AjU8zzBymiluZcFK6pLet8XzYijNmsE5dK4RVqnlu9NsI67Kmss9WIkXlS8UnJhu4DBUWSts9WIQ(0bLYNQFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEl0eluZcv)PKGlm7KmJRB4AjAdJbzHGxO6pLeCHzNKzCDdxlXLplBdJbzHAwiocGxy5IIFi2hztNlqefDzK3wyEGxiDMW)HKd6sluZcXra8clxmXhNjJKCYi5LpqIIUmYBlmpWl0GfsNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1EHAwiocGxy5cUWSts9WIkrrxg5TfQWfM)NAH5SqZCHyvasyYvmYhbWAbGUOrMB53c1SWl7SqhpluHGxOIFQUnJhu4D767Kmss9WIQ(0bLYN2(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5TqtSqnlu9NscUWStYmUUHRLOnmgKfcEHQ)usWfMDsMX1nCTex(SSnmgKfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfM3cPZe(pKCqxAHAwO6pLe13jzKK6HfvIVE3MXdk8UDXpe7JSPZfi9PdkLZx9t62KZQa0Rd6UnUqdviUBR(tjbxy2jzgx3W1s0ggdYcbVq1Fkj4cZojZ46gUwIlFw2ggdYc1Sq1FkjQVtYij1dlQeF9fQzHVyef)qSpYMoxGik6YiV1Tz8GcVBpXhNjJKCYi5Lpq9PdkLn69t62KZQa0Rd6UnUqdviUBBWcXra8clxmXhNjJKCYi5LpqIIUmYBlmNfM)NAHAVW8aVqCeaVWYfCHzNK6HfvIIUmYBluZcv)PKGlm7KupSOs8clFHAwOrSqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8UD9DsgjPEyrvF6GszfB)KUn5Ska96GUBJl0qfI72Q)usWfMDsMX1nCTeTHXGSqWlu9NscUWStYmUUHRL4YNLTHXGSqnlehbWlSCbxy2jPEyrLOOlJ82cvi4fQ4kAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5SqfxrlmpWlehbWlSCbxy2jPEyrLOOlJ82c1SqCeaVWYf13jzKK6HfvIIUmYBlmNfQ4kAH5bEH4iaEHLl4cZoj1dlQefDzK3wOMfEzNf64zHke8cv(uluZcnIfId)9rJGlm7KuVIh6qlb5Ska962mEqH3Tl(HyFKnDUaPpDqzcf1pPBtoRcqVoO724cnuH4U9lgrXpe7JSPZfiIIUmYBluHl8uluZcFK6pLef)qSpYMoxGin)bCQyveaA0s0ggdYcbVqfTqnlu9NsI67Kmss9WIkXlS8UnJhu4DBUWStYOu7thuMq5(jDBYzva61bD3gxOHke3TFK6pLef)qSpYMoxGin)bCQyveaA0s0ggdYcbVW8VBZ4bfE3Mlm7KuLRIpO(0bLjmr)KUn5Ska96GUBJl0qfI72Vyef)qSpYMoxGik6YiVTqnl8rQ)usmXhNjJKCYi5LpqIIUmYBluHlKot4)qYbDPfQzHgSWhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSqWlurlujLw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwyElm)xO2luZcnIfQxKz5b(juwWfMDsQYvXhu3MXdk8Unxy2jPka3M(0bLju8(jDBYzva61bD3gxOHke3TFXik(HyFKnDUaru0LrEBHkCH0zc)hsoOlTqnl8rQ)usu8dX(iB6CbI08hWPIvraOrlrBymiluHlurluZcFK6pLef)qSpYMoxGin)bCQyveaA0s0ggdYcZBH5)c1Sq1FkjQVtYij1dlQeVWY72mEqH3T5cZojvb420NoOmr(3pPBtoRcqVoO724cnuH4UT6pLeCHzNK4mUoirBymilmVfAIfQzHQ)usWfMDsQhwuj(6DBgpOW72CHzNKrP2NoOmXP6N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3gNXiVBRC3gxOHke3Tv)PKadqCH52G8drrmEwOMfQ(tjbxy2jPEyrL4R3NoOmXPTFs3MCwfGEDq3Tz8GcVBRxuJCmjJK8I8x3(rnCH0hu4DBJMgTW8lmzl89lKFSWCl)wyulmFh53cTq(lSAlCIfQ(raVfIZ46GAlKtdvl83q(XcZTcZoTqqZvXhu3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5Tq1Fkj4cZojXzCDqIlFw2ggdYc1Sq1Fkj4cZojXzCDqI2WyqwOcxOIwOMfQ(tjbxy2jPEyrLOOlJ82cvsPfQ(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzHQ)usWfMDsIZ46GeTHXGSqfUqfTqnlu9NsI67Kmss9WIkrrxg5TfQzHps9NsIj(4mzKKtgjV8bsu0LrERpDqzI8v)KUn5Ska96GUBJl0qfI72Q)usOxuJCmjJK8I8N4RVqnlu9NscUWStsCgxhKOnmgKfQWfQC3MXdk8Unxy2jPka3M(0bLjm69t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHMyHAwiocGxy5cUWSts9WIkrrxg5TfQqWl0ekAH5Jl0OVWC3cpWVfQzHgXcnyH4iaEHLlk(HyFKnDUaru0LrEBH5bEHkROfQzH4iaEHLl4cZoj1dlQefDzK3wOcbVW81PwO2DBgpOW72CHzNKrP2NoOmHITFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEl0eluZcXra8clxWfMDsQhwujk6YiVTqfcEHMqrlmFCHg9fM7w4b(Tqnleh(7Jgbxy2jPEfp0HwcYzva61Tz8GcVBZfMDsgLAF6GsXvu)KUn5Ska96GUBZ4bfE3Mlm7K8IAnea1624mg5DBL724cnuH4UT6pLeCHzNK4mUoirBymiluHlu5fQzHQ)usWfMDsMX1nCTeTHXGSW8wO6pLeCHzNKzCDdxlXLplBdJbPpDqP4k3pPBtoRcqVoO72mEqH3T5cZojVOwdbqTUnoJrE3w5UnUqdviUBJJa4fwUGlm7Kmkvrrxg5TfM3cZ)fQzHQ)usWfMDsMX1nCTeTHXGSW8wO6pLeCHzNKzCDdxlXLplBdJbPpDqP4MOFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfQ(tjbxy2jzgx3W1s0ggdYcbVq1Fkj4cZojZ46gUwIlFw2ggds3MXdk8Unxy2jPkxfFq9PdkfxX7N0TjNvbOxh0DBCHgQqC3(Yol0XZcZBHkFQUnJhu4DBYCG5bfEF6GsXZ)(jDBYzva61bD3MXdk8Unxy2jPka3MU9JA4cPpOW725dzKVqvASiYxiocGxy5l0c5VWQz6cTOfgoGwlu9JaElCIfM(aaleNX1b1wiNgQw4VH8JfMBfMDAHgTLA3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHkCHk3NoOu8t1pPBtoRcqVoO724mg5DBL72mEqH3T5cZojVOwdbqT(0NUDc1Yq(Hm0jNQ(jDqPC)KUn5Ska96GUBZ4bfE3MmhyEqH3TFudxi9bfE3oFiJ8fwF3r(Xcj0Kr1cNmAH22lmQfEs(WcbOdYFCHOMPl0IwOf7ZcNyHNgZXcvPuu0cNmAHNeJjtb5w(TqlK)clXcnAA0crZc52cBr4lKBlmFh53cZ42ctih1YO3cJFTqlYqZ0cB6Kplm(1cXzCDqTUnUqdviUBBWcRVtPOoirdPNfUSnrDfKZQa0BHkP0cRVtPOoiXqx9OyaPfx6cYzva6TqTxOMfAWcv)PKO(ojJKupSOs8clFHkP0c1lYS8a)ekl4cZojv5Q4dAHAVqnlehbWlSCr9DsgjPEyrLOOlJ8wF6GYe9t62KZQa0Rd6UnJhu4DBYCG5bfE3(rnCH0hu4D7tFAHwKHMPfMqoQLrVfg)AH4iaEHLVqlK)cR2cz)TWMo5ZcJFTqCgxhuZ0fQxOOqd60Hw4PXCSWWmvlKmtLwtgYpwib0OUnUqdviUBpma5JO(ojJKupSOsqoRcqVfQzH4iaEHLlQVtYij1dlQefDzK3wOMfIJa4fwUGlm7KupSOsu0LrEBHAwO6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAwOErMLh4Nqzbxy2jPkxfFq9PdkfVFs3MCwfGEDq3TXfAOcXD767ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfQ(tjXd1WiDaKZLwsCCVS)KPkAJ4R3Tz8GcVBNqfjvb420NoOY)(jDBYzva61bD3gxOHke3TRVtPOoiXrHAaAjryegGeKZQa0BHAw4LDwOJNfQWfQypv3MXdk8UDQI2i9Wm3NoOov)KUn5Ska96GUBJl0qfI72gXcRVtPOoirdPNfUSnrDfKZQa0BHAwOrSW67ukQdsm0vpkgqAXLUGCwfGEDBgpOW72pINm1OCQpDqDA7N0TjNvbOxh0DBCHgQqC3ghbWlSCr9DsgjPEyrLOi(Pv3MXdk8Unxy2jzuQ9PdQ8v)KUn5Ska96GUBJl0qfI724iaEHLlQVtYij1dlQefXpTwOMfQ(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStsvaUn9PdkJE)KUnJhu4D767Kmss9WIQUn5Ska96GUpDqPy7N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3(rnCH0hu4D7tFAHwKHfTqEw4LpVW2WyqAlmsl0OmQfY(BHw0cZyZKB4SWFJEl0KfNSqTOX0f(B0c5f2ggdYcNyH6fzM8zH3VJZq(r3gxOHke3Tv)PKadqCH52G8drrmEwOMfQ(tjbgG4cZTb5hI2Wyqwi4fQ(tjbgG4cZTb5hIlFw2ggdYc1SqCyMC2hHzYNmTQfQzH4iaEHLlUOQIQjJKCI6s(ikIFA1NoOuwr9t62KZQa0Rd6UnUqdviUBBel0GfwFNsrDqIgsplCzBI6kiNvbO3cvsPfwFNsrDqIHU6rXaslU0fKZQa0BHA3TFudxi9bfE3gurDzaaTwOfTqDgvlupgu4l83OfAHMSfMB5NPlu9plenl0cbaSqaUnlei8JfsE8pYwykQfQgt2cNmAH57i)wi7VfMB53cTq(lSAl87auRTW67oYpw4Krl02EHrTWtYhwiaDq(Jle162mEqH3T1JbfEF6GszL7N0TjNvbOxh0DBCHgQqC3w9NsI67Kmss9WIkXlS8fQKsluViZYd8tOSGlm7KuLRIpOUnJhu4D7hXtMAuo1NoOu2e9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4fw(cvsPfQxKz5b(juwWfMDsQYvXhu3MXdk8UDXpe7JSPZfi9PdkLv8(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clFHkP0c1lYS8a)ekl4cZojv5Q4dQBZ4bfE3(IQkQMmsYjQl5tF6Gs58VFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOskTq9ImlpWpHYcUWStsvUk(GwOskTq9ImlpWpHYIlQQOAYijNOUKplujLwOErMLh4NqzrXpe7JSPZfilujLwOErMLh4NqzXJ4jtnkN62mEqH3TN4JZKrsozK8YhO(0bLYNQFs3MCwfGEDq3TXfAOcXDB9ImlpWpHYIj(4mzKKtgjV8bQBZ4bfE3Mlm7KupSOQpDqP8PTFs3MCwfGEDq3Tz8GcVBRxuJCmjJK8I8x3(rnCH0hu4DBJMgTW8lmzlCIf2YNFIoDOfY(cPZtXlm3km70cbna3Mf((fYpw4Krl8Kymzki3YVfAH8xyTWVdqT2cRV7i)yH5wHzNw4PbNfIfE6tlm3km70cpn4SyHO2chgG8HEMUqlAHy2nCw4Vrlm)ct2cTqtgYx4Krl8Kymzki3YVfAH8xyTWVdqT2cTOfI8HQ6RplCYOfMBMSfIZy3jatxylwOfziaWcBSzAHOr0TXfAOcXDBJyHddq(i4cZojjCwiiNvbO3c1SWhP(tjXeFCMmsYjJKx(aj(6luZcFK6pLet8XzYijNmsE5dKOOlJ82cZd8cnyHmEqHl4cZojvb42iOZe(pKCqxAH5UfQ(tjHErnYXKmsYlYFIlFw2ggdYc1UpDqPC(QFs3MCwfGEDq3Tz8GcVBRxuJCmjJK8I8x3(rnCH0hu4D7tFAH5xyYwyg3CdNfQsKVWFJEl89lKFSWjJw4jXyYwOfYFHLPl0ImeayH)gTq0SWjwylF(j60Hwi7lKopfVWCRWStle0aCBwiYx4KrlmFh5NcYT8BHwi)fwIUnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NsI67Kmss9WIkrrxg5TfMh4fAWcz8GcxWfMDsQcWTrqNj8Fi5GU0cZDlu9Nsc9IAKJjzKKxK)ex(SSnmgKfQDF6GszJE)KUn5Ska96GUBJl0qfI72Vyef)qSpYMoxGik6YiVTqfUWtTqLuAHps9NsIIFi2hztNlqKM)aovSkcanAjAdJbzHkCHkQBZ4bfE3Mlm7KufGBtF6GszfB)KUn5Ska96GUBZ4bfE3Mlm7KuLRIpOU9JA4cPpOW725d0cTyFw4el8YGqlS9lAHw0cZyZ0cjp(hzl8YoVWuulCYOfs(GkAH5w(TqlK)cltxizM8fIslCYOImSTW2Gaaw4GU0cl6Yih5hlm8fMVJ8tSWt)yyBHHdO1cvPzOAHtSq1F5lCIfE6qvSq2Fl80yowikTW67oYpw4Krl02EHrTWtYhwiaDq(Jle1eDBCHgQqC3ghbWlSCbxy2jPEyrLOi(P1c1SWl7SqhplmVfAWcZFfTWCwObluzfTWC3cXHzYzFeGOvHyFHAVqTxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1SqJyH13PuuhKOH0Zcx2MOUcYzva6Tqnl0iwy9Dkf1bjg6QhfdiT4sxqoRcqV(0bLjuu)KUn5Ska96GUBZ4bfE3Mlm7KuLRIpOU9JA4cPpOW72gnoa1AlS(UJ8Jfoz0cZTcZoTqfdx3W1AHa0b5pU0Y0fcAUk(Gwyll(aVf6XSqvAH)g9wiplCYOfs(BHrAH5w(TquAHNgZbMhu4le1wyKslehbWlS8fYTf(Qqxh5hleNX1b1wOfcayHxgeAHOzHddcTqGWpOAHtSq1F5lCYQ4FKTWIUmYr(XcVSZDBCHgQqC3w9NscUWSts9WIkXxFHAwO6pLeCHzNK6HfvIIUmYBlmpWl8a)wOMfAWcRVtPOoibxy2jjYtihnAjiNvbO3cvsPfIJa4fwUGmhyEqHlk6YiVTqT7thuMq5(jDBYzva61bD3MXdk8Unxy2jPkxfFqD7h1WfsFqH3TbnxfFqlSLfFG3czalwR2cvPfoz0cb42Sqm3MfI8foz0cZ3r(TqlK)cRfYTfEsmMSfAHaawyrTjkAHtgTqCgxhuBHnDYNUnUqdviUBR(tjr9DsgjPEyrL4RVqnlu9NscUWSts9WIkXlS8fQzHQ)usuFNKrsQhwujk6YiVTW8aVWd8RpDqzct0pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPKbgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kPeocGxy5cYCG5bfUOi(PL2ARD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnlCyaYhbxy2jjHZcb5Ska9wOMfAWcv)PK4r8KPgLtIxy5lujLwiJhKzssoDruBHGxOYlu7fQzHps9NsIj(4mzKKtgjV8bsu0LrEBHkCHmEqHl4cZojVOwdbqnbDMW)HKd6sDBgpOW72CHzNKxuRHaOwF6GYekE)KUn5Ska96GUB)OgUq6dk8UTrRdO1cBdxZc)nKFSqJYOwyUzYwOvg5lm3YVfMXTfQsKVWFJEDBCHgQqC3w9NscmaXfMBdYpefX4zHAwiocGxy5cUWSts9WIkrrxg5TfQzHgSq1FkjQVtYij1dlQeF9fQKslu9NscUWSts9WIkXxFHA3TXzmY72k3Tz8GcVBZfMDsErTgcGA9PdktK)9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZd8cnZfIvbiXeZvE5ZsCgxhuRBZ4bfE3Mlm7Kmk1(0bLjov)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwuj(6lujLw4LDwOJNfQWfQ8P62mEqH3T5cZojvb420NoOmXPTFs3MCwfGEDq3Tz8GcVBtMdmpOW72iFOQ(6JeL62x2zHoEuiyJ(P62iFOQ(6JeDV0dXd1TvUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8(0bLjYx9t62mEqH3T5cZojv5Q4dQBtoRcqVoO7tF628v205B)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBZ4bfEtWxztNVGXSJjajJhu4MIsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk2t1TXfAOcXD7l7SqhplmpWl0mxiwfGeK5qQJNfQzHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqLuAH4iaEHLl4cZoj1dlQefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQKsl0Gfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLlQVtYij1dlQefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY7thuMOFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBle8cv0c1SqdwO6pLe13jzKK6HfvIxy5luZcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUlujLwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwO2lu7UnJhu4D7hXtMAuo1NoOu8(jDBYzva61bD3gxOHke3TXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHQ)usuFNKrsQhwujEHLVqnl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5UqLuAH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAVqT72mEqH3TVOQIQjJKCI6s(0NoOY)(jDBgpOW72f)qSpYMoxG0TjNvbOxh09PdQt1pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcXra8clxWfMDsQhwujM6tYIUmYBluHlKXdkCrldLgKFi1dlQe4xTqnlu9NsI67Kmss9WIkXlS8fQzH4iaEHLlQVtYij1dlQet9jzrxg5TfQWfY4bfUOLHsdYpK6Hfvc8RwOMf(i1FkjM4JZKrsozK8YhiXlS8UnJhu4D7wgkni)qQhwu1NoOoT9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4fw(c1SqCeaVWYfCHzNK6HfvIIUmYBDBgpOW7213jzKK6Hfv9PdQ8v)KUn5Ska96GUBJl0qfI72gSqCeaVWYfCHzNK6HfvIIUmYBle8cv0c1Sq1FkjQVtYij1dlQeVWYxO2lujLwOErMLh4Nqzr9DsgjPEyrv3MXdk8U9eFCMmsYjJKx(a1NoOm69t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7KupSOsu0LrEBH5TWtPOfQzHQ)usuFNKrsQhwujEHLVqnlKAnYXKWmQHcxgjPovjcpOWfKZQa0RBZ4bfE3EIpotgj5KrYlFG6thuk2(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clFHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjMB3MXdk8Unxy2jPEyrvF6Gszf1pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIV(c1Sq1Fkj4cZoj1dlQefDzK3wyEGxiJhu4cUWStYlQ1qautqNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2Wyq62mEqH3T5cZojv5Q4dQpDqPSY9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzHQ)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3Mlm7Kmk1(0bLYMOFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOMfQ(tjbxy2jPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStsvUk(G6thukR49t62KZQa0Rd6UnoJrE3w5UnXfGwsCgJCjk1Tv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUskP(tjr9DsgjPEyrL4RRKs4iaEHLliZbMhu4II4NwA3TXfAOcXDB1FkjWaexyUni)queJNUnJhu4DBUWStYlQ1qauRpDqPC(3pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPK6pLe13jzKK6HfvIVUskHJa4fwUGmhyEqHlkIFAPD3gxOHke3TnIfYNouHgsWfMDsQ)Vxca5hcYzva6TqLuAHQ)usGbiUWCBq(HeNXUtaIxy5DBgpOW72CHzNKxuRHaOwF6Gs5t1pPBtoRcqVoO724cnuH4UT6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY72mEqH3TjZbMhu49PdkLpT9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStYOu7thukNV6N0Tz8GcVBZfMDsQYvXhu3MCwfGEDq3NoOu2O3pPBZ4bfE3Mlm7KufGBt3MCwfGEDq3N(0TRy4bfE)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBZ4bfEtuXWdk8CaRam7ycqY4bfUPOeygpOWfK5aZdkCboJDNaq(HMl7SqhpkeSI9uAmWiQVtPOoirdPNfUSnrDvsj1FkjAi9SWLTjQROnmgeWQ)us0q6zHlBtuxXLplBdJbr7UnUqdviUBFzNf64zH5bEHM5cXQaKGmhsD8Sqnl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQKslehbWlSCbxy2jPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqLuAHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqTxO2luZcv)PKO(ojJKupSOs8clFHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fw(c1SqJyH6fzwEGFcLft8XzYijNmsE5duF6GYe9t62KZQa0Rd6UnUqdviUBxFNsrDqIgsplCzBI6kiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWlKXdkCbzoW8GcxqNj8Fi5GUu3MXdk8UnzoW8GcVpDqP49t62KZQa0Rd6UnJhu4DBUWStsvUk(G62pQHlK(GcVBdAUk(GwikTq0yyBHd6slCIf(B0cNyUlK93cTOfMXMPforSWl7ATqCgxhuRBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcXra8clxWfMDsQhwujk6YiVTW8aVq6mH)djh0LwOMfEzNf64zHkCHM5cXQaKG1LxKJU)R8Yol1XZc1Sq1FkjQVtYij1dlQeVWYxO29PdQ8VFs3MCwfGEDq3TXfAOcXDBCeaVWYft8XzYijNmsE5dKOi(P1c1SqdwO6pLeCHzNK4mUoirBymiluHl0mxiwfGetmx5LplXzCDqTfQzHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fsNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2DBgpOW72CHzNKQCv8b1NoOov)KUn5Ska96GUBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcnyHgXchgG8ruFNKrsQhwujiNvbO3cvsPfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKvOVqTxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1UBZ4bfE3Mlm7KuLRIpO(0b1PTFs3MCwfGEDq3TXfAOcXD7hP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSqWl8rQ)usu8dX(iB6CbI08hWPIvraOrlXLplBdJbzHAwOblu9NscUWSts9WIkXlS8fQKslu9NscUWSts9WIkrrxg5TfMh4fEGFlu7fQzHgSq1FkjQVtYij1dlQeVWYxOskTq1FkjQVtYij1dlQefDzK3wyEGx4b(TqT72mEqH3T5cZojv5Q4dQpDqLV6N0TjNvbOxh0DBCHgQqC3(fJO4hI9r205cerrxg5TfQWfA0xOskTqdw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwOcxOIwOMf(i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfM3cFK6pLef)qSpYMoxGin)bCQyveaA0sC5ZY2WyqwO2DBgpOW72CHzNKQaCB6thug9(jDBYzva61bD3gxOHke3Tv)PKqVOg5ysgj5f5pXxFHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHmEqHl4cZojvb42iOZe(pKCqxQBZ4bfE3Mlm7KufGBtF6GsX2pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPKbgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kPeocGxy5cYCG5bfUOi(PL2ARD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnlCyaYhbxy2jjHZcb5Ska9wOMfAWcv)PK4r8KPgLtIxy5lujLwiJhKzssoDruBHGxOYlu7fQzHgSWhP(tjXeFCMmsYjJKx(ajk6YiVTqfUqgpOWfCHzNKxuRHaOMGot4)qYbDPfQKslehbWlSCHErnYXKmsYlYFIIUmYBlujLwiomto7JaeTke7lu7UnJhu4DBUWStYlQ1qauRpDqPSI6N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAwO6pLe0zD2F0tQhd5dIbeF9UnJhu4DBUWStYlQ1qauRpDqPSY9t62KZQa0Rd6UnJhu4DBUWStYlQ1qauRBJZyK3TvUBJl0qfI72Q)usGbiUWCBq(HOigpluZcnyHQ)usWfMDsQhwuj(6lujLwO6pLe13jzKK6HfvIV(cvsPf(i1FkjM4JZKrsozK8Yhirrxg5TfQWfY4bfUGlm7K8IAnea1e0zc)hsoOlTqT7thukBI(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDB1FkjWaexyUni)queJNfQzHQ)usGbiUWCBq(HOnmgKfcEHQ)usGbiUWCBq(H4YNLTHXG0NoOuwX7N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3gNXiVBRC3gxOHke3Tv)PKadqCH52G8drrmEwOMfQ(tjbgG4cZTb5hIIUmYBlmpWl0GfAWcv)PKadqCH52G8drBymilm3TqgpOWfCHzNKxuRHaOMGot4)qYbDPfQ9cZzHh43c1UpDqPC(3pPBtoRcqVoO724cnuH4UTblSOurTmwfGwOskTqJyHdcdcYpwO2luZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UTttgvYHU6uB6thukFQ(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQ1Tz8GcVBZfMDsgLAF6Gs5tB)KUn5Ska96GUBJl0qfI72x2zHoEwyEGxOI9uluZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UD7RtLhM5(0bLY5R(jDBYzva61bD3gxOHke3Tv)PKO(aKmsYjRiQj(6luZcv)PKGlm7KeNX1bjAdJbzHkCHkE3MXdk8Unxy2jPka3M(0bLYg9(jDBYzva61bD3gxOHke3TVSZcD8SW8aVqZCHyvasOYvXhK8Yol1XZc1Sq1Fkj4cZoj1dlQeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQzH4iaEHLliZbMhu4IIUmYBDBgpOW72CHzNKQCv8b1NoOuwX2pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWYxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1SWHbiFeCHzNKrPkiNvbO3c1SqCeaVWYfCHzNKrPkk6YiVTW8aVWd8BHAw4LDwOJNfMh4fQyv0c1SqCeaVWYfK5aZdkCrrxg5TUnJhu4DBUWStsvUk(G6thuMqr9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NscUWSts9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkP0cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLjuUFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeF9fQzHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkP0cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLjmr)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs81xOMf(i1FkjM4JZKrsozK8Yhirrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KuLRIpO(0bLju8(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk(PwOMfQ(tjbxy2jjoJRds0ggdYcvi4fAWcz8GmtsYPlIAlmFCHkVqTxOMfwFNsrDqcUWSts14QY17s(iiNvbO3c1SqgpiZKKC6IO2cv4cvEHAwO6pLepINm1OCs8clVBZ4bfE3Mlm7KuLRIpO(0bLjY)(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk(PwOMfQ(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzH13PuuhKGlm7KunUQC9UKpcYzva6TqnlKXdYmjjNUiQTqfUqLxOMfQ(tjXJ4jtnkNeVWY72mEqH3T5cZojPZ6ardfEF6GYeNQFs3MXdk8Unxy2jPka3MUn5Ska96GUpDqzItB)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3MmhyEqH3NoOmr(QFs3MXdk8Unxy2jPkxfFqDBYzva61bDF6t3(gMPl5t)KoOuUFs3MCwfGEDq3TXfAOcXD7ByMUKpIhQnSJPfQqWluzf1Tz8GcVBRcGCq6thuMOFs3MXdk8UTErnYXKmsYlYFDBYzva61bDF6GsX7N0TjNvbOxh0DBCHgQqC3(gMPl5J4HAd7yAH5TqLvu3MXdk8Unxy2j5f1AiaQ1NoOY)(jDBgpOW72CHzNKrP2TjNvbOxh09PdQt1pPBZ4bfE3oHksQcWTPBtoRcqVoO7tF62pkXFGPFshuk3pPBZ4bfE3ghFFOQPtaaDBYzva61bDF6GYe9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62k3TXfAOcXDBZCHyvasKXMjzOto9wi4fQOfQzH6fzwEGFcLfK5aZdk8fQzHgXcnyH13PuuhKOH0Zcx2MOUcYzva6TqLuAH13PuuhKyOREumG0IlDb5Ska9wO2DBZCjD(sD7m2mjdDYPxF6GsX7N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TvUBJl0qfI72M5cXQaKiJntYqNC6TqWlurluZcv)PKGlm7KupSOs8clFHAwiocGxy5cUWSts9WIkrrxg5TfQzHgSW67ukQds0q6zHlBtuxb5Ska9wOskTW67ukQdsm0vpkgqAXLUGCwfGElu7UTzUKoFPUDgBMKHo50RpDqL)9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62k3TXfAOcXDB1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfAelu9NsI6dqYijNSIOM4RVqnlunATfQzHj0r2il6YiVTW8aVqdwObl8YoVqfSqgpOWfCHzNKQaCBe4Onlu7fM7wiJhu4cUWStsvaUnc6mH)djh0LwO2DBZCjD(sD7eYzaP6V8(0b1P6N0TjNvbOxh0DBCHgQqC32Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfMh4fA0v0c1SWl7SqhpluHGx4P9ulu7fQKsl0GfAelCyaYhb5aOJSHC6jiNvbO3c1SWl7SqhplmpWl0OFQfQD3MXdk8U9LDwEq3(0b1PTFs3MCwfGEDq3TXfAOcXDB1Fkj4cZoj1dlQeF9UnJhu4DB9yqH3NoOYx9t62KZQa0Rd6UnUqdviUBxFNsrDqIHU6rXaslU0fKZQa0BHAwO6pLe05m(3gu4IV(c1SqdwiocGxy5cUWSts9WIkrr8tRfQKslunATfQzHj0r2il6YiVTW8aVW8xrlu7UnJhu4D7bDjPfx69PdkJE)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3gaDKnn5PB)3XL8PpDqPy7N0TjNvbOxh0DBCHgQqC3w9NscUWSts9WIkXlS8fQzHQ)usuFNKrsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5DBgpOW72Q8HmsYPqyqA9PdkLvu)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwuj(6DBgpOW72Qu1OceKF0NoOuw5(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8172mEqH3TvbI4jt)sR(0bLYMOFs3MCwfGEDq3TXfAOcXDB1Fkj4cZoj1dlQeF9UnJhu4D7eQivGiE9PdkLv8(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8172mEqH3TzhtTPyajMba6thukN)9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4R3Tz8GcVB)BKen0T1NoOu(u9t62KZQa0Rd6UnJhu4D7da(H4jQMuLFhu3gxOHke3Tv)PKGlm7KupSOs81xOskTqCeaVWYfCHzNK6HfvIIUmYBluHGx4Po1c1SWhP(tjXeFCMmsYjJKx(aj(6DBkLi8iD(sD7da(H4jQMuLFhuF6Gs5tB)KUn5Ska96GUBZ4bfE3MU6AvediJ65SJPUnUqdviUBJJa4fwUGlm7KupSOsu0LrEBH5bEHgSqLv8fMZcZxlm3TqZCHyvasW6YWL)gTqT72oFPUnD11Qigqg1Zzht9PdkLZx9t62KZQa0Rd6UnJhu4D7xr8lHksAMAncOBJl0qfI724iaEHLl4cZoj1dlQefDzK3wOcbVqtOOfQKsl0iwOzUqSkajyDz4YFJwi4fQ8cvsPfAWch0Lwi4fQOfQzHM5cXQaKiHAzi)qg6Kt1cbVqLxOMfwFNsrDqIgsplCzBI6kiNvbO3c1UB78L62VI4xcvK0m1AeqF6GszJE)KUn5Ska96GUBZ4bfE3UfFaj6WrdvDBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cvi4fQ4kAHkP0cnIfAMleRcqcwxgU83OfcEHk3TD(sD7w8bKOdhnu1NoOuwX2pPBtoRcqVoO72mEqH3Tpa0sptgjj3AOlcGhu4DBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cvi4fAcfTqLuAHgXcnZfIvbibRldx(B0cbVqLxOskTqdw4GU0cbVqfTqnl0mxiwfGejuld5hYqNCQwi4fQ8c1SW67ukQds0q6zHlBtuxb5Ska9wO2DBNVu3(aql9mzKKCRHUiaEqH3NoOmHI6N0TjNvbOxh0DBgpOW72xgZQfjBzenY7VHWDBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cZd8cp1c1SqdwOrSqZCHyvasKqTmKFidDYPAHGxOYlujLw4GU0cv4cvCfTqT72oFPU9LXSArYwgrJ8(BiCF6GYek3pPBtoRcqVoO72mEqH3TVmMvls2YiAK3FdH724cnuH4UnocGxy5cUWSts9WIkrrxg5TfMh4fEQfQzHM5cXQaKiHAzi)qg6Kt1cbVqLxOMfQ(tjr9DsgjPEyrL4RVqnlu9NsI67Kmss9WIkrrxg5TfMh4fAWcvwrlmFCHNAH5UfwFNsrDqIgsplCzBI6kiNvbO3c1EHAw4GU0cZBHkUI62oFPU9LXSArYwgrJ8(BiCF6GYeMOFs3MCwfGEDq3TXfAOcXDBgpiZKKC6IO2cv4cnr3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1T5G6thuMqX7N0TjNvbOxh0DBCHgQqC3ghMjN9raIwfI9fQzH13PuuhKGlm7Ke5jKJgTeKZQa0BHAw4WaKpI67Kmss9WIkb5Ska962TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDgx3W1QpDqzI8VFs3MCwfGEDq3TFudxi9bfE3(KmAHjuld5hlm0jNQfQshiVTql0KTW8DKFlK93ctOwg1wykQfAug1c1Ra3w4el83Of((fYpw4jXyYuqULFDBgpOW72ygaqY4bfUea1MUDBkeE6Gs5UnUqdviUBBMleRcqIm2mjdDYP3cbVqfTqnl0mxiwfGejuld5hYqNCQ62aO2iD(sD7eQLH8dzOtov9PdktCQ(jDBYzva61bD3gxOHke3TnZfIvbirgBMKHo50BHGxOI62TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDOtov9PdktCA7N0TjNvbOxh0DBCHgQqC3UrZG8JMGVYMoFxi4fQC3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1T5RSPZ3(0bLjYx9t62KZQa0Rd6UnJhu4DBmdaiz8GcxcGAt3ga1gPZxQBJJa4fwERpDqzcJE)KUn5Ska96GUBJl0qfI72M5cXQaKiHCgqQ(lFHGxOI62TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDfdpOW7thuMqX2pPBtoRcqVoO724cnuH4UTzUqSkajsiNbKQ)Yxi4fQC3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1TtiNbKQ)Y7thukUI6N0TjNvbOxh0DBgpOW72ygaqY4bfUea1MUnaQnsNVu3(gMPl5tF6t3wViCCv5PFshuk3pPBZ4bfE3Mlm7Ke5dbaq4PBtoRcqVoO7thuMOFs3MXdk8UD7FVHl5cZojt8fbG4QBtoRcqVoO7thukE)KUnJhu4DBC4NU9lsEzNLh0TBtoRcqVoO7thu5F)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDB(kB68TB)Oe)bMUDJMb5hnbFLnD(2NoOov)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBYCi1Xt3(rj(dmDBLpvF6G602pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZL05l1T1ls)daijZr3gxOHke3TnyH13PuuhKOH0Zcx2MOUcYzva6TqnlKXdYmjjNUiQTqfUqLxyol0GfQ8cZDl0GfAelehMjN9r4eUcGOElu7fQ9c1UBBMb(KKaAu3wrDBZmWN62k3NoOYx9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZCjD(sD7m2mjdDYPx3gxOHke3TnyHmEqMjj50frTfQWfAIfQKsl0mxiwfGe6fP)baKK5yHGxOYlujLwOzUqSkaj4RSPZ3fcEHkVqT72MzGpjjGg1Tvu32md8PUTY9PdkJE)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUTI62M5s68L62jKZas1F59PdkfB)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBtUIr(iawla0fnYCl)62pkXFGPBR8P6thukRO(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62MCfJuVO2Wyqq(HCqxQB)Oe)bMUTITpDqPSY9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1Tn5kgPrB(g0POY32YhbWA1TFuI)at3wzf1NoOu2e9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TRM8YNLpcG1sMIsoXC72pkXFGPBFQ(0bLYkE)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7QjV8z5JayTKPOKvO3TFuI)at3(u9PdkLZ)(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62vtE5ZYhbWAjtrjz9U9Js8hy62Mqr9PdkLpv)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7Bms9IWe9KtmxPQwD7hL4pW0Tv8(0bLYN2(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L623yKx(S8raSwYuuYjMB3(rj(dmDBLvuF6Gs58v)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7BmYlFw(iawlzkkjR3TFuI)at3w5t1NoOu2O3pPBtoRcqVoO72HE3UOgnDBgpOW72M5cXQau32mxsNVu3M1Lx(S8raSwYuuYjMB3(rj(dmDBLvuF6GszfB)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBwxE5ZYhbWAjtrjVX0TFuI)at32ekQpDqzcf1pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBBcfTW8XfAWcp1cZDleh(7Jgbxy2jPEfp0HwcYzva6TqT72M5s68L62vOlV8z5JayTKPOKtm3(0bLjuUFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMb(u3(ulmNfQSIwyUBHgSqCyMC2hHJoYgzIPfQKsl0GfId)9rJGlm7KuVIh6qlb5Ska9wOMfY4bzMKKtxe1wyEluXxO2lu7fMZcv(ulm3Tqdwiomto7JaeTke7luZcRVtPOoibxy2jjYtihnAjiNvbO3c1SqgpiZKKC6IO2cv4cnXc1UBBMlPZxQBpXCLx(S8raSwYuuswVpDqzct0pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBBcfTW8XfAWcn6lm3TqC4VpAeCHzNK6v8qhAjiNvbO3c1UBBMlPZxQBpXCLx(S8raSwYuuYk07thuMqX7N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TpTkAH5Jl0GfE52qLwsZmWNwyUBHkRifTqT724cnuH4Unomto7JWrhzJmXu32mxsNVu3wLRIpi5LDwQJN(0bLjY)(jDBYzva61bD3o072nA62mEqH3TnZfIvbOUTzg4tDBf7Pwy(4cnyHxUnuPL0md8PfM7wOYksrlu7UnUqdviUBJdZKZ(iarRcXE32mxsNVu3wLRIpi5LDwQJN(0bLjov)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUTrxrlmFCHgSWl3gQ0sAMb(0cZDluzfPOfQD3gxOHke3TnZfIvbiHkxfFqYl7Suhple8cvu32mxsNVu3wLRIpi5LDwQJN(0bLjoT9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TzD5f5O7)kVSZsD80TFuI)at3w5t1NoOmr(QFs3MCwfGEDq3Td9UDrnA62mEqH3TnZfIvbOUTzUKoFPU9eZvE5ZsCgxhuRB)Oe)bMUTj6thuMWO3pPBtoRcqVoO72HE3UOgnDBgpOW72M5cXQau32mxsNVu3MdsoXCLx(SeNX1b162pkXFGPBBI(0bLjuS9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62kVWC3cnyHu(8J01PNGU6AvediJ65SJPfQKsl0Gfoma5JO(ojJKupSOsqoRcqVfQzHgSWHbiFeCHzNKeoleKZQa0BHkP0cnIfIdZKZ(iarRcX(c1EHAwObl0iwiomto7JWjCfar9wOskTqgpiZKKC6IO2cbVqLxOskTW67ukQds0q6zHlBtuxb5Ska9wO2lu7fQD32mxsNVu3oHAzi)qg6KtvF6GsXvu)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUnLp)iDD6jUmMvls2YiAK3FdHxOskTqkF(r660tCaWpepr1KQ87GwOskTqkF(r660tCaWpepr1Kx6XaaOWxOskTqkF(r660t84cKBeU8ryqK6)POgMCmTqLuAHu(8J01PNa5nC9hwfGK5Zp7Z)kFKzeMwOskTqkF(r660t0IpaandYpK1xvRfQKslKYNFKUo9eTVRceXtYxAY0QnlujLwiLp)iDD6jSyqiNQMmvH)wOskTqkF(r660tKa4ljJKuLNbG62M5s68L62SUmC5Vr9Pdkfx5(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62CqYjMR8YNL4mUoOw3(rj(dmDBt0NoOuCt0pPBtoRcqVoO72HE3UOgnDBgpOW72M5cXQau32mxsNVu3MmhsD80TFuI)at3w5t1NoOuCfVFs3MXdk8U9fvvus0LpOUn5Ska96GUpDqP45F)KUn5Ska96GUBJl0qfI72gXcnZfIvbiHEr6Faajzowi4fQ8c1SW67ukQds8qnmsha5CPLeh3l7pb5Ska962mEqH3Ttv0g1ay6thuk(P6N0TjNvbOxh0DBCHgQqC32iwOzUqSkaj0ls)daijZXcbVqLxOMfAelS(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVUnJhu4DBUWStsvaUn9Pdkf)02pPBtoRcqVoO724cnuH4UTzUqSkaj0ls)daijZXcbVqL72mEqH3TjZbMhu49PpDBCeaVWYB9t6Gs5(jDBYzva61bD3MXdk8UDQI2i9Wm3TFudxi9bfE3o)kuuObD6ql83q(XcpkudqRfIWimaTql0KTqwxSqJMgTq0Sql0KTWjM7cJjJkluJeDBCHgQqC3U(oLI6GehfQbOLeHryasqoRcqVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOIROfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAwOblu9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQKsl0GfAelCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqLuAH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO29Pdkt0pPBtoRcqVoO724cnuH4UD9Dkf1bjokudqljcJWaKGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHgXchgG8rqoa6iBiNEcYzva6TqLuAHgSWHbiFeKdGoYgYPNGCwfGEluZcVSZcD8SqfcEH5lfTqTxO2luZcnyHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cv4cvwrluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqLuAHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnlu9NscUWStsCgxhKOnmgKfcEHkAHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1SWl7SqhpluHGxOzUqSkajyD5f5O7)kVSZsD80Tz8GcVBNQOnspmZ9PdkfVFs3MCwfGEDq3TXfAOcXD767ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfIJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFATqnlu9NsIhQHr6aiNlTK44Ez)jtv0gXlS8fQzHgSq1Fkj4cZoj1dlQeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqTxOMfIJa4fwUyIpotgj5KrYlFGefDzK3wi4fQOfQzHgSq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GAluZcnyHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cpWVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqTxOskTqdwOrSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9cvsPfIJa4fwUGlm7KupSOsu0LrEBH5bEHh43c1EHA3Tz8GcVBNQOnQbW0NoOY)(jDBYzva61bD3gxOHke3TRVtPOoiXd1WiDaKZLwsCCVS)eKZQa0BHAwiocGxy5c1FkjFOggPdGCU0sIJ7L9NOi(P1c1Sq1FkjEOggPdGCU0sIJ7L9NmHks8clFHAwOErMLh4NqzrQI2Ogat3MXdk8UDcvKufGBtF6G6u9t62KZQa0Rd6UnJhu4D7lQQOAYijNOUKpD7h1WfsFqH3TZpgvl0KfNSql0KTWCl)wikTq0yyBH44I8Jf(1xylcxSWtFAHOzHwiaGfQsl83O3cTqt2cpjgtMPleZTzHOzHna0r2aO1cvPuuu3gxOHke3TXra8clxmXhNjJKCYi5LpqIIUmYBlmVfAMleRcqIBms9IWe9KtmxPQwlujLwOblehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXng5LplFeaRLmfLK1xOMfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajUXiV8z5JayTKPOKtm3fQDF6G602pPBtoRcqVoO724cnuH4UnocGxy5cUWSts9WIkrr8tRfQzHgSqJyHddq(iihaDKnKtpb5Ska9wOskTqdw4WaKpcYbqhzd50tqoRcqVfQzHx2zHoEwOcbVW8LIwO2lu7fQzHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzHGxOIwO2lu7fQzHQ)usuFNKrsQhwujEHLVqnl8Yol0XZcvi4fAMleRcqcwxEro6(VYl7SuhpDBgpOW72xuvr1KrsorDjF6thu5R(jDBYzva61bD3MXdk8U9J4jtnkN62pQHlK(GcVBNBawSwTf(B0cFepzQr50cTqt2czDXcp9PfoXCxiQTWI4NwlKBl0IaamDHxgeAHTFrlCIfI52Sq0SqvkffTWjMROBJl0qfI724iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAwO6pLeCHzNK4mUoirBymilmpWl0mxiwfGetmx5LplXzCDqTfQzH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(1NoOm69t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7KupSOsu0LrEBHGxOIwOMfAWcnIfoma5JGCa0r2qo9eKZQa0BHkP0cnyHddq(iihaDKnKtpb5Ska9wOMfEzNf64zHke8cZxkAHAVqTxOMfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfQSIwOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1EHkP0cnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAwO6pLeCHzNK4mUoirBymile8cv0c1EHAVqnlu9NsI67Kmss9WIkXlS8fQzHx2zHoEwOcbVqZCHyvasW6YlYr3)vEzNL64PBZ4bfE3(r8KPgLt9PdkfB)KUn5Ska96GUBZ4bfE3U4hI9r205cKU9JA4cPpOW72gnnAHnDUazHO0cNyUlK93cz9fYfTWWxi(Tq2Fl0kCdNfQsl8RVWuulei8dQw4KX(cNmAHx(8cFeaRLPl8YGG8Jf2(fTqlAHzSzAH8SqaIBZchRyHCHzNwioJRdQTq2FlCY4zHtm3fAXn3WzHNU9BZc)n6j624cnuH4UnocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKOAYlFw(iawlzkk5eZDHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIQjV8z5JayTKPOKS(c1Sqdw4WaKpI67Kmss9WIkb5Ska9wOMfAWcXra8clxuFNKrsQhwujk6YiVTW8wiDMW)HKd6slujLwiocGxy5I67Kmss9WIkrrxg5TfQWfAMleRcqIQjV8z5JayTKPOKvOVqTxOskTqJyHddq(iQVtYij1dlQeKZQa0BHAVqnlu9NscUWStsCgxhKOnmgKfQWfAIfQzHps9NsIj(4mzKKtgjV8bs8clFHAwO6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clVpDqPSI6N0TjNvbOxh0DBgpOW72f)qSpYMoxG0TFudxi9bfE32OPrlSPZfil0cnzlK1xOvg5lupAnKkajw4PpTWjM7crTfwe)0AHCBHweaGPl8YGqlS9lAHtSqm3MfIMfQsPOOfoXCfDBCHgQqC3ghbWlSCXeFCMmsYjJKx(ajk6YiVTW8wiDMW)HKd6sluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQTqnlehbWlSCbxy2jPEyrLOOlJ82cZBHgSq6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAHA3NoOuw5(jDBYzva61bD3gxOHke3TXra8clxWfMDsQhwujk6YiVTW8wiDMW)HKd6sluZcnyHgSqJyHddq(iihaDKnKtpb5Ska9wOskTqdw4WaKpcYbqhzd50tqoRcqVfQzHx2zHoEwOcbVW8LIwO2lu7fQzHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzHGxOIwO2lu7fQzHQ)usuFNKrsQhwujEHLVqnl8Yol0XZcvi4fAMleRcqcwxEro6(VYl7Suhplu7UnJhu4D7IFi2hztNlq6thukBI(jDBYzva61bD3MXdk8U9eFCMmsYjJKx(a1TFudxi9bfE32OPrlCI5Uql0KTqwFHO0crJHTfAHMmKVWjJw4LpVWhbWAjw4PpTqpgtx4Vrl0cnzlSc9fIslCYOfoma5ZcrTfomiKB6cz)Tq0yyBHwOjd5lCYOfE5Zl8raSwIUnUqdviUBR(tjbxy2jjoJRds0ggdYcZd8cnZfIvbiXeZvE5ZsCgxhuBHAwiocGxy5cUWSts9WIkrrxg5TfMh4fsNj8Fi5GU0c1SWl7SqhpluHl0mxiwfGeSU8IC09FLx2zPoEwOMfQ(tjr9DsgjPEyrL4fwEF6GszfVFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GAluZchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWlKot4)qYbDPfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqnlehbWlSCbxy2jPEyrLOOlJ82cv4cv2eDBgpOW72t8XzYijNmsE5duF6Gs58VFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GAluZcnyHgXchgG8ruFNKrsQhwujiNvbO3cvsPfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKvOVqTxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKSE3MXdk8U9eFCMmsYjJKx(a1NoOu(u9t62KZQa0Rd6UnJhu4DBUWSts9WIQU9JA4cPpOW72gnnAHS(crPfoXCxiQTWWxi(Tq2Fl0kCdNfQsl8RVWuulei8dQw4KX(cNmAHx(8cFeaRLPl8YGG8Jf2(fTWjJNfArlmJntlK84FKTWl78cz)TWjJNfozurle1wOhZczGI4NwlKxy9DAHrAH6Hfvl8fwUOBJl0qfI724iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUluZcnyHgXcXHzYzFeMjFY0QwOskTqCeaVWYfxuvr1KrsorDjFefDzK3wOcxOzUqSkajyD5LplFeaRLmfL8gZc1EHAwO6pLeCHzNK4mUoirBymile8cv)PKGlm7KeNX1bjU8zzBymiluZcv)PKO(ojJKupSOs8clFHAw4LDwOJNfQqWl0mxiwfGeSU8IC09FLx2zPoE6thukFA7N0TjNvbOxh0DBgpOW7213jzKK6HfvD7h1WfsFqH3TnAA0cRqFHO0cNyUle1wy4le)wi7VfAfUHZcvPf(1xykQfce(bvlCYyFHtgTWlFEHpcG1Y0fEzqq(XcB)Iw4KrfTquZnCwidue)0AH8cRVtl8fw(cz)TWjJNfY6l0kCdNfQs44slKnZiawfGw47xi)yH13jr3gxOHke3Tv)PKGlm7KupSOs8clFHAwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqfUqZCHyvasuHU8YNLpcG1sMIsoXCxOskTqCeaVWYfCHzNK6HfvIIUmYBlmpWl0mxiwfGetmx5LplFeaRLmfLK1xO2luZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwiocGxy5cUWSts9WIkrrxg5TfQWfQSj6thukNV6N0TjNvbOxh0DBCHgQqC3w9NscUWSts9WIkXlS8fQzH4iaEHLl4cZoj1dlQet9jzrxg5TfQWfY4bfUOLHsdYpK6Hfvc8RwOMfQ(tjr9DsgjPEyrL4fw(c1SqCeaVWYf13jzKK6HfvIP(KSOlJ82cv4cz8Gcx0YqPb5hs9WIkb(vluZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UDldLgKFi1dlQ6thukB07N0TjNvbOxh0DBgpOW726f1ihtYijVi)1TFudxi9bfE32OPrlupUlCIf2YNFIoDOfY(cPZtXlKvxiYx4Krl0PZZcXra8clFHwi)fwMUWVdqT2cbrRcX(cNmYxy4aATW3Vq(Xc5cZoTq9WIQf((0cNyHzH1cVSZlm77hLwlS4hI9zHnDUazHOw3gxOHke3ThgG8ruFNKrsQhwujiNvbO3c1Sq1Fkj4cZoj1dlQeF9fQzHQ)usuFNKrsQhwujk6YiVTW8w4b(jU85(0bLYk2(jDBYzva61bD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnl8rQ)usmXhNjJKCYi5LpqIIUmYBlmVfY4bfUGlm7K8IAnea1e0zc)hsoOlTqnl0iwiomto7JaeTke7DBgpOW726f1ihtYijVi)1NoOmHI6N0TjNvbOxh0DBCHgQqC3w9NsI67Kmss9WIkXxFHAwO6pLe13jzKK6HfvIIUmYBlmVfEGFIlFEHAwiocGxy5cYCG5bfUOi(P1c1SqCeaVWYft8XzYijNmsE5dKOOlJ82c1SqJyH4Wm5Spcq0QqS3Tz8GcVBRxuJCmjJK8I8xF6t3MdQFshuk3pPBtoRcqVoO724cnuH4UD9Dkf1bjEOggPdGCU0sIJ7L9NGCwfGEluZcXra8clxO(tj5d1WiDaKZLwsCCVS)efXpTwOMfQ(tjXd1WiDaKZLwsCCVS)KPkAJ4fw(c1SqdwO6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWYxO2luZcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1SqdwO6pLeCHzNK4mUoirBymilmpWl0mxiwfGeCqYjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQKsl0GfAelCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqLuAH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO2DBgpOW72PkAJAam9Pdkt0pPBtoRcqVoO724cnuH4UTblS(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVfQzH4iaEHLlu)PK8HAyKoaY5sljoUx2FII4NwluZcv)PK4HAyKoaY5sljoUx2FYeQiXlS8fQzH6fzwEGFcLfPkAJAamlu7fQKsl0GfwFNsrDqIhQHr6aiNlTK44Ez)jiNvbO3c1SWbDPfM3cvEHA3Tz8GcVBNqfjvb420NoOu8(jDBYzva61bD3gxOHke3TRVtPOoiXrHAaAjryegGeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfQ4kAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfAWcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wOMfAWcnyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fEGFluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqLuAHgSqJyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQKslehbWlSCbxy2jPEyrLOOlJ82cZd8cpWVfQ9c1UBZ4bfE3ovrBKEyM7thu5F)KUn5Ska96GUBJl0qfI7213PuuhK4OqnaTKimcdqcYzva6TqnlehbWlSCbxy2jPEyrLOOlJ82cbVqfTqnl0GfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqLuAHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1UBZ4bfE3ovrBKEyM7thuNQFs3MCwfGEDq3TXfAOcXD767ukQds0q6zHlBtuxb5Ska9wOMfQxKz5b(juwqMdmpOW72mEqH3TN4JZKrsozK8YhO(0b1PTFs3MCwfGEDq3TXfAOcXD767ukQds0q6zHlBtuxb5Ska9wOMfAWc1lYS8a)ekliZbMhu4lujLwOErMLh4NqzXeFCMmsYjJKx(aTqT72mEqH3T5cZoj1dlQ6thu5R(jDBYzva61bD3gxOHke3Th0LwOcxOIROfQzH13PuuhKOH0Zcx2MOUcYzva6Tqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfIJa4fwUGlm7KupSOsu0LrEBH5bEHh4x3MXdk8UnzoW8GcVpDqz07N0TjNvbOxh0DBgpOW72K5aZdk8UnYhQQV(irPUT6pLenKEw4Y2e1v0ggdcy1FkjAi9SWLTjQR4YNLTHXG0Tr(qv91hj6EPhIhQBRC3gxOHke3Th0LwOcxOIROfQzH13PuuhKOH0Zcx2MOUcYzva6TqnlehbWlSCbxy2jPEyrLOOlJ82cbVqfTqnl0GfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqLuAHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1UpDqPy7N0TjNvbOxh0DBCHgQqC32GfIJa4fwUGlm7KupSOsu0LrEBHkCH5)PwOskTqCeaVWYfCHzNK6HfvIIUmYBlmpWluXxO2luZcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1SqdwO6pLeCHzNK4mUoirBymilmpWl0mxiwfGeCqYjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfEQfQ9cvsPfAWcnIfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLl4cZoj1dlQefDzK3wOcx4PwO2lujLwiocGxy5cUWSts9WIkrrxg5TfMh4fEGFlu7fQD3MXdk8U9fvvunzKKtuxYN(0bLYkQFs3MCwfGEDq3TXfAOcXDBCeaVWYft8XzYijNmsE5dKOOlJ82cZBH0zc)hsoOlTqnl0GfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbibhKCI5kV8zjoJRdQTqnl0GfAWchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWl8a)wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkP0cnyHgXchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lujLwiocGxy5cUWSts9WIkrrxg5TfMh4fEGFlu7fQD3MXdk8UDXpe7JSPZfi9PdkLvUFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBlmVfsNj8Fi5GU0c1SqdwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvsPfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQ9c1EHAwO6pLe13jzKK6HfvIxy5lu7UnJhu4D7IFi2hztNlq6thukBI(jDBYzva61bD3gxOHke3TXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wO2lu7fQzHQ)usuFNKrsQhwujEHLVqT72mEqH3TFepzQr5uF6GszfVFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQzHgSqdw4WaKpI67Kmss9WIkb5Ska9wOMfIJa4fwUO(ojJKupSOsu0LrEBH5bEHh43c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lujLwObl0iw4WaKpI67Kmss9WIkb5Ska9wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkP0cXra8clxWfMDsQhwujk6YiVTW8aVWd8BHA3Tz8GcVBpXhNjJKCYi5Lpq9PdkLZ)(jDBYzva61bD3gxOHke3TnyHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cv4cnZfIvbibRlV8z5JayTKPOKtm3fQzHQ)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXGSqTxOskTqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbibhKCI5kV8zjoJRdQTqTxO2luZcv)PKO(ojJKupSOs8clVBZ4bfE3Mlm7KupSOQpDqP8P6N0TjNvbOxh0DBCHgQqC3w9NsI67Kmss9WIkXlS8fQzHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHMqrluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqLuAHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAVqTxOMfAWcXra8clxWfMDsQhwujk6YiVTqfUqLnXcvsPf(i1FkjM4JZKrsozK8YhiXxFHA3Tz8GcVBxFNKrsQhwu1NoOu(02pPBtoRcqVoO724cnuH4UnocGxy5cUWStYOuffDzK3wOcx4PwOskTqJyHddq(i4cZojJsvqoRcqVUnJhu4D7wgkni)qQhwu1NoOuoF1pPBtoRcqVoO724cnuH4UT6pLepINm1OCs81xOMf(i1FkjM4JZKrsozK8YhiXxFHAw4Ju)PKyIpotgj5KrYlFGefDzK3wyEGxO6pLe6f1ihtYijVi)jU8zzBymilm3TqgpOWfCHzNKQaCBe0zc)hsoOlTqnl0GfAWchgG8ruulC2XKGCwfGEluZcz8GmtsYPlIAlmVfM)lu7fQKslKXdYmjjNUiQTW8w4PwO2luZcnyHgXcRVtPOoibxy2jPACv56DjFeKZQa0BHkP0chUoOrKrmWKj0XZcv4cv8tTqT72mEqH3T1lQroMKrsEr(RpDqPSrVFs3MCwfGEDq3TXfAOcXDB1FkjEepzQr5K4RVqnl0GfAWchgG8ruulC2XKGCwfGEluZcz8GmtsYPlIAlmVfM)lu7fQKslKXdYmjjNUiQTW8w4PwO2luZcnyHgXcRVtPOoibxy2jPACv56DjFeKZQa0BHkP0chUoOrKrmWKj0XZcv4cv8tTqT72mEqH3T5cZojvb420NoOuwX2pPBZ4bfE3U91PYdZC3MCwfGEDq3NoOmHI6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfQqWl0GfY4bzMKKtxe1wy(4cvEHAVqnlS(oLI6GeCHzNKQXvLR3L8rqoRcqVfQzHdxh0iYigyYe64zH5Tqf)uDBgpOW72CHzNKQCv8b1NoOmHY9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggds3MXdk8Unxy2jPkxfFq9PdktyI(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHGxOI62mEqH3T5cZojJsTpDqzcfVFs3MCwfGEDq3TXfAOcXDBdwyrPIAzSkaTqLuAHgXchegeKFSqTxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggds3MXdk8UTttgvYHU6uB6thuMi)7N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAwy9Dkf1bj4cZojrEc5Orlb5Ska9wOMfAWcnyHddq(i4RoakHW8GcxqoRcqVfQzHmEqMjj50frTfM3cn6lu7fQKslKXdYmjjNUiQTW8w4PwO2DBgpOW72CHzNKxuRHaOwF6GYeNQFs3MCwfGEDq3TXfAOcXDB1FkjWaexyUni)queJNfQzHddq(i4cZojjCwiiNvbO3c1SWhP(tjXeFCMmsYjJKx(aj(6luZcnyHddq(i4RoakHW8GcxqoRcqVfQKslKXdYmjjNUiQTW8wOIDHA3Tz8GcVBZfMDsErTgcGA9PdktCA7N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAw4WaKpc(QdGsimpOWfKZQa0BHAwiJhKzssoDruBH5TW8VBZ4bfE3Mlm7K8IAnea16thuMiF1pPBtoRcqVoO724cnuH4UT6pLeCHzNK4mUoirBymilmVfQ(tjbxy2jjoJRdsC5ZY2Wyq62mEqH3T5cZojPZ6ardfEF6GYeg9(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOErMLh4Nqzbxy2jPkxfFqDBgpOW72CHzNK0zDGOHcVpDqzcfB)KUnYhQQV(irPU9LDwOJhfcwXEQUnYhQQV(ir3l9q8qDBL72mEqH3TjZbMhu4DBYzva61bDF6t3o0jNQ(jDqPC)KUn5Ska96GUBJl0qfI7213PuuhK4HAyKoaY5sljoUx2FcYzva6Tqnlu9NsIhQHr6aiNlTK44Ez)jtv0gXxVBZ4bfE3oHksQcWTPpDqzI(jDBYzva61bD3gxOHke3TRVtPOoiXrHAaAjryegGeKZQa0BHAw4LDwOJNfQWfQypv3MXdk8UDQI2i9Wm3NoOu8(jDBgpOW72pINm1OCQBtoRcqVoO7thu5F)KUn5Ska96GUBJl0qfI72x2zHoEwOcxy(ROUnJhu4D7IFi2hztNlq6thuNQFs3MCwfGEDq3TXfAOcXDB1Fkj4cZoj1dlQeVWYxOMfIJa4fwUGlm7KupSOsu0LrERBZ4bfE3ULHsdYpK6Hfv9PdQtB)KUnJhu4D7lQQOAYijNOUKpDBYzva61bDF6GkF1pPBZ4bfE3EIpotgj5KrYlFG62KZQa0Rd6(0bLrVFs3MXdk8Unxy2jPEyrv3MCwfGEDq3NoOuS9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4fwE3MXdk8UD9DsgjPEyrvF6Gszf1pPBtoRcqVoO72mEqH3T1lQroMKrsEr(RB)OgUq6dk8UTrtJwy(fMSfoXcB5ZprNo0czFH05P4fMBfMDAHGgGBZcF)c5hlCYOfEsmMmfKB53cTq(lSw43bOwBH13DKFSWCRWStl80GZcXcp9PfMBfMDAHNgCwSquBHddq(qptxOfTqm7gol83OfMFHjBHwOjd5lCYOfEsmMmfKB53cTq(lSw43bOwBHw0cr(qv91Nfoz0cZnt2cXzS7eGPlSfl0ImeayHn2mTq0i624cnuH4UTrSWHbiFeCHzNKeoleKZQa0BHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHgSqgpOWfCHzNKQaCBe0zc)hsoOlTWC3cv)PKqVOg5ysgj5f5pXLplBdJbzHA3NoOuw5(jDBYzva61bD3MXdk8UTErnYXKmsYlYFD7h1WfsFqH3Tp9PfMFHjBHzCZnCwOkr(c)n6TW3Vq(XcNmAHNeJjBHwi)fwMUqlYqaGf(B0crZcNyHT85NOthAHSVq68u8cZTcZoTqqdWTzHiFHtgTW8DKFki3YVfAH8xyj624cnuH4U9lgrXpe7JSPZfiIIUmYBluHl8ulujLw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwOcxOI6thukBI(jDBYzva61bD3gxOHke3Tv)PKqVOg5ysgj5f5pXxFHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHmEqHl4cZojvb42iOZe(pKCqxQBZ4bfE3Mlm7KufGBtF6GszfVFs3MCwfGEDq3Tz8GcVBZfMDsQYvXhu3(rnCH0hu4D7CdWI1QTqqZvXh0c5zHtgTqYFlmslm3YVfALr(cRV7i)yHtgTWCRWStluXW1nCTwiaDq(JlT624cnuH4UT6pLeCHzNK6HfvIV(c1Sq1Fkj4cZoj1dlQefDzK3wyEl8a)wOMfwFNsrDqcUWStsKNqoA0sqoRcqV(0bLY5F)KUn5Ska96GUBZ4bfE3Mlm7KuLRIpOU9JA4cPpOW725gGfRvBHGMRIpOfYZcNmAHK)wyKw4KrlmFh53cTq(lSwOvg5lS(UJ8Jfoz0cZTcZoTqfdx3W1AHa0b5pU0QBJl0qfI72Q)usuFNKrsQhwuj(6luZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIIUmYBlmpWl8a)wOMfwFNsrDqcUWStsKNqoA0sqoRcqV(0bLYNQFs3MCwfGEDq3TXzmY72k3TjUa0sIZyKlrPUT6pLeyaIlm3gKFiXzS7eG4fwUgdu)PKGlm7KupSOs81vsjdmIHbiFeHzQ0dlQONgdu)PKO(ojJKupSOs81vsjCeaVWYfK5aZdkCrr8tlT1w7UnUqdviUB)i1FkjM4JZKrsozK8YhiXxFHAw4WaKpcUWStscNfcYzva6Tqnl0GfQ(tjXJ4jtnkNeVWYxOskTqgpiZKKC6IO2cbVqLxO2luZcFK6pLet8XzYijNmsE5dKOOlJ82cv4cz8GcxWfMDsErTgcGAc6mH)djh0L62mEqH3T5cZojVOwdbqT(0bLYN2(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDB1FkjWaexyUni)queJN(0bLY5R(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQ1Tz8GcVBZfMDsgLAF6GszJE)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwuj(6lujLw4LDwOJNfQWfQ8P62mEqH3T5cZojvb420NoOuwX2pPBtoRcqVoO72mEqH3TjZbMhu4DBKpuvF9rIsD7l7SqhpkeSr)uDBKpuvF9rIUx6H4H62k3TXfAOcXDB1FkjQVtYij1dlQeVWYxOMfQ(tjbxy2jPEyrL4fwEF6GYekQFs3MXdk8Unxy2jPkxfFqDBYzva61bDF6t3oHCgqQ(lVFshuk3pPBtoRcqVoO72mEqH3T5cZojVOwdbqTUnoJrE3w5UnUqdviUBR(tjbgG4cZTb5hIIy80NoOmr)KUnJhu4DBUWStsvaUnDBYzva61bDF6GsX7N0Tz8GcVBZfMDsQYvXhu3MCwfGEDq3N(0NUTzQAOW7GYekYekRO8xzfVBBXLJ8Jw3oFi3Y3G60dQtxM0cx4jz0crx9OMfMIAHgMX1nCTmCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqf3KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTW83KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTWtzsl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOr3KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqLv2KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqLn6M0cnQWnt1qVfAio83hnICz4cNyHgId)9rJixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQSI1KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqtOynPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJxJZhYT8nOo9G60LjTWfEsgTq0vpQzHPOwOHjuld5hYqNCQmCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgyIZAlwJnsKtl0eM0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtluXnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfM)M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cpLjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTWtzsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQSImPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgyIZAlwJnsKtlu5tRjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I1yJe50cvwXAsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtluzfRjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOjuKjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqtyctAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXRX5d5w(guNEqD6YKw4cpjJwi6Qh1SWuul0WqNCQmCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfActAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHkRitAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXgjYPfQSIBsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQC(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQ8PmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgVgNpKB5BqD6b1PltAHl8KmAHOREuZctrTqdRy4bfUHlSO85hv0BHT4slK)tC5HEleNX(b1eRXgjYPfQSjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I1yJe50cnHjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTW83KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHNYKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkwtAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXgjYPfQSI1KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHMqrM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnHYM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnHIBsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0e5VjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTynEnoFi3Y3G60dQtxM0cx4jz0crx9OMfMIAHg(Oe)bgdxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtl0eM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdmXzTfRXgjYPfQ4M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdmXzTfRXgjYPfM)M0cnQWnt1qVfAJUg1cBA5dFEHNUVWjwOr(5f(qMrnu4lm0PINOwObkq7fAGYN1wSgBKiNw4PmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTW8LjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqLZxM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cvwXAsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0ekBsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0ekUjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHMqXnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXRX5d5w(guNEqD6YKw4cpjJwi6Qh1SWuul0q9IWXvLhdxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtl80Asl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0ekYKwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxObkFwBXASrICAHMqztAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMqztAHgv4MPAO3cneh(7JgrUmCHtSqdXH)(OrKlb5Ska9mCHgO8zTfRXgjYPfActysl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHl0aLpRTyn2iroTqtOynPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqtOynPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfQ45VjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOIFktAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxipl80y0AKl0aLpRTynEnoFi3Y3G60dQtxM0cx4jz0crx9OMfMIAHgIJa4fwEZWfwu(8Jk6TWwCPfY)jU8qVfIZy)GAI1yJe50cv2KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM4S2I1yJe50cv2KwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOjmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqtysl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtluXnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqf3KwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwy(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl80Asl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0atCwBXASrICAHgDtAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtluXAsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0atCwBXASrICAHkRSjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdmXzTfRXgjYPfQSIBsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqLZFtAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXgjYPfQSr3KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXA8AC(qULVb1PhuNUmPfUWtYOfIU6rnlmf1cnKdYWfwu(8Jk6TWwCPfY)jU8qVfIZy)GAI1yJe50cv2KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM4S2I1yJe50cv2KwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOjmPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgyIZAlwJnsKtluXnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqf3KwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwy(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl8uM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cpTM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cZxM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cn6M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cvSM0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnWeN1wSgBKiNwOYkYKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM4S2I1yJe50cvwXnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqLpTM0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQC(YKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkNVmPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfQSr3KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkB0nPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfAcfzsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0e5VjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I1yJe50cnr(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0eNYKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM4S2I1yJe50cnXP1KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXA8AC(qULVb1PhuNUmPfUWtYOfIU6rnlmf1cnKVYMoFnCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgVgF6V6rn0BHkR8cz8GcFHaO20eRXDB(pzr1TTr3papOWnQItt3wVIecG625(C)cnz8bTWCRWStRX5(C)cZn9cbSqLvSMUqtOitO8A8ACUp3VW8nDdZ0cnZfIvbibFLnD(UqKVWeBoQfgPf2Ozq(rtWxztNVl0aCgHbzHAf)AHnDcVWqFqH30wSgN7Z9l0OPrlC0shHzGfAJUg1cZy)bG8JfgPfIZy3jGfI8HQ6RpOWxiYBdXVfgPfAiMDmbiz8Gc3qXA8AmJhu4nHEr44QYtoGvaxy2jjYhcaGWZAmJhu4nHEr44QYtoGvaxy2jzIViaexRXmEqH3e6fHJRkp5awb4WpD7xK8YolpO7AmJhu4nHEr44QYtoGvGzUqSkazQZxcmFLnD(AAOdUOgnM(Oe)bgWnAgKF0e8v2057AmJhu4nHEr44QYtoGvGzUqSkazQZxcmzoK64X0qhCrnAm9rj(dmGv(uRXmEqH3e6fHJRkp5awbM5cXQaKPoFjW6fP)baKK5W0qhCJgtrjWguFNsrDqIgsplCzBI6QHXdYmjjNUiQPqLZXaLZDgye4Wm5SpcNWvae1tBT12uZmWNaRSPMzGpjjGgbwrRXmEqH3e6fHJRkp5awbM5cXQaKPoFjWzSzsg6KtptdDWnAmfLaBaJhKzssoDrutHMqjLmZfIvbiHEr6FaajzoaRSskzMleRcqc(kB68fSYABQzg4tGv2uZmWNKeqJaRO1ygpOWBc9IWXvLNCaRaZCHyvaYuNVe4eYzaP6VCtdDWnAm1md8jWkAnMXdk8MqViCCv5jhWkWmxiwfGm15lb2KRyKpcG1caDrJm3YptdDWf1OX0hL4pWaw5tTgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaBYvms9IAdJbb5hYbDjtdDWf1OX0hL4pWawXUgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaBYvmsJ28nOtrLVTLpcG1Y0qhCrnAm9rj(dmGvwrRXmEqH3e6fHJRkp5awbM5cXQaKPoFjWvtE5ZYhbWAjtrjNyUMg6GlQrJPpkXFGb8PwJz8GcVj0lchxvEYbScmZfIvbitD(sGRM8YNLpcG1sMIswHUPHo4IA0y6Js8hyaFQ1ygpOWBc9IWXvLNCaRaZCHyvaYuNVe4QjV8z5JayTKPOKSUPHo4IA0y6Js8hyaBcfTgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaFJrQxeMONCI5kv1Y0qhCrnAm9rj(dmGv81ygpOWBc9IWXvLNCaRaZCHyvaYuNVe4BmYlFw(iawlzkk5eZ10qhCrnAm9rj(dmGvwrRXmEqH3e6fHJRkp5awbM5cXQaKPoFjW3yKx(S8raSwYuusw30qhCrnAm9rj(dmGv(uRXmEqH3e6fHJRkp5awbM5cXQaKPoFjWSU8YNLpcG1sMIsoXCnn0bxuJgtFuI)adyLv0AmJhu4nHEr44QYtoGvGzUqSkazQZxcmRlV8z5JayTKPOK3ymn0bxuJgtFuI)adytOO1ygpOWBc9IWXvLNCaRaZCHyvaYuNVe4k0Lx(S8raSwYuuYjMRPHo4gnMAMb(eytOO8rdovUdh(7Jgbxy2jPEfp0HwAVgZ4bfEtOxeoUQ8KdyfyMleRcqM68LapXCLx(S8raSwYuusw30qhCJgtnZaFc8PYrzfL7mahMjN9r4OJSrMysjLmah(7Jgbxy2jPEfp0HwAy8GmtsYPlIA5P4ARDokFQCNb4Wm5Spcq0QqSRP(oLI6GeCHzNKipHC0OLggpiZKKC6IOMcnH2RXmEqH3e6fHJRkp5awbM5cXQaKPoFjWtmx5LplFeaRLmfLScDtdDWnAm1md8jWMqr5Jgy0ZD4WFF0i4cZoj1R4Ho0s71ygpOWBc9IWXvLNCaRaZCHyvaYuNVeyvUk(GKx2zPoEmn0b3OXuucmomto7JWrhzJmXKPMzGpb(0QO8rdUCBOslPzg4t5oLvKI0EnMXdk8MqViCCv5jhWkWmxiwfGm15lbwLRIpi5LDwQJhtdDWnAmfLaJdZKZ(iarRcXUPMzGpbwXEQ8rdUCBOslPzg4t5oLvKI0EnMXdk8MqViCCv5jhWkWmxiwfGm15lbwLRIpi5LDwQJhtdDWnAmfLaBMleRcqcvUk(GKx2zPoEaRitnZaFcSrxr5JgC52qLwsZmWNYDkRifP9AmJhu4nHEr44QYtoGvGzUqSkazQZxcmRlVihD)x5LDwQJhtdDWf1OX0hL4pWaw5tTgZ4bfEtOxeoUQ8KdyfyMleRcqM68LapXCLx(SeNX1b1mn0bxuJgtFuI)adytSgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaZbjNyUYlFwIZ46GAMg6GlQrJPpkXFGbSjwJz8GcVj0lchxvEYbScmZfIvbitD(sGtOwgYpKHo5uzAOdUrJPMzGpbw5CNbu(8J01PNGU6AvediJ65SJjLuYGHbiFe13jzKK6HfvAmyyaYhbxy2jjHZcLuYiWHzYzFeGOvHyxBngye4Wm5SpcNWvae1tjLy8GmtsYPlIAGvwjLQVtPOoirdPNfUSnrD1wBTxJxJz8GcVj0lchxvEYbScmZfIvbitD(sGzDz4YFJmn0b3OXuZmWNat5ZpsxNEIlJz1IKTmIg593qyLuIYNFKUo9eha8dXtunPk)oiLuIYNFKUo9eha8dXtun5LEmaakCLuIYNFKUo9epUa5gHlFegeP(FkQHjhtkPeLp)iDD6jqEdx)Hvbiz(8Z(8VYhzgHjLuIYNFKUo9eT4daqZG8dz9v1sjLO85hPRtpr77Qar8K8LMmTAJskr5ZpsxNEclgeYPQjtv4pLuIYNFKUo9eja(sYijv5zaO1ygpOWBc9IWXvLNCaRaZCHyvaYuNVeyoi5eZvE5ZsCgxhuZ0qhCrnAm9rj(dmGnXAmJhu4nHEr44QYtoGvGzUqSkazQZxcmzoK64X0qhCrnAm9rj(dmGv(uRXmEqH3e6fHJRkp5awbxuvrjrx(GwJz8GcVj0lchxvEYbScsv0g1aymfLaBeM5cXQaKqVi9paGKmhGvwt9Dkf1bjEOggPdGCU0sIJ7L93AmJhu4nHEr44QYtoGvaxy2jPka3gtrjWgHzUqSkaj0ls)daijZbyL1ye13PuuhK4HAyKoaY5sljoUx2FRXmEqH3e6fHJRkp5awbK5aZdkCtrjWM5cXQaKqVi9paGKmhGvEnEnMXdk8woGvao((qvtNaawJz8GcVLdyfyMleRcqM68LaNXMjzOto9mn0b3OXuZmWNaRSPOeyZCHyvasKXMjzOto9aRin6fzwEGFcLfK5aZdkCngHb13PuuhKOH0Zcx2MOUkPu9Dkf1bjg6QhfdiT4sx71ygpOWB5awbM5cXQaKPoFjWzSzsg6KtptdDWnAm1md8jWkBkkb2mxiwfGezSzsg6KtpWksJ6pLeCHzNK6HfvIxy5AWra8clxWfMDsQhwujk6YiVPXG67ukQds0q6zHlBtuxLuQ(oLI6GedD1JIbKwCPR9AmJhu4TCaRaZCHyvaYuNVe4eYzaP6VCtdDWnAm1md8jWkBkkbw9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgengH6pLe1hGKrsozfrnXxxJA0AAsOJSrw0LrElpWgyWLD(0DgpOWfCHzNKQaCBe4OnAN7y8GcxWfMDsQcWTrqNj8Fi5GUK2RXmEqH3YbSc(nsEzNLh01uucSbddq(iihaDKnKtpnx2zHoEYdSrxrAUSZcD8OqWN2tPTskzGrmma5JGCa0r2qo90CzNf64jpWg9tP9AmJhu4TCaRa9yqHBkkbw9NscUWSts9WIkXxFnMXdk8woGvWGUK0IlDtrjW13PuuhKyOREumG0IlDnQ)usqNZ4FBqHl(6AmahbWlSCbxy2jPEyrLOi(PLskPgTMMe6iBKfDzK3YdC(RiTxJz8GcVLdyfaGoYMM80T)74s(ykkbw9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3YbScu5dzKKtHWG0mfLaR(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQeVWY18i1FkjM4JZKrsozK8YhiXlS81ygpOWB5awbQu1OceKFykkbw9NscUWSts9WIkXxFnMXdk8woGvGkqepz6xAzkkbw9NscUWSts9WIkXxFnMXdk8woGvqcvKkqeptrjWQ)usWfMDsQhwuj(6RXmEqH3YbScyhtTPyajMbamfLaR(tjbxy2jPEyrL4RVgZ4bfElhWk43ijAOBZuucS6pLeCHzNK6HfvIV(AmJhu4TCaRGFJKOHUMsPeHhPZxc8ba)q8evtQYVdYuucS6pLeCHzNK6HfvIVUskHJa4fwUGlm7KupSOsu0LrEtHGp1P08i1FkjM4JZKrsozK8YhiXxFnMXdk8woGvWVrs0qxtD(sGPRUwfXaYOEo7yYuucmocGxy5cUWSts9WIkrrxg5T8aBGYkEo5RCNzUqSkajyDz4YFJ0EnMXdk8woGvWVrs0qxtD(sGFfXVeQiPzQ1iatrjW4iaEHLl4cZoj1dlQefDzK3uiytOiLuYimZfIvbibRldx(BeyLvsjdg0LaRinM5cXQaKiHAzi)qg6KtfyL1uFNsrDqIgsplCzBI6Q9AmJhu4TCaRGFJKOHUM68La3IpGeD4OHktrjW4iaEHLl4cZoj1dlQefDzK3uiyfxrkPKryMleRcqcwxgU83iWkVgZ4bfElhWk43ijAORPoFjWhaAPNjJKKBn0fbWdkCtrjW4iaEHLl4cZoj1dlQefDzK3uiytOiLuYimZfIvbibRldx(BeyLvsjdg0LaRinM5cXQaKiHAzi)qg6KtfyL1uFNsrDqIgsplCzBI6Q9AmJhu4TCaRGFJKOHUM68LaFzmRwKSLr0iV)gcBkkbghbWlSCbxy2jPEyrLOOlJ8wEGpLgdmcZCHyvasKqTmKFidDYPcSYkP0GUKcvCfP9AmJhu4TCaRGFJKOHUM68LaFzmRwKSLr0iV)gcBkkbghbWlSCbxy2jPEyrLOOlJ8wEGpLgZCHyvasKqTmKFidDYPcSYAu)PKO(ojJKupSOs811O(tjr9DsgjPEyrLOOlJ8wEGnqzfLpEQCx9Dkf1bjAi9SWLTjQR2Ag0LYtXv0AmJhu4TCaRamdaiz8GcxcGAJPoFjWCqM2McHhWkBkkbMXdYmjjNUiQPqtSgZ4bfElhWkaZaasgpOWLaO2yQZxcCgx3W1Y02ui8awztrjW4Wm5Spcq0QqSRP(oLI6GeCHzNKipHC0OLMHbiFe13jzKK6HfvRX5(fEsgTWeQLH8Jfg6Kt1cvPdK3wOfAYwy(oYVfY(BHjulJAlmf1cnkJAH6vGBlCIf(B0cF)c5hl8Kymzki3YV1ygpOWB5awbygaqY4bfUea1gtD(sGtOwgYpKHo5uzABkeEaRSPOeyZCHyvasKXMjzOto9aRinM5cXQaKiHAzi)qg6Kt1AmJhu4TCaRamdaiz8GcxcGAJPoFjWHo5uzABkeEaRSPOeyZCHyvasKXMjzOto9aRO1ygpOWB5awbygaqY4bfUea1gtD(sG5RSPZxtBtHWdyLnfLa3Ozq(rtWxztNVGvEnMXdk8woGvaMbaKmEqHlbqTXuNVeyCeaVWYBRXmEqH3YbScWmaGKXdkCjaQnM68LaxXWdkCtBtHWdyLnfLaBMleRcqIeYzaP6VCWkAnMXdk8woGvaMbaKmEqHlbqTXuNVe4eYzaP6VCtBtHWdyLnfLaBMleRcqIeYzaP6VCWkVgZ4bfElhWkaZaasgpOWLaO2yQZxc8nmtxYN1414C)cz8GcVj4RSPZxWy2XeGKXdkCtrjWmEqHliZbMhu4cCg7obG8dnx2zHoEuiyf7PwJz8GcVj4RSPZ3CaRaYCG5bfUPOe4l7Sqhp5b2mxiwfGeK5qQJhngGJa4fwUyIpotgj5KrYlFGefDzK3YdmJhu4cYCG5bfUGot4)qYbDjLuchbWlSCbxy2jPEyrLOOlJ8wEGz8GcxqMdmpOWf0zc)hsoOlPKsgmma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8aZ4bfUGmhyEqHlOZe(pKCqxsBT1O(tjr9DsgjPEyrL4fwUg1Fkj4cZoj1dlQeVWY18i1FkjM4JZKrsozK8YhiXlS81ygpOWBc(kB68nhWk4r8KPgLtMIsGXra8clxWfMDsQhwujk6YiVbwrAmq9NsI67Kmss9WIkXlSCngGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5QKs4iaEHLlM4JZKrsozK8Yhirrxg5nWksBTxJz8GcVj4RSPZ3CaRGlQQOAYijNOUKpMIsGXra8clxWfMDsQhwujk6YiVbwrAmq9NsI67Kmss9WIkXlSCngGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5QKs4iaEHLlM4JZKrsozK8Yhirrxg5nWksBTxJz8GcVj4RSPZ3CaRGIFi2hztNlqwJz8GcVj4RSPZ3CaRGwgkni)qQhwuzkkbw9NscUWSts9WIkXlSCn4iaEHLl4cZoj1dlQet9jzrxg5nfY4bfUOLHsdYpK6Hfvc8R0O(tjr9DsgjPEyrL4fwUgCeaVWYf13jzKK6HfvIP(KSOlJ8Mcz8Gcx0YqPb5hs9WIkb(vAEK6pLet8XzYijNmsE5dK4fw(AmJhu4nbFLnD(MdyfuFNKrsQhwuzkkbw9NsI67Kmss9WIkXlSCn4iaEHLl4cZoj1dlQefDzK3wJz8GcVj4RSPZ3CaRGj(4mzKKtgjV8bYuucSb4iaEHLl4cZoj1dlQefDzK3aRinQ)usuFNKrsQhwujEHLRTskPxKz5b(juwuFNKrsQhwuTgZ4bfEtWxztNV5awbt8XzYijNmsE5dKPOeyCeaVWYfCHzNK6HfvIIUmYB5DkfPr9NsI67Kmss9WIkXlSCnuRroMeMrnu4Yij1Pkr4bfUGCwfGERXmEqH3e8v205BoGvaxy2jPEyrLPOey1FkjQVtYij1dlQeVWY1GJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5UgZ4bfEtWxztNV5awbCHzNKQCv8bzkkbw9NscUWSts9WIkXxxJ6pLeCHzNK6HfvIIUmYB5bMXdkCbxy2j5f1AiaQjOZe(pKCqxsJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiRXmEqH3e8v205BoGvaxy2jzuQMIsGv)PKGlm7KeNX1bjAdJbjp1Fkj4cZojXzCDqIlFw2ggdIg1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fwUMhP(tjXeFCMmsYjJKx(ajEHLVgZ4bfEtWxztNV5awbCHzNKQCv8bzkkbw9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5Au)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbznMXdk8MGVYMoFZbSc4cZojVOwdbqntrjWQ)usGbiUWCBq(HOigpMIZyKdwztjUa0sIZyKlrjWQ)usGbiUWCBq(HeNXUtaIxy5Amq9NscUWSts9WIkXxxjLu)PKO(ojJKupSOs81vsjCeaVWYfK5aZdkCrr8tlTxJz8GcVj4RSPZ3CaRaUWStYlQ1qauZuucSrWNouHgsWfMDsQ)Vxca5hcYzva6PKsQ)usGbiUWCBq(HeNXUtaIxy5MIZyKdwztjUa0sIZyKlrjWQ)usGbiUWCBq(HeNXUtaIxy5Amq9NscUWSts9WIkXxxjLu)PKO(ojJKupSOs81vsjCeaVWYfK5aZdkCrr8tlTxJz8GcVj4RSPZ3CaRaYCG5bfUPOey1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fwUMhP(tjXeFCMmsYjJKx(ajEHLVgZ4bfEtWxztNV5awbCHzNKrPAkkbw9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiRXmEqH3e8v205BoGvaxy2jPkxfFqRXmEqH3e8v205BoGvaxy2jPka3M141ygpOWBcoiWPkAJAamMIsGRVtPOoiXd1WiDaKZLwsCCVS)0GJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFAPr9NsIhQHr6aiNlTK44Ez)jtv0gXlSCngO(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQeVWY18i1FkjM4JZKrsozK8YhiXlSCT1GJa4fwUyIpotgj5KrYlFGefDzK3aRingO(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPXadggG8ruFNKrsQhwuPbhbWlSCr9DsgjPEyrLOOlJ8wEGpWpn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTskzGrmma5JO(ojJKupSOsdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKs4iaEHLl4cZoj1dlQefDzK3Yd8b(PT2RXmEqH3eCq5awbjursvaUnMIsGnO(oLI6GepudJ0bqoxAjXX9Y(tdocGxy5c1FkjFOggPdGCU0sIJ7L9NOi(PLg1FkjEOggPdGCU0sIJ7L9NmHks8clxJErMLh4NqzrQI2OgaJ2kPKb13PuuhK4HAyKoaY5sljoUx2FAg0LYtzTxJz8GcVj4GYbScsv0gPhMztrjW13PuuhK4OqnaTKimcdqAWra8clxWfMDsQhwujk6YiVPqfxrAWra8clxmXhNjJKCYi5LpqIIUmYBGvKgdu)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10yGbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWh4NgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wjLmWiggG8ruFNKrsQhwuPbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDTvsjCeaVWYfCHzNK6HfvIIUmYB5b(a)0w71ygpOWBcoOCaRGufTr6Hz2uucC9Dkf1bjokudqljcJWaKgCeaVWYfCHzNK6HfvIIUmYBGvKgdmWaCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbibRlV8z5JayTKPOKtmxnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOTskzaocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0O(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPT2Au)PKO(ojJKupSOs8clx71ygpOWBcoOCaRGj(4mzKKtgjV8bYuucC9Dkf1bjAi9SWLTjQRg9ImlpWpHYcYCG5bf(AmJhu4nbhuoGvaxy2jPEyrLPOe467ukQds0q6zHlBtuxngOxKz5b(juwqMdmpOWvsj9ImlpWpHYIj(4mzKKtgjV8bs71ygpOWBcoOCaRaYCG5bfUPOe4bDjfQ4kst9Dkf1bjAi9SWLTjQRg1Fkj4cZojXzCDqI2WyqYdSzUqSkaj4GKtmx5LplXzCDqnn4iaEHLlM4JZKrsozK8Yhirrxg5nWksdocGxy5cUWSts9WIkrrxg5T8aFGFRXmEqH3eCq5awbK5aZdkCtrjWd6skuXvKM67ukQds0q6zHlBtuxn4iaEHLl4cZoj1dlQefDzK3aRingyGb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrBLuYaCeaVWYft8XzYijNmsE5dKOOlJ8gyfPr9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutBT1O(tjr9DsgjPEyrL4fwU2MI8HQ6RpsucS6pLenKEw4Y2e1v0ggdcy1FkjAi9SWLTjQR4YNLTHXGykYhQQV(ir3l9q8qGvEnMXdk8MGdkhWk4IQkQMmsYjQl5JPOeydWra8clxWfMDsQhwujk6YiVPW8)ukPeocGxy5cUWSts9WIkrrxg5T8aR4ARbhbWlSCXeFCMmsYjJKx(ajk6YiVbwrAmq9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutJbgmma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8aFGFAWra8clxWfMDsQhwujk6YiVPWtPTskzGrmma5JO(ojJKupSOsdocGxy5cUWSts9WIkrrxg5nfEkTvsjCeaVWYfCHzNK6HfvIIUmYB5b(a)0w71ygpOWBcoOCaRGIFi2hztNlqmfLaJJa4fwUyIpotgj5KrYlFGefDzK3YJot4)qYbDjngO(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPXadggG8ruFNKrsQhwuPbhbWlSCr9DsgjPEyrLOOlJ8wEGpWpn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTskzGrmma5JO(ojJKupSOsdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKs4iaEHLl4cZoj1dlQefDzK3Yd8b(PT2RXmEqH3eCq5awbf)qSpYMoxGykkbghbWlSCbxy2jPEyrLOOlJ8wE0zc)hsoOlPXadmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiARKsgGJa4fwUyIpotgj5KrYlFGefDzK3aRinQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAARTg1FkjQVtYij1dlQeVWY1EnMXdk8MGdkhWk4r8KPgLtMIsGXra8clxWfMDsQhwujk6YiVbwrAmWadWra8clxmXhNjJKCYi5LpqIIUmYBk0mxiwfGeSU8YNLpcG1sMIsoXC1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kPKb4iaEHLlM4JZKrsozK8Yhirrxg5nWksJ6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOM2ARr9NsI67Kmss9WIkXlSCTxJz8GcVj4GYbScM4JZKrsozK8YhitrjWQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAAmWGHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLh4d8tdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKsgyeddq(iQVtYij1dlQ0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPeocGxy5cUWSts9WIkrrxg5T8aFGFAVgZ4bfEtWbLdyfWfMDsQhwuzkkb2adWra8clxmXhNjJKCYi5LpqIIUmYBk0mxiwfGeSU8YNLpcG1sMIsoXC1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kPKb4iaEHLlM4JZKrsozK8Yhirrxg5nWksJ6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOM2ARr9NsI67Kmss9WIkXlS81ygpOWBcoOCaRG67Kmss9WIktrjWQ)usuFNKrsQhwujEHLRXadWra8clxmXhNjJKCYi5LpqIIUmYBk0eksJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiARKsgGJa4fwUyIpotgj5KrYlFGefDzK3aRinQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAARTgdWra8clxWfMDsQhwujk6YiVPqLnHsk9i1FkjM4JZKrsozK8YhiXxx71ygpOWBcoOCaRGwgkni)qQhwuzkkbghbWlSCbxy2jzuQIIUmYBk8ukPKrmma5JGlm7Kmk11ygpOWBcoOCaRa9IAKJjzKKxK)mfLaR(tjXJ4jtnkNeFDnps9NsIj(4mzKKtgjV8bs8118i1FkjM4JZKrsozK8Yhirrxg5T8aR(tjHErnYXKmsYlYFIlFw2ggdsUJXdkCbxy2jPka3gbDMW)HKd6sAmWGHbiFef1cNDmPHXdYmjjNUiQLx(RTskX4bzMKKtxe1Y7uARXaJO(oLI6GeCHzNKQXvLR3L8rjLgUoOrKrmWKj0XJcv8tP9AmJhu4nbhuoGvaxy2jPka3gtrjWQ)us8iEYuJYjXxxJbgmma5JOOw4SJjnmEqMjj50frT8YFTvsjgpiZKKC6IOwENsBngye13PuuhKGlm7KunUQC9UKpkP0W1bnImIbMmHoEuOIFkTxJz8GcVj4GYbScAFDQ8WmVgZ4bfEtWbLdyfWfMDsQYvXhKPOey1Fkj4cZojXzCDqI2Wyquiydy8GmtsYPlIA5JkRTM67ukQdsWfMDsQgxvUExYhndxh0iYigyYe64jpf)uRXmEqH3eCq5awbCHzNKQCv8bzkkbw9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgK1ygpOWBcoOCaRaUWStYOunfLaR(tjbxy2jjoJRds0ggdcyfTgZ4bfEtWbLdyf40KrLCORo1gtrjWguuQOwgRcqkPKrmimii)qBnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGSgZ4bfEtWbLdyfWfMDsErTgcGAMIsGv)PKadqCH52G8drrmE0uFNsrDqcUWStsKNqoA0sJbgmma5JGV6aOecZdkCnmEqMjj50frT8m6ARKsmEqMjj50frT8oL2RXmEqH3eCq5awbCHzNKxuRHaOMPOey1FkjWaexyUni)queJhnddq(i4cZojjCwO5rQ)usmXhNjJKCYi5LpqIVUgdggG8rWxDaucH5bfUskX4bzMKKtxe1YtXQ9AmJhu4nbhuoGvaxy2j5f1AiaQzkkbw9NscmaXfMBdYpefX4rZWaKpc(QdGsimpOW1W4bzMKKtxe1Yl)xJz8GcVj4GYbSc4cZojPZ6ardfUPOey1Fkj4cZojXzCDqI2WyqYt9NscUWStsCgxhK4YNLTHXGSgZ4bfEtWbLdyfWfMDssN1bIgkCtrjWQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOrViZYd8tOSGlm7KuLRIpO1ygpOWBcoOCaRaYCG5bfUPiFOQ(6JeLaFzNf64rHGvSNYuKpuvF9rIUx6H4HaR8A8ACUFH5xHIcnOthAH)gYpw4rHAaATqegHbOfAHMSfY6IfA00OfIMfAHMSfoXCxymzuzHAKynMXdk8MahbWlS8g4ufTr6Hz2uucC9Dkf1bjokudqljcJWaKgCeaVWYfCHzNK6HfvIIUmYBkuXvKgCeaVWYft8XzYijNmsE5dKOOlJ8gyfPXa1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GAAmWGHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLh4d8tdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKsgyeddq(iQVtYij1dlQ0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPeocGxy5cUWSts9WIkrrxg5T8aFGFAR9AmJhu4nbocGxy5TCaRGufTr6Hz2uucC9Dkf1bjokudqljcJWaKgCeaVWYfCHzNK6HfvIIUmYBGvKgdmIHbiFeKdGoYgYPNskzWWaKpcYbqhzd50tZLDwOJhfcoFPiT1wJbgGJa4fwUyIpotgj5KrYlFGefDzK3uOYksJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiARKsgGJa4fwUyIpotgj5KrYlFGefDzK3aRinQ)usWfMDsIZ46GeTHXGawrARTg1FkjQVtYij1dlQeVWY1CzNf64rHGnZfIvbibRlVihD)x5LDwQJN1ygpOWBcCeaVWYB5awbPkAJAamMIsGRVtPOoiXd1WiDaKZLwsCCVS)0GJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFAPr9NsIhQHr6aiNlTK44Ez)jtv0gXlSCngO(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQeVWY18i1FkjM4JZKrsozK8YhiXlSCT1GJa4fwUyIpotgj5KrYlFGefDzK3aRingO(tjbxy2jjoJRds0ggdsEGnZfIvbiXeZvE5ZsCgxhutJbgmma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8aFGFAWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswxBLuYaJyyaYhr9DsgjPEyrLgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wjLWra8clxWfMDsQhwujk6YiVLh4d8tBTxJz8GcVjWra8clVLdyfKqfjvb42ykkbU(oLI6GepudJ0bqoxAjXX9Y(tdocGxy5c1FkjFOggPdGCU0sIJ7L9NOi(PLg1FkjEOggPdGCU0sIJ7L9NmHks8clxJErMLh4NqzrQI2OgaZACUFH5hJQfAYItwOfAYwyULFleLwiAmSTqCCr(Xc)6lSfHlw4PpTq0SqleaWcvPf(B0BHwOjBHNeJjZ0fI52Sq0SWga6iBa0AHQukkAnMXdk8MahbWlS8woGvWfvvunzKKtuxYhtrjW4iaEHLlM4JZKrsozK8Yhirrxg5T8mZfIvbiXngPEryIEYjMRuvlLuYaCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGe3yKx(S8raSwYuuswxdocGxy5Ij(4mzKKtgjV8bsu0LrEtHM5cXQaK4gJ8YNLpcG1sMIsoXC1EnMXdk8MahbWlS8woGvWfvvunzKKtuxYhtrjW4iaEHLl4cZoj1dlQefXpT0yGrmma5JGCa0r2qo9usjdggG8rqoa6iBiNEAUSZcD8OqW5lfPT2AmWaCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbibRlV8z5JayTKPOKtmxnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOTskzaocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0O(tjbxy2jjoJRds0ggdcyfPT2Au)PKO(ojJKupSOs8clxZLDwOJhfc2mxiwfGeSU8IC09FLx2zPoEwJZ9lm3aSyTAl83Of(iEYuJYPfAHMSfY6IfE6tlCI5UquBHfXpTwi3wOfbay6cVmi0cB)Iw4eleZTzHOzHQukkAHtmxXAmJhu4nbocGxy5TCaRGhXtMAuozkkbghbWlSCXeFCMmsYjJKx(ajk6YiVbwrAu)PKGlm7KeNX1bjAdJbjpWM5cXQaKyI5kV8zjoJRdQPbhbWlSCbxy2jPEyrLOOlJ8wEGpWV1ygpOWBcCeaVWYB5awbpINm1OCYuucmocGxy5cUWSts9WIkrrxg5nWksJbgXWaKpcYbqhzd50tjLmyyaYhb5aOJSHC6P5Yol0XJcbNVuK2ARXadWra8clxmXhNjJKCYi5LpqIIUmYBkuzfPr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgeTvsjdWra8clxmXhNjJKCYi5LpqIIUmYBGvKg1Fkj4cZojXzCDqI2WyqaRiT1wJ6pLe13jzKK6HfvIxy5AUSZcD8OqWM5cXQaKG1LxKJU)R8Yol1XZACUFHgnnAHnDUazHO0cNyUlK93cz9fYfTWWxi(Tq2Fl0kCdNfQsl8RVWuulei8dQw4KX(cNmAHx(8cFeaRLPl8YGG8Jf2(fTqlAHzSzAH8SqaIBZchRyHCHzNwioJRdQTq2FlCY4zHtm3fAXn3WzHNU9BZc)n6jwJz8GcVjWra8clVLdyfu8dX(iB6CbIPOeyCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbir1Kx(S8raSwYuuYjMRgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGevtE5ZYhbWAjtrjzDngmma5JO(ojJKupSOsJb4iaEHLlQVtYij1dlQefDzK3YJot4)qYbDjLuchbWlSCr9DsgjPEyrLOOlJ8McnZfIvbir1Kx(S8raSwYuuYk01wjLmIHbiFe13jzKK6HfvARr9NscUWStsCgxhKOnmgefAcnps9NsIj(4mzKKtgjV8bs8clxJ6pLe13jzKK6HfvIxy5Au)PKGlm7KupSOs8clFno3VqJMgTWMoxGSql0KTqwFHwzKVq9O1qQaKyHN(0cNyUle1wyr8tRfYTfAraaMUWldcTW2VOfoXcXCBwiAwOkLIIw4eZvSgZ4bfEtGJa4fwElhWkO4hI9r205cetrjW4iaEHLlM4JZKrsozK8Yhirrxg5T8OZe(pKCqxsJ6pLeCHzNK4mUoirBymi5b2mxiwfGetmx5LplXzCDqnn4iaEHLl4cZoj1dlQefDzK3YZa6mH)djh0LYHXdkCXeFCMmsYjJKx(ajOZe(pKCqxs71ygpOWBcCeaVWYB5awbf)qSpYMoxGykkbghbWlSCbxy2jPEyrLOOlJ8wE0zc)hsoOlPXadmIHbiFeKdGoYgYPNskzWWaKpcYbqhzd50tZLDwOJhfcoFPiT1wJbgGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5Qr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgeTvsjdWra8clxmXhNjJKCYi5LpqIIUmYBGvKg1Fkj4cZojXzCDqI2WyqaRiT1wJ6pLe13jzKK6HfvIxy5AUSZcD8OqWM5cXQaKG1LxKJU)R8Yol1XJ2RX5(fA00OfoXCxOfAYwiRVquAHOXW2cTqtgYx4Krl8YNx4JayTel80NwOhJPl83OfAHMSfwH(crPfoz0chgG8zHO2chgeYnDHS)wiAmSTql0KH8foz0cV85f(iawlXAmJhu4nbocGxy5TCaRGj(4mzKKtgjV8bYuucS6pLeCHzNK4mUoirBymi5b2mxiwfGetmx5LplXzCDqnn4iaEHLl4cZoj1dlQefDzK3YdmDMW)HKd6sAUSZcD8OqZCHyvasW6YlYr3)vEzNL64rJ6pLe13jzKK6HfvIxy5RXmEqH3e4iaEHL3YbScM4JZKrsozK8YhitrjWQ)usWfMDsIZ46GeTHXGKhyZCHyvasmXCLx(SeNX1b10mma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8atNj8Fi5GUKgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11GJa4fwUGlm7KupSOsu0LrEtHkBI1ygpOWBcCeaVWYB5awbt8XzYijNmsE5dKPOey1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GAAmWiggG8ruFNKrsQhwuPKs4iaEHLlQVtYij1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkzf6ARbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjz914C)cnAA0cz9fIslCI5UquBHHVq8BHS)wOv4goluLw4xFHPOwiq4huTWjJ9foz0cV85f(iawltx4Lbb5hlS9lAHtgpl0IwygBMwi5X)iBHx25fY(BHtgplCYOIwiQTqpMfYafXpTwiVW670cJ0c1dlQw4lSCXAmJhu4nbocGxy5TCaRaUWSts9WIktrjW4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUAmWiWHzYzFeMjFY0QusjCeaVWYfxuvr1KrsorDjFefDzK3uOzUqSkajyD5LplFeaRLmfL8gJ2Au)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrJ6pLe13jzKK6HfvIxy5AUSZcD8OqWM5cXQaKG1LxKJU)R8Yol1XZACUFHgnnAHvOVquAHtm3fIAlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAz6cVmii)yHTFrlCYOIwiQ5golKbkIFATqEH13Pf(clFHS)w4KXZcz9fAfUHZcvjCCPfYMzeaRcql89lKFSW67KynMXdk8MahbWlS8woGvq9DsgjPEyrLPOey1Fkj4cZoj1dlQeVWY1yaocGxy5Ij(4mzKKtgjV8bsu0LrEtHM5cXQaKOcD5LplFeaRLmfLCI5QKs4iaEHLl4cZoj1dlQefDzK3YdSzUqSkajMyUYlFw(iawlzkkjRRTg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0GJa4fwUGlm7KupSOsu0LrEtHkBI1ygpOWBcCeaVWYB5awbTmuAq(HupSOYuucS6pLeCHzNK6HfvIxy5AWra8clxWfMDsQhwujM6tYIUmYBkKXdkCrldLgKFi1dlQe4xPr9NsI67Kmss9WIkXlSCn4iaEHLlQVtYij1dlQet9jzrxg5nfY4bfUOLHsdYpK6Hfvc8R08i1FkjM4JZKrsozK8YhiXlS814C)cnAA0c1J7cNyHT85NOthAHSVq68u8cz1fI8foz0cD68SqCeaVWYxOfYFHLPl87auRTqq0QqSVWjJ8fgoGwl89lKFSqUWStlupSOAHVpTWjwywyTWl78cZ((rP1cl(HyFwytNlqwiQTgZ4bfEtGJa4fwElhWkqVOg5ysgj5f5ptrjWddq(iQVtYij1dlQ0O(tjbxy2jPEyrL4RRr9NsI67Kmss9WIkrrxg5T8oWpXLpVgZ4bfEtGJa4fwElhWkqVOg5ysgj5f5ptrjWps9NsIj(4mzKKtgjV8bs8118i1FkjM4JZKrsozK8Yhirrxg5T8y8GcxWfMDsErTgcGAc6mH)djh0L0ye4Wm5Spcq0QqSVgZ4bfEtGJa4fwElhWkqVOg5ysgj5f5ptrjWQ)usuFNKrsQhwuj(6Au)PKO(ojJKupSOsu0LrElVd8tC5ZAWra8clxqMdmpOWffXpT0GJa4fwUyIpotgj5KrYlFGefDzK30ye4Wm5Spcq0QqSVgVgZ4bfEtKqodiv)LNdyfWfMDsErTgcGAMIsGv)PKadqCH52G8drrmEmfNXihSYRXmEqH3ejKZas1F55awbCHzNKQaCBwJz8GcVjsiNbKQ)YZbSc4cZojv5Q4dAnEno3VW8HmYxy9Dh5hlKqtgvlCYOfABVWOw4j5dleGoi)XfIAMUqlAHwSplCIfEAmhluLsrrlCYOfEsmMmfKB53cTq(lSel0OPrlenlKBlSfHVqUTW8DKFlmJBlmHCulJElm(1cTidntlSPt(SW4xleNX1b1wJz8GcVjsOwgYpKHo5ubMmhyEqHBkkb2G67ukQds0q6zHlBtuxLuQ(oLI6GedD1JIbKwCPRTgdu)PKO(ojJKupSOs8clxjL0lYS8a)ekl4cZojv5Q4dsBn4iaEHLlQVtYij1dlQefDzK3wJZ9l80NwOfzOzAHjKJAz0BHXVwiocGxy5l0c5VWQTq2FlSPt(SW4xleNX1b1mDH6fkk0GoDOfEAmhlmmt1cjZuP1KH8JfsanAnMXdk8MiHAzi)qg6KtvoGvazoW8Gc3uuc8WaKpI67Kmss9WIkn4iaEHLlQVtYij1dlQefDzK30GJa4fwUGlm7KupSOsu0LrEtJ6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOs8clxJErMLh4Nqzbxy2jPkxfFqRXmEqH3ejuld5hYqNCQYbScsOIKQaCBmfLaxFNsrDqIhQHr6aiNlTK44Ez)Pr9NsIhQHr6aiNlTK44Ez)jtv0gXxFnMXdk8MiHAzi)qg6KtvoGvqQI2i9WmBkkbU(oLI6GehfQbOLeHryasZLDwOJhfQyp1AmJhu4nrc1Yq(Hm0jNQCaRGhXtMAuozkkb2iQVtPOoirdPNfUSnrD1ye13PuuhKyOREumG0Il91ygpOWBIeQLH8dzOtov5awbCHzNKrPAkkbghbWlSCr9DsgjPEyrLOi(P1AmJhu4nrc1Yq(Hm0jNQCaRaUWStsvaUnMIsGXra8clxuFNKrsQhwujkIFAPr9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiRXmEqH3ejuld5hYqNCQYbScQVtYij1dlQwJZ9l80NwOfzyrlKNfE5ZlSnmgK2cJ0cnkJAHS)wOfTWm2m5gol83O3cnzXjlulAmDH)gTqEHTHXGSWjwOErMjFw4974mKFSgZ4bfEtKqTmKFidDYPkhWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8Or9NscmaXfMBdYpeTHXGaw9NscmaXfMBdYpex(SSnmgen4Wm5SpcZKpzAvAWra8clxCrvfvtgj5e1L8rue)0Ano3Vqqf1Lba0AHw0c1zuTq9yqHVWFJwOfAYwyULFMUq1)Sq0SqleaWcb42SqGWpwi5X)iBHPOwOAmzlCYOfMVJ8BHS)wyULFl0c5VWQTWVdqT2cRV7i)yHtgTqB7fg1cpjFyHa0b5pUquBnMXdk8MiHAzi)qg6KtvoGvGEmOWnfLaBeguFNsrDqIgsplCzBI6QKs13PuuhKyOREumG0IlDTxJz8GcVjsOwgYpKHo5uLdyf8iEYuJYjtrjWQ)usuFNKrsQhwujEHLRKs6fzwEGFcLfCHzNKQCv8bTgZ4bfEtKqTmKFidDYPkhWkO4hI9r205cetrjWQ)usuFNKrsQhwujEHLRKs6fzwEGFcLfCHzNKQCv8bTgZ4bfEtKqTmKFidDYPkhWk4IQkQMmsYjQl5JPOey1FkjQVtYij1dlQeVWYvsj9ImlpWpHYcUWStsvUk(GwJz8GcVjsOwgYpKHo5uLdyfmXhNjJKCYi5LpqMIsGv)PKO(ojJKupSOs8clxjL0lYS8a)ekl4cZojv5Q4dsjL0lYS8a)eklUOQIQjJKCI6s(OKs6fzwEGFcLff)qSpYMoxGOKs6fzwEGFcLfpINm1OCAnMXdk8MiHAzi)qg6KtvoGvaxy2jPEyrLPOey9ImlpWpHYIj(4mzKKtgjV8bAno3VqJMgTW8lmzlCIf2YNFIoDOfY(cPZtXlm3km70cbna3Mf((fYpw4Krl8Kymzki3YVfAH8xyTWVdqT2cRV7i)yH5wHzNw4PbNfIfE6tlm3km70cpn4SyHO2chgG8HEMUqlAHy2nCw4Vrlm)ct2cTqtgYx4Krl8Kymzki3YVfAH8xyTWVdqT2cTOfI8HQ6RplCYOfMBMSfIZy3jatxylwOfziaWcBSzAHOrSgZ4bfEtKqTmKFidDYPkhWkqVOg5ysgj5f5ptrjWgXWaKpcUWStscNfAEK6pLet8XzYijNmsE5dK4RR5rQ)usmXhNjJKCYi5LpqIIUmYB5b2agpOWfCHzNKQaCBe0zc)hsoOlL7u)PKqVOg5ysgj5f5pXLplBdJbr714C)cp9PfMFHjBHzCZnCwOkr(c)n6TW3Vq(XcNmAHNeJjBHwi)fwMUqlYqaGf(B0crZcNyHT85NOthAHSVq68u8cZTcZoTqqdWTzHiFHtgTW8DKFki3YVfAH8xyjwJz8GcVjsOwgYpKHo5uLdyfOxuJCmjJK8I8NPOey1Fkj4cZoj1dlQeFDnQ)usuFNKrsQhwujk6YiVLhydy8GcxWfMDsQcWTrqNj8Fi5GUuUt9Nsc9IAKJjzKKxK)ex(SSnmgeTxJz8GcVjsOwgYpKHo5uLdyfWfMDsQcWTXuuc8lgrXpe7JSPZfiIIUmYBk8ukP0Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyquOIwJZ9lmFGwOf7ZcNyHxgeAHTFrl0IwygBMwi5X)iBHx25fMIAHtgTqYhurlm3YVfAH8xyz6cjZKVquAHtgvKHTf2geaWch0Lwyrxg5i)yHHVW8DKFIfE6hdBlmCaTwOkndvlCIfQ(lFHtSWthQIfY(BHNgZXcrPfwF3r(XcNmAH22lmQfEs(WcbOdYFCHOMynMXdk8MiHAzi)qg6KtvoGvaxy2jPkxfFqMIsGXra8clxWfMDsQhwujkIFAP5Yol0XtEgK)kkhduwr5oCyMC2hbiAvi21wBnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOXiQVtPOoirdPNfUSnrD1ye13PuuhKyOREumG0Il914C)cnACaQ1wy9Dh5hlCYOfMBfMDAHkgUUHR1cbOdYFCPLPle0Cv8bTWww8bEl0JzHQ0c)n6TqEw4KrlK83cJ0cZT8BHO0cpnMdmpOWxiQTWiLwiocGxy5lKBl8vHUoYpwioJRdQTqleaWcVmi0crZchgeAHaHFq1cNyHQ)Yx4KvX)iBHfDzKJ8JfEzNxJz8GcVjsOwgYpKHo5uLdyfWfMDsQYvXhKPOey1Fkj4cZoj1dlQeFDnQ)usWfMDsQhwujk6YiVLh4d8tJb13PuuhKGlm7Ke5jKJgTusjCeaVWYfK5aZdkCrrxg5nTxJZ9le0Cv8bTWww8bElKbSyTAluLw4KrleGBZcXCBwiYx4KrlmFh53cTq(lSwi3w4jXyYwOfcayHf1MOOfoz0cXzCDqTf20jFwJz8GcVjsOwgYpKHo5uLdyfWfMDsQYvXhKPOey1FkjQVtYij1dlQeFDnQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkrrxg5T8aFGFRXmEqH3ejuld5hYqNCQYbSc4cZojVOwdbqntrjWps9NsIj(4mzKKtgjV8bs811mma5JGlm7KKWzHgdu)PK4r8KPgLtIxy5kPeJhKzssoDrudSYAR5rQ)usmXhNjJKCYi5LpqIIUmYBkKXdkCbxy2j5f1AiaQjOZe(pKCqxYuCgJCWkBkXfGwsCgJCjkbw9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPKbgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kPeocGxy5cYCG5bfUOi(PL2AR9ACUFHgToGwlSnCnl83q(XcnkJAH5MjBHwzKVWCl)wyg3wOkr(c)n6TgZ4bfEtKqTmKFidDYPkhWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8ObhbWlSCbxy2jPEyrLOOlJ8Mgdu)PKO(ojJKupSOs81vsj1Fkj4cZoj1dlQeFDTnfNXihSYRXmEqH3ejuld5hYqNCQYbSc4cZojJs1uucS6pLeCHzNK4mUoirBymi5b2mxiwfGetmx5LplXzCDqT1ygpOWBIeQLH8dzOtov5awbCHzNKQaCBmfLaR(tjr9DsgjPEyrL4RRKsx2zHoEuOYNAnMXdk8MiHAzi)qg6KtvoGvazoW8Gc3uucS6pLe13jzKK6HfvIxy5Au)PKGlm7KupSOs8cl3uKpuvF9rIsGVSZcD8OqWg9tzkYhQQV(ir3l9q8qGvEnMXdk8MiHAzi)qg6KtvoGvaxy2jPkxfFqRXRX5(C)cz8GcVjY46gUwGXSJjajJhu4MIsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk2tTgN7xOrtJw4PXCG5bf(crPfArgw0cbcRfg(cVSZlK93c5fEsmMmfKB53cTq(lSwiQTqCCr(Xc)6RXmEqH3ezCDdxRCaRaYCG5bfUPOe4l7Sqhp5bw5tPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhydOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjT1GJa4fwUGlm7KupSOsu0LrElpWgqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6s5W4bfUGlm7KupSOsqNj8Fi5GUK2Au)PKO(ojJKupSOs8clxJ6pLeCHzNK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fwUgJ4fJO4hI9r205cerrxg5T14C)cnAA0cpnMdmpOWxikTqlYWIwiqyTWWx4LDEHS)wiVW8DKFl0c5VWAHO2cXXf5hl8RVgZ4bfEtKX1nCTYbSciZbMhu4MIsGVSZcD8KhyfxrAWra8clxuFNKrsQhwujk6YiVLhydOZe(pKCqxkhgpOWf13jzKK6Hfvc6mH)djh0L0wdocGxy5Ij(4mzKKtgjV8bsu0LrElpWgqNj8Fi5GUuomEqHlQVtYij1dlQe0zc)hsoOlLdJhu4IIFi2hztNlqe0zc)hsoOlPTgCeaVWYfCHzNK6HfvIIUmYBkm)v0AmJhu4nrgx3W1khWkGlm7KufGBJPOeyCeaVWYff)qSpYMoxGik6YiVLhytK7oWVCmZfIvbiHjxXi1lQnmgeKFih0LYHot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctUIrQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVLhyZCHyvasyYvms9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjnQ)usWfMDsIZ46GeTHXGOqL1O(tjbxy2jjoJRds0ggdsE5VgJah(7Jgbxy2jPEfp0HwRXmEqH3ezCDdxRCaRaUWStsvaUnMIsGXra8clxuFNKrsQhwujk6YiVLhytK7oWVCmZfIvbiHjxXi1lQnmgeKFih0LYHot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxsdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm5kgPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMCfJuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDPCy8Gcxu8dX(iB6CbIGot4)qYbDjn4iaEHLl4cZoj1dlQefDzK30O(tjbxy2jjoJRds0ggdIcvwJ6pLeCHzNK4mUoirBymi5L)AmcC4VpAeCHzNK6v8qhATgZ4bfEtKX1nCTYbSc4cZojvb42ykkbghbWlSCrXpe7JSPZfiIIUmYB5b2e5Ud8lhZCHyvasyYvms9IAdJbb5hYbDjn4iaEHLl4cZoj1dlQefDzK3uiyfxrAWra8clxmXhNjJKCYi5LpqIIUmYB5O4kkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhfxr5bghbWlSCbxy2jPEyrLOOlJ8Mg1Fkj4cZojXzCDqI2WyquOYAu)PKGlm7KeNX1bjAdJbjV8xJrGd)9rJGlm7KuVIh6qR1ygpOWBImUUHRvoGvaxy2jPkxfFqMIsGXra8clxu8dX(iB6CbIOOlJ8wEGpWVCmZfIvbiHjxXi1lQnmgeKFih0LYHot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctUIrQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVLhyZCHyvasyYvms9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjnQ)usWfMDsIZ46GeTHXGOqLxJz8GcVjY46gUw5awbCHzNKQCv8bzkkbghbWlSCr9DsgjPEyrLOOlJ8wEGpWVCmZfIvbiHjxXi1lQnmgeKFih0LYHot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxsdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm5kgPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMCfJuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDPCy8Gcxu8dX(iB6CbIGot4)qYbDjn4iaEHLl4cZoj1dlQefDzK30O(tjbxy2jjoJRds0ggdIcvEnMXdk8MiJRB4ALdyfWfMDsQYvXhKPOeyCeaVWYff)qSpYMoxGik6YiVLh4d8lhZCHyvasyYvms9IAdJbb5hYbDjn4iaEHLl4cZoj1dlQefDzK3uiyfxrAWra8clxmXhNjJKCYi5LpqIIUmYB5O4kkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhfxr5bghbWlSCbxy2jPEyrLOOlJ8Mg1Fkj4cZojXzCDqI2WyquOYAmcC4VpAeCHzNK6v8qhATgN7xiO)iG3cvmCDdxRf2ggdsBHPOw4Krl8Kymzki3YVfAH8xyTgZ4bfEtKX1nCTYbSc4cZojVOwdbqntrjWQ)usWfMDsMX1nCTeTHXGKN6pLeCHzNKzCDdxlXLplBdJbrdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm5kgPErTHXGG8d5GUuo0zc)hsoOlPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhyZCHyvasyYvms9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxsdocGxy5cUWSts9WIkrrxg5T8aBMleRcqctUIrQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6s5W4bfUyIpotgj5KrYlFGe0zc)hsoOlzkoJroyLxJZ9le0FeWBHkgUUHR1cBdJbPTWuulCYOfMVJ8BHwi)fwRXmEqH3ezCDdxRCaRaUWStYlQ1qauZuucS6pLeCHzNKzCDdxlrBymi5P(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUO(ojJKupSOsu0LrElpWM5cXQaKWKRyK6f1ggdcYpKd6s5qNj8Fi5GUuomEqHlQVtYij1dlQe0zc)hsoOlPbhbWlSCrXpe7JSPZfiIIUmYB5b2mxiwfGeMCfJuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctUIrQxuBymii)qoOlLdDMW)HKd6s5W4bfUO(ojJKupSOsqNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUKgCeaVWYfCHzNK6HfvIIUmYBMIZyKdw514C)cb9hb8wOIHRB4ATW2WyqAlmf1cNmAHodc9wy(2EHwi)fwRXmEqH3ezCDdxRCaRaUWStYlQ1qauZuucS6pLeCHzNKzCDdxlrBymi5P(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUO4hI9r205cerrxg5T8aBMleRcqctUIrQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVPqWkUI0GJa4fwUO(ojJKupSOsu0LrEtHGvCfPXiWH)(OrWfMDsQxXdDOLP4mg5GvEnMXdk8MiJRB4ALdyfu8dX(iB6CbIPOey1Fkj4cZojXzCDqI2WyqYZeAu)PKGlm7KmJRB4AjAdJbbS6pLeCHzNKzCDdxlXLplBdJbrdocGxy5Ij(4mzKKtgjV8bsu0LrElp6mH)djh0L0GJa4fwUGlm7KupSOsu0LrElpWgqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6sAR5Yol0XJcv(uRXmEqH3ezCDdxRCaRGj(4mzKKtgjV8bYuucS6pLeCHzNK4mUoirBymi5zcnQ)usWfMDsMX1nCTeTHXGaw9NscUWStYmUUHRL4YNLTHXGObhbWlSCbxy2jPEyrLOOlJ8wEGPZe(pKCqxsZlgrXpe7JSPZfiIIUmYBRXmEqH3ezCDdxRCaRaUWSts9WIktrjWQ)usWfMDsMX1nCTeTHXGaw9NscUWStYmUUHRL4YNLTHXGO5rQ)usmXhNjJKCYi5LpqIVUg1FkjQVtYij1dlQeVWYxJz8GcVjY46gUw5awb13jzKK6HfvMIsGv)PKGlm7KeNX1bjAdJbjptOr9NscUWStYmUUHRLOnmgeWQ)usWfMDsMX1nCTex(SSnmgen4iaEHLlk(HyFKnDUaru0LrElpW0zc)hsoOlPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhydOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxsBn4iaEHLl4cZoj1dlQefDzK3uy(FQCmZfIvbiHjxXiFeaRfa6IgzULFAUSZcD8OqWk(PwJz8GcVjY46gUw5awbf)qSpYMoxGykkbw9NscUWStsCgxhKOnmgK8mHg1Fkj4cZojZ46gUwI2WyqaR(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUyIpotgj5KrYlFGefDzK3YJot4)qYbDjnQ)usuFNKrsQhwuj(6RXmEqH3ezCDdxRCaRGj(4mzKKtgjV8bYuucS6pLeCHzNKzCDdxlrBymiGv)PKGlm7KmJRB4AjU8zzBymiAu)PKO(ojJKupSOs8118Iru8dX(iB6CbIOOlJ82AmJhu4nrgx3W1khWkO(ojJKupSOYuucSb4iaEHLlM4JZKrsozK8Yhirrxg5TCY)tPDEGXra8clxWfMDsQhwujk6YiVPr9NscUWSts9WIkXlSCngbo83hncUWSts9kEOdTwJz8GcVjY46gUw5awbf)qSpYMoxGykkbw9NscUWStYmUUHRLOnmgeWQ)usWfMDsMX1nCTex(SSnmgen4iaEHLl4cZoj1dlQefDzK3uiyfxrAWra8clxmXhNjJKCYi5LpqIIUmYB5O4kkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhfxr5bghbWlSCbxy2jPEyrLOOlJ8MMl7SqhpkeSYNsJrGd)9rJGlm7KuVIh6qR1ygpOWBImUUHRvoGvaxy2jzuQMIsGFXik(HyFKnDUaru0LrEtHNsZJu)PKO4hI9r205ceP5pGtfRIaqJwI2WyqaRinQ)usuFNKrsQhwujEHLVgZ4bfEtKX1nCTYbSc4cZojv5Q4dYuuc8Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqaN)RXmEqH3ezCDdxRCaRaUWStsvaUnMIsGFXik(HyFKnDUaru0LrEtZJu)PKyIpotgj5KrYlFGefDzK3uiDMW)HKd6sAm4rQ)usu8dX(iB6CbI08hWPIvraOrlrBymiGvKsk9i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgK8YFT1ye6fzwEGFcLfCHzNKQCv8bTgZ4bfEtKX1nCTYbSc4cZojvb42ykkb(fJO4hI9r205cerrxg5nfsNj8Fi5GUKMhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGOqfP5rQ)usu8dX(iB6CbI08hWPIvraOrlrBymi5L)Au)PKO(ojJKupSOs8clFnMXdk8MiJRB4ALdyfWfMDsgLQPOey1Fkj4cZojXzCDqI2WyqYZeAu)PKGlm7KupSOs81xJz8GcVjY46gUw5awbCHzNKxuRHaOMPOey1FkjWaexyUni)queJhnQ)usWfMDsQhwuj(6MIZyKdw514C)cnAA0cZVWKTW3Vq(XcZT8BHrTW8DKFl0c5VWQTWjwO6hb8wioJRdQTqonuTWFd5hlm3km70cbnxfFqRXmEqH3ezCDdxRCaRa9IAKJjzKKxK)mfLaR(tjbxy2jjoJRds0ggdsEQ)usWfMDsIZ46Gex(SSnmgenQ)usWfMDsIZ46GeTHXGOqfPr9NscUWSts9WIkrrxg5nLus9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiAu)PKGlm7KeNX1bjAdJbrHksJ6pLe13jzKK6HfvIIUmYBAEK6pLet8XzYijNmsE5dKOOlJ82AmJhu4nrgx3W1khWkGlm7KufGBJPOey1Fkj0lQroMKrsEr(t811O(tjbxy2jjoJRds0ggdIcvEnMXdk8MiJRB4ALdyfWfMDsgLQPOey1Fkj4cZojXzCDqI2WyqYZeAWra8clxWfMDsQhwujk6YiVPqWMqr5Jg9C3b(PXimahbWlSCrXpe7JSPZfiIIUmYB5bwzfPbhbWlSCbxy2jPEyrLOOlJ8McbNVoL2RXmEqH3ezCDdxRCaRaUWStYOunfLaR(tjbxy2jjoJRds0ggdsEMqdocGxy5cUWSts9WIkrrxg5nfc2ekkF0ON7oWpn4WFF0i4cZoj1R4Ho0AnMXdk8MiJRB4ALdyfWfMDsErTgcGAMIsGv)PKGlm7KeNX1bjAdJbrHkRr9NscUWStYmUUHRLOnmgK8u)PKGlm7KmJRB4AjU8zzBymiMIZyKdw51ygpOWBImUUHRvoGvaxy2j5f1AiaQzkkbghbWlSCbxy2jzuQIIUmYB5L)Au)PKGlm7KmJRB4AjAdJbjp1Fkj4cZojZ46gUwIlFw2ggdIP4mg5GvEnMXdk8MiJRB4ALdyfWfMDsQYvXhKPOey1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0O(tjbxy2jzgx3W1s0ggdcy1Fkj4cZojZ46gUwIlFw2ggdYAmJhu4nrgx3W1khWkGmhyEqHBkkb(Yol0XtEkFQ14C)cZhYiFHQ0yrKVqCeaVWYxOfYFHvZ0fArlmCaTwO6hb8w4elm9bawioJRdQTqonuTWFd5hlm3km70cnAl11ygpOWBImUUHRvoGvaxy2jPka3gtrjWQ)usWfMDsIZ46GeTHXGOqLxJz8GcVjY46gUw5awbCHzNKxuRHaOMP4mg5GvEnEnMXdk8M4gMPl5toGvGkaYbrYUwMIsGVHz6s(iEO2WoMuiyLv0AmJhu4nXnmtxYNCaRa9IAKJjzKKxK)wJz8GcVjUHz6s(KdyfWfMDsErTgcGAMIsGVHz6s(iEO2WoMYtzfTgZ4bfEtCdZ0L8jhWkGlm7Kmk11ygpOWBIByMUKp5awbjursvaUnRXRXmEqH3eHo5uboHksQcWTXuucC9Dkf1bjEOggPdGCU0sIJ7L9Ng1FkjEOggPdGCU0sIJ7L9NmvrBeF91ygpOWBIqNCQYbScsv0gPhMztrjW13PuuhK4OqnaTKimcdqAUSZcD8Oqf7PwJz8GcVjcDYPkhWk4r8KPgLtRXmEqH3eHo5uLdyfu8dX(iB6CbIPOe4l7Sqhpkm)v0AmJhu4nrOtov5awbTmuAq(HupSOYuucS6pLeCHzNK6HfvIxy5AWra8clxWfMDsQhwujk6YiVTgZ4bfEte6KtvoGvWfvvunzKKtuxYN1ygpOWBIqNCQYbScM4JZKrsozK8YhO1ygpOWBIqNCQYbSc4cZoj1dlQwJz8GcVjcDYPkhWkO(ojJKupSOYuucS6pLe13jzKK6HfvIxy5RX5(fA00OfMFHjBHtSWw(8t0PdTq2xiDEkEH5wHzNwiOb42SW3Vq(XcNmAHNeJjtb5w(TqlK)cRf(DaQ1wy9Dh5hlm3km70cpn4SqSWtFAH5wHzNw4PbNfle1w4WaKp0Z0fArleZUHZc)nAH5xyYwOfAYq(cNmAHNeJjtb5w(TqlK)cRf(DaQ1wOfTqKpuvF9zHtgTWCZKTqCg7oby6cBXcTidbawyJntlenI1ygpOWBIqNCQYbSc0lQroMKrsEr(ZuucSrmma5JGlm7KKWzHMhP(tjXeFCMmsYjJKx(aj(6AEK6pLet8XzYijNmsE5dKOOlJ8wEGnGXdkCbxy2jPka3gbDMW)HKd6s5o1Fkj0lQroMKrsEr(tC5ZY2Wyq0Eno3VWtFAH5xyYwyg3CdNfQsKVWFJEl89lKFSWjJw4jXyYwOfYFHLPl0ImeayH)gTq0SWjwylF(j60Hwi7lKopfVWCRWStle0aCBwiYx4KrlmFh5NcYT8BHwi)fwI1ygpOWBIqNCQYbSc0lQroMKrsEr(ZuucS6pLeCHzNK6HfvIVUg1FkjQVtYij1dlQefDzK3YdSbmEqHl4cZojvb42iOZe(pKCqxk3P(tjHErnYXKmsYlYFIlFw2ggdI2mEqH3eHo5uLdyfWfMDsQcWTXuuc8lgrXpe7JSPZfiIIUmYBk8ukP0Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyquOIwJz8GcVjcDYPkhWkGlm7KufGBJPOey1Fkj0lQroMKrsEr(t8118i1FkjM4JZKrsozK8YhiXxxZJu)PKyIpotgj5KrYlFGefDzK3YdmJhu4cUWStsvaUnc6mH)djh0LwJZ9lm3aSyTAle0Cv8bTqEw4KrlK83cJ0cZT8BHwzKVW67oYpw4Krlm3km70cvmCDdxRfcqhK)4sR1ygpOWBIqNCQYbSc4cZojv5Q4dYuucS6pLeCHzNK6HfvIVUg1Fkj4cZoj1dlQefDzK3Y7a)0uFNsrDqcUWStsKNqoA0Ano3VWCdWI1QTqqZvXh0c5zHtgTqYFlmslCYOfMVJ8BHwi)fwl0kJ8fwF3r(XcNmAH5wHzNwOIHRB4ATqa6G8hxATgZ4bfEte6KtvoGvaxy2jPkxfFqMIsGv)PKO(ojJKupSOs811O(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQefDzK3Yd8b(PP(oLI6GeCHzNKipHC0O1AmJhu4nrOtov5awbCHzNKxuRHaOMPOe4hP(tjXeFCMmsYjJKx(aj(6AggG8rWfMDss4SqJbQ)us8iEYuJYjXlSCLuIXdYmjjNUiQbwzT18i1FkjM4JZKrsozK8Yhirrxg5nfY4bfUGlm7K8IAnea1e0zc)hsoOlzkoJroyLnL4cqljoJrUeLaR(tjbgG4cZTb5hsCg7obiEHLRXa1Fkj4cZoj1dlQeFDLuYaJyyaYhryMk9WIk6PXa1FkjQVtYij1dlQeFDLuchbWlSCbzoW8Gcxue)0sBT1EnMXdk8Mi0jNQCaRaUWStYlQ1qauZuucS6pLeyaIlm3gKFikIXJP4mg5GvEnMXdk8Mi0jNQCaRaUWStYOunfLaR(tjbxy2jjoJRds0ggdsEGnZfIvbiXeZvE5ZsCgxhuBnMXdk8Mi0jNQCaRaUWStsvaUnMIsGv)PKO(ojJKupSOs81vsPl7Sqhpku5tTgZ4bfEte6KtvoGvazoW8Gc3uucS6pLe13jzKK6HfvIxy5Au)PKGlm7KupSOs8cl3uKpuvF9rIsGVSZcD8OqWg9tzkYhQQV(ir3l9q8qGvEnMXdk8Mi0jNQCaRaUWStsvUk(GwJxJZ9lKXdk8MOIHhu45awby2XeGKXdkCtrjWmEqHliZbMhu4cCg7obG8dnx2zHoEuiyf7P0yGruFNsrDqIgsplCzBI6QKsQ)us0q6zHlBtuxrBymiGv)PKOH0Zcx2MOUIlFw2ggdI2RXmEqH3evm8GcphWkGmhyEqHBkkb(Yol0XtEGnZfIvbibzoK64rJb4iaEHLlM4JZKrsozK8Yhirrxg5T8aZ4bfUGmhyEqHlOZe(pKCqxsjLWra8clxWfMDsQhwujk6YiVLhygpOWfK5aZdkCbDMW)HKd6skPKbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWmEqHliZbMhu4c6mH)djh0L0wBnQ)usuFNKrsQhwujEHLRr9NscUWSts9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clxJrOxKz5b(juwmXhNjJKCYi5LpqRXmEqH3evm8GcphWkGmhyEqHBkkbU(oLI6GenKEw4Y2e1vdocGxy5cUWSts9WIkrrxg5T8aZ4bfUGmhyEqHlOZe(pKCqxAno3VqqZvXh0crPfIgdBlCqxAHtSWFJw4eZDHS)wOfTWm2mTWjIfEzxRfIZ46GARXmEqH3evm8GcphWkGlm7KuLRIpitrjW4iaEHLlM4JZKrsozK8Yhirr8tlngO(tjbxy2jjoJRds0ggdIcnZfIvbiXeZvE5ZsCgxhutdocGxy5cUWSts9WIkrrxg5T8atNj8Fi5GUKMl7Sqhpk0mxiwfGeSU8IC09FLx2zPoE0O(tjr9DsgjPEyrL4fwU2RXmEqH3evm8GcphWkGlm7KuLRIpitrjW4iaEHLlM4JZKrsozK8Yhirr8tlngO(tjbxy2jjoJRds0ggdIcnZfIvbiXeZvE5ZsCgxhutZWaKpI67Kmss9WIkn4iaEHLlQVtYij1dlQefDzK3YdmDMW)HKd6sAWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswx71ygpOWBIkgEqHNdyfWfMDsQYvXhKPOeyCeaVWYft8XzYijNmsE5dKOi(PLgdu)PKGlm7KeNX1bjAdJbrHM5cXQaKyI5kV8zjoJRdQPXaJyyaYhr9DsgjPEyrLskHJa4fwUO(ojJKupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKvORTgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11EnMXdk8MOIHhu45awbCHzNKQCv8bzkkb(rQ)usu8dX(iB6CbI08hWPIvraOrlrBymiGFK6pLef)qSpYMoxGin)bCQyveaA0sC5ZY2Wyq0yG6pLeCHzNK6HfvIxy5kPK6pLeCHzNK6HfvIIUmYB5b(a)0wJbQ)usuFNKrsQhwujEHLRKsQ)usuFNKrsQhwujk6YiVLh4d8t71ygpOWBIkgEqHNdyfWfMDsQcWTXuuc8lgrXpe7JSPZfiIIUmYBk0ORKsg8i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgefQinps9NsIIFi2hztNlqKM)aovSkcanAjAdJbjVhP(tjrXpe7JSPZfisZFaNkwfbGgTex(SSnmgeTxJz8GcVjQy4bfEoGvaxy2jPka3gtrjWQ)usOxuJCmjJK8I8N4RR5rQ)usmXhNjJKCYi5LpqIVUMhP(tjXeFCMmsYjJKx(ajk6YiVLhygpOWfCHzNKQaCBe0zc)hsoOlTgZ4bfEtuXWdk8CaRaUWStYlQ1qauZuuc8Ju)PKyIpotgj5KrYlFGeFDnddq(i4cZojjCwOXa1FkjEepzQr5K4fwUskX4bzMKKtxe1aRS2Am4rQ)usmXhNjJKCYi5LpqIIUmYBkKXdkCbxy2j5f1AiaQjOZe(pKCqxsjLWra8clxOxuJCmjJK8I8NOOlJ8MskHdZKZ(iarRcXU2MIZyKdwztjUa0sIZyKlrjWQ)usGbiUWCBq(HeNXUtaIxy5Amq9NscUWSts9WIkXxxjLmWiggG8reMPspSOIEAmq9NsI67Kmss9WIkXxxjLWra8clxqMdmpOWffXpT0wBTxJz8GcVjQy4bfEoGvaxy2j5f1AiaQzkkbw9NscmaXfMBdYpefX4rJ6pLe0zD2F0tQhd5dIbeF91ygpOWBIkgEqHNdyfWfMDsErTgcGAMIsGv)PKadqCH52G8drrmE0yG6pLeCHzNK6HfvIVUskP(tjr9DsgjPEyrL4RRKsps9NsIj(4mzKKtgjV8bsu0LrEtHmEqHl4cZojVOwdbqnbDMW)HKd6sABkoJroyLxJz8GcVjQy4bfEoGvaxy2j5f1AiaQzkkbw9NscmaXfMBdYpefX4rJ6pLeyaIlm3gKFiAdJbbS6pLeyaIlm3gKFiU8zzBymiMIZyKdw51ygpOWBIkgEqHNdyfWfMDsErTgcGAMIsGv)PKadqCH52G8drrmE0O(tjbgG4cZTb5hIIUmYB5b2adu)PKadqCH52G8drBymi5ogpOWfCHzNKxuRHaOMGot4)qYbDjTZ5a)02uCgJCWkVgZ4bfEtuXWdk8CaRaNMmQKdD1P2ykkb2GIsf1YyvasjLmIbHbb5hARr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgenQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3evm8GcphWkGlm7KmkvtrjWQ)usWfMDsIZ46GeTHXGKhyZCHyvasmXCLx(SeNX1b1wJz8GcVjQy4bfEoGvq7RtLhMztrjWx2zHoEYdSI9uAu)PKGlm7KupSOs8clxJ6pLe13jzKK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fw(AmJhu4nrfdpOWZbSc4cZojvb42ykkbw9NsI6dqYijNSIOM4RRr9NscUWStsCgxhKOnmgefQ4RXmEqH3evm8GcphWkGlm7KuLRIpitrjWx2zHoEYdSzUqSkaju5Q4dsEzNL64rJ6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOs8clxZJu)PKyIpotgj5KrYlFGeVWY1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdIgCeaVWYfK5aZdkCrrxg5T1ygpOWBIkgEqHNdyfWfMDsQYvXhKPOey1Fkj4cZoj1dlQeVWY1O(tjr9DsgjPEyrL4fwUMhP(tjXeFCMmsYjJKx(ajEHLRr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgenddq(i4cZojJsvdocGxy5cUWStYOuffDzK3Yd8b(P5Yol0XtEGvSksdocGxy5cYCG5bfUOOlJ82AmJhu4nrfdpOWZbSc4cZojv5Q4dYuucS6pLeCHzNK6HfvIVUg1Fkj4cZoj1dlQefDzK3Yd8b(Pr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgengGJa4fwUGmhyEqHlk6YiVPKs13PuuhKGlm7Ke5jKJgT0EnMXdk8MOIHhu45awbCHzNKQCv8bzkkbw9NsI67Kmss9WIkXxxJ6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOsu0LrElpWh4Ng1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0yaocGxy5cYCG5bfUOOlJ8MskvFNsrDqcUWStsKNqoA0s71ygpOWBIkgEqHNdyfWfMDsQYvXhKPOey1Fkj4cZoj1dlQeVWY1O(tjr9DsgjPEyrL4fwUMhP(tjXeFCMmsYjJKx(aj(6AEK6pLet8XzYijNmsE5dKOOlJ8wEGpWpnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGSgZ4bfEtuXWdk8CaRaUWStsvUk(GmfLapCDqJiJyGjtOJN8u8tPr9NscUWStsCgxhKOnmgefc2agpiZKKC6IOw(OYARP(oLI6GeCHzNKQXvLR3L8rdJhKzssoDrutHkRr9NsIhXtMAuojEHLVgZ4bfEtuXWdk8CaRaUWSts6Soq0qHBkkbE46GgrgXatMqhp5P4NsJ6pLeCHzNK4mUoirBymi5P(tjbxy2jjoJRdsC5ZY2Wyq0uFNsrDqcUWSts14QY17s(OHXdYmjjNUiQPqL1O(tjXJ4jtnkNeVWYxJz8GcVjQy4bfEoGvaxy2jPka3M1ygpOWBIkgEqHNdyfqMdmpOWnfLaR(tjr9DsgjPEyrL4fwUg1Fkj4cZoj1dlQeVWY18i1FkjM4JZKrsozK8YhiXlS81ygpOWBIkgEqHNdyfWfMDsQYvXhuF6tVd]] )
    
end