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
                    duration = 10,
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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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


    spec:RegisterPack( "Arcane", 20210823, [[deL1vhqiPK8ivjLljLav2ef5tQsnkKWPqOwLuI4virMffv3skbzxK8lIidJOIJruAzev6ziqMgru5AirzBerPVPkjmoIOQZjLqwhsu9oPeOkZtvI7rK2hrvDqPe1cjcEOusnrvjvIlsef2OQKkjFuvsLAKsjq5KQsIwjfLxQkPsQzIa1nLsK2jrOFQkPIHQkjTuvjv9ukzQiGRkLa2QucuvFLikASevzVQQ)sQbR0HrTyK6XeMmqxgAZs1NPuJwkonOvlLG61iKzRWTr0UP63IgofoUuc1YfEUIMUkxhW2rsFxvmEIIZlLA9sjqMpcA)s(l7NaFlq(WVeLRCKRSYrYlxcsjhjVKtUYsqFRRTb(TmybrSn(TCMe)wTCiyh)wgC7rYGFc8TMjqiWVvZDgtkxssYgEna0krskPjKeyWhmDrW9tstiPqsFlAa44EL(N(BbYh(LOCLJCLvosE5sqk5i5LCYkhj73AAGIVeLSY9B1abbr)t)TaXP4B1szBS2woeSJLzTmGnW8QvUeK51kx5ixzlZkZADd724KYlZAHQTfyI1ETnGcEuRfKS112Wo4a621M9AfnS74OwOFyeaghm9AH(8qgS2Sx7Bb7cCOzXbt)TQmRfQ2w3WUnwlhc2rn07qhETR9YA5qWoQB4Gm921sb8Q1rQyu7d6xTdivSwEwlhc2rDdhKP3MyvzwluTVUK(7RwjdQPGpSwOxBl)6izuBlmW8QLgfmWeRTDc8oWAtGR2SxBWUnwl7G165vlWe6212YHGDSwjdzmg5eMU6BnGZB(jW3knqhJpb(su2pb(wOZ0de8lHVLiGhgq(Bfao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uT0a9UceofqJb05OTwKKKSdQ7ropfGX3Ifhm9VvhgOMEWZ7FFjk3pb(wOZ0de8lHVLiGhgq(Bfao2ZWgv2bCoARHcOyGk0z6bcwRPAjzNvgIRw5xBlIY(wS4GP)T6ropTNu5)9Lib9jW3cDMEGGFj8TCMe)wZeymW7GUToaOB)TyXbt)BntGXaVd626aGU9)(suY9jW3Ifhm9VfiYxdDgo(TqNPhi4xc)7lrk7tGVf6m9ab)s4Bjc4HbK)wKSZkdXvR8RvYjNVfloy6FRGbHSF6Pbhe9VVeLSFc8TyXbt)BrcJiJPo76lds0VVf6m9ab)s4FFj(k(e4BHotpqWVe(wIaEya5VfnqVR4qWoQnYhmuG5JxRPAfzoaZhxXHGDuBKpyOcKKH(8BXIdM(3A2a7h0T1g5dg)7lrj)NaFl0z6bc(LW3seWddi)TezoaZhxXHGDuBKpyOcKbBxRPAPb6Dfhc2rTOHdBunpwquTVulnqVR4qWoQfnCyJkswg98ybrFlwCW0)wCiyh1zq)VVeBrFc8TqNPhi4xcFlrapmG83sKurN9trf9RPDuRPAfzoaZhxrcJiJPo76lds0pvGKm0N1k)AL8sUVfloy6FloeSJA6bpV)9LOSY5tGVfloy6FRlben6SRVgutY2WVf6m9ab)s4FFjkRSFc8TyXbt)BXHGDuBKpy8TqNPhi4xc)7lrzL7NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcmF8Vfloy6FRaWrD21g5dg)7lrzjOpb(wOZ0de8lHVfloy6FlJaNOlqD21Kqh8BbItranoy6FRwGjw7RMT0AVS2zlgaXwqyTSxlkZfCTTCiyhRvcdEE1cceq3U2RbRLa51sLul)Q1(aDW8PwaFGZzTbG7q3U2woeSJ1kziAsvTVYETTCiyhRvYq0K1cN1E8a9dbnV2hSwb7VVAbMyTVA2sR9bEnqV2RbRLa51sLul)Q1(aDW8PwaFGZzTpyTq)WiamUAVgS2wULwROHDhhMx7mR9bFpg1ozQyTWt9Teb8WaYFRwv7Xd0pfhc2rnkAsf6m9abR1uTGinqVRUeq0OZU(AqnjBdvag1AQwqKgO3vxciA0zxFnOMKTHQajzOpR9fP1srTS4GPR4qWoQPh88uOmOa4q9bjXABj1sd07kJaNOlqD21KqhurYYONhliQwI)3xIYk5(e4BHotpqWVe(wS4GP)TmcCIUa1zxtcDWVfiofb04GP)TEL9AF1SLwBdp93xT0i61cmrWAbbcOBx71G1sG8AP1(aDW8X8AFW3JrTatSw4v7L1oBXai2ccRL9ArzUGRTLdb7yTsyWZRwOx71G1(6ZxvsT8Rw7d0bZh13seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07QaWrD21g5dgQajzOpR9fP1srTS4GPR4qWoQPh88uOmOa4q9bjXABj1sd07kJaNOlqD21KqhurYYONhliQwI)3xIYszFc8TqNPhi4xcFlrapmG83cmpvWGq2p90GdIubsYqFwR8RLYQLqcRfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQv(1kNVfloy6FloeSJA6bpV)9LOSs2pb(wOZ0de8lHVfloy6FloeSJAAoc2g)wG4ueqJdM(3QLhpC7zTsGJGTXA5R2RbRfDWAZETT8Rw7td61gaUdD7AVgS2woeSJ12cghKP3U2bAJoihT)wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExXHGDuBKpyOcKKH(S2xQ1wawRPAdah7zyJkoeSJ6goitVTcDMEGG)7lrzFfFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9VvlpE42ZALahbBJ1YxTxdwl6G1M9AVgS2xF(Q1(aDW8P2Ng0RnaCh621EnyTTCiyhRTfmoitVDTd0gDqoA)Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOcKKH(S2xKwRTaSwt1gao2ZWgvCiyh1nCqMEBf6m9ab)3xIYk5)e4BHotpqWVe(wIgg6Flz)wihJ2ArddDnS)TOb6DLyGCi45bDBTOHDhhkW8XnrbnqVR4qWoQnYhmuagesifT64b6NkPIHr(GbcAIcAGExfaoQZU2iFWqbyqiHImhG5JRqQPGpy6QazW2etmXFlrapmG83cePb6D1LaIgD21xdQjzBOcWOwt1E8a9tXHGDuJIMuHotpqWAnvlf1sd07kqKVg6mCubMpETesyTS4Gurn6ijeN1kTwzRL4Anvlisd07Qlben6SRVgutY2qvGKm0N1k)AzXbtxXHGDutcNt4aNkuguaCO(GK43Ifhm9Vfhc2rnjCoHdC(VVeLTf9jW3cDMEGGFj8Teb8WaYFlAGExjgihcEEq3wnpwquTsRLgO3vIbYHGNh0TvKSm65XcIQ1uTIKk6SFkQOFnTJVfloy6FloeSJAs4Cch48FFjkx58jW3cDMEGGFj8TyXbt)BXHGDutcNt4aNFlrdd9VLSFlrapmG83IgO3vIbYHGNh0TvbYIRwt1kYCaMpUIdb7O2iFWqfijd9zTMQLIAPb6Dva4Oo7AJ8bdfGrTesyT0a9UIdb7O2iFWqbyulX)7lr5k7NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTOHdBunpwquTViTwQCaz6bQU8i1KSmArdh248BXIdM(3Idb7Ood6)9LOCL7NaFl0z6bc(LW3seWddi)TOb6Dva4Oo7AJ8bdfGrTesyTKSZkdXvR8Rvwk7BXIdM(3Idb7OMEWZ7FFjkxc6tGVf6m9ab)s4BXIdM(3cPMc(GP)TG(HrayCAy)BrYoRmeN8Lk5PSVf0pmcaJtdjjrqiF43s2VLiGhgq(Brd07QaWrD21g5dgkW8XR1uT0a9UIdb7O2iFWqbMp()(suUsUpb(wS4GP)T4qWoQP5iyB8BHotpqWVe(3)(wD4Sb6260aDm(e4lrz)e4BHotpqWVe(wS4GP)TqQPGpy6FlqCkcOXbt)Bjz2GETbG7q3UweEnyu71G1AzvBg1sajZAhOn6GCaXP51(G1(W(v7L1kzqnRLg7zG1EnyTeiVwQKA5xT2hOdMpQABbMyTWRwEw7mtVwEw7RpF1AB4zTDOdNniyTjqu7d(Mkw70a9R2eiQv0WHno)wIaEya5Vff1gao2ZWgvhsAKbp0pCyOqNPhiyTesyTuuBa4ypdBunHgnPRNxgKk0z6bcwRPABvTu5aY0duzeObWyOrQzTsRv2AjUwIR1uTuulnqVRcah1zxBKpyOaZhVwcjSwJaPQTfGkzvCiyh10CeSnwlX1AQwrMdW8XvbGJ6SRnYhmubsYqF(VVeL7NaFl0z6bc(LW3Ifhm9Vfsnf8bt)BbItranoy6FRxzV2h8nvS2o0HZgeS2eiQvK5amF8AFGoy(mRLDWANgOF1MarTIgoSXP51AeWmGhSfewRKb1S2Kkg1IuXO91aD7AXXe)wIaEya5V1Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(Swt1kYCaMpUIdb7O2iFWqfijd9zTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8AnvRrGu12cqLSkoeSJAAoc2g)3xIe0NaFl0z6bc(LW3seWddi)Tcah7zyJkq4uangqNJ2ArssYoOcDMEGG1AQwAGExbcNcOXa6C0wlsss2b19iNNcW4BXIdM(3Qddutp459VVeLCFc8TqNPhi4xcFlrapmG83kaCSNHnQSd4C0wdfqXavOZ0deSwt1sYoRmexTYV2weL9TyXbt)B1JCEApPY)7lrk7tGVf6m9ab)s4BXIdM(3Idb7OMeoNWbo)wIgg6Flz)wIaEya5Vva4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJ6goitVTAESGOAFPwAGExXHGDu3Wbz6TvKSm65XcIQ1uTuulf1sd07koeSJAJ8bdfy(41AQwrMdW8XvCiyh1g5dgQazW21sCTesyTGinqVRUeq0OZU(AqnjBdvag1s8)(suY(jW3cDMEGGFj8Teb8WaYFRaWXEg2OAcnAsxpVmivOZ0de8BXIdM(3kaCuNDTr(GX)(s8v8jW3cDMEGGFj8Teb8WaYFlrMdW8XvbGJ6SRnYhmubYGT)wS4GP)T4qWoQZG(FFjk5)e4BHotpqWVe(wIaEya5VLiZby(4QaWrD21g5dgQazW21AQwAGExXHGDulA4WgvZJfev7l1sd07koeSJArdh2OIKLrppwq03Ifhm9Vfhc2rn9GN3)(sSf9jW3cDMEGGFj8Teb8WaYFRwvBa4ypdBuDiPrg8q)WHHcDMEGG1siH1ksheaEkBy)0zxFnOEafnk0z6bc(TyXbt)BbI81qNHJ)7lrzLZNaFlwCW0)wbGJ6SRnYhm(wOZ0de8lH)9LOSY(jW3cDMEGGFj8TyXbt)BXHGDutcNt4aNFlqCkcOXbt)B9k71(GVdSw(QLKLP25XcIM1M9ABDRRLDWAFWAByQO)(QfyIG12stcuBB8mVwGjwlx78ybr1EzTgbsf9Rwsax0aD7Ab8boN1gaUdD7AVgS2wW4Gm921oqB0b5O93seWddi)TOb6DLyGCi45bDBvGS4Q1uT0a9Usmqoe88GUTAESGOALwlnqVRedKdbppOBRizz0ZJfevRPAfjv0z)uur)AAh1AQwrMdW8XvKWiYyQZU(YGe9tfid2Uwt12QAPYbKPhOcjnYhmqqnnhbBJ1AQwrMdW8XvCiyh1g5dgQazW2)7lrzL7NaFl0z6bc(LW3seWddi)TAvTbGJ9mSr1HKgzWd9dhgk0z6bcwRPAPO2wvBa4ypdBunHgnPRNxgKk0z6bcwlHewlf1sLditpqLrGgaJHgPM1kTwzR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlXFlqCkcOXbt)BjXmi5XODTpyTgmmQ1ipy61cmXAFGxtTT8RAET0axTWR2h4yu7GNxTJ0TRf9eWUP2Eg1sNxtTxdw7RpF1AzhS2w(vR9b6G5ZSwaFGZzTbG7q3U2RbR1YQ2mQLasM1oqB0b5aIZVfloy6FlJ8GP)VVeLLG(e4BHotpqWVe(wIaEya5VfnqVRcah1zxBKpyOaZhVwcjSwJaPQTfGkzvCiyh10CeSn(TyXbt)BbI81qNHJ)7lrzLCFc8TqNPhi4xcFlrapmG83IgO3vbGJ6SRnYhmuG5JxlHewRrGu12cqLSkoeSJAAoc2g)wS4GP)TcgeY(PNgCq0)(suwk7tGVf6m9ab)s4Bjc4HbK)w0a9UkaCuNDTr(GHkqsg6ZAFPwkQvYwlLQvU12sQnaCSNHnQMqJM01Zldsf6m9abRL4Vfloy6Flsyezm1zxFzqI(9VVeLvY(jW3cDMEGGFj8TyXbt)BXHGDuBKpy8TaXPiGghm9VLKzd61gaUdD7AVgS2wW4Gm921oqB0b5OT51cmXAB5xTwASNbwlbYRLw7L1ccqAulxBhymAx78ybriyT0CeSn(Teb8WaYFlQCaz6bQqsJ8bdeutZrW2yTMQLgO3vbGJ6SRnYhmuag1AQwkQLKDwziUAFPwkQvUuwTuQwkQvw5uBlPwrsfD2pfrTdi71sCTexlHewlnqVRedKdbppOBRMhliQwP1sd07kXa5qWZd62kswg98ybr1s8)(su2xXNaFl0z6bc(LW3seWddi)TOYbKPhOcjnYhmqqnnhbBJ1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1sd07koeSJAJ8bdfGX3Ifhm9Vfhc2rnnhbBJ)7lrzL8Fc8TqNPhi4xcFlwCW0)wZeymW7GUToaOB)Teb8WaYFlAGExfaoQZU2iFWqbMpETesyTgbsvBlavYQ4qWoQP5iyBSwcjSwJaPQTfGkzvbdcz)0tdoiQwcjSwkQ1iqQABbOswfiYxdDgowRPABvTbGJ9mSr1eA0KUEEzqQqNPhiyTe)TCMe)wZeymW7GUToaOB)VVeLTf9jW3cDMEGGFj8Teb8WaYFlAGExfaoQZU2iFWqbMpETesyTgbsvBlavYQ4qWoQP5iyBSwcjSwJaPQTfGkzvbdcz)0tdoiQwcjSwkQ1iqQABbOswfiYxdDgowRPABvTbGJ9mSr1eA0KUEEzqQqNPhiyTe)TyXbt)BDjGOrND91GAs2g(VVeLRC(e4BHotpqWVe(wIaEya5VLrGu12cqLSQlben6SRVgutY2WVfloy6FloeSJAJ8bJ)9LOCL9tGVf6m9ab)s4BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(3QfyI1(QzlT2lRD2IbqSfewl71IYCbxBlhc2XALWGNxTGab0TR9AWAjqETuj1YVATpqhmFQfWh4CwBa4o0TRTLdb7yTsgIMuv7RSxBlhc2XALmenzTWzThpq)qqZR9bRvW(7RwGjw7RMT0AFGxd0R9AWAjqETuj1YVATpqhmFQfWh4Cw7dwl0pmcaJR2RbRTLBP1kAy3XH51oZAFW3JrTtMkwl8uFlrapmG83Qv1E8a9tXHGDuJIMuHotpqWAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6ZAFrATuulloy6koeSJA6bppfkdkaouFqsS2wsT0a9UYiWj6cuNDnj0bvKSm65XcIQL4)9LOCL7NaFl0z6bc(LW3Ifhm9VLrGt0fOo7AsOd(TaXPiGghm9V1RSx7RMT0AB4P)(QLgrVwGjcwliqaD7AVgSwcKxlT2hOdMpMx7d(EmQfyI1cVAVS2zlgaXwqyTSxlkZfCTTCiyhRvcdEE1c9AVgS2xF(QsQLF1AFGoy(O(wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTViTwkQLfhmDfhc2rn9GNNcLbfahQpijwBlPwAGExze4eDbQZUMe6Gkswg98ybr1s8)(suUe0NaFl0z6bc(LW3seWddi)TaZtfmiK9tpn4GivGKm0N1k)APSAjKWAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOALFTY5BXIdM(3Idb7OMEWZ7FFjkxj3NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)BjzI1(W(v7L1sYeH1obcS2hS2gMkwl6jGDtTKSZ12ZO2RbRf9dgyTT8Rw7d0bZhZRfPIETWETxdg47zTZdog1EqsS2ajzOdD7AtV2xF(QQAFL37zTPpAxlnEhg1EzT0aHx7L12ccJSw2bRvYGAwlSxBa4o0TR9AWATSQnJAjGKzTd0gDqoG4u9Teb8WaYFlrMdW8XvCiyh1g5dgQazW21AQws2zLH4Q9LAPOwjNCQLs1srTYkNABj1ksQOZ(PiQDazVwIRL4AnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfevRPAPO2wvBa4ypdBunHgnPRNxgKk0z6bcwlHewlvoGm9avgbAamgAKAwR0ALTwIR1uTTQ2aWXEg2O6qsJm4H(Hddf6m9abR1uTTQ2aWXEg2OIdb7OUHdY0BRqNPhi4)(suUu2NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)Bjboc2gRD2KadWA98QLgRfyIG1YxTxdwl6G1M9AB5xTwyVwjdQPGpy61cN1gid2UwEwlyKggq3Uwrdh24S2h4yuljtewl8Q9yIWAhPBJrTxwlnq41Enrcy3uBGKm0HUDTKSZFlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVR4qWoQnYhmubsYqFw7lsR1wawRPAfzoaZhxHutbFW0vbsYqF(VVeLRK9tGVf6m9ab)s4BXIdM(3Idb7OMMJGTXVfiofb04GP)TKahbBJ1oBsGbyT84HBpRLgR9AWAh88QvWZRwOx71G1(6ZxT2hOdMp1YZAjqET0AFGJrTboVmWAVgSwrdh24S2Pb633seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHkqsg6ZAFrAT2cWAnvBRQnaCSNHnQ4qWoQB4Gm92k0z6bc(VVeL7R4tGVf6m9ab)s4BjAyO)TK9BHCmARfnm01W(3IgO3vIbYHGNh0T1Ig2DCOaZh3ef0a9UIdb7O2iFWqbyqiHu0QJhOFQKkgg5dgiOjkOb6Dva4Oo7AJ8bdfGbHekYCaMpUcPMc(GPRcKbBtmXe)Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnv7Xd0pfhc2rnkAsf6m9abR1uTuulnqVRar(AOZWrfy(41siH1YIdsf1OJKqCwR0ALTwIR1uTGinqVRUeq0OZU(AqnjBdvbsYqFwR8RLfhmDfhc2rnjCoHdCQqzqbWH6dsIFlwCW0)wCiyh1KW5eoW5)(suUs(pb(wOZ0de8lHVfloy6FloeSJAs4Cch48BbItranoy6FRxzV2h8DG1sf9RPDyETqsseeYhoAxlWeRT1TU2Ng0RvWggiyTxwRNxTp88WAnIumRThjzTT0KaFlrapmG83sKurN9trf9RPDuRPAPb6DLyGCi45bDB18ybr1kTwAGExjgihcEEq3wrYYONhli6FFjk3w0NaFl0z6bc(LW3ceNIaACW0)wwhhxTatOBxBRBDTTClT2Ng0RTLF1AB4zT0i61cmrWVLiGhgq(Brd07kXa5qWZd62QazXvRPAfzoaZhxXHGDuBKpyOcKKH(Swt1srT0a9UkaCuNDTr(GHcWOwcjSwAGExXHGDuBKpyOamQL4VLOHH(3s2Vfloy6FloeSJAs4Cch48FFjsqY5tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avxEKAswgTOHdBC(TyXbt)BXHGDuNb9)(sKGK9tGVf6m9ab)s4Bjc4HbK)w0a9UkaCuNDTr(GHcWOwcjSws2zLH4Qv(1klL9TyXbt)BXHGDutp459VVeji5(jW3cDMEGGFj8TyXbt)BHutbFW0)wq)WiamonS)TizNvgIt(sL8u23c6hgbGXPHKKiiKp8Bj73seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwAGExXHGDuBKpyOaZh)FFjsqe0NaFlwCW0)wCiyh10CeSn(TqNPhi4xc)7FFRip(GP)jWxIY(jW3cDMEGGFj8TyXbt)BHutbFW0)wG4ueqJdM(3QfyI1IuZAH9AFW3bw7iFQn9AjzNRLDWAfzoaZhFwlhyTmDcC1EzT0yTagFlrapmG83Qv1gao2ZWgvtOrt665LbPcDMEGG1AQws2zLH4Q9fP1sLditpqfsn1gIRwt1srTImhG5JRUeq0OZU(AqnjBdvbsYqFw7lsRLfhmDfsnf8btxHYGcGd1hKeRLqcRvK5amFCfhc2rTr(GHkqsg6ZAFrATS4GPRqQPGpy6kuguaCO(GKyTesyTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xKwlloy6kKAk4dMUcLbfahQpijwlX1sCTMQLgO3vbGJ6SRnYhmuG5JxRPAPb6Dfhc2rTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(41AQ2wvRrGu12cqLSQlben6SRVgutY2W)9LOC)e4BHotpqWVe(wIaEya5Vva4ypdBunHgnPRNxgKk0z6bcwRPABvTIKk6SFkQOFnTJAnvRiZby(4koeSJAJ8bdvGKm0N1(I0AzXbtxHutbFW0vOmOa4q9bjXVfloy6FlKAk4dM()(sKG(e4BHotpqWVe(wIaEya5Vva4ypdBunHgnPRNxgKk0z6bcwRPAfjv0z)uur)AAh1AQwrMdW8XvKWiYyQZU(YGe9tfijd9zTViTwwCW0vi1uWhmDfkdkaouFqsSwt1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwkQLkhqMEGkY80gbkqeuF5rQPBxlLQLfhmDfsnf8btxHYGcGd1hKeRLs1sq1sCTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATuulvoGm9avK5PncuGiO(YJut3Uwkvlloy6kKAk4dMUcLbfahQpijwlLQLGQL4Vfloy6FlKAk4dM()(suY9jW3cDMEGGFj8TyXbt)BXHGDutZrW243ceNIaACW0)wsGJGTXAH9AH37zThKeR9YAbMyTxEK1YoyTpyTnmvS2lZAjzVDTIgoSX53seWddi)TezoaZhxDjGOrND91GAs2gQcKbBxRPAPOwAGExXHGDulA4WgvZJfevR8RLkhqMEGQlpsnjlJw0WHnoR1uTImhG5JR4qWoQnYhmubsYqFw7lsRfLbfahQpijwRPAjzNvgIRw5xlvoGm9avSHMe6qsasnj7S2qC1AQwAGExfaoQZU2iFWqbMpETe)VVePSpb(wOZ0de8lHVLiGhgq(BjYCaMpU6sarJo76Rb1KSnufid2Uwt1srT0a9UIdb7Ow0WHnQMhliQw5xlvoGm9avxEKAswgTOHdBCwRPApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ArzqbWH6dsI1AQwQCaz6bQoijQb8do0SrTYVwQCaz6bQU8i1KSmAqCWT19m0SrTe)TyXbt)BXHGDutZrW24)(suY(jW3cDMEGGFj8Teb8WaYFlrMdW8XvxciA0zxFnOMKTHQazW21AQwkQLgO3vCiyh1IgoSr18ybr1k)APYbKPhO6YJutYYOfnCyJZAnvlf12QApEG(Pcah1zxBKpyOqNPhiyTesyTImhG5JRcah1zxBKpyOcKKH(Sw5xlvoGm9avxEKAswgnio426Eg6inQL4AnvlvoGm9avhKe1a(bhA2Ow5xlvoGm9avxEKAswgnio426EgA2OwI)wS4GP)T4qWoQP5iyB8FFj(k(e4BHotpqWVe(wIaEya5Vfisd07QGbHSF6PbhePPcmCmyA4aETvZJfevR0AbrAGExfmiK9tpn4GinvGHJbtdhWRTIKLrppwquTMQLIAPb6Dfhc2rTr(GHcmF8AjKWAPb6Dfhc2rTr(GHkqsg6ZAFrAT2cWAjUwt1srT0a9UkaCuNDTr(GHcmF8AjKWAPb6Dva4Oo7AJ8bdvGKm0N1(I0ATfG1s83Ifhm9Vfhc2rnnhbBJ)7lrj)NaFl0z6bc(LW3seWddi)TOYbKPhOQfgyEAGjcQNgCquTesyTuulisd07QGbHSF6PbhePPcmCmyA4aETvag1AQwqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhliQ2xQfePb6DvWGq2p90GdI0ubgogmnCaV2kswg98ybr1s83Ifhm9Vfhc2rn9GN3)(sSf9jW3cDMEGGFj8Teb8WaYFlAGExze4eDbQZUMe6GkaJAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6ZAFrATS4GPR4qWoQPh88uOmOa4q9bjXVfloy6FloeSJA6bpV)9LOSY5tGVf6m9ab)s4BjAyO)TK9BHCmARfnm01W(3IgO3vIbYHGNh0T1Ig2DCOaZh3ef0a9UIdb7O2iFWqbyqiHu0QJhOFQKkgg5dgiOjkOb6Dva4Oo7AJ8bdfGbHekYCaMpUcPMc(GPRcKbBtmXe)Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnv7Xd0pfhc2rnkAsf6m9abR1uTuulnqVRar(AOZWrfy(41siH1YIdsf1OJKqCwR0ALTwIR1uTuulisd07Qlben6SRVgutY2qvGKm0N1k)AzXbtxXHGDutcNt4aNkuguaCO(GKyTesyTImhG5JRmcCIUa1zxtcDqvGKm0N1siH1ksQOZ(PiQDazVwI)wS4GP)T4qWoQjHZjCGZ)9LOSY(jW3cDMEGGFj8TyXbt)BXHGDutcNt4aNFlqCkcOXbt)B160NaKyTxdwlkJb7GiyTg5H(b5rT0a9ET8KnQ9YA98QDKtSwJ8q)G8OwJifZVLiGhgq(Brd07kXa5qWZd62QazXvRPAPb6DfkJb7GiO2ip0pipuag)7lrzL7NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(Tenm0)wY(Teb8WaYFlAGExjgihcEEq3wfilUAnvlf1sd07koeSJAJ8bdfGrTesyT0a9UkaCuNDTr(GHcWOwcjSwqKgO3vxciA0zxFnOMKTHQajzOpRv(1YIdMUIdb7OMeoNWbovOmOa4q9bjXAj(FFjklb9jW3cDMEGGFj8TyXbt)BXHGDutcNt4aNFlrdd9VLSFlrapmG83IgO3vIbYHGNh0TvbYIRwt1sd07kXa5qWZd62Q5XcIQvAT0a9Usmqoe88GUTIKLrppwq0)(suwj3NaFl0z6bc(LW3ceNIaACW0)wT84HBpR9I21EzT0StuTTU112ZOwrMdW8XR9b6G5ZSwAGRwqasJAVgKSwyV2RbB)oWAz6e4Q9YArzmGb(Teb8WaYFlAGExjgihcEEq3wfilUAnvlnqVRedKdbppOBRcKKH(S2xKwlf1srT0a9Usmqoe88GUTAESGOABj1YIdMUIdb7OMeoNWbovOmOa4q9bjXAjUwkvRTaurYYulXFlrdd9VLSFlwCW0)wCiyh1KW5eoW5)(suwk7tGVf6m9ab)s4Bjc4HbK)wuuBG9aNnm9aRLqcRTv1Eqbrq3UwIR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTMQLgO3vCiyh1g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5J)TyXbt)B541GH(qsdCE)7lrzLSFc8TqNPhi4xcFlrapmG83IgO3vCiyh1IgoSr18ybr1(I0APYbKPhO6YJutYYOfnCyJZVfloy6FloeSJ6mO)3xIY(k(e4BHotpqWVe(wIaEya5VfvoGm9avjWnHGOo7ArMdW8XN1AQws2zLH4Q9fP12IOSVfloy6FRjGbgEsL)3xIYk5)e4BHotpqWVe(wIaEya5VfnqVRcGbQZU(AceNkaJAnvlnqVR4qWoQfnCyJQ5XcIQv(1sqFlwCW0)wCiyh10dEE)7lrzBrFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9V1RlaKg1kA4WgN1c71(G125XOwACKp1EnyTI0NyqfRLKDU2RjWztoaRLDWArQPGpy61cN1op4yuB61kYCaMp(3seWddi)TAvTbGJ9mSr1eA0KUEEzqQqNPhiyTMQLkhqMEGQe4MqquNDTiZby(4ZAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfevRPApEG(P4qWoQZGwHotpqWAnvRiZby(4koeSJ6mOvbsYqFw7lsR1wawRPAjzNvgIR2xKwBlso1AQwrMdW8Xvi1uWhmDvGKm0N)7lr5kNpb(wOZ0de8lHVLiGhgq(Bfao2ZWgvtOrt665LbPcDMEGG1AQwQCaz6bQsGBcbrD21ImhG5JpR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTMQ94b6NIdb7OodAf6m9abR1uTImhG5JR4qWoQZGwfijd9zTViTwBbyTMQLKDwziUAFrATTi5uRPAfzoaZhxHutbFW0vbsYqFw7l1sqY5BXIdM(3Idb7OMMJGTX)9LOCL9tGVf6m9ab)s4BXIdM(3Idb7OMMJGTXVfiofb04GP)TEDbG0Owrdh24SwyV2mORfoRnqgS93seWddi)TOYbKPhOkbUjee1zxlYCaMp(Swt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQ2JhOFkoeSJ6mOvOZ0deSwt1kYCaMpUIdb7OodAvGKm0N1(I0ATfG1AQws2zLH4Q9fP12IKtTMQvK5amFCfsnf8btxfijd9zTMQLIABvTbGJ9mSr1eA0KUEEzqQqNPhiyTesyT0a9UAcnAsxpVmivbsYqFw7lsRvwjFTe)VVeLRC)e4BHotpqWVe(wS4GP)T4qWoQP5iyB8BbItranoy6FRwoeSJ1kboc2gRD2KadWATrhdEmAxlnw71G1o45vRGNxTzV2RbRTLF1AFGoy(8Teb8WaYFlAGExXHGDuBKpyOamQ1uT0a9UIdb7O2iFWqfijd9zTViTwBbyTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQ1uTuuRiZby(4kKAk4dMUkqsg6ZAjKWAdah7zyJkoeSJ6goitVTcDMEGG1s8)(suUe0NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)B1YHGDSwjWrW2yTZMeyawRn6yWJr7APXAVgS2bpVAf88Qn71EnyTV(8vR9b6G5Z3seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHkqsg6ZAFrAT2cWAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfevRPAPOwrMdW8Xvi1uWhmDvGKm0N1siH1gao2ZWgvCiyh1nCqMEBf6m9abRL4)9LOCLCFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9Vvlhc2XALahbBJ1oBsGbyT0yTxdw7GNxTcEE1M9AVgSwcKxlT2hOdMp1c71cVAHZA98QfyIG1(aVMAF95RwBg12YV63seWddi)TOb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubyuRPAbrAGExDjGOrND91GAs2gQcKKH(S2xKwRTaSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr)7lr5szFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9VLKzd61EnyThh24vlCwl0RfLbfahwBWUnwl7G1EnyG1cN1sMbw71WETPJ1Ios228AbMyT0CeSnwlpRDMPxlpRTDcuBdtfRf9eWUPwrdh24S2lRTbE1YJrTOJKqCwlSx71G12YHGDSwjKK0CasI(v7aTrhKJ21cN1ITyaOHbc(Teb8WaYFlQCaz6bQqsJ8bdeutZrW2yTMQLgO3vCiyh1IgoSr18ybr1kFP1srTS4Gurn6ijeN12cvRS1sCTMQLfhKkQrhjH4Sw5xRS1AQwAGExbI81qNHJkW8X)3xIYvY(jW3cDMEGGFj8Teb8WaYFlQCaz6bQqsJ8bdeutZrW2yTMQLgO3vCiyh1IgoSr18ybr1(sT0a9UIdb7Ow0WHnQizz0ZJfevRPAzXbPIA0rsioRv(1kBTMQLgO3vGiFn0z4OcmF8Vfloy6FloeSJAugJroHP)VVeL7R4tGVfloy6FloeSJA6bpVVf6m9ab)s4FFjkxj)NaFl0z6bc(LW3seWddi)TOYbKPhOkbUjee1zxlYCaMp(8BXIdM(3cPMc(GP)VVeLBl6tGVfloy6FloeSJAAoc2g)wOZ0de8lH)9VVLiZby(4Zpb(su2pb(wOZ0de8lHVfloy6FREKZt7jv(BbItranoy6FRxnGzapyliSwGj0TR1oGZr7AHcOyG1(aVMAzdvTTatSw4v7d8AQ9YJS28AW4bor13seWddi)Tcah7zyJk7aohT1qbumqf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RLGKtTMQvK5amFC1LaIgD21xdQjzBOkqgSDTMQLIAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQU8i1KSmArdh24Swt1srTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xKwRTaSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQU8i1KSmAqCWT19m0SrTexlHewlf12QApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzz0G4GBR7zOzJAjUwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1AlaRL4Aj(FFjk3pb(wOZ0de8lHVLiGhgq(Bfao2ZWgv2bCoARHcOyGk0z6bcwRPAfzoaZhxXHGDuBKpyOcKbBxRPAPO2wv7Xd0pf6dODZHocQqNPhiyTesyTuu7Xd0pf6dODZHocQqNPhiyTMQLKDwziUALV0AFfYPwIRL4Anvlf1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8Rvw5uRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOAjUwcjSwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALwRCQ1uT0a9UIdb7Ow0WHnQMhliQwP1kNAjUwIR1uT0a9UkaCuNDTr(GHcmF8Anvlj7SYqC1kFP1sLditpqfBOjHoKeGutYoRne33Ifhm9VvpY5P9Kk)VVejOpb(wOZ0de8lHVLiGhgq(Bfao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uTImhG5JROb6DniCkGgdOZrBTijjzhufid2Uwt1sd07kq4uangqNJ2ArssYoOUh58uG5JxRPAPOwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5JxlX1AQwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYPwt1srT0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avxEKAswgTOHdBCwRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7lsR1wawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlvoGm9avxEKAswgnio426EgA2OwIRLqcRLIABvThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQU8i1KSmAqCWT19m0SrTexlHewRiZby(4koeSJAJ8bdvGKm0N1(I0ATfG1sCTe)TyXbt)B1JCE054(3xIsUpb(wOZ0de8lHVLiGhgq(Bfao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uTImhG5JROb6DniCkGgdOZrBTijjzhufid2Uwt1sd07kq4uangqNJ2ArssYoOUddubMpETMQ1iqQABbOswvpY5rNJ7BXIdM(3Qddutp459VVePSpb(wOZ0de8lHVfloy6Flsyezm1zxFzqI(9TaXPiGghm9V1RYWO2wAsGAFGxtTT8RwlSxl8EpRvKKq3UwaJANz6QAFL9AHxTpWXOwASwGjcw7d8AQLa51snVwbpVAHxTZb0U5gTRLg7zGFlrapmG83IIABvTbGJ9mSr1eA0KUEEzqQqNPhiyTesyT0a9UAcnAsxpVmivag1sCTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZAFPwQCaz6bQiZtBeOarq9LhPMUDTesyTuulvoGm9avhKe1a(bhA2Ow5xlvoGm9avK5Pjzz0G4GBR7zOzJAnvRiZby(4Qlben6SRVgutY2qvGKm0N1k)APYbKPhOImpnjlJgehCBDpd9LhzTe)VVeLSFc8TqNPhi4xcFlrapmG83sK5amFCfhc2rTr(GHkqgSDTMQLIABvThpq)uOpG2nh6iOcDMEGG1siH1srThpq)uOpG2nh6iOcDMEGG1AQws2zLH4Qv(sR9viNAjUwIR1uTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwQCaz6bQydnjlJgehCBDpd9LhzTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYPwt1sd07koeSJArdh2OAESGOALwRCQL4AjUwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8LwlvoGm9avSHMe6qsasnj7S2qCFlwCW0)wKWiYyQZU(YGe97FFj(k(e4BHotpqWVe(wIaEya5VfvoGm9avjWnHGOo7ArMdW8XN1AQwkQDMadAOdQOMd(GdupZbv0pf6m9abRLqcRDMadAOdQmaMhWa1yayCW0vOZ0deSwI)wS4GP)T6dC2icUF)7lrj)NaFl0z6bc(LW3Ifhm9VfiYxdDgo(TaXPiGghm9VvlpE42ZAbMyTGiFn0z4yTpWRPw2qv7RSx7LhzTWzTbYGTRLN1(GJH51sYeH1obcS2lRvWZRw4vln2ZaR9YJu9Teb8WaYFlrMdW8XvxciA0zxFnOMKTHQazW21AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGQlpsnjlJw0WHnoR1uTImhG5JR4qWoQnYhmubsYqFw7lsR1wa(VVeBrFc8TqNPhi4xcFlrapmG83sK5amFCfhc2rTr(GHkqgSDTMQLIABvThpq)uOpG2nh6iOcDMEGG1siH1srThpq)uOpG2nh6iOcDMEGG1AQws2zLH4Qv(sR9viNAjUwIR1uTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwzLtTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQazW21AQwAGExXHGDulA4WgvZJfevR0ALtTexlX1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALV0APYbKPhOIn0KqhscqQjzN1gI7BXIdM(3ce5RHodh)3xIYkNpb(wOZ0de8lHVfloy6FRGbHSF6Pbhe9TaXPiGghm9VvlWeRDAWbr1c71E5rwl7G1Yg1YbwB61kaRLDWAFs)9vlnwlGrT9mQDKUng1EnSx71G1sYYulio42Mxljte0TRDceyTpyTnmvSw(QDG88Q9EYA5qWowROHdBCwl7G1En8v7LhzTp80FF12cdmVAbMiO6Bjc4HbK)wImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RLkhqMEGQyQjzz0G4GBR7zOV8iR1uTImhG5JR4qWoQnYhmubsYqFwR8RLkhqMEGQyQjzz0G4GBR7zOzJAnvlf1E8a9tfaoQZU2iFWqHotpqWAnvlf1kYCaMpUkaCuNDTr(GHkqsg6ZAFPwuguaCO(GKyTesyTImhG5JRcah1zxBKpyOcKKH(Sw5xlvoGm9avXutYYObXb3w3ZqhPrTexlHewBRQ94b6NkaCuNDTr(GHcDMEGG1sCTMQLgO3vCiyh1IgoSr18ybr1k)ALBTMQfePb6D1LaIgD21xdQjzBOcmF8AnvlnqVRcah1zxBKpyOaZhVwt1sd07koeSJAJ8bdfy(4)7lrzL9tGVf6m9ab)s4BXIdM(3kyqi7NEAWbrFlqCkcOXbt)B1cmXANgCquTpWRPw2O2Ng0R1iNti9av1(k71E5rwlCwBGmy7A5zTp4yyETKmryTtGaR9YAf88QfE1sJ9mWAV8ivFlrapmG83sK5amFC1LaIgD21xdQjzBOkqsg6ZAFPwuguaCO(GKyTMQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhO6YJutYYOfnCyJZAnvRiZby(4koeSJAJ8bdvGKm0N1(sTuulkdkaouFqsSwkvlloy6Qlben6SRVgutY2qfkdkaouFqsSwI)3xIYk3pb(wOZ0de8lHVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTVulkdkaouFqsSwt1srTuuBRQ94b6Nc9b0U5qhbvOZ0deSwcjSwkQ94b6Nc9b0U5qhbvOZ0deSwt1sYoRmexTYxATVc5ulX1sCTMQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1sLditpqfBOjzz0G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvo1AQwAGExXHGDulA4WgvZJfevR0ALtTexlX1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALV0APYbKPhOIn0KqhscqQjzN1gIRwI)wS4GP)TcgeY(PNgCq0)(suwc6tGVf6m9ab)s4BXIdM(3AMaJbEh0T1baD7VLiGhgq(BrrTTQ2aWXEg2OAcnAsxpVmivOZ0deSwcjSwAGExnHgnPRNxgKkaJAjUwt1sd07koeSJArdh2OAESGOAFrATu5aY0duD5rQjzz0IgoSXzTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATOmOa4q9bjXAnvlj7SYqC1k)APYbKPhOIn0KqhscqQjzN1gIRwt1sd07QaWrD21g5dgkW8X)wotIFRzcmg4Dq3wha0T)3xIYk5(e4BHotpqWVe(wS4GP)TUeq0OZU(AqnjBd)wG4ueqJdM(3QfyI1E5rw7d8AQLnQf2RfEVN1(aVgOx71G1sYYulio42QAFL9A98mVwGjw7d8AQnsJAH9AVgS2JhOF1cN1EmrOBETSdwl8EpR9bEnqV2RbRLKLPwqCWTvFlrapmG83IIABvTbGJ9mSr1eA0KUEEzqQqNPhiyTesyT0a9UAcnAsxpVmivag1sCTMQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhO6YJutYYOfnCyJZAnvRiZby(4koeSJAJ8bdvGKm0N1(I0ArzqbWH6dsI1AQws2zLH4Qv(1sLditpqfBOjHoKeGutYoRnexTMQLgO3vbGJ6SRnYhmuG5J)VVeLLY(e4BHotpqWVe(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQ9fP1sLditpq1LhPMKLrlA4WgN1AQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwuguaCO(GKyTMQLkhqMEGQdsIAa)GdnBuR8RLkhqMEGQlpsnjlJgehCBDpdnB8TyXbt)BDjGOrND91GAs2g(VVeLvY(jW3cDMEGGFj8Teb8WaYFlAGExXHGDulA4WgvZJfev7lsRLkhqMEGQlpsnjlJw0WHnoR1uTuuBRQ94b6NkaCuNDTr(GHcDMEGG1siH1kYCaMpUkaCuNDTr(GHkqsg6ZALFTu5aY0duD5rQjzz0G4GBR7zOJ0OwIR1uTu5aY0duDqsud4hCOzJALFTu5aY0duD5rQjzz0G4GBR7zOzJVfloy6FRlben6SRVgutY2W)9LOSVIpb(wOZ0de8lHVfloy6FloeSJAJ8bJVfiofb04GP)TAbMyTSrTWETxEK1cN1METcWAzhS2N0FF1sJ1cyuBpJAhPBJrTxd71EnyTKSm1cIdUT51sYebD7ANabw71WxTpyTnmvSw0ta7MAjzNRLDWAVg(Q9AWaRfoR1ZRwEeid2UwU2aWXAZETg5dg1cMpU6Bjc4HbK)wImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RLkhqMEGk2qtYYObXb3w3ZqF5rwRPAPO2wvRiPIo7NIk6xt7OwcjSwrMdW8XvKWiYyQZU(YGe9tfijd9zTYVwQCaz6bQydnjlJgehCBDpdnzE1sCTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQ1uT0a9UkaCuNDTr(GHcmF8Anvlj7SYqC1kFP1sLditpqfBOjHoKeGutYoRne3)(suwj)NaFl0z6bc(LW3Ifhm9Vva4Oo7AJ8bJVfiofb04GP)TAbMyTrAulSx7LhzTWzTPxRaSw2bR9j93xT0yTag12ZO2r62yu71WETxdwljltTG4GBBETKmrq3U2jqG1EnyG1cN(7RwEeid2UwU2aWXAbZhVw2bR9A4Rw2O2N0FF1sJIKeRLPYWbtpWAbbcOBxBa4O6Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlvoGm9avrAOjzz0G4GBR7zOV8iRLqcRvK5amFCfhc2rTr(GHkqsg6ZAFrATu5aY0duD5rQjzz0G4GBR7zOzJAjUwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kRCQ1uTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8Rvw58VVeLTf9jW3cDMEGGFj8Teb8WaYFlQCaz6bQsGBcbrD21ImhG5Jp)wS4GP)TMnW(bDBTr(GX)(suUY5tGVf6m9ab)s4BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(3QfyI1AKK1EzTZwmaITGWAzVwuMl4Az6AHETxdwRJYC1kYCaMpETpqhmFmVwaFGZzTe1oGSx71GETPpAxliqaD7A5qWowRr(GrTGayTxwBt(ulj7CTnaUD0U2GbHSF1on4GOAHZVLiGhgq(BD8a9tfaoQZU2iFWqHotpqWAnvlnqVR4qWoQnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTVuRTaurYY8VVeLRSFc8TqNPhi4xcFlrapmG83cePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9zTVulloy6koeSJAs4Cch4uHYGcGd1hKeR1uTTQwrsfD2pfrTdi7FlwCW0)wgborxG6SRjHo4)(suUY9tGVf6m9ab)s4Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07QaWrD21g5dgQajzOpR9LATfGkswMAnvRiZby(4kKAk4dMUkqgSDTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZAnvBRQvKurN9tru7aY(3Ifhm9VLrGt0fOo7AsOd(V)9TaXodmUpb(su2pb(wS4GP)TejGFymnWX4BHotpqWVe(3xIY9tGVf6m9ab)s4Bjc4HbK)wuu7Xd0pf6dODZHocQqNPhiyTMQLKDwziUAFrATsE5uRPAjzNvgIRw5lTwjlLvlX1siH1srTTQ2JhOFk0hq7MdDeuHotpqWAnvlj7SYqC1(I0AL8uwTe)TyXbt)BrYoRTrY)9Lib9jW3cDMEGGFj8Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TmYdM()(suY9jW3cDMEGGFj8Teb8WaYFRaWXEg2O6qsJm4H(Hddf6m9abR1uT0a9UcLPHbMhmDfGrTMQLIAfzoaZhxXHGDuBKpyOcKbBxlHewlDoN1AQ2o0U50bsYqFw7lsRvYjNAj(BXIdM(36GKO(HdJ)9LiL9jW3cDMEGGFj8Teb8WaYFlAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5J)TyXbt)BnG2n3u3cdaAtI(9VVeLSFc8TqNPhi4xcFlrapmG83IgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(4FlwCW0)w0STo76lGcIM)7lXxXNaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3IgJjgebD7)9LOK)tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)BrpYeu3bI2)7lXw0NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3QddKEKj4)(suw58jW3cDMEGGFj8Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TyxGZl4HwWJX)(suwz)e4BHotpqWVe(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)watudpKC(VVeLvUFc8TqNPhi4xcFlwCW0)w2dgeYxgtnndAJFlrapmG83IgO3vCiyh1g5dgkaJAjKWAfzoaZhxXHGDuBKpyOcKKH(Sw5lTwkJYQ1uTGinqVRUeq0OZU(AqnjBdvagFlS3rXPDMe)w2dgeYxgtnndAJ)7lrzjOpb(wOZ0de8lHVfloy6FlK0ODG8qNbOZUa)wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1(I0ALLYQ1uTImhG5JRUeq0OZU(AqnjBdvbsYqFw7lsRvwk7B5mj(TqsJ2bYdDgGo7c8FFjkRK7tGVf6m9ab)s4BXIdM(3cmqgSddutfNtC8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpRv(sRvUYPwcjS2wvlvoGm9avSHoDnWeRvATYwlHewlf1EqsSwP1kNAnvlvoGm9avD4Sb6260aDmQvATYwRPAdah7zyJQj0OjD98YGuHotpqWAj(B5mj(TadKb7Wa1uX5eh)7lrzPSpb(wOZ0de8lHVfloy6FRzcm0qBhEy8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpRv(sRLGKtTesyTTQwQCaz6bQydD6AGjwR0AL9B5mj(TMjWqdTD4HX)(suwj7NaFl0z6bc(LW3Ifhm9VL9OTrJo7AEoHKWbFW0)wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1kFP1kx5ulHewBRQLkhqMEGk2qNUgyI1kTwzRLqcRLIApijwR0ALtTMQLkhqMEGQoC2aDBDAGog1kTwzR1uTbGJ9mSr1eA0KUEEzqQqNPhiyTe)TCMe)w2J2gn6SR55esch8bt)FFjk7R4tGVf6m9ab)s4BXIdM(3IKfmDG6zdINMeycfFlrapmG83sK5amFCfhc2rTr(GHkqsg6ZAFrATuwTMQLIABvTu5aY0du1HZgOBRtd0XOwP1kBTesyThKeRv(1sqYPwI)wotIFlswW0bQNniEAsGju8VVeLvY)jW3cDMEGGFj8TyXbt)BrYcMoq9SbXttcmHIVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTViTwkRwt1sLditpqvhoBGUTonqhJALwRS1AQwAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(I0APOwzLtTTq1sz12sQnaCSNHnQMqJM01Zldsf6m9abRL4Anv7bjXAFPwcsoFlNjXVfjly6a1ZgepnjWek(3xIY2I(e4BHotpqWVe(wS4GP)TMnmy(GG6mO1zxFzqI(9Teb8WaYFRdsI1kTw5ulHewlf1sLditpqvcCtiiQZUwK5amF8zTMQLIAPOwrsfD2pfrTdi71AQwrMdW8Xvbdcz)0tdoisfijd9zTViTw5wRPAfzoaZhxXHGDuBKpyOcKKH(S2xKwlLvRPAfzoaZhxDjGOrND91GAs2gQcKKH(S2xKwlLvlX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTw5wlHewBhA3C6ajzOpR9LAfzoaZhxXHGDuBKpyOcKKH(SwIRL4VLZK43A2WG5dcQZGwND9Lbj63)(suUY5tGVf6m9ab)s4BbItranoy6FlktjzRfoR9AWANgicwB2R9AWATsGXaVd621(6bOBxRrKTWO4Gd8B5mj(TMjWyG3bDBDaq3(Bjc4HbK)wuulvoGm9avhKe1a(bhA2Owkvlf1YIdMUkyqi7NEAWbrkuguaCO(GKyTTKAfjv0z)ue1oGSxlX1sPAPOwwCW0vGiFn0z4OcLbfahQpijwBlPwrsfD2pLJIihzawlX1sPAzXbtxDjGOrND91GAs2gQqzqbWH6dsI1(sThh24PaHZJDbwRKQLYus2AjUwt1srTu5aY0du1WurDAGocwlHewlf1ksQOZ(PiQDazVwt1gao2ZWgvCiyh1qVdD41wHotpqWAjUwIR1uThh24PaHZJDbwR8RvUu23Ifhm9V1mbgd8oOBRda62)7lr5k7NaFl0z6bc(LW3Ifhm9VLGhdnloy66bCEFRbCEANjXVLGhcGbFW0N)7lr5k3pb(wOZ0de8lHVLiGhgq(BXIdsf1OJKqCwR8LwlvoGm9avCI6JdB80IeWVV18cO4(su2Vfloy6FlbpgAwCW01d48(wd480otIFloX)9LOCjOpb(wOZ0de8lHVLiGhgq(BjsQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ab)wS4GP)Te8yOzXbtxpGZ7BnGZt7mj(TA4Gm92)7lr5k5(e4BHotpqWVe(wIaEya5VfvoGm9avnmvuNgOJG1kTw5uRPAPYbKPhOQdNnq3wNgOJrTMQTv1srTIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAj(BXIdM(3sWJHMfhmD9aoVV1aopTZK43QdNnq3wNgOJX)(suUu2NaFl0z6bc(LW3seWddi)TOYbKPhOQHPI60aDeSwP1kNAnvBRQLIAfjv0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1s83Ifhm9VLGhdnloy66bCEFRbCEANjXVvAGog)7lr5kz)e4BHotpqWVe(wIaEya5VvRQLIAfjv0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1s83Ifhm9VLGhdnloy66bCEFRbCEANjXVLiZby(4Z)9LOCFfFc8TqNPhi4xcFlrapmG83IkhqMEGQo05HMgi8ALwRCQ1uTTQwkQvKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwlXFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wrE8bt)FFjkxj)NaFl0z6bc(LW3seWddi)TOYbKPhOQdDEOPbcVwP1kBTMQTv1srTIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAj(BXIdM(3sWJHMfhmD9aoVV1aopTZK43QdDEOPbc)F)7BzeOijP57tGVeL9tGVfloy6FloeSJAOF4yGI7BHotpqWVe(3xIY9tGVfloy6FRjajz6AoeSJ6otchqo(wOZ0de8lH)9Lib9jW3Ifhm9VLi9wyGa1KSZABK8BHotpqWVe(3xIsUpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(T4e1hh24PfjGFFlqSZaJ7Brq)7lrk7tGVf6m9ab)s4BLgFRaN49TyXbt)BrLditpWVfvo0otIFlKAQne33ce7mW4(wYsz)7lrj7NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkhANjXVLrGgaJHgPMFlrapmG83IIAdah7zyJQj0OjD98YGuHotpqWAnvlf1ksQOZ(POI(10oQLqcRvKurN9t5OiYrgG1siH1ksheaEkoeSJAJibH2TvOZ0deSwIRL4VfvEaGACmXVLC(wu5ba(TK9FFj(k(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5q7mj(TAyQOonqhb)wIaEya5VfloivuJoscXzTYxATu5aY0duXjQpoSXtlsa)(wu5baQXXe)wY5BrLha43s2)9LOK)tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43soFlQCODMe)wDOZdnnq4)7lXw0NaFl0z6bc(LW3kn(wboX7BXIdM(3IkhqMEGFlQCODMe)wnCqMEB98ybr6dsIFlqSZaJ7B1I(3xIYkNpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(T4Xd3EQNTDHwK5amF853ce7mW4(wY5FFjkRSFc8TqNPhi4xcFR04Bf4eVVfloy6FlQCaz6b(TOYH2zs8BftnjlJgehCBDpd9Lh53ce7mW4(wu2)(suw5(jW3cDMEGGFj8TsJVvGt8(wS4GP)TOYbKPh43IkhANjXVvm1KSmAqCWT19m0rA8TaXodmUVfL9VVeLLG(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43kMAswgnio426EgA24BbIDgyCFl5kN)9LOSsUpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(TiZtBeOarq9LhPMU93ce7mW4(ws()9LOSu2NaFl0z6bc(LW3kn(wboX7BXIdM(3IkhqMEGFlQCODMe)wK5Pjzz0G4GBR7zOV8i)wGyNbg33sw58VVeLvY(jW3cDMEGGFj8TsJVvGt8(wS4GP)TOYbKPh43IkhANjXVfzEAswgnio426EgA24BbIDgyCFlzPS)9LOSVIpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(TydnjlJgehCBDpd9Lh53seWddi)TePdcapfhc2rTrKGq72FlQ8aa14yIFlzLZ3IkpaWVfbjN)9LOSs(pb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(TydnjlJgehCBDpd9Lh53ce7mW4(wYvo)7lrzBrFc8TqNPhi4xcFR04Bf4eVVfloy6FlQCaz6b(TOYH2zs8BXgAswgnio426EgAY8(wGyNbg33sUY5FFjkx58jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8Bjx5uBluTuulLvBlPwr6GaWtXHGDuBeji0UTcDMEGG1s83IkhANjXVvKgAswgnio426Eg6lpY)9LOCL9tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43IYQLs1kx5uBlPwkQvKurN9t5q7Mt3zSwcjSwkQvKoia8uCiyh1grccTBRqNPhiyTMQLfhKkQrhjH4S2xQLkhqMEGkor9XHnEArc4xTexlX1sPALLYQTLulf1ksQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abR1uTS4Gurn6ijeN1kFP1sLditpqfNO(4WgpTib8RwI)wu5q7mj(TU8i1KSmAqCWT19m0SX)(suUY9tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43sUYP2wOAPOwjFTTKAfPdcapfhc2rTrKGq72k0z6bcwlXFlQCODMe)wxEKAswgnio426Eg6in(3xIYLG(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5ba(TKSYP2wOAPOwsEEy0wtLhayTTKALvoYPwI)wIaEya5VLiPIo7NYH2nNUZ43IkhANjXVfnhbBJAs2zTH4(3xIYvY9jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8B1IOSABHQLIAj55HrBnvEaG12sQvw5iNAj(Bjc4HbK)wIKk6SFkIAhq2)wu5q7mj(TO5iyButYoRne3)(suUu2NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVLKxo12cvlf1sYZdJ2AQ8aaRTLuRSYro1s83seWddi)TOYbKPhOIMJGTrnj7S2qC1kTw58TOYH2zs8BrZrW2OMKDwBiU)9LOCLSFc8TqNPhi4xcFR04Bf4eVVfloy6FlQCaz6b(TOYH2zs8BXgAsOdjbi1KSZAdX9TaXodmUVLSu2)(suUVIpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(TU8i1KSmArdh248BbIDgyCFl5(VVeLRK)tGVf6m9ab)s4BLgFRaN49TyXbt)BrLditpWVfvo0otIFlor9LhPMKLrlA4WgNFlqSZaJ7Bj3)9LOCBrFc8TqNPhi4xcFR04BnX7BXIdM(3IkhqMEGFlQ8aa)wYwBlPwkQfBXaqddeuHKgTdKh6maD2fyTesyTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTuu7Xd0pfhc2rnkAsf6m9abRLqcRTv1ksQOZ(PiQDazVwIR1uTuuBRQvKurN9t5OiYrgG1siH1YIdsf1OJKqCwR0ALTwcjS2aWXEg2OAcnAsxpVmivOZ0deSwIR1uTTQwrsfD2pfv0VM2rTexlXFlQCODMe)wD4Sb6260aDm(3xIeKC(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5ba(TWwma0WabvKSGPdupBq80KatOOwcjSwSfdanmqqL9GbH8LXutZG2yTesyTylgaAyGGk7bdc5lJPMeb5XaMETesyTylgaAyGGkqoiImtxdIcI0gaxGtb6cSwcjSwSfdanmqqf0NIa4y6bQBXaSFaKAqKkuG1siH1ITyaOHbcQMjWyG3bDBDaq3UwcjSwSfdanmqq1eWPhzcQzs8AApVAjKWAXwma0WabvpmrOJXu3J0bRLqcRfBXaqddeu1hmjQZUMMVBGFlQCODMe)wSHoDnWe)3xIeKSFc8TyXbt)BrcJidnKKTXVf6m9ab)s4FFjsqY9tGVf6m9ab)s4Bjc4HbK)wZeyqdDqf1CWhCG6zoOI(PqNPhiyTesyTZeyqdDqLbW8agOgdaJdMUcDMEGGFlwCW0)w9boBeb3V)9LibrqFc8TqNPhi4xcFlrapmG83sKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwRPAfPdcapfhc2rTrKGq72k0z6bcwRPAPYbKPhOIhpC7PE22fArMdW8XN1AQwwCqQOgDKeIZAFPwQCaz6bQ4e1hh24PfjGFFlwCW0)wbGJ6SRnYhm(3xIeKK7tGVf6m9ab)s4Bjc4HbK)wTQwQCaz6bQmc0aym0i1SwP1kBTMQnaCSNHnQaHtb0yaDoARfjjj7Gk0z6bc(TyXbt)B1JCE054(3xIeeL9jW3cDMEGGFj8Teb8WaYFRwvlvoGm9avgbAamgAKAwR0ALTwt12QAdah7zyJkq4uangqNJ2ArssYoOcDMEGG1AQwkQTv1ksQOZ(POI(10oQLqcRLkhqMEGQoC2aDBDAGog1s83Ifhm9Vfhc2rn9GN3)(sKGKSFc8TqNPhi4xcFlrapmG83Qv1sLditpqLrGgaJHgPM1kTwzR1uTTQ2aWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQvKurN9trf9RPDuRPABvTu5aY0du1HZgOBRtd0X4BXIdM(3IegrgtD21xgKOF)7lrc6v8jW3cDMEGGFj8Teb8WaYFlQCaz6bQmc0aym0i1SwP1k73Ifhm9Vfsnf8bt)F)7BXj(jWxIY(jW3cDMEGGFj8Teb8WaYFRaWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQvK5amFCfnqVRbHtb0yaDoARfjjj7GQazW21AQwAGExbcNcOXa6C0wlsss2b19iNNcmF8Anvlf1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8AjUwt1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvo1AQwkQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhOItuF5rQjzz0IgoSXzTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwBbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzz0G4GBR7zOzJAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APYbKPhO6YJutYYObXb3w3ZqZg1sCTesyTImhG5JR4qWoQnYhmubsYqFw7lsR1wawlX1s83Ifhm9VvpY5rNJ7FFjk3pb(wOZ0de8lHVLiGhgq(BrrTbGJ9mSrfiCkGgdOZrBTijjzhuHotpqWAnvRiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTR1uT0a9UceofqJb05OTwKKKSdQ7WavG5JxRPAncKQ2waQKv1JCE054QL4AjKWAPO2aWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQ9GKyTsRvo1s83Ifhm9VvhgOMEWZ7FFjsqFc8TqNPhi4xcFlrapmG83kaCSNHnQSd4C0wdfqXavOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwcso1AQwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYPwt1srT0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avCI6lpsnjlJw0WHnoR1uTuulf1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9fP1AlaR1uTImhG5JR4qWoQnYhmubsYqFwR8RLkhqMEGQlpsnjlJgehCBDpdnBulX1siH1srTTQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlvoGm9avxEKAswgnio426EgA2OwIRLqcRvK5amFCfhc2rTr(GHkqsg6ZAFrAT2cWAjUwI)wS4GP)T6ropTNu5)9LOK7tGVf6m9ab)s4Bjc4HbK)wbGJ9mSrLDaNJ2AOakgOcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRvATYPwt1srTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwQCaz6bQydnjlJgehCBDpd9LhzTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYPwt1sd07koeSJArdh2OAESGOAFrATu5aY0duXjQV8i1KSmArdh24SwIRL4AnvlnqVRcah1zxBKpyOaZhVwI)wS4GP)T6ropTNu5)9LiL9jW3cDMEGGFj8TyXbt)BXHGDutcNt4aNFlrdd9VLSFlrapmG83sKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwRPAPb6Dfhc2rDdhKP3wnpwquTVuRSuwTMQvK5amFCvWGq2p90GdIubsYqFw7lsRLkhqMEGQgoitVTEESGi9bjXAPuTOmOa4q9bjXAnvRiZby(4Qlben6SRVgutY2qvGKm0N1(I0APYbKPhOQHdY0BRNhlisFqsSwkvlkdkaouFqsSwkvlloy6QGbHSF6PbhePqzqbWH6dsI1AQwrMdW8XvCiyh1g5dgQajzOpR9fP1sLditpqvdhKP3wppwqK(GKyTuQwuguaCO(GKyTuQwwCW0vbdcz)0tdoisHYGcGd1hKeRLs1YIdMU6sarJo76Rb1KSnuHYGcGd1hKe)3xIs2pb(wOZ0de8lHVLiGhgq(BjsQOZ(POI(10oQ1uThpq)uCiyh1OOjvOZ0deSwt1EqsS2xQvw5uRPAfzoaZhxrcJiJPo76lds0pvGKm0N1AQwAGExjgihcEEq3wnpwquTVulb9TyXbt)BXHGDutp459VVeFfFc8TqNPhi4xcFlwCW0)wZeymW7GUToaOB)Teb8WaYFRaWXEg2OAcnAsxpVmivOZ0deSwt1AeivTTaujRcPMc(GP)TCMe)wZeymW7GUToaOB)VVeL8Fc8TqNPhi4xcFlrapmG83kaCSNHnQMqJM01Zldsf6m9abR1uTgbsvBlavYQqQPGpy6FlwCW0)wxciA0zxFnOMKTH)7lXw0NaFl0z6bc(LW3seWddi)Tcah7zyJQj0OjD98YGuHotpqWAnvlf1AeivTTaujRcPMc(GPxlHewRrGu12cqLSQlben6SRVgutY2WAj(BXIdM(3Idb7O2iFW4FFjkRC(e4BHotpqWVe(wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1(I0AL81AQwrMdW8XvxciA0zxFnOMKTHQajzOpR9fP1k5R1uTuulnqVR4qWoQfnCyJQ5XcIQ9fP1sLditpqfNO(YJutYYOfnCyJZAnvlf1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFrAT2cWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APSAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APSAjUwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1AlaRL4Aj(BXIdM(3IegrgtD21xgKOF)7lrzL9tGVf6m9ab)s4Bjc4HbK)whKeRv(1sqYPwt1gao2ZWgvtOrt665LbPcDMEGG1AQwrsfD2pfv0VM2rTMQ1iqQABbOswfjmImM6SRVmir)(wS4GP)TqQPGpy6)7lrzL7NaFl0z6bc(LW3seWddi)ToijwR8RLGKtTMQnaCSNHnQMqJM01Zldsf6m9abR1uT0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avCI6lpsnjlJw0WHnoR1uTImhG5JRUeq0OZU(AqnjBdvbsYqFwR0ALtTMQvK5amFCfhc2rTr(GHkqsg6ZAFrAT2cWVfloy6FlKAk4dM()(suwc6tGVf6m9ab)s4BXIdM(3cPMc(GP)TG(HrayCAy)Brd07Qj0OjD98YGunpwqKuAGExnHgnPRNxgKkswg98ybrFlOFyeagNgssIGq(WVLSFlrapmG836GKyTYVwcso1AQ2aWXEg2OAcnAsxpVmivOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTsRvo1AQwkQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1sLditpqfBOjzz0G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvo1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLrlA4WgN1sCTexRPAPb6Dva4Oo7AJ8bdfy(41s8)(suwj3NaFl0z6bc(LW3seWddi)TezoaZhxDjGOrND91GAs2gQcKKH(S2xQfLbfahQpijwRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7lsR1wawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlvoGm9avxEKAswgnio426EgA2OwIRLqcRLIABvThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQU8i1KSmAqCWT19m0SrTexlHewRiZby(4koeSJAJ8bdvGKm0N1(I0ATfG1s83Ifhm9VvWGq2p90GdI(3xIYszFc8TqNPhi4xcFlrapmG83sK5amFCfhc2rTr(GHkqsg6ZAFPwuguaCO(GKyTMQLIAPOwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALFTu5aY0duXgAswgnio426Eg6lpYAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfevlX1siH1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR0ALtTMQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhOItuF5rQjzz0IgoSXzTexlX1AQwAGExfaoQZU2iFWqbMpETe)TyXbt)BfmiK9tpn4GO)9LOSs2pb(wOZ0de8lHVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTsRvo1AQwkQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1sLditpqfBOjzz0G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvo1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLrlA4WgN1sCTexRPAPb6Dva4Oo7AJ8bdfy(41s83Ifhm9VfiYxdDgo(VVeL9v8jW3cDMEGGFj8TyXbt)BntGXaVd626aGU93seWddi)TOOwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLrlA4WgN1siH1AeivTTaujRkyqi7NEAWbr1sCTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwBbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzz0G4GBR7zOzJAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APYbKPhO6YJutYYObXb3w3ZqZg1sCTesyTImhG5JR4qWoQnYhmubsYqFw7lsR1wawlXFlNjXV1mbgd8oOBRda62)7lrzL8Fc8TqNPhi4xcFlrapmG83IIAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswgTOHdBCwlHewRrGu12cqLSQGbHSF6PbhevlX1AQwkQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ATfG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sLditpq1LhPMKLrdIdUTUNHMnQL4AjKWAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RLkhqMEGQlpsnjlJgehCBDpdnBulX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTwBbyTe)TyXbt)BDjGOrND91GAs2g(VVeLTf9jW3cDMEGGFj8Teb8WaYFlkQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlvoGm9avSHMKLrdIdUTUNH(YJSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1sCTesyTuuRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5uRPAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswgTOHdBCwlX1sCTMQLgO3vbGJ6SRnYhmuG5J)TyXbt)BXHGDuBKpy8VVeLRC(e4BHotpqWVe(wIaEya5VfnqVRcah1zxBKpyOaZhVwt1srTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)ALRCQ1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvo1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLrlA4WgN1sCTexRPAPOwrMdW8XvCiyh1g5dgQajzOpRv(1kRCRLqcRfePb6D1LaIgD21xdQjzBOcWOwI)wS4GP)Tcah1zxBKpy8VVeLRSFc8TqNPhi4xcFlrapmG83sK5amFCfhc2rDg0QajzOpRv(1sz1siH12QApEG(P4qWoQZGwHotpqWVfloy6FRzdSFq3wBKpy8VVeLRC)e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQvATsUAnvRrGu12cqLSkoeSJ6mOR1uTS4Gurn6ijeN1(sTVIVfloy6FloeSJA6bpV)9LOCjOpb(wOZ0de8lHVLiGhgq(BjsQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOALwRK7BXIdM(3Idb7OMMJGTX)9LOCLCFc8TqNPhi4xcFlrapmG83sKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwRPAPb6Dfhc2rTr(GHcWOwt1srTG5PcgeY(PNgCqKkqsg6ZALFTs2AjKWAbrAGExfmiK9tpn4GinvGHJbtdhWRTcWOwIR1uTGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwquTVuRKRwt1YIdsf1OJKqCwR0AjOVfloy6FloeSJA6bpV)9LOCPSpb(wOZ0de8lHVLiGhgq(BjsQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOALwlb9TyXbt)BXHGDuNb9)(suUs2pb(wOZ0de8lHVLiGhgq(BjsQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOALwRC)wS4GP)T4qWoQP5iyB8FFjk3xXNaFl0z6bc(LW3seWddi)Tejv0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1AQwAGExXHGDuBKpyOamQ1uTgbsvBlavYvfmiK9tpn4GOAnvlloivuJoscXzTYVwc6BXIdM(3Idb7OgLXyKty6)7lr5k5)e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQvATYwRPAzXbPIA0rsioRv(1sqFlwCW0)wCiyh1OmgJCct)FFjk3w0NaFl0z6bc(LW3seWddi)TOb6DfiYxdDgoQamQ1uTGinqVRUeq0OZU(AqnjBdvag1AQwqKgO3vxciA0zxFnOMKTHQajzOpR9fP1sd07kJaNOlqD21KqhurYYONhliQ2wsTS4GPR4qWoQPh88uOmOa4q9bjXAnvlf1srThpq)ubotNDbQqNPhiyTMQLfhKkQrhjH4S2xQvYvlX1siH1YIdsf1OJKqCw7l1sz1sCTMQLIABvTbGJ9mSrfhc2rnDssZbij6NcDMEGG1siH1ECyJNQb5X1OmexTYVwcIYQL4Vfloy6FlJaNOlqD21Kqh8FFjsqY5tGVf6m9ab)s4Bjc4HbK)w0a9Uce5RHodhvag1AQwkQLIApEG(PcCMo7cuHotpqWAnvlloivuJoscXzTVuRKRwIRLqcRLfhKkQrhjH4S2xQLYQL4Anvlf12QAdah7zyJkoeSJA6KKMdqs0pf6m9abRLqcR94WgpvdYJRrziUALFTeeLvlXFlwCW0)wCiyh10dEE)7lrcs2pb(wS4GP)TMagy4jv(BHotpqWVe(3xIeKC)e4BHotpqWVe(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQv(sRLIAzXbPIA0rsioRTfQwzRL4AnvBa4ypdBuXHGDutNK0CasI(PqNPhiyTMQ94WgpvdYJRrziUAFPwcIY(wS4GP)T4qWoQP5iyB8FFjsqe0NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOVfloy6FloeSJAAoc2g)3xIeKK7tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQwP1kNAnvlf1kYCaMpUIdb7O2iFWqfijd9zTYVwzPSAjKWABvTuuRiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwIRL4Vfloy6FloeSJ6mO)3xIeeL9jW3cDMEGGFj8Teb8WaYFlkQnWEGZgMEG1siH12QApOGiOBxlX1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhli6BXIdM(3YXRbd9HKg48(3xIeKK9tGVf6m9ab)s4Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLIAPO2JhOFkM0ya7qbFW0vOZ0deSwt1YIdsf1OJKqCw7l1k5RL4AjKWAzXbPIA0rsioR9LAPSAj(BXIdM(3Idb7OMeoNWbo)3xIe0R4tGVf6m9ab)s4Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQ2JhOFkoeSJAu0Kk0z6bcwRPAbrAGExDjGOrND91GAs2gQamQ1uTuu7Xd0pftAmGDOGpy6k0z6bcwlHewlloivuJoscXzTVuBlQwI)wS4GP)T4qWoQjHZjCGZ)9Libj5)e4BHotpqWVe(wIaEya5VfnqVRedKdbppOBRcKfxTMQ94b6NIjngWouWhmDf6m9abR1uTS4Gurn6ijeN1(sTsUVfloy6FloeSJAs4Cch48FFjsqTOpb(wOZ0de8lHVLiGhgq(Brd07koeSJArdh2OAESGOAFPwAGExXHGDulA4WgvKSm65XcI(wS4GP)T4qWoQrzmg5eM()(suYjNpb(wOZ0de8lHVLiGhgq(Brd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwJaPQTfGkzvCiyh10CeSn(TyXbt)BXHGDuJYymYjm9)9VVvdhKP3(tGVeL9tGVf6m9ab)s4BXIdM(3cPMc(GP)TaXPiGghm9V1RSx7iFQn9AjzNRLDWAfzoaZhFwlhyTIKe621cyyET2zTCdYG1YoyTi18Bjc4HbK)wKSZkdXv7lsRLGKtTMQLkhqMEGQe4MqquNDTiZby(4ZAnvlf1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9LALvo1s8)(suUFc8TqNPhi4xcFlqCkcOXbt)BjzI1(W(v7L1opwquTnCqME7A7aJrBvTeObRfyI1M9ALvYw78ybrZABWaRfoR9YAzHib8R2Eg1EnyThuquTdSF1METxdwROHDhh1YoyTxdwljCoHdSwOxBFaTBo13seWddi)TOOwQCaz6bQMhlis3Wbz6TRLqcR9GKyTVuRSYPwIR1uT0a9UIdb7OUHdY0BRMhliQ2xQvwj73s0Wq)Bj73Ifhm9Vfhc2rnjCoHdC(VVejOpb(wOZ0de8lHVfloy6FloeSJAs4Cch48BbItranoy6FljZg0RfycD7ALminAhipQ91jaD2fO51k45vlxBhFQfL5cUws4Cch4S2Ng4aR9HHh0TRTNrTxdwlnqVxlF1EnyTZJJR2Sx71G12H2n33seWddi)TWwma0WabviPr7a5HodqNDbwRPApijw7l1sqYPwt1EPT9avImhG5JpR1uTImhG5JRqsJ2bYdDgGo7cufijd9zTYVwzLSs(AnvBRQLfhmDfsA0oqEOZa0zxGkq4KPhi4)(suY9jW3cDMEGGFj8TyXbt)BntGXaVd626aGU93seWddi)TOYbKPhOcjnYhmqqnnhbBJ1AQwrMdW8XvxciA0zxFnOMKTHQajzOpR9fP1IYGcGd1hKeR1uTImhG5JR4qWoQnYhmubsYqFw7lsRLIArzqbWH6dsI12sQvU1s83Yzs8BntGXaVd626aGU9)(sKY(e4BHotpqWVe(wIaEya5VfvoGm9aviPr(GbcQP5iyBSwt1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwuguaCO(GKyTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATuulkdkaouFqsS2wsTYTwIR1uTuuBRQfBXaqddeuntGXaVd626aGUDTesyTI0bbGNIdb7O2isqODBvWor1kFP1sz1siH1kYCaMpUAMaJbEh0T1baDBvGKm0N1k)ALvw5ulXFlwCW0)wbdcz)0tdoi6FFjkz)e4BHotpqWVe(wIaEya5VfvoGm9avTWaZtdmrq90GdIQ1uTImhG5JR4qWoQnYhmubsYqFw7lsRfLbfahQpijwRPAPO2wvl2IbGggiOAMaJbEh0T1baD7AjKWAfPdcapfhc2rTrKGq72QGDIQv(sRLYQLqcRvK5amFC1mbgd8oOBRda62QajzOpRv(1kRSYPwI)wS4GP)TUeq0OZU(AqnjBd)3xIVIpb(wOZ0de8lHVLiGhgq(BzeivTTaujR6sarJo76Rb1KSn8BXIdM(3Idb7O2iFW4FFjk5)e4BHotpqWVe(wIaEya5VfvoGm9aviPr(GbcQP5iyBSwt1kYCaMpUkyqi7NEAWbrQajzOpR9fP1IYGcGd1hKeR1uTu5aY0duDqsud4hCOzJALV0ALRCQ1uTuuBRQvKoia8uCiyh1grccTBRqNPhiyTesyTTQwQCaz6bQ4Xd3EQNTDHwK5amF8zTesyTImhG5JRUeq0OZU(AqnjBdvbsYqFw7lsRLIArzqbWH6dsI12sQvU1sCTe)TyXbt)BfaoQZU2iFW4FFj2I(e4BHotpqWVe(wIaEya5VfvoGm9aviPr(GbcQP5iyBSwt1AeivTTaujRkaCuNDTr(GX3Ifhm9VvWGq2p90GdI(3xIYkNpb(wOZ0de8lHVLiGhgq(BrLditpqvlmW80ateupn4GOAnvBRQLkhqMEGQMCacDB9Lh53Ifhm9V1LaIgD21xdQjzB4)(suwz)e4BHotpqWVe(wS4GP)T4qWoQP5iyB8BbItranoy6FRwGjwRCDWA5qWowlnhbBJ1c9AB5xLsV(xNxT20hTRf2RvcJmbhaZRw2bRLVAhipVALBTTU1ZAnIuiqWVLiGhgq(Brd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwAGExfaoQZU2iFWqbyuRPAPb6Dfhc2rTr(GHcWOwt1sd07koeSJ6goitVTAESGOALV0ALvYwRPAPb6Dfhc2rTr(GHkqsg6ZAFrATS4GPR4qWoQP5iyBuHYGcGd1hKeR1uT0a9UIEKj4ayEkaJ)9LOSY9tGVf6m9ab)s4BXIdM(3kaCuNDTr(GX3ceNIaACW0)wTatSw56G1(6ZxTwOxBl)Q1M(ODTWETsyKj4ayE1YoyTYT2w36zTgrk(wIaEya5VfnqVRcah1zxBKpyOaZhVwt1sd07k6rMGdG5PamQ1uTuulvoGm9avhKe1a(bhA2Ow5xlbjNAjKWAfzoaZhxfmiK9tpn4GivGKm0N1k)ALvU1sCTMQLIAPb6Dfhc2rDdhKP3wnpwquTYxATYsz1siH1sd07kXa5qWZd62Q5XcIQv(sRv2AjUwt1srTTQwr6GaWtXHGDuBeji0UTcDMEGG1siH12QAPYbKPhOIhpC7PE22fArMdW8XN1s8)(suwc6tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLIAPYbKPhO6GKOgWp4qZg1k)Aji5ulHewRiZby(4QGbHSF6PbhePcKKH(Sw5xRSYTwIR1uTuuBRQvKoia8uCiyh1grccTBRqNPhiyTesyTTQwQCaz6bQ4Xd3EQNTDHwK5amF8zTe)TyXbt)BfaoQZU2iFW4FFjkRK7tGVf6m9ab)s4Bjc4HbK)wu5aY0duHKg5dgiOMMJGTXAnvlf1sd07koeSJArdh2OAESGOALV0ALBTesyTImhG5JR4qWoQZGwfid2UwIR1uTuuBRQ94b6NkaCuNDTr(GHcDMEGG1siH1kYCaMpUkaCuNDTr(GHkqsg6ZALFTuwTexRPAPYbKPhOcNhKKpeuZgArMdW8XRv(sRLGKtTMQLIABvTI0bbGNIdb7O2isqODBf6m9abRLqcRTv1sLditpqfpE42t9STl0ImhG5JpRL4Vfloy6FRGbHSF6Pbhe9VVeLLY(e4BHotpqWVe(wS4GP)TUeq0OZU(AqnjBd)wG4ueqJdM(3sYSb9Ada3HUDTgrccTBBETatS2lpYAPBxl8M4Oxl0RndqmQ9YA5b02RfE1(aVMAzJVLiGhgq(BrLditpq1bjrnGFWHMnQ9LAPm5uRPAPYbKPhO6GKOgWp4qZg1k)Aji5uRPAPO2wvl2IbGggiOAMaJbEh0T1baD7AjKWAfPdcapfhc2rTrKGq72QGDIQv(sRLYQL4)9LOSs2pb(wOZ0de8lHVLiGhgq(BrLditpqvlmW80ateupn4GOAnvlnqVR4qWoQfnCyJQ5XcIQ9LAPb6Dfhc2rTOHdBurYYONhli6BXIdM(3Idb7Ood6)9LOSVIpb(wOZ0de8lHVLiGhgq(BbI0a9Ukyqi7NEAWbrAQadhdMgoGxB18ybr1kTwqKgO3vbdcz)0tdoistfy4yW0Wb8ARizz0ZJfe9TyXbt)BXHGDutZrW24)(suwj)NaFl0z6bc(LW3seWddi)TOYbKPhOQfgyEAGjcQNgCquTesyTuulisd07QGbHSF6PbhePPcmCmyA4aETvag1AQwqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhliQ2xQfePb6DvWGq2p90GdI0ubgogmnCaV2kswg98ybr1s83Ifhm9Vfhc2rn9GN3)(su2w0NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)B1cmXAjHoSwjWrW2yT049GOxBWGq2VANgCq0SwyVwaheJALabx7d8AsGRwqCWTHUDTVEgeY(vRLbhevlee5XO93seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UIEKj4ayEkaJAnvRiZby(4QGbHSF6PbhePcKKH(S2xKwRSYPwt1sd07koeSJ6goitVTAESGOALV0ALvY(VVeLRC(e4BHotpqWVe(wS4GP)T4qWoQZG(BbItranoy6FRwGjwBg01METcWAb8boN1Yg1cN1kssOBxlGrTZm9VLiGhgq(Brd07koeSJArdh2OAESGOAFPwcQwt1sLditpq1bjrnGFWHMnQv(1kRCQ1uTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)APSAjKWABvTI0bbGNIdb7O2isqODBf6m9abRL4)9LOCL9tGVf6m9ab)s4BXIdM(3Idb7OMeoNWbo)wIgg6Flz)wIaEya5VfnqVRedKdbppOBRcKfxTMQLgO3vCiyh1g5dgkaJ)9LOCL7NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)B9k71(G1AJxTg5dg1c9oWeMETGab0TRDamVAFW3JrTnmvSw0ta7MAB45H1EzT24vB271Y1oViD7AP5iyBSwqGa621EnyTrAij2O2hOdMpFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTViTwwCW0vCiyh1KW5eoWPcLbfahQpijwRPAPb6Dfhc2rTr(GHcWOwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwAGExXHGDu3Wbz6TvZJfevRPAPb6DLr(GHg6DGjmDfGrTMQLgO3v0JmbhaZtby8VVeLlb9jW3cDMEGGFj8TyXbt)BXHGDutp459TaXPiGghm9V1RSx7dwRnE1AKpyul07aty61cceq3U2bW8Q9bFpg12WuXArpbSBQTHNhw7L1AJxTzVxlx78I0TRLMJGTXAbbcOBx71G1gPHKyJAFGoy(yETZS2h89yuB6J21cmXArpbSBQLEWZBwl0HhKhJ21EzT24v7L12tGOwrdh248Bjc4HbK)w0a9UYiWj6cuNDnj0bvag1AQwkQLgO3vCiyh1IgoSr18ybr1(sT0a9UIdb7Ow0WHnQizz0ZJfevlHewBRQLIAPb6DLr(GHg6DGjmDfGrTMQLgO3v0JmbhaZtbyulX1s8)(suUsUpb(wOZ0de8lHVfloy6FlJaNOlqD21Kqh8BbItranoy6Flc0G1sJZRwGjwB2R1ijRfoR9YAbMyTWR2lRTfdafenAxlnaCawROHdBCwliqaD7AzJA5(HrTxd2UwB8QfeG0abRLUDTxdwBdhKP3UwAoc2g)wIaEya5VfnqVR4qWoQfnCyJQ5XcIQ9LAPb6Dfhc2rTOHdBurYYONhliQwt1sd07koeSJAJ8bdfGX)(suUu2NaFl0z6bc(LW3ceNIaACW0)wsMyTpSF1EzTZJfevBdhKP3U2oWy0wvlbAWAbMyTzVwzLS1opwq0S2gmWAHZAVSwwisa)QTNrTxdw7bfev7a7xTPx71G1kAy3XrTSdw71G1scNt4aRf612hq7Mt9TyXbt)BXHGDutcNt4aNFlOFyeag33s2VLOHH(3s2VLiGhgq(Brd07koeSJ6goitVTAESGOAFPwzLSFlOFyeagN2EK084Bj7)(suUs2pb(wOZ0de8lHVLiGhgq(Brd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwQCaz6bQqsJ8bdeutZrW243Ifhm9Vfhc2rnnhbBJ)7lr5(k(e4BHotpqWVe(wIaEya5Vfj7SYqC1(sTYszFlwCW0)wi1uWhm9)9LOCL8Fc8TqNPhi4xcFlwCW0)wCiyh10dEEFlqCkcOXbt)B964J21cmXAPh88Q9YAPbGdWAfnCyJZAH9AFWA5rGmy7AByQyTZKeRThjzTzq)Teb8WaYFlAGExXHGDulA4WgvZJfevRPAPb6Dfhc2rTOHdBunpwquTVulnqVR4qWoQfnCyJkswg98ybr)7lr52I(e4BHotpqWVe(wG4ueqJdM(361vWXO2h41ultwlGpW5Sw2Ow4SwrscD7AbmQLDWAFW3bw7iFQn9AjzN)wS4GP)T4qWoQjHZjCGZVf0pmcaJ7Bj73s0Wq)Bj73seWddi)TAvTuulvoGm9avhKe1a(bhA2O2xKwRSYPwt1sYoRmexTVulbjNAj(Bb9dJaW402JKMhFlz)3xIeKC(e4BHotpqWVe(wG4ueqJdM(36vJSdh4S2h41u7iFQLKNhgTnV2gODtTn88qZRnJAPZRPwsUDTEE12WuXArpbSBQLKDU2lRDcyyKXvBt(ulj7CTq)qFcPI1gmiK9R2PbhevRG9APrZRDM1(GVhJAbMyTDyG1sp45vl7G12JCE054Q9Pb9Ah5tTPxlj783Ifhm9VvhgOMEWZ7FFjsqY(jW3Ifhm9VvpY5rNJ7BHotpqWVe(3)(wcEiag8btF(jWxIY(jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8Bj73seWddi)TOYbKPhOQHPI60aDeSwP1kNAnvRrGu12cqLSkKAk4dMETMQTv1srTbGJ9mSr1eA0KUEEzqQqNPhiyTesyTbGJ9mSr1HKgzWd9dhgk0z6bcwlXFlQCODMe)wnmvuNgOJG)7lr5(jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8Bj73seWddi)TOYbKPhOQHPI60aDeSwP1kNAnvlnqVR4qWoQnYhmuG5JxRPAfzoaZhxXHGDuBKpyOcKKH(Swt1srTbGJ9mSr1eA0KUEEzqQqNPhiyTesyTbGJ9mSr1HKgzWd9dhgk0z6bcwlXFlQCODMe)wnmvuNgOJG)7lrc6tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43s2VLiGhgq(Brd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQ2wvlnqVRcGbQZU(AceNkaJAnvBhA3C6ajzOpR9fP1srTuulj7CTsQwwCW0vCiyh10dEEkroVAjU2wsTS4GPR4qWoQPh88uOmOa4q9bjXAj(BrLdTZK43QdDEOPbc)FFjk5(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5ba(TOb6Dfhc2rDdhKP3wnpwquTYxATYsz1siH1srTbGJ9mSrfhc2rnDssZbij6NcDMEGG1AQ2JdB8unipUgLH4Q9LAjikRwI)wG4ueqJdM(3sYaEnyulxBhymAx78ybriyTnCqME7AZOwOxlkdkaoS2GDBS2h41uRessAoajr)(wu5q7mj(TqsJ8bdeutZrW24)(sKY(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5q7mj(Tg880SHgyIFlqSZaJ7BjNVLiGhgq(Brd07koeSJAJ8bdfGrTMQLIAPYbKPhOAWZtZgAGjwR0ALtTesyThKeRv(sRLkhqMEGQbppnBObMyTuQwzPSAj(BrLha436GK4)(suY(jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8BrrTImhG5JR4qWoQnYhmuGabFW0RTLulf1kBTTq1srTYrjhcQ2wsTI0bbGNIdb7O2isqODBvWor1sCTexlX12cvlf1EqsS2wOAPYbKPhOAWZtZgAGjwlXFlqCkcOXbt)B1YHGDS2xnsqOD7ATHuXzTCTu5aY0dSwMmb8R2SxRammVwAGR2h89yulWeRLRTp4RwCEqs(GPxBdgOQwc0G1oHKIAnIKkeebRnqsg6tnkJbkoeSwugJaNty61cM4SwpVAFYGOAFWXO2Eg1Aeji0UDTGayTxw71G1sdeZRDToFabwB2R9AWAfGH6BrLdTZK43cNhKKpeuZgArMdW8X)3xIVIpb(wOZ0de8lHVvA8TM49TyXbt)BrLditpWVfvEaGFlQCaz6bQW5bj5db1SHwK5amF8VLiGhgq(BjsheaEkoeSJAJibH2T)wu5q7mj(ToijQb8do0SX)(suY)jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8BjYCaMpUIdb7O2iFWqfijd953seWddi)TAvTI0bbGNIdb7O2isqODBf6m9ab)wu5q7mj(ToijQb8do0SX)(sSf9jW3cDMEGGFj8TsJVfjlZ3Ifhm9VfvoGm9a)wu5q7mj(ToijQb8do0SX3seWddi)TOOwrMdW8XvxciA0zxFnOMKTHQajzOpRTfQwQCaz6bQoijQb8do0SrTex7l1kx58TaXPiGghm9VLKj(EmQfehC7AB5xTwaJAVSw5kNjkQTNrTeiVw63IkpaWVLiZby(4Qlben6SRVgutY2qvGKm0N)7lrzLZNaFl0z6bc(LW3kn(wKSmFlwCW0)wu5aY0d8BrLdTZK436GKOgWp4qZgFlrapmG83sKoia8uCiyh1grccTBxRPAfPdcapfhc2rTrKGq72QGDIQ9LAPSAnvl2IbGggiOAMaJbEh0T1baD7AnvRiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0de8BbItranoy6FllOlWAF9a0TRfoRDciAQLR1iFWOdmQ9cOteE12ZO2xx3oGSBETp47XO25bfev7L1EnyT3twlj0boSwrBXaRfWp4O2hSwB8QLRTbA3ul6jGDtTb7evB2R1isqOD7VfvEaGFlrMdW8XvZeymW7GUToaOBRcKKH(8FFjkRSFc8TqNPhi4xcFR04BnX7BXIdM(3IkhqMEGFlQ8aa)wImhG5JRUeq0OZU(AqnjBdvbYGTR1uTu5aY0duDqsud4hCOzJAFPw5kNVfiofb04GP)TKmX3JrTG4GBxlbYRLwlGrTxwRCLZef12ZO2w(v)wu5q7mj(TAYbi0T1xEK)7lrzL7NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVff1AeivTTaujRkyqi7NEAWbr1siH1AeivTTaujxvWGq2p90GdIQLqcR1iqQABbOIGubdcz)0tdoiQwIR1uTS4GPRcgeY(PNgCqK6GKOEcDbw7l1AlaRTLuRC)wG4ueqJdM(361ZGq2VATm4GOAbtCwRNxTqsseeYhoAxRbWvlGrTxdwlvGHJbtdhWRDTGinqVx7mRfE1kyVwASwqyVdfaJR2lRfeofy41En8v7d(oWA5R2RbRTfeg51ulvGHJbtdhWRDTZJfe9TOYH2zs8B1cdmpnWeb1tdoi6FFjklb9jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8AnvBRQLkhqMEGQwyG5PbMiOEAWbr1AQwqKgO3vbdcz)0tdoistfy4yW0Wb8ARaZh)BrLdTZK43kbUjee1zxlYCaMp(8FFjkRK7tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43kaCSNHnQ4qWoQB4Gm92k0z6bcwRPAPOwkQvKurN9tru7aYETMQvK5amFCvWGq2p90GdIubsYqFw7l1sLditpqvdhKP3wppwqK(GKyTexlXFlQCODMe)wZJfePB4Gm92)7FFRo05HMgi8pb(su2pb(wOZ0de8lHVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)w0a9Usmqoe88GUTkqwC)7lr5(jW3Ifhm9Vfhc2rn9GN33cDMEGGFj8VVejOpb(wS4GP)T4qWoQP5iyB8BHotpqWVe(3)(33Ikgty6Fjkx5ixzLJKx2w036Hdh62ZVLKzl)6L4RuIVUP8ARLanyTqsJmUA7zu77goitV97AdSfdadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1klLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1szuETToDQyCiyTVVa6eHNIPfkrMdW8XFx7L1(wK5amFCftlExlfYkdXQYmcg6yTswkV2wNovmoeS23xaDIWtX0cLiZby(4VR9YAFlYCaMpUIPfVRLczLHyvzgbdDSwjpLxBRtNkghcw7Br6GaWtjV31EzTVfPdcapL8uOZ0de8DTuiRmeRkZiyOJ1kRCP8ABD6uX4qWAFlsheaEk59U2lR9TiDqa4PKNcDMEGGVRLczLHyvzgbdDSwzjikV2wNovmoeS23I0bbGNsEVR9YAFlsheaEk5PqNPhi47APqwziwvMrWqhRvwjhLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1kRKJYRT1PtfJdbR9TiDqa4PK37AVS23I0bbGNsEk0z6bc(UwkKvgIvLzem0XALRCO8ABD6uX4qWAFlsheaEk59U2lR9TiDqa4PKNcDMEGGVRLczLHyvzwzMKzl)6L4RuIVUP8ARLanyTqsJmUA7zu77oC2aDBDAGogVRnWwmamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYvgIvLzem0XALlLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1squETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTsokV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSwkJYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRvYs51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DT8vRKXRdbxlfYkdXQYmcg6yTTikV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDS2weLxBRtNkghcw7Br6GaWtjV31EzTVfPdcapL8uOZ0de8DT8vRKXRdbxlfYkdXQYmcg6yTYkxkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLc5kdXQYmcg6yTYszuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYk5P8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XALTfr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kxzP8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLczLHyvzgbdDSw5k5O8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKRmeRkZiyOJ1kxjhLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31YxTsgVoeCTuiRmeRkZiyOJ1kxjlLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31YxTsgVoeCTuiRmeRkZiyOJ1k3xbLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZkZKmB5xVeFLs81nLxBTeObRfsAKXvBpJAFh5Xhm931gylgagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMrWqhRvwkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSw5s51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1squETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTugLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1kzP8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLczLHyvzgbdDSwzLdLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1kBlIYRT1PtfJdbR99Xd0pL8Ex7L1((4b6NsEk0z6bc(UwkKvgIvLzem0XALTfr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kx5q51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlfYkdXQYmcg6yTYvouETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYvwkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMrWqhRvUYs51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kx5s51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kxcIYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMvMjz2YVEj(kL4RBkV2AjqdwlK0iJR2Eg1(onqhJ31gylgagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSw5s51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1klbr51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlfYkdXQYmcg6yTYkzP8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(Uw(QvY41HGRLczLHyvzgbdDSwzFfuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlF1kz86qW1sHSYqSQmJGHowRSsEkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMvMjz2YVEj(kL4RBkV2AjqdwlK0iJR2Eg1(ge7mW4ExBGTyayGG1otsSwg4ss(qWAfnSBJtvzgbdDSw5s51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlfYvgIvLzem0XALCuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYk5O8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XALvYs51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kRKNYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRvUYHYRT1PtfJdbR1cs26ANT9JLP2wWv7L1sWaCTGqQWjm9Atdm4lJAPqsexlfYkdXQYmcg6yTYvouETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYLGO8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(Uw(QvY41HGRLczLHyvzgbdDSw5k5O8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XALlLr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kxjlLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRCFfuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYvYt51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZkZKmB5xVeFLs81nLxBTeObRfsAKXvBpJAFBeOijP57DTb2IbGbcw7mjXAzGlj5dbRv0WUnovLzem0XALSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTswkV2wNovmoeS23I0bbGNsEVR9YAFlsheaEk5PqNPhi47APqwziwvMrWqhRvUYHYRT1PtfJdbR9TiDqa4PK37AVS23I0bbGNsEk0z6bc(UwkKvgIvLzem0XALRSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYvwkV2wNovmoeS23I0bbGNsEVR9YAFlsheaEk5PqNPhi47APqwziwvMrWqhRvUYLYRT1PtfJdbR9TiDqa4PK37AVS23I0bbGNsEk0z6bc(UwkKvgIvLzem0XALBlIYRT1PtfJdbR99Xd0pL8Ex7L1((4b6NsEk0z6bc(UwkKRmeRkZiyOJ1k3weLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowlbjxkV2wNovmoeS23ZeyqdDqL8Ex7L1(EMadAOdQKNcDMEGGVRLczLHyvzgbdDSwcsUuETToDQyCiyTVNjWGg6Gk59U2lR99mbg0qhujpf6m9abFxlF1kz86qW1sHSYqSQmJGHowlbrquETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTeebr51260PIXHG1(wKoia8uY7DTxw7Br6GaWtjpf6m9abFxlfYkdXQYmcg6yTeKKJYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47A5RwjJxhcUwkKvgIvLzem0XAjikJYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRLGKSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYSYmjZw(1lXxPeFDt51wlbAWAHKgzC12ZO23ImhG5JpFxBGTyayGG1otsSwg4ss(qWAfnSBJtvzgbdDSwzP8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLc5kdXQYmcg6yTYs51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kxkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqUYqSQmJGHowRCP8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XAjikV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqUYqSQmJGHowlbr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1k5O8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XAPmkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSwjlLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuixziwvMrWqhR9vq51260PIXHG1(EMadAOdQK37AVS23ZeyqdDqL8uOZ0de8DTuixziwvMrWqhRTfr51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlfYvgIvLzem0XALvouETToDQyCiyTVpEG(PK37AVS23hpq)uYtHotpqW31sHCLHyvzgbdDSwzLlLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuixziwvMrWqhRvwcIYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRvwjhLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRSugLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1kRKLYRT1PtfJdbR99Xd0pL8Ex7L1((4b6NsEk0z6bc(UwkKvgIvLzem0XALRCO8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLczLHyvzwzMKzl)6L4RuIVUP8ARLanyTqsJmUA7zu7BoX31gylgagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqUYqSQmJGHowRSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYLYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqUYqSQmJGHowlbr51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlfYvgIvLzem0XAjikV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSwjhLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowlLr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kzP8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLczLHyvzgbdDS2xbLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRKNYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRTfr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kRCO8ABD6uX4qWAFF8a9tjV31EzTVpEG(PKNcDMEGGVRLc5kdXQYmcg6yTYklLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRSYLYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRvwcIYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqwziwvMrWqhRvwjhLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuixziwvMrWqhRv2xbLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuixziwvMrWqhRvwjpLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuixziwvMrWqhRvUYs51260PIXHG1((4b6NsEVR9YAFF8a9tjpf6m9abFxlF1kz86qW1sHSYqSQmJGHowRCLlLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRCjikV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSw5k5O8ABD6uX4qWAFhao2ZWgvY7DTxw77aWXEg2OsEk0z6bc(UwkKvgIvLzem0XALlLr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1kxjlLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRCFfuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTYvYt51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1k3weLxBRtNkghcw77JhOFk59U2lR99Xd0pL8uOZ0de8DTuiRmeRkZiyOJ1k3weLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowlbjhkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMrWqhRLGKdLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowlbjxkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLczLHyvzgbdDSwcsYr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZiyOJ1sqswkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMrWqhRLGKSuETToDQyCiyTVdah7zyJk59U2lR9Da4ypdBujpf6m9abFxlfYkdXQYmcg6yTe0RGYRT1PtfJdbR99Xd0pL8Ex7L1((4b6NsEk0z6bc(UwkKRmeRkZiyOJ1sqsEkV2wNovmoeS23hpq)uY7DTxw77JhOFk5PqNPhi47APqwziwvMvMjz2YVEj(kL4RBkV2AjqdwlK0iJR2Eg1(wWdbWGpy6Z31gylgagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNovmoeS23bGJ9mSrL8Ex7L1(oaCSNHnQKNcDMEGGVRLc5kdXQYmcg6yTYLYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47APqUYqSQmJGHowlbr51260PIXHG1AbjBDTZ2(XYuBl4Q9YAjyaUwqiv4eMETPbg8LrTuijIRLczLHyvzgbdDSwjhLxBRtNkghcw77aWXEg2OsEVR9YAFhao2ZWgvYtHotpqW31sHSYqSQmJGHowRKNYRT1PtfJdbR9TiDqa4PK37AVS23I0bbGNsEk0z6bc(Uw(QvY41HGRLczLHyvzgbdDSwzLdLxBRtNkghcw77lGor4PyAHsK5amF831EzTVfzoaZhxX0I31sHSYqSQmJGHowRSYHYRT1PtfJdbR9Da4ypdBujV31EzTVdah7zyJk5PqNPhi47A5RwjJxhcUwkKvgIvLzem0XALvYr51260PIXHG1(oaCSNHnQK37AVS23bGJ9mSrL8uOZ0de8DTuiRmeRkZkZELKgzCiyTYkNAzXbtV2bCEtvz23YiYoCGFRx71QTLY2yTTCiyhlZETxR2wgWgyE1kxcY8ALRCKRSLzLzV2RvBRBy3gNuEz2R9A12cvBlWeR9ABaf8OwlizRRTHDWb0TRn71kAy3XrTq)Wiamoy61c95HmyTzV23c2f4qZIdM(Bvz2R9A12cvBRBy3gRLdb7Og6DOdV21EzTCiyh1nCqME7APaE16ivmQ9b9R2bKkwlpRLdb7OUHdY0BtSQm71ETABHQ91L0FF1kzqnf8H1c9AB5xhjJABHbMxT0OGbMyTTtG3bwBcC1M9Ad2TXAzhSwpVAbMq3U2woeSJ1kziJXiNW0vLzLzS4GPpvgbkssA(OKujXHGDud9dhduCLzS4GPpvgbkssA(OKujXHGDu3zs4aYrzgloy6tLrGIKKMpkjvsI0BHbcutYoRTrYYmwCW0NkJafjjnFusQKOYbKPhO5otIs5e1hh24PfjGFMNgsdCIN5GyNbgNucQmJfhm9PYiqrssZhLKkjQCaz6bAUZKOuKAQneN5PH0aN4zoi2zGXjvwkRmJfhm9PYiqrssZhLKkjQCaz6bAUZKOuJanagdnsnnpnKoXZCyxkfbGJ9mSr1eA0KUEEzqAIcrsfD2pfv0VM2bHeksQOZ(PCue5idqcjuKoia8uCiyh1grccTBtmXMtLhaOuznNkpaqnoMOu5uMXIdM(uzeOijP5JssLevoGm9an3zsuAdtf1Pb6iO5PH0jEMd7szXbPIA0rsioLVuQCaz6bQ4e1hh24PfjGFMtLhaOuznNkpaqnoMOu5uMXIdM(uzeOijP5JssLevoGm9an3zsuAh68qtdeU5PH0jEMtLhaOu5uMXIdM(uzeOijP5JssLevoGm9an3zsuAdhKP3wppwqK(GKO5PH0aN4zoi2zGXjTfvMXIdM(uzeOijP5JssLevoGm9an3zsukpE42t9STl0ImhG5JpnpnKg4epZbXodmoPYPmJfhm9PYiqrssZhLKkjQCaz6bAUZKO0yQjzz0G4GBR7zOV8inpnKg4epZbXodmoPuwzgloy6tLrGIKKMpkjvsu5aY0d0CNjrPXutYYObXb3w3ZqhPH5PH0aN4zoi2zGXjLYkZyXbtFQmcuKK08rjPsIkhqMEGM7mjknMAswgnio426EgA2W80qAGt8mhe7mW4Kkx5uMXIdM(uzeOijP5JssLevoGm9an3zsukzEAJaficQV8i10TnpnKg4epZbXodmoPs(YmwCW0NkJafjjnFusQKOYbKPhO5otIsjZttYYObXb3w3ZqF5rAEAinWjEMdIDgyCsLvoLzS4GPpvgbkssA(OKujrLditpqZDMeLsMNMKLrdIdUTUNHMnmpnKg4epZbXodmoPYszLzS4GPpvgbkssA(OKujrLditpqZDMeLYgAswgnio426Eg6lpsZtdPboXZCyxQiDqa4P4qWoQnIeeA32CQ8aaLsqYXCQ8aa14yIsLvoLzS4GPpvgbkssA(OKujrLditpqZDMeLYgAswgnio426Eg6lpsZtdPboXZCqSZaJtQCLtzgloy6tLrGIKKMpkjvsu5aY0d0CNjrPSHMKLrdIdUTUNHMmpZtdPboXZCqSZaJtQCLtzgloy6tLrGIKKMpkjvsu5aY0d0CNjrPrAOjzz0G4GBR7zOV8inpnKoXZCQ8aaLkx50crbL1sePdcapfhc2rTrKGq72exMXIdM(uzeOijP5JssLevoGm9an3zsu6LhPMKLrdIdUTUNHMnmpnKoXZCQ8aaLszusUYPLqHiPIo7NYH2nNUZiHesHiDqa4P4qWoQnIeeA32eloivuJoscX5lu5aY0duXjQpoSXtlsa)iMykjlL1sOqKurN9tru7aYUPaWXEg2OIdb7OUHdY0BBIfhKkQrhjH4u(sPYbKPhOItuFCyJNwKa(rCzgloy6tLrGIKKMpkjvsu5aY0d0CNjrPxEKAswgnio426Eg6inmpnKoXZCQ8aaLkx50crHKVLisheaEkoeSJAJibH2TjUmJfhm9PYiqrssZhLKkjQCaz6bAUZKOuAoc2g1KSZAdXzEAiDIN5WUursfD2pLdTBoDNrZPYdauQKvoTquqYZdJ2AQ8aaBjYkh5qCzgloy6tLrGIKKMpkjvsu5aY0d0CNjrP0CeSnQjzN1gIZ80q6epZHDPIKk6SFkIAhq2nNkpaqPTikRfIcsEEy0wtLhaylrw5ihIlZyXbtFQmcuKK08rjPsIkhqMEGM7mjkLMJGTrnj7S2qCMNgsN4zoSlLkhqMEGkAoc2g1KSZAdXjvoMtLhaOujVCAHOGKNhgT1u5ba2sKvoYH4YmwCW0NkJafjjnFusQKOYbKPhO5otIszdnj0HKaKAs2zTH4mpnKg4epZbXodmoPYszLzS4GPpvgbkssA(OKujrLditpqZDMeLE5rQjzz0IgoSXP5PH0aN4zoi2zGXjvULzS4GPpvgbkssA(OKujrLditpqZDMeLYjQV8i1KSmArdh24080qAGt8mhe7mW4Kk3YmwCW0NkJafjjnFusQKOYbKPhO5otIs7Wzd0T1Pb6yyEAiDIN5u5bakv2wcfylgaAyGGkK0ODG8qNbOZUajKqkoEG(Pcah1zxBKpyyIIJhOFkoeSJAu0KesyRejv0z)ue1oGStSjkALiPIo7NYrrKJmajKqwCqQOgDKeItPYsiHbGJ9mSr1eA0KUEEzqsSPwjsQOZ(POI(10oiM4YmwCW0NkJafjjnFusQKOYbKPhO5otIszdD6AGjAEAiDIN5u5bakfBXaqddeurYcMoq9SbXttcmHccjeBXaqddeuzpyqiFzm10mOnsiHylgaAyGGk7bdc5lJPMeb5XaMoHeITyaOHbcQa5GiYmDnikisBaCbofOlqcjeBXaqddeub9PiaoMEG6wma7haPgePcfiHeITyaOHbcQMjWyG3bDBDaq3MqcXwma0WabvtaNEKjOMjXRP98iKqSfdanmqq1dte6ym19iDqcjeBXaqddeu1hmjQZUMMVBGLzS4GPpvgbkssA(OKujrcJidnKKTXYmwCW0NkJafjjnFusQK6dC2icUFMd7sNjWGg6GkQ5Gp4a1ZCqf9JqcNjWGg6GkdG5bmqngaghm9YmwCW0NkJafjjnFusQKcah1zxBKpyyoSlvKurN9tru7aYUPaWXEg2OIdb7OUHdY0BBsKoia8uCiyh1grccTBBIkhqMEGkE8WTN6zBxOfzoaZhFAIfhKkQrhjH48fQCaz6bQ4e1hh24PfjGFLzS4GPpvgbkssA(OKuj1JCE054mh2L2kQCaz6bQmc0aym0i1uQSMcah7zyJkq4uangqNJ2ArssYoyzgloy6tLrGIKKMpkjvsCiyh10dEEMd7sBfvoGm9avgbAamgAKAkvwtTkaCSNHnQaHtb0yaDoARfjjj7GMOOvIKk6SFkQOFnTdcjKkhqMEGQoC2aDBDAGogexMXIdM(uzeOijP5JssLejmImM6SRVmir)mh2L2kQCaz6bQmc0aym0i1uQSMAva4ypdBubcNcOXa6C0wlsss2bnjsQOZ(POI(10om1kQCaz6bQ6Wzd0T1Pb6yuMXIdM(uzeOijP5JssLesnf8bt3CyxkvoGm9avgbAamgAKAkv2YSYmwCW0NusQKejGFymnWXOmJfhm9jLKkjGjQjzN12iP5WUukoEG(PqFaTBo0rqtKSZkdX9IujVCmrYoRmeN8LkzPmIjKqkA1Xd0pf6dODZHocAIKDwziUxKk5PmIlZyXbtFsjPsYipy6Md7sPb6Dfhc2rTr(GHcWOmJfhm9jLKkPdsI6hommh2Lgao2ZWgvhsAKbp0pCyyIgO3vOmnmW8GPRammrHiZby(4koeSJAJ8bdvGmyBcjKoNttDODZPdKKH(8fPso5qCzgloy6tkjvsdODZn1TWaG2KOFMd7sPb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHcmFCtGinqVRUeq0OZU(AqnjBdvG5JxMXIdM(KssLenBRZU(cOGOP5WUuAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfy(4LzS4GPpPKujrJXedIGUT5WUuAGExXHGDuBKpyOamkZyXbtFsjPsIEKjOUdeTnh2Lsd07koeSJAJ8bdfGrzgloy6tkjvsDyG0Jmbnh2Lsd07koeSJAJ8bdfGrzgloy6tkjvsSlW5f8ql4XWCyxknqVR4qWoQnYhmuagLzS4GPpPKujbmrn8qYP5WUuAGExXHGDuBKpyOamkZyXbtFsjPscyIA4HKMJ9okoTZKOu7bdc5lJPMMbTrZHDP0a9UIdb7O2iFWqbyqiHImhG5JR4qWoQnYhmubsYqFkFPugLzcePb6D1LaIgD21xdQjzBOcWOmJfhm9jLKkjGjQHhsAUZKOuK0ODG8qNbOZUanh2LkYCaMpUIdb7O2iFWqfijd95lsLLYmjYCaMpU6sarJo76Rb1KSnufijd95lsLLYkZyXbtFsjPscyIA4HKM7mjkfmqgSddutfNtCyoSlvK5amFCfhc2rTr(GHkqsg6t5lvUYHqcBfvoGm9avSHoDnWeLklHesXbjrPYXevoGm9avD4Sb6260aDmKkRPaWXEg2OAcnAsxpVmijUmJfhm9jLKkjGjQHhsAUZKO0zcm0qBhEyyoSlvK5amFCfhc2rTr(GHkqsg6t5lLGKdHe2kQCaz6bQydD6AGjkv2YmwCW0NusQKaMOgEiP5otIsThTnA0zxZZjKeo4dMU5WUurMdW8XvCiyh1g5dgQajzOpLVu5khcjSvu5aY0duXg601atuQSesifhKeLkhtu5aY0du1HZgOBRtd0XqQSMcah7zyJQj0OjD98YGK4YmwCW0NusQKaMOgEiP5otIsjzbthOE2G4PjbMqH5WUurMdW8XvCiyh1g5dgQajzOpFrkLzIIwrLditpqvhoBGUTonqhdPYsiHhKeLpbjhIlZyXbtFsjPscyIA4HKM7mjkLKfmDG6zdINMeycfMd7sfzoaZhxXHGDuBKpyOcKKH(8fPuMjQCaz6bQ6Wzd0T1Pb6yivwt0a9UkaCuNDTr(GHcWWenqVRcah1zxBKpyOcKKH(8fPuiRCAHOSwsa4ypdBunHgnPRNxgKeB6GK4leKCkZyXbtFsjPscyIA4HKM7mjkD2WG5dcQZGwND9Lbj6N5WU0dsIsLdHesbvoGm9avjWnHGOo7ArMdW8XNMOGcrsfD2pfrTdi7MezoaZhxfmiK9tpn4GivGKm0NVivUMezoaZhxXHGDuBKpyOcKKH(8fPuMjrMdW8XvxciA0zxFnOMKTHQajzOpFrkLrmHekYCaMpUIdb7O2iFWqfijd95lsLlHe2H2nNoqsg6ZxezoaZhxXHGDuBKpyOcKKH(KyIlZETAPmLKTw4S2RbRDAGiyTzV2RbR1kbgd8oOBx7RhGUDTgr2cJIdoWYmwCW0NusQKaMOgEiP5otIsNjWyG3bDBDaq32Cyxkfu5aY0duDqsud4hCOzdkrbloy6QGbHSF6PbhePqzqbWH6dsITersfD2pfrTdi7etjkyXbtxbI81qNHJkuguaCO(GKylrKurN9t5OiYrgGetjwCW0vxciA0zxFnOMKTHkuguaCO(GK4lhh24PaHZJDb2coktjzj2efu5aY0du1WurDAGocsiHuisQOZ(PiQDaz3ua4ypdBuXHGDud9o0HxBIj20XHnEkq48yxGYxUuwz2R9A1YIdM(KssLKJp9eWb1boZbv0CGjQFAGdul45bDBPYAoSlLgO3vCiyh1g5dgkadcjeePb6D1LaIgD21xdQjzBOcWGqcbZtfmiK9tpn4Gi1bfebD7YmwCW0NusQKe8yOzXbtxpGZZCNjrPcEiag8btFwMXIdM(KssLKGhdnloy66bCEM7mjkLt085fqXjvwZHDPS4Gurn6ijeNYxkvoGm9avCI6JdB80IeWVYmwCW0NusQKe8yOzXbtxpGZZCNjrPnCqMEBZHDPIKk6SFkIAhq2nfao2ZWgvCiyh1nCqME7YmwCW0NusQKe8yOzXbtxpGZZCNjrPD4Sb6260aDmmh2LsLditpqvdtf1Pb6iOu5yIkhqMEGQoC2aDBDAGogMAffIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBIlZyXbtFsjPssWJHMfhmD9aopZDMeLMgOJH5WUuQCaz6bQAyQOonqhbLkhtTIcrsfD2pfrTdi7Mcah7zyJkoeSJ6goitVnXLzS4GPpPKujj4XqZIdMUEaNN5otIsfzoaZhFAoSlTvuisQOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TjUmJfhm9jLKkjbpgAwCW01d48m3zsuAKhFW0nh2LsLditpqvh68qtdeUu5yQvuisQOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TjUmJfhm9jLKkjbpgAwCW01d48m3zsuAh68qtdeU5WUuQCaz6bQ6qNhAAGWLkRPwrHiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3M4YSYmwCW0NkorP9iNhDooZHDPbGJ9mSrfiCkGgdOZrBTijjzh0KiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTnrd07kq4uangqNJ2ArssYoOUh58uG5JBIcAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfy(4eBsK5amFC1LaIgD21xdQjzBOkqsg6tPYXef0a9UIdb7Ow0WHnQMhli6fPu5aY0duXjQV8i1KSmArdh240efuC8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrQTa0KiZby(4koeSJAJ8bdvGKm0NYNkhqMEGQlpsnjlJgehCBDpdnBqmHesrRoEG(Pcah1zxBKpyysK5amFCfhc2rTr(GHkqsg6t5tLditpq1LhPMKLrdIdUTUNHMniMqcfzoaZhxXHGDuBKpyOcKKH(8fP2cqIjUmJfhm9PItKssLuhgOMEWZZCyxkfbGJ9mSrfiCkGgdOZrBTijjzh0KiZby(4kAGExdcNcOXa6C0wlsss2bvbYGTnrd07kq4uangqNJ2ArssYoOUddubMpUjJaPQTfGkzv9iNhDooIjKqkcah7zyJkq4uangqNJ2ArssYoOPdsIsLdXLzS4GPpvCIusQK6ropTNuzZHDPbGJ9mSrLDaNJ2AOakgOjrMdW8XvCiyh1g5dgQajzOpLpbjhtImhG5JRUeq0OZU(AqnjBdvbsYqFkvoMOGgO3vCiyh1IgoSr18ybrViLkhqMEGkor9LhPMKLrlA4WgNMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzz0G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFQCaz6bQU8i1KSmAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasmXLzS4GPpvCIusQK6ropTNuzZHDPbGJ9mSrLDaNJ2AOakgOjrMdW8XvCiyh1g5dgQajzOpLkhtuqbfImhG5JRUeq0OZU(AqnjBdvbsYqFkFQCaz6bQydnjlJgehCBDpd9LhPjAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGiIjKqkezoaZhxDjGOrND91GAs2gQcKKH(uQCmrd07koeSJArdh2OAESGOxKsLditpqfNO(YJutYYOfnCyJtIj2enqVRcah1zxBKpyOaZhN4YmwCW0NkorkjvsCiyh1KW5eoWP5WUursfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDu3Wbz6TvZJfe9ISuMjrMdW8Xvbdcz)0tdoisfijd95lsPYbKPhOQHdY0BRNhlisFqsKsOmOa4q9bjrtImhG5JRUeq0OZU(AqnjBdvbsYqF(IuQCaz6bQA4Gm9265XcI0hKePekdkaouFqsKsS4GPRcgeY(PNgCqKcLbfahQpijAsK5amFCfhc2rTr(GHkqsg6ZxKsLditpqvdhKP3wppwqK(GKiLqzqbWH6dsIuIfhmDvWGq2p90GdIuOmOa4q9bjrkXIdMU6sarJo76Rb1KSnuHYGcGd1hKenx0WqxQSLzS4GPpvCIusQK4qWoQPh88mh2LksQOZ(POI(10omD8a9tXHGDuJIM00bjXxKvoMezoaZhxrcJiJPo76lds0pvGKm0NMOb6DLyGCi45bDB18ybrVqqLzS4GPpvCIusQKaMOgEiP5otIsNjWyG3bDBDaq32CyxAa4ypdBunHgnPRNxgKMmcKQ2waQKvHutbFW0lZyXbtFQ4ePKujDjGOrND91GAs2gAoSlnaCSNHnQMqJM01ZldstgbsvBlavYQqQPGpy6LzS4GPpvCIusQK4qWoQnYhmmh2Lgao2ZWgvtOrt665LbPjkmcKQ2waQKvHutbFW0jKqJaPQTfGkzvxciA0zxFnOMKTHexMXIdM(uXjsjPsIegrgtD21xgKOFMd7sfzoaZhxXHGDuBKpyOcKKH(8fPsEtImhG5JRUeq0OZU(AqnjBdvbsYqF(IujVjkOb6Dfhc2rTOHdBunpwq0lsPYbKPhOItuF5rQjzz0IgoSXPjkO44b6NkaCuNDTr(GHjrMdW8XvbGJ6SRnYhmubsYqF(IuBbOjrMdW8XvCiyh1g5dgQajzOpLpLrmHesrRoEG(Pcah1zxBKpyysK5amFCfhc2rTr(GHkqsg6t5tzetiHImhG5JR4qWoQnYhmubsYqF(IuBbiXexMXIdM(uXjsjPscPMc(GPBoSl9GKO8ji5ykaCSNHnQMqJM01ZldstIKk6SFkQOFnTdtgbsvBlavYQiHrKXuND9Lbj6xzgloy6tfNiLKkjKAk4dMU5WU0dsIYNGKJPaWXEg2OAcnAsxpVminrd07koeSJArdh2OAESGOxKsLditpqfNO(YJutYYOfnCyJttImhG5JRUeq0OZU(AqnjBdvbsYqFkvoMezoaZhxXHGDuBKpyOcKKH(8fP2cWYmwCW0Nkorkjvsi1uWhmDZHDPhKeLpbjhtbGJ9mSr1eA0KUEEzqAsK5amFCfhc2rTr(GHkqsg6tPYXefuqHiZby(4Qlben6SRVgutY2qvGKm0NYNkhqMEGk2qtYYObXb3w3ZqF5rAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliIycjKcrMdW8XvxciA0zxFnOMKTHQajzOpLkht0a9UIdb7Ow0WHnQMhli6fPu5aY0duXjQV8i1KSmArdh24KyInrd07QaWrD21g5dgkW8Xj2COFyeagNg2Lsd07Qj0OjD98YGunpwqKuAGExnHgnPRNxgKkswg98ybrMd9dJaW40qsseeYhkv2YmwCW0Nkorkjvsbdcz)0tdoiYCyxQiZby(4Qlben6SRVgutY2qvGKm0NVGYGcGd1hKenrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYYObXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzz0G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaK4YmwCW0Nkorkjvsbdcz)0tdoiYCyxQiZby(4koeSJAJ8bdvGKm0NVGYGcGd1hKenrbfuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYXenqVR4qWoQfnCyJQ5XcIErkvoGm9avCI6lpsnjlJw0WHnojMyt0a9UkaCuNDTr(GHcmFCIlZyXbtFQ4ePKujbI81qNHJMd7sfzoaZhxXHGDuBKpyOcKKH(uQCmrbfuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYXenqVR4qWoQfnCyJQ5XcIErkvoGm9avCI6lpsnjlJw0WHnojMyt0a9UkaCuNDTr(GHcmFCIlZyXbtFQ4ePKujbmrn8qsZDMeLotGXaVd626aGUT5WUukOb6Dfhc2rTOHdBunpwq0lsPYbKPhOItuF5rQjzz0IgoSXjHeAeivTTaujRkyqi7NEAWbreBIckoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NVi1waAsK5amFCfhc2rTr(GHkqsg6t5tLditpq1LhPMKLrdIdUTUNHMniMqcPOvhpq)ubGJ6SRnYhmmjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYYObXb3w3ZqZgetiHImhG5JR4qWoQnYhmubsYqF(IuBbiXLzS4GPpvCIusQKUeq0OZU(AqnjBdnh2LsbnqVR4qWoQfnCyJQ5XcIErkvoGm9avCI6lpsnjlJw0WHnojKqJaPQTfGkzvbdcz)0tdoiIytuqXXd0pva4Oo7AJ8bdtImhG5JRcah1zxBKpyOcKKH(8fP2cqtImhG5JR4qWoQnYhmubsYqFkFQCaz6bQU8i1KSmAqCWT19m0SbXesifT64b6NkaCuNDTr(GHjrMdW8XvCiyh1g5dgQajzOpLpvoGm9avxEKAswgnio426EgA2GycjuK5amFCfhc2rTr(GHkqsg6ZxKAlajUmJfhm9PItKssLehc2rTr(GH5WUukOqK5amFC1LaIgD21xdQjzBOkqsg6t5tLditpqfBOjzz0G4GBR7zOV8inrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLJjAGExXHGDulA4WgvZJfe9IuQCaz6bQ4e1xEKAswgTOHdBCsmXMOb6Dva4Oo7AJ8bdfy(4LzS4GPpvCIusQKcah1zxBKpyyoSlLgO3vbGJ6SRnYhmuG5JBIckezoaZhxDjGOrND91GAs2gQcKKH(u(YvoMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYXenqVR4qWoQfnCyJQ5XcIErkvoGm9avCI6lpsnjlJw0WHnojMytuiYCaMpUIdb7O2iFWqfijd9P8LvUesiisd07Qlben6SRVgutY2qfGbXLzS4GPpvCIusQKMnW(bDBTr(GH5WUurMdW8XvCiyh1zqRcKKH(u(ugHe2QJhOFkoeSJ6mOlZyXbtFQ4ePKujXHGDutp45zoSlvKurN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwqKujNjJaPQTfGkzvCiyh1zqBIfhKkQrhjH48Lxrzgloy6tfNiLKkjoeSJAAoc2gnh2LksQOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhlisQKRmJfhm9PItKssLehc2rn9GNN5WUursfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDuBKpyOammrbyEQGbHSF6PbhePcKKH(u(swcjeePb6DvWGq2p90GdI0ubgogmnCaV2kadInbI0a9Ukyqi7NEAWbrAQadhdMgoGxB18ybrVi5mXIdsf1OJKqCkLGkZyXbtFQ4ePKujXHGDuNbT5WUursfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDuBKpyOammbI0a9Ukyqi7NEAWbrAQadhdMgoGxB18ybrsjOYmwCW0NkorkjvsCiyh10CeSnAoSlvKurN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwqKu5wMXIdM(uXjsjPsIdb7OgLXyKty6Md7sfjv0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MOb6Dfhc2rTr(GHcWWKrGu12cqLCvbdcz)0tdoiYeloivuJoscXP8jOYmwCW0NkorkjvsCiyh1OmgJCct3CyxQiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMarAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPYAIfhKkQrhjH4u(euzgloy6tfNiLKkjJaNOlqD21Kqh0CyxknqVRar(AOZWrfGHjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF(IuAGExze4eDbQZUMe6Gkswg98ybrTewCW0vCiyh10dEEkuguaCO(GKOjkO44b6NkWz6SlqtS4Gurn6ijeNVi5iMqczXbPIA0rsioFHYi2efTkaCSNHnQ4qWoQPtsAoajr)iKWJdB8unipUgLH4KpbrzexMXIdM(uXjsjPsIdb7OMEWZZCyxknqVRar(AOZWrfGHjkO44b6NkWz6SlqtS4Gurn6ijeNVi5iMqczXbPIA0rsioFHYi2efTkaCSNHnQ4qWoQPtsAoajr)iKWJdB8unipUgLH4KpbrzexMXIdM(uXjsjPsAcyGHNu5YmwCW0NkorkjvsCiyh10CeSnAoSlLgO3vCiyh1IgoSr18ybrYxkfS4Gurn6ijeNTqYsSPaWXEg2OIdb7OMojP5aKe9Z0XHnEQgKhxJYqCVqquwzgloy6tfNiLKkjoeSJAAoc2gnh2Lsd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfevMXIdM(uXjsjPsIdb7OodAZHDP0a9UIdb7Ow0WHnQMhlisQCmrHiZby(4koeSJAJ8bdvGKm0NYxwkJqcBffIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBIjUmJfhm9PItKssLKJxdg6djnW5zoSlLIa7boBy6bsiHT6GcIGUnXMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIkZyXbtFQ4ePKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mfao2ZWgvCiyh1nCqMEBtuqXXd0pftAmGDOGpy6MyXbPIA0rsioFrYtmHeYIdsf1OJKqC(cLrCzgloy6tfNiLKkjoeSJAs4Cch40CyxknqVRedKdbppOBRcKfNPJhOFkoeSJAu0KMarAGExDjGOrND91GAs2gQammrXXd0pftAmGDOGpy6esiloivuJoscX5lTiIlZyXbtFQ4ePKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mD8a9tXKgdyhk4dMUjwCqQOgDKeIZxKCLzS4GPpvCIusQK4qWoQrzmg5eMU5WUuAGExXHGDulA4WgvZJfe9cnqVR4qWoQfnCyJkswg98ybrLzS4GPpvCIusQK4qWoQrzmg5eMU5WUuAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGitgbsvBlavYQ4qWoQP5iyBSm71ETAzXbtFQ4ePKujHutbFW0nh6hgbGXPHDPKSZkdXjFPsEkZCOFyeagNgssIGq(qPYwMvMXIdM(uj4HayWhm9PuQCaz6bAUZKO0gMkQtd0rqZtdPt8mNkpaqPYAoSlLkhqMEGQgMkQtd0rqPYXKrGu12cqLSkKAk4dMUPwrra4ypdBunHgnPRNxgKesya4ypdBuDiPrg8q)WHbXLzS4GPpvcEiag8btFsjPsIkhqMEGM7mjkTHPI60aDe080q6epZPYdauQSMd7sPYbKPhOQHPI60aDeuQCmrd07koeSJAJ8bdfy(4MezoaZhxXHGDuBKpyOcKKH(0efbGJ9mSr1eA0KUEEzqsiHbGJ9mSr1HKgzWd9dhgexMXIdM(uj4HayWhm9jLKkjQCaz6bAUZKO0o05HMgiCZtdPt8mNkpaqPYAoSlLgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYuROb6DvamqD21xtG4ubyyQdTBoDGKm0NViLckizNBbhloy6koeSJA6bppLiNhXTewCW0vCiyh10dEEkuguaCO(GKiXLzVwTsgWRbJA5A7aJr7ANhlicbRTHdY0BxBg1c9ArzqbWH1gSBJ1(aVMALqssZbij6xzgloy6tLGhcGbFW0NusQKOYbKPhO5otIsrsJ8bdeutZrW2O5PH0jEMtLhaOuAGExXHGDu3Wbz6TvZJfejFPYszesifbGJ9mSrfhc2rnDssZbij6NPJdB8unipUgLH4EHGOmIlZyXbtFQe8qam4dM(KssLevoGm9an3zsu6GNNMn0at0CqSZaJtQCmpnKoXZCyxknqVR4qWoQnYhmuagMOGkhqMEGQbppnBObMOu5qiHhKeLVuQCaz6bQg880SHgyIuswkJyZPYdau6bjXYSxR2woeSJ1(QrccTBxRnKkoRLRLkhqMEG1YKjGF1M9AfGH51sdC1(GVhJAbMyTCT9bF1IZdsYhm9ABWav1sGgS2jKuuRrKuHGiyTbsYqFQrzmqXHG1IYye4CctVwWeN165v7tgev7dog12ZOwJibH2TRfeaR9YAVgSwAGyETR15diWAZETxdwRamuLzS4GPpvcEiag8btFsjPsIkhqMEGM7mjkfNhKKpeuZgArMdW8XnpnKoXZCQ8aaLsHiZby(4koeSJAJ8bdfiqWhm9wcfY2crHCuYHGAjI0bbGNIdb7O2isqODBvWoretmXTquCqsSfIkhqMEGQbppnBObMiXLzS4GPpvcEiag8btFsjPsIkhqMEGM7mjk9GKOgWp4qZgMNgsN4zoSlvKoia8uCiyh1grccTBBovEaGsPYbKPhOcNhKKpeuZgArMdW8XlZyXbtFQe8qam4dM(KssLevoGm9an3zsu6bjrnGFWHMnmpnKoXZCyxARePdcapfhc2rTrKGq72MtLhaOurMdW8XvCiyh1g5dgQajzOplZETALmX3JrTG4GBxBl)Q1cyu7L1kx5mrrT9mQLa51slZyXbtFQe8qam4dM(KssLevoGm9an3zsu6bjrnGFWHMnmpnKsYYyovEaGsfzoaZhxDjGOrND91GAs2gQcKKH(0CyxkfImhG5JRUeq0OZU(AqnjBdvbsYqF2crLditpq1bjrnGFWHMni(f5kNYSxRwlOlWAF9a0TRfoRDciAQLR1iFWOdmQ9cOteE12ZO2xx3oGSBETp47XO25bfev7L1EnyT3twlj0boSwrBXaRfWp4O2hSwB8QLRTbA3ul6jGDtTb7evB2R1isqOD7YmwCW0Nkbpead(GPpPKujrLditpqZDMeLEqsud4hCOzdZtdPKSmMtLhaO0lGor4PMjWyG3bDBDaq3wjYCaMpUkqsg6tZHDPI0bbGNIdb7O2isqODBtI0bbGNIdb7O2isqODBvWorVqzMWwma0WabvZeymW7GUToaOBBsKurN9tru7aYUPaWXEg2OIdb7OUHdY0BxM9A1kzIVhJAbXb3UwcKxlTwaJAVSw5kNjkQTNrTT8RwMXIdM(uj4HayWhm9jLKkjQCaz6bAUZKO0MCacDB9LhP5PH0jEMtLhaOurMdW8XvxciA0zxFnOMKTHQazW2MOYbKPhO6GKOgWp4qZgVix5uM9A1(6zqi7xTwgCquTGjoR1ZRwijjcc5dhTR1a4QfWO2RbRLkWWXGPHd41UwqKgO3RDM1cVAfSxlnwliS3HcGXv7L1ccNcm8AVg(Q9bFhyT8v71G12ccJ8AQLkWWXGPHd41U25XcIkZyXbtFQe8qam4dM(KssLevoGm9an3zsuAlmW80ateupn4GiZtdPt8mNkpaqPuyeivTTaujRkyqi7NEAWbresOrGu12cqLCvbdcz)0tdoiIqcncKQ2waQiivWGq2p90GdIi2eloy6QGbHSF6PbhePoijQNqxGVylaBjYTm71ETAFDcOn05rTwqYwxRObfeHG1cI0a9Ukyqi7NEAWbrAQadhdMgoGxBfy(4MxlnWv71WxTGjo93xTpzquTpnOx71G1YGGPxlBymG4S2xVvl4xl0Nh73OTQm71ETAzXbtFQe8qam4dM(KssLevoGm9an3zsuAlmW80ateupn4GiZtdPt8mNkpaqPuyeivTTaujRkyqi7NEAWbresOrGu12cqLCvbdcz)0tdoiIqcncKQ2waQiivWGq2p90GdIi2eisd07QGbHSF6PbhePPcmCmyA4aETvG5JxMXIdM(uj4HayWhm9jLKkjQCaz6bAUZKO0e4MqquNDTiZby(4tZtdPt8mNkpaqP0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kQCaz6bQAHbMNgyIG6PbhezcePb6DvWGq2p90GdI0ubgogmnCaV2kW8XlZyXbtFQe8qam4dM(KssLevoGm9an3zsu68ybr6goitVT5PH0jEMtLhaO0aWXEg2OIdb7OUHdY0BBIckejv0z)ue1oGSBsK5amFCvWGq2p90GdIubsYqF(cvoGm9avnCqMEB98ybr6dsIetCzwz2Rv7RgWmGhSfewlWe621AhW5ODTqbumWAFGxtTSHQ2wGjwl8Q9bEn1E5rwBEny8aNOQmJfhm9PsK5amF8P0EKZt7jv2CyxAa4ypdBuzhW5OTgkGIbAsK5amFCfhc2rTr(GHkqsg6t5tqYXKiZby(4Qlben6SRVgutY2qvGmyBtuqd07koeSJArdh2OAESGOxKsLditpq1LhPMKLrlA4WgNMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzz0G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFQCaz6bQU8i1KSmAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasmXLzS4GPpvImhG5JpPKuj1JCEApPYMd7sdah7zyJk7aohT1qbumqtImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqoetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lRCmrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLJjAGExXHGDulA4WgvZJfejvoetSjAGExfaoQZU2iFWqbMpUjs2zLH4KVuQCaz6bQydnj0HKaKAs2zTH4kZyXbtFQezoaZhFsjPsQh58OZXzoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b19iNNcmFCtuqd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MarAGExDjGOrND91GAs2gQaZhNytImhG5JRUeq0OZU(AqnjBdvbsYqFkvoMOGgO3vCiyh1IgoSr18ybrViLkhqMEGQlpsnjlJw0WHnonrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYYObXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzz0G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaKyIlZyXbtFQezoaZhFsjPsQddutp45zoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b1DyGkW8XnzeivTTaujRQh58OZXvM9A1(QmmQTLMeO2h41uBl)Q1c71cV3ZAfjj0TRfWO2zMUQ2xzVw4v7dCmQLgRfyIG1(aVMAjqETuZRvWZRw4v7CaTBUr7APXEgyzgloy6tLiZby(4tkjvsKWiYyQZU(YGe9ZCyxkfTkaCSNHnQMqJM01ZldscjKgO3vtOrt665LbPcWGytImhG5JRUeq0OZU(AqnjBdvbsYqF(cvoGm9avK5PncuGiO(YJut3MqcPGkhqMEGQdsIAa)GdnBiFQCaz6bQiZttYYObXb3w3ZqZgMezoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0durMNMKLrdIdUTUNH(YJK4YmwCW0NkrMdW8XNusQKiHrKXuND9Lbj6N5WUurMdW8XvCiyh1g5dgQazW2MOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vihIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYXenqVR4qWoQfnCyJQ5XcIKkhIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCLzS4GPpvImhG5JpPKuj1h4SreC)mh2LsLditpqvcCtiiQZUwK5amF8PjkMjWGg6GkQ5Gp4a1ZCqf9JqcNjWGg6GkdG5bmqngaghmDIlZETAB5Xd3EwlWeRfe5RHodhR9bEn1YgQAFL9AV8iRfoRnqgSDT8S2hCmmVwsMiS2jqG1EzTcEE1cVAPXEgyTxEKQYmwCW0NkrMdW8XNusQKar(AOZWrZHDPImhG5JRUeq0OZU(AqnjBdvbYGTnrd07koeSJArdh2OAESGOxKsLditpq1LhPMKLrlA4WgNMezoaZhxXHGDuBKpyOcKKH(8fP2cWYmwCW0NkrMdW8XNusQKar(AOZWrZHDPImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqoetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lRCmrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGmyBt0a9UIdb7Ow0WHnQMhlisQCiMyt0a9UkaCuNDTr(GHcmFCtKSZkdXjFPu5aY0duXgAsOdjbi1KSZAdXvM9A12cmXANgCquTWETxEK1YoyTSrTCG1METcWAzhS2N0FF1sJ1cyuBpJAhPBJrTxd71EnyTKSm1cIdUT51sYebD7ANabw7dwBdtfRLVAhipVAVNSwoeSJ1kA4WgN1YoyTxdF1E5rw7dp93xTTWaZRwGjcQkZyXbtFQezoaZhFsjPskyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0duftnjlJgehCBDpd9LhPjrMdW8XvCiyh1g5dgQajzOpLpvoGm9avXutYYObXb3w3ZqZgMO44b6NkaCuNDTr(GHjkezoaZhxfaoQZU2iFWqfijd95lOmOa4q9bjrcjuK5amFCva4Oo7AJ8bdvGKm0NYNkhqMEGQyQjzz0G4GBR7zOJ0GycjSvhpq)ubGJ6SRnYhmi2enqVR4qWoQfnCyJQ5XcIKVCnbI0a9U6sarJo76Rb1KSnubMpUjAGExfaoQZU2iFWqbMpUjAGExXHGDuBKpyOaZhVm71QTfyI1on4GOAFGxtTSrTpnOxRroNq6bQQ9v2R9YJSw4S2azW21YZAFWXW8AjzIWANabw7L1k45vl8QLg7zG1E5rQkZyXbtFQezoaZhFsjPskyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(8fuguaCO(GKOjAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSmArdh240KiZby(4koeSJAJ8bdvGKm0NVqbkdkaouFqsKsS4GPRUeq0OZU(AqnjBdvOmOa4q9bjrIlZyXbtFQezoaZhFsjPskyqi7NEAWbrMd7sfzoaZhxXHGDuBKpyOcKKH(8fuguaCO(GKOjkOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vihIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYXenqVR4qWoQfnCyJQ5XcIKkhIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCexMXIdM(ujYCaMp(KssLeWe1Wdjn3zsu6mbgd8oOBRda62Md7sPOvbGJ9mSr1eA0KUEEzqsiH0a9UAcnAsxpVmivageBIgO3vCiyh1IgoSr18ybrViLkhqMEGQlpsnjlJw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrzqbWH6dsIMizNvgIt(u5aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JxM9A12cmXAV8iR9bEn1Yg1c71cV3ZAFGxd0R9AWAjzzQfehCBvTVYETEEMxlWeR9bEn1gPrTWETxdw7Xd0VAHZApMi0nVw2bRfEVN1(aVgOx71G1sYYulio42QYmwCW0NkrMdW8XNusQKUeq0OZU(AqnjBdnh2LsrRcah7zyJQj0OjD98YGKqcPb6D1eA0KUEEzqQami2enqVR4qWoQfnCyJQ5XcIErkvoGm9avxEKAswgTOHdBCAsK5amFCfhc2rTr(GHkqsg6ZxKIYGcGd1hKenrYoRmeN8PYbKPhOIn0KqhscqQjzN1gIZenqVRcah1zxBKpyOaZhVmJfhm9PsK5amF8jLKkPlben6SRVgutY2qZHDP0a9UIdb7Ow0WHnQMhli6fPu5aY0duD5rQjzz0IgoSXPPJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsrzqbWH6dsIMOYbKPhO6GKOgWp4qZgYNkhqMEGQlpsnjlJgehCBDpdnBuMXIdM(ujYCaMp(KssL0LaIgD21xdQjzBO5WUuAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSmArdh240efT64b6NkaCuNDTr(GbHekYCaMpUkaCuNDTr(GHkqsg6t5tLditpq1LhPMKLrdIdUTUNHosdInrLditpq1bjrnGFWHMnKpvoGm9avxEKAswgnio426EgA2Om71QTfyI1Yg1c71E5rwlCwB61kaRLDWAFs)9vlnwlGrT9mQDKUng1EnSx71G1sYYulio42Mxljte0TRDceyTxdF1(G12WuXArpbSBQLKDUw2bR9A4R2RbdSw4SwpVA5rGmy7A5AdahRn71AKpyuly(4QYmwCW0NkrMdW8XNusQK4qWoQnYhmmh2LkYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSmAqCWT19m0xEKMOOvIKk6SFkQOFnTdcjuK5amFCfjmImM6SRVmir)ubsYqFkFQCaz6bQydnjlJgehCBDpdnzEeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYenqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCLzVwTTatS2inQf2R9YJSw4S20Rvawl7G1(K(7RwASwaJA7zu7iDBmQ9AyV2RbRLKLPwqCWTnVwsMiOBx7eiWAVgmWAHt)9vlpcKbBxlxBa4yTG5Jxl7G1En8vlBu7t6VVAPrrsI1Yuz4GPhyTGab0TRnaCuvMXIdM(ujYCaMp(KssLua4Oo7AJ8bdZHDP0a9UIdb7O2iFWqbMpUjkezoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0dufPHMKLrdIdUTUNH(YJKqcfzoaZhxXHGDuBKpyOcKKH(8fPu5aY0duD5rQjzz0G4GBR7zOzdInrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfezsK5amFCfhc2rTr(GHkqsg6t5lRCmjYCaMpU6sarJo76Rb1KSnufijd9P8LvoLzS4GPpvImhG5JpPKujnBG9d62AJ8bdZHDPu5aY0duLa3ecI6SRfzoaZhFwM9A12cmXAnsYAVS2zlgaXwqyTSxlkZfCTmDTqV2RbR1rzUAfzoaZhV2hOdMpMxlGpW5SwIAhq2R9AqV20hTRfeiGUDTCiyhR1iFWOwqaS2lRTjFQLKDU2ga3oAxBWGq2VANgCquTWzzgloy6tLiZby(4tkjvsgborxG6SRjHoO5WU0JhOFQaWrD21g5dgMOb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKLPmJfhm9PsK5amF8jLKkjJaNOlqD21Kqh0Cyxkisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFHfhmDfhc2rnjCoHdCQqzqbWH6dsIMALiPIo7NIO2bK9YmwCW0NkrMdW8XNusQKmcCIUa1zxtcDqZHDP0a9UkaCuNDTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKLXKiZby(4kKAk4dMUkqgSTjrMdW8XvxciA0zxFnOMKTHQajzOpn1krsfD2pfrTdi7LzLzS4GPpvDOZdnnq4s5qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMlAyOlv2YmwCW0NQo05HMgiCkjvsCiyh10dEELzS4GPpvDOZdnnq4usQK4qWoQP5iyBSmRm71QvYSb9Ada3HUDTi8AWO2RbR1YQ2mQLasM1oqB0b5aItZR9bR9H9R2lRvYGAwln2ZaR9AWAjqETuj1YVATpqhmFu12cmXAHxT8S2zMET8S2xF(Q12WZA7qhoBqWAtGO2h8nvS2Pb6xTjquROHdBCwMXIdM(u1HZgOBRtd0Xqksnf8bt3CyxkfbGJ9mSr1HKgzWd9dhgesifbGJ9mSr1eA0KUEEzqAQvu5aY0duzeObWyOrQPuzjMytuqd07QaWrD21g5dgkW8XjKqJaPQTfGkzvCiyh10CeSnsSjrMdW8XvbGJ6SRnYhmubsYqFwM9A1(k71(GVPI12HoC2GG1MarTImhG5Jx7d0bZNzTSdw70a9R2eiQv0WHnonVwJaMb8GTGWALmOM1MuXOwKkgTVgOBxloMyzgloy6tvhoBGUTonqhdkjvsi1uWhmDZHDPhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ttImhG5JR4qWoQnYhmubsYqFAIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnzeivTTaujRIdb7OMMJGTXYmwCW0NQoC2aDBDAGogusQK6Wa10dEEMd7sdah7zyJkq4uangqNJ2ArssYoOjAGExbcNcOXa6C0wlsss2b19iNNcWOmJfhm9PQdNnq3wNgOJbLKkPEKZt7jv2CyxAa4ypdBuzhW5OTgkGIbAIKDwzio53IOSYmwCW0NQoC2aDBDAGogusQK4qWoQjHZjCGtZHDPbGJ9mSrfhc2rDdhKP32enqVR4qWoQB4Gm92Q5XcIEHgO3vCiyh1nCqMEBfjlJEESGituqbnqVR4qWoQnYhmuG5JBsK5amFCfhc2rTr(GHkqgSnXesiisd07Qlben6SRVgutY2qfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusQKcah1zxBKpyyoSlnaCSNHnQMqJM01ZldYYmwCW0NQoC2aDBDAGogusQK4qWoQZG2CyxQiZby(4QaWrD21g5dgQazW2LzS4GPpvD4Sb6260aDmOKujXHGDutp45zoSlvK5amFCva4Oo7AJ8bdvGmyBt0a9UIdb7Ow0WHnQMhli6fAGExXHGDulA4WgvKSm65XcIkZyXbtFQ6Wzd0T1Pb6yqjPsce5RHodhnh2L2QaWXEg2O6qsJm4H(HddcjuKoia8u2W(PZU(Aq9akAkZyXbtFQ6Wzd0T1Pb6yqjPskaCuNDTr(Grz2Rv7RSx7d(oWA5RwswMANhliAwB2RT1TUw2bR9bRTHPI(7RwGjcwBlnjqTTXZ8AbMyTCTZJfev7L1Aeiv0VAjbCrd0TRfWh4CwBa4o0TR9AWABbJdY0Bx7aTrhKJ2LzS4GPpvD4Sb6260aDmOKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrMejv0z)uur)AAhMezoaZhxrcJiJPo76lds0pvGmyBtTIkhqMEGkK0iFWab10CeSnAsK5amFCfhc2rTr(GHkqgSDz2RvReZGKhJ21(G1AWWOwJ8GPxlWeR9bEn12YVQ51sdC1cVAFGJrTdEE1os3Uw0ta7MA7zulDEn1EnyTV(8vRLDWAB5xT2hOdMpZAb8boN1gaUdD7AVgSwlRAZOwcizw7aTrhKdiolZyXbtFQ6Wzd0T1Pb6yqjPsYipy6Md7sBva4ypdBuDiPrg8q)WHHjkAva4ypdBunHgnPRNxgKesifu5aY0duzeObWyOrQPuznrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermXLzS4GPpvD4Sb6260aDmOKujbI81qNHJMd7sPb6Dva4Oo7AJ8bdfy(4esOrGu12cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPskyqi7NEAWbrMd7sPb6Dva4Oo7AJ8bdfy(4esOrGu12cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPsIegrgtD21xgKOFMd7sPb6Dva4Oo7AJ8bdvGKm0NVqHKLsYTLeao2ZWgvtOrt665LbjXLzVwTsMnOxBa4o0TR9AWABbJdY0Bx7aTrhKJ2MxlWeRTLF1APXEgyTeiVwATxwliaPrTCTDGXODTZJfeHG1sZrW2yzgloy6tvhoBGUTonqhdkjvsCiyh1g5dgMd7sPYbKPhOcjnYhmqqnnhbBJMOb6Dva4Oo7AJ8bdfGHjkizNvgI7fkKlLrjkKvoTersfD2pfrTdi7etmHesd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrexMXIdM(u1HZgOBRtd0XGssLehc2rnnhbBJMd7sPYbKPhOcjnYhmqqnnhbBJMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcImrd07koeSJAJ8bdfGrzgloy6tvhoBGUTonqhdkjvsatudpK0CNjrPZeymW7GUToaOBBoSlLgO3vbGJ6SRnYhmuG5JtiHgbsvBlavYQ4qWoQP5iyBKqcncKQ2waQKvfmiK9tpn4GicjKcJaPQTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKujDjGOrND91GAs2gAoSlLgO3vbGJ6SRnYhmuG5JtiHgbsvBlavYQ4qWoQP5iyBKqcncKQ2waQKvfmiK9tpn4GicjKcJaPQTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKujXHGDuBKpyyoSl1iqQABbOsw1LaIgD21xdQjzByz2RvBlWeR9vZwATxw7SfdGyliSw2RfL5cU2woeSJ1kHbpVAbbcOBx71G1sG8APsQLF1AFGoy(ulGpW5S2aWDOBxBlhc2XALmenPQ2xzV2woeSJ1kziAYAHZApEG(HGMx7dwRG93xTatS2xnBP1(aVgOx71G1sG8APsQLF1AFGoy(ulGpW5S2hSwOFyeagxTxdwBl3sRv0WUJdZRDM1(GVhJANmvSw4PkZyXbtFQ6Wzd0T1Pb6yqjPsYiWj6cuNDnj0bnh2L2QJhOFkoeSJAu0KMarAGExDjGOrND91GAs2gQammbI0a9U6sarJo76Rb1KSnufijd95lsPGfhmDfhc2rn9GNNcLbfahQpij2sOb6DLrGt0fOo7AsOdQizz0ZJferCz2Rv7RSx7RMT0AB4P)(QLgrVwGjcwliqaD7AVgSwcKxlT2hOdMpMx7d(EmQfyI1cVAVS2zlgaXwqyTSxlkZfCTTCiyhRvcdEE1c9AVgS2xF(QsQLF1AFGoy(OkZyXbtFQ6Wzd0T1Pb6yqjPsYiWj6cuNDnj0bnh2Lsd07koeSJAJ8bdfGHjAGExfaoQZU2iFWqfijd95lsPGfhmDfhc2rn9GNNcLbfahQpij2sOb6DLrGt0fOo7AsOdQizz0ZJferCzgloy6tvhoBGUTonqhdkjvsCiyh10dEEMd7sbZtfmiK9tpn4GivGKm0NYNYiKqqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhlis(YPm71QvYeR9H9R2lRLKjcRDceyTpyTnmvSw0ta7MAjzNRTNrTxdwl6hmWAB5xT2hOdMpMxlsf9AH9AVgmW3ZANhCmQ9GKyTbsYqh621METV(8vv1(kV3ZAtF0UwA8omQ9YAPbcV2lRTfegzTSdwRKb1SwyV2aWDOBx71G1AzvBg1sajZAhOn6GCaXPQmJfhm9PQdNnq3wNgOJbLKkjoeSJAAoc2gnh2LkYCaMpUIdb7O2iFWqfid22ej7SYqCVqHKtouIczLtlrKurN9tru7aYoXeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYefTkaCSNHnQMqJM01ZldscjKkhqMEGkJanagdnsnLklXMAva4ypdBuDiPrg8q)WHHPwfao2ZWgvCiyh1nCqME7YSxRwjWrW2yTZMeyawRNxT0yTateSw(Q9AWArhS2SxBl)Q1c71kzqnf8btVw4S2azW21YZAbJ0Wa621kA4WgN1(ahJAjzIWAHxThtew7iDBmQ9YAPbcV2Rjsa7MAdKKHo0TRLKDUmJfhm9PQdNnq3wNgOJbLKkjoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqtImhG5JRqQPGpy6QajzOplZETALahbBJ1oBsGbyT84HBpRLgR9AWAh88QvWZRwOx71G1(6ZxT2hOdMp1YZAjqET0AFGJrTboVmWAVgSwrdh24S2Pb6xzgloy6tvhoBGUTonqhdkjvsCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlan1QaWXEg2OIdb7OUHdY0BxMXIdM(u1HZgOBRtd0XGssLehc2rnjCoHdCAoSlfePb6D1LaIgD21xdQjzBOcWW0Xd0pfhc2rnkAstuqd07kqKVg6mCubMpoHeYIdsf1OJKqCkvwInbI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkuguaCO(GKO5Igg6sL1CKJrBTOHHUg2Lsd07kXa5qWZd62Ard7oouG5JBIcAGExXHGDuBKpyOamiKqkA1Xd0pvsfdJ8bde0ef0a9UkaCuNDTr(GHcWGqcfzoaZhxHutbFW0vbYGTjMyIlZETAFL9AFW3bwlv0VM2H51cjjrqiF4ODTatS2w36AFAqVwbByGG1EzTEE1(WZdR1isXS2EKK12stcuMXIdM(u1HZgOBRtd0XGssLehc2rnjCoHdCAoSlvKurN9trf9RPDyIgO3vIbYHGNh0TvZJfejLgO3vIbYHGNh0TvKSm65XcIkZETATooUAbMq3U2w36AB5wATpnOxBl)Q12WZAPr0RfyIGLzS4GPpvD4Sb6260aDmOKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusQK4qWoQZG2CyxknqVR4qWoQfnCyJQ5XcIErkvoGm9avxEKAswgTOHdBCwMXIdM(u1HZgOBRtd0XGssLehc2rn9GNN5WUuAGExfaoQZU2iFWqbyqiHKSZkdXjFzPSYmwCW0NQoC2aDBDAGogusQKqQPGpy6Md7sPb6Dva4Oo7AJ8bdfy(4MOb6Dfhc2rTr(GHcmFCZH(HrayCAyxkj7SYqCYxQKNYmh6hgbGXPHKKiiKpuQSLzS4GPpvD4Sb6260aDmOKujXHGDutZrW2yzwz2R9A12c4tadJmoeSwb7cCOzXbtVf8QvYGAk4dMETpWXOwASwNpGGhJ21shjrOxlSxRiDq4btFwlhyTK4PkZETxRwwCW0NQgoitVTub7cCOzXbt3Cyxkloy6kKAk4dMUs0WUJdOBBIKDwzio5lTfrzLzVwTVYETJ8P20RLKDUw2bRvK5amF8zTCG1kssOBxlGH51AN1Ynidwl7G1IuZYmwCW0NQgoitVnLKkjKAk4dMU5WUus2zLH4Erkbjhtu5aY0duLa3ecI6SRfzoaZhFAIIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lYkhIlZETALmXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYkzRDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPsIdb7OMeoNWbonh2LsbvoGm9avZJfePB4Gm92es4bjXxKvoeBIgO3vCiyh1nCqMEB18ybrViRK1CrddDPYwM9A1kz2GETatOBxRKbPr7a5rTVobOZUanVwbpVA5A74tTOmxW1scNt4aN1(0ahyTpm8GUDT9mQ9AWAPb69A5R2RbRDECC1M9AVgS2o0U5kZyXbtFQA4Gm92usQK4qWoQjHZjCGtZHDPylgaAyGGkK0ODG8qNbOZUanDqs8fcsoMU02EGkrMdW8XNMezoaZhxHKgTdKh6maD2fOkqsg6t5lRKvYBQvS4GPRqsJ2bYdDgGo7cubcNm9ablZyXbtFQA4Gm92usQKaMOgEiP5otIsNjWyG3bDBDaq32CyxkvoGm9aviPr(GbcQP5iyB0KiZby(4Qlben6SRVgutY2qvGKm0NVifLbfahQpijAsK5amFCfhc2rTr(GHkqsg6ZxKsbkdkaouFqsSLixIlZyXbtFQA4Gm92usQKcgeY(PNgCqK5WUuQCaz6bQqsJ8bdeutZrW2OjrMdW8XvxciA0zxFnOMKTHQajzOpFrkkdkaouFqs0KiZby(4koeSJAJ8bdvGKm0NViLcuguaCO(GKylrUeBIIwHTyaOHbcQMjWyG3bDBDaq3MqcfPdcapfhc2rTrKGq72QGDIKVukJqcVa6eHNAMaJbEh0T1baDBLiZby(4QajzOpLVSYkhIlZyXbtFQA4Gm92usQKUeq0OZU(AqnjBdnh2LsLditpqvlmW80ateupn4GitImhG5JR4qWoQnYhmubsYqF(IuuguaCO(GKOjkAf2IbGggiOAMaJbEh0T1baDBcjuKoia8uCiyh1grccTBRc2js(sPmcj8cOteEQzcmg4Dq3wha0TvImhG5JRcKKH(u(YkRCiUmJfhm9PQHdY0BtjPsIdb7O2iFWWCyxQrGu12cqLSQlben6SRVgutY2WYmwCW0NQgoitVnLKkPaWrD21g5dgMd7sPYbKPhOcjnYhmqqnnhbBJMezoaZhxfmiK9tpn4GivGKm0NVifLbfahQpijAIkhqMEGQdsIAa)GdnBiFPYvoMOOvI0bbGNIdb7O2isqODBcjSvu5aY0duXJhU9upB7cTiZby(4tcjuK5amFC1LaIgD21xdQjzBOkqsg6ZxKsbkdkaouFqsSLixIjUmJfhm9PQHdY0BtjPskyqi7NEAWbrMd7sPYbKPhOcjnYhmqqnnhbBJMmcKQ2waQKvfaoQZU2iFWOmJfhm9PQHdY0BtjPs6sarJo76Rb1KSn0CyxkvoGm9avTWaZtdmrq90GdIm1kQCaz6bQAYbi0T1xEKLzVwTTatSw56G1YHGDSwAoc2gRf612YVkLE9VoVATPpAxlSxRegzcoaMxTSdwlF1oqEE1k3ABDRN1AePqGGLzS4GPpvnCqMEBkjvsCiyh10CeSnAoSlLgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYenqVRcah1zxBKpyOammrd07koeSJAJ8bdfGHjAGExXHGDu3Wbz6TvZJfejFPYkznrd07koeSJAJ8bdvGKm0NViLfhmDfhc2rnnhbBJkuguaCO(GKOjAGExrpYeCampfGrz2RvBlWeRvUoyTV(8vRf612YVATPpAxlSxRegzcoaMxTSdwRCRT1TEwRrKIYmwCW0NQgoitVnLKkPaWrD21g5dgMd7sPb6Dva4Oo7AJ8bdfy(4MOb6Df9itWbW8uagMOGkhqMEGQdsIAa)GdnBiFcsoesOiZby(4QGbHSF6PbhePcKKH(u(YkxInrbnqVR4qWoQB4Gm92Q5XcIKVuzPmcjKgO3vIbYHGNh0TvZJfejFPYsSjkALiDqa4P4qWoQnIeeA3MqcBfvoGm9av84HBp1Z2UqlYCaMp(K4YmwCW0NQgoitVnLKkPaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmFCtuqLditpq1bjrnGFWHMnKpbjhcjuK5amFCvWGq2p90GdIubsYqFkFzLlXMOOvI0bbGNIdb7O2isqODBcjSvu5aY0duXJhU9upB7cTiZby(4tIlZyXbtFQA4Gm92usQKcgeY(PNgCqK5WUuQCaz6bQqsJ8bdeutZrW2OjkOb6Dfhc2rTOHdBunpwqK8LkxcjuK5amFCfhc2rDg0QazW2eBIIwD8a9tfaoQZU2iFWGqcfzoaZhxfaoQZU2iFWqfijd9P8PmInrLditpqfopijFiOMn0ImhG5JlFPeKCmrrRePdcapfhc2rTrKGq72esyROYbKPhOIhpC7PE22fArMdW8XNexM9A1kz2GETbG7q3UwJibH2TnVwGjw7LhzT0TRfEtC0Rf61Mbig1EzT8aA71cVAFGxtTSrzgloy6tvdhKP3MssL0LaIgD21xdQjzBO5WUuQCaz6bQoijQb8do0SXluMCmrLditpq1bjrnGFWHMnKpbjhtu0kSfdanmqq1mbgd8oOBRda62esOiDqa4P4qWoQnIeeA3wfStK8LszexMXIdM(u1Wbz6TPKujXHGDuNbT5WUuQCaz6bQAHbMNgyIG6PbhezIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwquzgloy6tvdhKP3MssLehc2rnnhbBJMd7sbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKMkWWXGPHd41wrYYONhliQmJfhm9PQHdY0BtjPsIdb7OMEWZZCyxkvoGm9avTWaZtdmrq90GdIiKqkarAGExfmiK9tpn4GinvGHJbtdhWRTcWWeisd07QGbHSF6PbhePPcmCmyA4aETvZJfe9cisd07QGbHSF6PbhePPcmCmyA4aETvKSm65XcIiUm71QTfyI1scDyTsGJGTXAPX7brV2GbHSF1on4GOzTWETaoig1kbcU2h41KaxTG4GBdD7AF9miK9RwldoiQwiiYJr7YmwCW0NQgoitVnLKkjoeSJAAoc2gnh2Lsd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbMpUjAGExrpYeCampfGHjrMdW8Xvbdcz)0tdoisfijd95lsLvoMOb6Dfhc2rDdhKP3wnpwqK8LkRKTm71QTfyI1MbDTPxRaSwaFGZzTSrTWzTIKe621cyu7mtVmJfhm9PQHdY0BtjPsIdb7OodAZHDP0a9UIdb7Ow0WHnQMhli6fcYevoGm9avhKe1a(bhA2q(YkhtuiYCaMpU6sarJo76Rb1KSnufijd9P8PmcjSvI0bbGNIdb7O2isqODBIlZyXbtFQA4Gm92usQK4qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6Dfhc2rTr(GHcWWCrddDPYwM9A1(k71(G1AJxTg5dg1c9oWeMETGab0TRDamVAFW3JrTnmvSw0ta7MAB45H1EzT24vB271Y1oViD7AP5iyBSwqGa621EnyTrAij2O2hOdMpLzS4GPpvnCqMEBkjvsCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dva4Oo7AJ8bdvGKm0NViLfhmDfhc2rnjCoHdCQqzqbWH6dsIMOb6Dfhc2rTr(GHcWWenqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwqKjAGExXHGDu3Wbz6TvZJfezIgO3vg5dgAO3bMW0vagMOb6Df9itWbW8uagLzVwTVYETpyT24vRr(GrTqVdmHPxliqaD7AhaZR2h89yuBdtfRf9eWUP2gEEyTxwRnE1M9ETCTZls3UwAoc2gRfeiGUDTxdwBKgsInQ9b6G5J51oZAFW3JrTPpAxlWeRf9eWUPw6bpVzTqhEqEmAx7L1AJxTxwBpbIAfnCyJZYmwCW0NQgoitVnLKkjoeSJA6bppZHDP0a9UYiWj6cuNDnj0bvagMOGgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqeHe2kkOb6DLr(GHg6DGjmDfGHjAGExrpYeCampfGbXexM9A1sGgSwACE1cmXAZETgjzTWzTxwlWeRfE1EzTTyaOGOr7APbGdWAfnCyJZAbbcOBxlBul3pmQ9AW21AJxTGaKgiyT0TR9AWAB4Gm921sZrW2yzgloy6tvdhKP3MssLKrGt0fOo7AsOdAoSlLgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqKjAGExXHGDuBKpyOamkZETALmXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYkzRDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPsIdb7OMeoNWbonh2Lsd07koeSJ6goitVTAESGOxKvYAUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwMXIdM(u1Wbz6TPKujXHGDutZrW2O5WUuAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGitu5aY0duHKg5dgiOMMJGTXYmwCW0NQgoitVnLKkjKAk4dMU5WUus2zLH4ErwkRm71Q91XhTRfyI1sp45v7L1sdahG1kA4WgN1c71(G1YJazW212WuXANjjwBpsYAZGUmJfhm9PQHdY0BtjPsIdb7OMEWZZCyxknqVR4qWoQfnCyJQ5XcImrd07koeSJArdh2OAESGOxOb6Dfhc2rTOHdBurYYONhliQm71Q91vWXO2h41ultwlGpW5Sw2Ow4SwrscD7AbmQLDWAFW3bw7iFQn9AjzNlZyXbtFQA4Gm92usQK4qWoQjHZjCGtZHDPTIcQCaz6bQoijQb8do0SXlsLvoMizNvgI7fcsoeBUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwM9A1(Qr2HdCw7d8AQDKp1sYZdJ2MxBd0UP2gEEO51MrT051ulj3UwpVAByQyTONa2n1sYox7L1obmmY4QTjFQLKDUwOFOpHuXAdgeY(v70GdIQvWET0O51oZAFW3JrTatS2omWAPh88QLDWA7rop6CC1(0GETJ8P20RLKDUmJfhm9PQHdY0BtjPsQddutp45vMXIdM(u1Wbz6TPKuj1JCE054kZkZyXbtFQsd0XqAhgOMEWZZCyxAa4ypdBubcNcOXa6C0wlsss2bnrd07kq4uangqNJ2ArssYoOUh58uagLzS4GPpvPb6yqjPsQh580EsLnh2Lgao2ZWgv2bCoARHcOyGMizNvgIt(TikRmJfhm9PknqhdkjvsatudpK0CNjrPZeymW7GUToaOBxMXIdM(uLgOJbLKkjqKVg6mCSmJfhm9Pknqhdkjvsbdcz)0tdoiYCyxkj7SYqCYxYjNYmwCW0NQ0aDmOKujrcJiJPo76lds0VYmwCW0NQ0aDmOKujnBG9d62AJ8bdZHDP0a9UIdb7O2iFWqbMpUjrMdW8XvCiyh1g5dgQajzOplZyXbtFQsd0XGssLehc2rDg0Md7sfzoaZhxXHGDuBKpyOcKbBBIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwquzgloy6tvAGogusQK4qWoQPh88mh2LksQOZ(POI(10omjYCaMpUIegrgtD21xgKOFQajzOpLVKxYvMXIdM(uLgOJbLKkPlben6SRVgutY2WYmwCW0NQ0aDmOKujXHGDuBKpyuMXIdM(uLgOJbLKkPaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmF8YSxR2wGjw7RMT0AVS2zlgaXwqyTSxlkZfCTTCiyhRvcdEE1cceq3U2RbRLa51sLul)Q1(aDW8PwaFGZzTbG7q3U2woeSJ1kziAsvTVYETTCiyhRvYq0K1cN1E8a9dbnV2hSwb7VVAbMyTVA2sR9bEnqV2RbRLa51sLul)Q1(aDW8PwaFGZzTpyTq)WiamUAVgS2wULwROHDhhMx7mR9bFpg1ozQyTWtvMXIdM(uLgOJbLKkjJaNOlqD21Kqh0CyxARoEG(P4qWoQrrtAcePb6D1LaIgD21xdQjzBOcWWeisd07Qlben6SRVgutY2qvGKm0NViLcwCW0vCiyh10dEEkuguaCO(GKylHgO3vgborxG6SRjHoOIKLrppwqeXLzVwTVYETVA2sRTHN(7RwAe9AbMiyTGab0TR9AWAjqET0AFGoy(yETp47XOwGjwl8Q9YANTyaeBbH1YETOmxW12YHGDSwjm45vl0R9AWAF95RkPw(vR9b6G5JQmJfhm9PknqhdkjvsgborxG6SRjHoO5WUuAGExXHGDuBKpyOammrd07QaWrD21g5dgQajzOpFrkfS4GPR4qWoQPh88uOmOa4q9bjXwcnqVRmcCIUa1zxtcDqfjlJEESGiIlZyXbtFQsd0XGssLehc2rn9GNN5WUuW8ubdcz)0tdoisfijd9P8PmcjeePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIKVCkZETAB5Xd3EwRe4iyBSw(Q9AWArhS2SxBl)Q1(0GETbG7q3U2RbRTLdb7yTTGXbz6TRDG2OdYr7YmwCW0NQ0aDmOKujXHGDutZrW2O5WUuAGExXHGDuBKpyOammrd07koeSJAJ8bdvGKm0NVylanfao2ZWgvCiyh1nCqME7YSxR2wE8WTN1kboc2gRLVAVgSw0bRn71EnyTV(8vR9b6G5tTpnOxBa4o0TR9AWAB5qWowBlyCqME7AhOn6GC0UmJfhm9PknqhdkjvsCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlanfao2ZWgvCiyh1nCqME7YmwCW0NQ0aDmOKujXHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gurn6ijeNsLLytGinqVRUeq0OZU(AqnjBdvbsYqFkFwCW0vCiyh1KW5eoWPcLbfahQpijAUOHHUuznh5y0wlAyORHDP0a9Usmqoe88GUTw0WUJdfy(4MOGgO3vCiyh1g5dgkadcjKIwD8a9tLuXWiFWabnrbnqVRcah1zxBKpyOamiKqrMdW8Xvi1uWhmDvGmyBIjM4YmwCW0NQ0aDmOKujXHGDutcNt4aNMd7sPb6DLyGCi45bDB18ybrsPb6DLyGCi45bDBfjlJEESGitIKk6SFkQOFnTJYmwCW0NQ0aDmOKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQ0aDmOKujXHGDuNbT5WUuAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSmArdh24SmJfhm9PknqhdkjvsCiyh10dEEMd7sPb6Dva4Oo7AJ8bdfGbHesYoRmeN8LLYkZyXbtFQsd0XGssLesnf8bt3CyxknqVRcah1zxBKpyOaZh3enqVR4qWoQnYhmuG5JBo0pmcaJtd7sjzNvgIt(sL8uM5q)WiamonKKebH8HsLTmJfhm9PknqhdkjvsCiyh10CeSnwMvM9AVwTS4GPpvrE8btxQGDbo0S4GPBoSlLfhmDfsnf8btxjAy3Xb0TnrYoRmeN8L2IOmtu0QaWXEg2OAcnAsxpVmijKqAGExnHgnPRNxgKQ5XcIKsd07Qj0OjD98YGurYYONhliI4YSxR2wGjwlsnRf2R9bFhyTJ8P20RLKDUw2bRvK5amF8zTCG1Y0jWv7L1sJ1cyuMXIdM(uf5XhmDkjvsi1uWhmDZHDPTkaCSNHnQMqJM01ZldstKSZkdX9IuQCaz6bQqQP2qCMOqK5amFC1LaIgD21xdQjzBOkqsg6ZxKYIdMUcPMc(GPRqzqbWH6dsIesOiZby(4koeSJAJ8bdvGKm0NViLfhmDfsnf8btxHYGcGd1hKejKqkoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NViLfhmDfsnf8btxHYGcGd1hKejMyt0a9UkaCuNDTr(GHcmFCt0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kJaPQTfGkzvxciA0zxFnOMKTHLzS4GPpvrE8btNssLesnf8bt3CyxAa4ypdBunHgnPRNxgKMALiPIo7NIk6xt7WKiZby(4koeSJAJ8bdvGKm0NViLfhmDfsnf8btxHYGcGd1hKelZyXbtFQI84dMoLKkjKAk4dMU5WU0aWXEg2OAcnAsxpVminjsQOZ(POI(10omjYCaMpUIegrgtD21xgKOFQajzOpFrkloy6kKAk4dMUcLbfahQpijAsK5amFC1LaIgD21xdQjzBOkqsg6ZxKsbvoGm9avK5PncuGiO(YJut3MsS4GPRqQPGpy6kuguaCO(GKiLiiInjYCaMpUIdb7O2iFWqfijd95lsPGkhqMEGkY80gbkqeuF5rQPBtjwCW0vi1uWhmDfkdkaouFqsKseeXLzVwTsGJGTXAH9AH37zThKeR9YAbMyTxEK1YoyTpyTnmvS2lZAjzVDTIgoSXzzgloy6tvKhFW0PKujXHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYNkhqMEGQlpsnjlJw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrzqbWH6dsIMizNvgIt(u5aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JtCzgloy6tvKhFW0PKujXHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYNkhqMEGQlpsnjlJw0WHnonD8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrkkdkaouFqs0evoGm9avhKe1a(bhA2q(u5aY0duD5rQjzz0G4GBR7zOzdIlZyXbtFQI84dMoLKkjoeSJAAoc2gnh2LkYCaMpU6sarJo76Rb1KSnufid22ef0a9UIdb7Ow0WHnQMhlis(u5aY0duD5rQjzz0IgoSXPjkA1Xd0pva4Oo7AJ8bdcjuK5amFCva4Oo7AJ8bdvGKm0NYNkhqMEGQlpsnjlJgehCBDpdDKgeBIkhqMEGQdsIAa)GdnBiFQCaz6bQU8i1KSmAqCWT19m0SbXLzS4GPpvrE8btNssLehc2rnnhbBJMd7sbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKMkWWXGPHd41wrYYONhliYef0a9UIdb7O2iFWqbMpoHesd07koeSJAJ8bdvGKm0NVi1wasSjkOb6Dva4Oo7AJ8bdfy(4esinqVRcah1zxBKpyOcKKH(8fP2cqIlZyXbtFQI84dMoLKkjoeSJA6bppZHDPu5aY0du1cdmpnWeb1tdoiIqcPaePb6DvWGq2p90GdI0ubgogmnCaV2kadtGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwq0lGinqVRcgeY(PNgCqKMkWWXGPHd41wrYYONhliI4YmwCW0NQip(GPtjPsIdb7OMEWZZCyxknqVRmcCIUa1zxtcDqfGHjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF(IuwCW0vCiyh10dEEkuguaCO(GKyzgloy6tvKhFW0PKujXHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gurn6ijeNsLLytuaI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkuguaCO(GKiHekYCaMpUYiWj6cuNDnj0bvbsYqFsiHIKk6SFkIAhq2j2CrddDPYAoYXOTw0Wqxd7sPb6DLyGCi45bDBTOHDhhkW8XnrbnqVR4qWoQnYhmuagesifT64b6NkPIHr(GbcAIcAGExfaoQZU2iFWqbyqiHImhG5JRqQPGpy6QazW2etmXLzVwTTo9jajw71G1IYyWoicwRrEOFqEulnqVxlpzJAVSwpVAh5eR1ip0pipQ1isXSmJfhm9PkYJpy6usQK4qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6DfkJb7GiO2ip0pipuagLzS4GPpvrE8btNssLehc2rnjCoHdCAoSlLgO3vIbYHGNh0TvbYIZef0a9UIdb7O2iFWqbyqiH0a9UkaCuNDTr(GHcWGqcbrAGExDjGOrND91GAs2gQcKKH(u(S4GPR4qWoQjHZjCGtfkdkaouFqsKyZfnm0LkBzgloy6tvKhFW0PKujXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrMlAyOlv2YSxR2wE8WTN1Er7AVSwA2jQ2w36A7zuRiZby(41(aDW8zwlnWvliaPrTxdswlSx71GTFhyTmDcC1EzTOmgWalZyXbtFQI84dMoLKkjoeSJAs4Cch40CyxknqVRedKdbppOBRcKfNjAGExjgihcEEq3wfijd95lsPGcAGExjgihcEEq3wnpwqulHfhmDfhc2rnjCoHdCQqzqbWH6dsIetjBbOIKLHyZfnm0LkBzgloy6tvKhFW0PKuj541GH(qsdCEMd7sPiWEGZgMEGesyRoOGiOBtSjAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGit0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFQI84dMoLKkjoeSJ6mOnh2Lsd07koeSJArdh2OAESGOxKsLditpq1LhPMKLrlA4WgNLzS4GPpvrE8btNssL0eWadpPYMd7sPYbKPhOkbUjee1zxlYCaMp(0ej7SYqCViTfrzLzS4GPpvrE8btNssLehc2rn9GNN5WUuAGExfaduND91eiovagMOb6Dfhc2rTOHdBunpwqK8jOYSxR2xxainQv0WHnoRf2R9bRTZJrT04iFQ9AWAfPpXGkwlj7CTxtGZMCawl7G1IutbFW0RfoRDEWXO20RvK5amF8YmwCW0NQip(GPtjPsIdb7OMMJGTrZHDPTkaCSNHnQMqJM01Zldstu5aY0duLa3ecI6SRfzoaZhFAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliY0Xd0pfhc2rDg0MezoaZhxXHGDuNbTkqsg6ZxKAlanrYoRme3lsBrYXKiZby(4kKAk4dMUkqsg6ZYmwCW0NQip(GPtjPsIdb7OMMJGTrZHDPbGJ9mSr1eA0KUEEzqAIkhqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAlsoMezoaZhxHutbFW0vbsYqF(cbjNYSxR2xxainQv0WHnoRf2Rnd6AHZAdKbBxMXIdM(uf5XhmDkjvsCiyh10CeSnAoSlLkhqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAlsoMezoaZhxHutbFW0vbsYqFAIIwfao2ZWgvtOrt665LbjHesd07Qj0OjD98YGufijd95lsLvYtCz2RvBlhc2XALahbBJ1oBsGbyT2OJbpgTRLgR9AWAh88QvWZR2Sx71G12YVATpqhmFkZyXbtFQI84dMoLKkjoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMOqK5amFCfsnf8btxfijd9jHegao2ZWgvCiyh1nCqMEBIlZETAB5qWowRe4iyBS2ztcmaR1gDm4XODT0yTxdw7GNxTcEE1M9AVgS2xF(Q1(aDW8PmJfhm9PkYJpy6usQK4qWoQP5iyB0CyxknqVRcah1zxBKpyOammrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdvGKm0NVi1waAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYefImhG5JRqQPGpy6QajzOpjKWaWXEg2OIdb7OUHdY0BtCz2RvBlhc2XALahbBJ1oBsGbyT0yTxdw7GNxTcEE1M9AVgSwcKxlT2hOdMp1c71cVAHZA98QfyIG1(aVMAF95RwBg12YVAzgloy6tvKhFW0PKujXHGDutZrW2O5WUuAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFrQTa0enqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwquz2RvRKzd61EnyThh24vlCwl0RfLbfahwBWUnwl7G1EnyG1cN1sMbw71WETPJ1Ios228AbMyT0CeSnwlpRDMPxlpRTDcuBdtfRf9eWUPwrdh24S2lRTbE1YJrTOJKqCwlSx71G12YHGDSwjKK0CasI(v7aTrhKJ21cN1ITyaOHbcwMXIdM(uf5XhmDkjvsCiyh10CeSnAoSlLkhqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrYxkfS4Gurn6ijeNTqYsSjwCqQOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKkjoeSJAugJroHPBoSlLkhqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqKjwCqQOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKkjoeSJA6bpVYmwCW0NQip(GPtjPscPMc(GPBoSlLkhqMEGQe4MqquNDTiZby(4ZYmwCW0NQip(GPtjPsIdb7OMMJGTXVfdCnz8TSGKad(GP36G73)(3)da]] )

    
end