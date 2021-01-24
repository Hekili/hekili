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


    spec:RegisterPack( "Arcane", 20210124, [[dSKpDeqisf6rQqIlPcjf2eQQprbgfKYPGKwLePIxHQWSKiUffKKDH4xqQAyqQCmsLwgPIEMkennvi11ivW2uHqFtIu14OGuNtIuADuqmpjQUNkAFqIoOkKKfIQOhsbvxKcsOpkrQKtkrkSskuZKck3ufskANqc)KcsWqvHKslLcsQNsrtvfQRkrk6RsKk1yLizVs6VinysomXIrLhd1KvPld2mL(SuA0sXPrz1Qqs1RPqMTuDBLSBHFt1WjLJRcblx0ZvQPR46qSDsvFxcJhvPZlrz9uqIMVky)Q6QU1JRMxzGkk0j60PUOtxDE0eDrNUh9rwnNY0GQPMGnsAHQzilOAEuLyjGQPMuw3LB94Q52rsmunBMrBBiOh9TSPbHJG9f63SfsxgMh4uSd63Sfg9vtoewFknIkx18kdurHorNo1fD6QZJMOl609O1zPTAU1aCffhrDwnBy3levUQ5f24Q5r5O8QJAkTWRoQsSeWB8r5O8kJLarYYELop6sELorNo19n(n(OCuELHAy56HxPxsMW1bISOBnz9kw8kRO3Zx52xTHzyr7Mil6wtwVcnCdGn6vL5i5R2Aa(vU2W8yJk5n(OCuEvP5gE1uMgdl9xzYwg(RAK42zr7RC7RWnseq)vSyGmr0gMhVIf7bK7RC7Rmalbg6ubpmpmGun7S9SRhxnDniGSECff6wpUAcHW1HBLNvtCYgizs1eTxLiby9SfiBMwJh0945IaHW1H7RoC4vjsawpBbYalnpLoTqsncecxhUVc1xX)vJ0Hyijsau3s18cijqiCD4(k(Vc7E)6fbjrcG6wQMxajjHLWI9R4)k0EfhI1ssKaOULQ5fqsUEr8QdhELwc6PT4lrxIKyjakNKP0cVc1QPGhMhvtqVJLH5rDQOqN1JRMqiCD4w5z1eNSbsMuntKaSE2cKlBJzADwizzuSVwsCjqiCD4(k(VIdXAjx2gZ06SqYYOyFTK4sTPVhcIw1uWdZJQPLLaLRl7PovuCK1JRMqiCD4w5z1eNSbsMuntKaSE2cK2KT7LrzygUdeieUoCFf)xTKqiA45vO8vLwDOAk4H5r10M(EOHRxQtffhD94QjecxhUvEwnXjBGKjvtD8vjsawpBbYMP14bDpEUiqiCD4wnf8W8OAEbzA48mG6urHoupUAcHW1HBLNvtCYgizs1CjHq0WZRq5RoA0vnf8W8OAMYLjXq3AsAuDQO4iwpUAcHW1HBLNvtCYgizs1KdXAjsILaOAEbKKRxeVI)RWU3VErqKelbq18cijjSewSFf)xPxsMW1bcl0d5axQRbbKVshpFLUvtbpmpQM7gMDyrlvZlGSovuu6RhxnHq46WTYZQjozdKmPAQxsMW1bcl0d5axQRbbKV68v6(k(Vc7E)6fbjrcG6wQMxajjHLWI9RoFf6QMcEyEunLelbq9KRovuyORhxnHq46WTYZQjozdKmPAQxsMW1bcl0d5axQRbbKV68v6(k(Vc7E)6fbjrcG6wQMxajjHLWI9RoFf6Ef)xXHyTejXsauCJKTazpc2Oxv(R4qSwIKyjakUrYwGSeEP7rWgvnf8W8OAkjwcGY1L9uNkkkT1JRMqiCD4w5z1eNSbsMun1ljt46aHf6HCGl11GaYxD(kDFf)xXHyTKejaQBPAEbKKRxevtbpmpQMjsau3s18ciRtff6IU6XvtieUoCR8SAIt2ajtQM6LKjCDGWc9qoWL6Aqa5RoFLUVI)R0XxH2RsKaSE2cKntRXd6E8CrGq46W9vho8QejaRNTazGLMNsNwiPgbcHRd3xHA1uWdZJQPMpmpQtff6QB94QjecxhUvEwnXjBGKjvtoeRLKibqDlvZlGKC9IOAk4H5r18cY0W5za1PIcD1z94QjecxhUvEwnXjBGKjvtoeRLKibqDlvZlGKC9I4vho8kTe0tBXxIUejXsauojtPfQMcEyEunxSm9CtDlD8CbXuNkk09iRhxnHq46WTYZQjozdKmPAYHyTKejaQBPAEbKKRxeV6WHxPLGEAl(s0LijwcGYjzkTq1uWdZJQ54i4gQBPtdqxslRovuO7rxpUAcHW1HBLNvtCYgizs1ulb90w8LOlzCeCd1T0PbOlPLvnf8W8OAkjwcGQ5fqwNkk0vhQhxnHq46WTYZQjozdKmPAYHyTKejaQBPAEbKKRxevtbpmpQMjsau3s18ciRtff6EeRhxnHq46WTYZQjozdKmPAEboeRLmocUH6w60a0L0YiiAVI)RUahI1sghb3qDlDAa6sAzKewcl2VQ8xj4H5brsSeaDX2Bwh2eGxaJmaDylOAk4H5r1ulHneyG6w6If36urHUL(6XvtieUoCR8SAIt2ajtQMJ0Hyijsau3s18cijqiCD4(k(VIdXAjsILaOAEbKeeTxX)vCiwljrcG6wQMxajjHLWI9Rk)vT4lzj8wnf8W8OAQLWgcmqDlDXIBDQOqxdD94QjecxhUvEwnXjBGKjvZRpKuUmjg6wtsJijSewSFfkFLo8QdhE1f4qSwskxMedDRjPru9i9asHJ1ztzK9iyJEfkFf6QMcEyEunLelbq56YEQtff6wARhxnHq46WTYZQjozdKmPAYHyTeTe2qGbQBPlwCjiAVI)RUahI1sghb3qDlDAa6sAzeeTxX)vxGdXAjJJGBOULonaDjTmsclHf7xv(5Re8W8GijwcGY1L9qaEbmYa0HTGQPGhMhvtjXsauUUSN6urHorx94QjecxhUvEwnXjBGKjvtoeRLKibqDlvZlGKGO9k(Vc7E)6fbrsSeavZlGKKGCl7v8F1scHOHNxv(RoA09k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJEf)xPJVkrcW6zlq2mTgpO7XZfbcHRd3xX)v64RsKaSE2cKbwAEkDAHKAeieUoCRMcEyEunLelbq5KmLwOovuOtDRhxnHq46WTYZQjozdKmPAYHyTKejaQBPAEbKeeTxX)vCiwlrsSeavZlGKC9I4v8FfhI1ssKaOULQ5fqssyjSy)QYpFvl((k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJEf)xPxsMW1bcl0d5axQRbbKvtbpmpQMsILaOCsMsluNkk0PoRhxnHq46WTYZQjUryr1u3QjizVmkUrybLzRMCiwlb3bjXYEyrlf3iraDY1lc(OXHyTejXsaunVascI2HdOPJJ0HyiUEi18ciHlF04qSwsIea1TunVascI2Hdy37xViiGEhldZdscYTmurf1QjozdKmPAEboeRLmocUH6w60a0L0YiiAVI)RgPdXqKelbqbCJtGq46W9v8FfAVIdXAjxqMgopdGC9I4vho8kbpm9afcyXG9RoFLUVc1xX)vxGdXAjJJGBOULonaDjTmsclHf7xHYxj4H5brsSeaDX2Bwh2eGxaJmaDyl4v8FfAVshFLyOes2aejXsaunK1c6SOLaHW1H7RoC4vCiwlb3bjXYEyrlf3iraDY1lIxHA1uWdZJQPKyja6IT3SoSRtff68iRhxnHq46WTYZQjozdKmPAYHyTejXsauCJKTazpc2Oxv(5R0ljt46az8zrxcVuCJKTW(v8FfAVc7E)6fbrsSeavZlGKKWsyX(vO8v6IUxD4WRe8W0duiGfd2VQ8ZxPZxHA1uWdZJQPKyjaQNC1PIcDE01JRMqiCD4w5z1eNSbsMun5qSwsIea1TunVascI2RoC4vljeIgEEfkFLU6q1uWdZJQPKyjakxx2tDQOqN6q94QjecxhUvEwnf8W8OAc6DSmmpQMSyGmr0gkZwnxsien8GYtdTounzXazIOnu2AbxMmq1u3QjozdKmPAYHyTKejaQBPAEbKKRxeVI)R4qSwIKyjaQMxaj56frDQOqNhX6XvtbpmpQMsILaOCsMslunHq46WTYZ6uNQz6JmmpQhxrHU1JRMqiCD4w5z1uWdZJQjO3XYW8OAEHnozAdZJQPGhMhBs6Jmmp4Xj6XsGHovWdZJsy2tbpmpiGEhldZdcUrIa6SOL)scHOHhuEwA1b(OPJjsawpBbYMP14bDpEUoCGdXAjBMwJh0945IShbB0jhI1s2mTgpO7XZfzj8s3JGnc1QjozdKmPAUKqiA45vLF(k9sYeUoqa9ovdpVI)Rq7vy37xViiJJGBOULonaDjTmsclHf7xv(5Re8W8Ga6DSmmpiaVagza6WwWRoC4vy37xViisILaOAEbKKewcl2VQ8Zxj4H5bb07yzyEqaEbmYa0HTGxD4WRq7vJ0Hyijsau3s18cijqiCD4(k(Vc7E)6fbjrcG6wQMxajjHLWI9Rk)8vcEyEqa9owgMheGxaJmaDyl4vO(kuFf)xXHyTKejaQBPAEbKKRxeVI)R4qSwIKyjaQMxaj56fXR4)QlWHyTKXrWnu3sNgGUKwg56fXR4)kD8vAjON2IVeDjJJGBOULonaDjTS6urHoRhxnHq46WTYZQjozdKmPAMiby9SfiBMwJh0945IaHW1H7R4)kS79RxeejXsaunVassclHf7xv(5Re8W8Ga6DSmmpiaVagza6Wwq1uWdZJQjO3XYW8OovuCK1JRMqiCD4w5z1uWdZJQPKyjakNKP0cvZlSXjtByEun5PKP0cVIzFfBmy)QHTGxn(Rq2WRgFwVsI7RkGx1i6HxnU)QLeL9kCJKTWUAIt2ajtQMy37xViiJJGBOULonaDjTmscYTSxX)vO9koeRLijwcGIBKSfi7rWg9ku(k9sYeUoqgFw0LWlf3izlSFf)xHDVF9IGijwcGQ5fqssyjSy)QYpFfWlGrgGoSf8k(VAjHq0WZRq5R0ljt46ar0OlwWwil6scHQHNxX)vCiwljrcG6wQMxaj56fXRqTovuC01JRMqiCD4w5z1eNSbsMunXU3VErqghb3qDlDAa6sAzKeKBzVI)Rq7vCiwlrsSeaf3izlq2JGn6vO8v6LKjCDGm(SOlHxkUrYwy)k(VAKoedjrcG6wQMxajbcHRd3xX)vy37xViijsau3s18cijjSewSFv5NVc4fWidqh2cEf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQO9kuRMcEyEunLelbq5KmLwOovuOd1JRMqiCD4w5z1eNSbsMunXU3VErqghb3qDlDAa6sAzKeKBzVI)Rq7vCiwlrsSeaf3izlq2JGn6vO8v6LKjCDGm(SOlHxkUrYwy)k(VcTxPJVAKoedjrcG6wQMxajbcHRd3xD4WRWU3VErqsKaOULQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tA6AVc1xX)vy37xViisILaOAEbKKewcl2VcLVsVKmHRdKXNfDj8sVqxkJA9KkAVc1QPGhMhvtjXsauojtPfQtffhX6XvtieUoCR8SAIt2ajtQMxGdXAjPCzsm0TMKgr1J0difowNnLr2JGn6vNV6cCiwljLltIHU1K0iQEKEaPWX6SPmYs4LUhbB0R4)k0EfhI1sKelbq18cijxViE1HdVIdXAjsILaOAEbKKewcl2VQ8Zx1IVVc1xX)vO9koeRLKibqDlvZlGKC9I4vho8koeRLKibqDlvZlGKKWsyX(vLF(Qw89vOwnf8W8OAkjwcGYjzkTqDQOO0xpUAcHW1HBLNvtCYgizs186djLltIHU1K0isclHf7xHYxzOF1HdVcTxDboeRLKYLjXq3AsAevpspGu4yD2ugzpc2OxHYxHUxX)vxGdXAjPCzsm0TMKgr1J0difowNnLr2JGn6vL)QlWHyTKuUmjg6wtsJO6r6bKchRZMYilHx6EeSrVc1QPGhMhvtjXsauUUSN6urHHUEC1ecHRd3kpRM4KnqYKQjhI1s0sydbgOULUyXLGO9k(V6cCiwlzCeCd1T0PbOlPLrq0Ef)xDboeRLmocUH6w60a0L0YijSewSFv5NVsWdZdIKyjakxx2db4fWidqh2cQMcEyEunLelbq56YEQtffL26XvtieUoCR8SAIBewun1TAcs2lJIBewqz2QjhI1sWDqsSShw0sXnseqNC9IGpACiwlrsSeavZlGKGOD4aA64iDigIRhsnVas4YhnoeRLKibqDlvZlGKGOD4a29(1lccO3XYW8GKGCldvurTAIt2ajtQMxGdXAjJJGBOULonaDjTmcI2R4)Qr6qmejXsaua34eieUoCFf)xH2R4qSwYfKPHZZaixViE1HdVsWdtpqHawmy)QZxP7Rq9v8FfAV6cCiwlzCeCd1T0PbOlPLrsyjSy)ku(kbpmpisILaOl2EZ6WMa8cyKbOdBbV6WHxHDVF9IGOLWgcmqDlDXIljHLWI9RoC4vyxpesmeJklzs8kuFf)xH2R0XxjgkHKnarsSeavdzTGolAjqiCD4(QdhEfhI1sWDqsSShw0sXnseqNC9I4vOwnf8W8OAkjwcGUy7nRd76urHUOREC1ecHRd3kpRM4KnqYKQjhI1sWDqsSShw0ssqWZR4)koeRLa8QjXfUunFGyysNGOvnf8W8OAkjwcGUy7nRd76urHU6wpUAcHW1HBLNvtbpmpQMsILaOl2EZ6WUAIBewun1TAIt2ajtQMCiwlb3bjXYEyrljbbpVI)Rq7vCiwlrsSeavZlGKGO9QdhEfhI1ssKaOULQ5fqsq0E1HdV6cCiwlzCeCd1T0PbOlPLrsyjSy)ku(kbpmpisILaOl2EZ6WMa8cyKbOdBbVc16urHU6SEC1ecHRd3kpRMcEyEunLelbqxS9M1HD1e3iSOAQB1eNSbsMun5qSwcUdsIL9WIwsccEEf)xXHyTeChKel7HfTK9iyJE15R4qSwcUdsIL9WIwYs4LUhbBuDQOq3JSEC1ecHRd3kpRMcEyEunLelbqxS9M1HD1e3iSOAQB1eNSbsMun5qSwcUdsIL9WIwsccEEf)xXHyTeChKel7HfTKewcl2VQ8ZxH2Rq7vCiwlb3bjXYEyrlzpc2Oxv68kbpmpisILaOl2EZ6WMa8cyKbOdBbVc1xXJx1IVVc16urHUhD94QjecxhUvEwnXjBGKjvt0Evc2e2ncxhE1HdVshF1WWgXI2xH6R4)koeRLijwcGIBKSfi7rWg9QZxXHyTejXsauCJKTazj8s3JGn6v8FfhI1sKelbq18cijxViEf)xDboeRLmocUH6w60a0L0YixViQMcEyEundyAGKoWsd2tDQOqxDOEC1ecHRd3kpRM4KnqYKQjhI1sKelbqXns2cK9iyJEv5NVsVKmHRdKXNfDj8sXns2c7QPGhMhvtjXsaup5Qtff6EeRhxnHq46WTYZQjozdKmPAUKqiA45vLF(QsRo8k(VIdXAjsILaOAEbKKRxeVI)R4qSwsIea1TunVasY1lIxX)vxGdXAjJJGBOULonaDjTmY1lIQPGhMhvZnIgKHRxQtff6w6RhxnHq46WTYZQjozdKmPAYHyTKePdu3sNMeGnbr7v8FfhI1sKelbqXns2cK9iyJEfkF1rwnf8W8OAkjwcGY1L9uNkk01qxpUAcHW1HBLNvtCYgizs1CjHq0WZRk)8v6LKjCDGWjzkTaDjHq1WZR4)koeRLijwcGQ5fqsUEr8k(VIdXAjjsau3s18cijxViEf)xDboeRLmocUH6w60a0L0YixViEf)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrVI)RWU3VErqa9owgMhKewcl2vtbpmpQMsILaOCsMsluNkk0T0wpUAcHW1HBLNvtCYgizs1KdXAjsILaOAEbKKRxeVI)R4qSwsIea1TunVasY1lIxX)vxGdXAjJJGBOULonaDjTmY1lIxX)vCiwlrsSeaf3izlq2JGn6vNVIdXAjsILaO4gjBbYs4LUhbB0R4)Qr6qmejXsaup5iqiCD4(k(Vc7E)6fbrsSea1tosclHf7xv(5RAX3xX)vljeIgEEv5NVQ0IUxX)vy37xViiGEhldZdsclHf7QPGhMhvtjXsauojtPfQtff6eD1JRMqiCD4w5z1eNSbsMun5qSwIKyjaQMxajbr7v8FfhI1sKelbq18cijjSewSFv5NVQfFFf)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrVI)RWU3VErqa9owgMhKewcl2vtbpmpQMsILaOCsMsluNkk0PU1JRMqiCD4w5z1eNSbsMun5qSwsIea1TunVascI2R4)koeRLijwcGQ5fqsUEr8k(VIdXAjjsau3s18cijjSewSFv5NVQfFFf)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrVI)RWU3VErqa9owgMhKewcl2vtbpmpQMsILaOCsMsluNkk0PoRhxnHq46WTYZQjozdKmPAYHyTejXsaunVasY1lIxX)vCiwljrcG6wQMxaj56fXR4)QlWHyTKXrWnu3sNgGUKwgbr7v8F1f4qSwY4i4gQBPtdqxslJKWsyX(vLF(Qw89v8FfhI1sKelbqXns2cK9iyJE15R4qSwIKyjakUrYwGSeEP7rWgvnf8W8OAkjwcGYjzkTqDQOqNhz94QjecxhUvEwnXjBGKjvZrYwyinG0NgIgEEv5V6i1HxX)vCiwlrsSeaf3izlq2JGn6vO88vO9kbpm9afcyXG9Rmu9kDFfQVI)RsKaSE2cejXsauoFXj5DbXqGq46W9v8FLGhMEGcbSyW(vO8v6(k(VIdXAjxqMgopdGC9IOAk4H5r1usSeaLtYuAH6urHop66XvtieUoCR8SAIt2ajtQMJKTWqAaPpnen88QYF1rQdVI)R4qSwIKyjakUrYwGShbB0Rk)vCiwlrsSeaf3izlqwcV09iyJEf)xLiby9SfisILaOC(ItY7cIHaHW1H7R4)kbpm9afcyXG9Rq5R09v8FfhI1sUGmnCEga56fr1uWdZJQPKyjakWRw33mpQtff6uhQhxnf8W8OAkjwcGY1L9unHq46WTYZ6urHopI1JRMqiCD4w5z1eNSbsMun5qSwsIea1TunVasY1lIxX)vCiwlrsSeavZlGKC9I4v8F1f4qSwY4i4gQBPtdqxslJC9IOAk4H5r1e07yzyEuNkk0zPVEC1uWdZJQPKyjakNKP0cvtieUoCR8So1PAkoupUIcDRhxnHq46WTYZQjozdKmPAMiby9Sfix2gZ06SqYYOyFTK4sGq46W9v8Ff29(1lcchI1sVSnMP1zHKLrX(AjXLKGCl7v8FfhI1sUSnMP1zHKLrX(AjXLAtFpKRxeVI)Rq7vCiwlrsSeavZlGKC9I4v8FfhI1ssKaOULQ5fqsUEr8k(V6cCiwlzCeCd1T0PbOlPLrUEr8kuFf)xHDVF9IGmocUH6w60a0L0YijSewSF15Rq3R4)k0EfhI1sKelbqXns2cK9iyJEv5NVsVKmHRdeXb64ZIUeEP4gjBH9R4)k0EfAVAKoedjrcG6wQMxajbcHRd3xX)vy37xViijsau3s18cijjSewSFv5NVQfFFf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQO9kuF1HdVcTxPJVAKoedjrcG6wQMxajbcHRd3xX)vy37xViisILaOAEbKKewcl2VcLVsVKmHRdKXNfDj8sVqxkJA9KkAVc1xD4WRWU3VErqKelbq18cijjSewSFv5NVQfFFfQVc1QPGhMhvtB67HZ7tDQOqN1JRMqiCD4w5z1eNSbsMunr7vjsawpBbYLTXmTolKSmk2xljUeieUoCFf)xHDVF9IGWHyT0lBJzADwizzuSVwsCjji3YEf)xXHyTKlBJzADwizzuSVwsCPwwcKRxeVI)R0sqpTfFj6sSPVhoVpVc1xD4WRq7vjsawpBbYLTXmTolKSmk2xljUeieUoCFf)xnSf8QYFLUVc1QPGhMhvtllbkxx2tDQO4iRhxnHq46WTYZQjozdKmPAMiby9SfiTjB3lJYWmChiqiCD4(k(Vc7E)6fbrsSeavZlGKKWsyX(vO8vhj6Ef)xHDVF9IGmocUH6w60a0L0YijSewSF15Rq3R4)k0EfhI1sKelbqXns2cK9iyJEv5NVsVKmHRdeXb64ZIUeEP4gjBH9R4)k0EfAVAKoedjrcG6wQMxajbcHRd3xX)vy37xViijsau3s18cijjSewSFv5NVQfFFf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQO9kuF1HdVcTxPJVAKoedjrcG6wQMxajbcHRd3xX)vy37xViisILaOAEbKKewcl2VcLVsVKmHRdKXNfDj8sVqxkJA9KkAVc1xD4WRWU3VErqKelbq18cijjSewSFv5NVQfFFfQVc1QPGhMhvtB67HgUEPovuC01JRMqiCD4w5z1eNSbsMuntKaSE2cK2KT7LrzygUdeieUoCFf)xHDVF9IGijwcGQ5fqssyjSy)QZxHUxX)vO9k0EfAVc7E)6fbzCeCd1T0PbOlPLrsyjSy)ku(k9sYeUoqen6s4LEHUug16jD8z9k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJEfQV6WHxH2RWU3VErqghb3qDlDAa6sAzKewcl2V68vO7v8FfhI1sKelbqXns2cK9iyJEv5NVsVKmHRdeXb64ZIUeEP4gjBH9Rq9vO(k(VIdXAjjsau3s18cijxViEfQvtbpmpQM203dnC9sDQOqhQhxnHq46WTYZQjozdKmPAMiby9SfiBMwJh0945IaHW1H7R4)kTe0tBXxIUeqVJLH5r1uWdZJQ54i4gQBPtdqxslRovuCeRhxnHq46WTYZQjozdKmPAMiby9SfiBMwJh0945IaHW1H7R4)k0ELwc6PT4lrxcO3XYW84vho8kTe0tBXxIUKXrWnu3sNgGUKw2RqTAk4H5r1usSeavZlGSovuu6RhxnHq46WTYZQjozdKmPAoSf8ku(QJeDVI)RsKaSE2cKntRXd6E8CrGq46W9v8FfhI1sKelbqXns2cK9iyJEv5NVsVKmHRdeXb64ZIUeEP4gjBH9R4)kS79RxeKXrWnu3sNgGUKwgjHLWI9RoFf6Ef)xHDVF9IGijwcGQ5fqssyjSy)QYpFvl(wnf8W8OAc6DSmmpQtffg66XvtieUoCR8SAk4H5r1e07yzyEunzXazIOnuMTAYHyTKntRXd6E8Cr2JGn6KdXAjBMwJh0945ISeEP7rWgvnzXazIOnu2AbxMmq1u3QjozdKmPAoSf8ku(QJeDVI)RsKaSE2cKntRXd6E8CrGq46W9v8Ff29(1lcIKyjaQMxajjHLWI9RoFf6Ef)xH2Rq7vO9kS79RxeKXrWnu3sNgGUKwgjHLWI9Rq5R0ljt46ar0OlHx6f6szuRN0XN1R4)koeRLijwcGIBKSfi7rWg9QZxXHyTejXsauCJKTazj8s3JGn6vO(QdhEfAVc7E)6fbzCeCd1T0PbOlPLrsyjSy)QZxHUxX)vCiwlrsSeaf3izlq2JGn6vLF(k9sYeUoqehOJpl6s4LIBKSf2Vc1xH6R4)koeRLKibqDlvZlGKC9I4vOwNkkkT1JRMqiCD4w5z1eNSbsMunr7vy37xViisILaOAEbKKewcl2VcLV6O1HxD4WRWU3VErqKelbq18cijjSewSFv5NV6iFfQVI)RWU3VErqghb3qDlDAa6sAzKewcl2V68vO7v8FfAVIdXAjsILaO4gjBbYEeSrVQ8ZxPxsMW1bI4aD8zrxcVuCJKTW(v8FfAVcTxnshIHKibqDlvZlGKaHW1H7R4)kS79RxeKejaQBPAEbKKewcl2VQ8Zx1IVVI)RWU3VErqKelbq18cijjSewSFfkFLo8kuF1HdVcTxPJVAKoedjrcG6wQMxajbcHRd3xX)vy37xViisILaOAEbKKewcl2VcLVshEfQV6WHxHDVF9IGijwcGQ5fqssyjSy)QYpFvl((kuFfQvtbpmpQMlwMEUPULoEUGyQtff6IU6XvtieUoCR8SAIt2ajtQMy37xViiJJGBOULonaDjTmsclHf7xv(RaEbmYa0HTGxX)vO9koeRLijwcGIBKSfi7rWg9QYpFLEjzcxhiId0XNfDj8sXns2c7xX)vO9k0E1iDigsIea1TunVascecxhUVI)RWU3VErqsKaOULQ5fqssyjSy)QYpFvl((k(Vc7E)6fbrsSeavZlGKKWsyX(vO8v6LKjCDGm(SOlHx6f6szuRNur7vO(QdhEfAVshF1iDigsIea1TunVascecxhUVI)RWU3VErqKelbq18cijjSewSFfkFLEjzcxhiJpl6s4LEHUug16jv0EfQV6WHxHDVF9IGijwcGQ5fqssyjSy)QYpFvl((kuFfQvtbpmpQMPCzsm0TMKgvNkk0v36XvtieUoCR8SAIt2ajtQMy37xViisILaOAEbKKewcl2VQ8xb8cyKbOdBbVI)Rq7vO9k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vO8v6LKjCDGiA0LWl9cDPmQ1t64Z6v8FfhI1sKelbqXns2cK9iyJE15R4qSwIKyjakUrYwGSeEP7rWg9kuF1HdVcTxHDVF9IGmocUH6w60a0L0YijSewSF15Rq3R4)koeRLijwcGIBKSfi7rWg9QYpFLEjzcxhiId0XNfDj8sXns2c7xH6Rq9v8FfhI1ssKaOULQ5fqsUEr8kuRMcEyEunt5YKyOBnjnQovuORoRhxnHq46WTYZQjozdKmPAIDVF9IGijwcGQ5fqssyjSy)QZxHUxX)vO9k0EfAVc7E)6fbzCeCd1T0PbOlPLrsyjSy)ku(k9sYeUoqen6s4LEHUug16jD8z9k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJEfQV6WHxH2RWU3VErqghb3qDlDAa6sAzKewcl2V68vO7v8FfhI1sKelbqXns2cK9iyJEv5NVsVKmHRdeXb64ZIUeEP4gjBH9Rq9vO(k(VIdXAjjsau3s18cijxViEfQvtbpmpQMxqMgopdOovuO7rwpUAcHW1HBLNvtCYgizs1KdXAjsILaO4gjBbYEeSrVQ8ZxPxsMW1bI4aD8zrxcVuCJKTW(v8FfAVcTxnshIHKibqDlvZlGKaHW1H7R4)kS79RxeKejaQBPAEbKKewcl2VQ8Zx1IVVI)RWU3VErqKelbq18cijjSewSFfkFLEjzcxhiJpl6s4LEHUug16jv0EfQV6WHxH2R0XxnshIHKibqDlvZlGKaHW1H7R4)kS79RxeejXsaunVassclHf7xHYxPxsMW1bY4ZIUeEPxOlLrTEsfTxH6RoC4vy37xViisILaOAEbKKewcl2VQ8Zx1IVVc1QPGhMhvZXrWnu3sNgGUKwwDQOq3JUEC1ecHRd3kpRM4KnqYKQjAVcTxHDVF9IGmocUH6w60a0L0YijSewSFfkFLEjzcxhiIgDj8sVqxkJA9Ko(SEf)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrVc1xD4WRq7vy37xViiJJGBOULonaDjTmsclHf7xD(k09k(VIdXAjsILaO4gjBbYEeSrVQ8ZxPxsMW1bI4aD8zrxcVuCJKTW(vO(kuFf)xXHyTKejaQBPAEbKKRxevtbpmpQMsILaOAEbK1PIcD1H6XvtieUoCR8SAIt2ajtQMCiwljrcG6wQMxaj56fXR4)k0EfAVc7E)6fbzCeCd1T0PbOlPLrsyjSy)ku(kDIUxX)vCiwlrsSeaf3izlq2JGn6vNVIdXAjsILaO4gjBbYs4LUhbB0Rq9vho8k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vNVcDVI)R4qSwIKyjakUrYwGShbB0Rk)8v6LKjCDGioqhFw0LWlf3izlSFfQVc1xX)vO9kS79RxeejXsaunVassclHf7xHYxPRoF1HdV6cCiwlzCeCd1T0PbOlPLrq0EfQvtbpmpQMjsau3s18ciRtff6EeRhxnHq46WTYZQjozdKmPAIDVF9IGijwcG6jhjHLWI9Rq5R0HxD4WR0XxnshIHijwcG6jhbcHRd3QPGhMhvZDdZoSOLQ5fqwNkk0T0xpUAcHW1HBLNvtCYgizs1KdXAjxqMgopdGGO9k(V6cCiwlzCeCd1T0PbOlPLrq0Ef)xDboeRLmocUH6w60a0L0YijSewSFv5NVIdXAjAjSHadu3sxS4swcV09iyJEvPZRe8W8GijwcGY1L9qaEbmYa0HTGQPGhMhvtTe2qGbQBPlwCRtff6AORhxnHq46WTYZQjozdKmPAYHyTKlitdNNbqq0Ef)xH2Rq7vJ0HyijS9qcmqGq46W9v8FLGhMEGcbSyW(vL)QJ(vO(QdhELGhMEGcbSyW(vL)kD4vO(k(VcTxPJVkrcW6zlqKelbq58fNK3fedbcHRd3xD4WRgjBHH0asFAiA45vO8vhPo8kuRMcEyEunLelbq56YEQtff6wARhxnf8W8OAUr0GmC9s1ecHRd3kpRtff6eD1JRMqiCD4w5z1eNSbsMun5qSwIKyjakUrYwGShbB0Rq55Rq7vcEy6bkeWIb7xzO6v6(kuFf)xLiby9SfisILaOC(ItY7cIHaHW1H7R4)QrYwyinG0NgIgEEv5V6i1HQPGhMhvtjXsauojtPfQtff6u36XvtieUoCR8SAIt2ajtQMCiwlrsSeaf3izlq2JGn6vNVIdXAjsILaO4gjBbYs4LUhbBu1uWdZJQPKyjakNKP0c1PIcDQZ6XvtieUoCR8SAIt2ajtQMCiwlrsSeaf3izlq2JGn6vNVcDvtbpmpQMsILaOEYvNkk05rwpUAcHW1HBLNvtCYgizs1eTxLGnHDJW1HxD4WR0XxnmSrSO9vO(k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJQMcEyEundyAGKoWsd2tDQOqNhD94QjecxhUvEwnXjBGKjvtoeRLG7GKyzpSOLKGGNxX)vjsawpBbIKyjaklSSGnLrGq46W9v8FfAVcTxnshIHilToZYWYW8GaHW1H7R4)kbpm9afcyXG9Rk)vg6xH6RoC4vcEy6bkeWIb7xv(R0HxHA1uWdZJQPKyja6IT3SoSRtff6uhQhxnHq46WTYZQjozdKmPAYHyTeChKel7HfTKee88k(VAKoedrsSeafWnobcHRd3xX)vxGdXAjJJGBOULonaDjTmcI2R4)k0E1iDigIS06mldldZdcecxhUV6WHxj4HPhOqalgSFv5VQ0(kuRMcEyEunLelbqxS9M1HDDQOqNhX6XvtieUoCR8SAIt2ajtQMCiwlb3bjXYEyrljbbpVI)RgPdXqKLwNzzyzyEqGq46W9v8FLGhMEGcbSyW(vL)QJUAk4H5r1usSeaDX2Bwh21PIcDw6RhxnHq46WTYZQjozdKmPAYHyTejXsauCJKTazpc2Oxv(R4qSwIKyjakUrYwGSeEP7rWgvnf8W8OAkjwcGc8Q19nZJ6urHon01JRMqiCD4w5z1eNSbsMun5qSwIKyjakUrYwGShbB0RoFfhI1sKelbqXns2cKLWlDpc2OxX)vAjON2IVeDjsILaOCsMslunf8W8OAkjwcGc8Q19nZJ6urHolT1JRMSyGmr0gkZwnxsien8GYtdTounzXazIOnu2AbxMmq1u3QPGhMhvtqVJLH5r1ecHRd3kpRtDQMxWki9PECff6wpUAk4H5r1e7iXa5wd69QjecxhUvEwNkk0z94QjecxhUvEwnDTQ5gMQPGhMhvt9sYeUoun1lDeOAQB1eNSbsMun1ljt46aPr0duxdc4(QZxHUxX)vAjON2IVeDjGEhldZJxX)v64Rq7vjsawpBbYMP14bDpEUiqiCD4(QdhEvIeG1ZwGmWsZtPtlKuJaHW1H7RqTAQxsAilOA2i6bQRbbCRtffhz94QjecxhUvEwnDTQ5gMQPGhMhvt9sYeUoun1lDeOAQB1eNSbsMun1ljt46aPr0duxdc4(QZxHUxX)vCiwlrsSeavZlGKC9I4v8Ff29(1lcIKyjaQMxajjHLWI9R4)k0EvIeG1ZwGSzAnEq3JNlcecxhUV6WHxLiby9SfidS08u60cj1iqiCD4(kuRM6LKgYcQMnIEG6Aqa36urXrxpUAcHW1HBLNvtxRAUHPAk4H5r1uVKmHRdvt9shbQM6wnXjBGKjvtoeRLijwcGIBKSfi7rWg9QZxXHyTejXsauCJKTazj8s3JGn6v8FLo(koeRLKiDG6w60KaSjiAVI)RSS2MHMWsyX(vLF(k0EfAVAjH8k0)kbpmpisILaOCDzpeSVNxH6RkDELGhMhejXsauUUShcWlGrgGoSf8kuRM6LKgYcQMwwiDkhsg1PIcDOEC1ecHRd3kpRM4KnqYKQjAVAKoedbIoRTzGaUeieUoCFf)xTKqiA45vLF(kdn6Ef)xTKqiA45vO88vhrD4vO(QdhEfAVshF1iDigceDwBZabCjqiCD4(k(VAjHq0WZRk)8vgAD4vOwnf8W8OAUKqOTWQovuCeRhxnHq46WTYZQjozdKmPAYHyTejXsaunVascIw1uWdZJQPMpmpQtffL(6XvtieUoCR8SAIt2ajtQMjsawpBbYalnpLoTqsncecxhUVI)R4qSwcWBJGShMheeTxX)vO9kS79RxeejXsaunVasscYTSxD4WRSS2MHMWsyX(vLF(QJgDVc1QPGhMhvZHTaAHKA1PIcdD94QjecxhUvEwnXjBGKjvtoeRLijwcGQ5fqsUEr8k(VIdXAjjsau3s18cijxViEf)xDboeRLmocUH6w60a0L0YixViQMcEyEun7S2MztpQJCBxqm1PIIsB94QjecxhUvEwnXjBGKjvtoeRLijwcGQ5fqsUEr8k(VIdXAjjsau3s18cijxViEf)xDboeRLmocUH6w60a0L0YixViQMcEyEun5KwQBPtYWgTRtff6IU6XvtieUoCR8SAIt2ajtQMCiwlrsSeavZlGKGOvnf8W8OAYb5gsJyrBDQOqxDRhxnHq46WTYZQjozdKmPAYHyTejXsaunVascIw1uWdZJQjx39l1IKLvNkk0vN1JRMqiCD4w5z1eNSbsMun5qSwIKyjaQMxajbrRAk4H5r10YsGR7(TovuO7rwpUAcHW1HBLNvtCYgizs1KdXAjsILaOAEbKeeTQPGhMhvtjWWEsPtXsVxNkk09ORhxnHq46WTYZQjozdKmPAYHyTejXsaunVascIw1uWdZJQjYgOSbw76urHU6q94QjecxhUvEwnf8W8OA22Lltgp3uo52cvtCYgizs1KdXAjsILaOAEbKeeTxD4WRWU3VErqKelbq18cijjSewSFfkpFLoOdVI)RUahI1sghb3qDlDAa6sAzeeTQjyTaEOHSGQzBxUmz8Ct5KBluNkk09iwpUAcHW1HBLNvtbpmpQMWsRSeKo1ZBibgQM4KnqYKQj29(1lcIKyjaQMxajjHLWI9Rk)8v6eDvZqwq1ewALLG0PEEdjWqDQOq3sF94QjecxhUvEwnf8W8OAEtqUwwcu9WEd9QjozdKmPAIDVF9IGijwcGQ5fqssyjSy)kuE(kDIUxD4WR0XxPxsMW1bIOr9GISHxD(kDF1HdVcTxnSf8QYFLUVI)R0ljt46aHf6HCGl11GaYxD(kDFf)xLiby9SfiBMwJh0945IaHW1H7RqTAgYcQM3eKRLLavpS3qVovuORHUEC1ecHRd3kpRMcEyEun3osNYAd2az1eNSbsMunXU3VErqKelbq18cijjSewSFfkpFLor3RoC4v64R0ljt46ar0OEqr2WRoFLUV6WHxH2Rg2cEv5Vs3xX)v6LKjCDGWc9qoWL6Aqa5RoFLUVI)RsKaSE2cKntRXd6E8CrGq46W9vOwndzbvZTJ0PS2GnqwNkk0T0wpUAcHW1HBLNvtbpmpQMT9Y0AOULk7nBX6YW8OAIt2ajtQMy37xViisILaOAEbKKewcl2VcLNVsNO7vho8kD8v6LKjCDGiAupOiB4vNVs3xD4WRq7vdBbVQ8xP7R4)k9sYeUoqyHEih4sDniG8vNVs3xX)vjsawpBbYMP14bDpEUiqiCD4(kuRMHSGQzBVmTgQBPYEZwSUmmpQtff6eD1JRMqiCD4w5z1uWdZJQ5sWcxc0DdadDHSz4QjozdKmPAIDVF9IGijwcGQ5fqssyjSy)QYpFLo8k(VcTxPJVsVKmHRdewOhYbUuxdciF15R09vho8QHTGxHYxDKO7vOwndzbvZLGfUeO7gag6czZW1PIcDQB94QjecxhUvEwnf8W8OAUeSWLaD3aWqxiBgUAIt2ajtQMy37xViisILaOAEbKKewcl2VQ8ZxPdVI)R0ljt46aHf6HCGl11GaYxD(kDFf)xXHyTKejaQBPAEbKeeTxX)vCiwljrcG6wQMxajjHLWI9Rk)8vO9kDr3Rmu9kD4vLoVkrcW6zlq2mTgpO7XZfbcHRd3xH6R4)QHTGxv(Ros0vndzbvZLGfUeO7gag6czZW1PIcDQZ6XvtieUoCR8SAIt2ajtQMcEy6bkeWIb7xHYxPZQPGhMhvtS07ubpmpOD2EQMD2EOHSGQP4qDQOqNhz94QjecxhUvEwnXjBGKjvt9sYeUoqAe9a11GaUV68vORAk4H5r1el9ovWdZdANTNQzNThAilOA6AqazDQOqNhD94QjecxhUvEwnXjBGKjvZnmdlA3ezr3AY6vNVs3QPGhMhvtS07ubpmpOD2EQMD2EOHSGQPSOBnzvNkk0PoupUAcHW1HBLNvtbpmpQMyP3PcEyEq7S9un7S9qdzbvtS79Rxe76urHopI1JRMqiCD4w5z1eNSbsMun1ljt46aXYcPt5qY4vNVcDvtbpmpQMyP3PcEyEq7S9un7S9qdzbvZ0hzyEuNkk0zPVEC1ecHRd3kpRM4KnqYKQPEjzcxhiwwiDkhsgV68v6wnf8W8OAILENk4H5bTZ2t1SZ2dnKfunTSq6uoKmQtff60qxpUAcHW1HBLNvtbpmpQMyP3PcEyEq7S9un7S9qdzbvZLRhwqm1PovtTeW(ItM6XvuOB94QPGhMhvtjXsauwmqVd4PAcHW1HBLN1PIcDwpUAk4H5r1CJSwEqLelbqTYI1zswnHq46WTYZ6urXrwpUAk4H5r1e7XrDKeOljeAlSQMqiCD4w5zDQO4ORhxnHq46WTYZQPRvntydt1uWdZJQPEjzcxhQM6LKgYcQMYIU1Kv18cwbPpvZnmdlA3ezr3AYQovuOd1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvtqVt1Wt18cwbPpvtD1H6urXrSEC1ecHRd3kpRMUw1Cdt1uWdZJQPEjzcxhQM6LKgYcQMAjOH07uqVxnXjBGKjvt0EvIeG1ZwGSzAnEq3JNlcecxhUVI)Re8W0duiGfd2VcLVs3xXJxH2R09vLoVcTxPJVc76HqIHeao9UN3xH6Rq9vOwn1lDeGc9nunrx1uV0rGQPU1PIIsF94QjecxhUvEwnDTQ5gMQPGhMhvt9sYeUoun1ljnKfunBe9a11GaUvtCYgizs1eTxj4HPhOqalgSFfkFLoF1HdVsVKmHRdeTe0q6DkO3F15R09vho8k9sYeUoqKfDRjRxD(kDFfQvt9shbOqFdvt0vn1lDeOAQBDQOWqxpUAcHW1HBLNvtxRAUHPAk4H5r1uVKmHRdvt9shbQMORAQxsAilOAAzH0PCizuNkkkT1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvZCtxcV0l0LYOwpPJpRQ5fScsFQM6qDQOqx0vpUAcHW1HBLNvtxRAMWgMQPGhMhvt9sYeUoun1ljnKfunZnDj8sVqxkJA9KMUw18cwbPpvtDOovuORU1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvZCtxcV0l0LYOwpPIw18cwbPpvtDIU6urHU6SEC1ecHRd3kpRMUw1mHnmvtbpmpQM6LKjCDOAQxsAilOAkA0LWl9cDPmQ1t64ZQAEbRG0NQPUORovuO7rwpUAcHW1HBLNvtxRAMWgMQPGhMhvt9sYeUoun1ljnKfuntxJUeEPxOlLrTEshFwvZlyfK(un1j6Qtff6E01JRMqiCD4w5z101QMByQMcEyEun1ljt46q1uVK0qwq1C8zrxcV0l0LYOwpPIw1eNSbsMunr7vyxpesmKG12muRaV6WHxH2RWECrydrsSeavl9lRTmcecxhUVI)Re8W0duiGfd2VQ8xDKVc1xHA1uV0rak03q1uhQM6Locun1vhQtff6Qd1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvZXNfDj8sVqxkJA9KMUw18cwbPpvtDIU6urHUhX6XvtieUoCR8SA6AvZnmvtbpmpQM6LKjCDOAQx6iq1eTxH2Rm0O7vgQEfAVsNO7vLoVc76HqIHeS2MHAf4vO(kuFLHQxH2RwYEGSmQEPJaVQ05v6Io09kuFfQvt9ssdzbvtojtPfOljeQgEQtff6w6RhxnHq46WTYZQPRvntydt1uWdZJQPEjzcxhQM6LKgYcQMIgDXc2czrxsiun8unVGvq6t1uxDOovuORHUEC1ecHRd3kpRMUw1mHnmvtbpmpQM6LKjCDOAQxsAilOAo(SOlHxkUrYwyxnVGvq6t1uN1PIcDlT1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvtXb64ZIUeEP4gjBHD18cwbPpvtDwNkk0j6QhxnHq46WTYZQPRvn3Wunf8W8OAQxsMW1HQPEPJavtDFvPZRq7vJ0Hyijsau3s18cijqiCD4(k(VcTxnshIHijwcGc4gNaHW1H7RoC4v64RWUEiKyigvwYK4vO(k(VcTxPJVc76HqIHeao9UN3xD4WRe8W0duiGfd2V68v6(QdhEvIeG1ZwGSzAnEq3JNlcecxhUVc1xHA1uVK0qwq1Kf6HCGl11GaY6urHo1TEC1ecHRd3kpRMUw1Cdt1uWdZJQPEjzcxhQM6LocunHJacttdUKLGfUeO7gag6czZWV6WHxbhbeMMgCjTD5YKXZnLtUTWRoC4vWraHPPbxsBxUmz8CtxWv6DMhV6WHxbhbeMMgCjxjnA5EqVa2iQgYKWgdbgE1HdVcocimnn4syXgNiJW1b6rarIbzrVGEggE1HdVcocimnn4s2osVdZWIwAIWv2RoC4vWraHPPbxYgj46UFPYcMMY2ZRoC4vWraHPPbxsHyeeqUP20J7RoC4vWraHPPbxITllG6wkNmthQM6LKgYcQMIg1dkYgQtff6uN1JRMqiCD4w5z101QMjSHPAk4H5r1uVKmHRdvt9ssdzbvtXb64ZIUeEP4gjBHD18cwbPpvtDwNkk05rwpUAcHW1HBLNvtxRAMWgMQPGhMhvt9sYeUoun1ljnKfunb9ovdpvZlyfK(un1vhQtff68ORhxnf8W8OAUyz6jLTKwOAcHW1HBLN1PIcDQd1JRMqiCD4w5z1eNSbsMun1XxPxsMW1bIwcAi9of07V68v6(k(VkrcW6zlqUSnMP1zHKLrX(AjXLaHW1HB1uWdZJQPn99W59PovuOZJy94QjecxhUvEwnXjBGKjvtD8v6LKjCDGOLGgsVtb9(RoFLUVI)R0XxLiby9Sfix2gZ06SqYYOyFTK4sGq46WTAk4H5r1usSeaLRl7PovuOZsF94QjecxhUvEwnXjBGKjvt9sYeUoq0sqdP3PGE)vNVs3QPGhMhvtqVJLH5rDQt1e7E)6fXUECff6wpUAcHW1HBLNvtbpmpQM203dnC9s18cBCY0gMhvZJAtMNSHzOeEfYMfTVQnz7EzVIHz4o8Qc208krJ8QsZn8k28Qc208QXN1R8PbYc2givtCYgizs1mrcW6zlqAt2UxgLHz4oqGq46W9v8Ff29(1lcIKyjaQMxajjHLWI9Rq5Ros09k(Vc7E)6fbzCeCd1T0PbOlPLrsyjSy)QZxHUxX)vO9koeRLijwcGIBKSfi7rWg9QYpFLEjzcxhiJpl6s4LIBKSf2VI)Rq7vO9Qr6qmKejaQBPAEbKeieUoCFf)xHDVF9IGKibqDlvZlGKKWsyX(vLF(Qw89v8Ff29(1lcIKyjaQMxajjHLWI9Rq5R0ljt46az8zrxcV0l0LYOwpPI2Rq9vho8k0ELo(Qr6qmKejaQBPAEbKeieUoCFf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQO9kuF1HdVc7E)6fbrsSeavZlGKKWsyX(vLF(Qw89vO(kuRtff6SEC1ecHRd3kpRM4KnqYKQzIeG1ZwG0MSDVmkdZWDGaHW1H7R4)kS79RxeejXsaunVassclHf7xD(k09k(VcTxPJVAKoedbIoRTzGaUeieUoCF1HdVcTxnshIHarN12mqaxcecxhUVI)Rwsien88kuE(Qsp6EfQVc1xX)vO9k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vO8v6IUxX)vCiwlrsSeaf3izlq2JGn6vNVIdXAjsILaO4gjBbYs4LUhbB0Rq9vho8k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vNVcDVI)R4qSwIKyjakUrYwGShbB0RoFf6EfQVc1xX)vCiwljrcG6wQMxaj56fXR4)QLecrdpVcLNVsVKmHRderJUybBHSOljeQgEQMcEyEunTPVhA46L6urXrwpUAcHW1HBLNvtCYgizs1mrcW6zlqUSnMP1zHKLrX(AjXLaHW1H7R4)kS79RxeeoeRLEzBmtRZcjlJI91sIljb5w2R4)koeRLCzBmtRZcjlJI91sIl1M(EixViEf)xH2R4qSwIKyjaQMxaj56fXR4)koeRLKibqDlvZlGKC9I4v8F1f4qSwY4i4gQBPtdqxslJC9I4vO(k(Vc7E)6fbzCeCd1T0PbOlPLrsyjSy)QZxHUxX)vO9koeRLijwcGIBKSfi7rWg9QYpFLEjzcxhiJpl6s4LIBKSf2VI)Rq7vO9Qr6qmKejaQBPAEbKeieUoCFf)xHDVF9IGKibqDlvZlGKKWsyX(vLF(Qw89v8Ff29(1lcIKyjaQMxajjHLWI9Rq5R0ljt46az8zrxcV0l0LYOwpPI2Rq9vho8k0ELo(Qr6qmKejaQBPAEbKeieUoCFf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQO9kuF1HdVc7E)6fbrsSeavZlGKKWsyX(vLF(Qw89vO(kuRMcEyEunTPVhoVp1PIIJUEC1ecHRd3kpRM4KnqYKQzIeG1ZwGCzBmtRZcjlJI91sIlbcHRd3xX)vy37xViiCiwl9Y2yMwNfswgf7RLexscYTSxX)vCiwl5Y2yMwNfswgf7RLexQLLa56fXR4)kTe0tBXxIUeB67HZ7t1uWdZJQPLLaLRl7PovuOd1JRMqiCD4w5z1uWdZJQ5ILPNBQBPJNliMQ5f24KPnmpQMhv9cPS9Rq2WRwSm9C)Qc208krJ8Qsd7RgFwVITFvcYTSxj7xva9EjVAjgbVAJKWRg)vyzpVInVIdSEcVA8zrQM4KnqYKQj29(1lcY4i4gQBPtdqxslJKWsyX(vNVcDVI)R4qSwIKyjakUrYwGShbB0Rk)8v6LKjCDGm(SOlHxkUrYwy)k(Vc7E)6fbrsSeavZlGKKWsyX(vLF(Qw8TovuCeRhxnHq46WTYZQjozdKmPAIDVF9IGijwcGQ5fqssyjSy)QZxHUxX)vO9kD8vJ0Hyiq0zTndeWLaHW1H7RoC4vO9Qr6qmei6S2Mbc4sGq46W9v8F1scHOHNxHYZxv6r3Rq9vO(k(VcTxH2RWU3VErqghb3qDlDAa6sAzKewcl2VcLVsVKmHRderJUeEPxOlLrTEshFwVI)R4qSwIKyjakUrYwGShbB0RoFfhI1sKelbqXns2cKLWlDpc2OxH6RoC4vO9kS79RxeKXrWnu3sNgGUKwgjHLWI9RoFf6Ef)xXHyTejXsauCJKTazpc2OxD(k09kuFfQVI)R4qSwsIea1TunVasY1lIxX)vljeIgEEfkpFLEjzcxhiIgDXc2czrxsiun8unf8W8OAUyz65M6w645cIPovuu6RhxnHq46WTYZQPGhMhvZlitdNNbunVWgNmTH5r18OQxiLTFfYgE1fKPHZZaEvbBAELOrEvPH9vJpRxX2Vkb5w2RK9RkGEVKxTeJGxTrs4vJ)kSSNxXMxXbwpHxn(SivtCYgizs1e7E)6fbzCeCd1T0PbOlPLrsyjSy)QZxHUxX)vCiwlrsSeaf3izlq2JGn6vLF(k9sYeUoqgFw0LWlf3izlSFf)xHDVF9IGijwcGQ5fqssyjSy)QYpFvl(wNkkm01JRMqiCD4w5z1eNSbsMunXU3VErqKelbq18cijjSewSF15Rq3R4)k0ELo(Qr6qmei6S2Mbc4sGq46W9vho8k0E1iDigceDwBZabCjqiCD4(k(VAjHq0WZRq55Rk9O7vO(kuFf)xH2Rq7vy37xViiJJGBOULonaDjTmsclHf7xHYxPl6Ef)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrVc1xD4WRq7vy37xViiJJGBOULonaDjTmsclHf7xD(k09k(VIdXAjsILaO4gjBbYEeSrV68vO7vO(kuFf)xXHyTKejaQBPAEbKKRxeVI)Rwsien88kuE(k9sYeUoqen6IfSfYIUKqOA4PAk4H5r18cY0W5za1PIIsB94QjecxhUvEwnf8W8OAMYLjXq3AsAu18cBCY0gMhvZsZn8QTMKg9kM9vJpRxjX9vI2RKeELhVcFFLe3xv4HbZR4GxHO9kRNVQ7rlKVAAK4vtd8QLW7RUqxkRKxTeJyr7R2ij8Qc4vnIE4vY8Qoi75vtH)kjXsaVc3izlSFLe3xnnY8QXN1RkKDyW8QJ6i75viB4sQM4KnqYKQj29(1lcY4i4gQBPtdqxslJKWsyX(vO8v6LKjCDGKB6s4LEHUug16jD8z9k(Vc7E)6fbrsSeavZlGKKWsyX(vO8v6LKjCDGKB6s4LEHUug16jv0Ef)xH2RgPdXqsKaOULQ5fqsGq46W9v8FfAVc7E)6fbjrcG6wQMxajjHLWI9Rk)vaVagza6WwWRoC4vy37xViijsau3s18cijjSewSFfkFLEjzcxhi5MUeEPxOlLrTEstx7vO(QdhELo(Qr6qmKejaQBPAEbKeieUoCFfQVI)R4qSwIKyjakUrYwGShbB0Rq5R05R4)QlWHyTKXrWnu3sNgGUKwg56fXR4)koeRLKibqDlvZlGKC9I4v8FfhI1sKelbq18cijxViQtff6IU6XvtieUoCR8SAk4H5r1mLltIHU1K0OQ5f24KPnmpQMLMB4vBnjn6vfSP5vI2RkAG4vA(EZ46a5vLg2xn(SEfB)QeKBzVs2VQa69sE1smcE1gjHxn(RWYEEfBEfhy9eE14ZIunXjBGKjvtS79RxeKXrWnu3sNgGUKwgjHLWI9Rk)vaVagza6WwWR4)koeRLijwcGIBKSfi7rWg9QYpFLEjzcxhiJpl6s4LIBKSf2VI)RWU3VErqKelbq18cijjSewSFv5VcTxb8cyKbOdBbVIhVsWdZdY4i4gQBPtdqxslJa8cyKbOdBbVc16urHU6wpUAcHW1HBLNvtCYgizs1e7E)6fbrsSeavZlGKKWsyX(vL)kGxaJmaDyl4v8FfAVcTxPJVAKoedbIoRTzGaUeieUoCF1HdVcTxnshIHarN12mqaxcecxhUVI)Rwsien88kuE(Qsp6EfQVc1xX)vO9k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vO8v6LKjCDGiA0LWl9cDPmQ1t64Z6v8FfhI1sKelbqXns2cK9iyJE15R4qSwIKyjakUrYwGSeEP7rWg9kuF1HdVcTxHDVF9IGmocUH6w60a0L0YijSewSF15Rq3R4)koeRLijwcGIBKSfi7rWg9QZxHUxH6Rq9v8FfhI1ssKaOULQ5fqsUEr8k(VAjHq0WZRq55R0ljt46ar0OlwWwil6scHQHNxHA1uWdZJQzkxMedDRjPr1PIcD1z94QjecxhUvEwnf8W8OAoocUH6w60a0L0YQMxyJtM2W8OAwAUHxn(SEvbBAELO9kM9vSXG9RkytdlE10aVAj8(Ql0LYiVQ0W(QWNsEfYgEvbBAEv6AVIzF10aVAKoeZRy7xnIrquYRK4(k2yW(vfSPHfVAAGxTeEF1f6szKQjozdKmPAYHyTejXsauCJKTazpc2Oxv(5R0ljt46az8zrxcVuCJKTW(v8Ff29(1lcIKyjaQMxajjHLWI9Rk)8vaVagza6WwWR4)QLecrdpVcLVsVKmHRderJUybBHSOljeQgEEf)xXHyTKejaQBPAEbKKRxe1PIcDpY6XvtieUoCR8SAIt2ajtQMCiwlrsSeaf3izlq2JGn6vLF(k9sYeUoqgFw0LWlf3izlSFf)xnshIHKibqDlvZlGKaHW1H7R4)kS79RxeKejaQBPAEbKKewcl2VQ8Zxb8cyKbOdBbVI)RWU3VErqKelbq18cijjSewSFfkFLEjzcxhiJpl6s4LEHUug16jv0Ef)xHDVF9IGijwcGQ5fqssyjSy)ku(kD1z1uWdZJQ54i4gQBPtdqxslRovuO7rxpUAcHW1HBLNvtCYgizs1KdXAjsILaO4gjBbYEeSrVQ8ZxPxsMW1bY4ZIUeEP4gjBH9R4)k0ELo(Qr6qmKejaQBPAEbKeieUoCF1HdVc7E)6fbjrcG6wQMxajjHLWI9Rq5R0ljt46az8zrxcV0l0LYOwpPPR9kuFf)xHDVF9IGijwcGQ5fqssyjSy)ku(k9sYeUoqgFw0LWl9cDPmQ1tQOvnf8W8OAoocUH6w60a0L0YQtff6Qd1JRMqiCD4w5z1uWdZJQPKyjaQMxaz18cBCY0gMhvZsZn8kr7vm7RgFwVITFLhVcFFLe3xv4HbZR4GxHO9kRNVQ7rlKVAAK4vtd8QLW7RUqxkRKxTeJyr7R2ij8QPrMxvaVQr0dVcchPT5vljKxjX9vtJmVAAGeEfB)QWNxj9eKBzVsEvIeWRC7R08ciF11lcs1eNSbsMunXU3VErqghb3qDlDAa6sAzKewcl2VcLVsVKmHRderJUeEPxOlLrTEshFwVI)R4qSwIKyjakUrYwGShbB0RoFfhI1sKelbqXns2cKLWlDpc2OxX)vCiwljrcG6wQMxaj56fXR4)QLecrdpVcLNVsVKmHRderJUybBHSOljeQgEQtff6EeRhxnHq46WTYZQPGhMhvZejaQBPAEbKvZlSXjtByEunln3WRsx7vm7RgFwVITFLhVcFFLe3xv4HbZR4GxHO9kRNVQ7rlKVAAK4vtd8QLW7RUqxkRKxTeJyr7R2ij8QPbs4vSDyW8kPNGCl7vYRsKaE11lIxjX9vtJmVs0EvHhgmVIdW(cELOxyDHRdV6IKSO9vjsaKQjozdKmPAYHyTejXsaunVasY1lIxX)vO9kS79RxeKXrWnu3sNgGUKwgjHLWI9Rq5R0ljt46ajDn6s4LEHUug16jD8z9QdhEf29(1lcIKyjaQMxajjHLWI9Rk)8v6LKjCDGm(SOlHx6f6szuRNur7vO(k(VIdXAjsILaO4gjBbYEeSrV68vCiwlrsSeaf3izlqwcV09iyJEf)xHDVF9IGijwcGQ5fqssyjSy)ku(kD1zDQOq3sF94QjecxhUvEwnXjBGKjvtoeRLijwcGQ5fqsUEr8k(Vc7E)6fbrsSeavZlGKmjcqtyjSy)ku(kbpmpi7gMDyrlvZlGKGV5R4)koeRLKibqDlvZlGKC9I4v8Ff29(1lcsIea1TunVasYKianHLWI9Rq5Re8W8GSBy2HfTunVasc(MVI)RUahI1sghb3qDlDAa6sAzKRxevtbpmpQM7gMDyrlvZlGSovuORHUEC1ecHRd3kpRMcEyEun1sydbgOULUyXTAEHnozAdZJQzP5gELMVE14VAFeqaWqj8kjEfW7KYReUxXIxnnWRcG35vy37xViEvblUErjVcj6WE)kJklzs8QPbIx5rVSxDrsw0(kjXsaVsZlG8vxe4vJ)QgV4vljKx1GeTzzVkLltI5vBnjn6vSD1eNSbsMunhPdXqsKaOULQ5fqsGq46W9v8FfhI1sKelbq18cijiAVI)R4qSwsIea1TunVassclHf7xv(RAXxYs4TovuOBPTEC1ecHRd3kpRM4KnqYKQ5f4qSwY4i4gQBPtdqxslJGO9k(V6cCiwlzCeCd1T0PbOlPLrsyjSy)QYFLGhMhejXsa0fBVzDytaEbmYa0HTGxX)v64RWUEiKyigvwYKOAk4H5r1ulHneyG6w6If36urHorx94QjecxhUvEwnXjBGKjvtoeRLKibqDlvZlGKGO9k(VIdXAjjsau3s18cijjSewSFv5VQfFjlH3xX)vy37xViiGEhldZdscYTSxX)vy37xViiJJGBOULonaDjTmsclHf7xX)v64RWUEiKyigvwYKOAk4H5r1ulHneyG6w6If36uNQPSOBnzvpUIcDRhxnHq46WTYZQPGhMhvtqVJLH5r18cBCY0gMhvtbpmp2ezr3AY6elbg6ubpmpkHzpf8W8Ga6DSmmpi4gjcOZIw(ljeIgEq5zPvhQM4KnqYKQ5scHOHNxv(5R0ljt46ab07un88k(VcTxHDVF9IGmocUH6w60a0L0YijSewSFv5NVsWdZdcO3XYW8Ga8cyKbOdBbV6WHxHDVF9IGijwcGQ5fqssyjSy)QYpFLGhMheqVJLH5bb4fWidqh2cE1HdVcTxnshIHKibqDlvZlGKaHW1H7R4)kS79RxeKejaQBPAEbKKewcl2VQ8Zxj4H5bb07yzyEqaEbmYa0HTGxH6Rq9v8FfhI1ssKaOULQ5fqsUEr8k(VIdXAjsILaOAEbKKRxeVI)RUahI1sghb3qDlDAa6sAzKRxe1PIcDwpUAcHW1HBLNvtCYgizs1e7E)6fbrsSeavZlGKKWsyX(vNVcDVI)Rq7vCiwljrcG6wQMxaj56fXR4)k0Ef29(1lcY4i4gQBPtdqxslJKWsyX(vO8v6LKjCDGiA0LWl9cDPmQ1t64Z6vho8kS79RxeKXrWnu3sNgGUKwgjHLWI9RoFf6EfQVc1QPGhMhvZlitdNNbuNkkoY6XvtieUoCR8SAIt2ajtQMy37xViisILaOAEbKKewcl2V68vO7v8FfAVIdXAjjsau3s18cijxViEf)xH2RWU3VErqghb3qDlDAa6sAzKewcl2VcLVsVKmHRderJUeEPxOlLrTEshFwV6WHxHDVF9IGmocUH6w60a0L0YijSewSF15Rq3Rq9vOwnf8W8OAUyz65M6w645cIPovuC01JRMcEyEunt5YKyOBnjnQAcHW1HBLN1PIcDOEC1ecHRd3kpRM4KnqYKQjhI1sKelbq18cijxViEf)xHDVF9IGijwcGQ5fqsMebOjSewSFfkFLGhMhKDdZoSOLQ5fqsW38v8FfhI1ssKaOULQ5fqsUEr8k(Vc7E)6fbjrcG6wQMxajzseGMWsyX(vO8vcEyEq2nm7WIwQMxajbFZxX)vxGdXAjJJGBOULonaDjTmY1lIQPGhMhvZDdZoSOLQ5fqwNkkoI1JRMqiCD4w5z1eNSbsMun5qSwsIea1TunVasY1lIxX)vy37xViisILaOAEbKKewcl2vtbpmpQMjsau3s18ciRtffL(6XvtieUoCR8SAIt2ajtQMO9kS79RxeejXsaunVassclHf7xD(k09k(VIdXAjjsau3s18cijxViEfQV6WHxPLGEAl(s0LKibqDlvZlGSAk4H5r1CCeCd1T0PbOlPLvNkkm01JRMqiCD4w5z1eNSbsMunXU3VErqKelbq18cijjSewSFv5Vshq3R4)koeRLKibqDlvZlGKC9I4v8FfS3qGbIE2M5b1TuniTaEyEqGq46WTAk4H5r1CCeCd1T0PbOlPLvNkkkT1JRMqiCD4w5z1eNSbsMun5qSwsIea1TunVasY1lIxX)vy37xViiJJGBOULonaDjTmsclHf7xHYxPxsMW1bIOrxcV0l0LYOwpPJpRQPGhMhvtjXsaunVaY6urHUOREC1ecHRd3kpRM4KnqYKQjhI1sKelbq18cijiAVI)R4qSwIKyjaQMxajjHLWI9Rk)8vcEyEqKelbqxS9M1Hnb4fWidqh2cEf)xXHyTejXsauCJKTazpc2OxD(koeRLijwcGIBKSfilHx6EeSrvtbpmpQMsILaOCsMsluNkk0v36XvtieUoCR8SAIt2ajtQMCiwlrsSeaf3izlq2JGn6vL)koeRLijwcGIBKSfilHx6EeSrVI)R4qSwsIea1TunVasY1lIxX)vCiwlrsSeavZlGKC9I4v8F1f4qSwY4i4gQBPtdqxslJC9IOAk4H5r1usSea1tU6urHU6SEC1ecHRd3kpRM4KnqYKQjhI1ssKaOULQ5fqsUEr8k(VIdXAjsILaOAEbKKRxeVI)RUahI1sghb3qDlDAa6sAzKRxeVI)R4qSwIKyjakUrYwGShbB0RoFfhI1sKelbqXns2cKLWlDpc2OQPGhMhvtjXsauojtPfQtff6EK1JRMqiCD4w5z1e3iSOAQB1eKSxgf3iSGYSvtoeRLG7GKyzpSOLIBKiGo56fbF04qSwIKyjaQMxajbr7WboeRLKibqDlvZlGKGOD4a29(1lccO3XYW8GKGCld1QjozdKmPAYHyTeChKel7HfTKee8unf8W8OAkjwcGUy7nRd76urHUhD94QjecxhUvEwnXnclQM6wnbj7LrXnclOmB1KdXAj4oijw2dlAP4gjcOtUErWhnoeRLijwcGQ5fqsq0oCGdXAjjsau3s18cijiAhoGDVF9IGa6DSmmpiji3YqTAIt2ajtQM64RedLqYgGijwcGQHSwqNfTeieUoCF1HdVIdXAj4oijw2dlAP4gjcOtUErunf8W8OAkjwcGUy7nRd76urHU6q94QjecxhUvEwnXjBGKjvtoeRLKibqDlvZlGKC9I4v8FfhI1sKelbq18cijxViEf)xDboeRLmocUH6w60a0L0YixViQMcEyEunb9owgMh1PIcDpI1JRMqiCD4w5z1eNSbsMun5qSwIKyjakUrYwGShbB0Rk)vCiwlrsSeaf3izlqwcV09iyJQMcEyEunLelbq9KRovuOBPVEC1uWdZJQPKyjakNKP0cvtieUoCR8SovuORHUEC1uWdZJQPKyjakxx2t1ecHRd3kpRtDQMlxpSGyQhxrHU1JRMqiCD4w5z1eNSbsMunxUEybXqUS9ibgEfkpFLUORAk4H5r1KRZcJQtff6SEC1uWdZJQPwcBiWa1T0flUvtieUoCR8SovuCK1JRMqiCD4w5z1eNSbsMunxUEybXqUS9ibgEv5Vsx0vnf8W8OAkjwcGUy7nRd76urXrxpUAk4H5r1usSea1tUQjecxhUvEwNkk0H6XvtbpmpQMwwcuUUSNQjecxhUvEwN6unTSq6uoKmQhxrHU1JRMqiCD4w5z1uWdZJQPKyja6IT3SoSRM4gHfvtDRM4KnqYKQjhI1sWDqsSShw0ssqWtDQOqN1JRMcEyEunLelbq56YEQMqiCD4w5zDQO4iRhxnf8W8OAkjwcGYjzkTq1ecHRd3kpRtDQt1upKBMhvuOt0PtDrNU68ORMfsgSODxnlDFuzOgfLgOO0LH8QxDCd8k2sZZ5vwpFLbUgeqAWRs4iGWs4(QTVGxjiJVKbUVc3irlSjVXgglGxPRH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMU8Ik5n2Wyb8kDnKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRqtN8Ik5n2Wyb8kDAiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8QJ0qELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4vhTH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdELmVYqrdfmSxHMU8Ik5n2Wyb8kDrNH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6KxujVXgglGxPBP3qELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtxErL8gBySaELorNH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6YlQK3ydJfWR0j6mKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRK5vgkAOGH9k00LxujVXgglGxPtDAiVYW9qpKdCFLbJ0HyiLYGxn(RmyKoedPueieUoCn4vOPlVOsEJFJlDFuzOgfLgOO0LH8QxDCd8k2sZZ5vwpFLbPpYW8WGxLWraHLW9vBFbVsqgFjdCFfUrIwytEJnmwaVsxd5vgUh6HCG7RmyKoedPug8QXFLbJ0HyiLIaHW1HRbVcnD5fvYBSHXc4v60qELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4vhTH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMU8Ik5n2Wyb8kDWqELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtxErL8gBySaEvP1qELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtxErL8gBySaELULwd5vgUh6HCG7RmyKoedPug8QXFLbJ0HyiLIaHW1HRbVcnD5fvYBSHXc4v68inKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRqtxErL8gBySaELopAd5vgUh6HCG7RmircW6zlqkLbVA8xzqIeG1ZwGukcecxhUg8k00LxujVXVXLUpQmuJIsduu6YqE1RoUbEfBP558kRNVYGlyfK(yWRs4iGWs4(QTVGxjiJVKbUVc3irlSjVXgglGxPtd5vgUh6HCG7RmircW6zlqkLbVA8xzqIeG1ZwGukcecxhUg8k00jVOsEJnmwaV6inKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRqtN8Ik5n2Wyb8QJ2qELH7HEih4(kt2YWF1USyeEF1rnE14VYWqKxDz6zBMhVY1GugpFfAOh1xHMU8Ik5n2Wyb8kDWqELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtN8Ik5n2Wyb8QsVH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6YlQK3ydJfWR0T0BiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8kDn0gYRmCp0d5a3xzqIeG1ZwGukdE14VYGejaRNTaPueieUoCn4vOPlVOsEJnmwaVs3sRH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6YlQK3ydJfWR0PUgYRmCp0d5a3xzqIeG1ZwGukdE14VYGejaRNTaPueieUoCn4vOPlVOsEJFJlDFuzOgfLgOO0LH8QxDCd8k2sZZ5vwpFLbAjG9fNmg8QeociSeUVA7l4vcY4lzG7RWns0cBYBSHXc4vhrd5vgUh6HCG7RmircW6zlqkLbVA8xzqIeG1ZwGukcecxhUg8k00LxujVXgglGxP7rBiVYW9qpKdCFLbypUiSHukdE14VYaShxe2qkfbcHRdxdEfA6YlQK3ydJfWR0j6mKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00jVOsEJnmwaVsNOZqELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4v6uhmKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRK5vgkAOGH9k00LxujVXgglGxPZJOH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdELmVYqrdfmSxHMU8Ik5n(nU09rLHAuuAGIsxgYRE1XnWRylnpNxz98vgGDVF9IyBWRs4iGWs4(QTVGxjiJVKbUVc3irlSjVXgglGxPRH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMo5fvYBSHXc4v6AiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8kDAiVYW9qpKdCFLbJ0HyiLYGxn(RmyKoedPueieUoCn4vOPtErL8gBySaELonKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRqtxErL8gBySaE1rAiVYW9qpKdCFLbJ0HyiLYGxn(RmyKoedPueieUoCn4vOPtErL8gBySaE1rAiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8QJ2qELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4vhrd5vgUh6HCG7RmyKoedPug8QXFLbJ0HyiLIaHW1HRbVcnDYlQK3ydJfWRm0gYRmCp0d5a3xzWiDigsPm4vJ)kdgPdXqkfbcHRdxdEfA6KxujVXgglGxvAnKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00jVOsEJnmwaVsxDnKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00jVOsEJnmwaVs3J0qELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtxErL8gBySaELUhTH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMU8Ik5n2Wyb8kDn0gYRmCp0d5a3xzWiDigsPm4vJ)kdgPdXqkfbcHRdxdEfA6YlQK3434s3hvgQrrPbkkDziV6vh3aVIT08CEL1ZxzG4GbVkHJaclH7R2(cELGm(sg4(kCJeTWM8gBySaELUgYRmCp0d5a3xzWiDigsPm4vJ)kdgPdXqkfbcHRdxdEfA6KxujVXgglGxPRH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6YlQK3ydJfWR0PH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6KxujVXgglGxDKgYRmCp0d5a3xzWiDigsPm4vJ)kdgPdXqkfbcHRdxdEfA6KxujVXgglGxDKgYRmCp0d5a3xzqIeG1ZwGukdE14VYGejaRNTaPueieUoCn4vOPlVOsEJnmwaV6OnKxz4EOhYbUVYGejaRNTaPug8QXFLbjsawpBbsPiqiCD4AWRqtxErL8gBySaELoyiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8QJOH8kd3d9qoW9vgKiby9SfiLYGxn(RmircW6zlqkfbcHRdxdEfA6YlQK3ydJfWRk9gYRmCp0d5a3xzqIeG1ZwGukdE14VYGejaRNTaPueieUoCn4vOPlVOsEJnmwaVYqBiVYW9qpKdCFLbjsawpBbsPm4vJ)kdsKaSE2cKsrGq46W1GxHMU8Ik5n2Wyb8QsRH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMo5fvYBSHXc4v6Iod5vgUh6HCG7RmyKoedPug8QXFLbJ0HyiLIaHW1HRbVcnDYlQK3ydJfWR09inKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00jVOsEJnmwaVs3JOH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxjZRmu0qbd7vOPlVOsEJnmwaVsxdTH8kd3d9qoW9vgmshIHukdE14VYGr6qmKsrGq46W1GxHMU8Ik5n2Wyb8kDn0gYRmCp0d5a3xzqIeG1ZwGukdE14VYGejaRNTaPueieUoCn4vOPlVOsEJnmwaVsNOZqELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4v68OnKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00LxujVXgglGxPZJ2qELH7HEih4(kdsKaSE2cKszWRg)vgKiby9SfiLIaHW1HRbVcnD5fvYBSHXc4v6uhmKxz4EOhYbUVYGr6qmKszWRg)vgmshIHukcecxhUg8k00jVOsEJnmwaVsNhrd5vgUh6HCG7RmyKoedPug8QXFLbJ0HyiLIaHW1HRbVcnD5fvYB8BCP7Jkd1OO0afLUmKx9QJBGxXwAEoVY65Rmqw0TMSm4vjCeqyjCF12xWReKXxYa3xHBKOf2K3ydJfWR01qELH7HEih4(kdgPdXqkLbVA8xzWiDigsPiqiCD4AWRqtxErL8g)gxAS08CG7RkTVsWdZJx1z7ztEJRMAPBzDOAEuokV6OMsl8QJQelb8gFuokVYyjqKSSxPZJUKxPt0PtDFJFJpkhLxzOgwUE4v6LKjCDGil6wtwVIfVYk698vU9vBygw0UjYIU1K1Rqd3ayJEvzos(QTgGFLRnmp2OsEJpkhLxvAUHxnLPXWs)vMSLH)QgjUDw0(k3(kCJeb0FflgiteTH5XRyXEa5(k3(kdWsGHovWdZddiVXVXcEyESjAjG9fNm84e9sILaOSyGEhWZBSGhMhBIwcyFXjdporVKyjaQvwSotY3ybpmp2eTeW(ItgECIEShh1rsGUKqOTW6nwWdZJnrlbSV4KHhNOxVKmHRdLeYcoLfDRjRsCTZe2WuYfScsFo3WmSODtKfDRjR3ybpmp2eTeW(ItgECIE9sYeUousil4e07un8uIRDMWgMsUGvq6ZPU6WBSGhMhBIwcyFXjdporVEjzcxhkjKfCQLGgsVtb9EjU25gMsy2t0sKaSE2cKntRXd6E8CXxWdtpqHawmyJsD5bA6w6GMoID9qiXqcaNE3ZlQOIAj6LocCQBj6LocqH(gor3BSGhMhBIwcyFXjdporVEjzcxhkjKfC2i6bQRbbClX1o3WucZEIMGhMEGcbSyWgL68Wb9sYeUoq0sqdP3PGE)u3dh0ljt46arw0TMSo1f1s0lDe4u3s0lDeGc9nCIU3ybpmp2eTeW(ItgECIE9sYeUousil40YcPt5qYOex7Cdtj6LocCIU3ybpmp2eTeW(ItgECIE9sYeUousil4m30LWl9cDPmQ1t64ZQex7mHnmLCbRG0NtD4nwWdZJnrlbSV4KHhNOxVKmHRdLeYcoZnDj8sVqxkJA9KMUwjU2zcByk5cwbPpN6WBSGhMhBIwcyFXjdporVEjzcxhkjKfCMB6s4LEHUug16jv0kX1otydtjxWki95uNO7nwWdZJnrlbSV4KHhNOxVKmHRdLeYcofn6s4LEHUug16jD8zvIRDMWgMsUGvq6ZPUO7nwWdZJnrlbSV4KHhNOxVKmHRdLeYcotxJUeEPxOlLrTEshFwL4ANjSHPKlyfK(CQt09gl4H5XMOLa2xCYWJt0RxsMW1HsczbNJpl6s4LEHUug16jv0kX1o3WucZEIg21dHedjyTnd1kWHdOH94IWgIKyjaQw6xwBz8f8W0duiGfd2LFKOIAj6LocCQRouIEPJauOVHtD4nwWdZJnrlbSV4KHhNOxVKmHRdLeYcohFw0LWl9cDPmQ1tA6AL4ANjSHPKlyfK(CQt09gl4H5XMOLa2xCYWJt0RxsMW1HsczbNCsMslqxsiun8uIRDUHPe9shbordndn6muHMorxPd21dHedjyTnd1kaQOAOcTLShilJQx6iqPJUOdDOI6BSGhMhBIwcyFXjdporVEjzcxhkjKfCkA0flylKfDjHq1WtjU2zcByk5cwbPpN6QdVXcEyESjAjG9fNm84e96LKjCDOKqwW54ZIUeEP4gjBHDjU2zcByk5cwbPpN68nwWdZJnrlbSV4KHhNOxVKmHRdLeYcofhOJpl6s4LIBKSf2L4ANjSHPKlyfK(CQZ3ybpmp2eTeW(ItgECIE9sYeUousil4Kf6HCGl11GaYsCTZnmLOx6iWPULoOnshIHKibqDlvZlGKpAJ0HyisILaOaUXpCqhXUEiKyigvwYKav(OPJyxpesmKaWP398E4GGhMEGcbSyW(u3dhsKaSE2cKntRXd6E8CHkQVXcEyESjAjG9fNm84e96LKjCDOKqwWPOr9GISHsCTZnmLOx6iWjCeqyAAWLSeSWLaD3aWqxiBg(Wb4iGW00GlPTlxMmEUPCYTfoCaocimnn4sA7YLjJNB6cUsVZ84Wb4iGW00Gl5kPrl3d6fWgr1qMe2yiWWHdWraHPPbxcl24ezeUoqpcismil6f0ZWWHdWraHPPbxY2r6Dygw0steUYoCaocimnn4s2ibx39lvwW0u2EoCaocimnn4skeJGaYn1MECpCaocimnn4sSDzbu3s5Kz6WBSGhMhBIwcyFXjdporVEjzcxhkjKfCkoqhFw0LWlf3izlSlX1otydtjxWki95uNVXcEyESjAjG9fNm84e96LKjCDOKqwWjO3PA4Pex7mHnmLCbRG0NtD1H3ybpmp2eTeW(ItgECI(fltpPSL0cVXcEyESjAjG9fNm84e9203dN3Nsy2tDuVKmHRdeTe0q6DkO3p1LFIeG1ZwGCzBmtRZcjlJI91sI7BSGhMhBIwcyFXjdporVKyjakxx2tjm7PoQxsMW1bIwcAi9of07N6YxhtKaSE2cKlBJzADwizzuSVwsCFJf8W8yt0sa7loz4Xj6b9owgMhLWSN6LKjCDGOLGgsVtb9(PUVXVXcEyES5Xj6XosmqU1GE)nwWdZJnporVEjzcxhkjKfC2i6bQRbbClX1o3WuIEPJaN6wcZEQxsMW1bsJOhOUgeW9eD81sqpTfFj6sa9owgMh81r0sKaSE2cKntRXd6E8CD4qIeG1ZwGmWsZtPtlKud13ybpmp284e96LKjCDOKqwWzJOhOUgeWTex7Cdtj6LocCQBjm7PEjzcxhinIEG6Aqa3t0XNdXAjsILaOAEbKKRxe8XU3VErqKelbq18cijjSewS5JwIeG1ZwGSzAnEq3JNRdhsKaSE2cKbwAEkDAHKAO(gl4H5XMhNOxVKmHRdLeYcoTSq6uoKmkX1o3WuIEPJaN6wcZEYHyTejXsauCJKTazpc2OtoeRLijwcGIBKSfilHx6EeSr81roeRLKiDG6w60KaSjiA8TS2MHMWsyXU8t0qBjHCudbpmpisILaOCDzpeSVhulDe8W8GijwcGY1L9qaEbmYa0HTauFJf8W8yZJt0JSb6scH2cRsy2t0gPdXqGOZABgiGl)LecrdpLFAOrh)LecrdpO88iQdOE4aA64iDigceDwBZabC5VKqiA4P8tdToG6BSGhMhBECIEnFyEucZEYHyTejXsaunVascI2BSGhMhBECI(HTaAHKALWSNjsawpBbYalnpLoTqsn(Ciwlb4Trq2dZdcIgF0WU3VErqKelbq18cijji3YoCWYABgAclHf7YppA0H6BSGhMhBECI(oRTz20J6i32fetjm7jhI1sKelbq18cijxVi4ZHyTKejaQBPAEbKKRxe8VahI1sghb3qDlDAa6sAzKRxeVXcEyES5Xj65KwQBPtYWgTlHzp5qSwIKyjaQMxaj56fbFoeRLKibqDlvZlGKC9IG)f4qSwY4i4gQBPtdqxslJC9I4nwWdZJnporphKBinIfTLWSNCiwlrsSeavZlGKGO9gl4H5XMhNONR7(LArYYkHzp5qSwIKyjaQMxajbr7nwWdZJnporVLLax39Bjm7jhI1sKelbq18cijiAVXcEyES5Xj6Lad7jLofl9Ejm7jhI1sKelbq18cijiAVXcEyES5Xj6r2aLnWAxcZEYHyTejXsaunVascI2BSGhMhBECIEKnqzdSkbSwap0qwWzBxUmz8Ct5KBlucZEYHyTejXsaunVascI2Hdy37xViisILaOAEbKKewcl2O8uh0b(xGdXAjJJGBOULonaDjTmcI2BSGhMhBECIEKnqzdSkjKfCclTYsq6upVHeyOeM9e7E)6fbrsSeavZlGKKWsyXU8tDIU3ybpmp284e9iBGYgyvsil48MGCTSeO6H9g6LWSNy37xViisILaOAEbKKewcl2O8uNO7WbDuVKmHRderJ6bfzdN6E4aAdBbLRlF9sYeUoqyHEih4sDniG8ux(jsawpBbYMP14bDpEUq9nwWdZJnporpYgOSbwLeYco3osNYAd2azjm7j29(1lcIKyjaQMxajjHLWInkp1j6oCqh1ljt46ar0OEqr2WPUhoG2Wwq56YxVKmHRdewOhYbUuxdcip1LFIeG1ZwGSzAnEq3JNluFJf8W8yZJt0JSbkBGvjHSGZ2EzAnu3sL9MTyDzyEucZEIDVF9IGijwcGQ5fqssyjSyJYtDIUdh0r9sYeUoqenQhuKnCQ7HdOnSfuUU81ljt46aHf6HCGl11GaYtD5Niby9SfiBMwJh0945c13ybpmp284e9iBGYgyvsil4CjyHlb6UbGHUq2mCjm7j29(1lcIKyjaQMxajjHLWID5N6aF00r9sYeUoqyHEih4sDniG8u3dhg2cq5rIouFJf8W8yZJt0JSbkBGvjHSGZLGfUeO7gag6czZWLWSNy37xViisILaOAEbKKewcl2LFQd81ljt46aHf6HCGl11GaYtD5ZHyTKejaQBPAEbKeen(CiwljrcG6wQMxajjHLWID5NOPl6muPdLojsawpBbYMP14bDpEUqL)Wwq5hj6EJf8W8yZJt0JLENk4H5bTZ2tjHSGtXHsy2tbpm9afcyXGnk15BSGhMhBECIES07ubpmpOD2EkjKfC6Aqazjm7PEjzcxhinIEG6Aqa3t09gl4H5XMhNOhl9ovWdZdANTNsczbNYIU1Kvjm75gMHfTBISOBnzDQ7BSGhMhBECIES07ubpmpOD2EkjKfCIDVF9Iy)gl4H5XMhNOhl9ovWdZdANTNsczbNPpYW8OeM9uVKmHRdellKoLdjJt09gl4H5XMhNOhl9ovWdZdANTNsczbNwwiDkhsgLWSN6LKjCDGyzH0PCizCQ7BSGhMhBECIES07ubpmpOD2EkjKfCUC9WcI5n(n(O8kbpmp2ezr3AY6elbg6ubpmpkHzpf8W8Ga6DSmmpi4gjcOZIw(ljeIgEq5zPvhEJf8W8ytKfDRjlECIEqVJLH5rjm75scHOHNYp1ljt46ab07un8WhnS79RxeKXrWnu3sNgGUKwgjHLWID5NcEyEqa9owgMheGxaJmaDyl4WbS79RxeejXsaunVassclHf7Ypf8W8Ga6DSmmpiaVagza6WwWHdOnshIHKibqDlvZlGKp29(1lcsIea1TunVassclHf7Ypf8W8Ga6DSmmpiaVagza6WwaQOYNdXAjjsau3s18cijxVi4ZHyTejXsaunVasY1lc(xGdXAjJJGBOULonaDjTmY1lI3ybpmp2ezr3AYIhNO)cY0W5zaLWSNy37xViisILaOAEbKKewcl2NOJpACiwljrcG6wQMxaj56fbF0WU3VErqghb3qDlDAa6sAzKewcl2OuVKmHRderJUeEPxOlLrTEshFwhoGDVF9IGmocUH6w60a0L0YijSewSprhQO(gl4H5XMil6wtw84e9lwMEUPULoEUGykHzpXU3VErqKelbq18cijjSewSprhF04qSwsIea1TunVasY1lc(OHDVF9IGmocUH6w60a0L0YijSewSrPEjzcxhiIgDj8sVqxkJA9Ko(SoCa7E)6fbzCeCd1T0PbOlPLrsyjSyFIour9nwWdZJnrw0TMS4Xj6t5YKyOBnjn6nwWdZJnrw0TMS4Xj63nm7WIwQMxazjm7jhI1sKelbq18cijxVi4JDVF9IGijwcGQ5fqsMebOjSewSrPGhMhKDdZoSOLQ5fqsW3KphI1ssKaOULQ5fqsUErWh7E)6fbjrcG6wQMxajzseGMWsyXgLcEyEq2nm7WIwQMxajbFt(xGdXAjJJGBOULonaDjTmY1lI3ybpmp2ezr3AYIhNOprcG6wQMxazjm7jhI1ssKaOULQ5fqsUErWh7E)6fbrsSeavZlGKKWsyX(nwWdZJnrw0TMS4Xj6hhb3qDlDAa6sAzLWSNOHDVF9IGijwcGQ5fqssyjSyFIo(CiwljrcG6wQMxaj56fbQhoOLGEAl(s0LKibqDlvZlG8nwWdZJnrw0TMS4Xj6hhb3qDlDAa6sAzLWSNy37xViisILaOAEbKKewcl2LRdOJphI1ssKaOULQ5fqsUErWh2BiWarpBZ8G6wQgKwapmpiqiCD4(gl4H5XMil6wtw84e9sILaOAEbKLWSNCiwljrcG6wQMxaj56fbFS79RxeKXrWnu3sNgGUKwgjHLWInk1ljt46ar0OlHx6f6szuRN0XN1BSGhMhBISOBnzXJt0ljwcGYjzkTqjm7jhI1sKelbq18cijiA85qSwIKyjaQMxajjHLWID5NcEyEqKelbqxS9M1Hnb4fWidqh2c4ZHyTejXsauCJKTazpc2OtoeRLijwcGIBKSfilHx6EeSrVXcEyESjYIU1KfporVKyjaQNCLWSNCiwlrsSeaf3izlq2JGnQCoeRLijwcGIBKSfilHx6EeSr85qSwsIea1TunVasY1lc(CiwlrsSeavZlGKC9IG)f4qSwY4i4gQBPtdqxslJC9I4nwWdZJnrw0TMS4Xj6Lelbq5KmLwOeM9KdXAjjsau3s18cijxVi4ZHyTejXsaunVasY1lc(xGdXAjJJGBOULonaDjTmY1lc(CiwlrsSeaf3izlq2JGn6KdXAjsILaO4gjBbYs4LUhbB0BSGhMhBISOBnzXJt0ljwcGUy7nRd7sy2toeRLG7GKyzpSOLKGGNsWnclo1TeqYEzuCJWckZEYHyTeChKel7HfTuCJeb0jxVi4JghI1sKelbq18cijiAhoWHyTKejaQBPAEbKeeTdhWU3VErqa9owgMhKeKBzO(gl4H5XMil6wtw84e9sILaOl2EZ6WUeM9uhfdLqYgGijwcGQHSwqNfTeieUoCpCGdXAj4oijw2dlAP4gjcOtUErucUryXPULas2lJIBewqz2toeRLG7GKyzpSOLIBKiGo56fbF04qSwIKyjaQMxajbr7WboeRLKibqDlvZlGKGOD4a29(1lccO3XYW8GKGCld13ybpmp2ezr3AYIhNOh07yzyEucZEYHyTKejaQBPAEbKKRxe85qSwIKyjaQMxaj56fb)lWHyTKXrWnu3sNgGUKwg56fXBSGhMhBISOBnzXJt0ljwcG6jxjm7jhI1sKelbqXns2cK9iyJkNdXAjsILaO4gjBbYs4LUhbB0BSGhMhBISOBnzXJt0ljwcGYjzkTWBSGhMhBISOBnzXJt0ljwcGY1L98g)gl4H5XMioCAtFpCEFkHzptKaSE2cKlBJzADwizzuSVwsC5JDVF9IGWHyT0lBJzADwizzuSVwsCjji3Y4ZHyTKlBJzADwizzuSVwsCP203d56fbF04qSwIKyjaQMxaj56fbFoeRLKibqDlvZlGKC9IG)f4qSwY4i4gQBPtdqxslJC9Iav(y37xViiJJGBOULonaDjTmsclHf7t0XhnoeRLijwcGIBKSfi7rWgv(PEjzcxhiId0XNfDj8sXns2cB(OH2iDigsIea1TunVas(y37xViijsau3s18cijjSewSl)SfF5JDVF9IGijwcGQ5fqssyjSyJs9sYeUoqgFw0LWl9cDPmQ1tQOH6HdOPJJ0Hyijsau3s18ci5JDVF9IGijwcGQ5fqssyjSyJs9sYeUoqgFw0LWl9cDPmQ1tQOH6Hdy37xViisILaOAEbKKewcl2LF2IVOI6BSGhMhBI4aporVLLaLRl7PeM9eTejaRNTa5Y2yMwNfswgf7RLex(y37xViiCiwl9Y2yMwNfswgf7RLexscYTm(Ciwl5Y2yMwNfswgf7RLexQLLa56fbFTe0tBXxIUeB67HZ7dQhoGwIeG1ZwGCzBmtRZcjlJI91sIl)HTGY1f13ybpmp2eXbECIEB67HgUEPeM9mrcW6zlqAt2UxgLHz4oWh7E)6fbrsSeavZlGKKWsyXgLhj64JDVF9IGmocUH6w60a0L0YijSewSprhF04qSwIKyjakUrYwGShbBu5N6LKjCDGioqhFw0LWlf3izlS5JgAJ0Hyijsau3s18ci5JDVF9IGKibqDlvZlGKKWsyXU8Zw8Lp29(1lcIKyjaQMxajjHLWInk1ljt46az8zrxcV0l0LYOwpPIgQhoGMooshIHKibqDlvZlGKp29(1lcIKyjaQMxajjHLWInk1ljt46az8zrxcV0l0LYOwpPIgQhoGDVF9IGijwcGQ5fqssyjSyx(zl(IkQVXcEyESjId84e9203dnC9sjm7zIeG1ZwG0MSDVmkdZWDGp29(1lcIKyjaQMxajjHLWI9j64JgAOHDVF9IGmocUH6w60a0L0YijSewSrPEjzcxhiIgDj8sVqxkJA9Ko(S4ZHyTejXsauCJKTazpc2OtoeRLijwcGIBKSfilHx6EeSrOE4aAy37xViiJJGBOULonaDjTmsclHf7t0XNdXAjsILaO4gjBbYEeSrLFQxsMW1bI4aD8zrxcVuCJKTWgvu5ZHyTKejaQBPAEbKKRxeO(gl4H5XMioWJt0pocUH6w60a0L0YkHzptKaSE2cKntRXd6E8CXxlb90w8LOlb07yzyE8gl4H5XMioWJt0ljwcGQ5fqwcZEMiby9SfiBMwJh0945IpAAjON2IVeDjGEhldZJdh0sqpTfFj6sghb3qDlDAa6sAzO(gl4H5XMioWJt0d6DSmmpkHzph2cq5rIo(jsawpBbYMP14bDpEU4ZHyTejXsauCJKTazpc2OYp1ljt46arCGo(SOlHxkUrYwyZh7E)6fbzCeCd1T0PbOlPLrsyjSyFIo(y37xViisILaOAEbKKewcl2LF2IVVXcEyESjId84e9GEhldZJsy2ZHTauEKOJFIeG1ZwGSzAnEq3JNl(y37xViisILaOAEbKKewcl2NOJpAOHg29(1lcY4i4gQBPtdqxslJKWsyXgL6LKjCDGiA0LWl9cDPmQ1t64ZIphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgH6HdOHDVF9IGmocUH6w60a0L0YijSewSprhFoeRLijwcGIBKSfi7rWgv(PEjzcxhiId0XNfDj8sXns2cBurLphI1ssKaOULQ5fqsUErGAjSyGmr0gkZEYHyTKntRXd6E8Cr2JGn6KdXAjBMwJh0945ISeEP7rWgvclgiteTHYwl4YKbo19nwWdZJnrCGhNOFXY0Zn1T0XZfetjm7jAy37xViisILaOAEbKKewcl2O8O1HdhWU3VErqKelbq18cijjSewSl)8irLp29(1lcY4i4gQBPtdqxslJKWsyX(eD8rJdXAjsILaO4gjBbYEeSrLFQxsMW1bI4aD8zrxcVuCJKTWMpAOnshIHKibqDlvZlGKp29(1lcsIea1TunVassclHf7YpBXx(y37xViisILaOAEbKKewcl2Ouhq9Wb00Xr6qmKejaQBPAEbK8XU3VErqKelbq18cijjSewSrPoG6Hdy37xViisILaOAEbKKewcl2LF2IVOI6BSGhMhBI4aporFkxMedDRjPrLWSNy37xViiJJGBOULonaDjTmsclHf7YbEbmYa0HTa(OXHyTejXsauCJKTazpc2OYp1ljt46arCGo(SOlHxkUrYwyZhn0gPdXqsKaOULQ5fqYh7E)6fbjrcG6wQMxajjHLWID5NT4lFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfnupCanDCKoedjrcG6wQMxajFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfnupCa7E)6fbrsSeavZlGKKWsyXU8Zw8fvuFJf8W8yteh4Xj6t5YKyOBnjnQeM9e7E)6fbrsSeavZlGKKWsyXUCGxaJmaDylGpAOHg29(1lcY4i4gQBPtdqxslJKWsyXgL6LKjCDGiA0LWl9cDPmQ1t64ZIphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgH6HdOHDVF9IGmocUH6w60a0L0YijSewSprhFoeRLijwcGIBKSfi7rWgv(PEjzcxhiId0XNfDj8sXns2cBurLphI1ssKaOULQ5fqsUErG6BSGhMhBI4apor)fKPHZZakHzpXU3VErqKelbq18cijjSewSprhF0qdnS79RxeKXrWnu3sNgGUKwgjHLWInk1ljt46ar0OlHx6f6szuRN0XNfFoeRLijwcGIBKSfi7rWgDYHyTejXsauCJKTazj8s3JGnc1dhqd7E)6fbzCeCd1T0PbOlPLrsyjSyFIo(CiwlrsSeaf3izlq2JGnQ8t9sYeUoqehOJpl6s4LIBKSf2OIkFoeRLKibqDlvZlGKC9Ia13ybpmp2eXbECI(XrWnu3sNgGUKwwjm7jhI1sKelbqXns2cK9iyJk)uVKmHRdeXb64ZIUeEP4gjBHnF0qBKoedjrcG6wQMxajFS79RxeKejaQBPAEbKKewcl2LF2IV8XU3VErqKelbq18cijjSewSrPEjzcxhiJpl6s4LEHUug16jv0q9Wb00Xr6qmKejaQBPAEbK8XU3VErqKelbq18cijjSewSrPEjzcxhiJpl6s4LEHUug16jv0q9WbS79RxeejXsaunVassclHf7YpBXxuFJf8W8yteh4Xj6Lelbq18cilHzprdnS79RxeKXrWnu3sNgGUKwgjHLWInk1ljt46ar0OlHx6f6szuRN0XNfFoeRLijwcGIBKSfi7rWgDYHyTejXsauCJKTazj8s3JGnc1dhqd7E)6fbzCeCd1T0PbOlPLrsyjSyFIo(CiwlrsSeaf3izlq2JGnQ8t9sYeUoqehOJpl6s4LIBKSf2OIkFoeRLKibqDlvZlGKC9I4nwWdZJnrCGhNOprcG6wQMxazjm7jhI1ssKaOULQ5fqsUErWhn0WU3VErqghb3qDlDAa6sAzKewcl2OuNOJphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgH6HdOHDVF9IGmocUH6w60a0L0YijSewSprhFoeRLijwcGIBKSfi7rWgv(PEjzcxhiId0XNfDj8sXns2cBurLpAy37xViisILaOAEbKKewcl2OuxDE4Wf4qSwY4i4gQBPtdqxslJGOH6BSGhMhBI4apor)UHzhw0s18cilHzpXU3VErqKelbq9KJKWsyXgL6WHd64iDigIKyjaQNCVXcEyESjId84e9AjSHadu3sxS4wcZEYHyTKlitdNNbqq04FboeRLmocUH6w60a0L0YiiA8VahI1sghb3qDlDAa6sAzKewcl2LFYHyTeTe2qGbQBPlwCjlHx6EeSrLocEyEqKelbq56YEiaVagza6WwWBSGhMhBI4aporVKyjakxx2tjm7jhI1sUGmnCEgabrJpAOnshIHKW2djWaFbpm9afcyXGD5hnQhoi4HPhOqalgSlxhqLpA6yIeG1ZwGijwcGY5lojVliMdhgjBHH0asFAiA4bLhPoG6BSGhMhBI4apor)grdYW1lVXcEyESjId84e9sILaOCsMslucZEYHyTejXsauCJKTazpc2iuEIMGhMEGcbSyW2qLUOYprcW6zlqKelbq58fNK3fed)rYwyinG0NgIgEk)i1H3ybpmp2eXbECIEjXsauojtPfkHzp5qSwIKyjakUrYwGShbB0jhI1sKelbqXns2cKLWlDpc2O3ybpmp2eXbECIEjXsaup5kHzp5qSwIKyjakUrYwGShbB0j6EJf8W8yteh4Xj6dyAGKoWsd2tjm7jAjyty3iCD4WbDCyyJyrlQ85qSwIKyjakUrYwGShbB0jhI1sKelbqXns2cKLWlDpc2O3ybpmp2eXbECIEjXsa0fBVzDyxcZEYHyTeChKel7HfTKee8WprcW6zlqKelbqzHLfSPm(OH2iDigIS06mldldZd(cEy6bkeWIb7Yn0OE4GGhMEGcbSyWUCDa13ybpmp2eXbECIEjXsa0fBVzDyxcZEYHyTeChKel7HfTKee8WFKoedrsSeafWno)lWHyTKXrWnu3sNgGUKwgbrJpAJ0HyiYsRZSmSmmpoCqWdtpqHawmyxEPf13ybpmp2eXbECIEjXsa0fBVzDyxcZEYHyTeChKel7HfTKee8WFKoedrwADMLHLH5bFbpm9afcyXGD5h9BSGhMhBI4aporVKyjakWRw33mpkHzp5qSwIKyjakUrYwGShbBu5CiwlrsSeaf3izlqwcV09iyJEJf8W8yteh4Xj6LelbqbE16(M5rjm7jhI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgXxlb90w8LOlrsSeaLtYuAH3ybpmp2eXbECIEqVJLH5rjSyGmr0gkZEUKqiA4bLNgADOewmqMiAdLTwWLjdCQ7B8B8r5vh1MmpzdZqj8kKnlAFvBY29YEfdZWD4vfSP5vIg5vLMB4vS5vfSP5vJpRx5tdKfSnqEJf8W8ytWU3VErSpTPVhA46Lsy2ZejaRNTaPnz7EzugMH7aFS79RxeejXsaunVassclHfBuEKOJp29(1lcY4i4gQBPtdqxslJKWsyX(eD8rJdXAjsILaO4gjBbYEeSrLFQxsMW1bY4ZIUeEP4gjBHnF0qBKoedjrcG6wQMxajFS79RxeKejaQBPAEbKKewcl2LF2IV8XU3VErqKelbq18cijjSewSrPEjzcxhiJpl6s4LEHUug16jv0q9Wb00Xr6qmKejaQBPAEbK8XU3VErqKelbq18cijjSewSrPEjzcxhiJpl6s4LEHUug16jv0q9WbS79RxeejXsaunVassclHf7YpBXxur9nwWdZJnb7E)6fXMhNO3M(EOHRxkHzptKaSE2cK2KT7LrzygUd8XU3VErqKelbq18cijjSewSprhF00Xr6qmei6S2Mbc4E4aAJ0Hyiq0zTndeWL)scHOHhuEw6rhQOYhn0WU3VErqghb3qDlDAa6sAzKewcl2Oux0XNdXAjsILaO4gjBbYEeSrNCiwlrsSeaf3izlqwcV09iyJq9Wb0WU3VErqghb3qDlDAa6sAzKewcl2NOJphI1sKelbqXns2cK9iyJorhQOYNdXAjjsau3s18cijxVi4VKqiA4bLN6LKjCDGiA0flylKfDjHq1WZBSGhMhBc29(1lInporVn99W59PeM9mrcW6zlqUSnMP1zHKLrX(AjXLp29(1lcchI1sVSnMP1zHKLrX(AjXLKGClJphI1sUSnMP1zHKLrX(AjXLAtFpKRxe8rJdXAjsILaOAEbKKRxe85qSwsIea1TunVasY1lc(xGdXAjJJGBOULonaDjTmY1lcu5JDVF9IGmocUH6w60a0L0YijSewSprhF04qSwIKyjakUrYwGShbBu5N6LKjCDGm(SOlHxkUrYwyZhn0gPdXqsKaOULQ5fqYh7E)6fbjrcG6wQMxajjHLWID5NT4lFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfnupCanDCKoedjrcG6wQMxajFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfnupCa7E)6fbrsSeavZlGKKWsyXU8Zw8fvuFJf8W8ytWU3VErS5Xj6TSeOCDzpLWSNjsawpBbYLTXmTolKSmk2xljU8XU3VErq4qSw6LTXmTolKSmk2xljUKeKBz85qSwYLTXmTolKSmk2xljUullbY1lc(AjON2IVeDj203dN3N34JYRoQ6fsz7xHSHxTyz65(vfSP5vIg5vLg2xn(SEfB)QeKBzVs2VQa69sE1smcE1gjHxn(RWYEEfBEfhy9eE14ZI8gl4H5XMGDVF9IyZJt0Vyz65M6w645cIPeM9e7E)6fbzCeCd1T0PbOlPLrsyjSyFIo(CiwlrsSeaf3izlq2JGnQ8t9sYeUoqgFw0LWlf3izlS5JDVF9IGijwcGQ5fqssyjSyx(zl((gl4H5XMGDVF9IyZJt0Vyz65M6w645cIPeM9e7E)6fbrsSeavZlGKKWsyX(eD8rthhPdXqGOZABgiG7HdOnshIHarN12mqax(ljeIgEq5zPhDOIkF0qd7E)6fbzCeCd1T0PbOlPLrsyjSyJs9sYeUoqen6s4LEHUug16jD8zXNdXAjsILaO4gjBbYEeSrNCiwlrsSeaf3izlqwcV09iyJq9Wb0WU3VErqghb3qDlDAa6sAzKewcl2NOJphI1sKelbqXns2cK9iyJorhQOYNdXAjjsau3s18cijxVi4VKqiA4bLN6LKjCDGiA0flylKfDjHq1WZB8r5vhv9cPS9Rq2WRUGmnCEgWRkytZRenYRknSVA8z9k2(vji3YELSFvb07L8QLye8QnscVA8xHL98k28koW6j8QXNf5nwWdZJnb7E)6fXMhNO)cY0W5zaLWSNy37xViiJJGBOULonaDjTmsclHf7t0XNdXAjsILaO4gjBbYEeSrLFQxsMW1bY4ZIUeEP4gjBHnFS79RxeejXsaunVassclHf7YpBX33ybpmp2eS79RxeBECI(litdNNbucZEIDVF9IGijwcGQ5fqssyjSyFIo(OPJJ0Hyiq0zTndeW9Wb0gPdXqGOZABgiGl)LecrdpO8S0JourLpAOHDVF9IGmocUH6w60a0L0YijSewSrPUOJphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgH6HdOHDVF9IGmocUH6w60a0L0YijSewSprhFoeRLijwcGIBKSfi7rWgDIourLphI1ssKaOULQ5fqsUErWFjHq0Wdkp1ljt46ar0OlwWwil6scHQHN34JYRkn3WR2AsA0Ry2xn(SELe3xjAVss4vE8k89vsCFvHhgmVIdEfI2RSE(QUhTq(QPrIxnnWRwcVV6cDPSsE1smIfTVAJKWRkGx1i6HxjZR6GSNxnf(RKelb8kCJKTW(vsCF10iZRgFwVQq2HbZRoQJSNxHSHl5nwWdZJnb7E)6fXMhNOpLltIHU1K0Osy2tS79RxeKXrWnu3sNgGUKwgjHLWInk1ljt46aj30LWl9cDPmQ1t64ZIp29(1lcIKyjaQMxajjHLWInk1ljt46aj30LWl9cDPmQ1tQOXhTr6qmKejaQBPAEbK8rd7E)6fbjrcG6wQMxajjHLWID5aVagza6WwWHdy37xViijsau3s18cijjSewSrPEjzcxhi5MUeEPxOlLrTEstxd1dh0Xr6qmKejaQBPAEbKOYNdXAjsILaO4gjBbYEeSrOuN8VahI1sghb3qDlDAa6sAzKRxe85qSwsIea1TunVasY1lc(CiwlrsSeavZlGKC9I4n(O8QsZn8QTMKg9Qc208kr7vfnq8knFVzCDG8Qsd7RgFwVITFvcYTSxj7xva9EjVAjgbVAJKWRg)vyzpVInVIdSEcVA8zrEJf8W8ytWU3VErS5Xj6t5YKyOBnjnQeM9e7E)6fbzCeCd1T0PbOlPLrsyjSyxoWlGrgGoSfWNdXAjsILaO4gjBbYEeSrLFQxsMW1bY4ZIUeEP4gjBHnFS79RxeejXsaunVassclHf7Yrd4fWidqh2c4HGhMhKXrWnu3sNgGUKwgb4fWidqh2cq9nwWdZJnb7E)6fXMhNOpLltIHU1K0Osy2tS79RxeejXsaunVassclHf7YbEbmYa0HTa(OHMooshIHarN12mqa3dhqBKoedbIoRTzGaU8xsien8GYZsp6qfv(OHg29(1lcY4i4gQBPtdqxslJKWsyXgL6LKjCDGiA0LWl9cDPmQ1t64ZIphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgH6HdOHDVF9IGmocUH6w60a0L0YijSewSprhFoeRLijwcGIBKSfi7rWgDIourLphI1ssKaOULQ5fqsUErWFjHq0Wdkp1ljt46ar0OlwWwil6scHQHhuFJpkVQ0CdVA8z9Qc208kr7vm7RyJb7xvWMgw8QPbE1s49vxOlLrEvPH9vHpL8kKn8Qc208Q01EfZ(QPbE1iDiMxX2VAeJGOKxjX9vSXG9RkytdlE10aVAj8(Ql0LYiVXcEyESjy37xVi284e9JJGBOULonaDjTSsy2toeRLijwcGIBKSfi7rWgv(PEjzcxhiJpl6s4LIBKSf28XU3VErqKelbq18cijjSewSl)e4fWidqh2c4VKqiA4bL6LKjCDGiA0flylKfDjHq1WdFoeRLKibqDlvZlGKC9I4nwWdZJnb7E)6fXMhNOFCeCd1T0PbOlPLvcZEYHyTejXsauCJKTazpc2OYp1ljt46az8zrxcVuCJKTWM)iDigsIea1TunVas(y37xViijsau3s18cijjSewSl)e4fWidqh2c4JDVF9IGijwcGQ5fqssyjSyJs9sYeUoqgFw0LWl9cDPmQ1tQOXh7E)6fbrsSeavZlGKKWsyXgL6QZ3ybpmp2eS79RxeBECI(XrWnu3sNgGUKwwjm7jhI1sKelbqXns2cK9iyJk)uVKmHRdKXNfDj8sXns2cB(OPJJ0Hyijsau3s18cipCa7E)6fbjrcG6wQMxajjHLWInk1ljt46az8zrxcV0l0LYOwpPPRHkFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfT34JYRkn3WReTxXSVA8z9k2(vE8k89vsCFvHhgmVIdEfI2RSE(QUhTq(QPrIxnnWRwcVV6cDPSsE1smIfTVAJKWRMgzEvb8Qgrp8kiCK2MxTKqELe3xnnY8QPbs4vS9RcFEL0tqUL9k5vjsaVYTVsZlG8vxViiVXcEyESjy37xVi284e9sILaOAEbKLWSNy37xViiJJGBOULonaDjTmsclHfBuQxsMW1bIOrxcV0l0LYOwpPJpl(CiwlrsSeaf3izlq2JGn6KdXAjsILaO4gjBbYs4LUhbBeFoeRLKibqDlvZlGKC9IG)scHOHhuEQxsMW1bIOrxSGTqw0LecvdpVXhLxvAUHxLU2Ry2xn(SEfB)kpEf((kjUVQWddMxXbVcr7vwpFv3JwiF10iXRMg4vlH3xDHUuwjVAjgXI2xTrs4vtdKWRy7WG5vspb5w2RKxLib8QRxeVsI7RMgzELO9QcpmyEfhG9f8krVW6cxhE1fjzr7RsKaiVXcEyESjy37xVi284e9jsau3s18cilHzp5qSwIKyjaQMxaj56fbF0WU3VErqghb3qDlDAa6sAzKewcl2OuVKmHRdK01OlHx6f6szuRN0XN1Hdy37xViisILaOAEbKKewcl2LFQxsMW1bY4ZIUeEPxOlLrTEsfnu5ZHyTejXsauCJKTazpc2OtoeRLijwcGIBKSfilHx6EeSr8XU3VErqKelbq18cijjSewSrPU68nwWdZJnb7E)6fXMhNOF3WSdlAPAEbKLWSNCiwlrsSeavZlGKC9IGp29(1lcIKyjaQMxajzseGMWsyXgLcEyEq2nm7WIwQMxajbFt(CiwljrcG6wQMxaj56fbFS79RxeKejaQBPAEbKKjraAclHfBuk4H5bz3WSdlAPAEbKe8n5FboeRLmocUH6w60a0L0YixViEJpkVQ0CdVsZxVA8xTpciayOeELeVc4Ds5vc3RyXRMg4vbW78kS79RxeVQGfxVOKxHeDyVFLrLLmjE10aXR8Ox2RUijlAFLKyjGxP5fq(Qlc8QXFvJx8QLeYRAqI2SSxLYLjX8QTMKg9k2(nwWdZJnb7E)6fXMhNOxlHneyG6w6If3sy2Zr6qmKejaQBPAEbK85qSwIKyjaQMxajbrJphI1ssKaOULQ5fqssyjSyxEl(swcVVXcEyESjy37xVi284e9AjSHadu3sxS4wcZEEboeRLmocUH6w60a0L0YiiA8VahI1sghb3qDlDAa6sAzKewcl2Ll4H5brsSeaDX2Bwh2eGxaJmaDylGVoID9qiXqmQSKjXBSGhMhBc29(1lInporVwcBiWa1T0flULWSNCiwljrcG6wQMxajbrJphI1ssKaOULQ5fqssyjSyxEl(swcV8XU3VErqa9owgMhKeKBz8XU3VErqghb3qDlDAa6sAzKewcl281rSRhcjgIrLLmjEJFJf8W8ytSSq6uoKm4Xj6LelbqxS9M1HDjm7jhI1sWDqsSShw0ssqWtj4gHfN6(gl4H5XMyzH0PCizWJt0ljwcGY1L98gl4H5XMyzH0PCizWJt0ljwcGYjzkTWB8BSGhMhBYY1dligECIEUolmIkrzLWSNlxpSGyix2EKadO8ux09gl4H5XMSC9WcIHhNOxlHneyG6w6If33ybpmp2KLRhwqm84e9sILaOl2EZ6WUeM9C56Hfed5Y2JeyOCDr3BSGhMhBYY1dligECIEjXsaup5EJf8W8ytwUEybXWJt0Bzjq56YEEJFJf8W8ytCniG8e07yzyEucZEIwIeG1ZwGSzAnEq3JNRdhsKaSE2cKbwAEkDAHKAOYFKoedjrcG6wQMxajFS79RxeKejaQBPAEbKKewcl28rJdXAjjsau3s18cijxVioCqlb90w8LOlrsSeaLtYuAbuFJf8W8ytCniGKhNO3YsGY1L9ucZEMiby9Sfix2gZ06SqYYOyFTK4YNdXAjx2gZ06SqYYOyFTK4sTPVhcI2BSGhMhBIRbbK84e9203dnC9sjm7zIeG1ZwG0MSDVmkdZWDG)scHOHhuwA1H3ybpmp2exdci5Xj6VGmnCEgqjm7PoMiby9SfiBMwJh09456nwWdZJnX1GasECI(uUmjg6wtsJkHzpxsien8GYJgDVXcEyESjUgeqYJt0VBy2HfTunVaYsy2toeRLijwcGQ5fqsUErWh7E)6fbrsSeavZlGKKWsyXMVEjzcxhiSqpKdCPUgeqQJN6(gl4H5XM4AqajporVKyjaQNCLWSN6LKjCDGWc9qoWL6Aqa5PU8XU3VErqsKaOULQ5fqssyjSyFIU3ybpmp2exdci5Xj6Lelbq56YEkHzp1ljt46aHf6HCGl11GaYtD5JDVF9IGKibqDlvZlGKKWsyX(eD85qSwIKyjakUrYwGShbBu5CiwlrsSeaf3izlqwcV09iyJEJf8W8ytCniGKhNOprcG6wQMxazjm7PEjzcxhiSqpKdCPUgeqEQlFoeRLKibqDlvZlGKC9I4nwWdZJnX1GasECIEnFyEucZEQxsMW1bcl0d5axQRbbKN6YxhrlrcW6zlq2mTgpO7XZ1HdjsawpBbYalnpLoTqsnuFJf8W8ytCniGKhNO)cY0W5zaLWSNCiwljrcG6wQMxaj56fXBSGhMhBIRbbK84e9lwMEUPULoEUGykHzp5qSwsIea1TunVasY1lIdh0sqpTfFj6sKelbq5KmLw4nwWdZJnX1GasECI(XrWnu3sNgGUKwwjm7jhI1ssKaOULQ5fqsUErC4Gwc6PT4lrxIKyjakNKP0cVXcEyESjUgeqYJt0ljwcGQ5fqwcZEQLGEAl(s0LmocUH6w60a0L0YEJf8W8ytCniGKhNOprcG6wQMxazjm7jhI1ssKaOULQ5fqsUEr8gl4H5XM4AqajporVwcBiWa1T0flULWSNxGdXAjJJGBOULonaDjTmcIg)lWHyTKXrWnu3sNgGUKwgjHLWID5cEyEqKelbqxS9M1Hnb4fWidqh2cEJf8W8ytCniGKhNOxlHneyG6w6If3sy2Zr6qmKejaQBPAEbK85qSwIKyjaQMxajbrJphI1ssKaOULQ5fqssyjSyxEl(swcVVXcEyESjUgeqYJt0ljwcGY1L9ucZEE9HKYLjXq3AsAejHLWInk1HdhUahI1ss5YKyOBnjnIQhPhqkCSoBkJShbBekr3BSGhMhBIRbbK84e9sILaOCDzpLWSNCiwlrlHneyG6w6IfxcIg)lWHyTKXrWnu3sNgGUKwgbrJ)f4qSwY4i4gQBPtdqxslJKWsyXU8tbpmpisILaOCDzpeGxaJmaDyl4nwWdZJnX1GasECIEjXsauojtPfkHzp5qSwsIea1TunVascIgFS79RxeejXsaunVasscYTm(ljeIgEk)OrhFoeRLijwcGIBKSfi7rWgDYHyTejXsauCJKTazj8s3JGnIVoMiby9SfiBMwJh0945IVoMiby9SfidS08u60cj1EJf8W8ytCniGKhNOxsSeaLtYuAHsy2toeRLKibqDlvZlGKGOXNdXAjsILaOAEbKKRxe85qSwsIea1TunVassclHf7YpBXx(CiwlrsSeaf3izlq2JGn6KdXAjsILaO4gjBbYs4LUhbBeF9sYeUoqyHEih4sDniG8nwWdZJnX1GasECIEjXsa0fBVzDyxcZEEboeRLmocUH6w60a0L0YiiA8hPdXqKelbqbCJZhnoeRLCbzA48maY1lIdhe8W0duiGfd2N6Ik)lWHyTKXrWnu3sNgGUKwgjHLWInkf8W8GijwcGUy7nRdBcWlGrgGoSfWhnDumucjBaIKyjaQgYAbDw0sGq46W9WboeRLG7GKyzpSOLIBKiGo56fbQLGBewCQBjGK9YO4gHfuM9KdXAj4oijw2dlAP4gjcOtUErWhnoeRLijwcGQ5fqsq0oCanDCKoedX1dPMxajC5JghI1ssKaOULQ5fqsq0oCa7E)6fbb07yzyEqsqULHkQO(gl4H5XM4AqajporVKyjaQNCLWSNCiwlrsSeaf3izlq2JGnQ8t9sYeUoqgFw0LWlf3izlS5Jg29(1lcIKyjaQMxajjHLWInk1fDhoi4HPhOqalgSl)uNO(gl4H5XM4AqajporVKyjakxx2tjm7jhI1ssKaOULQ5fqsq0oCyjHq0Wdk1vhEJf8W8ytCniGKhNOh07yzyEucZEYHyTKejaQBPAEbKKRxe85qSwIKyjaQMxaj56frjSyGmr0gkZEUKqiA4bLNgADOewmqMiAdLTwWLjdCQ7BSGhMhBIRbbK84e9sILaOCsMsl8g)gFuELGhMhBs6Jmmp4Xj6XsGHovWdZJsy2tbpmpiGEhldZdcUrIa6SOL)scHOHhuEwA1b(OPJjsawpBbYMP14bDpEUoCGdXAjBMwJh0945IShbB0jhI1s2mTgpO7XZfzj8s3JGnc13ybpmp2K0hzyEWJt0d6DSmmpkHzpxsien8u(PEjzcxhiGENQHh(OHDVF9IGmocUH6w60a0L0YijSewSl)uWdZdcO3XYW8Ga8cyKbOdBbhoGDVF9IGijwcGQ5fqssyjSyx(PGhMheqVJLH5bb4fWidqh2coCaTr6qmKejaQBPAEbK8XU3VErqsKaOULQ5fqssyjSyx(PGhMheqVJLH5bb4fWidqh2cqfv(CiwljrcG6wQMxaj56fbFoeRLijwcGQ5fqsUErW)cCiwlzCeCd1T0PbOlPLrUErWxh1sqpTfFj6sghb3qDlDAa6sAzVXcEyESjPpYW8GhNOh07yzyEucZEMiby9SfiBMwJh0945Ip29(1lcIKyjaQMxajjHLWID5NcEyEqa9owgMheGxaJmaDyl4n(O8kEkzkTWRy2xXgd2VAyl4vJ)kKn8QXN1RK4(Qc4vnIE4vJ7VAjrzVc3izlSFJf8W8ytsFKH5bporVKyjakNKP0cLWSNy37xViiJJGBOULonaDjTmscYTm(OXHyTejXsauCJKTazpc2iuQxsMW1bY4ZIUeEP4gjBHnFS79RxeejXsaunVassclHf7YpbEbmYa0HTa(ljeIgEqPEjzcxhiIgDXc2czrxsiun8WNdXAjjsau3s18cijxViq9nwWdZJnj9rgMh84e9sILaOCsMslucZEIDVF9IGmocUH6w60a0L0Yiji3Y4JghI1sKelbqXns2cK9iyJqPEjzcxhiJpl6s4LIBKSf28hPdXqsKaOULQ5fqYh7E)6fbjrcG6wQMxajjHLWID5NaVagza6WwaFS79RxeejXsaunVassclHfBuQxsMW1bY4ZIUeEPxOlLrTEsfnuFJf8W8ytsFKH5bporVKyjakNKP0cLWSNy37xViiJJGBOULonaDjTmscYTm(OXHyTejXsauCJKTazpc2iuQxsMW1bY4ZIUeEP4gjBHnF00Xr6qmKejaQBPAEbKhoGDVF9IGKibqDlvZlGKKWsyXgL6LKjCDGm(SOlHx6f6szuRN001qLp29(1lcIKyjaQMxajjHLWInk1ljt46az8zrxcV0l0LYOwpPIgQVXcEyESjPpYW8GhNOxsSeaLtYuAHsy2ZlWHyTKuUmjg6wtsJO6r6bKchRZMYi7rWgDEboeRLKYLjXq3AsAevpspGu4yD2ugzj8s3JGnIpACiwlrsSeavZlGKC9I4WboeRLijwcGQ5fqssyjSyx(zl(IkF04qSwsIea1TunVasY1lIdh4qSwsIea1TunVassclHf7YpBXxuFJf8W8ytsFKH5bporVKyjakxx2tjm751hskxMedDRjPrKewcl2O0qF4aAxGdXAjPCzsm0TMKgr1J0difowNnLr2JGncLOJ)f4qSwskxMedDRjPru9i9asHJ1ztzK9iyJk)cCiwljLltIHU1K0iQEKEaPWX6SPmYs4LUhbBeQVXcEyESjPpYW8GhNOxsSeaLRl7PeM9KdXAjAjSHadu3sxS4sq04FboeRLmocUH6w60a0L0YiiA8VahI1sghb3qDlDAa6sAzKewcl2LFk4H5brsSeaLRl7Ha8cyKbOdBbVXcEyESjPpYW8GhNOxsSeaDX2Bwh2LWSNxGdXAjJJGBOULonaDjTmcIg)r6qmejXsaua348rJdXAjxqMgopdGC9I4Wbbpm9afcyXG9PUOYhTlWHyTKXrWnu3sNgGUKwgjHLWInkf8W8GijwcGUy7nRdBcWlGrgGoSfC4a29(1lcIwcBiWa1T0flUKewcl2hoGD9qiXqmQSKjbQ8rthfdLqYgGijwcGQHSwqNfTeieUoCpCGdXAj4oijw2dlAP4gjcOtUErGAj4gHfN6wcizVmkUrybLzp5qSwcUdsIL9WIwkUrIa6KRxe8rJdXAjsILaOAEbKeeTdhqthhPdXqC9qQ5fqcx(OXHyTKejaQBPAEbKeeTdhWU3VErqa9owgMhKeKBzOIkQVXcEyESjPpYW8GhNOxsSeaDX2Bwh2LWSNCiwlb3bjXYEyrljbbp85qSwcWRMex4s18bIHjDcI2BSGhMhBs6Jmmp4Xj6LelbqxS9M1HDjm7jhI1sWDqsSShw0ssqWdF04qSwIKyjaQMxajbr7WboeRLKibqDlvZlGKGOD4Wf4qSwY4i4gQBPtdqxslJKWsyXgLcEyEqKelbqxS9M1Hnb4fWidqh2cqTeCJWItDFJf8W8ytsFKH5bporVKyja6IT3SoSlHzp5qSwcUdsIL9WIwsccE4ZHyTeChKel7HfTK9iyJo5qSwcUdsIL9WIwYs4LUhbBuj4gHfN6(gl4H5XMK(idZdECIEjXsa0fBVzDyxcZEYHyTeChKel7HfTKee8WNdXAj4oijw2dlAjjSewSl)en04qSwcUdsIL9WIwYEeSrLocEyEqKelbqxS9M1Hnb4fWidqh2cqLhT4lQLGBewCQ7BSGhMhBs6Jmmp4Xj6dyAGKoWsd2tjm7jAjyty3iCD4WbDCyyJyrlQ85qSwIKyjakUrYwGShbB0jhI1sKelbqXns2cKLWlDpc2i(CiwlrsSeavZlGKC9IG)f4qSwY4i4gQBPtdqxslJC9I4nwWdZJnj9rgMh84e9sILaOEYvcZEYHyTejXsauCJKTazpc2OYp1ljt46az8zrxcVuCJKTW(nwWdZJnj9rgMh84e9BenidxVucZEUKqiA4P8ZsRoWNdXAjsILaOAEbKKRxe85qSwsIea1TunVasY1lc(xGdXAjJJGBOULonaDjTmY1lI3ybpmp2K0hzyEWJt0ljwcGY1L9ucZEYHyTKePdu3sNMeGnbrJphI1sKelbqXns2cK9iyJq5r(gl4H5XMK(idZdECIEjXsauojtPfkHzpxsien8u(PEjzcxhiCsMslqxsiun8WNdXAjsILaOAEbKKRxe85qSwsIea1TunVasY1lc(xGdXAjJJGBOULonaDjTmY1lc(CiwlrsSeaf3izlq2JGn6KdXAjsILaO4gjBbYs4LUhbBeFS79RxeeqVJLH5bjHLWI9BSGhMhBs6Jmmp4Xj6Lelbq5KmLwOeM9KdXAjsILaOAEbKKRxe85qSwsIea1TunVasY1lc(xGdXAjJJGBOULonaDjTmY1lc(CiwlrsSeaf3izlq2JGn6KdXAjsILaO4gjBbYs4LUhbBe)r6qmejXsaup54JDVF9IGijwcG6jhjHLWID5NT4l)LecrdpLFwArhFS79RxeeqVJLH5bjHLWI9BSGhMhBs6Jmmp4Xj6Lelbq5KmLwOeM9KdXAjsILaOAEbKeen(CiwlrsSeavZlGKKWsyXU8Zw8LphI1sKelbqXns2cK9iyJo5qSwIKyjakUrYwGSeEP7rWgXh7E)6fbb07yzyEqsyjSy)gl4H5XMK(idZdECIEjXsauojtPfkHzp5qSwsIea1TunVascIgFoeRLijwcGQ5fqsUErWNdXAjjsau3s18cijjSewSl)SfF5ZHyTejXsauCJKTazpc2OtoeRLijwcGIBKSfilHx6EeSr8XU3VErqa9owgMhKewcl2VXcEyESjPpYW8GhNOxsSeaLtYuAHsy2toeRLijwcGQ5fqsUErWNdXAjjsau3s18cijxVi4FboeRLmocUH6w60a0L0YiiA8VahI1sghb3qDlDAa6sAzKewcl2LF2IV85qSwIKyjakUrYwGShbB0jhI1sKelbqXns2cKLWlDpc2O3ybpmp2K0hzyEWJt0ljwcGYjzkTqjm75izlmKgq6tdrdpLFK6aFoeRLijwcGIBKSfi7rWgHYt0e8W0duiGfd2gQ0fv(jsawpBbIKyjakNV4K8UGy4l4HPhOqalgSrPU85qSwYfKPHZZaixViEJf8W8ytsFKH5bporVKyjakWRw33mpkHzphjBHH0asFAiA4P8Juh4ZHyTejXsauCJKTazpc2OY5qSwIKyjakUrYwGSeEP7rWgXprcW6zlqKelbq58fNK3fedFbpm9afcyXGnk1LphI1sUGmnCEga56fXBSGhMhBs6Jmmp4Xj6Lelbq56YEEJf8W8ytsFKH5bporpO3XYW8OeM9KdXAjjsau3s18cijxVi4ZHyTejXsaunVasY1lc(xGdXAjJJGBOULonaDjTmY1lI3ybpmp2K0hzyEWJt0ljwcGYjzkTq1uqMgpRMMSfsxgMhgEk2Po1Pwb]] )


end
