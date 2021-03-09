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


    spec:RegisterPack( "Arcane", 20210307.1, [[dWKI8fqikGEKir6suaeTjsXNOqgfjQtrISkrc4vQGMffQBjsGAxe(LksdduvhJuQLrb6zIKQPPIkDnvu12urf9nrsX4ejLoNirSorIAEQqUhOSpqvoOijTqvuEOiHUifG6JuaKgjfa1jPaWkPGMPijUPibTtve)uKazOQa1svrfEQiMQkuxLcq(Qkq0yvbSxP6VenyGdJAXK0JHAYQQlJSzk9zr1OfLtdz1uaeEnjy2GCBvA3u9BHHtQoUkqA5sEUuMUIRRkBxK67u04bvopPK1RceMpj0(v6U29J7jFEO(jge(guB4N6Wp1imyQRTbH)52tgT0PEIoJvGZPEIZxQNKQfMDQNOZAbf8VFCpPfVct9KSz0BP8PNMJMSNQah3tBO7dIhu44ITZPn0fFApr9HGgdaVR2t(8q9tmi8nO2Wp1HFQryWuxBdcFd2tA6eUFY50G9Km0)tExTN8PgUNKc5CAbPAHzNwdtHCHZwqQX4fyq4BqTxdxdph0nstlinxiwfIe8v2057cq(cSC6OwqyxqJMb55nbFLnD(UaLXzewHfOv8Qf00j8cc9bfEtjXAObuJwWOLocZqlibDtXfKX(hc55liSlaNXUtqla5dv1tFqHVaK3gI)liSlWim7ycsY4bfUrIEceQnT(X9KqNCQ6h3pr7(X9eYzvi63pRNGl0qfI7j1ZjBu5K4JAyKoeY5sljoUx2)cYzvi6Vanlq9zTIpQHr6qiNlTK44Ez)lTv0gXtVNW4bfEpXIksQcXTPp9tmy)4Ec5Ske97N1tWfAOcX9K65KnQCsKxOgKwsegHHib5Ske9xGMfCzNf64zbWBbPKZ3ty8GcVNyROnspsZ9PFsQ3pUNW4bfEp5t8KPgLt9eYzvi63pRp9to3(X9eYzvi63pRNGl0qfI7jx2zHoEwa8wW5c)EcJhu49KI)i2hztNlf6t)KZ3pUNqoRcr)(z9eCHgQqCpr9zTcUWSts9WKkXpm9fOzb4iG(HPl4cZoj1dtQefDzK36jmEqH3tAzi7G8CPEysvF6NCo7h3ty8GcVNCrvfvtgw5e1L8PNqoRcr)(z9PFsQPFCpHXdk8EYepCMmSYjJKxoh1tiNvHOF)S(0pj12pUNW4bfEpHlm7KupmPQNqoRcr)(z9PFskPFCpHCwfI(9Z6j4cnuH4EI6ZAf1ZjzyL6HjvIFy69egpOW7j1ZjzyL6Hjv9PFI2WVFCpHCwfI(9Z6jmEqH3t0lQroMKHvEr(VN8PgUq6dk8EIbuJwWbhPWfmXcAh0hrhe0cyFbeCtXlivlm70codIBZc(Vc55lyYOfCCmPWtt1dEbMi)hMl45quRTG65oYZxqQwy2PfyaJZcXcmaSlivlm70cmGXzXcqTfmme5d9nEbM0cWSB0SGxJwWbhPWfyIMmKVGjJwWXXKcpnvp4fyI8FyUGNdrT2cmPfG8HQ6PplyYOfKQPWfGZy3jiJxqlwGjzee0cACAAbOr0tWfAOcX9edCbddr(i4cZojjCwiiNvHO)c0SGpP(SwXepCMmSYjJKxohjE6lqZc(K6ZAft8WzYWkNmsE5CKOOlJ82coc2cuEbmEqHl4cZojvH42ii4i8Bi5GU0csbwG6ZAf6f1ihtYWkVi)lUmCY2WyfwGs9PFI2A3pUNqoRcr)(z9egpOW7j6f1ihtYWkVi)3t(udxi9bfEpXaWUGdosHliJBUrZcujYxWRr)f8FfYZxWKrl44ysHlWe5)W04fysgbbTGxJwaAwWelODqFeDqqlG9fqWnfVGuTWStl4miUnla5lyYOfCoId(0u9GxGjY)HPONGl0qfI7j)yef)rSpYMoxkik6YiVTa4TGZVafvCbFs9zTII)i2hztNlfKPFqovSkccnAjAdJvybWBbWVp9t02G9J7jKZQq0VFwpbxOHke3tuFwRqVOg5ysgw5f5FXtFbAwWNuFwRyIhotgw5KrYlNJep9fOzbFs9zTIjE4mzyLtgjVCosu0LrEBbhbBbmEqHl4cZojvH42ii4i8Bi5GUupHXdk8Ecxy2jPke3M(0pr7uVFCpHCwfI(9Z6jmEqH3t4cZojv5Q4CQN8PgUq6dk8EsQczYA1wWzCvCoTaEwWKrlG8)cc7cs1dEbMzKVG65oYZxWKrlivlm70cmaZ1nCTwaeLt(NlT6j4cnuH4EI6ZAfCHzNK6HjvIN(c0Sa1N1k4cZoj1dtQefDzK3wWrlih)xGMfupNSrLtcUWStsKBroA0sqoRcr)(0pr7ZTFCpHCwfI(9Z6jmEqH3t4cZojv5Q4CQN8PgUq6dk8EsQczYA1wWzCvCoTaEwWKrlG8)cc7cMmAbNJ4GxGjY)H5cmZiFb1ZDKNVGjJwqQwy2PfyaMRB4ATaikN8pxA1tWfAOcX9e1N1kQNtYWk1dtQep9fOzbQpRvWfMDsQhMuj(HPVanlq9zTI65KmSs9WKkrrxg5TfCeSfKJ)lqZcQNt2OYjbxy2jjYTihnAjiNvHOFF6NO957h3tiNvHOF)SEcoJrEpr7EcXfKwsCgJCjY2tuFwRadrCH52G8CjoJDNGe)W01OS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91OS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)APKsk1tWfAOcX9KpP(SwXepCMmSYjJKxohjE6lqZcggI8rWfMDss4SqqoRcr)fOzbkVa1N1k(epzQr5K4hM(cuuXfW4bLMKKtxe1waSfO9cuAbAwWNuFwRyIhotgw5KrYlNJefDzK3wa8waJhu4cUWStYlQ1qqutqWr43qYbDPEcJhu49eUWStYlQ1qquRp9t0(C2pUNqoRcr)(z9egpOW7jCHzNKxuRHGOwpbNXiVNODpbxOHke3tuFwRadrCH52G8CrrmE6t)eTtn9J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKyI5kVmCsCgx5uRNW4bfEpHlm7Kmk1(0pr7uB)4Ec5Ske97N1tWfAOcX9e1N1kQNtYWk1dtQep9fOOIl4Yol0XZcG3c0(89egpOW7jCHzNKQqCB6t)eTtj9J7jKZQq0VFwpHXdk8EcLoW8GcVNG8HQ6PpsKTNCzNf64bEWsTNVNG8HQ6Pps09sFepupr7EcUqdviUNO(Swr9CsgwPEysL4hM(c0Sa1N1k4cZoj1dtQe)W07t)edc)(X9egpOW7jCHzNKQCvCo1tiNvHOF)S(0NEIf1YqEUm0jNQ(X9t0UFCpHCwfI(9Z6jmEqH3tO0bMhu49Kp1WfsFqH3toiZiFb1ZDKNVacnzuTGjJwqsYcIAbhFqUaikN8pxiQz8cmPfyY(SGjwGbC6ybQKnkAbtgTGJJjfEAQEWlWe5)WuSadOgTa0SaUTGwe(c42cohXbVGmUTalYrTm6VG4vlWKmknTGMo5ZcIxTaCgx5uRNGl0qfI7jkVG65KnQCs0q6zHlBtuxb5Ske9xGIkUG65KnQCsm0vpkgsAYLUGCwfI(lqPfOzbkVa1N1kQNtYWk1dtQe)W0xGIkUa9IslZXFH2cUWStsvUkoNwGslqZcWra9dtxupNKHvQhMujk6YiV1N(jgSFCpHCwfI(9Z6jmEqH3tO0bMhu49Kp1WfsFqH3tmaSlWKmknTalYrTm6VG4vlahb0pm9fyI8Fy2wa7)f00jFwq8QfGZ4kNAgVa9cffAqhe0cmGthlist1cO0uP1KH88fqqnQNGl0qfI7jddr(iQNtYWk1dtQeKZQq0FbAwaocOFy6I65KmSs9WKkrrxg5TfOzb4iG(HPl4cZoj1dtQefDzK3wGMfO(Swbxy2jPEysL4hM(c0Sa1N1kQNtYWk1dtQe)W0xGMfOxuAzo(l0wWfMDsQYvX5uF6NK69J7jKZQq0VFwpbxOHke3tQNt2OYjXh1WiDiKZLwsCCVS)fKZQq0FbAwG6ZAfFudJ0HqoxAjXX9Y(xAROnINEpHXdk8EIfvKufIBtF6NCU9J7jKZQq0VFwpbxOHke3tQNt2OYjrEHAqAjryegIeKZQq0FbAwWLDwOJNfaVfKsoFpHXdk8EITI2i9in3N(jNVFCpHCwfI(9Z6j4cnuH4EIbUG65KnQCs0q6zHlBtuxb5Ske97jmEqH3t(epzQr5uF6NCo7h3tiNvHOF)SEcUqdviUNGJa6hMUOEojdRupmPsue)1QNW4bfEpHlm7Kmk1(0pj10pUNqoRcr)(z9eCHgQqCpbhb0pmDr9CsgwPEysLOi(R1c0Sa1N1k4cZojXzCLtI2WyfwWrlq9zTcUWStsCgx5K4YWjBdJvONW4bfEpHlm7KufIBtF6NKA7h3ty8GcVNupNKHvQhMu1tiNvHOF)S(0pjL0pUNqoRcr)(z9eCHgQqCpXaxGYlOEozJkNenKEw4Y2e1vqoRcr)fOOIlOEozJkNedD1JIHKMCPliNvHO)cuQN8PgUq6dk8EYjrDziiTwGjTaDgvlqpgu4l41OfyIMSfKQhSXlq9nlanlWebbTaiUnlak88fqE8YZwGnQfOgt2cMmAbNJ4Gxa7)fKQh8cmr(pmBl45quRTG65oYZxWKrlijzbrTGJpixaeLt(Nle16jmEqH3t0JbfEF6NOn87h3tiNvHOF)SEcUqdviUNO(Swr9CsgwPEysL4hM(cuuXfOxuAzo(l0wWfMDsQYvX5upHXdk8EYN4jtnkN6t)eT1UFCpHCwfI(9Z6j4cnuH4EI6ZAf1ZjzyL6HjvIFy6lqrfxGErPL54VqBbxy2jPkxfNt9egpOW7jf)rSpYMoxk0N(jABW(X9eYzvi63pRNGl0qfI7jQpRvupNKHvQhMuj(HPVafvCb6fLwMJ)cTfCHzNKQCvCo1ty8GcVNCrvfvtgw5e1L8Pp9t0o17h3tiNvHOF)SEcUqdviUNOxuAzo(l0wmXdNjdRCYi5LZr9egpOW7jCHzNK6Hjv9PFI2NB)4Ec5Ske97N1ty8GcVNOxuJCmjdR8I8Fp5tnCH0hu49edOgTGdosHlyIf0oOpIoiOfW(ci4MIxqQwy2PfCge3Mf8FfYZxWKrl44ysHNMQh8cmr(pmxWZHOwBb1ZDKNVGuTWStlWagNfIfyayxqQwy2PfyaJZIfGAlyyiYh6B8cmPfGz3OzbVgTGdosHlWenziFbtgTGJJjfEAQEWlWe5)WCbphIATfysla5dv1tFwWKrlivtHlaNXUtqgVGwSatYiiOf0400cqJONGl0qfI7jg4cggI8rWfMDss4SqqoRcr)fOzbFs9zTIjE4mzyLtgjVCos80xGMf8j1N1kM4HZKHvozK8Y5irrxg5TfCeSfO8cy8GcxWfMDsQcXTrqWr43qYbDPfKcSa1N1k0lQroMKHvEr(xCz4KTHXkSaL6t)eTpF)4Ec5Ske97N1ty8GcVNOxuJCmjdR8I8Fp5tnCH0hu49eda7co4ifUGmU5gnlqLiFbVg9xW)vipFbtgTGJJjfUatK)dtJxGjzee0cEnAbOzbtSG2b9r0bbTa2xab3u8cs1cZoTGZG42SaKVGjJwW5io4tt1dEbMi)hMIEcUqdviUNO(Swbxy2jPEysL4PVanlq9zTI65KmSs9WKkrrxg5TfCeSfO8cy8GcxWfMDsQcXTrqWr43qYbDPfKcSa1N1k0lQroMKHvEr(xCz4KTHXkSaL6t)eTpN9J7jKZQq0VFwpbxOHke3t(Xik(JyFKnDUuqu0LrEBbWBbNFbkQ4c(K6ZAff)rSpYMoxkit)GCQyveeA0s0ggRWcG3cGFpHXdk8Ecxy2jPke3M(0pr7ut)4Ec5Ske97N1ty8GcVNWfMDsQYvX5up5tnCH0hu49KdsAbMSplyIfCzfOf0EfTatAbzCAAbKhV8SfCzNxGnQfmz0ciFqfTGu9GxGjY)HPXlGst(cq2fmzurg1wqBqqqlyqxAbfDzKJ88fe(cohXblwGbWyuBbHdP1cuPzOAbtSa1x5lyIfCqqvSa2)lWaoDSaKDb1ZDKNVGjJwqsYcIAbhFqUaikN8pxiQj6j4cnuH4EcocOFy6cUWSts9WKkrr8xRfOzbx2zHoEwWrlq5fCUWFbhUaLxG2WFbPalahPjN9rOGwfI9fO0cuAbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2WyfwGMfyGlOEozJkNenKEw4Y2e1vqoRcr)fOzbg4cQNt2OYjXqx9OyiPjx6cYzvi63N(jANA7h3tiNvHOF)SEcJhu49eUWStsvUkoN6jFQHlK(GcVNya5quRTG65oYZxWKrlivlm70cmaZ1nCTwaeLt(NlTmEbNXvX50cAzXd6VapMfOsl41O)c4zbtgTaY)liSlivp4fGSlWaoDG5bf(cqTfew7cWra9dtFbCBb)k01rE(cWzCLtTfyIGGwWLvGwaAwWWkqlak8CQwWelq9v(cMSkE5zlOOlJCKNVGl7CpbxOHke3tuFwRGlm7KupmPs80xGMfO(Swbxy2jPEysLOOlJ82coc2cYX)fOzbkVG65KnQCsWfMDsIClYrJwcYzvi6VafvCb4iG(HPlO0bMhu4IIUmYBlqP(0pr7us)4Ec5Ske97N1ty8GcVNWfMDsQYvX5up5tnCH0hu49KZ4Q4CAbTS4b9xadzYA1wGkTGjJwae3MfG52SaKVGjJwW5io4fyI8FyUaUTGJJjfUatee0ckQnrrlyYOfGZ4kNAlOPt(0tWfAOcX9e1N1kQNtYWk1dtQep9fOzbQpRvWfMDsQhMuj(HPVanlq9zTI65KmSs9WKkrrxg5TfCeSfKJ)9PFIbHF)4Ec5Ske97N1tWzmY7jA3tiUG0sIZyKlr2EI6ZAfyiIlm3gKNlXzS7eK4hMUgLvFwRGlm7KupmPs80vurLnWHHiFerAQ0dtQOVgLvFwROEojdRupmPs80vurCeq)W0fu6aZdkCrr8xlLusPEcUqdviUN8j1N1kM4HZKHvozK8Y5iXtFbAwWWqKpcUWStscNfcYzvi6Vanlq5fO(SwXN4jtnkNe)W0xGIkUagpO0KKC6IO2cGTaTxGslqZc(K6ZAft8WzYWkNmsE5CKOOlJ82cG3cy8GcxWfMDsErTgcIAccoc)gsoOl1ty8GcVNWfMDsErTgcIA9PFIb1UFCpHCwfI(9Z6jFQHlK(GcVNKcYH0AbTHRzbVgYZxqkMIlivtHlWmJ8fKQh8cY42cujYxWRr)EcUqdviUNO(SwbgI4cZTb55IIy8Sanlahb0pmDbxy2jPEysLOOlJ82c0SaLxG6ZAf1ZjzyL6HjvIN(cuuXfO(Swbxy2jPEysL4PVaL6j4mg59eT7jmEqH3t4cZojVOwdbrT(0pXGgSFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK4mUYjrByScl4iylinxiwfIetmx5LHtIZ4kNA9egpOW7jCHzNKrP2N(jgm17h3tiNvHOF)SEcUqdviUNO(Swr9CsgwPEysL4PVafvCbx2zHoEwa8wG2NVNW4bfEpHlm7KufIBtF6NyWZTFCpHCwfI(9Z6jmEqH3tO0bMhu49eKpuvp9rIS9Kl7SqhpWdwQ989eKpuvp9rIUx6J4H6jA3tWfAOcX9e1N1kQNtYWk1dtQe)W0xGMfO(Swbxy2jPEysL4hMEF6NyWZ3pUNW4bfEpHlm7KuLRIZPEc5Ske97N1N(0t4RSPZ3(X9t0UFCpHCwfI(9Z6jmEqH3tO0bMhu49Kp1WfsFqH3ty8GcVj4RSPZxyy2XeKKXdkCJrwymEqHlO0bMhu4cCg7obH8Cnx2zHoEGhSuY57j4cnuH4EYLDwOJNfCeSfKMleRcrckDi1XZc0SaLxaocOFy6IjE4mzyLtgjVCosu0LrEBbhbBbmEqHlO0bMhu4ccoc)gsoOlTafvCb4iG(HPl4cZoj1dtQefDzK3wWrWwaJhu4ckDG5bfUGGJWVHKd6slqrfxGYlyyiYhr9CsgwPEysLGCwfI(lqZcWra9dtxupNKHvQhMujk6YiVTGJGTagpOWfu6aZdkCbbhHFdjh0LwGslqPfOzbQpRvupNKHvQhMuj(HPVanlq9zTcUWSts9WKkXpm9fOzbFs9zTIjE4mzyLtgjVCos8dtVp9tmy)4Ec5Ske97N1tWfAOcX9eCeq)W0fCHzNK6HjvIIUmYBla2cG)c0SaLxG6ZAf1ZjzyL6HjvIFy6lqZcuEb4iG(HPlM4HZKHvozK8Y5irrxg5TfaVfKMleRcrcwxEz4KFcI1sAJsoXCxGIkUaCeq)W0ft8WzYWkNmsE5CKOOlJ82cGTa4VaLwGs9egpOW7jFINm1OCQp9ts9(X9eYzvi63pRNGl0qfI7j4iG(HPl4cZoj1dtQefDzK3waSfa)fOzbkVa1N1kQNtYWk1dtQe)W0xGMfO8cWra9dtxmXdNjdRCYi5LZrIIUmYBlaElinxiwfIeSU8YWj)eeRL0gLCI5UafvCb4iG(HPlM4HZKHvozK8Y5irrxg5TfaBbWFbkTaL6jmEqH3tUOQIQjdRCI6s(0N(jNB)4EcJhu49KI)i2hztNlf6jKZQq0VFwF6NC((X9eYzvi63pRNGl0qfI7jQpRvWfMDsQhMuj(HPVanlahb0pmDbxy2jPEysLyQhjl6YiVTa4TagpOWfTmKDqEUupmPsG)1c0Sa1N1kQNtYWk1dtQe)W0xGMfGJa6hMUOEojdRupmPsm1JKfDzK3wa8waJhu4IwgYoipxQhMujW)AbAwWNuFwRyIhotgw5KrYlNJe)W07jmEqH3tAzi7G8CPEysvF6NCo7h3tiNvHOF)SEcUqdviUNO(Swr9CsgwPEysL4hM(c0SaCeq)W0fCHzNK6HjvIIUmYB9egpOW7j1ZjzyL6Hjv9PFsQPFCpHCwfI(9Z6j4cnuH4EIYlahb0pmDbxy2jPEysLOOlJ82cGTa4Vanlq9zTI65KmSs9WKkXpm9fO0cuuXfOxuAzo(l0wupNKHvQhMu1ty8GcVNmXdNjdRCYi5LZr9PFsQTFCpHCwfI(9Z6j4cnuH4EcocOFy6cUWSts9WKkrrxg5TfC0cop8xGMfO(Swr9CsgwPEysL4hM(c0SaQ1ihtI0OgkCzyL6uzj8GcxqoRcr)EcJhu49KjE4mzyLtgjVCoQp9tsj9J7jKZQq0VFwpbxOHke3tuFwROEojdRupmPs8dtFbAwaocOFy6IjE4mzyLtgjVCosu0LrEBbWBbP5cXQqKG1Lxgo5NGyTK2OKtm3EcJhu49eUWSts9WKQ(0prB43pUNqoRcr)(z9eCHgQqCpr9zTcUWSts9WKkXtFbAwG6ZAfCHzNK6HjvIIUmYBl4iylGXdkCbxy2j5f1AiiQji4i8Bi5GU0c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXk0ty8GcVNWfMDsQYvX5uF6NOT29J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybhTa1N1k4cZojXzCLtIldNSnmwHfOzbQpRvupNKHvQhMuj(HPVanlq9zTcUWSts9WKkXpm9fOzbFs9zTIjE4mzyLtgjVCos8dtVNW4bfEpHlm7Kmk1(0prBd2pUNqoRcr)(z9eCHgQqCpr9zTI65KmSs9WKkXpm9fOzbQpRvWfMDsQhMuj(HPVanl4tQpRvmXdNjdRCYi5LZrIFy6lqZcuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRqpHXdk8Ecxy2jPkxfNt9PFI2PE)4Ec5Ske97N1tWzmY7jA3tiUG0sIZyKlr2EI6ZAfyiIlm3gKNlXzS7eK4hMUgLvFwRGlm7KupmPs80vur1N1kQNtYWk1dtQepDfvehb0pmDbLoW8Gcxue)1sPEcUqdviUNO(SwbgI4cZTb55IIy80ty8GcVNWfMDsErTgcIA9PFI2NB)4Ec5Ske97N1tWzmY7jA3tiUG0sIZyKlr2EI6ZAfyiIlm3gKNlXzS7eK4hMUgLvFwRGlm7KupmPs80vur1N1kQNtYWk1dtQepDfvehb0pmDbLoW8Gcxue)1sPEcUqdviUNyGlGpiOcnKGlm7Ku)DVeeYZfKZQq0FbkQ4cuFwRadrCH52G8CjoJDNGe)W07jmEqH3t4cZojVOwdbrT(0pr7Z3pUNqoRcr)(z9eCHgQqCpr9zTI65KmSs9WKkXpm9fOzbQpRvWfMDsQhMuj(HPVanl4tQpRvmXdNjdRCYi5LZrIFy69egpOW7ju6aZdk8(0pr7Zz)4Ec5Ske97N1tWfAOcX9e1N1k4cZojXzCLtI2WyfwWrlq9zTcUWStsCgx5K4YWjBdJvONW4bfEpHlm7Kmk1(0pr7ut)4EcJhu49eUWStsvUkoN6jKZQq0VFwF6NODQTFCpHXdk8Ecxy2jPke3MEc5Ske97N1N(0tQy4bfE)4(jA3pUNqoRcr)(z9egpOW7ju6aZdk8EYNA4cPpOW7jmEqH3evm8Gc)qyNIzhtqsgpOWngzHX4bfUGshyEqHlWzS7eeYZ1CzNf64bEWsjNxJYgy9CYgvojAi9SWLTjQRIkQ(SwrdPNfUSnrDfTHXkat9zTIgsplCzBI6kUmCY2WyfuQNGl0qfI7jx2zHoEwWrWwqAUqSkejO0HuhplqZcuEb4iG(HPlM4HZKHvozK8Y5irrxg5TfCeSfW4bfUGshyEqHli4i8Bi5GU0cuuXfGJa6hMUGlm7KupmPsu0LrEBbhbBbmEqHlO0bMhu4ccoc)gsoOlTafvCbkVGHHiFe1ZjzyL6HjvcYzvi6Vanlahb0pmDr9CsgwPEysLOOlJ82coc2cy8GcxqPdmpOWfeCe(nKCqxAbkTaLwGMfO(Swr9CsgwPEysL4hM(c0Sa1N1k4cZoj1dtQe)W0xGMf8j1N1kM4HZKHvozK8Y5iXpm9fOzbg4c0lkTmh)fAlM4HZKHvozK8Y5O(0pXG9J7jKZQq0VFwpbxOHke3tQNt2OYjrdPNfUSnrDfKZQq0FbAwaocOFy6cUWSts9WKkrrxg5TfCeSfW4bfUGshyEqHli4i8Bi5GUupHXdk8EcLoW8GcVp9ts9(X9eYzvi63pRNW4bfEpHlm7KuLRIZPEYNA4cPpOW7jNXvX50cq2fGgJAlyqxAbtSGxJwWeZDbS)xGjTGmonTGjIfCzxRfGZ4kNA9eCHgQqCpbhb0pmDXepCMmSYjJKxohjkI)ATanlq5fO(Swbxy2jjoJRCs0ggRWcG3csZfIvHiXeZvEz4K4mUYP2c0SaCeq)W0fCHzNK6HjvIIUmYBl4iylGGJWVHKd6slqZcUSZcD8Sa4TG0CHyvisW6YlYr33vEzNL64zbAwG6ZAf1ZjzyL6HjvIFy6lqP(0p5C7h3tiNvHOF)SEcUqdviUNGJa6hMUyIhotgw5KrYlNJefXFTwGMfO8cuFwRGlm7KeNXvojAdJvybWBbP5cXQqKyI5kVmCsCgx5uBbAwWWqKpI65KmSs9WKkb5Ske9xGMfGJa6hMUOEojdRupmPsu0LrEBbhbBbeCe(nKCqxAbAwaocOFy6cUWSts9WKkrrxg5TfaVfKMleRcrIjMR8YWj)eeRL0gLK1xGs9egpOW7jCHzNKQCvCo1N(jNVFCpHCwfI(9Z6j4cnuH4EcocOFy6IjE4mzyLtgjVCosue)1AbAwGYlq9zTcUWStsCgx5KOnmwHfaVfKMleRcrIjMR8YWjXzCLtTfOzbkVadCbddr(iQNtYWk1dtQeKZQq0FbkQ4cWra9dtxupNKHvQhMujk6YiVTa4TG0CHyvismXCLxgo5NGyTK2OKvOVaLwGMfGJa6hMUGlm7KupmPsu0LrEBbWBbP5cXQqKyI5kVmCYpbXAjTrjz9fOupHXdk8Ecxy2jPkxfNt9PFY5SFCpHCwfI(9Z6j4cnuH4EYNuFwRO4pI9r205sbz6hKtfRIGqJwI2WyfwaSf8j1N1kk(JyFKnDUuqM(b5uXQii0OL4YWjBdJvybAwGYlq9zTcUWSts9WKkXpm9fOOIlq9zTcUWSts9WKkrrxg5TfCeSfKJ)lqPfOzbkVa1N1kQNtYWk1dtQe)W0xGIkUa1N1kQNtYWk1dtQefDzK3wWrWwqo(VaL6jmEqH3t4cZojv5Q4CQp9tsn9J7jKZQq0VFwpbxOHke3t(Xik(JyFKnDUuqu0LrEBbWBbP2fOOIlq5f8j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwHfaVfa)fOzbFs9zTII)i2hztNlfKPFqovSkccnAjAdJvybhTGpP(SwrXFe7JSPZLcY0piNkwfbHgTexgozBySclqPEcJhu49eUWStsviUn9PFsQTFCpHCwfI(9Z6j4cnuH4EI6ZAf6f1ihtYWkVi)lE6lqZc(K6ZAft8WzYWkNmsE5CK4PVanl4tQpRvmXdNjdRCYi5LZrIIUmYBl4iylGXdkCbxy2jPke3gbbhHFdjh0L6jmEqH3t4cZojvH420N(jPK(X9eYzvi63pRNGZyK3t0UNqCbPLeNXixIS9e1N1kWqexyUnipxIZy3jiXpmDnkR(Swbxy2jPEysL4PROIkBGddr(iI0uPhMurFnkR(Swr9CsgwPEysL4PROI4iG(HPlO0bMhu4II4VwkPKs9eCHgQqCp5tQpRvmXdNjdRCYi5LZrIN(c0SGHHiFeCHzNKeoleKZQq0FbAwGYlq9zTIpXtMAuoj(HPVafvCbmEqPjj50frTfaBbAVaLwGMfO8c(K6ZAft8WzYWkNmsE5CKOOlJ82cG3cy8GcxWfMDsErTgcIAccoc)gsoOlTafvCb4iG(HPl0lQroMKHvEr(xu0LrEBbkQ4cWrAYzFekOvHyFbk1ty8GcVNWfMDsErTgcIA9PFI2WVFCpHCwfI(9Z6j4cnuH4EI6ZAfyiIlm3gKNlkIXZc0Sa1N1ki40z)tFPEmKpigs807jmEqH3t4cZojVOwdbrT(0prBT7h3tiNvHOF)SEcJhu49eUWStYlQ1qquRNGZyK3t0UNGl0qfI7jQpRvGHiUWCBqEUOigplqZcuEbQpRvWfMDsQhMujE6lqrfxG6ZAf1ZjzyL6HjvIN(cuuXf8j1N1kM4HZKHvozK8Y5irrxg5TfaVfW4bfUGlm7K8IAnee1eeCe(nKCqxAbk1N(jABW(X9eYzvi63pRNW4bfEpHlm7K8IAnee16j4mg59eT7j4cnuH4EI6ZAfyiIlm3gKNlkIXZc0Sa1N1kWqexyUnipx0ggRWcGTa1N1kWqexyUnipxCz4KTHXk0N(jAN69J7jKZQq0VFwpHXdk8Ecxy2j5f1AiiQ1tWzmY7jA3tWfAOcX9e1N1kWqexyUnipxueJNfOzbQpRvGHiUWCBqEUOOlJ82coc2cuEbkVa1N1kWqexyUnipx0ggRWcsbwaJhu4cUWStYlQ1qqutqWr43qYbDPfO0coCb54)cuQp9t0(C7h3tiNvHOF)SEcUqdviUNO8ckYwulJvHOfOOIlWaxWGWkG88fO0c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXkSanlq9zTcUWSts9WKkXpm9fOzbFs9zTIjE4mzyLtgjVCos8dtVNW4bfEpXPjJk5qxDQn9PFI2NVFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK4mUYjrByScl4iylinxiwfIetmx5LHtIZ4kNA9egpOW7jCHzNKrP2N(jAFo7h3tiNvHOF)SEcUqdviUNCzNf64zbhbBbPKZVanlq9zTcUWSts9WKkXpm9fOzbQpRvupNKHvQhMuj(HPVanl4tQpRvmXdNjdRCYi5LZrIFy69egpOW7jTNovEKM7t)eTtn9J7jKZQq0VFwpbxOHke3tuFwROEqKmSYjRiQjE6lqZcuFwRGlm7KeNXvojAdJvybWBbPEpHXdk8Ecxy2jPke3M(0pr7uB)4Ec5Ske97N1tWfAOcX9Kl7Sqhpl4iylinxiwfIeQCvCojVSZsD8Sanlq9zTcUWSts9WKkXpm9fOzbQpRvupNKHvQhMuj(HPVanl4tQpRvmXdNjdRCYi5LZrIFy6lqZcuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRWc0SaCeq)W0fu6aZdkCrrxg5TEcJhu49eUWStsvUkoN6t)eTtj9J7jKZQq0VFwpbxOHke3tuFwRGlm7KupmPs8dtFbAwG6ZAf1ZjzyL6HjvIFy6lqZc(K6ZAft8WzYWkNmsE5CK4hM(c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXkSanlyyiYhbxy2jzuQcYzvi6Vanlahb0pmDbxy2jzuQIIUmYBl4iylih)xGMfCzNf64zbhbBbPe4Vanlahb0pmDbLoW8Gcxu0LrERNW4bfEpHlm7KuLRIZP(0pXGWVFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK6HjvIN(c0Sa1N1k4cZoj1dtQefDzK3wWrWwqo(Vanlq9zTcUWStsCgx5KOnmwHfaBbQpRvWfMDsIZ4kNexgozBySclqZcuEb4iG(HPlO0bMhu4IIUmYBlqrfxq9CYgvoj4cZojrUf5Orlb5Ske9xGs9egpOW7jCHzNKQCvCo1N(jgu7(X9eYzvi63pRNGl0qfI7jQpRvupNKHvQhMujE6lqZcuFwRGlm7KupmPs8dtFbAwG6ZAf1ZjzyL6HjvIIUmYBl4iylih)xGMfO(Swbxy2jjoJRCs0ggRWcGTa1N1k4cZojXzCLtIldNSnmwHfOzbkVaCeq)W0fu6aZdkCrrxg5TfOOIlOEozJkNeCHzNKi3IC0OLGCwfI(lqPEcJhu49eUWStsvUkoN6t)edAW(X9eYzvi63pRNGl0qfI7jQpRvWfMDsQhMuj(HPVanlq9zTI65KmSs9WKkXpm9fOzbFs9zTIjE4mzyLtgjVCos80xGMf8j1N1kM4HZKHvozK8Y5irrxg5TfCeSfKJ)lqZcuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRqpHXdk8Ecxy2jPkxfNt9PFIbt9(X9eYzvi63pRNGl0qfI7jdx50iYigAYe64zbhTGu)8lqZcuFwRGlm7KeNXvojAdJvybWd2cuEbmEqPjj50frTfKcEbAVaLwGMfupNSrLtcUWSts14QY1)s(iiNvHO)c0SagpO0KKC6IO2cG3c0EbAwG6ZAfFINm1OCs8dtVNW4bfEpHlm7KuLRIZP(0pXGNB)4Ec5Ske97N1tWfAOcX9KHRCAezednzcD8SGJwqQF(fOzbQpRvWfMDsIZ4kNeTHXkSGJwG6ZAfCHzNK4mUYjXLHt2ggRWc0SG65KnQCsWfMDsQgxvU(xYhb5Ske9xGMfW4bLMKKtxe1wa8wG2lqZcuFwR4t8KPgLtIFy69egpOW7jCHzNKeC6qrdfEF6NyWZ3pUNW4bfEpHlm7KufIBtpHCwfI(9Z6t)edEo7h3tiNvHOF)SEcUqdviUNO(Swr9CsgwPEysL4hM(c0Sa1N1k4cZoj1dtQe)W0xGMf8j1N1kM4HZKHvozK8Y5iXpm9EcJhu49ekDG5bfEF6NyWut)4EcJhu49eUWStsvUkoN6jKZQq0VFwF6tp5tw(bn9J7NOD)4EcJhu49eC88HQMobb1tiNvHOF)S(0pXG9J7jKZQq0VFwpj07jnA6jmEqH3tsZfIvHOEsAg6r9eT7j4cnuH4EsAUqSkejY40Km0jN(la2cG)c0Sa9IslZXFH2ckDG5bf(c0SadCbkVG65KnQCs0q6zHlBtuxb5Ske9xGIkUG65KnQCsm0vpkgsAYLUGCwfI(lqPEsAUKoFPEsgNMKHo50Vp9ts9(X9eYzvi63pRNe69Kgn9egpOW7jP5cXQqupjnd9OEI29eCHgQqCpjnxiwfIezCAsg6Kt)faBbWFbAwG6ZAfCHzNK6HjvIFy6lqZcWra9dtxWfMDsQhMujk6YiVTanlq5fupNSrLtIgsplCzBI6kiNvHO)cuuXfupNSrLtIHU6rXqstU0fKZQq0Fbk1tsZL05l1tY40Km0jN(9PFY52pUNqoRcr)(z9KqVN0OPNW4bfEpjnxiwfI6jPzOh1t0UNGl0qfI7jQpRvWfMDsIZ4kNeTHXkSaylq9zTcUWStsCgx5K4YWjBdJvybAwGbUa1N1kQhejdRCYkIAIN(c0Sa1O1wGMfyr5zJSOlJ82coc2cuEbkVGl78coDbmEqHl4cZojvH42iWrBwGslifybmEqHl4cZojvH42ii4i8Bi5GU0cuQNKMlPZxQNyrodjvFL3N(jNVFCpHCwfI(9Z6j4cnuH4EIYlyyiYhb5qO8SHC6liNvHO)c0SGl7Sqhpl4iyli1c)fOzbx2zHoEwa8GTGZ55xGslqrfxGYlWaxWWqKpcYHq5zd50xqoRcr)fOzbx2zHoEwWrWwqQ98lqPEcJhu49Kl7SmNU9PFY5SFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK6HjvINEpHXdk8EIEmOW7t)Kut)4Ec5Ske97N1tWfAOcX9K65KnQCsm0vpkgsAYLUGCwfI(lqZcuFwRGGlJFTbfU4PVanlq5fGJa6hMUGlm7KupmPsue)1AbkQ4cuJwBbAwGfLNnYIUmYBl4iyl4CH)cuQNW4bfEpzqxsAYLEF6NKA7h3tiNvHOF)SEcUqdviUNO(Swbxy2jPEysL4hM(c0Sa1N1kQNtYWk1dtQe)W0xGMf8j1N1kM4HZKHvozK8Y5iXpm9EcJhu49eiuE20KgG49ZVKp9PFskPFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK6HjvIFy6lqZcuFwROEojdRupmPs8dtFbAwWNuFwRyIhotgw5KrYlNJe)W07jmEqH3tu5CzyLtHWk06t)eTHF)4Ec5Ske97N1tWfAOcX9e1N1k4cZoj1dtQep9EcJhu49evQAuPaYZ7t)eT1UFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK6HjvINEpHXdk8EIkueFP9vA1N(jABW(X9eYzvi63pRNGl0qfI7jQpRvWfMDsQhMujE69egpOW7jwurQqr87t)eTt9(X9eYzvi63pRNGl0qfI7jQpRvWfMDsQhMujE69egpOW7jSJP2umKeZqq9PFI2NB)4Ec5Ske97N1tWfAOcX9e1N1k4cZoj1dtQep9EcJhu49KxJKOHUT(0pr7Z3pUNqoRcr)(z9egpOW7j5q8hXtunPk)ZPEcUqdviUNO(Swbxy2jPEysL4PVafvCb4iG(HPl4cZoj1dtQefDzK3wa8GTGZF(fOzbFs9zTIjE4mzyLtgjVCos807jK1s4r68L6j5q8hXtunPk)ZP(0pr7Zz)4Ec5Ske97N1ty8GcVNqxDTkIHKr9D2XupbxOHke3tWra9dtxWfMDsQhMujk6YiVTGJGTadc)EIZxQNqxDTkIHKr9D2XuF6NODQPFCpHCwfI(9Z6jmEqH3t(fXFlQizAQ1iOEcUqdviUNGJa6hMUGlm7KupmPsu0LrEBbWd2cmi8xGIkUadCbP5cXQqKG1LHlFnAbWwG2lqrfxGYlyqxAbWwa8xGMfKMleRcrclQLH8CzOtovla2c0EbAwq9CYgvojAi9SWLTjQRGCwfI(lqPEIZxQN8lI)wurY0uRrq9PFI2P2(X9eYzvi63pRNW4bfEpPfpijk3rdv9eCHgQqCpbhb0pmDbxy2jPEysLOOlJ82cGhSfK6WFbkQ4cmWfKMleRcrcwxgU81OfaBbA3tC(s9Kw8GKOChnu1N(jANs6h3tiNvHOF)SEcJhu49KCiT0ZKHvYTg6IG4bfEpbxOHke3tWra9dtxWfMDsQhMujk6YiVTa4bBbge(lqrfxGbUG0CHyvisW6YWLVgTaylq7fOOIlq5fmOlTayla(lqZcsZfIvHiHf1YqEUm0jNQfaBbAVanlOEozJkNenKEw4Y2e1vqoRcr)fOupX5l1tYH0sptgwj3AOlcIhu49PFIbHF)4Ec5Ske97N1ty8GcVNCzmRwKSLr0iVVgc3tWfAOcX9eCeq)W0fCHzNK6HjvIIUmYBl4iyl48lqZcuEbg4csZfIvHiHf1YqEUm0jNQfaBbAVafvCbd6slaEli1H)cuQN48L6jxgZQfjBzenY7RHW9PFIb1UFCpHCwfI(9Z6jmEqH3tUmMvls2YiAK3xdH7j4cnuH4EcocOFy6cUWSts9WKkrrxg5TfCeSfC(fOzbP5cXQqKWIAzipxg6Kt1cGTaTxGMfO(Swr9CsgwPEysL4PVanlq9zTI65KmSs9WKkrrxg5TfCeSfO8c0g(lif8co)csbwq9CYgvojAi9SWLTjQRGCwfI(lqPfOzbd6sl4OfK6WVN48L6jxgZQfjBzenY7RHW9PFIbny)4Ec5Ske97N1tWfAOcX9egpO0KKC6IO2cG3cmypPnfcp9t0UNW4bfEpbZqqsgpOWLqO20tGqTr68L6jCq9PFIbt9(X9eYzvi63pRNGl0qfI7j4in5Spcf0QqSVanlOEozJkNeCHzNKi3IC0OLGCwfI(lqZcggI8rupNKHvQhMujiNvHO)c0SadCb4W)p0i4cZoj1R4JY1sqoRcr)EsBkeE6NODpHXdk8EcMHGKmEqHlHqTPNaHAJ05l1tY46gUw9PFIbp3(X9eYzvi63pRN8PgUq6dk8EYXz0cSOwgYZxqOtovlqLYrEBbMOjBbNJ4Gxa7)fyrTmQTaBuliftXfOxbUTGjwWRrl4)kKNVGJJjfEAQEW9egpOW7jygcsY4bfUec1MEsBkeE6NODpbxOHke3tsZfIvHirgNMKHo50FbWwa8xGMfKMleRcrclQLH8CzOtov9eiuBKoFPEIf1YqEUm0jNQ(0pXGNVFCpHCwfI(9Z6j4cnuH4EsAUqSkejY40Km0jN(la2cGFpPnfcp9t0UNW4bfEpbZqqsgpOWLqO20tGqTr68L6jHo5u1N(jg8C2pUNqoRcr)(z9eCHgQqCpPrZG88MGVYMoFxaSfODpPnfcp9t0UNW4bfEpbZqqsgpOWLqO20tGqTr68L6j8v205BF6NyWut)4Ec5Ske97N1ty8GcVNGziijJhu4siuB6jqO2iD(s9eCeq)W0B9PFIbtT9J7jKZQq0VFwpbxOHke3tsZfIvHiHf5mKu9v(cGTa43tAtHWt)eT7jmEqH3tWmeKKXdkCjeQn9eiuBKoFPEsfdpOW7t)edMs6h3tiNvHOF)SEcUqdviUNKMleRcrclYziP6R8faBbA3tAtHWt)eT7jmEqH3tWmeKKXdkCjeQn9eiuBKoFPEIf5mKu9vEF6NK6WVFCpHCwfI(9Z6jmEqH3tWmeKKXdkCjeQn9eiuBKoFPEYnstxYN(0NEYnstxYN(X9t0UFCpHCwfI(9Z6j4cnuH4EYnstxYhXh1g2X0cGhSfOn87jmEqH3tuHqUc9PFIb7h3ty8GcVNOxuJCmjdR8I8FpHCwfI(9Z6t)KuVFCpHCwfI(9Z6j4cnuH4EYnstxYhXh1g2X0coAbAd)EcJhu49eUWStYlQ1qquRp9to3(X9egpOW7jCHzNKrP2tiNvHOF)S(0p589J7jmEqH3tSOIKQqCB6jKZQq0VFwF6tprViCCv5PFC)eT7h3ty8GcVNWfMDsI8HGGi80tiNvHOF)S(0pXG9J7jmEqH3tAV7nCjxy2jPLViiex9eYzvi63pRp9ts9(X9egpOW7j4WnaXRi5LDwMt3Ec5Ske97N1N(jNB)4Ec5Ske97N1tc9EsrnA6jmEqH3tsZfIvHOEsAUKoFPEcFLnD(2t(KLFqtpPrZG88MGVYMoF7t)KZ3pUNqoRcr)(z9KqVNuuJMEcJhu49K0CHyviQNKMlPZxQNqPdPoE6jFYYpOPNO957t)KZz)4Ec5Ske97N1tc9EsJMEcJhu49K0CHyviQNKMlPZxQNOxK(dcssPJEcUqdviUNO8cQNt2OYjrdPNfUSnrDfKZQq0FbAwaJhuAssoDruBbWBbAVGdxGYlq7fKcSaLxGbUaCKMC2hHt4kGI6VaLwGslqPEsAg6rscQr9e43tsZqpQNODF6NKA6h3tiNvHOF)SEsO3tA00ty8GcVNKMleRcr9K0CjD(s9KmonjdDYPFpbxOHke3tuEbmEqPjj50frTfaVfyWfOOIlinxiwfIe6fP)GGKu6ybWwG2lqrfxqAUqSkej4RSPZ3faBbAVaL6jPzOhjjOg1tGFpjnd9OEI29PFsQTFCpHCwfI(9Z6jHEpPrtpHXdk8EsAUqSke1tsZqpQNa)EsAUKoFPEIf5mKu9vEF6NKs6h3tiNvHOF)SEsO3tkQrtpHXdk8EsAUqSke1tsZL05l1tQM8YWj)eeRL0gLCI52t(KLFqtp589PFI2WVFCpHCwfI(9Z6jHEpPOgn9egpOW7jP5cXQqupjnxsNVupPAYldN8tqSwsBuYk07jFYYpOPNC((0prBT7h3tiNvHOF)SEsO3tkQrtpHXdk8EsAUqSke1tsZL05l1tQM8YWj)eeRL0gLK17jFYYpOPNyq43N(jABW(X9eYzvi63pRNe69KIA00ty8GcVNKMleRcr9K0CjD(s9ewxEz4KFcI1sAJsoXC7jFYYpOPNOn87t)eTt9(X9eYzvi63pRNe69KIA00ty8GcVNKMleRcr9K0CjD(s9Kk0Lxgo5NGyTK2OKtm3EYNS8dA6jge(9PFI2NB)4Ec5Ske97N1tc9EsJMEcJhu49K0CHyviQNKMlPZxQNmXCLxgo5NGyTK2OKSEpbxOHke3tuEb4in5SpchLNnsltlqrfxGYlah()Hgbxy2jPEfFuUwcYzvi6VanlGXdknjjNUiQTGJwqQVaLwGs9K0m0JKeuJ6jNVNKMHEupr7Z3N(jAF((X9eYzvi63pRNe69KIA00ty8GcVNKMleRcr9K0CjD(s9KjMR8YWj)eeRL0gLSc9EYNS8dA6jge(9PFI2NZ(X9eYzvi63pRNe69Kgn9egpOW7jP5cXQqupjnd9OEY5e(lif8cuEbxUnuPLmnd9OfKcSaTHp8xGs9eCHgQqCpbhPjN9r4O8SrAzQNKMlPZxQNOYvX5K8Yol1XtF6NODQPFCpHCwfI(9Z6jHEpPrtpHXdk8EsAUqSke1tsZqpQNKso)csbVaLxWLBdvAjtZqpAbPalqB4d)fOupbxOHke3tWrAYzFekOvHyVNKMlPZxQNOYvX5K8Yol1XtF6NODQTFCpHCwfI(9Z6jHEpPrtpHXdk8EsAUqSke1tsZqpQNKAH)csbVaLxWLBdvAjtZqpAbPalqB4d)fOupbxOHke3tsZfIvHiHkxfNtYl7Suhpla2cGFpjnxsNVuprLRIZj5LDwQJN(0pr7us)4Ec5Ske97N1tc9EsrnA6jmEqH3tsZfIvHOEsAUKoFPEcRlVihDFx5LDwQJNEYNS8dA6jAF((0pXGWVFCpHCwfI(9Z6jHEpPOgn9egpOW7jP5cXQqupjnxsNVupzI5kVmCsCgx5uRN8jl)GMEIb7t)edQD)4Ec5Ske97N1tc9EsrnA6jmEqH3tsZfIvHOEsAUKoFPEchKCI5kVmCsCgx5uRN8jl)GMEIb7t)edAW(X9eYzvi63pRNe69Kgn9egpOW7jP5cXQqupjnd9OEI2lifybkVa6G(q660xqxDTkIHKr9D2X0cuuXfO8cggI8rupNKHvQhMujiNvHO)c0SaLxWWqKpcUWStscNfcYzvi6VafvCbg4cWrAYzFekOvHyFbkTanlq5fyGlahPjN9r4eUcOO(lqrfxaJhuAssoDruBbWwG2lqrfxq9CYgvojAi9SWLTjQRGCwfI(lqPfO0cuQNKMlPZxQNyrTmKNldDYPQp9tmyQ3pUNqoRcr)(z9KqVN0OPNW4bfEpjnxiwfI6jPzOh1tOd6dPRtFXLXSArYwgrJ8(Ai8cuuXfqh0hsxN(ICi(J4jQMuL)50cuuXfqh0hsxN(ICi(J4jQM8sFgccf(cuuXfqh0hsxN(IpxkCJWLFcRGu)nf1WKJPfOOIlGoOpKUo9fiVHR3WQqK8G(yFEx5NsJW0cuuXfqh0hsxN(Iw8GGOzqEUSEQATafvCb0b9H01PVO9CvOi(s(stMwTzbkQ4cOd6dPRtFHjRa5u1K2k8)cuuXfqh0hsxN(cleFjzyLQ8mqupjnxsNVupH1LHlFnQp9tm452pUNqoRcr)(z9KqVNuuJMEcJhu49K0CHyviQNKMlPZxQNWbjNyUYldNeNXvo16jFYYpOPNyW(0pXGNVFCpHCwfI(9Z6jHEpPOgn9egpOW7jP5cXQqupjnxsNVupHshsD80t(KLFqtpr7Z3N(jg8C2pUNW4bfEp5IQkkj6Y5upHCwfI(9Z6t)edMA6h3tiNvHOF)SEcUqdviUNyGlinxiwfIe6fP)GGKu6ybWwG2lqZcQNt2OYjXh1WiDiKZLwsCCVS)fKZQq0VNW4bfEpXwrBudOPp9tmyQTFCpHCwfI(9Z6j4cnuH4EIbUG0CHyvisOxK(dcssPJfaBbAVanlWaxq9CYgvoj(OggPdHCU0sIJ7L9VGCwfI(9egpOW7jCHzNKQqCB6t)edMs6h3tiNvHOF)SEcUqdviUNKMleRcrc9I0FqqskDSaylq7EcJhu49ekDG5bfEF6tpbhb0pm9w)4(jA3pUNqoRcr)(z9egpOW7j2kAJ0J0Cp5tnCH0hu49KdUqrHg0bbTGxd55liVqniTwacJWq0cmrt2cyDXcmGA0cqZcmrt2cMyUliMmQmrns0tWfAOcX9K65KnQCsKxOgKwsegHHib5Ske9xGMfGJa6hMUGlm7KupmPsu0LrEBbWBbPo8xGMfGJa6hMUyIhotgw5KrYlNJefDzK3waSfa)fOzbkVa1N1k4cZojXzCLtI2WyfwWrWwqAUqSkejMyUYldNeNXvo1wGMfO8cuEbddr(iQNtYWk1dtQeKZQq0FbAwaocOFy6I65KmSs9WKkrrxg5TfCeSfKJ)lqZcWra9dtxWfMDsQhMujk6YiVTa4TG0CHyvismXCLxgo5NGyTK2OKS(cuAbkQ4cuEbg4cggI8rupNKHvQhMujiNvHO)c0SaCeq)W0fCHzNK6HjvIIUmYBlaElinxiwfIetmx5LHt(jiwlPnkjRVaLwGIkUaCeq)W0fCHzNK6HjvIIUmYBl4iylih)xGslqP(0pXG9J7jKZQq0VFwpbxOHke3tQNt2OYjrEHAqAjryegIeKZQq0FbAwaocOFy6cUWSts9WKkrrxg5TfaBbWFbAwGYlWaxWWqKpcYHq5zd50xqoRcr)fOOIlq5fmme5JGCiuE2qo9fKZQq0FbAwWLDwOJNfapyli1a)fO0cuAbAwGYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3wa8wG2WFbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2WyfwGslqrfxGYlahb0pmDXepCMmSYjJKxohjk6YiVTayla(lqZcuFwRGlm7KeNXvojAdJvybWwa8xGslqPfOzbQpRvupNKHvQhMuj(HPVanl4Yol0XZcGhSfKMleRcrcwxEro6(UYl7Suhp9egpOW7j2kAJ0J0CF6NK69J7jKZQq0VFwpbxOHke3tQNt2OYjXh1WiDiKZLwsCCVS)fKZQq0FbAwaocOFy6c1N1k)OggPdHCU0sIJ7L9VOi(R1c0Sa1N1k(OggPdHCU0sIJ7L9V0wrBe)W0xGMfO8cuFwRGlm7KupmPs8dtFbAwG6ZAf1ZjzyL6HjvIFy6lqZc(K6ZAft8WzYWkNmsE5CK4hM(cuAbAwaocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO8cuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKyI5kVmCsCgx5uBbAwGYlq5fmme5JOEojdRupmPsqoRcr)fOzb4iG(HPlQNtYWk1dtQefDzK3wWrWwqo(Vanlahb0pmDbxy2jPEysLOOlJ82cG3csZfIvHiXeZvEz4KFcI1sAJsY6lqPfOOIlq5fyGlyyiYhr9CsgwPEysLGCwfI(lqZcWra9dtxWfMDsQhMujk6YiVTa4TG0CHyvismXCLxgo5NGyTK2OKS(cuAbkQ4cWra9dtxWfMDsQhMujk6YiVTGJGTGC8FbkTaL6jmEqH3tSv0g1aA6t)KZTFCpHCwfI(9Z6j4cnuH4Es9CYgvoj(OggPdHCU0sIJ7L9VGCwfI(lqZcWra9dtxO(Sw5h1WiDiKZLwsCCVS)ffXFTwGMfO(SwXh1WiDiKZLwsCCVS)LwurIFy6lqZc0lkTmh)fAlSv0g1aA6jmEqH3tSOIKQqCB6t)KZ3pUNqoRcr)(z9egpOW7jxuvr1KHvorDjF6jFQHlK(GcVNKmiiOfygLcipFbHVGqFqx0bbpOWBlWg1cMmAbozUGuyCSXlq9nla)QI8bsRf8AipFbOzbHVa8FbO2cuPzOAbtg7lilG(ipFb2OwaRVGOwWRH88fGMf0Gq5zdKwlqLSrrlG17j4cnuH4EI(u9PFY5SFCpHCwfI(9Z6jmEqH3tUOQIQjdRCI6s(0t(udxi9bfEpjvHmzTAl41OfCrvfvBbMOjBbSUybga2fmXCxaQTGI4VwlGBlWKGGmEbxwbAbTxrlyIfG52Sa0SavYgfTGjMRONGl0qfI7jg4c0NAbAwaocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHiXeZvEz4K4mUYP2c0SaCeq)W0fCHzNK6HjvIIUmYBl4iylih)7t)Kut)4Ec5Ske97N1tWfAOcX9edCb6tTanlahb0pmDbxy2jPEysLOOlJ82cGTa4Vanlq5fyGlyyiYhb5qO8SHC6liNvHO)cuuXfO8cggI8rqoekpBiN(cYzvi6Vanl4Yol0XZcGhSfKAG)cuAbkTanlq5fO8cWra9dtxmXdNjdRCYi5LZrIIUmYBlaElinxiwfIeSU8YWj)eeRL0gLCI5Uanlq9zTcUWStsCgx5KOnmwHfaBbQpRvWfMDsIZ4kNexgozBySclqPfOOIlq5fGJa6hMUyIhotgw5KrYlNJefDzK3waSfa)fOzbQpRvWfMDsIZ4kNeTHXkSayla(lqPfO0c0Sa1N1kQNtYWk1dtQe)W0xGMfCzNf64zbWd2csZfIvHibRlVihDFx5LDwQJNEcJhu49KlQQOAYWkNOUKp9PFsQTFCpHCwfI(9Z6jmEqH3t(epzQr5up5tnCH0hu49KufYK1QTGxJwWN4jtnkNwGjAYwaRlwGbGDbtm3fGAlOi(R1c42cmjiiJxWLvGwq7v0cMybyUnlanlqLSrrlyI5k6j4cnuH4EcocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHiXeZvEz4K4mUYP2c0SaCeq)W0fCHzNK6HjvIIUmYBl4iylih)7t)Kus)4Ec5Ske97N1tWfAOcX9eCeq)W0fCHzNK6HjvIIUmYBla2cG)c0SaLxGbUGHHiFeKdHYZgYPVGCwfI(lqrfxGYlyyiYhb5qO8SHC6liNvHO)c0SGl7SqhplaEWwqQb(lqPfO0c0SaLxGYlahb0pmDXepCMmSYjJKxohjk6YiVTa4TaTH)c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXkSaLwGIkUaLxaocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO(Swbxy2jjoJRCs0ggRWcGTa4VaLwGslqZcuFwROEojdRupmPs8dtFbAwWLDwOJNfapylinxiwfIeSU8IC09DLx2zPoE6jmEqH3t(epzQr5uF6NOn87h3tiNvHOF)SEcJhu49KI)i2hztNlf6jFQHlK(GcVNya1Of005sHfGSlyI5Ua2)lG1xax0ccFb4)cy)VaZWnAwGkTGN(cSrTaOWZPAbtg7lyYOfCz4wWNGyTmEbxwbKNVG2ROfysliJttlGNfarCBwWyglGlm70cWzCLtTfW(FbtgplyI5UatU5gnlWaeV2SGxJ(IEcUqdviUNGJa6hMUyIhotgw5KrYlNJefDzK3wa8wqAUqSkejQM8YWj)eeRL0gLCI5Uanlahb0pmDbxy2jPEysLOOlJ82cG3csZfIvHir1Kxgo5NGyTK2OKS(c0SaLxWWqKpI65KmSs9WKkb5Ske9xGMfO8cWra9dtxupNKHvQhMujk6YiVTGJwabhHFdjh0LwGIkUaCeq)W0f1ZjzyL6HjvIIUmYBlaElinxiwfIevtEz4KFcI1sAJswH(cuAbkQ4cmWfmme5JOEojdRupmPsqoRcr)fO0c0Sa1N1k4cZojXzCLtI2Wyfwa8wGbxGMf8j1N1kM4HZKHvozK8Y5iXpm9fOzbQpRvupNKHvQhMuj(HPVanlq9zTcUWSts9WKkXpm9(0prBT7h3tiNvHOF)SEcJhu49KI)i2hztNlf6jFQHlK(GcVNya1Of005sHfyIMSfW6lWmJ8fOhTgsfIelWaWUGjM7cqTfue)1AbCBbMeeKXl4YkqlO9kAbtSam3MfGMfOs2OOfmXCf9eCHgQqCpbhb0pmDXepCMmSYjJKxohjk6YiVTGJwabhHFdjh0LwGMfO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHiXeZvEz4K4mUYP2c0SaCeq)W0fCHzNK6HjvIIUmYBl4OfO8ci4i8Bi5GU0coCbmEqHlM4HZKHvozK8Y5ibbhHFdjh0LwGs9PFI2gSFCpHCwfI(9Z6j4cnuH4EcocOFy6cUWSts9WKkrrxg5TfC0ci4i8Bi5GU0c0SaLxGYlWaxWWqKpcYHq5zd50xqoRcr)fOOIlq5fmme5JGCiuE2qo9fKZQq0FbAwWLDwOJNfapyli1a)fO0cuAbAwGYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3wa8wqAUqSkejyD5LHt(jiwlPnk5eZDbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2WyfwGslqrfxGYlahb0pmDXepCMmSYjJKxohjk6YiVTayla(lqZcuFwRGlm7KeNXvojAdJvybWwa8xGslqPfOzbQpRvupNKHvQhMuj(HPVanl4Yol0XZcGhSfKMleRcrcwxEro6(UYl7SuhplqPEcJhu49KI)i2hztNlf6t)eTt9(X9eYzvi63pRNW4bfEpzIhotgw5KrYlNJ6jFQHlK(GcVNya1OfmXCxGjAYwaRVaKDbOXO2cmrtgYxWKrl4YWTGpbXAjwGbGDbEmgVGxJwGjAYwqf6lazxWKrlyyiYNfGAlyyfi34fW(FbOXO2cmrtgYxWKrl4YWTGpbXAj6j4cnuH4EI6ZAfCHzNK4mUYjrByScl4iylinxiwfIetmx5LHtIZ4kNAlqZcWra9dtxWfMDsQhMujk6YiVTGJGTacoc)gsoOlTanl4Yol0XZcG3csZfIvHibRlVihDFx5LDwQJNfOzbQpRvupNKHvQhMuj(HP3N(jAFU9J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKyI5kVmCsCgx5uBbAwWWqKpI65KmSs9WKkb5Ske9xGMfGJa6hMUOEojdRupmPsu0LrEBbhbBbeCe(nKCqxAbAwaocOFy6cUWSts9WKkrrxg5TfaVfKMleRcrIjMR8YWj)eeRL0gLK1xGMfGJa6hMUGlm7KupmPsu0LrEBbWBbABWEcJhu49KjE4mzyLtgjVCoQp9t0(89J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKyI5kVmCsCgx5uBbAwGYlWaxWWqKpI65KmSs9WKkb5Ske9xGIkUaCeq)W0f1ZjzyL6HjvIIUmYBlaElinxiwfIetmx5LHt(jiwlPnkzf6lqPfOzb4iG(HPl4cZoj1dtQefDzK3wa8wqAUqSkejMyUYldN8tqSwsBuswVNW4bfEpzIhotgw5KrYlNJ6t)eTpN9J7jKZQq0VFwpHXdk8Ecxy2jPEysvp5tnCH0hu49edOgTawFbi7cMyUla1wq4la)xa7)fygUrZcuPf80xGnQfafEovlyYyFbtgTGld3c(eeRLXl4YkG88f0EfTGjJNfysliJttlG84LNTGl78cy)VGjJNfmzurla1wGhZcyOI4VwlGxq9CAbHDb6Hjvl4hMUONGl0qfI7j4iG(HPlM4HZKHvozK8Y5irrxg5TfaVfKMleRcrcwxEz4KFcI1sAJsoXCxGMfO(Swbxy2jjoJRCs0ggRWcGTa1N1k4cZojXzCLtIldNSnmwHfOzbQpRvupNKHvQhMuj(HPVanl4Yol0XZcGhSfKMleRcrcwxEro6(UYl7Suhp9PFI2PM(X9eYzvi63pRNW4bfEpPEojdRupmPQN8PgUq6dk8EIbuJwqf6lazxWeZDbO2ccFb4)cy)VaZWnAwGkTGN(cSrTaOWZPAbtg7lyYOfCz4wWNGyTmEbxwbKNVG2ROfmzurla1CJMfWqfXFTwaVG650c(HPVa2)lyY4zbS(cmd3OzbQeoU0c40mcIvHOf8FfYZxq9Cs0tWfAOcX9e1N1k4cZoj1dtQe)W0xGMfO8cWra9dtxmXdNjdRCYi5LZrIIUmYBlaElinxiwfIevOlVmCYpbXAjTrjNyUlqrfxaocOFy6cUWSts9WKkrrxg5TfCeSfKMleRcrIjMR8YWj)eeRL0gLK1xGslqZcuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRWc0SaCeq)W0fCHzNK6HjvIIUmYBlaElqBd2N(jANA7h3tiNvHOF)SEcUqdviUNO(Swbxy2jPEysL4hM(c0SaCeq)W0fCHzNK6HjvIPEKSOlJ82cG3cy8Gcx0Yq2b55s9WKkb(xlqZcuFwROEojdRupmPs8dtFbAwaocOFy6I65KmSs9WKkXupsw0LrEBbWBbmEqHlAzi7G8CPEysLa)RfOzbFs9zTIjE4mzyLtgjVCos8dtVNW4bfEpPLHSdYZL6Hjv9PFI2PK(X9eYzvi63pRNW4bfEprVOg5ysgw5f5)EYNA4cPpOW7jgqnAb6XDbtSG2b9r0bbTa2xab3u8cy1fG8fmz0cCcUzb4iG(HPVatK)dtJxWZHOwBbkOvHyFbtg5liCiTwW)vipFbCHzNwGEys1c(pAbtSGSWCbx25fK988sRfu8hX(SGMoxkSauRNGl0qfI7jddr(iQNtYWk1dtQeKZQq0FbAwG6ZAfCHzNK6HjvIN(c0Sa1N1kQNtYWk1dtQefDzK3wWrlih)fxgU(0pXGWVFCpHCwfI(9Z6j4cnuH4EYNuFwRyIhotgw5KrYlNJep9fOzbFs9zTIjE4mzyLtgjVCosu0LrEBbhTagpOWfCHzNKxuRHGOMGGJWVHKd6slqZcmWfGJ0KZ(iuqRcXEpHXdk8EIErnYXKmSYlY)9PFIb1UFCpHCwfI(9Z6j4cnuH4EI6ZAf1ZjzyL6HjvIN(c0Sa1N1kQNtYWk1dtQefDzK3wWrlih)fxgUfOzb4iG(HPlO0bMhu4II4VwlqZcWra9dtxmXdNjdRCYi5LZrIIUmYBlqZcmWfGJ0KZ(iuqRcXEpHXdk8EIErnYXKmSYlY)9Pp9eoO(X9t0UFCpHCwfI(9Z6j4cnuH4Es9CYgvoj(OggPdHCU0sIJ7L9VGCwfI(lqZcWra9dtxO(Sw5h1WiDiKZLwsCCVS)ffXFTwGMfO(SwXh1WiDiKZLwsCCVS)L2kAJ4hM(c0SaLxG6ZAfCHzNK6HjvIFy6lqZcuFwROEojdRupmPs8dtFbAwWNuFwRyIhotgw5KrYlNJe)W0xGslqZcWra9dtxmXdNjdRCYi5LZrIIUmYBla2cG)c0SaLxG6ZAfCHzNK4mUYjrByScl4iylinxiwfIeCqYjMR8YWjXzCLtTfOzbkVaLxWWqKpI65KmSs9WKkb5Ske9xGMfGJa6hMUOEojdRupmPsu0LrEBbhbBb54)c0SaCeq)W0fCHzNK6HjvIIUmYBlaElinxiwfIetmx5LHt(jiwlPnkjRVaLwGIkUaLxGbUGHHiFe1ZjzyL6HjvcYzvi6Vanlahb0pmDbxy2jPEysLOOlJ82cG3csZfIvHiXeZvEz4KFcI1sAJsY6lqPfOOIlahb0pmDbxy2jPEysLOOlJ82coc2cYX)fO0cuQNW4bfEpXwrBudOPp9tmy)4Ec5Ske97N1tWfAOcX9eLxq9CYgvoj(OggPdHCU0sIJ7L9VGCwfI(lqZcWra9dtxO(Sw5h1WiDiKZLwsCCVS)ffXFTwGMfO(SwXh1WiDiKZLwsCCVS)LwurIFy6lqZc0lkTmh)fAlSv0g1aAwGslqrfxGYlOEozJkNeFudJ0HqoxAjXX9Y(xqoRcr)fOzbd6sl4OfO9cuQNW4bfEpXIksQcXTPp9ts9(X9eYzvi63pRNGl0qfI7j1ZjBu5KiVqniTKimcdrcYzvi6Vanlahb0pmDbxy2jPEysLOOlJ82cG3csD4Vanlahb0pmDXepCMmSYjJKxohjk6YiVTayla(lqZcuEbQpRvWfMDsIZ4kNeTHXkSGJGTG0CHyvisWbjNyUYldNeNXvo1wGMfO8cuEbddr(iQNtYWk1dtQeKZQq0FbAwaocOFy6I65KmSs9WKkrrxg5TfCeSfKJ)lqZcWra9dtxWfMDsQhMujk6YiVTa4TG0CHyvismXCLxgo5NGyTK2OKS(cuAbkQ4cuEbg4cggI8rupNKHvQhMujiNvHO)c0SaCeq)W0fCHzNK6HjvIIUmYBlaElinxiwfIetmx5LHt(jiwlPnkjRVaLwGIkUaCeq)W0fCHzNK6HjvIIUmYBl4iylih)xGslqPEcJhu49eBfTr6rAUp9to3(X9eYzvi63pRNGl0qfI7j1ZjBu5KiVqniTKimcdrcYzvi6Vanlahb0pmDbxy2jPEysLOOlJ82cGTa4Vanlq5fO8cuEb4iG(HPlM4HZKHvozK8Y5irrxg5TfaVfKMleRcrcwxEz4KFcI1sAJsoXCxGMfO(Swbxy2jjoJRCs0ggRWcGTa1N1k4cZojXzCLtIldNSnmwHfO0cuuXfO8cWra9dtxmXdNjdRCYi5LZrIIUmYBla2cG)c0Sa1N1k4cZojXzCLtI2WyfwWrWwqAUqSkej4GKtmx5LHtIZ4kNAlqPfO0c0Sa1N1kQNtYWk1dtQe)W0xGs9egpOW7j2kAJ0J0CF6NC((X9eYzvi63pRNGl0qfI7j1ZjBu5KOH0Zcx2MOUcYzvi6VanlqVO0YC8xOTGshyEqH3ty8GcVNmXdNjdRCYi5LZr9PFY5SFCpHCwfI(9Z6j4cnuH4Es9CYgvojAi9SWLTjQRGCwfI(lqZcuEb6fLwMJ)cTfu6aZdk8fOOIlqVO0YC8xOTyIhotgw5KrYlNJwGs9egpOW7jCHzNK6Hjv9PFsQPFCpHCwfI(9Z6j4cnuH4EYGU0cG3csD4VanlOEozJkNenKEw4Y2e1vqoRcr)fOzbQpRvWfMDsIZ4kNeTHXkSGJGTG0CHyvisWbjNyUYldNeNXvo1wGMfGJa6hMUyIhotgw5KrYlNJefDzK3waSfa)fOzb4iG(HPl4cZoj1dtQefDzK3wWrWwqo(3ty8GcVNqPdmpOW7t)KuB)4Ec5Ske97N1ty8GcVNqPdmpOW7jiFOQE6Jez7jQpRv0q6zHlBtuxrByScWuFwROH0Zcx2MOUIldNSnmwHEcYhQQN(ir3l9r8q9eT7j4cnuH4EYGU0cG3csD4VanlOEozJkNenKEw4Y2e1vqoRcr)fOzb4iG(HPl4cZoj1dtQefDzK3waSfa)fOzbkVaLxGYlahb0pmDXepCMmSYjJKxohjk6YiVTa4TG0CHyvisW6YldN8tqSwsBuYjM7c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXkSaLwGIkUaLxaocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHibhKCI5kVmCsCgx5uBbkTaLwGMfO(Swr9CsgwPEysL4hM(cuQp9tsj9J7jKZQq0VFwpbxOHke3tuEb4iG(HPl4cZoj1dtQefDzK3wa8wW5E(fOOIlahb0pmDbxy2jPEysLOOlJ82coc2cs9fO0c0SaCeq)W0ft8WzYWkNmsE5CKOOlJ82cGTa4Vanlq5fO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHibhKCI5kVmCsCgx5uBbAwGYlq5fmme5JOEojdRupmPsqoRcr)fOzb4iG(HPlQNtYWk1dtQefDzK3wWrWwqo(Vanlahb0pmDbxy2jPEysLOOlJ82cG3co)cuAbkQ4cuEbg4cggI8rupNKHvQhMujiNvHO)c0SaCeq)W0fCHzNK6HjvIIUmYBlaEl48lqPfOOIlahb0pmDbxy2jPEysLOOlJ82coc2cYX)fO0cuQNW4bfEp5IQkQMmSYjQl5tF6NOn87h3tiNvHOF)SEcUqdviUNGJa6hMUyIhotgw5KrYlNJefDzK3wWrlGGJWVHKd6slqZcuEbQpRvWfMDsIZ4kNeTHXkSGJGTG0CHyvisWbjNyUYldNeNXvo1wGMfO8cuEbddr(iQNtYWk1dtQeKZQq0FbAwaocOFy6I65KmSs9WKkrrxg5TfCeSfKJ)lqZcWra9dtxWfMDsQhMujk6YiVTa4TG0CHyvismXCLxgo5NGyTK2OKS(cuAbkQ4cuEbg4cggI8rupNKHvQhMujiNvHO)c0SaCeq)W0fCHzNK6HjvIIUmYBlaElinxiwfIetmx5LHt(jiwlPnkjRVaLwGIkUaCeq)W0fCHzNK6HjvIIUmYBl4iylih)xGslqPEcJhu49KI)i2hztNlf6t)eT1UFCpHCwfI(9Z6j4cnuH4EcocOFy6cUWSts9WKkrrxg5TfC0ci4i8Bi5GU0c0SaLxGYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3wa8wqAUqSkejyD5LHt(jiwlPnk5eZDbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2WyfwGslqrfxGYlahb0pmDXepCMmSYjJKxohjk6YiVTayla(lqZcuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKGdsoXCLxgojoJRCQTaLwGslqZcuFwROEojdRupmPs8dtFbk1ty8GcVNu8hX(iB6CPqF6NOTb7h3tiNvHOF)SEcUqdviUNGJa6hMUGlm7KupmPsu0LrEBbWwa8xGMfO8cuEbkVaCeq)W0ft8WzYWkNmsE5CKOOlJ82cG3csZfIvHibRlVmCYpbXAjTrjNyUlqZcuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRWcuAbkQ4cuEb4iG(HPlM4HZKHvozK8Y5irrxg5TfaBbWFbAwG6ZAfCHzNK4mUYjrByScl4iylinxiwfIeCqYjMR8YWjXzCLtTfO0cuAbAwG6ZAf1ZjzyL6HjvIFy6lqPEcJhu49KpXtMAuo1N(jAN69J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKGdsoXCLxgojoJRCQTanlq5fO8cggI8rupNKHvQhMujiNvHO)c0SaCeq)W0f1ZjzyL6HjvIIUmYBl4iylih)xGMfGJa6hMUGlm7KupmPsu0LrEBbWBbP5cXQqKyI5kVmCYpbXAjTrjz9fO0cuuXfO8cmWfmme5JOEojdRupmPsqoRcr)fOzb4iG(HPl4cZoj1dtQefDzK3wa8wqAUqSkejMyUYldN8tqSwsBuswFbkTafvCb4iG(HPl4cZoj1dtQefDzK3wWrWwqo(VaL6jmEqH3tM4HZKHvozK8Y5O(0pr7ZTFCpHCwfI(9Z6j4cnuH4EIYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3wa8wqAUqSkejyD5LHt(jiwlPnk5eZDbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2WyfwGslqrfxGYlahb0pmDXepCMmSYjJKxohjk6YiVTayla(lqZcuFwRGlm7KeNXvojAdJvybhbBbP5cXQqKGdsoXCLxgojoJRCQTaLwGslqZcuFwROEojdRupmPs8dtVNW4bfEpHlm7KupmPQp9t0(89J7jKZQq0VFwpbxOHke3tuFwROEojdRupmPs8dtFbAwGYlq5fGJa6hMUyIhotgw5KrYlNJefDzK3wa8wGbH)c0Sa1N1k4cZojXzCLtI2WyfwaSfO(Swbxy2jjoJRCsCz4KTHXkSaLwGIkUaLxaocOFy6IjE4mzyLtgjVCosu0LrEBbWwa8xGMfO(Swbxy2jjoJRCs0ggRWcoc2csZfIvHibhKCI5kVmCsCgx5uBbkTaLwGMfO8cWra9dtxWfMDsQhMujk6YiVTa4TaTn4cuuXf8j1N1kM4HZKHvozK8Y5iXtFbk1ty8GcVNupNKHvQhMu1N(jAFo7h3tiNvHOF)SEcUqdviUNGJa6hMUGlm7Kmkvrrxg5TfaVfC(fOOIlWaxWWqKpcUWStYOufKZQq0VNW4bfEpPLHSdYZL6Hjv9PFI2PM(X9eYzvi63pRNGl0qfI7jQpRv8jEYuJYjXtFbAwWNuFwRyIhotgw5KrYlNJep9fOzbFs9zTIjE4mzyLtgjVCosu0LrEBbhbBbQpRvOxuJCmjdR8I8V4YWjBdJvybPalGXdkCbxy2jPke3gbbhHFdjh0L6jmEqH3t0lQroMKHvEr(Vp9t0o12pUNqoRcr)(z9eCHgQqCpr9zTIpXtMAuojE6lqZcuEbkVGHHiFef1cNDmjiNvHO)c0SagpO0KKC6IO2coAbN7cuAbkQ4cy8GstsYPlIAl4OfC(fO0c0SaLxGbUG65KnQCsWfMDsQgxvU(xYhb5Ske9xGIkUGHRCAezednzcD8Sa4TGu)8lqPEcJhu49eUWStsviUn9PFI2PK(X9egpOW7jTNovEKM7jKZQq0VFwF6Nyq43pUNqoRcr)(z9eCHgQqCpr9zTcUWStsCgx5KOnmwHfapylq5fW4bLMKKtxe1wqk4fO9cuAbAwq9CYgvoj4cZojvJRkx)l5JGCwfI(lqZcgUYPrKrm0Kj0XZcoAbP(57jmEqH3t4cZojv5Q4CQp9tmO29J7jKZQq0VFwpbxOHke3tuFwRGlm7KeNXvojAdJvybWwG6ZAfCHzNK4mUYjXLHt2ggRqpHXdk8Ecxy2jPkxfNt9PFIbny)4Ec5Ske97N1tWfAOcX9e1N1k4cZojXzCLtI2WyfwaSfa)EcJhu49eUWStYOu7t)edM69J7jKZQq0VFwpbxOHke3tuEbfzlQLXQq0cuuXfyGlyqyfqE(cuAbAwG6ZAfCHzNK4mUYjrByScla2cuFwRGlm7KeNXvojUmCY2Wyf6jmEqH3tCAYOso0vNAtF6NyWZTFCpHCwfI(9Z6j4cnuH4EI6ZAfyiIlm3gKNlkIXZc0SG65KnQCsWfMDsIClYrJwcYzvi6Vanlq5fO8cggI8rWxDiKfH5bfUGCwfI(lqZcy8GstsYPlIAl4OfKAxGslqrfxaJhuAssoDruBbhTGZVaL6jmEqH3t4cZojVOwdbrT(0pXGNVFCpHCwfI(9Z6j4cnuH4EI6ZAfyiIlm3gKNlkIXZc0SGHHiFeCHzNKeoleKZQq0FbAwWNuFwRyIhotgw5KrYlNJep9fOzbkVGHHiFe8vhczryEqHliNvHO)cuuXfW4bLMKKtxe1wWrliLSaL6jmEqH3t4cZojVOwdbrT(0pXGNZ(X9eYzvi63pRNGl0qfI7jQpRvGHiUWCBqEUOigplqZcggI8rWxDiKfH5bfUGCwfI(lqZcy8GstsYPlIAl4OfCU9egpOW7jCHzNKxuRHGOwF6NyWut)4Ec5Ske97N1tWfAOcX9e1N1k4cZojXzCLtI2WyfwWrlq9zTcUWStsCgx5K4YWjBdJvONW4bfEpHlm7KKGthkAOW7t)edMA7h3tiNvHOF)SEcUqdviUNO(Swbxy2jjoJRCs0ggRWcGTa1N1k4cZojXzCLtIldNSnmwHfOzb6fLwMJ)cTfCHzNKQCvCo1ty8GcVNWfMDssWPdfnu49PFIbtj9J7jiFOQE6Jez7jx2zHoEGhSuY57jiFOQE6JeDV0hXd1t0UNW4bfEpHshyEqH3tiNvHOF)S(0NEsgx3W1QFC)eT7h3tiNvHOF)SEcJhu49ekDG5bfEp5tnCH0hu49edOgTad40bMhu4lazxGjzurlakmxq4l4YoVa2)lGxWXXKcpnvp4fyI8FyUauBb44I88f807j4cnuH4EYLDwOJNfCeSfO95xGMfGJa6hMUyIhotgw5KrYlNJefDzK3wWrWwGYlGGJWVHKd6sl4WfW4bfUyIhotgw5KrYlNJeeCe(nKCqxAbkTanlahb0pmDbxy2jPEysLOOlJ82coc2cuEbeCe(nKCqxAbhUagpOWft8WzYWkNmsE5CKGGJWVHKd6sl4WfW4bfUGlm7KupmPsqWr43qYbDPfO0c0Sa1N1kQNtYWk1dtQe)W0xGMfO(Swbxy2jPEysL4hM(c0SGpP(SwXepCMmSYjJKxohj(HPVanlWaxWpgrXFe7JSPZLcIIUmYB9PFIb7h3tiNvHOF)SEcJhu49ekDG5bfEp5tnCH0hu49edOgTad40bMhu4lazxGjzurlakmxq4l4YoVa2)lGxW5io4fyI8FyUauBb44I88f807j4cnuH4EYLDwOJNfCeSfK6WFbAwaocOFy6I65KmSs9WKkrrxg5TfCeSfO8ci4i8Bi5GU0coCbmEqHlQNtYWk1dtQeeCe(nKCqxAbkTanlahb0pmDXepCMmSYjJKxohjk6YiVTGJGTaLxabhHFdjh0LwWHlGXdkCr9CsgwPEysLGGJWVHKd6sl4WfW4bfUO4pI9r205sbbbhHFdjh0LwGslqZcWra9dtxWfMDsQhMujk6YiVTa4TGZf(9PFsQ3pUNqoRcr)(z9Kp1WfsFqH3to7HG(lWamx3W1AbTHXk0wGnQfmz0cooMu4PP6bVatK)dZEcUqdviUNO(Swbxy2jzgx3W1s0ggRWcoAbQpRvWfMDsMX1nCTexgozBySclqZcWra9dtxu8hX(iB6CPGOOlJ82coc2cuEbgCbhUaLxabhHFdjh0LwWHlGXdkCrXFe7JSPZLcccoc)gsoOlTaLwGslqZcWra9dtxmXdNjdRCYi5LZrIIUmYBl4iylq5fyWfC4cuEbeCe(nKCqxAbhUagpOWff)rSpYMoxkii4i8Bi5GU0coCbmEqHlM4HZKHvozK8Y5ibbhHFdjh0LwGslqPfOzb4iG(HPl4cZoj1dtQefDzK3wWrWwGYlWGl4WfO8ci4i8Bi5GU0coCbmEqHlk(JyFKnDUuqqWr43qYbDPfC4cy8GcxmXdNjdRCYi5LZrccoc)gsoOlTGdxaJhu4cUWSts9WKkbbhHFdjh0LwGslqPEcoJrEpr7EcJhu49eUWStYlQ1qquRp9to3(X9eYzvi63pRN8PgUq6dk8EYzpe0FbgG56gUwlOnmwH2cSrTGjJwW5io4fyI8Fy2tWfAOcX9e1N1k4cZojZ46gUwI2WyfwWrlq9zTcUWStYmUUHRL4YWjBdJvybAwaocOFy6I65KmSs9WKkrrxg5TfCeSfO8cm4coCbkVacoc)gsoOlTGdxaJhu4I65KmSs9WKkbbhHFdjh0LwGslqPfOzb4iG(HPlk(JyFKnDUuqu0LrEBbhbBbkVadUGdxGYlGGJWVHKd6sl4WfW4bfUOEojdRupmPsqWr43qYbDPfC4cy8Gcxu8hX(iB6CPGGGJWVHKd6slqPfO0c0SaCeq)W0ft8WzYWkNmsE5CKOOlJ82coc2cuEbgCbhUaLxabhHFdjh0LwWHlGXdkCr9CsgwPEysLGGJWVHKd6sl4WfW4bfUO4pI9r205sbbbhHFdjh0LwWHlGXdkCXepCMmSYjJKxohji4i8Bi5GU0cuAbkTanlahb0pmDbxy2jPEysLOOlJ8wpbNXiVNODpHXdk8Ecxy2j5f1AiiQ1N(jNVFCpHCwfI(9Z6jFQHlK(GcVNC2db9xGbyUUHR1cAdJvOTaBulyYOf4Sc0FbNJKfyI8Fy2tWfAOcX9e1N1k4cZojZ46gUwI2WyfwWrlq9zTcUWStYmUUHRL4YWjBdJvybAwaocOFy6II)i2hztNlfefDzK3wWrWwGYlWGl4WfO8ci4i8Bi5GU0coCbmEqHlk(JyFKnDUuqqWr43qYbDPfO0cuAbAwaocOFy6cUWSts9WKkrrxg5Tfapyli1H)c0SaCeq)W0f1ZjzyL6HjvIIUmYBlaEWwqQd)EcoJrEpr7EcJhu49eUWStYlQ1qquRp9toN9J7jKZQq0VFwpbxOHke3tuFwRGlm7KmJRB4AjAdJvybWwG6ZAfCHzNKzCDdxlXLHt2ggRWc0SaCeq)W0ft8WzYWkNmsE5CKOOlJ82coAbeCe(nKCqxAbAwaocOFy6cUWSts9WKkrrxg5TfCeSfO8ci4i8Bi5GU0coCbmEqHlM4HZKHvozK8Y5ibbhHFdjh0LwGslqZcUSZcD8Sa4TaTpFpHXdk8EsXFe7JSPZLc9PFsQPFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNKzCDdxlrByScla2cuFwRGlm7KmJRB4AjUmCY2WyfwGMfGJa6hMUGlm7KupmPsu0LrEBbhbBbeCe(nKCqxAbAwWpgrXFe7JSPZLcIIUmYB9egpOW7jt8WzYWkNmsE5CuF6NKA7h3tiNvHOF)SEcUqdviUNO(Swbxy2jzgx3W1s0ggRWcGTa1N1k4cZojZ46gUwIldNSnmwHfOzbFs9zTIjE4mzyLtgjVCos80xGMfO(Swr9CsgwPEysL4hMEpHXdk8Ecxy2jPEysvF6NKs6h3tiNvHOF)SEcUqdviUNO(Swbxy2jzgx3W1s0ggRWcGTa1N1k4cZojZ46gUwIldNSnmwHfOzb4iG(HPlM4HZKHvozK8Y5irrxg5TfCeSfO8ci4i8Bi5GU0coCbmEqHlk(JyFKnDUuqqWr43qYbDPfO0c0SaCeq)W0fCHzNK6HjvIIUmYBlaEl4CH)c0SGl7SqhplaEWwqQF(EcJhu49K65KmSs9WKQ(0prB43pUNqoRcr)(z9eCHgQqCpr9zTcUWStYmUUHRLOnmwHfaBbQpRvWfMDsMX1nCTexgozBySclqZcWra9dtxmXdNjdRCYi5LZrIIUmYBl4OfqWr43qYbDPfOzbQpRvupNKHvQhMujE69egpOW7jf)rSpYMoxk0N(jARD)4Ec5Ske97N1tWfAOcX9e1N1k4cZojZ46gUwI2WyfwaSfO(Swbxy2jzgx3W1sCz4KTHXkSanlahb0pmDbxy2jPEysLOOlJ82cG3cox4Vanlq9zTI65KmSs9WKkXtFbAwWpgrXFe7JSPZLcIIUmYB9egpOW7jt8WzYWkNmsE5CuF6NOTb7h3tiNvHOF)SEcUqdviUNGJa6hMUyIhotgw5KrYlNJefDzK3wa8wG2WFbAwaocOFy6cUWSts9WKkrrxg5TfaVfK6WFbAwG6ZAfCHzNK6HjvIFy69egpOW7j1ZjzyL6Hjv9PFI2PE)4Ec5Ske97N1tWfAOcX9e1N1k4cZojZ46gUwI2WyfwaSfO(Swbxy2jzgx3W1sCz4KTHXkSanlahb0pmDbxy2jPEysLOOlJ82cGhSfyWZVanlahb0pmDr9CsgwPEysLOOlJ82cGhSfyWZVanlq9zTcUWStYmUUHRLOnmwHfaBbQpRvWfMDsMX1nCTexgozBySclqZcUSZcD8Sa4bBbAF(EcJhu49KI)i2hztNlf6t)eTp3(X9eYzvi63pRNW4bfEprVOg5ysgw5f5)EYNA4cPpOW7jgqnAbhCKcxW)vipFbP6bVGOwW5io4fyI8Fy2wWelq9HG(laNXvo1waBhQwWRH88fKQfMDAbNXvX5upbxOHke3tuFwRGlm7KeNXvojAdJvybhTa1N1k4cZojXzCLtIldNSnmwHfOzbQpRvWfMDsIZ4kNeTHXkSa4Ta4Vanlq9zTcUWSts9WKkrrxg5TfOOIlq9zTcUWStsCgx5KOnmwHfC0cuFwRGlm7KeNXvojUmCY2WyfwGMfO(Swbxy2jjoJRCs0ggRWcG3cG)c0Sa1N1kQNtYWk1dtQefDzK3wGMf8j1N1kM4HZKHvozK8Y5irrxg5T(0pr7Z3pUNqoRcr)(z9eCHgQqCpr9zTc9IAKJjzyLxK)fp9EcJhu49eUWStsviUn9PFI2NZ(X9eYzvi63pRNGl0qfI7jQpRvWfMDsIZ4kNeTHXkSGJwGbxGMfO(Swbxy2jPEysL4P3ty8GcVNWfMDsgLAF6NODQPFCpHCwfI(9Z6j4cnuH4EI6ZAfCHzNK4mUYjrByScl4OfyWfOzbg4cuEb4iG(HPl4cZoj1dtQefDzK3wWrWwG2WFbAwaocOFy6IjE4mzyLtgjVCosu0LrEBbhbBbAd)fOzb4iG(HPlk(JyFKnDUuqu0LrEBbhbBbNFbk1ty8GcVNWfMDsgLAF6NODQTFCpHCwfI(9Z6jmEqH3t4cZojVOwdbrTEcoJrEpr7EcUqdviUNO(Swbxy2jjoJRCs0ggRWcG3c0EbAwG6ZAfCHzNKzCDdxlrByScl4OfO(Swbxy2jzgx3W1sCz4KTHXk0N(jANs6h3tiNvHOF)SEcJhu49eUWStYlQ1qquRNGZyK3t0UNGl0qfI7j4iG(HPl4cZojJsvu0LrEBbhTGZDbAwG6ZAfCHzNKzCDdxlrByScl4OfO(Swbxy2jzgx3W1sCz4KTHXk0N(jge(9J7jKZQq0VFwpbxOHke3t(K6ZAff)rSpYMoxkit)GCQyveeA0s0ggRWcGTGZTNW4bfEpHlm7KuLRIZP(0pXGA3pUNqoRcr)(z9eCHgQqCp5hJO4pI9r205sbrrxg5TfOzbFs9zTIjE4mzyLtgjVCosu0LrEBbWBbeCe(nKCqxAbAwGYl4tQpRvu8hX(iB6CPGm9dYPIvrqOrlrByScla2cG)cuuXf8j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwHfC0co3fOupHXdk8Ecxy2jPke3M(0pXGgSFCpHCwfI(9Z6j4cnuH4EYpgrXFe7JSPZLcIIUmYBlaEl48lqZc(K6ZAff)rSpYMoxkit)GCQyveeA0s0ggRWcGTa4Vanlq9zTI65KmSs9WKkXpm9EcJhu49eUWStYOu7t)edM69J7jKZQq0VFwpbxOHke3t(Xik(JyFKnDUuqu0LrEBbWBbeCe(nKCqxAbAwWNuFwRO4pI9r205sbz6hKtfRIGqJwI2Wyfwa8wa8xGMf8j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwHfC0co3fOzbQpRvupNKHvQhMuj(HP3ty8GcVNWfMDsQcXTPp9tm452pUNqoRcr)(z9eCHgQqCpr9zTcUWStsCgx5KOnmwHfaBbQpRvWfMDsIZ4kNexgozBySclqZcuFwRGlm7KmJRB4AjAdJvybWwG6ZAfCHzNKzCDdxlXLHt2ggRqpHXdk8Ecxy2jPkxfNt9PFIbpF)4Ec5Ske97N1tWfAOcX9Kl7Sqhpl4OfO957jmEqH3tO0bMhu49PFIbpN9J7jKZQq0VFwpHXdk8Ecxy2jPke3MEYNA4cPpOW7jhKzKVavAmjYxaocOFy6lWe5)WSz8cmPfeoKwlq9HG(lyIfyFqqlaNXvo1waBhQwWRH88fKQfMDAbPGk1EcUqdviUNO(Swbxy2jjoJRCs0ggRWcG3c0Up9tmyQPFCpHCwfI(9Z6jmEqH3t4cZojv5Q4CQN8PgUq6dk8EIbW9sFepeKwlOPt(FbgG56gUwlOnmwH2cmZiFbQ0ysKVaCeq)W0xGjY)HzRNGl0qfI7jQpRvWfMDsMX1nCTeTHXkSa4Ta43N(jgm12pUNqoRcr)(z9eCgJ8EI29egpOW7jCHzNKxuRHGOwF6tpXICgsQ(kVFC)eT7h3tiNvHOF)SEcJhu49eUWStYlQ1qquRNGZyK3t0UNGl0qfI7jQpRvGHiUWCBqEUOigp9PFIb7h3ty8GcVNWfMDsQcXTPNqoRcr)(z9PFsQ3pUNW4bfEpHlm7KuLRIZPEc5Ske97N1N(0NEsAQAOW7Nyq4BqTHFQd)utpXKlh55TEYbzQEooXa4edqt5fSGJZOfGU6rnlWg1cmYIAzipxg6KtLrlOOd6dv0FbT4slGFtC5H(laNXEo1eRHPcYPfODkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzdcNsI1Wub50cmykVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1goLeRHPcYPfK6P8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfCUP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfC(uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwaplWaofuQSaL1goLeRHPcYPfKss5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkBq4usSgMkiNwG2NBkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1goLeRHPcYPfODQjLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOS2WPKynmvqoTaTtnP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaEwGbCkOuzbkRnCkjwdtfKtlq7uBkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbge(P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwB4usSgUgEqMQNJtmaoXa0uEbl44mAbOREuZcSrTaJcDYPYOfu0b9Hk6VGwCPfWVjU8q)fGZypNAI1Wub50c0oLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOS2WPKynmvqoTadMYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwG2WpLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAdNsI1Wub50c0o1t5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAb8Sad4uqPYcuwB4usSgMkiNwG2NBkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlGNfyaNckvwGYAdNsI1Wub50c0(8P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwB4usSgUgEqMQNJtmaoXa0uEbl44mAbOREuZcSrTaJQy4bfUrlOOd6dv0FbT4slGFtC5H(laNXEo1eRHPcYPfODkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1goLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAdNsI1Wub50co3uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRnCkjwdtfKtl48P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cuwB4usSgMkiNwqkjLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAdNsI1Wub50c0oLKYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqzTHtjXAyQGCAbge(P8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfyqTt5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRnCkjwdtfKtlWGPEkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbg8Ct5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRnCkjwdxdpit1ZXjgaNyaAkVGfCCgTa0vpQzb2OwGrFYYpOXOfu0b9Hk6VGwCPfWVjU8q)fGZypNAI1Wub50cmykVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzdcNsI1Wub50cs9uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYgeoLeRHPcYPfCUP8csXWtt1q)fKGUP4cAA5dd3cma5cMybPYJxWhLg1qHVGqNkEIAbkFQslqzTHtjXAyQGCAbNpLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfKAs5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRnCkjwdtfKtlq7utkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbANss5fKIHNMQH(lWO65KnQCsCaJwWelWO65KnQCsCab5Ske9nAbkRnCkjwdtfKtlWGANYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwGbt9uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRnCkjwdtfKtlWGPEkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbgm1t5fKIHNMQH(lWiC4)hAehWOfmXcmch()HgXbeKZQq03OfWZcmGtbLklqzTHtjXA4A4bzQEooXa4edqt5fSGJZOfGU6rnlWg1cmsViCCv5XOfu0b9Hk6VGwCPfWVjU8q)fGZypNAI1Wub50coNP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfO95MYlifdpnvd9xGr4W)p0ioGrlyIfyeo8)dnIdiiNvHOVrlqzTHtjXAyQGCAbg0GP8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTadAWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAdNsI1Wub50cmyQjLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfWZcmGtbLklqzTHtjXAyQGCAbgm1MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0c4zbgWPGsLfOS2WPKynCn8GmvphNyaCIbOP8cwWXz0cqx9OMfyJAbgHJa6hMEZOfu0b9Hk6VGwCPfWVjU8q)fGZypNAI1Wub50c0oLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfODkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbgmLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAdNsI1Wub50cs9uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwqQNYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwW5MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwqQjLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfKss5fKIHNMQH(lWOHHiFehWOfmXcmAyiYhXbeKZQq03OfOSbHtjXAyQGCAbAd)uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwG2gmLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfO95MYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqzTHtjXAyQGCAbAF(uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkRnCkjwdtfKtlq7uskVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaL1goLeRHRHhKP654edGtmanLxWcooJwa6Qh1SaBulWioiJwqrh0hQO)cAXLwa)M4Yd9xaoJ9CQjwdtfKtlq7uEbPy4PPAO)cmAyiYhXbmAbtSaJggI8rCab5Ske9nAbkBq4usSgMkiNwG2P8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfyWuEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYgeoLeRHPcYPfK6P8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTGupLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOS2WPKynmvqoTGZnLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOS2WPKynmvqoTGZNYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwW5mLxqkgEAQg6VaJQNt2OYjXbmAbtSaJQNt2OYjXbeKZQq03OfOS2WPKynmvqoTGutkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbP2uEbPy4PPAO)cmQEozJkNehWOfmXcmQEozJkNehqqoRcrFJwGYAdNsI1Wub50csjP8csXWtt1q)fy0WqKpIdy0cMybgnme5J4acYzvi6B0cu2GWPKynmvqoTaTHFkVGum80un0Fbgnme5J4agTGjwGrddr(ioGGCwfI(gTaLniCkjwdtfKtlq7upLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYgeoLeRHPcYPfO95mLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwaplWaofuQSaL1goLeRHPcYPfODQnLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAdNsI1Wub50c0o1MYlifdpnvd9xGr1ZjBu5K4agTGjwGr1ZjBu5K4acYzvi6B0cuwB4usSgMkiNwGbHFkVGum80un0FbgvpNSrLtIdy0cMybgvpNSrLtIdiiNvHOVrlqzTHtjXAyQGCAbg8Ct5fKIHNMQH(lWOHHiFehWOfmXcmAyiYhXbeKZQq03OfOS2WPKynmvqoTadEUP8csXWtt1q)fyu9CYgvojoGrlyIfyu9CYgvojoGGCwfI(gTaL1goLeRHPcYPfyWZNYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqzdcNsI1Wub50cm45mLxqkgEAQg6VaJggI8rCaJwWelWOHHiFehqqoRcrFJwGYAdNsI1W1WdYu9CCIbWjgGMYlybhNrlaD1JAwGnQfyeFLnD(A0ck6G(qf9xqlU0c43exEO)cWzSNtnXAyQGCAbANYlifdpnvd9xGrddr(ioGrlyIfy0WqKpIdiiNvHOVrlqzTHtjXA4AObWvpQH(lqBTxaJhu4lac1MMynSNWVjlQEsc6(G4bfEkwSD6j6vyrqupjLMsxqkKZPfKQfMDAnmLMsxqkKlC2csngVadcFdQ9A4AyknLUGZbDJ00csZfIvHibFLnD(UaKValNoQfe2f0OzqEEtWxztNVlqzCgHvybAfVAbnDcVGqFqH3usSgMstPlWaQrly0shHzOfKGUP4cYy)dH88fe2fGZy3jOfG8HQ6PpOWxaYBdX)fe2fyeMDmbjz8Gc3iXA4AiJhu4nHEr44QYZHWoLlm7Ke5dbbr4znKXdk8MqViCCv55qyNYfMDsA5lccX1AiJhu4nHEr44QYZHWofhUbiEfjVSZYC6UgY4bfEtOxeoUQ8CiSttZfIvHiJD(sW4RSPZxJdDyf1OX4pz5h0aRrZG88MGVYMoFxdz8GcVj0lchxvEoe2PP5cXQqKXoFjyu6qQJhJdDyf1OX4pz5h0at7ZVgY4bfEtOxeoUQ8CiSttZfIvHiJD(sW0ls)bbjP0HXHoSgngJSWuUEozJkNenKEw4Y2e1vdJhuAssoDrudEAFOYANcOSbIJ0KZ(iCcxbuuFLusjJtZqpcM2gNMHEKKGAem4VgY4bfEtOxeoUQ8CiSttZfIvHiJD(sWY40Km0jN(gh6WA0ymYctzgpO0KKC6IOg8mOIkMMleRcrc9I0FqqskDatBfvmnxiwfIe8v205lmTvY40m0JGPTXPzOhjjOgbd(RHmEqH3e6fHJRkphc700CHyviYyNVemlYziP6RCJdDynAmond9iyWFnKXdk8MqViCCv55qyNMMleRcrg78LGvn5LHt(jiwlPnk5eZ14qhwrnAm(tw(bnWo)AiJhu4nHEr44QYZHWonnxiwfIm25lbRAYldN8tqSwsBuYk0no0HvuJgJ)KLFqdSZVgY4bfEtOxeoUQ8CiSttZfIvHiJD(sWQM8YWj)eeRL0gLK1no0HvuJgJ)KLFqdmdc)1qgpOWBc9IWXvLNdHDAAUqSkezSZxcgRlVmCYpbXAjTrjNyUgh6WkQrJXFYYpObM2WFnKXdk8MqViCCv55qyNMMleRcrg78LGvHU8YWj)eeRL0gLCI5ACOdROgng)jl)Ggyge(RHmEqH3e6fHJRkphc700CHyviYyNVeSjMR8YWj)eeRL0gLK1no0H1OXyKfMY4in5SpchLNnsltkQOY4W)p0i4cZoj1R4JY1sdJhuAssoDru7OuxjLmond9iyAFEJtZqpssqnc25xdz8GcVj0lchxvEoe2PP5cXQqKXoFjytmx5LHt(jiwlPnkzf6gh6WkQrJXFYYpObMbH)AiJhu4nHEr44QYZHWonnxiwfIm25lbtLRIZj5LDwQJhJdDynAmgzHHJ0KZ(iCuE2iTmzCAg6rWoNWpfSYxUnuPLmnd9OuaTHp8vAnKXdk8MqViCCv55qyNMMleRcrg78LGPYvX5K8Yol1XJXHoSgngJSWWrAYzFekOvHy340m0JGLsoFkyLVCBOslzAg6rPaAdF4R0AiJhu4nHEr44QYZHWonnxiwfIm25lbtLRIZj5LDwQJhJdDynAmgzHLMleRcrcvUkoNKx2zPoEGbFJtZqpcwQf(PGv(YTHkTKPzOhLcOn8HVsRHmEqH3e6fHJRkphc700CHyviYyNVemwxEro6(UYl7Suhpgh6WkQrJXFYYpObM2NFnKXdk8MqViCCv55qyNMMleRcrg78LGnXCLxgojoJRCQzCOdROgng)jl)GgygCnKXdk8MqViCCv55qyNMMleRcrg78LGXbjNyUYldNeNXvo1mo0HvuJgJ)KLFqdmdUgY4bfEtOxeoUQ8CiSttZfIvHiJD(sWSOwgYZLHo5uzCOdRrJXPzOhbt7uaLPd6dPRtFbD11Qigsg13zhtkQOYddr(iQNtYWk1dtQ0O8WqKpcUWStscNfkQObIJ0KZ(iuqRcXUsAu2aXrAYzFeoHRakQVIkY4bLMKKtxe1GPTIkwpNSrLtIgsplCzBI6QKskTgY4bfEtOxeoUQ8CiSttZfIvHiJD(sWyDz4YxJmo0H1OX40m0JGrh0hsxN(IlJz1IKTmIg591qyfvKoOpKUo9f5q8hXtunPk)ZjfvKoOpKUo9f5q8hXtun5L(meekCfvKoOpKUo9fFUu4gHl)ewbP(BkQHjhtkQiDqFiDD6lqEdxVHvHi5b9X(8UYpLgHjfvKoOpKUo9fT4bbrZG8Cz9u1srfPd6dPRtFr75Qqr8L8LMmTAJIksh0hsxN(ctwbYPQjTv4FfvKoOpKUo9fwi(sYWkv5zGO1qgpOWBc9IWXvLNdHDAAUqSkezSZxcghKCI5kVmCsCgx5uZ4qhwrnAm(tw(bnWm4AiJhu4nHEr44QYZHWonnxiwfIm25lbJshsD8yCOdROgng)jl)GgyAF(1qgpOWBc9IWXvLNdHD6fvvus0LZP1qgpOWBc9IWXvLNdHDQTI2OgqJXilmdmnxiwfIe6fP)GGKu6aM2AQNt2OYjXh1WiDiKZLwsCCVS)xdz8GcVj0lchxvEoe2PCHzNKQqCBmgzHzGP5cXQqKqVi9heKKshW0wJbwpNSrLtIpQHr6qiNlTK44Ez)VgY4bfEtOxeoUQ8CiStP0bMhu4gJSWsZfIvHiHEr6piijLoGP9A4AiJhu4TdHDkoE(qvtNGGwdz8GcVDiSttZfIvHiJD(sWY40Km0jN(gh6WA0yCAg6rW02yKfwAUqSkejY40Km0jN(WGVg9IslZXFH2ckDG5bfUgdu565KnQCs0q6zHlBtuxfvSEozJkNedD1JIHKMCPR0AiJhu4TdHDAAUqSkezSZxcwgNMKHo5034qhwJgJtZqpcM2gJSWsZfIvHirgNMKHo50hg81O(Swbxy2jPEysL4hMUgCeq)W0fCHzNK6HjvIIUmYBAuUEozJkNenKEw4Y2e1vrfRNt2OYjXqx9OyiPjx6kTgY4bfE7qyNMMleRcrg78LGzrodjvFLBCOdRrJXPzOhbtBJrwyQpRvWfMDsIZ4kNeTHXkat9zTcUWStsCgx5K4YWjBdJvqJbQ(Swr9GizyLtwrut801OgTMglkpBKfDzK3ocMYkFzNnajJhu4cUWStsviUncC0gLsby8GcxWfMDsQcXTrqWr43qYbDjLwdz8GcVDiStFnsEzNL501yKfMYddr(iihcLNnKtFnx2zHoEocwQf(AUSZcD8apyNZZRKIkQSbome5JGCiuE2qo91CzNf645iyP2ZR0AiJhu4TdHDQEmOWngzHP(Swbxy2jPEysL4PVgY4bfE7qyNoOljn5s3yKfw9CYgvojg6Qhfdjn5sxJ6ZAfeCz8RnOWfpDnkJJa6hMUGlm7KupmPsue)1srfvJwtJfLNnYIUmYBhb7CHVsRHmEqH3oe2PqO8SPjnaX7NFjFmgzHP(Swbxy2jPEysL4hMUg1N1kQNtYWk1dtQe)W018j1N1kM4HZKHvozK8Y5iXpm91qgpOWBhc7uvoxgw5uiScnJrwyQpRvWfMDsQhMuj(HPRr9zTI65KmSs9WKkXpmDnFs9zTIjE4mzyLtgjVCos8dtFnKXdk82HWovLQgvkG8CJrwyQpRvWfMDsQhMujE6RHmEqH3oe2PQqr8L2xPLXilm1N1k4cZoj1dtQep91qgpOWBhc7ulQivOi(gJSWuFwRGlm7KupmPs80xdz8GcVDiStzhtTPyijMHGmgzHP(Swbxy2jPEysL4PVgY4bfE7qyN(AKen0TzmYct9zTcUWSts9WKkXtFnKXdk82HWo91ijAORXK1s4r68LGLdXFepr1KQ8pNmgzHP(Swbxy2jPEysL4PROI4iG(HPl4cZoj1dtQefDzK3GhSZFEnFs9zTIjE4mzyLtgjVCos80xdz8GcVDiStFnsIg6ASZxcgD11Qigsg13zhtgJSWWra9dtxWfMDsQhMujk6YiVDemdc)1qgpOWBhc70xJKOHUg78LG9lI)wurY0uRrqgJSWWra9dtxWfMDsQhMujk6YiVbpyge(kQObMMleRcrcwxgU81iyAROIkpOlbd(AsZfIvHiHf1YqEUm0jNkyARPEozJkNenKEw4Y2e1vP1qgpOWBhc70xJKOHUg78LG1IhKeL7OHkJrwy4iG(HPl4cZoj1dtQefDzK3GhSuh(kQObMMleRcrcwxgU81iyAVgY4bfE7qyN(AKen01yNVeSCiT0ZKHvYTg6IG4bfUXilmCeq)W0fCHzNK6HjvIIUmYBWdMbHVIkAGP5cXQqKG1LHlFncM2kQOYd6sWGVM0CHyvisyrTmKNldDYPcM2AQNt2OYjrdPNfUSnrDvAnKXdk82HWo91ijAORXoFjyxgZQfjBzenY7RHWgJSWWra9dtxWfMDsQhMujk6YiVDeSZRrzdmnxiwfIewuld55YqNCQGPTIkoOlbVuh(kTgY4bfE7qyN(AKen01yNVeSlJz1IKTmIg591qyJrwy4iG(HPl4cZoj1dtQefDzK3oc251KMleRcrclQLH8CzOtovW0wJ6ZAf1ZjzyL6HjvINUg1N1kQNtYWk1dtQefDzK3ocMYAd)uWNpfOEozJkNenKEw4Y2e1vjnd6shL6WFnKXdk82HWofZqqsgpOWLqO2ySZxcghKXTPq4bM2gJSWy8GstsYPlIAWZGRHmEqH3oe2PygcsY4bfUec1gJD(sWY46gUwg3McHhyABmYcdhPjN9rOGwfIDn1ZjBu5KGlm7Ke5wKJgT0mme5JOEojdRupmPsJbId))qJGlm7KuVIpkxR1Wu6cooJwGf1YqE(ccDYPAbQuoYBlWenzl4Ceh8cy)ValQLrTfyJAbPykUa9kWTfmXcEnAb)xH88fCCmPWtt1dEnKXdk82HWofZqqsgpOWLqO2ySZxcMf1YqEUm0jNkJBtHWdmTngzHLMleRcrImonjdDYPpm4RjnxiwfIewuld55YqNCQwdz8GcVDiStXmeKKXdkCjeQng78LGf6KtLXTPq4bM2gJSWsZfIvHirgNMKHo50hg8xdz8GcVDiStXmeKKXdkCjeQng78LGXxztNVg3McHhyABmYcRrZG88MGVYMoFHP9AiJhu4TdHDkMHGKmEqHlHqTXyNVemCeq)W0BRHmEqH3oe2PygcsY4bfUec1gJD(sWQy4bfUXTPq4bM2gJSWsZfIvHiHf5mKu9vom4VgY4bfE7qyNIziijJhu4siuBm25lbZICgsQ(k342ui8atBJrwyP5cXQqKWICgsQ(khM2RHmEqH3oe2PygcsY4bfUec1gJD(sWUrA6s(SgUgMsxaJhu4nbFLnD(cdZoMGKmEqHBmYcJXdkCbLoW8GcxGZy3jiKNR5Yol0Xd8GLso)AiJhu4nbFLnD(EiStP0bMhu4gJSWUSZcD8CeS0CHyvisqPdPoE0OmocOFy6IjE4mzyLtgjVCosu0LrE7iymEqHlO0bMhu4ccoc)gsoOlPOI4iG(HPl4cZoj1dtQefDzK3ocgJhu4ckDG5bfUGGJWVHKd6skQOYddr(iQNtYWk1dtQ0GJa6hMUOEojdRupmPsu0LrE7iymEqHlO0bMhu4ccoc)gsoOlPKsAuFwROEojdRupmPs8dtxJ6ZAfCHzNK6HjvIFy6A(K6ZAft8WzYWkNmsE5CK4hM(AiJhu4nbFLnD(EiSt)epzQr5KXilmCeq)W0fCHzNK6HjvIIUmYBWGVgLvFwROEojdRupmPs8dtxJY4iG(HPlM4HZKHvozK8Y5irrxg5n4LMleRcrcwxEz4KFcI1sAJsoXCvurCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4RKsRHmEqH3e8v2057HWo9IQkQMmSYjQl5JXilmCeq)W0fCHzNK6HjvIIUmYBWGVgLvFwROEojdRupmPs8dtxJY4iG(HPlM4HZKHvozK8Y5irrxg5n4LMleRcrcwxEz4KFcI1sAJsoXCvurCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4RKsRHmEqH3e8v2057HWoT4pI9r205sH1qgpOWBc(kB689qyN2Yq2b55s9WKkJrwyQpRvWfMDsQhMuj(HPRbhb0pmDbxy2jPEysLyQhjl6YiVbpgpOWfTmKDqEUupmPsG)Lg1N1kQNtYWk1dtQe)W01GJa6hMUOEojdRupmPsm1JKfDzK3GhJhu4IwgYoipxQhMujW)sZNuFwRyIhotgw5KrYlNJe)W0xdz8GcVj4RSPZ3dHDA9CsgwPEysLXilm1N1kQNtYWk1dtQe)W01GJa6hMUGlm7KupmPsu0LrEBnKXdk8MGVYMoFpe2Pt8WzYWkNmsE5CKXilmLXra9dtxWfMDsQhMujk6YiVbd(AuFwROEojdRupmPs8dtxjfvuVO0YC8xOTOEojdRupmPAnKXdk8MGVYMoFpe2Pt8WzYWkNmsE5CKXilmCeq)W0fCHzNK6HjvIIUmYBhDE4Rr9zTI65KmSs9WKkXpmDnuRroMePrnu4YWk1PYs4bfUGCwfI(RHmEqH3e8v2057HWoLlm7KupmPYyKfM6ZAf1ZjzyL6HjvIFy6AWra9dtxmXdNjdRCYi5LZrIIUmYBWlnxiwfIeSU8YWj)eeRL0gLCI5UgY4bfEtWxztNVhc7uUWStsvUkoNmgzHP(Swbxy2jPEysL4PRr9zTcUWSts9WKkrrxg5TJGX4bfUGlm7K8IAnee1eeCe(nKCqxsJ6ZAfCHzNK4mUYjrByScWuFwRGlm7KeNXvojUmCY2Wyfwdz8GcVj4RSPZ3dHDkxy2jzuQgJSWuFwRGlm7KeNXvojAdJv4i1N1k4cZojXzCLtIldNSnmwbnQpRvupNKHvQhMuj(HPRr9zTcUWSts9WKkXpmDnFs9zTIjE4mzyLtgjVCos8dtFnKXdk8MGVYMoFpe2PCHzNKQCvCozmYct9zTI65KmSs9WKkXpmDnQpRvWfMDsQhMuj(HPR5tQpRvmXdNjdRCYi5LZrIFy6AuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRWAiJhu4nbFLnD(EiSt5cZojVOwdbrnJrwyQpRvGHiUWCBqEUOigpgJZyKdtBJjUG0sIZyKlrwyQpRvGHiUWCBqEUeNXUtqIFy6Auw9zTcUWSts9WKkXtxrfvFwROEojdRupmPs80vurCeq)W0fu6aZdkCrr8xlLwdz8GcVj4RSPZ3dHDkxy2j5f1AiiQzmYcZa5dcQqdj4cZoj1F3lbH8Cb5Ske9vur1N1kWqexyUnipxIZy3jiXpmDJXzmYHPTXexqAjXzmYLilm1N1kWqexyUnipxIZy3jiXpmDnkR(Swbxy2jPEysL4PROIQpRvupNKHvQhMujE6kQiocOFy6ckDG5bfUOi(RLsRHmEqH3e8v2057HWoLshyEqHBmYct9zTI65KmSs9WKkXpmDnQpRvWfMDsQhMuj(HPR5tQpRvmXdNjdRCYi5LZrIFy6RHmEqH3e8v2057HWoLlm7KmkvJrwyQpRvWfMDsIZ4kNeTHXkCK6ZAfCHzNK4mUYjXLHt2ggRWAiJhu4nbFLnD(EiSt5cZojv5Q4CAnKXdk8MGVYMoFpe2PCHzNKQqCBwdxdz8GcVj4GGzROnQb0ymYcREozJkNeFudJ0HqoxAjXX9Y(xdocOFy6c1N1k)OggPdHCU0sIJ7L9VOi(RLg1N1k(OggPdHCU0sIJ7L9V0wrBe)W01OS6ZAfCHzNK6HjvIFy6AuFwROEojdRupmPs8dtxZNuFwRyIhotgw5KrYlNJe)W0vsdocOFy6IjE4mzyLtgjVCosu0LrEdg81OS6ZAfCHzNK4mUYjrBySchblnxiwfIeCqYjMR8YWjXzCLtnnkR8WqKpI65KmSs9WKkn4iG(HPlQNtYWk1dtQefDzK3ocwo(Rbhb0pmDbxy2jPEysLOOlJ8g8sZfIvHiXeZvEz4KFcI1sAJsY6kPOIkBGddr(iQNtYWk1dtQ0GJa6hMUGlm7KupmPsu0LrEdEP5cXQqKyI5kVmCYpbXAjTrjzDLuurCeq)W0fCHzNK6HjvIIUmYBhblh)vsP1qgpOWBcoOdHDQfvKufIBJXilmLRNt2OYjXh1WiDiKZLwsCCVS)1GJa6hMUq9zTYpQHr6qiNlTK44Ez)lkI)APr9zTIpQHr6qiNlTK44Ez)lTOIe)W01OxuAzo(l0wyROnQb0OKIkQC9CYgvoj(OggPdHCU0sIJ7L9VMbDPJ0wP1qgpOWBcoOdHDQTI2i9inBmYcREozJkNe5fQbPLeHryisdocOFy6cUWSts9WKkrrxg5n4L6WxdocOFy6IjE4mzyLtgjVCosu0LrEdg81OS6ZAfCHzNK4mUYjrBySchblnxiwfIeCqYjMR8YWjXzCLtnnkR8WqKpI65KmSs9WKkn4iG(HPlQNtYWk1dtQefDzK3ocwo(Rbhb0pmDbxy2jPEysLOOlJ8g8sZfIvHiXeZvEz4KFcI1sAJsY6kPOIkBGddr(iQNtYWk1dtQ0GJa6hMUGlm7KupmPsu0LrEdEP5cXQqKyI5kVmCYpbXAjTrjzDLuurCeq)W0fCHzNK6HjvIIUmYBhblh)vsP1qgpOWBcoOdHDQTI2i9inBmYcREozJkNe5fQbPLeHryisdocOFy6cUWSts9WKkrrxg5nyWxJYkRmocOFy6IjE4mzyLtgjVCosu0LrEdEP5cXQqKG1Lxgo5NGyTK2OKtmxnQpRvWfMDsIZ4kNeTHXkat9zTcUWStsCgx5K4YWjBdJvqjfvuzCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4Rr9zTcUWStsCgx5KOnmwHJGLMleRcrcoi5eZvEz4K4mUYPMskPr9zTI65KmSs9WKkXpmDLwdz8GcVj4Goe2Pt8WzYWkNmsE5CKXilS65KnQCs0q6zHlBtuxn6fLwMJ)cTfu6aZdk81qgpOWBcoOdHDkxy2jPEysLXilS65KnQCs0q6zHlBtuxnkRxuAzo(l0wqPdmpOWvur9IslZXFH2IjE4mzyLtgjVCosP1qgpOWBcoOdHDkLoW8Gc3yKf2GUe8sD4RPEozJkNenKEw4Y2e1vJ6ZAfCHzNK4mUYjrBySchblnxiwfIeCqYjMR8YWjXzCLtnn4iG(HPlM4HZKHvozK8Y5irrxg5nyWxdocOFy6cUWSts9WKkrrxg5TJGLJ)RHmEqH3eCqhc7ukDG5bfUXilSbDj4L6Wxt9CYgvojAi9SWLTjQRgCeq)W0fCHzNK6HjvIIUmYBWGVgLvwzCeq)W0ft8WzYWkNmsE5CKOOlJ8g8sZfIvHibRlVmCYpbXAjTrjNyUAuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRGskQOY4iG(HPlM4HZKHvozK8Y5irrxg5nyWxJ6ZAfCHzNK4mUYjrBySchblnxiwfIeCqYjMR8YWjXzCLtnLusJ6ZAf1ZjzyL6HjvIFy6kzmYhQQN(irwyQpRv0q6zHlBtuxrByScWuFwROH0Zcx2MOUIldNSnmwbJr(qv90hj6EPpIhcM2RHmEqH3eCqhc70lQQOAYWkNOUKpgJSWughb0pmDbxy2jPEysLOOlJ8g8o3ZROI4iG(HPl4cZoj1dtQefDzK3ocwQRKgCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4Rrz1N1k4cZojXzCLtI2WyfocwAUqSkej4GKtmx5LHtIZ4kNAAuw5HHiFe1ZjzyL6HjvAWra9dtxupNKHvQhMujk6YiVDeSC8xdocOFy6cUWSts9WKkrrxg5n4DELuurLnWHHiFe1ZjzyL6HjvAWra9dtxWfMDsQhMujk6YiVbVZRKIkIJa6hMUGlm7KupmPsu0LrE7iy54VskTgY4bfEtWbDiStl(JyFKnDUuWyKfgocOFy6IjE4mzyLtgjVCosu0LrE7icoc)gsoOlPrz1N1k4cZojXzCLtI2WyfocwAUqSkej4GKtmx5LHtIZ4kNAAuw5HHiFe1ZjzyL6HjvAWra9dtxupNKHvQhMujk6YiVDeSC8xdocOFy6cUWSts9WKkrrxg5n4LMleRcrIjMR8YWj)eeRL0gLK1vsrfv2ahgI8rupNKHvQhMuPbhb0pmDbxy2jPEysLOOlJ8g8sZfIvHiXeZvEz4KFcI1sAJsY6kPOI4iG(HPl4cZoj1dtQefDzK3ocwo(RKsRHmEqH3eCqhc70I)i2hztNlfmgzHHJa6hMUGlm7KupmPsu0LrE7icoc)gsoOlPrzLvghb0pmDXepCMmSYjJKxohjk6YiVbV0CHyvisW6YldN8tqSwsBuYjMRg1N1k4cZojXzCLtI2WyfGP(Swbxy2jjoJRCsCz4KTHXkOKIkQmocOFy6IjE4mzyLtgjVCosu0LrEdg81O(Swbxy2jjoJRCs0ggRWrWsZfIvHibhKCI5kVmCsCgx5utjL0O(Swr9CsgwPEysL4hMUsRHmEqH3eCqhc70pXtMAuozmYcdhb0pmDbxy2jPEysLOOlJ8gm4RrzLvghb0pmDXepCMmSYjJKxohjk6YiVbV0CHyvisW6YldN8tqSwsBuYjMRg1N1k4cZojXzCLtI2WyfGP(Swbxy2jjoJRCsCz4KTHXkOKIkQmocOFy6IjE4mzyLtgjVCosu0LrEdg81O(Swbxy2jjoJRCs0ggRWrWsZfIvHibhKCI5kVmCsCgx5utjL0O(Swr9CsgwPEysL4hMUsRHmEqH3eCqhc70jE4mzyLtgjVCoYyKfM6ZAfCHzNK4mUYjrBySchblnxiwfIeCqYjMR8YWjXzCLtnnkR8WqKpI65KmSs9WKkn4iG(HPlQNtYWk1dtQefDzK3ocwo(Rbhb0pmDbxy2jPEysLOOlJ8g8sZfIvHiXeZvEz4KFcI1sAJsY6kPOIkBGddr(iQNtYWk1dtQ0GJa6hMUGlm7KupmPsu0LrEdEP5cXQqKyI5kVmCYpbXAjTrjzDLuurCeq)W0fCHzNK6HjvIIUmYBhblh)vAnKXdk8MGd6qyNYfMDsQhMuzmYctzLXra9dtxmXdNjdRCYi5LZrIIUmYBWlnxiwfIeSU8YWj)eeRL0gLCI5Qr9zTcUWStsCgx5KOnmwbyQpRvWfMDsIZ4kNexgozBySckPOIkJJa6hMUyIhotgw5KrYlNJefDzK3GbFnQpRvWfMDsIZ4kNeTHXkCeS0CHyvisWbjNyUYldNeNXvo1usjnQpRvupNKHvQhMuj(HPVgY4bfEtWbDiStRNtYWk1dtQmgzHP(Swr9CsgwPEysL4hMUgLvghb0pmDXepCMmSYjJKxohjk6YiVbpdcFnQpRvWfMDsIZ4kNeTHXkat9zTcUWStsCgx5K4YWjBdJvqjfvuzCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4Rr9zTcUWStsCgx5KOnmwHJGLMleRcrcoi5eZvEz4K4mUYPMskPrzCeq)W0fCHzNK6HjvIIUmYBWtBdQOIFs9zTIjE4mzyLtgjVCos80vAnKXdk8MGd6qyN2Yq2b55s9WKkJrwy4iG(HPl4cZojJsvu0LrEdENxrfnWHHiFeCHzNKrPUgY4bfEtWbDiSt1lQroMKHvEr(3yKfM6ZAfFINm1OCs8018j1N1kM4HZKHvozK8Y5iXtxZNuFwRyIhotgw5KrYlNJefDzK3ocM6ZAf6f1ihtYWkVi)lUmCY2Wyfsby8GcxWfMDsQcXTrqWr43qYbDP1qgpOWBcoOdHDkxy2jPke3gJrwyQpRv8jEYuJYjXtxJYkpme5JOOw4SJjnmEqPjj50frTJoxLuurgpO0KKC6IO2rNxjnkBG1ZjBu5KGlm7KunUQC9VKpkQ4WvonImIHMmHoEGxQFELwdz8GcVj4Goe2PTNovEKMxdz8GcVj4Goe2PCHzNKQCvCozmYct9zTcUWStsCgx5KOnmwb4btzgpO0KKC6IOwkyTvst9CYgvoj4cZojvJRkx)l5JMHRCAezednzcD8CuQF(1qgpOWBcoOdHDkxy2jPkxfNtgJSWuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRWAiJhu4nbh0HWoLlm7KmkvJrwyQpRvWfMDsIZ4kNeTHXkad(RHmEqH3eCqhc7uNMmQKdD1P2ymYct5ISf1YyvisrfnWbHva55kPr9zTcUWStsCgx5KOnmwbyQpRvWfMDsIZ4kNexgozByScRHmEqH3eCqhc7uUWStYlQ1qquZyKfM6ZAfyiIlm3gKNlkIXJM65KnQCsWfMDsIClYrJwAuw5HHiFe8vhczryEqHRHXdknjjNUiQDuQvjfvKXdknjjNUiQD05vAnKXdk8MGd6qyNYfMDsErTgcIAgJSWuFwRadrCH52G8CrrmE0mme5JGlm7KKWzHMpP(SwXepCMmSYjJKxohjE6AuEyiYhbF1HqweMhu4kQiJhuAssoDru7OuIsRHmEqH3eCqhc7uUWStYlQ1qquZyKfM6ZAfyiIlm3gKNlkIXJMHHiFe8vhczryEqHRHXdknjjNUiQD05UgY4bfEtWbDiSt5cZojj40HIgkCJrwyQpRvWfMDsIZ4kNeTHXkCK6ZAfCHzNK4mUYjXLHt2ggRWAiJhu4nbh0HWoLlm7KKGthkAOWngzHP(Swbxy2jjoJRCs0ggRam1N1k4cZojXzCLtIldNSnmwbn6fLwMJ)cTfCHzNKQCvCoTgY4bfEtWbDiStP0bMhu4gJ8HQ6PpsKf2LDwOJh4blLCEJr(qv90hj6EPpIhcM2RHRHP0fCWfkk0GoiOf8AipFb5fQbP1cqyegIwGjAYwaRlwGbuJwaAwGjAYwWeZDbXKrLjQrI1qgpOWBcCeq)W0BWSv0gPhPzJrwy1ZjBu5KiVqniTKimcdrAWra9dtxWfMDsQhMujk6YiVbVuh(AWra9dtxmXdNjdRCYi5LZrIIUmYBWGVgLvFwRGlm7KeNXvojAdJv4iyP5cXQqKyI5kVmCsCgx5utJYkpme5JOEojdRupmPsdocOFy6I65KmSs9WKkrrxg5TJGLJ)AWra9dtxWfMDsQhMujk6YiVbV0CHyvismXCLxgo5NGyTK2OKSUskQOYg4WqKpI65KmSs9WKkn4iG(HPl4cZoj1dtQefDzK3GxAUqSkejMyUYldN8tqSwsBuswxjfvehb0pmDbxy2jPEysLOOlJ82rWYXFLuAnKXdk8Mahb0pm92HWo1wrBKEKMngzHvpNSrLtI8c1G0sIWimePbhb0pmDbxy2jPEysLOOlJ8gm4RrzdCyiYhb5qO8SHC6ROIkpme5JGCiuE2qo91CzNf64bEWsnWxjL0OSY4iG(HPlM4HZKHvozK8Y5irrxg5n4Pn81O(Swbxy2jjoJRCs0ggRam1N1k4cZojXzCLtIldNSnmwbLuurLXra9dtxmXdNjdRCYi5LZrIIUmYBWGVg1N1k4cZojXzCLtI2WyfGbFLusJ6ZAf1ZjzyL6HjvIFy6AUSZcD8apyP5cXQqKG1LxKJUVR8Yol1XZAiJhu4nbocOFy6TdHDQTI2OgqJXilS65KnQCs8rnmshc5CPLeh3l7Fn4iG(HPluFwR8JAyKoeY5sljoUx2)II4VwAuFwR4JAyKoeY5sljoUx2)sBfTr8dtxJYQpRvWfMDsQhMuj(HPRr9zTI65KmSs9WKkXpmDnFs9zTIjE4mzyLtgjVCos8dtxjn4iG(HPlM4HZKHvozK8Y5irrxg5nyWxJYQpRvWfMDsIZ4kNeTHXkCeS0CHyvismXCLxgojoJRCQPrzLhgI8rupNKHvQhMuPbhb0pmDr9CsgwPEysLOOlJ82rWYXFn4iG(HPl4cZoj1dtQefDzK3GxAUqSkejMyUYldN8tqSwsBuswxjfvuzdCyiYhr9CsgwPEysLgCeq)W0fCHzNK6HjvIIUmYBWlnxiwfIetmx5LHt(jiwlPnkjRRKIkIJa6hMUGlm7KupmPsu0LrE7iy54VskTgY4bfEtGJa6hME7qyNArfjvH42ymYcREozJkNeFudJ0HqoxAjXX9Y(xdocOFy6c1N1k)OggPdHCU0sIJ7L9VOi(RLg1N1k(OggPdHCU0sIJ7L9V0Iks8dtxJErPL54VqBHTI2OgqZAykDbjdccAbMrPaYZxq4li0h0fDqWdk82cSrTGjJwGtMlifghB8cuFZcWVQiFG0AbVgYZxaAwq4la)xaQTavAgQwWKX(cYcOpYZxGnQfW6liQf8AipFbOzbniuE2aP1cujBu0cy91qgpOWBcCeq)W0Bhc70lQQOAYWkNOUKpgJSW0NAnmLUGufYK1QTGxJwWfvvuTfyIMSfW6IfyayxWeZDbO2ckI)ATaUTatccY4fCzfOf0EfTGjwaMBZcqZcujBu0cMyUI1qgpOWBcCeq)W0Bhc70lQQOAYWkNOUKpgJSWmq9P0GJa6hMUyIhotgw5KrYlNJefDzK3GbFnQpRvWfMDsIZ4kNeTHXkCeS0CHyvismXCLxgojoJRCQPbhb0pmDbxy2jPEysLOOlJ82rWYX)1qgpOWBcCeq)W0Bhc70lQQOAYWkNOUKpgJSWmq9P0GJa6hMUGlm7KupmPsu0LrEdg81OSbome5JGCiuE2qo9vurLhgI8rqoekpBiN(AUSZcD8apyPg4RKsAuwzCeq)W0ft8WzYWkNmsE5CKOOlJ8g8sZfIvHibRlVmCYpbXAjTrjNyUAuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRGskQOY4iG(HPlM4HZKHvozK8Y5irrxg5nyWxJ6ZAfCHzNK4mUYjrByScWGVskPr9zTI65KmSs9WKkXpmDnx2zHoEGhS0CHyvisW6YlYr33vEzNL64znmLUGufYK1QTGxJwWN4jtnkNwGjAYwaRlwGbGDbtm3fGAlOi(R1c42cmjiiJxWLvGwq7v0cMybyUnlanlqLSrrlyI5kwdz8GcVjWra9dtVDiSt)epzQr5KXilmCeq)W0ft8WzYWkNmsE5CKOOlJ8gm4Rr9zTcUWStsCgx5KOnmwHJGLMleRcrIjMR8YWjXzCLtnn4iG(HPl4cZoj1dtQefDzK3ocwo(VgY4bfEtGJa6hME7qyN(jEYuJYjJrwy4iG(HPl4cZoj1dtQefDzK3GbFnkBGddr(iihcLNnKtFfvu5HHiFeKdHYZgYPVMl7SqhpWdwQb(kPKgLvghb0pmDXepCMmSYjJKxohjk6YiVbpTHVg1N1k4cZojXzCLtI2WyfGP(Swbxy2jjoJRCsCz4KTHXkOKIkQmocOFy6IjE4mzyLtgjVCosu0LrEdg81O(Swbxy2jjoJRCs0ggRam4RKsAuFwROEojdRupmPs8dtxZLDwOJh4blnxiwfIeSU8IC09DLx2zPoEwdtPlWaQrlOPZLclazxWeZDbS)xaRVaUOfe(cW)fW(FbMHB0SavAbp9fyJAbqHNt1cMm2xWKrl4YWTGpbXAz8cUScipFbTxrlWKwqgNMwaplaI42SGXmwaxy2PfGZ4kNAlG9)cMmEwWeZDbMCZnAwGbiETzbVg9fRHmEqH3e4iG(HP3oe2Pf)rSpYMoxkymYcdhb0pmDXepCMmSYjJKxohjk6YiVbV0CHyvisun5LHt(jiwlPnk5eZvdocOFy6cUWSts9WKkrrxg5n4LMleRcrIQjVmCYpbXAjTrjzDnkpme5JOEojdRupmPsJY4iG(HPlQNtYWk1dtQefDzK3oIGJWVHKd6skQiocOFy6I65KmSs9WKkrrxg5n4LMleRcrIQjVmCYpbXAjTrjRqxjfv0ahgI8rupNKHvQhMuPKg1N1k4cZojXzCLtI2WyfGNb18j1N1kM4HZKHvozK8Y5iXpmDnQpRvupNKHvQhMuj(HPRr9zTcUWSts9WKkXpm91Wu6cmGA0cA6CPWcmrt2cy9fyMr(c0JwdPcrIfyayxWeZDbO2ckI)ATaUTatccY4fCzfOf0EfTGjwaMBZcqZcujBu0cMyUI1qgpOWBcCeq)W0Bhc70I)i2hztNlfmgzHHJa6hMUyIhotgw5KrYlNJefDzK3oIGJWVHKd6sAuFwRGlm7KeNXvojAdJv4iyP5cXQqKyI5kVmCsCgx5utdocOFy6cUWSts9WKkrrxg5TJuMGJWVHKd6shY4bfUyIhotgw5KrYlNJeeCe(nKCqxsP1qgpOWBcCeq)W0Bhc70I)i2hztNlfmgzHHJa6hMUGlm7KupmPsu0LrE7icoc)gsoOlPrzLnWHHiFeKdHYZgYPVIkQ8WqKpcYHq5zd50xZLDwOJh4bl1aFLusJYkJJa6hMUyIhotgw5KrYlNJefDzK3GxAUqSkejyD5LHt(jiwlPnk5eZvJ6ZAfCHzNK4mUYjrByScWuFwRGlm7KeNXvojUmCY2Wyfusrfvghb0pmDXepCMmSYjJKxohjk6YiVbd(AuFwRGlm7KeNXvojAdJvag8vsjnQpRvupNKHvQhMuj(HPR5Yol0Xd8GLMleRcrcwxEro6(UYl7SuhpkTgMsxGbuJwWeZDbMOjBbS(cq2fGgJAlWenziFbtgTGld3c(eeRLybga2f4Xy8cEnAbMOjBbvOVaKDbtgTGHHiFwaQTGHvGCJxa7)fGgJAlWenziFbtgTGld3c(eeRLynKXdk8Mahb0pm92HWoDIhotgw5KrYlNJmgzHP(Swbxy2jjoJRCs0ggRWrWsZfIvHiXeZvEz4K4mUYPMgCeq)W0fCHzNK6HjvIIUmYBhbJGJWVHKd6sAUSZcD8aV0CHyvisW6YlYr33vEzNL64rJ6ZAf1ZjzyL6HjvIFy6RHmEqH3e4iG(HP3oe2Pt8WzYWkNmsE5CKXilm1N1k4cZojXzCLtI2WyfocwAUqSkejMyUYldNeNXvo10mme5JOEojdRupmPsdocOFy6I65KmSs9WKkrrxg5TJGrWr43qYbDjn4iG(HPl4cZoj1dtQefDzK3GxAUqSkejMyUYldN8tqSwsBuswxdocOFy6cUWSts9WKkrrxg5n4PTbxdz8GcVjWra9dtVDiStN4HZKHvozK8Y5iJrwyQpRvWfMDsIZ4kNeTHXkCeS0CHyvismXCLxgojoJRCQPrzdCyiYhr9CsgwPEysLIkIJa6hMUOEojdRupmPsu0LrEdEP5cXQqKyI5kVmCYpbXAjTrjRqxjn4iG(HPl4cZoj1dtQefDzK3GxAUqSkejMyUYldN8tqSwsBuswFnmLUadOgTawFbi7cMyUla1wq4la)xa7)fygUrZcuPf80xGnQfafEovlyYyFbtgTGld3c(eeRLXl4YkG88f0EfTGjJNfysliJttlG84LNTGl78cy)VGjJNfmzurla1wGhZcyOI4VwlGxq9CAbHDb6Hjvl4hMUynKXdk8Mahb0pm92HWoLlm7KupmPYyKfgocOFy6IjE4mzyLtgjVCosu0LrEdEP5cXQqKG1Lxgo5NGyTK2OKtmxnQpRvWfMDsIZ4kNeTHXkat9zTcUWStsCgx5K4YWjBdJvqJ6ZAf1ZjzyL6HjvIFy6AUSZcD8apyP5cXQqKG1LxKJUVR8Yol1XZAykDbgqnAbvOVaKDbtm3fGAli8fG)lG9)cmd3OzbQ0cE6lWg1cGcpNQfmzSVGjJwWLHBbFcI1Y4fCzfqE(cAVIwWKrfTauZnAwadve)1Ab8cQNtl4hM(cy)VGjJNfW6lWmCJMfOs44slGtZiiwfIwW)vipFb1ZjXAiJhu4nbocOFy6TdHDA9CsgwPEysLXilm1N1k4cZoj1dtQe)W01OmocOFy6IjE4mzyLtgjVCosu0LrEdEP5cXQqKOcD5LHt(jiwlPnk5eZvrfXra9dtxWfMDsQhMujk6YiVDeS0CHyvismXCLxgo5NGyTK2OKSUsAuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRGgCeq)W0fCHzNK6HjvIIUmYBWtBdUgY4bfEtGJa6hME7qyN2Yq2b55s9WKkJrwyQpRvWfMDsQhMuj(HPRbhb0pmDbxy2jPEysLyQhjl6YiVbpgpOWfTmKDqEUupmPsG)Lg1N1kQNtYWk1dtQe)W01GJa6hMUOEojdRupmPsm1JKfDzK3GhJhu4IwgYoipxQhMujW)sZNuFwRyIhotgw5KrYlNJe)W0xdtPlWaQrlqpUlyIf0oOpIoiOfW(ci4MIxaRUaKVGjJwGtWnlahb0pm9fyI8FyA8cEoe1AlqbTke7lyYiFbHdP1c(Vc55lGlm70c0dtQwW)rlyIfKfMl4YoVGSNNxATGI)i2Nf005sHfGARHmEqH3e4iG(HP3oe2P6f1ihtYWkVi)BmYcByiYhr9CsgwPEysLg1N1k4cZoj1dtQepDnQpRvupNKHvQhMujk6YiVDuo(lUmCRHmEqH3e4iG(HP3oe2P6f1ihtYWkVi)BmYc7tQpRvmXdNjdRCYi5LZrINUMpP(SwXepCMmSYjJKxohjk6YiVDeJhu4cUWStYlQ1qqutqWr43qYbDjngiosto7JqbTke7RHmEqH3e4iG(HP3oe2P6f1ihtYWkVi)BmYct9zTI65KmSs9WKkXtxJ6ZAf1ZjzyL6HjvIIUmYBhLJ)IldNgCeq)W0fu6aZdkCrr8xln4iG(HPlM4HZKHvozK8Y5irrxg5nngiosto7JqbTke7RHRHmEqH3ewKZqs1x5hc7uUWStYlQ1qquZyKfM6ZAfyiIlm3gKNlkIXJX4mg5W0EnKXdk8MWICgsQ(k)qyNYfMDsQcXTznKXdk8MWICgsQ(k)qyNYfMDsQYvX50A4AykDbhKzKVG65oYZxaHMmQwWKrlijzbrTGJpixaeLt(Nle1mEbM0cmzFwWelWaoDSavYgfTGjJwWXXKcpnvp4fyI8FykwGbuJwaAwa3wqlcFbCBbNJ4Gxqg3wGf5Owg9xq8QfysgLMwqtN8zbXRwaoJRCQTgY4bfEtyrTmKNldDYPcgLoW8Gc3yKfMY1ZjBu5KOH0Zcx2MOUkQy9CYgvojg6Qhfdjn5sxjnkR(Swr9CsgwPEysL4hMUIkQxuAzo(l0wWfMDsQYvX5KsAWra9dtxupNKHvQhMujk6YiVTgMsxGbGDbMKrPPfyroQLr)feVAb4iG(HPVatK)dZ2cy)VGMo5ZcIxTaCgx5uZ4fOxOOqd6GGwGbC6ybrAQwaLMkTMmKNVacQrRHmEqH3ewuld55YqNCQoe2Pu6aZdkCJrwyddr(iQNtYWk1dtQ0GJa6hMUOEojdRupmPsu0LrEtdocOFy6cUWSts9WKkrrxg5nnQpRvWfMDsQhMuj(HPRr9zTI65KmSs9WKkXpmDn6fLwMJ)cTfCHzNKQCvCoTgY4bfEtyrTmKNldDYP6qyNArfjvH42ymYcREozJkNeFudJ0HqoxAjXX9Y(xJ6ZAfFudJ0HqoxAjXX9Y(xAROnIN(AiJhu4nHf1YqEUm0jNQdHDQTI2i9inBmYcREozJkNe5fQbPLeHryisZLDwOJh4Lso)AiJhu4nHf1YqEUm0jNQdHD6N4jtnkNmgzHzG1ZjBu5KOH0Zcx2MOURHmEqH3ewuld55YqNCQoe2PCHzNKrPAmYcdhb0pmDr9CsgwPEysLOi(R1AiJhu4nHf1YqEUm0jNQdHDkxy2jPke3gJrwy4iG(HPlQNtYWk1dtQefXFT0O(Swbxy2jjoJRCs0ggRWrQpRvWfMDsIZ4kNexgozByScRHmEqH3ewuld55YqNCQoe2P1ZjzyL6HjvRHP0fCsuxgcsRfyslqNr1c0Jbf(cEnAbMOjBbP6bB8cuFZcqZcmrqqlaIBZcGcpFbKhV8SfyJAbQXKTGjJwW5io4fW(FbP6bVatK)dZ2cEoe1AlOEUJ88fmz0csswqul44dYfar5K)5crT1qgpOWBclQLH8CzOtovhc7u9yqHBmYcZavUEozJkNenKEw4Y2e1vrfRNt2OYjXqx9OyiPjx6kTgY4bfEtyrTmKNldDYP6qyN(jEYuJYjJrwyQpRvupNKHvQhMuj(HPROI6fLwMJ)cTfCHzNKQCvCoTgY4bfEtyrTmKNldDYP6qyNw8hX(iB6CPGXilm1N1kQNtYWk1dtQe)W0vur9IslZXFH2cUWStsvUkoNwdz8GcVjSOwgYZLHo5uDiStVOQIQjdRCI6s(ymYct9zTI65KmSs9WKkXpmDfvuVO0YC8xOTGlm7KuLRIZP1q8GcVjSOwgYZLHo5uDiStN4HZKHvozK8Y5iJrwyQpRvupNKHvQhMuj(HPROI6fLwMJ)cTfCHzNKQCvCoPOI6fLwMJ)cTfxuvr1KHvorDjFuur9IslZXFH2II)i2hztNlfuur9IslZXFH2IpXtMAuoTgY4bfEtyrTmKNldDYP6qyNYfMDsQhMuzmYctVO0YC8xOTyIhotgw5KrYlNJwdtPlWaQrl4GJu4cMybTd6JOdcAbSVacUP4fKQfMDAbNbXTzb)xH88fmz0cooMu4PP6bVatK)dZf8CiQ1wq9Ch55livlm70cmGXzHybga2fKQfMDAbgW4SybO2cggI8H(gVatAby2nAwWRrl4GJu4cmrtgYxWKrl44ysHNMQh8cmr(pmxWZHOwBbM0cq(qv90Nfmz0cs1u4cWzS7eKXlOflWKmccAbnonTa0iwdz8GcVjSOwgYZLHo5uDiSt1lQroMKHvEr(3yKfMbome5JGlm7KKWzHMpP(SwXepCMmSYjJKxohjE6A(K6ZAft8WzYWkNmsE5CKOOlJ82rWuMXdkCbxy2jPke3gbbhHFdjh0LsbuFwRqVOg5ysgw5f5FXLHt2ggRGsRHP0fyayxWbhPWfKXn3OzbQe5l41O)c(Vc55lyYOfCCmPWfyI8FyA8cmjJGGwWRrlanlyIf0oOpIoiOfW(ci4MIxqQwy2PfCge3MfG8fmz0cohXbFAQEWlWe5)WuSgY4bfEtyrTmKNldDYP6qyNQxuJCmjdR8I8VXilm1N1k4cZoj1dtQepDnQpRvupNKHvQhMujk6YiVDemLz8GcxWfMDsQcXTrqWr43qYbDPua1N1k0lQroMKHvEr(xCz4KTHXkO0AiJhu4nHf1YqEUm0jNQdHDkxy2jPke3gJrwy)yef)rSpYMoxkik6YiVbVZROIFs9zTII)i2hztNlfKPFqovSkccnAjAdJvaEWFnmLUGdsAbMSplyIfCzfOf0EfTatAbzCAAbKhV8SfCzNxGnQfmz0ciFqfTGu9GxGjY)HPXlGst(cq2fmzurg1wqBqqqlyqxAbfDzKJ88fe(cohXblwGbWyuBbHdP1cuPzOAbtSa1x5lyIfCqqvSa2)lWaoDSaKDb1ZDKNVGjJwqsYcIAbhFqUaikN8pxiQjwdz8GcVjSOwgYZLHo5uDiSt5cZojv5Q4CYyKfgocOFy6cUWSts9WKkrr8xlnx2zHoEos5Zf(hQS2WpfahPjN9rOGwfIDLusJ6ZAfCHzNK4mUYjrByScWuFwRGlm7KeNXvojUmCY2Wyf0yG1ZjBu5KOH0Zcx2MOUAmW65KnQCsm0vpkgsAYL(AykDbgqoe1AlOEUJ88fmz0cs1cZoTadWCDdxRfar5K)5slJxWzCvCoTGww8G(lWJzbQ0cEn6VaEwWKrlG8)cc7cs1dEbi7cmGthyEqHVauBbH1UaCeq)W0xa3wWVcDDKNVaCgx5uBbMiiOfCzfOfGMfmSc0cGcpNQfmXcuFLVGjRIxE2ck6Yih55l4YoVgY4bfEtyrTmKNldDYP6qyNYfMDsQYvX5KXilm1N1k4cZoj1dtQepDnQpRvWfMDsQhMujk6YiVDeSC8xJY1ZjBu5KGlm7Ke5wKJgTuurCeq)W0fu6aZdkCrrxg5nLwdtPl4mUkoNwqllEq)fWqMSwTfOslyYOfaXTzbyUnla5lyYOfCoIdEbMi)hMlGBl44ysHlWebbTGIAtu0cMmAb4mUYP2cA6KpRHmEqH3ewuld55YqNCQoe2PCHzNKQCvCozmYct9zTI65KmSs9WKkXtxJ6ZAfCHzNK6HjvIFy6AuFwROEojdRupmPsu0LrE7iy54)AiJhu4nHf1YqEUm0jNQdHDkxy2j5f1AiiQzmYc7tQpRvmXdNjdRCYi5LZrINUMHHiFeCHzNKeol0OS6ZAfFINm1OCs8dtxrfz8GstsYPlIAW0wjnFs9zTIjE4mzyLtgjVCosu0LrEdEmEqHl4cZojVOwdbrnbbhHFdjh0LmgNXihM2gtCbPLeNXixISWuFwRadrCH52G8CjoJDNGe)W01OS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91OS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)APKskTgMsxqkihsRf0gUMf8AipFbPykUGunfUaZmYxqQEWliJBlqLiFbVg9xdz8GcVjSOwgYZLHo5uDiSt5cZojVOwdbrnJrwyQpRvGHiUWCBqEUOigpAWra9dtxWfMDsQhMujk6YiVPrz1N1kQNtYWk1dtQepDfvu9zTcUWSts9WKkXtxjJXzmYHP9AiJhu4nHf1YqEUm0jNQdHDkxy2jzuQgJSWuFwRGlm7KeNXvojAdJv4iyP5cXQqKyI5kVmCsCgx5uBnKXdk8MWIAzipxg6Kt1HWoLlm7KufIBJXilm1N1kQNtYWk1dtQepDfv8Yol0Xd80(8RHmEqH3ewuld55YqNCQoe2Pu6aZdkCJrwyQpRvupNKHvQhMuj(HPRr9zTcUWSts9WKkXpmDJr(qv90hjYc7Yol0Xd8GLApVXiFOQE6JeDV0hXdbt71qgpOWBclQLH8CzOtovhc7uUWStsvUkoNwdxdtPlGXdk8MiJRB4AbdZoMGKmEqHBmYcJXdkCbLoW8GcxGZy3jiKNR5Yol0Xd8GLso)AykDbgqnAbgWPdmpOWxaYUatYOIwauyUGWxWLDEbS)xaVGJJjfEAQEWlWe5)WCbO2cWXf55l4PVgY4bfEtKX1nCToe2Pu6aZdkCJrwyx2zHoEocM2NxdocOFy6IjE4mzyLtgjVCosu0LrE7iyktWr43qYbDPdz8GcxmXdNjdRCYi5LZrccoc)gsoOlPKgCeq)W0fCHzNK6HjvIIUmYBhbtzcoc)gsoOlDiJhu4IjE4mzyLtgjVCosqWr43qYbDPdz8GcxWfMDsQhMuji4i8Bi5GUKsAuFwROEojdRupmPs8dtxJ6ZAfCHzNK6HjvIFy6A(K6ZAft8WzYWkNmsE5CK4hMUgd8hJO4pI9r205sbrrxg5T1Wu6cmGA0cmGthyEqHVaKDbMKrfTaOWCbHVGl78cy)VaEbNJ4GxGjY)H5cqTfGJlYZxWtFnKXdk8MiJRB4ADiStP0bMhu4gJSWUSZcD8CeSuh(AWra9dtxupNKHvQhMujk6YiVDemLj4i8Bi5GU0HmEqHlQNtYWk1dtQeeCe(nKCqxsjn4iG(HPlM4HZKHvozK8Y5irrxg5TJGPmbhHFdjh0LoKXdkCr9CsgwPEysLGGJWVHKd6shY4bfUO4pI9r205sbbbhHFdjh0LusdocOFy6cUWSts9WKkrrxg5n4DUWFnmLUGZEiO)cmaZ1nCTwqByScTfyJAbtgTGJJjfEAQEWlWe5)WCnKXdk8MiJRB4ADiSt5cZojVOwdbrnJrwyQpRvWfMDsMX1nCTeTHXkCK6ZAfCHzNKzCDdxlXLHt2ggRGgCeq)W0ff)rSpYMoxkik6YiVDemLn4HktWr43qYbDPdz8Gcxu8hX(iB6CPGGGJWVHKd6skPKgCeq)W0ft8WzYWkNmsE5CKOOlJ82rWu2GhQmbhHFdjh0LoKXdkCrXFe7JSPZLcccoc)gsoOlDiJhu4IjE4mzyLtgjVCosqWr43qYbDjLusdocOFy6cUWSts9WKkrrxg5TJGPSbpuzcoc)gsoOlDiJhu4II)i2hztNlfeeCe(nKCqx6qgpOWft8WzYWkNmsE5CKGGJWVHKd6shY4bfUGlm7KupmPsqWr43qYbDjLuYyCgJCyAVgMsxWzpe0FbgG56gUwlOnmwH2cSrTGjJwW5io4fyI8FyUgY4bfEtKX1nCToe2PCHzNKxuRHGOMXilm1N1k4cZojZ46gUwI2Wyfos9zTcUWStYmUUHRL4YWjBdJvqdocOFy6I65KmSs9WKkrrxg5TJGPSbpuzcoc)gsoOlDiJhu4I65KmSs9WKkbbhHFdjh0Lusjn4iG(HPlk(JyFKnDUuqu0LrE7iykBWdvMGJWVHKd6shY4bfUOEojdRupmPsqWr43qYbDPdz8Gcxu8hX(iB6CPGGGJWVHKd6skPKgCeq)W0ft8WzYWkNmsE5CKOOlJ82rWu2GhQmbhHFdjh0LoKXdkCr9CsgwPEysLGGJWVHKd6shY4bfUO4pI9r205sbbbhHFdjh0LoKXdkCXepCMmSYjJKxohji4i8Bi5GUKskPbhb0pmDbxy2jPEysLOOlJ8MX4mg5W0EnmLUGZEiO)cmaZ1nCTwqByScTfyJAbtgTaNvG(l4CKSatK)dZ1qgpOWBImUUHR1HWoLlm7K8IAnee1mgzHP(Swbxy2jzgx3W1s0ggRWrQpRvWfMDsMX1nCTexgozByScAWra9dtxu8hX(iB6CPGOOlJ82rWu2GhQmbhHFdjh0LoKXdkCrXFe7JSPZLcccoc)gsoOlPKsAWra9dtxWfMDsQhMujk6YiVbpyPo81GJa6hMUOEojdRupmPsu0LrEdEWsD4BmoJromTxdz8GcVjY46gUwhc70I)i2hztNlfmgzHP(Swbxy2jzgx3W1s0ggRam1N1k4cZojZ46gUwIldNSnmwbn4iG(HPlM4HZKHvozK8Y5irrxg5TJi4i8Bi5GUKgCeq)W0fCHzNK6HjvIIUmYBhbtzcoc)gsoOlDiJhu4IjE4mzyLtgjVCosqWr43qYbDjL0CzNf64bEAF(1qgpOWBImUUHR1HWoDIhotgw5KrYlNJmgzHP(Swbxy2jzgx3W1s0ggRam1N1k4cZojZ46gUwIldNSnmwbn4iG(HPl4cZoj1dtQefDzK3ocgbhHFdjh0L08Jru8hX(iB6CPGOOlJ82AiJhu4nrgx3W16qyNYfMDsQhMuzmYct9zTcUWStYmUUHRLOnmwbyQpRvWfMDsMX1nCTexgozByScA(K6ZAft8WzYWkNmsE5CK4PRr9zTI65KmSs9WKkXpm91qgpOWBImUUHR1HWoTEojdRupmPYyKfM6ZAfCHzNKzCDdxlrByScWuFwRGlm7KmJRB4AjUmCY2Wyf0GJa6hMUyIhotgw5KrYlNJefDzK3ocMYeCe(nKCqx6qgpOWff)rSpYMoxkii4i8Bi5GUKsAWra9dtxWfMDsQhMujk6YiVbVZf(AUSZcD8apyP(5xdz8GcVjY46gUwhc70I)i2hztNlfmgzHP(Swbxy2jzgx3W1s0ggRam1N1k4cZojZ46gUwIldNSnmwbn4iG(HPlM4HZKHvozK8Y5irrxg5TJi4i8Bi5GUKg1N1kQNtYWk1dtQep91qgpOWBImUUHR1HWoDIhotgw5KrYlNJmgzHP(Swbxy2jzgx3W1s0ggRam1N1k4cZojZ46gUwIldNSnmwbn4iG(HPl4cZoj1dtQefDzK3G35cFnQpRvupNKHvQhMujE6A(Xik(JyFKnDUuqu0LrEBnKXdk8MiJRB4ADiStRNtYWk1dtQmgzHHJa6hMUyIhotgw5KrYlNJefDzK3GN2WxdocOFy6cUWSts9WKkrrxg5n4L6WxJ6ZAfCHzNK6HjvIFy6RHmEqH3ezCDdxRdHDAXFe7JSPZLcgJSWuFwRGlm7KmJRB4AjAdJvaM6ZAfCHzNKzCDdxlXLHt2ggRGgCeq)W0fCHzNK6HjvIIUmYBWdMbpVgCeq)W0f1ZjzyL6HjvIIUmYBWdMbpVg1N1k4cZojZ46gUwI2WyfGP(Swbxy2jzgx3W1sCz4KTHXkO5Yol0Xd8GP95xdtPlWaQrl4GJu4c(Vc55livp4fe1cohXbVatK)dZ2cMybQpe0Fb4mUYP2cy7q1cEnKNVGuTWStl4mUkoNwdz8GcVjY46gUwhc7u9IAKJjzyLxK)ngzHP(Swbxy2jjoJRCs0ggRWrQpRvWfMDsIZ4kNexgozByScAuFwRGlm7KeNXvojAdJvaEWxJ6ZAfCHzNK6HjvIIUmYBkQO6ZAfCHzNK4mUYjrBySchP(Swbxy2jjoJRCsCz4KTHXkOr9zTcUWStsCgx5KOnmwb4bFnQpRvupNKHvQhMujk6YiVP5tQpRvmXdNjdRCYi5LZrIIUmYBRHmEqH3ezCDdxRdHDkxy2jPke3gJrwyQpRvOxuJCmjdR8I8V4PVgY4bfEtKX1nCToe2PCHzNKrPAmYct9zTcUWStsCgx5KOnmwHJmOg1N1k4cZoj1dtQep91qgpOWBImUUHR1HWoLlm7KmkvJrwyQpRvWfMDsIZ4kNeTHXkCKb1yGkJJa6hMUGlm7KupmPsu0LrE7iyAdFn4iG(HPlM4HZKHvozK8Y5irrxg5TJGPn81GJa6hMUO4pI9r205sbrrxg5TJGDELwdz8GcVjY46gUwhc7uUWStYlQ1qquZyKfM6ZAfCHzNK4mUYjrByScWtBnQpRvWfMDsMX1nCTeTHXkCK6ZAfCHzNKzCDdxlXLHt2ggRGX4mg5W0EnKXdk8MiJRB4ADiSt5cZojVOwdbrnJrwy4iG(HPl4cZojJsvu0LrE7OZvJ6ZAfCHzNKzCDdxlrBySchP(Swbxy2jzgx3W1sCz4KTHXkymoJromTxdz8GcVjY46gUwhc7uUWStsvUkoNmgzH9j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwbyN7AiJhu4nrgx3W16qyNYfMDsQcXTXyKf2pgrXFe7JSPZLcIIUmYBA(K6ZAft8WzYWkNmsE5CKOOlJ8g8i4i8Bi5GUKgL)K6ZAff)rSpYMoxkit)GCQyveeA0s0ggRam4ROIFs9zTII)i2hztNlfKPFqovSkccnAjAdJv4OZvP1qgpOWBImUUHR1HWoLlm7KmkvJrwy)yef)rSpYMoxkik6YiVbVZR5tQpRvu8hX(iB6CPGm9dYPIvrqOrlrByScWGVg1N1kQNtYWk1dtQe)W0xdz8GcVjY46gUwhc7uUWStsviUngJSW(Xik(JyFKnDUuqu0LrEdEeCe(nKCqxsZNuFwRO4pI9r205sbz6hKtfRIGqJwI2WyfGh818j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwHJoxnQpRvupNKHvQhMuj(HPVgY4bfEtKX1nCToe2PCHzNKQCvCozmYct9zTcUWStsCgx5KOnmwbyQpRvWfMDsIZ4kNexgozByScAuFwRGlm7KmJRB4AjAdJvaM6ZAfCHzNKzCDdxlXLHt2ggRWAiJhu4nrgx3W16qyNsPdmpOWngzHDzNf645iTp)AykDbhKzKVavAmjYxaocOFy6lWe5)WSz8cmPfeoKwlq9HG(lyIfyFqqlaNXvo1waBhQwWRH88fKQfMDAbPGk11qgpOWBImUUHR1HWoLlm7KufIBJXilm1N1k4cZojXzCLtI2WyfGN2RHP0fyaCV0hXdbP1cA6K)xGbyUUHR1cAdJvOTaZmYxGknMe5lahb0pm9fyI8Fy2wdz8GcVjY46gUwhc7uUWStsvUkoNmgzHP(Swbxy2jzgx3W1s0ggRa8G)AiJhu4nrgx3W16qyNYfMDsErTgcIAgJZyKdt71W1qgpOWBIBKMUKphc7uviKRGKDTmgzHDJ00L8r8rTHDmbpyAd)1qgpOWBIBKMUKphc7u9IAKJjzyLxK)xdz8GcVjUrA6s(CiSt5cZojVOwdbrnJrwy3inDjFeFuByhthPn8xdz8GcVjUrA6s(CiSt5cZojJsDnKXdk8M4gPPl5ZHWo1IksQcXTznCnKXdk8Mi0jNkywursviUngJSWQNt2OYjXh1WiDiKZLwsCCVS)1O(SwXh1WiDiKZLwsCCVS)L2kAJ4PVgY4bfEte6Kt1HWo1wrBKEKMngzHvpNSrLtI8c1G0sIWimeP5Yol0Xd8sjNFnKXdk8Mi0jNQdHD6N4jtnkNwdz8GcVjcDYP6qyNw8hX(iB6CPGXilSl7SqhpW7CH)AiJhu4nrOtovhc70wgYoipxQhMuzmYct9zTcUWSts9WKkXpmDn4iG(HPl4cZoj1dtQefDzK3wdz8GcVjcDYP6qyNErvfvtgw5e1L8znKXdk8Mi0jNQdHD6epCMmSYjJKxohTgY4bfEte6Kt1HWoLlm7KupmPAnKXdk8Mi0jNQdHDA9CsgwPEysLXilm1N1kQNtYWk1dtQe)W0xdtPlWaQrl4GJu4cMybTd6JOdcAbSVacUP4fKQfMDAbNbXTzb)xH88fmz0cooMu4PP6bVatK)dZf8CiQ1wq9Ch55livlm70cmGXzHybga2fKQfMDAbgW4SybO2cggI8H(gVatAby2nAwWRrl4GJu4cmrtgYxWKrl44ysHNMQh8cmr(pmxWZHOwBbM0cq(qv90Nfmz0cs1u4cWzS7eKXlOflWKmccAbnonTa0iwdz8GcVjcDYP6qyNQxuJCmjdR8I8VXilmdCyiYhbxy2jjHZcnFs9zTIjE4mzyLtgjVCos8018j1N1kM4HZKHvozK8Y5irrxg5TJGPmJhu4cUWStsviUnccoc)gsoOlLcO(SwHErnYXKmSYlY)IldNSnmwbLwdtPlWaWUGdosHliJBUrZcujYxWRr)f8FfYZxWKrl44ysHlWe5)W04fysgbbTGxJwaAwWelODqFeDqqlG9fqWnfVGuTWStl4miUnla5lyYOfCoId(0u9GxGjY)HPynKXdk8Mi0jNQdHDQErnYXKmSYlY)gJSWuFwRGlm7KupmPs801O(Swr9CsgwPEysLOOlJ82rWuMXdkCbxy2jPke3gbbhHFdjh0LsbuFwRqVOg5ysgw5f5FXLHt2ggRGsmEqH3eHo5uDiSt5cZojvH42ymYc7hJO4pI9r205sbrrxg5n4DEfv8tQpRvu8hX(iB6CPGm9dYPIvrqOrlrByScWd(RHmEqH3eHo5uDiSt5cZojvH42ymYct9zTc9IAKJjzyLxK)fpDnFs9zTIjE4mzyLtgjVCos8018j1N1kM4HZKHvozK8Y5irrxg5TJGX4bfUGlm7KufIBJGGJWVHKd6sRHP0fKQqMSwTfCgxfNtlGNfmz0ci)VGWUGu9GxGzg5lOEUJ88fmz0cs1cZoTadWCDdxRfar5K)5sR1qgpOWBIqNCQoe2PCHzNKQCvCozmYct9zTcUWSts9WKkXtxJ6ZAfCHzNK6HjvIIUmYBhLJ)AQNt2OYjbxy2jjYTihnATgMsxqQczYA1wWzCvCoTaEwWKrlG8)cc7cMmAbNJ4GxGjY)H5cmZiFb1ZDKNVGjJwqQwy2PfyaMRB4ATaikN8pxATgY4bfEte6Kt1HWoLlm7KuLRIZjJrwyQpRvupNKHvQhMujE6AuFwRGlm7KupmPs8dtxJ6ZAf1ZjzyL6HjvIIUmYBhblh)1upNSrLtcUWStsKBroA0AnKXdk8Mi0jNQdHDkxy2j5f1AiiQzmYc7tQpRvmXdNjdRCYi5LZrINUMHHiFeCHzNKeol0OS6ZAfFINm1OCs8dtxrfz8GstsYPlIAW0wjnFs9zTIjE4mzyLtgjVCosu0LrEdEmEqHl4cZojVOwdbrnbbhHFdjh0LmgNXihM2gtCbPLeNXixISWuFwRadrCH52G8CjoJDNGe)W01OS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91OS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)APKskTgY4bfEte6Kt1HWoLlm7K8IAnee1mgzHP(SwbgI4cZTb55IIy8ymoJromTxdz8GcVjcDYP6qyNYfMDsgLQXilm1N1k4cZojXzCLtI2WyfocwAUqSkejMyUYldNeNXvo1wdz8GcVjcDYP6qyNYfMDsQcXTXyKfM6ZAf1ZjzyL6HjvINUIkEzNf64bEAF(1qgpOWBIqNCQoe2Pu6aZdkCJrwyQpRvupNKHvQhMuj(HPRr9zTcUWSts9WKkXpmDJr(qv90hjYc7Yol0Xd8GLApVXiFOQE6JeDV0hXdbt71qgpOWBIqNCQoe2PCHzNKQCvCoTgUgMsxaJhu4nrfdpOWpe2Py2XeKKXdkCJrwymEqHlO0bMhu4cCg7obH8Cnx2zHoEGhSuY51OSbwpNSrLtIgsplCzBI6QOIQpRv0q6zHlBtuxrByScWuFwROH0Zcx2MOUIldNSnmwbLwdz8GcVjQy4bf(HWoLshyEqHBmYc7Yol0XZrWsZfIvHibLoK64rJY4iG(HPlM4HZKHvozK8Y5irrxg5TJGX4bfUGshyEqHli4i8Bi5GUKIkIJa6hMUGlm7KupmPsu0LrE7iymEqHlO0bMhu4ccoc)gsoOlPOIkpme5JOEojdRupmPsdocOFy6I65KmSs9WKkrrxg5TJGX4bfUGshyEqHli4i8Bi5GUKskPr9zTI65KmSs9WKkXpmDnQpRvWfMDsQhMuj(HPR5tQpRvmXdNjdRCYi5LZrIFy6Amq9IslZXFH2IjE4mzyLtgjVCoAnKXdk8MOIHhu4hc7ukDG5bfUXilS65KnQCs0q6zHlBtuxn4iG(HPl4cZoj1dtQefDzK3ocgJhu4ckDG5bfUGGJWVHKd6sRHP0fCgxfNtlazxaAmQTGbDPfmXcEnAbtm3fW(FbM0cY400cMiwWLDTwaoJRCQTgY4bfEtuXWdk8dHDkxy2jPkxfNtgJSWWra9dtxmXdNjdRCYi5LZrII4VwAuw9zTcUWStsCgx5KOnmwb4LMleRcrIjMR8YWjXzCLtnn4iG(HPl4cZoj1dtQefDzK3ocgbhHFdjh0L0CzNf64bEP5cXQqKG1LxKJUVR8Yol1XJg1N1kQNtYWk1dtQe)W0vAnKXdk8MOIHhu4hc7uUWStsvUkoNmgzHHJa6hMUyIhotgw5KrYlNJefXFT0OS6ZAfCHzNK4mUYjrByScWlnxiwfIetmx5LHtIZ4kNAAggI8rupNKHvQhMuPbhb0pmDr9CsgwPEysLOOlJ82rWi4i8Bi5GUKgCeq)W0fCHzNK6HjvIIUmYBWlnxiwfIetmx5LHt(jiwlPnkjRR0AiJhu4nrfdpOWpe2PCHzNKQCvCozmYcdhb0pmDXepCMmSYjJKxohjkI)APrz1N1k4cZojXzCLtI2WyfGxAUqSkejMyUYldNeNXvo10OSbome5JOEojdRupmPsrfXra9dtxupNKHvQhMujk6YiVbV0CHyvismXCLxgo5NGyTK2OKvORKgCeq)W0fCHzNK6HjvIIUmYBWlnxiwfIetmx5LHt(jiwlPnkjRR0AiJhu4nrfdpOWpe2PCHzNKQCvCozmYc7tQpRvu8hX(iB6CPGm9dYPIvrqOrlrByScW(K6ZAff)rSpYMoxkit)GCQyveeA0sCz4KTHXkOrz1N1k4cZoj1dtQe)W0vur1N1k4cZoj1dtQefDzK3ocwo(RKgLvFwROEojdRupmPs8dtxrfvFwROEojdRupmPsu0LrE7iy54VsRHmEqH3evm8Gc)qyNYfMDsQcXTXyKf2pgrXFe7JSPZLcIIUmYBWl1QOIk)j1N1kk(JyFKnDUuqM(b5uXQii0OLOnmwb4bFnFs9zTII)i2hztNlfKPFqovSkccnAjAdJv4OpP(SwrXFe7JSPZLcY0piNkwfbHgTexgozBySckTgY4bfEtuXWdk8dHDkxy2jPke3gJrwyQpRvOxuJCmjdR8I8V4PR5tQpRvmXdNjdRCYi5LZrINUMpP(SwXepCMmSYjJKxohjk6YiVDemgpOWfCHzNKQqCBeeCe(nKCqxAnKXdk8MOIHhu4hc7uUWStYlQ1qquZyKf2NuFwRyIhotgw5KrYlNJepDnddr(i4cZojjCwOrz1N1k(epzQr5K4hMUIkY4bLMKKtxe1GPTsAu(tQpRvmXdNjdRCYi5LZrIIUmYBWJXdkCbxy2j5f1AiiQji4i8Bi5GUKIkIJa6hMUqVOg5ysgw5f5Frrxg5nfvehPjN9rOGwfIDLmgNXihM2gtCbPLeNXixISWuFwRadrCH52G8CjoJDNGe)W01OS6ZAfCHzNK6HjvINUIkQSbome5JistLEysf91OS6ZAf1ZjzyL6HjvINUIkIJa6hMUGshyEqHlkI)APKskTgY4bfEtuXWdk8dHDkxy2j5f1AiiQzmYct9zTcmeXfMBdYZffX4rJ6ZAfeC6S)PVupgYhedjE6RHmEqH3evm8Gc)qyNYfMDsErTgcIAgJSWuFwRadrCH52G8CrrmE0OS6ZAfCHzNK6HjvINUIkQ(Swr9CsgwPEysL4PROIFs9zTIjE4mzyLtgjVCosu0LrEdEmEqHl4cZojVOwdbrnbbhHFdjh0LuYyCgJCyAVgY4bfEtuXWdk8dHDkxy2j5f1AiiQzmYct9zTcmeXfMBdYZffX4rJ6ZAfyiIlm3gKNlAdJvaM6ZAfyiIlm3gKNlUmCY2WyfmgNXihM2RHmEqH3evm8Gc)qyNYfMDsErTgcIAgJSWuFwRadrCH52G8CrrmE0O(SwbgI4cZTb55IIUmYBhbtzLvFwRadrCH52G8CrByScPamEqHl4cZojVOwdbrnbbhHFdjh0Lu6WC8xjJXzmYHP9AiJhu4nrfdpOWpe2Ponzujh6QtTXyKfMYfzlQLXQqKIkAGdcRaYZvsJ6ZAfCHzNK4mUYjrByScWuFwRGlm7KeNXvojUmCY2Wyf0O(Swbxy2jPEysL4hMUMpP(SwXepCMmSYjJKxohj(HPVgY4bfEtuXWdk8dHDkxy2jzuQgJSWuFwRGlm7KeNXvojAdJv4iyP5cXQqKyI5kVmCsCgx5uBnKXdk8MOIHhu4hc702tNkpsZgJSWUSZcD8CeSuY51O(Swbxy2jPEysL4hMUg1N1kQNtYWk1dtQe)W018j1N1kM4HZKHvozK8Y5iXpm91qgpOWBIkgEqHFiSt5cZojvH42ymYct9zTI6brYWkNSIOM4PRr9zTcUWStsCgx5KOnmwb4L6RHmEqH3evm8Gc)qyNYfMDsQYvX5KXilSl7SqhphblnxiwfIeQCvCojVSZsD8Or9zTcUWSts9WKkXpmDnQpRvupNKHvQhMuj(HPR5tQpRvmXdNjdRCYi5LZrIFy6AuFwRGlm7KeNXvojAdJvaM6ZAfCHzNK4mUYjXLHt2ggRGgCeq)W0fu6aZdkCrrxg5T1qgpOWBIkgEqHFiSt5cZojv5Q4CYyKfM6ZAfCHzNK6HjvIFy6AuFwROEojdRupmPs8dtxZNuFwRyIhotgw5KrYlNJe)W01O(Swbxy2jjoJRCs0ggRam1N1k4cZojXzCLtIldNSnmwbnddr(i4cZojJsvdocOFy6cUWStYOuffDzK3ocwo(R5Yol0XZrWsjWxdocOFy6ckDG5bfUOOlJ82AiJhu4nrfdpOWpe2PCHzNKQCvCozmYct9zTcUWSts9WKkXtxJ6ZAfCHzNK6HjvIIUmYBhblh)1O(Swbxy2jjoJRCs0ggRam1N1k4cZojXzCLtIldNSnmwbnkJJa6hMUGshyEqHlk6YiVPOI1ZjBu5KGlm7Ke5wKJgTuAnKXdk8MOIHhu4hc7uUWStsvUkoNmgzHP(Swr9CsgwPEysL4PRr9zTcUWSts9WKkXpmDnQpRvupNKHvQhMujk6YiVDeSC8xJ6ZAfCHzNK4mUYjrByScWuFwRGlm7KeNXvojUmCY2Wyf0OmocOFy6ckDG5bfUOOlJ8MIkwpNSrLtcUWStsKBroA0sP1qgpOWBIkgEqHFiSt5cZojv5Q4CYyKfM6ZAfCHzNK6HjvIFy6AuFwROEojdRupmPs8dtxZNuFwRyIhotgw5KrYlNJepDnFs9zTIjE4mzyLtgjVCosu0LrE7iy54Vg1N1k4cZojXzCLtI2WyfGP(Swbxy2jjoJRCsCz4KTHXkSgY4bfEtuXWdk8dHDkxy2jPkxfNtgJSWgUYPrKrm0Kj0XZrP(51O(Swbxy2jjoJRCs0ggRa8GPmJhuAssoDrulfS2kPPEozJkNeCHzNKQXvLR)L8rdJhuAssoDrudEARr9zTIpXtMAuoj(HPVgY4bfEtuXWdk8dHDkxy2jjbNou0qHBmYcB4kNgrgXqtMqhphL6NxJ6ZAfCHzNK4mUYjrBySchP(Swbxy2jjoJRCsCz4KTHXkOPEozJkNeCHzNKQXvLR)L8rdJhuAssoDrudEARr9zTIpXtMAuoj(HPVgY4bfEtuXWdk8dHDkxy2jPke3M1qgpOWBIkgEqHFiStP0bMhu4gJSWuFwROEojdRupmPs8dtxJ6ZAfCHzNK6HjvIFy6A(K6ZAft8WzYWkNmsE5CK4hM(AiJhu4nrfdpOWpe2PCHzNKQCvCo1N(07]] )


end
