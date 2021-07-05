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


    spec:RegisterPack( "Arcane", 20210705, [[davXXgqiPK6riu4sevuLSjkYNuv1OqIofsyvsjKxHq1SOO6wevu2fj)IiYWiI6yeLwgffpJiKPrubxdb02iQiFtkjmoPe05KseRJiuVJOIQuZtvLUhsAFuu6GsjQfIa9qeGjsurvCrIkKnsurv5JiuKmseksDsPKOvsu1ljQOQAMiu6Msju7Ki4NevuzOsjPLsuH6PuYuvvXvLsK8vekQXsuP9Qk)LudwPdJAXi1JjmzaxgAZs1NLIrtPonOvlLi1RriZwHBJODt1VfnCkCCPey5cpxrtxLRd02jsFxvz8efNxk16rOiMpcA)s(j77NNfaF4tcMrYMrwj3kKmbQKCluo0cjqc8zDTnWNLbliIBWNLZK4ZQLdb74ZYGBpsg49ZZAMGHaFw23zmLyjjPg4zdsRejPKMqsWbFW0fb3pjnHKcj9SObHJRv6p6NfaF4tcMrYMrwj3kKmbQKCluo0cLizFwtdu8KGCYmplBiaa6p6NfaofpRwm3G12YHGDSKxEWr7AjqZR1ms2mYwYxYta2S3GtjUKxoR2wQjw712ak4rTwqscOwB2bgqVP2SxRWMDhh1c9dJa04GPxl0NhYa1M9A)lyxGdnloy6)vL8Yz1sa2S3G1YHGDud9o0Hx7AVSwoeSJABoitVDTucVADukg1(H(v7akfRLN1YHGDud9o0HxBkupRbCEZ3ppR0aDmE)8KGSVFEwOZ0de4rWNLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uT0G9UcaofqJb05OTwKKKSdO7ropfOXZIfhm9NvhgOMEWZ7DpjyM3ppl0z6bc8i4ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTKSZkdXvRzRTLqGplwCW0Fw9iNN2tP87EsqIE)8SyXbt)zbG8ztNHJpl0z6bc8i47Esqo8(5zHotpqGhbFwIaEya5Nfj7SYqC1A2ALds(zXIdM(Zkyai7NEAWbrV7jbc89ZZIfhm9NfjmImM6SRVmir)EwOZ0de4rW39KGC69ZZcDMEGapc(Seb8WaYplAWExXHGDuBKFyOaYpVwt1kYCaKFUIdb7O2i)Wqfijd95ZIfhm9N10g2pO3OnYpmE3tcTI3ppl0z6bc8i4ZseWddi)SezoaYpxXHGDuBKFyOcKbAxRPAPb7Dfhc2rTWMJgunpwquT)wlnyVR4qWoQf2C0Gkswg98ybrplwCW0FwCiyh1zq)UNeAHVFEwOZ0de4rWNLiGhgq(zjsPOZ(PKI(z3oQ1uTImha5NRiHrKXuND9Lbj6Nkqsg6ZAnBTTq5WZIfhm9Nfhc2rn9GN37EsOL8(5zXIdM(Z6sqHTo76Zg1KCd8zHotpqGhbF3tcYk53pplwCW0FwCiyh1g5hgpl0z6bc8i47EsqwzF)8SqNPhiWJGplrapmG8ZIgS3vCiyh1g5hgkG8ZFwS4GP)Scqh1zxBKFy8UNeK1mVFEwOZ0de4rWNfloy6plJaNOlqD21Kqh4zbGtranoy6pRwQjwBRMT4AVS2zlaerIjyTSxlkZfCTTCiyhRLGdEE1cagqVP2ZgR9N8AXsQLB1A)Goq(vlOpW5S2a0DO3uBlhc2XALJe2PQ2wzV2woeSJ1khjSZAHZApEG(HaMx7hwRG9)xTGtS2wnBX1(bpBOx7zJ1(tETyj1YTATFqhi)Qf0h4Cw7hwl0pmcqJR2ZgRTLBX1kSz3XH51oZA)W)JrTtwkwl8uplrapmG8ZQ11E8a9tXHGDuJc7uHotpqGAnvlasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)LATuwlloy6koeSJA6bppfkdkapuFqsS2wuT0G9UYiWj6cuNDnj0buKSm65XcIQLI39KGSs07NNf6m9abEe8zXIdM(ZYiWj6cuNDnj0bEwa4ueqJdM(ZQv2RTvZwCT280)F1sJOxl4ebQfamGEtTNnw7p51IR9d6a5N51(H)hJAbNyTWR2lRD2carKycwl71IYCbxBlhc2XAj4GNxTqV2ZgRvooBvj1YTATFqhi)uplrapmG8ZIgS3vCiyh1g5hgkqJAnvlnyVRcqh1zxBKFyOcKKH(S2FPwlL1YIdMUIdb7OMEWZtHYGcWd1hKeRTfvlnyVRmcCIUa1zxtcDafjlJEESGOAP4DpjiRC49ZZcDMEGapc(Seb8WaYplG8ubdaz)0tdoisfijd9zTMTwcSwcjSwaKgS3vbdaz)0tdoislfC4yW0Wb8ARMhliQwZwRKFwS4GP)S4qWoQPh88E3tcYsGVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZQLhFC7zTeKJGBWA5R2ZgRfDGAZETTCRw7Nn61gGUd9MApBS2woeSJ1smnhKP3U2b2GoahTFwIaEya5NfnyVR4qWoQnYpmuGg1AQwAWExXHGDuBKFyOcKKH(S2FRTrauRPAdqh7z0GkoeSJABoitVTcDMEGaV7jbzLtVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZQLhFC7zTeKJGBWA5R2ZgRfDGAZETNnwRCC2Q1(bDG8R2pB0RnaDh6n1E2yTTCiyhRLyAoitVDTdSbDaoA)Seb8WaYplAWExfGoQZU2i)WqbAuRPAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOcKKH(S2FPwBJaOwt1gGo2ZObvCiyh12CqMEBf6m9abE3tcY2kE)8SqNPhiWJGplHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdcjKYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniKqrMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwcjSwwCqPOgDKeIZAPwRS1srTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZAnBTS4GPR4qWoQjHZjCGtfkdkapuFqs8zXIdM(ZIdb7OMeoNWboF3tcY2cF)8SqNPhiWJGplrapmG8ZIgS3vIbYHGNh0BuZJfevl1APb7DLyGCi45b9gfjlJEESGOAnvRiLIo7Nsk6ND74zXIdM(ZIdb7OMeoNWboF3tcY2sE)8SqNPhiWJGplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)SOb7DLyGCi45b9gvGS4Q1uTImha5NR4qWoQnYpmubsYqFwRPAPSwAWExfGoQZU2i)WqbAulHewlnyVR4qWoQnYpmuGg1sX7EsWms(9ZZcDMEGapc(Seb8WaYplAWExXHGDulS5ObvZJfev7VuRvkhqMEGQlpsnjlJwyZrdoFwS4GP)S4qWoQZG(DpjygzF)8SqNPhiWJGplrapmG8ZIgS3vbOJ6SRnYpmuGg1siH1sYoRmexTMTwzjWNfloy6ploeSJA6bpV39KGzmZ7NNf6m9abEe8zXIdM(ZcLMc(GP)SG(HraACAy)zrYoRmeNzP2cjWNf0pmcqJtdjjraiF4Zs2NLiGhgq(zrd27Qa0rD21g5hgkG8ZR1uT0G9UIdb7O2i)WqbKF(7EsWms07NNfloy6ploeSJAAocUbFwOZ0de4rW39UNvhoTHEJonqhJ3ppji77NNf6m9abEe8zXIdM(ZcLMc(GP)SaWPiGghm9NfXSn61gGUd9MAr4zJrTNnwRLvTzu7peZ1oWg0b4aItZR9dR9J9R2lRvosAwln2ZaR9SXA)jVwSKA5wT2pOdKFQABPMyTWRwEw7mtVwEwRCC2Q1AZZA7qhoTrGAtWO2p8VuS2Pb6xTjyuRWMJgC(Seb8WaYplkRnaDSNrdQoK0idEO)4WqHotpqGAjKWAPS2a0XEgnOAcnStxpVmivOZ0deOwt126ALYbKPhOYiqdWXqJsZAPwRS1srTuuRPAPSwAWExfGoQZU2i)WqbKFETesyTgbkv3iauYQ4qWoQP5i4gSwkQ1uTImha5NRcqh1zxBKFyOcKKH(8DpjyM3ppl0z6bc8i4ZIfhm9Nfknf8bt)zbGtranoy6pRwzV2p8VuS2o0HtBeO2emQvK5ai)8A)Goq(nRLDGANgOF1MGrTcBoAWP51AeWmGhKycwRCK0S2ukg1IsXO9zd9MAXXeFwIaEya5N1Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(Swt1kYCaKFUIdb7O2i)Wqfijd9zTMQLgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHci)8AnvRrGs1ncaLSkoeSJAAocUbF3tcs07NNf6m9abEe8zjc4HbKFwbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnvlnyVRaGtb0yaDoARfjjj7a6EKZtbA8SyXbt)z1HbQPh88E3tcYH3ppl0z6bc8i4ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTKSZkdXvRzRTLqGplwCW0Fw9iNN2tP87EsGaF)8SqNPhiWJGplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)Scqh7z0GkoeSJABoitVTcDMEGa1AQwAWExXHGDuBZbz6TvZJfev7V1sd27koeSJABoitVTIKLrppwquTMQLYAPSwAWExXHGDuBKFyOaYpVwt1kYCaKFUIdb7O2i)Wqfid0UwkQLqcRfaPb7D1LGcBD21NnQj5gOc0OwkE3tcYP3ppl0z6bc8i4ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGNfloy6pRa0rD21g5hgV7jHwX7NNf6m9abEe8zjc4HbKFwImha5NRcqh1zxBKFyOcKbA)SyXbt)zXHGDuNb97EsOf((5zHotpqGhbFwIaEya5NLiZbq(5Qa0rD21g5hgQazG21AQwAWExXHGDulS5ObvZJfev7V1sd27koeSJAHnhnOIKLrppwq0ZIfhm9Nfhc2rn9GN37EsOL8(5zHotpqGhbFwIaEya5NvRRnaDSNrdQoK0idEO)4WqHotpqGAjKWAfPdacpvdSF6SRpBupGcBf6m9abEwS4GP)Saq(SPZWX39KGSs(9ZZIfhm9Nva6Oo7AJ8dJNf6m9abEe8DpjiRSVFEwOZ0de4rWNfloy6ploeSJAs4Cch48zbGtranoy6pRwzV2p8FG1YxTKSm1opwq0S2Sxlbqa1YoqTFyT2Su0)F1corGABX5p12gpZRfCI1Y1opwquTxwRrGsr)QLe0f2qVPwqFGZzTbO7qVP2ZgRLyAoitVDTdSbDaoA)Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OMhliQwQ1sd27kXa5qWZd6nkswg98ybr1AQwrkfD2pLu0p72rTMQvK5ai)CfjmImM6SRVmir)ubYaTR1uTTUwPCaz6bQqsJ8ddeqtZrWnyTMQvK5ai)Cfhc2rTr(HHkqgO97EsqwZ8(5zHotpqGhbFwIaEya5NvRRnaDSNrdQoK0idEO)4WqHotpqGAnvlL126Adqh7z0GQj0WoD98YGuHotpqGAjKWALYbKPhOYiqdWXqJsZAPwRS1sXZcaNIaACW0FwsidsEmAx7hwRbdJAnYdMETGtS2p4zxBl3QMxln4vl8Q9dog1o45v7i9MArpbBSRTNrT05zx7zJ1khNTATSduBl3Q1(bDG8BwlOpW5S2a0DO3u7zJ1AzvBg1(dXCTdSbDaoG48zXIdM(ZYipy6V7jbzLO3ppl0z6bc8i4ZseWddi)SOb7Dva6Oo7AJ8ddfq(51siH1AeOuDJaqjRIdb7OMMJGBWNfloy6plaKpB6mC8DpjiRC49ZZcDMEGapc(Seb8WaYplAWExfGoQZU2i)WqbKFETesyTgbkv3iauYQ4qWoQP5i4g8zXIdM(Zkyai7NEAWbrV7jbzjW3ppl0z6bc8i4ZseWddi)SOb7Dva6Oo7AJ8ddvGKm0N1(BTuwRCQwIxRzQTfvBa6ypJgunHg2PRNxgKk0z6bculfplwCW0FwKWiYyQZU(YGe97DpjiRC69ZZcDMEGapc(SyXbt)zXHGDuBKFy8SaWPiGghm9NfXSn61gGUd9MApBSwIP5Gm921oWg0b4OT51coXAB5wTwASNbw7p51IR9YAbajnQLRTdogTRDESGieOwAo4ObFwIaEya5NLuoGm9aviPr(HbcOP5i4gSwt1sd27Qa0rD21g5hgkqJAnvlL1sYoRmexT)wlL1AgcSwIxlL1kRKRTfvRiLIo7NIO2bK9APOwkQLqcRLgS3vIbYHGNh0BuZJfevl1APb7DLyGCi45b9gfjlJEESGOAP4DpjiBR49ZZcDMEGapc(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIQ1uT0G9UIdb7O2i)WqbA8SyXbt)zXHGDutZrWn47Esq2w47NNf6m9abEe8zjc4HbKFw0G9UkaDuNDTr(HHci)8AjKWAncuQUraOKvXHGDutZrWnyTesyTgbkv3iauYQcgaY(PNgCquTesyTgbkv3iauYQaq(SPZWXNfloy6pRlbf26SRpButYnW39KGSTK3ppl0z6bc8i4ZseWddi)SmcuQUraOKvDjOWwND9zJAsUb(SyXbt)zXHGDuBKFy8UNemJKF)8SqNPhiWJGplwCW0FwgborxG6SRjHoWZcaNIaACW0FwTutS2wnBX1EzTZwaiIetWAzVwuMl4AB5qWowlbh88QfamGEtTNnw7p51ILul3Q1(bDG8RwqFGZzTbO7qVP2woeSJ1khjStvTTYETTCiyhRvosyN1cN1E8a9dbmV2pSwb7)VAbNyTTA2IR9dE2qV2ZgR9N8AXsQLB1A)Goq(vlOpW5S2pSwOFyeGgxTNnwBl3IRvyZUJdZRDM1(H)hJANSuSw4PEwIaEya5NvRR94b6NIdb7Ogf2PcDMEGa1AQwaKgS3vxckS1zxF2OMKBGkqJAnvlasd27Qlbf26SRpButYnqvGKm0N1(l1APSwwCW0vCiyh10dEEkuguaEO(GKyTTOAPb7DLrGt0fOo7AsOdOizz0ZJfevlfV7jbZi77NNf6m9abEe8zXIdM(ZYiWj6cuNDnj0bEwa4ueqJdM(ZQv2RTvZwCT280)F1sJOxl4ebQfamGEtTNnw7p51IR9d6a5N51(H)hJAbNyTWR2lRD2carKycwl71IYCbxBlhc2XAj4GNxTqV2ZgRvooBvj1YTATFqhi)uplrapmG8ZIgS3vCiyh1g5hgkqJAnvlnyVRcqh1zxBKFyOcKKH(S2FPwlL1YIdMUIdb7OMEWZtHYGcWd1hKeRTfvlnyVRmcCIUa1zxtcDafjlJEESGOAP4DpjygZ8(5zHotpqGhbFwIaEya5NfqEQGbGSF6PbhePcKKH(SwZwlbwlHewlasd27QGbGSF6PbhePLcoCmyA4aETvZJfevRzRvYplwCW0FwCiyh10dEEV7jbZirVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZIygR9J9R2lRLKjcRDcgyTFyT2SuSw0tWg7AjzNRTNrTNnwl6hmWAB5wT2pOdKFMxlkf9AH9ApBmW)ZANhCmQ9GKyTbsYqh6n1METYXzRQQTvE)N1M(ODT04Dyu7L1sdgETxwlXemYAzhOw5iPzTWETbO7qVP2ZgR1YQ2mQ9hI5Ahyd6aCaXP6zjc4HbKFwImha5NR4qWoQnYpmubYaTR1uTKSZkdXv7V1szTYbjxlXRLYALvY12IQvKsrN9tru7aYETuulf1AQwAWExXHGDulS5ObvZJfevl1APb7Dfhc2rTWMJgurYYONhliQwt1szTTU2a0XEgnOAcnStxpVmivOZ0deOwcjSwPCaz6bQmc0aCm0O0SwQ1kBTuuRPABDTbOJ9mAq1HKgzWd9hhgk0z6bcuRPABDTbOJ9mAqfhc2rTnhKP3wHotpqG39KGzKdVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZIGCeCdw70obha165vlnwl4ebQLVApBSw0bQn712YTATWETYrstbFW0RfoRnqgODT8SwGinmGEtTcBoAWzTFWXOwsMiSw4v7XeH1osVbJAVSwAWWR9SJeSXU2ajzOd9MAjzNFwIaEya5NfnyVR4qWoQnYpmuGg1AQwAWExXHGDuBKFyOcKKH(S2FPwBJaOwt1kYCaKFUcLMc(GPRcKKH(8Dpjygc89ZZcDMEGapc(SyXbt)zXHGDutZrWn4ZcaNIaACW0FweKJGBWAN2j4aOwE8XTN1sJ1E2yTdEE1k45vl0R9SXALJZwT2pOdKF1YZA)jVwCTFWXO2aNxgyTNnwRWMJgCw70a97zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)Wqfijd9zT)sT2gbqTMQT11gGo2ZObvCiyh12CqMEBf6m9abE3tcMro9(5zHotpqGhbFwcBg6plzFwihJ2AHndDnS)SOb7DLyGCi45b9gTWMDhhkG8ZnrjnyVR4qWoQnYpmuGgesiLT(4b6NkLIHr(HbcyIsAWExfGoQZU2i)WqbAqiHImha5NRqPPGpy6QazG2uqbfplrapmG8ZcaPb7D1LGcBD21NnQj5gOc0Owt1E8a9tXHGDuJc7uHotpqGAnvlL1sd27kaKpB6mCubKFETesyTS4Gsrn6ijeN1sTwzRLIAnvlasd27Qlbf26SRpButYnqvGKm0N1A2AzXbtxXHGDutcNt4aNkuguaEO(GK4ZIfhm9Nfhc2rnjCoHdC(UNemtR49ZZcDMEGapc(SyXbt)zXHGDutcNt4aNplaCkcOXbt)z1k71(H)dSwPOF2TdZRfssIaq(Wr7AbNyTeabu7Nn61kyddeO2lR1ZR2pEEyTgrkM12JKS2wC(ZZseWddi)SePu0z)usr)SBh1AQwAWExjgihcEEqVrnpwquTuRLgS3vIbYHGNh0BuKSm65XcIE3tcMPf((5zHotpqGhbFwa4ueqJdM(ZY644QfCc9MAjacO2wUfx7Nn612YTAT28SwAe9AbNiWZseWddi)SOb7DLyGCi45b9gvGS4Q1uTImha5NR4qWoQnYpmubsYqFwRPAPSwAWExfGoQZU2i)WqbAulHewlnyVR4qWoQnYpmuGg1sXZsyZq)zj7ZIfhm9Nfhc2rnjCoHdC(UNemtl59ZZcDMEGapc(Seb8WaYplAWExXHGDulS5ObvZJfev7VuRvkhqMEGQlpsnjlJwyZrdoFwS4GP)S4qWoQZG(Dpjirs(9ZZcDMEGapc(Seb8WaYplAWExfGoQZU2i)WqbAulHewlj7SYqC1A2ALLaFwS4GP)S4qWoQPh88E3tcsKSVFEwOZ0de4rWNfloy6pluAk4dM(Zc6hgbOXPH9Nfj7SYqCMLAlKaFwq)WianonKKebG8HplzFwIaEya5NfnyVRcqh1zxBKFyOaYpVwt1sd27koeSJAJ8ddfq(5V7jbjYmVFEwS4GP)S4qWoQP5i4g8zHotpqGhbF37EwrE8bt)9ZtcY((5zHotpqGhbFwS4GP)SqPPGpy6plaCkcOXbt)z1snXArPzTWETF4)aRDKF1METKSZ1YoqTImha5NpRLdSwMobVAVSwASwqJNLiGhgq(zrYoRmexT)sTwPCaz6bQqPP2qC1AQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZA)LATS4GPRqPPGpy6kuguaEO(GKyTesyTImha5NR4qWoQnYpmubsYqFw7VuRLfhmDfknf8btxHYGcWd1hKeRLqcRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1AzXbtxHstbFW0vOmOa8q9bjXAPOwkQ1uT0G9UkaDuNDTr(HHci)8AnvlnyVR4qWoQnYpmua5NxRPAbqAWExDjOWwND9zJAsUbQaYpVwt126AncuQUraOKvDjOWwND9zJAsUb(UNemZ7NNf6m9abEe8zjc4HbKFwbOJ9mAq1eAyNUEEzqQqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATS4GPRqPPGpy6kuguaEO(GK4ZIfhm9Nfknf8bt)DpjirVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZIGCeCdwlSxl8(pR9GKyTxwl4eR9YJSw2bQ9dR1MLI1Ezwlj7TRvyZrdoFwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlL1sd27koeSJAHnhnOAESGOAnBTs5aY0duD5rQjzz0cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATOmOa8q9bjXAnvlj7SYqC1A2ALYbKPhOIn0KqhscsQjzN1gIRwt1sd27Qa0rD21g5hgkG8ZRLI39KGC49ZZcDMEGapc(Seb8WaYplrMdG8ZvxckS1zxF2OMKBGQazG21AQwkRLgS3vCiyh1cBoAq18ybr1A2ALYbKPhO6YJutYYOf2C0GZAnv7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NRcqh1zxBKFyOcKKH(S2FPwlkdkapuFqsSwt1kLditpq1bjrnOFWHMnQ1S1kLditpq1LhPMKLrdGdUTUNHMnQLINfloy6ploeSJAAocUbF3tce47NNf6m9abEe8zjc4HbKFwImha5NRUeuyRZU(Srnj3avbYaTR1uTuwlnyVR4qWoQf2C0GQ5XcIQ1S1kLditpq1LhPMKLrlS5ObN1AQwkRT11E8a9tfGoQZU2i)WqHotpqGAjKWAfzoaYpxfGoQZU2i)Wqfijd9zTMTwPCaz6bQU8i1KSmAaCWT19m0rAulf1AQwPCaz6bQoijQb9do0SrTMTwPCaz6bQU8i1KSmAaCWT19m0SrTu8SyXbt)zXHGDutZrWn47Esqo9(5zHotpqGhbFwIaEya5Nfasd27QGbGSF6PbhePLcoCmyA4aETvZJfevl1AbqAWExfmaK9tpn4GiTuWHJbtdhWRTIKLrppwquTMQLYAPb7Dfhc2rTr(HHci)8AjKWAPb7Dfhc2rTr(HHkqsg6ZA)LATncGAPOwt1szT0G9UkaDuNDTr(HHci)8AjKWAPb7Dva6Oo7AJ8ddvGKm0N1(l1ABea1sXZIfhm9Nfhc2rnnhb3GV7jHwX7NNf6m9abEe8zjc4HbKFws5aY0du1sdopn4eb0tdoiQwcjSwkRfaPb7DvWaq2p90GdI0sbhogmnCaV2kqJAnvlasd27QGbGSF6PbhePLcoCmyA4aETvZJfev7V1cG0G9Ukyai7NEAWbrAPGdhdMgoGxBfjlJEESGOAP4zXIdM(ZIdb7OMEWZ7Dpj0cF)8SqNPhiWJGplrapmG8ZIgS3vgborxG6SRjHoGc0Owt1cG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2FPwlloy6koeSJA6bppfkdkapuFqs8zXIdM(ZIdb7OMEWZ7Dpj0sE)8SqNPhiWJGplHnd9NLSplKJrBTWMHUg2Fw0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdcjKYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniKqrMdG8ZvO0uWhmDvGmqBkOGINLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPApEG(P4qWoQrHDQqNPhiqTMQLYAPb7DfaYNnDgoQaYpVwcjSwwCqPOgDKeIZAPwRS1srTMQLYAbqAWExDjOWwND9zJAsUbQcKKH(SwZwlloy6koeSJAs4Cch4uHYGcWd1hKeRLqcRvK5ai)CLrGt0fOo7AsOdOcKKH(SwcjSwrkfD2pfrTdi71sXZIfhm9Nfhc2rnjCoHdC(UNeKvYVFEwOZ0de4rWNfloy6ploeSJAs4Cch48zbGtranoy6plci9jijw7zJ1IYyWoacuRrEOFqEulnyVxlpzJAVSwpVAh5eR1ip0pipQ1isX8zjc4HbKFw0G9Usmqoe88GEJkqwC1AQwAWExHYyWoacOnYd9dYdfOX7EsqwzF)8SqNPhiWJGplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)SOb7DLyGCi45b9gvGS4Q1uTuwlnyVR4qWoQnYpmuGg1siH1sd27Qa0rD21g5hgkqJAjKWAbqAWExDjOWwND9zJAsUbQcKKH(SwZwlloy6koeSJAs4Cch4uHYGcWd1hKeRLI39KGSM59ZZcDMEGapc(SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZIgS3vIbYHGNh0BubYIRwt1sd27kXa5qWZd6nQ5XcIQLAT0G9Usmqoe88GEJIKLrppwq07Esqwj69ZZcDMEGapc(SaWPiGghm9Nvlp(42ZAVODTxwln7evlbqa12ZOwrMdG8ZR9d6a53SwAWRwaqsJApBKSwyV2ZgB)pWAz6e8Q9YArzmGb(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OcKKH(S2FPwlL1szT0G9Usmqoe88GEJAESGOABr1YIdMUIdb7OMeoNWbovOmOa8q9bjXAPOwIxBJaqrYYulfplHnd9NLSplwCW0FwCiyh1KW5eoW57Esqw5W7NNf6m9abEe8zjc4HbKFwuwBG9aN2m9aRLqcRT11EqbrqVPwkQ1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTMQLgS3vCiyh1g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5N)SyXbt)z54zJH(qsdCEV7jbzjW3ppl0z6bc8i4ZseWddi)SOb7Dfhc2rTWMJgunpwquT)sTwPCaz6bQU8i1KSmAHnhn48zXIdM(ZIdb7Ood639KGSYP3ppl0z6bc8i4ZseWddi)SKYbKPhOkbVjea1zxlYCaKF(Swt1sYoRmexT)sT2wcb(SyXbt)znbnWWtP87Esq2wX7NNf6m9abEe8zjc4HbKFw0G9UkahOo76ZoqCQanQ1uT0G9UIdb7OwyZrdQMhliQwZwRe9SyXbt)zXHGDutp459UNeKTf((5zHotpqGhbFwS4GP)S4qWoQP5i4g8zbGtranoy6pl58asAuRWMJgCwlSx7hwBNhJAPXr(v7zJ1ksFIHuSws25Ap7aN25aOw2bQfLMc(GPxlCw78GJrTPxRiZbq(5plrapmG8ZQ11gGo2ZObvtOHD665LbPcDMEGa1AQwPCaz6bQsWBcbqD21Imha5NpR1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTMQ94b6NIdb7OodAf6m9abQ1uTImha5NR4qWoQZGwfijd9zT)sT2gbqTMQLKDwziUA)LATTejxRPAfzoaYpxHstbFW0vbsYqF(UNeKTL8(5zHotpqGhbFwIaEya5Nva6ypJgunHg2PRNxgKk0z6bcuRPALYbKPhOkbVjea1zxlYCaKF(Swt1sd27koeSJAHnhnOAESGOAPwlnyVR4qWoQf2C0Gkswg98ybr1AQ2JhOFkoeSJ6mOvOZ0deOwt1kYCaKFUIdb7OodAvGKm0N1(l1ABea1AQws2zLH4Q9xQ12sKCTMQvK5ai)Cfknf8btxfijd9zT)wRej5Nfloy6ploeSJAAocUbF3tcMrYVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZsopGKg1kS5ObN1c71MbDTWzTbYaTFwIaEya5NLuoGm9avj4nHaOo7ArMdG8ZN1AQwAWExXHGDulS5ObvZJfevl1APb7Dfhc2rTWMJgurYYONhliQwt1E8a9tXHGDuNbTcDMEGa1AQwrMdG8ZvCiyh1zqRcKKH(S2FPwBJaOwt1sYoRmexT)sT2wIKR1uTImha5NRqPPGpy6QajzOpF3tcMr23ppl0z6bc8i4ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)z1YHGDSwcYrWnyTt7eCauBd6yWJr7APXApBS2bpVAf88Qn71E2yTTCRw7h0bYVNLiGhgq(zrd27koeSJAJ8ddfOrTMQLgS3vCiyh1g5hgQajzOpR9xQ12iaQ1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTMQLYAfzoaYpxHstbFW0vbsYqFwlHewBa6ypJguXHGDuBZbz6TvOZ0deOwkE3tcMXmVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZQLdb7yTeKJGBWAN2j4aO2g0XGhJ21sJ1E2yTdEE1k45vB2R9SXALJZwT2pOdKFplrapmG8ZIgS3vbOJ6SRnYpmuGg1AQwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgQajzOpR9xQ12iaQ1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTMQLYAfzoaYpxHstbFW0vbsYqFwlHewBa6ypJguXHGDuBZbz6TvOZ0deOwkE3tcMrIE)8SqNPhiWJGplwCW0FwCiyh10CeCd(SaWPiGghm9Nvlhc2XAjihb3G1oTtWbqT0yTNnw7GNxTcEE1M9ApBS2FYRfx7h0bYVAH9AHxTWzTEE1corGA)GNDTYXzRwBg12YT6ZseWddi)SOb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2FPwBJaOwt1sd27koeSJAHnhnOAESGOAPwlnyVR4qWoQf2C0Gkswg98ybrV7jbZihE)8SqNPhiWJGplwCW0FwCiyh10CeCd(SaWPiGghm9NfXSn61E2yThhn4vlCwl0RfLbfGhwBWEdwl7a1E2yG1cN1sMbw7zZETPJ1Ios228AbNyT0CeCdwlpRDMPxlpRTDcwRnlfRf9eSXUwHnhn4S2lR1gE1YJrTOJKqCwlSx7zJ12YHGDSwcMK0CaqI(v7aBqhGJ21cN1ITaqOHbc8Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLgS3vCiyh1cBoAq18ybr1AwQ1szTS4Gsrn6ijeN1kNvRS1srTMQLfhukQrhjH4SwZwRS1AQwAWExbG8ztNHJkG8ZF3tcMHaF)8SqNPhiWJGplrapmG8ZskhqMEGkK0i)Wab00CeCdwRPAPb7Dfhc2rTWMJgunpwquT)wlnyVR4qWoQf2C0Gkswg98ybr1AQwwCqPOgDKeIZAnBTYwRPAPb7DfaYNnDgoQaYp)zXIdM(ZIdb7OgLXyKty6V7jbZiNE)8SyXbt)zXHGDutp459SqNPhiWJGV7jbZ0kE)8SqNPhiWJGplrapmG8ZskhqMEGQe8MqauNDTiZbq(5ZNfloy6pluAk4dM(7EsWmTW3pplwCW0FwCiyh10CeCd(SqNPhiWJGV7DploX3ppji77NNf6m9abEe8zjc4HbKFwbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnvRiZbq(5kAWExdaNcOXa6C0wlsss2bubYaTR1uT0G9UcaofqJb05OTwKKKSdO7ropfq(51AQwkRLgS3vCiyh1g5hgkG8ZR1uT0G9UkaDuNDTr(HHci)8Anvlasd27Qlbf26SRpButYnqfq(51srTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uTuwlnyVR4qWoQf2C0GQ5XcIQ9xQ1kLditpqfNO(YJutYYOf2C0GZAnvlL1szThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZA)LATncGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYYObWb3w3ZqZg1srTesyTuwBRR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLrdGdUTUNHMnQLIAjKWAfzoaYpxXHGDuBKFyOcKKH(S2FPwBJaOwkQLINfloy6pREKZJoh37EsWmVFEwOZ0de4rWNLiGhgq(zrzTbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnvRiZbq(5kAWExdaNcOXa6C0wlsss2bubYaTR1uT0G9UcaofqJb05OTwKKKSdO7Wava5NxRPAncuQUraOKv1JCE054QLIAjKWAPS2a0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQ9GKyTuRvY1sXZIfhm9NvhgOMEWZ7DpjirVFEwOZ0de4rWNLiGhgq(zfGo2ZObvnbCoARHcOyGk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRej5AnvRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwjxRPAPSwAWExXHGDulS5ObvZJfev7VuRvkhqMEGkor9LhPMKLrlS5ObN1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLrdGdUTUNHMnQLIAjKWAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlJgahCBDpdnBulf1siH1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTuulfplwCW0Fw9iNN2tP87Esqo8(5zHotpqGhbFwIaEya5Nva6ypJgu1eW5OTgkGIbQqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAPwRKR1uTuwlL1szTImha5NRUeuyRZU(Srnj3avbsYqFwRzRvkhqMEGk2qtYYObWb3w3ZqF5rwRPAPb7Dfhc2rTWMJgunpwquTuRLgS3vCiyh1cBoAqfjlJEESGOAPOwcjSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRKR1uT0G9UIdb7OwyZrdQMhliQ2FPwRuoGm9avCI6lpsnjlJwyZrdoRLIAPOwt1sd27Qa0rD21g5hgkG8ZRLINfloy6pREKZt7Pu(DpjqGVFEwOZ0de4rWNfloy6ploeSJAs4Cch48zjSzO)SK9zjc4HbKFwIuk6SFkIAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQT5Gm92Q5XcIQ93ALLaR1uTImha5NRcgaY(PNgCqKkqsg6ZA)LATs5aY0duzZbz6T1ZJfePpijwlXRfLbfGhQpijwRPAfzoaYpxDjOWwND9zJAsUbQcKKH(S2FPwRuoGm9av2CqMEB98ybr6dsI1s8Arzqb4H6dsI1s8AzXbtxfmaK9tpn4GifkdkapuFqsSwt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwPCaz6bQS5Gm9265XcI0hKeRL41IYGcWd1hKeRL41YIdMUkyai7NEAWbrkuguaEO(GKyTeVwwCW0vxckS1zxF2OMKBGkuguaEO(GK47Esqo9(5zHotpqGhbFwIaEya5Nva6ypJgunHg2PRNxgKk0z6bcuRPAncuQUraOKvHstbFW0FwS4GP)SUeuyRZU(Srnj3aF3tcTI3ppl0z6bc8i4ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGAnvlL1AeOuDJaqjRcLMc(GPxlHewRrGs1ncaLSQlbf26SRpButYnWAP4zXIdM(ZIdb7O2i)W4Dpj0cF)8SqNPhiWJGplrapmG8Z6GKyTMTwjsY1AQ2a0XEgnOAcnStxpVmivOZ0deOwt1sd27koeSJAHnhnOAESGOA)LATs5aY0duXjQV8i1KSmAHnhn4Swt1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12iaEwS4GP)SqPPGpy6V7jHwY7NNf6m9abEe8zXIdM(ZcLMc(GP)SG(HraACAy)zrd27Qj0WoD98YGunpwqevAWExnHg2PRNxgKkswg98ybrplOFyeGgNgssIaq(WNLSplrapmG8Z6GKyTMTwjsY1AQ2a0XEgnOAcnStxpVmivOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTuulHewlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfev7VuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(51sX7Esqwj)(5zHotpqGhbFwIaEya5NfL1kYCaKFUIdb7O2i)Wqfijd9zTMTw5abwlHewRiZbq(5koeSJAJ8ddvGKm0N1(l1ALOAPOwt1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwkRLgS3vCiyh1cBoAq18ybr1(l1ALYbKPhOItuF5rQjzz0cBoAWzTMQLYAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sT2gbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTeyTuulHewlL126ApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTeyTuulHewRiZbq(5koeSJAJ8ddvGKm0N1(l1ABea1srTu8SyXbt)zrcJiJPo76lds0V39KGSY((5zHotpqGhbFwIaEya5NLiZbq(5Qlbf26SRpButYnqvGKm0N1(BTOmOa8q9bjXAnvlL1szThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZA)LATncGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYYObWb3w3ZqZg1srTesyTuwBRR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLrdGdUTUNHMnQLIAjKWAfzoaYpxXHGDuBKFyOcKKH(S2FPwBJaOwkEwS4GP)ScgaY(PNgCq07EsqwZ8(5zHotpqGhbFwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1(BTOmOa8q9bjXAnvlL1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1A2ALYbKPhOIn0KSmAaCWT19m0xEK1AQwAWExXHGDulS5ObvZJfevl1APb7Dfhc2rTWMJgurYYONhliQwkQLqcRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlnyVR4qWoQf2C0GQ5XcIQ9xQ1kLditpqfNO(YJutYYOf2C0GZAPOwkQ1uT0G9UkaDuNDTr(HHci)8AP4zXIdM(Zkyai7NEAWbrV7jbzLO3ppl0z6bc8i4ZseWddi)SezoaYpxXHGDuBKFyOcKKH(SwQ1k5AnvlL1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1A2ALYbKPhOIn0KSmAaCWT19m0xEK1AQwAWExXHGDulS5ObvZJfevl1APb7Dfhc2rTWMJgurYYONhliQwkQLqcRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlnyVR4qWoQf2C0GQ5XcIQ9xQ1kLditpqfNO(YJutYYOf2C0GZAPOwkQ1uT0G9UkaDuNDTr(HHci)8AP4zXIdM(Zca5ZModhF3tcYkhE)8SqNPhiWJGplrapmG8ZIYAPb7Dfhc2rTWMJgunpwquT)sTwPCaz6bQ4e1xEKAswgTWMJgCwlHewRrGs1ncaLSQGbGSF6Pbhevlf1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLrdGdUTUNHMnQLIAjKWAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlJgahCBDpdnBulf1siH1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTu8SyXbt)zDjOWwND9zJAsUb(UNeKLaF)8SqNPhiWJGplrapmG8ZIYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTuulHewlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfev7VuRvkhqMEGkor9LhPMKLrlS5ObN1srTuuRPAPb7Dva6Oo7AJ8ddfq(5plwCW0FwCiyh1g5hgV7jbzLtVFEwOZ0de4rWNLiGhgq(zrd27Qa0rD21g5hgkG8ZR1uTuwlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTMTwZi5AnvlnyVR4qWoQf2C0GQ5XcIQLAT0G9UIdb7OwyZrdQizz0ZJfevlf1siH1szTImha5NRUeuyRZU(Srnj3avbsYqFwl1ALCTMQLgS3vCiyh1cBoAq18ybr1(l1ALYbKPhOItuF5rQjzz0cBoAWzTuulf1AQwkRvK5ai)Cfhc2rTr(HHkqsg6ZAnBTYAMAjKWAbqAWExDjOWwND9zJAsUbQanQLINfloy6pRa0rD21g5hgV7jbzBfVFEwOZ0de4rWNLiGhgq(zjYCaKFUIdb7OodAvGKm0N1A2AjWAjKWABDThpq)uCiyh1zqRqNPhiWZIfhm9N10g2pO3OnYpmE3tcY2cF)8SqNPhiWJGplrapmG8ZsKsrN9tru7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bcuRPAPb7Dfhc2rTr(HHc0Owt1cG0G9Ukyai7NEAWbrAPGdhdMgoGxB18ybr1sTw5qTMQ1iqP6gbGswfhc2rDg01AQwwCqPOgDKeIZA)T2wXZIfhm9Nfhc2rn9GN37Esq2wY7NNf6m9abEe8zjc4HbKFwIuk6SFkIAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwaKgS3vbdaz)0tdoislfC4yW0Wb8ARMhliQwQ1khEwS4GP)S4qWoQP5i4g8Dpjygj)(5zHotpqGhbFwIaEya5NLiLIo7NIO2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1sd27koeSJAJ8ddfOrTMQLYAbYtfmaK9tpn4GivGKm0N1A2ALt1siH1cG0G9Ukyai7NEAWbrAPGdhdMgoGxBfOrTuuRPAbqAWExfmaK9tpn4GiTuWHJbtdhWRTAESGOA)Tw5qTMQLfhukQrhjH4SwQ1krplwCW0FwCiyh10dEEV7jbZi77NNf6m9abEe8zjc4HbKFwIuk6SFkIAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwaKgS3vbdaz)0tdoislfC4yW0Wb8ARMhliQwQ1krplwCW0FwCiyh1zq)UNemJzE)8SqNPhiWJGplrapmG8ZsKsrN9tru7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bcuRPAPb7Dfhc2rTr(HHc0Owt1cG0G9Ukyai7NEAWbrAPGdhdMgoGxB18ybr1sTwZ8SyXbt)zXHGDutZrWn47EsWms07NNf6m9abEe8zjc4HbKFwIuk6SFkIAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvlnyVR4qWoQnYpmuGg1AQwJaLQBeakZOcgaY(PNgCquTMQLfhukQrhjH4SwZwRe9SyXbt)zXHGDuJYymYjm939KGzKdVFEwOZ0de4rWNLiGhgq(zjsPOZ(PiQDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn4GiTuWHJbtdhWRTAESGOAPwRS1AQwwCqPOgDKeIZAnBTs0ZIfhm9Nfhc2rnkJXiNW0F3tcMHaF)8SqNPhiWJGplrapmG8ZIgS3vaiF20z4Oc0Owt1cG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2FPwlnyVRmcCIUa1zxtcDafjlJEESGOABr1YIdMUIdb7OMEWZtHYGcWd1hKeR1uTuwlL1E8a9tf4mD2fOcDMEGa1AQwwCqPOgDKeIZA)Tw5qTuulHewlloOuuJoscXzT)wlbwlf1AQwkRT11gGo2ZObvCiyh10jjnhaKOFk0z6bculHew7XrdEkBKhNTYqC1A2ALicSwkEwS4GP)SmcCIUa1zxtcDG39KGzKtVFEwOZ0de4rWNLiGhgq(zrd27kaKpB6mCubAuRPAPSwkR94b6NkWz6Slqf6m9abQ1uTS4Gsrn6ijeN1(BTYHAPOwcjSwwCqPOgDKeIZA)TwcSwkQ1uTuwBRRnaDSNrdQ4qWoQPtsAoair)uOZ0deOwcjS2JJg8u2ipoBLH4Q1S1kreyTu8SyXbt)zXHGDutp459UNemtR49ZZIfhm9N1e0adpLYpl0z6bc8i47EsWmTW3ppl0z6bc8i4ZseWddi)SOb7Dfhc2rTWMJgunpwquTMLATuwlloOuuJoscXzTYz1kBTuuRPAdqh7z0GkoeSJA6KKMdas0pf6m9abQ1uThhn4PSrEC2kdXv7V1kre4ZIfhm9Nfhc2rnnhb3GV7jbZ0sE)8SqNPhiWJGplrapmG8ZIgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIEwS4GP)S4qWoQP5i4g8Dpjirs(9ZZcDMEGapc(Seb8WaYplAWExXHGDulS5ObvZJfevl1ALCTMQLYAfzoaYpxXHGDuBKFyOcKKH(SwZwRSeyTesyTTUwkRvKsrN9tru7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bculf1sXZIfhm9Nfhc2rDg0V7jbjs23ppl0z6bc8i4ZseWddi)SOS2a7boTz6bwlHewBRR9GcIGEtTuuRPAPb7Dfhc2rTWMJgunpwquTuRLgS3vCiyh1cBoAqfjlJEESGONfloy6plhpBm0hsAGZ7DpjirM59ZZcDMEGapc(Seb8WaYplAWExjgihcEEqVrfilUAnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1szTuw7Xd0pftAmGDOGpy6k0z6bcuRPAzXbLIA0rsioR93ABH1srTesyTS4Gsrn6ijeN1(BTeyTu8SyXbt)zXHGDutcNt4aNV7jbjsIE)8SqNPhiWJGplrapmG8ZIgS3vIbYHGNh0BubYIRwt1E8a9tXHGDuJc7uHotpqGAnvlasd27Qlbf26SRpButYnqfOrTMQLYApEG(PysJbSdf8btxHotpqGAjKWAzXbLIA0rsioR93ABj1sXZIfhm9Nfhc2rnjCoHdC(UNeKi5W7NNf6m9abEe8zjc4HbKFw0G9Usmqoe88GEJkqwC1AQ2JhOFkM0ya7qbFW0vOZ0deOwt1YIdkf1OJKqCw7V1khEwS4GP)S4qWoQjHZjCGZ39KGerGVFEwOZ0de4rWNLiGhgq(zrd27koeSJAHnhnOAESGOA)TwAWExXHGDulS5ObvKSm65XcIEwS4GP)S4qWoQrzmg5eM(7EsqIKtVFEwOZ0de4rWNLiGhgq(zrd27koeSJAHnhnOAESGOAPwlnyVR4qWoQf2C0Gkswg98ybr1AQwJaLQBeakzvCiyh10CeCd(SyXbt)zXHGDuJYymYjm939KGe1kE)8SG(HraACAy)zrYoRmeNzP2cjWNf0pmcqJtdjjraiF4Zs2Nfloy6pluAk4dM(ZcDMEGapc(U39SaWodoU3ppji77NNfloy6plrc6hgtdCmEwOZ0de4rW39KGzE)8SqNPhiWJGplrapmG8ZIYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXv7VuRTfk5Anvlj7SYqC1AwQ1kNiWAPOwcjSwkRT11E8a9tH(a2yFOJak0z6bcuRPAjzNvgIR2FPwBlKaRLINfloy6pls2zDds(UNeKO3ppl0z6bc8i4ZseWddi)SOb7Dfhc2rTr(HHc04zXIdM(ZYipy6V7jb5W7NNf6m9abEe8zjc4HbKFwbOJ9mAq1HKgzWd9hhgk0z6bcuRPAPb7DfkJndopy6kqJAnvlL1kYCaKFUIdb7O2i)Wqfid0UwcjSw6CoR1uTDyJ9PdKKH(S2FPwRCqY1sXZIfhm9N1bjr9hhgV7jbc89ZZcDMEGapc(Seb8WaYplAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5N)SyXbt)znGn23u3sdc0qI(9UNeKtVFEwOZ0de4rWNLiGhgq(zrd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8Nfloy6plAUrND9fqbrZ39KqR49ZZcDMEGapc(Seb8WaYplAWExXHGDuBKFyOanEwS4GP)SOXyIbrqV5Dpj0cF)8SqNPhiWJGplrapmG8ZIgS3vCiyh1g5hgkqJNfloy6pl6rMa6oy0(Dpj0sE)8SqNPhiWJGplrapmG8ZIgS3vCiyh1g5hgkqJNfloy6pRomq6rMaV7jbzL87NNf6m9abEe8zjc4HbKFw0G9UIdb7O2i)WqbA8SyXbt)zXUaNxWdTGhJ39KGSY((5zHotpqGhbFwIaEya5NfnyVR4qWoQnYpmuGgplwCW0FwGtudpKC(UNeK1mVFEwOZ0de4rWNfloy6pRMbda5lJPMMbAWNLiGhgq(zrd27koeSJAJ8ddfOrTesyTImha5NR4qWoQnYpmubsYqFwRzPwlbsG1AQwaKgS3vxckS1zxF2OMKBGkqJNf27O40otIpRMbda5lJPMMbAW39KGSs07NNf6m9abEe8zXIdM(ZcjnAhip0za4SlWNLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)sTwkRvwjQwIxBRO2wuTs5aY0duXg601GtSwkQ1uTImha5NRUeuyRZU(Srnj3avbsYqFw7VuRLYALvIQL412kQTfvRuoGm9avSHoDn4eRLINLZK4ZcjnAhip0za4SlW39KGSYH3ppl0z6bc8i4ZIfhm9NfqGmqhgOwkoN44zjc4HbKFwImha5NR4qWoQnYpmubsYqFwRzPwRzKCTesyTTUwPCaz6bQydD6AWjwl1ALTwcjSwkR9GKyTuRvY1AQwPCaz6bQ6WPn0B0Pb6yul1ALTwt1gGo2ZObvtOHD665LbPcDMEGa1sXZYzs8zbeid0HbQLIZjoE3tcYsGVFEwOZ0de4rWNfloy6pRzco0WghEy8Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR1SuRvIKCTesyTTUwPCaz6bQydD6AWjwl1AL9z5mj(SMj4qdBC4HX7Esqw507NNf6m9abEe8zXIdM(ZQz02WwNDnpNqs4Gpy6plrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZAnl1AnJKRLqcRT11kLditpqfBOtxdoXAPwRS1siH1szThKeRLATsUwt1kLditpqvhoTHEJonqhJAPwRS1AQ2a0XEgnOAcnStxpVmivOZ0deOwkEwotIpRMrBdBD218CcjHd(GP)UNeKTv8(5zHotpqGhbFwS4GP)SizbthOEAJ4PjbNqXZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2FPwlbwRPAPS2wxRuoGm9avD40g6n60aDmQLATYwlHew7bjXAnBTsKKRLINLZK4ZIKfmDG6PnINMeCcfV7jbzBHVFEwOZ0de4rWNfloy6plswW0bQN2iEAsWju8Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR9xQ1sG1AQwPCaz6bQ6WPn0B0Pb6yul1ALTwt1sd27Qa0rD21g5hgkqJAnvlnyVRcqh1zxBKFyOcKKH(S2FPwlL1kRKRvoRwcS2wuTbOJ9mAq1eAyNUEEzqQqNPhiqTuuRPApijw7V1krs(z5mj(SizbthOEAJ4PjbNqX7Esq2wY7NNf6m9abEe8zXIdM(ZAAZa5hcOZGwND9Lbj63ZseWddi)Soijwl1ALCTesyTuwRuoGm9avj4nHaOo7ArMdG8ZN1AQwkRvK5ai)Cfhc2rTr(HHkqsg6ZA)LATMPwcjS2oSX(0bsYqFw7V1kYCaKFUIdb7O2i)Wqfijd9zTuulfplNjXN10MbYpeqNbTo76lds0V39KGzK87NNf6m9abEe8zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZsWdb4Gpy6Z39KGzK99ZZcDMEGapc(Seb8WaYplwCqPOgDKeIZAnl1ALYbKPhOItuFC0GNwKG(9SMxaf3tcY(SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zXj(UNemJzE)8SqNPhiWJGplrapmG8ZsKsrN9tru7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bc8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zzZbz6TF3tcMrIE)8SqNPhiWJGplrapmG8ZskhqMEGkBwkQtd0rGAPwRKR1uTs5aY0du1HtBO3Otd0XOwt126APSwrkfD2pfrTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8z1HtBO3Otd0X4Dpjyg5W7NNf6m9abEe8zjc4HbKFws5aY0duzZsrDAGocul1ALCTMQT11szTIuk6SFkIAhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAP4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZknqhJ39KGziW3ppl0z6bc8i4ZseWddi)SADTuwRiLIo7NIO2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwkEwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SezoaYpF(UNemJC69ZZcDMEGapc(Seb8WaYplPCaz6bQ6qNhAAWWRLATsUwt126APSwrkfD2pfrTdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zf5Xhm939KGzAfVFEwOZ0de4rWNLiGhgq(zjLditpqvh68qtdgETuRv2AnvBRRLYAfPu0z)ue1oGSxRPAdqh7z0GkoeSJABoitVTcDMEGa1sXZIfhm9NLGhdnloy66bCEpRbCEANjXNvh68qtdg(7E3ZYiqrssZ37NNeK99ZZIfhm9Nfhc2rn0pCmqX9SqNPhiWJGV7jbZ8(5zXIdM(ZAcssMUMdb7OUZKWbKJNf6m9abEe8DpjirVFEwS4GP)SeP3sdgOMKDw3GKpl0z6bc8i47Esqo8(5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZItuFC0GNwKG(9SaWodoUNLe9UNeiW3ppl0z6bc8i4ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwO0uBiUNfa2zWX9SKLaF3tcYP3ppl0z6bc8i4ZknEwt8EwS4GP)SKYbKPh4ZskhANjXNLrGgGJHgLMplrapmG8ZIYAdqh7z0GQj0WoD98YGuHotpqGAnvlL1ksPOZ(PKI(z3oQLqcRvKsrN9t5OiYrga1siH1kshaeEkoeSJAJibGnTvOZ0deOwkQLINLuEaIACmXNLKFws5bi(SK9Dpj0kE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplPCODMeFw2SuuNgOJaplrapmG8ZIfhukQrhjH4SwZsTwPCaz6bQ4e1hhn4PfjOFplP8ae14yIplj)SKYdq8zj77EsOf((5zHotpqGhbFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SK8ZskhANjXNvh68qtdg(7EsOL8(5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZYMdY0BRNhlisFqs8zbGDgCCpRwY7Esqwj)(5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZIhFC7PE22fArMdG8ZNplaSZGJ7zj539KGSY((5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZkMAswgnao426Eg6lpYNfa2zWX9SiW39KGSM59ZZcDMEGapc(SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNvm1KSmAaCWT19m0rA8SaWodoUNfb(UNeKvIE)8SqNPhiWJGpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zftnjlJgahCBDpdnB8SaWodoUNLzK87Esqw5W7NNf6m9abEe8zLgpRaN49SyXbt)zjLditpWNLuo0otIplY80gbkqeqF5rQPB)SaWodoUNvl8Dpjilb((5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZImpnjlJgahCBDpd9Lh5Zca7m44EwYk539KGSYP3ppl0z6bc8i4ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwK5Pjzz0a4GBR7zOzJNfa2zWX9SKLaF3tcY2kE)8SqNPhiWJGpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXgAswgnao426Eg6lpYNLiGhgq(zjshaeEkoeSJAJibGnTFws5biQXXeFwYk5NLuEaIpljsYV7jbzBHVFEwOZ0de4rWNvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SydnjlJgahCBDpd9Lh5Zca7m44EwYk539KGSTK3ppl0z6bc8i4ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwSHMKLrdGdUTUNHMmVNfa2zWX9SmJKF3tcMrYVFEwOZ0de4rWNvA8SM49SyXbt)zjLditpWNLuEaIplZi5ALZQLYAjWABr1kshaeEkoeSJAJibGnTvOZ0deOwkEws5q7mj(SI0qtYYObWb3w3ZqF5r(UNemJSVFEwOZ0de4rWNvA8SM49SyXbt)zjLditpWNLuEaIplcSwIxRzKCTTOAPSwrkfD2pLdBSpDNXAjKWAPSwr6aGWtXHGDuBejaSPTcDMEGa1AQwwCqPOgDKeIZA)TwPCaz6bQ4e1hhn4PfjOF1srTuulXRvwcS2wuTuwRiLIo7NIO2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1YIdkf1OJKqCwRzPwRuoGm9avCI6JJg80Ie0VAP4zjLdTZK4Z6YJutYYObWb3w3ZqZgV7jbZyM3ppl0z6bc8i4ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLzKCTYz1szTTWABr1kshaeEkoeSJAJibGnTvOZ0deOwkEws5q7mj(SU8i1KSmAaCWT19m0rA8UNemJe9(5zHotpqGhbFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKtsUw5SAPSwsEEy0wlLhGyTTOALvYsUwkEwIaEya5NLiLIo7NYHn2NUZ4ZskhANjXNfnhb3GAs2zTH4E3tcMro8(5zHotpqGhbFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SAjeyTYz1szTK88WOTwkpaXABr1kRKLCTu8Seb8WaYplrkfD2pfrTdi7plPCODMeFw0CeCdQjzN1gI7Dpjygc89ZZcDMEGapc(SsJN1eVNfloy6plPCaz6b(SKYdq8z1cLCTYz1szTK88WOTwkpaXABr1kRKLCTu8Seb8WaYplPCaz6bQO5i4gutYoRnexTuRvYplPCODMeFw0CeCdQjzN1gI7Dpjyg507NNf6m9abEe8zLgpRaN49SyXbt)zjLditpWNLuo0otIpl2qtcDijiPMKDwBiUNfa2zWX9SKLaF3tcMPv8(5zHotpqGhbFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4Z6YJutYYOf2C0GZNfa2zWX9SmZ7EsWmTW3ppl0z6bc8i4ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwCI6lpsnjlJwyZrdoFwayNbh3ZYmV7jbZ0sE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFwYwBlQwkRfBbGqddeqHKgTdKh6maC2fyTesyTuw7Xd0pva6Oo7AJ8ddf6m9abQ1uTuw7Xd0pfhc2rnkStf6m9abQLqcRT11ksPOZ(PiQDazVwkQ1uTuwBRRvKsrN9t5OiYrga1siH1YIdkf1OJKqCwl1ALTwcjS2a0XEgnOAcnStxpVmivOZ0deOwkQ1uTTUwrkfD2pLu0p72rTuulfplPCODMeFwD40g6n60aDmE3tcsKKF)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFwylaeAyGakswW0bQN2iEAsWjuulHewl2caHggiGQzWaq(YyQPzGgSwcjSwSfacnmqavZGbG8LXutIa8yatVwcjSwSfacnmqafaherMPRbqbrAdWlWPaDbwlHewl2caHggiGc6traEm9a1Taq2pqsnakfkWAjKWAXwai0WabuZeCmW7GEJoaPBxlHewl2caHggiGAc60Jmb0mjE2TNxTesyTylaeAyGaQpMi0XyQ7r6a1siH1ITaqOHbcO6dMe1zxtZ3nWNLuo0otIpl2qNUgCIV7jbjs23pplwCW0FwKWiYqdj5g8zHotpqGhbF3tcsKzE)8SqNPhiWJGplrapmG8ZAMGdAOdOKMd(GdupZHu0pf6m9abQLqcRDMGdAOdOmaNh4a1yaACW0vOZ0de4zXIdM(ZQpWPTi4(9UNeKij69ZZcDMEGapc(Seb8WaYplrkfD2pfrTdi71AQ2a0XEgnOIdb7Og6DOdV2k0z6bcuRPAfPdacpfhc2rTrKaWM2k0z6bcuRPALYbKPhOIhFC7PE22fArMdG8ZN1AQwwCqPOgDKeIZA)TwPCaz6bQ4e1hhn4PfjOFplwCW0FwbOJ6SRnYpmE3tcsKC49ZZcDMEGapc(Seb8WaYpRwxRuoGm9avgbAaogAuAwl1ALTwt1gGo2ZObvaWPaAmGohT1IKKKDaf6m9abEwS4GP)S6rop6CCV7jbjIaF)8SqNPhiWJGplrapmG8ZQ11kLditpqLrGgGJHgLM1sTwzR1uTTU2a0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQLYABDTIuk6SFkPOF2TJAjKWALYbKPhOQdN2qVrNgOJrTu8SyXbt)zXHGDutp459UNeKi507NNf6m9abEe8zjc4HbKFwTUwPCaz6bQmc0aCm0O0SwQ1kBTMQT11gGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTIuk6SFkPOF2TJAnvBRRvkhqMEGQoCAd9gDAGogplwCW0FwKWiYyQZU(YGe97DpjirTI3ppl0z6bc8i4ZseWddi)SKYbKPhOYiqdWXqJsZAPwRSplwCW0FwO0uWhm939UNLiZbq(5Z3ppji77NNf6m9abEe8zXIdM(ZQh580EkLFwa4ueqJdM(ZQvdygWdsmbRfCc9MABc4C0UwOakgyTFWZUw2qvBl1eRfE1(bp7AV8iRnpBm(Gtu9Seb8WaYpRa0XEgnOQjGZrBnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALijxRPAfzoaYpxDjOWwND9zJAsUbQcKbAxRPAPSwAWExXHGDulS5ObvZJfev7VuRvkhqMEGQlpsnjlJwyZrdoR1uTuwlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9xQ12iaQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlJgahCBDpdnBulf1siH1szTTU2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRuoGm9avxEKAswgnao426EgA2OwkQLqcRvK5ai)Cfhc2rTr(HHkqsg6ZA)LATncGAPOwkE3tcM59ZZcDMEGapc(Seb8WaYpRa0XEgnOQjGZrBnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGmq7AnvlL126ApEG(PqFaBSp0raf6m9abQLqcRLYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXvRzPwBRqY1srTuuRPAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAnBTYk5AnvlnyVR4qWoQf2C0GQ5XcIQLAT0G9UIdb7OwyZrdQizz0ZJfevlf1siH1szTImha5NRUeuyRZU(Srnj3avbsYqFwl1ALCTMQLgS3vCiyh1cBoAq18ybr1sTwjxlf1srTMQLgS3vbOJ6SRnYpmua5NxRPAjzNvgIRwZsTwPCaz6bQydnj0HKGKAs2zTH4EwS4GP)S6ropTNs539KGe9(5zHotpqGhbFwIaEya5Nva6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1kYCaKFUIgS31aWPaAmGohT1IKKKDavGmq7AnvlnyVRaGtb0yaDoARfjjj7a6EKZtbKFETMQLYAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1cG0G9U6sqHTo76Zg1KCdubKFETuuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1k5AnvlL1sd27koeSJAHnhnOAESGOA)LATs5aY0duD5rQjzz0cBoAWzTMQLYAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sT2gbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTs5aY0duD5rQjzz0a4GBR7zOzJAPOwcjSwkRT11E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYYObWb3w3ZqZg1srTesyTImha5NR4qWoQnYpmubsYqFw7VuRTraulf1sXZIfhm9NvpY5rNJ7DpjihE)8SqNPhiWJGplrapmG8ZkaDSNrdQaGtb0yaDoARfjjj7ak0z6bcuRPAfzoaYpxrd27Aa4uangqNJ2ArssYoGkqgODTMQLgS3vaWPaAmGohT1IKKKDaDhgOci)8AnvRrGs1ncaLSQEKZJoh3ZIfhm9NvhgOMEWZ7DpjqGVFEwOZ0de4rWNfloy6plsyezm1zxFzqI(9SaWPiGghm9NvRYWO2wC(tTFWZU2wUvRf2RfE)N1kssO3ulOrTZmDvTTYETWR2p4yulnwl4ebQ9dE21(tETyZRvWZRw4v7CaBSVr7APXEg4ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKKH(S2FRvkhqMEGkY80gbkqeqF5rQPBxlHewlL1kLditpq1bjrnOFWHMnQ1S1kLditpqfzEAswgnao426EgA2Owt1kYCaKFU6sqHTo76Zg1KCdufijd9zTMTwPCaz6bQiZttYYObWb3w3ZqF5rwlfV7jb507NNf6m9abEe8zjc4HbKFwImha5NR4qWoQnYpmubYaTR1uTuwBRR94b6Nc9bSX(qhbuOZ0deOwcjSwkR94b6Nc9bSX(qhbuOZ0deOwt1sYoRmexTMLATTcjxlf1srTMQLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqfBOjzz0a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhliQwQ1sd27koeSJAHnhnOIKLrppwquTuulHewlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvY1AQwAWExXHGDulS5ObvZJfevl1ALCTuulf1AQwAWExfGoQZU2i)WqbKFETMQLKDwziUAnl1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(ZIegrgtD21xgKOFV7jHwX7NNf6m9abEe8zjc4HbKFws5aY0duLG3ecG6SRfzoaYpFwRPAPS2zcoOHoGsAo4doq9mhsr)uOZ0deOwcjS2zcoOHoGYaCEGduJbOXbtxHotpqGAP4zXIdM(ZQpWPTi4(9UNeAHVFEwOZ0de4rWNfloy6plaKpB6mC8zbGtranoy6pRwE8XTN1coXAbq(SPZWXA)GNDTSHQ2wzV2lpYAHZAdKbAxlpR9dhdZRLKjcRDcgyTxwRGNxTWRwASNbw7LhP6zjc4HbKFwImha5NRUeuyRZU(Srnj3avbYaTR1uT0G9UIdb7OwyZrdQMhliQ2FPwRuoGm9avxEKAswgTWMJgCwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwBJa4Dpj0sE)8SqNPhiWJGplrapmG8ZsK5ai)Cfhc2rTr(HHkqgODTMQLYABDThpq)uOpGn2h6iGcDMEGa1siH1szThpq)uOpGn2h6iGcDMEGa1AQws2zLH4Q1SuRTvi5APOwkQ1uTuwlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTMTwzLCTMQLgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIQLIAjKWAPSwrMdG8ZvxckS1zxF2OMKBGQazG21AQwAWExXHGDulS5ObvZJfevl1ALCTuulf1AQwAWExfGoQZU2i)WqbKFETMQLKDwziUAnl1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(Zca5ZModhF3tcYk53ppl0z6bc8i4ZIfhm9NvWaq2p90GdIEwa4ueqJdM(ZQLAI1on4GOAH9AV8iRLDGAzJA5aRn9Afa1YoqTFP))QLgRf0O2Eg1osVbJApB2R9SXAjzzQfahCBZRLKjc6n1obdS2pSwBwkwlF1oqEE1EFzTCiyhRvyZrdoRLDGApB(Q9YJS2pE6)VABPbNxTGteq9Seb8WaYplrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqvm1KSmAaCWT19m0xEK1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpqvm1KSmAaCWT19m0SrTMQLYApEG(Pcqh1zxBKFyOqNPhiqTMQLYAfzoaYpxfGoQZU2i)Wqfijd9zT)wlkdkapuFqsSwcjSwrMdG8ZvbOJ6SRnYpmubsYqFwRzRvkhqMEGQyQjzz0a4GBR7zOJ0OwkQLqcRT11E8a9tfGoQZU2i)WqHotpqGAPOwt1sd27koeSJAHnhnOAESGOAnBTMPwt1cG0G9U6sqHTo76Zg1KCdubKFETMQLgS3vbOJ6SRnYpmua5NxRPAPb7Dfhc2rTr(HHci)839KGSY((5zHotpqGhbFwS4GP)ScgaY(PNgCq0ZcaNIaACW0FwTutS2Pbhev7h8SRLnQ9Zg9AnY5espqvTTYETxEK1cN1gid0UwEw7hogMxljtew7emWAVSwbpVAHxT0ypdS2lps1ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKKH(S2FRfLbfGhQpijwRPAPb7Dfhc2rTWMJgunpwquT)sTwPCaz6bQU8i1KSmAHnhn4Swt1kYCaKFUIdb7O2i)Wqfijd9zT)wlL1IYGcWd1hKeRL41YIdMU6sqHTo76Zg1KCduHYGcWd1hKeRLI39KGSM59ZZcDMEGapc(Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR93Arzqb4H6dsI1AQwkRLYABDThpq)uOpGn2h6iGcDMEGa1siH1szThpq)uOpGn2h6iGcDMEGa1AQws2zLH4Q1SuRTvi5APOwkQ1uTuwlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTMTwPCaz6bQydnjlJgahCBDpd9LhzTMQLgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIQLIAjKWAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATsUwt1sd27koeSJAHnhnOAESGOAPwRKRLIAPOwt1sd27Qa0rD21g5hgkG8ZR1uTKSZkdXvRzPwRuoGm9avSHMe6qsqsnj7S2qC1sXZIfhm9NvWaq2p90GdIE3tcYkrVFEwOZ0de4rWNfloy6pRlbf26SRpButYnWNfaofb04GP)SAPMyTxEK1(bp7AzJAH9AH3)zTFWZg61E2yTKSm1cGdUTQ2wzVwppZRfCI1(bp7AJ0OwyV2ZgR94b6xTWzThte6Mxl7a1cV)ZA)GNn0R9SXAjzzQfahCB1ZseWddi)SOb7Dfhc2rTWMJgunpwquT)sTwPCaz6bQU8i1KSmAHnhn4Swt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwuguaEO(GKyTMQLKDwziUAnBTs5aY0duXgAsOdjbj1KSZAdXvRPAPb7Dva6Oo7AJ8ddfq(5V7jbzLdVFEwOZ0de4rWNLiGhgq(zrd27koeSJAHnhnOAESGOA)LATs5aY0duD5rQjzz0cBoAWzTMQ94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7VuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1A2ALYbKPhO6YJutYYObWb3w3ZqZgplwCW0FwxckS1zxF2OMKBGV7jbzjW3ppl0z6bc8i4ZseWddi)SOb7Dfhc2rTWMJgunpwquT)sTwPCaz6bQU8i1KSmAHnhn4Swt1szTTU2JhOFQa0rD21g5hgk0z6bculHewRiZbq(5Qa0rD21g5hgQajzOpR1S1kLditpq1LhPMKLrdGdUTUNHosJAPOwt1kLditpq1bjrnOFWHMnQ1S1kLditpq1LhPMKLrdGdUTUNHMnEwS4GP)SUeuyRZU(Srnj3aF3tcYkNE)8SqNPhiWJGplwCW0FwCiyh1g5hgplaCkcOXbt)z1snXAzJAH9AV8iRfoRn9Afa1YoqTFP))QLgRf0O2Eg1osVbJApB2R9SXAjzzQfahCBZRLKjc6n1obdS2ZMVA)WATzPyTONGn21sYoxl7a1E28v7zJbwlCwRNxT8iqgODTCTbOJ1M9AnYpmQfi)C1ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKKH(SwZwRuoGm9avSHMKLrdGdUTUNH(YJSwt1szTTUwrkfD2pLu0p72rTesyTImha5NRiHrKXuND9Lbj6Nkqsg6ZAnBTs5aY0duXgAswgnao426EgAY8QLIAnvlnyVR4qWoQf2C0GQ5XcIQLAT0G9UIdb7OwyZrdQizz0ZJfevRPAPb7Dva6Oo7AJ8ddfq(51AQws2zLH4Q1SuRvkhqMEGk2qtcDijiPMKDwBiU39KGSTI3ppl0z6bc8i4ZIfhm9Nva6Oo7AJ8dJNfaofb04GP)SAPMyTrAulSx7LhzTWzTPxRaOw2bQ9l9)xT0yTGg12ZO2r6nyu7zZETNnwljltTa4GBBETKmrqVP2jyG1E2yG1cN()RwEeid0UwU2a0XAbYpVw2bQ9S5Rw2O2V0)F1sJIKeRLLYWbtpWAbadO3uBa6O6zjc4HbKFw0G9UIdb7O2i)WqbKFETMQLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwZwRuoGm9avrAOjzz0a4GBR7zOV8iRLqcRvK5ai)Cfhc2rTr(HHkqsg6ZA)LATs5aY0duD5rQjzz0a4GBR7zOzJAPOwt1sd27koeSJAHnhnOAESGOAPwlnyVR4qWoQf2C0Gkswg98ybr1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kRzE3tcY2cF)8SqNPhiWJGplrapmG8ZskhqMEGQe8MqauNDTiZbq(5ZNfloy6pRPnSFqVrBKFy8UNeKTL8(5zHotpqGhbFwS4GP)SmcCIUa1zxtcDGNfaofb04GP)SAPMyTgjzTxw7SfaIiXeSw2RfL5cUwMUwOx7zJ16OmxTImha5Nx7h0bYpZRf0h4CwlrTdi71E2OxB6J21cagqVPwoeSJ1AKFyulaiw7L1ANF1sYoxRnO3eTRnyai7xTtdoiQw48zjc4HbKFwhpq)ubOJ6SRnYpmuOZ0deOwt1sd27koeSJAJ8ddfOrTMQLgS3vbOJ6SRnYpmubsYqFw7V12iauKSmV7jbZi53ppl0z6bc8i4ZseWddi)SaqAWExDjOWwND9zJAsUbQanQ1uTainyVRUeuyRZU(Srnj3avbsYqFw7V1YIdMUIdb7OMeoNWbovOmOa8q9bjXAnvBRRvKsrN9tru7aY(ZIfhm9NLrGt0fOo7AsOd8UNemJSVFEwOZ0de4rWNLiGhgq(zrd27Qa0rD21g5hgkqJAnvlnyVRcqh1zxBKFyOcKKH(S2FRTraOizzQ1uTImha5NRqPPGpy6QazG21AQwrMdG8ZvxckS1zxF2OMKBGQajzOpR1uTTUwrkfD2pfrTdi7plwCW0FwgborxG6SRjHoW7E3ZYMdY0B)(5jbzF)8SqNPhiWJGplwCW0FwO0uWhm9Nfaofb04GP)SAL9Ah5xTPxlj7CTSduRiZbq(5ZA5aRvKKqVPwqdZRTjRLTrgOw2bQfLMplrapmG8ZIKDwziUA)LATsKKR1uTs5aY0duLG3ecG6SRfzoaYpFwRPAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)wRSsUwkE3tcM59ZZcDMEGapc(SaWPiGghm9NfXmw7h7xTxw78ybr1AZbz6TRTdogTv1(Jnwl4eRn71kRCQ25XcIM1AJbwlCw7L1Ycrc6xT9mQ9SXApOGOAhy)Qn9ApBSwHn7ooQLDGApBSws4CchyTqV2(a2yFQNLiGhgq(zrzTs5aY0dunpwqK2MdY0BxlHew7bjXA)TwzLCTuuRPAPb7Dfhc2rTnhKP3wnpwquT)wRSYPNLWMH(Zs2Nfloy6ploeSJAs4Cch48DpjirVFEwOZ0de4rWNfloy6ploeSJAs4Cch48zbGtranoy6plIzB0RfCc9MALJinAhipQvoxa4SlqZRvWZRwU2o(vlkZfCTKW5eoWzTF2Wbw7hdpO3uBpJApBSwAWEVw(Q9SXANhhxTzV2ZgRTdBSVNLiGhgq(zHTaqOHbcOqsJ2bYdDgao7cSwt1EqsS2FRvIKCTMQ9YMMbQezoaYpFwRPAfzoaYpxHKgTdKh6maC2fOkqsg6ZAnBTYkNAH1AQ2wxlloy6kK0ODG8qNbGZUavaWjtpqG39KGC49ZZcDMEGapc(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZA)LATOmOa8q9bjXAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1APSwuguaEO(GKyTTOAntTuuRPAPS2wxl2caHggiGAMGJbEh0B0biD7AjKWAfPdacpfhc2rTrKaWM2QGDIQ1SuRLaRLqcRvK5ai)C1mbhd8oO3Odq62QajzOpR9xQ1szTOmOa8q9bjXABr1AMAPOwkEwS4GP)ScgaY(PNgCq07EsGaF)8SqNPhiWJGplrapmG8ZskhqMEGQwAW5PbNiGEAWbr1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1IYGcWd1hKeR1uTuwBRRfBbGqddeqntWXaVd6n6aKUDTesyTI0baHNIdb7O2isaytBvWor1AwQ1sG1siH1kYCaKFUAMGJbEh0B0biDBvGKm0N1(l1Arzqb4H6dsI1sXZIfhm9N1LGcBD21NnQj5g47Esqo9(5zHotpqGhbFwIaEya5NLrGs1ncaLSQlbf26SRpButYnWNfloy6ploeSJAJ8dJ39KqR49ZZcDMEGapc(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQvK5ai)CvWaq2p90GdIubsYqFw7VuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1AwQ1AgjxRPAPS2wxRiDaq4P4qWoQnIea20wHotpqGAjKWABDTs5aY0duXJpU9upB7cTiZbq(5ZAjKWAfzoaYpxDjOWwND9zJAsUbQcKKH(S2FPwlL1IYGcWd1hKeRTfvRzQLIAP4zXIdM(ZkaDuNDTr(HX7EsOf((5zHotpqGhbFwIaEya5NLuoGm9aviPr(HbcOP5i4gSwt1AeOuDJaqjRkaDuNDTr(HXZIfhm9NvWaq2p90GdIE3tcTK3ppl0z6bc8i4ZseWddi)SKYbKPhOQLgCEAWjcONgCquTMQT11kLditpqLDoaGEJ(YJ8zXIdM(Z6sqHTo76Zg1KCd8DpjiRKF)8SqNPhiWJGplrapmG8ZIgS3vCiyh1g5hgkG8ZR1uTuwRuoGm9avhKe1G(bhA2OwZwRej5AjKWAfzoaYpxfmaK9tpn4GivGKm0N1A2AL1m1srTMQLYABDTI0baHNIdb7O2isaytBf6m9abQLqcRT11kLditpqfp(42t9STl0Imha5NpRLINfloy6pRa0rD21g5hgV7jbzL99ZZcDMEGapc(Seb8WaYplPCaz6bQqsJ8ddeqtZrWnyTMQLYAPb7Dfhc2rTWMJgunpwquTMLATMPwcjSwrMdG8ZvCiyh1zqRcKbAxlf1AQwkRT11E8a9tfGoQZU2i)WqHotpqGAjKWAfzoaYpxfGoQZU2i)Wqfijd9zTMTwcSwkQ1uTs5aY0duHZdsYhcOzdTiZbq(51AwQ1krsUwt1szTTUwr6aGWtXHGDuBejaSPTcDMEGa1siH126ALYbKPhOIhFC7PE22fArMdG8ZN1sXZIfhm9NvWaq2p90GdIE3tcYAM3ppl0z6bc8i4ZIfhm9N1LGcBD21NnQj5g4ZcaNIaACW0FweZ2OxBa6o0BQ1isaytBZRfCI1E5rwlD7AH3eh9AHETzaGrTxwlpGnETWR2p4zxlB8Seb8WaYplPCaz6bQoijQb9do0SrT)wlbk5AnvRuoGm9avhKe1G(bhA2OwZwRej5AnvlL126AXwai0WabuZeCmW7GEJoaPBxlHewRiDaq4P4qWoQnIea20wfStuTMLATeyTu8UNeKvIE)8SqNPhiWJGplrapmG8ZskhqMEGQwAW5PbNiGEAWbr1AQwAWExXHGDulS5ObvZJfev7V1sd27koeSJAHnhnOIKLrppwq0ZIfhm9Nfhc2rDg0V7jbzLdVFEwOZ0de4rWNLiGhgq(zbG0G9Ukyai7NEAWbrAPGdhdMgoGxB18ybr1sTwaKgS3vbdaz)0tdoislfC4yW0Wb8ARizz0ZJfe9SyXbt)zXHGDutZrWn47Esqwc89ZZcDMEGapc(Seb8WaYplPCaz6bQAPbNNgCIa6PbhevlHewlL1cG0G9Ukyai7NEAWbrAPGdhdMgoGxBfOrTMQfaPb7DvWaq2p90GdI0sbhogmnCaV2Q5XcIQ93AbqAWExfmaK9tpn4GiTuWHJbtdhWRTIKLrppwquTu8SyXbt)zXHGDutp459UNeKvo9(5zHotpqGhbFwS4GP)S4qWoQZG(zbGtranoy6pRwQjwBg01METcGAb9boN1Yg1cN1kssO3ulOrTZm9NLiGhgq(zrd27koeSJAHnhnOAESGOA)TwjQwt1kLditpq1bjrnOFWHMnQ1S1kRKR1uTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1A2AjWAjKWABDTI0baHNIdb7O2isaytBf6m9abQLI39KGSTI3ppl0z6bc8i4ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVR4qWoQnYpmuGgV7jbzBHVFEwOZ0de4rWNfloy6ploeSJAAocUbFwa4ueqJdM(ZQv2R9dRTbVAnYpmQf6DWjm9AbadO3u7aCE1(H)hJATzPyTONGn21AZZdR9YABWR2S3RLRDEr6n1sZrWnyTaGb0BQ9SXAJ0qsSrTFqhi)EwIaEya5NfnyVRcqh1zxBKFyOanQ1uT0G9UkaDuNDTr(HHkqsg6ZA)LATS4GPR4qWoQjHZjCGtfkdkapuFqsSwt1sd27koeSJAJ8ddfOrTMQLgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIQ1uT0G9UIdb7O2MdY0BRMhliQwt1sd27kJ8ddn07Gty6kqJAnvlnyVROhzcmaNNc04DpjiBl59ZZcDMEGapc(SyXbt)zXHGDutp459SaWPiGghm9NvRSx7hwBdE1AKFyul07Gty61cagqVP2b48Q9d)pg1AZsXArpbBSR1MNhw7L12GxTzVxlx78I0BQLMJGBWAbadO3u7zJ1gPHKyJA)Goq(zETZS2p8)yuB6J21coXArpbBSRLEWZBwl0HhKhJ21EzTn4v7L12tWOwHnhn48zjc4HbKFw0G9UYiWj6cuNDnj0buGg1AQwkRLgS3vCiyh1cBoAq18ybr1(BT0G9UIdb7OwyZrdQizz0ZJfevlHewBRRLYAPb7DLr(HHg6DWjmDfOrTMQLgS3v0JmbgGZtbAulf1sX7EsWms(9ZZcDMEGapc(SyXbt)zze4eDbQZUMe6aplaCkcOXbt)z9JnwlnoVAbNyTzVwJKSw4S2lRfCI1cVAVS2waiuq0ODT0GWbqTcBoAWzTaGb0BQLnQL7hg1E2y7ABWRwaqsdeOw621E2yT2CqME7AP5i4g8zjc4HbKFw0G9UIdb7OwyZrdQMhliQ2FRLgS3vCiyh1cBoAqfjlJEESGOAnvlnyVR4qWoQnYpmuGgV7jbZi77NNf6m9abEe8zbGtranoy6plIzS2p2VAVS25XcIQ1MdY0BxBhCmARQ9hBSwWjwB2Rvw5uTZJfenR1gdSw4S2lRLfIe0VA7zu7zJ1Eqbr1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uplwCW0FwCiyh1KW5eoW5Zc6hgbOX9SK9zjSzO)SK9zjc4HbKFw0G9UIdb7O2MdY0BRMhliQ2FRvw50Zc6hgbOXPBgjnpEwY(UNemJzE)8SqNPhiWJGplrapmG8ZIgS3vCiyh1cBoAq18ybr1sTwAWExXHGDulS5ObvKSm65XcIQ1uTs5aY0duHKg5hgiGMMJGBWNfloy6ploeSJAAocUbF3tcMrIE)8SqNPhiWJGplrapmG8ZIKDwziUA)TwzjWNfloy6pluAk4dM(7EsWmYH3ppl0z6bc8i4ZIfhm9Nfhc2rn9GN3ZcaNIaACW0FwY58r7AbNyT0dEE1EzT0GWbqTcBoAWzTWETFyT8iqgODT2SuS2zsI12JKS2mOFwIaEya5NfnyVR4qWoQf2C0GQ5XcIQ1uT0G9UIdb7OwyZrdQMhliQ2FRLgS3vCiyh1cBoAqfjlJEESGO39KGziW3ppl0z6bc8i4ZcaNIaACW0FwY5dog1(bp7AzYAb9boN1Yg1cN1kssO3ulOrTSdu7h(pWAh5xTPxlj78ZIfhm9Nfhc2rnjCoHdC(SG(HraACplzFwcBg6plzFwIaEya5NvRRLYALYbKPhO6GKOg0p4qZg1(l1ALvY1AQws2zLH4Q93ALijxlfplOFyeGgNUzK084zj77EsWmYP3ppl0z6bc8i4ZcaNIaACW0FwTAKD4aN1(bp7Ah5xTK88WOT51AdBSR1MNhAETzulDE21sYTR1ZRwBwkwl6jyJDTKSZ1EzTtqdJmUATZVAjzNRf6h6tOuS2GbGSF1on4GOAfSxlnAETZS2p8)yul4eRTddSw6bpVAzhO2EKZJohxTF2Ox7i)Qn9AjzNFwS4GP)S6Wa10dEEV7jbZ0kE)8SyXbt)z1JCE054EwOZ0de4rW39UNLGhcWbFW0NVFEsq23ppl0z6bc8i4ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZskhqMEGkBwkQtd0rGAPwRKR1uTgbkv3iauYQqPPGpy61AQ2wxlL1gGo2ZObvtOHD665LbPcDMEGa1siH1gGo2ZObvhsAKbp0FCyOqNPhiqTu8SKYH2zs8zzZsrDAGoc8UNemZ7NNf6m9abEe8zLgpRjEplwCW0Fws5aY0d8zjLhG4Zs2NLiGhgq(zjLditpqLnlf1Pb6iqTuRvY1AQwAWExXHGDuBKFyOaYpVwt1kYCaKFUIdb7O2i)Wqfijd9zTMQLYAdqh7z0GQj0WoD98YGuHotpqGAjKWAdqh7z0GQdjnYGh6pomuOZ0deOwkEws5q7mj(SSzPOonqhbE3tcs07NNf6m9abEe8zLgpRjEplwCW0Fws5aY0d8zjLhG4Zs2NLiGhgq(zrd27koeSJAHnhnOAESGOAPwlnyVR4qWoQf2C0Gkswg98ybr1AQ2wxlnyVRcWbQZU(SdeNkqJAnvBh2yF6ajzOpR9xQ1szTuwlj7CTsQwwCW0vCiyh10dEEkroVAPO2wuTS4GPR4qWoQPh88uOmOa8q9bjXAP4zjLdTZK4ZQdDEOPbd)DpjihE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFw0G9UIdb7O2MdY0BRMhliQwZsTwzjWAjKWAPS2a0XEgnOIdb7OMojP5aGe9tHotpqGAnv7XrdEkBKhNTYqC1(BTsebwlfplaCkcOXbt)zjhbpBmQLRTdogTRDESGieOwBoitVDTzul0RfLbfGhwBWEdw7h8SRLGjjnhaKOFplPCODMeFwiPr(HbcOP5i4g8DpjqGVFEwOZ0de4rWNvA8SM49SyXbt)zjLditpWNLuo0otIpRbppnBObN4Zca7m44Ews(zjc4HbKFw0G9UIdb7O2i)WqbAuRPAPSwPCaz6bQg880SHgCI1sTwjxlHew7bjXAnl1ALYbKPhOAWZtZgAWjwlXRvwcSwkEws5bi(Soij(UNeKtVFEwOZ0de4rWNvA8SM49SyXbt)zjLditpWNLuEaIplkRvK5ai)Cfhc2rTr(HHcam4dMETTOAPSwzRvoRwkRvYkjlr12IQvKoai8uCiyh1grcaBARc2jQwkQLIAPOw5SAPS2dsI1kNvRuoGm9avdEEA2qdoXAP4zbGtranoy6pRwoeSJ12QrcaBAxBdukoRLRvkhqMEG1YKjOF1M9AfaH51sdE1(H)hJAbNyTCT9bF1IZdsYhm9ATXav1(Jnw7eskQ1isPqaeO2ajzOp1OmgO4qGArzmcCoHPxlqIZA98Q9ldIQ9dhJA7zuRrKaWM21caI1EzTNnwlnymV2168bgyTzV2ZgRvaeQNLuo0otIplCEqs(qanBOfzoaYp)Dpj0kE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFws5aY0duHZdsYhcOzdTiZbq(5plrapmG8ZsKoai8uCiyh1grcaBA)SKYH2zs8zDqsud6hCOzJ39Kql89ZZcDMEGapc(SsJN1eVNfloy6plPCaz6b(SKYdq8zjYCaKFUIdb7O2i)Wqfijd95ZseWddi)SADTI0baHNIdb7O2isaytBf6m9abEws5q7mj(SoijQb9do0SX7EsOL8(5zHotpqGhbFwPXZIKL5zXIdM(ZskhqMEGplPCODMeFwhKe1G(bhA24zjc4HbKFwuwRiZbq(5Qlbf26SRpButYnqvGKm0N1kNvRuoGm9avhKe1G(bhA2OwkQ93AnJKFwa4ueqJdM(ZIyg)pg1cGdUDTTCRwlOrTxwRzK8ef12ZO2FYRf)SKYdq8zjYCaKFU6sqHTo76Zg1KCdufijd957Esqwj)(5zHotpqGhbFwPXZIKL5zXIdM(ZskhqMEGplPCODMeFwhKe1G(bhA24zjc4HbKFwI0baHNIdb7O2isayt7AnvRiDaq4P4qWoQnIea20wfStuT)wlbwRPAXwai0WabuZeCmW7GEJoaPBxRPAfPu0z)ue1oGSxRPAdqh7z0GkoeSJABoitVTcDMEGaplaCkcOXbt)zzbDbwRCmiD7AHZANGc7A5AnYpm6GJAVa6eHxT9mQvo)Tdi7Mx7h(FmQDEqbr1EzTNnw79L1scDWdRv0wmWAb9doQ9dRTbVA5ATHn21IEc2yxBWor1M9AnIea20(zjLhG4ZsK5ai)C1mbhd8oO3Odq62QajzOpF3tcYk77NNf6m9abEe8zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsK5ai)C1LGcBD21NnQj5gOkqgODTMQvkhqMEGQdsIAq)GdnBu7V1Agj)SaWPiGghm9NfXm(FmQfahC7A)jVwCTGg1EzTMrYtuuBpJAB5w9zjLdTZK4ZYohaqVrF5r(UNeK1mVFEwOZ0de4rWNvA8SM49SyXbt)zjLditpWNLuEaIplkR1iqP6gbGswvWaq2p90GdIQLqcR1iqP6gbGYmQGbGSF6PbhevlHewRrGs1ncaLePcgaY(PNgCquTuuRPAbqAWExfmaK9tpn4GiTuWHJbtdhWRTci)8Nfaofb04GP)SKJzai7xTwgCquTajoR1ZRwijjca5dhTR1a8Qf0O2ZgRvk4WXGPHd41UwaKgS3RDM1cVAfSxlnwlaS3HcWXv7L1caNcm8ApB(Q9d)hyT8v7zJ1smbJ8SRvk4WXGPHd41U25XcIEws5q7mj(SAPbNNgCIa6Pbhe9UNeKvIE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFw0G9UIdb7O2i)WqbKFETMQLgS3vbOJ6SRnYpmua5NxRPAbqAWExDjOWwND9zJAsUbQaYpVwt126ALYbKPhOQLgCEAWjcONgCquTMQfaPb7DvWaq2p90GdI0sbhogmnCaV2kG8ZFws5q7mj(SsWBcbqD21Imha5NpF3tcYkhE)8SqNPhiWJGpR04znX7zXIdM(ZskhqMEGplP8aeFwbOJ9mAqfhc2rTnhKP3wHotpqGAnvlL1szTIuk6SFkIAhq2R1uTImha5NRcgaY(PNgCqKkqsg6ZA)TwPCaz6bQS5Gm9265XcI0hKeRLIAP4zjLdTZK4ZAESGiTnhKP3(DV7z1Hop00GH)(5jbzF)8SqNPhiWJGplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)SOb7DLyGCi45b9gvGS4E3tcM59ZZIfhm9Nfhc2rn9GN3ZcDMEGapc(UNeKO3pplwCW0FwCiyh10CeCd(SqNPhiWJGV7DV7zjfJjm9NemJKnJSswozMwYZ6Jdh6nZNfXCllhlHwPeiMsIRT2FSXAHKgzC12ZO2)2CqME7)1gylaegiqTZKeRLbVKKpeOwHn7n4uvYtSqhRvwjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQKNyHowRCqIRLasxkghcu7)lGor4PyAHsK5ai)8)1EzT)fzoaYpxX0I)1sPSYqHQKNyHowlbkX1saPlfJdbQ9)fqNi8umTqjYCaKF()AVS2)Imha5NRyAX)APuwzOqvYtSqhRTviX1saPlfJdbQ9ViDaq4PK7)AVS2)I0baHNsUk0z6bc8VwkLvgkuL8el0XALvYsCTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvjpXcDSwzLvIRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOk5jwOJ1kRSsCTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvjpXcDSwzLtsCTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvjFjpXCllhlHwPeiMsIRT2FSXAHKgzC12ZO2)D40g6n60aDm(xBGTaqyGa1otsSwg8ss(qGAf2S3GtvjpXcDSwzL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTuAgzOqvYtSqhR1msCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvjpXcDSwjsIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRCqIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowlbkX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhRvojX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)A5Rw5i5CeBTukRmuOk5jwOJ12sK4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ12sK4AjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlF1khjNJyRLszLHcvjpXcDSwznJexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLsZidfQsEIf6yTYsGsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XAnJKL4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQsEIf6yTMrIK4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTuAgzOqvYtSqhR1msKexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLVALJKZrS1sPSYqHQKNyHowRziqjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlF1khjNJyRLszLHcvjpXcDSwZiNK4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQs(sEI5wwowcTsjqmLexBT)yJ1cjnY4QTNrT)J84dM()AdSfacdeO2zsI1YGxsYhcuRWM9gCQk5jwOJ1kRexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYtSqhR1msCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALdsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvjpXcDSwcuIRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOk5jwOJ12sK4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQsEIf6yTY2cL4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQsEIf6yTY2cL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ1kBlrIRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOk5jwOJ1kBlrIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRzKSexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYtSqhR1mYkX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhR1mMrIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKVKNyULLJLqRucetjX1w7p2yTqsJmUA7zu7)0aDm(xBGTaqyGa1otsSwg8ss(qGAf2S3GtvjpXcDSwzL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ1AgjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQsEIf6yTYAgjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQKNyHowRSeOexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLVALJKZrS1sPSYqHQKNyHowRSYjjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlF1khjNJyRLszLHcvjpXcDSwzBfsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvjFjpXCllhlHwPeiMsIRT2FSXAHKgzC12ZO2)ayNbh3)AdSfacdeO2zsI1YGxsYhcuRWM9gCQk5jwOJ1AgjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPzKHcvjpXcDSw5GexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwzLdsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALvojX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhRv2wOexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwZygjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlF1khjNJyRLszLHcvjpXcDSwZirsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XAnJCqIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRziqjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQsEIf6yTMrojX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhR1mTcjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQs(sEI5wwowcTsjqmLexBT)yJ1cjnY4QTNrT)ncuKK089V2aBbGWabQDMKyTm4LK8Ha1kSzVbNQsEIf6yTYjjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQsEIf6yTYjjUwciDPyCiqT)fPdacpLC)x7L1(xKoai8uYvHotpqG)1sPSYqHQKNyHowRzKSexlbKUumoeO2)I0baHNsU)R9YA)lshaeEk5QqNPhiW)APuwzOqvYtSqhR1mYkX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhR1mYkX1saPlfJdbQ9ViDaq4PK7)AVS2)I0baHNsUk0z6bc8VwkLvgkuL8el0XAnJzK4AjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlLYkdfQsEIf6yTMPLiX1saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwknJmuOk5jwOJ1AMwIexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwjYmsCTeq6sX4qGA)ptWbn0buY9FTxw7)zcoOHoGsUk0z6bc8VwkLvgkuL8el0XALiZiX1saPlfJdbQ9)mbh0qhqj3)1EzT)Nj4Gg6ak5QqNPhiW)A5Rw5i5CeBTukRmuOk5jwOJ1krsKexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwjsIK4AjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlLYkdfQsEIf6yTsKCqIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1YxTYrY5i2APuwzOqvYtSqhRvIiqjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQsEIf6yTsKCsIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKVKNyULLJLqRucetjX1w7p2yTqsJmUA7zu7FrMdG8ZN)RnWwaimqGANjjwldEjjFiqTcB2BWPQKNyHowRSsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLsZidfQsEIf6yTYkX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhR1msCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLsZidfQsEIf6yTMrIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRejX1saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwknJmuOk5jwOJ1krsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALdsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALtsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLsZidfQsEIf6yTTcjUwciDPyCiqT)Nj4Gg6ak5(V2lR9)mbh0qhqjxf6m9ab(xlLMrgkuL8el0XABjsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLsZidfQsEIf6yTYkzjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPzKHcvjpXcDSwznJexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)AP0mYqHQKNyHowRSYbjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQKNyHowRSeOexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYtSqhRv2wIexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYxYtm3YYXsOvkbIPK4AR9hBSwiPrgxT9mQ9pN4)AdSfacdeO2zsI1YGxsYhcuRWM9gCQk5jwOJ1kRexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)AP0mYqHQKNyHowRSsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XAnJexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLsZidfQsEIf6yTsKexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)AP0mYqHQKNyHowRejX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhRvoiX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhRLaL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ1kNK4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ12kK4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ12cL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ12sK4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FTukRmuOk5jwOJ1kRKL4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLMrgkuL8el0XALvwjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPzKHcvjpXcDSwzLdsCTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLsZidfQsEIf6yTY2kK4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlF1khjNJyRLszLHcvjpXcDSwzBHsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALTLiX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhR1mswIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRzKvIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRzmJexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwZirsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XAnJCqIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRziqjUwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQKNyHowRziqjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLYkdfQsEIf6yTMrojX1saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuL8el0XAnJCsIRLasxkghcu7)a0XEgnOsU)R9YA)hGo2ZObvYvHotpqG)1sPSYqHQKNyHowRzAHsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwkLvgkuL8el0XALijlX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYtSqhRvImJexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYtSqhRvImJexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDSwjsIK4AjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLMrgkuL8el0XALi5GexlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvYxYtm3YYXsOvkbIPK4AR9hBSwiPrgxT9mQ9VGhcWbFW0N)RnWwaimqGANjjwldEjjFiqTcB2BWPQKNyHowRSsCTeq6sX4qGA)hGo2ZObvY9FTxw7)a0XEgnOsUk0z6bc8VwknJmuOk5jwOJ1AgjUwciDPyCiqT)dqh7z0Gk5(V2lR9Fa6ypJgujxf6m9ab(xlLMrgkuL8el0XALijUwciDPyCiqTwqscO2zB)yzQvoVQ9YAjwqUwaOu4eMETPbg8LrTukjkQLszLHcvjpXcDSw5GexlbKUumoeO2)bOJ9mAqLC)x7L1(paDSNrdQKRcDMEGa)RLszLHcvjpXcDS2wOexlbKUumoeO2)I0baHNsU)R9YA)lshaeEk5QqNPhiW)A5Rw5i5CeBTukRmuOk5jwOJ1kRKL4AjG0LIXHa1()cOteEkMwOezoaYp)FTxw7FrMdG8ZvmT4FTukRmuOk5jwOJ1kRKL4AjG0LIXHa1(paDSNrdQK7)AVS2)bOJ9mAqLCvOZ0de4FT8vRCKCoITwkLvgkuL8el0XALvoiX1saPlfJdbQ9Fa6ypJguj3)1EzT)dqh7z0Gk5QqNPhiW)APuwzOqvYxY3kjnY4qGALvY1YIdMETd48MQs(NfdE2z8SSGKGd(GPtab3VNLrKD4aFwedIrTTyUbRTLdb7yjpXGyuR8GJ21sGMxRzKSzKTKVKNyqmQLaSzVbNsCjpXGyuRCwTTutS2RTbuWJATGKeqT2SdmGEtTzVwHn7ooQf6hgbOXbtVwOppKbQn71(xWUahAwCW0)Rk5jgeJALZQLaSzVbRLdb7Og6DOdV21EzTCiyh12CqME7APeE16OumQ9d9R2bukwlpRLdb7Og6DOdV2uOk5l5zXbtFQmcuKK08rCQsIdb7Og6hogO4k5zXbtFQmcuKK08rCQsIdb7OUZKWbKJsEwCW0NkJafjjnFeNQKeP3sdgOMKDw3GKL8S4GPpvgbkssA(iovjjLditpqZDMePYjQpoAWtlsq)mpnOg4epZbWodooQsujploy6tLrGIKKMpItvss5aY0d0CNjrQO0uBioZtdQboXZCaSZGJJQSeyjploy6tLrGIKKMpItvss5aY0d0CNjrQgbAaogAuAAEAqDIN5Wovkdqh7z0GQj0WoD98YG0eLIuk6SFkPOF2TdcjuKsrN9t5OiYrgaesOiDaq4P4qWoQnIea20MckmxkparQYAUuEaIACmrQsUKNfhm9PYiqrssZhXPkjPCaz6bAUZKivBwkQtd0raZtdQt8mh2PYIdkf1OJKqCAwQs5aY0duXjQpoAWtlsq)mxkparQYAUuEaIACmrQsUKNfhm9PYiqrssZhXPkjPCaz6bAUZKi1o05HMgmCZtdQt8mxkparQsUKNfhm9PYiqrssZhXPkjPCaz6bAUZKivBoitVTEESGi9bjrZtdQboXZCaSZGJJAlPKNfhm9PYiqrssZhXPkjPCaz6bAUZKivE8XTN6zBxOfzoaYpFAEAqnWjEMdGDgCCuLCjploy6tLrGIKKMpItvss5aY0d0CNjrQXutYYObWb3w3ZqF5rAEAqnWjEMdGDgCCujWsEwCW0NkJafjjnFeNQKKYbKPhO5otIuJPMKLrdGdUTUNHosdZtdQboXZCaSZGJJkbwYZIdM(uzeOijP5J4uLKuoGm9an3zsKAm1KSmAaCWT19m0SH5Pb1aN4zoa2zWXr1msUKNfhm9PYiqrssZhXPkjPCaz6bAUZKivY80gbkqeqF5rQPBBEAqnWjEMdGDgCCuBHL8S4GPpvgbkssA(iovjjLditpqZDMePsMNMKLrdGdUTUNH(YJ080GAGt8mha7m44OkRKl5zXbtFQmcuKK08rCQsskhqMEGM7mjsLmpnjlJgahCBDpdnByEAqnWjEMdGDgCCuLLal5zXbtFQmcuKK08rCQsskhqMEGM7mjsLn0KSmAaCWT19m0xEKMNgudCIN5Wovr6aGWtXHGDuBejaSPT5s5bisvIKS5s5biQXXePkRKl5zXbtFQmcuKK08rCQsskhqMEGM7mjsLn0KSmAaCWT19m0xEKMNgudCIN5ayNbhhvzLCjploy6tLrGIKKMpItvss5aY0d0CNjrQSHMKLrdGdUTUNHMmpZtdQboXZCaSZGJJQzKCjploy6tLrGIKKMpItvss5aY0d0CNjrQrAOjzz0a4GBR7zOV8inpnOoXZCP8aePAgjlNrjb2IePdacpfhc2rTrKaWM2uuYZIdM(uzeOijP5J4uLKuoGm9an3zsK6LhPMKLrdGdUTUNHMnmpnOoXZCP8aePsGe3msUfrPiLIo7NYHn2NUZiHesPiDaq4P4qWoQnIea202eloOuuJoscX5Vs5aY0duXjQpoAWtlsq)OGcIllb2IOuKsrN9tru7aYUPa0XEgnOIdb7O2MdY0BBIfhukQrhjH40SuLYbKPhOItuFC0GNwKG(rrjploy6tLrGIKKMpItvss5aY0d0CNjrQxEKAswgnao426Eg6inmpnOoXZCP8aePAgjlNrzlSfjshaeEkoeSJAJibGnTPOKNfhm9PYiqrssZhXPkjPCaz6bAUZKivAocUb1KSZAdXzEAqDIN5WovrkfD2pLdBSpDNrZLYdqKQCsYYzusYZdJ2AP8aeBrYkzjtrjploy6tLrGIKKMpItvss5aY0d0CNjrQ0CeCdQjzN1gIZ80G6epZHDQIuk6SFkIAhq2nxkparQTecuoJssEEy0wlLhGylswjlzkk5zXbtFQmcuKK08rCQsskhqMEGM7mjsLMJGBqnj7S2qCMNguN4zoStvkhqMEGkAocUb1KSZAdXrvYMlLhGi1wOKLZOKKNhgT1s5bi2IKvYsMIsEwCW0NkJafjjnFeNQKKYbKPhO5otIuzdnj0HKGKAs2zTH4mpnOg4epZbWodooQYsGL8S4GPpvgbkssA(iovjjLditpqZDMePE5rQjzz0cBoAWP5Pb1aN4zoa2zWXr1mL8S4GPpvgbkssA(iovjjLditpqZDMePYjQV8i1KSmAHnhn4080GAGt8mha7m44OAMsEwCW0NkJafjjnFeNQKKYbKPhO5otIu7WPn0B0Pb6yyEAqDIN5s5bisv2weLylaeAyGakK0ODG8qNbGZUajKqkpEG(Pcqh1zxBKFyyIYJhOFkoeSJAuyNesyRfPu0z)ue1oGStHjkBTiLIo7NYrrKJmaiKqwCqPOgDKeItQYsiHbOJ9mAq1eAyNUEEzqsHPwlsPOZ(PKI(z3oOGIsEwCW0NkJafjjnFeNQKKYbKPhO5otIuzdD6AWjAEAqDIN5s5bisfBbGqddeqrYcMoq90gXttcoHccjeBbGqddeq1myaiFzm10mqdsiHylaeAyGaQMbda5lJPMeb4XaMoHeITaqOHbcOa4GiYmDnakisBaEbofOlqcjeBbGqddeqb9PiapMEG6wai7hiPgaLcfiHeITaqOHbcOMj4yG3b9gDas3MqcXwai0WabutqNEKjGMjXZU98iKqSfacnmqa1hte6ym19iDacjeBbGqddeq1hmjQZUMMVBGL8S4GPpvgbkssA(iovjrcJidnKKBWsEwCW0NkJafjjnFeNQK6dCAlcUFMd7uNj4Gg6akP5Gp4a1ZCif9JqcNj4Gg6akdW5boqngGghm9sEwCW0NkJafjjnFeNQKcqh1zxBKFyyoStvKsrN9tru7aYUPa0XEgnOIdb7Og6DOdV2MePdacpfhc2rTrKaWM2MKYbKPhOIhFC7PE22fArMdG8ZNMyXbLIA0rsio)vkhqMEGkor9XrdEArc6xjploy6tLrGIKKMpItvs9iNhDooZHDQTwkhqMEGkJanahdnknPkRPa0XEgnOcaofqJb05OTwKKKSduYZIdM(uzeOijP5J4uLehc2rn9GNN5Wo1wlLditpqLrGgGJHgLMuL1uRdqh7z0Gka4uangqNJ2ArssYoGjkBTiLIo7Nsk6ND7GqcLYbKPhOQdN2qVrNgOJbfL8S4GPpvgbkssA(iovjrcJiJPo76lds0pZHDQTwkhqMEGkJanahdnknPkRPwhGo2ZObvaWPaAmGohT1IKKKDatIuk6SFkPOF2TdtTwkhqMEGQoCAd9gDAGogL8S4GPpvgbkssA(iovjHstbFW0nh2PkLditpqLrGgGJHgLMuLTKVKNfhm9jXPkjrc6hgtdCmk5zXbtFsCQscCIAs2zDdsAoStLYJhOFk0hWg7dDeWej7SYqC)sTfkztKSZkdXzwQYjcKccjKYwF8a9tH(a2yFOJaMizNvgI7xQTqcKIsEwCW0NeNQKmYdMU5WovAWExXHGDuBKFyOank5zXbtFsCQs6GKO(JddZHDQbOJ9mAq1HKgzWd9hhgMOb7DfkJndopy6kqdtukYCaKFUIdb7O2i)Wqfid0MqcPZ50uh2yF6ajzOp)LQCqYuuYZIdM(K4uL0a2yFtDlniqdj6N5WovAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfq(5L8S4GPpjovjrZn6SRVakiAAoStLgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgkG8ZnbG0G9U6sqHTo76Zg1KCdubKFEjploy6tItvs0ymXGiO3yoStLgS3vCiyh1g5hgkqJsEwCW0NeNQKOhzcO7GrBZHDQ0G9UIdb7O2i)WqbAuYZIdM(K4uLuhgi9itaZHDQ0G9UIdb7O2i)WqbAuYZIdM(K4uLe7cCEbp0cEmmh2Psd27koeSJAJ8ddfOrjploy6tItvsGtudpKCAoStLgS3vCiyh1g5hgkqJsEwCW0NeNQKaNOgEiP5yVJIt7mjsTzWaq(YyQPzGg0CyNknyVR4qWoQnYpmuGgesOiZbq(5koeSJAJ8ddvGKm0NMLkbsGMaqAWExDjOWwND9zJAsUbQank5zXbtFsCQscCIA4HKM7mjsfjnAhip0za4SlqZHDQImha5NR4qWoQnYpmubsYqF(lvkLvIiEROfjLditpqfBOtxdorkmjYCaKFU6sqHTo76Zg1KCdufijd95VuPuwjI4TIwKuoGm9avSHoDn4ePOKNfhm9jXPkjWjQHhsAUZKivGazGomqTuCoXH5WovrMdG8ZvCiyh1g5hgQajzOpnlvZizcjS1s5aY0duXg601GtKQSesiLhKePkzts5aY0du1HtBO3Otd0XGQSMcqh7z0GQj0WoD98YGKIsEwCW0NeNQKaNOgEiP5otIuNj4qdBC4HH5WovrMdG8ZvCiyh1g5hgQajzOpnlvjsYesyRLYbKPhOIn0PRbNivzl5zXbtFsCQscCIA4HKM7mjsTz02WwNDnpNqs4Gpy6Md7ufzoaYpxXHGDuBKFyOcKKH(0SunJKjKWwlLditpqfBOtxdorQYsiHuEqsKQKnjLditpqvhoTHEJonqhdQYAkaDSNrdQMqd701Zldskk5zXbtFsCQscCIA4HKM7mjsLKfmDG6PnINMeCcfMd7ufzoaYpxXHGDuBKFyOcKKH(8xQeOjkBTuoGm9avD40g6n60aDmOklHeEqs0SsKKPOKNfhm9jXPkjWjQHhsAUZKivswW0bQN2iEAsWjuyoStvK5ai)Cfhc2rTr(HHkqsg6ZFPsGMKYbKPhOQdN2qVrNgOJbvznrd27Qa0rD21g5hgkqdt0G9UkaDuNDTr(HHkqsg6ZFPsPSswoJaBrbOJ9mAq1eAyNUEEzqsHPdsI)krsUKNfhm9jXPkjWjQHhsAUZKi1PndKFiGodAD21xgKOFMd7upijsvYesiLs5aY0duLG3ecG6SRfzoaYpFAIsrMdG8ZvCiyh1g5hgQajzOp)LQziKWoSX(0bsYqF(RiZbq(5koeSJAJ8ddvGKm0NuqrjpXGyulloy6tItvso(1tqhqh4mhsrZbNO(ZgoqTGNh0BOkR5WovAWExXHGDuBKFyOaniKqaKgS3vxckS1zxF2OMKBGkqdcjeipvWaq2p90GdIuhuqe0Bk5zXbtFsCQssWJHMfhmD9aopZDMePk4HaCWhm9zjploy6tItvscEm0S4GPRhW5zUZKivorZNxafhvznh2PYIdkf1OJKqCAwQs5aY0duXjQpoAWtlsq)k5zXbtFsCQssWJHMfhmD9aopZDMePAZbz6Tnh2PksPOZ(PiQDaz3ua6ypJguXHGDuBZbz6Tl5zXbtFsCQssWJHMfhmD9aopZDMeP2HtBO3Otd0XWCyNQuoGm9av2SuuNgOJauLSjPCaz6bQ6WPn0B0Pb6yyQ1uksPOZ(PiQDaz3ua6ypJguXHGDuBZbz6TPOKNfhm9jXPkjbpgAwCW01d48m3zsKAAGogMd7uLYbKPhOYMLI60aDeGQKn1AkfPu0z)ue1oGSBkaDSNrdQ4qWoQT5Gm92uuYZIdM(K4uLKGhdnloy66bCEM7mjsvK5ai)8P5Wo1wtPiLIo7NIO2bKDtbOJ9mAqfhc2rTnhKP3MIsEwCW0NeNQKe8yOzXbtxpGZZCNjrQrE8bt3CyNQuoGm9avDOZdnny4uLSPwtPiLIo7NIO2bKDtbOJ9mAqfhc2rTnhKP3MIsEwCW0NeNQKe8yOzXbtxpGZZCNjrQDOZdnny4Md7uLYbKPhOQdDEOPbdNQSMAnLIuk6SFkIAhq2nfGo2ZObvCiyh12CqMEBkk5l5zXbtFQ4eP2JCE054mh2PgGo2ZObvaWPaAmGohT1IKKKDatImha5NROb7DnaCkGgdOZrBTijjzhqfid02enyVRaGtb0yaDoARfjjj7a6EKZtbKFUjkPb7Dfhc2rTr(HHci)Ct0G9UkaDuNDTr(HHci)CtainyVRUeuyRZU(Srnj3ava5NtHjrMdG8ZvxckS1zxF2OMKBGQajzOpPkztusd27koeSJAHnhnOAESGOFPkLditpqfNO(YJutYYOf2C0Gttus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSmAaCWT19m0SbfesiLT(4b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswgnao426EgA2GccjuK5ai)Cfhc2rTr(HHkqsg6ZFP2iaOGIsEwCW0NkorItvsDyGA6bppZHDQugGo2ZObvaWPaAmGohT1IKKKDatImha5NROb7DnaCkGgdOZrBTijjzhqfid02enyVRaGtb0yaDoARfjjj7a6omqfq(5MmcuQUraOKv1JCE054OGqcPmaDSNrdQaGtb0yaDoARfjjj7aMoijsvYuuYZIdM(uXjsCQsQh580EkLnh2PgGo2ZObvnbCoARHcOyGMezoaYpxXHGDuBKFyOcKKH(0SsKKnjYCaKFU6sqHTo76Zg1KCdufijd9jvjBIsAWExXHGDulS5ObvZJfe9lvPCaz6bQ4e1xEKAswgTWMJgCAIskpEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)sTraysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLrdGdUTUNHMnOGqcPS1hpq)ubOJ6SRnYpmmjYCaKFUIdb7O2i)Wqfijd9PzLYbKPhO6YJutYYObWb3w3ZqZguqiHImha5NR4qWoQnYpmubsYqF(l1gbafuuYZIdM(uXjsCQsQh580EkLnh2PgGo2ZObvnbCoARHcOyGMezoaYpxXHGDuBKFyOcKKH(KQKnrjLukYCaKFU6sqHTo76Zg1KCdufijd9PzLYbKPhOIn0KSmAaCWT19m0xEKMOb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcIOGqcPuK5ai)C1LGcBD21NnQj5gOkqsg6tQs2enyVR4qWoQf2C0GQ5XcI(LQuoGm9avCI6lpsnjlJwyZrdoPGct0G9UkaDuNDTr(HHci)Ckk5zXbtFQ4ejovjXHGDutcNt4aNMd7ufPu0z)ue1oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTnhKP3wnpwq0VYsGMezoaYpxfmaK9tpn4GivGKm0N)svkhqMEGkBoitVTEESGi9bjrIJYGcWd1hKenjYCaKFU6sqHTo76Zg1KCdufijd95VuLYbKPhOYMdY0BRNhlisFqsK4OmOa8q9bjrIZIdMUkyai7NEAWbrkuguaEO(GKOjrMdG8ZvCiyh1g5hgQajzOp)LQuoGm9av2CqMEB98ybr6dsIehLbfGhQpijsCwCW0vbdaz)0tdoisHYGcWd1hKejoloy6Qlbf26SRpButYnqfkdkapuFqs0CHndDQYwYZIdM(uXjsCQs6sqHTo76Zg1KCd0CyNAa6ypJgunHg2PRNxgKMmcuQUraOKvHstbFW0l5zXbtFQ4ejovjXHGDuBKFyyoStnaDSNrdQMqd701ZldstuAeOuDJaqjRcLMc(GPtiHgbkv3iauYQUeuyRZU(Srnj3aPOKNfhm9PItK4uLeknf8bt3CyN6bjrZkrs2ua6ypJgunHg2PRNxgKMOb7Dfhc2rTWMJgunpwq0VuLYbKPhOItuF5rQjzz0cBoAWPjrMdG8ZvxckS1zxF2OMKBGQajzOpPkztImha5NR4qWoQnYpmubsYqF(l1gbqjploy6tfNiXPkjuAk4dMU5Wo1dsIMvIKSPa0XEgnOAcnStxpVminjYCaKFUIdb7O2i)Wqfijd9jvjBIskPuK5ai)C1LGcBD21NnQj5gOkqsg6tZkLditpqfBOjzz0a4GBR7zOV8inrd27koeSJAHnhnOAESGiQ0G9UIdb7OwyZrdQizz0ZJferbHesPiZbq(5Qlbf26SRpButYnqvGKm0NuLSjAWExXHGDulS5ObvZJfe9lvPCaz6bQ4e1xEKAswgTWMJgCsbfMOb7Dva6Oo7AJ8ddfq(5uyo0pmcqJtd7uPb7D1eAyNUEEzqQMhliIknyVRMqd701ZldsfjlJEESGiZH(HraACAijjca5dPkBjploy6tfNiXPkjsyezm1zxFzqI(zoStLsrMdG8ZvCiyh1g5hgQajzOpnRCGajKqrMdG8ZvCiyh1g5hgQajzOp)LQerHjrMdG8ZvxckS1zxF2OMKBGQajzOpPkztusd27koeSJAHnhnOAESGOFPkLditpqfNO(YJutYYOf2C0Gttus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwcKccjKYwF8a9tfGoQZU2i)WWKiZbq(5koeSJAJ8ddvGKm0NMLaPGqcfzoaYpxXHGDuBKFyOcKKH(8xQncakOOKNfhm9PItK4uLuWaq2p90GdImh2PkYCaKFU6sqHTo76Zg1KCdufijd95VOmOa8q9bjrtus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSmAaCWT19m0SbfesiLT(4b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswgnao426EgA2GccjuK5ai)Cfhc2rTr(HHkqsg6ZFP2iaOOKNfhm9PItK4uLuWaq2p90GdImh2PkYCaKFUIdb7O2i)Wqfijd95VOmOa8q9bjrtusjLImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQydnjlJgahCBDpd9LhPjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGikiKqkfzoaYpxDjOWwND9zJAsUbQcKKH(KQKnrd27koeSJAHnhnOAESGOFPkLditpqfNO(YJutYYOf2C0GtkOWenyVRcqh1zxBKFyOaYpNIsEwCW0NkorItvsaiF20z4O5WovrMdG8ZvCiyh1g5hgQajzOpPkztusjLImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQydnjlJgahCBDpd9LhPjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGikiKqkfzoaYpxDjOWwND9zJAsUbQcKKH(KQKnrd27koeSJAHnhnOAESGOFPkLditpqfNO(YJutYYOf2C0GtkOWenyVRcqh1zxBKFyOaYpNIsEwCW0NkorItvsxckS1zxF2OMKBGMd7uPKgS3vCiyh1cBoAq18ybr)svkhqMEGkor9LhPMKLrlS5ObNesOrGs1ncaLSQGbGSF6PbherHjkP84b6NkaDuNDTr(HHjrMdG8ZvbOJ6SRnYpmubsYqF(l1gbGjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswgnao426EgA2GccjKYwF8a9tfGoQZU2i)WWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlJgahCBDpdnBqbHekYCaKFUIdb7O2i)Wqfijd95VuBeauuYZIdM(uXjsCQsIdb7O2i)WWCyNkLukYCaKFU6sqHTo76Zg1KCdufijd9PzLYbKPhOIn0KSmAaCWT19m0xEKMOb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcIOGqcPuK5ai)C1LGcBD21NnQj5gOkqsg6tQs2enyVR4qWoQf2C0GQ5XcI(LQuoGm9avCI6lpsnjlJwyZrdoPGct0G9UkaDuNDTr(HHci)8sEwCW0NkorItvsbOJ6SRnYpmmh2Psd27Qa0rD21g5hgkG8ZnrjLImha5NRUeuyRZU(Srnj3avbsYqFAwZizt0G9UIdb7OwyZrdQMhliIknyVR4qWoQf2C0Gkswg98ybruqiHukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybr)svkhqMEGkor9LhPMKLrlS5ObNuqHjkfzoaYpxXHGDuBKFyOcKKH(0SYAgcjeaPb7D1LGcBD21NnQj5gOc0GIsEwCW0NkorItvstBy)GEJ2i)WWCyNQiZbq(5koeSJ6mOvbsYqFAwcKqcB9Xd0pfhc2rDg0L8S4GPpvCIeNQK4qWoQPh88mh2PksPOZ(PiQDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdoislfC4yW0Wb8ARMhliIQCWKrGs1ncaLSkoeSJ6mOnXIdkf1OJKqC(BROKNfhm9PItK4uLehc2rnnhb3GMd7ufPu0z)ue1oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTr(HHc0Weasd27QGbGSF6PbhePLcoCmyA4aETvZJfervouYZIdM(uXjsCQsIdb7OMEWZZCyNQiLIo7NIO2bKDtbOJ9mAqfhc2rTnhKP32enyVR4qWoQnYpmuGgMOeipvWaq2p90GdIubsYqFAw5eHecG0G9Ukyai7NEAWbrAPGdhdMgoGxBfObfMaqAWExfmaK9tpn4GiTuWHJbtdhWRTAESGOFLdMyXbLIA0rsioPkrL8S4GPpvCIeNQK4qWoQZG2CyNQiLIo7NIO2bKDtbOJ9mAqfhc2rTnhKP32enyVR4qWoQnYpmuGgMaqAWExfmaK9tpn4GiTuWHJbtdhWRTAESGiQsujploy6tfNiXPkjoeSJAAocUbnh2PksPOZ(PiQDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdoislfC4yW0Wb8ARMhliIQzk5zXbtFQ4ejovjXHGDuJYymYjmDZHDQIuk6SFkIAhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2i)WqbAyYiqP6gbGYmQGbGSF6PbhezIfhukQrhjH40Ssujploy6tfNiXPkjoeSJAugJroHPBoStvKsrN9tru7aYUPa0XEgnOIdb7O2MdY0BBIgS3vCiyh1g5hgkqdtainyVRcgaY(PNgCqKwk4WXGPHd41wnpwqevznXIdkf1OJKqCAwjQKNfhm9PItK4uLKrGt0fOo7AsOdyoStLgS3vaiF20z4Oc0Weasd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)LknyVRmcCIUa1zxtcDafjlJEESGOweloy6koeSJA6bppfkdkapuFqs0eLuE8a9tf4mD2fOjwCqPOgDKeIZFLduqiHS4Gsrn6ijeN)sGuyIYwhGo2ZObvCiyh10jjnhaKOFes4XrdEkBKhNTYqCMvIiqkk5zXbtFQ4ejovjXHGDutp45zoStLgS3vaiF20z4Oc0WeLuE8a9tf4mD2fOjwCqPOgDKeIZFLduqiHS4Gsrn6ijeN)sGuyIYwhGo2ZObvCiyh10jjnhaKOFes4XrdEkBKhNTYqCMvIiqkk5zXbtFQ4ejovjnbnWWtPCjploy6tfNiXPkjoeSJAAocUbnh2Psd27koeSJAHnhnOAESGiZsLswCqPOgDKeIt5mzPWua6ypJguXHGDutNK0CaqI(z64ObpLnYJZwziUFLicSKNfhm9PItK4uLehc2rnnhb3GMd7uPb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcIk5zXbtFQ4ejovjXHGDuNbT5WovAWExXHGDulS5ObvZJfervYMOuK5ai)Cfhc2rTr(HHkqsg6tZklbsiHTMsrkfD2pfrTdi7Mcqh7z0GkoeSJABoitVnfuuYZIdM(uXjsCQsYXZgd9HKg48mh2PszG9aN2m9ajKWwFqbrqVHct0G9UIdb7OwyZrdQMhliIknyVR4qWoQf2C0Gkswg98ybrL8S4GPpvCIeNQK4qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMcqh7z0GkoeSJABoitVTjkP84b6NIjngWouWhmDtS4Gsrn6ijeN)2cPGqczXbLIA0rsio)LaPOKNfhm9PItK4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZ0Xd0pfhc2rnkSttainyVRUeuyRZU(Srnj3avGgMO84b6NIjngWouWhmDcjKfhukQrhjH483wcfL8S4GPpvCIeNQK4qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMoEG(PysJbSdf8bt3eloOuuJoscX5VYHsEwCW0NkorItvsCiyh1OmgJCct3CyNknyVR4qWoQf2C0GQ5XcI(LgS3vCiyh1cBoAqfjlJEESGOsEwCW0NkorItvsCiyh1OmgJCct3CyNknyVR4qWoQf2C0GQ5XcIOsd27koeSJAHnhnOIKLrppwqKjJaLQBeakzvCiyh10CeCdwYZIdM(uXjsCQscLMc(GPBo0pmcqJtd7ujzNvgIZSuBHeO5q)WianonKKebG8HuLTKVKNfhm9PsWdb4Gpy6tQs5aY0d0CNjrQ2SuuNgOJaMNguN4zUuEaIuL1CyNQuoGm9av2SuuNgOJauLSjJaLQBeakzvO0uWhmDtTMYa0XEgnOAcnStxpVmijKWa0XEgnO6qsJm4H(Jddkk5zXbtFQe8qao4dM(K4uLKuoGm9an3zsKQnlf1Pb6iG5Pb1jEMlLhGivznh2PkLditpqLnlf1Pb6iavjBIgS3vCiyh1g5hgkG8ZnjYCaKFUIdb7O2i)Wqfijd9Pjkdqh7z0GQj0WoD98YGKqcdqh7z0GQdjnYGh6pomOOKNfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQDOZdnny4MNguN4zUuEaIuL1CyNknyVR4qWoQf2C0GQ5XcIOsd27koeSJAHnhnOIKLrppwqKPwtd27QaCG6SRp7aXPc0Wuh2yF6ajzOp)LkLusYolNxS4GPR4qWoQPh88uICEu0IyXbtxXHGDutp45Pqzqb4H6dsIuuYtmQvocE2yulxBhCmAx78ybriqT2CqME7AZOwOxlkdkapS2G9gS2p4zxlbtsAoair)k5zXbtFQe8qao4dM(K4uLKuoGm9an3zsKksAKFyGaAAocUbnpnOoXZCP8aePsd27koeSJABoitVTAESGiZsvwcKqcPmaDSNrdQ4qWoQPtsAoair)mDC0GNYg5XzRme3Vsebsrjploy6tLGhcWbFW0NeNQKKYbKPhO5otIuh880SHgCIMdGDgCCuLS5Pb1jEMd7uPb7Dfhc2rTr(HHc0WeLs5aY0dun45Pzdn4ePkzcj8GKOzPkLditpq1GNNMn0GtK4YsGuyUuEaIupijwYtmQTLdb7yTTAKaWM212aLIZA5ALYbKPhyTmzc6xTzVwbqyET0GxTF4)XOwWjwlxBFWxT48GK8btVwBmqvT)yJ1oHKIAnIukeabQnqsg6tnkJbkoeOwugJaNty61cK4SwpVA)YGOA)WXO2Eg1AejaSPDTaGyTxw7zJ1sdgZRDToFGbwB2R9SXAfaHQKNfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQ48GK8HaA2qlYCaKFU5Pb1jEMlLhGivkfzoaYpxXHGDuBKFyOaad(GP3IOuw5mkLSsYsulsKoai8uCiyh1grcaBARc2jIckOqoJYdsIYzs5aY0dun45Pzdn4ePOKNfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQhKe1G(bhA2W80G6epZHDQI0baHNIdb7O2isaytBZLYdqKQuoGm9av48GK8HaA2qlYCaKFEjploy6tLGhcWbFW0NeNQKKYbKPhO5otIupijQb9do0SH5Pb1jEMd7uBTiDaq4P4qWoQnIea202CP8aePkYCaKFUIdb7O2i)Wqfijd9zjpXOwIz8)yulao4212YTATGg1EzTMrYtuuBpJA)jVwCjploy6tLGhcWbFW0NeNQKKYbKPhO5otIupijQb9do0SH5PbvswgZLYdqKQiZbq(5Qlbf26SRpButYnqvGKm0NMd7uPuK5ai)C1LGcBD21NnQj5gOkqsg6t5mPCaz6bQoijQb9do0Sbf)AgjxYtmQ1c6cSw5yq621cN1obf21Y1AKFy0bh1Eb0jcVA7zuRC(Bhq2nV2p8)yu78GcIQ9YApBS27lRLe6GhwROTyG1c6hCu7hwBdE1Y1AdBSRf9eSXU2GDIQn71AejaSPDjploy6tLGhcWbFW0NeNQKKYbKPhO5otIupijQb9do0SH5PbvswgZLYdqK6fqNi8uZeCmW7GEJoaPBRezoaYpxfijd9P5Wovr6aGWtXHGDuBejaSPTjr6aGWtXHGDuBejaSPTkyNOFjqtylaeAyGaQzcog4DqVrhG0TnjsPOZ(PiQDaz3ua6ypJguXHGDuBZbz6Tl5jg1smJ)hJAbWb3U2FYRfxlOrTxwRzK8ef12ZO2wUvl5zXbtFQe8qao4dM(K4uLKuoGm9an3zsKQDoaGEJ(YJ080G6epZLYdqKQiZbq(5Qlbf26SRpButYnqvGmqBts5aY0duDqsud6hCOzJFnJKl5jg1khZaq2VATm4GOAbsCwRNxTqsseaYhoAxRb4vlOrTNnwRuWHJbtdhWRDTainyVx7mRfE1kyVwASwayVdfGJR2lRfaofy41E28v7h(pWA5R2ZgRLycg5zxRuWHJbtdhWRDTZJfevYZIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1wAW5PbNiGEAWbrMNguN4zUuEaIuP0iqP6gbGswvWaq2p90GdIiKqJaLQBeakZOcgaY(PNgCqeHeAeOuDJaqjrQGbGSF6PbherHjaKgS3vbdaz)0tdoislfC4yW0Wb8ARaYpVKNfhm9PsWdb4Gpy6tItvss5aY0d0CNjrQj4nHaOo7ArMdG8ZNMNguN4zUuEaIuPb7Dfhc2rTr(HHci)Ct0G9UkaDuNDTr(HHci)CtainyVRUeuyRZU(Srnj3ava5NBQ1s5aY0du1sdopn4eb0tdoiYeasd27QGbGSF6PbhePLcoCmyA4aETva5NxYZIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi15XcI02CqMEBZtdQt8mxkparQbOJ9mAqfhc2rTnhKP32eLuksPOZ(PiQDaz3KiZbq(5QGbGSF6PbhePcKKH(8xPCaz6bQS5Gm9265XcI0hKePGIs(sEIrTTAaZaEqIjyTGtO3uBtaNJ21cfqXaR9dE21YgQABPMyTWR2p4zx7LhzT5zJXhCIQsEwCW0NkrMdG8ZNu7ropTNszZHDQbOJ9mAqvtaNJ2AOakgOjrMdG8ZvCiyh1g5hgQajzOpnRejztImha5NRUeuyRZU(Srnj3avbYaTnrjnyVR4qWoQf2C0GQ5XcI(LQuoGm9avxEKAswgTWMJgCAIskpEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)sTraysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLrdGdUTUNHMnOGqcPS1hpq)ubOJ6SRnYpmmjYCaKFUIdb7O2i)Wqfijd9PzLYbKPhO6YJutYYObWb3w3ZqZguqiHImha5NR4qWoQnYpmubsYqF(l1gbafuuYZIdM(ujYCaKF(K4uLupY5P9ukBoStnaDSNrdQAc4C0wdfqXanjYCaKFUIdb7O2i)Wqfid02eLT(4b6Nc9bSX(qhbiKqkpEG(PqFaBSp0ratKSZkdXzwQTcjtbfMOKsrMdG8ZvxckS1zxF2OMKBGQajzOpnRSs2enyVR4qWoQf2C0GQ5XcIOsd27koeSJAHnhnOIKLrppwqefesiLImha5NRUeuyRZU(Srnj3avbsYqFsvYMOb7Dfhc2rTWMJgunpwqevjtbfMOb7Dva6Oo7AJ8ddfq(5MizNvgIZSuLYbKPhOIn0KqhscsQjzN1gIRKNfhm9PsK5ai)8jXPkPEKZJohN5Wo1a0XEgnOcaofqJb05OTwKKKSdysK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG2MOb7DfaCkGgdOZrBTijjzhq3JCEkG8ZnrjnyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBcaPb7D1LGcBD21NnQj5gOci)CkmjYCaKFU6sqHTo76Zg1KCdufijd9jvjBIsAWExXHGDulS5ObvZJfe9lvPCaz6bQU8i1KSmAHnhn40eLuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LAJaWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlJgahCBDpdnBqbHeszRpEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLrdGdUTUNHMnOGqcfzoaYpxXHGDuBKFyOcKKH(8xQncakOOKNfhm9PsK5ai)8jXPkPomqn9GNN5Wo1a0XEgnOcaofqJb05OTwKKKSdysK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG2MOb7DfaCkGgdOZrBTijjzhq3HbQaYp3KrGs1ncaLSQEKZJohxjpXO2wLHrTT48NA)GNDTTCRwlSxl8(pRvKKqVPwqJANz6QABL9AHxTFWXOwASwWjcu7h8SR9N8AXMxRGNxTWR25a2yFJ21sJ9mWsEwCW0NkrMdG8ZNeNQKiHrKXuND9Lbj6N5WovrMdG8ZvxckS1zxF2OMKBGQajzOp)vkhqMEGkY80gbkqeqF5rQPBtiHukLditpq1bjrnOFWHMnmRuoGm9avK5Pjzz0a4GBR7zOzdtImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQiZttYYObWb3w3ZqF5rsrjploy6tLiZbq(5tItvsKWiYyQZU(YGe9ZCyNQiZbq(5koeSJAJ8ddvGmqBtu26JhOFk0hWg7dDeGqcP84b6Nc9bSX(qhbmrYoRmeNzP2kKmfuyIskfzoaYpxDjOWwND9zJAsUbQcKKH(0Ss5aY0duXgAswgnao426Eg6lpst0G9UIdb7OwyZrdQMhliIknyVR4qWoQf2C0Gkswg98ybruqiHukYCaKFU6sqHTo76Zg1KCdufijd9jvjBIgS3vCiyh1cBoAq18ybruLmfuyIgS3vbOJ6SRnYpmua5NBIKDwzioZsvkhqMEGk2qtcDijiPMKDwBiUsEwCW0NkrMdG8ZNeNQK6dCAlcUFMd7uLYbKPhOkbVjea1zxlYCaKF(0eLZeCqdDaL0CWhCG6zoKI(riHZeCqdDaLb48ahOgdqJdMofL8eJAB5Xh3Ewl4eRfa5ZModhR9dE21YgQABL9AV8iRfoRnqgODT8S2pCmmVwsMiS2jyG1EzTcEE1cVAPXEgyTxEKQsEwCW0NkrMdG8ZNeNQKaq(SPZWrZHDQImha5NRUeuyRZU(Srnj3avbYaTnrd27koeSJAHnhnOAESGOFPkLditpq1LhPMKLrlS5ObNMezoaYpxXHGDuBKFyOcKKH(8xQncGsEwCW0NkrMdG8ZNeNQKaq(SPZWrZHDQImha5NR4qWoQnYpmubYaTnrzRpEG(PqFaBSp0racjKYJhOFk0hWg7dDeWej7SYqCMLARqYuqHjkPuK5ai)C1LGcBD21NnQj5gOkqsg6tZkRKnrd27koeSJAHnhnOAESGiQ0G9UIdb7OwyZrdQizz0ZJferbHesPiZbq(5Qlbf26SRpButYnqvGmqBt0G9UIdb7OwyZrdQMhliIQKPGct0G9UkaDuNDTr(HHci)CtKSZkdXzwQs5aY0duXgAsOdjbj1KSZAdXvYtmQTLAI1on4GOAH9AV8iRLDGAzJA5aRn9Afa1YoqTFP))QLgRf0O2Eg1osVbJApB2R9SXAjzzQfahCBZRLKjc6n1obdS2pSwBwkwlF1oqEE1EFzTCiyhRvyZrdoRLDGApB(Q9YJS2pE6)VABPbNxTGteqvYZIdM(ujYCaKF(K4uLuWaq2p90GdImh2PkYCaKFU6sqHTo76Zg1KCdufijd9PzLYbKPhOkMAswgnao426Eg6lpstImha5NR4qWoQnYpmubsYqFAwPCaz6bQIPMKLrdGdUTUNHMnmr5Xd0pva6Oo7AJ8ddtukYCaKFUkaDuNDTr(HHkqsg6ZFrzqb4H6dsIesOiZbq(5Qa0rD21g5hgQajzOpnRuoGm9avXutYYObWb3w3ZqhPbfesyRpEG(Pcqh1zxBKFyqHjAWExXHGDulS5ObvZJfezwZycaPb7D1LGcBD21NnQj5gOci)Ct0G9UkaDuNDTr(HHci)Ct0G9UIdb7O2i)WqbKFEjpXO2wQjw70GdIQ9dE21Yg1(zJETg5CcPhOQ2wzV2lpYAHZAdKbAxlpR9dhdZRLKjcRDcgyTxwRGNxTWRwASNbw7LhPQKNfhm9PsK5ai)8jXPkPGbGSF6PbhezoStvK5ai)C1LGcBD21NnQj5gOkqsg6ZFrzqb4H6dsIMOb7Dfhc2rTWMJgunpwq0VuLYbKPhO6YJutYYOf2C0GttImha5NR4qWoQnYpmubsYqF(lLOmOa8q9bjrIZIdMU6sqHTo76Zg1KCduHYGcWd1hKePOKNfhm9PsK5ai)8jXPkPGbGSF6PbhezoStvK5ai)Cfhc2rTr(HHkqsg6ZFrzqb4H6dsIMOKYwF8a9tH(a2yFOJaesiLhpq)uOpGn2h6iGjs2zLH4ml1wHKPGctusPiZbq(5Qlbf26SRpButYnqvGKm0NMvkhqMEGk2qtYYObWb3w3ZqF5rAIgS3vCiyh1cBoAq18ybruPb7Dfhc2rTWMJgurYYONhliIccjKsrMdG8ZvxckS1zxF2OMKBGQajzOpPkzt0G9UIdb7OwyZrdQMhliIQKPGct0G9UkaDuNDTr(HHci)CtKSZkdXzwQs5aY0duXgAsOdjbj1KSZAdXrrjpXO2wQjw7LhzTFWZUw2OwyVw49Fw7h8SHETNnwljltTa4GBRQTv2R1ZZ8AbNyTFWZU2inQf2R9SXApEG(vlCw7XeHU51YoqTW7)S2p4zd9ApBSwswMAbWb3wvYZIdM(ujYCaKF(K4uL0LGcBD21NnQj5gO5WovAWExXHGDulS5ObvZJfe9lvPCaz6bQU8i1KSmAHnhn40KiZbq(5koeSJAJ8ddvGKm0N)sfLbfGhQpijAIKDwzioZkLditpqfBOjHoKeKutYoRneNjAWExfGoQZU2i)WqbKFEjploy6tLiZbq(5tItvsxckS1zxF2OMKBGMd7uPb7Dfhc2rTWMJgunpwq0VuLYbKPhO6YJutYYOf2C0Gtthpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6ZFPIYGcWd1hKenjLditpq1bjrnOFWHMnmRuoGm9avxEKAswgnao426EgA2OKNfhm9PsK5ai)8jXPkPlbf26SRpButYnqZHDQ0G9UIdb7OwyZrdQMhli6xQs5aY0duD5rQjzz0cBoAWPjkB9Xd0pva6Oo7AJ8ddcjuK5ai)Cva6Oo7AJ8ddvGKm0NMvkhqMEGQlpsnjlJgahCBDpdDKguyskhqMEGQdsIAq)GdnBywPCaz6bQU8i1KSmAaCWT19m0SrjpXO2wQjwlBulSx7LhzTWzTPxRaOw2bQ9l9)xT0yTGg12ZO2r6nyu7zZETNnwljltTa4GBBETKmrqVP2jyG1E28v7hwRnlfRf9eSXUws25AzhO2ZMVApBmWAHZA98QLhbYaTRLRnaDS2SxRr(HrTa5NRk5zXbtFQezoaYpFsCQsIdb7O2i)WWCyNQiZbq(5Qlbf26SRpButYnqvGKm0NMvkhqMEGk2qtYYObWb3w3ZqF5rAIYwlsPOZ(PKI(z3oiKqrMdG8ZvKWiYyQZU(YGe9tfijd9PzLYbKPhOIn0KSmAaCWT19m0K5rHjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGit0G9UkaDuNDTr(HHci)CtKSZkdXzwQs5aY0duXgAsOdjbj1KSZAdXvYtmQTLAI1gPrTWETxEK1cN1METcGAzhO2V0)F1sJ1cAuBpJAhP3GrTNn71E2yTKSm1cGdUT51sYeb9MANGbw7zJbwlC6)VA5rGmq7A5AdqhRfi)8AzhO2ZMVAzJA)s))vlnkssSwwkdhm9aRfamGEtTbOJQsEwCW0NkrMdG8ZNeNQKcqh1zxBKFyyoStLgS3vCiyh1g5hgkG8ZnrPiZbq(5Qlbf26SRpButYnqvGKm0NMvkhqMEGQin0KSmAaCWT19m0xEKesOiZbq(5koeSJAJ8ddvGKm0N)svkhqMEGQlpsnjlJgahCBDpdnBqHjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGitImha5NR4qWoQnYpmubsYqFAwzntjploy6tLiZbq(5tItvstBy)GEJ2i)WWCyNQuoGm9avj4nHaOo7ArMdG8ZNL8eJABPMyTgjzTxw7SfaIiXeSw2RfL5cUwMUwOx7zJ16OmxTImha5Nx7h0bYpZRf0h4CwlrTdi71E2OxB6J21cagqVPwoeSJ1AKFyulaiw7L1ANF1sYoxRnO3eTRnyai7xTtdoiQw4SKNfhm9PsK5ai)8jXPkjJaNOlqD21KqhWCyN6Xd0pva6Oo7AJ8ddt0G9UIdb7O2i)WqbAyIgS3vbOJ6SRnYpmubsYqF(BJaqrYYuYZIdM(ujYCaKF(K4uLKrGt0fOo7AsOdyoStfaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)YIdMUIdb7OMeoNWbovOmOa8q9bjrtTwKsrN9tru7aYEjploy6tLiZbq(5tItvsgborxG6SRjHoG5WovAWExfGoQZU2i)WqbAyIgS3vbOJ6SRnYpmubsYqF(BJaqrYYysK5ai)Cfknf8btxfid02KiZbq(5Qlbf26SRpButYnqvGKm0NMATiLIo7NIO2bK9s(sEwCW0NQo05HMgmCQCiyh1KW5eoWP5WovAWExjgihcEEqVrfiloZf2m0PkBjploy6tvh68qtdgoXPkjoeSJA6bpVsEwCW0NQo05HMgmCItvsCiyh10CeCdwYxYtmQLy2g9Adq3HEtTi8SXO2ZgR1YQ2mQ9hI5Ahyd6aCaXP51(H1(X(v7L1khjnRLg7zG1E2yT)KxlwsTCRw7h0bYpvTTutSw4vlpRDMPxlpRvooB1AT5zTDOdN2iqTjyu7h(xkw70a9R2emQvyZrdol5zXbtFQ6WPn0B0Pb6yqfLMc(GPBoStLYa0XEgnO6qsJm4H(JddcjKYa0XEgnOAcnStxpVmin1APCaz6bQmc0aCm0O0KQSuqHjkPb7Dva6Oo7AJ8ddfq(5esOrGs1ncaLSkoeSJAAocUbPWKiZbq(5Qa0rD21g5hgQajzOpl5jg12k71(H)LI12HoCAJa1MGrTImha5Nx7h0bYVzTSdu70a9R2emQvyZrdonVwJaMb8GetWALJKM1MsXOwukgTpBO3uloMyjploy6tvhoTHEJonqhdItvsO0uWhmDZHDQhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6ttImha5NR4qWoQnYpmubsYqFAIgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgkG8ZnzeOuDJaqjRIdb7OMMJGBWsEwCW0NQoCAd9gDAGogeNQK6Wa10dEEMd7udqh7z0Gka4uangqNJ2ArssYoGjAWExbaNcOXa6C0wlsss2b09iNNc0OKNfhm9PQdN2qVrNgOJbXPkPEKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAIKDwzioZ2siWsEwCW0NQoCAd9gDAGogeNQK4qWoQjHZjCGtZHDQbOJ9mAqfhc2rTnhKP32enyVR4qWoQT5Gm92Q5XcI(LgS3vCiyh12CqMEBfjlJEESGitusjnyVR4qWoQnYpmua5NBsK5ai)Cfhc2rTr(HHkqgOnfesiasd27Qlbf26SRpButYnqfObfMlSzOtv2sEwCW0NQoCAd9gDAGogeNQKcqh1zxBKFyyoStnaDSNrdQMqd701ZldYsEwCW0NQoCAd9gDAGogeNQK4qWoQZG2CyNQiZbq(5Qa0rD21g5hgQazG2L8S4GPpvD40g6n60aDmiovjXHGDutp45zoStvK5ai)Cva6Oo7AJ8ddvGmqBt0G9UIdb7OwyZrdQMhli6xAWExXHGDulS5ObvKSm65XcIk5zXbtFQ6WPn0B0Pb6yqCQsca5ZModhnh2P26a0XEgnO6qsJm4H(JddcjuKoai8unW(PZU(Sr9akSl5zXbtFQ6WPn0B0Pb6yqCQskaDuNDTr(HrjpXO2wzV2p8FG1YxTKSm1opwq0S2Sxlbqa1YoqTFyT2Su0)F1corGABX5p12gpZRfCI1Y1opwquTxwRrGsr)QLe0f2qVPwqFGZzTbO7qVP2ZgRLyAoitVDTdSbDaoAxYZIdM(u1HtBO3Otd0XG4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZenyVRedKdbppO3OMhliIknyVRedKdbppO3Oizz0ZJfezsKsrN9tjf9ZUDysK5ai)CfjmImM6SRVmir)ubYaTn1APCaz6bQqsJ8ddeqtZrWnOjrMdG8ZvCiyh1g5hgQazG2L8eJALqgK8y0U2pSwdgg1AKhm9AbNyTFWZU2wUvnVwAWRw4v7hCmQDWZR2r6n1IEc2yxBpJAPZZU2ZgRvooB1AzhO2wUvR9d6a53SwqFGZzTbO7qVP2ZgR1YQ2mQ9hI5Ahyd6aCaXzjploy6tvhoTHEJonqhdItvsg5bt3CyNARdqh7z0GQdjnYGh6pommrzRdqh7z0GQj0WoD98YGKqcLYbKPhOYiqdWXqJstQYsrjploy6tvhoTHEJonqhdItvsaiF20z4O5WovAWExfGoQZU2i)WqbKFoHeAeOuDJaqjRIdb7OMMJGBWsEwCW0NQoCAd9gDAGogeNQKcgaY(PNgCqK5WovAWExfGoQZU2i)WqbKFoHeAeOuDJaqjRIdb7OMMJGBWsEwCW0NQoCAd9gDAGogeNQKiHrKXuND9Lbj6N5WovAWExfGoQZU2i)Wqfijd95VukNiUzArbOJ9mAq1eAyNUEEzqsrjpXOwIzB0RnaDh6n1E2yTetZbz6TRDGnOdWrBZRfCI12YTAT0ypdS2FYRfx7L1casAulxBhCmAx78ybriqT0CWrdwYZIdM(u1HtBO3Otd0XG4uLehc2rTr(HH5WovPCaz6bQqsJ8ddeqtZrWnOjAWExfGoQZU2i)WqbAyIss2zLH4(LsZqGeNszLClsKsrN9tru7aYofuqiH0G9Usmqoe88GEJAESGiQ0G9Usmqoe88GEJIKLrppwqefL8S4GPpvD40g6n60aDmiovjXHGDutZrWnO5WovPCaz6bQqsJ8ddeqtZrWnOjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGit0G9UIdb7O2i)WqbAuYZIdM(u1HtBO3Otd0XG4uL0LGcBD21NnQj5gO5WovAWExfGoQZU2i)WqbKFoHeAeOuDJaqjRIdb7OMMJGBqcj0iqP6gbGswvWaq2p90GdIiKqJaLQBeakzvaiF20z4yjploy6tvhoTHEJonqhdItvsCiyh1g5hgMd7uncuQUraOKvDjOWwND9zJAsUbwYtmQTLAI12QzlU2lRD2carKycwl71IYCbxBlhc2XAj4GNxTaGb0BQ9SXA)jVwSKA5wT2pOdKF1c6dCoRnaDh6n12YHGDSw5iHDQQTv2RTLdb7yTYrc7Sw4S2JhOFiG51(H1ky))vl4eRTvZwCTFWZg61E2yT)KxlwsTCRw7h0bYVAb9boN1(H1c9dJa04Q9SXAB5wCTcB2DCyETZS2p8)yu7KLI1cpvjploy6tvhoTHEJonqhdItvsgborxG6SRjHoG5Wo1wF8a9tXHGDuJc70easd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)LkLS4GPR4qWoQPh88uOmOa8q9bjXwenyVRmcCIUa1zxtcDafjlJEESGikk5jg12k712QzlUwBE6)VAPr0RfCIa1cagqVP2ZgR9N8AX1(bDG8Z8A)W)JrTGtSw4v7L1oBbGismbRL9ArzUGRTLdb7yTeCWZRwOx7zJ1khNTQKA5wT2pOdKFQsEwCW0NQoCAd9gDAGogeNQKmcCIUa1zxtcDaZHDQ0G9UIdb7O2i)WqbAyIgS3vbOJ6SRnYpmubsYqF(lvkzXbtxXHGDutp45Pqzqb4H6dsITiAWExze4eDbQZUMe6akswg98ybruuYZIdM(u1HtBO3Otd0XG4uLehc2rn9GNN5WovG8ubdaz)0tdoisfijd9PzjqcjeaPb7DvWaq2p90GdI0sbhogmnCaV2Q5XcImRKl5jg1smJ1(X(v7L1sYeH1obdS2pSwBwkwl6jyJDTKSZ12ZO2ZgRf9dgyTTCRw7h0bYpZRfLIETWETNng4)zTZdog1EqsS2ajzOd9MAtVw54Svv12kV)ZAtF0UwA8omQ9YAPbdV2lRLycgzTSduRCK0SwyV2a0DO3u7zJ1AzvBg1(dXCTdSbDaoG4uvYZIdM(u1HtBO3Otd0XG4uLehc2rnnhb3GMd7ufzoaYpxXHGDuBKFyOcKbABIKDwziUFPuoizItPSsUfjsPOZ(PiQDazNckmrd27koeSJAHnhnOAESGiQ0G9UIdb7OwyZrdQizz0ZJfezIYwhGo2ZObvtOHD665LbjHekLditpqLrGgGJHgLMuLLctToaDSNrdQoK0idEO)4WWuRdqh7z0GkoeSJABoitVDjpXOwcYrWnyTt7eCauRNxT0yTGteOw(Q9SXArhO2SxBl3Q1c71khjnf8btVw4S2azG21YZAbI0Wa6n1kS5ObN1(bhJAjzIWAHxThtew7i9gmQ9YAPbdV2ZosWg7AdKKHo0BQLKDUKNfhm9PQdN2qVrNgOJbXPkjoeSJAAocUbnh2Psd27koeSJAJ8ddfOHjAWExXHGDuBKFyOcKKH(8xQncatImha5NRqPPGpy6QajzOpl5jg1sqocUbRDANGdGA5Xh3Ewlnw7zJ1o45vRGNxTqV2ZgRvooB1A)Goq(vlpR9N8AX1(bhJAdCEzG1E2yTcBoAWzTtd0VsEwCW0NQoCAd9gDAGogeNQK4qWoQP5i4g0CyNknyVRcqh1zxBKFyOanmrd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddvGKm0N)sTrayQ1bOJ9mAqfhc2rTnhKP3UKNfhm9PQdN2qVrNgOJbXPkjoeSJAs4Cch40CyNkasd27Qlbf26SRpButYnqfOHPJhOFkoeSJAuyNMOKgS3vaiF20z4Oci)CcjKfhukQrhjH4KQSuycaPb7D1LGcBD21NnQj5gOkqsg6tZYIdMUIdb7OMeoNWbovOmOa8q9bjrZf2m0PkR5ihJ2AHndDnStLgS3vIbYHGNh0B0cB2DCOaYp3eL0G9UIdb7O2i)WqbAqiHu26JhOFQukgg5hgiGjkPb7Dva6Oo7AJ8ddfObHekYCaKFUcLMc(GPRcKbAtbfuuYtmQTv2R9d)hyTsr)SBhMxlKKebG8HJ21coXAjacO2pB0RvWggiqTxwRNxTF88WAnIumRThjzTT48NsEwCW0NQoCAd9gDAGogeNQK4qWoQjHZjCGtZHDQIuk6SFkPOF2Tdt0G9Usmqoe88GEJAESGiQ0G9Usmqoe88GEJIKLrppwqujpXOwRJJRwWj0BQLaiGAB5wCTF2OxBl3Q1AZZAPr0RfCIaL8S4GPpvD40g6n60aDmiovjXHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mjYCaKFUIdb7O2i)Wqfijd9PjkPb7Dva6Oo7AJ8ddfObHesd27koeSJAJ8ddfObfMlSzOtv2sEwCW0NQoCAd9gDAGogeNQK4qWoQZG2CyNknyVR4qWoQf2C0GQ5XcI(LQuoGm9avxEKAswgTWMJgCwYZIdM(u1HtBO3Otd0XG4uLehc2rn9GNN5WovAWExfGoQZU2i)WqbAqiHKSZkdXzwzjWsEwCW0NQoCAd9gDAGogeNQKqPPGpy6Md7uPb7Dva6Oo7AJ8ddfq(5MOb7Dfhc2rTr(HHci)CZH(HraACAyNkj7SYqCMLAlKanh6hgbOXPHKKiaKpKQSL8S4GPpvD40g6n60aDmiovjXHGDutZrWnyjFjpXGyuBlLpbnmY4qGAfSlWHMfhmD58Uw5iPPGpy61(bhJAPXAD(adEmAxlDKeHETWETI0bGhm9zTCG1sINQKNyqmQLfhm9PYMdY0BtvWUahAwCW0nh2PYIdMUcLMc(GPRe2S74a6nMizNvgIZSuBjeyjpXO2wzV2r(vB61sYoxl7a1kYCaKF(SwoWAfjj0BQf0W8ABYAzBKbQLDGArPzjploy6tLnhKP3M4uLeknf8bt3CyNkj7SYqC)svIKSjPCaz6bQsWBcbqD21Imha5Npnr5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xzLmfL8eJAjMXA)y)Q9YANhliQwBoitVDTDWXOTQ2FSXAbNyTzVwzLt1opwq0SwBmWAHZAVSwwisq)QTNrTNnw7bfev7a7xTPx7zJ1kSz3XrTSdu7zJ1scNt4aRf612hWg7tvYZIdM(uzZbz6TjovjXHGDutcNt4aNMd7uPukhqMEGQ5XcI02CqMEBcj8GK4VYkzkmrd27koeSJABoitVTAESGOFLvozUWMHovzl5jg1smBJETGtO3uRCePr7a5rTY5caNDbAETcEE1Y12XVArzUGRLeoNWboR9ZgoWA)y4b9MA7zu7zJ1sd271YxTNnw7844Qn71E2yTDyJ9vYZIdM(uzZbz6TjovjXHGDutcNt4aNMd7uXwai0WabuiPr7a5HodaNDbA6GK4VsKKnDztZavImha5NpnjYCaKFUcjnAhip0za4SlqvGKm0NMvw5ul0uRzXbtxHKgTdKh6maC2fOcaoz6bcuYZIdM(uzZbz6TjovjfmaK9tpn4GiZHDQs5aY0duHKg5hgiGMMJGBqtImha5NRUeuyRZU(Srnj3avbsYqF(lvuguaEO(GKOjrMdG8ZvCiyh1g5hgQajzOp)LkLOmOa8q9bjXwKzOWeLTgBbGqddeqntWXaVd6n6aKUnHekshaeEkoeSJAJibGnTvb7ezwQeiHeEb0jcp1mbhd8oO3Odq62krMdG8ZvbsYqF(lvkrzqb4H6dsITiZqbfL8S4GPpv2CqMEBItvsxckS1zxF2OMKBGMd7uLYbKPhOQLgCEAWjcONgCqKjrMdG8ZvCiyh1g5hgQajzOp)LkkdkapuFqs0eLTgBbGqddeqntWXaVd6n6aKUnHekshaeEkoeSJAJibGnTvb7ezwQeiHeEb0jcp1mbhd8oO3Odq62krMdG8ZvbsYqF(lvuguaEO(GKifL8S4GPpv2CqMEBItvsCiyh1g5hgMd7uncuQUraOKvDjOWwND9zJAsUbwYZIdM(uzZbz6TjovjfGoQZU2i)WWCyNQuoGm9aviPr(HbcOP5i4g0KiZbq(5QGbGSF6PbhePcKKH(8xQOmOa8q9bjrts5aY0duDqsud6hCOzdZs1ms2eLTwKoai8uCiyh1grcaBAtiHTwkhqMEGkE8XTN6zBxOfzoaYpFsiHImha5NRUeuyRZU(Srnj3avbsYqF(lvkrzqb4H6dsITiZqbfL8S4GPpv2CqMEBItvsbdaz)0tdoiYCyNQuoGm9aviPr(HbcOP5i4g0KrGs1ncaLSQa0rD21g5hgL8S4GPpv2CqMEBItvsxckS1zxF2OMKBGMd7uLYbKPhOQLgCEAWjcONgCqKPwlLditpqLDoaGEJ(YJSKNfhm9PYMdY0BtCQskaDuNDTr(HH5WovAWExXHGDuBKFyOaYp3eLs5aY0duDqsud6hCOzdZkrsMqcfzoaYpxfmaK9tpn4GivGKm0NMvwZqHjkBTiDaq4P4qWoQnIea20MqcBTuoGm9av84JBp1Z2UqlYCaKF(KIsEwCW0NkBoitVnXPkPGbGSF6PbhezoStvkhqMEGkK0i)Wab00CeCdAIsAWExXHGDulS5ObvZJfezwQMHqcfzoaYpxXHGDuNbTkqgOnfMOS1hpq)ubOJ6SRnYpmiKqrMdG8ZvbOJ6SRnYpmubsYqFAwcKcts5aY0duHZdsYhcOzdTiZbq(5MLQejztu2Ar6aGWtXHGDuBejaSPnHe2APCaz6bQ4Xh3EQNTDHwK5ai)8jfL8eJAjMTrV2a0DO3uRrKaWM2Mxl4eR9YJSw621cVjo61c9AZaaJAVSwEaB8AHxTFWZUw2OKNfhm9PYMdY0BtCQs6sqHTo76Zg1KCd0CyNQuoGm9avhKe1G(bhA24xcuYMKYbKPhO6GKOg0p4qZgMvIKSjkBn2caHggiGAMGJbEh0B0biDBcjuKoai8uCiyh1grcaBARc2jYSujqkk5zXbtFQS5Gm92eNQK4qWoQZG2CyNQuoGm9avT0GZtdora90GdImrd27koeSJAHnhnOAESGOFPb7Dfhc2rTWMJgurYYONhliQKNfhm9PYMdY0BtCQsIdb7OMMJGBqZHDQainyVRcgaY(PNgCqKwk4WXGPHd41wnpwqevaKgS3vbdaz)0tdoislfC4yW0Wb8ARizz0ZJfevYZIdM(uzZbz6TjovjXHGDutp45zoStvkhqMEGQwAW5PbNiGEAWbresiLainyVRcgaY(PNgCqKwk4WXGPHd41wbAycaPb7DvWaq2p90GdI0sbhogmnCaV2Q5XcI(faPb7DvWaq2p90GdI0sbhogmnCaV2kswg98ybruuYtmQTLAI1MbDTPxRaOwqFGZzTSrTWzTIKe6n1cAu7mtVKNfhm9PYMdY0BtCQsIdb7OodAZHDQ0G9UIdb7OwyZrdQMhli6xjYKuoGm9avhKe1G(bhA2WSYkztukYCaKFU6sqHTo76Zg1KCdufijd9PzjqcjS1I0baHNIdb7O2isaytBkk5zXbtFQS5Gm92eNQK4qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMOb7Dfhc2rTr(HHc0WCHndDQYwYtmQTv2R9dRTbVAnYpmQf6DWjm9AbadO3u7aCE1(H)hJATzPyTONGn21AZZdR9YABWR2S3RLRDEr6n1sZrWnyTaGb0BQ9SXAJ0qsSrTFqhi)k5zXbtFQS5Gm92eNQK4qWoQP5i4g0CyNknyVRcqh1zxBKFyOanmrd27Qa0rD21g5hgQajzOp)Lkloy6koeSJAs4Cch4uHYGcWd1hKenrd27koeSJAJ8ddfOHjAWExXHGDulS5ObvZJferLgS3vCiyh1cBoAqfjlJEESGit0G9UIdb7O2MdY0BRMhliYenyVRmYpm0qVdoHPRanmrd27k6rMadW5Pank5jg12k71(H12GxTg5hg1c9o4eMETaGb0BQDaoVA)W)JrT2SuSw0tWg7AT55H1EzTn4vB271Y1oVi9MAP5i4gSwaWa6n1E2yTrAij2O2pOdKFMx7mR9d)pg1M(ODTGtSw0tWg7APh88M1cD4b5XODTxwBdE1EzT9emQvyZrdol5zXbtFQS5Gm92eNQK4qWoQPh88mh2Psd27kJaNOlqD21KqhqbAyIsAWExXHGDulS5ObvZJfe9lnyVR4qWoQf2C0Gkswg98ybresyRPKgS3vg5hgAO3bNW0vGgMOb7Df9itGb48uGguqrjpXO2FSXAPX5vl4eRn71AKK1cN1EzTGtSw4v7L12caHcIgTRLgeoaQvyZrdoRfamGEtTSrTC)WO2ZgBxBdE1casAGa1s3U2ZgR1MdY0Bxlnhb3GL8S4GPpv2CqMEBItvsgborxG6SRjHoG5WovAWExXHGDulS5ObvZJfe9lnyVR4qWoQf2C0Gkswg98ybrMOb7Dfhc2rTr(HHc0OKNyulXmw7h7xTxw78ybr1AZbz6TRTdogTv1(Jnwl4eRn71kRCQ25XcIM1AJbwlCw7L1Ycrc6xT9mQ9SXApOGOAhy)Qn9ApBSwHn7ooQLDGApBSws4CchyTqV2(a2yFQsEwCW0NkBoitVnXPkjoeSJAs4Cch40CyNknyVR4qWoQT5Gm92Q5XcI(vw5K5cBg6uL1COFyeGghvznh6hgbOXPBgjnpOkBjploy6tLnhKP3M4uLehc2rnnhb3GMd7uPb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcImjLditpqfsAKFyGaAAocUbl5zXbtFQS5Gm92eNQKqPPGpy6Md7ujzNvgI7xzjWsEIrTY58r7AbNyT0dEE1EzT0GWbqTcBoAWzTWETFyT8iqgODT2SuS2zsI12JKS2mOl5zXbtFQS5Gm92eNQK4qWoQPh88mh2Psd27koeSJAHnhnOAESGit0G9UIdb7OwyZrdQMhli6xAWExXHGDulS5ObvKSm65XcIk5jg1kNp4yu7h8SRLjRf0h4CwlBulCwRijHEtTGg1YoqTF4)aRDKF1METKSZL8S4GPpv2CqMEBItvsCiyh1KW5eoWP5Wo1wtPuoGm9avhKe1G(bhA24xQYkztKSZkdX9RejzkmxyZqNQSMd9dJa04OkR5q)WianoDZiP5bvzl5jg12Qr2HdCw7h8SRDKF1sYZdJ2MxRnSXUwBEEO51MrT05zxlj3UwpVATzPyTONGn21sYox7L1obnmY4Q1o)QLKDUwOFOpHsXAdgaY(v70GdIQvWET0O51oZA)W)JrTGtS2omWAPh88QLDGA7rop6CC1(zJETJ8R20RLKDUKNfhm9PYMdY0BtCQsQddutp45vYZIdM(uzZbz6Tjovj1JCE054k5l5zXbtFQsd0XGAhgOMEWZZCyNAa6ypJgubaNcOXa6C0wlsss2bmrd27ka4uangqNJ2ArssYoGUh58uGgL8S4GPpvPb6yqCQsQh580EkLnh2PgGo2ZObvnbCoARHcOyGMizNvgIZSTecSKNfhm9PknqhdItvsaiF20z4yjploy6tvAGogeNQKcgaY(PNgCqK5Wovs2zLH4mRCqYL8S4GPpvPb6yqCQsIegrgtD21xgKOFL8S4GPpvPb6yqCQsAAd7h0B0g5hgMd7uPb7Dfhc2rTr(HHci)CtImha5NR4qWoQnYpmubsYqFwYZIdM(uLgOJbXPkjoeSJ6mOnh2PkYCaKFUIdb7O2i)Wqfid02enyVR4qWoQf2C0GQ5XcI(LgS3vCiyh1cBoAqfjlJEESGOsEwCW0NQ0aDmiovjXHGDutp45zoStvKsrN9tjf9ZUDysK5ai)CfjmImM6SRVmir)ubsYqFA2wOCOKNfhm9PknqhdItvsxckS1zxF2OMKBGL8S4GPpvPb6yqCQsIdb7O2i)WOKNfhm9PknqhdItvsbOJ6SRnYpmmh2Psd27koeSJAJ8ddfq(5L8eJABPMyTTA2IR9YANTaqejMG1YETOmxW12YHGDSwco45vlaya9MApBS2FYRflPwUvR9d6a5xTG(aNZAdq3HEtTTCiyhRvosyNQABL9AB5qWowRCKWoRfoR94b6hcyETFyTc2)F1coXAB1Sfx7h8SHETNnw7p51ILul3Q1(bDG8RwqFGZzTFyTq)WianUApBS2wUfxRWMDhhMx7mR9d)pg1ozPyTWtvYZIdM(uLgOJbXPkjJaNOlqD21KqhWCyNARpEG(P4qWoQrHDAcaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)sLswCW0vCiyh10dEEkuguaEO(GKylIgS3vgborxG6SRjHoGIKLrppwqefL8eJABL9AB1SfxRnp9)xT0i61corGAbadO3u7zJ1(tET4A)Goq(zETF4)XOwWjwl8Q9YANTaqejMG1YETOmxW12YHGDSwco45vl0R9SXALJZwvsTCRw7h0bYpvjploy6tvAGogeNQKmcCIUa1zxtcDaZHDQ0G9UIdb7O2i)WqbAyIgS3vbOJ6SRnYpmubsYqF(lvkzXbtxXHGDutp45Pqzqb4H6dsITiAWExze4eDbQZUMe6akswg98ybruuYZIdM(uLgOJbXPkjoeSJA6bppZHDQa5PcgaY(PNgCqKkqsg6tZsGesiasd27QGbGSF6PbhePLcoCmyA4aETvZJfezwjxYtmQTLhFC7zTeKJGBWA5R2ZgRfDGAZETTCRw7Nn61gGUd9MApBS2woeSJ1smnhKP3U2b2GoahTl5zXbtFQsd0XG4uLehc2rnnhb3GMd7uPb7Dfhc2rTr(HHc0WenyVR4qWoQnYpmubsYqF(BJaWua6ypJguXHGDuBZbz6Tl5jg12YJpU9SwcYrWnyT8v7zJ1IoqTzV2ZgRvooB1A)Goq(v7Nn61gGUd9MApBS2woeSJ1smnhKP3U2b2GoahTl5zXbtFQsd0XG4uLehc2rnnhb3GMd7uPb7Dva6Oo7AJ8ddfOHjAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOcKKH(8xQncatbOJ9mAqfhc2rTnhKP3UKNfhm9PknqhdItvsCiyh1KW5eoWP5WovaKgS3vxckS1zxF2OMKBGkqdthpq)uCiyh1OWonrjnyVRaq(SPZWrfq(5esiloOuuJoscXjvzPWeasd27Qlbf26SRpButYnqvGKm0NMLfhmDfhc2rnjCoHdCQqzqb4H6dsIMlSzOtvwZrogT1cBg6AyNknyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GqcPS1hpq)uPummYpmqatusd27Qa0rD21g5hgkqdcjuK5ai)Cfknf8btxfid0MckOOKNfhm9PknqhdItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrnpwqevAWExjgihcEEqVrrYYONhliYKiLIo7Nsk6ND7OKNfhm9PknqhdItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilotImha5NR4qWoQnYpmubsYqFAIsAWExfGoQZU2i)WqbAqiH0G9UIdb7O2i)WqbAqH5cBg6uLTKNfhm9PknqhdItvsCiyh1zqBoStLgS3vCiyh1cBoAq18ybr)svkhqMEGQlpsnjlJwyZrdol5zXbtFQsd0XG4uLehc2rn9GNN5WovAWExfGoQZU2i)WqbAqiHKSZkdXzwzjWsEwCW0NQ0aDmiovjHstbFW0nh2Psd27Qa0rD21g5hgkG8Znrd27koeSJAJ8ddfq(5Md9dJa040Wovs2zLH4ml1wibAo0pmcqJtdjjraiFivzl5zXbtFQsd0XG4uLehc2rnnhb3GL8L8edIrTS4GPpvrE8btNQGDbo0S4GPBoStLfhmDfknf8btxjSz3Xb0BmrYoRmeNzP2siqtu26a0XEgnOAcnStxpVmijKqAWExnHg2PRNxgKQ5XcIOsd27Qj0WoD98YGurYYONhliIIsEIrTTutSwuAwlSx7h(pWAh5xTPxlj7CTSduRiZbq(5ZA5aRLPtWR2lRLgRf0OKNfhm9PkYJpy6eNQKqPPGpy6Md7ujzNvgI7xQs5aY0duHstTH4mrPiZbq(5Qlbf26SRpButYnqvGKm0N)sLfhmDfknf8btxHYGcWd1hKejKqrMdG8ZvCiyh1g5hgQajzOp)Lkloy6kuAk4dMUcLbfGhQpijsiHuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)Lkloy6kuAk4dMUcLbfGhQpijsbfMOb7Dva6Oo7AJ8ddfq(5MOb7Dfhc2rTr(HHci)CtainyVRUeuyRZU(Srnj3ava5NBQ1gbkv3iauYQUeuyRZU(Srnj3al5zXbtFQI84dMoXPkjuAk4dMU5Wo1a0XEgnOAcnStxpVminjYCaKFUIdb7O2i)Wqfijd95VuzXbtxHstbFW0vOmOa8q9bjXsEIrTeKJGBWAH9AH3)zThKeR9YAbNyTxEK1YoqTFyT2SuS2lZAjzVDTcBoAWzjploy6tvKhFW0jovjXHGDutZrWnO5WovrMdG8ZvxckS1zxF2OMKBGQazG2MOKgS3vCiyh1cBoAq18ybrMvkhqMEGQlpsnjlJwyZrdonjYCaKFUIdb7O2i)Wqfijd95Vurzqb4H6dsIMizNvgIZSs5aY0duXgAsOdjbj1KSZAdXzIgS3vbOJ6SRnYpmua5Ntrjploy6tvKhFW0jovjXHGDutZrWnO5WovrMdG8ZvxckS1zxF2OMKBGQazG2MOKgS3vCiyh1cBoAq18ybrMvkhqMEGQlpsnjlJwyZrdonD8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LkkdkapuFqs0KuoGm9avhKe1G(bhA2WSs5aY0duD5rQjzz0a4GBR7zOzdkk5zXbtFQI84dMoXPkjoeSJAAocUbnh2PkYCaKFU6sqHTo76Zg1KCdufid02eL0G9UIdb7OwyZrdQMhliYSs5aY0duD5rQjzz0cBoAWPjkB9Xd0pva6Oo7AJ8ddcjuK5ai)Cva6Oo7AJ8ddvGKm0NMvkhqMEGQlpsnjlJgahCBDpdDKguyskhqMEGQdsIAq)GdnBywPCaz6bQU8i1KSmAaCWT19m0SbfL8S4GPpvrE8btN4uLehc2rnnhb3GMd7ubqAWExfmaK9tpn4GiTuWHJbtdhWRTAESGiQainyVRcgaY(PNgCqKwk4WXGPHd41wrYYONhliYeL0G9UIdb7O2i)WqbKFoHesd27koeSJAJ8ddvGKm0N)sTraqHjkPb7Dva6Oo7AJ8ddfq(5esinyVRcqh1zxBKFyOcKKH(8xQncakk5zXbtFQI84dMoXPkjoeSJA6bppZHDQs5aY0du1sdopn4eb0tdoiIqcPeaPb7DvWaq2p90GdI0sbhogmnCaV2kqdtainyVRcgaY(PNgCqKwk4WXGPHd41wnpwq0VainyVRcgaY(PNgCqKwk4WXGPHd41wrYYONhliIIsEwCW0NQip(GPtCQsIdb7OMEWZZCyNknyVRmcCIUa1zxtcDafOHjaKgS3vxckS1zxF2OMKBGkqdtainyVRUeuyRZU(Srnj3avbsYqF(lvwCW0vCiyh10dEEkuguaEO(GKyjploy6tvKhFW0jovjXHGDutcNt4aNMd7ubqAWExDjOWwND9zJAsUbQanmD8a9tXHGDuJc70eL0G9Uca5ZModhva5NtiHS4Gsrn6ijeNuLLctucG0G9U6sqHTo76Zg1KCdufijd9PzzXbtxXHGDutcNt4aNkuguaEO(GKiHekYCaKFUYiWj6cuNDnj0bubsYqFsiHIuk6SFkIAhq2PWCHndDQYAoYXOTwyZqxd7uPb7DLyGCi45b9gTWMDhhkG8ZnrjnyVR4qWoQnYpmuGgesiLT(4b6NkLIHr(HbcyIsAWExfGoQZU2i)WqbAqiHImha5NRqPPGpy6QazG2uqbfL8eJAjG0NGKyTNnwlkJb7aiqTg5H(b5rT0G9ET8KnQ9YA98QDKtSwJ8q)G8OwJifZsEwCW0NQip(GPtCQsIdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXzIgS3vOmgSdGaAJ8q)G8qbAuYZIdM(uf5XhmDItvsCiyh1KW5eoWP5WovAWExjgihcEEqVrfilotusd27koeSJAJ8ddfObHesd27Qa0rD21g5hgkqdcjeaPb7D1LGcBD21NnQj5gOkqsg6tZYIdMUIdb7OMeoNWbovOmOa8q9bjrkmxyZqNQSL8S4GPpvrE8btN4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZenyVRedKdbppO3OMhliIknyVRedKdbppO3Oizz0ZJfezUWMHovzl5jg12YJpU9S2lAx7L1sZor1saeqT9mQvK5ai)8A)Goq(nRLg8QfaK0O2ZgjRf2R9SX2)dSwMobVAVSwugdyGL8S4GPpvrE8btN4uLehc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZenyVRedKdbppO3OcKKH(8xQusjnyVRedKdbppO3OMhliQfXIdMUIdb7OMeoNWbovOmOa8q9bjrkiEJaqrYYqH5cBg6uLTKNfhm9PkYJpy6eNQKC8SXqFiPbopZHDQugypWPntpqcjS1huqe0BOWenyVR4qWoQf2C0GQ5XcIOsd27koeSJAHnhnOIKLrppwqKjAWExXHGDuBKFyOaYp3easd27Qlbf26SRpButYnqfq(5L8S4GPpvrE8btN4uLehc2rDg0Md7uPb7Dfhc2rTWMJgunpwq0VuLYbKPhO6YJutYYOf2C0GZsEwCW0NQip(GPtCQsAcAGHNszZHDQs5aY0duLG3ecG6SRfzoaYpFAIKDwziUFP2siWsEwCW0NQip(GPtCQsIdb7OMEWZZCyNknyVRcWbQZU(SdeNkqdt0G9UIdb7OwyZrdQMhliYSsujpXOw58asAuRWMJgCwlSx7hwBNhJAPXr(v7zJ1ksFIHuSws25Ap7aN25aOw2bQfLMc(GPxlCw78GJrTPxRiZbq(5L8S4GPpvrE8btN4uLehc2rnnhb3GMd7uBDa6ypJgunHg2PRNxgKMKYbKPhOkbVjea1zxlYCaKF(0enyVR4qWoQf2C0GQ5XcIOsd27koeSJAHnhnOIKLrppwqKPJhOFkoeSJ6mOnjYCaKFUIdb7OodAvGKm0N)sTrayIKDwziUFP2sKSjrMdG8ZvO0uWhmDvGKm0NL8S4GPpvrE8btN4uLehc2rnnhb3GMd7udqh7z0GQj0WoD98YG0KuoGm9avj4nHaOo7ArMdG8ZNMOb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcImD8a9tXHGDuNbTjrMdG8ZvCiyh1zqRcKKH(8xQncatKSZkdX9l1wIKnjYCaKFUcLMc(GPRcKKH(8xjsYL8eJALZdiPrTcBoAWzTWETzqxlCwBGmq7sEwCW0NQip(GPtCQsIdb7OMMJGBqZHDQs5aY0duLG3ecG6SRfzoaYpFAIgS3vCiyh1cBoAq18ybruPb7Dfhc2rTWMJgurYYONhliY0Xd0pfhc2rDg0MezoaYpxXHGDuNbTkqsg6ZFP2iamrYoRme3VuBjs2KiZbq(5kuAk4dMUkqsg6ZsEIrTTCiyhRLGCeCdw70obha12Gog8y0UwAS2ZgRDWZRwbpVAZETNnwBl3Q1(bDG8RKNfhm9PkYJpy6eNQK4qWoQP5i4g0CyNknyVR4qWoQnYpmuGgMOb7Dfhc2rTr(HHkqsg6ZFP2iamrd27koeSJAHnhnOAESGiQ0G9UIdb7OwyZrdQizz0ZJfezIsrMdG8ZvO0uWhmDvGKm0Nesya6ypJguXHGDuBZbz6TPOKNyuBlhc2XAjihb3G1oTtWbqTnOJbpgTRLgR9SXAh88QvWZR2Sx7zJ1khNTATFqhi)k5zXbtFQI84dMoXPkjoeSJAAocUbnh2Psd27Qa0rD21g5hgkqdt0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)Wqfijd95VuBeaMOb7Dfhc2rTWMJgunpwqevAWExXHGDulS5ObvKSm65XcImrPiZbq(5kuAk4dMUkqsg6tcjmaDSNrdQ4qWoQT5Gm92uuYtmQTLdb7yTeKJGBWAN2j4aOwAS2ZgRDWZRwbpVAZETNnw7p51IR9d6a5xTWETWRw4SwpVAbNiqTFWZUw54SvRnJAB5wTKNfhm9PkYJpy6eNQK4qWoQP5i4g0CyNknyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBcaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)sTrayIgS3vCiyh1cBoAq18ybruPb7Dfhc2rTWMJgurYYONhliQKNyulXSn61E2yThhn4vlCwl0RfLbfGhwBWEdwl7a1E2yG1cN1sMbw7zZETPJ1Ios228AbNyT0CeCdwlpRDMPxlpRTDcwRnlfRf9eSXUwHnhn4S2lR1gE1YJrTOJKqCwlSx7zJ12YHGDSwcMK0CaqI(v7aBqhGJ21cN1ITaqOHbcuYZIdM(uf5XhmDItvsCiyh10CeCdAoStvkhqMEGkK0i)Wab00CeCdAIgS3vCiyh1cBoAq18ybrMLkLS4Gsrn6ijeNYzYsHjwCqPOgDKeItZkRjAWExbG8ztNHJkG8Zl5zXbtFQI84dMoXPkjoeSJAugJroHPBoStvkhqMEGkK0i)Wab00CeCdAIgS3vCiyh1cBoAq18ybr)sd27koeSJAHnhnOIKLrppwqKjwCqPOgDKeItZkRjAWExbG8ztNHJkG8Zl5zXbtFQI84dMoXPkjoeSJA6bpVsEwCW0NQip(GPtCQscLMc(GPBoStvkhqMEGQe8MqauNDTiZbq(5ZsEwCW0NQip(GPtCQsIdb7OMMJGBW39U3da]] )

    
end