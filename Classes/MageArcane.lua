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
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
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
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
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
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
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
                    duration = 15,
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


    spec:RegisterPack( "Arcane", 20210707, [[da1k6gqiPK6rQQuUerfPKnrr(ecAuirNcjSkPeYRqOAwuuDlPKGDrYViImmIOogrPLruPNHqPPruHUgcfBJOI6BsjIXjLiDoPeyDeH6DevKsnpvv5EiP9ruLdkLOwOQQ6HQQKjsurkUirfXgjQiv(irfjgjrfjDsPKOvsr5LevKQMjri3ukHANeb)uvLQAOsjPLQQsLNsjtvvfxLOc6RevGXsuv7vv(lPgSshg1IrQhtyYaUm0MLQplfJMsDAqRwkj0RrGzRWTr0UP63IgofoUucA5cpxrtxLRd02jsFxvz8efNxk16vvPkZhHSFj)K99ZZcGp8jb5kz5kRKBjsULOKClqwjl3wWZ6ABGpldwqa3GplNjXNvlhc2XNLb3EKmW7NN1mbdb(SSVZykXsssnWZgKwjssjnHKGd(GPlcUFsAcjfs6zrdchxR0F0pla(WNeKRKLRSsULi5wIsYTazLSCL7ZAAGINeKZY9zzdbaq)r)SaWP4z1I5gS2woeSJLzMboAxBlX8ALRKLRSLzLz)YM9gCkXLzTc1khoXAV2gqbpQ1cs(RATzhya9MAZETcB2DCul0pmcqJdMETqFEiduB2RLqb7cCOzXbtNqvzwRqT)YM9gSwoeSJAO3Ho8Ax7L1YHGDuBZbz6TRLs4vRJsXO2p0VAhqPyT8SwoeSJAO3Ho8AtH6znGZB((5zLgOJX7NNeK99ZZcDMEGaV)FwIaEya5Nva6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1sd27ka4uangqNJ2ArssYoGUh58uGgplwCW0FwDyGA6bpV39KGCF)8SqNPhiW7)NLiGhgq(zfGo2ZObvnbCoARHcOyGk0z6bcuRPAjzNvgIRw5vBlGyEwS4GP)S6ropTNs539KaX((5zXIdM(Zca5ZModhFwOZ0de49)7Esqo((5zHotpqG3)plrapmG8ZIKDwziUALxTYrj)SyXbt)zfmaK9tpn4GG39KaX8(5zXIdM(ZIegrgtD21xgKOFpl0z6bc8()DpjiNF)8SqNPhiW7)NLiGhgq(zrd27koeSJAJ8ddfq(51AQwrMdG8ZvCiyh1g5hgQajzOpFwS4GP)SM2W(b9gTr(HX7EsOL8(5zHotpqG3)plrapmG8ZsK5ai)Cfhc2rTr(HHkqgODTMQLgS3vCiyh1cBoAq18ybb1(xT0G9UIdb7OwyZrdQizz0ZJfe8SyXbt)zXHGDuNb97EsOL((5zHotpqG3)plrapmG8ZsKsrN9tjf9ZUDuRPAfzoaYpxrcJiJPo76lds0pvGKm0N1kVABPYXNfloy6ploeSJA6bpV39Kql49ZZIfhm9N1LGcBD21NnQj5g4ZcDMEGaV)F3tcYk53pplwCW0FwCiyh1g5hgpl0z6bc8()DpjiRSVFEwOZ0de49)ZseWddi)SOb7Dfhc2rTr(HHci)8Nfloy6pRa0rD21g5hgV7jbzL77NNf6m9abE))SyXbt)zze4eDbQZUMe6aplaCkcOXbt)zjhoXAB1Sfx7L1oBHGi(7H1YETOmxW12YHGDS2)h88QfamGEtTNnw7p51ILul3Q1(bDG8RwqFGZzTbO7qVP2woeSJ1kNiStvTTYETTCiyhRvoryN1cN1E8a9dbmV2pSwb7eE1coXAB1Sfx7h8SHETNnw7p51ILul3Q1(bDG8RwqFGZzTFyTq)WianUApBS2wUfxRWMDhhMx7mR9djCmQDYsXAHN6zjc4HbKFwTU2JhOFkoeSJAuyNk0z6bcuRPAbqAWExDjOWwND9zJAsUbQanQ1uTainyVRUeuyRZU(Srnj3avbsYqFw7FuRLYAzXbtxXHGDutp45Pqzqb4H6dsI12IQLgS3vgborxG6SRjHoGIKLrppwqqTu8UNeKLyF)8SqNPhiW7)Nfloy6plJaNOlqD21Kqh4zbGtranoy6pRwzV2wnBX1AZtNWRwAe9AbNiqTaGb0BQ9SXA)jVwCTFqhi)mV2pKWXOwWjwl8Q9YANTqqe)9WAzVwuMl4AB5qWow7)dEE1c9ApBS2Fx2QsQLB1A)Goq(PEwIaEya5NfnyVR4qWoQnYpmuGg1AQwAWExfGoQZU2i)Wqfijd9zT)rTwkRLfhmDfhc2rn9GNNcLbfGhQpijwBlQwAWExze4eDbQZUMe6akswg98ybb1sX7Esqw547NNf6m9abE))Seb8WaYplG8ubdaz)0tdoiqfijd9zTYRwIPwIiQwaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhliOw5vRKFwS4GP)S4qWoQPh88E3tcYsmVFEwOZ0de49)ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)z1YJpU9S2)5i4gSw(Q9SXArhO2SxBl3Q1(zJETbO7qVP2ZgRTLdb7yTYPYbz6TRDGnOdWr7NLiGhgq(zrd27koeSJAJ8ddfOrTMQLgS3vCiyh1g5hgQajzOpR9VABea1AQ2a0XEgnOIdb7O2MdY0BRqNPhiW7Esqw587NNf6m9abE))SyXbt)zXHGDutZrWn4ZcaNIaACW0FwT84JBpR9FocUbRLVApBSw0bQn71E2yT)USvR9d6a5xTF2OxBa6o0BQ9SXAB5qWowRCQCqME7Ahyd6aC0(zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)Wqfijd9zT)rT2gbqTMQnaDSNrdQ4qWoQT5Gm92k0z6bc8UNeKTL8(5zHotpqG3)plHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwIiQwwCqPOgDKeIZAPwRS1srTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZALxTS4GPR4qWoQjHZjCGtfkdkapuFqs8zXIdM(ZIdb7OMeoNWboF3tcY2sF)8SqNPhiW7)NLiGhgq(zrd27kXa5qWZd6nQ5XccQLAT0G9Usmqoe88GEJIKLrppwqqTMQvKsrN9tjf9ZUD8SyXbt)zXHGDutcNt4aNV7jbzBbVFEwOZ0de49)ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilUAnvRiZbq(5koeSJAJ8ddvGKm0N1AQwkRLgS3vbOJ6SRnYpmuGg1ser1sd27koeSJAJ8ddfOrTu8UNeKRKF)8SqNPhiW7)NLiGhgq(zrd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAW5ZIfhm9Nfhc2rDg0V7jb5k77NNf6m9abE))Seb8WaYplAWExfGoQZU2i)WqbAulrevlj7SYqC1kVALLyEwS4GP)S4qWoQPh88E3tcYvUVFEwOZ0de49)ZIfhm9Nfknf8bt)zb9dJa040W(ZIKDwzio5rTLsmplOFyeGgNgssIaq(WNLSplrapmG8ZIgS3vbOJ6SRnYpmua5NxRPAPb7Dfhc2rTr(HHci)839KGCj23pplwCW0FwCiyh10CeCd(SqNPhiW7)39UNvhoTHEJonqhJ3ppji77NNf6m9abE))SyXbt)zHstbFW0Fwa4ueqJdM(ZsoWg9Adq3HEtTi8SXO2ZgR1YQ2mQ9h5GAhyd6aCaXP51(H1(X(v7L1kNinRLg7zG1E2yT)KxlwsTCRw7h0bYpvTYHtSw4vlpRDMPxlpR93LTAT28S2o0HtBeO2emQ9djukw70a9R2emQvyZrdoFwIaEya5NfL1gGo2ZObvhsAKbp0FCyOqNPhiqTeruTuwBa6ypJgunHg2PRNxgKk0z6bcuRPABDTs5aY0duzeOb4yOrPzTuRv2APOwkQ1uTuwlnyVRcqh1zxBKFyOaYpVwIiQwJaLQBeakzvCiyh10CeCdwlf1AQwrMdG8ZvbOJ6SRnYpmubsYqF(UNeK77NNf6m9abE))SyXbt)zHstbFW0Fwa4ueqJdM(ZQv2R9djukwBh6WPncuBcg1kYCaKFETFqhi)M1YoqTtd0VAtWOwHnhn408AncygWd(7H1kNinRnLIrTOumAF2qVPwCmXNLiGhgq(zD8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR1uTImha5NR4qWoQnYpmubsYqFwRPAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1AeOuDJaqjRIdb7OMMJGBW39KaX((5zHotpqG3)plrapmG8ZkaDSNrdQaGtb0yaDoARfjjj7ak0z6bcuRPAPb7DfaCkGgdOZrBTijjzhq3JCEkqJNfloy6pRomqn9GN37Esqo((5zHotpqG3)plrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1sYoRmexTYR2waX8SyXbt)z1JCEApLYV7jbI59ZZcDMEGaV)FwS4GP)S4qWoQjHZjCGZNLWMH(Zs2NLiGhgq(zfGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2MdY0BRMhliO2)QLgS3vCiyh12CqMEBfjlJEESGGAnvlL1szT0G9UIdb7O2i)WqbKFETMQvK5ai)Cfhc2rTr(HHkqgODTuulrevlasd27Qlbf26SRpButYnqfOrTu8UNeKZVFEwOZ0de49)ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGNfloy6pRa0rD21g5hgV7jHwY7NNf6m9abE))Seb8WaYplrMdG8ZvbOJ6SRnYpmubYaTFwS4GP)S4qWoQZG(Dpj0sF)8SqNPhiW7)NLiGhgq(zjYCaKFUkaDuNDTr(HHkqgODTMQLgS3vCiyh1cBoAq18ybb1(xT0G9UIdb7OwyZrdQizz0ZJfe8SyXbt)zXHGDutp459UNeAbVFEwOZ0de49)ZseWddi)SADTbOJ9mAq1HKgzWd9hhgk0z6bculrevRiDaq4PAG9tND9zJ6buyRqNPhiWZIfhm9NfaYNnDgo(UNeKvYVFEwS4GP)Scqh1zxBKFy8SqNPhiW7)39KGSY((5zHotpqG3)plwCW0FwCiyh1KW5eoW5ZcaNIaACW0FwTYETFiHbwlF1sYYu78ybbZAZET)6x1YoqTFyT2Su0j8QfCIa12IZFQTnEMxl4eRLRDESGGAVSwJaLI(vljOlSHEtTG(aNZAdq3HEtTNnwRCQCqME7Ahyd6aC0(zjc4HbKFw0G9Usmqoe88GEJkqwC1AQwAWExjgihcEEqVrnpwqqTuRLgS3vIbYHGNh0BuKSm65XccQ1uTIuk6SFkPOF2TJAnvRiZbq(5ksyezm1zxFzqI(PcKbAxRPABDTs5aY0duHKg5hgiGMMJGBWAnvRiZbq(5koeSJAJ8ddvGmq739KGSY99ZZcDMEGaV)FwIaEya5NvRRnaDSNrdQoK0idEO)4WqHotpqGAnvlL126Adqh7z0GQj0WoD98YGuHotpqGAjIOALYbKPhOYiqdWXqJsZAPwRS1sXZcaNIaACW0FwsidsEmAx7hwRbdJAnYdMETGtS2p4zxBl3QMxln4vl8Q9dog1o45v7i9MArpbBSRTNrT05zx7zJ1(7YwTw2bQTLB1A)Goq(nRf0h4CwBa6o0BQ9SXATSQnJA)roO2b2GoahqC(SyXbt)zzKhm939KGSe77NNf6m9abE))Seb8WaYplAWExfGoQZU2i)WqbKFETeruTgbkv3iauYQ4qWoQP5i4g8zXIdM(Zca5ZModhF3tcYkhF)8SqNPhiW7)NLiGhgq(zrd27Qa0rD21g5hgkG8ZRLiIQ1iqP6gbGswfhc2rnnhb3GplwCW0Fwbdaz)0tdoi4DpjilX8(5zHotpqG3)plrapmG8ZIgS3vbOJ6SRnYpmubsYqFw7F1szTY5AjETYT2wuTbOJ9mAq1eAyNUEEzqQqNPhiqTu8SyXbt)zrcJiJPo76lds0V39KGSY53ppl0z6bc8()zXIdM(ZIdb7O2i)W4zbGtranoy6pl5aB0RnaDh6n1E2yTYPYbz6TRDGnOdWrBZRfCI12YTAT0ypdS2FYRfx7L1casAulxBhCmAx78ybbiqT0CWrd(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLgS3vbOJ6SRnYpmuGg1AQwkRLKDwziUA)RwkRvUetTeVwkRvwjxBlQwrkfD2pfbTdi71srTuulrevlnyVRedKdbppO3OMhliOwQ1sd27kXa5qWZd6nkswg98ybb1sX7Esq2wY7NNf6m9abE))Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uT0G9UIdb7O2i)WqbA8SyXbt)zXHGDutZrWn47Esq2w67NNf6m9abE))Seb8WaYplAWExfGoQZU2i)WqbKFETeruTgbkv3iauYQ4qWoQP5i4gSwIiQwJaLQBeakzvbdaz)0tdoiOwIiQwJaLQBeakzvaiF20z44ZIfhm9N1LGcBD21NnQj5g47Esq2wW7NNf6m9abE))Seb8WaYplJaLQBeakzvxckS1zxF2OMKBGplwCW0FwCiyh1g5hgV7jb5k53ppl0z6bc8()zXIdM(ZYiWj6cuNDnj0bEwa4ueqJdM(ZsoCI12QzlU2lRD2cbr83dRL9ArzUGRTLdb7yT)p45vlaya9MApBS2FYRflPwUvR9d6a5xTG(aNZAdq3HEtTTCiyhRvoryNQABL9AB5qWowRCIWoRfoR94b6hcyETFyTc2j8QfCI12QzlU2p4zd9ApBS2FYRflPwUvR9d6a5xTG(aNZA)WAH(HraAC1E2yTTClUwHn7oomV2zw7hs4yu7KLI1cp1ZseWddi)SADThpq)uCiyh1OWovOZ0deOwt1cG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2)OwlL1YIdMUIdb7OMEWZtHYGcWd1hKeRTfvlnyVRmcCIUa1zxtcDafjlJEESGGAP4DpjixzF)8SqNPhiW7)Nfloy6plJaNOlqD21Kqh4zbGtranoy6pRwzV2wnBX1AZtNWRwAe9AbNiqTaGb0BQ9SXA)jVwCTFqhi)mV2pKWXOwWjwl8Q9YANTqqe)9WAzVwuMl4AB5qWow7)dEE1c9ApBS2Fx2QsQLB1A)Goq(PEwIaEya5NfnyVR4qWoQnYpmuGg1AQwAWExfGoQZU2i)Wqfijd9zT)rTwkRLfhmDfhc2rn9GNNcLbfGhQpijwBlQwAWExze4eDbQZUMe6akswg98ybb1sX7EsqUY99ZZcDMEGaV)FwIaEya5NfqEQGbGSF6PbheOcKKH(Sw5vlXulrevlasd27QGbGSF6PbheOLcoCmyA4aETvZJfeuR8QvYplwCW0FwCiyh10dEEV7jb5sSVFEwOZ0de49)ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zjhG1(X(v7L1sYeG1obdS2pSwBwkwl6jyJDTKSZ12ZO2ZgRf9dgyTTCRw7h0bYpZRfLIETWETNngiHZANhCmQ9GKyTbsYqh6n1MET)USvv12kpcN1M(ODT04Dyu7L1sdgETxw7VhgzTSduRCI0SwyV2a0DO3u7zJ1AzvBg1(JCqTdSbDaoG4u9Seb8WaYplrMdG8ZvCiyh1g5hgQazG21AQws2zLH4Q9VAPSw5OKRL41szTYk5ABr1ksPOZ(PiODazVwkQLIAnvlnyVR4qWoQf2C0GQ5XccQLAT0G9UIdb7OwyZrdQizz0ZJfeuRPAPS2wxBa6ypJgunHg2PRNxgKk0z6bculrevRuoGm9avgbAaogAuAwl1ALTwkQ1uTTU2a0XEgnO6qsJm4H(Jddf6m9abQ1uTTU2a0XEgnOIdb7O2MdY0BRqNPhiW7EsqUYX3ppl0z6bc8()zXIdM(ZIdb7OMMJGBWNfaofb04GP)S(NJGBWAN2j4aOwpVAPXAbNiqT8v7zJ1IoqTzV2wUvRf2RvorAk4dMETWzTbYaTRLN1cePHb0BQvyZrdoR9dog1sYeG1cVApMaS2r6nyu7L1sdgETNDKGn21gijdDO3ulj78ZseWddi)SOb7Dfhc2rTr(HHc0Owt1sd27koeSJAJ8ddvGKm0N1(h1ABea1AQwrMdG8ZvO0uWhmDvGKm0NV7jb5smVFEwOZ0de49)ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)z9phb3G1oTtWbqT84JBpRLgR9SXAh88QvWZRwOx7zJ1(7YwT2pOdKF1YZA)jVwCTFWXO2aNxgyTNnwRWMJgCw70a97zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)Wqfijd9zT)rT2gbqTMQT11gGo2ZObvCiyh12CqMEBf6m9abE3tcYvo)(5zHotpqG3)plHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwIiQwwCqPOgDKeIZAPwRS1srTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZALxTS4GPR4qWoQjHZjCGtfkdkapuFqs8zXIdM(ZIdb7OMeoNWboF3tcYTL8(5zHotpqG3)plwCW0FwCiyh1KW5eoW5ZcaNIaACW0FwTYETFiHbwRu0p72H51cjjraiF4ODTGtS2F9RA)SrVwbByGa1EzTEE1(XZdR1isXS2EKK12IZFEwIaEya5NLiLIo7Nsk6ND7Owt1sd27kXa5qWZd6nQ5XccQLAT0G9Usmqoe88GEJIKLrppwqW7EsqUT03ppl0z6bc8()zbGtranoy6plRJJRwWj0BQ9x)Q2wUfx7Nn612YTAT28SwAe9AbNiWZseWddi)SOb7DLyGCi45b9gvGS4Q1uTImha5NR4qWoQnYpmubsYqFwRPAPSwAWExfGoQZU2i)WqbAulrevlnyVR4qWoQnYpmuGg1sXZsyZq)zj7ZIfhm9Nfhc2rnjCoHdC(UNeKBl49ZZcDMEGaV)FwIaEya5NfnyVR4qWoQf2C0GQ5XccQ9pQ1kLditpq1LhPMKLrlS5ObNplwCW0FwCiyh1zq)UNeiwj)(5zHotpqG3)plrapmG8ZIgS3vbOJ6SRnYpmuGg1ser1sYoRmexTYRwzjMNfloy6ploeSJA6bpV39KaXk77NNf6m9abE))SyXbt)zHstbFW0Fwq)WianonS)SizNvgItEuBPeZZc6hgbOXPHKKiaKp8zj7ZseWddi)SOb7Dva6Oo7AJ8ddfq(51AQwAWExXHGDuBKFyOaYp)DpjqSY99ZZIfhm9Nfhc2rnnhb3Gpl0z6bc8()DV7zf5Xhm93ppji77NNf6m9abE))SyXbt)zHstbFW0Fwa4ueqJdM(ZsoCI1IsZAH9A)qcdS2r(vB61sYoxl7a1kYCaKF(SwoWAz6e8Q9YAPXAbnEwIaEya5Nfj7SYqC1(h1ALYbKPhOcLMAdXvRPAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR9pQ1YIdMUcLMc(GPRqzqb4H6dsI1ser1kYCaKFUIdb7O2i)Wqfijd9zT)rTwwCW0vO0uWhmDfkdkapuFqsSwIiQwkR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7FuRLfhmDfknf8btxHYGcWd1hKeRLIAPOwt1sd27Qa0rD21g5hgkG8ZR1uT0G9UIdb7O2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8AnvBRR1iqP6gbGsw1LGcBD21NnQj5g47EsqUVFEwOZ0de49)ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1(h1AzXbtxHstbFW0vOmOa8q9bjXNfloy6pluAk4dM(7EsGyF)8SqNPhiW7)Nfloy6ploeSJAAocUbFwa4ueqJdM(Z6FocUbRf2RfEeoR9GKyTxwl4eR9YJSw2bQ9dR1MLI1Ezwlj7TRvyZrdoFwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlL1sd27koeSJAHnhnOAESGGALxTs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATOmOa8q9bjXAnvlj7SYqC1kVALYbKPhOIn0KqhscsQjzN1gIRwt1sd27Qa0rD21g5hgkG8ZRLI39KGC89ZZcDMEGaV)FwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlL1sd27koeSJAHnhnOAESGGALxTs5aY0duD5rQjzz0cBoAWzTMQ94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7FuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1kVALYbKPhO6YJutYYObWb3w3ZqZg1sXZIfhm9Nfhc2rnnhb3GV7jbI59ZZcDMEGaV)FwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlL1sd27koeSJAHnhnOAESGGALxTs5aY0duD5rQjzz0cBoAWzTMQLYABDThpq)ubOJ6SRnYpmuOZ0deOwIiQwrMdG8ZvbOJ6SRnYpmubsYqFwR8QvkhqMEGQlpsnjlJgahCBDpdDKg1srTMQvkhqMEGQdsIAq)GdnBuR8QvkhqMEGQlpsnjlJgahCBDpdnBulfplwCW0FwCiyh10CeCd(UNeKZVFEwOZ0de49)ZseWddi)SaqAWExfmaK9tpn4GaTuWHJbtdhWRTAESGGAPwlasd27QGbGSF6PbheOLcoCmyA4aETvKSm65XccQ1uTuwlnyVR4qWoQnYpmua5NxlrevlnyVR4qWoQnYpmubsYqFw7FuRTraulf1AQwkRLgS3vbOJ6SRnYpmua5NxlrevlnyVRcqh1zxBKFyOcKKH(S2)OwBJaOwkEwS4GP)S4qWoQP5i4g8Dpj0sE)8SqNPhiW7)NLiGhgq(zjLditpqvRi480Gteqpn4GGAjIOAPSwaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARanQ1uTainyVRcgaY(PNgCqGwk4WXGPHd41wnpwqqT)vlasd27QGbGSF6PbheOLcoCmyA4aETvKSm65XccQLINfloy6ploeSJA6bpV39Kql99ZZcDMEGaV)FwIaEya5NfnyVRmcCIUa1zxtcDafOrTMQfaPb7D1LGcBD21NnQj5gOc0Owt1cG0G9U6sqHTo76Zg1KCdufijd9zT)rTwwCW0vCiyh10dEEkuguaEO(GK4ZIfhm9Nfhc2rn9GN37EsOf8(5zHotpqG3)plHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwIiQwwCqPOgDKeIZAPwRS1srTMQLYAbqAWExDjOWwND9zJAsUbQcKKH(Sw5vlloy6koeSJAs4Cch4uHYGcWd1hKeRLiIQvK5ai)CLrGt0fOo7AsOdOcKKH(SwIiQwrkfD2pfbTdi71sXZIfhm9Nfhc2rnjCoHdC(UNeKvYVFEwOZ0de49)ZIfhm9Nfhc2rnjCoHdC(SaWPiGghm9N1VsFcsI1E2yTOmgSdGa1AKh6hKh1sd271Yt2O2lR1ZR2roXAnYd9dYJAnIumFwIaEya5NfnyVRedKdbppO3OcKfxTMQLgS3vOmgSdGaAJ8q)G8qbA8UNeKv23ppl0z6bc8()zXIdM(ZIdb7OMeoNWboFwcBg6plzFwIaEya5NfnyVRedKdbppO3OcKfxTMQLYAPb7Dfhc2rTr(HHc0OwIiQwAWExfGoQZU2i)WqbAulrevlasd27Qlbf26SRpButYnqvGKm0N1kVAzXbtxXHGDutcNt4aNkuguaEO(GKyTu8UNeKvUVFEwOZ0de49)ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OMhliOwQ1sd27kXa5qWZd6nkswg98ybbV7jbzj23ppl0z6bc8()zbGtranoy6pRwE8XTN1Er7AVSwA2jO2F9RA7zuRiZbq(51(bDG8Bwln4vlaiPrTNnswlSx7zJTjmWAz6e8Q9YArzmGb(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OcKKH(S2)OwlL1szT0G9Usmqoe88GEJAESGGABr1YIdMUIdb7OMeoNWbovOmOa8q9bjXAPOwIxBJaqrYYulfplHnd9NLSplwCW0FwCiyh1KW5eoW57Esqw547NNf6m9abE))Seb8WaYplkRnWEGtBMEG1ser126ApOGaO3ulf1AQwAWExXHGDulS5ObvZJfeul1APb7Dfhc2rTWMJgurYYONhliOwt1sd27koeSJAJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkG8ZFwS4GP)SC8SXqFiPboV39KGSeZ7NNf6m9abE))Seb8WaYplAWExXHGDulS5ObvZJfeu7FuRvkhqMEGQlpsnjlJwyZrdoFwS4GP)S4qWoQZG(DpjiRC(9ZZcDMEGaV)FwIaEya5NLuoGm9avj4nHaOo7ArMdG8ZN1AQws2zLH4Q9pQ12ciMNfloy6pRjObgEkLF3tcY2sE)8SqNPhiW7)NLiGhgq(zrd27QaCG6SRp7aXPc0Owt1sd27koeSJAHnhnOAESGGALxTe7ZIfhm9Nfhc2rn9GN37Esq2w67NNf6m9abE))SyXbt)zXHGDutZrWn4ZcaNIaACW0FwYPbK0OwHnhn4SwyV2pS2opg1sJJ8R2ZgRvK(edPyTKSZ1E2boTZbqTSdulknf8btVw4S25bhJAtVwrMdG8ZFwIaEya5NvRRnaDSNrdQMqd701Zldsf6m9abQ1uTs5aY0duLG3ecG6SRfzoaYpFwRPAPb7Dfhc2rTWMJgunpwqqTuRLgS3vCiyh1cBoAqfjlJEESGGAnv7Xd0pfhc2rDg0k0z6bcuRPAfzoaYpxXHGDuNbTkqsg6ZA)JATncGAnvlj7SYqC1(h1ABbsUwt1kYCaKFUcLMc(GPRcKKH(8DpjiBl49ZZcDMEGaV)FwIaEya5Nva6ypJgunHg2PRNxgKk0z6bcuRPALYbKPhOkbVjea1zxlYCaKF(Swt1sd27koeSJAHnhnOAESGGAPwlnyVR4qWoQf2C0Gkswg98ybb1AQ2JhOFkoeSJ6mOvOZ0deOwt1kYCaKFUIdb7OodAvGKm0N1(h1ABea1AQws2zLH4Q9pQ12cKCTMQvK5ai)Cfknf8btxfijd9zT)vlXk5Nfloy6ploeSJAAocUbF3tcYvYVFEwOZ0de49)ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zjNgqsJAf2C0GZAH9AZGUw4S2azG2plrapmG8ZskhqMEGQe8MqauNDTiZbq(5ZAnvlnyVR4qWoQf2C0GQ5XccQLAT0G9UIdb7OwyZrdQizz0ZJfeuRPApEG(P4qWoQZGwHotpqGAnvRiZbq(5koeSJ6mOvbsYqFw7FuRTrauRPAjzNvgIR2)OwBlqY1AQwrMdG8ZvO0uWhmDvGKm0NV7jb5k77NNf6m9abE))SyXbt)zXHGDutZrWn4ZcaNIaACW0FwTCiyhR9FocUbRDANGdGABqhdEmAxlnw7zJ1o45vRGNxTzV2ZgRTLB1A)Goq(9Seb8WaYplAWExXHGDuBKFyOanQ1uT0G9UIdb7O2i)Wqfijd9zT)rT2gbqTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uTuwRiZbq(5kuAk4dMUkqsg6ZAjIOAdqh7z0GkoeSJABoitVTcDMEGa1sX7EsqUY99ZZcDMEGaV)FwS4GP)S4qWoQP5i4g8zbGtranoy6pRwoeSJ1(phb3G1oTtWbqTnOJbpgTRLgR9SXAh88QvWZR2Sx7zJ1(7YwT2pOdKFplrapmG8ZIgS3vbOJ6SRnYpmuGg1AQwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgQajzOpR9pQ12iaQ1uT0G9UIdb7OwyZrdQMhliOwQ1sd27koeSJAHnhnOIKLrppwqqTMQLYAfzoaYpxHstbFW0vbsYqFwlrevBa6ypJguXHGDuBZbz6TvOZ0deOwkE3tcYLyF)8SqNPhiW7)Nfloy6ploeSJAAocUbFwa4ueqJdM(ZQLdb7yT)ZrWnyTt7eCaulnw7zJ1o45vRGNxTzV2ZgR9N8AX1(bDG8RwyVw4vlCwRNxTGteO2p4zx7VlB1AZO2wUvFwIaEya5NfnyVR4qWoQnYpmua5NxRPAPb7Dva6Oo7AJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkqJAnvlasd27Qlbf26SRpButYnqvGKm0N1(h1ABea1AQwAWExXHGDulS5ObvZJfeul1APb7Dfhc2rTWMJgurYYONhli4Dpjix547NNf6m9abE))SyXbt)zXHGDutZrWn4ZcaNIaACW0FwYb2Ox7zJ1EC0GxTWzTqVwuguaEyTb7nyTSdu7zJbwlCwlzgyTNn71Mowl6izBZRfCI1sZrWnyT8S2zMET8S22jyT2SuSw0tWg7Af2C0GZAVSwB4vlpg1IoscXzTWETNnwBlhc2XA)pjP5aGe9R2b2GoahTRfoRfBHGqdde4zjc4HbKFws5aY0duHKg5hgiGMMJGBWAnvlnyVR4qWoQf2C0GQ5XccQvEuRLYAzXbLIA0rsioRTvOwzRLIAnvlloOuuJoscXzTYRwzR1uT0G9Uca5ZModhva5N)UNeKlX8(5zHotpqG3)plrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAPb7Dfhc2rTWMJgunpwqqT)vlnyVR4qWoQf2C0Gkswg98ybb1AQwwCqPOgDKeIZALxTYwRPAPb7DfaYNnDgoQaYp)zXIdM(ZIdb7OgLXyKty6V7jb5kNF)8SyXbt)zXHGDutp459SqNPhiW7)39KGCBjVFEwOZ0de49)ZseWddi)SKYbKPhOkbVjea1zxlYCaKF(8zXIdM(ZcLMc(GP)UNeKBl99ZZIfhm9Nfhc2rnnhb3Gpl0z6bc8()DV7zXj((5jbzF)8SqNPhiW7)NLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTImha5NROb7DnaCkGgdOZrBTijjzhqfid0Uwt1sd27ka4uangqNJ2ArssYoGUh58ua5NxRPAPSwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5Nxlf1AQwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATsUwt1szT0G9UIdb7OwyZrdQMhliO2)OwRuoGm9avCI6lpsnjlJwyZrdoR1uTuwlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9pQ12iaQ1uTImha5NR4qWoQnYpmubsYqFwR8QvkhqMEGQlpsnjlJgahCBDpdnBulf1ser1szTTU2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(Sw5vRuoGm9avxEKAswgnao426EgA2OwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATncGAPOwkEwS4GP)S6rop6CCV7jb5((5zHotpqG3)plrapmG8ZIYAdqh7z0Gka4uangqNJ2ArssYoGcDMEGa1AQwrMdG8Zv0G9UgaofqJb05OTwKKKSdOcKbAxRPAPb7DfaCkGgdOZrBTijjzhq3HbQaYpVwt1AeOuDJaqjRQh58OZXvlf1ser1szTbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnv7bjXAPwRKRLINfloy6pRomqn9GN37EsGyF)8SqNPhiW7)NLiGhgq(zfGo2ZObvnbCoARHcOyGk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(Sw5vlXk5AnvRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPSwAWExXHGDulS5ObvZJfeu7FuRvkhqMEGkor9LhPMKLrlS5ObN1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(h1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpRvE1kLditpq1LhPMKLrdGdUTUNHMnQLIAjIOAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8QvkhqMEGQlpsnjlJgahCBDpdnBulf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)rT2gbqTuulfplwCW0Fw9iNN2tP87Esqo((5zHotpqG3)plrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRvE1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliOwQ1sd27koeSJAHnhnOIKLrppwqqTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfeu7FuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(51sXZIfhm9NvpY5P9uk)UNeiM3ppl0z6bc8()zXIdM(ZIdb7OMeoNWboFwcBg6plzFwIaEya5NLiLIo7NIG2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1sd27koeSJABoitVTAESGGA)RwzjMAnvRiZbq(5QGbGSF6PbheOcKKH(S2)OwRuoGm9av2CqMEB98ybb6dsI1s8Arzqb4H6dsI1AQwrMdG8ZvxckS1zxF2OMKBGQajzOpR9pQ1kLditpqLnhKP3wppwqG(GKyTeVwuguaEO(GKyTeVwwCW0vbdaz)0tdoiqHYGcWd1hKeR1uTImha5NR4qWoQnYpmubsYqFw7FuRvkhqMEGkBoitVTEESGa9bjXAjETOmOa8q9bjXAjETS4GPRcgaY(PNgCqGcLbfGhQpijwlXRLfhmD1LGcBD21NnQj5gOcLbfGhQpij(UNeKZVFEwOZ0de49)ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGAnvRrGs1ncaLSkuAk4dM(ZIfhm9N1LGcBD21NnQj5g47EsOL8(5zHotpqG3)plrapmG8ZkaDSNrdQMqd701Zldsf6m9abQ1uTuwRrGs1ncaLSkuAk4dMETeruTgbkv3iauYQUeuyRZU(Srnj3aRLINfloy6ploeSJAJ8dJ39Kql99ZZcDMEGaV)FwIaEya5N1bjXALxTeRKR1uTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLgS3vCiyh1cBoAq18ybb1(h1ALYbKPhOItuF5rQjzz0cBoAWzTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uTImha5NR4qWoQnYpmubsYqFw7FuRTra8SyXbt)zHstbFW0F3tcTG3ppl0z6bc8()zXIdM(ZcLMc(GP)SG(HraACAy)zrd27Qj0WoD98YGunpwqavAWExnHg2PRNxgKkswg98ybbplOFyeGgNgssIaq(WNLSplrapmG8Z6GKyTYRwIvY1AQ2a0XEgnOAcnStxpVmivOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRvE1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliOwQ1sd27koeSJAHnhnOIKLrppwqqTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfeu7FuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(51sX7Esqwj)(5zHotpqG3)plrapmG8ZIYAfzoaYpxXHGDuBKFyOcKKH(Sw5vRCKyQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATeBTuuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlL1sd27koeSJAHnhnOAESGGA)JATs5aY0duXjQV8i1KSmAHnhn4Swt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2)OwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYRwIPwkQLiIQLYABDThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTYRwIPwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATncGAPOwkEwS4GP)SiHrKXuND9Lbj637EsqwzF)8SqNPhiW7)NLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufijd9zT)vlkdkapuFqsSwt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2)OwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYRwPCaz6bQU8i1KSmAaCWT19m0SrTuulrevlL126ApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALxTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9pQ12iaQLINfloy6pRGbGSF6Pbhe8UNeKvUVFEwOZ0de49)ZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2)QfLbfGhQpijwRPAPSwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5vRuoGm9avSHMKLrdGdUTUNH(YJSwt1sd27koeSJAHnhnOAESGGAPwlnyVR4qWoQf2C0Gkswg98ybb1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPb7Dfhc2rTWMJgunpwqqT)rTwPCaz6bQ4e1xEKAswgTWMJgCwlf1srTMQLgS3vbOJ6SRnYpmua5NxlfplwCW0Fwbdaz)0tdoi4DpjilX((5zHotpqG3)plrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZAPwRKR1uTuwlL1szTImha5NRUeuyRZU(Srnj3avbsYqFwR8QvkhqMEGk2qtYYObWb3w3ZqF5rwRPAPb7Dfhc2rTWMJgunpwqqTuRLgS3vCiyh1cBoAqfjlJEESGGAPOwIiQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uT0G9UIdb7OwyZrdQMhliO2)OwRuoGm9avCI6lpsnjlJwyZrdoRLIAPOwt1sd27Qa0rD21g5hgkG8ZRLINfloy6plaKpB6mC8DpjiRC89ZZcDMEGaV)FwIaEya5NfL1sd27koeSJAHnhnOAESGGA)JATs5aY0duXjQV8i1KSmAHnhn4SwIiQwJaLQBeakzvbdaz)0tdoiOwkQ1uTuwlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9pQ12iaQ1uTImha5NR4qWoQnYpmubsYqFwR8QvkhqMEGQlpsnjlJgahCBDpdnBulf1ser1szTTU2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(Sw5vRuoGm9avxEKAswgnao426EgA2OwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATncGAP4zXIdM(Z6sqHTo76Zg1KCd8DpjilX8(5zHotpqG3)plrapmG8ZIYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRvE1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliOwQ1sd27koeSJAHnhnOIKLrppwqqTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfeu7FuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(5plwCW0FwCiyh1g5hgV7jbzLZVFEwOZ0de49)ZseWddi)SOb7Dva6Oo7AJ8ddfq(51AQwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5vRCLCTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQLIAjIOAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATsUwt1sd27koeSJAHnhnOAESGGA)JATs5aY0duXjQV8i1KSmAHnhn4SwkQLIAnvlL1kYCaKFUIdb7O2i)Wqfijd9zTYRwzLBTeruTainyVRUeuyRZU(Srnj3avGg1sXZIfhm9Nva6Oo7AJ8dJ39KGSTK3ppl0z6bc8()zjc4HbKFwImha5NR4qWoQZGwfijd9zTYRwIPwIiQ2wx7Xd0pfhc2rDg0k0z6bc8SyXbt)znTH9d6nAJ8dJ39KGST03ppl0z6bc8()zjc4HbKFwIuk6SFkcAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhliOwQ1khR1uTgbkv3iauYQ4qWoQZGUwt1YIdkf1OJKqCw7F12sEwS4GP)S4qWoQPh88E3tcY2cE)8SqNPhiW7)NLiGhgq(zjsPOZ(PiODazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn4GaTuWHJbtdhWRTAESGGAPwRC8zXIdM(ZIdb7OMMJGBW39KGCL87NNf6m9abE))Seb8WaYplrkfD2pfbTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh1g5hgkqJAnvlL1cKNkyai7NEAWbbQajzOpRvE1kNRLiIQfaPb7DvWaq2p90Gdc0sbhogmnCaV2kqJAPOwt1cG0G9Ukyai7NEAWbbAPGdhdMgoGxB18ybb1(xTYXAnvlloOuuJoscXzTuRLyFwS4GP)S4qWoQPh88E3tcYv23ppl0z6bc8()zjc4HbKFwIuk6SFkcAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhliOwQ1sSplwCW0FwCiyh1zq)UNeKRCF)8SqNPhiW7)NLiGhgq(zjsPOZ(PiODazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn4GaTuWHJbtdhWRTAESGGAPwRCFwS4GP)S4qWoQP5i4g8DpjixI99ZZcDMEGaV)FwIaEya5NLiLIo7NIG2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1sd27koeSJAJ8ddfOrTMQ1iqP6gbGsUQGbGSF6PbheuRPAzXbLIA0rsioRvE1sSplwCW0FwCiyh1OmgJCct)Dpjix547NNf6m9abE))Seb8WaYplrkfD2pfbTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh1g5hgkqJAnvlasd27QGbGSF6PbheOLcoCmyA4aETvZJfeul1ALTwt1YIdkf1OJKqCwR8QLyFwS4GP)S4qWoQrzmg5eM(7EsqUeZ7NNf6m9abE))Seb8WaYplAWExbG8ztNHJkqJAnvlasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)JAT0G9UYiWj6cuNDnj0buKSm65XccQTfvlloy6koeSJA6bppfkdkapuFqsSwt1szTuw7Xd0pvGZ0zxGk0z6bcuRPAzXbLIA0rsioR9VALJ1srTeruTS4Gsrn6ijeN1(xTetTuuRPAPS2wxBa6ypJguXHGDutNK0CaqI(PqNPhiqTeruThhn4PSrEC2kdXvR8QLyjMAP4zXIdM(ZYiWj6cuNDnj0bE3tcYvo)(5zHotpqG3)plrapmG8ZIgS3vaiF20z4Oc0Owt1szTuw7Xd0pvGZ0zxGk0z6bcuRPAzXbLIA0rsioR9VALJ1srTeruTS4Gsrn6ijeN1(xTetTuuRPAPS2wxBa6ypJguXHGDutNK0CaqI(PqNPhiqTeruThhn4PSrEC2kdXvR8QLyjMAP4zXIdM(ZIdb7OMEWZ7Dpji3wY7NNfloy6pRjObgEkLFwOZ0de49)7EsqUT03ppl0z6bc8()zjc4HbKFw0G9UIdb7OwyZrdQMhliOw5rTwkRLfhukQrhjH4S2wHALTwkQ1uTbOJ9mAqfhc2rnDssZbaj6NcDMEGa1AQ2JJg8u2ipoBLH4Q9VAjwI5zXIdM(ZIdb7OMMJGBW39KGCBbVFEwOZ0de49)ZseWddi)SOb7Dfhc2rTWMJgunpwqqTuRLgS3vCiyh1cBoAqfjlJEESGGNfloy6ploeSJAAocUbF3tceRKF)8SqNPhiW7)NLiGhgq(zrd27koeSJAHnhnOAESGGAPwRKR1uTuwRiZbq(5koeSJAJ8ddvGKm0N1kVALLyQLiIQT11szTIuk6SFkcAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAPOwkEwS4GP)S4qWoQZG(DpjqSY((5zHotpqG3)plrapmG8ZIYAdSh40MPhyTeruTTU2dkia6n1srTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccEwS4GP)SC8SXqFiPboV39KaXk33ppl0z6bc8()zjc4HbKFw0G9Usmqoe88GEJkqwC1AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLYAPS2JhOFkM0ya7qbFW0vOZ0deOwt1YIdkf1OJKqCw7F12sRLIAjIOAzXbLIA0rsioR9VAjMAP4zXIdM(ZIdb7OMeoNWboF3tcelX((5zHotpqG3)plrapmG8ZIgS3vIbYHGNh0BubYIRwt1E8a9tXHGDuJc7uHotpqGAnvlasd27Qlbf26SRpButYnqfOrTMQLYApEG(PysJbSdf8btxHotpqGAjIOAzXbLIA0rsioR9VABb1sXZIfhm9Nfhc2rnjCoHdC(UNeiw547NNf6m9abE))Seb8WaYplAWExjgihcEEqVrfilUAnv7Xd0pftAmGDOGpy6k0z6bcuRPAzXbLIA0rsioR9VALJplwCW0FwCiyh1KW5eoW57EsGyjM3ppl0z6bc8()zjc4HbKFw0G9UIdb7OwyZrdQMhliO2)QLgS3vCiyh1cBoAqfjlJEESGGNfloy6ploeSJAugJroHP)UNeiw587NNf6m9abE))Seb8WaYplAWExXHGDulS5ObvZJfeul1APb7Dfhc2rTWMJgurYYONhliOwt1AeOuDJaqjRIdb7OMMJGBWNfloy6ploeSJAugJroHP)UNei2wY7NNf0pmcqJtd7pls2zLH4Kh1wkX8SG(HraACAijjca5dFwY(SyXbt)zHstbFW0FwOZ0de49)7E3Zca7m44E)8KGSVFEwS4GP)SejOFymnWX4zHotpqG3)V7jb5((5zHotpqG3)plrapmG8ZIYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXv7FuRTLk5Anvlj7SYqC1kpQ1kNjMAPOwIiQwkRT11E8a9tH(a2yFOJak0z6bcuRPAjzNvgIR2)OwBlLyQLINfloy6pls2zDds(UNei23ppl0z6bc8()zjc4HbKFw0G9UIdb7O2i)WqbA8SyXbt)zzKhm939KGC89ZZcDMEGaV)FwIaEya5Nva6ypJguDiPrg8q)XHHcDMEGa1AQwAWExHYyZGZdMUc0Owt1szTImha5NR4qWoQnYpmubYaTRLiIQLoNZAnvBh2yF6ajzOpR9pQ1khLCTu8SyXbt)zDqsu)XHX7EsGyE)8SqNPhiW7)NLiGhgq(zrd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8Nfloy6pRbSX(M6wrqGgs0V39KGC(9ZZcDMEGaV)FwIaEya5NfnyVR4qWoQnYpmua5NxRPAPb7Dva6Oo7AJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkG8ZFwS4GP)SO5gD21xafemF3tcTK3ppl0z6bc8()zjc4HbKFw0G9UIdb7O2i)WqbA8SyXbt)zrJXedcGEZ7EsOL((5zHotpqG3)plrapmG8ZIgS3vCiyh1g5hgkqJNfloy6pl6rMa6oy0(Dpj0cE)8SqNPhiW7)NLiGhgq(zrd27koeSJAJ8ddfOXZIfhm9Nvhgi9itG39KGSs(9ZZcDMEGaV)FwIaEya5NfnyVR4qWoQnYpmuGgplwCW0FwSlW5f8ql4X4DpjiRSVFEwOZ0de49)ZseWddi)SOb7Dfhc2rTr(HHc04zXIdM(ZcCIA4HKZ39KGSY99ZZcDMEGaV)FwS4GP)SAgmaKVmMAAgObFwIaEya5NfnyVR4qWoQnYpmuGg1ser1kYCaKFUIdb7O2i)Wqfijd9zTYJATedXuRPAbqAWExDjOWwND9zJAsUbQanEwyVJIt7mj(SAgmaKVmMAAgObF3tcYsSVFEwOZ0de49)ZIfhm9NfsA0oqEOZaWzxGplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)JATuwRSeBTeV2wsTTOALYbKPhOIn0PRbNyTuuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(S2)OwlL1klXwlXRTLuBlQwPCaz6bQydD6AWjwlfplNjXNfsA0oqEOZaWzxGV7jbzLJVFEwOZ0de49)ZIfhm9NfqGmqhgOwkoN44zjc4HbKFwImha5NR4qWoQnYpmubsYqFwR8OwRCLCTeruTTUwPCaz6bQydD6AWjwl1ALTwIiQwkR9GKyTuRvY1AQwPCaz6bQ6WPn0B0Pb6yul1ALTwt1gGo2ZObvtOHD665LbPcDMEGa1sXZYzs8zbeid0HbQLIZjoE3tcYsmVFEwOZ0de49)ZIfhm9N1mbhAyJdpmEwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1kpQ1sSsUwIiQ2wxRuoGm9avSHoDn4eRLATY(SCMeFwZeCOHno8W4DpjiRC(9ZZcDMEGaV)FwS4GP)SAgTnS1zxZZjKeo4dM(ZseWddi)SezoaYpxXHGDuBKFyOcKKH(Sw5rTw5k5AjIOABDTs5aY0duXg601GtSwQ1kBTeruTuw7bjXAPwRKR1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQnaDSNrdQMqd701Zldsf6m9abQLINLZK4ZQz02WwNDnpNqs4Gpy6V7jbzBjVFEwOZ0de49)ZIfhm9Nfjly6a1tBepnj4ekEwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1(h1AjMAnvlL126ALYbKPhOQdN2qVrNgOJrTuRv2AjIOApijwR8QLyLCTu8SCMeFwKSGPdupTr80KGtO4DpjiBl99ZZcDMEGaV)FwS4GP)SizbthOEAJ4PjbNqXZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2)OwlXuRPALYbKPhOQdN2qVrNgOJrTuRv2AnvlnyVRcqh1zxBKFyOanQ1uT0G9UkaDuNDTr(HHkqsg6ZA)JATuwRSsU2wHAjMABr1gGo2ZObvtOHD665LbPcDMEGa1srTMQ9GKyT)vlXk5NLZK4ZIKfmDG6PnINMeCcfV7jbzBbVFEwOZ0de49)ZIfhm9N10MbYpeqNbTo76lds0VNLiGhgq(zDqsSwQ1k5AjIOAPSwPCaz6bQsWBcbqD21Imha5NpR1uTuwRiZbq(5koeSJAJ8ddvGKm0N1(h1ALBTeruTDyJ9PdKKH(S2)QvK5ai)Cfhc2rTr(HHkqsg6ZAPOwkEwotIpRPndKFiGodAD21xgKOFV7jb5k53ppl0z6bc8()zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZsWdb4Gpy6Z39KGCL99ZZcDMEGaV)FwIaEya5NfloOuuJoscXzTYJATs5aY0duXjQpoAWtlsq)EwZlGI7jbzFwS4GP)Se8yOzXbtxpGZ7znGZt7mj(S4eF3tcYvUVFEwOZ0de49)ZseWddi)SePu0z)ue0oGSxRPAdqh7z0GkoeSJABoitVTcDMEGaplwCW0FwcEm0S4GPRhW59SgW5PDMeFw2CqME739KGCj23ppl0z6bc8()zjc4HbKFws5aY0duzZsrDAGocul1ALCTMQvkhqMEGQoCAd9gDAGog1AQ2wxlL1ksPOZ(PiODazVwt1gGo2ZObvCiyh12CqMEBf6m9abQLINfloy6plbpgAwCW01d48Ewd480otIpRoCAd9gDAGogV7jb5khF)8SqNPhiW7)NLiGhgq(zjLditpqLnlf1Pb6iqTuRvY1AQ2wxlL1ksPOZ(PiODazVwt1gGo2ZObvCiyh12CqMEBf6m9abQLINfloy6plbpgAwCW01d48Ewd480otIpR0aDmE3tcYLyE)8SqNPhiW7)NLiGhgq(z16APSwrkfD2pfbTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zjYCaKF(8Dpjix587NNf6m9abE))Seb8WaYplPCaz6bQ6qNhAAWWRLATsUwt126APSwrkfD2pfbTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zf5Xhm939KGCBjVFEwOZ0de49)ZseWddi)SKYbKPhOQdDEOPbdVwQ1kBTMQT11szTIuk6SFkcAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAP4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZQdDEOPbd)DV7zzeOijP579ZtcY((5zXIdM(ZIdb7Og6hogO4EwOZ0de49)7EsqUVFEwS4GP)SMGKKPR5qWoQ7mjCa54zHotpqG3)V7jbI99ZZIfhm9NLi9wrWa1KSZ6gK8zHotpqG3)V7jb547NNf6m9abE))SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfNO(4ObpTib97zbGDgCCplI9DpjqmVFEwOZ0de49)ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwO0uBiUNfa2zWX9SKLyE3tcY53ppl0z6bc8()zLgpRjEplwCW0Fws5aY0d8zjLdTZK4ZYiqdWXqJsZNLiGhgq(zrzTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLYAfPu0z)usr)SBh1ser1ksPOZ(PCue5idGAjIOAfPdacpfhc2rTrKaWM2k0z6bculf1sXZskparnoM4ZsYplP8aeFwY(UNeAjVFEwOZ0de49)ZknEwt8EwS4GP)SKYbKPh4ZskhANjXNLnlf1Pb6iWZseWddi)SyXbLIA0rsioRvEuRvkhqMEGkor9XrdEArc63ZskparnoM4ZsYplP8aeFwY(UNeAPVFEwOZ0de49)ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLKFws5q7mj(S6qNhAAWWF3tcTG3ppl0z6bc8()zLgpRaN49SyXbt)zjLditpWNLuo0otIplBoitVTEESGa9bjXNfa2zWX9SAbV7jbzL87NNf6m9abE))SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfp(42t9STl0Imha5NpFwayNbh3ZsYV7jbzL99ZZcDMEGaV)FwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZkMAswgnao426Eg6lpYNfa2zWX9SiM39KGSY99ZZcDMEGaV)FwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZkMAswgnao426Eg6inEwayNbh3ZIyE3tcYsSVFEwOZ0de49)ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwXutYYObWb3w3ZqZgplaSZGJ7zjxj)UNeKvo((5zHotpqG3)pR04zf4eVNfloy6plPCaz6b(SKYH2zs8zrMN2iqbIa6lpsnD7Nfa2zWX9SAPV7jbzjM3ppl0z6bc8()zLgpRaN49SyXbt)zjLditpWNLuo0otIplY80KSmAaCWT19m0xEKplaSZGJ7zjRKF3tcYkNF)8SqNPhiW7)NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SiZttYYObWb3w3ZqZgplaSZGJ7zjlX8UNeKTL8(5zHotpqG3)pR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXgAswgnao426Eg6lpYNLiGhgq(zjshaeEkoeSJAJibGnTFws5biQXXeFwYk5NLuEaIplIvYV7jbzBPVFEwOZ0de49)ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwSHMKLrdGdUTUNH(YJ8zbGDgCCplzL87Esq2wW7NNf6m9abE))SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfBOjzz0a4GBR7zOjZ7zbGDgCCpl5k539KGCL87NNf6m9abE))SsJN1eVNfloy6plPCaz6b(SKYdq8zjxjxBRqTuwlXuBlQwr6aGWtXHGDuBejaSPTcDMEGa1sXZskhANjXNvKgAswgnao426Eg6lpY39KGCL99ZZcDMEGaV)FwPXZAI3ZIfhm9NLuoGm9aFws5bi(SiMAjETYvY12IQLYAfPu0z)uoSX(0DgRLiIQLYAfPdacpfhc2rTrKaWM2k0z6bcuRPAzXbLIA0rsioR9VALYbKPhOItuFC0GNwKG(vlf1srTeVwzjMABr1szTIuk6SFkcAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlloOuuJoscXzTYJATs5aY0duXjQpoAWtlsq)QLINLuo0otIpRlpsnjlJgahCBDpdnB8UNeKRCF)8SqNPhiW7)NvA8SM49SyXbt)zjLditpWNLuEaIpl5k5ABfQLYABP12IQvKoai8uCiyh1grcaBARqNPhiqTu8SKYH2zs8zD5rQjzz0a4GBR7zOJ04DpjixI99ZZcDMEGaV)FwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKZsU2wHAPSwsEEy0wlLhGyTTOALvYsUwkEwIaEya5NLiLIo7NYHn2NUZ4ZskhANjXNfnhb3GAs2zTH4E3tcYvo((5zHotpqG3)pR04znX7zXIdM(ZskhqMEGplP8aeFwTaIP2wHAPSwsEEy0wlLhGyTTOALvYsUwkEwIaEya5NLiLIo7NIG2bK9NLuo0otIplAocUb1KSZAdX9UNeKlX8(5zHotpqG3)pR04znX7zXIdM(ZskhqMEGplP8aeFwTujxBRqTuwljppmARLYdqS2wuTYkzjxlfplrapmG8ZskhqMEGkAocUb1KSZAdXvl1AL8ZskhANjXNfnhb3GAs2zTH4E3tcYvo)(5zHotpqG3)pR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXgAsOdjbj1KSZAdX9SaWodoUNLSeZ7EsqUTK3ppl0z6bc8()zLgpRaN49SyXbt)zjLditpWNLuo0otIpRlpsnjlJwyZrdoFwayNbh3ZsUV7jb52sF)8SqNPhiW7)NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(S4e1xEKAswgTWMJgC(SaWodoUNLCF3tcYTf8(5zHotpqG3)pR04znX7zXIdM(ZskhqMEGplP8aeFwYwBlQwkRfBHGqddeqHKgTdKh6maC2fyTeruTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTuw7Xd0pfhc2rnkStf6m9abQLiIQT11ksPOZ(PiODazVwkQ1uTuwBRRvKsrN9t5OiYrga1ser1YIdkf1OJKqCwl1ALTwIiQ2a0XEgnOAcnStxpVmivOZ0deOwkQ1uTTUwrkfD2pLu0p72rTuulfplPCODMeFwD40g6n60aDmE3tceRKF)8SqNPhiW7)NvA8SM49SyXbt)zjLditpWNLuEaIplSfccnmqafjly6a1tBepnj4ekQLiIQfBHGqddeq1myaiFzm10mqdwlrevl2cbHggiGQzWaq(YyQjraEmGPxlrevl2cbHggiGcGdciZ01aOGaTb4f4uGUaRLiIQfBHGqddeqb9PiapMEG6wii7hiPgaLcfyTeruTyleeAyGaQzcog4DqVrhG0TRLiIQfBHGqddeqnbD6rMaAMep72ZRwIiQwSfccnmqa1hta6ym19iDGAjIOAXwii0Wabu9btI6SRP57g4ZskhANjXNfBOtxdoX39KaXk77NNfloy6plsyezOHKCd(SqNPhiW7)39KaXk33ppl0z6bc8()zjc4HbKFwZeCqdDaL0CWhCG6zoKI(PqNPhiqTeruTZeCqdDaLb48ahOgdqJdMUcDMEGaplwCW0Fw9boTfb3V39KaXsSVFEwOZ0de49)ZseWddi)SePu0z)ue0oGSxRPAdqh7z0GkoeSJAO3Ho8ARqNPhiqTMQvKoai8uCiyh1grcaBARqNPhiqTMQvkhqMEGkE8XTN6zBxOfzoaYpFwRPAzXbLIA0rsioR9VALYbKPhOItuFC0GNwKG(9SyXbt)zfGoQZU2i)W4DpjqSYX3ppl0z6bc8()zjc4HbKFwTUwPCaz6bQmc0aCm0O0SwQ1kBTMQnaDSNrdQaGtb0yaDoARfjjj7ak0z6bc8SyXbt)z1JCE054E3tcelX8(5zHotpqG3)plrapmG8ZQ11kLditpqLrGgGJHgLM1sTwzR1uTTU2a0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQLYABDTIuk6SFkPOF2TJAjIOALYbKPhOQdN2qVrNgOJrTu8SyXbt)zXHGDutp459UNeiw587NNf6m9abE))Seb8WaYpRwxRuoGm9avgbAaogAuAwl1ALTwt126Adqh7z0Gka4uangqNJ2ArssYoGcDMEGa1AQwrkfD2pLu0p72rTMQT11kLditpqvhoTHEJonqhJNfloy6plsyezm1zxFzqI(9UNei2wY7NNf6m9abE))Seb8WaYplPCaz6bQmc0aCm0O0SwQ1k7ZIfhm9Nfknf8bt)DV7zjYCaKF(89ZtcY((5zHotpqG3)plwCW0Fw9iNN2tP8ZcaNIaACW0FwTAaZaEWFpSwWj0BQTjGZr7AHcOyG1(bp7AzdvTYHtSw4v7h8SR9YJS28SX4dor1ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8QLyLCTMQvK5ai)C1LGcBD21NnQj5gOkqgODTMQLYAPb7Dfhc2rTWMJgunpwqqT)rTwPCaz6bQU8i1KSmAHnhn4Swt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2)OwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYRwPCaz6bQU8i1KSmAaCWT19m0SrTuulrevlL126ApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALxTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9pQ12iaQLIAP4Dpji33ppl0z6bc8()zjc4HbKFwbOJ9mAqvtaNJ2AOakgOcDMEGa1AQwrMdG8ZvCiyh1g5hgQazG21AQwkRT11E8a9tH(a2yFOJak0z6bculrevlL1E8a9tH(a2yFOJak0z6bcuRPAjzNvgIRw5rT2wIKRLIAPOwt1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1kVALvY1AQwAWExXHGDulS5ObvZJfeul1APb7Dfhc2rTWMJgurYYONhliOwkQLiIQLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlnyVR4qWoQf2C0GQ5XccQLATsUwkQLIAnvlnyVRcqh1zxBKFyOaYpVwt1sYoRmexTYJATs5aY0duXgAsOdjbj1KSZAdX9SyXbt)z1JCEApLYV7jbI99ZZcDMEGaV)FwIaEya5Nva6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1kYCaKFUIgS31aWPaAmGohT1IKKKDavGmq7AnvlnyVRaGtb0yaDoARfjjj7a6EKZtbKFETMQLYAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubKFETuuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlL1sd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAWzTMQLYAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)rT2gbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALxTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwkRT11E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1kVALYbKPhO6YJutYYObWb3w3ZqZg1srTeruTImha5NR4qWoQnYpmubsYqFw7FuRTraulf1sXZIfhm9NvpY5rNJ7DpjihF)8SqNPhiW7)NLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTImha5NROb7DnaCkGgdOZrBTijjzhqfid0Uwt1sd27ka4uangqNJ2ArssYoGUddubKFETMQ1iqP6gbGswvpY5rNJ7zXIdM(ZQddutp459UNeiM3ppl0z6bc8()zXIdM(ZIegrgtD21xgKOFplaCkcOXbt)z1QmmQTfN)u7h8SRTLB1AH9AHhHZAfjj0BQf0O2zMUQ2wzVw4v7hCmQLgRfCIa1(bp7A)jVwS51k45vl8QDoGn23ODT0ypd8zjc4HbKFwImha5NRUeuyRZU(Srnj3avbsYqFw7F1kLditpqfzEAJaficOV8i10TRLiIQLYALYbKPhO6GKOg0p4qZg1kVALYbKPhOImpnjlJgahCBDpdnBuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5vRuoGm9avK5Pjzz0a4GBR7zOV8iRLI39KGC(9ZZcDMEGaV)FwIaEya5NLiZbq(5koeSJAJ8ddvGmq7AnvlL126ApEG(PqFaBSp0raf6m9abQLiIQLYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXvR8OwBlrY1srTuuRPAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZALxTs5aY0duXgAswgnao426Eg6lpYAnvlnyVR4qWoQf2C0GQ5XccQLAT0G9UIdb7OwyZrdQizz0ZJfeulf1ser1szTImha5NRUeuyRZU(Srnj3avbsYqFwl1ALCTMQLgS3vCiyh1cBoAq18ybb1sTwjxlf1srTMQLgS3vbOJ6SRnYpmua5NxRPAjzNvgIRw5rTwPCaz6bQydnj0HKGKAs2zTH4EwS4GP)SiHrKXuND9Lbj637EsOL8(5zHotpqG3)plrapmG8ZskhqMEGQe8MqauNDTiZbq(5ZAnvlL1otWbn0busZbFWbQN5qk6NcDMEGa1ser1otWbn0bugGZdCGAmanoy6k0z6bculfplwCW0Fw9boTfb3V39Kql99ZZcDMEGaV)FwS4GP)Saq(SPZWXNfaofb04GP)SA5Xh3Ewl4eRfa5ZModhR9dE21YgQABL9AV8iRfoRnqgODT8S2pCmmVwsMaS2jyG1EzTcEE1cVAPXEgyTxEKQNLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufid0Uwt1sd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATncG39Kql49ZZcDMEGaV)FwIaEya5NLiZbq(5koeSJAJ8ddvGmq7AnvlL126ApEG(PqFaBSp0raf6m9abQLiIQLYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXvR8OwBlrY1srTuuRPAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZALxTYk5AnvlnyVR4qWoQf2C0GQ5XccQLAT0G9UIdb7OwyZrdQizz0ZJfeulf1ser1szTImha5NRUeuyRZU(Srnj3avbYaTR1uT0G9UIdb7OwyZrdQMhliOwQ1k5APOwkQ1uT0G9UkaDuNDTr(HHci)8Anvlj7SYqC1kpQ1kLditpqfBOjHoKeKutYoRne3ZIfhm9NfaYNnDgo(UNeKvYVFEwOZ0de49)ZIfhm9NvWaq2p90GdcEwa4ueqJdM(ZsoCI1on4GGAH9AV8iRLDGAzJA5aRn9Afa1YoqTFPt4vlnwlOrT9mQDKEdg1E2Sx7zJ1sYYulao42Mxljta0BQDcgyTFyT2SuSw(QDG88Q9(YA5qWowRWMJgCwl7a1E28v7LhzTF80j8QTveCE1cora1ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKKH(Sw5vRuoGm9avXutYYObWb3w3ZqF5rwRPAfzoaYpxXHGDuBKFyOcKKH(Sw5vRuoGm9avXutYYObWb3w3ZqZg1AQwkR94b6NkaDuNDTr(HHcDMEGa1AQwkRvK5ai)Cva6Oo7AJ8ddvGKm0N1(xTOmOa8q9bjXAjIOAfzoaYpxfGoQZU2i)Wqfijd9zTYRwPCaz6bQIPMKLrdGdUTUNHosJAPOwIiQ2wx7Xd0pva6Oo7AJ8ddf6m9abQLIAnvlnyVR4qWoQf2C0GQ5XccQvE1k3Anvlasd27Qlbf26SRpButYnqfq(51AQwAWExfGoQZU2i)WqbKFETMQLgS3vCiyh1g5hgkG8ZF3tcYk77NNf6m9abE))SyXbt)zfmaK9tpn4GGNfaofb04GP)SKdNyTtdoiO2p4zxlBu7Nn61AKZjKEGQABL9AV8iRfoRnqgODT8S2pCmmVwsMaS2jyG1EzTcEE1cVAPXEgyTxEKQNLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufijd9zT)vlkdkapuFqsSwt1sd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)RwkRfLbfGhQpijwlXRLfhmD1LGcBD21NnQj5gOcLbfGhQpijwlfV7jbzL77NNf6m9abE))Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR9VArzqb4H6dsI1AQwkRLYABDThpq)uOpGn2h6iGcDMEGa1ser1szThpq)uOpGn2h6iGcDMEGa1AQws2zLH4QvEuRTLi5APOwkQ1uTuwlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTYRwPCaz6bQydnjlJgahCBDpd9LhzTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQLIAjIOAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATsUwt1sd27koeSJAHnhnOAESGGAPwRKRLIAPOwt1sd27Qa0rD21g5hgkG8ZR1uTKSZkdXvR8OwRuoGm9avSHMe6qsqsnj7S2qC1sXZIfhm9NvWaq2p90GdcE3tcYsSVFEwOZ0de49)ZIfhm9N1LGcBD21NnQj5g4ZcaNIaACW0FwYHtS2lpYA)GNDTSrTWETWJWzTFWZg61E2yTKSm1cGdUTQ2wzVwppZRfCI1(bp7AJ0OwyV2ZgR94b6xTWzThta6Mxl7a1cpcN1(bpBOx7zJ1sYYulao42QNLiGhgq(zrd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)JATOmOa8q9bjXAnvlj7SYqC1kVALYbKPhOIn0KqhscsQjzN1gIRwt1sd27Qa0rD21g5hgkG8ZF3tcYkhF)8SqNPhiW7)NLiGhgq(zrd27koeSJAHnhnOAESGGA)JATs5aY0duD5rQjzz0cBoAWzTMQ94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7FuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1kVALYbKPhO6YJutYYObWb3w3ZqZgplwCW0FwxckS1zxF2OMKBGV7jbzjM3ppl0z6bc8()zjc4HbKFw0G9UIdb7OwyZrdQMhliO2)OwRuoGm9avxEKAswgTWMJgCwRPAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQLiIQvK5ai)Cva6Oo7AJ8ddvGKm0N1kVALYbKPhO6YJutYYObWb3w3ZqhPrTuuRPALYbKPhO6GKOg0p4qZg1kVALYbKPhO6YJutYYObWb3w3ZqZgplwCW0FwxckS1zxF2OMKBGV7jbzLZVFEwOZ0de49)ZIfhm9Nfhc2rTr(HXZcaNIaACW0FwYHtSw2OwyV2lpYAHZAtVwbqTSdu7x6eE1sJ1cAuBpJAhP3GrTNn71E2yTKSm1cGdUT51sYea9MANGbw7zZxTFyT2SuSw0tWg7AjzNRLDGApB(Q9SXaRfoR1ZRwEeid0UwU2a0XAZETg5hg1cKFU6zjc4HbKFwImha5NRUeuyRZU(Srnj3avbsYqFwR8QvkhqMEGk2qtYYObWb3w3ZqF5rwRPAPS2wxRiLIo7Nsk6ND7OwIiQwrMdG8ZvKWiYyQZU(YGe9tfijd9zTYRwPCaz6bQydnjlJgahCBDpdnzE1srTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uT0G9UkaDuNDTr(HHci)8Anvlj7SYqC1kpQ1kLditpqfBOjHoKeKutYoRne37Esq2wY7NNf6m9abE))SyXbt)zfGoQZU2i)W4zbGtranoy6pl5WjwBKg1c71E5rwlCwB61kaQLDGA)sNWRwASwqJA7zu7i9gmQ9SzV2ZgRLKLPwaCWTnVwsMaO3u7emWApBmWAHtNWRwEeid0UwU2a0XAbYpVw2bQ9S5Rw2O2V0j8QLgfjjwllLHdMEG1cagqVP2a0r1ZseWddi)SOb7Dfhc2rTr(HHci)8AnvlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTYRwPCaz6bQI0qtYYObWb3w3ZqF5rwlrevRiZbq(5koeSJAJ8ddvGKm0N1(h1ALYbKPhO6YJutYYObWb3w3ZqZg1srTMQLgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uTImha5NR4qWoQnYpmubsYqFwR8Qvw5(UNeKTL((5zHotpqG3)plrapmG8ZskhqMEGQe8MqauNDTiZbq(5ZNfloy6pRPnSFqVrBKFy8UNeKTf8(5zHotpqG3)plwCW0FwgborxG6SRjHoWZcaNIaACW0FwYHtSwJKS2lRD2cbr83dRL9ArzUGRLPRf61E2yTokZvRiZbq(51(bDG8Z8Ab9boN1sq7aYETNn61M(ODTaGb0BQLdb7yTg5hg1caI1EzT25xTKSZ1Ad6nr7AdgaY(v70GdcQfoFwIaEya5N1Xd0pva6Oo7AJ8ddf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAPb7Dva6Oo7AJ8ddvGKm0N1(xTncafjlZ7EsqUs(9ZZcDMEGaV)FwIaEya5Nfasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)RwwCW0vCiyh1KW5eoWPcLbfGhQpijwRPABDTIuk6SFkcAhq2FwS4GP)SmcCIUa1zxtcDG39KGCL99ZZcDMEGaV)FwIaEya5NfnyVRcqh1zxBKFyOanQ1uT0G9UkaDuNDTr(HHkqsg6ZA)R2gbGIKLPwt1kYCaKFUcLMc(GPRcKbAxRPAfzoaYpxDjOWwND9zJAsUbQcKKH(Swt126AfPu0z)ue0oGS)SyXbt)zze4eDbQZUMe6aV7DplBoitV97NNeK99ZZcDMEGaV)FwS4GP)SqPPGpy6plaCkcOXbt)z1k71oYVAtVws25AzhOwrMdG8ZN1YbwRijHEtTGgMxBtwlBJmqTSdulknFwIaEya5Nfj7SYqC1(h1AjwjxRPALYbKPhOkbVjea1zxlYCaKF(Swt1szThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZA)RwzLCTu8UNeK77NNf6m9abE))SaWPiGghm9NLCaw7h7xTxw78ybb1AZbz6TRTdogTv1(Jnwl4eRn71kRCU25XccM1AJbwlCw7L1Ycrc6xT9mQ9SXApOGGAhy)Qn9ApBSwHn7ooQLDGApBSws4CchyTqV2(a2yFQNLiGhgq(zrzTs5aY0dunpwqG2MdY0Bxlrev7bjXA)RwzLCTuuRPAPb7Dfhc2rTnhKP3wnpwqqT)vRSY5NLWMH(Zs2Nfloy6ploeSJAs4Cch48DpjqSVFEwOZ0de49)ZIfhm9Nfhc2rnjCoHdC(SaWPiGghm9NLCGn61coHEtTYjKgTdKh1(7hao7c08Af88QLRTJF1IYCbxljCoHdCw7NnCG1(XWd6n12ZO2ZgRLgS3RLVApBS25XXvB2R9SXA7Wg77zjc4HbKFwyleeAyGakK0ODG8qNbGZUaR1uThKeR9VAjwjxRPAVSPzGkrMdG8ZN1AQwrMdG8ZviPr7a5HodaNDbQcKKH(Sw5vRSY5wATMQT11YIdMUcjnAhip0za4SlqfaCY0de4DpjihF)8SqNPhiW7)NLiGhgq(zjLditpqfsAKFyGaAAocUbR1uTImha5NRUeuyRZU(Srnj3avbsYqFw7FuRfLbfGhQpijwRPAfzoaYpxXHGDuBKFyOcKKH(S2)OwlL1IYGcWd1hKeRTfvRCRLIAnvlL126AXwii0WabuZeCmW7GEJoaPBxlrevRiDaq4P4qWoQnIea20wfStqTYJATetTeruTImha5NRMj4yG3b9gDas3wfijd9zT)rTwkRfLbfGhQpijwBlQw5wlf1sXZIfhm9NvWaq2p90GdcE3tceZ7NNf6m9abE))Seb8WaYplPCaz6bQAfbNNgCIa6PbheuRPAfzoaYpxXHGDuBKFyOcKKH(S2)OwlkdkapuFqsSwt1szTTUwSfccnmqa1mbhd8oO3Odq621ser1kshaeEkoeSJAJibGnTvb7euR8OwlXulrevRiZbq(5Qzcog4DqVrhG0TvbsYqFw7FuRfLbfGhQpijwlfplwCW0FwxckS1zxF2OMKBGV7jb587NNf6m9abE))Seb8WaYplJaLQBeakzvxckS1zxF2OMKBGplwCW0FwCiyh1g5hgV7jHwY7NNf6m9abE))Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQvK5ai)CvWaq2p90GdcubsYqFw7FuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1kpQ1kxjxRPAPS2wxRiDaq4P4qWoQnIea20wHotpqGAjIOABDTs5aY0duXJpU9upB7cTiZbq(5ZAjIOAfzoaYpxDjOWwND9zJAsUbQcKKH(S2)OwlL1IYGcWd1hKeRTfvRCRLIAP4zXIdM(ZkaDuNDTr(HX7EsOL((5zHotpqG3)plrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAncuQUraOKvfGoQZU2i)W4zXIdM(Zkyai7NEAWbbV7jHwW7NNf6m9abE))Seb8WaYplPCaz6bQAfbNNgCIa6PbheuRPABDTs5aY0duzNdaO3OV8iFwS4GP)SUeuyRZU(Srnj3aF3tcYk53ppl0z6bc8()zXIdM(ZIdb7OMMJGBWNfaofb04GP)SKdNyTY1bQLdb7yT0CeCdwl0RTLBvI)7(9B1AtF0UwyV2)hzcmaNxTSdulF1oqEE1k3A)1VM1AePqGaplrapmG8ZIgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uT0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfOrTMQLgS3vCiyh12CqMEB18ybb1kpQ1kRCUwt1sd27koeSJAJ8ddvGKm0N1(h1AzXbtxXHGDutZrWnOcLbfGhQpijwRPAPb7Df9itGb48uGgV7jbzL99ZZcDMEGaV)FwS4GP)Scqh1zxBKFy8SaWPiGghm9NLC4eRvUoqT)USvRf612YTATPpAxlSx7)JmbgGZRw2bQvU1(RFnR1isXZseWddi)SOb7Dva6Oo7AJ8ddfq(51AQwAWExrpYeyaopfOrTMQLYALYbKPhO6GKOg0p4qZg1kVAjwjxlrevRiZbq(5QGbGSF6PbheOcKKH(Sw5vRSYTwkQ1uTuwlnyVR4qWoQT5Gm92Q5XccQvEuRvwIPwIiQwAWExjgihcEEqVrnpwqqTYJATYwlf1AQwkRT11kshaeEkoeSJAJibGnTvOZ0deOwIiQ2wxRuoGm9av84JBp1Z2UqlYCaKF(SwkE3tcYk33ppl0z6bc8()zjc4HbKFw0G9UIdb7O2i)WqbKFETMQLYALYbKPhO6GKOg0p4qZg1kVAjwjxlrevRiZbq(5QGbGSF6PbheOcKKH(Sw5vRSYTwkQ1uTuwBRRvKoai8uCiyh1grcaBARqNPhiqTeruTTUwPCaz6bQ4Xh3EQNTDHwK5ai)8zTu8SyXbt)zfGoQZU2i)W4DpjilX((5zHotpqG3)plrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAPSwAWExXHGDulS5ObvZJfeuR8OwRCRLiIQvK5ai)Cfhc2rDg0QazG21srTMQLYABDThpq)ubOJ6SRnYpmuOZ0deOwIiQwrMdG8ZvbOJ6SRnYpmubsYqFwR8QLyQLIAnvRuoGm9av48GK8HaA2qlYCaKFETYJATeRKR1uTuwBRRvKoai8uCiyh1grcaBARqNPhiqTeruTTUwPCaz6bQ4Xh3EQNTDHwK5ai)8zTu8SyXbt)zfmaK9tpn4GG39KGSYX3ppl0z6bc8()zXIdM(Z6sqHTo76Zg1KCd8zbGtranoy6pl5aB0RnaDh6n1AejaSPT51coXAV8iRLUDTWBIJETqV2maWO2lRLhWgVw4v7h8SRLnEwIaEya5NLuoGm9avhKe1G(bhA2O2)QLyKCTMQvkhqMEGQdsIAq)GdnBuR8QLyLCTMQLYABDTyleeAyGaQzcog4DqVrhG0TRLiIQvKoai8uCiyh1grcaBARc2jOw5rTwIPwkE3tcYsmVFEwOZ0de49)ZseWddi)SKYbKPhOQveCEAWjcONgCqqTMQLgS3vCiyh1cBoAq18ybb1(xT0G9UIdb7OwyZrdQizz0ZJfe8SyXbt)zXHGDuNb97Esqw587NNf6m9abE))Seb8WaYplaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhliOwQ1cG0G9Ukyai7NEAWbbAPGdhdMgoGxBfjlJEESGGNfloy6ploeSJAAocUbF3tcY2sE)8SqNPhiW7)NLiGhgq(zjLditpqvRi480Gteqpn4GGAjIOAPSwaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARanQ1uTainyVRcgaY(PNgCqGwk4WXGPHd41wnpwqqT)vlasd27QGbGSF6PbheOLcoCmyA4aETvKSm65XccQLINfloy6ploeSJA6bpV39KGST03ppl0z6bc8()zXIdM(ZIdb7OMMJGBWNfaofb04GP)SKdNyTKqhw7)CeCdwlnEFi61gmaK9R2PbhemRf2Rf0bWO2)LOA)GNDcE1cGdUn0BQ93Xaq2VATm4GGAHaipgTFwIaEya5NfnyVRcqh1zxBKFyOanQ1uT0G9UIdb7O2i)WqbKFETMQLgS3v0JmbgGZtbAuRPAfzoaYpxfmaK9tpn4GavGKm0N1(h1ALvY1AQwAWExXHGDuBZbz6TvZJfeuR8OwRSY539KGSTG3ppl0z6bc8()zXIdM(ZIdb7Ood6Nfaofb04GP)SKdNyTzqxB61kaQf0h4CwlBulCwRijHEtTGg1oZ0FwIaEya5NfnyVR4qWoQf2C0GQ5XccQ9VAj2AnvRuoGm9avhKe1G(bhA2Ow5vRSsUwt1szTImha5NRUeuyRZU(Srnj3avbsYqFwR8QLyQLiIQT11kshaeEkoeSJAJibGnTvOZ0deOwkE3tcYvYVFEwOZ0de49)ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVR4qWoQnYpmuGgV7jb5k77NNf6m9abE))SyXbt)zXHGDutZrWn4ZcaNIaACW0FwTYETFyTn4vRr(HrTqVdoHPxlaya9MAhGZR2pKWXOwBwkwl6jyJDT288WAVS2g8Qn79A5ANxKEtT0CeCdwlaya9MApBS2inKeBu7h0bYVNLiGhgq(zrd27Qa0rD21g5hgkqJAnvlnyVRcqh1zxBKFyOcKKH(S2)Owlloy6koeSJAs4Cch4uHYGcWd1hKeR1uT0G9UIdb7O2i)WqbAuRPAPb7Dfhc2rTWMJgunpwqqTuRLgS3vCiyh1cBoAqfjlJEESGGAnvlnyVR4qWoQT5Gm92Q5XccQ1uT0G9UYi)Wqd9o4eMUc0Owt1sd27k6rMadW5PanE3tcYvUVFEwOZ0de49)ZIfhm9Nfhc2rn9GN3ZcaNIaACW0FwTYETFyTn4vRr(HrTqVdoHPxlaya9MAhGZR2pKWXOwBwkwl6jyJDT288WAVS2g8Qn79A5ANxKEtT0CeCdwlaya9MApBS2inKeBu7h0bYpZRDM1(Heog1M(ODTGtSw0tWg7APh88M1cD4b5XODTxwBdE1EzT9emQvyZrdoFwIaEya5NfnyVRmcCIUa1zxtcDafOrTMQLYAPb7Dfhc2rTWMJgunpwqqT)vlnyVR4qWoQf2C0Gkswg98ybb1ser126APSwAWExzKFyOHEhCctxbAuRPAPb7Df9itGb48uGg1srTu8UNeKlX((5zHotpqG3)plwCW0FwgborxG6SRjHoWZcaNIaACW0Fw)yJ1sJZRwWjwB2R1ijRfoR9YAbNyTWR2lRTfccfemAxlniCauRWMJgCwlaya9MAzJA5(HrTNn2U2g8QfaK0abQLUDTNnwRnhKP3UwAocUbFwIaEya5NfnyVR4qWoQf2C0GQ5XccQ9VAPb7Dfhc2rTWMJgurYYONhliOwt1sd27koeSJAJ8ddfOX7EsqUYX3ppl0z6bc8()zbGtranoy6pl5aS2p2VAVS25XccQ1MdY0BxBhCmARQ9hBSwWjwB2Rvw5CTZJfemR1gdSw4S2lRLfIe0VA7zu7zJ1Eqbb1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uplwCW0FwCiyh1KW5eoW5Zc6hgbOX9SK9zjSzO)SK9zjc4HbKFw0G9UIdb7O2MdY0BRMhliO2)Qvw58Zc6hgbOXPBgjnpEwY(UNeKlX8(5zHotpqG3)plrapmG8ZIgS3vCiyh1cBoAq18ybb1sTwAWExXHGDulS5ObvKSm65XccQ1uTs5aY0duHKg5hgiGMMJGBWNfloy6ploeSJAAocUbF3tcYvo)(5zHotpqG3)plrapmG8ZIKDwziUA)RwzjMNfloy6pluAk4dM(7EsqUTK3ppl0z6bc8()zXIdM(ZIdb7OMEWZ7zbGtranoy6pRFFF0UwWjwl9GNxTxwlniCauRWMJgCwlSx7hwlpcKbAxRnlfRDMKyT9ijRnd6NLiGhgq(zrd27koeSJAHnhnOAESGGAnvlnyVR4qWoQf2C0GQ5XccQ9VAPb7Dfhc2rTWMJgurYYONhli4Dpji3w67NNf6m9abE))SaWPiGghm9NLC6GJrTFWZUwMSwqFGZzTSrTWzTIKe6n1cAul7a1(HegyTJ8R20RLKD(zXIdM(ZIdb7OMeoNWboFwq)WianUNLSplHnd9NLSplrapmG8ZQ11szTs5aY0duDqsud6hCOzJA)JATYk5Anvlj7SYqC1(xTeRKRLINf0pmcqJt3msAE8SK9Dpji3wW7NNf6m9abE))SaWPiGghm9NvRgzhoWzTFWZU2r(vljppmABET2Wg7AT55HMxBg1sNNDTKC7A98Q1MLI1IEc2yxlj7CTxw7e0WiJRw78Rws25AH(H(ekfRnyai7xTtdoiOwb71sJMx7mR9djCmQfCI12Hbwl9GNxTSduBpY5rNJR2pB0RDKF1METKSZplwCW0FwDyGA6bpV39KaXk53pplwCW0Fw9iNhDoUNf6m9abE))U39Se8qao4dM(89ZtcY((5zHotpqG3)pR04znX7zXIdM(ZskhqMEGplP8aeFwY(Seb8WaYplPCaz6bQSzPOonqhbQLATsUwt1AeOuDJaqjRcLMc(GPxRPABDTuwBa6ypJgunHg2PRNxgKk0z6bculrevBa6ypJguDiPrg8q)XHHcDMEGa1sXZskhANjXNLnlf1Pb6iW7EsqUVFEwOZ0de49)ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZskhqMEGkBwkQtd0rGAPwRKR1uT0G9UIdb7O2i)WqbKFETMQvK5ai)Cfhc2rTr(HHkqsg6ZAnvlL1gGo2ZObvtOHD665LbPcDMEGa1ser1gGo2ZObvhsAKbp0FCyOqNPhiqTu8SKYH2zs8zzZsrDAGoc8UNei23ppl0z6bc8()zLgpRjEplwCW0Fws5aY0d8zjLhG4Zs2NLiGhgq(zrd27koeSJAHnhnOAESGGAPwlnyVR4qWoQf2C0Gkswg98ybb1AQ2wxlnyVRcWbQZU(SdeNkqJAnvBh2yF6ajzOpR9pQ1szTuwlj7CTsQwwCW0vCiyh10dEEkroVAPO2wuTS4GPR4qWoQPh88uOmOa8q9bjXAP4zjLdTZK4ZQdDEOPbd)DpjihF)8SqNPhiW7)NvA8SM49SyXbt)zjLditpWNLuEaIplAWExXHGDuBZbz6TvZJfeuR8OwRSetTeruTuwBa6ypJguXHGDutNK0CaqI(PqNPhiqTMQ94ObpLnYJZwziUA)RwILyQLINfaofb04GP)SKtGNng1Y12bhJ21opwqacuRnhKP3U2mQf61IYGcWdRnyVbR9dE21(FssZbaj63ZskhANjXNfsAKFyGaAAocUbF3tceZ7NNf6m9abE))SsJN1eVNfloy6plPCaz6b(SKYH2zs8zn45Pzdn4eFwayNbh3ZsYplrapmG8ZIgS3vCiyh1g5hgkqJAnvlL1kLditpq1GNNMn0GtSwQ1k5AjIOApijwR8OwRuoGm9avdEEA2qdoXAjETYsm1sXZskpaXN1bjX39KGC(9ZZcDMEGaV)FwPXZAI3ZIfhm9NLuoGm9aFws5bi(SOSwrMdG8ZvCiyh1g5hgkaWGpy612IQLYALT2wHAPSwjRKmXwBlQwr6aGWtXHGDuBejaSPTkyNGAPOwkQLIABfQLYApijwBRqTs5aY0dun45Pzdn4eRLINfaofb04GP)SA5qWowBRgjaSPDTnqP4SwUwPCaz6bwltMG(vB2RvaeMxln4v7hs4yul4eRLRTp4RwCEqs(GPxRngOQ2FSXANqsrTgrkfcGa1gijd9PgLXafhculkJrGZjm9AbsCwRNxTFzqqTF4yuBpJAnIea20UwaqS2lR9SXAPbJ51UwNpWaRn71E2yTcGq9SKYH2zs8zHZdsYhcOzdTiZbq(5V7jHwY7NNf6m9abE))SsJN1eVNfloy6plPCaz6b(SKYdq8zjLditpqfopijFiGMn0Imha5N)Seb8WaYplr6aGWtXHGDuBejaSP9ZskhANjXN1bjrnOFWHMnE3tcT03ppl0z6bc8()zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsK5ai)Cfhc2rTr(HHkqsg6ZNLiGhgq(z16AfPdacpfhc2rTrKaWM2k0z6bc8SKYH2zs8zDqsud6hCOzJ39Kql49ZZcDMEGaV)FwPXZIKL5zXIdM(ZskhqMEGplPCODMeFwhKe1G(bhA24zjc4HbKFwuwRiZbq(5Qlbf26SRpButYnqvGKm0N12kuRuoGm9avhKe1G(bhA2OwkQ9VALRKFwa4ueqJdM(ZsoajCmQfahC7AB5wTwqJAVSw5k5jkQTNrT)Kxl(zjLhG4ZsK5ai)C1LGcBD21NnQj5gOkqsg6Z39KGSs(9ZZcDMEGaV)FwPXZIKL5zXIdM(ZskhqMEGplPCODMeFwhKe1G(bhA24zjc4HbKFwI0baHNIdb7O2isayt7AnvRiDaq4P4qWoQnIea20wfStqT)vlXuRPAXwii0WabuZeCmW7GEJoaPBxRPAfPu0z)ue0oGSxRPAdqh7z0GkoeSJABoitVTcDMEGaplaCkcOXbt)zzbDbw7VdKUDTWzTtqHDTCTg5hgDWrTxaDcWR2Eg1kN(2bKDZR9djCmQDEqbb1EzTNnw79L1scDWdRv0wmWAb9doQ9dRTbVA5ATHn21IEc2yxBWob1M9AnIea20(zjLhG4ZsK5ai)C1mbhd8oO3Odq62QajzOpF3tcYk77NNf6m9abE))SsJN1eVNfloy6plPCaz6b(SKYdq8zjYCaKFU6sqHTo76Zg1KCdufid0Uwt1kLditpq1bjrnOFWHMnQ9VALRKFwa4ueqJdM(ZsoajCmQfahC7A)jVwCTGg1EzTYvYtuuBpJAB5w9zjLdTZK4ZYohaqVrF5r(UNeKvUVFEwOZ0de49)ZknEwt8EwS4GP)SKYbKPh4ZskpaXNfL1AeOuDJaqjRkyai7NEAWbb1ser1AeOuDJaqjxvWaq2p90GdcQLiIQ1iqP6gbGIyvbdaz)0tdoiOwkQ1uTainyVRcgaY(PNgCqGwk4WXGPHd41wbKF(ZcaNIaACW0Fw)ogaY(vRLbheulqIZA98QfssIaq(Wr7AnaVAbnQ9SXALcoCmyA4aETRfaPb79ANzTWRwb71sJ1ca7DOaCC1EzTaWPadV2ZMVA)qcdSw(Q9SXA)9Wip7ALcoCmyA4aETRDESGGNLuo0otIpRwrW5PbNiGEAWbbV7jbzj23ppl0z6bc8()zLgpRjEplwCW0Fws5aY0d8zjLhG4ZIgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHci)8Anvlasd27Qlbf26SRpButYnqfq(51AQ2wxRuoGm9avTIGZtdora90GdcQ1uTainyVRcgaY(PNgCqGwk4WXGPHd41wbKF(ZskhANjXNvcEtiaQZUwK5ai)857Esqw547NNf6m9abE))SsJN1eVNfloy6plPCaz6b(SKYdq8zfGo2ZObvCiyh12CqMEBf6m9abQ1uTuwlL1ksPOZ(PiODazVwt1kYCaKFUkyai7NEAWbbQajzOpR9VALYbKPhOYMdY0BRNhliqFqsSwkQLINLuo0otIpR5Xcc02CqME739UNvh68qtdg(7NNeK99ZZcDMEGaV)FwS4GP)S4qWoQjHZjCGZNLWMH(Zs2NLiGhgq(zrd27kXa5qWZd6nQazX9UNeK77NNfloy6ploeSJA6bpVNf6m9abE))UNei23pplwCW0FwCiyh10CeCd(SqNPhiW7)39U39SKIXeM(tcYvYYvwj3sKmX8S(4WHEZ8zjh0Y)oj0kLGCksCT1(JnwlK0iJR2Eg1sOnhKP3MWAdSfccdeO2zsI1YGxsYhcuRWM9gCQkZKiOJ1kRex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTYrjU2FLUumoeOwcVa6eGNIPfkrMdG8ZjS2lRLqrMdG8ZvmTGWAPuwzOqvMjrqhRLyK4A)v6sX4qGAj8cOtaEkMwOezoaYpNWAVSwcfzoaYpxX0ccRLszLHcvzMebDS2wIex7VsxkghculHI0baHNs(ew7L1sOiDaq4PKVcDMEGaewlLYkdfQYmjc6yTYkRex7VsxkghculHI0baHNs(ew7L1sOiDaq4PKVcDMEGaewlLYkdfQYmjc6yTYkxjU2FLUumoeOwcfPdacpL8jS2lRLqr6aGWtjFf6m9abiSwkLvgkuLzse0XALLyL4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuwzOqvMjrqhRvwIvIR9xPlfJdbQLqr6aGWtjFcR9YAjuKoai8uYxHotpqacRLszLHcvzMebDSwzBbsCT)kDPyCiqTekshaeEk5tyTxwlHI0baHNs(k0z6bcqyTukRmuOkZkZKdA5FNeALsqofjU2A)XgRfsAKXvBpJAjSdN2qVrNgOJbH1gyleegiqTZKeRLbVKKpeOwHn7n4uvMjrqhRvwjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuUYqHQmtIGowRCL4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuwzOqvMjrqhRLyL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSw5Oex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZKiOJ1smsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCwIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSw(Qvo53xIQLszLHcvzMebDS2wGex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZKiOJ12cK4A)v6sX4qGAjuKoai8uYNWAVSwcfPdacpL8vOZ0deGWA5Rw5KFFjQwkLvgkuLzse0XALvUsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPCLHcvzMebDSwzjgjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRvUswIR9xPlfJdbQLWJhOFk5tyTxwlHhpq)uYxHotpqacRLszLHcvzMebDSw5sSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPCLHcvzMebDSw5sSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1YxTYj)(suTukRmuOkZKiOJ1kxIrIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSw(Qvo53xIQLszLHcvzMebDSw5kNL4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuwzOqvMvMjh0Y)oj0kLGCksCT1(JnwlK0iJR2Eg1syKhFW0jS2aBHGWabQDMKyTm4LK8Ha1kSzVbNQYmjc6yTYkX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPSYqHQmtIGowRCL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSw5Oex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTeJex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTTajU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLvgkuLzse0XALTLkX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPSYqHQmtIGowRSTujU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRv2wGex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTY2cK4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSw5kzjU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLvgkuLzse0XALRSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCLRex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZkZKdA5FNeALsqofjU2A)XgRfsAKXvBpJAjmnqhdcRnWwiimqGANjjwldEjjFiqTcB2BWPQmtIGowRSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSwzLRex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTYsmsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1YxTYj)(suTukRmuOkZKiOJ1kRCwIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSw(Qvo53xIQLszLHcvzMebDSwzBjsCT)kDPyCiqTeE8a9tjFcR9YAj84b6Ns(k0z6bcqyTukRmuOkZkZKdA5FNeALsqofjU2A)XgRfsAKXvBpJAjea7m44iS2aBHGWabQDMKyTm4LK8Ha1kSzVbNQYmjc6yTYvIR9xPlfJdbQLWJhOFk5tyTxwlHhpq)uYxHotpqacRLs5kdfQYmjc6yTYrjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRvw5Oex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZKiOJ1kRCwIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALTLkX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYvUsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1YxTYj)(suTukRmuOkZKiOJ1kxIvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALRCuIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALlXiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYvolX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYTLiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYSYm5Gw(3jHwPeKtrIRT2FSXAHKgzC12ZOwcncuKK08ryTb2cbHbcu7mjXAzWlj5dbQvyZEdovLzse0XALZsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCwIR9xPlfJdbQLqr6aGWtjFcR9YAjuKoai8uYxHotpqacRLszLHcvzMebDSw5kzjU2FLUumoeOwcfPdacpL8jS2lRLqr6aGWtjFf6m9abiSwkLvgkuLzse0XALRSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCLvIR9xPlfJdbQLqr6aGWtjFcR9YAjuKoai8uYxHotpqacRLszLHcvzMebDSw5kxjU2FLUumoeOwcfPdacpL8jS2lRLqr6aGWtjFf6m9abiSwkLvgkuLzse0XALBlqIR9xPlfJdbQLWJhOFk5tyTxwlHhpq)uYxHotpqacRLs5kdfQYmjc6yTYTfiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTeRCL4A)v6sX4qGAjCMGdAOdOKpH1EzTeotWbn0buYxHotpqacRLszLHcvzMebDSwIvUsCT)kDPyCiqTeotWbn0buYNWAVSwcNj4Gg6ak5RqNPhiaH1YxTYj)(suTukRmuOkZKiOJ1sSeRex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZKiOJ1sSeRex7VsxkghculHI0baHNs(ew7L1sOiDaq4PKVcDMEGaewlLYkdfQYmjc6yTeRCuIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSw(Qvo53xIQLszLHcvzMebDSwILyK4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSwIvolX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYSYm5Gw(3jHwPeKtrIRT2FSXAHKgzC12ZOwcfzoaYpFsyTb2cbHbcu7mjXAzWlj5dbQvyZEdovLzse0XALvIR9xPlfJdbQLWJhOFk5tyTxwlHhpq)uYxHotpqacRLs5kdfQYmjc6yTYkX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYvIR9xPlfJdbQLWJhOFk5tyTxwlHhpq)uYxHotpqacRLs5kdfQYmjc6yTYvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XAjwjU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLRmuOkZKiOJ1sSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCuIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALZsCT)kDPyCiqTeE8a9tjFcR9YAj84b6Ns(k0z6bcqyTukxzOqvMjrqhRTLiX1(R0LIXHa1s4mbh0qhqjFcR9YAjCMGdAOdOKVcDMEGaewlLYvgkuLzse0XABbsCT)kDPyCiqTeE8a9tjFcR9YAj84b6Ns(k0z6bcqyTukxzOqvMjrqhRvwjlX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPCLHcvzMebDSwzLRex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYvgkuLzse0XALvokX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPSYqHQmtIGowRSeJex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTY2cK4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuwzOqvMvMjh0Y)oj0kLGCksCT1(JnwlK0iJR2Eg1siNiH1gyleegiqTZKeRLbVKKpeOwHn7n4uvMjrqhRvwjU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLRmuOkZKiOJ1kRex7VsxkghculHbOJ9mAqL8jS2lRLWa0XEgnOs(k0z6bcqyTukRmuOkZKiOJ1kxjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuUYqHQmtIGowlXkX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPCLHcvzMebDSwIvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALJsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowlXiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYzjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRTLiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTTujU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRTfiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYkzjU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLRmuOkZKiOJ1kRSsCT)kDPyCiqTeE8a9tjFcR9YAj84b6Ns(k0z6bcqyTukxzOqvMjrqhRvw5Oex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYvgkuLzse0XALTLiX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1YxTYj)(suTukRmuOkZKiOJ1kBlvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALTfiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYvYsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCLvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XALRCL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSw5sSsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCLJsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCjgjU2FLUumoeOwcpEG(PKpH1EzTeE8a9tjFf6m9abiSwkLvgkuLzse0XALlXiX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlLYkdfQYmjc6yTYvolX1(R0LIXHa1s4Xd0pL8jS2lRLWJhOFk5RqNPhiaH1sPSYqHQmtIGowRCLZsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowRCBPsCT)kDPyCiqTegGo2ZObvYNWAVSwcdqh7z0Gk5RqNPhiaH1sPSYqHQmtIGowlXkzjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMjrqhRLyLRex7VsxkghculHhpq)uYNWAVSwcpEG(PKVcDMEGaewlLYkdfQYmjc6yTeRCL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLszLHcvzMebDSwILyL4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuUYqHQmtIGowlXkhL4A)v6sX4qGAj84b6Ns(ew7L1s4Xd0pL8vOZ0deGWAPuwzOqvMvMjh0Y)oj0kLGCksCT1(JnwlK0iJR2Eg1sOGhcWbFW0NewBGTqqyGa1otsSwg8ss(qGAf2S3GtvzMebDSwzL4A)v6sX4qGAjmaDSNrdQKpH1EzTegGo2ZObvYxHotpqacRLs5kdfQYmjc6yTYvIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLRmuOkZKiOJ1sSsCT)kDPyCiqTwqYFv7STFSm1kNw1EzTseixlaukCctV20ad(YOwkLef1sPSYqHQmtIGowRCuIR9xPlfJdbQLWa0XEgnOs(ew7L1sya6ypJgujFf6m9abiSwkLvgkuLzse0XABPsCT)kDPyCiqTekshaeEk5tyTxwlHI0baHNs(k0z6bcqyT8vRCYVVevlLYkdfQYmjc6yTYkzjU2FLUumoeOwcVa6eGNIPfkrMdG8ZjS2lRLqrMdG8ZvmTGWAPuwzOqvMjrqhRvwjlX1(R0LIXHa1sya6ypJgujFcR9YAjmaDSNrdQKVcDMEGaewlF1kN87lr1sPSYqHQmtIGowRSYrjU2FLUumoeOwcdqh7z0Gk5tyTxwlHbOJ9mAqL8vOZ0deGWAPuwzOqvMvM1kjnY4qGALvY1YIdMETd48MQYSNfdE2z8SSGKGd(GP)RG73ZYiYoCGpRF73QTfZnyTTCiyhlZ(TFRwZahTRTLyETYvYYv2YSYSF73Q9x2S3GtjUm73(TABfQvoCI1ETnGcEuRfK8x1AZoWa6n1M9Af2S74OwOFyeGghm9AH(8qgO2SxlHc2f4qZIdMoHQYSF73QTvO2FzZEdwlhc2rn07qhETR9YA5qWoQT5Gm921sj8Q1rPyu7h6xTdOuSwEwlhc2rn07qhETPqvMvMXIdM(uzeOijP5J4uLehc2rn0pCmqXvMXIdM(uzeOijP5J4uLehc2rDNjHdihLzS4GPpvgbkssA(iovjjsVvemqnj7SUbjlZyXbtFQmcuKK08rCQsskhqMEGM7mjsLtuFC0GNwKG(zEAqnWjEMdGDgCCuj2YmwCW0NkJafjjnFeNQKKYbKPhO5otIurPP2qCMNgudCIN5ayNbhhvzjMYmwCW0NkJafjjnFeNQKKYbKPhO5otIunc0aCm0O0080G6epZHDQugGo2ZObvtOHD665LbPjkfPu0z)usr)SBherKiLIo7NYrrKJmaiIir6aGWtXHGDuBejaSPnfuyUuEaIuL1CP8ae14yIuLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQ2SuuNgOJaMNguN4zoStLfhukQrhjH4uEuLYbKPhOItuFC0GNwKG(zUuEaIuL1CP8ae14yIuLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQDOZdnny4MNguN4zUuEaIuLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQ2CqMEB98ybb6dsIMNgudCIN5ayNbhh1wqzgloy6tLrGIKKMpItvss5aY0d0CNjrQ84JBp1Z2UqlYCaKF(080GAGt8mha7m44Ok5YmwCW0NkJafjjnFeNQKKYbKPhO5otIuJPMKLrdGdUTUNH(YJ080GAGt8mha7m44OsmLzS4GPpvgbkssA(iovjjLditpqZDMePgtnjlJgahCBDpdDKgMNgudCIN5ayNbhhvIPmJfhm9PYiqrssZhXPkjPCaz6bAUZKi1yQjzz0a4GBR7zOzdZtdQboXZCaSZGJJQCLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQK5PncuGiG(YJut3280GAGt8mha7m44O2slZyXbtFQmcuKK08rCQsskhqMEGM7mjsLmpnjlJgahCBDpd9LhP5Pb1aN4zoa2zWXrvwjxMXIdM(uzeOijP5J4uLKuoGm9an3zsKkzEAswgnao426EgA2W80GAGt8mha7m44OklXuMXIdM(uzeOijP5J4uLKuoGm9an3zsKkBOjzz0a4GBR7zOV8inpnOg4epZHDQI0baHNIdb7O2isaytBZLYdqKkXkzZLYdquJJjsvwjxMXIdM(uzeOijP5J4uLKuoGm9an3zsKkBOjzz0a4GBR7zOV8inpnOg4epZbWodooQYk5YmwCW0NkJafjjnFeNQKKYbKPhO5otIuzdnjlJgahCBDpdnzEMNgudCIN5ayNbhhv5k5YmwCW0NkJafjjnFeNQKKYbKPhO5otIuJ0qtYYObWb3w3ZqF5rAEAqDIN5s5bisvUsUvGsIPfjshaeEkoeSJAJibGnTPOmJfhm9PYiqrssZhXPkjPCaz6bAUZKi1lpsnjlJgahCBDpdnByEAqDIN5s5bisLyiUCLClIsrkfD2pLdBSpDNrIiIsr6aGWtXHGDuBejaSPTjwCqPOgDKeIZ)KYbKPhOItuFC0GNwKG(rbfexwIPfrPiLIo7NIG2bKDtbOJ9mAqfhc2rTnhKP32eloOuuJoscXP8OkLditpqfNO(4ObpTib9JIYmwCW0NkJafjjnFeNQKKYbKPhO5otIuV8i1KSmAaCWT19m0rAyEAqDIN5s5bisvUsUvGYwAlsKoai8uCiyh1grcaBAtrzgloy6tLrGIKKMpItvss5aY0d0CNjrQ0CeCdQjzN1gIZ80G6epZHDQIuk6SFkh2yF6oJMlLhGiv5SKBfOKKNhgT1s5bi2IKvYsMIYmwCW0NkJafjjnFeNQKKYbKPhO5otIuP5i4gutYoRneN5Pb1jEMd7ufPu0z)ue0oGSBUuEaIuBbetRaLK88WOTwkpaXwKSswYuuMXIdM(uzeOijP5J4uLKuoGm9an3zsKknhb3GAs2zTH4mpnOoXZCyNQuoGm9av0CeCdQjzN1gIJQKnxkparQTuj3kqjjppmARLYdqSfjRKLmfLzS4GPpvgbkssA(iovjjLditpqZDMePYgAsOdjbj1KSZAdXzEAqnWjEMdGDgCCuLLykZyXbtFQmcuKK08rCQsskhqMEGM7mjs9YJutYYOf2C0GtZtdQboXZCaSZGJJQClZyXbtFQmcuKK08rCQsskhqMEGM7mjsLtuF5rQjzz0cBoAWP5Pb1aN4zoa2zWXrvULzS4GPpvgbkssA(iovjjLditpqZDMeP2HtBO3Otd0XW80G6epZLYdqKQSTikXwii0WabuiPr7a5HodaNDbseruE8a9tfGoQZU2i)WWeLhpq)uCiyh1OWojIOwlsPOZ(PiODazNctu2ArkfD2pLJIihzaqerS4Gsrn6ijeNuLLiIcqh7z0GQj0WoD98YGKctTwKsrN9tjf9ZUDqbfLzS4GPpvgbkssA(iovjjLditpqZDMePYg601Gt080G6epZLYdqKk2cbHggiGIKfmDG6PnINMeCcfere2cbHggiGQzWaq(YyQPzGgKiIWwii0WabundgaYxgtnjcWJbmDIicBHGqddeqbWbbKz6AauqG2a8cCkqxGere2cbHggiGc6traEm9a1Tqq2pqsnakfkqIicBHGqddeqntWXaVd6n6aKUnreHTqqOHbcOMGo9itantIND75reryleeAyGaQpMa0XyQ7r6aere2cbHggiGQpysuNDnnF3alZyXbtFQmcuKK08rCQsIegrgAij3GLzS4GPpvgbkssA(iovj1h40weC)mh2PotWbn0busZbFWbQN5qk6hrentWbn0bugGZdCGAmanoy6LzS4GPpvgbkssA(iovjfGoQZU2i)WWCyNQiLIo7NIG2bKDtbOJ9mAqfhc2rn07qhETnjshaeEkoeSJAJibGnTnjLditpqfp(42t9STl0Imha5NpnXIdkf1OJKqC(NuoGm9avCI6JJg80Ie0VYmwCW0NkJafjjnFeNQK6rop6CCMd7uBTuoGm9avgbAaogAuAsvwtbOJ9mAqfaCkGgdOZrBTijjzhOmJfhm9PYiqrssZhXPkjoeSJA6bppZHDQTwkhqMEGkJanahdnknPkRPwhGo2ZObvaWPaAmGohT1IKKKDatu2ArkfD2pLu0p72brejLditpqvhoTHEJonqhdkkZyXbtFQmcuKK08rCQsIegrgtD21xgKOFMd7uBTuoGm9avgbAaogAuAsvwtToaDSNrdQaGtb0yaDoARfjjj7aMePu0z)usr)SBhMATuoGm9avD40g6n60aDmkZyXbtFQmcuKK08rCQscLMc(GPBoStvkhqMEGkJanahdnknPkBzwzgloy6tItvsIe0pmMg4yuMXIdM(K4uLe4e1KSZ6gK0CyNkLhpq)uOpGn2h6iGjs2zLH4(JAlvYMizNvgItEuLZedfereLT(4b6Nc9bSX(qhbmrYoRme3FuBPedfLzS4GPpjovjzKhmDZHDQ0G9UIdb7O2i)WqbAuMXIdM(K4uL0bjr9hhgMd7udqh7z0GQdjnYGh6pommrd27kugBgCEW0vGgMOuK5ai)Cfhc2rTr(HHkqgOnrerNZPPoSX(0bsYqF(hv5OKPOmJfhm9jXPkPbSX(M6wrqGgs0pZHDQ0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)WqbKFUjaKgS3vxckS1zxF2OMKBGkG8ZlZyXbtFsCQsIMB0zxFbuqW0CyNknyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBcaPb7D1LGcBD21NnQj5gOci)8YmwCW0NeNQKOXyIbbqVXCyNknyVR4qWoQnYpmuGgLzS4GPpjovjrpYeq3bJ2Md7uPb7Dfhc2rTr(HHc0OmJfhm9jXPkPomq6rMaMd7uPb7Dfhc2rTr(HHc0OmJfhm9jXPkj2f48cEOf8yyoStLgS3vCiyh1g5hgkqJYmwCW0NeNQKaNOgEi50CyNknyVR4qWoQnYpmuGgLzS4GPpjovjborn8qsZXEhfN2zsKAZGbG8LXutZanO5WovAWExXHGDuBKFyOaniIirMdG8ZvCiyh1g5hgQajzOpLhvIHymbG0G9U6sqHTo76Zg1KCdubAuMXIdM(K4uLe4e1Wdjn3zsKksA0oqEOZaWzxGMd7ufzoaYpxXHGDuBKFyOcKKH(8pQuklXs8wslskhqMEGk2qNUgCIuysK5ai)C1LGcBD21NnQj5gOkqsg6Z)OsPSelXBjTiPCaz6bQydD6AWjsrzgloy6tItvsGtudpK0CNjrQabYaDyGAP4CIdZHDQImha5NR4qWoQnYpmubsYqFkpQYvYeruRLYbKPhOIn0PRbNivzjIikpijsvYMKYbKPhOQdN2qVrNgOJbvznfGo2ZObvtOHD665LbjfLzS4GPpjovjborn8qsZDMePotWHg24WddZHDQImha5NR4qWoQnYpmubsYqFkpQeRKjIOwlLditpqfBOtxdorQYwMXIdM(K4uLe4e1Wdjn3zsKAZOTHTo7AEoHKWbFW0nh2PkYCaKFUIdb7O2i)Wqfijd9P8OkxjterTwkhqMEGk2qNUgCIuLLiIO8GKivjBskhqMEGQoCAd9gDAGoguL1ua6ypJgunHg2PRNxgKuuMXIdM(K4uLe4e1Wdjn3zsKkjly6a1tBepnj4ekmh2PkYCaKFUIdb7O2i)Wqfijd95Fujgtu2APCaz6bQ6WPn0B0Pb6yqvwIi6GKO8iwjtrzgloy6tItvsGtudpK0CNjrQKSGPdupTr80KGtOWCyNQiZbq(5koeSJAJ8ddvGKm0N)rLymjLditpqvhoTHEJonqhdQYAIgS3vbOJ6SRnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)rLszLCRaX0Icqh7z0GQj0WoD98YGKcthKe)JyLCzgloy6tItvsGtudpK0CNjrQtBgi)qaDg06SRVmir)mh2PEqsKQKjIikLYbKPhOkbVjea1zxlYCaKF(0eLImha5NR4qWoQnYpmubsYqF(hv5serDyJ9PdKKH(8prMdG8ZvCiyh1g5hgQajzOpPGIYSF73QLfhm9jXPkjh)6jOdOdCMdPO5Gtu)zdhOwWZd6nuL1CyNknyVR4qWoQnYpmuGgereasd27Qlbf26SRpButYnqfObrebKNkyai7NEAWbbQdkia6nLzS4GPpjovjj4XqZIdMUEaNN5otIuf8qao4dM(SmJfhm9jXPkjbpgAwCW01d48m3zsKkNO5ZlGIJQSMd7uzXbLIA0rsioLhvPCaz6bQ4e1hhn4PfjOFLzS4GPpjovjj4XqZIdMUEaNN5otIuT5Gm92Md7ufPu0z)ue0oGSBkaDSNrdQ4qWoQT5Gm92LzS4GPpjovjj4XqZIdMUEaNN5otIu7WPn0B0Pb6yyoStvkhqMEGkBwkQtd0raQs2KuoGm9avD40g6n60aDmm1AkfPu0z)ue0oGSBkaDSNrdQ4qWoQT5Gm92uuMXIdM(K4uLKGhdnloy66bCEM7mjsnnqhdZHDQs5aY0duzZsrDAGocqvYMAnLIuk6SFkcAhq2nfGo2ZObvCiyh12CqMEBkkZyXbtFsCQssWJHMfhmD9aopZDMePkYCaKF(0CyNARPuKsrN9trq7aYUPa0XEgnOIdb7O2MdY0Btrzgloy6tItvscEm0S4GPRhW5zUZKi1ip(GPBoStvkhqMEGQo05HMgmCQs2uRPuKsrN9trq7aYUPa0XEgnOIdb7O2MdY0Btrzgloy6tItvscEm0S4GPRhW5zUZKi1o05HMgmCZHDQs5aY0du1Hop00GHtvwtTMsrkfD2pfbTdi7Mcqh7z0GkoeSJABoitVnfLzLzS4GPpvCIu7rop6CCMd7udqh7z0Gka4uangqNJ2ArssYoGjrMdG8Zv0G9UgaofqJb05OTwKKKSdOcKbABIgS3vaWPaAmGohT1IKKKDaDpY5PaYp3eL0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)WqbKFUjaKgS3vxckS1zxF2OMKBGkG8ZPWKiZbq(5Qlbf26SRpButYnqvGKm0NuLSjkPb7Dfhc2rTWMJgunpwqWFuLYbKPhOItuF5rQjzz0cBoAWPjkP84b6NkaDuNDTr(HHjrMdG8ZvbOJ6SRnYpmubsYqF(h1gbGjrMdG8ZvCiyh1g5hgQajzOpLNuoGm9avxEKAswgnao426EgA2GcIiIYwF8a9tfGoQZU2i)WWKiZbq(5koeSJAJ8ddvGKm0NYtkhqMEGQlpsnjlJgahCBDpdnBqbrejYCaKFUIdb7O2i)Wqfijd95FuBeauqrzgloy6tfNiXPkPomqn9GNN5Wovkdqh7z0Gka4uangqNJ2ArssYoGjrMdG8Zv0G9UgaofqJb05OTwKKKSdOcKbABIgS3vaWPaAmGohT1IKKKDaDhgOci)Ctgbkv3iauYQ6rop6CCuqerugGo2ZObvaWPaAmGohT1IKKKDathKePkzkkZyXbtFQ4ejovj1JCEApLYMd7udqh7z0GQMaohT1qbumqtImha5NR4qWoQnYpmubsYqFkpIvYMezoaYpxDjOWwND9zJAsUbQcKKH(KQKnrjnyVR4qWoQf2C0GQ5Xcc(JQuoGm9avCI6lpsnjlJwyZrdonrjLhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6Z)O2iamjYCaKFUIdb7O2i)Wqfijd9P8KYbKPhO6YJutYYObWb3w3ZqZguqeru26JhOFQa0rD21g5hgMezoaYpxXHGDuBKFyOcKKH(uEs5aY0duD5rQjzz0a4GBR7zOzdkiIirMdG8ZvCiyh1g5hgQajzOp)JAJaGckkZyXbtFQ4ejovj1JCEApLYMd7udqh7z0GQMaohT1qbumqtImha5NR4qWoQnYpmubsYqFsvYMOKskfzoaYpxDjOWwND9zJAsUbQcKKH(uEs5aY0duXgAswgnao426Eg6lpst0G9UIdb7OwyZrdQMhliGknyVR4qWoQf2C0Gkswg98ybbuqerukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybb)rvkhqMEGkor9LhPMKLrlS5ObNuqHjAWExfGoQZU2i)WqbKFofLzS4GPpvCIeNQK4qWoQjHZjCGtZHDQIuk6SFkcAhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2MdY0BRMhli4pzjgtImha5NRcgaY(PNgCqGkqsg6Z)OkLditpqLnhKP3wppwqG(GKiXrzqb4H6dsIMezoaYpxDjOWwND9zJAsUbQcKKH(8pQs5aY0duzZbz6T1ZJfeOpijsCuguaEO(GKiXzXbtxfmaK9tpn4GafkdkapuFqs0KiZbq(5koeSJAJ8ddvGKm0N)rvkhqMEGkBoitVTEESGa9bjrIJYGcWd1hKejoloy6QGbGSF6PbheOqzqb4H6dsIeNfhmD1LGcBD21NnQj5gOcLbfGhQpijAUWMHovzlZyXbtFQ4ejovjDjOWwND9zJAsUbAoStnaDSNrdQMqd701Zldstgbkv3iauYQqPPGpy6LzS4GPpvCIeNQK4qWoQnYpmmh2PgGo2ZObvtOHD665LbPjkncuQUraOKvHstbFW0jIiJaLQBeakzvxckS1zxF2OMKBGuuMXIdM(uXjsCQscLMc(GPBoSt9GKO8iwjBkaDSNrdQMqd701Zldst0G9UIdb7OwyZrdQMhli4pQs5aY0duXjQV8i1KSmAHnhn40KiZbq(5Qlbf26SRpButYnqvGKm0NuLSjrMdG8ZvCiyh1g5hgQajzOp)JAJaOmJfhm9PItK4uLeknf8bt3CyN6bjr5rSs2ua6ypJgunHg2PRNxgKMezoaYpxXHGDuBKFyOcKKH(KQKnrjLukYCaKFU6sqHTo76Zg1KCdufijd9P8KYbKPhOIn0KSmAaCWT19m0xEKMOb7Dfhc2rTWMJgunpwqavAWExXHGDulS5ObvKSm65XccOGiIOuK5ai)C1LGcBD21NnQj5gOkqsg6tQs2enyVR4qWoQf2C0GQ5Xcc(JQuoGm9avCI6lpsnjlJwyZrdoPGct0G9UkaDuNDTr(HHci)Ckmh6hgbOXPHDQ0G9UAcnStxpVmivZJfeqLgS3vtOHD665LbPIKLrppwqG5q)WianonKKebG8HuLTmJfhm9PItK4uLejmImM6SRVmir)mh2PsPiZbq(5koeSJAJ8ddvGKm0NYtosmerKiZbq(5koeSJAJ8ddvGKm0N)rLyPWKiZbq(5Qlbf26SRpButYnqvGKm0NuLSjkPb7Dfhc2rTWMJgunpwqWFuLYbKPhOItuF5rQjzz0cBoAWPjkP84b6NkaDuNDTr(HHjrMdG8ZvbOJ6SRnYpmubsYqF(h1gbGjrMdG8ZvCiyh1g5hgQajzOpLhXqbrerzRpEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6t5rmuqerImha5NR4qWoQnYpmubsYqF(h1gbafuuMXIdM(uXjsCQskyai7NEAWbbMd7ufzoaYpxDjOWwND9zJAsUbQcKKH(8puguaEO(GKOjkP84b6NkaDuNDTr(HHjrMdG8ZvbOJ6SRnYpmubsYqF(h1gbGjrMdG8ZvCiyh1g5hgQajzOpLNuoGm9avxEKAswgnao426EgA2GcIiIYwF8a9tfGoQZU2i)WWKiZbq(5koeSJAJ8ddvGKm0NYtkhqMEGQlpsnjlJgahCBDpdnBqbrejYCaKFUIdb7O2i)Wqfijd95FuBeauuMXIdM(uXjsCQskyai7NEAWbbMd7ufzoaYpxXHGDuBKFyOcKKH(8puguaEO(GKOjkPKsrMdG8ZvxckS1zxF2OMKBGQajzOpLNuoGm9avSHMKLrdGdUTUNH(YJ0enyVR4qWoQf2C0GQ5XccOsd27koeSJAHnhnOIKLrppwqafereLImha5NRUeuyRZU(Srnj3avbsYqFsvYMOb7Dfhc2rTWMJgunpwqWFuLYbKPhOItuF5rQjzz0cBoAWjfuyIgS3vbOJ6SRnYpmua5Ntrzgloy6tfNiXPkjaKpB6mC0CyNQiZbq(5koeSJAJ8ddvGKm0NuLSjkPKsrMdG8ZvxckS1zxF2OMKBGQajzOpLNuoGm9avSHMKLrdGdUTUNH(YJ0enyVR4qWoQf2C0GQ5XccOsd27koeSJAHnhnOIKLrppwqafereLImha5NRUeuyRZU(Srnj3avbsYqFsvYMOb7Dfhc2rTWMJgunpwqWFuLYbKPhOItuF5rQjzz0cBoAWjfuyIgS3vbOJ6SRnYpmua5Ntrzgloy6tfNiXPkPlbf26SRpButYnqZHDQusd27koeSJAHnhnOAESGG)OkLditpqfNO(YJutYYOf2C0GtIiYiqP6gbGswvWaq2p90GdcOWeLuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)JAJaWKiZbq(5koeSJAJ8ddvGKm0NYtkhqMEGQlpsnjlJgahCBDpdnBqbrerzRpEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6t5jLditpq1LhPMKLrdGdUTUNHMnOGiIezoaYpxXHGDuBKFyOcKKH(8pQncakkZyXbtFQ4ejovjXHGDuBKFyyoStLskfzoaYpxDjOWwND9zJAsUbQcKKH(uEs5aY0duXgAswgnao426Eg6lpst0G9UIdb7OwyZrdQMhliGknyVR4qWoQf2C0Gkswg98ybbuqerukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybb)rvkhqMEGkor9LhPMKLrlS5ObNuqHjAWExfGoQZU2i)WqbKFEzgloy6tfNiXPkPa0rD21g5hgMd7uPb7Dva6Oo7AJ8ddfq(5MOKsrMdG8ZvxckS1zxF2OMKBGQajzOpLNCLSjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGakiIikfzoaYpxDjOWwND9zJAsUbQcKKH(KQKnrd27koeSJAHnhnOAESGG)OkLditpqfNO(YJutYYOf2C0GtkOWeLImha5NR4qWoQnYpmubsYqFkpzLlrebG0G9U6sqHTo76Zg1KCdubAqrzgloy6tfNiXPkPPnSFqVrBKFyyoStvK5ai)Cfhc2rDg0QajzOpLhXqerT(4b6NIdb7Ood6YmwCW0NkorItvsCiyh10dEEMd7ufPu0z)ue0oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTr(HHc0Weasd27QGbGSF6PbheOLcoCmyA4aETvZJfeqvoAYiqP6gbGswfhc2rDg0MyXbLIA0rsio)RLuMXIdM(uXjsCQsIdb7OMMJGBqZHDQIuk6SFkcAhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2i)WqbAycaPb7DvWaq2p90Gdc0sbhogmnCaV2Q5XccOkhlZyXbtFQ4ejovjXHGDutp45zoStvKsrN9trq7aYUPa0XEgnOIdb7O2MdY0BBIgS3vCiyh1g5hgkqdtucKNkyai7NEAWbbQajzOpLNCMiIaqAWExfmaK9tpn4GaTuWHJbtdhWRTc0GctainyVRcgaY(PNgCqGwk4WXGPHd41wnpwqWFYrtS4Gsrn6ijeNuj2YmwCW0NkorItvsCiyh1zqBoStvKsrN9trq7aYUPa0XEgnOIdb7O2MdY0BBIgS3vCiyh1g5hgkqdtainyVRcgaY(PNgCqGwk4WXGPHd41wnpwqavITmJfhm9PItK4uLehc2rnnhb3GMd7ufPu0z)ue0oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTr(HHc0Weasd27QGbGSF6PbheOLcoCmyA4aETvZJfeqvULzS4GPpvCIeNQK4qWoQrzmg5eMU5WovrkfD2pfbTdi7Mcqh7z0GkoeSJABoitVTjAWExXHGDuBKFyOanmzeOuDJaqjxvWaq2p90GdcmXIdkf1OJKqCkpITmJfhm9PItK4uLehc2rnkJXiNW0nh2PksPOZ(PiODaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhliGQSMyXbLIA0rsioLhXwMXIdM(uXjsCQsYiWj6cuNDnj0bmh2Psd27kaKpB6mCubAycaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)rLgS3vgborxG6SRjHoGIKLrppwqqlIfhmDfhc2rn9GNNcLbfGhQpijAIskpEG(PcCMo7c0eloOuuJoscX5FYrkiIiwCqPOgDKeIZ)igkmrzRdqh7z0GkoeSJA6KKMdas0pIi64ObpLnYJZwzio5rSedfLzS4GPpvCIeNQK4qWoQPh88mh2Psd27kaKpB6mCubAyIskpEG(PcCMo7c0eloOuuJoscX5FYrkiIiwCqPOgDKeIZ)igkmrzRdqh7z0GkoeSJA6KKMdas0pIi64ObpLnYJZwzio5rSedfLzS4GPpvCIeNQKMGgy4PuUmJfhm9PItK4uLehc2rnnhb3GMd7uPb7Dfhc2rTWMJgunpwqG8OsjloOuuJoscXzRGSuykaDSNrdQ4qWoQPtsAoair)mDC0GNYg5XzRme3FelXuMXIdM(uXjsCQsIdb7OMMJGBqZHDQ0G9UIdb7OwyZrdQMhliGknyVR4qWoQf2C0Gkswg98ybbLzS4GPpvCIeNQK4qWoQZG2CyNknyVR4qWoQf2C0GQ5XccOkztukYCaKFUIdb7O2i)Wqfijd9P8KLyiIOwtPiLIo7NIG2bKDtbOJ9mAqfhc2rTnhKP3MckkZyXbtFQ4ejovj54zJH(qsdCEMd7uPmWEGtBMEGeruRpOGaO3qHjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGGYmwCW0NkorItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilotbOJ9mAqfhc2rTnhKP32eLuE8a9tXKgdyhk4dMUjwCqPOgDKeIZ)APuqerS4Gsrn6ijeN)rmuuMXIdM(uXjsCQsIdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXz64b6NIdb7Ogf2PjaKgS3vxckS1zxF2OMKBGkqdtuE8a9tXKgdyhk4dMoreXIdkf1OJKqC(xlGIYmwCW0NkorItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilothpq)umPXa2Hc(GPBIfhukQrhjH48p5yzgloy6tfNiXPkjoeSJAugJroHPBoStLgS3vCiyh1cBoAq18ybb)rd27koeSJAHnhnOIKLrppwqqzgloy6tfNiXPkjoeSJAugJroHPBoStLgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWKrGs1ncaLSkoeSJAAocUblZyXbtFQ4ejovjHstbFW0nh6hgbOXPHDQKSZkdXjpQTuIXCOFyeGgNgssIaq(qQYwMvMXIdM(uj4HaCWhm9jvPCaz6bAUZKivBwkQtd0raZtdQt8mxkparQYAoStvkhqMEGkBwkQtd0raQs2KrGs1ncaLSkuAk4dMUPwtza6ypJgunHg2PRNxgKerua6ypJguDiPrg8q)XHbfLzS4GPpvcEiah8btFsCQsskhqMEGM7mjs1MLI60aDeW80G6epZLYdqKQSMd7uLYbKPhOYMLI60aDeGQKnrd27koeSJAJ8ddfq(5MezoaYpxXHGDuBKFyOcKKH(0eLbOJ9mAq1eAyNUEEzqserbOJ9mAq1HKgzWd9hhguuMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1o05HMgmCZtdQt8mxkparQYAoStLgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWuRPb7DvaoqD21NDG4ubAyQdBSpDGKm0N)rLskjzNLtlwCW0vCiyh10dEEkropkArS4GPR4qWoQPh88uOmOa8q9bjrkkZ(TALtGNng1Y12bhJ21opwqacuRnhKP3U2mQf61IYGcWdRnyVbR9dE21(FssZbaj6xzgloy6tLGhcWbFW0NeNQKKYbKPhO5otIursJ8ddeqtZrWnO5Pb1jEMlLhGivAWExXHGDuBZbz6TvZJfeipQYsmereLbOJ9mAqfhc2rnDssZbaj6NPJJg8u2ipoBLH4(JyjgkkZyXbtFQe8qao4dM(K4uLKuoGm9an3zsK6GNNMn0Gt0CaSZGJJQKnpnOoXZCyNknyVR4qWoQnYpmuGgMOukhqMEGQbppnBObNivjterhKeLhvPCaz6bQg880SHgCIexwIHcZLYdqK6bjXYSFR2woeSJ12QrcaBAxBdukoRLRvkhqMEG1YKjOF1M9AfaH51sdE1(Heog1coXA5A7d(QfNhKKpy61AJbQQ9hBS2jKuuRrKsHaiqTbsYqFQrzmqXHa1IYye4CctVwGeN165v7xgeu7hog12ZOwJibGnTRfaeR9YApBSwAWyETR15dmWAZETNnwRaiuLzS4GPpvcEiah8btFsCQsskhqMEGM7mjsfNhKKpeqZgArMdG8ZnpnOoXZCP8aePsPiZbq(5koeSJAJ8ddfayWhm9weLY2kqPKvsMyBrI0baHNIdb7O2isaytBvWobuqbfTcuEqsSvqkhqMEGQbppnBObNifLzS4GPpvcEiah8btFsCQsskhqMEGM7mjs9GKOg0p4qZgMNguN4zoStvKoai8uCiyh1grcaBABUuEaIuLYbKPhOcNhKKpeqZgArMdG8ZlZyXbtFQe8qao4dM(K4uLKuoGm9an3zsK6bjrnOFWHMnmpnOoXZCyNARfPdacpfhc2rTrKaWM2MlLhGivrMdG8ZvCiyh1g5hgQajzOplZ(TALdqchJAbWb3U2wUvRf0O2lRvUsEIIA7zu7p51IlZyXbtFQe8qao4dM(K4uLKuoGm9an3zsK6bjrnOFWHMnmpnOsYYyUuEaIufzoaYpxDjOWwND9zJAsUbQcKKH(0CyNkLImha5NRUeuyRZU(Srnj3avbsYqF2kiLditpq1bjrnOFWHMnO4p5k5YSFRwlOlWA)DG0TRfoRDckSRLR1i)WOdoQ9cOtaE12ZOw503oGSBETFiHJrTZdkiO2lR9SXAVVSwsOdEyTI2IbwlOFWrTFyTn4vlxRnSXUw0tWg7Ad2jO2SxRrKaWM2LzS4GPpvcEiah8btFsCQsskhqMEGM7mjs9GKOg0p4qZgMNgujzzmxkparQxaDcWtntWXaVd6n6aKUTsK5ai)CvGKm0NMd7ufPdacpfhc2rTrKaWM2MePdacpfhc2rTrKaWM2QGDc(JymHTqqOHbcOMj4yG3b9gDas32KiLIo7NIG2bKDtbOJ9mAqfhc2rTnhKP3Um73QvoajCmQfahC7A)jVwCTGg1EzTYvYtuuBpJAB5wTmJfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQ25aa6n6lpsZtdQt8mxkparQImha5NRUeuyRZU(Srnj3avbYaTnjLditpq1bjrnOFWHMn(tUsUm73Q93Xaq2VATm4GGAbsCwRNxTqsseaYhoAxRb4vlOrTNnwRuWHJbtdhWRDTainyVx7mRfE1kyVwASwayVdfGJR2lRfaofy41E28v7hsyG1YxTNnw7Vhg5zxRuWHJbtdhWRDTZJfeuMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1wrW5PbNiGEAWbbMNguN4zUuEaIuP0iqP6gbGswvWaq2p90GdciIiJaLQBeak5QcgaY(PNgCqarezeOuDJaqrSQGbGSF6PbheqHjaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARaYpVmJfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQj4nHaOo7ArMdG8ZNMNguN4zUuEaIuPb7Dfhc2rTr(HHci)Ct0G9UkaDuNDTr(HHci)CtainyVRUeuyRZU(Srnj3ava5NBQ1s5aY0du1kcopn4eb0tdoiWeasd27QGbGSF6PbheOLcoCmyA4aETva5NxMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi15Xcc02CqMEBZtdQt8mxkparQbOJ9mAqfhc2rTnhKP32eLuksPOZ(PiODaz3KiZbq(5QGbGSF6PbheOcKKH(8pPCaz6bQS5Gm9265Xcc0hKePGIYSYSFR2wnGzap4Vhwl4e6n12eW5ODTqbumWA)GNDTSHQw5Wjwl8Q9dE21E5rwBE2y8bNOQmJfhm9PsK5ai)8j1EKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAsK5ai)Cfhc2rTr(HHkqsg6t5rSs2KiZbq(5Qlbf26SRpButYnqvGmqBtusd27koeSJAHnhnOAESGG)OkLditpq1LhPMKLrlS5ObNMOKYJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95FuBeaMezoaYpxXHGDuBKFyOcKKH(uEs5aY0duD5rQjzz0a4GBR7zOzdkiIikB9Xd0pva6Oo7AJ8ddtImha5NR4qWoQnYpmubsYqFkpPCaz6bQU8i1KSmAaCWT19m0SbferKiZbq(5koeSJAJ8ddvGKm0N)rTraqbfLzS4GPpvImha5Npjovj1JCEApLYMd7udqh7z0GQMaohT1qbumqtImha5NR4qWoQnYpmubYaTnrzRpEG(PqFaBSp0raIiIYJhOFk0hWg7dDeWej7SYqCYJAlrYuqHjkPuK5ai)C1LGcBD21NnQj5gOkqsg6t5jRKnrd27koeSJAHnhnOAESGaQ0G9UIdb7OwyZrdQizz0ZJfeqbrerPiZbq(5Qlbf26SRpButYnqvGKm0NuLSjAWExXHGDulS5ObvZJfeqvYuqHjAWExfGoQZU2i)WqbKFUjs2zLH4KhvPCaz6bQydnj0HKGKAs2zTH4kZyXbtFQezoaYpFsCQsQh58OZXzoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b09iNNci)Ctusd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MaqAWExDjOWwND9zJAsUbQaYpNctImha5NRUeuyRZU(Srnj3avbsYqFsvYMOKgS3vCiyh1cBoAq18ybb)rvkhqMEGQlpsnjlJwyZrdonrjLhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6Z)O2iamjYCaKFUIdb7O2i)Wqfijd9P8KYbKPhO6YJutYYObWb3w3ZqZguqeru26JhOFQa0rD21g5hgMezoaYpxXHGDuBKFyOcKKH(uEs5aY0duD5rQjzz0a4GBR7zOzdkiIirMdG8ZvCiyh1g5hgQajzOp)JAJaGckkZyXbtFQezoaYpFsCQsQddutp45zoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b0DyGkG8ZnzeOuDJaqjRQh58OZXvM9B12QmmQTfN)u7h8SRTLB1AH9AHhHZAfjj0BQf0O2zMUQ2wzVw4v7hCmQLgRfCIa1(bp7A)jVwS51k45vl8QDoGn23ODT0ypdSmJfhm9PsK5ai)8jXPkjsyezm1zxFzqI(zoStvK5ai)C1LGcBD21NnQj5gOkqsg6Z)KYbKPhOImpTrGceb0xEKA62ereLs5aY0duDqsud6hCOzd5jLditpqfzEAswgnao426EgA2WKiZbq(5Qlbf26SRpButYnqvGKm0NYtkhqMEGkY80KSmAaCWT19m0xEKuuMXIdM(ujYCaKF(K4uLejmImM6SRVmir)mh2PkYCaKFUIdb7O2i)Wqfid02eLT(4b6Nc9bSX(qhbiIikpEG(PqFaBSp0ratKSZkdXjpQTejtbfMOKsrMdG8ZvxckS1zxF2OMKBGQajzOpLNuoGm9avSHMKLrdGdUTUNH(YJ0enyVR4qWoQf2C0GQ5XccOsd27koeSJAHnhnOIKLrppwqafereLImha5NRUeuyRZU(Srnj3avbsYqFsvYMOb7Dfhc2rTWMJgunpwqavjtbfMOb7Dva6Oo7AJ8ddfq(5MizNvgItEuLYbKPhOIn0KqhscsQjzN1gIRmJfhm9PsK5ai)8jXPkP(aN2IG7N5WovPCaz6bQsWBcbqD21Imha5Npnr5mbh0qhqjnh8bhOEMdPOFer0mbh0qhqzaopWbQXa04GPtrz2VvBlp(42ZAbNyTaiF20z4yTFWZUw2qvBRSx7LhzTWzTbYaTRLN1(HJH51sYeG1obdS2lRvWZRw4vln2ZaR9YJuvMXIdM(ujYCaKF(K4uLeaYNnDgoAoStvK5ai)C1LGcBD21NnQj5gOkqgOTjAWExXHGDulS5ObvZJfe8hvPCaz6bQU8i1KSmAHnhn40KiZbq(5koeSJAJ8ddvGKm0N)rTrauMXIdM(ujYCaKF(K4uLeaYNnDgoAoStvK5ai)Cfhc2rTr(HHkqgOTjkB9Xd0pf6dyJ9HocqeruE8a9tH(a2yFOJaMizNvgItEuBjsMckmrjLImha5NRUeuyRZU(Srnj3avbsYqFkpzLSjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGakiIikfzoaYpxDjOWwND9zJAsUbQcKbABIgS3vCiyh1cBoAq18ybbuLmfuyIgS3vbOJ6SRnYpmua5NBIKDwzio5rvkhqMEGk2qtcDijiPMKDwBiUYSFRw5Wjw70GdcQf2R9YJSw2bQLnQLdS20Rvaul7a1(LoHxT0yTGg12ZO2r6nyu7zZETNnwljltTa4GBBETKmbqVP2jyG1(H1AZsXA5R2bYZR27lRLdb7yTcBoAWzTSdu7zZxTxEK1(XtNWR2wrW5vl4ebuLzS4GPpvImha5NpjovjfmaK9tpn4GaZHDQImha5NRUeuyRZU(Srnj3avbsYqFkpPCaz6bQIPMKLrdGdUTUNH(YJ0KiZbq(5koeSJAJ8ddvGKm0NYtkhqMEGQyQjzz0a4GBR7zOzdtuE8a9tfGoQZU2i)WWeLImha5NRcqh1zxBKFyOcKKH(8puguaEO(GKirejYCaKFUkaDuNDTr(HHkqsg6t5jLditpqvm1KSmAaCWT19m0rAqbre16JhOFQa0rD21g5hguyIgS3vCiyh1cBoAq18ybbYtUMaqAWExDjOWwND9zJAsUbQaYp3enyVRcqh1zxBKFyOaYp3enyVR4qWoQnYpmua5NxM9B1khoXANgCqqTFWZUw2O2pB0R1iNti9av12k71E5rwlCwBGmq7A5zTF4yyETKmbyTtWaR9YAf88QfE1sJ9mWAV8ivLzS4GPpvImha5NpjovjfmaK9tpn4GaZHDQImha5NRUeuyRZU(Srnj3avbsYqF(hkdkapuFqs0enyVR4qWoQf2C0GQ5Xcc(JQuoGm9avxEKAswgTWMJgCAsK5ai)Cfhc2rTr(HHkqsg6Z)OeLbfGhQpijsCwCW0vxckS1zxF2OMKBGkuguaEO(GKifLzS4GPpvImha5NpjovjfmaK9tpn4GaZHDQImha5NR4qWoQnYpmubsYqF(hkdkapuFqs0eLu26JhOFk0hWg7dDeGiIO84b6Nc9bSX(qhbmrYoRmeN8O2sKmfuyIskfzoaYpxDjOWwND9zJAsUbQcKKH(uEs5aY0duXgAswgnao426Eg6lpst0G9UIdb7OwyZrdQMhliGknyVR4qWoQf2C0Gkswg98ybbuqerukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybbuLmfuyIgS3vbOJ6SRnYpmua5NBIKDwzio5rvkhqMEGk2qtcDijiPMKDwBiokkZ(TALdNyTxEK1(bp7AzJAH9AHhHZA)GNn0R9SXAjzzQfahCBvTTYETEEMxl4eR9dE21gPrTWETNnw7Xd0VAHZApMa0nVw2bQfEeoR9dE2qV2ZgRLKLPwaCWTvLzS4GPpvImha5NpjovjDjOWwND9zJAsUbAoStLgS3vCiyh1cBoAq18ybb)rvkhqMEGQlpsnjlJwyZrdonjYCaKFUIdb7O2i)Wqfijd95Furzqb4H6dsIMizNvgItEs5aY0duXgAsOdjbj1KSZAdXzIgS3vbOJ6SRnYpmua5NxMXIdM(ujYCaKF(K4uL0LGcBD21NnQj5gO5WovAWExXHGDulS5ObvZJfe8hvPCaz6bQU8i1KSmAHnhn400Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8pQOmOa8q9bjrts5aY0duDqsud6hCOzd5jLditpq1LhPMKLrdGdUTUNHMnkZyXbtFQezoaYpFsCQs6sqHTo76Zg1KCd0CyNknyVR4qWoQf2C0GQ5Xcc(JQuoGm9avxEKAswgTWMJgCAIYwF8a9tfGoQZU2i)WGiIezoaYpxfGoQZU2i)Wqfijd9P8KYbKPhO6YJutYYObWb3w3ZqhPbfMKYbKPhO6GKOg0p4qZgYtkhqMEGQlpsnjlJgahCBDpdnBuM9B1khoXAzJAH9AV8iRfoRn9Afa1YoqTFPt4vlnwlOrT9mQDKEdg1E2Sx7zJ1sYYulao42Mxljta0BQDcgyTNnF1(H1AZsXArpbBSRLKDUw2bQ9S5R2ZgdSw4SwpVA5rGmq7A5AdqhRn71AKFyulq(5QYmwCW0NkrMdG8ZNeNQK4qWoQnYpmmh2PkYCaKFU6sqHTo76Zg1KCdufijd9P8KYbKPhOIn0KSmAaCWT19m0xEKMOS1Iuk6SFkPOF2TdIisK5ai)CfjmImM6SRVmir)ubsYqFkpPCaz6bQydnjlJgahCBDpdnzEuyIgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWenyVRcqh1zxBKFyOaYp3ej7SYqCYJQuoGm9avSHMe6qsqsnj7S2qCLz)wTYHtS2inQf2R9YJSw4S20Rvaul7a1(LoHxT0yTGg12ZO2r6nyu7zZETNnwljltTa4GBBETKmbqVP2jyG1E2yG1cNoHxT8iqgODTCTbOJ1cKFETSdu7zZxTSrTFPt4vlnkssSwwkdhm9aRfamGEtTbOJQYmwCW0NkrMdG8ZNeNQKcqh1zxBKFyyoStLgS3vCiyh1g5hgkG8ZnrPiZbq(5Qlbf26SRpButYnqvGKm0NYtkhqMEGQin0KSmAaCWT19m0xEKerKiZbq(5koeSJAJ8ddvGKm0N)rvkhqMEGQlpsnjlJgahCBDpdnBqHjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGatImha5NR4qWoQnYpmubsYqFkpzLBzgloy6tLiZbq(5tItvstBy)GEJ2i)WWCyNQuoGm9avj4nHaOo7ArMdG8ZNLz)wTYHtSwJKS2lRD2cbr83dRL9ArzUGRLPRf61E2yTokZvRiZbq(51(bDG8Z8Ab9boN1sq7aYETNn61M(ODTaGb0BQLdb7yTg5hg1caI1EzT25xTKSZ1Ad6nr7AdgaY(v70GdcQfolZyXbtFQezoaYpFsCQsYiWj6cuNDnj0bmh2PE8a9tfGoQZU2i)WWenyVR4qWoQnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)1iauKSmLzS4GPpvImha5Npjovjze4eDbQZUMe6aMd7ubqAWExDjOWwND9zJAsUbQanmbG0G9U6sqHTo76Zg1KCdufijd95FS4GPR4qWoQjHZjCGtfkdkapuFqs0uRfPu0z)ue0oGSxMXIdM(ujYCaKF(K4uLKrGt0fOo7AsOdyoStLgS3vbOJ6SRnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)1iauKSmMezoaYpxHstbFW0vbYaTnjYCaKFU6sqHTo76Zg1KCdufijd9PPwlsPOZ(PiODazVmRmJfhm9PQdDEOPbdNkhc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZCHndDQYwMXIdM(u1Hop00GHtCQsIdb7OMEWZRmJfhm9PQdDEOPbdN4uLehc2rnnhb3GLzLz)wTYb2OxBa6o0BQfHNng1E2yTww1MrT)ihu7aBqhGdionV2pS2p2VAVSw5ePzT0ypdS2ZgR9N8AXsQLB1A)Goq(PQvoCI1cVA5zTZm9A5zT)USvR1MN12HoCAJa1MGrTFiHsXANgOF1MGrTcBoAWzzgloy6tvhoTHEJonqhdQO0uWhmDZHDQugGo2ZObvhsAKbp0FCyqerugGo2ZObvtOHD665LbPPwlLditpqLrGgGJHgLMuLLckmrjnyVRcqh1zxBKFyOaYpNiImcuQUraOKvXHGDutZrWnifMezoaYpxfGoQZU2i)Wqfijd9zz2VvBRSx7hsOuS2o0HtBeO2emQvK5ai)8A)Goq(nRLDGANgOF1MGrTcBoAWP51AeWmGh83dRvorAwBkfJArPy0(SHEtT4yILzS4GPpvD40g6n60aDmiovjHstbFW0nh2PE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOpnjYCaKFUIdb7O2i)Wqfijd9PjAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3KrGs1ncaLSkoeSJAAocUblZyXbtFQ6WPn0B0Pb6yqCQsQddutp45zoStnaDSNrdQaGtb0yaDoARfjjj7aMOb7DfaCkGgdOZrBTijjzhq3JCEkqJYmwCW0NQoCAd9gDAGogeNQK6ropTNszZHDQbOJ9mAqvtaNJ2AOakgOjs2zLH4KxlGykZyXbtFQ6WPn0B0Pb6yqCQsIdb7OMeoNWbonh2PgGo2ZObvCiyh12CqMEBt0G9UIdb7O2MdY0BRMhli4pAWExXHGDuBZbz6TvKSm65XccmrjL0G9UIdb7O2i)WqbKFUjrMdG8ZvCiyh1g5hgQazG2uqerainyVRUeuyRZU(Srnj3avGguyUWMHovzlZyXbtFQ6WPn0B0Pb6yqCQskaDuNDTr(HH5Wo1a0XEgnOAcnStxpVmilZyXbtFQ6WPn0B0Pb6yqCQsIdb7OodAZHDQImha5NRcqh1zxBKFyOcKbAxMXIdM(u1HtBO3Otd0XG4uLehc2rn9GNN5WovrMdG8ZvbOJ6SRnYpmubYaTnrd27koeSJAHnhnOAESGG)Ob7Dfhc2rTWMJgurYYONhliOmJfhm9PQdN2qVrNgOJbXPkjaKpB6mC0CyNARdqh7z0GQdjnYGh6pomiIir6aGWt1a7No76Zg1dOWUmJfhm9PQdN2qVrNgOJbXPkPa0rD21g5hgLz)wTTYETFiHbwlF1sYYu78ybbZAZET)6x1YoqTFyT2Su0j8QfCIa12IZFQTnEMxl4eRLRDESGGAVSwJaLI(vljOlSHEtTG(aNZAdq3HEtTNnwRCQCqME7Ahyd6aC0UmJfhm9PQdN2qVrNgOJbXPkjoeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjAWExjgihcEEqVrnpwqavAWExjgihcEEqVrrYYONhliWKiLIo7Nsk6ND7WKiZbq(5ksyezm1zxFzqI(PcKbABQ1s5aY0duHKg5hgiGMMJGBqtImha5NR4qWoQnYpmubYaTlZ(TALqgK8y0U2pSwdgg1AKhm9AbNyTFWZU2wUvnVwAWRw4v7hCmQDWZR2r6n1IEc2yxBpJAPZZU2ZgR93LTATSduBl3Q1(bDG8BwlOpW5S2a0DO3u7zJ1AzvBg1(JCqTdSbDaoG4SmJfhm9PQdN2qVrNgOJbXPkjJ8GPBoStT1bOJ9mAq1HKgzWd9hhgMOS1bOJ9mAq1eAyNUEEzqsers5aY0duzeOb4yOrPjvzPOmJfhm9PQdN2qVrNgOJbXPkjaKpB6mC0CyNknyVRcqh1zxBKFyOaYpNiImcuQUraOKvXHGDutZrWnyzgloy6tvhoTHEJonqhdItvsbdaz)0tdoiWCyNknyVRcqh1zxBKFyOaYpNiImcuQUraOKvXHGDutZrWnyzgloy6tvhoTHEJonqhdItvsKWiYyQZU(YGe9ZCyNknyVRcqh1zxBKFyOcKKH(8pkLZexUTOa0XEgnOAcnStxpVmiPOm73QvoWg9Adq3HEtTNnwRCQCqME7Ahyd6aC028AbNyTTCRwln2ZaR9N8AX1EzTaGKg1Y12bhJ21opwqaculnhC0GLzS4GPpvD40g6n60aDmiovjXHGDuBKFyyoStvkhqMEGkK0i)Wab00CeCdAIgS3vbOJ6SRnYpmuGgMOKKDwziU)OuUedXPuwj3IePu0z)ue0oGStbferenyVRedKdbppO3OMhliGknyVRedKdbppO3Oizz0ZJfeqrzgloy6tvhoTHEJonqhdItvsCiyh10CeCdAoStvkhqMEGkK0i)Wab00CeCdAIgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWenyVR4qWoQnYpmuGgLzS4GPpvD40g6n60aDmiovjDjOWwND9zJAsUbAoStLgS3vbOJ6SRnYpmua5Ntergbkv3iauYQ4qWoQP5i4gKiImcuQUraOKvfmaK9tpn4GaIiYiqP6gbGswfaYNnDgowMXIdM(u1HtBO3Otd0XG4uLehc2rTr(HH5WovJaLQBeakzvxckS1zxF2OMKBGLz)wTYHtS2wnBX1EzTZwiiI)EyTSxlkZfCTTCiyhR9)bpVAbadO3u7zJ1(tETyj1YTATFqhi)Qf0h4CwBa6o0BQTLdb7yTYjc7uvBRSxBlhc2XALte2zTWzThpq)qaZR9dRvWoHxTGtS2wnBX1(bpBOx7zJ1(tETyj1YTATFqhi)Qf0h4Cw7hwl0pmcqJR2ZgRTLBX1kSz3XH51oZA)qchJANSuSw4PkZyXbtFQ6WPn0B0Pb6yqCQsYiWj6cuNDnj0bmh2P26JhOFkoeSJAuyNMaqAWExDjOWwND9zJAsUbQanmbG0G9U6sqHTo76Zg1KCdufijd95FuPKfhmDfhc2rn9GNNcLbfGhQpij2IOb7DLrGt0fOo7AsOdOizz0ZJfeqrz2VvBRSxBRMT4AT5Pt4vlnIETGteOwaWa6n1E2yT)KxlU2pOdKFMx7hs4yul4eRfE1EzTZwiiI)EyTSxlkZfCTTCiyhR9)bpVAHETNnw7VlBvj1YTATFqhi)uLzS4GPpvD40g6n60aDmiovjze4eDbQZUMe6aMd7uPb7Dfhc2rTr(HHc0WenyVRcqh1zxBKFyOcKKH(8pQuYIdMUIdb7OMEWZtHYGcWd1hKeBr0G9UYiWj6cuNDnj0buKSm65XccOOmJfhm9PQdN2qVrNgOJbXPkjoeSJA6bppZHDQa5PcgaY(PNgCqGkqsg6t5rmereasd27QGbGSF6PbheOLcoCmyA4aETvZJfeipjxM9B1khG1(X(v7L1sYeG1obdS2pSwBwkwl6jyJDTKSZ12ZO2ZgRf9dgyTTCRw7h0bYpZRfLIETWETNngiHZANhCmQ9GKyTbsYqh6n1MET)USvv12kpcN1M(ODT04Dyu7L1sdgETxw7VhgzTSduRCI0SwyV2a0DO3u7zJ1AzvBg1(JCqTdSbDaoG4uvMXIdM(u1HtBO3Otd0XG4uLehc2rnnhb3GMd7ufzoaYpxXHGDuBKFyOcKbABIKDwziU)OuokzItPSsUfjsPOZ(PiODazNckmrd27koeSJAHnhnOAESGaQ0G9UIdb7OwyZrdQizz0ZJfeyIYwhGo2ZObvtOHD665LbjrejLditpqLrGgGJHgLMuLLctToaDSNrdQoK0idEO)4WWuRdqh7z0GkoeSJABoitVDz2Vv7)CeCdw70obha165vlnwl4ebQLVApBSw0bQn712YTATWETYjstbFW0RfoRnqgODT8SwGinmGEtTcBoAWzTFWXOwsMaSw4v7XeG1osVbJAVSwAWWR9SJeSXU2ajzOd9MAjzNlZyXbtFQ6WPn0B0Pb6yqCQsIdb7OMMJGBqZHDQ0G9UIdb7O2i)WqbAyIgS3vCiyh1g5hgQajzOp)JAJaWKiZbq(5kuAk4dMUkqsg6ZYSFR2)5i4gS2PDcoaQLhFC7zT0yTNnw7GNxTcEE1c9ApBS2Fx2Q1(bDG8RwEw7p51IR9dog1g48YaR9SXAf2C0GZANgOFLzS4GPpvD40g6n60aDmiovjXHGDutZrWnO5WovAWExfGoQZU2i)WqbAyIgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgQajzOp)JAJaWuRdqh7z0GkoeSJABoitVDzgloy6tvhoTHEJonqhdItvsCiyh1KW5eoWP5WovaKgS3vxckS1zxF2OMKBGkqdthpq)uCiyh1OWonrjnyVRaq(SPZWrfq(5ereloOuuJoscXjvzPWeasd27Qlbf26SRpButYnqvGKm0NYJfhmDfhc2rnjCoHdCQqzqb4H6dsIMlSzOtvwZrogT1cBg6AyNknyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GiIOS1hpq)uPummYpmqatusd27Qa0rD21g5hgkqdIisK5ai)Cfknf8btxfid0MckOOm73QTv2R9djmWALI(z3omVwijjca5dhTRfCI1(RFv7Nn61kyddeO2lR1ZR2pEEyTgrkM12JKS2wC(tzgloy6tvhoTHEJonqhdItvsCiyh1KW5eoWP5WovrkfD2pLu0p72HjAWExjgihcEEqVrnpwqavAWExjgihcEEqVrrYYONhliOm73Q1644QfCc9MA)1VQTLBX1(zJETTCRwRnpRLgrVwWjcuMXIdM(u1HtBO3Otd0XG4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZKiZbq(5koeSJAJ8ddvGKm0NMOKgS3vbOJ6SRnYpmuGgerenyVR4qWoQnYpmuGguyUWMHovzlZyXbtFQ6WPn0B0Pb6yqCQsIdb7OodAZHDQ0G9UIdb7OwyZrdQMhli4pQs5aY0duD5rQjzz0cBoAWzzgloy6tvhoTHEJonqhdItvsCiyh10dEEMd7uPb7Dva6Oo7AJ8ddfObrerYoRmeN8KLykZyXbtFQ6WPn0B0Pb6yqCQscLMc(GPBoStLgS3vbOJ6SRnYpmua5NBIgS3vCiyh1g5hgkG8Znh6hgbOXPHDQKSZkdXjpQTuIXCOFyeGgNgssIaq(qQYwMXIdM(u1HtBO3Otd0XG4uLehc2rnnhb3GLzLz)2VvRCOpbnmY4qGAfSlWHMfhmD50Uw5ePPGpy61(bhJAPXAD(adEmAxlDKeGETWETI0bGhm9zTCG1sINQm73(TAzXbtFQS5Gm92ufSlWHMfhmDZHDQS4GPRqPPGpy6kHn7ooGEJjs2zLH4Kh1waXuM9B12k71oYVAtVws25AzhOwrMdG8ZN1YbwRijHEtTGgMxBtwlBJmqTSdulknlZyXbtFQS5Gm92eNQKqPPGpy6Md7ujzNvgI7pQeRKnjLditpqvcEtiaQZUwK5ai)8PjkpEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)jRKPOm73QvoaR9J9R2lRDESGGAT5Gm9212bhJ2QA)XgRfCI1M9ALvox78ybbZATXaRfoR9YAzHib9R2Eg1E2yThuqqTdSF1METNnwRWMDhh1YoqTNnwljCoHdSwOxBFaBSpvzgloy6tLnhKP3M4uLehc2rnjCoHdCAoStLsPCaz6bQMhliqBZbz6TjIOdsI)jRKPWenyVR4qWoQT5Gm92Q5Xcc(tw5S5cBg6uLTm73QvoWg9AbNqVPw5esJ2bYJA)9daNDbAETcEE1Y12XVArzUGRLeoNWboR9ZgoWA)y4b9MA7zu7zJ1sd271YxTNnw7844Qn71E2yTDyJ9vMXIdM(uzZbz6TjovjXHGDutcNt4aNMd7uXwii0WabuiPr7a5HodaNDbA6GK4FeRKnDztZavImha5NpnjYCaKFUcjnAhip0za4SlqvGKm0NYtw5Cl1uRzXbtxHKgTdKh6maC2fOcaoz6bcuMXIdM(uzZbz6TjovjfmaK9tpn4GaZHDQs5aY0duHKg5hgiGMMJGBqtImha5NRUeuyRZU(Srnj3avbsYqF(hvuguaEO(GKOjrMdG8ZvCiyh1g5hgQajzOp)JkLOmOa8q9bjXwKCPWeLTgBHGqddeqntWXaVd6n6aKUnrejshaeEkoeSJAJibGnTvb7eipQedreDb0jap1mbhd8oO3Odq62krMdG8ZvbsYqF(hvkrzqb4H6dsITi5sbfLzS4GPpv2CqMEBItvsxckS1zxF2OMKBGMd7uLYbKPhOQveCEAWjcONgCqGjrMdG8ZvCiyh1g5hgQajzOp)JkkdkapuFqs0eLTgBHGqddeqntWXaVd6n6aKUnrejshaeEkoeSJAJibGnTvb7eipQedreDb0jap1mbhd8oO3Odq62krMdG8ZvbsYqF(hvuguaEO(GKifLzS4GPpv2CqMEBItvsCiyh1g5hgMd7uncuQUraOKvDjOWwND9zJAsUbwMXIdM(uzZbz6TjovjfGoQZU2i)WWCyNQuoGm9aviPr(HbcOP5i4g0KiZbq(5QGbGSF6PbheOcKKH(8pQOmOa8q9bjrts5aY0duDqsud6hCOzd5rvUs2eLTwKoai8uCiyh1grcaBAterTwkhqMEGkE8XTN6zBxOfzoaYpFserImha5NRUeuyRZU(Srnj3avbsYqF(hvkrzqb4H6dsITi5sbfLzS4GPpv2CqMEBItvsbdaz)0tdoiWCyNQuoGm9aviPr(HbcOP5i4g0KrGs1ncaLSQa0rD21g5hgLzS4GPpv2CqMEBItvsxckS1zxF2OMKBGMd7uLYbKPhOQveCEAWjcONgCqGPwlLditpqLDoaGEJ(YJSm73QvoCI1kxhOwoeSJ1sZrWnyTqV2wUvj(V73VvRn9r7AH9A)FKjWaCE1YoqT8v7a55vRCR9x)AwRrKcbcuMXIdM(uzZbz6TjovjXHGDutZrWnO5WovAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGat0G9UkaDuNDTr(HHc0WenyVR4qWoQnYpmuGgMOb7Dfhc2rTnhKP3wnpwqG8OkRC2enyVR4qWoQnYpmubsYqF(hvwCW0vCiyh10CeCdQqzqb4H6dsIMOb7Df9itGb48uGgLz)wTYHtSw56a1(7YwTwOxBl3Q1M(ODTWET)pYeyaoVAzhOw5w7V(1SwJifLzS4GPpv2CqMEBItvsbOJ6SRnYpmmh2Psd27Qa0rD21g5hgkG8Znrd27k6rMadW5PanmrPuoGm9avhKe1G(bhA2qEeRKjIirMdG8Zvbdaz)0tdoiqfijd9P8KvUuyIsAWExXHGDuBZbz6TvZJfeipQYsmerenyVRedKdbppO3OMhliqEuLLctu2Ar6aGWtXHGDuBejaSPnre1APCaz6bQ4Xh3EQNTDHwK5ai)8jfLzS4GPpv2CqMEBItvsbOJ6SRnYpmmh2Psd27koeSJAJ8ddfq(5MOukhqMEGQdsIAq)GdnBipIvYerKiZbq(5QGbGSF6PbheOcKKH(uEYkxkmrzRfPdacpfhc2rTrKaWM2eruRLYbKPhOIhFC7PE22fArMdG8ZNuuMXIdM(uzZbz6TjovjfmaK9tpn4GaZHDQs5aY0duHKg5hgiGMMJGBqtusd27koeSJAHnhnOAESGa5rvUerKiZbq(5koeSJ6mOvbYaTPWeLT(4b6NkaDuNDTr(HbrejYCaKFUkaDuNDTr(HHkqsg6t5rmuyskhqMEGkCEqs(qanBOfzoaYpxEujwjBIYwlshaeEkoeSJAJibGnTjIOwlLditpqfp(42t9STl0Imha5NpPOm73QvoWg9Adq3HEtTgrcaBABETGtS2lpYAPBxl8M4Oxl0RndamQ9YA5bSXRfE1(bp7AzJYmwCW0NkBoitVnXPkPlbf26SRpButYnqZHDQs5aY0duDqsud6hCOzJ)igjBskhqMEGQdsIAq)GdnBipIvYMOS1yleeAyGaQzcog4DqVrhG0TjIir6aGWtXHGDuBejaSPTkyNa5rLyOOmJfhm9PYMdY0BtCQsIdb7OodAZHDQs5aY0du1kcopn4eb0tdoiWenyVR4qWoQf2C0GQ5Xcc(JgS3vCiyh1cBoAqfjlJEESGGYmwCW0NkBoitVnXPkjoeSJAAocUbnh2PcG0G9Ukyai7NEAWbbAPGdhdMgoGxB18ybbubqAWExfmaK9tpn4GaTuWHJbtdhWRTIKLrppwqqzgloy6tLnhKP3M4uLehc2rn9GNN5WovPCaz6bQAfbNNgCIa6PbheqerucG0G9Ukyai7NEAWbbAPGdhdMgoGxBfOHjaKgS3vbdaz)0tdoiqlfC4yW0Wb8ARMhli4paKgS3vbdaz)0tdoiqlfC4yW0Wb8ARizz0ZJfeqrz2VvRC4eRLe6WA)NJGBWAPX7drV2GbGSF1on4GGzTWETGoag1(Vev7h8StWRwaCWTHEtT)ogaY(vRLbheulea5XODzgloy6tLnhKP3M4uLehc2rnnhb3GMd7uPb7Dva6Oo7AJ8ddfOHjAWExXHGDuBKFyOaYp3enyVROhzcmaNNc0WKiZbq(5QGbGSF6PbheOcKKH(8pQYkzt0G9UIdb7O2MdY0BRMhliqEuLvoxM9B1khoXAZGU20RvaulOpW5Sw2Ow4Swrsc9MAbnQDMPxMXIdM(uzZbz6TjovjXHGDuNbT5WovAWExXHGDulS5ObvZJfe8hXAskhqMEGQdsIAq)GdnBipzLSjkfzoaYpxDjOWwND9zJAsUbQcKKH(uEedre1Ar6aGWtXHGDuBejaSPnfLzS4GPpv2CqMEBItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilot0G9UIdb7O2i)WqbAyUWMHovzlZ(TABL9A)WABWRwJ8dJAHEhCctVwaWa6n1oaNxTFiHJrT2SuSw0tWg7AT55H1EzTn4vB271Y1oVi9MAP5i4gSwaWa6n1E2yTrAij2O2pOdKFLzS4GPpv2CqMEBItvsCiyh10CeCdAoStLgS3vbOJ6SRnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)rLfhmDfhc2rnjCoHdCQqzqb4H6dsIMOb7Dfhc2rTr(HHc0WenyVR4qWoQf2C0GQ5XccOsd27koeSJAHnhnOIKLrppwqGjAWExXHGDuBZbz6TvZJfeyIgS3vg5hgAO3bNW0vGgMOb7Df9itGb48uGgLz)wTTYETFyTn4vRr(HrTqVdoHPxlaya9MAhGZR2pKWXOwBwkwl6jyJDT288WAVS2g8Qn79A5ANxKEtT0CeCdwlaya9MApBS2inKeBu7h0bYpZRDM1(Heog1M(ODTGtSw0tWg7APh88M1cD4b5XODTxwBdE1EzT9emQvyZrdolZyXbtFQS5Gm92eNQK4qWoQPh88mh2Psd27kJaNOlqD21KqhqbAyIsAWExXHGDulS5ObvZJfe8hnyVR4qWoQf2C0Gkswg98ybberuRPKgS3vg5hgAO3bNW0vGgMOb7Df9itGb48uGguqrz2Vv7p2yT048QfCI1M9AnsYAHZAVSwWjwl8Q9YABHGqbbJ21sdcha1kS5ObN1cagqVPw2OwUFyu7zJTRTbVAbajnqGAPBx7zJ1AZbz6TRLMJGBWYmwCW0NkBoitVnXPkjJaNOlqD21KqhWCyNknyVR4qWoQf2C0GQ5Xcc(JgS3vCiyh1cBoAqfjlJEESGat0G9UIdb7O2i)WqbAuM9B1khG1(X(v7L1opwqqT2CqME7A7GJrBvT)yJ1coXAZETYkNRDESGGzT2yG1cN1EzTSqKG(vBpJApBS2dkiO2b2VAtV2ZgRvyZUJJAzhO2ZgRLeoNWbwl0RTpGn2NQmJfhm9PYMdY0BtCQsIdb7OMeoNWbonh2Psd27koeSJABoitVTAESGG)KvoBUWMHovznh6hgbOXrvwZH(HraAC6MrsZdQYwMXIdM(uzZbz6TjovjXHGDutZrWnO5WovAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGats5aY0duHKg5hgiGMMJGBWYmwCW0NkBoitVnXPkjuAk4dMU5Wovs2zLH4(twIPm73Q933hTRfCI1sp45v7L1sdcha1kS5ObN1c71(H1YJazG21AZsXANjjwBpsYAZGUmJfhm9PYMdY0BtCQsIdb7OMEWZZCyNknyVR4qWoQf2C0GQ5Xccmrd27koeSJAHnhnOAESGG)Ob7Dfhc2rTWMJgurYYONhliOm73QvoDWXO2p4zxltwlOpW5Sw2Ow4Swrsc9MAbnQLDGA)qcdS2r(vB61sYoxMXIdM(uzZbz6TjovjXHGDutcNt4aNMd7uBnLs5aY0duDqsud6hCOzJ)OkRKnrYoRme3FeRKPWCHndDQYAo0pmcqJJQSMd9dJa040nJKMhuLTm73QTvJSdh4S2p4zx7i)QLKNhgTnVwByJDT288qZRnJAPZZUwsUDTEE1AZsXArpbBSRLKDU2lRDcAyKXvRD(vlj7CTq)qFcLI1gmaK9R2PbheuRG9APrZRDM1(Heog1coXA7WaRLEWZRw2bQTh58OZXv7Nn61oYVAtVws25YmwCW0NkBoitVnXPkPomqn9GNxzgloy6tLnhKP3M4uLupY5rNJRmRmJfhm9PknqhdQDyGA6bppZHDQbOJ9mAqfaCkGgdOZrBTijjzhWenyVRaGtb0yaDoARfjjj7a6EKZtbAuMXIdM(uLgOJbXPkPEKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAIKDwzio51ciMYmwCW0NQ0aDmiovjbG8ztNHJLzS4GPpvPb6yqCQskyai7NEAWbbMd7ujzNvgItEYrjxMXIdM(uLgOJbXPkjsyezm1zxFzqI(vMXIdM(uLgOJbXPkPPnSFqVrBKFyyoStLgS3vCiyh1g5hgkG8ZnjYCaKFUIdb7O2i)Wqfijd9zzgloy6tvAGogeNQK4qWoQZG2CyNQiZbq(5koeSJAJ8ddvGmqBt0G9UIdb7OwyZrdQMhli4pAWExXHGDulS5ObvKSm65XcckZyXbtFQsd0XG4uLehc2rn9GNN5WovrkfD2pLu0p72HjrMdG8ZvKWiYyQZU(YGe9tfijd9P8APYXYmwCW0NQ0aDmiovjDjOWwND9zJAsUbwMXIdM(uLgOJbXPkjoeSJAJ8dJYmwCW0NQ0aDmiovjfGoQZU2i)WWCyNknyVR4qWoQnYpmua5NxM9B1khoXAB1Sfx7L1oBHGi(7H1YETOmxW12YHGDS2)h88QfamGEtTNnw7p51ILul3Q1(bDG8RwqFGZzTbO7qVP2woeSJ1kNiStvTTYETTCiyhRvoryN1cN1E8a9dbmV2pSwb7eE1coXAB1Sfx7h8SHETNnw7p51ILul3Q1(bDG8RwqFGZzTFyTq)WianUApBS2wUfxRWMDhhMx7mR9djCmQDYsXAHNQmJfhm9PknqhdItvsgborxG6SRjHoG5Wo1wF8a9tXHGDuJc70easd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)JkLS4GPR4qWoQPh88uOmOa8q9bjXwenyVRmcCIUa1zxtcDafjlJEESGakkZ(TABL9AB1SfxRnpDcVAPr0RfCIa1cagqVP2ZgR9N8AX1(bDG8Z8A)qchJAbNyTWR2lRD2cbr83dRL9ArzUGRTLdb7yT)p45vl0R9SXA)DzRkPwUvR9d6a5NQmJfhm9PknqhdItvsgborxG6SRjHoG5WovAWExXHGDuBKFyOanmrd27Qa0rD21g5hgQajzOp)JkLS4GPR4qWoQPh88uOmOa8q9bjXwenyVRmcCIUa1zxtcDafjlJEESGakkZyXbtFQsd0XG4uLehc2rn9GNN5WovG8ubdaz)0tdoiqfijd9P8igIicaPb7DvWaq2p90Gdc0sbhogmnCaV2Q5XccKNKlZ(TAB5Xh3Ew7)CeCdwlF1E2yTOduB2RTLB1A)SrV2a0DO3u7zJ12YHGDSw5u5Gm921oWg0b4ODzgloy6tvAGogeNQK4qWoQP5i4g0CyNknyVR4qWoQnYpmuGgMOb7Dfhc2rTr(HHkqsg6Z)AeaMcqh7z0GkoeSJABoitVDz2VvBlp(42ZA)NJGBWA5R2ZgRfDGAZETNnw7VlB1A)Goq(v7Nn61gGUd9MApBS2woeSJ1kNkhKP3U2b2GoahTlZyXbtFQsd0XG4uLehc2rnnhb3GMd7uPb7Dva6Oo7AJ8ddfOHjAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOcKKH(8pQncatbOJ9mAqfhc2rTnhKP3UmJfhm9PknqhdItvsCiyh1KW5eoWP5WovaKgS3vxckS1zxF2OMKBGkqdthpq)uCiyh1OWonrjnyVRaq(SPZWrfq(5ereloOuuJoscXjvzPWeasd27Qlbf26SRpButYnqvGKm0NYJfhmDfhc2rnjCoHdCQqzqb4H6dsIMlSzOtvwZrogT1cBg6AyNknyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GiIOS1hpq)uPummYpmqatusd27Qa0rD21g5hgkqdIisK5ai)Cfknf8btxfid0MckOOmJfhm9PknqhdItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrnpwqavAWExjgihcEEqVrrYYONhliWKiLIo7Nsk6ND7OmJfhm9PknqhdItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilotImha5NR4qWoQnYpmubsYqFAIsAWExfGoQZU2i)WqbAqer0G9UIdb7O2i)WqbAqH5cBg6uLTmJfhm9PknqhdItvsCiyh1zqBoStLgS3vCiyh1cBoAq18ybb)rvkhqMEGQlpsnjlJwyZrdolZyXbtFQsd0XG4uLehc2rn9GNN5WovAWExfGoQZU2i)WqbAqerKSZkdXjpzjMYmwCW0NQ0aDmiovjHstbFW0nh2Psd27Qa0rD21g5hgkG8Znrd27koeSJAJ8ddfq(5Md9dJa040Wovs2zLH4Kh1wkXyo0pmcqJtdjjraiFivzlZyXbtFQsd0XG4uLehc2rnnhb3GLzLz)2Vvlloy6tvKhFW0PkyxGdnloy6Md7uzXbtxHstbFW0vcB2DCa9gtKSZkdXjpQTaIXeLToaDSNrdQMqd701ZldsIiIgS3vtOHD665LbPAESGaQ0G9UAcnStxpVmivKSm65XccOOm73QvoCI1IsZAH9A)qcdS2r(vB61sYoxl7a1kYCaKF(SwoWAz6e8Q9YAPXAbnkZyXbtFQI84dMoXPkjuAk4dMU5Wovs2zLH4(JQuoGm9avO0uBiotukYCaKFU6sqHTo76Zg1KCdufijd95FuzXbtxHstbFW0vOmOa8q9bjrIisK5ai)Cfhc2rTr(HHkqsg6Z)OYIdMUcLMc(GPRqzqb4H6dsIereLhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6Z)OYIdMUcLMc(GPRqzqb4H6dsIuqHjAWExfGoQZU2i)WqbKFUjAWExXHGDuBKFyOaYp3easd27Qlbf26SRpButYnqfq(5MATrGs1ncaLSQlbf26SRpButYnWYmwCW0NQip(GPtCQscLMc(GPBoStnaDSNrdQMqd701ZldstImha5NR4qWoQnYpmubsYqF(hvwCW0vO0uWhmDfkdkapuFqsSm73Q9FocUbRf2RfEeoR9GKyTxwl4eR9YJSw2bQ9dR1MLI1Ezwlj7TRvyZrdolZyXbtFQI84dMoXPkjoeSJAAocUbnh2PkYCaKFU6sqHTo76Zg1KCdufid02eL0G9UIdb7OwyZrdQMhliqEs5aY0duD5rQjzz0cBoAWPjrMdG8ZvCiyh1g5hgQajzOp)JkkdkapuFqs0ej7SYqCYtkhqMEGk2qtcDijiPMKDwBiot0G9UkaDuNDTr(HHci)CkkZyXbtFQI84dMoXPkjoeSJAAocUbnh2PkYCaKFU6sqHTo76Zg1KCdufid02eL0G9UIdb7OwyZrdQMhliqEs5aY0duD5rQjzz0cBoAWPPJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95Furzqb4H6dsIMKYbKPhO6GKOg0p4qZgYtkhqMEGQlpsnjlJgahCBDpdnBqrzgloy6tvKhFW0jovjXHGDutZrWnO5WovrMdG8ZvxckS1zxF2OMKBGQazG2MOKgS3vCiyh1cBoAq18ybbYtkhqMEGQlpsnjlJwyZrdonrzRpEG(Pcqh1zxBKFyqerImha5NRcqh1zxBKFyOcKKH(uEs5aY0duD5rQjzz0a4GBR7zOJ0Gcts5aY0duDqsud6hCOzd5jLditpq1LhPMKLrdGdUTUNHMnOOmJfhm9PkYJpy6eNQK4qWoQP5i4g0CyNkasd27QGbGSF6PbheOLcoCmyA4aETvZJfeqfaPb7DvWaq2p90Gdc0sbhogmnCaV2kswg98ybbMOKgS3vCiyh1g5hgkG8ZjIiAWExXHGDuBKFyOcKKH(8pQncakmrjnyVRcqh1zxBKFyOaYpNiIOb7Dva6Oo7AJ8ddvGKm0N)rTraqrzgloy6tvKhFW0jovjXHGDutp45zoStvkhqMEGQwrW5PbNiGEAWbbereLainyVRcgaY(PNgCqGwk4WXGPHd41wbAycaPb7DvWaq2p90Gdc0sbhogmnCaV2Q5Xcc(daPb7DvWaq2p90Gdc0sbhogmnCaV2kswg98ybbuuMXIdM(uf5XhmDItvsCiyh10dEEMd7uPb7DLrGt0fOo7AsOdOanmbG0G9U6sqHTo76Zg1KCdubAycaPb7D1LGcBD21NnQj5gOkqsg6Z)OYIdMUIdb7OMEWZtHYGcWd1hKelZyXbtFQI84dMoXPkjoeSJAs4Cch40CyNkasd27Qlbf26SRpButYnqfOHPJhOFkoeSJAuyNMOKgS3vaiF20z4Oci)CIiIfhukQrhjH4KQSuyIsaKgS3vxckS1zxF2OMKBGQajzOpLhloy6koeSJAs4Cch4uHYGcWd1hKejIirMdG8ZvgborxG6SRjHoGkqsg6tIisKsrN9trq7aYofMlSzOtvwZrogT1cBg6AyNknyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GiIOS1hpq)uPummYpmqatusd27Qa0rD21g5hgkqdIisK5ai)Cfknf8btxfid0MckOOm73Q9xPpbjXApBSwugd2bqGAnYd9dYJAPb79A5jBu7L165v7iNyTg5H(b5rTgrkMLzS4GPpvrE8btN4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZenyVRqzmyhab0g5H(b5Hc0OmJfhm9PkYJpy6eNQK4qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMOKgS3vCiyh1g5hgkqdIiIgS3vbOJ6SRnYpmuGgereasd27Qlbf26SRpButYnqvGKm0NYJfhmDfhc2rnjCoHdCQqzqb4H6dsIuyUWMHovzlZyXbtFQI84dMoXPkjoeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjAWExjgihcEEqVrnpwqavAWExjgihcEEqVrrYYONhliWCHndDQYwM9B12YJpU9S2lAx7L1sZob1(RFvBpJAfzoaYpV2pOdKFZAPbVAbajnQ9SrYAH9ApBSnHbwltNGxTxwlkJbmWYmwCW0NQip(GPtCQsIdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXzIgS3vIbYHGNh0BubsYqF(hvkPKgS3vIbYHGNh0BuZJfe0IyXbtxXHGDutcNt4aNkuguaEO(GKifeVraOizzOWCHndDQYwMXIdM(uf5XhmDItvsoE2yOpK0aNN5WovkdSh40MPhire16dkia6nuyIgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWenyVR4qWoQnYpmua5NBcaPb7D1LGcBD21NnQj5gOci)8YmwCW0NQip(GPtCQsIdb7OodAZHDQ0G9UIdb7OwyZrdQMhli4pQs5aY0duD5rQjzz0cBoAWzzgloy6tvKhFW0jovjnbnWWtPS5WovPCaz6bQsWBcbqD21Imha5NpnrYoRme3FuBbetzgloy6tvKhFW0jovjXHGDutp45zoStLgS3vb4a1zxF2bItfOHjAWExXHGDulS5ObvZJfeipITm73QvonGKg1kS5ObN1c71(H125XOwACKF1E2yTI0NyifRLKDU2ZoWPDoaQLDGArPPGpy61cN1op4yuB61kYCaKFEzgloy6tvKhFW0jovjXHGDutZrWnO5Wo1whGo2ZObvtOHD665LbPjPCaz6bQsWBcbqD21Imha5Npnrd27koeSJAHnhnOAESGaQ0G9UIdb7OwyZrdQizz0ZJfey64b6NIdb7OodAtImha5NR4qWoQZGwfijd95FuBeaMizNvgI7pQTajBsK5ai)Cfknf8btxfijd9zzgloy6tvKhFW0jovjXHGDutZrWnO5Wo1a0XEgnOAcnStxpVminjLditpqvcEtiaQZUwK5ai)8PjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGathpq)uCiyh1zqBsK5ai)Cfhc2rDg0QajzOp)JAJaWej7SYqC)rTfiztImha5NRqPPGpy6QajzOp)JyLCz2VvRCAajnQvyZrdoRf2Rnd6AHZAdKbAxMXIdM(uf5XhmDItvsCiyh10CeCdAoStvkhqMEGQe8MqauNDTiZbq(5tt0G9UIdb7OwyZrdQMhliGknyVR4qWoQf2C0Gkswg98ybbMoEG(P4qWoQZG2KiZbq(5koeSJ6mOvbsYqF(h1gbGjs2zLH4(JAlqYMezoaYpxHstbFW0vbsYqFwM9B12YHGDS2)5i4gS2PDcoaQTbDm4XODT0yTNnw7GNxTcEE1M9ApBS2wUvR9d6a5xzgloy6tvKhFW0jovjXHGDutZrWnO5WovAWExXHGDuBKFyOanmrd27koeSJAJ8ddvGKm0N)rTrayIgS3vCiyh1cBoAq18ybbuPb7Dfhc2rTWMJgurYYONhliWeLImha5NRqPPGpy6QajzOpjIOa0XEgnOIdb7O2MdY0Btrz2VvBlhc2XA)NJGBWAN2j4aO2g0XGhJ21sJ1E2yTdEE1k45vB2R9SXA)DzRw7h0bYVYmwCW0NQip(GPtCQsIdb7OMMJGBqZHDQ0G9UkaDuNDTr(HHc0WenyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmubsYqF(h1gbGjAWExXHGDulS5ObvZJfeqLgS3vCiyh1cBoAqfjlJEESGatukYCaKFUcLMc(GPRcKKH(KiIcqh7z0GkoeSJABoitVnfLz)wTTCiyhR9FocUbRDANGdGAPXApBS2bpVAf88Qn71E2yT)KxlU2pOdKF1c71cVAHZA98QfCIa1(bp7A)DzRwBg12YTAzgloy6tvKhFW0jovjXHGDutZrWnO5WovAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)JAJaWenyVR4qWoQf2C0GQ5XccOsd27koeSJAHnhnOIKLrppwqqz2VvRCGn61E2yThhn4vlCwl0RfLbfGhwBWEdwl7a1E2yG1cN1sMbw7zZETPJ1Ios228AbNyT0CeCdwlpRDMPxlpRTDcwRnlfRf9eSXUwHnhn4S2lR1gE1YJrTOJKqCwlSx7zJ12YHGDS2)tsAoair)QDGnOdWr7AHZAXwii0WabkZyXbtFQI84dMoXPkjoeSJAAocUbnh2PkLditpqfsAKFyGaAAocUbnrd27koeSJAHnhnOAESGa5rLswCqPOgDKeIZwbzPWeloOuuJoscXP8K1enyVRaq(SPZWrfq(5LzS4GPpvrE8btN4uLehc2rnkJXiNW0nh2PkLditpqfsAKFyGaAAocUbnrd27koeSJAHnhnOAESGG)Ob7Dfhc2rTWMJgurYYONhliWeloOuuJoscXP8K1enyVRaq(SPZWrfq(5LzS4GPpvrE8btN4uLehc2rn9GNxzgloy6tvKhFW0jovjHstbFW0nh2PkLditpqvcEtiaQZUwK5ai)8zzgloy6tvKhFW0jovjXHGDutZrWn47E37b]] )

    
end