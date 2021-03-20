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


    spec:RegisterPack( "Arcane", 20210317, [[dW0yfgqikqEeLsXLOaeAtKsFIcAuKiNIe1Quru9kviZIc1TOaK2fHFbQyyGQ6yKclJsHNrPOMgfaxtfHTPIi(gLsPXrPiohLI06OusZtf09aL9bQYbPuQwiOspKcuxKci(ifGOrsbKCsveLvsHmtkL4Mua1ovr6NuaPgQkqTuvePNsrtvfQRsbO(QkqYyvbSxP8xIgmWHrTys6Xqnzv1Lr2SiFwunAr50qwnfGGxtcMni3wL2nv)wy4KQJRcelxYZLQPR46QY2Pu9Dkz8QOopPO1RcKA(Kq7xPBA0oUz(5HANAd4BdnGVnRHTvOHnb(AOXjAMJM6uZuNXkW5uZ05l1mT9cZo1m1znHc(3oUz2JxHPMz2m6DBfoWjhnzpvboUWPJUpiEqHJlonWPJUy40mvFiO5K5n1M5NhQDQnGVn0a(2Sg2wHg2e4dFB2M2m76eUD6jXgnZm0)tEtTz(PoUzAG5CAb2EHzNwJmWCHZwGg2wJxGnGVn0ynAn6Ks3WoTa7CHyvisWxzxNVla5liX2JAbrAbDAgKN3f8v2157cucNryfwGMXRwqxNWli0hu4DLfRrgWDAbJM6imdTat01Gxqg7FiKNVGiTaCg7obTaKpuvp9bf(cqEFi(VGiTadXSJjijJhu4gkAMqO(0Bh3mdDYPQDC7unAh3mjNvHOFdUntCHgQqCZSEoLIkNeFuhJ0HqoxAkXX9Y(xqoRcr)fODbQVus8rDmshc5CPPeh3l7FzQI(iE6ntgpOWBMjursviUpTPDQnAh3mjNvHOFdUntCHgQqCZSEoLIkNe5fQdPPeHryisqoRcr)fODbx2zHoEwa8wGn9entgpOWBMPk6J0d7CBANAZTJBMmEqH3m)epzQr5uZKCwfI(n42M2PgG2XntYzvi63GBZexOHke3mVSZcD8Sa4Tada8BMmEqH3ml(JyFKDDUuOnTtpr74Mj5Ske9BWTzIl0qfIBMQVusWfMDsQhwuj(HLVaTlahb0pSCbxy2jPEyrLOOlJ8EZKXdk8MzpdLgKNl1dlQAt70ts74MjJhu4nZlQQO6YijNOUKpntYzvi63GBBANABBh3mz8GcVzoXdNjJKCYi5LZrntYzvi63GBBANAtAh3mz8GcVzYfMDsQhwu1mjNvHOFdUTPDQnTDCZKCwfI(n42mXfAOcXnt1xkjQNtYij1dlQe)WYBMmEqH3mRNtYij1dlQAt7unGF74Mj5Ske9BWTzY4bfEZuVOo5ysgj5f5)M5N64cPpOWBMgWDAbhCyGxWelOFqEeDqtlG9fqNNIxGTxy2PfaxiUpl4)kKNVGjJwWXXyGHJTFWlWc5)WAbphI69fup3rE(cS9cZoTadeCwiwWjlTaBVWStlWabNfla1xWWqKp034fyrlaZUHZcEDAbhCyGxGfAYq(cMmAbhhJbgo2(bValK)dRf8CiQ3xGfTaKpuvp9zbtgTaB3aVaCg7obz8c6XcSidHGwqNTtlanIMjUqdviUzAqlyyiYhbxy2jjHZcb5Ske9xG2f8j1xkjM4HZKrsozK8Y5iXtFbAxWNuFPKyIhotgj5KrYlNJefDzK3xWHWwGslGXdkCbxy2jPke3hbDMWVHKd6sl4KVa1xkj0lQtoMKrsEr(xC5ZY(WyfwGYTPDQgA0oUzsoRcr)gCBMmEqH3m1lQtoMKrsEr(Vz(PoUq6dk8M5jlTGdomWliJ7UHZcujYxWRt)f8FfYZxWKrl44ymWlWc5)WY4fyrgcbTGxNwaAwWelOFqEeDqtlG9fqNNIxGTxy2PfaxiUpla5lyYOfCsJdgo2(bValK)dlrZexOHke3m)Xik(JyFKDDUuqu0LrEFbWBbNybkQ4c(K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRWcG3cGFBANQHnAh3mjNvHOFdUntCHgQqCZu9Lsc9I6KJjzKKxK)fp9fODbFs9LsIjE4mzKKtgjVCos80xG2f8j1xkjM4HZKrsozK8Y5irrxg59fCiSfW4bfUGlm7KufI7JGot43qYbDPMjJhu4ntUWStsviUpTPDQg2C74Mj5Ske9BWTzY4bfEZKlm7KuLRIZPM5N64cPpOWBM2oKfRzFbWLRIZPfWZcMmAbK)xqKwGTFWlWkJ8fup3rE(cMmAb2EHzNwGbkUUHR5cGOCY)CPzZexOHke3mvFPKGlm7KupSOs80xG2fO(sjbxy2jPEyrLOOlJ8(coCb54)c0UG65ukQCsWfMDsI8eYrJMcYzvi63M2PAyaAh3mjNvHOFdUntgpOWBMCHzNKQCvCo1m)uhxi9bfEZ02HSyn7laUCvCoTaEwWKrlG8)cI0cMmAbN04GxGfY)H1cSYiFb1ZDKNVGjJwGTxy2PfyGIRB4AUaikN8pxA2mXfAOcXnt1xkjQNtYij1dlQep9fODbQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkrrxg59fCiSfKJ)lq7cQNtPOYjbxy2jjYtihnAkiNvHOFBANQXjAh3mjNvHOFdUntCgJ8MPgntIlinL4mg5suQzQ(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvujdAyiYhryNk9WIk6Rvj1xkjQNtYij1dlQepDfvehb0pSCbzpW8Gcxue)1uzLvUzIl0qfIBMFs9LsIjE4mzKKtgjVCos80xG2fmme5JGlm7KKWzHGCwfI(lq7cuAbQVus8jEYuJYjXpS8fOOIlGXdYojjNUiQVaylqJfO8c0UGpP(sjXepCMmsYjJKxohjk6YiVVa4TagpOWfCHzNKxuVJGOUGot43qYbDPMjJhu4ntUWStYlQ3rquVnTt14K0oUzsoRcr)gCBMmEqH3m5cZojVOEhbr9MjoJrEZuJMjUqdviUzQ(sjbgI4cZ9b55IIy80M2PAyBBh3mjNvHOFdUntCHgQqCZu9LscUWStsCgx5KOpmwHfCiSfyNleRcrIjMR8YNL4mUYPEZKXdk8Mjxy2jzuQTPDQg2K2XntYzvi63GBZexOHke3mvFPKOEojJKupSOs80xGIkUGl7SqhplaElqJt0mz8GcVzYfMDsQcX9PnTt1WM2oUzsoRcr)gCBMmEqH3mj7bMhu4ntKpuvp9rIsnZl7SqhpWdMn5entKpuvp9rIUx6J4HAMA0mXfAOcXnt1xkjQNtYij1dlQe)WYxG2fO(sjbxy2jPEyrL4hwEBANAd43oUzY4bfEZKlm7KuLRIZPMj5Ske9BWTnTPzMq9mKNldDYPQDC7unAh3mjNvHOFdUntgpOWBMK9aZdk8M5N64cPpOWBMhuzKVG65oYZxaHMmQwWKrlW0CbrTGJpOwaeLt(Nle1nEbw0cSyFwWelWaXESavkffTGjJwWXXyGHJTFWlWc5)WsSad4oTa0SaUVGEe(c4(coPXbVGmUVGeYr9m6VG4vlWIm0oTGUo5ZcIxTaCgx5uVzIl0qfIBMkTG65ukQCs0r6zHl7tuxb5Ske9xGIkUG65ukQCsm0vpkgsAXLUGCwfI(lq5fODbkTa1xkjQNtYij1dlQe)WYxGIkUa9ISlZXFHgcUWStsvUkoNwGYlq7cWra9dlxupNKrsQhwujk6YiV3M2P2ODCZKCwfI(n42mz8GcVzs2dmpOWBMFQJlK(GcVzEYslWIm0oTGeYr9m6VG4vlahb0pS8fyH8Fy1xa7)f01jFwq8QfGZ4kN6gVa9cffAqh00cmqShliSt1ci7uP5KH88fqqDQzIl0qfIBMddr(iQNtYij1dlQeKZQq0FbAxaocOFy5I65Kmss9WIkrrxg59fODb4iG(HLl4cZoj1dlQefDzK3xG2fO(sjbxy2jPEyrL4hw(c0Ua1xkjQNtYij1dlQe)WYxG2fOxKDzo(l0qWfMDsQYvX5uBANAZTJBMKZQq0Vb3MjUqdviUzwpNsrLtIpQJr6qiNlnL44Ez)liNvHO)c0Ua1xkj(OogPdHCU0uIJ7L9VmvrFep9MjJhu4nZeQiPke3N20o1a0oUzsoRcr)gCBM4cnuH4Mz9CkfvojYluhstjcJWqKGCwfI(lq7cUSZcD8Sa4TaB6jAMmEqH3mtv0hPh2520o9eTJBMKZQq0Vb3MjUqdviUzAqlOEoLIkNeDKEw4Y(e1vqoRcr)fODbg0cQNtPOYjXqx9OyiPfx6cYzvi63mz8GcVz(jEYuJYP20o9K0oUzsoRcr)gCBM4cnuH4MjocOFy5I65Kmss9WIkrr8xZMjJhu4ntUWStYOuBt7uBB74Mj5Ske9BWTzIl0qfIBM4iG(HLlQNtYij1dlQefXFnxG2fO(sjbxy2jjoJRCs0hgRWcoCbQVusWfMDsIZ4kNex(SSpmwHMjJhu4ntUWStsviUpTPDQnPDCZKXdk8Mz9CsgjPEyrvZKCwfI(n42M2P202XntYzvi63GBZKXdk8Mjxy2j5f17iiQ3m)uhxi9bfEZ8KLwGfzyrlGNfC5ZlOpmwH(cI0cmydEbS)xGfTGm2o5gol41P)cmWXXlqtAmEbVoTaEb9HXkSGjwGEr2jFwW954mKN3mXfAOcXnt1xkjWqexyUpipxueJNfODbQVusGHiUWCFqEUOpmwHfaBbQVusGHiUWCFqEU4YNL9HXkSaTlah2jN9ryN8jtZAbAxaocOFy5IlQQO6YijNOUKpII4VMTPDQgWVDCZKCwfI(n42mXfAOcXntdAbkTG65ukQCs0r6zHl7tuxb5Ske9xGIkUG65ukQCsm0vpkgsAXLUGCwfI(lq5M5N64cPpOWBMNg1LHG0Cbw0c0zuTa9yqHVGxNwGfAYwGTFWgVa13Sa0Salee0cG4(SaOWZxa5XlpBbPOwGAmzlyYOfCsJdEbS)xGTFWlWc5)WQVGNdr9(cQN7ipFbtgTatZfe1co(GAbquo5FUquVzY4bfEZupgu4TPDQgA0oUzsoRcr)gCBM4cnuH4MP6lLe1ZjzKK6HfvIFy5lqrfxGEr2L54Vqdbxy2jPkxfNtntgpOWBMFINm1OCQnTt1WgTJBMKZQq0Vb3MjUqdviUzQ(sjr9CsgjPEyrL4hw(cuuXfOxKDzo(l0qWfMDsQYvX5uZKXdk8MzXFe7JSRZLcTPDQg2C74Mj5Ske9BWTzIl0qfIBMQVusupNKrsQhwuj(HLVafvCb6fzxMJ)cneCHzNKQCvCo1mz8GcVzErvfvxgj5e1L8PnTt1Wa0oUzsoRcr)gCBM4cnuH4MPEr2L54VqdXepCMmsYjJKxoh1mz8GcVzYfMDsQhwu1M2PACI2XntYzvi63GBZKXdk8MPErDYXKmsYlY)nZp1XfsFqH3mnG70co4WaVGjwq)G8i6GMwa7lGopfVaBVWStlaUqCFwW)vipFbtgTGJJXadhB)GxGfY)H1cEoe17lOEUJ88fy7fMDAbgi4SqSGtwAb2EHzNwGbcolwaQVGHHiFOVXlWIwaMDdNf860co4WaVal0KH8fmz0coogdmCS9dEbwi)hwl45quVValAbiFOQE6ZcMmAb2UbEb4m2DcY4f0JfyrgcbTGoBNwaAentCHgQqCZ0GwWWqKpcUWStscNfcYzvi6VaTl4tQVusmXdNjJKCYi5LZrIN(c0UGpP(sjXepCMmsYjJKxohjk6YiVVGdHTaLwaJhu4cUWStsviUpc6mHFdjh0LwWjFbQVusOxuNCmjJK8I8V4YNL9HXkSaLBt7unojTJBMKZQq0Vb3MjJhu4nt9I6KJjzKKxK)BMFQJlK(GcVzEYsl4Gdd8cY4UB4SavI8f860Fb)xH88fmz0coogd8cSq(pSmEbwKHqql41PfGMfmXc6hKhrh00cyFb05P4fy7fMDAbWfI7Zcq(cMmAbN04GHJTFWlWc5)Ws0mXfAOcXnt1xkj4cZoj1dlQep9fODbQVusupNKrsQhwujk6YiVVGdHTaLwaJhu4cUWStsviUpc6mHFdjh0LwWjFbQVusOxuNCmjJK8I8V4YNL9HXkSaLBt7unSTTJBMKZQq0Vb3MjUqdviUz(Jru8hX(i76CPGOOlJ8(cG3coXcuuXf8j1xkjk(JyFKDDUuqA)b5uXQii0OPOpmwHfaVfa)MjJhu4ntUWStsviUpTPDQg2K2XntYzvi63GBZKXdk8Mjxy2jPkxfNtnZp1XfsFqH3mpOOfyX(SGjwWLvGwq)v0cSOfKX2PfqE8YZwWLDEbPOwWKrlG8bv0cS9dEbwi)hwgVaYo5laLwWKrfzyFb9bbbTGbDPfu0LroYZxq4l4KghSybNSXW(cchsZfOsZq1cMybQVYxWel4GMQybS)xGbI9ybO0cQN7ipFbtgTatZfe1co(GAbquo5FUqux0mXfAOcXntCeq)WYfCHzNK6HfvII4VMlq7cUSZcD8SGdxGslWaa)fC0cuAbAa)fCYxaoSto7Jqbnle7lq5fO8c0Ua1xkj4cZojXzCLtI(WyfwaSfO(sjbxy2jjoJRCsC5ZY(WyfwG2fyqlOEoLIkNeDKEw4Y(e1vqoRcr)fODbg0cQNtPOYjXqx9OyiPfx6cYzvi63M2PAytBh3mjNvHOFdUntgpOWBMCHzNKQCvCo1m)uhxi9bfEZ0a2HOEFb1ZDKNVGjJwGTxy2PfyGIRB4AUaikN8pxAA8cGlxfNtlONfpO)c8ywGkTGxN(lGNfmz0ci)VGiTaB)GxakTade7bMhu4la1xqKslahb0pS8fW9f8Rqxh55laNXvo1xGfccAbxwbAbOzbdRaTaOWZPAbtSa1x5lyYQ4LNTGIUmYrE(cUSZntCHgQqCZu9LscUWSts9WIkXtFbAxG6lLeCHzNK6HfvIIUmY7l4qylih)xG2fO0cQNtPOYjbxy2jjYtihnAkiNvHO)cuuXfGJa6hwUGShyEqHlk6YiVVaLBt7uBa)2XntYzvi63GBZKXdk8Mjxy2jPkxfNtnZp1XfsFqH3mHlxfNtlONfpO)cyilwZ(cuPfmz0cG4(Sam3NfG8fmz0coPXbValK)dRfW9fCCmg4fyHGGwqr9jkAbtgTaCgx5uFbDDYNMjUqdviUzQ(sjr9CsgjPEyrL4PVaTlq9LscUWSts9WIkXpS8fODbQVusupNKrsQhwujk6YiVVGdHTGC8VnTtTHgTJBMKZQq0Vb3MjoJrEZuJMjXfKMsCgJCjk1mvFPKadrCH5(G8CjoJDNGe)WY1QK6lLeCHzNK6HfvINUIkQKbnme5JiStLEyrf91QK6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AQSYk3mXfAOcXnZpP(sjXepCMmsYjJKxohjE6lq7cggI8rWfMDss4SqqoRcr)fODbkTa1xkj(epzQr5K4hw(cuuXfW4bzNKKtxe1xaSfOXcuEbAxWNuFPKyIhotgj5KrYlNJefDzK3xa8waJhu4cUWStYlQ3rquxqNj8Bi5GUuZKXdk8Mjxy2j5f17iiQ3M2P2WgTJBMKZQq0Vb3M5N64cPpOWBMgODinxqF4AwWRJ88fyWg8cSDd8cSYiFb2(bVGmUVavI8f860VzIl0qfIBMQVusGHiUWCFqEUOigplq7cWra9dlxWfMDsQhwujk6YiVVaTlqPfO(sjr9CsgjPEyrL4PVafvCbQVusWfMDsQhwujE6lq5MjoJrEZuJMjJhu4ntUWStYlQ3rquVnTtTHn3oUzsoRcr)gCBM4cnuH4MP6lLeCHzNK4mUYjrFyScl4qylWoxiwfIetmx5LplXzCLt9MjJhu4ntUWStYOuBt7uByaAh3mjNvHOFdUntCHgQqCZu9LsI65Kmss9WIkXtFbkQ4cUSZcD8Sa4TanorZKXdk8Mjxy2jPke3N20o1gNODCZKCwfI(n42mz8GcVzs2dmpOWBMiFOQE6JeLAMx2zHoEGhmBYjAMiFOQE6JeDV0hXd1m1OzIl0qfIBMQVusupNKrsQhwuj(HLVaTlq9LscUWSts9WIkXpS820o1gNK2XntgpOWBMCHzNKQCvCo1mjNvHOFdUTPnnZpL4h00oUDQgTJBMmEqH3mXXZhQ66eeuZKCwfI(n42M2P2ODCZKCwfI(n42md9MzNMMjJhu4nt7CHyviQzANHEuZuJMjUqdviUzANleRcrIm2ojdDYP)cGTa4VaTlqVi7YC8xOHGShyEqHVaTlWGwGslOEoLIkNeDKEw4Y(e1vqoRcr)fOOIlOEoLIkNedD1JIHKwCPliNvHO)cuUzANlPZxQzMX2jzOto9Bt7uBUDCZKCwfI(n42md9MzNMMjJhu4nt7CHyviQzANHEuZuJMjUqdviUzANleRcrIm2ojdDYP)cGTa4VaTlq9LscUWSts9WIkXpS8fODb4iG(HLl4cZoj1dlQefDzK3xG2fO0cQNtPOYjrhPNfUSprDfKZQq0FbkQ4cQNtPOYjXqx9OyiPfx6cYzvi6VaLBM25s68LAMzSDsg6Kt)20o1a0oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZqpQzQrZexOHke3mvFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLpl7dJvybAxGbTa1xkjQhejJKCYkI6IN(c0Ua1O3xG2fKq5zJSOlJ8(coe2cuAbkTGl78cGZcy8GcxWfMDsQcX9rGJ(SaLxWjFbmEqHl4cZojvH4(iOZe(nKCqxAbk3mTZL05l1mtiNHKQVYBt70t0oUzsoRcr)gCBM4cnuH4MPslyyiYhb5qO8SHC6liNvHO)c0UGl7Sqhpl4qylWMa)fODbx2zHoEwa8GTGtYjwGYlqrfxGslWGwWWqKpcYHq5zd50xqoRcr)fODbx2zHoEwWHWwGn5elq5MjJhu4nZl7SmNUTPD6jPDCZKCwfI(n42mXfAOcXnt1xkj4cZoj1dlQep9MjJhu4nt9yqH3M2P222XntYzvi63GBZexOHke3mRNtPOYjXqx9OyiPfx6cYzvi6VaTlq9Lsc6Cg)6dkCXtFbAxGslahb0pSCbxy2jPEyrLOi(R5cuuXfOg9(c0UGekpBKfDzK3xWHWwGba(lq5MjJhu4nZbDjPfx6TPDQnPDCZKCwfI(n42mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrL4hw(c0UGpP(sjXepCMmsYjJKxohj(HL3mz8GcVzcHYZMU0acVF(L8PnTtTPTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jPEyrL4hw(c0Ua1xkjQNtYij1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS8MjJhu4ntvoxgj5uiSc920ovd43oUzsoRcr)gCBM4cnuH4MP6lLeCHzNK6HfvINEZKXdk8MPkvDQua55TPDQgA0oUzsoRcr)gCBM4cnuH4MP6lLeCHzNK6HfvINEZKXdk8MPkueFz6vA2M2PAyJ2XntYzvi63GBZexOHke3mvFPKGlm7KupSOs80BMmEqH3mtOIuHI43M2PAyZTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jPEyrL4P3mz8GcVzYoM6tXqsmdb1M2PAyaAh3mjNvHOFdUntCHgQqCZu9LscUWSts9WIkXtVzY4bfEZ81jjAOBVnTt14eTJBMKZQq0Vb3MjJhu4nZCi(J4jQUuL)5uZexOHke3mvFPKGlm7KupSOs80xGIkUaCeq)WYfCHzNK6HfvIIUmY7laEWwWjoXc0UGpP(sjXepCMmsYjJKxohjE6ntkLi8iD(snZCi(J4jQUuL)5uBANQXjPDCZKCwfI(n42mz8GcVzsxDnlIHKr9D2XuZexOHke3mXra9dlxWfMDsQhwujk6YiVVGdHTaLwGg28coAb22fCYxGDUqSkejyDz4YxNwGYntNVuZKU6AwedjJ67SJP20ovdBB74Mj5Ske9BWTzY4bfEZ8xe)tOIK2PENGAM4cnuH4MjocOFy5cUWSts9WIkrrxg59fapylWgWFbkQ4cmOfyNleRcrcwxgU81PfaBbASafvCbkTGbDPfaBbWFbAxGDUqSkejsOEgYZLHo5uTaylqJfODb1ZPuu5KOJ0Zcx2NOUcYzvi6VaLBMoFPM5Vi(NqfjTt9ob1M2PAytAh3mjNvHOFdUntgpOWBM94bjr5oAOQzIl0qfIBM4iG(HLl4cZoj1dlQefDzK3xa8GTaBg(lqrfxGbTa7CHyvisW6YWLVoTaylqJMPZxQz2JhKeL7OHQ20ovdBA74Mj5Ske9BWTzY4bfEZmhst9mzKKCVJUiiEqH3mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7laEWwGnG)cuuXfyqlWoxiwfIeSUmC5Rtla2c0ybkQ4cuAbd6sla2cG)c0Ua7CHyvisKq9mKNldDYPAbWwGglq7cQNtPOYjrhPNfUSprDfKZQq0Fbk3mD(snZCin1ZKrsY9o6IG4bfEBANAd43oUzsoRcr)gCBMmEqH3mVmMvls2ZiAK3xhHBM4cnuH4MjocOFy5cUWSts9WIkrrxg59fCiSfCIfODbkTadAb25cXQqKiH6zipxg6Kt1cGTanwGIkUGbDPfaVfyZWFbk3mD(snZlJz1IK9mIg591r420o1gA0oUzsoRcr)gCBMmEqH3mVmMvls2ZiAK3xhHBM4cnuH4MjocOFy5cUWSts9WIkrrxg59fCiSfCIfODb25cXQqKiH6zipxg6Kt1cGTanwG2fO(sjr9CsgjPEyrL4PVaTlq9LsI65Kmss9WIkrrxg59fCiSfO0c0a(lWa6coXco5lOEoLIkNeDKEw4Y(e1vqoRcr)fO8c0UGbDPfC4cSz43mD(snZlJz1IK9mIg591r420o1g2ODCZKCwfI(n42mXfAOcXntgpi7KKC6IO(cG3cSrZSpfcpTt1OzY4bfEZeZqqsgpOWLqO(0mHq9r68LAMCqTPDQnS52XntYzvi63GBZexOHke3mXHDYzFekOzHyFbAxq9Ckfvoj4cZojrEc5Ortb5Ske9xG2fmme5JOEojJKupSOsqoRcr)fODbg0cWH)FOrWfMDsQxXhLRPGCwfI(nZ(ui80ovJMjJhu4ntmdbjz8GcxcH6tZec1hPZxQzMX1nCnBt7uByaAh3mjNvHOFdUnZp1XfsFqH3mpoJwqc1ZqE(ccDYPAbQuoY7lWcnzl4Kgh8cy)VGeQNr9fKIAbgSbVa9kW9fmXcEDAb)xH88fCCmgy4y7hCZKXdk8MjMHGKmEqHlHq9Pz2NcHN2PA0mXfAOcXnt7CHyvisKX2jzOto9xaSfa)fODb25cXQqKiH6zipxg6KtvZec1hPZxQzMq9mKNldDYPQnTtTXjAh3mjNvHOFdUntCHgQqCZ0oxiwfIezSDsg6Kt)faBbWVz2NcHN2PA0mz8GcVzIziijJhu4siuFAMqO(iD(snZqNCQAt7uBCsAh3mjNvHOFdUntCHgQqCZStZG88UGVYUoFxaSfOrZSpfcpTt1OzY4bfEZeZqqsgpOWLqO(0mHq9r68LAM8v215BBANAdBB74Mj5Ske9BWTzY4bfEZeZqqsgpOWLqO(0mHq9r68LAM4iG(HL3Bt7uBytAh3mjNvHOFdUntCHgQqCZ0oxiwfIejKZqs1x5la2cGFZSpfcpTt1OzY4bfEZeZqqsgpOWLqO(0mHq9r68LAMvm8GcVnTtTHnTDCZKCwfI(n42mXfAOcXnt7CHyvisKqodjvFLVaylqJMzFkeEANQrZKXdk8MjMHGKmEqHlHq9PzcH6J05l1mtiNHKQVYBt7uBg(TJBMKZQq0Vb3MjJhu4ntmdbjz8GcxcH6tZec1hPZxQzEd70L8PnTPzwXWdk82XTt1ODCZKCwfI(n42mz8GcVzs2dmpOWBMFQJlK(GcVzY4bfExuXWdk8JGbhm7ycsY4bfUXOemgpOWfK9aZdkCboJDNGqEU2l7SqhpWdMn9eAvYGQNtPOYjrhPNfUSprDvur1xkj6i9SWL9jQROpmwbyQVus0r6zHl7tuxXLpl7dJvq5MjUqdviUzEzNf64zbhcBb25cXQqKGShsD8SaTlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xWHWwaJhu4cYEG5bfUGot43qYbDPfOOIlahb0pSCbxy2jPEyrLOOlJ8(coe2cy8Gcxq2dmpOWf0zc)gsoOlTafvCbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cy8Gcxq2dmpOWf0zc)gsoOlTaLxGYlq7cuFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hw(c0UadAb6fzxMJ)cnet8WzYijNmsE5CuBANAJ2XntYzvi63GBZexOHke3mRNtPOYjrhPNfUSprDfKZQq0FbAxaocOFy5cUWSts9WIkrrxg59fCiSfW4bfUGShyEqHlOZe(nKCqxQzY4bfEZKShyEqH3M2P2C74Mj5Ske9BWTzY4bfEZKlm7KuLRIZPM5N64cPpOWBMWLRIZPfGslang2xWGU0cMybVoTGjM7cy)ValAbzSDAbtel4YUMlaNXvo1BM4cnuH4MjocOFy5IjE4mzKKtgjVCosue)1CbAxGslq9LscUWStsCgx5KOpmwHfaVfyNleRcrIjMR8YNL4mUYP(c0UaCeq)WYfCHzNK6HfvIIUmY7l4qylGot43qYbDPfODbx2zHoEwa8wGDUqSkejyD5f5O77kVSZsD8SaTlq9LsI65Kmss9WIkXpS8fOCBANAaAh3mjNvHOFdUntCHgQqCZehb0pSCXepCMmsYjJKxohjkI)AUaTlqPfO(sjbxy2jjoJRCs0hgRWcG3cSZfIvHiXeZvE5ZsCgx5uFbAxWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUOEojJKupSOsu0LrEFbhcBb0zc)gsoOlTaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvE5ZYpbXAktrjz9fOCZKXdk8Mjxy2jPkxfNtTPD6jAh3mjNvHOFdUntCHgQqCZehb0pSCXepCMmsYjJKxohjkI)AUaTlqPfO(sjbxy2jjoJRCs0hgRWcG3cSZfIvHiXeZvE5ZsCgx5uFbAxGslWGwWWqKpI65Kmss9WIkb5Ske9xGIkUaCeq)WYf1ZjzKK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLSc9fO8c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLK1xGYntgpOWBMCHzNKQCvCo1M2PNK2XntYzvi63GBZexOHke3m)K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRWcGTGpP(sjrXFe7JSRZLcs7piNkwfbHgnfx(SSpmwHfODbkTa1xkj4cZoj1dlQe)WYxGIkUa1xkj4cZoj1dlQefDzK3xWHWwqo(VaLxG2fO0cuFPKOEojJKupSOs8dlFbkQ4cuFPKOEojJKupSOsu0LrEFbhcBb54)cuUzY4bfEZKlm7KuLRIZP20o122oUzsoRcr)gCBM4cnuH4M5pgrXFe7JSRZLcIIUmY7laElWMSafvCbkTGpP(sjrXFe7JSRZLcs7piNkwfbHgnf9HXkSa4Ta4VaTl4tQVusu8hX(i76CPG0(dYPIvrqOrtrFyScl4Wf8j1xkjk(JyFKDDUuqA)b5uXQii0OP4YNL9HXkSaLBMmEqH3m5cZojvH4(0M2P2K2XntYzvi63GBZexOHke3mvFPKqVOo5ysgj5f5FXtFbAxWNuFPKyIhotgj5KrYlNJep9fODbFs9LsIjE4mzKKtgjVCosu0LrEFbhcBbmEqHl4cZojvH4(iOZe(nKCqxQzY4bfEZKlm7KufI7tBANAtBh3mjNvHOFdUntCgJ8MPgntIlinL4mg5suQzQ(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvujdAyiYhryNk9WIk6Rvj1xkjQNtYij1dlQepDfvehb0pSCbzpW8Gcxue)1uzLvUzIl0qfIBMFs9LsIjE4mzKKtgjVCos80xG2fmme5JGlm7KKWzHGCwfI(lq7cuAbQVus8jEYuJYjXpS8fOOIlGXdYojjNUiQVaylqJfO8c0UaLwWNuFPKyIhotgj5KrYlNJefDzK3xa8waJhu4cUWStYlQ3rquxqNj8Bi5GU0cuuXfGJa6hwUqVOo5ysgj5f5Frrxg59fOOIlah2jN9rOGMfI9fOCZKXdk8Mjxy2j5f17iiQ3M2PAa)2XntYzvi63GBZexOHke3mvFPKadrCH5(G8CrrmEwG2fO(sjbDwN9p9L6Xq(GyiXtVzY4bfEZKlm7K8I6Dee1Bt7un0ODCZKCwfI(n42mz8GcVzYfMDsEr9ocI6ntCgJ8MPgntCHgQqCZu9LscmeXfM7dYZffX4zbAxGslq9LscUWSts9WIkXtFbkQ4cuFPKOEojJKupSOs80xGIkUGpP(sjXepCMmsYjJKxohjk6YiVVa4TagpOWfCHzNKxuVJGOUGot43qYbDPfOCBANQHnAh3mjNvHOFdUntgpOWBMCHzNKxuVJGOEZeNXiVzQrZexOHke3mvFPKadrCH5(G8CrrmEwG2fO(sjbgI4cZ9b55I(WyfwaSfO(sjbgI4cZ9b55IlFw2hgRqBANQHn3oUzsoRcr)gCBMmEqH3m5cZojVOEhbr9MjoJrEZuJMjUqdviUzQ(sjbgI4cZ9b55IIy8SaTlq9LscmeXfM7dYZffDzK3xWHWwGslqPfO(sjbgI4cZ9b55I(WyfwWjFbmEqHl4cZojVOEhbrDbDMWVHKd6slq5fC0cYX)fOCBANQHbODCZKCwfI(n42mXfAOcXntLwqrPI6zSkeTafvCbg0cgewbKNVaLxG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRWc0Ua1xkj4cZoj1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS8MjJhu4ntNMmQKdD1P(0M2PACI2XntYzvi63GBZexOHke3mvFPKGlm7KeNXvoj6dJvybhcBb25cXQqKyI5kV8zjoJRCQ3mz8GcVzYfMDsgLABANQXjPDCZKCwfI(n42mXfAOcXnZl7Sqhpl4qylWMEIfODbQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkXpS8fODbFs9LsIjE4mzKKtgjVCos8dlVzY4bfEZS)0PYd7CBANQHTTDCZKCwfI(n42mXfAOcXnt1xkjQhejJKCYkI6IN(c0Ua1xkj4cZojXzCLtI(Wyfwa8wGn3mz8GcVzYfMDsQcX9PnTt1WM0oUzsoRcr)gCBM4cnuH4M5LDwOJNfCiSfyNleRcrcvUkoNKx2zPoEwG2fO(sjbxy2jPEyrL4hw(c0Ua1xkjQNtYij1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS8fODbQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YNL9HXkSaTlahb0pSCbzpW8Gcxu0LrEVzY4bfEZKlm7KuLRIZP20ovdBA74Mj5Ske9BWTzIl0qfIBMQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkXpS8fODbFs9LsIjE4mzKKtgjVCos8dlFbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojU8zzFySclq7cggI8rWfMDsgLQGCwfI(lq7cWra9dlxWfMDsgLQOOlJ8(coe2cYX)fODbx2zHoEwWHWwGnf(lq7cWra9dlxq2dmpOWffDzK3BMmEqH3m5cZojv5Q4CQnTtTb8Bh3mjNvHOFdUntCHgQqCZu9LscUWSts9WIkXtFbAxG6lLeCHzNK6HfvIIUmY7l4qylih)xG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRWc0UaLwaocOFy5cYEG5bfUOOlJ8(cuuXfupNsrLtcUWStsKNqoA0uqoRcr)fOCZKXdk8Mjxy2jPkxfNtTPDQn0ODCZKCwfI(n42mXfAOcXnt1xkjQNtYij1dlQep9fODbQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkrrxg59fCiSfKJ)lq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLpl7dJvybAxGslahb0pSCbzpW8Gcxu0LrEFbkQ4cQNtPOYjbxy2jjYtihnAkiNvHO)cuUzY4bfEZKlm7KuLRIZP20o1g2ODCZKCwfI(n42mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fO(sjr9CsgjPEyrL4hw(c0UGpP(sjXepCMmsYjJKxohjE6lq7c(K6lLet8WzYijNmsE5CKOOlJ8(coe2cYX)fODbQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YNL9HXk0mz8GcVzYfMDsQYvX5uBANAdBUDCZKCwfI(n42mXfAOcXnZHRCAezednzcD8SGdxGnFIfODbQVusWfMDsIZ4kNe9HXkSa4bBbkTagpi7KKC6IO(cmGUanwGYlq7cQNtPOYjbxy2jPACv56FjFeKZQq0FbAxaJhKDssoDruFbWBbASaTlq9LsIpXtMAuoj(HL3mz8GcVzYfMDsQYvX5uBANAddq74Mj5Ske9BWTzIl0qfIBMdx50iYigAYe64zbhUaB(elq7cuFPKGlm7KeNXvoj6dJvybhUa1xkj4cZojXzCLtIlFw2hgRWc0UG65ukQCsWfMDsQgxvU(xYhb5Ske9xG2fW4bzNKKtxe1xa8wGglq7cuFPK4t8KPgLtIFy5ntgpOWBMCHzNK0zDOOJcVnTtTXjAh3mz8GcVzYfMDsQcX9PzsoRcr)gCBt7uBCsAh3mjNvHOFdUntCHgQqCZu9LsI65Kmss9WIkXpS8fODbQVusWfMDsQhwuj(HLVaTl4tQVusmXdNjJKCYi5LZrIFy5ntgpOWBMK9aZdk820o1g222XntgpOWBMCHzNKQCvCo1mjNvHOFdUTPnnt(k768TDC7unAh3mjNvHOFdUntgpOWBMK9aZdk8M5N64cPpOWBMmEqH3f8v215lmm7ycsY4bfUXOemgpOWfK9aZdkCboJDNGqEU2l7SqhpWdMn9entCHgQqCZ8Yol0XZcoe2cSZfIvHibzpK64zbAxGslahb0pSCXepCMmsYjJKxohjk6YiVVGdHTagpOWfK9aZdkCbDMWVHKd6slqrfxaocOFy5cUWSts9WIkrrxg59fCiSfW4bfUGShyEqHlOZe(nKCqxAbkQ4cuAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5I65Kmss9WIkrrxg59fCiSfW4bfUGShyEqHlOZe(nKCqxAbkVaLxG2fO(sjr9CsgjPEyrL4hw(c0Ua1xkj4cZoj1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS820o1gTJBMKZQq0Vb3MjUqdviUzIJa6hwUGlm7KupSOsu0LrEFbWwa8xG2fO0cuFPKOEojJKupSOs8dlFbAxGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YlFw(jiwtzkk5eZDbkQ4cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)cuEbk3mz8GcVz(jEYuJYP20o1MBh3mjNvHOFdUntCHgQqCZehb0pSCbxy2jPEyrLOOlJ8(cGTa4VaTlqPfO(sjr9CsgjPEyrL4hw(c0UaLwaocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqKG1Lx(S8tqSMYuuYjM7cuuXfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fO8cuUzY4bfEZ8IQkQUmsYjQl5tBANAaAh3mz8GcVzw8hX(i76CPqZKCwfI(n42M2PNODCZKCwfI(n42mXfAOcXnt1xkj4cZoj1dlQe)WYxG2fGJa6hwUGlm7KupSOsm1JKfDzK3xa8waJhu4IEgknipxQhwujW)AbAxG6lLe1ZjzKK6HfvIFy5lq7cWra9dlxupNKrsQhwujM6rYIUmY7laElGXdkCrpdLgKNl1dlQe4FTaTl4tQVusmXdNjJKCYi5LZrIFy5ntgpOWBM9muAqEUupSOQnTtpjTJBMKZQq0Vb3MjUqdviUzQ(sjr9CsgjPEyrL4hw(c0UaCeq)WYfCHzNK6HfvIIUmY7ntgpOWBM1ZjzKK6HfvTPDQTTDCZKCwfI(n42mXfAOcXntLwaocOFy5cUWSts9WIkrrxg59faBbWFbAxG6lLe1ZjzKK6HfvIFy5lq5fOOIlqVi7YC8xOHOEojJKupSOQzY4bfEZCIhotgj5KrYlNJAt7uBs74Mj5Ske9BWTzIl0qfIBM4iG(HLl4cZoj1dlQefDzK3xWHl4eWFbAxG6lLe1ZjzKK6HfvIFy5lq7cOENCmjSJ6OWLrsQtvIWdkCb5Ske9BMmEqH3mN4HZKrsozK8Y5O20o1M2oUzsoRcr)gCBM4cnuH4MP6lLe1ZjzKK6HfvIFy5lq7cWra9dlxmXdNjJKCYi5LZrIIUmY7laElWoxiwfIeSU8YNLFcI1uMIsoXCBMmEqH3m5cZoj1dlQAt7unGF74Mj5Ske9BWTzIl0qfIBMQVusWfMDsQhwujE6lq7cuFPKGlm7KupSOsu0LrEFbhcBbmEqHl4cZojVOEhbrDbDMWVHKd6slq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLpl7dJvOzY4bfEZKlm7KuLRIZP20ovdnAh3mjNvHOFdUntCHgQqCZu9LscUWStsCgx5KOpmwHfC4cuFPKGlm7KeNXvojU8zzFySclq7cuFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hwEZKXdk8Mjxy2jzuQTPDQg2ODCZKCwfI(n42mXfAOcXnt1xkjQNtYij1dlQe)WYxG2fO(sjbxy2jPEyrL4hw(c0UGpP(sjXepCMmsYjJKxohj(HLVaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNex(SSpmwHMjJhu4ntUWStsvUkoNAt7unS52XntYzvi63GBZeNXiVzQrZK4cstjoJrUeLAMQVusGHiUWCFqEUeNXUtqIFy5Avs9LscUWSts9WIkXtxrfvFPKOEojJKupSOs80vurCeq)WYfK9aZdkCrr8xtLBM4cnuH4MP6lLeyiIlm3hKNlkIXtZKXdk8Mjxy2j5f17iiQ3M2PAyaAh3mjNvHOFdUntCgJ8MPgntIlinL4mg5suQzQ(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvu9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnvUzIl0qfIBMg0c4dAQqdj4cZoj1F3lbH8Cb5Ske9xGIkUa1xkjWqexyUpipxIZy3jiXpS8MjJhu4ntUWStYlQ3rquVnTt14eTJBMKZQq0Vb3MjUqdviUzQ(sjr9CsgjPEyrL4hw(c0Ua1xkj4cZoj1dlQe)WYxG2f8j1xkjM4HZKrsozK8Y5iXpS8MjJhu4ntYEG5bfEBANQXjPDCZKCwfI(n42mXfAOcXnt1xkj4cZojXzCLtI(WyfwWHlq9LscUWStsCgx5K4YNL9HXk0mz8GcVzYfMDsgLABANQHTTDCZKXdk8Mjxy2jPkxfNtntYzvi63GBBANQHnPDCZKXdk8Mjxy2jPke3NMj5Ske9BWTnTPzEd70L8PDC7unAh3mjNvHOFdUntCHgQqCZ8g2Pl5J4J6d7yAbWd2c0a(ntgpOWBMQqixH20o1gTJBMmEqH3m1lQtoMKrsEr(VzsoRcr)gCBt7uBUDCZKCwfI(n42mXfAOcXnZByNUKpIpQpSJPfC4c0a(ntgpOWBMCHzNKxuVJGOEBANAaAh3mz8GcVzYfMDsgLAZKCwfI(n42M2PNODCZKXdk8MzcvKufI7tZKCwfI(n42M20m1lchxvEAh3ovJ2XntgpOWBMCHzNKiFiiicpntYzvi63GBBANAJ2XntgpOWBM939gUKlm7KmXxeeIRMj5Ske9BWTnTtT52XntgpOWBM4WnGWRi5LDwMt3Mj5Ske9BWTnTtnaTJBMKZQq0Vb3MzO3mlQttZKXdk8MPDUqSke1mTZL05l1m5RSRZ3M5Ns8dAAMDAgKN3f8v215BBANEI2XntYzvi63GBZm0BMf1PPzY4bfEZ0oxiwfIAM25s68LAMK9qQJNM5Ns8dAAMACI20o9K0oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZL05l1m1ls)bbjj7rZexOHke3mvAb1ZPuu5KOJ0Zcx2NOUcYzvi6VaTlGXdYojjNUiQVa4TanwWrlqPfOXco5lqPfyqlah2jN9r4eUcOO(lq5fO8cuUzANHEKKG6uZe(nt7m0JAMA0M2P222XntYzvi63GBZm0BMDAAMmEqH3mTZfIvHOMPDUKoFPMzgBNKHo50VzIl0qfIBMkTagpi7KKC6IO(cG3cSXcuuXfyNleRcrc9I0FqqsYESaylqJfOOIlWoxiwfIe8v2157cGTanwGYnt7m0JKeuNAMWVzANHEuZuJ20o1M0oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZqpQzc)MPDUKoFPMzc5mKu9vEBANAtBh3mjNvHOFdUnZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzwD5Lpl)eeRPmfLCI52m)uIFqtZ8eTPDQgWVDCZKCwfI(n42md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPMz1Lx(S8tqSMYuuYk0BMFkXpOPzEI20ovdnAh3mjNvHOFdUnZqVzwuNMMjJhu4nt7CHyviQzANlPZxQzwD5Lpl)eeRPmfLK1BMFkXpOPzAd43M2PAyJ2XntYzvi63GBZm0BMf1PPzY4bfEZ0oxiwfIAM25s68LAM3yK6fHj6lNyUsvnBMFkXpOPzAZTPDQg2C74Mj5Ske9BWTzg6nZI600mz8GcVzANleRcrnt7CjD(snZBmYlFw(jiwtzkk5eZTz(Pe)GMMPgWVnTt1Wa0oUzsoRcr)gCBMHEZSOonntgpOWBM25cXQquZ0oxsNVuZ8gJ8YNLFcI1uMIsY6nZpL4h00m14eTPDQgNODCZKCwfI(n42md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPMjRlV8z5NGynLPOKtm3M5Ns8dAAMAa)20ovJts74Mj5Ske9BWTzg6nZI600mz8GcVzANleRcrnt7CjD(sntwxE5ZYpbXAktrjVX0m)uIFqtZ0gWVnTt1W22oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZqpQzAd4VadOlqPfCIfCYxao8)dncUWSts9k(OCnfKZQq0Fbk3mTZL05l1mRqxE5ZYpbXAktrjNyUTPDQg2K2XntYzvi63GBZm0BMDAAMmEqH3mTZfIvHOMPDUKoFPM5eZvE5ZYpbXAktrjz9MjUqdviUzQ0cWHDYzFeokpBKjMwGIkUaLwao8)dncUWSts9k(OCnfKZQq0FbAxaJhKDssoDruFbhUaBEbkVaLBM2zOhjjOo1mprZ0od9OMPgNOnTt1WM2oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZqpQzAd4VadOlqPfytwWjFb4W)p0i4cZoj1R4JY1uqoRcr)fOCZ0oxsNVuZCI5kV8z5NGynLPOKvO3M2P2a(TJBMKZQq0Vb3MzO3m700mz8GcVzANleRcrnt7m0JAMNe4VadOlqPfC5(qLMs7m0JwWjFbAaF4VaLBM4cnuH4MjoSto7JWr5zJmXuZ0oxsNVuZuLRIZj5LDwQJN20o1gA0oUzsoRcr)gCBMHEZSttZKXdk8MPDUqSke1mTZqpQzAtpXcmGUaLwWL7dvAkTZqpAbN8fOb8H)cuUzIl0qfIBM4Wo5Spcf0SqS3mTZL05l1mv5Q4CsEzNL64PnTtTHnAh3mjNvHOFdUnZqVz2PPzY4bfEZ0oxiwfIAM2zOh1mTjWFbgqxGsl4Y9HknL2zOhTGt(c0a(WFbk3mXfAOcXnt7CHyvisOYvX5K8Yol1XZcGTa43mTZL05l1mv5Q4CsEzNL64PnTtTHn3oUzsoRcr)gCBMHEZSOonntgpOWBM25cXQquZ0oxsNVuZK1LxKJUVR8Yol1XtZ8tj(bnntnorBANAddq74Mj5Ske9BWTzg6nZI600mz8GcVzANleRcrnt7CjD(snZjMR8YNL4mUYPEZ8tj(bnntB0M2P24eTJBMKZQq0Vb3MzO3mlQttZKXdk8MPDUqSke1mTZL05l1m5GKtmx5LplXzCLt9M5Ns8dAAM2OnTtTXjPDCZKCwfI(n42md9MzNMMjJhu4nt7CHyviQzANHEuZuJfCYxGslGoipKUo9f0vxZIyizuFNDmTafvCbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlqPfmme5JGlm7KKWzHGCwfI(lqrfxGbTaCyNC2hHcAwi2xGYlq7cuAbg0cWHDYzFeoHRakQ)cuuXfW4bzNKKtxe1xaSfOXcuuXfupNsrLtIosplCzFI6kiNvHO)cuEbkVaLBM25s68LAMjupd55YqNCQAt7uByBBh3mjNvHOFdUnZqVz2PPzY4bfEZ0oxiwfIAM2zOh1mPdYdPRtFXLXSArYEgrJ8(6i8cuuXfqhKhsxN(ICi(J4jQUuL)50cuuXfqhKhsxN(ICi(J4jQU8sFgccf(cuuXfqhKhsxN(IpxkCJWLFcRGu)nf1XKJPfOOIlGoipKUo9fiVJR3WQqK8G8yFEx5NSJW0cuuXfqhKhsxN(IE8GGOzqEUSEQAUafvCb0b5H01PVO)CvOi(s(stMM9zbkQ4cOdYdPRtFHfRa5u1LPk8)cuuXfqhKhsxN(IeeFjzKKQ8mquZ0oxsNVuZK1LHlFDQnTtTHnPDCZKCwfI(n42md9MzrDAAMmEqH3mTZfIvHOMPDUKoFPMjhKCI5kV8zjoJRCQ3m)uIFqtZ0gTPDQnSPTJBMKZQq0Vb3MzO3mlQttZKXdk8MPDUqSke1mTZL05l1mj7HuhpnZpL4h00m14eTPDQnd)2XntgpOWBMxuvrjrxoNAMKZQq0Vb320o1M1ODCZKCwfI(n42mXfAOcXntdAb25cXQqKqVi9heKKShla2c0ybAxq9Ckfvoj(OogPdHCU0uIJ7L9VGCwfI(ntgpOWBMPk6JAanTPDQnBJ2XntYzvi63GBZexOHke3mnOfyNleRcrc9I0FqqsYESaylqJfODbg0cQNtPOYjXh1XiDiKZLMsCCVS)fKZQq0VzY4bfEZKlm7KufI7tBANAZ2C74Mj5Ske9BWTzIl0qfIBM25cXQqKqVi9heKKShla2c0OzY4bfEZKShyEqH3M20mXra9dlV3oUDQgTJBMKZQq0Vb3MjJhu4nZuf9r6HDUz(PoUq6dk8M5bxOOqd6GMwWRJ88fKxOoKMlaHryiAbwOjBbSUybgWDAbOzbwOjBbtm3fetgvwOojAM4cnuH4Mz9CkfvojYluhstjcJWqKGCwfI(lq7cWra9dlxWfMDsQhwujk6YiVVa4TaBg(lq7cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0UaLwG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIetmx5LplXzCLt9fODbkTaLwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUOEojJKupSOsu0LrEFbhcBb54)c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLK1xGYlqrfxGslWGwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb25cXQqKyI5kV8z5NGynLPOKS(cuEbkQ4cWra9dlxWfMDsQhwujk6YiVVGdHTGC8FbkVaLBt7uB0oUzsoRcr)gCBM4cnuH4Mz9CkfvojYluhstjcJWqKGCwfI(lq7cWra9dlxWfMDsQhwujk6YiVVayla(lq7cuAbg0cggI8rqoekpBiN(cYzvi6VafvCbkTGHHiFeKdHYZgYPVGCwfI(lq7cUSZcD8Sa4bBb2w4VaLxGYlq7cuAbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cG3c0a(lq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLpl7dJvybkVafvCbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cGTa4VaTlq9LscUWStsCgx5KOpmwHfaBbWFbkVaLxG2fO(sjr9CsgjPEyrL4hw(c0UGl7SqhplaEWwGDUqSkejyD5f5O77kVSZsD80mz8GcVzMQOpspSZTPDQn3oUzsoRcr)gCBM4cnuH4Mz9Ckfvoj(OogPdHCU0uIJ7L9VGCwfI(lq7cWra9dlxO(sj5h1XiDiKZLMsCCVS)ffXFnxG2fO(sjXh1XiDiKZLMsCCVS)LPk6J4hw(c0UaLwG6lLeCHzNK6HfvIFy5lq7cuFPKOEojJKupSOs8dlFbAxWNuFPKyIhotgj5KrYlNJe)WYxGYlq7cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0UaLwG6lLeCHzNK4mUYjrFyScl4qylWoxiwfIetmx5LplXzCLt9fODbkTaLwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUOEojJKupSOsu0LrEFbhcBb54)c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLK1xGYlqrfxGslWGwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb25cXQqKyI5kV8z5NGynLPOKS(cuEbkQ4cWra9dlxWfMDsQhwujk6YiVVGdHTGC8FbkVaLBMmEqH3mtv0h1aAAt7udq74Mj5Ske9BWTzIl0qfIBM1ZPuu5K4J6yKoeY5stjoUx2)cYzvi6VaTlahb0pSCH6lLKFuhJ0HqoxAkXX9Y(xue)1CbAxG6lLeFuhJ0HqoxAkXX9Y(xMqfj(HLVaTlqVi7YC8xOHivrFudOPzY4bfEZmHksQcX9PnTtpr74Mj5Ske9BWTzY4bfEZ8IQkQUmsYjQl5tZ8tDCH0hu4nZdMr1cmWXXlWcnzlW2p4fGslang2xaoUipFbp9f0JWfl4KLwaAwGfccAbQ0cED6Val0KTGJJXaB8cWCFwaAwqhcLNnqAUavkff1mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(coCb25cXQqK4gJuVimrF5eZvQQ5cuuXfO0cWra9dlxWfMDsQhwujk6YiVVa4Ta7CHyvisCJrE5ZYpbXAktrjz9fODb4iG(HLlM4HZKrsozK8Y5irrxg59faVfyNleRcrIBmYlFw(jiwtzkk5eZDbk3M2PNK2XntYzvi63GBZexOHke3mXra9dlxWfMDsQhwujkI)AUaTlqPfyqlyyiYhb5qO8SHC6liNvHO)cuuXfO0cggI8rqoekpBiN(cYzvi6VaTl4Yol0XZcGhSfyBH)cuEbkVaTlqPfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7laElWoxiwfIeSU8YNLFcI1uMIsoXCxG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRWcuEbkQ4cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faBbWFbAxG6lLeCHzNK4mUYjrFyScla2cG)cuEbkVaTlq9LsI65Kmss9WIkXpS8fODbx2zHoEwa8GTa7CHyvisW6YlYr33vEzNL64PzY4bfEZ8IQkQUmsYjQl5tBANABBh3mjNvHOFdUntgpOWBMFINm1OCQz(PoUq6dk8MPTdzXA2xWRtl4t8KPgLtlWcnzlG1fl4KLwWeZDbO(ckI)AUaUValccY4fCzfOf0FfTGjwaM7ZcqZcuPuu0cMyUIMjUqdviUzIJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLx(SeNXvo1xG2fGJa6hwUGlm7KupSOsu0LrEFbhcBb54FBANAtAh3mjNvHOFdUntCHgQqCZehb0pSCbxy2jPEyrLOOlJ8(cGTa4VaTlqPfyqlyyiYhb5qO8SHC6liNvHO)cuuXfO0cggI8rqoekpBiN(cYzvi6VaTl4Yol0XZcGhSfyBH)cuEbkVaTlqPfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7laElqd4VaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNex(SSpmwHfO8cuuXfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwaSfa)fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq7cUSZcD8Sa4bBb25cXQqKG1LxKJUVR8Yol1XtZKXdk8M5N4jtnkNAt7uBA74Mj5Ske9BWTzY4bfEZS4pI9r215sHM5N64cPpOWBMgWDAbDDUuybO0cMyUlG9)cy9fWfTGWxa(Va2)lWkCdNfOsl4PVGuulak8CQwWKX(cMmAbx(8c(eeRPXl4YkG88f0FfTalAbzSDAb8SaiI7ZcgRybCHzNwaoJRCQVa2)lyY4zbtm3fyXD3Wzbgq41Nf860x0mXfAOcXntCeq)WYft8WzYijNmsE5CKOOlJ8(cG3cSZfIvHir1Lx(S8tqSMYuuYjM7c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIevxE5ZYpbXAktrjz9fODbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlqPfGJa6hwUOEojJKupSOsu0LrEFbhUa6mHFdjh0LwGIkUaCeq)WYf1ZjzKK6HfvIIUmY7laElWoxiwfIevxE5ZYpbXAktrjRqFbkVafvCbg0cggI8rupNKrsQhwujiNvHO)cuEbAxG6lLeCHzNK4mUYjrFySclaElWglq7c(K6lLet8WzYijNmsE5CK4hw(c0Ua1xkjQNtYij1dlQe)WYxG2fO(sjbxy2jPEyrL4hwEBANQb8Bh3mjNvHOFdUntgpOWBMf)rSpYUoxk0m)uhxi9bfEZ0aUtlORZLclWcnzlG1xGvg5lqp6DKkejwWjlTGjM7cq9fue)1CbCFbweeKXl4YkqlO)kAbtSam3NfGMfOsPOOfmXCfntCHgQqCZehb0pSCXepCMmsYjJKxohjk6YiVVGdxaDMWVHKd6slq7cuFPKGlm7KeNXvoj6dJvybhcBb25cXQqKyI5kV8zjoJRCQVaTlahb0pSCbxy2jPEyrLOOlJ8(coCbkTa6mHFdjh0LwWrlGXdkCXepCMmsYjJKxohjOZe(nKCqxAbk3M2PAOr74Mj5Ske9BWTzIl0qfIBM4iG(HLl4cZoj1dlQefDzK3xWHlGot43qYbDPfODbkTaLwGbTGHHiFeKdHYZgYPVGCwfI(lqrfxGslyyiYhb5qO8SHC6liNvHO)c0UGl7SqhplaEWwGTf(lq5fO8c0UaLwGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YlFw(jiwtzkk5eZDbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojU8zzFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSayla(lq5fO8c0Ua1xkjQNtYij1dlQe)WYxG2fCzNf64zbWd2cSZfIvHibRlVihDFx5LDwQJNfOCZKXdk8MzXFe7JSRZLcTPDQg2ODCZKCwfI(n42mz8GcVzoXdNjJKCYi5LZrnZp1XfsFqH3mnG70cMyUlWcnzlG1xakTa0yyFbwOjd5lyYOfC5Zl4tqSMIfCYslWJX4f860cSqt2cQqFbO0cMmAbddr(SauFbdRa5gVa2)lang2xGfAYq(cMmAbx(8c(eeRPOzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvismXCLx(SeNXvo1xG2fGJa6hwUGlm7KupSOsu0LrEFbhcBb0zc)gsoOlTaTl4Yol0XZcG3cSZfIvHibRlVihDFx5LDwQJNfODbQVusupNKrsQhwuj(HL3M2PAyZTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcoe2cSZfIvHiXeZvE5ZsCgx5uFbAxWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUOEojJKupSOsu0LrEFbhcBb0zc)gsoOlTaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvE5ZYpbXAktrjz9fODb4iG(HLl4cZoj1dlQefDzK3xa8wGg2OzY4bfEZCIhotgj5KrYlNJAt7unmaTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcoe2cSZfIvHiXeZvE5ZsCgx5uFbAxGslWGwWWqKpI65Kmss9WIkb5Ske9xGIkUaCeq)WYf1ZjzKK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLSc9fO8c0UaCeq)WYfCHzNK6HfvIIUmY7laElWoxiwfIetmx5Lpl)eeRPmfLK1BMmEqH3mN4HZKrsozK8Y5O20ovJt0oUzsoRcr)gCBMmEqH3m5cZoj1dlQAMFQJlK(GcVzAa3PfW6laLwWeZDbO(ccFb4)cy)VaRWnCwGkTGN(csrTaOWZPAbtg7lyYOfC5Zl4tqSMgVGlRaYZxq)v0cMmEwGfTGm2oTaYJxE2cUSZlG9)cMmEwWKrfTauFbEmlGHkI)AUaEb1ZPfePfOhwuTGFy5IMjUqdviUzIJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5Lpl)eeRPmfLCI5UaTlqPfyqlah2jN9ryN8jtZAbkQ4cWra9dlxCrvfvxgj5e1L8ru0LrEFbWBb25cXQqKG1Lx(S8tqSMYuuYBmlq5fODbQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YNL9HXkSaTlq9LsI65Kmss9WIkXpS8fODbx2zHoEwa8GTa7CHyvisW6YlYr33vEzNL64PnTt14K0oUzsoRcr)gCBMmEqH3mRNtYij1dlQAMFQJlK(GcVzAa3PfuH(cqPfmXCxaQVGWxa(Va2)lWkCdNfOsl4PVGuulak8CQwWKX(cMmAbx(8c(eeRPXl4YkG88f0FfTGjJkAbOUB4SagQi(R5c4fupNwWpS8fW(FbtgplG1xGv4golqLWXLwaBNrqSkeTG)RqE(cQNtIMjUqdviUzQ(sjbxy2jPEyrL4hw(c0UaLwaocOFy5IjE4mzKKtgjVCosu0LrEFbWBb25cXQqKOcD5Lpl)eeRPmfLCI5UafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwGDUqSkejMyUYlFw(jiwtzkkjRVaLxG2fO(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRWc0UaCeq)WYfCHzNK6HfvIIUmY7laElqdB0M2PAyBBh3mjNvHOFdUntCHgQqCZu9LscUWSts9WIkXpS8fODb4iG(HLl4cZoj1dlQet9izrxg59faVfW4bfUONHsdYZL6Hfvc8VwG2fO(sjr9CsgjPEyrL4hw(c0UaCeq)WYf1ZjzKK6HfvIPEKSOlJ8(cG3cy8Gcx0ZqPb55s9WIkb(xlq7c(K6lLet8WzYijNmsE5CK4hwEZKXdk8MzpdLgKNl1dlQAt7unSjTJBMKZQq0Vb3MjJhu4nt9I6KJjzKKxK)BMFQJlK(GcVzAa3PfOh3fmXc6hKhrh00cyFb05P4fWQla5lyYOf405zb4iG(HLValK)dlJxWZHOEFbkOzHyFbtg5liCinxW)vipFbCHzNwGEyr1c(pAbtSGSWAbx25fK988sZfu8hX(SGUoxkSauVzIl0qfIBMddr(iQNtYij1dlQeKZQq0FbAxG6lLeCHzNK6HfvIN(c0Ua1xkjQNtYij1dlQefDzK3xWHlih)fx(CBANQHnTDCZKCwfI(n42mXfAOcXnZpP(sjXepCMmsYjJKxohjE6lq7c(K6lLet8WzYijNmsE5CKOOlJ8(coCbmEqHl4cZojVOEhbrDbDMWVHKd6slq7cmOfGd7KZ(iuqZcXEZKXdk8MPErDYXKmsYlY)TPDQnGF74Mj5Ske9BWTzIl0qfIBMQVusupNKrsQhwujE6lq7cuFPKOEojJKupSOsu0LrEFbhUGC8xC5Zlq7cWra9dlxq2dmpOWffXFnxG2fGJa6hwUyIhotgj5KrYlNJefDzK3xG2fyqlah2jN9rOGMfI9MjJhu4nt9I6KJjzKKxK)BtBAMCqTJBNQr74Mj5Ske9BWTzIl0qfIBM1ZPuu5K4J6yKoeY5stjoUx2)cYzvi6VaTlahb0pSCH6lLKFuhJ0HqoxAkXX9Y(xue)1CbAxG6lLeFuhJ0HqoxAkXX9Y(xMQOpIFy5lq7cuAbQVusWfMDsQhwuj(HLVaTlq9LsI65Kmss9WIkXpS8fODbFs9LsIjE4mzKKtgjVCos8dlFbkVaTlahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq7cuAbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq7cuAbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cYX)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYlFw(jiwtzkkjRVaLxGIkUaLwGbTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvE5ZYpbXAktrjz9fO8cuuXfGJa6hwUGlm7KupSOsu0LrEFbhcBb54)cuEbk3mz8GcVzMQOpQb00M2P2ODCZKCwfI(n42mXfAOcXntLwq9Ckfvoj(OogPdHCU0uIJ7L9VGCwfI(lq7cWra9dlxO(sj5h1XiDiKZLMsCCVS)ffXFnxG2fO(sjXh1XiDiKZLMsCCVS)LjurIFy5lq7c0lYUmh)fAisv0h1aAwGYlqrfxGslOEoLIkNeFuhJ0HqoxAkXX9Y(xqoRcr)fODbd6sl4WfOXcuUzY4bfEZmHksQcX9PnTtT52XntYzvi63GBZexOHke3mRNtPOYjrEH6qAkryegIeKZQq0FbAxaocOFy5cUWSts9WIkrrxg59faVfyZWFbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbWwa8xG2fO0cuFPKGlm7KeNXvoj6dJvybhcBb25cXQqKGdsoXCLx(SeNXvo1xG2fO0cuAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5I65Kmss9WIkrrxg59fCiSfKJ)lq7cWra9dlxWfMDsQhwujk6YiVVa4Ta7CHyvismXCLx(S8tqSMYuuswFbkVafvCbkTadAbddr(iQNtYij1dlQeKZQq0FbAxaocOFy5cUWSts9WIkrrxg59faVfyNleRcrIjMR8YNLFcI1uMIsY6lq5fOOIlahb0pSCbxy2jPEyrLOOlJ8(coe2cYX)fO8cuUzY4bfEZmvrFKEyNBt7udq74Mj5Ske9BWTzIl0qfIBM1ZPuu5KiVqDinLimcdrcYzvi6VaTlahb0pSCbxy2jPEyrLOOlJ8(cGTa4VaTlqPfO0cuAb4iG(HLlM4HZKrsozK8Y5irrxg59faVfyNleRcrcwxE5ZYpbXAktrjNyUlq7cuFPKGlm7KeNXvoj6dJvybWwG6lLeCHzNK4mUYjXLpl7dJvybkVafvCbkTaCeq)WYft8WzYijNmsE5CKOOlJ8(cGTa4VaTlq9LscUWStsCgx5KOpmwHfCiSfyNleRcrcoi5eZvE5ZsCgx5uFbkVaLxG2fO(sjr9CsgjPEyrL4hw(cuUzY4bfEZmvrFKEyNBt70t0oUzsoRcr)gCBM4cnuH4Mz9Ckfvoj6i9SWL9jQRGCwfI(lq7c0lYUmh)fAii7bMhu4ntgpOWBMt8WzYijNmsE5CuBANEsAh3mjNvHOFdUntCHgQqCZSEoLIkNeDKEw4Y(e1vqoRcr)fODbkTa9ISlZXFHgcYEG5bf(cuuXfOxKDzo(l0qmXdNjJKCYi5LZrlq5MjJhu4ntUWSts9WIQ20o122oUzsoRcr)gCBM4cnuH4M5GU0cG3cSz4VaTlOEoLIkNeDKEw4Y(e1vqoRcr)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq7cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0UaCeq)WYfCHzNK6HfvIIUmY7l4qylih)BMmEqH3mj7bMhu4TPDQnPDCZKCwfI(n42mz8GcVzs2dmpOWBMiFOQE6JeLAMQVus0r6zHl7tuxrFyScWuFPKOJ0Zcx2NOUIlFw2hgRqZe5dv1tFKO7L(iEOMPgntCHgQqCZCqxAbWBb2m8xG2fupNsrLtIosplCzFI6kiNvHO)c0UaCeq)WYfCHzNK6HfvIIUmY7la2cG)c0UaLwGslqPfGJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5Lpl)eeRPmfLCI5UaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNex(SSpmwHfO8cuuXfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwWHWwGDUqSkej4GKtmx5LplXzCLt9fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq520o1M2oUzsoRcr)gCBM4cnuH4MPslahb0pSCbxy2jPEyrLOOlJ8(cG3cmaNybkQ4cWra9dlxWfMDsQhwujk6YiVVGdHTaBEbkVaTlahb0pSCXepCMmsYjJKxohjk6YiVVayla(lq7cuAbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq7cuAbkTGHHiFe1ZjzKK6HfvcYzvi6VaTlahb0pSCr9CsgjPEyrLOOlJ8(coe2cYX)fODb4iG(HLl4cZoj1dlQefDzK3xa8wWjwGYlqrfxGslWGwWWqKpI65Kmss9WIkb5Ske9xG2fGJa6hwUGlm7KupSOsu0LrEFbWBbNybkVafvCb4iG(HLl4cZoj1dlQefDzK3xWHWwqo(VaLxGYntgpOWBMxuvr1LrsorDjFAt7unGF74Mj5Ske9BWTzIl0qfIBM4iG(HLlM4HZKrsozK8Y5irrxg59fC4cOZe(nKCqxAbAxGslq9LscUWStsCgx5KOpmwHfCiSfyNleRcrcoi5eZvE5ZsCgx5uFbAxGslqPfmme5JOEojJKupSOsqoRcr)fODb4iG(HLlQNtYij1dlQefDzK3xWHWwqo(VaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvE5ZYpbXAktrjz9fO8cuuXfO0cmOfmme5JOEojJKupSOsqoRcr)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYlFw(jiwtzkkjRVaLxGIkUaCeq)WYfCHzNK6HfvIIUmY7l4qylih)xGYlq5MjJhu4nZI)i2hzxNlfAt7un0ODCZKCwfI(n42mXfAOcXntCeq)WYfCHzNK6HfvIIUmY7l4WfqNj8Bi5GU0c0UaLwGslqPfGJa6hwUyIhotgj5KrYlNJefDzK3xa8wGDUqSkejyD5Lpl)eeRPmfLCI5UaTlq9LscUWStsCgx5KOpmwHfaBbQVusWfMDsIZ4kNex(SSpmwHfO8cuuXfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7la2cG)c0Ua1xkj4cZojXzCLtI(WyfwWHWwGDUqSkej4GKtmx5LplXzCLt9fO8cuEbAxG6lLe1ZjzKK6HfvIFy5lq5MjJhu4nZI)i2hzxNlfAt7unSr74Mj5Ske9BWTzIl0qfIBM4iG(HLl4cZoj1dlQefDzK3xaSfa)fODbkTaLwGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YlFw(jiwtzkk5eZDbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojU8zzFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq5fO8c0Ua1xkjQNtYij1dlQe)WYxGYntgpOWBMFINm1OCQnTt1WMBh3mjNvHOFdUntCHgQqCZu9LscUWStsCgx5KOpmwHfCiSfyNleRcrcoi5eZvE5ZsCgx5uFbAxGslqPfmme5JOEojJKupSOsqoRcr)fODb4iG(HLlQNtYij1dlQefDzK3xWHWwqo(VaTlahb0pSCbxy2jPEyrLOOlJ8(cG3cSZfIvHiXeZvE5ZYpbXAktrjz9fO8cuuXfO0cmOfmme5JOEojJKupSOsqoRcr)fODb4iG(HLl4cZoj1dlQefDzK3xa8wGDUqSkejMyUYlFw(jiwtzkkjRVaLxGIkUaCeq)WYfCHzNK6HfvIIUmY7l4qylih)xGYntgpOWBMt8WzYijNmsE5CuBANQHbODCZKCwfI(n42mXfAOcXntLwGslahb0pSCXepCMmsYjJKxohjk6YiVVa4Ta7CHyvisW6YlFw(jiwtzkk5eZDbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojU8zzFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq5fO8c0Ua1xkjQNtYij1dlQe)WYBMmEqH3m5cZoj1dlQAt7unor74Mj5Ske9BWTzIl0qfIBMQVusupNKrsQhwuj(HLVaTlqPfO0cWra9dlxmXdNjJKCYi5LZrIIUmY7laElWgWFbAxG6lLeCHzNK4mUYjrFyScla2cuFPKGlm7KeNXvojU8zzFySclq5fOOIlqPfGJa6hwUyIhotgj5KrYlNJefDzK3xaSfa)fODbQVusWfMDsIZ4kNe9HXkSGdHTa7CHyvisWbjNyUYlFwIZ4kN6lq5fO8c0UaLwaocOFy5cUWSts9WIkrrxg59faVfOHnwGIkUGpP(sjXepCMmsYjJKxohjE6lq5MjJhu4nZ65Kmss9WIQ20ovJts74Mj5Ske9BWTzIl0qfIBM4iG(HLl4cZojJsvu0LrEFbWBbNybkQ4cmOfmme5JGlm7Kmkvb5Ske9BMmEqH3m7zO0G8CPEyrvBANQHTTDCZKCwfI(n42mXfAOcXnt1xkj(epzQr5K4PVaTl4tQVusmXdNjJKCYi5LZrIN(c0UGpP(sjXepCMmsYjJKxohjk6YiVVGdHTa1xkj0lQtoMKrsEr(xC5ZY(WyfwWjFbmEqHl4cZojvH4(iOZe(nKCqxAbAxGslqPfmme5JOOE4SJjb5Ske9xG2fW4bzNKKtxe1xWHlWaSaLxGIkUagpi7KKC6IO(coCbNybkVaTlqPfyqlOEoLIkNeCHzNKQXvLR)L8rqoRcr)fOOIly4kNgrgXqtMqhplaElWMpXcuUzY4bfEZuVOo5ysgj5f5)20ovdBs74Mj5Ske9BWTzIl0qfIBMQVus8jEYuJYjXtFbAxGslqPfmme5JOOE4SJjb5Ske9xG2fW4bzNKKtxe1xWHlWaSaLxGIkUagpi7KKC6IO(coCbNybkVaTlqPfyqlOEoLIkNeCHzNKQXvLR)L8rqoRcr)fOOIly4kNgrgXqtMqhplaElWMpXcuUzY4bfEZKlm7KufI7tBANQHnTDCZKXdk8Mz)PtLh25Mj5Ske9BWTnTtTb8Bh3mjNvHOFdUntCHgQqCZu9LscUWStsCgx5KOpmwHfapylqPfW4bzNKKtxe1xGb0fOXcuEbAxq9Ckfvoj4cZojvJRkx)l5JGCwfI(lq7cgUYPrKrm0Kj0XZcoCb28jAMmEqH3m5cZojv5Q4CQnTtTHgTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRqZKXdk8Mjxy2jPkxfNtTPDQnSr74Mj5Ske9BWTzIl0qfIBMQVusWfMDsIZ4kNe9HXkSayla(ntgpOWBMCHzNKrP2M2P2WMBh3mjNvHOFdUntCHgQqCZuPfuuQOEgRcrlqrfxGbTGbHva55lq5fODbQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YNL9HXk0mz8GcVz60KrLCORo1N20o1ggG2XntYzvi63GBZexOHke3mvFPKadrCH5(G8CrrmEwG2fupNsrLtcUWStsKNqoA0uqoRcr)fODbkTaLwWWqKpc(QdHsimpOWfKZQq0FbAxaJhKDssoDruFbhUaBYcuEbkQ4cy8GStsYPlI6l4WfCIfOCZKXdk8Mjxy2j5f17iiQ3M2P24eTJBMKZQq0Vb3MjUqdviUzQ(sjbgI4cZ9b55IIy8SaTlyyiYhbxy2jjHZcb5Ske9xG2f8j1xkjM4HZKrsozK8Y5iXtFbAxGslyyiYhbF1HqjeMhu4cYzvi6VafvCbmEq2jj50fr9fC4cSPlq5MjJhu4ntUWStYlQ3rquVnTtTXjPDCZKCwfI(n42mXfAOcXnt1xkjWqexyUpipxueJNfODbddr(i4RoekHW8GcxqoRcr)fODbmEq2jj50fr9fC4cmantgpOWBMCHzNKxuVJGOEBANAdBB74Mj5Ske9BWTzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdxG6lLeCHzNK4mUYjXLpl7dJvOzY4bfEZKlm7KKoRdfDu4TPDQnSjTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jjoJRCs0hgRWcGTa1xkj4cZojXzCLtIlFw2hgRWc0Ua9ISlZXFHgcUWStsvUkoNAMmEqH3m5cZojPZ6qrhfEBANAdBA74MjYhQQN(irPM5LDwOJh4bZMEIMjYhQQN(ir3l9r8qntnAMmEqH3mj7bMhu4ntYzvi63GBBAtZmJRB4A2oUDQgTJBMKZQq0Vb3MjJhu4ntYEG5bfEZ8tDCH0hu4ntd4oTade7bMhu4laLwGfzyrlakSwq4l4YoVa2)lGxWXXyGHJTFWlWc5)WAbO(cWXf55l4P3mXfAOcXnZl7Sqhpl4qylqJtSaTlahb0pSCXepCMmsYjJKxohjk6YiVVGdHTaLwaDMWVHKd6sl4OfW4bfUyIhotgj5KrYlNJe0zc)gsoOlTaLxG2fGJa6hwUGlm7KupSOsu0LrEFbhcBbkTa6mHFdjh0LwWrlGXdkCXepCMmsYjJKxohjOZe(nKCqxAbhTagpOWfCHzNK6Hfvc6mHFdjh0LwGYlq7cuFPKOEojJKupSOs8dlFbAxG6lLeCHzNK6HfvIFy5lq7c(K6lLet8WzYijNmsE5CK4hw(c0UadAb)yef)rSpYUoxkik6YiV3M2P2ODCZKCwfI(n42mz8GcVzs2dmpOWBMFQJlK(GcVzAa3PfyGypW8GcFbO0cSidlAbqH1ccFbx25fW(Fb8coPXbValK)dRfG6lahxKNVGNEZexOHke3mVSZcD8SGdHTaBg(lq7cWra9dlxupNKrsQhwujk6YiVVGdHTaLwaDMWVHKd6sl4OfW4bfUOEojJKupSOsqNj8Bi5GU0cuEbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbhcBbkTa6mHFdjh0LwWrlGXdkCr9CsgjPEyrLGot43qYbDPfC0cy8Gcxu8hX(i76CPGGot43qYbDPfO8c0UaCeq)WYfCHzNK6HfvIIUmY7laElWaa)20o1MBh3mjNvHOFdUnZp1XfsFqH3mH7db9xGbkUUHR5c6dJvOVGuulyYOfCCmgy4y7h8cSq(pSAM4cnuH4MP6lLeCHzNKzCDdxtrFyScl4WfO(sjbxy2jzgx3W1uC5ZY(WyfwG2fGJa6hwUO4pI9r215sbrrxg59fCiSfO0cSXcoAbkTa6mHFdjh0LwWrlGXdkCrXFe7JSRZLcc6mHFdjh0LwGYlq5fODb4iG(HLlM4HZKrsozK8Y5irrxg59fCiSfO0cSXcoAbkTa6mHFdjh0LwWrlGXdkCrXFe7JSRZLcc6mHFdjh0LwWrlGXdkCXepCMmsYjJKxohjOZe(nKCqxAbkVaLxG2fGJa6hwUGlm7KupSOsu0LrEFbhcBbkTaBSGJwGslGot43qYbDPfC0cy8Gcxu8hX(i76CPGGot43qYbDPfC0cy8GcxmXdNjJKCYi5LZrc6mHFdjh0LwWrlGXdkCbxy2jPEyrLGot43qYbDPfO8cuUzIZyK3m1OzY4bfEZKlm7K8I6Dee1Bt7udq74Mj5Ske9BWTz(PoUq6dk8MjCFiO)cmqX1nCnxqFySc9fKIAbtgTGtACWlWc5)WQzIl0qfIBMQVusWfMDsMX1nCnf9HXkSGdxG6lLeCHzNKzCDdxtXLpl7dJvybAxaocOFy5I65Kmss9WIkrrxg59fCiSfO0cSXcoAbkTa6mHFdjh0LwWrlGXdkCr9CsgjPEyrLGot43qYbDPfO8cuEbAxaocOFy5II)i2hzxNlfefDzK3xWHWwGslWgl4OfO0cOZe(nKCqxAbhTagpOWf1ZjzKK6Hfvc6mHFdjh0LwWrlGXdkCrXFe7JSRZLcc6mHFdjh0LwGYlq5fODb4iG(HLlM4HZKrsozK8Y5irrxg59fCiSfO0cSXcoAbkTa6mHFdjh0LwWrlGXdkCr9CsgjPEyrLGot43qYbDPfC0cy8Gcxu8hX(i76CPGGot43qYbDPfC0cy8GcxmXdNjJKCYi5LZrc6mHFdjh0LwGYlq5fODb4iG(HLl4cZoj1dlQefDzK3BM4mg5ntnAMmEqH3m5cZojVOEhbr920o9eTJBMKZQq0Vb3M5N64cPpOWBMW9HG(lWafx3W1Cb9HXk0xqkQfmz0cCwb6VGtQ5cSq(pSAM4cnuH4MP6lLeCHzNKzCDdxtrFyScl4WfO(sjbxy2jzgx3W1uC5ZY(WyfwG2fGJa6hwUO4pI9r215sbrrxg59fCiSfO0cSXcoAbkTa6mHFdjh0LwWrlGXdkCrXFe7JSRZLcc6mHFdjh0LwGYlq5fODb4iG(HLl4cZoj1dlQefDzK3xa8GTaBg(lq7cWra9dlxupNKrsQhwujk6YiVVa4bBb2m8BM4mg5ntnAMmEqH3m5cZojVOEhbr920o9K0oUzsoRcr)gCBM4cnuH4MP6lLeCHzNKzCDdxtrFyScla2cuFPKGlm7KmJRB4AkU8zzFySclq7cWra9dlxmXdNjJKCYi5LZrIIUmY7l4WfqNj8Bi5GU0c0UaCeq)WYfCHzNK6HfvIIUmY7l4qylqPfqNj8Bi5GU0coAbmEqHlM4HZKrsozK8Y5ibDMWVHKd6slq5fODbx2zHoEwa8wGgNOzY4bfEZS4pI9r215sH20o122oUzsoRcr)gCBM4cnuH4MP6lLeCHzNKzCDdxtrFyScla2cuFPKGlm7KmJRB4AkU8zzFySclq7cWra9dlxWfMDsQhwujk6YiVVGdHTa6mHFdjh0LwG2f8Jru8hX(i76CPGOOlJ8EZKXdk8M5epCMmsYjJKxoh1M2P2K2XntYzvi63GBZexOHke3mvFPKGlm7KmJRB4Ak6dJvybWwG6lLeCHzNKzCDdxtXLpl7dJvybAxWNuFPKyIhotgj5KrYlNJep9fODbQVusupNKrsQhwuj(HL3mz8GcVzYfMDsQhwu1M2P202XntYzvi63GBZexOHke3mvFPKGlm7KmJRB4Ak6dJvybWwG6lLeCHzNKzCDdxtXLpl7dJvybAxaocOFy5IjE4mzKKtgjVCosu0LrEFbhcBbkTa6mHFdjh0LwWrlGXdkCrXFe7JSRZLcc6mHFdjh0LwGYlq7cWra9dlxWfMDsQhwujk6YiVVa4Tada8xG2fCzNf64zbWd2cS5t0mz8GcVzwpNKrsQhwu1M2PAa)2XntYzvi63GBZexOHke3mvFPKGlm7KmJRB4Ak6dJvybWwG6lLeCHzNKzCDdxtXLpl7dJvybAxaocOFy5IjE4mzKKtgjVCosu0LrEFbhUa6mHFdjh0LwG2fO(sjr9CsgjPEyrL4P3mz8GcVzw8hX(i76CPqBANQHgTJBMKZQq0Vb3MjUqdviUzQ(sjbxy2jzgx3W1u0hgRWcGTa1xkj4cZojZ46gUMIlFw2hgRWc0UaCeq)WYfCHzNK6HfvIIUmY7laElWaa)fODbQVusupNKrsQhwujE6lq7c(Xik(JyFKDDUuqu0LrEVzY4bfEZCIhotgj5KrYlNJAt7unSr74Mj5Ske9BWTzIl0qfIBM4iG(HLlM4HZKrsozK8Y5irrxg59faVfOb8xG2fGJa6hwUGlm7KupSOsu0LrEFbWBb2m8xG2fO(sjbxy2jPEyrL4hwEZKXdk8Mz9CsgjPEyrvBANQHn3oUzsoRcr)gCBM4cnuH4MP6lLeCHzNKzCDdxtrFyScla2cuFPKGlm7KmJRB4AkU8zzFySclq7cWra9dlxWfMDsQhwujk6YiVVa4bBb24elq7cWra9dlxupNKrsQhwujk6YiVVa4bBb24elq7cuFPKGlm7KmJRB4Ak6dJvybWwG6lLeCHzNKzCDdxtXLpl7dJvybAxWLDwOJNfapylqJt0mz8GcVzw8hX(i76CPqBANQHbODCZKCwfI(n42mz8GcVzQxuNCmjJK8I8FZ8tDCH0hu4ntd4oTGdomWl4)kKNVaB)Gxqul4Kgh8cSq(pS6lyIfO(qq)fGZ4kN6lGtdvl41rE(cS9cZoTa4YvX5uZexOHke3mvFPKGlm7KeNXvoj6dJvybhUa1xkj4cZojXzCLtIlFw2hgRWc0Ua1xkj4cZojXzCLtI(Wyfwa8wa8xG2fO(sjbxy2jPEyrLOOlJ8(cuuXfO(sjbxy2jjoJRCs0hgRWcoCbQVusWfMDsIZ4kNex(SSpmwHfODbQVusWfMDsIZ4kNe9HXkSa4Ta4VaTlq9LsI65Kmss9WIkrrxg59fODbFs9LsIjE4mzKKtgjVCosu0LrEVnTt14eTJBMKZQq0Vb3MjUqdviUzQ(sjHErDYXKmsYlY)INEZKXdk8Mjxy2jPke3N20ovJts74Mj5Ske9BWTzIl0qfIBMQVusWfMDsIZ4kNe9HXkSGdxGnwG2fO(sjbxy2jPEyrL4P3mz8GcVzYfMDsgLABANQHTTDCZKCwfI(n42mXfAOcXnt1xkj4cZojXzCLtI(WyfwWHlWglq7cmOfO0cWra9dlxWfMDsQhwujk6YiVVGdHTanG)c0UaCeq)WYft8WzYijNmsE5CKOOlJ8(coe2c0a(lq7cWra9dlxu8hX(i76CPGOOlJ8(coe2coXcuUzY4bfEZKlm7Kmk120ovdBs74Mj5Ske9BWTzY4bfEZKlm7K8I6Dee1BM4mg5ntnAM4cnuH4MP6lLeCHzNK4mUYjrFySclaElqJfODbQVusWfMDsMX1nCnf9HXkSGdxG6lLeCHzNKzCDdxtXLpl7dJvOnTt1WM2oUzsoRcr)gCBMmEqH3m5cZojVOEhbr9MjoJrEZuJMjUqdviUzIJa6hwUGlm7Kmkvrrxg59fC4cmalq7cuFPKGlm7KmJRB4Ak6dJvybhUa1xkj4cZojZ46gUMIlFw2hgRqBANAd43oUzsoRcr)gCBM4cnuH4M5NuFPKO4pI9r215sbP9hKtfRIGqJMI(WyfwaSfyaAMmEqH3m5cZojv5Q4CQnTtTHgTJBMKZQq0Vb3MjUqdviUz(Jru8hX(i76CPGOOlJ8(c0UGpP(sjXepCMmsYjJKxohjk6YiVVa4Ta6mHFdjh0LwG2fO0c(K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRWcGTa4VafvCbFs9LsII)i2hzxNlfK2FqovSkccnAk6dJvybhUadWcuUzY4bfEZKlm7KufI7tBANAdB0oUzsoRcr)gCBM4cnuH4M5pgrXFe7JSRZLcIIUmY7laEl4elq7c(K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRWcGTa4VaTlq9LsI65Kmss9WIkXpS8MjJhu4ntUWStYOuBt7uByZTJBMKZQq0Vb3MjUqdviUz(Jru8hX(i76CPGOOlJ8(cG3cOZe(nKCqxAbAxWNuFPKO4pI9r215sbP9hKtfRIGqJMI(Wyfwa8wa8xG2f8j1xkjk(JyFKDDUuqA)b5uXQii0OPOpmwHfC4cmalq7cuFPKOEojJKupSOs8dlVzY4bfEZKlm7KufI7tBANAddq74Mj5Ske9BWTzIl0qfIBMQVusWfMDsIZ4kNe9HXkSaylq9LscUWStsCgx5K4YNL9HXkSaTlq9LscUWStYmUUHRPOpmwHfaBbQVusWfMDsMX1nCnfx(SSpmwHMjJhu4ntUWStsvUkoNAt7uBCI2XntYzvi63GBZexOHke3mVSZcD8SGdxGgNOzY4bfEZKShyEqH3M2P24K0oUzsoRcr)gCBMmEqH3m5cZojvH4(0m)uhxi9bfEZ8GkJ8fOsJfr(cWra9dlFbwi)hwDJxGfTGWH0CbQpe0FbtSG0dcAb4mUYP(c40q1cEDKNVaBVWStlWaDP2mXfAOcXnt1xkj4cZojXzCLtI(Wyfwa8wGgTPDQnSTTJBMKZQq0Vb3MjJhu4ntUWStsvUkoNAMFQJlK(GcVzEYUx6J4HG0CbDDY)lWafx3W1Cb9HXk0xGvg5lqLglI8fGJa6hw(cSq(pS6ntCHgQqCZu9LscUWStYmUUHRPOpmwHfaVfa)fODbg0cuAb4iG(HLl4cZoj1dlQefDzK3xWHWwGgWFbAxaocOFy5IjE4mzKKtgjVCosu0LrEFbhcBbAa)fODb4iG(HLlk(JyFKDDUuqu0LrEFbhcBbNybk3M2P2WM0oUzsoRcr)gCBM4mg5ntnAMmEqH3m5cZojVOEhbr920MMzc5mKu9vE742PA0oUzsoRcr)gCBMmEqH3m5cZojVOEhbr9MjoJrEZuJMjUqdviUzQ(sjbgI4cZ9b55IIy80M2P2ODCZKXdk8Mjxy2jPke3NMj5Ske9BWTnTtT52XntgpOWBMCHzNKQCvCo1mjNvHOFdUTPnTPzANQok82P2a(2qd4BZAa)MPfxoYZ7nZdkB)KE6j7udiT1fSGJZOfGU6rnlif1cmmH6zipxg6KtLHlOOdYdv0Fb94slGFtC5H(laNXEo1fRr2cYPfOHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjBCwzXAKTGCAb2WwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsACwzXAKTGCAb2STUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTadGTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTGtyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtl4e26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaEwGbIbABzbkPXzLfRr2cYPfOb8T1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkzJZklwJSfKtlqJtyRlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjnoRSynYwqoTanSj26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50c0WMyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4c4zbgigOTLfOKgNvwSgzliNwGg2uBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxGsACwzXAKTGCAb2qdBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPXzLfRrRrhu2(j90t2PgqARlybhNrlaD1JAwqkQfyyOtovgUGIoipur)f0JlTa(nXLh6VaCg75uxSgzliNwGg26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTanGVTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL04SYI1iBb50c0WMT1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCb8Saded02YcusJZklwJSfKtlqddGTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlGNfyGyG2wwGsACwzXAKTGCAbACcBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPXzLfRrRrhu2(j90t2PgqARlybhNrlaD1JAwqkQfyyfdpOWnCbfDqEOI(lOhxAb8BIlp0Fb4m2ZPUynYwqoTanS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwGnS1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPXzLfRr2cYPfyaS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwWjS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwGn1wxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsACwzXAKTGCAbAytT1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwGnGVTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTaBOHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTaByZ26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSHbWwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKgNvwSgTgDqz7N0tpzNAaPTUGfCCgTa0vpQzbPOwGHFkXpOXWfu0b5Hk6VGECPfWVjU8q)fGZypN6I1iBb50cSHTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjBCwzXAKTGCAb2STUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjBCwzXAKTGCAbgaBDbgC42PAO)cmrxdEbDn9HpVadiUGjwGT84f8r2rDu4li0PINOwGsWr5fOKgNvwSgzliNwWjS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTaBRTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTanST26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50c0WMARlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtlWgAyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtlWg2STUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL04SYI1iBb50cSHnBRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtlWg2STUadoC7un0FbgId))qJ4agUGjwGH4W)p0ioGGCwfI(gUaEwGbIbABzbkPXzLfRrRrhu2(j90t2PgqARlybhNrlaD1JAwqkQfyOEr44QYJHlOOdYdv0Fb94slGFtC5H(laNXEo1fRr2cYPfCsS1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPXzLfRr2cYPfOHT1wxGbhUDQg6VadXH)FOrCadxWelWqC4)hAehqqoRcrFdxGsACwzXAKTGCAbAytS1fyWHBNQH(lWqC4)hAehWWfmXcmeh()HgXbeKZQq03WfOKgNvwSgzliNwGg2uBDbgC42PAO)cmeh()HgXbmCbtSadXH)FOrCab5Ske9nCbkPXzLfRr2cYPfyJtITUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSXzLfRr2cYPfyJtITUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTaBwdBDbgC42PAO)cmSEoLIkNehWWfmXcmSEoLIkNehqqoRcrFdxaplWaXaTTSaL04SYI1iBb50cSzByRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4c4zbgigOTLfOKgNvwSgTgDqz7N0tpzNAaPTUGfCCgTa0vpQzbPOwGH4iG(HL3nCbfDqEOI(lOhxAb8BIlp0Fb4m2ZPUynYwqoTanS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTanS1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPXzLfRr2cYPfydBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkzJZklwJSfKtlWg26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSzBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkzJZklwJSfKtlWMT1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPXzLfRr2cYPfyaS1fyWHBNQH(lWW65ukQCsCadxWelWW65ukQCsCab5Ske9nCbkPXzLfRr2cYPfCsS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTaBITUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaLSXzLfRr2cYPfytT1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTan0WwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGs24SYI1iBb50c0WMT1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwGggaBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPXzLfRr2cYPfOHnXwxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGsACwzXA0A0bLTFsp9KDQbK26cwWXz0cqx9OMfKIAbgYbz4ck6G8qf9xqpU0c43exEO)cWzSNtDXAKTGCAbAyRlWGd3ovd9xGHddr(ioGHlyIfy4WqKpIdiiNvHOVHlqjBCwzXAKTGCAbAyRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtlWg26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaLSXzLfRr2cYPfyZ26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cuYgNvwSgzliNwGnBRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtlWayRlWGd3ovd9xGH1ZPuu5K4agUGjwGH1ZPuu5K4acYzvi6B4cusJZklwJSfKtl4e26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50coj26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cST26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSj26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSP26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4cuYgNvwSgzliNwGgW3wxGbhUDQg6VadhgI8rCadxWelWWHHiFehqqoRcrFdxGs24SYI1iBb50c0WMT1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTanoj26cm4WTt1q)fy4WqKpIdy4cMybgome5J4acYzvi6B4c4zbgigOTLfOKgNvwSgzliNwGg2wBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPXzLfRr2cYPfOHT1wxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKgNvwSgzliNwGg2eBDbgC42PAO)cmCyiYhXbmCbtSadhgI8rCab5Ske9nCbkPXzLfRr2cYPfOHnXwxGbhUDQg6VadRNtPOYjXbmCbtSadRNtPOYjXbeKZQq03WfOKgNvwSgzliNwGnGVTUadoC7un0FbgwpNsrLtIdy4cMybgwpNsrLtIdiiNvHOVHlqjnoRSynYwqoTaByaS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgzliNwGnma26cm4WTt1q)fyy9CkfvojoGHlyIfyy9CkfvojoGGCwfI(gUaL04SYI1iBb50cSXjS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKnoRSynYwqoTaBCsS1fyWHBNQH(lWWHHiFehWWfmXcmCyiYhXbeKZQq03WfOKgNvwSgTgDqz7N0tpzNAaPTUGfCCgTa0vpQzbPOwGH8v215RHlOOdYdv0Fb94slGFtC5H(laNXEo1fRr2cYPfOHTUadoC7un0Fbgome5J4agUGjwGHddr(ioGGCwfI(gUaL04SYI1O1Ot2vpQH(lqdnwaJhu4lac1NUynQzYVjlQMPj6(G4bfUbxCAAM6vKqquZ02yBwGbMZPfy7fMDAnY2yBwGbMlC2c0W2A8cSb8THgRrRr2gBZcoP0nStlWoxiwfIe8v2157cq(csS9OwqKwqNMb55DbFLDD(UaLWzewHfOz8Qf01j8cc9bfExzXAKTX2Sad4oTGrtDeMHwGj6AWliJ9peYZxqKwaoJDNGwaYhQQN(GcFbiVpe)xqKwGHy2XeKKXdkCdfRrRrmEqH3f6fHJRkphbdoCHzNKiFiiicpRrmEqH3f6fHJRkphbdoCHzNKj(IGqCTgX4bfExOxeoUQ8Cem4Gd3acVIKx2zzoDxJy8GcVl0lchxvEocgCSZfIvHiJD(sW4RSRZxJdDyf1PX4pL4h0aRtZG88UGVYUoFxJy8GcVl0lchxvEocgCSZfIvHiJD(sWi7Huhpgh6WkQtJXFkXpObMgNynIXdk8UqViCCv55iyWXoxiwfIm25lbtVi9heKKShgh6W60ymkbtP65ukQCs0r6zHl7tuxTmEq2jj50frD4PXrkPXjxjdch2jN9r4eUcOO(kRSYgBNHEemnm2od9ijb1jyWFnIXdk8UqViCCv55iyWXoxiwfIm25lblJTtYqNC6BCOdRtJXOemLy8GStsYPlI6WZgkQODUqSkej0ls)bbjj7bmnuur7CHyvisWxzxNVW0qzJTZqpcMggBNHEKKG6em4VgX4bfExOxeoUQ8Cem4yNleRcrg78LGLqodjvFLBCOdRtJX2zOhbd(RrmEqH3f6fHJRkphbdo25cXQqKXoFjyvxE5ZYpbXAktrjNyUgh6WkQtJXFkXpOb2jwJy8GcVl0lchxvEocgCSZfIvHiJD(sWQU8YNLFcI1uMIswHUXHoSI60y8Ns8dAGDI1igpOW7c9IWXvLNJGbh7CHyviYyNVeSQlV8z5NGynLPOKSUXHoSI60y8Ns8dAGzd4VgX4bfExOxeoUQ8Cem4yNleRcrg78LGDJrQxeMOVCI5kv104qhwrDAm(tj(bnWS51igpOW7c9IWXvLNJGbh7CHyviYyNVeSBmYlFw(jiwtzkk5eZ14qhwrDAm(tj(bnW0a(RrmEqH3f6fHJRkphbdo25cXQqKXoFjy3yKx(S8tqSMYuusw34qhwrDAm(tj(bnW04eRrmEqH3f6fHJRkphbdo25cXQqKXoFjySU8YNLFcI1uMIsoXCno0HvuNgJ)uIFqdmnG)AeJhu4DHEr44QYZrWGJDUqSkezSZxcgRlV8z5NGynLPOK3ymo0HvuNgJ)uIFqdmBa)1igpOW7c9IWXvLNJGbh7CHyviYyNVeSk0Lx(S8tqSMYuuYjMRXHoSongBNHEemBaFdOkDItoo8)dncUWSts9k(OCnvEnIXdk8UqViCCv55iyWXoxiwfIm25lbBI5kV8z5NGynLPOKSUXHoSongJsWuch2jN9r4O8SrMysrfvch()Hgbxy2jPEfFuUMAz8GStsYPlI6hAZkRSX2zOhbtJtySDg6rscQtWoXAeJhu4DHEr44QYZrWGJDUqSkezSZxc2eZvE5ZYpbXAktrjRq34qhwNgJTZqpcMnGVbuLSjNCC4)hAeCHzNK6v8r5AQ8AeJhu4DHEr44QYZrWGJDUqSkezSZxcMkxfNtYl7Suhpgh6W60ymkbdh2jN9r4O8SrMyYy7m0JGDsGVbuLUCFOstPDg6rNCnGp8vEnIXdk8UqViCCv55iyWXoxiwfIm25lbtLRIZj5LDwQJhJdDyDAmgLGHd7KZ(iuqZcXUX2zOhbZMEcdOkD5(qLMs7m0Jo5AaF4R8AeJhu4DHEr44QYZrWGJDUqSkezSZxcMkxfNtYl7Suhpgh6W60ymkbZoxiwfIeQCvCojVSZsD8ad(gBNHEemBc8nGQ0L7dvAkTZqp6KRb8HVYRrmEqH3f6fHJRkphbdo25cXQqKXoFjySU8IC09DLx2zPoEmo0HvuNgJ)uIFqdmnoXAeJhu4DHEr44QYZrWGJDUqSkezSZxc2eZvE5ZsCgx5u34qhwrDAm(tj(bnWSXAeJhu4DHEr44QYZrWGJDUqSkezSZxcghKCI5kV8zjoJRCQBCOdROong)Pe)Ggy2ynIXdk8UqViCCv55iyWXoxiwfIm25lblH6zipxg6KtLXHoSongBNHEemno5krhKhsxN(c6QRzrmKmQVZoMuurLggI8rupNKrsQhwuPvPHHiFeCHzNKeoluurdch2jN9rOGMfIDL1QKbHd7KZ(iCcxbuuFfvKXdYojjNUiQdtdfvSEoLIkNeDKEw4Y(e1vzLvEnIXdk8UqViCCv55iyWXoxiwfIm25lbJ1LHlFDY4qhwNgJTZqpcgDqEiDD6lUmMvls2ZiAK3xhHvur6G8q660xKdXFepr1LQ8pNuur6G8q660xKdXFepr1Lx6ZqqOWvur6G8q660x85sHBeU8tyfK6VPOoMCmPOI0b5H01PVa5DC9gwfIKhKh7Z7k)KDeMuur6G8q660x0JheendYZL1tvtfvKoipKUo9f9NRcfXxYxAY0SpkQiDqEiDD6lSyfiNQUmvH)vur6G8q660xKG4ljJKuLNbIwJy8GcVl0lchxvEocgCSZfIvHiJD(sW4GKtmx5LplXzCLtDJdDyf1PX4pL4h0aZgRrmEqH3f6fHJRkphbdo25cXQqKXoFjyK9qQJhJdDyf1PX4pL4h0atJtSgX4bfExOxeoUQ8Cem4CrvfLeD5CAnIXdk8UqViCCv55iyWjvrFudOXyucMbzNleRcrc9I0FqqsYEatdT1ZPuu5K4J6yKoeY5stjoUx2)RrmEqH3f6fHJRkphbdoCHzNKQqCFmgLGzq25cXQqKqVi9heKKShW0qRbvpNsrLtIpQJr6qiNlnL44Ez)VgX4bfExOxeoUQ8Cem4q2dmpOWngLGzNleRcrc9I0FqqsYEatJ1O1igpOW7hbdo445dvDDccAnIXdk8(rWGJDUqSkezSZxcwgBNKHo5034qhwNgJTZqpcMggJsWSZfIvHirgBNKHo50hg81QxKDzo(l0qq2dmpOW1AqkvpNsrLtIosplCzFI6QOI1ZPuu5KyOREumK0IlDLxJy8GcVFem4yNleRcrg78LGLX2jzOto9no0H1PXy7m0JGPHXOem7CHyvisKX2jzOto9HbFTQVusWfMDsQhwuj(HLRfhb0pSCbxy2jPEyrLOOlJ8UwLQNtPOYjrhPNfUSprDvuX65ukQCsm0vpkgsAXLUYRrmEqH3pcgCSZfIvHiJD(sWsiNHKQVYno0H1PXy7m0JGPHXOem1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(Wyf0AqQVusupisgj5Kve1fpDTQrVRnHYZgzrxg59dHPKsx2zdiY4bfUGlm7KufI7Jah9r5toJhu4cUWStsviUpc6mHFdjh0LuEnIXdk8(rWGZRtYl7SmNUgJsWuAyiYhb5qO8SHC6R9Yol0XZHWSjWx7LDwOJh4b7KCcLvurLmOHHiFeKdHYZgYPV2l7SqhphcZMCcLxJy8GcVFem4OhdkCJrjyQVusWfMDsQhwujE6RrmEqH3pcgCg0LKwCPBmkbREoLIkNedD1JIHKwCPRv9Lsc6Cg)6dkCXtxRs4iG(HLl4cZoj1dlQefXFnvur1O31Mq5zJSOlJ8(HWmaWx51igpOW7hbdoqO8SPlnGW7NFjFmgLGP(sjbxy2jPEyrL4hwUw1xkjQNtYij1dlQe)WY1(j1xkjM4HZKrsozK8Y5iXpS81igpOW7hbdoQCUmsYPqyf6gJsWuFPKGlm7KupSOs8dlxR6lLe1ZjzKK6HfvIFy5A)K6lLet8WzYijNmsE5CK4hw(AeJhu49JGbhvQ6uPaYZngLGP(sjbxy2jPEyrL4PVgX4bfE)iyWrfkIVm9knngLGP(sjbxy2jPEyrL4PVgX4bfE)iyWjHksfkIVXOem1xkj4cZoj1dlQep91igpOW7hbdoSJP(umKeZqqgJsWuFPKGlm7KupSOs80xJy8GcVFem486Ken0TBmkbt9LscUWSts9WIkXtFnIXdk8(rWGZRts0qxJPuIWJ05lblhI)iEIQlv5Fozmkbt9LscUWSts9WIkXtxrfXra9dlxWfMDsQhwujk6YiVdpyN4eA)K6lLet8WzYijNmsE5CK4PVgX4bfE)iyW51jjAORXoFjy0vxZIyizuFNDmzmkbdhb0pSCbxy2jPEyrLOOlJ8(HWusdB(iB7j3oxiwfIeSUmC5RtkVgX4bfE)iyW51jjAORXoFjy)I4FcvK0o17eKXOemCeq)WYfCHzNK6HfvIIUmY7WdMnGVIkAq25cXQqKG1LHlFDcMgkQOsd6sWGVw7CHyvisKq9mKNldDYPcMgARNtPOYjrhPNfUSprDvEnIXdk8(rWGZRts0qxJD(sW6XdsIYD0qLXOemCeq)WYfCHzNK6HfvIIUmY7WdMndFfv0GSZfIvHibRldx(6emnwJy8GcVFem486Ken01yNVeSCin1ZKrsY9o6IG4bfUXOemCeq)WYfCHzNK6HfvIIUmY7WdMnGVIkAq25cXQqKG1LHlFDcMgkQOsd6sWGVw7CHyvisKq9mKNldDYPcMgARNtPOYjrhPNfUSprDvEnIXdk8(rWGZRts0qxJD(sWUmMvls2ZiAK3xhHngLGHJa6hwUGlm7KupSOsu0LrE)qyNqRsgKDUqSkejsOEgYZLHo5ubtdfvCqxcE2m8vEnIXdk8(rWGZRts0qxJD(sWUmMvls2ZiAK3xhHngLGHJa6hwUGlm7KupSOsu0LrE)qyNqRDUqSkejsOEgYZLHo5ubtdTQVusupNKrsQhwujE6AvFPKOEojJKupSOsu0LrE)qykPb8nGEItE9Ckfvoj6i9SWL9jQRYAh0Lo0MH)AeJhu49JGbhmdbjz8GcxcH6JXoFjyCqg3NcHhyAymkbJXdYojjNUiQdpBSgX4bfE)iyWbZqqsgpOWLqO(ySZxcwgx3W104(ui8atdJrjy4Wo5Spcf0SqSRTEoLIkNeCHzNKipHC0OP2HHiFe1ZjzKK6HfvAniC4)hAeCHzNK6v8r5AUgzBwWXz0csOEgYZxqOtovlqLYrEFbwOjBbN04Gxa7)fKq9mQVGuulWGn4fOxbUVGjwWRtl4)kKNVGJJXadhB)GxJy8GcVFem4GziijJhu4siuFm25lblH6zipxg6KtLX9Pq4bMggJsWSZfIvHirgBNKHo50hg81ANleRcrIeQNH8CzOtovRrmEqH3pcgCWmeKKXdkCjeQpg78LGf6KtLX9Pq4bMggJsWSZfIvHirgBNKHo50hg8xJy8GcVFem4GziijJhu4siuFm25lbJVYUoFnUpfcpW0WyucwNMb55DbFLDD(ctJ1igpOW7hbdoygcsY4bfUec1hJD(sWWra9dlVVgX4bfE)iyWbZqqsgpOWLqO(ySZxcwfdpOWnUpfcpW0WyucMDUqSkejsiNHKQVYHb)1igpOW7hbdoygcsY4bfUec1hJD(sWsiNHKQVYnUpfcpW0WyucMDUqSkejsiNHKQVYHPXAeJhu49JGbhmdbjz8GcxcH6JXoFjy3WoDjFwJwJSnlGXdk8UGVYUoFHHzhtqsgpOWngLGX4bfUGShyEqHlWzS7eeYZ1EzNf64bEWSPNynIXdk8UGVYUoFpcgCi7bMhu4gJsWUSZcD8Cim7CHyvisq2dPoE0QeocOFy5IjE4mzKKtgjVCosu0LrE)qymEqHli7bMhu4c6mHFdjh0LuurCeq)WYfCHzNK6HfvIIUmY7hcJXdkCbzpW8GcxqNj8Bi5GUKIkQ0WqKpI65Kmss9WIkT4iG(HLlQNtYij1dlQefDzK3pegJhu4cYEG5bfUGot43qYbDjLvwR6lLe1ZjzKK6HfvIFy5AvFPKGlm7KupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WYxJy8GcVl4RSRZ3JGbNpXtMAuozmkbdhb0pSCbxy2jPEyrLOOlJ8om4Rvj1xkjQNtYij1dlQe)WY1QeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjMRIkIJa6hwUyIhotgj5KrYlNJefDzK3HbFLvEnIXdk8UGVYUoFpcgCUOQIQlJKCI6s(ymkbdhb0pSCbxy2jPEyrLOOlJ8om4Rvj1xkjQNtYij1dlQe)WY1QeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjMRIkIJa6hwUyIhotgj5KrYlNJefDzK3HbFLvEnIXdk8UGVYUoFpcgCk(JyFKDDUuynIXdk8UGVYUoFpcgC6zO0G8CPEyrLXOem1xkj4cZoj1dlQe)WY1IJa6hwUGlm7KupSOsm1JKfDzK3HhJhu4IEgknipxQhwujW)sR6lLe1ZjzKK6HfvIFy5AXra9dlxupNKrsQhwujM6rYIUmY7WJXdkCrpdLgKNl1dlQe4FP9tQVusmXdNjJKCYi5LZrIFy5RrmEqH3f8v2157rWGt9CsgjPEyrLXOem1xkjQNtYij1dlQe)WY1IJa6hwUGlm7KupSOsu0LrEFnIXdk8UGVYUoFpcgCM4HZKrsozK8Y5iJrjykHJa6hwUGlm7KupSOsu0LrEhg81Q(sjr9CsgjPEyrL4hwUYkQOEr2L54Vqdr9CsgjPEyr1AeJhu4DbFLDD(Eem4mXdNjJKCYi5LZrgJsWWra9dlxWfMDsQhwujk6YiVF4jGVw1xkjQNtYij1dlQe)WY1s9o5ysyh1rHlJKuNQeHhu4cYzvi6VgX4bfExWxzxNVhbdoCHzNK6HfvgJsWuFPKOEojJKupSOs8dlxlocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjM7AeJhu4DbFLDD(Eem4WfMDsQYvX5KXOem1xkj4cZoj1dlQepDTQVusWfMDsQhwujk6YiVFimgpOWfCHzNKxuVJGOUGot43qYbDjTQVusWfMDsIZ4kNe9HXkat9LscUWStsCgx5K4YNL9HXkSgX4bfExWxzxNVhbdoCHzNKrPAmkbt9LscUWStsCgx5KOpmwHdvFPKGlm7KeNXvojU8zzFyScAvFPKOEojJKupSOs8dlxR6lLeCHzNK6HfvIFy5A)K6lLet8WzYijNmsE5CK4hw(AeJhu4DbFLDD(Eem4WfMDsQYvX5KXOem1xkjQNtYij1dlQe)WY1Q(sjbxy2jPEyrL4hwU2pP(sjXepCMmsYjJKxohj(HLRv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNex(SSpmwH1igpOW7c(k7689iyWHlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8ymoJromnmM4cstjoJrUeLGP(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvu9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnvEnIXdk8UGVYUoFpcgC4cZojVOEhbrDJrjygeFqtfAibxy2jP(7EjiKNliNvHOVIkQ(sjbgI4cZ9b55sCg7obj(HLBmoJromnmM4cstjoJrUeLGP(sjbgI4cZ9b55sCg7obj(HLRvj1xkj4cZoj1dlQepDfvu9LsI65Kmss9WIkXtxrfXra9dlxq2dmpOWffXFnvEnIXdk8UGVYUoFpcgCi7bMhu4gJsWuFPKOEojJKupSOs8dlxR6lLeCHzNK6HfvIFy5A)K6lLet8WzYijNmsE5CK4hw(AeJhu4DbFLDD(Eem4WfMDsgLQXOem1xkj4cZojXzCLtI(Wyfou9LscUWStsCgx5K4YNL9HXkSgX4bfExWxzxNVhbdoCHzNKQCvCoTgX4bfExWxzxNVhbdoCHzNKQqCFwJwJy8GcVl4GGLQOpQb0ymkbREoLIkNeFuhJ0HqoxAkXX9Y(xlocOFy5c1xkj)OogPdHCU0uIJ7L9VOi(RPw1xkj(OogPdHCU0uIJ7L9VmvrFe)WY1QK6lLeCHzNK6HfvIFy5AvFPKOEojJKupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WYvwlocOFy5IjE4mzKKtgjVCosu0LrEhg81QK6lLeCHzNK4mUYjrFySchcZoxiwfIeCqYjMR8YNL4mUYPUwLuAyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hclh)1IJa6hwUGlm7KupSOsu0LrEhE25cXQqKyI5kV8z5NGynLPOKSUYkQOsg0WqKpI65Kmss9WIkT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYlFw(jiwtzkkjRRSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExWbDem4KqfjvH4(ymkbtP65ukQCs8rDmshc5CPPeh3l7FT4iG(HLluFPK8J6yKoeY5stjoUx2)II4VMAvFPK4J6yKoeY5stjoUx2)YeQiXpSCT6fzxMJ)cnePk6JAankROIkvpNsrLtIpQJr6qiNlnL44Ez)RDqx6qnuEnIXdk8UGd6iyWjvrFKEyNngLGvpNsrLtI8c1H0uIWimePfhb0pSCbxy2jPEyrLOOlJ8o8Sz4Rfhb0pSCXepCMmsYjJKxohjk6YiVdd(Avs9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvE5ZsCgx5uxRsknme5JOEojJKupSOslocOFy5I65Kmss9WIkrrxg59dHLJ)AXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLx(S8tqSMYuuswxzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5Lpl)eeRPmfLK1vwrfXra9dlxWfMDsQhwujk6YiVFiSC8xzLxJy8GcVl4GocgCsv0hPh2zJrjy1ZPuu5KiVqDinLimcdrAXra9dlxWfMDsQhwujk6YiVdd(AvsjLWra9dlxmXdNjJKCYi5LZrIIUmY7WZoxiwfIeSU8YNLFcI1uMIsoXC1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIlFw2hgRGYkQOs4iG(HLlM4HZKrsozK8Y5irrxg5DyWxR6lLeCHzNK4mUYjrFySchcZoxiwfIeCqYjMR8YNL4mUYPUYkRv9LsI65Kmss9WIkXpSCLxJy8GcVl4GocgCM4HZKrsozK8Y5iJrjy1ZPuu5KOJ0Zcx2NOUA1lYUmh)fAii7bMhu4RrmEqH3fCqhbdoCHzNK6HfvgJsWQNtPOYjrhPNfUSprD1QKEr2L54VqdbzpW8Gcxrf1lYUmh)fAiM4HZKrsozK8Y5iLxJy8GcVl4GocgCi7bMhu4gJsWg0LGNndFT1ZPuu5KOJ0Zcx2NOUAvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLx(SeNXvo11IJa6hwUyIhotgj5KrYlNJefDzK3HbFT4iG(HLl4cZoj1dlQefDzK3pewo(VgX4bfExWbDem4q2dmpOWngLGnOlbpBg(ARNtPOYjrhPNfUSprD1IJa6hwUGlm7KupSOsu0LrEhg81QKskHJa6hwUyIhotgj5KrYlNJefDzK3HNDUqSkejyD5Lpl)eeRPmfLCI5Qv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNex(SSpmwbLvurLWra9dlxmXdNjJKCYi5LZrIIUmY7WGVw1xkj4cZojXzCLtI(WyfoeMDUqSkej4GKtmx5LplXzCLtDLvwR6lLe1ZjzKK6HfvIFy5kBmYhQQN(irjyQVus0r6zHl7tuxrFyScWuFPKOJ0Zcx2NOUIlFw2hgRGXiFOQE6JeDV0hXdbtJ1igpOW7coOJGbNlQQO6YijNOUKpgJsWuchb0pSCbxy2jPEyrLOOlJ8o8maNqrfXra9dlxWfMDsQhwujk6YiVFimBwzT4iG(HLlM4HZKrsozK8Y5irrxg5DyWxRsQVusWfMDsIZ4kNe9HXkCim7CHyvisWbjNyUYlFwIZ4kN6AvsPHHiFe1ZjzKK6HfvAXra9dlxupNKrsQhwujk6YiVFiSC8xlocOFy5cUWSts9WIkrrxg5D4DcLvurLmOHHiFe1ZjzKK6HfvAXra9dlxWfMDsQhwujk6YiVdVtOSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExWbDem4u8hX(i76CPGXOemCeq)WYft8WzYijNmsE5CKOOlJ8(H0zc)gsoOlPvj1xkj4cZojXzCLtI(WyfoeMDUqSkej4GKtmx5LplXzCLtDTkP0WqKpI65Kmss9WIkT4iG(HLlQNtYij1dlQefDzK3pewo(Rfhb0pSCbxy2jPEyrLOOlJ8o8SZfIvHiXeZvE5ZYpbXAktrjzDLvurLmOHHiFe1ZjzKK6HfvAXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLx(S8tqSMYuuswxzfvehb0pSCbxy2jPEyrLOOlJ8(HWYXFLvEnIXdk8UGd6iyWP4pI9r215sbJrjy4iG(HLl4cZoj1dlQefDzK3pKot43qYbDjTkPKs4iG(HLlM4HZKrsozK8Y5irrxg5D4zNleRcrcwxE5ZYpbXAktrjNyUAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqzfvujCeq)WYft8WzYijNmsE5CKOOlJ8om4Rv9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvE5ZsCgx5uxzL1Q(sjr9CsgjPEyrL4hwUYRrmEqH3fCqhbdoFINm1OCYyucgocOFy5cUWSts9WIkrrxg5DyWxRskPeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjMRw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLx(SeNXvo1vwzTQVusupNKrsQhwuj(HLR8AeJhu4Dbh0rWGZepCMmsYjJKxohzmkbt9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvE5ZsCgx5uxRsknme5JOEojJKupSOslocOFy5I65Kmss9WIkrrxg59dHLJ)AXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLx(S8tqSMYuuswxzfvujdAyiYhr9CsgjPEyrLwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5Lpl)eeRPmfLK1vwrfXra9dlxWfMDsQhwujk6YiVFiSC8x51igpOW7coOJGbhUWSts9WIkJrjykPeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjMRw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJv4qy25cXQqKGdsoXCLx(SeNXvo1vwzTQVusupNKrsQhwuj(HLVgX4bfExWbDem4upNKrsQhwuzmkbt9LsI65Kmss9WIkXpSCTkPeocOFy5IjE4mzKKtgjVCosu0LrEhE2a(AvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqzfvujCeq)WYft8WzYijNmsE5CKOOlJ8om4Rv9LscUWStsCgx5KOpmwHdHzNleRcrcoi5eZvE5ZsCgx5uxzL1QeocOFy5cUWSts9WIkrrxg5D4PHnuuXpP(sjXepCMmsYjJKxohjE6kVgX4bfExWbDem40ZqPb55s9WIkJrjy4iG(HLl4cZojJsvu0LrEhENqrfnOHHiFeCHzNKrPUgX4bfExWbDem4OxuNCmjJK8I8VXOem1xkj(epzQr5K4PR9tQVusmXdNjJKCYi5LZrINU2pP(sjXepCMmsYjJKxohjk6YiVFim1xkj0lQtoMKrsEr(xC5ZY(Wyfo5mEqHl4cZojvH4(iOZe(nKCqxsRsknme5JOOE4SJjTmEq2jj50fr9dnakROImEq2jj50fr9dpHYAvYGQNtPOYjbxy2jPACv56FjFuuXHRCAezednzcD8apB(ekVgX4bfExWbDem4WfMDsQcX9XyucM6lLeFINm1OCs801QKsddr(ikQho7yslJhKDssoDru)qdGYkQiJhKDssoDru)WtOSwLmO65ukQCsWfMDsQgxvU(xYhfvC4kNgrgXqtMqhpWZMpHYRrmEqH3fCqhbdo9NovEyNxJy8GcVl4GocgC4cZojv5Q4CYyucM6lLeCHzNK4mUYjrFyScWdMsmEq2jj50frDdOAOS265ukQCsWfMDsQgxvU(xYhTdx50iYigAYe645qB(eRrmEqH3fCqhbdoCHzNKQCvCozmkbt9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNex(SSpmwH1igpOW7coOJGbhUWStYOungLGP(sjbxy2jjoJRCs0hgRam4VgX4bfExWbDem440KrLCORo1hJrjykvuQOEgRcrkQObniScipxzTQVusWfMDsIZ4kNe9HXkat9LscUWStsCgx5K4YNL9HXkSgX4bfExWbDem4WfMDsEr9ocI6gJsWuFPKadrCH5(G8CrrmE0wpNsrLtcUWStsKNqoA0uRsknme5JGV6qOecZdkCTmEq2jj50fr9dTjkROImEq2jj50fr9dpHYRrmEqH3fCqhbdoCHzNKxuVJGOUXOem1xkjWqexyUpipxueJhTddr(i4cZojjCwO9tQVusmXdNjJKCYi5LZrINUwLggI8rWxDiucH5bfUIkY4bzNKKtxe1p0MQ8AeJhu4Dbh0rWGdxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4r7WqKpc(QdHsimpOW1Y4bzNKKtxe1p0aSgX4bfExWbDem4WfMDssN1HIokCJrjyQVusWfMDsIZ4kNe9HXkCO6lLeCHzNK4mUYjXLpl7dJvynIXdk8UGd6iyWHlm7KKoRdfDu4gJsWuFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqREr2L54Vqdbxy2jPkxfNtRrmEqH3fCqhbdoK9aZdkCJr(qv90hjkb7Yol0Xd8GztpHXiFOQE6JeDV0hXdbtJ1O1iBZco4cffAqh00cEDKNVG8c1H0CbimcdrlWcnzlG1flWaUtlanlWcnzlyI5UGyYOYc1jXAeJhu4DbocOFy5DyPk6J0d7SXOeS65ukQCsKxOoKMsegHHiT4iG(HLl4cZoj1dlQefDzK3HNndFT4iG(HLlM4HZKrsozK8Y5irrxg5DyWxRsQVusWfMDsIZ4kNe9HXkCim7CHyvismXCLx(SeNXvo11QKsddr(iQNtYij1dlQ0IJa6hwUOEojJKupSOsu0LrE)qy54VwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5Lpl)eeRPmfLK1vwrfvYGggI8rupNKrsQhwuPfhb0pSCbxy2jPEyrLOOlJ8o8SZfIvHiXeZvE5ZYpbXAktrjzDLvurCeq)WYfCHzNK6HfvIIUmY7hclh)vw51igpOW7cCeq)WY7hbdoPk6J0d7SXOeS65ukQCsKxOoKMsegHHiT4iG(HLl4cZoj1dlQefDzK3HbFTkzqddr(iihcLNnKtFfvuPHHiFeKdHYZgYPV2l7SqhpWdMTf(kRSwLuchb0pSCXepCMmsYjJKxohjk6YiVdpnGVw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJvag8vwzTQVusupNKrsQhwuj(HLR9Yol0Xd8GzNleRcrcwxEro6(UYl7SuhpRrmEqH3f4iG(HL3pcgCsv0h1aAmgLGvpNsrLtIpQJr6qiNlnL44Ez)Rfhb0pSCH6lLKFuhJ0HqoxAkXX9Y(xue)1uR6lLeFuhJ0HqoxAkXX9Y(xMQOpIFy5Avs9LscUWSts9WIkXpSCTQVusupNKrsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5kRfhb0pSCXepCMmsYjJKxohjk6YiVdd(Avs9LscUWStsCgx5KOpmwHdHzNleRcrIjMR8YNL4mUYPUwLuAyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hclh)1IJa6hwUGlm7KupSOsu0LrEhE25cXQqKyI5kV8z5NGynLPOKSUYkQOsg0WqKpI65Kmss9WIkT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYlFw(jiwtzkkjRRSIkIJa6hwUGlm7KupSOsu0LrE)qy54VYkVgX4bfExGJa6hwE)iyWjHksQcX9Xyucw9Ckfvoj(OogPdHCU0uIJ7L9VwCeq)WYfQVus(rDmshc5CPPeh3l7Frr8xtTQVus8rDmshc5CPPeh3l7FzcvK4hwUw9ISlZXFHgIuf9rnGM1iBZcoygvlWahhVal0KTaB)GxakTa0yyFb44I88f80xqpcxSGtwAbOzbwiiOfOsl41P)cSqt2coogdSXlaZ9zbOzbDiuE2aP5cuPuu0AeJhu4DbocOFy59JGbNlQQO6YijNOUKpgJsWWra9dlxmXdNjJKCYi5LZrIIUmY7hANleRcrIBms9IWe9LtmxPQMkQOs4iG(HLl4cZoj1dlQefDzK3HNDUqSkejUXiV8z5NGynLPOKSUwCeq)WYft8WzYijNmsE5CKOOlJ8o8SZfIvHiXng5Lpl)eeRPmfLCI5Q8AeJhu4DbocOFy59JGbNlQQO6YijNOUKpgJsWWra9dlxWfMDsQhwujkI)AQvjdAyiYhb5qO8SHC6ROIknme5JGCiuE2qo91EzNf64bEWSTWxzL1QKs4iG(HLlM4HZKrsozK8Y5irrxg5D4zNleRcrcwxE5ZYpbXAktrjNyUAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqzfvujCeq)WYft8WzYijNmsE5CKOOlJ8om4Rv9LscUWStsCgx5KOpmwbyWxzL1Q(sjr9CsgjPEyrL4hwU2l7SqhpWdMDUqSkejyD5f5O77kVSZsD8SgzBwGTdzXA2xWRtl4t8KPgLtlWcnzlG1fl4KLwWeZDbO(ckI)AUaUValccY4fCzfOf0FfTGjwaM7ZcqZcuPuu0cMyUI1igpOW7cCeq)WY7hbdoFINm1OCYyucgocOFy5IjE4mzKKtgjVCosu0LrEhg81Q(sjbxy2jjoJRCs0hgRWHWSZfIvHiXeZvE5ZsCgx5uxlocOFy5cUWSts9WIkrrxg59dHLJ)RrmEqH3f4iG(HL3pcgC(epzQr5KXOemCeq)WYfCHzNK6HfvIIUmY7WGVwLmOHHiFeKdHYZgYPVIkQ0WqKpcYHq5zd50x7LDwOJh4bZ2cFLvwRskHJa6hwUyIhotgj5KrYlNJefDzK3HNgWxR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojU8zzFySckROIkHJa6hwUyIhotgj5KrYlNJefDzK3HbFTQVusWfMDsIZ4kNe9HXkad(kRSw1xkjQNtYij1dlQe)WY1EzNf64bEWSZfIvHibRlVihDFx5LDwQJN1iBZcmG70c66CPWcqPfmXCxa7)fW6lGlAbHVa8FbS)xGv4golqLwWtFbPOwau45uTGjJ9fmz0cU85f8jiwtJxWLva55lO)kAbw0cYy70c4zbqe3NfmwXc4cZoTaCgx5uFbS)xWKXZcMyUlWI7UHZcmGWRpl41PVynIXdk8Uahb0pS8(rWGtXFe7JSRZLcgJsWWra9dlxmXdNjJKCYi5LZrIIUmY7WZoxiwfIevxE5ZYpbXAktrjNyUAXra9dlxWfMDsQhwujk6YiVdp7CHyvisuD5Lpl)eeRPmfLK11Q0WqKpI65Kmss9WIkTkHJa6hwUOEojJKupSOsu0LrE)q6mHFdjh0LuurCeq)WYf1ZjzKK6HfvIIUmY7WZoxiwfIevxE5ZYpbXAktrjRqxzfv0GggI8rupNKrsQhwuPSw1xkj4cZojXzCLtI(WyfGNn0(j1xkjM4HZKrsozK8Y5iXpSCTQVusupNKrsQhwuj(HLRv9LscUWSts9WIkXpS81iBZcmG70c66CPWcSqt2cy9fyLr(c0JEhPcrIfCYslyI5UauFbfXFnxa3xGfbbz8cUSc0c6VIwWelaZ9zbOzbQukkAbtmxXAeJhu4DbocOFy59JGbNI)i2hzxNlfmgLGHJa6hwUyIhotgj5KrYlNJefDzK3pKot43qYbDjTQVusWfMDsIZ4kNe9HXkCim7CHyvismXCLx(SeNXvo11IJa6hwUGlm7KupSOsu0LrE)qLOZe(nKCqx6igpOWft8WzYijNmsE5CKGot43qYbDjLxJy8GcVlWra9dlVFem4u8hX(i76CPGXOemCeq)WYfCHzNK6HfvIIUmY7hsNj8Bi5GUKwLuYGggI8rqoekpBiN(kQOsddr(iihcLNnKtFTx2zHoEGhmBl8vwzTkPeocOFy5IjE4mzKKtgjVCosu0LrEhE25cXQqKG1Lx(S8tqSMYuuYjMRw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(Wyfuwrfvchb0pSCXepCMmsYjJKxohjk6YiVdd(AvFPKGlm7KeNXvoj6dJvag8vwzTQVusupNKrsQhwuj(HLR9Yol0Xd8GzNleRcrcwxEro6(UYl7SuhpkVgzBwGbCNwWeZDbwOjBbS(cqPfGgd7lWcnziFbtgTGlFEbFcI1uSGtwAbEmgVGxNwGfAYwqf6laLwWKrlyyiYNfG6lyyfi34fW(FbOXW(cSqtgYxWKrl4YNxWNGynfRrmEqH3f4iG(HL3pcgCM4HZKrsozK8Y5iJrjyQVusWfMDsIZ4kNe9HXkCim7CHyvismXCLx(SeNXvo11IJa6hwUGlm7KupSOsu0LrE)qy0zc)gsoOlP9Yol0Xd8SZfIvHibRlVihDFx5LDwQJhTQVusupNKrsQhwuj(HLVgX4bfExGJa6hwE)iyWzIhotgj5KrYlNJmgLGP(sjbxy2jjoJRCs0hgRWHWSZfIvHiXeZvE5ZsCgx5ux7WqKpI65Kmss9WIkT4iG(HLlQNtYij1dlQefDzK3pegDMWVHKd6sAXra9dlxWfMDsQhwujk6YiVdp7CHyvismXCLx(S8tqSMYuuswxlocOFy5cUWSts9WIkrrxg5D4PHnwJy8GcVlWra9dlVFem4mXdNjJKCYi5LZrgJsWuFPKGlm7KeNXvoj6dJv4qy25cXQqKyI5kV8zjoJRCQRvjdAyiYhr9CsgjPEyrLIkIJa6hwUOEojJKupSOsu0LrEhE25cXQqKyI5kV8z5NGynLPOKvORSwCeq)WYfCHzNK6HfvIIUmY7WZoxiwfIetmx5Lpl)eeRPmfLK1xJSnlWaUtlG1xakTGjM7cq9fe(cW)fW(FbwHB4SavAbp9fKIAbqHNt1cMm2xWKrl4YNxWNGynnEbxwbKNVG(ROfmz8SalAbzSDAbKhV8SfCzNxa7)fmz8SGjJkAbO(c8ywadve)1Cb8cQNtlislqpSOAb)WYfRrmEqH3f4iG(HL3pcgC4cZoj1dlQmgLGHJa6hwUyIhotgj5KrYlNJefDzK3HNDUqSkejyD5Lpl)eeRPmfLCI5Qvjdch2jN9ryN8jtZsrfXra9dlxCrvfvxgj5e1L8ru0LrEhE25cXQqKG1Lx(S8tqSMYuuYBmkRv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNex(SSpmwbTQVusupNKrsQhwuj(HLR9Yol0Xd8GzNleRcrcwxEro6(UYl7SuhpRr2Mfya3PfuH(cqPfmXCxaQVGWxa(Va2)lWkCdNfOsl4PVGuulak8CQwWKX(cMmAbx(8c(eeRPXl4YkG88f0FfTGjJkAbOUB4SagQi(R5c4fupNwWpS8fW(FbtgplG1xGv4golqLWXLwaBNrqSkeTG)RqE(cQNtI1igpOW7cCeq)WY7hbdo1ZjzKK6HfvgJsWuFPKGlm7KupSOs8dlxRs4iG(HLlM4HZKrsozK8Y5irrxg5D4zNleRcrIk0Lx(S8tqSMYuuYjMRIkIJa6hwUGlm7KupSOsu0LrE)qy25cXQqKyI5kV8z5NGynLPOKSUYAvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqlocOFy5cUWSts9WIkrrxg5D4PHnwJy8GcVlWra9dlVFem40ZqPb55s9WIkJrjyQVusWfMDsQhwuj(HLRfhb0pSCbxy2jPEyrLyQhjl6YiVdpgpOWf9muAqEUupSOsG)Lw1xkjQNtYij1dlQe)WY1IJa6hwUOEojJKupSOsm1JKfDzK3HhJhu4IEgknipxQhwujW)s7NuFPKyIhotgj5KrYlNJe)WYxJSnlWaUtlqpUlyIf0pipIoOPfW(cOZtXlGvxaYxWKrlWPZZcWra9dlFbwi)hwgVGNdr9(cuqZcX(cMmYxq4qAUG)RqE(c4cZoTa9WIQf8F0cMybzH1cUSZli755LMlO4pI9zbDDUuybO(AeJhu4DbocOFy59JGbh9I6KJjzKKxK)ngLGnme5JOEojJKupSOsR6lLeCHzNK6HfvINUw1xkjQNtYij1dlQefDzK3pmh)fx(8AeJhu4DbocOFy59JGbh9I6KJjzKKxK)ngLG9j1xkjM4HZKrsozK8Y5iXtx7NuFPKyIhotgj5KrYlNJefDzK3pKXdkCbxy2j5f17iiQlOZe(nKCqxsRbHd7KZ(iuqZcX(AeJhu4DbocOFy59JGbh9I6KJjzKKxK)ngLGP(sjr9CsgjPEyrL4PRv9LsI65Kmss9WIkrrxg59dZXFXLpRfhb0pSCbzpW8Gcxue)1ulocOFy5IjE4mzKKtgjVCosu0LrExRbHd7KZ(iuqZcX(A0AeJhu4Drc5mKu9v(rWGdxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4XyCgJCyASgX4bfExKqodjvFLFem4WfMDsQcX9znIXdk8UiHCgsQ(k)iyWHlm7KuLRIZP1O1iBZcoOYiFb1ZDKNVacnzuTGjJwGP5cIAbhFqTaikN8pxiQB8cSOfyX(SGjwGbI9ybQukkAbtgTGJJXadhB)GxGfY)HLybgWDAbOzbCFb9i8fW9fCsJdEbzCFbjKJ6z0FbXRwGfzODAbDDYNfeVAb4mUYP(AeJhu4Drc1ZqEUm0jNkyK9aZdkCJrjykvpNsrLtIosplCzFI6QOI1ZPuu5KyOREumK0IlDL1QK6lLe1ZjzKK6HfvIFy5kQOEr2L54Vqdbxy2jPkxfNtkRfhb0pSCr9CsgjPEyrLOOlJ8(AKTzbNS0cSidTtliHCupJ(liE1cWra9dlFbwi)hw9fW(FbDDYNfeVAb4mUYPUXlqVqrHg0bnTade7Xcc7uTaYovAozipFbeuNwJy8GcVlsOEgYZLHo5uDem4q2dmpOWngLGnme5JOEojJKupSOslocOFy5I65Kmss9WIkrrxg5DT4iG(HLl4cZoj1dlQefDzK31Q(sjbxy2jPEyrL4hwUw1xkjQNtYij1dlQe)WY1QxKDzo(l0qWfMDsQYvX50AeJhu4Drc1ZqEUm0jNQJGbNeQiPke3hJrjy1ZPuu5K4J6yKoeY5stjoUx2)AvFPK4J6yKoeY5stjoUx2)Yuf9r80xJy8GcVlsOEgYZLHo5uDem4KQOpspSZgJsWQNtPOYjrEH6qAkryegI0EzNf64bE20tSgX4bfExKq9mKNldDYP6iyW5t8KPgLtgJsWmO65ukQCs0r6zHl7tuxTgu9Ckfvojg6QhfdjT4sFnIXdk8UiH6zipxg6Kt1rWGdxy2jzuQgJsWWra9dlxupNKrsQhwujkI)AUgX4bfExKq9mKNldDYP6iyWHlm7KufI7JXOemCeq)WYf1ZjzKK6HfvII4VMAvFPKGlm7KeNXvoj6dJv4q1xkj4cZojXzCLtIlFw2hgRWAeJhu4Drc1ZqEUm0jNQJGbN65Kmss9WIQ1iBZcozPfyrgw0c4zbx(8c6dJvOVGiTad2Gxa7)fyrliJTtUHZcED6VadCC8c0KgJxWRtlGxqFySclyIfOxKDYNfCFood55RrmEqH3fjupd55YqNCQocgC4cZojVOEhbrDJrjyQVusGHiUWCFqEUOigpAvFPKadrCH5(G8CrFyScWuFPKadrCH5(G8CXLpl7dJvqloSto7JWo5tMMLwCeq)WYfxuvr1LrsorDjFefXFnxJSnl40OUmeKMlWIwGoJQfOhdk8f860cSqt2cS9d24fO(MfGMfyHGGwae3NfafE(cipE5zlif1cuJjBbtgTGtACWlG9)cS9dEbwi)hw9f8CiQ3xq9Ch55lyYOfyAUGOwWXhulaIYj)ZfI6RrmEqH3fjupd55YqNCQocgC0JbfUXOemdsP65ukQCs0r6zHl7tuxfvSEoLIkNedD1JIHKwCPR8AeJhu4Drc1ZqEUm0jNQJGbNpXtMAuozmkbt9LsI65Kmss9WIkXpSCfvuVi7YC8xOHGlm7KuLRIZP1igpOW7IeQNH8CzOtovhbdof)rSpYUoxkymkbt9LsI65Kmss9WIkXpSCfvuVi7YC8xOHGlm7KuLRIZP1igpOW7IeQNH8CzOtovhbdoxuvr1LrsorDjFmgLGP(sjr9CsgjPEyrL4hwUIkQxKDzo(l0qWfMDsQYvX50AeEqH3fjupd55YqNCQocgCM4HZKrsozK8Y5iJrjyQVusupNKrsQhwuj(HLROI6fzxMJ)cneCHzNKQCvCoPOI6fzxMJ)cnexuvr1LrsorDjFuur9ISlZXFHgII)i2hzxNlfuur9ISlZXFHgIpXtMAuoTgX4bfExKq9mKNldDYP6iyWHlm7KupSOYyucMEr2L54VqdXepCMmsYjJKxohTgzBwGbCNwWbhg4fmXc6hKhrh00cyFb05P4fy7fMDAbWfI7Zc(Vc55lyYOfCCmgy4y7h8cSq(pSwWZHOEFb1ZDKNVaBVWStlWabNfIfCYslW2lm70cmqWzXcq9fmme5d9nEbw0cWSB4SGxNwWbhg4fyHMmKVGjJwWXXyGHJTFWlWc5)WAbphI69fyrla5dv1tFwWKrlW2nWlaNXUtqgVGESalYqiOf0z70cqJynIXdk8UiH6zipxg6Kt1rWGJErDYXKmsYlY)gJsWmOHHiFeCHzNKeol0(j1xkjM4HZKrsozK8Y5iXtx7NuFPKyIhotgj5KrYlNJefDzK3peMsmEqHl4cZojvH4(iOZe(nKCqx6KR(sjHErDYXKmsYlY)IlFw2hgRGYRr2MfCYsl4Gdd8cY4UB4SavI8f860Fb)xH88fmz0coogd8cSq(pSmEbwKHqql41PfGMfmXc6hKhrh00cyFb05P4fy7fMDAbWfI7Zcq(cMmAbN04GHJTFWlWc5)WsSgX4bfExKq9mKNldDYP6iyWrVOo5ysgj5f5FJrjyQVusWfMDsQhwujE6AvFPKOEojJKupSOsu0LrE)qykX4bfUGlm7KufI7JGot43qYbDPtU6lLe6f1jhtYijVi)lU8zzFySckVgX4bfExKq9mKNldDYP6iyWHlm7KufI7JXOeSFmII)i2hzxNlfefDzK3H3juuXpP(sjrXFe7JSRZLcs7piNkwfbHgnf9HXkap4VgzBwWbfTal2NfmXcUSc0c6VIwGfTGm2oTaYJxE2cUSZlif1cMmAbKpOIwGTFWlWc5)WY4fq2jFbO0cMmQid7lOpiiOfmOlTGIUmYrE(ccFbN04Gfl4Kng2xq4qAUavAgQwWelq9v(cMybh0uflG9)cmqShlaLwq9Ch55lyYOfyAUGOwWXhulaIYj)ZfI6I1igpOW7IeQNH8CzOtovhbdoCHzNKQCvCozmkbdhb0pSCbxy2jPEyrLOi(RP2l7SqhphQKba(hPKgW)KJd7KZ(iuqZcXUYkRv9LscUWStsCgx5KOpmwbyQVusWfMDsIZ4kNex(SSpmwbTgu9Ckfvoj6i9SWL9jQRwdQEoLIkNedD1JIHKwCPVgzBwGbSdr9(cQN7ipFbtgTaBVWStlWafx3W1Cbquo5FU004faxUkoNwqplEq)f4XSavAbVo9xaplyYOfq(FbrAb2(bVauAbgi2dmpOWxaQVGiLwaocOFy5lG7l4xHUoYZxaoJRCQValee0cUSc0cqZcgwbAbqHNt1cMybQVYxWKvXlpBbfDzKJ88fCzNxJy8GcVlsOEgYZLHo5uDem4WfMDsQYvX5KXOem1xkj4cZoj1dlQepDTQVusWfMDsQhwujk6YiVFiSC8xRs1ZPuu5KGlm7Ke5jKJgnvurCeq)WYfK9aZdkCrrxg5DLxJSnlaUCvCoTGEw8G(lGHSyn7lqLwWKrlaI7ZcWCFwaYxWKrl4Kgh8cSq(pSwa3xWXXyGxGfccAbf1NOOfmz0cWzCLt9f01jFwJy8GcVlsOEgYZLHo5uDem4WfMDsQYvX5KXOem1xkjQNtYij1dlQepDTQVusWfMDsQhwuj(HLRv9LsI65Kmss9WIkrrxg59dHLJ)RrmEqH3fjupd55YqNCQocgC4cZojVOEhbrDJrjyFs9LsIjE4mzKKtgjVCos801ome5JGlm7KKWzHwLuFPK4t8KPgLtIFy5kQiJhKDssoDruhMgkR9tQVusmXdNjJKCYi5LZrIIUmY7WJXdkCbxy2j5f17iiQlOZe(nKCqxYyCgJCyAymXfKMsCgJCjkbt9LscmeXfM7dYZL4m2Dcs8dlxRsQVusWfMDsQhwujE6kQOsg0WqKpIWov6Hfv0xRsQVusupNKrsQhwujE6kQiocOFy5cYEG5bfUOi(RPYkR8AKTzbgODinxqF4AwWRJ88fyWg8cSDd8cSYiFb2(bVGmUVavI8f860FnIXdk8UiH6zipxg6Kt1rWGdxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4rlocOFy5cUWSts9WIkrrxg5DTkP(sjr9CsgjPEyrL4PROIQVusWfMDsQhwujE6kBmoJromnwJy8GcVlsOEgYZLHo5uDem4WfMDsgLQXOem1xkj4cZojXzCLtI(WyfoeMDUqSkejMyUYlFwIZ4kN6RrmEqH3fjupd55YqNCQocgC4cZojvH4(ymkbt9LsI65Kmss9WIkXtxrfVSZcD8apnoXAeJhu4Drc1ZqEUm0jNQJGbhYEG5bfUXOem1xkjQNtYij1dlQe)WY1Q(sjbxy2jPEyrL4hwUXiFOQE6JeLGDzNf64bEWSjNWyKpuvp9rIUx6J4HGPXAeJhu4Drc1ZqEUm0jNQJGbhUWStsvUkoNwJwJSnlGXdk8UiJRB4AcdZoMGKmEqHBmkbJXdkCbzpW8GcxGZy3jiKNR9Yol0Xd8GztpXAKTzbgWDAbgi2dmpOWxakTalYWIwauyTGWxWLDEbS)xaVGJJXadhB)GxGfY)H1cq9fGJlYZxWtFnIXdk8UiJRB4AEem4q2dmpOWngLGDzNf645qyACcT4iG(HLlM4HZKrsozK8Y5irrxg59dHPeDMWVHKd6shX4bfUyIhotgj5KrYlNJe0zc)gsoOlPSwCeq)WYfCHzNK6HfvIIUmY7hctj6mHFdjh0LoIXdkCXepCMmsYjJKxohjOZe(nKCqx6igpOWfCHzNK6Hfvc6mHFdjh0LuwR6lLe1ZjzKK6HfvIFy5AvFPKGlm7KupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WY1Aq)yef)rSpYUoxkik6YiVVgzBwGbCNwGbI9aZdk8fGslWImSOfafwli8fCzNxa7)fWl4Kgh8cSq(pSwaQVaCCrE(cE6RrmEqH3fzCDdxZJGbhYEG5bfUXOeSl7SqhphcZMHVwCeq)WYf1ZjzKK6HfvIIUmY7hctj6mHFdjh0LoIXdkCr9CsgjPEyrLGot43qYbDjL1IJa6hwUyIhotgj5KrYlNJefDzK3peMs0zc)gsoOlDeJhu4I65Kmss9WIkbDMWVHKd6shX4bfUO4pI9r215sbbDMWVHKd6skRfhb0pSCbxy2jPEyrLOOlJ8o8maWFnY2Sa4(qq)fyGIRB4AUG(Wyf6lif1cMmAbhhJbgo2(bValK)dR1igpOW7ImUUHR5rWGdxy2j5f17iiQBmkbt9LscUWStYmUUHRPOpmwHdvFPKGlm7KmJRB4AkU8zzFyScAXra9dlxu8hX(i76CPGOOlJ8(HWuYghPeDMWVHKd6shX4bfUO4pI9r215sbbDMWVHKd6skRSwCeq)WYft8WzYijNmsE5CKOOlJ8(HWuYghPeDMWVHKd6shX4bfUO4pI9r215sbbDMWVHKd6shX4bfUyIhotgj5KrYlNJe0zc)gsoOlPSYAXra9dlxWfMDsQhwujk6YiVFimLSXrkrNj8Bi5GU0rmEqHlk(JyFKDDUuqqNj8Bi5GU0rmEqHlM4HZKrsozK8Y5ibDMWVHKd6shX4bfUGlm7KupSOsqNj8Bi5GUKYkBmoJromnwJSnlaUpe0FbgO46gUMlOpmwH(csrTGjJwWjno4fyH8FyTgX4bfExKX1nCnpcgC4cZojVOEhbrDJrjyQVusWfMDsMX1nCnf9HXkCO6lLeCHzNKzCDdxtXLpl7dJvqlocOFy5I65Kmss9WIkrrxg59dHPKnosj6mHFdjh0LoIXdkCr9CsgjPEyrLGot43qYbDjLvwlocOFy5II)i2hzxNlfefDzK3peMs24iLOZe(nKCqx6igpOWf1ZjzKK6Hfvc6mHFdjh0LoIXdkCrXFe7JSRZLcc6mHFdjh0LuwzT4iG(HLlM4HZKrsozK8Y5irrxg59dHPKnosj6mHFdjh0LoIXdkCr9CsgjPEyrLGot43qYbDPJy8Gcxu8hX(i76CPGGot43qYbDPJy8GcxmXdNjJKCYi5LZrc6mHFdjh0LuwzT4iG(HLl4cZoj1dlQefDzK3ngNXihMgRr2Mfa3hc6VaduCDdxZf0hgRqFbPOwWKrlWzfO)coPMlWc5)WAnIXdk8UiJRB4AEem4WfMDsEr9ocI6gJsWuFPKGlm7KmJRB4Ak6dJv4q1xkj4cZojZ46gUMIlFw2hgRGwCeq)WYff)rSpYUoxkik6YiVFimLSXrkrNj8Bi5GU0rmEqHlk(JyFKDDUuqqNj8Bi5GUKYkRfhb0pSCbxy2jPEyrLOOlJ8o8GzZWxlocOFy5I65Kmss9WIkrrxg5D4bZMHVX4mg5W0ynIXdk8UiJRB4AEem4u8hX(i76CPGXOem1xkj4cZojZ46gUMI(WyfGP(sjbxy2jzgx3W1uC5ZY(Wyf0IJa6hwUyIhotgj5KrYlNJefDzK3pKot43qYbDjT4iG(HLl4cZoj1dlQefDzK3peMs0zc)gsoOlDeJhu4IjE4mzKKtgjVCosqNj8Bi5GUKYAVSZcD8apnoXAeJhu4Drgx3W18iyWzIhotgj5KrYlNJmgLGP(sjbxy2jzgx3W1u0hgRam1xkj4cZojZ46gUMIlFw2hgRGwCeq)WYfCHzNK6HfvIIUmY7hcJot43qYbDjT)yef)rSpYUoxkik6YiVVgX4bfExKX1nCnpcgC4cZoj1dlQmgLGP(sjbxy2jzgx3W1u0hgRam1xkj4cZojZ46gUMIlFw2hgRG2pP(sjXepCMmsYjJKxohjE6AvFPKOEojJKupSOs8dlFnIXdk8UiJRB4AEem4upNKrsQhwuzmkbt9LscUWStYmUUHRPOpmwbyQVusWfMDsMX1nCnfx(SSpmwbT4iG(HLlM4HZKrsozK8Y5irrxg59dHPeDMWVHKd6shX4bfUO4pI9r215sbbDMWVHKd6skRfhb0pSCbxy2jPEyrLOOlJ8o8maWx7LDwOJh4bZMpXAeJhu4Drgx3W18iyWP4pI9r215sbJrjyQVusWfMDsMX1nCnf9HXkat9LscUWStYmUUHRP4YNL9HXkOfhb0pSCXepCMmsYjJKxohjk6YiVFiDMWVHKd6sAvFPKOEojJKupSOs80xJy8GcVlY46gUMhbdot8WzYijNmsE5CKXOem1xkj4cZojZ46gUMI(WyfGP(sjbxy2jzgx3W1uC5ZY(Wyf0IJa6hwUGlm7KupSOsu0LrEhEga4Rv9LsI65Kmss9WIkXtx7pgrXFe7JSRZLcIIUmY7RrmEqH3fzCDdxZJGbN65Kmss9WIkJrjy4iG(HLlM4HZKrsozK8Y5irrxg5D4Pb81IJa6hwUGlm7KupSOsu0LrEhE2m81Q(sjbxy2jPEyrL4hw(AeJhu4Drgx3W18iyWP4pI9r215sbJrjyQVusWfMDsMX1nCnf9HXkat9LscUWStYmUUHRP4YNL9HXkOfhb0pSCbxy2jPEyrLOOlJ8o8GzJtOfhb0pSCr9CsgjPEyrLOOlJ8o8GzJtOv9LscUWStYmUUHRPOpmwbyQVusWfMDsMX1nCnfx(SSpmwbTx2zHoEGhmnoXAKTzbgWDAbhCyGxW)vipFb2(bVGOwWjno4fyH8Fy1xWelq9HG(laNXvo1xaNgQwWRJ88fy7fMDAbWLRIZP1igpOW7ImUUHR5rWGJErDYXKmsYlY)gJsWuFPKGlm7KeNXvoj6dJv4q1xkj4cZojXzCLtIlFw2hgRGw1xkj4cZojXzCLtI(WyfGh81Q(sjbxy2jPEyrLOOlJ8UIkQ(sjbxy2jjoJRCs0hgRWHQVusWfMDsIZ4kNex(SSpmwbTQVusWfMDsIZ4kNe9HXkap4Rv9LsI65Kmss9WIkrrxg5DTFs9LsIjE4mzKKtgjVCosu0LrEFnIXdk8UiJRB4AEem4WfMDsQcX9XyucM6lLe6f1jhtYijVi)lE6RrmEqH3fzCDdxZJGbhUWStYOungLGP(sjbxy2jjoJRCs0hgRWH2qR6lLeCHzNK6HfvIN(AeJhu4Drgx3W18iyWHlm7KmkvJrjyQVusWfMDsIZ4kNe9HXkCOn0AqkHJa6hwUGlm7KupSOsu0LrE)qyAaFT4iG(HLlM4HZKrsozK8Y5irrxg59dHPb81IJa6hwUO4pI9r215sbrrxg59dHDcLxJy8GcVlY46gUMhbdoCHzNKxuVJGOUXOem1xkj4cZojXzCLtI(WyfGNgAvFPKGlm7KmJRB4Ak6dJv4q1xkj4cZojZ46gUMIlFw2hgRGX4mg5W0ynIXdk8UiJRB4AEem4WfMDsEr9ocI6gJsWWra9dlxWfMDsgLQOOlJ8(HgaTQVusWfMDsMX1nCnf9HXkCO6lLeCHzNKzCDdxtXLpl7dJvWyCgJCyASgX4bfExKX1nCnpcgC4cZojv5Q4CYyuc2NuFPKO4pI9r215sbP9hKtfRIGqJMI(WyfGzawJy8GcVlY46gUMhbdoCHzNKQqCFmgLG9Jru8hX(i76CPGOOlJ8U2pP(sjXepCMmsYjJKxohjk6YiVdp6mHFdjh0L0Q0NuFPKO4pI9r215sbP9hKtfRIGqJMI(WyfGbFfv8tQVusu8hX(i76CPG0(dYPIvrqOrtrFySchAauEnIXdk8UiJRB4AEem4WfMDsgLQXOeSFmII)i2hzxNlfefDzK3H3j0(j1xkjk(JyFKDDUuqA)b5uXQii0OPOpmwbyWxR6lLe1ZjzKK6HfvIFy5RrmEqH3fzCDdxZJGbhUWStsviUpgJsW(Xik(JyFKDDUuqu0LrEhE0zc)gsoOlP9tQVusu8hX(i76CPG0(dYPIvrqOrtrFyScWd(A)K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRWHgaTQVusupNKrsQhwuj(HLVgX4bfExKX1nCnpcgC4cZojv5Q4CYyucM6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojU8zzFyScAvFPKGlm7KmJRB4Ak6dJvaM6lLeCHzNKzCDdxtXLpl7dJvynIXdk8UiJRB4AEem4q2dmpOWngLGDzNf645qnoXAKTzbhuzKVavASiYxaocOFy5lWc5)WQB8cSOfeoKMlq9HG(lyIfKEqqlaNXvo1xaNgQwWRJ88fy7fMDAbgOl11igpOW7ImUUHR5rWGdxy2jPke3hJrjyQVusWfMDsIZ4kNe9HXkapnwJSnl4KDV0hXdbP5c66K)xGbkUUHR5c6dJvOVaRmYxGknwe5lahb0pS8fyH8Fy1xJy8GcVlY46gUMhbdoCHzNKQCvCozmkbt9LscUWStYmUUHRPOpmwb4bFTgKs4iG(HLl4cZoj1dlQefDzK3peMgWxlocOFy5IjE4mzKKtgjVCosu0LrE)qyAaFT4iG(HLlk(JyFKDDUuqu0LrE)qyNq51igpOW7ImUUHR5rWGdxy2j5f17iiQBmoJromnwJwJy8GcVlUHD6s(Cem4OcHCfKSRPXOeSByNUKpIpQpSJj4btd4VgX4bfExCd70L85iyWrVOo5ysgj5f5)1igpOW7IByNUKphbdoCHzNKxuVJGOUXOeSByNUKpIpQpSJPd1a(RrmEqH3f3WoDjFocgC4cZojJsDnIXdk8U4g2Pl5ZrWGtcvKufI7ZA0AeJhu4DrOtovWsOIKQqCFmgLGvpNsrLtIpQJr6qiNlnL44Ez)Rv9LsIpQJr6qiNlnL44Ez)ltv0hXtFnIXdk8Ui0jNQJGbNuf9r6HD2yucw9CkfvojYluhstjcJWqK2l7SqhpWZMEI1igpOW7IqNCQocgC(epzQr50AeJhu4DrOtovhbdof)rSpYUoxkymkb7Yol0Xd8maWFnIXdk8Ui0jNQJGbNEgknipxQhwuzmkbt9LscUWSts9WIkXpSCT4iG(HLl4cZoj1dlQefDzK3xJy8GcVlcDYP6iyW5IQkQUmsYjQl5ZAeJhu4DrOtovhbdot8WzYijNmsE5C0AeJhu4DrOtovhbdoCHzNK6HfvRrmEqH3fHo5uDem4upNKrsQhwuzmkbt9LsI65Kmss9WIkXpS81iBZcmG70co4WaVGjwq)G8i6GMwa7lGopfVaBVWStlaUqCFwW)vipFbtgTGJJXadhB)GxGfY)H1cEoe17lOEUJ88fy7fMDAbgi4SqSGtwAb2EHzNwGbcolwaQVGHHiFOVXlWIwaMDdNf860co4WaVal0KH8fmz0coogdmCS9dEbwi)hwl45quVValAbiFOQE6ZcMmAb2UbEb4m2DcY4f0JfyrgcbTGoBNwaAeRrmEqH3fHo5uDem4OxuNCmjJK8I8VXOemdAyiYhbxy2jjHZcTFs9LsIjE4mzKKtgjVCos801(j1xkjM4HZKrsozK8Y5irrxg59dHPeJhu4cUWStsviUpc6mHFdjh0Lo5QVusOxuNCmjJK8I8V4YNL9HXkO8AKTzbNS0co4WaVGmU7golqLiFbVo9xW)vipFbtgTGJJXaValK)dlJxGfzie0cEDAbOzbtSG(b5r0bnTa2xaDEkEb2EHzNwaCH4(SaKVGjJwWjnoy4y7h8cSq(pSeRrmEqH3fHo5uDem4OxuNCmjJK8I8VXOem1xkj4cZoj1dlQepDTQVusupNKrsQhwujk6YiVFimLy8GcxWfMDsQcX9rqNj8Bi5GU0jx9Lsc9I6KJjzKKxK)fx(SSpmwbLz8GcVlcDYP6iyWHlm7KufI7JXOeSFmII)i2hzxNlfefDzK3H3juuXpP(sjrXFe7JSRZLcs7piNkwfbHgnf9HXkap4VgX4bfExe6Kt1rWGdxy2jPke3hJrjyQVusOxuNCmjJK8I8V4PR9tQVusmXdNjJKCYi5LZrINU2pP(sjXepCMmsYjJKxohjk6YiVFimgpOWfCHzNKQqCFe0zc)gsoOlTgzBwGTdzXA2xaC5Q4CAb8SGjJwa5)fePfy7h8cSYiFb1ZDKNVGjJwGTxy2PfyGIRB4AUaikN8pxAUgX4bfExe6Kt1rWGdxy2jPkxfNtgJsWuFPKGlm7KupSOs801Q(sjbxy2jPEyrLOOlJ8(H54V265ukQCsWfMDsI8eYrJMRr2Mfy7qwSM9faxUkoNwaplyYOfq(FbrAbtgTGtACWlWc5)WAbwzKVG65oYZxWKrlW2lm70cmqX1nCnxaeLt(NlnxJy8GcVlcDYP6iyWHlm7KuLRIZjJrjyQVusupNKrsQhwujE6AvFPKGlm7KupSOs8dlxR6lLe1ZjzKK6HfvIIUmY7hclh)1wpNsrLtcUWStsKNqoA0CnIXdk8Ui0jNQJGbhUWStYlQ3rqu3yuc2NuFPKyIhotgj5KrYlNJepDTddr(i4cZojjCwOvj1xkj(epzQr5K4hwUIkY4bzNKKtxe1HPHYA)K6lLet8WzYijNmsE5CKOOlJ8o8y8GcxWfMDsEr9ocI6c6mHFdjh0LmgNXihMggtCbPPeNXixIsWuFPKadrCH5(G8CjoJDNGe)WY1QK6lLeCHzNK6HfvINUIkQKbnme5JiStLEyrf91QK6lLe1ZjzKK6HfvINUIkIJa6hwUGShyEqHlkI)AQSYkVgX4bfExe6Kt1rWGdxy2j5f17iiQBmkbt9LscmeXfM7dYZffX4XyCgJCyASgX4bfExe6Kt1rWGdxy2jzuQgJsWuFPKGlm7KeNXvoj6dJv4qy25cXQqKyI5kV8zjoJRCQVgX4bfExe6Kt1rWGdxy2jPke3hJrjyQVusupNKrsQhwujE6kQ4LDwOJh4PXjwJy8GcVlcDYP6iyWHShyEqHBmkbt9LsI65Kmss9WIkXpSCTQVusWfMDsQhwuj(HLBmYhQQN(irjyx2zHoEGhmBYjmg5dv1tFKO7L(iEiyASgX4bfExe6Kt1rWGdxy2jPkxfNtRrRr2MfW4bfExuXWdk8JGbhm7ycsY4bfUXOemgpOWfK9aZdkCboJDNGqEU2l7SqhpWdMn9eAvYGQNtPOYjrhPNfUSprDvur1xkj6i9SWL9jQROpmwbyQVus0r6zHl7tuxXLpl7dJvq51igpOW7IkgEqHFem4q2dmpOWngLGDzNf645qy25cXQqKGShsD8OvjCeq)WYft8WzYijNmsE5CKOOlJ8(HWy8Gcxq2dmpOWf0zc)gsoOlPOI4iG(HLl4cZoj1dlQefDzK3pegJhu4cYEG5bfUGot43qYbDjfvuPHHiFe1ZjzKK6HfvAXra9dlxupNKrsQhwujk6YiVFimgpOWfK9aZdkCbDMWVHKd6skRSw1xkjQNtYij1dlQe)WY1Q(sjbxy2jPEyrL4hwU2pP(sjXepCMmsYjJKxohj(HLR1G0lYUmh)fAiM4HZKrsozK8Y5O1igpOW7IkgEqHFem4q2dmpOWngLGvpNsrLtIosplCzFI6Qfhb0pSCbxy2jPEyrLOOlJ8(HWy8Gcxq2dmpOWf0zc)gsoOlTgzBwaC5Q4CAbO0cqJH9fmOlTGjwWRtlyI5Ua2)lWIwqgBNwWeXcUSR5cWzCLt91igpOW7IkgEqHFem4WfMDsQYvX5KXOemCeq)WYft8WzYijNmsE5CKOi(RPwLuFPKGlm7KeNXvoj6dJvaE25cXQqKyI5kV8zjoJRCQRfhb0pSCbxy2jPEyrLOOlJ8(HWOZe(nKCqxs7LDwOJh4zNleRcrcwxEro6(UYl7SuhpAvFPKOEojJKupSOs8dlx51igpOW7IkgEqHFem4WfMDsQYvX5KXOemCeq)WYft8WzYijNmsE5CKOi(RPwLuFPKGlm7KeNXvoj6dJvaE25cXQqKyI5kV8zjoJRCQRDyiYhr9CsgjPEyrLwCeq)WYf1ZjzKK6HfvIIUmY7hcJot43qYbDjT4iG(HLl4cZoj1dlQefDzK3HNDUqSkejMyUYlFw(jiwtzkkjRR8AeJhu4DrfdpOWpcgC4cZojv5Q4CYyucgocOFy5IjE4mzKKtgjVCosue)1uRsQVusWfMDsIZ4kNe9HXkap7CHyvismXCLx(SeNXvo11QKbnme5JOEojJKupSOsrfXra9dlxupNKrsQhwujk6YiVdp7CHyvismXCLx(S8tqSMYuuYk0vwlocOFy5cUWSts9WIkrrxg5D4zNleRcrIjMR8YNLFcI1uMIsY6kVgX4bfExuXWdk8JGbhUWStsvUkoNmgLG9j1xkjk(JyFKDDUuqA)b5uXQii0OPOpmwbyFs9LsII)i2hzxNlfK2FqovSkccnAkU8zzFyScAvs9LscUWSts9WIkXpSCfvu9LscUWSts9WIkrrxg59dHLJ)kRvj1xkjQNtYij1dlQe)WYvur1xkjQNtYij1dlQefDzK3pewo(R8AeJhu4DrfdpOWpcgC4cZojvH4(ymkb7hJO4pI9r215sbrrxg5D4ztuurL(K6lLef)rSpYUoxkiT)GCQyveeA0u0hgRa8GV2pP(sjrXFe7JSRZLcs7piNkwfbHgnf9HXkC4NuFPKO4pI9r215sbP9hKtfRIGqJMIlFw2hgRGYRrmEqH3fvm8Gc)iyWHlm7KufI7JXOem1xkj0lQtoMKrsEr(x801(j1xkjM4HZKrsozK8Y5iXtx7NuFPKyIhotgj5KrYlNJefDzK3pegJhu4cUWStsviUpc6mHFdjh0LwJy8GcVlQy4bf(rWGdxy2j5f17iiQBmkb7tQVusmXdNjJKCYi5LZrINU2HHiFeCHzNKeol0QK6lLeFINm1OCs8dlxrfz8GStsYPlI6W0qzTk9j1xkjM4HZKrsozK8Y5irrxg5D4X4bfUGlm7K8I6Dee1f0zc)gsoOlPOI4iG(HLl0lQtoMKrsEr(xu0LrExrfXHDYzFekOzHyxzJXzmYHPHXexqAkXzmYLOem1xkjWqexyUpipxIZy3jiXpSCTkP(sjbxy2jPEyrL4PROIkzqddr(ic7uPhwurFTkP(sjr9CsgjPEyrL4PROI4iG(HLli7bMhu4II4VMkRSYRrmEqH3fvm8Gc)iyWHlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8Ov9Lsc6So7F6l1JH8bXqIN(AeJhu4DrfdpOWpcgC4cZojVOEhbrDJrjyQVusGHiUWCFqEUOigpAvs9LscUWSts9WIkXtxrfvFPKOEojJKupSOs80vuXpP(sjXepCMmsYjJKxohjk6YiVdpgpOWfCHzNKxuVJGOUGot43qYbDjLngNXihMgRrmEqH3fvm8Gc)iyWHlm7K8I6Dee1ngLGP(sjbgI4cZ9b55IIy8Ov9LscmeXfM7dYZf9HXkat9LscmeXfM7dYZfx(SSpmwbJXzmYHPXAeJhu4DrfdpOWpcgC4cZojVOEhbrDJrjyQVusGHiUWCFqEUOigpAvFPKadrCH5(G8Crrxg59dHPKsQVusGHiUWCFqEUOpmwHtoJhu4cUWStYlQ3rquxqNj8Bi5GUKYhLJ)kBmoJromnwJy8GcVlQy4bf(rWGJttgvYHU6uFmgLGPurPI6zSkePOIg0GWkG8CL1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIlFw2hgRGw1xkj4cZoj1dlQe)WY1(j1xkjM4HZKrsozK8Y5iXpS81igpOW7IkgEqHFem4WfMDsgLQXOem1xkj4cZojXzCLtI(WyfoeMDUqSkejMyUYlFwIZ4kN6RrmEqH3fvm8Gc)iyWP)0PYd7SXOeSl7SqhphcZMEcTQVusWfMDsQhwuj(HLRv9LsI65Kmss9WIkXpSCTFs9LsIjE4mzKKtgjVCos8dlFnIXdk8UOIHhu4hbdoCHzNKQqCFmgLGP(sjr9GizKKtwrux801Q(sjbxy2jjoJRCs0hgRa8S51igpOW7IkgEqHFem4WfMDsQYvX5KXOeSl7SqhphcZoxiwfIeQCvCojVSZsD8Ov9LscUWSts9WIkXpSCTQVusupNKrsQhwuj(HLR9tQVusmXdNjJKCYi5LZrIFy5AvFPKGlm7KeNXvoj6dJvaM6lLeCHzNK4mUYjXLpl7dJvqlocOFy5cYEG5bfUOOlJ8(AeJhu4DrfdpOWpcgC4cZojv5Q4CYyucM6lLeCHzNK6HfvIFy5AvFPKOEojJKupSOs8dlx7NuFPKyIhotgj5KrYlNJe)WY1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIlFw2hgRG2HHiFeCHzNKrPQfhb0pSCbxy2jzuQIIUmY7hclh)1EzNf645qy2u4Rfhb0pSCbzpW8Gcxu0LrEFnIXdk8UOIHhu4hbdoCHzNKQCvCozmkbt9LscUWSts9WIkXtxR6lLeCHzNK6HfvIIUmY7hclh)1Q(sjbxy2jjoJRCs0hgRam1xkj4cZojXzCLtIlFw2hgRGwLWra9dlxq2dmpOWffDzK3vuX65ukQCsWfMDsI8eYrJMkVgX4bfExuXWdk8JGbhUWStsvUkoNmgLGP(sjr9CsgjPEyrL4PRv9LscUWSts9WIkXpSCTQVusupNKrsQhwujk6YiVFiSC8xR6lLeCHzNK4mUYjrFyScWuFPKGlm7KeNXvojU8zzFyScAvchb0pSCbzpW8Gcxu0LrExrfRNtPOYjbxy2jjYtihnAQ8AeJhu4DrfdpOWpcgC4cZojv5Q4CYyucM6lLeCHzNK6HfvIFy5AvFPKOEojJKupSOs8dlx7NuFPKyIhotgj5KrYlNJepDTFs9LsIjE4mzKKtgjVCosu0LrE)qy54Vw1xkj4cZojXzCLtI(WyfGP(sjbxy2jjoJRCsC5ZY(WyfwJy8GcVlQy4bf(rWGdxy2jPkxfNtgJsWgUYPrKrm0Kj0XZH28j0Q(sjbxy2jjoJRCs0hgRa8GPeJhKDssoDru3aQgkRTEoLIkNeCHzNKQXvLR)L8rlJhKDssoDruhEAOv9LsIpXtMAuoj(HLVgX4bfExuXWdk8JGbhUWSts6Sou0rHBmkbB4kNgrgXqtMqhphAZNqR6lLeCHzNK4mUYjrFySchQ(sjbxy2jjoJRCsC5ZY(Wyf0wpNsrLtcUWSts14QY1)s(OLXdYojjNUiQdpn0Q(sjXN4jtnkNe)WYxJy8GcVlQy4bf(rWGdxy2jPke3N1igpOW7IkgEqHFem4q2dmpOWngLGP(sjr9CsgjPEyrL4hwUw1xkj4cZoj1dlQe)WY1(j1xkjM4HZKrsozK8Y5iXpS81igpOW7IkgEqHFem4WfMDsQYvX5uBAtRb]] )


end
