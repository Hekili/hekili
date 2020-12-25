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


    spec:RegisterPack( "Arcane", 20201225, [[dWelLeqisk6rkQsUefkqTjIQprHmkIsNIOyvKuq9kvLAwuq3IcfWUq8lvLmmjQogjvlJcvptIuMgjf6AkQQTPOk6BsKQghfk6CkQsTosk18uuCpfzFQQ0bjPGSqvv8qkuAIuOqLlsHc5JsKk1jjPawjfyMKuYnPqHQ2PIs)uIurdLcfilLcf0tPOPQOYvjPa9vjsLmwjs2RK(lKbtQdJAXe5XqnzvCzWMP0NLIrlLonHvtHcLxlrmBP62kSBHFt1WjXXvufwUONRstxPRRkBNK8DjmEvvDEjkRxIuH5RQy)iDv96CvZdVqDwJxUXlxDJB85tuF(gV8st9Q5wMcunvyCjCdundEavt1qjMdOAQWL1D(uNRAE9xIHQz7Ukx1(RVAeB7tIG9XxxX415v4boz7(1vmWFvnLEI(QgiQsvZdVqDwJxUXlxDJB85tuF(gVC1nMvZRcGRZopnE1SvCoquLQMh4IRMZlQ2y8Cdq1QHsmha1G5fvBmoaddjiPAJpFdPAJxUXlNAa1G5fvBmegUkGQvXPGL6aHhORcpOArq1wwLNuTBP6lSRiAUeEGUk8GQLf3c4sO6Y8xs1xfat1UYk84kdHAW8IQvdQC4fouTiwidUt1TCC6IOHQDlvRItbl1bslRcqUceWHQxNQLaQwDQUOfcQ(c7kIMlHhORcpO6jQwDc1G5fvRg8cu9wMIaZDQ2ummwQULJtxenuTBPAClhb0PArSqMpLv4bvlI7c8HQDlvBeMdm0rmEfEyeHAW8IQngDVqGHlvNWWvbhQMVuTBP6zDvWqcsQ24gtQEDQoHZdduTXAmi1GuTS3UOPD7LjdPA2f39wNRA6kqazDU6SQxNRAcbl1Ht9NQjoflKcUAklvNVaSE2aKRqP1d0D9CqGGL6WHQ)8HQZxawpBaYcdfp5oQGtfceSuhouTmuTCQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCPA5uTSuT0ZAj5laKBrkEbKKJxeu9NpuTscQqn4drDcNyoaKeNj3auTmvtgVcpQMGkhZRWJ6wN1415QMqWsD4u)PAItXcPGRM5laRNna5iUyHsxeCwgc7JbhhceSuhouTCQw6zTKJ4IfkDrWzziSpgCCq20Vl5Punz8k8OAAfjGK68DRBD2sRox1ecwQdN6pvtCkwifC1mFby9SbinP42ldjWcChiqWsD4q1YP6bhmrbVu9Vu98E(vtgVcpQM20VlkCvCDRZQgRZvnHGL6WP(t1eNIfsbxnvtQoFby9SbixHsRhO765Gabl1Ht1KXRWJQ5b4TvYZaQBD25xNRAcbl1Ht9NQjoflKcUAo4Gjk4LQ)LQvJLxnz8k8OAM8rWXIUkCwsDRZopRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGKC8IGQLt1y37hViiCI5aqkEbKKegSiUuTCQwfNcwQderOcYfoixbciPA1CIQvVAY4v4r182kSRiAqkEbK1ToBPVox1ecwQdN6pvtCkwifC1ufNcwQderOcYfoixbciP6jQwDQwovJDVF8IGKVaqUfP4fqssyWI4s1tuD5vtgVcpQMCI5aqEkv36SgZ6CvtiyPoCQ)unXPyHuWvtvCkyPoqeHkix4GCfiGKQNOA1PA5un29(Xlcs(ca5wKIxajjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6zOAPN1s4eZbGWTC2aKb)hDxgxs1KXRWJQjNyoaKuNVBDRZoVRZvnHGL6WP(t1eNIfsbxnvXPGL6areQGCHdYvGasQEIQvNQLt1spRLKVaqUfP4fqsoErunz8k8OAMVaqUfP4fqw36SQxEDUQjeSuho1FQM4uSqk4QPkofSuhiIqfKlCqUceqs1tuT6uTCQwnPAzP68fG1ZgGCfkTEGURNdceSuhou9NpuD(cW6zdqwyO4j3rfCQqGGL6WHQLPAY4v4r1uXxHh1ToR6QxNRAcbl1Ht9NQjoflKcUAk9Sws(ca5wKIxaj54fr1KXRWJQ5b4TvYZaQBDw1nEDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxeu9NpuTscQqn4drDcNyoaKeNj3avtgVcpQMdrMEErUfTEoGyRBDw1lT6CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijhViO6pFOALeuHAWhI6eoXCaijotUbQMmEfEunx)HBrUfTTaAWnI6wNvD1yDUQjeSuho1FQM4uSqk4QPscQqn4drDY6pClYTOTfqdUrunz8k8OAYjMdaP4fqw36SQp)6CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijhViQMmEfEunZxai3Iu8ciRBDw1NN15QMqWsD4u)PAItXcPGRMhq6zTK1F4wKBrBlGgCJG8uOA5u9bKEwlz9hUf5w02cOb3iijmyrCP6zOAgVcpiCI5aqdX9k6WLa)b8Bb0kgq1KXRWJQPscxiWaYTOHio1ToR6L(6CvtiyPoCQ)unXPyHuWvZL7qSK8faYTifVasceSuhouTCQw6zTeoXCaifVasYtHQLt1spRLKVaqUfP4fqssyWI4s1Zq1n4dzW)RMmEfEunvs4cbgqUfneXPU1zv3ywNRAcbl1Ht9NQjoflKcUAE8LK8rWXIUkCwcjHblIlv)lvpFQ(ZhQ(aspRLK8rWXIUkCwcs1RhqYsIUylJCxgxcv)lvxE1KXRWJQjNyoaKuNVBDRZQ(8Uox1ecwQdN6pvtCkwifC1u6zTeLeUqGbKBrdrCipfQwovFaPN1sw)HBrUfTTaAWncYtHQLt1hq6zTK1F4wKBrBlGgCJGKWGfXLQNzIQz8k8GWjMdaj157sG)a(TaAfdOAY4v4r1KtmhasQZ3TU1znE515QMqWsD4u)PAItXcPGRMspRLKVaqUfP4fqsEkuTCQg7E)4fbHtmhasXlGKKaFkJQLt1doyIcEP6zOA1y5uTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTCQwnP68fG1ZgGCfkTEGURNdceSuhouTCQwnP68fG1ZgGSWqXtUJk4uHabl1Ht1KXRWJQjNyoaKeNj3a1ToRXvVox1ecwQdN6pvtCkwifC1u6zTK8faYTifVasYtHQLt1spRLWjMdaP4fqsoErq1YPAPN1sYxai3Iu8cijjmyrCP6zMO6g8HQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLt1Q4uWsDGicvqUWb5kqaz1KXRWJQjNyoaKeNj3a1ToRXnEDUQjeSuho1FQM4wwevt1RMaN9Yq4wweiHTAk9SwcUdCI57kIgeULJa6KJxeYLv6zTeoXCaifVasYt5ZhzvZL7qSexfKkEbKWrUSspRLKVaqUfP4fqsEkF(GDVF8IGaQCmVcpijWNYKrgzQM4uSqk4Q5bKEwlz9hUf5w02cOb3iipfQwovVChILWjMdab4wNabl1HdvlNQLLQLEwl5a82k5zaKJxeu9NpunJxHkabbmeWLQNOA1PAzOA5u9bKEwlz9hUf5w02cOb3iijmyrCP6FPAgVcpiCI5aqdX9k6WLa)b8Bb0kgavlNQLLQvtQMlDaPybcNyoaKYBmGUiAiqWsD4q1F(q1spRLG7aNy(UIObHB5iGo54fbvlt1KXRWJQjNyoa0qCVIoCRBDwJxA15QMqWsD4u)PAY4v4r1KtmhaAiUxrhUvtCllIQP6vtCkwifC1u6zTeCh4eZ3venKey8s1YPAS79JxeeoXCaifVasscdwexQwovllvl9Sws(ca5wKIxaj5Pq1F(q1spRLWjMdaP4fqsEkuTm1ToRXvJ15QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGS(oqd(pc3YzdCPA5uTSun29(XlccNyoaKIxajjHblIlv)lvRE5u9NpunJxHkabbmeWLQNzIQnovlt1KXRWJQjNyoaKNs1ToRXNFDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKNcv)5dvp4Gjk4LQ)LQvF(vtgVcpQMCI5aqsD(U1ToRXNN15QMqWsD4u)PAY4v4r1eu5yEfEunfXcz(uwKWwnhCWef8(7KXC(vtrSqMpLfjgd4i4fQMQxnXPyHuWvtPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxe1ToRXl915QMmEfEun5eZbGK4m5gOAcbl1Ht9N6w3Q5bS8RV15QZQEDUQjeSuho1FQM4uSqk4Q5YzdSKdi9SwcMVRiAijW4TAY4v4r1e7VyH8Qa9EDRZA86CvtiyPoCQ)unDLQ5f2QjJxHhvtvCkyPounvX9hunvVAItXcPGRMQ4uWsDG0YQaKRabCO6jQUCQwovRKGkud(quNaQCmVcpOA5uTAs1Ys15laRNna5kuA9aDxpheiyPoCO6pFO68fG1ZgGSWqXtUJk4uHabl1Hdvlt1ufNOGhq1SLvbixbc4u36SLwDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMQxnXPyHuWvtvCkyPoqAzvaYvGaou9evxovlNQLEwlHtmhasXlGKC8IGQLt1y37hViiCI5aqkEbKKegSiUuTCQwwQoFby9SbixHsRhO765Gabl1Hdv)5dvNVaSE2aKfgkEYDubNkeiyPoCOAzQMQ4ef8aQMTSka5kqaN6wNvnwNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQP6vtCkwifC1u6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTCQwnPAPN1sYxhqUfTTjaxYtHQLt1wrt7IsyWI4s1Zmr1Ys1Ys1doyQ(lQMXRWdcNyoaKuNVlb73LQLHQvdt1mEfEq4eZbGK68DjWFa)waTIbq1YunvXjk4bunTIG7iPxg1To78RZvnHGL6WP(t1KXRWJQjM7DeJxHhOU4UvZU4UOGhq182YjCq4ZTU1zNN15QMqWsD4u)PAItXcPGRMmEfQaeeWqaxQ(xQ24vtgVcpQMyU3rmEfEG6I7wn7I7IcEavt2H6wNT0xNRAcbl1Ht9NQjoflKcUAQItbl1bslRcqUceWHQNO6YRMmEfEunXCVJy8k8a1f3TA2f3ff8aQMUceqw36SgZ6CvtiyPoCQ)unXPyHuWvZlSRiAUeEGUk8GQNOA1RMmEfEunXCVJy8k8a1f3TA2f3ff8aQM8aDv4rDRZoVRZvnHGL6WP(t1KXRWJQjM7DeJxHhOU4UvZU4UOGhq1e7E)4fXTU1zvV86CvtiyPoCQ)unXPyHuWvtvCkyPoqSIG7iPxgu9evxE1KXRWJQjM7DeJxHhOU4UvZU4UOGhq1m9LxHh1ToR6QxNRAcbl1Ht9NQjoflKcUAQItbl1bIveChj9YGQNOA1RMmEfEunXCVJy8k8a1f3TA2f3ff8aQMwrWDK0lJ6wNvDJxNRAcbl1Ht9NQjJxHhvtm37igVcpqDXDRMDXDrbpGQ5Wvbdi26w3Qz6lVcpQZvNv96CvtiyPoCQ)unXPyHuWvZbhmrbVu9mtuTkofSuhiGkhPGxQwovllvJDVF8IGS(d3IClABb0GBeKegSiUu9mtunJxHheqLJ5v4bb(d43cOvmaQ(ZhQg7E)4fbHtmhasXlGKKWGfXLQNzIQz8k8GaQCmVcpiWFa)waTIbq1F(q1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZevZ4v4bbu5yEfEqG)a(TaAfdGQLHQLHQLt1spRLKVaqUfP4fqsoErq1YPAPN1s4eZbGu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViOA5uTAs1kjOc1Gpe1jR)WTi3I2wan4gr1KXRWJQjOYX8k8OU1znEDUQjeSuho1FQM4uSqk4Qz(cW6zdqUcLwpq31ZbbcwQdhQwovJDVF8IGWjMdaP4fqssyWI4s1Zmr1mEfEqavoMxHhe4pGFlGwXaQMmEfEunbvoMxHh1ToBPvNRAcbl1Ht9NQjoflKcUAIDVF8IGS(d3IClABb0GBeKe4tzuTCQwwQw6zTeoXCaiClNna5UmUeQ(xQwfNcwQdK13bAW)r4woBGlvlNQXU3pErq4eZbGu8cijjmyrCP6zMOA4pGFlGwXaOA5u9GdMOGxQ(xQwfNcwQdewbneHy8gObhmsbVuTCQw6zTK8faYTifVasYXlcQwMQjJxHhvtoXCaijotUbQBDw1yDUQjeSuho1FQM4uSqk4Qj29(XlcY6pClYTOTfqdUrqsGpLr1YPAzPAPN1s4eZbGWTC2aK7Y4sO6FPAvCkyPoqwFhOb)hHB5SbUuTCQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMOA4pGFlGwXaOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvlt1KXRWJQjNyoaKeNj3a1To78RZvnHGL6WP(t1eNIfsbxnXU3pErqw)HBrUfTTaAWncsc8PmQwovllvl9SwcNyoaeULZgGCxgxcv)lvRItbl1bY67an4)iClNnWLQLt1Ys1QjvVChILKVaqUfP4fqsGGL6WHQ)8HQXU3pErqYxai3Iu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jkDfQwgQwovJDVF8IGWjMdaP4fqssyWI4s1)s1Q4uWsDGS(oqd(p6aDUmK1teRq1Yunz8k8OAYjMdajXzYnqDRZopRZvnHGL6WP(t1eNIfsbxnpG0ZAjjFeCSORcNLGu96bKSKOl2Yi3LXLq1tu9bKEwlj5JGJfDv4SeKQxpGKLeDXwgzW)r3LXLq1YPAzPAPN1s4eZbGu8cijhViO6pFOAPN1s4eZbGu8cijjmyrCP6zMO6g8HQLHQLt1Ys1spRLKVaqUfP4fqsoErq1F(q1spRLKVaqUfP4fqssyWI4s1Zmr1n4dvlt1KXRWJQjNyoaKeNj3a1ToBPVox1ecwQdN6pvtCkwifC184lj5JGJfDv4SescdwexQ(xQ2ys1F(q1Ys1hq6zTKKpcow0vHZsqQE9asws0fBzK7Y4sO6FP6YPA5u9bKEwlj5JGJfDv4SeKQxpGKLeDXwg5UmUeQEgQ(aspRLK8rWXIUkCwcs1RhqYsIUylJm4)O7Y4sOAzQMmEfEun5eZbGK68DRBDwJzDUQjeSuho1FQM4uSqk4QP0ZAjkjCHadi3IgI4qEkuTCQ(aspRLS(d3IClABb0GBeKNcvlNQpG0ZAjR)WTi3I2wan4gbjHblIlvpZevZ4v4bHtmhasQZ3La)b8Bb0kgq1KXRWJQjNyoaKuNVBDRZoVRZvnHGL6WP(t1e3YIOAQE1e4Sxgc3YIajSvtPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(iRAUChIL4QGuXlGeoYLv6zTK8faYTifVasYt5ZhS79JxeeqLJ5v4bjb(uMmYit1eNIfsbxnpG0ZAjR)WTi3I2wan4gb5Pq1YP6L7qSeoXCaia36eiyPoCOA5uTSuT0ZAjhG3wjpdGC8IGQ)8HQz8kubiiGHaUu9evRovldvlNQLLQpG0ZAjR)WTi3I2wan4gbjHblIlv)lvZ4v4bHtmhaAiUxrhUe4pGFlGwXaO6pFOAS79JxeeLeUqGbKBrdrCijmyrCP6pFOASRccowsjLLcoOAzOA5uTSuTAs1CPdiflq4eZbGuEJb0frdbcwQdhQ(ZhQw6zTeCh4eZ3veniClhb0jhViOAzQMmEfEun5eZbGgI7v0HBDRZQE515QMqWsD4u)PAItXcPGRMspRLG7aNy(UIOHKaJxQwovl9Swc8xHJdCqk(cXk4o5Punz8k8OAYjMdane3ROd36wNvD1RZvnHGL6WP(t1KXRWJQjNyoa0qCVIoCRM4wwevt1RM4uSqk4QP0ZAj4oWjMVRiAijW4LQLt1Ys1spRLWjMdaP4fqsEku9NpuT0ZAj5laKBrkEbKKNcv)5dvFaPN1sw)HBrUfTTaAWncscdwexQ(xQMXRWdcNyoa0qCVIoCjWFa)waTIbq1Yu36SQB86CvtiyPoCQ)unz8k8OAYjMdane3ROd3QjULfr1u9QjoflKcUAk9SwcUdCI57kIgscmEPA5uT0ZAj4oWjMVRiAi3LXLq1tuT0ZAj4oWjMVRiAid(p6UmUK6wNv9sRox1ecwQdN6pvtgVcpQMCI5aqdX9k6WTAIBzrunvVAItXcPGRMspRLG7aNy(UIOHKaJxQwovl9SwcUdCI57kIgscdwexQEMjQwwQwwQw6zTeCh4eZ3venK7Y4sOA1WunJxHheoXCaOH4EfD4sG)a(TaAfdGQLHQ)MQBWhQwM6wNvD1yDUQjeSuho1FQM4uSqk4QPSuDc2eUTSuhO6pFOA1KQxbUer0q1Yq1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1YPAPN1s4eZbGu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViQMmEfEundyBHeTWqbUBDRZQ(8RZvnHGL6WP(t1eNIfsbxnLEwlHtmhac3YzdqUlJlHQNzIQvXPGL6az9DGg8FeULZg4wnz8k8OAYjMda5PuDRZQ(8Sox1ecwQdN6pvtCkwifC1CWbtuWlvpZevpVNpvlNQLEwlHtmhasXlGKC8IGQLt1spRLKVaqUfP4fqsoErq1YP6di9SwY6pClYTOTfqdUrqoErunz8k8OAEFkqgUkUU1zvV0xNRAcbl1Ht9NQjoflKcUAk9Sws(6aYTOTnb4sEkuTCQw6zTeoXCaiClNna5UmUeQ(xQU0QMmEfEun5eZbGK68DRBDw1nM15QMqWsD4u)PAItXcPGRMdoyIcEP6zMOAvCkyPoqK4m5gan4Grk4LQLt1spRLWjMdaP4fqsoErq1YPAPN1sYxai3Iu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOA5un29(XlccOYX8k8GKWGfXTAY4v4r1KtmhasIZKBG6wNv95DDUQjeSuho1FQM4uSqk4QP0ZAjCI5aqkEbKKJxeuTCQw6zTK8faYTifVasYXlcQwovFaPN1sw)HBrUfTTaAWncYXlcQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovVChILWjMda5PebcwQdhQwovJDVF8IGWjMda5PejHblIlvpZev3GpuTCQEWbtuWlvpZevpVlNQLt1y37hViiGkhZRWdscdwe3QjJxHhvtoXCaijotUbQBDwJxEDUQjeSuho1FQM4uSqk4QP0ZAjCI5aqkEbKKNcvlNQLEwlHtmhasXlGKKWGfXLQNzIQBWhQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovJDVF8IGaQCmVcpijmyrCRMmEfEun5eZbGK4m5gOU1znU615QMqWsD4u)PAItXcPGRMspRLKVaqUfP4fqsEkuTCQw6zTeoXCaifVasYXlcQwovl9Sws(ca5wKIxajjHblIlvpZev3GpuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTCQg7E)4fbbu5yEfEqsyWI4wnz8k8OAYjMdajXzYnqDRZACJxNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj54fbvlNQLEwljFbGClsXlGKC8IGQLt1hq6zTK1F4wKBrBlGgCJG8uOA5u9bKEwlz9hUf5w02cOb3iijmyrCP6zMO6g8HQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlPAY4v4r1KtmhasIZKBG6wN14LwDUQjeSuho1FQM4uSqk4Q5YzdSKwG7BlrbVu9muDPnFQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovNVaSE2aeoXCaijFiX5zaXsGGL6WHQLt1mEfQaeeWqaxQ(xQwDQwovl9SwYb4TvYZaihViQMmEfEun5eZbGK4m5gOU1znUASox1ecwQdN6pvtCkwifC1C5SbwslW9TLOGxQEgQU0MpvlNQLEwlHtmhac3YzdqUlJlHQNHQLEwlHtmhac3Yzdqg8F0DzCjuTCQoFby9SbiCI5aqs(qIZZaILabl1HdvlNQz8kubiiGHaUu9VuT6uTCQw6zTKdWBRKNbqoErunz8k8OAYjMdab)v6(v4rDRZA85xNRAY4v4r1KtmhasQZ3TAcbl1Ht9N6wN14ZZ6CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxevtgVcpQMGkhZRWJ6wN14L(6CvtgVcpQMCI5aqsCMCdunHGL6WP(tDRB1KDOoxDw1RZvnHGL6WP(t1eNIfsbxnZxawpBaYrCXcLUi4Sme2hdooeiyPoCOA5un29(XlcI0ZArhXflu6IGZYqyFm44qsGpLr1YPAPN1soIlwO0fbNLHW(yWXbzt)UKJxeuTCQwwQw6zTeoXCaifVasYXlcQwovl9Sws(ca5wKIxaj54fbvlNQpG0ZAjR)WTi3I2wan4gb54fbvldvlNQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1Ys1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvldvlt1KXRWJQPn97k59TU1znEDUQjeSuho1FQM4uSqk4QPSuD(cW6zdqoIlwO0fbNLHW(yWXHabl1HdvlNQXU3pErqKEwl6iUyHsxeCwgc7Jbhhsc8PmQwovl9SwYrCXcLUi4Sme2hdooiRibYXlcQwovRKGkud(quNyt)UsEFPAzO6pFOAzP68fG1ZgGCexSqPlcoldH9XGJdbcwQdhQwovVIbq1tuD5uTmvtgVcpQMwrciPoF36wNT0QZvnHGL6WP(t1eNIfsbxnZxawpBastkU9YqcSa3bceSuhouTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQlTYPA5un29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQwwQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzOAzQMmEfEunTPFxu4Q46wNvnwNRAcbl1Ht9NQjoflKcUAMVaSE2aKMuC7LHeybUdeiyPoCOA5un29(XlccNyoaKIxajjHblIlvpr1Lt1YPAzPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvXPGL6aHvqd(p6aDUmK1t067GQLt1spRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLHQ)8HQLLQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLt1spRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGWoGwFhOb)hHB5SbUuTmuTmuTCQw6zTK8faYTifVasYXlcQwMQjJxHhvtB63ffUkUU1zNFDUQjeSuho1FQM4uSqk4Qz(cW6zdqUcLwpq31ZbbcwQdhQwovRKGkud(quNaQCmVcpQMmEfEunx)HBrUfTTaAWnI6wNDEwNRAcbl1Ht9NQjoflKcUAMVaSE2aKRqP1d0D9CqGGL6WHQLt1Ys1kjOc1Gpe1jGkhZRWdQ(ZhQwjbvOg8HOoz9hUf5w02cOb3iOAzQMmEfEun5eZbGu8ciRBD2sFDUQjeSuho1FQM4uSqk4Q5kgav)lvxALt1YP68fG1ZgGCfkTEGURNdceSuhouTCQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLt1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAS79JxeeoXCaifVasscdwexQEMjQUbFQMmEfEunbvoMxHh1ToRXSox1ecwQdN6pvtgVcpQMGkhZRWJQPiwiZNYIe2QP0ZAjxHsRhO765GCxgxYK0ZAjxHsRhO765Gm4)O7Y4sQMIyHmFklsmgWrWlunvVAItXcPGRMRyau9VuDPvovlNQZxawpBaYvO06b6UEoiqWsD4q1YPAS79JxeeoXCaifVasscdwexQEIQlNQLt1Ys1Ys1Ys1y37hViiR)WTi3I2wan4gbjHblIlv)lvRItbl1bcRGg8F0b6CziRNO13bvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvldv)5dvllvJDVF8IGS(d3IClABb0GBeKegSiUu9evxovlNQLEwlHtmhac3YzdqUlJlHQNzIQvXPGL6aHDaT(oqd(pc3YzdCPAzOAzOA5uT0ZAj5laKBrkEbKKJxeuTm1To78Uox1ecwQdN6pvtCkwifC1uwQg7E)4fbHtmhasXlGKKWGfXLQ)LQvJZNQ)8HQXU3pErq4eZbGu8cijjmyrCP6zMO6sJQLHQLt1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAzPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqyhqRVd0G)JWTC2axQwovllvllvVChILKVaqUfP4fqsGGL6WHQLt1y37hVii5laKBrkEbKKegSiUu9mtuDd(q1YPAS79JxeeoXCaifVasscdwexQ(xQE(uTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvpFQwgQ(ZhQg7E)4fbHtmhasXlGKKWGfXLQNzIQBWhQwgQwMQjJxHhvZHitpVi3IwphqS1ToR6LxNRAcbl1Ht9NQjoflKcUAIDVF8IGS(d3IClABb0GBeKegSiUu9mun8hWVfqRyauTCQwwQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzOAzQMmEfEunt(i4yrxfolPU1zvx96CvtiyPoCQ)unXPyHuWvtS79JxeeoXCaifVasscdwexQEgQg(d43cOvmaQwovllvllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuTkofSuhiScAW)rhOZLHSEIwFhuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTmu9NpuTSun29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLHQLHQLt1spRLKVaqUfP4fqsoErq1Yunz8k8OAM8rWXIUkCwsDRZQUXRZvnHGL6WP(t1eNIfsbxnXU3pErq4eZbGu8cijjmyrCP6jQUCQwovllvllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuTkofSuhiScAW)rhOZLHSEIwFhuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTmu9NpuTSun29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLHQLHQLt1spRLKVaqUfP4fqsoErq1Yunz8k8OAEaEBL8mG6wNv9sRox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEMjQwfNcwQde2b067an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzQMmEfEunx)HBrUfTTaAWnI6wNvD1yDUQjeSuho1FQM4uSqk4QPSuTSun29(XlcY6pClYTOTfqdUrqsyWI4s1)s1Q4uWsDGWkOb)hDGoxgY6jA9Dq1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1Yq1F(q1Ys1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqyhqRVd0G)JWTC2axQwgQwgQwovl9Sws(ca5wKIxaj54fr1KXRWJQjNyoaKIxazDRZQ(8RZvnHGL6WP(t1eNIfsbxnLEwljFbGClsXlGKC8IGQLt1Ys1Ys1y37hViiR)WTi3I2wan4gbjHblIlv)lvB8YPA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOAzO6pFOAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQNO6YPA5uT0ZAjCI5aq4woBaYDzCju9mtuTkofSuhiSdO13bAW)r4woBGlvldvldvlNQLLQXU3pErq4eZbGu8cijjmyrCP6FPA1nov)5dvFaPN1sw)HBrUfTTaAWncYtHQLPAY4v4r1mFbGClsXlGSU1zvFEwNRAcbl1Ht9NQjoflKcUAIDVF8IGWjMda5PejHblIlv)lvpFQ(ZhQwnP6L7qSeoXCaipLiqWsD4unz8k8OAEBf2venifVaY6wNv9sFDUQjeSuho1FQM4uSqk4QP0ZAjhG3wjpdG8uOA5u9bKEwlz9hUf5w02cOb3iipfQwovFaPN1sw)HBrUfTTaAWncscdwexQEMjQw6zTeLeUqGbKBrdrCid(p6UmUeQwnmvZ4v4bHtmhasQZ3La)b8Bb0kgq1KXRWJQPscxiWaYTOHio1ToR6gZ6CvtiyPoCQ)unXPyHuWvtPN1soaVTsEga5Pq1YPAzPAzP6L7qSKeUEWbgiqWsD4q1YPAgVcvaccyiGlvpdvRgPAzO6pFOAgVcvaccyiGlvpdvpFQwgQwovllvRMuD(cW6zdq4eZbGK8HeNNbelbcwQdhQ(ZhQE5SbwslW9TLOGxQ(xQU0Mpvlt1KXRWJQjNyoaKuNVBDRZQ(8Uox1KXRWJQ59Paz4Q4QjeSuho1FQBDwJxEDUQjeSuho1FQM4uSqk4QP0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sQMmEfEun5eZbGK4m5gOU1znU615QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1tuD5vtgVcpQMCI5aqEkv36Sg3415QMqWsD4u)PAItXcPGRMYs1jyt42YsDGQ)8HQvtQEf4serdvldvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxs1KXRWJQzaBlKOfgkWDRBDwJxA15QMqWsD4u)PAItXcPGRMspRLG7aNy(UIOHKaJxQwovNVaSE2aeoXCairyfHylJabl1HdvlNQLLQLLQxUdXs4HsxyfyEfEqGGL6WHQLt1mEfQaeeWqaxQEgQ2ys1Yq1F(q1mEfQaeeWqaxQEgQE(uTmvtgVcpQMCI5aqdX9k6WTU1znUASox1ecwQdN6pvtCkwifC1u6zTeCh4eZ3venKey8s1YP6L7qSeoXCaia36eiyPoCOA5u9bKEwlz9hUf5w02cOb3iipfQwovllvVChILWdLUWkW8k8Gabl1Hdv)5dvZ4vOcqqadbCP6zO65nvlt1KXRWJQjNyoa0qCVIoCRBDwJp)6CvtiyPoCQ)unXPyHuWvtPN1sWDGtmFxr0qsGXlvlNQxUdXs4HsxyfyEfEqGGL6WHQLt1mEfQaeeWqaxQEgQwnwnz8k8OAYjMdane3ROd36wN14ZZ6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGWTC2aK7Y4sO6zOAPN1s4eZbGWTC2aKb)hDxgxs1KXRWJQjNyoae8xP7xHh1ToRXl915QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1tuT0ZAjCI5aq4woBaYG)JUlJlHQLt1kjOc1Gpe1jCI5aqsCMCdunz8k8OAYjMdab)v6(v4rDRZACJzDUQPiwiZNYIe2Q5GdMOG3FNmMZVAkIfY8PSiXyahbVq1u9QjJxHhvtqLJ5v4r1ecwQdN6p1TUvZHRcgqS15QZQEDUQjeSuho1FQM4uSqk4Q5WvbdiwYrCxoWav)7evRE5vtgVcpQMsDrusDRZA86CvtgVcpQMkjCHadi3IgI4unHGL6WP(tDRZwA15QMqWsD4u)PAItXcPGRMdxfmGyjhXD5adu9muT6Lxnz8k8OAYjMdane3ROd36wNvnwNRAY4v4r1KtmhaYtPQjeSuho1FQBD25xNRAY4v4r10ksaj157wnHGL6WP(tDRB1ujbSpK4ToxDw1RZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavtLeuE9ocu5vZdy5xFRMLx36SgVox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvt1RM4uSqk4QPkofSuhikjO86DeOYP6jQUCQwovNVaSE2aKRqP1d0D9CqGGL6WHQLt1mEfQaeeWqaxQ(xQ24vtvCIcEavtLeuE9ocu51ToBPvNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQP6vtCkwifC1ufNcwQdeLeuE9ocu5u9evxovlNQZxawpBaYvO06b6UEoiqWsD4q1YPASRccowsa407EEOA5unJxHkabbmeWLQ)LQvVAQItuWdOAQKGYR3rGkVU1zvJ15QMqWsD4u)PA6kvZlSvtgVcpQMQ4uWsDOAQI7pOAwE1ufNOGhq10kcUJKEzu36SZVox1ecwQdN6pvtxPAMWf2QjJxHhvtvCkyPounvXjk4bunZlAW)rhOZLHSEIwFhvZdy5xFRMZVU1zNN15QMqWsD4u)PA6kvZeUWwnz8k8OAQItbl1HQPkorbpGQzErd(p6aDUmK1tu6kvZdy5xFRMZVU1zl915QMqWsD4u)PA6kvZeUWwnz8k8OAQItbl1HQPkorbpGQzErd(p6aDUmK1teRunpGLF9TAA8YRBDwJzDUQjeSuho1FQMUs1mHlSvtgVcpQMQ4uWsDOAQItuWdOAYkOb)hDGoxgY6jA9DunpGLF9TAQE51To78Uox1ecwQdN6pvtxPAMWf2QjJxHhvtvCkyPounvXjk4buntxbn4)Od05YqwprRVJQ5bS8RVvtJxEDRZQE515QMqWsD4u)PA6kvZeUWwnz8k8OAQItbl1HQPkorbpGQ567an4)Od05YqwprSs18aw(13Qz51ToR6QxNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQzPvnXPyHuWvtvCkyPoqwFhOb)hDGoxgY6jIvO6jQUCQwovNVaSE2aKJ4IfkDrWzziSpgCCiqWsD4unvXjk4bunxFhOb)hDGoxgY6jIvQBDw1nEDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMQp)QjoflKcUAQItbl1bY67an4)Od05YqwprScvpr1Lt1YPASRccowsiAAxKLHQPkorbpGQ567an4)Od05YqwprSsDRZQEPvNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQP6ZVAItXcPGRMQ4uWsDGS(oqd(p6aDUmK1teRq1tuD5uTCQg7X5jwcNyoaKs6hrtzeiyPoCOA5unJxHkabbmeWLQNHQlTQPkorbpGQ567an4)Od05YqwprSsDRZQUASox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvZ5xnXPyHuWvtvCkyPoqwFhOb)hDGoxgY6jIvO6jQU8QPkorbpGQ567an4)Od05YqwprSsDRZQ(8RZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavZ13bAW)rhOZLHSEIsxPAEal)6B104Lx36SQppRZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavtjotUbqdoyKcERMhWYV(wnlVU1zvV0xNRAcbl1Ht9NQPRunVWwnz8k8OAQItbl1HQPkU)GQPSu98SCQ2yaQwwQEW3fYYqQ4(dOA1WuT6Lxovldvlt1eNIfsbxnvXPGL6arIZKBa0GdgPGxQEIQlNQLt1yxfeCSKq00UildvtvCIcEavtjotUbqdoyKcERBDw1nM15QMqWsD4u)PA6kvZlSvtgVcpQMQ4uWsDOAQI7pOAklvBmlNQngGQLLQh8DHSmKkU)aQwnmvRE5Lt1Yq1YunXPyHuWvtvCkyPoqK4m5gan4Grk4LQNO6YRMQ4ef8aQMsCMCdGgCWif8w36SQpVRZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavtwbneHy8gObhmsbVvZdy5xFRMLx36SgV86CvtiyPoCQ)unDLQ5f2QjJxHhvtvCkyPounvX9hunNF5vtCkwifC1ufNcwQdewbneHy8gObhmsbVu9evxovlNQZxawpBaYrCXcLUi4Sme2hdooeiyPoCQMQ4ef8aQMScAicX4nqdoyKcERBDwJREDUQjeSuho1FQMUs18cB1KXRWJQPkofSuhQMQ4(dQMZV8QjoflKcUAQItbl1bcRGgIqmEd0GdgPGxQEIQlNQLt15laRNnaPjf3EzibwG7abcwQdNQPkorbpGQjRGgIqmEd0GdgPG36wN14gVox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvt1NF1eNIfsbxnvXPGL6aHvqdrigVbAWbJuWlvpr1LxnvXjk4bunzf0qeIXBGgCWif8w36SgV0QZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavZ13bAW)r4woBGB18aw(13QPXRBDwJRgRZvnHGL6WP(t10vQMjCHTAY4v4r1ufNcwQdvtvCIcEavtrOcYfoixbciRMhWYV(wnlVU1zn(8RZvnHGL6WP(t10vQMxyRMmEfEunvXPGL6q1uf3Fq1u9QjoflKcUAQItbl1bIiub5chKRabKu9evxovlNQxUdXsYxai3Iu8cijqWsD4q1YPAzP6L7qSeoXCaia36eiyPoCO6pFOA1KQXUki4yjLuwk4GQLHQLt1Ys1QjvJDvqWXscaNE3Zdv)5dvZ4vOcqqadbCP6jQwDQ(ZhQoFby9SbixHsRhO765Gabl1Hdvlt1ufNOGhq1ueQGCHdYvGaY6wN14ZZ6CvtiyPoCQ)unDLQ5f2QjJxHhvtvCkyPounvX9hunlVAItXcPGRMQ4uWsDGicvqUWb5kqajvpr1LxnvXjk4bunfHkix4GCfiGSU1znEPVox1ecwQdN6pvtxPAEHTAY4v4r1ufNcwQdvtvC)bvtyE8ekkWHmymlLa62cWIgVRat1F(q1W84juuGdPPZhbVEErs8PbO6pFOAyE8ekkWH005JGxpVObC4Ex4bv)5dvdZJNqrboKdNLmCpqhaxcs5TjCXqGbQ(ZhQgMhpHIcCiI4IZ3YsDanpECSVb6aQeyGQ)8HQH5XtOOahY1F9oSRiAq5tQmQ(ZhQgMhpHIcCi3xi1D)G4bSTLDxQ(ZhQgMhpHIcCifCjqa5fztpou9NpunmpEcff4qSDEai3IK4D7q1ufNOGhq1KvqEGExOU1znUXSox1ecwQdN6pvtxPAMWf2QjJxHhvtvCkyPounvXjk4bunzhqRVd0G)JWTC2a3Q5bS8RVvtJx36SgFExNRAcbl1Ht9NQPRunt4cB1KXRWJQPkofSuhQMQ4ef8aQMGkhPG3Q5bS8RVvt1NFDRZwALxNRAY4v4r18(gdpqCI5aqwEi6coRMqWsD4u)PU1zln1RZvnz8k8OAYjMdajIf6DaVvtiyPoCQ)u36SLMXRZvnz8k8OAI9WySxcObhmQbgvtiyPoCQ)u36SLwPvNRAY4v4r1CiY0tKyWnq1ecwQdN6p1ToBPPgRZvnHGL6WP(t1eNIfsbxnvtQwfNcwQdeLeuE9ocu5u9evRovlNQZxawpBaYrCXcLUi4Sme2hdooeiyPoCQMmEfEunTPFxjVV1ToBPn)6CvtiyPoCQ)unXPyHuWvt1KQvXPGL6arjbLxVJavovpr1Qt1YPA1KQZxawpBaYrCXcLUi4Sme2hdooeiyPoCQMmEfEun5eZbGK68DRBD2sBEwNRAcbl1Ht9NQjoflKcUAQItbl1bIsckVEhbQCQEIQvVAY4v4r1eu5yEfEu36wn5b6QWJ6C1zvVox1ecwQdN6pvtCkwifC1CWbtuWlvpZevRItbl1bcOYrk4LQLt1Ys1y37hViiR)WTi3I2wan4gbjHblIlvpZevZ4v4bbu5yEfEqG)a(TaAfdGQ)8HQXU3pErq4eZbGu8cijjmyrCP6zMOAgVcpiGkhZRWdc8hWVfqRyau9NpuTSu9YDiws(ca5wKIxajbcwQdhQwovJDVF8IGKVaqUfP4fqssyWI4s1Zmr1mEfEqavoMxHhe4pGFlGwXaOAzOAzOA5uT0ZAj5laKBrkEbKKJxeuTCQw6zTeoXCaifVasYXlcQwovFaPN1sw)HBrUfTTaAWncYXlIQjJxHhvtqLJ5v4rDRZA86CvtiyPoCQ)unXPyHuWvtS79JxeeoXCaifVasscdwexQEIQlNQLt1Ys1spRLKVaqUfP4fqsoErq1YPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvXPGL6aHvqd(p6aDUmK1t067GQ)8HQXU3pErqw)HBrUfTTaAWncscdwexQEIQlNQLHQLPAY4v4r18a82k5za1ToBPvNRAcbl1Ht9NQjoflKcUAIDVF8IGWjMdaP4fqssyWI4s1tuD5uTCQwwQw6zTK8faYTifVasYXlcQwovllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuTkofSuhiScAW)rhOZLHSEIwFhu9Npun29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTmuTmvtgVcpQMdrMEErUfTEoGyRBDw1yDUQjJxHhvZKpcow0vHZsQMqWsD4u)PU1zNFDUQjeSuho1FQM4uSqk4QP0ZAjCI5aqkEbKKJxeuTCQg7E)4fbHtmhasXlGKS5dqjmyrCP6FPAgVcpi3wHDfrdsXlGKGpjvlNQLEwljFbGClsXlGKC8IGQLt1y37hVii5laKBrkEbKKnFakHblIlv)lvZ4v4b52kSRiAqkEbKe8jPA5u9bKEwlz9hUf5w02cOb3iihViQMmEfEunVTc7kIgKIxazDRZopRZvnHGL6WP(t1eNIfsbxnLEwljFbGClsXlGKC8IGQLt1y37hViiCI5aqkEbKKegSiUvtgVcpQM5laKBrkEbK1ToBPVox1ecwQdN6pvtCkwifC1uwQg7E)4fbHtmhasXlGKKWGfXLQNO6YPA5uT0ZAj5laKBrkEbKKJxeuTmu9NpuTscQqn4drDs(ca5wKIxaz1KXRWJQ56pClYTOTfqdUru36SgZ6CvtiyPoCQ)unXPyHuWvtS79JxeeoXCaifVasscdwexQEgQE(Lt1YPAPN1sYxai3Iu8cijhViOA5unCVqGbIkXv4bYTifiTaEfEqGGL6WPAY4v4r1C9hUf5w02cOb3iQBD25DDUQjeSuho1FQM4uSqk4QP0ZAj5laKBrkEbKKJxeuTCQg7E)4fbz9hUf5w02cOb3iijmyrCP6FPAvCkyPoqyf0G)JoqNldz9eT(oQMmEfEun5eZbGu8ciRBDw1lVox1ecwQdN6pvtCkwifC1u6zTeoXCaifVasYtHQLt1spRLWjMdaP4fqssyWI4s1Zmr1mEfEq4eZbGgI7v0Hlb(d43cOvmaQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUKQjJxHhvtoXCaijotUbQBDw1vVox1ecwQdN6pvtCkwifC1u6zTeoXCaiClNna5UmUeQEgQw6zTeoXCaiClNnazW)r3LXLq1YPAPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxevtgVcpQMCI5aqEkv36SQB86CvtiyPoCQ)unXPyHuWvtPN1sYxai3Iu8cijhViOA5uT0ZAjCI5aqkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxeuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjvtgVcpQMCI5aqsCMCdu36SQxA15QMqWsD4u)PAIBzrunvVAcC2ldHBzrGe2QP0ZAj4oWjMVRiAq4wocOtoErixwPN1s4eZbGu8cijpLpFKEwljFbGClsXlGK8u(8b7E)4fbbu5yEfEqsGpLjt1eNIfsbxnLEwlb3boX8DfrdjbgVvtgVcpQMCI5aqdX9k6WTU1zvxnwNRAcbl1Ht9NQjULfr1u9QjWzVmeULfbsyRMspRLG7aNy(UIObHB5iGo54fHCzLEwlHtmhasXlGK8u(8r6zTK8faYTifVasYt5ZhS79JxeeqLJ5v4bjb(uMmvtCkwifC1unPAU0bKIfiCI5aqkVXa6IOHabl1Hdv)5dvl9SwcUdCI57kIgeULJa6KJxevtgVcpQMCI5aqdX9k6WTU1zvF(15QMqWsD4u)PAItXcPGRMspRLKVaqUfP4fqsoErq1YPAPN1s4eZbGu8cijhViOA5u9bKEwlz9hUf5w02cOb3iihViQMmEfEunbvoMxHh1ToR6ZZ6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGWTC2aK7Y4sO6zOAPN1s4eZbGWTC2aKb)hDxgxs1KXRWJQjNyoaKNs1ToR6L(6CvtgVcpQMCI5aqsCMCdunHGL6WP(tDRZQUXSox1KXRWJQjNyoaKuNVB1ecwQdN6p1TUvZBlNWbHp36C1zvVox1ecwQdN6pvtCkwifC1uwQE5oelbIUOPDHaoeiyPoCOA5u9GdMOGxQEMjQ2ywovlNQhCWef8s1)or1ZZ5t1Yq1F(q1Ys1QjvVChILarx00UqahceSuhouTCQEWbtuWlvpZevBmNpvlt1KXRWJQ5Gdg1aJ6wN1415QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsEkvtgVcpQMk(k8OU1zlT6CvtiyPoCQ)unXPyHuWvZ8fG1ZgGSWqXtUJk4uHabl1HdvlNQLEwlb(3YV7k8G8uOA5uTSun29(XlccNyoaKIxajjb(ugv)5dvBfnTlkHblIlvpZevRglNQLPAY4v4r1CfdavWPsDRZQgRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGKC8IGQLt1spRLKVaqUfP4fqsoErq1YP6di9SwY6pClYTOTfqdUrqoErunz8k8OA2fnT7fzm270mGyRBD25xNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj54fbvlNQLEwljFbGClsXlGKC8IGQLt1hq6zTK1F4wKBrBlGgCJGC8IOAY4v4r1uIBqUfTPaxYTU1zNN15QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsEkvtgVcpQMsqEHSer0u36SL(6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGu8cijpLQjJxHhvtPU7hK9LLv36SgZ6CvtiyPoCQ)unXPyHuWvtPN1s4eZbGu8cijpLQjJxHhvtRibPU7N6wNDExNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj5Punz8k8OAYbgUBYDeM796wNv9YRZvnHGL6WP(t1eNIfsbxnLEwlHtmhasXlGK8uQMmEfEunFxajwyCRBDw1vVox1ecwQdN6pvtgVcpQMnD(i41ZlsIpnq1eNIfsbxnLEwlHtmhasXlGK8uO6pFOAS79JxeeoXCaifVasscdwexQ(3jQE(ZNQLt1hq6zTK1F4wKBrBlGgCJG8uQMG1c4ff8aQMnD(i41ZlsIpnqDRZQUXRZvnHGL6WP(t1KXRWJQjmuklbUJ88eCGHQjoflKcUAIDVF8IGWjMdaP4fqssyWI4s1Zmr1gV8QzWdOAcdLYsG7ippbhyOU1zvV0QZvnHGL6WP(t1KXRWJQ5jb(yfjGub3l0RM4uSqk4Qj29(XlccNyoaKIxajjHblIlv)7evB8YP6pFOAvCkyPoqyfKhO3fOA1CIQvNQ)8HQLLQxXaO6jQUCQwovRItbl1bIiub5chKRabKu9evRovlNQZxawpBaYvO06b6UEoiqWsD4q1YundEavZtc8XksaPcUxOx36SQRgRZvnHGL6WP(t1KXRWJQ51FDKOjelKvtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQ)DIQnE5u9NpuTkofSuhiScYd07cuTAor1Qt1F(q1Ys1Ryau9evxovlNQvXPGL6areQGCHdYvGasQEIQvNQLt15laRNna5kuA9aDxpheiyPoCOAzQMbpGQ51FDKOjelK1ToR6ZVox1ecwQdN6pvtgVcpQMn9YuArUfX3Ryi68k8OAItXcPGRMy37hViiCI5aqkEbKKegSiUu9VtuTXlNQ)8HQvXPGL6aHvqEGExGQvZjQwDQ(ZhQwwQEfdGQNO6YPA5uTkofSuhiIqfKlCqUceqs1tuT6uTCQoFby9SbixHsRhO765Gabl1Hdvlt1m4bunB6LP0IClIVxXq05v4rDRZQ(8Sox1ecwQdN6pvtgVcpQMdgZsjGUTaSOX7kWvtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQNzIQNpvlNQLLQvXPGL6areQGCHdYvGasQwnNOA1P6pFO6vmaQ(xQU0kNQLPAg8aQMdgZsjGUTaSOX7kW1ToR6L(6CvtiyPoCQ)unz8k8OAoymlLa62cWIgVRaxnXPyHuWvtS79JxeeoXCaifVasscdwexQEMjQE(uTCQwfNcwQderOcYfoixbciP6jQwDQwovl9Sws(ca5wKIxaj5Pq1YPAPN1sYxai3Iu8cijjmyrCP6zMOAzPA1lNQngGQNpvRgMQZxawpBaYvO06b6UEoiqWsD4q1Yq1YP6vmaQEgQU0kVAg8aQMdgZsjGUTaSOX7kW1TUvtS79Jxe36C1zvVox1ecwQdN6pvtCkwifC1mFby9SbinP42ldjWcChiqWsD4q1YPAS79JxeeoXCaifVasscdwexQ(xQU0kNQLt1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAzPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqwFhOb)hHB5SbUuTCQwwQwwQE5oeljFbGClsXlGKabl1HdvlNQXU3pErqYxai3Iu8cijjmyrCP6zMO6g8HQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkuTmu9NpuTSuTAs1l3Hyj5laKBrkEbKeiyPoCOA5un29(XlccNyoaKIxajjHblIlv)lvRItbl1bY67an4)Od05YqwprScvldv)5dvJDVF8IGWjMdaP4fqssyWI4s1Zmr1n4dvldvlt1KXRWJQPn97Icxfx36SgVox1ecwQdN6pvtCkwifC1mFby9SbinP42ldjWcChiqWsD4q1YPAS79JxeeoXCaifVasscdwexQEIQlNQLt1Ys1QjvVChILarx00UqahceSuhou9NpuTSu9YDiwceDrt7cbCiqWsD4q1YP6bhmrbVu9VtuDPVCQwgQwgQwovllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuT6Lt1YPAPN1s4eZbGWTC2aK7Y4sO6jQw6zTeoXCaiClNnazW)r3LXLq1Yq1F(q1Ys1y37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6jQUCQwgQwgQwovl9Sws(ca5wKIxaj54fbvlNQhCWef8s1)or1Q4uWsDGWkOHieJ3an4Grk4TAY4v4r10M(DrHRIRBD2sRox1ecwQdN6pvtCkwifC1mFby9SbihXflu6IGZYqyFm44qGGL6WHQLt1y37hViispRfDexSqPlcoldH9XGJdjb(ugvlNQLEwl5iUyHsxeCwgc7JbhhKn97soErq1YPAzPAPN1s4eZbGu8cijhViOA5uT0ZAj5laKBrkEbKKJxeuTCQ(aspRLS(d3IClABb0GBeKJxeuTmuTCQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovllvl9SwcNyoaeULZgGCxgxcvpZevRItbl1bY67an4)iClNnWLQLt1Ys1Ys1l3Hyj5laKBrkEbKeiyPoCOA5un29(Xlcs(ca5wKIxajjHblIlvpZev3GpuTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwHQLHQ)8HQLLQvtQE5oeljFbGClsXlGKabl1HdvlNQXU3pErq4eZbGu8cijjmyrCP6FPAvCkyPoqwFhOb)hDGoxgY6jIvOAzO6pFOAS79JxeeoXCaifVasscdwexQEMjQUbFOAzOAzQMmEfEunTPFxjVV1ToRASox1ecwQdN6pvtCkwifC1mFby9SbihXflu6IGZYqyFm44qGGL6WHQLt1y37hViispRfDexSqPlcoldH9XGJdjb(ugvlNQLEwl5iUyHsxeCwgc7JbhhKvKa54fbvlNQvsqfQbFiQtSPFxjVVvtgVcpQMwrciPoF36wND(15QMqWsD4u)PAItXcPGRMy37hViiR)WTi3I2wan4gbjHblIlvpr1Lt1YPAPN1s4eZbGWTC2aK7Y4sO6zMOAvCkyPoqwFhOb)hHB5SbUuTCQg7E)4fbHtmhasXlGKKWGfXLQNzIQBWNQjJxHhvZHitpVi3IwphqS1To78Sox1ecwQdN6pvtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQNO6YPA5uTSuTAs1l3Hyjq0fnTleWHabl1Hdv)5dvllvVChILarx00UqahceSuhouTCQEWbtuWlv)7evx6lNQLHQLHQLt1Ys1Ys1y37hViiR)WTi3I2wan4gbjHblIlv)lvRItbl1bcRGg8F0b6CziRNO13bvlNQLEwlHtmhac3YzdqUlJlHQNOAPN1s4eZbGWTC2aKb)hDxgxcvldv)5dvllvJDVF8IGS(d3IClABb0GBeKegSiUu9evxovlNQLEwlHtmhac3YzdqUlJlHQNO6YPAzOAzOA5uT0ZAj5laKBrkEbKKJxeuTCQEWbtuWlv)7evRItbl1bcRGgIqmEd0GdgPG3QjJxHhvZHitpVi3IwphqS1ToBPVox1ecwQdN6pvtCkwifC1e7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovl9SwcNyoaeULZgGCxgxcvpZevRItbl1bY67an4)iClNnWLQLt1y37hViiCI5aqkEbKKegSiUu9mtuDd(unz8k8OAEaEBL8mG6wN1ywNRAcbl1Ht9NQjoflKcUAIDVF8IGWjMdaP4fqssyWI4s1tuD5uTCQwwQwnP6L7qSei6IM2fc4qGGL6WHQ)8HQLLQxUdXsGOlAAxiGdbcwQdhQwovp4Gjk4LQ)DIQl9Lt1Yq1Yq1YPAzPAzPAS79JxeK1F4wKBrBlGgCJGKWGfXLQ)LQvVCQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwgQ(ZhQwwQg7E)4fbz9hUf5w02cOb3iijmyrCP6jQUCQwovl9SwcNyoaeULZgGCxgxcvpr1Lt1Yq1Yq1YPAPN1sYxai3Iu8cijhViOA5u9GdMOGxQ(3jQwfNcwQdewbneHy8gObhmsbVvtgVcpQMhG3wjpdOU1zN315QMqWsD4u)PAItXcPGRMy37hViiR)WTi3I2wan4gbjHblIlv)lvRItbl1bsErd(p6aDUmK1t067GQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhi5fn4)Od05YqwprScvlNQLLQxUdXsYxai3Iu8cijqWsD4q1YPAzPAS79JxeK8faYTifVasscdwexQEgQg(d43cOvmaQ(ZhQg7E)4fbjFbGClsXlGKKWGfXLQ)LQvXPGL6ajVOb)hDGoxgY6jkDfQwgQ(ZhQwnP6L7qSK8faYTifVasceSuhouTmuTCQw6zTeoXCaiClNna5UmUeQ(xQ24uTCQ(aspRLS(d3IClABb0GBeKJxeuTCQw6zTK8faYTifVasYXlcQwovl9SwcNyoaKIxaj54fr1KXRWJQzYhbhl6QWzj1ToR6LxNRAcbl1Ht9NQjoflKcUAIDVF8IGS(d3IClABb0GBeKegSiUu9mun8hWVfqRyauTCQw6zTeoXCaiClNna5UmUeQEMjQwfNcwQdK13bAW)r4woBGlvlNQXU3pErq4eZbGu8cijjmyrCP6zOAzPA4pGFlGwXaO6VPAgVcpiR)WTi3I2wan4gbb(d43cOvmaQwMQjJxHhvZKpcow0vHZsQBDw1vVox1ecwQdN6pvtCkwifC1e7E)4fbHtmhasXlGKKWGfXLQNHQH)a(TaAfdGQLt1Ys1Ys1QjvVChILarx00UqahceSuhou9NpuTSu9YDiwceDrt7cbCiqWsD4q1YP6bhmrbVu9VtuDPVCQwgQwgQwovllvllvJDVF8IGS(d3IClABb0GBeKegSiUu9VuTkofSuhiScAW)rhOZLHSEIwFhuTCQw6zTeoXCaiClNna5UmUeQEIQLEwlHtmhac3Yzdqg8F0DzCjuTmu9NpuTSun29(XlcY6pClYTOTfqdUrqsyWI4s1tuD5uTCQw6zTeoXCaiClNna5UmUeQEIQlNQLHQLHQLt1spRLKVaqUfP4fqsoErq1YP6bhmrbVu9VtuTkofSuhiScAicX4nqdoyKcEPAzQMmEfEunt(i4yrxfolPU1zv3415QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGS(oqd(pc3YzdCPA5un29(XlccNyoaKIxajjHblIlvpZevd)b8Bb0kgavlNQhCWef8s1)s1Q4uWsDGWkOHieJ3an4Grk4LQLt1spRLKVaqUfP4fqsoErunz8k8OAU(d3IClABb0GBe1ToR6LwDUQjeSuho1FQM4uSqk4QP0ZAjCI5aq4woBaYDzCju9mtuTkofSuhiRVd0G)JWTC2axQwovVChILKVaqUfP4fqsGGL6WHQLt1y37hVii5laKBrkEbKKegSiUu9mtun8hWVfqRyauTCQg7E)4fbHtmhasXlGKKWGfXLQ)LQvXPGL6az9DGg8F0b6CziRNiwPAY4v4r1C9hUf5w02cOb3iQBDw1vJ15QMqWsD4u)PAItXcPGRMspRLWjMdaHB5Sbi3LXLq1Zmr1Q4uWsDGS(oqd(pc3YzdCPA5uTSuTAs1l3Hyj5laKBrkEbKeiyPoCO6pFOAS79JxeK8faYTifVasscdwexQ(xQwfNcwQdK13bAW)rhOZLHSEIsxHQLHQLt1y37hViiCI5aqkEbKKegSiUu9VuTkofSuhiRVd0G)JoqNldz9eXkvtgVcpQMR)WTi3I2wan4grDRZQ(8RZvnHGL6WP(t1eNIfsbxnXU3pErqw)HBrUfTTaAWncscdwexQ(xQwfNcwQdewbn4)Od05YqwprRVdQwovl9SwcNyoaeULZgGCxgxcvpr1spRLWjMdaHB5Sbid(p6UmUeQwovl9Sws(ca5wKIxaj54fbvlNQhCWef8s1)or1Q4uWsDGWkOHieJ3an4Grk4TAY4v4r1KtmhasXlGSU1zvFEwNRAcbl1Ht9NQjoflKcUAk9SwcNyoaKIxaj54fbvlNQLLQXU3pErqw)HBrUfTTaAWncscdwexQ(xQwfNcwQdK0vqd(p6aDUmK1t067GQ)8HQXU3pErq4eZbGu8cijjmyrCP6zMOAvCkyPoqwFhOb)hDGoxgY6jIvOAzOA5uT0ZAjCI5aq4woBaYDzCju9evl9SwcNyoaeULZgGm4)O7Y4sOA5un29(XlccNyoaKIxajjHblIlv)lvRUXRMmEfEunZxai3Iu8ciRBDw1l915QMqWsD4u)PAItXcPGRMspRLWjMdaP4fqsoErq1YPAS79JxeeoXCaifVasYMpaLWGfXLQ)LQz8k8GCBf2venifVasc(KuTCQw6zTK8faYTifVasYXlcQwovJDVF8IGKVaqUfP4fqs28bOegSiUu9VunJxHhKBRWUIObP4fqsWNKQLt1hq6zTK1F4wKBrBlGgCJGC8IOAY4v4r182kSRiAqkEbK1ToR6gZ6CvtiyPoCQ)unXPyHuWvZL7qSK8faYTifVasceSuhouTCQw6zTeoXCaifVasYtHQLt1spRLKVaqUfP4fqssyWI4s1Zq1n4dzW)RMmEfEunvs4cbgqUfneXPU1zvFExNRAcbl1Ht9NQjoflKcUAEaPN1sw)HBrUfTTaAWncYtHQLt1hq6zTK1F4wKBrBlGgCJGKWGfXLQNHQz8k8GWjMdane3ROdxc8hWVfqRyauTCQwnPASRccowsjLLcoQMmEfEunvs4cbgqUfneXPU1znE515QMqWsD4u)PAItXcPGRMspRLKVaqUfP4fqsEkuTCQw6zTK8faYTifVasscdwexQEgQUbFid(pvlNQXU3pErqavoMxHhKe4tzuTCQg7E)4fbz9hUf5w02cOb3iijmyrCPA5uTAs1yxfeCSKsklfCunz8k8OAQKWfcmGClAiItDRB10kcUJKEzuNRoR615QMqWsD4u)PAY4v4r1KtmhaAiUxrhUvtCllIQP6vtCkwifC1u6zTeCh4eZ3venKey8w36SgVox1KXRWJQjNyoaKuNVB1ecwQdN6p1ToBPvNRAY4v4r1KtmhasIZKBGQjeSuho1FQBDRB1ufKxHh1znE5gVC1nE5gZQzbNHiAUvZsxQHmgoRAGzlDR2unvpxlq1IHINlvB9KQnYvGasJO6eMhprchQ(6dGQ536dEHdvJB5ObUeQbQLiaQwD1MQnwpub5chQ2OL7qSKszevVovB0YDiwsPiqWsD4yevlR6)LHqnqTebq1QR2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzn(FziudulrauTXvBQ2y9qfKlCOAJYxawpBasPmIQxNQnkFby9SbiLIabl1HJruTSQ)xgc1a1seavxAQnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAGAjcGQvJQnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQMxQ2yuPt1IQLv9)YqOgOwIaOA1lxTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YA8)YqOgOwIaOA1l9QnvBSEOcYfouTrl3HyjLYiQEDQ2OL7qSKsrGGL6WXiQww1)ldHAGAjcGQnE5QnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAGAjcGQnE5QnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQMxQ2yuPt1IQLv9)YqOgOwIaOAJBC1MQnwpub5chQ2OL7qSKszevVovB0YDiwsPiqWsD4yevlR6)LHqnGAqPl1qgdNvnWSLUvBQMQNRfOAXqXZLQTEs1gXoyevNW84js4q1xFaun)wFWlCOAClhnWLqnqTebq1QR2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauT6QnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAGAjcGQnUAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQL14)LHqnqTebq1LMAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1LMAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaOA1OAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaO65R2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQEEQ2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQU0R2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQ2yQ2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQEER2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauT6LR2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauT6LMAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1QppvBQ2y9qfKlCOAJwUdXskLru96uTrl3HyjLIabl1HJrunVuTXOsNQfvlR6)LHqnqTebq1QBmvBQ2y9qfKlCOAJwUdXskLru96uTrl3HyjLIabl1HJruTSQ)xgc1a1seavRUXuTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YQ(FziudulrauTXln1MQnwpub5chQ2OL7qSKszevVovB0YDiwsPiqWsD4yevlR6)LHqnqTebq1gV0uBQ2y9qfKlCOAJYxawpBasPmIQxNQnkFby9SbiLIabl1HJruTSQ)xgc1a1seavBC1OAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1gF(QnvBSEOcYfouTrl3HyjLYiQEDQ2OL7qSKsrGGL6WXiQww1)ldHAa1GsxQHmgoRAGzlDR2unvpxlq1IHINlvB9KQnk9LxHhgr1jmpEIeou91havZV1h8chQg3YrdCjudulrauT6QnvBSEOcYfouTrl3HyjLYiQEDQ2OL7qSKsrGGL6WXiQww1)ldHAGAjcGQnUAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaOA1OAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQLv9)YqOgOwIaO65R2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzv)VmeQbQLiaQEER2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzv)VmeQbQLiaQw95TAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQLv9)YqOgOwIaOAJxAQnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAGAjcGQnUAuTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YQ(FziudOgu6snKXWzvdmBPB1MQP65AbQwmu8CPARNuTrhWYV(AevNW84js4q1xFaun)wFWlCOAClhnWLqnqTebq1gxTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YA8)YqOgOwIaO6stTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YA8)YqOgOwIaOA1OAt1gRhQGCHdvBkgglvFllw(pvBmyQEDQwTEmvFeQexHhuTRajVEs1Y(LmuTSQ)xgc1aQbLUudzmCw1aZw6wTPAQEUwGQfdfpxQ26jvBKscyFiXRruDcZJNiHdvF9bq18B9bVWHQXTC0axc1a1seavBC1MQnwpub5chQ2O8fG1ZgGukJO61PAJYxawpBasPiqWsD4yevlR6)LHqnqTebq1LMAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaOA1vxTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr18s1gJkDQwuTSQ)xgc1a1seavREPP2uTX6Hkix4q1gH948elPugr1Rt1gH948elPueiyPoCmIQLv9)YqOgOwIaOAJxUAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQ5LQngv6uTOAzv)VmeQbQLiaQ24QR2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAEPAJrLovlQww1)ldHAGAjcGQn(8vBQ2y9qfKlCOAJwUdXskLru96uTrl3HyjLIabl1HJruTSg)VmeQbQLiaQ24ZxTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YQ(FziudulrauDPPgvBQ2y9qfKlCOAJYxawpBasPmIQxNQnkFby9SbiLIabl1HJrunVuTXOsNQfvlR6)LHqnqTebq1L28vBQ2y9qfKlCOAJYxawpBasPmIQxNQnkFby9SbiLIabl1HJrunVuTXOsNQfvlR6)LHqnGAqPl1qgdNvnWSLUvBQMQNRfOAXqXZLQTEs1gHDVF8I4AevNW84js4q1xFaun)wFWlCOAClhnWLqnqTebq1QR2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauT6QnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAGAjcGQnUAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1gxTPAJ1dvqUWHQnkFby9SbiLYiQEDQ2O8fG1ZgGukceSuhogr1YQ(FziudulrauDPP2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauDPP2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQwnQ2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQEEQ2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzn(FziudulrauTXuTPAJ1dvqUWHQnA5oelPugr1Rt1gTChILukceSuhogr1YA8)YqOgOwIaO65TAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1QRUAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQL14)LHqnqTebq1QxAQnvBSEOcYfouTrl3HyjLYiQEDQ2OL7qSKsrGGL6WXiQww1)ldHAGAjcGQvxnQ2uTX6Hkix4q1gTChILukJO61PAJwUdXskfbcwQdhJOAzv)VmeQbQLiaQwDJPAt1gRhQGCHdvB0YDiwsPmIQxNQnA5oelPueiyPoCmIQLv9)YqOgqnO0LAiJHZQgy2s3Qnvt1Z1cuTyO45s1wpPAJUTCche(CnIQtyE8ejCO6RpaQMFRp4founULJg4sOgOwIaOA1vBQ2y9qfKlCOAJwUdXskLru96uTrl3HyjLIabl1HJruTSg)VmeQbQLiaQU0uBQ2y9qfKlCOAJYxawpBasPmIQxNQnkFby9SbiLIabl1HJruTSQ)xgc1a1seavREPP2uTX6Hkix4q1gLVaSE2aKszevVovBu(cW6zdqkfbcwQdhJOAzv)VmeQbQLiaQwD1OAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaOA1NVAt1gRhQGCHdvBu(cW6zdqkLru96uTr5laRNnaPueiyPoCmIQLv9)YqOgOwIaOA1l9QnvBSEOcYfouTr5laRNnaPugr1Rt1gLVaSE2aKsrGGL6WXiQww1)ldHAa1GsxQHmgoRAGzlDR2unvpxlq1IHINlvB9KQnIhORcpmIQtyE8ejCO6RpaQMFRp4founULJg4sOgOwIaOA1vBQ2y9qfKlCOAJwUdXskLru96uTrl3HyjLIabl1HJruTSQ)xgc1aQbQbgkEUWHQvVCQMXRWdQUlU7LqnOAQKUv0HQ58IQngp3auTAOeZbqnyEr1gJdWWqcsQ24Z3qQ24LB8YPgqnyEr1gdHHRcOAvCkyPoq4b6QWdQweuTLv5jv7wQ(c7kIMlHhORcpOAzXTaUeQUm)Lu9vbWuTRScpUYqOgmVOA1GkhEHdvlIfYG7uDlhNUiAOA3s1Q4uWsDG0YQaKRabCO61PAjGQvNQlAHGQVWUIO5s4b6QWdQEIQvNqnyEr1QbVavVLPiWCNQnfdJLQB540frdv7wQg3YraDQwelK5tzfEq1I4UaFOA3s1gH5adDeJxHhgrOgmVOAJr3ley4s1jmCvWHQ5lv7wQEwxfmKGKQnUXKQxNQt48WavBSgdsnivl7TlAA3EzYqOgqnGXRWJlrjbSpK4DsfNcwQdgg8aMusq517iqLBORmLWfwdpGLF9DQCQbmEfECjkjG9HeVFp9LkofSuhmm4bmPKGYR3rGk3qxz6cRHQ4(dMu3qHDsfNcwQdeLeuE9ocu5tLlpFby9SbixHsRhO765qoJxHkabbmeW9xJtnGXRWJlrjbSpK497PVuXPGL6GHbpGjLeuE9ocu5g6ktxynuf3FWK6gkStQ4uWsDGOKGYR3rGkFQC55laRNna5kuA9aDxphYXUki4yjbGtV75roJxHkabbmeW9x1PgmVOAgVcpUeLeW(qI3VN(sfNcwQdgg8aMAzvaYvGaog6ktxynuf3FWu5udMxunJxHhxIscyFiX73tFPItbl1bddEatTSka5kqahdDLPlSgQI7pysDdf2jvCkyPoqAzvaYvGaotLlNXRqfGGagc4(RXPgmVOAgVcpUeLeW(qI3VN(sfNcwQdgg8aMAzvaYvGaog6ktxynuf3FWK6gkStQ4uWsDG0YQaKRabCMkxUkofSuhikjO86DeOYNuNAaJxHhxIscyFiX73tFPItbl1bddEatwrWDK0lddDLPlSgQI7pyQCQbmEfECjkjG9HeVFp9LkofSuhmm4bmLx0G)JoqNldz9eT(om0vMs4cRHhWYV(onFQbmEfECjkjG9HeVFp9LkofSuhmm4bmLx0G)JoqNldz9eLUIHUYucxyn8aw(13P5tnGXRWJlrjbSpK497PVuXPGL6GHbpGP8Ig8F0b6CziRNiwXqxzkHlSgEal)67KXlNAaJxHhxIscyFiX73tFPItbl1bddEatScAW)rhOZLHSEIwFhg6ktjCH1Wdy5xFNuVCQbmEfECjkjG9HeVFp9LkofSuhmm4bmLUcAW)rhOZLHSEIwFhg6ktjCH1Wdy5xFNmE5udy8k84susa7djE)E6lvCkyPoyyWdyA9DGg8F0b6CziRNiwXqxzkHlSgEal)67u5udy8k84susa7djE)E6lvCkyPoyyWdyA9DGg8F0b6CziRNiwXqxz6cRHQ4(dMkndf2jvCkyPoqwFhOb)hDGoxgY6jIvMkxE(cW6zdqoIlwO0fbNLHW(yWXHAaJxHhxIscyFiX73tFPItbl1bddEatRVd0G)JoqNldz9eXkg6ktxynuf3FWK6Z3qHDsfNcwQdK13bAW)rhOZLHSEIyLPYLJDvqWXscrt7ISmqnGXRWJlrjbSpK497PVuXPGL6GHbpGP13bAW)rhOZLHSEIyfdDLPlSgQI7pys95BOWoPItbl1bY67an4)Od05YqwprSYu5YXECEILWjMdaPK(r0uMCgVcvaccyiG7mLg1agVcpUeLeW(qI3VN(sfNcwQdgg8aMwFhOb)hDGoxgY6jIvm0vMUWAOkU)GP5BOWoPItbl1bY67an4)Od05YqwprSYu5udy8k84susa7djE)E6lvCkyPoyyWdyA9DGg8F0b6CziRNO0vm0vMs4cRHhWYV(oz8YPgW4v4XLOKa2hs8(90xQ4uWsDWWGhWKeNj3aObhmsbVg6ktjCH1Wdy5xFNkNAaJxHhxIscyFiX73tFPItbl1bddEatsCMCdGgCWif8AORmDH1qvC)btYopl3yazh8DHSmKkU)a1WQxE5YiJHc7KkofSuhisCMCdGgCWif8ovUCSRccowsiAAxKLbQbmEfECjkjG9HeVFp9LkofSuhmm4bmjXzYnaAWbJuWRHUY0fwdvX9hmjRXSCJbKDW3fYYqQ4(dudRE5LlJmgkStQ4uWsDGiXzYnaAWbJuW7u5udy8k84susa7djE)E6lvCkyPoyyWdyIvqdrigVbAWbJuWRHUYucxyn8aw(13PYPgW4v4XLOKa2hs8(90xQ4uWsDWWGhWeRGgIqmEd0GdgPGxdDLPlSgQI7pyA(LBOWoPItbl1bcRGgIqmEd0GdgPG3PYLNVaSE2aKJ4IfkDrWzziSpgCCOgW4v4XLOKa2hs8(90xQ4uWsDWWGhWeRGgIqmEd0GdgPGxdDLPlSgQI7pyA(LBOWoPItbl1bcRGgIqmEd0GdgPG3PYLNVaSE2aKMuC7LHeybUdudy8k84susa7djE)E6lvCkyPoyyWdyIvqdrigVbAWbJuWRHUY0fwdvX9hmP(8nuyNuXPGL6aHvqdrigVbAWbJuW7u5udy8k84susa7djE)E6lvCkyPoyyWdyA9DGg8FeULZg4AORmLWfwdpGLF9DY4udy8k84susa7djE)E6lvCkyPoyyWdyseQGCHdYvGasdDLPeUWA4bS8RVtLtnGXRWJlrjbSpK497PVuXPGL6GHbpGjrOcYfoixbcin0vMUWAOkU)Gj1nuyNuXPGL6areQGCHdYvGaYPYLVChILKVaqUfP4fqkx2L7qSeoXCaia36F(OMyxfeCSKsklfCiJCzvtSRccowsa407EE(8HXRqfGGagc4oP(Np5laRNna5kuA9aDxphYqnGXRWJlrjbSpK497PVuXPGL6GHbpGjrOcYfoixbcin0vMUWAOkU)GPYnuyNuXPGL6areQGCHdYvGaYPYPgW4v4XLOKa2hs8(90xQ4uWsDWWGhWeRG8a9UGHUY0fwdvX9hmbZJNqrboKbJzPeq3waw04Df4pFG5XtOOahstNpcE98IK4td85dmpEcff4qA68rWRNx0aoCVl84ZhyE8ekkWHC4SKH7b6a4sqkVnHlgcm85dmpEcff4qeXfNVLL6aAE84yFd0bujWWNpW84juuGd56VEh2venO8jv2NpW84juuGd5(cPU7hepGTTS7(5dmpEcff4qk4sGaYlYMEC(8bMhpHIcCi2opaKBrs8UDGAaJxHhxIscyFiX73tFPItbl1bddEatSdO13bAW)r4woBGRHUYucxyn8aw(13jJtnyEr1mEfECjkjG9HeVFp9LkofSuhmm4bm1YQaKRabCm0vMUWAOkU)Gj1nuyNuXPGL6aPLvbixbc4mvU8lSRiAUeEGUk8ysDQbmEfECjkjG9HeVFp9LkofSuhmm4bmbQCKcEn0vMs4cRHhWYV(oP(8PgW4v4XLOKa2hs8(90xCI5aqwEi6coPgW4v4XLOKa2hs8(90xCI5aqIyHEhWl1agVcpUeLeW(qI3VN(c7HXyVeqdoyudmOgW4v4XLOKa2hs8(90xdrMEIedUbOgW4v4XLOKa2hs8(90x20VRK3xdf2j1ufNcwQdeLeuE9ocu5tQlpFby9SbihXflu6IGZYqyFm44qnGXRWJlrjbSpK497PV4eZbGK68DnuyNutvCkyPoqusq517iqLpPUC1mFby9SbihXflu6IGZYqyFm44qnGXRWJlrjbSpK497PVavoMxHhgkStQ4uWsDGOKGYR3rGkFsDQbudy8k84(90xy)flKxfO3nuyNwoBGLCaPN1sW8DfrdjbgVudy8k84(90xQ4uWsDWWGhWulRcqUceWXqxz6cRHQ4(dMu3qHDsfNcwQdKwwfGCfiGZu5YvsqfQbFiQtavoMxHhYvtzZxawpBaYvO06b6UEo(8jFby9Sbilmu8K7OcovKHAaJxHh3VN(sfNcwQdgg8aMAzvaYvGaog6ktxynuf3FWK6gkStQ4uWsDG0YQaKRabCMkxU0ZAjCI5aqkEbKKJxeYXU3pErq4eZbGu8cijjmyrCLlB(cW6zdqUcLwpq31ZXNp5laRNnazHHINChvWPImudy8k84(90xQ4uWsDWWGhWKveChj9YWqxz6cRHQ4(dMu3qHDs6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxIC1u6zTK81bKBrBBcWL8uKBfnTlkHblI7mtYk7Gd2yWmEfEq4eZbGK68Djy)UYOgMXRWdcNyoaKuNVlb(d43cOvmazOgW4v4X97PVWCVJy8k8a1f31WGhW0TLt4GWNl1agVcpUFp9fM7DeJxHhOU4Ugg8aMyhmuyNy8kubiiGHaU)ACQbmEfEC)E6lm37igVcpqDXDnm4bm5kqaPHc7KkofSuhiTSka5kqaNPYPgW4v4X97PVWCVJy8k8a1f31WGhWepqxfEyOWoDHDfrZLWd0vHhtQtnGXRWJ73tFH5EhX4v4bQlURHbpGjS79JxexQbmEfEC)E6lm37igVcpqDXDnm4bmL(YRWddf2jvCkyPoqSIG7iPxgtLtnGXRWJ73tFH5EhX4v4bQlURHbpGjRi4os6LHHc7KkofSuhiwrWDK0lJj1PgW4v4X97PVWCVJy8k8a1f31WGhW0WvbdiwQbudMxunJxHhxcpqxfEmH5adDeJxHhgkStmEfEqavoMxHheClhb0frJ8bhmrbV)onVNp1agVcpUeEGUk847PVavoMxHhgkStdoyIcENzsfNcwQdeqLJuWRCzXU3pErqw)HBrUfTTaAWncscdwe3zMy8k8GaQCmVcpiWFa)waTIb85d29(XlccNyoaKIxajjHblI7mtmEfEqavoMxHhe4pGFlGwXa(8r2L7qSK8faYTifVas5y37hVii5laKBrkEbKKegSiUZmX4v4bbu5yEfEqG)a(TaAfdqgzKl9Sws(ca5wKIxaj54fHCPN1s4eZbGu8cijhViKFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFDaEBL8madf2jS79JxeeoXCaifVasscdwe3PYLlR0ZAj5laKBrkEbKKJxeYLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVJpFWU3pErqw)HBrUfTTaAWncscdwe3PYLrgQbmEfECj8aDv4X3tFnez65f5w065aI1qHDc7E)4fbHtmhasXlGKKWGfXDQC5Yk9Sws(ca5wKIxaj54fHCzXU3pErqw)HBrUfTTaAWncscdwe3FvXPGL6aHvqd(p6aDUmK1t0674ZhS79JxeK1F4wKBrBlGgCJGKWGfXDQCzKHAaJxHhxcpqxfE890xjFeCSORcNLqnGXRWJlHhORcp(E6RBRWUIObP4fqAOWoj9SwcNyoaKIxaj54fHCS79JxeeoXCaifVasYMpaLWGfX9xgVcpi3wHDfrdsXlGKGpPCPN1sYxai3Iu8cijhViKJDVF8IGKVaqUfP4fqs28bOegSiU)Y4v4b52kSRiAqkEbKe8jLFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFLVaqUfP4fqAOWoj9Sws(ca5wKIxaj54fHCS79JxeeoXCaifVasscdwexQbmEfECj8aDv4X3tFT(d3IClABb0GBegkStYIDVF8IGWjMdaP4fqssyWI4ovUCPN1sYxai3Iu8cijhViK5ZhLeuHAWhI6K8faYTifVasQbmEfECj8aDv4X3tFT(d3IClABb0GBegkSty37hViiCI5aqkEbKKegSiUZm)YLl9Sws(ca5wKIxaj54fHC4EHadevIRWdKBrkqAb8k8Gabl1Hd1agVcpUeEGUk847PV4eZbGu8cinuyNKEwljFbGClsXlGKC8Iqo29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhudy8k84s4b6QWJVN(ItmhasIZKBadf2jPN1s4eZbGu8cijpf5spRLWjMdaP4fqssyWI4oZeJxHheoXCaOH4EfD4sG)a(TaAfdqU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUeQbmEfECj8aDv4X3tFXjMda5PKHc7K0ZAjCI5aq4woBaYDzCjZi9SwcNyoaeULZgGm4)O7Y4sKl9Sws(ca5wKIxaj54fHCPN1s4eZbGu8cijhViKFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj8aDv4X3tFXjMdajXzYnGHc7K0ZAj5laKBrkEbKKJxeYLEwlHtmhasXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlHAaJxHhxcpqxfE890xCI5aqdX9k6W1qHDs6zTeCh4eZ3venKey8AiULfXK6gcC2ldHBzrGe2jPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(i9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgQbmEfECj8aDv4X3tFXjMdane3ROdxdf2j1KlDaPybcNyoaKYBmGUiAiqWsD485J0ZAj4oWjMVRiAq4wocOtoEryiULfXK6gcC2ldHBzrGe2jPN1sWDGtmFxr0GWTCeqNC8IqUSspRLWjMdaP4fqsEkF(i9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgQbmEfECj8aDv4X3tFbQCmVcpmuyNKEwljFbGClsXlGKC8IqU0ZAjCI5aqkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fb1agVcpUeEGUk847PV4eZbG8uYqHDs6zTeoXCaiClNna5UmUKzKEwlHtmhac3Yzdqg8F0DzCjudy8k84s4b6QWJVN(ItmhasIZKBaQbmEfECj8aDv4X3tFXjMdaj157snGAaJxHhxc7WKn97k591qHDkFby9SbihXflu6IGZYqyFm44ih7E)4fbr6zTOJ4IfkDrWzziSpgCCijWNYKl9SwYrCXcLUi4Sme2hdooiB63LC8IqUSspRLWjMdaP4fqsoErix6zTK8faYTifVasYXlc5hq6zTK1F4wKBrBlGgCJGC8Iqg5y37hViiR)WTi3I2wan4gbjHblI7u5YLv6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLlRSl3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzQbFKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkY85JSQ5YDiws(ca5wKIxaPCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwrMpFWU3pErq4eZbGu8cijjmyrCNzQbFKrgQbmEfECjSdFp9LvKasQZ31qHDs28fG1ZgGCexSqPlcoldH9XGJJCS79JxeePN1IoIlwO0fbNLHW(yWXHKaFktU0ZAjhXflu6IGZYqyFm44GSIeihViKRKGkud(quNyt)UsEFL5ZhzZxawpBaYrCXcLUi4Sme2hdooYxXaMkxgQbmEfECjSdFp9Ln97IcxfBOWoLVaSE2aKMuC7LHeybUdYXU3pErq4eZbGu8cijjmyrC)T0kxo29(XlcY6pClYTOTfqdUrqsyWI4ovUCzLEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2ax5Yk7YDiws(ca5wKIxaPCS79JxeK8faYTifVasscdwe3zMAWh5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(iRAUChILKVaqUfP4fqkh7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhS79JxeeoXCaifVasscdwe3zMAWhzKHAaJxHhxc7W3tFzt)UOWvXgkSt5laRNnaPjf3EzibwG7GCS79JxeeoXCaifVasscdwe3PYLlRSYIDVF8IGS(d3IClABb0GBeKegSiU)QItbl1bcRGg8F0b6CziRNO13HCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjY85JSy37hViiR)WTi3I2wan4gbjHblI7u5YLEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2axzKrU0ZAj5laKBrkEbKKJxeYqnGXRWJlHD47PVw)HBrUfTTaAWncdf2P8fG1ZgGCfkTEGURNd5kjOc1Gpe1jGkhZRWdQbmEfECjSdFp9fNyoaKIxaPHc7u(cW6zdqUcLwpq31ZHCzvsqfQbFiQtavoMxHhF(OKGkud(quNS(d3IClABb0GBeYqnGXRWJlHD47PVavoMxHhgkStRya)wALlpFby9SbixHsRhO765qU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kh7E)4fbz9hUf5w02cOb3iijmyrCNkxo29(XlccNyoaKIxajjHblI7mtn4d1agVcpUe2HVN(cu5yEfEyOWoTIb8BPvU88fG1ZgGCfkTEGURNd5y37hViiCI5aqkEbKKegSiUtLlxwzLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVd5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sK5ZhzXU3pErqw)HBrUfTTaAWncscdwe3PYLl9SwcNyoaeULZgGCxgxYmtQ4uWsDGWoGwFhOb)hHB5SbUYiJCPN1sYxai3Iu8cijhViKXqrSqMpLfjStspRLCfkTEGURNdYDzCjtspRLCfkTEGURNdYG)JUlJlXqrSqMpLfjgd4i4fMuNAaJxHhxc7W3tFnez65f5w065aI1qHDswS79JxeeoXCaifVasscdwe3FvJZ)ZhS79JxeeoXCaifVasscdwe3zMknzKJDVF8IGS(d3IClABb0GBeKegSiUtLlxwPN1s4eZbGWTC2aK7Y4sMzsfNcwQde2b067an4)iClNnWvUSYUChILKVaqUfP4fqkh7E)4fbjFbGClsXlGKKWGfXDMPg8ro29(XlccNyoaKIxajjHblI7VZxMpFKvnxUdXsYxai3Iu8ciLJDVF8IGWjMdaP4fqssyWI4(78L5ZhS79JxeeoXCaifVasscdwe3zMAWhzKHAaJxHhxc7W3tFL8rWXIUkCwIHc7e29(XlcY6pClYTOTfqdUrqsyWI4od8hWVfqRyaYLv6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLlRSl3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzQbFKJDVF8IGWjMdaP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eXkY85JSQ5YDiws(ca5wKIxaPCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwrMpFWU3pErq4eZbGu8cijjmyrCNzQbFKrgQbmEfECjSdFp9vYhbhl6QWzjgkSty37hViiCI5aqkEbKKegSiUZa)b8Bb0kgGCzLvwS79JxeK1F4wKBrBlGgCJGKWGfX9xvCkyPoqyf0G)JoqNldz9eT(oKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrMpFKf7E)4fbz9hUf5w02cOb3iijmyrCNkxU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kJmYLEwljFbGClsXlGKC8IqgQbmEfECjSdFp91b4TvYZamuyNWU3pErq4eZbGu8cijjmyrCNkxUSYkl29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLiZNpYIDVF8IGS(d3IClABb0GBeKegSiUtLlx6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLrg5spRLKVaqUfP4fqsoErid1agVcpUe2HVN(A9hUf5w02cOb3imuyNKEwlHtmhac3YzdqUlJlzMjvCkyPoqyhqRVd0G)JWTC2ax5Yk7YDiws(ca5wKIxaPCS79JxeK8faYTifVasscdwe3zMAWh5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(iRAUChILKVaqUfP4fqkh7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhS79JxeeoXCaifVasscdwe3zMAWhzOgW4v4XLWo890xCI5aqkEbKgkStYkl29(XlcY6pClYTOTfqdUrqsyWI4(RkofSuhiScAW)rhOZLHSEIwFhYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLiZNpYIDVF8IGS(d3IClABb0GBeKegSiUtLlx6zTeoXCaiClNna5UmUKzMuXPGL6aHDaT(oqd(pc3YzdCLrg5spRLKVaqUfP4fqsoErqnGXRWJlHD47PVYxai3Iu8cinuyNKEwljFbGClsXlGKC8IqUSYIDVF8IGS(d3IClABb0GBeKegSiU)A8YLl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrMpFKf7E)4fbz9hUf5w02cOb3iijmyrCNkxU0ZAjCI5aq4woBaYDzCjZmPItbl1bc7aA9DGg8FeULZg4kJmYLf7E)4fbHtmhasXlGKKWGfX9x1n(Nphq6zTK1F4wKBrBlGgCJG8uKHAaJxHhxc7W3tFDBf2venifVasdf2jS79JxeeoXCaipLijmyrC)D(F(OMl3HyjCI5aqEkrnGXRWJlHD47PVus4cbgqUfneXXqHDs6zTKdWBRKNbqEkYpG0ZAjR)WTi3I2wan4gb5Pi)aspRLS(d3IClABb0GBeKegSiUZmj9SwIscxiWaYTOHioKb)hDxgxIAygVcpiCI5aqsD(Ue4pGFlGwXaOgW4v4XLWo890xCI5aqsD(UgkStspRLCaEBL8maYtrUSYUChILKW1doWGCgVcvaccyiG7mQrz(8HXRqfGGagc4oZ8LrUSQz(cW6zdq4eZbGK8HeNNbe7NplNnWsAbUVTef8(BPnFzOgW4v4XLWo890x3NcKHRIPgW4v4XLWo890xCI5aqsCMCdyOWoj9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlHAaJxHhxc7W3tFXjMda5PKHc7K0ZAjCI5aq4woBaYDzCjtLtnGXRWJlHD47PVcyBHeTWqbURHc7KSjyt42YsD4Zh1Cf4serJmYLEwlHtmhac3YzdqUlJlzs6zTeoXCaiClNnazW)r3LXLqnGXRWJlHD47PV4eZbGgI7v0HRHc7K0ZAj4oWjMVRiAijW4vE(cW6zdq4eZbGeHveITm5Yk7YDiwcpu6cRaZRWd5mEfQaeeWqa3zmMY85dJxHkabbmeWDM5ld1agVcpUe2HVN(ItmhaAiUxrhUgkStspRLG7aNy(UIOHKaJx5l3HyjCI5aqaU1LFaPN1sw)HBrUfTTaAWncYtrUSl3Hyj8qPlScmVcp(8HXRqfGGagc4oZ8wgQbmEfECjSdFp9fNyoa0qCVIoCnuyNKEwlb3boX8DfrdjbgVYxUdXs4HsxyfyEfEiNXRqfGGagc4oJAKAaJxHhxc7W3tFXjMdab)v6(v4HHc7K0ZAjCI5aq4woBaYDzCjZi9SwcNyoaeULZgGm4)O7Y4sOgW4v4XLWo890xCI5aqWFLUFfEyOWoj9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrUscQqn4drDcNyoaKeNj3audy8k84syh(E6lqLJ5v4HHIyHmFklsyNgCWef8(7KXC(gkIfY8PSiXyahbVWK6udOgmVOAJbLcpfRO0bq1VRiAO6MuC7Lr1cSa3bQUqSTunRqOA1GxGQflvxi2wQE9Dq1(2czH4ceQbmEfECjy37hViUt20VlkCvSHc7u(cW6zdqAsXTxgsGf4oih7E)4fbHtmhasXlGKKWGfX93sRC5y37hViiR)WTi3I2wan4gbjHblI7u5YLv6zTeoXCaiClNna5UmUKzMuXPGL6az9DGg8FeULZg4kxwzxUdXsYxai3Iu8ciLJDVF8IGKVaqUfP4fqssyWI4oZud(ih7E)4fbHtmhasXlGKKWGfX9xvCkyPoqwFhOb)hDGoxgY6jIvK5ZhzvZL7qSK8faYTifVas5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImF(GDVF8IGWjMdaP4fqssyWI4oZud(iJmudy8k84sWU3pErC)E6lB63ffUk2qHDkFby9SbinP42ldjWcChKJDVF8IGWjMdaP4fqssyWI4ovUCzvZL7qSei6IM2fc485JSl3Hyjq0fnTleWr(GdMOG3FNk9LlJmYLvwS79JxeK1F4wKBrBlGgCJGKWGfX9x1lxU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUez(8rwS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmvUmYix6zTK8faYTifVasYXlc5doyIcE)DsfNcwQdewbneHy8gObhmsbVudy8k84sWU3pErC)E6lB63vY7RHc7u(cW6zdqoIlwO0fbNLHW(yWXro29(XlcI0ZArhXflu6IGZYqyFm44qsGpLjx6zTKJ4IfkDrWzziSpgCCq20Vl54fHCzLEwlHtmhasXlGKC8IqU0ZAj5laKBrkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fHmYXU3pErqw)HBrUfTTaAWncscdwe3PYLlR0ZAjCI5aq4woBaYDzCjZmPItbl1bY67an4)iClNnWvUSYUChILKVaqUfP4fqkh7E)4fbjFbGClsXlGKKWGfXDMPg8ro29(XlccNyoaKIxajjHblI7VQ4uWsDGS(oqd(p6aDUmK1teRiZNpYQMl3Hyj5laKBrkEbKYXU3pErq4eZbGu8cijjmyrC)vfNcwQdK13bAW)rhOZLHSEIyfz(8b7E)4fbHtmhasXlGKKWGfXDMPg8rgzOgW4v4XLGDVF8I4(90xwrciPoFxdf2P8fG1ZgGCexSqPlcoldH9XGJJCS79JxeePN1IoIlwO0fbNLHW(yWXHKaFktU0ZAjhXflu6IGZYqyFm44GSIeihViKRKGkud(quNyt)UsEFPgmVOA1q9cUSlv)Uavpez65LQleBlvZkeQwnGLQxFhuT4s1jWNYOA(s1fqVBivp4saQ((sGQxNQX8DPAXs1sG1tGQxFheQbmEfECjy37hViUFp91qKPNxKBrRNdiwdf2jS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmZKkofSuhiRVd0G)JWTC2ax5y37hViiCI5aqkEbKKegSiUZm1Gpudy8k84sWU3pErC)E6RHitpVi3IwphqSgkSty37hViiCI5aqkEbKKegSiUtLlxw1C5oelbIUOPDHaoF(i7YDiwceDrt7cbCKp4Gjk493PsF5YiJCzLf7E)4fbz9hUf5w02cOb3iijmyrC)vfNcwQdewbn4)Od05YqwprRVd5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sK5ZhzXU3pErqw)HBrUfTTaAWncscdwe3PYLl9SwcNyoaeULZgGCxgxYu5YiJCPN1sYxai3Iu8cijhViKp4Gjk493jvCkyPoqyf0qeIXBGgCWif8snyEr1QH6fCzxQ(DbQ(a82k5zauDHyBPAwHq1QbSu967GQfxQob(ugvZxQUa6DdP6bxcq13xcu96unMVlvlwQwcSEcu967GqnGXRWJlb7E)4fX97PVoaVTsEgGHc7e29(XlcY6pClYTOTfqdUrqsyWI4ovUCPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGRCS79JxeeoXCaifVasscdwe3zMAWhQbmEfECjy37hViUFp91b4TvYZamuyNWU3pErq4eZbGu8cijjmyrCNkxUSQ5YDiwceDrt7cbC(8r2L7qSei6IM2fc4iFWbtuW7VtL(YLrg5Ykl29(XlcY6pClYTOTfqdUrqsyWI4(R6Llx6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxImF(il29(XlcY6pClYTOTfqdUrqsyWI4ovUCPN1s4eZbGWTC2aK7Y4sMkxgzKl9Sws(ca5wKIxaj54fH8bhmrbV)oPItbl1bcRGgIqmEd0GdgPGxQbZlQwn4fO6RcNLq1clvV(oOAoounRq1CcuThun(q1CCO6cpmAPAjGQFkuT1tQU7rdKu92YbvVTavp4)u9b6Czgs1dUer0q13xcuDbq1TSkGQ5LQ7aFxQElCQMtmhavJB5SbUunhhQEB5LQxFhuDbFdJwQ2yS3DP63foeQbmEfECjy37hViUFp9vYhbhl6QWzjgkSty37hViiR)WTi3I2wan4gbjHblI7VQ4uWsDGKx0G)JoqNldz9eT(oKJDVF8IGWjMdaP4fqssyWI4(RkofSuhi5fn4)Od05YqwprSICzxUdXsYxai3Iu8ciLll29(Xlcs(ca5wKIxajjHblI7mWFa)waTIb85d29(Xlcs(ca5wKIxajjHblI7VQ4uWsDGKx0G)JoqNldz9eLUImF(OMl3Hyj5laKBrkEbKYix6zTeoXCaiClNna5UmUKFnU8di9SwY6pClYTOTfqdUrqoErix6zTK8faYTifVasYXlc5spRLWjMdaP4fqsoErqnyEr1QbVavFv4SeQUqSTunRq1fTqq1k(9kK6aHQvdyP613bvlUuDc8PmQMVuDb07gs1dUeGQVVeO61PAmFxQwSuTey9eO613bHAaJxHhxc29(XlI73tFL8rWXIUkCwIHc7e29(XlcY6pClYTOTfqdUrqsyWI4od8hWVfqRyaYLEwlHtmhac3YzdqUlJlzMjvCkyPoqwFhOb)hHB5SbUYXU3pErq4eZbGu8cijjmyrCNrw4pGFlGwXa(MXRWdY6pClYTOTfqdUrqG)a(TaAfdqgQbmEfECjy37hViUFp9vYhbhl6QWzjgkSty37hViiCI5aqkEbKKegSiUZa)b8Bb0kgGCzLvnxUdXsGOlAAxiGZNpYUChILarx00Uqah5doyIcE)DQ0xUmYixwzXU3pErqw)HBrUfTTaAWncscdwe3FvXPGL6aHvqd(p6aDUmK1t067qU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUez(8rwS79JxeK1F4wKBrBlGgCJGKWGfXDQC5spRLWjMdaHB5Sbi3LXLmvUmYix6zTK8faYTifVasYXlc5doyIcE)DsfNcwQdewbneHy8gObhmsbVYqnyEr1QbVavV(oO6cX2s1ScvlSuTyn6s1fITveu92cu9G)t1hOZLrOA1awQo81qQ(DbQUqSTuD6kuTWs1Blq1l3HyPAXLQxUeimKQ54q1I1Olvxi2wrq1Blq1d(pvFGoxgHAaJxHhxc29(XlI73tFT(d3IClABb0GBegkStspRLWjMdaHB5Sbi3LXLmZKkofSuhiRVd0G)JWTC2ax5y37hViiCI5aqkEbKKegSiUZmb)b8Bb0kgG8bhmrbV)QItbl1bcRGgIqmEd0GdgPGx5spRLKVaqUfP4fqsoErqnGXRWJlb7E)4fX97PVw)HBrUfTTaAWncdf2jPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGR8L7qSK8faYTifVas5y37hVii5laKBrkEbKKegSiUZmb)b8Bb0kgGCS79JxeeoXCaifVasscdwe3FvXPGL6az9DGg8F0b6CziRNiwHAaJxHhxc29(XlI73tFT(d3IClABb0GBegkStspRLWjMdaHB5Sbi3LXLmZKkofSuhiRVd0G)JWTC2ax5YQMl3Hyj5laKBrkEbKF(GDVF8IGKVaqUfP4fqssyWI4(RkofSuhiRVd0G)JoqNldz9eLUImYXU3pErq4eZbGu8cijjmyrC)vfNcwQdK13bAW)rhOZLHSEIyfQbZlQwn4fOAwHQfwQE9Dq1Ilv7bvJpunhhQUWdJwQwcO6NcvB9KQ7E0ajvVTCq1Blq1d(pvFGoxMHu9Glrenu99LavVT8s1fav3YQaQgc)10s1doyQMJdvVT8s1BlKavlUuD4lvZ9e4tzunt15laQ2TuTIxajvF8IGqnGXRWJlb7E)4fX97PV4eZbGu8cinuyNWU3pErqw)HBrUfTTaAWncscdwe3FvXPGL6aHvqd(p6aDUmK1t067qU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUe5spRLKVaqUfP4fqsoEriFWbtuW7VtQ4uWsDGWkOHieJ3an4Grk4LAW8IQvdEbQoDfQwyP613bvlUuThun(q1CCO6cpmAPAjGQFkuT1tQU7rdKu92YbvVTavp4)u9b6Czgs1dUer0q13xcu92cjq1IBy0s1Cpb(ugvZuD(cGQpErq1CCO6TLxQMvO6cpmAPAja7dGQzvSOZsDGQpVuenuD(cGqnGXRWJlb7E)4fX97PVYxai3Iu8cinuyNKEwlHtmhasXlGKC8IqUSy37hViiR)WTi3I2wan4gbjHblI7VQ4uWsDGKUcAW)rhOZLHSEIwFhF(GDVF8IGWjMdaP4fqssyWI4oZKkofSuhiRVd0G)JoqNldz9eXkYix6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxICS79JxeeoXCaifVasscdwe3Fv34udy8k84sWU3pErC)E6RBRWUIObP4fqAOWoj9SwcNyoaKIxaj54fHCS79JxeeoXCaifVasYMpaLWGfX9xgVcpi3wHDfrdsXlGKGpPCPN1sYxai3Iu8cijhViKJDVF8IGKVaqUfP4fqs28bOegSiU)Y4v4b52kSRiAqkEbKe8jLFaPN1sw)HBrUfTTaAWncYXlcQbZlQwn4fOAfFq1Rt135XdGshavZbvd)3KPAwIQfbvVTavhW)LQXU3pErq1fI44fgs1VOd3lvxszPGdQEBHGQ9OxgvFEPiAOAoXCauTIxajvFEavVov36fu9GdMQBFrtwgvN8rWXs1xfolHQfxQbmEfECjy37hViUFp9LscxiWaYTOHiogkStl3Hyj5laKBrkEbKYLEwlHtmhasXlGK8uKl9Sws(ca5wKIxajjHblI7mn4dzW)PgW4v4XLGDVF8I4(90xkjCHadi3IgI4yOWoDaPN1sw)HBrUfTTaAWncYtr(bKEwlz9hUf5w02cOb3iijmyrCNHXRWdcNyoa0qCVIoCjWFa)waTIbixnXUki4yjLuwk4GAaJxHhxc29(XlI73tFPKWfcmGClAiIJHc7K0ZAj5laKBrkEbKKNICPN1sYxai3Iu8cijjmyrCNPbFid(VCS79JxeeqLJ5v4bjb(uMCS79JxeK1F4wKBrBlGgCJGKWGfXvUAIDvqWXskPSuWb1aQbmEfECjwrWDK0lJVN(ItmhaAiUxrhUgkStspRLG7aNy(UIOHKaJxdXTSiMuNAaJxHhxIveChj9Y47PV4eZbGK68DPgW4v4XLyfb3rsVm(E6loXCaijotUbOgqnGXRWJlz4QGbe73tFj1frjiokZqHDA4QGbel5iUlhy43j1lNAaJxHhxYWvbdi2VN(sjHleya5w0qehQbmEfECjdxfmGy)E6loXCaOH4EfD4AOWonCvWaILCe3LdmmJ6LtnGXRWJlz4QGbe73tFXjMda5Pe1agVcpUKHRcgqSFp9LvKasQZ3LAa1agVcpUexbciNavoMxHhgkStYMVaSE2aKRqP1d0D9C85t(cW6zdqwyO4j3rfCQiJ8L7qSK8faYTifVas5y37hVii5laKBrkEbKKegSiUYLv6zTK8faYTifVasYXlIpFusqfQbFiQt4eZbGK4m5gqgQbmEfECjUceq(90xwrciPoFxdf2P8fG1ZgGCexSqPlcoldH9XGJJCPN1soIlwO0fbNLHW(yWXbzt)UKNc1agVcpUexbci)E6lB63ffUk2qHDkFby9SbinP42ldjWcChKp4Gjk493598PgW4v4XL4kqa53tFDaEBL8madf2j1mFby9SbixHsRhO765GAaJxHhxIRabKFp9vYhbhl6QWzjgkStdoyIcE)vnwo1agVcpUexbci)E6RBRWUIObP4fqAOWoj9SwcNyoaKIxaj54fHCS79JxeeoXCaifVasscdwex5Q4uWsDGicvqUWb5kqaPAoPo1agVcpUexbci)E6loXCaipLmuyNuXPGL6areQGCHdYvGaYj1LJDVF8IGKVaqUfP4fqssyWI4ovo1agVcpUexbci)E6loXCaiPoFxdf2jvCkyPoqeHkix4GCfiGCsD5y37hVii5laKBrkEbKKegSiUtLlx6zTeoXCaiClNna5UmUKzKEwlHtmhac3Yzdqg8F0DzCjudy8k84sCfiG87PVYxai3Iu8cinuyNuXPGL6areQGCHdYvGaYj1Ll9Sws(ca5wKIxaj54fb1agVcpUexbci)E6lfFfEyOWoPItbl1bIiub5chKRabKtQlxnLnFby9SbixHsRhO7654ZN8fG1ZgGSWqXtUJk4urgQbmEfECjUceq(90xhG3wjpdWqHDs6zTK8faYTifVasYXlcQbmEfECjUceq(90xdrMEErUfTEoGynuyNKEwljFbGClsXlGKC8I4ZhLeuHAWhI6eoXCaijotUbOgW4v4XL4kqa53tFT(d3IClABb0GBegkStspRLKVaqUfP4fqsoEr85JscQqn4drDcNyoaKeNj3audy8k84sCfiG87PV4eZbGu8cinuyNusqfQbFiQtw)HBrUfTTaAWncQbmEfECjUceq(90x5laKBrkEbKgkStspRLKVaqUfP4fqsoErqnGXRWJlXvGaYVN(sjHleya5w0qehdf2Pdi9SwY6pClYTOTfqdUrqEkYpG0ZAjR)WTi3I2wan4gbjHblI7mmEfEq4eZbGgI7v0Hlb(d43cOvmaQbmEfECjUceq(90xkjCHadi3IgI4yOWoTChILKVaqUfP4fqkx6zTeoXCaifVasYtrU0ZAj5laKBrkEbKKegSiUZ0GpKb)NAaJxHhxIRabKFp9fNyoaKuNVRHc70XxsYhbhl6QWzjKegSiU)o)pFoG0ZAjjFeCSORcNLGu96bKSKOl2Yi3LXL8B5udy8k84sCfiG87PV4eZbGK68DnuyNKEwlrjHleya5w0qehYtr(bKEwlz9hUf5w02cOb3iipf5hq6zTK1F4wKBrBlGgCJGKWGfXDMjgVcpiCI5aqsD(Ue4pGFlGwXaOgW4v4XL4kqa53tFXjMdajXzYnGHc7K0ZAj5laKBrkEbKKNICS79JxeeoXCaifVassc8Pm5doyIcENrnwUCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjYvZ8fG1ZgGCfkTEGURNd5Qz(cW6zdqwyO4j3rfCQqnGXRWJlXvGaYVN(ItmhasIZKBadf2jPN1sYxai3Iu8cijpf5spRLWjMdaP4fqsoErix6zTK8faYTifVasscdwe3zMAWh5spRLWjMdaHB5Sbi3LXLmj9SwcNyoaeULZgGm4)O7Y4sKRItbl1bIiub5chKRabKudy8k84sCfiG87PV4eZbGgI7v0HRHc70bKEwlz9hUf5w02cOb3iipf5l3HyjCI5aqaU1LlR0ZAjhG3wjpdGC8I4ZhgVcvaccyiG7K6Yi)aspRLS(d3IClABb0GBeKegSiU)Y4v4bHtmhaAiUxrhUe4pGFlGwXaKlRAYLoGuSaHtmhas5ngqxeneiyPoC(8r6zTeCh4eZ3veniClhb0jhViKXqCllIj1ne4Sxgc3YIajStspRLG7aNy(UIObHB5iGo54fHCzLEwlHtmhasXlGK8u(8rw1C5oelXvbPIxajCKlR0ZAj5laKBrkEbKKNYNpy37hViiGkhZRWdsc8PmzKrgQbmEfECjUceq(90xCI5aqdX9k6W1qHDs6zTeCh4eZ3venKey8kh7E)4fbHtmhasXlGKKWGfXvUSspRLKVaqUfP4fqsEkF(i9SwcNyoaKIxaj5PiJH4wwetQtnGXRWJlXvGaYVN(ItmhaYtjdf2jPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGRCzXU3pErq4eZbGu8cijjmyrC)v9Y)8HXRqfGGagc4oZKXLHAaJxHhxIRabKFp9fNyoaKuNVRHc7K0ZAj5laKBrkEbKKNYNpdoyIcE)v95tnGXRWJlXvGaYVN(cu5yEfEyOWoj9Sws(ca5wKIxaj54fHCPN1s4eZbGu8cijhVimuelK5tzrc70GdMOG3FNmMZ3qrSqMpLfjgd4i4fMuNAaJxHhxIRabKFp9fNyoaKeNj3audOgmVOAgVcpUK0xEfE890xyoWqhX4v4HHc7eJxHheqLJ5v4bb3YraDr0iFWbtuW7VtZ75lxw1mFby9SbixHsRhO7654ZhPN1sUcLwpq31Zb5UmUKjPN1sUcLwpq31ZbzW)r3LXLid1agVcpUK0xEfE890xGkhZRWddf2PbhmrbVZmPItbl1bcOYrk4vUSy37hViiR)WTi3I2wan4gbjHblI7mtmEfEqavoMxHhe4pGFlGwXa(8b7E)4fbHtmhasXlGKKWGfXDMjgVcpiGkhZRWdc8hWVfqRyaF(i7YDiws(ca5wKIxaPCS79JxeK8faYTifVasscdwe3zMy8k8GaQCmVcpiWFa)waTIbiJmYLEwljFbGClsXlGKC8IqU0ZAjCI5aqkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fHC1ujbvOg8HOoz9hUf5w02cOb3iOgW4v4XLK(YRWJVN(cu5yEfEyOWoLVaSE2aKRqP1d0D9Cih7E)4fbHtmhasXlGKKWGfXDMjgVcpiGkhZRWdc8hWVfqRyaudMxu9pCMCdq1clvlwJUu9kgavVov)UavV(oOAoouDbq1TSkGQx3P6bhLr14woBGl1agVcpUK0xEfE890xCI5aqsCMCdyOWoHDVF8IGS(d3IClABb0GBeKe4tzYLv6zTeoXCaiClNna5UmUKFvXPGL6az9DGg8FeULZg4kh7E)4fbHtmhasXlGKKWGfXDMj4pGFlGwXaKp4Gjk49xvCkyPoqyf0qeIXBGgCWif8kx6zTK8faYTifVasYXlczOgW4v4XLK(YRWJVN(ItmhasIZKBadf2jS79JxeK1F4wKBrBlGgCJGKaFktUSspRLWjMdaHB5Sbi3LXL8RkofSuhiRVd0G)JWTC2ax5l3Hyj5laKBrkEbKYXU3pErqYxai3Iu8cijjmyrCNzc(d43cOvma5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImudy8k84ssF5v4X3tFXjMdajXzYnGHc7e29(XlcY6pClYTOTfqdUrqsGpLjxwPN1s4eZbGWTC2aK7Y4s(vfNcwQdK13bAW)r4woBGRCzvZL7qSK8faYTifVaYpFWU3pErqYxai3Iu8cijjmyrC)vfNcwQdK13bAW)rhOZLHSEIsxrg5y37hViiCI5aqkEbKKegSiU)QItbl1bY67an4)Od05YqwprSImudy8k84ssF5v4X3tFXjMdajXzYnGHc70bKEwlj5JGJfDv4SeKQxpGKLeDXwg5UmUKPdi9SwsYhbhl6QWzjivVEajlj6ITmYG)JUlJlrUSspRLWjMdaP4fqsoEr85J0ZAjCI5aqkEbKKegSiUZm1GpYixwPN1sYxai3Iu8cijhVi(8r6zTK8faYTifVasscdwe3zMAWhzOgW4v4XLK(YRWJVN(ItmhasQZ31qHD64lj5JGJfDv4Sescdwe3FnMF(i7bKEwlj5JGJfDv4SeKQxpGKLeDXwg5UmUKFlx(bKEwlj5JGJfDv4SeKQxpGKLeDXwg5UmUKzoG0ZAjjFeCSORcNLGu96bKSKOl2Yid(p6UmUezOgW4v4XLK(YRWJVN(ItmhasQZ31qHDs6zTeLeUqGbKBrdrCipf5hq6zTK1F4wKBrBlGgCJG8uKFaPN1sw)HBrUfTTaAWncscdwe3zMy8k8GWjMdaj157sG)a(TaAfdGAaJxHhxs6lVcp(E6loXCaOH4EfD4AOWoDaPN1sw)HBrUfTTaAWncYtr(YDiwcNyoaeGBD5Yk9SwYb4TvYZaihVi(8HXRqfGGagc4oPUmYL9aspRLS(d3IClABb0GBeKegSiU)Y4v4bHtmhaAiUxrhUe4pGFlGwXa(8b7E)4fbrjHleya5w0qehscdwe3pFWUki4yjLuwk4qg5YQMCPdiflq4eZbGuEJb0frdbcwQdNpFKEwlb3boX8Dfrdc3YraDYXlczme3YIysDdbo7LHWTSiqc7K0ZAj4oWjMVRiAq4wocOtoErixwPN1s4eZbGu8cijpLpFKvnxUdXsCvqQ4fqch5Yk9Sws(ca5wKIxaj5P85d29(XlccOYX8k8GKaFktgzKHAaJxHhxs6lVcp(E6loXCaOH4EfD4AOWoj9SwcUdCI57kIgscmELl9Swc8xHJdCqk(cXk4o5PqnGXRWJlj9LxHhFp9fNyoa0qCVIoCnuyNKEwlb3boX8DfrdjbgVYLv6zTeoXCaifVasYt5ZhPN1sYxai3Iu8cijpLpFoG0ZAjR)WTi3I2wan4gbjHblI7VmEfEq4eZbGgI7v0Hlb(d43cOvmazme3YIysDQbmEfECjPV8k847PV4eZbGgI7v0HRHc7K0ZAj4oWjMVRiAijW4vU0ZAj4oWjMVRiAi3LXLmj9SwcUdCI57kIgYG)JUlJlXqCllIj1PgW4v4XLK(YRWJVN(ItmhaAiUxrhUgkStspRLG7aNy(UIOHKaJx5spRLG7aNy(UIOHKWGfXDMjzLv6zTeCh4eZ3venK7Y4sudZ4v4bHtmhaAiUxrhUe4pGFlGwXaK57g8rgdXTSiMuNAaJxHhxs6lVcp(E6Ra2wirlmuG7AOWojBc2eUTSuh(8rnxbUer0iJCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjYLEwlHtmhasXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViOgW4v4XLK(YRWJVN(ItmhaYtjdf2jPN1s4eZbGWTC2aK7Y4sMzsfNcwQdK13bAW)r4woBGl1agVcpUK0xEfE890x3NcKHRInuyNgCWef8oZ08E(YLEwlHtmhasXlGKC8IqU0ZAj5laKBrkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fb1agVcpUK0xEfE890xCI5aqsD(UgkStspRLKVoGClABtaUKNICPN1s4eZbGWTC2aK7Y4s(T0OgW4v4XLK(YRWJVN(ItmhasIZKBadf2PbhmrbVZmPItbl1bIeNj3aObhmsbVYLEwlHtmhasXlGKC8IqU0ZAj5laKBrkEbKKJxeYpG0ZAjR)WTi3I2wan4gb54fHCPN1s4eZbGWTC2aK7Y4sMKEwlHtmhac3Yzdqg8F0DzCjYXU3pErqavoMxHhKegSiUudy8k84ssF5v4X3tFXjMdajXzYnGHc7K0ZAjCI5aqkEbKKJxeYLEwljFbGClsXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViKl9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlr(YDiwcNyoaKNsYXU3pErq4eZbG8uIKWGfXDMPg8r(GdMOG3zMM3Llh7E)4fbbu5yEfEqsyWI4snGXRWJlj9LxHhFp9fNyoaKeNj3agkStspRLWjMdaP4fqsEkYLEwlHtmhasXlGKKWGfXDMPg8rU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUe5y37hViiGkhZRWdscdwexQbmEfECjPV8k847PV4eZbGK4m5gWqHDs6zTK8faYTifVasYtrU0ZAjCI5aqkEbKKJxeYLEwljFbGClsXlGKKWGfXDMPg8rU0ZAjCI5aq4woBaYDzCjtspRLWjMdaHB5Sbid(p6UmUe5y37hViiGkhZRWdscdwexQbmEfECjPV8k847PV4eZbGK4m5gWqHDs6zTeoXCaifVasYXlc5spRLKVaqUfP4fqsoEri)aspRLS(d3IClABb0GBeKNI8di9SwY6pClYTOTfqdUrqsyWI4oZud(ix6zTeoXCaiClNna5UmUKjPN1s4eZbGWTC2aKb)hDxgxc1agVcpUK0xEfE890xCI5aqsCMCdyOWoTC2alPf4(2suW7mL28Ll9SwcNyoaeULZgGCxgxYK0ZAjCI5aq4woBaYG)JUlJlrE(cW6zdq4eZbGK8HeNNbeRCgVcvaccyiG7VQlx6zTKdWBRKNbqoErqnGXRWJlj9LxHhFp9fNyoae8xP7xHhgkStlNnWsAbUVTef8otPnF5spRLWjMdaHB5Sbi3LXLmJ0ZAjCI5aq4woBaYG)JUlJlrE(cW6zdq4eZbGK8HeNNbeRCgVcvaccyiG7VQlx6zTKdWBRKNbqoErqnGXRWJlj9LxHhFp9fNyoaKuNVl1agVcpUK0xEfE890xGkhZRWddf2jPN1sYxai3Iu8cijhViKl9SwcNyoaKIxaj54fH8di9SwY6pClYTOTfqdUrqoErqnGXRWJlj9LxHhFp9fNyoaKeNj3audOgW4v4XLCB5eoi85(90xVlGgCWOgyyOWoj7YDiwceDrt7cbCKp4Gjk4DMjJz5YhCWef8(708C(Y85JSQ5YDiwceDrt7cbCKp4Gjk4DMjJ58LHAaJxHhxYTLt4GWN73tFP4RWddf2jPN1s4eZbGu8cijpfQbmEfECj3woHdcFUFp91kgaQGtfdf2P8fG1ZgGSWqXtUJk4urU0ZAjW)w(DxHhKNICzXU3pErq4eZbGu8cijjWNY(8XkAAxucdwe3zMuJLld1agVcpUKBlNWbHp3VN(QlAA3lYyS3PzaXAOWoj9SwcNyoaKIxaj54fHCPN1sYxai3Iu8cijhViKFaPN1sw)HBrUfTTaAWncYXlcQbmEfECj3woHdcFUFp9Le3GClAtbUKRHc7K0ZAjCI5aqkEbKKJxeYLEwljFbGClsXlGKC8Iq(bKEwlz9hUf5w02cOb3iihViOgW4v4XLCB5eoi85(90xsqEHSer0yOWoj9SwcNyoaKIxaj5PqnGXRWJl52YjCq4Z97PVK6UFq2xwMHc7K0ZAjCI5aqkEbKKNc1agVcpUKBlNWbHp3VN(YksqQ7(XqHDs6zTeoXCaifVasYtHAaJxHhxYTLt4GWN73tFXbgUBYDeM7Ddf2jPN1s4eZbGu8cijpfQbmEfECj3woHdcFUFp917ciXcJRHc7K0ZAjCI5aqkEbKKNc1agVcpUKBlNWbHp3VN(6DbKyHHHG1c4ff8aMA68rWRNxKeFAadf2jPN1s4eZbGu8cijpLpFWU3pErq4eZbGu8cijjmyrC)DA(Zx(bKEwlz9hUf5w02cOb3iipfQbmEfECj3woHdcFUFp917ciXcdddEatWqPSe4oYZtWbgmuyNWU3pErq4eZbGu8cijjmyrCNzY4LtnGXRWJl52YjCq4Z97PVExajwyyyWdy6KaFSIeqQG7f6gkSty37hViiCI5aqkEbKKegSiU)oz8Y)8rfNcwQdewb5b6Db1Cs9pFKDfdyQC5Q4uWsDGicvqUWb5kqa5K6YZxawpBaYvO06b6UEoKHAaJxHhxYTLt4GWN73tF9UasSWWWGhW01FDKOjelKgkSty37hViiCI5aqkEbKKegSiU)oz8Y)8rfNcwQdewb5b6Db1Cs9pFKDfdyQC5Q4uWsDGicvqUWb5kqa5K6YZxawpBaYvO06b6UEoKHAaJxHhxYTLt4GWN73tF9UasSWWWGhWutVmLwKBr89kgIoVcpmuyNWU3pErq4eZbGu8cijjmyrC)DY4L)5JkofSuhiScYd07cQ5K6F(i7kgWu5YvXPGL6areQGCHdYvGaYj1LNVaSE2aKRqP1d0D9Cid1agVcpUKBlNWbHp3VN(6DbKyHHHbpGPbJzPeq3waw04Dfydf2jS79JxeeoXCaifVasscdwe3zMMVCzvXPGL6areQGCHdYvGas1Cs9pFwXa(T0kxgQbmEfECj3woHdcFUFp917ciXcdddEatdgZsjGUTaSOX7kWgkSty37hViiCI5aqkEbKKegSiUZmnF5Q4uWsDGicvqUWb5kqa5K6YLEwljFbGClsXlGK8uKl9Sws(ca5wKIxajjHblI7mtYQE5gdmF1W5laRNna5kuA9aDxphYiFfdyMsR8Qj)2wpRMMIXRZRWdJnz7w36wR]] )


end
