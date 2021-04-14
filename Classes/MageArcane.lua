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


    spec:RegisterPack( "Arcane", 20210413, [[d0ecIgqikeEKOsLlPIuPAtKIprbnkkWPiLAvIkv9krfZII0TevfAxe(fjWWirCmsulJIWZirY0evvDnvKSnvKsFtuvY4OqQohjs16OiY8ev5Ea1(ibDqrLYcbs9qkKCrvKIpQIujJKePCsvKQwjfQxsruntkeDtkIYobs(jfsPHkQQSurvPEkLAQQiUkfsXxfvfmwrLSxP6Venyqhg1IjPhd1KvLlJSzr(SkmAr50qwTksLYRbIzd42Q0UP63cdNuDCrvrlxYZLY0vCDv12PO(oLmEvuNNuY6vrQy(Kq7xP7k3pPB)4H6GYekXekRK8xzLsycLvwPRK8VBpAPtDBDgdcFqDBNVu3o3km7u3wN1ci4x)KUDl(fM62zZO3mjfOGd0K9vf44QGg6(b4bfoU40OGg6Ivq3w9JaMtV3v72pEOoOmHsmHYkj)vwPeMqzLn65VrVB30jChuNwt0TZqVh5D1U9JA4UTjJpOfMBfMDAno30leWcv2eMUqtOetO8A8AC(MUHzAHM5cXQaKGVYMoFxiYxyInh1cJ0cB0mi)Oj4RSPZ3fAaoJWGSqTIFTWMoHxyOpOWBAlwJnAA0chT0rygyH2ORrTWm2Fai)yHrAH4m2DcyHiFOQ(6dk8fI82q8BHrAHgIzhtasgpOWnu0TbqTP1pPBh6Ktv)KoOuUFs3MCwfGEDq3TXfAOcXD767ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfQ(tjXd1WiDaKZLwsCCVS)KPkAJ4R3Tz8GcVBNqfjvb420NoOmr)KUn5Ska96GUBJl0qfI7213PuuhK4OqnaTKimcdqcYzva6Tqnl8Yol0XZcv4cv6NQBZ4bfE3ovrBKEyM7thukv)KUnJhu4D7hXtMAuo1TjNvbOxh09PdQ8VFs3MCwfGEDq3TXfAOcXD7l7SqhpluHlm)vs3MXdk8UDXpe7JSPZfi9PdQt1pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcXra8clxWfMDsQhwujk6YiV1Tz8GcVB3YqPb5hs9WIQ(0b1PTFs3MXdk8U9fvvunzKKtuxYNUn5Ska96GUpDqLV6N0Tz8GcVBpXhNjJKCYi5LpqDBYzva61bDF6GYO3pPBZ4bfE3Mlm7KupSOQBtoRcqVoO7thuk9(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clVBZ4bfE3U(ojJKupSOQpDqPSs6N0TjNvbOxh0DBgpOW726f1ihtYijVi)1TFudxi9bfE32OPrlm)ct2cNyHT85NOthAHSVq68u8cZTcZoTqqdWTzHVFH8Jfoz0cpjgtMcYT8BHwi)fwl87auRTW67oYpwyUvy2PfEAWzHyHN(0cZTcZoTWtdolwiQTWHbiFONPl0IwiMDdNf(B0cZVWKTql0KH8foz0cpjgtMcYT8BHwi)fwl87auRTqlAHiFOQ(6ZcNmAH5MjBH4m2DcW0f2IfArgcaSWgBMwiAeDBCHgQqC32iw4WaKpcUWStscNfcYzva6Tqnl8rQ)usmXhNjJKCYi5LpqIV(c1SWhP(tjXeFCMmsYjJKx(ajk6YiVTW8aVqdwiJhu4cUWStsvaUnc6mH)djh0LwyUFHQ)usOxuJCmjJK8I8N4YNLTHXGSqT7thukRC)KUn5Ska96GUBZ4bfE3wVOg5ysgj5f5VU9JA4cPpOW72N(0cZVWKTWmU5goluLiFH)g9w47xi)yHtgTWtIXKTqlK)cltxOfziaWc)nAHOzHtSWw(8t0PdTq2xiDEkEH5wHzNwiOb42SqKVWjJwy(oYpfKB53cTq(lSeDBCHgQqC3(fJO4hI9r205cerrxg5TfQWfEQfQOIl8rQ)usu8dX(iB6CbI08hWPIvraOrlrBymiluHluj9PdkLnr)KUn5Ska96GUBJl0qfI72Q)usOxuJCmjJK8I8N4RVqnl8rQ)usmXhNjJKCYi5LpqIV(c1SWhP(tjXeFCMmsYjJKx(ajk6YiVTW8aVqgpOWfCHzNKQaCBe0zc)hsoOl1Tz8GcVBZfMDsQcWTPpDqPSs1pPBtoRcqVoO72mEqH3T5cZojv5Q4dQB)OgUq6dk8UDUbyXA1wiO5Q4dAH8SWjJwi5VfgPfMB53cTYiFH13DKFSWjJwyUvy2PfQ046gUwleGoi)XLwDBCHgQqC3w9NscUWSts9WIkXxFHAwO6pLeCHzNK6HfvIIUmYBlmVfEGFluZcRVtPOoibxy2jjYtihnAjiNvbOxF6Gs58VFs3MCwfGEDq3Tz8GcVBZfMDsQYvXhu3(rnCH0hu4D7CdWI1QTqqZvXh0c5zHtgTqYFlmslCYOfMVJ8BHwi)fwl0kJ8fwF3r(XcNmAH5wHzNwOsJRB4ATqa6G8hxA1TXfAOcXDB1FkjQVtYij1dlQeF9fQzHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkrrxg5TfMh4fEGFluZcRVtPOoibxy2jjYtihnAjiNvbOxF6Gs5t1pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kQObgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kQiocGxy5cYCG5bfUOi(PL2ARD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnlCyaYhbxy2jjHZcb5Ska9wOMfAWcv)PK4r8KPgLtIxy5lurfxiJhKzssoDruBHGxOYlu7fQzHps9NsIj(4mzKKtgjV8bsu0LrEBHkCHmEqHl4cZojVOwdbqnbDMW)HKd6sDBgpOW72CHzNKxuRHaOwF6Gs5tB)KUn5Ska96GUBZ4bfE3Mlm7K8IAnea1624mg5DBL724cnuH4UT6pLeyaIlm3gKFikIXtF6Gs58v)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8aVqZCHyvasmXCLx(SeNX1b162mEqH3T5cZojJsTpDqPSrVFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeF9fQOIl8Yol0XZcv4cv(uDBgpOW72CHzNKQaCB6thukR07N0TjNvbOxh0DBgpOW72K5aZdk8UnYhQQV(irPU9LDwOJhfc2OFQUnYhQQV(ir3l9q8qDBL724cnuH4UT6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clVpDqzcL0pPBZ4bfE3Mlm7KuLRIpOUn5Ska96GUp9PBNqTmKFidDYPQFshuk3pPBtoRcqVoO72mEqH3TjZbMhu4D7h1WfsFqH3TZhYiFH13DKFSqcnzuTWjJwOT9cJAHNKpSqa6G8hxiQz6cTOfAX(SWjw4PXCSqvkffTWjJw4jXyYuqULFl0c5VWsSqJMgTq0SqUTWwe(c52cZ3r(TWmUTWeYrTm6TW4xl0Im0mTWMo5ZcJFTqCgxhuRBJl0qfI72gSW67ukQds0q6zHlBtuxb5Ska9wOIkUW67ukQdsm0vpkgqAXLUGCwfGElu7fQzHgSq1FkjQVtYij1dlQeVWYxOIkUq9ImlpWpHYcUWStsvUk(GwO2luZcXra8clxuFNKrsQhwujk6YiV1NoOmr)KUn5Ska96GUBZ4bfE3MmhyEqH3TFudxi9bfE3(0NwOfzOzAHjKJAz0BHXVwiocGxy5l0c5VWQTq2FlSPt(SW4xleNX1b1mDH6fkk0GoDOfEAmhlmmt1cjZuP1KH8JfsanQBJl0qfI72ddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfQzH4iaEHLl4cZoj1dlQefDzK3wOMfQ(tjbxy2jPEyrL4fw(c1Sq1FkjQVtYij1dlQeVWYxOMfQxKz5b(juwWfMDsQYvXhuF6GsP6N0TjNvbOxh0DBCHgQqC3U(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVfQzHQ)us8qnmsha5CPLeh3l7pzQI2i(6DBgpOW72jursvaUn9PdQ8VFs3MCwfGEDq3TXfAOcXD767ukQdsCuOgGwsegHbib5Ska9wOMfEzNf64zHkCHk9t1Tz8GcVBNQOnspmZ9PdQt1pPBtoRcqVoO724cnuH4UTrSW67ukQds0q6zHlBtuxb5Ska9wOMfAelS(oLI6GedD1JIbKwCPliNvbOx3MXdk8U9J4jtnkN6thuN2(jDBYzva61bD3gxOHke3TXra8clxuFNKrsQhwujkIFA1Tz8GcVBZfMDsgLAF6GkF1pPBtoRcqVoO724cnuH4UnocGxy5I67Kmss9WIkrr8tRfQzHQ)usWfMDsIZ46GeTHXGSW8wO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KufGBtF6GYO3pPBZ4bfE3U(ojJKupSOQBtoRcqVoO7thuk9(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TFudxi9bfE3(0NwOfzyrlKNfE5ZlSnmgK2cJ0cnkJAHS)wOfTWm2m5gol83O3cnzXjlulAmDH)gTqEHTHXGSWjwOErMjFw4974mKF0TXfAOcXDB1FkjWaexyUni)queJNfQzHQ)usGbiUWCBq(HOnmgKfcEHQ)usGbiUWCBq(H4YNLTHXGSqnlehMjN9ryM8jtRAHAwiocGxy5IlQQOAYijNOUKpII4Nw9PdkLvs)KUn5Ska96GUBJl0qfI72gXcnyH13PuuhKOH0Zcx2MOUcYzva6TqfvCH13PuuhKyOREumG0IlDb5Ska9wO2D7h1WfsFqH3TbvuxgaqRfArluNr1c1Jbf(c)nAHwOjBH5w(z6cv)ZcrZcTqaaleGBZcbc)yHKh)JSfMIAHQXKTWjJwy(oYVfY(BH5w(TqlK)cR2c)oa1AlS(UJ8Jfoz0cTTxyul8K8HfcqhK)4crTUnJhu4DB9yqH3NoOuw5(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs8clFHkQ4c1lYS8a)ekl4cZojv5Q4dQBZ4bfE3(r8KPgLt9PdkLnr)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqfvCH6fzwEGFcLfCHzNKQCv8b1Tz8GcVBx8dX(iB6CbsF6GszLQFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOIkUq9ImlpWpHYcUWStsvUk(G62mEqH3TVOQIQjJKCI6s(0NoOuo)7N0TjNvbOxh0DBCHgQqC3w9NsI67Kmss9WIkXlS8fQOIluViZYd8tOSGlm7KuLRIpOfQOIluViZYd8tOS4IQkQMmsYjQl5ZcvuXfQxKz5b(juwu8dX(iB6CbYcvuXfQxKz5b(juw8iEYuJYPUnJhu4D7j(4mzKKtgjV8bQpDqP8P6N0TjNvbOxh0DBCHgQqC3wViZYd8tOSyIpotgj5KrYlFG62mEqH3T5cZoj1dlQ6thukFA7N0TjNvbOxh0DBgpOW726f1ihtYijVi)1TFudxi9bfE32OPrlm)ct2cNyHT85NOthAHSVq68u8cZTcZoTqqdWTzHVFH8Jfoz0cpjgtMcYT8BHwi)fwl87auRTW67oYpwyUvy2PfEAWzHyHN(0cZTcZoTWtdolwiQTWHbiFONPl0IwiMDdNf(B0cZVWKTql0KH8foz0cpjgtMcYT8BHwi)fwl87auRTqlAHiFOQ(6ZcNmAH5MjBH4m2DcW0f2IfArgcaSWgBMwiAeDBCHgQqC32iw4WaKpcUWStscNfcYzva6Tqnl8rQ)usmXhNjJKCYi5LpqIV(c1SWhP(tjXeFCMmsYjJKx(ajk6YiVTW8aVqdwiJhu4cUWStsvaUnc6mH)djh0LwyUFHQ)usOxuJCmjJK8I8N4YNLTHXGSqT7thukNV6N0TjNvbOxh0DBgpOW726f1ihtYijVi)1TFudxi9bfE3(0Nwy(fMSfMXn3WzHQe5l83O3cF)c5hlCYOfEsmMSfAH8xyz6cTidbaw4VrlenlCIf2YNFIoDOfY(cPZtXlm3km70cbna3MfI8foz0cZ3r(PGCl)wOfYFHLOBJl0qfI72Q)usWfMDsQhwuj(6luZcv)PKO(ojJKupSOsu0LrEBH5bEHgSqgpOWfCHzNKQaCBe0zc)hsoOlTWC)cv)PKqVOg5ysgj5f5pXLplBdJbzHA3NoOu2O3pPBtoRcqVoO724cnuH4U9lgrXpe7JSPZfiIIUmYBluHl8ulurfx4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwOcxOs62mEqH3T5cZojvb420NoOuwP3pPBtoRcqVoO72mEqH3T5cZojv5Q4dQB)OgUq6dk8UD(aTql2NfoXcVmi0cB)IwOfTWm2mTqYJ)r2cVSZlmf1cNmAHKpOIwyULFl0c5VWY0fsMjFHO0cNmQidBlSniaGfoOlTWIUmYr(XcdFH57i)el80pg2wy4aATqvAgQw4elu9x(cNyHNouflK93cpnMJfIslS(UJ8Jfoz0cTTxyul8K8HfcqhK)4crnr3gxOHke3TXra8clxWfMDsQhwujkIFATqnl8Yol0XZcZBHgSW8xjlmNfAWcvwjlm3VqCyMC2hbiAvi2xO2lu7fQzHQ)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXGSqnl0iwy9Dkf1bjAi9SWLTjQRGCwfGEluZcnIfwFNsrDqIHU6rXaslU0fKZQa0RpDqzcL0pPBtoRcqVoO72mEqH3T5cZojv5Q4dQB)OgUq6dk8UTrJdqT2cRV7i)yHtgTWCRWStluPX1nCTwiaDq(JlTmDHGMRIpOf2YIpWBHEmluLw4VrVfYZcNmAHK)wyKwyULFleLw4PXCG5bf(crTfgP0cXra8clFHCBHVk01r(XcXzCDqTfAHaaw4LbHwiAw4WGqlei8dQw4elu9x(cNSk(hzlSOlJCKFSWl7C3gxOHke3Tv)PKGlm7KupSOs81xOMfQ(tjbxy2jPEyrLOOlJ82cZd8cpWVfQzHgSW67ukQdsWfMDsI8eYrJwcYzva6TqfvCH4iaEHLliZbMhu4IIUmYBlu7(0bLjuUFs3MCwfGEDq3Tz8GcVBZfMDsQYvXhu3(rnCH0hu4DBqZvXh0cBzXh4TqgWI1QTqvAHtgTqaUnleZTzHiFHtgTW8DKFl0c5VWAHCBHNeJjBHwiaGfwuBIIw4KrleNX1b1wytN8PBJl0qfI72Q)usuFNKrsQhwuj(6luZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIIUmYBlmpWl8a)6thuMWe9t62KZQa0Rd6UnoJrE3w5UnXfGwsCgJCjk1Tv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUIkAGrmma5JimtLEyrf90yG6pLe13jzKK6HfvIVUIkIJa4fwUGmhyEqHlkIFAPT2A3TXfAOcXD7hP(tjXeFCMmsYjJKx(aj(6luZchgG8rWfMDss4SqqoRcqVfQzHgSq1FkjEepzQr5K4fw(cvuXfY4bzMKKtxe1wi4fQ8c1EHAw4Ju)PKyIpotgj5KrYlFGefDzK3wOcxiJhu4cUWStYlQ1qautqNj8Fi5GUu3MXdk8Unxy2j5f1AiaQ1NoOmHs1pPBtoRcqVoO72pQHlK(GcVBB06aATW2W1SWFd5hl0OmQfMBMSfALr(cZT8BHzCBHQe5l83Ox3gxOHke3Tv)PKadqCH52G8drrmEwOMfIJa4fwUGlm7KupSOsu0LrEBHAwOblu9NsI67Kmss9WIkXxFHkQ4cv)PKGlm7KupSOs81xO2DBCgJ8UTYDBgpOW72CHzNKxuRHaOwF6GYe5F)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8aVqZCHyvasmXCLx(SeNX1b162mEqH3T5cZojJsTpDqzIt1pPBtoRcqVoO724cnuH4UT6pLe13jzKK6HfvIV(cvuXfEzNf64zHkCHkFQUnJhu4DBUWStsvaUn9PdktCA7N0TjNvbOxh0DBgpOW72K5aZdk8UnYhQQV(irPU9LDwOJhfc2OFQUnYhQQV(ir3l9q8qDBL724cnuH4UT6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clVpDqzI8v)KUnJhu4DBUWStsvUk(G62KZQa0Rd6(0NU9nmtxYN(jDqPC)KUn5Ska96GUBJl0qfI723WmDjFepuByhtluHGxOYkPBZ4bfE3wfa5G0NoOmr)KUnJhu4DB9IAKJjzKKxK)62KZQa0Rd6(0bLs1pPBtoRcqVoO724cnuH4U9nmtxYhXd1g2X0cZBHkRKUnJhu4DBUWStYlQ1qauRpDqL)9t62mEqH3T5cZojJsTBtoRcqVoO7thuNQFs3MXdk8UDcvKufGBt3MCwfGEDq3N(0TRy4bfE)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBZ4bfEtuXWdk8CaRam7ycqY4bfUPOeygpOWfK5aZdkCboJDNaq(HMl7SqhpkeSs)uAmWiQVtPOoirdPNfUSnrDvur1FkjAi9SWLTjQROnmgeWQ)us0q6zHlBtuxXLplBdJbr7UnUqdviUBFzNf64zH5bEHM5cXQaKGmhsD8Sqnl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wyEGxiJhu4cYCG5bfUGot4)qYbDPfQOIlehbWlSCbxy2jPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqfvCHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cz8GcxqMdmpOWf0zc)hsoOlTqTxO2luZcv)PKO(ojJKupSOs8clFHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fw(c1SqJyH6fzwEGFcLft8XzYijNmsE5duF6GYe9t62KZQa0Rd6UnUqdviUBxFNsrDqIgsplCzBI6kiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWlKXdkCbzoW8GcxqNj8Fi5GUu3MXdk8UnzoW8GcVpDqPu9t62KZQa0Rd6UnJhu4DBUWStsvUk(G62pQHlK(GcVBdAUk(GwikTq0yyBHd6slCIf(B0cNyUlK93cTOfMXMPforSWl7ATqCgxhuRBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcXra8clxWfMDsQhwujk6YiVTW8aVq6mH)djh0LwOMfEzNf64zHkCHM5cXQaKG1LxKJU)R8Yol1XZc1Sq1FkjQVtYij1dlQeVWYxO29PdQ8VFs3MCwfGEDq3TXfAOcXDBCeaVWYft8XzYijNmsE5dKOi(P1c1SqdwO6pLeCHzNK4mUoirBymiluHl0mxiwfGetmx5LplXzCDqTfQzHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fsNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2DBgpOW72CHzNKQCv8b1NoOov)KUn5Ska96GUBJl0qfI724iaEHLlM4JZKrsozK8Yhirr8tRfQzHgSq1Fkj4cZojXzCDqI2WyqwOcxOzUqSkajMyUYlFwIZ46GAluZcnyHgXchgG8ruFNKrsQhwujiNvbO3cvuXfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKvOVqTxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1UBZ4bfE3Mlm7KuLRIpO(0b1PTFs3MCwfGEDq3TXfAOcXD7hP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSqWl8rQ)usu8dX(iB6CbI08hWPIvraOrlXLplBdJbzHAwOblu9NscUWSts9WIkXlS8fQOIlu9NscUWSts9WIkrrxg5TfMh4fEGFlu7fQzHgSq1FkjQVtYij1dlQeVWYxOIkUq1FkjQVtYij1dlQefDzK3wyEGx4b(TqT72mEqH3T5cZojv5Q4dQpDqLV6N0TjNvbOxh0DBCHgQqC3(fJO4hI9r205cerrxg5TfQWfA0xOIkUqdw4Ju)PKO4hI9r205ceP5pGtfRIaqJwI2WyqwOcxOswOMf(i1Fkjk(HyFKnDUarA(d4uXQia0OLOnmgKfM3cFK6pLef)qSpYMoxGin)bCQyveaA0sC5ZY2WyqwO2DBgpOW72CHzNKQaCB6thug9(jDBYzva61bD3gxOHke3Tv)PKqVOg5ysgj5f5pXxFHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHmEqHl4cZojvb42iOZe(pKCqxQBZ4bfE3Mlm7KufGBtF6GsP3pPBtoRcqVoO724mg5DBL72exaAjXzmYLOu3w9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kQObgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kQiocGxy5cYCG5bfUOi(PL2ARD3gxOHke3TFK6pLet8XzYijNmsE5dK4RVqnlCyaYhbxy2jjHZcb5Ska9wOMfAWcv)PK4r8KPgLtIxy5lurfxiJhKzssoDruBHGxOYlu7fQzHgSWhP(tjXeFCMmsYjJKx(ajk6YiVTqfUqgpOWfCHzNKxuRHaOMGot4)qYbDPfQOIlehbWlSCHErnYXKmsYlYFIIUmYBlurfxiomto7JaeTke7lu7UnJhu4DBUWStYlQ1qauRpDqPSs6N0TjNvbOxh0DBCHgQqC3w9NscmaXfMBdYpefX4zHAwO6pLe0zD2F0tQhd5dIbeF9UnJhu4DBUWStYlQ1qauRpDqPSY9t62KZQa0Rd6UnJhu4DBUWStYlQ1qauRBJZyK3TvUBJl0qfI72Q)usGbiUWCBq(HOigpluZcnyHQ)usWfMDsQhwuj(6lurfxO6pLe13jzKK6HfvIV(cvuXf(i1FkjM4JZKrsozK8Yhirrxg5TfQWfY4bfUGlm7K8IAnea1e0zc)hsoOlTqT7thukBI(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDB1FkjWaexyUni)queJNfQzHQ)usGbiUWCBq(HOnmgKfcEHQ)usGbiUWCBq(H4YNLTHXG0NoOuwP6N0TjNvbOxh0DBgpOW72CHzNKxuRHaOw3gNXiVBRC3gxOHke3Tv)PKadqCH52G8drrmEwOMfQ(tjbgG4cZTb5hIIUmYBlmpWl0GfAWcv)PKadqCH52G8drBymilm3VqgpOWfCHzNKxuRHaOMGot4)qYbDPfQ9cZzHh43c1UpDqPC(3pPBtoRcqVoO724cnuH4UTblSOurTmwfGwOIkUqJyHdcdcYpwO2luZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwO6pLeCHzNK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UTttgvYHU6uB6thukFQ(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQ1Tz8GcVBZfMDsgLAF6Gs5tB)KUn5Ska96GUBJl0qfI72x2zHoEwyEGxOs)uluZcv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8UD7RtLhM5(0bLY5R(jDBYzva61bD3gxOHke3Tv)PKO(aKmsYjRiQj(6luZcv)PKGlm7KeNX1bjAdJbzHkCHkv3MXdk8Unxy2jPka3M(0bLYg9(jDBYzva61bD3gxOHke3TVSZcD8SW8aVqZCHyvasOYvXhK8Yol1XZc1Sq1Fkj4cZoj1dlQeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1SWhP(tjXeFCMmsYjJKx(ajEHLVqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQzH4iaEHLliZbMhu4IIUmYBDBgpOW72CHzNKQCv8b1NoOuwP3pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWYxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1SWHbiFeCHzNKrPkiNvbO3c1SqCeaVWYfCHzNKrPkk6YiVTW8aVWd8BHAw4LDwOJNfMh4fQ0vYc1SqCeaVWYfK5aZdkCrrxg5TUnJhu4DBUWStsvUk(G6thuMqj9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NscUWSts9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkQ4cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLjuUFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeF9fQzHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkrrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwOblehbWlSCbzoW8Gcxu0LrEBHkQ4cRVtPOoibxy2jjYtihnAjiNvbO3c1UBZ4bfE3Mlm7KuLRIpO(0bLjmr)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs81xOMf(i1FkjM4JZKrsozK8Yhirrxg5TfMh4fEGFluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KuLRIpO(0bLjuQ(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk1PwOMfQ(tjbxy2jjoJRds0ggdYcvi4fAWcz8GmtsYPlIAlmFCHkVqTxOMfwFNsrDqcUWSts14QY17s(iiNvbO3c1SqgpiZKKC6IO2cv4cvEHAwO6pLepINm1OCs8clVBZ4bfE3Mlm7KuLRIpO(0bLjY)(jDBYzva61bD3gxOHke3ThUoOrKrmWKj0XZcZBHk1PwOMfQ(tjbxy2jjoJRds0ggdYcZBHQ)usWfMDsIZ46Gex(SSnmgKfQzH13PuuhKGlm7KunUQC9UKpcYzva6TqnlKXdYmjjNUiQTqfUqLxOMfQ(tjXJ4jtnkNeVWY72mEqH3T5cZojPZ6ardfEF6GYeNQFs3MXdk8Unxy2jPka3MUn5Ska96GUpDqzItB)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlu9NscUWSts9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3MmhyEqH3NoOmr(QFs3MXdk8Unxy2jPkxfFqDBYzva61bDF6t3ghbWlS8w)KoOuUFs3MCwfGEDq3Tz8GcVBNQOnspmZD7h1WfsFqH3TZVcffAqNo0c)nKFSWJc1a0AHimcdql0cnzlK1fl0OPrlenl0cnzlCI5UWyYOYc1ir3gxOHke3TRVtPOoiXrHAaAjryegGeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfQukzHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOswOMfAWcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKyI5kV8zjoJRdQTqnl0GfAWchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYf13jzKK6HfvIIUmYBlmpWl8a)wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKyI5kV8z5JayTKPOKS(c1EHkQ4cnyHgXchgG8ruFNKrsQhwujiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBluHl0mxiwfGetmx5LplFeaRLmfLK1xO2lurfxiocGxy5cUWSts9WIkrrxg5TfMh4fEGFlu7fQDF6GYe9t62KZQa0Rd6UnUqdviUBxFNsrDqIJc1a0sIWimajiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBle8cvYc1SqdwOrSWHbiFeKdGoYgYPNGCwfGElurfxOblCyaYhb5aOJSHC6jiNvbO3c1SWl7SqhpluHGxy(sjlu7fQ9c1SqdwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqfUqLvYc1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lurfxOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlujluZcv)PKGlm7KeNX1bjAdJbzHGxOswO2lu7fQzHQ)usuFNKrsQhwujEHLVqnl8Yol0XZcvi4fAMleRcqcwxEro6(VYl7SuhpDBgpOW72PkAJ0dZCF6GsP6N0TjNvbOxh0DBCHgQqC3U(oLI6GepudJ0bqoxAjXX9Y(tqoRcqVfQzH4iaEHLlu)PK8HAyKoaY5sljoUx2FII4NwluZcv)PK4HAyKoaY5sljoUx2FYufTr8clFHAwOblu9NscUWSts9WIkXlS8fQzHQ)usuFNKrsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5lu7fQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkzHAwOblu9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQOIl0GfAelCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqfvCH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO2DBgpOW72PkAJAam9PdQ8VFs3MCwfGEDq3TXfAOcXD767ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfIJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFATqnlu9NsIhQHr6aiNlTK44Ez)jtOIeVWYxOMfQxKz5b(juwKQOnQbW0Tz8GcVBNqfjvb420NoOov)KUn5Ska96GUBZ4bfE3(IQkQMmsYjQl5t3(rnCH0hu4D78Jr1cnzXjl0cnzlm3YVfIsleng2wioUi)yHF9f2IWfl80NwiAwOfcayHQ0c)n6Tql0KTWtIXKz6cXCBwiAwydaDKnaATqvkff1TXfAOcXDBCeaVWYft8XzYijNmsE5dKOOlJ82cZBHM5cXQaK4gJuVimrp5eZvQQ1cvuXfAWcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasCJrE5ZYhbWAjtrjz9fQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqIBmYlFw(iawlzkk5eZDHA3NoOoT9t62KZQa0Rd6UnUqdviUBJJa4fwUGlm7KupSOsue)0AHAwObl0iw4WaKpcYbqhzd50tqoRcqVfQOIl0Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfQqWlmFPKfQ9c1EHAwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvuXfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cvYc1Sq1Fkj4cZojXzCDqI2Wyqwi4fQKfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcVSZcD8SqfcEHM5cXQaKG1LxKJU)R8Yol1Xt3MXdk8U9fvvunzKKtuxYN(0bv(QFs3MCwfGEDq3Tz8GcVB)iEYuJYPU9JA4cPpOW725gGfRvBH)gTWhXtMAuoTql0KTqwxSWtFAHtm3fIAlSi(P1c52cTiaatx4LbHwy7x0cNyHyUnlenluLsrrlCI5k624cnuH4UnocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOswOMfQ(tjbxy2jjoJRds0ggdYcZd8cnZfIvbiXeZvE5ZsCgxhuBHAwiocGxy5cUWSts9WIkrrxg5TfMh4fEGF9PdkJE)KUn5Ska96GUBJl0qfI724iaEHLl4cZoj1dlQefDzK3wi4fQKfQzHgSqJyHddq(iihaDKnKtpb5Ska9wOIkUqdw4WaKpcYbqhzd50tqoRcqVfQzHx2zHoEwOcbVW8LswO2lu7fQzHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHkRKfQzHQ)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXGSqTxOIkUqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOswOMfQ(tjbxy2jjoJRds0ggdYcbVqLSqTxO2luZcv)PKO(ojJKupSOs8clFHAw4LDwOJNfQqWl0mxiwfGeSU8IC09FLx2zPoE62mEqH3TFepzQr5uF6GsP3pPBtoRcqVoO72mEqH3Tl(HyFKnDUaPB)OgUq6dk8UTrtJwytNlqwikTWjM7cz)TqwFHCrlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAz6cVmii)yHTFrl0IwygBMwipleG42SWXkwixy2PfIZ46GAlK93cNmEw4eZDHwCZnCw4PB)2SWFJEIUnUqdviUBJJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajQM8YNLpcG1sMIsoXCxOMfIJa4fwUGlm7KupSOsu0LrEBHkCHM5cXQaKOAYlFw(iawlzkkjRVqnl0Gfoma5JO(ojJKupSOsqoRcqVfQzHgSqCeaVWYf13jzKK6HfvIIUmYBlmVfsNj8Fi5GU0cvuXfIJa4fwUO(ojJKupSOsu0LrEBHkCHM5cXQaKOAYlFw(iawlzkkzf6lu7fQOIl0iw4WaKpI67Kmss9WIkb5Ska9wO2luZcv)PKGlm7KeNX1bjAdJbzHkCHMyHAw4Ju)PKyIpotgj5KrYlFGeVWYxOMfQ(tjr9DsgjPEyrL4fw(c1Sq1Fkj4cZoj1dlQeVWY7thukRK(jDBYzva61bD3MXdk8UDXpe7JSPZfiD7h1WfsFqH3TnAA0cB6CbYcTqt2cz9fALr(c1JwdPcqIfE6tlCI5UquBHfXpTwi3wOfbay6cVmi0cB)Iw4eleZTzHOzHQukkAHtmxr3gxOHke3TXra8clxmXhNjJKCYi5LpqIIUmYBlmVfsNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkajMyUYlFwIZ46GAluZcXra8clxWfMDsQhwujk6YiVTW8wOblKot4)qYbDPfMZcz8GcxmXhNjJKCYi5Lpqc6mH)djh0LwO29PdkLvUFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBlmVfsNj8Fi5GU0c1SqdwObl0iw4WaKpcYbqhzd50tqoRcqVfQOIl0Gfoma5JGCa0r2qo9eKZQa0BHAw4LDwOJNfQqWlmFPKfQ9c1EHAwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvuXfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cvYc1Sq1Fkj4cZojXzCDqI2Wyqwi4fQKfQ9c1EHAwO6pLe13jzKK6HfvIxy5luZcVSZcD8SqfcEHM5cXQaKG1LxKJU)R8Yol1XZc1UBZ4bfE3U4hI9r205cK(0bLYMOFs3MCwfGEDq3Tz8GcVBpXhNjJKCYi5LpqD7h1WfsFqH3TnAA0cNyUl0cnzlK1xikTq0yyBHwOjd5lCYOfE5Zl8raSwIfE6tl0JX0f(B0cTqt2cRqFHO0cNmAHddq(SquBHddc5MUq2Fleng2wOfAYq(cNmAHx(8cFeaRLOBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8aVqZCHyvasmXCLx(SeNX1b1wOMfIJa4fwUGlm7KupSOsu0LrEBH5bEH0zc)hsoOlTqnl8Yol0XZcv4cnZfIvbibRlVihD)x5LDwQJNfQzHQ)usuFNKrsQhwujEHL3NoOuwP6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cPZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6luZcXra8clxWfMDsQhwujk6YiVTqfUqLnr3MXdk8U9eFCMmsYjJKx(a1NoOuo)7N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfMh4fAMleRcqIjMR8YNL4mUoO2c1SqdwOrSWHbiFe13jzKK6HfvcYzva6TqfvCH4iaEHLlQVtYij1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkzf6lu7fQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjR3Tz8GcVBpXhNjJKCYi5Lpq9PdkLpv)KUn5Ska96GUBZ4bfE3Mlm7KupSOQB)OgUq6dk8UTrtJwiRVquAHtm3fIAlm8fIFlK93cTc3WzHQ0c)6lmf1cbc)GQfozSVWjJw4LpVWhbWAz6cVmii)yHTFrlCY4zHw0cZyZ0cjp(hzl8YoVq2FlCY4zHtgv0crTf6XSqgOi(P1c5fwFNwyKwOEyr1cFHLl624cnuH4UnocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1SqdwOrSqCyMC2hHzYNmTQfQOIlehbWlSCXfvvunzKKtuxYhrrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjVXSqTxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1Sq1FkjQVtYij1dlQeVWYxOMfEzNf64zHke8cnZfIvbibRlVihD)x5LDwQJN(0bLYN2(jDBYzva61bD3MXdk8UD9DsgjPEyrv3(rnCH0hu4DBJMgTWk0xikTWjM7crTfg(cXVfY(BHwHB4SqvAHF9fMIAHaHFq1cNm2x4Krl8YNx4JayTmDHxgeKFSW2VOfozurle1CdNfYafXpTwiVW670cFHLVq2FlCY4zHS(cTc3WzHQeoU0czZmcGvbOf((fYpwy9Ds0TXfAOcXDB1Fkj4cZoj1dlQeVWYxOMfAWcXra8clxmXhNjJKCYi5LpqIIUmYBluHl0mxiwfGevOlV8z5JayTKPOKtm3fQOIlehbWlSCbxy2jPEyrLOOlJ82cZd8cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwOMfIJa4fwUGlm7KupSOsu0LrEBHkCHkBI(0bLY5R(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8clFHAwiocGxy5cUWSts9WIkXuFsw0LrEBHkCHmEqHlAzO0G8dPEyrLa)QfQzHQ)usuFNKrsQhwujEHLVqnlehbWlSCr9DsgjPEyrLyQpjl6YiVTqfUqgpOWfTmuAq(HupSOsGF1c1SWhP(tjXeFCMmsYjJKx(ajEHL3Tz8GcVB3YqPb5hs9WIQ(0bLYg9(jDBYzva61bD3MXdk8UTErnYXKmsYlYFD7h1WfsFqH3TnAA0c1J7cNyHT85NOthAHSVq68u8cz1fI8foz0cD68SqCeaVWYxOfYFHLPl87auRTqq0QqSVWjJ8fgoGwl89lKFSqUWStlupSOAHVpTWjwywyTWl78cZ((rP1cl(HyFwytNlqwiQ1TXfAOcXD7HbiFe13jzKK6HfvcYzva6Tqnlu9NscUWSts9WIkXxFHAwO6pLe13jzKK6HfvIIUmYBlmVfEGFIlFUpDqPSsVFs3MCwfGEDq3TXfAOcXD7hP(tjXeFCMmsYjJKx(aj(6luZcFK6pLet8XzYijNmsE5dKOOlJ82cZBHmEqHl4cZojVOwdbqnbDMW)HKd6sluZcnIfIdZKZ(iarRcXE3MXdk8UTErnYXKmsYlYF9PdktOK(jDBYzva61bD3gxOHke3Tv)PKO(ojJKupSOs81xOMfQ(tjr9DsgjPEyrLOOlJ82cZBHh4N4YNxOMfIJa4fwUGmhyEqHlkIFATqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTqnl0iwiomto7JaeTke7DBgpOW726f1ihtYijVi)1N(0TFuI)at)KoOuUFs3MXdk8Uno((qvtNaa62KZQa0Rd6(0bLj6N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TvUBJl0qfI72M5cXQaKiJntYqNC6TqWlujluZc1lYS8a)ekliZbMhu4luZcnIfAWcRVtPOoirdPNfUSnrDfKZQa0BHkQ4cRVtPOoiXqx9OyaPfx6cYzva6TqT72M5s68L62zSzsg6KtV(0bLs1pPBtoRcqVoO72HE3Urt3MXdk8UTzUqSka1TnZaFQBRC3gxOHke3TnZfIvbirgBMKHo50BHGxOswOMfQ(tjbxy2jPEyrL4fw(c1SqCeaVWYfCHzNK6HfvIIUmYBluZcnyH13PuuhKOH0Zcx2MOUcYzva6TqfvCH13PuuhKyOREumG0IlDb5Ska9wO2DBZCjD(sD7m2mjdDYPxF6Gk)7N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TvUBJl0qfI72Q)usWfMDsIZ46GeTHXGSqWlu9NscUWStsCgxhK4YNLTHXGSqnl0iwO6pLe1hGKrsozfrnXxFHAwOA0AluZctOJSrw0LrEBH5bEHgSqdw4LDEHkyHmEqHl4cZojvb42iWrBwO2lm3VqgpOWfCHzNKQaCBe0zc)hsoOlTqT72M5s68L62jKZas1F59PdQt1pPBtoRcqVoO724cnuH4UTblCyaYhb5aOJSHC6jiNvbO3c1SWl7SqhplmpWl0ORKfQzHx2zHoEwOcbVWt7PwO2lurfxObl0iw4WaKpcYbqhzd50tqoRcqVfQzHx2zHoEwyEGxOr)ulu7UnJhu4D7l7S8GU9PdQtB)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwuj(6DBgpOW726XGcVpDqLV6N0TjNvbOxh0DBCHgQqC3U(oLI6GedD1JIbKwCPliNvbO3c1Sq1FkjOZz8VnOWfF9fQzHgSqCeaVWYfCHzNK6HfvII4NwlurfxOA0AluZctOJSrw0LrEBH5bEH5VswO2DBgpOW72d6sslU07thug9(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8clFHAwO6pLe13jzKK6HfvIxy5luZcFK6pLet8XzYijNmsE5dK4fwE3MXdk8Una6iBAYt3(VJl5tF6GsP3pPBtoRcqVoO724cnuH4UT6pLeCHzNK6HfvIxy5luZcv)PKO(ojJKupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY72mEqH3Tv5dzKKtHWG06thukRK(jDBYzva61bD3gxOHke3Tv)PKGlm7KupSOs8172mEqH3TvPQrfii)OpDqPSY9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4R3Tz8GcVBRceXtM(Lw9PdkLnr)KUn5Ska96GUBJl0qfI72Q)usWfMDsQhwuj(6DBgpOW72jurQar86thukRu9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4R3Tz8GcVBZoMAtXasmda0NoOuo)7N0TjNvbOxh0DBCHgQqC3w9NscUWSts9WIkXxVBZ4bfE3(3ijAOBRpDqP8P6N0TjNvbOxh0DBgpOW72ha8dXtunPk)oOUnUqdviUBR(tjbxy2jPEyrL4RVqfvCH4iaEHLl4cZoj1dlQefDzK3wOcbVWtDQfQzHps9NsIj(4mzKKtgjV8bs8172ukr4r68L62ha8dXtunPk)oO(0bLYN2(jDBYzva61bD3MXdk8UnD11Qigqg1ZzhtDBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cZd8cnyHkRulmNfMVwyUFHM5cXQaKG1LHl)nAHA3TD(sDB6QRvrmGmQNZoM6thukNV6N0TjNvbOxh0DBgpOW72VI4xcvK0m1Aeq3gxOHke3TXra8clxWfMDsQhwujk6YiVTqfcEHMqjlurfxOrSqZCHyvasW6YWL)gTqWlu5fQOIl0GfoOlTqWlujluZcnZfIvbirc1Yq(Hm0jNQfcEHkVqnlS(oLI6GenKEw4Y2e1vqoRcqVfQD325l1TFfXVeQiPzQ1iG(0bLYg9(jDBYzva61bD3MXdk8UDl(as0HJgQ624cnuH4UnocGxy5cUWSts9WIkrrxg5TfQqWluPuYcvuXfAel0mxiwfGeSUmC5Vrle8cvUB78L62T4dirhoAOQpDqPSsVFs3MCwfGEDq3Tz8GcVBFaOLEMmssU1qxeapOW724cnuH4UnocGxy5cUWSts9WIkrrxg5TfQqWl0ekzHkQ4cnIfAMleRcqcwxgU83OfcEHkVqfvCHgSWbDPfcEHkzHAwOzUqSkajsOwgYpKHo5uTqWlu5fQzH13PuuhKOH0Zcx2MOUcYzva6TqT72oFPU9bGw6zYij5wdDra8GcVpDqzcL0pPBtoRcqVoO72mEqH3TVmMvls2YiAK3FdH724cnuH4UnocGxy5cUWSts9WIkrrxg5TfMh4fEQfQzHgSqJyHM5cXQaKiHAzi)qg6Kt1cbVqLxOIkUWbDPfQWfQukzHA3TD(sD7lJz1IKTmIg593q4(0bLjuUFs3MCwfGEDq3Tz8GcVBFzmRwKSLr0iV)gc3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBlmpWl8uluZcnZfIvbirc1Yq(Hm0jNQfcEHkVqnlu9NsI67Kmss9WIkXxFHAwO6pLe13jzKK6HfvIIUmYBlmpWl0GfQSswy(4cp1cZ9lS(oLI6GenKEw4Y2e1vqoRcqVfQ9c1SWbDPfM3cvkL0TD(sD7lJz1IKTmIg593q4(0bLjmr)KUn5Ska96GUBJl0qfI72mEqMjj50frTfQWfAIUDBkeE6Gs5UnJhu4DBmdaiz8GcxcGAt3ga1gPZxQBZb1NoOmHs1pPBtoRcqVoO724cnuH4Unomto7JaeTke7luZcRVtPOoibxy2jjYtihnAjiNvbO3c1SWHbiFe13jzKK6HfvcYzva61TBtHWthuk3Tz8GcVBJzaajJhu4sauB62aO2iD(sD7mUUHRvF6GYe5F)KUn5Ska96GUB)OgUq6dk8U9jz0ctOwgYpwyOtovluLoqEBHwOjBH57i)wi7VfMqTmQTWuul0OmQfQxbUTWjw4Vrl89lKFSWtIXKPGCl)62mEqH3TXmaGKXdkCjaQnD72ui80bLYDBCHgQqC32mxiwfGezSzsg6KtVfcEHkzHAwOzUqSkajsOwgYpKHo5u1TbqTr68L62juld5hYqNCQ6thuM4u9t62KZQa0Rd6UnUqdviUBBMleRcqIm2mjdDYP3cbVqL0TBtHWthuk3Tz8GcVBJzaajJhu4sauB62aO2iD(sD7qNCQ6thuM402pPBtoRcqVoO724cnuH4UDJMb5hnbFLnD(UqWlu5UDBkeE6Gs5UnJhu4DBmdaiz8GcxcGAt3ga1gPZxQBZxztNV9PdktKV6N0TjNvbOxh0DBgpOW72ygaqY4bfUea1MUnaQnsNVu3ghbWlS8wF6GYeg9(jDBYzva61bD3gxOHke3TnZfIvbirc5mGu9x(cbVqL0TBtHWthuk3Tz8GcVBJzaajJhu4sauB62aO2iD(sD7kgEqH3NoOmHsVFs3MCwfGEDq3TXfAOcXDBZCHyvasKqodiv)LVqWlu5UDBkeE6Gs5UnJhu4DBmdaiz8GcxcGAt3ga1gPZxQBNqodiv)L3NoOukL0pPBtoRcqVoO72mEqH3TXmaGKXdkCjaQnDBauBKoFPU9nmtxYN(0NUTEr44QYt)KoOuUFs3MXdk8Unxy2jjYhcaGWt3MCwfGEDq3NoOmr)KUnJhu4D72)EdxYfMDsM4lcaXv3MCwfGEDq3NoOuQ(jDBgpOW724WpD7xK8YolpOB3MCwfGEDq3NoOY)(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L628v205B3(rj(dmD7gndYpAc(kB68TpDqDQ(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62K5qQJNU9Js8hy62kFQ(0b1PTFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMlPZxQBRxK(haqsMJUnUqdviUBBWcRVtPOoirdPNfUSnrDfKZQa0BHAwiJhKzssoDruBHkCHkVWCwOblu5fM7xObl0iwiomto7JWjCfar9wO2lu7fQD32md8jjb0OUTs62MzGp1TvUpDqLV6N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62M5s68L62zSzsg6KtVUnUqdviUBBWcz8GmtsYPlIAluHl0elurfxOzUqSkaj0ls)daijZXcbVqLxOIkUqZCHyvasWxztNVle8cvEHA3TnZaFssanQBRKUTzg4tDBL7thug9(jDBYzva61bD3o072nA62mEqH3TnZfIvbOUTzg4tDBL0TnZL05l1TtiNbKQ)Y7thuk9(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62MCLM8raSwaOlAK5w(1TFuI)at3w5t1NoOuwj9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1Tn5knPErTHXGG8d5GUu3(rj(dmDBLEF6GszL7N0TjNvbOxh0D7qVBxuJMUnJhu4DBZCHyvaQBBMlPZxQBBYvAsJ28nOtrLVTLpcG1QB)Oe)bMUTYkPpDqPSj6N0TjNvbOxh0D7qVBxuJMUnJhu4DBZCHyvaQBBMlPZxQBxn5LplFeaRLmfLCI52TFuI)at3(u9PdkLvQ(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62vtE5ZYhbWAjtrjRqVB)Oe)bMU9P6thukN)9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TRM8YNLpcG1sMIsY6D7hL4pW0TnHs6thukFQ(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L623yK6fHj6jNyUsvT62pkXFGPBRu9PdkLpT9t62KZQa0Rd6UDO3TlQrt3MXdk8UTzUqSka1TnZL05l1TVXiV8z5JayTKPOKtm3U9Js8hy62kRK(0bLY5R(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L623yKx(S8raSwYuuswVB)Oe)bMUTYNQpDqPSrVFs3MCwfGEDq3Td9UDrnA62mEqH3TnZfIvbOUTzUKoFPUnRlV8z5JayTKPOKtm3U9Js8hy62kRK(0bLYk9(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62SU8YNLpcG1sMIsEJPB)Oe)bMUTjusF6GYekPFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMb(u32ekzH5Jl0GfEQfM7xio83hncUWSts9kEOdTeKZQa0BHA3TnZL05l1TRqxE5ZYhbWAjtrjNyU9PdktOC)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32mxsNVu3EI5kV8z5JayTKPOKSE3gxOHke3TnyH4Wm5SpchDKnYetlurfxObleh(7Jgbxy2jPEfp0HwcYzva6TqnlKXdYmjjNUiQTW8wOsTqTxO2DBZmWNKeqJ62NQBBMb(u3w5t1NoOmHj6N0TjNvbOxh0D7qVB3OPBZ4bfE32mxiwfG62MzGp1TnHswy(4cnyHg9fM7xio83hncUWSts9kEOdTeKZQa0BHA3TnZL05l1TNyUYlFw(iawlzkkzf69PdktOu9t62KZQa0Rd6UDO3TB00Tz8GcVBBMleRcqDBZmWN62NwLSW8XfAWcVCBOslPzg4tlm3VqLvIswO2DBCHgQqC3ghMjN9r4OJSrMyQBBMlPZxQBRYvXhK8Yol1XtF6GYe5F)KUn5Ska96GUBh6D7gnDBgpOW72M5cXQau32md8PUTs)ulmFCHgSWl3gQ0sAMb(0cZ9luzLOKfQD3gxOHke3TXHzYzFeGOvHyVBBMlPZxQBRYvXhK8Yol1XtF6GYeNQFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMb(u32ORKfMpUqdw4LBdvAjnZaFAH5(fQSsuYc1UBJl0qfI72M5cXQaKqLRIpi5LDwQJNfcEHkPBBMlPZxQBRYvXhK8Yol1XtF6GYeN2(jDBYzva61bD3o072f1OPBZ4bfE32mxiwfG62M5s68L62SU8IC09FLx2zPoE62pkXFGPBR8P6thuMiF1pPBtoRcqVoO72HE3UOgnDBgpOW72M5cXQau32mxsNVu3EI5kV8zjoJRdQ1TFuI)at32e9Pdkty07N0TjNvbOxh0D7qVBxuJMUnJhu4DBZCHyvaQBBMlPZxQBZbjNyUYlFwIZ46GAD7hL4pW0TnrF6GYek9(jDBYzva61bD3o072nA62mEqH3TnZfIvbOUTzg4tDBLxyUFHgSqkF(r660tqxDTkIbKr9C2X0cvuXfAWchgG8ruFNKrsQhwujiNvbO3c1Sqdw4WaKpcUWStscNfcYzva6TqfvCHgXcXHzYzFeGOvHyFHAVqnl0GfAelehMjN9r4eUcGOElurfxiJhKzssoDruBHGxOYlurfxy9Dkf1bjAi9SWLTjQRGCwfGElu7fQ9c1UBBMlPZxQBNqTmKFidDYPQpDqPukPFs3MCwfGEDq3Td9UDJMUnJhu4DBZCHyvaQBBMb(u3MYNFKUo9exgZQfjBzenY7VHWlurfxiLp)iDD6joa4hINOAsv(DqlurfxiLp)iDD6joa4hINOAYl9yaau4lurfxiLp)iDD6jECbYncx(imis9)uudtoMwOIkUqkF(r660tG8gU(dRcqY85N95FLpYmctlurfxiLp)iDD6jAXhaGMb5hY6RQ1cvuXfs5ZpsxNEI23vbI4j5lnzA1MfQOIlKYNFKUo9ewmiKtvtMQWFlurfxiLp)iDD6jsa8LKrsQYZaqDBZCjD(sDBwxgU83O(0bLsPC)KUn5Ska96GUBh6D7IA00Tz8GcVBBMleRcqDBZCjD(sDBoi5eZvE5ZsCgxhuRB)Oe)bMUTj6thukLj6N0TjNvbOxh0D7qVBxuJMUnJhu4DBZCHyvaQBBMlPZxQBtMdPoE62pkXFGPBR8P6thukLs1pPBZ4bfE3(IQkkj6Yhu3MCwfGEDq3NoOuQ8VFs3MCwfGEDq3TXfAOcXDBJyHM5cXQaKqVi9paGKmhle8cvEHAwy9Dkf1bjEOggPdGCU0sIJ7L9NGCwfGEDBgpOW72PkAJAam9PdkL6u9t62KZQa0Rd6UnUqdviUBBel0mxiwfGe6fP)baKK5yHGxOYluZcnIfwFNsrDqIhQHr6aiNlTK44Ez)jiNvbOx3MXdk8Unxy2jPka3M(0bLsDA7N0TjNvbOxh0DBCHgQqC32mxiwfGe6fP)baKK5yHGxOYDBgpOW72K5aZdk8(0NUnFLnD(2pPdkL7N0TjNvbOxh0DBgpOW72K5aZdk8U9JA4cPpOW72mEqH3e8v205lym7ycqY4bfUPOeygpOWfK5aZdkCboJDNaq(HMl7SqhpkeSs)uDBCHgQqC3(Yol0XZcZd8cnZfIvbibzoK64zHAwOblehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqgpOWfK5aZdkCbDMW)HKd6slurfxiocGxy5cUWSts9WIkrrxg5TfMh4fY4bfUGmhyEqHlOZe(pKCqxAHkQ4cnyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fY4bfUGmhyEqHlOZe(pKCqxAHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1Sq1Fkj4cZoj1dlQeVWYxOMf(i1FkjM4JZKrsozK8YhiXlS8(0bLj6N0TjNvbOxh0DBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cbVqLSqnl0GfQ(tjr9DsgjPEyrL4fw(c1SqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7cvuXfIJa4fwUyIpotgj5KrYlFGefDzK3wi4fQKfQ9c1UBZ4bfE3(r8KPgLt9PdkLQFs3MCwfGEDq3TXfAOcXDBCeaVWYfCHzNK6HfvIIUmYBle8cvYc1SqdwO6pLe13jzKK6HfvIxy5luZcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUlurfxiocGxy5Ij(4mzKKtgjV8bsu0LrEBHGxOswO2lu7UnJhu4D7lQQOAYijNOUKp9PdQ8VFs3MXdk8UDXpe7JSPZfiDBYzva61bDF6G6u9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4fw(c1SqCeaVWYfCHzNK6HfvIP(KSOlJ82cv4cz8Gcx0YqPb5hs9WIkb(vluZcv)PKO(ojJKupSOs8clFHAwiocGxy5I67Kmss9WIkXuFsw0LrEBHkCHmEqHlAzO0G8dPEyrLa)QfQzHps9NsIj(4mzKKtgjV8bs8clVBZ4bfE3ULHsdYpK6Hfv9PdQtB)KUn5Ska96GUBJl0qfI72Q)usuFNKrsQhwujEHLVqnlehbWlSCbxy2jPEyrLOOlJ8w3MXdk8UD9DsgjPEyrvF6GkF1pPBtoRcqVoO724cnuH4UTblehbWlSCbxy2jPEyrLOOlJ82cbVqLSqnlu9NsI67Kmss9WIkXlS8fQ9cvuXfQxKz5b(juwuFNKrsQhwu1Tz8GcVBpXhNjJKCYi5Lpq9PdkJE)KUn5Ska96GUBJl0qfI724iaEHLl4cZoj1dlQefDzK3wyEl8ukzHAwO6pLe13jzKK6HfvIxy5luZcPwJCmjmJAOWLrsQtvIWdkCb5Ska962mEqH3TN4JZKrsozK8YhO(0bLsVFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOMfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI52Tz8GcVBZfMDsQhwu1NoOuwj9t62KZQa0Rd6UnUqdviUBR(tjbxy2jPEyrL4RVqnlu9NscUWSts9WIkrrxg5TfMh4fY4bfUGlm7K8IAnea1e0zc)hsoOlTqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKUnJhu4DBUWStsvUk(G6thukRC)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wO6pLeCHzNK4mUoiXLplBdJbzHAwO6pLe13jzKK6HfvIxy5luZcv)PKGlm7KupSOs8clFHAw4Ju)PKyIpotgj5KrYlFGeVWY72mEqH3T5cZojJsTpDqPSj6N0TjNvbOxh0DBCHgQqC3w9NsI67Kmss9WIkXlS8fQzHQ)usWfMDsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5luZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KuLRIpO(0bLYkv)KUn5Ska96GUBJZyK3TvUBtCbOLeNXixIsDB1FkjWaexyUni)qIZy3jaXlSCngO(tjbxy2jPEyrL4RROIQ)usuFNKrsQhwuj(6kQiocGxy5cYCG5bfUOi(PL2DBCHgQqC3w9NscmaXfMBdYpefX4PBZ4bfE3Mlm7K8IAnea16thukN)9t62KZQa0Rd6UnoJrE3w5UnXfGwsCgJCjk1Tv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUIkQ(tjr9DsgjPEyrL4RROI4iaEHLliZbMhu4II4NwA3TXfAOcXDBJyH8PdvOHeCHzNK6)7Laq(HGCwfGElurfxO6pLeyaIlm3gKFiXzS7eG4fwE3MXdk8Unxy2j5f1AiaQ1NoOu(u9t62KZQa0Rd6UnUqdviUBR(tjr9DsgjPEyrL4fw(c1Sq1Fkj4cZoj1dlQeVWYxOMf(i1FkjM4JZKrsozK8YhiXlS8UnJhu4DBYCG5bfEF6Gs5tB)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7Kmk1(0bLY5R(jDBgpOW72CHzNKQCv8b1TjNvbOxh09PdkLn69t62mEqH3T5cZojvb420TjNvbOxh09PpDBoO(jDqPC)KUn5Ska96GUBJl0qfI7213PuuhK4HAyKoaY5sljoUx2FcYzva6TqnlehbWlSCH6pLKpudJ0bqoxAjXX9Y(tue)0AHAwO6pLepudJ0bqoxAjXX9Y(tMQOnIxy5luZcnyHQ)usWfMDsQhwujEHLVqnlu9NsI67Kmss9WIkXlS8fQzHps9NsIj(4mzKKtgjV8bs8clFHAVqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlujluZcnyHQ)usWfMDsIZ46GeTHXGSW8aVqZCHyvasWbjNyUYlFwIZ46GAluZcnyHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cpWVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqTxOIkUqdwOrSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9cvuXfIJa4fwUGlm7KupSOsu0LrEBH5bEHh43c1EHA3Tz8GcVBNQOnQbW0NoOmr)KUn5Ska96GUBJl0qfI72gSW67ukQds8qnmsha5CPLeh3l7pb5Ska9wOMfIJa4fwUq9NsYhQHr6aiNlTK44Ez)jkIFATqnlu9NsIhQHr6aiNlTK44Ez)jtOIeVWYxOMfQxKz5b(juwKQOnQbWSqTxOIkUqdwy9Dkf1bjEOggPdGCU0sIJ7L9NGCwfGEluZch0LwyElu5fQD3MXdk8UDcvKufGBtF6GsP6N0TjNvbOxh0DBCHgQqC3U(oLI6GehfQbOLeHryasqoRcqVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOsPKfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkzHAwOblu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAwObl0Gfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLlQVtYij1dlQefDzK3wyEGx4b(TqnlehbWlSCbxy2jPEyrLOOlJ82cv4cnZfIvbiXeZvE5ZYhbWAjtrjz9fQ9cvuXfAWcnIfoma5JO(ojJKupSOsqoRcqVfQzH4iaEHLl4cZoj1dlQefDzK3wOcxOzUqSkajMyUYlFw(iawlzkkjRVqTxOIkUqCeaVWYfCHzNK6HfvIIUmYBlmpWl8a)wO2lu7UnJhu4D7ufTr6HzUpDqL)9t62KZQa0Rd6UnUqdviUBxFNsrDqIJc1a0sIWimajiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBle8cvYc1SqdwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvuXfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cvYc1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQ9c1EHAwO6pLe13jzKK6HfvIxy5lu7UnJhu4D7ufTr6HzUpDqDQ(jDBYzva61bD3gxOHke3TRVtPOoirdPNfUSnrDfKZQa0BHAwOErMLh4NqzbzoW8GcVBZ4bfE3EIpotgj5KrYlFG6thuN2(jDBYzva61bD3gxOHke3TRVtPOoirdPNfUSnrDfKZQa0BHAwObluViZYd8tOSGmhyEqHVqfvCH6fzwEGFcLft8XzYijNmsE5d0c1UBZ4bfE3Mlm7KupSOQpDqLV6N0TjNvbOxh0DBCHgQqC3EqxAHkCHkLswOMfwFNsrDqIgsplCzBI6kiNvbO3c1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkzHAwiocGxy5cUWSts9WIkrrxg5TfMh4fEGFDBgpOW72K5aZdk8(0bLrVFs3MCwfGEDq3Tz8GcVBtMdmpOW72iFOQ(6JeL62Q)us0q6zHlBtuxrBymiGv)PKOH0Zcx2MOUIlFw2ggds3g5dv1xFKO7LEiEOUTYDBCHgQqC3EqxAHkCHkLswOMfwFNsrDqIgsplCzBI6kiNvbO3c1SqCeaVWYfCHzNK6HfvIIUmYBle8cvYc1SqdwObl0GfIJa4fwUyIpotgj5KrYlFGefDzK3wOcxOzUqSkajyD5LplFeaRLmfLCI5Uqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvuXfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cvYc1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQ9c1EHAwO6pLe13jzKK6HfvIxy5lu7(0bLsVFs3MCwfGEDq3TXfAOcXDBdwiocGxy5cUWSts9WIkrrxg5TfQWfM)NAHkQ4cXra8clxWfMDsQhwujk6YiVTW8aVqLAHAVqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlujluZcnyHQ)usWfMDsIZ46GeTHXGSW8aVqZCHyvasWbjNyUYlFwIZ46GAluZcnyHgSWHbiFe13jzKK6HfvcYzva6TqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cpWVfQzH4iaEHLl4cZoj1dlQefDzK3wOcx4PwO2lurfxObl0iw4WaKpI67Kmss9WIkb5Ska9wOMfIJa4fwUGlm7KupSOsu0LrEBHkCHNAHAVqfvCH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO2DBgpOW72xuvr1KrsorDjF6thukRK(jDBYzva61bD3gxOHke3TXra8clxmXhNjJKCYi5LpqIIUmYBlmVfsNj8Fi5GU0c1SqdwO6pLeCHzNK4mUoirBymilmpWl0mxiwfGeCqYjMR8YNL4mUoO2c1SqdwOblCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxuFNKrsQhwujk6YiVTW8aVWd8BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQOIl0GfAelCyaYhr9DsgjPEyrLGCwfGEluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqfvCH4iaEHLl4cZoj1dlQefDzK3wyEGx4b(TqTxO2DBgpOW72f)qSpYMoxG0NoOuw5(jDBYzva61bD3gxOHke3TXra8clxWfMDsQhwujk6YiVTW8wiDMW)HKd6sluZcnyHgSqdwiocGxy5Ij(4mzKKtgjV8bsu0LrEBHkCHM5cXQaKG1Lx(S8raSwYuuYjM7c1Sq1Fkj4cZojXzCDqI2Wyqwi4fQ(tjbxy2jjoJRdsC5ZY2WyqwO2lurfxOblehbWlSCXeFCMmsYjJKx(ajk6YiVTqWlujluZcv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wO2lu7fQzHQ)usuFNKrsQhwujEHLVqT72mEqH3Tl(HyFKnDUaPpDqPSj6N0TjNvbOxh0DBCHgQqC3ghbWlSCbxy2jPEyrLOOlJ82cbVqLSqnl0GfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAMleRcqcwxE5ZYhbWAjtrjNyUluZcv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAVqfvCHgSqCeaVWYft8XzYijNmsE5dKOOlJ82cbVqLSqnlu9NscUWStsCgxhKOnmgKfMh4fAMleRcqcoi5eZvE5ZsCgxhuBHAVqTxOMfQ(tjr9DsgjPEyrL4fw(c1UBZ4bfE3(r8KPgLt9PdkLvQ(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5bEHM5cXQaKGdsoXCLx(SeNX1b1wOMfAWcnyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5I67Kmss9WIkrrxg5TfMh4fEGFluZcXra8clxWfMDsQhwujk6YiVTqfUqZCHyvasmXCLx(S8raSwYuuswFHAVqfvCHgSqJyHddq(iQVtYij1dlQeKZQa0BHAwiocGxy5cUWSts9WIkrrxg5TfQWfAMleRcqIjMR8YNLpcG1sMIsY6lu7fQOIlehbWlSCbxy2jPEyrLOOlJ82cZd8cpWVfQD3MXdk8U9eFCMmsYjJKx(a1NoOuo)7N0TjNvbOxh0DBCHgQqC32GfAWcXra8clxmXhNjJKCYi5LpqIIUmYBluHl0mxiwfGeSU8YNLpcG1sMIsoXCxOMfQ(tjbxy2jjoJRds0ggdYcbVq1Fkj4cZojXzCDqIlFw2ggdYc1EHkQ4cnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfcEHkzHAwO6pLeCHzNK4mUoirBymilmpWl0mxiwfGeCqYjMR8YNL4mUoO2c1EHAVqnlu9NsI67Kmss9WIkXlS8UnJhu4DBUWSts9WIQ(0bLYNQFs3MCwfGEDq3TXfAOcXDB1FkjQVtYij1dlQeVWYxOMfAWcnyH4iaEHLlM4JZKrsozK8Yhirrxg5TfQWfAcLSqnlu9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQ9cvuXfAWcXra8clxmXhNjJKCYi5LpqIIUmYBle8cvYc1Sq1Fkj4cZojXzCDqI2WyqwyEGxOzUqSkaj4GKtmx5LplXzCDqTfQ9c1EHAwOblehbWlSCbxy2jPEyrLOOlJ82cv4cv2elurfx4Ju)PKyIpotgj5KrYlFGeF9fQD3MXdk8UD9DsgjPEyrvF6Gs5tB)KUn5Ska96GUBJl0qfI724iaEHLl4cZojJsvu0LrEBHkCHNAHkQ4cnIfoma5JGlm7Kmkvb5Ska962mEqH3TBzO0G8dPEyrvF6Gs58v)KUn5Ska96GUBJl0qfI72Q)us8iEYuJYjXxFHAw4Ju)PKyIpotgj5KrYlFGeF9fQzHps9NsIj(4mzKKtgjV8bsu0LrEBH5bEHQ)usOxuJCmjJK8I8N4YNLTHXGSWC)cz8GcxWfMDsQcWTrqNj8Fi5GU0c1SqdwOblCyaYhrrTWzhtcYzva6TqnlKXdYmjjNUiQTW8wy(VqTxOIkUqgpiZKKC6IO2cZBHNAHAVqnl0GfAelS(oLI6GeCHzNKQXvLR3L8rqoRcqVfQOIlC46GgrgXatMqhpluHluPo1c1UBZ4bfE3wVOg5ysgj5f5V(0bLYg9(jDBYzva61bD3gxOHke3Tv)PK4r8KPgLtIV(c1SqdwOblCyaYhrrTWzhtcYzva6TqnlKXdYmjjNUiQTW8wy(VqTxOIkUqgpiZKKC6IO2cZBHNAHAVqnl0GfAelS(oLI6GeCHzNKQXvLR3L8rqoRcqVfQOIlC46GgrgXatMqhpluHluPo1c1UBZ4bfE3Mlm7KufGBtF6GszLE)KUnJhu4D72xNkpmZDBYzva61bDF6GYekPFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwOcbVqdwiJhKzssoDruBH5Jlu5fQ9c1SW67ukQdsWfMDsQgxvUExYhb5Ska9wOMfoCDqJiJyGjtOJNfM3cvQt1Tz8GcVBZfMDsQYvXhuF6GYek3pPBtoRcqVoO724cnuH4UT6pLeCHzNK4mUoirBymile8cv)PKGlm7KeNX1bjU8zzBymiDBgpOW72CHzNKQCv8b1NoOmHj6N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfcEHkPBZ4bfE3Mlm7Kmk1(0bLjuQ(jDBYzva61bD3gxOHke3TnyHfLkQLXQa0cvuXfAelCqyqq(Xc1EHAwO6pLeCHzNK4mUoirBymile8cv)PKGlm7KeNX1bjU8zzBymiDBgpOW72onzujh6QtTPpDqzI8VFs3MCwfGEDq3TXfAOcXDB1FkjWaexyUni)queJNfQzH13PuuhKGlm7Ke5jKJgTeKZQa0BHAwObl0Gfoma5JGV6aOecZdkCb5Ska9wOMfY4bzMKKtxe1wyEl0OVqTxOIkUqgpiZKKC6IO2cZBHNAHA3Tz8GcVBZfMDsErTgcGA9PdktCQ(jDBYzva61bD3gxOHke3Tv)PKadqCH52G8drrmEwOMfoma5JGlm7KKWzHGCwfGEluZcFK6pLet8XzYijNmsE5dK4RVqnl0Gfoma5JGV6aOecZdkCb5Ska9wOIkUqgpiZKKC6IO2cZBHk9fQD3MXdk8Unxy2j5f1AiaQ1NoOmXPTFs3MCwfGEDq3TXfAOcXDB1FkjWaexyUni)queJNfQzHddq(i4RoakHW8GcxqoRcqVfQzHmEqMjj50frTfM3cZ)UnJhu4DBUWStYlQ1qauRpDqzI8v)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wO6pLeCHzNK4mUoiXLplBdJbPBZ4bfE3Mlm7KKoRdenu49Pdkty07N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfcEHQ)usWfMDsIZ46Gex(SSnmgKfQzH6fzwEGFcLfCHzNKQCv8b1Tz8GcVBZfMDssN1bIgk8(0bLju69t62iFOQ(6JeL62x2zHoEuiyL(P62iFOQ(6JeDV0dXd1TvUBZ4bfE3MmhyEqH3TjNvbOxh09PpD7mUUHRv)KoOuUFs3MCwfGEDq3Tz8GcVBtMdmpOW72pQHlK(GcVBB00OfEAmhyEqHVquAHwKHfTqGWAHHVWl78cz)TqEHNeJjtb5w(TqlK)cRfIAlehxKFSWVE3gxOHke3TVSZcD8SW8aVqLp1c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnyH0zc)hsoOlTWCwiJhu4Ij(4mzKKtgjV8bsqNj8Fi5GU0c1EHAwiocGxy5cUWSts9WIkrrxg5TfMh4fAWcPZe(pKCqxAH5SqgpOWft8XzYijNmsE5dKGot4)qYbDPfMZcz8GcxWfMDsQhwujOZe(pKCqxAHAVqnlu9NsI67Kmss9WIkXlS8fQzHQ)usWfMDsQhwujEHLVqnl8rQ)usmXhNjJKCYi5LpqIxy5luZcnIf(Iru8dX(iB6CbIOOlJ8wF6GYe9t62KZQa0Rd6UnJhu4DBYCG5bfE3(rnCH0hu4DBJMgTWtJ5aZdk8fIsl0ImSOfcewlm8fEzNxi7VfYlmFh53cTq(lSwiQTqCCr(Xc)6DBCHgQqC3(Yol0XZcZd8cvkLSqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cnyH0zc)hsoOlTWCwiJhu4I67Kmss9WIkbDMW)HKd6slu7fQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMh4fAWcPZe(pKCqxAH5SqgpOWf13jzKK6Hfvc6mH)djh0LwyolKXdkCrXpe7JSPZfic6mH)djh0LwO2luZcXra8clxWfMDsQhwujk6YiVTqfUW8xj9PdkLQFs3MCwfGEDq3TXfAOcXDBCeaVWYff)qSpYMoxGik6YiVTW8aVqtSWC)cpWVfMZcnZfIvbiHjxPj1lQnmgeKFih0LwyolKot4)qYbDPfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMh4fAMleRcqctUstQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6sluZcXra8clxWfMDsQhwujk6YiVTW8aVqZCHyvasyYvAs9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAH5SqgpOWft8XzYijNmsE5dKGot4)qYbDPfQzHQ)usWfMDsIZ46GeTHXGSqfUqLxOMfQ(tjbxy2jjoJRds0ggdYcZBH5)c1SqJyH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4DBUWStsvaUn9PdQ8VFs3MCwfGEDq3TXfAOcXDBCeaVWYf13jzKK6HfvIIUmYBlmpWl0elm3VWd8BH5SqZCHyvasyYvAs9IAdJbb5hYbDPfMZcPZe(pKCqxAH5SqgpOWf13jzKK6Hfvc6mH)djh0LwOMfIJa4fwUO4hI9r205cerrxg5TfMh4fAMleRcqctUstQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnZfIvbiHjxPj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAH5SqgpOWff)qSpYMoxGiOZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfQzHQ)usWfMDsIZ46GeTHXGSqfUqLxOMfQ(tjbxy2jjoJRds0ggdYcZBH5)c1SqJyH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4DBUWStsvaUn9PdQt1pPBtoRcqVoO724cnuH4UnocGxy5IIFi2hztNlqefDzK3wyEGxOjwyUFHh43cZzHM5cXQaKWKR0K6f1ggdcYpKd6sluZcXra8clxWfMDsQhwujk6YiVTqfcEHkLswOMfIJa4fwUyIpotgj5KrYlFGefDzK3wyoluPuYcZd8cXra8clxWfMDsQhwujk6YiVTqnlehbWlSCr9DsgjPEyrLOOlJ82cZzHkLswyEGxiocGxy5cUWSts9WIkrrxg5TfQzHQ)usWfMDsIZ46GeTHXGSqfUqLxOMfQ(tjbxy2jjoJRds0ggdYcZBH5)c1SqJyH4WFF0i4cZoj1R4Ho0sqoRcqVUnJhu4DBUWStsvaUn9PdQtB)KUn5Ska96GUBJl0qfI724iaEHLlk(HyFKnDUaru0LrEBH5bEHh43cZzHM5cXQaKWKR0K6f1ggdcYpKd6slmNfsNj8Fi5GU0c1SqCeaVWYft8XzYijNmsE5dKOOlJ82cZd8cnZfIvbiHjxPj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQzH4iaEHLl4cZoj1dlQefDzK3wyEGxOzUqSkajm5knPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4IIFi2hztNlqe0zc)hsoOlTWCwiJhu4Ij(4mzKKtgjV8bsqNj8Fi5GU0c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYDBgpOW72CHzNKQCv8b1NoOYx9t62KZQa0Rd6UnUqdviUBJJa4fwUO(ojJKupSOsu0LrEBH5bEHh43cZzHM5cXQaKWKR0K6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlQVtYij1dlQe0zc)hsoOlTqnlehbWlSCrXpe7JSPZfiIIUmYBlmpWl0mxiwfGeMCLMuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMh4fAMleRcqctUstQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO(ojJKupSOsqNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluZcv)PKGlm7KeNX1bjAdJbzHkCHk3Tz8GcVBZfMDsQYvXhuF6GYO3pPBtoRcqVoO724cnuH4UnocGxy5IIFi2hztNlqefDzK3wyEGx4b(TWCwOzUqSkajm5knPErTHXGG8d5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBluHGxOsPKfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMZcvkLSW8aVqCeaVWYfCHzNK6HfvIIUmYBluZcXra8clxuFNKrsQhwujk6YiVTWCwOsPKfMh4fIJa4fwUGlm7KupSOsu0LrEBHAwO6pLeCHzNK4mUoirBymiluHlu5fQzHgXcXH)(OrWfMDsQxXdDOLGCwfGEDBgpOW72CHzNKQCv8b1NoOu69t62KZQa0Rd6U9JA4cPpOW72G(JaEluPX1nCTwyBymiTfMIAHtgTWtIXKPGCl)wOfYFHv3gxOHke3Tv)PKGlm7KmJRB4AjAdJbzH5Tq1Fkj4cZojZ46gUwIlFw2ggdYc1SqCeaVWYff)qSpYMoxGik6YiVTW8aVqZCHyvasyYvAs9IAdJbb5hYbDPfMZcPZe(pKCqxAHAwiocGxy5Ij(4mzKKtgjV8bsu0LrEBH5bEHM5cXQaKWKR0K6f1ggdcYpKd6slmNfsNj8Fi5GU0cZzHmEqHlk(HyFKnDUarqNj8Fi5GU0c1SqCeaVWYfCHzNK6HfvIIUmYBlmpWl0mxiwfGeMCLMuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCrXpe7JSPZfic6mH)djh0LwyolKXdkCXeFCMmsYjJKx(ajOZe(pKCqxQBJZyK3TvUBZ4bfE3Mlm7K8IAnea16thukRK(jDBYzva61bD3(rnCH0hu4DBq)raVfQ046gUwlSnmgK2ctrTWjJwy(oYVfAH8xy1TXfAOcXDB1Fkj4cZojZ46gUwI2WyqwyElu9NscUWStYmUUHRL4YNLTHXGSqnlehbWlSCr9DsgjPEyrLOOlJ82cZd8cnZfIvbiHjxPj1lQnmgeKFih0LwyolKot4)qYbDPfMZcz8GcxuFNKrsQhwujOZe(pKCqxAHAwiocGxy5IIFi2hztNlqefDzK3wyEGxOzUqSkajm5knPErTHXGG8d5GU0cZzH0zc)hsoOlTWCwiJhu4I67Kmss9WIkbDMW)HKd6sluZcXra8clxmXhNjJKCYi5LpqIIUmYBlmpWl0mxiwfGeMCLMuVO2Wyqq(HCqxAH5Sq6mH)djh0LwyolKXdkCr9DsgjPEyrLGot4)qYbDPfMZcz8Gcxu8dX(iB6CbIGot4)qYbDPfQzH4iaEHLl4cZoj1dlQefDzK3624mg5DBL72mEqH3T5cZojVOwdbqT(0bLYk3pPBtoRcqVoO72pQHlK(GcVBd6pc4TqLgx3W1AHTHXG0wykQfoz0cDge6TW8T9cTq(lS624cnuH4UT6pLeCHzNKzCDdxlrBymilmVfQ(tjbxy2jzgx3W1sC5ZY2WyqwOMfIJa4fwUO4hI9r205cerrxg5TfMh4fAMleRcqctUstQxuBymii)qoOlTWCwiDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6sluZcXra8clxWfMDsQhwujk6YiVTqfcEHkLswOMfIJa4fwUO(ojJKupSOsu0LrEBHke8cvkLSqnl0iwio83hncUWSts9kEOdTeKZQa0RBJZyK3TvUBZ4bfE3Mlm7K8IAnea16thukBI(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5TqtSqnlu9NscUWStYmUUHRLOnmgKfcEHQ)usWfMDsMX1nCTex(SSnmgKfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfM3cPZe(pKCqxAHAwiocGxy5cUWSts9WIkrrxg5TfMh4fAWcPZe(pKCqxAH5SqgpOWft8XzYijNmsE5dKGot4)qYbDPfQ9c1SWl7SqhpluHlu5t1Tz8GcVBx8dX(iB6CbsF6GszLQFs3MCwfGEDq3TXfAOcXDB1Fkj4cZojXzCDqI2WyqwyEl0eluZcv)PKGlm7KmJRB4AjAdJbzHGxO6pLeCHzNKzCDdxlXLplBdJbzHAwiocGxy5cUWSts9WIkrrxg5TfMh4fsNj8Fi5GU0c1SWxmIIFi2hztNlqefDzK362mEqH3TN4JZKrsozK8YhO(0bLY5F)KUn5Ska96GUBJl0qfI72Q)usWfMDsMX1nCTeTHXGSqWlu9NscUWStYmUUHRL4YNLTHXGSqnl8rQ)usmXhNjJKCYi5LpqIV(c1Sq1FkjQVtYij1dlQeVWY72mEqH3T5cZoj1dlQ6thukFQ(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5TqtSqnlu9NscUWStYmUUHRLOnmgKfcEHQ)usWfMDsMX1nCTex(SSnmgKfQzH4iaEHLlk(HyFKnDUaru0LrEBH5bEH0zc)hsoOlTqnlehbWlSCXeFCMmsYjJKx(ajk6YiVTW8aVqdwiDMW)HKd6slmNfY4bfUO4hI9r205cebDMW)HKd6slu7fQzH4iaEHLl4cZoj1dlQefDzK3wOcxy(FQfMZcnZfIvbiHjxPjFeaRfa6IgzULFluZcVSZcD8SqfcEHk1P62mEqH3TRVtYij1dlQ6thukFA7N0TjNvbOxh0DBCHgQqC3w9NscUWStsCgxhKOnmgKfM3cnXc1Sq1Fkj4cZojZ46gUwI2Wyqwi4fQ(tjbxy2jzgx3W1sC5ZY2WyqwOMfIJa4fwUyIpotgj5KrYlFGefDzK3wyElKot4)qYbDPfQzHQ)usuFNKrsQhwuj(6DBgpOW72f)qSpYMoxG0NoOuoF1pPBtoRcqVoO724cnuH4UT6pLeCHzNKzCDdxlrBymile8cv)PKGlm7KmJRB4AjU8zzBymiluZcv)PKO(ojJKupSOs81xOMf(Iru8dX(iB6CbIOOlJ8w3MXdk8U9eFCMmsYjJKx(a1NoOu2O3pPBtoRcqVoO724cnuH4UTblehbWlSCXeFCMmsYjJKx(ajk6YiVTWCwy(FQfQ9cZd8cXra8clxWfMDsQhwujk6YiVTqnlu9NscUWSts9WIkXlS8fQzHgXcXH)(OrWfMDsQxXdDOLGCwfGEDBgpOW7213jzKK6Hfv9PdkLv69t62KZQa0Rd6UnUqdviUBR(tjbxy2jzgx3W1s0ggdYcbVq1Fkj4cZojZ46gUwIlFw2ggdYc1SqCeaVWYfCHzNK6HfvIIUmYBluHGxOsPKfQzH4iaEHLlM4JZKrsozK8Yhirrxg5TfMZcvkLSW8aVqCeaVWYfCHzNK6HfvIIUmYBluZcXra8clxuFNKrsQhwujk6YiVTWCwOsPKfMh4fIJa4fwUGlm7KupSOsu0LrEBHAw4LDwOJNfQqWlu5tTqnl0iwio83hncUWSts9kEOdTeKZQa0RBZ4bfE3U4hI9r205cK(0bLjus)KUn5Ska96GUBJl0qfI72Vyef)qSpYMoxGik6YiVTqfUWtTqnl8rQ)usu8dX(iB6CbI08hWPIvraOrlrBymile8cvYc1Sq1FkjQVtYij1dlQeVWY72mEqH3T5cZojJsTpDqzcL7N0TjNvbOxh0DBCHgQqC3(rQ)usu8dX(iB6CbI08hWPIvraOrlrBymile8cZ)UnJhu4DBUWStsvUk(G6thuMWe9t62KZQa0Rd6UnUqdviUB)Iru8dX(iB6CbIOOlJ82c1SWhP(tjXeFCMmsYjJKx(ajk6YiVTqfUq6mH)djh0LwOMfAWcFK6pLef)qSpYMoxGin)bCQyveaA0s0ggdYcbVqLSqfvCHps9NsIIFi2hztNlqKM)aovSkcanAjAdJbzH5TW8FHAVqnl0iwOErMLh4Nqzbxy2jPkxfFqDBgpOW72CHzNKQaCB6thuMqP6N0TjNvbOxh0DBCHgQqC3(fJO4hI9r205cerrxg5TfQWfsNj8Fi5GU0c1SWhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGSqfUqLSqnl8rQ)usu8dX(iB6CbI08hWPIvraOrlrBymilmVfM)luZcv)PKO(ojJKupSOs8clVBZ4bfE3Mlm7KufGBtF6GYe5F)KUn5Ska96GUBJl0qfI72Q)usWfMDsIZ46GeTHXGSW8wOjwOMfQ(tjbxy2jPEyrL4R3Tz8GcVBZfMDsgLAF6GYeNQFs3MCwfGEDq3Tz8GcVBZfMDsErTgcGADBCgJ8UTYDBCHgQqC3w9NscmaXfMBdYpefX4zHAwO6pLeCHzNK6HfvIVEF6GYeN2(jDBYzva61bD3MXdk8UTErnYXKmsYlYFD7h1WfsFqH3TnAA0cZVWKTW3Vq(XcZT8BHrTW8DKFl0c5VWQTWjwO6hb8wioJRdQTqonuTWFd5hlm3km70cbnxfFqDBCHgQqC3w9NscUWStsCgxhKOnmgKfM3cv)PKGlm7KeNX1bjU8zzBymiluZcv)PKGlm7KeNX1bjAdJbzHkCHkzHAwO6pLeCHzNK6HfvIIUmYBlurfxO6pLeCHzNK4mUoirBymilmVfQ(tjbxy2jjoJRdsC5ZY2WyqwOMfQ(tjbxy2jjoJRds0ggdYcv4cvYc1Sq1FkjQVtYij1dlQefDzK3wOMf(i1FkjM4JZKrsozK8Yhirrxg5T(0bLjYx9t62KZQa0Rd6UnUqdviUBR(tjHErnYXKmsYlYFIV(c1Sq1Fkj4cZojXzCDqI2WyqwOcxOYDBgpOW72CHzNKQaCB6thuMWO3pPBtoRcqVoO724cnuH4UT6pLeCHzNK4mUoirBymilmVfAIfQzH4iaEHLl4cZoj1dlQefDzK3wOcbVqtOKfMpUqJ(cZ9l8a)wOMfAel0GfIJa4fwUO4hI9r205cerrxg5TfMh4fQSswOMfIJa4fwUGlm7KupSOsu0LrEBHke8cZxNAHA3Tz8GcVBZfMDsgLAF6GYek9(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzH5TqtSqnlehbWlSCbxy2jPEyrLOOlJ82cvi4fAcLSW8XfA0xyUFHh43c1SqC4VpAeCHzNK6v8qhAjiNvbOx3MXdk8Unxy2jzuQ9PdkLsj9t62KZQa0Rd6UnJhu4DBUWStYlQ1qauRBJZyK3TvUBJl0qfI72Q)usWfMDsIZ46GeTHXGSqfUqLxOMfQ(tjbxy2jzgx3W1s0ggdYcZBHQ)usWfMDsMX1nCTex(SSnmgK(0bLsPC)KUn5Ska96GUBZ4bfE3Mlm7K8IAnea1624mg5DBL724cnuH4UnocGxy5cUWStYOuffDzK3wyElm)xOMfQ(tjbxy2jzgx3W1s0ggdYcZBHQ)usWfMDsMX1nCTex(SSnmgK(0bLszI(jDBYzva61bD3gxOHke3Tv)PKGlm7KeNX1bjAdJbzHGxO6pLeCHzNK4mUoiXLplBdJbzHAwO6pLeCHzNKzCDdxlrBymile8cv)PKGlm7KmJRB4AjU8zzBymiDBgpOW72CHzNKQCv8b1NoOukLQFs3MCwfGEDq3TXfAOcXD7l7SqhplmVfQ8P62mEqH3TjZbMhu49PdkLk)7N0TjNvbOxh0DBgpOW72CHzNKQaCB62pQHlK(GcVBNpKr(cvPXIiFH4iaEHLVqlK)cRMPl0Iwy4aATq1pc4TWjwy6daSqCgxhuBHCAOAH)gYpwyUvy2PfA0wQDBCHgQqC3w9NscUWStsCgxhKOnmgKfQWfQCF6GsPov)KUn5Ska96GUBJZyK3TvUBZ4bfE3Mlm7K8IAnea16tF62jKZas1F59t6Gs5(jDBYzva61bD3MXdk8Unxy2j5f1AiaQ1TXzmY72k3TXfAOcXDB1FkjWaexyUni)queJN(0bLj6N0Tz8GcVBZfMDsQcWTPBtoRcqVoO7thukv)KUnJhu4DBUWStsvUk(G62KZQa0Rd6(0N(0TntvdfEhuMqjMqzLK)krP62wC5i)O1TZhYT8nOo9G60LjTWfEsgTq0vpQzHPOwOHzCDdxldxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtluPmPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtlm)nPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtl8uM0cnQWnt1qVfAio83hnICz4cNyHgId)9rJixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfA0nPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtluzLnPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtluzJUjTqJkCZun0BHgId)9rJixgUWjwOH4WFF0iYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHkR0nPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfYZcpngTg5cnq5ZAlwJnsKtl0ekDtAHgv4MPAO3cneh(7JgrUmCHtSqdXH)(OrKlb5Ska9mCH8SWtJrRrUqdu(S2I14148HClFdQtpOoDzslCHNKrleD1JAwykQfAyc1Yq(Hm0jNkdxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtluztAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObM4S2I1yJe50cnHjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdu(S2I1yJe50cvktAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAH5VjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTWtzsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl8uM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHkRetAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObM4S2I1yJe50cv(0Asl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqLv6M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cvwPBsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfAcLysl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtl0eMWKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXA8AC(qULVb1PhuNUmPfUWtYOfIU6rnlmf1cnm0jNkdxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtluztAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMWKwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfAGYN1wSgBKiNwOYkXKwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkRuM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHkN)M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHkFktAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXRX5d5w(guNEqD6YKw4cpjJwi6Qh1SWuul0WkgEqHB4clkF(rf9wylU0c5)exEO3cXzSFqnXASrICAHkBsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqtysl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtlm)nPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNw4PmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOs3KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkR0nPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOjuIjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqtOSjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqtOuM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnr(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJxJZhYT8nOo9G60LjTWfEsgTq0vpQzHPOwOHpkXFGXWfwu(8Jk6TWwCPfY)jU8qVfIZy)GAI1yJe50cnHjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0atCwBXASrICAHkLjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0atCwBXASrICAH5VjTqJkCZun0BH2ORrTWMw(WNx4P7lCIfAKFEHpKzudf(cdDQ4jQfAGc0EHgO8zTfRXgjYPfEktAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtlmFzsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4cnq5ZAlwJnsKtlu58LjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqLv6M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnHYM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnHszsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHlKNfEAmAnYfAGYN1wSgBKiNwOjuktAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXA8AC(qULVb1PhuNUmPfUWtYOfIU6rnlmf1cnuViCCv5XWfwu(8Jk6TWwCPfY)jU8qVfIZy)GAI1yJe50cpTM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnHsmPfAuHBMQHEl0qC4VpAe5YWfoXcneh(7JgrUeKZQa0ZWfAGYN1wSgBKiNwOju2KwOrfUzQg6TqdXH)(OrKldx4el0qC4VpAe5sqoRcqpdxObkFwBXASrICAHMWeM0cnQWnt1qVfAio83hnICz4cNyHgId)9rJixcYzva6z4cnq5ZAlwJnsKtl0ekDtAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtl0ekDtAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHkv(Bsl0Oc3mvd9wOH13PuuhKixgUWjwOH13PuuhKixcYzva6z4c5zHNgJwJCHgO8zTfRXgjYPfQuNYKwOrfUzQg6TqdRVtPOoirUmCHtSqdRVtPOoirUeKZQa0ZWfYZcpngTg5cnq5ZAlwJxJZhYT8nOo9G60LjTWfEsgTq0vpQzHPOwOH4iaEHL3mCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqLnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfActAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtl0eM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cvktAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtluPmPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfM)M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cpTM0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnWeN1wSgBKiNwOr3KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObM4S2I1yJe50cv6M0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnWeN1wSgBKiNwOYkBsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0atCwBXASrICAHkRuM0cnQWnt1qVfA4WaKpICz4cNyHgoma5JixcYzva6z4cnq5ZAlwJnsKtlu583KwOrfUzQg6TqdhgG8rKldx4el0WHbiFe5sqoRcqpdxObkFwBXASrICAHkB0nPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgVgNpKB5BqD6b1PltAHl8KmAHOREuZctrTqd5GmCHfLp)OIElSfxAH8FIlp0BH4m2pOMyn2iroTqLnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqLnPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfActAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObM4S2I1yJe50cvktAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtluPmPfAuHBMQHEl0W67ukQdsKldx4el0W67ukQdsKlb5Ska9mCHgO8zTfRXgjYPfM)M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cpLjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTWtRjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTW8LjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqJUjTqJkCZun0BHgwFNsrDqICz4cNyHgwFNsrDqICjiNvbONHl0aLpRTyn2iroTqLUjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqdmXzTfRXgjYPfQSsmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqLvktAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgyIZAlwJnsKtlu5tRjTqJkCZun0BHgoma5JixgUWjwOHddq(iYLGCwfGEgUqEw4PXO1ixObkFwBXASrICAHkNVmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOY5ltAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHkB0nPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgBKiNwOYgDtAHgv4MPAO3cnS(oLI6Ge5YWfoXcnS(oLI6Ge5sqoRcqpdxObkFwBXASrICAHMqjM0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnr(Bsl0Oc3mvd9wOHddq(iYLHlCIfA4WaKpICjiNvbONHl0aLpRTyn2iroTqtK)M0cnQWnt1qVfAy9Dkf1bjYLHlCIfAy9Dkf1bjYLGCwfGEgUqdu(S2I1yJe50cnXPmPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGjoRTyn2iroTqtCAnPfAuHBMQHEl0WHbiFe5YWfoXcnCyaYhrUeKZQa0ZWfAGYN1wSgVgNpKB5BqD6b1PltAHl8KmAHOREuZctrTqd5RSPZxdxyr5ZpQO3cBXLwi)N4Yd9wioJ9dQjwJnsKtluztAHgv4MPAO3cnCyaYhrUmCHtSqdhgG8rKlb5Ska9mCHgO8zTfRXRXN(REud9wOYkVqgpOWxiaQnnXAC3wVIecG625UC3cnz8bTWCRWStRX5UC3cZn9cbSqLnHPl0ekXekVgVgN7YDlmFt3WmTqZCHyvasWxztNVle5lmXMJAHrAHnAgKF0e8v2057cnaNryqwOwXVwytNWlm0hu4nTfRX5UC3cnAA0chT0rygyH2ORrTWm2Fai)yHrAH4m2DcyHiFOQ(6dk8fI82q8BHrAHgIzhtasgpOWnuSgVgZ4bfEtOxeoUQ8KdyfWfMDsI8Haai8SgZ4bfEtOxeoUQ8KdyfWfMDsM4lcaX1AmJhu4nHEr44QYtoGvao8t3(fjVSZYd6UgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaZxztNVMg6GlQrJPpkXFGbCJMb5hnbFLnD(UgZ4bfEtOxeoUQ8KdyfyMleRcqM68LatMdPoEmn0bxuJgtFuI)adyLp1AmJhu4nHEr44QYtoGvGzUqSkazQZxcSEr6Faajzomn0b3OXuucSb13PuuhKOH0Zcx2MOUAy8GmtsYPlIAku5Cmq5CVbgbomto7JWjCfar90wBTn1md8jWkBQzg4tscOrGvYAmJhu4nHEr44QYtoGvGzUqSkazQZxcCgBMKHo50Z0qhCJgtrjWgW4bzMKKtxe1uOjuurZCHyvasOxK(haqsMdWkROIM5cXQaKGVYMoFbRS2MAMb(eyLn1md8jjb0iWkznMXdk8MqViCCv5jhWkWmxiwfGm15lboHCgqQ(l30qhCJgtnZaFcSswJz8GcVj0lchxvEYbScmZfIvbitD(sGn5kn5JayTaqx0iZT8Z0qhCrnAm9rj(dmGv(uRXmEqH3e6fHJRkp5awbM5cXQaKPoFjWMCLMuVO2Wyqq(HCqxY0qhCrnAm9rj(dmGv6RXmEqH3e6fHJRkp5awbM5cXQaKPoFjWMCLM0OnFd6uu5BB5JayTmn0bxuJgtFuI)adyLvYAmJhu4nHEr44QYtoGvGzUqSkazQZxcC1Kx(S8raSwYuuYjMRPHo4IA0y6Js8hyaFQ1ygpOWBc9IWXvLNCaRaZCHyvaYuNVe4QjV8z5JayTKPOKvOBAOdUOgnM(Oe)bgWNAnMXdk8MqViCCv5jhWkWmxiwfGm15lbUAYlFw(iawlzkkjRBAOdUOgnM(Oe)bgWMqjRXmEqH3e6fHJRkp5awbM5cXQaKPoFjW3yK6fHj6jNyUsvTmn0bxuJgtFuI)adyLAnMXdk8MqViCCv5jhWkWmxiwfGm15lb(gJ8YNLpcG1sMIsoXCnn0bxuJgtFuI)adyLvYAmJhu4nHEr44QYtoGvGzUqSkazQZxc8ng5LplFeaRLmfLK1nn0bxuJgtFuI)adyLp1AmJhu4nHEr44QYtoGvGzUqSkazQZxcmRlV8z5JayTKPOKtmxtdDWf1OX0hL4pWawzLSgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaZ6YlFw(iawlzkk5ngtdDWf1OX0hL4pWa2ekznMXdk8MqViCCv5jhWkWmxiwfGm15lbUcD5LplFeaRLmfLCI5AAOdUrJPMzGpb2ekjF0GtL7XH)(OrWfMDsQxXdDOL2RXmEqH3e6fHJRkp5awbM5cXQaKPoFjWtmx5LplFeaRLmfLK1nn0b3OXuucSb4Wm5SpchDKnYetkQOb4WFF0i4cZoj1R4Ho0sdJhKzssoDrulpLsBTn1md8jWkFktnZaFssanc8PwJz8GcVj0lchxvEYbScmZfIvbitD(sGNyUYlFw(iawlzkkzf6Mg6GB0yQzg4tGnHsYhnWON7XH)(OrWfMDsQxXdDOL2RXmEqH3e6fHJRkp5awbM5cXQaKPoFjWQCv8bjVSZsD8yAOdUrJPOeyCyMC2hHJoYgzIjtnZaFc8Pvj5JgC52qLwsZmWNY9kReLO9AmJhu4nHEr44QYtoGvGzUqSkazQZxcSkxfFqYl7SuhpMg6GB0ykkbghMjN9raIwfIDtnZaFcSs)u5JgC52qLwsZmWNY9kReLO9AmJhu4nHEr44QYtoGvGzUqSkazQZxcSkxfFqYl7SuhpMg6GB0ykkb2mxiwfGeQCv8bjVSZsD8awjMAMb(eyJUsYhn4YTHkTKMzGpL7vwjkr71ygpOWBc9IWXvLNCaRaZCHyvaYuNVeywxEro6(VYl7SuhpMg6GlQrJPpkXFGbSYNAnMXdk8MqViCCv5jhWkWmxiwfGm15lbEI5kV8zjoJRdQzAOdUOgnM(Oe)bgWMynMXdk8MqViCCv5jhWkWmxiwfGm15lbMdsoXCLx(SeNX1b1mn0bxuJgtFuI)adytSgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaNqTmKFidDYPY0qhCJgtnZaFcSY5EdO85hPRtpbD11Qigqg1ZzhtkQObddq(iQVtYij1dlQ0yWWaKpcUWStscNfkQOrGdZKZ(iarRcXU2AmWiWHzYzFeoHRaiQNIkY4bzMKKtxe1aRSIkwFNsrDqIgsplCzBI6QT2AVgZ4bfEtOxeoUQ8KdyfyMleRcqM68LaZ6YWL)gzAOdUrJPMzGpbMYNFKUo9exgZQfjBzenY7VHWkQiLp)iDD6joa4hINOAsv(DqkQiLp)iDD6joa4hINOAYl9yaau4kQiLp)iDD6jECbYncx(imis9)uudtoMuurkF(r660tG8gU(dRcqY85N95FLpYmctkQiLp)iDD6jAXhaGMb5hY6RQLIks5ZpsxNEI23vbI4j5lnzA1gfvKYNFKUo9ewmiKtvtMQWFkQiLp)iDD6jsa8LKrsQYZaqRXmEqH3e6fHJRkp5awbM5cXQaKPoFjWCqYjMR8YNL4mUoOMPHo4IA0y6Js8hyaBI1ygpOWBc9IWXvLNCaRaZCHyvaYuNVeyYCi1XJPHo4IA0y6Js8hyaR8PwJz8GcVj0lchxvEYbScUOQIsIU8bTgZ4bfEtOxeoUQ8KdyfKQOnQbWykkb2imZfIvbiHEr6FaajzoaRSM67ukQds8qnmsha5CPLeh3l7V1ygpOWBc9IWXvLNCaRaUWStsvaUnMIsGncZCHyvasOxK(haqsMdWkRXiQVtPOoiXd1WiDaKZLwsCCVS)wJz8GcVj0lchxvEYbSciZbMhu4MIsGnZfIvbiHEr6FaajzoaR8A8AmJhu4TCaRaC89HQMobaSgZ4bfElhWkWmxiwfGm15lboJntYqNC6zAOdUrJPMzGpbwztrjWM5cXQaKiJntYqNC6bwjA0lYS8a)ekliZbMhu4AmcdQVtPOoirdPNfUSnrDvuX67ukQdsm0vpkgqAXLU2RXmEqH3YbScmZfIvbitD(sGZyZKm0jNEMg6GB0yQzg4tGv2uucSzUqSkajYyZKm0jNEGvIg1Fkj4cZoj1dlQeVWY1GJa4fwUGlm7KupSOsu0LrEtJb13PuuhKOH0Zcx2MOUkQy9Dkf1bjg6QhfdiT4sx71ygpOWB5awbM5cXQaKPoFjWjKZas1F5Mg6GB0yQzg4tGv2uucS6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAmc1FkjQpajJKCYkIAIVUg1O10KqhzJSOlJ8wEGnWGl78P7mEqHl4cZojvb42iWrB0o3Z4bfUGlm7KufGBJGot4)qYbDjTxJz8GcVLdyf8BK8YolpORPOeydggG8rqoa6iBiNEAUSZcD8KhyJUs0CzNf64rHGpTNsBfv0aJyyaYhb5aOJSHC6P5Yol0XtEGn6Ns71ygpOWB5awb6XGc3uucS6pLeCHzNK6HfvIV(AmJhu4TCaRGbDjPfx6MIsGRVtPOoiXqx9OyaPfx6Au)PKGoNX)2Gcx811yaocGxy5cUWSts9WIkrr8tlfvunAnnj0r2il6YiVLh48xjAVgZ4bfElhWkaaDKnn5PB)3XL8XuucS6pLeCHzNK6HfvIxy5Au)PKO(ojJKupSOs8clxZJu)PKyIpotgj5KrYlFGeVWYxJz8GcVLdyfOYhYijNcHbPzkkbw9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3YbScuPQrfii)WuucS6pLeCHzNK6HfvIV(AmJhu4TCaRavGiEY0V0YuucS6pLeCHzNK6HfvIV(AmJhu4TCaRGeQivGiEMIsGv)PKGlm7KupSOs81xJz8GcVLdyfWoMAtXasmdaykkbw9NscUWSts9WIkXxFnMXdk8woGvWVrs0q3MPOey1Fkj4cZoj1dlQeF91ygpOWB5awb)gjrdDnLsjcpsNVe4da(H4jQMuLFhKPOey1Fkj4cZoj1dlQeFDfvehbWlSCbxy2jPEyrLOOlJ8McbFQtP5rQ)usmXhNjJKCYi5LpqIV(AmJhu4TCaRGFJKOHUM68LatxDTkIbKr9C2XKPOeyCeaVWYfCHzNK6HfvIIUmYB5b2aLvQCYx5EZCHyvasW6YWL)gP9AmJhu4TCaRGFJKOHUM68La)kIFjursZuRraMIsGXra8clxWfMDsQhwujk6YiVPqWMqjkQOryMleRcqcwxgU83iWkROIgmOlbwjAmZfIvbirc1Yq(Hm0jNkWkRP(oLI6GenKEw4Y2e1v71ygpOWB5awb)gjrdDn15lbUfFaj6WrdvMIsGXra8clxWfMDsQhwujk6YiVPqWkLsuurJWmxiwfGeSUmC5VrGvEnMXdk8woGvWVrs0qxtD(sGpa0sptgjj3AOlcGhu4MIsGXra8clxWfMDsQhwujk6YiVPqWMqjkQOryMleRcqcwxgU83iWkROIgmOlbwjAmZfIvbirc1Yq(Hm0jNkWkRP(oLI6GenKEw4Y2e1v71ygpOWB5awb)gjrdDn15lb(YywTizlJOrE)ne2uucmocGxy5cUWSts9WIkrrxg5T8aFkngyeM5cXQaKiHAzi)qg6KtfyLvuXbDjfQukr71ygpOWB5awb)gjrdDn15lb(YywTizlJOrE)ne2uucmocGxy5cUWSts9WIkrrxg5T8aFknM5cXQaKiHAzi)qg6KtfyL1O(tjr9DsgjPEyrL4RRr9NsI67Kmss9WIkrrxg5T8aBGYkjF8u5(67ukQds0q6zHlBtuxT1mOlLNsPK1ygpOWB5awbygaqY4bfUea1gtD(sG5GmTnfcpGv2uucmJhKzssoDrutHMynMXdk8woGvaMbaKmEqHlbqTXuNVe4mUUHRLPTPq4bSYMIsGXHzYzFeGOvHyxt9Dkf1bj4cZojrEc5Orlnddq(iQVtYij1dlQwJZDl8KmAHjuld5hlm0jNQfQshiVTql0KTW8DKFlK93ctOwg1wykQfAug1c1Ra3w4el83Of((fYpw4jXyYuqULFRXmEqH3YbScWmaGKXdkCjaQnM68LaNqTmKFidDYPY02ui8awztrjWM5cXQaKiJntYqNC6bwjAmZfIvbirc1Yq(Hm0jNQ1ygpOWB5awbygaqY4bfUea1gtD(sGdDYPY02ui8awztrjWM5cXQaKiJntYqNC6bwjRXmEqH3YbScWmaGKXdkCjaQnM68LaZxztNVM2McHhWkBkkbUrZG8JMGVYMoFbR8AmJhu4TCaRamdaiz8GcxcGAJPoFjW4iaEHL3wJz8GcVLdyfGzaajJhu4sauBm15lbUIHhu4M2McHhWkBkkb2mxiwfGejKZas1F5GvYAmJhu4TCaRamdaiz8GcxcGAJPoFjWjKZas1F5M2McHhWkBkkb2mxiwfGejKZas1F5GvEnMXdk8woGvaMbaKmEqHlbqTXuNVe4ByMUKpRXRX5UfY4bfEtWxztNVGXSJjajJhu4MIsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk9tTgZ4bfEtWxztNV5awbK5aZdkCtrjWx2zHoEYdSzUqSkajiZHuhpAmahbWlSCXeFCMmsYjJKx(ajk6YiVLhygpOWfK5aZdkCbDMW)HKd6skQiocGxy5cUWSts9WIkrrxg5T8aZ4bfUGmhyEqHlOZe(pKCqxsrfnyyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5bMXdkCbzoW8GcxqNj8Fi5GUK2ARr9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3e8v205BoGvWJ4jtnkNmfLaJJa4fwUGlm7KupSOsu0LrEdSs0yG6pLe13jzKK6HfvIxy5AmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvrfXra8clxmXhNjJKCYi5LpqIIUmYBGvI2AVgZ4bfEtWxztNV5awbxuvr1KrsorDjFmfLaJJa4fwUGlm7KupSOsu0LrEdSs0yG6pLe13jzKK6HfvIxy5AmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvrfXra8clxmXhNjJKCYi5LpqIIUmYBGvI2AVgZ4bfEtWxztNV5awbf)qSpYMoxGSgZ4bfEtWxztNV5awbTmuAq(HupSOYuucS6pLeCHzNK6HfvIxy5AWra8clxWfMDsQhwujM6tYIUmYBkKXdkCrldLgKFi1dlQe4xPr9NsI67Kmss9WIkXlSCn4iaEHLlQVtYij1dlQet9jzrxg5nfY4bfUOLHsdYpK6Hfvc8R08i1FkjM4JZKrsozK8YhiXlS81ygpOWBc(kB68nhWkO(ojJKupSOYuucS6pLe13jzKK6HfvIxy5AWra8clxWfMDsQhwujk6YiVTgZ4bfEtWxztNV5awbt8XzYijNmsE5dKPOeydWra8clxWfMDsQhwujk6YiVbwjAu)PKO(ojJKupSOs8clxBfvuViZYd8tOSO(ojJKupSOAnMXdk8MGVYMoFZbScM4JZKrsozK8YhitrjW4iaEHLl4cZoj1dlQefDzK3Y7ukrJ6pLe13jzKK6HfvIxy5AOwJCmjmJAOWLrsQtvIWdkCb5Ska9wJz8GcVj4RSPZ3CaRaUWSts9WIktrjWQ)usuFNKrsQhwujEHLRbhbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZDnMXdk8MGVYMoFZbSc4cZojv5Q4dYuucS6pLeCHzNK6HfvIVUg1Fkj4cZoj1dlQefDzK3YdmJhu4cUWStYlQ1qautqNj8Fi5GUKg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2WyqwJz8GcVj4RSPZ3CaRaUWStYOunfLaR(tjbxy2jjoJRds0ggdsEQ)usWfMDsIZ46Gex(SSnmgenQ)usuFNKrsQhwujEHLRr9NscUWSts9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clFnMXdk8MGVYMoFZbSc4cZojv5Q4dYuucS6pLe13jzKK6HfvIxy5Au)PKGlm7KupSOs8clxZJu)PKyIpotgj5KrYlFGeVWY1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdYAmJhu4nbFLnD(MdyfWfMDsErTgcGAMIsGv)PKadqCH52G8drrmEmfNXihSYMsCbOLeNXixIsGv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUIkQ(tjr9DsgjPEyrL4RROI4iaEHLliZbMhu4II4NwAVgZ4bfEtWxztNV5awbCHzNKxuRHaOMPOeyJGpDOcnKGlm7Ku)FVeaYpeKZQa0trfv)PKadqCH52G8djoJDNaeVWYnfNXihSYMsCbOLeNXixIsGv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUIkQ(tjr9DsgjPEyrL4RROI4iaEHLliZbMhu4II4NwAVgZ4bfEtWxztNV5awbK5aZdkCtrjWQ)usuFNKrsQhwujEHLRr9NscUWSts9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clFnMXdk8MGVYMoFZbSc4cZojJs1uucS6pLeCHzNK4mUoirBymi5P(tjbxy2jjoJRdsC5ZY2WyqwJz8GcVj4RSPZ3CaRaUWStsvUk(GwJz8GcVj4RSPZ3CaRaUWStsvaUnRXRXmEqH3eCqGtv0g1aymfLaxFNsrDqIhQHr6aiNlTK44Ez)PbhbWlSCH6pLKpudJ0bqoxAjXX9Y(tue)0sJ6pLepudJ0bqoxAjXX9Y(tMQOnIxy5Amq9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5ARbhbWlSCXeFCMmsYjJKx(ajk6YiVbwjAmq9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutJbgmma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8aFGFAWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswxBfv0aJyyaYhr9DsgjPEyrLgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wrfXra8clxWfMDsQhwujk6YiVLh4d8tBTxJz8GcVj4GYbScsOIKQaCBmfLaBq9Dkf1bjEOggPdGCU0sIJ7L9NgCeaVWYfQ)us(qnmsha5CPLeh3l7prr8tlnQ)us8qnmsha5CPLeh3l7pzcvK4fwUg9ImlpWpHYIufTrnagTvurdQVtPOoiXd1WiDaKZLwsCCVS)0mOlLNYAVgZ4bfEtWbLdyfKQOnspmZMIsGRVtPOoiXrHAaAjryegG0GJa4fwUGlm7KupSOsu0LrEtHkLs0GJa4fwUyIpotgj5KrYlFGefDzK3aRengO(tjbxy2jjoJRds0ggdsEGnZfIvbibhKCI5kV8zjoJRdQPXadggG8ruFNKrsQhwuPbhbWlSCr9DsgjPEyrLOOlJ8wEGpWpn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTIkAGrmma5JO(ojJKupSOsdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6AROI4iaEHLl4cZoj1dlQefDzK3Yd8b(PT2RXmEqH3eCq5awbPkAJ0dZSPOe467ukQdsCuOgGwsegHbin4iaEHLl4cZoj1dlQefDzK3aRengyGb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrBfv0aCeaVWYft8XzYijNmsE5dKOOlJ8gyLOr9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutBT1O(tjr9DsgjPEyrL4fwU2RXmEqH3eCq5awbt8XzYijNmsE5dKPOe467ukQds0q6zHlBtuxn6fzwEGFcLfK5aZdk81ygpOWBcoOCaRaUWSts9WIktrjW13PuuhKOH0Zcx2MOUAmqViZYd8tOSGmhyEqHROI6fzwEGFcLft8XzYijNmsE5dK2RXmEqH3eCq5awbK5aZdkCtrjWd6skuPuIM67ukQds0q6zHlBtuxnQ)usWfMDsIZ46GeTHXGKhyZCHyvasWbjNyUYlFwIZ46GAAWra8clxmXhNjJKCYi5LpqIIUmYBGvIgCeaVWYfCHzNK6HfvIIUmYB5b(a)wJz8GcVj4GYbSciZbMhu4MIsGh0LuOsPen13PuuhKOH0Zcx2MOUAWra8clxWfMDsQhwujk6YiVbwjAmWadWra8clxmXhNjJKCYi5LpqIIUmYBk0mxiwfGeSU8YNLpcG1sMIsoXC1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdI2kQOb4iaEHLlM4JZKrsozK8Yhirrxg5nWkrJ6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOM2ARr9NsI67Kmss9WIkXlSCTnf5dv1xFKOey1FkjAi9SWLTjQROnmgeWQ)us0q6zHlBtuxXLplBdJbXuKpuvF9rIUx6H4HaR8AmJhu4nbhuoGvWfvvunzKKtuxYhtrjWgGJa4fwUGlm7KupSOsu0LrEtH5)PuurCeaVWYfCHzNK6HfvIIUmYB5bwP0wdocGxy5Ij(4mzKKtgjV8bsu0LrEdSs0yG6pLeCHzNK4mUoirBymi5b2mxiwfGeCqYjMR8YNL4mUoOMgdmyyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5b(a)0GJa4fwUGlm7KupSOsu0LrEtHNsBfv0aJyyaYhr9DsgjPEyrLgCeaVWYfCHzNK6HfvIIUmYBk8uAROI4iaEHLl4cZoj1dlQefDzK3Yd8b(PT2RXmEqH3eCq5awbf)qSpYMoxGykkbghbWlSCXeFCMmsYjJKx(ajk6YiVLhDMW)HKd6sAmq9NscUWStsCgxhKOnmgK8aBMleRcqcoi5eZvE5ZsCgxhutJbgmma5JO(ojJKupSOsdocGxy5I67Kmss9WIkrrxg5T8aFGFAWra8clxWfMDsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuswxBfv0aJyyaYhr9DsgjPEyrLgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wrfXra8clxWfMDsQhwujk6YiVLh4d8tBTxJz8GcVj4GYbSck(HyFKnDUaXuucmocGxy5cUWSts9WIkrrxg5T8OZe(pKCqxsJbgyaocGxy5Ij(4mzKKtgjV8bsu0LrEtHM5cXQaKG1Lx(S8raSwYuuYjMRg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0wrfnahbWlSCXeFCMmsYjJKx(ajk6YiVbwjAu)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10wBnQ)usuFNKrsQhwujEHLR9AmJhu4nbhuoGvWJ4jtnkNmfLaJJa4fwUGlm7KupSOsu0LrEdSs0yGbgGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5Qr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgeTvurdWra8clxmXhNjJKCYi5LpqIIUmYBGvIg1Fkj4cZojXzCDqI2WyqYdSzUqSkaj4GKtmx5LplXzCDqnT1wJ6pLe13jzKK6HfvIxy5AVgZ4bfEtWbLdyfmXhNjJKCYi5LpqMIsGv)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10yGbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWh4NgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wrfnWiggG8ruFNKrsQhwuPbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDTvurCeaVWYfCHzNK6HfvIIUmYB5b(a)0EnMXdk8MGdkhWkGlm7KupSOYuucSbgGJa4fwUyIpotgj5KrYlFGefDzK3uOzUqSkajyD5LplFeaRLmfLCI5Qr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgeTvurdWra8clxmXhNjJKCYi5LpqIIUmYBGvIg1Fkj4cZojXzCDqI2WyqYdSzUqSkaj4GKtmx5LplXzCDqnT1wJ6pLe13jzKK6HfvIxy5RXmEqH3eCq5awb13jzKK6HfvMIsGv)PKO(ojJKupSOs8clxJbgGJa4fwUyIpotgj5KrYlFGefDzK3uOjuIg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0wrfnahbWlSCXeFCMmsYjJKx(ajk6YiVbwjAu)PKGlm7KeNX1bjAdJbjpWM5cXQaKGdsoXCLx(SeNX1b10wBngGJa4fwUGlm7KupSOsu0LrEtHkBcfv8rQ)usmXhNjJKCYi5LpqIVU2RXmEqH3eCq5awbTmuAq(HupSOYuucmocGxy5cUWStYOuffDzK3u4PuurJyyaYhbxy2jzuQRXmEqH3eCq5awb6f1ihtYijVi)zkkbw9NsIhXtMAuoj(6AEK6pLet8XzYijNmsE5dK4RR5rQ)usmXhNjJKCYi5LpqIIUmYB5bw9Nsc9IAKJjzKKxK)ex(SSnmgKCpJhu4cUWStsvaUnc6mH)djh0L0yGbddq(ikQfo7ysdJhKzssoDrulV8xBfvKXdYmjjNUiQL3P0wJbgr9Dkf1bj4cZojvJRkxVl5JIkoCDqJiJyGjtOJhfQuNs71ygpOWBcoOCaRaUWStsvaUnMIsGv)PK4r8KPgLtIVUgdmyyaYhrrTWzhtAy8GmtsYPlIA5L)AROImEqMjj50frT8oL2AmWiQVtPOoibxy2jPACv56DjFuuXHRdAezedmzcD8OqL6uAVgZ4bfEtWbLdyf0(6u5HzEnMXdk8MGdkhWkGlm7KuLRIpitrjWQ)usWfMDsIZ46GeTHXGOqWgW4bzMKKtxe1YhvwBn13PuuhKGlm7KunUQC9UKpAgUoOrKrmWKj0XtEk1PwJz8GcVj4GYbSc4cZojv5Q4dYuucS6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiRXmEqH3eCq5awbCHzNKrPAkkbw9NscUWStsCgxhKOnmgeWkznMXdk8MGdkhWkWPjJk5qxDQnMIsGnOOurTmwfGuurJyqyqq(H2Au)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbznMXdk8MGdkhWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8OP(oLI6GeCHzNKipHC0OLgdmyyaYhbF1bqjeMhu4Ay8GmtsYPlIA5z01wrfz8GmtsYPlIA5DkTxJz8GcVj4GYbSc4cZojVOwdbqntrjWQ)usGbiUWCBq(HOigpAggG8rWfMDss4SqZJu)PKyIpotgj5KrYlFGeFDngmma5JGV6aOecZdkCfvKXdYmjjNUiQLNsx71ygpOWBcoOCaRaUWStYlQ1qauZuucS6pLeyaIlm3gKFikIXJMHbiFe8vhaLqyEqHRHXdYmjjNUiQLx(VgZ4bfEtWbLdyfWfMDssN1bIgkCtrjWQ)usWfMDsIZ46GeTHXGKN6pLeCHzNK4mUoiXLplBdJbznMXdk8MGdkhWkGlm7KKoRdenu4MIsGv)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrJErMLh4Nqzbxy2jPkxfFqRXmEqH3eCq5awbK5aZdkCtr(qv91hjkb(Yol0XJcbR0pLPiFOQ(6JeDV0dXdbw51414C3cZVcffAqNo0c)nKFSWJc1a0AHimcdql0cnzlK1fl0OPrlenl0cnzlCI5UWyYOYc1iXAmJhu4nbocGxy5nWPkAJ0dZSPOe467ukQdsCuOgGwsegHbin4iaEHLl4cZoj1dlQefDzK3uOsPen4iaEHLlM4JZKrsozK8Yhirrxg5nWkrJbQ)usWfMDsIZ46GeTHXGKhyZCHyvasmXCLx(SeNX1b10yGbddq(iQVtYij1dlQ0GJa4fwUO(ojJKupSOsu0LrElpWh4NgCeaVWYfCHzNK6HfvIIUmYBk0mxiwfGetmx5LplFeaRLmfLK11wrfnWiggG8ruFNKrsQhwuPbhbWlSCbxy2jPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjzDTvurCeaVWYfCHzNK6HfvIIUmYB5b(a)0w71ygpOWBcCeaVWYB5awbPkAJ0dZSPOe467ukQdsCuOgGwsegHbin4iaEHLl4cZoj1dlQefDzK3aRengyeddq(iihaDKnKtpfv0GHbiFeKdGoYgYPNMl7SqhpkeC(sjARTgdmahbWlSCXeFCMmsYjJKx(ajk6YiVPqLvIg1Fkj4cZojXzCDqI2WyqaR(tjbxy2jjoJRdsC5ZY2Wyq0wrfnahbWlSCXeFCMmsYjJKx(ajk6YiVbwjAu)PKGlm7KeNX1bjAdJbbSs0wBnQ)usuFNKrsQhwujEHLR5Yol0XJcbBMleRcqcwxEro6(VYl7SuhpRXmEqH3e4iaEHL3YbScsv0g1aymfLaxFNsrDqIhQHr6aiNlTK44Ez)PbhbWlSCH6pLKpudJ0bqoxAjXX9Y(tue)0sJ6pLepudJ0bqoxAjXX9Y(tMQOnIxy5Amq9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5ARbhbWlSCXeFCMmsYjJKx(ajk6YiVbwjAmq9NscUWStsCgxhKOnmgK8aBMleRcqIjMR8YNL4mUoOMgdmyyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5b(a)0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2kQObgXWaKpI67Kmss9WIkn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRTIkIJa4fwUGlm7KupSOsu0LrElpWh4N2AVgZ4bfEtGJa4fwElhWkiHksQcWTXuucC9Dkf1bjEOggPdGCU0sIJ7L9NgCeaVWYfQ)us(qnmsha5CPLeh3l7prr8tlnQ)us8qnmsha5CPLeh3l7pzcvK4fwUg9ImlpWpHYIufTrnaM14C3cZpgvl0KfNSql0KTWCl)wikTq0yyBH44I8Jf(1xylcxSWtFAHOzHwiaGfQsl83O3cTqt2cpjgtMPleZTzHOzHna0r2aO1cvPuu0AmJhu4nbocGxy5TCaRGlQQOAYijNOUKpMIsGXra8clxmXhNjJKCYi5LpqIIUmYB5zMleRcqIBms9IWe9KtmxPQwkQOb4iaEHLl4cZoj1dlQefDzK3uOzUqSkajUXiV8z5JayTKPOKSUgCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbiXng5LplFeaRLmfLCI5Q9AmJhu4nbocGxy5TCaRGlQQOAYijNOUKpMIsGXra8clxWfMDsQhwujkIFAPXaJyyaYhb5aOJSHC6POIgmma5JGCa0r2qo90CzNf64rHGZxkrBT1yGb4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqcwxE5ZYhbWAjtrjNyUAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrBfv0aCeaVWYft8XzYijNmsE5dKOOlJ8gyLOr9NscUWStsCgxhKOnmgeWkrBT1O(tjr9DsgjPEyrL4fwUMl7SqhpkeSzUqSkajyD5f5O7)kVSZsD8SgN7wyUbyXA1w4Vrl8r8KPgLtl0cnzlK1fl80Nw4eZDHO2clIFATqUTqlcaW0fEzqOf2(fTWjwiMBZcrZcvPuu0cNyUI1ygpOWBcCeaVWYB5awbpINm1OCYuucmocGxy5Ij(4mzKKtgjV8bsu0LrEdSs0O(tjbxy2jjoJRds0ggdsEGnZfIvbiXeZvE5ZsCgxhutdocGxy5cUWSts9WIkrrxg5T8aFGFRXmEqH3e4iaEHL3YbScEepzQr5KPOeyCeaVWYfCHzNK6HfvIIUmYBGvIgdmIHbiFeKdGoYgYPNIkAWWaKpcYbqhzd50tZLDwOJhfcoFPeT1wJbgGJa4fwUyIpotgj5KrYlFGefDzK3uOYkrJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAROIgGJa4fwUyIpotgj5KrYlFGefDzK3aRenQ)usWfMDsIZ46GeTHXGawjARTg1FkjQVtYij1dlQeVWY1CzNf64rHGnZfIvbibRlVihD)x5LDwQJN14C3cnAA0cB6CbYcrPfoXCxi7VfY6lKlAHHVq8BHS)wOv4goluLw4xFHPOwiq4huTWjJ9foz0cV85f(iawltx4Lbb5hlS9lAHw0cZyZ0c5zHae3MfowXc5cZoTqCgxhuBHS)w4KXZcNyUl0IBUHZcpD73Mf(B0tSgZ4bfEtGJa4fwElhWkO4hI9r205cetrjW4iaEHLlM4JZKrsozK8Yhirrxg5nfAMleRcqIQjV8z5JayTKPOKtmxn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajQM8YNLpcG1sMIsY6AmyyaYhr9DsgjPEyrLgdWra8clxuFNKrsQhwujk6YiVLhDMW)HKd6skQiocGxy5I67Kmss9WIkrrxg5nfAMleRcqIQjV8z5JayTKPOKvORTIkAeddq(iQVtYij1dlQ0wJ6pLeCHzNK4mUoirBymik0eAEK6pLet8XzYijNmsE5dK4fwUg1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fw(ACUBHgnnAHnDUazHwOjBHS(cTYiFH6rRHubiXcp9PfoXCxiQTWI4NwlKBl0IaamDHxgeAHTFrlCIfI52Sq0SqvkffTWjMRynMXdk8MahbWlS8woGvqXpe7JSPZfiMIsGXra8clxmXhNjJKCYi5LpqIIUmYB5rNj8Fi5GUKg1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GAAWra8clxWfMDsQhwujk6YiVLNb0zc)hsoOlLdJhu4Ij(4mzKKtgjV8bsqNj8Fi5GUK2RXmEqH3e4iaEHL3YbSck(HyFKnDUaXuucmocGxy5cUWSts9WIkrrxg5T8OZe(pKCqxsJbgyeddq(iihaDKnKtpfv0GHbiFeKdGoYgYPNMl7SqhpkeC(sjARTgdmahbWlSCXeFCMmsYjJKx(ajk6YiVPqZCHyvasW6YlFw(iawlzkk5eZvJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAROIgGJa4fwUyIpotgj5KrYlFGefDzK3aRenQ)usWfMDsIZ46GeTHXGawjARTg1FkjQVtYij1dlQeVWY1CzNf64rHGnZfIvbibRlVihD)x5LDwQJhTxJZDl0OPrlCI5Uql0KTqwFHO0crJHTfAHMmKVWjJw4LpVWhbWAjw4PpTqpgtx4Vrl0cnzlSc9fIslCYOfoma5ZcrTfomiKB6cz)Tq0yyBHwOjd5lCYOfE5Zl8raSwI1ygpOWBcCeaVWYB5awbt8XzYijNmsE5dKPOey1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GAAWra8clxWfMDsQhwujk6YiVLhy6mH)djh0L0CzNf64rHM5cXQaKG1LxKJU)R8Yol1XJg1FkjQVtYij1dlQeVWYxJz8GcVjWra8clVLdyfmXhNjJKCYi5LpqMIsGv)PKGlm7KeNX1bjAdJbjpWM5cXQaKyI5kV8zjoJRdQPzyaYhr9DsgjPEyrLgCeaVWYf13jzKK6HfvIIUmYB5bMot4)qYbDjn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRRbhbWlSCbxy2jPEyrLOOlJ8Mcv2eRXmEqH3e4iaEHL3YbScM4JZKrsozK8YhitrjWQ)usWfMDsIZ46GeTHXGKhyZCHyvasmXCLx(SeNX1b10yGrmma5JO(ojJKupSOsrfXra8clxuFNKrsQhwujk6YiVPqZCHyvasmXCLx(S8raSwYuuYk01wdocGxy5cUWSts9WIkrrxg5nfAMleRcqIjMR8YNLpcG1sMIsY6RX5UfA00OfY6leLw4eZDHO2cdFH43cz)TqRWnCwOkTWV(ctrTqGWpOAHtg7lCYOfE5Zl8raSwMUWldcYpwy7x0cNmEwOfTWm2mTqYJ)r2cVSZlK93cNmEw4KrfTquBHEmlKbkIFATqEH13PfgPfQhwuTWxy5I1ygpOWBcCeaVWYB5awbCHzNK6HfvMIsGXra8clxmXhNjJKCYi5LpqIIUmYBk0mxiwfGeSU8YNLpcG1sMIsoXC1yGrGdZKZ(imt(KPvPOI4iaEHLlUOQIQjJKCI6s(ik6YiVPqZCHyvasW6YlFw(iawlzkk5ngT1O(tjbxy2jjoJRds0ggdcy1Fkj4cZojXzCDqIlFw2ggdIg1FkjQVtYij1dlQeVWY1CzNf64rHGnZfIvbibRlVihD)x5LDwQJN14C3cnAA0cRqFHO0cNyUle1wy4le)wi7VfAfUHZcvPf(1xykQfce(bvlCYyFHtgTWlFEHpcG1Y0fEzqq(XcB)Iw4KrfTquZnCwidue)0AH8cRVtl8fw(cz)TWjJNfY6l0kCdNfQs44slKnZiawfGw47xi)yH13jXAmJhu4nbocGxy5TCaRG67Kmss9WIktrjWQ)usWfMDsQhwujEHLRXaCeaVWYft8XzYijNmsE5dKOOlJ8McnZfIvbirf6YlFw(iawlzkk5eZvrfXra8clxWfMDsQhwujk6YiVLhyZCHyvasmXCLx(S8raSwYuuswxBnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGObhbWlSCbxy2jPEyrLOOlJ8Mcv2eRXmEqH3e4iaEHL3YbScAzO0G8dPEyrLPOey1Fkj4cZoj1dlQeVWY1GJa4fwUGlm7KupSOsm1NKfDzK3uiJhu4Iwgkni)qQhwujWVsJ6pLe13jzKK6HfvIxy5AWra8clxuFNKrsQhwujM6tYIUmYBkKXdkCrldLgKFi1dlQe4xP5rQ)usmXhNjJKCYi5LpqIxy5RX5UfA00OfQh3foXcB5ZprNo0czFH05P4fYQle5lCYOf605zH4iaEHLVqlK)cltx43bOwBHGOvHyFHtg5lmCaTw47xi)yHCHzNwOEyr1cFFAHtSWSWAHx25fM99JsRfw8dX(SWMoxGSquBnMXdk8MahbWlS8woGvGErnYXKmsYlYFMIsGhgG8ruFNKrsQhwuPr9NscUWSts9WIkXxxJ6pLe13jzKK6HfvIIUmYB5DGFIlFEnMXdk8MahbWlS8woGvGErnYXKmsYlYFMIsGFK6pLet8XzYijNmsE5dK4RR5rQ)usmXhNjJKCYi5LpqIIUmYB5X4bfUGlm7K8IAnea1e0zc)hsoOlPXiWHzYzFeGOvHyFnMXdk8MahbWlS8woGvGErnYXKmsYlYFMIsGv)PKO(ojJKupSOs811O(tjr9DsgjPEyrLOOlJ8wEh4N4YN1GJa4fwUGmhyEqHlkIFAPbhbWlSCXeFCMmsYjJKx(ajk6YiVPXiWHzYzFeGOvHyFnEnMXdk8MiHCgqQ(lphWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8ykoJroyLxJz8GcVjsiNbKQ)YZbSc4cZojvb42SgZ4bfEtKqodiv)LNdyfWfMDsQYvXh0A8ACUBH5dzKVW67oYpwiHMmQw4Krl02EHrTWtYhwiaDq(Jle1mDHw0cTyFw4el80yowOkLIIw4Krl8Kymzki3YVfAH8xyjwOrtJwiAwi3wylcFHCBH57i)wyg3wyc5Owg9wy8RfArgAMwytN8zHXVwioJRdQTgZ4bfEtKqTmKFidDYPcmzoW8Gc3uucSb13PuuhKOH0Zcx2MOUkQy9Dkf1bjg6QhfdiT4sxBngO(tjr9DsgjPEyrL4fwUIkQxKz5b(juwWfMDsQYvXhK2AWra8clxuFNKrsQhwujk6YiVTgN7w4PpTqlYqZ0ctih1YO3cJFTqCeaVWYxOfYFHvBHS)wytN8zHXVwioJRdQz6c1luuObD6ql80yowyyMQfsMPsRjd5hlKaA0AmJhu4nrc1Yq(Hm0jNQCaRaYCG5bfUPOe4HbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVPbhbWlSCbxy2jPEyrLOOlJ8Mg1Fkj4cZoj1dlQeVWY1O(tjr9DsgjPEyrL4fwUg9ImlpWpHYcUWStsvUk(GwJz8GcVjsOwgYpKHo5uLdyfKqfjvb42ykkbU(oLI6GepudJ0bqoxAjXX9Y(tJ6pLepudJ0bqoxAjXX9Y(tMQOnIV(AmJhu4nrc1Yq(Hm0jNQCaRGufTr6Hz2uucC9Dkf1bjokudqljcJWaKMl7SqhpkuPFQ1ygpOWBIeQLH8dzOtov5awbpINm1OCYuucSruFNsrDqIgsplCzBI6QXiQVtPOoiXqx9OyaPfx6RXmEqH3ejuld5hYqNCQYbSc4cZojJs1uucmocGxy5I67Kmss9WIkrr8tR1ygpOWBIeQLH8dzOtov5awbCHzNKQaCBmfLaJJa4fwUO(ojJKupSOsue)0sJ6pLeCHzNK4mUoirBymi5P(tjbxy2jjoJRdsC5ZY2WyqwJz8GcVjsOwgYpKHo5uLdyfuFNKrsQhwuTgN7w4PpTqlYWIwipl8YNxyBymiTfgPfAug1cz)TqlAHzSzYnCw4VrVfAYItwOw0y6c)nAH8cBdJbzHtSq9Imt(SW73Xzi)ynMXdk8MiHAzi)qg6KtvoGvaxy2j5f1AiaQzkkbw9NscmaXfMBdYpefX4rJ6pLeyaIlm3gKFiAdJbbS6pLeyaIlm3gKFiU8zzBymiAWHzYzFeMjFY0Q0GJa4fwU4IQkQMmsYjQl5JOi(P1ACUBHGkQldaO1cTOfQZOAH6XGcFH)gTql0KTWCl)mDHQ)zHOzHwiaGfcWTzHaHFSqYJ)r2ctrTq1yYw4KrlmFh53cz)TWCl)wOfYFHvBHFhGATfwF3r(XcNmAH22lmQfEs(WcbOdYFCHO2AmJhu4nrc1Yq(Hm0jNQCaRa9yqHBkkb2imO(oLI6GenKEw4Y2e1vrfRVtPOoiXqx9OyaPfx6AVgZ4bfEtKqTmKFidDYPkhWk4r8KPgLtMIsGv)PKO(ojJKupSOs8clxrf1lYS8a)ekl4cZojv5Q4dAnMXdk8MiHAzi)qg6KtvoGvqXpe7JSPZfiMIsGv)PKO(ojJKupSOs8clxrf1lYS8a)ekl4cZojv5Q4dAnMXdk8MiHAzi)qg6KtvoGvWfvvunzKKtuxYhtrjWQ)usuFNKrsQhwujEHLROI6fzwEGFcLfCHzNKQCv8bTgZ4bfEtKqTmKFidDYPkhWkyIpotgj5KrYlFGmfLaR(tjr9DsgjPEyrL4fwUIkQxKz5b(juwWfMDsQYvXhKIkQxKz5b(juwCrvfvtgj5e1L8rrf1lYS8a)eklk(HyFKnDUarrf1lYS8a)eklEepzQr50AmJhu4nrc1Yq(Hm0jNQCaRaUWSts9WIktrjW6fzwEGFcLft8XzYijNmsE5d0ACUBHgnnAH5xyYw4elSLp)eD6qlK9fsNNIxyUvy2PfcAaUnl89lKFSWjJw4jXyYuqULFl0c5VWAHFhGATfwF3r(XcZTcZoTWtdolel80NwyUvy2PfEAWzXcrTfoma5d9mDHw0cXSB4SWFJwy(fMSfAHMmKVWjJw4jXyYuqULFl0c5VWAHFhGATfArle5dv1xFw4Krlm3mzleNXUtaMUWwSqlYqaGf2yZ0crJynMXdk8MiHAzi)qg6KtvoGvGErnYXKmsYlYFMIsGnIHbiFeCHzNKeol08i1FkjM4JZKrsozK8YhiXxxZJu)PKyIpotgj5KrYlFGefDzK3YdSbmEqHl4cZojvb42iOZe(pKCqxk3R(tjHErnYXKmsYlYFIlFw2ggdI2RX5UfE6tlm)ct2cZ4MB4SqvI8f(B0BHVFH8Jfoz0cpjgt2cTq(lSmDHwKHaal83OfIMfoXcB5ZprNo0czFH05P4fMBfMDAHGgGBZcr(cNmAH57i)uqULFl0c5VWsSgZ4bfEtKqTmKFidDYPkhWkqVOg5ysgj5f5ptrjWQ)usWfMDsQhwuj(6Au)PKO(ojJKupSOsu0LrElpWgW4bfUGlm7KufGBJGot4)qYbDPCV6pLe6f1ihtYijVi)jU8zzBymiAVgZ4bfEtKqTmKFidDYPkhWkGlm7KufGBJPOe4xmIIFi2hztNlqefDzK3u4PuuXhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGOqLSgN7wy(aTql2NfoXcVmi0cB)IwOfTWm2mTqYJ)r2cVSZlmf1cNmAHKpOIwyULFl0c5VWY0fsMjFHO0cNmQidBlSniaGfoOlTWIUmYr(XcdFH57i)el80pg2wy4aATqvAgQw4elu9x(cNyHNouflK93cpnMJfIslS(UJ8Jfoz0cTTxyul8K8HfcqhK)4crnXAmJhu4nrc1Yq(Hm0jNQCaRaUWStsvUk(GmfLaJJa4fwUGlm7KupSOsue)0sZLDwOJN8mi)vsogOSsY94Wm5Spcq0QqSRT2Au)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbrJruFNsrDqIgsplCzBI6QXiQVtPOoiXqx9OyaPfx6RX5UfA04auRTW67oYpw4Krlm3km70cvACDdxRfcqhK)4sltxiO5Q4dAHTS4d8wOhZcvPf(B0BH8SWjJwi5VfgPfMB53crPfEAmhyEqHVquBHrkTqCeaVWYxi3w4RcDDKFSqCgxhuBHwiaGfEzqOfIMfomi0cbc)GQfoXcv)LVWjRI)r2cl6Yih5hl8YoVgZ4bfEtKqTmKFidDYPkhWkGlm7KuLRIpitrjWQ)usWfMDsQhwuj(6Au)PKGlm7KupSOsu0LrElpWh4NgdQVtPOoibxy2jjYtihnAPOI4iaEHLliZbMhu4IIUmYBAVgN7wiO5Q4dAHTS4d8widyXA1wOkTWjJwia3MfI52SqKVWjJwy(oYVfAH8xyTqUTWtIXKTqleaWclQnrrlCYOfIZ46GAlSPt(SgZ4bfEtKqTmKFidDYPkhWkGlm7KuLRIpitrjWQ)usuFNKrsQhwuj(6Au)PKGlm7KupSOs8clxJ6pLe13jzKK6HfvIIUmYB5b(a)wJz8GcVjsOwgYpKHo5uLdyfWfMDsErTgcGAMIsGFK6pLet8XzYijNmsE5dK4RRzyaYhbxy2jjHZcngO(tjXJ4jtnkNeVWYvurgpiZKKC6IOgyL1wZJu)PKyIpotgj5KrYlFGefDzK3uiJhu4cUWStYlQ1qautqNj8Fi5GUKP4mg5Gv2uIlaTK4mg5sucS6pLeyaIlm3gKFiXzS7eG4fwUgdu)PKGlm7KupSOs81vurdmIHbiFeHzQ0dlQONgdu)PKO(ojJKupSOs81vurCeaVWYfK5aZdkCrr8tlT1w714C3cnADaTwyB4Aw4VH8JfAug1cZnt2cTYiFH5w(TWmUTqvI8f(B0BnMXdk8MiHAzi)qg6KtvoGvaxy2j5f1AiaQzkkbw9NscmaXfMBdYpefX4rdocGxy5cUWSts9WIkrrxg5nngO(tjr9DsgjPEyrL4RROIQ)usWfMDsQhwuj(6ABkoJroyLxJz8GcVjsOwgYpKHo5uLdyfWfMDsgLQPOey1Fkj4cZojXzCDqI2WyqYdSzUqSkajMyUYlFwIZ46GARXmEqH3ejuld5hYqNCQYbSc4cZojvb42ykkbw9NsI67Kmss9WIkXxxrfVSZcD8OqLp1AmJhu4nrc1Yq(Hm0jNQCaRaYCG5bfUPOey1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fwUPiFOQ(6JeLaFzNf64rHGn6NYuKpuvF9rIUx6H4HaR8AmJhu4nrc1Yq(Hm0jNQCaRaUWStsvUk(GwJxJZD5UfY4bfEtKX1nCTaJzhtasgpOWnfLaZ4bfUGmhyEqHlWzS7eaYp0CzNf64rHGv6NAno3TqJMgTWtJ5aZdk8fIsl0ImSOfcewlm8fEzNxi7VfYl8Kymzki3YVfAH8xyTquBH44I8Jf(1xJz8GcVjY46gUw5awbK5aZdkCtrjWx2zHoEYdSYNsdocGxy5Ij(4mzKKtgjV8bsu0LrElpWgqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6sARbhbWlSCbxy2jPEyrLOOlJ8wEGnGot4)qYbDPCy8GcxmXhNjJKCYi5Lpqc6mH)djh0LYHXdkCbxy2jPEyrLGot4)qYbDjT1O(tjr9DsgjPEyrL4fwUg1Fkj4cZoj1dlQeVWY18i1FkjM4JZKrsozK8YhiXlSCngXlgrXpe7JSPZfiIIUmYBRX5UfA00OfEAmhyEqHVquAHwKHfTqGWAHHVWl78cz)TqEH57i)wOfYFH1crTfIJlYpw4xFnMXdk8MiJRB4ALdyfqMdmpOWnfLaFzNf64jpWkLs0GJa4fwUO(ojJKupSOsu0LrElpWgqNj8Fi5GUuomEqHlQVtYij1dlQe0zc)hsoOlPTgCeaVWYft8XzYijNmsE5dKOOlJ8wEGnGot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxkhgpOWff)qSpYMoxGiOZe(pKCqxsBn4iaEHLl4cZoj1dlQefDzK3uy(RK1ygpOWBImUUHRvoGvaxy2jPka3gtrjW4iaEHLlk(HyFKnDUaru0LrElpWMi3FGF5yMleRcqctUstQxuBymii)qoOlLdDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMCLMuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCrXpe7JSPZfic6mH)djh0L0GJa4fwUGlm7KupSOsu0LrElpWM5cXQaKWKR0K6f1ggdcYpKd6s5qNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6sAu)PKGlm7KeNX1bjAdJbrHkRr9NscUWStsCgxhKOnmgK8YFngbo83hncUWSts9kEOdTwJz8GcVjY46gUw5awbCHzNKQaCBmfLaJJa4fwUO(ojJKupSOsu0LrElpWMi3FGF5yMleRcqctUstQxuBymii)qoOlLdDMW)HKd6s5W4bfUO(ojJKupSOsqNj8Fi5GUKgCeaVWYff)qSpYMoxGik6YiVLhyZCHyvasyYvAs9IAdJbb5hYbDPCOZe(pKCqxkhgpOWf13jzKK6Hfvc6mH)djh0L0GJa4fwUyIpotgj5KrYlFGefDzK3YdSzUqSkajm5knPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVPr9NscUWStsCgxhKOnmgefQSg1Fkj4cZojXzCDqI2WyqYl)1ye4WFF0i4cZoj1R4Ho0AnMXdk8MiJRB4ALdyfWfMDsQcWTXuucmocGxy5IIFi2hztNlqefDzK3YdSjY9h4xoM5cXQaKWKR0K6f1ggdcYpKd6sAWra8clxWfMDsQhwujk6YiVPqWkLs0GJa4fwUyIpotgj5KrYlFGefDzK3YrPusEGXra8clxWfMDsQhwujk6YiVPbhbWlSCr9DsgjPEyrLOOlJ8wokLsYdmocGxy5cUWSts9WIkrrxg5nnQ)usWfMDsIZ46GeTHXGOqL1O(tjbxy2jjoJRds0ggdsE5VgJah(7Jgbxy2jPEfp0HwRXmEqH3ezCDdxRCaRaUWStsvUk(GmfLaJJa4fwUO4hI9r205cerrxg5T8aFGF5yMleRcqctUstQxuBymii)qoOlLdDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMCLMuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCrXpe7JSPZfic6mH)djh0L0GJa4fwUGlm7KupSOsu0LrElpWM5cXQaKWKR0K6f1ggdcYpKd6s5qNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUuomEqHlM4JZKrsozK8YhibDMW)HKd6sAu)PKGlm7KeNX1bjAdJbrHkVgZ4bfEtKX1nCTYbSc4cZojv5Q4dYuucmocGxy5I67Kmss9WIkrrxg5T8aFGF5yMleRcqctUstQxuBymii)qoOlLdDMW)HKd6s5W4bfUO(ojJKupSOsqNj8Fi5GUKgCeaVWYff)qSpYMoxGik6YiVLhyZCHyvasyYvAs9IAdJbb5hYbDPCOZe(pKCqxkhgpOWf13jzKK6Hfvc6mH)djh0L0GJa4fwUyIpotgj5KrYlFGefDzK3YdSzUqSkajm5knPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6s5W4bfUO4hI9r205cebDMW)HKd6sAWra8clxWfMDsQhwujk6YiVPr9NscUWStsCgxhKOnmgefQ8AmJhu4nrgx3W1khWkGlm7KuLRIpitrjW4iaEHLlk(HyFKnDUaru0LrElpWh4xoM5cXQaKWKR0K6f1ggdcYpKd6sAWra8clxWfMDsQhwujk6YiVPqWkLs0GJa4fwUyIpotgj5KrYlFGefDzK3YrPusEGXra8clxWfMDsQhwujk6YiVPbhbWlSCr9DsgjPEyrLOOlJ8wokLsYdmocGxy5cUWSts9WIkrrxg5nnQ)usWfMDsIZ46GeTHXGOqL1ye4WFF0i4cZoj1R4Ho0Ano3Tqq)raVfQ046gUwlSnmgK2ctrTWjJw4jXyYuqULFl0c5VWAnMXdk8MiJRB4ALdyfWfMDsErTgcGAMIsGv)PKGlm7KmJRB4AjAdJbjp1Fkj4cZojZ46gUwIlFw2ggdIgCeaVWYff)qSpYMoxGik6YiVLhyZCHyvasyYvAs9IAdJbb5hYbDPCOZe(pKCqxsdocGxy5Ij(4mzKKtgjV8bsu0LrElpWM5cXQaKWKR0K6f1ggdcYpKd6s5qNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUKgCeaVWYfCHzNK6HfvIIUmYB5b2mxiwfGeMCLMuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCrXpe7JSPZfic6mH)djh0LYHXdkCXeFCMmsYjJKx(ajOZe(pKCqxYuCgJCWkVgN7wiO)iG3cvACDdxRf2ggdsBHPOw4KrlmFh53cTq(lSwJz8GcVjY46gUw5awbCHzNKxuRHaOMPOey1Fkj4cZojZ46gUwI2WyqYt9NscUWStYmUUHRL4YNLTHXGObhbWlSCr9DsgjPEyrLOOlJ8wEGnZfIvbiHjxPj1lQnmgeKFih0LYHot4)qYbDPCy8GcxuFNKrsQhwujOZe(pKCqxsdocGxy5IIFi2hztNlqefDzK3YdSzUqSkajm5knPErTHXGG8d5GUuo0zc)hsoOlLdJhu4I67Kmss9WIkbDMW)HKd6sAWra8clxmXhNjJKCYi5LpqIIUmYB5b2mxiwfGeMCLMuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCr9DsgjPEyrLGot4)qYbDPCy8Gcxu8dX(iB6CbIGot4)qYbDjn4iaEHLl4cZoj1dlQefDzK3mfNXihSYRX5Ufc6pc4TqLgx3W1AHTHXG0wykQfoz0cDge6TW8T9cTq(lSwJz8GcVjY46gUw5awbCHzNKxuRHaOMPOey1Fkj4cZojZ46gUwI2WyqYt9NscUWStYmUUHRL4YNLTHXGObhbWlSCrXpe7JSPZfiIIUmYB5b2mxiwfGeMCLMuVO2Wyqq(HCqxkh6mH)djh0LYHXdkCrXpe7JSPZfic6mH)djh0L0GJa4fwUGlm7KupSOsu0LrEtHGvkLObhbWlSCr9DsgjPEyrLOOlJ8McbRukrJrGd)9rJGlm7KuVIh6qltXzmYbR8AmJhu4nrgx3W1khWkO4hI9r205cetrjWQ)usWfMDsIZ46GeTHXGKNj0O(tjbxy2jzgx3W1s0ggdcy1Fkj4cZojZ46gUwIlFw2ggdIgCeaVWYft8XzYijNmsE5dKOOlJ8wE0zc)hsoOlPbhbWlSCbxy2jPEyrLOOlJ8wEGnGot4)qYbDPCy8GcxmXhNjJKCYi5Lpqc6mH)djh0L0wZLDwOJhfQ8PwJz8GcVjY46gUw5awbt8XzYijNmsE5dKPOey1Fkj4cZojXzCDqI2WyqYZeAu)PKGlm7KmJRB4AjAdJbbS6pLeCHzNKzCDdxlXLplBdJbrdocGxy5cUWSts9WIkrrxg5T8atNj8Fi5GUKMxmIIFi2hztNlqefDzK3wJz8GcVjY46gUw5awbCHzNK6HfvMIsGv)PKGlm7KmJRB4AjAdJbbS6pLeCHzNKzCDdxlXLplBdJbrZJu)PKyIpotgj5KrYlFGeFDnQ)usuFNKrsQhwujEHLVgZ4bfEtKX1nCTYbScQVtYij1dlQmfLaR(tjbxy2jjoJRds0ggdsEMqJ6pLeCHzNKzCDdxlrBymiGv)PKGlm7KmJRB4AjU8zzBymiAWra8clxu8dX(iB6CbIOOlJ8wEGPZe(pKCqxsdocGxy5Ij(4mzKKtgjV8bsu0LrElpWgqNj8Fi5GUuomEqHlk(HyFKnDUarqNj8Fi5GUK2AWra8clxWfMDsQhwujk6YiVPW8)u5yMleRcqctUst(iawla0fnYCl)0CzNf64rHGvQtTgZ4bfEtKX1nCTYbSck(HyFKnDUaXuucS6pLeCHzNK4mUoirBymi5zcnQ)usWfMDsMX1nCTeTHXGaw9NscUWStYmUUHRL4YNLTHXGObhbWlSCXeFCMmsYjJKx(ajk6YiVLhDMW)HKd6sAu)PKO(ojJKupSOs81xJz8GcVjY46gUw5awbt8XzYijNmsE5dKPOey1Fkj4cZojZ46gUwI2WyqaR(tjbxy2jzgx3W1sC5ZY2Wyq0O(tjr9DsgjPEyrL4RR5fJO4hI9r205cerrxg5T1ygpOWBImUUHRvoGvq9DsgjPEyrLPOeydWra8clxmXhNjJKCYi5LpqIIUmYB5K)Ns78aJJa4fwUGlm7KupSOsu0LrEtJ6pLeCHzNK6HfvIxy5AmcC4VpAeCHzNK6v8qhATgZ4bfEtKX1nCTYbSck(HyFKnDUaXuucS6pLeCHzNKzCDdxlrBymiGv)PKGlm7KmJRB4AjU8zzBymiAWra8clxWfMDsQhwujk6YiVPqWkLs0GJa4fwUyIpotgj5KrYlFGefDzK3YrPusEGXra8clxWfMDsQhwujk6YiVPbhbWlSCr9DsgjPEyrLOOlJ8wokLsYdmocGxy5cUWSts9WIkrrxg5nnx2zHoEuiyLpLgJah(7Jgbxy2jPEfp0HwRXmEqH3ezCDdxRCaRaUWStYOunfLa)Iru8dX(iB6CbIOOlJ8McpLMhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGawjAu)PKO(ojJKupSOs8clFnMXdk8MiJRB4ALdyfWfMDsQYvXhKPOe4hP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGao)xJz8GcVjY46gUw5awbCHzNKQaCBmfLa)Iru8dX(iB6CbIOOlJ8MMhP(tjXeFCMmsYjJKx(ajk6YiVPq6mH)djh0L0yWJu)PKO4hI9r205ceP5pGtfRIaqJwI2WyqaRefv8rQ)usu8dX(iB6CbI08hWPIvraOrlrBymi5L)ARXi0lYS8a)ekl4cZojv5Q4dAnMXdk8MiJRB4ALdyfWfMDsQcWTXuuc8lgrXpe7JSPZfiIIUmYBkKot4)qYbDjnps9NsIIFi2hztNlqKM)aovSkcanAjAdJbrHkrZJu)PKO4hI9r205ceP5pGtfRIaqJwI2WyqYl)1O(tjr9DsgjPEyrL4fw(AmJhu4nrgx3W1khWkGlm7KmkvtrjWQ)usWfMDsIZ46GeTHXGKNj0O(tjbxy2jPEyrL4RVgZ4bfEtKX1nCTYbSc4cZojVOwdbqntrjWQ)usGbiUWCBq(HOigpAu)PKGlm7KupSOs81nfNXihSYRX5UfA00OfMFHjBHVFH8JfMB53cJAH57i)wOfYFHvBHtSq1pc4TqCgxhuBHCAOAH)gYpwyUvy2PfcAUk(GwJz8GcVjY46gUw5awb6f1ihtYijVi)zkkbw9NscUWStsCgxhKOnmgK8u)PKGlm7KeNX1bjU8zzBymiAu)PKGlm7KeNX1bjAdJbrHkrJ6pLeCHzNK6HfvIIUmYBkQO6pLeCHzNK4mUoirBymi5P(tjbxy2jjoJRdsC5ZY2Wyq0O(tjbxy2jjoJRds0ggdIcvIg1FkjQVtYij1dlQefDzK308i1FkjM4JZKrsozK8Yhirrxg5T1ygpOWBImUUHRvoGvaxy2jPka3gtrjWQ)usOxuJCmjJK8I8N4RRr9NscUWStsCgxhKOnmgefQ8AmJhu4nrgx3W1khWkGlm7KmkvtrjWQ)usWfMDsIZ46GeTHXGKNj0GJa4fwUGlm7KupSOsu0LrEtHGnHsYhn65(d8tJryaocGxy5IIFi2hztNlqefDzK3YdSYkrdocGxy5cUWSts9WIkrrxg5nfcoFDkTxJz8GcVjY46gUw5awbCHzNKrPAkkbw9NscUWStsCgxhKOnmgK8mHgCeaVWYfCHzNK6HfvIIUmYBkeSjus(Orp3FGFAWH)(OrWfMDsQxXdDO1AmJhu4nrgx3W1khWkGlm7K8IAnea1mfLaR(tjbxy2jjoJRds0ggdIcvwJ6pLeCHzNKzCDdxlrBymi5P(tjbxy2jzgx3W1sC5ZY2WyqmfNXihSYRXmEqH3ezCDdxRCaRaUWStYlQ1qauZuucmocGxy5cUWStYOuffDzK3Yl)1O(tjbxy2jzgx3W1s0ggdsEQ)usWfMDsMX1nCTex(SSnmgetXzmYbR8AmJhu4nrgx3W1khWkGlm7KuLRIpitrjWQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOr9NscUWStYmUUHRLOnmgeWQ)usWfMDsMX1nCTex(SSnmgK1ygpOWBImUUHRvoGvazoW8Gc3uuc8LDwOJN8u(uRX5UfMpKr(cvPXIiFH4iaEHLVqlK)cRMPl0Iwy4aATq1pc4TWjwy6daSqCgxhuBHCAOAH)gYpwyUvy2PfA0wQRXmEqH3ezCDdxRCaRaUWStsvaUnMIsGv)PKGlm7KeNX1bjAdJbrHkVgZ4bfEtKX1nCTYbSc4cZojVOwdbqntXzmYbR8A8AmJhu4nXnmtxYNCaRavaKdIKDTmfLaFdZ0L8r8qTHDmPqWkRK1ygpOWBIByMUKp5awb6f1ihtYijVi)TgZ4bfEtCdZ0L8jhWkGlm7K8IAnea1mfLaFdZ0L8r8qTHDmLNYkznMXdk8M4gMPl5toGvaxy2jzuQRXmEqH3e3WmDjFYbScsOIKQaCBwJxJz8GcVjcDYPcCcvKufGBJPOe467ukQds8qnmsha5CPLeh3l7pnQ)us8qnmsha5CPLeh3l7pzQI2i(6RXmEqH3eHo5uLdyfKQOnspmZMIsGRVtPOoiXrHAaAjryegG0CzNf64rHk9tTgZ4bfEte6KtvoGvWJ4jtnkNwJz8GcVjcDYPkhWkO4hI9r205cetrjWx2zHoEuy(RK1ygpOWBIqNCQYbScAzO0G8dPEyrLPOey1Fkj4cZoj1dlQeVWY1GJa4fwUGlm7KupSOsu0LrEBnMXdk8Mi0jNQCaRGlQQOAYijNOUKpRXmEqH3eHo5uLdyfmXhNjJKCYi5LpqRXmEqH3eHo5uLdyfWfMDsQhwuTgZ4bfEte6KtvoGvq9DsgjPEyrLPOey1FkjQVtYij1dlQeVWYxJZDl0OPrlm)ct2cNyHT85NOthAHSVq68u8cZTcZoTqqdWTzHVFH8Jfoz0cpjgtMcYT8BHwi)fwl87auRTW67oYpwyUvy2PfEAWzHyHN(0cZTcZoTWtdolwiQTWHbiFONPl0IwiMDdNf(B0cZVWKTql0KH8foz0cpjgtMcYT8BHwi)fwl87auRTqlAHiFOQ(6ZcNmAH5MjBH4m2DcW0f2IfArgcaSWgBMwiAeRXmEqH3eHo5uLdyfOxuJCmjJK8I8NPOeyJyyaYhbxy2jjHZcnps9NsIj(4mzKKtgjV8bs8118i1FkjM4JZKrsozK8Yhirrxg5T8aBaJhu4cUWStsvaUnc6mH)djh0LY9Q)usOxuJCmjJK8I8N4YNLTHXGO9ACUBHN(0cZVWKTWmU5goluLiFH)g9w47xi)yHtgTWtIXKTqlK)cltxOfziaWc)nAHOzHtSWw(8t0PdTq2xiDEkEH5wHzNwiOb42SqKVWjJwy(oYpfKB53cTq(lSeRXmEqH3eHo5uLdyfOxuJCmjJK8I8NPOey1Fkj4cZoj1dlQeFDnQ)usuFNKrsQhwujk6YiVLhydy8GcxWfMDsQcWTrqNj8Fi5GUuUx9Nsc9IAKJjzKKxK)ex(SSnmgeTz8GcVjcDYPkhWkGlm7KufGBJPOe4xmIIFi2hztNlqefDzK3u4PuuXhP(tjrXpe7JSPZfisZFaNkwfbGgTeTHXGOqLSgZ4bfEte6KtvoGvaxy2jPka3gtrjWQ)usOxuJCmjJK8I8N4RR5rQ)usmXhNjJKCYi5LpqIVUMhP(tjXeFCMmsYjJKx(ajk6YiVLhygpOWfCHzNKQaCBe0zc)hsoOlTgN7wyUbyXA1wiO5Q4dAH8SWjJwi5VfgPfMB53cTYiFH13DKFSWjJwyUvy2PfQ046gUwleGoi)XLwRXmEqH3eHo5uLdyfWfMDsQYvXhKPOey1Fkj4cZoj1dlQeFDnQ)usWfMDsQhwujk6YiVL3b(PP(oLI6GeCHzNKipHC0O1ACUBH5gGfRvBHGMRIpOfYZcNmAHK)wyKw4KrlmFh53cTq(lSwOvg5lS(UJ8Jfoz0cZTcZoTqLgx3W1AHa0b5pU0AnMXdk8Mi0jNQCaRaUWStsvUk(GmfLaR(tjr9DsgjPEyrL4RRr9NscUWSts9WIkXlSCnQ)usuFNKrsQhwujk6YiVLh4d8tt9Dkf1bj4cZojrEc5OrR1ygpOWBIqNCQYbSc4cZojVOwdbqntrjWps9NsIj(4mzKKtgjV8bs811mma5JGlm7KKWzHgdu)PK4r8KPgLtIxy5kQiJhKzssoDrudSYAR5rQ)usmXhNjJKCYi5LpqIIUmYBkKXdkCbxy2j5f1AiaQjOZe(pKCqxYuCgJCWkBkXfGwsCgJCjkbw9NscmaXfMBdYpK4m2Dcq8clxJbQ)usWfMDsQhwuj(6kQObgXWaKpIWmv6Hfv0tJbQ)usuFNKrsQhwuj(6kQiocGxy5cYCG5bfUOi(PL2AR9AmJhu4nrOtov5awbCHzNKxuRHaOMPOey1FkjWaexyUni)queJhtXzmYbR8AmJhu4nrOtov5awbCHzNKrPAkkbw9NscUWStsCgxhKOnmgK8aBMleRcqIjMR8YNL4mUoO2AmJhu4nrOtov5awbCHzNKQaCBmfLaR(tjr9DsgjPEyrL4RROIx2zHoEuOYNAnMXdk8Mi0jNQCaRaYCG5bfUPOey1FkjQVtYij1dlQeVWY1O(tjbxy2jPEyrL4fwUPiFOQ(6JeLaFzNf64rHGn6NYuKpuvF9rIUx6H4HaR8AmJhu4nrOtov5awbCHzNKQCv8bTgVgN7wiJhu4nrfdpOWZbScWSJjajJhu4MIsGz8GcxqMdmpOWf4m2Dca5hAUSZcD8OqWk9tPXaJO(oLI6GenKEw4Y2e1vrfv)PKOH0Zcx2MOUI2WyqaR(tjrdPNfUSnrDfx(SSnmgeTxJz8GcVjQy4bfEoGvazoW8Gc3uuc8LDwOJN8aBMleRcqcYCi1XJgdWra8clxmXhNjJKCYi5LpqIIUmYB5bMXdkCbzoW8GcxqNj8Fi5GUKIkIJa4fwUGlm7KupSOsu0LrElpWmEqHliZbMhu4c6mH)djh0LuurdggG8ruFNKrsQhwuPbhbWlSCr9DsgjPEyrLOOlJ8wEGz8GcxqMdmpOWf0zc)hsoOlPT2Au)PKO(ojJKupSOs8clxJ6pLeCHzNK6HfvIxy5AEK6pLet8XzYijNmsE5dK4fwUgJqViZYd8tOSyIpotgj5KrYlFGwJz8GcVjQy4bfEoGvazoW8Gc3uucC9Dkf1bjAi9SWLTjQRgCeaVWYfCHzNK6HfvIIUmYB5bMXdkCbzoW8GcxqNj8Fi5GU0ACUBHGMRIpOfIsleng2w4GU0cNyH)gTWjM7cz)TqlAHzSzAHtel8YUwleNX1b1wJz8GcVjQy4bfEoGvaxy2jPkxfFqMIsGXra8clxmXhNjJKCYi5LpqII4NwAmq9NscUWStsCgxhKOnmgefAMleRcqIjMR8YNL4mUoOMgCeaVWYfCHzNK6HfvIIUmYB5bMot4)qYbDjnx2zHoEuOzUqSkajyD5f5O7)kVSZsD8Or9NsI67Kmss9WIkXlSCTxJz8GcVjQy4bfEoGvaxy2jPkxfFqMIsGXra8clxmXhNjJKCYi5LpqII4NwAmq9NscUWStsCgxhKOnmgefAMleRcqIjMR8YNL4mUoOMMHbiFe13jzKK6HfvAWra8clxuFNKrsQhwujk6YiVLhy6mH)djh0L0GJa4fwUGlm7KupSOsu0LrEtHM5cXQaKyI5kV8z5JayTKPOKSU2RXmEqH3evm8GcphWkGlm7KuLRIpitrjW4iaEHLlM4JZKrsozK8Yhirr8tlngO(tjbxy2jjoJRds0ggdIcnZfIvbiXeZvE5ZsCgxhutJbgXWaKpI67Kmss9WIkfvehbWlSCr9DsgjPEyrLOOlJ8McnZfIvbiXeZvE5ZYhbWAjtrjRqxBn4iaEHLl4cZoj1dlQefDzK3uOzUqSkajMyUYlFw(iawlzkkjRR9AmJhu4nrfdpOWZbSc4cZojv5Q4dYuuc8Ju)PKO4hI9r205ceP5pGtfRIaqJwI2Wyqa)i1Fkjk(HyFKnDUarA(d4uXQia0OL4YNLTHXGOXa1Fkj4cZoj1dlQeVWYvur1Fkj4cZoj1dlQefDzK3Yd8b(PTgdu)PKO(ojJKupSOs8clxrfv)PKO(ojJKupSOsu0LrElpWh4N2RXmEqH3evm8GcphWkGlm7KufGBJPOe4xmIIFi2hztNlqefDzK3uOrxrfn4rQ)usu8dX(iB6CbI08hWPIvraOrlrBymikujAEK6pLef)qSpYMoxGin)bCQyveaA0s0ggdsEps9NsIIFi2hztNlqKM)aovSkcanAjU8zzBymiAVgZ4bfEtuXWdk8CaRaUWStsvaUnMIsGv)PKqVOg5ysgj5f5pXxxZJu)PKyIpotgj5KrYlFGeFDnps9NsIj(4mzKKtgjV8bsu0LrElpWmEqHl4cZojvb42iOZe(pKCqxAnMXdk8MOIHhu45awbCHzNKxuRHaOMPOe4hP(tjXeFCMmsYjJKx(aj(6AggG8rWfMDss4SqJbQ)us8iEYuJYjXlSCfvKXdYmjjNUiQbwzT1yWJu)PKyIpotgj5KrYlFGefDzK3uiJhu4cUWStYlQ1qautqNj8Fi5GUKIkIJa4fwUqVOg5ysgj5f5prrxg5nfvehMjN9raIwfIDTnfNXihSYMsCbOLeNXixIsGv)PKadqCH52G8djoJDNaeVWY1yG6pLeCHzNK6HfvIVUIkAGrmma5JimtLEyrf90yG6pLe13jzKK6HfvIVUIkIJa4fwUGmhyEqHlkIFAPT2AVgZ4bfEtuXWdk8CaRaUWStYlQ1qauZuucS6pLeyaIlm3gKFikIXJg1FkjOZ6S)ONupgYhedi(6RXmEqH3evm8GcphWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8OXa1Fkj4cZoj1dlQeFDfvu9NsI67Kmss9WIkXxxrfFK6pLet8XzYijNmsE5dKOOlJ8Mcz8GcxWfMDsErTgcGAc6mH)djh0L02uCgJCWkVgZ4bfEtuXWdk8CaRaUWStYlQ1qauZuucS6pLeyaIlm3gKFikIXJg1FkjWaexyUni)q0ggdcy1FkjWaexyUni)qC5ZY2WyqmfNXihSYRXmEqH3evm8GcphWkGlm7K8IAnea1mfLaR(tjbgG4cZTb5hIIy8Or9NscmaXfMBdYpefDzK3YdSbgO(tjbgG4cZTb5hI2WyqY9mEqHl4cZojVOwdbqnbDMW)HKd6sANZb(PTP4mg5GvEnMXdk8MOIHhu45awbonzujh6QtTXuucSbfLkQLXQaKIkAedcdcYp0wJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAu)PKGlm7KupSOs8clxZJu)PKyIpotgj5KrYlFGeVWYxJz8GcVjQy4bfEoGvaxy2jzuQMIsGv)PKGlm7KeNX1bjAdJbjpWM5cXQaKyI5kV8zjoJRdQTgZ4bfEtuXWdk8CaRG2xNkpmZMIsGVSZcD8KhyL(P0O(tjbxy2jPEyrL4fwUg1FkjQVtYij1dlQeVWY18i1FkjM4JZKrsozK8YhiXlS81ygpOWBIkgEqHNdyfWfMDsQcWTXuucS6pLe1hGKrsozfrnXxxJ6pLeCHzNK4mUoirBymikuPwJz8GcVjQy4bfEoGvaxy2jPkxfFqMIsGVSZcD8KhyZCHyvasOYvXhK8Yol1XJg1Fkj4cZoj1dlQeVWY1O(tjr9DsgjPEyrL4fwUMhP(tjXeFCMmsYjJKx(ajEHLRr9NscUWStsCgxhKOnmgeWQ)usWfMDsIZ46Gex(SSnmgen4iaEHLliZbMhu4IIUmYBRXmEqH3evm8GcphWkGlm7KuLRIpitrjWQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8clxJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAggG8rWfMDsgLQgCeaVWYfCHzNKrPkk6YiVLh4d8tZLDwOJN8aR0vIgCeaVWYfK5aZdkCrrxg5T1ygpOWBIkgEqHNdyfWfMDsQYvXhKPOey1Fkj4cZoj1dlQeFDnQ)usWfMDsQhwujk6YiVLh4d8tJ6pLeCHzNK4mUoirBymiGv)PKGlm7KeNX1bjU8zzBymiAmahbWlSCbzoW8Gcxu0LrEtrfRVtPOoibxy2jjYtihnAP9AmJhu4nrfdpOWZbSc4cZojv5Q4dYuucS6pLe13jzKK6HfvIVUg1Fkj4cZoj1dlQeVWY1O(tjr9DsgjPEyrLOOlJ8wEGpWpnQ)usWfMDsIZ46GeTHXGaw9NscUWStsCgxhK4YNLTHXGOXaCeaVWYfK5aZdkCrrxg5nfvS(oLI6GeCHzNKipHC0OL2RXmEqH3evm8GcphWkGlm7KuLRIpitrjWQ)usWfMDsQhwujEHLRr9NsI67Kmss9WIkXlSCnps9NsIj(4mzKKtgjV8bs8118i1FkjM4JZKrsozK8Yhirrxg5T8aFGFAu)PKGlm7KeNX1bjAdJbbS6pLeCHzNK4mUoiXLplBdJbznMXdk8MOIHhu45awbCHzNKQCv8bzkkbE46GgrgXatMqhp5PuNsJ6pLeCHzNK4mUoirBymikeSbmEqMjj50frT8rL1wt9Dkf1bj4cZojvJRkxVl5JggpiZKKC6IOMcvwJ6pLepINm1OCs8clFnMXdk8MOIHhu45awbCHzNK0zDGOHc3uuc8W1bnImIbMmHoEYtPoLg1Fkj4cZojXzCDqI2WyqYt9NscUWStsCgxhK4YNLTHXGOP(oLI6GeCHzNKQXvLR3L8rdJhKzssoDrutHkRr9NsIhXtMAuojEHLVgZ4bfEtuXWdk8CaRaUWStsvaUnRXmEqH3evm8GcphWkGmhyEqHBkkbw9NsI67Kmss9WIkXlSCnQ)usWfMDsQhwujEHLR5rQ)usmXhNjJKCYi5LpqIxy5RXmEqH3evm8GcphWkGlm7KuLRIpOUn)NSO622O7hGhu4gvXPPp9P3b]] )

    
end