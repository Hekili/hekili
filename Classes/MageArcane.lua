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
        arcanosphere = 5397, -- 353128
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
                if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end

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
        local val = 0
        
        if active_enemies > 2 then
            val = 1
        end

        -- actions.calculations=variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&prev_gcd.1.evocation&!(runeforge.siphon_storm|runeforge.temporal_warp)
        if val == 0 and prev_gcd[1].evocation and not ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            val = 1
        end
        
        -- actions.calculations+=/variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&buff.arcane_power.down&cooldown.arcane_power.remains&(runeforge.siphon_storm|runeforge.temporal_warp)
        if val == 0 and buff.arcane_power.down and cooldown.arcane_power.remains > 0 and ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            val = 1
        end

        return val
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
                else
                    removeStack( "clearcasting" )
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 3 ) end
                end
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
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 3 ) end
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
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 3 ) end
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
                heart_of_the_fae = {
                    id = 356881,
                    duration = 10,
                    max_stack = 1,
                }
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

    --[[ spec:RegisterSetting( "am_spam", 0, {
        type = "toggle",
        name = "Use |T136096:0|t Arcane Missiles Spam",
        icon = 136096,
        width = "full",
        get = function () return Hekili.DB.profile.specs[ 62 ].settings.am_spam == 1 end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 62 ].settings.am_spam = val and 1 or 0
        end,
        order = 2,
    } ) ]]

    
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


    spec:RegisterPack( "Arcane", 20210628, [[dav5Rgqivv0JqqQljvbvYMOiFcbgfI4uisRsQc5viuMffv3sQIKDrYVicnmIkogrPLruPNre00ikIRreyBefLVPQcmoIIQZjvrSoIc9oPkOsnpvv6EiQ9rrPdkvrTqeupebXeLQGkUirrYgLQGQ8reKiJebjQtQQcALev9sPkOQMjrb3uQc1orO6NsvqzOQQqlLOi1tPKPkvPRkvb5RiiPXsrXEvL)sQbR0HrTyK6XeMmqxgAZs5ZuQrlvonOvlvrQxRQQzRWTrYUP63IgofoUufy5cpxrtxLRdy7ePVRQmEIOZlv16rqcZhHSFj)K917ZcKp8rC5kh5kRCKzYvMRKRekx5k3FWZ66BGpldw8NTXNLZu4ZQNdb74ZYG7psg817ZAMaHaFwD3zmLrjkrB41bqRejLeNqkGbFW0fb3ojoHucj(SObGJ7h6p6NfiF4J4YvoYvw5iZKRmxjxjuUYktK7ZAAGIhXLzY9z1bbbr)r)SaXP4z1JzBS2EoeSJL8Yd4yTYvMBETYvoYv2s(s(EOjw713ak4rTwqkcP2o2bhq3U2SvROJDhh1c9dJaW4GPxl0NhYG1MTAjqWUahAwCW0jq9SgW5nF9(Ssd0X417J4Y(69zHotpqWhHFwIaEya5Nva4yldBubcNcOXa6C0xlskk2bvOZ0deSwt1sd0Akq4uangqNJ(ArsrXoOUf58uagplwCW0FwnyGA6bpV39iUCF9(SqNPhi4JWplrapmG8ZkaCSLHnQSd4C0xdfqXavOZ0deSwt1sXoRmexTMT2EIe8SyXbt)z1ICEApLYV7rCj817ZIfhm9NfiYxhDgo(SqNPhi4JWV7rCzYR3Nf6m9abFe(zjc4HbKFwuSZkdXvRzRvMiNNfloy6pRGbHSF6Pbh)F3J4sWR3Nfloy6plkyezm1ztFzqH(9SqNPhi4JWV7rCz2R3Nf6m9abFe(zjc4HbKFw0aTMIdb7O2i)WqbMFETMQvK5am)Cfhc2rTr(HHkqkg6ZNfloy6pRzhSDq3wBKFy8UhX)bVEFwOZ0de8r4NLiGhgq(zjYCaMFUIdb7O2i)Wqfid2Vwt1sd0AkoeSJArhh2OAES4FT)wlnqRP4qWoQfDCyJkkws98yX)Nfloy6ploeSJ6mOF3J4Y8xVpl0z6bc(i8ZseWddi)SePu0z)usr)66h1AQwrMdW8ZvuWiYyQZM(YGc9tfifd9zTMTwzUm5zXIdM(ZIdb7OMEWZ7DpI3tE9(SyXbt)zDjGOtNn91HAk2g(SqNPhi4JWV7rCzLZR3Nfloy6ploeSJAJ8dJNf6m9abFe(DpIlRSVEFwOZ0de8r4NLiGhgq(zrd0AkoeSJAJ8ddfy(5plwCW0FwbGJ6SPnYpmE3J4Yk3xVpl0z6bc(i8ZIfhm9NLrGt0fOoBAkOd(SaXPiGghm9Nvp0eR9hZECTxw7ShaGiHcSw2RfL8cU2EoeSJ1s4bpVAbbcOBx71H12BE9yj2Z)yTFqhm)QfWh4CwBa4o0TRTNdb7yTYuIUuv7pSvBphc2XALPeDzTWzThpq)qqZR9dRvWobxTatS2Fm7X1(bVoOx71H12BE9yj2Z)yTFqhm)QfWh4Cw7hwl0pmcaJR2RdRTN7X1k6y3XH51oZA)qcgJANSuSw4PEwIaEya5N1pR94b6NIdb7OgfDPcDMEGG1AQwqKgO1uxci60ztFDOMITHkaJAnvlisd0AQlbeD6SPVoutX2qvGum0N1(l5AjPwwCW0vCiyh10dEEkusuaCO(GuyT9OAPbAnLrGt0fOoBAkOdQOyj1ZJf)RL039iUSs4R3Nf6m9abFe(zXIdM(ZYiWj6cuNnnf0bFwG4ueqJdM(Z6h2Q9hZECTD80j4QLgrVwGjcwliqaD7AVoS2EZRhx7h0bZpZR9djymQfyI1cVAVS2zpaarcfyTSxlk5fCT9CiyhRLWdEE1c9AVoSwz68hLyp)J1(bDW8t9Seb8WaYplAGwtXHGDuBKFyOamQ1uT0aTMkaCuNnTr(HHkqkg6ZA)LCTKulloy6koeSJA6bppfkjkaouFqkS2EuT0aTMYiWj6cuNnnf0bvuSK65XI)1s67EexwzYR3Nf6m9abFe(zjc4HbKFwG5PcgeY(PNgC8xfifd9zTMTwjOwIiQwqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)R1S1kNNfloy6ploeSJA6bpV39iUSsWR3Nf6m9abFe(zXIdM(ZIdb7OMMJGTXNfiofb04GP)S65Xh3FwlH5iyBSw(Q96WArhS2SvBp)J1(1HETbG7q3U2RdRTNdb7yTekZbv69RDG2OdYr)NLiGhgq(zrd0AkoeSJAJ8ddfGrTMQLgO1uCiyh1g5hgQaPyOpR93ATfG1AQ2aWXwg2OIdb7Og6nOdV(k0z6bc(UhXLvM969zHotpqWhHFwS4GP)S4qWoQP5iyB8zbItranoy6pREE8X9N1syoc2gRLVAVoSw0bRnB1EDyTY05pw7h0bZVA)6qV2aWDOBx71H12ZHGDSwcL5Gk9(1oqB0b5O)ZseWddi)SObAnva4OoBAJ8ddfGrTMQLgO1uCiyh1g5hgkW8ZR1uT0aTMkaCuNnTr(HHkqkg6ZA)LCT2cWAnvBa4yldBuXHGDud9g0HxFf6m9abF3J4Y(dE9(SqNPhi4JWplrhd9NLSplKJrFTOJHUg2Ew0aTMsmqoe88GUTw0XUJdfy(5MiHgO1uCiyh1g5hgkadIiIKFE8a9tLsXWi)WabnrcnqRPcah1ztBKFyOamiIirMdW8ZvO0uWhmDvGmyFsjL0NLiGhgq(zbI0aTM6sarNoB6Rd1uSnubyuRPApEG(P4qWoQrrxQqNPhiyTMQLKAPbAnfiYxhDgoQaZpVwIiQwwCqPOgDKcIZAjxRS1sATMQfePbAn1LaIoD20xhQPyBOkqkg6ZAnBTS4GPR4qWoQPGZjCGtfkjkaouFqk8zXIdM(ZIdb7OMcoNWboF3J4YkZF9(SqNPhi4JWplrapmG8ZIgO1uIbYHGNh0TvZJf)RLCT0aTMsmqoe88GUTIILuppw8Vwt1ksPOZ(PKI(11pEwS4GP)S4qWoQPGZjCGZ39iUS9KxVpl0z6bc(i8ZIfhm9Nfhc2rnfCoHdC(SeDm0FwY(Seb8WaYplAGwtjgihcEEq3wfilUAnvRiZby(5koeSJAJ8ddvGum0N1AQwsQLgO1ubGJ6SPnYpmuag1ser1sd0AkoeSJAJ8ddfGrTK(UhXLRCE9(SqNPhi4JWplrapmG8ZIgO1uCiyh1IooSr18yX)A)LCTs5aY0duD5rPPyj1IooSX5ZIfhm9Nfhc2rDg0V7rC5k7R3Nf6m9abFe(zjc4HbKFw0aTMkaCuNnTr(HHcWOwIiQwk2zLH4Q1S1kRe8SyXbt)zXHGDutp459UhXLRCF9(SqNPhi4JWplwCW0FwO0uWhm9Nf0pmcaJtdBplk2zLH4mlzzUe8SG(HrayCAiffcc5dFwY(Seb8WaYplAGwtfaoQZM2i)WqbMFETMQLgO1uCiyh1g5hgkW8ZF3J4YvcF9(SyXbt)zXHGDutZrW24ZcDMEGGpc)U39SAWzh0T1Pb6y869rCzF9(SqNPhi4JWplwCW0FwO0uWhm9Nfiofb04GP)Siu7qV2aWDOBxlcVomQ96WATSQnJA7LqT2bAJoihqCAETFyTFSF1EzTYusZAPXwgyTxhwBV51JLyp)J1(bDW8tvBp0eRfE1YZANz61YZALPZFS2oEwBd6WzhcwBce1(HeifRDAG(vBce1k64WgNplrapmG8ZIKAdahBzyJQdPmYGh6pomuOZ0deSwIiQwsQnaCSLHnQMqJU01Zldkf6m9abR1uT)SwPCaz6bQmc0aym0O0SwY1kBTKwlP1AQwsQLgO1ubGJ6SPnYpmuG5NxlrevRrGs12cqLSkoeSJAAoc2gRL0AnvRiZby(5QaWrD20g5hgQaPyOpF3J4Y917ZcDMEGGpc)SyXbt)zHstbFW0FwG4ueqJdM(Z6h2Q9djqkwBd6WzhcwBce1kYCaMFETFqhm)M1YoyTtd0VAtGOwrhh2408AncygWdsOaRvMsAwBkfJArPy0)6GUDT4yIplrapmG8Z64b6NkaCuNnTr(HHcDMEGG1AQwrMdW8ZvbGJ6SPnYpmubsXqFwRPAfzoaZpxXHGDuBKFyOcKIH(Swt1sd0AkoeSJAJ8ddfy(51AQwAGwtfaoQZM2i)WqbMFETMQ1iqPABbOswfhc2rnnhbBJV7rCj817ZcDMEGGpc)Seb8WaYpRaWXwg2OceofqJb05OVwKuuSdQqNPhiyTMQLgO1uGWPaAmGoh91IKIIDqDlY5PamEwS4GP)SAWa10dEEV7rCzYR3Nf6m9abFe(zjc4HbKFwbGJTmSrLDaNJ(AOakgOcDMEGG1AQwk2zLH4Q1S12tKGNfloy6pRwKZt7Pu(DpIlbVEFwOZ0de8r4Nfloy6ploeSJAk4Cch48zj6yO)SK9zjc4HbKFwbGJTmSrfhc2rn0BqhE9vOZ0deSwt1sd0AkoeSJ6ooOsVVAES4FT)wlnqRP4qWoQ74Gk9(kkws98yX)Anvlj1ssT0aTMIdb7O2i)WqbMFETMQvK5am)Cfhc2rTr(HHkqgSFTKwlrevlisd0AQlbeD6SPVoutX2qfGrTK(UhXLzVEFwOZ0de8r4NLiGhgq(zfao2YWgvtOrx665LbLcDMEGGplwCW0FwbGJ6SPnYpmE3J4)GxVpl0z6bc(i8ZseWddi)SezoaZpxfaoQZM2i)Wqfid2)zXIdM(ZIdb7Ood639iUm)17ZcDMEGGpc)Seb8WaYplrMdW8ZvbGJ6SPnYpmubYG9R1uT0aTMIdb7Ow0XHnQMhl(x7V1sd0AkoeSJArhh2OIILuppw8)zXIdM(ZIdb7OMEWZ7DpI3tE9(SqNPhi4JWplrapmG8Z6N1gao2YWgvhszKbp0FCyOqNPhiyTeruTI0bbGNYg2oD20xhQhqrNcDMEGGplwCW0FwGiFD0z447Eexw5869zXIdM(ZkaCuNnTr(HXZcDMEGGpc)UhXLv2xVpl0z6bc(i8ZIfhm9Nfhc2rnfCoHdC(SaXPiGghm9N1pSv7hsqG1YxTuSK1opw8FwB2QLqiKAzhS2pS2owk6eC1cmrWA7XzV12hpZRfyI1Y1opw8V2lR1iqPOF1sb4IoOBxlGpW5S2aWDOBx71H1sOmhuP3V2bAJoih9FwIaEya5NfnqRPedKdbppOBRcKfxTMQLgO1uIbYHGNh0TvZJf)RLCT0aTMsmqoe88GUTIILuppw8Vwt1ksPOZ(PKI(11pQ1uTImhG5NROGrKXuNn9Lbf6NkqgSFTMQ9N1kLditpqfszKFyGGAAoc2gR1uTImhG5NR4qWoQnYpmubYG9F3J4Yk3xVpl0z6bc(i8ZseWddi)S(zTbGJTmSr1HugzWd9hhgk0z6bcwRPAjP2FwBa4yldBunHgDPRNxguk0z6bcwlrevRuoGm9avgbAamgAuAwl5ALTwsFwG4ueqJdM(ZI4zqXJr)A)WAnyyuRrEW0RfyI1(bVUA75F08APbUAHxTFWXO2bpVAhPBxl6jGDxTTmQLoVUAVoSwz68hRLDWA75FS2pOdMFZAb8boN1gaUdD7AVoSwlRAZO2EjuRDG2OdYbeNplwCW0Fwg5bt)DpIlRe(69zHotpqWhHFwIaEya5NfnqRPcah1ztBKFyOaZpVwIiQwJaLQTfGkzvCiyh10CeSn(SyXbt)zbI81rNHJV7rCzLjVEFwOZ0de8r4NLiGhgq(zrd0AQaWrD20g5hgkW8ZRLiIQ1iqPABbOswfhc2rnnhbBJplwCW0Fwbdcz)0tdo()UhXLvcE9(SqNPhi4JWplrapmG8ZIgO1ubGJ6SPnYpmubsXqFw7V1ssTYSAjwTYT2EuTbGJTmSr1eA0LUEEzqPqNPhiyTK(SyXbt)zrbJiJPoB6ldk0V39iUSYSxVpl0z6bc(i8ZIfhm9Nfhc2rTr(HXZceNIaACW0FweQDOxBa4o0TR96WAjuMdQ07x7aTrhKJ(MxlWeRTN)XAPXwgyT9MxpU2lRfeGYOwU2gWy0V25XI)iyT0CWHn(Seb8WaYplPCaz6bQqkJ8ddeutZrW2yTMQLgO1ubGJ6SPnYpmuag1AQwsQLIDwziUA)TwsQvUsqTeRwsQvw5uBpQwrkfD2p1)(bK9AjTwsRLiIQLgO1uIbYHGNh0TvZJf)RLCT0aTMsmqoe88GUTIILuppw8VwsF3J4Y(dE9(SqNPhi4JWplrapmG8ZskhqMEGkKYi)Wab10CeSnwRPAPbAnfhc2rTOJdBunpw8VwY1sd0AkoeSJArhh2OIILuppw8Vwt1sd0AkoeSJAJ8ddfGXZIfhm9Nfhc2rnnhbBJV7rCzL5VEFwOZ0de8r4NLiGhgq(zrd0AQaWrD20g5hgkW8ZRLiIQ1iqPABbOswfhc2rnnhbBJ1ser1AeOuTTaujRkyqi7NEAWX)AjIOAncuQ2waQKvbI81rNHJplwCW0Fwxci60ztFDOMITHV7rCz7jVEFwOZ0de8r4NLiGhgq(zzeOuTTaujR6sarNoB6Rd1uSn8zXIdM(ZIdb7O2i)W4DpIlx5869zHotpqWhHFwS4GP)SmcCIUa1zttbDWNfiofb04GP)S6HMyT)y2JR9YAN9aaejuG1YETOKxW12ZHGDSwcp45vliqaD7AVoS2EZRhlXE(hR9d6G5xTa(aNZAda3HUDT9CiyhRvMs0LQA)HTA75qWowRmLOlRfoR94b6hcAETFyTc2j4QfyI1(JzpU2p41b9AVoS2EZRhlXE(hR9d6G5xTa(aNZA)WAH(HrayC1EDyT9CpUwrh7oomV2zw7hsWyu7KLI1cp1ZseWddi)S(zThpq)uCiyh1OOlvOZ0deSwt1cI0aTM6sarNoB6Rd1uSnubyuRPAbrAGwtDjGOtNn91HAk2gQcKIH(S2Fjxlj1YIdMUIdb7OMEWZtHsIcGd1hKcRThvlnqRPmcCIUa1zttbDqfflPEES4FTK(UhXLRSVEFwOZ0de8r4Nfloy6plJaNOlqD20uqh8zbItranoy6pRFyR2Fm7X12XtNGRwAe9AbMiyTGab0TR96WA7nVECTFqhm)mV2pKGXOwGjwl8Q9YAN9aaejuG1YETOKxW12ZHGDSwcp45vl0R96WALPZFuI98pw7h0bZp1ZseWddi)SObAnfhc2rTr(HHcWOwt1sd0AQaWrD20g5hgQaPyOpR9xY1ssTS4GPR4qWoQPh88uOKOa4q9bPWA7r1sd0AkJaNOlqD20uqhurXsQNhl(xlPV7rC5k3xVpl0z6bc(i8ZseWddi)SaZtfmiK9tpn44Vkqkg6ZAnBTsqTeruTGinqRPcgeY(PNgC8xlfy4yW0Wb86RMhl(xRzRvoplwCW0FwCiyh10dEEV7rC5kHVEFwOZ0de8r4Nfloy6ploeSJAAoc2gFwG4ueqJdM(ZIqfR9J9R2lRLI)J1obcS2pS2owkwl6jGDxTuSZ12YO2RdRf9dgyT98pw7h0bZpZRfLIETWwTxhgibZANhCmQ9GuyTbsXqh621METY05pQQ9hEemRn9r)APX7WO2lRLgi8AVSwcfyK1YoyTYusZAHTAda3HUDTxhwRLvTzuBVeQ1oqB0b5aIt1ZseWddi)SezoaZpxXHGDuBKFyOcKb7xRPAPyNvgIR2FRLKALjYPwIvlj1kRCQThvRiLIo7N6F)aYETKwlP1AQwAGwtXHGDul64WgvZJf)RLCT0aTMIdb7Ow0XHnQOyj1ZJf)R1uTKu7pRnaCSLHnQMqJU01Zldkf6m9abRLiIQvkhqMEGkJanagdnknRLCTYwlP1AQ2FwBa4yldBuDiLrg8q)XHHcDMEGG1AQ2FwBa4yldBuXHGDud9g0HxFf6m9abF3J4YvM869zHotpqWhHFwS4GP)S4qWoQP5iyB8zbItranoy6plcZrW2yTZUeyawRNxT0yTateSw(Q96WArhS2SvBp)J1cB1ktjnf8btVw4S2azW(1YZAbJ0Wa621k64WgN1(bhJAP4)yTWR2J)J1os3gJAVSwAGWR96IeWUR2aPyOdD7APyNFwIaEya5NfnqRP4qWoQnYpmuag1AQwAGwtXHGDuBKFyOcKIH(S2FjxRTaSwt1kYCaMFUcLMc(GPRcKIH(8DpIlxj417ZcDMEGGpc)SyXbt)zXHGDutZrW24ZceNIaACW0FweMJGTXANDjWaSwE8X9N1sJ1EDyTdEE1k45vl0R96WALPZFS2pOdMF1YZA7nVECTFWXO2aNxgyTxhwROJdBCw70a97zjc4HbKFw0aTMkaCuNnTr(HHcWOwt1sd0AkoeSJAJ8ddfy(51AQwAGwtfaoQZM2i)Wqfifd9zT)sUwBbyTMQ9N1gao2YWgvCiyh1qVbD41xHotpqW39iUCLzVEFwOZ0de8r4NLOJH(Zs2NfYXOVw0XqxdBplAGwtjgihcEEq3wl6y3XHcm)CtKqd0AkoeSJAJ8ddfGbrerYppEG(PsPyyKFyGGMiHgO1ubGJ6SPnYpmuagerKiZby(5kuAk4dMUkqgSpPKs6ZseWddi)SarAGwtDjGOtNn91HAk2gQamQ1uThpq)uCiyh1OOlvOZ0deSwt1ssT0aTMce5RJodhvG5NxlrevlloOuuJosbXzTKRv2AjTwt1cI0aTM6sarNoB6Rd1uSnufifd9zTMTwwCW0vCiyh1uW5eoWPcLefahQpif(SyXbt)zXHGDutbNt4aNV7rC5(dE9(SqNPhi4JWplwCW0FwCiyh1uW5eoW5ZceNIaACW0Fw)WwTFibbwRu0VU(H51cPOqqiF4OFTatSwcHqQ9Rd9AfSHbcw7L165v7hppSwJifZABrsvBpo79zjc4HbKFwIuk6SFkPOFD9JAnvlnqRPedKdbppOBRMhl(xl5APbAnLyGCi45bDBfflPEES4)7EexUY8xVpl0z6bc(i8ZceNIaACW0FwwhhxTatOBxlHqi12Z94A)6qV2E(hRTJN1sJOxlWebFwIaEya5NfnqRPedKdbppOBRcKfxTMQvK5am)Cfhc2rTr(HHkqkg6ZAnvlj1sd0AQaWrD20g5hgkaJAjIOAPbAnfhc2rTr(HHcWOwsFwIog6plzFwS4GP)S4qWoQPGZjCGZ39iUC7jVEFwOZ0de8r4NLiGhgq(zrd0AkoeSJArhh2OAES4FT)sUwPCaz6bQU8O0uSKArhh248zXIdM(ZIdb7Ood639iUekNxVpl0z6bc(i8ZseWddi)SObAnva4OoBAJ8ddfGrTeruTuSZkdXvRzRvwj4zXIdM(ZIdb7OMEWZ7DpIlHY(69zHotpqWhHFwS4GP)SqPPGpy6plOFyeagNg2EwuSZkdXzwYYCj4zb9dJaW40qkkeeYh(SK9zjc4HbKFw0aTMkaCuNnTr(HHcm)8AnvlnqRP4qWoQnYpmuG5N)UhXLq5(69zXIdM(ZIdb7OMMJGTXNf6m9abFe(DV7zf5Xhm9xVpIl7R3Nf6m9abFe(zXIdM(ZcLMc(GP)SaXPiGghm9Nvp0eRfLM1cB1(HeeyTJ8R20RLIDUw2bRvK5am)8zTCG1Y0jWv7L1sJ1cy8Seb8WaYplk2zLH4Q9xY1kLditpqfkn1gIRwt1ssTImhG5NRUeq0PZM(6qnfBdvbsXqFw7VKRLfhmDfknf8btxHsIcGd1hKcRLiIQvK5am)Cfhc2rTr(HHkqkg6ZA)LCTS4GPRqPPGpy6kusuaCO(GuyTeruTKu7Xd0pva4OoBAJ8ddf6m9abR1uTImhG5NRcah1ztBKFyOcKIH(S2Fjxlloy6kuAk4dMUcLefahQpifwlP1sATMQLgO1ubGJ6SPnYpmuG5NxRPAPbAnfhc2rTr(HHcm)8Anvlisd0AQlbeD6SPVoutX2qfy(51AQ2FwRrGs12cqLSQlbeD6SPVoutX2W39iUCF9(SqNPhi4JWplrapmG8ZkaCSLHnQMqJU01Zldkf6m9abR1uTImhG5NR4qWoQnYpmubsXqFw7VKRLfhmDfknf8btxHsIcGd1hKcFwS4GP)SqPPGpy6V7rCj817ZcDMEGGpc)SyXbt)zXHGDutZrW24ZceNIaACW0FweMJGTXAHTAHhbZApifw7L1cmXAV8OQLDWA)WA7yPyTxM1sXE)AfDCyJZNLiGhgq(zjYCaMFU6sarNoB6Rd1uSnufid2Vwt1ssT0aTMIdb7Ow0XHnQMhl(xRzRvkhqMEGQlpknflPw0XHnoR1uTImhG5NR4qWoQnYpmubsXqFw7VKRfLefahQpifwRPAPyNvgIRwZwRuoGm9avSHMc6qkaknf7S2qC1AQwAGwtfaoQZM2i)WqbMFETK(UhXLjVEFwOZ0de8r4NLiGhgq(zjYCaMFU6sarNoB6Rd1uSnufid2Vwt1ssT0aTMIdb7Ow0XHnQMhl(xRzRvkhqMEGQlpknflPw0XHnoR1uThpq)ubGJ6SPnYpmuOZ0deSwt1kYCaMFUkaCuNnTr(HHkqkg6ZA)LCTOKOa4q9bPWAnvRuoGm9avhKc1a(bhA2OwZwRuoGm9avxEuAkwsnio4(6wgA2OwsFwS4GP)S4qWoQP5iyB8DpIlbVEFwOZ0de8r4NLiGhgq(zjYCaMFU6sarNoB6Rd1uSnufid2Vwt1ssT0aTMIdb7Ow0XHnQMhl(xRzRvkhqMEGQlpknflPw0XHnoR1uTKu7pR94b6NkaCuNnTr(HHcDMEGG1ser1kYCaMFUkaCuNnTr(HHkqkg6ZAnBTs5aY0duD5rPPyj1G4G7RBzOJ0OwsR1uTs5aY0duDqkud4hCOzJAnBTs5aY0duD5rPPyj1G4G7RBzOzJAj9zXIdM(ZIdb7OMMJGTX39iUm717ZcDMEGGpc)Seb8WaYplqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)RLCTGinqRPcgeY(PNgC8xlfy4yW0Wb86ROyj1ZJf)R1uTKulnqRP4qWoQnYpmuG5NxlrevlnqRP4qWoQnYpmubsXqFw7VKR1wawlP1AQwsQLgO1ubGJ6SPnYpmuG5NxlrevlnqRPcah1ztBKFyOcKIH(S2FjxRTaSwsFwS4GP)S4qWoQP5iyB8DpI)dE9(SqNPhi4JWplrapmG8ZskhqMEGQEAG5PbMiOEAWX)AjIOAjPwqKgO1ubdcz)0tdo(RLcmCmyA4aE9vag1AQwqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)R93AbrAGwtfmiK9tpn44VwkWWXGPHd41xrXsQNhl(xlPplwCW0FwCiyh10dEEV7rCz(R3Nf6m9abFe(zjc4HbKFw0aTMYiWj6cuNnnf0bvag1AQwqKgO1uxci60ztFDOMITHkaJAnvlisd0AQlbeD6SPVoutX2qvGum0N1(l5AzXbtxXHGDutp45PqjrbWH6dsHplwCW0FwCiyh10dEEV7r8EYR3Nf6m9abFe(zj6yO)SK9zHCm6RfDm01W2ZIgO1uIbYHGNh0T1Io2DCOaZp3ej0aTMIdb7O2i)WqbyqerK8ZJhOFQukgg5hgiOjsObAnva4OoBAJ8ddfGbrejYCaMFUcLMc(GPRcKb7tkPK(Seb8WaYplqKgO1uxci60ztFDOMITHkaJAnv7Xd0pfhc2rnk6sf6m9abR1uTKulnqRPar(6OZWrfy(51ser1YIdkf1OJuqCwl5ALTwsR1uTKulisd0AQlbeD6SPVoutX2qvGum0N1A2AzXbtxXHGDutbNt4aNkusuaCO(GuyTeruTImhG5NRmcCIUa1zttbDqvGum0N1ser1ksPOZ(P(3pGSxlPplwCW0FwCiyh1uW5eoW57Eexw5869zHotpqWhHFwS4GP)S4qWoQPGZjCGZNfiofb04GP)SiK0NauyTxhwlkPb7GiyTg5H(b5rT0aTwT8KnQ9YA98QDKtSwJ8q)G8OwJifZNLiGhgq(zrd0AkXa5qWZd62QazXvRPAPbAnfkPb7GiO2ip0pipuagV7rCzL917ZcDMEGGpc)SyXbt)zXHGDutbNt4aNplrhd9NLSplrapmG8ZIgO1uIbYHGNh0TvbYIRwt1ssT0aTMIdb7O2i)WqbyulrevlnqRPcah1ztBKFyOamQLiIQfePbAn1LaIoD20xhQPyBOkqkg6ZAnBTS4GPR4qWoQPGZjCGtfkjkaouFqkSwsF3J4Yk3xVpl0z6bc(i8ZIfhm9Nfhc2rnfCoHdC(SeDm0FwY(Seb8WaYplAGwtjgihcEEq3wfilUAnvlnqRPedKdbppOBRMhl(xl5APbAnLyGCi45bDBfflPEES4)7Eexwj817ZcDMEGGpc)SaXPiGghm9Nvpp(4(ZAVOFTxwln7)RLqiKABzuRiZby(51(bDW8BwlnWvliaLrTxhsvlSv71H9jiWAz6e4Q9YArjnGb(Seb8WaYplAGwtjgihcEEq3wfilUAnvlnqRPedKdbppOBRcKIH(S2Fjxlj1ssT0aTMsmqoe88GUTAES4FT9OAzXbtxXHGDutbNt4aNkusuaCO(GuyTKwlXQ1waQOyjRL0NLOJH(Zs2Nfloy6ploeSJAk4Cch48DpIlRm517ZcDMEGGpc)Seb8WaYplsQnWwGZoMEG1ser1(ZApO4p0TRL0AnvlnqRP4qWoQfDCyJQ5XI)1sUwAGwtXHGDul64WgvuSK65XI)1AQwAGwtXHGDuBKFyOaZpVwt1cI0aTM6sarNoB6Rd1uSnubMF(ZIfhm9NLJxhg6dPmW59UhXLvcE9(SqNPhi4JWplrapmG8ZIgO1uCiyh1IooSr18yX)A)LCTs5aY0duD5rPPyj1IooSX5ZIfhm9Nfhc2rDg0V7rCzLzVEFwOZ0de8r4NLiGhgq(zjLditpqvcCtiiQZMwK5am)8zTMQLIDwziUA)LCT9ej4zXIdM(ZAcyGHNs539iUS)GxVpl0z6bc(i8ZseWddi)SObAnvamqD20xxG4ubyuRPAPbAnfhc2rTOJdBunpw8VwZwRe(SyXbt)zXHGDutp459UhXLvM)69zHotpqWhHFwS4GP)S4qWoQP5iyB8zbItranoy6pRE4aqzuROJdBCwlSv7hwBJhJAPXr(v71H1ksFIHuSwk25AVUaND5aSw2bRfLMc(GPxlCw78GJrTPxRiZby(5plrapmG8Z6N1gao2YWgvtOrx665LbLcDMEGG1AQwPCaz6bQsGBcbrD20ImhG5NpR1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xRPApEG(P4qWoQZGwHotpqWAnvRiZby(5koeSJ6mOvbsXqFw7VKR1wawRPAPyNvgIR2FjxBpro1AQwrMdW8ZvO0uWhmDvGum0NV7rCz7jVEFwOZ0de8r4NLiGhgq(zfao2YWgvtOrx665LbLcDMEGG1AQwPCaz6bQsGBcbrD20ImhG5NpR1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xRPApEG(P4qWoQZGwHotpqWAnvRiZby(5koeSJ6mOvbsXqFw7VKR1wawRPAPyNvgIR2FjxBpro1AQwrMdW8ZvO0uWhmDvGum0N1(BTsOCEwS4GP)S4qWoQP5iyB8DpIlx5869zHotpqWhHFwS4GP)S4qWoQP5iyB8zbItranoy6pRE4aqzuROJdBCwlSvBg01cN1gid2)zjc4HbKFws5aY0duLa3ecI6SPfzoaZpFwRPAPbAnfhc2rTOJdBunpw8VwY1sd0AkoeSJArhh2OIILuppw8Vwt1E8a9tXHGDuNbTcDMEGG1AQwrMdW8ZvCiyh1zqRcKIH(S2FjxRTaSwt1sXoRmexT)sU2EICQ1uTImhG5NRqPPGpy6QaPyOpF3J4Yv2xVpl0z6bc(i8ZIfhm9Nfhc2rnnhbBJplqCkcOXbt)z1ZHGDSwcZrW2yTZUeyawRn6yWJr)APXAVoS2bpVAf88QnB1EDyT98pw7h0bZVNLiGhgq(zrd0AkoeSJAJ8ddfGrTMQLgO1uCiyh1g5hgQaPyOpR9xY1AlaR1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xRPAjPwrMdW8ZvO0uWhmDvGum0N1ser1gao2YWgvCiyh1qVbD41xHotpqWAj9DpIlx5(69zHotpqWhHFwS4GP)S4qWoQP5iyB8zbItranoy6pREoeSJ1syoc2gRD2LadWATrhdEm6xlnw71H1o45vRGNxTzR2RdRvMo)XA)Goy(9Seb8WaYplAGwtfaoQZM2i)WqbyuRPAPbAnfhc2rTr(HHcm)8AnvlnqRPcah1ztBKFyOcKIH(S2FjxRTaSwt1sd0AkoeSJArhh2OAES4FTKRLgO1uCiyh1IooSrfflPEES4FTMQLKAfzoaZpxHstbFW0vbsXqFwlrevBa4yldBuXHGDud9g0HxFf6m9abRL039iUCLWxVpl0z6bc(i8ZIfhm9Nfhc2rnnhbBJplqCkcOXbt)z1ZHGDSwcZrW2yTZUeyawlnw71H1o45vRGNxTzR2RdRT386X1(bDW8RwyRw4vlCwRNxTateS2p41vRmD(J1MrT98p(Seb8WaYplAGwtXHGDuBKFyOaZpVwt1sd0AQaWrD20g5hgkW8ZR1uTGinqRPUeq0PZM(6qnfBdvag1AQwqKgO1uxci60ztFDOMITHQaPyOpR9xY1AlaR1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl()UhXLRm517ZcDMEGGpc)SyXbt)zXHGDutZrW24ZceNIaACW0FweQDOx71H1ECyJxTWzTqVwusuaCyTb72yTSdw71HbwlCwlvgyTxh71Mowl6ivFZRfyI1sZrW2yT8S2zMET8S2(jqTDSuSw0ta7UAfDCyJZAVS2o4vlpg1IosbXzTWwTxhwBphc2XAjCsrZbif6xTd0gDqo6xlCwl2daGggi4ZseWddi)SKYbKPhOcPmYpmqqnnhbBJ1AQwAGwtXHGDul64WgvZJf)R1SKRLKAzXbLIA0rkioRTNQwzRL0AnvlloOuuJosbXzTMTwzR1uT0aTMce5RJodhvG5N)UhXLRe869zHotpqWhHFwIaEya5NLuoGm9aviLr(HbcQP5iyBSwt1sd0AkoeSJArhh2OAES4FT)wlnqRP4qWoQfDCyJkkws98yX)AnvlloOuuJosbXzTMTwzR1uT0aTMce5RJodhvG5N)SyXbt)zXHGDuJsAmYjm939iUCLzVEFwS4GP)S4qWoQPh88EwOZ0de8r439iUC)bVEFwOZ0de8r4NLiGhgq(zjLditpqvcCtiiQZMwK5am)85ZIfhm9Nfknf8bt)DpIlxz(R3Nfloy6ploeSJAAoc2gFwOZ0de8r439UNLiZby(5ZxVpIl7R3Nf6m9abFe(zXIdM(ZQf580EkLFwG4ueqJdM(Z6hdygWdsOaRfycD7ATd4C0VwOakgyTFWRRw2qvBp0eRfE1(bVUAV8OQnVom(Gtu9Seb8WaYpRaWXwg2OYoGZrFnuafduHotpqWAnvRiZby(5koeSJAJ8ddvGum0N1A2ALq5uRPAfzoaZpxDjGOtNn91HAk2gQcKb7xRPAjPwAGwtXHGDul64WgvZJf)R9xY1kLditpq1LhLMILul64WgN1AQwsQLKApEG(Pcah1ztBKFyOqNPhiyTMQvK5am)Cva4OoBAJ8ddvGum0N1(l5ATfG1AQwrMdW8ZvCiyh1g5hgQaPyOpR1S1kLditpq1LhLMILudIdUVULHMnQL0AjIOAjP2Fw7Xd0pva4OoBAJ8ddf6m9abR1uTImhG5NR4qWoQnYpmubsXqFwRzRvkhqMEGQlpknflPgehCFDldnBulP1ser1kYCaMFUIdb7O2i)Wqfifd9zT)sUwBbyTKwlPV7rC5(69zHotpqWhHFwIaEya5Nva4yldBuzhW5OVgkGIbQqNPhiyTMQvK5am)Cfhc2rTr(HHkqgSFTMQLKA)zThpq)uOpG2Dh6iOcDMEGG1ser1ssThpq)uOpG2Dh6iOcDMEGG1AQwk2zLH4Q1SKR9hiNAjTwsR1uTKulj1kYCaMFU6sarNoB6Rd1uSnufifd9zTMTwzLtTMQLgO1uCiyh1IooSr18yX)AjxlnqRP4qWoQfDCyJkkws98yX)AjTwIiQwsQvK5am)C1LaIoD20xhQPyBOkqkg6ZAjxRCQ1uT0aTMIdb7Ow0XHnQMhl(xl5ALtTKwlP1AQwAGwtfaoQZM2i)WqbMFETMQLIDwziUAnl5ALYbKPhOIn0uqhsbqPPyN1gI7zXIdM(ZQf580EkLF3J4s4R3Nf6m9abFe(zjc4HbKFwbGJTmSrfiCkGgdOZrFTiPOyhuHotpqWAnvRiZby(5kAGwtdcNcOXa6C0xlskk2bvbYG9R1uT0aTMceofqJb05OVwKuuSdQBropfy(51AQwsQLgO1uCiyh1g5hgkW8ZR1uT0aTMkaCuNnTr(HHcm)8Anvlisd0AQlbeD6SPVoutX2qfy(51sATMQvK5am)C1LaIoD20xhQPyBOkqkg6ZAjxRCQ1uTKulnqRP4qWoQfDCyJQ5XI)1(l5ALYbKPhO6YJstXsQfDCyJZAnvlj1ssThpq)ubGJ6SPnYpmuOZ0deSwt1kYCaMFUkaCuNnTr(HHkqkg6ZA)LCT2cWAnvRiZby(5koeSJAJ8ddvGum0N1A2ALYbKPhO6YJstXsQbXb3x3YqZg1sATeruTKu7pR94b6NkaCuNnTr(HHcDMEGG1AQwrMdW8ZvCiyh1g5hgQaPyOpR1S1kLditpq1LhLMILudIdUVULHMnQL0AjIOAfzoaZpxXHGDuBKFyOcKIH(S2FjxRTaSwsRL0Nfloy6pRwKZJoh37EexM869zHotpqWhHFwIaEya5Nva4yldBubcNcOXa6C0xlskk2bvOZ0deSwt1kYCaMFUIgO10GWPaAmGoh91IKIIDqvGmy)AnvlnqRPaHtb0yaDo6Rfjff7G6gmqfy(51AQwJaLQTfGkzvTiNhDoUNfloy6pRgmqn9GN37EexcE9(SqNPhi4JWplwCW0FwuWiYyQZM(YGc97zbItranoy6pRFKHrT94S3A)GxxT98pwlSvl8iywRiPGUDTag1oZ0v1(dB1cVA)GJrT0yTateS2p41vBV51JnVwbpVAHxTZb0U7g9RLgBzGplrapmG8ZsK5am)C1LaIoD20xhQPyBOkqkg6ZA)TwPCaz6bQOYtBeOarq9LhLMUFTeruTKuRuoGm9avhKc1a(bhA2OwZwRuoGm9avu5PPyj1G4G7RBzOzJAnvRiZby(5QlbeD6SPVoutX2qvGum0N1A2ALYbKPhOIkpnflPgehCFDld9LhvTK(UhXLzVEFwOZ0de8r4NLiGhgq(zjYCaMFUIdb7O2i)Wqfid2Vwt1ssT)S2JhOFk0hq7UdDeuHotpqWAjIOAjP2JhOFk0hq7UdDeuHotpqWAnvlf7SYqC1AwY1(dKtTKwlP1AQwsQLKAfzoaZpxDjGOtNn91HAk2gQcKIH(SwZwRuoGm9avSHMILudIdUVULH(YJQwt1sd0AkoeSJArhh2OAES4FTKRLgO1uCiyh1IooSrfflPEES4FTKwlrevlj1kYCaMFU6sarNoB6Rd1uSnufifd9zTKRvo1AQwAGwtXHGDul64WgvZJf)RLCTYPwsRL0AnvlnqRPcah1ztBKFyOaZpVwt1sXoRmexTMLCTs5aY0duXgAkOdPaO0uSZAdX9SyXbt)zrbJiJPoB6ldk0V39i(p417ZcDMEGGpc)SyXbt)zbI81rNHJplqCkcOXbt)z1ZJpU)SwGjwliYxhDgow7h86QLnu1(dB1E5rvlCwBGmy)A5zTF4yyETu8FS2jqG1EzTcEE1cVAPXwgyTxEuQNLiGhgq(zjYCaMFU6sarNoB6Rd1uSnufid2Vwt1sd0AkoeSJArhh2OAES4FT)sUwPCaz6bQU8O0uSKArhh24Swt1kYCaMFUIdb7O2i)Wqfifd9zT)sUwBb47EexM)69zHotpqWhHFwIaEya5NLiZby(5koeSJAJ8ddvGmy)Anvlj1(ZApEG(PqFaT7o0rqf6m9abRLiIQLKApEG(PqFaT7o0rqf6m9abR1uTuSZkdXvRzjx7pqo1sATKwRPAjPwsQvK5am)C1LaIoD20xhQPyBOkqkg6ZAnBTYkNAnvlnqRP4qWoQfDCyJQ5XI)1sUwAGwtXHGDul64WgvuSK65XI)1sATeruTKuRiZby(5QlbeD6SPVoutX2qvGmy)AnvlnqRP4qWoQfDCyJQ5XI)1sUw5ulP1sATMQLgO1ubGJ6SPnYpmuG5NxRPAPyNvgIRwZsUwPCaz6bQydnf0HuauAk2zTH4EwS4GP)Sar(6OZWX39iEp517ZcDMEGGpc)SyXbt)zfmiK9tpn44)ZceNIaACW0Fw9qtS2Pbh)Rf2Q9YJQw2bRLnQLdS20Rvawl7G1(LobxT0yTag12YO2r62yu71XETxhwlflzTG4G7BETu8FOBx7eiWA)WA7yPyT8v7a55v79L1YHGDSwrhh24Sw2bR964R2lpQA)4PtWvBpnW8QfyIGQNLiGhgq(zjYCaMFU6sarNoB6Rd1uSnufifd9zTMTwPCaz6bQIPMILudIdUVULH(YJQwt1kYCaMFUIdb7O2i)Wqfifd9zTMTwPCaz6bQIPMILudIdUVULHMnQ1uTKu7Xd0pva4OoBAJ8ddf6m9abR1uTKuRiZby(5QaWrD20g5hgQaPyOpR93ArjrbWH6dsH1ser1kYCaMFUkaCuNnTr(HHkqkg6ZAnBTs5aY0duftnflPgehCFDldDKg1sATeruT)S2JhOFQaWrD20g5hgk0z6bcwlP1AQwAGwtXHGDul64WgvZJf)R1S1k3Anvlisd0AQlbeD6SPVoutX2qfy(51AQwAGwtfaoQZM2i)WqbMFETMQLgO1uCiyh1g5hgkW8ZF3J4YkNxVpl0z6bc(i8ZIfhm9NvWGq2p90GJ)plqCkcOXbt)z1dnXANgC8V2p41vlBu7xh61AKZjKEGQA)HTAV8OQfoRnqgSFT8S2pCmmVwk(pw7eiWAVSwbpVAHxT0yldS2lpk1ZseWddi)SezoaZpxDjGOtNn91HAk2gQcKIH(S2FRfLefahQpifwRPAPbAnfhc2rTOJdBunpw8V2FjxRuoGm9avxEuAkwsTOJdBCwRPAfzoaZpxXHGDuBKFyOcKIH(S2FRLKArjrbWH6dsH1sSAzXbtxDjGOtNn91HAk2gQqjrbWH6dsH1s67EexwzF9(SqNPhi4JWplrapmG8ZsK5am)Cfhc2rTr(HHkqkg6ZA)TwusuaCO(GuyTMQLKAjP2Fw7Xd0pf6dOD3HocQqNPhiyTeruTKu7Xd0pf6dOD3HocQqNPhiyTMQLIDwziUAnl5A)bYPwsRL0Anvlj1ssTImhG5NRUeq0PZM(6qnfBdvbsXqFwRzRvkhqMEGk2qtXsQbXb3x3YqF5rvRPAPbAnfhc2rTOJdBunpw8VwY1sd0AkoeSJArhh2OIILuppw8VwsRLiIQLKAfzoaZpxDjGOtNn91HAk2gQcKIH(SwY1kNAnvlnqRP4qWoQfDCyJQ5XI)1sUw5ulP1sATMQLgO1ubGJ6SPnYpmuG5NxRPAPyNvgIRwZsUwPCaz6bQydnf0HuauAk2zTH4QL0Nfloy6pRGbHSF6Pbh)F3J4Yk3xVpl0z6bc(i8ZIfhm9N1LaIoD20xhQPyB4ZceNIaACW0Fw9qtS2lpQA)GxxTSrTWwTWJGzTFWRd61EDyTuSK1cIdUVQ2FyRwppZRfyI1(bVUAJ0OwyR2RdR94b6xTWzTh)hDZRLDWAHhbZA)Gxh0R96WAPyjRfehCF1ZseWddi)SObAnfhc2rTOJdBunpw8V2FjxRuoGm9avxEuAkwsTOJdBCwRPAfzoaZpxXHGDuBKFyOcKIH(S2FjxlkjkaouFqkSwt1sXoRmexTMTwPCaz6bQydnf0HuauAk2zTH4Q1uT0aTMkaCuNnTr(HHcm)839iUSs4R3Nf6m9abFe(zjc4HbKFw0aTMIdb7Ow0XHnQMhl(x7VKRvkhqMEGQlpknflPw0XHnoR1uThpq)ubGJ6SPnYpmuOZ0deSwt1kYCaMFUkaCuNnTr(HHkqkg6ZA)LCTOKOa4q9bPWAnvRuoGm9avhKc1a(bhA2OwZwRuoGm9avxEuAkwsnio4(6wgA24zXIdM(Z6sarNoB6Rd1uSn8DpIlRm517ZcDMEGGpc)Seb8WaYplAGwtXHGDul64WgvZJf)R9xY1kLditpq1LhLMILul64WgN1AQwsQ9N1E8a9tfaoQZM2i)WqHotpqWAjIOAfzoaZpxfaoQZM2i)Wqfifd9zTMTwPCaz6bQU8O0uSKAqCW91Tm0rAulP1AQwPCaz6bQoifQb8do0SrTMTwPCaz6bQU8O0uSKAqCW91Tm0SXZIfhm9N1LaIoD20xhQPyB47Eexwj417ZcDMEGGpc)SyXbt)zXHGDuBKFy8SaXPiGghm9Nvp0eRLnQf2Q9YJQw4S20Rvawl7G1(LobxT0yTag12YO2r62yu71XETxhwlflzTG4G7BETu8FOBx7eiWAVo(Q9dRTJLI1IEcy3vlf7CTSdw71XxTxhgyTWzTEE1YJazW(1Y1gaowB2Q1i)WOwW8ZvplrapmG8ZsK5am)C1LaIoD20xhQPyBOkqkg6ZAnBTs5aY0duXgAkwsnio4(6wg6lpQAnvlj1(ZAfPu0z)usr)66h1ser1kYCaMFUIcgrgtD20xguOFQaPyOpR1S1kLditpqfBOPyj1G4G7RBzOPYRwsR1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xRPAPbAnva4OoBAJ8ddfy(51AQwk2zLH4Q1SKRvkhqMEGk2qtbDifaLMIDwBiU39iUSYSxVpl0z6bc(i8ZIfhm9Nva4OoBAJ8dJNfiofb04GP)S6HMyTrAulSv7LhvTWzTPxRaSw2bR9lDcUAPXAbmQTLrTJ0TXO2RJ9AVoSwkwYAbXb338AP4)q3U2jqG1EDyG1cNobxT8iqgSFTCTbGJ1cMFETSdw71XxTSrTFPtWvlnkskSwwkdhm9aRfeiGUDTbGJQNLiGhgq(zrd0AkoeSJAJ8ddfy(51AQwsQvK5am)C1LaIoD20xhQPyBOkqkg6ZAnBTs5aY0dufPHMILudIdUVULH(YJQwIiQwrMdW8ZvCiyh1g5hgQaPyOpR9xY1kLditpq1LhLMILudIdUVULHMnQL0AnvlnqRP4qWoQfDCyJQ5XI)1sUwAGwtXHGDul64WgvuSK65XI)1AQwrMdW8ZvCiyh1g5hgQaPyOpR1S1kRCF3J4Y(dE9(SqNPhi4JWplrapmG8ZskhqMEGQe4MqquNnTiZby(5ZNfloy6pRzhSDq3wBKFy8UhXLvM)69zHotpqWhHFwS4GP)SmcCIUa1zttbDWNfiofb04GP)S6HMyTgjvTxw7ShaGiHcSw2RfL8cUwMUwOx71H16OKxTImhG5Nx7h0bZpZRfWh4Cw7)(bK9AVo0Rn9r)AbbcOBxlhc2XAnYpmQfeaR9YA7YVAPyNRTdWTJ(1gmiK9R2Pbh)RfoFwIaEya5N1Xd0pva4OoBAJ8ddf6m9abR1uT0aTMIdb7O2i)WqbyuRPAPbAnva4OoBAJ8ddvGum0N1(BT2cqffl57Eex2EYR3Nf6m9abFe(zjc4HbKFwGinqRPUeq0PZM(6qnfBdvag1AQwqKgO1uxci60ztFDOMITHQaPyOpR93AzXbtxXHGDutbNt4aNkusuaCO(GuyTMQ9N1ksPOZ(P(3pGS)SyXbt)zze4eDbQZMMc6GV7rC5kNxVpl0z6bc(i8ZseWddi)SObAnva4OoBAJ8ddfGrTMQLgO1ubGJ6SPnYpmubsXqFw7V1AlavuSK1AQwrMdW8ZvO0uWhmDvGmy)AnvRiZby(5QlbeD6SPVoutX2qvGum0N1AQ2FwRiLIo7N6F)aY(ZIfhm9NLrGt0fOoBAkOd(U39SaXgdmUxVpIl7R3Nfloy6plrc4hgtdCmEwOZ0de8r439iUCF9(SqNPhi4JWplrapmG8ZIKApEG(PqFaT7o0rqf6m9abR1uTuSZkdXv7VKRvMlNAnvlf7SYqC1AwY1kZKGAjTwIiQwsQ9N1E8a9tH(aA3DOJGk0z6bcwRPAPyNvgIR2FjxRmxcQL0Nfloy6plk2zTns9UhXLWxVpl0z6bc(i8ZseWddi)SObAnfhc2rTr(HHcW4zXIdM(ZYipy6V7rCzYR3Nf6m9abFe(zjc4HbKFwbGJTmSr1HugzWd9hhgk0z6bcwRPAPbAnfkzhdmpy6kaJAnvlj1kYCaMFUIdb7O2i)Wqfid2VwIiQw6CoR1uTnOD3PdKIH(S2FjxRmro1s6ZIfhm9N1bPq9hhgV7rCj417ZcDMEGGpc)Seb8WaYplAGwtXHGDuBKFyOaZpVwt1sd0AQaWrD20g5hgkW8ZR1uTGinqRPUeq0PZM(6qnfBdvG5N)SyXbt)znG2D3u3tdaAtH(9UhXLzVEFwOZ0de8r4NLiGhgq(zrd0AkoeSJAJ8ddfy(51AQwAGwtfaoQZM2i)WqbMFETMQfePbAn1LaIoD20xhQPyBOcm)8Nfloy6plA2wNn9fqX)57Ee)h869zHotpqWhHFwIaEya5NfnqRP4qWoQnYpmuagplwCW0Fw0ymX4p0TF3J4Y8xVpl0z6bc(i8ZseWddi)SObAnfhc2rTr(HHcW4zXIdM(ZIEKjOUbe9F3J49KxVpl0z6bc(i8ZseWddi)SObAnfhc2rTr(HHcW4zXIdM(ZQbdKEKj47Eexw5869zHotpqWhHFwIaEya5NfnqRP4qWoQnYpmuagplwCW0FwSlW5f8ql4X4DpIlRSVEFwOZ0de8r4NLiGhgq(zrd0AkoeSJAJ8ddfGXZIfhm9NfWe1WdPMV7rCzL7R3Nf6m9abFe(zXIdM(ZYEWGq(YyQPzqB8zjc4HbKFw0aTMIdb7O2i)WqbyulrevRiZby(5koeSJAJ8ddvGum0N1AwY1kbsqTMQfePbAn1LaIoD20xhQPyBOcW4zHTgkoTZu4ZYEWGq(YyQPzqB8DpIlRe(69zHotpqWhHFwS4GP)SqkJ(bYdDgGo7c8zjc4HbKFwImhG5NR4qWoQnYpmubsXqFw7VKRLKALvcRLy1(dQThvRuoGm9avSHoDnWeRL0AnvRiZby(5QlbeD6SPVoutX2qvGum0N1(l5AjPwzLWAjwT)GA7r1kLditpqfBOtxdmXAj9z5mf(SqkJ(bYdDgGo7c8DpIlRm517ZcDMEGGpc)SyXbt)zbgid2GbQLIZjoEwIaEya5NLiZby(5koeSJAJ8ddvGum0N1AwY1kx5ulrev7pRvkhqMEGk2qNUgyI1sUwzRLiIQLKApifwl5ALtTMQvkhqMEGQgC2bDBDAGog1sUwzR1uTbGJTmSr1eA0LUEEzqPqNPhiyTK(SCMcFwGbYGnyGAP4CIJ39iUSsWR3Nf6m9abFe(zXIdM(ZAMadn02HhgplrapmG8ZsK5am)Cfhc2rTr(HHkqkg6ZAnl5ALq5ulrev7pRvkhqMEGk2qNUgyI1sUwzFwotHpRzcm0qBhEy8UhXLvM969zHotpqWhHFwS4GP)SSh9n60ztZZjKco4dM(ZseWddi)SezoaZpxXHGDuBKFyOcKIH(SwZsUw5kNAjIOA)zTs5aY0duXg601atSwY1kBTeruTKu7bPWAjxRCQ1uTs5aY0du1GZoOBRtd0XOwY1kBTMQnaCSLHnQMqJU01Zldkf6m9abRL0NLZu4ZYE03OtNnnpNqk4Gpy6V7rCz)bVEFwOZ0de8r4Nfloy6plkwW0bQNDiEAkGju8Seb8WaYplrMdW8ZvCiyh1g5hgQaPyOpR9xY1kb1AQwsQ9N1kLditpqvdo7GUTonqhJAjxRS1ser1EqkSwZwRekNAj9z5mf(SOybthOE2H4PPaMqX7Eexwz(R3Nf6m9abFe(zXIdM(ZIIfmDG6zhINMcycfplrapmG8ZsK5am)Cfhc2rTr(HHkqkg6ZA)LCTsqTMQvkhqMEGQgC2bDBDAGog1sUwzR1uT0aTMkaCuNnTr(HHcWOwt1sd0AQaWrD20g5hgQaPyOpR9xY1ssTYkNA7PQvcQThvBa4yldBunHgDPRNxguk0z6bcwlP1AQ2dsH1(BTsOCEwotHplkwW0bQNDiEAkGju8UhXLTN869zHotpqWhHFwS4GP)Se8yOzXbtxpGZ7znGZt7mf(Se8qam4dM(8DpIlx5869zHotpqWhHFwIaEya5NfloOuuJosbXzTMLCTs5aY0duXjQpoSXtlsa)EwZlGI7rCzFwS4GP)Se8yOzXbtxpGZ7znGZt7mf(S4eF3J4Yv2xVpl0z6bc(i8ZseWddi)SePu0z)u)7hq2R1uTbGJTmSrfhc2rn0BqhE9vOZ0de8zXIdM(ZsWJHMfhmD9aoVN1aopTZu4ZQJdQ07)UhXLRCF9(SqNPhi4JWplrapmG8ZskhqMEGQowkQtd0rWAjxRCQ1uTs5aY0du1GZoOBRtd0XOwt1(ZAjPwrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abRL0Nfloy6plbpgAwCW01d48Ewd480otHpRgC2bDBDAGogV7rC5kHVEFwOZ0de8r4NLiGhgq(zjLditpqvhlf1Pb6iyTKRvo1AQ2Fwlj1ksPOZ(P(3pGSxRPAdahBzyJkoeSJAO3Go86RqNPhiyTK(SyXbt)zj4XqZIdMUEaN3ZAaNN2zk8zLgOJX7EexUYKxVpl0z6bc(i8ZseWddi)S(zTKuRiLIo7N6F)aYETMQnaCSLHnQ4qWoQHEd6WRVcDMEGG1s6ZIfhm9NLGhdnloy66bCEpRbCEANPWNLiZby(5Z39iUCLGxVpl0z6bc(i8ZseWddi)SKYbKPhOQbDEOPbcVwY1kNAnv7pRLKAfPu0z)u)7hq2R1uTbGJTmSrfhc2rn0BqhE9vOZ0deSwsFwS4GP)Se8yOzXbtxpGZ7znGZt7mf(SI84dM(7EexUYSxVpl0z6bc(i8ZseWddi)SKYbKPhOQbDEOPbcVwY1kBTMQ9N1ssTIuk6SFQ)9di71AQ2aWXwg2OIdb7Og6nOdV(k0z6bcwlPplwCW0FwcEm0S4GPRhW59SgW5PDMcFwnOZdnnq4V7DplJafjfnFVEFex2xVplwCW0FwCiyh1q)WXaf3ZcDMEGGpc)UhXL7R3Nfloy6pRjafv6AoeSJ6gtbhqoEwOZ0de8r439iUe(69zXIdM(ZsKEpnqGAk2zTns9SqNPhi4JWV7rCzYR3Nf6m9abFe(zLgpRaN49SyXbt)zjLditpWNLuo0otHplor9XHnEArc43ZceBmW4Ews47EexcE9(SqNPhi4JWpR04zf4eVNfloy6plPCaz6b(SKYH2zk8zHstTH4EwGyJbg3Zswj4DpIlZE9(SqNPhi4JWpR04znX7zXIdM(ZskhqMEGplPCODMcFwgbAamgAuA(Seb8WaYplsQnaCSLHnQMqJU01Zldkf6m9abR1uTKuRiLIo7Nsk6xx)OwIiQwrkfD2pLJIihzawlrevRiDqa4P4qWoQnIeeA3xHotpqWAjTwsFws5baQXXeFwY5zjLha4Zs239i(p417ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYH2zk8z1XsrDAGoc(Seb8WaYplwCqPOgDKcIZAnl5ALYbKPhOItuFCyJNwKa(9SKYdauJJj(SKZZskpaWNLSV7rCz(R3Nf6m9abFe(zLgpRjEplwCW0Fws5aY0d8zjLha4ZsoplPCODMcFwnOZdnnq4V7r8EYR3Nf6m9abFe(zLgpRaN49SyXbt)zjLditpWNLuo0otHpRooOsVVEES4V(Gu4ZceBmW4Ew9K39iUSY517ZcDMEGGpc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANPWNfp(4(t9SVl0ImhG5NpFwGyJbg3ZsoV7rCzL917ZcDMEGGpc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANPWNvm1uSKAqCW91Tm0xEuplqSXaJ7zjbV7rCzL7R3Nf6m9abFe(zLgpRaN49SyXbt)zjLditpWNLuo0otHpRyQPyj1G4G7RBzOJ04zbIngyCplj4DpIlRe(69zHotpqWhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZu4ZkMAkwsnio4(6wgA24zbIngyCpl5kN39iUSYKxVpl0z6bc(i8ZknEwboX7zXIdM(ZskhqMEGplPCODMcFwu5PncuGiO(YJst3)zbIngyCplz(7Eexwj417ZcDMEGGpc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANPWNfvEAkwsnio4(6wg6lpQNfi2yGX9SKvoV7rCzLzVEFwOZ0de8r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mf(SOYttXsQbXb3x3YqZgplqSXaJ7zjRe8UhXL9h869zHotpqWhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZu4ZIn0uSKAqCW91Tm0xEuplrapmG8ZsKoia8uCiyh1grccT7)SKYdauJJj(SKvoplP8aaFwsOCE3J4YkZF9(SqNPhi4JWpR04zf4eVNfloy6plPCaz6b(SKYH2zk8zXgAkwsnio4(6wg6lpQNfi2yGX9SKvoV7rCz7jVEFwOZ0de8r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mf(SydnflPgehCFDldnvEplqSXaJ7zjx58UhXLRCE9(SqNPhi4JWpR04znX7zXIdM(ZskhqMEGplP8aaFwYvo12tvlj1kb12JQvKoia8uCiyh1grccT7RqNPhiyTK(SKYH2zk8zfPHMILudIdUVULH(YJ6DpIlxzF9(SqNPhi4JWpR04znX7zXIdM(ZskhqMEGplP8aaFwsqTeRw5kNA7r1ssTIuk6SFkhA3D6gJ1ser1ssTI0bbGNIdb7O2isqODFf6m9abR1uTS4Gsrn6ifeN1(BTs5aY0duXjQpoSXtlsa)QL0AjTwIvRSsqT9OAjPwrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abR1uTS4Gsrn6ifeN1AwY1kLditpqfNO(4WgpTib8RwsFws5q7mf(SU8O0uSKAqCW91Tm0SX7EexUY917ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYda8zjx5uBpvTKuRmV2EuTI0bbGNIdb7O2isqODFf6m9abRL0NLuo0otHpRlpknflPgehCFDldDKgV7rC5kHVEFwOZ0de8r4NvA8SM49SyXbt)zjLditpWNLuEaGplzMCQTNQwsQLINhg91s5bawBpQwzLJCQL0NLiGhgq(zjsPOZ(PCOD3PBm(SKYH2zk8zrZrW2OMIDwBiU39iUCLjVEFwOZ0de8r4NvA8SM49SyXbt)zjLditpWNLuEaGpREIeuBpvTKulfppm6RLYdaS2EuTYkh5ulPplrapmG8ZsKsrN9t9VFaz)zjLdTZu4ZIMJGTrnf7S2qCV7rC5kbVEFwOZ0de8r4NvA8SM49SyXbt)zjLditpWNLuEaGplzUCQTNQwsQLINhg91s5bawBpQwzLJCQL0NLiGhgq(zjLditpqfnhbBJAk2zTH4QLCTY5zjLdTZu4ZIMJGTrnf7S2qCV7rC5kZE9(SqNPhi4JWpR04zf4eVNfloy6plPCaz6b(SKYH2zk8zXgAkOdPaO0uSZAdX9SaXgdmUNLSsW7EexU)GxVpl0z6bc(i8ZknEwboX7zXIdM(ZskhqMEGplPCODMcFwxEuAkwsTOJdBC(SaXgdmUNLCF3J4YvM)69zHotpqWhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZu4ZItuF5rPPyj1IooSX5ZceBmW4EwY9DpIl3EYR3Nf6m9abFe(zLgpRjEplwCW0Fws5aY0d8zjLha4Zs2A7r1ssTypaaAyGGkKYOFG8qNbOZUaRLiIQLKApEG(Pcah1ztBKFyOqNPhiyTMQLKApEG(P4qWoQrrxQqNPhiyTeruT)SwrkfD2p1)(bK9AjTwt1ssT)SwrkfD2pLJIihzawlrevlloOuuJosbXzTKRv2AjIOAdahBzyJQj0OlD98YGsHotpqWAjTwt1(ZAfPu0z)usr)66h1sATK(SKYH2zk8z1GZoOBRtd0X4DpIlHY517ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYda8zH9aaOHbcQOybthOE2H4PPaMqrTeruTypaaAyGGk7bdc5lJPMMbTXAjIOAXEaa0Wabv2dgeYxgtnfcYJbm9AjIOAXEaa0WabvGC8NktxdII)AdGlWPaDbwlrevl2daGggiOc6traCm9a19aa2paknikfkWAjIOAXEaa0WabvZeymW7GUToaO7xlrevl2daGggiOAc40Jmb1mfED9NxTeruTypaaAyGGQp(p6ym1TiDWAjIOAXEaa0WabvTbtH6SPP57g4ZskhANPWNfBOtxdmX39iUek7R3Nfloy6plkyezOHuSn(SqNPhi4JWV7rCjuUVEFwOZ0de8r4NLiGhgq(zjsPOZ(P(3pGSxRPAdahBzyJkoeSJAO3Go86RqNPhiyTMQvKoia8uCiyh1grccT7RqNPhiyTMQvkhqMEGkE8X9N6zFxOfzoaZpF(SyXbt)zfaoQZM2i)W4DpIlHs4R3Nf6m9abFe(zjc4HbKFw)SwPCaz6bQmc0aym0O0SwY1kBTMQnaCSLHnQaHtb0yaDo6Rfjff7Gk0z6bc(SyXbt)z1ICE054E3J4sOm517ZcDMEGGpc)Seb8WaYpRFwRuoGm9avgbAamgAuAwl5ALTwt1(ZAdahBzyJkq4uangqNJ(ArsrXoOcDMEGG1AQwsQ9N1ksPOZ(PKI(11pQLiIQvkhqMEGQgC2bDBDAGog1s6ZIfhm9Nfhc2rn9GN37EexcLGxVpl0z6bc(i8ZseWddi)S(zTs5aY0duzeObWyOrPzTKRv2Anv7pRnaCSLHnQaHtb0yaDo6Rfjff7Gk0z6bcwRPAfPu0z)usr)66h1AQ2FwRuoGm9avn4Sd6260aDmEwS4GP)SOGrKXuNn9Lbf637EexcLzVEFwOZ0de8r4NLiGhgq(zjLditpqLrGgaJHgLM1sUwzFwS4GP)SqPPGpy6V7DploXxVpIl7R3Nf6m9abFe(zjc4HbKFwbGJTmSrfiCkGgdOZrFTiPOyhuHotpqWAnvRiZby(5kAGwtdcNcOXa6C0xlskk2bvbYG9R1uT0aTMceofqJb05OVwKuuSdQBropfy(51AQwsQLgO1uCiyh1g5hgkW8ZR1uT0aTMkaCuNnTr(HHcm)8Anvlisd0AQlbeD6SPVoutX2qfy(51sATMQvK5am)C1LaIoD20xhQPyBOkqkg6ZAjxRCQ1uTKulnqRP4qWoQfDCyJQ5XI)1(l5ALYbKPhOItuF5rPPyj1IooSXzTMQLKAjP2JhOFQaWrD20g5hgk0z6bcwRPAfzoaZpxfaoQZM2i)Wqfifd9zT)sUwBbyTMQvK5am)Cfhc2rTr(HHkqkg6ZAnBTs5aY0duD5rPPyj1G4G7RBzOzJAjTwIiQwsQ9N1E8a9tfaoQZM2i)WqHotpqWAnvRiZby(5koeSJAJ8ddvGum0N1A2ALYbKPhO6YJstXsQbXb3x3YqZg1sATeruTImhG5NR4qWoQnYpmubsXqFw7VKR1wawlP1s6ZIfhm9NvlY5rNJ7DpIl3xVpl0z6bc(i8ZseWddi)SiP2aWXwg2OceofqJb05OVwKuuSdQqNPhiyTMQvK5am)CfnqRPbHtb0yaDo6Rfjff7GQazW(1AQwAGwtbcNcOXa6C0xlskk2b1nyGkW8ZR1uTgbkvBlavYQArop6CC1sATeruTKuBa4yldBubcNcOXa6C0xlskk2bvOZ0deSwt1EqkSwY1kNAj9zXIdM(ZQbdutp459UhXLWxVpl0z6bc(i8ZseWddi)ScahBzyJk7aoh91qbumqf6m9abR1uTImhG5NR4qWoQnYpmubsXqFwRzRvcLtTMQvK5am)C1LaIoD20xhQPyBOkqkg6ZAjxRCQ1uTKulnqRP4qWoQfDCyJQ5XI)1(l5ALYbKPhOItuF5rPPyj1IooSXzTMQLKAjP2JhOFQaWrD20g5hgk0z6bcwRPAfzoaZpxfaoQZM2i)Wqfifd9zT)sUwBbyTMQvK5am)Cfhc2rTr(HHkqkg6ZAnBTs5aY0duD5rPPyj1G4G7RBzOzJAjTwIiQwsQ9N1E8a9tfaoQZM2i)WqHotpqWAnvRiZby(5koeSJAJ8ddvGum0N1A2ALYbKPhO6YJstXsQbXb3x3YqZg1sATeruTImhG5NR4qWoQnYpmubsXqFw7VKR1wawlP1s6ZIfhm9NvlY5P9uk)UhXLjVEFwOZ0de8r4NLiGhgq(zfao2YWgv2bCo6RHcOyGk0z6bcwRPAfzoaZpxXHGDuBKFyOcKIH(SwY1kNAnvlj1ssTKuRiZby(5QlbeD6SPVoutX2qvGum0N1A2ALYbKPhOIn0uSKAqCW91Tm0xEu1AQwAGwtXHGDul64WgvZJf)RLCT0aTMIdb7Ow0XHnQOyj1ZJf)RL0AjIOAjPwrMdW8Zvxci60ztFDOMITHQaPyOpRLCTYPwt1sd0AkoeSJArhh2OAES4FT)sUwPCaz6bQ4e1xEuAkwsTOJdBCwlP1sATMQLgO1ubGJ6SPnYpmuG5NxlPplwCW0FwTiNN2tP87EexcE9(SqNPhi4JWplwCW0FwCiyh1uW5eoW5Zs0Xq)zj7ZseWddi)SePu0z)u)7hq2R1uTbGJTmSrfhc2rn0BqhE9vOZ0deSwt1sd0AkoeSJ6ooOsVVAES4FT)wRSsqTMQvK5am)CvWGq2p90GJ)QaPyOpR9xY1kLditpqvhhuP3xppw8xFqkSwIvlkjkaouFqkSwt1kYCaMFU6sarNoB6Rd1uSnufifd9zT)sUwPCaz6bQ64Gk9(65XI)6dsH1sSArjrbWH6dsH1sSAzXbtxfmiK9tpn44VcLefahQpifwRPAfzoaZpxXHGDuBKFyOcKIH(S2FjxRuoGm9avDCqLEF98yXF9bPWAjwTOKOa4q9bPWAjwTS4GPRcgeY(PNgC8xHsIcGd1hKcRLy1YIdMU6sarNoB6Rd1uSnuHsIcGd1hKcF3J4YSxVpl0z6bc(i8ZseWddi)ScahBzyJQj0OlD98YGsHotpqWAnvRrGs12cqLSkuAk4dM(ZIfhm9N1LaIoD20xhQPyB47Ee)h869zHotpqWhHFwIaEya5Nva4yldBunHgDPRNxguk0z6bcwRPAjPwJaLQTfGkzvO0uWhm9AjIOAncuQ2waQKvDjGOtNn91HAk2gwlPplwCW0FwCiyh1g5hgV7rCz(R3Nf6m9abFe(zjc4HbKFwhKcR1S1kHYPwt1gao2YWgvtOrx665LbLcDMEGG1AQwAGwtXHGDul64WgvZJf)R9xY1kLditpqfNO(YJstXsQfDCyJZAnvRiZby(5QlbeD6SPVoutX2qvGum0N1sUw5uRPAfzoaZpxXHGDuBKFyOcKIH(S2FjxRTa8zXIdM(ZcLMc(GP)UhX7jVEFwOZ0de8r4Nfloy6pluAk4dM(Zc6hgbGXPHTNfnqRPMqJU01Zldk18yXFY0aTMAcn6sxpVmOuuSK65XI)plOFyeagNgsrHGq(WNLSplrapmG8Z6GuyTMTwjuo1AQ2aWXwg2OAcn6sxpVmOuOZ0deSwt1kYCaMFUIdb7O2i)Wqfifd9zTKRvo1AQwsQLKAjPwrMdW8Zvxci60ztFDOMITHQaPyOpR1S1kLditpqfBOPyj1G4G7RBzOV8OQ1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xlP1ser1ssTImhG5NRUeq0PZM(6qnfBdvbsXqFwl5ALtTMQLgO1uCiyh1IooSr18yX)A)LCTs5aY0duXjQV8O0uSKArhh24SwsRL0AnvlnqRPcah1ztBKFyOaZpVwsF3J4YkNxVpl0z6bc(i8ZseWddi)SiPwrMdW8ZvCiyh1g5hgQaPyOpR1S1ktKGAjIOAfzoaZpxXHGDuBKFyOcKIH(S2FjxRewlP1AQwrMdW8Zvxci60ztFDOMITHQaPyOpRLCTYPwt1ssT0aTMIdb7Ow0XHnQMhl(x7VKRvkhqMEGkor9LhLMILul64WgN1AQwsQLKApEG(Pcah1ztBKFyOqNPhiyTMQvK5am)Cva4OoBAJ8ddvGum0N1(l5ATfG1AQwrMdW8ZvCiyh1g5hgQaPyOpR1S1kb1sATeruTKu7pR94b6NkaCuNnTr(HHcDMEGG1AQwrMdW8ZvCiyh1g5hgQaPyOpR1S1kb1sATeruTImhG5NR4qWoQnYpmubsXqFw7VKR1wawlP1s6ZIfhm9NffmImM6SPVmOq)E3J4Yk7R3Nf6m9abFe(zjc4HbKFwImhG5NRUeq0PZM(6qnfBdvbsXqFw7V1IsIcGd1hKcR1uTKulj1E8a9tfaoQZM2i)WqHotpqWAnvRiZby(5QaWrD20g5hgQaPyOpR9xY1AlaR1uTImhG5NR4qWoQnYpmubsXqFwRzRvkhqMEGQlpknflPgehCFDldnBulP1ser1ssT)S2JhOFQaWrD20g5hgk0z6bcwRPAfzoaZpxXHGDuBKFyOcKIH(SwZwRuoGm9avxEuAkwsnio4(6wgA2OwsRLiIQvK5am)Cfhc2rTr(HHkqkg6ZA)LCT2cWAj9zXIdM(Zkyqi7NEAWX)39iUSY917ZcDMEGGpc)Seb8WaYplrMdW8ZvCiyh1g5hgQaPyOpR93ArjrbWH6dsH1AQwsQLKAjPwrMdW8Zvxci60ztFDOMITHQaPyOpR1S1kLditpqfBOPyj1G4G7RBzOV8OQ1uT0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xlP1ser1ssTImhG5NRUeq0PZM(6qnfBdvbsXqFwl5ALtTMQLgO1uCiyh1IooSr18yX)A)LCTs5aY0duXjQV8O0uSKArhh24SwsRL0AnvlnqRPcah1ztBKFyOaZpVwsFwS4GP)ScgeY(PNgC8)DpIlRe(69zHotpqWhHFwIaEya5NLiZby(5koeSJAJ8ddvGum0N1sUw5uRPAjPwsQLKAfzoaZpxDjGOtNn91HAk2gQcKIH(SwZwRuoGm9avSHMILudIdUVULH(YJQwt1sd0AkoeSJArhh2OAES4FTKRLgO1uCiyh1IooSrfflPEES4FTKwlrevlj1kYCaMFU6sarNoB6Rd1uSnufifd9zTKRvo1AQwAGwtXHGDul64WgvZJf)R9xY1kLditpqfNO(YJstXsQfDCyJZAjTwsR1uT0aTMkaCuNnTr(HHcm)8Aj9zXIdM(Zce5RJodhF3J4YktE9(SqNPhi4JWplrapmG8ZIKAPbAnfhc2rTOJdBunpw8V2FjxRuoGm9avCI6lpknflPw0XHnoRLiIQ1iqPABbOswvWGq2p90GJ)1sATMQLKAjP2JhOFQaWrD20g5hgk0z6bcwRPAfzoaZpxfaoQZM2i)Wqfifd9zT)sUwBbyTMQvK5am)Cfhc2rTr(HHkqkg6ZAnBTs5aY0duD5rPPyj1G4G7RBzOzJAjTwIiQwsQ9N1E8a9tfaoQZM2i)WqHotpqWAnvRiZby(5koeSJAJ8ddvGum0N1A2ALYbKPhO6YJstXsQbXb3x3YqZg1sATeruTImhG5NR4qWoQnYpmubsXqFw7VKR1wawlPplwCW0Fwxci60ztFDOMITHV7rCzLGxVpl0z6bc(i8ZseWddi)SiPwsQvK5am)C1LaIoD20xhQPyBOkqkg6ZAnBTs5aY0duXgAkwsnio4(6wg6lpQAnvlnqRP4qWoQfDCyJQ5XI)1sUwAGwtXHGDul64WgvuSK65XI)1sATeruTKuRiZby(5QlbeD6SPVoutX2qvGum0N1sUw5uRPAPbAnfhc2rTOJdBunpw8V2FjxRuoGm9avCI6lpknflPw0XHnoRL0AjTwt1sd0AQaWrD20g5hgkW8ZFwS4GP)S4qWoQnYpmE3J4YkZE9(SqNPhi4JWplrapmG8ZIgO1ubGJ6SPnYpmuG5NxRPAjPwsQvK5am)C1LaIoD20xhQPyBOkqkg6ZAnBTYvo1AQwAGwtXHGDul64WgvZJf)RLCT0aTMIdb7Ow0XHnQOyj1ZJf)RL0AjIOAjPwrMdW8Zvxci60ztFDOMITHQaPyOpRLCTYPwt1sd0AkoeSJArhh2OAES4FT)sUwPCaz6bQ4e1xEuAkwsTOJdBCwlP1sATMQLKAfzoaZpxXHGDuBKFyOcKIH(SwZwRSYTwIiQwqKgO1uxci60ztFDOMITHkaJAj9zXIdM(ZkaCuNnTr(HX7Eex2FWR3Nf6m9abFe(zjc4HbKFwImhG5NR4qWoQZGwfifd9zTMTwjOwIiQ2Fw7Xd0pfhc2rDg0k0z6bc(SyXbt)zn7GTd62AJ8dJ39iUSY8xVpl0z6bc(i8ZseWddi)SePu0z)u)7hq2R1uTbGJTmSrfhc2rn0BqhE9vOZ0deSwt1sd0AkoeSJAJ8ddfGrTMQfePbAnvWGq2p90GJ)APadhdMgoGxF18yX)AjxRmPwt1AeOuTTaujRIdb7Ood6AnvlloOuuJosbXzT)w7p4zXIdM(ZIdb7OMEWZ7DpIlBp517ZcDMEGGpc)Seb8WaYplrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abR1uT0aTMIdb7O2i)WqbyuRPAbrAGwtfmiK9tpn44VwkWWXGPHd41xnpw8VwY1ktEwS4GP)S4qWoQP5iyB8DpIlx5869zHotpqWhHFwIaEya5NLiLIo7N6F)aYETMQnaCSLHnQ4qWoQHEd6WRVcDMEGG1AQwAGwtXHGDuBKFyOamQ1uTKulyEQGbHSF6Pbh)vbsXqFwRzRvMvlrevlisd0AQGbHSF6Pbh)1sbgogmnCaV(kaJAjTwt1cI0aTMkyqi7NEAWXFTuGHJbtdhWRVAES4FT)wRmPwt1YIdkf1OJuqCwl5ALWNfloy6ploeSJA6bpV39iUCL917ZcDMEGGpc)Seb8WaYplrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abR1uT0aTMIdb7O2i)WqbyuRPAbrAGwtfmiK9tpn44VwkWWXGPHd41xnpw8VwY1kHplwCW0FwCiyh1zq)UhXLRCF9(SqNPhi4JWplrapmG8ZsKsrN9t9VFazVwt1gao2YWgvCiyh1qVbD41xHotpqWAnvlnqRP4qWoQnYpmuag1AQwqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)RLCTY9zXIdM(ZIdb7OMMJGTX39iUCLWxVpl0z6bc(i8ZseWddi)SePu0z)u)7hq2R1uTbGJTmSrfhc2rn0BqhE9vOZ0deSwt1sd0AkoeSJAJ8ddfGrTMQ1iqPABbOsUQGbHSF6Pbh)R1uTS4Gsrn6ifeN1A2ALWNfloy6ploeSJAusJroHP)UhXLRm517ZcDMEGGpc)Seb8WaYplrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abR1uT0aTMIdb7O2i)WqbyuRPAbrAGwtfmiK9tpn44VwkWWXGPHd41xnpw8VwY1kBTMQLfhukQrhPG4SwZwRe(SyXbt)zXHGDuJsAmYjm939iUCLGxVpl0z6bc(i8ZseWddi)SObAnfiYxhDgoQamQ1uTGinqRPUeq0PZM(6qnfBdvag1AQwqKgO1uxci60ztFDOMITHQaPyOpR9xY1sd0AkJaNOlqD20uqhurXsQNhl(xBpQwwCW0vCiyh10dEEkusuaCO(GuyTMQLKAjP2JhOFQaNPZUavOZ0deSwt1YIdkf1OJuqCw7V1ktQL0AjIOAzXbLIA0rkioR93ALGAjTwt1ssT)S2aWXwg2OIdb7OMoPO5aKc9tHotpqWAjIOApoSXt1H846ugIRwZwRekb1s6ZIfhm9NLrGt0fOoBAkOd(UhXLRm717ZcDMEGGpc)Seb8WaYplAGwtbI81rNHJkaJAnvlj1ssThpq)ubotNDbQqNPhiyTMQLfhukQrhPG4S2FRvMulP1ser1YIdkf1OJuqCw7V1kb1sATMQLKA)zTbGJTmSrfhc2rnDsrZbif6NcDMEGG1ser1ECyJNQd5X1PmexTMTwjucQL0Nfloy6ploeSJA6bpV39iUC)bVEFwS4GP)SMagy4Pu(zHotpqWhHF3J4YvM)69zHotpqWhHFwIaEya5NfnqRP4qWoQfDCyJQ5XI)1AwY1ssTS4Gsrn6ifeN12tvRS1sATMQnaCSLHnQ4qWoQPtkAoaPq)uOZ0deSwt1ECyJNQd5X1PmexT)wRekbplwCW0FwCiyh10CeSn(UhXLBp517ZcDMEGGpc)Seb8WaYplAGwtXHGDul64WgvZJf)RLCT0aTMIdb7Ow0XHnQOyj1ZJf)FwS4GP)S4qWoQP5iyB8DpIlHY517ZcDMEGGpc)Seb8WaYplAGwtXHGDul64WgvZJf)RLCTYPwt1ssTImhG5NR4qWoQnYpmubsXqFwRzRvwjOwIiQ2Fwlj1ksPOZ(P(3pGSxRPAdahBzyJkoeSJAO3Go86RqNPhiyTKwlPplwCW0FwCiyh1zq)UhXLqzF9(SqNPhi4JWplrapmG8ZIKAdSf4SJPhyTeruT)S2dk(dD7AjTwt1sd0AkoeSJArhh2OAES4FTKRLgO1uCiyh1IooSrfflPEES4)ZIfhm9NLJxhg6dPmW59UhXLq5(69zHotpqWhHFwIaEya5NfnqRPedKdbppOBRcKfxTMQnaCSLHnQ4qWoQHEd6WRVcDMEGG1AQwsQLKApEG(PykJbSbf8btxHotpqWAnvlloOuuJosbXzT)wRmVwsRLiIQLfhukQrhPG4S2FRvcQL0Nfloy6ploeSJAk4Cch48DpIlHs4R3Nf6m9abFe(zjc4HbKFw0aTMsmqoe88GUTkqwC1AQ2JhOFkoeSJAu0Lk0z6bcwRPAbrAGwtDjGOtNn91HAk2gQamQ1uTKu7Xd0pftzmGnOGpy6k0z6bcwlrevlloOuuJosbXzT)wBpPwsFwS4GP)S4qWoQPGZjCGZ39iUektE9(SqNPhi4JWplrapmG8ZIgO1uIbYHGNh0TvbYIRwt1E8a9tXugdydk4dMUcDMEGG1AQwwCqPOgDKcIZA)TwzYZIfhm9Nfhc2rnfCoHdC(UhXLqj417ZcDMEGGpc)Seb8WaYplAGwtXHGDul64WgvZJf)R93APbAnfhc2rTOJdBurXsQNhl()SyXbt)zXHGDuJsAmYjm939iUekZE9(SqNPhi4JWplrapmG8ZIgO1uCiyh1IooSr18yX)AjxlnqRP4qWoQfDCyJkkws98yX)AnvRrGs12cqLSkoeSJAAoc2gFwS4GP)S4qWoQrjng5eM(7Eexc)bVEFwq)WiamonS9SOyNvgIZSKL5sWZc6hgbGXPHuuiiKp8zj7ZIfhm9Nfknf8bt)zHotpqWhHF37EwDCqLE)xVpIl7R3Nf6m9abFe(zXIdM(ZcLMc(GP)SaXPiGghm9N1pSv7i)Qn9APyNRLDWAfzoaZpFwlhyTIKc621cyyET2zTChYG1YoyTO08zjc4HbKFwuSZkdXv7VKRvcLtTMQvkhqMEGQe4MqquNnTiZby(5ZAnvlj1E8a9tfaoQZM2i)WqHotpqWAnvRiZby(5QaWrD20g5hgQaPyOpR93ALvo1s67EexUVEFwOZ0de8r4Nfiofb04GP)SiuXA)y)Q9YANhl(xBhhuP3V2gWy0xvBVDyTatS2SvRSYSANhl(pRTddSw4S2lRLfIeWVABzu71H1EqX)Ahy7Qn9AVoSwrh7ooQLDWAVoSwk4CchyTqV22aA3DQNLiGhgq(zrsTs5aY0dunpw8x3Xbv69RLiIQ9GuyT)wRSYPwsR1uT0aTMIdb7OUJdQ07RMhl(x7V1kRm7zj6yO)SK9zXIdM(ZIdb7OMcoNWboF3J4s4R3Nf6m9abFe(zXIdM(ZIdb7OMcoNWboFwG4ueqJdM(ZIqTd9AbMq3UwzkkJ(bYJA7HfGo7c08Af88QLRTHF1IsEbxlfCoHdCw7xhCG1(XWd6212YO2RdRLgO1QLVAVoS25XXvB2Q96WABq7U7zjc4HbKFwypaaAyGGkKYOFG8qNbOZUaR1uThKcR93ALq5uRPAV02EGkrMdW8ZN1AQwrMdW8ZviLr)a5HodqNDbQcKIH(SwZwRSYmz(7EexM869zHotpqWhHFwIaEya5NLuoGm9aviLr(HbcQP5iyBSwt1kYCaMFU6sarNoB6Rd1uSnufifd9zT)sUwusuaCO(GuyTMQvK5am)Cfhc2rTr(HHkqkg6ZA)LCTKulkjkaouFqkS2EuTYTwsR1uTKu7pRf7baqddeuntGXaVd626aGUFTeruTI0bbGNIdb7O2isqODFvW()Anl5ALGAjIOAfzoaZpxntGXaVd626aGUVkqkg6ZA)LCTKulkjkaouFqkS2EuTYTwsRL0Nfloy6pRGbHSF6Pbh)F3J4sWR3Nf6m9abFe(zjc4HbKFws5aY0du1tdmpnWeb1tdo(xRPAfzoaZpxXHGDuBKFyOcKIH(S2FjxlkjkaouFqkSwt1ssT)SwShaanmqq1mbgd8oOBRda6(1ser1ksheaEkoeSJAJibH29vb7)R1SKRvcQLiIQvK5am)C1mbgd8oOBRda6(QaPyOpR9xY1IsIcGd1hKcRL0Nfloy6pRlbeD6SPVoutX2W39iUm717ZcDMEGGpc)Seb8WaYplJaLQTfGkzvxci60ztFDOMITHplwCW0FwCiyh1g5hgV7r8FWR3Nf6m9abFe(zjc4HbKFws5aY0duHug5hgiOMMJGTXAnvRiZby(5QGbHSF6Pbh)vbsXqFw7VKRfLefahQpifwRPALYbKPhO6GuOgWp4qZg1AwY1kx5uRPAjP2FwRiDqa4P4qWoQnIeeA3xHotpqWAjIOA)zTs5aY0duXJpU)up77cTiZby(5ZAjIOAfzoaZpxDjGOtNn91HAk2gQcKIH(S2Fjxlj1IsIcGd1hKcRThvRCRL0Aj9zXIdM(ZkaCuNnTr(HX7EexM)69zHotpqWhHFwIaEya5NLuoGm9aviLr(HbcQP5iyBSwt1AeOuTTaujRkaCuNnTr(HXZIfhm9NvWGq2p90GJ)V7r8EYR3Nf6m9abFe(zjc4HbKFws5aY0du1tdmpnWeb1tdo(xRPA)zTs5aY0du1LdqOBRV8OEwS4GP)SUeq0PZM(6qnfBdF3J4YkNxVpl0z6bc(i8ZseWddi)SObAnfhc2rTr(HHcm)8Anvlj1kLditpq1bPqnGFWHMnQ1S1kHYPwIiQwrMdW8Zvbdcz)0tdo(RcKIH(SwZwRSYTwsR1uTKu7pRvKoia8uCiyh1grccT7RqNPhiyTeruT)SwPCaz6bQ4Xh3FQN9DHwK5am)8zTK(SyXbt)zfaoQZM2i)W4DpIlRSVEFwOZ0de8r4NLiGhgq(zjLditpqfszKFyGGAAoc2gR1uTKulnqRP4qWoQfDCyJQ5XI)1AwY1k3AjIOAfzoaZpxXHGDuNbTkqgSFTKwRPAjP2Fw7Xd0pva4OoBAJ8ddf6m9abRLiIQvK5am)Cva4OoBAJ8ddvGum0N1A2ALGAjTwt1kLditpqfopifFiOMn0ImhG5NxRzjxRekNAnvlj1(ZAfPdcapfhc2rTrKGq7(k0z6bcwlrev7pRvkhqMEGkE8X9N6zFxOfzoaZpFwlPplwCW0Fwbdcz)0tdo()UhXLvUVEFwOZ0de8r4Nfloy6pRlbeD6SPVoutX2WNfiofb04GP)Siu7qV2aWDOBxRrKGq7(MxlWeR9YJQw6(1cVjoA1c9AZaeJAVSwEaT9AHxTFWRRw24zjc4HbKFws5aY0duDqkud4hCOzJA)Twjqo1AQwPCaz6bQoifQb8do0SrTMTwjuo1AQwsQ9N1I9aaOHbcQMjWyG3bDBDaq3VwIiQwr6GaWtXHGDuBeji0UVky)FTMLCTsqTK(UhXLvcF9(SqNPhi4JWplrapmG8ZskhqMEGQEAG5PbMiOEAWX)AnvlnqRP4qWoQfDCyJQ5XI)1(BT0aTMIdb7Ow0XHnQOyj1ZJf)FwS4GP)S4qWoQZG(DpIlRm517ZcDMEGGpc)Seb8WaYplqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)RLCTGinqRPcgeY(PNgC8xlfy4yW0Wb86ROyj1ZJf)FwS4GP)S4qWoQP5iyB8DpIlRe869zHotpqWhHFwIaEya5NLuoGm9av90aZtdmrq90GJ)1ser1ssTGinqRPcgeY(PNgC8xlfy4yW0Wb86RamQ1uTGinqRPcgeY(PNgC8xlfy4yW0Wb86RMhl(x7V1cI0aTMkyqi7NEAWXFTuGHJbtdhWRVIILuppw8VwsFwS4GP)S4qWoQPh88E3J4YkZE9(SqNPhi4JWplwCW0FwCiyh1zq)SaXPiGghm9Nvp0eRnd6AtVwbyTa(aNZAzJAHZAfjf0TRfWO2zM(ZseWddi)SObAnfhc2rTOJdBunpw8V2FRvcR1uTs5aY0duDqkud4hCOzJAnBTYkN39iUS)GxVpl0z6bc(i8ZIfhm9Nfhc2rnfCoHdC(SeDm0FwY(Seb8WaYplAGwtjgihcEEq3wfilUAnvlnqRP4qWoQnYpmuagV7rCzL5VEFwOZ0de8r4Nfloy6ploeSJAAoc2gFwG4ueqJdM(Z6h2Q9dR1gVAnYpmQf6nGjm9AbbcOBx7ayE1(Hemg12XsXArpbS7QTJNhw7L1AJxTzRvlx78I0TRLMJGTXAbbcOBx71H1gPHezJA)Goy(9Seb8WaYplAGwtfaoQZM2i)WqbyuRPAPbAnva4OoBAJ8ddvGum0N1(l5AzXbtxXHGDutbNt4aNkusuaCO(GuyTMQLgO1uCiyh1g5hgkaJAnvlnqRP4qWoQfDCyJQ5XI)1sUwAGwtXHGDul64WgvuSK65XI)1AQwAGwtXHGDu3Xbv69vZJf)R1uT0aTMYi)Wqd9gWeMUcWOwt1sd0Ak6rMGdG5PamE3J4Y2tE9(SqNPhi4JWplwCW0FwCiyh10dEEplqCkcOXbt)z9dB1(H1AJxTg5hg1c9gWeMETGab0TRDamVA)qcgJA7yPyTONa2D12XZdR9YATXR2S1QLRDEr621sZrW2yTGab0TR96WAJ0qISrTFqhm)mV2zw7hsWyuB6J(1cmXArpbS7QLEWZBwl0HhKhJ(1EzT24v7L12sGOwrhh248zjc4HbKFw0aTMYiWj6cuNnnf0bvag1AQwsQLgO1uCiyh1IooSr18yX)A)TwAGwtXHGDul64WgvuSK65XI)1ser1(ZAjPwAGwtzKFyOHEdyctxbyuRPAPbAnf9itWbW8uag1sATK(UhXLRCE9(SqNPhi4JWplwCW0FwgborxG6SPPGo4ZceNIaACW0Fw92H1sJZRwGjwB2Q1iPQfoR9YAbMyTWR2lRThaaf)h9RLgaoaRv0XHnoRfeiGUDTSrTC7WO2Rd7xRnE1ccqzGG1s3V2RdRTJdQ07xlnhbBJplrapmG8ZIgO1uCiyh1IooSr18yX)A)TwAGwtXHGDul64WgvuSK65XI)1AQwAGwtXHGDuBKFyOamE3J4Yv2xVpl0z6bc(i8ZceNIaACW0FweQyTFSF1EzTZJf)RTJdQ07xBdym6RQT3oSwGjwB2QvwzwTZJf)N12HbwlCw7L1Ycrc4xTTmQ96WApO4FTdSD1METxhwROJDhh1YoyTxhwlfCoHdSwOxBBaT7o1ZIfhm9Nfhc2rnfCoHdC(SG(HrayCplzFwIog6plzFwIaEya5NfnqRP4qWoQ74Gk9(Q5XI)1(BTYkZEwq)WiamoT9iP5XZs239iUCL7R3Nf6m9abFe(zjc4HbKFw0aTMIdb7Ow0XHnQMhl(xl5APbAnfhc2rTOJdBurXsQNhl(xRPALYbKPhOcPmYpmqqnnhbBJplwCW0FwCiyh10CeSn(UhXLRe(69zHotpqWhHFwIaEya5Nff7SYqC1(BTYkbplwCW0FwO0uWhm939iUCLjVEFwOZ0de8r4Nfloy6ploeSJA6bpVNfiofb04GP)S6H5J(1cmXAPh88Q9YAPbGdWAfDCyJZAHTA)WA5rGmy)A7yPyTZKcRTfjvTzq)Seb8WaYplAGwtXHGDul64WgvZJf)R1uT0aTMIdb7Ow0XHnQMhl(x7V1sd0AkoeSJArhh2OIILuppw8)DpIlxj417ZcDMEGGpc)SaXPiGghm9Nvp8GJrTFWRRwMQwaFGZzTSrTWzTIKc621cyul7G1(HeeyTJ8R20RLID(zXIdM(ZIdb7OMcoNWboFwq)WiamUNLSplrhd9NLSplrapmG8Z6N1ssTs5aY0duDqkud4hCOzJA)LCTYkNAnvlf7SYqC1(BTsOCQL0Nf0pmcaJtBpsAE8SK9DpIlxz2R3Nf6m9abFe(zbItranoy6pRFmYgCGZA)GxxTJ8RwkEEy038A7G2D12XZdnV2mQLoVUAP4(165vBhlfRf9eWURwk25AVS2jGHrgxTD5xTuSZ1c9d9jukwBWGq2VANgC8Vwb71sJMx7mR9djymQfyI12Gbwl9GNxTSdwBlY5rNJR2Vo0RDKF1METuSZplwCW0FwnyGA6bpV39iUC)bVEFwS4GP)SArop6CCpl0z6bc(i87E3ZsWdbWGpy6ZxVpIl7R3Nf6m9abFe(zLgpRjEplwCW0Fws5aY0d8zjLha4Zs2NLiGhgq(zjLditpqvhlf1Pb6iyTKRvo1AQwJaLQTfGkzvO0uWhm9Anv7pRLKAdahBzyJQj0OlD98YGsHotpqWAjIOAdahBzyJQdPmYGh6pomuOZ0deSwsFws5q7mf(S6yPOonqhbF3J4Y917ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYda8zj7ZseWddi)SKYbKPhOQJLI60aDeSwY1kNAnvlnqRP4qWoQnYpmuG5NxRPAfzoaZpxXHGDuBKFyOcKIH(Swt1ssTbGJTmSr1eA0LUEEzqPqNPhiyTeruTbGJTmSr1HugzWd9hhgk0z6bcwlPplPCODMcFwDSuuNgOJGV7rCj817ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYda8zj7ZseWddi)SObAnfhc2rTOJdBunpw8VwY1sd0AkoeSJArhh2OIILuppw8Vwt1(ZAPbAnvamqD20xxG4ubyuRPABq7Uthifd9zT)sUwsQLKAPyNRvI1YIdMUIdb7OMEWZtjY5vlP12JQLfhmDfhc2rn9GNNcLefahQpifwlPplPCODMcFwnOZdnnq4V7rCzYR3Nf6m9abFe(zLgpRjEplwCW0Fws5aY0d8zjLha4ZIgO1uCiyh1DCqLEF18yX)AjxlnqRP4qWoQ74Gk9(kkws98yX)AjIOAjP2aWXwg2OIdb7OMoPO5aKc9tHotpqWAnv7XHnEQoKhxNYqC1(BTsOeulPplqCkcOXbt)zjtbVomQLRTbmg9RDES4pcwBhhuP3V2mQf61IsIcGdRny3gR9dED1s4KIMdqk0VNLuo0otHplKYi)Wab10CeSn(UhXLGxVpl0z6bc(i8ZknEwt8EwS4GP)SKYbKPh4ZskhANPWN1GNNMn0at8zbIngyCpl58Seb8WaYplAGwtXHGDuBKFyOamQ1uTKuRuoGm9avdEEA2qdmXAjxRCQLiIQ9GuyTMLCTs5aY0dun45PzdnWeRLy1kReulPplP8aaFwhKcF3J4YSxVpl0z6bc(i8ZknEwt8EwS4GP)SKYbKPh4ZskpaWNfj1kYCaMFUIdb7O2i)Wqbce8btV2EuTKuRS12tvlj1khLCKWA7r1ksheaEkoeSJAJibH29vb7)RL0AjTwsRTNQwsQ9GuyT9u1kLditpq1GNNMn0atSwsFwG4ueqJdM(ZQNdb7yT)yKGq7(1AdLIZA5ALYbKPhyTmvc4xTzRwbyyET0axTFibJrTatSwU22GVAX5bP4dMETDyGQA7TdRDcPe1AePuiicwBGum0NAusduCiyTOKgboNW0RfmXzTEE1(LX)A)WXO2wg1Aeji0UFTGayTxw71H1sdeZRFToFabwB2Q96WAfGH6zjLdTZu4ZcNhKIpeuZgArMdW8ZF3J4)GxVpl0z6bc(i8ZknEwt8EwS4GP)SKYbKPh4ZskpaWNLuoGm9av48Gu8HGA2qlYCaMF(ZseWddi)SePdcapfhc2rTrKGq7(plPCODMcFwhKc1a(bhA24DpIlZF9(SqNPhi4JWpR04znX7zXIdM(ZskhqMEGplP8aaFwImhG5NR4qWoQnYpmubsXqF(Seb8WaYpRFwRiDqa4P4qWoQnIeeA3xHotpqWNLuo0otHpRdsHAa)GdnB8UhX7jVEFwOZ0de8r4NvA8SOyjFwS4GP)SKYbKPh4ZskhANPWN1bPqnGFWHMnEwIaEya5Nfj1kYCaMFU6sarNoB6Rd1uSnufifd9zT9u1kLditpq1bPqnGFWHMnQL0A)Tw5kNNfiofb04GP)SiurcgJAbXb3V2E(hRfWO2lRvUYzIIABzuBV51JFws5ba(SezoaZpxDjGOtNn91HAk2gQcKIH(8DpIlRCE9(SqNPhi4JWpR04zrXs(SyXbt)zjLditpWNLuo0otHpRdsHAa)GdnB8Seb8WaYplr6GaWtXHGDuBeji0UFTMQvKoia8uCiyh1grccT7Rc2)x7V1kb1AQwShaanmqq1mbgd8oOBRda6(1AQwrkfD2p1)(bK9AnvBa4yldBuXHGDud9g0HxFf6m9abFwG4ueqJdM(ZYc6cSwzAa6(1cN1obeD1Y1AKFy0ag1Eb0)JxTTmQTh(9di7Mx7hsWyu78GI)1EzTxhw79L1sbDGdRv0xmWAb8doQ9dR1gVA5A7G2D1IEcy3vBW()AZwTgrccT7)SKYda8zjYCaMFUAMaJbEh0T1baDFvGum0NV7rCzL917ZcDMEGGpc)SsJN1eVNfloy6plPCaz6b(SKYda8zjYCaMFU6sarNoB6Rd1uSnufid2Vwt1kLditpq1bPqnGFWHMnQ93ALRCEwG4ueqJdM(ZIqfjymQfehC)A7nVECTag1EzTYvotuuBlJA75F8zjLdTZu4ZQlhGq3wF5r9UhXLvUVEFwOZ0de8r4NvA8SM49SyXbt)zjLditpWNLuEaGplsQ1iqPABbOswvWGq2p90GJ)1ser1AeOuTTaujxvWGq2p90GJ)1ser1AeOuTTaujHQGbHSF6Pbh)RL0Anvlisd0AQGbHSF6Pbh)1sbgogmnCaV(kW8ZFwG4ueqJdM(ZsMMbHSF1AzWX)AbtCwRNxTqkkeeYho6xRbWvlGrTxhwRuGHJbtdhWRFTGinqRv7mRfE1kyVwASwqyRbfaJR2lRfeofy41ED8v7hsqG1YxTxhwlHcmYRRwPadhdMgoGx)ANhl()SKYH2zk8z1tdmpnWeb1tdo()UhXLvcF9(SqNPhi4JWpR04znX7zXIdM(ZskhqMEGplP8aaFw0aTMIdb7O2i)WqbMFETMQLgO1ubGJ6SPnYpmuG5NxRPAbrAGwtDjGOtNn91HAk2gQaZpVwt1(ZALYbKPhOQNgyEAGjcQNgC8Vwt1cI0aTMkyqi7NEAWXFTuGHJbtdhWRVcm)8NLuo0otHpRe4MqquNnTiZby(5Z39iUSYKxVpl0z6bc(i8ZknEwt8EwS4GP)SKYbKPh4ZskpaWNva4yldBuXHGDud9g0HxFf6m9abR1uTKulj1ksPOZ(P(3pGSxRPAfzoaZpxfmiK9tpn44Vkqkg6ZA)TwPCaz6bQ64Gk9(65XI)6dsH1sATK(SKYH2zk8znpw8x3Xbv69F37EwnOZdnnq4VEFex2xVpl0z6bc(i8ZIfhm9Nfhc2rnfCoHdC(SeDm0FwY(Seb8WaYplAGwtjgihcEEq3wfilU39iUCF9(SyXbt)zXHGDutp459SqNPhi4JWV7rCj817ZIfhm9Nfhc2rnnhbBJpl0z6bc(i87E37EwsXyct)rC5kh5kRCKzY9h8S(4WHU98zrO2ZY0e)hsCcLKXART3oSwiLrgxTTmQLGooOsVpb1gypaagiyTZKcRLbUKIpeSwrh724uvYldqhRvwzSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKiRKKQk5LbOJ1ktKXAjK0LIXHG1sWfq)pEkMwOezoaZpNGAVSwcezoaZpxX0ccQLezLKuvjVmaDSwjqgRLqsxkghcwlbxa9)4PyAHsK5am)CcQ9YAjqK5am)CftliOwsKvssvL8Ya0XA)bYyTes6sX4qWAjqKoia8uMHGAVSwcePdcapLzuOZ0deKGAjrwjjvvYldqhRvw5iJ1siPlfJdbRLar6GaWtzgcQ9YAjqKoia8uMrHotpqqcQLezLKuvjVmaDSwzLvgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYkjPQsEza6yTYkRmwlHKUumoeSwcePdcapLziO2lRLar6GaWtzgf6m9abjOwsKvssvL892H12YXi)GUDTmqWZA)WaRfyIG1c9AVoSwwCW0RDaNxT0axTFyG165vBlbCWAHETxhwldcMETG8X08eLXs(A7PQ1i)Wqd9gWeMEjFjpHApltt8FiXjusgRT2E7WAHugzC12YOwcAWzh0T1Pb6yqqTb2daGbcw7mPWAzGlP4dbRv0XUnovL8Ya0XALvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKixjjvvYldqhRvUYyTes6sX4qWAj44b6NYmeu7L1sWXd0pLzuOZ0deKGAjrwjjvvYldqhRvcLXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYezSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowReiJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALzYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLVALP6Hjd1sISssQQKxgGowBprgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ12tKXAjK0LIXHG1sGiDqa4Pmdb1EzTeisheaEkZOqNPhiib1YxTYu9WKHAjrwjjvvYldqhRvw5kJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKRKKQk5LbOJ1kReiJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALRCKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRCLqzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sICLKuvjVmaDSw5kHYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLVALP6Hjd1sISssQQKxgGowRCLazSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1YxTYu9WKHAjrwjjvvYldqhRvUYmzSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKiRKKQk5l5ju7zzAI)djoHsYyT12BhwlKYiJR2wg1sqKhFW0jO2a7baWabRDMuyTmWLu8HG1k6y3gNQsEza6yTYkJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLezLKuvjVmaDSw5kJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALjYyTes6sX4qWAj44b6NYmeu7L1sWXd0pLzuOZ0deKGAjrwjjvvYldqhRvcKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowBprgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYkjPQsEza6yTYkZLXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRSYCzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRS9ezSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKiRKKQk5LbOJ1kBprgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kx5iJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLezLKuvjVmaDSw5kRmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvUYvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5l5ju7zzAI)djoHsYyT12BhwlKYiJR2wg1sqAGogeuBG9aayGG1otkSwg4sk(qWAfDSBJtvjVmaDSwzLXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kRCLXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRSsGmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGA5RwzQEyYqTKiRKKQk5LbOJ1kRmtgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqT8vRmvpmzOwsKvssvL8Ya0XAL9hiJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLezLKuvjFjpHApltt8FiXjusgRT2E7WAHugzC12YOwcaXgdmocQnWEaamqWANjfwldCjfFiyTIo2TXPQKxgGowRCLXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sICLKuvjVmaDSwzImwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvwzImwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvwzMmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvwzUmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvUYkJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOw(QvMQhMmuljYkjPQsEza6yTYvUYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSw5kHYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSw5ktKXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYvcKXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYvMjJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8L8eQ9SmnX)HeNqjzS2A7TdRfszKXvBlJAjWiqrsrZhb1gypaagiyTZKcRLbUKIpeSwrh724uvYldqhRvMjJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALzYyTes6sX4qWAjqKoia8uMHGAVSwcePdcapLzuOZ0deKGAjrwjjvvYldqhRvUYrgRLqsxkghcwlbI0bbGNYmeu7L1sGiDqa4PmJcDMEGGeuljYkjPQsEza6yTYvwzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRCLvgRLqsxkghcwlbI0bbGNYmeu7L1sGiDqa4PmJcDMEGGeuljYkjPQsEza6yTYvUYyTes6sX4qWAjqKoia8uMHGAVSwcePdcapLzuOZ0deKGAjrwjjvvYldqhRvU9ezSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKixjjvvYldqhRvU9ezSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRekxzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRekxzSwcjDPyCiyTeisheaEkZqqTxwlbI0bbGNYmk0z6bcsqTKiRKKQk5LbOJ1kHsOmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGA5RwzQEyYqTKiRKKQk5LbOJ1kHYezSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRekbYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjFjpHApltt8FiXjusgRT2E7WAHugzC12YOwcezoaZpFsqTb2daGbcw7mPWAzGlP4dbRv0XUnovL8Ya0XALvgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XALvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kxzSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKixjjvvYldqhRvUYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSwjugRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XALqzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRmrgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kZKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sICLKuvjVmaDSwzUmwlHKUumoeSwcoEG(Pmdb1EzTeC8a9tzgf6m9abjOwsKRKKQk5LbOJ12tKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sICLKuvjVmaDSwzLvgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XALvcLXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRSYezSwcjDPyCiyTeC8a9tzgcQ9YAj44b6NYmk0z6bcsqTKiRKKQk5LbOJ1kRmxgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYkjPQs(sEc1EwMM4)qItOKmwBT92H1cPmY4QTLrTeWjsqTb2daGbcw7mPWAzGlP4dbRv0XUnovL8Ya0XALvgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XALvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kxzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sICLKuvjVmaDSwjugRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XALqzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRmrgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kbYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSwzMmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhR9hiJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XAL5YyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDS2EImwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvw5iJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLe5kjPQsEza6yTYkRmwlHKUumoeSwcoEG(Pmdb1EzTeC8a9tzgf6m9abjOwsKRKKQk5LbOJ1kRmrgRLqsxkghcwlbhpq)uMHGAVSwcoEG(PmJcDMEGGeuljYvssvL8Ya0XAL9hiJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLVALP6Hjd1sISssQQKxgGowRSYCzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRS9ezSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRCLJmwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYldqhRvUYkJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALRCLXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYvcLXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTYvMiJ1siPlfJdbRLGaWXwg2OYmeu7L1sqa4yldBuzgf6m9abjOwsKvssvL8Ya0XALReiJ1siPlfJdbRLGJhOFkZqqTxwlbhpq)uMrHotpqqcQLezLKuvjVmaDSw5kbYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSw5kZKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRCLzYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLezLKuvjVmaDSw5kZLXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTsOCKXAjK0LIXHG1sqa4yldBuzgcQ9YAjiaCSLHnQmJcDMEGGeuljYkjPQsEza6yTsOCLXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKxgGowRekxzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1sISssQQKxgGowRekHYyTes6sX4qWAj44b6NYmeu7L1sWXd0pLzuOZ0deKGAjrUssQQKxgGowRektKXAjK0LIXHG1sWXd0pLziO2lRLGJhOFkZOqNPhiib1sISssQQKVKNqTNLPj(pK4ekjJ1wBVDyTqkJmUABzulbcEiag8btFsqTb2daGbcw7mPWAzGlP4dbRv0XUnovL8Ya0XALvgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKixjjvvYldqhRvUYyTes6sX4qWAjiaCSLHnQmdb1EzTeeao2YWgvMrHotpqqcQLe5kjPQsEza6yTsOmwlHKUumoeSwlifHu7SVFSK12dx1EzTYaaxliukCctV20ad(YOwsKiP1sISssQQKxgGowRmrgRLqsxkghcwlbbGJTmSrLziO2lRLGaWXwg2OYmk0z6bcsqTKiRKKQk5LbOJ1kZLXAjK0LIXHG1sGiDqa4Pmdb1EzTeisheaEkZOqNPhiib1YxTYu9WKHAjrwjjvvYldqhRvw5iJ1siPlfJdbRLGlG(F8umTqjYCaMFob1EzTeiYCaMFUIPfeuljYkjPQsEza6yTYkhzSwcjDPyCiyTeeao2YWgvMHGAVSwccahBzyJkZOqNPhiib1YxTYu9WKHAjrwjjvvYldqhRvwzImwlHKUumoeSwccahBzyJkZqqTxwlbbGJTmSrLzuOZ0deKGAjrwjjvvYxY)dPmY4qWALvo1YIdMETd48MQs(NLrKn4aFweAcDT9y2gRTNdb7yjpHMqxR8aowRCL5MxRCLJCLTKVKNqtORThAI1E9nGcEuRfKIqQTJDWb0TRnB1k6y3XrTq)Wiamoy61c95HmyTzRwceSlWHMfhmDcuL8L8S4GPpvgbkskA(igzjYHGDud9dhduCL8S4GPpvgbkskA(igzjYHGDu3yk4aYrjploy6tLrGIKIMpIrwII07PbcutXoRTrQsEwCW0NkJafjfnFeJSeLYbKPhO5otHK5e1hh24PfjGFMNgKdCIN5GyJbghzjSKNfhm9PYiqrsrZhXilrPCaz6bAUZuizuAQneN5Pb5aN4zoi2yGXrwwjOKNfhm9PYiqrsrZhXilrPCaz6bAUZuizJanagdnknnpnipXZCyJmjbGJTmSr1eA0LUEEzqzIerkfD2pLu0VU(brejsPOZ(PCue5idqIisKoia8uCiyh1grccT7tkPMlLhaizznxkpaqnoMiz5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKChlf1Pb6iO5Pb5jEMdBKzXbLIA0rkionlzPCaz6bQ4e1hh24PfjGFMlLhaizznxkpaqnoMiz5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKCd68qtdeU5Pb5jEMlLhaiz5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKChhuP3xppw8xFqk080GCGt8mheBmW4i3tk5zXbtFQmcuKu08rmYsukhqMEGM7mfsMhFC)PE23fArMdW8ZNMNgKdCIN5GyJbghz5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKCm1uSKAqCW91Tm0xEuMNgKdCIN5GyJbghzjOKNfhm9PYiqrsrZhXilrPCaz6bAUZui5yQPyj1G4G7RBzOJ0W80GCGt8mheBmW4ilbL8S4GPpvgbkskA(igzjkLditpqZDMcjhtnflPgehCFDldnByEAqoWjEMdIngyCKLRCk5zXbtFQmcuKu08rmYsukhqMEGM7mfsMkpTrGceb1xEuA6(MNgKdCIN5GyJbghzzEjploy6tLrGIKIMpIrwIs5aY0d0CNPqYu5PPyj1G4G7RBzOV8Ompnih4epZbXgdmoYYkNsEwCW0NkJafjfnFeJSeLYbKPhO5otHKPYttXsQbXb3x3YqZgMNgKdCIN5GyJbghzzLGsEwCW0NkJafjfnFeJSeLYbKPhO5otHKzdnflPgehCFDld9LhL5Pb5aN4zoSrwKoia8uCiyh1grccT7BUuEaGKLq5yUuEaGACmrYYkNsEwCW0NkJafjfnFeJSeLYbKPhO5otHKzdnflPgehCFDld9LhL5Pb5aN4zoi2yGXrww5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKmBOPyj1G4G7RBzOPYZ80GCGt8mheBmW4ilx5uYZIdM(uzeOiPO5JyKLOuoGm9an3zkKCKgAkwsnio4(6wg6lpkZtdYt8mxkpaqYYvo9uKib9ir6GaWtXHGDuBeji0UpPL8S4GPpvgbkskA(igzjkLditpqZDMcjF5rPPyj1G4G7RBzOzdZtdYt8mxkpaqYsaXKRC6rKisPOZ(PCOD3PBmserKisheaEkoeSJAJibH29nXIdkf1OJuqC(RuoGm9avCI6JdB80IeWpsjLyYkb9isePu0z)u)7hq2nfao2YWgvCiyh1qVbD413eloOuuJosbXPzjlLditpqfNO(4WgpTib8J0sEwCW0NkJafjfnFeJSeLYbKPhO5otHKV8O0uSKAqCW91Tm0rAyEAqEIN5s5baswUYPNIezEpsKoia8uCiyh1grccT7tAjploy6tLrGIKIMpIrwIs5aY0d0CNPqY0CeSnQPyN1gIZ80G8epZHnYIuk6SFkhA3D6gJMlLhaizzMC6PiHINhg91s5ba2JKvoYH0sEwCW0NkJafjfnFeJSeLYbKPhO5otHKP5iyButXoRneN5Pb5jEMdBKfPu0z)u)7hq2nxkpaqY9ejONIekEEy0xlLhaypsw5ihsl5zXbtFQmcuKu08rmYsukhqMEGM7mfsMMJGTrnf7S2qCMNgKN4zoSrwkhqMEGkAoc2g1uSZAdXrwoMlLhaizzUC6PiHINhg91s5ba2JKvoYH0sEwCW0NkJafjfnFeJSeLYbKPhO5otHKzdnf0HuauAk2zTH4mpnih4epZbXgdmoYYkbL8S4GPpvgbkskA(igzjkLditpqZDMcjF5rPPyj1IooSXP5Pb5aN4zoi2yGXrwUL8S4GPpvgbkskA(igzjkLditpqZDMcjZjQV8O0uSKArhh24080GCGt8mheBmW4il3sEwCW0NkJafjfnFeJSeLYbKPhO5otHKBWzh0T1Pb6yyEAqEIN5s5basw2EejypaaAyGGkKYOFG8qNbOZUajIisoEG(Pcah1ztBKFyyIKJhOFkoeSJAu0Ler0pfPu0z)u)7hq2j1ej)uKsrN9t5OiYrgGereloOuuJosbXjzzjIOaWXwg2OAcn6sxpVmOi10pfPu0z)usr)66hKsAjploy6tLrGIKIMpIrwIs5aY0d0CNPqYSHoDnWenpnipXZCP8aajJ9aaOHbcQOybthOE2H4PPaMqbreH9aaOHbcQShmiKVmMAAg0gjIiShaanmqqL9GbH8LXutHG8yatNiIWEaa0WabvGC8NktxdII)AdGlWPaDbserypaaAyGGkOpfbWX0du3day)aO0GOuOajIiShaanmqq1mbgd8oOBRda6(ere2daGggiOAc40Jmb1mfED9NhreH9aaOHbcQ(4)OJXu3I0bjIiShaanmqqvBWuOoBAA(UbwYZIdM(uzeOiPO5JyKLifmIm0qk2gl5zXbtFQmcuKu08rmYsmaCuNnTr(HH5WgzrkfD2p1)(bKDtbGJTmSrfhc2rn0BqhE9njsheaEkoeSJAJibH29njLditpqfp(4(t9SVl0ImhG5Npl5zXbtFQmcuKu08rmYsSf58OZXzoSr(Ns5aY0duzeObWyOrPjzznfao2YWgvGWPaAmGoh91IKIIDWsEwCW0NkJafjfnFeJSe5qWoQPh88mh2i)tPCaz6bQmc0aym0O0KSSM(za4yldBubcNcOXa6C0xlskk2bnrYpfPu0z)usr)66herKuoGm9avn4Sd6260aDmiTKNfhm9PYiqrsrZhXilrkyezm1ztFzqH(zoSr(Ns5aY0duzeObWyOrPjzzn9ZaWXwg2OceofqJb05OVwKuuSdAsKsrN9tjf9RRFy6Ns5aY0du1GZoOBRtd0XOKNfhm9PYiqrsrZhXilruAk4dMU5WgzPCaz6bQmc0aym0O0KSSL8L8S4GPpjgzjksa)WyAGJrjploy6tIrwIatutXoRTrkZHnYKC8a9tH(aA3DOJGMOyNvgI7xYYC5yIIDwzioZswMjbKserK8ZJhOFk0hq7UdDe0ef7SYqC)swMlbKwYZIdM(KyKLOrEW0nh2itd0AkoeSJAJ8ddfGrjploy6tIrwIhKc1FCyyoSroaCSLHnQoKYidEO)4WWenqRPqj7yG5btxbyyIerMdW8ZvCiyh1g5hgQazW(ereDoNMAq7Uthifd95VKLjYH0sEwCW0NeJSehq7UBQ7PbaTPq)mh2itd0AkoeSJAJ8ddfy(5MObAnva4OoBAJ8ddfy(5MarAGwtDjGOtNn91HAk2gQaZpVKNfhm9jXilrA2wNn9fqX)P5WgzAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOaZp3eisd0AQlbeD6SPVoutX2qfy(5L8S4GPpjgzjsJXeJ)q32CyJmnqRP4qWoQnYpmuagL8S4GPpjgzjspYeu3aI(MdBKPbAnfhc2rTr(HHcWOKNfhm9jXilXgmq6rMGMdBKPbAnfhc2rTr(HHcWOKNfhm9jXilr2f48cEOf8yyoSrMgO1uCiyh1g5hgkaJsEwCW0NeJSebMOgEi10CyJmnqRP4qWoQnYpmuagL8S4GPpjgzjcmrn8qkZXwdfN2zkKS9GbH8LXutZG2O5WgzAGwtXHGDuBKFyOamiIirMdW8ZvCiyh1g5hgQaPyOpnlzjqcmbI0aTM6sarNoB6Rd1uSnubyuYZIdM(KyKLiWe1WdPm3zkKmsz0pqEOZa0zxGMdBKfzoaZpxXHGDuBKFyOcKIH(8xYKiResSFqpskhqMEGk2qNUgyIKAsK5am)C1LaIoD20xhQPyBOkqkg6ZFjtISsiX(b9iPCaz6bQydD6AGjsAjploy6tIrwIatudpKYCNPqYGbYGnyGAP4CIdZHnYImhG5NR4qWoQnYpmubsXqFAwYYvoer0pLYbKPhOIn0PRbMizzjIisoifswoMKYbKPhOQbNDq3wNgOJbzznfao2YWgvtOrx665LbfPL8S4GPpjgzjcmrn8qkZDMcjptGHgA7WddZHnYImhG5NR4qWoQnYpmubsXqFAwYsOCiIOFkLditpqfBOtxdmrYYwYZIdM(KyKLiWe1WdPm3zkKS9OVrNoBAEoHuWbFW0nh2ilYCaMFUIdb7O2i)Wqfifd9Pzjlx5qer)ukhqMEGk2qNUgyIKLLiIi5Guiz5yskhqMEGQgC2bDBDAGogKL1ua4yldBunHgDPRNxguKwYZIdM(KyKLiWe1WdPm3zkKmfly6a1ZoepnfWekmh2ilYCaMFUIdb7O2i)Wqfifd95VKLatK8tPCaz6bQAWzh0T1Pb6yqwwIi6GuOzLq5qAjploy6tIrwIatudpKYCNPqYuSGPdup7q80uatOWCyJSiZby(5koeSJAJ8ddvGum0N)swcmjLditpqvdo7GUTonqhdYYAIgO1ubGJ6SPnYpmuagMObAnva4OoBAJ8ddvGum0N)sMezLtpLe0JcahBzyJQj0OlD98YGIuthKc)vcLtjpHMqxlloy6tIrwIo(1sahuh4mhsrZbMO(RdoqTGNh0TjlR5WgzAGwtXHGDuBKFyOamiIiqKgO1uxci60ztFDOMITHkadIicmpvWGq2p90GJ)Qdk(dD7sEwCW0NeJSef8yOzXbtxpGZZCNPqYcEiag8btFwYZIdM(KyKLOGhdnloy66bCEM7mfsMt085fqXrwwZHnYS4Gsrn6ifeNMLSuoGm9avCI6JdB80IeWVsEwCW0NeJSef8yOzXbtxpGZZCNPqYDCqLEFZHnYIuk6SFQ)9di7McahBzyJkoeSJAO3Go86xYZIdM(KyKLOGhdnloy66bCEM7mfsUbNDq3wNgOJH5WgzPCaz6bQ6yPOonqhbjlhts5aY0du1GZoOBRtd0XW0pjrKsrN9t9VFaz3ua4yldBuXHGDud9g0HxFsl5zXbtFsmYsuWJHMfhmD9aopZDMcjNgOJH5WgzPCaz6bQ6yPOonqhbjlht)KerkfD2p1)(bKDtbGJTmSrfhc2rn0BqhE9jTKNfhm9jXilrbpgAwCW01d48m3zkKSiZby(5tZHnY)KerkfD2p1)(bKDtbGJTmSrfhc2rn0BqhE9jTKNfhm9jXilrbpgAwCW01d48m3zkKCKhFW0nh2ilLditpqvd68qtdeoz5y6NKisPOZ(P(3pGSBkaCSLHnQ4qWoQHEd6WRpPL8S4GPpjgzjk4XqZIdMUEaNN5otHKBqNhAAGWnh2ilLditpqvd68qtdeozzn9tsePu0z)u)7hq2nfao2YWgvCiyh1qVbD41N0s(sEwCW0NkorYTiNhDooZHnYbGJTmSrfiCkGgdOZrFTiPOyh0KiZby(5kAGwtdcNcOXa6C0xlskk2bvbYG9nrd0Akq4uangqNJ(ArsrXoOUf58uG5NBIeAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOaZp3eisd0AQlbeD6SPVoutX2qfy(5KAsK5am)C1LaIoD20xhQPyBOkqkg6tYYXej0aTMIdb7Ow0XHnQMhl()lzPCaz6bQ4e1xEuAkwsTOJdBCAIesoEG(Pcah1ztBKFyysK5am)Cva4OoBAJ8ddvGum0N)s2waAsK5am)Cfhc2rTr(HHkqkg6tZkLditpq1LhLMILudIdUVULHMniLiIi5Nhpq)ubGJ6SPnYpmmjYCaMFUIdb7O2i)Wqfifd9PzLYbKPhO6YJstXsQbXb3x3YqZgKserImhG5NR4qWoQnYpmubsXqF(lzBbiPKwYZIdM(uXjsmYsSbdutp45zoSrMKaWXwg2OceofqJb05OVwKuuSdAsK5am)CfnqRPbHtb0yaDo6Rfjff7GQazW(MObAnfiCkGgdOZrFTiPOyhu3GbQaZp3KrGs12cqLSQwKZJohhPerejbGJTmSrfiCkGgdOZrFTiPOyh00bPqYYH0sEwCW0NkorIrwITiNN2tPS5Wg5aWXwg2OYoGZrFnuafd0KiZby(5koeSJAJ8ddvGum0NMvcLJjrMdW8Zvxci60ztFDOMITHQaPyOpjlhtKqd0AkoeSJArhh2OAES4)VKLYbKPhOItuF5rPPyj1IooSXPjsi54b6NkaCuNnTr(HHjrMdW8ZvbGJ6SPnYpmubsXqF(lzBbOjrMdW8ZvCiyh1g5hgQaPyOpnRuoGm9avxEuAkwsnio4(6wgA2GuIiIKFE8a9tfaoQZM2i)WWKiZby(5koeSJAJ8ddvGum0NMvkhqMEGQlpknflPgehCFDldnBqkrejYCaMFUIdb7O2i)Wqfifd95VKTfGKsAjploy6tfNiXilXwKZt7Pu2CyJCa4yldBuzhW5OVgkGIbAsK5am)Cfhc2rTr(HHkqkg6tYYXejKqIiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGk2qtXsQbXb3x3YqF5rzIgO1uCiyh1IooSr18yXFY0aTMIdb7Ow0XHnQOyj1ZJf)jLiIirK5am)C1LaIoD20xhQPyBOkqkg6tYYXenqRP4qWoQfDCyJQ5XI))swkhqMEGkor9LhLMILul64WgNKsQjAGwtfaoQZM2i)WqbMFoPL8S4GPpvCIeJSe5qWoQPGZjCGtZHnYIuk6SFQ)9di7McahBzyJkoeSJAO3Go86BIgO1uCiyh1DCqLEF18yX)FLvcmjYCaMFUkyqi7NEAWXFvGum0N)swkhqMEGQooOsVVEES4V(GuiXqjrbWH6dsHMezoaZpxDjGOtNn91HAk2gQcKIH(8xYs5aY0du1Xbv691ZJf)1hKcjgkjkaouFqkKyS4GPRcgeY(PNgC8xHsIcGd1hKcnjYCaMFUIdb7O2i)Wqfifd95VKLYbKPhOQJdQ07RNhl(RpifsmusuaCO(GuiXyXbtxfmiK9tpn44VcLefahQpifsmwCW0vxci60ztFDOMITHkusuaCO(GuO5Iog6KLTKNfhm9PItKyKL4LaIoD20xhQPyBO5Wg5aWXwg2OAcn6sxpVmOmzeOuTTaujRcLMc(GPxYZIdM(uXjsmYsKdb7O2i)WWCyJCa4yldBunHgDPRNxguMiXiqPABbOswfknf8btNiImcuQ2waQKvDjGOtNn91HAk2gsAjploy6tfNiXilruAk4dMU5Wg5dsHMvcLJPaWXwg2OAcn6sxpVmOmrd0AkoeSJArhh2OAES4)VKLYbKPhOItuF5rPPyj1IooSXPjrMdW8Zvxci60ztFDOMITHQaPyOpjlhtImhG5NR4qWoQnYpmubsXqF(lzBbyjploy6tfNiXilruAk4dMU5Wg5dsHMvcLJPaWXwg2OAcn6sxpVmOmjYCaMFUIdb7O2i)Wqfifd9jz5yIesirK5am)C1LaIoD20xhQPyBOkqkg6tZkLditpqfBOPyj1G4G7RBzOV8Omrd0AkoeSJArhh2OAES4pzAGwtXHGDul64WgvuSK65XI)KserKiYCaMFU6sarNoB6Rd1uSnufifd9jz5yIgO1uCiyh1IooSr18yX)FjlLditpqfNO(YJstXsQfDCyJtsj1enqRPcah1ztBKFyOaZpNuZH(HrayCAyJmnqRPMqJU01Zldk18yXFY0aTMAcn6sxpVmOuuSK65XI)Md9dJaW40qkkeeYhsw2sEwCW0NkorIrwIuWiYyQZM(YGc9ZCyJmjImhG5NR4qWoQnYpmubsXqFAwzIeqerImhG5NR4qWoQnYpmubsXqF(lzjKutImhG5NRUeq0PZM(6qnfBdvbsXqFswoMiHgO1uCiyh1IooSr18yX)FjlLditpqfNO(YJstXsQfDCyJttKqYXd0pva4OoBAJ8ddtImhG5NRcah1ztBKFyOcKIH(8xY2cqtImhG5NR4qWoQnYpmubsXqFAwjGuIiIKFE8a9tfaoQZM2i)WWKiZby(5koeSJAJ8ddvGum0NMvciLiIezoaZpxXHGDuBKFyOcKIH(8xY2cqsjTKNfhm9PItKyKLyWGq2p90GJ)MdBKfzoaZpxDjGOtNn91HAk2gQcKIH(8xusuaCO(GuOjsi54b6NkaCuNnTr(HHjrMdW8ZvbGJ6SPnYpmubsXqF(lzBbOjrMdW8ZvCiyh1g5hgQaPyOpnRuoGm9avxEuAkwsnio4(6wgA2GuIiIKFE8a9tfaoQZM2i)WWKiZby(5koeSJAJ8ddvGum0NMvkhqMEGQlpknflPgehCFDldnBqkrejYCaMFUIdb7O2i)Wqfifd95VKTfGKwYZIdM(uXjsmYsmyqi7NEAWXFZHnYImhG5NR4qWoQnYpmubsXqF(lkjkaouFqk0ejKqIiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGk2qtXsQbXb3x3YqF5rzIgO1uCiyh1IooSr18yXFY0aTMIdb7Ow0XHnQOyj1ZJf)jLiIirK5am)C1LaIoD20xhQPyBOkqkg6tYYXenqRP4qWoQfDCyJQ5XI))swkhqMEGkor9LhLMILul64WgNKsQjAGwtfaoQZM2i)WqbMFoPL8S4GPpvCIeJSebr(6OZWrZHnYImhG5NR4qWoQnYpmubsXqFswoMiHesezoaZpxDjGOtNn91HAk2gQcKIH(0Ss5aY0duXgAkwsnio4(6wg6lpkt0aTMIdb7Ow0XHnQMhl(tMgO1uCiyh1IooSrfflPEES4pPerejImhG5NRUeq0PZM(6qnfBdvbsXqFswoMObAnfhc2rTOJdBunpw8)xYs5aY0duXjQV8O0uSKArhh24Kusnrd0AQaWrD20g5hgkW8ZjTKNfhm9PItKyKL4LaIoD20xhQPyBO5WgzsObAnfhc2rTOJdBunpw8)xYs5aY0duXjQV8O0uSKArhh24KiImcuQ2waQKvfmiK9tpn44pPMiHKJhOFQaWrD20g5hgMezoaZpxfaoQZM2i)Wqfifd95VKTfGMezoaZpxXHGDuBKFyOcKIH(0Ss5aY0duD5rPPyj1G4G7RBzOzdsjIis(5Xd0pva4OoBAJ8ddtImhG5NR4qWoQnYpmubsXqFAwPCaz6bQU8O0uSKAqCW91Tm0SbPerKiZby(5koeSJAJ8ddvGum0N)s2wasAjploy6tfNiXilroeSJAJ8ddZHnYKqIiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGk2qtXsQbXb3x3YqF5rzIgO1uCiyh1IooSr18yXFY0aTMIdb7Ow0XHnQOyj1ZJf)jLiIirK5am)C1LaIoD20xhQPyBOkqkg6tYYXenqRP4qWoQfDCyJQ5XI))swkhqMEGkor9LhLMILul64WgNKsQjAGwtfaoQZM2i)WqbMFEjploy6tfNiXilXaWrD20g5hgMdBKPbAnva4OoBAJ8ddfy(5MiHerMdW8Zvxci60ztFDOMITHQaPyOpnRCLJjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw8NuIiIerMdW8Zvxci60ztFDOMITHQaPyOpjlht0aTMIdb7Ow0XHnQMhl()lzPCaz6bQ4e1xEuAkwsTOJdBCskPMirK5am)Cfhc2rTr(HHkqkg6tZkRCjIiqKgO1uxci60ztFDOMITHkadsl5zXbtFQ4ejgzjo7GTd62AJ8ddZHnYImhG5NR4qWoQZGwfifd9PzLaIi6Nhpq)uCiyh1zqxYZIdM(uXjsmYsKdb7OMEWZZCyJSiLIo7N6F)aYUPaWXwg2OIdb7Og6nOdV(MObAnfhc2rTr(HHcWWeisd0AQGbHSF6Pbh)1sbgogmnCaV(Q5XI)KLjMmcuQ2waQKvXHGDuNbTjwCqPOgDKcIZF)bL8S4GPpvCIeJSe5qWoQP5iyB0CyJSiLIo7N6F)aYUPaWXwg2OIdb7Og6nOdV(MObAnfhc2rTr(HHcWWeisd0AQGbHSF6Pbh)1sbgogmnCaV(Q5XI)KLjL8S4GPpvCIeJSe5qWoQPh88mh2ilsPOZ(P(3pGSBkaCSLHnQ4qWoQHEd6WRVjAGwtXHGDuBKFyOammrcyEQGbHSF6Pbh)vbsXqFAwzgrebI0aTMkyqi7NEAWXFTuGHJbtdhWRVcWGutGinqRPcgeY(PNgC8xlfy4yW0Wb86RMhl()RmXeloOuuJosbXjzjSKNfhm9PItKyKLihc2rDg0MdBKfPu0z)u)7hq2nfao2YWgvCiyh1qVbD413enqRP4qWoQnYpmuagMarAGwtfmiK9tpn44VwkWWXGPHd41xnpw8NSewYZIdM(uXjsmYsKdb7OMMJGTrZHnYIuk6SFQ)9di7McahBzyJkoeSJAO3Go86BIgO1uCiyh1g5hgkadtGinqRPcgeY(PNgC8xlfy4yW0Wb86RMhl(twUL8S4GPpvCIeJSe5qWoQrjng5eMU5WgzrkfD2p1)(bKDtbGJTmSrfhc2rn0BqhE9nrd0AkoeSJAJ8ddfGHjJaLQTfGk5QcgeY(PNgC83eloOuuJosbXPzLWsEwCW0NkorIrwICiyh1OKgJCct3CyJSiLIo7N6F)aYUPaWXwg2OIdb7Og6nOdV(MObAnfhc2rTr(HHcWWeisd0AQGbHSF6Pbh)1sbgogmnCaV(Q5XI)KL1eloOuuJosbXPzLWsEwCW0NkorIrwIgborxG6SPPGoO5WgzAGwtbI81rNHJkadtGinqRPUeq0PZM(6qnfBdvagMarAGwtDjGOtNn91HAk2gQcKIH(8xY0aTMYiWj6cuNnnf0bvuSK65XI)9iwCW0vCiyh10dEEkusuaCO(GuOjsi54b6NkWz6SlqtS4Gsrn6ifeN)ktiLiIyXbLIA0rkio)vci1ej)maCSLHnQ4qWoQPtkAoaPq)iIOJdB8uDipUoLH4mRekbKwYZIdM(uXjsmYsKdb7OMEWZZCyJmnqRPar(6OZWrfGHjsi54b6NkWz6SlqtS4Gsrn6ifeN)ktiLiIyXbLIA0rkio)vci1ej)maCSLHnQ4qWoQPtkAoaPq)iIOJdB8uDipUoLH4mRekbKwYZIdM(uXjsmYsCcyGHNs5sEwCW0NkorIrwICiyh10CeSnAoSrMgO1uCiyh1IooSr18yXFZsMewCqPOgDKcIZEkzj1ua4yldBuXHGDutNu0CasH(z64WgpvhYJRtziUFLqjOKNfhm9PItKyKLihc2rnnhbBJMdBKPbAnfhc2rTOJdBunpw8NmnqRP4qWoQfDCyJkkws98yX)sEwCW0NkorIrwICiyh1zqBoSrMgO1uCiyh1IooSr18yXFYYXejImhG5NR4qWoQnYpmubsXqFAwzLaIi6NKisPOZ(P(3pGSBkaCSLHnQ4qWoQHEd6WRpPKwYZIdM(uXjsmYs0XRdd9Hug48mh2itsGTaNDm9ajIOFEqXFOBtQjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw8VKNfhm9PItKyKLihc2rnfCoHdCAoSrMgO1uIbYHGNh0TvbYIZua4yldBuXHGDud9g0HxFtKqYXd0pftzmGnOGpy6MyXbLIA0rkio)vMtkreXIdkf1OJuqC(ReqAjploy6tfNiXilroeSJAk4Cch40CyJmnqRPedKdbppOBRcKfNPJhOFkoeSJAu0LMarAGwtDjGOtNn91HAk2gQammrYXd0pftzmGnOGpy6ereloOuuJosbX5V9esl5zXbtFQ4ejgzjYHGDutbNt4aNMdBKPbAnLyGCi45bDBvGS4mD8a9tXugdydk4dMUjwCqPOgDKcIZFLjL8S4GPpvCIeJSe5qWoQrjng5eMU5WgzAGwtXHGDul64WgvZJf))LgO1uCiyh1IooSrfflPEES4Fjploy6tfNiXilroeSJAusJroHPBoSrMgO1uCiyh1IooSr18yXFY0aTMIdb7Ow0XHnQOyj1ZJf)nzeOuTTaujRIdb7OMMJGTXsEwCW0NkorIrwIO0uWhmDZH(HrayCAyJmf7SYqCMLSmxcmh6hgbGXPHuuiiKpKSSL8L8S4GPpvcEiag8btFswkhqMEGM7mfsUJLI60aDe080G8epZLYdaKSSMdBKLYbKPhOQJLI60aDeKSCmzeOuTTaujRcLMc(GPB6NKeao2YWgvtOrx665Lbfrefao2YWgvhszKbp0FCyqAjploy6tLGhcGbFW0NeJSeLYbKPhO5otHK7yPOonqhbnpnipXZCP8aajlR5WgzPCaz6bQ6yPOonqhbjlht0aTMIdb7O2i)WqbMFUjrMdW8ZvCiyh1g5hgQaPyOpnrsa4yldBunHgDPRNxguerua4yldBuDiLrg8q)XHbPL8S4GPpvcEiag8btFsmYsukhqMEGM7mfsUbDEOPbc380G8epZLYdaKSSMdBKPbAnfhc2rTOJdBunpw8NmnqRP4qWoQfDCyJkkws98yXFt)KgO1ubWa1ztFDbItfGHPg0U70bsXqF(lzsiHIDUhUyXbtxXHGDutp45Pe58iThXIdMUIdb7OMEWZtHsIcGd1hKcjTKNqxRmf86WOwU2gWy0V25XI)iyTDCqLE)AZOwOxlkjkaoS2GDBS2p41vlHtkAoaPq)k5zXbtFQe8qam4dM(KyKLOuoGm9an3zkKmszKFyGGAAoc2gnpnipXZCP8aajtd0AkoeSJ6ooOsVVAES4pzAGwtXHGDu3Xbv69vuSK65XI)erejbGJTmSrfhc2rnDsrZbif6NPJdB8uDipUoLH4(vcLasl5zXbtFQe8qam4dM(KyKLOuoGm9an3zkK8GNNMn0at0CqSXaJJSCmpnipXZCyJmnqRP4qWoQnYpmuagMirkhqMEGQbppnBObMiz5qerhKcnlzPCaz6bQg880SHgyIetwjGuZLYdaK8bPWsEcDT9CiyhR9hJeeA3VwBOuCwlxRuoGm9aRLPsa)QnB1kadZRLg4Q9djymQfyI1Y12g8vlopifFW0RTdduvBVDyTtiLOwJiLcbrWAdKIH(uJsAGIdbRfL0iW5eMETGjoR1ZR2Vm(x7hog12YOwJibH29RfeaR9YAVoSwAGyE9R15diWAZwTxhwRamuL8S4GPpvcEiag8btFsmYsukhqMEGM7mfsgNhKIpeuZgArMdW8ZnpnipXZCP8aajtIiZby(5koeSJAJ8ddfiqWhm9EejY2trICuYrc7rI0bbGNIdb7O2isqODFvW(FsjL0Eksoif2tjLditpq1GNNMn0atK0sEwCW0Nkbpead(GPpjgzjkLditpqZDMcjFqkud4hCOzdZtdYt8mh2ilsheaEkoeSJAJibH29nxkpaqYs5aY0duHZdsXhcQzdTiZby(5L8S4GPpvcEiag8btFsmYsukhqMEGM7mfs(GuOgWp4qZgMNgKN4zoSr(NI0bbGNIdb7O2isqODFZLYdaKSiZby(5koeSJAJ8ddvGum0NL8e6AjurcgJAbXb3V2E(hRfWO2lRvUYzIIABzuBV51Jl5zXbtFQe8qam4dM(KyKLOuoGm9an3zkK8bPqnGFWHMnmpnitXsAUuEaGKfzoaZpxDjGOtNn91HAk2gQcKIH(0CyJmjImhG5NRUeq0PZM(6qnfBdvbsXqF2tjLditpq1bPqnGFWHMni9x5kNsEcDTwqxG1ktdq3Vw4S2jGORwUwJ8dJgWO2lG(F8QTLrT9WVFaz38A)qcgJANhu8V2lR96WAVVSwkOdCyTI(IbwlGFWrTFyT24vlxBh0URw0ta7UAd2)xB2Q1isqOD)sEwCW0Nkbpead(GPpjgzjkLditpqZDMcjFqkud4hCOzdZtdYuSKMlLhai5lG(F8uZeymW7GUToaO7RezoaZpxfifd9P5Wgzr6GaWtXHGDuBeji0UVjr6GaWtXHGDuBeji0UVky))VsGjShaanmqq1mbgd8oOBRda6(MePu0z)u)7hq2nfao2YWgvCiyh1qVbD41VKNqxlHksWyulio4(12BE94AbmQ9YALRCMOO2wg12Z)yjploy6tLGhcGbFW0NeJSeLYbKPhO5otHK7Ybi0T1xEuMNgKN4zUuEaGKfzoaZpxDjGOtNn91HAk2gQcKb7BskhqMEGQdsHAa)GdnB8RCLtjpHUwzAgeY(vRLbh)RfmXzTEE1cPOqqiF4OFTgaxTag1EDyTsbgogmnCaV(1cI0aTwTZSw4vRG9APXAbHTguamUAVSwq4uGHx71XxTFibbwlF1EDyTekWiVUALcmCmyA4aE9RDES4Fjploy6tLGhcGbFW0NeJSeLYbKPhO5otHK7PbMNgyIG6Pbh)npnipXZCP8aajtIrGs12cqLSQGbHSF6Pbh)jIiJaLQTfGk5QcgeY(PNgC8NiImcuQ2waQKqvWGq2p90GJ)KAcePbAnvWGq2p90GJ)APadhdMgoGxFfy(5L8S4GPpvcEiag8btFsmYsukhqMEGM7mfsobUjee1ztlYCaMF(080G8epZLYdaKmnqRP4qWoQnYpmuG5NBIgO1ubGJ6SPnYpmuG5NBcePbAn1LaIoD20xhQPyBOcm)Ct)ukhqMEGQEAG5PbMiOEAWXFtGinqRPcgeY(PNgC8xlfy4yW0Wb86RaZpVKNfhm9PsWdbWGpy6tIrwIs5aY0d0CNPqYZJf)1DCqLEFZtdYt8mxkpaqYbGJTmSrfhc2rn0BqhE9nrcjIuk6SFQ)9di7MezoaZpxfmiK9tpn44Vkqkg6ZFLYbKPhOQJdQ07RNhl(RpifskPL8L8e6A)XaMb8GekWAbMq3Uw7aoh9RfkGIbw7h86QLnu12dnXAHxTFWRR2lpQAZRdJp4evL8S4GPpvImhG5Npj3ICEApLYMdBKdahBzyJk7aoh91qbumqtImhG5NR4qWoQnYpmubsXqFAwjuoMezoaZpxDjGOtNn91HAk2gQcKb7BIeAGwtXHGDul64WgvZJf))LSuoGm9avxEuAkwsTOJdBCAIesoEG(Pcah1ztBKFyysK5am)Cva4OoBAJ8ddvGum0N)s2waAsK5am)Cfhc2rTr(HHkqkg6tZkLditpq1LhLMILudIdUVULHMniLiIi5Nhpq)ubGJ6SPnYpmmjYCaMFUIdb7O2i)Wqfifd9PzLYbKPhO6YJstXsQbXb3x3YqZgKserImhG5NR4qWoQnYpmubsXqF(lzBbiPKwYZIdM(ujYCaMF(KyKLylY5P9ukBoSroaCSLHnQSd4C0xdfqXanjYCaMFUIdb7O2i)Wqfid23ej)84b6Nc9b0U7qhbjIisoEG(PqFaT7o0rqtuSZkdXzwY)a5qkPMiHerMdW8Zvxci60ztFDOMITHQaPyOpnRSYXenqRP4qWoQfDCyJQ5XI)KPbAnfhc2rTOJdBurXsQNhl(tkrerIiZby(5QlbeD6SPVoutX2qvGum0NKLJjAGwtXHGDul64WgvZJf)jlhsj1enqRPcah1ztBKFyOaZp3ef7SYqCMLSuoGm9avSHMc6qkaknf7S2qCL8S4GPpvImhG5Npjgzj2ICE054mh2ihao2YWgvGWPaAmGoh91IKIIDqtImhG5NRObAnniCkGgdOZrFTiPOyhufid23enqRPaHtb0yaDo6Rfjff7G6wKZtbMFUjsObAnfhc2rTr(HHcm)Ct0aTMkaCuNnTr(HHcm)CtGinqRPUeq0PZM(6qnfBdvG5NtQjrMdW8Zvxci60ztFDOMITHQaPyOpjlhtKqd0AkoeSJArhh2OAES4)VKLYbKPhO6YJstXsQfDCyJttKqYXd0pva4OoBAJ8ddtImhG5NRcah1ztBKFyOcKIH(8xY2cqtImhG5NR4qWoQnYpmubsXqFAwPCaz6bQU8O0uSKAqCW91Tm0SbPerej)84b6NkaCuNnTr(HHjrMdW8ZvCiyh1g5hgQaPyOpnRuoGm9avxEuAkwsnio4(6wgA2GuIisK5am)Cfhc2rTr(HHkqkg6ZFjBlajL0sEwCW0NkrMdW8ZNeJSeBWa10dEEMdBKdahBzyJkq4uangqNJ(ArsrXoOjrMdW8Zv0aTMgeofqJb05OVwKuuSdQcKb7BIgO1uGWPaAmGoh91IKIIDqDdgOcm)CtgbkvBlavYQArop6CCL8e6A)rgg12JZER9dED12Z)yTWwTWJGzTIKc621cyu7mtxv7pSvl8Q9dog1sJ1cmrWA)GxxT9Mxp28Af88QfE1ohq7UB0VwASLbwYZIdM(ujYCaMF(KyKLifmImM6SPVmOq)mh2ilYCaMFU6sarNoB6Rd1uSnufifd95Vs5aY0durLN2iqbIG6lpknDFIiIePCaz6bQoifQb8do0SHzLYbKPhOIkpnflPgehCFDldnBysK5am)C1LaIoD20xhQPyBOkqkg6tZkLditpqfvEAkwsnio4(6wg6lpksl5zXbtFQezoaZpFsmYsKcgrgtD20xguOFMdBKfzoaZpxXHGDuBKFyOcKb7BIKFE8a9tH(aA3DOJGerejhpq)uOpG2Dh6iOjk2zLH4ml5FGCiLutKqIiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGk2qtXsQbXb3x3YqF5rzIgO1uCiyh1IooSr18yXFY0aTMIdb7Ow0XHnQOyj1ZJf)jLiIirK5am)C1LaIoD20xhQPyBOkqkg6tYYXenqRP4qWoQfDCyJQ5XI)KLdPKAIgO1ubGJ6SPnYpmuG5NBIIDwzioZswkhqMEGk2qtbDifaLMIDwBiUsEcDT984J7pRfyI1cI81rNHJ1(bVUAzdvT)WwTxEu1cN1gid2VwEw7hogMxlf)hRDceyTxwRGNxTWRwASLbw7LhLQKNfhm9PsK5am)8jXilrqKVo6mC0CyJSiZby(5QlbeD6SPVoutX2qvGmyFt0aTMIdb7Ow0XHnQMhl()lzPCaz6bQU8O0uSKArhh240KiZby(5koeSJAJ8ddvGum0N)s2wawYZIdM(ujYCaMF(KyKLiiYxhDgoAoSrwK5am)Cfhc2rTr(HHkqgSVjs(5Xd0pf6dOD3HocserKC8a9tH(aA3DOJGMOyNvgIZSK)bYHusnrcjImhG5NRUeq0PZM(6qnfBdvbsXqFAwzLJjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw8NuIiIerMdW8Zvxci60ztFDOMITHQazW(MObAnfhc2rTOJdBunpw8NSCiLut0aTMkaCuNnTr(HHcm)CtuSZkdXzwYs5aY0duXgAkOdPaO0uSZAdXvYtORThAI1on44FTWwTxEu1YoyTSrTCG1METcWAzhS2V0j4QLgRfWO2wg1os3gJAVo2R96WAPyjRfehCFZRLI)dD7ANabw7hwBhlfRLVAhipVAVVSwoeSJ1k64WgN1YoyTxhF1E5rv7hpDcUA7PbMxTateuvYZIdM(ujYCaMF(KyKLyWGq2p90GJ)MdBKfzoaZpxDjGOtNn91HAk2gQcKIH(0Ss5aY0duftnflPgehCFDld9LhLjrMdW8ZvCiyh1g5hgQaPyOpnRuoGm9avXutXsQbXb3x3YqZgMi54b6NkaCuNnTr(HHjsezoaZpxfaoQZM2i)Wqfifd95VOKOa4q9bPqIisK5am)Cva4OoBAJ8ddvGum0NMvkhqMEGQyQPyj1G4G7RBzOJ0GuIi6Nhpq)ubGJ6SPnYpmi1enqRP4qWoQfDCyJQ5XI)MvUMarAGwtDjGOtNn91HAk2gQaZp3enqRPcah1ztBKFyOaZp3enqRP4qWoQnYpmuG5NxYtORThAI1on44FTFWRRw2O2Vo0R1iNti9av1(dB1E5rvlCwBGmy)A5zTF4yyETu8FS2jqG1EzTcEE1cVAPXwgyTxEuQsEwCW0NkrMdW8ZNeJSedgeY(PNgC83CyJSiZby(5QlbeD6SPVoutX2qvGum0N)IsIcGd1hKcnrd0AkoeSJArhh2OAES4)VKLYbKPhO6YJstXsQfDCyJttImhG5NR4qWoQnYpmubsXqF(ljOKOa4q9bPqIXIdMU6sarNoB6Rd1uSnuHsIcGd1hKcjTKNfhm9PsK5am)8jXilXGbHSF6Pbh)nh2ilYCaMFUIdb7O2i)Wqfifd95VOKOa4q9bPqtKqYppEG(PqFaT7o0rqIiIKJhOFk0hq7UdDe0ef7SYqCML8pqoKsQjsirK5am)C1LaIoD20xhQPyBOkqkg6tZkLditpqfBOPyj1G4G7RBzOV8Omrd0AkoeSJArhh2OAES4pzAGwtXHGDul64WgvuSK65XI)KserKiYCaMFU6sarNoB6Rd1uSnufifd9jz5yIgO1uCiyh1IooSr18yXFYYHusnrd0AQaWrD20g5hgkW8ZnrXoRmeNzjlLditpqfBOPGoKcGstXoRnehPL8e6A7HMyTxEu1(bVUAzJAHTAHhbZA)Gxh0R96WAPyjRfehCFvT)WwTEEMxlWeR9dED1gPrTWwTxhw7Xd0VAHZAp(p6Mxl7G1cpcM1(bVoOx71H1sXswlio4(QsEwCW0NkrMdW8ZNeJSeVeq0PZM(6qnfBdnh2itd0AkoeSJArhh2OAES4)VKLYbKPhO6YJstXsQfDCyJttImhG5NR4qWoQnYpmubsXqF(lzusuaCO(GuOjk2zLH4mRuoGm9avSHMc6qkaknf7S2qCMObAnva4OoBAJ8ddfy(5L8S4GPpvImhG5NpjgzjEjGOtNn91HAk2gAoSrMgO1uCiyh1IooSr18yX)FjlLditpq1LhLMILul64WgNMoEG(Pcah1ztBKFyysK5am)Cva4OoBAJ8ddvGum0N)sgLefahQpifAskhqMEGQdsHAa)GdnBywPCaz6bQU8O0uSKAqCW91Tm0Srjploy6tLiZby(5tIrwIxci60ztFDOMITHMdBKPbAnfhc2rTOJdBunpw8)xYs5aY0duD5rPPyj1IooSXPjs(5Xd0pva4OoBAJ8ddIisK5am)Cva4OoBAJ8ddvGum0NMvkhqMEGQlpknflPgehCFDldDKgKAskhqMEGQdsHAa)GdnBywPCaz6bQU8O0uSKAqCW91Tm0SrjpHU2EOjwlBulSv7LhvTWzTPxRaSw2bR9lDcUAPXAbmQTLrTJ0TXO2RJ9AVoSwkwYAbXb338AP4)q3U2jqG1ED8v7hwBhlfRf9eWURwk25AzhS2RJVAVomWAHZA98QLhbYG9RLRnaCS2SvRr(HrTG5NRk5zXbtFQezoaZpFsmYsKdb7O2i)WWCyJSiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGk2qtXsQbXb3x3YqF5rzIKFksPOZ(PKI(11piIirMdW8ZvuWiYyQZM(YGc9tfifd9PzLYbKPhOIn0uSKAqCW91Tm0u5rQjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83enqRPcah1ztBKFyOaZp3ef7SYqCMLSuoGm9avSHMc6qkaknf7S2qCL8e6A7HMyTrAulSv7LhvTWzTPxRaSw2bR9lDcUAPXAbmQTLrTJ0TXO2RJ9AVoSwkwYAbXb338AP4)q3U2jqG1EDyG1cNobxT8iqgSFTCTbGJ1cMFETSdw71XxTSrTFPtWvlnkskSwwkdhm9aRfeiGUDTbGJQsEwCW0NkrMdW8ZNeJSedah1ztBKFyyoSrMgO1uCiyh1g5hgkW8ZnrIiZby(5QlbeD6SPVoutX2qvGum0NMvkhqMEGQin0uSKAqCW91Tm0xEuerKiZby(5koeSJAJ8ddvGum0N)swkhqMEGQlpknflPgehCFDldnBqQjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83KiZby(5koeSJAJ8ddvGum0NMvw5wYZIdM(ujYCaMF(KyKL4Sd2oOBRnYpmmh2ilLditpqvcCtiiQZMwK5am)8zjpHU2EOjwRrsv7L1o7baisOaRL9ArjVGRLPRf61EDyTok5vRiZby(51(bDW8Z8Ab8boN1(VFazV2Rd9AtF0VwqGa621YHGDSwJ8dJAbbWAVS2U8Rwk25A7aC7OFTbdcz)QDAWX)AHZsEwCW0NkrMdW8ZNeJSencCIUa1zttbDqZHnYhpq)ubGJ6SPnYpmmrd0AkoeSJAJ8ddfGHjAGwtfaoQZM2i)Wqfifd95V2cqfflzjploy6tLiZby(5tIrwIgborxG6SPPGoO5WgzqKgO1uxci60ztFDOMITHkadtGinqRPUeq0PZM(6qnfBdvbsXqF(lloy6koeSJAk4Cch4uHsIcGd1hKcn9trkfD2p1)(bK9sEwCW0NkrMdW8ZNeJSencCIUa1zttbDqZHnY0aTMkaCuNnTr(HHcWWenqRPcah1ztBKFyOcKIH(8xBbOIIL0KiZby(5kuAk4dMUkqgSVjrMdW8Zvxci60ztFDOMITHQaPyOpn9trkfD2p1)(bK9s(sEwCW0NQg05HMgiCYCiyh1uW5eoWP5WgzAGwtjgihcEEq3wfiloZfDm0jlBjploy6tvd68qtdeoXilroeSJA6bpVsEwCW0NQg05HMgiCIrwICiyh10CeSnwYxYtORLqTd9Ada3HUDTi86WO2RdR1YQ2mQTxc1AhOn6GCaXP51(H1(X(v7L1ktjnRLgBzG1EDyT9MxpwI98pw7h0bZpvT9qtSw4vlpRDMPxlpRvMo)XA74zTnOdNDiyTjqu7hsGuS2Pb6xTjquROJdBCwYZIdM(u1GZoOBRtd0XGmknf8bt3CyJmjbGJTmSr1HugzWd9hhgerejbGJTmSr1eA0LUEEzqz6Ns5aY0duzeObWyOrPjzzjLutKqd0AQaWrD20g5hgkW8ZjIiJaLQTfGkzvCiyh10CeSnsQjrMdW8ZvbGJ6SPnYpmubsXqFwYtOR9h2Q9djqkwBd6WzhcwBce1kYCaMFETFqhm)M1YoyTtd0VAtGOwrhh2408AncygWdsOaRvMsAwBkfJArPy0)6GUDT4yIL8S4GPpvn4Sd6260aDmigzjIstbFW0nh2iF8a9tfaoQZM2i)WWKiZby(5QaWrD20g5hgQaPyOpnjYCaMFUIdb7O2i)Wqfifd9PjAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOaZp3KrGs12cqLSkoeSJAAoc2gl5zXbtFQAWzh0T1Pb6yqmYsSbdutp45zoSroaCSLHnQaHtb0yaDo6Rfjff7GMObAnfiCkGgdOZrFTiPOyhu3ICEkaJsEwCW0NQgC2bDBDAGogeJSeBropTNszZHnYbGJTmSrLDaNJ(AOakgOjk2zLH4mBprck5zXbtFQAWzh0T1Pb6yqmYsKdb7OMcoNWbonh2ihao2YWgvCiyh1qVbD413enqRP4qWoQ74Gk9(Q5XI))sd0AkoeSJ6ooOsVVIILuppw83ejKqd0AkoeSJAJ8ddfy(5MezoaZpxXHGDuBKFyOcKb7tkrebI0aTM6sarNoB6Rd1uSnubyqQ5Iog6KLTKNfhm9PQbNDq3wNgOJbXilXaWrD20g5hgMdBKdahBzyJQj0OlD98YGQKNfhm9PQbNDq3wNgOJbXilroeSJ6mOnh2ilYCaMFUkaCuNnTr(HHkqgSFjploy6tvdo7GUTonqhdIrwICiyh10dEEMdBKfzoaZpxfaoQZM2i)Wqfid23enqRP4qWoQfDCyJQ5XI))sd0AkoeSJArhh2OIILuppw8VKNfhm9PQbNDq3wNgOJbXilrqKVo6mC0CyJ8pdahBzyJQdPmYGh6pomiIir6GaWtzdBNoB6Rd1dOORKNfhm9PQbNDq3wNgOJbXilXaWrD20g5hgL8e6A)HTA)qccSw(QLILS25XI)ZAZwTecHul7G1(H12XsrNGRwGjcwBpo7T2(4zETatSwU25XI)1EzTgbkf9Rwkax0bD7Ab8boN1gaUdD7AVoSwcL5Gk9(1oqB0b5OFjploy6tvdo7GUTonqhdIrwICiyh1uW5eoWP5WgzAGwtjgihcEEq3wfilot0aTMsmqoe88GUTAES4pzAGwtjgihcEEq3wrXsQNhl(BsKsrN9tjf9RRFysK5am)CffmImM6SPVmOq)ubYG9n9tPCaz6bQqkJ8ddeutZrW2OjrMdW8ZvCiyh1g5hgQazW(L8e6AjEgu8y0V2pSwdgg1AKhm9AbMyTFWRR2E(hnVwAGRw4v7hCmQDWZR2r621IEcy3vBlJAPZRR2RdRvMo)XAzhS2E(hR9d6G53SwaFGZzTbG7q3U2RdR1YQ2mQTxc1AhOn6GCaXzjploy6tvdo7GUTonqhdIrwIg5bt3CyJ8pdahBzyJQdPmYGh6pommrYpdahBzyJQj0OlD98YGIiIKYbKPhOYiqdGXqJstYYsAjploy6tvdo7GUTonqhdIrwIGiFD0z4O5WgzAGwtfaoQZM2i)WqbMForezeOuTTaujRIdb7OMMJGTXsEwCW0NQgC2bDBDAGogeJSedgeY(PNgC83CyJmnqRPcah1ztBKFyOaZpNiImcuQ2waQKvXHGDutZrW2yjploy6tvdo7GUTonqhdIrwIuWiYyQZM(YGc9ZCyJmnqRPcah1ztBKFyOcKIH(8xsKzetU9OaWXwg2OAcn6sxpVmOiTKNqxlHAh61gaUdD7AVoSwcL5Gk9(1oqB0b5OV51cmXA75FSwASLbwBV51JR9YAbbOmQLRTbmg9RDES4pcwlnhCyJL8S4GPpvn4Sd6260aDmigzjYHGDuBKFyyoSrwkhqMEGkKYi)Wab10CeSnAIgO1ubGJ6SPnYpmuagMiHIDwziUFjrUsaXirw50JePu0z)u)7hq2jLuIiIgO1uIbYHGNh0TvZJf)jtd0AkXa5qWZd62kkws98yXFsl5zXbtFQAWzh0T1Pb6yqmYsKdb7OMMJGTrZHnYs5aY0duHug5hgiOMMJGTrt0aTMIdb7Ow0XHnQMhl(tMgO1uCiyh1IooSrfflPEES4VjAGwtXHGDuBKFyOamk5zXbtFQAWzh0T1Pb6yqmYs8sarNoB6Rd1uSn0CyJmnqRPcah1ztBKFyOaZpNiImcuQ2waQKvXHGDutZrW2irezeOuTTaujRkyqi7NEAWXFIiYiqPABbOswfiYxhDgowYZIdM(u1GZoOBRtd0XGyKLihc2rTr(HH5WgzJaLQTfGkzvxci60ztFDOMITHL8e6A7HMyT)y2JR9YAN9aaejuG1YETOKxW12ZHGDSwcp45vliqaD7AVoS2EZRhlXE(hR9d6G5xTa(aNZAda3HUDT9CiyhRvMs0LQA)HTA75qWowRmLOlRfoR94b6hcAETFyTc2j4QfyI1(JzpU2p41b9AVoS2EZRhlXE(hR9d6G5xTa(aNZA)WAH(HrayC1EDyT9CpUwrh7oomV2zw7hsWyu7KLI1cpvjploy6tvdo7GUTonqhdIrwIgborxG6SPPGoO5Wg5FE8a9tXHGDuJIU0eisd0AQlbeD6SPVoutX2qfGHjqKgO1uxci60ztFDOMITHQaPyOp)LmjS4GPR4qWoQPh88uOKOa4q9bPWEenqRPmcCIUa1zttbDqfflPEES4pPL8e6A)HTA)XShxBhpDcUAPr0RfyIG1cceq3U2RdRT386X1(bDW8Z8A)qcgJAbMyTWR2lRD2daqKqbwl71IsEbxBphc2XAj8GNxTqV2RdRvMo)rj2Z)yTFqhm)uL8S4GPpvn4Sd6260aDmigzjAe4eDbQZMMc6GMdBKPbAnfhc2rTr(HHcWWenqRPcah1ztBKFyOcKIH(8xYKWIdMUIdb7OMEWZtHsIcGd1hKc7r0aTMYiWj6cuNnnf0bvuSK65XI)KwYZIdM(u1GZoOBRtd0XGyKLihc2rn9GNN5WgzW8ubdcz)0tdo(RcKIH(0SsarebI0aTMkyqi7NEAWXFTuGHJbtdhWRVAES4VzLtjpHUwcvS2p2VAVSwk(pw7eiWA)WA7yPyTONa2D1sXoxBlJAVoSw0pyG12Z)yTFqhm)mVwuk61cB1EDyGemRDEWXO2dsH1gifdDOBxB61ktN)OQ2F4rWS20h9RLgVdJAVSwAGWR9YAjuGrwl7G1ktjnRf2QnaCh621EDyTww1MrT9sOw7aTrhKdiovL8S4GPpvn4Sd6260aDmigzjYHGDutZrW2O5WgzrMdW8ZvCiyh1g5hgQazW(MOyNvgI7xsKjYHyKiRC6rIuk6SFQ)9di7KsQjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83ej)maCSLHnQMqJU01ZldkIiskhqMEGkJanagdnknjllPM(za4yldBuDiLrg8q)XHHPFgao2YWgvCiyh1qVbD41VKNqxlH5iyBS2zxcmaR1ZRwASwGjcwlF1EDyTOdwB2QTN)XAHTALPKMc(GPxlCwBGmy)A5zTGrAyaD7AfDCyJZA)GJrTu8FSw4v7X)XAhPBJrTxwlnq41EDrcy3vBGum0HUDTuSZL8S4GPpvn4Sd6260aDmigzjYHGDutZrW2O5WgzAGwtXHGDuBKFyOammrd0AkoeSJAJ8ddvGum0N)s2waAsK5am)Cfknf8btxfifd9zjpHUwcZrW2yTZUeyawlp(4(ZAPXAVoS2bpVAf88Qf61EDyTY05pw7h0bZVA5zT9MxpU2p4yuBGZldS2RdRv0XHnoRDAG(vYZIdM(u1GZoOBRtd0XGyKLihc2rnnhbBJMdBKPbAnva4OoBAJ8ddfGHjAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOcKIH(8xY2cqt)maCSLHnQ4qWoQHEd6WRFjploy6tvdo7GUTonqhdIrwICiyh1uW5eoWP5WgzqKgO1uxci60ztFDOMITHkadthpq)uCiyh1OOlnrcnqRPar(6OZWrfy(5ereloOuuJosbXjzzj1eisd0AQlbeD6SPVoutX2qvGum0NMLfhmDfhc2rnfCoHdCQqjrbWH6dsHMl6yOtwwZrog91Iog6AyJmnqRPedKdbppOBRfDS74qbMFUjsObAnfhc2rTr(HHcWGiIi5Nhpq)uPummYpmqqtKqd0AQaWrD20g5hgkadIisK5am)Cfknf8btxfid2NusjTKNqx7pSv7hsqG1kf9RRFyETqkkeeYho6xlWeRLqiKA)6qVwbByGG1EzTEE1(XZdR1isXS2wKu12JZEl5zXbtFQAWzh0T1Pb6yqmYsKdb7OMcoNWbonh2ilsPOZ(PKI(11pmrd0AkXa5qWZd62Q5XI)KPbAnLyGCi45bDBfflPEES4FjpHUwRJJRwGj0TRLqiKA75ECTFDOxBp)J12XZAPr0RfyIGL8S4GPpvn4Sd6260aDmigzjYHGDutbNt4aNMdBKPbAnLyGCi45bDBvGS4mjYCaMFUIdb7O2i)Wqfifd9PjsObAnva4OoBAJ8ddfGbrerd0AkoeSJAJ8ddfGbPMl6yOtw2sEwCW0NQgC2bDBDAGogeJSe5qWoQZG2CyJmnqRP4qWoQfDCyJQ5XI))swkhqMEGQlpknflPw0XHnol5zXbtFQAWzh0T1Pb6yqmYsKdb7OMEWZZCyJmnqRPcah1ztBKFyOamiIik2zLH4mRSsqjploy6tvdo7GUTonqhdIrwIO0uWhmDZHnY0aTMkaCuNnTr(HHcm)Ct0aTMIdb7O2i)WqbMFU5q)WiamonSrMIDwzioZswMlbMd9dJaW40qkkeeYhsw2sEwCW0NQgC2bDBDAGogeJSe5qWoQP5iyBSKVKNqtORThYNaggzCiyTc2f4qZIdMEpCxRmL0uWhm9A)GJrT0yToFabpg9RLoY)OxlSvRiDq4btFwlhyTu4Pk5j0e6AzXbtFQ64Gk9(KfSlWHMfhmDZHnYS4GPRqPPGpy6krh7ooGUTjk2zLH4ml5EIeuYtOR9h2QDKF1METuSZ1YoyTImhG5NpRLdSwrsbD7AbmmVw7SwUdzWAzhSwuAwYZIdM(u1Xbv69jgzjIstbFW0nh2itXoRme3VKLq5yskhqMEGQe4MqquNnTiZby(5ttKC8a9tfaoQZM2i)WWKiZby(5QaWrD20g5hgQaPyOp)vw5qAjpHUwcvS2p2VAVS25XI)12Xbv69RTbmg9v12BhwlWeRnB1kRmR25XI)ZA7WaRfoR9YAzHib8R2wg1EDyThu8V2b2UAtV2RdRv0XUJJAzhS2RdRLcoNWbwl0RTnG2DNQKNfhm9PQJdQ07tmYsKdb7OMcoNWbonh2itIuoGm9avZJf)1DCqLEFIi6Gu4VYkhsnrd0AkoeSJ6ooOsVVAES4)VYkZmx0XqNSSL8e6Aju7qVwGj0TRvMIYOFG8O2EybOZUanVwbpVA5AB4xTOKxW1sbNt4aN1(1bhyTFm8GUDTTmQ96WAPbATA5R2RdRDECC1MTAVoS2g0U7k5zXbtFQ64Gk9(eJSe5qWoQPGZjCGtZHnYypaaAyGGkKYOFG8qNbOZUanDqk8xjuoMU02EGkrMdW8ZNMezoaZpxHug9dKh6maD2fOkqkg6tZkRmtMxYZIdM(u1Xbv69jgzjgmiK9tpn44V5WgzPCaz6bQqkJ8ddeutZrW2OjrMdW8Zvxci60ztFDOMITHQaPyOp)LmkjkaouFqk0KiZby(5koeSJAJ8ddvGum0N)sMeusuaCO(GuypsUKAIKFI9aaOHbcQMjWyG3bDBDaq3NiIePdcapfhc2rTrKGq7(QG9)MLSeqerxa9)4PMjWyG3bDBDaq3xjYCaMFUkqkg6ZFjtckjkaouFqkShjxsjTKNfhm9PQJdQ07tmYs8sarNoB6Rd1uSn0CyJSuoGm9av90aZtdmrq90GJ)MezoaZpxXHGDuBKFyOcKIH(8xYOKOa4q9bPqtK8tShaanmqq1mbgd8oOBRda6(erKiDqa4P4qWoQnIeeA3xfS)3SKLaIi6cO)hp1mbgd8oOBRda6(krMdW8ZvbsXqF(lzusuaCO(GuiPL8S4GPpvDCqLEFIrwICiyh1g5hgMdBKncuQ2waQKvDjGOtNn91HAk2gwYZIdM(u1Xbv69jgzjgaoQZM2i)WWCyJSuoGm9aviLr(HbcQP5iyB0KiZby(5QGbHSF6Pbh)vbsXqF(lzusuaCO(GuOjPCaz6bQoifQb8do0SHzjlx5yIKFksheaEkoeSJAJibH29jIOFkLditpqfp(4(t9SVl0ImhG5NpjIirMdW8Zvxci60ztFDOMITHQaPyOp)LmjOKOa4q9bPWEKCjL0sEwCW0NQooOsVpXilXGbHSF6Pbh)nh2ilLditpqfszKFyGGAAoc2gnzeOuTTaujRkaCuNnTr(Hrjploy6tvhhuP3NyKL4LaIoD20xhQPyBO5WgzPCaz6bQ6PbMNgyIG6Pbh)n9tPCaz6bQ6Ybi0T1xEuL8S4GPpvDCqLEFIrwIbGJ6SPnYpmmh2itd0AkoeSJAJ8ddfy(5MirkhqMEGQdsHAa)GdnBywjuoerKiZby(5QGbHSF6Pbh)vbsXqFAwzLlPMi5NI0bbGNIdb7O2isqODFIi6Ns5aY0duXJpU)up77cTiZby(5tsl5zXbtFQ64Gk9(eJSedgeY(PNgC83CyJSuoGm9aviLr(HbcQP5iyB0ej0aTMIdb7Ow0XHnQMhl(BwYYLiIezoaZpxXHGDuNbTkqgSpPMi5Nhpq)ubGJ6SPnYpmiIirMdW8ZvbGJ6SPnYpmubsXqFAwjGuts5aY0duHZdsXhcQzdTiZby(5MLSekhtK8tr6GaWtXHGDuBeji0Upre9tPCaz6bQ4Xh3FQN9DHwK5am)8jPL8e6Aju7qV2aWDOBxRrKGq7(MxlWeR9YJQw6(1cVjoA1c9AZaeJAVSwEaT9AHxTFWRRw2OKNfhm9PQJdQ07tmYs8sarNoB6Rd1uSn0CyJSuoGm9avhKc1a(bhA24xjqoMKYbKPhO6GuOgWp4qZgMvcLJjs(j2daGggiOAMaJbEh0T1baDFIisKoia8uCiyh1grccT7Rc2)BwYsaPL8S4GPpvDCqLEFIrwICiyh1zqBoSrwkhqMEGQEAG5PbMiOEAWXFt0aTMIdb7Ow0XHnQMhl()lnqRP4qWoQfDCyJkkws98yX)sEwCW0NQooOsVpXilroeSJAAoc2gnh2idI0aTMkyqi7NEAWXFTuGHJbtdhWRVAES4pzqKgO1ubdcz)0tdo(RLcmCmyA4aE9vuSK65XI)L8S4GPpvDCqLEFIrwICiyh10dEEMdBKLYbKPhOQNgyEAGjcQNgC8NiIibePbAnvWGq2p90GJ)APadhdMgoGxFfGHjqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf))fePbAnvWGq2p90GJ)APadhdMgoGxFfflPEES4pPL8e6A7HMyTzqxB61kaRfWh4CwlBulCwRiPGUDTag1oZ0l5zXbtFQ64Gk9(eJSe5qWoQZG2CyJmnqRP4qWoQfDCyJQ5XI))kHMKYbKPhO6GuOgWp4qZgMvw5uYZIdM(u1Xbv69jgzjYHGDutbNt4aNMdBKPbAnLyGCi45bDBvGS4mrd0AkoeSJAJ8ddfGH5Iog6KLTKNqx7pSv7hwRnE1AKFyul0Baty61cceq3U2bW8Q9djymQTJLI1IEcy3vBhppS2lR1gVAZwRwU25fPBxlnhbBJ1cceq3U2RdRnsdjYg1(bDW8RKNfhm9PQJdQ07tmYsKdb7OMMJGTrZHnY0aTMkaCuNnTr(HHcWWenqRPcah1ztBKFyOcKIH(8xYS4GPR4qWoQPGZjCGtfkjkaouFqk0enqRP4qWoQnYpmuagMObAnfhc2rTOJdBunpw8NmnqRP4qWoQfDCyJkkws98yXFt0aTMIdb7OUJdQ07RMhl(BIgO1ug5hgAO3aMW0vagMObAnf9itWbW8uagL8e6A)HTA)WATXRwJ8dJAHEdyctVwqGa621oaMxTFibJrTDSuSw0ta7UA745H1EzT24vB2A1Y1oViD7AP5iyBSwqGa621EDyTrAir2O2pOdMFMx7mR9djymQn9r)AbMyTONa2D1sp45nRf6WdYJr)AVSwB8Q9YABjquROJdBCwYZIdM(u1Xbv69jgzjYHGDutp45zoSrMgO1ugborxG6SPPGoOcWWej0aTMIdb7Ow0XHnQMhl()lnqRP4qWoQfDCyJkkws98yXFIi6NKqd0AkJ8ddn0Baty6kadt0aTMIEKj4ayEkadsjTKNqxBVDyT048QfyI1MTAnsQAHZAVSwGjwl8Q9YA7baqX)r)APbGdWAfDCyJZAbbcOBxlBul3omQ96W(1AJxTGaugiyT09R96WA74Gk9(1sZrW2yjploy6tvhhuP3NyKLOrGt0fOoBAkOdAoSrMgO1uCiyh1IooSr18yX)FPbAnfhc2rTOJdBurXsQNhl(BIgO1uCiyh1g5hgkaJsEcDTeQyTFSF1EzTZJf)RTJdQ07xBdym6RQT3oSwGjwB2QvwzwTZJf)N12HbwlCw7L1Ycrc4xTTmQ96WApO4FTdSD1METxhwROJDhh1YoyTxhwlfCoHdSwOxBBaT7ovjploy6tvhhuP3NyKLihc2rnfCoHdCAoSrMgO1uCiyh1DCqLEF18yX)FLvMzUOJHozznh6hgbGXrwwZH(HrayCA7rsZdYYwYZIdM(u1Xbv69jgzjYHGDutZrW2O5WgzAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83KuoGm9aviLr(HbcQP5iyBSKNfhm9PQJdQ07tmYseLMc(GPBoSrMIDwziUFLvck5j012dZh9RfyI1sp45v7L1sdahG1k64WgN1cB1(H1YJazW(12XsXANjfwBlsQAZGUKNfhm9PQJdQ07tmYsKdb7OMEWZZCyJmnqRP4qWoQfDCyJQ5XI)MObAnfhc2rTOJdBunpw8)xAGwtXHGDul64WgvuSK65XI)L8e6A7HhCmQ9dED1Yu1c4dCoRLnQfoRvKuq3UwaJAzhS2pKGaRDKF1METuSZL8S4GPpvDCqLEFIrwICiyh1uW5eoWP5Wg5FsIuoGm9avhKc1a(bhA24xYYkhtuSZkdX9Rekhsnx0XqNSSMd9dJaW4ilR5q)WiamoT9iP5bzzl5j01(Jr2GdCw7h86QDKF1sXZdJ(MxBh0UR2oEEO51MrT051vlf3VwpVA7yPyTONa2D1sXox7L1obmmY4QTl)QLIDUwOFOpHsXAdgeY(v70GJ)1kyVwA08ANzTFibJrTatS2gmWAPh88QLDWABrop6CC1(1HETJ8R20RLIDUKNfhm9PQJdQ07tmYsSbdutp45vYZIdM(u1Xbv69jgzj2ICE054k5l5zXbtFQsd0XGCdgOMEWZZCyJCa4yldBubcNcOXa6C0xlskk2bnrd0Akq4uangqNJ(ArsrXoOUf58uagL8S4GPpvPb6yqmYsSf580EkLnh2ihao2YWgv2bCo6RHcOyGMOyNvgIZS9ejOKNfhm9PknqhdIrwIGiFD0z4yjploy6tvAGogeJSedgeY(PNgC83CyJmf7SYqCMvMiNsEwCW0NQ0aDmigzjsbJiJPoB6ldk0VsEwCW0NQ0aDmigzjo7GTd62AJ8ddZHnY0aTMIdb7O2i)WqbMFUjrMdW8ZvCiyh1g5hgQaPyOpl5zXbtFQsd0XGyKLihc2rDg0MdBKfzoaZpxXHGDuBKFyOcKb7BIgO1uCiyh1IooSr18yX)FPbAnfhc2rTOJdBurXsQNhl(xYZIdM(uLgOJbXilroeSJA6bppZHnYIuk6SFkPOFD9dtImhG5NROGrKXuNn9Lbf6Nkqkg6tZkZLjL8S4GPpvPb6yqmYs8sarNoB6Rd1uSnSKNfhm9PknqhdIrwICiyh1g5hgL8S4GPpvPb6yqmYsmaCuNnTr(HH5WgzAGwtXHGDuBKFyOaZpVKNqxBp0eR9hZECTxw7ShaGiHcSw2RfL8cU2EoeSJ1s4bpVAbbcOBx71H12BE9yj2Z)yTFqhm)QfWh4CwBa4o0TRTNdb7yTYuIUuv7pSvBphc2XALPeDzTWzThpq)qqZR9dRvWobxTatS2Fm7X1(bVoOx71H12BE9yj2Z)yTFqhm)QfWh4Cw7hwl0pmcaJR2RdRTN7X1k6y3XH51oZA)qcgJANSuSw4Pk5zXbtFQsd0XGyKLOrGt0fOoBAkOdAoSr(Nhpq)uCiyh1OOlnbI0aTM6sarNoB6Rd1uSnubyycePbAn1LaIoD20xhQPyBOkqkg6ZFjtcloy6koeSJA6bppfkjkaouFqkShrd0AkJaNOlqD20uqhurXsQNhl(tAjpHU2FyR2Fm7X12XtNGRwAe9AbMiyTGab0TR96WA7nVECTFqhm)mV2pKGXOwGjwl8Q9YAN9aaejuG1YETOKxW12ZHGDSwcp45vl0R96WALPZFuI98pw7h0bZpvjploy6tvAGogeJSencCIUa1zttbDqZHnY0aTMIdb7O2i)WqbyyIgO1ubGJ6SPnYpmubsXqF(lzsyXbtxXHGDutp45PqjrbWH6dsH9iAGwtze4eDbQZMMc6Gkkws98yXFsl5zXbtFQsd0XGyKLihc2rn9GNN5WgzW8ubdcz)0tdo(RcKIH(0SsarebI0aTMkyqi7NEAWXFTuGHJbtdhWRVAES4VzLtjpHU2EE8X9N1syoc2gRLVAVoSw0bRnB12Z)yTFDOxBa4o0TR96WA75qWowlHYCqLE)AhOn6GC0VKNfhm9PknqhdIrwICiyh10CeSnAoSrMgO1uCiyh1g5hgkadt0aTMIdb7O2i)Wqfifd95V2cqtbGJTmSrfhc2rn0BqhE9l5j012ZJpU)SwcZrW2yT8v71H1IoyTzR2RdRvMo)XA)Goy(v7xh61gaUdD7AVoS2EoeSJ1sOmhuP3V2bAJoih9l5zXbtFQsd0XGyKLihc2rnnhbBJMdBKPbAnva4OoBAJ8ddfGHjAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOcKIH(8xY2cqtbGJTmSrfhc2rn0BqhE9l5zXbtFQsd0XGyKLihc2rnfCoHdCAoSrgePbAn1LaIoD20xhQPyBOcWW0Xd0pfhc2rnk6stKqd0AkqKVo6mCubMForeXIdkf1OJuqCswwsnbI0aTM6sarNoB6Rd1uSnufifd9PzzXbtxXHGDutbNt4aNkusuaCO(GuO5Iog6KL1CKJrFTOJHUg2itd0AkXa5qWZd62Arh7oouG5NBIeAGwtXHGDuBKFyOamiIis(5Xd0pvkfdJ8dde0ej0aTMkaCuNnTr(HHcWGiIezoaZpxHstbFW0vbYG9jLusl5zXbtFQsd0XGyKLihc2rnfCoHdCAoSrMgO1uIbYHGNh0TvZJf)jtd0AkXa5qWZd62kkws98yXFtIuk6SFkPOFD9JsEwCW0NQ0aDmigzjYHGDutbNt4aNMdBKPbAnLyGCi45bDBvGS4mjYCaMFUIdb7O2i)Wqfifd9PjsObAnva4OoBAJ8ddfGbrerd0AkoeSJAJ8ddfGbPMl6yOtw2sEwCW0NQ0aDmigzjYHGDuNbT5WgzAGwtXHGDul64WgvZJf))LSuoGm9avxEuAkwsTOJdBCwYZIdM(uLgOJbXilroeSJA6bppZHnY0aTMkaCuNnTr(HHcWGiIOyNvgIZSYkbL8S4GPpvPb6yqmYseLMc(GPBoSrMgO1ubGJ6SPnYpmuG5NBIgO1uCiyh1g5hgkW8Znh6hgbGXPHnYuSZkdXzwYYCjWCOFyeagNgsrHGq(qYYwYZIdM(uLgOJbXilroeSJAAoc2gl5l5j0e6AzXbtFQI84dMozb7cCOzXbt3CyJmloy6kuAk4dMUs0XUJdOBBIIDwzioZsUNibMi5NbGJTmSr1eA0LUEEzqrer0aTMAcn6sxpVmOuZJf)jtd0AQj0OlD98YGsrXsQNhl(tAjpHU2EOjwlknRf2Q9djiWAh5xTPxlf7CTSdwRiZby(5ZA5aRLPtGR2lRLgRfWOKNfhm9PkYJpy6eJSerPPGpy6MdBKPyNvgI7xYs5aY0duHstTH4mrIiZby(5QlbeD6SPVoutX2qvGum0N)sMfhmDfknf8btxHsIcGd1hKcjIirMdW8ZvCiyh1g5hgQaPyOp)Lmloy6kuAk4dMUcLefahQpifserKC8a9tfaoQZM2i)WWKiZby(5QaWrD20g5hgQaPyOp)Lmloy6kuAk4dMUcLefahQpifskPMObAnva4OoBAJ8ddfy(5MObAnfhc2rTr(HHcm)CtGinqRPUeq0PZM(6qnfBdvG5NB6NgbkvBlavYQUeq0PZM(6qnfBdl5zXbtFQI84dMoXilruAk4dMU5Wg5aWXwg2OAcn6sxpVmOmjYCaMFUIdb7O2i)Wqfifd95VKzXbtxHstbFW0vOKOa4q9bPWsEcDTeMJGTXAHTAHhbZApifw7L1cmXAV8OQLDWA)WA7yPyTxM1sXE)AfDCyJZsEwCW0NQip(GPtmYsKdb7OMMJGTrZHnYImhG5NRUeq0PZM(6qnfBdvbYG9nrcnqRP4qWoQfDCyJQ5XI)MvkhqMEGQlpknflPw0XHnonjYCaMFUIdb7O2i)Wqfifd95VKrjrbWH6dsHMOyNvgIZSs5aY0duXgAkOdPaO0uSZAdXzIgO1ubGJ6SPnYpmuG5NtAjploy6tvKhFW0jgzjYHGDutZrW2O5WgzrMdW8Zvxci60ztFDOMITHQazW(MiHgO1uCiyh1IooSr18yXFZkLditpq1LhLMILul64WgNMoEG(Pcah1ztBKFyysK5am)Cva4OoBAJ8ddvGum0N)sgLefahQpifAskhqMEGQdsHAa)GdnBywPCaz6bQU8O0uSKAqCW91Tm0SbPL8S4GPpvrE8btNyKLihc2rnnhbBJMdBKfzoaZpxDjGOtNn91HAk2gQcKb7BIeAGwtXHGDul64WgvZJf)nRuoGm9avxEuAkwsTOJdBCAIKFE8a9tfaoQZM2i)WGiIezoaZpxfaoQZM2i)Wqfifd9PzLYbKPhO6YJstXsQbXb3x3YqhPbPMKYbKPhO6GuOgWp4qZgMvkhqMEGQlpknflPgehCFDldnBqAjploy6tvKhFW0jgzjYHGDutZrW2O5WgzqKgO1ubdcz)0tdo(RLcmCmyA4aE9vZJf)jdI0aTMkyqi7NEAWXFTuGHJbtdhWRVIILuppw83ej0aTMIdb7O2i)WqbMForerd0AkoeSJAJ8ddvGum0N)s2wasQjsObAnva4OoBAJ8ddfy(5erenqRPcah1ztBKFyOcKIH(8xY2cqsl5zXbtFQI84dMoXilroeSJA6bppZHnYs5aY0du1tdmpnWeb1tdo(terKaI0aTMkyqi7NEAWXFTuGHJbtdhWRVcWWeisd0AQGbHSF6Pbh)1sbgogmnCaV(Q5XI))cI0aTMkyqi7NEAWXFTuGHJbtdhWRVIILuppw8N0sEwCW0NQip(GPtmYsKdb7OMEWZZCyJmnqRPmcCIUa1zttbDqfGHjqKgO1uxci60ztFDOMITHkadtGinqRPUeq0PZM(6qnfBdvbsXqF(lzwCW0vCiyh10dEEkusuaCO(Guyjploy6tvKhFW0jgzjYHGDutbNt4aNMdBKbrAGwtDjGOtNn91HAk2gQammD8a9tXHGDuJIU0ej0aTMce5RJodhvG5NterS4Gsrn6ifeNKLLutKaI0aTM6sarNoB6Rd1uSnufifd9PzzXbtxXHGDutbNt4aNkusuaCO(GuirejYCaMFUYiWj6cuNnnf0bvbsXqFserIuk6SFQ)9di7KAUOJHozznh5y0xl6yORHnY0aTMsmqoe88GUTw0XUJdfy(5MiHgO1uCiyh1g5hgkadIiIKFE8a9tLsXWi)WabnrcnqRPcah1ztBKFyOamiIirMdW8ZvO0uWhmDvGmyFsjL0sEcDTes6takS2RdRfL0GDqeSwJ8q)G8OwAGwRwEYg1EzTEE1oYjwRrEOFqEuRrKIzjploy6tvKhFW0jgzjYHGDutbNt4aNMdBKPbAnLyGCi45bDBvGS4mrd0Akusd2brqTrEOFqEOamk5zXbtFQI84dMoXilroeSJAk4Cch40CyJmnqRPedKdbppOBRcKfNjsObAnfhc2rTr(HHcWGiIObAnva4OoBAJ8ddfGbrebI0aTM6sarNoB6Rd1uSnufifd9PzzXbtxXHGDutbNt4aNkusuaCO(GuiPMl6yOtw2sEwCW0NQip(GPtmYsKdb7OMcoNWbonh2itd0AkXa5qWZd62QazXzIgO1uIbYHGNh0TvZJf)jtd0AkXa5qWZd62kkws98yXFZfDm0jlBjpHU2EE8X9N1Er)AVSwA2)xlHqi12YOwrMdW8ZR9d6G53SwAGRwqakJAVoKQwyR2Rd7tqG1Y0jWv7L1IsAadSKNfhm9PkYJpy6eJSe5qWoQPGZjCGtZHnY0aTMsmqoe88GUTkqwCMObAnLyGCi45bDBvGum0N)sMesObAnLyGCi45bDB18yX)Eeloy6koeSJAk4Cch4uHsIcGd1hKcjLy2cqffljPMl6yOtw2sEwCW0NQip(GPtmYs0XRdd9Hug48mh2itsGTaNDm9ajIOFEqXFOBtQjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83enqRP4qWoQnYpmuG5NBcePbAn1LaIoD20xhQPyBOcm)8sEwCW0NQip(GPtmYsKdb7OodAZHnY0aTMIdb7Ow0XHnQMhl()lzPCaz6bQU8O0uSKArhh24SKNfhm9PkYJpy6eJSeNagy4Pu2CyJSuoGm9avjWnHGOoBArMdW8ZNMOyNvgI7xY9ejOKNfhm9PkYJpy6eJSe5qWoQPh88mh2itd0AQayG6SPVUaXPcWWenqRP4qWoQfDCyJQ5XI)Mvcl5j012dhakJAfDCyJZAHTA)WAB8yulnoYVAVoSwr6tmKI1sXox71f4SlhG1YoyTO0uWhm9AHZANhCmQn9AfzoaZpVKNfhm9PkYJpy6eJSe5qWoQP5iyB0CyJ8pdahBzyJQj0OlD98YGYKuoGm9avjWnHGOoBArMdW8ZNMObAnfhc2rTOJdBunpw8NmnqRP4qWoQfDCyJkkws98yXFthpq)uCiyh1zqBsK5am)Cfhc2rDg0QaPyOp)LSTa0ef7SYqC)sUNihtImhG5NRqPPGpy6QaPyOpl5zXbtFQI84dMoXilroeSJAAoc2gnh2ihao2YWgvtOrx665LbLjPCaz6bQsGBcbrD20ImhG5Npnrd0AkoeSJArhh2OAES4pzAGwtXHGDul64WgvuSK65XI)MoEG(P4qWoQZG2KiZby(5koeSJ6mOvbsXqF(lzBbOjk2zLH4(LCproMezoaZpxHstbFW0vbsXqF(RekNsEcDT9WbGYOwrhh24SwyR2mORfoRnqgSFjploy6tvKhFW0jgzjYHGDutZrW2O5WgzPCaz6bQsGBcbrD20ImhG5Npnrd0AkoeSJArhh2OAES4pzAGwtXHGDul64WgvuSK65XI)MoEG(P4qWoQZG2KiZby(5koeSJ6mOvbsXqF(lzBbOjk2zLH4(LCproMezoaZpxHstbFW0vbsXqFwYtORTNdb7yTeMJGTXANDjWaSwB0XGhJ(1sJ1EDyTdEE1k45vB2Q96WA75FS2pOdMFL8S4GPpvrE8btNyKLihc2rnnhbBJMdBKPbAnfhc2rTr(HHcWWenqRP4qWoQnYpmubsXqF(lzBbOjAGwtXHGDul64WgvZJf)jtd0AkoeSJArhh2OIILuppw83ejImhG5NRqPPGpy6QaPyOpjIOaWXwg2OIdb7Og6nOdV(KwYtORTNdb7yTeMJGTXANDjWaSwB0XGhJ(1sJ1EDyTdEE1k45vB2Q96WALPZFS2pOdMFL8S4GPpvrE8btNyKLihc2rnnhbBJMdBKPbAnva4OoBAJ8ddfGHjAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOcKIH(8xY2cqt0aTMIdb7Ow0XHnQMhl(tMgO1uCiyh1IooSrfflPEES4VjsezoaZpxHstbFW0vbsXqFserbGJTmSrfhc2rn0BqhE9jTKNqxBphc2XAjmhbBJ1o7sGbyT0yTxhw7GNxTcEE1MTAVoS2EZRhx7h0bZVAHTAHxTWzTEE1cmrWA)GxxTY05pwBg12Z)yjploy6tvKhFW0jgzjYHGDutZrW2O5WgzAGwtXHGDuBKFyOaZp3enqRPcah1ztBKFyOaZp3eisd0AQlbeD6SPVoutX2qfGHjqKgO1uxci60ztFDOMITHQaPyOp)LSTa0enqRP4qWoQfDCyJQ5XI)KPbAnfhc2rTOJdBurXsQNhl(xYtORLqTd9AVoS2JdB8QfoRf61IsIcGdRny3gRLDWAVomWAHZAPYaR96yV20XArhP6BETatSwAoc2gRLN1oZ0RLN12pbQTJLI1IEcy3vROJdBCw7L12bVA5XOw0rkioRf2Q96WA75qWowlHtkAoaPq)QDG2OdYr)AHZAXEaa0Wabl5zXbtFQI84dMoXilroeSJAAoc2gnh2ilLditpqfszKFyGGAAoc2gnrd0AkoeSJArhh2OAES4VzjtcloOuuJosbXzpLSKAIfhukQrhPG40SYAIgO1uGiFD0z4Ocm)8sEwCW0NQip(GPtmYsKdb7OgL0yKty6MdBKLYbKPhOcPmYpmqqnnhbBJMObAnfhc2rTOJdBunpw8)xAGwtXHGDul64WgvuSK65XI)MyXbLIA0rkionRSMObAnfiYxhDgoQaZpVKNfhm9PkYJpy6eJSe5qWoQPh88k5zXbtFQI84dMoXilruAk4dMU5WgzPCaz6bQsGBcbrD20ImhG5Npl5zXbtFQI84dMoXilroeSJAAoc2gFwmW1LXZYcsbm4dMoHeC7E37Epa]] )

    
end