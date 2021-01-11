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


    spec:RegisterPack( "Arcane", 20201228, [[dWKDLeqisk6rkQsUejLe1MiQ(efQrru6uefRIKcQxPQuZIc5wKusyxi(LQsgMevhJKQLrb1ZKiLPrsHUMIQABkQI(MePQXrsjoNIQuRJcI5PO4EkY(uvPdssbzHQQ4HuqAIKusvUijLu(OePsDsskGvsbMjjL6MKusvTtfL(PePIgkjLezPKus6Pu0uvu5QKuG(QePsgRej7vs)fYGj1HrTyI8yOMSkUmyZu6ZsXOLsNMWQjPKkVwIy2s1Tvy3c)MQHtIJROkSCrpxLMUsxxv2oj57sy8QQ68suwVePcZxvX(r6Q615QMhEH6SgUCdxU6g2WQfI6QRE5Lp)Q5wMcunvyCjCdundEavt1qjMdOAQWL1D(uNRAE9xIHQz7Ukxd5RVAeB7tIG9XxxX415v4boz7(1vmWFvnLEI(QgiQsvZdVqDwdxUHlxDdBy1cr9YNFPvAZVAEvaCD25PHRMTIZbIQu18axC1CEr1Q1NBaQwnuI5aOgmVOA16byyibjvBy1IruTHl3WLtnGAW8IQvRcdxfq1Q4uWsDGWd0vHhuTiOAlRYtQ2Tu9f2venxcpqxfEq1YIBbCjuDz(lP6RcGPAxzfECLHqnyEr1Qbvo8chQwelKb3P6wooDr0q1ULQvXPGL6aPLvbixbc4q1Rt1savRovx0cbvFHDfrZLWd0vHhu9evRoHAW8IQvdEbQEltrG5ovBkggkv3YXPlIgQ2TunULJa6uTiwiZNYk8GQfXDb(q1ULQngZbg6igVcpmMqnyEr1Q1UxiWWLQty4QGdvZxQ2Tu9SUkyibjvBy1cvVovNW5HbQ2qvRKAqQw2Bx00U9YKHun7I7ERZvnDfiGSoxDw1RZvnHGL6WP(t1eNIfsbxnLLQZxawpBaYvO06b6UEoiqWsD4q1F(q15laRNnazHHINChvWPcbcwQdhQwgQwovVChILKVaqUfP4fqsGGL6WHQLt1y37hVii5laKBrkEbKKegSiUuTCQwwQw6zTK8faYTifVasYXlcQ(ZhQwjbvOg8HOoHtmhasIZKBaQwMQjJxHhvtqLJ5v4rDRZA46CvtiyPoCQ)unXPyHuWvZ8fG1ZgGCexSqPlcoldH9XGJdbcwQdhQwovl9SwYrCXcLUi4Sme2hdooiB63L8uQMmEfEunTIeqsD(U1ToBPvNRAcbl1Ht9NQjoflKcUAMVaSE2aKMuC7LHeybUdeiyPoCOA5u9GdMOGxQ(xQEEp)QjJxHhvtB63ffUkUU1zvJ15QMqWsD4u)PAItXcPGRMQjvNVaSE2aKRqP1d0D9CqGGL6WPAY4v4r18a82k5za1To78RZvnHGL6WP(t1eNIfsbxnhCWef8s1)s1QXYRMmEfEunt(i4yrxfolPU1zNN15QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsoErq1YPAS79JxeeoXCaifVasscdwexQwovRItbl1bIiub5chKRabKuTAor1Qxnz8k8OAEBf2venifVaY6wNT0xNRAcbl1Ht9NQjoflKcUAQItbl1bIiub5chKRabKu9evRovlNQXU3pErqYxai3Iu8cijjmyrCP6jQU8QjJxHhvtoXCaipLQBDw1sDUQjeSuho1FQM4uSqk4QPkofSuhiIqfKlCqUceqs1tuT6uTCQg7E)4fbjFbGClsXlGKKWGfXLQNO6YPA5uT0ZAjCI5aq4woBaYDzCju9muT0ZAjCI5aq4woBaYG)JUlJlPAY4v4r1KtmhasQZ3TU1zN315QMqWsD4u)PAItXcPGRMQ4uWsDGicvqUWb5kqajvpr1Qt1YPAPN1sYxai3Iu8cijhViQMmEfEunZxai3Iu8ciRBDw1lVox1ecwQdN6pvtCkwifC1ufNcwQderOcYfoixbciP6jQwDQwovRMuTSuD(cW6zdqUcLwpq31ZbbcwQdhQ(ZhQoFby9Sbilmu8K7OcoviqWsD4q1Yunz8k8OAQ4RWJ6wNvD1RZvnHGL6WP(t1eNIfsbxnLEwljFbGClsXlGKC8IOAY4v4r18a82k5za1ToR6gUox1ecwQdN6pvtCkwifC1u6zTK8faYTifVasYXlcQ(ZhQwjbvOg8HOoHtmhasIZKBGQjJxHhvZHitpVi3IwphqS1ToR6LwDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxeu9NpuTscQqn4drDcNyoaKeNj3avtgVcpQMR)WTi3I2wan4grDRZQUASox1ecwQdN6pvtCkwifC1ujbvOg8HOoz9hUf5w02cOb3iQMmEfEun5eZbGu8ciRBDw1NFDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxevtgVcpQM5laKBrkEbK1ToR6ZZ6CvtiyPoCQ)unXPyHuWvZdi9SwY6pClYTOTfqdUrqEkuTCQ(aspRLS(d3IClABb0GBeKegSiUu9munJxHheoXCaOH4EfD4sG)a(TaAfdOAY4v4r1ujHleya5w0qeN6wNv9sFDUQjeSuho1FQM4uSqk4Q5YDiws(ca5wKIxajbcwQdhQwovl9SwcNyoaKIxaj5Pq1YPAPN1sYxai3Iu8cijjmyrCP6zO6g8Hm4)vtgVcpQMkjCHadi3IgI4u36SQRwQZvnHGL6WP(t1eNIfsbxnp(ss(i4yrxfolHKWGfXLQ)LQNpv)5dvFaPN1ss(i4yrxfolbP61dizjrxSLrUlJlHQ)LQlVAY4v4r1KtmhasQZ3TU1zvFExNRAcbl1Ht9NQjoflKcUAk9SwIscxiWaYTOHioKNcvlNQpG0ZAjR)WTi3I2wan4gb5Pq1YP6di9SwY6pClYTOTfqdUrqsyWI4s1Zmr1mEfEq4eZbGK68DjWFa)waTIbunz8k8OAYjMdaj157w36SgU86CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijpfQwovJDVF8IGWjMdaP4fqssGpLr1YP6bhmrbVu9muTASCQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovRMuD(cW6zdqUcLwpq31ZbbcwQdhQwovRMuD(cW6zdqwyO4j3rfCQqGGL6WPAY4v4r1KtmhasIZKBG6wN1WQxNRAcbl1Ht9NQjoflKcUAk9Sws(ca5wKIxaj5Pq1YPAPN1s4eZbGu8cijhViOA5uT0ZAj5laKBrkEbKKegSiUu9mtuDd(q1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1YPAvCkyPoqeHkix4GCfiGSAY4v4r1KtmhasIZKBG6wN1WgUox1ecwQdN6pvtCllIQP6vtGZEziCllcKWwnLEwlb3boX8Dfrdc3YraDYXlc5Yk9SwcNyoaKIxaj5P85JSQ5YDiwIRcsfVas4ixwPN1sYxai3Iu8cijpLpFWU3pErqavoMxHhKe4tzYiJmvtCkwifC18aspRLS(d3IClABb0GBeKNcvlNQxUdXs4eZbGaCRtGGL6WHQLt1Ys1spRLCaEBL8maYXlcQ(ZhQMXRqfGGagc4s1tuT6uTmuTCQ(aspRLS(d3IClABb0GBeKegSiUu9VunJxHheoXCaOH4EfD4sG)a(TaAfdGQLt1Ys1QjvZLoGuSaHtmhas5ngqxeneiyPoCO6pFOAPN1sWDGtmFxr0GWTCeqNC8IGQLPAY4v4r1KtmhaAiUxrhU1ToRHlT6CvtiyPoCQ)unz8k8OAYjMdane3ROd3QjULfr1u9QjoflKcUAk9SwcUdCI57kIgscmEPA5un29(XlccNyoaKIxajjHblIlvlNQLLQLEwljFbGClsXlGK8uO6pFOAPN1s4eZbGu8cijpfQwM6wN1WQX6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqwFhOb)hHB5SbUuTCQwwQg7E)4fbHtmhasXlGKKWGfXLQ)LQvVCQ(ZhQMXRqfGGagc4s1Zmr1gMQLPAY4v4r1KtmhaYtP6wN1WZVox1ecwQdN6pvtCkwifC1u6zTK8faYTifVasYtHQ)8HQhCWef8s1)s1Qp)QjJxHhvtoXCaiPoF36wN1WZZ6CvtiyPoCQ)unz8k8OAcQCmVcpQMIyHmFklsyRMdoyIcE)DsTm)QPiwiZNYIeJbCe8cvt1RM4uSqk4QP0ZAj5laKBrkEbKKJxeuTCQw6zTeoXCaifVasYXlI6wN1WL(6CvtgVcpQMCI5aqsCMCdunHGL6WP(tDRB18aw(136C1zvVox1ecwQdN6pvtCkwifC1C5SbwYbKEwlbZ3venKey8wnz8k8OAI9xSqEvGEVU1znCDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMQxnXPyHuWvtvCkyPoqAzvaYvGaou9evxovlNQvsqfQbFiQtavoMxHhuTCQwnPAzP68fG1ZgGCfkTEGURNdceSuhou9NpuD(cW6zdqwyO4j3rfCQqGGL6WHQLPAQItuWdOA2YQaKRabCQBD2sRox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvt1RM4uSqk4QPkofSuhiTSka5kqahQEIQlNQLt1spRLWjMdaP4fqsoErq1YPAS79JxeeoXCaifVasscdwexQwovllvNVaSE2aKRqP1d0D9CqGGL6WHQ)8HQZxawpBaYcdfp5oQGtfceSuhouTmvtvCIcEavZwwfGCfiGtDRZQgRZvnHGL6WP(t10vQMxyRMmEfEunvXPGL6q1uf3Fq1u9QjoflKcUAk9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovRMuT0ZAj5Rdi3I22eGl5Pq1YPAROPDrjmyrCP6zMOAzPAzP6bhmv)fvZ4v4bHtmhasQZ3LG97s1Yq1QHPAgVcpiCI5aqsD(Ue4pGFlGwXaOAzQMQ4ef8aQMwrWDK0lJ6wND(15QMqWsD4u)PAY4v4r1eZ9oIXRWduxC3QzxCxuWdOAEB5eoi85w36SZZ6CvtiyPoCQ)unXPyHuWvtgVcvaccyiGlv)lvB4QjJxHhvtm37igVcpqDXDRMDXDrbpGQj7qDRZw6RZvnHGL6WP(t1eNIfsbxnvXPGL6aPLvbixbc4q1tuD5vtgVcpQMyU3rmEfEG6I7wn7I7IcEavtxbciRBDw1sDUQjeSuho1FQM4uSqk4Q5f2venxcpqxfEq1tuT6vtgVcpQMyU3rmEfEG6I7wn7I7IcEavtEGUk8OU1zN315QMqWsD4u)PAY4v4r1eZ9oIXRWduxC3QzxCxuWdOAIDVF8I4w36SQxEDUQjeSuho1FQM4uSqk4QPkofSuhiwrWDK0ldQEIQlVAY4v4r1eZ9oIXRWduxC3QzxCxuWdOAM(YRWJ6wNvD1RZvnHGL6WP(t1eNIfsbxnvXPGL6aXkcUJKEzq1tuT6vtgVcpQMyU3rmEfEG6I7wn7I7IcEavtRi4os6LrDRZQUHRZvnHGL6WP(t1KXRWJQjM7DeJxHhOU4UvZU4UOGhq1C4QGbeBDRB1m9LxHh15QZQEDUQjeSuho1FQM4uSqk4Q5GdMOGxQEMjQwfNcwQdeqLJuWlvlNQLLQXU3pErqw)HBrUfTTaAWncscdwexQEMjQMXRWdcOYX8k8Ga)b8Bb0kgav)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1mEfEqavoMxHhe4pGFlGwXaO6pFOAzP6L7qSK8faYTifVasceSuhouTCQg7E)4fbjFbGClsXlGKKWGfXLQNzIQz8k8GaQCmVcpiWFa)waTIbq1Yq1Yq1YPAPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxeuTCQwnPALeuHAWhI6K1F4wKBrBlGgCJOAY4v4r1eu5yEfEu36SgUox1ecwQdN6pvtCkwifC1mFby9SbixHsRhO765Gabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6zMOAgVcpiGkhZRWdc8hWVfqRyavtgVcpQMGkhZRWJ6wNT0QZvnHGL6WP(t1eNIfsbxnXU3pErqw)HBrUfTTaAWncsc8PmQwovllvl9SwcNyoaeULZgGCxgxcv)lvRItbl1bY67an4)iClNnWLQLt1y37hViiCI5aqkEbKKegSiUu9mtun8hWVfqRyauTCQEWbtuWlv)lvRItbl1bcRGgIqmEd0GdgPGxQwovl9Sws(ca5wKIxaj54fbvlt1KXRWJQjNyoaKeNj3a1ToRASox1ecwQdN6pvtCkwifC1e7E)4fbz9hUf5w02cOb3iijWNYOA5uTSuT0ZAjCI5aq4woBaYDzCju9VuTkofSuhiRVd0G)JWTC2axQwovVChILKVaqUfP4fqsGGL6WHQLt1y37hVii5laKBrkEbKKegSiUu9mtun8hWVfqRyauTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLPAY4v4r1KtmhasIZKBG6wND(15QMqWsD4u)PAItXcPGRMy37hViiR)WTi3I2wan4gbjb(ugvlNQLLQLEwlHtmhac3YzdqUlJlHQ)LQvXPGL6az9DGg8FeULZg4s1YPAzPA1KQxUdXsYxai3Iu8cijqWsD4q1F(q1y37hVii5laKBrkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eLUcvldvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzQMmEfEun5eZbGK4m5gOU1zNN15QMqWsD4u)PAItXcPGRMhq6zTKKpcow0vHZsqQE9asws0fBzK7Y4sO6jQ(aspRLK8rWXIUkCwcs1RhqYsIUylJm4)O7Y4sOA5uTSuT0ZAjCI5aqkEbKKJxeu9NpuT0ZAjCI5aqkEbKKegSiUu9mtuDd(q1Yq1YPAzPAPN1sYxai3Iu8cijhViO6pFOAPN1sYxai3Iu8cijjmyrCP6zMO6g8HQLPAY4v4r1KtmhasIZKBG6wNT0xNRAcbl1Ht9NQjoflKcUAE8LK8rWXIUkCwcjHblIlv)lvRwO6pFOAzP6di9SwsYhbhl6QWzjivVEajlj6ITmYDzCju9VuD5uTCQ(aspRLK8rWXIUkCwcs1RhqYsIUylJCxgxcvpdvFaPN1ss(i4yrxfolbP61dizjrxSLrg8F0DzCjuTmvtgVcpQMCI5aqsD(U1ToRAPox1ecwQdN6pvtCkwifC1u6zTeLeUqGbKBrdrCipfQwovFaPN1sw)HBrUfTTaAWncYtHQLt1hq6zTK1F4wKBrBlGgCJGKWGfXLQNzIQz8k8GWjMdaj157sG)a(TaAfdOAY4v4r1KtmhasQZ3TU1zN315QMqWsD4u)PAIBzrunvVAcC2ldHBzrGe2QP0ZAj4oWjMVRiAq4wocOtoErixwPN1s4eZbGu8cijpLpFKvnxUdXsCvqQ4fqch5Yk9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgzKPAItXcPGRMhq6zTK1F4wKBrBlGgCJG8uOA5u9YDiwcNyoaeGBDceSuhouTCQwwQw6zTKdWBRKNbqoErq1F(q1mEfQaeeWqaxQEIQvNQLHQLt1Ys1hq6zTK1F4wKBrBlGgCJGKWGfXLQ)LQz8k8GWjMdane3ROdxc8hWVfqRyau9Npun29(XlcIscxiWaYTOHioKegSiUu9Npun2vbbhlPKYsbhuTmuTCQwwQwnPAU0bKIfiCI5aqkVXa6IOHabl1Hdv)5dvl9SwcUdCI57kIgeULJa6KJxeuTmvtgVcpQMCI5aqdX9k6WTU1zvV86CvtiyPoCQ)unXPyHuWvtPN1sWDGtmFxr0qsGXlvlNQLEwlb(RWXboifFHyfCN8uQMmEfEun5eZbGgI7v0HBDRZQU615QMqWsD4u)PAY4v4r1KtmhaAiUxrhUvtCllIQP6vtCkwifC1u6zTeCh4eZ3venKey8s1YPAzPAPN1s4eZbGu8cijpfQ(ZhQw6zTK8faYTifVasYtHQ)8HQpG0ZAjR)WTi3I2wan4gbjHblIlv)lvZ4v4bHtmhaAiUxrhUe4pGFlGwXaOAzQBDw1nCDUQjeSuho1FQMmEfEun5eZbGgI7v0HB1e3YIOAQE1eNIfsbxnLEwlb3boX8DfrdjbgVuTCQw6zTeCh4eZ3venK7Y4sO6jQw6zTeCh4eZ3venKb)hDxgxsDRZQEPvNRAcbl1Ht9NQjJxHhvtoXCaOH4EfD4wnXTSiQMQxnXPyHuWvtPN1sWDGtmFxr0qsGXlvlNQLEwlb3boX8DfrdjHblIlvpZevllvllvl9SwcUdCI57kIgYDzCjuTAyQMXRWdcNyoa0qCVIoCjWFa)waTIbq1Yq1Ft1n4dvltDRZQUASox1ecwQdN6pvtCkwifC1uwQobBc3wwQdu9NpuTAs1RaxIiAOAzOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxevtgVcpQMbSTqIwyOa3TU1zvF(15QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGS(oqd(pc3YzdCRMmEfEun5eZbG8uQU1zvFEwNRAcbl1Ht9NQjoflKcUAo4Gjk4LQNzIQN3ZNQLt1spRLWjMdaP4fqsoErq1YPAPN1sYxai3Iu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViQMmEfEunVpfidxfx36SQx6RZvnHGL6WP(t1eNIfsbxnLEwljFDa5w02MaCjpfQwovl9SwcNyoaeULZgGCxgxcv)lvxAvtgVcpQMCI5aqsD(U1ToR6QL6CvtiyPoCQ)unXPyHuWvZbhmrbVu9mtuTkofSuhisCMCdGgCWif8s1YPAPN1s4eZbGu8cijhViOA5uT0ZAj5laKBrkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxeuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTCQg7E)4fbbu5yEfEqsyWI4wnz8k8OAYjMdajXzYnqDRZQ(8Uox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYXlcQwovl9Sws(ca5wKIxaj54fbvlNQpG0ZAjR)WTi3I2wan4gb54fbvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvlNQxUdXs4eZbG8uIabl1HdvlNQXU3pErq4eZbG8uIKWGfXLQNzIQBWhQwovp4Gjk4LQNzIQN3Lt1YPAS79JxeeqLJ5v4bjHblIB1KXRWJQjNyoaKeNj3a1ToRHlVox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYtHQLt1spRLWjMdaP4fqssyWI4s1Zmr1n4dvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvlNQXU3pErqavoMxHhKegSiUvtgVcpQMCI5aqsCMCdu36Sgw96CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijpfQwovl9SwcNyoaKIxaj54fbvlNQLEwljFbGClsXlGKKWGfXLQNzIQBWhQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovJDVF8IGaQCmVcpijmyrCRMmEfEun5eZbGK4m5gOU1znSHRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGKC8IGQLt1spRLKVaqUfP4fqsoErq1YP6di9SwY6pClYTOTfqdUrqEkuTCQ(aspRLS(d3IClABb0GBeKegSiUu9mtuDd(q1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLunz8k8OAYjMdajXzYnqDRZA4sRox1ecwQdN6pvtCkwifC1C5SbwslW9TLOGxQEgQU0MpvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvlNQZxawpBacNyoaKKpK48mGyjqWsD4q1YPAgVcvaccyiGlv)lvRovlNQLEwl5a82k5zaKJxevtgVcpQMCI5aqsCMCdu36SgwnwNRAcbl1Ht9NQjoflKcUAUC2alPf4(2suWlvpdvxAZNQLt1spRLWjMdaHB5Sbi3LXLq1Zq1spRLWjMdaHB5Sbid(p6UmUeQwovNVaSE2aeoXCaijFiX5zaXsGGL6WHQLt1mEfQaeeWqaxQ(xQwDQwovl9SwYb4TvYZaihViQMmEfEun5eZbGG)kD)k8OU1zn88RZvnz8k8OAYjMdaj157wnHGL6WP(tDRZA45zDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxeuTCQw6zTeoXCaifVasYXlcQwovFaPN1sw)HBrUfTTaAWncYXlIQjJxHhvtqLJ5v4rDRZA4sFDUQjJxHhvtoXCaijotUbQMqWsD4u)PU1TAYd0vHh15QZQEDUQjeSuho1FQM4uSqk4Q5GdMOGxQEMjQwfNcwQdeqLJuWlvlNQLLQXU3pErqw)HBrUfTTaAWncscdwexQEMjQMXRWdcOYX8k8Ga)b8Bb0kgav)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1mEfEqavoMxHhe4pGFlGwXaO6pFOAzP6L7qSK8faYTifVasceSuhouTCQg7E)4fbjFbGClsXlGKKWGfXLQNzIQz8k8GaQCmVcpiWFa)waTIbq1Yq1Yq1YPAPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxevtgVcpQMGkhZRWJ6wN1W15QMqWsD4u)PAItXcPGRMy37hViiCI5aqkEbKKegSiUu9evxovlNQLLQLEwljFbGClsXlGKC8IGQLt1Ys1y37hViiR)WTi3I2wan4gbjHblIlv)lvRItbl1bcRGg8F0b6CziRNO13bv)5dvJDVF8IGS(d3IClABb0GBeKegSiUu9evxovldvlt1KXRWJQ5b4TvYZaQBD2sRox1ecwQdN6pvtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQNO6YPA5uTSuT0ZAj5laKBrkEbKKJxeuTCQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6FPAvCkyPoqyf0G)JoqNldz9eT(oO6pFOAS79JxeK1F4wKBrBlGgCJGKWGfXLQNO6YPAzOAzQMmEfEunhIm98IClA9CaXw36SQX6CvtgVcpQMjFeCSORcNLunHGL6WP(tDRZo)6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGu8cijhViOA5un29(XlccNyoaKIxajzZhGsyWI4s1)s1mEfEqUTc7kIgKIxajbFsQwovl9Sws(ca5wKIxaj54fbvlNQXU3pErqYxai3Iu8cijB(aucdwexQ(xQMXRWdYTvyxr0Gu8cij4ts1YP6di9SwY6pClYTOTfqdUrqoErunz8k8OAEBf2venifVaY6wNDEwNRAcbl1Ht9NQjoflKcUAk9Sws(ca5wKIxaj54fbvlNQXU3pErq4eZbGu8cijjmyrCRMmEfEunZxai3Iu8ciRBD2sFDUQjeSuho1FQM4uSqk4QPSun29(XlccNyoaKIxajjHblIlvpr1Lt1YPAPN1sYxai3Iu8cijhViOAzO6pFOALeuHAWhI6K8faYTifVaYQjJxHhvZ1F4wKBrBlGgCJOU1zvl15QMqWsD4u)PAItXcPGRMy37hViiCI5aqkEbKKegSiUu9mu98lNQLt1spRLKVaqUfP4fqsoErq1YPA4EHadevIRWdKBrkqAb8k8Gabl1Ht1KXRWJQ56pClYTOTfqdUru36SZ76CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijhViOA5un29(XlcY6pClYTOTfqdUrqsyWI4s1)s1Q4uWsDGWkOb)hDGoxgY6jA9Dunz8k8OAYjMdaP4fqw36SQxEDUQjeSuho1FQM4uSqk4QP0ZAjCI5aqkEbKKNcvlNQLEwlHtmhasXlGKKWGfXLQNzIQz8k8GWjMdane3ROdxc8hWVfqRyauTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjvtgVcpQMCI5aqsCMCdu36SQREDUQjeSuho1FQM4uSqk4QP0ZAjCI5aq4woBaYDzCju9muT0ZAjCI5aq4woBaYG)JUlJlHQLt1spRLKVaqUfP4fqsoErq1YPAPN1s4eZbGu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViQMmEfEun5eZbG8uQU1zv3W15QMqWsD4u)PAItXcPGRMspRLKVaqUfP4fqsoErq1YPAPN1s4eZbGu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sQMmEfEun5eZbGK4m5gOU1zvV0QZvnHGL6WP(t1e3YIOAQE1e4Sxgc3YIajSvtPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(i9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktMQjoflKcUAk9SwcUdCI57kIgscmERMmEfEun5eZbGgI7v0HBDRZQUASox1ecwQdN6pvtCllIQP6vtGZEziCllcKWwnLEwlb3boX8Dfrdc3YraDYXlc5Yk9SwcNyoaKIxaj5P85J0ZAj5laKBrkEbKKNYNpy37hViiGkhZRWdsc8PmzQM4uSqk4QPAs1CPdiflq4eZbGuEJb0frdbcwQdhQ(ZhQw6zTeCh4eZ3veniClhb0jhViQMmEfEun5eZbGgI7v0HBDRZQ(8RZvnHGL6WP(t1eNIfsbxnLEwljFbGClsXlGKC8IGQLt1spRLWjMdaP4fqsoErq1YP6di9SwY6pClYTOTfqdUrqoErunz8k8OAcQCmVcpQBDw1NN15QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zq1spRLWjMdaHB5Sbid(p6UmUKQjJxHhvtoXCaipLQBDw1l915QMmEfEun5eZbGK4m5gOAcbl1Ht9N6wNvD1sDUQjJxHhvtoXCaiPoF3QjeSuho1FQBDRMdxfmGyRZvNv96CvtiyPoCQ)unXPyHuWvZHRcgqSKJ4UCGbQ(3jQw9YRMmEfEunL6IOK6wN1W15QMmEfEunvs4cbgqUfneXPAcbl1Ht9N6wNT0QZvnHGL6WP(t1eNIfsbxnhUkyaXsoI7YbgO6zOA1lVAY4v4r1KtmhaAiUxrhU1ToRASox1KXRWJQjNyoaKNsvtiyPoCQ)u36SZVox1KXRWJQPvKasQZ3TAcbl1Ht9N6w3QPscyFiXBDU6SQxNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMkjO86DeOYRMhWYV(wnlVU1znCDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMQxnXPyHuWvtvCkyPoqusq517iqLt1tuD5uTCQoFby9SbixHsRhO765Gabl1HdvlNQz8kubiiGHaUu9VuTHRMQ4ef8aQMkjO86DeOYRBD2sRox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvt1RM4uSqk4QPkofSuhikjO86DeOYP6jQUCQwovNVaSE2aKRqP1d0D9CqGGL6WHQLt1yxfeCSKaWP398q1YPAgVcvaccyiGlv)lvRE1ufNOGhq1ujbLxVJavEDRZQgRZvnHGL6WP(t10vQMxyRMmEfEunvXPGL6q1uf3Fq1S8QPkorbpGQPveChj9YOU1zNFDUQjeSuho1FQMUs1mHlSvtgVcpQMQ4uWsDOAQItuWdOAMx0G)JoqNldz9eT(oQMhWYV(wnNFDRZopRZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavZ8Ig8F0b6CziRNO0vQMhWYV(wnNFDRZw6RZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavZ8Ig8F0b6CziRNiwPAEal)6B10WLx36SQL6CvtiyPoCQ)unDLQzcxyRMmEfEunvXPGL6q1ufNOGhq1Kvqd(p6aDUmK1t067OAEal)6B1u9YRBD25DDUQjeSuho1FQMUs1mHlSvtgVcpQMQ4uWsDOAQItuWdOAMUcAW)rhOZLHSEIwFhvZdy5xFRMgU86wNv9YRZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavZ13bAW)rhOZLHSEIyLQ5bS8RVvZYRBDw1vVox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvZsRAItXcPGRMQ4uWsDGS(oqd(p6aDUmK1teRq1tuD5uTCQoFby9SbihXflu6IGZYqyFm44qGGL6WPAQItuWdOAU(oqd(p6aDUmK1teRu36SQB46CvtiyPoCQ)unDLQ5f2QjJxHhvtvCkyPounvX9hunvF(vtCkwifC1ufNcwQdK13bAW)rhOZLHSEIyfQEIQlNQLt1yxfeCSKq00UildvtvCIcEavZ13bAW)rhOZLHSEIyL6wNv9sRox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvt1NF1eNIfsbxnvXPGL6az9DGg8F0b6CziRNiwHQNO6YPA5un2JZtSeoXCaiL0pIMYiqWsD4q1YPAgVcvaccyiGlvpdvxAvtvCIcEavZ13bAW)rhOZLHSEIyL6wNvD1yDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMZVAItXcPGRMQ4uWsDGS(oqd(p6aDUmK1teRq1tuD5vtvCIcEavZ13bAW)rhOZLHSEIyL6wNv95xNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMRVd0G)JoqNldz9eLUs18aw(13QPHlVU1zvFEwNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMsCMCdGgCWif8wnpGLF9TAwEDRZQEPVox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvtzP65z5uTAfuTSu9GVlKLHuX9hq1QHPA1lVCQwgQwMQjoflKcUAQItbl1bIeNj3aObhmsbVu9evxovlNQXUki4yjHOPDrwgQMQ4ef8aQMsCMCdGgCWif8w36SQRwQZvnHGL6WP(t10vQMxyRMmEfEunvXPGL6q1uf3Fq1uwQwTuovRwbvllvp47czzivC)buTAyQw9YlNQLHQLPAItXcPGRMQ4uWsDGiXzYnaAWbJuWlvpr1LxnvXjk4bunL4m5gan4Grk4TU1zvFExNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMScAicX4nqdoyKcERMhWYV(wnlVU1znC515QMqWsD4u)PA6kvZlSvtgVcpQMQ4uWsDOAQI7pOAo)YRM4uSqk4QPkofSuhiScAicX4nqdoyKcEP6jQUCQwovNVaSE2aKJ4IfkDrWzziSpgCCiqWsD4unvXjk4bunzf0qeIXBGgCWif8w36Sgw96CvtiyPoCQ)unDLQ5f2QjJxHhvtvCkyPounvX9hunNF5vtCkwifC1ufNcwQdewbneHy8gObhmsbVu9evxovlNQZxawpBastkU9YqcSa3bceSuhovtvCIcEavtwbneHy8gObhmsbV1ToRHnCDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMQp)QjoflKcUAQItbl1bcRGgIqmEd0GdgPGxQEIQlVAQItuWdOAYkOHieJ3an4Grk4TU1znCPvNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMRVd0G)JWTC2a3Q5bS8RVvtdx36SgwnwNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMIqfKlCqUceqwnpGLF9TAwEDRZA45xNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQP6vtCkwifC1ufNcwQderOcYfoixbciP6jQUCQwovVChILKVaqUfP4fqsGGL6WHQLt1Ys1l3HyjCI5aqaU1jqWsD4q1F(q1QjvJDvqWXskPSuWbvldvlNQLLQvtQg7QGGJLeao9UNhQ(ZhQMXRqfGGagc4s1tuT6u9NpuD(cW6zdqUcLwpq31ZbbcwQdhQwMQPkorbpGQPiub5chKRabK1ToRHNN15QMqWsD4u)PA6kvZlSvtgVcpQMQ4uWsDOAQI7pOAwE1eNIfsbxnvXPGL6areQGCHdYvGasQEIQlVAQItuWdOAkcvqUWb5kqazDRZA4sFDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMW84juuGdzWywkb0TfGfnExbMQ)8HQH5XtOOahstNpcE98IK4tdq1F(q1W84juuGdPPZhbVEErd4W9UWdQ(ZhQgMhpHIcCiholz4EGoaUeKYBt4IHadu9NpunmpEcff4qeXfNVLL6aAE84yFd0bujWav)5dvdZJNqrboKR)6Dyxr0GYNuzu9NpunmpEcff4qUVqQ7(bXdyBl7Uu9NpunmpEcff4qk4sGaYlYMECO6pFOAyE8ekkWHy78aqUfjX72HQPkorbpGQjRG8a9UqDRZAy1sDUQjeSuho1FQMUs1mHlSvtgVcpQMQ4uWsDOAQItuWdOAYoGwFhOb)hHB5SbUvZdy5xFRMgUU1zn88Uox1ecwQdN6pvtxPAMWf2QjJxHhvtvCkyPounvXjk4bunbvosbVvZdy5xFRMQp)6wNT0kVox1KXRWJQ59ngEG4eZbGS8q0fCwnHGL6WP(tDRZwAQxNRAY4v4r1Ktmhasel07aERMqWsD4u)PU1zlndxNRAY4v4r1e7HADVeqdoyudmQMqWsD4u)PU1zlTsRox1KXRWJQ5qKPNiXGBGQjeSuho1FQBD2stnwNRAcbl1Ht9NQjoflKcUAQMuTkofSuhikjO86DeOYP6jQwDQwovNVaSE2aKJ4IfkDrWzziSpgCCiqWsD4unz8k8OAAt)UsEFRBD2sB(15QMqWsD4u)PAItXcPGRMQjvRItbl1bIsckVEhbQCQEIQvNQLt1QjvNVaSE2aKJ4IfkDrWzziSpgCCiqWsD4unz8k8OAYjMdaj157w36SL28Sox1ecwQdN6pvtCkwifC1ufNcwQdeLeuE9ocu5u9evRE1KXRWJQjOYX8k8OU1TAIDVF8I4wNRoR615QMqWsD4u)PAItXcPGRM5laRNnaPjf3EzibwG7abcwQdhQwovJDVF8IGWjMdaP4fqssyWI4s1)s1Lw5uTCQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovllvl9SwcNyoaeULZgGCxgxcvpZevRItbl1bY67an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzOAzQMmEfEunTPFxu4Q46wN1W15QMqWsD4u)PAItXcPGRM5laRNnaPjf3EzibwG7abcwQdhQwovJDVF8IGWjMdaP4fqssyWI4s1tuD5uTCQwwQwnP6L7qSei6IM2fc4qGGL6WHQ)8HQLLQxUdXsGOlAAxiGdbcwQdhQwovp4Gjk4LQ)DIQl9Lt1Yq1Yq1YPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvVCQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwgQ(ZhQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovl9SwcNyoaeULZgGCxgxcvpr1Lt1Yq1Yq1YPAPN1sYxai3Iu8cijhViOA5u9GdMOGxQ(3jQwfNcwQdewbneHy8gObhmsbVvtgVcpQM20VlkCvCDRZwA15QMqWsD4u)PAItXcPGRM5laRNna5iUyHsxeCwgc7JbhhceSuhouTCQg7E)4fbr6zTOJ4IfkDrWzziSpgCCijWNYOA5uT0ZAjhXflu6IGZYqyFm44GSPFxYXlcQwovllvl9SwcNyoaKIxaj54fbvlNQLEwljFbGClsXlGKC8IGQLt1hq6zTK1F4wKBrBlGgCJGC8IGQLHQLt1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAzPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvldvlt1KXRWJQPn97k59TU1zvJ15QMqWsD4u)PAItXcPGRM5laRNna5iUyHsxeCwgc7JbhhceSuhouTCQg7E)4fbr6zTOJ4IfkDrWzziSpgCCijWNYOA5uT0ZAjhXflu6IGZYqyFm44GSIeihViOA5uTscQqn4drDIn97k59TAY4v4r10ksaj157w36SZVox1ecwQdN6pvtCkwifC1e7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovl9SwcNyoaeULZgGCxgxcvpZevRItbl1bY67an4)iClNnWLQLt1y37hViiCI5aqkEbKKegSiUu9mtuDd(unz8k8OAoez65f5w065aITU1zNN15QMqWsD4u)PAItXcPGRMy37hViiCI5aqkEbKKegSiUu9evxovlNQLLQvtQE5oelbIUOPDHaoeiyPoCO6pFOAzP6L7qSei6IM2fc4qGGL6WHQLt1doyIcEP6FNO6sF5uTmuTmuTCQwwQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6FPAvCkyPoqyf0G)JoqNldz9eT(oOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOAzO6pFOAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQNO6YPA5uT0ZAjCI5aq4woBaYDzCju9evxovldvldvlNQLEwljFbGClsXlGKC8IGQLt1doyIcEP6FNOAvCkyPoqyf0qeIXBGgCWif8wnz8k8OAoez65f5w065aITU1zl915QMqWsD4u)PAItXcPGRMy37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqwFhOb)hHB5SbUuTCQg7E)4fbHtmhasXlGKKWGfXLQNzIQBWNQjJxHhvZdWBRKNbu36SQL6CvtiyPoCQ)unXPyHuWvtS79JxeeoXCaifVasscdwexQEIQlNQLt1Ys1QjvVChILarx00UqahceSuhou9NpuTSu9YDiwceDrt7cbCiqWsD4q1YP6bhmrbVu9VtuDPVCQwgQwgQwovllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuT6Lt1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1Yq1F(q1Ys1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6jQUCQwgQwgQwovl9Sws(ca5wKIxaj54fbvlNQhCWef8s1)or1Q4uWsDGWkOHieJ3an4Grk4TAY4v4r18a82k5za1To78Uox1ecwQdN6pvtCkwifC1e7E)4fbz9hUf5w02cOb3iijmyrCP6FPAvCkyPoqYlAW)rhOZLHSEIwFhuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6ajVOb)hDGoxgY6jIvOA5uTSu9YDiws(ca5wKIxajbcwQdhQwovllvJDVF8IGKVaqUfP4fqssyWI4s1Zq1WFa)waTIbq1F(q1y37hVii5laKBrkEbKKegSiUu9VuTkofSuhi5fn4)Od05YqwprPRq1Yq1F(q1QjvVChILKVaqUfP4fqsGGL6WHQLHQLt1spRLWjMdaHB5Sbi3LXLq1)s1gMQLt1hq6zTK1F4wKBrBlGgCJGC8IGQLt1spRLKVaqUfP4fqsoErq1YPAPN1s4eZbGu8cijhViQMmEfEunt(i4yrxfolPU1zvV86CvtiyPoCQ)unXPyHuWvtS79JxeK1F4wKBrBlGgCJGKWGfXLQNHQH)a(TaAfdGQLt1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGS(oqd(pc3YzdCPA5un29(XlccNyoaKIxajjHblIlvpdvllvd)b8Bb0kgav)nvZ4v4bz9hUf5w02cOb3iiWFa)waTIbq1Yunz8k8OAM8rWXIUkCwsDRZQU615QMqWsD4u)PAItXcPGRMy37hViiCI5aqkEbKKegSiUu9mun8hWVfqRyauTCQwwQwwQwnP6L7qSei6IM2fc4qGGL6WHQ)8HQLLQxUdXsGOlAAxiGdbcwQdhQwovp4Gjk4LQ)DIQl9Lt1Yq1Yq1YPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvXPGL6aHvqd(p6aDUmK1t067GQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLHQ)8HQLLQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1spRLWjMdaHB5Sbi3LXLq1tuD5uTmuTmuTCQw6zTK8faYTifVasYXlcQwovp4Gjk4LQ)DIQvXPGL6aHvqdrigVbAWbJuWlvlt1KXRWJQzYhbhl6QWzj1ToR6gUox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEMjQwfNcwQdK13bAW)r4woBGlvlNQXU3pErq4eZbGu8cijjmyrCP6zMOA4pGFlGwXaOA5u9GdMOGxQ(xQwfNcwQdewbneHy8gObhmsbVuTCQw6zTK8faYTifVasYXlIQjJxHhvZ1F4wKBrBlGgCJOU1zvV0QZvnHGL6WP(t1eNIfsbxnLEwlHtmhac3YzdqUlJlHQNzIQvXPGL6az9DGg8FeULZg4s1YP6L7qSK8faYTifVasceSuhouTCQg7E)4fbjFbGClsXlGKKWGfXLQNzIQH)a(TaAfdGQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQv3WvtgVcpQMR)WTi3I2wan4grDRZQUASox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEMjQwfNcwQdK13bAW)r4woBGlvlNQLLQvtQE5oeljFbGClsXlGKabl1Hdv)5dvJDVF8IGKVaqUfP4fqssyWI4s1)s1Q4uWsDGS(oqd(p6aDUmK1tu6kuTmuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwPAY4v4r1C9hUf5w02cOb3iQBDw1NFDUQjeSuho1FQM4uSqk4Qj29(XlcY6pClYTOTfqdUrqsyWI4s1)s1Q4uWsDGWkOb)hDGoxgY6jA9Dq1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1YPAPN1sYxai3Iu8cijhViOA5u9GdMOGxQ(3jQwfNcwQdewbneHy8gObhmsbVvtgVcpQMCI5aqkEbK1ToR6ZZ6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGu8cijhViOA5uTSun29(XlcY6pClYTOTfqdUrqsyWI4s1)s1Q4uWsDGKUcAW)rhOZLHSEIwFhu9Npun29(XlccNyoaKIxajjHblIlvpZevRItbl1bY67an4)Od05YqwprScvldvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvlNQXU3pErq4eZbGu8cijjmyrCP6FPA1nC1KXRWJQz(ca5wKIxazDRZQEPVox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYXlcQwovJDVF8IGWjMdaP4fqs28bOegSiUu9VunJxHhKBRWUIObP4fqsWNKQLt1spRLKVaqUfP4fqsoErq1YPAS79JxeK8faYTifVasYMpaLWGfXLQ)LQz8k8GCBf2venifVasc(KuTCQ(aspRLS(d3IClABb0GBeKJxevtgVcpQM3wHDfrdsXlGSU1zvxTuNRAcbl1Ht9NQjoflKcUAUChILKVaqUfP4fqsGGL6WHQLt1spRLWjMdaP4fqsEkuTCQw6zTK8faYTifVasscdwexQEgQUbFid(F1KXRWJQPscxiWaYTOHio1ToR6Z76CvtiyPoCQ)unXPyHuWvZdi9SwY6pClYTOTfqdUrqEkuTCQ(aspRLS(d3IClABb0GBeKegSiUu9munJxHheoXCaOH4EfD4sG)a(TaAfdGQLt1QjvJDvqWXskPSuWr1KXRWJQPscxiWaYTOHio1ToRHlVox1ecwQdN6pvtCkwifC1u6zTK8faYTifVasYtHQLt1spRLKVaqUfP4fqssyWI4s1Zq1n4dzW)PA5un29(XlccOYX8k8GKaFkJQLt1y37hViiR)WTi3I2wan4gbjHblIlvlNQvtQg7QGGJLuszPGJQjJxHhvtLeUqGbKBrdrCQBDRM3woHdcFU15QZQEDUQjeSuho1FQM4uSqk4QPSu9YDiwceDrt7cbCiqWsD4q1YP6bhmrbVu9mtuTAPCQwovp4Gjk4LQ)DIQNNZNQLHQ)8HQLLQvtQE5oelbIUOPDHaoeiyPoCOA5u9GdMOGxQEMjQwTmFQwMQjJxHhvZbhmQbg1ToRHRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGK8uQMmEfEunv8v4rDRZwA15QMqWsD4u)PAItXcPGRM5laRNnazHHINChvWPcbcwQdhQwovl9Swc8VLF3v4b5Pq1YPAzPAS79JxeeoXCaifVassc8PmQ(ZhQ2kAAxucdwexQEMjQwnwovlt1KXRWJQ5kgaQGtL6wNvnwNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj54fbvlNQLEwljFbGClsXlGKC8IGQLt1hq6zTK1F4wKBrBlGgCJGC8IOAY4v4r1SlAA3lsTU3PzaXw36SZVox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYXlcQwovl9Sws(ca5wKIxaj54fbvlNQpG0ZAjR)WTi3I2wan4gb54fr1KXRWJQPe3GClAtbUKBDRZopRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGK8uQMmEfEunLG8czjIOPU1zl915QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsEkvtgVcpQMsD3pi7llRU1zvl15QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsEkvtgVcpQMwrcsD3p1To78Uox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYtPAY4v4r1KdmC3K7im371ToR6LxNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj5Punz8k8OA(UasSW4w36SQREDUQjeSuho1FQMmEfEunB68rWRNxKeFAGQjoflKcUAk9SwcNyoaKIxaj5Pq1F(q1y37hViiCI5aqkEbKKegSiUu9Vtu98NpvlNQpG0ZAjR)WTi3I2wan4gb5PunbRfWlk4bunB68rWRNxKeFAG6wNvDdxNRAcbl1Ht9NQjJxHhvtyOuwcCh55j4advtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQNzIQnC5vZGhq1egkLLa3rEEcoWqDRZQEPvNRAcbl1Ht9NQjJxHhvZtc8XksaPcUxOxnXPyHuWvtS79JxeeoXCaifVasscdwexQ(3jQ2WLt1F(q1Q4uWsDGWkipqVlq1Q5evRov)5dvllvVIbq1tuD5uTCQwfNcwQderOcYfoixbciP6jQwDQwovNVaSE2aKRqP1d0D9CqGGL6WHQLPAg8aQMNe4JvKasfCVqVU1zvxnwNRAcbl1Ht9NQjJxHhvZR)6irtiwiRM4uSqk4Qj29(XlccNyoaKIxajjHblIlv)7evB4YP6pFOAvCkyPoqyfKhO3fOA1CIQvNQ)8HQLLQxXaO6jQUCQwovRItbl1bIiub5chKRabKu9evRovlNQZxawpBaYvO06b6UEoiqWsD4q1YundEavZR)6irtiwiRBDw1NFDUQjeSuho1FQMmEfEunB6LP0IClIVxXq05v4r1eNIfsbxnXU3pErq4eZbGu8cijjmyrCP6FNOAdxov)5dvRItbl1bcRG8a9UavRMtuT6u9NpuTSu9kgavpr1Lt1YPAvCkyPoqeHkix4GCfiGKQNOA1PA5uD(cW6zdqUcLwpq31ZbbcwQdhQwMQzWdOA20ltPf5weFVIHOZRWJ6wNv95zDUQjeSuho1FQMmEfEunhmMLsaDBbyrJ3vGRM4uSqk4Qj29(XlccNyoaKIxajjHblIlvpZevpFQwovllvRItbl1bIiub5chKRabKuTAor1Qt1F(q1Ryau9VuDPvovlt1m4bunhmMLsaDBbyrJ3vGRBDw1l915QMqWsD4u)PAY4v4r1CWywkb0TfGfnExbUAItXcPGRMy37hViiCI5aqkEbKKegSiUu9mtu98PA5uTkofSuhiIqfKlCqUceqs1tuT6uTCQw6zTK8faYTifVasYtHQLt1spRLKVaqUfP4fqssyWI4s1Zmr1Ys1QxovRwbvpFQwnmvNVaSE2aKRqP1d0D9CqGGL6WHQLHQLt1Ryau9muDPvE1m4bunhmMLsaDBbyrJ3vGRBDRMSd15QZQEDUQjeSuho1FQM4uSqk4Qz(cW6zdqoIlwO0fbNLHW(yWXHabl1HdvlNQXU3pErqKEwl6iUyHsxeCwgc7Jbhhsc8PmQwovl9SwYrCXcLUi4Sme2hdooiB63LC8IGQLt1Ys1spRLWjMdaP4fqsoErq1YPAPN1sYxai3Iu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViOAzOA5un29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQwwQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzOAzQMmEfEunTPFxjVV1ToRHRZvnHGL6WP(t1eNIfsbxnLLQZxawpBaYrCXcLUi4Sme2hdooeiyPoCOA5un29(XlcI0ZArhXflu6IGZYqyFm44qsGpLr1YPAPN1soIlwO0fbNLHW(yWXbzfjqoErq1YPALeuHAWhI6eB63vY7lvldv)5dvllvNVaSE2aKJ4IfkDrWzziSpgCCiqWsD4q1YP6vmaQEIQlNQLPAY4v4r10ksaj157w36SLwDUQjeSuho1FQM4uSqk4Qz(cW6zdqAsXTxgsGf4oqGGL6WHQLt1y37hViiCI5aqkEbKKegSiUu9VuDPvovlNQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1Ys1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvldvlt1KXRWJQPn97Icxfx36SQX6CvtiyPoCQ)unXPyHuWvZ8fG1ZgG0KIBVmKalWDGabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6jQUCQwovllvllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuTkofSuhiScAW)rhOZLHSEIwFhuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTmu9NpuTSun29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLHQLHQLt1spRLKVaqUfP4fqsoErq1Yunz8k8OAAt)UOWvX1To78RZvnHGL6WP(t1eNIfsbxnZxawpBaYvO06b6UEoiqWsD4q1YPALeuHAWhI6eqLJ5v4r1KXRWJQ56pClYTOTfqdUru36SZZ6CvtiyPoCQ)unXPyHuWvZ8fG1ZgGCfkTEGURNdceSuhouTCQwwQwjbvOg8HOobu5yEfEq1F(q1kjOc1Gpe1jR)WTi3I2wan4gbvlt1KXRWJQjNyoaKIxazDRZw6RZvnHGL6WP(t1eNIfsbxnxXaO6FP6sRCQwovNVaSE2aKRqP1d0D9CqGGL6WHQLt1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTCQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4t1KXRWJQjOYX8k8OU1zvl15QMqWsD4u)PAY4v4r1eu5yEfEunfXcz(uwKWwnLEwl5kuA9aDxphK7Y4sMKEwl5kuA9aDxphKb)hDxgxs1uelK5tzrIXaocEHQP6vtCkwifC1CfdGQ)LQlTYPA5uD(cW6zdqUcLwpq31ZbbcwQdhQwovJDVF8IGWjMdaP4fqssyWI4s1tuD5uTCQwwQwwQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6FPAvCkyPoqyf0G)JoqNldz9eT(oOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOAzO6pFOAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQNO6YPA5uT0ZAjCI5aq4woBaYDzCju9mtuTkofSuhiSdO13bAW)r4woBGlvldvldvlNQLEwljFbGClsXlGKC8IGQLPU1zN315QMqWsD4u)PAItXcPGRMYs1y37hViiCI5aqkEbKKegSiUu9VuTAC(u9Npun29(XlccNyoaKIxajjHblIlvpZevxAuTmuTCQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovllvl9SwcNyoaeULZgGCxgxcvpZevRItbl1bc7aA9DGg8FeULZg4s1YPAzPAzP6L7qSK8faYTifVasceSuhouTCQg7E)4fbjFbGClsXlGKKWGfXLQNzIQBWhQwovJDVF8IGWjMdaP4fqssyWI4s1)s1ZNQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FP65t1Yq1F(q1y37hViiCI5aqkEbKKegSiUu9mtuDd(q1Yq1Yunz8k8OAoez65f5w065aITU1zvV86CvtiyPoCQ)unXPyHuWvtS79JxeK1F4wKBrBlGgCJGKWGfXLQNHQH)a(TaAfdGQLt1Ys1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvldvlt1KXRWJQzYhbhl6QWzj1ToR6QxNRAcbl1Ht9NQjoflKcUAIDVF8IGWjMdaP4fqssyWI4s1Zq1WFa)waTIbq1YPAzPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvXPGL6aHvqd(p6aDUmK1t067GQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLHQ)8HQLLQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTmuTmuTCQw6zTK8faYTifVasYXlcQwMQjJxHhvZKpcow0vHZsQBDw1nCDUQjeSuho1FQM4uSqk4Qj29(XlccNyoaKIxajjHblIlvpr1Lt1YPAzPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvXPGL6aHvqd(p6aDUmK1t067GQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLHQ)8HQLLQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTmuTmuTCQw6zTK8faYTifVasYXlcQwMQjJxHhvZdWBRKNbu36SQxA15QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvlt1KXRWJQ56pClYTOTfqdUru36SQRgRZvnHGL6WP(t1eNIfsbxnLLQLLQXU3pErqw)HBrUfTTaAWncscdwexQ(xQwfNcwQdewbn4)Od05YqwprRVdQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwgQ(ZhQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovl9SwcNyoaeULZgGCxgxcvpZevRItbl1bc7aA9DGg8FeULZg4s1Yq1Yq1YPAPN1sYxai3Iu8cijhViQMmEfEun5eZbGu8ciRBDw1NFDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxeuTCQwwQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6FPAdxovlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvldv)5dvllvJDVF8IGS(d3IClABb0GBeKegSiUu9evxovlNQLEwlHtmhac3YzdqUlJlHQNzIQvXPGL6aHDaT(oqd(pc3YzdCPAzOAzOA5uTSun29(XlccNyoaKIxajjHblIlv)lvRUHP6pFO6di9SwY6pClYTOTfqdUrqEkuTmvtgVcpQM5laKBrkEbK1ToR6ZZ6CvtiyPoCQ)unXPyHuWvtS79JxeeoXCaipLijmyrCP6FP65t1F(q1QjvVChILWjMda5PebcwQdNQjJxHhvZBRWUIObP4fqw36SQx6RZvnHGL6WP(t1eNIfsbxnLEwl5a82k5zaKNcvlNQpG0ZAjR)WTi3I2wan4gb5Pq1YP6di9SwY6pClYTOTfqdUrqsyWI4s1Zmr1spRLOKWfcmGClAiIdzW)r3LXLq1QHPAgVcpiCI5aqsD(Ue4pGFlGwXaQMmEfEunvs4cbgqUfneXPU1zvxTuNRAcbl1Ht9NQjoflKcUAk9SwYb4TvYZaipfQwovllvllvVChILKW1doWabcwQdhQwovZ4vOcqqadbCP6zOA1ivldv)5dvZ4vOcqqadbCP6zO65t1Yq1YPAzPA1KQZxawpBacNyoaKKpK48mGyjqWsD4q1F(q1lNnWsAbUVTef8s1)s1L28PAzQMmEfEun5eZbGK68DRBDw1N315QMmEfEunVpfidxfxnHGL6WP(tDRZA4YRZvnHGL6WP(t1eNIfsbxnLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxs1KXRWJQjNyoaKeNj3a1ToRHvVox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEIQlVAY4v4r1KtmhaYtP6wN1WgUox1ecwQdN6pvtCkwifC1uwQobBc3wwQdu9NpuTAs1RaxIiAOAzOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sQMmEfEundyBHeTWqbUBDRZA4sRox1ecwQdN6pvtCkwifC1u6zTeCh4eZ3venKey8s1YP68fG1ZgGWjMdajcRieBzeiyPoCOA5uTSuTSu9YDiwcpu6cRaZRWdceSuhouTCQMXRqfGGagc4s1Zq1QfQwgQ(ZhQMXRqfGGagc4s1Zq1ZNQLPAY4v4r1KtmhaAiUxrhU1ToRHvJ15QMqWsD4u)PAItXcPGRMspRLG7aNy(UIOHKaJxQwovVChILWjMdab4wNabl1HdvlNQpG0ZAjR)WTi3I2wan4gb5Pq1YPAzP6L7qSeEO0fwbMxHheiyPoCO6pFOAgVcvaccyiGlvpdvpVPAzQMmEfEun5eZbGgI7v0HBDRZA45xNRAcbl1Ht9NQjoflKcUAk9SwcUdCI57kIgscmEPA5u9YDiwcpu6cRaZRWdceSuhouTCQMXRqfGGagc4s1Zq1QXQjJxHhvtoXCaOH4EfD4w36SgEEwNRAcbl1Ht9NQjoflKcUAk9SwcNyoaeULZgGCxgxcvpdvl9SwcNyoaeULZgGm4)O7Y4sQMmEfEun5eZbGG)kD)k8OU1znCPVox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTCQwjbvOg8HOoHtmhasIZKBGQjJxHhvtoXCai4Vs3VcpQBDwdRwQZvnfXcz(uwKWwnhCWef8(7KAz(vtrSqMpLfjgd4i4fQMQxnz8k8OAcQCmVcpQMqWsD4u)PU1TAAfb3rsVmQZvNv96CvtiyPoCQ)unz8k8OAYjMdane3ROd3QjULfr1u9QjoflKcUAk9SwcUdCI57kIgscmERBDwdxNRAY4v4r1KtmhasQZ3TAcbl1Ht9N6wNT0QZvnz8k8OAYjMdajXzYnq1ecwQdN6p1TU1TAQcYRWJ6SgUCdxU6g2WZVAwWziIMB1S0LAi1QZQgy2s3gcvt1Z1cuTyO45s1wpPAJDfiG0yQoH5XtKWHQV(aOA(T(Gx4q14woAGlHAGAlcGQv3qOAd1dvqUWHQnE5oelPugt1Rt1gVChILukceSuhogt1YQ(FziuduBrauT6gcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQwwd)xgc1a1weavBydHQnupub5chQ248fG1ZgGukJP61PAJZxawpBasPiqWsD4ymvlR6)LHqnqTfbq1LMHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgO2IaOA1OHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQ5LQvRv6uTPAzv)VmeQbQTiaQw9YneQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSg(VmeQbQTiaQw9sVHq1gQhQGCHdvB8YDiwsPmMQxNQnE5oelPueiyPoCmMQLv9)YqOgO2IaOAdxUHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgO2IaOAdxUHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQ5LQvRv6uTPAzv)VmeQbQTiaQ2Wg2qOAd1dvqUWHQnE5oelPugt1Rt1gVChILukceSuhogt1YQ(FziudOgu6snKA1zvdmBPBdHQP65AbQwmu8CPARNuTXSdgt1jmpEIeou91havZV1h8chQg3YrdCjuduBrauT6gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavRUHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgO2IaOAdBiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzn8FziuduBrauDPziuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauDPziuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQwnAiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQE(gcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQNNgcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQl9gcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQvlgcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQN3gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavRE5gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavREPziuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauT6ZtdHQnupub5chQ24L7qSKszmvVovB8YDiwsPiqWsD4ymvZlvRwR0PAt1YQ(FziuduBrauT6QfdHQnupub5chQ24L7qSKszmvVovB8YDiwsPiqWsD4ymvlR6)LHqnqTfbq1QRwmeQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSQ)xgc1a1weavB4sZqOAd1dvqUWHQnE5oelPugt1Rt1gVChILukceSuhogt1YQ(FziuduBrauTHlndHQnupub5chQ248fG1ZgGukJP61PAJZxawpBasPiqWsD4ymvlR6)LHqnqTfbq1gwnAiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauTHNVHq1gQhQGCHdvB8YDiwsPmMQxNQnE5oelPueiyPoCmMQLv9)YqOgqnO0LAi1QZQgy2s3gcvt1Z1cuTyO45s1wpPAJtF5v4HXuDcZJNiHdvF9bq18B9bVWHQXTC0axc1a1weavRUHq1gQhQGCHdvB8YDiwsPmMQxNQnE5oelPueiyPoCmMQLv9)YqOgO2IaOAdBiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQwnAiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzv)VmeQbQTiaQE(gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQww1)ldHAGAlcGQN3gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQww1)ldHAGAlcGQvFEBiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzv)VmeQbQTiaQ2WLMHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgO2IaOAdRgneQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSQ)xgc1aQbLUudPwDw1aZw62qOAQEUwGQfdfpxQ26jvB8bS8RVgt1jmpEIeou91havZV1h8chQg3YrdCjuduBrauTHneQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSg(VmeQbQTiaQU0meQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSg(VmeQbQTiaQwnAiuTH6Hkix4q1MIHHs13YIL)t1QvMQxNQv7ht1hHkXv4bv7kqYRNuTSFjdvlR6)LHqnGAqPl1qQvNvnWSLUneQMQNRfOAXqXZLQTEs1gRKa2hs8AmvNW84js4q1xFaun)wFWlCOAClhnWLqnqTfbq1g2qOAd1dvqUWHQnoFby9SbiLYyQEDQ248fG1ZgGukceSuhogt1YQ(FziuduBrauDPziuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQwD1neQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXunVuTATsNQnvlR6)LHqnqTfbq1QxAgcvBOEOcYfouTXypopXskLXu96uTXypopXskfbcwQdhJPAzv)VmeQbQTiaQ2WLBiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAEPA1ALovBQww1)ldHAGAlcGQnS6gcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQMxQwTwPt1MQLv9)YqOgO2IaOAdpFdHQnupub5chQ24L7qSKszmvVovB8YDiwsPiqWsD4ymvlRH)ldHAGAlcGQn88neQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSQ)xgc1a1weavxAQrdHQnupub5chQ248fG1ZgGukJP61PAJZxawpBasPiqWsD4ymvZlvRwR0PAt1YQ(FziuduBrauDPnFdHQnupub5chQ248fG1ZgGukJP61PAJZxawpBasPiqWsD4ymvZlvRwR0PAt1YQ(FziudOgu6snKA1zvdmBPBdHQP65AbQwmu8CPARNuTXy37hViUgt1jmpEIeou91havZV1h8chQg3YrdCjuduBrauT6gcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavRUHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgO2IaOAdBiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauTHneQ2q9qfKlCOAJZxawpBasPmMQxNQnoFby9SbiLIabl1HJXuTSQ)xgc1a1weavxAgcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavxAgcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQvJgcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQNNgcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQwwd)xgc1a1weavRwmeQ2q9qfKlCOAJxUdXskLXu96uTXl3HyjLIabl1HJXuTSg(VmeQbQTiaQEEBiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauT6QBiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzn8FziuduBrauT6LMHq1gQhQGCHdvB8YDiwsPmMQxNQnE5oelPueiyPoCmMQLv9)YqOgO2IaOA1vJgcvBOEOcYfouTXl3HyjLYyQEDQ24L7qSKsrGGL6WXyQww1)ldHAGAlcGQvxTyiuTH6Hkix4q1gVChILukJP61PAJxUdXskfbcwQdhJPAzv)VmeQbudkDPgsT6SQbMT0THq1u9CTavlgkEUuT1tQ24BlNWbHpxJP6eMhprchQ(6dGQ536dEHdvJB5ObUeQbQTiaQwDdHQnupub5chQ24L7qSKszmvVovB8YDiwsPiqWsD4ymvlRH)ldHAGAlcGQlndHQnupub5chQ248fG1ZgGukJP61PAJZxawpBasPiqWsD4ymvlR6)LHqnqTfbq1QxAgcvBOEOcYfouTX5laRNnaPugt1Rt1gNVaSE2aKsrGGL6WXyQww1)ldHAGAlcGQvxnAiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQw95BiuTH6Hkix4q1gNVaSE2aKszmvVovBC(cW6zdqkfbcwQdhJPAzv)VmeQbQTiaQw9sVHq1gQhQGCHdvBC(cW6zdqkLXu96uTX5laRNnaPueiyPoCmMQLv9)YqOgqnO0LAi1QZQgy2s3gcvt1Z1cuTyO45s1wpPAJ5b6QWdJP6eMhprchQ(6dGQ536dEHdvJB5ObUeQbQTiaQwDdHQnupub5chQ24L7qSKszmvVovB8YDiwsPiqWsD4ymvlR6)LHqnGAGAGHINlCOA1lNQz8k8GQ7I7EjudQMkPBfDOAoVOA16ZnavRgkXCaudMxuTA9ammKGKQnSAXiQ2WLB4YPgqnyEr1QvHHRcOAvCkyPoq4b6QWdQweuTLv5jv7wQ(c7kIMlHhORcpOAzXTaUeQUm)Lu9vbWuTRScpUYqOgmVOA1GkhEHdvlIfYG7uDlhNUiAOA3s1Q4uWsDG0YQaKRabCO61PAjGQvNQlAHGQVWUIO5s4b6QWdQEIQvNqnyEr1QbVavVLPiWCNQnfddLQB540frdv7wQg3YraDQwelK5tzfEq1I4UaFOA3s1gJ5adDeJxHhgtOgmVOA1A3ley4s1jmCvWHQ5lv7wQEwxfmKGKQnSAHQxNQt48WavBOQvsnivl7TlAA3EzYqOgqnGXRWJlrjbSpK4DsfNcwQdgf8aMusq517iqLBKRmLWfwJoGLF9DQCQbmEfECjkjG9HeVFp9LkofSuhmk4bmPKGYR3rGk3ixz6cRrQ4(dMu3iHDsfNcwQdeLeuE9ocu5tLlpFby9SbixHsRhO765qoJxHkabbmeW9xdtnGXRWJlrjbSpK497PVuXPGL6GrbpGjLeuE9ocu5g5ktxynsf3FWK6gjStQ4uWsDGOKGYR3rGkFQC55laRNna5kuA9aDxphYXUki4yjbGtV75roJxHkabbmeW9x1PgmVOAgVcpUeLeW(qI3VN(sfNcwQdgf8aMAzvaYvGaog5ktxynsf3FWu5udMxunJxHhxIscyFiX73tFPItbl1bJcEatTSka5kqahJCLPlSgPI7pysDJe2jvCkyPoqAzvaYvGaotLlNXRqfGGagc4(RHPgmVOAgVcpUeLeW(qI3VN(sfNcwQdgf8aMAzvaYvGaog5ktxynsf3FWK6gjStQ4uWsDG0YQaKRabCMkxUkofSuhikjO86DeOYNuNAaJxHhxIscyFiX73tFPItbl1bJcEatwrWDK0ldJCLPlSgPI7pyQCQbmEfECjkjG9HeVFp9LkofSuhmk4bmLx0G)JoqNldz9eT(omYvMs4cRrhWYV(onFQbmEfECjkjG9HeVFp9LkofSuhmk4bmLx0G)JoqNldz9eLUIrUYucxyn6aw(13P5tnGXRWJlrjbSpK497PVuXPGL6GrbpGP8Ig8F0b6CziRNiwXixzkHlSgDal)67KHlNAaJxHhxIscyFiX73tFPItbl1bJcEatScAW)rhOZLHSEIwFhg5ktjCH1Ody5xFNuVCQbmEfECjkjG9HeVFp9LkofSuhmk4bmLUcAW)rhOZLHSEIwFhg5ktjCH1Ody5xFNmC5udy8k84susa7djE)E6lvCkyPoyuWdyA9DGg8F0b6CziRNiwXixzkHlSgDal)67u5udy8k84susa7djE)E6lvCkyPoyuWdyA9DGg8F0b6CziRNiwXixz6cRrQ4(dMknJe2jvCkyPoqwFhOb)hDGoxgY6jIvMkxE(cW6zdqoIlwO0fbNLHW(yWXHAaJxHhxIscyFiX73tFPItbl1bJcEatRVd0G)JoqNldz9eXkg5ktxynsf3FWK6Z3iHDsfNcwQdK13bAW)rhOZLHSEIyLPYLJDvqWXscrt7ISmqnGXRWJlrjbSpK497PVuXPGL6GrbpGP13bAW)rhOZLHSEIyfJCLPlSgPI7pys95BKWoPItbl1bY67an4)Od05YqwprSYu5YXECEILWjMdaPK(r0uMCgVcvaccyiG7mLg1agVcpUeLeW(qI3VN(sfNcwQdgf8aMwFhOb)hDGoxgY6jIvmYvMUWAKkU)GP5BKWoPItbl1bY67an4)Od05YqwprSYu5udy8k84susa7djE)E6lvCkyPoyuWdyA9DGg8F0b6CziRNO0vmYvMs4cRrhWYV(oz4YPgW4v4XLOKa2hs8(90xQ4uWsDWOGhWKeNj3aObhmsbVg5ktjCH1Ody5xFNkNAaJxHhxIscyFiX73tFPItbl1bJcEatsCMCdGgCWif8AKRmDH1ivC)btYoplxTczh8DHSmKkU)a1WQxE5YiJrc7KkofSuhisCMCdGgCWif8ovUCSRccowsiAAxKLbQbmEfECjkjG9HeVFp9LkofSuhmk4bmjXzYnaAWbJuWRrUY0fwJuX9hmjRAPC1kKDW3fYYqQ4(dudRE5LlJmgjStQ4uWsDGiXzYnaAWbJuW7u5udy8k84susa7djE)E6lvCkyPoyuWdyIvqdrigVbAWbJuWRrUYucxyn6aw(13PYPgW4v4XLOKa2hs8(90xQ4uWsDWOGhWeRGgIqmEd0GdgPGxJCLPlSgPI7pyA(LBKWoPItbl1bcRGgIqmEd0GdgPG3PYLNVaSE2aKJ4IfkDrWzziSpgCCOgW4v4XLOKa2hs8(90xQ4uWsDWOGhWeRGgIqmEd0GdgPGxJCLPlSgPI7pyA(LBKWoPItbl1bcRGgIqmEd0GdgPG3PYLNVaSE2aKMuC7LHeybUdudy8k84susa7djE)E6lvCkyPoyuWdyIvqdrigVbAWbJuWRrUY0fwJuX9hmP(8nsyNuXPGL6aHvqdrigVbAWbJuW7u5udy8k84susa7djE)E6lvCkyPoyuWdyA9DGg8FeULZg4AKRmLWfwJoGLF9DYWudy8k84susa7djE)E6lvCkyPoyuWdyseQGCHdYvGasJCLPeUWA0bS8RVtLtnGXRWJlrjbSpK497PVuXPGL6GrbpGjrOcYfoixbcinYvMUWAKkU)Gj1nsyNuXPGL6areQGCHdYvGaYPYLVChILKVaqUfP4fqkx2L7qSeoXCaia36F(OMyxfeCSKsklfCiJCzvtSRccowsa407EE(8HXRqfGGagc4oP(Np5laRNna5kuA9aDxphYqnGXRWJlrjbSpK497PVuXPGL6GrbpGjrOcYfoixbcinYvMUWAKkU)GPYnsyNuXPGL6areQGCHdYvGaYPYPgW4v4XLOKa2hs8(90xQ4uWsDWOGhWeRG8a9UGrUY0fwJuX9hmbZJNqrboKbJzPeq3waw04Df4pFG5XtOOahstNpcE98IK4td85dmpEcff4qA68rWRNx0aoCVl84ZhyE8ekkWHC4SKH7b6a4sqkVnHlgcm85dmpEcff4qeXfNVLL6aAE84yFd0bujWWNpW84juuGd56VEh2venO8jv2NpW84juuGd5(cPU7hepGTTS7(5dmpEcff4qk4sGaYlYMEC(8bMhpHIcCi2opaKBrs8UDGAaJxHhxIscyFiX73tFPItbl1bJcEatSdO13bAW)r4woBGRrUYucxyn6aw(13jdtnyEr1mEfECjkjG9HeVFp9LkofSuhmk4bm1YQaKRabCmYvMUWAKkU)Gj1nsyNuXPGL6aPLvbixbc4mvU8lSRiAUeEGUk8ysDQbmEfECjkjG9HeVFp9LkofSuhmk4bmbQCKcEnYvMs4cRrhWYV(oP(8PgW4v4XLOKa2hs8(90xCI5aqwEi6coPgW4v4XLOKa2hs8(90xCI5aqIyHEhWl1agVcpUeLeW(qI3VN(c7HADVeqdoyudmOgW4v4XLOKa2hs8(90xdrMEIedUbOgW4v4XLOKa2hs8(90x20VRK3xJe2j1ufNcwQdeLeuE9ocu5tQlpFby9SbihXflu6IGZYqyFm44qnGXRWJlrjbSpK497PV4eZbGK68DnsyNutvCkyPoqusq517iqLpPUC1mFby9SbihXflu6IGZYqyFm44qnGXRWJlrjbSpK497PVavoMxHhgjStQ4uWsDGOKGYR3rGkFsDQbudy8k84(90xy)flKxfO3nsyNwoBGLCaPN1sW8DfrdjbgVudy8k84(90xQ4uWsDWOGhWulRcqUceWXixz6cRrQ4(dMu3iHDsfNcwQdKwwfGCfiGZu5YvsqfQbFiQtavoMxHhYvtzZxawpBaYvO06b6UEo(8jFby9Sbilmu8K7OcovKHAaJxHh3VN(sfNcwQdgf8aMAzvaYvGaog5ktxynsf3FWK6gjStQ4uWsDG0YQaKRabCMkxU0ZAjCI5aqkEbKKJxeYXU3pErq4eZbGu8cijjmyrCLlB(cW6zdqUcLwpq31ZXNp5laRNnazHHINChvWPImudy8k84(90xQ4uWsDWOGhWKveChj9YWixz6cRrQ4(dMu3iHDs6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxIC1u6zTK81bKBrBBcWL8uKBfnTlkHblI7mtYk7GdwTYmEfEq4eZbGK68Djy)UYOgMXRWdcNyoaKuNVlb(d43cOvmazOgW4v4X97PVWCVJy8k8a1f31OGhW0TLt4GWNl1agVcpUFp9fM7DeJxHhOU4Ugf8aMyhmsyNy8kubiiGHaU)AyQbmEfEC)E6lm37igVcpqDXDnk4bm5kqaPrc7KkofSuhiTSka5kqaNPYPgW4v4X97PVWCVJy8k8a1f31OGhWepqxfEyKWoDHDfrZLWd0vHhtQtnGXRWJ73tFH5EhX4v4bQlURrbpGjS79JxexQbmEfEC)E6lm37igVcpqDXDnk4bmL(YRWdJe2jvCkyPoqSIG7iPxgtLtnGXRWJ73tFH5EhX4v4bQlURrbpGjRi4os6LHrc7KkofSuhiwrWDK0lJj1PgW4v4X97PVWCVJy8k8a1f31OGhW0WvbdiwQbudMxunJxHhxcpqxfEmH5adDeJxHhgjStmEfEqavoMxHheClhb0frJ8bhmrbV)onVNp1agVcpUeEGUk847PVavoMxHhgjStdoyIcENzsfNcwQdeqLJuWRCzXU3pErqw)HBrUfTTaAWncscdwe3zMy8k8GaQCmVcpiWFa)waTIb85d29(XlccNyoaKIxajjHblI7mtmEfEqavoMxHhe4pGFlGwXa(8r2L7qSK8faYTifVas5y37hVii5laKBrkEbKKegSiUZmX4v4bbu5yEfEqG)a(TaAfdqgzKl9Sws(ca5wKIxaj54fHCPN1s4eZbGu8cijhViKFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFDaEBL8maJe2jS79JxeeoXCaifVasscdwe3PYLlR0ZAj5laKBrkEbKKJxeYLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVJpFWU3pErqw)HBrUfTTaAWncscdwe3PYLrgQbmEfECj8aDv4X3tFnez65f5w065aI1iHDc7E)4fbHtmhasXlGKKWGfXDQC5Yk9Sws(ca5wKIxaj54fHCzXU3pErqw)HBrUfTTaAWncscdwe3FvXPGL6aHvqd(p6aDUmK1t0674ZhS79JxeK1F4wKBrBlGgCJGKWGfXDQCzKHAaJxHhxcpqxfE890xjFeCSORcNLqnGXRWJlHhORcp(E6RBRWUIObP4fqAKWoj9SwcNyoaKIxaj54fHCS79JxeeoXCaifVasYMpaLWGfX9xgVcpi3wHDfrdsXlGKGpPCPN1sYxai3Iu8cijhViKJDVF8IGKVaqUfP4fqs28bOegSiU)Y4v4b52kSRiAqkEbKe8jLFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFLVaqUfP4fqAKWoj9Sws(ca5wKIxaj54fHCS79JxeeoXCaifVasscdwexQbmEfECj8aDv4X3tFT(d3IClABb0GBegjStYIDVF8IGWjMdaP4fqssyWI4ovUCPN1sYxai3Iu8cijhViK5ZhLeuHAWhI6K8faYTifVasQbmEfECj8aDv4X3tFT(d3IClABb0GBegjSty37hViiCI5aqkEbKKegSiUZm)YLl9Sws(ca5wKIxaj54fHC4EHadevIRWdKBrkqAb8k8Gabl1Hd1agVcpUeEGUk847PV4eZbGu8cinsyNKEwljFbGClsXlGKC8Iqo29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhudy8k84s4b6QWJVN(ItmhasIZKBaJe2jPN1s4eZbGu8cijpf5spRLWjMdaP4fqssyWI4oZeJxHheoXCaOH4EfD4sG)a(TaAfdqU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUeQbmEfECj8aDv4X3tFXjMda5PKrc7K0ZAjCI5aq4woBaYDzCjZi9SwcNyoaeULZgGm4)O7Y4sKl9Sws(ca5wKIxaj54fHCPN1s4eZbGu8cijhViKFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFXjMdajXzYnGrc7K0ZAj5laKBrkEbKKJxeYLEwlHtmhasXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlHAaJxHhxcpqxfE890xCI5aqdX9k6W1iHDs6zTeCh4eZ3venKey8AeULfXK6gbC2ldHBzrGe2jPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(i9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgQbmEfECj8aDv4X3tFXjMdane3ROdxJe2j1KlDaPybcNyoaKYBmGUiAiqWsD485J0ZAj4oWjMVRiAq4wocOtoEryeULfXK6gbC2ldHBzrGe2jPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(i9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgQbmEfECj8aDv4X3tFbQCmVcpmsyNKEwljFbGClsXlGKC8IqU0ZAjCI5aqkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fb1agVcpUeEGUk847PV4eZbG8uYiHDs6zTeoXCaiClNna5UmUKzKEwlHtmhac3Yzdqg8F0DzCjudy8k84s4b6QWJVN(ItmhasIZKBaQbmEfECj8aDv4X3tFXjMdaj157snGAaJxHhxc7WKn97k591iHDkFby9SbihXflu6IGZYqyFm44ih7E)4fbr6zTOJ4IfkDrWzziSpgCCijWNYKl9SwYrCXcLUi4Sme2hdooiB63LC8IqUSspRLWjMdaP4fqsoErix6zTK8faYTifVasYXlc5hq6zTK1F4wKBrBlGgCJGC8Iqg5y37hViiR)WTi3I2wan4gbjHblI7u5YLv6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLlRSl3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzQbFKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkY85JSQ5YDiws(ca5wKIxaPCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwrMpFWU3pErq4eZbGu8cijjmyrCNzQbFKrgQbmEfECjSdFp9LvKasQZ31iHDs28fG1ZgGCexSqPlcoldH9XGJJCS79JxeePN1IoIlwO0fbNLHW(yWXHKaFktU0ZAjhXflu6IGZYqyFm44GSIeihViKRKGkud(quNyt)UsEFL5ZhzZxawpBaYrCXcLUi4Sme2hdooYxXaMkxgQbmEfECjSdFp9Ln97IcxfBKWoLVaSE2aKMuC7LHeybUdYXU3pErq4eZbGu8cijjmyrC)T0kxo29(XlcY6pClYTOTfqdUrqsyWI4ovUCzLEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2ax5Yk7YDiws(ca5wKIxaPCS79JxeK8faYTifVasscdwe3zMAWh5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(iRAUChILKVaqUfP4fqkh7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhS79JxeeoXCaifVasscdwe3zMAWhzKHAaJxHhxc7W3tFzt)UOWvXgjSt5laRNnaPjf3EzibwG7GCS79JxeeoXCaifVasscdwe3PYLlRSYIDVF8IGS(d3IClABb0GBeKegSiU)QItbl1bcRGg8F0b6CziRNO13HCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjY85JSy37hViiR)WTi3I2wan4gbjHblI7u5YLEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2axzKrU0ZAj5laKBrkEbKKJxeYqnGXRWJlHD47PVw)HBrUfTTaAWncJe2P8fG1ZgGCfkTEGURNd5kjOc1Gpe1jGkhZRWdQbmEfECjSdFp9fNyoaKIxaPrc7u(cW6zdqUcLwpq31ZHCzvsqfQbFiQtavoMxHhF(OKGkud(quNS(d3IClABb0GBeYqnGXRWJlHD47PVavoMxHhgjStRya)wALlpFby9SbixHsRhO765qU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kh7E)4fbz9hUf5w02cOb3iijmyrCNkxo29(XlccNyoaKIxajjHblI7mtn4d1agVcpUe2HVN(cu5yEfEyKWoTIb8BPvU88fG1ZgGCfkTEGURNd5y37hViiCI5aqkEbKKegSiUtLlxwzLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVd5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sK5ZhzXU3pErqw)HBrUfTTaAWncscdwe3PYLl9SwcNyoaeULZgGCxgxYmtQ4uWsDGWoGwFhOb)hHB5SbUYiJCPN1sYxai3Iu8cijhViKXirSqMpLfjStspRLCfkTEGURNdYDzCjtspRLCfkTEGURNdYG)JUlJlXirSqMpLfjgd4i4fMuNAaJxHhxc7W3tFnez65f5w065aI1iHDswS79JxeeoXCaifVasscdwe3FvJZ)ZhS79JxeeoXCaifVasscdwe3zMknzKJDVF8IGS(d3IClABb0GBeKegSiUtLlxwPN1s4eZbGWTC2aK7Y4sMzsfNcwQde2b067an4)iClNnWvUSYUChILKVaqUfP4fqkh7E)4fbjFbGClsXlGKKWGfXDMPg8ro29(XlccNyoaKIxajjHblI7VZxMpFKvnxUdXsYxai3Iu8ciLJDVF8IGWjMdaP4fqssyWI4(78L5ZhS79JxeeoXCaifVasscdwe3zMAWhzKHAaJxHhxc7W3tFL8rWXIUkCwIrc7e29(XlcY6pClYTOTfqdUrqsyWI4od8hWVfqRyaYLv6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLlRSl3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzQbFKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkY85JSQ5YDiws(ca5wKIxaPCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwrMpFWU3pErq4eZbGu8cijjmyrCNzQbFKrgQbmEfECjSdFp9vYhbhl6QWzjgjSty37hViiCI5aqkEbKKegSiUZa)b8Bb0kgGCzLvwS79JxeK1F4wKBrBlGgCJGKWGfX9xvCkyPoqyf0G)JoqNldz9eT(oKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrMpFKf7E)4fbz9hUf5w02cOb3iijmyrCNkxU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kJmYLEwljFbGClsXlGKC8IqgQbmEfECjSdFp91b4TvYZamsyNWU3pErq4eZbGu8cijjmyrCNkxUSYkl29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLiZNpYIDVF8IGS(d3IClABb0GBeKegSiUtLlx6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLrg5spRLKVaqUfP4fqsoErid1agVcpUe2HVN(A9hUf5w02cOb3imsyNKEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2ax5Yk7YDiws(ca5wKIxaPCS79JxeK8faYTifVasscdwe3zMAWh5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(iRAUChILKVaqUfP4fqkh7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhS79JxeeoXCaifVasscdwe3zMAWhzOgW4v4XLWo890xCI5aqkEbKgjStYkl29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLiZNpYIDVF8IGS(d3IClABb0GBeKegSiUtLlx6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLrg5spRLKVaqUfP4fqsoErqnGXRWJlHD47PVYxai3Iu8cinsyNKEwljFbGClsXlGKC8IqUSYIDVF8IGS(d3IClABb0GBeKegSiU)A4YLl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrMpFKf7E)4fbz9hUf5w02cOb3iijmyrCNkxU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kJmYLf7E)4fbHtmhasXlGKKWGfX9x1n8Nphq6zTK1F4wKBrBlGgCJG8uKHAaJxHhxc7W3tFDBf2venifVasJe2jS79JxeeoXCaipLijmyrC)D(F(OMl3HyjCI5aqEkrnGXRWJlHD47PVus4cbgqUfneXXiHDs6zTKdWBRKNbqEkYpG0ZAjR)WTi3I2wan4gb5Pi)aspRLS(d3IClABb0GBeKegSiUZmj9SwIscxiWaYTOHioKb)hDxgxIAygVcpiCI5aqsD(Ue4pGFlGwXaOgW4v4XLWo890xCI5aqsD(UgjStspRLCaEBL8maYtrUSYUChILKW1doWGCgVcvaccyiG7mQrz(8HXRqfGGagc4oZ8LrUSQz(cW6zdq4eZbGK8HeNNbe7NplNnWsAbUVTef8(BPnFzOgW4v4XLWo890x3NcKHRIPgW4v4XLWo890xCI5aqsCMCdyKWoj9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlHAaJxHhxc7W3tFXjMda5PKrc7K0ZAjCI5aq4woBaYDzCjtLtnGXRWJlHD47PVcyBHeTWqbURrc7KSjyt42YsD4Zh1Cf4serJmYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLqnGXRWJlHD47PV4eZbGgI7v0HRrc7K0ZAj4oWjMVRiAijW4vE(cW6zdq4eZbGeHveITm5Yk7YDiwcpu6cRaZRWd5mEfQaeeWqa3zulY85dJxHkabbmeWDM5ld1agVcpUe2HVN(ItmhaAiUxrhUgjStspRLG7aNy(UIOHKaJx5l3HyjCI5aqaU1LFaPN1sw)HBrUfTTaAWncYtrUSl3Hyj8qPlScmVcp(8HXRqfGGagc4oZ8wgQbmEfECjSdFp9fNyoa0qCVIoCnsyNKEwlb3boX8DfrdjbgVYxUdXs4HsxyfyEfEiNXRqfGGagc4oJAKAaJxHhxc7W3tFXjMdab)v6(v4Hrc7K0ZAjCI5aq4woBaYDzCjZi9SwcNyoaeULZgGm4)O7Y4sOgW4v4XLWo890xCI5aqWFLUFfEyKWoj9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrUscQqn4drDcNyoaKeNj3audy8k84syh(E6lqLJ5v4HrIyHmFklsyNgCWef8(7KAz(gjIfY8PSiXyahbVWK6udOgmVOA1kLcpfRO0bq1VRiAO6MuC7Lr1cSa3bQUqSTunRqOA1GxGQflvxi2wQE9Dq1(2czH4ceQbmEfECjy37hViUt20VlkCvSrc7u(cW6zdqAsXTxgsGf4oih7E)4fbHtmhasXlGKKWGfX93sRC5y37hViiR)WTi3I2wan4gbjHblI7u5YLv6zTeoXCaiClNna5UmUKzMuXPGL6az9DGg8FeULZg4kxwzxUdXsYxai3Iu8ciLJDVF8IGKVaqUfP4fqssyWI4oZud(ih7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhzvZL7qSK8faYTifVas5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(GDVF8IGWjMdaP4fqssyWI4oZud(iJmudy8k84sWU3pErC)E6lB63ffUk2iHDkFby9SbinP42ldjWcChKJDVF8IGWjMdaP4fqssyWI4ovUCzvZL7qSei6IM2fc485JSl3Hyjq0fnTleWr(GdMOG3FNk9LlJmYLvwS79JxeK1F4wKBrBlGgCJGKWGfX9x1lxU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUez(8rwS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmvUmYix6zTK8faYTifVasYXlc5doyIcE)DsfNcwQdewbneHy8gObhmsbVudy8k84sWU3pErC)E6lB63vY7Rrc7u(cW6zdqoIlwO0fbNLHW(yWXro29(XlcI0ZArhXflu6IGZYqyFm44qsGpLjx6zTKJ4IfkDrWzziSpgCCq20Vl54fHCzLEwlHtmhasXlGKC8IqU0ZAj5laKBrkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fHmYXU3pErqw)HBrUfTTaAWncscdwe3PYLlR0ZAjCI5aq4woBaYDzCjZmPItbl1bY67an4)iClNnWvUSYUChILKVaqUfP4fqkh7E)4fbjFbGClsXlGKKWGfXDMPg8ro29(XlccNyoaKIxajjHblI7VQ4uWsDGS(oqd(p6aDUmK1teRiZNpYQMl3Hyj5laKBrkEbKYXU3pErq4eZbGu8cijjmyrC)vfNcwQdK13bAW)rhOZLHSEIyfz(8b7E)4fbHtmhasXlGKKWGfXDMPg8rgzOgW4v4XLGDVF8I4(90xwrciPoFxJe2P8fG1ZgGCexSqPlcoldH9XGJJCS79JxeePN1IoIlwO0fbNLHW(yWXHKaFktU0ZAjhXflu6IGZYqyFm44GSIeihViKRKGkud(quNyt)UsEFPgmVOA1q9cUSlv)Uavpez65LQleBlvZkeQwnGLQxFhuT4s1jWNYOA(s1fqVBevp4saQ((sGQxNQX8DPAXs1sG1tGQxFheQbmEfECjy37hViUFp91qKPNxKBrRNdiwJe2jS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmZKkofSuhiRVd0G)JWTC2ax5y37hViiCI5aqkEbKKegSiUZm1Gpudy8k84sWU3pErC)E6RHitpVi3IwphqSgjSty37hViiCI5aqkEbKKegSiUtLlxw1C5oelbIUOPDHaoF(i7YDiwceDrt7cbCKp4Gjk493PsF5YiJCzLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVd5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sK5ZhzXU3pErqw)HBrUfTTaAWncscdwe3PYLl9SwcNyoaeULZgGCxgxYu5YiJCPN1sYxai3Iu8cijhViKp4Gjk493jvCkyPoqyf0qeIXBGgCWif8snyEr1QH6fCzxQ(DbQ(a82k5zauDHyBPAwHq1QbSu967GQfxQob(ugvZxQUa6DJO6bxcq13xcu96unMVlvlwQwcSEcu967GqnGXRWJlb7E)4fX97PVoaVTsEgGrc7e29(XlcY6pClYTOTfqdUrqsyWI4ovUCPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGRCS79JxeeoXCaifVasscdwe3zMAWhQbmEfECjy37hViUFp91b4TvYZamsyNWU3pErq4eZbGu8cijjmyrCNkxUSQ5YDiwceDrt7cbC(8r2L7qSei6IM2fc4iFWbtuW7VtL(YLrg5Ykl29(XlcY6pClYTOTfqdUrqsyWI4(R6Llx6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxImF(il29(XlcY6pClYTOTfqdUrqsyWI4ovUCPN1s4eZbGWTC2aK7Y4sMkxgzKl9Sws(ca5wKIxaj54fH8bhmrbV)oPItbl1bcRGgIqmEd0GdgPGxQbZlQwn4fO6RcNLq1clvV(oOAoounRq1CcuThun(q1CCO6cpmEPAjGQFkuT1tQU7rdKu92YbvVTavp4)u9b6Czgr1dUer0q13xcuDbq1TSkGQ5LQ7aFxQElCQMtmhavJB5SbUunhhQEB5LQxFhuDbFdJxQwTU3DP63foeQbmEfECjy37hViUFp9vYhbhl6QWzjgjSty37hViiR)WTi3I2wan4gbjHblI7VQ4uWsDGKx0G)JoqNldz9eT(oKJDVF8IGWjMdaP4fqssyWI4(RkofSuhi5fn4)Od05YqwprSICzxUdXsYxai3Iu8ciLll29(Xlcs(ca5wKIxajjHblI7mWFa)waTIb85d29(Xlcs(ca5wKIxajjHblI7VQ4uWsDGKx0G)JoqNldz9eLUImF(OMl3Hyj5laKBrkEbKYix6zTeoXCaiClNna5UmUKFnS8di9SwY6pClYTOTfqdUrqoErix6zTK8faYTifVasYXlc5spRLWjMdaP4fqsoErqnyEr1QbVavFv4SeQUqSTunRq1fTqq1k(9kK6aHQvdyP613bvlUuDc8PmQMVuDb07gr1dUeGQVVeO61PAmFxQwSuTey9eO613bHAaJxHhxc29(XlI73tFL8rWXIUkCwIrc7e29(XlcY6pClYTOTfqdUrqsyWI4od8hWVfqRyaYLEwlHtmhac3YzdqUlJlzMjvCkyPoqwFhOb)hHB5SbUYXU3pErq4eZbGu8cijjmyrCNrw4pGFlGwXa(MXRWdY6pClYTOTfqdUrqG)a(TaAfdqgQbmEfECjy37hViUFp9vYhbhl6QWzjgjSty37hViiCI5aqkEbKKegSiUZa)b8Bb0kgGCzLvnxUdXsGOlAAxiGZNpYUChILarx00Uqah5doyIcE)DQ0xUmYixwzXU3pErqw)HBrUfTTaAWncscdwe3FvXPGL6aHvqd(p6aDUmK1t067qU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUez(8rwS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmvUmYix6zTK8faYTifVasYXlc5doyIcE)DsfNcwQdewbneHy8gObhmsbVYqnyEr1QbVavV(oO6cX2s1ScvlSuTyn(s1fITveu92cu9G)t1hOZLrOA1awQo81iQ(DbQUqSTuD6kuTWs1Blq1l3HyPAXLQxUeimIQ54q1I14lvxi2wrq1Blq1d(pvFGoxgHAaJxHhxc29(XlI73tFT(d3IClABb0GBegjStspRLWjMdaHB5Sbi3LXLmZKkofSuhiRVd0G)JWTC2ax5y37hViiCI5aqkEbKKegSiUZmb)b8Bb0kgG8bhmrbV)QItbl1bcRGgIqmEd0GdgPGx5spRLKVaqUfP4fqsoErqnGXRWJlb7E)4fX97PVw)HBrUfTTaAWncJe2jPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGR8L7qSK8faYTifVas5y37hVii5laKBrkEbKKegSiUZmb)b8Bb0kgGCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwro29(XlccNyoaKIxajjHblI7VQByQbmEfECjy37hViUFp916pClYTOTfqdUryKWoj9SwcNyoaeULZgGCxgxYmtQ4uWsDGS(oqd(pc3YzdCLlRAUChILKVaqUfP4fq(5d29(Xlcs(ca5wKIxajjHblI7VQ4uWsDGS(oqd(p6aDUmK1tu6kYih7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvOgmVOA1GxGQzfQwyP613bvlUuThun(q1CCO6cpmEPAjGQFkuT1tQU7rdKu92YbvVTavp4)u9b6Czgr1dUer0q13xcu92YlvxauDlRcOAi8xtlvp4GPAoou92YlvVTqcuT4s1HVun3tGpLr1mvNVaOA3s1kEbKu9Xlcc1agVcpUeS79Jxe3VN(ItmhasXlG0iHDc7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVd5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sKl9Sws(ca5wKIxaj54fH8bhmrbV)oPItbl1bcRGgIqmEd0GdgPGxQbZlQwn4fO60vOAHLQxFhuT4s1Eq14dvZXHQl8W4LQLaQ(Pq1wpP6Uhnqs1Blhu92cu9G)t1hOZLzevp4serdvFFjq1BlKavlUHXlvZ9e4tzunt15laQ(4fbvZXHQ3wEPAwHQl8W4LQLaSpaQMvXIol1bQ(8sr0q15lac1agVcpUeS79Jxe3VN(kFbGClsXlG0iHDs6zTeoXCaifVasYXlc5YIDVF8IGS(d3IClABb0GBeKegSiU)QItbl1bs6kOb)hDGoxgY6jA9D85d29(XlccNyoaKIxajjHblI7mtQ4uWsDGS(oqd(p6aDUmK1teRiJCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjYXU3pErq4eZbGu8cijjmyrC)vDdtnGXRWJlb7E)4fX97PVUTc7kIgKIxaPrc7K0ZAjCI5aqkEbKKJxeYXU3pErq4eZbGu8cijB(aucdwe3Fz8k8GCBf2venifVasc(KYLEwljFbGClsXlGKC8Iqo29(Xlcs(ca5wKIxajzZhGsyWI4(lJxHhKBRWUIObP4fqsWNu(bKEwlz9hUf5w02cOb3iihViOgmVOA1GxGQv8bvVovFNhpakDaunhun8FtMQzjQweu92cuDa)xQg7E)4fbvxiIJxyev)IoCVuDjLLcoO6TfcQ2JEzu95LIOHQ5eZbq1kEbKu95bu96uDRxq1doyQU9fnzzuDYhbhlvFv4SeQwCPgW4v4XLGDVF8I4(90xkjCHadi3IgI4yKWoTChILKVaqUfP4fqkx6zTeoXCaifVasYtrU0ZAj5laKBrkEbKKegSiUZ0GpKb)NAaJxHhxc29(XlI73tFPKWfcmGClAiIJrc70bKEwlz9hUf5w02cOb3iipf5hq6zTK1F4wKBrBlGgCJGKWGfXDggVcpiCI5aqdX9k6WLa)b8Bb0kgGC1e7QGGJLuszPGdQbmEfECjy37hViUFp9LscxiWaYTOHiogjStspRLKVaqUfP4fqsEkYLEwljFbGClsXlGKKWGfXDMg8Hm4)YXU3pErqavoMxHhKe4tzYXU3pErqw)HBrUfTTaAWncscdwex5Qj2vbbhlPKYsbhudOgW4v4XLyfb3rsVm(E6loXCaOH4EfD4AKWoj9SwcUdCI57kIgscmEnc3YIysDQbmEfECjwrWDK0lJVN(ItmhasQZ3LAaJxHhxIveChj9Y47PV4eZbGK4m5gGAa1agVcpUKHRcgqSFp9LuxeLG4OmJe2PHRcgqSKJ4UCGHFNuVCQbmEfECjdxfmGy)E6lLeUqGbKBrdrCOgW4v4XLmCvWaI97PV4eZbGgI7v0HRrc70WvbdiwYrCxoWWmQxo1agVcpUKHRcgqSFp9fNyoaKNsudy8k84sgUkyaX(90xwrciPoFxQbudy8k84sCfiGCcu5yEfEyKWojB(cW6zdqUcLwpq31ZXNp5laRNnazHHINChvWPImYxUdXsYxai3Iu8ciLJDVF8IGKVaqUfP4fqssyWI4kxwPN1sYxai3Iu8cijhVi(8rjbvOg8HOoHtmhasIZKBazOgW4v4XL4kqa53tFzfjGK68DnsyNYxawpBaYrCXcLUi4Sme2hdooYLEwl5iUyHsxeCwgc7JbhhKn97sEkudy8k84sCfiG87PVSPFxu4QyJe2P8fG1ZgG0KIBVmKalWDq(GdMOG3FN3ZNAaJxHhxIRabKFp91b4TvYZamsyNuZ8fG1ZgGCfkTEGURNdQbmEfECjUceq(90xjFeCSORcNLyKWon4Gjk49x1y5udy8k84sCfiG87PVUTc7kIgKIxaPrc7K0ZAjCI5aqkEbKKJxeYXU3pErq4eZbGu8cijjmyrCLRItbl1bIiub5chKRabKQ5K6udy8k84sCfiG87PV4eZbG8uYiHDsfNcwQderOcYfoixbciNuxo29(Xlcs(ca5wKIxajjHblI7u5udy8k84sCfiG87PV4eZbGK68DnsyNuXPGL6areQGCHdYvGaYj1LJDVF8IGKVaqUfP4fqssyWI4ovUCPN1s4eZbGWTC2aK7Y4sMr6zTeoXCaiClNnazW)r3LXLqnGXRWJlXvGaYVN(kFbGClsXlG0iHDsfNcwQderOcYfoixbciNuxU0ZAj5laKBrkEbKKJxeudy8k84sCfiG87PVu8v4Hrc7KkofSuhiIqfKlCqUceqoPUC1u28fG1ZgGCfkTEGURNJpFYxawpBaYcdfp5oQGtfzOgW4v4XL4kqa53tFDaEBL8maJe2jPN1sYxai3Iu8cijhViOgW4v4XL4kqa53tFnez65f5w065aI1iHDs6zTK8faYTifVasYXlIpFusqfQbFiQt4eZbGK4m5gGAaJxHhxIRabKFp916pClYTOTfqdUryKWoj9Sws(ca5wKIxaj54fXNpkjOc1Gpe1jCI5aqsCMCdqnGXRWJlXvGaYVN(ItmhasXlG0iHDsjbvOg8HOoz9hUf5w02cOb3iOgW4v4XL4kqa53tFLVaqUfP4fqAKWoj9Sws(ca5wKIxaj54fb1agVcpUexbci)E6lLeUqGbKBrdrCmsyNoG0ZAjR)WTi3I2wan4gb5Pi)aspRLS(d3IClABb0GBeKegSiUZW4v4bHtmhaAiUxrhUe4pGFlGwXaOgW4v4XL4kqa53tFPKWfcmGClAiIJrc70YDiws(ca5wKIxaPCPN1s4eZbGu8cijpf5spRLKVaqUfP4fqssyWI4otd(qg8FQbmEfECjUceq(90xCI5aqsD(UgjSthFjjFeCSORcNLqsyWI4(78)85aspRLK8rWXIUkCwcs1RhqYsIUylJCxgxYVLtnGXRWJlXvGaYVN(ItmhasQZ31iHDs6zTeLeUqGbKBrdrCipf5hq6zTK1F4wKBrBlGgCJG8uKFaPN1sw)HBrUfTTaAWncscdwe3zMy8k8GWjMdaj157sG)a(TaAfdGAaJxHhxIRabKFp9fNyoaKeNj3agjStspRLKVaqUfP4fqsEkYXU3pErq4eZbGu8cijjWNYKp4Gjk4Dg1y5YLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLixnZxawpBaYvO06b6UEoKRM5laRNnazHHINChvWPc1agVcpUexbci)E6loXCaijotUbmsyNKEwljFbGClsXlGK8uKl9SwcNyoaKIxaj54fHCPN1sYxai3Iu8cijjmyrCNzQbFKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrUkofSuhiIqfKlCqUceqsnGXRWJlXvGaYVN(ItmhaAiUxrhUgjSthq6zTK1F4wKBrBlGgCJG8uKVChILWjMdab4wxUSspRLCaEBL8maYXlIpFy8kubiiGHaUtQlJ8di9SwY6pClYTOTfqdUrqsyWI4(lJxHheoXCaOH4EfD4sG)a(TaAfdqUSQjx6asXceoXCaiL3yaDr0qGGL6W5ZhPN1sWDGtmFxr0GWTCeqNC8IqgJWTSiMu3iGZEziCllcKWoj9SwcUdCI57kIgeULJa6KJxeYLv6zTeoXCaifVasYt5ZhzvZL7qSexfKkEbKWrUSspRLKVaqUfP4fqsEkF(GDVF8IGaQCmVcpijWNYKrgzOgW4v4XL4kqa53tFXjMdane3ROdxJe2jPN1sWDGtmFxr0qsGXRCS79JxeeoXCaifVasscdwex5Yk9Sws(ca5wKIxaj5P85J0ZAjCI5aqkEbKKNImgHBzrmPo1agVcpUexbci)E6loXCaipLmsyNKEwlHtmhac3YzdqUlJlzMjvCkyPoqwFhOb)hHB5SbUYLf7E)4fbHtmhasXlGKKWGfX9x1l)ZhgVcvaccyiG7mtgwgQbmEfECjUceq(90xCI5aqsD(UgjStspRLKVaqUfP4fqsEkF(m4Gjk49x1Np1agVcpUexbci)E6lqLJ5v4Hrc7K0ZAj5laKBrkEbKKJxeYLEwlHtmhasXlGKC8IWirSqMpLfjStdoyIcE)DsTmFJeXcz(uwKymGJGxysDQbmEfECjUceq(90xCI5aqsCMCdqnGAW8IQz8k84ssF5v4X3tFH5adDeJxHhgjStmEfEqavoMxHheClhb0frJ8bhmrbV)onVNVCzvZ8fG1ZgGCfkTEGURNJpFKEwl5kuA9aDxphK7Y4sMKEwl5kuA9aDxphKb)hDxgxImudy8k84ssF5v4X3tFbQCmVcpmsyNgCWef8oZKkofSuhiGkhPGx5YIDVF8IGS(d3IClABb0GBeKegSiUZmX4v4bbu5yEfEqG)a(TaAfd4ZhS79JxeeoXCaifVasscdwe3zMy8k8GaQCmVcpiWFa)waTIb85JSl3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzIXRWdcOYX8k8Ga)b8Bb0kgGmYix6zTK8faYTifVasYXlc5spRLWjMdaP4fqsoEri)aspRLS(d3IClABb0GBeKJxeYvtLeuHAWhI6K1F4wKBrBlGgCJGAaJxHhxs6lVcp(E6lqLJ5v4Hrc7u(cW6zdqUcLwpq31ZHCS79JxeeoXCaifVasscdwe3zMy8k8GaQCmVcpiWFa)waTIbqnyEr1)WzYnavlSuTyn(s1Ryau96u97cu967GQ54q1fav3YQaQEDNQhCugvJB5SbUudy8k84ssF5v4X3tFXjMdajXzYnGrc7e29(XlcY6pClYTOTfqdUrqsGpLjxwPN1s4eZbGWTC2aK7Y4s(vfNcwQdK13bAW)r4woBGRCS79JxeeoXCaifVasscdwe3zMG)a(TaAfdq(GdMOG3FvXPGL6aHvqdrigVbAWbJuWRCPN1sYxai3Iu8cijhViKHAaJxHhxs6lVcp(E6loXCaijotUbmsyNWU3pErqw)HBrUfTTaAWncsc8Pm5Yk9SwcNyoaeULZgGCxgxYVQ4uWsDGS(oqd(pc3YzdCLVChILKVaqUfP4fqkh7E)4fbjFbGClsXlGKKWGfXDMj4pGFlGwXaKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkYqnGXRWJlj9LxHhFp9fNyoaKeNj3agjSty37hViiR)WTi3I2wan4gbjb(uMCzLEwlHtmhac3YzdqUlJl5xvCkyPoqwFhOb)hHB5SbUYLvnxUdXsYxai3Iu8ci)8b7E)4fbjFbGClsXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jkDfzKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkYqnGXRWJlj9LxHhFp9fNyoaKeNj3agjSthq6zTKKpcow0vHZsqQE9asws0fBzK7Y4sMoG0ZAjjFeCSORcNLGu96bKSKOl2Yid(p6UmUe5Yk9SwcNyoaKIxaj54fXNpspRLWjMdaP4fqssyWI4oZud(iJCzLEwljFbGClsXlGKC8I4ZhPN1sYxai3Iu8cijjmyrCNzQbFKHAaJxHhxs6lVcp(E6loXCaiPoFxJe2PJVKKpcow0vHZsijmyrC)vT85JShq6zTKKpcow0vHZsqQE9asws0fBzK7Y4s(TC5hq6zTKKpcow0vHZsqQE9asws0fBzK7Y4sM5aspRLK8rWXIUkCwcs1RhqYsIUylJm4)O7Y4sKHAaJxHhxs6lVcp(E6loXCaiPoFxJe2jPN1sus4cbgqUfneXH8uKFaPN1sw)HBrUfTTaAWncYtr(bKEwlz9hUf5w02cOb3iijmyrCNzIXRWdcNyoaKuNVlb(d43cOvmaQbmEfECjPV8k847PV4eZbGgI7v0HRrc70bKEwlz9hUf5w02cOb3iipf5l3HyjCI5aqaU1LlR0ZAjhG3wjpdGC8I4ZhgVcvaccyiG7K6Yix2di9SwY6pClYTOTfqdUrqsyWI4(lJxHheoXCaOH4EfD4sG)a(TaAfd4ZhS79JxeeLeUqGbKBrdrCijmyrC)8b7QGGJLuszPGdzKlRAYLoGuSaHtmhas5ngqxeneiyPoC(8r6zTeCh4eZ3veniClhb0jhViKXiCllIj1nc4Sxgc3YIajStspRLG7aNy(UIObHB5iGo54fHCzLEwlHtmhasXlGK8u(8rw1C5oelXvbPIxajCKlR0ZAj5laKBrkEbKKNYNpy37hViiGkhZRWdsc8PmzKrgQbmEfECjPV8k847PV4eZbGgI7v0HRrc7K0ZAj4oWjMVRiAijW4vU0ZAjWFfooWbP4leRG7KNc1agVcpUK0xEfE890xCI5aqdX9k6W1iHDs6zTeCh4eZ3venKey8kxwPN1s4eZbGu8cijpLpFKEwljFbGClsXlGK8u(85aspRLS(d3IClABb0GBeKegSiU)Y4v4bHtmhaAiUxrhUe4pGFlGwXaKXiCllIj1PgW4v4XLK(YRWJVN(ItmhaAiUxrhUgjStspRLG7aNy(UIOHKaJx5spRLG7aNy(UIOHCxgxYK0ZAj4oWjMVRiAid(p6UmUeJWTSiMuNAaJxHhxs6lVcp(E6loXCaOH4EfD4AKWoj9SwcUdCI57kIgscmELl9SwcUdCI57kIgscdwe3zMKvwPN1sWDGtmFxr0qUlJlrnmJxHheoXCaOH4EfD4sG)a(TaAfdqMVBWhzmc3YIysDQbmEfECjPV8k847PVcyBHeTWqbURrc7KSjyt42YsD4Zh1Cf4serJmYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLix6zTeoXCaifVasYXlc5hq6zTK1F4wKBrBlGgCJGC8IGAaJxHhxs6lVcp(E6loXCaipLmsyNKEwlHtmhac3YzdqUlJlzMjvCkyPoqwFhOb)hHB5SbUudy8k84ssF5v4X3tFDFkqgUk2iHDAWbtuW7mtZ75lx6zTeoXCaifVasYXlc5spRLKVaqUfP4fqsoEri)aspRLS(d3IClABb0GBeKJxeudy8k84ssF5v4X3tFXjMdaj157AKWoj9Sws(6aYTOTnb4sEkYLEwlHtmhac3YzdqUlJl53sJAaJxHhxs6lVcp(E6loXCaijotUbmsyNgCWef8oZKkofSuhisCMCdGgCWif8kx6zTeoXCaifVasYXlc5spRLKVaqUfP4fqsoEri)aspRLS(d3IClABb0GBeKJxeYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLih7E)4fbbu5yEfEqsyWI4snGXRWJlj9LxHhFp9fNyoaKeNj3agjStspRLWjMdaP4fqsoErix6zTK8faYTifVasYXlc5hq6zTK1F4wKBrBlGgCJGC8IqU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUe5l3HyjCI5aqEkjh7E)4fbHtmhaYtjscdwe3zMAWh5doyIcENzAExUCS79JxeeqLJ5v4bjHblIl1agVcpUK0xEfE890xCI5aqsCMCdyKWoj9SwcNyoaKIxaj5Pix6zTeoXCaifVasscdwe3zMAWh5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sKJDVF8IGaQCmVcpijmyrCPgW4v4XLK(YRWJVN(ItmhasIZKBaJe2jPN1sYxai3Iu8cijpf5spRLWjMdaP4fqsoErix6zTK8faYTifVasscdwe3zMAWh5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sKJDVF8IGaQCmVcpijmyrCPgW4v4XLK(YRWJVN(ItmhasIZKBaJe2jPN1s4eZbGu8cijhViKl9Sws(ca5wKIxaj54fH8di9SwY6pClYTOTfqdUrqEkYpG0ZAjR)WTi3I2wan4gbjHblI7mtn4JCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjudy8k84ssF5v4X3tFXjMdajXzYnGrc70YzdSKwG7BlrbVZuAZxU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUe55laRNnaHtmhasYhsCEgqSYz8kubiiGHaU)QUCPN1soaVTsEga54fb1agVcpUK0xEfE890xCI5aqWFLUFfEyKWoTC2alPf4(2suW7mL28Ll9SwcNyoaeULZgGCxgxYmspRLWjMdaHB5Sbid(p6UmUe55laRNnaHtmhasYhsCEgqSYz8kubiiGHaU)QUCPN1soaVTsEga54fb1agVcpUK0xEfE890xCI5aqsD(Uudy8k84ssF5v4X3tFbQCmVcpmsyNKEwljFbGClsXlGKC8IqU0ZAjCI5aqkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fb1agVcpUK0xEfE890xCI5aqsCMCdqnGAaJxHhxYTLt4GWN73tF9UaAWbJAGHrc7KSl3Hyjq0fnTleWr(GdMOG3zMulLlFWbtuW7VtZZ5lZNpYQMl3Hyjq0fnTleWr(GdMOG3zMulZxgQbmEfECj3woHdcFUFp9LIVcpmsyNKEwlHtmhasXlGK8uOgW4v4XLCB5eoi85(90xRyaOcovmsyNYxawpBaYcdfp5oQGtf5spRLa)B53DfEqEkYLf7E)4fbHtmhasXlGKKaFk7ZhROPDrjmyrCNzsnwUmudy8k84sUTCche(C)E6RUOPDVi16ENMbeRrc7K0ZAjCI5aqkEbKKJxeYLEwljFbGClsXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViOgW4v4XLCB5eoi85(90xsCdYTOnf4sUgjStspRLWjMdaP4fqsoErix6zTK8faYTifVasYXlc5hq6zTK1F4wKBrBlGgCJGC8IGAaJxHhxYTLt4GWN73tFjb5fYserJrc7K0ZAjCI5aqkEbKKNc1agVcpUKBlNWbHp3VN(sQ7(bzFzzgjStspRLWjMdaP4fqsEkudy8k84sUTCche(C)E6lRibPU7hJe2jPN1s4eZbGu8cijpfQbmEfECj3woHdcFUFp9fhy4Uj3ryU3nsyNKEwlHtmhasXlGK8uOgW4v4XLCB5eoi85(90xVlGelmUgjStspRLWjMdaP4fqsEkudy8k84sUTCche(C)E6R3fqIfggbwlGxuWdyQPZhbVEErs8PbmsyNKEwlHtmhasXlGK8u(8b7E)4fbHtmhasXlGKKWGfX93P5pF5hq6zTK1F4wKBrBlGgCJG8uOgW4v4XLCB5eoi85(90xVlGelmmk4bmbdLYsG7ippbhyWiHDc7E)4fbHtmhasXlGKKWGfXDMjdxo1agVcpUKBlNWbHp3VN(6DbKyHHrbpGPtc8XksaPcUxOBKWoHDVF8IGWjMdaP4fqssyWI4(7KHl)ZhvCkyPoqyfKhO3fuZj1)8r2vmGPYLRItbl1bIiub5chKRabKtQlpFby9SbixHsRhO765qgQbmEfECj3woHdcFUFp917ciXcdJcEatx)1rIMqSqAKWoHDVF8IGWjMdaP4fqssyWI4(7KHl)ZhvCkyPoqyfKhO3fuZj1)8r2vmGPYLRItbl1bIiub5chKRabKtQlpFby9SbixHsRhO765qgQbmEfECj3woHdcFUFp917ciXcdJcEatn9YuArUfX3Ryi68k8WiHDc7E)4fbHtmhasXlGKKWGfX93jdx(NpQ4uWsDGWkipqVlOMtQ)5JSRyatLlxfNcwQderOcYfoixbciNuxE(cW6zdqUcLwpq31ZHmudy8k84sUTCche(C)E6R3fqIfggf8aMgmMLsaDBbyrJ3vGnsyNWU3pErq4eZbGu8cijjmyrCNzA(YLvfNcwQderOcYfoixbcivZj1)8zfd43sRCzOgW4v4XLCB5eoi85(90xVlGelmmk4bmnymlLa62cWIgVRaBKWoHDVF8IGWjMdaP4fqssyWI4oZ08LRItbl1bIiub5chKRabKtQlx6zTK8faYTifVasYtrU0ZAj5laKBrkEbKKegSiUZmjR6LRwX8vdNVaSE2aKRqP1d0D9CiJ8vmGzkTYRM8BB9SAAkgVoVcpm0KTBDRBTca]] )


end
