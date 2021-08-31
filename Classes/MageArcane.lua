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
            max_stack = function ()
                return 1 + ( level > 31 and 2 or 0 ) + ( pvptalent.arcane_empowerment.enabled and 2 or 0 )
            end,
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

                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
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

                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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

            tick = function ()
                if legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 1 ) end
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
            end,

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
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
                applyDebuff( "target", "touch_of_the_magi" )
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
                -- applyDebuff( "target", "radiant_spark_vulnerability" )
                -- RSV doesn't apply until the next hit.
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


    spec:RegisterPack( "Arcane", 20210831, [[devxEhqivj6rQsIlPkPQWMOiFsvQrHeDkKWQKsu9kekZIIQBjLqSls(frOHruXXikwgrvEgcKPrukUgcv2grPY3uLKmoPe4CsjO1HqvVtvsvrMNus3djTpIQ6GsjYcjcEOQeMirPk5IeLs2OQKQs(OQKQQrsuQsDsvjvwjfLxQkPQuZebQBkLOStIs(PQKQmuvjLLQkj1tPKPIaUkrPQ2QQKQI6ReLsnwIkTxv1Fj1Gv6WOwms9yctgOldTzP6ZuQrlfNg0QLsi9AeYSv0Tr0UP63IgofoUuc1YfEUctxLRdy7ePVRkgpr05LsTEIsvmFe0(L8xMpb(wG8HFzjp5ipzKtlGGKrjNwGSPfkZR6BDTnWVLbliITXVLZK43QLcb743YGBptg8tGV1ibcb(TAUZyq8suI2WRbGwjssjoGKat(GPlcUFsCajfs8BrdaN3RZ)0Flq(WVSKNCKNmYPfqqYOKtlq20cLr28TggO4llzN8(wnqqq0)0FlqCi(wTm2gRTLcb7yzwlbydmUAjizmVw5jh5jtzwz2lAy3gheFzwlsTY(dS2RTbuWZATGKVO2g2bNq3U2SxROHDhN1c9dJaW4GPxl0hhYG1M9AFlyxGtnloy6VvLzTi1(Ig2TXA5qWoQHEh6WRDTxwlhc2rDdhKP3UwkHxTokfJAFq)QDcLI1YJA5qWoQB4Gm92uOkZArQv2R0FF1kBjnf8H1c9ABPxpzRABrbgxT0OGbgyTTtG3bwBcC1M9Ad2TXAzhSwpVAbgq3U2wkeSJ1kBjPXmhW0vLzTi12sGTOaJRwJaMb8Ax7L1cmWABPqWow7RLpy8Eul27O4GsXAfzobZhVwAEGG1METVq2RxDTyVJIBO(wt44gFc8TA4Gm92Fc8LLmFc8TqNPNi4xcFlwCW0)wO0uWhm9Vfioeb04GP)TED9AN5tTPxlj7CTSdwRiZjy(4JA5aRvKKq3UwadZR1oRLBqgSw2bRfLMFlrapmG83IKDwziUABLATeKCQ1uTs5aY0tuLa3acI6SRfzobZhFuRPAPS2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxfaoQZU2iFWqfijd9rTTwRmYPwk(3xwY7tGVf6m9eb)s4BbIdranoy6FlzBS2h2VAVS2XXcIQTHdY0BxBhyoBRQLanyTadS2SxRmYUAhhliAuBdgyTWrTxwllejGF12ZO2RbR9GcIQDI9R20R9AWAfnS74Sw2bR9AWAjHJbCI1c9A7tODZP(wIaEya5VfL1kLditpr14ybr6goitVDTesyThKeRT1ALro1srTMQLgO3vCiyh1nCqMEB14ybr12ATYi7(wIgg6Flz(wS4GP)T4qWoQjHJbCIJ)9Lfb9jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlqCicOXbt)BjB3GETadOBxRSfPr7a5zTVEbOZUanVwbpUA5A74tTOKxW1schd4eh1(0aNyTpm8GUDT9mQ9AWAPb69A5R2RbRDCCC1M9AVgS2o0U5(wIaEya5Vf2IbGggiOcjnAhip1za6SlWAnv7bjXABTwcso1AQ2lTTNOsK5emF8rTMQvK5emFCfsA0oqEQZa0zxGQajzOpQv(1kJSRfuRPAFzTS4GPRqsJ2bYtDgGo7cubchm9eb)3xwYMpb(wOZ0te8lHVfloy6FRrcmN4Dq3wha0T)wIaEya5VfnqVR4qWoQnYhmuag1AQ2JdB8uGWXXUaRTvQ1kJC(wotIFRrcmN4Dq3wha0T)3xwe3NaFl0z6jc(LW3Ifhm9V1ibMt8oOBRda62FlrapmG83skhqMEIkK0iFWab10CeSnwRPAfzobZhxDjGOrND91GAs2gQcKKH(O2wPwlkjkaouFqsSwt1kYCcMpUIdb7O2iFWqfijd9rTTsTwkRfLefahQpijwBlVw5vlf1AQ2JdB8uGWXXUaRv(1kJC(wotIFRrcmN4Dq3wha0T)3xwYUpb(wOZ0te8lHVLiGhgq(BjLditprfsAKpyGGAAoc2gR1uTImNG5JRUeq0OZU(AqnjBdvbsYqFuBRuRfLefahQpijwRPAfzobZhxXHGDuBKpyOcKKH(O2wPwlL1IsIcGd1hKeRTLxR8QLIAnvlL1(YAXwma0WabvJeyoX7GUToaOBxlHewRiDqa4P4qWoQnIeeA3wfStuTYNATexTesyTuwRiZjy(4QrcmN4Dq3wha0TvbsYqFuR8RvgzKtTMQ94WgpfiCCSlWALFTYiNAPOwcjSwkRvK5emFC1ibMt8oOBRda62QajzOpQTvQ1IsIcGd1hKeR1uThh24PaHJJDbwBRuRvg5ulf1sX3Ifhm9VvWGq2p9WGdI(3xwVQpb(wOZ0te8lHVLiGhgq(BjLditprvlkW40adeupm4GOAnvRiZjy(4koeSJAJ8bdvGKm0h12k1ArjrbWH6dsI1AQwkR9L1ITyaOHbcQgjWCI3bDBDaq3UwcjSwr6GaWtXHGDuBeji0UTkyNOALp1AjUAjKWAPSwrMtW8XvJeyoX7GUToaOBRcKKH(Ow5xRmYiNAnv7XHnEkq44yxG1k)ALro1srTesyTuwRiZjy(4QrcmN4Dq3wha0TvbsYqFuBRuRfLefahQpijwRPApoSXtbchh7cS2wPwRmYPwkQLIVfloy6FRlben6SRVgutY2W)9Lvl4tGVf6m9eb)s4Bjc4HbK)wgbkvBlavYOUeq0OZU(AqnjBd)wS4GP)T4qWoQnYhm(3xwTWpb(wOZ0te8lHVLiGhgq(BjLditprfsAKpyGGAAoc2gR1uTImNG5JRcgeY(PhgCqKkqsg6JABLATOKOa4q9bjXAnvRuoGm9evhKe1a(bNA2Ow5tTw5jNAnvlL1(YAfPdcapfhc2rTrKGq72k0z6jcwlHew7lRvkhqMEIkE(WTh6rBxOfzobZhFulHewRiZjy(4Qlben6SRVgutY2qvGKm0h12k1APSwusuaCO(GKyTT8ALxTuulfFlwCW0)wbGJ6SRnYhm(3xwYiNpb(wOZ0te8lHVLiGhgq(BjLditprfsAKpyGGAAoc2gR1uTgbkvBlavYOcah1zxBKpy8TyXbt)BfmiK9tpm4GO)9LLmY8jW3cDMEIGFj8Teb8WaYFlPCaz6jQArbgNgyGG6HbhevRPAFzTs5aY0tu1KtqOBRV8i)wS4GP)TUeq0OZU(AqnjBd)3xwYiVpb(wOZ0te8lHVfloy6FloeSJAAoc2g)wG4qeqJdM(3s2FG1kphSwoeSJ1sZrW2yTqV2w61i2R(171Qn9z7AH9ALWmtWjW4QLDWA5R2jYJRw5v7lEXOwJifce8Bjc4HbK)w0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTMQLgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOamQ1uT0a9UIdb7OUHdY0BRghliQw5tTwzKD1AQwAGExXHGDuBKpyOcKKH(O2wPwlloy6koeSJAAoc2gvOKOa4q9bjXAnvlnqVRONzcobgNcW4FFzjdb9jW3cDMEIGFj8TyXbt)BfaoQZU2iFW4BbIdranoy6Flz)bwR8CWAF15Rvl0RTLETAtF2UwyVwjmZeCcmUAzhSw5v7lEXOwJifFlrapmG83IgO3vbGJ6SRnYhmuG5JxRPAPb6Df9mtWjW4uag1AQwkRvkhqMEIQdsIAa)GtnBuR8RLGKtTesyTImNG5JRcgeY(PhgCqKkqsg6JALFTYiVAPOwt1szT0a9UIdb7OUHdY0BRghliQw5tTwziUAjKWAPb6DLyICi4XbDB14ybr1kFQ1ktTuuRPAPS2xwRiDqa4P4qWoQnIeeA3wHotprWAjKWAFzTs5aY0tuXZhU9qpA7cTiZjy(4JAP4FFzjJS5tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLYALYbKPNO6GKOgWp4uZg1k)Aji5ulHewRiZjy(4QGbHSF6HbhePcKKH(Ow5xRmYRwkQ1uTuw7lRvKoia8uCiyh1grccTBRqNPNiyTesyTVSwPCaz6jQ45d3EOhTDHwK5emF8rTu8TyXbt)BfaoQZU2iFW4FFzjdX9jW3cDMEIGFj8Teb8WaYFlPCaz6jQqsJ8bdeutZrW2yTMQLYAPb6Dfhc2rTOHdBunowquTYNATYRwcjSwrMtW8XvCiyh1zqRcKbBxlf1AQwkR9L1E8e9tfaoQZU2iFWqHotprWAjKWAfzobZhxfaoQZU2iFWqfijd9rTYVwIRwkQ1uTImNG5JR4qWoQnYhmubsYqFOrjnqXHG1kFQ1sqYPwt1szTVSwr6GaWtXHGDuBeji0UTcDMEIG1siH1(YALYbKPNOINpC7HE02fArMtW8Xh1sX3Ifhm9VvWGq2p9WGdI(3xwYi7(e4BHotprWVe(wS4GP)TUeq0OZU(AqnjBd)wG4qeqJdM(3s2Ub9Ada3HUDTgrccTBBETadS2lpYAPBxl8g4Sxl0RndqmQ9YA5j02RfE1(aVMAzJVLiGhgq(BjLditpr1bjrnGFWPMnQT1Ajo5uRPALYbKPNO6GKOgWp4uZg1k)Aji5uRPAPS2xwl2IbGggiOAKaZjEh0T1baD7AjKWAfPdcapfhc2rTrKGq72QGDIQv(uRL4QLI)9LLmVQpb(wOZ0te8lHVLiGhgq(BjLditprvlkW40adeupm4GOAnvlnqVR4qWoQfnCyJQXXcIQT1APb6Dfhc2rTOHdBurYsQhhli6BXIdM(3Idb7Ood6)9LLmTGpb(wOZ0te8lHVLiGhgq(BbI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1sTwqKgO3vbdcz)0ddoislfy6yW0Wj8ARizj1JJfe9TyXbt)BXHGDutZrW24)(YsMw4NaFl0z6jc(LW3seWddi)TKYbKPNOQffyCAGbcQhgCquTesyTuwlisd07QGbHSF6HbhePLcmDmyA4eETvag1AQwqKgO3vbdcz)0ddoislfy6yW0Wj8ARghliQ2wRfePb6DvWGq2p9WGdI0sbMogmnCcV2ksws94ybr1sX3Ifhm9Vfhc2rn9Kh3)(YsEY5tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TK9hyTKqhwRe4iyBSwA8Eq0Rnyqi7xTddoiAulSxlGdIrTsGGR9bEnjWvlio52q3U2xndcz)Q1YGdIQfcI8C2(Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07koeSJAJ8bdfy(41AQwAGExrpZeCcmofGrTMQvK5emFCvWGq2p9WGdIubsYqFuBRuRvg5uRPAPb6Dfhc2rDdhKP3wnowquTYNATYi7(3xwYtMpb(wOZ0te8lHVfloy6FloeSJ6mO)wG4qeqJdM(3s2FG1MbDTPxRaSwaFIJrTSrTWrTIKe621cyu7it)Bjc4HbK)w0a9UIdb7Ow0WHnQghliQ2wRLGQ1uTs5aY0tuDqsud4hCQzJALFTYiNAnvlL1kYCcMpU6sarJo76Rb1KSnufijd9rTYVwIRwcjS2xwRiDqa4P4qWoQnIeeA3wHotprWAP4FFzjp59jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlrdd9VLmFlrapmG83IgO3vIjYHGhh0TvbYIRwt1sd07koeSJAJ8bdfGX)(YsEe0NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)B9661(G1AJxTg5dg1c9oWaMETGab0TRDcmUAFW3ZzTnSuSw0ta7MAB4XH1EzT24vB271Y1oUiD7AP5iyBSwqGa621EnyTrAir2O2hOdMpFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExfaoQZU2iFWqfijd9rTTsTwwCW0vCiyh1KWXaoXHcLefahQpijwRPAPb6Dfhc2rTr(GHcWOwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr1AQwAGExXHGDu3Wbz6TvJJfevRPAPb6DLr(GHg6DGbmDfGrTMQLgO3v0ZmbNaJtby8VVSKNS5tGVf6m9eb)s4BXIdM(3Idb7OMEYJ7BbIdranoy6FRxxV2hSwB8Q1iFWOwO3bgW0RfeiGUDTtGXv7d(EoRTHLI1IEcy3uBdpoS2lR1gVAZEVwU2XfPBxlnhbBJ1cceq3U2RbRnsdjYg1(aDW8X8AhzTp475S20NTRfyG1IEcy3ul9Kh3OwOdpipNTR9YATXR2lRTNarTIgoSXX3seWddi)TOb6DLrGd0fOo7AsOdQamQ1uTuwlnqVR4qWoQfnCyJQXXcIQT1APb6Dfhc2rTOHdBurYsQhhliQwcjS2xwlL1sd07kJ8bdn07ady6kaJAnvlnqVRONzcobgNcWOwkQLI)9LL8iUpb(wOZ0te8lHVfloy6FlJahOlqD21Kqh8BbIdranoy6Flc0G1sJJRwGbwB2R1ijRfoQ9YAbgyTWR2lRTfdafenBxlnaCcwROHdBCuliqaD7AzJA5(HrTxd2UwB8QfeG0abRLUDTxdwBdhKP3UwAoc2g)wIaEya5VfnqVR4qWoQfnCyJQXXcIQT1APb6Dfhc2rTOHdBurYsQhhliQwt1sd07koeSJAJ8bdfGX)(YsEYUpb(wOZ0te8lHVfioeb04GP)TKTXAFy)Q9YAhhliQ2goitVDTDG5STQwc0G1cmWAZETYi7QDCSGOrTnyG1ch1EzTSqKa(vBpJAVgS2dkiQ2j2VAtV2RbRv0WUJZAzhS2RbRLeogWjwl0RTpH2nN6BXIdM(3Idb7OMeogWjo(wq)WiamUVLmFlrdd9VLmFlrapmG83IgO3vCiyh1nCqMEB14ybr12ATYi7(wq)WiamoT9mP553sM)9LL8EvFc8TqNPNi4xcFlrapmG83IgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQ1uTs5aY0tuHKg5dgiOMMJGTXVfloy6FloeSJAAoc2g)3xwYRf8jW3cDMEIGFj8Teb8WaYFls2zLH4QT1ALH4(wS4GP)TqPPGpy6)7ll51c)e4BHotprWVe(wS4GP)T4qWoQPN84(wG4qeqJdM(361ZNTRfyG1sp5Xv7L1sdaNG1kA4Wgh1c71(G1YZazW212WsXAhjjwBpsYAZG(Bjc4HbK)w0a9UIdb7Ow0WHnQghliQwt1sd07koeSJArdh2OACSGOABTwAGExXHGDulA4WgvKSK6XXcI(3xweKC(e4BHotprWVe(wG4qeqJdM(361xW5S2h41ultwlGpXXOw2Ow4OwrscD7AbmQLDWAFW3bw7mFQn9AjzN)wS4GP)T4qWoQjHJbCIJVf0pmcaJ7BjZ3s0Wq)BjZ3seWddi)TEzTuwRuoGm9evhKe1a(bNA2O2wPwRmYPwt1sYoRmexTTwlbjNAP4Bb9dJaW402ZKMNFlz(3xweKmFc8TqNPNi4xcFlqCicOXbt)B9Ar2HtCu7d8AQDMp1sYJdJ2MxBd0UP2gECO51MrT051ulj3UwpVAByPyTONa2n1sYox7L1oammY4QTjFQLKDUwOFOpGsXAdgeY(v7WGdIQvWET0O51oYAFW3ZzTadS2omWAPN84QLDWA7roo6CE1(0GETZ8P20RLKD(BXIdM(3Qddutp5X9VVSii59jW3Ifhm9VvpYXrNZ7BHotprWVe(3)(wD4Ob6260aDm(e4llz(e4BHotprWVe(wS4GP)TqPPGpy6FlqCicOXbt)BjB3GETbG7q3UweEnyu71G1AzvBg1saz7ANOn6GCaXH51(G1(W(v7L1kBjnRLg7zG1EnyTeiVwMeBPxR2hOdMpQAL9hyTWRwEu7itVwEu7RoFTAB4rTDOdhniyTjqu7d(wkw7Wa9R2eiQv0WHno(wIaEya5VfL1gao2ZWgvhsAKbp1pCyOqNPNiyTesyTuwBa4ypdBunGgnPRhxgKk0z6jcwRPAFzTs5aY0tuzeObWCQrPzTuRvMAPOwkQ1uTuwlnqVRcah1zxBKpyOaZhVwcjSwJaLQTfGkzuCiyh10CeSnwlf1AQwrMtW8XvbGJ6SRnYhmubsYqF8VVSK3NaFl0z6jc(LW3Ifhm9Vfknf8bt)BbIdranoy6FRxxV2h8TuS2o0HJgeS2eiQvK5emF8AFGoy(mQLDWAhgOF1MarTIgoSXH51AeWmGhu2dwRSL0S2ukg1IsXO91aD7AX5a)wIaEya5V1Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(Owt1kYCcMpUIdb7O2iFWqfijd9rTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8AnvRrGs12cqLmkoeSJAAoc2g)3xwe0NaFl0z6jc(LW3seWddi)Tcah7zyJkq4qanMqNJ2ArssYoOcDMEIG1AQwAGExbchcOXe6C0wlsss2b19ihNcW4BXIdM(3Qddutp5X9VVSKnFc8TqNPNi4xcFlrapmG83kaCSNHnQSd4y2wdfqXevOZ0teSwt1sYoRmexTYV2wiX9TyXbt)B1JCCApLY)7llI7tGVf6m9eb)s4BXIdM(3Idb7OMeogWjo(wIgg6Flz(wIaEya5Vva4ypdBuXHGDu3Wbz6TvOZ0teSwt1sd07koeSJ6goitVTACSGOABTwAGExXHGDu3Wbz6TvKSK6XXcIQ1uTuwlL1sd07koeSJAJ8bdfy(41AQwrMtW8XvCiyh1g5dgQazW21srTesyTGinqVRUeq0OZU(AqnjBdvag1sX)(Ys29jW3cDMEIGFj8Teb8WaYFRaWXEg2OAanAsxpUmivOZ0te8BXIdM(3kaCuNDTr(GX)(Y6v9jW3cDMEIGFj8Teb8WaYFlrMtW8XvbGJ6SRnYhmubYGT)wS4GP)T4qWoQZG(FFz1c(e4BHotprWVe(wIaEya5VLiZjy(4QaWrD21g5dgQazW21AQwAGExXHGDulA4WgvJJfevBR1sd07koeSJArdh2OIKLupowq03Ifhm9Vfhc2rn9Kh3)(YQf(jW3cDMEIGFj8Teb8WaYFRxwBa4ypdBuDiPrg8u)WHHcDMEIG1siH1ksheaEkBy)0zxFnOEcfnk0z6jc(TyXbt)BbI81qNHJ)7llzKZNaFlwCW0)wbGJ6SRnYhm(wOZ0te8lH)9LLmY8jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlqCicOXbt)B9661(GVdSw(QLKLS2XXcIg1M9AFXlQLDWAFWAByPO)(QfyGG12YscuBB8mVwGbwlx74ybr1EzTgbkf9Rwsax0aD7Ab8jog1gaUdD7AVgSwzV5Gm921orB0b5O93seWddi)TOb6DLyICi4XbDBvGS4Q1uT0a9Usmroe84GUTACSGOAPwlnqVRetKdbpoOBRizj1JJfevRPAfPu0z)usr)AAh1AQwrMtW8XvKWiYyOZU(YGe9tfid2Uwt1(YALYbKPNOcjnYhmqqnnhbBJ1AQwrMtW8XvCiyh1g5dgQazW2)7llzK3NaFl0z6jc(LW3seWddi)TEzTbGJ9mSr1HKgzWt9dhgk0z6jcwRPAPS2xwBa4ypdBunGgnPRhxgKk0z6jcwlHewlL1kLditprLrGgaZPgLM1sTwzQ1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTuulfFlqCicOXbt)BjRmi55SDTpyTgmmQ1ipy61cmWAFGxtTT0RzET0axTWR2h4Cw7KhxTZ0TRf9eWUP2Eg1sNxtTxdw7RoFTAzhS2w61Q9b6G5ZOwaFIJrTbG7q3U2RbR1YQ2mQLaY21orB0b5aIJVfloy6FlJ8GP)VVSKHG(e4BHotprWVe(wIaEya5VfnqVRcah1zxBKpyOaZhVwcjSwJaLQTfGkzuCiyh10CeSn(TyXbt)BbI81qNHJ)7llzKnFc8TqNPNi4xcFlrapmG83IgO3vbGJ6SRnYhmuG5JxlHewRrGs12cqLmkoeSJAAoc2g)wS4GP)TcgeY(PhgCq0)(YsgI7tGVf6m9eb)s4Bjc4HbK)w0a9UkaCuNDTr(GHkqsg6JABTwkRv2vlXQvE12YRnaCSNHnQgqJM01Jldsf6m9ebRLIVfloy6Flsyezm0zxFzqI(9VVSKr29jW3cDMEIGFj8TyXbt)BXHGDuBKpy8TaXHiGghm9VLSDd61gaUdD7AVgSwzV5Gm921orB0b5OT51cmWABPxRwASNbwlbYRLv7L1ccqAulxBhyoBx74ybriyT0CeSn(Teb8WaYFlPCaz6jQqsJ8bdeutZrW2yTMQLgO3vbGJ6SRnYhmuag1AQwkRLKDwziUABTwkRvEexTeRwkRvg5uBlVwrkfD2pfrTdi71srTuulHewlnqVRetKdbpoOBRghliQwQ1sd07kXe5qWJd62ksws94ybr1sX)(YsMx1NaFl0z6jc(LW3seWddi)TKYbKPNOcjnYhmqqnnhbBJ1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYsQhhliQwt1sd07koeSJAJ8bdfGX3Ifhm9Vfhc2rnnhbBJ)7llzAbFc8TqNPNi4xcFlwCW0)wJeyoX7GUToaOB)Teb8WaYFlAGExfaoQZU2iFWqbMpETesyTgbkvBlavYO4qWoQP5iyBSwcjSwJaLQTfGkzubdcz)0ddoiQwcjSwkR1iqPABbOsgfiYxdDgowRPAFzTbGJ9mSr1aA0KUECzqQqNPNiyTu8TCMe)wJeyoX7GUToaOB)VVSKPf(jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqbMpETesyTgbkvBlavYO4qWoQP5iyBSwcjSwJaLQTfGkzubdcz)0ddoiQwcjSwkR1iqPABbOsgfiYxdDgowRPAFzTbGJ9mSr1aA0KUECzqQqNPNiyTu8TyXbt)BDjGOrND91GAs2g(VVSKNC(e4BHotprWVe(wIaEya5VLrGs12cqLmQlben6SRVgutY2WVfloy6FloeSJAJ8bJ)9LL8K5tGVf6m9eb)s4BXIdM(3YiWb6cuNDnj0b)wG4qeqJdM(3s2FG1(AzlR2lRD0Ibqu2dwl71IsEbxBlfc2XALWKhxTGab0TR9AWAjqETmj2sVwTpqhmFQfWN4yuBa4o0TRTLcb7yTYwIMuv7RRxBlfc2XALTenzTWrThpr)qqZR9bRvW(7RwGbw7RLTSAFGxd0R9AWAjqETmj2sVwTpqhmFQfWN4yu7dwl0pmcaJR2RbRTLAz1kAy3XP51oYAFW3ZzTdwkwl8uFlrapmG836L1E8e9tXHGDuJIMuHotprWAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6JABLATuwlloy6koeSJA6jpofkjkaouFqsS2wET0a9UYiWb6cuNDnj0bvKSK6XXcIQLI)9LL8K3NaFl0z6jc(LW3Ifhm9VLrGd0fOo7AsOd(TaXHiGghm9V1RRx7RLTSAB4H)(QLgrVwGbcwliqaD7AVgSwcKxlR2hOdMpMx7d(EoRfyG1cVAVS2rlgarzpyTSxlk5fCTTuiyhRvctEC1c9AVgS2xD(AsSLETAFGoy(O(wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExfaoQZU2iFWqfijd9rTTsTwkRLfhmDfhc2rn9KhNcLefahQpijwBlVwAGExze4aDbQZUMe6Gksws94ybr1sX)(YsEe0NaFl0z6jc(LW3seWddi)TaZtfmiK9tpm4GivGKm0h1k)AjUAjKWAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOALFTY5BXIdM(3Idb7OMEYJ7FFzjpzZNaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)BjBJ1(W(v7L1sYeH1oacS2hS2gwkwl6jGDtTKSZ12ZO2RbRf9dgyTT0Rv7d0bZhZRfLIETWETxdg47rTJdoN1EqsS2ajzOdD7AtV2xD(AQAFD37rTPpBxlnEhg1EzT0aHx7L1k7bJSw2bRv2sAwlSxBa4o0TR9AWATSQnJAjGSDTt0gDqoG4q9Teb8WaYFlrMtW8XvCiyh1g5dgQazW21AQws2zLH4QT1APSwzJCQLy1szTYiNAB51ksPOZ(PiQDazVwkQLIAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizj1JJfevRPAPS2xwBa4ypdBunGgnPRhxgKk0z6jcwlHewRuoGm9evgbAamNAuAwl1ALPwkQ1uTVS2aWXEg2O6qsJm4P(Hddf6m9ebR1uTVS2aWXEg2OIdb7OUHdY0BRqNPNi4)(YsEe3NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)Bjboc2gRD0KatWA98QLgRfyGG1YxTxdwl6G1M9ABPxRwyVwzlPPGpy61ch1gid2UwEulyKggq3Uwrdh24O2h4Cwljtewl8Q9yIWANPBJrTxwlnq41Enrcy3uBGKm0HUDTKSZFlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVR4qWoQnYhmubsYqFuBRuR1wawRPAfzobZhxHstbFW0vbsYqF8VVSKNS7tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TKahbBJ1oAsGjyT88HBpQLgR9AWAN84QvWJRwOx71G1(QZxR2hOdMp1YJAjqETSAFGZzTboUmWAVgSwrdh24O2Hb633seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHkqsg6JABLAT2cWAnv7lRnaCSNHnQ4qWoQB4Gm92k0z6jc(VVSK3R6tGVf6m9eb)s4BjAyO)TK5BHCmBRfnm01W(3IgO3vIjYHGhh0T1Ig2DCQaZh3eL0a9UIdb7O2iFWqbyqiHu(YJNOFQukgg5dgiOjkPb6Dva4Oo7AJ8bdfGbHekYCcMpUcLMc(GPRcKbBtbfu8Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnv7Xt0pfhc2rnkAsf6m9ebR1uTuwlnqVRar(AOZWrfy(41siH1YIdkf1OJKqCul1ALPwkQ1uTGinqVRUeq0OZU(AqnjBdvbsYqFuR8RLfhmDfhc2rnjCmGtCOqjrbWH6dsIFlwCW0)wCiyh1KWXaoXX)(YsETGpb(wOZ0te8lHVfloy6FloeSJAs4yaN44BbIdranoy6FRxxV2h8DG1kf9RPDyETqsseeYhoBxlWaR9fVO2Ng0RvWggiyTxwRNxTp84WAnIumQThjzTTSKaFlrapmG83sKsrN9tjf9RPDuRPAPb6DLyICi4XbDB14ybr1sTwAGExjMihcECq3wrYsQhhli6FFzjVw4NaFl0z6jc(LW3cehIaACW0)wwhhxTadOBx7lErTTulR2Ng0RTLETAB4rT0i61cmqWVLiGhgq(Brd07kXe5qWJd62QazXvRPAfzobZhxXHGDuBKpyOcKKH(Owt1szT0a9UkaCuNDTr(GHcWOwcjSwAGExXHGDuBKpyOamQLIVLOHH(3sMVfloy6FloeSJAs4yaN44FFzrqY5tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7Ow0WHnQghliQ2wPwRuoGm9evxEKAswsTOHdBC8TyXbt)BXHGDuNb9)(YIGK5tGVf6m9eb)s4Bjc4HbK)w0a9UkaCuNDTr(GHcWOwcjSws2zLH4Qv(1kdX9TyXbt)BXHGDutp5X9VVSii59jW3cDMEIGFj8TyXbt)BHstbFW0)wq)WiamonS)TizNvgIt(uBbe33c6hgbGXPHKKiiKp8BjZ3seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwAGExXHGDuBKpyOaZh)FFzrqe0NaFlwCW0)wCiyh10CeSn(TqNPNi4xc)7FFRip(GP)jWxwY8jW3cDMEIGFj8TyXbt)BHstbFW0)wG4qeqJdM(3s2FG1IsZAH9AFW3bw7mFQn9AjzNRLDWAfzobZhFulhyTmDcC1EzT0yTagFlrapmG836L1gao2ZWgvdOrt66XLbPcDMEIG1AQws2zLH4QTvQ1kLditprfkn1gIRwt1szTImNG5JRUeq0OZU(AqnjBdvbsYqFuBRuRLfhmDfknf8btxHsIcGd1hKeRLqcRvK5emFCfhc2rTr(GHkqsg6JABLATS4GPRqPPGpy6kusuaCO(GKyTesyTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2wPwlloy6kuAk4dMUcLefahQpijwlf1srTMQLgO3vbGJ6SRnYhmuG5JxRPAPb6Dfhc2rTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(41AQ2xwRrGs12cqLmQlben6SRVgutY2W)9LL8(e4BHotprWVe(wIaEya5Vva4ypdBunGgnPRhxgKk0z6jcwRPAFzTIuk6SFkPOFnTJAnvRiZjy(4koeSJAJ8bdvGKm0h12k1AzXbtxHstbFW0vOKOa4q9bjXVfloy6FluAk4dM()(YIG(e4BHotprWVe(wIaEya5Vva4ypdBunGgnPRhxgKk0z6jcwRPAfPu0z)usr)AAh1AQwrMtW8XvKWiYyOZU(YGe9tfijd9rTTsTwwCW0vO0uWhmDfkjkaouFqsSwt1kYCcMpU6sarJo76Rb1KSnufijd9rTTsTwkRvkhqMEIkY80gbkqeuF5rQPBxlXQLfhmDfknf8btxHsIcGd1hKeRLy1sq1srTMQvK5emFCfhc2rTr(GHkqsg6JABLATuwRuoGm9evK5PncuGiO(YJut3UwIvlloy6kuAk4dMUcLefahQpijwlXQLGQLIVfloy6FluAk4dM()(Ys28jW3cDMEIGFj8TyXbt)BXHGDutZrW243cehIaACW0)wsGJGTXAH9AH37rThKeR9YAbgyTxEK1YoyTpyTnSuS2lZAjzVDTIgoSXX3seWddi)TezobZhxDjGOrND91GAs2gQcKbBxRPAPSwAGExXHGDulA4WgvJJfevR8RvkhqMEIQlpsnjlPw0WHnoQ1uTImNG5JR4qWoQnYhmubsYqFuBRuRfLefahQpijwRPAjzNvgIRw5xRuoGm9evSHMe6qsasnj7S2qC1AQwAGExfaoQZU2iFWqbMpETu8VVSiUpb(wOZ0te8lHVLiGhgq(BjYCcMpU6sarJo76Rb1KSnufid2Uwt1szT0a9UIdb7Ow0WHnQghliQw5xRuoGm9evxEKAswsTOHdBCuRPApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCva4Oo7AJ8bdvGKm0h12k1ArjrbWH6dsI1AQwPCaz6jQoijQb8do1SrTYVwPCaz6jQU8i1KSKAqCYT19m0SrTu8TyXbt)BXHGDutZrW24)(Ys29jW3cDMEIGFj8Teb8WaYFlrMtW8XvxciA0zxFnOMKTHQazW21AQwkRLgO3vCiyh1IgoSr14ybr1k)ALYbKPNO6YJutYsQfnCyJJAnvlL1(YApEI(Pcah1zxBKpyOqNPNiyTesyTImNG5JRcah1zxBKpyOcKKH(Ow5xRuoGm9evxEKAswsnio526Eg6inQLIAnvRuoGm9evhKe1a(bNA2Ow5xRuoGm9evxEKAswsnio526EgA2Owk(wS4GP)T4qWoQP5iyB8FFz9Q(e4BHotprWVe(wIaEya5Vfisd07QGbHSF6HbhePLcmDmyA4eETvJJfevl1AbrAGExfmiK9tpm4GiTuGPJbtdNWRTIKLupowquTMQLYAPb6Dfhc2rTr(GHcmF8AjKWAPb6Dfhc2rTr(GHkqsg6JABLAT2cWAPOwt1szT0a9UkaCuNDTr(GHcmF8AjKWAPb6Dva4Oo7AJ8bdvGKm0h12k1ATfG1sX3Ifhm9Vfhc2rnnhbBJ)7lRwWNaFl0z6jc(LW3seWddi)TKYbKPNOQffyCAGbcQhgCquTesyTuwlisd07QGbHSF6HbhePLcmDmyA4eETvag1AQwqKgO3vbdcz)0ddoislfy6yW0Wj8ARghliQ2wRfePb6DvWGq2p9WGdI0sbMogmnCcV2ksws94ybr1sX3Ifhm9Vfhc2rn9Kh3)(YQf(jW3cDMEIGFj8Teb8WaYFlAGExze4aDbQZUMe6GkaJAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6JABLATS4GPR4qWoQPN84uOKOa4q9bjXVfloy6FloeSJA6jpU)9LLmY5tGVf6m9eb)s4BjAyO)TK5BHCmBRfnm01W(3IgO3vIjYHGhh0T1Ig2DCQaZh3eL0a9UIdb7O2iFWqbyqiHu(YJNOFQukgg5dgiOjkPb6Dva4Oo7AJ8bdfGbHekYCcMpUcLMc(GPRcKbBtbfu8Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnv7Xt0pfhc2rnkAsf6m9ebR1uTuwlnqVRar(AOZWrfy(41siH1YIdkf1OJKqCul1ALPwkQ1uTuwlisd07Qlben6SRVgutY2qvGKm0h1k)AzXbtxXHGDutchd4ehkusuaCO(GKyTesyTImNG5JRmcCGUa1zxtcDqvGKm0h1siH1ksPOZ(PiQDazVwk(wS4GP)T4qWoQjHJbCIJ)9LLmY8jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlqCicOXbt)B9I0haKyTxdwlkPb7GiyTg5H(b5zT0a9ET8GnQ9YA98QDMdSwJ8q)G8SwJifJVLiGhgq(Brd07kXe5qWJd62QazXvRPAPb6DfkPb7GiO2ip0pipvag)7llzK3NaFl0z6jc(LW3Ifhm9Vfhc2rnjCmGtC8Tenm0)wY8Teb8WaYFlAGExjMihcECq3wfilUAnvlL1sd07koeSJAJ8bdfGrTesyT0a9UkaCuNDTr(GHcWOwcjSwqKgO3vxciA0zxFnOMKTHQajzOpQv(1YIdMUIdb7OMeogWjouOKOa4q9bjXAP4FFzjdb9jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlrdd9VLmFlrapmG83IgO3vIjYHGhh0TvbYIRwt1sd07kXe5qWJd62QXXcIQLAT0a9Usmroe84GUTIKLupowq0)(YsgzZNaFl0z6jc(LW3cehIaACW0)wT08HBpQ9I21EzT0StuTV4f12ZOwrMtW8XR9b6G5ZOwAGRwqasJAVgKSwyV2RbB)oWAz6e4Q9YArjnGb(Teb8WaYFlAGExjMihcECq3wfilUAnvlnqVRetKdbpoOBRcKKH(O2wPwlL1szT0a9Usmroe84GUTACSGOAB51YIdMUIdb7OMeogWjouOKOa4q9bjXAPOwIvRTaurYswlfFlrdd9VLmFlwCW0)wCiyh1KWXaoXX)(YsgI7tGVf6m9eb)s4Bjc4HbK)wuwBG9ahnm9eRLqcR9L1Eqbrq3UwkQ1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTMQLgO3vCiyh1g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5J)TyXbt)B541GH(qsdCC)7llzKDFc8TqNPNi4xcFlrapmG83IgO3vCiyh1IgoSr14ybr12k1ALYbKPNO6YJutYsQfnCyJJVfloy6FloeSJ6mO)3xwY8Q(e4BHotprWVe(wIaEya5VLuoGm9evjWnGGOo7ArMtW8Xh1AQws2zLH4QTvQ12cjUVfloy6FRbGbgEkL)3xwY0c(e4BHotprWVe(wIaEya5VfnqVRcGjQZU(AcehkaJAnvlnqVR4qWoQfnCyJQXXcIQv(1sqFlwCW0)wCiyh10tEC)7llzAHFc8TqNPNi4xcFlwCW0)wCiyh10CeSn(TaXHiGghm9VLSxaKg1kA4Wgh1c71(G1255SwACMp1EnyTI0hyifRLKDU2RjWrtobRLDWArPPGpy61ch1oo4CwB61kYCcMp(3seWddi)TEzTbGJ9mSr1aA0KUECzqQqNPNiyTMQvkhqMEIQe4gqquNDTiZjy(4JAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizj1JJfevRPApEI(P4qWoQZGwHotprWAnvRiZjy(4koeSJ6mOvbsYqFuBRuR1wawRPAjzNvgIR2wPwBluo1AQwrMtW8XvO0uWhmDvGKm0h)7ll5jNpb(wOZ0te8lHVLiGhgq(Bfao2ZWgvdOrt66XLbPcDMEIG1AQwPCaz6jQsGBabrD21ImNG5JpQ1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTMQ94j6NIdb7OodAf6m9ebR1uTImNG5JR4qWoQZGwfijd9rTTsTwBbyTMQLKDwziUABLATTq5uRPAfzobZhxHstbFW0vbsYqFuBR1sqY5BXIdM(3Idb7OMMJGTX)9LL8K5tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TK9cG0Owrdh24OwyV2mORfoQnqgS93seWddi)TKYbKPNOkbUbee1zxlYCcMp(Owt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr1AQ2JNOFkoeSJ6mOvOZ0teSwt1kYCcMpUIdb7OodAvGKm0h12k1ATfG1AQws2zLH4QTvQ12cLtTMQvK5emFCfknf8btxfijd9rTMQLYAFzTbGJ9mSr1aA0KUECzqQqNPNiyTesyT0a9UAanAsxpUmivbsYqFuBRuRvMwqTu8VVSKN8(e4BHotprWVe(wS4GP)T4qWoQP5iyB8BbIdranoy6FRwkeSJ1kboc2gRD0KatWATrhdEoBxlnw71G1o5XvRGhxTzV2RbRTLETAFGoy(8Teb8WaYFlAGExXHGDuBKpyOamQ1uT0a9UIdb7O2iFWqfijd9rTTsTwBbyTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQ1uTuwRiZjy(4kuAk4dMUkqsg6JAjKWAdah7zyJkoeSJ6goitVTcDMEIG1sX)(YsEe0NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)B1sHGDSwjWrW2yTJMeycwRn6yWZz7APXAVgS2jpUAf84Qn71EnyTV681Q9b6G5Z3seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHkqsg6JABLAT2cWAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizj1JJfevRPAPSwrMtW8XvO0uWhmDvGKm0h1siH1gao2ZWgvCiyh1nCqMEBf6m9ebRLI)9LL8KnFc8TqNPNi4xcFlwCW0)wCiyh10CeSn(TaXHiGghm9Vvlfc2XALahbBJ1oAsGjyT0yTxdw7KhxTcEC1M9AVgSwcKxlR2hOdMp1c71cVAHJA98QfyGG1(aVMAF15RvBg12sV23seWddi)TOb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubyuRPAbrAGExDjGOrND91GAs2gQcKKH(O2wPwRTaSwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr)7ll5rCFc8TqNPNi4xcFlwCW0)wCiyh10CeSn(TaXHiGghm9VLSDd61EnyThh24vlCul0RfLefahwBWUnwl7G1EnyG1ch1sMbw71WETPJ1Ios228AbgyT0CeSnwlpQDKPxlpQTDcuBdlfRf9eWUPwrdh24O2lRTbE1YZzTOJKqCulSx71G12sHGDSwjKK0CasI(v7eTrhKJ21ch1ITyaOHbc(Teb8WaYFlPCaz6jQqsJ8bdeutZrW2yTMQLgO3vCiyh1IgoSr14ybr1kFQ1szTS4Gsrn6ijeh12IuRm1srTMQLfhukQrhjH4Ow5xRm1AQwAGExbI81qNHJkW8X)3xwYt29jW3cDMEIGFj8Teb8WaYFlPCaz6jQqsJ8bdeutZrW2yTMQLgO3vCiyh1IgoSr14ybr12AT0a9UIdb7Ow0WHnQizj1JJfevRPAzXbLIA0rsioQv(1ktTMQLgO3vGiFn0z4OcmF8Vfloy6FloeSJAusJzoGP)VVSK3R6tGVfloy6FloeSJA6jpUVf6m9eb)s4FFzjVwWNaFl0z6jc(LW3seWddi)TKYbKPNOkbUbee1zxlYCcMp(4BXIdM(3cLMc(GP)VVSKxl8tGVfloy6FloeSJAAoc2g)wOZ0te8lH)9VVLiZjy(4Jpb(YsMpb(wOZ0te8lHVfloy6FREKJt7Pu(BbIdranoy6FRxlGzapOShSwGb0TR1oGJz7AHcOyI1(aVMAzdvTY(dSw4v7d8AQ9YJS28AW4boq13seWddi)Tcah7zyJk7aoMT1qbumrf6m9ebR1uTImNG5JR4qWoQnYhmubsYqFuR8RLGKtTMQvK5emFC1LaIgD21xdQjzBOkqgSDTMQLYAPb6Dfhc2rTOHdBunowquTTsTwPCaz6jQU8i1KSKArdh24Owt1szTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2wPwRTaSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwPCaz6jQU8i1KSKAqCYT19m0SrTuulHewlL1(YApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCfhc2rTr(GHkqsg6JALFTs5aY0tuD5rQjzj1G4KBR7zOzJAPOwcjSwrMtW8XvCiyh1g5dgQajzOpQTvQ1AlaRLIAP4FFzjVpb(wOZ0te8lHVLiGhgq(Bfao2ZWgv2bCmBRHcOyIk0z6jcwRPAfzobZhxXHGDuBKpyOcKbBxRPAPS2xw7Xt0pf6tODZHocQqNPNiyTesyTuw7Xt0pf6tODZHocQqNPNiyTMQLKDwziUALp1AFvYPwkQLIAnvlL1szTImNG5JRUeq0OZU(AqnjBdvbsYqFuR8Rvg5uRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlPECSGOAPOwcjSwkRvK5emFC1LaIgD21xdQjzBOkqsg6JAPwRCQ1uT0a9UIdb7Ow0WHnQghliQwQ1kNAPOwkQ1uT0a9UkaCuNDTr(GHcmF8Anvlj7SYqC1kFQ1kLditprfBOjHoKeGutYoRne33Ifhm9VvpYXP9uk)VVSiOpb(wOZ0te8lHVLiGhgq(Bfao2ZWgvGWHaAmHohT1IKKKDqf6m9ebR1uTImNG5JROb6DniCiGgtOZrBTijjzhufid2Uwt1sd07kq4qanMqNJ2ArssYoOUh54uG5JxRPAPSwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5Jxlf1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYPwt1szT0a9UIdb7Ow0WHnQghliQ2wPwRuoGm9evxEKAswsTOHdBCuRPAPSwkR94j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvbGJ6SRnYhmubsYqFuBRuR1wawRPAfzobZhxXHGDuBKpyOcKKH(Ow5xRuoGm9evxEKAswsnio526EgA2OwkQLqcRLYAFzThpr)ubGJ6SRnYhmuOZ0teSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwPCaz6jQU8i1KSKAqCYT19m0SrTuulHewRiZjy(4koeSJAJ8bdvGKm0h12k1ATfG1srTu8TyXbt)B1JCC058(3xwYMpb(wOZ0te8lHVLiGhgq(Bfao2ZWgvGWHaAmHohT1IKKKDqf6m9ebR1uTImNG5JROb6DniCiGgtOZrBTijjzhufid2Uwt1sd07kq4qanMqNJ2ArssYoOUddubMpETMQ1iqPABbOsgvpYXrNZ7BXIdM(3Qddutp5X9VVSiUpb(wOZ0te8lHVfloy6Flsyezm0zxFzqI(9TaXHiGghm9V1RXWO2wwsGAFGxtTT0RvlSxl8EpQvKKq3UwaJAhz6QAFD9AHxTpW5SwASwGbcw7d8AQLa51YmVwbpUAHxTJj0U5MTRLg7zGFlrapmG83IYAFzTbGJ9mSr1aA0KUECzqQqNPNiyTesyT0a9UAanAsxpUmivag1srTMQvK5emFC1LaIgD21xdQjzBOkqsg6JABTwPCaz6jQiZtBeOarq9LhPMUDTesyTuwRuoGm9evhKe1a(bNA2Ow5xRuoGm9evK5Pjzj1G4KBR7zOzJAnvRiZjy(4Qlben6SRVgutY2qvGKm0h1k)ALYbKPNOImpnjlPgeNCBDpd9LhzTu8VVSKDFc8TqNPNi4xcFlrapmG83sK5emFCfhc2rTr(GHkqgSDTMQLYAFzThpr)uOpH2nh6iOcDMEIG1siH1szThpr)uOpH2nh6iOcDMEIG1AQws2zLH4Qv(uR9vjNAPOwkQ1uTuwlL1kYCcMpU6sarJo76Rb1KSnufijd9rTYVwPCaz6jQydnjlPgeNCBDpd9LhzTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQLIAjKWAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYPwt1sd07koeSJArdh2OACSGOAPwRCQLIAPOwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8PwRuoGm9evSHMe6qsasnj7S2qCFlwCW0)wKWiYyOZU(YGe97FFz9Q(e4BHotprWVe(wIaEya5VLuoGm9evjWnGGOo7ArMtW8Xh1AQwkRDKatAOdQKMt(GtupYPu0pf6m9ebRLqcRDKatAOdQmaghWe1yayCW0vOZ0teSwk(wS4GP)T6tC0icUF)7lRwWNaFl0z6jc(LW3Ifhm9VfiYxdDgo(TaXHiGghm9VvlnF42JAbgyTGiFn0z4yTpWRPw2qv7RRx7LhzTWrTbYGTRLh1(GZP51sYeH1oacS2lRvWJRw4vln2ZaR9YJu9Teb8WaYFlrMtW8XvxciA0zxFnOMKTHQazW21AQwAGExXHGDulA4WgvJJfevBRuRvkhqMEIQlpsnjlPw0WHnoQ1uTImNG5JR4qWoQnYhmubsYqFuBRuR1wa(VVSAHFc8TqNPNi4xcFlrapmG83sK5emFCfhc2rTr(GHkqgSDTMQLYAFzThpr)uOpH2nh6iOcDMEIG1siH1szThpr)uOpH2nh6iOcDMEIG1AQws2zLH4Qv(uR9vjNAPOwkQ1uTuwlL1kYCcMpU6sarJo76Rb1KSnufijd9rTYVwzKtTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQLIAjKWAPSwrMtW8XvxciA0zxFnOMKTHQazW21AQwAGExXHGDulA4WgvJJfevl1ALtTuulf1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALp1ALYbKPNOIn0KqhscqQjzN1gI7BXIdM(3ce5RHodh)3xwYiNpb(wOZ0te8lHVfloy6FRGbHSF6Hbhe9TaXHiGghm9VLS)aRDyWbr1c71E5rwl7G1Yg1YbwB61kaRLDWAFs)9vlnwlGrT9mQDMUng1EnSx71G1sYswlio52Mxljte0TRDaeyTpyTnSuSw(QDI84Q9EYA5qWowROHdBCul7G1En8v7LhzTp8WFF12IcmUAbgiO6Bjc4HbK)wImNG5JRUeq0OZU(AqnjBdvbsYqFuR8RvkhqMEIQyOjzj1G4KBR7zOV8iR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQyOjzj1G4KBR7zOzJAnvlL1E8e9tfaoQZU2iFWqHotprWAnvlL1kYCcMpUkaCuNDTr(GHkqsg6JABTwusuaCO(GKyTesyTImNG5JRcah1zxBKpyOcKKH(Ow5xRuoGm9evXqtYsQbXj3w3ZqhPrTuulHew7lR94j6NkaCuNDTr(GHcDMEIG1srTMQLgO3vCiyh1IgoSr14ybr1k)ALxTMQfePb6D1LaIgD21xdQjzBOcmF8AnvlnqVRcah1zxBKpyOaZhVwt1sd07koeSJAJ8bdfy(4)7llzK5tGVf6m9eb)s4BXIdM(3kyqi7NEyWbrFlqCicOXbt)Bj7pWAhgCquTpWRPw2O2Ng0R1ihdi9ev1(661E5rwlCuBGmy7A5rTp4CAETKmryTdGaR9YAf84QfE1sJ9mWAV8ivFlrapmG83sK5emFC1LaIgD21xdQjzBOkqsg6JABTwusuaCO(GKyTMQLgO3vCiyh1IgoSr14ybr12k1ALYbKPNO6YJutYsQfnCyJJAnvRiZjy(4koeSJAJ8bdvGKm0h12ATuwlkjkaouFqsSwIvlloy6Qlben6SRVgutY2qfkjkaouFqsSwk(3xwYiVpb(wOZ0te8lHVLiGhgq(BjYCcMpUIdb7O2iFWqfijd9rTTwlkjkaouFqsSwt1szTuw7lR94j6Nc9j0U5qhbvOZ0teSwcjSwkR94j6Nc9j0U5qhbvOZ0teSwt1sYoRmexTYNATVk5ulf1srTMQLYAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kLditprfBOjzj1G4KBR7zOV8iR1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTuulHewlL1kYCcMpU6sarJo76Rb1KSnufijd9rTuRvo1AQwAGExXHGDulA4WgvJJfevl1ALtTuulf1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALp1ALYbKPNOIn0KqhscqQjzN1gIRwk(wS4GP)TcgeY(PhgCq0)(Ysgc6tGVf6m9eb)s4BXIdM(3AKaZjEh0T1baD7VLiGhgq(BrzTVS2aWXEg2OAanAsxpUmivOZ0teSwcjSwAGExnGgnPRhxgKkaJAPOwt1sd07koeSJArdh2OACSGOABLATs5aY0tuD5rQjzj1IgoSXrTMQvK5emFCfhc2rTr(GHkqsg6JABLATOKOa4q9bjXAnvlj7SYqC1k)ALYbKPNOIn0KqhscqQjzN1gIRwt1sd07QaWrD21g5dgkW8X)wotIFRrcmN4Dq3wha0T)3xwYiB(e4BHotprWVe(wS4GP)TUeq0OZU(AqnjBd)wG4qeqJdM(3s2FG1E5rw7d8AQLnQf2RfEVh1(aVgOx71G1sYswlio52QAFD9A98mVwGbw7d8AQnsJAH9AVgS2JNOF1ch1EmrOBETSdwl8EpQ9bEnqV2RbRLKLSwqCYTvFlrapmG83IYAFzTbGJ9mSr1aA0KUECzqQqNPNiyTesyT0a9UAanAsxpUmivag1srTMQLgO3vCiyh1IgoSr14ybr12k1ALYbKPNO6YJutYsQfnCyJJAnvRiZjy(4koeSJAJ8bdvGKm0h12k1ArjrbWH6dsI1AQws2zLH4Qv(1kLditprfBOjHoKeGutYoRnexTMQLgO3vbGJ6SRnYhmuG5J)VVSKH4(e4BHotprWVe(wIaEya5VfnqVR4qWoQfnCyJQXXcIQTvQ1kLditpr1LhPMKLulA4Wgh1AQ2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxfaoQZU2iFWqfijd9rTTsTwusuaCO(GKyTMQvkhqMEIQdsIAa)GtnBuR8RvkhqMEIQlpsnjlPgeNCBDpdnB8TyXbt)BDjGOrND91GAs2g(VVSKr29jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfevBRuRvkhqMEIQlpsnjlPw0WHnoQ1uTuw7lR94j6NkaCuNDTr(GHcDMEIG1siH1kYCcMpUkaCuNDTr(GHkqsg6JALFTs5aY0tuD5rQjzj1G4KBR7zOJ0OwkQ1uTs5aY0tuDqsud4hCQzJALFTs5aY0tuD5rQjzj1G4KBR7zOzJVfloy6FRlben6SRVgutY2W)9LLmVQpb(wOZ0te8lHVfloy6FloeSJAJ8bJVfioeb04GP)TK9hyTSrTWETxEK1ch1METcWAzhS2N0FF1sJ1cyuBpJANPBJrTxd71EnyTKSK1cItUT51sYebD7Ahabw71WxTpyTnSuSw0ta7MAjzNRLDWAVg(Q9AWaRfoQ1ZRwEgid2UwU2aWXAZETg5dg1cMpU6Bjc4HbK)wImNG5JRUeq0OZU(AqnjBdvbsYqFuR8RvkhqMEIk2qtYsQbXj3w3ZqF5rwRPAPS2xwRiLIo7Nsk6xt7OwcjSwrMtW8XvKWiYyOZU(YGe9tfijd9rTYVwPCaz6jQydnjlPgeNCBDpdnzE1srTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQ1uT0a9UkaCuNDTr(GHcmF8Anvlj7SYqC1kFQ1kLditprfBOjHoKeGutYoRne3)(YsMwWNaFl0z6jc(LW3Ifhm9Vva4Oo7AJ8bJVfioeb04GP)TK9hyTrAulSx7LhzTWrTPxRaSw2bR9j93xT0yTag12ZO2z62yu71WETxdwljlzTG4KBBETKmrq3U2bqG1EnyG1ch(7RwEgid2UwU2aWXAbZhVw2bR9A4Rw2O2N0FF1sJIKeRLLYWjtpXAbbcOBxBa4O6Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xRuoGm9evrAOjzj1G4KBR7zOV8iRLqcRvK5emFCfhc2rTr(GHkqsg6JABLATs5aY0tuD5rQjzj1G4KBR7zOzJAPOwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kJCQ1uTImNG5JRUeq0OZU(AqnjBdvbsYqFuR8Rvg58VVSKPf(jW3cDMEIGFj8Teb8WaYFlPCaz6jQsGBabrD21ImNG5Jp(wS4GP)TgnW(bDBTr(GX)(YsEY5tGVf6m9eb)s4BXIdM(3YiWb6cuNDnj0b)wG4qeqJdM(3s2FG1AKK1EzTJwmaIYEWAzVwuYl4Az6AHETxdwRJsE1kYCcMpETpqhmFmVwaFIJrTe1oGSx71GETPpBxliqaD7A5qWowRr(GrTGayTxwBt(ulj7CTnaUD0U2GbHSF1om4GOAHJVLiGhgq(BD8e9tfaoQZU2iFWqHotprWAnvlnqVR4qWoQnYhmuag1AQwAGExfaoQZU2iFWqfijd9rTTwRTaurYs(VVSKNmFc8TqNPNi4xcFlrapmG83cePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9rTTwlloy6koeSJAs4yaN4qHsIcGd1hKeR1uTVSwrkfD2pfrTdi7FlwCW0)wgboqxG6SRjHo4)(YsEY7tGVf6m9eb)s4Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07QaWrD21g5dgQajzOpQT1ATfGkswYAnvRiZjy(4kuAk4dMUkqgSDTMQvK5emFC1LaIgD21xdQjzBOkqsg6JAnv7lRvKsrN9tru7aY(3Ifhm9VLrGd0fOo7AsOd(V)9TaXodmVpb(YsMpb(wS4GP)TejGFymmW58BHotprWVe(3xwY7tGVf6m9eb)s4Bjc4HbK)wuw7Xt0pf6tODZHocQqNPNiyTMQLKDwziUABLATTa5uRPAjzNvgIRw5tTwzhXvlf1siH1szTVS2JNOFk0Nq7MdDeuHotprWAnvlj7SYqC12k1ABbexTu8TyXbt)BrYoRTrY)9Lfb9jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TmYdM()(Ys28jW3cDMEIGFj8Teb8WaYFRaWXEg2O6qsJm4P(Hddf6m9ebR1uT0a9UcLSHbghmDfGrTMQLYAfzobZhxXHGDuBKpyOcKbBxlHewlDog1AQ2o0U50bsYqFuBRuRv2iNAP4BXIdM(36GKO(HdJ)9LfX9jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5J)TyXbt)BnH2n3q3IcaAtI(9VVSKDFc8TqNPNi4xcFlrapmG83IgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(4FlwCW0)w0STo76lGcIg)7lRx1NaFl0z6jc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3IgJbgebD7)9Lvl4tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)BrpZeu3bI2)7lRw4NaFl0z6jc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3QddKEMj4)(Ysg58jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TyxGJl4PwWZ5)(Ysgz(e4BHotprWVe(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)wadudpKC8VVSKrEFc8TqNPNi4xcFlwCW0)w2tgeYxgdnndAJFlrapmG83IgO3vCiyh1g5dgkaJAjKWAfzobZhxXHGDuBKpyOcKKH(Ow5tTwIJ4Q1uTGinqVRUeq0OZU(AqnjBdvagFlS3rXPDMe)w2tgeYxgdnndAJ)7llziOpb(wOZ0te8lHVfloy6FlK0ODG8uNbOZUa)wIaEya5VLiZjy(4koeSJAJ8bdvGKm0h12k1ALH4Q1uTImNG5JRUeq0OZU(AqnjBdvbsYqFuBRuRvgI7B5mj(TqsJ2bYtDgGo7c8FFzjJS5tGVf6m9eb)s4BXIdM(3cmqgSddulfhdC(Teb8WaYFlrMtW8XvCiyh1g5dgQajzOpQv(uRvEYPwcjS2xwRuoGm9evSHoDnWaRLATYulHewlL1EqsSwQ1kNAnvRuoGm9evD4Ob6260aDmQLATYuRPAdah7zyJQb0OjD94YGuHotprWAP4B5mj(TadKb7Wa1sXXaN)7llziUpb(wOZ0te8lHVfloy6FRrcm1qBhEy8Teb8WaYFlrMtW8XvCiyh1g5dgQajzOpQv(uRLGKtTesyTVSwPCaz6jQydD6AGbwl1AL5B5mj(TgjWudTD4HX)(Ysgz3NaFl0z6jc(LW3Ifhm9VL9STrJo7AEmGKWjFW0)wIaEya5VLiZjy(4koeSJAJ8bdvGKm0h1kFQ1kp5ulHew7lRvkhqMEIk2qNUgyG1sTwzQLqcRLYApijwl1ALtTMQvkhqMEIQoC0aDBDAGog1sTwzQ1uTbGJ9mSr1aA0KUECzqQqNPNiyTu8TCMe)w2Z2gn6SR5XascN8bt)FFzjZR6tGVf6m9eb)s4BXIdM(3IKfmDG6rdINMeyafFlrapmG83sK5emFCfhc2rTr(GHkqsg6JABLATexTMQLYAFzTs5aY0tu1HJgOBRtd0XOwQ1ktTesyThKeRv(1sqYPwk(wotIFlswW0bQhniEAsGbu8VVSKPf8jW3cDMEIGFj8TyXbt)BrYcMoq9ObXttcmGIVLiGhgq(BjYCcMpUIdb7O2iFWqfijd9rTTsTwIRwt1kLditprvhoAGUTonqhJAPwRm1AQwAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0h12k1APSwzKtTTi1sC12YRnaCSNHnQgqJM01Jldsf6m9ebRLIAnv7bjXABTwcsoFlNjXVfjly6a1JgepnjWak(3xwY0c)e4BHotprWVe(wS4GP)Tgnmy(GG6mO1zxFzqI(9Teb8WaYFRdsI1sTw5ulHewlL1kLditprvcCdiiQZUwK5emF8rTMQLYAPSwrkfD2pfrTdi71AQwrMtW8Xvbdcz)0ddoisfijd9rTTsTw5vRPAfzobZhxXHGDuBKpyOcKKH(O2wPwlXvRPAfzobZhxDjGOrND91GAs2gQcKKH(O2wPwlXvlf1siH1kYCcMpUIdb7O2iFWqfijd9rTTsTw5vlHewBhA3C6ajzOpQT1AfzobZhxXHGDuBKpyOcKKH(OwkQLIVLZK43A0WG5dcQZGwND9Lbj63)(YsEY5tGVf6m9eb)s4BbIdranoy6FlItj7QfoQ9AWAhgicwB2R9AWATsG5eVd621(QbOBxRrKTOO4Gt8B5mj(TgjWCI3bDBDaq3(Bjc4HbK)wuwRuoGm9evhKe1a(bNA2OwIvlL1YIdMUkyqi7NEyWbrkusuaCO(GKyTT8AfPu0z)ue1oGSxlf1sSAPSwwCW0vGiFn0z4OcLefahQpijwBlVwrkfD2pLJIiNzawlf1sSAzXbtxDjGOrND91GAs2gQqjrbWH6dsI12AThh24PaHJJDbwReRL4uYUAPOwt1szTs5aY0tu1WsrDAGocwlHewlL1ksPOZ(PiQDazVwt1gao2ZWgvCiyh1qVdD41wHotprWAPOwkQ1uThh24PaHJJDbwR8RvEe33Ifhm9V1ibMt8oOBRda62)7ll5jZNaFl0z6jc(LW3Ifhm9VLGNtnloy66jCCFRjCCANjXVLGNcGjFW0h)7ll5jVpb(wOZ0te8lHVLiGhgq(BXIdkf1OJKqCuR8PwRuoGm9evCI6JdB80IeWVV14cO4(YsMVfloy6FlbpNAwCW01t44(wt440otIFloX)9LL8iOpb(wOZ0te8lHVLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9eb)wS4GP)Te8CQzXbtxpHJ7BnHJt7mj(TA4Gm92)7ll5jB(e4BHotprWVe(wIaEya5VLuoGm9evnSuuNgOJG1sTw5uRPALYbKPNOQdhnq3wNgOJrTMQ9L1szTIuk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotprWAP4BXIdM(3sWZPMfhmD9eoUV1eooTZK43Qdhnq3wNgOJX)(YsEe3NaFl0z6jc(LW3seWddi)TKYbKPNOQHLI60aDeSwQ1kNAnv7lRLYAfPu0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEIG1sX3Ifhm9VLGNtnloy66jCCFRjCCANjXVvAGog)7ll5j7(e4BHotprWVe(wIaEya5V1lRLYAfPu0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEIG1sX3Ifhm9VLGNtnloy66jCCFRjCCANjXVLiZjy(4J)9LL8EvFc8TqNPNi4xcFlrapmG83skhqMEIQo05PMgi8APwRCQ1uTVSwkRvKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwlfFlwCW0)wcEo1S4GPRNWX9TMWXPDMe)wrE8bt)FFzjVwWNaFl0z6jc(LW3seWddi)TKYbKPNOQdDEQPbcVwQ1ktTMQ9L1szTIuk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotprWAP4BXIdM(3sWZPMfhmD9eoUV1eooTZK43QdDEQPbc)F)7BzeOijP57tGVSK5tGVfloy6FloeSJAOF4CII7BHotprWVe(3xwY7tGVfloy6FRbajz6AoeSJ6otcNqo(wOZ0te8lH)9Lfb9jW3Ifhm9VLi9wuGa1KSZABK8BHotprWVe(3xwYMpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(T4e1hh24PfjGFFlqSZaZ7Brq)7llI7tGVf6m9eb)s4BLgFRah49TyXbt)BjLditpXVLuo0otIFluAQne33ce7mW8(wYqC)7llz3NaFl0z6jc(LW3kn(wd8(wS4GP)TKYbKPN43skhANjXVLrGgaZPgLMFlrapmG83IYAdah7zyJQb0OjD94YGuHotprWAnvlL1ksPOZ(PKI(10oQLqcRvKsrN9t5OiYzgG1siH1ksheaEkoeSJAJibH2TvOZ0teSwkQLIVLuEcGACoWVLC(ws5ja(TK5FFz9Q(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5q7mj(TAyPOonqhb)wIaEya5VfloOuuJoscXrTYNATs5aY0tuXjQpoSXtlsa)(ws5jaQX5a)wY5BjLNa43sM)9Lvl4tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43soFlPCODMe)wDOZtnnq4)7lRw4NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wnCqMEB94ybr6dsIFlqSZaZ7B1c)3xwYiNpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(T45d3EOhTDHwK5emF8X3ce7mW8(wY5FFzjJmFc8TqNPNi4xcFR04Bf4aVVfloy6FlPCaz6j(TKYH2zs8BfdnjlPgeNCBDpd9Lh53ce7mW8(we3)(Ysg59jW3cDMEIGFj8TsJVvGd8(wS4GP)TKYbKPN43skhANjXVvm0KSKAqCYT19m0rA8TaXodmVVfX9VVSKHG(e4BHotprWVe(wPX3kWbEFlwCW0)ws5aY0t8BjLdTZK43kgAswsnio526EgA24BbIDgyEFl5jN)9LLmYMpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TiZtBeOarq9LhPMU93ce7mW8(wTG)9LLme3NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wK5Pjzj1G4KBR7zOV8i)wGyNbM33sg58VVSKr29jW3cDMEIGFj8TsJVvGd8(wS4GP)TKYbKPN43skhANjXVfzEAswsnio526EgA24BbIDgyEFlziU)9LLmVQpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TydnjlPgeNCBDpd9Lh53seWddi)TePdcapfhc2rTrKGq72FlP8ea14CGFlzKZ3skpbWVfbjN)9LLmTGpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TydnjlPgeNCBDpd9Lh53ce7mW8(wYto)7llzAHFc8TqNPNi4xcFR04Bf4aVVfloy6FlPCaz6j(TKYH2zs8BXgAswsnio526EgAY8(wGyNbM33sEY5FFzjp58jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Bjp5uBlsTuwlXvBlVwr6GaWtXHGDuBeji0UTcDMEIG1sX3skhANjXVvKgAswsnio526Eg6lpY)9LL8K5tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43I4QLy1kp5uBlVwkRvKsrN9t5q7Mt3zSwcjSwkRvKoia8uCiyh1grccTBRqNPNiyTMQLfhukQrhjH4O2wRvkhqMEIkor9XHnEArc4xTuulf1sSALH4QTLxlL1ksPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uTS4Gsrn6ijeh1kFQ1kLditprfNO(4WgpTib8Rwk(ws5q7mj(TU8i1KSKAqCYT19m0SX)(YsEY7tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43sEYP2wKAPS2wqTT8AfPdcapfhc2rTrKGq72k0z6jcwlfFlPCODMe)wxEKAswsnio526Eg6in(3xwYJG(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TKDYP2wKAPSwsECy0wlLNayTT8ALroYPwk(wIaEya5VLiLIo7NYH2nNUZ43skhANjXVfnhbBJAs2zTH4(3xwYt28jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8B1cjUABrQLYAj5XHrBTuEcG12YRvg5iNAP4Bjc4HbK)wIuk6SFkIAhq2)ws5q7mj(TO5iyButYoRne3)(YsEe3NaFl0z6jc(LW3kn(wd8(wS4GP)TKYbKPN43skpbWVvlqo12IulL1sYJdJ2AP8eaRTLxRmYro1sX3seWddi)TKYbKPNOIMJGTrnj7S2qC1sTw58TKYH2zs8BrZrW2OMKDwBiU)9LL8KDFc8TqNPNi4xcFR04Bf4aVVfloy6FlPCaz6j(TKYH2zs8BXgAsOdjbi1KSZAdX9TaXodmVVLme3)(YsEVQpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TU8i1KSKArdh244BbIDgyEFl59VVSKxl4tGVf6m9eb)s4BLgFRah49TyXbt)BjLditpXVLuo0otIFlor9LhPMKLulA4WghFlqSZaZ7BjV)9LL8AHFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wYuBlVwkRfBXaqddeuHKgTdKN6maD2fyTesyTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTuw7Xt0pfhc2rnkAsf6m9ebRLqcR9L1ksPOZ(PiQDazVwkQ1uTuw7lRvKsrN9t5OiYzgG1siH1YIdkf1OJKqCul1ALPwcjS2aWXEg2OAanAsxpUmivOZ0teSwkQ1uTVSwrkfD2pLu0VM2rTuulfFlPCODMe)wD4Ob6260aDm(3xweKC(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TWwma0WabvKSGPdupAq80KadOOwcjSwSfdanmqqL9KbH8LXqtZG2yTesyTylgaAyGGk7jdc5lJHMeb55eMETesyTylgaAyGGkqoiImtxdIcI0gaxGdb6cSwcjSwSfdanmqqf0hIa4y6jQBXaSFaKAqukuG1siH1ITyaOHbcQgjWCI3bDBDaq3UwcjSwSfdanmqq1aWPNzcQzs8AApUAjKWAXwma0WabvpmrOJXq3J0bRLqcRfBXaqddeu1NmjQZUMMVBIFlPCODMe)wSHoDnWa)3xweKmFc8TyXbt)BrcJidnKKTXVf6m9eb)s4FFzrqY7tGVf6m9eb)s4Bjc4HbK)wJeysdDqL0CYhCI6roLI(PqNPNiyTesyTJeysdDqLbW4aMOgdaJdMUcDMEIGFlwCW0)w9joAeb3V)9LfbrqFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAfPdcapfhc2rTrKGq72k0z6jcwRPALYbKPNOINpC7HE02fArMtW8Xh1AQwwCqPOgDKeIJABTwPCaz6jQ4e1hh24PfjGFFlwCW0)wbGJ6SRnYhm(3xweKS5tGVf6m9eb)s4Bjc4HbK)wVSwPCaz6jQmc0ayo1O0SwQ1ktTMQnaCSNHnQaHdb0ycDoARfjjj7Gk0z6jc(TyXbt)B1JCC058(3xweeX9jW3cDMEIGFj8Teb8WaYFRxwRuoGm9evgbAamNAuAwl1ALPwt1(YAdah7zyJkq4qanMqNJ2ArssYoOcDMEIG1AQwkR9L1ksPOZ(PKI(10oQLqcRvkhqMEIQoC0aDBDAGog1sX3Ifhm9Vfhc2rn9Kh3)(YIGKDFc8TqNPNi4xcFlrapmG836L1kLditprLrGgaZPgLM1sTwzQ1uTVS2aWXEg2OceoeqJj05OTwKKKSdQqNPNiyTMQvKsrN9tjf9RPDuRPAFzTs5aY0tu1HJgOBRtd0X4BXIdM(3IegrgdD21xgKOF)7llc6v9jW3cDMEIGFj8Teb8WaYFlPCaz6jQmc0ayo1O0SwQ1kZ3Ifhm9Vfknf8bt)F)7BXj(jWxwY8jW3cDMEIGFj8Teb8WaYFRaWXEg2OceoeqJj05OTwKKKSdQqNPNiyTMQvK5emFCfnqVRbHdb0ycDoARfjjj7GQazW21AQwAGExbchcOXe6C0wlsss2b19ihNcmF8AnvlL1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8APOwt1kYCcMpU6sarJo76Rb1KSnufijd9rTuRvo1AQwkRLgO3vCiyh1IgoSr14ybr12k1ALYbKPNOItuF5rQjzj1IgoSXrTMQLYAPS2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxfaoQZU2iFWqfijd9rTTsTwBbyTMQvK5emFCfhc2rTr(GHkqsg6JALFTs5aY0tuD5rQjzj1G4KBR7zOzJAPOwcjSwkR9L1E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4koeSJAJ8bdvGKm0h1k)ALYbKPNO6YJutYsQbXj3w3ZqZg1srTesyTImNG5JR4qWoQnYhmubsYqFuBRuR1wawlf1sX3Ifhm9VvpYXrNZ7FFzjVpb(wOZ0te8lHVLiGhgq(BrzTbGJ9mSrfiCiGgtOZrBTijjzhuHotprWAnvRiZjy(4kAGExdchcOXe6C0wlsss2bvbYGTR1uT0a9UceoeqJj05OTwKKKSdQ7WavG5JxRPAncuQ2waQKr1JCC058QLIAjKWAPS2aWXEg2OceoeqJj05OTwKKKSdQqNPNiyTMQ9GKyTuRvo1sX3Ifhm9VvhgOMEYJ7FFzrqFc8TqNPNi4xcFlrapmG83kaCSNHnQSd4y2wdfqXevOZ0teSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwcso1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYPwt1szT0a9UIdb7Ow0WHnQghliQ2wPwRuoGm9evCI6lpsnjlPw0WHnoQ1uTuwlL1E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4QaWrD21g5dgQajzOpQTvQ1AlaR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlPgeNCBDpdnBulf1siH1szTVS2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxXHGDuBKpyOcKKH(Ow5xRuoGm9evxEKAswsnio526EgA2OwkQLqcRvK5emFCfhc2rTr(GHkqsg6JABLAT2cWAPOwk(wS4GP)T6rooTNs5)9LLS5tGVf6m9eb)s4Bjc4HbK)wbGJ9mSrLDahZ2AOakMOcDMEIG1AQwrMtW8XvCiyh1g5dgQajzOpQLATYPwt1szTuwlL1kYCcMpU6sarJo76Rb1KSnufijd9rTYVwPCaz6jQydnjlPgeNCBDpd9LhzTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSK6XXcIQLIAjKWAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYPwt1sd07koeSJArdh2OACSGOABLATs5aY0tuXjQV8i1KSKArdh24OwkQLIAnvlnqVRcah1zxBKpyOaZhVwk(wS4GP)T6rooTNs5)9LfX9jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlrdd9VLmFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rDdhKP3wnowquTTwRmexTMQvK5emFCvWGq2p9WGdIubsYqFuBRuRvkhqMEIQgoitVTECSGi9bjXAjwTOKOa4q9bjXAnvRiZjy(4Qlben6SRVgutY2qvGKm0h12k1ALYbKPNOQHdY0BRhhlisFqsSwIvlkjkaouFqsSwIvlloy6QGbHSF6HbhePqjrbWH6dsI1AQwrMtW8XvCiyh1g5dgQajzOpQTvQ1kLditprvdhKP3wpowqK(GKyTeRwusuaCO(GKyTeRwwCW0vbdcz)0ddoisHsIcGd1hKeRLy1YIdMU6sarJo76Rb1KSnuHsIcGd1hKe)3xwYUpb(wOZ0te8lHVfloy6FloeSJAs4yaN44BjAyO)TK5Bjc4HbK)wIuk6SFkPOFnTJAnvBa4ypdBuXHGDud9o0HxBf6m9ebR1uT0a9UIdb7OUHdY0BRghliQ2wRvgIRwt1kYCcMpU6sarJo76Rb1KSnufijd9rTTsTwPCaz6jQA4Gm926XXcI0hKeRLy1IsIcGd1hKeR1uTImNG5JR4qWoQnYhmubsYqFuBRuRvkhqMEIQgoitVTECSGi9bjXAjwTOKOa4q9bjXAjwTS4GPRUeq0OZU(AqnjBdvOKOa4q9bjX)9L1R6tGVf6m9eb)s4Bjc4HbK)wIuk6SFkPOFnTJAnv7Xt0pfhc2rnkAsf6m9ebR1uThKeRT1ALro1AQwrMtW8XvKWiYyOZU(YGe9tfijd9rTMQLgO3vIjYHGhh0TvJJfevBR1sqFlwCW0)wCiyh10tEC)7lRwWNaFl0z6jc(LW3Ifhm9V1ibMt8oOBRda62FlrapmG83kaCSNHnQgqJM01Jldsf6m9ebR1uTgbkvBlavYOqPPGpy6FlNjXV1ibMt8oOBRda62)7lRw4NaFl0z6jc(LW3seWddi)Tcah7zyJQb0OjD94YGuHotprWAnvRrGs12cqLmkuAk4dM(3Ifhm9V1LaIgD21xdQjzB4)(Ysg58jW3cDMEIGFj8Teb8WaYFRaWXEg2OAanAsxpUmivOZ0teSwt1szTgbkvBlavYOqPPGpy61siH1AeOuTTaujJ6sarJo76Rb1KSnSwk(wS4GP)T4qWoQnYhm(3xwYiZNaFl0z6jc(LW3seWddi)Tcah7zyJkoeSJAO3Ho8ARqNPNiyTMQvK5emFC1LaIgD21xdQjzBOkqsg6JABLATYiNAnvRiZjy(4koeSJAJ8bdvGKm0h12k1ALH4(wS4GP)TiHrKXqND9Lbj63)(Ysg59jW3cDMEIGFj8Teb8WaYFlrMtW8XvCiyh1g5dgQajzOpQTvQ12cQ1uTImNG5JRUeq0OZU(AqnjBdvbsYqFuBRuRTfuRPAPSwAGExXHGDulA4WgvJJfevBRuRvkhqMEIkor9LhPMKLulA4Wgh1AQwkRLYApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCva4Oo7AJ8bdvGKm0h12k1ATfG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1sC1srTesyTuw7lR94j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1sC1srTesyTImNG5JR4qWoQnYhmubsYqFuBRuR1wawlf1sX3Ifhm9VfjmImg6SRVmir)(3xwYqqFc8TqNPNi4xcFlrapmG836GKyTYVwcso1AQ2aWXEg2OAanAsxpUmivOZ0teSwt1ksPOZ(PKI(10oQ1uTgbkvBlavYOiHrKXqND9Lbj633Ifhm9Vfknf8bt)FFzjJS5tGVf6m9eb)s4Bjc4HbK)whKeRv(1sqYPwt1gao2ZWgvdOrt66XLbPcDMEIG1AQwAGExXHGDulA4WgvJJfevBRuRvkhqMEIkor9LhPMKLulA4Wgh1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYPwt1kYCcMpUIdb7O2iFWqfijd9rTTsTwBb43Ifhm9Vfknf8bt)FFzjdX9jW3cDMEIGFj8TyXbt)BHstbFW0)wq)WiamonS)TOb6D1aA0KUECzqQghliIknqVRgqJM01JldsfjlPECSGOVf0pmcaJtdjjrqiF43sMVLiGhgq(BDqsSw5xlbjNAnvBa4ypdBunGgnPRhxgKk0z6jcwRPAfzobZhxXHGDuBKpyOcKKH(OwQ1kNAnvlL1szTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1k)ALYbKPNOIn0KSKAqCYT19m0xEK1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYsQhhliQwkQLqcRLYAfzobZhxDjGOrND91GAs2gQcKKH(OwQ1kNAnvlnqVR4qWoQfnCyJQXXcIQTvQ1kLditprfNO(YJutYsQfnCyJJAPOwkQ1uT0a9UkaCuNDTr(GHcmF8AP4FFzjJS7tGVf6m9eb)s4Bjc4HbK)wImNG5JRUeq0OZU(AqnjBdvbsYqFuBR1IsIcGd1hKeR1uTuwlL1E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4QaWrD21g5dgQajzOpQTvQ1AlaR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlPgeNCBDpdnBulf1siH1szTVS2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxXHGDuBKpyOcKKH(Ow5xRuoGm9evxEKAswsnio526EgA2OwkQLqcRvK5emFCfhc2rTr(GHkqsg6JABLAT2cWAP4BXIdM(3kyqi7NEyWbr)7llzEvFc8TqNPNi4xcFlrapmG83sK5emFCfhc2rTr(GHkqsg6JABTwusuaCO(GKyTMQLYAPSwkRvK5emFC1LaIgD21xdQjzBOkqsg6JALFTs5aY0tuXgAswsnio526Eg6lpYAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizj1JJfevlf1siH1szTImNG5JRUeq0OZU(AqnjBdvbsYqFul1ALtTMQLgO3vCiyh1IgoSr14ybr12k1ALYbKPNOItuF5rQjzj1IgoSXrTuulf1AQwAGExfaoQZU2iFWqbMpETu8TyXbt)BfmiK9tpm4GO)9LLmTGpb(wOZ0te8lHVLiGhgq(BjYCcMpUIdb7O2iFWqfijd9rTuRvo1AQwkRLYAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kLditprfBOjzj1G4KBR7zOV8iR1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTuulHewlL1kYCcMpU6sarJo76Rb1KSnufijd9rTuRvo1AQwAGExXHGDulA4WgvJJfevBRuRvkhqMEIkor9LhPMKLulA4Wgh1srTuuRPAPb6Dva4Oo7AJ8bdfy(41sX3Ifhm9VfiYxdDgo(VVSKPf(jW3cDMEIGFj8TyXbt)BnsG5eVd626aGU93seWddi)TOSwAGExXHGDulA4WgvJJfevBRuRvkhqMEIkor9LhPMKLulA4Wgh1siH1AeOuTTaujJkyqi7NEyWbr1srTMQLYAPS2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxfaoQZU2iFWqfijd9rTTsTwBbyTMQvK5emFCfhc2rTr(GHkqsg6JALFTs5aY0tuD5rQjzj1G4KBR7zOzJAPOwcjSwkR9L1E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4koeSJAJ8bdvGKm0h1k)ALYbKPNO6YJutYsQbXj3w3ZqZg1srTesyTImNG5JR4qWoQnYhmubsYqFuBRuR1wawlfFlNjXV1ibMt8oOBRda62)7ll5jNpb(wOZ0te8lHVLiGhgq(BjsPOZ(PKI(10oQ1uTbGJ9mSrfhc2rn07qhETvOZ0teSwt1kYCcMpUIegrgdD21xgKOFQajzOpQTvQ1sCY5BXIdM(36sarJo76Rb1KSn8FFzjpz(e4BHotprWVe(wIaEya5VLiLIo7Nsk6xt7Owt1gao2ZWgvCiyh1qVdD41wHotprWAnvlnqVRiHrKXqND9Lbj6Nkqsg6JABLATYto1AQwrMtW8XvCiyh1g5dgQajzOpQTvQ1Ala)wS4GP)TUeq0OZU(AqnjBd)3xwYtEFc8TqNPNi4xcFlrapmG83IYAPb6Dfhc2rTOHdBunowquTTsTwPCaz6jQ4e1xEKAswsTOHdBCulHewRrGs12cqLmQGbHSF6Hbhevlf1AQwkRLYApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCva4Oo7AJ8bdvGKm0h12k1ATfG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kLditpr1LhPMKLudItUTUNHMnQLIAjKWAPS2xw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlPgeNCBDpdnBulf1siH1kYCcMpUIdb7O2iFWqfijd9rTTsTwBbyTu8TyXbt)BDjGOrND91GAs2g(VVSKhb9jW3cDMEIGFj8Teb8WaYFlkRLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xRuoGm9evSHMKLudItUTUNH(YJSwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr1srTesyTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5uRPAPb6Dfhc2rTOHdBunowquTTsTwPCaz6jQ4e1xEKAswsTOHdBCulf1srTMQLgO3vbGJ6SRnYhmuG5J)TyXbt)BXHGDuBKpy8VVSKNS5tGVf6m9eb)s4Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AnvlL1szTImNG5JRUeq0OZU(AqnjBdvbsYqFuR8RvEYPwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJksws94ybr1srTesyTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5uRPAPb6Dfhc2rTOHdBunowquTTsTwPCaz6jQ4e1xEKAswsTOHdBCulf1srTMQLYAfzobZhxXHGDuBKpyOcKKH(Ow5xRmYRwcjSwqKgO3vxciA0zxFnOMKTHkaJAP4BXIdM(3kaCuNDTr(GX)(YsEe3NaFl0z6jc(LW3seWddi)TezobZhxXHGDuNbTkqsg6JALFTexTesyTVS2JNOFkoeSJ6mOvOZ0te8BXIdM(3A0a7h0T1g5dg)7ll5j7(e4BHotprWVe(wIaEya5VLiLIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0teSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIQLATYMAnvRrGs12cqLmkoeSJ6mOR1uTS4Gsrn6ijeh12ATVQVfloy6FloeSJA6jpU)9LL8EvFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rTr(GHcWOwt1cI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1sTwzZ3Ifhm9Vfhc2rnnhbBJ)7ll51c(e4BHotprWVe(wIaEya5VLiLIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0teSwt1sd07koeSJAJ8bdfGrTMQLYAbZtfmiK9tpm4GivGKm0h1k)ALD1siH1cI0a9Ukyqi7NEyWbrAPathdMgoHxBfGrTuuRPAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOABTwztTMQLfhukQrhjH4OwQ1sqFlwCW0)wCiyh10tEC)7ll51c)e4BHotprWVe(wIaEya5VLiLIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0teSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIQLATe03Ifhm9Vfhc2rDg0)7llcsoFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rTr(GHcWOwt1cI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1sTw59TyXbt)BXHGDutZrW24)(YIGK5tGVf6m9eb)s4Bjc4HbK)wIuk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotprWAnvlnqVR4qWoQnYhmuag1AQwJaLQTfGk5PcgeY(PhgCquTMQLfhukQrhjH4Ow5xlb9TyXbt)BXHGDuJsAmZbm9)9LfbjVpb(wOZ0te8lHVLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOAPwRm1AQwwCqPOgDKeIJALFTe03Ifhm9Vfhc2rnkPXmhW0)3xweeb9jW3cDMEIGFj8Teb8WaYFlAGExbI81qNHJkaJAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6JABLAT0a9UYiWb6cuNDnj0bvKSK6XXcIQTLxlloy6koeSJA6jpofkjkaouFqsSwt1szTuw7Xt0pvGJ0zxGk0z6jcwRPAzXbLIA0rsioQT1ALn1srTesyTS4Gsrn6ijeh12ATexTuuRPAPS2xwBa4ypdBuXHGDutNK0CasI(PqNPNiyTesyThh24PAqEEnkdXvR8RLGiUAP4BXIdM(3YiWb6cuNDnj0b)3xweKS5tGVf6m9eb)s4Bjc4HbK)w0a9Uce5RHodhvag1AQwkRLYApEI(PcCKo7cuHotprWAnvlloOuuJoscXrTTwRSPwkQLqcRLfhukQrhjH4O2wRL4QLIAnvlL1(YAdah7zyJkoeSJA6KKMdqs0pf6m9ebRLqcR94WgpvdYZRrziUALFTeeXvlfFlwCW0)wCiyh10tEC)7llcI4(e4BXIdM(3AayGHNs5Vf6m9eb)s4FFzrqYUpb(wOZ0te8lHVLiGhgq(Brd07koeSJArdh2OACSGOALp1APSwwCqPOgDKeIJABrQvMAPOwt1gao2ZWgvCiyh10jjnhGKOFk0z6jcwRPApoSXt1G88AugIR2wRLGiUVfloy6FloeSJAAoc2g)3xwe0R6tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowq03Ifhm9Vfhc2rnnhbBJ)7llcQf8jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfevl1ALtTMQLYAfzobZhxXHGDuBKpyOcKKH(Ow5xRmexTesyTVSwkRvKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwlf1sX3Ifhm9Vfhc2rDg0)7llcQf(jW3cDMEIGFj8Teb8WaYFlkRnWEGJgMEI1siH1(YApOGiOBxlf1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYsQhhli6BXIdM(3YXRbd9HKg44(3xwYg58jW3cDMEIGFj8Teb8WaYFlAGExjMihcECq3wfilUAnvBa4ypdBuXHGDu3Wbz6TvOZ0teSwt1szTuw7Xt0pftAmHDOGpy6k0z6jcwRPAzXbLIA0rsioQT1ABb1srTesyTS4Gsrn6ijeh12ATexTu8TyXbt)BXHGDutchd4eh)7llzJmFc8TqNPNi4xcFlrapmG83IgO3vIjYHGhh0TvbYIRwt1E8e9tXHGDuJIMuHotprWAnvlisd07Qlben6SRVgutY2qfGrTMQLYApEI(PysJjSdf8btxHotprWAjKWAzXbLIA0rsioQT1ABH1sX3Ifhm9Vfhc2rnjCmGtC8VVSKnY7tGVf6m9eb)s4Bjc4HbK)w0a9Usmroe84GUTkqwC1AQ2JNOFkM0yc7qbFW0vOZ0teSwt1YIdkf1OJKqCuBR1kB(wS4GP)T4qWoQjHJbCIJ)9LLSHG(e4BHotprWVe(wIaEya5VfnqVR4qWoQfnCyJQXXcIQT1APb6Dfhc2rTOHdBurYsQhhli6BXIdM(3Idb7OgL0yMdy6)7llzJS5tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLupowquTMQ1iqPABbOsgfhc2rnnhbBJFlwCW0)wCiyh1OKgZCat)F)7BLgOJXNaFzjZNaFl0z6jc(LW3seWddi)Tcah7zyJkq4qanMqNJ2ArssYoOcDMEIG1AQwAGExbchcOXe6C0wlsss2b19ihNcW4BXIdM(3Qddutp5X9VVSK3NaFl0z6jc(LW3seWddi)Tcah7zyJk7aoMT1qbumrf6m9ebR1uTKSZkdXvR8RTfsCFlwCW0)w9ihN2tP8)(YIG(e4BHotprWVe(wotIFRrcmN4Dq3wha0T)wS4GP)TgjWCI3bDBDaq3(FFzjB(e4BXIdM(3ce5RHodh)wOZ0te8lH)9LfX9jW3cDMEIGFj8Teb8WaYFls2zLH4Qv(1kBKZ3Ifhm9VvWGq2p9WGdI(3xwYUpb(wS4GP)TiHrKXqND9Lbj633cDMEIGFj8VVSEvFc8TqNPNi4xcFlrapmG83IgO3vCiyh1g5dgkW8XR1uTImNG5JR4qWoQnYhmubsYqF8TyXbt)BnAG9d62AJ8bJ)9Lvl4tGVf6m9eb)s4Bjc4HbK)wImNG5JR4qWoQnYhmubYGTR1uT0a9UIdb7Ow0WHnQghliQ2wRLgO3vCiyh1IgoSrfjlPECSGOVfloy6FloeSJ6mO)3xwTWpb(wOZ0te8lHVLiGhgq(BjsPOZ(PKI(10oQ1uTImNG5JRiHrKXqND9Lbj6Nkqsg6JALFTTazZ3Ifhm9Vfhc2rn9Kh3)(Ysg58jW3Ifhm9V1LaIgD21xdQjzB43cDMEIGFj8VVSKrMpb(wS4GP)T4qWoQnYhm(wOZ0te8lH)9LLmY7tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7O2iFWqbMp(3Ifhm9Vva4Oo7AJ8bJ)9LLme0NaFl0z6jc(LW3Ifhm9VLrGd0fOo7AsOd(TaXHiGghm9VLS)aR91YwwTxw7OfdGOShSw2RfL8cU2wkeSJ1kHjpUAbbcOBx71G1sG8AzsSLETAFGoy(ulGpXXO2aWDOBxBlfc2XALTenPQ2xxV2wkeSJ1kBjAYAHJApEI(HGMx7dwRG93xTadS2xlBz1(aVgOx71G1sG8AzsSLETAFGoy(ulGpXXO2hSwOFyeagxTxdwBl1YQv0WUJtZRDK1(GVNZAhSuSw4P(wIaEya5V1lR94j6NIdb7OgfnPcDMEIG1AQwqKgO3vxciA0zxFnOMKTHkaJAnvlisd07Qlben6SRVgutY2qvGKm0h12k1APSwwCW0vCiyh10tECkusuaCO(GKyTT8APb6DLrGd0fOo7AsOdQizj1JJfevlf)7llzKnFc8TqNPNi4xcFlwCW0)wgboqxG6SRjHo43cehIaACW0)wVUETVw2YQTHh(7RwAe9AbgiyTGab0TR9AWAjqETSAFGoy(yETp475SwGbwl8Q9YAhTyaeL9G1YETOKxW12sHGDSwjm5Xvl0R9AWAF15RjXw61Q9b6G5J6Bjc4HbK)w0a9UIdb7O2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0h12k1APSwwCW0vCiyh10tECkusuaCO(GKyTT8APb6DLrGd0fOo7AsOdQizj1JJfevlf)7llziUpb(wOZ0te8lHVLiGhgq(BbMNkyqi7NEyWbrQajzOpQv(1sC1siH1cI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1k)ALZ3Ifhm9Vfhc2rn9Kh3)(Ysgz3NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)B1sZhU9OwjWrW2yT8v71G1IoyTzV2w61Q9Pb9Ada3HUDTxdwBlfc2XAL9MdY0Bx7eTrhKJ2FlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVR4qWoQnYhmubsYqFuBR1AlaR1uTbGJ9mSrfhc2rDdhKP3wHotprW)9LLmVQpb(wOZ0te8lHVfloy6FloeSJAAoc2g)wG4qeqJdM(3QLMpC7rTsGJGTXA5R2RbRfDWAZETxdw7RoFTAFGoy(u7td61gaUdD7AVgS2wkeSJ1k7nhKP3U2jAJoihT)wIaEya5VfnqVRcah1zxBKpyOamQ1uT0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmubsYqFuBRuR1wawRPAdah7zyJkoeSJ6goitVTcDMEIG)7llzAbFc8TqNPNi4xcFlrdd9VLmFlKJzBTOHHUg2)w0a9Usmroe84GUTw0WUJtfy(4MOKgO3vCiyh1g5dgkadcjKYxE8e9tLsXWiFWabnrjnqVRcah1zxBKpyOamiKqrMtW8XvO0uWhmDvGmyBkOGIVLiGhgq(BbI0a9U6sarJo76Rb1KSnubyuRPApEI(P4qWoQrrtQqNPNiyTMQLYAPb6DfiYxdDgoQaZhVwcjSwwCqPOgDKeIJAPwRm1srTMQfePb6D1LaIgD21xdQjzBOkqsg6JALFTS4GPR4qWoQjHJbCIdfkjkaouFqs8BXIdM(3Idb7OMeogWjo(3xwY0c)e4BHotprWVe(wIaEya5VfnqVRetKdbpoOBRghliQwQ1sd07kXe5qWJd62ksws94ybr1AQwrkfD2pLu0VM2X3Ifhm9Vfhc2rnjCmGtC8VVSKNC(e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVLOHH(3sMVLiGhgq(Brd07kXe5qWJd62QazXvRPAfzobZhxXHGDuBKpyOcKKH(Owt1szT0a9UkaCuNDTr(GHcWOwcjSwAGExXHGDuBKpyOamQLI)9LL8K5tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7Ow0WHnQghliQ2wPwRuoGm9evxEKAswsTOHdBC8TyXbt)BXHGDuNb9)(YsEY7tGVf6m9eb)s4Bjc4HbK)w0a9UkaCuNDTr(GHcWOwcjSws2zLH4Qv(1kdX9TyXbt)BXHGDutp5X9VVSKhb9jW3cDMEIGFj8TyXbt)BHstbFW0)wq)WiamonS)TizNvgIt(uBbe33c6hgbGXPHKKiiKp8BjZ3seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwAGExXHGDuBKpyOaZh)FFzjpzZNaFlwCW0)wCiyh10CeSn(TqNPNi4xc)7FFlbpfat(GPp(e4llz(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TK5Bjc4HbK)ws5aY0tu1WsrDAGocwl1ALtTMQ1iqPABbOsgfknf8btVwt1(YAPS2aWXEg2OAanAsxpUmivOZ0teSwcjS2aWXEg2O6qsJm4P(Hddf6m9ebRLIVLuo0otIFRgwkQtd0rW)9LL8(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TK5Bjc4HbK)ws5aY0tu1WsrDAGocwl1ALtTMQLgO3vCiyh1g5dgkW8XR1uTImNG5JR4qWoQnYhmubsYqFuRPAPS2aWXEg2OAanAsxpUmivOZ0teSwcjS2aWXEg2O6qsJm4P(Hddf6m9ebRLIVLuo0otIFRgwkQtd0rW)9Lfb9jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8BjZ3seWddi)TOb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlPECSGOAnv7lRLgO3vbWe1zxFnbIdfGrTMQTdTBoDGKm0h12k1APSwkRLKDUwjwlloy6koeSJA6jpoLihxTuuBlVwwCW0vCiyh10tECkusuaCO(GKyTu8TKYH2zs8B1Hop10aH)VVSKnFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)w0a9UIdb7OUHdY0BRghliQw5tTwziUAjKWAPS2aWXEg2OIdb7OMojP5aKe9tHotprWAnv7XHnEQgKNxJYqC12ATeeXvlfFlqCicOXbt)BjBbVgmQLRTdmNTRDCSGieS2goitVDTzul0RfLefahwBWUnw7d8AQvcjjnhGKOFFlPCODMe)wiPr(GbcQP5iyB8FFzrCFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wImNG5JR4qWoQnYhmubsYqFOrjnqXHGFlrapmG83sKoia8uCiyh1grccTB)TKYH2zs8BDqsud4hCQzJ)9LLS7tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43sK5emFCfhc2rTr(GHkqsg6JVLiGhgq(B9YAfPdcapfhc2rTrKGq72k0z6jc(TKYH2zs8BDqsud4hCQzJ)9L1R6tGVf6m9eb)s4BLgFlswYVfloy6FlPCaz6j(TKYH2zs8BDqsud4hCQzJVLiGhgq(BrzTImNG5JRUeq0OZU(AqnjBdvbsYqFuBlsTs5aY0tuDqsud4hCQzJAPO2wRvEY5BbIdranoy6FlzB89Cwlio5212sVwTag1EzTYtoduuBpJAjqETSVLuEcGFlrMtW8XvxciA0zxFnOMKTHQajzOp(3xwTGpb(wOZ0te8lHVvA8Tizj)wS4GP)TKYbKPN43skhANjXV1bjrnGFWPMn(wIaEya5VLiDqa4P4qWoQnIeeA3Uwt1ksheaEkoeSJAJibH2Tvb7evBR1sC1AQwSfdanmqq1ibMt8oOBRda621AQwrkfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPNi43cehIaACW0)wwqxG1(QbOBxlCu7aq0ulxRr(Grhyw7fqNi8QTNrTV(UDaz38AFW3ZzTJdkiQ2lR9AWAVNSwsOdCyTI2IjwlGFWzTpyT24vlxBd0UPw0ta7MAd2jQ2SxRrKGq72FlP8ea)wImNG5JRgjWCI3bDBDaq3wfijd9X)(YQf(jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8BjYCcMpU6sarJo76Rb1KSnufid2Uwt1kLditpr1bjrnGFWPMnQT1ALNC(wG4qeqJdM(3s2gFpN1cItUDTeiVwwTag1EzTYtoduuBpJABPx7BjLdTZK43QjNGq3wF5r(VVSKroFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wuwRrGs12cqLmQGbHSF6HbhevlHewRrGs12cqL8ubdcz)0ddoiQwcjSwJaLQTfGkcsfmiK9tpm4GOAPOwt1YIdMUkyqi7NEyWbrQdsI6b0fyTTwRTaurYswBlVwzZ3cehIaACW0)wVAgeY(vRLbhevlyIJA98QfssIGq(Wz7AnaUAbmQ9AWALcmDmyA4eETRfePb69AhzTWRwb71sJ1cc7DOayE1EzTGWHadV2RHVAFW3bwlF1EnyTYEWiVMALcmDmyA4eETRDCSGOVLuo0otIFRwuGXPbgiOEyWbr)7llzK5tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43IgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(41AQ2xwRuoGm9evTOaJtdmqq9WGdIQ1uTGinqVRcgeY(PhgCqKwkW0XGPHt41wbMp(3skhANjXVvcCdiiQZUwK5emF8X)(Ysg59jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Bfao2ZWgvCiyh1nCqMEBf6m9ebR1uTuwlL1ksPOZ(PiQDazVwt1kYCcMpUkyqi7NEyWbrQajzOpQT1ALYbKPNOQHdY0BRhhlisFqsSwkQLIVLuo0otIFRXXcI0nCqME7)9VVvh68utde(NaFzjZNaFl0z6jc(LW3Ifhm9Vfhc2rnjCmGtC8Tenm0)wY8Teb8WaYFlAGExjMihcECq3wfilU)9LL8(e4BXIdM(3Idb7OMEYJ7BHotprWVe(3xwe0NaFlwCW0)wCiyh10CeSn(TqNPNi4xc)7F)7BjfJbm9VSKNCKNmYPfiVw436Hdh62JVLSDl9QL1RtwV(j(ARLanyTqsJmUA7zu77goitV97AdSfdadeS2rsI1YaxsYhcwROHDBCOkZiyOJ1kdXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukJKuOkZiyOJ1k7i(AFr6sX4qWAFFb0jcpftluImNG5J)U2lR9TiZjy(4kMw8UwkLNKuOkZiyOJ1(Qi(AFr6sX4qWAFFb0jcpftluImNG5J)U2lR9TiZjy(4kMw8UwkLNKuOkZiyOJ12cj(AFr6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEIGVRLszKKcvzgbdDSwziiIV2xKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPNi47APugjPqvMrWqhRvgzdXx7lsxkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0te8DTukJKuOkZiyOJ1kdXr81(I0LIXHG1((4j6NsUVR9YAFF8e9tjxf6m9ebFxlLYijfQYmcg6yTYqCeFTViDPyCiyTVfPdcapLCFx7L1(wKoia8uYvHotprW31sPmssHQmJGHowR8KH4R9fPlfJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6jc(UwkLrskuLzLzY2T0RwwVoz96N4RTwc0G1cjnY4QTNrTV7Wrd0T1Pb6y8U2aBXaWabRDKKyTmWLK8HG1kAy3ghQYmcg6yTYq81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukpjPqvMrWqhRvEeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sPmssHQmJGHowlbr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kBi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XAjoIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwzhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31YxTYwVEeCTukJKuOkZiyOJ12cj(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XABHeFTViDPyCiyTVfPdcapLCFx7L1(wKoia8uYvHotprW31YxTYwVEeCTukJKuOkZiyOJ1kJ8i(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLNKuOkZiyOJ1kdXr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1ktlG4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRvMwiXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8KH4R9fPlfJdbR99Xt0pLCFx7L1((4j6NsUk0z6jc(UwkLrskuLzem0XALNSH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APuEssHQmJGHowR8KneFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlF1kB96rW1sPmssHQmJGHowR8KDeFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlF1kB96rW1sPmssHQmJGHowR8EveFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sPmssHQmRmt2ULE1Y61jRx)eFT1sGgSwiPrgxT9mQ9DKhFW0FxBGTyayGG1ossSwg4ss(qWAfnSBJdvzgbdDSwzi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLszKKcvzgbdDSwzi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowlbr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1sCeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sPmssHQmJGHowRSJ4R9fPlfJdbR99Xt0pLCFx7L1((4j6NsUk0z6jc(UwkLrskuLzem0XALroeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sPmssHQmJGHowRmTqIV2xKUumoeS23hpr)uY9DTxw77JNOFk5QqNPNi47APugjPqvMrWqhRvMwiXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8KdXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukJKuOkZiyOJ1kp5q81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kpzi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLszKKcvzgbdDSw5jdXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8KhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8iiIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzwzMSDl9QL1RtwV(j(ARLanyTqsJmUA7zu770aDmExBGTyayGG1ossSwg4ss(qWAfnSBJdvzgbdDSwzi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowRmeeXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukJKuOkZiyOJ1kJSJ4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47A5RwzRxpcUwkLrskuLzem0XAL5vr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DT8vRS1RhbxlLYijfQYmcg6yTY0ci(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLszKKcvzwzMSDl9QL1RtwV(j(ARLanyTqsJmUA7zu7BqSZaZ7DTb2IbGbcw7ijXAzGlj5dbRv0WUnouLzem0XALhXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukpjPqvMrWqhRv2q81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kJSH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRvgzhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowRmTaIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSw5jhIV2xKUumoeSwli5lQD02pwYAF9rTxwlbdW1ccLchW0RnnWGVmQLsjsrTukJKuOkZiyOJ1kp5q81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kpcI4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47A5RwzRxpcUwkLrskuLzem0XALNSH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRvEehXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8KDeFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTY7vr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kVwaXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmRmt2ULE1Y61jRx)eFT1sGgSwiPrgxT9mQ9TrGIKKMV31gylgagiyTJKeRLbUKKpeSwrd724qvMrWqhRv2r81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1k7i(AFr6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEIGVRLszKKcvzgbdDSw5jhIV2xKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPNi47APugjPqvMrWqhRvEYq81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kpzi(AFr6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEIGVRLszKKcvzgbdDSw5jpIV2xKUumoeS23I0bbGNsUVR9YAFlsheaEk5QqNPNi47APugjPqvMrWqhRvETqIV2xKUumoeS23hpr)uY9DTxw77JNOFk5QqNPNi47APuEssHQmJGHowR8AHeFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTeK8i(AFr6sX4qWAFpsGjn0bvY9DTxw77rcmPHoOsUk0z6jc(UwkLrskuLzem0XAji5r81(I0LIXHG1(EKatAOdQK77AVS23JeysdDqLCvOZ0te8DT8vRS1RhbxlLYijfQYmcg6yTeebr81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1sqeeXx7lsxkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0te8DTukJKuOkZiyOJ1sqYgIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLVALTE9i4APugjPqvMrWqhRLGioIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwcs2r81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZkZKTBPxTSEDY61pXxBTeObRfsAKXvBpJAFlYCcMp(4DTb2IbGbcw7ijXAzGlj5dbRv0WUnouLzem0XALH4R9fPlfJdbR99Xt0pLCFx7L1((4j6NsUk0z6jc(UwkLNKuOkZiyOJ1kdXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowR8i(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLs5jjfQYmcg6yTYJ4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRLGi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLs5jjfQYmcg6yTeeXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowRSH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRL4i(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALDeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sP8KKcvzgbdDS2xfXx7lsxkghcw77rcmPHoOsUVR9YAFpsGjn0bvYvHotprW31sP8KKcvzgbdDS2wiXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukpjPqvMrWqhRvg5q81(I0LIXHG1((4j6NsUVR9YAFF8e9tjxf6m9ebFxlLYtskuLzem0XALrEeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sP8KKcvzgbdDSwziiIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwzKneFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTYqCeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sPmssHQmJGHowRmYoIV2xKUumoeS23hpr)uY9DTxw77JNOFk5QqNPNi47APugjPqvMrWqhRvEYH4R9fPlfJdbR99Xt0pLCFx7L1((4j6NsUk0z6jc(UwkLrskuLzLzY2T0RwwVoz96N4RTwc0G1cjnY4QTNrTV5eFxBGTyayGG1ossSwg4ss(qWAfnSBJdvzgbdDSwzi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLs5jjfQYmcg6yTYq81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1kpIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLs5jjfQYmcg6yTeeXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukpjPqvMrWqhRLGi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALneFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTehXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowRSJ4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhR9vr81(I0LIXHG1((4j6NsUVR9YAFF8e9tjxf6m9ebFxlLYijfQYmcg6yTTaIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDS2wiXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowRmYH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRvgzi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALrEeFTViDPyCiyTVpEI(PK77AVS23hpr)uYvHotprW31sP8KKcvzgbdDSwziiIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwzKneFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTYqCeFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTYi7i(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLs5jjfQYmcg6yTY0cj(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLs5jjfQYmcg6yTYtoeFTViDPyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9ebFxlLYijfQYmcg6yTYtgIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSw5jpIV2xKUumoeS23hpr)uY9DTxw77JNOFk5QqNPNi47APuEssHQmJGHowR8ioIV2xKUumoeS23hpr)uY9DTxw77JNOFk5QqNPNi47A5RwzRxpcUwkLrskuLzem0XALNSJ4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRvEVkIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSw51ci(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALxlK4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APugjPqvMrWqhRLGKdXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowlbjdXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmJGHowlbjpIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwcIGi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLszKKcvzgbdDSwcIGi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XAjizdXx7lsxkghcw77JNOFk5(U2lR99Xt0pLCvOZ0te8DTukJKuOkZiyOJ1sqYgIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwcs2r81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1sqTaIV2xKUumoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEIGVRLszKKcvzgbdDSwzJCi(AFr6sX4qWAFF8e9tj331EzTVpEI(PKRcDMEIGVRLszKKcvzgbdDSwzJCi(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLrskuLzem0XALnYq81(I0LIXHG1((4j6NsUVR9YAFF8e9tjxf6m9ebFxlLYtskuLzem0XALnYJ4R9fPlfJdbR99Xt0pLCFx7L1((4j6NsUk0z6jc(UwkLrskuLzLzY2T0RwwVoz96N4RTwc0G1cjnY4QTNrTVf8uam5dM(4DTb2IbGbcw7ijXAzGlj5dbRv0WUnouLzem0XALH4R9fPlfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPNi47APuEssHQmJGHowR8i(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(UwkLNKuOkZiyOJ1sqeFTViDPyCiyTwqYxu7OTFSK1(6JAVSwcgGRfekfoGPxBAGbFzulLsKIAPugjPqvMrWqhRv2q81(I0LIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0te8DTukJKuOkZiyOJ1k7i(AFr6sX4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEIGVRLVALTE9i4APugjPqvMrWqhRTfq81(I0LIXHG1((cOteEkMwOezobZh)DTxw7BrMtW8XvmT4DTukJKuOkZiyOJ12ci(AFr6sX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6jc(Uw(Qv261JGRLszKKcvzgbdDSwzKhXx7lsxkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotprW31sPmssHQmRm71rAKXHG1kJCQLfhm9ANWXnuLzFlg4AY4BzbjbM8bt)fb3VVLrKD4e)wVYRuBlJTXABPqWowM9kVsTTeGnW4QLGKX8ALNCKNmLzLzVYRu7lAy3gheFz2R8k12IuRS)aR9ABaf8Swli5lQTHDWj0TRn71kAy3XzTq)Wiamoy61c9XHmyTzV23c2f4uZIdM(Bvz2R8k12Iu7lAy3gRLdb7Og6DOdV21EzTCiyh1nCqME7APeE16OumQ9b9R2jukwlpQLdb7OUHdY0BtHQm7vELABrQv2R0FF1kBjnf8H1c9ABPxpzRABrbgxT0OGbgyTTtG3bwBcC1M9Ad2TXAzhSwpVAbgq3U2wkeSJ1kBjPXmhW0vLzVYRuBlsTTeylkW4Q1iGzaV21EzTadS2wkeSJ1(A5dgVh1I9okoOuSwrMtW8XRLMhiyTPx7lK96vxl27O4gQYSYmwCW0hkJafjjnFeJQe5qWoQH(HZjkUYmwCW0hkJafjjnFeJQe5qWoQ7mjCc5OmJfhm9HYiqrssZhXOkrr6TOabQjzN12izzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQCI6JdB80IeWpZtdQboWZCqSZaZJkbvMXIdM(qzeOijP5JyuLOuoGm9en3zsKkkn1gIZ80GAGd8mhe7mW8OkdXvMXIdM(qzeOijP5JyuLOuoGm9en3zsKQrGgaZPgLMMNguh4zoStLYaWXEg2OAanAsxpUminrPiLIo7Nsk6xt7GqcfPu0z)uokICMbiHeksheaEkoeSJAJibH2TPGcZLYtaKQmMlLNaOgNdKQCkZyXbtFOmcuKK08rmQsukhqMEIM7mjsTHLI60aDe080G6apZHDQS4Gsrn6ijehYNQuoGm9evCI6JdB80IeWpZLYtaKQmMlLNaOgNdKQCkZyXbtFOmcuKK08rmQsukhqMEIM7mjsTdDEQPbc380G6apZLYtaKQCkZyXbtFOmcuKK08rmQsukhqMEIM7mjsTHdY0BRhhlisFqs080GAGd8mhe7mW8O2clZyXbtFOmcuKK08rmQsukhqMEIM7mjsLNpC7HE02fArMtW8XhMNgudCGN5GyNbMhv5uMXIdM(qzeOijP5JyuLOuoGm9en3zsKAm0KSKAqCYT19m0xEKMNgudCGN5GyNbMhvIRmJfhm9HYiqrssZhXOkrPCaz6jAUZKi1yOjzj1G4KBR7zOJ0W80GAGd8mhe7mW8OsCLzS4GPpugbkssA(igvjkLditprZDMePgdnjlPgeNCBDpdnByEAqnWbEMdIDgyEuLNCkZyXbtFOmcuKK08rmQsukhqMEIM7mjsLmpTrGceb1xEKA62MNgudCGN5GyNbMh1wqzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQK5Pjzj1G4KBR7zOV8inpnOg4apZbXodmpQYiNYmwCW0hkJafjjnFeJQeLYbKPNO5otIujZttYsQbXj3w3ZqZgMNgudCGN5GyNbMhvziUYmwCW0hkJafjjnFeJQeLYbKPNO5otIuzdnjlPgeNCBDpd9LhP5Pb1ah4zoStvKoia8uCiyh1grccTBBUuEcGuji5yUuEcGACoqQYiNYmwCW0hkJafjjnFeJQeLYbKPNO5otIuzdnjlPgeNCBDpd9LhP5Pb1ah4zoi2zG5rvEYPmJfhm9HYiqrssZhXOkrPCaz6jAUZKiv2qtYsQbXj3w3ZqtMN5Pb1ah4zoi2zG5rvEYPmJfhm9HYiqrssZhXOkrPCaz6jAUZKi1in0KSKAqCYT19m0xEKMNguh4zUuEcGuLNCArOK4A5I0bbGNIdb7O2isqODBkkZyXbtFOmcuKK08rmQsukhqMEIM7mjs9YJutYsQbXj3w3ZqZgMNguh4zUuEcGujoIjp50YPuKsrN9t5q7Mt3zKqcPuKoia8uCiyh1grccTBBIfhukQrhjH4OvPCaz6jQ4e1hh24PfjGFuqbXKH4A5uksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TnXIdkf1OJKqCiFQs5aY0tuXjQpoSXtlsa)OOmJfhm9HYiqrssZhXOkrPCaz6jAUZKi1lpsnjlPgeNCBDpdDKgMNguh4zUuEcGuLNCArOSf0YfPdcapfhc2rTrKGq72uuMXIdM(qzeOijP5JyuLOuoGm9en3zsKknhbBJAs2zTH4mpnOoWZCyNQiLIo7NYH2nNUZO5s5jasv2jNwekj5XHrBTuEcGTCzKJCOOmJfhm9HYiqrssZhXOkrPCaz6jAUZKivAoc2g1KSZAdXzEAqDGN5WovrkfD2pfrTdi7MlLNai1wiX1IqjjpomARLYtaSLlJCKdfLzS4GPpugbkssA(igvjkLditprZDMePsZrW2OMKDwBioZtdQd8mh2PkLditprfnhbBJAs2zTH4OkhZLYtaKAlqoTiusYJdJ2AP8eaB5Yih5qrzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQSHMe6qsasnj7S2qCMNgudCGN5GyNbMhvziUYmwCW0hkJafjjnFeJQeLYbKPNO5otIuV8i1KSKArdh24W80GAGd8mhe7mW8OkVYmwCW0hkJafjjnFeJQeLYbKPNO5otIu5e1xEKAswsTOHdBCyEAqnWbEMdIDgyEuLxzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQD4Ob6260aDmmpnOoWZCP8eaPktlNsSfdanmqqfsA0oqEQZa0zxGesiLhpr)ubGJ6SRnYhmmr5Xt0pfhc2rnkAscj8LIuk6SFkIAhq2PWeLVuKsrN9t5OiYzgGesiloOuuJoscXbvziKWaWXEg2OAanAsxpUmiPW0lfPu0z)usr)AAhuqrzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQSHoDnWanpnOoWZCP8eaPITyaOHbcQizbthOE0G4PjbgqbHeITyaOHbcQSNmiKVmgAAg0gjKqSfdanmqqL9KbH8LXqtIG8CctNqcXwma0WabvGCqezMUgefePnaUahc0fiHeITyaOHbcQG(qeahtprDlgG9dGudIsHcKqcXwma0WabvJeyoX7GUToaOBtiHylgaAyGGQbGtpZeuZK410ECesi2IbGggiO6HjcDmg6EKoiHeITyaOHbcQ6tMe1zxtZ3nXYmwCW0hkJafjjnFeJQejHrKHgsY2yzgloy6dLrGIKKMpIrvI9joAeb3pZHDQJeysdDqL0CYhCI6roLI(riHJeysdDqLbW4aMOgdaJdMEzgloy6dLrGIKKMpIrvIbGJ6SRnYhmmh2PksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TnjsheaEkoeSJAJibH2TnjLditprfpF42d9OTl0ImNG5JpmXIdkf1OJKqC0QuoGm9evCI6JdB80IeWVYmwCW0hkJafjjnFeJQe7roo6CEMd7uFPuoGm9evgbAamNAuAsvgtbGJ9mSrfiCiGgtOZrBTijjzhSmJfhm9HYiqrssZhXOkroeSJA6jpoZHDQVukhqMEIkJanaMtnknPkJPxgao2ZWgvGWHaAmHohT1IKKKDqtu(srkfD2pLu0VM2bHekLditprvhoAGUTonqhdkkZyXbtFOmcuKK08rmQsKegrgdD21xgKOFMd7uFPuoGm9evgbAamNAuAsvgtVmaCSNHnQaHdb0ycDoARfjjj7GMePu0z)usr)AAhMEPuoGm9evD4Ob6260aDmkZyXbtFOmcuKK08rmQseLMc(GPBoStvkhqMEIkJanaMtnknPktzwzgloy6dIrvIIeWpmgg4CwMXIdM(GyuLiWa1KSZABK0CyNkLhpr)uOpH2nh6iOjs2zLH4ALAlqoMizNvgIt(uLDehfesiLV84j6Nc9j0U5qhbnrYoRmexRuBbehfLzS4GPpigvjAKhmDZHDQ0a9UIdb7O2iFWqbyuMXIdM(GyuL4bjr9dhgMd7udah7zyJQdjnYGN6hommrd07kuYggyCW0vagMOuK5emFCfhc2rTr(GHkqgSnHesNJHPo0U50bsYqF0kvzJCOOmJfhm9bXOkXj0U5g6wuaqBs0pZHDQ0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFqmQsKMT1zxFbuq0WCyNknqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmuG5JBcePb6D1LaIgD21xdQjzBOcmF8YmwCW0heJQePXyGbrq32CyNknqVR4qWoQnYhmuagLzS4GPpigvjspZeu3bI2Md7uPb6Dfhc2rTr(GHcWOmJfhm9bXOkXomq6zMGMd7uPb6Dfhc2rTr(GHcWOmJfhm9bXOkr2f44cEQf8CAoStLgO3vCiyh1g5dgkaJYmwCW0heJQebgOgEi5WCyNknqVR4qWoQnYhmuagLzS4GPpigvjcmqn8qsZXEhfN2zsKQ9KbH8LXqtZG2O5WovAGExXHGDuBKpyOamiKqrMtW8XvCiyh1g5dgQajzOpKpvIJ4mbI0a9U6sarJo76Rb1KSnubyuMXIdM(GyuLiWa1Wdjn3zsKksA0oqEQZa0zxGMd7ufzobZhxXHGDuBKpyOcKKH(OvQYqCMezobZhxDjGOrND91GAs2gQcKKH(OvQYqCLzS4GPpigvjcmqn8qsZDMePcgid2HbQLIJbonh2PkYCcMpUIdb7O2iFWqfijd9H8Pkp5qiHVukhqMEIk2qNUgyGuLHqcP8GKiv5yskhqMEIQoC0aDBDAGoguLXua4ypdBunGgnPRhxgKuuMXIdM(GyuLiWa1Wdjn3zsK6ibMAOTdpmmh2PkYCcMpUIdb7O2iFWqfijd9H8PsqYHqcFPuoGm9evSHoDnWaPktzgloy6dIrvIadudpK0CNjrQ2Z2gn6SR5XascN8bt3CyNQiZjy(4koeSJAJ8bdvGKm0hYNQ8KdHe(sPCaz6jQydD6AGbsvgcjKYdsIuLJjPCaz6jQ6Wrd0T1Pb6yqvgtbGJ9mSr1aA0KUECzqsrzgloy6dIrvIadudpK0CNjrQKSGPdupAq80KadOWCyNQiZjy(4koeSJAJ8bdvGKm0hTsL4mr5lLYbKPNOQdhnq3wNgOJbvziKWdsIYNGKdfLzS4GPpigvjcmqn8qsZDMePsYcMoq9ObXttcmGcZHDQImNG5JR4qWoQnYhmubsYqF0kvIZKuoGm9evD4Ob6260aDmOkJjAGExfaoQZU2iFWqbyyIgO3vbGJ6SRnYhmubsYqF0kvkLroTiexlpaCSNHnQgqJM01JldskmDqsSvcsoLzS4GPpigvjcmqn8qsZDMePoAyW8bb1zqRZU(YGe9ZCyN6bjrQYHqcPukhqMEIQe4gqquNDTiZjy(4dtusPiLIo7NIO2bKDtImNG5JRcgeY(PhgCqKkqsg6JwPkptImNG5JR4qWoQnYhmubsYqF0kvIZKiZjy(4Qlben6SRVgutY2qvGKm0hTsL4OGqcfzobZhxXHGDuBKpyOcKKH(OvQYJqc7q7Mthijd9rRImNG5JR4qWoQnYhmubsYqFqbfLzVsTeNs2vlCu71G1omqeS2Sx71G1ALaZjEh0TR9vdq3UwJiBrrXbNyzgloy6dIrvIadudpK0CNjrQJeyoX7GUToaOBBoStLsPCaz6jQoijQb8do1SbXOKfhmDvWGq2p9WGdIuOKOa4q9bjXwUiLIo7NIO2bKDkigLS4GPRar(AOZWrfkjkaouFqsSLlsPOZ(PCue5mdqkigloy6Qlben6SRVgutY2qfkjkaouFqsS1JdB8uGWXXUaF9bXPKDuyIsPCaz6jQAyPOonqhbjKqkfPu0z)ue1oGSBkaCSNHnQ4qWoQHEh6WRnfuy64WgpfiCCSlq5lpIRm7vELAzXbtFqmQs0XNEc4G6ah5ukAoWa1pnWjQf84GUnvzmh2Psd07koeSJAJ8bdfGbHecI0a9U6sarJo76Rb1KSnubyqiHG5PcgeY(PhgCqK6GcIGUDzgloy6dIrvIcEo1S4GPRNWXzUZKivbpfat(GPpkZyXbtFqmQsuWZPMfhmD9eooZDMePYjA(4cO4OkJ5WovwCqPOgDKeId5tvkhqMEIkor9XHnEArc4xzgloy6dIrvIcEo1S4GPRNWXzUZKi1goitVT5WovrkfD2pfrTdi7Mcah7zyJkoeSJ6goitVDzgloy6dIrvIcEo1S4GPRNWXzUZKi1oC0aDBDAGogMd7uLYbKPNOQHLI60aDeKQCmjLditprvhoAGUTonqhdtVKsrkfD2pfrTdi7Mcah7zyJkoeSJ6goitVnfLzS4GPpigvjk45uZIdMUEchN5otIutd0XWCyNQuoGm9evnSuuNgOJGuLJPxsPiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3MIYmwCW0heJQef8CQzXbtxpHJZCNjrQImNG5Jpmh2P(skfPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92uuMXIdM(GyuLOGNtnloy66jCCM7mjsnYJpy6Md7uLYbKPNOQdDEQPbcNQCm9skfPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92uuMXIdM(GyuLOGNtnloy66jCCM7mjsTdDEQPbc3CyNQuoGm9evDOZtnnq4uLX0lPuKsrN9tru7aYUPaWXEg2OIdb7OUHdY0Btrzwzgloy6dfNi1EKJJoNN5Wo1aWXEg2OceoeqJj05OTwKKKSdAsK5emFCfnqVRbHdb0ycDoARfjjj7GQazW2MOb6DfiCiGgtOZrBTijjzhu3JCCkW8XnrjnqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmuG5JBcePb6D1LaIgD21xdQjzBOcmFCkmjYCcMpU6sarJo76Rb1KSnufijd9bv5yIsAGExXHGDulA4WgvJJfe1kvPCaz6jQ4e1xEKAswsTOHdBCyIskpEI(Pcah1zxBKpyysK5emFCva4Oo7AJ8bdvGKm0hTs1waAsK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLudItUTUNHMnOGqcP8Lhpr)ubGJ6SRnYhmmjYCcMpUIdb7O2iFWqfijd9H8LYbKPNO6YJutYsQbXj3w3ZqZguqiHImNG5JR4qWoQnYhmubsYqF0kvBbifuuMXIdM(qXjsmQsSddutp5XzoStLYaWXEg2OceoeqJj05OTwKKKSdAsK5emFCfnqVRbHdb0ycDoARfjjj7GQazW2MOb6DfiCiGgtOZrBTijjzhu3HbQaZh3KrGs12cqLmQEKJJoNhfesiLbGJ9mSrfiCiGgtOZrBTijjzh00bjrQYHIYmwCW0hkorIrvI9ihN2tPS5Wo1aWXEg2OYoGJzBnuaft0KiZjy(4koeSJAJ8bdvGKm0hYNGKJjrMtW8XvxciA0zxFnOMKTHQajzOpOkhtusd07koeSJArdh2OACSGOwPkLditprfNO(YJutYsQfnCyJdtus5Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(OvQ2cqtImNG5JR4qWoQnYhmubsYqFiFPCaz6jQU8i1KSKAqCYT19m0SbfesiLV84j6NkaCuNDTr(GHjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswsnio526EgA2GccjuK5emFCfhc2rTr(GHkqsg6JwPAlaPGIYmwCW0hkorIrvI9ihN2tPS5Wo1aWXEg2OYoGJzBnuaft0KiZjy(4koeSJAJ8bdvGKm0huLJjkPKsrMtW8XvxciA0zxFnOMKTHQajzOpKVuoGm9evSHMKLudItUTUNH(YJ0enqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLupowqefesiLImNG5JRUeq0OZU(AqnjBdvbsYqFqvoMOb6Dfhc2rTOHdBunowquRuLYbKPNOItuF5rQjzj1IgoSXbfuyIgO3vbGJ6SRnYhmuG5Jtrzgloy6dfNiXOkroeSJAs4yaN4WCyNQiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQB4Gm92QXXcIAvgIZKiZjy(4QGbHSF6HbhePcKKH(OvQs5aY0tu1Wbz6T1JJfePpijsmusuaCO(GKOjrMtW8XvxciA0zxFnOMKTHQajzOpALQuoGm9evnCqMEB94ybr6dsIedLefahQpijsmwCW0vbdcz)0ddoisHsIcGd1hKenjYCcMpUIdb7O2iFWqfijd9rRuLYbKPNOQHdY0BRhhlisFqsKyOKOa4q9bjrIXIdMUkyqi7NEyWbrkusuaCO(GKiXyXbtxDjGOrND91GAs2gQqjrbWH6dsIMlAyOtvMYmwCW0hkorIrvICiyh1KWXaoXH5WovrkfD2pLu0VM2HPaWXEg2OIdb7Og6DOdV2MOb6Dfhc2rDdhKP3wnowquRYqCMezobZhxDjGOrND91GAs2gQcKKH(OvQs5aY0tu1Wbz6T1JJfePpijsmusuaCO(GKOjrMtW8XvCiyh1g5dgQajzOpALQuoGm9evnCqMEB94ybr6dsIedLefahQpijsmwCW0vxciA0zxFnOMKTHkusuaCO(GKO5Igg6uLPmJfhm9HItKyuLihc2rn9KhN5WovrkfD2pLu0VM2HPJNOFkoeSJAu0KMoij2QmYXKiZjy(4ksyezm0zxFzqI(PcKKH(WenqVRetKdbpoOBRghliQvcQmJfhm9HItKyuLiWa1Wdjn3zsK6ibMt8oOBRda62Md7udah7zyJQb0OjD94YG0KrGs12cqLmkuAk4dMEzgloy6dfNiXOkXlben6SRVgutY2qZHDQbGJ9mSr1aA0KUECzqAYiqPABbOsgfknf8btVmJfhm9HItKyuLihc2rTr(GH5Wo1aWXEg2OAanAsxpUminrPrGs12cqLmkuAk4dMoHeAeOuTTaujJ6sarJo76Rb1KSnKIYmwCW0hkorIrvIKWiYyOZU(YGe9ZCyNAa4ypdBuXHGDud9o0HxBtImNG5JRUeq0OZU(AqnjBdvbsYqF0kvzKJjrMtW8XvCiyh1g5dgQajzOpALQmexzgloy6dfNiXOkrsyezm0zxFzqI(zoStvK5emFCfhc2rTr(GHkqsg6JwP2cmjYCcMpU6sarJo76Rb1KSnufijd9rRuBbMOKgO3vCiyh1IgoSr14ybrTsvkhqMEIkor9LhPMKLulA4WghMOKYJNOFQaWrD21g5dgMezobZhxfaoQZU2iFWqfijd9rRuTfGMezobZhxXHGDuBKpyOcKKH(q(ehfesiLV84j6NkaCuNDTr(GHjrMtW8XvCiyh1g5dgQajzOpKpXrbHekYCcMpUIdb7O2iFWqfijd9rRuTfGuqrzgloy6dfNiXOkruAk4dMU5Wo1dsIYNGKJPaWXEg2OAanAsxpUminjsPOZ(PKI(10omzeOuTTaujJIegrgdD21xgKOFLzS4GPpuCIeJQerPPGpy6Md7upijkFcsoMcah7zyJQb0OjD94YG0enqVR4qWoQfnCyJQXXcIALQuoGm9evCI6lpsnjlPw0WHnomjYCcMpU6sarJo76Rb1KSnufijd9bv5ysK5emFCfhc2rTr(GHkqsg6JwPAlalZyXbtFO4ejgvjIstbFW0nh2PEqsu(eKCmfao2ZWgvdOrt66XLbPjrMtW8XvCiyh1g5dgQajzOpOkhtusjLImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQydnjlPgeNCBDpd9LhPjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGikiKqkfzobZhxDjGOrND91GAs2gQcKKH(GQCmrd07koeSJArdh2OACSGOwPkLditprfNO(YJutYsQfnCyJdkOWenqVRcah1zxBKpyOaZhNcZH(HrayCAyNknqVRgqJM01Jlds14ybruPb6D1aA0KUECzqQizj1JJfezo0pmcaJtdjjrqiFivzkZyXbtFO4ejgvjgmiK9tpm4GiZHDQImNG5JRUeq0OZU(AqnjBdvbsYqF0kkjkaouFqs0eLuE8e9tfaoQZU2iFWWKiZjy(4QaWrD21g5dgQajzOpALQTa0KiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlPgeNCBDpdnBqbHes5lpEI(Pcah1zxBKpyysK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLudItUTUNHMnOGqcfzobZhxXHGDuBKpyOcKKH(OvQ2cqkkZyXbtFO4ejgvjgmiK9tpm4GiZHDQImNG5JR4qWoQnYhmubsYqF0kkjkaouFqs0eLusPiZjy(4Qlben6SRVgutY2qvGKm0hYxkhqMEIk2qtYsQbXj3w3ZqF5rAIgO3vCiyh1IgoSr14ybruPb6Dfhc2rTOHdBurYsQhhliIccjKsrMtW8XvxciA0zxFnOMKTHQajzOpOkht0a9UIdb7Ow0WHnQghliQvQs5aY0tuXjQV8i1KSKArdh24Gckmrd07QaWrD21g5dgkW8XPOmJfhm9HItKyuLiiYxdDgoAoStvK5emFCfhc2rTr(GHkqsg6dQYXeLusPiZjy(4Qlben6SRVgutY2qvGKm0hYxkhqMEIk2qtYsQbXj3w3ZqF5rAIgO3vCiyh1IgoSr14ybruPb6Dfhc2rTOHdBurYsQhhliIccjKsrMtW8XvxciA0zxFnOMKTHQajzOpOkht0a9UIdb7Ow0WHnQghliQvQs5aY0tuXjQV8i1KSKArdh24Gckmrd07QaWrD21g5dgkW8XPOmJfhm9HItKyuLiWa1Wdjn3zsK6ibMt8oOBRda62Md7uPKgO3vCiyh1IgoSr14ybrTsvkhqMEIkor9LhPMKLulA4WghesOrGs12cqLmQGbHSF6HbherHjkP84j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF0kvBbOjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswsnio526EgA2GccjKYxE8e9tfaoQZU2iFWWKiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlPgeNCBDpdnBqbHekYCcMpUIdb7O2iFWqfijd9rRuTfGuuMXIdM(qXjsmQs8sarJo76Rb1KSn0CyNQiLIo7Nsk6xt7Wua4ypdBuXHGDud9o0HxBtImNG5JRiHrKXqND9Lbj6Nkqsg6JwPsCYPmJfhm9HItKyuL4LaIgD21xdQjzBO5WovrkfD2pLu0VM2HPaWXEg2OIdb7Og6DOdV2MOb6DfjmImg6SRVmir)ubsYqF0kv5jhtImNG5JR4qWoQnYhmubsYqF0kvBbyzgloy6dfNiXOkXlben6SRVgutY2qZHDQusd07koeSJArdh2OACSGOwPkLditprfNO(YJutYsQfnCyJdcj0iqPABbOsgvWGq2p9WGdIOWeLuE8e9tfaoQZU2iFWWKiZjy(4QaWrD21g5dgQajzOpALQTa0KiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlPgeNCBDpdnBqbHes5lpEI(Pcah1zxBKpyysK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLudItUTUNHMnOGqcfzobZhxXHGDuBKpyOcKKH(OvQ2cqkkZyXbtFO4ejgvjYHGDuBKpyyoStLskfzobZhxDjGOrND91GAs2gQcKKH(q(s5aY0tuXgAswsnio526Eg6lpst0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybruqiHukYCcMpU6sarJo76Rb1KSnufijd9bv5yIgO3vCiyh1IgoSr14ybrTsvkhqMEIkor9LhPMKLulA4WghuqHjAGExfaoQZU2iFWqbMpEzgloy6dfNiXOkXaWrD21g5dgMd7uPb6Dva4Oo7AJ8bdfy(4MOKsrMtW8XvxciA0zxFnOMKTHQajzOpKV8KJjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGikiKqkfzobZhxDjGOrND91GAs2gQcKKH(GQCmrd07koeSJArdh2OACSGOwPkLditprfNO(YJutYsQfnCyJdkOWeLImNG5JR4qWoQnYhmubsYqFiFzKhHecI0a9U6sarJo76Rb1KSnubyqrzgloy6dfNiXOkXrdSFq3wBKpyyoStvK5emFCfhc2rDg0QajzOpKpXriHV84j6NIdb7Ood6YmwCW0hkorIrvICiyh10tECMd7ufPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MOb6Dfhc2rTr(GHcWWeisd07QGbHSF6HbhePLcmDmyA4eETvJJferv2yYiqPABbOsgfhc2rDg0MyXbLIA0rsioA9vvMXIdM(qXjsmQsKdb7OMMJGTrZHDQIuk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyycePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIOkBkZyXbtFO4ejgvjYHGDutp5XzoStvKsrN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtucMNkyqi7NEyWbrQajzOpKVSJqcbrAGExfmiK9tpm4GiTuGPJbtdNWRTcWGctGinqVRcgeY(PhgCqKwkW0XGPHt41wnowquRYgtS4Gsrn6ijehujOYmwCW0hkorIrvICiyh1zqBoStvKsrN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PhgCqKwkW0XGPHt41wnowqevcQmJfhm9HItKyuLihc2rnnhbBJMd7ufPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MOb6Dfhc2rTr(GHcWWeisd07QGbHSF6HbhePLcmDmyA4eETvJJfervELzS4GPpuCIeJQe5qWoQrjnM5aMU5WovrkfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDuBKpyOammzeOuTTaujpvWGq2p9WGdImXIdkf1OJKqCiFcQmJfhm9HItKyuLihc2rnkPXmhW0nh2PksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0ddoislfy6yW0Wj8ARghliIQmMyXbLIA0rsioKpbvMXIdM(qXjsmQs0iWb6cuNDnj0bnh2Psd07kqKVg6mCubyycePb6D1LaIgD21xdQjzBOcWWeisd07Qlben6SRVgutY2qvGKm0hTsLgO3vgboqxG6SRjHoOIKLupowqulNfhmDfhc2rn9KhNcLefahQpijAIskpEI(PcCKo7c0eloOuuJoscXrRYgkiKqwCqPOgDKeIJwjokmr5ldah7zyJkoeSJA6KKMdqs0pcj84WgpvdYZRrzio5tqehfLzS4GPpuCIeJQe5qWoQPN84mh2Psd07kqKVg6mCubyyIskpEI(PcCKo7c0eloOuuJoscXrRYgkiKqwCqPOgDKeIJwjokmr5ldah7zyJkoeSJA6KKMdqs0pcj84WgpvdYZRrzio5tqehfLzS4GPpuCIeJQehagy4PuUmJfhm9HItKyuLihc2rnnhbBJMd7uPb6Dfhc2rTOHdBunowqK8PsjloOuuJoscXrlImuykaCSNHnQ4qWoQPtsAoajr)mDCyJNQb551OmexReeXvMXIdM(qXjsmQsKdb7OMMJGTrZHDQ0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybrLzS4GPpuCIeJQe5qWoQZG2CyNknqVR4qWoQfnCyJQXXcIOkhtukYCcMpUIdb7O2iFWqfijd9H8LH4iKWxsPiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3MckkZyXbtFO4ejgvj641GH(qsdCCMd7uPmWEGJgMEIes4lpOGiOBtHjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGOYmwCW0hkorIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilotbGJ9mSrfhc2rDdhKP32eLuE8e9tXKgtyhk4dMUjwCqPOgDKeIJwBbuqiHS4Gsrn6ijehTsCuuMXIdM(qXjsmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QazXz64j6NIdb7OgfnPjqKgO3vxciA0zxFnOMKTHkadtuE8e9tXKgtyhk4dMoHeYIdkf1OJKqC0AlKIYmwCW0hkorIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilothpr)umPXe2Hc(GPBIfhukQrhjH4Ovztzgloy6dfNiXOkroeSJAusJzoGPBoStLgO3vCiyh1IgoSr14ybrTsd07koeSJArdh2OIKLupowquzgloy6dfNiXOkroeSJAusJzoGPBoStLgO3vCiyh1IgoSr14ybruPb6Dfhc2rTOHdBurYsQhhliYKrGs12cqLmkoeSJAAoc2glZELxPwwCW0hkorIrvIO0uWhmDZH(HrayCAyNkj7SYqCYNAlG4mh6hgbGXPHKKiiKpKQmLzLzS4GPpucEkaM8btFqvkhqMEIM7mjsTHLI60aDe080G6apZLYtaKQmMd7uLYbKPNOQHLI60aDeKQCmzeOuTTaujJcLMc(GPB6Lugao2ZWgvdOrt66XLbjHegao2ZWgvhsAKbp1pCyqrzgloy6dLGNcGjFW0heJQeLYbKPNO5otIuByPOonqhbnpnOoWZCP8eaPkJ5WovPCaz6jQAyPOonqhbPkht0a9UIdb7O2iFWqbMpUjrMtW8XvCiyh1g5dgQajzOpmrza4ypdBunGgnPRhxgKesya4ypdBuDiPrg8u)WHbfLzS4GPpucEkaM8btFqmQsukhqMEIM7mjsTdDEQPbc380G6apZLYtaKQmMd7uPb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcIm9sAGExfatuND91eiouagM6q7Mthijd9rRuPKss25xFWIdMUIdb7OMEYJtjYXrrlNfhmDfhc2rn9KhNcLefahQpijsrz2RuRSf8AWOwU2oWC2U2XXcIqWAB4Gm921MrTqVwusuaCyTb72yTpWRPwjKK0CasI(vMXIdM(qj4PayYhm9bXOkrPCaz6jAUZKivK0iFWab10CeSnAEAqDGN5s5jasLgO3vCiyh1nCqMEB14ybrYNQmehHesza4ypdBuXHGDutNK0CasI(z64WgpvdYZRrziUwjiIJIYSx5vQLfhm9HsWtbWKpy6dIrvIs5aY0t0CNjrQtECA2qdmqZbXodmpQYX80G6apZHDQ0a9UIdb7O2iFWqbyyIsPCaz6jQM840SHgyGuLdHeEqsu(uLYbKPNOAYJtZgAGbsmziokmxkpbqQhKelZELxP2wkeSJ1(ArccTBxRnukoQLRvkhqMEI1YKjGF1M9AfGH51sdC1(GVNZAbgyTCT9jF1IJdsYhm9ABWav1sGgS2bKuuRrKsHGiyTbsYqFOrjnqXHG1IsAe4yatVwWeh165v7tgev7doN12ZOwJibH2TRfeaR9YAVgSwAGyCTR15diWAZETxdwRamuLzVYRulloy6dLGNcGjFW0heJQeLYbKPNO5otIuXXbj5db1SHwK5emFCZtdQd8mxkpbqQukYCcMpUIdb7O2iFWqbce8btVLtPmTiukhLCiOwUiDqa4P4qWoQnIeeA3wfStefuqrlcLhKeBrKYbKPNOAYJtZgAGbsrzgloy6dLGNcGjFW0heJQeLYbKPNO5otIupijQb8do1SH5Pb1bEMd7ufPdcapfhc2rTrKGq72MlLNaivrMtW8XvCiyh1g5dgQajzOp0OKgO4qWYmwCW0hkbpfat(GPpigvjkLditprZDMePEqsud4hCQzdZtdQd8mh2P(sr6GaWtXHGDuBeji0UT5s5jasvK5emFCfhc2rTr(GHkqsg6JYSxPwzB89Cwlio5212sVwTag1EzTYtoduuBpJAjqETSYmwCW0hkbpfat(GPpigvjkLditprZDMePEqsud4hCQzdZtdQKSKMlLNaivrMtW8XvxciA0zxFnOMKTHQajzOpmh2PsPiZjy(4Qlben6SRVgutY2qvGKm0hTis5aY0tuDqsud4hCQzdkAvEYPm7vQ1c6cS2xnaD7AHJAhaIMA5AnYhm6aZAVa6eHxT9mQ913Tdi7Mx7d(EoRDCqbr1EzTxdw79K1scDGdRv0wmXAb8doR9bR1gVA5ABG2n1IEcy3uBWor1M9AnIeeA3UmJfhm9HsWtbWKpy6dIrvIs5aY0t0CNjrQhKe1a(bNA2W80GkjlP5s5jas9cOteEQrcmN4Dq3wha0TvImNG5JRcKKH(WCyNQiDqa4P4qWoQnIeeA32KiDqa4P4qWoQnIeeA3wfStuReNjSfdanmqq1ibMt8oOBRda62MePu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92LzVsTY2475SwqCYTRLa51YQfWO2lRvEYzGIA7zuBl9ALzS4GPpucEkaM8btFqmQsukhqMEIM7mjsTjNGq3wF5rAEAqDGN5s5jasvK5emFC1LaIgD21xdQjzBOkqgSTjPCaz6jQoijQb8do1SrRYtoLzVsTVAgeY(vRLbhevlyIJA98QfssIGq(Wz7AnaUAbmQ9AWALcmDmyA4eETRfePb69AhzTWRwb71sJ1cc7DOayE1EzTGWHadV2RHVAFW3bwlF1EnyTYEWiVMALcmDmyA4eETRDCSGOYmwCW0hkbpfat(GPpigvjkLditprZDMeP2IcmonWab1ddoiY80G6apZLYtaKkLgbkvBlavYOcgeY(PhgCqeHeAeOuTTaujpvWGq2p9WGdIiKqJaLQTfGkcsfmiK9tpm4GikmXIdMUkyqi7NEyWbrQdsI6b0fyR2cqfjlzlx2uM9kVsTVEb0g68Swli5lQv0GcIqWAbrAGExfmiK9tpm4GiTuGPJbtdNWRTcmFCZRLg4Q9A4RwWeh(7R2NmiQ2Ng0R9AWAzqW0RLnmMqCu7R261NRf6JJ9B2wvM9kVsTS4GPpucEkaM8btFqmQsukhqMEIM7mjsTffyCAGbcQhgCqK5Pb1bEMlLNaivkncuQ2waQKrfmiK9tpm4Gicj0iqPABbOsEQGbHSF6HbheriHgbkvBlaveKkyqi7NEyWbruycePb6DvWGq2p9WGdI0sbMogmnCcV2kW8XlZyXbtFOe8uam5dM(GyuLOuoGm9en3zsKAcCdiiQZUwK5emF8H5Pb1bEMlLNaivAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfy(4MEPuoGm9evTOaJtdmqq9WGdImbI0a9Ukyqi7NEyWbrAPathdMgoHxBfy(4LzS4GPpucEkaM8btFqmQsukhqMEIM7mjsDCSGiDdhKP3280G6apZLYtaKAa4ypdBuXHGDu3Wbz6TnrjLIuk6SFkIAhq2njYCcMpUkyqi7NEyWbrQajzOpAvkhqMEIQgoitVTECSGi9bjrkOOmRm7vQ91cygWdk7bRfyaD7ATd4y2UwOakMyTpWRPw2qvRS)aRfE1(aVMAV8iRnVgmEGduvMXIdM(qjYCcMp(GApYXP9ukBoStnaCSNHnQSd4y2wdfqXenjYCcMpUIdb7O2iFWqfijd9H8ji5ysK5emFC1LaIgD21xdQjzBOkqgSTjkPb6Dfhc2rTOHdBunowquRuLYbKPNO6YJutYsQfnCyJdtus5Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(OvQ2cqtImNG5JR4qWoQnYhmubsYqFiFPCaz6jQU8i1KSKAqCYT19m0SbfesiLV84j6NkaCuNDTr(GHjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswsnio526EgA2GccjuK5emFCfhc2rTr(GHkqsg6JwPAlaPGIYmwCW0hkrMtW8XheJQe7rooTNszZHDQbGJ9mSrLDahZ2AOakMOjrMtW8XvCiyh1g5dgQazW2MO8Lhpr)uOpH2nh6iiHes5Xt0pf6tODZHocAIKDwzio5t9vjhkOWeLukYCcMpU6sarJo76Rb1KSnufijd9H8LroMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcIOGqcPuK5emFC1LaIgD21xdQjzBOkqsg6dQYXenqVR4qWoQfnCyJQXXcIOkhkOWenqVRcah1zxBKpyOaZh3ej7SYqCYNQuoGm9evSHMe6qsasnj7S2qCLzS4GPpuImNG5Jpigvj2JCC058mh2Pgao2ZWgvGWHaAmHohT1IKKKDqtImNG5JROb6DniCiGgtOZrBTijjzhufid22enqVRaHdb0ycDoARfjjj7G6EKJtbMpUjkPb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHcmFCtGinqVRUeq0OZU(AqnjBdvG5JtHjrMtW8XvxciA0zxFnOMKTHQajzOpOkhtusd07koeSJArdh2OACSGOwPkLditpr1LhPMKLulA4WghMOKYJNOFQaWrD21g5dgMezobZhxfaoQZU2iFWqfijd9rRuTfGMezobZhxXHGDuBKpyOcKKH(q(s5aY0tuD5rQjzj1G4KBR7zOzdkiKqkF5Xt0pva4Oo7AJ8bdtImNG5JR4qWoQnYhmubsYqFiFPCaz6jQU8i1KSKAqCYT19m0SbfesOiZjy(4koeSJAJ8bdvGKm0hTs1wasbfLzS4GPpuImNG5Jpigvj2HbQPN84mh2Pgao2ZWgvGWHaAmHohT1IKKKDqtImNG5JROb6DniCiGgtOZrBTijjzhufid22enqVRaHdb0ycDoARfjjj7G6omqfy(4MmcuQ2waQKr1JCC058kZELAFngg12Yscu7d8AQTLETAH9AH37rTIKe621cyu7itxv7RRxl8Q9boN1sJ1cmqWAFGxtTeiVwM51k4Xvl8QDmH2n3SDT0ypdSmJfhm9HsK5emF8bXOkrsyezm0zxFzqI(zoStLYxgao2ZWgvdOrt66XLbjHesd07Qb0OjD94YGubyqHjrMtW8XvxciA0zxFnOMKTHQajzOpAvkhqMEIkY80gbkqeuF5rQPBtiHukLditpr1bjrnGFWPMnKVuoGm9evK5Pjzj1G4KBR7zOzdtImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQiZttYsQbXj3w3ZqF5rsrzgloy6dLiZjy(4dIrvIKWiYyOZU(YGe9ZCyNQiZjy(4koeSJAJ8bdvGmyBtu(YJNOFk0Nq7MdDeKqcP84j6Nc9j0U5qhbnrYoRmeN8P(QKdfuyIskfzobZhxDjGOrND91GAs2gQcKKH(q(s5aY0tuXgAswsnio526Eg6lpst0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybruqiHukYCcMpU6sarJo76Rb1KSnufijd9bv5yIgO3vCiyh1IgoSr14ybruLdfuyIgO3vbGJ6SRnYhmuG5JBIKDwzio5tvkhqMEIk2qtcDijaPMKDwBiUYmwCW0hkrMtW8XheJQe7tC0icUFMd7uLYbKPNOkbUbee1zxlYCcMp(WeLJeysdDqL0CYhCI6roLI(riHJeysdDqLbW4aMOgdaJdMofLzVsTT08HBpQfyG1cI81qNHJ1(aVMAzdvTVUETxEK1ch1gid2UwEu7doNMxljtew7aiWAVSwbpUAHxT0ypdS2lpsvzgloy6dLiZjy(4dIrvIGiFn0z4O5WovrMtW8XvxciA0zxFnOMKTHQazW2MOb6Dfhc2rTOHdBunowquRuLYbKPNO6YJutYsQfnCyJdtImNG5JR4qWoQnYhmubsYqF0kvBbyzgloy6dLiZjy(4dIrvIGiFn0z4O5WovrMtW8XvCiyh1g5dgQazW2MO8Lhpr)uOpH2nh6iiHes5Xt0pf6tODZHocAIKDwzio5t9vjhkOWeLukYCcMpU6sarJo76Rb1KSnufijd9H8LroMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcIOGqcPuK5emFC1LaIgD21xdQjzBOkqgSTjAGExXHGDulA4WgvJJfervouqHjAGExfaoQZU2iFWqbMpUjs2zLH4KpvPCaz6jQydnj0HKaKAs2zTH4kZELAL9hyTddoiQwyV2lpYAzhSw2OwoWAtVwbyTSdw7t6VVAPXAbmQTNrTZ0TXO2RH9AVgSwswYAbXj328AjzIGUDTdGaR9bRTHLI1YxTtKhxT3twlhc2XAfnCyJJAzhS2RHVAV8iR9Hh(7R2wuGXvlWabvLzS4GPpuImNG5JpigvjgmiK9tpm4GiZHDQImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQIHMKLudItUTUNH(YJ0KiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQyOjzj1G4KBR7zOzdtuE8e9tfaoQZU2iFWWeLImNG5JRcah1zxBKpyOcKKH(OvusuaCO(GKiHekYCcMpUkaCuNDTr(GHkqsg6d5lLditprvm0KSKAqCYT19m0rAqbHe(YJNOFQaWrD21g5dguyIgO3vCiyh1IgoSr14ybrYxEMarAGExDjGOrND91GAs2gQaZh3enqVRcah1zxBKpyOaZh3enqVR4qWoQnYhmuG5JxM9k1k7pWAhgCquTpWRPw2O2Ng0R1ihdi9ev1(661E5rwlCuBGmy7A5rTp4CAETKmryTdGaR9YAf84QfE1sJ9mWAV8ivLzS4GPpuImNG5JpigvjgmiK9tpm4GiZHDQImNG5JRUeq0OZU(AqnjBdvbsYqF0kkjkaouFqs0enqVR4qWoQfnCyJQXXcIALQuoGm9evxEKAswsTOHdBCysK5emFCfhc2rTr(GHkqsg6JwPeLefahQpijsmwCW0vxciA0zxFnOMKTHkusuaCO(GKifLzS4GPpuImNG5JpigvjgmiK9tpm4GiZHDQImNG5JR4qWoQnYhmubsYqF0kkjkaouFqs0eLu(YJNOFk0Nq7MdDeKqcP84j6Nc9j0U5qhbnrYoRmeN8P(QKdfuyIskfzobZhxDjGOrND91GAs2gQcKKH(q(s5aY0tuXgAswsnio526Eg6lpst0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybruqiHukYCcMpU6sarJo76Rb1KSnufijd9bv5yIgO3vCiyh1IgoSr14ybruLdfuyIgO3vbGJ6SRnYhmuG5JBIKDwzio5tvkhqMEIk2qtcDijaPMKDwBiokkZyXbtFOezobZhFqmQseyGA4HKM7mjsDKaZjEh0T1baDBZHDQu(YaWXEg2OAanAsxpUmijKqAGExnGgnPRhxgKkadkmrd07koeSJArdh2OACSGOwPkLditpr1LhPMKLulA4WghMezobZhxXHGDuBKpyOcKKH(OvQOKOa4q9bjrtKSZkdXjFPCaz6jQydnj0HKaKAs2zTH4mrd07QaWrD21g5dgkW8XlZELAL9hyTxEK1(aVMAzJAH9AH37rTpWRb61EnyTKSK1cItUTQ2xxVwppZRfyG1(aVMAJ0OwyV2RbR94j6xTWrThte6Mxl7G1cV3JAFGxd0R9AWAjzjRfeNCBvzgloy6dLiZjy(4dIrvIxciA0zxFnOMKTHMd7uP8LbGJ9mSr1aA0KUECzqsiH0a9UAanAsxpUmivaguyIgO3vCiyh1IgoSr14ybrTsvkhqMEIQlpsnjlPw0WHnomjYCcMpUIdb7O2iFWqfijd9rRurjrbWH6dsIMizNvgIt(s5aY0tuXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JxMXIdM(qjYCcMp(GyuL4LaIgD21xdQjzBO5WovAGExXHGDulA4WgvJJfe1kvPCaz6jQU8i1KSKArdh24W0Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(OvQOKOa4q9bjrts5aY0tuDqsud4hCQzd5lLditpr1LhPMKLudItUTUNHMnkZyXbtFOezobZhFqmQs8sarJo76Rb1KSn0CyNknqVR4qWoQfnCyJQXXcIALQuoGm9evxEKAswsTOHdBCyIYxE8e9tfaoQZU2iFWGqcfzobZhxfaoQZU2iFWqfijd9H8LYbKPNO6YJutYsQbXj3w3ZqhPbfMKYbKPNO6GKOgWp4uZgYxkhqMEIQlpsnjlPgeNCBDpdnBuM9k1k7pWAzJAH9AV8iRfoQn9AfG1YoyTpP)(QLgRfWO2Eg1ot3gJAVg2R9AWAjzjRfeNCBZRLKjc621oacS2RHVAFWAByPyTONa2n1sYoxl7G1En8v71GbwlCuRNxT8mqgSDTCTbGJ1M9AnYhmQfmFCvzgloy6dLiZjy(4dIrvICiyh1g5dgMd7ufzobZhxDjGOrND91GAs2gQcKKH(q(s5aY0tuXgAswsnio526Eg6lpstu(srkfD2pLu0VM2bHekYCcMpUIegrgdD21xgKOFQajzOpKVuoGm9evSHMKLudItUTUNHMmpkmrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizj1JJfezIgO3vbGJ6SRnYhmuG5JBIKDwzio5tvkhqMEIk2qtcDijaPMKDwBiUYSxPwz)bwBKg1c71E5rwlCuB61kaRLDWAFs)9vlnwlGrT9mQDMUng1EnSx71G1sYswlio52Mxljte0TRDaeyTxdgyTWH)(QLNbYGTRLRnaCSwW8XRLDWAVg(QLnQ9j93xT0OijXAzPmCY0tSwqGa621gaoQkZyXbtFOezobZhFqmQsmaCuNDTr(GH5WovAGExXHGDuBKpyOaZh3eLImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQI0qtYsQbXj3w3ZqF5rsiHImNG5JR4qWoQnYhmubsYqF0kvPCaz6jQU8i1KSKAqCYT19m0SbfMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcImjYCcMpUIdb7O2iFWqfijd9H8LroMezobZhxDjGOrND91GAs2gQcKKH(q(YiNYmwCW0hkrMtW8XheJQehnW(bDBTr(GH5WovPCaz6jQsGBabrD21ImNG5JpkZELAL9hyTgjzTxw7OfdGOShSw2RfL8cUwMUwOx71G16OKxTImNG5Jx7d0bZhZRfWN4yulrTdi71EnOxB6Z21cceq3UwoeSJ1AKpyuliaw7L12Kp1sYoxBdGBhTRnyqi7xTddoiQw4OmJfhm9HsK5emF8bXOkrJahOlqD21Kqh0CyN6Xt0pva4Oo7AJ8bdt0a9UIdb7O2iFWqbyyIgO3vbGJ6SRnYhmubsYqF0QTaurYswMXIdM(qjYCcMp(GyuLOrGd0fOo7AsOdAoStfePb6D1LaIgD21xdQjzBOcWWeisd07Qlben6SRVgutY2qvGKm0hTYIdMUIdb7OMeogWjouOKOa4q9bjrtVuKsrN9tru7aYEzgloy6dLiZjy(4dIrvIgboqxG6SRjHoO5WovAGExfaoQZU2iFWqbyyIgO3vbGJ6SRnYhmubsYqF0QTaurYsAsK5emFCfknf8btxfid22KiZjy(4Qlben6SRVgutY2qvGKm0hMEPiLIo7NIO2bK9YSYmwCW0hQo05PMgiCQCiyh1KWXaoXH5WovAGExjMihcECq3wfiloZfnm0Pktzgloy6dvh68utdeoXOkroeSJA6jpUYmwCW0hQo05PMgiCIrvICiyh10CeSnwMvM9k1kB3GETbG7q3UweEnyu71G1AzvBg1saz7ANOn6GCaXH51(G1(W(v7L1kBjnRLg7zG1EnyTeiVwMeBPxR2hOdMpQAL9hyTWRwEu7itVwEu7RoFTAB4rTDOdhniyTjqu7d(wkw7Wa9R2eiQv0WHnokZyXbtFO6Wrd0T1Pb6yqfLMc(GPBoStLYaWXEg2O6qsJm4P(HddcjKYaWXEg2OAanAsxpUmin9sPCaz6jQmc0ayo1O0KQmuqHjkPb6Dva4Oo7AJ8bdfy(4esOrGs12cqLmkoeSJAAoc2gPWKiZjy(4QaWrD21g5dgQajzOpkZELAFD9AFW3sXA7qhoAqWAtGOwrMtW8XR9b6G5ZOw2bRDyG(vBce1kA4WghMxRraZaEqzpyTYwsZAtPyulkfJ2xd0TRfNdSmJfhm9HQdhnq3wNgOJbXOkruAk4dMU5Wo1JNOFQaWrD21g5dgMezobZhxfaoQZU2iFWqfijd9HjrMtW8XvCiyh1g5dgQajzOpmrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MmcuQ2waQKrXHGDutZrW2yzgloy6dvhoAGUTonqhdIrvIDyGA6jpoZHDQbGJ9mSrfiCiGgtOZrBTijjzh0enqVRaHdb0ycDoARfjjj7G6EKJtbyuMXIdM(q1HJgOBRtd0XGyuLypYXP9ukBoStnaCSNHnQSd4y2wdfqXenrYoRmeN8BHexzgloy6dvhoAGUTonqhdIrvICiyh1KWXaoXH5Wo1aWXEg2OIdb7OUHdY0BBIgO3vCiyh1nCqMEB14ybrTsd07koeSJ6goitVTIKLupowqKjkPKgO3vCiyh1g5dgkW8XnjYCcMpUIdb7O2iFWqfid2MccjeePb6D1LaIgD21xdQjzBOcWGcZfnm0Pktzgloy6dvhoAGUTonqhdIrvIbGJ6SRnYhmmh2Pgao2ZWgvdOrt66XLbzzgloy6dvhoAGUTonqhdIrvICiyh1zqBoStvK5emFCva4Oo7AJ8bdvGmy7YmwCW0hQoC0aDBDAGogeJQe5qWoQPN84mh2PkYCcMpUkaCuNDTr(GHkqgSTjAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybrLzS4GPpuD4Ob6260aDmigvjcI81qNHJMd7uFza4ypdBuDiPrg8u)WHbHeksheaEkBy)0zxFnOEcfnLzS4GPpuD4Ob6260aDmigvjgaoQZU2iFWOm7vQ911R9bFhyT8vljlzTJJfenQn71(Ixul7G1(G12Wsr)9vlWabRTLLeO224zETadSwU2XXcIQ9YAncuk6xTKaUOb621c4tCmQnaCh621EnyTYEZbz6TRDI2OdYr7YmwCW0hQoC0aDBDAGogeJQe5qWoQjHJbCIdZHDQ0a9Usmroe84GUTkqwCMOb6DLyICi4XbDB14ybruPb6DLyICi4XbDBfjlPECSGitIuk6SFkPOFnTdtImNG5JRiHrKXqND9Lbj6NkqgSTPxkLditprfsAKpyGGAAoc2gnjYCcMpUIdb7O2iFWqfid2Um7vQvwzqYZz7AFWAnyyuRrEW0RfyG1(aVMABPxZ8APbUAHxTpW5S2jpUANPBxl6jGDtT9mQLoVMAVgS2xD(A1YoyTT0Rv7d0bZNrTa(ehJAda3HUDTxdwRLvTzulbKTRDI2OdYbehLzS4GPpuD4Ob6260aDmigvjAKhmDZHDQVmaCSNHnQoK0idEQF4WWeLVmaCSNHnQgqJM01JldscjKsPCaz6jQmc0ayo1O0KQmMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcIOGIYmwCW0hQoC0aDBDAGogeJQebr(AOZWrZHDQ0a9UkaCuNDTr(GHcmFCcj0iqPABbOsgfhc2rnnhbBJLzS4GPpuD4Ob6260aDmigvjgmiK9tpm4GiZHDQ0a9UkaCuNDTr(GHcmFCcj0iqPABbOsgfhc2rnnhbBJLzS4GPpuD4Ob6260aDmigvjscJiJHo76lds0pZHDQ0a9UkaCuNDTr(GHkqsg6JwPu2rm51Ydah7zyJQb0OjD94YGKIYSxPwz7g0RnaCh621EnyTYEZbz6TRDI2OdYrBZRfyG12sVwT0ypdSwcKxlR2lRfeG0OwU2oWC2U2XXcIqWAP5iyBSmJfhm9HQdhnq3wNgOJbXOkroeSJAJ8bdZHDQs5aY0tuHKg5dgiOMMJGTrt0a9UkaCuNDTr(GHcWWeLKSZkdX1kLYJ4igLYiNwUiLIo7NIO2bKDkOGqcPb6DLyICi4XbDB14ybruPb6DLyICi4XbDBfjlPECSGikkZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMMJGTrZHDQs5aY0tuHKg5dgiOMMJGTrt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybrMOb6Dfhc2rTr(GHcWOmJfhm9HQdhnq3wNgOJbXOkrGbQHhsAUZKi1rcmN4Dq3wha0Tnh2Psd07QaWrD21g5dgkW8XjKqJaLQTfGkzuCiyh10CeSnsiHgbkvBlavYOcgeY(PhgCqeHesPrGs12cqLmkqKVg6mC00ldah7zyJQb0OjD94YGKIYmwCW0hQoC0aDBDAGogeJQeVeq0OZU(AqnjBdnh2Psd07QaWrD21g5dgkW8XjKqJaLQTfGkzuCiyh10CeSnsiHgbkvBlavYOcgeY(PhgCqeHesPrGs12cqLmkqKVg6mC00ldah7zyJQb0OjD94YGKIYmwCW0hQoC0aDBDAGogeJQe5qWoQnYhmmh2PAeOuTTaujJ6sarJo76Rb1KSnSm7vQv2FG1(AzlR2lRD0Ibqu2dwl71IsEbxBlfc2XALWKhxTGab0TR9AWAjqETmj2sVwTpqhmFQfWN4yuBa4o0TRTLcb7yTYwIMuv7RRxBlfc2XALTenzTWrThpr)qqZR9bRvW(7RwGbw7RLTSAFGxd0R9AWAjqETmj2sVwTpqhmFQfWN4yu7dwl0pmcaJR2RbRTLAz1kAy3XP51oYAFW3ZzTdwkwl8uLzS4GPpuD4Ob6260aDmigvjAe4aDbQZUMe6GMd7uF5Xt0pfhc2rnkAstGinqVRUeq0OZU(AqnjBdvagMarAGExDjGOrND91GAs2gQcKKH(OvQuYIdMUIdb7OMEYJtHsIcGd1hKeB50a9UYiWb6cuNDnj0bvKSK6XXcIOOm7vQ911R91YwwTn8WFF1sJOxlWabRfeiGUDTxdwlbYRLv7d0bZhZR9bFpN1cmWAHxTxw7OfdGOShSw2RfL8cU2wkeSJ1kHjpUAHETxdw7RoFnj2sVwTpqhmFuLzS4GPpuD4Ob6260aDmigvjAe4aDbQZUMe6GMd7uPb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(OvQuYIdMUIdb7OMEYJtHsIcGd1hKeB50a9UYiWb6cuNDnj0bvKSK6XXcIOOmJfhm9HQdhnq3wNgOJbXOkroeSJA6jpoZHDQG5PcgeY(PhgCqKkqsg6d5tCesiisd07QGbHSF6HbhePLcmDmyA4eETvJJfejF5uM9k1kBJ1(W(v7L1sYeH1oacS2hS2gwkwl6jGDtTKSZ12ZO2RbRf9dgyTT0Rv7d0bZhZRfLIETWETxdg47rTJdoN1EqsS2ajzOdD7AtV2xD(AQAFD37rTPpBxlnEhg1EzT0aHx7L1k7bJSw2bRv2sAwlSxBa4o0TR9AWATSQnJAjGSDTt0gDqoG4qvMXIdM(q1HJgOBRtd0XGyuLihc2rnnhbBJMd7ufzobZhxXHGDuBKpyOcKbBBIKDwziUwPu2ihIrPmYPLlsPOZ(PiQDazNckmrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizj1JJfezIYxgao2ZWgvdOrt66XLbjHekLditprLrGgaZPgLMuLHctVmaCSNHnQoK0idEQF4WW0ldah7zyJkoeSJ6goitVDz2RuRe4iyBS2rtcmbR1ZRwASwGbcwlF1EnyTOdwB2RTLETAH9ALTKMc(GPxlCuBGmy7A5rTGrAyaD7AfnCyJJAFGZzTKmryTWR2JjcRDMUng1EzT0aHx71ejGDtTbsYqh621sYoxMXIdM(q1HJgOBRtd0XGyuLihc2rnnhbBJMd7uPb6Dfhc2rTr(GHcWWenqVR4qWoQnYhmubsYqF0kvBbOjrMtW8XvO0uWhmDvGKm0hLzVsTsGJGTXAhnjWeSwE(WTh1sJ1EnyTtEC1k4Xvl0R9AWAF15Rv7d0bZNA5rTeiVwwTpW5S2ahxgyTxdwROHdBCu7Wa9RmJfhm9HQdhnq3wNgOJbXOkroeSJAAoc2gnh2Psd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqfijd9rRuTfGMEza4ypdBuXHGDu3Wbz6TlZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMeogWjomh2PcI0a9U6sarJo76Rb1KSnubyy64j6NIdb7OgfnPjkPb6DfiYxdDgoQaZhNqczXbLIA0rsioOkdfMarAGExDjGOrND91GAs2gQcKKH(q(S4GPR4qWoQjHJbCIdfkjkaouFqs0CrddDQYyoYXSTw0Wqxd7uPb6DLyICi4XbDBTOHDhNkW8XnrjnqVR4qWoQnYhmuagesiLV84j6NkLIHr(GbcAIsAGExfaoQZU2iFWqbyqiHImNG5JRqPPGpy6QazW2uqbfLzVsTVUETp47aRvk6xt7W8AHKKiiKpC2UwGbw7lErTpnOxRGnmqWAVSwpVAF4XH1AePyuBpsYABzjbkZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMeogWjomh2PksPOZ(PKI(10omrd07kXe5qWJd62QXXcIOsd07kXe5qWJd62ksws94ybrLzVsTwhhxTadOBx7lErTTulR2Ng0RTLETAB4rT0i61cmqWYmwCW0hQoC0aDBDAGogeJQe5qWoQjHJbCIdZHDQ0a9Usmroe84GUTkqwCMezobZhxXHGDuBKpyOcKKH(WeL0a9UkaCuNDTr(GHcWGqcPb6Dfhc2rTr(GHcWGcZfnm0Pktzgloy6dvhoAGUTonqhdIrvICiyh1zqBoStLgO3vCiyh1IgoSr14ybrTsvkhqMEIQlpsnjlPw0WHnokZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMEYJZCyNknqVRcah1zxBKpyOamiKqs2zLH4KVmexzgloy6dvhoAGUTonqhdIrvIO0uWhmDZHDQ0a9UkaCuNDTr(GHcmFCt0a9UIdb7O2iFWqbMpU5q)WiamonStLKDwzio5tTfqCMd9dJaW40qsseeYhsvMYmwCW0hQoC0aDBDAGogeJQe5qWoQP5iyBSmRm7vELAL99bGHrghcwRGDbo1S4GP)6t1kBjnf8btV2h4CwlnwRZhqWZz7APJKi0Rf2RvKoi8GPpQLdSws8uLzVYRulloy6dvdhKP3MQGDbo1S4GPBoStLfhmDfknf8btxjAy3Xj0TnrYoRmeN8P2cjUYSxP2xxV2z(uB61sYoxl7G1kYCcMp(OwoWAfjj0TRfWW8ATZA5gKbRLDWArPzzgloy6dvdhKP3MyuLiknf8bt3CyNkj7SYqCTsLGKJjPCaz6jQsGBabrD21ImNG5Jpmr5Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(OvzKdfLzVsTY2yTpSF1EzTJJfevBdhKP3U2oWC2wvlbAWAbgyTzVwzKD1oowq0O2gmWAHJAVSwwisa)QTNrTxdw7bfev7e7xTPx71G1kAy3XzTSdw71G1schd4eRf612Nq7MtvMXIdM(q1Wbz6TjgvjYHGDutchd4ehMd7uPukhqMEIQXXcI0nCqMEBcj8GKyRYihkmrd07koeSJ6goitVTACSGOwLr2zUOHHovzkZELALTBqVwGb0TRv2I0ODG8S2xVa0zxGMxRGhxTCTD8PwuYl4AjHJbCIJAFAGtS2hgEq3U2Eg1EnyT0a9ET8v71G1oooUAZETxdwBhA3CLzS4GPpunCqMEBIrvICiyh1KWXaoXH5WovSfdanmqqfsA0oqEQZa0zxGMoij2kbjhtxABprLiZjy(4dtImNG5JRqsJ2bYtDgGo7cufijd9H8Lr21cm9swCW0viPr7a5PodqNDbQaHdMEIGLzS4GPpunCqMEBIrvIadudpK0CNjrQJeyoX7GUToaOBBoStLgO3vCiyh1g5dgkadthh24PaHJJDb2kvzKtzgloy6dvdhKP3MyuLiWa1Wdjn3zsK6ibMt8oOBRda62Md7uLYbKPNOcjnYhmqqnnhbBJMezobZhxDjGOrND91GAs2gQcKKH(OvQOKOa4q9bjrtImNG5JR4qWoQnYhmubsYqF0kvkrjrbWH6dsITC5rHPJdB8uGWXXUaLVmYPmJfhm9HQHdY0BtmQsmyqi7NEyWbrMd7uLYbKPNOcjnYhmqqnnhbBJMezobZhxDjGOrND91GAs2gQcKKH(OvQOKOa4q9bjrtImNG5JR4qWoQnYhmubsYqF0kvkrjrbWH6dsITC5rHjkFj2IbGggiOAKaZjEh0T1baDBcjuKoia8uCiyh1grccTBRc2js(ujocjKYlGor4PgjWCI3bDBDaq3wjYCcMpUkqsg6d5lJmYX0XHnEkq44yxGYxg5qbHes5fqNi8uJeyoX7GUToaOBRezobZhxfijd9rRurjrbWH6dsIMooSXtbchh7cSvQYihkOOmJfhm9HQHdY0BtmQs8sarJo76Rb1KSn0CyNQuoGm9evTOaJtdmqq9WGdImjYCcMpUIdb7O2iFWqfijd9rRurjrbWH6dsIMO8LylgaAyGGQrcmN4Dq3wha0TjKqr6GaWtXHGDuBeji0UTkyNi5tL4iKqkVa6eHNAKaZjEh0T1baDBLiZjy(4QajzOpKVmYihthh24PaHJJDbkFzKdfesiLxaDIWtnsG5eVd626aGUTsK5emFCvGKm0hTsfLefahQpijA64WgpfiCCSlWwPkJCOGIYmwCW0hQgoitVnXOkroeSJAJ8bdZHDQgbkvBlavYOUeq0OZU(AqnjBdlZyXbtFOA4Gm92eJQedah1zxBKpyyoStvkhqMEIkK0iFWab10CeSnAsK5emFCvWGq2p9WGdIubsYqF0kvusuaCO(GKOjPCaz6jQoijQb8do1SH8Pkp5yIYxksheaEkoeSJAJibH2TjKWxkLditprfpF42d9OTl0ImNG5JpiKqrMtW8XvxciA0zxFnOMKTHQajzOpALkLOKOa4q9bjXwU8OGIYmwCW0hQgoitVnXOkXGbHSF6HbhezoStvkhqMEIkK0iFWab10CeSnAYiqPABbOsgva4Oo7AJ8bJYmwCW0hQgoitVnXOkXlben6SRVgutY2qZHDQs5aY0tu1IcmonWab1ddoiY0lLYbKPNOQjNGq3wF5rwM9k1k7pWALNdwlhc2XAP5iyBSwOxBl9Ae7v)69A1M(SDTWETsyMj4eyC1YoyT8v7e5XvR8Q9fVyuRrKcbcwMXIdM(q1Wbz6TjgvjYHGDutZrW2O5WovAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGit0a9UkaCuNDTr(GHcWWenqVR4qWoQnYhmuagMOb6Dfhc2rDdhKP3wnowqK8PkJSZenqVR4qWoQnYhmubsYqF0kvwCW0vCiyh10CeSnQqjrbWH6dsIMOb6Df9mtWjW4uagLzVsTY(dSw55G1(QZxRwOxBl9A1M(SDTWETsyMj4eyC1YoyTYR2x8IrTgrkkZyXbtFOA4Gm92eJQedah1zxBKpyyoStLgO3vbGJ6SRnYhmuG5JBIgO3v0ZmbNaJtbyyIsPCaz6jQoijQb8do1SH8ji5qiHImNG5JRcgeY(PhgCqKkqsg6d5lJ8OWeL0a9UIdb7OUHdY0BRghlis(uLH4iKqAGExjMihcECq3wnowqK8PkdfMO8LI0bbGNIdb7O2isqODBcj8Ls5aY0tuXZhU9qpA7cTiZjy(4dkkZyXbtFOA4Gm92eJQedah1zxBKpyyoStLgO3vCiyh1g5dgkW8XnrPuoGm9evhKe1a(bNA2q(eKCiKqrMtW8Xvbdcz)0ddoisfijd9H8LrEuyIYxksheaEkoeSJAJibH2TjKWxkLditprfpF42d9OTl0ImNG5JpOOmJfhm9HQHdY0BtmQsmyqi7NEyWbrMd7uLYbKPNOcjnYhmqqnnhbBJMOKgO3vCiyh1IgoSr14ybrYNQ8iKqrMtW8XvCiyh1zqRcKbBtHjkF5Xt0pva4Oo7AJ8bdcjuK5emFCva4Oo7AJ8bdvGKm0hYN4OWKiZjy(4koeSJAJ8bdvGKm0hAusduCiO8PsqYXeLVuKoia8uCiyh1grccTBtiHVukhqMEIkE(WTh6rBxOfzobZhFqrz2RuRSDd61gaUdD7AnIeeA328AbgyTxEK1s3Uw4nWzVwOxBgGyu7L1YtOTxl8Q9bEn1YgLzS4GPpunCqMEBIrvIxciA0zxFnOMKTHMd7uLYbKPNO6GKOgWp4uZgTsCYXKuoGm9evhKe1a(bNA2q(eKCmr5lXwma0WabvJeyoX7GUToaOBtiHI0bbGNIdb7O2isqODBvWorYNkXrrzgloy6dvdhKP3MyuLihc2rDg0Md7uLYbKPNOQffyCAGbcQhgCqKjAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybrLzS4GPpunCqMEBIrvICiyh10CeSnAoStfePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIOcI0a9Ukyqi7NEyWbrAPathdMgoHxBfjlPECSGOYmwCW0hQgoitVnXOkroeSJA6jpoZHDQs5aY0tu1IcmonWab1ddoiIqcPeePb6DvWGq2p9WGdI0sbMogmnCcV2kadtGinqVRcgeY(PhgCqKwkW0XGPHt41wnowquRGinqVRcgeY(PhgCqKwkW0XGPHt41wrYsQhhliIIYSxPwz)bwlj0H1kboc2gRLgVhe9AdgeY(v7WGdIg1c71c4GyuRei4AFGxtcC1cItUn0TR9vZGq2VATm4GOAHGipNTlZyXbtFOA4Gm92eJQe5qWoQP5iyB0CyNknqVRcah1zxBKpyOammrd07koeSJAJ8bdfy(4MOb6Df9mtWjW4uagMezobZhxfmiK9tpm4GivGKm0hTsvg5yIgO3vCiyh1nCqMEB14ybrYNQmYUYSxPwz)bwBg01METcWAb8jog1Yg1ch1kssOBxlGrTJm9YmwCW0hQgoitVnXOkroeSJ6mOnh2Psd07koeSJArdh2OACSGOwjits5aY0tuDqsud4hCQzd5lJCmrPiZjy(4Qlben6SRVgutY2qvGKm0hYN4iKWxksheaEkoeSJAJibH2TPOmJfhm9HQHdY0BtmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QazXzIgO3vCiyh1g5dgkadZfnm0Pktz2Ru7RRx7dwRnE1AKpyul07ady61cceq3U2jW4Q9bFpN12WsXArpbSBQTHhhw7L1AJxTzVxlx74I0TRLMJGTXAbbcOBx71G1gPHezJAFGoy(uMXIdM(q1Wbz6TjgvjYHGDutZrW2O5WovAGExfaoQZU2iFWqbyyIgO3vbGJ6SRnYhmubsYqF0kvwCW0vCiyh1KWXaoXHcLefahQpijAIgO3vCiyh1g5dgkadt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybrMOb6Dfhc2rDdhKP3wnowqKjAGExzKpyOHEhyatxbyyIgO3v0ZmbNaJtbyuM9k1(661(G1AJxTg5dg1c9oWaMETGab0TRDcmUAFW3ZzTnSuSw0ta7MAB4XH1EzT24vB271Y1oUiD7AP5iyBSwqGa621EnyTrAir2O2hOdMpMx7iR9bFpN1M(SDTadSw0ta7MAPN84g1cD4b55SDTxwRnE1EzT9eiQv0WHnokZyXbtFOA4Gm92eJQe5qWoQPN84mh2Psd07kJahOlqD21KqhubyyIsAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybres4lPKgO3vg5dgAO3bgW0vagMOb6Df9mtWjW4uaguqrz2RulbAWAPXXvlWaRn71AKK1ch1EzTadSw4v7L12IbGcIMTRLgaobRv0WHnoQfeiGUDTSrTC)WO2RbBxRnE1ccqAGG1s3U2RbRTHdY0BxlnhbBJLzS4GPpunCqMEBIrvIgboqxG6SRjHoO5WovAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybrMOb6Dfhc2rTr(GHcWOm7vQv2gR9H9R2lRDCSGOAB4Gm9212bMZ2QAjqdwlWaRn71kJSR2XXcIg12GbwlCu7L1Ycrc4xT9mQ9AWApOGOANy)Qn9AVgSwrd7ooRLDWAVgSws4yaNyTqV2(eA3CQYmwCW0hQgoitVnXOkroeSJAs4yaN4WCyNknqVR4qWoQB4Gm92QXXcIAvgzN5Igg6uLXCOFyeaghvzmh6hgbGXPTNjnpPktzgloy6dvdhKP3MyuLihc2rnnhbBJMd7uPb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcImjLditprfsAKpyGGAAoc2glZyXbtFOA4Gm92eJQerPPGpy6Md7ujzNvgIRvziUYSxP2xpF2UwGbwl9KhxTxwlnaCcwROHdBCulSx7dwlpdKbBxBdlfRDKKyT9ijRnd6YmwCW0hQgoitVnXOkroeSJA6jpoZHDQ0a9UIdb7Ow0WHnQghliYenqVR4qWoQfnCyJQXXcIALgO3vCiyh1IgoSrfjlPECSGOYSxP2xFbNZAFGxtTmzTa(ehJAzJAHJAfjj0TRfWOw2bR9bFhyTZ8P20RLKDUmJfhm9HQHdY0BtmQsKdb7OMeogWjomh2P(skLYbKPNO6GKOgWp4uZgTsvg5yIKDwziUwji5qH5Igg6uLXCOFyeaghvzmh6hgbGXPTNjnpPktz2Ru7RfzhoXrTpWRP2z(uljpomABETnq7MAB4XHMxBg1sNxtTKC7A98QTHLI1IEcy3ulj7CTxw7aWWiJR2M8Pws25AH(H(akfRnyqi7xTddoiQwb71sJMx7iR9bFpN1cmWA7WaRLEYJRw2bRTh54OZ5v7td61oZNAtVws25YmwCW0hQgoitVnXOkXomqn9Khxzgloy6dvdhKP3MyuLypYXrNZRmRmJfhm9HknqhdQDyGA6jpoZHDQbGJ9mSrfiCiGgtOZrBTijjzh0enqVRaHdb0ycDoARfjjj7G6EKJtbyuMXIdM(qLgOJbXOkXEKJt7Pu2CyNAa4ypdBuzhWXSTgkGIjAIKDwzio53cjUYmwCW0hQ0aDmigvjcmqn8qsZDMePosG5eVd626aGUDzgloy6dvAGogeJQebr(AOZWXYmwCW0hQ0aDmigvjgmiK9tpm4GiZHDQKSZkdXjFzJCkZyXbtFOsd0XGyuLijmImg6SRVmir)kZyXbtFOsd0XGyuL4Ob2pOBRnYhmmh2Psd07koeSJAJ8bdfy(4MezobZhxXHGDuBKpyOcKKH(OmJfhm9HknqhdIrvICiyh1zqBoStvK5emFCfhc2rTr(GHkqgSTjAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybrLzS4GPpuPb6yqmQsKdb7OMEYJZCyNQiLIo7Nsk6xt7WKiZjy(4ksyezm0zxFzqI(PcKKH(q(Taztzgloy6dvAGogeJQeVeq0OZU(AqnjBdlZyXbtFOsd0XGyuLihc2rTr(Grzgloy6dvAGogeJQedah1zxBKpyyoStLgO3vCiyh1g5dgkW8XlZELAL9hyTVw2YQ9YAhTyaeL9G1YETOKxW12sHGDSwjm5XvliqaD7AVgSwcKxltIT0Rv7d0bZNAb8jog1gaUdD7ABPqWowRSLOjv1(6612sHGDSwzlrtwlCu7Xt0pe08AFWAfS)(QfyG1(AzlR2h41a9AVgSwcKxltIT0Rv7d0bZNAb8jog1(G1c9dJaW4Q9AWABPwwTIg2DCAETJS2h89Cw7GLI1cpvzgloy6dvAGogeJQencCGUa1zxtcDqZHDQV84j6NIdb7OgfnPjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF0kvkzXbtxXHGDutp5XPqjrbWH6dsITCAGExze4aDbQZUMe6Gksws94ybruuM9k1(661(AzlR2gE4VVAPr0RfyGG1cceq3U2RbRLa51YQ9b6G5J51(GVNZAbgyTWR2lRD0Ibqu2dwl71IsEbxBlfc2XALWKhxTqV2RbR9vNVMeBPxR2hOdMpQYmwCW0hQ0aDmigvjAe4aDbQZUMe6GMd7uPb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(OvQuYIdMUIdb7OMEYJtHsIcGd1hKeB50a9UYiWb6cuNDnj0bvKSK6XXcIOOmJfhm9HknqhdIrvICiyh10tECMd7ubZtfmiK9tpm4GivGKm0hYN4iKqqKgO3vbdcz)0ddoislfy6yW0Wj8ARghlis(YPm7vQTLMpC7rTsGJGTXA5R2RbRfDWAZETT0Rv7td61gaUdD7AVgS2wkeSJ1k7nhKP3U2jAJoihTlZyXbtFOsd0XGyuLihc2rnnhbBJMd7uPb6Dfhc2rTr(GHcWWenqVR4qWoQnYhmubsYqF0QTa0ua4ypdBuXHGDu3Wbz6TlZELABP5d3EuRe4iyBSw(Q9AWArhS2Sx71G1(QZxR2hOdMp1(0GETbG7q3U2RbRTLcb7yTYEZbz6TRDI2OdYr7YmwCW0hQ0aDmigvjYHGDutZrW2O5WovAGExfaoQZU2iFWqbyyIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgQajzOpALQTa0ua4ypdBuXHGDu3Wbz6TlZyXbtFOsd0XGyuLihc2rnjCmGtCyoStfePb6D1LaIgD21xdQjzBOcWW0Xt0pfhc2rnkAstusd07kqKVg6mCubMpoHeYIdkf1OJKqCqvgkmbI0a9U6sarJo76Rb1KSnufijd9H8zXbtxXHGDutchd4ehkusuaCO(GKO5Igg6uLXCKJzBTOHHUg2Psd07kXe5qWJd62Ard7oovG5JBIsAGExXHGDuBKpyOamiKqkF5Xt0pvkfdJ8bde0eL0a9UkaCuNDTr(GHcWGqcfzobZhxHstbFW0vbYGTPGckkZyXbtFOsd0XGyuLihc2rnjCmGtCyoStLgO3vIjYHGhh0TvJJferLgO3vIjYHGhh0TvKSK6XXcImjsPOZ(PKI(10okZyXbtFOsd0XGyuLihc2rnjCmGtCyoStLgO3vIjYHGhh0TvbYIZKiZjy(4koeSJAJ8bdvGKm0hMOKgO3vbGJ6SRnYhmuagesinqVR4qWoQnYhmuaguyUOHHovzkZyXbtFOsd0XGyuLihc2rDg0Md7uPb6Dfhc2rTOHdBunowquRuLYbKPNO6YJutYsQfnCyJJYmwCW0hQ0aDmigvjYHGDutp5XzoStLgO3vbGJ6SRnYhmuagesij7SYqCYxgIRmJfhm9HknqhdIrvIO0uWhmDZHDQ0a9UkaCuNDTr(GHcmFCt0a9UIdb7O2iFWqbMpU5q)WiamonStLKDwzio5tTfqCMd9dJaW40qsseeYhsvMYmwCW0hQ0aDmigvjYHGDutZrW2yzwz2R8k1YIdM(qf5XhmDQc2f4uZIdMU5WovwCW0vO0uWhmDLOHDhNq32ej7SYqCYNAlK4mr5ldah7zyJQb0OjD94YGKqcPb6D1aA0KUECzqQghliIknqVRgqJM01JldsfjlPECSGikkZELAL9hyTO0SwyV2h8DG1oZNAtVws25AzhSwrMtW8Xh1YbwltNaxTxwlnwlGrzgloy6dvKhFW0jgvjIstbFW0nh2P(YaWXEg2OAanAsxpUminrYoRmexRuLYbKPNOcLMAdXzIsrMtW8XvxciA0zxFnOMKTHQajzOpALkloy6kuAk4dMUcLefahQpijsiHImNG5JR4qWoQnYhmubsYqF0kvwCW0vO0uWhmDfkjkaouFqsKqcP84j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF0kvwCW0vO0uWhmDfkjkaouFqsKckmrd07QaWrD21g5dgkW8Xnrd07koeSJAJ8bdfy(4MarAGExDjGOrND91GAs2gQaZh30lncuQ2waQKrDjGOrND91GAs2gwMXIdM(qf5XhmDIrvIO0uWhmDZHDQbGJ9mSr1aA0KUECzqA6LIuk6SFkPOFnTdtImNG5JR4qWoQnYhmubsYqF0kvwCW0vO0uWhmDfkjkaouFqsSmJfhm9HkYJpy6eJQerPPGpy6Md7udah7zyJQb0OjD94YG0KiLIo7Nsk6xt7WKiZjy(4ksyezm0zxFzqI(PcKKH(OvQS4GPRqPPGpy6kusuaCO(GKOjrMtW8XvxciA0zxFnOMKTHQajzOpALkLs5aY0turMN2iqbIG6lpsnDBIXIdMUcLMc(GPRqjrbWH6dsIeJGOWKiZjy(4koeSJAJ8bdvGKm0hTsLsPCaz6jQiZtBeOarq9LhPMUnXyXbtxHstbFW0vOKOa4q9bjrIrquuM9k1kboc2gRf2RfEVh1EqsS2lRfyG1E5rwl7G1(G12WsXAVmRLK921kA4WghLzS4GPpurE8btNyuLihc2rnnhbBJMd7ufzobZhxDjGOrND91GAs2gQcKbBBIsAGExXHGDulA4WgvJJfejFPCaz6jQU8i1KSKArdh24WKiZjy(4koeSJAJ8bdvGKm0hTsfLefahQpijAIKDwzio5lLditprfBOjHoKeGutYoRneNjAGExfaoQZU2iFWqbMpofLzS4GPpurE8btNyuLihc2rnnhbBJMd7ufzobZhxDjGOrND91GAs2gQcKbBBIsAGExXHGDulA4WgvJJfejFPCaz6jQU8i1KSKArdh24W0Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(OvQOKOa4q9bjrts5aY0tuDqsud4hCQzd5lLditpr1LhPMKLudItUTUNHMnOOmJfhm9HkYJpy6eJQe5qWoQP5iyB0CyNQiZjy(4Qlben6SRVgutY2qvGmyBtusd07koeSJArdh2OACSGi5lLditpr1LhPMKLulA4WghMO8Lhpr)ubGJ6SRnYhmiKqrMtW8XvbGJ6SRnYhmubsYqFiFPCaz6jQU8i1KSKAqCYT19m0rAqHjPCaz6jQoijQb8do1SH8LYbKPNO6YJutYsQbXj3w3ZqZguuMXIdM(qf5XhmDIrvICiyh10CeSnAoStfePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIOcI0a9Ukyqi7NEyWbrAPathdMgoHxBfjlPECSGitusd07koeSJAJ8bdfy(4esinqVR4qWoQnYhmubsYqF0kvBbifMOKgO3vbGJ6SRnYhmuG5JtiH0a9UkaCuNDTr(GHkqsg6JwPAlaPOmJfhm9HkYJpy6eJQe5qWoQPN84mh2PkLditprvlkW40adeupm4GicjKsqKgO3vbdcz)0ddoislfy6yW0Wj8ARammbI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybrTcI0a9Ukyqi7NEyWbrAPathdMgoHxBfjlPECSGikkZyXbtFOI84dMoXOkroeSJA6jpoZHDQ0a9UYiWb6cuNDnj0bvagMarAGExDjGOrND91GAs2gQammbI0a9U6sarJo76Rb1KSnufijd9rRuzXbtxXHGDutp5XPqjrbWH6dsILzS4GPpurE8btNyuLihc2rnjCmGtCyoStfePb6D1LaIgD21xdQjzBOcWW0Xt0pfhc2rnkAstusd07kqKVg6mCubMpoHeYIdkf1OJKqCqvgkmrjisd07Qlben6SRVgutY2qvGKm0hYNfhmDfhc2rnjCmGtCOqjrbWH6dsIesOiZjy(4kJahOlqD21Kqhufijd9bHeksPOZ(PiQDazNcZfnm0PkJ5ihZ2ArddDnStLgO3vIjYHGhh0T1Ig2DCQaZh3eL0a9UIdb7O2iFWqbyqiHu(YJNOFQukgg5dgiOjkPb6Dva4Oo7AJ8bdfGbHekYCcMpUcLMc(GPRcKbBtbfuuM9k1(I0haKyTxdwlkPb7GiyTg5H(b5zT0a9ET8GnQ9YA98QDMdSwJ8q)G8SwJifJYmwCW0hQip(GPtmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QazXzIgO3vOKgSdIGAJ8q)G8ubyuMXIdM(qf5XhmDIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilotusd07koeSJAJ8bdfGbHesd07QaWrD21g5dgkadcjeePb6D1LaIgD21xdQjzBOkqsg6d5ZIdMUIdb7OMeogWjouOKOa4q9bjrkmx0WqNQmLzS4GPpurE8btNyuLihc2rnjCmGtCyoStLgO3vIjYHGhh0TvbYIZenqVRetKdbpoOBRghliIknqVRetKdbpoOBRizj1JJfezUOHHovzkZELABP5d3Eu7fTR9YAPzNOAFXlQTNrTImNG5Jx7d0bZNrT0axTGaKg1EnizTWETxd2(DG1Y0jWv7L1IsAadSmJfhm9HkYJpy6eJQe5qWoQjHJbCIdZHDQ0a9Usmroe84GUTkqwCMOb6DLyICi4XbDBvGKm0hTsLskPb6DLyICi4XbDB14ybrTCwCW0vCiyh1KWXaoXHcLefahQpijsbXSfGkswskmx0WqNQmLzS4GPpurE8btNyuLOJxdg6djnWXzoStLYa7boAy6jsiHV8GcIGUnfMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSK6XXcImrd07koeSJAJ8bdfy(4MarAGExDjGOrND91GAs2gQaZhVmJfhm9HkYJpy6eJQe5qWoQZG2CyNknqVR4qWoQfnCyJQXXcIALQuoGm9evxEKAswsTOHdBCuMXIdM(qf5XhmDIrvIdadm8ukBoStvkhqMEIQe4gqquNDTiZjy(4dtKSZkdX1k1wiXvMXIdM(qf5XhmDIrvICiyh10tECMd7uPb6DvamrD21xtG4qbyyIgO3vCiyh1IgoSr14ybrYNGkZELAL9cG0Owrdh24OwyV2hS2opN1sJZ8P2RbRvK(adPyTKSZ1EnboAYjyTSdwlknf8btVw4O2XbNZAtVwrMtW8XlZyXbtFOI84dMoXOkroeSJAAoc2gnh2P(YaWXEg2OAanAsxpUminjLditprvcCdiiQZUwK5emF8HjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGithpr)uCiyh1zqBsK5emFCfhc2rDg0QajzOpALQTa0ej7SYqCTsTfkhtImNG5JRqPPGpy6QajzOpkZyXbtFOI84dMoXOkroeSJAAoc2gnh2Pgao2ZWgvdOrt66XLbPjPCaz6jQsGBabrD21ImNG5Jpmrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizj1JJfez64j6NIdb7OodAtImNG5JR4qWoQZGwfijd9rRuTfGMizNvgIRvQTq5ysK5emFCfknf8btxfijd9rReKCkZELAL9cG0Owrdh24OwyV2mORfoQnqgSDzgloy6dvKhFW0jgvjYHGDutZrW2O5WovPCaz6jQsGBabrD21ImNG5Jpmrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizj1JJfez64j6NIdb7OodAtImNG5JR4qWoQZGwfijd9rRuTfGMizNvgIRvQTq5ysK5emFCfknf8btxfijd9HjkFza4ypdBunGgnPRhxgKesinqVRgqJM01JldsvGKm0hTsvMwafLzVsTTuiyhRvcCeSnw7OjbMG1AJog8C2UwAS2RbRDYJRwbpUAZETxdwBl9A1(aDW8PmJfhm9HkYJpy6eJQe5qWoQP5iyB0CyNknqVR4qWoQnYhmuagMOb6Dfhc2rTr(GHkqsg6JwPAlanrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizj1JJfezIsrMtW8XvO0uWhmDvGKm0hesya4ypdBuXHGDu3Wbz6TPOm7vQTLcb7yTsGJGTXAhnjWeSwB0XGNZ21sJ1EnyTtEC1k4XvB2R9AWAF15Rv7d0bZNYmwCW0hQip(GPtmQsKdb7OMMJGTrZHDQ0a9UkaCuNDTr(GHcWWenqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmubsYqF0kvBbOjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlPECSGitukYCcMpUcLMc(GPRcKKH(Gqcdah7zyJkoeSJ6goitVnfLzVsTTuiyhRvcCeSnw7OjbMG1sJ1EnyTtEC1k4XvB2R9AWAjqETSAFGoy(ulSxl8QfoQ1ZRwGbcw7d8AQ9vNVwTzuBl9ALzS4GPpurE8btNyuLihc2rnnhbBJMd7uPb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHcmFCtGinqVRUeq0OZU(AqnjBdvagMarAGExDjGOrND91GAs2gQcKKH(OvQ2cqt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJksws94ybrLzVsTY2nOx71G1ECyJxTWrTqVwusuaCyTb72yTSdw71GbwlCulzgyTxd71Mowl6izBZRfyG1sZrW2yT8O2rMET8O22jqTnSuSw0ta7MAfnCyJJAVS2g4vlpN1IoscXrTWETxdwBlfc2XALqssZbij6xTt0gDqoAxlCul2IbGggiyzgloy6dvKhFW0jgvjYHGDutZrW2O5WovPCaz6jQqsJ8bdeutZrW2OjAGExXHGDulA4WgvJJfejFQuYIdkf1OJKqC0IidfMyXbLIA0rsioKVmMOb6DfiYxdDgoQaZhVmJfhm9HkYJpy6eJQe5qWoQrjnM5aMU5WovPCaz6jQqsJ8bdeutZrW2OjAGExXHGDulA4WgvJJfe1knqVR4qWoQfnCyJksws94ybrMyXbLIA0rsioKVmMOb6DfiYxdDgoQaZhVmJfhm9HkYJpy6eJQe5qWoQPN84kZyXbtFOI84dMoXOkruAk4dMU5WovPCaz6jQsGBabrD21ImNG5JpkZyXbtFOI84dMoXOkroeSJAAoc2g)3)(F]] )

    
end