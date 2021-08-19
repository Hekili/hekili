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


    spec:RegisterPack( "Arcane", 20210819, [[davufhqiPK8ieqUerfQKnrr(KQuJcjCkKOvjLO6vebZIIQBjLqzxK8lIcdJOOJruAzev5ziuzAsjW1qGSnIkY3Kskghrf15KsqRdHQEhrfQuZtvI7HK2hrvDqPezHiuEicWejQqvxebu2irfQWhjQqXijQqPtkLuALuuEjrfQOzIa1nLsu2jrOFIaQmuPKQLsubEkLmvvjDvIkKVsubnwIkTxv1Fj1Gv6WOwms9yctgOldTzP6ZsXOPuNg0QLsO61iOzRWTr0UP63IgofoUucz5cpxrtxLRdy7ePVRkgpr05LsTEeqvZhHSFj)L9)63cKp8lr5jt5jRmLZY2cvYuolRmLxR5BDTnWVLbliKBWVLZK43QLcb743YGBpsg8)63AMaHa)w23zmjEziJg4zdqRejPmMqsGbFW0fb3pzmHKcz8TObGJR16F6VfiF4xIYtMYtwzkNLTfQKPCwwzkpc6BnnqXxIYj59TSHGGO)P)wG4u8TAzCdwBlfc2XYSwcObyE1kBl08ALNmLNSLzLzeGn7n4K4lZAXQvoAI1ETnGcEuRfKKaQ1MDWb0BQn71kSz3XrTq)Wiamoy61c95HmyTzV23c2f4qZIdM(BvzwlwTeGn7nyTCiyh1qVdD41U2lRLdb7O2MdY0BxlfWRwhLIrTpOF1oGsXA5zTCiyh12CqMEBkvLzTy1khF6VVAjWKMc(WAHETTebocSABXbMxT0OGbMyTTtG3bwBcC1M9Ad2BWAzhSwpVAbMqVP2wkeSJ1sGjPXiNW0vFRbCEZ)RFR0aDm(V(LOS)x)wOZ0de8tSVLiGhgq(Bfao2ZObvGWPaAmGohT1IKKKDqf6m9abR1uT0a9UceofqJb05OTwKKKSdQ7ropfGX3Ifhm9VvhgOMEWZ7FFjkV)RFl0z6bc(j23seWddi)Tcah7z0GQMaohT1qbumqf6m9abR1uTKSZkdXvR8RTfsqFlwCW0)w9iNN2tP8)(sK4(V(TyXbt)BbI8ztNHJFl0z6bc(j2)(sSf8F9BHotpqWpX(wIaEya5Vfj7SYqC1k)ABbY8BXIdM(3kyqi7NEAWbH)7lrc6)63Ifhm9VfjmImM6SRVmir)(wOZ0de8tS)9LOC6)63cDMEGGFI9Teb8WaYFlAGExXHGDuBKpyOaZhVwt1kYCaMpUIdb7O2iFWqfijd953Ifhm9V10g2pO3OnYhm(3xITM)RFl0z6bc(j23seWddi)TezoaZhxXHGDuBKpyOcKbBxRPAPb6Dfhc2rTWMJgunpwqyTVulnqVR4qWoQf2C0Gksws98ybHFlwCW0)wCiyh1zq)VVeLZ)x)wOZ0de8tSVLiGhgq(BjsPOZ(PKI(z3oQ1uTImhG5JRiHrKXuND9Lbj6Nkqsg6ZALFTY5wW3Ifhm9Vfhc2rn9GN3)(sSf(F9BXIdM(36saHTo76Zg1KCd8BHotpqWpX(3xIYkZ)RFlwCW0)wCiyh1g5dgFl0z6bc(j2)(suwz)V(TqNPhi4NyFlrapmG83IgO3vCiyh1g5dgkW8X)wS4GP)Tcah1zxBKpy8VVeLvE)x)wOZ0de8tSVfloy6FlJaNOlqD21Kqh8BbItranoy6Fl5OjwBRNTSAVS2zlcarc8yTSxlk5fCTTuiyhRLydEE1cceqVP2ZgR918AzYOLA9AFGoy(ulGpW5S2aWDO3uBlfc2XAjWe2PQ2wBV2wkeSJ1sGjSZAHZApEG(HGMx7dwRG93xTatS2wpBz1(apBOx7zJ1(AETmz0sTETpqhmFQfWh4Cw7dwl0pmcaJR2ZgRTLAz1kSz3XH51oZAFW3JrTtwkwl8uFlrapmG83Qv1E8a9tXHGDuJc7uHotpqWAnvlisd07Qlbe26SRpButYnqfGrTMQfePb6D1LacBD21NnQj5gOkqsg6ZAFHATuulloy6koeSJA6bppfkjkaouFqsS2wET0a9UYiWj6cuNDnj0bvKSK65XccRLY)9LOSe3)1Vf6m9ab)e7BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(3Q12RT1ZwwT280FF1sJOxlWebRfeiGEtTNnw7R51YQ9b6G5J51(GVhJAbMyTWR2lRD2IaqKapwl71IsEbxBlfc2XAj2GNxTqV2ZgRvoiBDz0sTETpqhmFuFlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(S2xOwlf1YIdMUIdb7OMEWZtHsIcGd1hKeRTLxlnqVRmcCIUa1zxtcDqfjlPEESGWAP8FFjkBl4)63cDMEGGFI9Teb8WaYFlW8ubdcz)0tdoiufijd9zTYVwcQwIiQwqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliSw5xRm)wS4GP)T4qWoQPh88(3xIYsq)x)wOZ0de8tSVfloy6FloeSJAAocUb)wG4ueqJdM(3QLgpC7zTeJJGBWA5R2ZgRfDWAZETTuRx7Jn61gaUd9MApBS2wkeSJ1khlhKP3U2b2GoihT)wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExXHGDuBKpyOcKKH(S2xQTrawRPAdah7z0GkoeSJABoitVTcDMEGG)7lrzLt)x)wOZ0de8tSVfloy6FloeSJAAocUb)wG4ueqJdM(3QLgpC7zTeJJGBWA5R2ZgRfDWAZETNnwRCq261(aDW8P2hB0RnaCh6n1E2yTTuiyhRvowoitVDTdSbDqoA)Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOcKKH(S2xOwBJaSwt1gao2ZObvCiyh12CqMEBf6m9ab)3xIY2A(V(TqNPhi4NyFlHnd9VLSFlKJrBTWMHUg2)w0a9Usmqoe88GEJwyZUJdfy(4MOGgO3vCiyh1g5dgkadIiIIwD8a9tLsXWiFWabnrbnqVRcah1zxBKpyOamiIirMdW8XvO0uWhmDvGmyBkPKYVLiGhgq(BbI0a9U6saHTo76Zg1KCdubyuRPApEG(P4qWoQrHDQqNPhiyTMQLIAPb6DfiYNnDgoQaZhVwIiQwwCqPOgDKeIZAPwRS1szTMQfePb6D1LacBD21NnQj5gOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkjkaouFqs8BXIdM(3Idb7OMeoNWbo)3xIYkN)V(TqNPhi4NyFlrapmG83IgO3vIbYHGNh0BuZJfewl1APb6DLyGCi45b9gfjlPEESGWAnvRiLIo7Nsk6ND74BXIdM(3Idb7OMeoNWbo)3xIY2c)V(TqNPhi4NyFlwCW0)wCiyh1KW5eoW53syZq)Bj73seWddi)TOb6DLyGCi45b9gvGS4Q1uTImhG5JR4qWoQnYhmubsYqFwRPAPOwAGExfaoQZU2iFWqbyulrevlnqVR4qWoQnYhmuag1s5)(suEY8)63cDMEGGFI9Teb8WaYFlAGExXHGDulS5ObvZJfew7luRvkhqMEGQlpsnjlPwyZrdo)wS4GP)T4qWoQZG(FFjkpz)V(TqNPhi4NyFlrapmG83IgO3vbGJ6SRnYhmuag1ser1sYoRmexTYVwzjOVfloy6FloeSJA6bpV)9LO8K3)1Vf6m9ab)e7BXIdM(3cLMc(GP)TG(HrayCAy)BrYoRmeN8PkNjOVf0pmcaJtdjjrqiF43s2VLiGhgq(Brd07QaWrD21g5dgkW8XR1uT0a9UIdb7O2iFWqbMp()(suEe3)1Vfloy6FloeSJAAocUb)wOZ0de8tS)9VVvhoTHEJonqhJ)RFjk7)1Vf6m9ab)e7BXIdM(3cLMc(GP)TaXPiGghm9VLCOn61gaUd9MAr4zJrTNnwRLvTzu7RYH1oWg0b5aItZR9bR9H9R2lRLatAwln2ZaR9SXAFnVwMmAPwV2hOdMpQALJMyTWRwEw7mtVwEwRCq261AZZA7qhoTrWAtGO2h8TuS2Pb6xTjquRWMJgC(Teb8WaYFlkQnaCSNrdQoK0idEOF4WqHotpqWAjIOAPO2aWXEgnOAcnStxpVmivOZ0deSwt12QALYbKPhOYiqdGXqJsZAPwRS1szTuwRPAPOwAGExfaoQZU2iFWqbMpETeruTgbkv3iavYQ4qWoQP5i4gSwkR1uTImhG5JRcah1zxBKpyOcKKH(8FFjkV)RFl0z6bc(j23Ifhm9Vfknf8bt)BbItranoy6FRwBV2h8TuS2o0HtBeS2eiQvK5amF8AFGoy(mRLDWANgOF1MarTcBoAWP51AeWmGhKapwlbM0S2ukg1IsXO9zd9MAXXe)wIaEya5V1Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(Swt1kYCaMpUIdb7O2iFWqfijd9zTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8AnvRrGs1ncqLSkoeSJAAocUb)3xIe3)1Vf6m9ab)e7Bjc4HbK)wbGJ9mAqfiCkGgdOZrBTijjzhuHotpqWAnvlnqVRaHtb0yaDoARfjjj7G6EKZtby8TyXbt)B1HbQPh88(3xITG)RFl0z6bc(j23seWddi)Tcah7z0GQMaohT1qbumqf6m9abR1uTKSZkdXvR8RTfsqFlwCW0)w9iNN2tP8)(sKG(V(TqNPhi4NyFlwCW0)wCiyh1KW5eoW53syZq)Bj73seWddi)Tcah7z0GkoeSJABoitVTcDMEGG1AQwAGExXHGDuBZbz6TvZJfew7l1sd07koeSJABoitVTIKLuppwqyTMQLIAPOwAGExXHGDuBKpyOaZhVwt1kYCaMpUIdb7O2iFWqfid2UwkRLiIQfePb6D1LacBD21NnQj5gOcWOwk)3xIYP)RFl0z6bc(j23seWddi)Tcah7z0GQj0WoD98YGuHotpqWVfloy6FRaWrD21g5dg)7lXwZ)1Vf6m9ab)e7Bjc4HbK)wImhG5JRcah1zxBKpyOcKbB)TyXbt)BXHGDuNb9)(suo)F9BHotpqWpX(wIaEya5VLiZby(4QaWrD21g5dgQazW21AQwAGExXHGDulS5ObvZJfew7l1sd07koeSJAHnhnOIKLuppwq43Ifhm9Vfhc2rn9GN3)(sSf(F9BHotpqWpX(wIaEya5VvRQnaCSNrdQoK0idEOF4WqHotpqWAjIOAfPdcapvdSF6SRpBupGcBf6m9ab)wS4GP)Tar(SPZWX)9LOSY8)63Ifhm9Vva4Oo7AJ8bJVf6m9ab)e7FFjkRS)x)wOZ0de8tSVfloy6FloeSJAs4Cch48BbItranoy6FRwBV2h8DG1YxTKSK1opwq4S2Sxlbqa1YoyTpyT2Su0FF1cmrWABz5R12gpZRfyI1Y1opwqyTxwRrGsr)QLeWf2qVPwaFGZzTbG7qVP2ZgRvowoitVDTdSbDqoA)Teb8WaYFlAGExjgihcEEqVrfilUAnvlnqVRedKdbppO3OMhliSwQ1sd07kXa5qWZd6nksws98ybH1AQwrkfD2pLu0p72rTMQvK5amFCfjmImM6SRVmir)ubYGTR1uTTQwPCaz6bQqsJ8bdeutZrWnyTMQvK5amFCfhc2rTr(GHkqgS9)(suw59F9BHotpqWpX(wIaEya5VvRQnaCSNrdQoK0idEOF4WqHotpqWAnvlf12QAdah7z0GQj0WoD98YGuHotpqWAjIOAPOwPCaz6bQmc0aym0O0SwQ1kBTMQLgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccRLYAP8BbItranoy6FljMbjpgTR9bR1GHrTg5btVwGjw7d8SRTLADZRLg4QfE1(ahJAh88QDKEtTONan212ZOw68SR9SXALdYwVw2bRTLA9AFGoy(mRfWh4CwBa4o0BQ9SXATSQnJAFvoS2b2GoihqC(TyXbt)BzKhm9)9LOSe3)1Vf6m9ab)e7Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AjIOAncuQUraQKvXHGDutZrWn43Ifhm9VfiYNnDgo(VVeLTf8F9BHotpqWpX(wIaEya5VfnqVRcah1zxBKpyOaZhVwIiQwJaLQBeGkzvCiyh10CeCd(TyXbt)BfmiK9tpn4GW)9LOSe0)1Vf6m9ab)e7Bjc4HbK)w0a9UkaCuNDTr(GHkqsg6ZAFPwkQvovReQvE12YRnaCSNrdQMqd701Zldsf6m9abRLYVfloy6Flsyezm1zxFzqI(9VVeLvo9F9BHotpqWpX(wS4GP)T4qWoQnYhm(wG4ueqJdM(3so0g9Ada3HEtTNnwRCSCqME7Ahyd6GC028AbMyTTuRxln2ZaR918Az1EzTGaKg1Y12bgJ21opwqicwlnhC0GFlrapmG83skhqMEGkK0iFWab10CeCdwRPAPb6Dva4Oo7AJ8bdfGrTMQLIAjzNvgIR2xQLIALhbvReQLIALvM12YRvKsrN9try7aYETuwlL1ser1sd07kXa5qWZd6nQ5XccRLAT0a9Usmqoe88GEJIKLuppwqyTu(VVeLT18F9BHotpqWpX(wIaEya5VLuoGm9aviPr(GbcQP5i4gSwt1sd07koeSJAHnhnOAESGWAPwlnqVR4qWoQf2C0Gksws98ybH1AQwAGExXHGDuBKpyOam(wS4GP)T4qWoQP5i4g8FFjkRC()63cDMEGGFI9Teb8WaYFlAGExfaoQZU2iFWqbMpETeruTgbkv3iavYQ4qWoQP5i4gSwIiQwJaLQBeGkzvbdcz)0tdoiSwIiQwkQ1iqP6gbOswfiYNnDgowRPABvTbGJ9mAq1eAyNUEEzqQqNPhiyTu(TyXbt)BDjGWwND9zJAsUb(VVeLTf(F9BHotpqWpX(wIaEya5VLrGs1ncqLSQlbe26SRpButYnWVfloy6FloeSJAJ8bJ)9LO8K5)1Vf6m9ab)e7BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(3soAI126zlR2lRD2IaqKapwl71IsEbxBlfc2XAj2GNxTGab0BQ9SXAFnVwMmAPwV2hOdMp1c4dCoRnaCh6n12sHGDSwcmHDQQT12RTLcb7yTeyc7Sw4S2JhOFiO51(G1ky)9vlWeRT1ZwwTpWZg61E2yTVMxltgTuRx7d0bZNAb8boN1(G1c9dJaW4Q9SXABPwwTcB2DCyETZS2h89yu7KLI1cp13seWddi)TAvThpq)uCiyh1OWovOZ0deSwt1cI0a9U6saHTo76Zg1KCdubyuRPAbrAGExDjGWwND9zJAsUbQcKKH(S2xOwlf1YIdMUIdb7OMEWZtHsIcGd1hKeRTLxlnqVRmcCIUa1zxtcDqfjlPEESGWAP8FFjkpz)V(TqNPhi4NyFlwCW0)wgborxG6SRjHo43ceNIaACW0)wT2ETTE2YQ1MN(7RwAe9AbMiyTGab0BQ9SXAFnVwwTpqhmFmV2h89yulWeRfE1EzTZweaIe4XAzVwuYl4ABPqWowlXg88Qf61E2yTYbzRlJwQ1R9b6G5J6Bjc4HbK)w0a9UIdb7O2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(c1APOwwCW0vCiyh10dEEkusuaCO(GKyTT8APb6DLrGt0fOo7AsOdQizj1ZJfewlL)7lr5jV)RFl0z6bc(j23seWddi)TaZtfmiK9tpn4GqvGKm0N1k)AjOAjIOAbrAGExfmiK9tpn4GqTuGHJbtdhWRTAESGWALFTY8BXIdM(3Idb7OMEWZ7FFjkpI7)63cDMEGGFI9TyXbt)BXHGDutZrWn43ceNIaACW0)wYHyTpSF1EzTKmHyTtGaR9bR1MLI1IEc0yxlj7CT9mQ9SXAr)GbwBl161(aDW8X8ArPOxlSx7zJb(Ew78GJrThKeRnqsg6qVP20RvoiBDvTT279S20hTRLgVdJAVSwAGWR9YAjWJrwl7G1sGjnRf2RnaCh6n1E2yTww1MrTVkhw7aBqhKdiovFlrapmG83sK5amFCfhc2rTr(GHkqgSDTMQLKDwziUAFPwkQTfiZALqTuuRSYS2wETIuk6SFkcBhq2RLYAPSwt1sd07koeSJAHnhnOAESGWAPwlnqVR4qWoQf2C0Gksws98ybH1AQwkQTv1gao2ZObvtOHD665LbPcDMEGG1ser1kLditpqLrGgaJHgLM1sTwzRLYAnvBRQnaCSNrdQoK0idEOF4WqHotpqWAnvBRQnaCSNrdQ4qWoQT5Gm92k0z6bc(VVeLxl4)63cDMEGGFI9TyXbt)BXHGDutZrWn43ceNIaACW0)weJJGBWAN2jWaSwpVAPXAbMiyT8v7zJ1IoyTzV2wQ1Rf2RLatAk4dMETWzTbYGTRLN1cgPHb0BQvyZrdoR9bog1sYeI1cVApMqS2r6nyu7L1sdeETNDKan21gijdDO3ulj783seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07koeSJAJ8bdvGKm0N1(c1ABeG1AQwrMdW8XvO0uWhmDvGKm0N)7lr5rq)x)wOZ0de8tSVfloy6FloeSJAAocUb)wG4ueqJdM(3IyCeCdw70obgG1YJhU9SwAS2ZgRDWZRwbpVAHETNnwRCq261(aDW8PwEw7R51YQ9bog1g48YaR9SXAf2C0GZANgOFFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgQajzOpR9fQ12iaR1uTTQ2aWXEgnOIdb7O2MdY0BRqNPhi4)(suEYP)RFl0z6bc(j23syZq)Bj73c5y0wlSzORH9VfnqVRedKdbppO3Of2S74qbMpUjkOb6Dfhc2rTr(GHcWGiIOOvhpq)uPummYhmqqtuqd07QaWrD21g5dgkadIisK5amFCfknf8btxfid2MskP8Bjc4HbK)wGinqVRUeqyRZU(Srnj3avag1AQ2JhOFkoeSJAuyNk0z6bcwRPAPOwAGExbI8ztNHJkW8XRLiIQLfhukQrhjH4SwQ1kBTuwRPAbrAGExDjGWwND9zJAsUbQcKKH(Sw5xlloy6koeSJAs4Cch4uHsIcGd1hKe)wS4GP)T4qWoQjHZjCGZ)9LO8An)x)wOZ0de8tSVfloy6FloeSJAs4Cch48BbItranoy6FRwBV2h8DG1kf9ZUDyETqsseeYhoAxlWeRLaiGAFSrVwbByGG1EzTEE1(WZdR1isXS2EKK12YYx)wIaEya5VLiLIo7Nsk6ND7Owt1sd07kXa5qWZd6nQ5XccRLAT0a9Usmqoe88GEJIKLuppwq4)(suEY5)RFl0z6bc(j23ceNIaACW0)wwhhxTatO3ulbqa12sTSAFSrV2wQ1R1MN1sJOxlWeb)wIaEya5VfnqVRedKdbppO3OcKfxTMQvK5amFCfhc2rTr(GHkqsg6ZAnvlf1sd07QaWrD21g5dgkaJAjIOAPb6Dfhc2rTr(GHcWOwk)wcBg6Flz)wS4GP)T4qWoQjHZjCGZ)9LO8AH)x)wOZ0de8tSVLiGhgq(Brd07koeSJAHnhnOAESGWAFHATs5aY0duD5rQjzj1cBoAW53Ifhm9Vfhc2rDg0)7lrItM)x)wOZ0de8tSVLiGhgq(Brd07QaWrD21g5dgkaJAjIOAjzNvgIRw5xRSe03Ifhm9Vfhc2rn9GN3)(sK4K9)63cDMEGGFI9TyXbt)BHstbFW0)wq)WiamonS)TizNvgIt(uLZe03c6hgbGXPHKKiiKp8Bj73seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwAGExXHGDuBKpyOaZh)FFjsCY7)63Ifhm9Vfhc2rnnhb3GFl0z6bc(j2)(33kYJpy6)x)su2)RFl0z6bc(j23Ifhm9Vfknf8bt)BbItranoy6Fl5OjwlknRf2R9bFhyTJ8P20RLKDUw2bRvK5amF8zTCG1Y0jWv7L1sJ1cy8Teb8WaYFRwvBa4ypJgunHg2PRNxgKk0z6bcwRPAjzNvgIR2xOwRuoGm9avO0uBiUAnvlf1kYCaMpU6saHTo76Zg1KCdufijd9zTVqTwwCW0vO0uWhmDfkjkaouFqsSwIiQwrMdW8XvCiyh1g5dgQajzOpR9fQ1YIdMUcLMc(GPRqjrbWH6dsI1ser1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFHATS4GPRqPPGpy6kusuaCO(GKyTuwlL1AQwAGExfaoQZU2iFWqbMpETMQLgO3vCiyh1g5dgkW8XR1uTGinqVRUeqyRZU(Srnj3avG5JxRPABvTgbkv3iavYQUeqyRZU(Srnj3a)3xIY7)63cDMEGGFI9Teb8WaYFRaWXEgnOAcnStxpVmivOZ0deSwt12QAfPu0z)usr)SBh1AQwrMdW8XvCiyh1g5dgQajzOpR9fQ1YIdMUcLMc(GPRqjrbWH6dsIFlwCW0)wO0uWhm9)9LiX9F9BHotpqWpX(wIaEya5Vva4ypJgunHg2PRNxgKk0z6bcwRPAfPu0z)usr)SBh1AQwrMdW8XvKWiYyQZU(YGe9tfijd9zTVqTwwCW0vO0uWhmDfkjkaouFqsSwt1kYCaMpU6saHTo76Zg1KCdufijd9zTVqTwkQvkhqMEGkY80gbkqeuF5rQPBxReQLfhmDfknf8btxHsIcGd1hKeRvc1sC1szTMQvK5amFCfhc2rTr(GHkqsg6ZAFHATuuRuoGm9avK5PncuGiO(YJut3Uwjulloy6kuAk4dMUcLefahQpijwReQL4QLYVfloy6FluAk4dM()(sSf8F9BHotpqWpX(wS4GP)T4qWoQP5i4g8BbItranoy6FlIXrWnyTWETW79S2dsI1EzTatS2lpYAzhS2hSwBwkw7LzTKS3UwHnhn48Bjc4HbK)wImhG5JRUeqyRZU(Srnj3avbYGTR1uTuulnqVR4qWoQf2C0GQ5XccRv(1kLditpq1LhPMKLulS5ObN1AQwrMdW8XvCiyh1g5dgQajzOpR9fQ1IsIcGd1hKeR1uTKSZkdXvR8RvkhqMEGk2qtcDijaPMKDwBiUAnvlnqVRcah1zxBKpyOaZhVwk)3xIe0)1Vf6m9ab)e7Bjc4HbK)wImhG5JRUeqyRZU(Srnj3avbYGTR1uTuulnqVR4qWoQf2C0GQ5XccRv(1kLditpq1LhPMKLulS5ObN1AQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTVqTwusuaCO(GKyTMQvkhqMEGQdsIAa)GdnBuR8RvkhqMEGQlpsnjlPgehCBDpdnBulLFlwCW0)wCiyh10CeCd(VVeLt)x)wOZ0de8tSVLiGhgq(BjYCaMpU6saHTo76Zg1KCdufid2Uwt1srT0a9UIdb7OwyZrdQMhliSw5xRuoGm9avxEKAswsTWMJgCwRPAPO2wv7Xd0pva4Oo7AJ8bdf6m9abRLiIQvK5amFCva4Oo7AJ8bdvGKm0N1k)ALYbKPhO6YJutYsQbXb3w3ZqhPrTuwRPALYbKPhO6GKOgWp4qZg1k)ALYbKPhO6YJutYsQbXb3w3ZqZg1s53Ifhm9Vfhc2rnnhb3G)7lXwZ)1Vf6m9ab)e7Bjc4HbK)wGinqVRcgeY(PNgCqOwkWWXGPHd41wnpwqyTuRfePb6DvWGq2p90Gdc1sbgogmnCaV2ksws98ybH1AQwkQLgO3vCiyh1g5dgkW8XRLiIQLgO3vCiyh1g5dgQajzOpR9fQ12iaRLYAnvlf1sd07QaWrD21g5dgkW8XRLiIQLgO3vbGJ6SRnYhmubsYqFw7luRTrawlLFlwCW0)wCiyh10CeCd(VVeLZ)x)wOZ0de8tSVLiGhgq(BjLditpqvloW80ateupn4GWAjIOAPOwqKgO3vbdcz)0tdoiulfy4yW0Wb8ARamQ1uTGinqVRcgeY(PNgCqOwkWWXGPHd41wnpwqyTVulisd07QGbHSF6PbheQLcmCmyA4aETvKSK65XccRLYVfloy6FloeSJA6bpV)9Lyl8)63cDMEGGFI9Teb8WaYFlAGExze4eDbQZUMe6GkaJAnvlisd07Qlbe26SRpButYnqfGrTMQfePb6D1LacBD21NnQj5gOkqsg6ZAFHATS4GPR4qWoQPh88uOKOa4q9bjXVfloy6FloeSJA6bpV)9LOSY8)63cDMEGGFI9Te2m0)wY(TqogT1cBg6Ay)Brd07kXa5qWZd6nAHn7oouG5JBIcAGExXHGDuBKpyOamiIikA1Xd0pvkfdJ8bde0ef0a9UkaCuNDTr(GHcWGiIezoaZhxHstbFW0vbYGTPKsk)wIaEya5Vfisd07Qlbe26SRpButYnqfGrTMQ94b6NIdb7Ogf2PcDMEGG1AQwkQLgO3vGiF20z4OcmF8AjIOAzXbLIA0rsioRLATYwlL1AQwkQfePb6D1LacBD21NnQj5gOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkjkaouFqsSwIiQwrMdW8XvgborxG6SRjHoOkqsg6ZAjIOAfPu0z)ue2oGSxlLFlwCW0)wCiyh1KW5eoW5)(suwz)V(TqNPhi4NyFlwCW0)wCiyh1KW5eoW53ceNIaACW0)weq6tasS2ZgRfL0GDqeSwJ8q)G8OwAGEVwEYg1EzTEE1oYjwRrEOFqEuRrKI53seWddi)TOb6DLyGCi45b9gvGS4Q1uT0a9UcL0GDqeuBKh6hKhkaJ)9LOSY7)63cDMEGGFI9TyXbt)BXHGDutcNt4aNFlHnd9VLSFlrapmG83IgO3vIbYHGNh0BubYIRwt1srT0a9UIdb7O2iFWqbyulrevlnqVRcah1zxBKpyOamQLiIQfePb6D1LacBD21NnQj5gOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkjkaouFqsSwk)3xIYsC)x)wOZ0de8tSVfloy6FloeSJAs4Cch48BjSzO)TK9Bjc4HbK)w0a9Usmqoe88GEJkqwC1AQwAGExjgihcEEqVrnpwqyTuRLgO3vIbYHGNh0BuKSK65Xcc)3xIY2c(V(TqNPhi4NyFlqCkcOXbt)B1sJhU9S2lAx7L1sZoH1saeqT9mQvK5amF8AFGoy(mRLg4QfeG0O2ZgjRf2R9SX2VdSwMobUAVSwusdyGFlrapmG83IgO3vIbYHGNh0BubYIRwt1sd07kXa5qWZd6nQajzOpR9fQ1srTuulnqVRedKdbppO3OMhliS2wETS4GPR4qWoQjHZjCGtfkjkaouFqsSwkRvc12iavKSK1s53syZq)Bj73Ifhm9Vfhc2rnjCoHdC(VVeLLG(V(TqNPhi4NyFlrapmG83IIAdSh40MPhyTeruTTQ2dkie6n1szTMQLgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccR1uT0a9UIdb7O2iFWqbMpETMQfePb6D1LacBD21NnQj5gOcmF8Vfloy6FlhpBm0hsAGZ7FFjkRC6)63cDMEGGFI9Teb8WaYFlAGExXHGDulS5ObvZJfew7luRvkhqMEGQlpsnjlPwyZrdo)wS4GP)T4qWoQZG(FFjkBR5)63cDMEGGFI9Teb8WaYFlPCaz6bQsGBcbrD21ImhG5JpR1uTKSZkdXv7luRTfsqFlwCW0)wtadm8uk)VVeLvo)F9BHotpqWpX(wIaEya5VfnqVRcGbQZU(SdeNkaJAnvlnqVR4qWoQf2C0GQ5XccRv(1sCFlwCW0)wCiyh10dEE)7lrzBH)x)wOZ0de8tSVfloy6FloeSJAAocUb)wG4ueqJdM(3soEasJAf2C0GZAH9AFWA78yulnoYNApBSwr6tmKI1sYox7zh40ohG1YoyTO0uWhm9AHZANhCmQn9AfzoaZh)Bjc4HbK)wTQ2aWXEgnOAcnStxpVmivOZ0deSwt1kLditpqvcCtiiQZUwK5amF8zTMQLgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccR1uThpq)uCiyh1zqRqNPhiyTMQvK5amFCfhc2rDg0QajzOpR9fQ12iaR1uTKSZkdXv7luRTfkZAnvRiZby(4kuAk4dMUkqsg6Z)9LO8K5)1Vf6m9ab)e7Bjc4HbK)wbGJ9mAq1eAyNUEEzqQqNPhiyTMQvkhqMEGQe4MqquNDTiZby(4ZAnvlnqVR4qWoQf2C0GQ5XccRLAT0a9UIdb7OwyZrdQizj1ZJfewRPApEG(P4qWoQZGwHotpqWAnvRiZby(4koeSJ6mOvbsYqFw7luRTrawRPAjzNvgIR2xOwBluM1AQwrMdW8XvO0uWhmDvGKm0N1(sTeNm)wS4GP)T4qWoQP5i4g8FFjkpz)V(TqNPhi4NyFlwCW0)wCiyh10CeCd(TaXPiGghm9VLC8aKg1kS5ObN1c71MbDTWzTbYGT)wIaEya5VLuoGm9avjWnHGOo7ArMdW8XN1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwt1E8a9tXHGDuNbTcDMEGG1AQwrMdW8XvCiyh1zqRcKKH(S2xOwBJaSwt1sYoRmexTVqT2wOmR1uTImhG5JRqPPGpy6QajzOpR1uTuuBRQnaCSNrdQMqd701Zldsf6m9abRLiIQLgO3vtOHD665LbPkqsg6ZAFHATYkNRLY)9LO8K3)1Vf6m9ab)e7BXIdM(3Idb7OMMJGBWVfiofb04GP)TAPqWowlX4i4gS2PDcmaRTbDm4XODT0yTNnw7GNxTcEE1M9ApBS2wQ1R9b6G5Z3seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07koeSJAJ8bdvGKm0N1(c1ABeG1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwt1srTImhG5JRqPPGpy6QajzOpRLiIQnaCSNrdQ4qWoQT5Gm92k0z6bcwlL)7lr5rC)x)wOZ0de8tSVfloy6FloeSJAAocUb)wG4ueqJdM(3QLcb7yTeJJGBWAN2jWaS2g0XGhJ21sJ1E2yTdEE1k45vB2R9SXALdYwV2hOdMpFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgQajzOpR9fQ12iaR1uT0a9UIdb7OwyZrdQMhliSwQ1sd07koeSJAHnhnOIKLuppwqyTMQLIAfzoaZhxHstbFW0vbsYqFwlrevBa4ypJguXHGDuBZbz6TvOZ0deSwk)3xIYRf8F9BHotpqWpX(wS4GP)T4qWoQP5i4g8BbItranoy6FRwkeSJ1smocUbRDANadWAPXApBS2bpVAf88Qn71E2yTVMxlR2hOdMp1c71cVAHZA98QfyIG1(ap7ALdYwV2mQTLA9VLiGhgq(Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LacBD21NnQj5gOcWOwt1cI0a9U6saHTo76Zg1KCdufijd9zTVqT2gbyTMQLgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65Xcc)3xIYJG(V(TqNPhi4NyFlwCW0)wCiyh10CeCd(TaXPiGghm9VLCOn61E2yThhn4vlCwl0RfLefahwBWEdwl7G1E2yG1cN1sMbw7zZETPJ1Ios228AbMyT0CeCdwlpRDMPxlpRTDcuRnlfRf9eOXUwHnhn4S2lR1gE1YJrTOJKqCwlSx7zJ12sHGDSwILK0CasI(v7aBqhKJ21cN1ITiaOHbc(Teb8WaYFlPCaz6bQqsJ8bdeutZrWnyTMQLgO3vCiyh1cBoAq18ybH1kFQ1srTS4Gsrn6ijeN12IvRS1szTMQLfhukQrhjH4Sw5xRS1AQwAGExbI8ztNHJkW8X)3xIYto9F9BHotpqWpX(wIaEya5VLuoGm9aviPr(GbcQP5i4gSwt1sd07koeSJAHnhnOAESGWAFPwAGExXHGDulS5ObvKSK65XccR1uTS4Gsrn6ijeN1k)ALTwt1sd07kqKpB6mCubMp(3Ifhm9Vfhc2rnkPXiNW0)3xIYR18F9BXIdM(3Idb7OMEWZ7BHotpqWpX(3xIYto)F9BHotpqWpX(wIaEya5VLuoGm9avjWnHGOo7ArMdW8XNFlwCW0)wO0uWhm9)9LO8AH)x)wS4GP)T4qWoQP5i4g8BHotpqWpX(3)(wImhG5Jp)V(LOS)x)wOZ0de8tSVfloy6FREKZt7Pu(BbItranoy6FRwpGzapibESwGj0BQTjGZr7AHcOyG1(ap7AzdvTYrtSw4v7d8SR9YJS28SX4bor13seWddi)Tcah7z0GQMaohT1qbumqf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RL4KzTMQvK5amFC1LacBD21NnQj5gOkqgSDTMQLIAPb6Dfhc2rTWMJgunpwqyTVqTwPCaz6bQU8i1KSKAHnhn4Swt1srTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xOwBJaSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwPCaz6bQU8i1KSKAqCWT19m0SrTuwlrevlf12QApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs5aY0duD5rQjzj1G4GBR7zOzJAPSwIiQwrMdW8XvCiyh1g5dgQajzOpR9fQ12iaRLYAP8FFjkV)RFl0z6bc(j23seWddi)Tcah7z0GQMaohT1qbumqf6m9abR1uTImhG5JR4qWoQnYhmubYGTR1uTuuBRQ94b6Nc9bSX(qhbvOZ0deSwIiQwkQ94b6Nc9bSX(qhbvOZ0deSwt1sYoRmexTYNATTgzwlL1szTMQLIAPOwrMdW8XvxciS1zxF2OMKBGQajzOpRv(1kRmR1uT0a9UIdb7OwyZrdQMhliSwQ1sd07koeSJAHnhnOIKLuppwqyTuwlrevlf1kYCaMpU6saHTo76Zg1KCdufijd9zTuRvM1AQwAGExXHGDulS5ObvZJfewl1ALzTuwlL1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALp1ALYbKPhOIn0KqhscqQjzN1gI7BXIdM(3Qh580EkL)3xIe3)1Vf6m9ab)e7Bjc4HbK)wbGJ9mAqfiCkGgdOZrBTijjzhuHotpqWAnvRiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTR1uT0a9UceofqJb05OTwKKKSdQ7ropfy(41AQwkQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlbe26SRpButYnqfy(41szTMQvK5amFC1LacBD21NnQj5gOkqsg6ZAPwRmR1uTuulnqVR4qWoQf2C0GQ5XccR9fQ1kLditpq1LhPMKLulS5ObN1AQwkQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(c1ABeG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kLditpq1LhPMKLudIdUTUNHMnQLYAjIOAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RvkhqMEGQlpsnjlPgehCBDpdnBulL1ser1kYCaMpUIdb7O2iFWqfijd9zTVqT2gbyTuwlLFlwCW0)w9iNhDoU)9Lyl4)63cDMEGGFI9Teb8WaYFRaWXEgnOceofqJb05OTwKKKSdQqNPhiyTMQvK5amFCfnqVRbHtb0yaDoARfjjj7GQazW21AQwAGExbcNcOXa6C0wlsss2b1DyGkW8XR1uTgbkv3iavYQ6rop6CCFlwCW0)wDyGA6bpV)9Lib9F9BHotpqWpX(wS4GP)TiHrKXuND9Lbj633ceNIaACW0)wTodJABz5R1(ap7ABPwVwyVw49EwRijHEtTag1oZ0v12A71cVAFGJrT0yTateS2h4zx7R51YmVwbpVAHxTZbSX(gTRLg7zGFlrapmG83IIABvTbGJ9mAq1eAyNUEEzqQqNPhiyTeruT0a9UAcnStxpVmivag1szTMQvK5amFC1LacBD21NnQj5gOkqsg6ZAFPwPCaz6bQiZtBeOarq9LhPMUDTeruTuuRuoGm9avhKe1a(bhA2Ow5xRuoGm9avK5Pjzj1G4GBR7zOzJAnvRiZby(4Qlbe26SRpButYnqvGKm0N1k)ALYbKPhOImpnjlPgehCBDpd9LhzTu(VVeLt)x)wOZ0de8tSVLiGhgq(BjYCaMpUIdb7O2iFWqfid2Uwt1srTTQ2JhOFk0hWg7dDeuHotpqWAjIOAPO2JhOFk0hWg7dDeuHotpqWAnvlj7SYqC1kFQ12AKzTuwlL1AQwkQLIAfzoaZhxDjGWwND9zJAsUbQcKKH(Sw5xRuoGm9avSHMKLudIdUTUNH(YJSwt1sd07koeSJAHnhnOAESGWAPwlnqVR4qWoQf2C0Gksws98ybH1szTeruTuuRiZby(4Qlbe26SRpButYnqvGKm0N1sTwzwRPAPb6Dfhc2rTWMJgunpwqyTuRvM1szTuwRPAPb6Dva4Oo7AJ8bdfy(41AQws2zLH4Qv(uRvkhqMEGk2qtcDijaPMKDwBiUVfloy6Flsyezm1zxFzqI(9VVeBn)x)wOZ0de8tSVLiGhgq(BjLditpqvcCtiiQZUwK5amF8zTMQLIANjWGg6GkP5Gp4a1ZCif9tHotpqWAjIOANjWGg6GkdG5bmqngaghmDf6m9abRLYVfloy6FR(aN2IG73)(suo)F9BHotpqWpX(wS4GP)Tar(SPZWXVfiofb04GP)TAPXd3EwlWeRfe5ZModhR9bE21YgQABT9AV8iRfoRnqgSDT8S2hCmmVwsMqS2jqG1EzTcEE1cVAPXEgyTxEKQVLiGhgq(BjYCaMpU6saHTo76Zg1KCdufid2Uwt1sd07koeSJAHnhnOAESGWAFHATs5aY0duD5rQjzj1cBoAWzTMQvK5amFCfhc2rTr(GHkqsg6ZAFHATncW)9Lyl8)63cDMEGGFI9Teb8WaYFlrMdW8XvCiyh1g5dgQazW21AQwkQTv1E8a9tH(a2yFOJGk0z6bcwlrevlf1E8a9tH(a2yFOJGk0z6bcwRPAjzNvgIRw5tT2wJmRLYAPSwt1srTuuRiZby(4Qlbe26SRpButYnqvGKm0N1k)ALvM1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwkRLiIQLIAfzoaZhxDjGWwND9zJAsUbQcKbBxRPAPb6Dfhc2rTWMJgunpwqyTuRvM1szTuwRPAPb6Dva4Oo7AJ8bdfy(41AQws2zLH4Qv(uRvkhqMEGk2qtcDijaPMKDwBiUVfloy6FlqKpB6mC8FFjkRm)V(TqNPhi4NyFlwCW0)wbdcz)0tdoi8BbItranoy6Fl5Ojw70GdcRf2R9YJSw2bRLnQLdS20Rvawl7G1(K(7RwASwaJA7zu7i9gmQ9SzV2ZgRLKLSwqCWTnVwsMqO3u7eiWAFWATzPyT8v7a55v79K1YHGDSwHnhn4Sw2bR9S5R2lpYAF4P)(QTfhyE1cmrq13seWddi)TezoaZhxDjGWwND9zJAsUbQcKKH(Sw5xRuoGm9avXutYsQbXb3w3ZqF5rwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xRuoGm9avXutYsQbXb3w3ZqZg1AQwkQ94b6NkaCuNDTr(GHcDMEGG1AQwkQvK5amFCva4Oo7AJ8bdvGKm0N1(sTOKOa4q9bjXAjIOAfzoaZhxfaoQZU2iFWqfijd9zTYVwPCaz6bQIPMKLudIdUTUNHosJAPSwIiQ2wv7Xd0pva4Oo7AJ8bdf6m9abRLYAnvlnqVR4qWoQf2C0GQ5XccRv(1kVAnvlisd07Qlbe26SRpButYnqfy(41AQwAGExfaoQZU2iFWqbMpETMQLgO3vCiyh1g5dgkW8X)3xIYk7)1Vf6m9ab)e7BXIdM(3kyqi7NEAWbHFlqCkcOXbt)BjhnXANgCqyTpWZUw2O2hB0R1iNti9av12A71E5rwlCwBGmy7A5zTp4yyETKmHyTtGaR9YAf88QfE1sJ9mWAV8ivFlrapmG83sK5amFC1LacBD21NnQj5gOkqsg6ZAFPwusuaCO(GKyTMQLgO3vCiyh1cBoAq18ybH1(c1ALYbKPhO6YJutYsQf2C0GZAnvRiZby(4koeSJAJ8bdvGKm0N1(sTuulkjkaouFqsSwjulloy6Qlbe26SRpButYnqfkjkaouFqsSwk)3xIYkV)RFl0z6bc(j23seWddi)TezoaZhxXHGDuBKpyOcKKH(S2xQfLefahQpijwRPAPOwkQTv1E8a9tH(a2yFOJGk0z6bcwlrevlf1E8a9tH(a2yFOJGk0z6bcwRPAjzNvgIRw5tT2wJmRLYAPSwt1srTuuRiZby(4Qlbe26SRpButYnqvGKm0N1k)ALYbKPhOIn0KSKAqCWT19m0xEK1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwkRLiIQLIAfzoaZhxDjGWwND9zJAsUbQcKKH(SwQ1kZAnvlnqVR4qWoQf2C0GQ5XccRLATYSwkRLYAnvlnqVRcah1zxBKpyOaZhVwt1sYoRmexTYNATs5aY0duXgAsOdjbi1KSZAdXvlLFlwCW0)wbdcz)0tdoi8FFjklX9F9BHotpqWpX(wS4GP)TUeqyRZU(Srnj3a)wG4ueqJdM(3soAI1E5rw7d8SRLnQf2RfEVN1(apBOx7zJ1sYswlio42QABT9A98mVwGjw7d8SRnsJAH9ApBS2JhOF1cN1EmHOBETSdwl8EpR9bE2qV2ZgRLKLSwqCWTvFlrapmG83IIABvTbGJ9mAq1eAyNUEEzqQqNPhiyTeruT0a9UAcnStxpVmivag1szTMQLgO3vCiyh1cBoAq18ybH1(c1ALYbKPhO6YJutYsQf2C0GZAnvRiZby(4koeSJAJ8bdvGKm0N1(c1ArjrbWH6dsI1AQws2zLH4Qv(1kLditpqfBOjHoKeGutYoRnexTMQLgO3vbGJ6SRnYhmuG5J)VVeLTf8F9BHotpqWpX(wIaEya5VfnqVR4qWoQf2C0GQ5XccR9fQ1kLditpq1LhPMKLulS5ObN1AQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTVqTwusuaCO(GKyTMQvkhqMEGQdsIAa)GdnBuR8RvkhqMEGQlpsnjlPgehCBDpdnB8TyXbt)BDjGWwND9zJAsUb(VVeLLG(V(TqNPhi4NyFlrapmG83IgO3vCiyh1cBoAq18ybH1(c1ALYbKPhO6YJutYsQf2C0GZAnvlf12QApEG(Pcah1zxBKpyOqNPhiyTeruTImhG5JRcah1zxBKpyOcKKH(Sw5xRuoGm9avxEKAswsnio426Eg6inQLYAnvRuoGm9avhKe1a(bhA2Ow5xRuoGm9avxEKAswsnio426EgA24BXIdM(36saHTo76Zg1KCd8FFjkRC6)63cDMEGGFI9TyXbt)BXHGDuBKpy8TaXPiGghm9VLC0eRLnQf2R9YJSw4S20Rvawl7G1(K(7RwASwaJA7zu7i9gmQ9SzV2ZgRLKLSwqCWTnVwsMqO3u7eiWApB(Q9bR1MLI1IEc0yxlj7CTSdw7zZxTNngyTWzTEE1YJazW21Y1gaowB2R1iFWOwW8XvFlrapmG83sK5amFC1LacBD21NnQj5gOkqsg6ZALFTs5aY0duXgAswsnio426Eg6lpYAnvlf12QAfPu0z)usr)SBh1ser1kYCaMpUIegrgtD21xgKOFQajzOpRv(1kLditpqfBOjzj1G4GBR7zOjZRwkR1uT0a9UIdb7OwyZrdQMhliSwQ1sd07koeSJAHnhnOIKLuppwqyTMQLgO3vbGJ6SRnYhmuG5JxRPAjzNvgIRw5tTwPCaz6bQydnj0HKaKAs2zTH4(3xIY2A(V(TqNPhi4NyFlwCW0)wbGJ6SRnYhm(wG4ueqJdM(3soAI1gPrTWETxEK1cN1METcWAzhS2N0FF1sJ1cyuBpJAhP3GrTNn71E2yTKSK1cIdUT51sYec9MANabw7zJbwlC6VVA5rGmy7A5AdahRfmF8AzhS2ZMVAzJAFs)9vlnkssSwwkdhm9aRfeiGEtTbGJQVLiGhgq(Brd07koeSJAJ8bdfy(41AQwkQvK5amFC1LacBD21NnQj5gOkqsg6ZALFTs5aY0dufPHMKLudIdUTUNH(YJSwIiQwrMdW8XvCiyh1g5dgQajzOpR9fQ1kLditpq1LhPMKLudIdUTUNHMnQLYAnvlnqVR4qWoQf2C0GQ5XccRLAT0a9UIdb7OwyZrdQizj1ZJfewRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xRSYSwt1kYCaMpU6saHTo76Zg1KCdufijd9zTYVwzL5)(suw58)1Vf6m9ab)e7Bjc4HbK)ws5aY0duLa3ecI6SRfzoaZhF(TyXbt)BnTH9d6nAJ8bJ)9LOSTW)RFl0z6bc(j23Ifhm9VLrGt0fOo7AsOd(TaXPiGghm9VLC0eR1ijR9YANTiaejWJ1YETOKxW1Y01c9ApBSwhL8QvK5amF8AFGoy(yETa(aNZAjSDazV2Zg9AtF0UwqGa6n1YHGDSwJ8bJAbbWAVSw78Pws25ATb8MODTbdcz)QDAWbH1cNFlrapmG8364b6NkaCuNDTr(GHcDMEGG1AQwAGExXHGDuBKpyOamQ1uT0a9UkaCuNDTr(GHkqsg6ZAFP2gbOIKL8FFjkpz(F9BHotpqWpX(wIaEya5Vfisd07Qlbe26SRpButYnqfGrTMQfePb6D1LacBD21NnQj5gOkqsg6ZAFPwwCW0vCiyh1KW5eoWPcLefahQpijwRPABvTIuk6SFkcBhq2)wS4GP)TmcCIUa1zxtcDW)9LO8K9)63cDMEGGFI9Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(sTncqfjlzTMQvK5amFCfknf8btxfid2Uwt1kYCaMpU6saHTo76Zg1KCdufijd9zTMQTv1ksPOZ(PiSDaz)BXIdM(3YiWj6cuNDnj0b)3)(wGyNbg3)1VeL9)63Ifhm9VLib8dJPbogFl0z6bc(j2)(suE)x)wOZ0de8tSVLiGhgq(BrrThpq)uOpGn2h6iOcDMEGG1AQws2zLH4Q9fQ1kNLzTMQLKDwziUALp1ALteuTuwlrevlf12QApEG(PqFaBSp0rqf6m9abR1uTKSZkdXv7luRvotq1s53Ifhm9Vfj7SUbj)3xIe3)1Vf6m9ab)e7Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)BzKhm9)9Lyl4)63cDMEGGFI9Teb8WaYFRaWXEgnO6qsJm4H(Hddf6m9abR1uT0a9UcL0MbMhmDfGrTMQLIAfzoaZhxXHGDuBKpyOcKbBxlrevlDoN1AQ2oSX(0bsYqFw7luRTfiZAP8BXIdM(36GKO(HdJ)9Lib9F9BHotpqWpX(wIaEya5VfnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwqKgO3vxciS1zxF2OMKBGkW8X)wS4GP)TgWg7BQBXbaBir)(3xIYP)RFl0z6bc(j23seWddi)TOb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6saHTo76Zg1KCdubMp(3Ifhm9Vfn3OZU(cOGW5)(sS18F9BHotpqWpX(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)w0ymXGqO38VVeLZ)x)wOZ0de8tSVLiGhgq(Brd07koeSJAJ8bdfGX3Ifhm9Vf9itqDhiA)VVeBH)x)wOZ0de8tSVLiGhgq(Brd07koeSJAJ8bdfGX3Ifhm9Vvhgi9itW)9LOSY8)63cDMEGGFI9Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TyxGZl4HwWJX)(suwz)V(TqNPhi4NyFlrapmG83IgO3vCiyh1g5dgkaJVfloy6FlGjQHhso)3xIYkV)RFl0z6bc(j23Ifhm9VvZGbH8LXutZGn43seWddi)TOb6Dfhc2rTr(GHcWOwIiQwrMdW8XvCiyh1g5dgQajzOpRv(uRLGiOAnvlisd07Qlbe26SRpButYnqfGX3c7DuCANjXVvZGbH8LXutZGn4)(suwI7)63cDMEGGFI9TyXbt)BHKgTdKh6maD2f43seWddi)TezoaZhxXHGDuBKpyOcKKH(S2xOwRSeuTMQvK5amFC1LacBD21NnQj5gOkqsg6ZAFHATYsqFlNjXVfsA0oqEOZa0zxG)7lrzBb)x)wOZ0de8tSVfloy6FlWazWomqTuCoXX3seWddi)TezoaZhxXHGDuBKpyOcKKH(Sw5tTw5jZAjIOABvTs5aY0duXg601atSwQ1kBTeruTuu7bjXAPwRmR1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQnaCSNrdQMqd701Zldsf6m9abRLYVLZK43cmqgSddulfNtC8VVeLLG(V(TqNPhi4NyFlwCW0)wZeyOHno8W4Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFwR8PwlXjZAjIOABvTs5aY0duXg601atSwQ1k73Yzs8BntGHg24WdJ)9LOSYP)RFl0z6bc(j23Ifhm9VvZOTHTo7AEoHKWbFW0)wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1kFQ1kpzwlrevBRQvkhqMEGk2qNUgyI1sTwzRLiIQLIApijwl1ALzTMQvkhqMEGQoCAd9gDAGog1sTwzR1uTbGJ9mAq1eAyNUEEzqQqNPhiyTu(TCMe)wnJ2g26SR55esch8bt)FFjkBR5)63cDMEGGFI9TyXbt)BrYcMoq90gXttcmHIVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTVqTwcQwt1srTTQwPCaz6bQ6WPn0B0Pb6yul1ALTwIiQ2dsI1k)AjozwlLFlNjXVfjly6a1tBepnjWek(3xIYkN)V(TqNPhi4NyFlwCW0)wKSGPdupTr80KatO4Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7luRLGQ1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQLgO3vbGJ6SRnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTVqTwkQvwzwBlwTeuTT8Adah7z0GQj0WoD98YGuHotpqWAPSwt1EqsS2xQL4K53Yzs8BrYcMoq90gXttcmHI)9LOSTW)RFl0z6bc(j23Ifhm9V10MbZheuNbTo76lds0VVLiGhgq(BDqsSwQ1kZAjIOAPOwPCaz6bQsGBcbrD21ImhG5JpR1uTuulf1ksPOZ(PiSDazVwt1kYCaMpUkyqi7NEAWbHQajzOpR9fQ1kVAnvRiZby(4koeSJAJ8bdvGKm0N1(c1AjOAnvRiZby(4Qlbe26SRpButYnqvGKm0N1(c1AjOAPSwIiQwrMdW8XvCiyh1g5dgQajzOpR9fQ1kVAjIOA7Wg7thijd9zTVuRiZby(4koeSJAJ8bdvGKm0N1szTu(TCMe)wtBgmFqqDg06SRVmir)(3xIYtM)x)wOZ0de8tSVfloy6FlbpgAwCW01d48(wd480otIFlbpead(GPp)3xIYt2)RFl0z6bc(j23seWddi)TyXbLIA0rsioRv(uRvkhqMEGkor9XrdEArc433AEbuCFjk73Ifhm9VLGhdnloy66bCEFRbCEANjXVfN4)(suEY7)63cDMEGGFI9Teb8WaYFlrkfD2pfHTdi71AQ2aWXEgnOIdb7O2MdY0BRqNPhi43Ifhm9VLGhdnloy66bCEFRbCEANjXVLnhKP3(FFjkpI7)63cDMEGGFI9Teb8WaYFlPCaz6bQSzPOonqhbRLATYSwt1kLditpqvhoTHEJonqhJAnvBRQLIAfPu0z)ue2oGSxRPAdah7z0GkoeSJABoitVTcDMEGG1s53Ifhm9VLGhdnloy66bCEFRbCEANjXVvhoTHEJonqhJ)9LO8Ab)x)wOZ0de8tSVLiGhgq(BjLditpqLnlf1Pb6iyTuRvM1AQ2wvlf1ksPOZ(PiSDazVwt1gao2ZObvCiyh12CqMEBf6m9abRLYVfloy6FlbpgAwCW01d48(wd480otIFR0aDm(3xIYJG(V(TqNPhi4NyFlrapmG83Qv1srTIuk6SFkcBhq2R1uTbGJ9mAqfhc2rTnhKP3wHotpqWAP8BXIdM(3sWJHMfhmD9aoVV1aopTZK43sK5amF85)(suEYP)RFl0z6bc(j23seWddi)TKYbKPhOQdDEOPbcVwQ1kZAnvBRQLIAfPu0z)ue2oGSxRPAdah7z0GkoeSJABoitVTcDMEGG1s53Ifhm9VLGhdnloy66bCEFRbCEANjXVvKhFW0)3xIYR18F9BHotpqWpX(wIaEya5VLuoGm9avDOZdnnq41sTwzR1uTTQwkQvKsrN9try7aYETMQnaCSNrdQ4qWoQT5Gm92k0z6bcwlLFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wDOZdnnq4)7FFlJafjjnF)x)su2)RFlwCW0)wCiyh1q)WXaf33cDMEGGFI9VVeL3)1Vfloy6FRjajz6AoeSJ6otchqo(wOZ0de8tS)9LiX9F9BXIdM(3sKEloqGAs2zDds(TqNPhi4Ny)7lXwW)1Vf6m9ab)e7BLgFRaN49TyXbt)BjLditpWVLuo0otIFlor9XrdEArc433ce7mW4(we3)(sKG(V(TqNPhi4NyFR04Bf4eVVfloy6FlPCaz6b(TKYH2zs8BHstTH4(wGyNbg33swc6FFjkN(V(TqNPhi4NyFR04BnX7BXIdM(3skhqMEGFlPCODMe)wgbAamgAuA(Teb8WaYFlkQnaCSNrdQMqd701Zldsf6m9abR1uTuuRiLIo7Nsk6ND7OwIiQwrkfD2pLJIihzawlrevRiDqa4P4qWoQnIee20wHotpqWAPSwk)ws5baQXXe)wY8BjLha43s2)9LyR5)63cDMEGGFI9TsJV1eVVfloy6FlPCaz6b(TKYH2zs8BzZsrDAGoc(Teb8WaYFlwCqPOgDKeIZALp1ALYbKPhOItuFC0GNwKa(9TKYdauJJj(TK53skpaWVLS)7lr58)1Vf6m9ab)e7BLgFRjEFlwCW0)ws5aY0d8BjLha43sMFlPCODMe)wDOZdnnq4)7lXw4)1Vf6m9ab)e7BLgFRaN49TyXbt)BjLditpWVLuo0otIFlBoitVTEESGq9bjXVfi2zGX9TAH)7lrzL5)1Vf6m9ab)e7BLgFRaN49TyXbt)BjLditpWVLuo0otIFlE8WTN6zBxOfzoaZhF(TaXodmUVLm)3xIYk7)1Vf6m9ab)e7BLgFRaN49TyXbt)BjLditpWVLuo0otIFRyQjzj1G4GBR7zOV8i)wGyNbg33IG(3xIYkV)RFl0z6bc(j23kn(wboX7BXIdM(3skhqMEGFlPCODMe)wXutYsQbXb3w3ZqhPX3ce7mW4(we0)(suwI7)63cDMEGGFI9TsJVvGt8(wS4GP)TKYbKPh43skhANjXVvm1KSKAqCWT19m0SX3ce7mW4(wYtM)7lrzBb)x)wOZ0de8tSVvA8TcCI33Ifhm9VLuoGm9a)ws5q7mj(TiZtBeOarq9LhPMU93ce7mW4(wY5)9LOSe0)1Vf6m9ab)e7BLgFRaN49TyXbt)BjLditpWVLuo0otIFlY80KSKAqCWT19m0xEKFlqSZaJ7BjRm)3xIYkN(V(TqNPhi4NyFR04Bf4eVVfloy6FlPCaz6b(TKYH2zs8BrMNMKLudIdUTUNHMn(wGyNbg33swc6FFjkBR5)63cDMEGGFI9TsJVvGt8(wS4GP)TKYbKPh43skhANjXVfBOjzj1G4GBR7zOV8i)wIaEya5VLiDqa4P4qWoQnIee20(BjLhaOght8BjRm)ws5ba(Tioz(VVeLvo)F9BHotpqWpX(wPX3kWjEFlwCW0)ws5aY0d8BjLdTZK43In0KSKAqCWT19m0xEKFlqSZaJ7Bjpz(VVeLTf(F9BHotpqWpX(wPX3kWjEFlwCW0)ws5aY0d8BjLdTZK43In0KSKAqCWT19m0K59TaXodmUVL8K5)(suEY8)63cDMEGGFI9TsJV1eVVfloy6FlPCaz6b(TKYda8BjpzwBlwTuulbvBlVwr6GaWtXHGDuBejiSPTcDMEGG1s53skhANjXVvKgAswsnio426Eg6lpY)9LO8K9)63cDMEGGFI9TsJV1eVVfloy6FlPCaz6b(TKYda8Brq1kHALNmRTLxlf1ksPOZ(PCyJ9P7mwlrevlf1ksheaEkoeSJAJibHnTvOZ0deSwt1YIdkf1OJKqCw7l1kLditpqfNO(4ObpTib8RwkRLYALqTYsq12YRLIAfPu0z)ue2oGSxRPAdah7z0GkoeSJABoitVTcDMEGG1AQwwCqPOgDKeIZALp1ALYbKPhOItuFC0GNwKa(vlLFlPCODMe)wxEKAswsnio426EgA24FFjkp59F9BHotpqWpX(wPX3AI33Ifhm9VLuoGm9a)ws5ba(TKNmRTfRwkQvoxBlVwr6GaWtXHGDuBejiSPTcDMEGG1s53skhANjXV1LhPMKLudIdUTUNHosJ)9LO8iU)RFl0z6bc(j23kn(wt8(wS4GP)TKYbKPh43skpaWVLCsM12Ivlf1sYZdJ2AP8aaRTLxRSYuM1s53seWddi)TePu0z)uoSX(0Dg)ws5q7mj(TO5i4gutYoRne3)(suETG)RFl0z6bc(j23kn(wt8(wS4GP)TKYbKPh43skpaWVvlKGQTfRwkQLKNhgT1s5bawBlVwzLPmRLYVLiGhgq(BjsPOZ(PiSDaz)BjLdTZK43IMJGBqnj7S2qC)7lr5rq)x)wOZ0de8tSVvA8TM49TyXbt)BjLditpWVLuEaGFl5SmRTfRwkQLKNhgT1s5bawBlVwzLPmRLYVLiGhgq(BjLditpqfnhb3GAs2zTH4QLATY8BjLdTZK43IMJGBqnj7S2qC)7lr5jN(V(TqNPhi4NyFR04Bf4eVVfloy6FlPCaz6b(TKYH2zs8BXgAsOdjbi1KSZAdX9TaXodmUVLSe0)(suETM)RFl0z6bc(j23kn(wboX7BXIdM(3skhqMEGFlPCODMe)wxEKAswsTWMJgC(TaXodmUVL8(3xIYto)F9BHotpqWpX(wPX3kWjEFlwCW0)ws5aY0d8BjLdTZK43ItuF5rQjzj1cBoAW53ce7mW4(wY7FFjkVw4)1Vf6m9ab)e7BLgFRjEFlwCW0)ws5aY0d8BjLha43s2AB51srTylcaAyGGkK0ODG8qNbOZUaRLiIQLIApEG(Pcah1zxBKpyOqNPhiyTMQLIApEG(P4qWoQrHDQqNPhiyTeruTTQwrkfD2pfHTdi71szTMQLIABvTIuk6SFkhfroYaSwIiQwwCqPOgDKeIZAPwRS1ser1gao2ZObvtOHD665LbPcDMEGG1szTMQTv1ksPOZ(PKI(z3oQLYAP8BjLdTZK43QdN2qVrNgOJX)(sK4K5)1Vf6m9ab)e7BLgFRjEFlwCW0)ws5aY0d8BjLha43cBraqddeurYcMoq90gXttcmHIAjIOAXwea0WabvndgeYxgtnnd2G1ser1ITiaOHbcQAgmiKVmMAseKhdy61ser1ITiaOHbcQa5GqYmDnikiuBaCbofOlWAjIOAXwea0WabvqFkcGJPhOUfbW(bqQbrPqbwlrevl2IaGggiOAMaJbEh0B0baD7AjIOAXwea0WabvtaNEKjOMjXZU98QLiIQfBraqddeu9WeIogtDpshSwIiQwSfbanmqqvFWKOo7AA(Ub(TKYH2zs8BXg601at8FFjsCY(F9BXIdM(3IegrgAij3GFl0z6bc(j2)(sK4K3)1Vf6m9ab)e7Bjc4HbK)wZeyqdDqL0CWhCG6zoKI(PqNPhiyTeruTZeyqdDqLbW8agOgdaJdMUcDMEGGFlwCW0)w9boTfb3V)9LiXrC)x)wOZ0de8tSVLiGhgq(BjsPOZ(PiSDazVwt1gao2ZObvCiyh12CqMEBf6m9abR1uTI0bbGNIdb7O2isqytBf6m9abR1uTs5aY0duXJhU9upB7cTiZby(4ZAnvlloOuuJoscXzTVuRuoGm9avCI6JJg80IeWVVfloy6FRaWrD21g5dg)7lrIRf8F9BHotpqWpX(wIaEya5VvRQvkhqMEGkJanagdnknRLATYwRPAdah7z0Gkq4uangqNJ2ArssYoOcDMEGGFlwCW0)w9iNhDoU)9LiXrq)x)wOZ0de8tSVLiGhgq(B1QALYbKPhOYiqdGXqJsZAPwRS1AQ2wvBa4ypJgubcNcOXa6C0wlsss2bvOZ0deSwt1srTTQwrkfD2pLu0p72rTeruTs5aY0du1HtBO3Otd0XOwk)wS4GP)T4qWoQPh88(3xIeNC6)63cDMEGGFI9Teb8WaYFRwvRuoGm9avgbAamgAuAwl1ALTwt12QAdah7z0Gkq4uangqNJ2ArssYoOcDMEGG1AQwrkfD2pLu0p72rTMQTv1kLditpqvhoTHEJonqhJVfloy6Flsyezm1zxFzqI(9VVejUwZ)1Vf6m9ab)e7Bjc4HbK)ws5aY0duzeObWyOrPzTuRv2Vfloy6FluAk4dM()(33It8)6xIY(F9BHotpqWpX(wIaEya5Vva4ypJgubcNcOXa6C0wlsss2bvOZ0deSwt1kYCaMpUIgO31GWPaAmGohT1IKKKDqvGmy7AnvlnqVRaHtb0yaDoARfjjj7G6EKZtbMpETMQLIAPb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6saHTo76Zg1KCdubMpETuwRPAfzoaZhxDjGWwND9zJAsUbQcKKH(SwQ1kZAnvlf1sd07koeSJAHnhnOAESGWAFHATs5aY0duXjQV8i1KSKAHnhn4Swt1srTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xOwBJaSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwPCaz6bQU8i1KSKAqCWT19m0SrTuwlrevlf12QApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs5aY0duD5rQjzj1G4GBR7zOzJAPSwIiQwrMdW8XvCiyh1g5dgQajzOpR9fQ12iaRLYAP8BXIdM(3Qh58OZX9VVeL3)1Vf6m9ab)e7Bjc4HbK)wuuBa4ypJgubcNcOXa6C0wlsss2bvOZ0deSwt1kYCaMpUIgO31GWPaAmGohT1IKKKDqvGmy7AnvlnqVRaHtb0yaDoARfjjj7G6omqfy(41AQwJaLQBeGkzv9iNhDoUAPSwIiQwkQnaCSNrdQaHtb0yaDoARfjjj7Gk0z6bcwRPApijwl1ALzTu(TyXbt)B1HbQPh88(3xIe3)1Vf6m9ab)e7Bjc4HbK)wbGJ9mAqvtaNJ2AOakgOcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sCYSwt1kYCaMpU6saHTo76Zg1KCdufijd9zTuRvM1AQwkQLgO3vCiyh1cBoAq18ybH1(c1ALYbKPhOItuF5rQjzj1cBoAWzTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTVqT2gbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs5aY0duD5rQjzj1G4GBR7zOzJAPSwIiQwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)ALYbKPhO6YJutYsQbXb3w3ZqZg1szTeruTImhG5JR4qWoQnYhmubsYqFw7luRTrawlL1s53Ifhm9VvpY5P9uk)VVeBb)x)wOZ0de8tSVLiGhgq(Bfao2ZObvnbCoARHcOyGk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(SwQ1kZAnvlf1srTuuRiZby(4Qlbe26SRpButYnqvGKm0N1k)ALYbKPhOIn0KSKAqCWT19m0xEK1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwkRLiIQLIAfzoaZhxDjGWwND9zJAsUbQcKKH(SwQ1kZAnvlnqVR4qWoQf2C0GQ5XccR9fQ1kLditpqfNO(YJutYsQf2C0GZAPSwkR1uT0a9UkaCuNDTr(GHcmF8AP8BXIdM(3Qh580EkL)3xIe0)1Vf6m9ab)e7BXIdM(3Idb7OMeoNWbo)wcBg6Flz)wIaEya5VLiLIo7NIW2bK9AnvBa4ypJguXHGDuBZbz6TvOZ0deSwt1sd07koeSJABoitVTAESGWAFPwzjOAnvRiZby(4QGbHSF6PbheQcKKH(S2xOwRuoGm9av2CqMEB98ybH6dsI1kHArjrbWH6dsI1AQwrMdW8XvxciS1zxF2OMKBGQajzOpR9fQ1kLditpqLnhKP3wppwqO(GKyTsOwusuaCO(GKyTsOwwCW0vbdcz)0tdoiuHsIcGd1hKeR1uTImhG5JR4qWoQnYhmubsYqFw7luRvkhqMEGkBoitVTEESGq9bjXALqTOKOa4q9bjXALqTS4GPRcgeY(PNgCqOcLefahQpijwReQLfhmD1LacBD21NnQj5gOcLefahQpij(VVeLt)x)wOZ0de8tSVLiGhgq(BjsPOZ(PKI(z3oQ1uThpq)uCiyh1OWovOZ0deSwt1EqsS2xQvwzwRPAfzoaZhxrcJiJPo76lds0pvGKm0N1AQwAGExjgihcEEqVrnpwqyTVulX9TyXbt)BXHGDutp459VVeBn)x)wOZ0de8tSVLiGhgq(Bfao2ZObvtOHD665LbPcDMEGG1AQwJaLQBeGkzvO0uWhm9Vfloy6FRlbe26SRpButYnW)9LOC()63cDMEGGFI9Teb8WaYFRaWXEgnOAcnStxpVmivOZ0deSwt1srTgbkv3iavYQqPPGpy61ser1AeOuDJaujR6saHTo76Zg1KCdSwk)wS4GP)T4qWoQnYhm(3xITW)RFl0z6bc(j23seWddi)TezoaZhxXHGDuBKpyOcKKH(S2xOwRCUwt1kYCaMpU6saHTo76Zg1KCdufijd9zTVqTw5CTMQLIAPb6Dfhc2rTWMJgunpwqyTVqTwPCaz6bQ4e1xEKAswsTWMJgCwRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7luRTrawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlbvlL1ser1srTTQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlbvlL1ser1kYCaMpUIdb7O2iFWqfijd9zTVqT2gbyTuwlLFlwCW0)wKWiYyQZU(YGe97FFjkRm)V(TqNPhi4NyFlrapmG836GKyTYVwItM1AQ2aWXEgnOAcnStxpVmivOZ0deSwt1ksPOZ(PKI(z3oQ1uTgbkv3iavYQiHrKXuND9Lbj633Ifhm9Vfknf8bt)FFjkRS)x)wOZ0de8tSVLiGhgq(BDqsSw5xlXjZAnvBa4ypJgunHg2PRNxgKk0z6bcwRPAPb6Dfhc2rTWMJgunpwqyTVqTwPCaz6bQ4e1xEKAswsTWMJgCwRPAfzoaZhxDjGWwND9zJAsUbQcKKH(SwQ1kZAnvRiZby(4koeSJAJ8bdvGKm0N1(c1ABeGFlwCW0)wO0uWhm9)9LOSY7)63cDMEGGFI9TyXbt)BHstbFW0)wq)WiamonS)TOb6D1eAyNUEEzqQMhliKknqVRMqd701ZldsfjlPEESGWVf0pmcaJtdjjrqiF43s2VLiGhgq(BDqsSw5xlXjZAnvBa4ypJgunHg2PRNxgKk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(SwQ1kZAnvlf1srTuuRiZby(4Qlbe26SRpButYnqvGKm0N1k)ALYbKPhOIn0KSKAqCWT19m0xEK1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhliSwkRLiIQLIAfzoaZhxDjGWwND9zJAsUbQcKKH(SwQ1kZAnvlnqVR4qWoQf2C0GQ5XccR9fQ1kLditpqfNO(YJutYsQf2C0GZAPSwkR1uT0a9UkaCuNDTr(GHcmF8AP8FFjklX9F9BHotpqWpX(wIaEya5VLiZby(4Qlbe26SRpButYnqvGKm0N1(sTOKOa4q9bjXAnvlf1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFHATncWAnvRiZby(4koeSJAJ8bdvGKm0N1k)ALYbKPhO6YJutYsQbXb3w3ZqZg1szTeruTuuBRQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kLditpq1LhPMKLudIdUTUNHMnQLYAjIOAfzoaZhxXHGDuBKpyOcKKH(S2xOwBJaSwk)wS4GP)TcgeY(PNgCq4)(su2wW)1Vf6m9ab)e7Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7l1IsIcGd1hKeR1uTuulf1srTImhG5JRUeqyRZU(Srnj3avbsYqFwR8RvkhqMEGk2qtYsQbXb3w3ZqF5rwRPAPb6Dfhc2rTWMJgunpwqyTuRLgO3vCiyh1cBoAqfjlPEESGWAPSwIiQwkQvK5amFC1LacBD21NnQj5gOkqsg6ZAPwRmR1uT0a9UIdb7OwyZrdQMhliS2xOwRuoGm9avCI6lpsnjlPwyZrdoRLYAPSwt1sd07QaWrD21g5dgkW8XRLYVfloy6FRGbHSF6Pbhe(VVeLLG(V(TqNPhi4NyFlrapmG83sK5amFCfhc2rTr(GHkqsg6ZAPwRmR1uTuulf1srTImhG5JRUeqyRZU(Srnj3avbsYqFwR8RvkhqMEGk2qtYsQbXb3w3ZqF5rwRPAPb6Dfhc2rTWMJgunpwqyTuRLgO3vCiyh1cBoAqfjlPEESGWAPSwIiQwkQvK5amFC1LacBD21NnQj5gOkqsg6ZAPwRmR1uT0a9UIdb7OwyZrdQMhliS2xOwRuoGm9avCI6lpsnjlPwyZrdoRLYAPSwt1sd07QaWrD21g5dgkW8XRLYVfloy6FlqKpB6mC8FFjkRC6)63cDMEGGFI9Teb8WaYFlkQLgO3vCiyh1cBoAq18ybH1(c1ALYbKPhOItuF5rQjzj1cBoAWzTeruTgbkv3iavYQcgeY(PNgCqyTuwRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7luRTrawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xRuoGm9avxEKAswsnio426EgA2OwkRLiIQLIABvThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwPCaz6bQU8i1KSKAqCWT19m0SrTuwlrevRiZby(4koeSJAJ8bdvGKm0N1(c1ABeG1s53Ifhm9V1LacBD21NnQj5g4)(su2wZ)1Vf6m9ab)e7Bjc4HbK)wuulf1kYCaMpU6saHTo76Zg1KCdufijd9zTYVwPCaz6bQydnjlPgehCBDpd9LhzTMQLgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccRLYAjIOAPOwrMdW8XvxciS1zxF2OMKBGQajzOpRLATYSwt1sd07koeSJAHnhnOAESGWAFHATs5aY0duXjQV8i1KSKAHnhn4SwkRLYAnvlnqVRcah1zxBKpyOaZh)BXIdM(3Idb7O2iFW4FFjkRC()63cDMEGGFI9Teb8WaYFlAGExfaoQZU2iFWqbMpETMQLIAPOwrMdW8XvxciS1zxF2OMKBGQajzOpRv(1kpzwRPAPb6Dfhc2rTWMJgunpwqyTuRLgO3vCiyh1cBoAqfjlPEESGWAPSwIiQwkQvK5amFC1LacBD21NnQj5gOkqsg6ZAPwRmR1uT0a9UIdb7OwyZrdQMhliS2xOwRuoGm9avCI6lpsnjlPwyZrdoRLYAPSwt1srTImhG5JR4qWoQnYhmubsYqFwR8Rvw5vlrevlisd07Qlbe26SRpButYnqfGrTu(TyXbt)BfaoQZU2iFW4FFjkBl8)63cDMEGGFI9Teb8WaYFlrMdW8XvCiyh1zqRcKKH(Sw5xlbvlrevBRQ94b6NIdb7OodAf6m9ab)wS4GP)TM2W(b9gTr(GX)(suEY8)63cDMEGGFI9Teb8WaYFlrkfD2pfHTdi71AQ2aWXEgnOIdb7O2MdY0BRqNPhiyTMQLgO3vCiyh1g5dgkaJAnvlisd07QGbHSF6PbheQLcmCmyA4aETvZJfewl1ABb1AQwJaLQBeGkzvCiyh1zqxRPAzXbLIA0rsioR9LABnFlwCW0)wCiyh10dEE)7lr5j7)1Vf6m9ab)e7Bjc4HbK)wIuk6SFkcBhq2R1uTbGJ9mAqfhc2rTnhKP3wHotpqWAnvlnqVR4qWoQnYhmuag1AQwqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliSwQ12c(wS4GP)T4qWoQP5i4g8FFjkp59F9BHotpqWpX(wIaEya5VLiLIo7NIW2bK9AnvBa4ypJguXHGDuBZbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQLIAbZtfmiK9tpn4GqvGKm0N1k)ALt1ser1cI0a9Ukyqi7NEAWbHAPadhdMgoGxBfGrTuwRPAbrAGExfmiK9tpn4GqTuGHJbtdhWRTAESGWAFP2wqTMQLfhukQrhjH4SwQ1sCFlwCW0)wCiyh10dEE)7lr5rC)x)wOZ0de8tSVLiGhgq(BjsPOZ(PiSDazVwt1gao2ZObvCiyh12CqMEBf6m9abR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpn4GqTuGHJbtdhWRTAESGWAPwlX9TyXbt)BXHGDuNb9)(suETG)RFl0z6bc(j23seWddi)TePu0z)ue2oGSxRPAdah7z0GkoeSJABoitVTcDMEGG1AQwAGExXHGDuBKpyOamQ1uTGinqVRcgeY(PNgCqOwkWWXGPHd41wnpwqyTuRvEFlwCW0)wCiyh10CeCd(VVeLhb9F9BHotpqWpX(wIaEya5VLiLIo7NIW2bK9AnvBa4ypJguXHGDuBZbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQ1iqP6gbOsEQGbHSF6PbhewRPAzXbLIA0rsioRv(1sCFlwCW0)wCiyh1OKgJCct)FFjkp50)1Vf6m9ab)e7Bjc4HbK)wIuk6SFkcBhq2R1uTbGJ9mAqfhc2rTnhKP3wHotpqWAnvlnqVR4qWoQnYhmuag1AQwqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliSwQ1kBTMQLfhukQrhjH4Sw5xlX9TyXbt)BXHGDuJsAmYjm9)9LO8An)x)wOZ0de8tSVLiGhgq(Brd07kqKpB6mCubyuRPAbrAGExDjGWwND9zJAsUbQamQ1uTGinqVRUeqyRZU(Srnj3avbsYqFw7luRLgO3vgborxG6SRjHoOIKLuppwqyTT8AzXbtxXHGDutp45PqjrbWH6dsI1AQwkQLIApEG(PcCMo7cuHotpqWAnvlloOuuJoscXzTVuBlOwkRLiIQLfhukQrhjH4S2xQLGQLYAnvlf12QAdah7z0GkoeSJA6KKMdqs0pf6m9abRLiIQ94ObpLnYJZwziUALFTehbvlLFlwCW0)wgborxG6SRjHo4)(suEY5)RFl0z6bc(j23seWddi)TOb6DfiYNnDgoQamQ1uTuulf1E8a9tf4mD2fOcDMEGG1AQwwCqPOgDKeIZAFP2wqTuwlrevlloOuuJoscXzTVulbvlL1AQwkQTv1gao2ZObvCiyh10jjnhGKOFk0z6bcwlrev7XrdEkBKhNTYqC1k)AjocQwk)wS4GP)T4qWoQPh88(3xIYRf(F9BXIdM(3AcyGHNs5Vf6m9ab)e7FFjsCY8)63cDMEGGFI9Teb8WaYFlAGExXHGDulS5ObvZJfewR8Pwlf1YIdkf1OJKqCwBlwTYwlL1AQ2aWXEgnOIdb7OMojP5aKe9tHotpqWAnv7XrdEkBKhNTYqC1(sTehb9TyXbt)BXHGDutZrWn4)(sK4K9)63cDMEGGFI9Teb8WaYFlAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhli8BXIdM(3Idb7OMMJGBW)9LiXjV)RFl0z6bc(j23seWddi)TOb6Dfhc2rTWMJgunpwqyTuRvM1AQwkQvK5amFCfhc2rTr(GHkqsg6ZALFTYsq1ser12QAPOwrkfD2pfHTdi71AQ2aWXEgnOIdb7O2MdY0BRqNPhiyTuwlLFlwCW0)wCiyh1zq)VVejoI7)63cDMEGGFI9Teb8WaYFlkQnWEGtBMEG1ser12QApOGqO3ulL1AQwAGExXHGDulS5ObvZJfewl1APb6Dfhc2rTWMJgurYsQNhli8BXIdM(3YXZgd9HKg48(3xIexl4)63cDMEGGFI9Teb8WaYFlAGExjgihcEEqVrfilUAnvBa4ypJguXHGDuBZbz6TvOZ0deSwt1srTuu7Xd0pftAmGDOGpy6k0z6bcwRPAzXbLIA0rsioR9LALZ1szTeruTS4Gsrn6ijeN1(sTeuTu(TyXbt)BXHGDutcNt4aN)7lrIJG(V(TqNPhi4NyFlrapmG83IgO3vIbYHGNh0BubYIRwt1E8a9tXHGDuJc7uHotpqWAnvlisd07Qlbe26SRpButYnqfGrTMQLIApEG(PysJbSdf8btxHotpqWAjIOAzXbLIA0rsioR9LABH1s53Ifhm9Vfhc2rnjCoHdC(VVejo50)1Vf6m9ab)e7Bjc4HbK)w0a9Usmqoe88GEJkqwC1AQ2JhOFkM0ya7qbFW0vOZ0deSwt1YIdkf1OJKqCw7l12c(wS4GP)T4qWoQjHZjCGZ)9LiX1A(V(TqNPhi4NyFlrapmG83IgO3vCiyh1cBoAq18ybH1(sT0a9UIdb7OwyZrdQizj1ZJfe(TyXbt)BXHGDuJsAmYjm9)9LiXjN)V(TqNPhi4NyFlrapmG83IgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccR1uTgbkv3iavYQ4qWoQP5i4g8BXIdM(3Idb7OgL0yKty6)7FFlBoitV9)1VeL9)63cDMEGGFI9TyXbt)BHstbFW0)wG4ueqJdM(3Q12RDKp1METKSZ1YoyTImhG5JpRLdSwrsc9MAbmmV2MSw2gzWAzhSwuA(Teb8WaYFls2zLH4Q9fQ1sCYSwt1kLditpqvcCtiiQZUwK5amF8zTMQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(sTYkZAP8FFjkV)RFl0z6bc(j23ceNIaACW0)wYHyTpSF1EzTZJfewRnhKP3U2oWy0wv7R2yTatS2SxRSYPANhliCwRngyTWzTxwllejGF12ZO2ZgR9GccRDG9R20R9SXAf2S74Ow2bR9SXAjHZjCG1c9A7dyJ9P(wIaEya5Vff1kLditpq18ybHABoitVDTeruThKeR9LALvM1szTMQLgO3vCiyh12CqMEB18ybH1(sTYkN(wcBg6Flz)wS4GP)T4qWoQjHZjCGZ)9LiX9F9BHotpqWpX(wS4GP)T4qWoQjHZjCGZVfiofb04GP)TKdTrVwGj0BQLaJ0ODG8OwcCbOZUanVwbpVA5A74tTOKxW1scNt4aN1(ydhyTpm8GEtT9mQ9SXAPb69A5R2ZgRDECC1M9ApBS2oSX((wIaEya5Vf2IaGggiOcjnAhip0za6SlWAnv7bjXAFPwItM1AQ2lBAgOsK5amF8zTMQvK5amFCfsA0oqEOZa0zxGQajzOpRv(1kRCsoxRPABvTS4GPRqsJ2bYdDgGo7cubcNm9ab)3xITG)RFl0z6bc(j23seWddi)TKYbKPhOcjnYhmqqnnhb3G1AQwrMdW8XvxciS1zxF2OMKBGQajzOpR9fQ1IsIcGd1hKeR1uTImhG5JR4qWoQnYhmubsYqFw7luRLIArjrbWH6dsI12YRvE1szTMQLIABvTylcaAyGGQzcmg4DqVrha0TRLiIQvKoia8uCiyh1grccBARc2jSw5tTwcQwIiQwrMdW8XvZeymW7GEJoaOBRcKKH(S2xOwlf1IsIcGd1hKeRTLxR8QLYAP8BXIdM(3kyqi7NEAWbH)7lrc6)63cDMEGGFI9Teb8WaYFlPCaz6bQAXbMNgyIG6PbhewRPAfzoaZhxXHGDuBKpyOcKKH(S2xOwlkjkaouFqsSwt1srTTQwSfbanmqq1mbgd8oO3Oda621ser1ksheaEkoeSJAJibHnTvb7ewR8PwlbvlrevRiZby(4Qzcmg4DqVrha0TvbsYqFw7luRfLefahQpijwlLFlwCW0)wxciS1zxF2OMKBG)7lr50)1Vf6m9ab)e7Bjc4HbK)wgbkv3iavYQUeqyRZU(Srnj3a)wS4GP)T4qWoQnYhm(3xITM)RFl0z6bc(j23seWddi)TKYbKPhOcjnYhmqqnnhb3G1AQwrMdW8Xvbdcz)0tdoiufijd9zTVqTwusuaCO(GKyTMQvkhqMEGQdsIAa)GdnBuR8PwR8KzTMQLIABvTI0bbGNIdb7O2isqytBf6m9abRLiIQTv1kLditpqfpE42t9STl0ImhG5JpRLiIQvK5amFC1LacBD21NnQj5gOkqsg6ZAFHATuulkjkaouFqsS2wETYRwkRLYVfloy6FRaWrD21g5dg)7lr58)1Vf6m9ab)e7Bjc4HbK)ws5aY0duHKg5dgiOMMJGBWAnvRrGs1ncqLSQaWrD21g5dgFlwCW0)wbdcz)0tdoi8FFj2c)V(TqNPhi4NyFlrapmG83skhqMEGQwCG5PbMiOEAWbH1AQ2wvRuoGm9av25ae6n6lpYVfloy6FRlbe26SRpButYnW)9LOSY8)63cDMEGGFI9TyXbt)BXHGDutZrWn43ceNIaACW0)wYrtSw55G1YHGDSwAocUbRf612sTUeKdiW161M(ODTWETeBKj4ayE1YoyT8v7a55vR8QLaiGzTgrkei43seWddi)TOb6Dfhc2rTWMJgunpwqyTuRLgO3vCiyh1cBoAqfjlPEESGWAnvlnqVRcah1zxBKpyOamQ1uT0a9UIdb7O2iFWqbyuRPAPb6Dfhc2rTnhKP3wnpwqyTYNATYkNQ1uT0a9UIdb7O2iFWqfijd9zTVqTwwCW0vCiyh10CeCdQqjrbWH6dsI1AQwAGExrpYeCampfGX)(suwz)V(TqNPhi4NyFlwCW0)wbGJ6SRnYhm(wG4ueqJdM(3soAI1kphSw5GS1Rf612sTETPpAxlSxlXgzcoaMxTSdwR8QLaiGzTgrk(wIaEya5VfnqVRcah1zxBKpyOaZhVwt1sd07k6rMGdG5PamQ1uTuuRuoGm9avhKe1a(bhA2Ow5xlXjZAjIOAfzoaZhxfmiK9tpn4GqvGKm0N1k)ALvE1szTMQLIAPb6Dfhc2rTnhKP3wnpwqyTYNATYsq1ser1sd07kXa5qWZd6nQ5XccRv(uRv2APSwt1srTTQwr6GaWtXHGDuBejiSPTcDMEGG1ser12QALYbKPhOIhpC7PE22fArMdW8XN1s5)(suw59F9BHotpqWpX(wIaEya5VfnqVR4qWoQnYhmuG5JxRPAPOwPCaz6bQoijQb8do0SrTYVwItM1ser1kYCaMpUkyqi7NEAWbHQajzOpRv(1kR8QLYAnvlf12QAfPdcapfhc2rTrKGWM2k0z6bcwlrevBRQvkhqMEGkE8WTN6zBxOfzoaZhFwlLFlwCW0)wbGJ6SRnYhm(3xIYsC)x)wOZ0de8tSVLiGhgq(BjLditpqfsAKpyGGAAocUbR1uTuulnqVR4qWoQf2C0GQ5XccRv(uRvE1ser1kYCaMpUIdb7OodAvGmy7APSwt1srTTQ2JhOFQaWrD21g5dgk0z6bcwlrevRiZby(4QaWrD21g5dgQajzOpRv(1sq1szTMQvkhqMEGkCEqs(qqnBOfzoaZhVw5tTwItM1AQwkQTv1ksheaEkoeSJAJibHnTvOZ0deSwIiQ2wvRuoGm9av84HBp1Z2UqlYCaMp(Swk)wS4GP)TcgeY(PNgCq4)(su2wW)1Vf6m9ab)e7BXIdM(36saHTo76Zg1KCd8BbItranoy6Fl5qB0RnaCh6n1AejiSPT51cmXAV8iRLUDTWBIJETqV2maXO2lRLhWgVw4v7d8SRLn(wIaEya5VLuoGm9avhKe1a(bhA2O2xQLGKzTMQvkhqMEGQdsIAa)GdnBuR8RL4KzTMQLIABvTylcaAyGGQzcmg4DqVrha0TRLiIQvKoia8uCiyh1grccBARc2jSw5tTwcQwk)3xIYsq)x)wOZ0de8tSVLiGhgq(BjLditpqvloW80ateupn4GWAnvlnqVR4qWoQf2C0GQ5XccR9LAPb6Dfhc2rTWMJgurYsQNhli8BXIdM(3Idb7Ood6)9LOSYP)RFl0z6bc(j23seWddi)TarAGExfmiK9tpn4GqTuGHJbtdhWRTAESGWAPwlisd07QGbHSF6PbheQLcmCmyA4aETvKSK65Xcc)wS4GP)T4qWoQP5i4g8FFjkBR5)63cDMEGGFI9Teb8WaYFlPCaz6bQAXbMNgyIG6Pbhewlrevlf1cI0a9Ukyqi7NEAWbHAPadhdMgoGxBfGrTMQfePb6DvWGq2p90Gdc1sbgogmnCaV2Q5XccR9LAbrAGExfmiK9tpn4GqTuGHJbtdhWRTIKLuppwqyTu(TyXbt)BXHGDutp459VVeLvo)F9BHotpqWpX(wS4GP)T4qWoQP5i4g8BbItranoy6Fl5Ojwlj0H1smocUbRLgVhe9AdgeY(v70GdcN1c71c4GyulXi4AFGNDcC1cIdUn0BQvoGbHSF1AzWbH1cbrEmA)Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dfhc2rTr(GHcmF8AnvlnqVROhzcoaMNcWOwt1kYCaMpUkyqi7NEAWbHQajzOpR9fQ1kRmR1uT0a9UIdb7O2MdY0BRMhliSw5tTwzLt)7lrzBH)x)wOZ0de8tSVfloy6FloeSJ6mO)wG4ueqJdM(3soAI1MbDTPxRaSwaFGZzTSrTWzTIKe6n1cyu7mt)Bjc4HbK)w0a9UIdb7OwyZrdQMhliS2xQL4Q1uTs5aY0duDqsud4hCOzJALFTYkZAnvlf1kYCaMpU6saHTo76Zg1KCdufijd9zTYVwcQwIiQ2wvRiDqa4P4qWoQnIee20wHotpqWAP8FFjkpz(F9BHotpqWpX(wS4GP)T4qWoQjHZjCGZVLWMH(3s2VLiGhgq(Brd07kXa5qWZd6nQazXvRPAPb6Dfhc2rTr(GHcW4FFjkpz)V(TqNPhi4NyFlwCW0)wCiyh10CeCd(TaXPiGghm9VvRTx7dwBdE1AKpyul07aty61cceqVP2bW8Q9bFpg1AZsXArpbASR1MNhw7L12GxTzVxlx78I0BQLMJGBWAbbcO3u7zJ1gPHmyJAFGoy(8Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(c1AzXbtxXHGDutcNt4aNkusuaCO(GKyTMQLgO3vCiyh1g5dgkaJAnvlnqVR4qWoQf2C0GQ5XccRLAT0a9UIdb7OwyZrdQizj1ZJfewRPAPb6Dfhc2rTnhKP3wnpwqyTMQLgO3vg5dgAO3bMW0vag1AQwAGExrpYeCampfGX)(suEY7)63cDMEGGFI9TyXbt)BXHGDutp459TaXPiGghm9VvRTx7dwBdE1AKpyul07aty61cceqVP2bW8Q9bFpg1AZsXArpbASR1MNhw7L12GxTzVxlx78I0BQLMJGBWAbbcO3u7zJ1gPHmyJAFGoy(yETZS2h89yuB6J21cmXArpbASRLEWZBwl0HhKhJ21EzTn4v7L12tGOwHnhn48Bjc4HbK)w0a9UYiWj6cuNDnj0bvag1AQwkQLgO3vCiyh1cBoAq18ybH1(sT0a9UIdb7OwyZrdQizj1ZJfewlrevBRQLIAPb6DLr(GHg6DGjmDfGrTMQLgO3v0JmbhaZtbyulL1s5)(suEe3)1Vf6m9ab)e7BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(36vBSwACE1cmXAZETgjzTWzTxwlWeRfE1EzTTiaOGWr7APbGdWAf2C0GZAbbcO3ulBul3pmQ9SX212GxTGaKgiyT0TR9SXAT5Gm921sZrWn43seWddi)TOb6Dfhc2rTWMJgunpwqyTVulnqVR4qWoQf2C0Gksws98ybH1AQwAGExXHGDuBKpyOam(3xIYRf8F9BHotpqWpX(wG4ueqJdM(3soeR9H9R2lRDESGWAT5Gm9212bgJ2QAF1gRfyI1M9ALvov78ybHZATXaRfoR9YAzHib8R2Eg1E2yThuqyTdSF1METNnwRWMDhh1YoyTNnwljCoHdSwOxBFaBSp13Ifhm9Vfhc2rnjCoHdC(TG(HrayCFlz)wcBg6Flz)wIaEya5VfnqVR4qWoQT5Gm92Q5XccR9LALvo9TG(HrayC6MrsZJVLS)7lr5rq)x)wOZ0de8tSVLiGhgq(Brd07koeSJAHnhnOAESGWAPwlnqVR4qWoQf2C0Gksws98ybH1AQwPCaz6bQqsJ8bdeutZrWn43Ifhm9Vfhc2rnnhb3G)7lr5jN(V(TqNPhi4NyFlrapmG83IKDwziUAFPwzjOVfloy6FluAk4dM()(suETM)RFl0z6bc(j23Ifhm9Vfhc2rn9GN33ceNIaACW0)we48r7AbMyT0dEE1EzT0aWbyTcBoAWzTWETpyT8iqgSDT2SuS2zsI12JKS2mO)wIaEya5VfnqVR4qWoQf2C0GQ5XccR1uT0a9UIdb7OwyZrdQMhliS2xQLgO3vCiyh1cBoAqfjlPEESGW)9LO8KZ)x)wOZ0de8tSVfiofb04GP)TKJd4yu7d8SRLjRfWh4CwlBulCwRijHEtTag1YoyTp47aRDKp1METKSZFlwCW0)wCiyh1KW5eoW53c6hgbGX9TK9BjSzO)TK9Bjc4HbK)wTQwkQvkhqMEGQdsIAa)GdnBu7luRvwzwRPAjzNvgIR2xQL4KzTu(TG(HrayC6MrsZJVLS)7lr51c)V(TqNPhi4NyFlqCkcOXbt)B16r2HdCw7d8SRDKp1sYZdJ2MxRnSXUwBEEO51MrT05zxlj3UwpVATzPyTONan21sYox7L1obmmY4Q1oFQLKDUwOFOpHsXAdgeY(v70GdcRvWET0O51oZAFW3JrTatS2omWAPh88QLDWA7rop6CC1(yJETJ8P20RLKD(BXIdM(3Qddutp459VVejoz(F9BXIdM(3Qh58OZX9TqNPhi4Ny)7FFlbpead(GPp)V(LOS)x)wOZ0de8tSVvA8TM49TyXbt)BjLditpWVLuEaGFlz)wIaEya5VLuoGm9av2SuuNgOJG1sTwzwRPAncuQUraQKvHstbFW0R1uTTQwkQnaCSNrdQMqd701Zldsf6m9abRLiIQnaCSNrdQoK0idEOF4WqHotpqWAP8BjLdTZK43YMLI60aDe8FFjkV)RFl0z6bc(j23kn(wt8(wS4GP)TKYbKPh43skpaWVLSFlrapmG83skhqMEGkBwkQtd0rWAPwRmR1uT0a9UIdb7O2iFWqbMpETMQvK5amFCfhc2rTr(GHkqsg6ZAnvlf1gao2ZObvtOHD665LbPcDMEGG1ser1gao2ZObvhsAKbp0pCyOqNPhiyTu(TKYH2zs8BzZsrDAGoc(VVejU)RFl0z6bc(j23kn(wt8(wS4GP)TKYbKPh43skpaWVLSFlrapmG83IgO3vCiyh1cBoAq18ybH1sTwAGExXHGDulS5ObvKSK65XccR1uTTQwAGExfaduND9zhiovag1AQ2oSX(0bsYqFw7luRLIAPOws25ALrTS4GPR4qWoQPh88uICE1szTT8AzXbtxXHGDutp45PqjrbWH6dsI1s53skhANjXVvh68qtde()(sSf8F9BHotpqWpX(wPX3AI33Ifhm9VLuoGm9a)ws5ba(TOb6Dfhc2rTnhKP3wnpwqyTYNATYsq1ser1srTbGJ9mAqfhc2rnDssZbij6NcDMEGG1AQ2JJg8u2ipoBLH4Q9LAjocQwk)wG4ueqJdM(3IadE2yulxBhymAx78ybHiyT2CqME7AZOwOxlkjkaoS2G9gS2h4zxlXssAoajr)(ws5q7mj(TqsJ8bdeutZrWn4)(sKG(V(TqNPhi4NyFR04BnX7BXIdM(3skhqMEGFlPCODMe)wdEEA2qdmXVfi2zGX9TK53seWddi)TOb6Dfhc2rTr(GHcWOwt1srTs5aY0dun45PzdnWeRLATYSwIiQ2dsI1kFQ1kLditpq1GNNMn0atSwjuRSeuTu(TKYda8BDqs8FFjkN(V(TqNPhi4NyFR04BnX7BXIdM(3skhqMEGFlP8aa)wuuRiZby(4koeSJAJ8bdfiqWhm9AB51srTYwBlwTuuRmvYK4QTLxRiDqa4P4qWoQnIee20wfStyTuwlL1szTTy1srThKeRTfRwPCaz6bQg880SHgyI1s53ceNIaACW0)wTuiyhRT1Jee20U2gOuCwlxRuoGm9aRLjta)Qn71kadZRLg4Q9bFpg1cmXA5A7d(QfNhKKpy61AJbQQ9vBS2jKuuRrKsHGiyTbsYqFQrjnqXHG1IsAe4CctVwWeN165v7tgew7dog12ZOwJibHnTRfeaR9YApBSwAGyETR15diWAZETNnwRamuFlPCODMe)w48GK8HGA2qlYCaMp()(sS18F9BHotpqWpX(wPX3AI33Ifhm9VLuoGm9a)ws5ba(TKYbKPhOcNhKKpeuZgArMdW8X)wIaEya5VLiDqa4P4qWoQnIee20(BjLdTZK436GKOgWp4qZg)7lr58)1Vf6m9ab)e7BLgFRjEFlwCW0)ws5aY0d8BjLha43sK5amFCfhc2rTr(GHkqsg6ZVLiGhgq(B1QAfPdcapfhc2rTrKGWM2k0z6bc(TKYH2zs8BDqsud4hCOzJ)9Lyl8)63cDMEGGFI9TsJVfjl53Ifhm9VLuoGm9a)ws5q7mj(ToijQb8do0SX3seWddi)TOOwrMdW8XvxciS1zxF2OMKBGQajzOpRTfRwPCaz6bQoijQb8do0SrTuw7l1kpz(TaXPiGghm9VLCi(EmQfehC7ABPwVwaJAVSw5jZjkQTNrTVMxl7BjLha43sK5amFC1LacBD21NnQj5gOkqsg6Z)9LOSY8)63cDMEGGFI9TsJVfjl53Ifhm9VLuoGm9a)ws5q7mj(ToijQb8do0SX3seWddi)TePdcapfhc2rTrKGWM21AQwr6GaWtXHGDuBejiSPTkyNWAFPwcQwt1ITiaOHbcQMjWyG3b9gDaq3Uwt1ksPOZ(PiSDazVwt1gao2ZObvCiyh12CqMEBf6m9ab)wG4ueqJdM(3Yc6cSw5aa621cN1obe21Y1AKpy0bg1Eb0jeVA7zuRCC2oGSBETp47XO25bfew7L1E2yT3twlj0boSwrBXaRfWp4O2hS2g8QLR1g2yxl6jqJDTb7ewB2R1isqyt7VLuEaGFlrMdW8XvZeymW7GEJoaOBRcKKH(8FFjkRS)x)wOZ0de8tSVvA8TM49TyXbt)BjLditpWVLuEaGFlrMdW8XvxciS1zxF2OMKBGQazW21AQwPCaz6bQoijQb8do0SrTVuR8K53ceNIaACW0)wYH47XOwqCWTR918Az1cyu7L1kpzorrT9mQTLA9VLuo0otIFl7Cac9g9Lh5)(suw59F9BHotpqWpX(wPX3AI33Ifhm9VLuoGm9a)ws5ba(TOOwJaLQBeGkzvbdcz)0tdoiSwIiQwJaLQBeGk5PcgeY(PNgCqyTeruTgbkv3iaveNkyqi7NEAWbH1szTMQfePb6DvWGq2p90Gdc1sbgogmnCaV2kW8X)wG4ueqJdM(3soGbHSF1AzWbH1cM4SwpVAHKKiiKpC0UwdGRwaJApBSwPadhdMgoGx7AbrAGEV2zwl8QvWET0yTGWEhkagxTxwliCkWWR9S5R2h8DG1YxTNnwlbEmYZUwPadhdMgoGx7ANhli8BjLdTZK43QfhyEAGjcQNgCq4)(suwI7)63cDMEGGFI9TsJV1eVVfloy6FlPCaz6b(TKYda8Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LacBD21NnQj5gOcmF8AnvBRQvkhqMEGQwCG5PbMiOEAWbH1AQwqKgO3vbdcz)0tdoiulfy4yW0Wb8ARaZh)BjLdTZK43kbUjee1zxlYCaMp(8FFjkBl4)63cDMEGGFI9TsJV1eVVfloy6FlPCaz6b(TKYda8Bfao2ZObvCiyh12CqMEBf6m9abR1uTuulf1ksPOZ(PiSDazVwt1kYCaMpUkyqi7NEAWbHQajzOpR9LALYbKPhOYMdY0BRNhliuFqsSwkRLYVLuo0otIFR5Xcc12CqME7)9VVvh68qtde()1VeL9)63cDMEGGFI9TyXbt)BXHGDutcNt4aNFlHnd9VLSFlrapmG83IgO3vIbYHGNh0BubYI7FFjkV)RFlwCW0)wCiyh10dEEFl0z6bc(j2)(sK4(V(TyXbt)BXHGDutZrWn43cDMEGGFI9V)9VVLumMW0)suEYuEYkt5SSY7B9WHd9M53soSLKdKyRvIYXq81w7R2yTqsJmUA7zu7BBoitV97AdSfbadeS2zsI1YaxsYhcwRWM9gCQkZiyOJ1klXxlbKUumoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjPuvMrWqhRTfq81saPlfJdbR99fqNq8umTqjYCaMp(7AVS23ImhG5JRyAX7APqwjPuvMrWqhRLGi(AjG0LIXHG1((cOtiEkMwOezoaZh)DTxw7BrMdW8XvmT4DTuiRKuQkZiyOJ12Ai(AjG0LIXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkjLQYmcg6yTYklXxlbKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPhi47APqwjPuvMrWqhRvw5r81saPlfJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6bc(UwkKvskvLzem0XALL4i(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjLQYmcg6yTYsCeFTeq6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEGGVRLczLKsvzgbdDSwzBHeFTeq6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEGGVRLczLKsvzwzMCyljhiXwReLJH4RT2xTXAHKgzC12ZO23D40g6n60aDmExBGTiayGG1otsSwg4ss(qWAf2S3GtvzgbdDSwzj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuipjPuvMrWqhRvEeFTeq6sX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLKsvzgbdDSwIJ4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowBlG4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowlbr81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvor81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47A5RwcmcCeCTuiRKuQkZiyOJ12cj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ12cj(AjG0LIXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlF1sGrGJGRLczLKsvzgbdDSwzLhXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLc5jjLQYmcg6yTYsqeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALvot81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvEYK4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKuQkZiyOJ1kpIJ4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sH8KKsvzgbdDSw5rCeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(Uw(QLaJahbxlfYkjLQYmcg6yTYJGi(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DT8vlbgbocUwkKvskvLzem0XALNCI4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKuQkZkZKdBj5aj2ALOCmeFT1(QnwlK0iJR2Eg1(oYJpy6VRnWweamqWANjjwldCjjFiyTcB2BWPQmJGHowRSeFTeq6sX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLKsvzgbdDSwzj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kpIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTehXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSwcI4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKuQkZiyOJ1kNi(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjLQYmcg6yTYktIVwciDPyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssPQmJGHowRSTqIVwciDPyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssPQmJGHowRSTqIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYtMeFTeq6sX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLKsvzgbdDSw5jtIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYtwIVwciDPyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssPQmJGHowR8KL4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowR8KhXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSw5rCeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzLzYHTKCGeBTsuogIV2AF1gRfsAKXvBpJAFNgOJX7AdSfbadeS2zsI1YaxsYhcwRWM9gCQkZiyOJ1klXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSw5r81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvw5r81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvskvLzem0XALLGi(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DT8vlbgbocUwkKvskvLzem0XALvor81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47A5RwcmcCeCTuiRKuQkZiyOJ1kBRH4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKuQkZkZKdBj5aj2ALOCmeFT1(QnwlK0iJR2Eg1(ge7mW4ExBGTiayGG1otsSwg4ss(qWAf2S3GtvzgbdDSw5r81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKNKuQkZiyOJ12ci(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kBlG4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowRSYjIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYkNj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kp5r81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47A5RwcmcCeCTuiRKuQkZiyOJ1kpIJ4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowR8AbeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALhbr81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvEYjIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYR1q81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMvMjh2sYbsS1kr5yi(AR9vBSwiPrgxT9mQ9TrGIKKMV31gylcagiyTZKeRLbUKKpeSwHn7n4uvMrWqhRvor81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvor81saPlfJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6bc(UwkKvskvLzem0XALNmj(AjG0LIXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkjLQYmcg6yTYtwIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYtwIVwciDPyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSssPQmJGHowR8KhXxlbKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPhi47APqwjPuvMrWqhRvETqIVwciDPyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sH8KKsvzgbdDSw51cj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1sCYJ4RLasxkghcw77zcmOHoOsUVR9YAFptGbn0bvYvHotpqW31sHSssPQmJGHowlXjpIVwciDPyCiyTVNjWGg6Gk5(U2lR99mbg0qhujxf6m9abFxlF1sGrGJGRLczLKsvzgbdDSwIJ4i(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1sCehXxlbKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPhi47APqwjPuvMrWqhRL4AbeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(Uw(QLaJahbxlfYkjLQYmcg6yTehbr81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRL4KteFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzLzYHTKCGeBTsuogIV2AF1gRfsAKXvBpJAFlYCaMp(8DTb2IaGbcw7mjXAzGlj5dbRvyZEdovLzem0XALL4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuipjPuvMrWqhRvwIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTYJ4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuipjPuvMrWqhRvEeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XAjoIVwciDPyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sH8KKsvzgbdDSwIJ4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowBlG4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowlbr81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvor81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKNKuQkZiyOJ12Ai(AjG0LIXHG1(EMadAOdQK77AVS23ZeyqdDqLCvOZ0de8DTuipjPuvMrWqhRTfs81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKNKuQkZiyOJ1kRmj(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYtskvLzem0XALvEeFTeq6sX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLc5jjLQYmcg6yTYsCeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALTfq81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvskvLzem0XALLGi(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjLQYmcg6yTY2cj(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjLQYSYm5WwsoqITwjkhdXxBTVAJ1cjnY4QTNrTV5eFxBGTiayGG1otsSwg4ss(qWAf2S3GtvzgbdDSwzj(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYtskvLzem0XALL4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowR8i(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuipjPuvMrWqhRL4i(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYtskvLzem0XAjoIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTTaIVwciDPyCiyTVdah7z0Gk5(U2lR9Da4ypJgujxf6m9abFxlfYkjLQYmcg6yTeeXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSw5eXxlbKUumoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjPuvMrWqhRT1q81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvot81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRTfs81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKNKuQkZiyOJ1kRmj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kRSeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALvEeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALL4i(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYtskvLzem0XALvor81saPlfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKNKuQkZiyOJ1kBlK4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DT8vlbgbocUwkKvskvLzem0XALNmj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kpzj(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kp5r81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRvEehXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSw51ci(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuiRKuQkZiyOJ1kpcI4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31sHSssPQmJGHowR8KteFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALxRH4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKuQkZiyOJ1kVwdXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSw5jNj(AjG0LIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjLQYmcg6yTYtot81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqwjPuvMrWqhRL4KjXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzgbdDSwItEeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XAjUwaXxlbKUumoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjPuvMrWqhRL4AbeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XAjocI4RLasxkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuipjPuvMrWqhRL4KteFTeq6sX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLKsvzwzMCyljhiXwReLJH4RT2xTXAHKgzC12ZO23cEiag8btF(U2aBraWabRDMKyTmWLK8HG1kSzVbNQYmcg6yTYs81saPlfJdbR9Da4ypJguj331EzTVdah7z0Gk5QqNPhi47APqEssPQmJGHowR8i(AjG0LIXHG1(oaCSNrdQK77AVS23bGJ9mAqLCvOZ0de8DTuipjPuvMrWqhRL4i(AjG0LIXHG1AbjjGANT9JLSw54Q2lRLGb4AbHsHty61MgyWxg1sHmOSwkKvskvLzem0XABbeFTeq6sX4qWAFhao2ZObvY9DTxw77aWXEgnOsUk0z6bc(UwkKvskvLzem0XALZeFTeq6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEGGVRLVAjWiWrW1sHSssPQmJGHowRSYK4RLasxkghcw77lGoH4PyAHsK5amF831EzTVfzoaZhxX0I31sHSssPQmJGHowRSYK4RLasxkghcw77aWXEgnOsUVR9YAFhao2ZObvYvHotpqW31YxTeye4i4APqwjPuvMrWqhRv2waXxlbKUumoeS23bGJ9mAqLCFx7L1(oaCSNrdQKRcDMEGGVRLczLKsvzwzwRL0iJdbRvwzwlloy61oGZBQkZ(wgr2Hd8BrGiq12Y4gS2wkeSJLzeicuTTeqdW8Qv2wO51kpzkpzlZkZiqeOAjaB2BWjXxMrGiq12IvRC0eR9ABaf8OwlijbuRn7GdO3uB2RvyZUJJAH(HrayCW0Rf6ZdzWAZETVfSlWHMfhm93QYmcebQ2wSAjaB2BWA5qWoQHEh6WRDTxwlhc2rTnhKP3UwkGxTokfJAFq)QDaLI1YZA5qWoQT5Gm92uQkZiqeOABXQvo(0FF1sGjnf8H1c9ABjcCey12IdmVAPrbdmXABNaVdS2e4Qn71gS3G1YoyTEE1cmHEtTTuiyhRLatsJroHPRkZkZyXbtFQmcuKK08jbQYGdb7Og6hogO4kZyXbtFQmcuKK08jbQYGdb7OUZKWbKJYmwCW0NkJafjjnFsGQmeP3IdeOMKDw3GKLzS4GPpvgbkssA(KavziLditpqZDMePYjQpoAWtlsa)mpnOg4epZbXodmoQexzgloy6tLrGIKKMpjqvgs5aY0d0CNjrQO0uBioZtdQboXZCqSZaJJQSeuzgloy6tLrGIKKMpjqvgs5aY0d0CNjrQgbAamgAuAAEAqDIN5Wovkcah7z0GQj0WoD98YG0efIuk6SFkPOF2TdIisKsrN9t5OiYrgGerKiDqa4P4qWoQnIee20MsknxkpaqQYAUuEaGACmrQYSmJfhm9PYiqrssZNeOkdPCaz6bAUZKivBwkQtd0rqZtdQt8mh2PYIdkf1OJKqCkFQs5aY0duXjQpoAWtlsa)mxkpaqQYAUuEaGACmrQYSmJfhm9PYiqrssZNeOkdPCaz6bAUZKi1o05HMgiCZtdQt8mxkpaqQYSmJfhm9PYiqrssZNeOkdPCaz6bAUZKivBoitVTEESGq9bjrZtdQboXZCqSZaJJAlSmJfhm9PYiqrssZNeOkdPCaz6bAUZKivE8WTN6zBxOfzoaZhFAEAqnWjEMdIDgyCuLzzgloy6tLrGIKKMpjqvgs5aY0d0CNjrQXutYsQbXb3w3ZqF5rAEAqnWjEMdIDgyCujOYmwCW0NkJafjjnFsGQmKYbKPhO5otIuJPMKLudIdUTUNHosdZtdQboXZCqSZaJJkbvMXIdM(uzeOijP5tcuLHuoGm9an3zsKAm1KSKAqCWT19m0SH5Pb1aN4zoi2zGXrvEYSmJfhm9PYiqrssZNeOkdPCaz6bAUZKivY80gbkqeuF5rQPBBEAqnWjEMdIDgyCuLZLzS4GPpvgbkssA(KavziLditpqZDMePsMNMKLudIdUTUNH(YJ080GAGt8mhe7mW4OkRmlZyXbtFQmcuKK08jbQYqkhqMEGM7mjsLmpnjlPgehCBDpdnByEAqnWjEMdIDgyCuLLGkZyXbtFQmcuKK08jbQYqkhqMEGM7mjsLn0KSKAqCWT19m0xEKMNgudCIN5Wovr6GaWtXHGDuBejiSPT5s5basL4KP5s5baQXXePkRmlZyXbtFQmcuKK08jbQYqkhqMEGM7mjsLn0KSKAqCWT19m0xEKMNgudCIN5GyNbghv5jZYmwCW0NkJafjjnFsGQmKYbKPhO5otIuzdnjlPgehCBDpdnzEMNgudCIN5GyNbghv5jZYmwCW0NkJafjjnFsGQmKYbKPhO5otIuJ0qtYsQbXb3w3ZqF5rAEAqDIN5s5basvEYSfJccQLlsheaEkoeSJAJibHnTPSmJfhm9PYiqrssZNeOkdPCaz6bAUZKi1lpsnjlPgehCBDpdnByEAqDIN5s5basLGKG8KzlNcrkfD2pLdBSpDNrIiIcr6GaWtXHGDuBejiSPTjwCqPOgDKeIZxKYbKPhOItuFC0GNwKa(rjLsqwcQLtHiLIo7NIW2bKDtbGJ9mAqfhc2rTnhKP32eloOuuJoscXP8PkLditpqfNO(4ObpTib8JYYmwCW0NkJafjjnFsGQmKYbKPhO5otIuV8i1KSKAqCWT19m0rAyEAqDIN5s5basvEYSfJc5ClxKoia8uCiyh1grccBAtzzgloy6tLrGIKKMpjqvgs5aY0d0CNjrQ0CeCdQjzN1gIZ80G6epZHDQIuk6SFkh2yF6oJMlLhaiv5KmBXOGKNhgT1s5ba2YLvMYKYYmwCW0NkJafjjnFsGQmKYbKPhO5otIuP5i4gutYoRneN5Pb1jEMd7ufPu0z)ue2oGSBUuEaGuBHeulgfK88WOTwkpaWwUSYuMuwMXIdM(uzeOijP5tcuLHuoGm9an3zsKknhb3GAs2zTH4mpnOoXZCyNQuoGm9av0CeCdQjzN1gIJQmnxkpaqQYzz2IrbjppmARLYdaSLlRmLjLLzS4GPpvgbkssA(KavziLditpqZDMePYgAsOdjbi1KSZAdXzEAqnWjEMdIDgyCuLLGkZyXbtFQmcuKK08jbQYqkhqMEGM7mjs9YJutYsQf2C0GtZtdQboXZCqSZaJJQ8kZyXbtFQmcuKK08jbQYqkhqMEGM7mjsLtuF5rQjzj1cBoAWP5Pb1aN4zoi2zGXrvELzS4GPpvgbkssA(KavziLditpqZDMeP2HtBO3Otd0XW80G6epZLYdaKQSTCkWwea0WabviPr7a5HodqNDbseruC8a9tfaoQZU2iFWWefhpq)uCiyh1OWojIOwjsPOZ(PiSDazNstu0krkfD2pLJIihzaserS4Gsrn6ijeNuLLiIcah7z0GQj0WoD98YGKstTsKsrN9tjf9ZUDqjLLzS4GPpvgbkssA(KavziLditpqZDMePYg601at080G6epZLYdaKk2IaGggiOIKfmDG6PnINMeycfere2IaGggiOQzWGq(YyQPzWgKiIWwea0WabvndgeYxgtnjcYJbmDIicBraqddeubYbHKz6AquqO2a4cCkqxGere2IaGggiOc6traCm9a1Tia2pasnikfkqIicBraqddeuntGXaVd6n6aGUnreHTiaOHbcQMao9itqntIND75rerylcaAyGGQhMq0XyQ7r6Gere2IaGggiOQpysuNDnnF3alZyXbtFQmcuKK08jbQYGegrgAij3GLzS4GPpvgbkssA(Kavz0h40weC)mh2PotGbn0bvsZbFWbQN5qk6hrentGbn0bvgaZdyGAmamoy6LzS4GPpvgbkssA(KavzeaoQZU2iFWWCyNQiLIo7NIW2bKDtbGJ9mAqfhc2rTnhKP32KiDqa4P4qWoQnIee202KuoGm9av84HBp1Z2UqlYCaMp(0eloOuuJoscX5ls5aY0duXjQpoAWtlsa)kZyXbtFQmcuKK08jbQYOh58OZXzoStTvs5aY0duzeObWyOrPjvznfao2ZObvGWPaAmGohT1IKKKDWYmwCW0NkJafjjnFsGQm4qWoQPh88mh2P2kPCaz6bQmc0aym0O0KQSMAva4ypJgubcNcOXa6C0wlsss2bnrrRePu0z)usr)SBherKuoGm9avD40g6n60aDmOSmJfhm9PYiqrssZNeOkdsyezm1zxFzqI(zoStTvs5aY0duzeObWyOrPjvzn1QaWXEgnOceofqJb05OTwKKKSdAsKsrN9tjf9ZUDyQvs5aY0du1HtBO3Otd0XOmJfhm9PYiqrssZNeOkduAk4dMU5WovPCaz6bQmc0aym0O0KQSLzLzS4GPpLavzisa)WyAGJrzgloy6tjqvgatutYoRBqsZHDQuC8a9tH(a2yFOJGMizNvgI7fQYzzAIKDwzio5tvorquseru0QJhOFk0hWg7dDe0ej7SYqCVqvotquwMXIdM(ucuLHrEW0nh2Psd07koeSJAJ8bdfGrzgloy6tjqvghKe1pCyyoStnaCSNrdQoK0idEOF4WWenqVRqjTzG5btxbyyIcrMdW8XvCiyh1g5dgQazW2ereDoNM6Wg7thijd95luBbYKYYmwCW0NsGQmgWg7BQBXbaBir)mh2Psd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MarAGExDjGWwND9zJAsUbQaZhVmJfhm9PeOkdAUrND9fqbHtZHDQ0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciS1zxF2OMKBGkW8XlZyXbtFkbQYGgJjgec9gZHDQ0a9UIdb7O2iFWqbyuMXIdM(ucuLb9itqDhiABoStLgO3vCiyh1g5dgkaJYmwCW0NsGQm6WaPhzcAoStLgO3vCiyh1g5dgkaJYmwCW0NsGQmyxGZl4HwWJH5WovAGExXHGDuBKpyOamkZyXbtFkbQYayIA4HKtZHDQ0a9UIdb7O2iFWqbyuMXIdM(ucuLbWe1Wdjnh7DuCANjrQndgeYxgtnnd2GMd7uPb6Dfhc2rTr(GHcWGiIezoaZhxXHGDuBKpyOcKKH(u(ujicYeisd07Qlbe26SRpButYnqfGrzgloy6tjqvgatudpK0CNjrQiPr7a5HodqNDbAoStvK5amFCfhc2rTr(GHkqsg6ZxOklbzsK5amFC1LacBD21NnQj5gOkqsg6ZxOklbvMXIdM(ucuLbWe1Wdjn3zsKkyGmyhgOwkoN4WCyNQiZby(4koeSJAJ8bdvGKm0NYNQ8Kjre1kPCaz6bQydD6AGjsvwIiIIdsIuLPjPCaz6bQ6WPn0B0Pb6yqvwtbGJ9mAq1eAyNUEEzqszzgloy6tjqvgatudpK0CNjrQZeyOHno8WWCyNQiZby(4koeSJAJ8bdvGKm0NYNkXjtIiQvs5aY0duXg601atKQSLzS4GPpLavzamrn8qsZDMeP2mAByRZUMNtijCWhmDZHDQImhG5JR4qWoQnYhmubsYqFkFQYtMeruRKYbKPhOIn0PRbMivzjIikoijsvMMKYbKPhOQdN2qVrNgOJbvznfao2ZObvtOHD665LbjLLzS4GPpLavzamrn8qsZDMePsYcMoq90gXttcmHcZHDQImhG5JR4qWoQnYhmubsYqF(cvcYefTskhqMEGQoCAd9gDAGoguLLiIoijkFItMuwMXIdM(ucuLbWe1Wdjn3zsKkjly6a1tBepnjWekmh2PkYCaMpUIdb7O2iFWqfijd95lujits5aY0du1HtBO3Otd0XGQSMOb6Dva4Oo7AJ8bdfGHjAGExfaoQZU2iFWqfijd95luPqwz2IrqT8aWXEgnOAcnStxpVmiP00bjXxiozwMXIdM(ucuLbWe1Wdjn3zsK60MbZheuNbTo76lds0pZHDQhKePktIiIcPCaz6bQsGBcbrD21ImhG5JpnrbfIuk6SFkcBhq2njYCaMpUkyqi7NEAWbHQajzOpFHQ8mjYCaMpUIdb7O2iFWqfijd95lujitImhG5JRUeqyRZU(Srnj3avbsYqF(cvcIsIisK5amFCfhc2rTr(GHkqsg6ZxOkpIiQdBSpDGKm0NViYCaMpUIdb7O2iFWqfijd9jLuwMrGiq1YIdM(ucuLHJp9eWb1boZHu0CGjQFSHdul45b9gQYAoStLgO3vCiyh1g5dgkadIicePb6D1LacBD21NnQj5gOcWGiIaZtfmiK9tpn4Gq1bfec9MYmwCW0NsGQme8yOzXbtxpGZZCNjrQcEiag8btFwMXIdM(ucuLHGhdnloy66bCEM7mjsLt085fqXrvwZHDQS4Gsrn6ijeNYNQuoGm9avCI6JJg80IeWVYmwCW0NsGQme8yOzXbtxpGZZCNjrQ2CqMEBZHDQIuk6SFkcBhq2nfao2ZObvCiyh12CqME7YmwCW0NsGQme8yOzXbtxpGZZCNjrQD40g6n60aDmmh2PkLditpqLnlf1Pb6iivzAskhqMEGQoCAd9gDAGogMAffIuk6SFkcBhq2nfao2ZObvCiyh12CqMEBklZyXbtFkbQYqWJHMfhmD9aopZDMePMgOJH5WovPCaz6bQSzPOonqhbPkttTIcrkfD2pfHTdi7Mcah7z0GkoeSJABoitVnLLzS4GPpLavzi4XqZIdMUEaNN5otIufzoaZhFAoStTvuisPOZ(PiSDaz3ua4ypJguXHGDuBZbz6TPSmJfhm9PeOkdbpgAwCW01d48m3zsKAKhFW0nh2PkLditpqvh68qtdeovzAQvuisPOZ(PiSDaz3ua4ypJguXHGDuBZbz6TPSmJfhm9PeOkdbpgAwCW01d48m3zsKAh68qtdeU5WovPCaz6bQ6qNhAAGWPkRPwrHiLIo7NIW2bKDtbGJ9mAqfhc2rTnhKP3MYYSYmwCW0NkorQ9iNhDooZHDQbGJ9mAqfiCkGgdOZrBTijjzh0KiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTnrd07kq4uangqNJ2ArssYoOUh58uG5JBIcAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlbe26SRpButYnqfy(4uAsK5amFC1LacBD21NnQj5gOkqsg6tQY0ef0a9UIdb7OwyZrdQMhli8fQs5aY0duXjQV8i1KSKAHnhn40efuC8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFHAJa0KiZby(4koeSJAJ8bdvGKm0NYxkhqMEGQlpsnjlPgehCBDpdnBqjrerrRoEG(Pcah1zxBKpyysK5amFCfhc2rTr(GHkqsg6t5lLditpq1LhPMKLudIdUTUNHMnOKiIezoaZhxXHGDuBKpyOcKKH(8fQncqkPSmJfhm9PItucuLrhgOMEWZZCyNkfbGJ9mAqfiCkGgdOZrBTijjzh0KiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTnrd07kq4uangqNJ2ArssYoOUddubMpUjJaLQBeGkzv9iNhDookjIikcah7z0Gkq4uangqNJ2ArssYoOPdsIuLjLLzS4GPpvCIsGQm6ropTNszZHDQbGJ9mAqvtaNJ2AOakgOjrMdW8XvCiyh1g5dgQajzOpLpXjttImhG5JRUeqyRZU(Srnj3avbsYqFsvMMOGgO3vCiyh1cBoAq18ybHVqvkhqMEGkor9LhPMKLulS5ObNMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95luBeGMezoaZhxXHGDuBKpyOcKKH(u(s5aY0duD5rQjzj1G4GBR7zOzdkjIikA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFPCaz6bQU8i1KSKAqCWT19m0SbLerKiZby(4koeSJAJ8bdvGKm0NVqTrasjLLzS4GPpvCIsGQm6ropTNszZHDQbGJ9mAqvtaNJ2AOakgOjrMdW8XvCiyh1g5dgQajzOpPkttuqbfImhG5JRUeqyRZU(Srnj3avbsYqFkFPCaz6bQydnjlPgehCBDpd9LhPjAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqkjIikezoaZhxDjGWwND9zJAsUbQcKKH(KQmnrd07koeSJAHnhnOAESGWxOkLditpqfNO(YJutYsQf2C0GtkP0enqVRcah1zxBKpyOaZhNYYmwCW0NkorjqvgCiyh1KW5eoWP5WovrkfD2pfHTdi7Mcah7z0GkoeSJABoitVTjAGExXHGDuBZbz6TvZJfe(ISeKjrMdW8Xvbdcz)0tdoiufijd95luLYbKPhOYMdY0BRNhliuFqsucOKOa4q9bjrtImhG5JRUeqyRZU(Srnj3avbsYqF(cvPCaz6bQS5Gm9265Xcc1hKeLakjkaouFqsucS4GPRcgeY(PNgCqOcLefahQpijAsK5amFCfhc2rTr(GHkqsg6ZxOkLditpqLnhKP3wppwqO(GKOeqjrbWH6dsIsGfhmDvWGq2p90GdcvOKOa4q9bjrjWIdMU6saHTo76Zg1KCduHsIcGd1hKenxyZqNQSLzS4GPpvCIsGQm4qWoQPh88mh2PksPOZ(PKI(z3omD8a9tXHGDuJc700bjXxKvMMezoaZhxrcJiJPo76lds0pvGKm0NMOb6DLyGCi45b9g18ybHVqCLzS4GPpvCIsGQmUeqyRZU(Srnj3anh2Pgao2ZObvtOHD665LbPjJaLQBeGkzvO0uWhm9YmwCW0NkorjqvgCiyh1g5dgMd7udah7z0GQj0WoD98YG0efgbkv3iavYQqPPGpy6erKrGs1ncqLSQlbe26SRpButYnqklZyXbtFQ4eLavzqcJiJPo76lds0pZHDQImhG5JR4qWoQnYhmubsYqF(cv5SjrMdW8XvxciS1zxF2OMKBGQajzOpFHQC2ef0a9UIdb7OwyZrdQMhli8fQs5aY0duXjQV8i1KSKAHnhn40efuC8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFHAJa0KiZby(4koeSJAJ8bdvGKm0NYNGOKiIOOvhpq)ubGJ6SRnYhmmjYCaMpUIdb7O2iFWqfijd9P8jikjIirMdW8XvCiyh1g5dgQajzOpFHAJaKsklZyXbtFQ4eLavzGstbFW0nh2PEqsu(eNmnfao2ZObvtOHD665LbPjrkfD2pLu0p72HjJaLQBeGkzvKWiYyQZU(YGe9RmJfhm9PItucuLbknf8bt3CyN6bjr5tCY0ua4ypJgunHg2PRNxgKMOb6Dfhc2rTWMJgunpwq4luLYbKPhOItuF5rQjzj1cBoAWPjrMdW8XvxciS1zxF2OMKBGQajzOpPkttImhG5JR4qWoQnYhmubsYqF(c1gbyzgloy6tfNOeOkduAk4dMU5Wo1dsIYN4KPPaWXEgnOAcnStxpVminjYCaMpUIdb7O2iFWqfijd9jvzAIckOqK5amFC1LacBD21NnQj5gOkqsg6t5lLditpqfBOjzj1G4GBR7zOV8inrd07koeSJAHnhnOAESGqQ0a9UIdb7OwyZrdQizj1ZJfesjrerHiZby(4Qlbe26SRpButYnqvGKm0NuLPjAGExXHGDulS5ObvZJfe(cvPCaz6bQ4e1xEKAswsTWMJgCsjLMOb6Dva4Oo7AJ8bdfy(4uAo0pmcaJtd7uPb6D1eAyNUEEzqQMhliKknqVRMqd701ZldsfjlPEESGqZH(HrayCAijjcc5dPkBzgloy6tfNOeOkJGbHSF6PbheAoStvK5amFC1LacBD21NnQj5gOkqsg6ZxqjrbWH6dsIMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95luBeGMezoaZhxXHGDuBKpyOcKKH(u(s5aY0duD5rQjzj1G4GBR7zOzdkjIikA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFPCaz6bQU8i1KSKAqCWT19m0SbLerKiZby(4koeSJAJ8bdvGKm0NVqTraszzgloy6tfNOeOkJGbHSF6PbheAoStvK5amFCfhc2rTr(GHkqsg6ZxqjrbWH6dsIMOGckezoaZhxDjGWwND9zJAsUbQcKKH(u(s5aY0duXgAswsnio426Eg6lpst0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHuseruiYCaMpU6saHTo76Zg1KCdufijd9jvzAIgO3vCiyh1cBoAq18ybHVqvkhqMEGkor9LhPMKLulS5ObNusPjAGExfaoQZU2iFWqbMpoLLzS4GPpvCIsGQmar(SPZWrZHDQImhG5JR4qWoQnYhmubsYqFsvMMOGckezoaZhxDjGWwND9zJAsUbQcKKH(u(s5aY0duXgAswsnio426Eg6lpst0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHuseruiYCaMpU6saHTo76Zg1KCdufijd9jvzAIgO3vCiyh1cBoAq18ybHVqvkhqMEGkor9LhPMKLulS5ObNusPjAGExfaoQZU2iFWqbMpoLLzS4GPpvCIsGQmUeqyRZU(Srnj3anh2PsbnqVR4qWoQf2C0GQ5XccFHQuoGm9avCI6lpsnjlPwyZrdojIiJaLQBeGkzvbdcz)0tdoiKstuqXXd0pva4Oo7AJ8bdtImhG5JRcah1zxBKpyOcKKH(8fQncqtImhG5JR4qWoQnYhmubsYqFkFPCaz6bQU8i1KSKAqCWT19m0SbLerefT64b6NkaCuNDTr(GHjrMdW8XvCiyh1g5dgQajzOpLVuoGm9avxEKAswsnio426EgA2GsIisK5amFCfhc2rTr(GHkqsg6ZxO2iaPSmJfhm9PItucuLbhc2rTr(GH5WovkOqK5amFC1LacBD21NnQj5gOkqsg6t5lLditpqfBOjzj1G4GBR7zOV8inrd07koeSJAHnhnOAESGqQ0a9UIdb7OwyZrdQizj1ZJfesjrerHiZby(4Qlbe26SRpButYnqvGKm0NuLPjAGExXHGDulS5ObvZJfe(cvPCaz6bQ4e1xEKAswsTWMJgCsjLMOb6Dva4Oo7AJ8bdfy(4LzS4GPpvCIsGQmcah1zxBKpyyoStLgO3vbGJ6SRnYhmuG5JBIckezoaZhxDjGWwND9zJAsUbQcKKH(u(YtMMOb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65XccPKiIOqK5amFC1LacBD21NnQj5gOkqsg6tQY0enqVR4qWoQf2C0GQ5XccFHQuoGm9avCI6lpsnjlPwyZrdoPKstuiYCaMpUIdb7O2iFWqfijd9P8LvEereisd07Qlbe26SRpButYnqfGbLLzS4GPpvCIsGQmM2W(b9gTr(GH5WovrMdW8XvCiyh1zqRcKKH(u(eere1QJhOFkoeSJ6mOlZyXbtFQ4eLavzWHGDutp45zoStvKsrN9try7aYUPaWXEgnOIdb7O2MdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqOwkWWXGPHd41wnpwqi1wGjJaLQBeGkzvCiyh1zqBIfhukQrhjH48Lwtzgloy6tfNOeOkdoeSJAAocUbnh2PksPOZ(PiSDaz3ua4ypJguXHGDuBZbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliKAlOmJfhm9PItucuLbhc2rn9GNN5WovrkfD2pfHTdi7Mcah7z0GkoeSJABoitVTjAGExXHGDuBKpyOammrbyEQGbHSF6PbheQcKKH(u(YjIicePb6DvWGq2p90Gdc1sbgogmnCaV2kadknbI0a9Ukyqi7NEAWbHAPadhdMgoGxB18ybHV0cmXIdkf1OJKqCsL4kZyXbtFQ4eLavzWHGDuNbT5WovrkfD2pfHTdi7Mcah7z0GkoeSJABoitVTjAGExXHGDuBKpyOammbI0a9Ukyqi7NEAWbHAPadhdMgoGxB18ybHujUYmwCW0NkorjqvgCiyh10CeCdAoStvKsrN9try7aYUPaWXEgnOIdb7O2MdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqOwkWWXGPHd41wnpwqiv5vMXIdM(uXjkbQYGdb7OgL0yKty6Md7ufPu0z)ue2oGSBkaCSNrdQ4qWoQT5Gm92MOb6Dfhc2rTr(GHcWWKrGs1ncqL8ubdcz)0tdoi0eloOuuJoscXP8jUYmwCW0NkorjqvgCiyh1OKgJCct3CyNQiLIo7NIW2bKDtbGJ9mAqfhc2rTnhKP32enqVR4qWoQnYhmuagMarAGExfmiK9tpn4GqTuGHJbtdhWRTAESGqQYAIfhukQrhjH4u(exzgloy6tfNOeOkdJaNOlqD21Kqh0CyNknqVRar(SPZWrfGHjqKgO3vxciS1zxF2OMKBGkadtGinqVRUeqyRZU(Srnj3avbsYqF(cvAGExze4eDbQZUMe6Gksws98ybHTCwCW0vCiyh10dEEkusuaCO(GKOjkO44b6NkWz6SlqtS4Gsrn6ijeNV0cOKiIyXbLIA0rsioFHGO0efTkaCSNrdQ4qWoQPtsAoajr)iIOJJg8u2ipoBLH4KpXrquwMXIdM(uXjkbQYGdb7OMEWZZCyNknqVRar(SPZWrfGHjkO44b6NkWz6SlqtS4Gsrn6ijeNV0cOKiIyXbLIA0rsioFHGO0efTkaCSNrdQ4qWoQPtsAoajr)iIOJJg8u2ipoBLH4KpXrquwMXIdM(uXjkbQYycyGHNs5YmwCW0NkorjqvgCiyh10CeCdAoStLgO3vCiyh1cBoAq18ybHYNkfS4Gsrn6ijeNTyYsPPaWXEgnOIdb7OMojP5aKe9Z0XrdEkBKhNTYqCVqCeuzgloy6tfNOeOkdoeSJAAocUbnh2Psd07koeSJAHnhnOAESGqQ0a9UIdb7OwyZrdQizj1ZJfewMXIdM(uXjkbQYGdb7OodAZHDQ0a9UIdb7OwyZrdQMhliKQmnrHiZby(4koeSJAJ8bdvGKm0NYxwcIiIAffIuk6SFkcBhq2nfao2ZObvCiyh12CqMEBkPSmJfhm9PItucuLHJNng6djnW5zoStLIa7boTz6bserT6GccHEdLMOb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65XcclZyXbtFQ4eLavzWHGDutcNt4aNMd7uPb6DLyGCi45b9gvGS4mfao2ZObvCiyh12CqMEBtuqXXd0pftAmGDOGpy6MyXbLIA0rsioFrotjreXIdkf1OJKqC(cbrzzgloy6tfNOeOkdoeSJAs4Cch40CyNknqVRedKdbppO3OcKfNPJhOFkoeSJAuyNMarAGExDjGWwND9zJAsUbQammrXXd0pftAmGDOGpy6ereloOuuJoscX5lTqklZyXbtFQ4eLavzWHGDutcNt4aNMd7uPb6DLyGCi45b9gvGS4mD8a9tXKgdyhk4dMUjwCqPOgDKeIZxAbLzS4GPpvCIsGQm4qWoQrjng5eMU5WovAGExXHGDulS5ObvZJfe(cnqVR4qWoQf2C0Gksws98ybHLzS4GPpvCIsGQm4qWoQrjng5eMU5WovAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqtgbkv3iavYQ4qWoQP5i4gSmJarGQLfhm9PItucuLbknf8bt3COFyeagNg2PsYoRmeN8PkNjiZH(HrayCAijjcc5dPkBzwzgloy6tLGhcGbFW0NuLYbKPhO5otIuTzPOonqhbnpnOoXZCP8aaPkR5WovPCaz6bQSzPOonqhbPkttgbkv3iavYQqPPGpy6MAffbGJ9mAq1eAyNUEEzqserbGJ9mAq1HKgzWd9dhguwMXIdM(uj4HayWhm9PeOkdPCaz6bAUZKivBwkQtd0rqZtdQt8mxkpaqQYAoStvkhqMEGkBwkQtd0rqQY0enqVR4qWoQnYhmuG5JBsK5amFCfhc2rTr(GHkqsg6ttueao2ZObvtOHD665Lbjrefao2ZObvhsAKbp0pCyqzzgloy6tLGhcGbFW0NsGQmKYbKPhO5otIu7qNhAAGWnpnOoXZCP8aaPkR5WovAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqtTIgO3vbWa1zxF2bItfGHPoSX(0bsYqF(cvkOGKDwoUyXbtxXHGDutp45Pe58OSLZIdMUIdb7OMEWZtHsIcGd1hKePSmJavlbg8SXOwU2oWy0U25XccrWAT5Gm921MrTqVwusuaCyTb7nyTpWZUwILK0CasI(vMXIdM(uj4HayWhm9PeOkdPCaz6bAUZKivK0iFWab10CeCdAEAqDIN5s5basLgO3vCiyh12CqMEB18ybHYNQSeererra4ypJguXHGDutNK0CasI(z64ObpLnYJZwziUxiocIYYmwCW0Nkbpead(GPpLavziLditpqZDMePo45PzdnWenhe7mW4OktZtdQt8mh2Psd07koeSJAJ8bdfGHjkKYbKPhOAWZtZgAGjsvMer0bjr5tvkhqMEGQbppnBObMOeKLGO0CP8aaPEqsSmJavBlfc2XAB9ibHnTRTbkfN1Y1kLditpWAzYeWVAZETcWW8APbUAFW3JrTatSwU2(GVAX5bj5dMET2yGQAF1gRDcjf1AePuiicwBGKm0NAusduCiyTOKgboNW0RfmXzTEE1(KbH1(GJrT9mQ1isqyt7AbbWAVS2ZgRLgiMx7AD(acS2Sx7zJ1kadvzgloy6tLGhcGbFW0NsGQmKYbKPhO5otIuX5bj5db1SHwK5amFCZtdQt8mxkpaqQuiYCaMpUIdb7O2iFWqbce8btVLtHSTyuitLmjUwUiDqa4P4qWoQnIee20wfStiLuszlgfhKeBXKYbKPhOAWZtZgAGjszzgloy6tLGhcGbFW0NsGQmKYbKPhO5otIupijQb8do0SH5Pb1jEMd7ufPdcapfhc2rTrKGWM2MlLhaivPCaz6bQW5bj5db1SHwK5amF8YmwCW0Nkbpead(GPpLavziLditpqZDMePEqsud4hCOzdZtdQt8mh2P2kr6GaWtXHGDuBejiSPT5s5basvK5amFCfhc2rTr(GHkqsg6ZYmcuTYH47XOwqCWTRTLA9AbmQ9YALNmNOO2Eg1(AETSYmwCW0Nkbpead(GPpLavziLditpqZDMePEqsud4hCOzdZtdQKSKMlLhaivrMdW8XvxciS1zxF2OMKBGQajzOpnh2PsHiZby(4Qlbe26SRpButYnqvGKm0NTys5aY0duDqsud4hCOzdkFrEYSmJavRf0fyTYba0TRfoRDciSRLR1iFWOdmQ9cOtiE12ZOw54SDaz38AFW3JrTZdkiS2lR9SXAVNSwsOdCyTI2IbwlGFWrTpyTn4vlxRnSXUw0tGg7Ad2jS2SxRrKGWM2LzS4GPpvcEiag8btFkbQYqkhqMEGM7mjs9GKOgWp4qZgMNgujzjnxkpaqQxaDcXtntGXaVd6n6aGUTsK5amFCvGKm0NMd7ufPdcapfhc2rTrKGWM2MePdcapfhc2rTrKGWM2QGDcFHGmHTiaOHbcQMjWyG3b9gDaq32KiLIo7NIW2bKDtbGJ9mAqfhc2rTnhKP3UmJavRCi(EmQfehC7AFnVwwTag1EzTYtMtuuBpJABPwVmJfhm9PsWdbWGpy6tjqvgs5aY0d0CNjrQ25ae6n6lpsZtdQt8mxkpaqQImhG5JRUeqyRZU(Srnj3avbYGTnjLditpq1bjrnGFWHMnErEYSmJavRCadcz)Q1YGdcRfmXzTEE1cjjrqiF4ODTgaxTag1E2yTsbgogmnCaV21cI0a9ETZSw4vRG9APXAbH9ouamUAVSwq4uGHx7zZxTp47aRLVApBSwc8yKNDTsbgogmnCaV21opwqyzgloy6tLGhcGbFW0NsGQmKYbKPhO5otIuBXbMNgyIG6PbheAEAqDIN5s5basLcJaLQBeGkzvbdcz)0tdoiKiImcuQUraQKNkyqi7NEAWbHerKrGs1ncqfXPcgeY(PNgCqiLMarAGExfmiK9tpn4GqTuGHJbtdhWRTcmF8YmwCW0Nkbpead(GPpLavziLditpqZDMePMa3ecI6SRfzoaZhFAEAqDIN5s5basLgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnbI0a9U6saHTo76Zg1KCdubMpUPwjLditpqvloW80ateupn4GqtGinqVRcgeY(PNgCqOwkWWXGPHd41wbMpEzgloy6tLGhcGbFW0NsGQmKYbKPhO5otIuNhliuBZbz6TnpnOoXZCP8aaPgao2ZObvCiyh12CqMEBtuqHiLIo7NIW2bKDtImhG5JRcgeY(PNgCqOkqsg6ZxKYbKPhOYMdY0BRNhliuFqsKsklZkZiq126bmd4bjWJ1cmHEtTnbCoAxluafdS2h4zxlBOQvoAI1cVAFGNDTxEK1MNngpWjQkZyXbtFQezoaZhFsTh580EkLnh2Pgao2ZObvnbCoARHcOyGMezoaZhxXHGDuBKpyOcKKH(u(eNmnjYCaMpU6saHTo76Zg1KCdufid22ef0a9UIdb7OwyZrdQMhli8fQs5aY0duD5rQjzj1cBoAWPjkO44b6NkaCuNDTr(GHjrMdW8XvbGJ6SRnYhmubsYqF(c1gbOjrMdW8XvCiyh1g5dgQajzOpLVuoGm9avxEKAswsnio426EgA2GsIiIIwD8a9tfaoQZU2iFWWKiZby(4koeSJAJ8bdvGKm0NYxkhqMEGQlpsnjlPgehCBDpdnBqjrejYCaMpUIdb7O2iFWqfijd95luBeGuszzgloy6tLiZby(4tjqvg9iNN2tPS5Wo1aWXEgnOQjGZrBnuafd0KiZby(4koeSJAJ8bdvGmyBtu0QJhOFk0hWg7dDeKiIO44b6Nc9bSX(qhbnrYoRmeN8P2AKjLuAIckezoaZhxDjGWwND9zJAsUbQcKKH(u(Yktt0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHuseruiYCaMpU6saHTo76Zg1KCdufijd9jvzAIgO3vCiyh1cBoAq18ybHuLjLuAIgO3vbGJ6SRnYhmuG5JBIKDwzio5tvkhqMEGk2qtcDijaPMKDwBiUYmwCW0NkrMdW8XNsGQm6rop6CCMd7udah7z0Gkq4uangqNJ2ArssYoOjrMdW8Xv0a9UgeofqJb05OTwKKKSdQcKbBBIgO3vGWPaAmGohT1IKKKDqDpY5PaZh3ef0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciS1zxF2OMKBGkW8XP0KiZby(4Qlbe26SRpButYnqvGKm0NuLPjkOb6Dfhc2rTWMJgunpwq4luLYbKPhO6YJutYsQf2C0GttuqXXd0pva4Oo7AJ8bdtImhG5JRcah1zxBKpyOcKKH(8fQncqtImhG5JR4qWoQnYhmubsYqFkFPCaz6bQU8i1KSKAqCWT19m0SbLerefT64b6NkaCuNDTr(GHjrMdW8XvCiyh1g5dgQajzOpLVuoGm9avxEKAswsnio426EgA2GsIisK5amFCfhc2rTr(GHkqsg6ZxO2iaPKYYmwCW0NkrMdW8XNsGQm6Wa10dEEMd7udah7z0Gkq4uangqNJ2ArssYoOjrMdW8Xv0a9UgeofqJb05OTwKKKSdQcKbBBIgO3vGWPaAmGohT1IKKKDqDhgOcmFCtgbkv3iavYQ6rop6CCLzeOABDgg12YYxR9bE212sTETWETW79Swrsc9MAbmQDMPRQT12RfE1(ahJAPXAbMiyTpWZU2xZRLzETcEE1cVANdyJ9nAxln2ZalZyXbtFQezoaZhFkbQYGegrgtD21xgKOFMd7uPOvbGJ9mAq1eAyNUEEzqser0a9UAcnStxpVmivaguAsK5amFC1LacBD21NnQj5gOkqsg6ZxKYbKPhOImpTrGceb1xEKA62erefs5aY0duDqsud4hCOzd5lLditpqfzEAswsnio426EgA2WKiZby(4Qlbe26SRpButYnqvGKm0NYxkhqMEGkY80KSKAqCWT19m0xEKuwMXIdM(ujYCaMp(ucuLbjmImM6SRVmir)mh2PkYCaMpUIdb7O2iFWqfid22efT64b6Nc9bSX(qhbjIikoEG(PqFaBSp0rqtKSZkdXjFQTgzsjLMOGcrMdW8XvxciS1zxF2OMKBGQajzOpLVuoGm9avSHMKLudIdUTUNH(YJ0enqVR4qWoQf2C0GQ5XccPsd07koeSJAHnhnOIKLuppwqiLerefImhG5JRUeqyRZU(Srnj3avbsYqFsvMMOb6Dfhc2rTWMJgunpwqivzsjLMOb6Dva4Oo7AJ8bdfy(4MizNvgIt(uLYbKPhOIn0KqhscqQjzN1gIRmJfhm9PsK5amF8PeOkJ(aN2IG7N5WovPCaz6bQsGBcbrD21ImhG5JpnrXmbg0qhujnh8bhOEMdPOFer0mbg0qhuzampGbQXaW4GPtzzgbQ2wA8WTN1cmXAbr(SPZWXAFGNDTSHQ2wBV2lpYAHZAdKbBxlpR9bhdZRLKjeRDceyTxwRGNxTWRwASNbw7LhPQmJfhm9PsK5amF8PeOkdqKpB6mC0CyNQiZby(4Qlbe26SRpButYnqvGmyBt0a9UIdb7OwyZrdQMhli8fQs5aY0duD5rQjzj1cBoAWPjrMdW8XvCiyh1g5dgQajzOpFHAJaSmJfhm9PsK5amF8PeOkdqKpB6mC0CyNQiZby(4koeSJAJ8bdvGmyBtu0QJhOFk0hWg7dDeKiIO44b6Nc9bSX(qhbnrYoRmeN8P2AKjLuAIckezoaZhxDjGWwND9zJAsUbQcKKH(u(Yktt0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHuseruiYCaMpU6saHTo76Zg1KCdufid22enqVR4qWoQf2C0GQ5XccPktkP0enqVRcah1zxBKpyOaZh3ej7SYqCYNQuoGm9avSHMe6qsasnj7S2qCLzeOALJMyTtdoiSwyV2lpYAzhSw2OwoWAtVwbyTSdw7t6VVAPXAbmQTNrTJ0BWO2ZM9ApBSwswYAbXb328AjzcHEtTtGaR9bR1MLI1YxTdKNxT3twlhc2XAf2C0GZAzhS2ZMVAV8iR9HN(7R2wCG5vlWebvLzS4GPpvImhG5JpLavzemiK9tpn4GqZHDQImhG5JRUeqyRZU(Srnj3avbsYqFkFPCaz6bQIPMKLudIdUTUNH(YJ0KiZby(4koeSJAJ8bdvGKm0NYxkhqMEGQyQjzj1G4GBR7zOzdtuC8a9tfaoQZU2iFWWefImhG5JRcah1zxBKpyOcKKH(8fusuaCO(GKirejYCaMpUkaCuNDTr(GHkqsg6t5lLditpqvm1KSKAqCWT19m0rAqjre1QJhOFQaWrD21g5dguAIgO3vCiyh1cBoAq18ybHYxEMarAGExDjGWwND9zJAsUbQaZh3enqVRcah1zxBKpyOaZh3enqVR4qWoQnYhmuG5JxMrGQvoAI1on4GWAFGNDTSrTp2OxRroNq6bQQT12R9YJSw4S2azW21YZAFWXW8AjzcXANabw7L1k45vl8QLg7zG1E5rQkZyXbtFQezoaZhFkbQYiyqi7NEAWbHMd7ufzoaZhxDjGWwND9zJAsUbQcKKH(8fusuaCO(GKOjAGExXHGDulS5ObvZJfe(cvPCaz6bQU8i1KSKAHnhn40KiZby(4koeSJAJ8bdvGKm0NVqbkjkaouFqsucS4GPRUeqyRZU(Srnj3avOKOa4q9bjrklZyXbtFQezoaZhFkbQYiyqi7NEAWbHMd7ufzoaZhxXHGDuBKpyOcKKH(8fusuaCO(GKOjkOOvhpq)uOpGn2h6iirerXXd0pf6dyJ9HocAIKDwzio5tT1itkP0efuiYCaMpU6saHTo76Zg1KCdufijd9P8LYbKPhOIn0KSKAqCWT19m0xEKMOb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65XccPKiIOqK5amFC1LacBD21NnQj5gOkqsg6tQY0enqVR4qWoQf2C0GQ5XccPktkP0enqVRcah1zxBKpyOaZh3ej7SYqCYNQuoGm9avSHMe6qsasnj7S2qCuwMrGQvoAI1E5rw7d8SRLnQf2RfEVN1(apBOx7zJ1sYswlio42QABT9A98mVwGjw7d8SRnsJAH9ApBS2JhOF1cN1EmHOBETSdwl8EpR9bE2qV2ZgRLKLSwqCWTvLzS4GPpvImhG5JpLavzCjGWwND9zJAsUbAoStLIwfao2ZObvtOHD665Lbjrerd07Qj0WoD98YGubyqPjAGExXHGDulS5ObvZJfe(cvPCaz6bQU8i1KSKAHnhn40KiZby(4koeSJAJ8bdvGKm0NVqfLefahQpijAIKDwzio5lLditpqfBOjHoKeGutYoRneNjAGExfaoQZU2iFWqbMpEzgloy6tLiZby(4tjqvgxciS1zxF2OMKBGMd7uPb6Dfhc2rTWMJgunpwq4luLYbKPhO6YJutYsQf2C0Gtthpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxOIsIcGd1hKenjLditpq1bjrnGFWHMnKVuoGm9avxEKAswsnio426EgA2OmJfhm9PsK5amF8PeOkJlbe26SRpButYnqZHDQ0a9UIdb7OwyZrdQMhli8fQs5aY0duD5rQjzj1cBoAWPjkA1Xd0pva4Oo7AJ8bdIisK5amFCva4Oo7AJ8bdvGKm0NYxkhqMEGQlpsnjlPgehCBDpdDKguAskhqMEGQdsIAa)GdnBiFPCaz6bQU8i1KSKAqCWT19m0SrzgbQw5OjwlBulSx7LhzTWzTPxRaSw2bR9j93xT0yTag12ZO2r6nyu7zZETNnwljlzTG4GBBETKmHqVP2jqG1E28v7dwRnlfRf9eOXUws25AzhS2ZMVApBmWAHZA98QLhbYGTRLRnaCS2SxRr(GrTG5JRkZyXbtFQezoaZhFkbQYGdb7O2iFWWCyNQiZby(4Qlbe26SRpButYnqvGKm0NYxkhqMEGk2qtYsQbXb3w3ZqF5rAIIwjsPOZ(PKI(z3oiIirMdW8XvKWiYyQZU(YGe9tfijd9P8LYbKPhOIn0KSKAqCWT19m0K5rPjAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqt0a9UkaCuNDTr(GHcmFCtKSZkdXjFQs5aY0duXgAsOdjbi1KSZAdXvMrGQvoAI1gPrTWETxEK1cN1METcWAzhS2N0FF1sJ1cyuBpJAhP3GrTNn71E2yTKSK1cIdUT51sYec9MANabw7zJbwlC6VVA5rGmy7A5AdahRfmF8AzhS2ZMVAzJAFs)9vlnkssSwwkdhm9aRfeiGEtTbGJQYmwCW0NkrMdW8XNsGQmcah1zxBKpyyoStLgO3vCiyh1g5dgkW8XnrHiZby(4Qlbe26SRpButYnqvGKm0NYxkhqMEGQin0KSKAqCWT19m0xEKerKiZby(4koeSJAJ8bdvGKm0NVqvkhqMEGQlpsnjlPgehCBDpdnBqPjAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqtImhG5JR4qWoQnYhmubsYqFkFzLPjrMdW8XvxciS1zxF2OMKBGQajzOpLVSYSmJfhm9PsK5amF8PeOkJPnSFqVrBKpyyoStvkhqMEGQe4MqquNDTiZby(4ZYmcuTYrtSwJKS2lRD2IaqKapwl71IsEbxltxl0R9SXADuYRwrMdW8XR9b6G5J51c4dCoRLW2bK9ApB0Rn9r7AbbcO3ulhc2XAnYhmQfeaR9YATZNAjzNR1gWBI21gmiK9R2PbhewlCwMXIdM(ujYCaMp(ucuLHrGt0fOo7AsOdAoSt94b6NkaCuNDTr(GHjAGExXHGDuBKpyOammrd07QaWrD21g5dgQajzOpFPraQizjlZyXbtFQezoaZhFkbQYWiWj6cuNDnj0bnh2PcI0a9U6saHTo76Zg1KCdubyycePb6D1LacBD21NnQj5gOkqsg6ZxyXbtxXHGDutcNt4aNkusuaCO(GKOPwjsPOZ(PiSDazVmJfhm9PsK5amF8PeOkdJaNOlqD21Kqh0CyNknqVRcah1zxBKpyOammrd07QaWrD21g5dgQajzOpFPraQizjnjYCaMpUcLMc(GPRcKbBBsK5amFC1LacBD21NnQj5gOkqsg6ttTsKsrN9try7aYEzwzgloy6tvh68qtdeovoeSJAs4Cch40CyNknqVRedKdbppO3OcKfN5cBg6uLTmJfhm9PQdDEOPbcxcuLbhc2rn9GNxzgloy6tvh68qtdeUeOkdoeSJAAocUblZkZiq1khAJETbG7qVPweE2yu7zJ1AzvBg1(QCyTdSbDqoG408AFWAFy)Q9YAjWKM1sJ9mWApBS2xZRLjJwQ1R9b6G5JQw5Ojwl8QLN1oZ0RLN1khKTET28S2o0HtBeS2eiQ9bFlfRDAG(vBce1kS5ObNLzS4GPpvD40g6n60aDmOIstbFW0nh2Psra4ypJguDiPrg8q)WHbrerra4ypJgunHg2PRNxgKMALuoGm9avgbAamgAuAsvwkP0ef0a9UkaCuNDTr(GHcmFCIiYiqP6gbOswfhc2rnnhb3GuAsK5amFCva4Oo7AJ8bdvGKm0NLzeOABT9AFW3sXA7qhoTrWAtGOwrMdW8XR9b6G5ZSw2bRDAG(vBce1kS5ObNMxRraZaEqc8yTeysZAtPyulkfJ2Nn0BQfhtSmJfhm9PQdN2qVrNgOJHeOkduAk4dMU5Wo1JhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd9PjrMdW8XvCiyh1g5dgQajzOpnrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MmcuQUraQKvXHGDutZrWnyzgloy6tvhoTHEJonqhdjqvgDyGA6bppZHDQbGJ9mAqfiCkGgdOZrBTijjzh0enqVRaHtb0yaDoARfjjj7G6EKZtbyuMXIdM(u1HtBO3Otd0XqcuLrpY5P9ukBoStnaCSNrdQAc4C0wdfqXanrYoRmeN8BHeuzgloy6tvhoTHEJonqhdjqvgCiyh1KW5eoWP5Wo1aWXEgnOIdb7O2MdY0BBIgO3vCiyh12CqMEB18ybHVqd07koeSJABoitVTIKLuppwqOjkOGgO3vCiyh1g5dgkW8XnjYCaMpUIdb7O2iFWqfid2MsIicePb6D1LacBD21NnQj5gOcWGsZf2m0PkBzgloy6tvhoTHEJonqhdjqvgbGJ6SRnYhmmh2Pgao2ZObvtOHD665Lbzzgloy6tvhoTHEJonqhdjqvgCiyh1zqBoStvK5amFCva4Oo7AJ8bdvGmy7YmwCW0NQoCAd9gDAGogsGQm4qWoQPh88mh2PkYCaMpUkaCuNDTr(GHkqgSTjAGExXHGDulS5ObvZJfe(cnqVR4qWoQf2C0Gksws98ybHLzS4GPpvD40g6n60aDmKavzaI8ztNHJMd7uBva4ypJguDiPrg8q)WHbrejsheaEQgy)0zxF2OEaf2LzS4GPpvD40g6n60aDmKavzeaoQZU2iFWOmJavBRTx7d(oWA5RwswYANhliCwB2RLaiGAzhS2hSwBwk6VVAbMiyTTS81ABJN51cmXA5ANhliS2lR1iqPOF1sc4cBO3ulGpW5S2aWDO3u7zJ1khlhKP3U2b2GoihTlZyXbtFQ6WPn0B0Pb6yibQYGdb7OMeoNWbonh2Psd07kXa5qWZd6nQazXzIgO3vIbYHGNh0BuZJfesLgO3vIbYHGNh0BuKSK65XccnjsPOZ(PKI(z3omjYCaMpUIegrgtD21xgKOFQazW2MALuoGm9aviPr(GbcQP5i4g0KiZby(4koeSJAJ8bdvGmy7YmcuTsmdsEmAx7dwRbdJAnYdMETatS2h4zxBl16MxlnWvl8Q9bog1o45v7i9MArpbASRTNrT05zx7zJ1khKTETSdwBl161(aDW8zwlGpW5S2aWDO3u7zJ1AzvBg1(QCyTdSbDqoG4SmJfhm9PQdN2qVrNgOJHeOkdJ8GPBoStTvbGJ9mAq1HKgzWd9dhgMOOvbGJ9mAq1eAyNUEEzqseruiLditpqLrGgaJHgLMuL1enqVR4qWoQf2C0GQ5XccPsd07koeSJAHnhnOIKLuppwqiLuwMXIdM(u1HtBO3Otd0XqcuLbiYNnDgoAoStLgO3vbGJ6SRnYhmuG5Jtergbkv3iavYQ4qWoQP5i4gSmJfhm9PQdN2qVrNgOJHeOkJGbHSF6PbheAoStLgO3vbGJ6SRnYhmuG5Jtergbkv3iavYQ4qWoQP5i4gSmJfhm9PQdN2qVrNgOJHeOkdsyezm1zxFzqI(zoStLgO3vbGJ6SRnYhmubsYqF(cfYjjiVwEa4ypJgunHg2PRNxgKuwMrGQvo0g9Ada3HEtTNnwRCSCqME7Ahyd6GC028AbMyTTuRxln2ZaR918Az1EzTGaKg1Y12bgJ21opwqicwlnhC0GLzS4GPpvD40g6n60aDmKavzWHGDuBKpyyoStvkhqMEGkK0iFWab10CeCdAIgO3vbGJ6SRnYhmuagMOGKDwziUxOqEeKeOqwz2YfPu0z)ue2oGStjLerenqVRedKdbppO3OMhliKknqVRedKdbppO3Oizj1ZJfeszzgloy6tvhoTHEJonqhdjqvgCiyh10CeCdAoStvkhqMEGkK0iFWab10CeCdAIgO3vCiyh1cBoAq18ybHuPb6Dfhc2rTWMJgurYsQNhli0enqVR4qWoQnYhmuagLzS4GPpvD40g6n60aDmKavzCjGWwND9zJAsUbAoStLgO3vbGJ6SRnYhmuG5Jtergbkv3iavYQ4qWoQP5i4gKiImcuQUraQKvfmiK9tpn4GqIiIcJaLQBeGkzvGiF20z4OPwfao2ZObvtOHD665LbjLLzS4GPpvD40g6n60aDmKavzWHGDuBKpyyoSt1iqP6gbOsw1LacBD21NnQj5gyzgbQw5OjwBRNTSAVS2zlcarc8yTSxlk5fCTTuiyhRLydEE1cceqVP2ZgR918AzYOLA9AFGoy(ulGpW5S2aWDO3uBlfc2XAjWe2PQ2wBV2wkeSJ1sGjSZAHZApEG(HGMx7dwRG93xTatS2wpBz1(apBOx7zJ1(AETmz0sTETpqhmFQfWh4Cw7dwl0pmcaJR2ZgRTLAz1kSz3XH51oZAFW3JrTtwkwl8uLzS4GPpvD40g6n60aDmKavzye4eDbQZUMe6GMd7uB1Xd0pfhc2rnkSttGinqVRUeqyRZU(Srnj3avagMarAGExDjGWwND9zJAsUbQcKKH(8fQuWIdMUIdb7OMEWZtHsIcGd1hKeB50a9UYiWj6cuNDnj0bvKSK65XccPSmJavBRTxBRNTSAT5P)(QLgrVwGjcwliqa9MApBS2xZRLv7d0bZhZR9bFpg1cmXAHxTxw7SfbGibESw2RfL8cU2wkeSJ1sSbpVAHETNnwRCq26YOLA9AFGoy(OkZyXbtFQ6WPn0B0Pb6yibQYWiWj6cuNDnj0bnh2Psd07koeSJAJ8bdfGHjAGExfaoQZU2iFWqfijd95luPGfhmDfhc2rn9GNNcLefahQpij2YPb6DLrGt0fOo7AsOdQizj1ZJfeszzgloy6tvhoTHEJonqhdjqvgCiyh10dEEMd7ubZtfmiK9tpn4GqvGKm0NYNGiIiqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliu(YSmJavRCiw7d7xTxwljtiw7eiWAFWATzPyTONan21sYoxBpJApBSw0pyG12sTETpqhmFmVwuk61c71E2yGVN1op4yu7bjXAdKKHo0BQn9ALdYwxvBR9EpRn9r7APX7WO2lRLgi8AVSwc8yK1YoyTeysZAH9Ada3HEtTNnwRLvTzu7RYH1oWg0b5aItvzgloy6tvhoTHEJonqhdjqvgCiyh10CeCdAoStvK5amFCfhc2rTr(GHkqgSTjs2zLH4EHIwGmLafYkZwUiLIo7NIW2bKDkP0enqVR4qWoQf2C0GQ5XccPsd07koeSJAHnhnOIKLuppwqOjkAva4ypJgunHg2PRNxgKerKuoGm9avgbAamgAuAsvwkn1QaWXEgnO6qsJm4H(HddtTkaCSNrdQ4qWoQT5Gm92LzeOAjghb3G1oTtGbyTEE1sJ1cmrWA5R2ZgRfDWAZETTuRxlSxlbM0uWhm9AHZAdKbBxlpRfmsddO3uRWMJgCw7dCmQLKjeRfE1EmHyTJ0BWO2lRLgi8Ap7ibASRnqsg6qVPws25YmwCW0NQoCAd9gDAGogsGQm4qWoQP5i4g0CyNknqVR4qWoQnYhmuagMOb6Dfhc2rTr(GHkqsg6ZxO2ianjYCaMpUcLMc(GPRcKKH(SmJavlX4i4gS2PDcmaRLhpC7zT0yTNnw7GNxTcEE1c9ApBSw5GS1R9b6G5tT8S2xZRLv7dCmQnW5Lbw7zJ1kS5ObN1onq)kZyXbtFQ6WPn0B0Pb6yibQYGdb7OMMJGBqZHDQ0a9UkaCuNDTr(GHcWWenqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmubsYqF(c1gbOPwfao2ZObvCiyh12CqME7YmwCW0NQoCAd9gDAGogsGQm4qWoQjHZjCGtZHDQGinqVRUeqyRZU(Srnj3avagMoEG(P4qWoQrHDAIcAGExbI8ztNHJkW8XjIiwCqPOgDKeItQYsPjqKgO3vxciS1zxF2OMKBGQajzOpLploy6koeSJAs4Cch4uHsIcGd1hKenxyZqNQSMJCmARf2m01WovAGExjgihcEEqVrlSz3XHcmFCtuqd07koeSJAJ8bdfGbrerrRoEG(PsPyyKpyGGMOGgO3vbGJ6SRnYhmuagerKiZby(4kuAk4dMUkqgSnLuszzgbQ2wBV2h8DG1kf9ZUDyETqsseeYhoAxlWeRLaiGAFSrVwbByGG1EzTEE1(WZdR1isXS2EKK12YYxlZyXbtFQ6WPn0B0Pb6yibQYGdb7OMeoNWbonh2PksPOZ(PKI(z3omrd07kXa5qWZd6nQ5XccPsd07kXa5qWZd6nksws98ybHLzeOATooUAbMqVPwcGaQTLAz1(yJETTuRxRnpRLgrVwGjcwMXIdM(u1HtBO3Otd0XqcuLbhc2rnjCoHdCAoStLgO3vIbYHGNh0BubYIZKiZby(4koeSJAJ8bdvGKm0NMOGgO3vbGJ6SRnYhmuagerenqVR4qWoQnYhmuaguAUWMHovzlZyXbtFQ6WPn0B0Pb6yibQYGdb7OodAZHDQ0a9UIdb7OwyZrdQMhli8fQs5aY0duD5rQjzj1cBoAWzzgloy6tvhoTHEJonqhdjqvgCiyh10dEEMd7uPb6Dva4Oo7AJ8bdfGbrerYoRmeN8LLGkZyXbtFQ6WPn0B0Pb6yibQYaLMc(GPBoStLgO3vbGJ6SRnYhmuG5JBIgO3vCiyh1g5dgkW8Xnh6hgbGXPHDQKSZkdXjFQYzcYCOFyeagNgssIGq(qQYwMXIdM(u1HtBO3Otd0XqcuLbhc2rnnhb3GLzLzeicuTYr(eWWiJdbRvWUahAwCW0LJ7AjWKMc(GPx7dCmQLgR15di4XODT0rsi61c71ksheEW0N1YbwljEQYmcebQwwCW0NkBoitVnvb7cCOzXbt3CyNkloy6kuAk4dMUsyZUJdO3yIKDwzio5tTfsqLzeOABT9Ah5tTPxlj7CTSdwRiZby(4ZA5aRvKKqVPwadZRTjRLTrgSw2bRfLMLzS4GPpv2CqMEBjqvgO0uWhmDZHDQKSZkdX9cvItMMKYbKPhOkbUjee1zxlYCaMp(0efhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKvMuwMrGQvoeR9H9R2lRDESGWAT5Gm9212bgJ2QAF1gRfyI1M9ALvov78ybHZATXaRfoR9YAzHib8R2Eg1E2yThuqyTdSF1METNnwRWMDhh1YoyTNnwljCoHdSwOxBFaBSpvzgloy6tLnhKP3wcuLbhc2rnjCoHdCAoStLcPCaz6bQMhliuBZbz6TjIOdsIViRmP0enqVR4qWoQT5Gm92Q5XccFrw5K5cBg6uLTmJavRCOn61cmHEtTeyKgTdKh1sGlaD2fO51k45vlxBhFQfL8cUws4Cch4S2hB4aR9HHh0BQTNrTNnwlnqVxlF1E2yTZJJR2Sx7zJ12Hn2xzgloy6tLnhKP3wcuLbhc2rnjCoHdCAoStfBraqddeuHKgTdKh6maD2fOPdsIVqCY00LnndujYCaMp(0KiZby(4kK0ODG8qNbOZUavbsYqFkFzLtYztTIfhmDfsA0oqEOZa0zxGkq4KPhiyzgloy6tLnhKP3wcuLrWGq2p90Gdcnh2PkLditpqfsAKpyGGAAocUbnjYCaMpU6saHTo76Zg1KCdufijd95lurjrbWH6dsIMezoaZhxXHGDuBKpyOcKKH(8fQuGsIcGd1hKeB5YJstu0kSfbanmqq1mbgd8oO3Oda62erKiDqa4P4qWoQnIee20wfStO8Psqer0fqNq8uZeymW7GEJoaOBRezoaZhxfijd95luPaLefahQpij2YLhLuwMXIdM(uzZbz6TLavzCjGWwND9zJAsUbAoStvkhqMEGQwCG5PbMiOEAWbHMezoaZhxXHGDuBKpyOcKKH(8fQOKOa4q9bjrtu0kSfbanmqq1mbgd8oO3Oda62erKiDqa4P4qWoQnIee20wfStO8Psqer0fqNq8uZeymW7GEJoaOBRezoaZhxfijd95lurjrbWH6dsIuwMXIdM(uzZbz6TLavzWHGDuBKpyyoSt1iqP6gbOsw1LacBD21NnQj5gyzgloy6tLnhKP3wcuLra4Oo7AJ8bdZHDQs5aY0duHKg5dgiOMMJGBqtImhG5JRcgeY(PNgCqOkqsg6ZxOIsIcGd1hKenjLditpq1bjrnGFWHMnKpv5jttu0kr6GaWtXHGDuBejiSPnre1kPCaz6bQ4Xd3EQNTDHwK5amF8jrejYCaMpU6saHTo76Zg1KCdufijd95luPaLefahQpij2YLhLuwMXIdM(uzZbz6TLavzemiK9tpn4GqZHDQs5aY0duHKg5dgiOMMJGBqtgbkv3iavYQcah1zxBKpyuMXIdM(uzZbz6TLavzCjGWwND9zJAsUbAoStvkhqMEGQwCG5PbMiOEAWbHMALuoGm9av25ae6n6lpYYmcuTYrtSw55G1YHGDSwAocUbRf612sTUeKdiW161M(ODTWETeBKj4ayE1YoyT8v7a55vR8QLaiGzTgrkeiyzgloy6tLnhKP3wcuLbhc2rnnhb3GMd7uPb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65Xccnrd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbyyIgO3vCiyh12CqMEB18ybHYNQSYjt0a9UIdb7O2iFWqfijd95luzXbtxXHGDutZrWnOcLefahQpijAIgO3v0JmbhaZtbyuMrGQvoAI1kphSw5GS1Rf612sTETPpAxlSxlXgzcoaMxTSdwR8QLaiGzTgrkkZyXbtFQS5Gm92sGQmcah1zxBKpyyoStLgO3vbGJ6SRnYhmuG5JBIgO3v0JmbhaZtbyyIcPCaz6bQoijQb8do0SH8jozserImhG5JRcgeY(PNgCqOkqsg6t5lR8O0ef0a9UIdb7O2MdY0BRMhliu(uLLGiIiAGExjgihcEEqVrnpwqO8PklLMOOvI0bbGNIdb7O2isqytBIiQvs5aY0duXJhU9upB7cTiZby(4tklZyXbtFQS5Gm92sGQmcah1zxBKpyyoStLgO3vCiyh1g5dgkW8XnrHuoGm9avhKe1a(bhA2q(eNmjIirMdW8Xvbdcz)0tdoiufijd9P8LvEuAIIwjsheaEkoeSJAJibHnTjIOwjLditpqfpE42t9STl0ImhG5JpPSmJfhm9PYMdY0BlbQYiyqi7NEAWbHMd7uLYbKPhOcjnYhmqqnnhb3GMOGgO3vCiyh1cBoAq18ybHYNQ8iIirMdW8XvCiyh1zqRcKbBtPjkA1Xd0pva4Oo7AJ8bdIisK5amFCva4Oo7AJ8bdvGKm0NYNGO0KuoGm9av48GK8HGA2qlYCaMpU8PsCY0efTsKoia8uCiyh1grccBAterTskhqMEGkE8WTN6zBxOfzoaZhFszzgbQw5qB0RnaCh6n1AejiSPT51cmXAV8iRLUDTWBIJETqV2maXO2lRLhWgVw4v7d8SRLnkZyXbtFQS5Gm92sGQmUeqyRZU(Srnj3anh2PkLditpq1bjrnGFWHMnEHGKPjPCaz6bQoijQb8do0SH8jozAIIwHTiaOHbcQMjWyG3b9gDaq3MiIePdcapfhc2rTrKGWM2QGDcLpvcIYYmwCW0NkBoitVTeOkdoeSJ6mOnh2PkLditpqvloW80ateupn4Gqt0a9UIdb7OwyZrdQMhli8fAGExXHGDulS5ObvKSK65XcclZyXbtFQS5Gm92sGQm4qWoQP5i4g0CyNkisd07QGbHSF6PbheQLcmCmyA4aETvZJfesfePb6DvWGq2p90Gdc1sbgogmnCaV2ksws98ybHLzS4GPpv2CqMEBjqvgCiyh10dEEMd7uLYbKPhOQfhyEAGjcQNgCqirerbisd07QGbHSF6PbheQLcmCmyA4aETvagMarAGExfmiK9tpn4GqTuGHJbtdhWRTAESGWxarAGExfmiK9tpn4GqTuGHJbtdhWRTIKLuppwqiLLzeOALJMyTKqhwlX4i4gSwA8Eq0Rnyqi7xTtdoiCwlSxlGdIrTeJGR9bE2jWvlio42qVPw5ageY(vRLbhewlee5XODzgloy6tLnhKP3wcuLbhc2rnnhb3GMd7uPb6Dva4Oo7AJ8bdfGHjAGExXHGDuBKpyOaZh3enqVROhzcoaMNcWWKiZby(4QGbHSF6PbheQcKKH(8fQYktt0a9UIdb7O2MdY0BRMhliu(uLvovMrGQvoAI1MbDTPxRaSwaFGZzTSrTWzTIKe6n1cyu7mtVmJfhm9PYMdY0BlbQYGdb7OodAZHDQ0a9UIdb7OwyZrdQMhli8fIZKuoGm9avhKe1a(bhA2q(YkttuiYCaMpU6saHTo76Zg1KCdufijd9P8jiIiQvI0bbGNIdb7O2isqytBklZyXbtFQS5Gm92sGQm4qWoQjHZjCGtZHDQ0a9Usmqoe88GEJkqwCMOb6Dfhc2rTr(GHcWWCHndDQYwMrGQT12R9bRTbVAnYhmQf6DGjm9AbbcO3u7ayE1(GVhJATzPyTONan21AZZdR9YABWR2S3RLRDEr6n1sZrWnyTGab0BQ9SXAJ0qgSrTpqhmFkZyXbtFQS5Gm92sGQm4qWoQP5i4g0CyNknqVRcah1zxBKpyOammrd07QaWrD21g5dgQajzOpFHkloy6koeSJAs4Cch4uHsIcGd1hKenrd07koeSJAJ8bdfGHjAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqt0a9UIdb7O2MdY0BRMhli0enqVRmYhm0qVdmHPRammrd07k6rMGdG5PamkZiq12A71(G12GxTg5dg1c9oWeMETGab0BQDamVAFW3JrT2SuSw0tGg7AT55H1EzTn4vB271Y1oVi9MAP5i4gSwqGa6n1E2yTrAid2O2hOdMpMx7mR9bFpg1M(ODTatSw0tGg7APh88M1cD4b5XODTxwBdE1EzT9eiQvyZrdolZyXbtFQS5Gm92sGQm4qWoQPh88mh2Psd07kJaNOlqD21KqhubyyIcAGExXHGDulS5ObvZJfe(cnqVR4qWoQf2C0Gksws98ybHeruROGgO3vg5dgAO3bMW0vagMOb6Df9itWbW8uaguszzgbQ2xTXAPX5vlWeRn71AKK1cN1EzTatSw4v7L12IaGcchTRLgaoaRvyZrdoRfeiGEtTSrTC)WO2ZgBxBdE1ccqAGG1s3U2ZgR1MdY0Bxlnhb3GLzS4GPpv2CqMEBjqvggborxG6SRjHoO5WovAGExXHGDulS5ObvZJfe(cnqVR4qWoQf2C0Gksws98ybHMOb6Dfhc2rTr(GHcWOmJavRCiw7d7xTxw78ybH1AZbz6TRTdmgTv1(QnwlWeRn71kRCQ25XccN1AJbwlCw7L1Ycrc4xT9mQ9SXApOGWAhy)Qn9ApBSwHn7ooQLDWApBSws4CchyTqV2(a2yFQYmwCW0NkBoitVTeOkdoeSJAs4Cch40CyNknqVR4qWoQT5Gm92Q5XccFrw5K5cBg6uL1COFyeaghvznh6hgbGXPBgjnpOkBzgloy6tLnhKP3wcuLbhc2rnnhb3GMd7uPb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65XccnjLditpqfsAKpyGGAAocUblZyXbtFQS5Gm92sGQmqPPGpy6Md7ujzNvgI7fzjOYmcuTe48r7AbMyT0dEE1EzT0aWbyTcBoAWzTWETpyT8iqgSDT2SuS2zsI12JKS2mOlZyXbtFQS5Gm92sGQm4qWoQPh88mh2Psd07koeSJAHnhnOAESGqt0a9UIdb7OwyZrdQMhli8fAGExXHGDulS5ObvKSK65XcclZiq1khhWXO2h4zxltwlGpW5Sw2Ow4Swrsc9MAbmQLDWAFW3bw7iFQn9AjzNlZyXbtFQS5Gm92sGQm4qWoQjHZjCGtZHDQTIcPCaz6bQoijQb8do0SXluLvMMizNvgI7fItMuAUWMHovznh6hgbGXrvwZH(HrayC6MrsZdQYwMrGQT1JSdh4S2h4zx7iFQLKNhgTnVwByJDT288qZRnJAPZZUwsUDTEE1AZsXArpbASRLKDU2lRDcyyKXvRD(ulj7CTq)qFcLI1gmiK9R2PbhewRG9APrZRDM1(GVhJAbMyTDyG1sp45vl7G12JCE054Q9Xg9Ah5tTPxlj7Czgloy6tLnhKP3wcuLrhgOMEWZRmJfhm9PYMdY0BlbQYOh58OZXvMvMXIdM(uLgOJb1omqn9GNN5Wo1aWXEgnOceofqJb05OTwKKKSdAIgO3vGWPaAmGohT1IKKKDqDpY5PamkZyXbtFQsd0XqcuLrpY5P9ukBoStnaCSNrdQAc4C0wdfqXanrYoRmeN8BHeuzgloy6tvAGogsGQmar(SPZWXYmwCW0NQ0aDmKavzemiK9tpn4GqZHDQKSZkdXj)wGmlZyXbtFQsd0XqcuLbjmImM6SRVmir)kZyXbtFQsd0XqcuLX0g2pO3OnYhmmh2Psd07koeSJAJ8bdfy(4MezoaZhxXHGDuBKpyOcKKH(SmJfhm9PknqhdjqvgCiyh1zqBoStvK5amFCfhc2rTr(GHkqgSTjAGExXHGDulS5ObvZJfe(cnqVR4qWoQf2C0Gksws98ybHLzS4GPpvPb6yibQYGdb7OMEWZZCyNQiLIo7Nsk6ND7WKiZby(4ksyezm1zxFzqI(PcKKH(u(Y5wqzgloy6tvAGogsGQmUeqyRZU(Srnj3alZyXbtFQsd0XqcuLbhc2rTr(Grzgloy6tvAGogsGQmcah1zxBKpyyoStLgO3vCiyh1g5dgkW8XlZiq1khnXAB9SLv7L1oBraisGhRL9ArjVGRTLcb7yTeBWZRwqGa6n1E2yTVMxltgTuRx7d0bZNAb8boN1gaUd9MABPqWowlbMWov12A712sHGDSwcmHDwlCw7Xd0pe08AFWAfS)(QfyI126zlR2h4zd9ApBS2xZRLjJwQ1R9b6G5tTa(aNZAFWAH(HrayC1E2yTTulRwHn7oomV2zw7d(EmQDYsXAHNQmJfhm9PknqhdjqvggborxG6SRjHoO5Wo1wD8a9tXHGDuJc70eisd07Qlbe26SRpButYnqfGHjqKgO3vxciS1zxF2OMKBGQajzOpFHkfS4GPR4qWoQPh88uOKOa4q9bjXwonqVRmcCIUa1zxtcDqfjlPEESGqklZiq12A7126zlRwBE6VVAPr0RfyIG1cceqVP2ZgR918Az1(aDW8X8AFW3JrTatSw4v7L1oBraisGhRL9ArjVGRTLcb7yTeBWZRwOx7zJ1khKTUmAPwV2hOdMpQYmwCW0NQ0aDmKavzye4eDbQZUMe6GMd7uPb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(8fQuWIdMUIdb7OMEWZtHsIcGd1hKeB50a9UYiWj6cuNDnj0bvKSK65XccPSmJfhm9PknqhdjqvgCiyh10dEEMd7ubZtfmiK9tpn4GqvGKm0NYNGiIiqKgO3vbdcz)0tdoiulfy4yW0Wb8ARMhliu(YSmJavBlnE42ZAjghb3G1YxTNnwl6G1M9ABPwV2hB0RnaCh6n1E2yTTuiyhRvowoitVDTdSbDqoAxMXIdM(uLgOJHeOkdoeSJAAocUbnh2Psd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8LgbOPaWXEgnOIdb7O2MdY0BxMrGQTLgpC7zTeJJGBWA5R2ZgRfDWAZETNnwRCq261(aDW8P2hB0RnaCh6n1E2yTTuiyhRvowoitVDTdSbDqoAxMXIdM(uLgOJHeOkdoeSJAAocUbnh2Psd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqfijd95luBeGMcah7z0GkoeSJABoitVDzgloy6tvAGogsGQm4qWoQjHZjCGtZHDQGinqVRUeqyRZU(Srnj3avagMoEG(P4qWoQrHDAIcAGExbI8ztNHJkW8XjIiwCqPOgDKeItQYsPjqKgO3vxciS1zxF2OMKBGQajzOpLploy6koeSJAs4Cch4uHsIcGd1hKenxyZqNQSMJCmARf2m01WovAGExjgihcEEqVrlSz3XHcmFCtuqd07koeSJAJ8bdfGbrerrRoEG(PsPyyKpyGGMOGgO3vbGJ6SRnYhmuagerKiZby(4kuAk4dMUkqgSnLuszzgloy6tvAGogsGQm4qWoQjHZjCGtZHDQ0a9Usmqoe88GEJAESGqQ0a9Usmqoe88GEJIKLuppwqOjrkfD2pLu0p72rzgloy6tvAGogsGQm4qWoQjHZjCGtZHDQ0a9Usmqoe88GEJkqwCMezoaZhxXHGDuBKpyOcKKH(0ef0a9UkaCuNDTr(GHcWGiIOb6Dfhc2rTr(GHcWGsZf2m0PkBzgloy6tvAGogsGQm4qWoQZG2CyNknqVR4qWoQf2C0GQ5XccFHQuoGm9avxEKAswsTWMJgCwMXIdM(uLgOJHeOkdoeSJA6bppZHDQ0a9UkaCuNDTr(GHcWGiIizNvgIt(YsqLzS4GPpvPb6yibQYaLMc(GPBoStLgO3vbGJ6SRnYhmuG5JBIgO3vCiyh1g5dgkW8Xnh6hgbGXPHDQKSZkdXjFQYzcYCOFyeagNgssIGq(qQYwMXIdM(uLgOJHeOkdoeSJAAocUblZkZiqeOAzXbtFQI84dMovb7cCOzXbt3CyNkloy6kuAk4dMUsyZUJdO3yIKDwzio5tTfsqMOOvbGJ9mAq1eAyNUEEzqser0a9UAcnStxpVmivZJfesLgO3vtOHD665LbPIKLuppwqiLLzeOALJMyTO0SwyV2h8DG1oYNAtVws25AzhSwrMdW8XN1YbwltNaxTxwlnwlGrzgloy6tvKhFW0LavzGstbFW0nh2P2QaWXEgnOAcnStxpVminrYoRme3luLYbKPhOcLMAdXzIcrMdW8XvxciS1zxF2OMKBGQajzOpFHkloy6kuAk4dMUcLefahQpijserImhG5JR4qWoQnYhmubsYqF(cvwCW0vO0uWhmDfkjkaouFqsKiIO44b6NkaCuNDTr(GHjrMdW8XvbGJ6SRnYhmubsYqF(cvwCW0vO0uWhmDfkjkaouFqsKsknrd07QaWrD21g5dgkW8Xnrd07koeSJAJ8bdfy(4MarAGExDjGWwND9zJAsUbQaZh3uRmcuQUraQKvDjGWwND9zJAsUbwMXIdM(uf5XhmDjqvgO0uWhmDZHDQbGJ9mAq1eAyNUEEzqAQvIuk6SFkPOF2TdtImhG5JR4qWoQnYhmubsYqF(cvwCW0vO0uWhmDfkjkaouFqsSmJfhm9PkYJpy6sGQmqPPGpy6Md7udah7z0GQj0WoD98YG0KiLIo7Nsk6ND7WKiZby(4ksyezm1zxFzqI(PcKKH(8fQS4GPRqPPGpy6kusuaCO(GKOjrMdW8XvxciS1zxF2OMKBGQajzOpFHkfs5aY0durMN2iqbIG6lpsnDBjWIdMUcLMc(GPRqjrbWH6dsIsG4O0KiZby(4koeSJAJ8bdvGKm0NVqLcPCaz6bQiZtBeOarq9LhPMUTeyXbtxHstbFW0vOKOa4q9bjrjqCuwMrGQLyCeCdwlSxl8EpR9GKyTxwlWeR9YJSw2bR9bR1MLI1Ezwlj7TRvyZrdolZyXbtFQI84dMUeOkdoeSJAAocUbnh2PkYCaMpU6saHTo76Zg1KCdufid22ef0a9UIdb7OwyZrdQMhliu(s5aY0duD5rQjzj1cBoAWPjrMdW8XvCiyh1g5dgQajzOpFHkkjkaouFqs0ej7SYqCYxkhqMEGk2qtcDijaPMKDwBiot0a9UkaCuNDTr(GHcmFCklZyXbtFQI84dMUeOkdoeSJAAocUbnh2PkYCaMpU6saHTo76Zg1KCdufid22ef0a9UIdb7OwyZrdQMhliu(s5aY0duD5rQjzj1cBoAWPPJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lurjrbWH6dsIMKYbKPhO6GKOgWp4qZgYxkhqMEGQlpsnjlPgehCBDpdnBqzzgloy6tvKhFW0LavzWHGDutZrWnO5WovrMdW8XvxciS1zxF2OMKBGQazW2MOGgO3vCiyh1cBoAq18ybHYxkhqMEGQlpsnjlPwyZrdonrrRoEG(Pcah1zxBKpyqerImhG5JRcah1zxBKpyOcKKH(u(s5aY0duD5rQjzj1G4GBR7zOJ0Gsts5aY0duDqsud4hCOzd5lLditpq1LhPMKLudIdUTUNHMnOSmJfhm9PkYJpy6sGQm4qWoQP5i4g0CyNkisd07QGbHSF6PbheQLcmCmyA4aETvZJfesfePb6DvWGq2p90Gdc1sbgogmnCaV2ksws98ybHMOGgO3vCiyh1g5dgkW8XjIiAGExXHGDuBKpyOcKKH(8fQncqknrbnqVRcah1zxBKpyOaZhNiIOb6Dva4Oo7AJ8bdvGKm0NVqTraszzgloy6tvKhFW0LavzWHGDutp45zoStvkhqMEGQwCG5PbMiOEAWbHerefGinqVRcgeY(PNgCqOwkWWXGPHd41wbyycePb6DvWGq2p90Gdc1sbgogmnCaV2Q5XccFbePb6DvWGq2p90Gdc1sbgogmnCaV2ksws98ybHuwMXIdM(uf5XhmDjqvgCiyh10dEEMd7uPb6DLrGt0fOo7AsOdQammbI0a9U6saHTo76Zg1KCdubyycePb6D1LacBD21NnQj5gOkqsg6ZxOYIdMUIdb7OMEWZtHsIcGd1hKelZyXbtFQI84dMUeOkdoeSJAs4Cch40CyNkisd07Qlbe26SRpButYnqfGHPJhOFkoeSJAuyNMOGgO3vGiF20z4OcmFCIiIfhukQrhjH4KQSuAIcqKgO3vxciS1zxF2OMKBGQajzOpLploy6koeSJAs4Cch4uHsIcGd1hKejIirMdW8XvgborxG6SRjHoOkqsg6tIisKsrN9try7aYoLMlSzOtvwZrogT1cBg6AyNknqVRedKdbppO3Of2S74qbMpUjkOb6Dfhc2rTr(GHcWGiIOOvhpq)uPummYhmqqtuqd07QaWrD21g5dgkadIisK5amFCfknf8btxfid2MskPSmJavlbK(eGeR9SXArjnyhebR1ip0pipQLgO3RLNSrTxwRNxTJCI1AKh6hKh1AePywMXIdM(uf5XhmDjqvgCiyh1KW5eoWP5WovAGExjgihcEEqVrfilot0a9UcL0GDqeuBKh6hKhkaJYmwCW0NQip(GPlbQYGdb7OMeoNWbonh2Psd07kXa5qWZd6nQazXzIcAGExXHGDuBKpyOamiIiAGExfaoQZU2iFWqbyqerGinqVRUeqyRZU(Srnj3avbsYqFkFwCW0vCiyh1KW5eoWPcLefahQpijsP5cBg6uLTmJfhm9PkYJpy6sGQm4qWoQjHZjCGtZHDQ0a9Usmqoe88GEJkqwCMOb6DLyGCi45b9g18ybHuPb6DLyGCi45b9gfjlPEESGqZf2m0PkBzgbQ2wA8WTN1Er7AVSwA2jSwcGaQTNrTImhG5Jx7d0bZNzT0axTGaKg1E2izTWETNn2(DG1Y0jWv7L1IsAadSmJfhm9PkYJpy6sGQm4qWoQjHZjCGtZHDQ0a9Usmqoe88GEJkqwCMOb6DLyGCi45b9gvGKm0NVqLckOb6DLyGCi45b9g18ybHTCwCW0vCiyh1KW5eoWPcLefahQpijsPeAeGkswsknxyZqNQSLzS4GPpvrE8btxcuLHJNng6djnW5zoStLIa7boTz6bserT6GccHEdLMOb6Dfhc2rTWMJgunpwqivAGExXHGDulS5ObvKSK65Xccnrd07koeSJAJ8bdfy(4MarAGExDjGWwND9zJAsUbQaZhVmJfhm9PkYJpy6sGQm4qWoQZG2CyNknqVR4qWoQf2C0GQ5XccFHQuoGm9avxEKAswsTWMJgCwMXIdM(uf5XhmDjqvgtadm8ukBoStvkhqMEGQe4MqquNDTiZby(4ttKSZkdX9c1wibvMXIdM(uf5XhmDjqvgCiyh10dEEMd7uPb6DvamqD21NDG4ubyyIgO3vCiyh1cBoAq18ybHYN4kZiq1khpaPrTcBoAWzTWETpyTDEmQLgh5tTNnwRi9jgsXAjzNR9SdCANdWAzhSwuAk4dMETWzTZdog1METImhG5JxMXIdM(uf5XhmDjqvgCiyh10CeCdAoStTvbGJ9mAq1eAyNUEEzqAskhqMEGQe4MqquNDTiZby(4tt0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(c1gbOjs2zLH4EHAluMMezoaZhxHstbFW0vbsYqFwMXIdM(uf5XhmDjqvgCiyh10CeCdAoStnaCSNrdQMqd701Zldsts5aY0duLa3ecI6SRfzoaZhFAIgO3vCiyh1cBoAq18ybHuPb6Dfhc2rTWMJgurYsQNhli00Xd0pfhc2rDg0MezoaZhxXHGDuNbTkqsg6ZxO2ianrYoRme3luBHY0KiZby(4kuAk4dMUkqsg6ZxiozwMrGQvoEasJAf2C0GZAH9AZGUw4S2azW2LzS4GPpvrE8btxcuLbhc2rnnhb3GMd7uLYbKPhOkbUjee1zxlYCaMp(0enqVR4qWoQf2C0GQ5XccPsd07koeSJAHnhnOIKLuppwqOPJhOFkoeSJ6mOnjYCaMpUIdb7OodAvGKm0NVqTraAIKDwziUxO2cLPjrMdW8XvO0uWhmDvGKm0NMOOvbGJ9mAq1eAyNUEEzqser0a9UAcnStxpVmivbsYqF(cvzLZuwMrGQTLcb7yTeJJGBWAN2jWaS2g0XGhJ21sJ1E2yTdEE1k45vB2R9SXABPwV2hOdMpLzS4GPpvrE8btxcuLbhc2rnnhb3GMd7uPb6Dfhc2rTr(GHcWWenqVR4qWoQnYhmubsYqF(c1gbOjAGExXHGDulS5ObvZJfesLgO3vCiyh1cBoAqfjlPEESGqtuiYCaMpUcLMc(GPRcKKH(KiIcah7z0GkoeSJABoitVnLLzeOABPqWowlX4i4gS2PDcmaRTbDm4XODT0yTNnw7GNxTcEE1M9ApBSw5GS1R9b6G5tzgloy6tvKhFW0LavzWHGDutZrWnO5WovAGExfaoQZU2iFWqbyyIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgQajzOpFHAJa0enqVR4qWoQf2C0GQ5XccPsd07koeSJAHnhnOIKLuppwqOjkezoaZhxHstbFW0vbsYqFserbGJ9mAqfhc2rTnhKP3MYYmcuTTuiyhRLyCeCdw70obgG1sJ1E2yTdEE1k45vB2R9SXAFnVwwTpqhmFQf2RfE1cN165vlWebR9bE21khKTETzuBl16LzS4GPpvrE8btxcuLbhc2rnnhb3GMd7uPb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHcmFCtGinqVRUeqyRZU(Srnj3avagMarAGExDjGWwND9zJAsUbQcKKH(8fQncqt0a9UIdb7OwyZrdQMhliKknqVR4qWoQf2C0Gksws98ybHLzeOALdTrV2ZgR94ObVAHZAHETOKOa4WAd2BWAzhS2ZgdSw4SwYmWApB2RnDSw0rY2MxlWeRLMJGBWA5zTZm9A5zTTtGATzPyTONan21kS5ObN1EzT2WRwEmQfDKeIZAH9ApBS2wkeSJ1sSKKMdqs0VAhyd6GC0Uw4SwSfbanmqWYmwCW0NQip(GPlbQYGdb7OMMJGBqZHDQs5aY0duHKg5dgiOMMJGBqt0a9UIdb7OwyZrdQMhliu(uPGfhukQrhjH4SftwknXIdkf1OJKqCkFznrd07kqKpB6mCubMpEzgloy6tvKhFW0LavzWHGDuJsAmYjmDZHDQs5aY0duHKg5dgiOMMJGBqt0a9UIdb7OwyZrdQMhli8fAGExXHGDulS5ObvKSK65XccnXIdkf1OJKqCkFznrd07kqKpB6mCubMpEzgloy6tvKhFW0LavzWHGDutp45vMXIdM(uf5XhmDjqvgO0uWhmDZHDQs5aY0duLa3ecI6SRfzoaZhFwMXIdM(uf5XhmDjqvgCiyh10CeCd(TyGZoJVLfKeyWhmDci4(9V)9)a]] )

    
end