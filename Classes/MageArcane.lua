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


    spec:RegisterPack( "Arcane", 20210403, [[d0u)GgqikeEKOsLlPIuQAtKIprbnkkWPiLAvIkv9krfZII4wIQIAxe(fjWWiHCmsulJIupJekttuv11urY2urQ8nrvHXrHuDosOQ1rrI5jQY9aQ9rc6GIkLfcK6Hui5IQifFufPugjju5KQivTskuVKIKAMui6MuKKDcK8tkKsdvuvzPIQs9uk1uvrCvkKIVkQkYyfvYELQ)s0GbDyulMKEmutwvUmYMf5ZQWOfLtdz1QiLkVgiMnGBRs7MQFlmCs1XfvLSCjpxktxX1vvBNI67uY4vrDEsjRxfPK5tISFLURC)KU9JhQdktRitRSIYFfPycLvwXu8kN)D7rlDQBRZyq4dQB78L625wHzN626Swab)6N0TBXVWu3oBg9MPOafCGMSVQahxf0q3papOWXfNgf0qxSc62QFeWC69UA3(Xd1bLPvKPvwr5VIumHYkRykEfLp62nDc3b1PZ0D7m07rExTB)OgUBBQ4dAH5wHzNwJZn9cbSqtBYcnTImTYRXRX5B6gMPfAMleRcqc(kB68DHiFHj2CulmslSrZG8JMGVYMoFxOb4mcdYc1k(1cB6eEHH(GcVPTyn2OPrlC0shHzGfAJUg1cZy)bG8JfgPfIZy3jGfI8HQ6RpOWxiYBdXVfgPfAiMDmbiz8Gc3qr3ga1Mw)KUDgx3W1QFshuk3pPBtoRcqVoO72mEqH3TjZbMhu4D7h1WfsFqH3TnAA0cpnMdmpOWxikTqlYWIwiqyTWWx4LDEHS)wiVWtIXuPGCl)wOfYFH1crTfIJlYpw4xVBJl0qfI72x2zHoEwyEGxOYNAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHgSq6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAHAVqnlehbWlSCbxy2jPEyrLOOlJ82cZd8cnyH0zc)hsoOlTWCwiJhu4Ij(4mzKKtgjV8bsqNj8Fi5GU0cZzHmEqHl4cZoj1dlQe0zc)hsoOlTqTxOMfQ(tjr9DsgjPEyrL4fw(c1Sq1Fkj4cZoj1dlQeVWYxOMf(i1FkjM4JZKrsozK8YhiXlS8fQzHgXcFXik(HyFKnDUaru0LrERpDqz6(jDBYzva61bD3MXdk8UnzoW8GcVB)OgUq6dk8UTrtJw4PXCG5bf(crPfArgw0cbcRfg(cVSZlK93c5fMVJ8BHwi)fwle1wioUi)yHF9UnUqdviUBFzNf64zH5bEHkMIwOMfIJa4fwUO(ojJKupSOsu0LrEBH5bEHgSq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfQ9c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnyH0zc)hsoOlTWCwiJhu4I67Kmss9WIkbDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6slu7fQzH4iaEHLl4cZoj1dlQefDzK3wOcxy(RO(0bLI1pPBtoRcqVoO724cnuH4UnocGxy5IIFi2hztNlqefDzK3wyEGxOPxyUFHh43cZzHM5cXQaKWuR4K6f1ggdcYpKd6slmNfsNj8Fi5GU0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnZfIvbiHPwXj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQzH4iaEHLl4cZoj1dlQefDzK3wyEGxOzUqSkajm1koPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4IIFi2hztNlqe0zc)hsoOlTWCwiJhu4Ij(4mzKKtgjV8bsqNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYluZcv)PKGlm7KeNX1bjAdJbzH5TW8FHAwOrSqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8Unxy2jPka3M(0bv(3pPBtoRcqVoO724cnuH4UnocGxy5I67Kmss9WIkrrxg5TfMh4fA6fM7x4b(TWCwOzUqSkajm1koPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4I67Kmss9WIkbDMW)HKd6sluZcXra8clxu8dX(iB6CbIOOlJ82cZd8cnZfIvbiHPwXj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHM5cXQaKWuR4K6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlQVtYij1dlQe0zc)hsoOlTWCwiJhu4IIFi2hztNlqe0zc)hsoOlTqnlehbWlSCbxy2jPEyrLOOlJ82c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYluZcv)PKGlm7KeNX1bjAdJbzH5TW8FHAwOrSqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8Unxy2jPka3M(0b1P6N0TjNvbOxh0DBCHgQqC3ghbWlSCrXpe7JSPZfiIIUmYBlmpWl00lm3VWd8BH5SqZCHyvasyQvCs9IAdJbb5hYbDPfQzH4iaEHLl4cZoj1dlQefDzK3wOcbVqftrluZcXra8clxmXhNjJKCYi5LpqIIUmYBlmNfQykAH5bEH4iaEHLl4cZoj1dlQefDzK3wOMfIJa4fwUO(ojJKupSOsu0LrEBH5SqftrlmpWlehbWlSCbxy2jPEyrLOOlJ82c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYluZcv)PKGlm7KeNX1bjAdJbzH5TW8FHAwOrSqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8Unxy2jPka3M(0b1PRFs3MCwfGEDq3TXfAOcXDBCeaVWYff)qSpYMoxGik6YiVTW8aVWd8BH5SqZCHyvasyQvCs9IAdJbb5hYbDPfMZcPZe(pKCqxAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHM5cXQaKWuR4K6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWl0mxiwfGeMAfNuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCrXpe7JSPZfic6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxAHAwO6pLeCHzNK4mUoirBymiluHlu5UnJhu4DBUWStsvUk(G6thu5J(jDBYzva61bD3gxOHke3TXra8clxuFNKrsQhwujk6YiVTW8aVWd8BH5SqZCHyvasyQvCs9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWf13jzKK6Hfvc6mH)djh0LwOMfIJa4fwUO4hI9r205cerrxg5TfMh4fAMleRcqctTItQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnZfIvbiHPwXj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfQzHQ)usWfMDsIZ46GeTHXGSqfUqL72mEqH3T5cZojv5Q4dQpDqz07N0TjNvbOxh0DBCHgQqC3ghbWlSCrXpe7JSPZfiIIUmYBlmpWl8a)wyol0mxiwfGeMAfNuVO2Wyqq(HCqxAHAwiocGxy5cUWSts9WIkrrxg5TfQqWluXu0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZzHkMIwyEGxiocGxy5cUWSts9WIkrrxg5TfQzH4iaEHLlQVtYij1dlQefDzK3wyoluXu0cZd8cXra8clxWfMDsQhwujk6YiVTqnlu9NscUWStsCgxhKOnmgKfQWfQ8c1SqJyH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4DBUWStsvUk(G6thuk((jDBYzva61bD3(rnCH0hu4DBq)raVfQ446gUwlSnmgK2ctrTWjJw4jXyQuqULFl0c5VWQBJl0qfI72Q)usWfMDsMX1nCTeTHXGSW8wO6pLeCHzNKzCDdxlXLplBdJbzHAwiocGxy5IIFi2hztNlqefDzK3wyEGxOzUqSkajm1koPErTHXGG8d5GU0cZzH0zc)hsoOlTqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqZCHyvasyQvCs9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfMh4fAMleRcqctTItQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6slmNfY4bfUyIpotgj5KrYlFGe0zc)hsoOl1TXzmY72k3Tz8GcVBZfMDsErTgcGA9PdkLvu)KUn5Ska96GUB)OgUq6dk8UnO)iG3cvCCDdxRf2ggdsBHPOw4KrlmFh53cTq(lS624cnuH4UT6pLeCHzNKzCDdxlrBymilmVfQ(tjbxy2jzgx3W1sC5ZY2WyqwOMfIJa4fwUO(ojJKupSOsu0LrEBH5bEHM5cXQaKWuR4K6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlQVtYij1dlQe0zc)hsoOlTqnlehbWlSCrXpe7JSPZfiIIUmYBlmpWl0mxiwfGeMAfNuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMh4fAMleRcqctTItQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBDBCgJ8UTYDBgpOW72CHzNKxuRHaOwF6GszL7N0TjNvbOxh0D7h1WfsFqH3Tb9hb8wOIJRB4ATW2WyqAlmf1cNmAHodc9wy(2EHwi)fwDBCHgQqC3w9NscUWStYmUUHRLOnmgKfM3cv)PKGlm7KmJRB4AjU8zzBymiluZcXra8clxu8dX(iB6CbIOOlJ82cZd8cnZfIvbiHPwXj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQzH4iaEHLl4cZoj1dlQefDzK3wOcbVqftrluZcXra8clxuFNKrsQhwujk6YiVTqfcEHkMIwOMfAeleh(7Jgbxy2jPEfp0HwcYzva61TXzmY72k3Tz8GcVBZfMDsErTgcGA9PdkLnD)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wOPxOMfQ(tjbxy2jzgx3W1s0ggdYcbVq1Fkj4cZojZ46gUwIlFw2ggdYc1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZBH0zc)hsoOlTqnlehbWlSCbxy2jPEyrLOOlJ82cZd8cnyH0zc)hsoOlTWCwiJhu4Ij(4mzKKtgjV8bsqNj8Fi5GU0c1EHAw4LDwOJNfQWfQ8P62mEqH3Tl(HyFKnDUaPpDqPSI1pPBtoRcqVoO724cnuH4UT6pLeCHzNK4mUoirBymilmVfA6fQzHQ)usWfMDsMX1nCTeTHXGSqWlu9NscUWStYmUUHRL4YNLTHXGSqnlehbWlSCbxy2jPEyrLOOlJ82cZd8cPZe(pKCqxAHAw4lgrXpe7JSPZfiIIUmYBDBgpOW72t8XzYijNmsE5duF6Gs58VFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojZ46gUwI2Wyqwi4fQ(tjbxy2jzgx3W1sC5ZY2WyqwOMf(i1FkjM4JZKrsozK8YhiXxFHAwO6pLe13jzKK6HfvIxy5DBgpOW72CHzNK6Hfv9PdkLpv)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wOPxOMfQ(tjbxy2jzgx3W1s0ggdYcbVq1Fkj4cZojZ46gUwIlFw2ggdYc1SqCeaVWYff)qSpYMoxGik6YiVTW8aVq6mH)djh0LwOMfIJa4fwUyIpotgj5KrYlFGefDzK3wyEGxOblKot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQ9c1SqCeaVWYfCHzNK6HfvIIUmYBluHlm)p1cZzHM5cXQaKWuR4KpcG1caDrJm3YVfQzHx2zHoEwOcbVqf7uDBgpOW7213jzKK6Hfv9PdkLpD9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHMEHAwO6pLeCHzNKzCDdxlrBymile8cv)PKGlm7KmJRB4AjU8zzBymiluZcXra8clxmXhNjJKCYi5LpqIIUmYBlmVfsNj8Fi5GU0c1Sq1FkjQVtYij1dlQeF9UnJhu4D7IFi2hztNlq6thukNp6N0TjNvbOxh0DBCHgQqC3w9NscUWStYmUUHRLOnmgKfcEHQ)usWfMDsMX1nCTex(SSnmgKfQzHQ)usuFNKrsQhwuj(6luZcFXik(HyFKnDUaru0LrERBZ4bfE3EIpotgj5KrYlFG6thukB07N0TjNvbOxh0DBCHgQqC32GfIJa4fwUyIpotgj5KrYlFGefDzK3wyolm)p1c1EH5bEH4iaEHLl4cZoj1dlQefDzK3wOMfQ(tjbxy2jPEyrL4fw(c1SqJyH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4D767Kmss9WIQ(0bLYk((jDBYzva61bD3gxOHke3Tv)PKGlm7KmJRB4AjAdJbzHGxO6pLeCHzNKzCDdxlXLplBdJbzHAwiocGxy5cUWSts9WIkrrxg5TfQqWluXu0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZzHkMIwyEGxiocGxy5cUWSts9WIkrrxg5TfQzH4iaEHLlQVtYij1dlQefDzK3wyoluXu0cZd8cXra8clxWfMDsQhwujk6YiVTqnl8Yol0XZcvi4fQ8PwOMfAeleh(7Jgbxy2jPEfp0HwcYzva61Tz8GcVBx8dX(iB6CbsF6GY0kQFs3MCwfGEDq3TXfAOcXD7xmIIFi2hztNlqefDzK3wOcx4PwOMf(i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfcEHkAHAwO6pLe13jzKK6HfvIxy5DBgpOW72CHzNKrP2NoOmTY9t62KZQa0Rd6UnUqdviUB)i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfcEH5F3MXdk8Unxy2jPkxfFq9PdktB6(jDBYzva61bD3gxOHke3TFXik(HyFKnDUaru0LrEBHAw4Ju)PKyIpotgj5KrYlFGefDzK3wOcxiDMW)HKd6sluZcnyHps9NsIIFi2hztNlqKM)aovSkcanAjAdJbzHGxOIwOskTWhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSW8wy(VqT72mEqH3T5cZojvb420NoOmTI1pPBtoRcqVoO724cnuH4U9lgrXpe7JSPZfiIIUmYBluHlKot4)qYbDPfQzHps9NsIIFi2hztNlqKM)aovSkcanAjAdJbzHkCHkAHAw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwyElm)xOMfQ(tjr9DsgjPEyrL4fwE3MXdk8Unxy2jPka3M(0bLPZ)(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5TqtVqnlu9NscUWSts9WIkXxVBZ4bfE3Mlm7Kmk1(0bLPpv)KUn5Ska96GUBZ4bfE3Mlm7K8IAnea1624mg5DBL724cnuH4UT6pLeyaIlm3gKFikIXZc1Sq1Fkj4cZoj1dlQeF9(0bLPpD9t62KZQa0Rd6UnJhu4DB9IAKJjzKKxK)62pQHlK(GcVBB00OfMFHPAHVFH8JfMB53cJAH57i)wOfYFHvBHtSq1pc4TqCgxhuBHCAOAH)gYpwyUvy2PfcAUk(G624cnuH4UT6pLeCHzNK4mUoirBymilmVfQ(tjbxy2jjoJRdsC5ZY2WyqwOMfQ(tjbxy2jjoJRds0ggdYcv4cv0c1Sq1Fkj4cZoj1dlQefDzK3wOskTq1Fkj4cZojXzCDqI2WyqwyElu9NscUWStsCgxhK4YNLTHXGSqnlu9NscUWStsCgxhKOnmgKfQWfQOfQzHQ)usuFNKrsQhwujk6YiVTqnl8rQ)usmXhNjJKCYi5LpqIIUmYB9PdktNp6N0TjNvbOxh0DBCHgQqC3w9Nsc9IAKJjzKKxK)eF9fQzHQ)usWfMDsIZ46GeTHXGSqfUqL72mEqH3T5cZojvb420NoOmTrVFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEl00luZcXra8clxWfMDsQhwujk6YiVTqfcEHMwrlmFEHg9fM7x4b(Tqnl0iwOblehbWlSCrXpe7JSPZfiIIUmYBlmpWluzfTqnlehbWlSCbxy2jPEyrLOOlJ82cvi4fMpo1c1UBZ4bfE3Mlm7Kmk1(0bLPv89t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHMEHAwiocGxy5cUWSts9WIkrrxg5TfQqWl00kAH5Zl0OVWC)cpWVfQzH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4DBUWStYOu7thukMI6N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3gNXiVBRC3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHkCHkVqnlu9NscUWStYmUUHRLOnmgKfM3cv)PKGlm7KmJRB4AjU8zzBymi9Pdkft5(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDBCeaVWYfCHzNKrPkk6YiVTW8wy(Vqnlu9NscUWStYmUUHRLOnmgKfM3cv)PKGlm7KmJRB4AjU8zzBymi9PdkfZ09t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1Sq1Fkj4cZojZ46gUwI2Wyqwi4fQ(tjbxy2jzgx3W1sC5ZY2Wyq62mEqH3T5cZojv5Q4dQpDqPykw)KUn5Ska96GUBJl0qfI72x2zHoEwyElu5t1Tz8GcVBtMdmpOW7thukw(3pPBtoRcqVoO72mEqH3T5cZojvb420TFudxi9bfE3oFkJ8fQsJfr(cXra8clFHwi)fwntwOfTWWb0AHQFeWBHtSW0hayH4mUoO2c50q1c)nKFSWCRWStl0OTu724cnuH4UT6pLeCHzNK4mUoirBymiluHlu5(0bLIDQ(jDBYzva61bD3gNXiVBRC3MXdk8Unxy2j5f1AiaQ1N(0TtOwgYpKHo5u1pPdkL7N0TjNvbOxh0DBgpOW72K5aZdk8U9JA4cPpOW725tzKVW67oYpwiHMmQw4Krl02EHrTWtYNwiaDq(Jle1mzHw0cTyFw4el80yowOkLIIw4Krl8Kymvki3YVfAH8xyjwOrtJwiAwi3wylcFHCBH57i)wyg3wyc5Owg9wy8RfArgAMwytN8zHXVwioJRdQ1TXfAOcXDBdwy9Dkf1bjAi9SWLTjQRGCwfGElujLwy9Dkf1bjg6QhfdiT4sxqoRcqVfQ9c1SqdwO6pLe13jzKK6HfvIxy5lujLwOErMLh4Nqzbxy2jPkxfFqlu7fQzH4iaEHLlQVtYij1dlQefDzK36thuMUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBF6tl0Im0mTWeYrTm6TW4xlehbWlS8fAH8xy1wi7Vf20jFwy8RfIZ46GAMSq9cffAqNw0cpnMJfgMPAHKzQ0AYq(XcjGg1TXfAOcXD7HbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82c1SqCeaVWYfCHzNK6HfvIIUmYBluZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIxy5luZc1lYS8a)ekl4cZojv5Q4dQpDqPy9t62KZQa0Rd6UnUqdviUBxFNsrDqIhQHr6aiNlTK44Ez)jiNvbO3c1Sq1FkjEOggPdGCU0sIJ7L9NmvrBeF9UnJhu4D7eQiPka3M(0bv(3pPBtoRcqVoO724cnuH4UD9Dkf1bjokudqljcJWaKGCwfGEluZcVSZcD8SqfUqf)P62mEqH3Ttv0gPhM5(0b1P6N0TjNvbOxh0DBCHgQqC32iwy9Dkf1bjAi9SWLTjQRGCwfGEluZcnIfwFNsrDqIHU6rXaslU0fKZQa0RBZ4bfE3(r8KPgLt9PdQtx)KUn5Ska96GUBJl0qfI724iaEHLlQVtYij1dlQefXpT62mEqH3T5cZojJsTpDqLp6N0TjNvbOxh0DBCHgQqC3ghbWlSCr9DsgjPEyrLOi(P1c1Sq1Fkj4cZojXzCDqI2WyqwyElu9NscUWStsCgxhK4YNLTHXG0Tz8GcVBZfMDsQcWTPpDqz07N0Tz8GcVBxFNKrsQhwu1TjNvbOxh09PdkfF)KUn5Ska96GUBZ4bfE3Mlm7K8IAnea162pQHlK(GcVBF6tl0ImSOfYZcV85f2ggdsBHrAHgLrTq2Fl0IwygBMCdNf(B0BHMQ4KfQfnMSWFJwiVW2Wyqw4eluViZKpl8(DCgYp624cnuH4UT6pLeyaIlm3gKFikIXZc1Sq1FkjWaexyUni)q0ggdYcbVq1FkjWaexyUni)qC5ZY2WyqwOMfIdZKZ(imt(KPvTqnlehbWlSCXfvvunzKKtuxYhrr8tR(0bLYkQFs3MCwfGEDq3TXfAOcXDBJyHgSW67ukQds0q6zHlBtuxb5Ska9wOskTW67ukQdsm0vpkgqAXLUGCwfGElu7U9JA4cPpOW72GkQldaO1cTOfQZOAH6XGcFH)gTql0KTWCl)mzHQ)zHOzHwiaGfcWTzHaHFSqYJ)r2ctrTq1yYw4KrlmFh53cz)TWCl)wOfYFHvBHFhGATfwF3r(XcNmAH22lmQfEs(0cbOdYFCHOw3MXdk8UTEmOW7thukRC)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqLuAH6fzwEGFcLfCHzNKQCv8b1Tz8GcVB)iEYuJYP(0bLYMUFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOskTq9ImlpWpHYcUWStsvUk(G62mEqH3Tl(HyFKnDUaPpDqPSI1pPBtoRcqVoO724cnuH4UT6pLe13jzKK6HfvIxy5lujLwOErMLh4Nqzbxy2jPkxfFqDBgpOW72xuvr1KrsorDjF6thukN)9t62KZQa0Rd6UnUqdviUBRxKz5b(juwmXhNjJKCYi5LpqDBgpOW72CHzNK6Hfv9PdkLpv)KUn5Ska96GUBZ4bfE3wVOg5ysgj5f5VU9JA4cPpOW72gnnAH5xyQw4elSLV(eDArlK9fsNNIxyUvy2PfcAaUnl89lKFSWjJw4jXyQuqULFl0c5VWAHFhGATfwF3r(XcZTcZoTWtdolel80NwyUvy2PfEAWzXcrTfoma5d9mzHw0cXSB4SWFJwy(fMQfAHMmKVWjJw4jXyQuqULFl0c5VWAHFhGATfArle5dv1xFw4Krlm3mvleNXUtaMSWwSqlYqaGf2yZ0crJOBJl0qfI72gXchgG8rWfMDss4SqqoRcqVfQzHps9NsIj(4mzKKtgjV8bs81xOMf(i1FkjM4JZKrsozK8Yhirrxg5TfMh4fAWcz8GcxWfMDsQcWTrqNj8Fi5GU0cZ9lu9Nsc9IAKJjzKKxK)ex(SSnmgKfQDF6Gs5tx)KUn5Ska96GUBZ4bfE3wVOg5ysgj5f5VU9JA4cPpOW72N(0cZVWuTWmU5goluLiFH)g9w47xi)yHtgTWtIXuTqlK)cltwOfziaWc)nAHOzHtSWw(6t0PfTq2xiDEkEH5wHzNwiOb42SqKVWjJwy(oYpfKB53cTq(lSeDBCHgQqC3w9NscUWSts9WIkXxFHAwO6pLe13jzKK6HfvIIUmYBlmpWl0GfY4bfUGlm7KufGBJGot4)qYbDPfM7xO6pLe6f1ihtYijVi)jU8zzBymilu7(0bLY5J(jDBYzva61bD3gxOHke3TFXik(HyFKnDUaru0LrEBHkCHNAHkP0cFK6pLef)qSpYMoxGin)bCQyveaA0s0ggdYcv4cvu3MXdk8Unxy2jPka3M(0bLYg9(jDBYzva61bD3MXdk8Unxy2jPkxfFqD7h1WfsFqH3TZNOfAX(SWjw4LbHwy7x0cTOfMXMPfsE8pYw4LDEHPOw4KrlK8bv0cZT8BHwi)fwMSqYm5leLw4KrfzyBHTbbaSWbDPfw0LroYpwy4lmFh5NyHN(XW2cdhqRfQsZq1cNyHQ)Yx4el80IQyHS)w4PXCSquAH13DKFSWjJwOT9cJAHNKpTqa6G8hxiQj624cnuH4UnocGxy5cUWSts9WIkrr8tRfQzHx2zHoEwyEl0GfM)kAH5SqdwOYkAH5(fIdZKZ(iarRcX(c1EHAVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQzHgXcRVtPOoirdPNfUSnrDfKZQa0BHAwOrSW67ukQdsm0vpkgqAXLUGCwfGE9PdkLv89t62KZQa0Rd6UnJhu4DBUWStsvUk(G62pQHlK(GcVBB04auRTW67oYpw4Krlm3km70cvCCDdxRfcqhK)4sltwiO5Q4dAHTS4d8wOhZcvPf(B0BH8SWjJwi5VfgPfMB53crPfEAmhyEqHVquBHrkTqCeaVWYxi3w4RcDDKFSqCgxhuBHwiaGfEzqOfIMfomi0cbc)GQfoXcv)LVWjRI)r2cl6Yih5hl8Yo3TXfAOcXDB1Fkj4cZoj1dlQeF9fQzHQ)usWfMDsQhwujk6YiVTW8aVWd8BHAwOblS(oLI6GeCHzNKipHC0OLGCwfGElujLwiocGxy5cYCG5bfUOOlJ82c1UpDqzAf1pPBtoRcqVoO72mEqH3T5cZojv5Q4dQB)OgUq6dk8UnO5Q4dAHTS4d8widyXA1wOkTWjJwia3MfI52SqKVWjJwy(oYVfAH8xyTqUTWtIXuTqleaWclQnrrlCYOfIZ46GAlSPt(0TXfAOcXDB1FkjQVtYij1dlQeF9fQzHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkrrxg5TfMh4fEGF9PdktRC)KUn5Ska96GUBJZyK3TvUBtCbOLeNXixIsDB1FkjWaexyUni)qIZy3jaXlSCngO(tjbxy2jPEyrL4RRKsgyeddq(icZuPhwurpngO(tjr9DsgjPEyrL4RRKs4iaEHLliZbMhu4II4NwART2DBCHgQqC3(rQ)usmXhNjJKCYi5LpqIV(c1SWHbiFeCHzNKeoleKZQa0BHAwOblu9NsIhXtMAuojEHLVqLuAHmEqMjj50frTfcEHkVqTxOMf(i1FkjM4JZKrsozK8Yhirrxg5TfQWfY4bfUGlm7K8IAnea1e0zc)hsoOl1Tz8GcVBZfMDsErTgcGA9PdktB6(jDBYzva61bD3(rnCH0hu4DBJwhqRf2gUMf(Bi)yHgLrTWCZuTqRmYxyULFlmJBluLiFH)g9624cnuH4UT6pLeyaIlm3gKFikIXZc1SqCeaVWYfCHzNK6HfvIIUmYBluZcnyHQ)usuFNKrsQhwuj(6lujLwO6pLeCHzNK6HfvIV(c1UBJZyK3TvUBZ4bfE3Mlm7K8IAnea16thuMwX6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoOw3MXdk8Unxy2jzuQ9PdktN)9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4RVqLuAHx2zHoEwOcxOYNQBZ4bfE3Mlm7KufGBtF6GY0NQFs3MCwfGEDq3Tz8GcVBtMdmpOW72iFOQ(6JeL62x2zHoEuiyJ(P62iFOQ(6JeDV0dXd1TvUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8(0bLPpD9t62mEqH3T5cZojv5Q4dQBtoRcqVoO7tF628v205B)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBZ4bfEtWxztNVGXSJjajJhu4MGsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk(t1TXfAOcXD7l7SqhplmpWl0mxiwfGeK5qQJNfQzHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqLuAH4iaEHLl4cZoj1dlQefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQKsl0Gfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLlQVtYij1dlQefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY7thuMUFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBle8cv0c1SqdwO6pLe13jzKK6HfvIxy5luZcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUlujLwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwO2lu7UnJhu4D7hXtMAuo1NoOuS(jDBYzva61bD3gxOHke3TXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHQ)usuFNKrsQhwujEHLVqnl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5UqLuAH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAVqT72mEqH3TVOQIQjJKCI6s(0NoOY)(jDBgpOW72f)qSpYMoxG0TjNvbOxh09PdQt1pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcXra8clxWfMDsQhwujM6tYIUmYBluHlKXdkCrldLgKFi1dlQe4xTqnlu9NsI67Kmss9WIkXlS8fQzH4iaEHLlQVtYij1dlQet9jzrxg5TfQWfY4bfUOLHsdYpK6Hfvc8RwOMf(i1FkjM4JZKrsozK8YhiXlS8UnJhu4D7wgkni)qQhwu1NoOoD9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4fw(c1SqCeaVWYfCHzNK6HfvIIUmYBDBgpOW7213jzKK6Hfv9PdQ8r)KUn5Ska96GUBJl0qfI72gSqCeaVWYfCHzNK6HfvIIUmYBle8cv0c1Sq1FkjQVtYij1dlQeVWYxO2lujLwOErMLh4Nqzr9DsgjPEyrv3MXdk8U9eFCMmsYjJKx(a1NoOm69t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7KupSOsu0LrEBH5TWtPOfQzHQ)usuFNKrsQhwujEHLVqnlKAnYXKWmQHcxgjPovjcpOWfKZQa0RBZ4bfE3EIpotgj5KrYlFG6thuk((jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clFHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjMB3MXdk8Unxy2jPEyrvF6Gszf1pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIV(c1Sq1Fkj4cZoj1dlQefDzK3wyEGxiJhu4cUWStYlQ1qautqNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2Wyq62mEqH3T5cZojv5Q4dQpDqPSY9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzHQ)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3Mlm7Kmk1(0bLYMUFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOMfQ(tjbxy2jPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStsvUk(G6thukRy9t62KZQa0Rd6UnoJrE3w5UnXfGwsCgJCjk1Tv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUskP(tjr9DsgjPEyrL4RRKs4iaEHLliZbMhu4II4NwA3TXfAOcXDB1FkjWaexyUni)queJNUnJhu4DBUWStYlQ1qauRpDqPC(3pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPK6pLe13jzKK6HfvIVUskHJa4fwUGmhyEqHlkIFAPD3gxOHke3TnIfYNwuHgsWfMDsQ)Vxca5hcYzva6TqLuAHQ)usGbiUWCBq(HeNXUtaIxy5DBgpOW72CHzNKxuRHaOwF6Gs5t1pPBtoRcqVoO724cnuH4UT6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY72mEqH3TjZbMhu49PdkLpD9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStYOu7thukNp6N0Tz8GcVBZfMDsQYvXhu3MCwfGEDq3NoOu2O3pPBZ4bfE3Mlm7KufGBt3MCwfGEDq3N(0TRy4bfE)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBZ4bfEtuXWdk8CaRam7ycqY4bfUjOeygpOWfK5aZdkCboJDNaq(HMl7SqhpkeSI)uAmWiQVtPOoirdPNfUSnrDvsj1FkjAi9SWLTjQROnmgeWQ)us0q6zHlBtuxXLplBdJbr7UnUqdviUBFzNf64zH5bEHM5cXQaKGmhsD8Sqnl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQKslehbWlSCbxy2jPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqLuAHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqTxO2luZcv)PKO(ojJKupSOs8clFHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fw(c1SqJyH6fzwEGFcLft8XzYijNmsE5duF6GY09t62KZQa0Rd6UnUqdviUBxFNsrDqIgsplCzBI6kiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWlKXdkCbzoW8GcxqNj8Fi5GUu3MXdk8UnzoW8GcVpDqPy9t62KZQa0Rd6UnJhu4DBUWStsvUk(G62pQHlK(GcVBdAUk(GwikTq0yyBHd6slCIf(B0cNyUlK93cTOfMXMPforSWl7ATqCgxhuRBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcXra8clxWfMDsQhwujk6YiVTW8aVq6mH)djh0LwOMfEzNf64zHkCHM5cXQaKG1LxKJU)R8Yol1XZc1Sq1FkjQVtYij1dlQeVWYxO29PdQ8VFs3MCwfGEDq3TXfAOcXDBCeaVWYft8XzYijNmsE5dKOi(P1c1SqdwO6pLeCHzNK4mUoirBymiluHl0mxiwfGetmx5LplXzCDqTfQzHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fsNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2DBgpOW72CHzNKQCv8b1NoOov)KUn5Ska96GUBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcnyHgXchgG8ruFNKrsQhwujiNvbO3cvsPfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKvOVqTxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1UBZ4bfE3Mlm7KuLRIpO(0b1PRFs3MCwfGEDq3TXfAOcXD7hP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSqWl8rQ)usu8dX(iB6CbI08hWPIvraOrlXLplBdJbzHAwOblu9NscUWSts9WIkXlS8fQKslu9NscUWSts9WIkrrxg5TfMh4fEGFlu7fQzHgSq1FkjQVtYij1dlQeVWYxOskTq1FkjQVtYij1dlQefDzK3wyEGx4b(TqT72mEqH3T5cZojv5Q4dQpDqLp6N0TjNvbOxh0DBCHgQqC3(fJO4hI9r205cerrxg5TfQWfA0xOskTqdw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwOcxOIwOMf(i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfM3cFK6pLef)qSpYMoxGin)bCQyveaA0sC5ZY2WyqwO2DBgpOW72CHzNKQaCB6thug9(jDBYzva61bD3gxOHke3Tv)PKqVOg5ysgj5f5pXxFHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHmEqHl4cZojvb42iOZe(pKCqxQBZ4bfE3Mlm7KufGBtF6GsX3pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPKbgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kPeocGxy5cYCG5bfUOi(PL2ARD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnlCyaYhbxy2jjHZcb5Ska9wOMfAWcv)PK4r8KPgLtIxy5lujLwiJhKzssoDruBHGxOYlu7fQzHgSWhP(tjXeFCMmsYjJKx(ajk6YiVTqfUqgpOWfCHzNKxuRHaOMGot4)qYbDPfQKslehbWlSCHErnYXKmsYlYFIIUmYBlujLwiomto7JaeTke7lu7UnJhu4DBUWStYlQ1qauRpDqPSI6N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAwO6pLe0zD2F0tQhd5dIbeF9UnJhu4DBUWStYlQ1qauRpDqPSY9t62KZQa0Rd6UnJhu4DBUWStYlQ1qauRBJZyK3TvUBJl0qfI72Q)usGbiUWCBq(HOigpluZcnyHQ)usWfMDsQhwuj(6lujLwO6pLe13jzKK6HfvIV(cvsPf(i1FkjM4JZKrsozK8Yhirrxg5TfQWfY4bfUGlm7K8IAnea1e0zc)hsoOlTqT7thukB6(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDB1FkjWaexyUni)queJNfQzHQ)usGbiUWCBq(HOnmgKfcEHQ)usGbiUWCBq(H4YNLTHXG0NoOuwX6N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3gNXiVBRC3gxOHke3Tv)PKadqCH52G8drrmEwOMfQ(tjbgG4cZTb5hIIUmYBlmpWl0GfAWcv)PKadqCH52G8drBymilm3VqgpOWfCHzNKxuRHaOMGot4)qYbDPfQ9cZzHh43c1UpDqPC(3pPBtoRcqVoO724cnuH4UTblSOurTmwfGwOskTqJyHdcdcYpwO2luZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UTttgvYHU6uB6thukFQ(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQ1Tz8GcVBZfMDsgLAF6Gs5tx)KUn5Ska96GUBJl0qfI72x2zHoEwyEGxOI)uluZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UD7RtLhM5(0bLY5J(jDBYzva61bD3gxOHke3Tv)PKO(aKmsYjRiQj(6luZcv)PKGlm7KeNX1bjAdJbzHkCHkw3MXdk8Unxy2jPka3M(0bLYg9(jDBYzva61bD3gxOHke3TVSZcD8SW8aVqZCHyvasOYvXhK8Yol1XZc1Sq1Fkj4cZoj1dlQeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQzH4iaEHLliZbMhu4IIUmYBDBgpOW72CHzNKQCv8b1NoOuwX3pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWYxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1SWHbiFeCHzNKrPkiNvbO3c1SqCeaVWYfCHzNKrPkk6YiVTW8aVWd8BHAw4LDwOJNfMh4fQ4v0c1SqCeaVWYfK5aZdkCrrxg5TUnJhu4DBUWStsvUk(G6thuMwr9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NscUWSts9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkP0cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLPvUFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeF9fQzHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkP0cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLPnD)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs81xOMf(i1FkjM4JZKrsozK8Yhirrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KuLRIpO(0bLPvS(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk2PwOMfQ(tjbxy2jjoJRds0ggdYcvi4fAWcz8GmtsYPlIAlmFEHkVqTxOMfwFNsrDqcUWSts14QY17s(iiNvbO3c1SqgpiZKKC6IO2cv4cvEHAwO6pLepINm1OCs8clVBZ4bfE3Mlm7KuLRIpO(0bLPZ)(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk2PwOMfQ(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzH13PuuhKGlm7KunUQC9UKpcYzva6TqnlKXdYmjjNUiQTqfUqLxOMfQ(tjXJ4jtnkNeVWY72mEqH3T5cZojPZ6ardfEF6GY0NQFs3MXdk8Unxy2jPka3MUn5Ska96GUpDqz6tx)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3MmhyEqH3NoOmD(OFs3MXdk8Unxy2jPkxfFqDBYzva61bDF6t3(gMPl5t)KoOuUFs3MCwfGEDq3TXfAOcXD7ByMUKpIhQnSJPfQqWluzf1Tz8GcVBRcGCq6thuMUFs3MXdk8UTErnYXKmsYlYFDBYzva61bDF6GsX6N0TjNvbOxh0DBCHgQqC3(gMPl5J4HAd7yAH5TqLvu3MXdk8Unxy2j5f1AiaQ1NoOY)(jDBgpOW72CHzNKrP2TjNvbOxh09PdQt1pPBZ4bfE3oHksQcWTPBtoRcqVoO7tF62pkXFGPFshuk3pPBZ4bfE3ghFFOQPtaaDBYzva61bDF6GY09t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62k3TXfAOcXDBZCHyvasKXMjzOto9wi4fQOfQzH6fzwEGFcLfK5aZdk8fQzHgXcnyH13PuuhKOH0Zcx2MOUcYzva6TqLuAH13PuuhKyOREumG0IlDb5Ska9wO2DBZCjD(sD7m2mjdDYPxF6GsX6N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TvUBJl0qfI72M5cXQaKiJntYqNC6TqWlurluZcv)PKGlm7KupSOs8clFHAwiocGxy5cUWSts9WIkrrxg5TfQzHgSW67ukQds0q6zHlBtuxb5Ska9wOskTW67ukQdsm0vpkgqAXLUGCwfGElu7UTzUKoFPUDgBMKHo50RpDqL)9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62k3TXfAOcXDB1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfAelu9NsI6dqYijNSIOM4RVqnlunATfQzHj0r2il6YiVTW8aVqdwObl8YoVqfSqgpOWfCHzNKQaCBe4Onlu7fM7xiJhu4cUWStsvaUnc6mH)djh0LwO2DBZCjD(sD7eYzaP6V8(0b1P6N0TjNvbOxh0DBCHgQqC32Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfMh4fA0v0c1SWl7SqhpluHGx4P7ulu7fQKsl0GfAelCyaYhb5aOJSHC6jiNvbO3c1SWl7SqhplmpWl0OFQfQD3MXdk8U9LDwEq3(0b1PRFs3MCwfGEDq3TXfAOcXDB1Fkj4cZoj1dlQeF9UnJhu4DB9yqH3NoOYh9t62KZQa0Rd6UnUqdviUBxFNsrDqIHU6rXaslU0fKZQa0BHAwO6pLe05m(3gu4IV(c1SqdwiocGxy5cUWSts9WIkrr8tRfQKslunATfQzHj0r2il6YiVTW8aVW8xrlu7UnJhu4D7bDjPfx69PdkJE)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3gaDKnn5PD)3XL8PpDqP47N0TjNvbOxh0DBCHgQqC3w9NscUWSts9WIkXlS8fQzHQ)usuFNKrsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5DBgpOW72Q8HmsYPqyqA9PdkLvu)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwuj(6DBgpOW72Qu1OceKF0NoOuw5(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8172mEqH3TvbI4jt)sR(0bLYMUFs3MCwfGEDq3TXfAOcXDB1Fkj4cZoj1dlQeF9UnJhu4D7eQivGiE9PdkLvS(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8172mEqH3TzhtTPyajMba6thukN)9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4R3Tz8GcVB)BKen0T1NoOu(u9t62KZQa0Rd6UnJhu4D7da(H4jQMuLFhu3gxOHke3Tv)PKGlm7KupSOs81xOskTqCeaVWYfCHzNK6HfvIIUmYBluHGx4Po1c1SWhP(tjXeFCMmsYjJKx(aj(6DBkLi8iD(sD7da(H4jQMuLFhuF6Gs5tx)KUn5Ska96GUBZ4bfE3MU6AvediJ65SJPUnUqdviUBJJa4fwUGlm7KupSOsu0LrEBH5bEHgSqLvSfMZcZhlm3VqZCHyvasW6YWL)gTqT72oFPUnD11Qigqg1Zzht9PdkLZh9t62KZQa0Rd6UnJhu4D7xr8lHksAMAncOBJl0qfI724iaEHLl4cZoj1dlQefDzK3wOcbVqtROfQKsl0iwOzUqSkajyDz4YFJwi4fQ8cvsPfAWch0Lwi4fQOfQzHM5cXQaKiHAzi)qg6Kt1cbVqLxOMfwFNsrDqIgsplCzBI6kiNvbO3c1UB78L62VI4xcvK0m1AeqF6GszJE)KUn5Ska96GUBZ4bfE3UfFaj6WrdvDBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cvi4fQykAHkP0cnIfAMleRcqcwxgU83OfcEHk3TD(sD7w8bKOdhnu1NoOuwX3pPBtoRcqVoO72mEqH3Tpa0sptgjj3AOlcGhu4DBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cvi4fAAfTqLuAHgXcnZfIvbibRldx(B0cbVqLxOskTqdw4GU0cbVqfTqnl0mxiwfGejuld5hYqNCQwi4fQ8c1SW67ukQds0q6zHlBtuxb5Ska9wO2DBNVu3(aql9mzKKCRHUiaEqH3NoOmTI6N0TjNvbOxh0DBgpOW72xgZQfjBzenY7VHWDBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cZd8cp1c1SqdwOrSqZCHyvasKqTmKFidDYPAHGxOYlujLw4GU0cv4cvmfTqT72oFPU9LXSArYwgrJ8(BiCF6GY0k3pPBtoRcqVoO72mEqH3TVmMvls2YiAK3FdH724cnuH4UnocGxy5cUWSts9WIkrrxg5TfMh4fEQfQzHM5cXQaKiHAzi)qg6Kt1cbVqLxOMfQ(tjr9DsgjPEyrL4RVqnlu9NsI67Kmss9WIkrrxg5TfMh4fAWcvwrlmFEHNAH5(fwFNsrDqIgsplCzBI6kiNvbO3c1EHAw4GU0cZBHkMI62oFPU9LXSArYwgrJ8(BiCF6GY0MUFs3MCwfGEDq3TXfAOcXDBgpiZKKC6IO2cv4cnD3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1T5G6thuMwX6N0TjNvbOxh0DBCHgQqC3ghMjN9raIwfI9fQzH13PuuhKGlm7Ke5jKJgTeKZQa0BHAw4WaKpI67Kmss9WIkb5Ska962TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDgx3W1QpDqz68VFs3MCwfGEDq3TFudxi9bfE3(KmAHjuld5hlm0jNQfQshiVTql0KTW8DKFlK93ctOwg1wykQfAug1c1Ra3w4el83Of((fYpw4jXyQuqULFDBgpOW72ygaqY4bfUea1MUDBkeE6Gs5UnUqdviUBBMleRcqIm2mjdDYP3cbVqfTqnl0mxiwfGejuld5hYqNCQ62aO2iD(sD7eQLH8dzOtov9PdktFQ(jDBYzva61bD3gxOHke3TnZfIvbirgBMKHo50BHGxOI62TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDOtov9PdktF66N0TjNvbOxh0DBCHgQqC3UrZG8JMGVYMoFxi4fQC3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1T5RSPZ3(0bLPZh9t62KZQa0Rd6UnJhu4DBmdaiz8GcxcGAt3ga1gPZxQBJJa4fwERpDqzAJE)KUn5Ska96GUBJl0qfI72M5cXQaKiHCgqQ(lFHGxOI62TPq4PdkL72mEqH3TXmaGKXdkCjaQnDBauBKoFPUDfdpOW7thuMwX3pPBtoRcqVoO724cnuH4UTzUqSkajsiNbKQ)Yxi4fQC3UnfcpDqPC3MXdk8UnMbaKmEqHlbqTPBdGAJ05l1TtiNbKQ)Y7thukMI6N0TjNvbOxh0DBgpOW72ygaqY4bfUea1MUnaQnsNVu3(gMPl5tF6t3wViCCv5PFshuk3pPBZ4bfE3Mlm7Ke5dbaq4PBtoRcqVoO7thuMUFs3MXdk8UD7FVHl5cZojt8fbG4QBtoRcqVoO7thukw)KUnJhu4DBC4N29lsEzNLh0TBtoRcqVoO7thu5F)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDB(kB68TB)Oe)bMUDJMb5hnbFLnD(2NoOov)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBYCi1Xt3(rj(dmDBLpvF6G601pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZL05l1T1ls)daijZr3gxOHke3TnyH13PuuhKOH0Zcx2MOUcYzva6TqnlKXdYmjjNUiQTqfUqLxyol0GfQ8cZ9l0GfAelehMjN9r4eUcGOElu7fQ9c1UBBMb(KKaAu3wrDBZmWN62k3NoOYh9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZCjD(sD7m2mjdDYPx3gxOHke3TnyHmEqMjj50frTfQWfA6fQKsl0mxiwfGe6fP)baKK5yHGxOYlujLwOzUqSkaj4RSPZ3fcEHkVqT72MzGpjjGg1Tvu32md8PUTY9PdkJE)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUTI62M5s68L62jKZas1F59PdkfF)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBtTIt(iawla0fnYCl)62pkXFGPBR8P6thukRO(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62MAfNuVO2Wyqq(HCqxQB)Oe)bMUTIVpDqPSY9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1Tn1koPrB(g0POY32YhbWA1TFuI)at3wzf1NoOu209t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TRM8YNLpcG1sMIsoXC72pkXFGPBFQ(0bLYkw)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7QjV8z5JayTKPOKvO3TFuI)at3(u9PdkLZ)(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62vtE5ZYhbWAjtrjz9U9Js8hy62Mwr9PdkLpv)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7Bms9IWe9KtmxPQwD7hL4pW0TvS(0bLYNU(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L623yKx(S8raSwYuuYjMB3(rj(dmDBLvuF6Gs58r)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sD7BmYlFw(iawlzkkjR3TFuI)at3w5t1NoOu2O3pPBtoRcqVoO72HE3UOgnDBgpOW72M5cXQau32mxsNVu3M1Lx(S8raSwYuuYjMB3(rj(dmDBLvuF6GszfF)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBwxE5ZYhbWAjtrjVX0TFuI)at320kQpDqzAf1pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBBAfTW85fAWcp1cZ9leh(7Jgbxy2jPEfp0HwcYzva6TqT72M5s68L62vOlV8z5JayTKPOKtm3(0bLPvUFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMlPZxQBpXCLx(S8raSwYuuswVBJl0qfI72gSqCyMC2hHJoYgzIPfQKsl0GfId)9rJGlm7KuVIh6qlb5Ska9wOMfY4bzMKKtxe1wyEluXwO2lu7UTzg4tscOrD7t1TnZaFQBR8P6thuM209t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62MwrlmFEHgSqJ(cZ9leh(7Jgbxy2jPEfp0HwcYzva6TqT72M5s68L62tmx5LplFeaRLmfLSc9(0bLPvS(jDBYzva61bD3o072nA62mEqH3TnZfIvbOUTzg4tD7tNIwy(8cnyHxUnuPL0md8PfM7xOYksrlu7UnUqdviUBJdZKZ(iC0r2itm1TnZL05l1Tv5Q4dsEzNL64PpDqz68VFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMb(u3wXFQfMpVqdw4LBdvAjnZaFAH5(fQSIu0c1UBJl0qfI724Wm5Spcq0QqS3TnZL05l1Tv5Q4dsEzNL64PpDqz6t1pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBB0v0cZNxObl8YTHkTKMzGpTWC)cvwrkAHA3TXfAOcXDBZCHyvasOYvXhK8Yol1XZcbVqf1TnZL05l1Tv5Q4dsEzNL64PpDqz6tx)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBwxEro6(VYl7SuhpD7hL4pW0Tv(u9PdktNp6N0TjNvbOxh0D7qVBxuJMUnJhu4DBZCHyvaQBBMlPZxQBpXCLx(SeNX1b162pkXFGPBB6(0bLPn69t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1T5GKtmx5LplXzCDqTU9Js8hy62MUpDqzAfF)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUTYlm3VqdwiLV(iDD6jORUwfXaYOEo7yAHkP0cnyHddq(iQVtYij1dlQeKZQa0BHAwOblCyaYhbxy2jjHZcb5Ska9wOskTqJyH4Wm5Spcq0QqSVqTxOMfAWcnIfIdZKZ(iCcxbquVfQKslKXdYmjjNUiQTqWlu5fQKslS(oLI6GenKEw4Y2e1vqoRcqVfQ9c1EHA3TnZL05l1TtOwgYpKHo5u1NoOumf1pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBt5RpsxNEIlJz1IKTmIg593q4fQKslKYxFKUo9eha8dXtunPk)oOfQKslKYxFKUo9eha8dXtun5LEmaak8fQKslKYxFKUo9epUa5gHlFegeP(FkQHjhtlujLwiLV(iDD6jqEdx)Hvbiz(6Z(8VYhzgHPfQKslKYxFKUo9eT4daqZG8dz9v1AHkP0cP81hPRtpr77Qar8K8LMmTAZcvsPfs5RpsxNEclgeYPQjtv4VfQKslKYxFKUo9eja(sYijv5zaOUTzUKoFPUnRldx(BuF6GsXuUFs3MCwfGEDq3Td9UDrnA62mEqH3TnZfIvbOUTzUKoFPUnhKCI5kV8zjoJRdQ1TFuI)at3209PdkfZ09t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TjZHuhpD7hL4pW0Tv(u9PdkftX6N0Tz8GcVBFrvfLeD5dQBtoRcqVoO7thukw(3pPBtoRcqVoO724cnuH4UTrSqZCHyvasOxK(haqsMJfcEHkVqnlS(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVUnJhu4D7ufTrnaM(0bLIDQ(jDBYzva61bD3gxOHke3TnIfAMleRcqc9I0)aasYCSqWlu5fQzHgXcRVtPOoiXd1WiDaKZLwsCCVS)eKZQa0RBZ4bfE3Mlm7KufGBtF6GsXoD9t62KZQa0Rd6UnUqdviUBBMleRcqc9I0)aasYCSqWlu5UnJhu4DBYCG5bfEF6t3ghbWlS8w)KoOuUFs3MCwfGEDq3Tz8GcVBNQOnspmZD7h1WfsFqH3TZVcffAqNw0c)nKFSWJc1a0AHimcdql0cnzlK1fl0OPrlenl0cnzlCI5UWyYOYc1ir3gxOHke3TRVtPOoiXrHAaAjryegGeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfQykAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfAWcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQTqnl0GfAWchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWl8a)wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkP0cnyHgXchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lujLwiocGxy5cUWSts9WIkrrxg5TfMh4fEGFlu7fQDF6GY09t62KZQa0Rd6UnUqdviUBxFNsrDqIJc1a0sIWimajiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBle8cv0c1SqdwOrSWHbiFeKdGoYgYPNGCwfGElujLwOblCyaYhb5aOJSHC6jiNvbO3c1SWl7SqhpluHGxy(qrlu7fQ9c1SqdwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqfUqLv0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzHGxOIwO2lu7fQzHQ)usuFNKrsQhwujEHLVqnl8Yol0XZcvi4fAMleRcqcwxEro6(VYl7SuhpDBgpOW72PkAJ0dZCF6GsX6N0TjNvbOxh0DBCHgQqC3U(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVfQzH4iaEHLlu)PK8HAyKoaY5sljoUx2FII4NwluZcv)PK4HAyKoaY5sljoUx2FYufTr8clFHAwOblu9NscUWSts9WIkXlS8fQzHQ)usuFNKrsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5lu7fQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkAHAwOblu9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQKsl0GfAelCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqLuAH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO2DBgpOW72PkAJAam9PdQ8VFs3MCwfGEDq3TXfAOcXD767ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfIJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFATqnlu9NsIhQHr6aiNlTK44Ez)jtOIeVWYxOMfQxKz5b(juwKQOnQbW0Tz8GcVBNqfjvb420NoOov)KUn5Ska96GUBZ4bfE3(IQkQMmsYjQl5t3(rnCH0hu4D78Jr1cnvXjl0cnzlm3YVfIsleng2wioUi)yHF9f2IWfl80NwiAwOfcayHQ0c)n6Tql0KTWtIXuzYcXCBwiAwydaDKnaATqvkff1TXfAOcXDBCeaVWYft8XzYijNmsE5dKOOlJ82cZBHM5cXQaK4gJuVimrp5eZvQQ1cvsPfAWcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasCJrE5ZYhbWAjtrjz9fQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqIBmYlFw(iawlzkk5eZDHA3NoOoD9t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7KupSOsue)0AHAwObl0iw4WaKpcYbqhzd50tqoRcqVfQKsl0Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfQqWlmFOOfQ9c1EHAwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvsPfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQOfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcVSZcD8SqfcEHM5cXQaKG1LxKJU)R8Yol1Xt3MXdk8U9fvvunzKKtuxYN(0bv(OFs3MCwfGEDq3Tz8GcVB)iEYuJYPU9JA4cPpOW725gGfRvBH)gTWhXtMAuoTql0KTqwxSWtFAHtm3fIAlSi(P1c52cTiaatw4LbHwy7x0cNyHyUnlenluLsrrlCI5k624cnuH4UnocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbiXeZvE5ZsCgxhuBHAwiocGxy5cUWSts9WIkrrxg5TfMh4fEGF9PdkJE)KUn5Ska96GUBJl0qfI724iaEHLl4cZoj1dlQefDzK3wi4fQOfQzHgSqJyHddq(iihaDKnKtpb5Ska9wOskTqdw4WaKpcYbqhzd50tqoRcqVfQzHx2zHoEwOcbVW8HIwO2lu7fQzHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHkROfQzHQ)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXGSqTxOskTqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOIwOMfQ(tjbxy2jjoJRds0ggdYcbVqfTqTxO2luZcv)PKO(ojJKupSOs8clFHAw4LDwOJNfQqWl0mxiwfGeSU8IC09FLx2zPoE62mEqH3TFepzQr5uF6GsX3pPBtoRcqVoO72mEqH3Tl(HyFKnDUaPB)OgUq6dk8UTrtJwytNlqwikTWjM7cz)TqwFHCrlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAzYcVmii)yHTFrl0IwygBMwipleG42SWXkwixy2PfIZ46GAlK93cNmEw4eZDHwCZnCw4PD)2SWFJEIUnUqdviUBJJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajQM8YNLpcG1sMIsoXCxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKOAYlFw(iawlzkkjRVqnl0Gfoma5JO(ojJKupSOsqoRcqVfQzHgSqCeaVWYf13jzKK6HfvIIUmYBlmVfsNj8Fi5GU0cvsPfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKOAYlFw(iawlzkkzf6lu7fQKsl0iw4WaKpI67Kmss9WIkb5Ska9wO2luZcv)PKGlm7KeNX1bjAdJbzHkCHMEHAw4Ju)PKyIpotgj5KrYlFGeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1Sq1Fkj4cZoj1dlQeVWY7thukRO(jDBYzva61bD3MXdk8UDXpe7JSPZfiD7h1WfsFqH3TnAA0cB6CbYcTqt2cz9fALr(c1JwdPcqIfE6tlCI5UquBHfXpTwi3wOfbayYcVmi0cB)Iw4eleZTzHOzHQukkAHtmxr3gxOHke3TXra8clxmXhNjJKCYi5LpqIIUmYBlmVfsNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GAluZcXra8clxWfMDsQhwujk6YiVTW8wOblKot4)qYbDPfMZcz8GcxmXhNjJKCYi5Lpqc6mH)djh0LwO29PdkLvUFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBlmVfsNj8Fi5GU0c1SqdwObl0iw4WaKpcYbqhzd50tqoRcqVfQKsl0Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfQqWlmFOOfQ9c1EHAwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvsPfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQOfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcVSZcD8SqfcEHM5cXQaKG1LxKJU)R8Yol1XZc1UBZ4bfE3U4hI9r205cK(0bLYMUFs3MCwfGEDq3Tz8GcVBpXhNjJKCYi5LpqD7h1WfsFqH3TnAA0cNyUl0cnzlK1xikTq0yyBHwOjd5lCYOfE5Zl8raSwIfE6tl0JXKf(B0cTqt2cRqFHO0cNmAHddq(SquBHddc5MSq2Fleng2wOfAYq(cNmAHx(8cFeaRLOBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8aVqZCHyvasmXCLx(SeNX1b1wOMfIJa4fwUGlm7KupSOsu0LrEBH5bEH0zc)hsoOlTqnl8Yol0XZcv4cnZfIvbibRlVihD)x5LDwQJNfQzHQ)usuFNKrsQhwujEHL3NoOuwX6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cPZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6luZcXra8clxWfMDsQhwujk6YiVTqfUqLnD3MXdk8U9eFCMmsYjJKx(a1NoOuo)7N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SqdwOrSWHbiFe13jzKK6HfvcYzva6TqLuAH4iaEHLlQVtYij1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkzf6lu7fQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjR3Tz8GcVBpXhNjJKCYi5Lpq9PdkLpv)KUn5Ska96GUBZ4bfE3Mlm7KupSOQB)OgUq6dk8UTrtJwiRVquAHtm3fIAlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAzYcVmii)yHTFrlCY4zHw0cZyZ0cjp(hzl8YoVq2FlCY4zHtgv0crTf6XSqgOi(P1c5fwFNwyKwOEyr1cFHLl624cnuH4UnocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1SqdwOrSqCyMC2hHzYNmTQfQKslehbWlSCXfvvunzKKtuxYhrrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjVXSqTxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1Sq1FkjQVtYij1dlQeVWYxOMfEzNf64zHke8cnZfIvbibRlVihD)x5LDwQJN(0bLYNU(jDBYzva61bD3MXdk8UD9DsgjPEyrv3(rnCH0hu4DBJMgTWk0xikTWjM7crTfg(cXVfY(BHwHB4SqvAHF9fMIAHaHFq1cNm2x4Krl8YNx4JayTmzHxgeKFSW2VOfozurle1CdNfYafXpTwiVW670cFHLVq2FlCY4zHS(cTc3WzHQeoU0czZmcGvbOf((fYpwy9Ds0TXfAOcXDB1Fkj4cZoj1dlQeVWYxOMfAWcXra8clxmXhNjJKCYi5LpqIIUmYBluHl0mxiwfGevOlV8z5JayTKPOKtm3fQKslehbWlSCbxy2jPEyrLOOlJ82cZd8cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfIJa4fwUGlm7KupSOsu0LrEBHkCHkB6(0bLY5J(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8clFHAwiocGxy5cUWSts9WIkXuFsw0LrEBHkCHmEqHlAzO0G8dPEyrLa)QfQzHQ)usuFNKrsQhwujEHLVqnlehbWlSCr9DsgjPEyrLyQpjl6YiVTqfUqgpOWfTmuAq(HupSOsGF1c1SWhP(tjXeFCMmsYjJKx(ajEHL3Tz8GcVB3YqPb5hs9WIQ(0bLYg9(jDBYzva61bD3MXdk8UTErnYXKmsYlYFD7h1WfsFqH3TnAA0c1J7cNyHT81NOtlAHSVq68u8cz1fI8foz0cD68SqCeaVWYxOfYFHLjl87auRTqq0QqSVWjJ8fgoGwl89lKFSqUWStlupSOAHVpTWjwywyTWl78cZ((rP1cl(HyFwytNlqwiQ1TXfAOcXD7HbiFe13jzKK6HfvcYzva6Tqnlu9NscUWSts9WIkXxFHAwO6pLe13jzKK6HfvIIUmYBlmVfEGFIlFUpDqPSIVFs3MCwfGEDq3TXfAOcXD7hP(tjXeFCMmsYjJKx(aj(6luZcFK6pLet8XzYijNmsE5dKOOlJ82cZBHmEqHl4cZojVOwdbqnbDMW)HKd6sluZcnIfIdZKZ(iarRcXE3MXdk8UTErnYXKmsYlYF9PdktRO(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs81xOMfQ(tjr9DsgjPEyrLOOlJ82cZBHh4N4YNxOMfIJa4fwUGmhyEqHlkIFATqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTqnl0iwiomto7JaeTke7DBgpOW726f1ihtYijVi)1N(0T5G6N0bLY9t62KZQa0Rd6UnUqdviUBxFNsrDqIhQHr6aiNlTK44Ez)jiNvbO3c1SqCeaVWYfQ)us(qnmsha5CPLeh3l7prr8tRfQzHQ)us8qnmsha5CPLeh3l7pzQI2iEHLVqnl0GfQ(tjbxy2jPEyrL4fw(c1Sq1FkjQVtYij1dlQeVWYxOMf(i1FkjM4JZKrsozK8YhiXlS8fQ9c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnl0GfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbibhKCI5kV8zjoJRdQTqnl0GfAWchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWl8a)wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkP0cnyHgXchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lujLwiocGxy5cUWSts9WIkrrxg5TfMh4fEGFlu7fQD3MXdk8UDQI2OgatF6GY09t62KZQa0Rd6UnUqdviUBBWcRVtPOoiXd1WiDaKZLwsCCVS)eKZQa0BHAwiocGxy5c1FkjFOggPdGCU0sIJ7L9NOi(P1c1Sq1FkjEOggPdGCU0sIJ7L9NmHks8clFHAwOErMLh4NqzrQI2OgaZc1EHkP0cnyH13PuuhK4HAyKoaY5sljoUx2FcYzva6TqnlCqxAH5TqLxO2DBgpOW72jursvaUn9PdkfRFs3MCwfGEDq3TXfAOcXD767ukQdsCuOgGwsegHbib5Ska9wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHkMIwOMfIJa4fwUyIpotgj5KrYlFGefDzK3wi4fQOfQzHgSq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQzHgSqdw4WaKpI67Kmss9WIkb5Ska9wOMfIJa4fwUO(ojJKupSOsu0LrEBH5bEHh43c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lujLwObl0iw4WaKpI67Kmss9WIkb5Ska9wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkP0cXra8clxWfMDsQhwujk6YiVTW8aVWd8BHAVqT72mEqH3Ttv0gPhM5(0bv(3pPBtoRcqVoO724cnuH4UD9Dkf1bjokudqljcJWaKGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wO2lu7fQzHQ)usuFNKrsQhwujEHLVqT72mEqH3Ttv0gPhM5(0b1P6N0TjNvbOxh0DBCHgQqC3U(oLI6GenKEw4Y2e1vqoRcqVfQzH6fzwEGFcLfK5aZdk8UnJhu4D7j(4mzKKtgjV8bQpDqD66N0TjNvbOxh0DBCHgQqC3U(oLI6GenKEw4Y2e1vqoRcqVfQzHgSq9ImlpWpHYcYCG5bf(cvsPfQxKz5b(juwmXhNjJKCYi5Lpqlu7UnJhu4DBUWSts9WIQ(0bv(OFs3MCwfGEDq3TXfAOcXD7bDPfQWfQykAHAwy9Dkf1bjAi9SWLTjQRGCwfGEluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wOMfIJa4fwUyIpotgj5KrYlFGefDzK3wi4fQOfQzH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(1Tz8GcVBtMdmpOW7thug9(jDBYzva61bD3MXdk8UnzoW8GcVBJ8HQ6RpsuQBR(tjrdPNfUSnrDfTHXGaw9NsIgsplCzBI6kU8zzBymiDBKpuvF9rIUx6H4H62k3TXfAOcXD7bDPfQWfQykAHAwy9Dkf1bjAi9SWLTjQRGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqWlurluZcnyHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wO2lu7fQzHQ)usuFNKrsQhwujEHLVqT7thuk((jDBYzva61bD3gxOHke3TnyH4iaEHLl4cZoj1dlQefDzK3wOcxy(FQfQKslehbWlSCbxy2jPEyrLOOlJ82cZd8cvSfQ9c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnl0GfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbibhKCI5kV8zjoJRdQTqnl0GfAWchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWl8a)wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHNAHAVqLuAHgSqJyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfEQfQ9cvsPfIJa4fwUGlm7KupSOsu0LrEBH5bEHh43c1EHA3Tz8GcVBFrvfvtgj5e1L8PpDqPSI6N0TjNvbOxh0DBCHgQqC3ghbWlSCXeFCMmsYjJKx(ajk6YiVTW8wiDMW)HKd6sluZcnyHQ)usWfMDsIZ46GeTHXGSW8aVqZCHyvasWbjNyUYlFwIZ46GAluZcnyHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cpWVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqTxOskTqdwOrSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9cvsPfIJa4fwUGlm7KupSOsu0LrEBH5bEHh43c1EHA3Tz8GcVBx8dX(iB6CbsF6GszL7N0TjNvbOxh0DBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cZBH0zc)hsoOlTqnl0GfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqLuAHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqfTqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1UBZ4bfE3U4hI9r205cK(0bLYMUFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBle8cv0c1SqdwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvsPfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cv0c1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQ9c1EHAwO6pLe13jzKK6HfvIxy5lu7UnJhu4D7hXtMAuo1NoOuwX6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAwObl0Gfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLlQVtYij1dlQefDzK3wyEGx4b(TqnlehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9cvsPfAWcnIfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqTxOskTqCeaVWYfCHzNK6HfvIIUmYBlmpWl8a)wO2DBgpOW72t8XzYijNmsE5duF6Gs58VFs3MCwfGEDq3TXfAOcXDBdwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqfUqZCHyvasW6YlFw(iawlzkk5eZDHAwO6pLeCHzNK4mUoirBymile8cv)PKGlm7KeNX1bjU8zzBymilu7fQKsl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wi4fQOfQzHQ)usWfMDsIZ46GeTHXGSW8aVqZCHyvasWbjNyUYlFwIZ46GAlu7fQ9c1Sq1FkjQVtYij1dlQeVWY72mEqH3T5cZoj1dlQ6thukFQ(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clFHAwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOPv0c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lujLwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlurluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wO2lu7fQzHgSqCeaVWYfCHzNK6HfvIIUmYBluHluztVqLuAHps9NsIj(4mzKKtgjV8bs81xO2DBgpOW7213jzKK6Hfv9PdkLpD9t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7Kmkvrrxg5TfQWfEQfQKsl0iw4WaKpcUWStYOufKZQa0RBZ4bfE3ULHsdYpK6Hfv9PdkLZh9t62KZQa0Rd6UnUqdviUBR(tjXJ4jtnkNeF9fQzHps9NsIj(4mzKKtgjV8bs81xOMf(i1FkjM4JZKrsozK8Yhirrxg5TfMh4fQ(tjHErnYXKmsYlYFIlFw2ggdYcZ9lKXdkCbxy2jPka3gbDMW)HKd6sluZcnyHgSWHbiFef1cNDmjiNvbO3c1SqgpiZKKC6IO2cZBH5)c1EHkP0cz8GmtsYPlIAlmVfEQfQ9c1SqdwOrSW67ukQdsWfMDsQgxvUExYhb5Ska9wOskTWHRdAezedmzcD8SqfUqf7ulu7UnJhu4DB9IAKJjzKKxK)6thukB07N0TjNvbOxh0DBCHgQqC3w9NsIhXtMAuoj(6luZcnyHgSWHbiFef1cNDmjiNvbO3c1SqgpiZKKC6IO2cZBH5)c1EHkP0cz8GmtsYPlIAlmVfEQfQ9c1SqdwOrSW67ukQdsWfMDsQgxvUExYhb5Ska9wOskTWHRdAezedmzcD8SqfUqf7ulu7UnJhu4DBUWStsvaUn9PdkLv89t62mEqH3TBFDQ8Wm3TjNvbOxh09PdktRO(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHke8cnyHmEqMjj50frTfMpVqLxO2luZcRVtPOoibxy2jPACv56DjFeKZQa0BHAw4W1bnImIbMmHoEwyEluXov3MXdk8Unxy2jPkxfFq9PdktRC)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXG0Tz8GcVBZfMDsQYvXhuF6GY0MUFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2Wyqwi4fQOUnJhu4DBUWStYOu7thuMwX6N0TjNvbOxh0DBCHgQqC32GfwuQOwgRcqlujLwOrSWbHbb5hlu7fQzHQ)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXG0Tz8GcVB70KrLCORo1M(0bLPZ)(jDBYzva61bD3gxOHke3Tv)PKadqCH52G8drrmEwOMfwFNsrDqcUWStsKNqoA0sqoRcqVfQzHgSqdw4WaKpc(QdGsimpOWfKZQa0BHAwiJhKzssoDruBH5TqJ(c1EHkP0cz8GmtsYPlIAlmVfEQfQD3MXdk8Unxy2j5f1AiaQ1NoOm9P6N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAw4WaKpcUWStscNfcYzva6Tqnl8rQ)usmXhNjJKCYi5LpqIV(c1Sqdw4WaKpc(QdGsimpOWfKZQa0BHkP0cz8GmtsYPlIAlmVfQ4xO2DBgpOW72CHzNKxuRHaOwF6GY0NU(jDBYzva61bD3gxOHke3Tv)PKadqCH52G8drrmEwOMfoma5JGV6aOecZdkCb5Ska9wOMfY4bzMKKtxe1wyElm)72mEqH3T5cZojVOwdbqT(0bLPZh9t62KZQa0Rd6UnUqdviUBR(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWSts6Soq0qH3NoOmTrVFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfQxKz5b(juwWfMDsQYvXhu3MXdk8Unxy2jjDwhiAOW7thuMwX3pPBJ8HQ6RpsuQBFzNf64rHGv8NQBJ8HQ6Rps09spepu3w5UnJhu4DBYCG5bfE3MCwfGEDq3N(0TdDYPQFshuk3pPBtoRcqVoO724cnuH4UD9Dkf1bjEOggPdGCU0sIJ7L9NGCwfGEluZcv)PK4HAyKoaY5sljoUx2FYufTr8172mEqH3TtOIKQaCB6thuMUFs3MCwfGEDq3TXfAOcXD767ukQdsCuOgGwsegHbib5Ska9wOMfEzNf64zHkCHk(t1Tz8GcVBNQOnspmZ9PdkfRFs3MXdk8U9J4jtnkN62KZQa0Rd6(0bv(3pPBtoRcqVoO724cnuH4U9LDwOJNfQWfM)kQBZ4bfE3U4hI9r205cK(0b1P6N0TjNvbOxh0DBCHgQqC3w9NscUWSts9WIkXlS8fQzH4iaEHLl4cZoj1dlQefDzK362mEqH3TBzO0G8dPEyrvF6G601pPBZ4bfE3(IQkQMmsYjQl5t3MCwfGEDq3NoOYh9t62mEqH3TN4JZKrsozK8YhOUn5Ska96GUpDqz07N0Tz8GcVBZfMDsQhwu1TjNvbOxh09PdkfF)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHL3Tz8GcVBxFNKrsQhwu1NoOuwr9t62KZQa0Rd6UnJhu4DB9IAKJjzKKxK)62pQHlK(GcVBB00OfMFHPAHtSWw(6t0PfTq2xiDEkEH5wHzNwiOb42SW3Vq(XcNmAHNeJPsb5w(TqlK)cRf(DaQ1wy9Dh5hlm3km70cpn4SqSWtFAH5wHzNw4PbNfle1w4WaKp0ZKfArleZUHZc)nAH5xyQwOfAYq(cNmAHNeJPsb5w(TqlK)cRf(DaQ1wOfTqKpuvF9zHtgTWCZuTqCg7obyYcBXcTidbawyJntlenIUnUqdviUBBelCyaYhbxy2jjHZcb5Ska9wOMf(i1FkjM4JZKrsozK8YhiXxFHAw4Ju)PKyIpotgj5KrYlFGefDzK3wyEGxOblKXdkCbxy2jPka3gbDMW)HKd6slm3Vq1Fkj0lQroMKrsEr(tC5ZY2WyqwO29PdkLvUFs3MCwfGEDq3Tz8GcVBRxuJCmjJK8I8x3(rnCH0hu4D7tFAH5xyQwyg3CdNfQsKVWFJEl89lKFSWjJw4jXyQwOfYFHLjl0ImeayH)gTq0SWjwylF9j60Iwi7lKopfVWCRWStle0aCBwiYx4KrlmFh5NcYT8BHwi)fwIUnUqdviUB)Iru8dX(iB6CbIOOlJ82cv4cp1cvsPf(i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfQWfQO(0bLYMUFs3MCwfGEDq3TXfAOcXDB1Fkj0lQroMKrsEr(t81xOMf(i1FkjM4JZKrsozK8YhiXxFHAw4Ju)PKyIpotgj5KrYlFGefDzK3wyEGxiJhu4cUWStsvaUnc6mH)djh0L62mEqH3T5cZojvb420NoOuwX6N0TjNvbOxh0DBgpOW72CHzNKQCv8b1TFudxi9bfE3o3aSyTAle0Cv8bTqEw4KrlK83cJ0cZT8BHwzKVW67oYpw4Krlm3km70cvCCDdxRfcqhK)4sRUnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NscUWSts9WIkrrxg5TfM3cpWVfQzH13PuuhKGlm7Ke5jKJgTeKZQa0RpDqPC(3pPBtoRcqVoO72mEqH3T5cZojv5Q4dQB)OgUq6dk8UDUbyXA1wiO5Q4dAH8SWjJwi5VfgPfoz0cZ3r(TqlK)cRfALr(cRV7i)yHtgTWCRWStluXX1nCTwiaDq(JlT624cnuH4UT6pLe13jzKK6HfvIV(c1Sq1Fkj4cZoj1dlQeVWYxOMfQ(tjr9DsgjPEyrLOOlJ82cZd8cpWVfQzH13PuuhKGlm7Ke5jKJgTeKZQa0RpDqP8P6N0TjNvbOxh0DBCgJ8UTYDBIlaTK4mg5suQBR(tjbgG4cZTb5hsCg7obiEHLRXa1Fkj4cZoj1dlQeFDLuYaJyyaYhryMk9WIk6PXa1FkjQVtYij1dlQeFDLuchbWlSCbzoW8Gcxue)0sBT1UBJl0qfI72ps9NsIj(4mzKKtgjV8bs81xOMfoma5JGlm7KKWzHGCwfGEluZcnyHQ)us8iEYuJYjXlS8fQKslKXdYmjjNUiQTqWlu5fQ9c1SWhP(tjXeFCMmsYjJKx(ajk6YiVTqfUqgpOWfCHzNKxuRHaOMGot4)qYbDPUnJhu4DBUWStYlQ1qauRpDqP8PRFs3MCwfGEDq3Tz8GcVBZfMDsErTgcGADBCgJ8UTYDBCHgQqC3w9NscmaXfMBdYpefX4PpDqPC(OFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GADBgpOW72CHzNKrP2NoOu2O3pPBtoRcqVoO724cnuH4UT6pLe13jzKK6HfvIV(cvsPfEzNf64zHkCHkFQUnJhu4DBUWStsvaUn9PdkLv89t62KZQa0Rd6UnJhu4DBYCG5bfE3g5dv1xFKOu3(Yol0XJcbB0pv3g5dv1xFKO7LEiEOUTYDBCHgQqC3w9NsI67Kmss9WIkXlS8fQzHQ)usWfMDsQhwujEHL3NoOmTI6N0Tz8GcVBZfMDsQYvXhu3MCwfGEDq3N(0TtiNbKQ)Y7N0bLY9t62KZQa0Rd6UnJhu4DBUWStYlQ1qauRBJZyK3TvUBJl0qfI72Q)usGbiUWCBq(HOigp9Pdkt3pPBZ4bfE3Mlm7KufGBt3MCwfGEDq3NoOuS(jDBgpOW72CHzNKQCv8b1TjNvbOxh09Pp9PBBMQgk8oOmTImTYksXuoF0TT4Yr(rRBNpLB5BqD6b1PntzHl8KmAHOREuZctrTqdZ46gUwgUWIYxFurVf2IlTq(pXLh6TqCg7hutSgBKiNwOIzkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwy(Bkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNw4PmLfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtl0OBkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOYkBkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOYgDtzHgv4MPAO3cneh(7JgrUmCHtSqdXH)(OrKlb5Ska9mCH8SWtJrRrUqdu(S2I1yJe50cvwXBkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOPv8MYcnQWnt1qVfAio83hnICz4cNyHgId)9rJixcYzva6z4c5zHNgJwJCHgO8zTfRXRX5t5w(guNEqDAZuw4cpjJwi6Qh1SWuul0WeQLH8dzOtovgUWIYxFurVf2IlTq(pXLh6TqCg7hutSgBKiNwOYMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdm9zTfRXgjYPfAAtzHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXgjYPfQyMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cZFtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHNYuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNw4PmLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCH8SWtJrRrUqdu(S2I1yJe50cvwrMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdm9zTfRXgjYPfQ8PmLfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOYgDtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHkB0nLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCH8SWtJrRrUqdu(S2I1yJe50cvwXBkl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl00kBkl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTynEnoFk3Y3G60dQtBMYcx4jz0crx9OMfMIAHgg6KtLHlSO81hv0BHT4slK)tC5HEleNX(b1eRXgjYPfQSPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqtBkl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtluzfzkl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqLvmtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqLZFtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqLpLPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I14148PClFdQtpOoTzklCHNKrleD1JAwykQfAyfdpOWnCHfLV(OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnLfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOPnLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfM)MYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtl8uMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtluXBkl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqLv8MYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtl00kYuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOPv2uwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOPvmtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMo)nLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXRX5t5w(guNEqDAZuw4cpjJwi6Qh1SWuul0WhL4pWy4clkF9rf9wylU0c5)exEO3cXzSFqnXASrICAHM2uwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGPpRTyn2iroTqfZuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGPpRTyn2iroTW83uwOrfUzQg6TqB01OwytlF4Zl80(foXcnYpVWhYmQHcFHHov8e1cnqbAVqdu(S2I1yJe50cpLPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfMpmLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfQC(WuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOYkEtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMwztzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMwXmLfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtl00kMPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTynEnoFk3Y3G60dQtBMYcx4jz0crx9OMfMIAHgQxeoUQ8y4clkF9rf9wylU0c5)exEO3cXzSFqnXASrICAHNotzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMwrMYcnQWnt1qVfAio83hnICz4cNyHgId)9rJixcYzva6z4cnq5ZAlwJnsKtl00kBkl0Oc3mvd9wOH4WFF0iYLHlCIfAio83hnICjiNvbONHl0aLpRTyn2iroTqtBAtzHgv4MPAO3cneh(7JgrUmCHtSqdXH)(OrKlb5Ska9mCHgO8zTfRXgjYPfAAfVPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfAAfVPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqfl)nLfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCH8SWtJrRrUqdu(S2I1yJe50cvStzkl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXRX5t5w(guNEqDAZuw4cpjJwi6Qh1SWuul0qCeaVWYBgUWIYxFurVf2IlTq(pXLh6TqCg7hutSgBKiNwOYMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnW0N1wSgBKiNwOYMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnTPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfAAtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHkMPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfQyMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cZFtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHNotzHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgy6ZAlwJnsKtl0OBkl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0atFwBXASrICAHkEtzHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgy6ZAlwJnsKtluzLnLfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGPpRTyn2iroTqLvmtzHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXgjYPfQC(Bkl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqLn6MYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJxJZNYT8nOo9G60MPSWfEsgTq0vpQzHPOwOHCqgUWIYxFurVf2IlTq(pXLh6TqCg7hutSgBKiNwOYMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnW0N1wSgBKiNwOYMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnTPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0atFwBXASrICAHkMPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfQyMYcnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cZFtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHNYuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNw4PZuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwy(WuwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOr3uwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOI3uwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM(S2I1yJe50cvwrMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnW0N1wSgBKiNwOYkMPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdm9zTfRXgjYPfQ8PZuwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxipl80y0AKl0aLpRTyn2iroTqLZhMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtlu58HPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqLn6MYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtluzJUPSqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqtRitzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMo)nLfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOPZFtzHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHM(uMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnW0N1wSgBKiNwOPpDMYcnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJxJZNYT8nOo9G60MPSWfEsgTq0vpQzHPOwOH8v205RHlSO81hv0BHT4slK)tC5HEleNX(b1eRXgjYPfQSPSqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I1414t)vpQHEluzLxiJhu4lea1MMynUBRxrcbqD7CxUBHMk(GwyUvy2P14CxUBH5MEHawOPnzHMwrMw51414CxUBH5B6gMPfAMleRcqc(kB68DHiFHj2CulmslSrZG8JMGVYMoFxOb4mcdYc1k(1cB6eEHH(GcVPTyno3L7wOrtJw4OLocZal0gDnQfMX(da5hlmsleNXUtale5dv1xFqHVqK3gIFlmsl0qm7ycqY4bfUHI141ygpOWBc9IWXvLNCaRaUWStsKpeaaHN1ygpOWBc9IWXvLNCaRaUWStYeFraiUwJz8GcVj0lchxvEYbScWHFA3Vi5LDwEq31ygpOWBc9IWXvLNCaRaZCHyvaYeNVey(kB681KqhCrnAm5rj(dmGB0mi)Oj4RSPZ31ygpOWBc9IWXvLNCaRaZCHyvaYeNVeyYCi1XJjHo4IA0yYJs8hyaR8PwJz8GcVj0lchxvEYbScmZfIvbitC(sG1ls)daijZHjHo4gnMGsGnO(oLI6GenKEw4Y2e1vdJhKzssoDrutHkNJbkN7nWiWHzYzFeoHRaiQN2ARTjMzGpbwztmZaFssancSIwJz8GcVj0lchxvEYbScmZfIvbitC(sGZyZKm0jNEMe6GB0yckb2agpiZKKC6IOMcnTskzMleRcqc9I0)aasYCawzLuYmxiwfGe8v205lyL12eZmWNaRSjMzGpjjGgbwrRXmEqH3e6fHJRkp5awbM5cXQaKjoFjWjKZas1F5Me6GB0yIzg4tGv0AmJhu4nHEr44QYtoGvGzUqSkazIZxcSPwXjFeaRfa6IgzULFMe6GlQrJjpkXFGbSYNAnMXdk8MqViCCv5jhWkWmxiwfGmX5lb2uR4K6f1ggdcYpKd6sMe6GlQrJjpkXFGbSIFnMXdk8MqViCCv5jhWkWmxiwfGmX5lb2uR4KgT5BqNIkFBlFeaRLjHo4IA0yYJs8hyaRSIwJz8GcVj0lchxvEYbScmZfIvbitC(sGRM8YNLpcG1sMIsoXCnj0bxuJgtEuI)ad4tTgZ4bfEtOxeoUQ8KdyfyMleRcqM48Laxn5LplFeaRLmfLScDtcDWf1OXKhL4pWa(uRXmEqH3e6fHJRkp5awbM5cXQaKjoFjWvtE5ZYhbWAjtrjzDtcDWf1OXKhL4pWa20kAnMXdk8MqViCCv5jhWkWmxiwfGmX5lb(gJuVimrp5eZvQQLjHo4IA0yYJs8hyaRyRXmEqH3e6fHJRkp5awbM5cXQaKjoFjW3yKx(S8raSwYuuYjMRjHo4IA0yYJs8hyaRSIwJz8GcVj0lchxvEYbScmZfIvbitC(sGVXiV8z5JayTKPOKSUjHo4IA0yYJs8hyaR8PwJz8GcVj0lchxvEYbScmZfIvbitC(sGzD5LplFeaRLmfLCI5AsOdUOgnM8Oe)bgWkRO1ygpOWBc9IWXvLNCaRaZCHyvaYeNVeywxE5ZYhbWAjtrjVXysOdUOgnM8Oe)bgWMwrRXmEqH3e6fHJRkp5awbM5cXQaKjoFjWvOlV8z5JayTKPOKtmxtcDWnAmXmd8jWMwr5ZgCQCpo83hncUWSts9kEOdT0EnMXdk8MqViCCv5jhWkWmxiwfGmX5lbEI5kV8z5JayTKPOKSUjHo4gnMGsGnahMjN9r4OJSrMysjLmah(7Jgbxy2jPEfp0HwAy8GmtsYPlIA5PyARTjMzGpbw5tzIzg4tscOrGp1AmJhu4nHEr44QYtoGvGzUqSkazIZxc8eZvE5ZYhbWAjtrjRq3KqhCJgtmZaFcSPvu(Sbg9Cpo83hncUWSts9kEOdT0EnMXdk8MqViCCv5jhWkWmxiwfGmX5lbwLRIpi5LDwQJhtcDWnAmbLaJdZKZ(iC0r2itmzIzg4tGpDkkF2Gl3gQ0sAMb(uUxzfPiTxJz8GcVj0lchxvEYbScmZfIvbitC(sGv5Q4dsEzNL64XKqhCJgtqjW4Wm5Spcq0QqSBIzg4tGv8NkF2Gl3gQ0sAMb(uUxzfPiTxJz8GcVj0lchxvEYbScmZfIvbitC(sGv5Q4dsEzNL64XKqhCJgtqjWM5cXQaKqLRIpi5LDwQJhWkYeZmWNaB0vu(SbxUnuPL0md8PCVYksrAVgZ4bfEtOxeoUQ8KdyfyMleRcqM48LaZ6YlYr3)vEzNL64XKqhCrnAm5rj(dmGv(uRXmEqH3e6fHJRkp5awbM5cXQaKjoFjWtmx5LplXzCDqntcDWf1OXKhL4pWa20RXmEqH3e6fHJRkp5awbM5cXQaKjoFjWCqYjMR8YNL4mUoOMjHo4IA0yYJs8hyaB61ygpOWBc9IWXvLNCaRaZCHyvaYeNVe4eQLH8dzOtovMe6GB0yIzg4tGvo3BaLV(iDD6jORUwfXaYOEo7ysjLmyyaYhr9DsgjPEyrLgdggG8rWfMDss4SqjLmcCyMC2hbiAvi21wJbgbomto7JWjCfar9usjgpiZKKC6IOgyLvsP67ukQds0q6zHlBtuxT1w71ygpOWBc9IWXvLNCaRaZCHyvaYeNVeywxgU83itcDWnAmXmd8jWu(6J01PN4YywTizlJOrE)newjLO81hPRtpXba)q8evtQYVdsjLO81hPRtpXba)q8evtEPhdaGcxjLO81hPRtpXJlqUr4YhHbrQ)NIAyYXKskr5RpsxNEcK3W1FyvasMV(Sp)R8rMrysjLO81hPRtprl(aa0mi)qwFvTusjkF9r660t0(UkqepjFPjtR2OKsu(6J01PNWIbHCQAYuf(tjLO81hPRtprcGVKmssvEgaAnMXdk8MqViCCv5jhWkWmxiwfGmX5lbMdsoXCLx(SeNX1b1mj0bxuJgtEuI)adytVgZ4bfEtOxeoUQ8KdyfyMleRcqM48LatMdPoEmj0bxuJgtEuI)adyLp1AmJhu4nHEr44QYtoGvWfvvus0LpO1ygpOWBc9IWXvLNCaRGufTrnagtqjWgHzUqSkaj0ls)daijZbyL1uFNsrDqIhQHr6aiNlTK44Ez)TgZ4bfEtOxeoUQ8KdyfWfMDsQcWTXeucSryMleRcqc9I0)aasYCawzngr9Dkf1bjEOggPdGCU0sIJ7L93AmJhu4nHEr44QYtoGvazoW8Gc3eucSzUqSkaj0ls)daijZbyLxJxJz8GcVLdyfGJVpu10jaG1ygpOWB5awbM5cXQaKjoFjWzSzsg6KtptcDWnAmXmd8jWkBckb2mxiwfGezSzsg6KtpWksJErMLh4NqzbzoW8GcxJryq9Dkf1bjAi9SWLTjQRskvFNsrDqIHU6rXaslU01EnMXdk8woGvGzUqSkazIZxcCgBMKHo50ZKqhCJgtmZaFcSYMGsGnZfIvbirgBMKHo50dSI0O(tjbxy2jPEyrL4fwUgCeaVWYfCHzNK6HfvIIUmYBAmO(oLI6GenKEw4Y2e1vjLQVtPOoiXqx9OyaPfx6AVgZ4bfElhWkWmxiwfGmX5lboHCgqQ(l3KqhCJgtmZaFcSYMGsGv)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrJrO(tjr9bizKKtwrut811OgTMMe6iBKfDzK3YdSbgCzNpTNXdkCbxy2jPka3gboAJ25EgpOWfCHzNKQaCBe0zc)hsoOlP9AmJhu4TCaRGFJKx2z5bDnbLaBWWaKpcYbqhzd50tZLDwOJN8aB0vKMl7Sqhpke8P7uARKsgyeddq(iihaDKnKtpnx2zHoEYdSr)uAVgZ4bfElhWkqpgu4MGsGv)PKGlm7KupSOs81xJz8GcVLdyfmOljT4s3eucC9Dkf1bjg6QhfdiT4sxJ6pLe05m(3gu4IVUgdWra8clxWfMDsQhwujkIFAPKsQrRPjHoYgzrxg5T8aN)ks71ygpOWB5awbaOJSPjpT7)oUKpMGsGv)PKGlm7KupSOs8clxJ6pLe13jzKK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fw(AmJhu4TCaRav(qgj5uimintqjWQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clFnMXdk8woGvGkvnQab5hMGsGv)PKGlm7KupSOs81xJz8GcVLdyfOceXtM(LwMGsGv)PKGlm7KupSOs81xJz8GcVLdyfKqfPceXZeucS6pLeCHzNK6HfvIV(AmJhu4TCaRa2XuBkgqIzaatqjWQ)usWfMDsQhwuj(6RXmEqH3YbSc(nsIg62mbLaR(tjbxy2jPEyrL4RVgZ4bfElhWk43ijAORjukr4r68LaFaWpepr1KQ87GmbLaR(tjbxy2jPEyrL4RRKs4iaEHLl4cZoj1dlQefDzK3ui4tDknps9NsIj(4mzKKtgjV8bs81xJz8GcVLdyf8BKen01eNVey6QRvrmGmQNZoMmbLaJJa4fwUGlm7KupSOsu0LrElpWgOSILt(i3BMleRcqcwxgU83iTxJz8GcVLdyf8BKen01eNVe4xr8lHksAMAncWeucmocGxy5cUWSts9WIkrrxg5nfc20ksjLmcZCHyvasW6YWL)gbwzLuYGbDjWksJzUqSkajsOwgYpKHo5ubwzn13PuuhKOH0Zcx2MOUAVgZ4bfElhWk43ijAORjoFjWT4dirhoAOYeucmocGxy5cUWSts9WIkrrxg5nfcwXuKskzeM5cXQaKG1LHl)ncSYRXmEqH3YbSc(nsIg6AIZxc8bGw6zYij5wdDra8Gc3eucmocGxy5cUWSts9WIkrrxg5nfc20ksjLmcZCHyvasW6YWL)gbwzLuYGbDjWksJzUqSkajsOwgYpKHo5ubwzn13PuuhKOH0Zcx2MOUAVgZ4bfElhWk43ijAORjoFjWxgZQfjBzenY7VHWMGsGXra8clxWfMDsQhwujk6YiVLh4tPXaJWmxiwfGejuld5hYqNCQaRSsknOlPqftrAVgZ4bfElhWk43ijAORjoFjWxgZQfjBzenY7VHWMGsGXra8clxWfMDsQhwujk6YiVLh4tPXmxiwfGejuld5hYqNCQaRSg1FkjQVtYij1dlQeFDnQ)usuFNKrsQhwujk6YiVLhyduwr5ZNk3xFNsrDqIgsplCzBI6QTMbDP8umfTgZ4bfElhWkaZaasgpOWLaO2yIZxcmhKjTPq4bSYMGsGz8GmtsYPlIAk00RXmEqH3YbScWmaGKXdkCjaQnM48LaNX1nCTmPnfcpGv2eucmomto7JaeTke7AQVtPOoibxy2jjYtihnAPzyaYhr9DsgjPEyr1ACUBHNKrlmHAzi)yHHo5uTqv6a5TfAHMSfMVJ8BHS)wyc1YO2ctrTqJYOwOEf42cNyH)gTW3Vq(XcpjgtLcYT8BnMXdk8woGvaMbaKmEqHlbqTXeNVe4eQLH8dzOtovM0McHhWkBckb2mxiwfGezSzsg6KtpWksJzUqSkajsOwgYpKHo5uTgZ4bfElhWkaZaasgpOWLaO2yIZxcCOtovM0McHhWkBckb2mxiwfGezSzsg6KtpWkAnMXdk8woGvaMbaKmEqHlbqTXeNVey(kB681K2ui8awztqjWnAgKF0e8v205lyLxJz8GcVLdyfGzaajJhu4sauBmX5lbghbWlS82AmJhu4TCaRamdaiz8GcxcGAJjoFjWvm8Gc3K2ui8awztqjWM5cXQaKiHCgqQ(lhSIwJz8GcVLdyfGzaajJhu4sauBmX5lboHCgqQ(l3K2ui8awztqjWM5cXQaKiHCgqQ(lhSYRXmEqH3YbScWmaGKXdkCjaQnM48LaFdZ0L8znEno3TqgpOWBc(kB68fmMDmbiz8Gc3eucmJhu4cYCG5bfUaNXUtai)qZLDwOJhfcwXFQ1ygpOWBc(kB68nhWkGmhyEqHBckb(Yol0XtEGnZfIvbibzoK64rJb4iaEHLlM4JZKrsozK8Yhirrxg5T8aZ4bfUGmhyEqHlOZe(pKCqxsjLWra8clxWfMDsQhwujk6YiVLhygpOWfK5aZdkCbDMW)HKd6skPKbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWmEqHliZbMhu4c6mH)djh0L0wBnQ)usuFNKrsQhwujEHLRr9NscUWSts9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clFnMXdk8MGVYMoFZbScEepzQr5KjOeyCeaVWYfCHzNK6HfvIIUmYBGvKgdu)PKO(ojJKupSOs8clxJb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUkPeocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0w71ygpOWBc(kB68nhWk4IQkQMmsYjQl5JjOeyCeaVWYfCHzNK6HfvIIUmYBGvKgdu)PKO(ojJKupSOs8clxJb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUkPeocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0w71ygpOWBc(kB68nhWkO4hI9r205cK1ygpOWBc(kB68nhWkOLHsdYpK6HfvMGsGv)PKGlm7KupSOs8clxdocGxy5cUWSts9WIkXuFsw0LrEtHmEqHlAzO0G8dPEyrLa)knQ)usuFNKrsQhwujEHLRbhbWlSCr9DsgjPEyrLyQpjl6YiVPqgpOWfTmuAq(HupSOsGFLMhP(tjXeFCMmsYjJKx(ajEHLVgZ4bfEtWxztNV5awb13jzKK6HfvMGsGv)PKO(ojJKupSOs8clxdocGxy5cUWSts9WIkrrxg5T1ygpOWBc(kB68nhWkyIpotgj5KrYlFGmbLaBaocGxy5cUWSts9WIkrrxg5nWksJ6pLe13jzKK6HfvIxy5ARKs6fzwEGFcLf13jzKK6HfvRXmEqH3e8v205BoGvWeFCMmsYjJKx(azckbghbWlSCbxy2jPEyrLOOlJ8wENsrAu)PKO(ojJKupSOs8clxd1AKJjHzudfUmssDQseEqHliNvbO3AmJhu4nbFLnD(MdyfWfMDsQhwuzckbw9NsI67Kmss9WIkXlSCn4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyURXmEqH3e8v205BoGvaxy2jPkxfFqMGsGv)PKGlm7KupSOs811O(tjbxy2jPEyrLOOlJ8wEGz8GcxWfMDsErTgcGAc6mH)djh0L0O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdYAmJhu4nbFLnD(MdyfWfMDsgLQjOey1Fkj4cZojXzCDqI2WyqYt9NscUWStsCgxhK4YNLTHXGOr9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3e8v205BoGvaxy2jPkxfFqMGsGv)PKO(ojJKupSOs8clxJ6pLeCHzNK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fwUg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2WyqwJz8GcVj4RSPZ3CaRaUWStYlQ1qauZeucS6pLeyaIlm3gKFikIXJj4mg5Gv2eIlaTK4mg5sucS6pLeyaIlm3gKFiXzS7eG4fwUgdu)PKGlm7KupSOs81vsj1FkjQVtYij1dlQeFDLuchbWlSCbzoW8Gcxue)0s71ygpOWBc(kB68nhWkGlm7K8IAnea1mbLaBe8PfvOHeCHzNK6)7Laq(HGCwfGEkPK6pLeyaIlm3gKFiXzS7eG4fwUj4mg5Gv2eIlaTK4mg5sucS6pLeyaIlm3gKFiXzS7eG4fwUgdu)PKGlm7KupSOs81vsj1FkjQVtYij1dlQeFDLuchbWlSCbzoW8Gcxue)0s71ygpOWBc(kB68nhWkGmhyEqHBckbw9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3e8v205BoGvaxy2jzuQMGsGv)PKGlm7KeNX1bjAdJbjp1Fkj4cZojXzCDqIlFw2ggdYAmJhu4nbFLnD(MdyfWfMDsQYvXh0AmJhu4nbFLnD(MdyfWfMDsQcWTznEnMXdk8MGdcCQI2OgaJjOe467ukQds8qnmsha5CPLeh3l7pn4iaEHLlu)PK8HAyKoaY5sljoUx2FII4NwAu)PK4HAyKoaY5sljoUx2FYufTr8clxJbQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clxBn4iaEHLlM4JZKrsozK8Yhirrxg5nWksJbQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAAmWGHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLh4d8tdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKsgyeddq(iQVtYij1dlQ0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPeocGxy5cUWSts9WIkrrxg5T8aFGFAR9AmJhu4nbhuoGvqcvKufGBJjOeydQVtPOoiXd1WiDaKZLwsCCVS)0GJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFAPr9NsIhQHr6aiNlTK44Ez)jtOIeVWY1OxKz5b(juwKQOnQbWOTskzq9Dkf1bjEOggPdGCU0sIJ7L9NMbDP8uw71ygpOWBcoOCaRGufTr6Hz2eucC9Dkf1bjokudqljcJWaKgCeaVWYfCHzNK6HfvIIUmYBkuXuKgCeaVWYft8XzYijNmsE5dKOOlJ8gyfPXa1Fkj4cZojXzCDqI2WyqYdSzUqSkaj4GKtmx5LplXzCDqnngyWWaKpI67Kmss9WIkn4iaEHLlQVtYij1dlQefDzK3Yd8b(PbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDTvsjdmIHbiFe13jzKK6HfvAWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswxBLuchbWlSCbxy2jPEyrLOOlJ8wEGpWpT1EnMXdk8MGdkhWkivrBKEyMnbLaxFNsrDqIJc1a0sIWimaPbhbWlSCbxy2jPEyrLOOlJ8gyfPXadmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiARKsgGJa4fwUyIpotgj5KrYlFGefDzK3aRinQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAARTg1FkjQVtYij1dlQeVWY1EnMXdk8MGdkhWkyIpotgj5KrYlFGmbLaxFNsrDqIgsplCzBI6QrViZYd8tOSGmhyEqHVgZ4bfEtWbLdyfWfMDsQhwuzckbU(oLI6GenKEw4Y2e1vJb6fzwEGFcLfK5aZdkCLusViZYd8tOSyIpotgj5KrYlFG0EnMXdk8MGdkhWkGmhyEqHBckbEqxsHkMI0uFNsrDqIgsplCzBI6Qr9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutdocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0GJa4fwUGlm7KupSOsu0LrElpWh43AmJhu4nbhuoGvazoW8Gc3euc8GUKcvmfPP(oLI6GenKEw4Y2e1vdocGxy5cUWSts9WIkrrxg5nWksJbgyaocGxy5Ij(4mzKKtgjV8bsu0LrEtHM5cXQaKG1Lx(S8raSwYuuYjMRg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0wjLmahbWlSCXeFCMmsYjJKx(ajk6YiVbwrAu)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10wBnQ)usuFNKrsQhwujEHLRTjiFOQ(6JeLaR(tjrdPNfUSnrDfTHXGaw9NsIgsplCzBI6kU8zzBymiMG8HQ6Rps09spepeyLxJz8GcVj4GYbScUOQIQjJKCI6s(yckb2aCeaVWYfCHzNK6HfvIIUmYBkm)pLskHJa4fwUGlm7KupSOsu0LrElpWkM2AWra8clxmXhNjJKCYi5LpqIIUmYBGvKgdu)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10yGbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWh4NgCeaVWYfCHzNK6HfvIIUmYBk8uARKsgyeddq(iQVtYij1dlQ0GJa4fwUGlm7KupSOsu0LrEtHNsBLuchbWlSCbxy2jPEyrLOOlJ8wEGpWpT1EnMXdk8MGdkhWkO4hI9r205cetqjW4iaEHLlM4JZKrsozK8Yhirrxg5T8OZe(pKCqxsJbQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAAmWGHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLh4d8tdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6ARKsgyeddq(iQVtYij1dlQ0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPeocGxy5cUWSts9WIkrrxg5T8aFGFAR9AmJhu4nbhuoGvqXpe7JSPZfiMGsGXra8clxWfMDsQhwujk6YiVLhDMW)HKd6sAmWadWra8clxmXhNjJKCYi5LpqIIUmYBk0mxiwfGeSU8YNLpcG1sMIsoXC1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kPKb4iaEHLlM4JZKrsozK8Yhirrxg5nWksJ6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOM2ARr9NsI67Kmss9WIkXlSCTxJz8GcVj4GYbScEepzQr5KjOeyCeaVWYfCHzNK6HfvIIUmYBGvKgdmWaCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbibRlV8z5JayTKPOKtmxnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOTskzaocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0O(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPT2Au)PKO(ojJKupSOs8clx71ygpOWBcoOCaRGj(4mzKKtgjV8bYeucS6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOMgdmyyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5b(a)0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPKbgXWaKpI67Kmss9WIkn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTskHJa4fwUGlm7KupSOsu0LrElpWh4N2RXmEqH3eCq5awbCHzNK6HfvMGsGnWaCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbibRlV8z5JayTKPOKtmxnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOTskzaocGxy5Ij(4mzKKtgjV8bsu0LrEdSI0O(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPT2Au)PKO(ojJKupSOs8clFnMXdk8MGdkhWkO(ojJKupSOYeucS6pLe13jzKK6HfvIxy5AmWaCeaVWYft8XzYijNmsE5dKOOlJ8McnTI0O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kPKb4iaEHLlM4JZKrsozK8Yhirrxg5nWksJ6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOM2ARXaCeaVWYfCHzNK6HfvIIUmYBkuztRKsps9NsIj(4mzKKtgjV8bs811EnMXdk8MGdkhWkOLHsdYpK6HfvMGsGXra8clxWfMDsgLQOOlJ8McpLskzeddq(i4cZojJsDnMXdk8MGdkhWkqVOg5ysgj5f5ptqjWQ)us8iEYuJYjXxxZJu)PKyIpotgj5KrYlFGeFDnps9NsIj(4mzKKtgjV8bsu0LrElpWQ)usOxuJCmjJK8I8N4YNLTHXGK7z8GcxWfMDsQcWTrqNj8Fi5GUKgdmyyaYhrrTWzhtAy8GmtsYPlIA5L)ARKsmEqMjj50frT8oL2AmWiQVtPOoibxy2jPACv56DjFusPHRdAezedmzcD8Oqf7uAVgZ4bfEtWbLdyfWfMDsQcWTXeucS6pLepINm1OCs811yGbddq(ikQfo7ysdJhKzssoDrulV8xBLuIXdYmjjNUiQL3P0wJbgr9Dkf1bj4cZojvJRkxVl5JsknCDqJiJyGjtOJhfQyNs71ygpOWBcoOCaRG2xNkpmZRXmEqH3eCq5awbCHzNKQCv8bzckbw9NscUWStsCgxhKOnmgefc2agpiZKKC6IOw(SYARP(oLI6GeCHzNKQXvLR3L8rZW1bnImIbMmHoEYtXo1AmJhu4nbhuoGvaxy2jPkxfFqMGsGv)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbznMXdk8MGdkhWkGlm7KmkvtqjWQ)usWfMDsIZ46GeTHXGawrRXmEqH3eCq5awbonzujh6QtTXeucSbfLkQLXQaKskzedcdcYp0wJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiRXmEqH3eCq5awbCHzNKxuRHaOMjOey1FkjWaexyUni)queJhn13PuuhKGlm7Ke5jKJgT0yGbddq(i4RoakHW8GcxdJhKzssoDrulpJU2kPeJhKzssoDrulVtP9AmJhu4nbhuoGvaxy2j5f1AiaQzckbw9NscmaXfMBdYpefX4rZWaKpcUWStscNfAEK6pLet8XzYijNmsE5dK4RRXGHbiFe8vhaLqyEqHRKsmEqMjj50frT8u8AVgZ4bfEtWbLdyfWfMDsErTgcGAMGsGv)PKadqCH52G8drrmE0mma5JGV6aOecZdkCnmEqMjj50frT8Y)1ygpOWBcoOCaRaUWSts6Soq0qHBckbw9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiRXmEqH3eCq5awbCHzNK0zDGOHc3eucS6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiA0lYS8a)ekl4cZojv5Q4dAnMXdk8MGdkhWkGmhyEqHBcYhQQV(irjWx2zHoEuiyf)Pmb5dv1xFKO7LEiEiWkVgVgN7wy(vOOqd60Iw4VH8JfEuOgGwleHryaAHwOjBHSUyHgnnAHOzHwOjBHtm3fgtgvwOgjwJz8GcVjWra8clVbovrBKEyMnbLaxFNsrDqIJc1a0sIWimaPbhbWlSCbxy2jPEyrLOOlJ8McvmfPbhbWlSCXeFCMmsYjJKx(ajk6YiVbwrAmq9NscUWStsCgxhKOnmgK8aBMleRcqIjMR8YNL4mUoOMgdmyyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5b(a)0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kPKbgXWaKpI67Kmss9WIkn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTskHJa4fwUGlm7KupSOsu0LrElpWh4N2AVgZ4bfEtGJa4fwElhWkivrBKEyMnbLaxFNsrDqIJc1a0sIWimaPbhbWlSCbxy2jPEyrLOOlJ8gyfPXaJyyaYhb5aOJSHC6PKsgmma5JGCa0r2qo90CzNf64rHGZhksBT1yGb4iaEHLlM4JZKrsozK8Yhirrxg5nfQSI0O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kPKb4iaEHLlM4JZKrsozK8Yhirrxg5nWksJ6pLeCHzNK4mUoirBymiGvK2ARr9NsI67Kmss9WIkXlSCnx2zHoEuiyZCHyvasW6YlYr3)vEzNL64znMXdk8MahbWlS8woGvqQI2OgaJjOe467ukQds8qnmsha5CPLeh3l7pn4iaEHLlu)PK8HAyKoaY5sljoUx2FII4NwAu)PK4HAyKoaY5sljoUx2FYufTr8clxJbQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clxBn4iaEHLlM4JZKrsozK8Yhirrxg5nWksJbQ)usWfMDsIZ46GeTHXGKhyZCHyvasmXCLx(SeNX1b10yGbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWh4NgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wjLmWiggG8ruFNKrsQhwuPbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDTvsjCeaVWYfCHzNK6HfvIIUmYB5b(a)0w71ygpOWBcCeaVWYB5awbjursvaUnMGsGRVtPOoiXd1WiDaKZLwsCCVS)0GJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFAPr9NsIhQHr6aiNlTK44Ez)jtOIeVWY1OxKz5b(juwKQOnQbWSgN7wy(XOAHMQ4KfAHMSfMB53crPfIgdBlehxKFSWV(cBr4IfE6tlenl0cbaSqvAH)g9wOfAYw4jXyQmzHyUnlenlSbGoYgaTwOkLIIwJz8GcVjWra8clVLdyfCrvfvtgj5e1L8XeucmocGxy5Ij(4mzKKtgjV8bsu0LrElpZCHyvasCJrQxeMONCI5kv1sjLmahbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXng5LplFeaRLmfLK11GJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajUXiV8z5JayTKPOKtmxTxJz8GcVjWra8clVLdyfCrvfvtgj5e1L8XeucmocGxy5cUWSts9WIkrr8tlngyeddq(iihaDKnKtpLuYGHbiFeKdGoYgYPNMl7SqhpkeC(qrARTgdmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiARKsgGJa4fwUyIpotgj5KrYlFGefDzK3aRinQ)usWfMDsIZ46GeTHXGawrARTg1FkjQVtYij1dlQeVWY1CzNf64rHGnZfIvbibRlVihD)x5LDwQJN14C3cZnalwR2c)nAHpINm1OCAHwOjBHSUyHN(0cNyUle1wyr8tRfYTfAraaMSWldcTW2VOfoXcXCBwiAwOkLIIw4eZvSgZ4bfEtGJa4fwElhWk4r8KPgLtMGsGXra8clxmXhNjJKCYi5LpqIIUmYBGvKg1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GAAWra8clxWfMDsQhwujk6YiVLh4d8BnMXdk8MahbWlS8woGvWJ4jtnkNmbLaJJa4fwUGlm7KupSOsu0LrEdSI0yGrmma5JGCa0r2qo9usjdggG8rqoa6iBiNEAUSZcD8OqW5dfPT2AmWaCeaVWYft8XzYijNmsE5dKOOlJ8McvwrAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrBLuYaCeaVWYft8XzYijNmsE5dKOOlJ8gyfPr9NscUWStsCgxhKOnmgeWksBT1O(tjr9DsgjPEyrL4fwUMl7SqhpkeSzUqSkajyD5f5O7)kVSZsD8SgN7wOrtJwytNlqwikTWjM7cz)TqwFHCrlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAzYcVmii)yHTFrl0IwygBMwipleG42SWXkwixy2PfIZ46GAlK93cNmEw4eZDHwCZnCw4PD)2SWFJEI1ygpOWBcCeaVWYB5awbf)qSpYMoxGyckbghbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasun5LplFeaRLmfLCI5QbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbir1Kx(S8raSwYuuswxJbddq(iQVtYij1dlQ0yaocGxy5I67Kmss9WIkrrxg5T8OZe(pKCqxsjLWra8clxuFNKrsQhwujk6YiVPqZCHyvasun5LplFeaRLmfLScDTvsjJyyaYhr9DsgjPEyrL2Au)PKGlm7KeNX1bjAdJbrHMwZJu)PKyIpotgj5KrYlFGeVWY1O(tjr9DsgjPEyrL4fwUg1Fkj4cZoj1dlQeVWYxJZDl0OPrlSPZfil0cnzlK1xOvg5lupAnKkajw4PpTWjM7crTfwe)0AHCBHweaGjl8YGqlS9lAHtSqm3MfIMfQsPOOfoXCfRXmEqH3e4iaEHL3YbSck(HyFKnDUaXeucmocGxy5Ij(4mzKKtgjV8bsu0LrElp6mH)djh0L0O(tjbxy2jjoJRds0ggdsEGnZfIvbiXeZvE5ZsCgxhutdocGxy5cUWSts9WIkrrxg5T8mGot4)qYbDPCy8GcxmXhNjJKCYi5Lpqc6mH)djh0L0EnMXdk8MahbWlS8woGvqXpe7JSPZfiMGsGXra8clxWfMDsQhwujk6YiVLhDMW)HKd6sAmWaJyyaYhb5aOJSHC6PKsgmma5JGCa0r2qo90CzNf64rHGZhksBT1yGb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrBLuYaCeaVWYft8XzYijNmsE5dKOOlJ8gyfPr9NscUWStsCgxhKOnmgeWksBT1O(tjr9DsgjPEyrL4fwUMl7SqhpkeSzUqSkajyD5f5O7)kVSZsD8O9ACUBHgnnAHtm3fAHMSfY6leLwiAmSTql0KH8foz0cV85f(iawlXcp9Pf6XyYc)nAHwOjBHvOVquAHtgTWHbiFwiQTWHbHCtwi7VfIgdBl0cnziFHtgTWlFEHpcG1sSgZ4bfEtGJa4fwElhWkyIpotgj5KrYlFGmbLaR(tjbxy2jjoJRds0ggdsEGnZfIvbiXeZvE5ZsCgxhutdocGxy5cUWSts9WIkrrxg5T8atNj8Fi5GUKMl7Sqhpk0mxiwfGeSU8IC09FLx2zPoE0O(tjr9DsgjPEyrL4fw(AmJhu4nbocGxy5TCaRGj(4mzKKtgjV8bYeucS6pLeCHzNK4mUoirBymi5b2mxiwfGetmx5LplXzCDqnnddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpW0zc)hsoOlPbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDn4iaEHLl4cZoj1dlQefDzK3uOYMEnMXdk8MahbWlS8woGvWeFCMmsYjJKx(azckbw9NscUWStsCgxhKOnmgK8aBMleRcqIjMR8YNL4mUoOMgdmIHbiFe13jzKK6HfvkPeocGxy5I67Kmss9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIswHU2AWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswFno3TqJMgTqwFHO0cNyUle1wy4le)wi7VfAfUHZcvPf(1xykQfce(bvlCYyFHtgTWlFEHpcG1YKfEzqq(XcB)Iw4KXZcTOfMXMPfsE8pYw4LDEHS)w4KXZcNmQOfIAl0JzHmqr8tRfYlS(oTWiTq9WIQf(clxSgZ4bfEtGJa4fwElhWkGlm7KupSOYeucmocGxy5Ij(4mzKKtgjV8bsu0LrEtHM5cXQaKG1Lx(S8raSwYuuYjMRgdmcCyMC2hHzYNmTkLuchbWlSCXfvvunzKKtuxYhrrxg5nfAMleRcqcwxE5ZYhbWAjtrjVXOTg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0O(tjr9DsgjPEyrL4fwUMl7SqhpkeSzUqSkajyD5f5O7)kVSZsD8SgN7wOrtJwyf6leLw4eZDHO2cdFH43cz)TqRWnCwOkTWV(ctrTqGWpOAHtg7lCYOfE5Zl8raSwMSWldcYpwy7x0cNmQOfIAUHZczGI4NwlKxy9DAHVWYxi7Vfoz8SqwFHwHB4SqvchxAHSzgbWQa0cF)c5hlS(ojwJz8GcVjWra8clVLdyfuFNKrsQhwuzckbw9NscUWSts9WIkXlSCngGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajQqxE5ZYhbWAjtrjNyUkPeocGxy5cUWSts9WIkrrxg5T8aBMleRcqIjMR8YNLpcG1sMIsY6ARr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgen4iaEHLl4cZoj1dlQefDzK3uOYMEnMXdk8MahbWlS8woGvqldLgKFi1dlQmbLaR(tjbxy2jPEyrL4fwUgCeaVWYfCHzNK6HfvIP(KSOlJ8Mcz8Gcx0YqPb5hs9WIkb(vAu)PKO(ojJKupSOs8clxdocGxy5I67Kmss9WIkXuFsw0LrEtHmEqHlAzO0G8dPEyrLa)knps9NsIj(4mzKKtgjV8bs8clFno3TqJMgTq94UWjwylF9j60Iwi7lKopfVqwDHiFHtgTqNoplehbWlS8fAH8xyzYc)oa1AleeTke7lCYiFHHdO1cF)c5hlKlm70c1dlQw47tlCIfMfwl8YoVWSVFuATWIFi2Nf205cKfIARXmEqH3e4iaEHL3YbSc0lQroMKrsEr(Zeuc8WaKpI67Kmss9WIknQ)usWfMDsQhwuj(6Au)PKO(ojJKupSOsu0LrElVd8tC5ZRXmEqH3e4iaEHL3YbSc0lQroMKrsEr(Zeuc8Ju)PKyIpotgj5KrYlFGeFDnps9NsIj(4mzKKtgjV8bsu0LrElpgpOWfCHzNKxuRHaOMGot4)qYbDjngbomto7JaeTke7RXmEqH3e4iaEHL3YbSc0lQroMKrsEr(ZeucS6pLe13jzKK6HfvIVUg1FkjQVtYij1dlQefDzK3Y7a)ex(SgCeaVWYfK5aZdkCrr8tln4iaEHLlM4JZKrsozK8Yhirrxg5nngbomto7JaeTke7RXRXmEqH3ejKZas1F55awbCHzNKxuRHaOMjOey1FkjWaexyUni)queJhtWzmYbR8AmJhu4nrc5mGu9xEoGvaxy2jPka3M1ygpOWBIeYzaP6V8CaRaUWStsvUk(GwJxJZDlmFkJ8fwF3r(Xcj0Kr1cNmAH22lmQfEs(0cbOdYFCHOMjl0IwOf7ZcNyHNgZXcvPuu0cNmAHNeJPsb5w(TqlK)clXcnAA0crZc52cBr4lKBlmFh53cZ42ctih1YO3cJFTqlYqZ0cB6Kplm(1cXzCDqT1ygpOWBIeQLH8dzOtovGjZbMhu4MGsGnO(oLI6GenKEw4Y2e1vjLQVtPOoiXqx9OyaPfx6ARXa1FkjQVtYij1dlQeVWYvsj9ImlpWpHYcUWStsvUk(G0wdocGxy5I67Kmss9WIkrrxg5T14C3cp9PfArgAMwyc5Owg9wy8RfIJa4fw(cTq(lSAlK93cB6Kplm(1cXzCDqntwOEHIcnOtlAHNgZXcdZuTqYmvAnzi)yHeqJwJz8GcVjsOwgYpKHo5uLdyfqMdmpOWnbLapma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5nn4iaEHLl4cZoj1dlQefDzK30O(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQeVWY1OxKz5b(juwWfMDsQYvXh0AmJhu4nrc1Yq(Hm0jNQCaRGeQiPka3gtqjW13PuuhK4HAyKoaY5sljoUx2FAu)PK4HAyKoaY5sljoUx2FYufTr81xJz8GcVjsOwgYpKHo5uLdyfKQOnspmZMGsGRVtPOoiXrHAaAjryegG0CzNf64rHk(tTgZ4bfEtKqTmKFidDYPkhWk4r8KPgLtMGsGnI67ukQds0q6zHlBtuxngr9Dkf1bjg6QhfdiT4sFnMXdk8MiHAzi)qg6KtvoGvaxy2jzuQMGsGXra8clxuFNKrsQhwujkIFATgZ4bfEtKqTmKFidDYPkhWkGlm7KufGBJjOeyCeaVWYf13jzKK6HfvII4NwAu)PKGlm7KeNX1bjAdJbjp1Fkj4cZojXzCDqIlFw2ggdYAmJhu4nrc1Yq(Hm0jNQCaRG67Kmss9WIQ14C3cp9PfArgw0c5zHx(8cBdJbPTWiTqJYOwi7VfArlmJntUHZc)n6TqtvCYc1Igtw4VrlKxyBymilCIfQxKzYNfE)ood5hRXmEqH3ejuld5hYqNCQYbSc4cZojVOwdbqntqjWQ)usGbiUWCBq(HOigpAu)PKadqCH52G8drBymiGv)PKadqCH52G8dXLplBdJbrdomto7JWm5tMwLgCeaVWYfxuvr1KrsorDjFefXpTwJZDleurDzaaTwOfTqDgvlupgu4l83OfAHMSfMB5Njlu9plenl0cbaSqaUnlei8JfsE8pYwykQfQgt2cNmAH57i)wi7VfMB53cTq(lSAl87auRTW67oYpw4Krl02EHrTWtYNwiaDq(Jle1wJz8GcVjsOwgYpKHo5uLdyfOhdkCtqjWgHb13PuuhKOH0Zcx2MOUkPu9Dkf1bjg6QhfdiT4sx71ygpOWBIeQLH8dzOtov5awbpINm1OCYeucS6pLe13jzKK6HfvIxy5kPKErMLh4Nqzbxy2jPkxfFqRXmEqH3ejuld5hYqNCQYbSck(HyFKnDUaXeucS6pLe13jzKK6HfvIxy5kPKErMLh4Nqzbxy2jPkxfFqRXmEqH3ejuld5hYqNCQYbScUOQIQjJKCI6s(yckbw9NsI67Kmss9WIkXlSCLusViZYd8tOSGlm7KuLRIpO1y8GcVjsOwgYpKHo5uLdyfmXhNjJKCYi5LpqMGsGv)PKO(ojJKupSOs8clxjL0lYS8a)ekl4cZojv5Q4dsjL0lYS8a)eklUOQIQjJKCI6s(OKs6fzwEGFcLff)qSpYMoxGOKs6fzwEGFcLfpINm1OCAnMXdk8MiHAzi)qg6KtvoGvaxy2jPEyrLjOey9ImlpWpHYIj(4mzKKtgjV8bAno3TqJMgTW8lmvlCIf2YxFIoTOfY(cPZtXlm3km70cbna3Mf((fYpw4Krl8Kymvki3YVfAH8xyTWVdqT2cRV7i)yH5wHzNw4PbNfIfE6tlm3km70cpn4SyHO2chgG8HEMSqlAHy2nCw4Vrlm)ct1cTqtgYx4Krl8Kymvki3YVfAH8xyTWVdqT2cTOfI8HQ6RplCYOfMBMQfIZy3jatwylwOfziaWcBSzAHOrSgZ4bfEtKqTmKFidDYPkhWkqVOg5ysgj5f5ptqjWgXWaKpcUWStscNfAEK6pLet8XzYijNmsE5dK4RR5rQ)usmXhNjJKCYi5LpqIIUmYB5b2agpOWfCHzNKQaCBe0zc)hsoOlL7v)PKqVOg5ysgj5f5pXLplBdJbr714C3cp9PfMFHPAHzCZnCwOkr(c)n6TW3Vq(XcNmAHNeJPAHwi)fwMSqlYqaGf(B0crZcNyHT81NOtlAHSVq68u8cZTcZoTqqdWTzHiFHtgTW8DKFki3YVfAH8xyjwJz8GcVjsOwgYpKHo5uLdyfOxuJCmjJK8I8NjOey1Fkj4cZoj1dlQeFDnQ)usuFNKrsQhwujk6YiVLhydy8GcxWfMDsQcWTrqNj8Fi5GUuUx9Nsc9IAKJjzKKxK)ex(SSnmgeTxJz8GcVjsOwgYpKHo5uLdyfWfMDsQcWTXeuc8lgrXpe7JSPZfiIIUmYBk8ukP0Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyquOIwJZDlmFIwOf7ZcNyHxgeAHTFrl0IwygBMwi5X)iBHx25fMIAHtgTqYhurlm3YVfAH8xyzYcjZKVquAHtgvKHTf2geaWch0Lwyrxg5i)yHHVW8DKFIfE6hdBlmCaTwOkndvlCIfQ(lFHtSWtlQIfY(BHNgZXcrPfwF3r(XcNmAH22lmQfEs(0cbOdYFCHOMynMXdk8MiHAzi)qg6KtvoGvaxy2jPkxfFqMGsGXra8clxWfMDsQhwujkIFAP5Yol0XtEgK)kkhduwr5ECyMC2hbiAvi21wBnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOXiQVtPOoirdPNfUSnrD1ye13PuuhKyOREumG0Il914C3cnACaQ1wy9Dh5hlCYOfMBfMDAHkoUUHR1cbOdYFCPLjle0Cv8bTWww8bEl0JzHQ0c)n6TqEw4KrlK83cJ0cZT8BHO0cpnMdmpOWxiQTWiLwiocGxy5lKBl8vHUoYpwioJRdQTqleaWcVmi0crZchgeAHaHFq1cNyHQ)Yx4KvX)iBHfDzKJ8JfEzNxJz8GcVjsOwgYpKHo5uLdyfWfMDsQYvXhKjOey1Fkj4cZoj1dlQeFDnQ)usWfMDsQhwujk6YiVLh4d8tJb13PuuhKGlm7Ke5jKJgTusjCeaVWYfK5aZdkCrrxg5nTxJZDle0Cv8bTWww8bElKbSyTAluLw4KrleGBZcXCBwiYx4KrlmFh53cTq(lSwi3w4jXyQwOfcayHf1MOOfoz0cXzCDqTf20jFwJz8GcVjsOwgYpKHo5uLdyfWfMDsQYvXhKjOey1FkjQVtYij1dlQeFDnQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkrrxg5T8aFGFRXmEqH3ejuld5hYqNCQYbSc4cZojVOwdbqntqjWps9NsIj(4mzKKtgjV8bs811mma5JGlm7KKWzHgdu)PK4r8KPgLtIxy5kPeJhKzssoDrudSYAR5rQ)usmXhNjJKCYi5LpqIIUmYBkKXdkCbxy2j5f1AiaQjOZe(pKCqxYeCgJCWkBcXfGwsCgJCjkbw9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kPKbgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kPeocGxy5cYCG5bfUOi(PL2AR9ACUBHgToGwlSnCnl83q(XcnkJAH5MPAHwzKVWCl)wyg3wOkr(c)n6TgZ4bfEtKqTmKFidDYPkhWkGlm7K8IAnea1mbLaR(tjbgG4cZTb5hIIy8ObhbWlSCbxy2jPEyrLOOlJ8Mgdu)PKO(ojJKupSOs81vsj1Fkj4cZoj1dlQeFDTnbNXihSYRXmEqH3ejuld5hYqNCQYbSc4cZojJs1eucS6pLeCHzNK4mUoirBymi5b2mxiwfGetmx5LplXzCDqT1ygpOWBIeQLH8dzOtov5awbCHzNKQaCBmbLaR(tjr9DsgjPEyrL4RRKsx2zHoEuOYNAnMXdk8MiHAzi)qg6KtvoGvazoW8Gc3eucS6pLe13jzKK6HfvIxy5Au)PKGlm7KupSOs8cl3eKpuvF9rIsGVSZcD8OqWg9tzcYhQQV(ir3l9q8qGvEnMXdk8MiHAzi)qg6KtvoGvaxy2jPkxfFqRXRX5UC3cz8GcVjY46gUwGXSJjajJhu4MGsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk(tTgN7wOrtJw4PXCG5bf(crPfArgw0cbcRfg(cVSZlK93c5fEsmMkfKB53cTq(lSwiQTqCCr(Xc)6RXmEqH3ezCDdxRCaRaYCG5bfUjOe4l7Sqhp5bw5tPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhydOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjT1GJa4fwUGlm7KupSOsu0LrElpWgqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6s5W4bfUGlm7KupSOsqNj8Fi5GUK2Au)PKO(ojJKupSOs8clxJ6pLeCHzNK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fwUgJ4fJO4hI9r205cerrxg5T14C3cnAA0cpnMdmpOWxikTqlYWIwiqyTWWx4LDEHS)wiVW8DKFl0c5VWAHO2cXXf5hl8RVgZ4bfEtKX1nCTYbSciZbMhu4MGsGVSZcD8KhyftrAWra8clxuFNKrsQhwujk6YiVLhydOZe(pKCqxkhgpOWf13jzKK6Hfvc6mH)djh0L0wdocGxy5Ij(4mzKKtgjV8bsu0LrElpWgqNj8Fi5GUuomEqHlQVtYij1dlQe0zc)hsoOlLdJhu4IIFi2hztNlqe0zc)hsoOlPTgCeaVWYfCHzNK6HfvIIUmYBkm)v0AmJhu4nrgx3W1khWkGlm7KufGBJjOeyCeaVWYff)qSpYMoxGik6YiVLhytN7pWVCmZfIvbiHPwXj1lQnmgeKFih0LYHot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctTItQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVLhyZCHyvasyQvCs9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjnQ)usWfMDsIZ46GeTHXGOqL1O(tjbxy2jjoJRds0ggdsE5VgJah(7Jgbxy2jPEfp0HwRXmEqH3ezCDdxRCaRaUWStsvaUnMGsGXra8clxuFNKrsQhwujk6YiVLhytN7pWVCmZfIvbiHPwXj1lQnmgeKFih0LYHot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxsdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm1koPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMAfNuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDPCy8Gcxu8dX(iB6CbIGot4)qYbDjn4iaEHLl4cZoj1dlQefDzK30O(tjbxy2jjoJRds0ggdIcvwJ6pLeCHzNK4mUoirBymi5L)AmcC4VpAeCHzNK6v8qhATgZ4bfEtKX1nCTYbSc4cZojvb42yckbghbWlSCrXpe7JSPZfiIIUmYB5b205(d8lhZCHyvasyQvCs9IAdJbb5hYbDjn4iaEHLl4cZoj1dlQefDzK3uiyftrAWra8clxmXhNjJKCYi5LpqIIUmYB5OykkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhftr5bghbWlSCbxy2jPEyrLOOlJ8Mg1Fkj4cZojXzCDqI2WyquOYAu)PKGlm7KeNX1bjAdJbjV8xJrGd)9rJGlm7KuVIh6qR1ygpOWBImUUHRvoGvaxy2jPkxfFqMGsGXra8clxu8dX(iB6CbIOOlJ8wEGpWVCmZfIvbiHPwXj1lQnmgeKFih0LYHot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctTItQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVLhyZCHyvasyQvCs9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxkhgpOWft8XzYijNmsE5dKGot4)qYbDjnQ)usWfMDsIZ46GeTHXGOqLxJz8GcVjY46gUw5awbCHzNKQCv8bzckbghbWlSCr9DsgjPEyrLOOlJ8wEGpWVCmZfIvbiHPwXj1lQnmgeKFih0LYHot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxsdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm1koPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMAfNuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDPCy8Gcxu8dX(iB6CbIGot4)qYbDjn4iaEHLl4cZoj1dlQefDzK30O(tjbxy2jjoJRds0ggdIcvEnMXdk8MiJRB4ALdyfWfMDsQYvXhKjOeyCeaVWYff)qSpYMoxGik6YiVLh4d8lhZCHyvasyQvCs9IAdJbb5hYbDjn4iaEHLl4cZoj1dlQefDzK3uiyftrAWra8clxmXhNjJKCYi5LpqIIUmYB5OykkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhftr5bghbWlSCbxy2jPEyrLOOlJ8Mg1Fkj4cZojXzCDqI2WyquOYAmcC4VpAeCHzNK6v8qhATgN7wiO)iG3cvCCDdxRf2ggdsBHPOw4Krl8Kymvki3YVfAH8xyTgZ4bfEtKX1nCTYbSc4cZojVOwdbqntqjWQ)usWfMDsMX1nCTeTHXGKN6pLeCHzNKzCDdxlXLplBdJbrdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm1koPErTHXGG8d5GUuo0zc)hsoOlPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhyZCHyvasyQvCs9IAdJbb5hYbDPCOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxsdocGxy5cUWSts9WIkrrxg5T8aBMleRcqctTItQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6s5W4bfUyIpotgj5KrYlFGe0zc)hsoOlzcoJroyLxJZDle0FeWBHkoUUHR1cBdJbPTWuulCYOfMVJ8BHwi)fwRXmEqH3ezCDdxRCaRaUWStYlQ1qauZeucS6pLeCHzNKzCDdxlrBymi5P(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUO(ojJKupSOsu0LrElpWM5cXQaKWuR4K6f1ggdcYpKd6s5qNj8Fi5GUuomEqHlQVtYij1dlQe0zc)hsoOlPbhbWlSCrXpe7JSPZfiIIUmYB5b2mxiwfGeMAfNuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDjn4iaEHLlM4JZKrsozK8Yhirrxg5T8aBMleRcqctTItQxuBymii)qoOlLdDMW)HKd6s5W4bfUO(ojJKupSOsqNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUKgCeaVWYfCHzNK6HfvIIUmYBMGZyKdw514C3cb9hb8wOIJRB4ATW2WyqAlmf1cNmAHodc9wy(2EHwi)fwRXmEqH3ezCDdxRCaRaUWStYlQ1qauZeucS6pLeCHzNKzCDdxlrBymi5P(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUO4hI9r205cerrxg5T8aBMleRcqctTItQxuBymii)qoOlLdDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVPqWkMI0GJa4fwUO(ojJKupSOsu0LrEtHGvmfPXiWH)(OrWfMDsQxXdDOLj4mg5GvEnMXdk8MiJRB4ALdyfu8dX(iB6CbIjOey1Fkj4cZojXzCDqI2WyqYZ0Au)PKGlm7KmJRB4AjAdJbbS6pLeCHzNKzCDdxlXLplBdJbrdocGxy5Ij(4mzKKtgjV8bsu0LrElp6mH)djh0L0GJa4fwUGlm7KupSOsu0LrElpWgqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6sAR5Yol0XJcv(uRXmEqH3ezCDdxRCaRGj(4mzKKtgjV8bYeucS6pLeCHzNK4mUoirBymi5zAnQ)usWfMDsMX1nCTeTHXGaw9NscUWStYmUUHRL4YNLTHXGObhbWlSCbxy2jPEyrLOOlJ8wEGPZe(pKCqxsZlgrXpe7JSPZfiIIUmYBRXmEqH3ezCDdxRCaRaUWSts9WIktqjWQ)usWfMDsMX1nCTeTHXGaw9NscUWStYmUUHRL4YNLTHXGO5rQ)usmXhNjJKCYi5LpqIVUg1FkjQVtYij1dlQeVWYxJz8GcVjY46gUw5awb13jzKK6HfvMGsGv)PKGlm7KeNX1bjAdJbjptRr9NscUWStYmUUHRLOnmgeWQ)usWfMDsMX1nCTex(SSnmgen4iaEHLlk(HyFKnDUaru0LrElpW0zc)hsoOlPbhbWlSCXeFCMmsYjJKx(ajk6YiVLhydOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxsBn4iaEHLl4cZoj1dlQefDzK3uy(FQCmZfIvbiHPwXjFeaRfa6IgzULFAUSZcD8OqWk2PwJz8GcVjY46gUw5awbf)qSpYMoxGyckbw9NscUWStsCgxhKOnmgK8mTg1Fkj4cZojZ46gUwI2WyqaR(tjbxy2jzgx3W1sC5ZY2Wyq0GJa4fwUyIpotgj5KrYlFGefDzK3YJot4)qYbDjnQ)usuFNKrsQhwuj(6RXmEqH3ezCDdxRCaRGj(4mzKKtgjV8bYeucS6pLeCHzNKzCDdxlrBymiGv)PKGlm7KmJRB4AjU8zzBymiAu)PKO(ojJKupSOs8118Iru8dX(iB6CbIOOlJ82AmJhu4nrgx3W1khWkO(ojJKupSOYeucSb4iaEHLlM4JZKrsozK8Yhirrxg5TCY)tPDEGXra8clxWfMDsQhwujk6YiVPr9NscUWSts9WIkXlSCngbo83hncUWSts9kEOdTwJz8GcVjY46gUw5awbf)qSpYMoxGyckbw9NscUWStYmUUHRLOnmgeWQ)usWfMDsMX1nCTex(SSnmgen4iaEHLl4cZoj1dlQefDzK3uiyftrAWra8clxmXhNjJKCYi5LpqIIUmYB5OykkpW4iaEHLl4cZoj1dlQefDzK30GJa4fwUO(ojJKupSOsu0LrElhftr5bghbWlSCbxy2jPEyrLOOlJ8MMl7SqhpkeSYNsJrGd)9rJGlm7KuVIh6qR1ygpOWBImUUHRvoGvaxy2jzuQMGsGFXik(HyFKnDUaru0LrEtHNsZJu)PKO4hI9r205ceP5pGtfRIaqJwI2WyqaRinQ)usuFNKrsQhwujEHLVgZ4bfEtKX1nCTYbSc4cZojv5Q4dYeuc8Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqaN)RXmEqH3ezCDdxRCaRaUWStsvaUnMGsGFXik(HyFKnDUaru0LrEtZJu)PKyIpotgj5KrYlFGefDzK3uiDMW)HKd6sAm4rQ)usu8dX(iB6CbI08hWPIvraOrlrBymiGvKsk9i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgK8YFTxJz8GcVjY46gUw5awbCHzNKQaCBmbLa)Iru8dX(iB6CbIOOlJ8McPZe(pKCqxsZJu)PKO4hI9r205ceP5pGtfRIaqJwI2WyquOI08i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgK8YFnQ)usuFNKrsQhwujEHLVgZ4bfEtKX1nCTYbSc4cZojJs1eucS6pLeCHzNK4mUoirBymi5zAnQ)usWfMDsQhwuj(6RXmEqH3ezCDdxRCaRaUWStYlQ1qauZeucS6pLeyaIlm3gKFikIXJg1Fkj4cZoj1dlQeFDtWzmYbR8ACUBHgnnAH5xyQw47xi)yH5w(TWOwy(oYVfAH8xy1w4elu9JaEleNX1b1wiNgQw4VH8JfMBfMDAHGMRIpO1ygpOWBImUUHRvoGvGErnYXKmsYlYFMGsGv)PKGlm7KeNX1bjAdJbjp1Fkj4cZojXzCDqIlFw2ggdIg1Fkj4cZojXzCDqI2WyquOI0O(tjbxy2jPEyrLOOlJ8MskP(tjbxy2jjoJRds0ggdsEQ)usWfMDsIZ46Gex(SSnmgenQ)usWfMDsIZ46GeTHXGOqfPr9NsI67Kmss9WIkrrxg5nnps9NsIj(4mzKKtgjV8bsu0LrEBnMXdk8MiJRB4ALdyfWfMDsQcWTXeucS6pLe6f1ihtYijVi)j(6Au)PKGlm7KeNX1bjAdJbrHkVgZ4bfEtKX1nCTYbSc4cZojJs1eucS6pLeCHzNK4mUoirBymi5zAn4iaEHLl4cZoj1dlQefDzK3uiytRO8zJEU)a)0yegGJa4fwUO4hI9r205cerrxg5T8aRSI0GJa4fwUGlm7KupSOsu0LrEtHGZhNs71ygpOWBImUUHRvoGvaxy2jzuQMGsGv)PKGlm7KeNX1bjAdJbjptRbhbWlSCbxy2jPEyrLOOlJ8McbBAfLpB0Z9h4NgC4VpAeCHzNK6v8qhATgZ4bfEtKX1nCTYbSc4cZojVOwdbqntqjWQ)usWfMDsIZ46GeTHXGOqL1O(tjbxy2jzgx3W1s0ggdsEQ)usWfMDsMX1nCTex(SSnmgetWzmYbR8AmJhu4nrgx3W1khWkGlm7K8IAnea1mbLaJJa4fwUGlm7Kmkvrrxg5T8YFnQ)usWfMDsMX1nCTeTHXGKN6pLeCHzNKzCDdxlXLplBdJbXeCgJCWkVgZ4bfEtKX1nCTYbSc4cZojv5Q4dYeucS6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAu)PKGlm7KmJRB4AjAdJbbS6pLeCHzNKzCDdxlXLplBdJbznMXdk8MiJRB4ALdyfqMdmpOWnbLaFzNf64jpLp1ACUBH5tzKVqvASiYxiocGxy5l0c5VWQzYcTOfgoGwlu9JaElCIfM(aaleNX1b1wiNgQw4VH8JfMBfMDAHgTL6AmJhu4nrgx3W1khWkGlm7KufGBJjOey1Fkj4cZojXzCDqI2WyquOYRXmEqH3ezCDdxRCaRaUWStYlQ1qauZeCgJCWkVgVgZ4bfEtCdZ0L8jhWkqfa5GizxltqjW3WmDjFepuByhtkeSYkAnMXdk8M4gMPl5toGvGErnYXKmsYlYFRXmEqH3e3WmDjFYbSc4cZojVOwdbqntqjW3WmDjFepuByht5PSIwJz8GcVjUHz6s(KdyfWfMDsgL6AmJhu4nXnmtxYNCaRGeQiPka3M141ygpOWBIqNCQaNqfjvb42yckbU(oLI6GepudJ0bqoxAjXX9Y(tJ6pLepudJ0bqoxAjXX9Y(tMQOnIV(AmJhu4nrOtov5awbPkAJ0dZSjOe467ukQdsCuOgGwsegHbinx2zHoEuOI)uRXmEqH3eHo5uLdyf8iEYuJYP1ygpOWBIqNCQYbSck(HyFKnDUaXeuc8LDwOJhfM)kAnMXdk8Mi0jNQCaRGwgkni)qQhwuzckbw9NscUWSts9WIkXlSCn4iaEHLl4cZoj1dlQefDzK3wJz8GcVjcDYPkhWk4IQkQMmsYjQl5ZAmJhu4nrOtov5awbt8XzYijNmsE5d0AmJhu4nrOtov5awbCHzNK6HfvRXmEqH3eHo5uLdyfuFNKrsQhwuzckbw9NsI67Kmss9WIkXlS814C3cnAA0cZVWuTWjwylF9j60Iwi7lKopfVWCRWStle0aCBw47xi)yHtgTWtIXuPGCl)wOfYFH1c)oa1AlS(UJ8JfMBfMDAHNgCwiw4PpTWCRWStl80GZIfIAlCyaYh6zYcTOfIz3WzH)gTW8lmvl0cnziFHtgTWtIXuPGCl)wOfYFH1c)oa1Al0IwiYhQQV(SWjJwyUzQwioJDNamzHTyHwKHaalSXMPfIgXAmJhu4nrOtov5awb6f1ihtYijVi)zckb2iggG8rWfMDss4SqZJu)PKyIpotgj5KrYlFGeFDnps9NsIj(4mzKKtgjV8bsu0LrElpWgW4bfUGlm7KufGBJGot4)qYbDPCV6pLe6f1ihtYijVi)jU8zzBymiAVgN7w4PpTW8lmvlmJBUHZcvjYx4VrVf((fYpw4Krl8Kymvl0c5VWYKfArgcaSWFJwiAw4elSLV(eDArlK9fsNNIxyUvy2PfcAaUnle5lCYOfMVJ8tb5w(TqlK)clXAmJhu4nrOtov5awb6f1ihtYijVi)zckbw9NscUWSts9WIkXxxJ6pLe13jzKK6HfvIIUmYB5b2agpOWfCHzNKQaCBe0zc)hsoOlL7v)PKqVOg5ysgj5f5pXLplBdJbrBgpOWBIqNCQYbSc4cZojvb42yckb(fJO4hI9r205cerrxg5nfEkLu6rQ)usu8dX(iB6CbI08hWPIvraOrlrBymikurRXmEqH3eHo5uLdyfWfMDsQcWTXeucS6pLe6f1ihtYijVi)j(6AEK6pLet8XzYijNmsE5dK4RR5rQ)usmXhNjJKCYi5LpqIIUmYB5bMXdkCbxy2jPka3gbDMW)HKd6sRX5UfMBawSwTfcAUk(GwiplCYOfs(BHrAH5w(TqRmYxy9Dh5hlCYOfMBfMDAHkoUUHR1cbOdYFCP1AmJhu4nrOtov5awbCHzNKQCv8bzckbw9NscUWSts9WIkXxxJ6pLeCHzNK6HfvIIUmYB5DGFAQVtPOoibxy2jjYtihnATgN7wyUbyXA1wiO5Q4dAH8SWjJwi5VfgPfoz0cZ3r(TqlK)cRfALr(cRV7i)yHtgTWCRWStluXX1nCTwiaDq(JlTwJz8GcVjcDYPkhWkGlm7KuLRIpitqjWQ)usuFNKrsQhwuj(6Au)PKGlm7KupSOs8clxJ6pLe13jzKK6HfvIIUmYB5b(a)0uFNsrDqcUWStsKNqoA0AnMXdk8Mi0jNQCaRaUWStYlQ1qauZeuc8Ju)PKyIpotgj5KrYlFGeFDnddq(i4cZojjCwOXa1FkjEepzQr5K4fwUskX4bzMKKtxe1aRS2AEK6pLet8XzYijNmsE5dKOOlJ8Mcz8GcxWfMDsErTgcGAc6mH)djh0LmbNXihSYMqCbOLeNXixIsGv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUskzGrmma5JimtLEyrf90yG6pLe13jzKK6HfvIVUskHJa4fwUGmhyEqHlkIFAPT2AVgZ4bfEte6KtvoGvaxy2j5f1AiaQzckbw9NscmaXfMBdYpefX4XeCgJCWkVgZ4bfEte6KtvoGvaxy2jzuQMGsGv)PKGlm7KeNX1bjAdJbjpWM5cXQaKyI5kV8zjoJRdQTgZ4bfEte6KtvoGvaxy2jPka3gtqjWQ)usuFNKrsQhwuj(6kP0LDwOJhfQ8PwJz8GcVjcDYPkhWkGmhyEqHBckbw9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLBcYhQQV(irjWx2zHoEuiyJ(Pmb5dv1xFKO7LEiEiWkVgZ4bfEte6KtvoGvaxy2jPkxfFqRXRX5UfY4bfEtuXWdk8CaRam7ycqY4bfUjOeygpOWfK5aZdkCboJDNaq(HMl7SqhpkeSI)uAmWiQVtPOoirdPNfUSnrDvsj1FkjAi9SWLTjQROnmgeWQ)us0q6zHlBtuxXLplBdJbr71ygpOWBIkgEqHNdyfqMdmpOWnbLaFzNf64jpWM5cXQaKGmhsD8OXaCeaVWYft8XzYijNmsE5dKOOlJ8wEGz8GcxqMdmpOWf0zc)hsoOlPKs4iaEHLl4cZoj1dlQefDzK3YdmJhu4cYCG5bfUGot4)qYbDjLuYGHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLhygpOWfK5aZdkCbDMW)HKd6sARTg1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fwUMhP(tjXeFCMmsYjJKx(ajEHLRXi0lYS8a)eklM4JZKrsozK8YhO1ygpOWBIkgEqHNdyfqMdmpOWnbLaxFNsrDqIgsplCzBI6QbhbWlSCbxy2jPEyrLOOlJ8wEGz8GcxqMdmpOWf0zc)hsoOlTgN7wiO5Q4dAHO0crJHTfoOlTWjw4VrlCI5Uq2Fl0IwygBMw4eXcVSR1cXzCDqT1ygpOWBIkgEqHNdyfWfMDsQYvXhKjOeyCeaVWYft8XzYijNmsE5dKOi(PLgdu)PKGlm7KeNX1bjAdJbrHM5cXQaKyI5kV8zjoJRdQPbhbWlSCbxy2jPEyrLOOlJ8wEGPZe(pKCqxsZLDwOJhfAMleRcqcwxEro6(VYl7SuhpAu)PKO(ojJKupSOs8clx71ygpOWBIkgEqHNdyfWfMDsQYvXhKjOeyCeaVWYft8XzYijNmsE5dKOi(PLgdu)PKGlm7KeNX1bjAdJbrHM5cXQaKyI5kV8zjoJRdQPzyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5bMot4)qYbDjn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRR9AmJhu4nrfdpOWZbSc4cZojv5Q4dYeucmocGxy5Ij(4mzKKtgjV8bsue)0sJbQ)usWfMDsIZ46GeTHXGOqZCHyvasmXCLx(SeNX1b10yGrmma5JO(ojJKupSOsjLWra8clxuFNKrsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuYk01wdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6AVgZ4bfEtuXWdk8CaRaUWStsvUk(GmbLa)i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgeWps9NsIIFi2hztNlqKM)aovSkcanAjU8zzBymiAmq9NscUWSts9WIkXlSCLus9NscUWSts9WIkrrxg5T8aFGFARXa1FkjQVtYij1dlQeVWYvsj1FkjQVtYij1dlQefDzK3Yd8b(P9AmJhu4nrfdpOWZbSc4cZojvb42yckb(fJO4hI9r205cerrxg5nfA0vsjdEK6pLef)qSpYMoxGin)bCQyveaA0s0ggdIcvKMhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGK3Ju)PKO4hI9r205ceP5pGtfRIaqJwIlFw2ggdI2RXmEqH3evm8GcphWkGlm7KufGBJjOey1Fkj0lQroMKrsEr(t8118i1FkjM4JZKrsozK8YhiXxxZJu)PKyIpotgj5KrYlFGefDzK3YdmJhu4cUWStsvaUnc6mH)djh0LwJz8GcVjQy4bfEoGvaxy2j5f1AiaQzckb(rQ)usmXhNjJKCYi5LpqIVUMHbiFeCHzNKeol0yG6pLepINm1OCs8clxjLy8GmtsYPlIAGvwBng8i1FkjM4JZKrsozK8Yhirrxg5nfY4bfUGlm7K8IAnea1e0zc)hsoOlPKs4iaEHLl0lQroMKrsEr(tu0LrEtjLWHzYzFeGOvHyxBtWzmYbRSjexaAjXzmYLOey1FkjWaexyUni)qIZy3jaXlSCngO(tjbxy2jPEyrL4RRKsgyeddq(icZuPhwurpngO(tjr9DsgjPEyrL4RRKs4iaEHLliZbMhu4II4NwART2RXmEqH3evm8GcphWkGlm7K8IAnea1mbLaR(tjbgG4cZTb5hIIy8Or9Nsc6So7p6j1JH8bXaIV(AmJhu4nrfdpOWZbSc4cZojVOwdbqntqjWQ)usGbiUWCBq(HOigpAmq9NscUWSts9WIkXxxjLu)PKO(ojJKupSOs81vsPhP(tjXeFCMmsYjJKx(ajk6YiVPqgpOWfCHzNKxuRHaOMGot4)qYbDjTnbNXihSYRXmEqH3evm8GcphWkGlm7K8IAnea1mbLaR(tjbgG4cZTb5hIIy8Or9NscmaXfMBdYpeTHXGaw9NscmaXfMBdYpex(SSnmgetWzmYbR8AmJhu4nrfdpOWZbSc4cZojVOwdbqntqjWQ)usGbiUWCBq(HOigpAu)PKadqCH52G8drrxg5T8aBGbQ)usGbiUWCBq(HOnmgKCpJhu4cUWStYlQ1qautqNj8Fi5GUK25CGFABcoJroyLxJz8GcVjQy4bfEoGvGttgvYHU6uBmbLaBqrPIAzSkaPKsgXGWGG8dT1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdIg1Fkj4cZoj1dlQeVWY18i1FkjM4JZKrsozK8YhiXlS81ygpOWBIkgEqHNdyfWfMDsgLQjOey1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GARXmEqH3evm8GcphWkO91PYdZSjOe4l7Sqhp5bwXFknQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clFnMXdk8MOIHhu45awbCHzNKQaCBmbLaR(tjr9bizKKtwrut811O(tjbxy2jjoJRds0ggdIcvS1ygpOWBIkgEqHNdyfWfMDsQYvXhKjOe4l7Sqhp5b2mxiwfGeQCv8bjVSZsD8Or9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5Au)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrdocGxy5cYCG5bfUOOlJ82AmJhu4nrfdpOWZbSc4cZojv5Q4dYeucS6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOs8clxZJu)PKyIpotgj5KrYlFGeVWY1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdIMHbiFeCHzNKrPQbhbWlSCbxy2jzuQIIUmYB5b(a)0CzNf64jpWkEfPbhbWlSCbzoW8Gcxu0LrEBnMXdk8MOIHhu45awbCHzNKQCv8bzckbw9NscUWSts9WIkXxxJ6pLeCHzNK6HfvIIUmYB5b(a)0O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdIgdWra8clxqMdmpOWffDzK3usP67ukQdsWfMDsI8eYrJwAVgZ4bfEtuXWdk8CaRaUWStsvUk(GmbLaR(tjr9DsgjPEyrL4RRr9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujk6YiVLh4d8tJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAmahbWlSCbzoW8Gcxu0LrEtjLQVtPOoibxy2jjYtihnAP9AmJhu4nrfdpOWZbSc4cZojv5Q4dYeucS6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOs8clxZJu)PKyIpotgj5KrYlFGeFDnps9NsIj(4mzKKtgjV8bsu0LrElpWh4Ng1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2WyqwJz8GcVjQy4bfEoGvaxy2jPkxfFqMGsGhUoOrKrmWKj0XtEk2P0O(tjbxy2jjoJRds0ggdIcbBaJhKzssoDrulFwzT1uFNsrDqcUWSts14QY17s(OHXdYmjjNUiQPqL1O(tjXJ4jtnkNeVWYxJz8GcVjQy4bfEoGvaxy2jjDwhiAOWnbLapCDqJiJyGjtOJN8uStPr9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiAQVtPOoibxy2jPACv56DjF0W4bzMKKtxe1uOYAu)PK4r8KPgLtIxy5RXmEqH3evm8GcphWkGlm7KufGBZAmJhu4nrfdpOWZbSciZbMhu4MGsGv)PKO(ojJKupSOs8clxJ6pLeCHzNK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fw(AmJhu4nrfdpOWZbSc4cZojv5Q4dQBZ)jlQUTn6(b4bfUrvCA6tF6Da]] )


end