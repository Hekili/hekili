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


    spec:RegisterPack( "Arcane", 20210627, [[daLtEgqivv0JiQqxIOIiztuKpPQQrreofs0QKQiEfcXSOO6wQQa2fj)cj0Wik6yeLwgrLEgrHMgsGUgcsBtQc5BsvKgNufQZjvbwhrbVJOIi18uvP7HK2hfLoOuf1crq9qeetKOIiUisaTrIkIYhrcqgjsaQtQQcALev9sIkIQzIe0nLQG2jcPFsuryOQQqlLOc8ukzQsv6QevK(krf0yPOyVQYFj1Gv6WOwms9yctgWLH2Su(mLA0sLtdA1QQa9Aey2kCBeTBQ(TOHtHJturTCHNROPRY1bA7ePVRQmEIOZlv16rcG5JqTFj)K917ZcGp8ru5kt5kRm7rYTNQKThrO9iz7bpRRVb(SmybbSn(SCMeFw9CiyhFwgC)rYaVEFwZeme4ZQ7oJPmqrkAdVoqALijP4esco4dMUi42rXjKuqXNfniCC)q)r)Sa4dFevUYuUYkZEKC7Pkz7reAps2E0ZAAGIhr7rY9z1bbaq)r)SaWP4z1dzBS2EoeSJL8Yd6yTYTNAETYvMYv2s(sE50jw713ak4rTwqscP2o2bgq3U2SvROJDhh1c9dJa04GPxl0NhYa1MTA)lyxGdnloy6)vpRbCEZxVpR0aDmE9(iQSVEFwOZ0de4r4NLiGhgq(zfGo2YWgvaWPaAmGoh91IKKKDaf6m9abQ1uT0GTMcaofqJb05OVwKKKSdOBropfOXZIfhm9NvdgOMEWZ7DpIk3xVpl0z6bc8i8ZseWddi)ScqhBzyJk7aoh91qbumqf6m9abQ1uTKSZkdXvRzRThqOplwCW0FwTiNN2tP87EevgF9(SyXbt)zbG81rNHJpl0z6bc8i87EeLc(69zHotpqGhHFwIaEya5Nfj7SYqC1A2APGY8zXIdM(Zkyai7NEAWbbV7ruc917ZIfhm9NfjmImM6SPVmir)EwOZ0de4r439iAp617ZcDMEGapc)Seb8WaYplAWwtXHGDuBKFyOaYpVwt1kYCaKFUIdb7O2i)Wqfijd95ZIfhm9N1Sd2oOBRnYpmE3JO90xVpl0z6bc8i8ZseWddi)SezoaYpxXHGDuBKFyOcKb6xRPAPbBnfhc2rTOJdBunpwqqT)wlnyRP4qWoQfDCyJksws98ybbplwCW0FwCiyh1zq)Uhr7XVEFwOZ0de4r4NLiGhgq(zjsPOZ(PKI(11pQ1uTImha5NRiHrKXuNn9Lbj6Nkqsg6ZAnBT9yk4ZIfhm9Nfhc2rn9GN37EeTh869zXIdM(Z6sqrNoB6Rd1KSn8zHotpqGhHF3JOYkZxVplwCW0FwCiyh1g5hgpl0z6bc8i87EevwzF9(SqNPhiWJWplrapmG8ZIgS1uCiyh1g5hgkG8ZFwS4GP)Scqh1ztBKFy8UhrLvUVEFwOZ0de4r4Nfloy6plJaNOlqD20Kqh4zbGtranoy6pl50jw7pM9WAVS2PCgerkayTSxlk5fCT9CiyhRLWdEE1cagq3U2RdRT386HuSN)XA)Goq(vlOpW5S2a0DOBxBphc2XAPafDPQ2FyR2EoeSJ1sbk6YAHZApEG(HaMx7hwRG9)xTGtS2Fm7H1(bVoOx71H12BE9qk2Z)yTFqhi)Qf0h4Cw7hwl0pmcqJR2RdRTN7H1k6y3XH51oZA)W)JrTtwkwl8uplrapmG8Z6N1E8a9tXHGDuJIUuHotpqGAnvlasd2AQlbfD6SPVoutY2qfOrTMQfaPbBn1LGIoD20xhQjzBOkqsg6ZA)LATsulloy6koeSJA6bppfkjkapuFqsS2EsT0GTMYiWj6cuNnnj0buKSK65XccQLY39iQSY4R3Nf6m9abEe(zXIdM(ZYiWj6cuNnnj0bEwa4ueqJdM(Z6h2Q9hZEyTD80)F1sJOxl4ebQfamGUDTxhwBV51dR9d6a5N51(H)hJAbNyTWR2lRDkNbrKcawl71IsEbxBphc2XAj8GNxTqV2RdRvoi)rk2Z)yTFqhi)uplrapmG8ZIgS1uCiyh1g5hgkqJAnvlnyRPcqh1ztBKFyOcKKH(S2FPwRe1YIdMUIdb7OMEWZtHsIcWd1hKeRTNulnyRPmcCIUa1zttcDafjlPEESGGAP8DpIklf817ZcDMEGapc)Seb8WaYplG8ubdaz)0tdoiqfijd9zTMTwcTwIjUwaKgS1ubdaz)0tdoiqlfC4yW0Wb86RMhliOwZwRmFwS4GP)S4qWoQPh88E3JOYsOVEFwOZ0de4r4Nfloy6ploeSJAAoc2gFwa4ueqJdM(ZQNhFC)zTeMJGTXA5R2RdRfDGAZwT98pw7xh61gGUdD7AVoS2EoeSJ1sbmhKP3V2bAJoah9FwIaEya5NfnyRP4qWoQnYpmuGg1AQwAWwtXHGDuBKFyOcKKH(S2FR1wauRPAdqhBzyJkoeSJAO3Go86RqNPhiW7Eev2E0R3Nf6m9abEe(zXIdM(ZIdb7OMMJGTXNfaofb04GP)S65Xh3FwlH5iyBSw(Q96WArhO2Sv71H1khK)yTFqhi)Q9Rd9Adq3HUDTxhwBphc2XAPaMdY07x7aTrhGJ(plrapmG8ZIgS1ubOJ6SPnYpmuGg1AQwAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgQajzOpR9xQ1AlaQ1uTbOJTmSrfhc2rn0BqhE9vOZ0de4DpIkBp917ZcDMEGapc)SeDm0FwY(Sqog91Iog6Ay7zrd2AkXa5qWZd62Arh7ooua5NBscAWwtXHGDuBKFyOaniMyj(5Xd0pvkfdJ8ddeWKe0GTMkaDuNnTr(HHc0GyIfzoaYpxHstbFW0vbYa9PKskFwIaEya5Nfasd2AQlbfD6SPVoutY2qfOrTMQ94b6NIdb7OgfDPcDMEGa1AQwjQLgS1uaiFD0z4Oci)8AjM4AzXbLIA0rsioRLATYwlL1AQwaKgS1uxck60ztFDOMKTHQajzOpR1S1YIdMUIdb7OMeoNWbovOKOa8q9bjXNfloy6ploeSJAs4Cch48DpIkBp(17ZcDMEGapc)Seb8WaYplAWwtjgihcEEq3wnpwqqTuRLgS1uIbYHGNh0TvKSK65XccQ1uTIuk6SFkPOFD9JNfloy6ploeSJAs4Cch48DpIkBp417ZcDMEGapc)SyXbt)zXHGDutcNt4aNplrhd9NLSplrapmG8ZIgS1uIbYHGNh0TvbYIRwt1kYCaKFUIdb7O2i)Wqfijd9zTMQvIAPbBnva6OoBAJ8ddfOrTetCT0GTMIdb7O2i)WqbAulLV7ru5kZxVpl0z6bc8i8ZseWddi)SObBnfhc2rTOJdBunpwqqT)sTwPCaz6bQU8i1KSKArhh248zXIdM(ZIdb7Ood639iQCL917ZcDMEGapc)Seb8WaYplAWwtfGoQZM2i)WqbAulXexlj7SYqC1A2ALLqFwS4GP)S4qWoQPh88E3JOYvUVEFwOZ0de4r4Nfloy6pluAk4dM(Zc6hgbOXPHTNfj7SYqCMLApMqFwq)WianonKKebG8HplzFwIaEya5NfnyRPcqh1ztBKFyOaYpVwt1sd2AkoeSJAJ8ddfq(5V7ru5kJVEFwS4GP)S4qWoQP5iyB8zHotpqGhHF37Ewn4Sd6260aDmE9(iQSVEFwOZ0de4r4Nfloy6pluAk4dM(ZcaNIaACW0FwYHDOxBa6o0TRfHxhg1EDyTww1MrT9khw7aTrhGdionV2pS2p2VAVSwkqPzT0yldS2RdRT386HuSN)XA)Goq(PQvoDI1cVA5zTZm9A5zTYb5pwBhpRTbD4SdbQnbJA)W)sXANgOF1MGrTIooSX5ZseWddi)SKO2a0Xwg2O6qsJm4H(Jddf6m9abQLyIRvIAdqhBzyJQj0OlD98YGuHotpqGAnv7pRvkhqMEGkJanahdnknRLATYwlL1szTMQvIAPbBnva6OoBAJ8ddfq(51smX1AeOuTTaqjRIdb7OMMJGTXAPSwt1kYCaKFUkaDuNnTr(HHkqsg6Z39iQCF9(SqNPhiWJWplwCW0FwO0uWhm9Nfaofb04GP)S(HTA)W)sXABqho7qGAtWOwrMdG8ZR9d6a53Sw2bQDAG(vBcg1k64WgNMxRraZaEqkayTuGsZAtPyulkfJ(xh0TRfht8zjc4HbKFwhpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUkaDuNnTr(HHkqsg6ZAnvRiZbq(5koeSJAJ8ddvGKm0N1AQwAWwtXHGDuBKFyOaYpVwt1sd2AQa0rD20g5hgkG8ZR1uTgbkvBlauYQ4qWoQP5iyB8DpIkJVEFwOZ0de4r4NLiGhgq(zfGo2YWgvaWPaAmGoh91IKKKDaf6m9abQ1uT0GTMcaofqJb05OVwKKKSdOBropfOXZIfhm9NvdgOMEWZ7DpIsbF9(SqNPhiWJWplrapmG8ZkaDSLHnQSd4C0xdfqXavOZ0deOwt1sYoRmexTMT2EaH(SyXbt)z1ICEApLYV7ruc917ZcDMEGapc)SyXbt)zXHGDutcNt4aNplrhd9NLSplrapmG8ZkaDSLHnQ4qWoQHEd6WRVcDMEGa1AQwAWwtXHGDu3Xbz69vZJfeu7V1sd2AkoeSJ6ooitVVIKLuppwqqTMQvIALOwAWwtXHGDuBKFyOaYpVwt1kYCaKFUIdb7O2i)Wqfid0VwkRLyIRfaPbBn1LGIoD20xhQjzBOc0OwkF3JO9OxVpl0z6bc8i8ZseWddi)ScqhBzyJQj0OlD98YGuHotpqGNfloy6pRa0rD20g5hgV7r0E6R3Nf6m9abEe(zjc4HbKFwImha5NRcqh1ztBKFyOcKb6)SyXbt)zXHGDuNb97EeTh)69zHotpqGhHFwIaEya5NLiZbq(5Qa0rD20g5hgQazG(1AQwAWwtXHGDul64WgvZJfeu7V1sd2AkoeSJArhh2OIKLuppwqWZIfhm9Nfhc2rn9GN37EeTh869zHotpqGhHFwIaEya5N1pRnaDSLHnQoK0idEO)4WqHotpqGAjM4AfPdacpLnSD6SPVoupGIof6m9abEwS4GP)Saq(6OZWX39iQSY817ZIfhm9Nva6OoBAJ8dJNf6m9abEe(DpIkRSVEFwOZ0de4r4Nfloy6ploeSJAs4Cch48zbGtranoy6pRFyR2p8FG1YxTKSK1opwqWS2SvlHqi1YoqTFyTDSu0)F1corGA7HzV12hpZRfCI1Y1opwqqTxwRrGsr)QLe0fDq3UwqFGZzTbO7q3U2RdRLcyoitVFTd0gDao6)Seb8WaYplAWwtjgihcEEq3wfilUAnvlnyRPedKdbppOBRMhliOwQ1sd2AkXa5qWZd62ksws98ybb1AQwrkfD2pLu0VU(rTMQvK5ai)CfjmImM6SPVmir)ubYa9R1uT)SwPCaz6bQqsJ8ddeqtZrW2yTMQvK5ai)Cfhc2rTr(HHkqgO)7Eevw5(69zHotpqGhHFwIaEya5N1pRvIAdqhBzyJQj0OlD98YGuHotpqGAjM4AdqhBzyJQdjnYGh6pomuOZ0deOwkFwa4ueqJdM(ZIOzqYJr)A)WAnyyuRrEW0RfCI1(bVUA75F08APbVAHxTFWXO2bpVAhPBxl6jODxTTmQLoVUAVoSw5G8hRLDGA75FS2pOdKFZAb9boN1gGUdD7AVoSwlRAZO2ELdRDG2OdWbeNplwCW0Fwg5bt)DpIkRm(69zHotpqGhHFwIaEya5N1pRnaDSLHnQoK0idEO)4WqHotpqGAnvRe1(ZAdqhBzyJQj0OlD98YGuHotpqGAjM4ALYbKPhOYiqdWXqJsZAPwRS1s5ZIfhm9NLrEW0F3JOYsbF9(SqNPhiWJWplrapmG8ZIgS1ubOJ6SPnYpmua5NxlXexRrGs12caLSkoeSJAAoc2gFwS4GP)Saq(6OZWX39iQSe6R3Nf6m9abEe(zjc4HbKFw0GTMkaDuNnTr(HHci)8AjM4AncuQ2waOKvXHGDutZrW24ZIfhm9NvWaq2p90GdcE3JOY2JE9(SqNPhiWJWplrapmG8ZIgS1ubOJ6SPnYpmubsYqFw7V1krT9OAjsTYT2EsTbOJTmSr1eA0LUEEzqQqNPhiqTu(SyXbt)zrcJiJPoB6lds0V39iQS90xVpl0z6bc8i8ZIfhm9Nfhc2rTr(HXZcaNIaACW0FwYHDOxBa6o0TR96WAPaMdY07x7aTrhGJ(Mxl4eRTN)XAPXwgyT9MxpS2lRfaK0OwU2g4y0V25XccqGAP5GdB8zjc4HbKFws5aY0duHKg5hgiGMMJGTXAnvlnyRPcqh1ztBKFyOanQ1uTsulj7SYqC1(BTsuRCj0AjsTsuRSYS2EsTIuk6SFkc6hq2RLYAPSwIjUwAWwtjgihcEEq3wnpwqqTuRLgS1uIbYHGNh0TvKSK65XccQLY39iQS94xVpl0z6bc8i8ZseWddi)SKYbKPhOcjnYpmqannhbBJ1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwt1sd2AkoeSJAJ8ddfOXZIfhm9Nfhc2rnnhbBJV7ruz7bVEFwOZ0de4r4NLiGhgq(zrd2AQa0rD20g5hgkG8ZRLyIR1iqPABbGswfhc2rnnhbBJ1smX1AeOuTTaqjRkyai7NEAWbb1smX1AeOuTTaqjRca5RJodhFwS4GP)SUeu0PZM(6qnjBdF3JOYvMVEFwOZ0de4r4NLiGhgq(zzeOuTTaqjR6sqrNoB6Rd1KSn8zXIdM(ZIdb7O2i)W4DpIkxzF9(SqNPhiWJWplwCW0FwgborxG6SPjHoWZcaNIaACW0FwYPtS2Fm7H1EzTt5miIuaWAzVwuYl4A75qWowlHh88QfamGUDTxhwBV51dPyp)J1(bDG8RwqFGZzTbO7q3U2EoeSJ1sbk6svT)WwT9CiyhRLcu0L1cN1E8a9dbmV2pSwb7)VAbNyT)y2dR9dEDqV2RdRT386HuSN)XA)Goq(vlOpW5S2pSwOFyeGgxTxhwBp3dRv0XUJdZRDM1(H)hJANSuSw4PEwIaEya5N1pR94b6NIdb7OgfDPcDMEGa1AQwaKgS1uxck60ztFDOMKTHkqJAnvlasd2AQlbfD6SPVoutY2qvGKm0N1(l1ALOwwCW0vCiyh10dEEkusuaEO(GKyT9KAPbBnLrGt0fOoBAsOdOizj1ZJfeulLV7ru5k3xVpl0z6bc8i8ZIfhm9NLrGt0fOoBAsOd8SaWPiGghm9N1pSv7pM9WA74P))QLgrVwWjculayaD7AVoS2EZRhw7h0bYpZR9d)pg1coXAHxTxw7uodIifaSw2RfL8cU2EoeSJ1s4bpVAHETxhwRCq(JuSN)XA)Goq(PEwIaEya5NfnyRP4qWoQnYpmuGg1AQwAWwtfGoQZM2i)Wqfijd9zT)sTwjQLfhmDfhc2rn9GNNcLefGhQpijwBpPwAWwtze4eDbQZMMe6aksws98ybb1s57EevUY4R3Nf6m9abEe(zjc4HbKFwa5PcgaY(PNgCqGkqsg6ZAnBTeATetCTainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqqTMTwz(SyXbt)zXHGDutp459UhrLlf817ZcDMEGapc)SyXbt)zXHGDutZrW24ZcaNIaACW0FwYHyTFSF1EzTKmbyTtWaR9dRTJLI1IEcA3vlj7CTTmQ96WAr)GbwBp)J1(bDG8Z8ArPOxlSv71Hb(Fw78GJrThKeRnqsg6q3U20Rvoi)rvT)W7)S20h9RLgVdJAVSwAWWR9YAPaGrwl7a1sbknRf2QnaDh621EDyTww1MrT9khw7aTrhGdiovplrapmG8ZsK5ai)Cfhc2rTr(HHkqgOFTMQLKDwziUA)TwjQLckZAjsTsuRSYS2EsTIuk6SFkc6hq2RLYAPSwt1sd2AkoeSJArhh2OAESGGAPwlnyRP4qWoQfDCyJksws98ybb1AQwjQ9N1gGo2YWgvtOrx665LbPcDMEGa1smX1kLditpqLrGgGJHgLM1sTwzRLYAnv7pRnaDSLHnQoK0idEO)4WqHotpqGAnv7pRnaDSLHnQ4qWoQHEd6WRVcDMEGaV7ru5sOVEFwOZ0de4r4Nfloy6ploeSJAAoc2gFwa4ueqJdM(ZIWCeSnw7Slbha165vlnwl4ebQLVAVoSw0bQnB12Z)yTWwTuGstbFW0RfoRnqgOFT8SwGinmGUDTIooSXzTFWXOwsMaSw4v7XeG1os3gJAVSwAWWR96Ie0UR2ajzOdD7AjzNFwIaEya5NfnyRP4qWoQnYpmuGg1AQwAWwtXHGDuBKFyOcKKH(S2FPwRTaOwt1kYCaKFUcLMc(GPRcKKH(8DpIk3E0R3Nf6m9abEe(zXIdM(ZIdb7OMMJGTXNfaofb04GP)SimhbBJ1o7sWbqT84J7pRLgR96WAh88QvWZRwOx71H1khK)yTFqhi)QLN12BE9WA)GJrTboVmWAVoSwrhh24S2Pb63ZseWddi)SObBnva6OoBAJ8ddfOrTMQLgS1uCiyh1g5hgkG8ZR1uT0GTMkaDuNnTr(HHkqsg6ZA)LAT2cGAnv7pRnaDSLHnQ4qWoQHEd6WRVcDMEGaV7ru52tF9(SqNPhiWJWplrhd9NLSplKJrFTOJHUg2Ew0GTMsmqoe88GUTw0XUJdfq(5MKGgS1uCiyh1g5hgkqdIjwIFE8a9tLsXWi)WabmjbnyRPcqh1ztBKFyOaniMyrMdG8ZvO0uWhmDvGmqFkPKYNLiGhgq(zbG0GTM6sqrNoB6Rd1KSnubAuRPApEG(P4qWoQrrxQqNPhiqTMQvIAPbBnfaYxhDgoQaYpVwIjUwwCqPOgDKeIZAPwRS1szTMQfaPbBn1LGIoD20xhQjzBOkqsg6ZAnBTS4GPR4qWoQjHZjCGtfkjkapuFqs8zXIdM(ZIdb7OMeoNWboF3JOYTh)69zHotpqGhHFwS4GP)S4qWoQjHZjCGZNfaofb04GP)S(HTA)W)bwRu0VU(H51cjjraiF4OFTGtSwcHqQ9Rd9AfSHbcu7L165v7hppSwJifZABrswBpm79zjc4HbKFwIuk6SFkPOFD9JAnvlnyRPedKdbppOBRMhliOwQ1sd2AkXa5qWZd62ksws98ybbV7ru52dE9(SqNPhiWJWplaCkcOXbt)zzDCC1coHUDTecHuBp3dR9Rd9A75FS2oEwlnIETGte4zjc4HbKFw0GTMsmqoe88GUTkqwC1AQwrMdG8ZvCiyh1g5hgQajzOpR1uTsulnyRPcqh1ztBKFyOanQLyIRLgS1uCiyh1g5hgkqJAP8zj6yO)SK9zXIdM(ZIdb7OMeoNWboF3JOYOmF9(SqNPhiWJWplrapmG8ZIgS1uCiyh1IooSr18ybb1(l1ALYbKPhO6YJutYsQfDCyJZNfloy6ploeSJ6mOF3JOYOSVEFwOZ0de4r4NLiGhgq(zrd2AQa0rD20g5hgkqJAjM4AjzNvgIRwZwRSe6ZIfhm9Nfhc2rn9GN37EevgL7R3Nf6m9abEe(zXIdM(ZcLMc(GP)SG(HraACAy7zrYoRmeNzP2Jj0Nf0pmcqJtdjjraiF4Zs2NLiGhgq(zrd2AQa0rD20g5hgkG8ZR1uT0GTMIdb7O2i)WqbKF(7EevgLXxVplwCW0FwCiyh10CeSn(SqNPhiWJWV7DpRip(GP)69ruzF9(SqNPhiWJWplwCW0FwO0uWhm9Nfaofb04GP)SKtNyTO0SwyR2p8FG1oYVAtVws25AzhOwrMdG8ZN1YbwltNGxTxwlnwlOXZseWddi)SizNvgIR2FPwRuoGm9avO0uBiUAnvRe1kYCaKFU6sqrNoB6Rd1KSnufijd9zT)sTwwCW0vO0uWhmDfkjkapuFqsSwIjUwrMdG8ZvCiyh1g5hgQajzOpR9xQ1YIdMUcLMc(GPRqjrb4H6dsI1smX1krThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUkaDuNnTr(HHkqsg6ZA)LATS4GPRqPPGpy6kusuaEO(GKyTuwlL1AQwAWwtfGoQZM2i)WqbKFETMQLgS1uCiyh1g5hgkG8ZR1uTainyRPUeu0PZM(6qnjBdva5NxRPA)zTgbkvBlauYQUeu0PZM(6qnjBdF3JOY917ZcDMEGapc)Seb8WaYpRa0Xwg2OAcn6sxpVmivOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwwCW0vO0uWhmDfkjkapuFqs8zXIdM(ZcLMc(GP)UhrLXxVpl0z6bc8i8ZIfhm9Nfhc2rnnhbBJplaCkcOXbt)zryoc2gRf2QfE)N1EqsS2lRfCI1E5rwl7a1(H12XsXAVmRLK9(1k64WgNplrapmG8ZsK5ai)C1LGIoD20xhQjzBOkqgOFTMQvIAPbBnfhc2rTOJdBunpwqqTMTwPCaz6bQU8i1KSKArhh24Swt1kYCaKFUIdb7O2i)Wqfijd9zT)sTwusuaEO(GKyTMQLKDwziUAnBTs5aY0duXgAsOdjbj1KSZAdXvRPAPbBnva6OoBAJ8ddfq(51s57EeLc(69zHotpqGhHFwIaEya5NLiZbq(5QlbfD6SPVoutY2qvGmq)AnvRe1sd2AkoeSJArhh2OAESGGAnBTs5aY0duD5rQjzj1IooSXzTMQ94b6NkaDuNnTr(HHcDMEGa1AQwrMdG8ZvbOJ6SPnYpmubsYqFw7VuRfLefGhQpijwRPALYbKPhO6GKOg0p4qZg1A2ALYbKPhO6YJutYsQbWb3x3YqZg1s5ZIfhm9Nfhc2rnnhbBJV7ruc917ZcDMEGapc)Seb8WaYplrMdG8Zvxck60ztFDOMKTHQazG(1AQwjQLgS1uCiyh1IooSr18ybb1A2ALYbKPhO6YJutYsQfDCyJZAnvRe1(ZApEG(Pcqh1ztBKFyOqNPhiqTetCTImha5NRcqh1ztBKFyOcKKH(SwZwRuoGm9avxEKAswsnao4(6wg6inQLYAnvRuoGm9avhKe1G(bhA2OwZwRuoGm9avxEKAswsnao4(6wgA2OwkFwS4GP)S4qWoQP5iyB8DpI2JE9(SqNPhiWJWplrapmG8ZcaPbBnvWaq2p90Gdc0sbhogmnCaV(Q5XccQLATainyRPcgaY(PNgCqGwk4WXGPHd41xrYsQNhliOwt1krT0GTMIdb7O2i)WqbKFETetCT0GTMIdb7O2i)Wqfijd9zT)sTwBbqTuwRPALOwAWwtfGoQZM2i)WqbKFETetCT0GTMkaDuNnTr(HHkqsg6ZA)LAT2cGAP8zXIdM(ZIdb7OMMJGTX39iAp917ZcDMEGapc)Seb8WaYplPCaz6bQ(bbNNgCIa6PbheulXexRe1cG0GTMkyai7NEAWbbAPGdhdMgoGxFfOrTMQfaPbBnvWaq2p90Gdc0sbhogmnCaV(Q5XccQ93AbqAWwtfmaK9tpn4GaTuWHJbtdhWRVIKLuppwqqTu(SyXbt)zXHGDutp459Uhr7XVEFwOZ0de4r4NLiGhgq(zrd2AkJaNOlqD20KqhqbAuRPAbqAWwtDjOOtNn91HAs2gQanQ1uTainyRPUeu0PZM(6qnjBdvbsYqFw7VuRLfhmDfhc2rn9GNNcLefGhQpij(SyXbt)zXHGDutp459Uhr7bVEFwOZ0de4r4NLOJH(Zs2NfYXOVw0XqxdBplAWwtjgihcEEq3wl6y3XHci)Ctsqd2AkoeSJAJ8ddfObXelXppEG(PsPyyKFyGaMKGgS1ubOJ6SPnYpmuGgetSiZbq(5kuAk4dMUkqgOpLus5ZseWddi)SaqAWwtDjOOtNn91HAs2gQanQ1uThpq)uCiyh1OOlvOZ0deOwt1krT0GTMca5RJodhva5NxlXexlloOuuJoscXzTuRv2APSwt1krTainyRPUeu0PZM(6qnjBdvbsYqFwRzRLfhmDfhc2rnjCoHdCQqjrb4H6dsI1smX1kYCaKFUYiWj6cuNnnj0bubsYqFwlXexRiLIo7NIG(bK9AP8zXIdM(ZIdb7OMeoNWboF3JOYkZxVpl0z6bc8i8ZIfhm9Nfhc2rnjCoHdC(SaWPiGghm9NfHK(eKeR96WArjnyhabQ1ip0pipQLgS1QLNSrTxwRNxTJCI1AKh6hKh1AePy(Seb8WaYplAWwtjgihcEEq3wfilUAnvlnyRPqjnyhab0g5H(b5Hc04DpIkRSVEFwOZ0de4r4Nfloy6ploeSJAs4Cch48zj6yO)SK9zjc4HbKFw0GTMsmqoe88GUTkqwC1AQwjQLgS1uCiyh1g5hgkqJAjM4APbBnva6OoBAJ8ddfOrTetCTainyRPUeu0PZM(6qnjBdvbsYqFwRzRLfhmDfhc2rnjCoHdCQqjrb4H6dsI1s57Eevw5(69zHotpqGhHFwS4GP)S4qWoQjHZjCGZNLOJH(Zs2NLiGhgq(zrd2AkXa5qWZd62QazXvRPAPbBnLyGCi45bDB18ybb1sTwAWwtjgihcEEq3wrYsQNhli4DpIkRm(69zHotpqGhHFwa4ueqJdM(ZQNhFC)zTx0V2lRLMDcQLqiKABzuRiZbq(51(bDG8Bwln4vlaiPrTxhswlSv71H9)hyTmDcE1EzTOKgWaFwIaEya5NfnyRPedKdbppOBRcKfxTMQLgS1uIbYHGNh0TvbsYqFw7VuRvIALOwAWwtjgihcEEq3wnpwqqT9KAzXbtxXHGDutcNt4aNkusuaEO(GKyTuwlrQ1waOizjRLYNLOJH(Zs2Nfloy6ploeSJAs4Cch48DpIklf817ZcDMEGapc)Seb8WaYpljQnWwGZoMEG1smX1(ZApOGaOBxlL1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwt1sd2AkoeSJAJ8ddfq(51AQwaKgS1uxck60ztFDOMKTHkG8ZFwS4GP)SC86WqFiPboV39iQSe6R3Nf6m9abEe(zjc4HbKFw0GTMIdb7Ow0XHnQMhliO2FPwRuoGm9avxEKAswsTOJdBC(SyXbt)zXHGDuNb97Eev2E0R3Nf6m9abEe(zjc4HbKFws5aY0duLG3ecG6SPfzoaYpFwRPAjzNvgIR2FPwBpGqFwS4GP)SMGgy4Pu(DpIkBp917ZcDMEGapc)Seb8WaYplAWwtfGduNn91fiovGg1AQwAWwtXHGDul64WgvZJfeuRzRvgFwS4GP)S4qWoQPh88E3JOY2JF9(SqNPhiWJWplwCW0FwCiyh10CeSn(SaWPiGghm9NLCsajnQv0XHnoRf2Q9dRTXJrT04i)Q96WAfPpXqkwlj7CTxxGZUCaul7a1IstbFW0RfoRDEWXO20RvK5ai)8NLiGhgq(z9ZAdqhBzyJQj0OlD98YGuHotpqGAnvRuoGm9avj4nHaOoBArMdG8ZN1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwt1E8a9tXHGDuNbTcDMEGa1AQwrMdG8ZvCiyh1zqRcKKH(S2FPwRTaOwt1sYoRmexT)sT2EGmR1uTImha5NRqPPGpy6QajzOpF3JOY2dE9(SqNPhiWJWplrapmG8ZkaDSLHnQMqJU01Zldsf6m9abQ1uTs5aY0duLG3ecG6SPfzoaYpFwRPAPbBnfhc2rTOJdBunpwqqTuRLgS1uCiyh1IooSrfjlPEESGGAnv7Xd0pfhc2rDg0k0z6bcuRPAfzoaYpxXHGDuNbTkqsg6ZA)LAT2cGAnvlj7SYqC1(l1A7bYSwt1kYCaKFUcLMc(GPRcKKH(S2FRvgL5ZIfhm9Nfhc2rnnhbBJV7ru5kZxVpl0z6bc8i8ZIfhm9Nfhc2rnnhbBJplaCkcOXbt)zjNeqsJAfDCyJZAHTAZGUw4S2azG(plrapmG8ZskhqMEGQe8MqauNnTiZbq(5ZAnvlnyRP4qWoQfDCyJQ5XccQLAT0GTMIdb7Ow0XHnQizj1ZJfeuRPApEG(P4qWoQZGwHotpqGAnvRiZbq(5koeSJ6mOvbsYqFw7VuR1wauRPAjzNvgIR2FPwBpqM1AQwrMdG8ZvO0uWhmDvGKm0NV7ru5k7R3Nf6m9abEe(zXIdM(ZIdb7OMMJGTXNfaofb04GP)S65qWowlH5iyBS2zxcoaQ1gDm4XOFT0yTxhw7GNxTcEE1MTAVoS2E(hR9d6a53ZseWddi)SObBnfhc2rTr(HHc0Owt1sd2AkoeSJAJ8ddvGKm0N1(l1ATfa1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwt1krTImha5NRqPPGpy6QajzOpRLyIRnaDSLHnQ4qWoQHEd6WRVcDMEGa1s57EevUY917ZcDMEGapc)SyXbt)zXHGDutZrW24ZcaNIaACW0Fw9CiyhRLWCeSnw7Slbha1AJog8y0VwAS2RdRDWZRwbpVAZwTxhwRCq(J1(bDG87zjc4HbKFw0GTMkaDuNnTr(HHc0Owt1sd2AkoeSJAJ8ddfq(51AQwAWwtfGoQZM2i)Wqfijd9zT)sTwBbqTMQLgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccQ1uTsuRiZbq(5kuAk4dMUkqsg6ZAjM4AdqhBzyJkoeSJAO3Go86RqNPhiqTu(UhrLRm(69zHotpqGhHFwS4GP)S4qWoQP5iyB8zbGtranoy6pREoeSJ1syoc2gRD2LGdGAPXAVoS2bpVAf88QnB1EDyT9MxpS2pOdKF1cB1cVAHZA98QfCIa1(bVUALdYFS2mQTN)XNLiGhgq(zrd2AkoeSJAJ8ddfq(51AQwAWwtfGoQZM2i)WqbKFETMQfaPbBn1LGIoD20xhQjzBOc0Owt1cG0GTM6sqrNoB6Rd1KSnufijd9zT)sTwBbqTMQLgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccE3JOYLc(69zHotpqGhHFwS4GP)S4qWoQP5iyB8zbGtranoy6pl5Wo0R96WApoSXRw4SwOxlkjkapS2GDBSw2bQ96WaRfoRLmdS2RJ9AthRfDKSV51coXAP5iyBSwEw7mtVwEwB)eS2owkwl6jODxTIooSXzTxwBh8QLhJArhjH4SwyR2RdRTNdb7yTeojP5aGe9R2bAJoah9RfoRfLZGqdde4zjc4HbKFws5aY0duHKg5hgiGMMJGTXAnvlnyRP4qWoQfDCyJQ5XccQ1SuRvIAzXbLIA0rsioR9hOwzRLYAnvlloOuuJoscXzTMTwzR1uT0GTMca5RJodhva5N)UhrLlH(69zHotpqGhHFwIaEya5NLuoGm9aviPr(HbcOP5iyBSwt1sd2AkoeSJArhh2OAESGGA)TwAWwtXHGDul64WgvKSK65XccQ1uTS4Gsrn6ijeN1A2ALTwt1sd2AkaKVo6mCubKF(ZIfhm9Nfhc2rnkPXiNW0F3JOYTh969zXIdM(ZIdb7OMEWZ7zHotpqGhHF3JOYTN(69zHotpqGhHFwIaEya5NLuoGm9avj4nHaOoBArMdG8ZNplwCW0FwO0uWhm939iQC7XVEFwS4GP)S4qWoQP5iyB8zHotpqGhHF37EwCIVEFev2xVpl0z6bc8i8ZseWddi)ScqhBzyJka4uangqNJ(ArssYoGcDMEGa1AQwrMdG8Zv0GTMgaofqJb05OVwKKKSdOcKb6xRPAPbBnfaCkGgdOZrFTijjzhq3ICEkG8ZR1uTsulnyRP4qWoQnYpmua5NxRPAPbBnva6OoBAJ8ddfq(51AQwaKgS1uxck60ztFDOMKTHkG8ZRLYAnvRiZbq(5QlbfD6SPVoutY2qvGKm0N1sTwzwRPALOwAWwtXHGDul64WgvZJfeu7VuRvkhqMEGkor9LhPMKLul64WgN1AQwjQvIApEG(Pcqh1ztBKFyOqNPhiqTMQvK5ai)Cva6OoBAJ8ddvGKm0N1(l1ATfa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUVULHMnQLYAjM4ALO2Fw7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCFDldnBulL1smX1kYCaKFUIdb7O2i)Wqfijd9zT)sTwBbqTuwlLplwCW0FwTiNhDoU39iQCF9(SqNPhiWJWplrapmG8ZsIAdqhBzyJka4uangqNJ(ArssYoGcDMEGa1AQwrMdG8Zv0GTMgaofqJb05OVwKKKSdOcKb6xRPAPbBnfaCkGgdOZrFTijjzhq3GbQaYpVwt1AeOuTTaqjRQf58OZXvlL1smX1krTbOJTmSrfaCkGgdOZrFTijjzhqHotpqGAnv7bjXA)TwzRLYNfloy6pRgmqn9GN37EevgF9(SqNPhiWJWplrapmG8ZkaDSLHnQSd4C0xdfqXavOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwzuM1AQwrMdG8Zvxck60ztFDOMKTHQajzOpRLATYSwt1krT0GTMIdb7Ow0XHnQMhliO2FPwRuoGm9avCI6lpsnjlPw0XHnoR1uTsuRe1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR9xQ1AlaQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCFDldnBulL1smX1krT)S2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRuoGm9avxEKAswsnao4(6wgA2OwkRLyIRvK5ai)Cfhc2rTr(HHkqsg6ZA)LAT2cGAPSwkFwS4GP)SAropTNs539ikf817ZcDMEGapc)Seb8WaYpRa0Xwg2OYoGZrFnuafduHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1sTwzwRPALOwjQvIAfzoaYpxDjOOtNn91HAs2gQcKKH(SwZwRuoGm9avSHMKLudGdUVULH(YJSwt1sd2AkoeSJArhh2OAESGGAPwlnyRP4qWoQfDCyJksws98ybb1szTetCTsuRiZbq(5QlbfD6SPVoutY2qvGKm0N1sTwzwRPAPbBnfhc2rTOJdBunpwqqT)sTwPCaz6bQ4e1xEKAswsTOJdBCwlL1szTMQLgS1ubOJ6SPnYpmua5NxlLplwCW0FwTiNN2tP87EeLqF9(SqNPhiWJWplwCW0FwCiyh1KW5eoW5Zs0Xq)zj7ZseWddi)SePu0z)ue0pGSxRPAdqhBzyJkoeSJAO3Go86RqNPhiqTMQLgS1uCiyh1DCqMEF18ybb1(BTYsO1AQwrMdG8Zvbdaz)0tdoiqfijd9zT)sTwPCaz6bQ64Gm9(65Xcc0hKeRLi1IsIcWd1hKeR1uTImha5NRUeu0PZM(6qnjBdvbsYqFw7VuRvkhqMEGQooitVVEESGa9bjXAjsTOKOa8q9bjXAjsTS4GPRcgaY(PNgCqGcLefGhQpijwRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwRuoGm9avDCqMEF98ybb6dsI1sKArjrb4H6dsI1sKAzXbtxfmaK9tpn4GafkjkapuFqsSwIulloy6QlbfD6SPVoutY2qfkjkapuFqs8DpI2JE9(SqNPhiWJWplrapmG8ZkaDSLHnQMqJU01Zldsf6m9abQ1uTgbkvBlauYQqPPGpy6plwCW0Fwxck60ztFDOMKTHV7r0E6R3Nf6m9abEe(zjc4HbKFwbOJTmSr1eA0LUEEzqQqNPhiqTMQvIAncuQ2waOKvHstbFW0RLyIR1iqPABbGsw1LGIoD20xhQjzByTu(SyXbt)zXHGDuBKFy8Uhr7XVEFwOZ0de4r4NLiGhgq(zDqsSwZwRmkZAnvBa6yldBunHgDPRNxgKk0z6bcuRPAPbBnfhc2rTOJdBunpwqqT)sTwPCaz6bQ4e1xEKAswsTOJdBCwRPAfzoaYpxDjOOtNn91HAs2gQcKKH(SwQ1kZAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1ATfaplwCW0FwO0uWhm939iAp417ZcDMEGapc)SyXbt)zHstbFW0Fwq)WianonS9SObBn1eA0LUEEzqQMhliGknyRPMqJU01ZldsfjlPEESGGNf0pmcqJtdjjraiF4Zs2NLiGhgq(zDqsSwZwRmkZAnvBa6yldBunHgDPRNxgKk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(SwQ1kZAnvRe1krTsuRiZbq(5QlbfD6SPVoutY2qvGKm0N1A2ALYbKPhOIn0KSKAaCW91Tm0xEK1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwkRLyIRvIAfzoaYpxDjOOtNn91HAs2gQcKKH(SwQ1kZAnvlnyRP4qWoQfDCyJQ5XccQ9xQ1kLditpqfNO(YJutYsQfDCyJZAPSwkR1uT0GTMkaDuNnTr(HHci)8AP8DpIkRmF9(SqNPhiWJWplrapmG8ZsIAfzoaYpxXHGDuBKFyOcKKH(SwZwlfKqRLyIRvK5ai)Cfhc2rTr(HHkqsg6ZA)LATYyTuwRPAfzoaYpxDjOOtNn91HAs2gQcKKH(SwQ1kZAnvRe1sd2AkoeSJArhh2OAESGGA)LATs5aY0duXjQV8i1KSKArhh24Swt1krTsu7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NRcqh1ztBKFyOcKKH(S2FPwRTaOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwcTwkRLyIRvIA)zThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwcTwkRLyIRvK5ai)Cfhc2rTr(HHkqsg6ZA)LAT2cGAPSwkFwS4GP)SiHrKXuNn9Lbj637EevwzF9(SqNPhiWJWplrapmG8ZsK5ai)C1LGIoD20xhQjzBOkqsg6ZA)TwusuaEO(GKyTMQvIALO2JhOFQa0rD20g5hgk0z6bcuRPAfzoaYpxfGoQZM2i)Wqfijd9zT)sTwBbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTs5aY0duD5rQjzj1a4G7RBzOzJAPSwIjUwjQ9N1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYsQbWb3x3YqZg1szTetCTImha5NR4qWoQnYpmubsYqFw7VuR1waulLplwCW0Fwbdaz)0tdoi4DpIkRCF9(SqNPhiWJWplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)TwusuaEO(GKyTMQvIALOwjQvK5ai)C1LGIoD20xhQjzBOkqsg6ZAnBTs5aY0duXgAswsnao4(6wg6lpYAnvlnyRP4qWoQfDCyJQ5XccQLAT0GTMIdb7Ow0XHnQizj1ZJfeulL1smX1krTImha5NRUeu0PZM(6qnjBdvbsYqFwl1ALzTMQLgS1uCiyh1IooSr18ybb1(l1ALYbKPhOItuF5rQjzj1IooSXzTuwlL1AQwAWwtfGoQZM2i)WqbKFETu(SyXbt)zfmaK9tpn4GG39iQSY4R3Nf6m9abEe(zjc4HbKFwImha5NR4qWoQnYpmubsYqFwl1ALzTMQvIALOwjQvK5ai)C1LGIoD20xhQjzBOkqsg6ZAnBTs5aY0duXgAswsnao4(6wg6lpYAnvlnyRP4qWoQfDCyJQ5XccQLAT0GTMIdb7Ow0XHnQizj1ZJfeulL1smX1krTImha5NRUeu0PZM(6qnjBdvbsYqFwl1ALzTMQLgS1uCiyh1IooSr18ybb1(l1ALYbKPhOItuF5rQjzj1IooSXzTuwlL1AQwAWwtfGoQZM2i)WqbKFETu(SyXbt)zbG81rNHJV7ruzPGVEFwOZ0de4r4NLiGhgq(zjrT0GTMIdb7Ow0XHnQMhliO2FPwRuoGm9avCI6lpsnjlPw0XHnoRLyIR1iqPABbGswvWaq2p90GdcQLYAnvRe1krThpq)ubOJ6SPnYpmuOZ0deOwt1kYCaKFUkaDuNnTr(HHkqsg6ZA)LAT2cGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYsQbWb3x3YqZg1szTetCTsu7pR94b6NkaDuNnTr(HHcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUVULHMnQLYAjM4AfzoaYpxXHGDuBKFyOcKKH(S2FPwRTaOwkFwS4GP)SUeu0PZM(6qnjBdF3JOYsOVEFwOZ0de4r4NLiGhgq(zjrTsuRiZbq(5QlbfD6SPVoutY2qvGKm0N1A2ALYbKPhOIn0KSKAaCW91Tm0xEK1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwkRLyIRvIAfzoaYpxDjOOtNn91HAs2gQcKKH(SwQ1kZAnvlnyRP4qWoQfDCyJQ5XccQ9xQ1kLditpqfNO(YJutYsQfDCyJZAPSwkR1uT0GTMkaDuNnTr(HHci)8Nfloy6ploeSJAJ8dJ39iQS9OxVpl0z6bc8i8ZseWddi)SObBnva6OoBAJ8ddfq(51AQwjQvIAfzoaYpxDjOOtNn91HAs2gQcKKH(SwZwRCLzTMQLgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccQLYAjM4ALOwrMdG8Zvxck60ztFDOMKTHQajzOpRLATYSwt1sd2AkoeSJArhh2OAESGGA)LATs5aY0duXjQV8i1KSKArhh24SwkRLYAnvRe1kYCaKFUIdb7O2i)Wqfijd9zTMTwzLBTetCTainyRPUeu0PZM(6qnjBdvGg1s5ZIfhm9Nva6OoBAJ8dJ39iQS90xVpl0z6bc8i8ZseWddi)SezoaYpxXHGDuNbTkqsg6ZAnBTeATetCT)S2JhOFkoeSJ6mOvOZ0de4zXIdM(ZA2bBh0T1g5hgV7ruz7XVEFwOZ0de4r4NLiGhgq(zjsPOZ(PiOFazVwt1gGo2YWgvCiyh1qVbD41xHotpqGAnvlnyRP4qWoQnYpmuGg1AQwaKgS1ubdaz)0tdoiqlfC4yW0Wb86RMhliOwQ1sbR1uTgbkvBlauYQ4qWoQZGUwt1YIdkf1OJKqCw7V12tFwS4GP)S4qWoQPh88E3JOY2dE9(SqNPhiWJWplrapmG8ZsKsrN9trq)aYETMQnaDSLHnQ4qWoQHEd6WRVcDMEGa1AQwAWwtXHGDuBKFyOanQ1uTainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqqTuRLc(SyXbt)zXHGDutZrW247EevUY817ZcDMEGapc)Seb8WaYplrkfD2pfb9di71AQ2a0Xwg2OIdb7Og6nOdV(k0z6bcuRPAPbBnfhc2rTr(HHc0Owt1krTa5PcgaY(PNgCqGkqsg6ZAnBT9OAjM4AbqAWwtfmaK9tpn4GaTuWHJbtdhWRVc0OwkR1uTainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqqT)wlfSwt1YIdkf1OJKqCwl1ALXNfloy6ploeSJA6bpV39iQCL917ZcDMEGapc)Seb8WaYplrkfD2pfb9di71AQ2a0Xwg2OIdb7Og6nOdV(k0z6bcuRPAPbBnfhc2rTr(HHc0Owt1cG0GTMkyai7NEAWbbAPGdhdMgoGxF18ybb1sTwz8zXIdM(ZIdb7Ood639iQCL7R3Nf6m9abEe(zjc4HbKFwIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0deOwt1sd2AkoeSJAJ8ddfOrTMQfaPbBnvWaq2p90Gdc0sbhogmnCaV(Q5XccQLATY9zXIdM(ZIdb7OMMJGTX39iQCLXxVpl0z6bc8i8ZseWddi)SePu0z)ue0pGSxRPAdqhBzyJkoeSJAO3Go86RqNPhiqTMQLgS1uCiyh1g5hgkqJAnvRrGs12caLCvbdaz)0tdoiOwt1YIdkf1OJKqCwRzRvgFwS4GP)S4qWoQrjng5eM(7EevUuWxVpl0z6bc8i8ZseWddi)SePu0z)ue0pGSxRPAdqhBzyJkoeSJAO3Go86RqNPhiqTMQLgS1uCiyh1g5hgkqJAnvlasd2AQGbGSF6PbheOLcoCmyA4aE9vZJfeul1ALTwt1YIdkf1OJKqCwRzRvgFwS4GP)S4qWoQrjng5eM(7EevUe6R3Nf6m9abEe(zjc4HbKFw0GTMca5RJodhvGg1AQwaKgS1uxck60ztFDOMKTHkqJAnvlasd2AQlbfD6SPVoutY2qvGKm0N1(l1APbBnLrGt0fOoBAsOdOizj1ZJfeuBpPwwCW0vCiyh10dEEkusuaEO(GKyTMQvIALO2JhOFQaNPZUavOZ0deOwt1YIdkf1OJKqCw7V1sbRLYAjM4AzXbLIA0rsioR93Aj0APSwt1krT)S2a0Xwg2OIdb7OMojP5aGe9tHotpqGAjM4ApoSXt1H846ugIRwZwRmsO1s5ZIfhm9NLrGt0fOoBAsOd8UhrLBp617ZcDMEGapc)Seb8WaYplAWwtbG81rNHJkqJAnvRe1krThpq)ubotNDbQqNPhiqTMQLfhukQrhjH4S2FRLcwlL1smX1YIdkf1OJKqCw7V1sO1szTMQvIA)zTbOJTmSrfhc2rnDssZbaj6NcDMEGa1smX1ECyJNQd5X1PmexTMTwzKqRLYNfloy6ploeSJA6bpV39iQC7PVEFwS4GP)SMGgy4Pu(zHotpqGhHF3JOYTh)69zHotpqGhHFwIaEya5NfnyRP4qWoQfDCyJQ5XccQ1SuRvIAzXbLIA0rsioR9hOwzRLYAnvBa6yldBuXHGDutNK0CaqI(PqNPhiqTMQ94WgpvhYJRtziUA)TwzKqFwS4GP)S4qWoQP5iyB8DpIk3EWR3Nf6m9abEe(zjc4HbKFw0GTMIdb7Ow0XHnQMhliOwQ1sd2AkoeSJArhh2OIKLuppwqWZIfhm9Nfhc2rnnhbBJV7ruzuMVEFwOZ0de4r4NLiGhgq(zrd2AkoeSJArhh2OAESGGAPwRmFwS4GP)S4qWoQZG(DpIkJY(69zHotpqGhHFwIaEya5NLe1gylWzhtpWAjM4A)zThuqa0TRLYAnvlnyRP4qWoQfDCyJQ5XccQLAT0GTMIdb7Ow0XHnQizj1ZJfe8SyXbt)z541HH(qsdCEV7ruzuUVEFwOZ0de4r4NLiGhgq(zrd2AkXa5qWZd62QazXvRPAdqhBzyJkoeSJAO3Go86RqNPhiqTMQvIALO2JhOFkM0yaBqbFW0vOZ0deOwt1YIdkf1OJKqCw7V12JRLYAjM4AzXbLIA0rsioR93Aj0AP8zXIdM(ZIdb7OMeoNWboF3JOYOm(69zHotpqGhHFwIaEya5NfnyRPedKdbppOBRcKfxTMQ94b6NIdb7OgfDPcDMEGa1AQwaKgS1uxck60ztFDOMKTHkqJAnvRe1E8a9tXKgdydk4dMUcDMEGa1smX1YIdkf1OJKqCw7V12dQLYNfloy6ploeSJAs4Cch48DpIkJuWxVpl0z6bc8i8ZseWddi)SObBnLyGCi45bDBvGS4Q1uThpq)umPXa2Gc(GPRqNPhiqTMQLfhukQrhjH4S2FRLc(SyXbt)zXHGDutcNt4aNV7ruzKqF9(SqNPhiWJWplrapmG8ZIgS1uCiyh1IooSr18ybb1(BT0GTMIdb7Ow0XHnQizj1ZJfe8SyXbt)zXHGDuJsAmYjm939iQm2JE9(SqNPhiWJWplrapmG8ZIgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccQ1uTgbkvBlauYQ4qWoQP5iyB8zXIdM(ZIdb7OgL0yKty6V7ruzSN(69zb9dJa040W2ZIKDwzioZsThqOplOFyeGgNgssIaq(WNLSplwCW0FwO0uWhm9Nf6m9abEe(DV7zbGngCCVEFev2xVplwCW0FwIe0pmMg4y8SqNPhiWJWV7ru5(69zHotpqGhHFwIaEya5NLe1E8a9tH(aA3DOJak0z6bcuRPAjzNvgIR2FPwBpwM1AQws2zLH4Q1SuRThrO1szTetCTsu7pR94b6Nc9b0U7qhbuOZ0deOwt1sYoRmexT)sT2EmHwlLplwCW0FwKSZABK8DpIkJVEFwOZ0de4r4NLiGhgq(zrd2AkoeSJAJ8ddfOXZIfhm9NLrEW0F3JOuWxVpl0z6bc8i8ZseWddi)ScqhBzyJQdjnYGh6pomuOZ0deOwt1sd2AkuYogCEW0vGg1AQwjQvK5ai)Cfhc2rTr(HHkqgOFTetCT05CwRPABq7Uthijd9zT)sTwkOmRLYNfloy6pRdsI6pomE3JOe6R3Nf6m9abEe(zjc4HbKFw0GTMIdb7O2i)WqbKFETMQLgS1ubOJ6SPnYpmua5NxRPAbqAWwtDjOOtNn91HAs2gQaYp)zXIdM(ZAaT7UP(heeWMe97DpI2JE9(SqNPhiWJWplrapmG8ZIgS1uCiyh1g5hgkG8ZR1uT0GTMkaDuNnTr(HHci)8Anvlasd2AQlbfD6SPVoutY2qfq(5plwCW0Fw0SToB6lGccMV7r0E6R3Nf6m9abEe(zjc4HbKFw0GTMIdb7O2i)WqbA8SyXbt)zrJXedcGU97EeTh)69zHotpqGhHFwIaEya5NfnyRP4qWoQnYpmuGgplwCW0Fw0Jmb0nWO)7EeTh869zHotpqGhHFwIaEya5NfnyRP4qWoQnYpmuGgplwCW0FwnyG0JmbE3JOYkZxVpl0z6bc8i8ZseWddi)SObBnfhc2rTr(HHc04zXIdM(ZIDboVGhAbpgV7ruzL917ZcDMEGapc)Seb8WaYplAWwtXHGDuBKFyOanEwS4GP)SaNOgEi58DpIkRCF9(SqNPhiWJWplwCW0Fw2dgaYxgtnndyJplrapmG8ZIgS1uCiyh1g5hgkqJAjM4AfzoaYpxXHGDuBKFyOcKKH(SwZsTwcLqR1uTainyRPUeu0PZM(6qnjBdvGgplS1qXPDMeFw2dgaYxgtnndyJV7ruzLXxVpl0z6bc8i8ZIfhm9NfsA0pqEOZaWzxGplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)LATsuRSYyTeP2EAT9KALYbKPhOIn0PRbNyTuwRPAfzoaYpxDjOOtNn91HAs2gQcKKH(S2FPwRe1kRmwlrQTNwBpPwPCaz6bQydD6AWjwlLplNjXNfsA0pqEOZaWzxGV7ruzPGVEFwOZ0de4r4Nfloy6plGazGgmqTuCoXXZseWddi)SezoaYpxXHGDuBKFyOcKKH(SwZsTw5kZAjM4A)zTs5aY0duXg601GtSwQ1kBTetCTsu7bjXAPwRmR1uTs5aY0du1GZoOBRtd0XOwQ1kBTMQnaDSLHnQMqJU01Zldsf6m9abQLYNLZK4ZciqgObdulfNtC8UhrLLqF9(SqNPhiWJWplwCW0FwZeCOH2o8W4zjc4HbKFwImha5NR4qWoQnYpmubsYqFwRzPwRmkZAjM4A)zTs5aY0duXg601GtSwQ1k7ZYzs8zntWHgA7WdJ39iQS9OxVpl0z6bc8i8ZIfhm9NL9OVrNoBAEoHKWbFW0FwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1AwQ1kxzwlXex7pRvkhqMEGk2qNUgCI1sTwzRLyIRvIApijwl1ALzTMQvkhqMEGQgC2bDBDAGog1sTwzR1uTbOJTmSr1eA0LUEEzqQqNPhiqTu(SCMeFw2J(gD6SP55esch8bt)DpIkBp917ZcDMEGapc)SyXbt)zrYcMoq9SdXttcoHINLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)sTwcTwt1krT)SwPCaz6bQAWzh0T1Pb6yul1ALTwIjU2dsI1A2ALrzwlLplNjXNfjly6a1Zoepnj4ekE3JOY2JF9(SqNPhiWJWplwCW0FwKSGPdup7q80KGtO4zjc4HbKFwImha5NR4qWoQnYpmubsYqFw7VuRLqR1uTs5aY0du1GZoOBRtd0XOwQ1kBTMQLgS1ubOJ6SPnYpmuGg1AQwAWwtfGoQZM2i)Wqfijd9zT)sTwjQvwzw7pqTeAT9KAdqhBzyJQj0OlD98YGuHotpqGAPSwt1EqsS2FRvgL5ZYzs8zrYcMoq9SdXttcoHI39iQS9GxVpl0z6bc8i8ZcCI6Vo4a1cEEq3(ruzFwS4GP)SC8RLGoGoWzoKIplrapmG8ZIgS1uCiyh1g5hgkqJAjM4AbqAWwtDjOOtNn91HAs2gQanQLyIRfipvWaq2p90Gdcuhuqa0TF3JOYvMVEFwOZ0de4r4Nfloy6plbpgAwCW01d48Ewd480otIplbpeGd(GPpF3JOYv2xVpl0z6bc8i8ZseWddi)SyXbLIA0rsioR1S1k3N18cO4Eev2Nfloy6plbpgAwCW01d48Ewd480otIploX39iQCL7R3Nf6m9abEe(zjc4HbKFwIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0de4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZQJdY07)UhrLRm(69zHotpqGhHFwIaEya5NLuoGm9avDSuuNgOJa1sTwzwRPALYbKPhOQbNDq3wNgOJrTMQ9N1krTIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0deOwkFwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SAWzh0T1Pb6y8UhrLlf817ZcDMEGapc)Seb8WaYplPCaz6bQ6yPOonqhbQLATYSwt1(ZALOwrkfD2pfb9di71AQ2a0Xwg2OIdb7Og6nOdV(k0z6bculLplwCW0FwcEm0S4GPRhW59SgW5PDMeFwPb6y8UhrLlH(69zHotpqGhHFwIaEya5N1pRvIAfPu0z)ue0pGSxRPAdqhBzyJkoeSJAO3Go86RqNPhiqTu(SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zjYCaKF(8DpIk3E0R3Nf6m9abEe(zjc4HbKFws5aY0du1Gop00GHxl1ALzTMQ9N1krTIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0deOwkFwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SI84dM(7EevU90xVpl0z6bc8i8ZseWddi)SKYbKPhOQbDEOPbdVwQ1kBTMQ9N1krTIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0deOwkFwS4GP)Se8yOzXbtxpGZ7znGZt7mj(SAqNhAAWWF37EwgbkssA(E9(iQSVEFwS4GP)S4qWoQH(HJbkUNf6m9abEe(DpIk3xVplwCW0FwtqsY01Ciyh1nMeoGC8SqNPhiWJWV7ruz817ZIfhm9NLi9FqWa1KSZABK8zHotpqGhHF3JOuWxVpl0z6bc8i8ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwO0uBiUNfa2yWX9SKLqF3JOe6R3Nf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLdTZK4ZYiqdWXqJsZNLiGhgq(zjrTbOJTmSr1eA0LUEEzqQqNPhiqTMQvIAfPu0z)usr)66h1smX1ksPOZ(PCue5idGAjM4AfPdacpfhc2rTrKaq7(k0z6bculL1s5ZskparnoM4ZsMplP8aeFwY(Uhr7rVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuo0otIpRowkQtd0rGNLiGhgq(zXIdkf1OJKqCwRzRvUplP8ae14yIplz(SKYdq8zj77EeTN(69zHotpqGhHFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SK5ZskhANjXNvd68qtdg(7EeTh)69zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZQJdY07RNhliqFqs8zbGngCCpREW7EeTh869zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZkMAswsnao4(6wg6lpYNfa2yWX9Si039iQSY817ZcDMEGapc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNvm1KSKAaCW91Tm0rA8SaWgdoUNfH(UhrLv2xVpl0z6bc8i8ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwXutYsQbWb3x3YqZgplaSXGJ7zjxz(UhrLvUVEFwOZ0de4r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SiZtBeOara9LhPMU)ZcaBm44Ew9439iQSY4R3Nf6m9abEe(zLgpRaN49SyXbt)zjLditpWNLuo0otIplY80KSKAaCW91Tm0xEKplaSXGJ7zjRmF3JOYsbF9(SqNPhiWJWpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zrMNMKLudGdUVULHMnEwayJbh3Zswc9DpIklH(69zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZIn0KSKAaCW91Tm0xEKplrapmG8ZsKoai8uCiyh1grcaT7RqNPhiWZskparnoM4Zswz(SKYdq8zjJY8DpIkBp617ZcDMEGapc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfBOjzj1a4G7RBzOV8iFwayJbh3Zswz(UhrLTN(69zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZIn0KSKAaCW91Tm0K59SaWgdoUNLCL57Eev2E8R3Nf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsUYS2FGALOwcT2EsTI0baHNIdb7O2isaODFf6m9abQLYNLuo0otIpRin0KSKAaCW91Tm0xEKV7ruz7bVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplcTwIuRCLzT9KALOwrkfD2pLdT7oDJXAjM4ALOwr6aGWtXHGDuBeja0UVcDMEGa1AQwwCqPOgDKeIZA)TwzSwkRLYAjsTYsO12tQvIAfPu0z)ue0pGSxRPAdqhBzyJkoeSJAO3Go86RqNPhiqTMQLfhukQrhjH4SwZwRCRLYNLuo0otIpRlpsnjlPgahCFDldnB8UhrLRmF9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwYvM1(duRe12JRTNuRiDaq4P4qWoQnIeaA3xHotpqGAP8zjLdTZK4Z6YJutYsQbWb3x3YqhPX7EevUY(69zHotpqGhHFwPXZAI3ZIfhm9NLuoGm9aFws5bi(S6rYS2FGALOwsEEy0xlLhGyT9KALvMYSwkFwIaEya5NLiLIo7NYH2DNUX4ZskhANjXNfnhbBJAs2zTH4E3JOYvUVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIpREaHw7pqTsuljppm6RLYdqS2EsTYktzwlLplrapmG8ZsKsrN9trq)aY(ZskhANjXNfnhbBJAs2zTH4E3JOYvgF9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFw9yzw7pqTsuljppm6RLYdqS2EsTYktzwlLplrapmG8ZskhqMEGkAoc2g1KSZAdXvl1AL5ZskhANjXNfnhbBJAs2zTH4E3JOYLc(69zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZIn0KqhscsQjzN1gI7zbGngCCplzj039iQCj0xVpl0z6bc8i8ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwxEKAswsTOJdBC(SaWgdoUNLCF3JOYTh969zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZItuF5rQjzj1IooSX5ZcaBm44EwY9DpIk3E6R3Nf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4Zs2A7j1krTOCgeAyGakK0OFG8qNbGZUaRLyIRvIApEG(Pcqh1ztBKFyOqNPhiqTMQvIApEG(P4qWoQrrxQqNPhiqTetCT)SwrkfD2pfb9di71szTMQvIA)zTIuk6SFkhfroYaOwIjUwwCqPOgDKeIZAPwRS1smX1gGo2YWgvtOrx665LbPcDMEGa1szTMQ9N1ksPOZ(PKI(11pQLYAP8zjLdTZK4ZQbNDq3wNgOJX7EevU94xVpl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNfkNbHggiGIKfmDG6zhINMeCcf1smX1IYzqOHbcOShmaKVmMAAgWgRLyIRfLZGqddeqzpyaiFzm1KiapgW0RLyIRfLZGqddeqbWbbKz6AauqG2a8cCkqxG1smX1IYzqOHbcOG(ueGhtpqTCgK9dKudGsHcSwIjUwuodcnmqa1mbhd8oOBRdq6(1smX1IYzqOHbcOMGo9itantIxx)5vlXexlkNbHggiG6JjaDmM6wKoqTetCTOCgeAyGaQ2GjrD2008Dd8zjLdTZK4ZIn0PRbN47EevU9GxVplwCW0FwKWiYqdjzB8zHotpqGhHF3JOYOmF9(SqNPhiWJWplrapmG8Z6N1kLditpqLrGgGJHgLM1sTwzR1uTbOJTmSrfaCkGgdOZrFTijjzhqHotpqGNfloy6pRwKZJoh37EevgL917ZcDMEGapc)Seb8WaYpRFwRuoGm9avgbAaogAuAwl1ALTwt1(ZAdqhBzyJka4uangqNJ(ArssYoGcDMEGa1AQwjQ9N1ksPOZ(PKI(11pQLyIRvkhqMEGQgC2bDBDAGog1s5ZIfhm9Nfhc2rn9GN37EevgL7R3Nf6m9abEe(zjc4HbKFw)SwPCaz6bQmc0aCm0O0SwQ1kBTMQ9N1gGo2YWgvaWPaAmGoh91IKKKDaf6m9abQ1uTIuk6SFkPOFD9JAnv7pRvkhqMEGQgC2bDBDAGogplwCW0FwKWiYyQZM(YGe97DpIkJY4R3Nf6m9abEe(zjc4HbKFws5aY0duzeOb4yOrPzTuRv2Nfloy6pluAk4dM(7E3ZsK5ai)85R3hrL917ZcDMEGapc)SyXbt)z1ICEApLYplaCkcOXbt)z9Jbmd4bPaG1coHUDT2bCo6xluafdS2p41vlBOQvoDI1cVA)GxxTxEK1MxhgFWjQEwIaEya5Nva6yldBuzhW5OVgkGIbQqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTYOmR1uTImha5NRUeu0PZM(6qnjBdvbYa9R1uTsulnyRP4qWoQfDCyJQ5XccQ9xQ1kLditpq1LhPMKLul64WgN1AQwjQvIApEG(Pcqh1ztBKFyOqNPhiqTMQvK5ai)Cva6OoBAJ8ddvGKm0N1(l1ATfa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUVULHMnQLYAjM4ALO2Fw7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCFDldnBulL1smX1kYCaKFUIdb7O2i)Wqfijd9zT)sTwBbqTuwlLV7ru5(69zHotpqGhHFwIaEya5Nva6yldBuzhW5OVgkGIbQqNPhiqTMQvK5ai)Cfhc2rTr(HHkqgOFTMQvIA)zThpq)uOpG2Dh6iGcDMEGa1smX1krThpq)uOpG2Dh6iGcDMEGa1AQws2zLH4Q1SuRTNkZAPSwkR1uTsuRe1kYCaKFU6sqrNoB6Rd1KSnufijd9zTMTwzLzTMQLgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccQLYAjM4ALOwrMdG8Zvxck60ztFDOMKTHQajzOpRLATYSwt1sd2AkoeSJArhh2OAESGGAPwRmRLYAPSwt1sd2AQa0rD20g5hgkG8ZR1uTKSZkdXvRzPwRuoGm9avSHMe6qsqsnj7S2qCplwCW0FwTiNN2tP87EevgF9(SqNPhiWJWplrapmG8ZkaDSLHnQaGtb0yaDo6Rfjjj7ak0z6bcuRPAfzoaYpxrd2AAa4uangqNJ(ArssYoGkqgOFTMQLgS1uaWPaAmGoh91IKKKDaDlY5PaYpVwt1krT0GTMIdb7O2i)WqbKFETMQLgS1ubOJ6SPnYpmua5NxRPAbqAWwtDjOOtNn91HAs2gQaYpVwkR1uTImha5NRUeu0PZM(6qnjBdvbsYqFwl1ALzTMQvIAPbBnfhc2rTOJdBunpwqqT)sTwPCaz6bQU8i1KSKArhh24Swt1krTsu7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NRcqh1ztBKFyOcKKH(S2FPwRTaOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwPCaz6bQU8i1KSKAaCW91Tm0SrTuwlXexRe1(ZApEG(Pcqh1ztBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTs5aY0duD5rQjzj1a4G7RBzOzJAPSwIjUwrMdG8ZvCiyh1g5hgQajzOpR9xQ1AlaQLYAP8zXIdM(ZQf58OZX9UhrPGVEFwOZ0de4r4NLiGhgq(zfGo2YWgvaWPaAmGoh91IKKKDaf6m9abQ1uTImha5NRObBnnaCkGgdOZrFTijjzhqfid0Vwt1sd2Aka4uangqNJ(ArssYoGUbdubKFETMQ1iqPABbGswvlY5rNJ7zXIdM(ZQbdutp459Uhrj0xVpl0z6bc8i8ZIfhm9NfjmImM6SPVmir)Ewa4ueqJdM(Z6hzyuBpm7T2p41vBp)J1cB1cV)ZAfjj0TRf0O2zMUQ2FyRw4v7hCmQLgRfCIa1(bVUA7nVEO51k45vl8QDoG2D3OFT0yld8zjc4HbKFwImha5NRUeu0PZM(6qnjBdvbsYqFw7V1kLditpqfzEAJaficOV8i109RLyIRvIALYbKPhO6GKOg0p4qZg1A2ALYbKPhOImpnjlPgahCFDldnBuRPAfzoaYpxDjOOtNn91HAs2gQcKKH(SwZwRuoGm9avK5Pjzj1a4G7RBzOV8iRLY39iAp617ZcDMEGapc)Seb8WaYplrMdG8ZvCiyh1g5hgQazG(1AQwjQ9N1E8a9tH(aA3DOJak0z6bculXexRe1E8a9tH(aA3DOJak0z6bcuRPAjzNvgIRwZsT2EQmRLYAPSwt1krTsuRiZbq(5QlbfD6SPVoutY2qvGKm0N1A2ALYbKPhOIn0KSKAaCW91Tm0xEK1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwkRLyIRvIAfzoaYpxDjOOtNn91HAs2gQcKKH(SwQ1kZAnvlnyRP4qWoQfDCyJQ5XccQLATYSwkRLYAnvlnyRPcqh1ztBKFyOaYpVwt1sYoRmexTMLATs5aY0duXgAsOdjbj1KSZAdX9SyXbt)zrcJiJPoB6lds0V39iAp917ZcDMEGapc)SyXbt)zbG81rNHJplaCkcOXbt)z1ZJpU)SwWjwlaYxhDgow7h86QLnu1(dB1E5rwlCwBGmq)A5zTF4yyETKmbyTtWaR9YAf88QfE1sJTmWAV8ivplrapmG8ZsK5ai)C1LGIoD20xhQjzBOkqgOFTMQLgS1uCiyh1IooSr18ybb1(l1ALYbKPhO6YJutYsQfDCyJZAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1ATfaV7r0E8R3Nf6m9abEe(zjc4HbKFwImha5NR4qWoQnYpmubYa9R1uTsu7pR94b6Nc9b0U7qhbuOZ0deOwIjUwjQ94b6Nc9b0U7qhbuOZ0deOwt1sYoRmexTMLAT9uzwlL1szTMQvIALOwrMdG8Zvxck60ztFDOMKTHQajzOpR1S1kRmR1uT0GTMIdb7Ow0XHnQMhliOwQ1sd2AkoeSJArhh2OIKLuppwqqTuwlXexRe1kYCaKFU6sqrNoB6Rd1KSnufid0Vwt1sd2AkoeSJArhh2OAESGGAPwRmRLYAPSwt1sd2AQa0rD20g5hgkG8ZR1uTKSZkdXvRzPwRuoGm9avSHMe6qsqsnj7S2qCplwCW0FwaiFD0z447EeTh869zHotpqGhHFwS4GP)ScgaY(PNgCqWZcaNIaACW0FwYPtS2PbheulSv7LhzTSdulBulhyTPxRaOw2bQ9l9)xT0yTGg12YO2r62yu71XETxhwljlzTa4G7BETKmbq3U2jyG1(H12XsXA5R2bYZR27lRLdb7yTIooSXzTSdu71XxTxEK1(Xt))v7pi48QfCIaQNLiGhgq(zjYCaKFU6sqrNoB6Rd1KSnufijd9zTMTwPCaz6bQIPMKLudGdUVULH(YJSwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwPCaz6bQIPMKLudGdUVULHMnQ1uTsu7Xd0pva6OoBAJ8ddf6m9abQ1uTsuRiZbq(5Qa0rD20g5hgQajzOpR93Arjrb4H6dsI1smX1kYCaKFUkaDuNnTr(HHkqsg6ZAnBTs5aY0duftnjlPgahCFDldDKg1szTetCT)S2JhOFQa0rD20g5hgk0z6bculL1AQwAWwtXHGDul64WgvZJfeuRzRvU1AQwaKgS1uxck60ztFDOMKTHkG8ZR1uT0GTMkaDuNnTr(HHci)8AnvlnyRP4qWoQnYpmua5N)UhrLvMVEFwOZ0de4r4Nfloy6pRGbGSF6Pbhe8SaWPiGghm9NLC6eRDAWbb1(bVUAzJA)6qVwJCoH0duv7pSv7LhzTWzTbYa9RLN1(HJH51sYeG1obdS2lRvWZRw4vln2YaR9YJu9Seb8WaYplrMdG8Zvxck60ztFDOMKTHQajzOpR93Arjrb4H6dsI1AQwAWwtXHGDul64WgvZJfeu7VuRvkhqMEGQlpsnjlPw0XHnoR1uTImha5NR4qWoQnYpmubsYqFw7V1krTOKOa8q9bjXAjsTS4GPRUeu0PZM(6qnjBdvOKOa8q9bjXAP8DpIkRSVEFwOZ0de4r4NLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)wlkjkapuFqsSwt1krTsu7pR94b6Nc9b0U7qhbuOZ0deOwIjUwjQ94b6Nc9b0U7qhbuOZ0deOwt1sYoRmexTMLAT9uzwlL1szTMQvIALOwrMdG8Zvxck60ztFDOMKTHQajzOpR1S1kLditpqfBOjzj1a4G7RBzOV8iR1uT0GTMIdb7Ow0XHnQMhliOwQ1sd2AkoeSJArhh2OIKLuppwqqTuwlXexRe1kYCaKFU6sqrNoB6Rd1KSnufijd9zTuRvM1AQwAWwtXHGDul64WgvZJfeul1ALzTuwlL1AQwAWwtfGoQZM2i)WqbKFETMQLKDwziUAnl1ALYbKPhOIn0KqhscsQjzN1gIRwkFwS4GP)ScgaY(PNgCqW7Eevw5(69zHotpqGhHFwS4GP)SUeu0PZM(6qnjBdFwa4ueqJdM(ZsoDI1E5rw7h86QLnQf2QfE)N1(bVoOx71H1sYswlao4(QA)HTA98mVwWjw7h86QnsJAHTAVoS2JhOF1cN1EmbOBETSdul8(pR9dEDqV2RdRLKLSwaCW9vplrapmG8ZIgS1uCiyh1IooSr18ybb1(l1ALYbKPhO6YJutYsQfDCyJZAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1Arjrb4H6dsI1AQws2zLH4Q1S1kLditpqfBOjHoKeKutYoRnexTMQLgS1ubOJ6SPnYpmua5N)UhrLvgF9(SqNPhiWJWplrapmG8ZIgS1uCiyh1IooSr18ybb1(l1ALYbKPhO6YJutYsQfDCyJZAnv7Xd0pva6OoBAJ8ddf6m9abQ1uTImha5NRcqh1ztBKFyOcKKH(S2FPwlkjkapuFqsSwt1kLditpq1bjrnOFWHMnQ1S1kLditpq1LhPMKLudGdUVULHMnEwS4GP)SUeu0PZM(6qnjBdF3JOYsbF9(SqNPhiWJWplrapmG8ZIgS1uCiyh1IooSr18ybb1(l1ALYbKPhO6YJutYsQfDCyJZAnvRe1(ZApEG(Pcqh1ztBKFyOqNPhiqTetCTImha5NRcqh1ztBKFyOcKKH(SwZwRuoGm9avxEKAswsnao4(6wg6inQLYAnvRuoGm9avhKe1G(bhA2OwZwRuoGm9avxEKAswsnao4(6wgA24zXIdM(Z6sqrNoB6Rd1KSn8DpIklH(69zHotpqGhHFwS4GP)S4qWoQnYpmEwa4ueqJdM(ZsoDI1Yg1cB1E5rwlCwB61kaQLDGA)s))vlnwlOrTTmQDKUng1EDSx71H1sYswlao4(Mxljta0TRDcgyTxhF1(H12XsXArpbT7QLKDUw2bQ964R2RddSw4SwpVA5rGmq)A5AdqhRnB1AKFyulq(5QNLiGhgq(zjYCaKFU6sqrNoB6Rd1KSnufijd9zTMTwPCaz6bQydnjlPgahCFDld9LhzTMQvIA)zTIuk6SFkPOFD9JAjM4AfzoaYpxrcJiJPoB6lds0pvGKm0N1A2ALYbKPhOIn0KSKAaCW91Tm0K5vlL1AQwAWwtXHGDul64WgvZJfeul1APbBnfhc2rTOJdBurYsQNhliOwt1sd2AQa0rD20g5hgkG8ZR1uTKSZkdXvRzPwRuoGm9avSHMe6qsqsnj7S2qCV7ruz7rVEFwOZ0de4r4Nfloy6pRa0rD20g5hgplaCkcOXbt)zjNoXAJ0OwyR2lpYAHZAtVwbqTSdu7x6)VAPXAbnQTLrTJ0TXO2RJ9AVoSwswYAbWb338AjzcGUDTtWaR96WaRfo9)xT8iqgOFTCTbOJ1cKFETSdu71XxTSrTFP))QLgfjjwllLHdMEG1cagq3U2a0r1ZseWddi)SObBnfhc2rTr(HHci)8AnvRe1kYCaKFU6sqrNoB6Rd1KSnufijd9zTMTwPCaz6bQI0qtYsQbWb3x3YqF5rwlXexRiZbq(5koeSJAJ8ddvGKm0N1(l1ALYbKPhO6YJutYsQbWb3x3YqZg1szTMQLgS1uCiyh1IooSr18ybb1sTwAWwtXHGDul64WgvKSK65XccQ1uTImha5NR4qWoQnYpmubsYqFwRzRvw5(UhrLTN(69zHotpqGhHFwIaEya5NLuoGm9avj4nHaOoBArMdG8ZNplwCW0FwZoy7GUT2i)W4DpIkBp(17ZcDMEGapc)SyXbt)zze4eDbQZMMe6aplaCkcOXbt)zjNoXAnsYAVS2PCgerkayTSxlk5fCTmDTqV2RdR1rjVAfzoaYpV2pOdKFMxlOpW5Swc6hq2R96qV20h9RfamGUDTCiyhR1i)WOwaqS2lRTl)QLKDU2oq3o6xBWaq2VANgCqqTW5ZseWddi)SoEG(Pcqh1ztBKFyOqNPhiqTMQLgS1uCiyh1g5hgkqJAnvlnyRPcqh1ztBKFyOcKKH(S2FR1waOizjF3JOY2dE9(SqNPhiWJWplrapmG8ZcaPbBn1LGIoD20xhQjzBOc0Owt1cG0GTM6sqrNoB6Rd1KSnufijd9zT)wlloy6koeSJAs4Cch4uHsIcWd1hKeR1uT)SwrkfD2pfb9di7plwCW0FwgborxG6SPjHoW7EevUY817ZcDMEGapc)Seb8WaYplAWwtfGoQZM2i)WqbAuRPAPbBnva6OoBAJ8ddvGKm0N1(BT2cafjlzTMQvK5ai)Cfknf8btxfid0Vwt1kYCaKFU6sqrNoB6Rd1KSnufijd9zTMQ9N1ksPOZ(PiOFaz)zXIdM(ZYiWj6cuNnnj0bE37EwDCqME)xVpIk7R3Nf6m9abEe(zXIdM(ZcLMc(GP)SaWPiGghm9N1pSv7i)Qn9AjzNRLDGAfzoaYpFwlhyTIKe621cAyET2zTChYa1YoqTO08zjc4HbKFwKSZkdXv7VuRvgLzTMQvkhqMEGQe8MqauNnTiZbq(5ZAnvRe1E8a9tfGoQZM2i)WqHotpqGAnvRiZbq(5Qa0rD20g5hgQajzOpR93ALvM1s57EevUVEFwOZ0de4r4Nfloy6ploeSJAs4Cch48zj6yO)SK9zjc4HbKFwsuRuoGm9avZJfeO74Gm9(1smX1EqsS2FRvwzwlL1AQwAWwtXHGDu3Xbz69vZJfeu7V1sd2AkoeSJ6ooitVVIKLuppwqW7EevgF9(SqNPhiWJWplwCW0FwCiyh1KW5eoW5ZcaNIaACW0FwYHDOxl4e621sbsA0pqEuRCIaWzxGMxRGNxTCTn8RwuYl4AjHZjCGZA)6GdS2pgEq3U2wg1EDyT0GTwT8v71H1opoUAZwTxhwBdA3DplrapmG8ZcLZGqddeqHKg9dKh6maC2fyTMQ9GKyT)wRmkZAnv7L22dujYCaKF(Swt1kYCaKFUcjn6hip0za4SlqvGKm0N1A2ALTh1JF3JOuWxVpl0z6bc8i8ZseWddi)SKYbKPhOcjnYpmqannhbBJ1AQwrMdG8Zvxck60ztFDOMKTHQajzOpR9xQ1IsIcWd1hKeR1uTImha5NR4qWoQnYpmubsYqFw7VuRvIArjrb4H6dsI12tQvU1szTMQvIA)zTOCgeAyGaQzcog4Dq3whG09RLyIRvKoai8uCiyh1grcaT7Rc2jOwZsTwcTwIjUwrMdG8ZvZeCmW7GUToaP7RcKKH(S2FPwRe1IsIcWd1hKeRTNuRCRLYAP8zXIdM(Zkyai7NEAWbbV7ruc917ZcDMEGapc)Seb8WaYplPCaz6bQ(bbNNgCIa6PbheuRPAfzoaYpxXHGDuBKFyOcKKH(S2FPwlkjkapuFqsSwt1krT)Swuodcnmqa1mbhd8oOBRdq6(1smX1kshaeEkoeSJAJibG29vb7euRzPwlHwlXexRiZbq(5Qzcog4Dq3whG09vbsYqFw7VuRfLefGhQpijwlLplwCW0Fwxck60ztFDOMKTHV7r0E0R3Nf6m9abEe(zjc4HbKFwgbkvBlauYQUeu0PZM(6qnjBdFwS4GP)S4qWoQnYpmE3JO90xVpl0z6bc8i8ZseWddi)SKYbKPhOcjnYpmqannhbBJ1AQwrMdG8Zvbdaz)0tdoiqfijd9zT)sTwusuaEO(GKyTMQvkhqMEGQdsIAq)GdnBuRzPwRCL5ZIfhm9Nva6OoBAJ8dJ39iAp(17ZcDMEGapc)Seb8WaYplPCaz6bQqsJ8ddeqtZrW2yTMQ1iqPABbGswva6OoBAJ8dJNfloy6pRGbGSF6Pbhe8Uhr7bVEFwOZ0de4r4NLiGhgq(zjLditpq1pi480Gteqpn4GGAnv7pRvkhqMEGQUCaaDB9Lh5ZIfhm9N1LGIoD20xhQjzB47Eevwz(69zHotpqGhHFwIaEya5NfnyRP4qWoQnYpmua5NxRPALOwPCaz6bQoijQb9do0SrTMTwzuM1smX1kYCaKFUkyai7NEAWbbQajzOpR1S1kRCRLYNfloy6pRa0rD20g5hgV7ruzL917ZcDMEGapc)Seb8WaYplPCaz6bQqsJ8ddeqtZrW2yTMQvIAPbBnfhc2rTOJdBunpwqqTMLATYTwIjUwrMdG8ZvCiyh1zqRcKb6xlL1AQwjQ9N1E8a9tfGoQZM2i)WqHotpqGAjM4AfzoaYpxfGoQZM2i)Wqfijd9zTMTwcTwkR1uTs5aY0duHZdsYhcOzdTiZbq(51AwQ1kJY8zXIdM(Zkyai7NEAWbbV7ruzL7R3Nf6m9abEe(zXIdM(Z6sqrNoB6Rd1KSn8zbGtranoy6pl5Wo0RnaDh621Aeja0UV51coXAV8iRLUFTWBIJwTqV2maWO2lRLhqBVw4v7h86QLnEwIaEya5NLuoGm9avhKe1G(bhA2O2FRLqLzTMQvkhqMEGQdsIAq)GdnBuRzRvgLzTMQvIA)zTOCgeAyGaQzcog4Dq3whG09RLyIRvKoai8uCiyh1grcaT7Rc2jOwZsTwcTwkF3JOYkJVEFwOZ0de4r4NLiGhgq(zjLditpq1pi480Gteqpn4GGAnvlnyRP4qWoQfDCyJQ5XccQ93APbBnfhc2rTOJdBurYsQNhli4zXIdM(ZIdb7Ood639iQSuWxVpl0z6bc8i8ZseWddi)SaqAWwtfmaK9tpn4GaTuWHJbtdhWRVAESGGAPwlasd2AQGbGSF6PbheOLcoCmyA4aE9vKSK65XccEwS4GP)S4qWoQP5iyB8DpIklH(69zHotpqGhHFwIaEya5NLuoGm9av)GGZtdora90GdcQLyIRvIAbqAWwtfmaK9tpn4GaTuWHJbtdhWRVc0Owt1cG0GTMkyai7NEAWbbAPGdhdMgoGxF18ybb1(BTainyRPcgaY(PNgCqGwk4WXGPHd41xrYsQNhliOwkFwS4GP)S4qWoQPh88E3JOY2JE9(SqNPhiWJWplwCW0FwCiyh1zq)SaWPiGghm9NLC6eRnd6AtVwbqTG(aNZAzJAHZAfjj0TRf0O2zM(ZseWddi)SObBnfhc2rTOJdBunpwqqT)wRmwRPALYbKPhO6GKOg0p4qZg1A2ALvMV7ruz7PVEFwOZ0de4r4Nfloy6ploeSJAs4Cch48zj6yO)SK9zjc4HbKFw0GTMsmqoe88GUTkqwC1AQwAWwtXHGDuBKFyOanE3JOY2JF9(SqNPhiWJWplrapmG8ZIgS1ugborxG6SPjHoGc04zXIdM(ZIdb7OMEWZ7DpIkBp417ZcDMEGapc)SyXbt)zze4eDbQZMMe6aplaCkcOXbt)z1BhwlnoVAbNyTzRwJKSw4S2lRfCI1cVAVSw5miuqWOFT0GWbqTIooSXzTaGb0TRLnQLBhg1EDy)ATXRwaqsdeOw6(1EDyTDCqME)AP5iyB8zjc4HbKFw0GTMIdb7Ow0XHnQMhliO2FRLgS1uCiyh1IooSrfjlPEESGGAnvlnyRP4qWoQnYpmuGgV7ru5kZxVpl0z6bc8i8ZIfhm9Nfhc2rnjCoHdC(SG(HraACplzFwIaEya5NfnyRP4qWoQ74Gm9(Q5XccQ93APbBnfhc2rDhhKP3xrYsQNhli4zj6yO)SK9zb9dJa0402JKMhplzF3JOYv2xVpl0z6bc8i8ZseWddi)SObBnfhc2rTOJdBunpwqqTuRLgS1uCiyh1IooSrfjlPEESGGAnvRuoGm9aviPr(HbcOP5iyB8zXIdM(ZIdb7OMMJGTX39iQCL7R3Nf6m9abEe(zjc4HbKFwKSZkdXv7V1klH(SyXbt)zHstbFW0F3JOYvgF9(SqNPhiWJWplwCW0FwCiyh10dEEplaCkcOXbt)zjNWh9RfCI1sp45v7L1sdcha1k64WgN1cB1(H1YJazG(12XsXANjjwBlsYAZG(zjc4HbKFw0GTMIdb7Ow0XHnQMhliOwt1sd2AkoeSJArhh2OAESGGA)TwAWwtXHGDul64WgvKSK65XccE3JOYLc(69zHotpqGhHFwa4ueqJdM(ZsozWXO2p41vltwlOpW5Sw2Ow4SwrscD7AbnQLDGA)W)bw7i)Qn9AjzNFwS4GP)S4qWoQjHZjCGZNf0pmcqJ7zj7Zs0Xq)zj7ZseWddi)S(zTsuRuoGm9avhKe1G(bhA2O2FPwRSYSwt1sYoRmexT)wRmkZAP8zb9dJa0402JKMhplzF3JOYLqF9(SqNPhiWJWplaCkcOXbt)z9Jr2GdCw7h86QDKF1sYZdJ(MxBh0UR2oEEO51MrT051vlj3VwpVA7yPyTONG2D1sYox7L1obnmY4QTl)QLKDUwOFOpHsXAdgaY(v70GdcQvWET0O51oZA)W)JrTGtS2gmWAPh88QLDGABrop6CC1(1HETJ8R20RLKD(zXIdM(ZQbdutp459UhrLBp617ZIfhm9NvlY5rNJ7zHotpqGhHF37EwcEiah8btF(69ruzF9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwY(Seb8WaYplPCaz6bQ6yPOonqhbQLATYSwt1AeOuTTaqjRcLMc(GPxRPA)zTsuBa6yldBunHgDPRNxgKk0z6bculXexBa6yldBuDiPrg8q)XHHcDMEGa1s5ZskhANjXNvhlf1Pb6iW7EevUVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplzFwIaEya5NLuoGm9avDSuuNgOJa1sTwzwRPAPbBnfhc2rTr(HHci)8AnvRiZbq(5koeSJAJ8ddvGKm0N1AQwjQnaDSLHnQMqJU01Zldsf6m9abQLyIRnaDSLHnQoK0idEO)4WqHotpqGAP8zjLdTZK4ZQJLI60aDe4DpIkJVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplzFwIaEya5NfnyRP4qWoQfDCyJQ5XccQLAT0GTMIdb7Ow0XHnQizj1ZJfeuRPA)zT0GTMkahOoB6RlqCQanQ1uTnOD3PdKKH(S2FPwRe1krTKSZ1sXAzXbtxXHGDutp45Pe58QLYA7j1YIdMUIdb7OMEWZtHsIcWd1hKeRLYNLuo0otIpRg05HMgm839ikf817ZcDMEGapc)SsJN1eVNfloy6plPCaz6b(SKYdq8zrd2AkoeSJ6ooitVVAESGGAPwlnyRP4qWoQ74Gm9(ksws98ybb1smX1krTbOJTmSrfhc2rnDssZbaj6NcDMEGa1AQ2JdB8uDipUoLH4Q93ALrcTwkFwa4ueqJdM(ZIceEDyulxBdCm6x78ybbiqTDCqME)AZOwOxlkjkapS2GDBS2p41vlHtsAoair)Ews5q7mj(SqsJ8ddeqtZrW247EeLqF9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplPCODMeFwdEEA2qdoXNfa2yWX9SK5ZseWddi)SObBnfhc2rTr(HHc0Owt1krTs5aY0dun45Pzdn4eRLATYSwIjU2dsI1AwQ1kLditpq1GNNMn0GtSwIuRSeATu(SKYdq8zDqs8DpI2JE9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwsuRiZbq(5koeSJAJ8ddfayWhm9A7j1krTYw7pqTsuRmvYugRTNuRiDaq4P4qWoQnIeaA3xfStqTuwlL1szT)a1krThKeR9hOwPCaz6bQg880SHgCI1s5ZcaNIaACW0Fw9CiyhR9hJeaA3VwBOuCwlxRuoGm9aRLjtq)QnB1kacZRLg8Q9d)pg1coXA5ABd(QfNhKKpy612HbQQT3oS2jKuuRrKsHaiqTbsYqFQrjnqXHa1IsAe4CctVwGeN165v7xgeu7hog12YOwJibG29RfaeR9YAVoSwAWyE9R15dmWAZwTxhwRaiuplPCODMeFw48GK8HaA2qlYCaKF(7EeTN(69zHotpqGhHFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKYbKPhOcNhKKpeqZgArMdG8ZFwIaEya5NLiDaq4P4qWoQnIeaA3xHotpqGNLuo0otIpRdsIAq)GdnB8Uhr7XVEFwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplrMdG8ZvCiyh1g5hgQajzOpFwIaEya5N1pRvKoai8uCiyh1grcaT7RqNPhiWZskhANjXN1bjrnOFWHMnE3JO9GxVpl0z6bc8i8ZknEwKSKplwCW0Fws5aY0d8zjLdTZK4Z6GKOg0p4qZgplrapmG8ZsIAfzoaYpxDjOOtNn91HAs2gQcKKH(S2FGALYbKPhO6GKOg0p4qZg1szT)wRCL5ZcaNIaACW0FwYH4)XOwaCW9RTN)XAbnQ9YALRmNOO2wg12BE9WNLuEaIplrMdG8Zvxck60ztFDOMKTHQajzOpF3JOYkZxVpl0z6bc8i8ZknEwKSKplwCW0Fws5aY0d8zjLdTZK4Z6GKOg0p4qZgplrapmG8ZsKoai8uCiyh1grcaT7RqNPhiqTMQvKoai8uCiyh1grcaT7Rc2jO2FRLqR1uTOCgeAyGaQzcog4Dq3whG09R1uTIuk6SFkc6hq2R1uTbOJTmSrfhc2rn0BqhE9vOZ0de4zbGtranoy6pllOlWALdaP7xlCw7eu0vlxRr(HrdCu7fqNa8QTLrTYjVFaz38A)W)JrTZdkiO2lR96WAVVSwsOdEyTI(IbwlOFWrTFyT24vlxBh0URw0tq7UAd2jO2SvRrKaq7(plP8aeFwImha5NRMj4yG3bDBDas3xfijd957EevwzF9(SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwImha5NRUeu0PZM(6qnjBdvbYa9R1uTs5aY0duDqsud6hCOzJA)Tw5kZNfaofb04GP)SKdX)JrTa4G7xBV51dRf0O2lRvUYCIIABzuBp)JplPCODMeFwD5aa626lpY39iQSY917ZcDMEGapc)SsJN1eVNfloy6plPCaz6b(SKYdq8zjrTgbkvBlauYQcgaY(PNgCqqTetCTgbkvBlauYvfmaK9tpn4GGAjM4AncuQ2waOKrvWaq2p90GdcQLYAnvlasd2AQGbGSF6PbheOLcoCmyA4aE9va5N)SaWPiGghm9NLCadaz)Q1YGdcQfiXzTEE1cjjraiF4OFTgGxTGg1EDyTsbhogmnCaV(1cG0GTwTZSw4vRG9APXAbGTguaoUAVSwa4uGHx71XxTF4)aRLVAVoSwkayKxxTsbhogmnCaV(1opwqWZskhANjXN1pi480Gteqpn4GG39iQSY4R3Nf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZIgS1uCiyh1g5hgkG8ZR1uT0GTMkaDuNnTr(HHci)8Anvlasd2AQlbfD6SPVoutY2qfq(51AQ2FwRuoGm9av)GGZtdora90GdcQ1uTainyRPcgaY(PNgCqGwk4WXGPHd41xbKF(ZskhANjXNvcEtiaQZMwK5ai)857Eevwk4R3Nf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZkaDSLHnQ4qWoQHEd6WRVcDMEGa1AQwjQvIAfPu0z)ue0pGSxRPAfzoaYpxfmaK9tpn4GavGKm0N1(BTs5aY0du1Xbz691ZJfeOpijwlL1s5ZskhANjXN18ybb6ooitV)7E3ZQbDEOPbd)17JOY(69zHotpqGhHFwS4GP)S4qWoQjHZjCGZNLOJH(Zs2NLiGhgq(zrd2AkXa5qWZd62QazX9UhrL7R3Nfloy6ploeSJA6bpVNf6m9abEe(DpIkJVEFwS4GP)S4qWoQP5iyB8zHotpqGhHF37E3Zskgty6pIkxzkxzLjHkxz8z9XHdD75ZsoSNLdi6pKOuajd1wBVDyTqsJmUABzu7)ooitV))AduodcdeO2zsI1YGxsYhcuROJDBCQk5PqOJ1kRmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqwjPuvYtHqhRLckd1siPlfJdbQ9)fqNa8umTqjYCaKF()AVS2)Imha5NRyAX)ALqwjPuvYtHqhRLqLHAjK0LIXHa1()cOtaEkMwOezoaYp)FTxw7FrMdG8ZvmT4FTsiRKuQk5PqOJ1kRSYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)RvczLKsvjFjVCyplhq0FirPasgQT2E7WAHKgzC12YO2)n4Sd6260aDm(xBGYzqyGa1otsSwg8ss(qGAfDSBJtvjpfcDSwzLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsixjPuvYtHqhRvUYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)RvczLKsvjpfcDSwzugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowlfugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowlHkd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRThjd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)A5Rwkq5euyTsiRKuQk5PqOJ12dKHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ12dKHAjK0LIXHa1(xKoai8uM5FTxw7Fr6aGWtzgf6m9ab(xlF1sbkNGcRvczLKsvjpfcDSwzLRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)Rvc5kjLQsEke6yTYkJYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKRKuQk5PqOJ1kBpsgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRCLvgQLqsxkghcu7)JhOFkZ8V2lR9)Xd0pLzuOZ0de4FTsiRKuQk5PqOJ1kxkOmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)Rvc5kjLQsEke6yTYLckd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)A5Rwkq5euyTsiRKuQk5PqOJ1k3EKmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RLVAPaLtqH1kHSssPQKNcHowRC7PYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)RvczLKsvjFjVCyplhq0FirPasgQT2E7WAHKgzC12YO2)rE8bt)FTbkNbHbcu7mjXAzWlj5dbQv0XUnovL8ui0XALvgQLqsxkghcu7)JhOFkZ8V2lR9)Xd0pLzuOZ0de4FTsiRKuQk5PqOJ1kxzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQsEke6yTuqzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHSssPQKNcHowlHkd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKvskvL8ui0XA7bYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)RvczLKsvjpfcDSwz7XYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)RvczLKsvjpfcDSwz7XYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALThid1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKvskvL8ui0XALThid1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRvUYugQLqsxkghcu7)JhOFkZ8V2lR9)Xd0pLzuOZ0de4FTsiRKuQk5PqOJ1kxzLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ1kx5kd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYxYlh2ZYbe9hsukGKHART3oSwiPrgxTTmQ9FAGog)Rnq5mimqGANjjwldEjjFiqTIo2TXPQKNcHowRSYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RvczLKsvjpfcDSwzLRmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqwjPuvYtHqhRvwcvgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1YxTuGYjOWALqwjPuvYtHqhRv2EKmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RLVAPaLtqH1kHSssPQKNcHowRS9uzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHSssPQKVKxoSNLdi6pKOuajd1wBVDyTqsJmUABzu7FaSXGJ7FTbkNbHbcu7mjXAzWlj5dbQv0XUnovL8ui0XALRmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqUssPQKNcHowlfugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRSuqzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQsEke6yTY2JKHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ1kBpwgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRS9azOw5uFcAyKXHa1YIdMET)D8RLGoGoWzoKI)vL8ui0XALRCLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FT8vlfOCckSwjKvskvL8ui0XALRmkd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRvUuqzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQsEke6yTYLqLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ1k3EKmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RvczLKsvjpfcDSw52tLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5l5Ld7z5aI(djkfqYqT12BhwlK0iJR2wg1(3iqrssZ3)AduodcdeO2zsI1YGxsYhcuROJDBCQk5PqOJ1sOYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XAjuzOwcjDPyCiqT)fPdacpLz(x7L1(xKoai8uMrHotpqG)1kHSssPQKNcHowRSeQmulHKUumoeO2)I0baHNYm)R9YA)lshaeEkZOqNPhiW)A5Rwkq5euyTsiRKuQk5PqOJ1kBpwgQLqsxkghcu7Fr6aGWtzM)1EzT)fPdacpLzuOZ0de4FTsiRKuQk5PqOJ1kBpqgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRS9azOwcjDPyCiqT)fPdacpLz(x7L1(xKoai8uMrHotpqG)1kHSssPQKNcHowRCLPmulHKUumoeO2)I0baHNYm)R9YA)lshaeEkZOqNPhiW)ALqwjPuvYtHqhRvU9uzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHCLKsvjpfcDSw52tLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ1kJYugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1YxTuGYjOWALqwjPuvYtHqhRvgLvgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRmkxzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQs(sE5WEwoGO)qIsbKmuBT92H1cjnY4QTLrT)fzoaYpF(V2aLZGWabQDMKyTm4LK8Ha1k6y3gNQsEke6yTYkd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKRKuQk5PqOJ1kRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RvczLKsvjpfcDSw5kd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKRKuQk5PqOJ1kxzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQsEke6yTYOmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqUssPQKNcHowRmkd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRLckd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRThjd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKRKuQk5PqOJ12JLHAjK0LIXHa1()4b6NYm)R9YA)F8a9tzgf6m9ab(xReYvskvL8ui0XA7bYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)Rvc5kjLQsEke6yTYkRmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqUssPQKNcHowRSYOmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqwjPuvYtHqhRvwkOmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqwjPuvYtHqhRv2ESmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqwjPuvYxYlh2ZYbe9hsukGKHART3oSwiPrgxTTmQ9pN4)AduodcdeO2zsI1YGxsYhcuROJDBCQk5PqOJ1kRmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqUssPQKNcHowRSYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)Rvc5kjLQsEke6yTYOmulHKUumoeO2)hpq)uM5FTxw7)JhOFkZOqNPhiW)ALqUssPQKNcHowRmkd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRLckd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRLqLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ12JKHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ12tLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ12JLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ12dKHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5PqOJ1kRmLHAjK0LIXHa1()4b6NYm)R9YA)F8a9tzgf6m9ab(xReYvskvL8ui0XALvwzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHCLKsvjpfcDSwzPGYqTes6sX4qGA)F8a9tzM)1EzT)pEG(PmJcDMEGa)Rvc5kjLQsEke6yTY2tLHAjK0LIXHa1()4b6NYm)R9YA)F8a9tzgf6m9ab(xlF1sbkNGcRvczLKsvjpfcDSwz7XYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALThid1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRvUYugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRCLvgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRCLRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)RvczLKsvjpfcDSw5kJYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALlfugQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRCjuzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHSssPQKNcHowRCjuzOwcjDPyCiqT)dqhBzyJkZ8V2lR9Fa6yldBuzgf6m9ab(xReYkjLQsEke6yTYThjd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKvskvL8ui0XALBpsgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHSssPQKNcHowRC7XYqTes6sX4qGA)hGo2YWgvM5FTxw7)a0Xwg2OYmk0z6bc8VwjKvskvL8ui0XALr5kd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKvskvL8ui0XALr5kd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRvgLrzOwcjDPyCiqT)pEG(PmZ)AVS2)hpq)uMrHotpqG)1kHCLKsvjpfcDSwzKckd1siPlfJdbQ9)Xd0pLz(x7L1()4b6NYmk0z6bc8VwjKvskvL8L8YH9SCar)HeLcizO2A7TdRfsAKXvBlJA)l4HaCWhm95)AduodcdeO2zsI1YGxsYhcuROJDBCQk5PqOJ1kRmulHKUumoeO2)bOJTmSrLz(x7L1(paDSLHnQmJcDMEGa)Rvc5kjLQsEke6yTYvgQLqsxkghcu7)a0Xwg2OYm)R9YA)hGo2YWgvMrHotpqG)1kHCLKsvjpfcDSwzugQLqsxkghcuRfKKqQD23pwYALtQAVSwkeKRfakfoHPxBAGbFzuReuKYALqwjPuvYtHqhRLckd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)ALqwjPuvYtHqhRTNkd1siPlfJdbQ9ViDaq4PmZ)AVS2)I0baHNYmk0z6bc8Vw(QLcuobfwReYkjLQsEke6yT9yzOwcjDPyCiqT)fPdacpLz(x7L1(xKoai8uMrHotpqG)1YxTuGYjOWALqwjPuvYtHqhRvwzkd1siPlfJdbQ9)fqNa8umTqjYCaKF()AVS2)Imha5NRyAX)ALqwjPuvYtHqhRvwzkd1siPlfJdbQ9Fa6yldBuzM)1EzT)dqhBzyJkZOqNPhiW)A5Rwkq5euyTsiRKuQk5PqOJ1kRmLHAjK0LIXHa1(xKoai8uM5FTxw7Fr6aGWtzgf6m9ab(xReYkjLQsEke6yTYsbLHAjK0LIXHa1(paDSLHnQmZ)AVS2)bOJTmSrLzuOZ0de4FTsiRKuQk5l5)HKgzCiqTYkZAzXbtV2bCEtvj)ZIbVUmEwwqsWbFW0jKGB3ZYiYgCGpl5OCS2EiBJ12ZHGDSKxokhRvEqhRvU9uZRvUYuUYwYxYlhLJ1kNoXAV(gqbpQ1cssi12XoWa621MTAfDS74OwOFyeGghm9AH(8qgO2Sv7Fb7cCOzXbt)VQKVKNfhm9PYiqrssZhrOsroeSJAOF4yGIRKNfhm9PYiqrssZhrOsroeSJ6gtchqok5zXbtFQmcuKK08reQuuK(piyGAs2zTnswYZIdM(uzeOijP5JiuPOuoGm9an3zsKkkn1gIZ80GAGt8mhaBm44OklHwYZIdM(uzeOijP5JiuPOuoGm9an3zsKQrGgGJHgLMMNguN4zoSrvIa0Xwg2OAcn6sxpVminjHiLIo7Nsk6xx)GyIfPu0z)uokICKbaXelshaeEkoeSJAJibG29PKsZLYdqKQSMlLhGOghtKQml5zXbtFQmcuKK08reQuukhqMEGM7mjsTJLI60aDeW80G6epZHnQS4Gsrn6ijeNMvUMlLhGivznxkparnoMivzwYZIdM(uzeOijP5JiuPOuoGm9an3zsKAd68qtdgU5Pb1jEMlLhGivzwYZIdM(uzeOijP5JiuPOuoGm9an3zsKAhhKP3xppwqG(GKO5Pb1aN4zoa2yWXrThuYZIdM(uzeOijP5JiuPOuoGm9an3zsKAm1KSKAaCW91Tm0xEKMNgudCIN5ayJbhhvcTKNfhm9PYiqrssZhrOsrPCaz6bAUZKi1yQjzj1a4G7RBzOJ0W80GAGt8mhaBm44OsOL8S4GPpvgbkssA(icvkkLditpqZDMePgtnjlPgahCFDldnByEAqnWjEMdGngCCuLRml5zXbtFQmcuKK08reQuukhqMEGM7mjsLmpTrGceb0xEKA6(MNgudCIN5ayJbhh1ECjploy6tLrGIKKMpIqLIs5aY0d0CNjrQK5Pjzj1a4G7RBzOV8inpnOg4epZbWgdooQYkZsEwCW0NkJafjjnFeHkfLYbKPhO5otIujZttYsQbWb3x3YqZgMNgudCIN5ayJbhhvzj0sEwCW0NkJafjjnFeHkfLYbKPhO5otIuzdnjlPgahCFDld9LhP5Pb1aN4zoSrvKoai8uCiyh1grcaT7BUuEaIuLrzAUuEaIACmrQYkZsEwCW0NkJafjjnFeHkfLYbKPhO5otIuzdnjlPgahCFDld9LhP5Pb1aN4zoa2yWXrvwzwYZIdM(uzeOijP5JiuPOuoGm9an3zsKkBOjzj1a4G7RBzOjZZ80GAGt8mhaBm44OkxzwYZIdM(uzeOijP5JiuPOuoGm9an3zsKAKgAswsnao4(6wg6lpsZtdQt8mxkparQYvM)asqO9er6aGWtXHGDuBeja0UpLL8S4GPpvgbkssA(icvkkLditpqZDMePE5rQjzj1a4G7RBzOzdZtdQt8mxkparQekrKRm7jsisPOZ(PCOD3PBmsmXsishaeEkoeSJAJibG29nXIdkf1OJKqC(RmsjLerwcTNiHiLIo7NIG(bKDtbOJTmSrfhc2rn0BqhE9nXIdkf1OJKqCAw5szjploy6tLrGIKKMpIqLIs5aY0d0CNjrQxEKAswsnao4(6wg6inmpnOoXZCP8aePkxz(dirpUNishaeEkoeSJAJibG29PSKNfhm9PYiqrssZhrOsrPCaz6bAUZKivAoc2g1KSZAdXzEAqDIN5WgvrkfD2pLdT7oDJrZLYdqKApsM)asqYZdJ(AP8ae7jYktzszjploy6tLrGIKKMpIqLIs5aY0d0CNjrQ0CeSnQjzN1gIZ80G6epZHnQIuk6SFkc6hq2nxkparQ9ac9hqcsEEy0xlLhGyprwzktkl5zXbtFQmcuKK08reQuukhqMEGM7mjsLMJGTrnj7S2qCMNguN4zoSrvkhqMEGkAoc2g1KSZAdXrvMMlLhGi1ESm)bKGKNhg91s5bi2tKvMYKYsEwCW0NkJafjjnFeHkfLYbKPhO5otIuzdnj0HKGKAs2zTH4mpnOg4epZbWgdooQYsOL8S4GPpvgbkssA(icvkkLditpqZDMePE5rQjzj1IooSXP5Pb1aN4zoa2yWXrvUL8S4GPpvgbkssA(icvkkLditpqZDMePYjQV8i1KSKArhh24080GAGt8mhaBm44Ok3sEwCW0NkJafjjnFeHkfLYbKPhO5otIuBWzh0T1Pb6yyEAqDIN5s5bisv2EIeOCgeAyGakK0OFG8qNbGZUajMyjoEG(Pcqh1ztBKFyysIJhOFkoeSJAu0Let8pfPu0z)ue0pGStPjj(PiLIo7NYrrKJmaiMywCqPOgDKeItQYsmXbOJTmSr1eA0LUEEzqsPPFksPOZ(PKI(11pOKYsEwCW0NkJafjjnFeHkfLYbKPhO5otIuzdD6AWjAEAqDIN5s5bisfLZGqddeqrYcMoq9SdXttcoHcIjgLZGqddeqzpyaiFzm10mGnsmXOCgeAyGak7bda5lJPMeb4XaMoXeJYzqOHbcOa4GaYmDnakiqBaEbofOlqIjgLZGqddeqb9PiapMEGA5mi7hiPgaLcfiXeJYzqOHbcOMj4yG3bDBDas3NyIr5mi0WabutqNEKjGMjXRR)8iMyuodcnmqa1hta6ym1TiDaIjgLZGqddeq1gmjQZMMMVBGL8S4GPpvgbkssA(icvkscJidnKKTXsEwCW0NkJafjjnFeHkfBrop6CCMdBu)PuoGm9avgbAaogAuAsvwtbOJTmSrfaCkGgdOZrFTijjzhOKNfhm9PYiqrssZhrOsroeSJA6bppZHnQ)ukhqMEGkJanahdnknPkRPFgGo2YWgvaWPaAmGoh91IKKKDats8trkfD2pLu0VU(bXelLditpqvdo7GUTonqhdkl5zXbtFQmcuKK08reQuKegrgtD20xgKOFMdBu)PuoGm9avgbAaogAuAsvwt)maDSLHnQaGtb0yaDo6Rfjjj7aMePu0z)usr)66hM(PuoGm9avn4Sd6260aDmk5zXbtFQmcuKK08reQueLMc(GPBoSrvkhqMEGkJanahdnknPkBjFjploy6tIqLIIe0pmMg4yuYZIdM(KiuPi4e1KSZABK0CyJQehpq)uOpG2Dh6iGjs2zLH4(LApwMMizNvgIZSu7rekLetSe)84b6Nc9b0U7qhbmrYoRme3Vu7XekLL8S4GPpjcvkAKhmDZHnQ0GTMIdb7O2i)WqbAuYZIdM(KiuP4bjr9hhgMdBudqhBzyJQdjnYGh6pommrd2AkuYogCEW0vGgMKqK5ai)Cfhc2rTr(HHkqgOpXetNZPPg0U70bsYqF(lvkOmPSKNfhm9jrOsXb0U7M6FqqaBs0pZHnQ0GTMIdb7O2i)WqbKFUjAWwtfGoQZM2i)WqbKFUjaKgS1uxck60ztFDOMKTHkG8Zl5zXbtFseQuKMT1ztFbuqW0CyJknyRP4qWoQnYpmua5NBIgS1ubOJ6SPnYpmua5NBcaPbBn1LGIoD20xhQjzBOci)8sEwCW0NeHkfPXyIbbq32CyJknyRP4qWoQnYpmuGgL8S4GPpjcvkspYeq3aJ(MdBuPbBnfhc2rTr(HHc0OKNfhm9jrOsXgmq6rMaMdBuPbBnfhc2rTr(HHc0OKNfhm9jrOsr2f48cEOf8yyoSrLgS1uCiyh1g5hgkqJsEwCW0NeHkfbNOgEi50CyJknyRP4qWoQnYpmuGgL8S4GPpjcvkcorn8qsZXwdfN2zsKQ9GbG8LXutZa2O5WgvAWwtXHGDuBKFyOaniMyrMdG8ZvCiyh1g5hgQajzOpnlvcLqnbG0GTM6sqrNoB6Rd1KSnubAuYZIdM(KiuPi4e1Wdjn3zsKksA0pqEOZaWzxGMdBufzoaYpxXHGDuBKFyOcKKH(8xQsiRmsKEAprkhqMEGk2qNUgCIuAsK5ai)C1LGIoD20xhQjzBOkqsg6ZFPkHSYir6P9ePCaz6bQydD6AWjszjploy6tIqLIGtudpK0CNjrQabYanyGAP4CIdZHnQImha5NR4qWoQnYpmubsYqFAwQYvMet8pLYbKPhOIn0PRbNivzjMyjoijsvMMKYbKPhOQbNDq3wNgOJbvznfGo2YWgvtOrx665LbjLL8S4GPpjcvkcorn8qsZDMePotWHgA7WddZHnQImha5NR4qWoQnYpmubsYqFAwQYOmjM4FkLditpqfBOtxdorQYwYZIdM(KiuPi4e1Wdjn3zsKQ9OVrNoBAEoHKWbFW0nh2OkYCaKFUIdb7O2i)Wqfijd9PzPkxzsmX)ukhqMEGk2qNUgCIuLLyIL4GKivzAskhqMEGQgC2bDBDAGoguL1ua6yldBunHgDPRNxgKuwYZIdM(KiuPi4e1Wdjn3zsKkjly6a1Zoepnj4ekmh2OkYCaKFUIdb7O2i)Wqfijd95Vujuts8tPCaz6bQAWzh0T1Pb6yqvwIj(GKOzLrzszjploy6tIqLIGtudpK0CNjrQKSGPdup7q80KGtOWCyJQiZbq(5koeSJAJ8ddvGKm0N)sLqnjLditpqvdo7GUTonqhdQYAIgS1ubOJ6SPnYpmuGgMObBnva6OoBAJ8ddvGKm0N)svczL5paH2tcqhBzyJQj0OlD98YGKsthKe)vgLzjploy6tIqLIo(1sqhqh4mhsrZbNO(RdoqTGNh0TPkR5WgvAWwtXHGDuBKFyOaniMyaKgS1uxck60ztFDOMKTHkqdIjgipvWaq2p90Gdcuhuqa0Tl5zXbtFseQuuWJHMfhmD9aopZDMePk4HaCWhm9zjploy6tIqLIcEm0S4GPRhW5zUZKivorZNxafhvznh2OYIdkf1OJKqCAw5wYZIdM(KiuPOGhdnloy66bCEM7mjsTJdY07BoSrvKsrN9trq)aYUPa0Xwg2OIdb7Og6nOdV(L8S4GPpjcvkk4XqZIdMUEaNN5otIuBWzh0T1Pb6yyoSrvkhqMEGQowkQtd0raQY0KuoGm9avn4Sd6260aDmm9tjePu0z)ue0pGSBkaDSLHnQ4qWoQHEd6WRpLL8S4GPpjcvkk4XqZIdMUEaNN5otIutd0XWCyJQuoGm9avDSuuNgOJauLPPFkHiLIo7NIG(bKDtbOJTmSrfhc2rn0BqhE9PSKNfhm9jrOsrbpgAwCW01d48m3zsKQiZbq(5tZHnQ)ucrkfD2pfb9di7McqhBzyJkoeSJAO3Go86tzjploy6tIqLIcEm0S4GPRhW5zUZKi1ip(GPBoSrvkhqMEGQg05HMgmCQY00pLqKsrN9trq)aYUPa0Xwg2OIdb7Og6nOdV(uwYZIdM(KiuPOGhdnloy66bCEM7mjsTbDEOPbd3CyJQuoGm9avnOZdnny4uL10pLqKsrN9trq)aYUPa0Xwg2OIdb7Og6nOdV(uwYxYZIdM(uXjsTf58OZXzoSrnaDSLHnQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0TiNNci)Ctsqd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddfq(5MaqAWwtDjOOtNn91HAs2gQaYpNstImha5NRUeu0PZM(6qnjBdvbsYqFsvMMKGgS1uCiyh1IooSr18ybb)svkhqMEGkor9LhPMKLul64WgNMKqIJhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd95VuTfaMezoaYpxXHGDuBKFyOcKKH(0Ss5aY0duD5rQjzj1a4G7RBzOzdkjMyj(5Xd0pva6OoBAJ8ddtImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSKAaCW91Tm0SbLetSiZbq(5koeSJAJ8ddvGKm0N)s1waqjLL8S4GPpvCIeHkfBWa10dEEMdBuLiaDSLHnQaGtb0yaDo6Rfjjj7aMezoaYpxrd2AAa4uangqNJ(ArssYoGkqgOVjAWwtbaNcOXa6C0xlsss2b0nyGkG8ZnzeOuTTaqjRQf58OZXrjXelra6yldBubaNcOXa6C0xlsss2bmDqs8xzPSKNfhm9PItKiuPylY5P9ukBoSrnaDSLHnQSd4C0xdfqXanjYCaKFUIdb7O2i)Wqfijd9PzLrzAsK5ai)C1LGIoD20xhQjzBOkqsg6tQY0Ke0GTMIdb7Ow0XHnQMhli4xQs5aY0duXjQV8i1KSKArhh240KesC8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LQTaWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlPgahCFDldnBqjXelXppEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHMnOKyIfzoaYpxXHGDuBKFyOcKKH(8xQ2cakPSKNfhm9PItKiuPylY5P9ukBoSrnaDSLHnQSd4C0xdfqXanjYCaKFUIdb7O2i)Wqfijd9jvzAscjKqK5ai)C1LGIoD20xhQjzBOkqsg6tZkLditpqfBOjzj1a4G7RBzOV8inrd2AkoeSJArhh2OAESGaQ0GTMIdb7Ow0XHnQizj1ZJfeqjXelHiZbq(5QlbfD6SPVoutY2qvGKm0NuLPjAWwtXHGDul64WgvZJfe8lvPCaz6bQ4e1xEKAswsTOJdBCsjLMObBnva6OoBAJ8ddfq(5uwYZIdM(uXjseQuKdb7OMeoNWbonh2OksPOZ(PiOFaz3ua6yldBuXHGDud9g0HxFt0GTMIdb7OUJdY07RMhli4xzjutImha5NRcgaY(PNgCqGkqsg6ZFPkLditpqvhhKP3xppwqG(GKirqjrb4H6dsIMezoaYpxDjOOtNn91HAs2gQcKKH(8xQs5aY0du1Xbz691ZJfeOpijseusuaEO(GKiryXbtxfmaK9tpn4GafkjkapuFqs0KiZbq(5koeSJAJ8ddvGKm0N)svkhqMEGQooitVVEESGa9bjrIGsIcWd1hKejcloy6QGbGSF6PbheOqjrb4H6dsIeHfhmD1LGIoD20xhQjzBOcLefGhQpijAUOJHovzl5zXbtFQ4ejcvkEjOOtNn91HAs2gAoSrnaDSLHnQMqJU01ZldstgbkvBlauYQqPPGpy6L8S4GPpvCIeHkf5qWoQnYpmmh2OgGo2YWgvtOrx665LbPjjmcuQ2waOKvHstbFW0jMyJaLQTfakzvxck60ztFDOMKTHuwYZIdM(uXjseQueLMc(GPBoSr9GKOzLrzAkaDSLHnQMqJU01Zldst0GTMIdb7Ow0XHnQMhli4xQs5aY0duXjQV8i1KSKArhh240KiZbq(5QlbfD6SPVoutY2qvGKm0NuLPjrMdG8ZvCiyh1g5hgQajzOp)LQTaOKNfhm9PItKiuPiknf8bt3CyJ6bjrZkJY0ua6yldBunHgDPRNxgKMezoaYpxXHGDuBKFyOcKKH(KQmnjHesiYCaKFU6sqrNoB6Rd1KSnufijd9PzLYbKPhOIn0KSKAaCW91Tm0xEKMObBnfhc2rTOJdBunpwqavAWwtXHGDul64WgvKSK65XccOKyILqK5ai)C1LGIoD20xhQjzBOkqsg6tQY0enyRP4qWoQfDCyJQ5Xcc(LQuoGm9avCI6lpsnjlPw0XHnoPKst0GTMkaDuNnTr(HHci)Cknh6hgbOXPHnQ0GTMAcn6sxpVmivZJfeqLgS1utOrx665LbPIKLuppwqG5q)WianonKKebG8HuLTKNfhm9PItKiuPijmImM6SPVmir)mh2OkHiZbq(5koeSJAJ8ddvGKm0NMLcsOetSiZbq(5koeSJAJ8ddvGKm0N)svgP0KiZbq(5QlbfD6SPVoutY2qvGKm0NuLPjjObBnfhc2rTOJdBunpwqWVuLYbKPhOItuF5rQjzj1IooSXPjjK44b6NkaDuNnTr(HHjrMdG8ZvbOJ6SPnYpmubsYqF(lvBbGjrMdG8ZvCiyh1g5hgQajzOpnlHsjXelXppEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6tZsOusmXImha5NR4qWoQnYpmubsYqF(lvBbaLuwYZIdM(uXjseQumyai7NEAWbbMdBufzoaYpxDjOOtNn91HAs2gQcKKH(8xusuaEO(GKOjjK44b6NkaDuNnTr(HHjrMdG8ZvbOJ6SPnYpmubsYqF(lvBbGjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswsnao4(6wgA2GsIjwIFE8a9tfGoQZM2i)WWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlPgahCFDldnBqjXelYCaKFUIdb7O2i)Wqfijd95VuTfauwYZIdM(uXjseQumyai7NEAWbbMdBufzoaYpxXHGDuBKFyOcKKH(8xusuaEO(GKOjjKqcrMdG8Zvxck60ztFDOMKTHQajzOpnRuoGm9avSHMKLudGdUVULH(YJ0enyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqaLetSeImha5NRUeu0PZM(6qnjBdvbsYqFsvMMObBnfhc2rTOJdBunpwqWVuLYbKPhOItuF5rQjzj1IooSXjLuAIgS1ubOJ6SPnYpmua5Ntzjploy6tfNirOsraKVo6mC0CyJQiZbq(5koeSJAJ8ddvGKm0NuLPjjKqcrMdG8Zvxck60ztFDOMKTHQajzOpnRuoGm9avSHMKLudGdUVULH(YJ0enyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqaLetSeImha5NRUeu0PZM(6qnjBdvbsYqFsvMMObBnfhc2rTOJdBunpwqWVuLYbKPhOItuF5rQjzj1IooSXjLuAIgS1ubOJ6SPnYpmua5Ntzjploy6tfNirOsXlbfD6SPVoutY2qZHnQsqd2AkoeSJArhh2OAESGGFPkLditpqfNO(YJutYsQfDCyJtIj2iqPABbGswvWaq2p90GdcO0KesC8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LQTaWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlPgahCFDldnBqjXelXppEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHMnOKyIfzoaYpxXHGDuBKFyOcKKH(8xQ2cakl5zXbtFQ4ejcvkYHGDuBKFyyoSrvcjezoaYpxDjOOtNn91HAs2gQcKKH(0Ss5aY0duXgAswsnao4(6wg6lpst0GTMIdb7Ow0XHnQMhliGknyRP4qWoQfDCyJksws98ybbusmXsiYCaKFU6sqrNoB6Rd1KSnufijd9jvzAIgS1uCiyh1IooSr18ybb)svkhqMEGkor9LhPMKLul64WgNusPjAWwtfGoQZM2i)WqbKFEjploy6tfNirOsXa0rD20g5hgMdBuPbBnva6OoBAJ8ddfq(5MKqcrMdG8Zvxck60ztFDOMKTHQajzOpnRCLPjAWwtXHGDul64WgvZJfeqLgS1uCiyh1IooSrfjlPEESGakjMyjezoaYpxDjOOtNn91HAs2gQcKKH(KQmnrd2AkoeSJArhh2OAESGGFPkLditpqfNO(YJutYsQfDCyJtkP0KeImha5NR4qWoQnYpmubsYqFAwzLlXedG0GTM6sqrNoB6Rd1KSnubAqzjploy6tfNirOsXzhSDq3wBKFyyoSrvK5ai)Cfhc2rDg0QajzOpnlHsmX)84b6NIdb7Ood6sEwCW0NkorIqLICiyh10dEEMdBufPu0z)ue0pGSBkaDSLHnQ4qWoQHEd6WRVjAWwtXHGDuBKFyOanmbG0GTMkyai7NEAWbbAPGdhdMgoGxF18ybbuPGMmcuQ2waOKvXHGDuNbTjwCqPOgDKeIZF7PL8S4GPpvCIeHkf5qWoQP5iyB0CyJQiLIo7NIG(bKDtbOJTmSrfhc2rn0BqhE9nrd2AkoeSJAJ8ddfOHjaKgS1ubdaz)0tdoiqlfC4yW0Wb86RMhliGkfSKNfhm9PItKiuPihc2rn9GNN5WgvrkfD2pfb9di7McqhBzyJkoeSJAO3Go86BIgS1uCiyh1g5hgkqdtsaKNkyai7NEAWbbQajzOpnBpIyIbqAWwtfmaK9tpn4GaTuWHJbtdhWRVc0GstainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqWVuqtS4Gsrn6ijeNuLXsEwCW0NkorIqLICiyh1zqBoSrvKsrN9trq)aYUPa0Xwg2OIdb7Og6nOdV(MObBnfhc2rTr(HHc0Weasd2AQGbGSF6PbheOLcoCmyA4aE9vZJfeqvgl5zXbtFQ4ejcvkYHGDutZrW2O5WgvrkfD2pfb9di7McqhBzyJkoeSJAO3Go86BIgS1uCiyh1g5hgkqdtainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqav5wYZIdM(uXjseQuKdb7OgL0yKty6MdBufPu0z)ue0pGSBkaDSLHnQ4qWoQHEd6WRVjAWwtXHGDuBKFyOanmzeOuTTaqjxvWaq2p90GdcmXIdkf1OJKqCAwzSKNfhm9PItKiuPihc2rnkPXiNW0nh2OksPOZ(PiOFaz3ua6yldBuXHGDud9g0HxFt0GTMIdb7O2i)WqbAycaPbBnvWaq2p90Gdc0sbhogmnCaV(Q5XccOkRjwCqPOgDKeItZkJL8S4GPpvCIeHkfncCIUa1zttcDaZHnQ0GTMca5RJodhvGgMaqAWwtDjOOtNn91HAs2gQanmbG0GTM6sqrNoB6Rd1KSnufijd95VuPbBnLrGt0fOoBAsOdOizj1ZJfe0tyXbtxXHGDutp45Pqjrb4H6dsIMKqIJhOFQaNPZUanXIdkf1OJKqC(lfKsIjMfhukQrhjH48xcLsts8Za0Xwg2OIdb7OMojP5aGe9JyIpoSXt1H846ugIZSYiHszjploy6tfNirOsroeSJA6bppZHnQ0GTMca5RJodhvGgMKqIJhOFQaNPZUanXIdkf1OJKqC(lfKsIjMfhukQrhjH48xcLsts8Za0Xwg2OIdb7OMojP5aGe9JyIpoSXt1H846ugIZSYiHszjploy6tfNirOsXjObgEkLl5zXbtFQ4ejcvkYHGDutZrW2O5WgvAWwtXHGDul64WgvZJfeywQsWIdkf1OJKqC(dilLMcqhBzyJkoeSJA6KKMdas0pthh24P6qECDkdX9RmsOL8S4GPpvCIeHkf5qWoQP5iyB0CyJknyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqqjploy6tfNirOsroeSJ6mOnh2Osd2AkoeSJArhh2OAESGaQYSKNfhm9PItKiuPOJxhg6djnW5zoSrvIaBbo7y6bsmX)8GccGUnLMObBnfhc2rTOJdBunpwqavAWwtXHGDul64WgvKSK65Xcck5zXbtFQ4ejcvkYHGDutcNt4aNMdBuPbBnLyGCi45bDBvGS4mfGo2YWgvCiyh1qVbD413KesC8a9tXKgdydk4dMUjwCqPOgDKeIZF7XusmXS4Gsrn6ijeN)sOuwYZIdM(uXjseQuKdb7OMeoNWbonh2Osd2AkXa5qWZd62QazXz64b6NIdb7OgfDPjaKgS1uxck60ztFDOMKTHkqdtsC8a9tXKgdydk4dMoXeZIdkf1OJKqC(BpGYsEwCW0NkorIqLICiyh1KW5eoWP5WgvAWwtjgihcEEq3wfilothpq)umPXa2Gc(GPBIfhukQrhjH48xkyjploy6tfNirOsroeSJAusJroHPBoSrLgS1uCiyh1IooSr18ybb)sd2AkoeSJArhh2OIKLuppwqqjploy6tfNirOsroeSJAusJroHPBoSrLgS1uCiyh1IooSr18ybbuPbBnfhc2rTOJdBurYsQNhliWKrGs12caLSkoeSJAAoc2gl5zXbtFQ4ejcvkIstbFW0nh6hgbOXPHnQKSZkdXzwQ9ac1COFyeGgNgssIaq(qQYwYxYZIdM(uj4HaCWhm9jvPCaz6bAUZKi1owkQtd0raZtdQt8mxkparQYAoSrvkhqMEGQowkQtd0raQY0KrGs12caLSkuAk4dMUPFkra6yldBunHgDPRNxgKetCa6yldBuDiPrg8q)XHbLL8S4GPpvcEiah8btFseQuukhqMEGM7mjsTJLI60aDeW80G6epZLYdqKQSMdBuLYbKPhOQJLI60aDeGQmnrd2AkoeSJAJ8ddfq(5MezoaYpxXHGDuBKFyOcKKH(0KebOJTmSr1eA0LUEEzqsmXbOJTmSr1HKgzWd9hhguwYZIdM(uj4HaCWhm9jrOsrPCaz6bAUZKi1g05HMgmCZtdQt8mxkparQYAoSrLgS1uCiyh1IooSr18ybbuPbBnfhc2rTOJdBurYsQNhliW0pPbBnvaoqD20xxG4ubAyQbT7oDGKm0N)svcjizNLtkwCW0vCiyh10dEEkropk7jS4GPR4qWoQPh88uOKOa8q9bjrkl5LJ1sbcVomQLRTbog9RDESGaeO2ooitVFTzul0RfLefGhwBWUnw7h86QLWjjnhaKOFL8S4GPpvcEiah8btFseQuukhqMEGM7mjsfjnYpmqannhbBJMNguN4zUuEaIuPbBnfhc2rDhhKP3xnpwqavAWwtXHGDu3Xbz69vKSK65XcciMyjcqhBzyJkoeSJA6KKMdas0pthh24P6qECDkdX9RmsOuwYZIdM(uj4HaCWhm9jrOsrPCaz6bAUZKi1bppnBObNO5ayJbhhvzAEAqDIN5WgvAWwtXHGDuBKFyOanmjHuoGm9avdEEA2qdorQYKyIpijAwQs5aY0dun45Pzdn4ejISekLMlLhGi1dsIL8YXA75qWow7pgja0UFT2qP4SwUwPCaz6bwltMG(vB2QvaeMxln4v7h(FmQfCI1Y12g8vlopijFW0RTdduvBVDyTtiPOwJiLcbqGAdKKH(uJsAGIdbQfL0iW5eMETajoR1ZR2VmiO2pCmQTLrTgrcaT7xlaiw7L1EDyT0GX86xRZhyG1MTAVoSwbqOk5zXbtFQe8qao4dM(KiuPOuoGm9an3zsKkopijFiGMn0Imha5NBEAqDIN5s5bisvcrMdG8ZvCiyh1g5hgkaWGpy69ejK9hqczQKPm2tePdacpfhc2rTrKaq7(QGDcOKsk)bK4GK4pGuoGm9avdEEA2qdorkl5zXbtFQe8qao4dM(KiuPOuoGm9an3zsK6bjrnOFWHMnmpnOoXZCyJQiDaq4P4qWoQnIeaA33CP8aePkLditpqfopijFiGMn0Imha5NxYZIdM(uj4HaCWhm9jrOsrPCaz6bAUZKi1dsIAq)GdnByEAqDIN5Wg1FkshaeEkoeSJAJibG29nxkparQImha5NR4qWoQnYpmubsYqFwYlhRvoe)pg1cGdUFT98pwlOrTxwRCL5ef12YO2EZRhwYZIdM(uj4HaCWhm9jrOsrPCaz6bAUZKi1dsIAq)GdnByEAqLKL0CP8aePkYCaKFU6sqrNoB6Rd1KSnufijd9P5WgvjezoaYpxDjOOtNn91HAs2gQcKKH(8hqkhqMEGQdsIAq)GdnBq5VYvML8YXATGUaRvoaKUFTWzTtqrxTCTg5hgnWrTxaDcWR2wg1kN8(bKDZR9d)pg1opOGGAVS2RdR9(YAjHo4H1k6lgyTG(bh1(H1AJxTCTDq7UArpbT7QnyNGAZwTgrcaT7xYZIdM(uj4HaCWhm9jrOsrPCaz6bAUZKi1dsIAq)GdnByEAqLKL0CP8aePEb0jap1mbhd8oOBRdq6(krMdG8ZvbsYqFAoSrvKoai8uCiyh1grcaT7BsKoai8uCiyh1grcaT7Rc2j4xc1ekNbHggiGAMGJbEh0T1biDFtIuk6SFkc6hq2nfGo2YWgvCiyh1qVbD41VKxowRCi(FmQfahC)A7nVEyTGg1EzTYvMtuuBlJA75FSKNfhm9PsWdb4Gpy6tIqLIs5aY0d0CNjrQD5aa626lpsZtdQt8mxkparQImha5NRUeu0PZM(6qnjBdvbYa9njLditpq1bjrnOFWHMn(vUYSKxowRCadaz)Q1YGdcQfiXzTEE1cjjraiF4OFTgGxTGg1EDyTsbhogmnCaV(1cG0GTwTZSw4vRG9APXAbGTguaoUAVSwa4uGHx71XxTF4)aRLVAVoSwkayKxxTsbhogmnCaV(1opwqqjploy6tLGhcWbFW0NeHkfLYbKPhO5otIu)bbNNgCIa6PbheyEAqDIN5s5bisvcJaLQTfakzvbdaz)0tdoiGyIncuQ2waOKRkyai7NEAWbbetSrGs12caLmQcgaY(PNgCqaLMaqAWwtfmaK9tpn4GaTuWHJbtdhWRVci)8sEwCW0NkbpeGd(GPpjcvkkLditpqZDMePMG3ecG6SPfzoaYpFAEAqDIN5s5bisLgS1uCiyh1g5hgkG8Znrd2AQa0rD20g5hgkG8ZnbG0GTM6sqrNoB6Rd1KSnubKFUPFkLditpq1pi480Gteqpn4GatainyRPcgaY(PNgCqGwk4WXGPHd41xbKFEjploy6tLGhcWbFW0NeHkfLYbKPhO5otIuNhliq3Xbz69npnOoXZCP8aePgGo2YWgvCiyh1qVbD413KesisPOZ(PiOFaz3KiZbq(5QGbGSF6PbheOcKKH(8xPCaz6bQ64Gm9(65Xcc0hKePKYs(sE5yT)yaZaEqkayTGtOBxRDaNJ(1cfqXaR9dED1YgQALtNyTWR2p41v7LhzT51HXhCIQsEwCW0NkrMdG8ZNuBropTNszZHnQbOJTmSrLDaNJ(AOakgOjrMdG8ZvCiyh1g5hgQajzOpnRmkttImha5NRUeu0PZM(6qnjBdvbYa9njbnyRP4qWoQfDCyJQ5Xcc(LQuoGm9avxEKAswsTOJdBCAscjoEG(Pcqh1ztBKFyysK5ai)Cva6OoBAJ8ddvGKm0N)s1waysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHMnOKyIL4Nhpq)ubOJ6SPnYpmmjYCaKFUIdb7O2i)Wqfijd9PzLYbKPhO6YJutYsQbWb3x3YqZgusmXImha5NR4qWoQnYpmubsYqF(lvBbaLuwYZIdM(ujYCaKF(KiuPylY5P9ukBoSrnaDSLHnQSd4C0xdfqXanjYCaKFUIdb7O2i)Wqfid03Ke)84b6Nc9b0U7qhbiMyjoEG(PqFaT7o0ratKSZkdXzwQ9uzsjLMKqcrMdG8Zvxck60ztFDOMKTHQajzOpnRSY0enyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqaLetSeImha5NRUeu0PZM(6qnjBdvbsYqFsvMMObBnfhc2rTOJdBunpwqavzsjLMObBnva6OoBAJ8ddfq(5MizNvgIZSuLYbKPhOIn0KqhscsQjzN1gIRKNfhm9PsK5ai)8jrOsXwKZJohN5Wg1a0Xwg2OcaofqJb05OVwKKKSdysK5ai)CfnyRPbGtb0yaDo6Rfjjj7aQazG(MObBnfaCkGgdOZrFTijjzhq3ICEkG8ZnjbnyRP4qWoQnYpmua5NBIgS1ubOJ6SPnYpmua5NBcaPbBn1LGIoD20xhQjzBOci)CknjYCaKFU6sqrNoB6Rd1KSnufijd9jvzAscAWwtXHGDul64WgvZJfe8lvPCaz6bQU8i1KSKArhh240KesC8a9tfGoQZM2i)WWKiZbq(5Qa0rD20g5hgQajzOp)LQTaWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlPgahCFDldnBqjXelXppEG(Pcqh1ztBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHMnOKyIfzoaYpxXHGDuBKFyOcKKH(8xQ2cakPSKNfhm9PsK5ai)8jrOsXgmqn9GNN5Wg1a0Xwg2OcaofqJb05OVwKKKSdysK5ai)CfnyRPbGtb0yaDo6Rfjjj7aQazG(MObBnfaCkGgdOZrFTijjzhq3GbQaYp3KrGs12caLSQwKZJohxjVCS2FKHrT9WS3A)GxxT98pwlSvl8(pRvKKq3UwqJANz6QA)HTAHxTFWXOwASwWjcu7h86QT386HMxRGNxTWR25aA3DJ(1sJTmWsEwCW0NkrMdG8ZNeHkfjHrKXuNn9Lbj6N5WgvrMdG8Zvxck60ztFDOMKTHQajzOp)vkhqMEGkY80gbkqeqF5rQP7tmXsiLditpq1bjrnOFWHMnmRuoGm9avK5Pjzj1a4G7RBzOzdtImha5NRUeu0PZM(6qnjBdvbsYqFAwPCaz6bQiZttYsQbWb3x3YqF5rszjploy6tLiZbq(5tIqLIKWiYyQZM(YGe9ZCyJQiZbq(5koeSJAJ8ddvGmqFts8ZJhOFk0hq7UdDeGyIL44b6Nc9b0U7qhbmrYoRmeNzP2tLjLuAscjezoaYpxDjOOtNn91HAs2gQcKKH(0Ss5aY0duXgAswsnao4(6wg6lpst0GTMIdb7Ow0XHnQMhliGknyRP4qWoQfDCyJksws98ybbusmXsiYCaKFU6sqrNoB6Rd1KSnufijd9jvzAIgS1uCiyh1IooSr18ybbuLjLuAIgS1ubOJ6SPnYpmua5NBIKDwzioZsvkhqMEGk2qtcDijiPMKDwBiUsE5yT984J7pRfCI1cG81rNHJ1(bVUAzdvT)WwTxEK1cN1gid0VwEw7hogMxljtaw7emWAVSwbpVAHxT0yldS2lpsvjploy6tLiZbq(5tIqLIaiFD0z4O5WgvrMdG8Zvxck60ztFDOMKTHQazG(MObBnfhc2rTOJdBunpwqWVuLYbKPhO6YJutYsQfDCyJttImha5NR4qWoQnYpmubsYqF(lvBbqjploy6tLiZbq(5tIqLIaiFD0z4O5WgvrMdG8ZvCiyh1g5hgQazG(MK4Nhpq)uOpG2Dh6iaXelXXd0pf6dOD3HocyIKDwzioZsTNktkP0KesiYCaKFU6sqrNoB6Rd1KSnufijd9PzLvMMObBnfhc2rTOJdBunpwqavAWwtXHGDul64WgvKSK65XccOKyILqK5ai)C1LGIoD20xhQjzBOkqgOVjAWwtXHGDul64WgvZJfeqvMusPjAWwtfGoQZM2i)WqbKFUjs2zLH4mlvPCaz6bQydnj0HKGKAs2zTH4k5LJ1kNoXANgCqqTWwTxEK1YoqTSrTCG1METcGAzhO2V0)F1sJ1cAuBlJAhPBJrTxh71EDyTKSK1cGdUV51sYeaD7ANGbw7hwBhlfRLVAhipVAVVSwoeSJ1k64WgN1YoqTxhF1E5rw7hp9)xT)GGZRwWjcOk5zXbtFQezoaYpFseQumyai7NEAWbbMdBufzoaYpxDjOOtNn91HAs2gQcKKH(0Ss5aY0duftnjlPgahCFDld9LhPjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avXutYsQbWb3x3YqZgMK44b6NkaDuNnTr(HHjjezoaYpxfGoQZM2i)Wqfijd95VOKOa8q9bjrIjwK5ai)Cva6OoBAJ8ddvGKm0NMvkhqMEGQyQjzj1a4G7RBzOJ0GsIj(Nhpq)ubOJ6SPnYpmO0enyRP4qWoQfDCyJQ5XccmRCnbG0GTM6sqrNoB6Rd1KSnubKFUjAWwtfGoQZM2i)WqbKFUjAWwtXHGDuBKFyOaYpVKxowRC6eRDAWbb1(bVUAzJA)6qVwJCoH0duv7pSv7LhzTWzTbYa9RLN1(HJH51sYeG1obdS2lRvWZRw4vln2YaR9YJuvYZIdM(ujYCaKF(KiuPyWaq2p90Gdcmh2OkYCaKFU6sqrNoB6Rd1KSnufijd95VOKOa8q9bjrt0GTMIdb7Ow0XHnQMhli4xQs5aY0duD5rQjzj1IooSXPjrMdG8ZvCiyh1g5hgQajzOp)vcusuaEO(GKiryXbtxDjOOtNn91HAs2gQqjrb4H6dsIuwYZIdM(ujYCaKF(KiuPyWaq2p90Gdcmh2OkYCaKFUIdb7O2i)Wqfijd95VOKOa8q9bjrtsiXppEG(PqFaT7o0raIjwIJhOFk0hq7UdDeWej7SYqCMLApvMusPjjKqK5ai)C1LGIoD20xhQjzBOkqsg6tZkLditpqfBOjzj1a4G7RBzOV8inrd2AkoeSJArhh2OAESGaQ0GTMIdb7Ow0XHnQizj1ZJfeqjXelHiZbq(5QlbfD6SPVoutY2qvGKm0NuLPjAWwtXHGDul64WgvZJfeqvMusPjAWwtfGoQZM2i)WqbKFUjs2zLH4mlvPCaz6bQydnj0HKGKAs2zTH4OSKxowRC6eR9YJS2p41vlBulSvl8(pR9dEDqV2RdRLKLSwaCW9v1(dB165zETGtS2p41vBKg1cB1EDyThpq)QfoR9ycq38AzhOw49Fw7h86GETxhwljlzTa4G7Rk5zXbtFQezoaYpFseQu8sqrNoB6Rd1KSn0CyJknyRP4qWoQfDCyJQ5Xcc(LQuoGm9avxEKAswsTOJdBCAsK5ai)Cfhc2rTr(HHkqsg6ZFPIsIcWd1hKenrYoRmeNzLYbKPhOIn0KqhscsQjzN1gIZenyRPcqh1ztBKFyOaYpVKNfhm9PsK5ai)8jrOsXlbfD6SPVoutY2qZHnQ0GTMIdb7Ow0XHnQMhli4xQs5aY0duD5rQjzj1IooSXPPJhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd95Vurjrb4H6dsIMKYbKPhO6GKOg0p4qZgMvkhqMEGQlpsnjlPgahCFDldnBuYZIdM(ujYCaKF(KiuP4LGIoD20xhQjzBO5WgvAWwtXHGDul64WgvZJfe8lvPCaz6bQU8i1KSKArhh240Ke)84b6NkaDuNnTr(HbXelYCaKFUkaDuNnTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHosdknjLditpq1bjrnOFWHMnmRuoGm9avxEKAswsnao4(6wgA2OKxowRC6eRLnQf2Q9YJSw4S20Rvaul7a1(L()RwASwqJABzu7iDBmQ96yV2RdRLKLSwaCW9nVwsMaOBx7emWAVo(Q9dRTJLI1IEcA3vlj7CTSdu71XxTxhgyTWzTEE1YJazG(1Y1gGowB2Q1i)WOwG8ZvL8S4GPpvImha5NpjcvkYHGDuBKFyyoSrvK5ai)C1LGIoD20xhQjzBOkqsg6tZkLditpqfBOjzj1a4G7RBzOV8injXpfPu0z)usr)66hetSiZbq(5ksyezm1ztFzqI(PcKKH(0Ss5aY0duXgAswsnao4(6wgAY8O0enyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqGjAWwtfGoQZM2i)WqbKFUjs2zLH4mlvPCaz6bQydnj0HKGKAs2zTH4k5LJ1kNoXAJ0OwyR2lpYAHZAtVwbqTSdu7x6)VAPXAbnQTLrTJ0TXO2RJ9AVoSwswYAbWb338AjzcGUDTtWaR96WaRfo9)xT8iqgOFTCTbOJ1cKFETSdu71XxTSrTFP))QLgfjjwllLHdMEG1cagq3U2a0rvjploy6tLiZbq(5tIqLIbOJ6SPnYpmmh2Osd2AkoeSJAJ8ddfq(5MKqK5ai)C1LGIoD20xhQjzBOkqsg6tZkLditpqvKgAswsnao4(6wg6lpsIjwK5ai)Cfhc2rTr(HHkqsg6ZFPkLditpq1LhPMKLudGdUVULHMnO0enyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqGjrMdG8ZvCiyh1g5hgQajzOpnRSYTKNfhm9PsK5ai)8jrOsXzhSDq3wBKFyyoSrvkhqMEGQe8MqauNnTiZbq(5ZsE5yTYPtSwJKS2lRDkNbrKcawl71IsEbxltxl0R96WADuYRwrMdG8ZR9d6a5N51c6dCoRLG(bK9AVo0Rn9r)AbadOBxlhc2XAnYpmQfaeR9YA7YVAjzNRTd0TJ(1gmaK9R2PbheulCwYZIdM(ujYCaKF(KiuPOrGt0fOoBAsOdyoSr94b6NkaDuNnTr(HHjAWwtXHGDuBKFyOanmrd2AQa0rD20g5hgQajzOp)1waOizjl5zXbtFQezoaYpFseQu0iWj6cuNnnj0bmh2OcG0GTM6sqrNoB6Rd1KSnubAycaPbBn1LGIoD20xhQjzBOkqsg6ZFzXbtxXHGDutcNt4aNkusuaEO(GKOPFksPOZ(PiOFazVKNfhm9PsK5ai)8jrOsrJaNOlqD20KqhWCyJknyRPcqh1ztBKFyOanmrd2AQa0rD20g5hgQajzOp)1waOizjnjYCaKFUcLMc(GPRcKb6BsK5ai)C1LGIoD20xhQjzBOkqsg6tt)uKsrN9trq)aYEjFjploy6tvd68qtdgorOsroeSJAs4Cch40CyJknyRPedKdbppOBRcKfN5Iog6uLTKNfhm9PQbDEOPbdNiuPihc2rn9GNxjploy6tvd68qtdgorOsroeSJAAoc2gl5l5LJ1kh2HETbO7q3UweEDyu71H1AzvBg12RCyTd0gDaoG408A)WA)y)Q9YAPaLM1sJTmWAVoS2EZRhsXE(hR9d6a5NQw50jwl8QLN1oZ0RLN1khK)yTD8S2g0HZoeO2emQ9d)lfRDAG(vBcg1k64WgNL8S4GPpvn4Sd6260aDmOIstbFW0nh2Okra6yldBuDiPrg8q)XHbXelra6yldBunHgDPRNxgKM(PuoGm9avgbAaogAuAsvwkP0Ke0GTMkaDuNnTr(HHci)CIj2iqPABbGswfhc2rnnhbBJuAsK5ai)Cva6OoBAJ8ddvGKm0NL8YXA)HTA)W)sXABqho7qGAtWOwrMdG8ZR9d6a53Sw2bQDAG(vBcg1k64WgNMxRraZaEqkayTuGsZAtPyulkfJ(xh0TRfhtSKNfhm9PQbNDq3wNgOJbrOsruAk4dMU5Wg1JhOFQa0rD20g5hgMezoaYpxfGoQZM2i)Wqfijd9PjrMdG8ZvCiyh1g5hgQajzOpnrd2AkoeSJAJ8ddfq(5MObBnva6OoBAJ8ddfq(5MmcuQ2waOKvXHGDutZrW2yjploy6tvdo7GUTonqhdIqLInyGA6bppZHnQbOJTmSrfaCkGgdOZrFTijjzhWenyRPaGtb0yaDo6Rfjjj7a6wKZtbAuYZIdM(u1GZoOBRtd0XGiuPylY5P9ukBoSrnaDSLHnQSd4C0xdfqXanrYoRmeNz7beAjploy6tvdo7GUTonqhdIqLICiyh1KW5eoWP5Wg1a0Xwg2OIdb7Og6nOdV(MObBnfhc2rDhhKP3xnpwqWV0GTMIdb7OUJdY07Rizj1ZJfeyscjObBnfhc2rTr(HHci)CtImha5NR4qWoQnYpmubYa9PKyIbqAWwtDjOOtNn91HAs2gQanO0CrhdDQYwYZIdM(u1GZoOBRtd0XGiuPya6OoBAJ8ddZHnQbOJTmSr1eA0LUEEzqwYZIdM(u1GZoOBRtd0XGiuPihc2rDg0MdBufzoaYpxfGoQZM2i)Wqfid0VKNfhm9PQbNDq3wNgOJbrOsroeSJA6bppZHnQImha5NRcqh1ztBKFyOcKb6BIgS1uCiyh1IooSr18ybb)sd2AkoeSJArhh2OIKLuppwqqjploy6tvdo7GUTonqhdIqLIaiFD0z4O5Wg1FgGo2YWgvhsAKbp0FCyqmXI0baHNYg2oD20xhQhqrxjploy6tvdo7GUTonqhdIqLIbOJ6SPnYpmk5LJ1(dB1(H)dSw(QLKLS25XccM1MTAjecPw2bQ9dRTJLI()RwWjcuBpm7T2(4zETGtSwU25XccQ9YAncuk6xTKGUOd621c6dCoRnaDh621EDyTuaZbz69RDG2OdWr)sEwCW0NQgC2bDBDAGogeHkf5qWoQjHZjCGtZHnQ0GTMsmqoe88GUTkqwCMObBnLyGCi45bDB18ybbuPbBnLyGCi45bDBfjlPEESGatIuk6SFkPOFD9dtImha5NRiHrKXuNn9Lbj6NkqgOVPFkLditpqfsAKFyGaAAoc2gnjYCaKFUIdb7O2i)Wqfid0VKxowlrZGKhJ(1(H1AWWOwJ8GPxl4eR9dED12Z)O51sdE1cVA)GJrTdEE1os3Uw0tq7UABzulDED1EDyTYb5pwl7a12Z)yTFqhi)M1c6dCoRnaDh621EDyTww1MrT9khw7aTrhGdiol5zXbtFQAWzh0T1Pb6yqeQu0ipy6MdBu)PebOJTmSr1eA0LUEEzqsmXbOJTmSr1HKgzWd9hhguwYZIdM(u1GZoOBRtd0XGiuPOrEW0nh2O(Za0Xwg2O6qsJm4H(Jddts8Za0Xwg2OAcn6sxpVmijMyPCaz6bQmc0aCm0O0KQSuwYZIdM(u1GZoOBRtd0XGiuPiaYxhDgoAoSrLgS1ubOJ6SPnYpmua5NtmXgbkvBlauYQ4qWoQP5iyBSKNfhm9PQbNDq3wNgOJbrOsXGbGSF6PbheyoSrLgS1ubOJ6SPnYpmua5NtmXgbkvBlauYQ4qWoQP5iyBSKNfhm9PQbNDq3wNgOJbrOsrsyezm1ztFzqI(zoSrLgS1ubOJ6SPnYpmubsYqF(Re9iIi3Esa6yldBunHgDPRNxgKuwYlhRvoSd9Adq3HUDTxhwlfWCqME)AhOn6aC038AbNyT98pwln2YaRT386H1EzTaGKg1Y12ahJ(1opwqaculnhCyJL8S4GPpvn4Sd6260aDmicvkYHGDuBKFyyoSrvkhqMEGkK0i)Wab00CeSnAIgS1ubOJ6SPnYpmuGgMKGKDwziUFLqUekrKqwz2tePu0z)ue0pGStjLetmnyRPedKdbppOBRMhliGknyRPedKdbppOBRizj1ZJfeqzjploy6tvdo7GUTonqhdIqLICiyh10CeSnAoSrvkhqMEGkK0i)Wab00CeSnAIgS1uCiyh1IooSr18ybbuPbBnfhc2rTOJdBurYsQNhliWenyRP4qWoQnYpmuGgL8S4GPpvn4Sd6260aDmicvkEjOOtNn91HAs2gAoSrLgS1ubOJ6SPnYpmua5NtmXgbkvBlauYQ4qWoQP5iyBKyIncuQ2waOKvfmaK9tpn4GaIj2iqPABbGswfaYxhDgowYZIdM(u1GZoOBRtd0XGiuPihc2rTr(HH5WgvJaLQTfakzvxck60ztFDOMKTHL8YXALtNyT)y2dR9YANYzqePaG1YETOKxW12ZHGDSwcp45vlayaD7AVoS2EZRhsXE(hR9d6a5xTG(aNZAdq3HUDT9CiyhRLcu0LQA)HTA75qWowlfOOlRfoR94b6hcyETFyTc2)F1coXA)XShw7h86GETxhwBV51dPyp)J1(bDG8RwqFGZzTFyTq)WianUAVoS2EUhwROJDhhMx7mR9d)pg1ozPyTWtvYZIdM(u1GZoOBRtd0XGiuPOrGt0fOoBAsOdyoSr9Nhpq)uCiyh1OOlnbG0GTM6sqrNoB6Rd1KSnubAycaPbBn1LGIoD20xhQjzBOkqsg6ZFPkbloy6koeSJA6bppfkjkapuFqsSNqd2AkJaNOlqD20KqhqrYsQNhliGYsE5yT)WwT)y2dRTJN()RwAe9AbNiqTaGb0TR96WA7nVEyTFqhi)mV2p8)yul4eRfE1EzTt5miIuaWAzVwuYl4A75qWowlHh88Qf61EDyTYb5psXE(hR9d6a5NQKNfhm9PQbNDq3wNgOJbrOsrJaNOlqD20KqhWCyJknyRP4qWoQnYpmuGgMObBnva6OoBAJ8ddvGKm0N)svcwCW0vCiyh10dEEkusuaEO(GKypHgS1ugborxG6SPjHoGIKLuppwqaLL8S4GPpvn4Sd6260aDmicvkYHGDutp45zoSrfipvWaq2p90GdcubsYqFAwcLyIbqAWwtfmaK9tpn4GaTuWHJbtdhWRVAESGaZkZsE5yTYHyTFSF1EzTKmbyTtWaR9dRTJLI1IEcA3vlj7CTTmQ96WAr)GbwBp)J1(bDG8Z8ArPOxlSv71Hb(Fw78GJrThKeRnqsg6q3U20Rvoi)rvT)W7)S20h9RLgVdJAVSwAWWR9YAPaGrwl7a1sbknRf2QnaDh621EDyTww1MrT9khw7aTrhGdiovL8S4GPpvn4Sd6260aDmicvkYHGDutZrW2O5WgvrMdG8ZvCiyh1g5hgQazG(MizNvgI7xjOGYKisiRm7jIuk6SFkc6hq2PKst0GTMIdb7Ow0XHnQMhliGknyRP4qWoQfDCyJksws98ybbMK4NbOJTmSr1eA0LUEEzqsmXs5aY0duzeOb4yOrPjvzP00pdqhBzyJQdjnYGh6pomm9Za0Xwg2OIdb7Og6nOdV(L8YXAjmhbBJ1o7sWbqTEE1sJ1corGA5R2RdRfDGAZwT98pwlSvlfO0uWhm9AHZAdKb6xlpRfisddOBxROJdBCw7hCmQLKjaRfE1EmbyTJ0TXO2lRLgm8AVUibT7Qnqsg6q3Uws25sEwCW0NQgC2bDBDAGogeHkf5qWoQP5iyB0CyJknyRP4qWoQnYpmuGgMObBnfhc2rTr(HHkqsg6ZFPAlamjYCaKFUcLMc(GPRcKKH(SKxowlH5iyBS2zxcoaQLhFC)zT0yTxhw7GNxTcEE1c9AVoSw5G8hR9d6a5xT8S2EZRhw7hCmQnW5Lbw71H1k64WgN1onq)k5zXbtFQAWzh0T1Pb6yqeQuKdb7OMMJGTrZHnQ0GTMkaDuNnTr(HHc0WenyRP4qWoQnYpmua5NBIgS1ubOJ6SPnYpmubsYqF(lvBbGPFgGo2YWgvCiyh1qVbD41VKNfhm9PQbNDq3wNgOJbrOsroeSJAs4Cch40CyJkasd2AQlbfD6SPVoutY2qfOHPJhOFkoeSJAu0LMKGgS1uaiFD0z4Oci)CIjMfhukQrhjH4KQSuAcaPbBn1LGIoD20xhQjzBOkqsg6tZYIdMUIdb7OMeoNWbovOKOa8q9bjrZfDm0PkR5ihJ(ArhdDnSrLgS1uIbYHGNh0T1Io2DCOaYp3Ke0GTMIdb7O2i)WqbAqmXs8ZJhOFQukgg5hgiGjjObBnva6OoBAJ8ddfObXelYCaKFUcLMc(GPRcKb6tjLuwYlhR9h2Q9d)hyTsr)66hMxlKKebG8HJ(1coXAjecP2Vo0RvWggiqTxwRNxTF88WAnIumRTfjzT9WS3sEwCW0NQgC2bDBDAGogeHkf5qWoQjHZjCGtZHnQIuk6SFkPOFD9dt0GTMsmqoe88GUTAESGaQ0GTMsmqoe88GUTIKLuppwqqjVCSwRJJRwWj0TRLqiKA75EyTFDOxBp)J12XZAPr0RfCIaL8S4GPpvn4Sd6260aDmicvkYHGDutcNt4aNMdBuPbBnLyGCi45bDBvGS4mjYCaKFUIdb7O2i)Wqfijd9PjjObBnva6OoBAJ8ddfObXetd2AkoeSJAJ8ddfObLMl6yOtv2sEwCW0NQgC2bDBDAGogeHkf5qWoQZG2CyJknyRP4qWoQfDCyJQ5Xcc(LQuoGm9avxEKAswsTOJdBCwYZIdM(u1GZoOBRtd0XGiuPihc2rn9GNN5WgvAWwtfGoQZM2i)WqbAqmXKSZkdXzwzj0sEwCW0NQgC2bDBDAGogeHkfrPPGpy6MdBuPbBnva6OoBAJ8ddfq(5MObBnfhc2rTr(HHci)CZH(HraACAyJkj7SYqCMLApMqnh6hgbOXPHKKiaKpKQSL8S4GPpvn4Sd6260aDmicvkYHGDutZrW2yjFjVCuowRCQpbnmY4qGAfSlWHMfhmD5KUwkqPPGpy61(bhJAPXAD(adEm6xlDKeGETWwTI0bGhm9zTCG1sINQKxokhRLfhm9PQJdY07tvWUahAwCW0nh2OYIdMUcLMc(GPReDS74a62MizNvgIZSu7beAjVCS2FyR2r(vB61sYoxl7a1kYCaKF(SwoWAfjj0TRf0W8ATZA5oKbQLDGArPzjploy6tvhhKP3NiuPiknf8bt3CyJkj7SYqC)svgLPjPCaz6bQsWBcbqD20Imha5NpnjXXd0pva6OoBAJ8ddtImha5NRcqh1ztBKFyOcKKH(8xzLjLL8S4GPpvDCqMEFIqLICiyh1KW5eoWP5WgvjKYbKPhOAESGaDhhKP3NyIpij(RSYKst0GTMIdb7OUJdY07RMhli4xAWwtXHGDu3Xbz69vKSK65Xccmx0XqNQSL8YXALd7qVwWj0TRLcK0OFG8Ow5ebGZUanVwbpVA5AB4xTOKxW1scNt4aN1(1bhyTFm8GUDTTmQ96WAPbBTA5R2RdRDECC1MTAVoS2g0U7k5zXbtFQ64Gm9(eHkf5qWoQjHZjCGtZHnQOCgeAyGakK0OFG8qNbGZUanDqs8xzuMMU02EGkrMdG8ZNMezoaYpxHKg9dKh6maC2fOkqsg6tZkBpQhxYZIdM(u1Xbz69jcvkgmaK9tpn4GaZHnQs5aY0duHKg5hgiGMMJGTrtImha5NRUeu0PZM(6qnjBdvbsYqF(lvusuaEO(GKOjrMdG8ZvCiyh1g5hgQajzOp)LQeOKOa8q9bjXEICP0Ke)eLZGqddeqntWXaVd626aKUpXelshaeEkoeSJAJibG29vb7eywQekXeFb0jap1mbhd8oOBRdq6(krMdG8ZvbsYqF(lvjqjrb4H6dsI9e5sjLL8S4GPpvDCqMEFIqLIxck60ztFDOMKTHMdBuLYbKPhO6heCEAWjcONgCqGjrMdG8ZvCiyh1g5hgQajzOp)LkkjkapuFqs0Ke)eLZGqddeqntWXaVd626aKUpXelshaeEkoeSJAJibG29vb7eywQekXeFb0jap1mbhd8oOBRdq6(krMdG8ZvbsYqF(lvusuaEO(GKiLL8S4GPpvDCqMEFIqLICiyh1g5hgMdBuncuQ2waOKvDjOOtNn91HAs2gwYZIdM(u1Xbz69jcvkgGoQZM2i)WWCyJQuoGm9aviPr(HbcOP5iyB0KiZbq(5QGbGSF6PbheOcKKH(8xQOKOa8q9bjrts5aY0duDqsud6hCOzdZsvUYSKNfhm9PQJdY07teQumyai7NEAWbbMdBuLYbKPhOcjnYpmqannhbBJMmcuQ2waOKvfGoQZM2i)WOKNfhm9PQJdY07teQu8sqrNoB6Rd1KSn0CyJQuoGm9av)GGZtdora90Gdcm9tPCaz6bQ6Yba0T1xEKL8S4GPpvDCqMEFIqLIbOJ6SPnYpmmh2Osd2AkoeSJAJ8ddfq(5MKqkhqMEGQdsIAq)GdnBywzuMetSiZbq(5QGbGSF6PbheOcKKH(0SYkxkl5zXbtFQ64Gm9(eHkfdgaY(PNgCqG5WgvPCaz6bQqsJ8ddeqtZrW2OjjObBnfhc2rTOJdBunpwqGzPkxIjwK5ai)Cfhc2rDg0QazG(uAsIFE8a9tfGoQZM2i)WGyIfzoaYpxfGoQZM2i)Wqfijd9PzjuknjLditpqfopijFiGMn0Imha5NBwQYOml5LJ1kh2HETbO7q3UwJibG29nVwWjw7LhzT09RfEtC0Qf61Mbag1EzT8aA71cVA)GxxTSrjploy6tvhhKP3NiuP4LGIoD20xhQjzBO5WgvPCaz6bQoijQb9do0SXVeQmnjLditpq1bjrnOFWHMnmRmktts8tuodcnmqa1mbhd8oOBRdq6(etSiDaq4P4qWoQnIeaA3xfStGzPsOuwYZIdM(u1Xbz69jcvkYHGDuNbT5WgvPCaz6bQ(bbNNgCIa6PbheyIgS1uCiyh1IooSr18ybb)sd2AkoeSJArhh2OIKLuppwqqjploy6tvhhKP3NiuPihc2rnnhbBJMdBubqAWwtfmaK9tpn4GaTuWHJbtdhWRVAESGaQainyRPcgaY(PNgCqGwk4WXGPHd41xrYsQNhliOKNfhm9PQJdY07teQuKdb7OMEWZZCyJQuoGm9av)GGZtdora90GdciMyjaqAWwtfmaK9tpn4GaTuWHJbtdhWRVc0Weasd2AQGbGSF6PbheOLcoCmyA4aE9vZJfe8lasd2AQGbGSF6PbheOLcoCmyA4aE9vKSK65XccOSKxowRC6eRnd6AtVwbqTG(aNZAzJAHZAfjj0TRf0O2zMEjploy6tvhhKP3NiuPihc2rDg0MdBuPbBnfhc2rTOJdBunpwqWVYOjPCaz6bQoijQb9do0SHzLvML8S4GPpvDCqMEFIqLICiyh1KW5eoWP5WgvAWwtjgihcEEq3wfilot0GTMIdb7O2i)WqbAyUOJHovzl5zXbtFQ64Gm9(eHkf5qWoQPh88mh2Osd2AkJaNOlqD20KqhqbAuYlhRT3oSwACE1coXAZwTgjzTWzTxwl4eRfE1EzTYzqOGGr)APbHdGAfDCyJZAbadOBxlBul3omQ96W(1AJxTaGKgiqT09R96WA74Gm9(1sZrW2yjploy6tvhhKP3NiuPOrGt0fOoBAsOdyoSrLgS1uCiyh1IooSr18ybb)sd2AkoeSJArhh2OIKLuppwqGjAWwtXHGDuBKFyOank5zXbtFQ64Gm9(eHkf5qWoQjHZjCGtZHnQ0GTMIdb7OUJdY07RMhli4xAWwtXHGDu3Xbz69vKSK65Xccmx0XqNQSMd9dJa04OkR5q)WianoT9iP5bvzl5zXbtFQ64Gm9(eHkf5qWoQP5iyB0CyJknyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqGjPCaz6bQqsJ8ddeqtZrW2yjploy6tvhhKP3NiuPiknf8bt3CyJkj7SYqC)klHwYlhRvoHp6xl4eRLEWZR2lRLgeoaQv0XHnoRf2Q9dRLhbYa9RTJLI1otsS2wKK1MbDjploy6tvhhKP3NiuPihc2rn9GNN5WgvAWwtXHGDul64WgvZJfeyIgS1uCiyh1IooSr18ybb)sd2AkoeSJArhh2OIKLuppwqqjVCSw5KbhJA)GxxTmzTG(aNZAzJAHZAfjj0TRf0Ow2bQ9d)hyTJ8R20RLKDUKNfhm9PQJdY07teQuKdb7OMeoNWbonh2O(tjKYbKPhO6GKOg0p4qZg)svwzAIKDwziUFLrzsP5Iog6uL1COFyeGghvznh6hgbOXPThjnpOkBjVCS2FmYgCGZA)GxxTJ8RwsEEy038A7G2D12XZdnV2mQLoVUAj5(165vBhlfRf9e0URws25AVS2jOHrgxTD5xTKSZ1c9d9jukwBWaq2VANgCqqTc2RLgnV2zw7h(FmQfCI12Gbwl9GNxTSduBlY5rNJR2Vo0RDKF1METKSZL8S4GPpvDCqMEFIqLInyGA6bpVsEwCW0NQooitVprOsXwKZJohxjFjploy6tvAGoguBWa10dEEMdBudqhBzyJka4uangqNJ(ArssYoGjAWwtbaNcOXa6C0xlsss2b0TiNNc0OKNfhm9PknqhdIqLITiNN2tPS5Wg1a0Xwg2OYoGZrFnuafd0ej7SYqCMThqOL8S4GPpvPb6yqeQuea5RJodhl5zXbtFQsd0XGiuPyWaq2p90Gdcmh2OsYoRmeNzPGYSKNfhm9PknqhdIqLIKWiYyQZM(YGe9RKNfhm9PknqhdIqLIZoy7GUT2i)WWCyJknyRP4qWoQnYpmua5NBsK5ai)Cfhc2rTr(HHkqsg6ZsEwCW0NQ0aDmicvkYHGDuNbT5WgvrMdG8ZvCiyh1g5hgQazG(MObBnfhc2rTOJdBunpwqWV0GTMIdb7Ow0XHnQizj1ZJfeuYZIdM(uLgOJbrOsroeSJA6bppZHnQIuk6SFkPOFD9dtImha5NRiHrKXuNn9Lbj6Nkqsg6tZ2JPGL8S4GPpvPb6yqeQu8sqrNoB6Rd1KSnSKNfhm9PknqhdIqLICiyh1g5hgL8S4GPpvPb6yqeQumaDuNnTr(HH5WgvAWwtXHGDuBKFyOaYpVKxowRC6eR9hZEyTxw7uodIifaSw2RfL8cU2EoeSJ1s4bpVAbadOBx71H12BE9qk2Z)yTFqhi)Qf0h4CwBa6o0TRTNdb7yTuGIUuv7pSvBphc2XAPafDzTWzThpq)qaZR9dRvW()RwWjw7pM9WA)Gxh0R96WA7nVEif75FS2pOdKF1c6dCoR9dRf6hgbOXv71H12Z9WAfDS74W8ANzTF4)XO2jlfRfEQsEwCW0NQ0aDmicvkAe4eDbQZMMe6aMdBu)5Xd0pfhc2rnk6stainyRPUeu0PZM(6qnjBdvGgMaqAWwtDjOOtNn91HAs2gQcKKH(8xQsWIdMUIdb7OMEWZtHsIcWd1hKe7j0GTMYiWj6cuNnnj0buKSK65XccOSKxow7pSv7pM9WA74P))QLgrVwWjculayaD7AVoS2EZRhw7h0bYpZR9d)pg1coXAHxTxw7uodIifaSw2RfL8cU2EoeSJ1s4bpVAHETxhwRCq(JuSN)XA)Goq(Pk5zXbtFQsd0XGiuPOrGt0fOoBAsOdyoSrLgS1uCiyh1g5hgkqdt0GTMkaDuNnTr(HHkqsg6ZFPkbloy6koeSJA6bppfkjkapuFqsSNqd2AkJaNOlqD20KqhqrYsQNhliGYsEwCW0NQ0aDmicvkYHGDutp45zoSrfipvWaq2p90GdcubsYqFAwcLyIbqAWwtfmaK9tpn4GaTuWHJbtdhWRVAESGaZkZsE5yT984J7pRLWCeSnwlF1EDyTOduB2QTN)XA)6qV2a0DOBx71H12ZHGDSwkG5Gm9(1oqB0b4OFjploy6tvAGogeHkf5qWoQP5iyB0CyJknyRP4qWoQnYpmuGgMObBnfhc2rTr(HHkqsg6ZFTfaMcqhBzyJkoeSJAO3Go86xYlhRTNhFC)zTeMJGTXA5R2RdRfDGAZwTxhwRCq(J1(bDG8R2Vo0RnaDh621EDyT9CiyhRLcyoitVFTd0gDao6xYZIdM(uLgOJbrOsroeSJAAoc2gnh2Osd2AQa0rD20g5hgkqdt0GTMIdb7O2i)WqbKFUjAWwtfGoQZM2i)Wqfijd95VuTfaMcqhBzyJkoeSJAO3Go86xYZIdM(uLgOJbrOsroeSJAs4Cch40CyJkasd2AQlbfD6SPVoutY2qfOHPJhOFkoeSJAu0LMKGgS1uaiFD0z4Oci)CIjMfhukQrhjH4KQSuAcaPbBn1LGIoD20xhQjzBOkqsg6tZYIdMUIdb7OMeoNWbovOKOa8q9bjrZfDm0PkR5ihJ(ArhdDnSrLgS1uIbYHGNh0T1Io2DCOaYp3Ke0GTMIdb7O2i)WqbAqmXs8ZJhOFQukgg5hgiGjjObBnva6OoBAJ8ddfObXelYCaKFUcLMc(GPRcKb6tjLuwYZIdM(uLgOJbrOsroeSJAs4Cch40CyJknyRPedKdbppOBRMhliGknyRPedKdbppOBRizj1ZJfeysKsrN9tjf9RRFuYZIdM(uLgOJbrOsroeSJAs4Cch40CyJknyRPedKdbppOBRcKfNjrMdG8ZvCiyh1g5hgQajzOpnjbnyRPcqh1ztBKFyOaniMyAWwtXHGDuBKFyOanO0CrhdDQYwYZIdM(uLgOJbrOsroeSJ6mOnh2Osd2AkoeSJArhh2OAESGGFPkLditpq1LhPMKLul64WgNL8S4GPpvPb6yqeQuKdb7OMEWZZCyJknyRPcqh1ztBKFyOaniMys2zLH4mRSeAjploy6tvAGogeHkfrPPGpy6MdBuPbBnva6OoBAJ8ddfq(5MObBnfhc2rTr(HHci)CZH(HraACAyJkj7SYqCMLApMqnh6hgbOXPHKKiaKpKQSL8S4GPpvPb6yqeQuKdb7OMMJGTXs(sE5OCSwwCW0NQip(GPtvWUahAwCW0nh2OYIdMUcLMc(GPReDS74a62MizNvgIZSu7beQjj(za6yldBunHgDPRNxgKetmnyRPMqJU01Zlds18ybbuPbBn1eA0LUEEzqQizj1ZJfeqzjVCSw50jwlknRf2Q9d)hyTJ8R20RLKDUw2bQvK5ai)8zTCG1Y0j4v7L1sJ1cAuYZIdM(uf5XhmDIqLIO0uWhmDZHnQKSZkdX9lvPCaz6bQqPP2qCMKqK5ai)C1LGIoD20xhQjzBOkqsg6ZFPYIdMUcLMc(GPRqjrb4H6dsIetSiZbq(5koeSJAJ8ddvGKm0N)sLfhmDfknf8btxHsIcWd1hKejMyjoEG(Pcqh1ztBKFyysK5ai)Cva6OoBAJ8ddvGKm0N)sLfhmDfknf8btxHsIcWd1hKePKst0GTMkaDuNnTr(HHci)Ct0GTMIdb7O2i)WqbKFUjaKgS1uxck60ztFDOMKTHkG8Zn9tJaLQTfakzvxck60ztFDOMKTHL8S4GPpvrE8btNiuPiknf8bt3CyJAa6yldBunHgDPRNxgKMezoaYpxXHGDuBKFyOcKKH(8xQS4GPRqPPGpy6kusuaEO(GKyjVCSwcZrW2yTWwTW7)S2dsI1EzTGtS2lpYAzhO2pS2owkw7LzTKS3Vwrhh24SKNfhm9PkYJpy6eHkf5qWoQP5iyB0CyJQiZbq(5QlbfD6SPVoutY2qvGmqFtsqd2AkoeSJArhh2OAESGaZkLditpq1LhPMKLul64WgNMezoaYpxXHGDuBKFyOcKKH(8xQOKOa8q9bjrtKSZkdXzwPCaz6bQydnj0HKGKAs2zTH4mrd2AQa0rD20g5hgkG8ZPSKNfhm9PkYJpy6eHkf5qWoQP5iyB0CyJQiZbq(5QlbfD6SPVoutY2qvGmqFtsqd2AkoeSJArhh2OAESGaZkLditpq1LhPMKLul64WgNMoEG(Pcqh1ztBKFyysK5ai)Cva6OoBAJ8ddvGKm0N)sfLefGhQpijAskhqMEGQdsIAq)GdnBywPCaz6bQU8i1KSKAaCW91Tm0SbLL8S4GPpvrE8btNiuPihc2rnnhbBJMdBufzoaYpxDjOOtNn91HAs2gQcKb6BscAWwtXHGDul64WgvZJfeywPCaz6bQU8i1KSKArhh240Ke)84b6NkaDuNnTr(HbXelYCaKFUkaDuNnTr(HHkqsg6tZkLditpq1LhPMKLudGdUVULHosdknjLditpq1bjrnOFWHMnmRuoGm9avxEKAswsnao4(6wgA2GYsEwCW0NQip(GPteQuKdb7OMMJGTrZHnQainyRPcgaY(PNgCqGwk4WXGPHd41xnpwqavaKgS1ubdaz)0tdoiqlfC4yW0Wb86Rizj1ZJfeyscAWwtXHGDuBKFyOaYpNyIPbBnfhc2rTr(HHkqsg6ZFPAlaO0Ke0GTMkaDuNnTr(HHci)CIjMgS1ubOJ6SPnYpmubsYqF(lvBbaLL8S4GPpvrE8btNiuPihc2rn9GNN5WgvPCaz6bQ(bbNNgCIa6PbheqmXsaG0GTMkyai7NEAWbbAPGdhdMgoGxFfOHjaKgS1ubdaz)0tdoiqlfC4yW0Wb86RMhli4xaKgS1ubdaz)0tdoiqlfC4yW0Wb86Rizj1ZJfeqzjploy6tvKhFW0jcvkYHGDutp45zoSrLgS1ugborxG6SPjHoGc0Weasd2AQlbfD6SPVoutY2qfOHjaKgS1uxck60ztFDOMKTHQajzOp)Lkloy6koeSJA6bppfkjkapuFqsSKNfhm9PkYJpy6eHkf5qWoQjHZjCGtZHnQainyRPUeu0PZM(6qnjBdvGgMoEG(P4qWoQrrxAscAWwtbG81rNHJkG8ZjMywCqPOgDKeItQYsPjjaqAWwtDjOOtNn91HAs2gQcKKH(0SS4GPR4qWoQjHZjCGtfkjkapuFqsKyIfzoaYpxze4eDbQZMMe6aQajzOpjMyrkfD2pfb9di7uAUOJHovznh5y0xl6yORHnQ0GTMsmqoe88GUTw0XUJdfq(5MKGgS1uCiyh1g5hgkqdIjwIFE8a9tLsXWi)WabmjbnyRPcqh1ztBKFyOaniMyrMdG8ZvO0uWhmDvGmqFkPKYsE5yTes6tqsS2RdRfL0GDaeOwJ8q)G8OwAWwRwEYg1EzTEE1oYjwRrEOFqEuRrKIzjploy6tvKhFW0jcvkYHGDutcNt4aNMdBuPbBnLyGCi45bDBvGS4mrd2Akusd2bqaTrEOFqEOank5zXbtFQI84dMorOsroeSJAs4Cch40CyJknyRPedKdbppOBRcKfNjjObBnfhc2rTr(HHc0GyIPbBnva6OoBAJ8ddfObXedG0GTM6sqrNoB6Rd1KSnufijd9PzzXbtxXHGDutcNt4aNkusuaEO(GKiLMl6yOtv2sEwCW0NQip(GPteQuKdb7OMeoNWbonh2Osd2AkXa5qWZd62QazXzIgS1uIbYHGNh0TvZJfeqLgS1uIbYHGNh0TvKSK65Xccmx0XqNQSL8YXA75Xh3Fw7f9R9YAPzNGAjecP2wg1kYCaKFETFqhi)M1sdE1casAu71HK1cB1EDy))bwltNGxTxwlkPbmWsEwCW0NQip(GPteQuKdb7OMeoNWbonh2Osd2AkXa5qWZd62QazXzIgS1uIbYHGNh0TvbsYqF(lvjKGgS1uIbYHGNh0TvZJfe0tyXbtxXHGDutcNt4aNkusuaEO(GKiLeXwaOizjP0CrhdDQYwYZIdM(uf5XhmDIqLIoEDyOpK0aNN5WgvjcSf4SJPhiXe)Zdkia62uAIgS1uCiyh1IooSr18ybbuPbBnfhc2rTOJdBurYsQNhliWenyRP4qWoQnYpmua5NBcaPbBn1LGIoD20xhQjzBOci)8sEwCW0NQip(GPteQuKdb7OodAZHnQ0GTMIdb7Ow0XHnQMhli4xQs5aY0duD5rQjzj1IooSXzjploy6tvKhFW0jcvkobnWWtPS5WgvPCaz6bQsWBcbqD20Imha5NpnrYoRme3Vu7beAjploy6tvKhFW0jcvkYHGDutp45zoSrLgS1ub4a1ztFDbItfOHjAWwtXHGDul64WgvZJfeywzSKxowRCsajnQv0XHnoRf2Q9dRTXJrT04i)Q96WAfPpXqkwlj7CTxxGZUCaul7a1IstbFW0RfoRDEWXO20RvK5ai)8sEwCW0NQip(GPteQuKdb7OMMJGTrZHnQ)maDSLHnQMqJU01Zldsts5aY0duLG3ecG6SPfzoaYpFAIgS1uCiyh1IooSr18ybbuPbBnfhc2rTOJdBurYsQNhliW0Xd0pfhc2rDg0MezoaYpxXHGDuNbTkqsg6ZFPAlamrYoRme3Vu7bY0KiZbq(5kuAk4dMUkqsg6ZsEwCW0NQip(GPteQuKdb7OMMJGTrZHnQbOJTmSr1eA0LUEEzqAskhqMEGQe8MqauNnTiZbq(5tt0GTMIdb7Ow0XHnQMhliGknyRP4qWoQfDCyJksws98ybbMoEG(P4qWoQZG2KiZbq(5koeSJ6mOvbsYqF(lvBbGjs2zLH4(LApqMMezoaYpxHstbFW0vbsYqF(RmkZsE5yTYjbK0Owrhh24SwyR2mORfoRnqgOFjploy6tvKhFW0jcvkYHGDutZrW2O5WgvPCaz6bQsWBcbqD20Imha5Npnrd2AkoeSJArhh2OAESGaQ0GTMIdb7Ow0XHnQizj1ZJfey64b6NIdb7OodAtImha5NR4qWoQZGwfijd95VuTfaMizNvgI7xQ9azAsK5ai)Cfknf8btxfijd9zjVCS2EoeSJ1syoc2gRD2LGdGATrhdEm6xlnw71H1o45vRGNxTzR2RdRTN)XA)Goq(vYZIdM(uf5XhmDIqLICiyh10CeSnAoSrLgS1uCiyh1g5hgkqdt0GTMIdb7O2i)Wqfijd95VuTfaMObBnfhc2rTOJdBunpwqavAWwtXHGDul64WgvKSK65XccmjHiZbq(5kuAk4dMUkqsg6tIjoaDSLHnQ4qWoQHEd6WRpLL8YXA75qWowlH5iyBS2zxcoaQ1gDm4XOFT0yTxhw7GNxTcEE1MTAVoSw5G8hR9d6a5xjploy6tvKhFW0jcvkYHGDutZrW2O5WgvAWwtfGoQZM2i)WqbAyIgS1uCiyh1g5hgkG8Znrd2AQa0rD20g5hgQajzOp)LQTaWenyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqGjjezoaYpxHstbFW0vbsYqFsmXbOJTmSrfhc2rn0BqhE9PSKxowBphc2XAjmhbBJ1o7sWbqT0yTxhw7GNxTcEE1MTAVoS2EZRhw7h0bYVAHTAHxTWzTEE1corGA)GxxTYb5pwBg12Z)yjploy6tvKhFW0jcvkYHGDutZrW2O5WgvAWwtXHGDuBKFyOaYp3enyRPcqh1ztBKFyOaYp3easd2AQlbfD6SPVoutY2qfOHjaKgS1uxck60ztFDOMKTHQajzOp)LQTaWenyRP4qWoQfDCyJQ5XccOsd2AkoeSJArhh2OIKLuppwqqjVCSw5Wo0R96WApoSXRw4SwOxlkjkapS2GDBSw2bQ96WaRfoRLmdS2RJ9AthRfDKSV51coXAP5iyBSwEw7mtVwEwB)eS2owkwl6jODxTIooSXzTxwBh8QLhJArhjH4SwyR2RdRTNdb7yTeojP5aGe9R2bAJoah9RfoRfLZGqddeOKNfhm9PkYJpy6eHkf5qWoQP5iyB0CyJQuoGm9aviPr(HbcOP5iyB0enyRP4qWoQfDCyJQ5XccmlvjyXbLIA0rsio)bKLstS4Gsrn6ijeNMvwt0GTMca5RJodhva5NxYZIdM(uf5XhmDIqLICiyh1OKgJCct3CyJQuoGm9aviPr(HbcOP5iyB0enyRP4qWoQfDCyJQ5Xcc(LgS1uCiyh1IooSrfjlPEESGatS4Gsrn6ijeNMvwt0GTMca5RJodhva5NxYZIdM(uf5XhmDIqLICiyh10dEEL8S4GPpvrE8btNiuPiknf8bt3CyJQuoGm9avj4nHaOoBArMdG8ZNL8S4GPpvrE8btNiuPihc2rnnhbBJV7DVh]] )

    
end