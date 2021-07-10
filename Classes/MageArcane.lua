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


    spec:RegisterPack( "Arcane", 20210710, [[daLqehqiPk1JqGYLiQOkztuKpPQQrHeDkKWQKQO6viunlkQULuff7IKFrezyerDmIslJOkpdbY0iQixdb02iQqFtQsyCsvGZjvHSoIGEhrfvPMNQkDpK0(iQQdkvrwicLhIamrIkQIlsurzJevuv(irfvmsIkQ0jLQeTskkVKOIQQzse4MsvO2jrOFIav1qLQKwkcu5PuYuvvXvjQG(krfySevAVQYFj1Gv6WOwms9yctgWLH2Su(Suz0uQtdA1svu61iOzRWTr0UP63IgofoUuf0YfEUIMUkxhOTtK(UQY4jkoVuvRhbQY8ri7xYpzF)8Sa4dFsuEswEYk5EHSswjRCswcuEe0Z66BGpldwqi3HplNjXNvpfc2XNLb3FKmW7NN1mbdb(SSVZykHsssDWZgKwjssjnHKGd(GPlcUDsAcjfs6zrdchxV0F0pla(WNeLNKLNSsUxiRKvYkNKLaLvo(SMgO4jr5O8Ew2qaa0F0plaCkEw9yUdRTNcb7yzMzGJ(1kRKnVw5jz5jBzwzgbyZEhoLWYSEMALdNyTxFdOGh1AbjjGATzhya9UAZwTcB2DCul0pmcqJdMETqFEiduB2Q9VGDbo0S4GP)xvM1ZulbyZEhwlhc2rn0BqhE9R9YA5qWoQT5Gm9(1sj8Q1rPyu7h6xTdOuSwEwlhc2rTnhKP3Nc1ZAaN389ZZknqhJ3ppjk77NNf6m9abEe7zjc4HbKFwbOJTm6qfaCkGgdOZrFTijjzhqHotpqGAnvlnyRPaGtb0yaDo6Rfjjj7a6wKZtbA8SyXbt)z1GbQPh88E3tIY79ZZcDMEGapI9Seb8WaYpRa0XwgDOQlGZrFnuafduHotpqGAnvlj7SYqC1k)A7re4ZIfhm9NvlY5P9uk)UNejO3pplwCW0FwaiF20z44ZcDMEGapI9UNeLtVFEwOZ0de4rSNLiGhgq(zrYoRmexTYVw5KKFwS4GP)ScgaY(PNgCq47EsKaF)8SyXbt)zrcJiJPoB6lds0VNf6m9abEe7DpjkhF)8SqNPhiWJyplrapmG8ZIgS1uCiyh1g5hgkG8ZR1uTImha5NR4qWoQnYpmubsYqF(SyXbt)znTHTd6DAJ8dJ39KyV49ZZcDMEGapI9Seb8WaYplrMdG8ZvCiyh1g5hgQazG(1AQwAWwtXHGDulS5OdvZJfew7V1sd2AkoeSJAHnhDOIKLrppwq4ZIfhm9Nfhc2rDg0V7jXEW7NNf6m9abEe7zjc4HbKFwIuk6SFkPOF29JAnvRiZbq(5ksyezm1ztFzqI(PcKKH(Sw5xBpqo9SyXbt)zXHGDutp459UNe7rVFEwS4GP)SUeuyRZM(Srnj3bFwOZ0de4rS39KOSs(9ZZIfhm9Nfhc2rTr(HXZcDMEGapI9UNeLv23ppl0z6bc8i2ZseWddi)SObBnfhc2rTr(HHci)8Nfloy6pRa0rD20g5hgV7jrzL37NNf6m9abEe7zXIdM(ZYiWj6cuNnnj0bEwa4ueqJdM(ZsoCI12RzpU2lRD2dbrKGhwl71IYCbxBpfc2XAj2GNxTaGb07Q9SXA)jVESK6PET2pOdKF1c6dCoRnaDh6D12tHGDSw5mHDQQTx2QTNcb7yTYzc7Sw4S2JhOFiG51(H1ky))vl4eRTxZECTFWZg61E2yT)Kxpws9uVw7h0bYVAb9boN1(H1c9dJa04Q9SXA7PECTcB2DCyETZS2p8)yu7KLI1cp1ZseWddi)S6DThpq)uCiyh1OWovOZ0deOwt1cG0GTM6sqHToB6Zg1KChubAuRPAbqAWwtDjOWwNn9zJAsUdQcKKH(S2FPwlL1YIdMUIdb7OMEWZtHYGcWd1hKeRTNxlnyRPmcCIUa1zttcDafjlJEESGWAP4Dpjklb9(5zHotpqGhXEwS4GP)SmcCIUa1zttcDGNfaofb04GP)S6LTA71ShxRnp9)xT0i61corGAbadO3v7zJ1(tE94A)Goq(zETF4)XOwWjwl8Q9YAN9qqej4H1YETOmxW12tHGDSwIn45vl0R9SXAj4YEvs9uVw7h0bYp1ZseWddi)SObBnfhc2rTr(HHc0Owt1sd2AQa0rD20g5hgQajzOpR9xQ1szTS4GPR4qWoQPh88uOmOa8q9bjXA751sd2AkJaNOlqD20KqhqrYYONhliSwkE3tIYkNE)8SqNPhiWJyplrapmG8ZcipvWaq2p90GdcvbsYqFwR8RLaRLiIQfaPbBnvWaq2p90Gdc1sbhogmnCaV(Q5XccRv(1k5Nfloy6ploeSJA6bpV39KOSe47NNf6m9abEe7zXIdM(ZIdb7OMMJG7WNfaofb04GP)S6PXh3FwlX4i4oSw(Q9SXArhO2SvBp1R1(zJETbO7qVR2ZgRTNcb7yTY5Ybz69RDGDOdWr)NLiGhgq(zrd2AkoeSJAJ8ddfOrTMQLgS1uCiyh1g5hgQajzOpR93A7ea1AQ2a0XwgDOIdb7O2MdY07RqNPhiW7Esuw547NNf6m9abEe7zXIdM(ZIdb7OMMJG7WNfaofb04GP)S6PXh3FwlX4i4oSw(Q9SXArhO2Sv7zJ1sWL9ATFqhi)Q9Zg9Adq3HExTNnwBpfc2XALZLdY07x7a7qhGJ(plrapmG8ZIgS1ubOJ6SPnYpmuGg1AQwAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgQajzOpR9xQ12jaQ1uTbOJTm6qfhc2rTnhKP3xHotpqG39KOS9I3ppl0z6bc8i2ZsyZq)zj7Zc5y0xlSzORHTNfnyRPedKdbppO3Pf2S74qbKFUjkPbBnfhc2rTr(HHc0GiIOS3hpq)uPummYpmqatusd2AQa0rD20g5hgkqdIisK5ai)Cfknf8btxfid0NckO4zjc4HbKFwainyRPUeuyRZM(Srnj3bvGg1AQ2JhOFkoeSJAuyNk0z6bcuRPAPSwAWwtbG8ztNHJkG8ZRLiIQLfhukQrhjH4SwQ1kBTuuRPAbqAWwtDjOWwNn9zJAsUdQcKKH(Sw5xlloy6koeSJAs4Cch4uHYGcWd1hKeFwS4GP)S4qWoQjHZjCGZ39KOS9G3ppl0z6bc8i2ZseWddi)SObBnLyGCi45b9o18ybH1sTwAWwtjgihcEEqVtrYYONhliSwt1ksPOZ(PKI(z3pEwS4GP)S4qWoQjHZjCGZ39KOS9O3ppl0z6bc8i2ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWwtjgihcEEqVtfilUAnvRiZbq(5koeSJAJ8ddvGKm0N1AQwkRLgS1ubOJ6SPnYpmuGg1ser1sd2AkoeSJAJ8ddfOrTu8UNeLNKF)8SqNPhiWJyplrapmG8ZIgS1uCiyh1cBo6q18ybH1(l1ALYbKPhO6YJutYYOf2C0HZNfloy6ploeSJ6mOF3tIYt23ppl0z6bc8i2ZseWddi)SObBnva6OoBAJ8ddfOrTeruTKSZkdXvR8Rvwc8zXIdM(ZIdb7OMEWZ7Dpjkp59(5zHotpqGhXEwS4GP)SqPPGpy6plOFyeGgNg2EwKSZkdXjFQ9ac8zb9dJa040qsseaYh(SK9zjc4HbKFw0GTMkaDuNnTr(HHci)8AnvlnyRP4qWoQnYpmua5N)UNeLhb9(5zXIdM(ZIdb7OMMJG7WNf6m9abEe7DV7z1GtBO3Ptd0X49ZtIY((5zHotpqGhXEwS4GP)SqPPGpy6plaCkcOXbt)zjhyJETbO7qVRweE2yu7zJ1AzvBg1(JCqTdSdDaoG408A)WA)y)Q9YALZKM1sJTmWApBS2FYRhlPEQxR9d6a5NQw5Wjwl8QLN1oZ0RLN1sWL9AT28S2g0HtBeO2emQ9d)lfRDAG(vBcg1kS5OdNplrapmG8ZIYAdqhBz0HQdjnYGh6pomuOZ0deOwIiQwkRnaDSLrhQMqd701Zldsf6m9abQ1uT9UwPCaz6bQmc0aCm0O0SwQ1kBTuulf1AQwkRLgS1ubOJ6SPnYpmua5NxlrevRrGs1DcaLSkoeSJAAocUdRLIAnvRiZbq(5Qa0rD20g5hgQajzOpF3tIY79ZZcDMEGapI9SyXbt)zHstbFW0Fwa4ueqJdM(ZQx2Q9d)lfRTbD40gbQnbJAfzoaYpV2pOdKFZAzhO2Pb6xTjyuRWMJoCAETgbmd4bj4H1kNjnRnLIrTOum6F2qVRwCmXNLiGhgq(zD8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR1uTImha5NR4qWoQnYpmubsYqFwRPAPbBnfhc2rTr(HHci)8AnvlnyRPcqh1ztBKFyOaYpVwt1AeOuDNaqjRIdb7OMMJG7W39Kib9(5zHotpqGhXEwIaEya5Nva6ylJoubaNcOXa6C0xlsss2buOZ0deOwt1sd2Aka4uangqNJ(ArssYoGUf58uGgplwCW0FwnyGA6bpV39KOC69ZZcDMEGapI9Seb8WaYpRa0XwgDOQlGZrFnuafduHotpqGAnvlj7SYqC1k)A7re4ZIfhm9NvlY5P9uk)UNejW3ppl0z6bc8i2ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYpRa0XwgDOIdb7O2MdY07RqNPhiqTMQLgS1uCiyh12CqMEF18ybH1(BT0GTMIdb7O2MdY07Rizz0ZJfewRPAPSwkRLgS1uCiyh1g5hgkG8ZR1uTImha5NR4qWoQnYpmubYa9RLIAjIOAbqAWwtDjOWwNn9zJAsUdQanQLI39KOC89ZZcDMEGapI9Seb8WaYpRa0XwgDOAcnStxpVmivOZ0de4zXIdM(ZkaDuNnTr(HX7EsSx8(5zHotpqGhXEwIaEya5NLiZbq(5Qa0rD20g5hgQazG(plwCW0FwCiyh1zq)UNe7bVFEwOZ0de4rSNLiGhgq(zjYCaKFUkaDuNnTr(HHkqgOFTMQLgS1uCiyh1cBo6q18ybH1(BT0GTMIdb7OwyZrhQizz0ZJfe(SyXbt)zXHGDutp459UNe7rVFEwOZ0de4rSNLiGhgq(z17AdqhBz0HQdjnYGh6pomuOZ0deOwIiQwr6aGWt1bBNoB6Zg1dOWwHotpqGNfloy6plaKpB6mC8DpjkRKF)8SyXbt)zfGoQZM2i)W4zHotpqGhXE3tIYk77NNf6m9abEe7zXIdM(ZIdb7OMeoNWboFwa4ueqJdM(ZQx2Q9d)hyT8vljltTZJfeoRnB1saeqTSdu7hwRnlf9)xTGteO2EC(tT9XZ8AbNyTCTZJfew7L1AeOu0VAjbDHn07Qf0h4CwBa6o07Q9SXALZLdY07x7a7qhGJ(plrapmG8ZIgS1uIbYHGNh07ubYIRwt1sd2AkXa5qWZd6DQ5XccRLAT0GTMsmqoe88GENIKLrppwqyTMQvKsrN9tjf9ZUFuRPAfzoaYpxrcJiJPoB6lds0pvGmq)AnvBVRvkhqMEGkK0i)Wab00CeChwRPAfzoaYpxXHGDuBKFyOcKb6)UNeLvEVFEwOZ0de4rSNLiGhgq(z17AdqhBz0HQdjnYGh6pomuOZ0deOwt1szT9U2a0XwgDOAcnStxpVmivOZ0deOwIiQwkRvkhqMEGkJanahdnknRLATYwRPAPbBnfhc2rTWMJounpwqyTuRLgS1uCiyh1cBo6qfjlJEESGWAPOwkEwa4ueqJdM(ZsIzqYJr)A)WAnyyuRrEW0RfCI1(bp7A7PE18APbVAHxTFWXO2bpVAhP3vl6jyNDTTmQLop7ApBSwcUSxRLDGA7PET2pOdKFZAb9boN1gGUd9UApBSwlRAZO2FKdQDGDOdWbeNplwCW0Fwg5bt)Dpjklb9(5zHotpqGhXEwIaEya5NfnyRPcqh1ztBKFyOaYpVwIiQwJaLQ7eakzvCiyh10CeCh(SyXbt)zbG8ztNHJV7jrzLtVFEwOZ0de4rSNLiGhgq(zrd2AQa0rD20g5hgkG8ZRLiIQ1iqP6obGswfhc2rnnhb3HplwCW0Fwbdaz)0tdoi8Dpjklb((5zHotpqGhXEwIaEya5NfnyRPcqh1ztBKFyOcKKH(S2FRLYALJ1s8ALxT98AdqhBz0HQj0WoD98YGuHotpqGAP4zXIdM(ZIegrgtD20xgKOFV7jrzLJVFEwOZ0de4rSNfloy6ploeSJAJ8dJNfaofb04GP)SKdSrV2a0DO3v7zJ1kNlhKP3V2b2Hoah9nVwWjwBp1R1sJTmWA)jVECTxwlaiPrTCTnWXOFTZJfeIa1sZbhD4ZseWddi)SKYbKPhOcjnYpmqannhb3H1AQwAWwtfGoQZM2i)WqbAuRPAPSws2zLH4Q93APSw5rG1s8APSwzLCT98AfPu0z)ue2pGSxlf1srTeruT0GTMsmqoe88GENAESGWAPwlnyRPedKdbppO3Pizz0ZJfewlfV7jrz7fVFEwOZ0de4rSNLiGhgq(zjLditpqfsAKFyGaAAocUdR1uT0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTMQLgS1uCiyh1g5hgkqJNfloy6ploeSJAAocUdF3tIY2dE)8SqNPhiWJyplrapmG8ZIgS1ubOJ6SPnYpmua5NxlrevRrGs1DcaLSkoeSJAAocUdRLiIQ1iqP6obGswvWaq2p90GdcRLiIQ1iqP6obGswfaYNnDgo(SyXbt)zDjOWwNn9zJAsUd(UNeLTh9(5zHotpqGhXEwIaEya5NLrGs1DcaLSQlbf26SPpButYDWNfloy6ploeSJAJ8dJ39KO8K87NNf6m9abEe7zXIdM(ZYiWj6cuNnnj0bEwa4ueqJdM(ZsoCI12RzpU2lRD2dbrKGhwl71IYCbxBpfc2XAj2GNxTaGb07Q9SXA)jVESK6PET2pOdKF1c6dCoRnaDh6D12tHGDSw5mHDQQTx2QTNcb7yTYzc7Sw4S2JhOFiG51(H1ky))vl4eRTxZECTFWZg61E2yT)Kxpws9uVw7h0bYVAb9boN1(H1c9dJa04Q9SXA7PECTcB2DCyETZS2p8)yu7KLI1cp1ZseWddi)S6DThpq)uCiyh1OWovOZ0deOwt1cG0GTM6sqHToB6Zg1KChubAuRPAbqAWwtDjOWwNn9zJAsUdQcKKH(S2FPwlL1YIdMUIdb7OMEWZtHYGcWd1hKeRTNxlnyRPmcCIUa1zttcDafjlJEESGWAP4DpjkpzF)8SqNPhiWJyplwCW0FwgborxG6SPjHoWZcaNIaACW0Fw9YwT9A2JR1MN()RwAe9AbNiqTaGb07Q9SXA)jVECTFqhi)mV2p8)yul4eRfE1EzTZEiiIe8WAzVwuMl4A7PqWowlXg88Qf61E2yTeCzVkPEQxR9d6a5N6zjc4HbKFw0GTMIdb7O2i)WqbAuRPAPbBnva6OoBAJ8ddvGKm0N1(l1APSwwCW0vCiyh10dEEkuguaEO(GKyT98APbBnLrGt0fOoBAsOdOizz0ZJfewlfV7jr5jV3ppl0z6bc8i2ZseWddi)SaYtfmaK9tpn4GqvGKm0N1k)AjWAjIOAbqAWwtfmaK9tpn4GqTuWHJbtdhWRVAESGWALFTs(zXIdM(ZIdb7OMEWZ7Dpjkpc69ZZcDMEGapI9SyXbt)zXHGDutZrWD4ZcaNIaACW0FwYbyTFSF1EzTKmHyTtWaR9dR1MLI1IEc2zxlj7CTTmQ9SXAr)GbwBp1R1(bDG8Z8ArPOxlSv7zJb(Fw78GJrThKeRnqsg6qVR20RLGl7vvT9Y7)S20h9RLgVdJAVSwAWWR9YAj4Hrwl7a1kNjnRf2QnaDh6D1E2yTww1MrT)ihu7a7qhGdiovplrapmG8ZsK5ai)Cfhc2rTr(HHkqgOFTMQLKDwziUA)TwkRvoj5AjETuwRSsU2EETIuk6SFkc7hq2RLIAPOwt1sd2AkoeSJAHnhDOAESGWAPwlnyRP4qWoQf2C0Hkswg98ybH1AQwkRT31gGo2YOdvtOHD665LbPcDMEGa1ser1kLditpqLrGgGJHgLM1sTwzRLIAnvBVRnaDSLrhQoK0idEO)4WqHotpqGAnvBVRnaDSLrhQ4qWoQT5Gm9(k0z6bc8UNeLNC69ZZcDMEGapI9SyXbt)zXHGDutZrWD4ZcaNIaACW0FweJJG7WAN2j4aOwpVAPXAbNiqT8v7zJ1IoqTzR2EQxRf2QvotAk4dMETWzTbYa9RLN1cePHb07QvyZrhoR9dog1sYeI1cVApMqS2r6Dyu7L1sdgETNDKGD21gijdDO3vlj78ZseWddi)SObBnfhc2rTr(HHc0Owt1sd2AkoeSJAJ8ddvGKm0N1(l1A7ea1AQwrMdG8ZvO0uWhmDvGKm0NV7jr5rGVFEwOZ0de4rSNfloy6ploeSJAAocUdFwa4ueqJdM(ZIyCeChw70obha1YJpU)SwAS2ZgRDWZRwbpVAHETNnwlbx2R1(bDG8RwEw7p51JR9dog1g48YaR9SXAf2C0HZANgOFplrapmG8ZIgS1ubOJ6SPnYpmuGg1AQwAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgQajzOpR9xQ12jaQ1uT9U2a0XwgDOIdb7O2MdY07RqNPhiW7EsuEYX3ppl0z6bc8i2ZsyZq)zj7Zc5y0xlSzORHTNfnyRPedKdbppO3Pf2S74qbKFUjkPbBnfhc2rTr(HHc0GiIOS3hpq)uPummYpmqatusd2AQa0rD20g5hgkqdIisK5ai)Cfknf8btxfid0NckO4zjc4HbKFwainyRPUeuyRZM(Srnj3bvGg1AQ2JhOFkoeSJAuyNk0z6bcuRPAPSwAWwtbG8ztNHJkG8ZRLiIQLfhukQrhjH4SwQ1kBTuuRPAbqAWwtDjOWwNn9zJAsUdQcKKH(Sw5xlloy6koeSJAs4Cch4uHYGcWd1hKeFwS4GP)S4qWoQjHZjCGZ39KO86fVFEwOZ0de4rSNfloy6ploeSJAs4Cch48zbGtranoy6pREzR2p8FG1kf9ZUFyETqsseaYho6xl4eRLaiGA)SrVwbByGa1EzTEE1(XZdR1isXS2wKK12JZFEwIaEya5NLiLIo7Nsk6ND)Owt1sd2AkXa5qWZd6DQ5XccRLAT0GTMsmqoe88GENIKLrppwq47EsuE9G3ppl0z6bc8i2ZcaNIaACW0FwwhhxTGtO3vlbqa12t94A)SrV2EQxR1MN1sJOxl4ebEwIaEya5NfnyRPedKdbppO3PcKfxTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnvlL1sd2AQa0rD20g5hgkqJAjIOAPbBnfhc2rTr(HHc0OwkEwcBg6plzFwS4GP)S4qWoQjHZjCGZ39KO86rVFEwOZ0de4rSNLiGhgq(zrd2AkoeSJAHnhDOAESGWA)LATs5aY0duD5rQjzz0cBo6W5ZIfhm9Nfhc2rDg0V7jrcsYVFEwOZ0de4rSNLiGhgq(zrd2AQa0rD20g5hgkqJAjIOAjzNvgIRw5xRSe4ZIfhm9Nfhc2rn9GN37EsKGK99ZZcDMEGapI9SyXbt)zHstbFW0Fwq)WianonS9SizNvgIt(u7be4Zc6hgbOXPHKKiaKp8zj7ZseWddi)SObBnva6OoBAJ8ddfq(51AQwAWwtXHGDuBKFyOaYp)DpjsqY79ZZIfhm9Nfhc2rnnhb3Hpl0z6bc8i27E3ZkYJpy6VFEsu23ppl0z6bc8i2ZIfhm9Nfknf8bt)zbGtranoy6pl5WjwlknRf2Q9d)hyTJ8R20RLKDUw2bQvK5ai)8zTCG1Y0j4v7L1sJ1cA8Seb8WaYpRExBa6ylJounHg2PRNxgKk0z6bcuRPAjzNvgIR2FPwRuoGm9avO0uBiUAnvlL1kYCaKFU6sqHToB6Zg1KChufijd9zT)sTwwCW0vO0uWhmDfkdkapuFqsSwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1YIdMUcLMc(GPRqzqb4H6dsI1ser1szThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUkaDuNnTr(HHkqsg6ZA)LATS4GPRqPPGpy6kuguaEO(GKyTuulf1AQwAWwtfGoQZM2i)WqbKFETMQLgS1uCiyh1g5hgkG8ZR1uTainyRPUeuyRZM(Srnj3bva5NxRPA7DTgbkv3jauYQUeuyRZM(Srnj3bF3tIY79ZZcDMEGapI9Seb8WaYpRa0XwgDOAcnStxpVmivOZ0deOwt127AfPu0z)usr)S7h1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1YIdMUcLMc(GPRqzqb4H6dsIplwCW0FwO0uWhm939Kib9(5zHotpqGhXEwIaEya5Nva6ylJounHg2PRNxgKk0z6bcuRPAfPu0z)usr)S7h1AQwrMdG8ZvKWiYyQZM(YGe9tfijd9zT)sTwwCW0vO0uWhmDfkdkapuFqsSwt1kYCaKFU6sqHToB6Zg1KChufijd9zT)sTwkRvkhqMEGkY80gbkqeqF5rQP7xlXRLfhmDfknf8btxHYGcWd1hKeRL41sq1srTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATuwRuoGm9avK5PncuGiG(YJut3VwIxlloy6kuAk4dMUcLbfGhQpijwlXRLGQLINfloy6pluAk4dM(7Esuo9(5zHotpqGhXEwS4GP)S4qWoQP5i4o8zbGtranoy6plIXrWDyTWwTW7)S2dsI1EzTGtS2lpYAzhO2pSwBwkw7LzTKS3VwHnhD48zjc4HbKFwImha5NRUeuyRZM(Srnj3bvbYa9R1uTuwlnyRP4qWoQf2C0HQ5XccRv(1kLditpq1LhPMKLrlS5OdN1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1IYGcWd1hKeR1uTKSZkdXvR8RvkhqMEGk2qtcDijiPMKDwBiUAnvlnyRPcqh1ztBKFyOaYpVwkE3tIe47NNf6m9abEe7zjc4HbKFwImha5NRUeuyRZM(Srnj3bvbYa9R1uTuwlnyRP4qWoQf2C0HQ5XccRv(1kLditpq1LhPMKLrlS5OdN1AQ2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxfGoQZM2i)Wqfijd9zT)sTwuguaEO(GKyTMQvkhqMEGQdsIAq)GdnBuR8RvkhqMEGQlpsnjlJgahCFDldnBulfplwCW0FwCiyh10CeCh(UNeLJVFEwOZ0de4rSNLiGhgq(zjYCaKFU6sqHToB6Zg1KChufid0Vwt1szT0GTMIdb7OwyZrhQMhliSw5xRuoGm9avxEKAswgTWMJoCwRPAPS2Ex7Xd0pva6OoBAJ8ddf6m9abQLiIQvK5ai)Cva6OoBAJ8ddvGKm0N1k)ALYbKPhO6YJutYYObWb3x3YqhPrTuuRPALYbKPhO6GKOg0p4qZg1k)ALYbKPhO6YJutYYObWb3x3YqZg1sXZIfhm9Nfhc2rnnhb3HV7jXEX7NNf6m9abEe7zjc4HbKFwainyRPcgaY(PNgCqOwk4WXGPHd41xnpwqyTuRfaPbBnvWaq2p90Gdc1sbhogmnCaV(kswg98ybH1AQwkRLgS1uCiyh1g5hgkG8ZRLiIQLgS1uCiyh1g5hgQajzOpR9xQ12jaQLIAnvlL1sd2AQa0rD20g5hgkG8ZRLiIQLgS1ubOJ6SPnYpmubsYqFw7VuRTtaulfplwCW0FwCiyh10CeCh(UNe7bVFEwOZ0de4rSNLiGhgq(zjLditpqvpl480Gteqpn4GWAjIOAPSwaKgS1ubdaz)0tdoiulfC4yW0Wb86RanQ1uTainyRPcgaY(PNgCqOwk4WXGPHd41xnpwqyT)wlasd2AQGbGSF6PbheQLcoCmyA4aE9vKSm65XccRLINfloy6ploeSJA6bpV39Kyp69ZZcDMEGapI9Seb8WaYplAWwtze4eDbQZMMe6akqJAnvlasd2AQlbf26SPpButYDqfOrTMQfaPbBn1LGcBD20NnQj5oOkqsg6ZA)LATS4GPR4qWoQPh88uOmOa8q9bjXNfloy6ploeSJA6bpV39KOSs(9ZZcDMEGapI9Se2m0FwY(Sqog91cBg6Ay7zrd2AkXa5qWZd6DAHn7ooua5NBIsAWwtXHGDuBKFyOaniIik79Xd0pvkfdJ8ddeWeL0GTMkaDuNnTr(HHc0GiIezoaYpxHstbFW0vbYa9PGckEwIaEya5Nfasd2AQlbf26SPpButYDqfOrTMQ94b6NIdb7Ogf2PcDMEGa1AQwkRLgS1uaiF20z4Oci)8AjIOAzXbLIA0rsioRLATYwlf1AQwkRfaPbBn1LGcBD20NnQj5oOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkdkapuFqsSwIiQwrMdG8ZvgborxG6SPjHoGkqsg6ZAjIOAfPu0z)ue2pGSxlfplwCW0FwCiyh1KW5eoW57EsuwzF)8SqNPhiWJyplwCW0FwCiyh1KW5eoW5ZcaNIaACW0Fweq6tqsS2ZgRfLXGDaeOwJ8q)G8OwAWwRwEYg1EzTEE1oYjwRrEOFqEuRrKI5ZseWddi)SObBnLyGCi45b9ovGS4Q1uT0GTMcLXGDaeqBKh6hKhkqJ39KOSY79ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZIgS1uIbYHGNh07ubYIRwt1szT0GTMIdb7O2i)WqbAulrevlnyRPcqh1ztBKFyOanQLiIQfaPbBn1LGcBD20NnQj5oOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkdkapuFqsSwkE3tIYsqVFEwOZ0de4rSNfloy6ploeSJAs4Cch48zjSzO)SK9zjc4HbKFw0GTMsmqoe88GENkqwC1AQwAWwtjgihcEEqVtnpwqyTuRLgS1uIbYHGNh07uKSm65XccF3tIYkNE)8SqNPhiWJyplaCkcOXbt)z1tJpU)S2l6x7L1sZoH1saeqTTmQvK5ai)8A)Goq(nRLg8QfaK0O2ZgjRf2Q9SX()dSwMobVAVSwugdyGplrapmG8ZIgS1uIbYHGNh07ubYIRwt1sd2AkXa5qWZd6DQajzOpR9xQ1szTuwlnyRPedKdbppO3PMhliS2EETS4GPR4qWoQjHZjCGtfkdkapuFqsSwkQL412jauKSm1sXZsyZq)zj7ZIfhm9Nfhc2rnjCoHdC(UNeLLaF)8SqNPhiWJyplrapmG8ZIYAdSf40MPhyTeruT9U2dkie6D1srTMQLgS1uCiyh1cBo6q18ybH1sTwAWwtXHGDulS5OdvKSm65XccR1uT0GTMIdb7O2i)WqbKFETMQfaPbBn1LGcBD20NnQj5oOci)8Nfloy6plhpBm0hsAGZ7DpjkRC89ZZcDMEGapI9Seb8WaYplAWwtXHGDulS5OdvZJfew7VuRvkhqMEGQlpsnjlJwyZrhoFwS4GP)S4qWoQZG(DpjkBV49ZZcDMEGapI9Seb8WaYplPCaz6bQsWBcbqD20Imha5NpR1uTKSZkdXv7VuRThrGplwCW0Fwtqdm8uk)UNeLTh8(5zHotpqGhXEwIaEya5NfnyRPcWbQZM(SdeNkqJAnvlnyRP4qWoQf2C0HQ5XccRv(1sqplwCW0FwCiyh10dEEV7jrz7rVFEwOZ0de4rSNfloy6ploeSJAAocUdFwa4ueqJdM(ZsopGKg1kS5OdN1cB1(H124XOwACKF1E2yTI0NyifRLKDU2ZoWPDoaQLDGArPPGpy61cN1op4yuB61kYCaKF(ZseWddi)S6DTbOJTm6q1eAyNUEEzqQqNPhiqTMQvkhqMEGQe8MqauNnTiZbq(5ZAnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfewRPApEG(P4qWoQZGwHotpqGAnvRiZbq(5koeSJ6mOvbsYqFw7VuRTtauRPAjzNvgIR2FPwBpsY1AQwrMdG8ZvO0uWhmDvGKm0NV7jr5j53ppl0z6bc8i2ZseWddi)ScqhBz0HQj0WoD98YGuHotpqGAnvRuoGm9avj4nHaOoBArMdG8ZN1AQwAWwtXHGDulS5OdvZJfewl1APbBnfhc2rTWMJourYYONhliSwt1E8a9tXHGDuNbTcDMEGa1AQwrMdG8ZvCiyh1zqRcKKH(S2FPwBNaOwt1sYoRmexT)sT2EKKR1uTImha5NRqPPGpy6QajzOpR93Ajij)SyXbt)zXHGDutZrWD47EsuEY((5zHotpqGhXEwS4GP)S4qWoQP5i4o8zbGtranoy6pl58asAuRWMJoCwlSvBg01cN1gid0)zjc4HbKFws5aY0duLG3ecG6SPfzoaYpFwRPAPbBnfhc2rTWMJounpwqyTuRLgS1uCiyh1cBo6qfjlJEESGWAnv7Xd0pfhc2rDg0k0z6bcuRPAfzoaYpxXHGDuNbTkqsg6ZA)LATDcGAnvlj7SYqC1(l1A7rsUwt1kYCaKFUcLMc(GPRcKKH(Swt1szT9U2a0XwgDOAcnStxpVmivOZ0deOwIiQwAWwtnHg2PRNxgKQajzOpR9xQ1kBpOwkE3tIYtEVFEwOZ0de4rSNfloy6ploeSJAAocUdFwa4ueqJdM(ZQNcb7yTeJJG7WAN2j4aO2o0XGhJ(1sJ1E2yTdEE1k45vB2Q9SXA7PET2pOdKFplrapmG8ZIgS1uCiyh1g5hgkqJAnvlnyRP4qWoQnYpmubsYqFw7VuRTtauRPAPbBnfhc2rTWMJounpwqyTuRLgS1uCiyh1cBo6qfjlJEESGWAnvlL1kYCaKFUcLMc(GPRcKKH(SwIiQ2a0XwgDOIdb7O2MdY07RqNPhiqTu8UNeLhb9(5zHotpqGhXEwS4GP)S4qWoQP5i4o8zbGtranoy6pREkeSJ1smocUdRDANGdGA7qhdEm6xlnw7zJ1o45vRGNxTzR2ZgRLGl71A)Goq(9Seb8WaYplAWwtfGoQZM2i)WqbAuRPAPbBnfhc2rTr(HHci)8AnvlnyRPcqh1ztBKFyOcKKH(S2FPwBNaOwt1sd2AkoeSJAHnhDOAESGWAPwlnyRP4qWoQf2C0Hkswg98ybH1AQwkRvK5ai)Cfknf8btxfijd9zTeruTbOJTm6qfhc2rTnhKP3xHotpqGAP4Dpjkp507NNf6m9abEe7zXIdM(ZIdb7OMMJG7WNfaofb04GP)S6PqWowlX4i4oS2PDcoaQLgR9SXAh88QvWZR2Sv7zJ1(tE94A)Goq(vlSvl8QfoR1ZRwWjcu7h8SRLGl71AZO2EQxFwIaEya5NfnyRP4qWoQnYpmua5NxRPAPbBnva6OoBAJ8ddfq(51AQwaKgS1uxckS1ztF2OMK7GkqJAnvlasd2AQlbf26SPpButYDqvGKm0N1(l1A7ea1AQwAWwtXHGDulS5OdvZJfewl1APbBnfhc2rTWMJourYYONhli8Dpjkpc89ZZcDMEGapI9SyXbt)zXHGDutZrWD4ZcaNIaACW0FwYb2Ox7zJ1EC0HxTWzTqVwuguaEyTb7DyTSdu7zJbwlCwlzgyTNn71Mowl6izFZRfCI1sZrWDyT8S2zMET8S2(jyT2SuSw0tWo7Af2C0HZAVSwB4vlpg1IoscXzTWwTNnwBpfc2XAjwssZbaj6xTdSdDao6xlCwl2dbHggiWZseWddi)SKYbKPhOcjnYpmqannhb3H1AQwAWwtXHGDulS5OdvZJfewR8PwlL1YIdkf1OJKqCwBptTYwlf1AQwwCqPOgDKeIZALFTYwRPAPbBnfaYNnDgoQaYp)Dpjkp547NNf6m9abEe7zjc4HbKFws5aY0duHKg5hgiGMMJG7WAnvlnyRP4qWoQf2C0HQ5XccR93APbBnfhc2rTWMJourYYONhliSwt1YIdkf1OJKqCwR8Rv2AnvlnyRPaq(SPZWrfq(5plwCW0FwCiyh1OmgJCct)DpjkVEX7NNfloy6ploeSJA6bpVNf6m9abEe7DpjkVEW7NNf6m9abEe7zjc4HbKFws5aY0duLG3ecG6SPfzoaYpF(SyXbt)zHstbFW0F3tIYRh9(5zXIdM(ZIdb7OMMJG7WNf6m9abEe7DV7zXj((5jrzF)8SqNPhiWJyplrapmG8ZkaDSLrhQaGtb0yaDo6Rfjjj7ak0z6bcuRPAfzoaYpxrd2AAa4uangqNJ(ArssYoGkqgOFTMQLgS1uaWPaAmGoh91IKKKDaDlY5PaYpVwt1szT0GTMIdb7O2i)WqbKFETMQLgS1ubOJ6SPnYpmua5NxRPAbqAWwtDjOWwNn9zJAsUdQaYpVwkQ1uTImha5NRUeuyRZM(Srnj3bvbsYqFwl1ALCTMQLYAPbBnfhc2rTWMJounpwqyT)sTwPCaz6bQ4e1xEKAswgTWMJoCwRPAPSwkR94b6NkaDuNnTr(HHcDMEGa1AQwrMdG8ZvbOJ6SPnYpmubsYqFw7VuRTtauRPAfzoaYpxXHGDuBKFyOcKKH(Sw5xRuoGm9avxEKAswgnao4(6wgA2OwkQLiIQLYA7DThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwPCaz6bQU8i1KSmAaCW91Tm0SrTuulrevRiZbq(5koeSJAJ8ddvGKm0N1(l1A7ea1srTu8SyXbt)z1ICE054E3tIY79ZZcDMEGapI9Seb8WaYplkRnaDSLrhQaGtb0yaDo6Rfjjj7ak0z6bcuRPAfzoaYpxrd2AAa4uangqNJ(ArssYoGkqgOFTMQLgS1uaWPaAmGoh91IKKKDaDdgOci)8AnvRrGs1DcaLSQwKZJohxTuulrevlL1gGo2YOdvaWPaAmGoh91IKKKDaf6m9abQ1uThKeRLATsUwkEwS4GP)SAWa10dEEV7jrc69ZZcDMEGapI9Seb8WaYpRa0XwgDOQlGZrFnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)AjijxRPAfzoaYpxDjOWwNn9zJAsUdQcKKH(SwQ1k5AnvlL1sd2AkoeSJAHnhDOAESGWA)LATs5aY0duXjQV8i1KSmAHnhD4Swt1szTuw7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NRcqh1ztBKFyOcKKH(S2FPwBNaOwt1kYCaKFUIdb7O2i)Wqfijd9zTYVwPCaz6bQU8i1KSmAaCW91Tm0SrTuulrevlL127ApEG(Pcqh1ztBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4G7RBzOzJAPOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12jaQLIAP4zXIdM(ZQf580EkLF3tIYP3ppl0z6bc8i2ZseWddi)ScqhBz0HQUaoh91qbumqf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwl1ALCTMQLYAPSwkRvK5ai)C1LGcBD20NnQj5oOkqsg6ZALFTs5aY0duXgAswgnao4(6wg6lpYAnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfewlf1ser1szTImha5NRUeuyRZM(Srnj3bvbsYqFwl1ALCTMQLgS1uCiyh1cBo6q18ybH1(l1ALYbKPhOItuF5rQjzz0cBo6WzTuulf1AQwAWwtfGoQZM2i)WqbKFETu8SyXbt)z1ICEApLYV7jrc89ZZcDMEGapI9SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZsKsrN9try)aYETMQnaDSLrhQ4qWoQT5Gm9(k0z6bcuRPAPbBnfhc2rTnhKP3xnpwqyT)wRSeyTMQvK5ai)CvWaq2p90GdcvbsYqFw7VuRvkhqMEGkBoitVVEESGq9bjXAjETOmOa8q9bjXAnvRiZbq(5Qlbf26SPpButYDqvGKm0N1(l1ALYbKPhOYMdY07RNhliuFqsSwIxlkdkapuFqsSwIxlloy6QGbGSF6PbheQqzqb4H6dsI1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1kLditpqLnhKP3xppwqO(GKyTeVwuguaEO(GKyTeVwwCW0vbdaz)0tdoiuHYGcWd1hKeRL41YIdMU6sqHToB6Zg1KChuHYGcWd1hKeF3tIYX3ppl0z6bc8i2ZseWddi)SePu0z)usr)S7h1AQ2JhOFkoeSJAuyNk0z6bcuRPApijw7V1kRKR1uTImha5NRiHrKXuNn9Lbj6Nkqsg6ZAnvlnyRPedKdbppO3PMhliS2FRLGEwS4GP)S4qWoQPh88E3tI9I3ppl0z6bc8i2ZseWddi)ScqhBz0HQj0WoD98YGuHotpqGAnvRrGs1DcaLSkuAk4dM(ZIfhm9N1LGcBD20NnQj5o47EsSh8(5zHotpqGhXEwIaEya5Nva6ylJounHg2PRNxgKk0z6bcuRPAPSwJaLQ7eakzvO0uWhm9AjIOAncuQUtaOKvDjOWwNn9zJAsUdwlfplwCW0FwCiyh1g5hgV7jXE07NNf6m9abEe7zjc4HbKFwImha5NR4qWoQnYpmubsYqFw7VuRThuRPAfzoaYpxDjOWwNn9zJAsUdQcKKH(S2FPwBpOwt1szT0GTMIdb7OwyZrhQMhliS2FPwRuoGm9avCI6lpsnjlJwyZrhoR1uTuwlL1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR9xQ12jaQ1uTImha5NR4qWoQnYpmubsYqFwR8RLaRLIAjIOAPS2Ex7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwR8RLaRLIAjIOAfzoaYpxXHGDuBKFyOcKKH(S2FPwBNaOwkQLINfloy6plsyezm1ztFzqI(9UNeLvYVFEwOZ0de4rSNLiGhgq(zDqsSw5xlbj5AnvBa6ylJounHg2PRNxgKk0z6bcuRPAfPu0z)usr)S7h1AQwJaLQ7eakzvKWiYyQZM(YGe97zXIdM(ZcLMc(GP)UNeLv23ppl0z6bc8i2ZseWddi)SoijwR8RLGKCTMQnaDSLrhQMqd701Zldsf6m9abQ1uT0GTMIdb7OwyZrhQMhliS2FPwRuoGm9avCI6lpsnjlJwyZrhoR1uTImha5NRUeuyRZM(Srnj3bvbsYqFwl1ALCTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATDcGNfloy6pluAk4dM(7Esuw59(5zHotpqGhXEwS4GP)SqPPGpy6plOFyeGgNg2Ew0GTMAcnStxpVmivZJfesLgS1utOHD665LbPIKLrppwq4Zc6hgbOXPHKKiaKp8zj7ZseWddi)SoijwR8RLGKCTMQnaDSLrhQMqd701Zldsf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwl1ALCTMQLYAPSwkRvK5ai)C1LGcBD20NnQj5oOkqsg6ZALFTs5aY0duXgAswgnao4(6wg6lpYAnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfewlf1ser1szTImha5NRUeuyRZM(Srnj3bvbsYqFwl1ALCTMQLgS1uCiyh1cBo6q18ybH1(l1ALYbKPhOItuF5rQjzz0cBo6WzTuulf1AQwAWwtfGoQZM2i)WqbKFETu8UNeLLGE)8SqNPhiWJyplrapmG8ZsK5ai)C1LGcBD20NnQj5oOkqsg6ZA)TwuguaEO(GKyTMQLYAPS2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxfGoQZM2i)Wqfijd9zT)sT2obqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4G7RBzOzJAPOwIiQwkRT31E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)ALYbKPhO6YJutYYObWb3x3YqZg1srTeruTImha5NR4qWoQnYpmubsYqFw7VuRTtaulfplwCW0Fwbdaz)0tdoi8DpjkRC69ZZcDMEGapI9Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR93Arzqb4H6dsI1AQwkRLYAPSwrMdG8ZvxckS1ztF2OMK7GQajzOpRv(1kLditpqfBOjzz0a4G7RBzOV8iR1uT0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTuulrevlL1kYCaKFU6sqHToB6Zg1KChufijd9zTuRvY1AQwAWwtXHGDulS5OdvZJfew7VuRvkhqMEGkor9LhPMKLrlS5OdN1srTuuRPAPbBnva6OoBAJ8ddfq(51sXZIfhm9NvWaq2p90GdcF3tIYsGVFEwOZ0de4rSNLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zTuRvY1AQwkRLYAPSwrMdG8ZvxckS1ztF2OMK7GQajzOpRv(1kLditpqfBOjzz0a4G7RBzOV8iR1uT0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTuulrevlL1kYCaKFU6sqHToB6Zg1KChufijd9zTuRvY1AQwAWwtXHGDulS5OdvZJfew7VuRvkhqMEGkor9LhPMKLrlS5OdN1srTuuRPAPbBnva6OoBAJ8ddfq(51sXZIfhm9NfaYNnDgo(UNeLvo((5zHotpqGhXEwIaEya5NfL1sd2AkoeSJAHnhDOAESGWA)LATs5aY0duXjQV8i1KSmAHnhD4SwIiQwJaLQ7eakzvbdaz)0tdoiSwkQ1uTuwlL1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR9xQ12jaQ1uTImha5NR4qWoQnYpmubsYqFwR8RvkhqMEGQlpsnjlJgahCFDldnBulf1ser1szT9U2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(Sw5xRuoGm9avxEKAswgnao4(6wgA2OwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATDcGAP4zXIdM(Z6sqHToB6Zg1KCh8DpjkBV49ZZcDMEGapI9Seb8WaYplkRLYAfzoaYpxDjOWwNn9zJAsUdQcKKH(Sw5xRuoGm9avSHMKLrdGdUVULH(YJSwt1sd2AkoeSJAHnhDOAESGWAPwlnyRP4qWoQf2C0Hkswg98ybH1srTeruTuwRiZbq(5Qlbf26SPpButYDqvGKm0N1sTwjxRPAPbBnfhc2rTWMJounpwqyT)sTwPCaz6bQ4e1xEKAswgTWMJoCwlf1srTMQLgS1ubOJ6SPnYpmua5N)SyXbt)zXHGDuBKFy8UNeLTh8(5zHotpqGhXEwIaEya5NfnyRPcqh1ztBKFyOaYpVwt1szTuwRiZbq(5Qlbf26SPpButYDqvGKm0N1k)ALNKR1uT0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTuulrevlL1kYCaKFU6sqHToB6Zg1KChufijd9zTuRvY1AQwAWwtXHGDulS5OdvZJfew7VuRvkhqMEGkor9LhPMKLrlS5OdN1srTuuRPAPSwrMdG8ZvCiyh1g5hgQajzOpRv(1kR8QLiIQfaPbBn1LGcBD20NnQj5oOc0OwkEwS4GP)Scqh1ztBKFy8UNeLTh9(5zHotpqGhXEwIaEya5NLiZbq(5koeSJ6mOvbsYqFwR8RLaRLiIQT31E8a9tXHGDuNbTcDMEGaplwCW0FwtBy7GEN2i)W4Dpjkpj)(5zHotpqGhXEwIaEya5NLiLIo7NIW(bK9AnvBa6ylJouXHGDuBZbz69vOZ0deOwt1sd2AkoeSJAJ8ddfOrTMQfaPbBnvWaq2p90Gdc1sbhogmnCaV(Q5XccRLATYPAnvRrGs1DcaLSkoeSJ6mOR1uTS4Gsrn6ijeN1(BT9INfloy6ploeSJA6bpV39KO8K99ZZcDMEGapI9Seb8WaYplrkfD2pfH9di71AQ2a0XwgDOIdb7O2MdY07RqNPhiqTMQLgS1uCiyh1g5hgkqJAnvlasd2AQGbGSF6PbheQLcoCmyA4aE9vZJfewl1ALtplwCW0FwCiyh10CeCh(UNeLN8E)8SqNPhiWJyplrapmG8ZsKsrN9try)aYETMQnaDSLrhQ4qWoQT5Gm9(k0z6bcuRPAPbBnfhc2rTr(HHc0Owt1szTa5PcgaY(PNgCqOkqsg6ZALFTYXAjIOAbqAWwtfmaK9tpn4GqTuWHJbtdhWRVc0OwkQ1uTainyRPcgaY(PNgCqOwk4WXGPHd41xnpwqyT)wRCQwt1YIdkf1OJKqCwl1AjONfloy6ploeSJA6bpV39KO8iO3ppl0z6bc8i2ZseWddi)SePu0z)ue2pGSxRPAdqhBz0HkoeSJABoitVVcDMEGa1AQwAWwtXHGDuBKFyOanQ1uTainyRPcgaY(PNgCqOwk4WXGPHd41xnpwqyTuRLGEwS4GP)S4qWoQZG(Dpjkp507NNf6m9abEe7zjc4HbKFwIuk6SFkc7hq2R1uTbOJTm6qfhc2rTnhKP3xHotpqGAnvlnyRP4qWoQnYpmuGg1AQwaKgS1ubdaz)0tdoiulfC4yW0Wb86RMhliSwQ1kVNfloy6ploeSJAAocUdF3tIYJaF)8SqNPhiWJyplrapmG8ZsKsrN9try)aYETMQnaDSLrhQ4qWoQT5Gm9(k0z6bcuRPAPbBnfhc2rTr(HHc0Owt1AeOuDNaqjpvWaq2p90GdcR1uTS4Gsrn6ijeN1k)AjONfloy6ploeSJAugJroHP)UNeLNC89ZZcDMEGapI9Seb8WaYplrkfD2pfH9di71AQ2a0XwgDOIdb7O2MdY07RqNPhiqTMQLgS1uCiyh1g5hgkqJAnvlasd2AQGbGSF6PbheQLcoCmyA4aE9vZJfewl1ALTwt1YIdkf1OJKqCwR8RLGEwS4GP)S4qWoQrzmg5eM(7EsuE9I3ppl0z6bc8i2ZseWddi)SObBnfaYNnDgoQanQ1uTainyRPUeuyRZM(Srnj3bvGg1AQwaKgS1uxckS1ztF2OMK7GQajzOpR9xQ1sd2AkJaNOlqD20KqhqrYYONhliS2EETS4GPR4qWoQPh88uOmOa8q9bjXAnvlL1szThpq)ubotNDbQqNPhiqTMQLfhukQrhjH4S2FRvovlf1ser1YIdkf1OJKqCw7V1sG1srTMQLYA7DTbOJTm6qfhc2rnDssZbaj6NcDMEGa1ser1EC0HNYg5XzRmexTYVwcIaRLINfloy6plJaNOlqD20Kqh4DpjkVEW7NNf6m9abEe7zjc4HbKFw0GTMca5ZModhvGg1AQwkRLYApEG(PcCMo7cuHotpqGAnvlloOuuJoscXzT)wRCQwkQLiIQLfhukQrhjH4S2FRLaRLIAnvlL127AdqhBz0HkoeSJA6KKMdas0pf6m9abQLiIQ94OdpLnYJZwziUALFTeebwlfplwCW0FwCiyh10dEEV7jr51JE)8SyXbt)znbnWWtP8ZcDMEGapI9UNejij)(5zHotpqGhXEwIaEya5NfnyRP4qWoQf2C0HQ5XccRv(uRLYAzXbLIA0rsioRTNPwzRLIAnvBa6ylJouXHGDutNK0CaqI(PqNPhiqTMQ94OdpLnYJZwziUA)TwcIaFwS4GP)S4qWoQP5i4o8DpjsqY((5zHotpqGhXEwIaEya5NfnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfe(SyXbt)zXHGDutZrWD47EsKGK37NNf6m9abEe7zjc4HbKFw0GTMIdb7OwyZrhQMhliSwQ1k5AnvlL1kYCaKFUIdb7O2i)Wqfijd9zTYVwzjWAjIOA7DTuwRiLIo7NIW(bK9AnvBa6ylJouXHGDuBZbz69vOZ0deOwkQLINfloy6ploeSJ6mOF3tIeeb9(5zHotpqGhXEwIaEya5NfL1gylWPntpWAjIOA7DThuqi07QLIAnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfe(SyXbt)z54zJH(qsdCEV7jrcso9(5zHotpqGhXEwIaEya5NfnyRPedKdbppO3PcKfxTMQnaDSLrhQ4qWoQT5Gm9(k0z6bcuRPAPSwkR94b6NIjngWguWhmDf6m9abQ1uTS4Gsrn6ijeN1(BT9GAPOwIiQwwCqPOgDKeIZA)TwcSwkEwS4GP)S4qWoQjHZjCGZ39KibrGVFEwOZ0de4rSNLiGhgq(zrd2AkXa5qWZd6DQazXvRPApEG(P4qWoQrHDQqNPhiqTMQfaPbBn1LGcBD20NnQj5oOc0Owt1szThpq)umPXa2Gc(GPRqNPhiqTeruTS4Gsrn6ijeN1(BT9OAP4zXIdM(ZIdb7OMeoNWboF3tIeKC89ZZcDMEGapI9Seb8WaYplAWwtjgihcEEqVtfilUAnv7Xd0pftAmGnOGpy6k0z6bcuRPAzXbLIA0rsioR93ALtplwCW0FwCiyh1KW5eoW57EsKG6fVFEwOZ0de4rSNLiGhgq(zrd2AkoeSJAHnhDOAESGWA)TwAWwtXHGDulS5OdvKSm65XccFwS4GP)S4qWoQrzmg5eM(7EsKG6bVFEwOZ0de4rSNLiGhgq(zrd2AkoeSJAHnhDOAESGWAPwlnyRP4qWoQf2C0Hkswg98ybH1AQwJaLQ7eakzvCiyh10CeCh(SyXbt)zXHGDuJYymYjm939Kib1JE)8SG(HraACAy7zrYoRmeN8P2diWNf0pmcqJtdjjraiF4Zs2Nfloy6pluAk4dM(ZcDMEGapI9U39SaWgdoU3ppjk77NNfloy6plrc6hgtdCmEwOZ0de4rS39KO8E)8SqNPhiWJyplrapmG8ZIYApEG(PqFa7Sp0raf6m9abQ1uTKSZkdXv7VuRThi5Anvlj7SYqC1kFQ1khjWAPOwIiQwkRT31E8a9tH(a2zFOJak0z6bcuRPAjzNvgIR2FPwBpGaRLINfloy6pls2zDhs(UNejO3ppl0z6bc8i2ZseWddi)SObBnfhc2rTr(HHc04zXIdM(ZYipy6V7jr507NNf6m9abEe7zjc4HbKFwbOJTm6q1HKgzWd9hhgk0z6bcuRPAPbBnfkJndopy6kqJAnvlL1kYCaKFUIdb7O2i)Wqfid0VwIiQw6CoR1uTnyN9PdKKH(S2FPwRCsY1sXZIfhm9N1bjr9hhgV7jrc89ZZcDMEGapI9Seb8WaYplAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgkG8ZR1uTainyRPUeuyRZM(Srnj3bva5N)SyXbt)znGD23u3Zcc0rI(9UNeLJVFEwOZ0de4rSNLiGhgq(zrd2AkoeSJAJ8ddfq(51AQwAWwtfGoQZM2i)WqbKFETMQfaPbBn1LGcBD20NnQj5oOci)8Nfloy6plAUtNn9fqbHZ39KyV49ZZcDMEGapI9Seb8WaYplAWwtXHGDuBKFyOanEwS4GP)SOXyIbHqV7Dpj2dE)8SqNPhiWJyplrapmG8ZIgS1uCiyh1g5hgkqJNfloy6pl6rMa6gy0)Dpj2JE)8SqNPhiWJyplrapmG8ZIgS1uCiyh1g5hgkqJNfloy6pRgmq6rMaV7jrzL87NNf6m9abEe7zjc4HbKFw0GTMIdb7O2i)WqbA8SyXbt)zXUaNxWdTGhJ39KOSY((5zHotpqGhXEwIaEya5NfnyRP4qWoQnYpmuGgplwCW0FwGtudpKC(UNeLvEVFEwOZ0de4rSNfloy6pRUbda5lJPMMb6WNLiGhgq(zrd2AkoeSJAJ8ddfOrTeruTImha5NR4qWoQnYpmubsYqFwR8PwlbsG1AQwaKgS1uxckS1ztF2OMK7GkqJNf2AO40otIpRUbda5lJPMMb6W39KOSe07NNf6m9abEe7zXIdM(Zcjn6hip0za4SlWNLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)sTwzjWAnvRiZbq(5Qlbf26SPpButYDqvGKm0N1(l1ALLaFwotIplK0OFG8qNbGZUaF3tIYkNE)8SqNPhiWJyplwCW0FwabYanyGAP4CIJNLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zTYNATYtY1ser127ALYbKPhOIn0PRbNyTuRv2AjIOAPS2dsI1sTwjxRPALYbKPhOQbN2qVtNgOJrTuRv2AnvBa6ylJounHg2PRNxgKk0z6bculfplNjXNfqGmqdgOwkoN44Dpjklb((5zHotpqGhXEwS4GP)SMj4qd7C4HXZseWddi)SezoaYpxXHGDuBKFyOcKKH(Sw5tTwcsY1ser127ALYbKPhOIn0PRbNyTuRv2NLZK4ZAMGdnSZHhgV7jrzLJVFEwOZ0de4rSNfloy6pRUrFdBD208CcjHd(GP)Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpRv(uRvEsUwIiQ2ExRuoGm9avSHoDn4eRLATYwlrevlL1EqsSwQ1k5AnvRuoGm9avn40g6D60aDmQLATYwRPAdqhBz0HQj0WoD98YGuHotpqGAP4z5mj(S6g9nS1ztZZjKeo4dM(7Esu2EX7NNf6m9abEe7zXIdM(ZIKfmDG6PnINMeCcfplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)LATeyTMQLYA7DTs5aY0du1GtBO3Ptd0XOwQ1kBTeruThKeRv(1sqsUwkEwotIplswW0bQN2iEAsWju8UNeLTh8(5zHotpqGhXEwS4GP)SizbthOEAJ4PjbNqXZseWddi)SezoaYpxXHGDuBKFyOcKKH(S2FPwlbwRPALYbKPhOQbN2qVtNgOJrTuRv2AnvlnyRPcqh1ztBKFyOanQ1uT0GTMkaDuNnTr(HHkqsg6ZA)LATuwRSsU2EMAjWA751gGo2YOdvtOHD665LbPcDMEGa1srTMQ9GKyT)wlbj5NLZK4ZIKfmDG6PnINMeCcfV7jrz7rVFEwOZ0de4rSNfloy6pRPndKFiGodAD20xgKOFplrapmG8Z6GKyTuRvY1ser1szTs5aY0duLG3ecG6SPfzoaYpFwRPAPSwkRvKsrN9try)aYETMQvK5ai)CvWaq2p90GdcvbsYqFw7VuRvE1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1sG1AQwrMdG8ZvxckS1ztF2OMK7GQajzOpR9xQ1sG1srTeruTImha5NR4qWoQnYpmubsYqFw7VuRvE1ser12GD2Noqsg6ZA)TwrMdG8ZvCiyh1g5hgQajzOpRLIAP4z5mj(SM2mq(Ha6mO1ztFzqI(9UNeLNKF)8SqNPhiWJyplwCW0FwcEm0S4GPRhW59SgW5PDMeFwcEiah8btF(UNeLNSVFEwOZ0de4rSNLiGhgq(zXIdkf1OJKqCwR8PwRuoGm9avCI6JJo80Ie0VN18cO4Esu2Nfloy6plbpgAwCW01d48Ewd480otIploX39KO8K37NNf6m9abEe7zjc4HbKFwIuk6SFkc7hq2R1uTbOJTm6qfhc2rTnhKP3xHotpqGNfloy6plbpgAwCW01d48Ewd480otIplBoitV)7EsuEe07NNf6m9abEe7zjc4HbKFws5aY0duzZsrDAGocul1ALCTMQvkhqMEGQgCAd9oDAGog1AQ2ExlL1ksPOZ(PiSFazVwt1gGo2YOdvCiyh12CqMEFf6m9abQLINfloy6plbpgAwCW01d48Ewd480otIpRgCAd9oDAGogV7jr5jNE)8SqNPhiWJyplrapmG8ZskhqMEGkBwkQtd0rGAPwRKR1uT9UwkRvKsrN9try)aYETMQnaDSLrhQ4qWoQT5Gm9(k0z6bculfplwCW0FwcEm0S4GPRhW59SgW5PDMeFwPb6y8UNeLhb((5zHotpqGhXEwIaEya5NvVRLYAfPu0z)ue2pGSxRPAdqhBz0HkoeSJABoitVVcDMEGa1sXZIfhm9NLGhdnloy66bCEpRbCEANjXNLiZbq(5Z39KO8KJVFEwOZ0de4rSNLiGhgq(zjLditpqvd68qtdgETuRvY1AQ2ExlL1ksPOZ(PiSFazVwt1gGo2YOdvCiyh12CqMEFf6m9abQLINfloy6plbpgAwCW01d48Ewd480otIpRip(GP)UNeLxV49ZZcDMEGapI9Seb8WaYplPCaz6bQAqNhAAWWRLATYwRPA7DTuwRiLIo7NIW(bK9AnvBa6ylJouXHGDuBZbz69vOZ0deOwkEwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SAqNhAAWWF37EwgbkssA(E)8KOSVFEwS4GP)S4qWoQH(HJbkUNf6m9abEe7DpjkV3pplwCW0FwtqsY01Ciyh1nMeoGC8SqNPhiWJyV7jrc69ZZIfhm9NLi9EwWa1KSZ6oK8zHotpqGhXE3tIYP3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwCI6JJo80Ie0VNfa2yWX9SiO39Kib((5zHotpqGhXEwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZcLMAdX9SaWgdoUNLSe47Esuo((5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5q7mj(Smc0aCm0O08zjc4HbKFwuwBa6ylJounHg2PRNxgKk0z6bcuRPAPSwrkfD2pLu0p7(rTeruTIuk6SFkhfroYaOwIiQwr6aGWtXHGDuBejaSRVcDMEGa1srTu8SKYdquJJj(SK8ZskpaXNLSV7jXEX7NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLdTZK4ZYMLI60aDe4zjc4HbKFwS4Gsrn6ijeN1kFQ1kLditpqfNO(4OdpTib97zjLhGOght8zj5NLuEaIplzF3tI9G3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLKFws5q7mj(SAqNhAAWWF3tI9O3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFw2CqMEF98ybH6dsIplaSXGJ7z1JE3tIYk53ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFw84J7p1Z(UqlYCaKF(8zbGngCCplj)UNeLv23ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwXutYYObWb3x3YqF5r(SaWgdoUNfb(UNeLvEVFEwOZ0de4rSNvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SIPMKLrdGdUVULHosJNfa2yWX9SiW39KOSe07NNf6m9abEe7zLgpRaN49SyXbt)zjLditpWNLuo0otIpRyQjzz0a4G7RBzOzJNfa2yWX9SKNKF3tIYkNE)8SqNPhiWJypR04zf4eVNfloy6plPCaz6b(SKYH2zs8zrMN2iqbIa6lpsnD)Nfa2yWX9S6bV7jrzjW3ppl0z6bc8i2ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwK5Pjzz0a4G7RBzOV8iFwayJbh3Zswj)UNeLvo((5zHotpqGhXEwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZImpnjlJgahCFDldnB8SaWgdoUNLSe47Esu2EX7NNf6m9abEe7zLgpRaN49SyXbt)zjLditpWNLuo0otIpl2qtYYObWb3x3YqF5r(Seb8WaYplr6aGWtXHGDuBejaSR)ZskparnoM4Zswj)SKYdq8zrqs(DpjkBp49ZZcDMEGapI9SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfBOjzz0a4G7RBzOV8iFwayJbh3ZsEs(DpjkBp69ZZcDMEGapI9SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfBOjzz0a4G7RBzOjZ7zbGngCCpl5j539KO8K87NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsEsU2EMAPSwcS2EETI0baHNIdb7O2isayxFf6m9abQLINLuo0otIpRin0KSmAaCW91Tm0xEKV7jr5j77NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLhG4ZIaRL41kpjxBpVwkRvKsrN9t5Wo7t3ySwIiQwkRvKoai8uCiyh1grca76RqNPhiqTMQLfhukQrhjH4S2FRvkhqMEGkor9XrhEArc6xTuulf1s8ALLaRTNxlL1ksPOZ(PiSFazVwt1gGo2YOdvCiyh12CqMEFf6m9abQ1uTS4Gsrn6ijeN1kFQ1kLditpqfNO(4OdpTib9RwkEws5q7mj(SU8i1KSmAaCW91Tm0SX7EsuEY79ZZcDMEGapI9SsJN1eVNfloy6plPCaz6b(SKYdq8zjpjxBptTuwBpO2EETI0baHNIdb7O2isayxFf6m9abQLINLuo0otIpRlpsnjlJgahCFDldDKgV7jr5rqVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIpl5OKRTNPwkRLKNhg91s5biwBpVwzLSKRLINLiGhgq(zjsPOZ(PCyN9PBm(SKYH2zs8zrZrWDOMKDwBiU39KO8KtVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIpREebwBptTuwljppm6RLYdqS2EETYkzjxlfplrapmG8ZsKsrN9try)aY(ZskhANjXNfnhb3HAs2zTH4E3tIYJaF)8SqNPhiWJypR04znX7zXIdM(ZskhqMEGplP8aeFw9ajxBptTuwljppm6RLYdqS2EETYkzjxlfplrapmG8ZskhqMEGkAocUd1KSZAdXvl1AL8ZskhANjXNfnhb3HAs2zTH4E3tIYto((5zHotpqGhXEwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZIn0KqhscsQjzN1gI7zbGngCCplzjW39KO86fVFEwOZ0de4rSNvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SU8i1KSmAHnhD48zbGngCCpl59UNeLxp49ZZcDMEGapI9SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfNO(YJutYYOf2C0HZNfa2yWX9SK37EsuE9O3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLS12ZRLYAXEii0WabuiPr)a5HodaNDbwlrevlL1E8a9tfGoQZM2i)WqHotpqGAnvlL1E8a9tXHGDuJc7uHotpqGAjIOA7DTIuk6SFkc7hq2RLIAnvlL127AfPu0z)uokICKbqTeruTS4Gsrn6ijeN1sTwzRLiIQnaDSLrhQMqd701Zldsf6m9abQLIAnvBVRvKsrN9tjf9ZUFulf1sXZskhANjXNvdoTHENonqhJ39Kibj53ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNf2dbHggiGIKfmDG6PnINMeCcf1ser1I9qqOHbcO6gmaKVmMAAgOdRLiIQf7HGqddeq1nyaiFzm1KiapgW0RLiIQf7HGqddeqbWbHKz6AauqO2a8cCkqxG1ser1I9qqOHbcOG(ueGhtpqDpeK9dKudGsHcSwIiQwShccnmqa1mbhd8oO3Pdq6(1ser1I9qqOHbcOMGo9itantIND)5vlrevl2dbHggiG6JjeDmM6wKoqTeruTypeeAyGaQ2GjrD2008Dd8zjLdTZK4ZIn0PRbN47EsKGK99ZZIfhm9NfjmIm0qsUdFwOZ0de4rS39KibjV3ppl0z6bc8i2ZseWddi)SMj4Gg6akP5Gp4a1ZCif9tHotpqGAjIOANj4Gg6akdW5boqngGghmDf6m9abEwS4GP)SAdCAlcUDV7jrcIGE)8SqNPhiWJyplrapmG8ZsKsrN9try)aYETMQnaDSLrhQ4qWoQT5Gm9(k0z6bcuRPAfPdacpfhc2rTrKaWU(k0z6bcuRPALYbKPhOIhFC)PE23fArMdG8ZN1AQwwCqPOgDKeIZA)TwPCaz6bQ4e1hhD4PfjOFplwCW0FwbOJ6SPnYpmE3tIeKC69ZZcDMEGapI9Seb8WaYpRExRuoGm9avgbAaogAuAwl1ALTwt1gGo2YOdvaWPaAmGoh91IKKKDaf6m9abEwS4GP)SArop6CCV7jrcIaF)8SqNPhiWJyplrapmG8ZQ31kLditpqLrGgGJHgLM1sTwzR1uT9U2a0XwgDOcaofqJb05OVwKKKSdOqNPhiqTMQLYA7DTIuk6SFkPOF29JAjIOALYbKPhOQbN2qVtNgOJrTu8SyXbt)zXHGDutp459UNeji547NNf6m9abEe7zjc4HbKFw9UwPCaz6bQmc0aCm0O0SwQ1kBTMQT31gGo2YOdvaWPaAmGoh91IKKKDaf6m9abQ1uTIuk6SFkPOF29JAnvBVRvkhqMEGQgCAd9oDAGogplwCW0FwKWiYyQZM(YGe97Dpjsq9I3ppl0z6bc8i2ZseWddi)SKYbKPhOYiqdWXqJsZAPwRSplwCW0FwO0uWhm939UNLiZbq(5Z3ppjk77NNf6m9abEe7zXIdM(ZQf580EkLFwa4ueqJdM(ZQxdygWdsWdRfCc9UA7c4C0VwOakgyTFWZUw2qvRC4eRfE1(bp7AV8iRnpBm(Gtu9Seb8WaYpRa0XwgDOQlGZrFnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)AjijxRPAfzoaYpxDjOWwNn9zJAsUdQcKb6xRPAPSwAWwtXHGDulS5OdvZJfew7VuRvkhqMEGQlpsnjlJwyZrhoR1uTuwlL1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR9xQ12jaQ1uTImha5NR4qWoQnYpmubsYqFwR8RvkhqMEGQlpsnjlJgahCFDldnBulf1ser1szT9U2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(Sw5xRuoGm9avxEKAswgnao4(6wgA2OwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATDcGAPOwkE3tIY79ZZcDMEGapI9Seb8WaYpRa0XwgDOQlGZrFnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGmq)AnvlL127ApEG(PqFa7Sp0raf6m9abQLiIQLYApEG(PqFa7Sp0raf6m9abQ1uTKSZkdXvR8PwBVqY1srTuuRPAPSwkRvK5ai)C1LGcBD20NnQj5oOkqsg6ZALFTYk5AnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfewlf1ser1szTImha5NRUeuyRZM(Srnj3bvbsYqFwl1ALCTMQLgS1uCiyh1cBo6q18ybH1sTwjxlf1srTMQLgS1ubOJ6SPnYpmua5NxRPAjzNvgIRw5tTwPCaz6bQydnj0HKGKAs2zTH4EwS4GP)SAropTNs539Kib9(5zHotpqGhXEwIaEya5Nva6ylJoubaNcOXa6C0xlsss2buOZ0deOwt1kYCaKFUIgS10aWPaAmGoh91IKKKDavGmq)AnvlnyRPaGtb0yaDo6Rfjjj7a6wKZtbKFETMQLYAPbBnfhc2rTr(HHci)8AnvlnyRPcqh1ztBKFyOaYpVwt1cG0GTM6sqHToB6Zg1KChubKFETuuRPAfzoaYpxDjOWwNn9zJAsUdQcKKH(SwQ1k5AnvlL1sd2AkoeSJAHnhDOAESGWA)LATs5aY0duD5rQjzz0cBo6WzTMQLYAPS2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxfGoQZM2i)Wqfijd9zT)sT2obqTMQvK5ai)Cfhc2rTr(HHkqsg6ZALFTs5aY0duD5rQjzz0a4G7RBzOzJAPOwIiQwkRT31E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1k)ALYbKPhO6YJutYYObWb3x3YqZg1srTeruTImha5NR4qWoQnYpmubsYqFw7VuRTtaulf1sXZIfhm9NvlY5rNJ7DpjkNE)8SqNPhiWJyplrapmG8ZkaDSLrhQaGtb0yaDo6Rfjjj7ak0z6bcuRPAfzoaYpxrd2AAa4uangqNJ(ArssYoGkqgOFTMQLgS1uaWPaAmGoh91IKKKDaDdgOci)8AnvRrGs1DcaLSQwKZJoh3ZIfhm9NvdgOMEWZ7DpjsGVFEwOZ0de4rSNfloy6plsyezm1ztFzqI(9SaWPiGghm9NvVYWO2EC(tTFWZU2EQxRf2QfE)N1kssO3vlOrTZmDvT9YwTWR2p4yulnwl4ebQ9dE21(tE9yZRvWZRw4v7Ca7SVr)APXwg4ZseWddi)SOS2ExBa6ylJounHg2PRNxgKk0z6bculrevlnyRPMqd701ZldsfOrTuuRPAfzoaYpxDjOWwNn9zJAsUdQcKKH(S2FRvkhqMEGkY80gbkqeqF5rQP7xlrevlL1kLditpq1bjrnOFWHMnQv(1kLditpqfzEAswgnao4(6wgA2Owt1kYCaKFU6sqHToB6Zg1KChufijd9zTYVwPCaz6bQiZttYYObWb3x3YqF5rwlfV7jr547NNf6m9abEe7zjc4HbKFwImha5NR4qWoQnYpmubYa9R1uTuwBVR94b6Nc9bSZ(qhbuOZ0deOwIiQwkR94b6Nc9bSZ(qhbuOZ0deOwt1sYoRmexTYNAT9cjxlf1srTMQLYAPSwrMdG8ZvxckS1ztF2OMK7GQajzOpRv(1kLditpqfBOjzz0a4G7RBzOV8iR1uT0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTuulrevlL1kYCaKFU6sqHToB6Zg1KChufijd9zTuRvY1AQwAWwtXHGDulS5OdvZJfewl1ALCTuulf1AQwAWwtfGoQZM2i)WqbKFETMQLKDwziUALp1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(ZIegrgtD20xgKOFV7jXEX7NNf6m9abEe7zjc4HbKFws5aY0duLG3ecG6SPfzoaYpFwRPAPS2zcoOHoGsAo4doq9mhsr)uOZ0deOwIiQ2zcoOHoGYaCEGduJbOXbtxHotpqGAP4zXIdM(ZQnWPTi429UNe7bVFEwOZ0de4rSNfloy6plaKpB6mC8zbGtranoy6pREA8X9N1coXAbq(SPZWXA)GNDTSHQ2EzR2lpYAHZAdKb6xlpR9dhdZRLKjeRDcgyTxwRGNxTWRwASLbw7LhP6zjc4HbKFwImha5NRUeuyRZM(Srnj3bvbYa9R1uT0GTMIdb7OwyZrhQMhliS2FPwRuoGm9avxEKAswgTWMJoCwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwBNa4Dpj2JE)8SqNPhiWJyplrapmG8ZsK5ai)Cfhc2rTr(HHkqgOFTMQLYA7DThpq)uOpGD2h6iGcDMEGa1ser1szThpq)uOpGD2h6iGcDMEGa1AQws2zLH4Qv(uRTxi5APOwkQ1uTuwlL1kYCaKFU6sqHToB6Zg1KChufijd9zTYVwzLCTMQLgS1uCiyh1cBo6q18ybH1sTwAWwtXHGDulS5OdvKSm65XccRLIAjIOAPSwrMdG8ZvxckS1ztF2OMK7GQazG(1AQwAWwtXHGDulS5OdvZJfewl1ALCTuulf1AQwAWwtfGoQZM2i)WqbKFETMQLKDwziUALp1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(Zca5ZModhF3tIYk53ppl0z6bc8i2ZIfhm9NvWaq2p90GdcFwa4ueqJdM(ZsoCI1on4GWAHTAV8iRLDGAzJA5aRn9Afa1YoqTFP))QLgRf0O2wg1osVdJApB2R9SXAjzzQfahCFZRLKje6D1obdS2pSwBwkwlF1oqEE1EFzTCiyhRvyZrhoRLDGApB(Q9YJS2pE6)VA7zbNxTGteq9Seb8WaYplrMdG8ZvxckS1ztF2OMK7GQajzOpRv(1kLditpqvm1KSmAaCW91Tm0xEK1AQwrMdG8ZvCiyh1g5hgQajzOpRv(1kLditpqvm1KSmAaCW91Tm0SrTMQLYApEG(Pcqh1ztBKFyOqNPhiqTMQLYAfzoaYpxfGoQZM2i)Wqfijd9zT)wlkdkapuFqsSwIiQwrMdG8ZvbOJ6SPnYpmubsYqFwR8RvkhqMEGQyQjzz0a4G7RBzOJ0OwkQLiIQT31E8a9tfGoQZM2i)WqHotpqGAPOwt1sd2AkoeSJAHnhDOAESGWALFTYRwt1cG0GTM6sqHToB6Zg1KChubKFETMQLgS1ubOJ6SPnYpmua5NxRPAPbBnfhc2rTr(HHci)839KOSY((5zHotpqGhXEwS4GP)ScgaY(PNgCq4ZcaNIaACW0FwYHtS2Pbhew7h8SRLnQ9Zg9AnY5espqvT9YwTxEK1cN1gid0VwEw7hogMxljtiw7emWAVSwbpVAHxT0yldS2lps1ZseWddi)SezoaYpxDjOWwNn9zJAsUdQcKKH(S2FRfLbfGhQpijwRPAPbBnfhc2rTWMJounpwqyT)sTwPCaz6bQU8i1KSmAHnhD4Swt1kYCaKFUIdb7O2i)Wqfijd9zT)wlL1IYGcWd1hKeRL41YIdMU6sqHToB6Zg1KChuHYGcWd1hKeRLI39KOSY79ZZcDMEGapI9Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR93Arzqb4H6dsI1AQwkRLYA7DThpq)uOpGD2h6iGcDMEGa1ser1szThpq)uOpGD2h6iGcDMEGa1AQws2zLH4Qv(uRTxi5APOwkQ1uTuwlL1kYCaKFU6sqHToB6Zg1KChufijd9zTYVwPCaz6bQydnjlJgahCFDld9LhzTMQLgS1uCiyh1cBo6q18ybH1sTwAWwtXHGDulS5OdvKSm65XccRLIAjIOAPSwrMdG8ZvxckS1ztF2OMK7GQajzOpRLATsUwt1sd2AkoeSJAHnhDOAESGWAPwRKRLIAPOwt1sd2AQa0rD20g5hgkG8ZR1uTKSZkdXvR8PwRuoGm9avSHMe6qsqsnj7S2qC1sXZIfhm9NvWaq2p90GdcF3tIYsqVFEwOZ0de4rSNfloy6pRlbf26SPpButYDWNfaofb04GP)SKdNyTxEK1(bp7AzJAHTAH3)zTFWZg61E2yTKSm1cGdUVQ2EzRwppZRfCI1(bp7AJ0OwyR2ZgR94b6xTWzThti6Mxl7a1cV)ZA)GNn0R9SXAjzzQfahCF1ZseWddi)SOS2ExBa6ylJounHg2PRNxgKk0z6bculrevlnyRPMqd701ZldsfOrTuuRPAPbBnfhc2rTWMJounpwqyT)sTwPCaz6bQU8i1KSmAHnhD4Swt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwuguaEO(GKyTMQLKDwziUALFTs5aY0duXgAsOdjbj1KSZAdXvRPAPbBnva6OoBAJ8ddfq(5V7jrzLtVFEwOZ0de4rSNLiGhgq(zrd2AkoeSJAHnhDOAESGWA)LATs5aY0duD5rQjzz0cBo6WzTMQ94b6NkaDuNnTr(HHcDMEGa1AQwrMdG8ZvbOJ6SPnYpmubsYqFw7VuRfLbfGhQpijwRPALYbKPhO6GKOg0p4qZg1k)ALYbKPhO6YJutYYObWb3x3YqZgplwCW0FwxckS1ztF2OMK7GV7jrzjW3ppl0z6bc8i2ZseWddi)SObBnfhc2rTWMJounpwqyT)sTwPCaz6bQU8i1KSmAHnhD4Swt1szT9U2JhOFQa0rD20g5hgk0z6bculrevRiZbq(5Qa0rD20g5hgQajzOpRv(1kLditpq1LhPMKLrdGdUVULHosJAPOwt1kLditpq1bjrnOFWHMnQv(1kLditpq1LhPMKLrdGdUVULHMnEwS4GP)SUeuyRZM(Srnj3bF3tIYkhF)8SqNPhiWJyplwCW0FwCiyh1g5hgplaCkcOXbt)zjhoXAzJAHTAV8iRfoRn9Afa1YoqTFP))QLgRf0O2wg1osVdJApB2R9SXAjzzQfahCFZRLKje6D1obdS2ZMVA)WATzPyTONGD21sYoxl7a1E28v7zJbwlCwRNxT8iqgOFTCTbOJ1MTAnYpmQfi)C1ZseWddi)SezoaYpxDjOWwNn9zJAsUdQcKKH(Sw5xRuoGm9avSHMKLrdGdUVULH(YJSwt1szT9UwrkfD2pLu0p7(rTeruTImha5NRiHrKXuNn9Lbj6Nkqsg6ZALFTs5aY0duXgAswgnao4(6wgAY8QLIAnvlnyRP4qWoQf2C0HQ5XccRLAT0GTMIdb7OwyZrhQizz0ZJfewRPAPbBnva6OoBAJ8ddfq(51AQws2zLH4Qv(uRvkhqMEGk2qtcDijiPMKDwBiU39KOS9I3ppl0z6bc8i2ZIfhm9Nva6OoBAJ8dJNfaofb04GP)SKdNyTrAulSv7LhzTWzTPxRaOw2bQ9l9)xT0yTGg12YO2r6Dyu7zZETNnwljltTa4G7BETKmHqVR2jyG1E2yG1cN()RwEeid0VwU2a0XAbYpVw2bQ9S5Rw2O2V0)F1sJIKeRLLYWbtpWAbadO3vBa6O6zjc4HbKFw0GTMIdb7O2i)WqbKFETMQLYAfzoaYpxDjOWwNn9zJAsUdQcKKH(Sw5xRuoGm9avrAOjzz0a4G7RBzOV8iRLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATs5aY0duD5rQjzz0a4G7RBzOzJAPOwt1sd2AkoeSJAHnhDOAESGWAPwlnyRP4qWoQf2C0Hkswg98ybH1AQwrMdG8ZvCiyh1g5hgQajzOpRv(1kRKR1uTImha5NRUeuyRZM(Srnj3bvbsYqFwR8Rvwj)UNeLTh8(5zHotpqGhXEwIaEya5NLuoGm9avj4nHaOoBArMdG8ZNplwCW0FwtBy7GEN2i)W4DpjkBp69ZZcDMEGapI9SyXbt)zze4eDbQZMMe6aplaCkcOXbt)zjhoXAnsYAVS2zpeercEyTSxlkZfCTmDTqV2ZgR1rzUAfzoaYpV2pOdKFMxlOpW5Swc7hq2R9SrV20h9RfamGExTCiyhR1i)WOwaqS2lR1o)QLKDUwBqVl6xBWaq2VANgCqyTW5ZseWddi)SoEG(Pcqh1ztBKFyOqNPhiqTMQLgS1uCiyh1g5hgkqJAnvlnyRPcqh1ztBKFyOcKKH(S2FRTtaOizzE3tIYtYVFEwOZ0de4rSNLiGhgq(zbG0GTM6sqHToB6Zg1KChubAuRPAbqAWwtDjOWwNn9zJAsUdQcKKH(S2FRLfhmDfhc2rnjCoHdCQqzqb4H6dsI1AQ2ExRiLIo7NIW(bK9Nfloy6plJaNOlqD20Kqh4DpjkpzF)8SqNPhiWJyplrapmG8ZIgS1ubOJ6SPnYpmuGg1AQwAWwtfGoQZM2i)Wqfijd9zT)wBNaqrYYuRPAfzoaYpxHstbFW0vbYa9R1uTImha5NRUeuyRZM(Srnj3bvbsYqFwRPA7DTIuk6SFkc7hq2FwS4GP)SmcCIUa1zttcDG39UNLnhKP3)9ZtIY((5zHotpqGhXEwS4GP)SqPPGpy6plaCkcOXbt)z1lB1oYVAtVws25AzhOwrMdG8ZN1YbwRijHExTGgMxBxwlBJmqTSdulknFwIaEya5Nfj7SYqC1(l1AjijxRPALYbKPhOkbVjea1ztlYCaKF(Swt1szThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUkaDuNnTr(HHkqsg6ZA)TwzLCTu8UNeL37NNf6m9abEe7zbGtranoy6pl5aS2p2VAVS25XccR1MdY07xBdCm6RQ9hBSwWjwB2Qvw5yTZJfeoR1gdSw4S2lRLfIe0VABzu7zJ1EqbH1oW2vB61E2yTcB2DCul7a1E2yTKW5eoWAHETTbSZ(uplrapmG8ZIYALYbKPhOAESGqTnhKP3VwIiQ2dsI1(BTYk5APOwt1sd2AkoeSJABoitVVAESGWA)TwzLJplHnd9NLSplwCW0FwCiyh1KW5eoW57EsKGE)8SqNPhiWJyplwCW0FwCiyh1KW5eoW5ZcaNIaACW0FwYb2Oxl4e6D1kNrA0pqEulb)aWzxGMxRGNxTCTn8RwuMl4AjHZjCGZA)SHdS2pgEqVR2wg1E2yT0GTwT8v7zJ1opoUAZwTNnwBd2zFplrapmG8Zc7HGqddeqHKg9dKh6maC2fyTMQ9GKyT)wlbj5Anv7LDDdujYCaKF(Swt1kYCaKFUcjn6hip0za4SlqvGKm0N1k)ALvo2dQ1uT9UwwCW0viPr)a5HodaNDbQaGtMEGaV7jr507NNf6m9abEe7zjc4HbKFws5aY0duHKg5hgiGMMJG7WAnvRiZbq(5Qlbf26SPpButYDqvGKm0N1(l1Arzqb4H6dsI1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1szTOmOa8q9bjXA751kVAPOwt1szT9UwShccnmqa1mbhd8oO3Pdq6(1ser1kshaeEkoeSJAJibGD9vb7ewR8PwlbwlrevRiZbq(5Qzcog4DqVthG09vbsYqFw7VuRLYArzqb4H6dsI12ZRvE1srTu8SyXbt)zfmaK9tpn4GW39Kib((5zHotpqGhXEwIaEya5NLuoGm9av9SGZtdora90GdcR1uTImha5NR4qWoQnYpmubsYqFw7VuRfLbfGhQpijwRPAPS2Exl2dbHggiGAMGJbEh070biD)AjIOAfPdacpfhc2rTrKaWU(QGDcRv(uRLaRLiIQvK5ai)C1mbhd8oO3Pdq6(QajzOpR9xQ1IYGcWd1hKeRLINfloy6pRlbf26SPpButYDW39KOC89ZZcDMEGapI9Seb8WaYplJaLQ7eakzvxckS1ztF2OMK7GplwCW0FwCiyh1g5hgV7jXEX7NNf6m9abEe7zjc4HbKFws5aY0duHKg5hgiGMMJG7WAnvRiZbq(5QGbGSF6PbheQcKKH(S2FPwlkdkapuFqsSwt1kLditpq1bjrnOFWHMnQv(uRvEsUwt1szT9Uwr6aGWtXHGDuBejaSRVcDMEGa1ser127ALYbKPhOIhFC)PE23fArMdG8ZN1ser1kYCaKFU6sqHToB6Zg1KChufijd9zT)sTwkRfLbfGhQpijwBpVw5vlf1sXZIfhm9Nva6OoBAJ8dJ39Kyp49ZZcDMEGapI9Seb8WaYplPCaz6bQqsJ8ddeqtZrWDyTMQ1iqP6obGswva6OoBAJ8dJNfloy6pRGbGSF6Pbhe(UNe7rVFEwOZ0de4rSNLiGhgq(zjLditpqvpl480Gteqpn4GWAnvBVRvkhqMEGk7Caa9o9Lh5ZIfhm9N1LGcBD20NnQj5o47Esuwj)(5zHotpqGhXEwS4GP)S4qWoQP5i4o8zbGtranoy6pl5WjwR8CGA5qWowlnhb3H1c9A7PEL4eCe871AtF0VwyRwInYeyaoVAzhOw(QDG88QvE1saeWSwJifce4zjc4HbKFw0GTMIdb7OwyZrhQMhliSwQ1sd2AkoeSJAHnhDOIKLrppwqyTMQLgS1ubOJ6SPnYpmuGg1AQwAWwtXHGDuBKFyOanQ1uT0GTMIdb7O2MdY07RMhliSw5tTwzLJ1AQwAWwtXHGDuBKFyOcKKH(S2FPwlloy6koeSJAAocUdvOmOa8q9bjXAnvlnyRPOhzcmaNNc04DpjkRSVFEwOZ0de4rSNfloy6pRa0rD20g5hgplaCkcOXbt)zjhoXALNdulbx2R1c9A7PET20h9Rf2QLyJmbgGZRw2bQvE1saeWSwJifplrapmG8ZIgS1ubOJ6SPnYpmua5NxRPAPbBnf9itGb48uGg1AQwkRvkhqMEGQdsIAq)GdnBuR8RLGKCTeruTImha5NRcgaY(PNgCqOkqsg6ZALFTYkVAPOwt1szT0GTMIdb7O2MdY07RMhliSw5tTwzjWAjIOAPbBnLyGCi45b9o18ybH1kFQ1kBTuuRPAPS2ExRiDaq4P4qWoQnIea21xHotpqGAjIOA7DTs5aY0duXJpU)up77cTiZbq(5ZAP4DpjkR8E)8SqNPhiWJyplrapmG8ZIgS1uCiyh1g5hgkG8ZR1uTuwRuoGm9avhKe1G(bhA2Ow5xlbj5AjIOAfzoaYpxfmaK9tpn4GqvGKm0N1k)ALvE1srTMQLYA7DTI0baHNIdb7O2isayxFf6m9abQLiIQT31kLditpqfp(4(t9SVl0Imha5NpRLINfloy6pRa0rD20g5hgV7jrzjO3ppl0z6bc8i2ZseWddi)SKYbKPhOcjnYpmqannhb3H1AQwkRLgS1uCiyh1cBo6q18ybH1kFQ1kVAjIOAfzoaYpxXHGDuNbTkqgOFTuuRPAPS2Ex7Xd0pva6OoBAJ8ddf6m9abQLiIQvK5ai)Cva6OoBAJ8ddvGKm0N1k)AjWAPOwt1kLditpqfopijFiGMn0Imha5NxR8Pwlbj5AnvlL127AfPdacpfhc2rTrKaWU(k0z6bculrevBVRvkhqMEGkE8X9N6zFxOfzoaYpFwlfplwCW0Fwbdaz)0tdoi8DpjkRC69ZZcDMEGapI9SyXbt)zDjOWwNn9zJAsUd(SaWPiGghm9NLCGn61gGUd9UAnIea2138AbNyTxEK1s3Vw4nXrRwOxBgayu7L1YdyNxl8Q9dE21YgplrapmG8ZskhqMEGQdsIAq)GdnBu7V1sGsUwt1kLditpq1bjrnOFWHMnQv(1sqsUwt1szT9UwShccnmqa1mbhd8oO3Pdq6(1ser1kshaeEkoeSJAJibGD9vb7ewR8PwlbwlfV7jrzjW3ppl0z6bc8i2ZseWddi)SKYbKPhOQNfCEAWjcONgCqyTMQLgS1uCiyh1cBo6q18ybH1(BT0GTMIdb7OwyZrhQizz0ZJfe(SyXbt)zXHGDuNb97Esuw547NNf6m9abEe7zjc4HbKFwainyRPcgaY(PNgCqOwk4WXGPHd41xnpwqyTuRfaPbBnvWaq2p90Gdc1sbhogmnCaV(kswg98ybHplwCW0FwCiyh10CeCh(UNeLTx8(5zHotpqGhXEwIaEya5NLuoGm9av9SGZtdora90GdcRLiIQLYAbqAWwtfmaK9tpn4GqTuWHJbtdhWRVc0Owt1cG0GTMkyai7NEAWbHAPGdhdMgoGxF18ybH1(BTainyRPcgaY(PNgCqOwk4WXGPHd41xrYYONhliSwkEwS4GP)S4qWoQPh88E3tIY2dE)8SqNPhiWJyplwCW0FwCiyh10CeCh(SaWPiGghm9NLC4eRLe6WAjghb3H1sJ3hIETbdaz)QDAWbHZAHTAbDamQLysqTFWZobVAbWb3h6D1sWXaq2VATm4GWAHaipg9FwIaEya5NfnyRPcqh1ztBKFyOanQ1uT0GTMIdb7O2i)WqbKFETMQLgS1u0JmbgGZtbAuRPAfzoaYpxfmaK9tpn4GqvGKm0N1(l1ALvY1AQwAWwtXHGDuBZbz69vZJfewR8PwRSYX39KOS9O3ppl0z6bc8i2ZIfhm9Nfhc2rDg0plaCkcOXbt)zjhoXAZGU20RvaulOpW5Sw2Ow4Swrsc9UAbnQDMP)Seb8WaYplAWwtXHGDulS5OdvZJfew7V1sq1AQwPCaz6bQoijQb9do0SrTYVwzLCTMQLYAfzoaYpxDjOWwNn9zJAsUdQcKKH(Sw5xlbwlrevBVRvKoai8uCiyh1grca76RqNPhiqTu8UNeLNKF)8SqNPhiWJyplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)SObBnLyGCi45b9ovGS4Q1uT0GTMIdb7O2i)WqbA8UNeLNSVFEwOZ0de4rSNfloy6ploeSJAAocUdFwa4ueqJdM(ZQx2Q9dRTdVAnYpmQf6nWjm9AbadO3v7aCE1(H)hJATzPyTONGD21AZZdR9YA7WR2S1QLRDEr6D1sZrWDyTaGb07Q9SXAJ0qsSrTFqhi)EwIaEya5NfnyRPcqh1ztBKFyOanQ1uT0GTMkaDuNnTr(HHkqsg6ZA)LATS4GPR4qWoQjHZjCGtfkdkapuFqsSwt1sd2AkoeSJAJ8ddfOrTMQLgS1uCiyh1cBo6q18ybH1sTwAWwtXHGDulS5OdvKSm65XccR1uT0GTMIdb7O2MdY07RMhliSwt1sd2AkJ8ddn0BGty6kqJAnvlnyRPOhzcmaNNc04Dpjkp59(5zHotpqGhXEwS4GP)S4qWoQPh88Ewa4ueqJdM(ZQx2Q9dRTdVAnYpmQf6nWjm9AbadO3v7aCE1(H)hJATzPyTONGD21AZZdR9YA7WR2S1QLRDEr6D1sZrWDyTaGb07Q9SXAJ0qsSrTFqhi)mV2zw7h(FmQn9r)AbNyTONGD21sp45nRf6WdYJr)AVS2o8Q9YABjyuRWMJoC(Seb8WaYplAWwtze4eDbQZMMe6akqJAnvlL1sd2AkoeSJAHnhDOAESGWA)TwAWwtXHGDulS5OdvKSm65XccRLiIQT31szT0GTMYi)Wqd9g4eMUc0Owt1sd2Ak6rMadW5PanQLIAP4Dpjkpc69ZZcDMEGapI9SyXbt)zze4eDbQZMMe6aplaCkcOXbt)z9JnwlnoVAbNyTzRwJKSw4S2lRfCI1cVAVS2Eiiuq4OFT0GWbqTcBo6WzTaGb07QLnQLBhg1E2y)A7WRwaqsdeOw6(1E2yT2CqME)AP5i4o8zjc4HbKFw0GTMIdb7OwyZrhQMhliS2FRLgS1uCiyh1cBo6qfjlJEESGWAnvlnyRP4qWoQnYpmuGgV7jr5jNE)8SqNPhiWJyplaCkcOXbt)zjhG1(X(v7L1opwqyT2CqME)ABGJrFvT)yJ1coXAZwTYkhRDESGWzT2yG1cN1EzTSqKG(vBlJApBS2dkiS2b2UAtV2ZgRvyZUJJAzhO2ZgRLeoNWbwl0RTnGD2N6zXIdM(ZIdb7OMeoNWboFwq)WianUNLSplHnd9NLSplrapmG8ZIgS1uCiyh12CqMEF18ybH1(BTYkhFwq)WianoD3iP5XZs239KO8iW3ppl0z6bc8i2ZseWddi)SObBnfhc2rTWMJounpwqyTuRLgS1uCiyh1cBo6qfjlJEESGWAnvRuoGm9aviPr(HbcOP5i4o8zXIdM(ZIdb7OMMJG7W39KO8KJVFEwOZ0de4rSNLiGhgq(zrYoRmexT)wRSe4ZIfhm9Nfknf8bt)DpjkVEX7NNf6m9abEe7zXIdM(ZIdb7OMEWZ7zbGtranoy6plc((OFTGtSw6bpVAVSwAq4aOwHnhD4SwyR2pSwEeid0VwBwkw7mjXABrswBg0plrapmG8ZIgS1uCiyh1cBo6q18ybH1AQwAWwtXHGDulS5OdvZJfew7V1sd2AkoeSJAHnhDOIKLrppwq47EsuE9G3ppl0z6bc8i2ZcaNIaACW0FwY5dog1(bp7AzYAb9boN1Yg1cN1kssO3vlOrTSdu7h(pWAh5xTPxlj78ZIfhm9Nfhc2rnjCoHdC(SG(HraACplzFwcBg6plzFwIaEya5NvVRLYALYbKPhO6GKOg0p4qZg1(l1ALvY1AQws2zLH4Q93AjijxlfplOFyeGgNUBK084zj77EsuE9O3ppl0z6bc8i2ZcaNIaACW0Fw9AKn4aN1(bp7Ah5xTK88WOV51Ad7SR1MNhAETzulDE21sY9R1ZRwBwkwl6jyNDTKSZ1EzTtqdJmUATZVAjzNRf6h6tOuS2GbGSF1on4GWAfSxlnAETZS2p8)yul4eRTbdSw6bpVAzhO2wKZJohxTF2Ox7i)Qn9AjzNFwS4GP)SAWa10dEEV7jrcsYVFEwS4GP)SArop6CCpl0z6bc8i27E3ZsWdb4Gpy6Z3ppjk77NNf6m9abEe7zLgpRjEplwCW0Fws5aY0d8zjLhG4Zs2NLiGhgq(zjLditpqLnlf1Pb6iqTuRvY1AQwJaLQ7eakzvO0uWhm9AnvBVRLYAdqhBz0HQj0WoD98YGuHotpqGAjIOAdqhBz0HQdjnYGh6pomuOZ0deOwkEws5q7mj(SSzPOonqhbE3tIY79ZZcDMEGapI9SsJN1eVNfloy6plPCaz6b(SKYdq8zj7ZseWddi)SKYbKPhOYMLI60aDeOwQ1k5AnvlnyRP4qWoQnYpmua5NxRPAfzoaYpxXHGDuBKFyOcKKH(Swt1szTbOJTm6q1eAyNUEEzqQqNPhiqTeruTbOJTm6q1HKgzWd9hhgk0z6bculfplPCODMeFw2SuuNgOJaV7jrc69ZZcDMEGapI9SsJN1eVNfloy6plPCaz6b(SKYdq8zj7ZseWddi)SObBnfhc2rTWMJounpwqyTuRLgS1uCiyh1cBo6qfjlJEESGWAnvBVRLgS1ub4a1ztF2bItfOrTMQTb7SpDGKm0N1(l1APSwkRLKDUwjvlloy6koeSJA6bppLiNxTuuBpVwwCW0vCiyh10dEEkuguaEO(GKyTu8SKYH2zs8z1Gop00GH)UNeLtVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIplAWwtXHGDuBZbz69vZJfewR8PwRSeyTeruTuwBa6ylJouXHGDutNK0CaqI(PqNPhiqTMQ94OdpLnYJZwziUA)TwcIaRLINfaofb04GP)SKZGNng1Y12ahJ(1opwqicuRnhKP3V2mQf61IYGcWdRnyVdR9dE21sSKKMdas0VNLuo0otIplK0i)Wab00CeCh(UNejW3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskhANjXN1GNNMn0Gt8zbGngCCplj)Seb8WaYplAWwtXHGDuBKFyOanQ1uTuwRuoGm9avdEEA2qdoXAPwRKRLiIQ9GKyTYNATs5aY0dun45Pzdn4eRL41klbwlfplP8aeFwhKeF3tIYX3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNfL1kYCaKFUIdb7O2i)Wqbag8btV2EETuwRS12ZulL1kzLKjOA751kshaeEkoeSJAJibGD9vb7ewlf1srTuuBptTuw7bjXA7zQvkhqMEGQbppnBObNyTu8SaWPiGghm9Nvpfc2XA71ibGD9RTdkfN1Y1kLditpWAzYe0VAZwTcGW8APbVA)W)JrTGtSwU22GVAX5bj5dMET2yGQA)XgRDcjf1AePuiacuBGKm0NAugduCiqTOmgboNW0RfiXzTEE1(LbH1(HJrTTmQ1isayx)AbaXAVS2ZgRLgmMx)AD(adS2Sv7zJ1kac1ZskhANjXNfopijFiGMn0Imha5N)UNe7fVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIplPCaz6bQW5bj5db0SHwK5ai)8NLiGhgq(zjshaeEkoeSJAJibGD9Fws5q7mj(SoijQb9do0SX7EsSh8(5zHotpqGhXEwPXZAI3ZIfhm9NLuoGm9aFws5bi(SezoaYpxXHGDuBKFyOcKKH(8zjc4HbKFw9Uwr6aGWtXHGDuBejaSRVcDMEGaplPCODMeFwhKe1G(bhA24Dpj2JE)8SqNPhiWJypR04zrYY8SyXbt)zjLditpWNLuo0otIpRdsIAq)GdnB8Seb8WaYplkRvK5ai)C1LGcBD20NnQj5oOkqsg6ZA7zQvkhqMEGQdsIAq)GdnBulf1(BTYtYplaCkcOXbt)zjhG)hJAbWb3V2EQxRf0O2lRvEsEIIABzu7p51JFws5bi(SezoaYpxDjOWwNn9zJAsUdQcKKH(8DpjkRKF)8SqNPhiWJypR04zrYY8SyXbt)zjLditpWNLuo0otIpRdsIAq)GdnB8Seb8WaYplr6aGWtXHGDuBejaSRFTMQvKoai8uCiyh1grca76Rc2jS2FRLaR1uTypeeAyGaQzcog4DqVthG09R1uTIuk6SFkc7hq2R1uTbOJTm6qfhc2rTnhKP3xHotpqGNfaofb04GP)SSGUaRLGdKUFTWzTtqHDTCTg5hgnWrTxaDcXR2wg1kN)(bKDZR9d)pg1opOGWAVS2ZgR9(YAjHo4H1k6lgyTG(bh1(H12HxTCT2Wo7Arpb7SRnyNWAZwTgrca76)SKYdq8zjYCaKFUAMGJbEh070biDFvGKm0NV7jrzL99ZZcDMEGapI9SsJN1eVNfloy6plPCaz6b(SKYdq8zjYCaKFU6sqHToB6Zg1KChufid0Vwt1kLditpq1bjrnOFWHMnQ93ALNKFwa4ueqJdM(Zsoa)pg1cGdUFT)KxpUwqJAVSw5j5jkQTLrT9uV(SKYH2zs8zzNdaO3PV8iF3tIYkV3ppl0z6bc8i2ZknEwt8EwS4GP)SKYbKPh4ZskpaXNfL1AeOuDNaqjRkyai7NEAWbH1ser1AeOuDNaqjpvWaq2p90GdcRLiIQ1iqP6obGIGubdaz)0tdoiSwkQ1uTainyRPcgaY(PNgCqOwk4WXGPHd41xbKF(ZcaNIaACW0FweCmaK9RwldoiSwGeN165vlKKebG8HJ(1AaE1cAu7zJ1kfC4yW0Wb86xlasd2A1oZAHxTc2RLgRfa2Aqb44Q9YAbGtbgETNnF1(H)dSw(Q9SXAj4HrE21kfC4yW0Wb86x78ybHplPCODMeFw9SGZtdora90GdcF3tIYsqVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIplAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgkG8ZR1uTainyRPUeuyRZM(Srnj3bva5NxRPA7DTs5aY0du1Zcopn4eb0tdoiSwt1cG0GTMkyai7NEAWbHAPGdhdMgoGxFfq(5plPCODMeFwj4nHaOoBArMdG8ZNV7jrzLtVFEwOZ0de4rSNvA8SM49SyXbt)zjLditpWNLuEaIpRa0XwgDOIdb7O2MdY07RqNPhiqTMQLYAPSwrkfD2pfH9di71AQwrMdG8Zvbdaz)0tdoiufijd9zT)wRuoGm9av2CqMEF98ybH6dsI1srTu8SKYH2zs8znpwqO2MdY07)U39SAqNhAAWWF)8KOSVFEwOZ0de4rSNfloy6ploeSJAs4Cch48zjSzO)SK9zjc4HbKFw0GTMsmqoe88GENkqwCV7jr59(5zXIdM(ZIdb7OMEWZ7zHotpqGhXE3tIe07NNfloy6ploeSJAAocUdFwOZ0de4rS39U39SKIXeM(tIYtYYtwj3lKCV4z9XHd9U5ZsoONi4KyVuIY5iH1w7p2yTqsJmUABzu7FBoitV))AdShccdeO2zsI1YGxsYhcuRWM9oCQkZKaOJ1kRewlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMjbqhRvojH1saPlfJdbQ9)fqNq8umTqjYCaKF()AVS2)Imha5NRyAX)APuwzOqvMjbqhRLaLWAjG0LIXHa1()cOtiEkMwOezoaYp)FTxw7FrMdG8ZvmT4FTukRmuOkZKaOJ12lKWAjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlLYkdfQYmja6yTYkRewlbKUumoeO2)I0baHNsU)R9YA)lshaeEk5QqNPhiW)APuwzOqvMjbqhRvw5jH1saPlfJdbQ9ViDaq4PK7)AVS2)I0baHNsUk0z6bc8VwkLvgkuLzsa0XALLGKWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmja6yTYsqsyTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvzMeaDSwz7rsyTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvzwzMCqprWjXEPeLZrcRT2FSXAHKgzC12YO2)n40g6D60aDm(xBG9qqyGa1otsSwg8ss(qGAf2S3HtvzMeaDSwzLWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukpzOqvMjbqhRvEsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzMeaDSwcscRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowRCscRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowlbkH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvokH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)A5Rw5mc(sqTukRmuOkZKaOJ12JKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ12JKWAjG0LIXHa1(xKoai8uY9FTxw7Fr6aGWtjxf6m9ab(xlF1kNrWxcQLszLHcvzMeaDSwzLNewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLs5jdfQYmja6yTYsGsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALNKLWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmja6yTYJGKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukpzOqvMjbqhRvEeKewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLVALZi4lb1sPSYqHQmtcGowR8iqjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlF1kNrWxcQLszLHcvzMeaDSw5jhLWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYSYm5GEIGtI9sjkNJewBT)yJ1cjnY4QTLrT)J84dM()AdShccdeO2zsI1YGxsYhcuRWM9oCQkZKaOJ1kRewlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMjbqhRvwjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYtcRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowlbjH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRLaLWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmja6yTYrjSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmtcGowRSswcRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZKaOJ1kBpscRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZKaOJ1kBpscRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowR8KSewlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMjbqhRvEswcRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowR8KvcRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukRmuOkZKaOJ1kpzLWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kp5jH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvEeKewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzwzMCqprWjXEPeLZrcRT2FSXAHKgzC12YO2)Pb6y8V2a7HGWabQDMKyTm4LK8Ha1kSzVdNQYmja6yTYkH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvEsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALvEsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzMeaDSwzjqjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlF1kNrWxcQLszLHcvzMeaDSwzLJsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8Vw(QvoJGVeulLYkdfQYmja6yTY2lKWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYSYm5GEIGtI9sjkNJewBT)yJ1cjnY4QTLrT)bWgdoU)1gypeegiqTZKeRLbVKKpeOwHn7D4uvMjbqhRvEsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5jdfQYmja6yTYjjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYkNKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kRCucRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowRS9ajSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYtEsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8Vw(QvoJGVeulLYkdfQYmja6yTYJGKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kp5KewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSw5rGsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALNCucRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowR86fsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzLzYb9ebNe7LsuohjS2A)XgRfsAKXvBlJA)BeOijP57FTb2dbHbcu7mjXAzWlj5dbQvyZEhovLzsa0XALJsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALJsyTeq6sX4qGA)lshaeEk5(V2lR9ViDaq4PKRcDMEGa)RLszLHcvzMeaDSw5jzjSwciDPyCiqT)fPdacpLC)x7L1(xKoai8uYvHotpqG)1sPSYqHQmtcGowR8KvcRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowR8KvcRLasxkghcu7Fr6aGWtj3)1EzT)fPdacpLCvOZ0de4FTukRmuOkZKaOJ1kp5jH1saPlfJdbQ9ViDaq4PK7)AVS2)I0baHNsUk0z6bc8VwkLvgkuLzsa0XALxpscRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukpzOqvMjbqhRvE9ijSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTeK8KWAjG0LIXHa1(FMGdAOdOK7)AVS2)ZeCqdDaLCvOZ0de4FTukRmuOkZKaOJ1sqYtcRLasxkghcu7)zcoOHoGsU)R9YA)ptWbn0buYvHotpqG)1YxTYze8LGAPuwzOqvMjbqhRLGiijSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTeebjH1saPlfJdbQ9ViDaq4PK7)AVS2)I0baHNsUk0z6bc8VwkLvgkuLzsa0XAji5KewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLVALZi4lb1sPSYqHQmtcGowlbrGsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XAji5OewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzwzMCqprWjXEPeLZrcRT2FSXAHKgzC12YO2)Imha5Np)xBG9qqyGa1otsSwg8ss(qGAf2S3HtvzMeaDSwzLWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYtgkuLzsa0XALvcRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowR8KWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYtgkuLzsa0XALNewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwcscRLasxkghcu7)JhOFk5(V2lR9)Xd0pLCvOZ0de4FTukpzOqvMjbqhRLGKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kNKWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1sGsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALJsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5jdfQYmja6yT9cjSwciDPyCiqT)Nj4Gg6ak5(V2lR9)mbh0qhqjxf6m9ab(xlLYtgkuLzsa0XA7rsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5jdfQYmja6yTYkzjSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sP8KHcvzMeaDSwzLNewlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuEYqHQmtcGowRSeKewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwzLtsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLszLHcvzMeaDSwzjqjSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmtcGowRS9ijSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmRmtoONi4KyVuIY5iH1w7p2yTqsJmUABzu7FoX)1gypeegiqTZKeRLbVKKpeOwHn7D4uvMjbqhRvwjSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sP8KHcvzMeaDSwzLWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kpjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYtgkuLzsa0XAjijSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sP8KHcvzMeaDSwcscRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowRCscRLasxkghcu7)a0XwgDOsU)R9YA)hGo2YOdvYvHotpqG)1sPSYqHQmtcGowlbkH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvokH1saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzsa0XA7fsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XA7bsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XA7rsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5jdfQYmja6yTYkzjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYkRewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwzLNewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwzjijSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sP8KHcvzMeaDSwzLJsyTeq6sX4qGA)F8a9tj3)1EzT)pEG(PKRcDMEGa)RLs5jdfQYmja6yTY2JKWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlF1kNrWxcQLszLHcvzMeaDSw5jzjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYtwjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYtEsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XALhbjH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvEYjjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYkdfQYmja6yTYJaLWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FTukRmuOkZKaOJ1kp5OewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSw51lKWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYkdfQYmja6yTYRxiH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRvE9ajSwciDPyCiqT)pEG(PK7)AVS2)hpq)uYvHotpqG)1sPSYqHQmtcGowR86bsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLvgkuLzsa0XAjijlH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMjbqhRLGKNewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwcsojH1saPlfJdbQ9)Xd0pLC)x7L1()4b6NsUk0z6bc8VwkLvgkuLzsa0XAji5KewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDSwcIaLWAjG0LIXHa1()4b6NsU)R9YA)F8a9tjxf6m9ab(xlLYtgkuLzsa0XAji5OewlbKUumoeO2)hpq)uY9FTxw7)JhOFk5QqNPhiW)APuwzOqvMvMjh0teCsSxkr5CKWAR9hBSwiPrgxTTmQ9VGhcWbFW0N)RnWEiimqGANjjwldEjjFiqTcB27WPQmtcGowRSsyTeq6sX4qGA)hGo2YOdvY9FTxw7)a0XwgDOsUk0z6bc8VwkLNmuOkZKaOJ1kpjSwciDPyCiqT)dqhBz0Hk5(V2lR9Fa6ylJoujxf6m9ab(xlLYtgkuLzsa0XAjijSwciDPyCiqTwqscO2zF)yzQvoVQ9YALaqUwaOu4eMETPbg8LrTukjkQLszLHcvzMeaDSw5KewlbKUumoeO2)bOJTm6qLC)x7L1(paDSLrhQKRcDMEGa)RLszLHcvzMeaDS2EGewlbKUumoeO2)I0baHNsU)R9YA)lshaeEk5QqNPhiW)A5Rw5mc(sqTukRmuOkZKaOJ1kRKLWAjG0LIXHa1()cOtiEkMwOezoaYp)FTxw7FrMdG8ZvmT4FTukRmuOkZKaOJ1kRKLWAjG0LIXHa1(paDSLrhQK7)AVS2)bOJTm6qLCvOZ0de4FT8vRCgbFjOwkLvgkuLzsa0XALvojH1saPlfJdbQ9Fa6ylJouj3)1EzT)dqhBz0Hk5QqNPhiW)APuwzOqvMvM1ljnY4qGALvY1YIdMETd48MQYSNfdE2z8SSGKGd(GPtab3UNLrKn4aFwemcwT9yUdRTNcb7yzgbJGvRzGJ(1kRKnVw5jz5jBzwzgbJGvlbyZEhoLWYmcgbR2EMALdNyTxFdOGh1AbjjGATzhya9UAZwTcB2DCul0pmcqJdMETqFEiduB2Q9VGDbo0S4GP)xvMrWiy12ZulbyZEhwlhc2rn0BqhE9R9YA5qWoQT5Gm9(1sj8Q1rPyu7h6xTdOuSwEwlhc2rTnhKP3Ncvzwzgloy6tLrGIKKMpItvsCiyh1q)WXafxzgloy6tLrGIKKMpItvsCiyh1nMeoGCuMXIdM(uzeOijP5J4uLKi9EwWa1KSZ6oKSmJfhm9PYiqrssZhXPkjPCaz6bAUZKivor9XrhEArc6N5Pb1aN4zoa2yWXrLGkZyXbtFQmcuKK08rCQsskhqMEGM7mjsfLMAdXzEAqnWjEMdGngCCuLLalZyXbtFQmcuKK08rCQsskhqMEGM7mjs1iqdWXqJstZtdQt8mh2Osza6ylJounHg2PRNxgKMOuKsrN9tjf9ZUFqerIuk6SFkhfroYaGiIePdacpfhc2rTrKaWU(uqH5s5bisvwZLYdquJJjsvYLzS4GPpvgbkssA(iovjjLditpqZDMePAZsrDAGocyEAqDIN5WgvwCqPOgDKeIt5tvkhqMEGkor9XrhEArc6N5s5bisvwZLYdquJJjsvYLzS4GPpvgbkssA(iovjjLditpqZDMeP2Gop00GHBEAqDIN5s5bisvYLzS4GPpvgbkssA(iovjjLditpqZDMePAZbz691ZJfeQpijAEAqnWjEMdGngCCu7rLzS4GPpvgbkssA(iovjjLditpqZDMePYJpU)up77cTiZbq(5tZtdQboXZCaSXGJJQKlZyXbtFQmcuKK08rCQsskhqMEGM7mjsnMAswgnao4(6wg6lpsZtdQboXZCaSXGJJkbwMXIdM(uzeOijP5J4uLKuoGm9an3zsKAm1KSmAaCW91Tm0rAyEAqnWjEMdGngCCujWYmwCW0NkJafjjnFeNQKKYbKPhO5otIuJPMKLrdGdUVULHMnmpnOg4epZbWgdooQYtYLzS4GPpvgbkssA(iovjjLditpqZDMePsMN2iqbIa6lpsnDFZtdQboXZCaSXGJJApOmJfhm9PYiqrssZhXPkjPCaz6bAUZKivY80KSmAaCW91Tm0xEKMNgudCIN5ayJbhhvzLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQK5Pjzz0a4G7RBzOzdZtdQboXZCaSXGJJQSeyzgloy6tLrGIKKMpItvss5aY0d0CNjrQSHMKLrdGdUVULH(YJ080GAGt8mh2OkshaeEkoeSJAJibGD9nxkparQeKKnxkparnoMivzLCzgloy6tLrGIKKMpItvss5aY0d0CNjrQSHMKLrdGdUVULH(YJ080GAGt8mhaBm44OkpjxMXIdM(uzeOijP5J4uLKuoGm9an3zsKkBOjzz0a4G7RBzOjZZ80GAGt8mhaBm44OkpjxMXIdM(uzeOijP5J4uLKuoGm9an3zsKAKgAswgnao4(6wg6lpsZtdQt8mxkparQYtY9musG9Cr6aGWtXHGDuBejaSRpfLzS4GPpvgbkssA(iovjjLditpqZDMePE5rQjzz0a4G7RBzOzdZtdQt8mxkparQeiXLNK75uksPOZ(PCyN9PBmserukshaeEkoeSJAJibGD9nXIdkf1OJKqC(RuoGm9avCI6JJo80Ie0pkOG4YsG9CkfPu0z)ue2pGSBkaDSLrhQ4qWoQT5Gm9(MyXbLIA0rsioLpvPCaz6bQ4e1hhD4PfjOFuuMXIdM(uzeOijP5J4uLKuoGm9an3zsK6LhPMKLrdGdUVULHosdZtdQt8mxkparQYtY9mu2d65I0baHNIdb7O2isayxFkkZyXbtFQmcuKK08rCQsskhqMEGM7mjsLMJG7qnj7S2qCMNguN4zoSrvKsrN9t5Wo7t3y0CP8aePkhLCpdLK88WOVwkpaXEUSswYuuMXIdM(uzeOijP5J4uLKuoGm9an3zsKknhb3HAs2zTH4mpnOoXZCyJQiLIo7NIW(bKDZLYdqKApIa7zOKKNhg91s5bi2ZLvYsMIYmwCW0NkJafjjnFeNQKKYbKPhO5otIuP5i4outYoRneN5Pb1jEMdBuLYbKPhOIMJG7qnj7S2qCuLS5s5bisThi5Egkj55HrFTuEaI9CzLSKPOmJfhm9PYiqrssZhXPkjPCaz6bAUZKiv2qtcDijiPMKDwBioZtdQboXZCaSXGJJQSeyzgloy6tLrGIKKMpItvss5aY0d0CNjrQxEKAswgTWMJoCAEAqnWjEMdGngCCuLxzgloy6tLrGIKKMpItvss5aY0d0CNjrQCI6lpsnjlJwyZrhonpnOg4epZbWgdooQYRmJfhm9PYiqrssZhXPkjPCaz6bAUZKi1gCAd9oDAGogMNguN4zUuEaIuLTNtj2dbHggiGcjn6hip0za4SlqIiIYJhOFQa0rD20g5hgMO84b6NIdb7Ogf2jre1BrkfD2pfH9di7uyIYElsPOZ(PCue5idaIiIfhukQrhjH4KQSerua6ylJounHg2PRNxgKuyQ3Iuk6SFkPOF29dkOOmJfhm9PYiqrssZhXPkjPCaz6bAUZKiv2qNUgCIMNguN4zUuEaIuXEii0WabuKSGPdupTr80KGtOGiIWEii0WabuDdgaYxgtnnd0Here2dbHggiGQBWaq(YyQjraEmGPterypeeAyGakaoiKmtxdGcc1gGxGtb6cKiIWEii0WabuqFkcWJPhOUhcY(bsQbqPqbserypeeAyGaQzcog4DqVthG09jIiShccnmqa1e0PhzcOzs8S7ppIic7HGqddeq9XeIogtDlshGiIWEii0WabuTbtI6SPP57gyzgloy6tLrGIKKMpItvsKWiYqdj5oSmJfhm9PYiqrssZhXPkP2aN2IGBN5Wg1zcoOHoGsAo4doq9mhsr)iIOzcoOHoGYaCEGduJbOXbtVmJfhm9PYiqrssZhXPkPa0rD20g5hgMdBufPu0z)ue2pGSBkaDSLrhQ4qWoQT5Gm9(MePdacpfhc2rTrKaWU(MKYbKPhOIhFC)PE23fArMdG8ZNMyXbLIA0rsio)vkhqMEGkor9XrhEArc6xzgloy6tLrGIKKMpItvsTiNhDooZHnQ9wkhqMEGkJanahdnknPkRPa0XwgDOcaofqJb05OVwKKKSduMXIdM(uzeOijP5J4uLehc2rn9GNN5Wg1ElLditpqLrGgGJHgLMuL1uVdqhBz0Hka4uangqNJ(ArssYoGjk7TiLIo7Nsk6ND)GiIKYbKPhOQbN2qVtNgOJbfLzS4GPpvgbkssA(iovjrcJiJPoB6lds0pZHnQ9wkhqMEGkJanahdnknPkRPEhGo2YOdvaWPaAmGoh91IKKKDatIuk6SFkPOF29dt9wkhqMEGQgCAd9oDAGogLzS4GPpvgbkssA(iovjHstbFW0nh2OkLditpqLrGgGJHgLMuLTmRmJfhm9jXPkjrc6hgtdCmkZyXbtFsCQscCIAs2zDhsAoSrLYJhOFk0hWo7dDeWej7SYqC)sThiztKSZkdXjFQYrcKcIiIYEF8a9tH(a2zFOJaMizNvgI7xQ9acKIYmwCW0NeNQKmYdMU5WgvAWwtXHGDuBKFyOankZyXbtFsCQs6GKO(JddZHnQbOJTm6q1HKgzWd9hhgMObBnfkJndopy6kqdtukYCaKFUIdb7O2i)Wqfid0NiIOZ50ud2zF6ajzOp)LQCsYuuMXIdM(K4uL0a2zFtDpliqhj6N5WgvAWwtXHGDuBKFyOaYp3enyRPcqh1ztBKFyOaYp3easd2AQlbf26SPpButYDqfq(5LzS4GPpjovjrZD6SPVakiCAoSrLgS1uCiyh1g5hgkG8Znrd2AQa0rD20g5hgkG8ZnbG0GTM6sqHToB6Zg1KChubKFEzgloy6tItvs0ymXGqO3zoSrLgS1uCiyh1g5hgkqJYmwCW0NeNQKOhzcOBGrFZHnQ0GTMIdb7O2i)WqbAuMXIdM(K4uLudgi9itaZHnQ0GTMIdb7O2i)WqbAuMXIdM(K4uLe7cCEbp0cEmmh2Osd2AkoeSJAJ8ddfOrzgloy6tItvsGtudpKCAoSrLgS1uCiyh1g5hgkqJYmwCW0NeNQKaNOgEiP5yRHIt7mjsTBWaq(YyQPzGo0CyJknyRP4qWoQnYpmuGgerKiZbq(5koeSJAJ8ddvGKm0NYNkbsGMaqAWwtDjOWwNn9zJAsUdQankZyXbtFsCQscCIA4HKM7mjsfjn6hip0za4SlqZHnQImha5NR4qWoQnYpmubsYqF(lvzjqtImha5NRUeuyRZM(Srnj3bvbsYqF(lvzjWYmwCW0NeNQKaNOgEiP5otIubcKbAWa1sX5ehMdBufzoaYpxXHGDuBKFyOcKKH(u(uLNKjIOElLditpqfBOtxdorQYseruEqsKQKnjLditpqvdoTHENonqhdQYAkaDSLrhQMqd701ZldskkZyXbtFsCQscCIA4HKM7mjsDMGdnSZHhgMdBufzoaYpxXHGDuBKFyOcKKH(u(ujijter9wkhqMEGk2qNUgCIuLTmJfhm9jXPkjWjQHhsAUZKi1UrFdBD208CcjHd(GPBoSrvK5ai)Cfhc2rTr(HHkqsg6t5tvEsMiI6TuoGm9avSHoDn4ePklrer5bjrQs2KuoGm9avn40g6D60aDmOkRPa0XwgDOAcnStxpVmiPOmJfhm9jXPkjWjQHhsAUZKivswW0bQN2iEAsWjuyoSrvK5ai)Cfhc2rTr(HHkqsg6ZFPsGMOS3s5aY0du1GtBO3Ptd0XGQSer0bjr5tqsMIYmwCW0NeNQKaNOgEiP5otIujzbthOEAJ4PjbNqH5WgvrMdG8ZvCiyh1g5hgQajzOp)LkbAskhqMEGQgCAd9oDAGoguL1enyRPcqh1ztBKFyOanmrd2AQa0rD20g5hgQajzOp)LkLYk5EgcSNhGo2YOdvtOHD665LbjfMoij(lbj5YmwCW0NeNQKaNOgEiP5otIuN2mq(Ha6mO1ztFzqI(zoSr9GKivjterukLditpqvcEtiaQZMwK5ai)8PjkPuKsrN9try)aYUjrMdG8Zvbdaz)0tdoiufijd95VuLNjrMdG8ZvCiyh1g5hgQajzOp)LkbAsK5ai)C1LGcBD20NnQj5oOkqsg6ZFPsGuqerImha5NR4qWoQnYpmubsYqF(lv5rernyN9PdKKH(8xrMdG8ZvCiyh1g5hgQajzOpPGIYmcgbRwwCW0NeNQKC8RLGoGoWzoKIMdor9NnCGAbppO3rvwZHnQ0GTMIdb7O2i)WqbAqerainyRPUeuyRZM(Srnj3bvGgereqEQGbGSF6PbheQoOGqO3vMXIdM(K4uLKGhdnloy66bCEM7mjsvWdb4Gpy6ZYmwCW0NeNQKe8yOzXbtxpGZZCNjrQCIMpVakoQYAoSrLfhukQrhjH4u(uLYbKPhOItuFC0HNwKG(vMXIdM(K4uLKGhdnloy66bCEM7mjs1MdY07BoSrvKsrN9try)aYUPa0XwgDOIdb7O2MdY07xMXIdM(K4uLKGhdnloy66bCEM7mjsTbN2qVtNgOJH5WgvPCaz6bQSzPOonqhbOkzts5aY0du1GtBO3Ptd0XWuVPuKsrN9try)aYUPa0XwgDOIdb7O2MdY07trzgloy6tItvscEm0S4GPRhW5zUZKi10aDmmh2OkLditpqLnlf1Pb6iavjBQ3uksPOZ(PiSFaz3ua6ylJouXHGDuBZbz69POmJfhm9jXPkjbpgAwCW01d48m3zsKQiZbq(5tZHnQ9MsrkfD2pfH9di7McqhBz0HkoeSJABoitVpfLzS4GPpjovjj4XqZIdMUEaNN5otIuJ84dMU5WgvPCaz6bQAqNhAAWWPkzt9MsrkfD2pfH9di7McqhBz0HkoeSJABoitVpfLzS4GPpjovjj4XqZIdMUEaNN5otIuBqNhAAWWnh2OkLditpqvd68qtdgovzn1BkfPu0z)ue2pGSBkaDSLrhQ4qWoQT5Gm9(uuMvMXIdM(uXjsTf58OZXzoSrnaDSLrhQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0TiNNci)Ctusd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddfq(5MaqAWwtDjOWwNn9zJAsUdQaYpNctImha5NRUeuyRZM(Srnj3bvbsYqFsvYMOKgS1uCiyh1cBo6q18ybH)svkhqMEGkor9LhPMKLrlS5OdNMOKYJhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd95Vu7eaMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4G7RBzOzdkiIik79Xd0pva6OoBAJ8ddtImha5NR4qWoQnYpmubsYqFkFPCaz6bQU8i1KSmAaCW91Tm0SbferKiZbq(5koeSJAJ8ddvGKm0N)sTtaqbfLzS4GPpvCIeNQKAWa10dEEMdBuPmaDSLrhQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0nyGkG8ZnzeOuDNaqjRQf58OZXrbrerza6ylJoubaNcOXa6C0xlsss2bmDqsKQKPOmJfhm9PItK4uLulY5P9ukBoSrnaDSLrhQ6c4C0xdfqXanjYCaKFUIdb7O2i)Wqfijd9P8jijBsK5ai)C1LGcBD20NnQj5oOkqsg6tQs2eL0GTMIdb7OwyZrhQMhli8xQs5aY0duXjQV8i1KSmAHnhD40eLuE8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LANaWKiZbq(5koeSJAJ8ddvGKm0NYxkhqMEGQlpsnjlJgahCFDldnBqbrerzVpEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUVULHMnOGiIezoaYpxXHGDuBKFyOcKKH(8xQDcakOOmJfhm9PItK4uLulY5P9ukBoSrnaDSLrhQ6c4C0xdfqXanjYCaKFUIdb7O2i)Wqfijd9jvjBIskPuK5ai)C1LGcBD20NnQj5oOkqsg6t5lLditpqfBOjzz0a4G7RBzOV8inrd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfesbrerPiZbq(5Qlbf26SPpButYDqvGKm0NuLSjAWwtXHGDulS5OdvZJfe(lvPCaz6bQ4e1xEKAswgTWMJoCsbfMObBnva6OoBAJ8ddfq(5uuMXIdM(uXjsCQsIdb7OMeoNWbonh2OksPOZ(PiSFaz3ua6ylJouXHGDuBZbz69nrd2AkoeSJABoitVVAESGWFLLanjYCaKFUkyai7NEAWbHQajzOp)LQuoGm9av2CqMEF98ybH6dsIehLbfGhQpijAsK5ai)C1LGcBD20NnQj5oOkqsg6ZFPkLditpqLnhKP3xppwqO(GKiXrzqb4H6dsIeNfhmDvWaq2p90GdcvOmOa8q9bjrtImha5NR4qWoQnYpmubsYqF(lvPCaz6bQS5Gm9(65Xcc1hKejokdkapuFqsK4S4GPRcgaY(PNgCqOcLbfGhQpijsCwCW0vxckS1ztF2OMK7GkuguaEO(GKO5cBg6uLTmJfhm9PItK4uLehc2rn9GNN5WgvrkfD2pLu0p7(HPJhOFkoeSJAuyNMoij(RSs2KiZbq(5ksyezm1ztFzqI(PcKKH(0enyRPedKdbppO3PMhli8xcQmJfhm9PItK4uL0LGcBD20NnQj5oO5Wg1a0XwgDOAcnStxpVminzeOuDNaqjRcLMc(GPxMXIdM(uXjsCQsIdb7O2i)WWCyJAa6ylJounHg2PRNxgKMO0iqP6obGswfknf8btNiImcuQUtaOKvDjOWwNn9zJAsUdsrzgloy6tfNiXPkjsyezm1ztFzqI(zoSrvK5ai)Cfhc2rTr(HHkqsg6ZFP2dmjYCaKFU6sqHToB6Zg1KChufijd95Vu7bMOKgS1uCiyh1cBo6q18ybH)svkhqMEGkor9LhPMKLrlS5OdNMOKYJhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd95Vu7eaMezoaYpxXHGDuBKFyOcKKH(u(eifereL9(4b6NkaDuNnTr(HHjrMdG8ZvCiyh1g5hgQajzOpLpbsbrejYCaKFUIdb7O2i)Wqfijd95Vu7eauqrzgloy6tfNiXPkjuAk4dMU5Wg1dsIYNGKSPa0XwgDOAcnStxpVminjsPOZ(PKI(z3pmzeOuDNaqjRIegrgtD20xgKOFLzS4GPpvCIeNQKqPPGpy6MdBupijkFcsYMcqhBz0HQj0WoD98YG0enyRP4qWoQf2C0HQ5Xcc)LQuoGm9avCI6lpsnjlJwyZrhonjYCaKFU6sqHToB6Zg1KChufijd9jvjBsK5ai)Cfhc2rTr(HHkqsg6ZFP2jakZyXbtFQ4ejovjHstbFW0nh2OEqsu(eKKnfGo2YOdvtOHD665LbPjrMdG8ZvCiyh1g5hgQajzOpPkztusjLImha5NRUeuyRZM(Srnj3bvbsYqFkFPCaz6bQydnjlJgahCFDld9LhPjAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGqkiIikfzoaYpxDjOWwNn9zJAsUdQcKKH(KQKnrd2AkoeSJAHnhDOAESGWFPkLditpqfNO(YJutYYOf2C0HtkOWenyRPcqh1ztBKFyOaYpNcZH(HraACAyJknyRPMqd701Zlds18ybHuPbBn1eAyNUEEzqQizz0ZJfeAo0pmcqJtdjjraiFivzlZyXbtFQ4ejovjfmaK9tpn4GqZHnQImha5NRUeuyRZM(Srnj3bvbsYqF(lkdkapuFqs0eLuE8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LANaWKiZbq(5koeSJAJ8ddvGKm0NYxkhqMEGQlpsnjlJgahCFDldnBqbrerzVpEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUVULHMnOGiIezoaYpxXHGDuBKFyOcKKH(8xQDcakkZyXbtFQ4ejovjfmaK9tpn4GqZHnQImha5NR4qWoQnYpmubsYqF(lkdkapuFqs0eLusPiZbq(5Qlbf26SPpButYDqvGKm0NYxkhqMEGk2qtYYObWb3x3YqF5rAIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhliKcIiIsrMdG8ZvxckS1ztF2OMK7GQajzOpPkzt0GTMIdb7OwyZrhQMhli8xQs5aY0duXjQV8i1KSmAHnhD4Kckmrd2AQa0rD20g5hgkG8ZPOmJfhm9PItK4uLeaYNnDgoAoSrvK5ai)Cfhc2rTr(HHkqsg6tQs2eLusPiZbq(5Qlbf26SPpButYDqvGKm0NYxkhqMEGk2qtYYObWb3x3YqF5rAIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhliKcIiIsrMdG8ZvxckS1ztF2OMK7GQajzOpPkzt0GTMIdb7OwyZrhQMhli8xQs5aY0duXjQV8i1KSmAHnhD4Kckmrd2AQa0rD20g5hgkG8ZPOmJfhm9PItK4uL0LGcBD20NnQj5oO5WgvkPbBnfhc2rTWMJounpwq4VuLYbKPhOItuF5rQjzz0cBo6WjrezeOuDNaqjRkyai7NEAWbHuyIskpEG(Pcqh1ztBKFyysK5ai)Cva6OoBAJ8ddvGKm0N)sTtaysK5ai)Cfhc2rTr(HHkqsg6t5lLditpq1LhPMKLrdGdUVULHMnOGiIOS3hpq)ubOJ6SPnYpmmjYCaKFUIdb7O2i)Wqfijd9P8LYbKPhO6YJutYYObWb3x3YqZguqerImha5NR4qWoQnYpmubsYqF(l1obafLzS4GPpvCIeNQK4qWoQnYpmmh2OsjLImha5NRUeuyRZM(Srnj3bvbsYqFkFPCaz6bQydnjlJgahCFDld9LhPjAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGqkiIikfzoaYpxDjOWwNn9zJAsUdQcKKH(KQKnrd2AkoeSJAHnhDOAESGWFPkLditpqfNO(YJutYYOf2C0HtkOWenyRPcqh1ztBKFyOaYpVmJfhm9PItK4uLua6OoBAJ8ddZHnQ0GTMkaDuNnTr(HHci)CtusPiZbq(5Qlbf26SPpButYDqvGKm0NYxEs2enyRP4qWoQf2C0HQ5XccPsd2AkoeSJAHnhDOIKLrppwqifereLImha5NRUeuyRZM(Srnj3bvbsYqFsvYMObBnfhc2rTWMJounpwq4VuLYbKPhOItuF5rQjzz0cBo6WjfuyIsrMdG8ZvCiyh1g5hgQajzOpLVSYJiIaqAWwtDjOWwNn9zJAsUdQanOOmJfhm9PItK4uL00g2oO3PnYpmmh2OkYCaKFUIdb7OodAvGKm0NYNajIOEF8a9tXHGDuNbDzgloy6tfNiXPkjoeSJA6bppZHnQIuk6SFkc7hq2nfGo2YOdvCiyh12CqMEFt0GTMIdb7O2i)WqbAycaPbBnvWaq2p90Gdc1sbhogmnCaV(Q5XccPkNmzeOuDNaqjRIdb7OodAtS4Gsrn6ijeN)2lkZyXbtFQ4ejovjXHGDutZrWDO5WgvrkfD2pfH9di7McqhBz0HkoeSJABoitVVjAWwtXHGDuBKFyOanmbG0GTMkyai7NEAWbHAPGdhdMgoGxF18ybHuLtLzS4GPpvCIeNQK4qWoQPh88mh2OksPOZ(PiSFaz3ua6ylJouXHGDuBZbz69nrd2AkoeSJAJ8ddfOHjkbYtfmaK9tpn4GqvGKm0NYxoserainyRPcgaY(PNgCqOwk4WXGPHd41xbAqHjaKgS1ubdaz)0tdoiulfC4yW0Wb86RMhli8x5KjwCqPOgDKeItQeuzgloy6tfNiXPkjoeSJ6mOnh2OksPOZ(PiSFaz3ua6ylJouXHGDuBZbz69nrd2AkoeSJAJ8ddfOHjaKgS1ubdaz)0tdoiulfC4yW0Wb86RMhliKkbvMXIdM(uXjsCQsIdb7OMMJG7qZHnQIuk6SFkc7hq2nfGo2YOdvCiyh12CqMEFt0GTMIdb7O2i)WqbAycaPbBnvWaq2p90Gdc1sbhogmnCaV(Q5XccPkVYmwCW0NkorItvsCiyh1OmgJCct3CyJQiLIo7NIW(bKDtbOJTm6qfhc2rTnhKP33enyRP4qWoQnYpmuGgMmcuQUtaOKNkyai7NEAWbHMyXbLIA0rsioLpbvMXIdM(uXjsCQsIdb7OgLXyKty6MdBufPu0z)ue2pGSBkaDSLrhQ4qWoQT5Gm9(MObBnfhc2rTr(HHc0Weasd2AQGbGSF6PbheQLcoCmyA4aE9vZJfesvwtS4Gsrn6ijeNYNGkZyXbtFQ4ejovjze4eDbQZMMe6aMdBuPbBnfaYNnDgoQanmbG0GTM6sqHToB6Zg1KChubAycaPbBn1LGcBD20NnQj5oOkqsg6ZFPsd2AkJaNOlqD20KqhqrYYONhliSNZIdMUIdb7OMEWZtHYGcWd1hKenrjLhpq)ubotNDbAIfhukQrhjH48x5efereloOuuJoscX5VeifMOS3bOJTm6qfhc2rnDssZbaj6hreDC0HNYg5XzRmeN8jicKIYmwCW0NkorItvsCiyh10dEEMdBuPbBnfaYNnDgoQanmrjLhpq)ubotNDbAIfhukQrhjH48x5efereloOuuJoscX5VeifMOS3bOJTm6qfhc2rnDssZbaj6hreDC0HNYg5XzRmeN8jicKIYmwCW0NkorItvstqdm8ukxMXIdM(uXjsCQsIdb7OMMJG7qZHnQ0GTMIdb7OwyZrhQMhliu(uPKfhukQrhjH4SNrwkmfGo2YOdvCiyh10jjnhaKOFMoo6WtzJ84SvgI7xcIalZyXbtFQ4ejovjXHGDutZrWDO5WgvAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGWYmwCW0NkorItvsCiyh1zqBoSrLgS1uCiyh1cBo6q18ybHuLSjkfzoaYpxXHGDuBKFyOcKKH(u(YsGeruVPuKsrN9try)aYUPa0XwgDOIdb7O2MdY07tbfLzS4GPpvCIeNQKC8SXqFiPbopZHnQugylWPntpqIiQ3huqi07OWenyRP4qWoQf2C0HQ5XccPsd2AkoeSJAHnhDOIKLrppwqyzgloy6tfNiXPkjoeSJAs4Cch40CyJknyRPedKdbppO3PcKfNPa0XwgDOIdb7O2MdY07BIskpEG(PysJbSbf8bt3eloOuuJoscX5V9akiIiwCqPOgDKeIZFjqkkZyXbtFQ4ejovjXHGDutcNt4aNMdBuPbBnLyGCi45b9ovGS4mD8a9tXHGDuJc70easd2AQlbf26SPpButYDqfOHjkpEG(PysJbSbf8btNiIyXbLIA0rsio)Thrrzgloy6tfNiXPkjoeSJAs4Cch40CyJknyRPedKdbppO3PcKfNPJhOFkM0yaBqbFW0nXIdkf1OJKqC(RCQmJfhm9PItK4uLehc2rnkJXiNW0nh2Osd2AkoeSJAHnhDOAESGWFPbBnfhc2rTWMJourYYONhliSmJfhm9PItK4uLehc2rnkJXiNW0nh2Osd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfeAYiqP6obGswfhc2rnnhb3HLzS4GPpvCIeNQKqPPGpy6Md9dJa040Wgvs2zLH4Kp1EabAo0pmcqJtdjjraiFivzlZkZyXbtFQe8qao4dM(KQuoGm9an3zsKQnlf1Pb6iG5Pb1jEMlLhGivznh2OkLditpqLnlf1Pb6iavjBYiqP6obGswfknf8bt3uVPmaDSLrhQMqd701ZldsIikaDSLrhQoK0idEO)4WGIYmwCW0NkbpeGd(GPpjovjjLditpqZDMePAZsrDAGocyEAqDIN5s5bisvwZHnQs5aY0duzZsrDAGocqvYMObBnfhc2rTr(HHci)CtImha5NR4qWoQnYpmubsYqFAIYa0XwgDOAcnStxpVmijIOa0XwgDO6qsJm4H(JddkkZyXbtFQe8qao4dM(K4uLKuoGm9an3zsKAd68qtdgU5Pb1jEMlLhGivznh2Osd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfeAQ30GTMkahOoB6ZoqCQanm1GD2Noqsg6ZFPsjLKSZY5floy6koeSJA6bppLiNhf9CwCW0vCiyh10dEEkuguaEO(GKifLzeSALZGNng1Y12ahJ(1opwqicuRnhKP3V2mQf61IYGcWdRnyVdR9dE21sSKKMdas0VYmwCW0NkbpeGd(GPpjovjjLditpqZDMePIKg5hgiGMMJG7qZtdQt8mxkparQ0GTMIdb7O2MdY07RMhliu(uLLajIikdqhBz0HkoeSJA6KKMdas0pthhD4PSrEC2kdX9lbrGuuMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1bppnBObNO5ayJbhhvjBEAqDIN5WgvAWwtXHGDuBKFyOanmrPuoGm9avdEEA2qdorQsMiIoijkFQs5aY0dun45Pzdn4ejUSeifMlLhGi1dsILzeSA7PqWowBVgjaSRFTDqP4SwUwPCaz6bwltMG(vB2QvaeMxln4v7h(FmQfCI1Y12g8vlopijFW0R1gduv7p2yTtiPOwJiLcbqGAdKKH(uJYyGIdbQfLXiW5eMETajoR1ZR2VmiS2pCmQTLrTgrca76xlaiw7L1E2yT0GX86xRZhyG1MTApBSwbqOkZyXbtFQe8qao4dM(K4uLKuoGm9an3zsKkopijFiGMn0Imha5NBEAqDIN5s5bisLsrMdG8ZvCiyh1g5hgkaWGpy69CkLTNHsjRKmb1ZfPdacpfhc2rTrKaWU(QGDcPGck6zO8GKypJuoGm9avdEEA2qdorkkZyXbtFQe8qao4dM(K4uLKuoGm9an3zsK6bjrnOFWHMnmpnOoXZCyJQiDaq4P4qWoQnIea213CP8aePkLditpqfopijFiGMn0Imha5NxMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1dsIAq)GdnByEAqDIN5Wg1ElshaeEkoeSJAJibGD9nxkparQImha5NR4qWoQnYpmubsYqFwMrWQvoa)pg1cGdUFT9uVwlOrTxwR8K8ef12YO2FYRhxMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1dsIAq)GdnByEAqLKLXCP8aePkYCaKFU6sqHToB6Zg1KChufijd9P5WgvkfzoaYpxDjOWwNn9zJAsUdQcKKH(SNrkhqMEGQdsIAq)GdnBqXVYtYLzeSATGUaRLGdKUFTWzTtqHDTCTg5hgnWrTxaDcXR2wg1kN)(bKDZR9d)pg1opOGWAVS2ZgR9(YAjHo4H1k6lgyTG(bh1(H12HxTCT2Wo7Arpb7SRnyNWAZwTgrca76xMXIdM(uj4HaCWhm9jXPkjPCaz6bAUZKi1dsIAq)GdnByEAqLKLXCP8aePEb0jep1mbhd8oO3Pdq6(krMdG8ZvbsYqFAoSrvKoai8uCiyh1grca76BsKoai8uCiyh1grca76Rc2j8xc0e2dbHggiGAMGJbEh070biDFtIuk6SFkc7hq2nfGo2YOdvCiyh12CqME)YmcwTYb4)XOwaCW9R9N86X1cAu7L1kpjprrTTmQTN61YmwCW0NkbpeGd(GPpjovjjLditpqZDMePANdaO3PV8inpnOoXZCP8aePkYCaKFU6sqHToB6Zg1KChufid03KuoGm9avhKe1G(bhA24x5j5YmcwTeCmaK9RwldoiSwGeN165vlKKebG8HJ(1AaE1cAu7zJ1kfC4yW0Wb86xlasd2A1oZAHxTc2RLgRfa2Aqb44Q9YAbGtbgETNnF1(H)dSw(Q9SXAj4HrE21kfC4yW0Wb86x78ybHLzS4GPpvcEiah8btFsCQsskhqMEGM7mjsTNfCEAWjcONgCqO5Pb1jEMlLhGivkncuQUtaOKvfmaK9tpn4GqIiYiqP6obGsEQGbGSF6Pbhesergbkv3jaueKkyai7NEAWbHuycaPbBnvWaq2p90Gdc1sbhogmnCaV(kG8ZlZyXbtFQe8qao4dM(K4uLKuoGm9an3zsKAcEtiaQZMwK5ai)8P5Pb1jEMlLhGivAWwtXHGDuBKFyOaYp3enyRPcqh1ztBKFyOaYp3easd2AQlbf26SPpButYDqfq(5M6TuoGm9av9SGZtdora90GdcnbG0GTMkyai7NEAWbHAPGdhdMgoGxFfq(5LzS4GPpvcEiah8btFsCQsskhqMEGM7mjsDESGqTnhKP3380G6epZLYdqKAa6ylJouXHGDuBZbz69nrjLIuk6SFkc7hq2njYCaKFUkyai7NEAWbHQajzOp)vkhqMEGkBoitVVEESGq9bjrkOOmRmJGvBVgWmGhKGhwl4e6D12fW5OFTqbumWA)GNDTSHQw5Wjwl8Q9dE21E5rwBE2y8bNOQmJfhm9PsK5ai)8j1wKZt7Pu2CyJAa6ylJou1fW5OVgkGIbAsK5ai)Cfhc2rTr(HHkqsg6t5tqs2KiZbq(5Qlbf26SPpButYDqvGmqFtusd2AkoeSJAHnhDOAESGWFPkLditpq1LhPMKLrlS5OdNMOKYJhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd95Vu7eaMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4G7RBzOzdkiIik79Xd0pva6OoBAJ8ddtImha5NR4qWoQnYpmubsYqFkFPCaz6bQU8i1KSmAaCW91Tm0SbferKiZbq(5koeSJAJ8ddvGKm0N)sTtaqbfLzS4GPpvImha5Npjovj1ICEApLYMdBudqhBz0HQUaoh91qbumqtImha5NR4qWoQnYpmubYa9nrzVpEG(PqFa7Sp0raIiIYJhOFk0hWo7dDeWej7SYqCYNAVqYuqHjkPuK5ai)C1LGcBD20NnQj5oOkqsg6t5lRKnrd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfesbrerPiZbq(5Qlbf26SPpButYDqvGKm0NuLSjAWwtXHGDulS5OdvZJfesvYuqHjAWwtfGoQZM2i)WqbKFUjs2zLH4KpvPCaz6bQydnj0HKGKAs2zTH4kZyXbtFQezoaYpFsCQsQf58OZXzoSrnaDSLrhQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0TiNNci)Ctusd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddfq(5MaqAWwtDjOWwNn9zJAsUdQaYpNctImha5NRUeuyRZM(Srnj3bvbsYqFsvYMOKgS1uCiyh1cBo6q18ybH)svkhqMEGQlpsnjlJwyZrhonrjLhpq)ubOJ6SPnYpmmjYCaKFUkaDuNnTr(HHkqsg6ZFP2jamjYCaKFUIdb7O2i)Wqfijd9P8LYbKPhO6YJutYYObWb3x3YqZguqeru27JhOFQa0rD20g5hgMezoaYpxXHGDuBKFyOcKKH(u(s5aY0duD5rQjzz0a4G7RBzOzdkiIirMdG8ZvCiyh1g5hgQajzOp)LANaGckkZyXbtFQezoaYpFsCQsQbdutp45zoSrnaDSLrhQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0nyGkG8ZnzeOuDNaqjRQf58OZXvMrWQTxzyuBpo)P2p4zxBp1R1cB1cV)ZAfjj07Qf0O2zMUQ2EzRw4v7hCmQLgRfCIa1(bp7A)jVES51k45vl8QDoGD23OFT0yldSmJfhm9PsK5ai)8jXPkjsyezm1ztFzqI(zoSrLYEhGo2YOdvtOHD665Lbjrerd2AQj0WoD98YGubAqHjrMdG8ZvxckS1ztF2OMK7GQajzOp)vkhqMEGkY80gbkqeqF5rQP7terukLditpq1bjrnOFWHMnKVuoGm9avK5Pjzz0a4G7RBzOzdtImha5NRUeuyRZM(Srnj3bvbsYqFkFPCaz6bQiZttYYObWb3x3YqF5rsrzgloy6tLiZbq(5tItvsKWiYyQZM(YGe9ZCyJQiZbq(5koeSJAJ8ddvGmqFtu27JhOFk0hWo7dDeGiIO84b6Nc9bSZ(qhbmrYoRmeN8P2lKmfuyIskfzoaYpxDjOWwNn9zJAsUdQcKKH(u(s5aY0duXgAswgnao4(6wg6lpst0GTMIdb7OwyZrhQMhliKknyRP4qWoQf2C0Hkswg98ybHuqerukYCaKFU6sqHToB6Zg1KChufijd9jvjBIgS1uCiyh1cBo6q18ybHuLmfuyIgS1ubOJ6SPnYpmua5NBIKDwzio5tvkhqMEGk2qtcDijiPMKDwBiUYmwCW0NkrMdG8ZNeNQKAdCAlcUDMdBuLYbKPhOkbVjea1ztlYCaKF(0eLZeCqdDaL0CWhCG6zoKI(rerZeCqdDaLb48ahOgdqJdMofLzeSA7PXh3Fwl4eRfa5ZModhR9dE21YgQA7LTAV8iRfoRnqgOFT8S2pCmmVwsMqS2jyG1EzTcEE1cVAPXwgyTxEKQYmwCW0NkrMdG8ZNeNQKaq(SPZWrZHnQImha5NRUeuyRZM(Srnj3bvbYa9nrd2AkoeSJAHnhDOAESGWFPkLditpq1LhPMKLrlS5OdNMezoaYpxXHGDuBKFyOcKKH(8xQDcGYmwCW0NkrMdG8ZNeNQKaq(SPZWrZHnQImha5NR4qWoQnYpmubYa9nrzVpEG(PqFa7Sp0raIiIYJhOFk0hWo7dDeWej7SYqCYNAVqYuqHjkPuK5ai)C1LGcBD20NnQj5oOkqsg6t5lRKnrd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfesbrerPiZbq(5Qlbf26SPpButYDqvGmqFt0GTMIdb7OwyZrhQMhliKQKPGct0GTMkaDuNnTr(HHci)CtKSZkdXjFQs5aY0duXgAsOdjbj1KSZAdXvMrWQvoCI1on4GWAHTAV8iRLDGAzJA5aRn9Afa1YoqTFP))QLgRf0O2wg1osVdJApB2R9SXAjzzQfahCFZRLKje6D1obdS2pSwBwkwlF1oqEE1EFzTCiyhRvyZrhoRLDGApB(Q9YJS2pE6)VA7zbNxTGteqvMXIdM(ujYCaKF(K4uLuWaq2p90Gdcnh2OkYCaKFU6sqHToB6Zg1KChufijd9P8LYbKPhOkMAswgnao4(6wg6lpstImha5NR4qWoQnYpmubsYqFkFPCaz6bQIPMKLrdGdUVULHMnmr5Xd0pva6OoBAJ8ddtukYCaKFUkaDuNnTr(HHkqsg6ZFrzqb4H6dsIerKiZbq(5Qa0rD20g5hgQajzOpLVuoGm9avXutYYObWb3x3YqhPbferuVpEG(Pcqh1ztBKFyqHjAWwtXHGDulS5OdvZJfekF5zcaPbBn1LGcBD20NnQj5oOci)Ct0GTMkaDuNnTr(HHci)Ct0GTMIdb7O2i)WqbKFEzgbRw5Wjw70GdcR9dE21Yg1(zJETg5CcPhOQ2EzR2lpYAHZAdKb6xlpR9dhdZRLKjeRDcgyTxwRGNxTWRwASLbw7LhPQmJfhm9PsK5ai)8jXPkPGbGSF6PbheAoSrvK5ai)C1LGcBD20NnQj5oOkqsg6ZFrzqb4H6dsIMObBnfhc2rTWMJounpwq4VuLYbKPhO6YJutYYOf2C0HttImha5NR4qWoQnYpmubsYqF(lLOmOa8q9bjrIZIdMU6sqHToB6Zg1KChuHYGcWd1hKePOmJfhm9PsK5ai)8jXPkPGbGSF6PbheAoSrvK5ai)Cfhc2rTr(HHkqsg6ZFrzqb4H6dsIMOKYEF8a9tH(a2zFOJaereLhpq)uOpGD2h6iGjs2zLH4Kp1EHKPGctusPiZbq(5Qlbf26SPpButYDqvGKm0NYxkhqMEGk2qtYYObWb3x3YqF5rAIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhliKcIiIsrMdG8ZvxckS1ztF2OMK7GQajzOpPkzt0GTMIdb7OwyZrhQMhliKQKPGct0GTMkaDuNnTr(HHci)CtKSZkdXjFQs5aY0duXgAsOdjbj1KSZAdXrrzgbRw5Wjw7LhzTFWZUw2OwyRw49Fw7h8SHETNnwljltTa4G7RQTx2Q1ZZ8AbNyTFWZU2inQf2Q9SXApEG(vlCw7XeIU51YoqTW7)S2p4zd9ApBSwswMAbWb3xvMXIdM(ujYCaKF(K4uL0LGcBD20NnQj5oO5Wgvk7Da6ylJounHg2PRNxgKerenyRPMqd701ZldsfObfMObBnfhc2rTWMJounpwq4VuLYbKPhO6YJutYYOf2C0HttImha5NR4qWoQnYpmubsYqF(lvuguaEO(GKOjs2zLH4KVuoGm9avSHMe6qsqsnj7S2qCMObBnva6OoBAJ8ddfq(5LzS4GPpvImha5NpjovjDjOWwNn9zJAsUdAoSrLgS1uCiyh1cBo6q18ybH)svkhqMEGQlpsnjlJwyZrhonD8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LkkdkapuFqs0KuoGm9avhKe1G(bhA2q(s5aY0duD5rQjzz0a4G7RBzOzJYmwCW0NkrMdG8ZNeNQKUeuyRZM(Srnj3bnh2Osd2AkoeSJAHnhDOAESGWFPkLditpq1LhPMKLrlS5OdNMOS3hpq)ubOJ6SPnYpmiIirMdG8ZvbOJ6SPnYpmubsYqFkFPCaz6bQU8i1KSmAaCW91Tm0rAqHjPCaz6bQoijQb9do0SH8LYbKPhO6YJutYYObWb3x3YqZgLzeSALdNyTSrTWwTxEK1cN1METcGAzhO2V0)F1sJ1cAuBlJAhP3HrTNn71E2yTKSm1cGdUV51sYec9UANGbw7zZxTFyT2SuSw0tWo7AjzNRLDGApB(Q9SXaRfoR1ZRwEeid0VwU2a0XAZwTg5hg1cKFUQmJfhm9PsK5ai)8jXPkjoeSJAJ8ddZHnQImha5NRUeuyRZM(Srnj3bvbsYqFkFPCaz6bQydnjlJgahCFDld9LhPjk7TiLIo7Nsk6ND)GiIezoaYpxrcJiJPoB6lds0pvGKm0NYxkhqMEGk2qtYYObWb3x3YqtMhfMObBnfhc2rTWMJounpwqivAWwtXHGDulS5OdvKSm65Xccnrd2AQa0rD20g5hgkG8ZnrYoRmeN8PkLditpqfBOjHoKeKutYoRnexzgbRw5WjwBKg1cB1E5rwlCwB61kaQLDGA)s))vlnwlOrTTmQDKEhg1E2Sx7zJ1sYYulao4(Mxljti07QDcgyTNngyTWP))QLhbYa9RLRnaDSwG8ZRLDGApB(QLnQ9l9)xT0OijXAzPmCW0dSwaWa6D1gGoQkZyXbtFQezoaYpFsCQskaDuNnTr(HH5WgvAWwtXHGDuBKFyOaYp3eLImha5NRUeuyRZM(Srnj3bvbsYqFkFPCaz6bQI0qtYYObWb3x3YqF5rserImha5NR4qWoQnYpmubsYqF(lvPCaz6bQU8i1KSmAaCW91Tm0SbfMObBnfhc2rTWMJounpwqivAWwtXHGDulS5OdvKSm65XccnjYCaKFUIdb7O2i)Wqfijd9P8LvYMezoaYpxDjOWwNn9zJAsUdQcKKH(u(Yk5YmwCW0NkrMdG8ZNeNQKM2W2b9oTr(HH5WgvPCaz6bQsWBcbqD20Imha5NplZiy1khoXAnsYAVS2zpeercEyTSxlkZfCTmDTqV2ZgR1rzUAfzoaYpV2pOdKFMxlOpW5Swc7hq2R9SrV20h9RfamGExTCiyhR1i)WOwaqS2lR1o)QLKDUwBqVl6xBWaq2VANgCqyTWzzgloy6tLiZbq(5tItvsgborxG6SPjHoG5Wg1JhOFQa0rD20g5hgMObBnfhc2rTr(HHc0WenyRPcqh1ztBKFyOcKKH(83obGIKLPmJfhm9PsK5ai)8jXPkjJaNOlqD20KqhWCyJkasd2AQlbf26SPpButYDqfOHjaKgS1uxckS1ztF2OMK7GQajzOp)LfhmDfhc2rnjCoHdCQqzqb4H6dsIM6TiLIo7NIW(bK9YmwCW0NkrMdG8ZNeNQKmcCIUa1zttcDaZHnQ0GTMkaDuNnTr(HHc0WenyRPcqh1ztBKFyOcKKH(83obGIKLXKiZbq(5kuAk4dMUkqgOVjrMdG8ZvxckS1ztF2OMK7GQajzOpn1BrkfD2pfH9di7LzLzS4GPpvnOZdnny4u5qWoQjHZjCGtZHnQ0GTMsmqoe88GENkqwCMlSzOtv2YmwCW0NQg05HMgmCItvsCiyh10dEELzS4GPpvnOZdnny4eNQK4qWoQP5i4oSmRmJGvRCGn61gGUd9UAr4zJrTNnwRLvTzu7pYb1oWo0b4aItZR9dR9J9R2lRvotAwln2YaR9SXA)jVESK6PET2pOdKFQALdNyTWRwEw7mtVwEwlbx2R1AZZABqhoTrGAtWO2p8VuS2Pb6xTjyuRWMJoCwMXIdM(u1GtBO3Ptd0XGkknf8bt3CyJkLbOJTm6q1HKgzWd9hhgereLbOJTm6q1eAyNUEEzqAQ3s5aY0duzeOb4yOrPjvzPGctusd2AQa0rD20g5hgkG8ZjIiJaLQ7eakzvCiyh10CeChsHjrMdG8ZvbOJ6SPnYpmubsYqFwMrWQTx2Q9d)lfRTbD40gbQnbJAfzoaYpV2pOdKFZAzhO2Pb6xTjyuRWMJoCAETgbmd4bj4H1kNjnRnLIrTOum6F2qVRwCmXYmwCW0NQgCAd9oDAGogeNQKqPPGpy6MdBupEG(Pcqh1ztBKFyysK5ai)Cva6OoBAJ8ddvGKm0NMezoaYpxXHGDuBKFyOcKKH(0enyRP4qWoQnYpmua5NBIgS1ubOJ6SPnYpmua5NBYiqP6obGswfhc2rnnhb3HLzS4GPpvn40g6D60aDmiovj1GbQPh88mh2OgGo2YOdvaWPaAmGoh91IKKKDat0GTMcaofqJb05OVwKKKSdOBropfOrzgloy6tvdoTHENonqhdItvsTiNN2tPS5Wg1a0XwgDOQlGZrFnuafd0ej7SYqCYVhrGLzS4GPpvn40g6D60aDmiovjXHGDutcNt4aNMdBudqhBz0HkoeSJABoitVVjAWwtXHGDuBZbz69vZJfe(lnyRP4qWoQT5Gm9(kswg98ybHMOKsAWwtXHGDuBKFyOaYp3KiZbq(5koeSJAJ8ddvGmqFkiIiaKgS1uxckS1ztF2OMK7GkqdkmxyZqNQSLzS4GPpvn40g6D60aDmiovjfGoQZM2i)WWCyJAa6ylJounHg2PRNxgKLzS4GPpvn40g6D60aDmiovjXHGDuNbT5WgvrMdG8ZvbOJ6SPnYpmubYa9lZyXbtFQAWPn070Pb6yqCQsIdb7OMEWZZCyJQiZbq(5Qa0rD20g5hgQazG(MObBnfhc2rTWMJounpwq4V0GTMIdb7OwyZrhQizz0ZJfewMXIdM(u1GtBO3Ptd0XG4uLeaYNnDgoAoSrT3bOJTm6q1HKgzWd9hhgerKiDaq4P6GTtNn9zJ6buyxMXIdM(u1GtBO3Ptd0XG4uLua6OoBAJ8dJYmcwT9YwTF4)aRLVAjzzQDESGWzTzRwcGaQLDGA)WATzPO))QfCIa12JZFQTpEMxl4eRLRDESGWAVSwJaLI(vljOlSHExTG(aNZAdq3HExTNnwRCUCqME)Ahyh6aC0VmJfhm9PQbN2qVtNgOJbXPkjoeSJAs4Cch40CyJknyRPedKdbppO3PcKfNjAWwtjgihcEEqVtnpwqivAWwtjgihcEEqVtrYYONhli0KiLIo7Nsk6ND)WKiZbq(5ksyezm1ztFzqI(PcKb6BQ3s5aY0duHKg5hgiGMMJG7qtImha5NR4qWoQnYpmubYa9lZiy1kXmi5XOFTFyTgmmQ1ipy61coXA)GNDT9uVAET0GxTWR2p4yu7GNxTJ07Qf9eSZU2wg1sNNDTNnwlbx2R1YoqT9uVw7h0bYVzTG(aNZAdq3HExTNnwRLvTzu7pYb1oWo0b4aIZYmwCW0NQgCAd9oDAGogeNQKmYdMU5Wg1EhGo2YOdvhsAKbp0FCyyIYEhGo2YOdvtOHD665LbjrerPuoGm9avgbAaogAuAsvwt0GTMIdb7OwyZrhQMhliKknyRP4qWoQf2C0Hkswg98ybHuqrzgloy6tvdoTHENonqhdItvsaiF20z4O5WgvAWwtfGoQZM2i)WqbKForezeOuDNaqjRIdb7OMMJG7WYmwCW0NQgCAd9oDAGogeNQKcgaY(PNgCqO5WgvAWwtfGoQZM2i)WqbKForezeOuDNaqjRIdb7OMMJG7WYmwCW0NQgCAd9oDAGogeNQKiHrKXuNn9Lbj6N5WgvAWwtfGoQZM2i)Wqfijd95VukhjU865bOJTm6q1eAyNUEEzqsrzgbRw5aB0RnaDh6D1E2yTY5Ybz69RDGDOdWrFZRfCI12t9AT0yldS2FYRhx7L1casAulxBdCm6x78ybHiqT0CWrhwMXIdM(u1GtBO3Ptd0XG4uLehc2rTr(HH5WgvPCaz6bQqsJ8ddeqtZrWDOjAWwtfGoQZM2i)WqbAyIss2zLH4(Ls5rGeNszLCpxKsrN9try)aYofuqer0GTMsmqoe88GENAESGqQ0GTMsmqoe88GENIKLrppwqifLzS4GPpvn40g6D60aDmiovjXHGDutZrWDO5WgvPCaz6bQqsJ8ddeqtZrWDOjAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGqt0GTMIdb7O2i)WqbAuMXIdM(u1GtBO3Ptd0XG4uL0LGcBD20NnQj5oO5WgvAWwtfGoQZM2i)WqbKForezeOuDNaqjRIdb7OMMJG7qIiYiqP6obGswvWaq2p90GdcjIiJaLQ7eakzvaiF20z4yzgloy6tvdoTHENonqhdItvsCiyh1g5hgMdBuncuQUtaOKvDjOWwNn9zJAsUdwMrWQvoCI12RzpU2lRD2dbrKGhwl71IYCbxBpfc2XAj2GNxTaGb07Q9SXA)jVESK6PET2pOdKF1c6dCoRnaDh6D12tHGDSw5mHDQQTx2QTNcb7yTYzc7Sw4S2JhOFiG51(H1ky))vl4eRTxZECTFWZg61E2yT)Kxpws9uVw7h0bYVAb9boN1(H1c9dJa04Q9SXA7PECTcB2DCyETZS2p8)yu7KLI1cpvzgloy6tvdoTHENonqhdItvsgborxG6SPjHoG5Wg1EF8a9tXHGDuJc70easd2AQlbf26SPpButYDqfOHjaKgS1uxckS1ztF2OMK7GQajzOp)LkLS4GPR4qWoQPh88uOmOa8q9bjXEonyRPmcCIUa1zttcDafjlJEESGqkkZiy12lB12RzpUwBE6)VAPr0RfCIa1cagqVR2ZgR9N86X1(bDG8Z8A)W)JrTGtSw4v7L1o7HGisWdRL9ArzUGRTNcb7yTeBWZRwOx7zJ1sWL9QK6PET2pOdKFQYmwCW0NQgCAd9oDAGogeNQKmcCIUa1zttcDaZHnQ0GTMIdb7O2i)WqbAyIgS1ubOJ6SPnYpmubsYqF(lvkzXbtxXHGDutp45Pqzqb4H6dsI9CAWwtze4eDbQZMMe6akswg98ybHuuMXIdM(u1GtBO3Ptd0XG4uLehc2rn9GNN5WgvG8ubdaz)0tdoiufijd9P8jqIicaPbBnvWaq2p90Gdc1sbhogmnCaV(Q5XccLVKlZiy1khG1(X(v7L1sYeI1obdS2pSwBwkwl6jyNDTKSZ12YO2ZgRf9dgyT9uVw7h0bYpZRfLIETWwTNng4)zTZdog1EqsS2ajzOd9UAtVwcUSxv12lV)ZAtF0VwA8omQ9YAPbdV2lRLGhgzTSduRCM0SwyR2a0DO3v7zJ1AzvBg1(JCqTdSdDaoG4uvMXIdM(u1GtBO3Ptd0XG4uLehc2rnnhb3HMdBufzoaYpxXHGDuBKFyOcKb6BIKDwziUFPuojzItPSsUNlsPOZ(PiSFazNckmrd2AkoeSJAHnhDOAESGqQ0GTMIdb7OwyZrhQizz0ZJfeAIYEhGo2YOdvtOHD665LbjrejLditpqLrGgGJHgLMuLLct9oaDSLrhQoK0idEO)4WWuVdqhBz0HkoeSJABoitVFzgbRwIXrWDyTt7eCauRNxT0yTGteOw(Q9SXArhO2SvBp1R1cB1kNjnf8btVw4S2azG(1YZAbI0Wa6D1kS5OdN1(bhJAjzcXAHxThtiw7i9omQ9YAPbdV2ZosWo7AdKKHo07QLKDUmJfhm9PQbN2qVtNgOJbXPkjoeSJAAocUdnh2Osd2AkoeSJAJ8ddfOHjAWwtXHGDuBKFyOcKKH(8xQDcatImha5NRqPPGpy6QajzOplZiy1smocUdRDANGdGA5Xh3Fwlnw7zJ1o45vRGNxTqV2ZgRLGl71A)Goq(vlpR9N86X1(bhJAdCEzG1E2yTcBo6WzTtd0VYmwCW0NQgCAd9oDAGogeNQK4qWoQP5i4o0CyJknyRPcqh1ztBKFyOanmrd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddvGKm0N)sTtayQ3bOJTm6qfhc2rTnhKP3VmJfhm9PQbN2qVtNgOJbXPkjoeSJAs4Cch40CyJkasd2AQlbf26SPpButYDqfOHPJhOFkoeSJAuyNMOKgS1uaiF20z4Oci)CIiIfhukQrhjH4KQSuycaPbBn1LGcBD20NnQj5oOkqsg6t5ZIdMUIdb7OMeoNWbovOmOa8q9bjrZf2m0PkR5ihJ(AHndDnSrLgS1uIbYHGNh070cB2DCOaYp3eL0GTMIdb7O2i)WqbAqeru27JhOFQukgg5hgiGjkPbBnva6OoBAJ8ddfObrejYCaKFUcLMc(GPRcKb6tbfuuMrWQTx2Q9d)hyTsr)S7hMxlKKebG8HJ(1coXAjacO2pB0RvWggiqTxwRNxTF88WAnIumRTfjzT948NYmwCW0NQgCAd9oDAGogeNQK4qWoQjHZjCGtZHnQIuk6SFkPOF29dt0GTMsmqoe88GENAESGqQ0GTMsmqoe88GENIKLrppwqyzgbRwRJJRwWj07QLaiGA7PECTF2OxBp1R1AZZAPr0RfCIaLzS4GPpvn40g6D60aDmiovjXHGDutcNt4aNMdBuPbBnLyGCi45b9ovGS4mjYCaKFUIdb7O2i)Wqfijd9PjkPbBnva6OoBAJ8ddfObrerd2AkoeSJAJ8ddfObfMlSzOtv2YmwCW0NQgCAd9oDAGogeNQK4qWoQZG2CyJknyRP4qWoQf2C0HQ5Xcc)LQuoGm9avxEKAswgTWMJoCwMXIdM(u1GtBO3Ptd0XG4uLehc2rn9GNN5WgvAWwtfGoQZM2i)WqbAqerKSZkdXjFzjWYmwCW0NQgCAd9oDAGogeNQKqPPGpy6MdBuPbBnva6OoBAJ8ddfq(5MObBnfhc2rTr(HHci)CZH(HraACAyJkj7SYqCYNApGanh6hgbOXPHKKiaKpKQSLzS4GPpvn40g6D60aDmiovjXHGDutZrWDyzwzgbJGvRCOpbnmY4qGAfSlWHMfhmD58Uw5mPPGpy61(bhJAPXAD(adEm6xlDKeIETWwTI0bGhm9zTCG1sINQmJGrWQLfhm9PYMdY07tvWUahAwCW0nh2OYIdMUcLMc(GPRe2S74a6DMizNvgIt(u7reyzgbR2EzR2r(vB61sYoxl7a1kYCaKF(SwoWAfjj07Qf0W8A7YAzBKbQLDGArPzzgloy6tLnhKP3N4uLeknf8bt3CyJkj7SYqC)sLGKSjPCaz6bQsWBcbqD20Imha5Npnr5Xd0pva6OoBAJ8ddtImha5NRcqh1ztBKFyOcKKH(8xzLmfLzeSALdWA)y)Q9YANhliSwBoitVFTnWXOVQ2FSXAbNyTzRwzLJ1opwq4SwBmWAHZAVSwwisq)QTLrTNnw7bfew7aBxTPx7zJ1kSz3XrTSdu7zJ1scNt4aRf612gWo7tvMXIdM(uzZbz69jovjXHGDutcNt4aNMdBuPukhqMEGQ5Xcc12CqMEFIi6GK4VYkzkmrd2AkoeSJABoitVVAESGWFLvoAUWMHovzlZiy1khyJETGtO3vRCgPr)a5rTe8daNDbAETcEE1Y12WVArzUGRLeoNWboR9ZgoWA)y4b9UABzu7zJ1sd2A1YxTNnw7844QnB1E2yTnyN9vMXIdM(uzZbz69jovjXHGDutcNt4aNMdBuXEii0WabuiPr)a5HodaNDbA6GK4VeKKnDzx3avImha5NpnjYCaKFUcjn6hip0za4SlqvGKm0NYxw5ypWuVzXbtxHKg9dKh6maC2fOcaoz6bcuMXIdM(uzZbz69jovjfmaK9tpn4GqZHnQs5aY0duHKg5hgiGMMJG7qtImha5NRUeuyRZM(Srnj3bvbsYqF(lvuguaEO(GKOjrMdG8ZvCiyh1g5hgQajzOp)LkLOmOa8q9bjXEU8OWeL9g7HGqddeqntWXaVd6D6aKUprejshaeEkoeSJAJibGD9vb7ekFQeireDb0jep1mbhd8oO3Pdq6(krMdG8ZvbsYqF(lvkrzqb4H6dsI9C5rbfLzS4GPpv2CqMEFItvsxckS1ztF2OMK7GMdBuLYbKPhOQNfCEAWjcONgCqOjrMdG8ZvCiyh1g5hgQajzOp)LkkdkapuFqs0eL9g7HGqddeqntWXaVd6D6aKUprejshaeEkoeSJAJibGD9vb7ekFQeireDb0jep1mbhd8oO3Pdq6(krMdG8ZvbsYqF(lvuguaEO(GKifLzS4GPpv2CqMEFItvsCiyh1g5hgMdBuncuQUtaOKvDjOWwNn9zJAsUdwMXIdM(uzZbz69jovjfGoQZM2i)WWCyJQuoGm9aviPr(HbcOP5i4o0KiZbq(5QGbGSF6PbheQcKKH(8xQOmOa8q9bjrts5aY0duDqsud6hCOzd5tvEs2eL9wKoai8uCiyh1grca76ter9wkhqMEGkE8X9N6zFxOfzoaYpFserImha5NRUeuyRZM(Srnj3bvbsYqF(lvkrzqb4H6dsI9C5rbfLzS4GPpv2CqMEFItvsbdaz)0tdoi0CyJQuoGm9aviPr(HbcOP5i4o0KrGs1DcaLSQa0rD20g5hgLzS4GPpv2CqMEFItvsxckS1ztF2OMK7GMdBuLYbKPhOQNfCEAWjcONgCqOPElLditpqLDoaGEN(YJSmJGvRC4eRvEoqTCiyhRLMJG7WAHET9uVsCcoc(9ATPp6xlSvlXgzcmaNxTSdulF1oqEE1kVAjacywRrKcbcuMXIdM(uzZbz69jovjXHGDutZrWDO5WgvAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGqt0GTMkaDuNnTr(HHc0WenyRP4qWoQnYpmuGgMObBnfhc2rTnhKP3xnpwqO8PkRC0enyRP4qWoQnYpmubsYqF(lvwCW0vCiyh10CeChQqzqb4H6dsIMObBnf9itGb48uGgLzeSALdNyTYZbQLGl71AHET9uVwB6J(1cB1sSrMadW5vl7a1kVAjacywRrKIYmwCW0NkBoitVpXPkPa0rD20g5hgMdBuPbBnva6OoBAJ8ddfq(5MObBnf9itGb48uGgMOukhqMEGQdsIAq)GdnBiFcsYerKiZbq(5QGbGSF6PbheQcKKH(u(YkpkmrjnyRP4qWoQT5Gm9(Q5XccLpvzjqIiIgS1uIbYHGNh07uZJfekFQYsHjk7TiDaq4P4qWoQnIea21NiI6TuoGm9av84J7p1Z(UqlYCaKF(KIYmwCW0NkBoitVpXPkPa0rD20g5hgMdBuPbBnfhc2rTr(HHci)CtukLditpq1bjrnOFWHMnKpbjzIisK5ai)CvWaq2p90GdcvbsYqFkFzLhfMOS3I0baHNIdb7O2isayxFIiQ3s5aY0duXJpU)up77cTiZbq(5tkkZyXbtFQS5Gm9(eNQKcgaY(PNgCqO5WgvPCaz6bQqsJ8ddeqtZrWDOjkPbBnfhc2rTWMJounpwqO8PkpIisK5ai)Cfhc2rDg0QazG(uyIYEF8a9tfGoQZM2i)WGiIezoaYpxfGoQZM2i)Wqfijd9P8jqkmjLditpqfopijFiGMn0Imha5NlFQeKKnrzVfPdacpfhc2rTrKaWU(eruVLYbKPhOIhFC)PE23fArMdG8ZNuuMrWQvoWg9Adq3HExTgrca76BETGtS2lpYAP7xl8M4Ovl0RndamQ9YA5bSZRfE1(bp7AzJYmwCW0NkBoitVpXPkPlbf26SPpButYDqZHnQs5aY0duDqsud6hCOzJFjqjBskhqMEGQdsIAq)GdnBiFcsYMOS3ypeeAyGaQzcog4DqVthG09jIir6aGWtXHGDuBejaSRVkyNq5tLaPOmJfhm9PYMdY07tCQsIdb7OodAZHnQs5aY0du1Zcopn4eb0tdoi0enyRP4qWoQf2C0HQ5Xcc)LgS1uCiyh1cBo6qfjlJEESGWYmwCW0NkBoitVpXPkjoeSJAAocUdnh2OcG0GTMkyai7NEAWbHAPGdhdMgoGxF18ybHubqAWwtfmaK9tpn4GqTuWHJbtdhWRVIKLrppwqyzgloy6tLnhKP3N4uLehc2rn9GNN5WgvPCaz6bQ6zbNNgCIa6PbheserucG0GTMkyai7NEAWbHAPGdhdMgoGxFfOHjaKgS1ubdaz)0tdoiulfC4yW0Wb86RMhli8xaKgS1ubdaz)0tdoiulfC4yW0Wb86Rizz0ZJfesrzgbRw5Wjwlj0H1smocUdRLgVpe9AdgaY(v70GdcN1cB1c6ayulXKGA)GNDcE1cGdUp07QLGJbGSF1AzWbH1cbqEm6xMXIdM(uzZbz69jovjXHGDutZrWDO5WgvAWwtfGoQZM2i)WqbAyIgS1uCiyh1g5hgkG8Znrd2Ak6rMadW5PanmjYCaKFUkyai7NEAWbHQajzOp)LQSs2enyRP4qWoQT5Gm9(Q5XccLpvzLJLzeSALdNyTzqxB61kaQf0h4CwlBulCwRijHExTGg1oZ0lZyXbtFQS5Gm9(eNQK4qWoQZG2CyJknyRP4qWoQf2C0HQ5Xcc)LGmjLditpq1bjrnOFWHMnKVSs2eLImha5NRUeuyRZM(Srnj3bvbsYqFkFcKiI6TiDaq4P4qWoQnIea21NIYmwCW0NkBoitVpXPkjoeSJAs4Cch40CyJknyRPedKdbppO3PcKfNjAWwtXHGDuBKFyOanmxyZqNQSLzeSA7LTA)WA7WRwJ8dJAHEdCctVwaWa6D1oaNxTF4)XOwBwkwl6jyNDT288WAVS2o8QnBTA5ANxKExT0CeChwlaya9UApBS2inKeBu7h0bYVYmwCW0NkBoitVpXPkjoeSJAAocUdnh2Osd2AQa0rD20g5hgkqdt0GTMkaDuNnTr(HHkqsg6ZFPYIdMUIdb7OMeoNWbovOmOa8q9bjrt0GTMIdb7O2i)WqbAyIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhli0enyRP4qWoQT5Gm9(Q5Xccnrd2AkJ8ddn0BGty6kqdt0GTMIEKjWaCEkqJYmcwT9YwTFyTD4vRr(HrTqVboHPxlaya9UAhGZR2p8)yuRnlfRf9eSZUwBEEyTxwBhE1MTwTCTZlsVRwAocUdRfamGExTNnwBKgsInQ9d6a5N51oZA)W)JrTPp6xl4eRf9eSZUw6bpVzTqhEqEm6x7L12HxTxwBlbJAf2C0HZYmwCW0NkBoitVpXPkjoeSJA6bppZHnQ0GTMYiWj6cuNnnj0buGgMOKgS1uCiyh1cBo6q18ybH)sd2AkoeSJAHnhDOIKLrppwqire1BkPbBnLr(HHg6nWjmDfOHjAWwtrpYeyaopfObfuuMrWQ9hBSwACE1coXAZwTgjzTWzTxwl4eRfE1EzT9qqOGWr)APbHdGAf2C0HZAbadO3vlBul3omQ9SX(12HxTaGKgiqT09R9SXAT5Gm9(1sZrWDyzgloy6tLnhKP3N4uLKrGt0fOoBAsOdyoSrLgS1uCiyh1cBo6q18ybH)sd2AkoeSJAHnhDOIKLrppwqOjAWwtXHGDuBKFyOankZiy1khG1(X(v7L1opwqyT2CqME)ABGJrFvT)yJ1coXAZwTYkhRDESGWzT2yG1cN1EzTSqKG(vBlJApBS2dkiS2b2UAtV2ZgRvyZUJJAzhO2ZgRLeoNWbwl0RTnGD2NQmJfhm9PYMdY07tCQsIdb7OMeoNWbonh2Osd2AkoeSJABoitVVAESGWFLvoAUWMHovznh6hgbOXrvwZH(HraAC6UrsZdQYwMXIdM(uzZbz69jovjXHGDutZrWDO5WgvAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGqts5aY0duHKg5hgiGMMJG7WYmwCW0NkBoitVpXPkjuAk4dMU5Wgvs2zLH4(vwcSmJGvlbFF0VwWjwl9GNxTxwlniCauRWMJoCwlSv7hwlpcKb6xRnlfRDMKyTTijRnd6YmwCW0NkBoitVpXPkjoeSJA6bppZHnQ0GTMIdb7OwyZrhQMhli0enyRP4qWoQf2C0HQ5Xcc)LgS1uCiyh1cBo6qfjlJEESGWYmcwTY5dog1(bp7AzYAb9boN1Yg1cN1kssO3vlOrTSdu7h(pWAh5xTPxlj7Czgloy6tLnhKP3N4uLehc2rnjCoHdCAoSrT3ukLditpq1bjrnOFWHMn(LQSs2ej7SYqC)sqsMcZf2m0PkR5q)WianoQYAo0pmcqJt3nsAEqv2YmcwT9AKn4aN1(bp7Ah5xTK88WOV51Ad7SR1MNhAETzulDE21sY9R1ZRwBwkwl6jyNDTKSZ1EzTtqdJmUATZVAjzNRf6h6tOuS2GbGSF1on4GWAfSxlnAETZS2p8)yul4eRTbdSw6bpVAzhO2wKZJohxTF2Ox7i)Qn9AjzNlZyXbtFQS5Gm9(eNQKAWa10dEELzS4GPpv2CqMEFItvsTiNhDoUYSYmwCW0NQ0aDmO2GbQPh88mh2OgGo2YOdvaWPaAmGoh91IKKKDat0GTMcaofqJb05OVwKKKSdOBropfOrzgloy6tvAGogeNQKAropTNszZHnQbOJTm6qvxaNJ(AOakgOjs2zLH4KFpIalZyXbtFQsd0XG4uLeaYNnDgowMXIdM(uLgOJbXPkPGbGSF6PbheAoSrLKDwzio5lNKCzgloy6tvAGogeNQKiHrKXuNn9Lbj6xzgloy6tvAGogeNQKM2W2b9oTr(HH5WgvAWwtXHGDuBKFyOaYp3KiZbq(5koeSJAJ8ddvGKm0NLzS4GPpvPb6yqCQsIdb7OodAZHnQImha5NR4qWoQnYpmubYa9nrd2AkoeSJAHnhDOAESGWFPbBnfhc2rTWMJourYYONhliSmJfhm9PknqhdItvsCiyh10dEEMdBufPu0z)usr)S7hMezoaYpxrcJiJPoB6lds0pvGKm0NYVhiNkZyXbtFQsd0XG4uL0LGcBD20NnQj5oyzgloy6tvAGogeNQK4qWoQnYpmkZyXbtFQsd0XG4uLua6OoBAJ8ddZHnQ0GTMIdb7O2i)WqbKFEzgbRw5WjwBVM94AVS2zpeercEyTSxlkZfCT9uiyhRLydEE1cagqVR2ZgR9N86XsQN61A)Goq(vlOpW5S2a0DO3vBpfc2XALZe2PQ2EzR2EkeSJ1kNjSZAHZApEG(HaMx7hwRG9)xTGtS2En7X1(bpBOx7zJ1(tE9yj1t9ATFqhi)Qf0h4Cw7hwl0pmcqJR2ZgRTN6X1kSz3XH51oZA)W)JrTtwkwl8uLzS4GPpvPb6yqCQsYiWj6cuNnnj0bmh2O27JhOFkoeSJAuyNMaqAWwtDjOWwNn9zJAsUdQanmbG0GTM6sqHToB6Zg1KChufijd95VuPKfhmDfhc2rn9GNNcLbfGhQpij2ZPbBnLrGt0fOoBAsOdOizz0ZJfesrzgbR2EzR2En7X1AZt))vlnIETGteOwaWa6D1E2yT)KxpU2pOdKFMx7h(FmQfCI1cVAVS2zpeercEyTSxlkZfCT9uiyhRLydEE1c9ApBSwcUSxLup1R1(bDG8tvMXIdM(uLgOJbXPkjJaNOlqD20KqhWCyJknyRP4qWoQnYpmuGgMObBnva6OoBAJ8ddvGKm0N)sLswCW0vCiyh10dEEkuguaEO(GKypNgS1ugborxG6SPjHoGIKLrppwqifLzS4GPpvPb6yqCQsIdb7OMEWZZCyJkqEQGbGSF6PbheQcKKH(u(eirebG0GTMkyai7NEAWbHAPGdhdMgoGxF18ybHYxYLzeSA7PXh3FwlX4i4oSw(Q9SXArhO2SvBp1R1(zJETbO7qVR2ZgRTNcb7yTY5Ybz69RDGDOdWr)YmwCW0NQ0aDmiovjXHGDutZrWDO5WgvAWwtXHGDuBKFyOanmrd2AkoeSJAJ8ddvGKm0N)2jamfGo2YOdvCiyh12CqME)YmcwT904J7pRLyCeChwlF1E2yTOduB2Q9SXAj4YET2pOdKF1(zJETbO7qVR2ZgRTNcb7yTY5Ybz69RDGDOdWr)YmwCW0NQ0aDmiovjXHGDutZrWDO5WgvAWwtfGoQZM2i)WqbAyIgS1uCiyh1g5hgkG8Znrd2AQa0rD20g5hgQajzOp)LANaWua6ylJouXHGDuBZbz69lZyXbtFQsd0XG4uLehc2rnjCoHdCAoSrfaPbBn1LGcBD20NnQj5oOc0W0Xd0pfhc2rnkSttusd2AkaKpB6mCubKForeXIdkf1OJKqCsvwkmbG0GTM6sqHToB6Zg1KChufijd9P8zXbtxXHGDutcNt4aNkuguaEO(GKO5cBg6uL1CKJrFTWMHUg2Osd2AkXa5qWZd6DAHn7ooua5NBIsAWwtXHGDuBKFyOaniIik79Xd0pvkfdJ8ddeWeL0GTMkaDuNnTr(HHc0GiIezoaYpxHstbFW0vbYa9PGckkZyXbtFQsd0XG4uLehc2rnjCoHdCAoSrLgS1uIbYHGNh07uZJfesLgS1uIbYHGNh07uKSm65XccnjsPOZ(PKI(z3pkZyXbtFQsd0XG4uLehc2rnjCoHdCAoSrLgS1uIbYHGNh07ubYIZKiZbq(5koeSJAJ8ddvGKm0NMOKgS1ubOJ6SPnYpmuGgerenyRP4qWoQnYpmuGguyUWMHovzlZyXbtFQsd0XG4uLehc2rDg0MdBuPbBnfhc2rTWMJounpwq4VuLYbKPhO6YJutYYOf2C0HZYmwCW0NQ0aDmiovjXHGDutp45zoSrLgS1ubOJ6SPnYpmuGgerej7SYqCYxwcSmJfhm9PknqhdItvsO0uWhmDZHnQ0GTMkaDuNnTr(HHci)Ct0GTMIdb7O2i)WqbKFU5q)WianonSrLKDwzio5tThqGMd9dJa040qsseaYhsv2YmwCW0NQ0aDmiovjXHGDutZrWDyzwzgbJGvlloy6tvKhFW0PkyxGdnloy6MdBuzXbtxHstbFW0vcB2DCa9otKSZkdXjFQ9ic0eL9oaDSLrhQMqd701ZldsIiIgS1utOHD665LbPAESGqQ0GTMAcnStxpVmivKSm65XccPOmJGvRC4eRfLM1cB1(H)dS2r(vB61sYoxl7a1kYCaKF(SwoWAz6e8Q9YAPXAbnkZyXbtFQI84dMoXPkjuAk4dMU5Wg1EhGo2YOdvtOHD665LbPjs2zLH4(LQuoGm9avO0uBiotukYCaKFU6sqHToB6Zg1KChufijd95VuzXbtxHstbFW0vOmOa8q9bjrIisK5ai)Cfhc2rTr(HHkqsg6ZFPYIdMUcLMc(GPRqzqb4H6dsIereLhpq)ubOJ6SPnYpmmjYCaKFUkaDuNnTr(HHkqsg6ZFPYIdMUcLMc(GPRqzqb4H6dsIuqHjAWwtfGoQZM2i)WqbKFUjAWwtXHGDuBKFyOaYp3easd2AQlbf26SPpButYDqfq(5M6TrGs1DcaLSQlbf26SPpButYDWYmwCW0NQip(GPtCQscLMc(GPBoSrnaDSLrhQMqd701Zldst9wKsrN9tjf9ZUFysK5ai)Cfhc2rTr(HHkqsg6ZFPYIdMUcLMc(GPRqzqb4H6dsILzS4GPpvrE8btN4uLeknf8bt3CyJAa6ylJounHg2PRNxgKMePu0z)usr)S7hMezoaYpxrcJiJPoB6lds0pvGKm0N)sLfhmDfknf8btxHYGcWd1hKenjYCaKFU6sqHToB6Zg1KChufijd95VuPukhqMEGkY80gbkqeqF5rQP7tCwCW0vO0uWhmDfkdkapuFqsK4eefMezoaYpxXHGDuBKFyOcKKH(8xQukLditpqfzEAJaficOV8i109joloy6kuAk4dMUcLbfGhQpijsCcIIYmcwTeJJG7WAHTAH3)zThKeR9YAbNyTxEK1YoqTFyT2SuS2lZAjzVFTcBo6Wzzgloy6tvKhFW0jovjXHGDutZrWDO5WgvrMdG8ZvxckS1ztF2OMK7GQazG(MOKgS1uCiyh1cBo6q18ybHYxkhqMEGQlpsnjlJwyZrhonjYCaKFUIdb7O2i)Wqfijd95Vurzqb4H6dsIMizNvgIt(s5aY0duXgAsOdjbj1KSZAdXzIgS1ubOJ6SPnYpmua5Ntrzgloy6tvKhFW0jovjXHGDutZrWDO5WgvrMdG8ZvxckS1ztF2OMK7GQazG(MOKgS1uCiyh1cBo6q18ybHYxkhqMEGQlpsnjlJwyZrhonD8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LkkdkapuFqs0KuoGm9avhKe1G(bhA2q(s5aY0duD5rQjzz0a4G7RBzOzdkkZyXbtFQI84dMoXPkjoeSJAAocUdnh2OkYCaKFU6sqHToB6Zg1KChufid03eL0GTMIdb7OwyZrhQMhliu(s5aY0duD5rQjzz0cBo6WPjk79Xd0pva6OoBAJ8ddIisK5ai)Cva6OoBAJ8ddvGKm0NYxkhqMEGQlpsnjlJgahCFDldDKguyskhqMEGQdsIAq)GdnBiFPCaz6bQU8i1KSmAaCW91Tm0SbfLzS4GPpvrE8btN4uLehc2rnnhb3HMdBubqAWwtfmaK9tpn4GqTuWHJbtdhWRVAESGqQainyRPcgaY(PNgCqOwk4WXGPHd41xrYYONhli0eL0GTMIdb7O2i)WqbKForerd2AkoeSJAJ8ddvGKm0N)sTtaqHjkPbBnva6OoBAJ8ddfq(5erenyRPcqh1ztBKFyOcKKH(8xQDcakkZyXbtFQI84dMoXPkjoeSJA6bppZHnQs5aY0du1Zcopn4eb0tdoiKiIOeaPbBnvWaq2p90Gdc1sbhogmnCaV(kqdtainyRPcgaY(PNgCqOwk4WXGPHd41xnpwq4VainyRPcgaY(PNgCqOwk4WXGPHd41xrYYONhliKIYmwCW0NQip(GPtCQsIdb7OMEWZZCyJknyRPmcCIUa1zttcDafOHjaKgS1uxckS1ztF2OMK7GkqdtainyRPUeuyRZM(Srnj3bvbsYqF(lvwCW0vCiyh10dEEkuguaEO(GKyzgloy6tvKhFW0jovjXHGDutcNt4aNMdBubqAWwtDjOWwNn9zJAsUdQanmD8a9tXHGDuJc70eL0GTMca5ZModhva5NterS4Gsrn6ijeNuLLctucG0GTM6sqHToB6Zg1KChufijd9P8zXbtxXHGDutcNt4aNkuguaEO(GKirejYCaKFUYiWj6cuNnnj0bubsYqFserIuk6SFkc7hq2PWCHndDQYAoYXOVwyZqxdBuPbBnLyGCi45b9oTWMDhhkG8ZnrjnyRP4qWoQnYpmuGgereL9(4b6NkLIHr(HbcyIsAWwtfGoQZM2i)WqbAqerImha5NRqPPGpy6QazG(uqbfLzeSAjG0NGKyTNnwlkJb7aiqTg5H(b5rT0GTwT8KnQ9YA98QDKtSwJ8q)G8OwJifZYmwCW0NQip(GPtCQsIdb7OMeoNWbonh2Osd2AkXa5qWZd6DQazXzIgS1uOmgSdGaAJ8q)G8qbAuMXIdM(uf5XhmDItvsCiyh1KW5eoWP5WgvAWwtjgihcEEqVtfilotusd2AkoeSJAJ8ddfObrerd2AQa0rD20g5hgkqdIicaPbBn1LGcBD20NnQj5oOkqsg6t5ZIdMUIdb7OMeoNWbovOmOa8q9bjrkmxyZqNQSLzS4GPpvrE8btN4uLehc2rnjCoHdCAoSrLgS1uIbYHGNh07ubYIZenyRPedKdbppO3PMhliKknyRPedKdbppO3Pizz0ZJfeAUWMHovzlZiy12tJpU)S2l6x7L1sZoH1saeqTTmQvK5ai)8A)Goq(nRLg8QfaK0O2ZgjRf2Q9SX()dSwMobVAVSwugdyGLzS4GPpvrE8btN4uLehc2rnjCoHdCAoSrLgS1uIbYHGNh07ubYIZenyRPedKdbppO3PcKKH(8xQusjnyRPedKdbppO3PMhliSNZIdMUIdb7OMeoNWbovOmOa8q9bjrkiENaqrYYqH5cBg6uLTmJfhm9PkYJpy6eNQKC8SXqFiPbopZHnQugylWPntpqIiQ3huqi07OWenyRP4qWoQf2C0HQ5XccPsd2AkoeSJAHnhDOIKLrppwqOjAWwtXHGDuBKFyOaYp3easd2AQlbf26SPpButYDqfq(5LzS4GPpvrE8btN4uLehc2rDg0MdBuPbBnfhc2rTWMJounpwq4VuLYbKPhO6YJutYYOf2C0HZYmwCW0NQip(GPtCQsAcAGHNszZHnQs5aY0duLG3ecG6SPfzoaYpFAIKDwziUFP2JiWYmwCW0NQip(GPtCQsIdb7OMEWZZCyJknyRPcWbQZM(SdeNkqdt0GTMIdb7OwyZrhQMhliu(euzgbRw58asAuRWMJoCwlSv7hwBJhJAPXr(v7zJ1ksFIHuSws25Ap7aN25aOw2bQfLMc(GPxlCw78GJrTPxRiZbq(5LzS4GPpvrE8btN4uLehc2rnnhb3HMdBu7Da6ylJounHg2PRNxgKMKYbKPhOkbVjea1ztlYCaKF(0enyRP4qWoQf2C0HQ5XccPsd2AkoeSJAHnhDOIKLrppwqOPJhOFkoeSJ6mOnjYCaKFUIdb7OodAvGKm0N)sTtayIKDwziUFP2JKSjrMdG8ZvO0uWhmDvGKm0NLzS4GPpvrE8btN4uLehc2rnnhb3HMdBudqhBz0HQj0WoD98YG0KuoGm9avj4nHaOoBArMdG8ZNMObBnfhc2rTWMJounpwqivAWwtXHGDulS5OdvKSm65XccnD8a9tXHGDuNbTjrMdG8ZvCiyh1zqRcKKH(8xQDcatKSZkdX9l1EKKnjYCaKFUcLMc(GPRcKKH(8xcsYLzeSALZdiPrTcBo6WzTWwTzqxlCwBGmq)YmwCW0NQip(GPtCQsIdb7OMMJG7qZHnQs5aY0duLG3ecG6SPfzoaYpFAIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhli00Xd0pfhc2rDg0MezoaYpxXHGDuNbTkqsg6ZFP2jamrYoRme3Vu7rs2KiZbq(5kuAk4dMUkqsg6ttu27a0XwgDOAcnStxpVmijIiAWwtnHg2PRNxgKQajzOp)LQS9akkZiy12tHGDSwIXrWDyTt7eCauBh6yWJr)APXApBS2bpVAf88QnB1E2yT9uVw7h0bYVYmwCW0NQip(GPtCQsIdb7OMMJG7qZHnQ0GTMIdb7O2i)WqbAyIgS1uCiyh1g5hgQajzOp)LANaWenyRP4qWoQf2C0HQ5XccPsd2AkoeSJAHnhDOIKLrppwqOjkfzoaYpxHstbFW0vbsYqFserbOJTm6qfhc2rTnhKP3NIYmcwT9uiyhRLyCeChw70obha12Hog8y0VwAS2ZgRDWZRwbpVAZwTNnwlbx2R1(bDG8RmJfhm9PkYJpy6eNQK4qWoQP5i4o0CyJknyRPcqh1ztBKFyOanmrd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddvGKm0N)sTtayIgS1uCiyh1cBo6q18ybHuPbBnfhc2rTWMJourYYONhli0eLImha5NRqPPGpy6QajzOpjIOa0XwgDOIdb7O2MdY07trzgbR2EkeSJ1smocUdRDANGdGAPXApBS2bpVAf88QnB1E2yT)KxpU2pOdKF1cB1cVAHZA98QfCIa1(bp7Aj4YET2mQTN61YmwCW0NQip(GPtCQsIdb7OMMJG7qZHnQ0GTMIdb7O2i)WqbKFUjAWwtfGoQZM2i)WqbKFUjaKgS1uxckS1ztF2OMK7GkqdtainyRPUeuyRZM(Srnj3bvbsYqF(l1obGjAWwtXHGDulS5OdvZJfesLgS1uCiyh1cBo6qfjlJEESGWYmcwTYb2Ox7zJ1EC0HxTWzTqVwuguaEyTb7DyTSdu7zJbwlCwlzgyTNn71Mowl6izFZRfCI1sZrWDyT8S2zMET8S2(jyT2SuSw0tWo7Af2C0HZAVSwB4vlpg1IoscXzTWwTNnwBpfc2XAjwssZbaj6xTdSdDao6xlCwl2dbHggiqzgloy6tvKhFW0jovjXHGDutZrWDO5WgvPCaz6bQqsJ8ddeqtZrWDOjAWwtXHGDulS5OdvZJfekFQuYIdkf1OJKqC2ZilfMyXbLIA0rsioLVSMObBnfaYNnDgoQaYpVmJfhm9PkYJpy6eNQK4qWoQrzmg5eMU5WgvPCaz6bQqsJ8ddeqtZrWDOjAWwtXHGDulS5OdvZJfe(lnyRP4qWoQf2C0Hkswg98ybHMyXbLIA0rsioLVSMObBnfaYNnDgoQaYpVmJfhm9PkYJpy6eNQK4qWoQPh88kZyXbtFQI84dMoXPkjuAk4dMU5WgvPCaz6bQsWBcbqD20Imha5NplZyXbtFQI84dMoXPkjoeSJAAocUdF37Epa]] )

    
end