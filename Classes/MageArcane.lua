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


    spec:RegisterPack( "Arcane", 20210629, [[daLwSgqiPK6rii5ssjss2ef5tiWOqIofsyvsjuVcHYSOO6wsjGDrYVicnmIIogrPLruPNre00iQqxJiW2iQiFtkjmoPeY5iQOwhrHENuIKuZtvLUhsAFuu6GsjQfIG6HiiMOuIK4IevGnkLiP8reKsgjcsPoPus0kjQ6LsjsQMjrb3ukrSteQ(PuIedvkjTuIkONsjtvvfxvkb6RiivJLII9Qk)LudwPdJAXi1JjmzaxgAZs1NLIrtPonOvlLi1Rvv1Sv42iA3u9BrdNchxkbTCHNROPRY1bA7ePVRQmEIOZlLA9iifZhHSFj)K99ZZcGp8rC5kt5kRmLtYvoRKTvit5Se0IEwxBd8zzWI)Cd(SCMeFwTCiyhFwgC7rYaVFEwZeme4ZY(oJPmkrj2apBqALijL4esco4dMUi4(jXjKuiXNfniCCTs)r)Sa4dFexUYuUYkt5KCLZkzBfYuolx5(SMgO4rC5KCFw2qaa0F0plaCkEwTeUbRTLdb7yjV8GowRCLZMxRCLPCLTKVKNqSzVbNYyjFlqTTGtS2RTbuWJATGKesT2SdmGEtTzVwHn7ooQf6hgbOXbtVwOppKbQn71sGGDbo0S4GPtGQKVfOwcXM9gSwoeSJAO3Ho8Ax7L1YHGDuBZbz6TRLs4vRJsXO2p0VAhqPyT8SwoeSJAO3Ho8AtH6znGZB((5zLgOJX7NhXL99ZZcDMEGapc)Seb8WaYpRa0XEgnOcaofqJb05OTwKKKSdOqNPhiqTMQLgS3vaWPaAmGohT1IKKKDaDpY5PanEwS4GP)S6Wa10dEEV7rC5((5zHotpqGhHFwIaEya5Nva6ypJgu1eW5OTgkGIbQqNPhiqTMQLKDwziUAnBTYzj4zXIdM(ZQh580EkLF3J4s47NNfloy6plaKpB6mC8zHotpqGhHF3J4YX3ppl0z6bc8i8ZseWddi)SizNvgIRwZwRCuMplwCW0Fwbdaz)0tdo()UhXLG3pplwCW0FwKWiYyQZU(YGe97zHotpqGhHF3J4YP3ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTr(HHci)8AnvRiZbq(5koeSJAJ8ddvGKm0NplwCW0FwtBy)GEJ2i)W4DpI3kE)8SqNPhiWJWplrapmG8ZsK5ai)Cfhc2rTr(HHkqgODTMQLgS3vCiyh1cBoAq18yX)A)TwAWExXHGDulS5ObvKSK65XI)plwCW0FwCiyh1zq)UhXBrVFEwOZ0de4r4NLiGhgq(zjsPOZ(PKI(z3oQ1uTImha5NRiHrKXuND9Lbj6Nkqsg6ZAnBTTi54ZIfhm9Nfhc2rn9GN37Eexo)(5zXIdM(Z6sqHTo76Zg1KCd8zHotpqGhHF3J4YkZ3pplwCW0FwCiyh1g5hgpl0z6bc8i87EexwzF)8SqNPhiWJWplrapmG8ZIgS3vCiyh1g5hgkG8ZFwS4GP)Scqh1zxBKFy8UhXLvUVFEwOZ0de4r4Nfloy6plJaNOlqD21Kqh4zbGtranoy6pRwWjwBRMTKAVS2zleercnyTSxlk5fCTTCiyhRLWdEE1cagqVP2ZgR9N8AjsSLB1A)Goq(vlOpW5S2a0DO3uBlhc2XALde2PQ2wzV2woeSJ1khiSZAHZApEG(HaMx7hwRGDcUAbNyTTA2sQ9dE2qV2ZgR9N8AjsSLB1A)Goq(vlOpW5S2pSwOFyeGgxTNnwBl3sQvyZUJdZRDM1(Hemg1ozPyTWt9Seb8WaYpRwx7Xd0pfhc2rnkStf6m9abQ1uTainyVRUeuyRZU(Srnj3avGg1AQwaKgS3vxckS1zxF2OMKBGQajzOpR9xQ1szTS4GPR4qWoQPh88uOKOa8q9bjXABX1sd27kJaNOlqD21KqhqrYsQNhl(xlfV7rCzLW3ppl0z6bc8i8ZIfhm9NLrGt0fOo7AsOd8SaWPiGghm9NvRSxBRMTKAT5PtWvlnIETGteOwaWa6n1E2yT)KxlP2pOdKFMx7hsWyul4eRfE1EzTZwiiIeAWAzVwuYl4AB5qWowlHh88Qf61E2yTYHzRkXwUvR9d6a5N6zjc4HbKFw0G9UIdb7O2i)WqbAuRPAPb7Dva6Oo7AJ8ddvGKm0N1(l1APSwwCW0vCiyh10dEEkusuaEO(GKyTT4APb7DLrGt0fOo7AsOdOizj1ZJf)RLI39iUSYX3ppl0z6bc8i8ZseWddi)SaYtfmaK9tpn44Vkqsg6ZAnBTsqTeruTainyVRcgaY(PNgC8xlfC4yW0Wb8ARMhl(xRzRvMplwCW0FwCiyh10dEEV7rCzLG3ppl0z6bc8i8ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)z1YJpU9SwcZrWnyT8v7zJ1IoqTzV2wUvR9Zg9Adq3HEtTNnwBlhc2XAj0MdY0Bx7aBqhGJ2plrapmG8ZIgS3vCiyh1g5hgkqJAnvlnyVR4qWoQnYpmubsYqFw7V12iaQ1uTbOJ9mAqfhc2rTnhKP3wHotpqG39iUSYP3ppl0z6bc8i8ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)z1YJpU9SwcZrWnyT8v7zJ1IoqTzV2ZgRvomB1A)Goq(v7Nn61gGUd9MApBS2woeSJ1sOnhKP3U2b2GoahTFwIaEya5NfnyVRcqh1zxBKFyOanQ1uT0G9UIdb7O2i)WqbKFETMQLgS3vbOJ6SRnYpmubsYqFw7VuRTrauRPAdqh7z0GkoeSJABoitVTcDMEGaV7rCzBfVFEwOZ0de4r4NLWMH(Zs2NfYXOTwyZqxd7plAWExjgihcEEqVrlSz3XHci)Ctusd27koeSJAJ8ddfObrerzRpEG(PsPyyKFyGaMOKgS3vbOJ6SRnYpmuGgerKiZbq(5kuAk4dMUkqgOnfuqXZseWddi)SaqAWExDjOWwND9zJAsUbQanQ1uThpq)uCiyh1OWovOZ0deOwt1szT0G9Uca5ZModhva5NxlrevlloOuuJoscXzTuRv2APOwt1cG0G9U6sqHTo76Zg1KCdufijd9zTMTwwCW0vCiyh1KW5eoWPcLefGhQpij(SyXbt)zXHGDutcNt4aNV7rCzBrVFEwOZ0de4r4NLiGhgq(zrd27kXa5qWZd6nQ5XI)1sTwAWExjgihcEEqVrrYsQNhl(xRPAfPu0z)usr)SBhplwCW0FwCiyh1KW5eoW57Eexw587NNf6m9abEe(zXIdM(ZIdb7OMeoNWboFwcBg6plzFwIaEya5NfnyVRedKdbppO3OcKfxTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnvlL1sd27Qa0rD21g5hgkqJAjIOAPb7Dfhc2rTr(HHc0OwkE3J4YvMVFEwOZ0de4r4NLiGhgq(zrd27koeSJAHnhnOAES4FT)sTwPCaz6bQU8i1KSKAHnhn48zXIdM(ZIdb7Ood639iUCL99ZZcDMEGapc)Seb8WaYplAWExfGoQZU2i)WqbAulrevlj7SYqC1A2ALvcEwS4GP)S4qWoQPh88E3J4YvUVFEwOZ0de4r4Nfloy6pluAk4dM(Zc6hgbOXPH9Nfj7SYqCMLAlscEwq)WianonKKebG8HplzFwIaEya5NfnyVRcqh1zxBKFyOaYpVwt1sd27koeSJAJ8ddfq(5V7rC5kHVFEwS4GP)S4qWoQP5i4g8zHotpqGhHF37EwD40g6n60aDmE)8iUSVFEwOZ0de4r4Nfloy6pluAk4dM(ZcaNIaACW0Fwe62OxBa6o0BQfHNng1E2yTww1MrT)qOx7aBqhGdionV2pS2p2VAVSw5aPzT0ypdS2ZgR9N8AjsSLB1A)Goq(PQTfCI1cVA5zTZm9A5zTYHzRwRnpRTdD40gbQnbJA)qcKI1onq)QnbJAf2C0GZNLiGhgq(zrzTbOJ9mAq1HKgzWd9hhgk0z6bculrevlL1gGo2ZObvtOHD665LbPcDMEGa1AQ2wxRuoGm9avgbAaogAuAwl1ALTwkQLIAnvlL1sd27Qa0rD21g5hgkG8ZRLiIQ1iqP6gbGswfhc2rnnhb3G1srTMQvK5ai)Cva6Oo7AJ8ddvGKm0NV7rC5((5zHotpqGhHFwS4GP)SqPPGpy6plaCkcOXbt)z1k71(HeifRTdD40gbQnbJAfzoaYpV2pOdKFZAzhO2Pb6xTjyuRWMJgCAETgbmd4bj0G1khinRnLIrTOumAF2qVPwCmXNLiGhgq(zD8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR1uTImha5NR4qWoQnYpmubsYqFwRPAPb7Dfhc2rTr(HHci)8AnvlnyVRcqh1zxBKFyOaYpVwt1AeOuDJaqjRIdb7OMMJGBW39iUe((5zHotpqGhHFwIaEya5Nva6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1sd27ka4uangqNJ2ArssYoGUh58uGgplwCW0FwDyGA6bpV39iUC89ZZcDMEGapc)Seb8WaYpRa0XEgnOQjGZrBnuafduHotpqGAnvlj7SYqC1A2ALZsWZIfhm9NvpY5P9uk)UhXLG3ppl0z6bc8i8ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYpRa0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh12CqMEB18yX)A)TwAWExXHGDuBZbz6TvKSK65XI)1AQwkRLYAPb7Dfhc2rTr(HHci)8AnvRiZbq(5koeSJAJ8ddvGmq7APOwIiQwaKgS3vxckS1zxF2OMKBGkqJAP4DpIlNE)8SqNPhiWJWplrapmG8ZkaDSNrdQMqd701Zldsf6m9abEwS4GP)Scqh1zxBKFy8UhXBfVFEwOZ0de4r4NLiGhgq(zjYCaKFUkaDuNDTr(HHkqgO9ZIfhm9Nfhc2rDg0V7r8w07NNf6m9abEe(zjc4HbKFwImha5NRcqh1zxBKFyOcKbAxRPAPb7Dfhc2rTWMJgunpw8V2FRLgS3vCiyh1cBoAqfjlPEES4)ZIfhm9Nfhc2rn9GN37Eexo)(5zHotpqGhHFwIaEya5NvRRnaDSNrdQoK0idEO)4WqHotpqGAjIOAfPdacpvdSF6SRpBupGcBf6m9abEwS4GP)Saq(SPZWX39iUSY89ZZIfhm9Nva6Oo7AJ8dJNf6m9abEe(DpIlRSVFEwOZ0de4r4Nfloy6ploeSJAs4Cch48zbGtranoy6pRwzV2pKGaRLVAjzjRDES4)S2SxlHqi1YoqTFyT2Su0j4QfCIa12sYFQTnEMxl4eRLRDES4FTxwRrGsr)QLe0f2qVPwqFGZzTbO7qVP2ZgRLqBoitVDTdSbDaoA)Seb8WaYplAWExjgihcEEqVrfilUAnvlnyVRedKdbppO3OMhl(xl1APb7DLyGCi45b9gfjlPEES4FTMQvKsrN9tjf9ZUDuRPAfzoaYpxrcJiJPo76lds0pvGmq7AnvBRRvkhqMEGkK0i)Wab00CeCdwRPAfzoaYpxXHGDuBKFyOcKbA)UhXLvUVFEwOZ0de4r4NLiGhgq(z16Adqh7z0GQdjnYGh6pomuOZ0deOwt1szTTU2a0XEgnOAcnStxpVmivOZ0deOwIiQwPCaz6bQmc0aCm0O0SwQ1kBTu8SaWPiGghm9NfXZGKhJ21(H1AWWOwJ8GPxl4eR9dE212YTQ51sdE1cVA)GJrTdEE1osVPw0tWg7A7zulDE21E2yTYHzRwl7a12YTATFqhi)M1c6dCoRnaDh6n1E2yTww1MrT)qOx7aBqhGdioFwS4GP)SmYdM(7Eexwj89ZZcDMEGapc)Seb8WaYplAWExfGoQZU2i)WqbKFETeruTgbkv3iauYQ4qWoQP5i4g8zXIdM(Zca5ZModhF3J4YkhF)8SqNPhiWJWplrapmG8ZIgS3vbOJ6SRnYpmua5NxlrevRrGs1ncaLSkoeSJAAocUbFwS4GP)ScgaY(PNgC8)DpIlRe8(5zHotpqGhHFwIaEya5NfnyVRcqh1zxBKFyOcKKH(S2FRLYALt1sSALBTT4Adqh7z0GQj0WoD98YGuHotpqGAP4zXIdM(ZIegrgtD21xgKOFV7rCzLtVFEwOZ0de4r4Nfloy6ploeSJAJ8dJNfaofb04GP)Si0TrV2a0DO3u7zJ1sOnhKP3U2b2GoahTnVwWjwBl3Q1sJ9mWA)jVwsTxwlaiPrTCTDWXODTZJf)rGAP5GJg8zjc4HbKFws5aY0duHKg5hgiGMMJGBWAnvlnyVRcqh1zxBKFyOanQ1uTuwlj7SYqC1(BTuwRCLGAjwTuwRSYS2wCTIuk6SFQ)Tdi71srTuulrevlnyVRedKdbppO3OMhl(xl1APb7DLyGCi45b9gfjlPEES4FTu8UhXLTv8(5zHotpqGhHFwIaEya5NLuoGm9aviPr(HbcOP5i4gSwt1sd27koeSJAHnhnOAES4FTuRLgS3vCiyh1cBoAqfjlPEES4FTMQLgS3vCiyh1g5hgkqJNfloy6ploeSJAAocUbF3J4Y2IE)8SqNPhiWJWplrapmG8ZIgS3vbOJ6SRnYpmua5NxlrevRrGs1ncaLSkoeSJAAocUbRLiIQ1iqP6gbGswvWaq2p90GJ)1ser1AeOuDJaqjRca5ZModhFwS4GP)SUeuyRZU(Srnj3aF3J4YkNF)8SqNPhiWJWplrapmG8ZYiqP6gbGsw1LGcBD21NnQj5g4ZIfhm9Nfhc2rTr(HX7EexUY89ZZcDMEGapc)SyXbt)zze4eDbQZUMe6aplaCkcOXbt)z1coXAB1SLu7L1oBHGisObRL9ArjVGRTLdb7yTeEWZRwaWa6n1E2yT)KxlrITCRw7h0bYVAb9boN1gGUd9MAB5qWowRCGWov12k712YHGDSw5aHDwlCw7Xd0peW8A)WAfStWvl4eRTvZwsTFWZg61E2yT)KxlrITCRw7h0bYVAb9boN1(H1c9dJa04Q9SXAB5wsTcB2DCyETZS2pKGXO2jlfRfEQNLiGhgq(z16ApEG(P4qWoQrHDQqNPhiqTMQfaPb7D1LGcBD21NnQj5gOc0Owt1cG0G9U6sqHTo76Zg1KCdufijd9zT)sTwkRLfhmDfhc2rn9GNNcLefGhQpijwBlUwAWExze4eDbQZUMe6aksws98yX)AP4DpIlxzF)8SqNPhiWJWplwCW0FwgborxG6SRjHoWZcaNIaACW0FwTYETTA2sQ1MNobxT0i61corGAbadO3u7zJ1(tETKA)Goq(zETFibJrTGtSw4v7L1oBHGisObRL9ArjVGRTLdb7yTeEWZRwOx7zJ1khMTQeB5wT2pOdKFQNLiGhgq(zrd27koeSJAJ8ddfOrTMQLgS3vbOJ6SRnYpmubsYqFw7VuRLYAzXbtxXHGDutp45Pqjrb4H6dsI12IRLgS3vgborxG6SRjHoGIKLuppw8VwkE3J4YvUVFEwOZ0de4r4NLiGhgq(zbKNkyai7NEAWXFvGKm0N1A2ALGAjIOAbqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8VwZwRmFwS4GP)S4qWoQPh88E3J4YvcF)8SqNPhiWJWplwCW0FwCiyh10CeCd(SaWPiGghm9NfHow7h7xTxwlj)hRDcgyTFyT2SuSw0tWg7AjzNRTNrTNnwl6hmWAB5wT2pOdKFMxlkf9AH9ApBmqcM1op4yu7bjXAdKKHo0BQn9ALdZwvvBR8iywB6J21sJ3HrTxwlny41EzTeAWiRLDGALdKM1c71gGUd9MApBSwlRAZO2Fi0RDGnOdWbeNQNLiGhgq(zjYCaKFUIdb7O2i)Wqfid0Uwt1sYoRmexT)wlL1khLzTeRwkRvwzwBlUwrkfD2p1)2bK9APOwkQ1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xRPAPS2wxBa6ypJgunHg2PRNxgKk0z6bculrevRuoGm9avgbAaogAuAwl1ALTwkQ1uTTU2a0XEgnO6qsJm4H(Jddf6m9abQ1uTTU2a0XEgnOIdb7O2MdY0BRqNPhiW7EexUYX3ppl0z6bc8i8ZIfhm9Nfhc2rnnhb3GplaCkcOXbt)zryocUbRDANGdGA98QLgRfCIa1YxTNnwl6a1M9AB5wTwyVw5aPPGpy61cN1gid0UwEwlqKggqVPwHnhn4S2p4yulj)hRfE1E8FS2r6nyu7L1sdgETNDKGn21gijdDO3ulj78ZseWddi)SOb7Dfhc2rTr(HHc0Owt1sd27koeSJAJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvO0uWhmDvGKm0NV7rC5kbVFEwOZ0de4r4Nfloy6ploeSJAAocUbFwa4ueqJdM(ZIWCeCdw70obha1YJpU9SwAS2ZgRDWZRwbpVAHETNnwRCy2Q1(bDG8RwEw7p51sQ9dog1g48YaR9SXAf2C0GZANgOFplrapmG8ZIgS3vbOJ6SRnYpmuGg1AQwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgQajzOpR9xQ12iaQ1uTTU2a0XEgnOIdb7O2MdY0BRqNPhiW7EexUYP3ppl0z6bc8i8ZsyZq)zj7Zc5y0wlSzORH9NfnyVRedKdbppO3Of2S74qbKFUjkPb7Dfhc2rTr(HHc0GiIOS1hpq)uPummYpmqatusd27Qa0rD21g5hgkqdIisK5ai)Cfknf8btxfid0MckO4zjc4HbKFwainyVRUeuyRZU(Srnj3avGg1AQ2JhOFkoeSJAuyNk0z6bcuRPAPSwAWExbG8ztNHJkG8ZRLiIQLfhukQrhjH4SwQ1kBTuuRPAbqAWExDjOWwND9zJAsUbQcKKH(SwZwlloy6koeSJAs4Cch4uHsIcWd1hKeFwS4GP)S4qWoQjHZjCGZ39iUCBfVFEwOZ0de4r4Nfloy6ploeSJAs4Cch48zbGtranoy6pRwzV2pKGaRvk6ND7W8AHKKiaKpC0UwWjwlHqi1(zJETc2WabQ9YA98Q9JNhwRrKIzT9ijRTLK)8Seb8WaYplrkfD2pLu0p72rTMQLgS3vIbYHGNh0BuZJf)RLAT0G9Usmqoe88GEJIKLuppw8)DpIl3w07NNf6m9abEe(zbGtranoy6plRJJRwWj0BQLqiKAB5wsTF2OxBl3Q1AZZAPr0RfCIaplrapmG8ZIgS3vIbYHGNh0BubYIRwt1kYCaKFUIdb7O2i)Wqfijd9zTMQLYAPb7Dva6Oo7AJ8ddfOrTeruT0G9UIdb7O2i)WqbAulfplHnd9NLSplwCW0FwCiyh1KW5eoW57EexUY53ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTWMJgunpw8V2FPwRuoGm9avxEKAswsTWMJgC(SyXbt)zXHGDuNb97EexcL57NNf6m9abEe(zjc4HbKFw0G9UkaDuNDTr(HHc0OwIiQws2zLH4Q1S1kRe8SyXbt)zXHGDutp459UhXLqzF)8SqNPhiWJWplwCW0FwO0uWhm9Nf0pmcqJtd7pls2zLH4ml1wKe8SG(HraACAijjca5dFwY(Seb8WaYplAWExfGoQZU2i)WqbKFETMQLgS3vCiyh1g5hgkG8ZF3J4sOCF)8SyXbt)zXHGDutZrWn4ZcDMEGapc)U39SI84dM(7NhXL99ZZcDMEGapc)SyXbt)zHstbFW0Fwa4ueqJdM(ZQfCI1IsZAH9A)qccS2r(vB61sYoxl7a1kYCaKF(SwoWAz6e8Q9YAPXAbnEwIaEya5Nfj7SYqC1(l1ALYbKPhOcLMAdXvRPAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR9xQ1YIdMUcLMc(GPRqjrb4H6dsI1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sTwwCW0vO0uWhmDfkjkapuFqsSwIiQwkR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7VuRLfhmDfknf8btxHsIcWd1hKeRLIAPOwt1sd27Qa0rD21g5hgkG8ZR1uT0G9UIdb7O2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8AnvBRR1iqP6gbGsw1LGcBD21NnQj5g47EexUVFEwOZ0de4r4NLiGhgq(zfGo2ZObvtOHD665LbPcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1YIdMUcLMc(GPRqjrb4H6dsIplwCW0FwO0uWhm939iUe((5zHotpqGhHFwS4GP)S4qWoQP5i4g8zbGtranoy6plcZrWnyTWETWJGzThKeR9YAbNyTxEK1YoqTFyT2SuS2lZAjzVDTcBoAW5ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKbAxRPAPSwAWExXHGDulS5ObvZJf)R1S1kLditpq1LhPMKLulS5ObN1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1IsIcWd1hKeR1uTKSZkdXvRzRvkhqMEGk2qtcDijiPMKDwBiUAnvlnyVRcqh1zxBKFyOaYpVwkE3J4YX3ppl0z6bc8i8ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKbAxRPAPSwAWExXHGDulS5ObvZJf)R1S1kLditpq1LhPMKLulS5ObN1AQ2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sTwusuaEO(GKyTMQvkhqMEGQdsIAq)GdnBuRzRvkhqMEGQlpsnjlPgahCBDpdnBulfplwCW0FwCiyh10CeCd(UhXLG3ppl0z6bc8i8ZseWddi)SezoaYpxDjOWwND9zJAsUbQcKbAxRPAPSwAWExXHGDulS5ObvZJf)R1S1kLditpq1LhPMKLulS5ObN1AQwkRT11E8a9tfGoQZU2i)WqHotpqGAjIOAfzoaYpxfGoQZU2i)Wqfijd9zTMTwPCaz6bQU8i1KSKAaCWT19m0rAulf1AQwPCaz6bQoijQb9do0SrTMTwPCaz6bQU8i1KSKAaCWT19m0SrTu8SyXbt)zXHGDutZrWn47Eexo9(5zHotpqGhHFwIaEya5Nfasd27QGbGSF6Pbh)1sbhogmnCaV2Q5XI)1sTwaKgS3vbdaz)0tdo(RLcoCmyA4aETvKSK65XI)1AQwkRLgS3vCiyh1g5hgkG8ZRLiIQLgS3vCiyh1g5hgQajzOpR9xQ12iaQLIAnvlL1sd27Qa0rD21g5hgkG8ZRLiIQLgS3vbOJ6SRnYpmubsYqFw7VuRTraulfplwCW0FwCiyh10CeCd(UhXBfVFEwOZ0de4r4NLiGhgq(zjLditpqvln480Gteqpn44FTeruTuwlasd27QGbGSF6Pbh)1sbhogmnCaV2kqJAnvlasd27QGbGSF6Pbh)1sbhogmnCaV2Q5XI)1(BTainyVRcgaY(PNgC8xlfC4yW0Wb8ARizj1ZJf)RLINfloy6ploeSJA6bpV39iEl69ZZcDMEGapc)Seb8WaYplAWExze4eDbQZUMe6akqJAnvlasd27Qlbf26SRpButYnqfOrTMQfaPb7D1LGcBD21NnQj5gOkqsg6ZA)LATS4GPR4qWoQPh88uOKOa8q9bjXNfloy6ploeSJA6bpV39iUC(9ZZcDMEGapc)Se2m0FwY(SqogT1cBg6Ay)zrd27kXa5qWZd6nAHn7ooua5NBIsAWExXHGDuBKFyOaniIikB9Xd0pvkfdJ8ddeWeL0G9UkaDuNDTr(HHc0GiIezoaYpxHstbFW0vbYaTPGckEwIaEya5Nfasd27Qlbf26SRpButYnqfOrTMQ94b6NIdb7Ogf2PcDMEGa1AQwkRLgS3vaiF20z4Oci)8AjIOAzXbLIA0rsioRLATYwlf1AQwkRfaPb7D1LGcBD21NnQj5gOkqsg6ZAnBTS4GPR4qWoQjHZjCGtfkjkapuFqsSwIiQwrMdG8ZvgborxG6SRjHoGkqsg6ZAjIOAfPu0z)u)Bhq2RLINfloy6ploeSJAs4Cch48DpIlRmF)8SqNPhiWJWplwCW0FwCiyh1KW5eoW5ZcaNIaACW0Fwes6tqsS2ZgRfL0GDaeOwJ8q)G8OwAWEVwEYg1EzTEE1oYjwRrEOFqEuRrKI5ZseWddi)SOb7DLyGCi45b9gvGS4Q1uT0G9UcL0GDaeqBKh6hKhkqJ39iUSY((5zHotpqGhHFwS4GP)S4qWoQjHZjCGZNLWMH(Zs2NLiGhgq(zrd27kXa5qWZd6nQazXvRPAPSwAWExXHGDuBKFyOanQLiIQLgS3vbOJ6SRnYpmuGg1ser1cG0G9U6sqHTo76Zg1KCdufijd9zTMTwwCW0vCiyh1KW5eoWPcLefGhQpijwlfV7rCzL77NNf6m9abEe(zXIdM(ZIdb7OMeoNWboFwcBg6plzFwIaEya5NfnyVRedKdbppO3OcKfxTMQLgS3vIbYHGNh0BuZJf)RLAT0G9Usmqoe88GEJIKLuppw8)DpIlRe((5zHotpqGhHFwa4ueqJdM(ZQLhFC7zTx0U2lRLM9)1siesT9mQvK5ai)8A)Goq(nRLg8QfaK0O2ZgjRf2R9SX2eeyTmDcE1EzTOKgWaFwIaEya5NfnyVRedKdbppO3OcKfxTMQLgS3vIbYHGNh0BubsYqFw7VuRLYAPSwAWExjgihcEEqVrnpw8V2wCTS4GPR4qWoQjHZjCGtfkjkapuFqsSwkQLy12iauKSK1sXZsyZq)zj7ZIfhm9Nfhc2rnjCoHdC(UhXLvo((5zHotpqGhHFwIaEya5NfL1gypWPntpWAjIOABDThu8h6n1srTMQLgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)AnvlnyVR4qWoQnYpmua5NxRPAbqAWExDjOWwND9zJAsUbQaYp)zXIdM(ZYXZgd9HKg48E3J4YkbVFEwOZ0de4r4NLiGhgq(zrd27koeSJAHnhnOAES4FT)sTwPCaz6bQU8i1KSKAHnhn48zXIdM(ZIdb7Ood639iUSYP3ppl0z6bc8i8ZseWddi)SKYbKPhOkbVjea1zxlYCaKF(Swt1sYoRmexT)sTw5Se8SyXbt)znbnWWtP87Eex2wX7NNf6m9abEe(zjc4HbKFw0G9UkahOo76ZoqCQanQ1uT0G9UIdb7OwyZrdQMhl(xRzRvcFwS4GP)S4qWoQPh88E3J4Y2IE)8SqNPhiWJWplwCW0FwCiyh10CeCd(SaWPiGghm9NvlvajnQvyZrdoRf2R9dRTZJrT04i)Q9SXAfPpXqkwlj7CTNDGt7Caul7a1IstbFW0RfoRDEWXO20RvK5ai)8NLiGhgq(z16Adqh7z0GQj0WoD98YGuHotpqGAnvRuoGm9avj4nHaOo7ArMdG8ZN1AQwAWExXHGDulS5ObvZJf)RLAT0G9UIdb7OwyZrdQizj1ZJf)R1uThpq)uCiyh1zqRqNPhiqTMQvK5ai)Cfhc2rDg0QajzOpR9xQ12iaQ1uTKSZkdXv7VuRvolZAnvRiZbq(5kuAk4dMUkqsg6Z39iUSY53ppl0z6bc8i8ZseWddi)Scqh7z0GQj0WoD98YGuHotpqGAnvRuoGm9avj4nHaOo7ArMdG8ZN1AQwAWExXHGDulS5ObvZJf)RLAT0G9UIdb7OwyZrdQizj1ZJf)R1uThpq)uCiyh1zqRqNPhiqTMQvK5ai)Cfhc2rDg0QajzOpR9xQ12iaQ1uTKSZkdXv7VuRvolZAnvRiZbq(5kuAk4dMUkqsg6ZA)TwjuMplwCW0FwCiyh10CeCd(UhXLRmF)8SqNPhiWJWplwCW0FwCiyh10CeCd(SaWPiGghm9NvlvajnQvyZrdoRf2Rnd6AHZAdKbA)Seb8WaYplPCaz6bQsWBcbqD21Imha5NpR1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xRPApEG(P4qWoQZGwHotpqGAnvRiZbq(5koeSJ6mOvbsYqFw7VuRTrauRPAjzNvgIR2FPwRCwM1AQwrMdG8ZvO0uWhmDvGKm0NV7rC5k77NNf6m9abEe(zXIdM(ZIdb7OMMJGBWNfaofb04GP)SA5qWowlH5i4gS2PDcoaQTbDm4XODT0yTNnw7GNxTcEE1M9ApBS2wUvR9d6a53ZseWddi)SOb7Dfhc2rTr(HHc0Owt1sd27koeSJAJ8ddvGKm0N1(l1ABea1AQwAWExXHGDulS5ObvZJf)RLAT0G9UIdb7OwyZrdQizj1ZJf)R1uTuwRiZbq(5kuAk4dMUkqsg6ZAjIOAdqh7z0GkoeSJABoitVTcDMEGa1sX7EexUY99ZZcDMEGapc)SyXbt)zXHGDutZrWn4ZcaNIaACW0FwTCiyhRLWCeCdw70obha12Gog8y0UwAS2ZgRDWZRwbpVAZETNnwRCy2Q1(bDG87zjc4HbKFw0G9UkaDuNDTr(HHc0Owt1sd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)Wqfijd9zT)sT2gbqTMQLgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)AnvlL1kYCaKFUcLMc(GPRcKKH(SwIiQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8UhXLRe((5zHotpqGhHFwS4GP)S4qWoQP5i4g8zbGtranoy6pRwoeSJ1syocUbRDANGdGAPXApBS2bpVAf88Qn71E2yT)KxlP2pOdKF1c71cVAHZA98QfCIa1(bp7ALdZwT2mQTLB1NLiGhgq(zrd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOc0Owt1cG0G9U6sqHTo76Zg1KCdufijd9zT)sT2gbqTMQLgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)39iUCLJVFEwOZ0de4r4Nfloy6ploeSJAAocUbFwa4ueqJdM(ZIq3g9ApBS2JJg8QfoRf61IsIcWdRnyVbRLDGApBmWAHZAjZaR9SzV20XArhjBBETGtSwAocUbRLN1oZ0RLN12obR1MLI1IEc2yxRWMJgCw7L1AdVA5XOw0rsioRf2R9SXAB5qWowlHtsAoair)QDGnOdWr7AHZAXwii0WabEwIaEya5NLuoGm9aviPr(HbcOP5i4gSwt1sd27koeSJAHnhnOAES4FTMLATuwlloOuuJoscXzTTa1kBTuuRPAzXbLIA0rsioR1S1kBTMQLgS3vaiF20z4Oci)839iUCLG3ppl0z6bc8i8ZseWddi)SKYbKPhOcjnYpmqannhb3G1AQwAWExXHGDulS5ObvZJf)R93APb7Dfhc2rTWMJgurYsQNhl(xRPAzXbLIA0rsioR1S1kBTMQLgS3vaiF20z4Oci)8Nfloy6ploeSJAusJroHP)UhXLRC69ZZIfhm9Nfhc2rn9GN3ZcDMEGapc)UhXLBR49ZZcDMEGapc)Seb8WaYplPCaz6bQsWBcbqD21Imha5NpFwS4GP)SqPPGpy6V7rC52IE)8SyXbt)zXHGDutZrWn4ZcDMEGapc)U39S4eF)8iUSVFEwOZ0de4r4NLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTImha5NROb7DnaCkGgdOZrBTijjzhqfid0Uwt1sd27ka4uangqNJ2ArssYoGUh58ua5NxRPAPSwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5Nxlf1AQwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATYSwt1szT0G9UIdb7OwyZrdQMhl(x7VuRvkhqMEGkor9LhPMKLulS5ObN1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUTUNHMnQLIAjIOAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCBDpdnBulf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTuulfplwCW0Fw9iNhDoU39iUCF)8SqNPhiWJWplrapmG8ZIYAdqh7z0Gka4uangqNJ2ArssYoGcDMEGa1AQwrMdG8Zv0G9UgaofqJb05OTwKKKSdOcKbAxRPAPb7DfaCkGgdOZrBTijjzhq3HbQaYpVwt1AeOuDJaqjRQh58OZXvlf1ser1szTbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnv7bjXAPwRmRLINfloy6pRomqn9GN37EexcF)8SqNPhiWJWplrapmG8ZkaDSNrdQAc4C0wdfqXavOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwjuM1AQwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATYSwt1szT0G9UIdb7OwyZrdQMhl(x7VuRvkhqMEGkor9LhPMKLulS5ObN1AQwkRLYApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cva6Oo7AJ8ddvGKm0N1(l1ABea1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUTUNHMnQLIAjIOAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCBDpdnBulf1ser1kYCaKFUIdb7O2i)Wqfijd9zT)sT2gbqTuulfplwCW0Fw9iNN2tP87Eexo((5zHotpqGhHFwIaEya5Nva6ypJgu1eW5OTgkGIbQqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAPwRmR1uTuwlL1szTImha5NRUeuyRZU(Srnj3avbsYqFwRzRvkhqMEGk2qtYsQbWb3w3ZqF5rwRPAPb7Dfhc2rTWMJgunpw8VwQ1sd27koeSJAHnhnOIKLuppw8VwkQLiIQLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwQ1kZAnvlnyVR4qWoQf2C0GQ5XI)1(l1ALYbKPhOItuF5rQjzj1cBoAWzTuulf1AQwAWExfGoQZU2i)WqbKFETu8SyXbt)z1JCEApLYV7rCj49ZZcDMEGapc)SyXbt)zXHGDutcNt4aNplHnd9NLSplrapmG8ZsKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2MdY0BRMhl(x7V1kReuRPAfzoaYpxfmaK9tpn44Vkqsg6ZA)LATs5aY0duzZbz6T1ZJf)1hKeRLy1IsIcWd1hKeR1uTImha5NRUeuyRZU(Srnj3avbsYqFw7VuRvkhqMEGkBoitVTEES4V(GKyTeRwusuaEO(GKyTeRwwCW0vbdaz)0tdo(Rqjrb4H6dsI1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1kLditpqLnhKP3wppw8xFqsSwIvlkjkapuFqsSwIvlloy6QGbGSF6Pbh)vOKOa8q9bjXAjwTS4GPRUeuyRZU(Srnj3avOKOa8q9bjX39iUC69ZZcDMEGapc)Seb8WaYpRa0XEgnOAcnStxpVmivOZ0deOwt1AeOuDJaqjRcLMc(GP)SyXbt)zDjOWwND9zJAsUb(UhXBfVFEwOZ0de4r4NLiGhgq(zfGo2ZObvtOHD665LbPcDMEGa1AQwkR1iqP6gbGswfknf8btVwIiQwJaLQBeakzvxckS1zxF2OMKBG1sXZIfhm9Nfhc2rTr(HX7EeVf9(5zHotpqGhHFwIaEya5N1bjXAnBTsOmR1uTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLgS3vCiyh1cBoAq18yX)A)LATs5aY0duXjQV8i1KSKAHnhn4Swt1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvM1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ12iaEwS4GP)SqPPGpy6V7rC587NNf6m9abEe(zXIdM(ZcLMc(GP)SG(HraACAy)zrd27Qj0WoD98YGunpw8NknyVRMqd701ZldsfjlPEES4)Zc6hgbOXPHKKiaKp8zj7ZseWddi)SoijwRzRvcLzTMQnaDSNrdQMqd701Zldsf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwl1ALzTMQLYAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAnBTs5aY0duXgAswsnao426Eg6lpYAnvlnyVR4qWoQf2C0GQ5XI)1sTwAWExXHGDulS5ObvKSK65XI)1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwzwRPAPb7Dfhc2rTWMJgunpw8V2FPwRuoGm9avCI6lpsnjlPwyZrdoRLIAPOwt1sd27Qa0rD21g5hgkG8ZRLI39iUSY89ZZcDMEGapc)Seb8WaYplkRvK5ai)Cfhc2rTr(HHkqsg6ZAnBTYrjOwIiQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1kH1srTMQvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRmR1uTuwlnyVR4qWoQf2C0GQ5XI)1(l1ALYbKPhOItuF5rQjzj1cBoAWzTMQLYAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)sT2gbqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTsqTuulrevlL126ApEG(Pcqh1zxBKFyOqNPhiqTMQvK5ai)Cfhc2rTr(HHkqsg6ZAnBTsqTuulrevRiZbq(5koeSJAJ8ddvGKm0N1(l1ABea1srTu8SyXbt)zrcJiJPo76lds0V39iUSY((5zHotpqGhHFwIaEya5NLiZbq(5Qlbf26SRpButYnqvGKm0N1(BTOKOa8q9bjXAnvlL1szThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUkaDuNDTr(HHkqsg6ZA)LATncGAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhO6YJutYsQbWb3w3ZqZg1srTeruTuwBRR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvCiyh1g5hgQajzOpR1S1kLditpq1LhPMKLudGdUTUNHMnQLIAjIOAfzoaYpxXHGDuBKFyOcKKH(S2FPwBJaOwkEwS4GP)ScgaY(PNgC8)DpIlRCF)8SqNPhiWJWplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)TwusuaEO(GKyTMQLYAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAnBTs5aY0duXgAswsnao426Eg6lpYAnvlnyVR4qWoQf2C0GQ5XI)1sTwAWExXHGDulS5ObvKSK65XI)1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwzwRPAPb7Dfhc2rTWMJgunpw8V2FPwRuoGm9avCI6lpsnjlPwyZrdoRLIAPOwt1sd27Qa0rD21g5hgkG8ZRLINfloy6pRGbGSF6Pbh)F3J4YkHVFEwOZ0de4r4NLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zTuRvM1AQwkRLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqfBOjzj1a4GBR7zOV8iR1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xlf1ser1szTImha5NRUeuyRZU(Srnj3avbsYqFwl1ALzTMQLgS3vCiyh1cBoAq18yX)A)LATs5aY0duXjQV8i1KSKAHnhn4SwkQLIAnvlnyVRcqh1zxBKFyOaYpVwkEwS4GP)Saq(SPZWX39iUSYX3ppl0z6bc8i8ZseWddi)SOSwAWExXHGDulS5ObvZJf)R9xQ1kLditpqfNO(YJutYsQf2C0GZAjIOAncuQUraOKvfmaK9tpn44FTuuRPAPSwkR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7VuRTrauRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRuoGm9avxEKAswsnao426EgA2OwkQLiIQLYABDThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwPCaz6bQU8i1KSKAaCWT19m0SrTuulrevRiZbq(5koeSJAJ8ddvGKm0N1(l1ABea1sXZIfhm9N1LGcBD21NnQj5g47Eexwj49ZZcDMEGapc)Seb8WaYplkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwZwRuoGm9avSHMKLudGdUTUNH(YJSwt1sd27koeSJAHnhnOAES4FTuRLgS3vCiyh1cBoAqfjlPEES4FTuulrevlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTuRvM1AQwAWExXHGDulS5ObvZJf)R9xQ1kLditpqfNO(YJutYsQf2C0GZAPOwkQ1uT0G9UkaDuNDTr(HHci)8Nfloy6ploeSJAJ8dJ39iUSYP3ppl0z6bc8i8ZseWddi)SOb7Dva6Oo7AJ8ddfq(51AQwkRLYAfzoaYpxDjOWwND9zJAsUbQcKKH(SwZwRCLzTMQLgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)APOwIiQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRmR1uT0G9UIdb7OwyZrdQMhl(x7VuRvkhqMEGkor9LhPMKLulS5ObN1srTuuRPAPSwrMdG8ZvCiyh1g5hgQajzOpR1S1kRCRLiIQfaPb7D1LGcBD21NnQj5gOc0OwkEwS4GP)Scqh1zxBKFy8UhXLTv8(5zHotpqGhHFwIaEya5NLiZbq(5koeSJ6mOvbsYqFwRzRvcQLiIQT11E8a9tXHGDuNbTcDMEGaplwCW0FwtBy)GEJ2i)W4DpIlBl69ZZcDMEGapc)Seb8WaYplrkfD2p1)2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1sd27koeSJAJ8ddfOrTMQfaPb7DvWaq2p90GJ)APGdhdMgoGxB18yX)APwRCSwt1AeOuDJaqjRIdb7Ood6AnvlloOuuJoscXzT)wBR4zXIdM(ZIdb7OMEWZ7DpIlRC(9ZZcDMEGapc)Seb8WaYplrkfD2p1)2bK9AnvBa6ypJguXHGDuBZbz6TvOZ0deOwt1sd27koeSJAJ8ddfOrTMQfaPb7DvWaq2p90GJ)APGdhdMgoGxB18yX)APwRC8zXIdM(ZIdb7OMMJGBW39iUCL57NNf6m9abEe(zjc4HbKFwIuk6SFQ)Tdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLgS3vCiyh1g5hgkqJAnvlL1cKNkyai7NEAWXFvGKm0N1A2ALt1ser1cG0G9Ukyai7NEAWXFTuWHJbtdhWRTc0OwkQ1uTainyVRcgaY(PNgC8xlfC4yW0Wb8ARMhl(x7V1khR1uTS4Gsrn6ijeN1sTwj8zXIdM(ZIdb7OMEWZ7DpIlxzF)8SqNPhiWJWplrapmG8ZsKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8VwQ1kHplwCW0FwCiyh1zq)UhXLRCF)8SqNPhiWJWplrapmG8ZsKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8VwQ1k3Nfloy6ploeSJAAocUbF3J4YvcF)8SqNPhiWJWplrapmG8ZsKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAncuQUraOKRkyai7NEAWX)AnvlloOuuJoscXzTMTwj8zXIdM(ZIdb7OgL0yKty6V7rC5khF)8SqNPhiWJWplrapmG8ZsKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQ1uT0G9UIdb7O2i)WqbAuRPAbqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8VwQ1kBTMQLfhukQrhjH4SwZwRe(SyXbt)zXHGDuJsAmYjm939iUCLG3ppl0z6bc8i8ZseWddi)SOb7DfaYNnDgoQanQ1uTainyVRUeuyRZU(Srnj3avGg1AQwaKgS3vxckS1zxF2OMKBGQajzOpR9xQ1sd27kJaNOlqD21KqhqrYsQNhl(xBlUwwCW0vCiyh10dEEkusuaEO(GKyTMQLYAPS2JhOFQaNPZUavOZ0deOwt1YIdkf1OJKqCw7V1khRLIAjIOAzXbLIA0rsioR93ALGAPOwt1szTTU2a0XEgnOIdb7OMojP5aGe9tHotpqGAjIOApoAWtzJ84SvgIRwZwRekb1sXZIfhm9NLrGt0fOo7AsOd8UhXLRC69ZZcDMEGapc)Seb8WaYplAWExbG8ztNHJkqJAnvlL1szThpq)ubotNDbQqNPhiqTMQLfhukQrhjH4S2FRvowlf1ser1YIdkf1OJKqCw7V1kb1srTMQLYABDTbOJ9mAqfhc2rnDssZbaj6NcDMEGa1ser1EC0GNYg5XzRmexTMTwjucQLINfloy6ploeSJA6bpV39iUCBfVFEwS4GP)SMGgy4Pu(zHotpqGhHF3J4YTf9(5zHotpqGhHFwIaEya5NfnyVR4qWoQf2C0GQ5XI)1AwQ1szTS4Gsrn6ijeN12cuRS1srTMQnaDSNrdQ4qWoQPtsAoair)uOZ0deOwt1EC0GNYg5XzRmexT)wRekbplwCW0FwCiyh10CeCd(UhXLRC(9ZZcDMEGapc)Seb8WaYplAWExXHGDulS5ObvZJf)RLAT0G9UIdb7OwyZrdQizj1ZJf)FwS4GP)S4qWoQP5i4g8DpIlHY89ZZcDMEGapc)Seb8WaYplAWExXHGDulS5ObvZJf)RLATYSwt1szTImha5NR4qWoQnYpmubsYqFwRzRvwjOwIiQ2wxlL1ksPOZ(P(3oGSxRPAdqh7z0GkoeSJABoitVTcDMEGa1srTu8SyXbt)zXHGDuNb97EexcL99ZZcDMEGapc)Seb8WaYplkRnWEGtBMEG1ser126ApO4p0BQLIAnvlnyVR4qWoQf2C0GQ5XI)1sTwAWExXHGDulS5ObvKSK65XI)plwCW0FwoE2yOpK0aN37EexcL77NNf6m9abEe(zjc4HbKFw0G9Usmqoe88GEJkqwC1AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTMQLYAPS2JhOFkM0ya7qbFW0vOZ0deOwt1YIdkf1OJKqCw7V12IQLIAjIOAzXbLIA0rsioR93ALGAP4zXIdM(ZIdb7OMeoNWboF3J4sOe((5zHotpqGhHFwIaEya5NfnyVRedKdbppO3OcKfxTMQ94b6NIdb7Ogf2PcDMEGa1AQwaKgS3vxckS1zxF2OMKBGkqJAnvlL1E8a9tXKgdyhk4dMUcDMEGa1ser1YIdkf1OJKqCw7V1kNRLINfloy6ploeSJAs4Cch48DpIlHYX3ppl0z6bc8i8ZseWddi)SOb7DLyGCi45b9gvGS4Q1uThpq)umPXa2Hc(GPRqNPhiqTMQLfhukQrhjH4S2FRvo(SyXbt)zXHGDutcNt4aNV7rCjucE)8SqNPhiWJWplrapmG8ZIgS3vCiyh1cBoAq18yX)A)TwAWExXHGDulS5ObvKSK65XI)plwCW0FwCiyh1OKgJCct)DpIlHYP3ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTWMJgunpw8VwQ1sd27koeSJAHnhnOIKLuppw8Vwt1AeOuDJaqjRIdb7OMMJGBWNfloy6ploeSJAusJroHP)UhXLWwX7NNf0pmcqJtd7pls2zLH4ml1wKe8SG(HraACAijjca5dFwY(SyXbt)zHstbFW0FwOZ0de4r439UNfa2zWX9(5rCzF)8SyXbt)zjsq)WyAGJXZcDMEGapc)UhXL77NNf6m9abEe(zjc4HbKFwuw7Xd0pf6dyJ9HocOqNPhiqTMQLKDwziUA)LATTizwRPAjzNvgIRwZsTw5Keulf1ser1szTTU2JhOFk0hWg7dDeqHotpqGAnvlj7SYqC1(l1ABrsqTu8SyXbt)zrYoRBqY39iUe((5zHotpqGhHFwIaEya5NfnyVR4qWoQnYpmuGgplwCW0Fwg5bt)DpIlhF)8SqNPhiWJWplrapmG8ZkaDSNrdQoK0idEO)4WqHotpqGAnvlnyVRqjTzW5btxbAuRPAPSwrMdG8ZvCiyh1g5hgQazG21ser1sNZzTMQTdBSpDGKm0N1(l1ALJYSwkEwS4GP)SoijQ)4W4DpIlbVFEwOZ0de4r4NLiGhgq(zrd27koeSJAJ8ddfq(51AQwAWExfGoQZU2i)WqbKFETMQfaPb7D1LGcBD21NnQj5gOci)8Nfloy6pRbSX(M6wAqGgs0V39iUC69ZZcDMEGapc)Seb8WaYplAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5N)SyXbt)zrZn6SRVak(pF3J4TI3ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTr(HHc04zXIdM(ZIgJjg)HEZ7EeVf9(5zHotpqGhHFwIaEya5NfnyVR4qWoQnYpmuGgplwCW0Fw0Jmb0DWO97Eexo)(5zHotpqGhHFwIaEya5NfnyVR4qWoQnYpmuGgplwCW0FwDyG0JmbE3J4YkZ3ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTr(HHc04zXIdM(ZIDboVGhAbpgV7rCzL99ZZcDMEGapc)Seb8WaYplAWExXHGDuBKFyOanEwS4GP)SaNOgEi58DpIlRCF)8SqNPhiWJWplwCW0FwndgaYxgtnnd0GplrapmG8ZIgS3vCiyh1g5hgkqJAjIOAfzoaYpxXHGDuBKFyOcKKH(SwZsTwjqcQ1uTainyVRUeuyRZU(Srnj3avGgplS3rXPDMeFwndgaYxgtnnd0GV7rCzLW3ppl0z6bc8i8ZIfhm9NfsA0oqEOZaWzxGplrapmG8ZsK5ai)Cfhc2rTr(HHkqsg6ZA)LATuwRSsyTeR2wrTT4ALYbKPhOIn0PRbNyTuuRPAfzoaYpxDjOWwND9zJAsUbQcKKH(S2FPwlL1kRewlXQTvuBlUwPCaz6bQydD6AWjwlfplNjXNfsA0oqEOZaWzxGV7rCzLJVFEwOZ0de4r4Nfloy6plGazGomqTuCoXXZseWddi)SezoaYpxXHGDuBKFyOcKKH(SwZsTw5kZAjIOABDTs5aY0duXg601GtSwQ1kBTeruTuw7bjXAPwRmR1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQnaDSNrdQMqd701Zldsf6m9abQLINLZK4ZciqgOddulfNtC8UhXLvcE)8SqNPhiWJWplwCW0FwZeCOHno8W4zjc4HbKFwImha5NR4qWoQnYpmubsYqFwRzPwRekZAjIOABDTs5aY0duXg601GtSwQ1k7ZYzs8zntWHg24WdJ39iUSYP3ppl0z6bc8i8ZIfhm9NvZOTHTo7AEoHKWbFW0FwIaEya5NLiZbq(5koeSJAJ8ddvGKm0N1AwQ1kxzwlrevBRRvkhqMEGk2qNUgCI1sTwzRLiIQLYApijwl1ALzTMQvkhqMEGQoCAd9gDAGog1sTwzR1uTbOJ9mAq1eAyNUEEzqQqNPhiqTu8SCMeFwnJ2g26SR55esch8bt)DpIlBR49ZZcDMEGapc)SyXbt)zrYcMoq90gXttcoHINLiGhgq(zjYCaKFUIdb7O2i)Wqfijd9zT)sTwjOwt1szTTUwPCaz6bQ6WPn0B0Pb6yul1ALTwIiQ2dsI1A2ALqzwlfplNjXNfjly6a1tBepnj4ekE3J4Y2IE)8SqNPhiWJWplwCW0FwKSGPdupTr80KGtO4zjc4HbKFwImha5NR4qWoQnYpmubsYqFw7VuRvcQ1uTs5aY0du1HtBO3Otd0XOwQ1kBTMQLgS3vbOJ6SRnYpmuGg1AQwAWExfGoQZU2i)Wqfijd9zT)sTwkRvwzwBlqTsqTT4Adqh7z0GQj0WoD98YGuHotpqGAPOwt1EqsS2FRvcL5ZYzs8zrYcMoq90gXttcoHI39iUSY53ppl0z6bc8i8ZIfhm9NLGhdnloy66bCEpRbCEANjXNLGhcWbFW0NV7rC5kZ3ppl0z6bc8i8ZseWddi)SyXbLIA0rsioR1SuRvkhqMEGkor9XrdEArc63ZAEbuCpIl7ZIfhm9NLGhdnloy66bCEpRbCEANjXNfN47EexUY((5zHotpqGhHFwIaEya5NLiLIo7N6F7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bc8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zzZbz6TF3J4YvUVFEwOZ0de4r4NLiGhgq(zjLditpqLnlf1Pb6iqTuRvM1AQwPCaz6bQ6WPn0B0Pb6yuRPABDTuwRiLIo7N6F7aYETMQnaDSNrdQ4qWoQT5Gm92k0z6bculfplwCW0FwcEm0S4GPRhW59SgW5PDMeFwD40g6n60aDmE3J4YvcF)8SqNPhiWJWplrapmG8ZskhqMEGkBwkQtd0rGAPwRmR1uTTUwkRvKsrN9t9VDazVwt1gGo2ZObvCiyh12CqMEBf6m9abQLINfloy6plbpgAwCW01d48Ewd480otIpR0aDmE3J4Yvo((5zHotpqGhHFwIaEya5NvRRLYAfPu0z)u)Bhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAP4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZsK5ai)857EexUsW7NNf6m9abEe(zjc4HbKFws5aY0du1Hop00GHxl1ALzTMQT11szTIuk6SFQ)Tdi71AQ2a0XEgnOIdb7O2MdY0BRqNPhiqTu8SyXbt)zj4XqZIdMUEaN3ZAaNN2zs8zf5Xhm939iUCLtVFEwOZ0de4r4NLiGhgq(zjLditpqvh68qtdgETuRv2AnvBRRLYAfPu0z)u)Bhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAP4zXIdM(ZsWJHMfhmD9aoVN1aopTZK4ZQdDEOPbd)DV7zzeOijP579ZJ4Y((5zXIdM(ZIdb7Og6hogO4EwOZ0de4r439iUCF)8SyXbt)znbjjtxZHGDu3zs4aYXZcDMEGapc)UhXLW3pplwCW0FwI0BPbdutYoRBqYNf6m9abEe(DpIlhF)8SqNPhiWJWpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXjQpoAWtlsq)EwayNbh3ZscF3J4sW7NNf6m9abEe(zLgpRaN49SyXbt)zjLditpWNLuo0otIpluAQne3Zca7m44EwYkbV7rC507NNf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLdTZK4ZYiqdWXqJsZNLiGhgq(zrzTbOJ9mAq1eAyNUEEzqQqNPhiqTMQLYAfPu0z)usr)SBh1ser1ksPOZ(PCue5idGAjIOAfPdacpfhc2rTrKaWM2k0z6bculf1sXZskparnoM4ZsMplP8aeFwY(UhXBfVFEwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuo0otIplBwkQtd0rGNLiGhgq(zXIdkf1OJKqCwRzPwRuoGm9avCI6JJg80Ie0VNLuEaIACmXNLmFws5bi(SK9DpI3IE)8SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwY8zjLdTZK4ZQdDEOPbd)DpIlNF)8SqNPhiWJWpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zzZbz6T1ZJf)1hKeFwayNbh3Zso)UhXLvMVFEwOZ0de4r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(S4Xh3EQNTDHwK5ai)85Zca7m44EwY8DpIlRSVFEwOZ0de4r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SIPMKLudGdUTUNH(YJ8zbGDgCCplj4DpIlRCF)8SqNPhiWJWpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zftnjlPgahCBDpdDKgplaSZGJ7zjbV7rCzLW3ppl0z6bc8i8ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwXutYsQbWb3w3ZqZgplaSZGJ7zjxz(UhXLvo((5zHotpqGhHFwPXZkWjEplwCW0Fws5aY0d8zjLdTZK4ZImpTrGceb0xEKA62plaSZGJ7z1IE3J4YkbVFEwOZ0de4r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(SiZttYsQbWb3w3ZqF5r(SaWodoUNLSY8DpIlRC69ZZcDMEGapc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfzEAswsnao426EgA24zbGDgCCplzLG39iUSTI3ppl0z6bc8i8ZknEwboX7zXIdM(ZskhqMEGplPCODMeFwSHMKLudGdUTUNH(YJ8zjc4HbKFwI0baHNIdb7O2isayt7NLuEaIACmXNLSY8zjLhG4ZscL57Eex2w07NNf6m9abEe(zLgpRaN49SyXbt)zjLditpWNLuo0otIpl2qtYsQbWb3w3ZqF5r(SaWodoUNLSY8DpIlRC(9ZZcDMEGapc)SsJNvGt8EwS4GP)SKYbKPh4ZskhANjXNfBOjzj1a4GBR7zOjZ7zbGDgCCpl5kZ39iUCL57NNf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZsUYS2wGAPSwjO2wCTI0baHNIdb7O2isaytBf6m9abQLINLuo0otIpRin0KSKAaCWT19m0xEKV7rC5k77NNf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZscQLy1kxzwBlUwkRvKsrN9t5Wg7t3zSwIiQwkRvKoai8uCiyh1grcaBARqNPhiqTMQLfhukQrhjH4S2FRvkhqMEGkor9XrdEArc6xTuulf1sSALvcQTfxlL1ksPOZ(P(3oGSxRPAdqh7z0GkoeSJABoitVTcDMEGa1AQwwCqPOgDKeIZAnl1ALYbKPhOItuFC0GNwKG(vlfplPCODMeFwxEKAswsnao426EgA24DpIlx5((5zHotpqGhHFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SKRmRTfOwkRTfvBlUwr6aGWtXHGDuBejaSPTcDMEGa1sXZskhANjXN1LhPMKLudGdUTUNHosJ39iUCLW3ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLCsM12culL1sYZdJ2AP8aeRTfxRSYuM1sXZseWddi)SePu0z)uoSX(0DgFws5q7mj(SO5i4gutYoRne37EexUYX3ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLCwcQTfOwkRLKNhgT1s5biwBlUwzLPmRLINLiGhgq(zjsPOZ(P(3oGS)SKYH2zs8zrZrWnOMKDwBiU39iUCLG3ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNvlsM12culL1sYZdJ2AP8aeRTfxRSYuM1sXZseWddi)SKYbKPhOIMJGBqnj7S2qC1sTwz(SKYH2zs8zrZrWnOMKDwBiU39iUCLtVFEwOZ0de4r4NvA8ScCI3ZIfhm9NLuoGm9aFws5q7mj(Sydnj0HKGKAs2zTH4EwayNbh3Zswj4DpIl3wX7NNf6m9abEe(zLgpRaN49SyXbt)zjLditpWNLuo0otIpRlpsnjlPwyZrdoFwayNbh3ZsUV7rC52IE)8SqNPhiWJWpR04zf4eVNfloy6plPCaz6b(SKYH2zs8zXjQV8i1KSKAHnhn48zbGDgCCpl5(UhXLRC(9ZZcDMEGapc)SsJN1eVNfloy6plPCaz6b(SKYdq8zjBTT4APSwSfccnmqafsA0oqEOZaWzxG1ser1szThpq)ubOJ6SRnYpmuOZ0deOwt1szThpq)uCiyh1OWovOZ0deOwIiQ2wxRiLIo7N6F7aYETuuRPAPS2wxRiLIo7NYrrKJmaQLiIQLfhukQrhjH4SwQ1kBTeruTbOJ9mAq1eAyNUEEzqQqNPhiqTuuRPABDTIuk6SFkPOF2TJAPOwkEws5q7mj(S6WPn0B0Pb6y8UhXLqz((5zHotpqGhHFwPXZAI3ZIfhm9NLuoGm9aFws5bi(SWwii0WabuKSGPdupTr80KGtOOwIiQwSfccnmqavZGbG8LXutZanyTeruTyleeAyGaQMbda5lJPMeb4XaMETeruTyleeAyGakao(tMPRbqXFTb4f4uGUaRLiIQfBHGqddeqb9PiapMEG6wii7hiPgaLcfyTeruTyleeAyGaQzcog4DqVrhG0TRLiIQfBHGqddeqnbD6rMaAMep72ZRwIiQwSfccnmqa1h)hDmM6EKoqTeruTyleeAyGaQ(GjrD2108Dd8zjLdTZK4ZIn0PRbN47EexcL99ZZIfhm9NfjmIm0qsUbFwOZ0de4r439iUek33ppl0z6bc8i8ZseWddi)SePu0z)u)Bhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGAnvRiDaq4P4qWoQnIea20wHotpqGAnvRuoGm9av84JBp1Z2UqlYCaKF(8zXIdM(ZkaDuNDTr(HX7EexcLW3ppl0z6bc8i8ZseWddi)SADTs5aY0duzeOb4yOrPzTuRv2AnvBa6ypJgubaNcOXa6C0wlsss2buOZ0de4zXIdM(ZQh58OZX9UhXLq547NNf6m9abEe(zjc4HbKFwTUwPCaz6bQmc0aCm0O0SwQ1kBTMQT11gGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTuwBRRvKsrN9tjf9ZUDulrevRuoGm9avD40g6n60aDmQLINfloy6ploeSJA6bpV39iUekbVFEwOZ0de4r4NLiGhgq(z16ALYbKPhOYiqdWXqJsZAPwRS1AQ2wxBa6ypJgubaNcOXa6C0wlsss2buOZ0deOwt1ksPOZ(PKI(z3oQ1uTTUwPCaz6bQ6WPn0B0Pb6y8SyXbt)zrcJiJPo76lds0V39iUekNE)8SqNPhiWJWplrapmG8ZskhqMEGkJanahdnknRLATY(SyXbt)zHstbFW0F37EwImha5NpF)8iUSVFEwOZ0de4r4Nfloy6pREKZt7Pu(zbGtranoy6pRwnGzapiHgSwWj0BQTjGZr7AHcOyG1(bp7AzdvTTGtSw4v7h8SR9YJS28SX4dor1ZseWddi)Scqh7z0GQMaohT1qbumqf6m9abQ1uTImha5NR4qWoQnYpmubsYqFwRzRvcLzTMQvK5ai)C1LGcBD21NnQj5gOkqgODTMQLYAPb7Dfhc2rTWMJgunpw8V2FPwRuoGm9avxEKAswsTWMJgCwRPAPSwkR94b6NkaDuNDTr(HHcDMEGa1AQwrMdG8ZvbOJ6SRnYpmubsYqFw7VuRTrauRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRuoGm9avxEKAswsnao426EgA2OwkQLiIQLYABDThpq)ubOJ6SRnYpmuOZ0deOwt1kYCaKFUIdb7O2i)Wqfijd9zTMTwPCaz6bQU8i1KSKAaCWT19m0SrTuulrevRiZbq(5koeSJAJ8ddvGKm0N1(l1ABea1srTu8UhXL77NNf6m9abEe(zjc4HbKFwbOJ9mAqvtaNJ2AOakgOcDMEGa1AQwrMdG8ZvCiyh1g5hgQazG21AQwkRT11E8a9tH(a2yFOJak0z6bculrevlL1E8a9tH(a2yFOJak0z6bcuRPAjzNvgIRwZsT2wHmRLIAPOwt1szTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1A2ALvM1AQwAWExXHGDulS5ObvZJf)RLAT0G9UIdb7OwyZrdQizj1ZJf)RLIAjIOAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATYSwt1sd27koeSJAHnhnOAES4FTuRvM1srTuuRPAPb7Dva6Oo7AJ8ddfq(51AQws2zLH4Q1SuRvkhqMEGk2qtcDijiPMKDwBiUNfloy6pREKZt7Pu(DpIlHVFEwOZ0de4r4NLiGhgq(zfGo2ZObvaWPaAmGohT1IKKKDaf6m9abQ1uTImha5NROb7DnaCkGgdOZrBTijjzhqfid0Uwt1sd27ka4uangqNJ2ArssYoGUh58ua5NxRPAPSwAWExXHGDuBKFyOaYpVwt1sd27Qa0rD21g5hgkG8ZR1uTainyVRUeuyRZU(Srnj3ava5Nxlf1AQwrMdG8ZvxckS1zxF2OMKBGQajzOpRLATYSwt1szT0G9UIdb7OwyZrdQMhl(x7VuRvkhqMEGQlpsnjlPwyZrdoR1uTuwlL1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9xQ12iaQ1uTImha5NR4qWoQnYpmubsYqFwRzRvkhqMEGQlpsnjlPgahCBDpdnBulf1ser1szTTU2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRuoGm9avxEKAswsnao426EgA2OwkQLiIQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATncGAPOwkEwS4GP)S6rop6CCV7rC547NNf6m9abEe(zjc4HbKFwbOJ9mAqfaCkGgdOZrBTijjzhqHotpqGAnvRiZbq(5kAWExdaNcOXa6C0wlsss2bubYaTR1uT0G9UcaofqJb05OTwKKKSdO7Wava5NxRPAncuQUraOKv1JCE054EwS4GP)S6Wa10dEEV7rCj49ZZcDMEGapc)SyXbt)zrcJiJPo76lds0VNfaofb04GP)SAvgg12sYFQ9dE212YTATWETWJGzTIKe6n1cAu7mtxvBRSxl8Q9dog1sJ1corGA)GNDT)KxlX8Af88QfE1ohWg7B0UwASNb(Seb8WaYplrMdG8ZvxckS1zxF2OMKBGQajzOpR93ALYbKPhOImpTrGceb0xEKA621ser1szTs5aY0duDqsud6hCOzJAnBTs5aY0durMNMKLudGdUTUNHMnQ1uTImha5NRUeuyRZU(Srnj3avbsYqFwRzRvkhqMEGkY80KSKAaCWT19m0xEK1sX7Eexo9(5zHotpqGhHFwIaEya5NLiZbq(5koeSJAJ8ddvGmq7AnvlL126ApEG(PqFaBSp0raf6m9abQLiIQLYApEG(PqFaBSp0raf6m9abQ1uTKSZkdXvRzPwBRqM1srTuuRPAPSwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAnBTs5aY0duXgAswsnao426Eg6lpYAnvlnyVR4qWoQf2C0GQ5XI)1sTwAWExXHGDulS5ObvKSK65XI)1srTeruTuwRiZbq(5Qlbf26SRpButYnqvGKm0N1sTwzwRPAPb7Dfhc2rTWMJgunpw8VwQ1kZAPOwkQ1uT0G9UkaDuNDTr(HHci)8Anvlj7SYqC1AwQ1kLditpqfBOjHoKeKutYoRne3ZIfhm9NfjmImM6SRVmir)E3J4TI3ppl0z6bc8i8ZIfhm9NfaYNnDgo(SaWPiGghm9Nvlp(42ZAbNyTaiF20z4yTFWZUw2qvBRSx7LhzTWzTbYaTRLN1(HJH51sY)XANGbw7L1k45vl8QLg7zG1E5rQEwIaEya5NLiZbq(5Qlbf26SRpButYnqvGmq7AnvlnyVR4qWoQf2C0GQ5XI)1(l1ALYbKPhO6YJutYsQf2C0GZAnvRiZbq(5koeSJAJ8ddvGKm0N1(l1ABeaV7r8w07NNf6m9abEe(zjc4HbKFwImha5NR4qWoQnYpmubYaTR1uTuwBRR94b6Nc9bSX(qhbuOZ0deOwIiQwkR94b6Nc9bSX(qhbuOZ0deOwt1sYoRmexTMLATTczwlf1srTMQLYAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kRmR1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xlf1ser1szTImha5NRUeuyRZU(Srnj3avbYaTR1uT0G9UIdb7OwyZrdQMhl(xl1ALzTuulf1AQwAWExfGoQZU2i)WqbKFETMQLKDwziUAnl1ALYbKPhOIn0KqhscsQjzN1gI7zXIdM(Zca5ZModhF3J4Y53ppl0z6bc8i8ZIfhm9NvWaq2p90GJ)plaCkcOXbt)z1coXANgC8VwyV2lpYAzhOw2OwoWAtVwbqTSdu7x6eC1sJ1cAuBpJAhP3GrTNn71E2yTKSK1cGdUT51sY)HEtTtWaR9dR1MLI1YxTdKNxT3xwlhc2XAf2C0GZAzhO2ZMVAV8iR9JNobxTT0GZRwWjcOEwIaEya5NLiZbq(5Qlbf26SRpButYnqvGKm0N1A2ALYbKPhOkMAswsnao426Eg6lpYAnvRiZbq(5koeSJAJ8ddvGKm0N1A2ALYbKPhOkMAswsnao426EgA2Owt1szThpq)ubOJ6SRnYpmuOZ0deOwt1szTImha5NRcqh1zxBKFyOcKKH(S2FRfLefGhQpijwlrevRiZbq(5Qa0rD21g5hgQajzOpR1S1kLditpqvm1KSKAaCWT19m0rAulf1ser126ApEG(Pcqh1zxBKFyOqNPhiqTuuRPAPb7Dfhc2rTWMJgunpw8VwZwRCR1uTainyVRUeuyRZU(Srnj3ava5NxRPAPb7Dva6Oo7AJ8ddfq(51AQwAWExXHGDuBKFyOaYp)DpIlRmF)8SqNPhiWJWplwCW0Fwbdaz)0tdo()SaWPiGghm9Nvl4eRDAWX)A)GNDTSrTF2OxRroNq6bQQTv2R9YJSw4S2azG21YZA)WXW8Aj5)yTtWaR9YAf88QfE1sJ9mWAV8ivplrapmG8ZsK5ai)C1LGcBD21NnQj5gOkqsg6ZA)TwusuaEO(GKyTMQLgS3vCiyh1cBoAq18yX)A)LATs5aY0duD5rQjzj1cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)TwkRfLefGhQpijwlXQLfhmD1LGcBD21NnQj5gOcLefGhQpijwlfV7rCzL99ZZcDMEGapc)Seb8WaYplrMdG8ZvCiyh1g5hgQajzOpR93Arjrb4H6dsI1AQwkRLYABDThpq)uOpGn2h6iGcDMEGa1ser1szThpq)uOpGn2h6iGcDMEGa1AQws2zLH4Q1SuRTviZAPOwkQ1uTuwlL1kYCaKFU6sqHTo76Zg1KCdufijd9zTMTwPCaz6bQydnjlPgahCBDpd9LhzTMQLgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)APOwIiQwkRvK5ai)C1LGcBD21NnQj5gOkqsg6ZAPwRmR1uT0G9UIdb7OwyZrdQMhl(xl1ALzTuulf1AQwAWExfGoQZU2i)WqbKFETMQLKDwziUAnl1ALYbKPhOIn0KqhscsQjzN1gIRwkEwS4GP)ScgaY(PNgC8)DpIlRCF)8SqNPhiWJWplwCW0FwxckS1zxF2OMKBGplaCkcOXbt)z1coXAV8iR9dE21Yg1c71cpcM1(bpBOx7zJ1sYswlao42QABL9A98mVwWjw7h8SRnsJAH9ApBS2JhOF1cN1E8F0nVw2bQfEemR9dE2qV2ZgRLKLSwaCWTvplrapmG8ZIgS3vCiyh1cBoAq18yX)A)LATs5aY0duD5rQjzj1cBoAWzTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATOKOa8q9bjXAnvlj7SYqC1A2ALYbKPhOIn0KqhscsQjzN1gIRwt1sd27Qa0rD21g5hgkG8ZF3J4YkHVFEwOZ0de4r4NLiGhgq(zrd27koeSJAHnhnOAES4FT)sTwPCaz6bQU8i1KSKAHnhn4Swt1E8a9tfGoQZU2i)WqHotpqGAnvRiZbq(5Qa0rD21g5hgQajzOpR9xQ1IsIcWd1hKeR1uTs5aY0duDqsud6hCOzJAnBTs5aY0duD5rQjzj1a4GBR7zOzJNfloy6pRlbf26SRpButYnW39iUSYX3ppl0z6bc8i8ZseWddi)SOb7Dfhc2rTWMJgunpw8V2FPwRuoGm9avxEKAswsTWMJgCwRPAPS2wx7Xd0pva6Oo7AJ8ddf6m9abQLiIQvK5ai)Cva6Oo7AJ8ddvGKm0N1A2ALYbKPhO6YJutYsQbWb3w3ZqhPrTuuRPALYbKPhO6GKOg0p4qZg1A2ALYbKPhO6YJutYsQbWb3w3ZqZgplwCW0FwxckS1zxF2OMKBGV7rCzLG3ppl0z6bc8i8ZIfhm9Nfhc2rTr(HXZcaNIaACW0FwTGtSw2OwyV2lpYAHZAtVwbqTSdu7x6eC1sJ1cAuBpJAhP3GrTNn71E2yTKSK1cGdUT51sY)HEtTtWaR9S5R2pSwBwkwl6jyJDTKSZ1YoqTNnF1E2yG1cN165vlpcKbAxlxBa6yTzVwJ8dJAbYpx9Seb8WaYplrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqfBOjzj1a4GBR7zOV8iR1uTuwBRRvKsrN9tjf9ZUDulrevRiZbq(5ksyezm1zxFzqI(PcKKH(SwZwRuoGm9avSHMKLudGdUTUNHMmVAPOwt1sd27koeSJAHnhnOAES4FTuRLgS3vCiyh1cBoAqfjlPEES4FTMQLgS3vbOJ6SRnYpmua5NxRPAjzNvgIRwZsTwPCaz6bQydnj0HKGKAs2zTH4E3J4YkNE)8SqNPhiWJWplwCW0FwbOJ6SRnYpmEwa4ueqJdM(ZQfCI1gPrTWETxEK1cN1METcGAzhO2V0j4QLgRf0O2Eg1osVbJApB2R9SXAjzjRfahCBZRLK)d9MANGbw7zJbwlC6eC1YJazG21Y1gGowlq(51YoqTNnF1Yg1(LobxT0OijXAzPmCW0dSwaWa6n1gGoQEwIaEya5NfnyVR4qWoQnYpmua5NxRPAPSwrMdG8ZvxckS1zxF2OMKBGQajzOpR1S1kLditpqvKgAswsnao426Eg6lpYAjIOAfzoaYpxXHGDuBKFyOcKKH(S2FPwRuoGm9avxEKAswsnao426EgA2OwkQ1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xRPAfzoaYpxXHGDuBKFyOcKKH(SwZwRSY9DpIlBR49ZZcDMEGapc)Seb8WaYplPCaz6bQsWBcbqD21Imha5NpFwS4GP)SM2W(b9gTr(HX7Eex2w07NNf6m9abEe(zXIdM(ZYiWj6cuNDnj0bEwa4ueqJdM(ZQfCI1AKK1EzTZwiiIeAWAzVwuYl4Az6AHETNnwRJsE1kYCaKFETFqhi)mVwqFGZzT)Bhq2R9SrV20hTRfamGEtTCiyhR1i)WOwaqS2lR1o)QLKDUwBqVjAxBWaq2VANgC8Vw48zjc4HbKFwhpq)ubOJ6SRnYpmuOZ0deOwt1sd27koeSJAJ8ddfOrTMQLgS3vbOJ6SRnYpmubsYqFw7V12iauKSKV7rCzLZVFEwOZ0de4r4NLiGhgq(zbG0G9U6sqHTo76Zg1KCdubAuRPAbqAWExDjOWwND9zJAsUbQcKKH(S2FRLfhmDfhc2rnjCoHdCQqjrb4H6dsI1AQ2wxRiLIo7N6F7aY(ZIfhm9NLrGt0fOo7AsOd8UhXLRmF)8SqNPhiWJWplrapmG8ZIgS3vbOJ6SRnYpmuGg1AQwAWExfGoQZU2i)Wqfijd9zT)wBJaqrYswRPAfzoaYpxHstbFW0vbYaTR1uTImha5NRUeuyRZU(Srnj3avbsYqFwRPABDTIuk6SFQ)Tdi7plwCW0FwgborxG6SRjHoW7E3ZYMdY0B)(5rCzF)8SqNPhiWJWplwCW0FwO0uWhm9Nfaofb04GP)SAL9Ah5xTPxlj7CTSduRiZbq(5ZA5aRvKKqVPwqdZRTjRLTrgOw2bQfLMplrapmG8ZIKDwziUA)LATsOmR1uTs5aY0duLG3ecG6SRfzoaYpFwRPAPS2JhOFQa0rD21g5hgk0z6bcuRPAfzoaYpxfGoQZU2i)Wqfijd9zT)wRSYSwkE3J4Y99ZZcDMEGapc)SaWPiGghm9NfHow7h7xTxw78yX)AT5Gm9212bhJ2QA)XgRfCI1M9ALvov78yX)zT2yG1cN1EzTSqKG(vBpJApBS2dk(x7a7xTPx7zJ1kSz3XrTSdu7zJ1scNt4aRf612hWg7t9Seb8WaYplkRvkhqMEGQ5XI)ABoitVDTeruThKeR93ALvM1srTMQLgS3vCiyh12CqMEB18yX)A)TwzLtplHnd9NLSplwCW0FwCiyh1KW5eoW57EexcF)8SqNPhiWJWplwCW0FwCiyh1KW5eoW5ZcaNIaACW0Fwe62Oxl4e6n1khqA0oqEuBlLaWzxGMxRGNxTCTD8RwuYl4AjHZjCGZA)SHdS2pgEqVP2Eg1E2yT0G9ET8v7zJ1opoUAZETNnwBh2yFplrapmG8ZcBHGqddeqHKgTdKh6maC2fyTMQ9GKyT)wRekZAnv7LnndujYCaKF(Swt1kYCaKFUcjnAhip0za4SlqvGKm0N1A2ALvo1IQ1uTTUwwCW0viPr7a5HodaNDbQaGtMEGaV7rC547NNf6m9abEe(zjc4HbKFws5aY0duHKg5hgiGMMJGBWAnvRiZbq(5Qlbf26SRpButYnqvGKm0N1(l1Arjrb4H6dsI1AQwrMdG8ZvCiyh1g5hgQajzOpR9xQ1szTOKOa8q9bjXABX1k3APOwt1szTTUwSfccnmqa1mbhd8oO3Odq621ser1kshaeEkoeSJAJibGnTvb7)R1SuRvcQLiIQvK5ai)C1mbhd8oO3Odq62QajzOpR9xQ1szTOKOa8q9bjXABX1k3APOwkEwS4GP)ScgaY(PNgC8)DpIlbVFEwOZ0de4r4NLiGhgq(zjLditpqvln480Gteqpn44FTMQvK5ai)Cfhc2rTr(HHkqsg6ZA)LATOKOa8q9bjXAnvlL126AXwii0WabuZeCmW7GEJoaPBxlrevRiDaq4P4qWoQnIea20wfS)VwZsTwjOwIiQwrMdG8ZvZeCmW7GEJoaPBRcKKH(S2FPwlkjkapuFqsSwkEwS4GP)SUeuyRZU(Srnj3aF3J4YP3ppl0z6bc8i8ZseWddi)SmcuQUraOKvDjOWwND9zJAsUb(SyXbt)zXHGDuBKFy8UhXBfVFEwOZ0de4r4NLiGhgq(zjLditpqfsAKFyGaAAocUbR1uTImha5NRcgaY(PNgC8xfijd9zT)sTwusuaEO(GKyTMQvkhqMEGQdsIAq)GdnBuRzPwRCLzTMQLYABDTI0baHNIdb7O2isaytBf6m9abQLiIQT11kLditpqfp(42t9STl0Imha5NpRLiIQvK5ai)C1LGcBD21NnQj5gOkqsg6ZA)LATuwlkjkapuFqsS2wCTYTwkQLINfloy6pRa0rD21g5hgV7r8w07NNf6m9abEe(zjc4HbKFws5aY0duHKg5hgiGMMJGBWAnvRrGs1ncaLSQa0rD21g5hgplwCW0Fwbdaz)0tdo()UhXLZVFEwOZ0de4r4NLiGhgq(zjLditpqvln480Gteqpn44FTMQT11kLditpqLDoaGEJ(YJ8zXIdM(Z6sqHTo76Zg1KCd8DpIlRmF)8SqNPhiWJWplrapmG8ZIgS3vCiyh1g5hgkG8ZR1uTuwRuoGm9avhKe1G(bhA2OwZwRekZAjIOAfzoaYpxfmaK9tpn44Vkqsg6ZAnBTYk3APOwt1szTTUwr6aGWtXHGDuBejaSPTcDMEGa1ser126ALYbKPhOIhFC7PE22fArMdG8ZN1sXZIfhm9Nva6Oo7AJ8dJ39iUSY((5zHotpqGhHFwIaEya5NLuoGm9aviPr(HbcOP5i4gSwt1szT0G9UIdb7OwyZrdQMhl(xRzPwRCRLiIQvK5ai)Cfhc2rDg0QazG21srTMQLYABDThpq)ubOJ6SRnYpmuOZ0deOwIiQwrMdG8ZvbOJ6SRnYpmubsYqFwRzRvcQLIAnvRuoGm9av48GK8HaA2qlYCaKFETMLATsOmR1uTuwBRRvKoai8uCiyh1grcaBARqNPhiqTeruTTUwPCaz6bQ4Xh3EQNTDHwK5ai)8zTu8SyXbt)zfmaK9tpn44)7Eexw5((5zHotpqGhHFwS4GP)SUeuyRZU(Srnj3aFwa4ueqJdM(ZIq3g9Adq3HEtTgrcaBABETGtS2lpYAPBxl8M4Oxl0RndamQ9YA5bSXRfE1(bp7AzJNLiGhgq(zjLditpq1bjrnOFWHMnQ93ALazwRPALYbKPhO6GKOg0p4qZg1A2ALqzwRPAPS2wxl2cbHggiGAMGJbEh0B0biD7AjIOAfPdacpfhc2rTrKaWM2QG9)1AwQ1kb1sX7Eexwj89ZZcDMEGapc)Seb8WaYplPCaz6bQAPbNNgCIa6Pbh)R1uT0G9UIdb7OwyZrdQMhl(x7V1sd27koeSJAHnhnOIKLuppw8)zXIdM(ZIdb7Ood639iUSYX3ppl0z6bc8i8ZseWddi)SaqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8VwQ1cG0G9Ukyai7NEAWXFTuWHJbtdhWRTIKLuppw8)zXIdM(ZIdb7OMMJGBW39iUSsW7NNf6m9abEe(zjc4HbKFws5aY0du1sdopn4eb0tdo(xlrevlL1cG0G9Ukyai7NEAWXFTuWHJbtdhWRTc0Owt1cG0G9Ukyai7NEAWXFTuWHJbtdhWRTAES4FT)wlasd27QGbGSF6Pbh)1sbhogmnCaV2ksws98yX)AP4zXIdM(ZIdb7OMEWZ7DpIlRC69ZZcDMEGapc)SyXbt)zXHGDuNb9ZcaNIaACW0FwTGtS2mORn9Afa1c6dCoRLnQfoRvKKqVPwqJANz6plrapmG8ZIgS3vCiyh1cBoAq18yX)A)TwjSwt1kLditpq1bjrnOFWHMnQ1S1kRmF3J4Y2kE)8SqNPhiWJWplwCW0FwCiyh1KW5eoW5ZsyZq)zj7ZseWddi)SOb7DLyGCi45b9gvGS4Q1uT0G9UIdb7O2i)WqbA8UhXLTf9(5zHotpqGhHFwS4GP)S4qWoQP5i4g8zbGtranoy6pRwzV2pS2g8Q1i)WOwO3bNW0RfamGEtTdW5v7hsWyuRnlfRf9eSXUwBEEyTxwBdE1M9ETCTZlsVPwAocUbRfamGEtTNnwBKgsKnQ9d6a53ZseWddi)SOb7Dva6Oo7AJ8ddfOrTMQLgS3vbOJ6SRnYpmubsYqFw7VuRLfhmDfhc2rnjCoHdCQqjrb4H6dsI1AQwAWExXHGDuBKFyOanQ1uT0G9UIdb7OwyZrdQMhl(xl1APb7Dfhc2rTWMJgurYsQNhl(xRPAPb7Dfhc2rTnhKP3wnpw8Vwt1sd27kJ8ddn07Gty6kqJAnvlnyVROhzcmaNNc04DpIlRC(9ZZcDMEGapc)SyXbt)zXHGDutp459SaWPiGghm9NvRSx7hwBdE1AKFyul07Gty61cagqVP2b48Q9djymQ1MLI1IEc2yxRnppS2lRTbVAZEVwU25fP3ulnhb3G1cagqVP2ZgRnsdjYg1(bDG8Z8ANzTFibJrTPpAxl4eRf9eSXUw6bpVzTqhEqEmAx7L12GxTxwBpbJAf2C0GZNLiGhgq(zrd27kJaNOlqD21KqhqbAuRPAPSwAWExXHGDulS5ObvZJf)R93APb7Dfhc2rTWMJgurYsQNhl(xlrevBRRLYAPb7DLr(HHg6DWjmDfOrTMQLgS3v0JmbgGZtbAulf1sX7EexUY89ZZcDMEGapc)SyXbt)zze4eDbQZUMe6aplaCkcOXbt)z9JnwlnoVAbNyTzVwJKSw4S2lRfCI1cVAVS2wiiu8F0UwAq4aOwHnhn4SwaWa6n1Yg1Y9dJApBSDTn4vlaiPbculD7ApBSwBoitVDT0CeCd(Seb8WaYplAWExXHGDulS5ObvZJf)R93APb7Dfhc2rTWMJgurYsQNhl(xRPAPb7Dfhc2rTr(HHc04DpIlxzF)8SqNPhiWJWplaCkcOXbt)zrOJ1(X(v7L1opw8VwBoitVDTDWXOTQ2FSXAbNyTzVwzLt1opw8FwRngyTWzTxwllejOF12ZO2ZgR9GI)1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uplwCW0FwCiyh1KW5eoW5Zc6hgbOX9SK9zjSzO)SK9zjc4HbKFw0G9UIdb7O2MdY0BRMhl(x7V1kRC6zb9dJa040nJKMhplzF3J4YvUVFEwOZ0de4r4NLiGhgq(zrd27koeSJAHnhnOAES4FTuRLgS3vCiyh1cBoAqfjlPEES4FTMQvkhqMEGkK0i)Wab00CeCd(SyXbt)zXHGDutZrWn47EexUs47NNf6m9abEe(zjc4HbKFwKSZkdXv7V1kRe8SyXbt)zHstbFW0F3J4Yvo((5zHotpqGhHFwS4GP)S4qWoQPh88Ewa4ueqJdM(ZQLIpAxl4eRLEWZR2lRLgeoaQvyZrdoRf2R9dRLhbYaTR1MLI1otsS2EKK1Mb9ZseWddi)SOb7Dfhc2rTWMJgunpw8Vwt1sd27koeSJAHnhnOAES4FT)wlnyVR4qWoQf2C0Gksws98yX)39iUCLG3ppl0z6bc8i8ZcaNIaACW0FwTudog1(bp7AzYAb9boN1Yg1cN1kssO3ulOrTSdu7hsqG1oYVAtVws25Nfloy6ploeSJAs4Cch48zb9dJa04EwY(Se2m0FwY(Seb8WaYpRwxlL1kLditpq1bjrnOFWHMnQ9xQ1kRmR1uTKSZkdXv7V1kHYSwkEwq)WianoDZiP5XZs239iUCLtVFEwOZ0de4r4Nfaofb04GP)SA1i7WboR9dE21oYVAj55HrBZR1g2yxRnpp08AZOw68SRLKBxRNxT2SuSw0tWg7AjzNR9YANGggzC1ANF1sYoxl0p0NqPyTbdaz)QDAWX)AfSxlnAETZS2pKGXOwWjwBhgyT0dEE1YoqT9iNhDoUA)SrV2r(vB61sYo)SyXbt)z1HbQPh88E3J4YTv8(5zXIdM(ZQh58OZX9SqNPhiWJWV7DplbpeGd(GPpF)8iUSVFEwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplzFwIaEya5NLuoGm9av2SuuNgOJa1sTwzwRPAncuQUraOKvHstbFW0R1uTTUwkRnaDSNrdQMqd701Zldsf6m9abQLiIQnaDSNrdQoK0idEO)4WqHotpqGAP4zjLdTZK4ZYMLI60aDe4DpIl33ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZskhqMEGkBwkQtd0rGAPwRmR1uT0G9UIdb7O2i)WqbKFETMQvK5ai)Cfhc2rTr(HHkqsg6ZAnvlL1gGo2ZObvtOHD665LbPcDMEGa1ser1gGo2ZObvhsAKbp0FCyOqNPhiqTu8SKYH2zs8zzZsrDAGoc8UhXLW3ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNLSplrapmG8ZIgS3vCiyh1cBoAq18yX)APwlnyVR4qWoQf2C0Gksws98yX)AnvBRRLgS3vb4a1zxF2bItfOrTMQTdBSpDGKm0N1(l1APSwkRLKDUwjwlloy6koeSJA6bppLiNxTuuBlUwwCW0vCiyh10dEEkusuaEO(GKyTu8SKYH2zs8z1Hop00GH)UhXLJVFEwOZ0de4r4NvA8SM49SyXbt)zjLditpWNLuEaIplAWExXHGDuBZbz6TvZJf)RLAT0G9UIdb7O2MdY0BRizj1ZJf)RLiIQLYAdqh7z0GkoeSJA6KKMdas0pf6m9abQ1uThhn4PSrEC2kdXv7V1kHsqTu8SaWPiGghm9NLCa8SXOwU2o4y0U25XI)iqT2CqME7AZOwOxlkjkapS2G9gS2p4zxlHtsAoair)Ews5q7mj(SqsJ8ddeqtZrWn47EexcE)8SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplPCODMeFwdEEA2qdoXNfa2zWX9SK5ZseWddi)SOb7Dfhc2rTr(HHc0Owt1szTs5aY0dun45Pzdn4eRLATYSwIiQ2dsI1AwQ1kLditpq1GNNMn0GtSwIvRSsqTu8SKYdq8zDqs8DpIlNE)8SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwuwRiZbq(5koeSJAJ8ddfayWhm9ABX1szTYwBlqTuwRmvYucRTfxRiDaq4P4qWoQnIea20wfS)VwkQLIAPO2wGAPS2dsI12cuRuoGm9avdEEA2qdoXAP4zbGtranoy6pRwoeSJ12QrcaBAxBdukoRLRvkhqMEG1YKjOF1M9AfaH51sdE1(Hemg1coXA5A7d(QfNhKKpy61AJbQQ9hBS2jKuuRrKsHaiqTbsYqFQrjnqXHa1IsAe4CctVwGeN165v7xg)R9dhJA7zuRrKaWM21caI1EzTNnwlnymV2168bgyTzV2ZgRvaeQNLuo0otIplCEqs(qanBOfzoaYp)DpI3kE)8SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFws5aY0duHZdsYhcOzdTiZbq(5plrapmG8ZsKoai8uCiyh1grcaBA)SKYH2zs8zDqsud6hCOzJ39iEl69ZZcDMEGapc)SsJN1eVNfloy6plPCaz6b(SKYdq8zjYCaKFUIdb7O2i)Wqfijd95ZseWddi)SADTI0baHNIdb7O2isaytBf6m9abEws5q7mj(SoijQb9do0SX7Eexo)(5zHotpqGhHFwPXZIKL8zXIdM(ZskhqMEGplPCODMeFwhKe1G(bhA24zjc4HbKFwuwRiZbq(5Qlbf26SRpButYnqvGKm0N12cuRuoGm9avhKe1G(bhA2OwkQ93ALRmFwa4ueqJdM(ZIqhjymQfahC7AB5wTwqJAVSw5kZjkQTNrT)Kxl5zjLhG4ZsK5ai)C1LGcBD21NnQj5gOkqsg6Z39iUSY89ZZcDMEGapc)SsJNfjl5ZIfhm9NLuoGm9aFws5q7mj(SoijQb9do0SXZseWddi)SePdacpfhc2rTrKaWM21AQwr6aGWtXHGDuBejaSPTky)FT)wReuRPAXwii0WabuZeCmW7GEJoaPBxRPAfPu0z)u)Bhq2R1uTbOJ9mAqfhc2rTnhKP3wHotpqGNfaofb04GP)SSGUaRvoeKUDTWzTtqHDTCTg5hgDWrTxa9)4vBpJABPE7aYU51(Hemg1opO4FTxw7zJ1EFzTKqh8WAfTfdSwq)GJA)WABWRwUwByJDTONGn21gS)V2SxRrKaWM2plP8aeFwImha5NRMj4yG3b9gDas3wfijd957EexwzF)8SqNPhiWJWpR04znX7zXIdM(ZskhqMEGplP8aeFwImha5NRUeuyRZU(Srnj3avbYaTR1uTs5aY0duDqsud6hCOzJA)Tw5kZNfaofb04GP)Si0rcgJAbWb3U2FYRLulOrTxwRCL5ef12ZO2wUvFws5q7mj(SSZba0B0xEKV7rCzL77NNf6m9abEe(zLgpRjEplwCW0Fws5aY0d8zjLhG4ZIYAncuQUraOKvfmaK9tpn44FTeruTgbkv3iauYvfmaK9tpn44FTeruTgbkv3iausOkyai7NEAWX)APOwt1cG0G9Ukyai7NEAWXFTuWHJbtdhWRTci)8Nfaofb04GP)SKdzai7xTwgC8VwGeN165vlKKebG8HJ21AaE1cAu7zJ1kfC4yW0Wb8Axlasd271oZAHxTc2RLgRfa27qb44Q9YAbGtbgETNnF1(HeeyT8v7zJ1sObJ8SRvk4WXGPHd41U25XI)plPCODMeFwT0GZtdora90GJ)V7rCzLW3ppl0z6bc8i8ZknEwt8EwS4GP)SKYbKPh4ZskpaXNfnyVR4qWoQnYpmua5NxRPAPb7Dva6Oo7AJ8ddfq(51AQwaKgS3vxckS1zxF2OMKBGkG8ZR1uTTUwPCaz6bQAPbNNgCIa6Pbh)R1uTainyVRcgaY(PNgC8xlfC4yW0Wb8ARaYp)zjLdTZK4ZkbVjea1zxlYCaKF(8DpIlRC89ZZcDMEGapc)SsJN1eVNfloy6plPCaz6b(SKYdq8zfGo2ZObvCiyh12CqMEBf6m9abQ1uTuwlL1ksPOZ(P(3oGSxRPAfzoaYpxfmaK9tpn44Vkqsg6ZA)TwPCaz6bQS5Gm9265XI)6dsI1srTu8SKYH2zs8znpw8xBZbz6TF37EwDOZdnny4VFEex23ppl0z6bc8i8ZIfhm9Nfhc2rnjCoHdC(Se2m0FwY(Seb8WaYplAWExjgihcEEqVrfilU39iUCF)8SyXbt)zXHGDutp459SqNPhiWJWV7rCj89ZZIfhm9Nfhc2rnnhb3Gpl0z6bc8i87E37EwsXyct)rC5kt5kRmLtYTf9S(4WHEZ8zrO3YYHeVvsCcTKXAR9hBSwiPrgxT9mQLaBoitVnb1gyleegiqTZKeRLbVKKpeOwHn7n4uvYldqhRvwzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukRKuOk5LbOJ1khLXAjK0LIXHa1sWfq)pEkMwOezoaYpNGAVSwcezoaYpxX0ccQLszLKcvjVmaDSwjqgRLqsxkghculbxa9)4PyAHsK5ai)CcQ9YAjqK5ai)CftliOwkLvskuL8Ya0XABfYyTes6sX4qGAjqKoai8uMHGAVSwcePdacpLzuOZ0deGGAPuwjPqvYldqhRvwzkJ1siPlfJdbQLar6aGWtzgcQ9YAjqKoai8uMrHotpqacQLszLKcvjVmaDSwzLvgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYkRmwlHKUumoeOwcePdacpLziO2lRLar6aGWtzgf6m9abiOwkLvskuL8L8e6TSCiXBLeNqlzS2A)XgRfsAKXvBpJAjOdN2qVrNgOJbb1gyleegiqTZKeRLbVKKpeOwHn7n4uvYldqhRvwzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPCLKcvjVmaDSw5kJ1siPlfJdbQLGJhOFkZqqTxwlbhpq)uMrHotpqacQLszLKcvjVmaDSwjugRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1khLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTsGmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvojJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOw(QvoOLImulLYkjfQsEza6yTYzzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRCwgRLqsxkghculbI0baHNYmeu7L1sGiDaq4PmJcDMEGaeulF1kh0srgQLszLKcvjVmaDSwzLRmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuUssHQKxgGowRSsGmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvUYugRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYvcLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYvskuL8Ya0XALRekJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOw(QvoOLImulLYkjfQsEza6yTYvcKXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulF1kh0srgQLszLKcvjVmaDSw5kNKXAjK0LIXHa1sWXd0pLziO2lRLGJhOFkZOqNPhiab1sPSssHQKVKNqVLLdjERK4eAjJ1w7p2yTqsJmUA7zulbrE8btNGAdSfccdeO2zsI1YGxsYhcuRWM9gCQk5LbOJ1kRmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOwkLvskuL8Ya0XALRmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvokJ1siPlfJdbQLGJhOFkZqqTxwlbhpq)uMrHotpqacQLszLKcvjVmaDSwjqgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYzzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukRKuOk5LbOJ1kBlsgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTY2IKXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYkNLXAjK0LIXHa1sWXd0pLziO2lRLGJhOFkZOqNPhiab1sPSssHQKxgGowRSYzzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRCLPmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOwkLvskuL8Ya0XALRSYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSw5kxzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKVKNqVLLdjERK4eAjJ1w7p2yTqsJmUA7zulbPb6yqqTb2cbHbcu7mjXAzWlj5dbQvyZEdovL8Ya0XALvgRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kxzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRSYvgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYkbYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLVALdAPid1sPSssHQKxgGowRSYjzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1YxTYbTuKHAPuwjPqvYldqhRv2wHmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOwkLvskuL8L8e6TSCiXBLeNqlzS2A)XgRfsAKXvBpJAjaa7m44iO2aBHGWabQDMKyTm4LK8Ha1kSzVbNQsEza6yTYvgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYvskuL8Ya0XALJYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSwzLJYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSwzLtYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSwzBrYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSw5kRmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGA5Rw5GwkYqTukRKuOk5LbOJ1kx5kJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALRekJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALRCugRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kxjqgRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kx5KmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYxYtO3YYHeVvsCcTKXAR9hBSwiPrgxT9mQLaJafjjnFeuBGTqqyGa1otsSwg8ss(qGAf2S3GtvjVmaDSw5KmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvojJ1siPlfJdbQLar6aGWtzgcQ9YAjqKoai8uMrHotpqacQLszLKcvjVmaDSw5ktzSwcjDPyCiqTeishaeEkZqqTxwlbI0baHNYmk0z6bcqqTukRKuOk5LbOJ1kxzLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYvwzSwcjDPyCiqTeishaeEkZqqTxwlbI0baHNYmk0z6bcqqTukRKuOk5LbOJ1kx5kJ1siPlfJdbQLar6aGWtzgcQ9YAjqKoai8uMrHotpqacQLszLKcvjVmaDSw5kNLXAjK0LIXHa1sWXd0pLziO2lRLGJhOFkZOqNPhiab1sPCLKcvjVmaDSw5kNLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTsOCLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTsOCLXAjK0LIXHa1sGiDaq4Pmdb1EzTeishaeEkZOqNPhiab1sPSssHQKxgGowRekHYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLVALdAPid1sPSssHQKxgGowRekhLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTsOeiJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8L8e6TSCiXBLeNqlzS2A)XgRfsAKXvBpJAjqK5ai)8jb1gyleegiqTZKeRLbVKKpeOwHn7n4uvYldqhRvwzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRvwzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRCLXAjK0LIXHa1sWXd0pLziO2lRLGJhOFkZOqNPhiab1sPCLKcvjVmaDSw5kJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALqzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRvcLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYrzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRCsgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYvskuL8Ya0XABrYyTes6sX4qGAj44b6NYmeu7L1sWXd0pLzuOZ0deGGAPuUssHQKxgGowRCwgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYvskuL8Ya0XALvwzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRvwjugRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYkhLXAjK0LIXHa1sWXd0pLziO2lRLGJhOFkZOqNPhiab1sPSssHQKxgGowRSTizSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukRKuOk5l5j0Bz5qI3kjoHwYyT1(JnwlK0iJR2Eg1saNib1gyleegiqTZKeRLbVKKpeOwHn7n4uvYldqhRvwzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRvwzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowRCLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYvskuL8Ya0XALqzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRvcLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYrzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowReiJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALtYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDS2wHmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRTfjJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALZYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSwzLPmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOwkLRKuOk5LbOJ1kRSYyTes6sX4qGAj44b6NYmeu7L1sWXd0pLzuOZ0deGGAPuUssHQKxgGowRSYrzSwcjDPyCiqTeC8a9tzgcQ9YAj44b6NYmk0z6bcqqTukxjPqvYldqhRv2wHmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOw(QvoOLImulLYkjfQsEza6yTY2IKXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYkNLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTYvMYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjVmaDSw5kRmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvUYvgRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kxjugRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kx5OmwlHKUumoeOwccqh7z0GkZqqTxwlbbOJ9mAqLzuOZ0deGGAPuwjPqvYldqhRvUsGmwlHKUumoeOwcoEG(Pmdb1EzTeC8a9tzgf6m9abiOwkLvskuL8Ya0XALReiJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALRCsgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTYvojJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLvskuL8Ya0XALBlsgRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kHYugRLqsxkghculbbOJ9mAqLziO2lRLGa0XEgnOYmk0z6bcqqTukRKuOk5LbOJ1kHYvgRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQsEza6yTsOCLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulLYkjfQsEza6yTsOekJ1siPlfJdbQLGJhOFkZqqTxwlbhpq)uMrHotpqacQLs5kjfQsEza6yTsOCugRLqsxkghculbhpq)uMHGAVSwcoEG(PmJcDMEGaeulLYkjfQs(sEc9wwoK4TsItOLmwBT)yJ1cjnY4QTNrTei4HaCWhm9jb1gyleegiqTZKeRLbVKKpeOwHn7n4uvYldqhRvwzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPCLKcvjVmaDSw5kJ1siPlfJdbQLGa0XEgnOYmeu7L1sqa6ypJguzgf6m9abiOwkLRKuOk5LbOJ1kHYyTes6sX4qGATGKesTZ2(XswBlvv7L1kdGCTaqPWjm9Atdm4lJAPuIuulLYkjfQsEza6yTYrzSwcjDPyCiqTeeGo2ZObvMHGAVSwccqh7z0GkZOqNPhiab1sPSssHQKxgGowBlsgRLqsxkghculbI0baHNYmeu7L1sGiDaq4PmJcDMEGaeulF1kh0srgQLszLKcvjVmaDSwzLPmwlHKUumoeOwcUa6)XtX0cLiZbq(5eu7L1sGiZbq(5kMwqqTukRKuOk5LbOJ1kRmLXAjK0LIXHa1sqa6ypJguzgcQ9YAjiaDSNrdQmJcDMEGaeulF1kh0srgQLszLKcvjVmaDSwzLJYyTes6sX4qGAjiaDSNrdQmdb1EzTeeGo2ZObvMrHotpqacQLszLKcvjFjFRK0iJdbQvwzwlloy61oGZBQk5Fwm4zNXZYcsco4dMoHeC)Ewgr2Hd8zrOiu12s4gS2woeSJL8ekcvTYd6yTYvoBETYvMYv2s(sEcfHQwcXM9gCkJL8ekcvTTa12coXAV2gqbpQ1cssi1AZoWa6n1M9Af2S74OwOFyeGghm9AH(8qgO2Sxlbc2f4qZIdMobQsEcfHQ2wGAjeB2BWA5qWoQHEh6WRDTxwlhc2rTnhKP3UwkHxTokfJA)q)QDaLI1YZA5qWoQHEh6WRnfQs(sEwCW0NkJafjjnFeJQe5qWoQH(HJbkUsEwCW0NkJafjjnFeJQe5qWoQ7mjCa5OKNfhm9PYiqrssZhXOkrr6T0GbQjzN1nizjploy6tLrGIKKMpIrvIs5aY0d0CNjrQCI6JJg80Ie0pZtdQboXZCaSZGJJQewYZIdM(uzeOijP5JyuLOuoGm9an3zsKkkn1gIZ80GAGt8mha7m44OkReuYZIdM(uzeOijP5JyuLOuoGm9an3zsKQrGgGJHgLMMNguN4zoStLYa0XEgnOAcnStxpVminrPiLIo7Nsk6ND7GiIePu0z)uokICKbarejshaeEkoeSJAJibGnTPGcZLYdqKQSMlLhGOghtKQml5zXbtFQmcuKK08rmQsukhqMEGM7mjs1MLI60aDeW80G6epZHDQS4Gsrn6ijeNMLQuoGm9avCI6JJg80Ie0pZLYdqKQSMlLhGOghtKQml5zXbtFQmcuKK08rmQsukhqMEGM7mjsTdDEOPbd380G6epZLYdqKQml5zXbtFQmcuKK08rmQsukhqMEGM7mjs1MdY0BRNhl(RpijAEAqnWjEMdGDgCCuLZL8S4GPpvgbkssA(igvjkLditpqZDMePYJpU9upB7cTiZbq(5tZtdQboXZCaSZGJJQml5zXbtFQmcuKK08rmQsukhqMEGM7mjsnMAswsnao426Eg6lpsZtdQboXZCaSZGJJQeuYZIdM(uzeOijP5JyuLOuoGm9an3zsKAm1KSKAaCWT19m0rAyEAqnWjEMdGDgCCuLGsEwCW0NkJafjjnFeJQeLYbKPhO5otIuJPMKLudGdUTUNHMnmpnOg4epZbWodooQYvML8S4GPpvgbkssA(igvjkLditpqZDMePsMN2iqbIa6lpsnDBZtdQboXZCaSZGJJAlQKNfhm9PYiqrssZhXOkrPCaz6bAUZKivY80KSKAaCWT19m0xEKMNgudCIN5ayNbhhvzLzjploy6tLrGIKKMpIrvIs5aY0d0CNjrQK5Pjzj1a4GBR7zOzdZtdQboXZCaSZGJJQSsqjploy6tLrGIKKMpIrvIs5aY0d0CNjrQSHMKLudGdUTUNH(YJ080GAGt8mh2PkshaeEkoeSJAJibGnTnxkparQsOmnxkparnoMivzLzjploy6tLrGIKKMpIrvIs5aY0d0CNjrQSHMKLudGdUTUNH(YJ080GAGt8mha7m44OkRml5zXbtFQmcuKK08rmQsukhqMEGM7mjsLn0KSKAaCWT19m0K5zEAqnWjEMdGDgCCuLRml5zXbtFQmcuKK08rmQsukhqMEGM7mjsnsdnjlPgahCBDpd9LhP5Pb1jEMlLhGiv5kZwakLGwSiDaq4P4qWoQnIea20MIsEwCW0NkJafjjnFeJQeLYbKPhO5otIuV8i1KSKAaCWT19m0SH5Pb1jEMlLhGivjGyYvMTykfPu0z)uoSX(0DgjIikfPdacpfhc2rTrKaWM2MyXbLIA0rsio)vkhqMEGkor9XrdEArc6hfuqmzLGwmLIuk6SFQ)Tdi7Mcqh7z0GkoeSJABoitVTjwCqPOgDKeItZsvkhqMEGkor9XrdEArc6hfL8S4GPpvgbkssA(igvjkLditpqZDMePE5rQjzj1a4GBR7zOJ0W80G6epZLYdqKQCLzlaLTOwSiDaq4P4qWoQnIea20MIsEwCW0NkJafjjnFeJQeLYbKPhO5otIuP5i4gutYoRneN5Pb1jEMd7ufPu0z)uoSX(0DgnxkparQYjz2cqjjppmARLYdqSflRmLjfL8S4GPpvgbkssA(igvjkLditpqZDMePsZrWnOMKDwBioZtdQt8mh2PksPOZ(P(3oGSBUuEaIuLZsqlaLK88WOTwkpaXwSSYuMuuYZIdM(uzeOijP5JyuLOuoGm9an3zsKknhb3GAs2zTH4mpnOoXZCyNQuoGm9av0CeCdQjzN1gIJQmnxkparQTiz2cqjjppmARLYdqSflRmLjfL8S4GPpvgbkssA(igvjkLditpqZDMePYgAsOdjbj1KSZAdXzEAqnWjEMdGDgCCuLvck5zXbtFQmcuKK08rmQsukhqMEGM7mjs9YJutYsQf2C0GtZtdQboXZCaSZGJJQCl5zXbtFQmcuKK08rmQsukhqMEGM7mjsLtuF5rQjzj1cBoAWP5Pb1aN4zoa2zWXrvUL8S4GPpvgbkssA(igvjkLditpqZDMeP2HtBO3Otd0XW80G6epZLYdqKQSTykXwii0WabuiPr7a5HodaNDbseruE8a9tfGoQZU2i)WWeLhpq)uCiyh1OWojIOwlsPOZ(P(3oGStHjkBTiLIo7NYrrKJmaiIiwCqPOgDKeItQYserbOJ9mAq1eAyNUEEzqsHPwlsPOZ(PKI(z3oOGIsEwCW0NkJafjjnFeJQeLYbKPhO5otIuzdD6AWjAEAqDIN5s5bisfBHGqddeqrYcMoq90gXttcoHcIicBHGqddeq1myaiFzm10mqdseryleeAyGaQMbda5lJPMeb4XaMoreHTqqOHbcOa44pzMUgaf)1gGxGtb6cKiIWwii0WabuqFkcWJPhOUfcY(bsQbqPqbseryleeAyGaQzcog4DqVrhG0TjIiSfccnmqa1e0PhzcOzs8SBppIicBHGqddeq9X)rhJPUhPdqeryleeAyGaQ(GjrD2108DdSKNfhm9PYiqrssZhXOkrsyezOHKCdwYZIdM(uzeOijP5JyuLya6Oo7AJ8ddZHDQIuk6SFQ)Tdi7Mcqh7z0GkoeSJABoitVTjr6aGWtXHGDuBejaSPTjPCaz6bQ4Xh3EQNTDHwK5ai)8zjploy6tLrGIKKMpIrvI9iNhDooZHDQTwkhqMEGkJanahdnknPkRPa0XEgnOcaofqJb05OTwKKKSduYZIdM(uzeOijP5JyuLihc2rn9GNN5Wo1wlLditpqLrGgGJHgLMuL1uRdqh7z0Gka4uangqNJ2ArssYoGjkBTiLIo7Nsk6ND7GiIKYbKPhOQdN2qVrNgOJbfL8S4GPpvgbkssA(igvjscJiJPo76lds0pZHDQTwkhqMEGkJanahdnknPkRPwhGo2ZObvaWPaAmGohT1IKKKDatIuk6SFkPOF2TdtTwkhqMEGQoCAd9gDAGogL8S4GPpvgbkssA(igvjIstbFW0nh2PkLditpqLrGgGJHgLMuLTKVKNfhm9jXOkrrc6hgtdCmk5zXbtFsmQseCIAs2zDdsAoStLYJhOFk0hWg7dDeWej7SYqC)sTfjttKSZkdXzwQYjjGcIiIYwF8a9tH(a2yFOJaMizNvgI7xQTijGIsEwCW0NeJQenYdMU5WovAWExXHGDuBKFyOank5zXbtFsmQs8GKO(JddZHDQbOJ9mAq1HKgzWd9hhgMOb7DfkPndopy6kqdtukYCaKFUIdb7O2i)Wqfid0MiIOZ50uh2yF6ajzOp)LQCuMuuYZIdM(KyuL4a2yFtDlniqdj6N5WovAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfq(5L8S4GPpjgvjsZn6SRVak(pnh2Psd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MaqAWExDjOWwND9zJAsUbQaYpVKNfhm9jXOkrAmMy8h6nMd7uPb7Dfhc2rTr(HHc0OKNfhm9jXOkr6rMa6oy02CyNknyVR4qWoQnYpmuGgL8S4GPpjgvj2HbspYeWCyNknyVR4qWoQnYpmuGgL8S4GPpjgvjYUaNxWdTGhdZHDQ0G9UIdb7O2i)WqbAuYZIdM(KyuLi4e1WdjNMd7uPb7Dfhc2rTr(HHc0OKNfhm9jXOkrWjQHhsAo27O40otIuBgmaKVmMAAgObnh2Psd27koeSJAJ8ddfObrejYCaKFUIdb7O2i)Wqfijd9PzPkbsGjaKgS3vxckS1zxF2OMKBGkqJsEwCW0NeJQebNOgEiP5otIursJ2bYdDgao7c0CyNQiZbq(5koeSJAJ8ddvGKm0N)sLszLqI1kAXs5aY0duXg601GtKctImha5NRUeuyRZU(Srnj3avbsYqF(lvkLvcjwROflLditpqfBOtxdorkk5zXbtFsmQseCIA4HKM7mjsfiqgOddulfNtCyoStvK5ai)Cfhc2rTr(HHkqsg6tZsvUYKiIATuoGm9avSHoDn4ePklrer5bjrQY0KuoGm9avD40g6n60aDmOkRPa0XEgnOAcnStxpVmiPOKNfhm9jXOkrWjQHhsAUZKi1zco0WghEyyoStvK5ai)Cfhc2rTr(HHkqsg6tZsvcLjre1APCaz6bQydD6AWjsv2sEwCW0NeJQebNOgEiP5otIuBgTnS1zxZZjKeo4dMU5WovrMdG8ZvCiyh1g5hgQajzOpnlv5ktIiQ1s5aY0duXg601GtKQSereLhKePktts5aY0du1HtBO3Otd0XGQSMcqh7z0GQj0WoD98YGKIsEwCW0NeJQebNOgEiP5otIujzbthOEAJ4PjbNqH5WovrMdG8ZvCiyh1g5hgQajzOp)LQeyIYwlLditpqvhoTHEJonqhdQYserhKenRektkk5zXbtFsmQseCIA4HKM7mjsLKfmDG6PnINMeCcfMd7ufzoaYpxXHGDuBKFyOcKKH(8xQsGjPCaz6bQ6WPn0B0Pb6yqvwt0G9UkaDuNDTr(HHc0WenyVRcqh1zxBKFyOcKKH(8xQukRmBbKGwCa6ypJgunHg2PRNxgKuy6GK4VsOml5jueQAzXbtFsmQs0XVEc6a6aN5qkAo4e1F2WbQf88GEdvznh2Psd27koeSJAJ8ddfObrebG0G9U6sqHTo76Zg1KCdubAqera5PcgaY(PNgC8xDqXFO3uYZIdM(KyuLOGhdnloy66bCEM7mjsvWdb4Gpy6ZsEwCW0NeJQef8yOzXbtxpGZZCNjrQCIMpVakoQYAoStLfhukQrhjH40SuLYbKPhOItuFC0GNwKG(vYZIdM(KyuLOGhdnloy66bCEM7mjs1MdY0BBoStvKsrN9t9VDaz3ua6ypJguXHGDuBZbz6Tl5zXbtFsmQsuWJHMfhmD9aopZDMeP2HtBO3Otd0XWCyNQuoGm9av2SuuNgOJauLPjPCaz6bQ6WPn0B0Pb6yyQ1uksPOZ(P(3oGSBkaDSNrdQ4qWoQT5Gm92uuYZIdM(KyuLOGhdnloy66bCEM7mjsnnqhdZHDQs5aY0duzZsrDAGocqvMMAnLIuk6SFQ)Tdi7Mcqh7z0GkoeSJABoitVnfL8S4GPpjgvjk4XqZIdMUEaNN5otIufzoaYpFAoStT1uksPOZ(P(3oGSBkaDSNrdQ4qWoQT5Gm92uuYZIdM(KyuLOGhdnloy66bCEM7mjsnYJpy6Md7uLYbKPhOQdDEOPbdNQmn1AkfPu0z)u)Bhq2nfGo2ZObvCiyh12CqMEBkk5zXbtFsmQsuWJHMfhmD9aopZDMeP2Hop00GHBoStvkhqMEGQo05HMgmCQYAQ1uksPOZ(P(3oGSBkaDSNrdQ4qWoQT5Gm92uuYxYZIdM(uXjsTh58OZXzoStnaDSNrdQaGtb0yaDoARfjjj7aMezoaYpxrd27Aa4uangqNJ2ArssYoGkqgOTjAWExbaNcOXa6C0wlsss2b09iNNci)Ctusd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MaqAWExDjOWwND9zJAsUbQaYpNctImha5NRUeuyRZU(Srnj3avbsYqFsvMMOKgS3vCiyh1cBoAq18yX)FPkLditpqfNO(YJutYsQf2C0Gttus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSKAaCWT19m0SbfereLT(4b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswsnao426EgA2GcIisK5ai)Cfhc2rTr(HHkqsg6ZFP2iaOGIsEwCW0NkorIrvIDyGA6bppZHDQugGo2ZObvaWPaAmGohT1IKKKDatImha5NROb7DnaCkGgdOZrBTijjzhqfid02enyVRaGtb0yaDoARfjjj7a6omqfq(5MmcuQUraOKv1JCE054OGiIOmaDSNrdQaGtb0yaDoARfjjj7aMoijsvMuuYZIdM(uXjsmQsSh580EkLnh2PgGo2ZObvnbCoARHcOyGMezoaYpxXHGDuBKFyOcKKH(0SsOmnjYCaKFU6sqHTo76Zg1KCdufijd9jvzAIsAWExXHGDulS5ObvZJf))LQuoGm9avCI6lpsnjlPwyZrdonrjLhpq)ubOJ6SRnYpmmjYCaKFUkaDuNDTr(HHkqsg6ZFP2iamjYCaKFUIdb7O2i)Wqfijd9PzLYbKPhO6YJutYsQbWb3w3ZqZguqeru26JhOFQa0rD21g5hgMezoaYpxXHGDuBKFyOcKKH(0Ss5aY0duD5rQjzj1a4GBR7zOzdkiIirMdG8ZvCiyh1g5hgQajzOp)LAJaGckk5zXbtFQ4ejgvj2JCEApLYMd7udqh7z0GQMaohT1qbumqtImha5NR4qWoQnYpmubsYqFsvMMOKskfzoaYpxDjOWwND9zJAsUbQcKKH(0Ss5aY0duXgAswsnao426Eg6lpst0G9UIdb7OwyZrdQMhl(tLgS3vCiyh1cBoAqfjlPEES4pfereLImha5NRUeuyRZU(Srnj3avbsYqFsvMMOb7Dfhc2rTWMJgunpw8)xQs5aY0duXjQV8i1KSKAHnhn4Kckmrd27Qa0rD21g5hgkG8ZPOKNfhm9PItKyuLihc2rnjCoHdCAoStvKsrN9t9VDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJABoitVTAES4)VYkbMezoaYpxfmaK9tpn44Vkqsg6ZFPkLditpqLnhKP3wppw8xFqsKyOKOa8q9bjrtImha5NRUeuyRZU(Srnj3avbsYqF(lvPCaz6bQS5Gm9265XI)6dsIedLefGhQpijsmwCW0vbdaz)0tdo(Rqjrb4H6dsIMezoaYpxXHGDuBKFyOcKKH(8xQs5aY0duzZbz6T1ZJf)1hKejgkjkapuFqsKyS4GPRcgaY(PNgC8xHsIcWd1hKejgloy6Qlbf26SRpButYnqfkjkapuFqs0CHndDQYwYZIdM(uXjsmQs8sqHTo76Zg1KCd0CyNAa6ypJgunHg2PRNxgKMmcuQUraOKvHstbFW0l5zXbtFQ4ejgvjYHGDuBKFyyoStnaDSNrdQMqd701ZldstuAeOuDJaqjRcLMc(GPtergbkv3iauYQUeuyRZU(Srnj3aPOKNfhm9PItKyuLiknf8bt3CyN6bjrZkHY0ua6ypJgunHg2PRNxgKMOb7Dfhc2rTWMJgunpw8)xQs5aY0duXjQV8i1KSKAHnhn40KiZbq(5Qlbf26SRpButYnqvGKm0NuLPjrMdG8ZvCiyh1g5hgQajzOp)LAJaOKNfhm9PItKyuLiknf8bt3CyN6bjrZkHY0ua6ypJgunHg2PRNxgKMezoaYpxXHGDuBKFyOcKKH(KQmnrjLukYCaKFU6sqHTo76Zg1KCdufijd9PzLYbKPhOIn0KSKAaCWT19m0xEKMOb7Dfhc2rTWMJgunpw8NknyVR4qWoQf2C0Gksws98yXFkiIikfzoaYpxDjOWwND9zJAsUbQcKKH(KQmnrd27koeSJAHnhnOAES4)VuLYbKPhOItuF5rQjzj1cBoAWjfuyIgS3vbOJ6SRnYpmua5NtH5q)WianonStLgS3vtOHD665LbPAES4pvAWExnHg2PRNxgKksws98yXFZH(HraACAijjca5dPkBjploy6tfNiXOkrsyezm1zxFzqI(zoStLsrMdG8ZvCiyh1g5hgQajzOpnRCuciIirMdG8ZvCiyh1g5hgQajzOp)LQesHjrMdG8ZvxckS1zxF2OMKBGQajzOpPkttusd27koeSJAHnhnOAES4)VuLYbKPhOItuF5rQjzj1cBoAWPjkP84b6NkaDuNDTr(HHjrMdG8ZvbOJ6SRnYpmubsYqF(l1gbGjrMdG8ZvCiyh1g5hgQajzOpnReqbrerzRpEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkbuqerImha5NR4qWoQnYpmubsYqF(l1gbafuuYZIdM(uXjsmQsmyai7NEAWXFZHDQImha5NRUeuyRZU(Srnj3avbsYqF(lkjkapuFqs0eLuE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)LAJaWKiZbq(5koeSJAJ8ddvGKm0NMvkhqMEGQlpsnjlPgahCBDpdnBqbrerzRpEG(Pcqh1zxBKFyysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUTUNHMnOGiIezoaYpxXHGDuBKFyOcKKH(8xQncakk5zXbtFQ4ejgvjgmaK9tpn44V5WovrMdG8ZvCiyh1g5hgQajzOp)fLefGhQpijAIskPuK5ai)C1LGcBD21NnQj5gOkqsg6tZkLditpqfBOjzj1a4GBR7zOV8inrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)uqerukYCaKFU6sqHTo76Zg1KCdufijd9jvzAIgS3vCiyh1cBoAq18yX)FPkLditpqfNO(YJutYsQf2C0GtkOWenyVRcqh1zxBKFyOaYpNIsEwCW0NkorIrvIaiF20z4O5WovrMdG8ZvCiyh1g5hgQajzOpPkttusjLImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQydnjlPgahCBDpd9LhPjAWExXHGDulS5ObvZJf)Psd27koeSJAHnhnOIKLuppw8NcIiIsrMdG8ZvxckS1zxF2OMKBGQajzOpPktt0G9UIdb7OwyZrdQMhl()lvPCaz6bQ4e1xEKAswsTWMJgCsbfMOb7Dva6Oo7AJ8ddfq(5uuYZIdM(uXjsmQs8sqHTo76Zg1KCd0CyNkL0G9UIdb7OwyZrdQMhl()lvPCaz6bQ4e1xEKAswsTWMJgCsergbkv3iauYQcgaY(PNgC8Nctus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSKAaCWT19m0SbfereLT(4b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswsnao426EgA2GcIisK5ai)Cfhc2rTr(HHkqsg6ZFP2iaOOKNfhm9PItKyuLihc2rTr(HH5WovkPuK5ai)C1LGcBD21NnQj5gOkqsg6tZkLditpqfBOjzj1a4GBR7zOV8inrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)uqerukYCaKFU6sqHTo76Zg1KCdufijd9jvzAIgS3vCiyh1cBoAq18yX)FPkLditpqfNO(YJutYsQf2C0GtkOWenyVRcqh1zxBKFyOaYpVKNfhm9PItKyuLya6Oo7AJ8ddZHDQ0G9UkaDuNDTr(HHci)CtusPiZbq(5Qlbf26SRpButYnqvGKm0NMvUY0enyVR4qWoQf2C0GQ5XI)uPb7Dfhc2rTWMJgurYsQNhl(tbrerPiZbq(5Qlbf26SRpButYnqvGKm0NuLPjAWExXHGDulS5ObvZJf))LQuoGm9avCI6lpsnjlPwyZrdoPGctukYCaKFUIdb7O2i)Wqfijd9PzLvUereasd27Qlbf26SRpButYnqfObfL8S4GPpvCIeJQeN2W(b9gTr(HH5WovrMdG8ZvCiyh1zqRcKKH(0Ssare16JhOFkoeSJ6mOl5zXbtFQ4ejgvjYHGDutp45zoStvKsrN9t9VDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdo(RLcoCmyA4aETvZJf)PkhnzeOuDJaqjRIdb7OodAtS4Gsrn6ijeN)2kk5zXbtFQ4ejgvjYHGDutZrWnO5WovrkfD2p1)2bKDtbOJ9mAqfhc2rTnhKP32enyVR4qWoQnYpmuGgMaqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8NQCSKNfhm9PItKyuLihc2rn9GNN5WovrkfD2p1)2bKDtbOJ9mAqfhc2rTnhKP32enyVR4qWoQnYpmuGgMOeipvWaq2p90GJ)QajzOpnRCIiIaqAWExfmaK9tpn44Vwk4WXGPHd41wbAqHjaKgS3vbdaz)0tdo(RLcoCmyA4aETvZJf))voAIfhukQrhjH4KQewYZIdM(uXjsmQsKdb7OodAZHDQIuk6SFQ)Tdi7Mcqh7z0GkoeSJABoitVTjAWExXHGDuBKFyOanmbG0G9Ukyai7NEAWXFTuWHJbtdhWRTAES4pvjSKNfhm9PItKyuLihc2rnnhb3GMd7ufPu0z)u)Bhq2nfGo2ZObvCiyh12CqMEBt0G9UIdb7O2i)WqbAycaPb7DvWaq2p90GJ)APGdhdMgoGxB18yXFQYTKNfhm9PItKyuLihc2rnkPXiNW0nh2PksPOZ(P(3oGSBkaDSNrdQ4qWoQT5Gm92MOb7Dfhc2rTr(HHc0WKrGs1ncaLCvbdaz)0tdo(BIfhukQrhjH40Ssyjploy6tfNiXOkroeSJAusJroHPBoStvKsrN9t9VDaz3ua6ypJguXHGDuBZbz6Tnrd27koeSJAJ8ddfOHjaKgS3vbdaz)0tdo(RLcoCmyA4aETvZJf)PkRjwCqPOgDKeItZkHL8S4GPpvCIeJQencCIUa1zxtcDaZHDQ0G9Uca5ZModhvGgMaqAWExDjOWwND9zJAsUbQanmbG0G9U6sqHTo76Zg1KCdufijd95VuPb7DLrGt0fOo7AsOdOizj1ZJf)BXS4GPR4qWoQPh88uOKOa8q9bjrtus5Xd0pvGZ0zxGMyXbLIA0rsio)vosbreXIdkf1OJKqC(ReqHjkBDa6ypJguXHGDutNK0CaqI(rerhhn4PSrEC2kdXzwjucOOKNfhm9PItKyuLihc2rn9GNN5WovAWExbG8ztNHJkqdtus5Xd0pvGZ0zxGMyXbLIA0rsio)vosbreXIdkf1OJKqC(ReqHjkBDa6ypJguXHGDutNK0CaqI(rerhhn4PSrEC2kdXzwjucOOKNfhm9PItKyuL4e0adpLYL8S4GPpvCIeJQe5qWoQP5i4g0CyNknyVR4qWoQf2C0GQ5XI)MLkLS4Gsrn6ijeNTaYsHPa0XEgnOIdb7OMojP5aGe9Z0XrdEkBKhNTYqC)kHsqjploy6tfNiXOkroeSJAAocUbnh2Psd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)L8S4GPpvCIeJQe5qWoQZG2CyNknyVR4qWoQf2C0GQ5XI)uLPjkfzoaYpxXHGDuBKFyOcKKH(0SYkberuRPuKsrN9t9VDaz3ua6ypJguXHGDuBZbz6TPGIsEwCW0NkorIrvIoE2yOpK0aNN5WovkdSh40MPhire16dk(d9gkmrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)L8S4GPpvCIeJQe5qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMcqh7z0GkoeSJABoitVTjkP84b6NIjngWouWhmDtS4Gsrn6ijeN)2IOGiIyXbLIA0rsio)vcOOKNfhm9PItKyuLihc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZ0Xd0pfhc2rnkSttainyVRUeuyRZU(Srnj3avGgMO84b6NIjngWouWhmDIiIfhukQrhjH48x5mfL8S4GPpvCIeJQe5qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMoEG(PysJbSdf8bt3eloOuuJoscX5VYXsEwCW0NkorIrvICiyh1OKgJCct3CyNknyVR4qWoQf2C0GQ5XI))sd27koeSJAHnhnOIKLuppw8VKNfhm9PItKyuLihc2rnkPXiNW0nh2Psd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MmcuQUraOKvXHGDutZrWnyjploy6tfNiXOkruAk4dMU5q)WianonStLKDwzioZsTfjbMd9dJa040qsseaYhsv2s(sEwCW0NkbpeGd(GPpPkLditpqZDMePAZsrDAGocyEAqDIN5s5bisvwZHDQs5aY0duzZsrDAGocqvMMmcuQUraOKvHstbFW0n1Akdqh7z0GQj0WoD98YGKiIcqh7z0GQdjnYGh6pomOOKNfhm9PsWdb4Gpy6tIrvIs5aY0d0CNjrQ2SuuNgOJaMNguN4zUuEaIuL1CyNQuoGm9av2SuuNgOJauLPjAWExXHGDuBKFyOaYp3KiZbq(5koeSJAJ8ddvGKm0NMOmaDSNrdQMqd701ZldsIikaDSNrdQoK0idEO)4WGIsEwCW0NkbpeGd(GPpjgvjkLditpqZDMeP2Hop00GHBEAqDIN5s5bisvwZHDQ0G9UIdb7OwyZrdQMhl(tLgS3vCiyh1cBoAqfjlPEES4VPwtd27QaCG6SRp7aXPc0Wuh2yF6ajzOp)LkLusYo3svS4GPR4qWoQPh88uICEu0IzXbtxXHGDutp45Pqjrb4H6dsIuuYtOQvoaE2yulxBhCmAx78yXFeOwBoitVDTzul0RfLefGhwBWEdw7h8SRLWjjnhaKOFL8S4GPpvcEiah8btFsmQsukhqMEGM7mjsfjnYpmqannhb3GMNguN4zUuEaIuPb7Dfhc2rTnhKP3wnpw8NknyVR4qWoQT5Gm92ksws98yXFIiIYa0XEgnOIdb7OMojP5aGe9Z0XrdEkBKhNTYqC)kHsafL8S4GPpvcEiah8btFsmQsukhqMEGM7mjsDWZtZgAWjAoa2zWXrvMMNguN4zoStLgS3vCiyh1g5hgkqdtukLditpq1GNNMn0GtKQmjIOdsIMLQuoGm9avdEEA2qdorIjReqH5s5bis9GKyjpHQ2woeSJ12QrcaBAxBdukoRLRvkhqMEG1YKjOF1M9AfaH51sdE1(Hemg1coXA5A7d(QfNhKKpy61AJbQQ9hBS2jKuuRrKsHaiqTbsYqFQrjnqXHa1IsAe4CctVwGeN165v7xg)R9dhJA7zuRrKaWM21caI1EzTNnwlnymV2168bgyTzV2ZgRvaeQsEwCW0NkbpeGd(GPpjgvjkLditpqZDMePIZdsYhcOzdTiZbq(5MNguN4zUuEaIuPuK5ai)Cfhc2rTr(HHcam4dMElMszBbOuMkzkHTyr6aGWtXHGDuBejaSPTky)pfuqrlaLhKeBbKYbKPhOAWZtZgAWjsrjploy6tLGhcWbFW0NeJQeLYbKPhO5otIupijQb9do0SH5Pb1jEMd7ufPdacpfhc2rTrKaWM2MlLhGivPCaz6bQW5bj5db0SHwK5ai)8sEwCW0NkbpeGd(GPpjgvjkLditpqZDMePEqsud6hCOzdZtdQt8mh2P2Ar6aGWtXHGDuBejaSPT5s5bisvK5ai)Cfhc2rTr(HHkqsg6ZsEcvTe6ibJrTa4GBxBl3Q1cAu7L1kxzorrT9mQ9N8AjL8S4GPpvcEiah8btFsmQsukhqMEGM7mjs9GKOg0p4qZgMNgujzjnxkparQImha5NRUeuyRZU(Srnj3avbsYqFAoStLsrMdG8ZvxckS1zxF2OMKBGQajzOpBbKYbKPhO6GKOg0p4qZgu8RCLzjpHQwlOlWALdbPBxlCw7euyxlxRr(HrhCu7fq)pE12ZO2wQ3oGSBETFibJrTZdk(x7L1E2yT3xwlj0bpSwrBXaRf0p4O2pS2g8QLR1g2yxl6jyJDTb7)Rn71AejaSPDjploy6tLGhcWbFW0NeJQeLYbKPhO5otIupijQb9do0SH5PbvswsZLYdqK6fq)pEQzcog4DqVrhG0TvImha5NRcKKH(0CyNQiDaq4P4qWoQnIea202KiDaq4P4qWoQnIea20wfS))xjWe2cbHggiGAMGJbEh0B0biDBtIuk6SFQ)Tdi7Mcqh7z0GkoeSJABoitVDjpHQwcDKGXOwaCWTR9N8Aj1cAu7L1kxzorrT9mQTLB1sEwCW0NkbpeGd(GPpjgvjkLditpqZDMePANdaO3OV8inpnOoXZCP8aePkYCaKFU6sqHTo76Zg1KCdufid02KuoGm9avhKe1G(bhA24x5kZsEcvTYHmaK9Rwldo(xlqIZA98QfssIaq(Wr7AnaVAbnQ9SXALcoCmyA4aETRfaPb79ANzTWRwb71sJ1ca7DOaCC1EzTaWPadV2ZMVA)qccSw(Q9SXAj0GrE21kfC4yW0Wb8Ax78yX)sEwCW0NkbpeGd(GPpjgvjkLditpqZDMeP2sdopn4eb0tdo(BEAqDIN5s5bisLsJaLQBeakzvbdaz)0tdo(tergbkv3iauYvfmaK9tpn44prezeOuDJaqjHQGbGSF6Pbh)PWeasd27QGbGSF6Pbh)1sbhogmnCaV2kG8Zl5zXbtFQe8qao4dM(KyuLOuoGm9an3zsKAcEtiaQZUwK5ai)8P5Pb1jEMlLhGivAWExXHGDuBKFyOaYp3enyVRcqh1zxBKFyOaYp3easd27Qlbf26SRpButYnqfq(5MATuoGm9avT0GZtdora90GJ)MaqAWExfmaK9tpn44Vwk4WXGPHd41wbKFEjploy6tLGhcWbFW0NeJQeLYbKPhO5otIuNhl(RT5Gm92MNguN4zUuEaIudqh7z0GkoeSJABoitVTjkPuKsrN9t9VDaz3KiZbq(5QGbGSF6Pbh)vbsYqF(RuoGm9av2CqMEB98yXF9bjrkOOKVKNqvBRgWmGhKqdwl4e6n12eW5ODTqbumWA)GNDTSHQ2wWjwl8Q9dE21E5rwBE2y8bNOQKNfhm9PsK5ai)8j1EKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAsK5ai)Cfhc2rTr(HHkqsg6tZkHY0KiZbq(5Qlbf26SRpButYnqvGmqBtusd27koeSJAHnhnOAES4)VuLYbKPhO6YJutYsQf2C0Gttus5Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQncatImha5NR4qWoQnYpmubsYqFAwPCaz6bQU8i1KSKAaCWT19m0SbfereLT(4b6NkaDuNDTr(HHjrMdG8ZvCiyh1g5hgQajzOpnRuoGm9avxEKAswsnao426EgA2GcIisK5ai)Cfhc2rTr(HHkqsg6ZFP2iaOGIsEwCW0NkrMdG8ZNeJQe7ropTNszZHDQbOJ9mAqvtaNJ2AOakgOjrMdG8ZvCiyh1g5hgQazG2MOS1hpq)uOpGn2h6iarer5Xd0pf6dyJ9HocyIKDwzioZsTvitkOWeLukYCaKFU6sqHTo76Zg1KCdufijd9PzLvMMOb7Dfhc2rTWMJgunpw8NknyVR4qWoQf2C0Gksws98yXFkiIikfzoaYpxDjOWwND9zJAsUbQcKKH(KQmnrd27koeSJAHnhnOAES4pvzsbfMOb7Dva6Oo7AJ8ddfq(5MizNvgIZSuLYbKPhOIn0KqhscsQjzN1gIRKNfhm9PsK5ai)8jXOkXEKZJohN5Wo1a0XEgnOcaofqJb05OTwKKKSdysK5ai)CfnyVRbGtb0yaDoARfjjj7aQazG2MOb7DfaCkGgdOZrBTijjzhq3JCEkG8ZnrjnyVR4qWoQnYpmua5NBIgS3vbOJ6SRnYpmua5NBcaPb7D1LGcBD21NnQj5gOci)CkmjYCaKFU6sqHTo76Zg1KCdufijd9jvzAIsAWExXHGDulS5ObvZJf))LQuoGm9avxEKAswsTWMJgCAIskpEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)sTraysK5ai)Cfhc2rTr(HHkqsg6tZkLditpq1LhPMKLudGdUTUNHMnOGiIOS1hpq)ubOJ6SRnYpmmjYCaKFUIdb7O2i)Wqfijd9PzLYbKPhO6YJutYsQbWb3w3ZqZguqerImha5NR4qWoQnYpmubsYqF(l1gbafuuYZIdM(ujYCaKF(KyuLyhgOMEWZZCyNAa6ypJgubaNcOXa6C0wlsss2bmjYCaKFUIgS31aWPaAmGohT1IKKKDavGmqBt0G9UcaofqJb05OTwKKKSdO7Wava5NBYiqP6gbGswvpY5rNJRKNqvBRYWO2ws(tTFWZU2wUvRf2RfEemRvKKqVPwqJANz6QABL9AHxTFWXOwASwWjcu7h8SR9N8AjMxRGNxTWR25a2yFJ21sJ9mWsEwCW0NkrMdG8ZNeJQejHrKXuND9Lbj6N5WovrMdG8ZvxckS1zxF2OMKBGQajzOp)vkhqMEGkY80gbkqeqF5rQPBterukLditpq1bjrnOFWHMnmRuoGm9avK5Pjzj1a4GBR7zOzdtImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQiZttYsQbWb3w3ZqF5rsrjploy6tLiZbq(5tIrvIKWiYyQZU(YGe9ZCyNQiZbq(5koeSJAJ8ddvGmqBtu26JhOFk0hWg7dDeGiIO84b6Nc9bSX(qhbmrYoRmeNzP2kKjfuyIskfzoaYpxDjOWwND9zJAsUbQcKKH(0Ss5aY0duXgAswsnao426Eg6lpst0G9UIdb7OwyZrdQMhl(tLgS3vCiyh1cBoAqfjlPEES4pfereLImha5NRUeuyRZU(Srnj3avbsYqFsvMMOb7Dfhc2rTWMJgunpw8NQmPGct0G9UkaDuNDTr(HHci)CtKSZkdXzwQs5aY0duXgAsOdjbj1KSZAdXvYtOQTLhFC7zTGtSwaKpB6mCS2p4zxlBOQTv2R9YJSw4S2azG21YZA)WXW8Aj5)yTtWaR9YAf88QfE1sJ9mWAV8ivL8S4GPpvImha5NpjgvjcG8ztNHJMd7ufzoaYpxDjOWwND9zJAsUbQcKbABIgS3vCiyh1cBoAq18yX)FPkLditpq1LhPMKLulS5ObNMezoaYpxXHGDuBKFyOcKKH(8xQncGsEwCW0NkrMdG8ZNeJQebq(SPZWrZHDQImha5NR4qWoQnYpmubYaTnrzRpEG(PqFaBSp0raIiIYJhOFk0hWg7dDeWej7SYqCMLARqMuqHjkPuK5ai)C1LGcBD21NnQj5gOkqsg6tZkRmnrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)uqerukYCaKFU6sqHTo76Zg1KCdufid02enyVR4qWoQf2C0GQ5XI)uLjfuyIgS3vbOJ6SRnYpmua5NBIKDwzioZsvkhqMEGk2qtcDijiPMKDwBiUsEcvTTGtS2Pbh)Rf2R9YJSw2bQLnQLdS20Rvaul7a1(LobxT0yTGg12ZO2r6nyu7zZETNnwljlzTa4GBBETK8FO3u7emWA)WATzPyT8v7a55v79L1YHGDSwHnhn4Sw2bQ9S5R2lpYA)4PtWvBln48QfCIaQsEwCW0NkrMdG8ZNeJQedgaY(PNgC83CyNQiZbq(5Qlbf26SRpButYnqvGKm0NMvkhqMEGQyQjzj1a4GBR7zOV8injYCaKFUIdb7O2i)Wqfijd9PzLYbKPhOkMAswsnao426EgA2WeLhpq)ubOJ6SRnYpmmrPiZbq(5Qa0rD21g5hgQajzOp)fLefGhQpijserImha5NRcqh1zxBKFyOcKKH(0Ss5aY0duftnjlPgahCBDpdDKguqerT(4b6NkaDuNDTr(HbfMOb7Dfhc2rTWMJgunpw83SY1easd27Qlbf26SRpButYnqfq(5MOb7Dva6Oo7AJ8ddfq(5MOb7Dfhc2rTr(HHci)8sEcvTTGtS2Pbh)R9dE21Yg1(zJETg5CcPhOQ2wzV2lpYAHZAdKbAxlpR9dhdZRLK)J1obdS2lRvWZRw4vln2ZaR9YJuvYZIdM(ujYCaKF(KyuLyWaq2p90GJ)Md7ufzoaYpxDjOWwND9zJAsUbQcKKH(8xusuaEO(GKOjAWExXHGDulS5ObvZJf))LQuoGm9avxEKAswsTWMJgCAsK5ai)Cfhc2rTr(HHkqsg6ZFPeLefGhQpijsmwCW0vxckS1zxF2OMKBGkusuaEO(GKifL8S4GPpvImha5NpjgvjgmaK9tpn44V5WovrMdG8ZvCiyh1g5hgQajzOp)fLefGhQpijAIskB9Xd0pf6dyJ9HocqeruE8a9tH(a2yFOJaMizNvgIZSuBfYKckmrjLImha5NRUeuyRZU(Srnj3avbsYqFAwPCaz6bQydnjlPgahCBDpd9LhPjAWExXHGDulS5ObvZJf)Psd27koeSJAHnhnOIKLuppw8NcIiIsrMdG8ZvxckS1zxF2OMKBGQajzOpPktt0G9UIdb7OwyZrdQMhl(tvMuqHjAWExfGoQZU2i)WqbKFUjs2zLH4mlvPCaz6bQydnj0HKGKAs2zTH4OOKNqvBl4eR9YJS2p4zxlBulSxl8iyw7h8SHETNnwljlzTa4GBRQTv2R1ZZ8AbNyTFWZU2inQf2R9SXApEG(vlCw7X)r38AzhOw4rWS2p4zd9ApBSwswYAbWb3wvYZIdM(ujYCaKF(KyuL4LGcBD21NnQj5gO5WovAWExXHGDulS5ObvZJf))LQuoGm9avxEKAswsTWMJgCAsK5ai)Cfhc2rTr(HHkqsg6ZFPIsIcWd1hKenrYoRmeNzLYbKPhOIn0KqhscsQjzN1gIZenyVRcqh1zxBKFyOaYpVKNfhm9PsK5ai)8jXOkXlbf26SRpButYnqZHDQ0G9UIdb7OwyZrdQMhl()lvPCaz6bQU8i1KSKAHnhn400Xd0pva6Oo7AJ8ddtImha5NRcqh1zxBKFyOcKKH(8xQOKOa8q9bjrts5aY0duDqsud6hCOzdZkLditpq1LhPMKLudGdUTUNHMnk5zXbtFQezoaYpFsmQs8sqHTo76Zg1KCd0CyNknyVR4qWoQf2C0GQ5XI))svkhqMEGQlpsnjlPwyZrdonrzRpEG(Pcqh1zxBKFyqerImha5NRcqh1zxBKFyOcKKH(0Ss5aY0duD5rQjzj1a4GBR7zOJ0Gcts5aY0duDqsud6hCOzdZkLditpq1LhPMKLudGdUTUNHMnk5ju12coXAzJAH9AV8iRfoRn9Afa1YoqTFPtWvlnwlOrT9mQDKEdg1E2Sx7zJ1sYswlao42Mxlj)h6n1obdS2ZMVA)WATzPyTONGn21sYoxl7a1E28v7zJbwlCwRNxT8iqgODTCTbOJ1M9AnYpmQfi)Cvjploy6tLiZbq(5tIrvICiyh1g5hgMd7ufzoaYpxDjOWwND9zJAsUbQcKKH(0Ss5aY0duXgAswsnao426Eg6lpstu2ArkfD2pLu0p72brejYCaKFUIegrgtD21xgKOFQajzOpnRuoGm9avSHMKLudGdUTUNHMmpkmrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MOb7Dva6Oo7AJ8ddfq(5MizNvgIZSuLYbKPhOIn0KqhscsQjzN1gIRKNqvBl4eRnsJAH9AV8iRfoRn9Afa1YoqTFPtWvlnwlOrT9mQDKEdg1E2Sx7zJ1sYswlao42Mxlj)h6n1obdS2ZgdSw40j4QLhbYaTRLRnaDSwG8ZRLDGApB(QLnQ9lDcUAPrrsI1Ysz4GPhyTaGb0BQnaDuvYZIdM(ujYCaKF(KyuLya6Oo7AJ8ddZHDQ0G9UIdb7O2i)WqbKFUjkfzoaYpxDjOWwND9zJAsUbQcKKH(0Ss5aY0dufPHMKLudGdUTUNH(YJKiIezoaYpxXHGDuBKFyOcKKH(8xQs5aY0duD5rQjzj1a4GBR7zOzdkmrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MezoaYpxXHGDuBKFyOcKKH(0SYk3sEwCW0NkrMdG8ZNeJQeN2W(b9gTr(HH5WovPCaz6bQsWBcbqD21Imha5Npl5ju12coXAnsYAVS2zleercnyTSxlk5fCTmDTqV2ZgR1rjVAfzoaYpV2pOdKFMxlOpW5S2)Tdi71E2OxB6J21cagqVPwoeSJ1AKFyulaiw7L1ANF1sYoxRnO3eTRnyai7xTtdo(xlCwYZIdM(ujYCaKF(KyuLOrGt0fOo7AsOdyoSt94b6NkaDuNDTr(HHjAWExXHGDuBKFyOanmrd27Qa0rD21g5hgQajzOp)TraOizjl5zXbtFQezoaYpFsmQs0iWj6cuNDnj0bmh2PcG0G9U6sqHTo76Zg1KCdubAycaPb7D1LGcBD21NnQj5gOkqsg6ZFzXbtxXHGDutcNt4aNkusuaEO(GKOPwlsPOZ(P(3oGSxYZIdM(ujYCaKF(KyuLOrGt0fOo7AsOdyoStLgS3vbOJ6SRnYpmuGgMOb7Dva6Oo7AJ8ddvGKm0N)2iauKSKMezoaYpxHstbFW0vbYaTnjYCaKFU6sqHTo76Zg1KCdufijd9PPwlsPOZ(P(3oGSxYxYZIdM(u1Hop00GHtLdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXzUWMHovzl5zXbtFQ6qNhAAWWjgvjYHGDutp45vYZIdM(u1Hop00GHtmQsKdb7OMMJGBWs(sEcvTe62OxBa6o0BQfHNng1E2yTww1MrT)qOx7aBqhGdionV2pS2p2VAVSw5aPzT0ypdS2ZgR9N8AjsSLB1A)Goq(PQTfCI1cVA5zTZm9A5zTYHzRwRnpRTdD40gbQnbJA)qcKI1onq)QnbJAf2C0GZsEwCW0NQoCAd9gDAGogurPPGpy6Md7uPmaDSNrdQoK0idEO)4WGiIOmaDSNrdQMqd701ZldstTwkhqMEGkJanahdnknPklfuyIsAWExfGoQZU2i)WqbKForezeOuDJaqjRIdb7OMMJGBqkmjYCaKFUkaDuNDTr(HHkqsg6ZsEcvTTYETFibsXA7qhoTrGAtWOwrMdG8ZR9d6a53Sw2bQDAG(vBcg1kS5ObNMxRraZaEqcnyTYbsZAtPyulkfJ2Nn0BQfhtSKNfhm9PQdN2qVrNgOJbXOkruAk4dMU5Wo1JhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd9PjrMdG8ZvCiyh1g5hgQajzOpnrd27koeSJAJ8ddfq(5MOb7Dva6Oo7AJ8ddfq(5MmcuQUraOKvXHGDutZrWnyjploy6tvhoTHEJonqhdIrvIDyGA6bppZHDQbOJ9mAqfaCkGgdOZrBTijjzhWenyVRaGtb0yaDoARfjjj7a6EKZtbAuYZIdM(u1HtBO3Otd0XGyuLypY5P9ukBoStnaDSNrdQAc4C0wdfqXanrYoRmeNzLZsqjploy6tvhoTHEJonqhdIrvICiyh1KW5eoWP5Wo1a0XEgnOIdb7O2MdY0BBIgS3vCiyh12CqMEB18yX)FPb7Dfhc2rTnhKP3wrYsQNhl(BIskPb7Dfhc2rTr(HHci)CtImha5NR4qWoQnYpmubYaTPGiIaqAWExDjOWwND9zJAsUbQanOWCHndDQYwYZIdM(u1HtBO3Otd0XGyuLya6Oo7AJ8ddZHDQbOJ9mAq1eAyNUEEzqwYZIdM(u1HtBO3Otd0XGyuLihc2rDg0Md7ufzoaYpxfGoQZU2i)Wqfid0UKNfhm9PQdN2qVrNgOJbXOkroeSJA6bppZHDQImha5NRcqh1zxBKFyOcKbABIgS3vCiyh1cBoAq18yX)FPb7Dfhc2rTWMJgurYsQNhl(xYZIdM(u1HtBO3Otd0XGyuLiaYNnDgoAoStT1bOJ9mAq1HKgzWd9hhgerKiDaq4PAG9tND9zJ6buyxYZIdM(u1HtBO3Otd0XGyuLya6Oo7AJ8dJsEcvTTYETFibbwlF1sYsw78yX)zTzVwcHqQLDGA)WATzPOtWvl4ebQTLK)uBB8mVwWjwlx78yX)AVSwJaLI(vljOlSHEtTG(aNZAdq3HEtTNnwlH2CqME7Ahyd6aC0UKNfhm9PQdN2qVrNgOJbXOkroeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjAWExjgihcEEqVrnpw8NknyVRedKdbppO3Oizj1ZJf)njsPOZ(PKI(z3omjYCaKFUIegrgtD21xgKOFQazG2MATuoGm9aviPr(HbcOP5i4g0KiZbq(5koeSJAJ8ddvGmq7sEcvTepdsEmAx7hwRbdJAnYdMETGtS2p4zxBl3QMxln4vl8Q9dog1o45v7i9MArpbBSRTNrT05zx7zJ1khMTATSduBl3Q1(bDG8BwlOpW5S2a0DO3u7zJ1AzvBg1(dHETdSbDaoG4SKNfhm9PQdN2qVrNgOJbXOkrJ8GPBoStT1bOJ9mAq1HKgzWd9hhgMOS1bOJ9mAq1eAyNUEEzqsers5aY0duzeOb4yOrPjvzPOKNfhm9PQdN2qVrNgOJbXOkraKpB6mC0CyNknyVRcqh1zxBKFyOaYpNiImcuQUraOKvXHGDutZrWnyjploy6tvhoTHEJonqhdIrvIbdaz)0tdo(BoStLgS3vbOJ6SRnYpmua5Ntergbkv3iauYQ4qWoQP5i4gSKNfhm9PQdN2qVrNgOJbXOkrsyezm1zxFzqI(zoStLgS3vbOJ6SRnYpmubsYqF(lLYjIj3wCa6ypJgunHg2PRNxgKuuYtOQLq3g9Adq3HEtTNnwlH2CqME7Ahyd6aC028AbNyTTCRwln2ZaR9N8Aj1EzTaGKg1Y12bhJ21opw8hbQLMdoAWsEwCW0NQoCAd9gDAGogeJQe5qWoQnYpmmh2PkLditpqfsAKFyGaAAocUbnrd27Qa0rD21g5hgkqdtusYoRme3VukxjGyukRmBXIuk6SFQ)Tdi7uqbrerd27kXa5qWZd6nQ5XI)uPb7DLyGCi45b9gfjlPEES4pfL8S4GPpvD40g6n60aDmigvjYHGDutZrWnO5WovPCaz6bQqsJ8ddeqtZrWnOjAWExXHGDulS5ObvZJf)Psd27koeSJAHnhnOIKLuppw83enyVR4qWoQnYpmuGgL8S4GPpvD40g6n60aDmigvjEjOWwND9zJAsUbAoStLgS3vbOJ6SRnYpmua5Ntergbkv3iauYQ4qWoQP5i4gKiImcuQUraOKvfmaK9tpn44prezeOuDJaqjRca5ZModhl5zXbtFQ6WPn0B0Pb6yqmQsKdb7O2i)WWCyNQrGs1ncaLSQlbf26SRpButYnWsEcvTTGtS2wnBj1EzTZwiiIeAWAzVwuYl4AB5qWowlHh88QfamGEtTNnw7p51sKyl3Q1(bDG8RwqFGZzTbO7qVP2woeSJ1khiStvTTYETTCiyhRvoqyN1cN1E8a9dbmV2pSwb7eC1coXAB1SLu7h8SHETNnw7p51sKyl3Q1(bDG8RwqFGZzTFyTq)WianUApBS2wULuRWMDhhMx7mR9djymQDYsXAHNQKNfhm9PQdN2qVrNgOJbXOkrJaNOlqD21KqhWCyNARpEG(P4qWoQrHDAcaPb7D1LGcBD21NnQj5gOc0Weasd27Qlbf26SRpButYnqvGKm0N)sLswCW0vCiyh10dEEkusuaEO(GKylMgS3vgborxG6SRjHoGIKLuppw8NIsEcvTTYETTA2sQ1MNobxT0i61corGAbadO3u7zJ1(tETKA)Goq(zETFibJrTGtSw4v7L1oBHGisObRL9ArjVGRTLdb7yTeEWZRwOx7zJ1khMTQeB5wT2pOdKFQsEwCW0NQoCAd9gDAGogeJQencCIUa1zxtcDaZHDQ0G9UIdb7O2i)WqbAyIgS3vbOJ6SRnYpmubsYqF(lvkzXbtxXHGDutp45Pqjrb4H6dsITyAWExze4eDbQZUMe6aksws98yXFkk5zXbtFQ6WPn0B0Pb6yqmQsKdb7OMEWZZCyNkqEQGbGSF6Pbh)vbsYqFAwjGiIaqAWExfmaK9tpn44Vwk4WXGPHd41wnpw83SYSKNqvlHow7h7xTxwlj)hRDcgyTFyT2SuSw0tWg7AjzNRTNrTNnwl6hmWAB5wT2pOdKFMxlkf9AH9ApBmqcM1op4yu7bjXAdKKHo0BQn9ALdZwvvBR8iywB6J21sJ3HrTxwlny41EzTeAWiRLDGALdKM1c71gGUd9MApBSwlRAZO2Fi0RDGnOdWbeNQsEwCW0NQoCAd9gDAGogeJQe5qWoQP5i4g0CyNQiZbq(5koeSJAJ8ddvGmqBtKSZkdX9lLYrzsmkLvMTyrkfD2p1)2bKDkOWenyVR4qWoQf2C0GQ5XI)uPb7Dfhc2rTWMJgurYsQNhl(BIYwhGo2ZObvtOHD665LbjrejLditpqLrGgGJHgLMuLLctToaDSNrdQoK0idEO)4WWuRdqh7z0GkoeSJABoitVDjpHQwcZrWnyTt7eCauRNxT0yTGteOw(Q9SXArhO2SxBl3Q1c71khinf8btVw4S2azG21YZAbI0Wa6n1kS5ObN1(bhJAj5)yTWR2J)J1osVbJAVSwAWWR9SJeSXU2ajzOd9MAjzNl5zXbtFQ6WPn0B0Pb6yqmQsKdb7OMMJGBqZHDQ0G9UIdb7O2i)WqbAyIgS3vCiyh1g5hgQajzOp)LAJaWKiZbq(5kuAk4dMUkqsg6ZsEcvTeMJGBWAN2j4aOwE8XTN1sJ1E2yTdEE1k45vl0R9SXALdZwT2pOdKF1YZA)jVwsTFWXO2aNxgyTNnwRWMJgCw70a9RKNfhm9PQdN2qVrNgOJbXOkroeSJAAocUbnh2Psd27Qa0rD21g5hgkqdt0G9UIdb7O2i)WqbKFUjAWExfGoQZU2i)Wqfijd95VuBeaMADa6ypJguXHGDuBZbz6Tl5zXbtFQ6WPn0B0Pb6yqmQsKdb7OMeoNWbonh2PcG0G9U6sqHTo76Zg1KCdubAy64b6NIdb7Ogf2PjkPb7DfaYNnDgoQaYpNiIyXbLIA0rsioPklfMaqAWExDjOWwND9zJAsUbQcKKH(0SS4GPR4qWoQjHZjCGtfkjkapuFqs0CHndDQYAoYXOTwyZqxd7uPb7DLyGCi45b9gTWMDhhkG8ZnrjnyVR4qWoQnYpmuGgereLT(4b6NkLIHr(HbcyIsAWExfGoQZU2i)WqbAqerImha5NRqPPGpy6QazG2uqbfL8eQABL9A)qccSwPOF2TdZRfssIaq(Wr7AbNyTecHu7Nn61kyddeO2lR1ZR2pEEyTgrkM12JKS2ws(tjploy6tvhoTHEJonqhdIrvICiyh1KW5eoWP5WovrkfD2pLu0p72HjAWExjgihcEEqVrnpw8NknyVRedKdbppO3Oizj1ZJf)l5ju1ADCC1coHEtTecHuBl3sQ9Zg9AB5wTwBEwlnIETGteOKNfhm9PQdN2qVrNgOJbXOkroeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjrMdG8ZvCiyh1g5hgQajzOpnrjnyVRcqh1zxBKFyOaniIiAWExXHGDuBKFyOanOWCHndDQYwYZIdM(u1HtBO3Otd0XGyuLihc2rDg0Md7uPb7Dfhc2rTWMJgunpw8)xQs5aY0duD5rQjzj1cBoAWzjploy6tvhoTHEJonqhdIrvICiyh10dEEMd7uPb7Dva6Oo7AJ8ddfObrerYoRmeNzLvck5zXbtFQ6WPn0B0Pb6yqmQseLMc(GPBoStLgS3vbOJ6SRnYpmua5NBIgS3vCiyh1g5hgkG8Znh6hgbOXPHDQKSZkdXzwQTijWCOFyeGgNgssIaq(qQYwYZIdM(u1HtBO3Otd0XGyuLihc2rnnhb3GL8L8ekcvTTG(e0WiJdbQvWUahAwCW0BP6ALdKMc(GPx7hCmQLgR15dm4XODT0r(h9AH9AfPdapy6ZA5aRLepvjpHIqvlloy6tLnhKP3MQGDbo0S4GPBoStLfhmDfknf8btxjSz3Xb0BmrYoRmeNzPkNLGsEcvTTYETJ8R20RLKDUw2bQvK5ai)8zTCG1kssO3ulOH512K1Y2idul7a1IsZsEwCW0NkBoitVnXOkruAk4dMU5Wovs2zLH4(LQektts5aY0duLG3ecG6SRfzoaYpFAIYJhOFQa0rD21g5hgMezoaYpxfGoQZU2i)Wqfijd95VYktkk5ju1sOJ1(X(v7L1opw8VwBoitVDTDWXOTQ2FSXAbNyTzVwzLt1opw8FwRngyTWzTxwllejOF12ZO2ZgR9GI)1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uL8S4GPpv2CqMEBIrvICiyh1KW5eoWP5WovkLYbKPhOAES4V2MdY0BterhKe)vwzsHjAWExXHGDuBZbz6TvZJf))vw5K5cBg6uLTKNqvlHUn61coHEtTYbKgTdKh12sjaC2fO51k45vlxBh)QfL8cUws4Cch4S2pB4aR9JHh0BQTNrTNnwlnyVxlF1E2yTZJJR2Sx7zJ12Hn2xjploy6tLnhKP3MyuLihc2rnjCoHdCAoStfBHGqddeqHKgTdKh6maC2fOPdsI)kHY00LnndujYCaKF(0KiZbq(5kK0ODG8qNbGZUavbsYqFAwzLtTitTMfhmDfsA0oqEOZaWzxGka4KPhiqjploy6tLnhKP3MyuLyWaq2p90GJ)Md7uLYbKPhOcjnYpmqannhb3GMezoaYpxDjOWwND9zJAsUbQcKKH(8xQOKOa8q9bjrtImha5NR4qWoQnYpmubsYqF(lvkrjrb4H6dsITy5sHjkBn2cbHggiGAMGJbEh0B0biDBIisKoai8uCiyh1grcaBARc2)BwQsareDb0)JNAMGJbEh0B0biDBLiZbq(5QajzOp)LkLOKOa8q9bjXwSCPGIsEwCW0NkBoitVnXOkXlbf26SRpButYnqZHDQs5aY0du1sdopn4eb0tdo(BsK5ai)Cfhc2rTr(HHkqsg6ZFPIsIcWd1hKenrzRXwii0WabuZeCmW7GEJoaPBterI0baHNIdb7O2isaytBvW(FZsvciIOlG(F8uZeCmW7GEJoaPBRezoaYpxfijd95Vurjrb4H6dsIuuYZIdM(uzZbz6TjgvjYHGDuBKFyyoSt1iqP6gbGsw1LGcBD21NnQj5gyjploy6tLnhKP3MyuLya6Oo7AJ8ddZHDQs5aY0duHKg5hgiGMMJGBqtImha5NRcgaY(PNgC8xfijd95Vurjrb4H6dsIMKYbKPhO6GKOg0p4qZgMLQCLPjkBTiDaq4P4qWoQnIea20MiIATuoGm9av84JBp1Z2UqlYCaKF(KiIezoaYpxDjOWwND9zJAsUbQcKKH(8xQuIsIcWd1hKeBXYLckk5zXbtFQS5Gm92eJQedgaY(PNgC83CyNQuoGm9aviPr(HbcOP5i4g0KrGs1ncaLSQa0rD21g5hgL8S4GPpv2CqMEBIrvIxckS1zxF2OMKBGMd7uLYbKPhOQLgCEAWjcONgC83uRLYbKPhOYohaqVrF5rwYZIdM(uzZbz6TjgvjgGoQZU2i)WWCyNknyVR4qWoQnYpmua5NBIsPCaz6bQoijQb9do0SHzLqzserImha5NRcgaY(PNgC8xfijd9PzLvUuyIYwlshaeEkoeSJAJibGnTjIOwlLditpqfp(42t9STl0Imha5NpPOKNfhm9PYMdY0BtmQsmyai7NEAWXFZHDQs5aY0duHKg5hgiGMMJGBqtusd27koeSJAHnhnOAES4VzPkxIisK5ai)Cfhc2rDg0QazG2uyIYwF8a9tfGoQZU2i)WGiIezoaYpxfGoQZU2i)Wqfijd9PzLakmjLditpqfopijFiGMn0Imha5NBwQsOmnrzRfPdacpfhc2rTrKaWM2eruRLYbKPhOIhFC7PE22fArMdG8ZNuuYtOQLq3g9Adq3HEtTgrcaBABETGtS2lpYAPBxl8M4Oxl0RndamQ9YA5bSXRfE1(bp7AzJsEwCW0NkBoitVnXOkXlbf26SRpButYnqZHDQs5aY0duDqsud6hCOzJFLazAskhqMEGQdsIAq)GdnBywjuMMOS1yleeAyGaQzcog4DqVrhG0TjIir6aGWtXHGDuBejaSPTky)VzPkbuuYZIdM(uzZbz6TjgvjYHGDuNbT5WovPCaz6bQAPbNNgCIa6Pbh)nrd27koeSJAHnhnOAES4)V0G9UIdb7OwyZrdQizj1ZJf)l5zXbtFQS5Gm92eJQe5qWoQP5i4g0CyNkasd27QGbGSF6Pbh)1sbhogmnCaV2Q5XI)ubqAWExfmaK9tpn44Vwk4WXGPHd41wrYsQNhl(xYZIdM(uzZbz6TjgvjYHGDutp45zoStvkhqMEGQwAW5PbNiGEAWXFIiIsaKgS3vbdaz)0tdo(RLcoCmyA4aETvGgMaqAWExfmaK9tpn44Vwk4WXGPHd41wnpw8)xaKgS3vbdaz)0tdo(RLcoCmyA4aETvKSK65XI)uuYtOQTfCI1MbDTPxRaOwqFGZzTSrTWzTIKe6n1cAu7mtVKNfhm9PYMdY0BtmQsKdb7OodAZHDQ0G9UIdb7OwyZrdQMhl()ReAskhqMEGQdsIAq)GdnBywzLzjploy6tLnhKP3MyuLihc2rnjCoHdCAoStLgS3vIbYHGNh0BubYIZenyVR4qWoQnYpmuGgMlSzOtv2sEcvTTYETFyTn4vRr(HrTqVdoHPxlaya9MAhGZR2pKGXOwBwkwl6jyJDT288WAVS2g8Qn79A5ANxKEtT0CeCdwlaya9MApBS2inKiBu7h0bYVsEwCW0NkBoitVnXOkroeSJAAocUbnh2Psd27Qa0rD21g5hgkqdt0G9UkaDuNDTr(HHkqsg6ZFPYIdMUIdb7OMeoNWbovOKOa8q9bjrt0G9UIdb7O2i)WqbAyIgS3vCiyh1cBoAq18yXFQ0G9UIdb7OwyZrdQizj1ZJf)nrd27koeSJABoitVTAES4VjAWExzKFyOHEhCctxbAyIgS3v0JmbgGZtbAuYtOQTv2R9dRTbVAnYpmQf6DWjm9AbadO3u7aCE1(Hemg1AZsXArpbBSR1MNhw7L12GxTzVxlx78I0BQLMJGBWAbadO3u7zJ1gPHezJA)Goq(zETZS2pKGXO20hTRfCI1IEc2yxl9GN3SwOdpipgTR9YABWR2lRTNGrTcBoAWzjploy6tLnhKP3MyuLihc2rn9GNN5WovAWExze4eDbQZUMe6akqdtusd27koeSJAHnhnOAES4)V0G9UIdb7OwyZrdQizj1ZJf)jIOwtjnyVRmYpm0qVdoHPRanmrd27k6rMadW5PanOGIsEcvT)yJ1sJZRwWjwB2R1ijRfoR9YAbNyTWR2lRTfccf)hTRLgeoaQvyZrdoRfamGEtTSrTC)WO2ZgBxBdE1casAGa1s3U2ZgR1MdY0Bxlnhb3GL8S4GPpv2CqMEBIrvIgborxG6SRjHoG5WovAWExXHGDulS5ObvZJf))LgS3vCiyh1cBoAqfjlPEES4VjAWExXHGDuBKFyOank5ju1sOJ1(X(v7L1opw8VwBoitVDTDWXOTQ2FSXAbNyTzVwzLt1opw8FwRngyTWzTxwllejOF12ZO2ZgR9GI)1oW(vB61E2yTcB2DCul7a1E2yTKW5eoWAHET9bSX(uL8S4GPpv2CqMEBIrvICiyh1KW5eoWP5WovAWExXHGDuBZbz6TvZJf))vw5K5cBg6uL1COFyeGghvznh6hgbOXPBgjnpOkBjploy6tLnhKP3MyuLihc2rnnhb3GMd7uPb7Dfhc2rTWMJgunpw8NknyVR4qWoQf2C0Gksws98yXFts5aY0duHKg5hgiGMMJGBWsEwCW0NkBoitVnXOkruAk4dMU5Wovs2zLH4(vwjOKNqvBlfF0UwWjwl9GNxTxwlniCauRWMJgCwlSx7hwlpcKbAxRnlfRDMKyT9ijRnd6sEwCW0NkBoitVnXOkroeSJA6bppZHDQ0G9UIdb7OwyZrdQMhl(BIgS3vCiyh1cBoAq18yX)FPb7Dfhc2rTWMJgurYsQNhl(xYtOQTLAWXO2p4zxltwlOpW5Sw2Ow4Swrsc9MAbnQLDGA)qccS2r(vB61sYoxYZIdM(uzZbz6TjgvjYHGDutcNt4aNMd7uBnLs5aY0duDqsud6hCOzJFPkRmnrYoRme3VsOmPWCHndDQYAo0pmcqJJQSMd9dJa040nJKMhuLTKNqvBRgzhoWzTFWZU2r(vljppmABET2Wg7AT55HMxBg1sNNDTKC7A98Q1MLI1IEc2yxlj7CTxw7e0WiJRw78Rws25AH(H(ekfRnyai7xTtdo(xRG9APrZRDM1(Hemg1coXA7WaRLEWZRw2bQTh58OZXv7Nn61oYVAtVws25sEwCW0NkBoitVnXOkXomqn9GNxjploy6tLnhKP3MyuLypY5rNJRKVKNfhm9PknqhdQDyGA6bppZHDQbOJ9mAqfaCkGgdOZrBTijjzhWenyVRaGtb0yaDoARfjjj7a6EKZtbAuYZIdM(uLgOJbXOkXEKZt7Pu2CyNAa6ypJgu1eW5OTgkGIbAIKDwzioZkNLGsEwCW0NQ0aDmigvjcG8ztNHJL8S4GPpvPb6yqmQsmyai7NEAWXFZHDQKSZkdXzw5Oml5zXbtFQsd0XGyuLijmImM6SRVmir)k5zXbtFQsd0XGyuL40g2pO3OnYpmmh2Psd27koeSJAJ8ddfq(5MezoaYpxXHGDuBKFyOcKKH(SKNfhm9PknqhdIrvICiyh1zqBoStvK5ai)Cfhc2rTr(HHkqgOTjAWExXHGDulS5ObvZJf))LgS3vCiyh1cBoAqfjlPEES4Fjploy6tvAGogeJQe5qWoQPh88mh2PksPOZ(PKI(z3omjYCaKFUIegrgtD21xgKOFQajzOpnBlsowYZIdM(uLgOJbXOkXlbf26SRpButYnWsEwCW0NQ0aDmigvjYHGDuBKFyuYZIdM(uLgOJbXOkXa0rD21g5hgMd7uPb7Dfhc2rTr(HHci)8sEcvTTGtS2wnBj1EzTZwiiIeAWAzVwuYl4AB5qWowlHh88QfamGEtTNnw7p51sKyl3Q1(bDG8RwqFGZzTbO7qVP2woeSJ1khiStvTTYETTCiyhRvoqyN1cN1E8a9dbmV2pSwb7eC1coXAB1SLu7h8SHETNnw7p51sKyl3Q1(bDG8RwqFGZzTFyTq)WianUApBS2wULuRWMDhhMx7mR9djymQDYsXAHNQKNfhm9PknqhdIrvIgborxG6SRjHoG5Wo1wF8a9tXHGDuJc70easd27Qlbf26SRpButYnqfOHjaKgS3vxckS1zxF2OMKBGQajzOp)LkLS4GPR4qWoQPh88uOKOa8q9bjXwmnyVRmcCIUa1zxtcDafjlPEES4pfL8eQABL9AB1SLuRnpDcUAPr0RfCIa1cagqVP2ZgR9N8Aj1(bDG8Z8A)qcgJAbNyTWR2lRD2cbrKqdwl71IsEbxBlhc2XAj8GNxTqV2ZgRvomBvj2YTATFqhi)uL8S4GPpvPb6yqmQs0iWj6cuNDnj0bmh2Psd27koeSJAJ8ddfOHjAWExfGoQZU2i)Wqfijd95VuPKfhmDfhc2rn9GNNcLefGhQpij2IPb7DLrGt0fOo7AsOdOizj1ZJf)POKNfhm9PknqhdIrvICiyh10dEEMd7ubYtfmaK9tpn44Vkqsg6tZkbereasd27QGbGSF6Pbh)1sbhogmnCaV2Q5XI)MvML8eQAB5Xh3EwlH5i4gSw(Q9SXArhO2SxBl3Q1(zJETbO7qVP2ZgRTLdb7yTeAZbz6TRDGnOdWr7sEwCW0NQ0aDmigvjYHGDutZrWnO5WovAWExXHGDuBKFyOanmrd27koeSJAJ8ddvGKm0N)2iamfGo2ZObvCiyh12CqME7sEcvTT84JBpRLWCeCdwlF1E2yTOduB2R9SXALdZwT2pOdKF1(zJETbO7qVP2ZgRTLdb7yTeAZbz6TRDGnOdWr7sEwCW0NQ0aDmigvjYHGDutZrWnO5WovAWExfGoQZU2i)WqbAyIgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgQajzOp)LAJaWua6ypJguXHGDuBZbz6Tl5zXbtFQsd0XGyuLihc2rnjCoHdCAoStfaPb7D1LGcBD21NnQj5gOc0W0Xd0pfhc2rnkSttusd27kaKpB6mCubKForeXIdkf1OJKqCsvwkmbG0G9U6sqHTo76Zg1KCdufijd9PzzXbtxXHGDutcNt4aNkusuaEO(GKO5cBg6uL1CKJrBTWMHUg2Psd27kXa5qWZd6nAHn7ooua5NBIsAWExXHGDuBKFyOaniIikB9Xd0pvkfdJ8ddeWeL0G9UkaDuNDTr(HHc0GiIezoaYpxHstbFW0vbYaTPGckk5zXbtFQsd0XGyuLihc2rnjCoHdCAoStLgS3vIbYHGNh0BuZJf)Psd27kXa5qWZd6nksws98yXFtIuk6SFkPOF2TJsEwCW0NQ0aDmigvjYHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mjYCaKFUIdb7O2i)Wqfijd9PjkPb7Dva6Oo7AJ8ddfObrerd27koeSJAJ8ddfObfMlSzOtv2sEwCW0NQ0aDmigvjYHGDuNbT5WovAWExXHGDulS5ObvZJf))LQuoGm9avxEKAswsTWMJgCwYZIdM(uLgOJbXOkroeSJA6bppZHDQ0G9UkaDuNDTr(HHc0GiIizNvgIZSYkbL8S4GPpvPb6yqmQseLMc(GPBoStLgS3vbOJ6SRnYpmua5NBIgS3vCiyh1g5hgkG8Znh6hgbOXPHDQKSZkdXzwQTijWCOFyeGgNgssIaq(qQYwYZIdM(uLgOJbXOkroeSJAAocUbl5l5jueQAzXbtFQI84dMovb7cCOzXbt3CyNkloy6kuAk4dMUsyZUJdO3yIKDwzioZsvolbMOS1bOJ9mAq1eAyNUEEzqser0G9UAcnStxpVmivZJf)Psd27Qj0WoD98YGurYsQNhl(trjpHQ2wWjwlknRf2R9djiWAh5xTPxlj7CTSduRiZbq(5ZA5aRLPtWR2lRLgRf0OKNfhm9PkYJpy6eJQerPPGpy6Md7ujzNvgI7xQs5aY0duHstTH4mrPiZbq(5Qlbf26SRpButYnqvGKm0N)sLfhmDfknf8btxHsIcWd1hKejIirMdG8ZvCiyh1g5hgQajzOp)Lkloy6kuAk4dMUcLefGhQpijseruE8a9tfGoQZU2i)WWKiZbq(5Qa0rD21g5hgQajzOp)Lkloy6kuAk4dMUcLefGhQpijsbfMOb7Dva6Oo7AJ8ddfq(5MOb7Dfhc2rTr(HHci)CtainyVRUeuyRZU(Srnj3ava5NBQ1gbkv3iauYQUeuyRZU(Srnj3al5zXbtFQI84dMoXOkruAk4dMU5Wo1a0XEgnOAcnStxpVminjYCaKFUIdb7O2i)Wqfijd95VuzXbtxHstbFW0vOKOa8q9bjXsEcvTeMJGBWAH9AHhbZApijw7L1coXAV8iRLDGA)WATzPyTxM1sYE7Af2C0GZsEwCW0NQip(GPtmQsKdb7OMMJGBqZHDQImha5NRUeuyRZU(Srnj3avbYaTnrjnyVR4qWoQf2C0GQ5XI)MvkhqMEGQlpsnjlPwyZrdonjYCaKFUIdb7O2i)Wqfijd95Vurjrb4H6dsIMizNvgIZSs5aY0duXgAsOdjbj1KSZAdXzIgS3vbOJ6SRnYpmua5Ntrjploy6tvKhFW0jgvjYHGDutZrWnO5WovrMdG8ZvxckS1zxF2OMKBGQazG2MOKgS3vCiyh1cBoAq18yXFZkLditpq1LhPMKLulS5ObNMoEG(Pcqh1zxBKFyysK5ai)Cva6Oo7AJ8ddvGKm0N)sfLefGhQpijAskhqMEGQdsIAq)GdnBywPCaz6bQU8i1KSKAaCWT19m0SbfL8S4GPpvrE8btNyuLihc2rnnhb3GMd7ufzoaYpxDjOWwND9zJAsUbQcKbABIsAWExXHGDulS5ObvZJf)nRuoGm9avxEKAswsTWMJgCAIYwF8a9tfGoQZU2i)WGiIezoaYpxfGoQZU2i)Wqfijd9PzLYbKPhO6YJutYsQbWb3w3ZqhPbfMKYbKPhO6GKOg0p4qZgMvkhqMEGQlpsnjlPgahCBDpdnBqrjploy6tvKhFW0jgvjYHGDutZrWnO5WovaKgS3vbdaz)0tdo(RLcoCmyA4aETvZJf)PcG0G9Ukyai7NEAWXFTuWHJbtdhWRTIKLuppw83eL0G9UIdb7O2i)WqbKForerd27koeSJAJ8ddvGKm0N)sTraqHjkPb7Dva6Oo7AJ8ddfq(5erenyVRcqh1zxBKFyOcKKH(8xQncakk5zXbtFQI84dMoXOkroeSJA6bppZHDQs5aY0du1sdopn4eb0tdo(terucG0G9Ukyai7NEAWXFTuWHJbtdhWRTc0Weasd27QGbGSF6Pbh)1sbhogmnCaV2Q5XI))cG0G9Ukyai7NEAWXFTuWHJbtdhWRTIKLuppw8NIsEwCW0NQip(GPtmQsKdb7OMEWZZCyNknyVRmcCIUa1zxtcDafOHjaKgS3vxckS1zxF2OMKBGkqdtainyVRUeuyRZU(Srnj3avbsYqF(lvwCW0vCiyh10dEEkusuaEO(GKyjploy6tvKhFW0jgvjYHGDutcNt4aNMd7ubqAWExDjOWwND9zJAsUbQanmD8a9tXHGDuJc70eL0G9Uca5ZModhva5NterS4Gsrn6ijeNuLLctucG0G9U6sqHTo76Zg1KCdufijd9PzzXbtxXHGDutcNt4aNkusuaEO(GKirejYCaKFUYiWj6cuNDnj0bubsYqFserIuk6SFQ)Tdi7uyUWMHovznh5y0wlSzORHDQ0G9Usmqoe88GEJwyZUJdfq(5MOKgS3vCiyh1g5hgkqdIiIYwF8a9tLsXWi)WabmrjnyVRcqh1zxBKFyOaniIirMdG8ZvO0uWhmDvGmqBkOGIsEcvTes6tqsS2ZgRfL0GDaeOwJ8q)G8OwAWEVwEYg1EzTEE1oYjwRrEOFqEuRrKIzjploy6tvKhFW0jgvjYHGDutcNt4aNMd7uPb7DLyGCi45b9gvGS4mrd27kusd2bqaTrEOFqEOank5zXbtFQI84dMoXOkroeSJAs4Cch40CyNknyVRedKdbppO3OcKfNjkPb7Dfhc2rTr(HHc0GiIOb7Dva6Oo7AJ8ddfObrebG0G9U6sqHTo76Zg1KCdufijd9PzzXbtxXHGDutcNt4aNkusuaEO(GKifMlSzOtv2sEwCW0NQip(GPtmQsKdb7OMeoNWbonh2Psd27kXa5qWZd6nQazXzIgS3vIbYHGNh0BuZJf)Psd27kXa5qWZd6nksws98yXFZf2m0PkBjpHQ2wE8XTN1Er7AVSwA2)xlHqi12ZOwrMdG8ZR9d6a53SwAWRwaqsJApBKSwyV2ZgBtqG1Y0j4v7L1IsAadSKNfhm9PkYJpy6eJQe5qWoQjHZjCGtZHDQ0G9Usmqoe88GEJkqwCMOb7DLyGCi45b9gvGKm0N)sLskPb7DLyGCi45b9g18yX)wmloy6koeSJAs4Cch4uHsIcWd1hKePGyncafjljfMlSzOtv2sEwCW0NQip(GPtmQs0XZgd9HKg48mh2PszG9aN2m9ajIOwFqXFO3qHjAWExXHGDulS5ObvZJf)Psd27koeSJAHnhnOIKLuppw83enyVR4qWoQnYpmua5NBcaPb7D1LGcBD21NnQj5gOci)8sEwCW0NQip(GPtmQsKdb7OodAZHDQ0G9UIdb7OwyZrdQMhl()lvPCaz6bQU8i1KSKAHnhn4SKNfhm9PkYJpy6eJQeNGgy4Pu2CyNQuoGm9avj4nHaOo7ArMdG8ZNMizNvgI7xQYzjOKNfhm9PkYJpy6eJQe5qWoQPh88mh2Psd27QaCG6SRp7aXPc0WenyVR4qWoQf2C0GQ5XI)Mvcl5ju12sfqsJAf2C0GZAH9A)WA78yulnoYVApBSwr6tmKI1sYox7zh40oha1YoqTO0uWhm9AHZANhCmQn9AfzoaYpVKNfhm9PkYJpy6eJQe5qWoQP5i4g0CyNARdqh7z0GQj0WoD98YG0KuoGm9avj4nHaOo7ArMdG8ZNMOb7Dfhc2rTWMJgunpw8NknyVR4qWoQf2C0Gksws98yXFthpq)uCiyh1zqBsK5ai)Cfhc2rDg0QajzOp)LAJaWej7SYqC)svolttImha5NRqPPGpy6QajzOpl5zXbtFQI84dMoXOkroeSJAAocUbnh2PgGo2ZObvtOHD665LbPjPCaz6bQsWBcbqD21Imha5Npnrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MoEG(P4qWoQZG2KiZbq(5koeSJ6mOvbsYqF(l1gbGjs2zLH4(LQCwMMezoaYpxHstbFW0vbsYqF(RekZsEcvTTubK0OwHnhn4SwyV2mORfoRnqgODjploy6tvKhFW0jgvjYHGDutZrWnO5WovPCaz6bQsWBcbqD21Imha5Npnrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MoEG(P4qWoQZG2KiZbq(5koeSJ6mOvbsYqF(l1gbGjs2zLH4(LQCwMMezoaYpxHstbFW0vbsYqFwYtOQTLdb7yTeMJGBWAN2j4aO2g0XGhJ21sJ1E2yTdEE1k45vB2R9SXAB5wT2pOdKFL8S4GPpvrE8btNyuLihc2rnnhb3GMd7uPb7Dfhc2rTr(HHc0WenyVR4qWoQnYpmubsYqF(l1gbGjAWExXHGDulS5ObvZJf)Psd27koeSJAHnhnOIKLuppw83eLImha5NRqPPGpy6QajzOpjIOa0XEgnOIdb7O2MdY0BtrjpHQ2woeSJ1syocUbRDANGdGABqhdEmAxlnw7zJ1o45vRGNxTzV2ZgRvomB1A)Goq(vYZIdM(uf5XhmDIrvICiyh10CeCdAoStLgS3vbOJ6SRnYpmuGgMOb7Dfhc2rTr(HHci)Ct0G9UkaDuNDTr(HHkqsg6ZFP2iamrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)MOuK5ai)Cfknf8btxfijd9jrefGo2ZObvCiyh12CqMEBkk5ju12YHGDSwcZrWnyTt7eCaulnw7zJ1o45vRGNxTzV2ZgR9N8Aj1(bDG8RwyVw4vlCwRNxTGteO2p4zxRCy2Q1MrTTCRwYZIdM(uf5XhmDIrvICiyh10CeCdAoStLgS3vCiyh1g5hgkG8Znrd27Qa0rD21g5hgkG8ZnbG0G9U6sqHTo76Zg1KCdubAycaPb7D1LGcBD21NnQj5gOkqsg6ZFP2iamrd27koeSJAHnhnOAES4pvAWExXHGDulS5ObvKSK65XI)L8eQAj0TrV2ZgR94ObVAHZAHETOKOa8WAd2BWAzhO2ZgdSw4SwYmWApB2RnDSw0rY2Mxl4eRLMJGBWA5zTZm9A5zTTtWATzPyTONGn21kS5ObN1EzT2WRwEmQfDKeIZAH9ApBS2woeSJ1s4KKMdas0VAhyd6aC0Uw4SwSfccnmqGsEwCW0NQip(GPtmQsKdb7OMMJGBqZHDQs5aY0duHKg5hgiGMMJGBqt0G9UIdb7OwyZrdQMhl(BwQuYIdkf1OJKqC2cilfMyXbLIA0rsionRSMOb7DfaYNnDgoQaYpVKNfhm9PkYJpy6eJQe5qWoQrjng5eMU5WovPCaz6bQqsJ8ddeqtZrWnOjAWExXHGDulS5ObvZJf))LgS3vCiyh1cBoAqfjlPEES4VjwCqPOgDKeItZkRjAWExbG8ztNHJkG8Zl5zXbtFQI84dMoXOkroeSJA6bpVsEwCW0NQip(GPtmQseLMc(GPBoStvkhqMEGQe8MqauNDTiZbq(5ZsEwCW0NQip(GPtmQsKdb7OMMJGBW39U3d]] )

    
end