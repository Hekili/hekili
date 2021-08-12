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


    spec:RegisterPack( "Arcane", 20210812, [[da10ehqiPK8ieiUervsjBII8jvvnkKOtHewLuIQxremlkQULuIIDrYViImmIOogrPLruXZqGAAevPUgcOTruf9nPKIXjLaNtkbToeQ6DevjLAEQQ09qs7JOQoOuISqekpebyIevjfxKOkXgjQsQ8rIQKyKevjPtkLuALuuEjrvsvZeHk3ukHANeH(jcKQHkLuTuei5PuYuvvXvjQc9vIQGXsuP9Qk)LudwPdJAXi1JjmzaxgAZs1NLIrtPonOvlLO0RrqZwHBJODt1VfnCkCCPeYYfEUIMUkxhOTtK(UQY4jkoVuQ1JaPmFeY(L8t23ppla(WNeLJKLJSsUfiRCusUfk5wOKBnpRRTb(SmybHCd(SCMeFwTuiyhFwgC7rYaVFEwZeme4ZY(oJjXljj1apBqALijL0esco4dMUi4(jPjKuiPNfniCCTw)r)Sa4dFsuoswoYk5wGSYrj5wOKBHsMaFwtdu8KO8uoplBiaa6p6NfaofpRwm3G12sHGDSmRLaBaNxTYkhZRvoswoYwMvMra2S3GtIVmRLPw5Xjw712ak4rTwqscOwB2bgqVP2SxRWMDhh1c9dJa04GPxl0NhYa1M9A)lyxGdnloy6)vLzTm1sa2S3G1YHGDud9o0Hx7AVSwoeSJABoitVDTucVADukg1(H(v7akfRLN1YHGDuBZbz6TPq9SgW5nF)8Ssd0X49ZtIY((5zHotpqGhXEwIaEya5Nva6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1sd27ka4uangqNJ2ArssYoGUh58uGgplwCW0FwDyGA6bpV39KOCE)8SqNPhiWJyplrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1sYoRmexTYV2wib(SyXbt)z1JCEApLYV7jrc(9ZZIfhm9NfaYNnDgo(SqNPhiWJyV7jr597NNf6m9abEe7zjc4HbKFwKSZkdXvR8RvEl5Nfloy6pRGbGSF6Pbhe(UNejW3pplwCW0FwKWiYyQZU(YGe97zHotpqGhXE3tIYZ3ppl0z6bc8i2ZseWddi)SOb7Dfhc2rTr(HHci)8AnvRiZbq(5koeSJAJ8ddvGKm0NplwCW0FwtBy)GEJ2i)W4Dpj2AE)8SqNPhiWJyplrapmG8ZsK5ai)Cfhc2rTr(HHkqgODTMQLgS3vCiyh1cBoAq18ybH1(BT0G9UIdb7OwyZrdQizz0ZJfe(SyXbt)zXHGDuNb97EsSf8(5zHotpqGhXEwIaEya5NLiLIo7Nsk6ND7Owt1kYCaKFUIegrgtD21xgKOFQajzOpRv(12cK3plwCW0FwCiyh10dEEV7jXw47NNfloy6pRlbf26SRpButYnWNf6m9abEe7DpjkRKF)8SyXbt)zXHGDuBKFy8SqNPhiWJyV7jrzL99ZZcDMEGapI9Seb8WaYplAWExXHGDuBKFyOaYp)zXIdM(ZkaDuNDTr(HX7Esuw58(5zHotpqGhXEwS4GP)SmcCIUa1zxtcDGNfaofb04GP)SKhNyTTE2IR9YANTiqejOH1YETOmxW12sHGDSwIn45vlaya9MApBS2FYRflPwQ1R9d6a5xTG(aNZAdq3HEtTTuiyhRvEryNQABT9ABPqWowR8IWoRfoR94b6hcyETFyTc2)F1coXAB9Sfx7h8SHETNnw7p51ILul161(bDG8RwqFGZzTFyTq)WianUApBS2wQfxRWMDhhMx7mR9d)pg1ozPyTWt9Seb8WaYpRwv7Xd0pfhc2rnkStf6m9abQ1uTainyVRUeuyRZU(Srnj3avGg1AQwaKgS3vxckS1zxF2OMKBGQajzOpR9xQ1szTS4GPR4qWoQPh88uOmOa8q9bjXAB51sd27kJaNOlqD21KqhqrYYONhliSwkE3tIYsWVFEwOZ0de4rSNfloy6plJaNOlqD21Kqh4zbGtranoy6pRwBV2wpBX1AZt))vlnIETGteOwaWa6n1E2yT)KxlU2pOdKFMx7h(FmQfCI1cVAVS2zlcercAyTSxlkZfCTTuiyhRLydEE1c9ApBSwcQS1Lul161(bDG8t9Seb8WaYplAWExXHGDuBKFyOanQ1uT0G9UkaDuNDTr(HHkqsg6ZA)LATuwlloy6koeSJA6bppfkdkapuFqsS2wET0G9UYiWj6cuNDnj0buKSm65XccRLI39KOSY73ppl0z6bc8i2ZseWddi)SaYtfmaK9tpn4GqvGKm0N1k)AjWAjIOAbqAWExfmaK9tpn4GqTuWHJbtdhWRTAESGWALFTs(zXIdM(ZIdb7OMEWZ7Dpjklb((5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6pRwA8XTN1smocUbRLVApBSw0bQn712sTETF2OxBa6o0BQ9SXABPqWowR8QCqME7Ahyd6aC0(zjc4HbKFw0G9UIdb7O2i)WqbAuRPAPb7Dfhc2rTr(HHkqsg6ZA)T2gbqTMQnaDSNrdQ4qWoQT5Gm92k0z6bc8UNeLvE((5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6pRwA8XTN1smocUbRLVApBSw0bQn71E2yTeuzRx7h0bYVA)SrV2a0DO3u7zJ12sHGDSw5v5Gm921oWg0b4O9ZseWddi)SOb7Dva6Oo7AJ8ddfOrTMQLgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHkqsg6ZA)LATncGAnvBa6ypJguXHGDuBZbz6TvOZ0de4DpjkBR59ZZcDMEGapI9Se2m0FwY(SqogT1cBg6Ay)zrd27kXa5qWZd6nAHn7ooua5NBIsAWExXHGDuBKFyOaniIikB1Xd0pvkfdJ8ddeWeL0G9UkaDuNDTr(HHc0GiIezoaYpxHstbFW0vbYaTPGckEwIaEya5Nfasd27Qlbf26SRpButYnqfOrTMQ94b6NIdb7Ogf2PcDMEGa1AQwkRLgS3vaiF20z4Oci)8AjIOAzXbLIA0rsioRLATYwlf1AQwaKgS3vxckS1zxF2OMKBGQajzOpRv(1YIdMUIdb7OMeoNWbovOmOa8q9bjXNfloy6ploeSJAs4Cch48DpjkBl49ZZcDMEGapI9Seb8WaYplAWExjgihcEEqVrnpwqyTuRLgS3vIbYHGNh0BuKSm65XccR1uTIuk6SFkPOF2TJNfloy6ploeSJAs4Cch48DpjkBl89ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZIgS3vIbYHGNh0BubYIRwt1kYCaKFUIdb7O2i)Wqfijd9zTMQLYAPb7Dva6Oo7AJ8ddfOrTeruT0G9UIdb7O2i)WqbAulfV7jr5i53ppl0z6bc8i2ZseWddi)SOb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQU8i1KSmAHnhn48zXIdM(ZIdb7Ood639KOCK99ZZcDMEGapI9Seb8WaYplAWExfGoQZU2i)WqbAulrevlj7SYqC1k)ALLaFwS4GP)S4qWoQPh88E3tIYroVFEwOZ0de4rSNfloy6pluAk4dM(Zc6hgbOXPH9Nfj7SYqCYNAlGaFwq)WianonKKebG8HplzFwIaEya5NfnyVRcqh1zxBKFyOaYpVwt1sd27koeSJAJ8ddfq(5V7jr5qWVFEwS4GP)S4qWoQP5i4g8zHotpqGhXE37EwD40g6n60aDmE)8KOSVFEwOZ0de4rSNfloy6pluAk4dM(ZcaNIaACW0FwYd2OxBa6o0BQfHNng1E2yTww1MrT)ipu7aBqhGdionV2pS2p2VAVSw5fPzT0ypdS2ZgR9N8AXsQLA9A)Goq(PQvECI1cVA5zTZm9A5zTeuzRxRnpRTdD40gbQnbJA)W)sXANgOF1MGrTcBoAW5ZseWddi)SOS2a0XEgnO6qsJm4H(Jddf6m9abQLiIQLYAdqh7z0GQj0WoD98YGuHotpqGAnvBRQvkhqMEGkJanahdnknRLATYwlf1srTMQLYAPb7Dva6Oo7AJ8ddfq(51ser1AeOuDJaqjRIdb7OMMJGBWAPOwt1kYCaKFUkaDuNDTr(HHkqsg6Z39KOCE)8SqNPhiWJyplwCW0FwO0uWhm9Nfaofb04GP)SAT9A)W)sXA7qhoTrGAtWOwrMdG8ZR9d6a53Sw2bQDAG(vBcg1kS5ObNMxRraZaEqcAyTYlsZAtPyulkfJ2Nn0BQfht8zjc4HbKFwhpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZAnvRiZbq(5koeSJAJ8ddvGKm0N1AQwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTgbkv3iauYQ4qWoQP5i4g8DpjsWVFEwOZ0de4rSNLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uT0G9UcaofqJb05OTwKKKSdO7ropfOXZIfhm9NvhgOMEWZ7DpjkVF)8SqNPhiWJyplrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1sYoRmexTYV2wib(SyXbt)z1JCEApLYV7jrc89ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZkaDSNrdQ4qWoQT5Gm92k0z6bcuRPAPb7Dfhc2rTnhKP3wnpwqyT)wlnyVR4qWoQT5Gm92kswg98ybH1AQwkRLYAPb7Dfhc2rTr(HHci)8AnvRiZbq(5koeSJAJ8ddvGmq7APOwIiQwaKgS3vxckS1zxF2OMKBGkqJAP4DpjkpF)8SqNPhiWJyplrapmG8ZkaDSNrdQMqd701Zldsf6m9abEwS4GP)Scqh1zxBKFy8UNeBnVFEwOZ0de4rSNLiGhgq(zjYCaKFUkaDuNDTr(HHkqgO9ZIfhm9Nfhc2rDg0V7jXwW7NNf6m9abEe7zjc4HbKFwImha5NRcqh1zxBKFyOcKbAxRPAPb7Dfhc2rTWMJgunpwqyT)wlnyVR4qWoQf2C0Gkswg98ybHplwCW0FwCiyh10dEEV7jXw47NNf6m9abEe7zjc4HbKFwTQ2a0XEgnO6qsJm4H(Jddf6m9abQLiIQvKoai8unW(PZU(Sr9akSvOZ0de4zXIdM(Zca5ZModhF3tIYk53pplwCW0FwbOJ6SRnYpmEwOZ0de4rS39KOSY((5zHotpqGhXEwS4GP)S4qWoQjHZjCGZNfaofb04GP)SAT9A)W)bwlF1sYYu78ybHZAZETeabul7a1(H1AZsr))vl4ebQTfN)uBB8mVwWjwlx78ybH1EzTgbkf9Rwsqxyd9MAb9boN1gGUd9MApBSw5v5Gm921oWg0b4O9ZseWddi)SOb7DLyGCi45b9gvGS4Q1uT0G9Usmqoe88GEJAESGWAPwlnyVRedKdbppO3Oizz0ZJfewRPAfPu0z)usr)SBh1AQwrMdG8ZvKWiYyQZU(YGe9tfid0Uwt12QALYbKPhOcjnYpmqannhb3G1AQwrMdG8ZvCiyh1g5hgQazG2V7jrzLZ7NNf6m9abEe7zjc4HbKFwTQ2a0XEgnO6qsJm4H(Jddf6m9abQ1uTuwBRQnaDSNrdQMqd701Zldsf6m9abQLiIQLYALYbKPhOYiqdWXqJsZAPwRS1AQwAWExXHGDulS5ObvZJfewl1APb7Dfhc2rTWMJgurYYONhliSwkQLINfaofb04GP)SKygK8y0U2pSwdgg1AKhm9AbNyTFWZU2wQ1nVwAWRw4v7hCmQDWZR2r6n1IEc2yxBpJAPZZU2ZgRLGkB9AzhO2wQ1R9d6a53SwqFGZzTbO7qVP2ZgR1YQ2mQ9h5HAhyd6aCaX5ZIfhm9NLrEW0F3tIYsWVFEwOZ0de4rSNLiGhgq(zrd27Qa0rD21g5hgkG8ZRLiIQ1iqP6gbGswfhc2rnnhb3GplwCW0FwaiF20z447Esuw597NNf6m9abEe7zjc4HbKFw0G9UkaDuNDTr(HHci)8AjIOAncuQUraOKvXHGDutZrWn4ZIfhm9NvWaq2p90GdcF3tIYsGVFEwOZ0de4rSNLiGhgq(zrd27Qa0rD21g5hgQajzOpR93APSw5zTsOw5uBlV2a0XEgnOAcnStxpVmivOZ0deOwkEwS4GP)SiHrKXuND9Lbj637Esuw557NNf6m9abEe7zXIdM(ZIdb7O2i)W4zbGtranoy6pl5bB0RnaDh6n1E2yTYRYbz6TRDGnOdWrBZRfCI12sTET0ypdS2FYRfx7L1casAulxBhCmAx78ybHiqT0CWrd(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLgS3vbOJ6SRnYpmuGg1AQwkRLKDwziUA)TwkRvoeyTsOwkRvwjxBlVwrkfD2pfHTdi71srTuulrevlnyVRedKdbppO3OMhliSwQ1sd27kXa5qWZd6nkswg98ybH1sX7Esu2wZ7NNf6m9abEe7zjc4HbKFws5aY0duHKg5hgiGMMJGBWAnvlnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewRPAPb7Dfhc2rTr(HHc04zXIdM(ZIdb7OMMJGBW39KOSTG3ppl0z6bc8i2ZseWddi)SOb7Dva6Oo7AJ8ddfq(51ser1AeOuDJaqjRIdb7OMMJGBWAjIOAncuQUraOKvfmaK9tpn4GWAjIOAPSwJaLQBeakzvaiF20z4yTMQTv1gGo2ZObvtOHD665LbPcDMEGa1sXZIfhm9N1LGcBD21NnQj5g47Esu2w47NNf6m9abEe7zjc4HbKFwgbkv3iauYQUeuyRZU(Srnj3aFwS4GP)S4qWoQnYpmE3tIYrYVFEwOZ0de4rSNfloy6plJaNOlqD21Kqh4zbGtranoy6pl5XjwBRNT4AVS2zlcercAyTSxlkZfCTTuiyhRLydEE1cagqVP2ZgR9N8AXsQLA9A)Goq(vlOpW5S2a0DO3uBlfc2XALxe2PQ2wBV2wkeSJ1kViSZAHZApEG(HaMx7hwRG9)xTGtS2wpBX1(bpBOx7zJ1(tETyj1sTETFqhi)Qf0h4Cw7hwl0pmcqJR2ZgRTLAX1kSz3XH51oZA)W)JrTtwkwl8uplrapmG8ZQv1E8a9tXHGDuJc7uHotpqGAnvlasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)LATuwlloy6koeSJA6bppfkdkapuFqsS2wET0G9UYiWj6cuNDnj0buKSm65XccRLI39KOCK99ZZcDMEGapI9SyXbt)zze4eDbQZUMe6aplaCkcOXbt)z1A7126zlUwBE6)VAPr0RfCIa1cagqVP2ZgR9N8AX1(bDG8Z8A)W)JrTGtSw4v7L1oBrGisqdRL9ArzUGRTLcb7yTeBWZRwOx7zJ1sqLTUKAPwV2pOdKFQNLiGhgq(zrd27koeSJAJ8ddfOrTMQLgS3vbOJ6SRnYpmubsYqFw7VuRLYAzXbtxXHGDutp45Pqzqb4H6dsI12YRLgS3vgborxG6SRjHoGIKLrppwqyTu8UNeLJCE)8SqNPhiWJyplrapmG8ZcipvWaq2p90GdcvbsYqFwR8RLaRLiIQfaPb7DvWaq2p90Gdc1sbhogmnCaV2Q5XccRv(1k5Nfloy6ploeSJA6bpV39KOCi43ppl0z6bc8i2ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zjpG1(X(v7L1sYeI1obdS2pSwBwkwl6jyJDTKSZ12ZO2ZgRf9dgyTTuRx7h0bYpZRfLIETWETNng4)zTZdog1EqsS2ajzOd9MAtVwcQS1v12AV)ZAtF0UwA8omQ9YAPbdV2lRLGggzTSduR8I0SwyV2a0DO3u7zJ1AzvBg1(J8qTdSbDaoG4u9Seb8WaYplrMdG8ZvCiyh1g5hgQazG21AQws2zLH4Q93APSw5TKRvc1szTYk5AB51ksPOZ(PiSDazVwkQLIAnvlnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewRPAPS2wvBa6ypJgunHg2PRNxgKk0z6bculrevRuoGm9avgbAaogAuAwl1ALTwkQ1uTTQ2a0XEgnO6qsJm4H(Jddf6m9abQ1uTTQ2a0XEgnOIdb7O2MdY0BRqNPhiW7EsuoY73ppl0z6bc8i2ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zrmocUbRDANGdGA98QLgRfCIa1YxTNnwl6a1M9ABPwVwyVw5fPPGpy61cN1gid0UwEwlqKggqVPwHnhn4S2p4yuljtiwl8Q9ycXAhP3GrTxwlny41E2rc2yxBGKm0HEtTKSZplrapmG8ZIgS3vCiyh1g5hgkqJAnvlnyVR4qWoQnYpmubsYqFw7VuRTrauRPAfzoaYpxHstbFW0vbsYqF(UNeLdb((5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6plIXrWnyTt7eCaulp(42ZAPXApBS2bpVAf88Qf61E2yTeuzRx7h0bYVA5zT)KxlU2p4yuBGZldS2ZgRvyZrdoRDAG(9Seb8WaYplAWExfGoQZU2i)WqbAuRPAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOcKKH(S2FPwBJaOwt12QAdqh7z0GkoeSJABoitVTcDMEGaV7jr5ipF)8SqNPhiWJyplHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwD8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwIiQwwCqPOgDKeIZAPwRS1srTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkdkapuFqs8zXIdM(ZIdb7OMeoNWboF3tIYP18(5zHotpqGhXEwS4GP)S4qWoQjHZjCGZNfaofb04GP)SAT9A)W)bwRu0p72H51cjjraiF4ODTGtSwcGaQ9Zg9AfSHbcu7L165v7hppSwJifZA7rswBlo)5zjc4HbKFwIuk6SFkPOF2TJAnvlnyVRedKdbppO3OMhliSwQ1sd27kXa5qWZd6nkswg98ybHV7jr50cE)8SqNPhiWJyplaCkcOXbt)zzDCC1coHEtTeabuBl1IR9Zg9ABPwVwBEwlnIETGte4zjc4HbKFw0G9Usmqoe88GEJkqwC1AQwrMdG8ZvCiyh1g5hgQajzOpR1uTuwlnyVRcqh1zxBKFyOanQLiIQLgS3vCiyh1g5hgkqJAP4zjSzO)SK9zXIdM(ZIdb7OMeoNWboF3tIYPf((5zHotpqGhXEwIaEya5NfnyVR4qWoQf2C0GQ5XccR9xQ1kLditpq1LhPMKLrlS5ObNplwCW0FwCiyh1zq)UNejyj)(5zHotpqGhXEwIaEya5NfnyVRcqh1zxBKFyOanQLiIQLKDwziUALFTYsGplwCW0FwCiyh10dEEV7jrcw23ppl0z6bc8i2ZIfhm9Nfknf8bt)zb9dJa040W(ZIKDwzio5tTfqGplOFyeGgNgssIaq(WNLSplrapmG8ZIgS3vbOJ6SRnYpmua5NxRPAPb7Dfhc2rTr(HHci)839KiblN3pplwCW0FwCiyh10CeCd(SqNPhiWJyV7DpRip(GP)(5jrzF)8SqNPhiWJyplwCW0FwO0uWhm9Nfaofb04GP)SKhNyTO0SwyV2p8FG1oYVAtVws25AzhOwrMdG8ZN1YbwltNGxTxwlnwlOXZseWddi)SAvTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLKDwziUA)LATs5aY0duHstTH4Q1uTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1(l1AzXbtxHstbFW0vOmOa8q9bjXAjIOAfzoaYpxXHGDuBKFyOcKKH(S2FPwlloy6kuAk4dMUcLbfGhQpijwlrevlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9xQ1YIdMUcLMc(GPRqzqb4H6dsI1srTuuRPAPb7Dva6Oo7AJ8ddfq(51AQwAWExXHGDuBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubKFETMQTv1AeOuDJaqjR6sqHTo76Zg1KCd8DpjkN3ppl0z6bc8i2ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGAnvBRQvKsrN9tjf9ZUDuRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwlloy6kuAk4dMUcLbfGhQpij(SyXbt)zHstbFW0F3tIe87NNf6m9abEe7zjc4HbKFwbOJ9mAq1eAyNUEEzqQqNPhiqTMQvKsrN9tjf9ZUDuRPAfzoaYpxrcJiJPo76lds0pvGKm0N1(l1AzXbtxHstbFW0vOmOa8q9bjXAnvRiZbq(5Qlbf26SRpButYnqvGKm0N1(l1APSwPCaz6bQiZtBeOara9LhPMUDTsOwwCW0vO0uWhmDfkdkapuFqsSwjulbxlf1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1szTs5aY0durMN2iqbIa6lpsnD7ALqTS4GPRqPPGpy6kuguaEO(GKyTsOwcUwkEwS4GP)SqPPGpy6V7jr597NNf6m9abEe7zXIdM(ZIdb7OMMJGBWNfaofb04GP)Sighb3G1c71cV)ZApijw7L1coXAV8iRLDGA)WATzPyTxM1sYE7Af2C0GZNLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufid0Uwt1szT0G9UIdb7OwyZrdQMhliSw5xRuoGm9avxEKAswgTWMJgCwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwlkdkapuFqsSwt1sYoRmexTYVwPCaz6bQydnj0HKGKAs2zTH4Q1uT0G9UkaDuNDTr(HHci)8AP4DpjsGVFEwOZ0de4rSNLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufid0Uwt1szT0G9UIdb7OwyZrdQMhliSw5xRuoGm9avxEKAswgTWMJgCwRPApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1Arzqb4H6dsI1AQwPCaz6bQoijQb9do0SrTYVwPCaz6bQU8i1KSmAaCWT19m0SrTu8SyXbt)zXHGDutZrWn47EsuE((5zHotpqGhXEwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlL1sd27koeSJAHnhnOAESGWALFTs5aY0duD5rQjzz0cBoAWzTMQLYABvThpq)ubOJ6SRnYpmuOZ0deOwIiQwrMdG8ZvbOJ6SRnYpmubsYqFwR8RvkhqMEGQlpsnjlJgahCBDpdDKg1srTMQvkhqMEGQdsIAq)GdnBuR8RvkhqMEGQlpsnjlJgahCBDpdnBulfplwCW0FwCiyh10CeCd(UNeBnVFEwOZ0de4rSNLiGhgq(zbG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybH1sTwaKgS3vbdaz)0tdoiulfC4yW0Wb8ARizz0ZJfewRPAPSwAWExXHGDuBKFyOaYpVwIiQwAWExXHGDuBKFyOcKKH(S2FPwBJaOwkQ1uTuwlnyVRcqh1zxBKFyOaYpVwIiQwAWExfGoQZU2i)Wqfijd9zT)sT2gbqTu8SyXbt)zXHGDutZrWn47EsSf8(5zHotpqGhXEwIaEya5NLuoGm9avTSGZtdora90GdcRLiIQLYAbqAWExfmaK9tpn4GqTuWHJbtdhWRTc0Owt1cG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybH1(BTainyVRcgaY(PNgCqOwk4WXGPHd41wrYYONhliSwkEwS4GP)S4qWoQPh88E3tITW3ppl0z6bc8i2ZseWddi)SOb7DLrGt0fOo7AsOdOanQ1uTainyVRUeuyRZU(Srnj3avGg1AQwaKgS3vxckS1zxF2OMKBGQajzOpR9xQ1YIdMUIdb7OMEWZtHYGcWd1hKeFwS4GP)S4qWoQPh88E3tIYk53ppl0z6bc8i2ZsyZq)zj7Zc5y0wlSzORH9NfnyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GiIOSvhpq)uPummYpmqatusd27Qa0rD21g5hgkqdIisK5ai)Cfknf8btxfid0MckO4zjc4HbKFwainyVRUeuyRZU(Srnj3avGg1AQ2JhOFkoeSJAuyNk0z6bcuRPAPSwAWExbG8ztNHJkG8ZRLiIQLfhukQrhjH4SwQ1kBTuuRPAPSwaKgS3vxckS1zxF2OMKBGQajzOpRv(1YIdMUIdb7OMeoNWbovOmOa8q9bjXAjIOAfzoaYpxze4eDbQZUMe6aQajzOpRLiIQvKsrN9try7aYETu8SyXbt)zXHGDutcNt4aNV7jrzL99ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplaCkcOXbt)zraPpbjXApBSwugd2bqGAnYd9dYJAPb79A5jBu7L165v7iNyTg5H(b5rTgrkMplrapmG8ZIgS3vIbYHGNh0BubYIRwt1sd27kugd2bqaTrEOFqEOanE3tIYkN3ppl0z6bc8i2ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilUAnvlL1sd27koeSJAJ8ddfOrTeruT0G9UkaDuNDTr(HHc0OwIiQwaKgS3vxckS1zxF2OMKBGQajzOpRv(1YIdMUIdb7OMeoNWbovOmOa8q9bjXAP4Dpjklb)(5zHotpqGhXEwS4GP)S4qWoQjHZjCGZNLWMH(Zs2NLiGhgq(zrd27kXa5qWZd6nQazXvRPAPb7DLyGCi45b9g18ybH1sTwAWExjgihcEEqVrrYYONhli8DpjkR8(9ZZcDMEGapI9SaWPiGghm9Nvln(42ZAVODTxwln7ewlbqa12ZOwrMdG8ZR9d6a53SwAWRwaqsJApBKSwyV2ZgB)pWAz6e8Q9YArzmGb(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OcKKH(S2FPwlL1szT0G9Usmqoe88GEJAESGWAB51YIdMUIdb7OMeoNWbovOmOa8q9bjXAPOwjuBJaqrYYulfplHnd9NLSplwCW0FwCiyh1KW5eoW57Esuwc89ZZcDMEGapI9Seb8WaYplkRnWEGtBMEG1ser12QApOGqO3ulf1AQwAWExXHGDulS5ObvZJfewl1APb7Dfhc2rTWMJgurYYONhliSwt1sd27koeSJAJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkG8ZFwS4GP)SC8SXqFiPboV39KOSYZ3ppl0z6bc8i2ZseWddi)SOb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQU8i1KSmAHnhn48zXIdM(ZIdb7Ood639KOSTM3ppl0z6bc8i2ZseWddi)SKYbKPhOkbVjea1zxlYCaKF(Swt1sYoRmexT)sT2wib(SyXbt)znbnWWtP87Esu2wW7NNf6m9abEe7zjc4HbKFw0G9UkahOo76ZoqCQanQ1uT0G9UIdb7OwyZrdQMhliSw5xlb)SyXbt)zXHGDutp459UNeLTf((5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6pl51asAuRWMJgCwlSx7hwBNhJAPXr(v7zJ1ksFIHuSws25Ap7aN25aOw2bQfLMc(GPxlCw78GJrTPxRiZbq(5plrapmG8ZQv1gGo2ZObvtOHD665LbPcDMEGa1AQwPCaz6bQsWBcbqD21Imha5NpR1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwqyTMQ94b6NIdb7OodAf6m9abQ1uTImha5NR4qWoQZGwfijd9zT)sT2gbqTMQLKDwziUA)LATTqjxRPAfzoaYpxHstbFW0vbsYqF(UNeLJKF)8SqNPhiWJyplrapmG8ZkaDSNrdQMqd701Zldsf6m9abQ1uTs5aY0duLG3ecG6SRfzoaYpFwRPAPb7Dfhc2rTWMJgunpwqyTuRLgS3vCiyh1cBoAqfjlJEESGWAnv7Xd0pfhc2rDg0k0z6bcuRPAfzoaYpxXHGDuNbTkqsg6ZA)LATncGAnvlj7SYqC1(l1ABHsUwt1kYCaKFUcLMc(GPRcKKH(S2FRLGL8ZIfhm9Nfhc2rnnhb3GV7jr5i77NNf6m9abEe7zXIdM(ZIdb7OMMJGBWNfaofb04GP)SKxdiPrTcBoAWzTWETzqxlCwBGmq7NLiGhgq(zjLditpqvcEtiaQZUwK5ai)8zTMQLgS3vCiyh1cBoAq18ybH1sTwAWExXHGDulS5ObvKSm65XccR1uThpq)uCiyh1zqRqNPhiqTMQvK5ai)Cfhc2rDg0QajzOpR9xQ12iaQ1uTKSZkdXv7VuRTfk5AnvRiZbq(5kuAk4dMUkqsg6ZAnvlL12QAdqh7z0GQj0WoD98YGuHotpqGAjIOAPb7D1eAyNUEEzqQcKKH(S2FPwRSTGAP4Dpjkh58(5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6pRwkeSJ1smocUbRDANGdGABqhdEmAxlnw7zJ1o45vRGNxTzV2ZgRTLA9A)Goq(9Seb8WaYplAWExXHGDuBKFyOanQ1uT0G9UIdb7O2i)Wqfijd9zT)sT2gbqTMQLgS3vCiyh1cBoAq18ybH1sTwAWExXHGDulS5ObvKSm65XccR1uTuwRiZbq(5kuAk4dMUkqsg6ZAjIOAdqh7z0GkoeSJABoitVTcDMEGa1sX7Esuoe87NNf6m9abEe7zXIdM(ZIdb7OMMJGBWNfaofb04GP)SAPqWowlX4i4gS2PDcoaQTbDm4XODT0yTNnw7GNxTcEE1M9ApBSwcQS1R9d6a53ZseWddi)SOb7Dva6Oo7AJ8ddfOrTMQLgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHkqsg6ZA)LATncGAnvlnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewRPAPSwrMdG8ZvO0uWhmDvGKm0N1ser1gGo2ZObvCiyh12CqMEBf6m9abQLI39KOCK3VFEwOZ0de4rSNfloy6ploeSJAAocUbFwa4ueqJdM(ZQLcb7yTeJJGBWAN2j4aOwAS2ZgRDWZRwbpVAZETNnw7p51IR9d6a5xTWETWRw4SwpVAbNiqTFWZUwcQS1RnJABPw)zjc4HbKFw0G9UIdb7O2i)WqbKFETMQLgS3vbOJ6SRnYpmua5NxRPAbqAWExDjOWwND9zJAsUbQanQ1uTainyVRUeuyRZU(Srnj3avbsYqFw7VuRTrauRPAPb7Dfhc2rTWMJgunpwqyTuRLgS3vCiyh1cBoAqfjlJEESGW39KOCiW3ppl0z6bc8i2ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zjpyJETNnw7XrdE1cN1c9Arzqb4H1gS3G1YoqTNngyTWzTKzG1E2SxB6yTOJKTnVwWjwlnhb3G1YZANz61YZABNG1AZsXArpbBSRvyZrdoR9YATHxT8yul6ijeN1c71E2yTTuiyhRLyjjnhaKOF1oWg0b4ODTWzTylceAyGaplrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAPb7Dfhc2rTWMJgunpwqyTYNATuwlloOuuJoscXzTTm1kBTuuRPAzXbLIA0rsioRv(1kBTMQLgS3vaiF20z4Oci)839KOCKNVFEwOZ0de4rSNLiGhgq(zjLditpqfsAKFyGaAAocUbR1uT0G9UIdb7OwyZrdQMhliS2FRLgS3vCiyh1cBoAqfjlJEESGWAnvlloOuuJoscXzTYVwzR1uT0G9Uca5ZModhva5N)SyXbt)zXHGDuJYymYjm939KOCAnVFEwS4GP)S4qWoQPh88EwOZ0de4rS39KOCAbVFEwOZ0de4rSNLiGhgq(zjLditpqvcEtiaQZUwK5ai)85ZIfhm9Nfknf8bt)DpjkNw47NNfloy6ploeSJAAocUbFwOZ0de4rS39UNfN47NNeL99ZZcDMEGapI9Seb8WaYpRa0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQvK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG21AQwAWExbaNcOXa6C0wlsss2b09iNNci)8AnvlL1sd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8APOwt1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwkRLgS3vCiyh1cBoAq18ybH1(l1ALYbKPhOItuF5rQjzz0cBoAWzTMQLYAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sT2gbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwkRTv1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)ALYbKPhO6YJutYYObWb3w3ZqZg1srTeruTImha5NR4qWoQnYpmubsYqFw7VuRTraulf1sXZIfhm9NvpY5rNJ7DpjkN3ppl0z6bc8i2ZseWddi)SOS2a0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQvK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG21AQwAWExbaNcOXa6C0wlsss2b0DyGkG8ZR1uTgbkv3iauYQ6rop6CC1srTeruTuwBa6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1EqsSwQ1k5AP4zXIdM(ZQddutp459UNej43ppl0z6bc8i2ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8RLGLCTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uTuwlnyVR4qWoQf2C0GQ5XccR9xQ1kLditpqfNO(YJutYYOf2C0GZAnvlL1szThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZA)LATncGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)ALYbKPhO6YJutYYObWb3w3ZqZg1srTeruTuwBRQ94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpRv(1kLditpq1LhPMKLrdGdUTUNHMnQLIAjIOAfzoaYpxXHGDuBKFyOcKKH(S2FPwBJaOwkQLINfloy6pREKZt7Pu(DpjkVF)8SqNPhiWJyplrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRv(1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwqyTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfew7VuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(51sXZIfhm9NvpY5P9uk)UNejW3ppl0z6bc8i2ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplrkfD2pfHTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh12CqMEB18ybH1(BTYsG1AQwrMdG8Zvbdaz)0tdoiufijd9zT)sTwPCaz6bQS5Gm9265Xcc1hKeRvc1IYGcWd1hKeR1uTImha5NRUeuyRZU(Srnj3avbsYqFw7VuRvkhqMEGkBoitVTEESGq9bjXALqTOmOa8q9bjXALqTS4GPRcgaY(PNgCqOcLbfGhQpijwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwRuoGm9av2CqMEB98ybH6dsI1kHArzqb4H6dsI1kHAzXbtxfmaK9tpn4GqfkdkapuFqsSwjulloy6Qlbf26SRpButYnqfkdkapuFqs8DpjkpF)8SqNPhiWJyplrapmG8ZsKsrN9tjf9ZUDuRPApEG(P4qWoQrHDQqNPhiqTMQ9GKyT)wRSsUwt1kYCaKFUIegrgtD21xgKOFQajzOpR1uT0G9Usmqoe88GEJAESGWA)Twc(zXIdM(ZIdb7OMEWZ7Dpj2AE)8SqNPhiWJyplrapmG8ZkaDSNrdQMqd701Zldsf6m9abQ1uTgbkv3iauYQqPPGpy6plwCW0FwxckS1zxF2OMKBGV7jXwW7NNf6m9abEe7zjc4HbKFwbOJ9mAq1eAyNUEEzqQqNPhiqTMQLYAncuQUraOKvHstbFW0RLiIQ1iqP6gbGsw1LGcBD21NnQj5gyTu8SyXbt)zXHGDuBKFy8UNeBHVFEwOZ0de4rSNLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)sT2wqTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZA)LATTGAnvlL1sd27koeSJAHnhnOAESGWA)LATs5aY0duXjQV8i1KSmAHnhn4Swt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2FPwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwcSwkQLiIQLYABvThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwcSwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATncGAPOwkEwS4GP)SiHrKXuND9Lbj637Esuwj)(5zHotpqGhXEwIaEya5N1bjXALFTeSKR1uTbOJ9mAq1eAyNUEEzqQqNPhiqTMQvKsrN9tjf9ZUDuRPAncuQUraOKvrcJiJPo76lds0VNfloy6pluAk4dM(7EsuwzF)8SqNPhiWJyplrapmG8Z6GKyTYVwcwY1AQ2a0XEgnOAcnStxpVmivOZ0deOwt1sd27koeSJAHnhnOAESGWA)LATs5aY0duXjQV8i1KSmAHnhn4Swt1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12iaEwS4GP)SqPPGpy6V7jrzLZ7NNf6m9abEe7zXIdM(ZcLMc(GP)SG(HraACAy)zrd27Qj0WoD98YGunpwqivAWExnHg2PRNxgKkswg98ybHplOFyeGgNgssIaq(WNLSplrapmG8Z6GKyTYVwcwY1AQ2a0XEgnOAcnStxpVmivOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRv(1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwqyTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfew7VuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(51sX7Esuwc(9ZZcDMEGapI9Seb8WaYplrMdG8ZvxckS1zxF2OMKBGQajzOpR93Arzqb4H6dsI1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpRv(1kLditpq1LhPMKLrdGdUTUNHMnQLIAjIOAPS2wv7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8RvkhqMEGQlpsnjlJgahCBDpdnBulf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTu8SyXbt)zfmaK9tpn4GW39KOSY73ppl0z6bc8i2ZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2FRfLbfGhQpijwRPAPSwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5xRuoGm9avSHMKLrdGdUTUNH(YJSwt1sd27koeSJAHnhnOAESGWAPwlnyVR4qWoQf2C0Gkswg98ybH1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQ4e1xEKAswgTWMJgCwlf1srTMQLgS3vbOJ6SRnYpmua5NxlfplwCW0Fwbdaz)0tdoi8Dpjklb((5zHotpqGhXEwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1sTwjxRPAPSwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5xRuoGm9avSHMKLrdGdUTUNH(YJSwt1sd27koeSJAHnhnOAESGWAPwlnyVR4qWoQf2C0Gkswg98ybH1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQ4e1xEKAswgTWMJgCwlf1srTMQLgS3vbOJ6SRnYpmua5NxlfplwCW0FwaiF20z447Esuw557NNf6m9abEe7zjc4HbKFwuwlnyVR4qWoQf2C0GQ5XccR9xQ1kLditpqfNO(YJutYYOf2C0GZAjIOAncuQUraOKvfmaK9tpn4GWAPOwt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2FPwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwPCaz6bQU8i1KSmAaCWT19m0SrTuulrevlL12QApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12iaQLINfloy6pRlbf26SRpButYnW39KOSTM3ppl0z6bc8i2ZseWddi)SOSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZALFTs5aY0duXgAswgnao426Eg6lpYAnvlnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewlf1ser1szTImha5NRUeuyRZU(Srnj3avbsYqFwl1ALCTMQLgS3vCiyh1cBoAq18ybH1(l1ALYbKPhOItuF5rQjzz0cBoAWzTuulf1AQwAWExfGoQZU2i)WqbKF(ZIfhm9Nfhc2rTr(HX7Esu2wW7NNf6m9abEe7zjc4HbKFw0G9UkaDuNDTr(HHci)8AnvlL1szTImha5NRUeuyRZU(Srnj3avbsYqFwR8RvosUwt1sd27koeSJAHnhnOAESGWAPwlnyVR4qWoQf2C0Gkswg98ybH1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQ4e1xEKAswgTWMJgCwlf1srTMQLYAfzoaYpxXHGDuBKFyOcKKH(Sw5xRSYPwIiQwaKgS3vxckS1zxF2OMKBGkqJAP4zXIdM(ZkaDuNDTr(HX7Esu2w47NNf6m9abEe7zjc4HbKFwImha5NR4qWoQZGwfijd9zTYVwcSwIiQ2wv7Xd0pfhc2rDg0k0z6bc8SyXbt)znTH9d6nAJ8dJ39KOCK87NNf6m9abEe7zjc4HbKFwIuk6SFkcBhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwaKgS3vbdaz)0tdoiulfC4yW0Wb8ARMhliSwQ1kVR1uTgbkv3iauYQ4qWoQZGUwt1YIdkf1OJKqCw7V12AEwS4GP)S4qWoQPh88E3tIYr23ppl0z6bc8i2ZseWddi)SePu0z)ue2oGSxRPAdqh7z0GkoeSJABoitVTcDMEGa1AQwAWExXHGDuBKFyOanQ1uTainyVRcgaY(PNgCqOwk4WXGPHd41wnpwqyTuRvE)SyXbt)zXHGDutZrWn47EsuoY59ZZcDMEGapI9Seb8WaYplrkfD2pfHTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh1g5hgkqJAnvlL1cKNkyai7NEAWbHQajzOpRv(1kpRLiIQfaPb7DvWaq2p90Gdc1sbhogmnCaV2kqJAPOwt1cG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybH1(BTY7AnvlloOuuJoscXzTuRLGFwS4GP)S4qWoQPh88E3tIYHGF)8SqNPhiWJyplrapmG8ZsKsrN9try7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bcuRPAPb7Dfhc2rTr(HHc0Owt1cG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybH1sTwc(zXIdM(ZIdb7Ood639KOCK3VFEwOZ0de4rSNLiGhgq(zjsPOZ(PiSDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn4GqTuWHJbtdhWRTAESGWAPwRCEwS4GP)S4qWoQP5i4g8Dpjkhc89ZZcDMEGapI9Seb8WaYplrkfD2pfHTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh1g5hgkqJAnvRrGs1ncaLCubdaz)0tdoiSwt1YIdkf1OJKqCwR8RLGFwS4GP)S4qWoQrzmg5eM(7EsuoYZ3ppl0z6bc8i2ZseWddi)SePu0z)ue2oGSxRPAdqh7z0GkoeSJABoitVTcDMEGa1AQwAWExXHGDuBKFyOanQ1uTainyVRcgaY(PNgCqOwk4WXGPHd41wnpwqyTuRv2AnvlloOuuJoscXzTYVwc(zXIdM(ZIdb7OgLXyKty6V7jr50AE)8SqNPhiWJyplrapmG8ZIgS3vaiF20z4Oc0Owt1cG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2FPwlnyVRmcCIUa1zxtcDafjlJEESGWAB51YIdMUIdb7OMEWZtHYGcWd1hKeR1uTuwlL1E8a9tf4mD2fOcDMEGa1AQwwCqPOgDKeIZA)Tw5DTuulrevlloOuuJoscXzT)wlbwlf1AQwkRTv1gGo2ZObvCiyh10jjnhaKOFk0z6bculrev7XrdEkBKhNTYqC1k)AjycSwkEwS4GP)SmcCIUa1zxtcDG39KOCAbVFEwOZ0de4rSNLiGhgq(zrd27kaKpB6mCubAuRPAPSwkR94b6NkWz6Slqf6m9abQ1uTS4Gsrn6ijeN1(BTY7APOwIiQwwCqPOgDKeIZA)TwcSwkQ1uTuwBRQnaDSNrdQ4qWoQPtsAoair)uOZ0deOwIiQ2JJg8u2ipoBLH4Qv(1sWeyTu8SyXbt)zXHGDutp459UNeLtl89ZZIfhm9N1e0adpLYpl0z6bc8i27EsKGL87NNf6m9abEe7zjc4HbKFw0G9UIdb7OwyZrdQMhliSw5tTwkRLfhukQrhjH4S2wMALTwkQ1uTbOJ9mAqfhc2rnDssZbaj6NcDMEGa1AQ2JJg8u2ipoBLH4Q93Ajyc8zXIdM(ZIdb7OMMJGBW39Kibl77NNf6m9abEe7zjc4HbKFw0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwq4ZIfhm9Nfhc2rnnhb3GV7jrcwoVFEwOZ0de4rSNLiGhgq(zrd27koeSJAHnhnOAESGWAPwRKR1uTuwRiZbq(5koeSJAJ8ddvGKm0N1k)ALLaRLiIQTv1szTIuk6SFkcBhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAPOwkEwS4GP)S4qWoQZG(DpjsWe87NNf6m9abEe7zjc4HbKFwuwBG9aN2m9aRLiIQTv1EqbHqVPwkQ1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwq4ZIfhm9NLJNng6djnW59UNejy597NNf6m9abEe7zjc4HbKFw0G9Usmqoe88GEJkqwC1AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLYAPS2JhOFkM0ya7qbFW0vOZ0deOwt1YIdkf1OJKqCw7V12cQLIAjIOAzXbLIA0rsioR93AjWAP4zXIdM(ZIdb7OMeoNWboF3tIemb((5zHotpqGhXEwIaEya5NfnyVRedKdbppO3OcKfxTMQ94b6NIdb7Ogf2PcDMEGa1AQwaKgS3vxckS1zxF2OMKBGkqJAnvlL1E8a9tXKgdyhk4dMUcDMEGa1ser1YIdkf1OJKqCw7V12cRLINfloy6ploeSJAs4Cch48DpjsWYZ3ppl0z6bc8i2ZseWddi)SOb7DLyGCi45b9gvGS4Q1uThpq)umPXa2Hc(GPRqNPhiqTMQLfhukQrhjH4S2FRvE)SyXbt)zXHGDutcNt4aNV7jrcU18(5zHotpqGhXEwIaEya5NfnyVR4qWoQf2C0GQ5XccR93APb7Dfhc2rTWMJgurYYONhli8zXIdM(ZIdb7OgLXyKty6V7jrcUf8(5zHotpqGhXEwIaEya5NfnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewRPAncuQUraOKvXHGDutZrWn4ZIfhm9Nfhc2rnkJXiNW0F3tIeCl89ZZc6hgbOXPH9Nfj7SYqCYNAlGaFwq)WianonKKebG8HplzFwS4GP)SqPPGpy6pl0z6bc8i27E3Zca7m44E)8KOSVFEwS4GP)SejOFymnWX4zHotpqGhXE3tIY59ZZcDMEGapI9Seb8WaYplkR94b6Nc9bSX(qhbuOZ0deOwt1sYoRmexT)sT2wGKR1uTKSZkdXvR8PwR8KaRLIAjIOAPS2wv7Xd0pf6dyJ9HocOqNPhiqTMQLKDwziUA)LATTacSwkEwS4GP)SizN1ni57EsKGF)8SqNPhiWJyplrapmG8ZIgS3vCiyh1g5hgkqJNfloy6plJ8GP)UNeL3VFEwOZ0de4rSNLiGhgq(zfGo2ZObvhsAKbp0FCyOqNPhiqTMQLgS3vOm2m48GPRanQ1uTuwRiZbq(5koeSJAJ8ddvGmq7AjIOAPZ5Swt12Hn2Noqsg6ZA)LATYBjxlfplwCW0FwhKe1FCy8UNejW3ppl0z6bc8i2ZseWddi)SOb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubKF(ZIfhm9N1a2yFtDlliqdj637EsuE((5zHotpqGhXEwIaEya5NfnyVR4qWoQnYpmua5NxRPAPb7Dva6Oo7AJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkG8ZFwS4GP)SO5gD21xafeoF3tITM3ppl0z6bc8i2ZseWddi)SOb7Dfhc2rTr(HHc04zXIdM(ZIgJjgec9M39Kyl49ZZcDMEGapI9Seb8WaYplAWExXHGDuBKFyOanEwS4GP)SOhzcO7Gr739Kyl89ZZcDMEGapI9Seb8WaYplAWExXHGDuBKFyOanEwS4GP)S6WaPhzc8UNeLvYVFEwOZ0de4rSNLiGhgq(zrd27koeSJAJ8ddfOXZIfhm9Nf7cCEbp0cEmE3tIYk77NNf6m9abEe7zjc4HbKFw0G9UIdb7O2i)WqbA8SyXbt)zborn8qY57Esuw58(5zHotpqGhXEwS4GP)SAgmaKVmMAAgObFwIaEya5NfnyVR4qWoQnYpmuGg1ser1kYCaKFUIdb7O2i)Wqfijd9zTYNATeibwRPAbqAWExDjOWwND9zJAsUbQanEwyVJIt7mj(SAgmaKVmMAAgObF3tIYsWVFEwOZ0de4rSNfloy6plK0ODG8qNbGZUaFwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1(l1ALLaR1uTImha5NRUeuyRZU(Srnj3avbsYqFw7VuRvwc8z5mj(SqsJ2bYdDgao7c8DpjkR8(9ZZcDMEGapI9SyXbt)zbeid0HbQLIZjoEwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1kFQ1khjxlrevBRQvkhqMEGk2qNUgCI1sTwzRLiIQLYApijwl1ALCTMQvkhqMEGQoCAd9gDAGog1sTwzR1uTbOJ9mAq1eAyNUEEzqQqNPhiqTu8SCMeFwabYaDyGAP4CIJ39KOSe47NNf6m9abEe7zXIdM(ZAMGdnSXHhgplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZALp1AjyjxlrevBRQvkhqMEGk2qNUgCI1sTwzFwotIpRzco0WghEy8UNeLvE((5zHotpqGhXEwS4GP)SAgTnS1zxZZjKeo4dM(ZseWddi)SezoaYpxXHGDuBKFyOcKKH(Sw5tTw5i5AjIOABvTs5aY0duXg601GtSwQ1kBTeruTuw7bjXAPwRKR1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQnaDSNrdQMqd701Zldsf6m9abQLINLZK4ZQz02WwNDnpNqs4Gpy6V7jrzBnVFEwOZ0de4rSNfloy6plswW0bQN2iEAsWju8Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR9xQ1sG1AQwkRTv1kLditpqvhoTHEJonqhJAPwRS1ser1EqsSw5xlbl5AP4z5mj(SizbthOEAJ4PjbNqX7Esu2wW7NNf6m9abEe7zXIdM(ZIKfmDG6PnINMeCcfplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)LATeyTMQvkhqMEGQoCAd9gDAGog1sTwzR1uT0G9UkaDuNDTr(HHc0Owt1sd27Qa0rD21g5hgQajzOpR9xQ1szTYk5ABzQLaRTLxBa6ypJgunHg2PRNxgKk0z6bculf1AQ2dsI1(BTeSKFwotIplswW0bQN2iEAsWju8UNeLTf((5zHotpqGhXEwS4GP)SM2mq(Ha6mO1zxFzqI(9Seb8WaYpRdsI1sTwjxlrevlL1kLditpqvcEtiaQZUwK5ai)8zTMQLYAPSwrkfD2pfHTdi71AQwrMdG8Zvbdaz)0tdoiufijd9zT)sTw5uRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwlbwRPAfzoaYpxDjOWwND9zJAsUbQcKKH(S2FPwlbwlf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sTw5ulrevBh2yF6ajzOpR93AfzoaYpxXHGDuBKFyOcKKH(SwkQLINLZK4ZAAZa5hcOZGwND9Lbj637Esuos(9ZZcDMEGapI9SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zj4HaCWhm957EsuoY((5zHotpqGhXEwIaEya5NfloOuuJoscXzTYNATs5aY0duXjQpoAWtlsq)EwZlGI7jrzFwS4GP)Se8yOzXbtxpGZ7znGZt7mj(S4eF3tIYroVFEwOZ0de4rSNLiGhgq(zjsPOZ(PiSDazVwt1gGo2ZObvCiyh12CqMEBf6m9abEwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SS5Gm92V7jr5qWVFEwOZ0de4rSNLiGhgq(zjLditpqLnlf1Pb6iqTuRvY1AQwPCaz6bQ6WPn0B0Pb6yuRPABvTuwRiLIo7NIW2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwkEwS4GP)Se8yOzXbtxpGZ7znGZt7mj(S6WPn0B0Pb6y8UNeLJ8(9ZZcDMEGapI9Seb8WaYplPCaz6bQSzPOonqhbQLATsUwt12QAPSwrkfD2pfHTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zLgOJX7Esuoe47NNf6m9abEe7zjc4HbKFwTQwkRvKsrN9try7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bculfplwCW0FwcEm0S4GPRhW59SgW5PDMeFwImha5NpF3tIYrE((5zHotpqGhXEwIaEya5NLuoGm9avDOZdnny41sTwjxRPABvTuwRiLIo7NIW2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwkEwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SI84dM(7EsuoTM3ppl0z6bc8i2ZseWddi)SKYbKPhOQdDEOPbdVwQ1kBTMQTv1szTIuk6SFkcBhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAP4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZQdDEOPbd)DV7zzeOijP579ZtIY((5zXIdM(ZIdb7Og6hogO4EwOZ0de4rS39KOCE)8SyXbt)znbjjtxZHGDu3zs4aYXZcDMEGapI9UNej43pplwCW0FwI0BzbdutYoRBqYNf6m9abEe7DpjkVF)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXjQpoAWtlsq)EwayNbh3ZIGF3tIe47NNf6m9abEe7zLgpRaN49SyXbt)zjLditpWNLuo0otIpluAQne3Zca7m44EwYsGV7jr557NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLdTZK4ZYiqdWXqJsZNLiGhgq(zrzTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLYAfPu0z)usr)SBh1ser1ksPOZ(PCue5idGAjIOAfPdacpfhc2rTrKaWM2k0z6bculf1sXZskparnoM4ZsYplP8aeFwY(UNeBnVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuo0otIplBwkQtd0rGNLiGhgq(zXIdkf1OJKqCwR8PwRuoGm9avCI6JJg80Ie0VNLuEaIACmXNLKFws5bi(SK9Dpj2cE)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFws(zjLdTZK4ZQdDEOPbd)Dpj2cF)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zzZbz6T1ZJfeQpij(SaWodoUNvl8DpjkRKF)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXJpU9upB7cTiZbq(5ZNfa2zWX9SK87EsuwzF)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zftnjlJgahCBDpd9Lh5Zca7m44Ewe47Esuw58(5zHotpqGhXEwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZkMAswgnao426Eg6inEwayNbh3ZIaF3tIYsWVFEwOZ0de4rSNvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SIPMKLrdGdUTUNHMnEwayNbh3Zsos(DpjkR8(9ZZcDMEGapI9SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfzEAJaficOV8i10TFwayNbh3ZQf8UNeLLaF)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zrMNMKLrdGdUTUNH(YJ8zbGDgCCplzL87Esuw557NNf6m9abEe7zLgpRaN49SyXbt)zjLditpWNLuo0otIplY80KSmAaCWT19m0SXZca7m44EwYsGV7jrzBnVFEwOZ0de4rSNvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SydnjlJgahCBDpd9Lh5ZseWddi)SePdacpfhc2rTrKaWM2plP8ae14yIplzL8ZskpaXNfbl539KOSTG3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwSHMKLrdGdUTUNH(YJ8zbGDgCCpl5i539KOSTW3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwSHMKLrdGdUTUNHMmVNfa2zWX9SKJKF3tIYrYVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIpl5i5ABzQLYAjWAB51kshaeEkoeSJAJibGnTvOZ0deOwkEws5q7mj(SI0qtYYObWb3w3ZqF5r(UNeLJSVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIplcSwjuRCKCTT8APSwrkfD2pLdBSpDNXAjIOAPSwr6aGWtXHGDuBejaSPTcDMEGa1AQwwCqPOgDKeIZA)TwPCaz6bQ4e1hhn4PfjOF1srTuuReQvwcS2wETuwRiLIo7NIW2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1YIdkf1OJKqCwR8PwRuoGm9avCI6JJg80Ie0VAP4zjLdTZK4Z6YJutYYObWb3w3ZqZgV7jr5iN3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLCKCTTm1szTTGAB51kshaeEkoeSJAJibGnTvOZ0deOwkEws5q7mj(SU8i1KSmAaCWT19m0rA8UNeLdb)(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKNsU2wMAPSwsEEy0wlLhGyTT8ALvYsUwkEwIaEya5NLiLIo7NYHn2NUZ4ZskhANjXNfnhb3GAs2zTH4E3tIYrE)(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SAHeyTTm1szTK88WOTwkpaXAB51kRKLCTu8Seb8WaYplrkfD2pfHTdi7plPCODMeFw0CeCdQjzN1gI7Dpjkhc89ZZcDMEGapI9SsJN1eVNfloy6plPCaz6b(SKYdq8z1cKCTTm1szTK88WOTwkpaXAB51kRKLCTu8Seb8WaYplPCaz6bQO5i4gutYoRnexTuRvYplPCODMeFw0CeCdQjzN1gI7Dpjkh557NNf6m9abEe7zLgpRaN49SyXbt)zjLditpWNLuo0otIpl2qtcDijiPMKDwBiUNfa2zWX9SKLaF3tIYP18(5zHotpqGhXEwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4Z6YJutYYOf2C0GZNfa2zWX9SKZ7EsuoTG3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwCI6lpsnjlJwyZrdoFwayNbh3ZsoV7jr50cF)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFwYwBlVwkRfBrGqddeqHKgTdKh6maC2fyTeruTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTuw7Xd0pfhc2rnkStf6m9abQLiIQTv1ksPOZ(PiSDazVwkQ1uTuwBRQvKsrN9t5OiYrga1ser1YIdkf1OJKqCwl1ALTwIiQ2a0XEgnOAcnStxpVmivOZ0deOwkQ1uTTQwrkfD2pLu0p72rTuulfplPCODMeFwD40g6n60aDmE3tIeSKF)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFwylceAyGakswW0bQN2iEAsWjuulrevl2IaHggiGQzWaq(YyQPzGgSwIiQwSfbcnmqavZGbG8LXutIa8yatVwIiQwSfbcnmqafahesMPRbqbHAdWlWPaDbwlrevl2IaHggiGc6traEm9a1Tiq2pqsnakfkWAjIOAXwei0WabuZeCmW7GEJoaPBxlrevl2IaHggiGAc60Jmb0mjE2TNxTeruTylceAyGaQpMq0XyQ7r6a1ser1ITiqOHbcO6dMe1zxtZ3nWNLuo0otIpl2qNUgCIV7jrcw23pplwCW0FwKWiYqdj5g8zHotpqGhXE3tIeSCE)8SqNPhiWJyplrapmG8ZAMGdAOdOKMd(GdupZHu0pf6m9abQLiIQDMGdAOdOmaNh4a1yaACW0vOZ0de4zXIdM(ZQpWPTi4(9UNejyc(9ZZcDMEGapI9Seb8WaYplrkfD2pfHTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQvKoai8uCiyh1grcaBARqNPhiqTMQvkhqMEGkE8XTN6zBxOfzoaYpFwRPAzXbLIA0rsioR93ALYbKPhOItuFC0GNwKG(9SyXbt)zfGoQZU2i)W4DpjsWY73ppl0z6bc8i2ZseWddi)SAvTs5aY0duzeOb4yOrPzTuRv2AnvBa6ypJgubaNcOXa6C0wlsss2buOZ0de4zXIdM(ZQh58OZX9UNejyc89ZZcDMEGapI9Seb8WaYpRwvRuoGm9avgbAaogAuAwl1ALTwt12QAdqh7z0Gka4uangqNJ2ArssYoGcDMEGa1AQwkRTv1ksPOZ(PKI(z3oQLiIQvkhqMEGQoCAd9gDAGog1sXZIfhm9Nfhc2rn9GN37EsKGLNVFEwOZ0de4rSNLiGhgq(z1QALYbKPhOYiqdWXqJsZAPwRS1AQ2wvBa6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1ksPOZ(PKI(z3oQ1uTTQwPCaz6bQ6WPn0B0Pb6y8SyXbt)zrcJiJPo76lds0V39Kib3AE)8SqNPhiWJyplrapmG8ZskhqMEGkJanahdnknRLATY(SyXbt)zHstbFW0F37EwImha5NpF)8KOSVFEwOZ0de4rSNfloy6pREKZt7Pu(zbGtranoy6pRwpGzapibnSwWj0BQTjGZr7AHcOyG1(bp7AzdvTYJtSw4v7h8SR9YJS28SX4dor1ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8RLGLCTMQvK5ai)C1LGcBD21NnQj5gOkqgODTMQLYAPb7Dfhc2rTWMJgunpwqyT)sTwPCaz6bQU8i1KSmAHnhn4Swt1szTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2FPwBJaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwPCaz6bQU8i1KSmAaCWT19m0SrTuulrevlL12QApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4GBR7zOzJAPOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12iaQLIAP4DpjkN3ppl0z6bc8i2ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTImha5NR4qWoQnYpmubYaTR1uTuwBRQ94b6Nc9bSX(qhbuOZ0deOwIiQwkR94b6Nc9bSX(qhbuOZ0deOwt1sYoRmexTYNATTgjxlf1srTMQLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRv(1kRKR1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwqyTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfewl1ALCTuulf1AQwAWExfGoQZU2i)WqbKFETMQLKDwziUALp1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(ZQh580EkLF3tIe87NNf6m9abEe7zjc4HbKFwbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnvRiZbq(5kAWExdaNcOXa6C0wlsss2bubYaTR1uT0G9UcaofqJb05OTwKKKSdO7ropfq(51AQwkRLgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHci)8Anvlasd27Qlbf26SRpButYnqfq(51srTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uTuwlnyVR4qWoQf2C0GQ5XccR9xQ1kLditpq1LhPMKLrlS5ObN1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpRv(1kLditpq1LhPMKLrdGdUTUNHMnQLIAjIOAPS2wv7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8RvkhqMEGQlpsnjlJgahCBDpdnBulf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTuulfplwCW0Fw9iNhDoU39KO8(9ZZcDMEGapI9Seb8WaYpRa0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQvK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG21AQwAWExbaNcOXa6C0wlsss2b0DyGkG8ZR1uTgbkv3iauYQ6rop6CCplwCW0FwDyGA6bpV39Kib((5zHotpqGhXEwS4GP)SiHrKXuND9Lbj63ZcaNIaACW0FwTodJABX5p1(bp7ABPwVwyVw49FwRijHEtTGg1oZ0v12A71cVA)GJrT0yTGteO2p4zx7p51InVwbpVAHxTZbSX(gTRLg7zGplrapmG8ZIYABvTbOJ9mAq1eAyNUEEzqQqNPhiqTeruT0G9UAcnStxpVmivGg1srTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZA)TwPCaz6bQiZtBeOara9LhPMUDTeruTuwRuoGm9avhKe1G(bhA2Ow5xRuoGm9avK5Pjzz0a4GBR7zOzJAnvRiZbq(5Qlbf26SRpButYnqvGKm0N1k)ALYbKPhOImpnjlJgahCBDpd9LhzTu8UNeLNVFEwOZ0de4rSNLiGhgq(zjYCaKFUIdb7O2i)Wqfid0Uwt1szTTQ2JhOFk0hWg7dDeqHotpqGAjIOAPS2JhOFk0hWg7dDeqHotpqGAnvlj7SYqC1kFQ12AKCTuulf1AQwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(Sw5xRuoGm9avSHMKLrdGdUTUNH(YJSwt1sd27koeSJAHnhnOAESGWAPwlnyVR4qWoQf2C0Gkswg98ybH1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPb7Dfhc2rTWMJgunpwqyTuRvY1srTuuRPAPb7Dva6Oo7AJ8ddfq(51AQws2zLH4Qv(uRvkhqMEGk2qtcDijiPMKDwBiUNfloy6plsyezm1zxFzqI(9UNeBnVFEwOZ0de4rSNLiGhgq(zjLditpqvcEtiaQZUwK5ai)8zTMQLYANj4Gg6akP5Gp4a1ZCif9tHotpqGAjIOANj4Gg6akdW5boqngGghmDf6m9abQLINfloy6pR(aN2IG737EsSf8(5zHotpqGhXEwS4GP)Saq(SPZWXNfaofb04GP)SAPXh3Ewl4eRfa5ZModhR9dE21YgQABT9AV8iRfoRnqgODT8S2pCmmVwsMqS2jyG1EzTcEE1cVAPXEgyTxEKQNLiGhgq(zjYCaKFU6sqHTo76Zg1KCdufid0Uwt1sd27koeSJAHnhnOAESGWA)LATs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATncG39Kyl89ZZcDMEGapI9Seb8WaYplrMdG8ZvCiyh1g5hgQazG21AQwkRTv1E8a9tH(a2yFOJak0z6bculrevlL1E8a9tH(a2yFOJak0z6bcuRPAjzNvgIRw5tT2wJKRLIAPOwt1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1k)ALvY1AQwAWExXHGDulS5ObvZJfewl1APb7Dfhc2rTWMJgurYYONhliSwkQLiIQLYAfzoaYpxDjOWwND9zJAsUbQcKbAxRPAPb7Dfhc2rTWMJgunpwqyTuRvY1srTuuRPAPb7Dva6Oo7AJ8ddfq(51AQws2zLH4Qv(uRvkhqMEGk2qtcDijiPMKDwBiUNfloy6plaKpB6mC8DpjkRKF)8SqNPhiWJyplwCW0Fwbdaz)0tdoi8zbGtranoy6pl5Xjw70GdcRf2R9YJSw2bQLnQLdS20Rvaul7a1(L()RwASwqJA7zu7i9gmQ9SzV2ZgRLKLPwaCWTnVwsMqO3u7emWA)WATzPyT8v7a55v79L1YHGDSwHnhn4Sw2bQ9S5R2lpYA)4P))QTLfCE1cora1ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKKH(Sw5xRuoGm9avXutYYObWb3w3ZqF5rwRPAfzoaYpxXHGDuBKFyOcKKH(Sw5xRuoGm9avXutYYObWb3w3ZqZg1AQwkR94b6NkaDuNDTr(HHcDMEGa1AQwkRvK5ai)Cva6Oo7AJ8ddvGKm0N1(BTOmOa8q9bjXAjIOAfzoaYpxfGoQZU2i)Wqfijd9zTYVwPCaz6bQIPMKLrdGdUTUNHosJAPOwIiQ2wv7Xd0pva6Oo7AJ8ddf6m9abQLIAnvlnyVR4qWoQf2C0GQ5XccRv(1kNAnvlasd27Qlbf26SRpButYnqfq(51AQwAWExfGoQZU2i)WqbKFETMQLgS3vCiyh1g5hgkG8ZF3tIYk77NNf6m9abEe7zXIdM(Zkyai7NEAWbHplaCkcOXbt)zjpoXANgCqyTFWZUw2O2pB0R1iNti9av12A71E5rwlCwBGmq7A5zTF4yyETKmHyTtWaR9YAf88QfE1sJ9mWAV8ivplrapmG8ZsK5ai)C1LGcBD21NnQj5gOkqsg6ZA)TwuguaEO(GKyTMQLgS3vCiyh1cBoAq18ybH1(l1ALYbKPhO6YJutYYOf2C0GZAnvRiZbq(5koeSJAJ8ddvGKm0N1(BTuwlkdkapuFqsSwjulloy6Qlbf26SRpButYnqfkdkapuFqsSwkE3tIYkN3ppl0z6bc8i2ZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2FRfLbfGhQpijwRPAPSwkRTv1E8a9tH(a2yFOJak0z6bculrevlL1E8a9tH(a2yFOJak0z6bcuRPAjzNvgIRw5tT2wJKRLIAPOwt1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1k)ALYbKPhOIn0KSmAaCWT19m0xEK1AQwAWExXHGDulS5ObvZJfewl1APb7Dfhc2rTWMJgurYYONhliSwkQLiIQLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlnyVR4qWoQf2C0GQ5XccRLATsUwkQLIAnvlnyVRcqh1zxBKFyOaYpVwt1sYoRmexTYNATs5aY0duXgAsOdjbj1KSZAdXvlfplwCW0Fwbdaz)0tdoi8Dpjklb)(5zHotpqGhXEwS4GP)SUeuyRZU(Srnj3aFwa4ueqJdM(ZsECI1E5rw7h8SRLnQf2RfE)N1(bpBOx7zJ1sYYulao42QABT9A98mVwWjw7h8SRnsJAH9ApBS2JhOF1cN1EmHOBETSdul8(pR9dE2qV2ZgRLKLPwaCWTvplrapmG8ZIYABvTbOJ9mAq1eAyNUEEzqQqNPhiqTeruT0G9UAcnStxpVmivGg1srTMQLgS3vCiyh1cBoAq18ybH1(l1ALYbKPhO6YJutYYOf2C0GZAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1Arzqb4H6dsI1AQws2zLH4Qv(1kLditpqfBOjHoKeKutYoRnexTMQLgS3vbOJ6SRnYpmua5N)UNeLvE)(5zHotpqGhXEwIaEya5NfnyVR4qWoQf2C0GQ5XccR9xQ1kLditpq1LhPMKLrlS5ObN1AQ2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sTwuguaEO(GKyTMQvkhqMEGQdsIAq)GdnBuR8RvkhqMEGQlpsnjlJgahCBDpdnB8SyXbt)zDjOWwND9zJAsUb(UNeLLaF)8SqNPhiWJyplrapmG8ZIgS3vCiyh1cBoAq18ybH1(l1ALYbKPhO6YJutYYOf2C0GZAnvlL12QApEG(Pcqh1zxBKFyOqNPhiqTeruTImha5NRcqh1zxBKFyOcKKH(Sw5xRuoGm9avxEKAswgnao426Eg6inQLIAnvRuoGm9avhKe1G(bhA2Ow5xRuoGm9avxEKAswgnao426EgA24zXIdM(Z6sqHTo76Zg1KCd8DpjkR889ZZcDMEGapI9SyXbt)zXHGDuBKFy8SaWPiGghm9NL84eRLnQf2R9YJSw4S20Rvaul7a1(L()RwASwqJA7zu7i9gmQ9SzV2ZgRLKLPwaCWTnVwsMqO3u7emWApB(Q9dR1MLI1IEc2yxlj7CTSdu7zZxTNngyTWzTEE1YJazG21Y1gGowB2R1i)WOwG8ZvplrapmG8ZsK5ai)C1LGcBD21NnQj5gOkqsg6ZALFTs5aY0duXgAswgnao426Eg6lpYAnvlL12QAfPu0z)usr)SBh1ser1kYCaKFUIegrgtD21xgKOFQajzOpRv(1kLditpqfBOjzz0a4GBR7zOjZRwkQ1uT0G9UIdb7OwyZrdQMhliSwQ1sd27koeSJAHnhnOIKLrppwqyTMQLgS3vbOJ6SRnYpmua5NxRPAjzNvgIRw5tTwPCaz6bQydnj0HKGKAs2zTH4E3tIY2AE)8SqNPhiWJyplwCW0FwbOJ6SRnYpmEwa4ueqJdM(ZsECI1gPrTWETxEK1cN1METcGAzhO2V0)F1sJ1cAuBpJAhP3GrTNn71E2yTKSm1cGdUT51sYec9MANGbw7zJbwlC6)VA5rGmq7A5AdqhRfi)8AzhO2ZMVAzJA)s))vlnkssSwwkdhm9aRfamGEtTbOJQNLiGhgq(zrd27koeSJAJ8ddfq(51AQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZALFTs5aY0dufPHMKLrdGdUTUNH(YJSwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1kLditpq1LhPMKLrdGdUTUNHMnQLIAnvlnyVR4qWoQf2C0GQ5XccRLAT0G9UIdb7OwyZrdQizz0ZJfewRPAfzoaYpxXHGDuBKFyOcKKH(Sw5xRSsUwt1kYCaKFU6sqHTo76Zg1KCdufijd9zTYVwzL87Esu2wW7NNf6m9abEe7zjc4HbKFws5aY0duLG3ecG6SRfzoaYpF(SyXbt)znTH9d6nAJ8dJ39KOSTW3ppl0z6bc8i2ZIfhm9NLrGt0fOo7AsOd8SaWPiGghm9NL84eR1ijR9YANTiqejOH1YETOmxW1Y01c9ApBSwhL5QvK5ai)8A)Goq(zETG(aNZAjSDazV2Zg9AtF0UwaWa6n1YHGDSwJ8dJAbaXAVSw78Rws25ATb9MODTbdaz)QDAWbH1cNplrapmG8Z64b6NkaDuNDTr(HHcDMEGa1AQwAWExXHGDuBKFyOanQ1uT0G9UkaDuNDTr(HHkqsg6ZA)T2gbGIKL5Dpjkhj)(5zHotpqGhXEwIaEya5Nfasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)TwwCW0vCiyh1KW5eoWPcLbfGhQpijwRPABvTIuk6SFkcBhq2FwS4GP)SmcCIUa1zxtcDG39KOCK99ZZcDMEGapI9Seb8WaYplAWExfGoQZU2i)WqbAuRPAPb7Dva6Oo7AJ8ddvGKm0N1(BTncafjltTMQvK5ai)Cfknf8btxfid0Uwt1kYCaKFU6sqHTo76Zg1KCdufijd9zTMQTv1ksPOZ(PiSDaz)zXIdM(ZYiWj6cuNDnj0bE37Ew2CqME73ppjk77NNf6m9abEe7zXIdM(ZcLMc(GP)SaWPiGghm9NvRTx7i)Qn9AjzNRLDGAfzoaYpFwlhyTIKe6n1cAyETnzTSnYa1YoqTO08zjc4HbKFwKSZkdXv7VuRLGLCTMQvkhqMEGQe8MqauNDTiZbq(5ZAnvlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR93ALvY1sX7EsuoVFEwOZ0de4rSNfaofb04GP)SKhWA)y)Q9YANhliSwBoitVDTDWXOTQ2FSXAbNyTzVwzLN1opwq4SwBmWAHZAVSwwisq)QTNrTNnw7bfew7a7xTPx7zJ1kSz3XrTSdu7zJ1scNt4aRf612hWg7t9Seb8WaYplkRvkhqMEGQ5Xcc12CqME7AjIOApijw7V1kRKRLIAnvlnyVR4qWoQT5Gm92Q5XccR93ALvE(Se2m0FwY(SyXbt)zXHGDutcNt4aNV7jrc(9ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplaCkcOXbt)zjpyJETGtO3uR8cPr7a5rTe0daNDbAETcEE1Y12XVArzUGRLeoNWboR9ZgoWA)y4b9MA7zu7zJ1sd271YxTNnw7844Qn71E2yTDyJ99Seb8WaYplSfbcnmqafsA0oqEOZaWzxG1AQ2dsI1(BTeSKR1uTx20mqLiZbq(5ZAnvRiZbq(5kK0ODG8qNbGZUavbsYqFwR8Rvw5zlOwt12QAzXbtxHKgTdKh6maC2fOcaoz6bc8UNeL3VFEwOZ0de4rSNLiGhgq(zjLditpqfsAKFyGaAAocUbR1uTImha5NRUeuyRZU(Srnj3avbsYqFw7VuRfLbfGhQpijwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwlL1IYGcWd1hKeRTLxRCQLIAnvlL12QAXwei0WabuZeCmW7GEJoaPBxlrevRiDaq4P4qWoQnIea20wfStyTYNATeyTeruTImha5NRMj4yG3b9gDas3wfijd9zT)sTwkRfLbfGhQpijwBlVw5ulf1sXZIfhm9NvWaq2p90GdcF3tIe47NNf6m9abEe7zjc4HbKFws5aY0du1Ycopn4eb0tdoiSwt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwuguaEO(GKyTMQLYABvTylceAyGaQzcog4DqVrhG0TRLiIQvKoai8uCiyh1grcaBARc2jSw5tTwcSwIiQwrMdG8ZvZeCmW7GEJoaPBRcKKH(S2FPwlkdkapuFqsSwkEwS4GP)SUeuyRZU(Srnj3aF3tIYZ3ppl0z6bc8i2ZseWddi)SmcuQUraOKvDjOWwND9zJAsUb(SyXbt)zXHGDuBKFy8UNeBnVFEwOZ0de4rSNLiGhgq(zjLditpqfsAKFyGaAAocUbR1uTImha5NRcgaY(PNgCqOkqsg6ZA)LATOmOa8q9bjXAnvRuoGm9avhKe1G(bhA2Ow5tTw5i5AnvlL12QAfPdacpfhc2rTrKaWM2k0z6bculrevBRQvkhqMEGkE8XTN6zBxOfzoaYpFwlrevRiZbq(5Qlbf26SRpButYnqvGKm0N1(l1APSwuguaEO(GKyTT8ALtTuulfplwCW0FwbOJ6SRnYpmE3tITG3ppl0z6bc8i2ZseWddi)SKYbKPhOcjnYpmqannhb3G1AQwJaLQBeakzvbOJ6SRnYpmEwS4GP)ScgaY(PNgCq47EsSf((5zHotpqGhXEwIaEya5NLuoGm9avTSGZtdora90GdcR1uTTQwPCaz6bQSZba0B0xEKplwCW0FwxckS1zxF2OMKBGV7jrzL87NNf6m9abEe7zXIdM(ZIdb7OMMJGBWNfaofb04GP)SKhNyTYXbQLdb7yT0CeCdwl0RTLADjqqrqV1Rn9r7AH9Aj2itGb48QLDGA5R2bYZRw5ulbqaZAnIuiqGNLiGhgq(zrd27koeSJAHnhnOAESGWAPwlnyVR4qWoQf2C0Gkswg98ybH1AQwAWExfGoQZU2i)WqbAuRPAPb7Dfhc2rTr(HHc0Owt1sd27koeSJABoitVTAESGWALp1ALvEwRPAPb7Dfhc2rTr(HHkqsg6ZA)LATS4GPR4qWoQP5i4guHYGcWd1hKeR1uT0G9UIEKjWaCEkqJ39KOSY((5zHotpqGhXEwS4GP)Scqh1zxBKFy8SaWPiGghm9NL84eRvooqTeuzRxl0RTLA9AtF0UwyVwInYeyaoVAzhOw5ulbqaZAnIu8Seb8WaYplAWExfGoQZU2i)WqbKFETMQLgS3v0JmbgGZtbAuRPAPSwPCaz6bQoijQb9do0SrTYVwcwY1ser1kYCaKFUkyai7NEAWbHQajzOpRv(1kRCQLIAnvlL1sd27koeSJABoitVTAESGWALp1ALLaRLiIQLgS3vIbYHGNh0BuZJfewR8PwRS1srTMQLYABvTI0baHNIdb7O2isaytBf6m9abQLiIQTv1kLditpqfp(42t9STl0Imha5NpRLI39KOSY59ZZcDMEGapI9Seb8WaYplAWExXHGDuBKFyOaYpVwt1szTs5aY0duDqsud6hCOzJALFTeSKRLiIQvK5ai)CvWaq2p90GdcvbsYqFwR8Rvw5ulf1AQwkRTv1kshaeEkoeSJAJibGnTvOZ0deOwIiQ2wvRuoGm9av84JBp1Z2UqlYCaKF(SwkEwS4GP)Scqh1zxBKFy8UNeLLGF)8SqNPhiWJyplrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAPSwAWExXHGDulS5ObvZJfewR8PwRCQLiIQvK5ai)Cfhc2rDg0QazG21srTMQLYABvThpq)ubOJ6SRnYpmuOZ0deOwIiQwrMdG8ZvbOJ6SRnYpmubsYqFwR8RLaRLIAnvRuoGm9av48GK8HaA2qlYCaKFETYNATeSKR1uTuwBRQvKoai8uCiyh1grcaBARqNPhiqTeruTTQwPCaz6bQ4Xh3EQNTDHwK5ai)8zTu8SyXbt)zfmaK9tpn4GW39KOSY73ppl0z6bc8i2ZIfhm9N1LGcBD21NnQj5g4ZcaNIaACW0FwYd2OxBa6o0BQ1isaytBZRfCI1E5rwlD7AH3eh9AHETzaGrTxwlpGnETWR2p4zxlB8Seb8WaYplPCaz6bQoijQb9do0SrT)wlbk5AnvRuoGm9avhKe1G(bhA2Ow5xlbl5AnvlL12QAXwei0WabuZeCmW7GEJoaPBxlrevRiDaq4P4qWoQnIea20wfStyTYNATeyTu8UNeLLaF)8SqNPhiWJyplrapmG8ZskhqMEGQwwW5PbNiGEAWbH1AQwAWExXHGDulS5ObvZJfew7V1sd27koeSJAHnhnOIKLrppwq4ZIfhm9Nfhc2rDg0V7jrzLNVFEwOZ0de4rSNLiGhgq(zbG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybH1sTwaKgS3vbdaz)0tdoiulfC4yW0Wb8ARizz0ZJfe(SyXbt)zXHGDutZrWn47Esu2wZ7NNf6m9abEe7zjc4HbKFws5aY0du1Ycopn4eb0tdoiSwIiQwkRfaPb7DvWaq2p90Gdc1sbhogmnCaV2kqJAnvlasd27QGbGSF6PbheQLcoCmyA4aETvZJfew7V1cG0G9Ukyai7NEAWbHAPGdhdMgoGxBfjlJEESGWAP4zXIdM(ZIdb7OMEWZ7DpjkBl49ZZcDMEGapI9SyXbt)zXHGDutZrWn4ZcaNIaACW0FwYJtSwsOdRLyCeCdwlnEFi61gmaK9R2PbheoRf2Rf0bWOwIrC1(bp7e8QfahCBO3ulbfdaz)Q1YGdcRfcG8y0(zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfq(51AQwAWExrpYeyaopfOrTMQvK5ai)CvWaq2p90GdcvbsYqFw7VuRvwjxRPAPb7Dfhc2rTnhKP3wnpwqyTYNATYkpF3tIY2cF)8SqNPhiWJyplwCW0FwCiyh1zq)SaWPiGghm9NL84eRnd6AtVwbqTG(aNZAzJAHZAfjj0BQf0O2zM(ZseWddi)SOb7Dfhc2rTWMJgunpwqyT)wlbxRPALYbKPhO6GKOg0p4qZg1k)ALvY1AQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZALFTeyTeruTTQwr6aGWtXHGDuBejaSPTcDMEGa1sX7Esuos(9ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZIgS3vIbYHGNh0BubYIRwt1sd27koeSJAJ8ddfOX7EsuoY((5zHotpqGhXEwS4GP)S4qWoQP5i4g8zbGtranoy6pRwBV2pS2g8Q1i)WOwO3bNW0RfamGEtTdW5v7h(FmQ1MLI1IEc2yxRnppS2lRTbVAZEVwU25fP3ulnhb3G1cagqVP2ZgRnsdjXg1(bDG87zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27Qa0rD21g5hgQajzOpR9xQ1YIdMUIdb7OMeoNWbovOmOa8q9bjXAnvlnyVR4qWoQnYpmuGg1AQwAWExXHGDulS5ObvZJfewl1APb7Dfhc2rTWMJgurYYONhliSwt1sd27koeSJABoitVTAESGWAnvlnyVRmYpm0qVdoHPRanQ1uT0G9UIEKjWaCEkqJ39KOCKZ7NNf6m9abEe7zXIdM(ZIdb7OMEWZ7zbGtranoy6pRwBV2pS2g8Q1i)WOwO3bNW0RfamGEtTdW5v7h(FmQ1MLI1IEc2yxRnppS2lRTbVAZEVwU25fP3ulnhb3G1cagqVP2ZgRnsdjXg1(bDG8Z8ANzTF4)XO20hTRfCI1IEc2yxl9GN3SwOdpipgTR9YABWR2lRTNGrTcBoAW5ZseWddi)SOb7DLrGt0fOo7AsOdOanQ1uTuwlnyVR4qWoQf2C0GQ5XccR93APb7Dfhc2rTWMJgurYYONhliSwIiQ2wvlL1sd27kJ8ddn07Gty6kqJAnvlnyVROhzcmaNNc0OwkQLI39KOCi43ppl0z6bc8i2ZIfhm9NLrGt0fOo7AsOd8SaWPiGghm9N1p2yT048QfCI1M9AnsYAHZAVSwWjwl8Q9YABrGqbHJ21sdcha1kS5ObN1cagqVPw2OwUFyu7zJTRTbVAbajnqGAPBx7zJ1AZbz6TRLMJGBWNLiGhgq(zrd27koeSJAHnhnOAESGWA)TwAWExXHGDulS5ObvKSm65XccR1uT0G9UIdb7O2i)WqbA8UNeLJ8(9ZZcDMEGapI9SaWPiGghm9NL8aw7h7xTxw78ybH1AZbz6TRTdogTv1(Jnwl4eRn71kR8S25XccN1AJbwlCw7L1Ycrc6xT9mQ9SXApOGWAhy)Qn9ApBSwHn7ooQLDGApBSws4CchyTqV2(a2yFQNfloy6ploeSJAs4Cch48zb9dJa04EwY(Se2m0FwY(Seb8WaYplAWExXHGDuBZbz6TvZJfew7V1kR88zb9dJa040nJKMhplzF3tIYHaF)8SqNPhiWJyplrapmG8ZIgS3vCiyh1cBoAq18ybH1sTwAWExXHGDulS5ObvKSm65XccR1uTs5aY0duHKg5hgiGMMJGBWNfloy6ploeSJAAocUbF3tIYrE((5zHotpqGhXEwIaEya5Nfj7SYqC1(BTYsGplwCW0FwO0uWhm939KOCAnVFEwOZ0de4rSNfloy6ploeSJA6bpVNfaofb04GP)SiO7J21coXAPh88Q9YAPbHdGAf2C0GZAH9A)WA5rGmq7ATzPyTZKeRThjzTzq)Seb8WaYplAWExXHGDulS5ObvZJfewRPAPb7Dfhc2rTWMJgunpwqyT)wlnyVR4qWoQf2C0Gkswg98ybHV7jr50cE)8SqNPhiWJyplaCkcOXbt)zjVo4yu7h8SRLjRf0h4CwlBulCwRijHEtTGg1YoqTF4)aRDKF1METKSZplwCW0FwCiyh1KW5eoW5Zc6hgbOX9SK9zjSzO)SK9zjc4HbKFwTQwkRvkhqMEGQdsIAq)GdnBu7VuRvwjxRPAjzNvgIR2FRLGLCTu8SG(HraAC6MrsZJNLSV7jr50cF)8SqNPhiWJyplaCkcOXbt)z16r2HdCw7h8SRDKF1sYZdJ2MxRnSXUwBEEO51MrT05zxlj3UwpVATzPyTONGn21sYox7L1obnmY4Q1o)QLKDUwOFOpHsXAdgaY(v70GdcRvWET0O51oZA)W)JrTGtS2omWAPh88QLDGA7rop6CC1(zJETJ8R20RLKD(zXIdM(ZQddutp459UNejyj)(5zXIdM(ZQh58OZX9SqNPhiWJyV7DplbpeGd(GPpF)8KOSVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIplzFwIaEya5NLuoGm9av2SuuNgOJa1sTwjxRPAncuQUraOKvHstbFW0R1uTTQwkRnaDSNrdQMqd701Zldsf6m9abQLiIQnaDSNrdQoK0idEO)4WqHotpqGAP4zjLdTZK4ZYMLI60aDe4DpjkN3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZskhqMEGkBwkQtd0rGAPwRKR1uT0G9UIdb7O2i)WqbKFETMQvK5ai)Cfhc2rTr(HHkqsg6ZAnvlL1gGo2ZObvtOHD665LbPcDMEGa1ser1gGo2ZObvhsAKbp0FCyOqNPhiqTu8SKYH2zs8zzZsrDAGoc8UNej43ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZIgS3vCiyh1cBoAq18ybH1sTwAWExXHGDulS5ObvKSm65XccR1uTTQwAWExfGduND9zhiovGg1AQ2oSX(0bsYqFw7VuRLYAPSws25ALuTS4GPR4qWoQPh88uICE1srTT8AzXbtxXHGDutp45Pqzqb4H6dsI1sXZskhANjXNvh68qtdg(7EsuE)(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SOb7Dfhc2rTnhKP3wnpwqyTYNATYsG1ser1szTbOJ9mAqfhc2rnDssZbaj6NcDMEGa1AQ2JJg8u2ipoBLH4Q93AjycSwkEwa4ueqJdM(ZsEbE2yulxBhCmAx78ybHiqT2CqME7AZOwOxlkdkapS2G9gS2p4zxlXssAoair)Ews5q7mj(SqsJ8ddeqtZrWn47EsKaF)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplPCODMeFwdEEA2qdoXNfa2zWX9SK8ZseWddi)SOb7Dfhc2rTr(HHc0Owt1szTs5aY0dun45Pzdn4eRLATsUwIiQ2dsI1kFQ1kLditpq1GNNMn0GtSwjuRSeyTu8SKYdq8zDqs8DpjkpF)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFwuwRiZbq(5koeSJAJ8ddfayWhm9AB51szTYwBltTuwRKvsMGRTLxRiDaq4P4qWoQnIea20wfStyTuulf1srTTm1szThKeRTLPwPCaz6bQg880SHgCI1sXZcaNIaACW0FwTuiyhRT1Jea20U2gOuCwlxRuoGm9aRLjtq)Qn71kacZRLg8Q9d)pg1coXA5A7d(QfNhKKpy61AJbQQ9hBS2jKuuRrKsHaiqTbsYqFQrzmqXHa1IYye4CctVwGeN165v7xgew7hog12ZOwJibGnTRfaeR9YApBSwAWyETR15dmWAZETNnwRaiuplPCODMeFw48GK8HaA2qlYCaKF(7EsS18(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKYbKPhOcNhKKpeqZgArMdG8ZFwIaEya5NLiDaq4P4qWoQnIea20(zjLdTZK4Z6GKOg0p4qZgV7jXwW7NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsK5ai)Cfhc2rTr(HHkqsg6ZNLiGhgq(z1QAfPdacpfhc2rTrKaWM2k0z6bc8SKYH2zs8zDqsud6hCOzJ39Kyl89ZZcDMEGapI9SsJNfjlZZIfhm9NLuoGm9aFws5q7mj(SoijQb9do0SXZseWddi)SOSwrMdG8ZvxckS1zxF2OMKBGQajzOpRTLPwPCaz6bQoijQb9do0SrTuu7V1khj)SaWPiGghm9NL8a(FmQfahC7ABPwVwqJAVSw5i5jkQTNrT)Kxl(zjLhG4ZsK5ai)C1LGcBD21NnQj5gOkqsg6Z39KOSs(9ZZcDMEGapI9SsJNfjlZZIfhm9NLuoGm9aFws5q7mj(SoijQb9do0SXZseWddi)SePdacpfhc2rTrKaWM21AQwr6aGWtXHGDuBejaSPTkyNWA)TwcSwt1ITiqOHbcOMj4yG3b9gDas3Uwt1ksPOZ(PiSDazVwt1gGo2ZObvCiyh12CqMEBf6m9abEwa4ueqJdM(ZYc6cSwckq621cN1obf21Y1AKFy0bh1Eb0jeVA7zuR86Bhq2nV2p8)yu78GccR9YApBS27lRLe6GhwROTyG1c6hCu7hwBdE1Y1AdBSRf9eSXU2GDcRn71AejaSP9ZskpaXNLiZbq(5Qzcog4DqVrhG0TvbsYqF(UNeLv23ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLiZbq(5Qlbf26SRpButYnqvGmq7AnvRuoGm9avhKe1G(bhA2O2FRvos(zbGtranoy6pl5b8)yulao421(tET4AbnQ9YALJKNOO2Eg12sT(ZskhANjXNLDoaGEJ(YJ8DpjkRCE)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFwuwRrGs1ncaLSQGbGSF6PbhewlrevRrGs1ncaLCubdaz)0tdoiSwIiQwJaLQBeakcwfmaK9tpn4GWAPOwt1cG0G9Ukyai7NEAWbHAPGdhdMgoGxBfq(5plaCkcOXbt)zrqXaq2VATm4GWAbsCwRNxTqsseaYhoAxRb4vlOrTNnwRuWHJbtdhWRDTainyVx7mRfE1kyVwASwayVdfGJR2lRfaofy41E28v7h(pWA5R2ZgRLGgg5zxRuWHJbtdhWRDTZJfe(SKYH2zs8z1Ycopn4eb0tdoi8Dpjklb)(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SOb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubKFETMQTv1kLditpqvll480Gteqpn4GWAnvlasd27QGbGSF6PbheQLcoCmyA4aETva5N)SKYH2zs8zLG3ecG6SRfzoaYpF(UNeLvE)(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(Scqh7z0GkoeSJABoitVTcDMEGa1AQwkRLYAfPu0z)ue2oGSxRPAfzoaYpxfmaK9tpn4GqvGKm0N1(BTs5aY0duzZbz6T1ZJfeQpijwlf1sXZskhANjXN18ybHABoitV97E3ZQdDEOPbd)9ZtIY((5zHotpqGhXEwS4GP)S4qWoQjHZjCGZNLWMH(Zs2NLiGhgq(zrd27kXa5qWZd6nQazX9UNeLZ7NNfloy6ploeSJA6bpVNf6m9abEe7DpjsWVFEwS4GP)S4qWoQP5i4g8zHotpqGhXE37E3Zskgty6pjkhjlhzLCRrwj)S(4WHEZ8zjp0seusS1kr5vi(AR9hBSwiPrgxT9mQ9VnhKP3(FTb2IaHbcu7mjXAzWlj5dbQvyZEdovLzeh0XALL4RLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZioOJ1kVj(AjG0LIXHa1()cOtiEkMwOezoaYp)FTxw7FrMdG8ZvmT4FTukRmuOkZioOJ1sGeFTeq6sX4qGA)Fb0jepftluImha5N)V2lR9ViZbq(5kMw8VwkLvgkuLzeh0XABneFTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvzgXbDSwzLL4RLasxkghcu7Fr6aGWtj3)1EzT)fPdacpLCvOZ0de4FTukRmuOkZioOJ1kRCi(AjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlLYkdfQYmId6yTYsWeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzgXbDSwzjyIVwciDPyCiqT)fPdacpLC)x7L1(xKoai8uYvHotpqG)1sPSYqHQmJ4GowRSTqIVwciDPyCiqT)fPdacpLC)x7L1(xKoai8uYvHotpqG)1sPSYqHQmRmtEOLiOKyRvIYRq81w7p2yTqsJmUA7zu7)oCAd9gDAGog)RnWweimqGANjjwldEjjFiqTcB2BWPQmJ4GowRSeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLJmuOkZioOJ1khIVwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmJ4Gowlbt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvEt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRLaj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1kpj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FT8vR8cbDIRwkLvgkuLzeh0XABHeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XABHeFTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLVALxiOtC1sPSYqHQmJ4GowRSYH4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPCKHcvzgXbDSwzjqIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTY2ci(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1khjt81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzeh0XALdbt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuoYqHQmJ4GowRCiyIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlF1kVqqN4QLszLHcvzgXbDSw5qGeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8Vw(QvEHGoXvlLYkdfQYmId6yTYrEs81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzLzYdTebLeBTsuEfIV2A)XgRfsAKXvBpJA)h5Xhm9)1gylcegiqTZKeRLbVKKpeOwHn7n4uvMrCqhRvwIVwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmJ4GowRSeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALdXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSwcM4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4Gowlbs81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzeh0XALNeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzgXbDSwzLmXxlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMrCqhRv2wiXxlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMrCqhRv2wiXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw5izIVwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmJ4GowRCKmXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw5ilXxlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMrCqhRvoYs81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvoYH4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowRCiyIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYSYm5HwIGsITwjkVcXxBT)yJ1cjnY4QTNrT)td0X4FTb2IaHbcu7mjXAzWlj5dbQvyZEdovLzeh0XALL4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowRCi(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1kRCi(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmId6yTYsGeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8Vw(QvEHGoXvlLYkdfQYmId6yTYkpj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FT8vR8cbDIRwkLvgkuLzeh0XALT1q81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzLzYdTebLeBTsuEfIV2A)XgRfsAKXvBpJA)dGDgCC)RnWweimqGANjjwldEjjFiqTcB2BWPQmJ4GowRCi(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYrgkuLzeh0XAL3eFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALvEt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvw5jXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSwzBbeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALJCi(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FT8vR8cbDIRwkLvgkuLzeh0XALdbt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvoYBIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTYHaj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1kh5jXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw50Ai(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZkZKhAjckj2ALO8keFT1(JnwlK0iJR2Eg1(3iqrssZ3)AdSfbcdeO2zsI1YGxsYhcuRWM9gCQkZioOJ1kpj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1kpj(AjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlLYkdfQYmId6yTYrYeFTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvzgXbDSw5ilXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw5ilXxlbKUumoeO2)I0baHNsU)R9YA)lshaeEk5QqNPhiW)APuwzOqvMrCqhRvoYH4RLasxkghcu7Fr6aGWtj3)1EzT)fPdacpLCvOZ0de4FTukRmuOkZioOJ1kNwiXxlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuoYqHQmJ4GowRCAHeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XAjy5q81saPlfJdbQ9)mbh0qhqj3)1EzT)Nj4Gg6ak5QqNPhiW)APuwzOqvMrCqhRLGLdXxlbKUumoeO2)ZeCqdDaLC)x7L1(FMGdAOdOKRcDMEGa)RLVALxiOtC1sPSYqHQmJ4GowlbtWeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XAjycM4RLasxkghcu7Fr6aGWtj3)1EzT)fPdacpLCvOZ0de4FTukRmuOkZioOJ1sWYBIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlF1kVqqN4QLszLHcvzgXbDSwcMaj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1sWYtIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYSYm5HwIGsITwjkVcXxBT)yJ1cjnY4QTNrT)fzoaYpF(V2aBrGWabQDMKyTm4LK8Ha1kSzVbNQYmId6yTYs81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLJmuOkZioOJ1klXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw5q81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLJmuOkZioOJ1khIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTemXxlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuoYqHQmJ4Gowlbt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvEt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRLaj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1kpj(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYrgkuLzeh0XABneFTeq6sX4qGA)ptWbn0buY9FTxw7)zcoOHoGsUk0z6bc8VwkLJmuOkZioOJ12cj(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYrgkuLzeh0XALvYeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5idfQYmId6yTYkhIVwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPCKHcvzgXbDSwzjyIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTYkVj(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmId6yTYsGeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzgXbDSwzBHeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzwzM8qlrqjXwReLxH4RT2FSXAHKgzC12ZO2)CI)RnWweimqGANjjwldEjjFiqTcB2BWPQmJ4GowRSeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5idfQYmId6yTYs81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvoeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLJmuOkZioOJ1sWeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5idfQYmId6yTemXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSw5nXxlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvzgXbDSwcK4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowR8K4RLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZioOJ12Ai(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ12ci(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ12cj(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYrgkuLzeh0XALvYeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALvwIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTYkhIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTYsWeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5idfQYmId6yTYkpj(AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYrgkuLzeh0XALTfs81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8Vw(QvEHGoXvlLYkdfQYmId6yTYrYeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALJSeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALJCi(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1khcM4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowRCK3eFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuLzeh0XALdbs81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvMrCqhRvoYtIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTYP1q81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzeh0XALtRH4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowRCAbeFTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzgXbDSw50ci(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOkZioOJ1sWsM4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmJ4GowlblhIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTeS8M4RLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZioOJ1sWYBIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTembs81saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLJmuOkZioOJ1sWYtIVwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmRmtEOLiOKyRvIYRq81w7p2yTqsJmUA7zu7FbpeGd(GPp)xBGTiqyGa1otsSwg8ss(qGAf2S3GtvzgXbDSwzj(AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukhzOqvMrCqhRvoeFTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLJmuOkZioOJ1sWeFTeq6sX4qGATGKeqTZ2(XYuR8Av7L1sCGCTaqPWjm9Atdm4lJAPusuulLYkdfQYmId6yTYBIVwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQYmId6yTTaIVwciDPyCiqT)fPdacpLC)x7L1(xKoai8uYvHotpqG)1YxTYle0jUAPuwzOqvMrCqhRvwjt81saPlfJdbQ9)fqNq8umTqjYCaKF()AVS2)Imha5NRyAX)APuwzOqvMrCqhRvwjt81saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)A5Rw5fc6exTukRmuOkZioOJ1kR8M4RLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQmRmR1sAKXHa1kRKRLfhm9AhW5nvLzplg8SZ4zzbjbh8btNacUFplJi7Wb(SiieKABXCdwBlfc2XYmccbP2wcSbCE1kRCmVw5iz5iBzwzgbHGulbyZEdoj(YmccbP2wMALhNyTxBdOGh1AbjjGATzhya9MAZETcB2DCul0pmcqJdMETqFEiduB2R9VGDbo0S4GP)xvMrqii12YulbyZEdwlhc2rn07qhETR9YA5qWoQT5Gm921sj8Q1rPyu7h6xTdOuSwEwlhc2rTnhKP3Mcvzwzgloy6tLrGIKKMpjqvsCiyh1q)WXafxzgloy6tLrGIKKMpjqvsCiyh1DMeoGCuMXIdM(uzeOijP5tcuLKi9wwWa1KSZ6gKSmJfhm9PYiqrssZNeOkjPCaz6bAUZKivor9XrdEArc6N5Pb1aN4zoa2zWXrLGlZyXbtFQmcuKK08jbQsskhqMEGM7mjsfLMAdXzEAqnWjEMdGDgCCuLLalZyXbtFQmcuKK08jbQsskhqMEGM7mjs1iqdWXqJstZtdQt8mh2Psza6ypJgunHg2PRNxgKMOuKsrN9tjf9ZUDqerIuk6SFkhfroYaGiIePdacpfhc2rTrKaWM2uqH5s5bisvwZLYdquJJjsvYLzS4GPpvgbkssA(KavjjLditpqZDMePAZsrDAGocyEAqDIN5WovwCqPOgDKeIt5tvkhqMEGkor9XrdEArc6N5s5bisvwZLYdquJJjsvYLzS4GPpvgbkssA(KavjjLditpqZDMeP2Hop00GHBEAqDIN5s5bisvYLzS4GPpvgbkssA(KavjjLditpqZDMePAZbz6T1ZJfeQpijAEAqnWjEMdGDgCCuBHLzS4GPpvgbkssA(KavjjLditpqZDMePYJpU9upB7cTiZbq(5tZtdQboXZCaSZGJJQKlZyXbtFQmcuKK08jbQsskhqMEGM7mjsnMAswgnao426Eg6lpsZtdQboXZCaSZGJJkbwMXIdM(uzeOijP5tcuLKuoGm9an3zsKAm1KSmAaCWT19m0rAyEAqnWjEMdGDgCCujWYmwCW0NkJafjjnFsGQKKYbKPhO5otIuJPMKLrdGdUTUNHMnmpnOg4epZbWodooQYrYLzS4GPpvgbkssA(KavjjLditpqZDMePsMN2iqbIa6lpsnDBZtdQboXZCaSZGJJAlOmJfhm9PYiqrssZNeOkjPCaz6bAUZKivY80KSmAaCWT19m0xEKMNgudCIN5ayNbhhvzLCzgloy6tLrGIKKMpjqvss5aY0d0CNjrQK5Pjzz0a4GBR7zOzdZtdQboXZCaSZGJJQSeyzgloy6tLrGIKKMpjqvss5aY0d0CNjrQSHMKLrdGdUTUNH(YJ080GAGt8mh2PkshaeEkoeSJAJibGnTnxkparQeSKnxkparnoMivzLCzgloy6tLrGIKKMpjqvss5aY0d0CNjrQSHMKLrdGdUTUNH(YJ080GAGt8mha7m44OkhjxMXIdM(uzeOijP5tcuLKuoGm9an3zsKkBOjzz0a4GBR7zOjZZ80GAGt8mha7m44OkhjxMXIdM(uzeOijP5tcuLKuoGm9an3zsKAKgAswgnao426Eg6lpsZtdQt8mxkparQYrYTmusGTCr6aGWtXHGDuBejaSPnfLzS4GPpvgbkssA(KavjjLditpqZDMePE5rQjzz0a4GBR7zOzdZtdQt8mxkparQeOeKJKB5uksPOZ(PCyJ9P7mserukshaeEkoeSJAJibGnTnXIdkf1OJKqC(RuoGm9avCI6JJg80Ie0pkOqcYsGTCkfPu0z)ue2oGSBkaDSNrdQ4qWoQT5Gm92MyXbLIA0rsioLpvPCaz6bQ4e1hhn4PfjOFuuMXIdM(uzeOijP5tcuLKuoGm9an3zsK6LhPMKLrdGdUTUNHosdZtdQt8mxkparQYrYTmu2cA5I0baHNIdb7O2isaytBkkZyXbtFQmcuKK08jbQsskhqMEGM7mjsLMJGBqnj7S2qCMNguN4zoStvKsrN9t5Wg7t3z0CP8aePkpLCldLK88WOTwkpaXwUSswYuuMXIdM(uzeOijP5tcuLKuoGm9an3zsKknhb3GAs2zTH4mpnOoXZCyNQiLIo7NIW2bKDZLYdqKAlKaBzOKKNhgT1s5bi2YLvYsMIYmwCW0NkJafjjnFsGQKKYbKPhO5otIuP5i4gutYoRneN5Pb1jEMd7uLYbKPhOIMJGBqnj7S2qCuLS5s5bisTfi5wgkj55HrBTuEaITCzLSKPOmJfhm9PYiqrssZNeOkjPCaz6bAUZKiv2qtcDijiPMKDwBioZtdQboXZCaSZGJJQSeyzgloy6tLrGIKKMpjqvss5aY0d0CNjrQxEKAswgTWMJgCAEAqnWjEMdGDgCCuLtzgloy6tLrGIKKMpjqvss5aY0d0CNjrQCI6lpsnjlJwyZrdonpnOg4epZbWodooQYPmJfhm9PYiqrssZNeOkjPCaz6bAUZKi1oCAd9gDAGogMNguN4zUuEaIuLTLtj2IaHggiGcjnAhip0za4SlqIiIYJhOFQa0rD21g5hgMO84b6NIdb7Ogf2jre1krkfD2pfHTdi7uyIYwjsPOZ(PCue5idaIiIfhukQrhjH4KQSerua6ypJgunHg2PRNxgKuyQvIuk6SFkPOF2TdkOOmJfhm9PYiqrssZNeOkjPCaz6bAUZKiv2qNUgCIMNguN4zUuEaIuXwei0WabuKSGPdupTr80KGtOGiIWwei0WabundgaYxgtnnd0Gere2IaHggiGQzWaq(YyQjraEmGPterylceAyGakaoiKmtxdGcc1gGxGtb6cKiIWwei0WabuqFkcWJPhOUfbY(bsQbqPqbserylceAyGaQzcog4DqVrhG0TjIiSfbcnmqa1e0PhzcOzs8SBppIicBrGqddeq9XeIogtDpshGiIWwei0Wabu9btI6SRP57gyzgloy6tLrGIKKMpjqvsKWiYqdj5gSmJfhm9PYiqrssZNeOkP(aN2IG7N5Wo1zcoOHoGsAo4doq9mhsr)iIOzcoOHoGYaCEGduJbOXbtVmJfhm9PYiqrssZNeOkPa0rD21g5hgMd7ufPu0z)ue2oGSBkaDSNrdQ4qWoQT5Gm92MePdacpfhc2rTrKaWM2MKYbKPhOIhFC7PE22fArMdG8ZNMyXbLIA0rsio)vkhqMEGkor9XrdEArc6xzgloy6tLrGIKKMpjqvs9iNhDooZHDQTskhqMEGkJanahdnknPkRPa0XEgnOcaofqJb05OTwKKKSduMXIdM(uzeOijP5tcuLehc2rn9GNN5Wo1wjLditpqLrGgGJHgLMuL1uRcqh7z0Gka4uangqNJ2ArssYoGjkBLiLIo7Nsk6ND7GiIKYbKPhOQdN2qVrNgOJbfLzS4GPpvgbkssA(KavjrcJiJPo76lds0pZHDQTskhqMEGkJanahdnknPkRPwfGo2ZObvaWPaAmGohT1IKKKDatIuk6SFkPOF2TdtTskhqMEGQoCAd9gDAGogLzS4GPpvgbkssA(KavjHstbFW0nh2PkLditpqLrGgGJHgLMuLTmRmJfhm9PeOkjrc6hgtdCmkZyXbtFkbQscCIAs2zDdsAoStLYJhOFk0hWg7dDeWej7SYqC)sTfiztKSZkdXjFQYtcKcIiIYwD8a9tH(a2yFOJaMizNvgI7xQTacKIYmwCW0NsGQKmYdMU5WovAWExXHGDuBKFyOankZyXbtFkbQs6GKO(JddZHDQbOJ9mAq1HKgzWd9hhgMOb7DfkJndopy6kqdtukYCaKFUIdb7O2i)Wqfid0MiIOZ50uh2yF6ajzOp)LQ8wYuuMXIdM(ucuL0a2yFtDlliqdj6N5WovAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfq(5LzS4GPpLavjrZn6SRVakiCAoStLgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgkG8ZnbG0G9U6sqHTo76Zg1KCdubKFEzgloy6tjqvs0ymXGqO3yoStLgS3vCiyh1g5hgkqJYmwCW0NsGQKOhzcO7GrBZHDQ0G9UIdb7O2i)WqbAuMXIdM(ucuLuhgi9itaZHDQ0G9UIdb7O2i)WqbAuMXIdM(ucuLe7cCEbp0cEmmh2Psd27koeSJAJ8ddfOrzgloy6tjqvsGtudpKCAoStLgS3vCiyh1g5hgkqJYmwCW0NsGQKaNOgEiP5yVJIt7mjsTzWaq(YyQPzGg0CyNknyVR4qWoQnYpmuGgerKiZbq(5koeSJAJ8ddvGKm0NYNkbsGMaqAWExDjOWwND9zJAsUbQankZyXbtFkbQscCIA4HKM7mjsfjnAhip0za4SlqZHDQImha5NR4qWoQnYpmubsYqF(lvzjqtImha5NRUeuyRZU(Srnj3avbsYqF(lvzjWYmwCW0NsGQKaNOgEiP5otIubcKb6Wa1sX5ehMd7ufzoaYpxXHGDuBKFyOcKKH(u(uLJKjIOwjLditpqfBOtxdorQYseruEqsKQKnjLditpqvhoTHEJonqhdQYAkaDSNrdQMqd701ZldskkZyXbtFkbQscCIA4HKM7mjsDMGdnSXHhgMd7ufzoaYpxXHGDuBKFyOcKKH(u(ujyjterTskhqMEGk2qNUgCIuLTmJfhm9PeOkjWjQHhsAUZKi1MrBdBD218CcjHd(GPBoStvK5ai)Cfhc2rTr(HHkqsg6t5tvosMiIALuoGm9avSHoDn4ePklrer5bjrQs2KuoGm9avD40g6n60aDmOkRPa0XEgnOAcnStxpVmiPOmJfhm9PeOkjWjQHhsAUZKivswW0bQN2iEAsWjuyoStvK5ai)Cfhc2rTr(HHkqsg6ZFPsGMOSvs5aY0du1HtBO3Otd0XGQSer0bjr5tWsMIYmwCW0NsGQKaNOgEiP5otIujzbthOEAJ4PjbNqH5WovrMdG8ZvCiyh1g5hgQajzOp)LkbAskhqMEGQoCAd9gDAGoguL1enyVRcqh1zxBKFyOanmrd27Qa0rD21g5hgQajzOp)LkLYk5wgcSLhGo2ZObvtOHD665LbjfMoij(lbl5YmwCW0NsGQKaNOgEiP5otIuN2mq(Ha6mO1zxFzqI(zoSt9GKivjterukLditpqvcEtiaQZUwK5ai)8PjkPuKsrN9try7aYUjrMdG8Zvbdaz)0tdoiufijd95VuLJjrMdG8ZvCiyh1g5hgQajzOp)LkbAsK5ai)C1LGcBD21NnQj5gOkqsg6ZFPsGuqerImha5NR4qWoQnYpmubsYqF(lv5qerDyJ9PdKKH(8xrMdG8ZvCiyh1g5hgQajzOpPGIYmccbPwwCW0NsGQKC8RNGoGoWzoKIMdor9NnCGAbppO3qvwZHDQ0G9UIdb7O2i)WqbAqerainyVRUeuyRZU(Srnj3avGgereqEQGbGSF6PbheQoOGqO3uMXIdM(ucuLKGhdnloy66bCEM7mjsvWdb4Gpy6ZYmwCW0NsGQKe8yOzXbtxpGZZCNjrQCIMpVakoQYAoStLfhukQrhjH4u(uLYbKPhOItuFC0GNwKG(vMXIdM(ucuLKGhdnloy66bCEM7mjs1MdY0BBoStvKsrN9try7aYUPa0XEgnOIdb7O2MdY0BxMXIdM(ucuLKGhdnloy66bCEM7mjsTdN2qVrNgOJH5WovPCaz6bQSzPOonqhbOkzts5aY0du1HtBO3Otd0XWuROuKsrN9try7aYUPa0XEgnOIdb7O2MdY0Btrzgloy6tjqvscEm0S4GPRhW5zUZKi10aDmmh2PkLditpqLnlf1Pb6iavjBQvuksPOZ(PiSDaz3ua6ypJguXHGDuBZbz6TPOmJfhm9PeOkjbpgAwCW01d48m3zsKQiZbq(5tZHDQTIsrkfD2pfHTdi7Mcqh7z0GkoeSJABoitVnfLzS4GPpLavjj4XqZIdMUEaNN5otIuJ84dMU5WovPCaz6bQ6qNhAAWWPkztTIsrkfD2pfHTdi7Mcqh7z0GkoeSJABoitVnfLzS4GPpLavjj4XqZIdMUEaNN5otIu7qNhAAWWnh2PkLditpqvh68qtdgovzn1kkfPu0z)ue2oGSBkaDSNrdQ4qWoQT5Gm92uuMvMXIdM(uXjsTh58OZXzoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b09iNNci)Ctusd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MaqAWExDjOWwND9zJAsUbQaYpNctImha5NRUeuyRZU(Srnj3avbsYqFsvYMOKgS3vCiyh1cBoAq18ybH)svkhqMEGkor9LhPMKLrlS5ObNMOKYJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95VuBeaMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4GBR7zOzdkiIikB1Xd0pva6Oo7AJ8ddtImha5NR4qWoQnYpmubsYqFkFPCaz6bQU8i1KSmAaCWT19m0SbferKiZbq(5koeSJAJ8ddvGKm0N)sTraqbfLzS4GPpvCIsGQK6Wa10dEEMd7uPmaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b0DyGkG8ZnzeOuDJaqjRQh58OZXrbrerza6ypJgubaNcOXa6C0wlsss2bmDqsKQKPOmJfhm9PItucuLupY5P9ukBoStnaDSNrdQAc4C0wdfqXanjYCaKFUIdb7O2i)Wqfijd9P8jyjBsK5ai)C1LGcBD21NnQj5gOkqsg6tQs2eL0G9UIdb7OwyZrdQMhli8xQs5aY0duXjQV8i1KSmAHnhn40eLuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LAJaWKiZbq(5koeSJAJ8ddvGKm0NYxkhqMEGQlpsnjlJgahCBDpdnBqbrerzRoEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUTUNHMnOGiIezoaYpxXHGDuBKFyOcKKH(8xQncakOOmJfhm9PItucuLupY5P9ukBoStnaDSNrdQAc4C0wdfqXanjYCaKFUIdb7O2i)Wqfijd9jvjBIskPuK5ai)C1LGcBD21NnQj5gOkqsg6t5lLditpqfBOjzz0a4GBR7zOV8inrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfesbrerPiZbq(5Qlbf26SRpButYnqvGKm0NuLSjAWExXHGDulS5ObvZJfe(lvPCaz6bQ4e1xEKAswgTWMJgCsbfMOb7Dva6Oo7AJ8ddfq(5uuMXIdM(uXjkbQsIdb7OMeoNWbonh2PksPOZ(PiSDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJABoitVTAESGWFLLanjYCaKFUkyai7NEAWbHQajzOp)LQuoGm9av2CqMEB98ybH6dsIsaLbfGhQpijAsK5ai)C1LGcBD21NnQj5gOkqsg6ZFPkLditpqLnhKP3wppwqO(GKOeqzqb4H6dsIsGfhmDvWaq2p90GdcvOmOa8q9bjrtImha5NR4qWoQnYpmubsYqF(lvPCaz6bQS5Gm9265Xcc1hKeLakdkapuFqsucS4GPRcgaY(PNgCqOcLbfGhQpijkbwCW0vxckS1zxF2OMKBGkuguaEO(GKO5cBg6uLTmJfhm9PItucuLehc2rn9GNN5WovrkfD2pLu0p72HPJhOFkoeSJAuyNMoij(RSs2KiZbq(5ksyezm1zxFzqI(PcKKH(0enyVRedKdbppO3OMhli8xcUmJfhm9PItucuL0LGcBD21NnQj5gO5Wo1a0XEgnOAcnStxpVminzeOuDJaqjRcLMc(GPxMXIdM(uXjkbQsIdb7O2i)WWCyNAa6ypJgunHg2PRNxgKMO0iqP6gbGswfknf8btNiImcuQUraOKvDjOWwND9zJAsUbsrzgloy6tfNOeOkjsyezm1zxFzqI(zoStvK5ai)Cfhc2rTr(HHkqsg6ZFP2cmjYCaKFU6sqHTo76Zg1KCdufijd95VuBbMOKgS3vCiyh1cBoAq18ybH)svkhqMEGkor9LhPMKLrlS5ObNMOKYJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95VuBeaMezoaYpxXHGDuBKFyOcKKH(u(eifereLT64b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpLpbsbrejYCaKFUIdb7O2i)Wqfijd95VuBeauqrzgloy6tfNOeOkjuAk4dMU5Wo1dsIYNGLSPa0XEgnOAcnStxpVminjsPOZ(PKI(z3omzeOuDJaqjRIegrgtD21xgKOFLzS4GPpvCIsGQKqPPGpy6Md7upijkFcwYMcqh7z0GQj0WoD98YG0enyVR4qWoQf2C0GQ5Xcc)LQuoGm9avCI6lpsnjlJwyZrdonjYCaKFU6sqHTo76Zg1KCdufijd9jvjBsK5ai)Cfhc2rTr(HHkqsg6ZFP2iakZyXbtFQ4eLavjHstbFW0nh2PEqsu(eSKnfGo2ZObvtOHD665LbPjrMdG8ZvCiyh1g5hgQajzOpPkztusjLImha5NRUeuyRZU(Srnj3avbsYqFkFPCaz6bQydnjlJgahCBDpd9LhPjAWExXHGDulS5ObvZJfesLgS3vCiyh1cBoAqfjlJEESGqkiIikfzoaYpxDjOWwND9zJAsUbQcKKH(KQKnrd27koeSJAHnhnOAESGWFPkLditpqfNO(YJutYYOf2C0GtkOWenyVRcqh1zxBKFyOaYpNcZH(HraACAyNknyVRMqd701Zlds18ybHuPb7D1eAyNUEEzqQizz0ZJfeAo0pmcqJtdjjraiFivzlZyXbtFQ4eLavjfmaK9tpn4GqZHDQImha5NRUeuyRZU(Srnj3avbsYqF(lkdkapuFqs0eLuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LAJaWKiZbq(5koeSJAJ8ddvGKm0NYxkhqMEGQlpsnjlJgahCBDpdnBqbrerzRoEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUTUNHMnOGiIezoaYpxXHGDuBKFyOcKKH(8xQncakkZyXbtFQ4eLavjfmaK9tpn4GqZHDQImha5NR4qWoQnYpmubsYqF(lkdkapuFqs0eLusPiZbq(5Qlbf26SRpButYnqvGKm0NYxkhqMEGk2qtYYObWb3w3ZqF5rAIgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhliKcIiIsrMdG8ZvxckS1zxF2OMKBGQajzOpPkzt0G9UIdb7OwyZrdQMhli8xQs5aY0duXjQV8i1KSmAHnhn4Kckmrd27Qa0rD21g5hgkG8ZPOmJfhm9PItucuLeaYNnDgoAoStvK5ai)Cfhc2rTr(HHkqsg6tQs2eLusPiZbq(5Qlbf26SRpButYnqvGKm0NYxkhqMEGk2qtYYObWb3w3ZqF5rAIgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhliKcIiIsrMdG8ZvxckS1zxF2OMKBGQajzOpPkzt0G9UIdb7OwyZrdQMhli8xQs5aY0duXjQV8i1KSmAHnhn4Kckmrd27Qa0rD21g5hgkG8ZPOmJfhm9PItucuL0LGcBD21NnQj5gO5WovkPb7Dfhc2rTWMJgunpwq4VuLYbKPhOItuF5rQjzz0cBoAWjrezeOuDJaqjRkyai7NEAWbHuyIskpEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)sTraysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUTUNHMnOGiIOSvhpq)ubOJ6SRnYpmmjYCaKFUIdb7O2i)Wqfijd9P8LYbKPhO6YJutYYObWb3w3ZqZguqerImha5NR4qWoQnYpmubsYqF(l1gbafLzS4GPpvCIsGQK4qWoQnYpmmh2PsjLImha5NRUeuyRZU(Srnj3avbsYqFkFPCaz6bQydnjlJgahCBDpd9LhPjAWExXHGDulS5ObvZJfesLgS3vCiyh1cBoAqfjlJEESGqkiIikfzoaYpxDjOWwND9zJAsUbQcKKH(KQKnrd27koeSJAHnhnOAESGWFPkLditpqfNO(YJutYYOf2C0GtkOWenyVRcqh1zxBKFyOaYpVmJfhm9PItucuLua6Oo7AJ8ddZHDQ0G9UkaDuNDTr(HHci)CtusPiZbq(5Qlbf26SRpButYnqvGKm0NYxos2enyVR4qWoQf2C0GQ5XccPsd27koeSJAHnhnOIKLrppwqifereLImha5NRUeuyRZU(Srnj3avbsYqFsvYMOb7Dfhc2rTWMJgunpwq4VuLYbKPhOItuF5rQjzz0cBoAWjfuyIsrMdG8ZvCiyh1g5hgQajzOpLVSYHiIaqAWExDjOWwND9zJAsUbQanOOmJfhm9PItucuL00g2pO3OnYpmmh2PkYCaKFUIdb7OodAvGKm0NYNajIOwD8a9tXHGDuNbDzgloy6tfNOeOkjoeSJA6bppZHDQIuk6SFkcBhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2i)WqbAycaPb7DvWaq2p90Gdc1sbhogmnCaV2Q5XccPkVnzeOuDJaqjRIdb7OodAtS4Gsrn6ijeN)2AkZyXbtFQ4eLavjXHGDutZrWnO5WovrkfD2pfHTdi7Mcqh7z0GkoeSJABoitVTjAWExXHGDuBKFyOanmbG0G9Ukyai7NEAWbHAPGdhdMgoGxB18ybHuL3LzS4GPpvCIsGQK4qWoQPh88mh2PksPOZ(PiSDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjkbYtfmaK9tpn4GqvGKm0NYxEserainyVRcgaY(PNgCqOwk4WXGPHd41wbAqHjaKgS3vbdaz)0tdoiulfC4yW0Wb8ARMhli8x5TjwCqPOgDKeItQeCzgloy6tfNOeOkjoeSJ6mOnh2PksPOZ(PiSDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdoiulfC4yW0Wb8ARMhliKkbxMXIdM(uXjkbQsIdb7OMMJGBqZHDQIuk6SFkcBhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2i)WqbAycaPb7DvWaq2p90Gdc1sbhogmnCaV2Q5XccPkNYmwCW0NkorjqvsCiyh1OmgJCct3CyNQiLIo7NIW2bKDtbOJ9mAqfhc2rTnhKP32enyVR4qWoQnYpmuGgMmcuQUraOKJkyai7NEAWbHMyXbLIA0rsioLpbxMXIdM(uXjkbQsIdb7OgLXyKty6Md7ufPu0z)ue2oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTr(HHc0Weasd27QGbGSF6PbheQLcoCmyA4aETvZJfesvwtS4Gsrn6ijeNYNGlZyXbtFQ4eLavjze4eDbQZUMe6aMd7uPb7DfaYNnDgoQanmbG0G9U6sqHTo76Zg1KCdubAycaPb7D1LGcBD21NnQj5gOkqsg6ZFPsd27kJaNOlqD21KqhqrYYONhliSLZIdMUIdb7OMEWZtHYGcWd1hKenrjLhpq)ubotNDbAIfhukQrhjH48x5nfereloOuuJoscX5VeifMOSvbOJ9mAqfhc2rnDssZbaj6hreDC0GNYg5XzRmeN8jycKIYmwCW0NkorjqvsCiyh10dEEMd7uPb7DfaYNnDgoQanmrjLhpq)ubotNDbAIfhukQrhjH48x5nfereloOuuJoscX5VeifMOSvbOJ9mAqfhc2rnDssZbaj6hreDC0GNYg5XzRmeN8jycKIYmwCW0Nkorjqvstqdm8ukxMXIdM(uXjkbQsIdb7OMMJGBqZHDQ0G9UIdb7OwyZrdQMhliu(uPKfhukQrhjH4SLrwkmfGo2ZObvCiyh10jjnhaKOFMooAWtzJ84SvgI7xcMalZyXbtFQ4eLavjXHGDutZrWnO5WovAWExXHGDulS5ObvZJfesLgS3vCiyh1cBoAqfjlJEESGWYmwCW0NkorjqvsCiyh1zqBoStLgS3vCiyh1cBoAq18ybHuLSjkfzoaYpxXHGDuBKFyOcKKH(u(YsGeruROuKsrN9try7aYUPa0XEgnOIdb7O2MdY0BtbfLzS4GPpvCIsGQKC8SXqFiPbopZHDQugypWPntpqIiQvhuqi0BOWenyVR4qWoQf2C0GQ5XccPsd27koeSJAHnhnOIKLrppwqyzgloy6tfNOeOkjoeSJAs4Cch40CyNknyVRedKdbppO3OcKfNPa0XEgnOIdb7O2MdY0BBIskpEG(PysJbSdf8bt3eloOuuJoscX5VTakiIiwCqPOgDKeIZFjqkkZyXbtFQ4eLavjXHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mD8a9tXHGDuJc70easd27Qlbf26SRpButYnqfOHjkpEG(PysJbSdf8btNiIyXbLIA0rsio)Tfsrzgloy6tfNOeOkjoeSJAs4Cch40CyNknyVRedKdbppO3OcKfNPJhOFkM0ya7qbFW0nXIdkf1OJKqC(R8UmJfhm9PItucuLehc2rnkJXiNW0nh2Psd27koeSJAHnhnOAESGWFPb7Dfhc2rTWMJgurYYONhliSmJfhm9PItucuLehc2rnkJXiNW0nh2Psd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfeAYiqP6gbGswfhc2rnnhb3GLzS4GPpvCIsGQKqPPGpy6Md9dJa040Wovs2zLH4Kp1wabAo0pmcqJtdjjraiFivzlZkZyXbtFQe8qao4dM(KQuoGm9an3zsKQnlf1Pb6iG5Pb1jEMlLhGivznh2PkLditpqLnlf1Pb6iavjBYiqP6gbGswfknf8bt3uROmaDSNrdQMqd701ZldsIikaDSNrdQoK0idEO)4WGIYmwCW0NkbpeGd(GPpLavjjLditpqZDMePAZsrDAGocyEAqDIN5s5bisvwZHDQs5aY0duzZsrDAGocqvYMOb7Dfhc2rTr(HHci)CtImha5NR4qWoQnYpmubsYqFAIYa0XEgnOAcnStxpVmijIOa0XEgnO6qsJm4H(JddkkZyXbtFQe8qao4dM(ucuLKuoGm9an3zsKAh68qtdgU5Pb1jEMlLhGivznh2Psd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfeAQv0G9UkahOo76ZoqCQanm1Hn2Noqsg6ZFPsjLKSZYRfloy6koeSJA6bppLiNhfTCwCW0vCiyh10dEEkuguaEO(GKifLzeKALxGNng1Y12bhJ21opwqicuRnhKP3U2mQf61IYGcWdRnyVbR9dE21sSKKMdas0VYmwCW0NkbpeGd(GPpLavjjLditpqZDMePIKg5hgiGMMJGBqZtdQt8mxkparQ0G9UIdb7O2MdY0BRMhliu(uLLajIikdqh7z0GkoeSJA6KKMdas0pthhn4PSrEC2kdX9lbtGuuMXIdM(uj4HaCWhm9PeOkjPCaz6bAUZKi1bppnBObNO5ayNbhhvjBEAqDIN5WovAWExXHGDuBKFyOanmrPuoGm9avdEEA2qdorQsMiIoijkFQs5aY0dun45Pzdn4eLGSeifMlLhGi1dsILzeKABPqWowBRhjaSPDTnqP4SwUwPCaz6bwltMG(vB2RvaeMxln4v7h(FmQfCI1Y12h8vlopijFW0R1gduv7p2yTtiPOwJiLcbqGAdKKH(uJYyGIdbQfLXiW5eMETajoR1ZR2VmiS2pCmQTNrTgrcaBAxlaiw7L1E2yT0GX8AxRZhyG1M9ApBSwbqOkZyXbtFQe8qao4dM(ucuLKuoGm9an3zsKkopijFiGMn0Imha5NBEAqDIN5s5bisLsrMdG8ZvCiyh1g5hgkaWGpy6TCkLTLHsjRKmb3YfPdacpfhc2rTrKaWM2QGDcPGckAzO8GKylJuoGm9avdEEA2qdorkkZyXbtFQe8qao4dM(ucuLKuoGm9an3zsK6bjrnOFWHMnmpnOoXZCyNQiDaq4P4qWoQnIea202CP8aePkLditpqfopijFiGMn0Imha5NxMXIdM(uj4HaCWhm9PeOkjPCaz6bAUZKi1dsIAq)GdnByEAqDIN5Wo1wjshaeEkoeSJAJibGnTnxkparQImha5NR4qWoQnYpmubsYqFwMrqQvEa)pg1cGdUDTTuRxlOrTxwRCK8ef12ZO2FYRfxMXIdM(uj4HaCWhm9PeOkjPCaz6bAUZKi1dsIAq)GdnByEAqLKLXCP8aePkYCaKFU6sqHTo76Zg1KCdufijd9P5WovkfzoaYpxDjOWwND9zJAsUbQcKKH(SLrkhqMEGQdsIAq)GdnBqXVYrYLzeKATGUaRLGcKUDTWzTtqHDTCTg5hgDWrTxaDcXR2Eg1kV(2bKDZR9d)pg1opOGWAVS2ZgR9(YAjHo4H1kAlgyTG(bh1(H12GxTCT2Wg7ArpbBSRnyNWAZETgrcaBAxMXIdM(uj4HaCWhm9PeOkjPCaz6bAUZKi1dsIAq)GdnByEAqLKLXCP8aePEb0jep1mbhd8oO3Odq62krMdG8ZvbsYqFAoStvKoai8uCiyh1grcaBABsKoai8uCiyh1grcaBARc2j8xc0e2IaHggiGAMGJbEh0B0biDBtIuk6SFkcBhq2nfGo2ZObvCiyh12CqME7YmcsTYd4)XOwaCWTR9N8AX1cAu7L1khjprrT9mQTLA9YmwCW0NkbpeGd(GPpLavjjLditpqZDMePANdaO3OV8inpnOoXZCP8aePkYCaKFU6sqHTo76Zg1KCdufid02KuoGm9avhKe1G(bhA24x5i5YmcsTeumaK9RwldoiSwGeN165vlKKebG8HJ21AaE1cAu7zJ1kfC4yW0Wb8Axlasd271oZAHxTc2RLgRfa27qb44Q9YAbGtbgETNnF1(H)dSw(Q9SXAjOHrE21kfC4yW0Wb8Ax78ybHLzS4GPpvcEiah8btFkbQsskhqMEGM7mjsTLfCEAWjcONgCqO5Pb1jEMlLhGivkncuQUraOKvfmaK9tpn4GqIiYiqP6gbGsoQGbGSF6Pbhesergbkv3iaueSkyai7NEAWbHuycaPb7DvWaq2p90Gdc1sbhogmnCaV2kG8ZlZyXbtFQe8qao4dM(ucuLKuoGm9an3zsKAcEtiaQZUwK5ai)8P5Pb1jEMlLhGivAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfq(5MALuoGm9avTSGZtdora90GdcnbG0G9Ukyai7NEAWbHAPGdhdMgoGxBfq(5LzS4GPpvcEiah8btFkbQsskhqMEGM7mjsDESGqTnhKP3280G6epZLYdqKAa6ypJguXHGDuBZbz6TnrjLIuk6SFkcBhq2njYCaKFUkyai7NEAWbHQajzOp)vkhqMEGkBoitVTEESGq9bjrkOOmRmJGuBRhWmGhKGgwl4e6n12eW5ODTqbumWA)GNDTSHQw5Xjwl8Q9dE21E5rwBE2y8bNOQmJfhm9PsK5ai)8j1EKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAsK5ai)Cfhc2rTr(HHkqsg6t5tWs2KiZbq(5Qlbf26SRpButYnqvGmqBtusd27koeSJAHnhnOAESGWFPkLditpq1LhPMKLrlS5ObNMOKYJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95VuBeaMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4GBR7zOzdkiIikB1Xd0pva6Oo7AJ8ddtImha5NR4qWoQnYpmubsYqFkFPCaz6bQU8i1KSmAaCWT19m0SbferKiZbq(5koeSJAJ8ddvGKm0N)sTraqbfLzS4GPpvImha5NpLavj1JCEApLYMd7udqh7z0GQMaohT1qbumqtImha5NR4qWoQnYpmubYaTnrzRoEG(PqFaBSp0raIiIYJhOFk0hWg7dDeWej7SYqCYNARrYuqHjkPuK5ai)C1LGcBD21NnQj5gOkqsg6t5lRKnrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfesbrerPiZbq(5Qlbf26SRpButYnqvGKm0NuLSjAWExXHGDulS5ObvZJfesvYuqHjAWExfGoQZU2i)WqbKFUjs2zLH4KpvPCaz6bQydnj0HKGKAs2zTH4kZyXbtFQezoaYpFkbQsQh58OZXzoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b09iNNci)Ctusd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MaqAWExDjOWwND9zJAsUbQaYpNctImha5NRUeuyRZU(Srnj3avbsYqFsvYMOKgS3vCiyh1cBoAq18ybH)svkhqMEGQlpsnjlJwyZrdonrjLhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6ZFP2iamjYCaKFUIdb7O2i)Wqfijd9P8LYbKPhO6YJutYYObWb3w3ZqZguqeru2QJhOFQa0rD21g5hgMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4GBR7zOzdkiIirMdG8ZvCiyh1g5hgQajzOp)LAJaGckkZyXbtFQezoaYpFkbQsQddutp45zoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b0DyGkG8ZnzeOuDJaqjRQh58OZXvMrqQT1zyuBlo)P2p4zxBl161c71cV)ZAfjj0BQf0O2zMUQ2wBVw4v7hCmQLgRfCIa1(bp7A)jVwS51k45vl8QDoGn23ODT0ypdSmJfhm9PsK5ai)8PeOkjsyezm1zxFzqI(zoStLYwfGo2ZObvtOHD665Lbjrerd27Qj0WoD98YGubAqHjrMdG8ZvxckS1zxF2OMKBGQajzOp)vkhqMEGkY80gbkqeqF5rQPBterukLditpq1bjrnOFWHMnKVuoGm9avK5Pjzz0a4GBR7zOzdtImha5NRUeuyRZU(Srnj3avbsYqFkFPCaz6bQiZttYYObWb3w3ZqF5rsrzgloy6tLiZbq(5tjqvsKWiYyQZU(YGe9ZCyNQiZbq(5koeSJAJ8ddvGmqBtu2QJhOFk0hWg7dDeGiIO84b6Nc9bSX(qhbmrYoRmeN8P2AKmfuyIskfzoaYpxDjOWwND9zJAsUbQcKKH(u(s5aY0duXgAswgnao426Eg6lpst0G9UIdb7OwyZrdQMhliKknyVR4qWoQf2C0Gkswg98ybHuqerukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybHuLmfuyIgS3vbOJ6SRnYpmua5NBIKDwzio5tvkhqMEGk2qtcDijiPMKDwBiUYmwCW0NkrMdG8ZNsGQK6dCAlcUFMd7uLYbKPhOkbVjea1zxlYCaKF(0eLZeCqdDaL0CWhCG6zoKI(rerZeCqdDaLb48ahOgdqJdMofLzeKABPXh3Ewl4eRfa5ZModhR9dE21YgQABT9AV8iRfoRnqgODT8S2pCmmVwsMqS2jyG1EzTcEE1cVAPXEgyTxEKQYmwCW0NkrMdG8ZNsGQKaq(SPZWrZHDQImha5NRUeuyRZU(Srnj3avbYaTnrd27koeSJAHnhnOAESGWFPkLditpq1LhPMKLrlS5ObNMezoaYpxXHGDuBKFyOcKKH(8xQncGYmwCW0NkrMdG8ZNsGQKaq(SPZWrZHDQImha5NR4qWoQnYpmubYaTnrzRoEG(PqFaBSp0raIiIYJhOFk0hWg7dDeWej7SYqCYNARrYuqHjkPuK5ai)C1LGcBD21NnQj5gOkqsg6t5lRKnrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfesbrerPiZbq(5Qlbf26SRpButYnqvGmqBt0G9UIdb7OwyZrdQMhliKQKPGct0G9UkaDuNDTr(HHci)CtKSZkdXjFQs5aY0duXgAsOdjbj1KSZAdXvMrqQvECI1on4GWAH9AV8iRLDGAzJA5aRn9Afa1YoqTFP))QLgRf0O2Eg1osVbJApB2R9SXAjzzQfahCBZRLKje6n1obdS2pSwBwkwlF1oqEE1EFzTCiyhRvyZrdoRLDGApB(Q9YJS2pE6)VABzbNxTGteqvMXIdM(ujYCaKF(ucuLuWaq2p90Gdcnh2PkYCaKFU6sqHTo76Zg1KCdufijd9P8LYbKPhOkMAswgnao426Eg6lpstImha5NR4qWoQnYpmubsYqFkFPCaz6bQIPMKLrdGdUTUNHMnmr5Xd0pva6Oo7AJ8ddtukYCaKFUkaDuNDTr(HHkqsg6ZFrzqb4H6dsIerKiZbq(5Qa0rD21g5hgQajzOpLVuoGm9avXutYYObWb3w3ZqhPbferuRoEG(Pcqh1zxBKFyqHjAWExXHGDulS5ObvZJfekF5ycaPb7D1LGcBD21NnQj5gOci)Ct0G9UkaDuNDTr(HHci)Ct0G9UIdb7O2i)WqbKFEzgbPw5Xjw70GdcR9dE21Yg1(zJETg5CcPhOQ2wBV2lpYAHZAdKbAxlpR9dhdZRLKjeRDcgyTxwRGNxTWRwASNbw7LhPQmJfhm9PsK5ai)8PeOkPGbGSF6PbheAoStvK5ai)C1LGcBD21NnQj5gOkqsg6ZFrzqb4H6dsIMOb7Dfhc2rTWMJgunpwq4VuLYbKPhO6YJutYYOf2C0GttImha5NR4qWoQnYpmubsYqF(lLOmOa8q9bjrjWIdMU6sqHTo76Zg1KCduHYGcWd1hKePOmJfhm9PsK5ai)8PeOkPGbGSF6PbheAoStvK5ai)Cfhc2rTr(HHkqsg6ZFrzqb4H6dsIMOKYwD8a9tH(a2yFOJaereLhpq)uOpGn2h6iGjs2zLH4Kp1wJKPGctusPiZbq(5Qlbf26SRpButYnqvGKm0NYxkhqMEGk2qtYYObWb3w3ZqF5rAIgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhliKcIiIsrMdG8ZvxckS1zxF2OMKBGQajzOpPkzt0G9UIdb7OwyZrdQMhliKQKPGct0G9UkaDuNDTr(HHci)CtKSZkdXjFQs5aY0duXgAsOdjbj1KSZAdXrrzgbPw5Xjw7LhzTFWZUw2OwyVw49Fw7h8SHETNnwljltTa4GBRQT12R1ZZ8AbNyTFWZU2inQf2R9SXApEG(vlCw7XeIU51YoqTW7)S2p4zd9ApBSwswMAbWb3wvMXIdM(ujYCaKF(ucuL0LGcBD21NnQj5gO5WovkBva6ypJgunHg2PRNxgKerenyVRMqd701ZldsfObfMOb7Dfhc2rTWMJgunpwq4VuLYbKPhO6YJutYYOf2C0GttImha5NR4qWoQnYpmubsYqF(lvuguaEO(GKOjs2zLH4KVuoGm9avSHMe6qsqsnj7S2qCMOb7Dva6Oo7AJ8ddfq(5LzS4GPpvImha5NpLavjDjOWwND9zJAsUbAoStLgS3vCiyh1cBoAq18ybH)svkhqMEGQlpsnjlJwyZrdonD8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LkkdkapuFqs0KuoGm9avhKe1G(bhA2q(s5aY0duD5rQjzz0a4GBR7zOzJYmwCW0NkrMdG8ZNsGQKUeuyRZU(Srnj3anh2Psd27koeSJAHnhnOAESGWFPkLditpq1LhPMKLrlS5ObNMOSvhpq)ubOJ6SRnYpmiIirMdG8ZvbOJ6SRnYpmubsYqFkFPCaz6bQU8i1KSmAaCWT19m0rAqHjPCaz6bQoijQb9do0SH8LYbKPhO6YJutYYObWb3w3ZqZgLzeKALhNyTSrTWETxEK1cN1METcGAzhO2V0)F1sJ1cAuBpJAhP3GrTNn71E2yTKSm1cGdUT51sYec9MANGbw7zZxTFyT2SuSw0tWg7AjzNRLDGApB(Q9SXaRfoR1ZRwEeid0UwU2a0XAZETg5hg1cKFUQmJfhm9PsK5ai)8PeOkjoeSJAJ8ddZHDQImha5NRUeuyRZU(Srnj3avbsYqFkFPCaz6bQydnjlJgahCBDpd9LhPjkBLiLIo7Nsk6ND7GiIezoaYpxrcJiJPo76lds0pvGKm0NYxkhqMEGk2qtYYObWb3w3ZqtMhfMOb7Dfhc2rTWMJgunpwqivAWExXHGDulS5ObvKSm65Xccnrd27Qa0rD21g5hgkG8ZnrYoRmeN8PkLditpqfBOjHoKeKutYoRnexzgbPw5XjwBKg1c71E5rwlCwB61kaQLDGA)s))vlnwlOrT9mQDKEdg1E2Sx7zJ1sYYulao42Mxljti0BQDcgyTNngyTWP))QLhbYaTRLRnaDSwG8ZRLDGApB(QLnQ9l9)xT0OijXAzPmCW0dSwaWa6n1gGoQkZyXbtFQezoaYpFkbQskaDuNDTr(HH5WovAWExXHGDuBKFyOaYp3eLImha5NRUeuyRZU(Srnj3avbsYqFkFPCaz6bQI0qtYYObWb3w3ZqF5rserImha5NR4qWoQnYpmubsYqF(lvPCaz6bQU8i1KSmAaCWT19m0SbfMOb7Dfhc2rTWMJgunpwqivAWExXHGDulS5ObvKSm65XccnjYCaKFUIdb7O2i)Wqfijd9P8LvYMezoaYpxDjOWwND9zJAsUbQcKKH(u(Yk5YmwCW0NkrMdG8ZNsGQKM2W(b9gTr(HH5WovPCaz6bQsWBcbqD21Imha5NplZii1kpoXAnsYAVS2zlcercAyTSxlkZfCTmDTqV2ZgR1rzUAfzoaYpV2pOdKFMxlOpW5SwcBhq2R9SrV20hTRfamGEtTCiyhR1i)WOwaqS2lR1o)QLKDUwBqVjAxBWaq2VANgCqyTWzzgloy6tLiZbq(5tjqvsgborxG6SRjHoG5Wo1JhOFQa0rD21g5hgMOb7Dfhc2rTr(HHc0WenyVRcqh1zxBKFyOcKKH(83gbGIKLPmJfhm9PsK5ai)8PeOkjJaNOlqD21KqhWCyNkasd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)LfhmDfhc2rnjCoHdCQqzqb4H6dsIMALiLIo7NIW2bK9YmwCW0NkrMdG8ZNsGQKmcCIUa1zxtcDaZHDQ0G9UkaDuNDTr(HHc0WenyVRcqh1zxBKFyOcKKH(83gbGIKLXKiZbq(5kuAk4dMUkqgOTjrMdG8ZvxckS1zxF2OMKBGQajzOpn1krkfD2pfHTdi7LzLzS4GPpvDOZdnny4u5qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMlSzOtv2YmwCW0NQo05HMgmCjqvsCiyh10dEELzS4GPpvDOZdnny4sGQK4qWoQP5i4gSmRmJGuR8Gn61gGUd9MAr4zJrTNnwRLvTzu7pYd1oWg0b4aItZR9dR9J9R2lRvErAwln2ZaR9SXA)jVwSKAPwV2pOdKFQALhNyTWRwEw7mtVwEwlbv261AZZA7qhoTrGAtWO2p8VuS2Pb6xTjyuRWMJgCwMXIdM(u1HtBO3Otd0XGkknf8bt3CyNkLbOJ9mAq1HKgzWd9hhgereLbOJ9mAq1eAyNUEEzqAQvs5aY0duzeOb4yOrPjvzPGctusd27Qa0rD21g5hgkG8ZjIiJaLQBeakzvCiyh10CeCdsHjrMdG8ZvbOJ6SRnYpmubsYqFwMrqQT12R9d)lfRTdD40gbQnbJAfzoaYpV2pOdKFZAzhO2Pb6xTjyuRWMJgCAETgbmd4bjOH1kVinRnLIrTOumAF2qVPwCmXYmwCW0NQoCAd9gDAGogsGQKqPPGpy6Md7upEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0NMezoaYpxXHGDuBKFyOcKKH(0enyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBYiqP6gbGswfhc2rnnhb3GLzS4GPpvD40g6n60aDmKavj1HbQPh88mh2PgGo2ZObvaWPaAmGohT1IKKKDat0G9UcaofqJb05OTwKKKSdO7ropfOrzgloy6tvhoTHEJonqhdjqvs9iNN2tPS5Wo1a0XEgnOQjGZrBnuafd0ej7SYqCYVfsGLzS4GPpvD40g6n60aDmKavjXHGDutcNt4aNMd7udqh7z0GkoeSJABoitVTjAWExXHGDuBZbz6TvZJfe(lnyVR4qWoQT5Gm92kswg98ybHMOKsAWExXHGDuBKFyOaYp3KiZbq(5koeSJAJ8ddvGmqBkiIiaKgS3vxckS1zxF2OMKBGkqdkmxyZqNQSLzS4GPpvD40g6n60aDmKavjfGoQZU2i)WWCyNAa6ypJgunHg2PRNxgKLzS4GPpvD40g6n60aDmKavjXHGDuNbT5WovrMdG8ZvbOJ6SRnYpmubYaTlZyXbtFQ6WPn0B0Pb6yibQsIdb7OMEWZZCyNQiZbq(5Qa0rD21g5hgQazG2MOb7Dfhc2rTWMJgunpwq4V0G9UIdb7OwyZrdQizz0ZJfewMXIdM(u1HtBO3Otd0XqcuLeaYNnDgoAoStTvbOJ9mAq1HKgzWd9hhgerKiDaq4PAG9tND9zJ6buyxMXIdM(u1HtBO3Otd0XqcuLua6Oo7AJ8dJYmcsTT2ETF4)aRLVAjzzQDESGWzTzVwcGaQLDGA)WATzPO))QfCIa12IZFQTnEMxl4eRLRDESGWAVSwJaLI(vljOlSHEtTG(aNZAdq3HEtTNnwR8QCqME7Ahyd6aC0UmJfhm9PQdN2qVrNgOJHeOkjoeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjAWExjgihcEEqVrnpwqivAWExjgihcEEqVrrYYONhli0KiLIo7Nsk6ND7WKiZbq(5ksyezm1zxFzqI(PcKbABQvs5aY0duHKg5hgiGMMJGBqtImha5NR4qWoQnYpmubYaTlZii1kXmi5XODTFyTgmmQ1ipy61coXA)GNDTTuRBET0GxTWR2p4yu7GNxTJ0BQf9eSXU2Eg1sNNDTNnwlbv261YoqTTuRx7h0bYVzTG(aNZAdq3HEtTNnwRLvTzu7pYd1oWg0b4aIZYmwCW0NQoCAd9gDAGogsGQKmYdMU5Wo1wfGo2ZObvhsAKbp0FCyyIYwfGo2ZObvtOHD665LbjrerPuoGm9avgbAaogAuAsvwt0G9UIdb7OwyZrdQMhliKknyVR4qWoQf2C0Gkswg98ybHuqrzgloy6tvhoTHEJonqhdjqvsaiF20z4O5WovAWExfGoQZU2i)WqbKForezeOuDJaqjRIdb7OMMJGBWYmwCW0NQoCAd9gDAGogsGQKcgaY(PNgCqO5WovAWExfGoQZU2i)WqbKForezeOuDJaqjRIdb7OMMJGBWYmwCW0NQoCAd9gDAGogsGQKiHrKXuND9Lbj6N5WovAWExfGoQZU2i)Wqfijd95VukpLGCA5bOJ9mAq1eAyNUEEzqsrzgbPw5bB0RnaDh6n1E2yTYRYbz6TRDGnOdWrBZRfCI12sTET0ypdS2FYRfx7L1casAulxBhCmAx78ybHiqT0CWrdwMXIdM(u1HtBO3Otd0XqcuLehc2rTr(HH5WovPCaz6bQqsJ8ddeqtZrWnOjAWExfGoQZU2i)WqbAyIss2zLH4(Ls5qGsGszLClxKsrN9try7aYofuqer0G9Usmqoe88GEJAESGqQ0G9Usmqoe88GEJIKLrppwqifLzS4GPpvD40g6n60aDmKavjXHGDutZrWnO5WovPCaz6bQqsJ8ddeqtZrWnOjAWExXHGDulS5ObvZJfesLgS3vCiyh1cBoAqfjlJEESGqt0G9UIdb7O2i)WqbAuMXIdM(u1HtBO3Otd0XqcuL0LGcBD21NnQj5gO5WovAWExfGoQZU2i)WqbKForezeOuDJaqjRIdb7OMMJGBqIiYiqP6gbGswvWaq2p90GdcjIikncuQUraOKvbG8ztNHJMAva6ypJgunHg2PRNxgKuuMXIdM(u1HtBO3Otd0XqcuLehc2rTr(HH5WovJaLQBeakzvxckS1zxF2OMKBGLzeKALhNyTTE2IR9YANTiqejOH1YETOmxW12sHGDSwIn45vlaya9MApBS2FYRflPwQ1R9d6a5xTG(aNZAdq3HEtTTuiyhRvEryNQABT9ABPqWowR8IWoRfoR94b6hcyETFyTc2)F1coXAB9Sfx7h8SHETNnw7p51ILul161(bDG8RwqFGZzTFyTq)WianUApBS2wQfxRWMDhhMx7mR9d)pg1ozPyTWtvMXIdM(u1HtBO3Otd0XqcuLKrGt0fOo7AsOdyoStTvhpq)uCiyh1OWonbG0G9U6sqHTo76Zg1KCdubAycaPb7D1LGcBD21NnQj5gOkqsg6ZFPsjloy6koeSJA6bppfkdkapuFqsSLtd27kJaNOlqD21KqhqrYYONhliKIYmcsTT2ETTE2IR1MN()RwAe9AbNiqTaGb0BQ9SXA)jVwCTFqhi)mV2p8)yul4eRfE1EzTZweiIe0WAzVwuMl4ABPqWowlXg88Qf61E2yTeuzRlPwQ1R9d6a5NQmJfhm9PQdN2qVrNgOJHeOkjJaNOlqD21KqhWCyNknyVR4qWoQnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)sLswCW0vCiyh10dEEkuguaEO(GKylNgS3vgborxG6SRjHoGIKLrppwqifLzS4GPpvD40g6n60aDmKavjXHGDutp45zoStfipvWaq2p90GdcvbsYqFkFcKiIaqAWExfmaK9tpn4GqTuWHJbtdhWRTAESGq5l5YmcsTYdyTFSF1EzTKmHyTtWaR9dR1MLI1IEc2yxlj7CT9mQ9SXAr)GbwBl161(bDG8Z8ArPOxlSx7zJb(Fw78GJrThKeRnqsg6qVP20RLGkBDvTT27)S20hTRLgVdJAVSwAWWR9YAjOHrwl7a1kVinRf2RnaDh6n1E2yTww1MrT)ipu7aBqhGdiovLzS4GPpvD40g6n60aDmKavjXHGDutZrWnO5WovrMdG8ZvCiyh1g5hgQazG2MizNvgI7xkL3swcukRKB5Iuk6SFkcBhq2PGct0G9UIdb7OwyZrdQMhliKknyVR4qWoQf2C0Gkswg98ybHMOSvbOJ9mAq1eAyNUEEzqsers5aY0duzeOb4yOrPjvzPWuRcqh7z0GQdjnYGh6pomm1Qa0XEgnOIdb7O2MdY0BxMrqQLyCeCdw70obha165vlnwl4ebQLVApBSw0bQn712sTETWETYlstbFW0RfoRnqgODT8SwGinmGEtTcBoAWzTFWXOwsMqSw4v7XeI1osVbJAVSwAWWR9SJeSXU2ajzOd9MAjzNlZyXbtFQ6WPn0B0Pb6yibQsIdb7OMMJGBqZHDQ0G9UIdb7O2i)WqbAyIgS3vCiyh1g5hgQajzOp)LAJaWKiZbq(5kuAk4dMUkqsg6ZYmcsTeJJGBWAN2j4aOwE8XTN1sJ1E2yTdEE1k45vl0R9SXAjOYwV2pOdKF1YZA)jVwCTFWXO2aNxgyTNnwRWMJgCw70a9RmJfhm9PQdN2qVrNgOJHeOkjoeSJAAocUbnh2Psd27Qa0rD21g5hgkqdt0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)Wqfijd95VuBeaMAva6ypJguXHGDuBZbz6TlZyXbtFQ6WPn0B0Pb6yibQsIdb7OMeoNWbonh2PcG0G9U6sqHTo76Zg1KCdubAy64b6NIdb7Ogf2PjkPb7DfaYNnDgoQaYpNiIyXbLIA0rsioPklfMaqAWExDjOWwND9zJAsUbQcKKH(u(S4GPR4qWoQjHZjCGtfkdkapuFqs0CHndDQYAoYXOTwyZqxd7uPb7DLyGCi45b9gTWMDhhkG8ZnrjnyVR4qWoQnYpmuGgereLT64b6NkLIHr(HbcyIsAWExfGoQZU2i)WqbAqerImha5NRqPPGpy6QazG2uqbfLzeKABT9A)W)bwRu0p72H51cjjraiF4ODTGtSwcGaQ9Zg9AfSHbcu7L165v7hppSwJifZA7rswBlo)PmJfhm9PQdN2qVrNgOJHeOkjoeSJAs4Cch40CyNQiLIo7Nsk6ND7WenyVRedKdbppO3OMhliKknyVRedKdbppO3Oizz0ZJfewMrqQ1644QfCc9MAjacO2wQfx7Nn612sTET28SwAe9AbNiqzgloy6tvhoTHEJonqhdjqvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilotImha5NR4qWoQnYpmubsYqFAIsAWExfGoQZU2i)WqbAqer0G9UIdb7O2i)WqbAqH5cBg6uLTmJfhm9PQdN2qVrNgOJHeOkjoeSJ6mOnh2Psd27koeSJAHnhnOAESGWFPkLditpq1LhPMKLrlS5ObNLzS4GPpvD40g6n60aDmKavjXHGDutp45zoStLgS3vbOJ6SRnYpmuGgerej7SYqCYxwcSmJfhm9PQdN2qVrNgOJHeOkjuAk4dMU5WovAWExfGoQZU2i)WqbKFUjAWExXHGDuBKFyOaYp3COFyeGgNg2PsYoRmeN8P2ciqZH(HraACAijjca5dPkBzgloy6tvhoTHEJonqhdjqvsCiyh10CeCdwMvMrqii1kp6tqdJmoeOwb7cCOzXbtxETRvErAk4dMETFWXOwASwNpWGhJ21shjHOxlSxRiDa4btFwlhyTK4PkZiieKAzXbtFQS5Gm92ufSlWHMfhmDZHDQS4GPRqPPGpy6kHn7ooGEJjs2zLH4Kp1wibwMrqQT12RDKF1METKSZ1YoqTImha5NpRLdSwrsc9MAbnmV2MSw2gzGAzhOwuAwMXIdM(uzZbz6TLavjHstbFW0nh2PsYoRme3VujyjBskhqMEGQe8MqauNDTiZbq(5ttuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)vwjtrzgbPw5bS2p2VAVS25XccR1MdY0BxBhCmARQ9hBSwWjwB2Rvw5zTZJfeoR1gdSw4S2lRLfIe0VA7zu7zJ1EqbH1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uLzS4GPpv2CqMEBjqvsCiyh1KW5eoWP5WovkLYbKPhOAESGqTnhKP3MiIoij(RSsMct0G9UIdb7O2MdY0BRMhli8xzLNMlSzOtv2YmcsTYd2Oxl4e6n1kVqA0oqEulb9aWzxGMxRGNxTCTD8RwuMl4AjHZjCGZA)SHdS2pgEqVP2Eg1E2yT0G9ET8v7zJ1opoUAZETNnwBh2yFLzS4GPpv2CqMEBjqvsCiyh1KW5eoWP5WovSfbcnmqafsA0oqEOZaWzxGMoij(lblztx20mqLiZbq(5ttImha5NRqsJ2bYdDgao7cufijd9P8LvE2cm1kwCW0viPr7a5HodaNDbQaGtMEGaLzS4GPpv2CqMEBjqvsbdaz)0tdoi0CyNQuoGm9aviPr(HbcOP5i4g0KiZbq(5Qlbf26SRpButYnqvGKm0N)sfLbfGhQpijAsK5ai)Cfhc2rTr(HHkqsg6ZFPsjkdkapuFqsSLlhkmrzRWwei0WabuZeCmW7GEJoaPBterI0baHNIdb7O2isaytBvWoHYNkbserxaDcXtntWXaVd6n6aKUTsK5ai)CvGKm0N)sLsuguaEO(GKylxouqrzgloy6tLnhKP3wcuL0LGcBD21NnQj5gO5WovPCaz6bQAzbNNgCIa6PbheAsK5ai)Cfhc2rTr(HHkqsg6ZFPIYGcWd1hKenrzRWwei0WabuZeCmW7GEJoaPBterI0baHNIdb7O2isaytBvWoHYNkbserxaDcXtntWXaVd6n6aKUTsK5ai)CvGKm0N)sfLbfGhQpijsrzgloy6tLnhKP3wcuLehc2rTr(HH5WovJaLQBeakzvxckS1zxF2OMKBGLzS4GPpv2CqMEBjqvsbOJ6SRnYpmmh2PkLditpqfsAKFyGaAAocUbnjYCaKFUkyai7NEAWbHQajzOp)LkkdkapuFqs0KuoGm9avhKe1G(bhA2q(uLJKnrzRePdacpfhc2rTrKaWM2eruRKYbKPhOIhFC7PE22fArMdG8ZNerKiZbq(5Qlbf26SRpButYnqvGKm0N)sLsuguaEO(GKylxouqrzgloy6tLnhKP3wcuLuWaq2p90Gdcnh2PkLditpqfsAKFyGaAAocUbnzeOuDJaqjRkaDuNDTr(Hrzgloy6tLnhKP3wcuL0LGcBD21NnQj5gO5WovPCaz6bQAzbNNgCIa6PbheAQvs5aY0duzNdaO3OV8ilZii1kpoXALJdulhc2XAP5i4gSwOxBl16sGGIGERxB6J21c71sSrMadW5vl7a1YxTdKNxTYPwcGaM1AePqGaLzS4GPpv2CqMEBjqvsCiyh10CeCdAoStLgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhli0enyVRcqh1zxBKFyOanmrd27koeSJAJ8ddfOHjAWExXHGDuBZbz6TvZJfekFQYkpnrd27koeSJAJ8ddvGKm0N)sLfhmDfhc2rnnhb3GkuguaEO(GKOjAWExrpYeyaopfOrzgbPw5XjwRCCGAjOYwVwOxBl161M(ODTWETeBKjWaCE1YoqTYPwcGaM1AePOmJfhm9PYMdY0BlbQskaDuNDTr(HH5WovAWExfGoQZU2i)WqbKFUjAWExrpYeyaopfOHjkLYbKPhO6GKOg0p4qZgYNGLmrejYCaKFUkyai7NEAWbHQajzOpLVSYHctusd27koeSJABoitVTAESGq5tvwcKiIOb7DLyGCi45b9g18ybHYNQSuyIYwjshaeEkoeSJAJibGnTjIOwjLditpqfp(42t9STl0Imha5NpPOmJfhm9PYMdY0BlbQskaDuNDTr(HH5WovAWExXHGDuBKFyOaYp3eLs5aY0duDqsud6hCOzd5tWsMiIezoaYpxfmaK9tpn4GqvGKm0NYxw5qHjkBLiDaq4P4qWoQnIea20MiIALuoGm9av84JBp1Z2UqlYCaKF(KIYmwCW0NkBoitVTeOkPGbGSF6PbheAoStvkhqMEGkK0i)Wab00CeCdAIsAWExXHGDulS5ObvZJfekFQYHiIezoaYpxXHGDuNbTkqgOnfMOSvhpq)ubOJ6SRnYpmiIirMdG8ZvbOJ6SRnYpmubsYqFkFcKcts5aY0duHZdsYhcOzdTiZbq(5YNkblztu2kr6aGWtXHGDuBejaSPnre1kPCaz6bQ4Xh3EQNTDHwK5ai)8jfLzeKALhSrV2a0DO3uRrKaWM2Mxl4eR9YJSw621cVjo61c9AZaaJAVSwEaB8AHxTFWZUw2OmJfhm9PYMdY0BlbQs6sqHTo76Zg1KCd0CyNQuoGm9avhKe1G(bhA24xcuYMKYbKPhO6GKOg0p4qZgYNGLSjkBf2IaHggiGAMGJbEh0B0biDBIisKoai8uCiyh1grcaBARc2ju(ujqkkZyXbtFQS5Gm92sGQK4qWoQZG2CyNQuoGm9avTSGZtdora90Gdcnrd27koeSJAHnhnOAESGWFPb7Dfhc2rTWMJgurYYONhliSmJfhm9PYMdY0BlbQsIdb7OMMJGBqZHDQainyVRcgaY(PNgCqOwk4WXGPHd41wnpwqivaKgS3vbdaz)0tdoiulfC4yW0Wb8ARizz0ZJfewMXIdM(uzZbz6TLavjXHGDutp45zoStvkhqMEGQwwW5PbNiGEAWbHereLainyVRcgaY(PNgCqOwk4WXGPHd41wbAycaPb7DvWaq2p90Gdc1sbhogmnCaV2Q5Xcc)faPb7DvWaq2p90Gdc1sbhogmnCaV2kswg98ybHuuMrqQvECI1scDyTeJJGBWAPX7drV2GbGSF1on4GWzTWETGoag1smIR2p4zNGxTa4GBd9MAjOyai7xTwgCqyTqaKhJ2LzS4GPpv2CqMEBjqvsCiyh10CeCdAoStLgS3vbOJ6SRnYpmuGgMOb7Dfhc2rTr(HHci)Ct0G9UIEKjWaCEkqdtImha5NRcgaY(PNgCqOkqsg6ZFPkRKnrd27koeSJABoitVTAESGq5tvw5zzgbPw5XjwBg01METcGAb9boN1Yg1cN1kssO3ulOrTZm9YmwCW0NkBoitVTeOkjoeSJ6mOnh2Psd27koeSJAHnhnOAESGWFjyts5aY0duDqsud6hCOzd5lRKnrPiZbq(5Qlbf26SRpButYnqvGKm0NYNajIOwjshaeEkoeSJAJibGnTPOmJfhm9PYMdY0BlbQsIdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXzIgS3vCiyh1g5hgkqdZf2m0PkBzgbP2wBV2pS2g8Q1i)WOwO3bNW0RfamGEtTdW5v7h(FmQ1MLI1IEc2yxRnppS2lRTbVAZEVwU25fP3ulnhb3G1cagqVP2ZgRnsdjXg1(bDG8RmJfhm9PYMdY0BlbQsIdb7OMMJGBqZHDQ0G9UkaDuNDTr(HHc0WenyVRcqh1zxBKFyOcKKH(8xQS4GPR4qWoQjHZjCGtfkdkapuFqs0enyVR4qWoQnYpmuGgMOb7Dfhc2rTWMJgunpwqivAWExXHGDulS5ObvKSm65Xccnrd27koeSJABoitVTAESGqt0G9UYi)Wqd9o4eMUc0WenyVROhzcmaNNc0OmJGuBRTx7hwBdE1AKFyul07Gty61cagqVP2b48Q9d)pg1AZsXArpbBSR1MNhw7L12GxTzVxlx78I0BQLMJGBWAbadO3u7zJ1gPHKyJA)Goq(zETZS2p8)yuB6J21coXArpbBSRLEWZBwl0HhKhJ21EzTn4v7L12tWOwHnhn4SmJfhm9PYMdY0BlbQsIdb7OMEWZZCyNknyVRmcCIUa1zxtcDafOHjkPb7Dfhc2rTWMJgunpwq4V0G9UIdb7OwyZrdQizz0ZJfeserTIsAWExzKFyOHEhCctxbAyIgS3v0JmbgGZtbAqbfLzeKA)XgRLgNxTGtS2SxRrswlCw7L1coXAHxTxwBlcekiC0UwAq4aOwHnhn4SwaWa6n1Yg1Y9dJApBSDTn4vlaiPbculD7ApBSwBoitVDT0CeCdwMXIdM(uzZbz6TLavjze4eDbQZUMe6aMd7uPb7Dfhc2rTWMJgunpwq4V0G9UIdb7OwyZrdQizz0ZJfeAIgS3vCiyh1g5hgkqJYmcsTYdyTFSF1EzTZJfewRnhKP3U2o4y0wv7p2yTGtS2SxRSYZANhliCwRngyTWzTxwllejOF12ZO2ZgR9GccRDG9R20R9SXAf2S74Ow2bQ9SXAjHZjCG1c9A7dyJ9PkZyXbtFQS5Gm92sGQK4qWoQjHZjCGtZHDQ0G9UIdb7O2MdY0BRMhli8xzLNMlSzOtvwZH(HraACuL1COFyeGgNUzK08GQSLzS4GPpv2CqMEBjqvsCiyh10CeCdAoStLgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhli0KuoGm9aviPr(HbcOP5i4gSmJfhm9PYMdY0BlbQscLMc(GPBoStLKDwziUFLLalZii1sq3hTRfCI1sp45v7L1sdcha1kS5ObN1c71(H1YJazG21AZsXANjjwBpsYAZGUmJfhm9PYMdY0BlbQsIdb7OMEWZZCyNknyVR4qWoQf2C0GQ5Xccnrd27koeSJAHnhnOAESGWFPb7Dfhc2rTWMJgurYYONhliSmJGuR86GJrTFWZUwMSwqFGZzTSrTWzTIKe6n1cAul7a1(H)dS2r(vB61sYoxMXIdM(uzZbz6TLavjXHGDutcNt4aNMd7uBfLs5aY0duDqsud6hCOzJFPkRKnrYoRme3VeSKPWCHndDQYAo0pmcqJJQSMd9dJa040nJKMhuLTmJGuBRhzhoWzTFWZU2r(vljppmABET2Wg7AT55HMxBg1sNNDTKC7A98Q1MLI1IEc2yxlj7CTxw7e0WiJRw78Rws25AH(H(ekfRnyai7xTtdoiSwb71sJMx7mR9d)pg1coXA7WaRLEWZRw2bQTh58OZXv7Nn61oYVAtVws25YmwCW0NkBoitVTeOkPomqn9GNxzgloy6tLnhKP3wcuLupY5rNJRmRmJfhm9PknqhdQDyGA6bppZHDQbOJ9mAqfaCkGgdOZrBTijjzhWenyVRaGtb0yaDoARfjjj7a6EKZtbAuMXIdM(uLgOJHeOkPEKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAIKDwzio53cjWYmwCW0NQ0aDmKavjbG8ztNHJLzS4GPpvPb6yibQskyai7NEAWbHMd7ujzNvgIt(YBjxMXIdM(uLgOJHeOkjsyezm1zxFzqI(vMXIdM(uLgOJHeOkPPnSFqVrBKFyyoStLgS3vCiyh1g5hgkG8ZnjYCaKFUIdb7O2i)Wqfijd9zzgloy6tvAGogsGQK4qWoQZG2CyNQiZbq(5koeSJAJ8ddvGmqBt0G9UIdb7OwyZrdQMhli8xAWExXHGDulS5ObvKSm65XcclZyXbtFQsd0XqcuLehc2rn9GNN5WovrkfD2pLu0p72HjrMdG8ZvKWiYyQZU(YGe9tfijd9P8BbY7YmwCW0NQ0aDmKavjDjOWwND9zJAsUbwMXIdM(uLgOJHeOkjoeSJAJ8dJYmwCW0NQ0aDmKavjfGoQZU2i)WWCyNknyVR4qWoQnYpmua5NxMrqQvECI126zlU2lRD2IarKGgwl71IYCbxBlfc2XAj2GNxTaGb0BQ9SXA)jVwSKAPwV2pOdKF1c6dCoRnaDh6n12sHGDSw5fHDQQT12RTLcb7yTYlc7Sw4S2JhOFiG51(H1ky))vl4eRT1ZwCTFWZg61E2yT)KxlwsTuRx7h0bYVAb9boN1(H1c9dJa04Q9SXABPwCTcB2DCyETZS2p8)yu7KLI1cpvzgloy6tvAGogsGQKmcCIUa1zxtcDaZHDQT64b6NIdb7Ogf2PjaKgS3vxckS1zxF2OMKBGkqdtainyVRUeuyRZU(Srnj3avbsYqF(lvkzXbtxXHGDutp45Pqzqb4H6dsITCAWExze4eDbQZUMe6akswg98ybHuuMrqQT12RT1ZwCT280)F1sJOxl4ebQfamGEtTNnw7p51IR9d6a5N51(H)hJAbNyTWR2lRD2IarKGgwl71IYCbxBlfc2XAj2GNxTqV2ZgRLGkBDj1sTETFqhi)uLzS4GPpvPb6yibQsYiWj6cuNDnj0bmh2Psd27koeSJAJ8ddfOHjAWExfGoQZU2i)Wqfijd95VuPKfhmDfhc2rn9GNNcLbfGhQpij2YPb7DLrGt0fOo7AsOdOizz0ZJfesrzgloy6tvAGogsGQK4qWoQPh88mh2PcKNkyai7NEAWbHQajzOpLpbserainyVRcgaY(PNgCqOwk4WXGPHd41wnpwqO8LCzgbP2wA8XTN1smocUbRLVApBSw0bQn712sTETF2OxBa6o0BQ9SXABPqWowR8QCqME7Ahyd6aC0UmJfhm9PknqhdjqvsCiyh10CeCdAoStLgS3vCiyh1g5hgkqdt0G9UIdb7O2i)Wqfijd95VncatbOJ9mAqfhc2rTnhKP3UmJGuBln(42ZAjghb3G1YxTNnwl6a1M9ApBSwcQS1R9d6a5xTF2OxBa6o0BQ9SXABPqWowR8QCqME7Ahyd6aC0UmJfhm9PknqhdjqvsCiyh10CeCdAoStLgS3vbOJ6SRnYpmuGgMOb7Dfhc2rTr(HHci)Ct0G9UkaDuNDTr(HHkqsg6ZFP2iamfGo2ZObvCiyh12CqME7YmwCW0NQ0aDmKavjXHGDutcNt4aNMd7ubqAWExDjOWwND9zJAsUbQanmD8a9tXHGDuJc70eL0G9Uca5ZModhva5NterS4Gsrn6ijeNuLLctainyVRUeuyRZU(Srnj3avbsYqFkFwCW0vCiyh1KW5eoWPcLbfGhQpijAUWMHovznh5y0wlSzORHDQ0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwD8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGIYmwCW0NQ0aDmKavjXHGDutcNt4aNMd7uPb7DLyGCi45b9g18ybHuPb7DLyGCi45b9gfjlJEESGqtIuk6SFkPOF2TJYmwCW0NQ0aDmKavjXHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mjYCaKFUIdb7O2i)Wqfijd9PjkPb7Dva6Oo7AJ8ddfObrerd27koeSJAJ8ddfObfMlSzOtv2YmwCW0NQ0aDmKavjXHGDuNbT5WovAWExXHGDulS5ObvZJfe(lvPCaz6bQU8i1KSmAHnhn4SmJfhm9PknqhdjqvsCiyh10dEEMd7uPb7Dva6Oo7AJ8ddfObrerYoRmeN8LLalZyXbtFQsd0XqcuLeknf8bt3CyNknyVRcqh1zxBKFyOaYp3enyVR4qWoQnYpmua5NBo0pmcqJtd7ujzNvgIt(uBbeO5q)WianonKKebG8HuLTmJfhm9PknqhdjqvsCiyh10CeCdwMvMrqii1YIdM(uf5XhmDQc2f4qZIdMU5WovwCW0vO0uWhmDLWMDhhqVXej7SYqCYNAlKanrzRcqh7z0GQj0WoD98YGKiIOb7D1eAyNUEEzqQMhliKknyVRMqd701ZldsfjlJEESGqkkZii1kpoXArPzTWETF4)aRDKF1METKSZ1YoqTImha5NpRLdSwMobVAVSwASwqJYmwCW0NQip(GPlbQscLMc(GPBoStTvbOJ9mAq1eAyNUEEzqAIKDwziUFPkLditpqfkn1gIZeLImha5NRUeuyRZU(Srnj3avbsYqF(lvwCW0vO0uWhmDfkdkapuFqsKiIezoaYpxXHGDuBKFyOcKKH(8xQS4GPRqPPGpy6kuguaEO(GKirer5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQS4GPRqPPGpy6kuguaEO(GKifuyIgS3vbOJ6SRnYpmua5NBIgS3vCiyh1g5hgkG8ZnbG0G9U6sqHTo76Zg1KCdubKFUPwzeOuDJaqjR6sqHTo76Zg1KCdSmJfhm9PkYJpy6sGQKqPPGpy6Md7udqh7z0GQj0WoD98YG0uRePu0z)usr)SBhMezoaYpxXHGDuBKFyOcKKH(8xQS4GPRqPPGpy6kuguaEO(GKyzgloy6tvKhFW0LavjHstbFW0nh2PgGo2ZObvtOHD665LbPjrkfD2pLu0p72HjrMdG8ZvKWiYyQZU(YGe9tfijd95VuzXbtxHstbFW0vOmOa8q9bjrtImha5NRUeuyRZU(Srnj3avbsYqF(lvkLYbKPhOImpTrGceb0xEKA62sGfhmDfknf8btxHYGcWd1hKeLabtHjrMdG8ZvCiyh1g5hgQajzOp)LkLs5aY0durMN2iqbIa6lpsnDBjWIdMUcLMc(GPRqzqb4H6dsIsGGPOmJGulX4i4gSwyVw49Fw7bjXAVSwWjw7LhzTSdu7hwRnlfR9YSws2BxRWMJgCwMXIdM(uf5XhmDjqvsCiyh10CeCdAoStvK5ai)C1LGcBD21NnQj5gOkqgOTjkPb7Dfhc2rTWMJgunpwqO8LYbKPhO6YJutYYOf2C0GttImha5NR4qWoQnYpmubsYqF(lvuguaEO(GKOjs2zLH4KVuoGm9avSHMe6qsqsnj7S2qCMOb7Dva6Oo7AJ8ddfq(5uuMXIdM(uf5XhmDjqvsCiyh10CeCdAoStvK5ai)C1LGcBD21NnQj5gOkqgOTjkPb7Dfhc2rTWMJgunpwqO8LYbKPhO6YJutYYOf2C0Gtthpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6ZFPIYGcWd1hKenjLditpq1bjrnOFWHMnKVuoGm9avxEKAswgnao426EgA2GIYmwCW0NQip(GPlbQsIdb7OMMJGBqZHDQImha5NRUeuyRZU(Srnj3avbYaTnrjnyVR4qWoQf2C0GQ5XccLVuoGm9avxEKAswgTWMJgCAIYwD8a9tfGoQZU2i)WGiIezoaYpxfGoQZU2i)Wqfijd9P8LYbKPhO6YJutYYObWb3w3ZqhPbfMKYbKPhO6GKOg0p4qZgYxkhqMEGQlpsnjlJgahCBDpdnBqrzgloy6tvKhFW0LavjXHGDutZrWnO5WovaKgS3vbdaz)0tdoiulfC4yW0Wb8ARMhliKkasd27QGbGSF6PbheQLcoCmyA4aETvKSm65XccnrjnyVR4qWoQnYpmua5Nter0G9UIdb7O2i)Wqfijd95VuBeauyIsAWExfGoQZU2i)WqbKForerd27Qa0rD21g5hgQajzOp)LAJaGIYmwCW0NQip(GPlbQsIdb7OMEWZZCyNQuoGm9avTSGZtdora90GdcjIikbqAWExfmaK9tpn4GqTuWHJbtdhWRTc0Weasd27QGbGSF6PbheQLcoCmyA4aETvZJfe(lasd27QGbGSF6PbheQLcoCmyA4aETvKSm65XccPOmJfhm9PkYJpy6sGQK4qWoQPh88mh2Psd27kJaNOlqD21KqhqbAycaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)sLfhmDfhc2rn9GNNcLbfGhQpijwMXIdM(uf5XhmDjqvsCiyh1KW5eoWP5WovaKgS3vxckS1zxF2OMKBGkqdthpq)uCiyh1OWonrjnyVRaq(SPZWrfq(5ereloOuuJoscXjvzPWeLainyVRUeuyRZU(Srnj3avbsYqFkFwCW0vCiyh1KW5eoWPcLbfGhQpijserImha5NRmcCIUa1zxtcDavGKm0NerKiLIo7NIW2bKDkmxyZqNQSMJCmARf2m01WovAWExjgihcEEqVrlSz3XHci)Ctusd27koeSJAJ8ddfObrerzRoEG(PsPyyKFyGaMOKgS3vbOJ6SRnYpmuGgerKiZbq(5kuAk4dMUkqgOnfuqrzgbPwci9jijw7zJ1IYyWoacuRrEOFqEulnyVxlpzJAVSwpVAh5eR1ip0pipQ1isXSmJfhm9PkYJpy6sGQK4qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMOb7DfkJb7aiG2ip0pipuGgLzS4GPpvrE8btxcuLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZeL0G9UIdb7O2i)WqbAqer0G9UkaDuNDTr(HHc0GiIaqAWExDjOWwND9zJAsUbQcKKH(u(S4GPR4qWoQjHZjCGtfkdkapuFqsKcZf2m0PkBzgloy6tvKhFW0LavjXHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mrd27kXa5qWZd6nQ5XccPsd27kXa5qWZd6nkswg98ybHMlSzOtv2YmcsTT04JBpR9I21EzT0StyTeabuBpJAfzoaYpV2pOdKFZAPbVAbajnQ9SrYAH9ApBS9)aRLPtWR2lRfLXagyzgloy6tvKhFW0LavjXHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mrd27kXa5qWZd6nQajzOp)LkLusd27kXa5qWZd6nQ5XccB5S4GPR4qWoQjHZjCGtfkdkapuFqsKcj0iauKSmuyUWMHovzlZyXbtFQI84dMUeOkjhpBm0hsAGZZCyNkLb2dCAZ0dKiIA1bfec9gkmrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfeAIgS3vCiyh1g5hgkG8ZnbG0G9U6sqHTo76Zg1KCdubKFEzgloy6tvKhFW0LavjXHGDuNbT5WovAWExXHGDulS5ObvZJfe(lvPCaz6bQU8i1KSmAHnhn4SmJfhm9PkYJpy6sGQKMGgy4Pu2CyNQuoGm9avj4nHaOo7ArMdG8ZNMizNvgI7xQTqcSmJfhm9PkYJpy6sGQK4qWoQPh88mh2Psd27QaCG6SRp7aXPc0WenyVR4qWoQf2C0GQ5XccLpbxMrqQvEnGKg1kS5ObN1c71(H125XOwACKF1E2yTI0NyifRLKDU2ZoWPDoaQLDGArPPGpy61cN1op4yuB61kYCaKFEzgloy6tvKhFW0LavjXHGDutZrWnO5Wo1wfGo2ZObvtOHD665LbPjPCaz6bQsWBcbqD21Imha5Npnrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfeA64b6NIdb7OodAtImha5NR4qWoQZGwfijd95VuBeaMizNvgI7xQTqjBsK5ai)Cfknf8btxfijd9zzgloy6tvKhFW0LavjXHGDutZrWnO5Wo1a0XEgnOAcnStxpVminjLditpqvcEtiaQZUwK5ai)8PjAWExXHGDulS5ObvZJfesLgS3vCiyh1cBoAqfjlJEESGqthpq)uCiyh1zqBsK5ai)Cfhc2rDg0QajzOp)LAJaWej7SYqC)sTfkztImha5NRqPPGpy6QajzOp)LGLCzgbPw51asAuRWMJgCwlSxBg01cN1gid0UmJfhm9PkYJpy6sGQK4qWoQP5i4g0CyNQuoGm9avj4nHaOo7ArMdG8ZNMOb7Dfhc2rTWMJgunpwqivAWExXHGDulS5ObvKSm65XccnD8a9tXHGDuNbTjrMdG8ZvCiyh1zqRcKKH(8xQncatKSZkdX9l1wOKnjYCaKFUcLMc(GPRcKKH(0eLTkaDSNrdQMqd701ZldsIiIgS3vtOHD665LbPkqsg6ZFPkBlGIYmcsTTuiyhRLyCeCdw70obha12Gog8y0UwAS2ZgRDWZRwbpVAZETNnwBl161(bDG8RmJfhm9PkYJpy6sGQK4qWoQP5i4g0CyNknyVR4qWoQnYpmuGgMOb7Dfhc2rTr(HHkqsg6ZFP2iamrd27koeSJAHnhnOAESGqQ0G9UIdb7OwyZrdQizz0ZJfeAIsrMdG8ZvO0uWhmDvGKm0Nerua6ypJguXHGDuBZbz6TPOmJGuBlfc2XAjghb3G1oTtWbqTnOJbpgTRLgR9SXAh88QvWZR2Sx7zJ1sqLTETFqhi)kZyXbtFQI84dMUeOkjoeSJAAocUbnh2Psd27Qa0rD21g5hgkqdt0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)Wqfijd95VuBeaMOb7Dfhc2rTWMJgunpwqivAWExXHGDulS5ObvKSm65XccnrPiZbq(5kuAk4dMUkqsg6tIikaDSNrdQ4qWoQT5Gm92uuMrqQTLcb7yTeJJGBWAN2j4aOwAS2ZgRDWZRwbpVAZETNnw7p51IR9d6a5xTWETWRw4SwpVAbNiqTFWZUwcQS1RnJABPwVmJfhm9PkYJpy6sGQK4qWoQP5i4g0CyNknyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBcaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)sTrayIgS3vCiyh1cBoAq18ybHuPb7Dfhc2rTWMJgurYYONhliSmJGuR8Gn61E2yThhn4vlCwl0RfLbfGhwBWEdwl7a1E2yG1cN1sMbw7zZETPJ1Ios228AbNyT0CeCdwlpRDMPxlpRTDcwRnlfRf9eSXUwHnhn4S2lR1gE1YJrTOJKqCwlSx7zJ12sHGDSwILK0CaqI(v7aBqhGJ21cN1ITiqOHbcuMXIdM(uf5XhmDjqvsCiyh10CeCdAoStvkhqMEGkK0i)Wab00CeCdAIgS3vCiyh1cBoAq18ybHYNkLS4Gsrn6ijeNTmYsHjwCqPOgDKeIt5lRjAWExbG8ztNHJkG8ZlZyXbtFQI84dMUeOkjoeSJAugJroHPBoStvkhqMEGkK0i)Wab00CeCdAIgS3vCiyh1cBoAq18ybH)sd27koeSJAHnhnOIKLrppwqOjwCqPOgDKeIt5lRjAWExbG8ztNHJkG8ZlZyXbtFQI84dMUeOkjoeSJA6bpVYmwCW0NQip(GPlbQscLMc(GPBoStvkhqMEGQe8MqauNDTiZbq(5ZYmwCW0NQip(GPlbQsIdb7OMMJGBW39U3d]] )

    
end