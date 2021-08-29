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


    spec:RegisterPack( "Arcane", 20210829, [[devNChqiPK6rQsIlPkPQWMOiFsvQrHeDkKWQKsu9kekZIIQBjLqSls(frOHruPJruAzev5ziuzAerPRHazBerLVPkP04KsGZjLGwhcv9ovjvfzEQsCpK0(iQQdkLilKi4HsjzIervYfjIcBuvsvjFuvsv1ijIQuNuvsLvsr5LQsQk1mrG6Msjk7KiYpvLuLHQkjTuvjfpLsMkc4QervTvvjvf1xjIIglrf7vv9xsnyLomQfJupMWKb6YqBwQ(mLA0sXPbTAPesVgHmBfDBeTBQ(TOHtHJlLqTCHNRW0v56a2or67QIXtuCEPuRNiQI5JG2VK)Y(jW3cKp8lj5jx5jRCBbYRfQKvYrqYLGKCFRRTb(TmybrSn(TCMe)wTuiyh)wgC7zYGFc8TgjqiWVvZDgdIxIs0gEna0krskXbKeyYhmDrW9tIdiPqIFlAa48ED(N(BbYh(LK8KR8KvUTa51cvYk5ii5sqs2V1WafFjj5K33QbccI(N(BbIdX3QLX2yTTuiyhlZAjaBGXvR8AHMxR8KR8KTmRmRvnSBJdIVmRfPwj)bw712ak4zTwqYwvBd7GtOBxB2Rv0WUJZAH(HrayCW0Rf6JdzWAZETVfSlWPMfhm93QYSwKABvd72yTCiyh1qVdD41U2lRLdb7OUHdY0BxlLWRwhLIrTpOF1oHsXA5rTCiyh1nCqMEBkuLzTi1k5v6VVALmKMc(WAHETT0RNKrTTOaJRwAuWadS22jW7aRnbUAZETb72yTSdwRNxTadOBxBlfc2XALmKXyMdy6QYSwKABjWwuGXvRraZaETR9YAbgyTTuiyhR9vZhmEpQf7DuCqPyTImNG5JxlnpqWAtV2wj51RPwS3rXnuFRjCCJpb(wnCqME7pb(ss2pb(wOZ0te8lHVfloy6FluAk4dM(3cehIaACW0)wVUETZ8P20RLKDUw2bRvK5emF8rTCG1kssOBxlGH51AN1Ynidwl7G1IsZVLiGhgq(BrYoRmexTVqTwItU1AQwPCaz6jQsGBabrD21ImNG5JpQ1uTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2xQvw5wlf)7lj59jW3cDMEIGFj8TaXHiGghm9VLKjw7d7xTxw74ybr12Wbz6TRTdmNTv1sGgSwGbwB2RvwjxTJJfenQTbdSw4O2lRLfIeWVA7zu71G1Eqbr1oX(vB61EnyTIg2DCwl7G1EnyTKWXaoXAHET9j0U5uFlrapmG83IYALYbKPNOACSGiDdhKP3UwcjS2dsI1(sTYk3APOwt1sd07koeSJ6goitVTACSGOAFPwzLCFlrdd9VLSFlwCW0)wCiyh1KWXaoXX)(sI4(e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVfioeb04GP)TKmBqVwGb0TRvYG0ODG8S2xVa0zxGMxRGhxTCTD8PwuMl4AjHJbCIJAFAGtS2hgEq3U2Eg1EnyT0a9ET8v71G1oooUAZETxdwBhA3CFlrapmG83cBXaqddeuHKgTdKN6maD2fyTMQ9GKyTVulXj3Anv7L22tujYCcMp(Owt1kYCcMpUcjnAhip1za6SlqvGKm0h1k)ALvY1cQ1uTTUwwCW0viPr7a5PodqNDbQaHdMEIG)7ljj7NaFl0z6jc(LW3Ifhm9V1ibMt8oOBRda62FlrapmG83IgO3vCiyh1g5dgkaJAnv7XHnEkq44yxG1(c1ALvUFlNjXV1ibMt8oOBRda62)7ljc6tGVf6m9eb)s4BXIdM(3AKaZjEh0T1baD7VLiGhgq(BjLditprfsAKpyGGAAoc2gR1uTImNG5JRUeq0OZU(AqnjBdvbsYqFu7luRfLbfahQpijwRPAfzobZhxXHGDuBKpyOcKKH(O2xOwlL1IYGcGd1hKeRTLxR8QLIAnv7XHnEkq44yxG1k)ALvUFlNjXV1ibMt8oOBRda62)7ljj3NaFl0z6jc(LW3seWddi)TKYbKPNOcjnYhmqqnnhbBJ1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQ9fQ1IYGcGd1hKeR1uTImNG5JR4qWoQnYhmubsYqFu7luRLYArzqbWH6dsI12YRvE1srTMQLYABDTylgaAyGGQrcmN4Dq3wha0TRLqcRvKoia8uCiyh1grccTBRc2jQw5tTwcQwcjSwrMtW8XvJeyoX7GUToaOBRcKKH(Ow5xRSYk3AP4BXIdM(3kyqi7NEyWbr)7lPx7NaFl0z6jc(LW3seWddi)TKYbKPNOQffyCAGbcQhgCquTMQvK5emFCfhc2rTr(GHkqsg6JAFHATOmOa4q9bjXAnvlL126AXwma0WabvJeyoX7GUToaOBxlHewRiDqa4P4qWoQnIeeA3wfStuTYNATeuTesyTImNG5JRgjWCI3bDBDaq3wfijd9rTYVwzLvU1sX3Ifhm9V1LaIgD21xdQjzB4)(sQf8jW3cDMEIGFj8Teb8WaYFlJaLQTfGkzvxciA0zxFnOMKTHFlwCW0)wCiyh1g5dg)7lPw4NaFl0z6jc(LW3seWddi)TKYbKPNOcjnYhmqqnnhbBJ1AQwrMtW8Xvbdcz)0ddoisfijd9rTVqTwuguaCO(GKyTMQvkhqMEIQdsIAa)GtnBuR8PwR8KBTMQLYABDTI0bbGNIdb7O2isqODBf6m9ebRLqcRT11kLditprfpF42d9OTl0ImNG5JpQLqcRvK5emFC1LaIgD21xdQjzBOkqsg6JAFHATuwlkdkaouFqsS2wETYRwkQLIVfloy6FRaWrD21g5dg)7ljzL7NaFl0z6jc(LW3seWddi)TKYbKPNOcjnYhmqqnnhbBJ1AQwJaLQTfGkzvbGJ6SRnYhm(wS4GP)TcgeY(PhgCq0)(sswz)e4BHotprWVe(wIaEya5VLuoGm9evTOaJtdmqq9WGdIQ1uTTUwPCaz6jQAYji0T1xEKFlwCW0)wxciA0zxFnOMKTH)7ljzL3NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)Bj5pWALNdwlhc2XAP5iyBSwOxBl9Qe71869Q1M(SDTWETsyMj4eyC1YoyT8v7e5XvR8QTvTAuRrKcbc(Teb8WaYFlAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwt1sd07QaWrD21g5dgkaJAnvlnqVR4qWoQnYhmuag1AQwAGExXHGDu3Wbz6TvJJfevR8PwRSsUAnvlnqVR4qWoQnYhmubsYqFu7luRLfhmDfhc2rnnhbBJkuguaCO(GKyTMQLgO3v0ZmbNaJtby8VVKKL4(e4BHotprWVe(wS4GP)Tcah1zxBKpy8TaXHiGghm9VLK)aRvEoyTVM8vRf612sVATPpBxlSxReMzcobgxTSdwR8QTvTAuRrKIVLiGhgq(Brd07QaWrD21g5dgkW8XR1uT0a9UIEMj4eyCkaJAnvlL1kLditpr1bjrnGFWPMnQv(1sCYTwcjSwrMtW8Xvbdcz)0ddoisfijd9rTYVwzLxTuuRPAPSwAGExXHGDu3Wbz6TvJJfevR8PwRSeuTesyT0a9Usmroe84GUTACSGOALp1ALTwkQ1uTuwBRRvKoia8uCiyh1grccTBRqNPNiyTesyTTUwPCaz6jQ45d3EOhTDHwK5emF8rTu8VVKKvY(jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOaZhVwt1szTs5aY0tuDqsud4hCQzJALFTeNCRLqcRvK5emFCvWGq2p9WGdIubsYqFuR8Rvw5vlf1AQwkRT11ksheaEkoeSJAJibH2TvOZ0teSwcjS2wxRuoGm9ev88HBp0J2UqlYCcMp(Owk(wS4GP)Tcah1zxBKpy8VVKKLG(e4BHotprWVe(wIaEya5VLuoGm9eviPr(GbcQP5iyBSwt1szT0a9UIdb7Ow0WHnQghliQw5tTw5vlHewRiZjy(4koeSJ6mOvbYGTRLIAnvlL126ApEI(Pcah1zxBKpyOqNPNiyTesyTImNG5JRcah1zxBKpyOcKKH(Ow5xlbvlf1AQwrMtW8XvCiyh1g5dgQajzOp0OmgO4qWALp1Ajo5wRPAPS2wxRiDqa4P4qWoQnIeeA3wHotprWAjKWABDTs5aY0tuXZhU9qpA7cTiZjy(4JAP4BXIdM(3kyqi7NEyWbr)7ljzLCFc8TqNPNi4xcFlwCW0)wxciA0zxFnOMKTHFlqCicOXbt)Bjz2GETbG7q3UwJibH2TnVwGbw7LhzT0TRfEdC2Rf61Mbig1EzT8eA71cVAFGxtTSX3seWddi)TKYbKPNO6GKOgWp4uZg1(sTeKCR1uTs5aY0tuDqsud4hCQzJALFTeNCR1uTuwBRRfBXaqddeunsG5eVd626aGUDTesyTI0bbGNIdb7O2isqODBvWor1kFQ1sq1sX)(ss2x7NaFl0z6jc(LW3seWddi)TKYbKPNOQffyCAGbcQhgCquTMQLgO3vCiyh1IgoSr14ybr1(sT0a9UIdb7Ow0WHnQizz0JJfe9TyXbt)BXHGDuNb9)(ss2wWNaFl0z6jc(LW3seWddi)TarAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOAPwlisd07QGbHSF6HbhePLcmDmyA4eETvKSm6XXcI(wS4GP)T4qWoQP5iyB8FFjjBl8tGVf6m9eb)s4Bjc4HbK)ws5aY0tu1IcmonWab1ddoiQwcjSwkRfePb6DvWGq2p9WGdI0sbMogmnCcV2kaJAnvlisd07QGbHSF6HbhePLcmDmyA4eETvJJfev7l1cI0a9Ukyqi7NEyWbrAPathdMgoHxBfjlJECSGOAP4BXIdM(3Idb7OMEYJ7FFjjp5(jW3cDMEIGFj8TyXbt)BXHGDutZrW243cehIaACW0)ws(dSwsOdRvcCeSnwlnEpi61gmiK9R2HbhenQf2RfWbXOwjqW1(aVMe4QfeNCBOBx7RHbHSF1AzWbr1cbrEoB)Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dfhc2rTr(GHcmF8AnvlnqVRONzcobgNcWOwt1kYCcMpUkyqi7NEyWbrQajzOpQ9fQ1kRCR1uT0a9UIdb7OUHdY0BRghliQw5tTwzLC)7lj5j7NaFl0z6jc(LW3Ifhm9Vfhc2rDg0FlqCicOXbt)Bj5pWAZGU20RvawlGpXXOw2Ow4OwrscD7AbmQDKP)Teb8WaYFlAGExXHGDulA4WgvJJfev7l1sC1AQwPCaz6jQoijQb8do1SrTYVwzLBTMQLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xlbvlHewBRRvKoia8uCiyh1grccTBRqNPNiyTu8VVKKN8(e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVLOHH(3s2VLiGhgq(Brd07kXe5qWJd62QazXvRPAPb6Dfhc2rTr(GHcW4FFjjpI7tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TED9AFWATXRwJ8bJAHEhyatVwqGa621obgxTp475S2gwkwl6jGDtTn84WAVSwB8Qn79A5AhxKUDT0CeSnwliqaD7AVgS2inKiBu7d0bZNVLiGhgq(Brd07QaWrD21g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(O2xOwlloy6koeSJAs4yaN4qHYGcGd1hKeR1uT0a9UIdb7O2iFWqbyuRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGOAnvlnqVR4qWoQB4Gm92QXXcIQ1uT0a9UYiFWqd9oWaMUcWOwt1sd07k6zMGtGXPam(3xsYtY(jW3cDMEIGFj8TyXbt)BXHGDutp5X9TaXHiGghm9V1RRx7dwRnE1AKpyul07ady61cceq3U2jW4Q9bFpN12WsXArpbSBQTHhhw7L1AJxTzVxlx74I0TRLMJGTXAbbcOBx71G1gPHezJAFGoy(yETJS2h89CwB6Z21cmWArpbSBQLEYJBul0HhKNZ21EzT24v7L12tGOwrdh244Bjc4HbK)w0a9UYiWb6cuNDnj0bvag1AQwkRLgO3vCiyh1IgoSr14ybr1(sT0a9UIdb7Ow0WHnQizz0JJfevlHewBRRLYAPb6DLr(GHg6DGbmDfGrTMQLgO3v0ZmbNaJtbyulf1sX)(ssEe0NaFl0z6jc(LW3Ifhm9VLrGd0fOo7AsOd(TaXHiGghm9VfbAWAPXXvlWaRn71AKK1ch1EzTadSw4v7L12IbGcIMTRLgaobRv0WHnoQfeiGUDTSrTC)WO2RbBxRnE1ccqAGG1s3U2RbRTHdY0BxlnhbBJFlrapmG83IgO3vCiyh1IgoSr14ybr1(sT0a9UIdb7Ow0WHnQizz0JJfevRPAPb6Dfhc2rTr(GHcW4FFjjpj3NaFl0z6jc(LW3cehIaACW0)wsMyTpSF1EzTJJfevBdhKP3U2oWC2wvlbAWAbgyTzVwzLC1oowq0O2gmWAHJAVSwwisa)QTNrTxdw7bfev7e7xTPx71G1kAy3XzTSdw71G1schd4eRf612Nq7Mt9TyXbt)BXHGDutchd4ehFlOFyeag33s2VLOHH(3s2VLiGhgq(Brd07koeSJ6goitVTACSGOAFPwzLCFlOFyeagN2EM088Bj7)(ssEV2pb(wOZ0te8lHVLiGhgq(Brd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1AQwPCaz6jQqsJ8bdeutZrW243Ifhm9Vfhc2rnnhbBJ)7lj51c(e4BHotprWVe(wIaEya5Vfj7SYqC1(sTYsqFlwCW0)wO0uWhm9)9LK8AHFc8TqNPNi4xcFlwCW0)wCiyh10tECFlqCicOXbt)B965Z21cmWAPN84Q9YAPbGtWAfnCyJJAH9AFWA5zGmy7AByPyTJKeRThjzTzq)Teb8WaYFlAGExXHGDulA4WgvJJfevRPAPb6Dfhc2rTOHdBunowquTVulnqVR4qWoQfnCyJkswg94ybr)7ljItUFc8TqNPNi4xcFlqCicOXbt)B96l4Cw7d8AQLjRfWN4yulBulCuRijHUDTag1YoyTp47aRDMp1METKSZFlwCW0)wCiyh1KWXaoXX3c6hgbGX9TK9BjAyO)TK9Bjc4HbK)wTUwkRvkhqMEIQdsIAa)GtnBu7luRvw5wRPAjzNvgIR2xQL4KBTu8TG(HrayCA7zsZZVLS)7ljIt2pb(wOZ0te8lHVfioeb04GP)TE1i7WjoQ9bEn1oZNAj5XHrBZRTbA3uBdpo08AZOw68AQLKBxRNxTnSuSw0ta7MAjzNR9YAhaggzC12Kp1sYoxl0p0hqPyTbdcz)QDyWbr1kyVwA08AhzTp475SwGbwBhgyT0tEC1YoyT9ihhDoVAFAqV2z(uB61sYo)TyXbt)B1HbQPN84(3xseN8(e4BXIdM(3Qh54OZ59TqNPNi4xc)7FFRoC0aDBDAGogFc8LKSFc8TqNPNi4xcFlwCW0)wO0uWhm9Vfioeb04GP)TKmBqV2aWDOBxlcVgmQ9AWATSQnJAjGKzTt0gDqoG4W8AFWAFy)Q9YALmKM1sJ9mWAVgSwcKxltIT0Rw7d0bZhvTs(dSw4vlpQDKPxlpQ91KVATn8O2o0HJgeS2eiQ9bFlfRDyG(vBce1kA4WghFlrapmG83IYAdah7zyJQdjnYGN6homuOZ0teSwcjSwkRnaCSNHnQgqJM01Jldsf6m9ebR1uTTUwPCaz6jQmc0ayo1O0SwQ1kBTuulf1AQwkRLgO3vbGJ6SRnYhmuG5JxlHewRrGs12cqLSkoeSJAAoc2gRLIAnvRiZjy(4QaWrD21g5dgQajzOp(3xsY7tGVf6m9eb)s4BXIdM(3cLMc(GP)TaXHiGghm9V1RRx7d(wkwBh6WrdcwBce1kYCcMpETpqhmFg1YoyTdd0VAtGOwrdh24W8AncygWdk5bRvYqAwBkfJArPy0(AGUDT4CGFlrapmG8364j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvbGJ6SRnYhmubsYqFuRPAfzobZhxXHGDuBKpyOcKKH(Owt1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQ1iqPABbOswfhc2rnnhbBJ)7ljI7tGVf6m9eb)s4Bjc4HbK)wbGJ9mSrfiCiGgtOZrBTijjzhuHotprWAnvlnqVRaHdb0ycDoARfjjj7G6EKJtby8TyXbt)B1HbQPN84(3xss2pb(wOZ0te8lHVLiGhgq(Bfao2ZWgv2bCmBRHcOyIk0z6jcwRPAjzNvgIRw5xBlKG(wS4GP)T6rooTNs5)9Leb9jW3cDMEIGFj8TyXbt)BXHGDutchd4ehFlrdd9VLSFlrapmG83kaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rDdhKP3wnowquTVulnqVR4qWoQB4Gm92kswg94ybr1AQwkRLYAPb6Dfhc2rTr(GHcmF8AnvRiZjy(4koeSJAJ8bdvGmy7APOwcjSwqKgO3vxciA0zxFnOMKTHkaJAP4FFjj5(e4BHotprWVe(wIaEya5Vva4ypdBunGgnPRhxgKk0z6jc(TyXbt)BfaoQZU2iFW4FFj9A)e4BHotprWVe(wIaEya5VLiZjy(4QaWrD21g5dgQazW2FlwCW0)wCiyh1zq)VVKAbFc8TqNPNi4xcFlrapmG83sK5emFCva4Oo7AJ8bdvGmy7AnvlnqVR4qWoQfnCyJQXXcIQ9LAPb6Dfhc2rTOHdBurYYOhhli6BXIdM(3Idb7OMEYJ7FFj1c)e4BHotprWVe(wIaEya5VvRRnaCSNHnQoK0idEQF4WqHotprWAjKWAfPdcapLnSF6SRVgupHIgf6m9eb)wS4GP)Tar(AOZWX)9LKSY9tGVfloy6FRaWrD21g5dgFl0z6jc(LW)(sswz)e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVfioeb04GP)TED9AFW3bwlF1sYYu74ybrJAZETTQv1YoyTpyTnSu0FF1cmqWABzjbQTnEMxlWaRLRDCSGOAVSwJaLI(vljGlAGUDTa(ehJAda3HUDTxdwRK3CqME7ANOn6GC0(Bjc4HbK)w0a9Usmroe84GUTkqwC1AQwAGExjMihcECq3wnowquTuRLgO3vIjYHGhh0TvKSm6XXcIQ1uTIuk6SFkPOFnTJAnvRiZjy(4ksyezm0zxFzqI(PcKbBxRPABDTs5aY0tuHKg5dgiOMMJGTXAnvRiZjy(4koeSJAJ8bdvGmy7)9LKSY7tGVf6m9eb)s4Bjc4HbK)wTU2aWXEg2O6qsJm4P(Hddf6m9ebR1uTuwBRRnaCSNHnQgqJM01Jldsf6m9ebRLqcRLYALYbKPNOYiqdG5uJsZAPwRS1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwkQLIVfioeb04GP)TKugK8C2U2hSwdgg1AKhm9AbgyTpWRP2w6vnVwAGRw4v7dCoRDYJR2z621IEcy3uBpJAPZRP2RbR91KVATSdwBl9Q1(aDW8zulGpXXO2aWDOBx71G1AzvBg1sajZANOn6GCaXX3Ifhm9VLrEW0)3xsYsCFc8TqNPNi4xcFlrapmG83IgO3vbGJ6SRnYhmuG5JxlHewRrGs12cqLSkoeSJAAoc2g)wS4GP)Tar(AOZWX)9LKSs2pb(wOZ0te8lHVLiGhgq(Brd07QaWrD21g5dgkW8XRLqcR1iqPABbOswfhc2rnnhbBJFlwCW0)wbdcz)0ddoi6FFjjlb9jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqfijd9rTVulL1k5QLy1kVAB51gao2ZWgvdOrt66XLbPcDMEIG1sX3Ifhm9VfjmImg6SRVmir)(3xsYk5(e4BHotprWVe(wS4GP)T4qWoQnYhm(wG4qeqJdM(3sYSb9Ada3HUDTxdwRK3CqME7ANOn6GC028AbgyTT0Rwln2ZaRLa51YQ9YAbbinQLRTdmNTRDCSGieSwAoc2g)wIaEya5VLuoGm9eviPr(GbcQP5iyBSwt1sd07QaWrD21g5dgkaJAnvlL1sYoRmexTVulL1kpcQwIvlL1kRCRTLxRiLIo7NIO2bK9APOwkQLqcRLgO3vIjYHGhh0TvJJfevl1APb6DLyICi4XbDBfjlJECSGOAP4FFjj7R9tGVf6m9eb)s4Bjc4HbK)ws5aY0tuHKg5dgiOMMJGTXAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizz0JJfevRPAPb6Dfhc2rTr(GHcW4BXIdM(3Idb7OMMJGTX)9LKSTGpb(wOZ0te8lHVfloy6FRrcmN4Dq3wha0T)wIaEya5VfnqVRcah1zxBKpyOaZhVwcjSwJaLQTfGkzvCiyh10CeSnwlHewRrGs12cqLSQGbHSF6HbhevlHewlL1AeOuTTaujRce5RHodhR1uTTU2aWXEg2OAanAsxpUmivOZ0teSwk(wotIFRrcmN4Dq3wha0T)3xsY2c)e4BHotprWVe(wIaEya5VfnqVRcah1zxBKpyOaZhVwcjSwJaLQTfGkzvCiyh10CeSnwlHewRrGs12cqLSQGbHSF6HbhevlHewlL1AeOuTTaujRce5RHodhR1uTTU2aWXEg2OAanAsxpUmivOZ0teSwk(wS4GP)TUeq0OZU(AqnjBd)3xsYtUFc8TqNPNi4xcFlrapmG83YiqPABbOsw1LaIgD21xdQjzB43Ifhm9Vfhc2rTr(GX)(ssEY(jW3cDMEIGFj8TyXbt)Bze4aDbQZUMe6GFlqCicOXbt)Bj5pWAF1SLv7L1oAXaik5bRL9ArzUGRTLcb7yTsyYJRwqGa621EnyTeiVwMeBPxT2hOdMp1c4tCmQnaCh6212sHGDSwjdrtQQ911RTLcb7yTsgIMSw4O2JNOFiO51(G1ky)9vlWaR9vZwwTpWRb61EnyTeiVwMeBPxT2hOdMp1c4tCmQ9bRf6hgbGXv71G12sTSAfnS7408AhzTp475S2blfRfEQVLiGhgq(B16ApEI(P4qWoQrrtQqNPNiyTMQfePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9rTVqTwkRLfhmDfhc2rn9KhNcLbfahQpijwBlVwAGExze4aDbQZUMe6Gkswg94ybr1sX)(ssEY7tGVf6m9eb)s4BXIdM(3YiWb6cuNDnj0b)wG4qeqJdM(3611R9vZwwTn8WFF1sJOxlWabRfeiGUDTxdwlbYRLv7d0bZhZR9bFpN1cmWAHxTxw7OfdGOKhSw2RfL5cU2wkeSJ1kHjpUAHETxdw7RjFvj2sVATpqhmFuFlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(O2xOwlL1YIdMUIdb7OMEYJtHYGcGd1hKeRTLxlnqVRmcCGUa1zxtcDqfjlJECSGOAP4FFjjpI7tGVf6m9eb)s4Bjc4HbK)wG5PcgeY(PhgCqKkqsg6JALFTeuTesyTGinqVRcgeY(PhgCqKwkW0XGPHt41wnowquTYVw5(TyXbt)BXHGDutp5X9VVKKNK9tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TKmXAFy)Q9YAjzIWAhabw7dwBdlfRf9eWUPws25A7zu71G1I(bdS2w6vR9b6G5J51IsrVwyV2Rbd89O2XbNZApijwBGKm0HUDTPx7RjFvvTVU79O20NTRLgVdJAVSwAGWR9YAL8Grwl7G1kzinRf2RnaCh621EnyTww1MrTeqYS2jAJoihqCO(wIaEya5VLiZjy(4koeSJAJ8bdvGmy7Anvlj7SYqC1(sTuwRKvU1sSAPSwzLBTT8AfPu0z)ue1oGSxlf1srTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSm6XXcIQ1uTuwBRRnaCSNHnQgqJM01Jldsf6m9ebRLqcRvkhqMEIkJanaMtnknRLATYwlf1AQ2wxBa4ypdBuDiPrg8u)WHHcDMEIG1AQ2wxBa4ypdBuXHGDu3Wbz6TvOZ0te8FFjjpc6tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TKahbBJ1oAsGjyTEE1sJ1cmqWA5R2RbRfDWAZETT0RwlSxRKH0uWhm9AHJAdKbBxlpQfmsddOBxROHdBCu7dCoRLKjcRfE1EmryTZ0TXO2lRLgi8AVMibSBQnqsg6q3Uws25VLiGhgq(Brd07koeSJAJ8bdfGrTMQLgO3vCiyh1g5dgQajzOpQ9fQ1AlaR1uTImNG5JRqPPGpy6QajzOp(3xsYtY9jW3cDMEIGFj8TyXbt)BXHGDutZrW243cehIaACW0)wsGJGTXAhnjWeSwE(WTh1sJ1EnyTtEC1k4Xvl0R9AWAFn5Rw7d0bZNA5rTeiVwwTpW5S2ahxgyTxdwROHdBCu7Wa97Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqfijd9rTVqTwBbyTMQT11gao2ZWgvCiyh1nCqMEBf6m9eb)3xsY71(jW3cDMEIGFj8Tenm0)wY(TqoMT1Igg6Ay)Brd07kXe5qWJd62Ard7oovG5JBIsAGExXHGDuBKpyOamiKqkB9Xt0pvkfdJ8bde0eL0a9UkaCuNDTr(GHcWGqcfzobZhxHstbFW0vbYGTPGck(wIaEya5Vfisd07Qlben6SRVgutY2qfGrTMQ94j6NIdb7OgfnPcDMEIG1AQwkRLgO3vGiFn0z4OcmF8AjKWAzXbLIA0rsioQLATYwlf1AQwqKgO3vxciA0zxFnOMKTHQajzOpQv(1YIdMUIdb7OMeogWjouOmOa4q9bjXVfloy6FloeSJAs4yaN44FFjjVwWNaFl0z6jc(LW3Ifhm9Vfhc2rnjCmGtC8TaXHiGghm9V1RRx7d(oWALI(10omVwijjcc5dNTRfyG12Qwv7td61kyddeS2lR1ZR2hECyTgrkg12JKS2wwsGVLiGhgq(BjsPOZ(PKI(10oQ1uT0a9Usmroe84GUTACSGOAPwlnqVRetKdbpoOBRizz0JJfe9VVKKxl8tGVf6m9eb)s4BbIdranoy6FlRJJRwGb0TRTvTQ2wQLv7td612sVATn8OwAe9Abgi43seWddi)TOb6DLyICi4XbDBvGS4Q1uTImNG5JR4qWoQnYhmubsYqFuRPAPSwAGExfaoQZU2iFWqbyulHewlnqVR4qWoQnYhmuag1sX3s0Wq)Bj73Ifhm9Vfhc2rnjCmGtC8VVKio5(jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfev7luRvkhqMEIQlpsnjlJw0WHno(wS4GP)T4qWoQZG(FFjrCY(jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqbyulHewlj7SYqC1k)ALLG(wS4GP)T4qWoQPN84(3xseN8(e4BHotprWVe(wS4GP)TqPPGpy6FlOFyeagNg2)wKSZkdXjFQTac6Bb9dJaW40qsseeYh(TK9Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AnvlnqVR4qWoQnYhmuG5J)VVKioI7tGVfloy6FloeSJAAoc2g)wOZ0te8lH)9VVvKhFW0)e4ljz)e4BHotprWVe(wS4GP)TqPPGpy6FlqCicOXbt)Bj5pWArPzTWETp47aRDMp1METKSZ1YoyTImNG5JpQLdSwMobUAVSwASwaJVLiGhgq(B16Adah7zyJQb0OjD94YGuHotprWAnvlj7SYqC1(c1ALYbKPNOcLMAdXvRPAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQ9fQ1YIdMUcLMc(GPRqzqbWH6dsI1siH1kYCcMpUIdb7O2iFWqfijd9rTVqTwwCW0vO0uWhmDfkdkaouFqsSwcjSwkR94j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvbGJ6SRnYhmubsYqFu7luRLfhmDfknf8btxHYGcGd1hKeRLIAPOwt1sd07QaWrD21g5dgkW8XR1uT0a9UIdb7O2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8AnvBRR1iqPABbOsw1LaIgD21xdQjzB4)(ssEFc8TqNPNi4xcFlrapmG83kaCSNHnQgqJM01Jldsf6m9ebR1uTTUwrkfD2pLu0VM2rTMQvK5emFCfhc2rTr(GHkqsg6JAFHATS4GPRqPPGpy6kuguaCO(GK43Ifhm9Vfknf8bt)FFjrCFc8TqNPNi4xcFlrapmG83kaCSNHnQgqJM01Jldsf6m9ebR1uTIuk6SFkPOFnTJAnvRiZjy(4ksyezm0zxFzqI(PcKKH(O2xOwlloy6kuAk4dMUcLbfahQpijwRPAfzobZhxDjGOrND91GAs2gQcKKH(O2xOwlL1kLditprfzEAJaficQV8i10TRLy1YIdMUcLMc(GPRqzqbWH6dsI1sSAjUAPOwt1kYCcMpUIdb7O2iFWqfijd9rTVqTwkRvkhqMEIkY80gbkqeuF5rQPBxlXQLfhmDfknf8btxHYGcGd1hKeRLy1sC1sX3Ifhm9Vfknf8bt)FFjjz)e4BHotprWVe(wS4GP)T4qWoQP5iyB8BbIdranoy6FljWrW2yTWETW79O2dsI1EzTadS2lpYAzhS2hS2gwkw7LzTKS3Uwrdh244Bjc4HbK)wImNG5JRUeq0OZU(AqnjBdvbYGTR1uTuwlnqVR4qWoQfnCyJQXXcIQv(1kLditpr1LhPMKLrlA4Wgh1AQwrMtW8XvCiyh1g5dgQajzOpQ9fQ1IYGcGd1hKeR1uTKSZkdXvR8RvkhqMEIk2qtcDijaPMKDwBiUAnvlnqVRcah1zxBKpyOaZhVwk(3xse0NaFl0z6jc(LW3seWddi)TezobZhxDjGOrND91GAs2gQcKbBxRPAPSwAGExXHGDulA4WgvJJfevR8RvkhqMEIQlpsnjlJw0WHnoQ1uThpr)ubGJ6SRnYhmuOZ0teSwt1kYCcMpUkaCuNDTr(GHkqsg6JAFHATOmOa4q9bjXAnvRuoGm9evhKe1a(bNA2Ow5xRuoGm9evxEKAswgnio526EgA2Owk(wS4GP)T4qWoQP5iyB8FFjj5(e4BHotprWVe(wIaEya5VLiZjy(4Qlben6SRVgutY2qvGmy7AnvlL1sd07koeSJArdh2OACSGOALFTs5aY0tuD5rQjzz0IgoSXrTMQLYABDThpr)ubGJ6SRnYhmuOZ0teSwcjSwrMtW8XvbGJ6SRnYhmubsYqFuR8RvkhqMEIQlpsnjlJgeNCBDpdDKg1srTMQvkhqMEIQdsIAa)GtnBuR8RvkhqMEIQlpsnjlJgeNCBDpdnBulfFlwCW0)wCiyh10CeSn(VVKETFc8TqNPNi4xcFlrapmG83cePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIQLATGinqVRcgeY(PhgCqKwkW0XGPHt41wrYYOhhliQwt1szT0a9UIdb7O2iFWqbMpETesyT0a9UIdb7O2iFWqfijd9rTVqTwBbyTuuRPAPSwAGExfaoQZU2iFWqbMpETesyT0a9UkaCuNDTr(GHkqsg6JAFHAT2cWAP4BXIdM(3Idb7OMMJGTX)9Lul4tGVf6m9eb)s4Bjc4HbK)ws5aY0tu1IcmonWab1ddoiQwcjSwkRfePb6DvWGq2p9WGdI0sbMogmnCcV2kaJAnvlisd07QGbHSF6HbhePLcmDmyA4eETvJJfev7l1cI0a9Ukyqi7NEyWbrAPathdMgoHxBfjlJECSGOAP4BXIdM(3Idb7OMEYJ7FFj1c)e4BHotprWVe(wIaEya5VfnqVRmcCGUa1zxtcDqfGrTMQfePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9rTVqTwwCW0vCiyh10tECkuguaCO(GK43Ifhm9Vfhc2rn9Kh3)(ssw5(jW3cDMEIGFj8Tenm0)wY(TqoMT1Igg6Ay)Brd07kXe5qWJd62Ard7oovG5JBIsAGExXHGDuBKpyOamiKqkB9Xt0pvkfdJ8bde0eL0a9UkaCuNDTr(GHcWGqcfzobZhxHstbFW0vbYGTPGck(wIaEya5Vfisd07Qlben6SRVgutY2qfGrTMQ94j6NIdb7OgfnPcDMEIG1AQwkRLgO3vGiFn0z4OcmF8AjKWAzXbLIA0rsioQLATYwlf1AQwkRfePb6D1LaIgD21xdQjzBOkqsg6JALFTS4GPR4qWoQjHJbCIdfkdkaouFqsSwcjSwrMtW8XvgboqxG6SRjHoOkqsg6JAjKWAfPu0z)ue1oGSxlfFlwCW0)wCiyh1KWXaoXX)(sswz)e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVfioeb04GP)TAv6dasS2RbRfLXGDqeSwJ8q)G8SwAGEVwEWg1EzTEE1oZbwRrEOFqEwRrKIX3seWddi)TOb6DLyICi4XbDBvGS4Q1uT0a9UcLXGDqeuBKh6hKNkaJ)9LKSY7tGVf6m9eb)s4BXIdM(3Idb7OMeogWjo(wIgg6Flz)wIaEya5VfnqVRetKdbpoOBRcKfxTMQLYAPb6Dfhc2rTr(GHcWOwcjSwAGExfaoQZU2iFWqbyulHewlisd07Qlben6SRVgutY2qvGKm0h1k)AzXbtxXHGDutchd4ehkuguaCO(GKyTu8VVKKL4(e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVLOHH(3s2VLiGhgq(Brd07kXe5qWJd62QazXvRPAPb6DLyICi4XbDB14ybr1sTwAGExjMihcECq3wrYYOhhli6FFjjRK9tGVf6m9eb)s4BbIdranoy6FRwA(WTh1Er7AVSwA2jQ2w1QA7zuRiZjy(41(aDW8zulnWvliaPrTxdswlSx71GTFhyTmDcC1EzTOmgWa)wIaEya5VfnqVRetKdbpoOBRcKfxTMQLgO3vIjYHGhh0TvbsYqFu7luRLYAPSwAGExjMihcECq3wnowquTT8AzXbtxXHGDutchd4ehkuguaCO(GKyTuulXQ1waQizzQLIVLOHH(3s2Vfloy6FloeSJAs4yaN44FFjjlb9jW3cDMEIGFj8Teb8WaYFlkRnWEGJgMEI1siH126ApOGiOBxlf1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwt1sd07koeSJAJ8bdfy(41AQwqKgO3vxciA0zxFnOMKTHkW8X)wS4GP)TC8AWqFiPboU)9LKSsUpb(wOZ0te8lHVLiGhgq(Brd07koeSJArdh2OACSGOAFHATs5aY0tuD5rQjzz0IgoSXX3Ifhm9Vfhc2rDg0)7ljzFTFc8TqNPNi4xcFlrapmG83skhqMEIQe4gqquNDTiZjy(4JAnvlj7SYqC1(c1ABHe03Ifhm9V1aWadpLY)7ljzBbFc8TqNPNi4xcFlrapmG83IgO3vbWe1zxFnbIdfGrTMQLgO3vCiyh1IgoSr14ybr1k)AjUVfloy6FloeSJA6jpU)9LKSTWpb(wOZ0te8lHVfloy6FloeSJAAoc2g)wG4qeqJdM(3sYlasJAfnCyJJAH9AFWA78CwlnoZNAVgSwr6dmKI1sYox71e4OjNG1YoyTO0uWhm9AHJAhhCoRn9AfzobZh)Bjc4HbK)wTU2aWXEg2OAanAsxpUmivOZ0teSwt1kLditprvcCdiiQZUwK5emF8rTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSm6XXcIQ1uThpr)uCiyh1zqRqNPNiyTMQvK5emFCfhc2rDg0QajzOpQ9fQ1AlaR1uTKSZkdXv7luRTfk3AnvRiZjy(4kuAk4dMUkqsg6J)9LK8K7NaFl0z6jc(LW3seWddi)Tcah7zyJQb0OjD94YGuHotprWAnvRuoGm9evjWnGGOo7ArMtW8Xh1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwt1E8e9tXHGDuNbTcDMEIG1AQwrMtW8XvCiyh1zqRcKKH(O2xOwRTaSwt1sYoRmexTVqT2wOCR1uTImNG5JRqPPGpy6QajzOpQ9LAjo5(TyXbt)BXHGDutZrW24)(ssEY(jW3cDMEIGFj8TyXbt)BXHGDutZrW243cehIaACW0)wsEbqAuROHdBCulSxBg01ch1gid2(Bjc4HbK)ws5aY0tuLa3acI6SRfzobZhFuRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGOAnv7Xt0pfhc2rDg0k0z6jcwRPAfzobZhxXHGDuNbTkqsg6JAFHAT2cWAnvlj7SYqC1(c1ABHYTwt1kYCcMpUcLMc(GPRcKKH(Owt1szTTU2aWXEg2OAanAsxpUmivOZ0teSwcjSwAGExnGgnPRhxgKQajzOpQ9fQ1kBlOwk(3xsYtEFc8TqNPNi4xcFlwCW0)wCiyh10CeSn(TaXHiGghm9Vvlfc2XALahbBJ1oAsGjyT2OJbpNTRLgR9AWAN84QvWJR2Sx71G12sVATpqhmF(wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExXHGDuBKpyOcKKH(O2xOwRTaSwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1AQwkRvK5emFCfknf8btxfijd9rTesyTbGJ9mSrfhc2rDdhKP3wHotprWAP4FFjjpI7tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TAPqWowRe4iyBS2rtcmbR1gDm45SDT0yTxdw7KhxTcEC1M9AVgS2xt(Q1(aDW85Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqfijd9rTVqTwBbyTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSm6XXcIQ1uTuwRiZjy(4kuAk4dMUkqsg6JAjKWAdah7zyJkoeSJ6goitVTcDMEIG1sX)(ssEs2pb(wOZ0te8lHVfloy6FloeSJAAoc2g)wG4qeqJdM(3QLcb7yTsGJGTXAhnjWeSwAS2RbRDYJRwbpUAZETxdwlbYRLv7d0bZNAH9AHxTWrTEE1cmqWAFGxtTVM8vRnJABPx9Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmuG5JxRPAbrAGExDjGOrND91GAs2gQamQ1uTGinqVRUeq0OZU(AqnjBdvbsYqFu7luR1wawRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGO)9LK8iOpb(wOZ0te8lHVfloy6FloeSJAAoc2g)wG4qeqJdM(3sYSb9AVgS2JdB8QfoQf61IYGcGdRny3gRLDWAVgmWAHJAjZaR9AyV20XArhjBBETadSwAoc2gRLh1oY0RLh12obQTHLI1IEcy3uROHdBCu7L12aVA55Sw0rsioQf2R9AWABPqWowRessAoajr)QDI2OdYr7AHJAXwma0Wab)wIaEya5VLuoGm9eviPr(GbcQP5iyBSwt1sd07koeSJArdh2OACSGOALp1APSwwCqPOgDKeIJABrQv2APOwt1YIdkf1OJKqCuR8Rv2AnvlnqVRar(AOZWrfy(4)7lj5j5(e4BHotprWVe(wIaEya5VLuoGm9eviPr(GbcQP5iyBSwt1sd07koeSJArdh2OACSGOAFPwAGExXHGDulA4WgvKSm6XXcIQ1uTS4Gsrn6ijeh1k)ALTwt1sd07kqKVg6mCubMp(3Ifhm9Vfhc2rnkJXmhW0)3xsY71(jW3Ifhm9Vfhc2rn9Kh33cDMEIGFj8VVKKxl4tGVf6m9eb)s4Bjc4HbK)ws5aY0tuLa3acI6SRfzobZhF8TyXbt)BHstbFW0)3xsYRf(jW3Ifhm9Vfhc2rnnhbBJFl0z6jc(LW)(33sK5emF8XNaFjj7NaFl0z6jc(LW3Ifhm9VvpYXP9uk)TaXHiGghm9V1RgWmGhuYdwlWa621AhWXSDTqbumXAFGxtTSHQwj)bwl8Q9bEn1E5rwBEny8ahO6Bjc4HbK)wbGJ9mSrLDahZ2AOakMOcDMEIG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1sCYTwt1kYCcMpU6sarJo76Rb1KSnufid2Uwt1szT0a9UIdb7Ow0WHnQghliQ2xOwRuoGm9evxEKAswgTOHdBCuRPAPSwkR94j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvbGJ6SRnYhmubsYqFu7luR1wawRPAfzobZhxXHGDuBKpyOcKKH(Ow5xRuoGm9evxEKAswgnio526EgA2OwkQLqcRLYABDThpr)ubGJ6SRnYhmuOZ0teSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwPCaz6jQU8i1KSmAqCYT19m0SrTuulHewRiZjy(4koeSJAJ8bdvGKm0h1(c1ATfG1srTu8VVKK3NaFl0z6jc(LW3seWddi)Tcah7zyJk7aoMT1qbumrf6m9ebR1uTImNG5JR4qWoQnYhmubYGTR1uTuwBRR94j6Nc9j0U5qhbvOZ0teSwcjSwkR94j6Nc9j0U5qhbvOZ0teSwt1sYoRmexTYNATVw5wlf1srTMQLYAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kRCR1uT0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLrpowquTuulHewlL1kYCcMpU6sarJo76Rb1KSnufijd9rTuRvU1AQwAGExXHGDulA4WgvJJfevl1ALBTuulf1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALp1ALYbKPNOIn0KqhscqQjzN1gI7BXIdM(3Qh540EkL)3xse3NaFl0z6jc(LW3seWddi)Tcah7zyJkq4qanMqNJ2ArssYoOcDMEIG1AQwrMtW8Xv0a9UgeoeqJj05OTwKKKSdQcKbBxRPAPb6DfiCiGgtOZrBTijjzhu3JCCkW8XR1uTuwlnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwqKgO3vxciA0zxFnOMKTHkW8XRLIAnvRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5wRPAPSwAGExXHGDulA4WgvJJfev7luRvkhqMEIQlpsnjlJw0WHnoQ1uTuwlL1E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4QaWrD21g5dgQajzOpQ9fQ1AlaR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlJgeNCBDpdnBulf1siH1szTTU2JNOFQaWrD21g5dgk0z6jcwRPAfzobZhxXHGDuBKpyOcKKH(Ow5xRuoGm9evxEKAswgnio526EgA2OwkQLqcRvK5emFCfhc2rTr(GHkqsg6JAFHAT2cWAPOwk(wS4GP)T6roo6CE)7ljj7NaFl0z6jc(LW3seWddi)Tcah7zyJkq4qanMqNJ2ArssYoOcDMEIG1AQwrMtW8Xv0a9UgeoeqJj05OTwKKKSdQcKbBxRPAPb6DfiCiGgtOZrBTijjzhu3HbQaZhVwt1AeOuTTaujRQh54OZ59TyXbt)B1HbQPN84(3xse0NaFl0z6jc(LW3Ifhm9VfjmImg6SRVmir)(wG4qeqJdM(36vzyuBlljqTpWRP2w6vRf2RfEVh1kssOBxlGrTJmDvTVUETWR2h4CwlnwlWabR9bEn1sG8AzMxRGhxTWR2XeA3CZ21sJ9mWVLiGhgq(BrzTTU2aWXEg2OAanAsxpUmivOZ0teSwcjSwAGExnGgnPRhxgKkaJAPOwt1kYCcMpU6sarJo76Rb1KSnufijd9rTVuRuoGm9evK5PncuGiO(YJut3UwcjSwkRvkhqMEIQdsIAa)GtnBuR8RvkhqMEIkY80KSmAqCYT19m0SrTMQvK5emFC1LaIgD21xdQjzBOkqsg6JALFTs5aY0turMNMKLrdItUTUNH(YJSwk(3xssUpb(wOZ0te8lHVLiGhgq(BjYCcMpUIdb7O2iFWqfid2Uwt1szTTU2JNOFk0Nq7MdDeuHotprWAjKWAPS2JNOFk0Nq7MdDeuHotprWAnvlj7SYqC1kFQ1(ALBTuulf1AQwkRLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xRuoGm9evSHMKLrdItUTUNH(YJSwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1srTesyTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5wRPAPb6Dfhc2rTOHdBunowquTuRvU1srTuuRPAPb6Dva4Oo7AJ8bdfy(41AQws2zLH4Qv(uRvkhqMEIk2qtcDijaPMKDwBiUVfloy6Flsyezm0zxFzqI(9VVKETFc8TqNPNi4xcFlrapmG83skhqMEIQe4gqquNDTiZjy(4JAnvlL1osGjn0bvsZjFWjQh5uk6NcDMEIG1siH1osGjn0bvgaJdyIAmamoy6k0z6jcwlfFlwCW0)w9joAeb3V)9Lul4tGVf6m9eb)s4BXIdM(3ce5RHodh)wG4qeqJdM(3QLMpC7rTadSwqKVg6mCS2h41ulBOQ911R9YJSw4O2azW21YJAFW508AjzIWAhabw7L1k4Xvl8QLg7zG1E5rQ(wIaEya5VLiZjy(4Qlben6SRVgutY2qvGmy7AnvlnqVR4qWoQfnCyJQXXcIQ9fQ1kLditpr1LhPMKLrlA4Wgh1AQwrMtW8XvCiyh1g5dgQajzOpQ9fQ1Ala)3xsTWpb(wOZ0te8lHVLiGhgq(BjYCcMpUIdb7O2iFWqfid2Uwt1szTTU2JNOFk0Nq7MdDeuHotprWAjKWAPS2JNOFk0Nq7MdDeuHotprWAnvlj7SYqC1kFQ1(ALBTuulf1AQwkRLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xRSYTwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1srTesyTuwRiZjy(4Qlben6SRVgutY2qvGmy7AnvlnqVR4qWoQfnCyJQXXcIQLATYTwkQLIAnvlnqVRcah1zxBKpyOaZhVwt1sYoRmexTYNATs5aY0tuXgAsOdjbi1KSZAdX9TyXbt)BbI81qNHJ)7ljzL7NaFl0z6jc(LW3Ifhm9VvWGq2p9WGdI(wG4qeqJdM(3sYFG1om4GOAH9AV8iRLDWAzJA5aRn9AfG1YoyTpP)(QLgRfWO2Eg1ot3gJAVg2R9AWAjzzQfeNCBZRLKjc621oacS2hS2gwkwlF1orEC1EpzTCiyhRv0WHnoQLDWAVg(Q9YJS2hE4VVABrbgxTadeu9Teb8WaYFlrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kLditprvm0KSmAqCYT19m0xEK1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kLditprvm0KSmAqCYT19m0SrTMQLYApEI(Pcah1zxBKpyOqNPNiyTMQLYAfzobZhxfaoQZU2iFWqfijd9rTVulkdkaouFqsSwcjSwrMtW8XvbGJ6SRnYhmubsYqFuR8RvkhqMEIQyOjzz0G4KBR7zOJ0OwkQLqcRT11E8e9tfaoQZU2iFWqHotprWAPOwt1sd07koeSJArdh2OACSGOALFTYRwt1cI0a9U6sarJo76Rb1KSnubMpETMQLgO3vbGJ6SRnYhmuG5JxRPAPb6Dfhc2rTr(GHcmF8)9LKSY(jW3cDMEIGFj8TyXbt)BfmiK9tpm4GOVfioeb04GP)TK8hyTddoiQ2h41ulBu7td61AKJbKEIQAFD9AV8iRfoQnqgSDT8O2hConVwsMiS2bqG1EzTcEC1cVAPXEgyTxEKQVLiGhgq(BjYCcMpU6sarJo76Rb1KSnufijd9rTVulkdkaouFqsSwt1sd07koeSJArdh2OACSGOAFHATs5aY0tuD5rQjzz0IgoSXrTMQvK5emFCfhc2rTr(GHkqsg6JAFPwkRfLbfahQpijwlXQLfhmD1LaIgD21xdQjzBOcLbfahQpijwlf)7ljzL3NaFl0z6jc(LW3seWddi)TezobZhxXHGDuBKpyOcKKH(O2xQfLbfahQpijwRPAPSwkRT11E8e9tH(eA3COJGk0z6jcwlHewlL1E8e9tH(eA3COJGk0z6jcwRPAjzNvgIRw5tT2xRCRLIAPOwt1szTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1k)ALYbKPNOIn0KSmAqCYT19m0xEK1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwkQLqcRLYAfzobZhxDjGOrND91GAs2gQcKKH(OwQ1k3AnvlnqVR4qWoQfnCyJQXXcIQLATYTwkQLIAnvlnqVRcah1zxBKpyOaZhVwt1sYoRmexTYNATs5aY0tuXgAsOdjbi1KSZAdXvlfFlwCW0)wbdcz)0ddoi6FFjjlX9jW3cDMEIGFj8TyXbt)BnsG5eVd626aGU93seWddi)TOS2wxBa4ypdBunGgnPRhxgKk0z6jcwlHewlnqVRgqJM01JldsfGrTuuRPAPb6Dfhc2rTOHdBunowquTVqTwPCaz6jQU8i1KSmArdh24Owt1kYCcMpUIdb7O2iFWqfijd9rTVqTwuguaCO(GKyTMQLKDwziUALFTs5aY0tuXgAsOdjbi1KSZAdXvRPAPb6Dva4Oo7AJ8bdfy(4FlNjXV1ibMt8oOBRda62)7ljzLSFc8TqNPNi4xcFlwCW0)wxciA0zxFnOMKTHFlqCicOXbt)Bj5pWAV8iR9bEn1Yg1c71cV3JAFGxd0R9AWAjzzQfeNCBvTVUETEEMxlWaR9bEn1gPrTWETxdw7Xt0VAHJApMi0nVw2bRfEVh1(aVgOx71G1sYYulio52QVLiGhgq(BrzTTU2aWXEg2OAanAsxpUmivOZ0teSwcjSwAGExnGgnPRhxgKkaJAPOwt1sd07koeSJArdh2OACSGOAFHATs5aY0tuD5rQjzz0IgoSXrTMQvK5emFCfhc2rTr(GHkqsg6JAFHATOmOa4q9bjXAnvlj7SYqC1k)ALYbKPNOIn0KqhscqQjzN1gIRwt1sd07QaWrD21g5dgkW8X)3xsYsqFc8TqNPNi4xcFlrapmG83IgO3vCiyh1IgoSr14ybr1(c1ALYbKPNO6YJutYYOfnCyJJAnv7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2xOwlkdkaouFqsSwt1kLditpr1bjrnGFWPMnQv(1kLditpr1LhPMKLrdItUTUNHMn(wS4GP)TUeq0OZU(AqnjBd)3xsYk5(e4BHotprWVe(wIaEya5VfnqVR4qWoQfnCyJQXXcIQ9fQ1kLditpr1LhPMKLrlA4Wgh1AQwkRT11E8e9tfaoQZU2iFWqHotprWAjKWAfzobZhxfaoQZU2iFWqfijd9rTYVwPCaz6jQU8i1KSmAqCYT19m0rAulf1AQwPCaz6jQoijQb8do1SrTYVwPCaz6jQU8i1KSmAqCYT19m0SX3Ifhm9V1LaIgD21xdQjzB4)(ss2x7NaFl0z6jc(LW3Ifhm9Vfhc2rTr(GX3cehIaACW0)ws(dSw2OwyV2lpYAHJAtVwbyTSdw7t6VVAPXAbmQTNrTZ0TXO2RH9AVgSwswMAbXj328AjzIGUDTdGaR9A4R2hS2gwkwl6jGDtTKSZ1YoyTxdF1EnyG1ch165vlpdKbBxlxBa4yTzVwJ8bJAbZhx9Teb8WaYFlrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kLditprfBOjzz0G4KBR7zOV8iR1uTuwBRRvKsrN9tjf9RPDulHewRiZjy(4ksyezm0zxFzqI(PcKKH(Ow5xRuoGm9evSHMKLrdItUTUNHMmVAPOwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALp1ALYbKPNOIn0KqhscqQjzN1gI7FFjjBl4tGVf6m9eb)s4BXIdM(3kaCuNDTr(GX3cehIaACW0)ws(dS2inQf2R9YJSw4O20Rvawl7G1(K(7RwASwaJA7zu7mDBmQ9AyV2RbRLKLPwqCYTnVwsMiOBx7aiWAVgmWAHd)9vlpdKbBxlxBa4yTG5Jxl7G1En8vlBu7t6VVAPrrsI1Ysz4KPNyTGab0TRnaCu9Teb8WaYFlAGExXHGDuBKpyOaZhVwt1szTImNG5JRUeq0OZU(AqnjBdvbsYqFuR8RvkhqMEIQin0KSmAqCYT19m0xEK1siH1kYCcMpUIdb7O2iFWqfijd9rTVqTwPCaz6jQU8i1KSmAqCYT19m0SrTuuRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGOAnvRiZjy(4koeSJAJ8bdvGKm0h1k)ALvU1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kRC)3xsY2c)e4BHotprWVe(wIaEya5VLuoGm9evjWnGGOo7ArMtW8XhFlwCW0)wJgy)GUT2iFW4FFjjp5(jW3cDMEIGFj8TyXbt)Bze4aDbQZUMe6GFlqCicOXbt)Bj5pWAnsYAVS2rlgarjpyTSxlkZfCTmDTqV2RbR1rzUAfzobZhV2hOdMpMxlGpXXOwIAhq2R9AqV20NTRfeiGUDTCiyhR1iFWOwqaS2lRTjFQLKDU2ga3oAxBWGq2VAhgCquTWX3seWddi)ToEI(Pcah1zxBKpyOqNPNiyTMQLgO3vCiyh1g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(O2xQ1waQizz(3xsYt2pb(wOZ0te8lHVLiGhgq(BbI0a9U6sarJo76Rb1KSnubyuRPAbrAGExDjGOrND91GAs2gQcKKH(O2xQLfhmDfhc2rnjCmGtCOqzqbWH6dsI1AQ2wxRiLIo7NIO2bK9Vfloy6FlJahOlqD21Kqh8FFjjp59jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0h1(sT2cqfjltTMQvK5emFCfknf8btxfid2Uwt1kYCcMpU6sarJo76Rb1KSnufijd9rTMQT11ksPOZ(PiQDaz)BXIdM(3YiWb6cuNDnj0b)3)(wGyNbM3NaFjj7NaFlwCW0)wIeWpmgg4C(TqNPNi4xc)7lj59jW3cDMEIGFj8Teb8WaYFlkR94j6Nc9j0U5qhbvOZ0teSwt1sYoRmexTVqT2wGCR1uTKSZkdXvR8PwRKJGQLIAjKWAPS2wx7Xt0pf6tODZHocQqNPNiyTMQLKDwziUAFHATTacQwk(wS4GP)TizN12i5)(sI4(e4BHotprWVe(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)wg5bt)FFjjz)e4BHotprWVe(wIaEya5Vva4ypdBuDiPrg8u)WHHcDMEIG1AQwAGExHY0WaJdMUcWOwt1szTImNG5JR4qWoQnYhmubYGTRLqcRLohJAnvBhA3C6ajzOpQ9fQ1kzLBTu8TyXbt)BDqsu)WHX)(sIG(e4BHotprWVe(wIaEya5VfnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwqKgO3vxciA0zxFnOMKTHkW8X)wS4GP)TMq7MBOBrbaTjr)(3xssUpb(wOZ0te8lHVLiGhgq(Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8Vfloy6FlA2wND9fqbrJ)9L0R9tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)BrJXadIGU9)(sQf8jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOam(wS4GP)TONzcQ7ar7)9Lul8tGVf6m9eb)s4Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)B1HbspZe8FFjjRC)e4BHotprWVe(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)wSlWXf8ul458FFjjRSFc8TqNPNi4xcFlrapmG83IgO3vCiyh1g5dgkaJVfloy6FlGbQHhso(3xsYkVpb(wOZ0te8lHVfloy6Fl7jdc5lJHMMbTXVLiGhgq(Brd07koeSJAJ8bdfGrTesyTImNG5JR4qWoQnYhmubsYqFuR8Pwlbrq1AQwqKgO3vxciA0zxFnOMKTHkaJVf27O40otIFl7jdc5lJHMMbTX)9LKSe3NaFl0z6jc(LW3Ifhm9VfsA0oqEQZa0zxGFlrapmG83sK5emFCfhc2rTr(GHkqsg6JAFHATYsq1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQ9fQ1klb9TCMe)wiPr7a5PodqNDb(VVKKvY(jW3cDMEIGFj8TyXbt)Bbgid2HbQLIJbo)wIaEya5VLiZjy(4koeSJAJ8bdvGKm0h1kFQ1kp5wlHewBRRvkhqMEIk2qNUgyG1sTwzRLqcRLYApijwl1ALBTMQvkhqMEIQoC0aDBDAGog1sTwzR1uTbGJ9mSr1aA0KUECzqQqNPNiyTu8TCMe)wGbYGDyGAP4yGZ)9LKSe0NaFl0z6jc(LW3Ifhm9V1ibMAOTdpm(wIaEya5VLiZjy(4koeSJAJ8bdvGKm0h1kFQ1sCYTwcjS2wxRuoGm9evSHoDnWaRLATY(TCMe)wJeyQH2o8W4FFjjRK7tGVf6m9eb)s4BXIdM(3YE22OrNDnpgqs4Kpy6FlrapmG83sK5emFCfhc2rTr(GHkqsg6JALp1ALNCRLqcRT11kLditprfBOtxdmWAPwRS1siH1szThKeRLATYTwt1kLditprvhoAGUTonqhJAPwRS1AQ2aWXEg2OAanAsxpUmivOZ0teSwk(wotIFl7zBJgD218yajHt(GP)VVKK91(jW3cDMEIGFj8TyXbt)BrYcMoq9ObXttcmGIVLiGhgq(BjYCcMpUIdb7O2iFWqfijd9rTVqTwcQwt1szTTUwPCaz6jQ6Wrd0T1Pb6yul1ALTwcjS2dsI1k)Ajo5wlfFlNjXVfjly6a1JgepnjWak(3xsY2c(e4BHotprWVe(wS4GP)TizbthOE0G4PjbgqX3seWddi)TezobZhxXHGDuBKpyOcKKH(O2xOwlbvRPALYbKPNOQdhnq3wNgOJrTuRv2AnvlnqVRcah1zxBKpyOamQ1uT0a9UkaCuNDTr(GHkqsg6JAFHATuwRSYT2wKAjOAB51gao2ZWgvdOrt66XLbPcDMEIG1srTMQ9GKyTVulXj3VLZK43IKfmDG6rdINMeyaf)7ljzBHFc8TqNPNi4xcFlwCW0)wJggmFqqDg06SRVmir)(wIaEya5V1bjXAPwRCRLqcRLYALYbKPNOkbUbee1zxlYCcMp(Owt1szTuwRiLIo7NIO2bK9AnvRiZjy(4QGbHSF6HbhePcKKH(O2xOwR8Q1uTImNG5JR4qWoQnYhmubsYqFu7luRLGQ1uTImNG5JRUeq0OZU(AqnjBdvbsYqFu7luRLGQLIAjKWAfzobZhxXHGDuBKpyOcKKH(O2xOwR8QLqcRTdTBoDGKm0h1(sTImNG5JR4qWoQnYhmubsYqFulf1sX3Yzs8BnAyW8bb1zqRZU(YGe97FFjjp5(jW3cDMEIGFj8TaXHiGghm9VfbPKC1ch1EnyTddebRn71EnyTwjWCI3bD7AFna0TR1iYwuuCWj(TCMe)wJeyoX7GUToaOB)Teb8WaYFlkRvkhqMEIQdsIAa)GtnBulXQLYAzXbtxfmiK9tpm4GifkdkaouFqsS2wETIuk6SFkIAhq2RLIAjwTuwlloy6kqKVg6mCuHYGcGd1hKeRTLxRiLIo7NYrrKZmaRLIAjwTS4GPRUeq0OZU(AqnjBdvOmOa4q9bjXAFP2JdB8uGWXXUaRvI1sqkjxTuuRPAPSwPCaz6jQAyPOonqhbRLqcRLYAfPu0z)ue1oGSxRPAdah7zyJkoeSJAO3Ho8ARqNPNiyTuulf1AQ2JdB8uGWXXUaRv(1kpc6BXIdM(3AKaZjEh0T1baD7)9LK8K9tGVf6m9eb)s4BXIdM(3sWZPMfhmD9eoUV1eooTZK43sWtbWKpy6J)9LK8K3NaFl0z6jc(LW3seWddi)TyXbLIA0rsioQv(uRvkhqMEIkor9XHnEArc433ACbuCFjj73Ifhm9VLGNtnloy66jCCFRjCCANjXVfN4)(ssEe3NaFl0z6jc(LW3seWddi)TePu0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEIGFlwCW0)wcEo1S4GPRNWX9TMWXPDMe)wnCqME7)9LK8KSFc8TqNPNi4xcFlrapmG83skhqMEIQgwkQtd0rWAPwRCR1uTs5aY0tu1HJgOBRtd0XOwt126APSwrkfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPNiyTu8TyXbt)Bj45uZIdMUEch33AchN2zs8B1HJgOBRtd0X4FFjjpc6tGVf6m9eb)s4Bjc4HbK)ws5aY0tu1WsrDAGocwl1ALBTMQT11szTIuk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotprWAP4BXIdM(3sWZPMfhmD9eoUV1eooTZK43knqhJ)9LK8KCFc8TqNPNi4xcFlrapmG83Q11szTIuk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotprWAP4BXIdM(3sWZPMfhmD9eoUV1eooTZK43sK5emF8X)(ssEV2pb(wOZ0te8lHVLiGhgq(BjLditprvh68utdeETuRvU1AQ2wxlL1ksPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebRLIVfloy6FlbpNAwCW01t44(wt440otIFRip(GP)VVKKxl4tGVf6m9eb)s4Bjc4HbK)ws5aY0tu1Hop10aHxl1ALTwt126APSwrkfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPNiyTu8TyXbt)Bj45uZIdMUEch33AchN2zs8B1Hop10aH)V)9TmcuKK089jWxsY(jW3Ifhm9Vfhc2rn0pCorX9TqNPNi4xc)7lj59jW3Ifhm9V1aGKmDnhc2rDNjHtihFl0z6jc(LW)(sI4(e4BXIdM(3sKElkqGAs2zTns(TqNPNi4xc)7ljj7NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wCI6JdB80IeWVVfi2zG59TiU)9Leb9jW3cDMEIGFj8TsJVvGd8(wS4GP)TKYbKPN43skhANjXVfkn1gI7BbIDgyEFlzjO)9LKK7tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLdTZK43YiqdG5uJsZVLiGhgq(BrzTbGJ9mSr1aA0KUECzqQqNPNiyTMQLYAfPu0z)usr)AAh1siH1ksPOZ(PCue5mdWAjKWAfPdcapfhc2rTrKGq72k0z6jcwlf1sX3skpbqnoh43sUFlP8ea)wY(VVKETFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlPCODMe)wnSuuNgOJGFlrapmG83IfhukQrhjH4Ow5tTwPCaz6jQ4e1hh24PfjGFFlP8ea14CGFl5(TKYta8Bj7)(sQf8jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Bj3VLuo0otIFRo05PMgi8)9Lul8tGVf6m9eb)s4BLgFRah49TyXbt)BjLditpXVLuo0otIFRgoitVTECSGi9bjXVfi2zG59TAH)7ljzL7NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)w88HBp0J2UqlYCcMp(4BbIDgyEFl5(VVKKv2pb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TIHMKLrdItUTUNH(YJ8BbIDgyEFlc6FFjjR8(e4BHotprWVe(wPX3kWbEFlwCW0)ws5aY0t8BjLdTZK43kgAswgnio526Eg6in(wGyNbM33IG(3xsYsCFc8TqNPNi4xcFR04Bf4aVVfloy6FlPCaz6j(TKYH2zs8BfdnjlJgeNCBDpdnB8TaXodmVVL8K7)(sswj7NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wK5PncuGiO(YJut3(BbIDgyEFRwW)(sswc6tGVf6m9eb)s4BLgFRah49TyXbt)BjLditpXVLuo0otIFlY80KSmAqCYT19m0xEKFlqSZaZ7BjRC)3xsYk5(e4BHotprWVe(wPX3kWbEFlwCW0)ws5aY0t8BjLdTZK43ImpnjlJgeNCBDpdnB8TaXodmVVLSe0)(ss2x7NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wSHMKLrdItUTUNH(YJ8Bjc4HbK)wI0bbGNIdb7O2isqOD7VLuEcGACoWVLSY9BjLNa43I4K7)(ss2wWNaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wSHMKLrdItUTUNH(YJ8BbIDgyEFl5j3)9LKSTWpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(TydnjlJgeNCBDpdnzEFlqSZaZ7Bjp5(VVKKNC)e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TKNCRTfPwkRLGQTLxRiDqa4P4qWoQnIeeA3wHotprWAP4BjLdTZK43ksdnjlJgeNCBDpd9Lh5)(ssEY(jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Brq1sSALNCRTLxlL1ksPOZ(PCODZP7mwlHewlL1ksheaEkoeSJAJibH2TvOZ0teSwt1YIdkf1OJKqCu7l1kLditprfNO(4WgpTib8RwkQLIAjwTYsq12YRLYAfPu0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEIG1AQwwCqPOgDKeIJALp1ALYbKPNOItuFCyJNwKa(vlfFlPCODMe)wxEKAswgnio526EgA24FFjjp59jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Bjp5wBlsTuwBlO2wETI0bbGNIdb7O2isqODBf6m9ebRLIVLuo0otIFRlpsnjlJgeNCBDpdDKg)7lj5rCFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wso5wBlsTuwljpomARLYtaS2wETYkx5wlfFlrapmG83sKsrN9t5q7Mt3z8BjLdTZK43IMJGTrnj7S2qC)7lj5jz)e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TAHeuTTi1szTK84WOTwkpbWAB51kRCLBTu8Teb8WaYFlrkfD2pfrTdi7FlPCODMe)w0CeSnQjzN1gI7FFjjpc6tGVf6m9eb)s4BLgFRbEFlwCW0)ws5aY0t8BjLNa43Qfi3ABrQLYAj5XHrBTuEcG12YRvw5k3AP4Bjc4HbK)ws5aY0turZrW2OMKDwBiUAPwRC)ws5q7mj(TO5iyButYoRne3)(ssEsUpb(wOZ0te8lHVvA8TcCG33Ifhm9VLuoGm9e)ws5q7mj(Tydnj0HKaKAs2zTH4(wGyNbM33swc6FFjjVx7NaFl0z6jc(LW3kn(wboW7BXIdM(3skhqMEIFlPCODMe)wxEKAswgTOHdBC8TaXodmVVL8(3xsYRf8jW3cDMEIGFj8TsJVvGd8(wS4GP)TKYbKPN43skhANjXVfNO(YJutYYOfnCyJJVfi2zG59TK3)(ssETWpb(wOZ0te8lHVvA8Tg49TyXbt)BjLditpXVLuEcGFlzRTLxlL1ITyaOHbcQqsJ2bYtDgGo7cSwcjSwkR94j6NkaCuNDTr(GHcDMEIG1AQwkR94j6NIdb7OgfnPcDMEIG1siH126AfPu0z)ue1oGSxlf1AQwkRT11ksPOZ(PCue5mdWAjKWAzXbLIA0rsioQLATYwlHewBa4ypdBunGgnPRhxgKk0z6jcwlf1AQ2wxRiLIo7Nsk6xt7OwkQLIVLuo0otIFRoC0aDBDAGog)7ljItUFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wylgaAyGGkswW0bQhniEAsGbuulHewl2IbGggiOYEYGq(YyOPzqBSwcjSwSfdanmqqL9KbH8LXqtIG8CctVwcjSwSfdanmqqfiherMPRbrbrAdGlWHaDbwlHewl2IbGggiOc6draCm9e1Tya2pasnikfkWAjKWAXwma0WabvJeyoX7GUToaOBxlHewl2IbGggiOAa40Zmb1mjEnThxTesyTylgaAyGGQhMi0XyO7r6G1siH1ITyaOHbcQ6tMe1zxtZ3nXVLuo0otIFl2qNUgyG)7ljIt2pb(wS4GP)TiHrKHgsY243cDMEIGFj8VVKio59jW3cDMEIGFj8Teb8WaYFRrcmPHoOsAo5dor9iNsr)uOZ0teSwcjS2rcmPHoOYayCatuJbGXbtxHotprWVfloy6FR(ehnIG73)(sI4iUpb(wOZ0te8lHVLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uTI0bbGNIdb7O2isqODBf6m9ebR1uTs5aY0tuXZhU9qpA7cTiZjy(4JAnvlloOuuJoscXrTVuRuoGm9evCI6JdB80IeWVVfloy6FRaWrD21g5dg)7ljItY(jW3cDMEIGFj8Teb8WaYFRwxRuoGm9evgbAamNAuAwl1ALTwt1gao2ZWgvGWHaAmHohT1IKKKDqf6m9eb)wS4GP)T6roo6CE)7ljIJG(e4BHotprWVe(wIaEya5VvRRvkhqMEIkJanaMtnknRLATYwRPABDTbGJ9mSrfiCiGgtOZrBTijjzhuHotprWAnvlL126AfPu0z)usr)AAh1siH1kLditprvhoAGUTonqhJAP4BXIdM(3Idb7OMEYJ7FFjrCsUpb(wOZ0te8lHVLiGhgq(B16ALYbKPNOYiqdG5uJsZAPwRS1AQ2wxBa4ypdBubchcOXe6C0wlsss2bvOZ0teSwt1ksPOZ(PKI(10oQ1uTTUwPCaz6jQ6Wrd0T1Pb6y8TyXbt)BrcJiJHo76lds0V)9LeX9A)e4BHotprWVe(wIaEya5VLuoGm9evgbAamNAuAwl1AL9BXIdM(3cLMc(GP)V)9T4e)e4ljz)e4BHotprWVe(wIaEya5Vva4ypdBubchcOXe6C0wlsss2bvOZ0teSwt1kYCcMpUIgO31GWHaAmHohT1IKKKDqvGmy7AnvlnqVRaHdb0ycDoARfjjj7G6EKJtbMpETMQLYAPb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubMpETuuRPAfzobZhxDjGOrND91GAs2gQcKKH(OwQ1k3AnvlL1sd07koeSJArdh2OACSGOAFHATs5aY0tuXjQV8i1KSmArdh24Owt1szTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2xOwRTaSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwPCaz6jQU8i1KSmAqCYT19m0SrTuulHewlL126ApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCfhc2rTr(GHkqsg6JALFTs5aY0tuD5rQjzz0G4KBR7zOzJAPOwcjSwrMtW8XvCiyh1g5dgQajzOpQ9fQ1AlaRLIAP4BXIdM(3Qh54OZ59VVKK3NaFl0z6jc(LW3seWddi)TOS2aWXEg2OceoeqJj05OTwKKKSdQqNPNiyTMQvK5emFCfnqVRbHdb0ycDoARfjjj7GQazW21AQwAGExbchcOXe6C0wlsss2b1DyGkW8XR1uTgbkvBlavYQ6roo6CE1srTesyTuwBa4ypdBubchcOXe6C0wlsss2bvOZ0teSwt1EqsSwQ1k3AP4BXIdM(3Qddutp5X9VVKiUpb(wOZ0te8lHVLiGhgq(Bfao2ZWgv2bCmBRHcOyIk0z6jcwRPAfzobZhxXHGDuBKpyOcKKH(Ow5xlXj3AnvRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5wRPAPSwAGExXHGDulA4WgvJJfev7luRvkhqMEIkor9LhPMKLrlA4Wgh1AQwkRLYApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCva4Oo7AJ8bdvGKm0h1(c1ATfG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kLditpr1LhPMKLrdItUTUNHMnQLIAjKWAPS2wx7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlJgeNCBDpdnBulf1siH1kYCcMpUIdb7O2iFWqfijd9rTVqTwBbyTuulfFlwCW0)w9ihN2tP8)(ssY(jW3cDMEIGFj8Teb8WaYFRaWXEg2OYoGJzBnuaftuHotprWAnvRiZjy(4koeSJAJ8bdvGKm0h1sTw5wRPAPSwkRLYAfzobZhxDjGOrND91GAs2gQcKKH(Ow5xRuoGm9evSHMKLrdItUTUNH(YJSwt1sd07koeSJArdh2OACSGOAPwlnqVR4qWoQfnCyJkswg94ybr1srTesyTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5wRPAPb6Dfhc2rTOHdBunowquTVqTwPCaz6jQ4e1xEKAswgTOHdBCulf1srTMQLgO3vbGJ6SRnYhmuG5JxlfFlwCW0)w9ihN2tP8)(sIG(e4BHotprWVe(wS4GP)T4qWoQjHJbCIJVLOHH(3s2VLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uT0a9UIdb7OUHdY0BRghliQ2xQvwcQwt1kYCcMpUkyqi7NEyWbrQajzOpQ9fQ1kLditprvdhKP3wpowqK(GKyTeRwuguaCO(GKyTMQvK5emFC1LaIgD21xdQjzBOkqsg6JAFHATs5aY0tu1Wbz6T1JJfePpijwlXQfLbfahQpijwlXQLfhmDvWGq2p9WGdIuOmOa4q9bjXAnvRiZjy(4koeSJAJ8bdvGKm0h1(c1ALYbKPNOQHdY0BRhhlisFqsSwIvlkdkaouFqsSwIvlloy6QGbHSF6HbhePqzqbWH6dsI1sSAzXbtxDjGOrND91GAs2gQqzqbWH6dsI)7ljj3NaFl0z6jc(LW3Ifhm9Vfhc2rnjCmGtC8Tenm0)wY(Teb8WaYFlrkfD2pLu0VM2rTMQnaCSNHnQ4qWoQHEh6WRTcDMEIG1AQwAGExXHGDu3Wbz6TvJJfev7l1klbvRPAfzobZhxDjGOrND91GAs2gQcKKH(O2xOwRuoGm9evnCqMEB94ybr6dsI1sSArzqbWH6dsI1AQwrMtW8XvCiyh1g5dgQajzOpQ9fQ1kLditprvdhKP3wpowqK(GKyTeRwuguaCO(GKyTeRwwCW0vxciA0zxFnOMKTHkuguaCO(GK4)(s61(jW3cDMEIGFj8Teb8WaYFlrkfD2pLu0VM2rTMQ94j6NIdb7OgfnPcDMEIG1AQ2dsI1(sTYk3AnvRiZjy(4ksyezm0zxFzqI(PcKKH(Owt1sd07kXe5qWJd62QXXcIQ9LAjUVfloy6FloeSJA6jpU)9Lul4tGVf6m9eb)s4BXIdM(3AKaZjEh0T1baD7VLiGhgq(Bfao2ZWgvdOrt66XLbPcDMEIG1AQwJaLQTfGkzvO0uWhm9VLZK43AKaZjEh0T1baD7)9Lul8tGVf6m9eb)s4Bjc4HbK)wbGJ9mSr1aA0KUECzqQqNPNiyTMQ1iqPABbOswfknf8bt)BXIdM(36sarJo76Rb1KSn8FFjjRC)e4BHotprWVe(wIaEya5Vva4ypdBunGgnPRhxgKk0z6jcwRPAPSwJaLQTfGkzvO0uWhm9AjKWAncuQ2waQKvDjGOrND91GAs2gwlfFlwCW0)wCiyh1g5dg)7ljzL9tGVf6m9eb)s4Bjc4HbK)wbGJ9mSrfhc2rn07qhETvOZ0teSwt1kYCcMpU6sarJo76Rb1KSnufijd9rTVqTwzLBTMQvK5emFCfhc2rTr(GHkqsg6JAFHATYsqFlwCW0)wKWiYyOZU(YGe97FFjjR8(e4BHotprWVe(wIaEya5VLiZjy(4koeSJAJ8bdvGKm0h1(c1ABb1AQwrMtW8XvxciA0zxFnOMKTHQajzOpQ9fQ12cQ1uTuwlnqVR4qWoQfnCyJQXXcIQ9fQ1kLditprfNO(YJutYYOfnCyJJAnvlL1szThpr)ubGJ6SRnYhmuOZ0teSwt1kYCcMpUkaCuNDTr(GHkqsg6JAFHAT2cWAnvRiZjy(4koeSJAJ8bdvGKm0h1k)AjOAPOwcjSwkRT11E8e9tfaoQZU2iFWqHotprWAnvRiZjy(4koeSJAJ8bdvGKm0h1k)AjOAPOwcjSwrMtW8XvCiyh1g5dgQajzOpQ9fQ1AlaRLIAP4BXIdM(3IegrgdD21xgKOF)7ljzjUpb(wOZ0te8lHVLiGhgq(BDqsSw5xlXj3AnvBa4ypdBunGgnPRhxgKk0z6jcwRPAfPu0z)usr)AAh1AQwJaLQTfGkzvKWiYyOZU(YGe97BXIdM(3cLMc(GP)VVKKvY(jW3cDMEIGFj8Teb8WaYFRdsI1k)Ajo5wRPAdah7zyJQb0OjD94YGuHotprWAnvlnqVR4qWoQfnCyJQXXcIQ9fQ1kLditprfNO(YJutYYOfnCyJJAnvRiZjy(4Qlben6SRVgutY2qvGKm0h1sTw5wRPAfzobZhxXHGDuBKpyOcKKH(O2xOwRTa8BXIdM(3cLMc(GP)VVKKLG(e4BHotprWVe(wS4GP)TqPPGpy6FlOFyeagNg2)w0a9UAanAsxpUmivJJferLgO3vdOrt66XLbPIKLrpowq03c6hgbGXPHKKiiKp8Bj73seWddi)ToijwR8RL4KBTMQnaCSNHnQgqJM01Jldsf6m9ebR1uTImNG5JR4qWoQnYhmubsYqFul1ALBTMQLYAPSwkRvK5emFC1LaIgD21xdQjzBOkqsg6JALFTs5aY0tuXgAswgnio526Eg6lpYAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizz0JJfevlf1siH1szTImNG5JRUeq0OZU(AqnjBdvbsYqFul1ALBTMQLgO3vCiyh1IgoSr14ybr1(c1ALYbKPNOItuF5rQjzz0IgoSXrTuulf1AQwAGExfaoQZU2iFWqbMpETu8VVKKvY9jW3cDMEIGFj8Teb8WaYFlrMtW8XvxciA0zxFnOMKTHQajzOpQ9LArzqbWH6dsI1AQwkRLYApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCva4Oo7AJ8bdvGKm0h1(c1ATfG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kLditpr1LhPMKLrdItUTUNHMnQLIAjKWAPS2wx7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JR4qWoQnYhmubsYqFuR8RvkhqMEIQlpsnjlJgeNCBDpdnBulf1siH1kYCcMpUIdb7O2iFWqfijd9rTVqTwBbyTu8TyXbt)BfmiK9tpm4GO)9LKSV2pb(wOZ0te8lHVLiGhgq(BjYCcMpUIdb7O2iFWqfijd9rTVulkdkaouFqsSwt1szTuwlL1kYCcMpU6sarJo76Rb1KSnufijd9rTYVwPCaz6jQydnjlJgeNCBDpd9LhzTMQLgO3vCiyh1IgoSr14ybr1sTwAGExXHGDulA4WgvKSm6XXcIQLIAjKWAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQLATYTwt1sd07koeSJArdh2OACSGOAFHATs5aY0tuXjQV8i1KSmArdh24OwkQLIAnvlnqVRcah1zxBKpyOaZhVwk(wS4GP)TcgeY(PhgCq0)(ss2wWNaFl0z6jc(LW3seWddi)TezobZhxXHGDuBKpyOcKKH(OwQ1k3AnvlL1szTuwRiZjy(4Qlben6SRVgutY2qvGKm0h1k)ALYbKPNOIn0KSmAqCYT19m0xEK1AQwAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwkQLqcRLYAfzobZhxDjGOrND91GAs2gQcKKH(OwQ1k3AnvlnqVR4qWoQfnCyJQXXcIQ9fQ1kLditprfNO(YJutYYOfnCyJJAPOwkQ1uT0a9UkaCuNDTr(GHcmF8AP4BXIdM(3ce5RHodh)3xsY2c)e4BHotprWVe(wS4GP)TgjWCI3bDBDaq3(Bjc4HbK)wuwlnqVR4qWoQfnCyJQXXcIQ9fQ1kLditprfNO(YJutYYOfnCyJJAjKWAncuQ2waQKvfmiK9tpm4GOAPOwt1szTuw7Xt0pva4Oo7AJ8bdf6m9ebR1uTImNG5JRcah1zxBKpyOcKKH(O2xOwRTaSwt1kYCcMpUIdb7O2iFWqfijd9rTYVwPCaz6jQU8i1KSmAqCYT19m0SrTuulHewlL126ApEI(Pcah1zxBKpyOqNPNiyTMQvK5emFCfhc2rTr(GHkqsg6JALFTs5aY0tuD5rQjzz0G4KBR7zOzJAPOwcjSwrMtW8XvCiyh1g5dgQajzOpQ9fQ1AlaRLIVLZK43AKaZjEh0T1baD7)9LK8K7NaFl0z6jc(LW3seWddi)TePu0z)usr)AAh1AQ2aWXEg2OIdb7Og6DOdV2k0z6jcwRPAfzobZhxrcJiJHo76lds0pvGKm0h1(c1Aji5(TyXbt)BDjGOrND91GAs2g(VVKKNSFc8TqNPNi4xcFlrapmG83sKsrN9tjf9RPDuRPAdah7zyJkoeSJAO3Ho8ARqNPNiyTMQLgO3vKWiYyOZU(YGe9tfijd9rTVqTw5j3AnvRiZjy(4koeSJAJ8bdvGKm0h1(c1ATfGFlwCW0)wxciA0zxFnOMKTH)7lj5jVpb(wOZ0te8lHVLiGhgq(BrzT0a9UIdb7Ow0WHnQghliQ2xOwRuoGm9evCI6lpsnjlJw0WHnoQLqcR1iqPABbOswvWGq2p9WGdIQLIAnvlL1szThpr)ubGJ6SRnYhmuOZ0teSwt1kYCcMpUkaCuNDTr(GHkqsg6JAFHAT2cWAnvRiZjy(4koeSJAJ8bdvGKm0h1k)ALYbKPNO6YJutYYObXj3w3ZqZg1srTesyTuwBRR94j6NkaCuNDTr(GHcDMEIG1AQwrMtW8XvCiyh1g5dgQajzOpQv(1kLditpr1LhPMKLrdItUTUNHMnQLIAjKWAfzobZhxXHGDuBKpyOcKKH(O2xOwRTaSwk(wS4GP)TUeq0OZU(AqnjBd)3xsYJ4(e4BHotprWVe(wIaEya5VfL1szTImNG5JRUeq0OZU(AqnjBdvbsYqFuR8RvkhqMEIk2qtYYObXj3w3ZqF5rwRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGOAPOwcjSwkRvK5emFC1LaIgD21xdQjzBOkqsg6JAPwRCR1uT0a9UIdb7Ow0WHnQghliQ2xOwRuoGm9evCI6lpsnjlJw0WHnoQLIAPOwt1sd07QaWrD21g5dgkW8X)wS4GP)T4qWoQnYhm(3xsYtY(jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqbMpETMQLYAPSwrMtW8XvxciA0zxFnOMKTHQajzOpQv(1kp5wRPAPb6Dfhc2rTOHdBunowquTuRLgO3vCiyh1IgoSrfjlJECSGOAPOwcjSwkRvK5emFC1LaIgD21xdQjzBOkqsg6JAPwRCR1uT0a9UIdb7Ow0WHnQghliQ2xOwRuoGm9evCI6lpsnjlJw0WHnoQLIAPOwt1szTImNG5JR4qWoQnYhmubsYqFuR8Rvw5vlHewlisd07Qlben6SRVgutY2qfGrTu8TyXbt)BfaoQZU2iFW4FFjjpc6tGVf6m9eb)s4Bjc4HbK)wImNG5JR4qWoQZGwfijd9rTYVwcQwcjS2wx7Xt0pfhc2rDg0k0z6jc(TyXbt)BnAG9d62AJ8bJ)9LK8KCFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rTr(GHcWOwt1cI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1sTwjBTMQ1iqPABbOswfhc2rDg01AQwwCqPOgDKeIJAFP2x73Ifhm9Vfhc2rn9Kh3)(ssEV2pb(wOZ0te8lHVLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOAPwRK9BXIdM(3Idb7OMMJGTX)9LK8AbFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rTr(GHcWOwt1szTG5PcgeY(PhgCqKkqsg6JALFTsUAjKWAbrAGExfmiK9tpm4GiTuGPJbtdNWRTcWOwkQ1uTGinqVRcgeY(PhgCqKwkW0XGPHt41wnowquTVuRKTwt1YIdkf1OJKqCul1AjUVfloy6FloeSJA6jpU)9LK8AHFc8TqNPNi4xcFlrapmG83sKsrN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPb6Dfhc2rTr(GHcWOwt1cI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybr1sTwI7BXIdM(3Idb7Ood6)9LeXj3pb(wOZ0te8lHVLiGhgq(BjsPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebR1uT0a9UIdb7O2iFWqbyuRPAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOAPwR8(wS4GP)T4qWoQP5iyB8FFjrCY(jW3cDMEIGFj8Teb8WaYFlrkfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPNiyTMQLgO3vCiyh1g5dgkaJAnvRrGs12cqL8ubdcz)0ddoiQwt1YIdkf1OJKqCuR8RL4(wS4GP)T4qWoQrzmM5aM()(sI4K3NaFl0z6jc(LW3seWddi)TePu0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEIG1AQwAGExXHGDuBKpyOamQ1uTGinqVRcgeY(PhgCqKwkW0XGPHt41wnowquTuRv2AnvlloOuuJoscXrTYVwI7BXIdM(3Idb7OgLXyMdy6)7ljIJ4(e4BHotprWVe(wIaEya5VfnqVRar(AOZWrfGrTMQfePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9rTVqTwAGExze4aDbQZUMe6Gkswg94ybr12YRLfhmDfhc2rn9KhNcLbfahQpijwRPAPSwkR94j6NkWr6Slqf6m9ebR1uTS4Gsrn6ijeh1(sTs2APOwcjSwwCqPOgDKeIJAFPwcQwkQ1uTuwBRRnaCSNHnQ4qWoQPtsAoajr)uOZ0teSwcjS2JdB8unipVgLH4Qv(1sCeuTu8TyXbt)Bze4aDbQZUMe6G)7ljItY(jW3cDMEIGFj8Teb8WaYFlAGExbI81qNHJkaJAnvlL1szThpr)ubosNDbQqNPNiyTMQLfhukQrhjH4O2xQvYwlf1siH1YIdkf1OJKqCu7l1sq1srTMQLYABDTbGJ9mSrfhc2rnDssZbij6NcDMEIG1siH1ECyJNQb551OmexTYVwIJGQLIVfloy6FloeSJA6jpU)9LeXrqFc8TyXbt)BnamWWtP83cDMEIGFj8VVKioj3NaFl0z6jc(LW3seWddi)TOb6Dfhc2rTOHdBunowquTYNATuwlloOuuJoscXrTTi1kBTuuRPAdah7zyJkoeSJA6KKMdqs0pf6m9ebR1uThh24PAqEEnkdXv7l1sCe03Ifhm9Vfhc2rnnhbBJ)7ljI71(jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhli6BXIdM(3Idb7OMMJGTX)9LeX1c(e4BHotprWVe(wIaEya5VfnqVR4qWoQfnCyJQXXcIQLATYTwt1szTImNG5JR4qWoQnYhmubsYqFuR8RvwcQwcjS2wxlL1ksPOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9ebRLIAP4BXIdM(3Idb7Ood6)9LeX1c)e4BHotprWVe(wIaEya5VfL1gypWrdtpXAjKWABDThuqe0TRLIAnvlnqVR4qWoQfnCyJQXXcIQLAT0a9UIdb7Ow0WHnQizz0JJfe9TyXbt)B541GH(qsdCC)7ljjRC)e4BHotprWVe(wIaEya5VfnqVRetKdbpoOBRcKfxTMQnaCSNHnQ4qWoQB4Gm92k0z6jcwRPAPSwkR94j6NIjnMWouWhmDf6m9ebR1uTS4Gsrn6ijeh1(sTTGAPOwcjSwwCqPOgDKeIJAFPwcQwk(wS4GP)T4qWoQjHJbCIJ)9LKKv2pb(wOZ0te8lHVLiGhgq(Brd07kXe5qWJd62QazXvRPApEI(P4qWoQrrtQqNPNiyTMQfePb6D1LaIgD21xdQjzBOcWOwt1szThpr)umPXe2Hc(GPRqNPNiyTesyTS4Gsrn6ijeh1(sTTWAP4BXIdM(3Idb7OMeogWjo(3xssw59jW3cDMEIGFj8Teb8WaYFlAGExjMihcECq3wfilUAnv7Xt0pftAmHDOGpy6k0z6jcwRPAzXbLIA0rsioQ9LALSFlwCW0)wCiyh1KWXaoXX)(ssYsCFc8TqNPNi4xcFlrapmG83IgO3vCiyh1IgoSr14ybr1(sT0a9UIdb7Ow0WHnQizz0JJfe9TyXbt)BXHGDuJYymZbm9)9LKKvY(jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfevl1APb6Dfhc2rTOHdBurYYOhhliQwt1AeOuTTaujRIdb7OMMJGTXVfloy6FloeSJAugJzoGP)V)9Tsd0X4tGVKK9tGVf6m9eb)s4Bjc4HbK)wbGJ9mSrfiCiGgtOZrBTijjzhuHotprWAnvlnqVRaHdb0ycDoARfjjj7G6EKJtby8TyXbt)B1HbQPN84(3xsY7tGVf6m9eb)s4Bjc4HbK)wbGJ9mSrLDahZ2AOakMOcDMEIG1AQws2zLH4Qv(12cjOVfloy6FREKJt7Pu(FFjrCFc8TqNPNi4xcFlNjXV1ibMt8oOBRda62FlwCW0)wJeyoX7GUToaOB)VVKKSFc8TyXbt)BbI81qNHJFl0z6jc(LW)(sIG(e4BHotprWVe(wIaEya5Vfj7SYqC1k)ALSY9BXIdM(3kyqi7NEyWbr)7ljj3NaFlwCW0)wKWiYyOZU(YGe97BHotprWVe(3xsV2pb(wOZ0te8lHVLiGhgq(Brd07koeSJAJ8bdfy(41AQwrMtW8XvCiyh1g5dgQajzOp(wS4GP)TgnW(bDBTr(GX)(sQf8jW3cDMEIGFj8Teb8WaYFlrMtW8XvCiyh1g5dgQazW21AQwAGExXHGDulA4WgvJJfev7l1sd07koeSJArdh2OIKLrpowq03Ifhm9Vfhc2rDg0)7lPw4NaFl0z6jc(LW3seWddi)TePu0z)usr)AAh1AQwrMtW8XvKWiYyOZU(YGe9tfijd9rTYV2wGK9BXIdM(3Idb7OMEYJ7FFjjRC)e4BXIdM(36sarJo76Rb1KSn8BHotprWVe(3xsYk7NaFlwCW0)wCiyh1g5dgFl0z6jc(LW)(ssw59jW3cDMEIGFj8Teb8WaYFlAGExXHGDuBKpyOaZh)BXIdM(3kaCuNDTr(GX)(sswI7tGVf6m9eb)s4BXIdM(3YiWb6cuNDnj0b)wG4qeqJdM(3sYFG1(QzlR2lRD0IbquYdwl71IYCbxBlfc2XALWKhxTGab0TR9AWAjqETmj2sVATpqhmFQfWN4yuBa4o0TRTLcb7yTsgIMuv7RRxBlfc2XALmenzTWrThpr)qqZR9bRvW(7RwGbw7RMTSAFGxd0R9AWAjqETmj2sVATpqhmFQfWN4yu7dwl0pmcaJR2RbRTLAz1kAy3XP51oYAFW3ZzTdwkwl8uFlrapmG83Q11E8e9tXHGDuJIMuHotprWAnvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6JAFHATuwlloy6koeSJA6jpofkdkaouFqsS2wET0a9UYiWb6cuNDnj0bvKSm6XXcIQLI)9LKSs2pb(wOZ0te8lHVfloy6FlJahOlqD21Kqh8BbIdranoy6FRxxV2xnBz12Wd)9vlnIETadeSwqGa621EnyTeiVwwTpqhmFmV2h89CwlWaRfE1EzTJwmaIsEWAzVwuMl4ABPqWowReM84Qf61EnyTVM8vLyl9Q1(aDW8r9Teb8WaYFlAGExXHGDuBKpyOamQ1uT0a9UkaCuNDTr(GHkqsg6JAFHATuwlloy6koeSJA6jpofkdkaouFqsS2wET0a9UYiWb6cuNDnj0bvKSm6XXcIQLI)9LKSe0NaFl0z6jc(LW3seWddi)TaZtfmiK9tpm4GivGKm0h1k)AjOAjKWAbrAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOALFTY9BXIdM(3Idb7OMEYJ7FFjjRK7tGVf6m9eb)s4BXIdM(3Idb7OMMJGTXVfioeb04GP)TAP5d3EuRe4iyBSw(Q9AWArhS2SxBl9Q1(0GETbG7q3U2RbRTLcb7yTsEZbz6TRDI2OdYr7VLiGhgq(Brd07koeSJAJ8bdfGrTMQLgO3vCiyh1g5dgQajzOpQ9LATfG1AQ2aWXEg2OIdb7OUHdY0BRqNPNi4)(ss2x7NaFl0z6jc(LW3Ifhm9Vfhc2rnnhbBJFlqCicOXbt)B1sZhU9OwjWrW2yT8v71G1IoyTzV2RbR91KVATpqhmFQ9Pb9Ada3HUDTxdwBlfc2XAL8MdY0Bx7eTrhKJ2FlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgQajzOpQ9fQ1AlaR1uTbGJ9mSrfhc2rDdhKP3wHotprW)9LKSTGpb(wOZ0te8lHVLOHH(3s2VfYXSTw0Wqxd7FlAGExjMihcECq3wlAy3XPcmFCtusd07koeSJAJ8bdfGbHeszRpEI(PsPyyKpyGGMOKgO3vbGJ6SRnYhmuagesOiZjy(4kuAk4dMUkqgSnfuqX3seWddi)TarAGExDjGOrND91GAs2gQamQ1uThpr)uCiyh1OOjvOZ0teSwt1szT0a9Uce5RHodhvG5JxlHewlloOuuJoscXrTuRv2APOwt1cI0a9U6sarJo76Rb1KSnufijd9rTYVwwCW0vCiyh1KWXaoXHcLbfahQpij(TyXbt)BXHGDutchd4eh)7ljzBHFc8TqNPNi4xcFlrapmG83IgO3vIjYHGhh0TvJJfevl1APb6DLyICi4XbDBfjlJECSGOAnvRiLIo7Nsk6xt74BXIdM(3Idb7OMeogWjo(3xsYtUFc8TqNPNi4xcFlwCW0)wCiyh1KWXaoXX3s0Wq)Bj73seWddi)TOb6DLyICi4XbDBvGS4Q1uTImNG5JR4qWoQnYhmubsYqFuRPAPSwAGExfaoQZU2iFWqbyulHewlnqVR4qWoQnYhmuag1sX)(ssEY(jW3cDMEIGFj8Teb8WaYFlAGExXHGDulA4WgvJJfev7luRvkhqMEIQlpsnjlJw0WHno(wS4GP)T4qWoQZG(FFjjp59jW3cDMEIGFj8Teb8WaYFlAGExfaoQZU2iFWqbyulHewlj7SYqC1k)ALLG(wS4GP)T4qWoQPN84(3xsYJ4(e4BHotprWVe(wS4GP)TqPPGpy6FlOFyeagNg2)wKSZkdXjFQTac6Bb9dJaW40qsseeYh(TK9Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AnvlnqVR4qWoQnYhmuG5J)VVKKNK9tGVfloy6FloeSJAAoc2g)wOZ0te8lH)9VVLGNcGjFW0hFc8LKSFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wY(Teb8WaYFlPCaz6jQAyPOonqhbRLATYTwt1AeOuTTaujRcLMc(GPxRPABDTuwBa4ypdBunGgnPRhxgKk0z6jcwlHewBa4ypdBuDiPrg8u)WHHcDMEIG1sX3skhANjXVvdlf1Pb6i4)(ssEFc8TqNPNi4xcFR04BnW7BXIdM(3skhqMEIFlP8ea)wY(Teb8WaYFlPCaz6jQAyPOonqhbRLATYTwt1sd07koeSJAJ8bdfy(41AQwrMtW8XvCiyh1g5dgQajzOpQ1uTuwBa4ypdBunGgnPRhxgKk0z6jcwlHewBa4ypdBuDiPrg8u)WHHcDMEIG1sX3skhANjXVvdlf1Pb6i4)(sI4(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TK9Bjc4HbK)w0a9UIdb7Ow0WHnQghliQwQ1sd07koeSJArdh2OIKLrpowquTMQT11sd07QayI6SRVMaXHcWOwt12H2nNoqsg6JAFHATuwlL1sYoxReRLfhmDfhc2rn9KhNsKJRwkQTLxlloy6koeSJA6jpofkdkaouFqsSwk(ws5q7mj(T6qNNAAGW)3xss2pb(wOZ0te8lHVvA8Tg49TyXbt)BjLditpXVLuEcGFlAGExXHGDu3Wbz6TvJJfevR8PwRSeuTesyTuwBa4ypdBuXHGDutNK0CasI(PqNPNiyTMQ94WgpvdYZRrziUAFPwIJGQLIVfioeb04GP)TKmGxdg1Y12bMZ21oowqecwBdhKP3U2mQf61IYGcGdRny3gR9bEn1kHKKMdqs0VVLuo0otIFlK0iFWab10CeSn(VVKiOpb(wOZ0te8lHVvA8Tg49TyXbt)BjLditpXVLuEcGFlrMtW8XvCiyh1g5dgQajzOp0OmgO4qWVLiGhgq(BjsheaEkoeSJAJibH2T)ws5q7mj(ToijQb8do1SX)(ssY9jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8BjYCcMpUIdb7O2iFWqfijd9X3seWddi)TADTI0bbGNIdb7O2isqODBf6m9eb)ws5q7mj(ToijQb8do1SX)(s61(jW3cDMEIGFj8TsJVfjlZ3Ifhm9VLuoGm9e)ws5q7mj(ToijQb8do1SX3seWddi)TOSwrMtW8XvxciA0zxFnOMKTHQajzOpQTfPwPCaz6jQoijQb8do1SrTuu7l1kp5(TaXHiGghm9VLKj(EoRfeNC7ABPxTwaJAVSw5j3bkQTNrTeiVw23skpbWVLiZjy(4Qlben6SRVgutY2qvGKm0h)7lPwWNaFl0z6jc(LW3kn(wKSmFlwCW0)ws5aY0t8BjLdTZK436GKOgWp4uZgFlrapmG83sKoia8uCiyh1grccTBxRPAfPdcapfhc2rTrKGq72QGDIQ9LAjOAnvl2IbGggiOAKaZjEh0T1baD7AnvRiLIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0te8BbIdranoy6FllOlWAFna0TRfoQDaiAQLR1iFWOdmR9cOteE12ZO2xF3oGSBETp475S2Xbfev7L1EnyT3twlj0boSwrBXeRfWp4S2hSwB8QLRTbA3ul6jGDtTb7evB2R1isqOD7VLuEcGFlrMtW8XvJeyoX7GUToaOBRcKKH(4FFj1c)e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(TezobZhxDjGOrND91GAs2gQcKbBxRPALYbKPNO6GKOgWp4uZg1(sTYtUFlqCicOXbt)BjzIVNZAbXj3UwcKxlRwaJAVSw5j3bkQTNrTT0R(TKYH2zs8B1KtqOBRV8i)3xsYk3pb(wOZ0te8lHVvA8Tg49TyXbt)BjLditpXVLuEcGFlkR1iqPABbOswvWGq2p9WGdIQLqcR1iqPABbOsEQGbHSF6HbhevlHewRrGs12cqfXPcgeY(PhgCquTuuRPAzXbtxfmiK9tpm4Gi1bjr9a6cS2xQ1waQizzQTLxRK9BbIdranoy6FRxddcz)Q1YGdIQfmXrTEE1cjjrqiF4SDTgaxTag1EnyTsbMogmnCcV21cI0a9ETJSw4vRG9APXAbH9ouamVAVSwq4qGHx71WxTp47aRLVAVgSwjpyKxtTsbMogmnCcV21oowq03skhANjXVvlkW40adeupm4GO)9LKSY(jW3cDMEIGFj8TsJV1aVVfloy6FlPCaz6j(TKYta8Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8AnvBRRvkhqMEIQwuGXPbgiOEyWbr1AQwqKgO3vbdcz)0ddoislfy6yW0Wj8ARaZh)BjLdTZK43kbUbee1zxlYCcMp(4FFjjR8(e4BHotprWVe(wPX3AG33Ifhm9VLuoGm9e)ws5ja(Tcah7zyJkoeSJ6goitVTcDMEIG1AQwkRLYAfPu0z)ue1oGSxRPAfzobZhxfmiK9tpm4GivGKm0h1(sTs5aY0tu1Wbz6T1JJfePpijwlf1sX3skhANjXV14ybr6goitV9)(33QdDEQPbc)tGVKK9tGVf6m9eb)s4BXIdM(3Idb7OMeogWjo(wIgg6Flz)wIaEya5VfnqVRetKdbpoOBRcKf3)(ssEFc8TyXbt)BXHGDutp5X9TqNPNi4xc)7ljI7tGVfloy6FloeSJAAoc2g)wOZ0te8lH)9V)9TKIXaM(xsYtUYtw52cKxl4B9WHdD7X3sYSLEns61jPx)eFT1sGgSwiPrgxT9mQ9DdhKP3(DTb2IbGbcw7ijXAzGlj5dbRv0WUnouLzem0XALL4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzem0XALCeFTTkDPyCiyTVVa6eHNIPfkrMtW8XFx7L1(wK5emFCftlExlLYkdfQYmcg6yTVwIV2wLUumoeS23xaDIWtX0cLiZjy(4VR9YAFlYCcMpUIPfVRLszLHcvzgbdDS2wiXxBRsxkghcw7Br6GaWtjN31EzTVfPdcapLCuOZ0te8DTukRmuOkZiyOJ1klXr812Q0LIXHG1(wKoia8uY5DTxw7Br6GaWtjhf6m9ebFxlLYkdfQYmcg6yTYkzj(ABv6sX4qWAFlsheaEk58U2lR9TiDqa4PKJcDMEIGVRLszLHcvzgbdDSwzjiIV2wLUumoeS23hpr)uY5DTxw77JNOFk5OqNPNi47APuwzOqvMrWqhRvwcI4RTvPlfJdbR9TiDqa4PKZ7AVS23I0bbGNsok0z6jc(UwkLvgkuLzem0XALNSeFTTkDPyCiyTVfPdcapLCEx7L1(wKoia8uYrHotprW31sPSYqHQmRmtYSLEns61jPx)eFT1sGgSwiPrgxT9mQ9DhoAGUTonqhJ31gylgagiyTJKeRLbUKKpeSwrd724qvMrWqhRvwIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLs5jdfQYmcg6yTYJ4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzem0XAjoIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwjlXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowlbr812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1k5i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(Uw(QvY41JGRLszLHcvzgbdDS2wiXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowBlK4RTvPlfJdbR9TiDqa4PKZ7AVS23I0bbGNsok0z6jc(Uw(QvY41JGRLszLHcvzgbdDSwzLhXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sP8KHcvzgbdDSwzjiIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwzBbeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTY2cj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALNSeFTTkDPyCiyTVpEI(PKZ7AVS23hpr)uYrHotprW31sPSYqHQmJGHowR8KSeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYtgkuLzem0XALNKL4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47A5RwjJxpcUwkLvgkuLzem0XALNKJ4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47A5RwjJxpcUwkLvgkuLzem0XAL3RL4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzLzsMT0RrsVoj96N4RTwc0G1cjnY4QTNrTVJ84dM(7AdSfdadeS2rsI1YaxsYhcwROHDBCOkZiyOJ1klXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukRmuOkZiyOJ1klXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowR8i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XAjoIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwcI4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzem0XALCeFTTkDPyCiyTVpEI(PKZ7AVS23hpr)uYrHotprW31sPSYqHQmJGHowRSYL4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzem0XALTfs812Q0LIXHG1((4j6NsoVR9YAFF8e9tjhf6m9ebFxlLYkdfQYmcg6yTY2cj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALNCj(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLszLHcvzgbdDSw5jxIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSw5jlXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukRmuOkZiyOJ1kpzj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALN8i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALhXr812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZkZKmBPxJKEDs61pXxBTeObRfsAKXvBpJAFNgOJX7AdSfdadeS2rsI1YaxsYhcwROHDBCOkZiyOJ1klXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowR8i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALL4i(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLszLHcvzgbdDSwzLCeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlF1kz86rW1sPSYqHQmJGHowRSVwIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLVALmE9i4APuwzOqvMrWqhRv2waXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukRmuOkZkZKmBPxJKEDs61pXxBTeObRfsAKXvBpJAFdIDgyEVRnWwmamqWAhjjwldCjjFiyTIg2TXHQmJGHowR8i(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLs5jdfQYmcg6yTswIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwzLSeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTYk5i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALTfq812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kp5s812Q0LIXHG1AbjBvTJ2(XYu7RpQ9YAjyaUwqOu4aMETPbg8LrTukrkQLszLHcvzgbdDSw5jxIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSw5rCeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlF1kz86rW1sPSYqHQmJGHowR8KSeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTYJGi(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALNKJ4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRvEVwIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSw51ci(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzLzsMT0RrsVoj96N4RTwc0G1cjnY4QTNrTVncuKK089U2aBXaWabRDKKyTmWLK8HG1kAy3ghQYmcg6yTsoIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwjhXxBRsxkghcw7Br6GaWtjN31EzTVfPdcapLCuOZ0te8DTukRmuOkZiyOJ1kp5s812Q0LIXHG1(wKoia8uY5DTxw7Br6GaWtjhf6m9ebFxlLYkdfQYmcg6yTYtwIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSw5jlXxBRsxkghcw7Br6GaWtjN31EzTVfPdcapLCuOZ0te8DTukRmuOkZiyOJ1kp5r812Q0LIXHG1(wKoia8uY5DTxw7Br6GaWtjhf6m9ebFxlLYkdfQYmcg6yTYRfs812Q0LIXHG1((4j6NsoVR9YAFF8e9tjhf6m9ebFxlLYtgkuLzem0XALxlK4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRL4KhXxBRsxkghcw77rcmPHoOsoVR9YAFpsGjn0bvYrHotprW31sPSYqHQmJGHowlXjpIV2wLUumoeS23JeysdDqLCEx7L1(EKatAOdQKJcDMEIGVRLVALmE9i4APuwzOqvMrWqhRL4ioIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwIJ4i(ABv6sX4qWAFlsheaEk58U2lR9TiDqa4PKJcDMEIGVRLszLHcvzgbdDSwItYs812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DT8vRKXRhbxlLYkdfQYmcg6yTehbr812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1sCsoIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzwzMKzl9AK0RtsV(j(ARLanyTqsJmUA7zu7BrMtW8XhVRnWwmamqWAhjjwldCjjFiyTIg2TXHQmJGHowRSeFTTkDPyCiyTVpEI(PKZ7AVS23hpr)uYrHotprW31sP8KHcvzgbdDSwzj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALhXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukpzOqvMrWqhRvEeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTehXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukpzOqvMrWqhRL4i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALSeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTeeXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowRKJ4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLNmuOkZiyOJ1(Aj(ABv6sX4qWAFpsGjn0bvY5DTxw77rcmPHoOsok0z6jc(UwkLNmuOkZiyOJ12cj(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLs5jdfQYmcg6yTYkxIV2wLUumoeS23hpr)uY5DTxw77JNOFk5OqNPNi47APuEYqHQmJGHowRSYJ4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLNmuOkZiyOJ1klXr812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kRKL4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRvwcI4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLvgkuLzem0XALvYr812Q0LIXHG1((4j6NsoVR9YAFF8e9tjhf6m9ebFxlLYkdfQYmcg6yTYtUeFTTkDPyCiyTVpEI(PKZ7AVS23hpr)uYrHotprW31sPSYqHQmRmtYSLEns61jPx)eFT1sGgSwiPrgxT9mQ9nN47AdSfdadeS2rsI1YaxsYhcwROHDBCOkZiyOJ1klXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukpzOqvMrWqhRvwIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSw5r812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukpzOqvMrWqhRL4i(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLs5jdfQYmcg6yTehXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowRKL4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRLGi(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALCeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTVwIV2wLUumoeS23hpr)uY5DTxw77JNOFk5OqNPNi47APuwzOqvMrWqhRTfq812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ12cj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XALvUeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTYklXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowRSYJ4RTvPlfJdbR99Xt0pLCEx7L1((4j6Nsok0z6jc(UwkLNmuOkZiyOJ1klXr812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kRKL4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRvwcI4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRvwjhXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukpzOqvMrWqhRv2wiXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukpzOqvMrWqhRvEYL4RTvPlfJdbR9Da4ypdBujN31EzTVdah7zyJk5OqNPNi47APuwzOqvMrWqhRvEYs812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kp5r812Q0LIXHG1((4j6NsoVR9YAFF8e9tjhf6m9ebFxlLYtgkuLzem0XALhbr812Q0LIXHG1((4j6NsoVR9YAFF8e9tjhf6m9ebFxlF1kz86rW1sPSYqHQmJGHowR8KCeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTY71s812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kVwaXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowR8AHeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYkdfQYmcg6yTeNCj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XAjozj(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzem0XAjo5r812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1sCehXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukRmuOkZiyOJ1sCehXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowlXjzj(ABv6sX4qWAFF8e9tjN31EzTVpEI(PKJcDMEIGVRLszLHcvzgbdDSwItYs812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1sCsoIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwIRfq812Q0LIXHG1(oaCSNHnQKZ7AVS23bGJ9mSrLCuOZ0te8DTukRmuOkZiyOJ1kzLlXxBRsxkghcw77JNOFk58U2lR99Xt0pLCuOZ0te8DTukRmuOkZiyOJ1kzLlXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sPSYqHQmJGHowRKvwIV2wLUumoeS23hpr)uY5DTxw77JNOFk5OqNPNi47APuEYqHQmJGHowRKvEeFTTkDPyCiyTVpEI(PKZ7AVS23hpr)uYrHotprW31sPSYqHQmRmtYSLEns61jPx)eFT1sGgSwiPrgxT9mQ9TGNcGjFW0hVRnWwmamqWAhjjwldCjjFiyTIg2TXHQmJGHowRSeFTTkDPyCiyTVdah7zyJk58U2lR9Da4ypdBujhf6m9ebFxlLYtgkuLzem0XALhXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31sP8KHcvzgbdDSwIJ4RTvPlfJdbR1cs2QAhT9JLP2xFu7L1sWaCTGqPWbm9Atdm4lJAPuIuulLYkdfQYmcg6yTswIV2wLUumoeS23bGJ9mSrLCEx7L1(oaCSNHnQKJcDMEIGVRLszLHcvzgbdDSwjhXxBRsxkghcw7Br6GaWtjN31EzTVfPdcapLCuOZ0te8DT8vRKXRhbxlLYkdfQYmcg6yTTaIV2wLUumoeS23xaDIWtX0cLiZjy(4VR9YAFlYCcMpUIPfVRLszLHcvzgbdDS2waXxBRsxkghcw77aWXEg2OsoVR9YAFhao2ZWgvYrHotprW31YxTsgVEeCTukRmuOkZiyOJ1kR8i(ABv6sX4qWAFhao2ZWgvY5DTxw77aWXEg2Osok0z6jc(UwkLvgkuLzLzVosJmoeSwzLBTS4GPx7eoUHQm7BXaxtgFllijWKpy6Tk4(9TmISdN436vELABzSnwBlfc2XYSx5vQTLaSbgxTYRfAETYtUYt2YSYSx5vQTvnSBJdIVm7vELABrQvYFG1ETnGcEwRfKSv12Wo4e621M9AfnS74SwOFyeaghm9AH(4qgS2Sx7Bb7cCQzXbt)TQm7vELABrQTvnSBJ1YHGDud9o0Hx7AVSwoeSJ6goitVDTucVADukg1(G(v7ekfRLh1YHGDu3Wbz6TPqvM9kVsTTi1k5v6VVALmKMc(WAHETT0RNKrTTOaJRwAuWadS22jW7aRnbUAZETb72yTSdwRNxTadOBxBlfc2XALmKXyMdy6QYSx5vQTfP2wcSffyC1AeWmGx7AVSwGbwBlfc2XAF18bJ3JAXEhfhukwRiZjy(41sZdeS20RTvsE9AQf7DuCdvzwzgloy6dLrGIKKMpIrvICiyh1q)W5efxzgloy6dLrGIKKMpIrvICiyh1DMeoHCuMXIdM(qzeOijP5JyuLOi9wuGa1KSZABKSmJfhm9HYiqrssZhXOkrPCaz6jAUZKivor9XHnEArc4N5Pb1ah4zoi2zG5rL4kZyXbtFOmcuKK08rmQsukhqMEIM7mjsfLMAdXzEAqnWbEMdIDgyEuLLGkZyXbtFOmcuKK08rmQsukhqMEIM7mjs1iqdG5uJstZtdQd8mh2Psza4ypdBunGgnPRhxgKMOuKsrN9tjf9RPDqiHIuk6SFkhfroZaKqcfPdcapfhc2rTrKGq72uqH5s5jasvwZLYtauJZbsvULzS4GPpugbkssA(igvjkLditprZDMeP2WsrDAGocAEAqDGN5WovwCqPOgDKeId5tvkhqMEIkor9XHnEArc4N5s5jasvwZLYtauJZbsvULzS4GPpugbkssA(igvjkLditprZDMeP2Hop10aHBEAqDGN5s5jasvULzS4GPpugbkssA(igvjkLditprZDMeP2Wbz6T1JJfePpijAEAqnWbEMdIDgyEuBHLzS4GPpugbkssA(igvjkLditprZDMePYZhU9qpA7cTiZjy(4dZtdQboWZCqSZaZJQClZyXbtFOmcuKK08rmQsukhqMEIM7mjsngAswgnio526Eg6lpsZtdQboWZCqSZaZJkbvMXIdM(qzeOijP5JyuLOuoGm9en3zsKAm0KSmAqCYT19m0rAyEAqnWbEMdIDgyEujOYmwCW0hkJafjjnFeJQeLYbKPNO5otIuJHMKLrdItUTUNHMnmpnOg4apZbXodmpQYtULzS4GPpugbkssA(igvjkLditprZDMePsMN2iqbIG6lpsnDBZtdQboWZCqSZaZJAlOmJfhm9HYiqrssZhXOkrPCaz6jAUZKivY80KSmAqCYT19m0xEKMNgudCGN5GyNbMhvzLBzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQK5Pjzz0G4KBR7zOzdZtdQboWZCqSZaZJQSeuzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQSHMKLrdItUTUNH(YJ080GAGd8mh2PksheaEkoeSJAJibH2TnxkpbqQeNCnxkpbqnohivzLBzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQSHMKLrdItUTUNH(YJ080GAGd8mhe7mW8Okp5wMXIdM(qzeOijP5JyuLOuoGm9en3zsKkBOjzz0G4KBR7zOjZZ80GAGd8mhe7mW8Okp5wMXIdM(qzeOijP5JyuLOuoGm9en3zsKAKgAswgnio526Eg6lpsZtdQd8mxkpbqQYtUTiusqTCr6GaWtXHGDuBeji0UnfLzS4GPpugbkssA(igvjkLditprZDMePE5rQjzz0G4KBR7zOzdZtdQd8mxkpbqQeeXKNCB5uksPOZ(PCODZP7msiHuksheaEkoeSJAJibH2TnXIdkf1OJKqC8IuoGm9evCI6JdB80IeWpkOGyYsqTCkfPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MyXbLIA0rsioKpvPCaz6jQ4e1hh24PfjGFuuMXIdM(qzeOijP5JyuLOuoGm9en3zsK6LhPMKLrdItUTUNHosdZtdQd8mxkpbqQYtUTiu2cA5I0bbGNIdb7O2isqODBkkZyXbtFOmcuKK08rmQsukhqMEIM7mjsLMJGTrnj7S2qCMNguh4zoStvKsrN9t5q7Mt3z0CP8eaPk5KBlcLK84WOTwkpbWwUSYvUuuMXIdM(qzeOijP5JyuLOuoGm9en3zsKknhbBJAs2zTH4mpnOoWZCyNQiLIo7NIO2bKDZLYtaKAlKGArOKKhhgT1s5ja2YLvUYLIYmwCW0hkJafjjnFeJQeLYbKPNO5otIuP5iyButYoRneN5Pb1bEMd7uLYbKPNOIMJGTrnj7S2qCuLR5s5jasTfi3wekj5XHrBTuEcGTCzLRCPOmJfhm9HYiqrssZhXOkrPCaz6jAUZKiv2qtcDijaPMKDwBioZtdQboWZCqSZaZJQSeuzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQxEKAswgTOHdBCyEAqnWbEMdIDgyEuLxzgloy6dLrGIKKMpIrvIs5aY0t0CNjrQCI6lpsnjlJw0WHnompnOg4apZbXodmpQYRmJfhm9HYiqrssZhXOkrPCaz6jAUZKi1oC0aDBDAGogMNguh4zUuEcGuLTLtj2IbGggiOcjnAhip1za6SlqcjKYJNOFQaWrD21g5dgMO84j6NIdb7OgfnjHe2ArkfD2pfrTdi7uyIYwlsPOZ(PCue5mdqcjKfhukQrhjH4GQSesya4ypdBunGgnPRhxgKuyQ1Iuk6SFkPOFnTdkOOmJfhm9HYiqrssZhXOkrPCaz6jAUZKiv2qNUgyGMNguh4zUuEcGuXwma0WabvKSGPdupAq80KadOGqcXwma0Wabv2tgeYxgdnndAJesi2IbGggiOYEYGq(YyOjrqEoHPtiHylgaAyGGkqoiImtxdIcI0gaxGdb6cKqcXwma0WabvqFicGJPNOUfdW(bqQbrPqbsiHylgaAyGGQrcmN4Dq3wha0TjKqSfdanmqq1aWPNzcQzs8AApocjeBXaqddeu9WeHogdDpshKqcXwma0Wabv9jtI6SRP57Myzgloy6dLrGIKKMpIrvIKWiYqdjzBSmJfhm9HYiqrssZhXOkX(ehnIG7N5Wo1rcmPHoOsAo5dor9iNsr)iKWrcmPHoOYayCatuJbGXbtVmJfhm9HYiqrssZhXOkXaWrD21g5dgMd7ufPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MePdcapfhc2rTrKGq72MKYbKPNOINpC7HE02fArMtW8XhMyXbLIA0rsioErkhqMEIkor9XHnEArc4xzgloy6dLrGIKKMpIrvI9ihhDopZHDQTwkhqMEIkJanaMtnknPkRPaWXEg2OceoeqJj05OTwKKKSdwMXIdM(qzeOijP5JyuLihc2rn9KhN5Wo1wlLditprLrGgaZPgLMuL1uRdah7zyJkq4qanMqNJ2ArssYoOjkBTiLIo7Nsk6xt7GqcLYbKPNOQdhnq3wNgOJbfLzS4GPpugbkssA(igvjscJiJHo76lds0pZHDQTwkhqMEIkJanaMtnknPkRPwhao2ZWgvGWHaAmHohT1IKKKDqtIuk6SFkPOFnTdtTwkhqMEIQoC0aDBDAGogLzS4GPpugbkssA(igvjIstbFW0nh2PkLditprLrGgaZPgLMuLTmRmJfhm9bXOkrrc4hgddColZyXbtFqmQseyGAs2zTnsAoStLYJNOFk0Nq7MdDe0ej7SYqCVqTfixtKSZkdXjFQsocIccjKYwF8e9tH(eA3COJGMizNvgI7fQTacIIYmwCW0heJQenYdMU5WovAGExXHGDuBKpyOamkZyXbtFqmQs8GKO(HddZHDQbGJ9mSr1HKgzWt9dhgMOb6Dfktddmoy6kadtukYCcMpUIdb7O2iFWqfid2MqcPZXWuhA3C6ajzOpEHQKvUuuMXIdM(GyuL4eA3CdDlkaOnj6N5WovAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfy(4LzS4GPpigvjsZ26SRVakiAyoStLgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnbI0a9U6sarJo76Rb1KSnubMpEzgloy6dIrvI0ymWGiOBBoStLgO3vCiyh1g5dgkaJYmwCW0heJQePNzcQ7arBZHDQ0a9UIdb7O2iFWqbyuMXIdM(GyuLyhgi9mtqZHDQ0a9UIdb7O2iFWqbyuMXIdM(GyuLi7cCCbp1cEonh2Psd07koeSJAJ8bdfGrzgloy6dIrvIadudpKCyoStLgO3vCiyh1g5dgkaJYmwCW0heJQebgOgEiP5yVJIt7mjs1EYGq(YyOPzqB0CyNknqVR4qWoQnYhmuagesOiZjy(4koeSJAJ8bdvGKm0hYNkbrqMarAGExDjGOrND91GAs2gQamkZyXbtFqmQseyGA4HKM7mjsfjnAhip1za6SlqZHDQImNG5JR4qWoQnYhmubsYqF8cvzjitImNG5JRUeq0OZU(AqnjBdvbsYqF8cvzjOYmwCW0heJQebgOgEiP5otIubdKb7Wa1sXXaNMd7ufzobZhxXHGDuBKpyOcKKH(q(uLNCjKWwlLditprfBOtxdmqQYsiHuEqsKQCnjLditprvhoAGUTonqhdQYAkaCSNHnQgqJM01JldskkZyXbtFqmQseyGA4HKM7mjsDKatn02HhgMd7ufzobZhxXHGDuBKpyOcKKH(q(ujo5siHTwkhqMEIk2qNUgyGuLTmJfhm9bXOkrGbQHhsAUZKiv7zBJgD218yajHt(GPBoStvK5emFCfhc2rTr(GHkqsg6d5tvEYLqcBTuoGm9evSHoDnWaPklHes5bjrQY1KuoGm9evD4Ob6260aDmOkRPaWXEg2OAanAsxpUmiPOmJfhm9bXOkrGbQHhsAUZKivswW0bQhniEAsGbuyoStvK5emFCfhc2rTr(GHkqsg6JxOsqMOS1s5aY0tu1HJgOBRtd0XGQSes4bjr5tCYLIYmwCW0heJQebgOgEiP5otIujzbthOE0G4PjbgqH5WovrMtW8XvCiyh1g5dgQajzOpEHkbzskhqMEIQoC0aDBDAGoguL1enqVRcah1zxBKpyOammrd07QaWrD21g5dgQajzOpEHkLYk3wecQLhao2ZWgvdOrt66XLbjfMoij(cXj3YmwCW0heJQebgOgEiP5otIuhnmy(GG6mO1zxFzqI(zoSt9GKiv5siHukLditprvcCdiiQZUwK5emF8HjkPuKsrN9tru7aYUjrMtW8Xvbdcz)0ddoisfijd9XluLNjrMtW8XvCiyh1g5dgQajzOpEHkbzsK5emFC1LaIgD21xdQjzBOkqsg6JxOsquqiHImNG5JR4qWoQnYhmubsYqF8cv5riHDODZPdKKH(4frMtW8XvCiyh1g5dgQajzOpOGIYSxPwcsj5QfoQ9AWAhgicwB2R9AWATsG5eVd621(AaOBxRrKTOO4GtSmJfhm9bXOkrGbQHhsAUZKi1rcmN4Dq3wha0Tnh2PsPuoGm9evhKe1a(bNA2GyuYIdMUkyqi7NEyWbrkuguaCO(GKylxKsrN9tru7aYofeJswCW0vGiFn0z4OcLbfahQpij2YfPu0z)uokICMbifeJfhmD1LaIgD21xdQjzBOcLbfahQpij(YXHnEkq44yxGV(GGusokmrPuoGm9evnSuuNgOJGesiLIuk6SFkIAhq2nfao2ZWgvCiyh1qVdD41MckmDCyJNceoo2fO8LhbvM9kVsTS4GPpigvj64tpbCqDGJCkfnhyG6Ng4e1cECq3MQSMd7uPb6Dfhc2rTr(GHcWGqcbrAGExDjGOrND91GAs2gQamiKqW8ubdcz)0ddoisDqbrq3UmJfhm9bXOkrbpNAwCW01t44m3zsKQGNcGjFW0hLzS4GPpigvjk45uZIdMUEchN5otIu5enFCbuCuL1CyNkloOuuJoscXH8PkLditprfNO(4WgpTib8RmJfhm9bXOkrbpNAwCW01t44m3zsKAdhKP32CyNQiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3UmJfhm9bXOkrbpNAwCW01t44m3zsKAhoAGUTonqhdZHDQs5aY0tu1WsrDAGocsvUMKYbKPNOQdhnq3wNgOJHPwtPiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3MIYmwCW0heJQef8CQzXbtxpHJZCNjrQPb6yyoStvkhqMEIQgwkQtd0rqQY1uRPuKsrN9tru7aYUPaWXEg2OIdb7OUHdY0Btrzgloy6dIrvIcEo1S4GPRNWXzUZKivrMtW8XhMd7uBnLIuk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBkkZyXbtFqmQsuWZPMfhmD9eooZDMePg5XhmDZHDQs5aY0tu1Hop10aHtvUMAnLIuk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBkkZyXbtFqmQsuWZPMfhmD9eooZDMeP2Hop10aHBoStvkhqMEIQo05PMgiCQYAQ1uksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TPOmRmJfhm9HItKApYXrNZZCyNAa4ypdBubchcOXe6C0wlsss2bnjYCcMpUIgO31GWHaAmHohT1IKKKDqvGmyBt0a9UceoeqJj05OTwKKKSdQ7roofy(4MOKgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnbI0a9U6sarJo76Rb1KSnubMpofMezobZhxDjGOrND91GAs2gQcKKH(GQCnrjnqVR4qWoQfnCyJQXXcIEHQuoGm9evCI6lpsnjlJw0WHnomrjLhpr)ubGJ6SRnYhmmjYCcMpUkaCuNDTr(GHkqsg6JxOAlanjYCcMpUIdb7O2iFWqfijd9H8LYbKPNO6YJutYYObXj3w3ZqZguqiHu26JNOFQaWrD21g5dgMezobZhxXHGDuBKpyOcKKH(q(s5aY0tuD5rQjzz0G4KBR7zOzdkiKqrMtW8XvCiyh1g5dgQajzOpEHQTaKckkZyXbtFO4ejgvj2HbQPN84mh2Psza4ypdBubchcOXe6C0wlsss2bnjYCcMpUIgO31GWHaAmHohT1IKKKDqvGmyBt0a9UceoeqJj05OTwKKKSdQ7WavG5JBYiqPABbOswvpYXrNZJccjKYaWXEg2OceoeqJj05OTwKKKSdA6GKiv5srzgloy6dfNiXOkXEKJt7Pu2CyNAa4ypdBuzhWXSTgkGIjAsK5emFCfhc2rTr(GHkqsg6d5tCY1KiZjy(4Qlben6SRVgutY2qvGKm0huLRjkPb6Dfhc2rTOHdBunowq0luLYbKPNOItuF5rQjzz0IgoSXHjkP84j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF8cvBbOjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswgnio526EgA2GccjKYwF8e9tfaoQZU2iFWWKiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlJgeNCBDpdnBqbHekYCcMpUIdb7O2iFWqfijd9XluTfGuqrzgloy6dfNiXOkXEKJt7Pu2CyNAa4ypdBuzhWXSTgkGIjAsK5emFCfhc2rTr(GHkqsg6dQY1eLusPiZjy(4Qlben6SRVgutY2qvGKm0hYxkhqMEIk2qtYYObXj3w3ZqF5rAIgO3vCiyh1IgoSr14ybruPb6Dfhc2rTOHdBurYYOhhliIccjKsrMtW8XvxciA0zxFnOMKTHQajzOpOkxt0a9UIdb7Ow0WHnQghli6fQs5aY0tuXjQV8i1KSmArdh24Gckmrd07QaWrD21g5dgkW8XPOmJfhm9HItKyuLihc2rnjCmGtCyoStvKsrN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1nCqMEB14ybrVilbzsK5emFCvWGq2p9WGdIubsYqF8cvPCaz6jQA4Gm926XXcI0hKejgkdkaouFqs0KiZjy(4Qlben6SRVgutY2qvGKm0hVqvkhqMEIQgoitVTECSGi9bjrIHYGcGd1hKejgloy6QGbHSF6HbhePqzqbWH6dsIMezobZhxXHGDuBKpyOcKKH(4fQs5aY0tu1Wbz6T1JJfePpijsmuguaCO(GKiXyXbtxfmiK9tpm4GifkdkaouFqsKyS4GPRUeq0OZU(AqnjBdvOmOa4q9bjrZfnm0PkBzgloy6dfNiXOkroeSJAs4yaN4WCyNQiLIo7Nsk6xt7Wua4ypdBuXHGDud9o0HxBt0a9UIdb7OUHdY0BRghli6fzjitImNG5JRUeq0OZU(AqnjBdvbsYqF8cvPCaz6jQA4Gm926XXcI0hKejgkdkaouFqs0KiZjy(4koeSJAJ8bdvGKm0hVqvkhqMEIQgoitVTECSGi9bjrIHYGcGd1hKejgloy6Qlben6SRVgutY2qfkdkaouFqs0CrddDQYwMXIdM(qXjsmQsKdb7OMEYJZCyNQiLIo7Nsk6xt7W0Xt0pfhc2rnkAsthKeFrw5AsK5emFCfjmImg6SRVmir)ubsYqFyIgO3vIjYHGhh0TvJJfe9cXvMXIdM(qXjsmQseyGA4HKM7mjsDKaZjEh0T1baDBZHDQbGJ9mSr1aA0KUECzqAYiqPABbOswfknf8btVmJfhm9HItKyuL4LaIgD21xdQjzBO5Wo1aWXEg2OAanAsxpUminzeOuTTaujRcLMc(GPxMXIdM(qXjsmQsKdb7O2iFWWCyNAa4ypdBunGgnPRhxgKMO0iqPABbOswfknf8btNqcncuQ2waQKvDjGOrND91GAs2gsrzgloy6dfNiXOkrsyezm0zxFzqI(zoStnaCSNHnQ4qWoQHEh6WRTjrMtW8XvxciA0zxFnOMKTHQajzOpEHQSY1KiZjy(4koeSJAJ8bdvGKm0hVqvwcQmJfhm9HItKyuLijmImg6SRVmir)mh2PkYCcMpUIdb7O2iFWqfijd9XluBbMezobZhxDjGOrND91GAs2gQcKKH(4fQTatusd07koeSJArdh2OACSGOxOkLditprfNO(YJutYYOfnCyJdtus5Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(4fQ2cqtImNG5JR4qWoQnYhmubsYqFiFcIccjKYwF8e9tfaoQZU2iFWWKiZjy(4koeSJAJ8bdvGKm0hYNGOGqcfzobZhxXHGDuBKpyOcKKH(4fQ2cqkOOmJfhm9HItKyuLiknf8bt3CyN6bjr5tCY1ua4ypdBunGgnPRhxgKMePu0z)usr)AAhMmcuQ2waQKvrcJiJHo76lds0VYmwCW0hkorIrvIO0uWhmDZHDQhKeLpXjxtbGJ9mSr1aA0KUECzqAIgO3vCiyh1IgoSr14ybrVqvkhqMEIkor9LhPMKLrlA4WghMezobZhxDjGOrND91GAs2gQcKKH(GQCnjYCcMpUIdb7O2iFWqfijd9XluTfGLzS4GPpuCIeJQerPPGpy6Md7upijkFItUMcah7zyJQb0OjD94YG0KiZjy(4koeSJAJ8bdvGKm0huLRjkPKsrMtW8XvxciA0zxFnOMKTHQajzOpKVuoGm9evSHMKLrdItUTUNH(YJ0enqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowqefesiLImNG5JRUeq0OZU(AqnjBdvbsYqFqvUMOb6Dfhc2rTOHdBunowq0luLYbKPNOItuF5rQjzz0IgoSXbfuyIgO3vbGJ6SRnYhmuG5JtH5q)WiamonStLgO3vdOrt66XLbPACSGiQ0a9UAanAsxpUmivKSm6XXcImh6hgbGXPHKKiiKpKQSLzS4GPpuCIeJQedgeY(PhgCqK5WovrMtW8XvxciA0zxFnOMKTHQajzOpEbLbfahQpijAIskpEI(Pcah1zxBKpyysK5emFCva4Oo7AJ8bdvGKm0hVq1waAsK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLrdItUTUNHMnOGqcPS1hpr)ubGJ6SRnYhmmjYCcMpUIdb7O2iFWqfijd9H8LYbKPNO6YJutYYObXj3w3ZqZguqiHImNG5JR4qWoQnYhmubsYqF8cvBbifLzS4GPpuCIeJQedgeY(PhgCqK5WovrMtW8XvCiyh1g5dgQajzOpEbLbfahQpijAIskPuK5emFC1LaIgD21xdQjzBOkqsg6d5lLditprfBOjzz0G4KBR7zOV8inrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizz0JJferbHesPiZjy(4Qlben6SRVgutY2qvGKm0huLRjAGExXHGDulA4WgvJJfe9cvPCaz6jQ4e1xEKAswgTOHdBCqbfMOb6Dva4Oo7AJ8bdfy(4uuMXIdM(qXjsmQsee5RHodhnh2PkYCcMpUIdb7O2iFWqfijd9bv5AIskPuK5emFC1LaIgD21xdQjzBOkqsg6d5lLditprfBOjzz0G4KBR7zOV8inrd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizz0JJferbHesPiZjy(4Qlben6SRVgutY2qvGKm0huLRjAGExXHGDulA4WgvJJfe9cvPCaz6jQ4e1xEKAswgTOHdBCqbfMOb6Dva4Oo7AJ8bdfy(4uuMXIdM(qXjsmQseyGA4HKM7mjsDKaZjEh0T1baDBZHDQusd07koeSJArdh2OACSGOxOkLditprfNO(YJutYYOfnCyJdcj0iqPABbOswvWGq2p9WGdIOWeLuE8e9tfaoQZU2iFWWKiZjy(4QaWrD21g5dgQajzOpEHQTa0KiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlJgeNCBDpdnBqbHeszRpEI(Pcah1zxBKpyysK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLrdItUTUNHMnOGqcfzobZhxXHGDuBKpyOcKKH(4fQ2cqkkZyXbtFO4ejgvjEjGOrND91GAs2gAoStvKsrN9tjf9RPDykaCSNHnQ4qWoQHEh6WRTjrMtW8XvKWiYyOZU(YGe9tfijd9Xluji5wMXIdM(qXjsmQs8sarJo76Rb1KSn0CyNQiLIo7Nsk6xt7Wua4ypdBuXHGDud9o0HxBt0a9UIegrgdD21xgKOFQajzOpEHQ8KRjrMtW8XvCiyh1g5dgQajzOpEHQTaSmJfhm9HItKyuL4LaIgD21xdQjzBO5WovkPb6Dfhc2rTOHdBunowq0luLYbKPNOItuF5rQjzz0IgoSXbHeAeOuTTaujRkyqi7NEyWbruyIskpEI(Pcah1zxBKpyysK5emFCva4Oo7AJ8bdvGKm0hVq1waAsK5emFCfhc2rTr(GHkqsg6d5lLditpr1LhPMKLrdItUTUNHMnOGqcPS1hpr)ubGJ6SRnYhmmjYCcMpUIdb7O2iFWqfijd9H8LYbKPNO6YJutYYObXj3w3ZqZguqiHImNG5JR4qWoQnYhmubsYqF8cvBbifLzS4GPpuCIeJQe5qWoQnYhmmh2PsjLImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQydnjlJgeNCBDpd9LhPjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGikiKqkfzobZhxDjGOrND91GAs2gQcKKH(GQCnrd07koeSJArdh2OACSGOxOkLditprfNO(YJutYYOfnCyJdkOWenqVRcah1zxBKpyOaZhVmJfhm9HItKyuLya4Oo7AJ8bdZHDQ0a9UkaCuNDTr(GHcmFCtusPiZjy(4Qlben6SRVgutY2qvGKm0hYxEY1enqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowqefesiLImNG5JRUeq0OZU(AqnjBdvbsYqFqvUMOb6Dfhc2rTOHdBunowq0luLYbKPNOItuF5rQjzz0IgoSXbfuyIsrMtW8XvCiyh1g5dgQajzOpKVSYJqcbrAGExDjGOrND91GAs2gQamOOmJfhm9HItKyuL4Ob2pOBRnYhmmh2PkYCcMpUIdb7OodAvGKm0hYNGiKWwF8e9tXHGDuNbDzgloy6dfNiXOkroeSJA6jpoZHDQIuk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyycePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIOkznzeOuTTaujRIdb7OodAtS4Gsrn6ijehV8AlZyXbtFO4ejgvjYHGDutZrW2O5WovrkfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDuBKpyOammbI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybruLSLzS4GPpuCIeJQe5qWoQPN84mh2PksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjkbZtfmiK9tpm4GivGKm0hYxYriHGinqVRcgeY(PhgCqKwkW0XGPHt41wbyqHjqKgO3vbdcz)0ddoislfy6yW0Wj8ARghli6fjRjwCqPOgDKeIdQexzgloy6dfNiXOkroeSJ6mOnh2PksPOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0ddoislfy6yW0Wj8ARghliIkXvMXIdM(qXjsmQsKdb7OMMJGTrZHDQIuk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyycePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIOkVYmwCW0hkorIrvICiyh1OmgZCat3CyNQiLIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMmcuQ2waQKNkyqi7NEyWbrMyXbLIA0rsioKpXvMXIdM(qXjsmQsKdb7OgLXyMdy6Md7ufPu0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MOb6Dfhc2rTr(GHcWWeisd07QGbHSF6HbhePLcmDmyA4eETvJJfervwtS4Gsrn6ijehYN4kZyXbtFO4ejgvjAe4aDbQZUMe6GMd7uPb6DfiYxdDgoQammbI0a9U6sarJo76Rb1KSnubyycePb6D1LaIgD21xdQjzBOkqsg6JxOsd07kJahOlqD21KqhurYYOhhliQLZIdMUIdb7OMEYJtHYGcGd1hKenrjLhpr)ubosNDbAIfhukQrhjH44fjlfesiloOuuJoscXXleefMOS1bGJ9mSrfhc2rnDssZbij6hHeECyJNQb551OmeN8jocIIYmwCW0hkorIrvICiyh10tECMd7uPb6DfiYxdDgoQammrjLhpr)ubosNDbAIfhukQrhjH44fjlfesiloOuuJoscXXleefMOS1bGJ9mSrfhc2rnDssZbij6hHeECyJNQb551OmeN8jocIIYmwCW0hkorIrvIdadm8ukxMXIdM(qXjsmQsKdb7OMMJGTrZHDQ0a9UIdb7Ow0WHnQghlis(uPKfhukQrhjH4Ofrwkmfao2ZWgvCiyh10jjnhGKOFMooSXt1G88AugI7fIJGkZyXbtFO4ejgvjYHGDutZrW2O5WovAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGOYmwCW0hkorIrvICiyh1zqBoStLgO3vCiyh1IgoSr14ybruLRjkfzobZhxXHGDuBKpyOcKKH(q(YsqesyRPuKsrN9tru7aYUPaWXEg2OIdb7OUHdY0BtbfLzS4GPpuCIeJQeD8AWqFiPbooZHDQugypWrdtprcjS1huqe0TPWenqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowquzgloy6dfNiXOkroeSJAs4yaN4WCyNknqVRetKdbpoOBRcKfNPaWXEg2OIdb7OUHdY0BBIskpEI(PysJjSdf8bt3eloOuuJoscXXlTakiKqwCqPOgDKeIJxiikkZyXbtFO4ejgvjYHGDutchd4ehMd7uPb6DLyICi4XbDBvGS4mD8e9tXHGDuJIM0eisd07Qlben6SRVgutY2qfGHjkpEI(PysJjSdf8btNqczXbLIA0rsioEPfsrzgloy6dfNiXOkroeSJAs4yaN4WCyNknqVRetKdbpoOBRcKfNPJNOFkM0yc7qbFW0nXIdkf1OJKqC8IKTmJfhm9HItKyuLihc2rnkJXmhW0nh2Psd07koeSJArdh2OACSGOxOb6Dfhc2rTOHdBurYYOhhliQmJfhm9HItKyuLihc2rnkJXmhW0nh2Psd07koeSJArdh2OACSGiQ0a9UIdb7Ow0WHnQizz0JJfezYiqPABbOswfhc2rnnhbBJLzVYRulloy6dfNiXOkruAk4dMU5q)WiamonStLKDwzio5tTfqqMd9dJaW40qsseeYhsv2YSYmwCW0hkbpfat(GPpOkLditprZDMeP2WsrDAGocAEAqDGN5s5jasvwZHDQs5aY0tu1WsrDAGocsvUMmcuQ2waQKvHstbFW0n1Akdah7zyJQb0OjD94YGKqcdah7zyJQdjnYGN6homOOmJfhm9HsWtbWKpy6dIrvIs5aY0t0CNjrQnSuuNgOJGMNguh4zUuEcGuL1CyNQuoGm9evnSuuNgOJGuLRjAGExXHGDuBKpyOaZh3KiZjy(4koeSJAJ8bdvGKm0hMOmaCSNHnQgqJM01JldscjmaCSNHnQoK0idEQF4WGIYmwCW0hkbpfat(GPpigvjkLditprZDMeP2Hop10aHBEAqDGN5s5jasvwZHDQ0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybrMAnnqVRcGjQZU(AcehkadtDODZPdKKH(4fQusjj78RpyXbtxXHGDutp5XPe54OOLZIdMUIdb7OMEYJtHYGcGd1hKePOm7vQvYaEnyulxBhyoBx74ybriyTnCqME7AZOwOxlkdkaoS2GDBS2h41uRessAoajr)kZyXbtFOe8uam5dM(GyuLOuoGm9en3zsKksAKpyGGAAoc2gnpnOoWZCP8eaPsd07koeSJ6goitVTACSGi5tvwcIqcPmaCSNHnQ4qWoQPtsAoajr)mDCyJNQb551Ome3lehbrrz2R8k1YIdM(qj4PayYhm9bXOkrPCaz6jAUZKi1jponBObgO5GyNbMhv5AEAqDGN5WovAGExXHGDuBKpyOammrPuoGm9evtECA2qdmqQYLqcpijkFQs5aY0tun5XPzdnWajMSeefMlLNai1dsILzVYRuBlfc2XAF1ibH2TR1gkfh1Y1kLditpXAzYeWVAZETcWW8APbUAFW3ZzTadSwU2(KVAXXbj5dMETnyGQAjqdw7askQ1isPqqeS2ajzOp0OmgO4qWArzmcCmGPxlyIJA98Q9jdIQ9bNZA7zuRrKGq721ccG1EzTxdwlnqmU2168beyTzV2RbRvagQYSx5vQLfhm9HsWtbWKpy6dIrvIs5aY0t0CNjrQ44GK8HGA2qlYCcMpU5Pb1bEMlLNaivkfzobZhxXHGDuBKpyOabc(GP3YPu2wekLRsUexlxKoia8uCiyh1grccTBRc2jIckOOfHYdsITis5aY0tun5XPzdnWaPOmJfhm9HsWtbWKpy6dIrvIs5aY0t0CNjrQhKe1a(bNA2W80G6apZHDQI0bbGNIdb7O2isqODBZLYtaKQiZjy(4koeSJAJ8bdvGKm0hAugduCiyzgloy6dLGNcGjFW0heJQeLYbKPNO5otIupijQb8do1SH5Pb1bEMd7uBTiDqa4P4qWoQnIeeA32CP8eaPkYCcMpUIdb7O2iFWqfijd9rz2RuRKj(EoRfeNC7ABPxTwaJAVSw5j3bkQTNrTeiVwwzgloy6dLGNcGjFW0heJQeLYbKPNO5otIupijQb8do1SH5PbvswgZLYtaKQiZjy(4Qlben6SRVgutY2qvGKm0hMd7uPuK5emFC1LaIgD21xdQjzBOkqsg6JwePCaz6jQoijQb8do1SbfVip5wM9k1AbDbw7RbGUDTWrTdartTCTg5dgDGzTxaDIWR2Eg1(672bKDZR9bFpN1ooOGOAVS2RbR9EYAjHoWH1kAlMyTa(bN1(G1AJxTCTnq7MArpbSBQnyNOAZETgrccTBxMXIdM(qj4PayYhm9bXOkrPCaz6jAUZKi1dsIAa)GtnByEAqLKLXCP8eaPEb0jcp1ibMt8oOBRda62krMtW8XvbsYqFyoStvKoia8uCiyh1grccTBBsKoia8uCiyh1grccTBRc2j6fcYe2IbGggiOAKaZjEh0T1baDBtIuk6SFkIAhq2nfao2ZWgvCiyh1nCqME7YSxPwjt89Cwlio521sG8Az1cyu7L1kp5oqrT9mQTLE1YmwCW0hkbpfat(GPpigvjkLditprZDMeP2KtqOBRV8inpnOoWZCP8eaPkYCcMpU6sarJo76Rb1KSnufid22KuoGm9evhKe1a(bNA24f5j3YSxP2xddcz)Q1YGdIQfmXrTEE1cjjrqiF4SDTgaxTag1EnyTsbMogmnCcV21cI0a9ETJSw4vRG9APXAbH9ouamVAVSwq4qGHx71WxTp47aRLVAVgSwjpyKxtTsbMogmnCcV21oowquzgloy6dLGNcGjFW0heJQeLYbKPNO5otIuBrbgNgyGG6HbhezEAqDGN5s5jasLsJaLQTfGkzvbdcz)0ddoiIqcncuQ2waQKNkyqi7NEyWbresOrGs12cqfXPcgeY(PhgCqefMyXbtxfmiK9tpm4Gi1bjr9a6c8fBbOIKLPLlzlZELxP2xVaAdDEwRfKSv1kAqbriyTGinqVRcgeY(PhgCqKwkW0XGPHt41wbMpU51sdC1En8vlyId)9v7tgev7td61EnyTmiy61YggtioQ91y96Z1c9XX(nBRkZELxPwwCW0hkbpfat(GPpigvjkLditprZDMeP2IcmonWab1ddoiY80G6apZLYtaKkLgbkvBlavYQcgeY(PhgCqeHeAeOuTTaujpvWGq2p9WGdIiKqJaLQTfGkItfmiK9tpm4GikmbI0a9Ukyqi7NEyWbrAPathdMgoHxBfy(4LzS4GPpucEkaM8btFqmQsukhqMEIM7mjsnbUbee1zxlYCcMp(W80G6apZLYtaKknqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmuG5JBcePb6D1LaIgD21xdQjzBOcmFCtTwkhqMEIQwuGXPbgiOEyWbrMarAGExfmiK9tpm4GiTuGPJbtdNWRTcmF8YmwCW0hkbpfat(GPpigvjkLditprZDMePoowqKUHdY0BBEAqDGN5s5jasnaCSNHnQ4qWoQB4Gm92MOKsrkfD2pfrTdi7MezobZhxfmiK9tpm4GivGKm0hViLditprvdhKP3wpowqK(GKifuuMvM9k1(Qbmd4bL8G1cmGUDT2bCmBxluaftS2h41ulBOQvYFG1cVAFGxtTxEK1MxdgpWbQkZyXbtFOezobZhFqTh540EkLnh2Pgao2ZWgv2bCmBRHcOyIMezobZhxXHGDuBKpyOcKKH(q(eNCnjYCcMpU6sarJo76Rb1KSnufid22eL0a9UIdb7Ow0WHnQghli6fQs5aY0tuD5rQjzz0IgoSXHjkP84j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF8cvBbOjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswgnio526EgA2GccjKYwF8e9tfaoQZU2iFWWKiZjy(4koeSJAJ8bdvGKm0hYxkhqMEIQlpsnjlJgeNCBDpdnBqbHekYCcMpUIdb7O2iFWqfijd9XluTfGuqrzgloy6dLiZjy(4dIrvI9ihN2tPS5Wo1aWXEg2OYoGJzBnuaft0KiZjy(4koeSJAJ8bdvGmyBtu26JNOFk0Nq7MdDeKqcP84j6Nc9j0U5qhbnrYoRmeN8P(ALlfuyIskfzobZhxDjGOrND91GAs2gQcKKH(q(Ykxt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybruqiHukYCcMpU6sarJo76Rb1KSnufijd9bv5AIgO3vCiyh1IgoSr14ybruLlfuyIgO3vbGJ6SRnYhmuG5JBIKDwzio5tvkhqMEIk2qtcDijaPMKDwBiUYmwCW0hkrMtW8XheJQe7roo6CEMd7udah7zyJkq4qanMqNJ2ArssYoOjrMtW8Xv0a9UgeoeqJj05OTwKKKSdQcKbBBIgO3vGWHaAmHohT1IKKKDqDpYXPaZh3eL0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XPWKiZjy(4Qlben6SRVgutY2qvGKm0huLRjkPb6Dfhc2rTOHdBunowq0luLYbKPNO6YJutYYOfnCyJdtus5Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(4fQ2cqtImNG5JR4qWoQnYhmubsYqFiFPCaz6jQU8i1KSmAqCYT19m0SbfesiLT(4j6NkaCuNDTr(GHjrMtW8XvCiyh1g5dgQajzOpKVuoGm9evxEKAswgnio526EgA2GccjuK5emFCfhc2rTr(GHkqsg6JxOAlaPGIYmwCW0hkrMtW8XheJQe7Wa10tECMd7udah7zyJkq4qanMqNJ2ArssYoOjrMtW8Xv0a9UgeoeqJj05OTwKKKSdQcKbBBIgO3vGWHaAmHohT1IKKKDqDhgOcmFCtgbkvBlavYQ6roo6CELzVsTVkdJABzjbQ9bEn12sVATWETW79OwrscD7AbmQDKPRQ911RfE1(aNZAPXAbgiyTpWRPwcKxlZ8Af84QfE1oMq7MB2UwASNbwMXIdM(qjYCcMp(GyuLijmImg6SRVmir)mh2PszRdah7zyJQb0OjD94YGKqcPb6D1aA0KUECzqQamOWKiZjy(4Qlben6SRVgutY2qvGKm0hViLditprfzEAJaficQV8i10TjKqkLYbKPNO6GKOgWp4uZgYxkhqMEIkY80KSmAqCYT19m0SHjrMtW8XvxciA0zxFnOMKTHQajzOpKVuoGm9evK5Pjzz0G4KBR7zOV8iPOmJfhm9HsK5emF8bXOkrsyezm0zxFzqI(zoStvK5emFCfhc2rTr(GHkqgSTjkB9Xt0pf6tODZHocsiHuE8e9tH(eA3COJGMizNvgIt(uFTYLckmrjLImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQydnjlJgeNCBDpd9LhPjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGikiKqkfzobZhxDjGOrND91GAs2gQcKKH(GQCnrd07koeSJArdh2OACSGiQYLckmrd07QaWrD21g5dgkW8XnrYoRmeN8PkLditprfBOjHoKeGutYoRnexzgloy6dLiZjy(4dIrvI9joAeb3pZHDQs5aY0tuLa3acI6SRfzobZhFyIYrcmPHoOsAo5dor9iNsr)iKWrcmPHoOYayCatuJbGXbtNIYSxP2wA(WTh1cmWAbr(AOZWXAFGxtTSHQ2xxV2lpYAHJAdKbBxlpQ9bNtZRLKjcRDaeyTxwRGhxTWRwASNbw7LhPQmJfhm9HsK5emF8bXOkrqKVg6mC0CyNQiZjy(4Qlben6SRVgutY2qvGmyBt0a9UIdb7Ow0WHnQghli6fQs5aY0tuD5rQjzz0IgoSXHjrMtW8XvCiyh1g5dgQajzOpEHQTaSmJfhm9HsK5emF8bXOkrqKVg6mC0CyNQiZjy(4koeSJAJ8bdvGmyBtu26JNOFk0Nq7MdDeKqcP84j6Nc9j0U5qhbnrYoRmeN8P(ALlfuyIskfzobZhxDjGOrND91GAs2gQcKKH(q(Ykxt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybruqiHukYCcMpU6sarJo76Rb1KSnufid22enqVR4qWoQfnCyJQXXcIOkxkOWenqVRcah1zxBKpyOaZh3ej7SYqCYNQuoGm9evSHMe6qsasnj7S2qCLzVsTs(dS2HbhevlSx7LhzTSdwlBulhyTPxRaSw2bR9j93xT0yTag12ZO2z62yu71WETxdwljltTG4KBBETKmrq3U2bqG1(G12WsXA5R2jYJR27jRLdb7yTIgoSXrTSdw71WxTxEK1(Wd)9vBlkW4QfyGGQYmwCW0hkrMtW8XheJQedgeY(PhgCqK5WovrMtW8XvxciA0zxFnOMKTHQajzOpKVuoGm9evXqtYYObXj3w3ZqF5rAsK5emFCfhc2rTr(GHkqsg6d5lLditprvm0KSmAqCYT19m0SHjkpEI(Pcah1zxBKpyyIsrMtW8XvbGJ6SRnYhmubsYqF8ckdkaouFqsKqcfzobZhxfaoQZU2iFWqfijd9H8LYbKPNOkgAswgnio526Eg6inOGqcB9Xt0pva4Oo7AJ8bdkmrd07koeSJArdh2OACSGi5lptGinqVRUeq0OZU(AqnjBdvG5JBIgO3vbGJ6SRnYhmuG5JBIgO3vCiyh1g5dgkW8XlZELAL8hyTddoiQ2h41ulBu7td61AKJbKEIQAFD9AV8iRfoQnqgSDT8O2hConVwsMiS2bqG1EzTcEC1cVAPXEgyTxEKQYmwCW0hkrMtW8XheJQedgeY(PhgCqK5WovrMtW8XvxciA0zxFnOMKTHQajzOpEbLbfahQpijAIgO3vCiyh1IgoSr14ybrVqvkhqMEIQlpsnjlJw0WHnomjYCcMpUIdb7O2iFWqfijd9XluIYGcGd1hKejgloy6Qlben6SRVgutY2qfkdkaouFqsKIYmwCW0hkrMtW8XheJQedgeY(PhgCqK5WovrMtW8XvCiyh1g5dgQajzOpEbLbfahQpijAIskB9Xt0pf6tODZHocsiHuE8e9tH(eA3COJGMizNvgIt(uFTYLckmrjLImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQydnjlJgeNCBDpd9LhPjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGikiKqkfzobZhxDjGOrND91GAs2gQcKKH(GQCnrd07koeSJArdh2OACSGiQYLckmrd07QaWrD21g5dgkW8XnrYoRmeN8PkLditprfBOjHoKeGutYoRnehfLzS4GPpuImNG5Jpigvjcmqn8qsZDMePosG5eVd626aGUT5WovkBDa4ypdBunGgnPRhxgKesinqVRgqJM01JldsfGbfMOb6Dfhc2rTOHdBunowq0luLYbKPNO6YJutYYOfnCyJdtImNG5JR4qWoQnYhmubsYqF8cvuguaCO(GKOjs2zLH4KVuoGm9evSHMe6qsasnj7S2qCMOb6Dva4Oo7AJ8bdfy(4LzVsTs(dS2lpYAFGxtTSrTWETW79O2h41a9AVgSwswMAbXj3wv7RRxRNN51cmWAFGxtTrAulSx71G1E8e9Rw4O2JjcDZRLDWAH37rTpWRb61EnyTKSm1cItUTQmJfhm9HsK5emF8bXOkXlben6SRVgutY2qZHDQu26aWXEg2OAanAsxpUmijKqAGExnGgnPRhxgKkadkmrd07koeSJArdh2OACSGOxOkLditpr1LhPMKLrlA4WghMezobZhxXHGDuBKpyOcKKH(4fQOmOa4q9bjrtKSZkdXjFPCaz6jQydnj0HKaKAs2zTH4mrd07QaWrD21g5dgkW8XlZyXbtFOezobZhFqmQs8sarJo76Rb1KSn0CyNknqVR4qWoQfnCyJQXXcIEHQuoGm9evxEKAswgTOHdBCy64j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF8cvuguaCO(GKOjPCaz6jQoijQb8do1SH8LYbKPNO6YJutYYObXj3w3ZqZgLzS4GPpuImNG5JpigvjEjGOrND91GAs2gAoStLgO3vCiyh1IgoSr14ybrVqvkhqMEIQlpsnjlJw0WHnomrzRpEI(Pcah1zxBKpyqiHImNG5JRcah1zxBKpyOcKKH(q(s5aY0tuD5rQjzz0G4KBR7zOJ0Gcts5aY0tuDqsud4hCQzd5lLditpr1LhPMKLrdItUTUNHMnkZELAL8hyTSrTWETxEK1ch1METcWAzhS2N0FF1sJ1cyuBpJANPBJrTxd71EnyTKSm1cItUT51sYebD7Ahabw71WxTpyTnSuSw0ta7MAjzNRLDWAVg(Q9AWaRfoQ1ZRwEgid2UwU2aWXAZETg5dg1cMpUQmJfhm9HsK5emF8bXOkroeSJAJ8bdZHDQImNG5JRUeq0OZU(AqnjBdvbsYqFiFPCaz6jQydnjlJgeNCBDpd9LhPjkBTiLIo7Nsk6xt7GqcfzobZhxrcJiJHo76lds0pvGKm0hYxkhqMEIk2qtYYObXj3w3ZqtMhfMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSm6XXcImrd07QaWrD21g5dgkW8XnrYoRmeN8PkLditprfBOjHoKeGutYoRnexz2RuRK)aRnsJAH9AV8iRfoQn9AfG1YoyTpP)(QLgRfWO2Eg1ot3gJAVg2R9AWAjzzQfeNCBZRLKjc621oacS2RbdSw4WFF1YZazW21Y1gaowly(41YoyTxdF1Yg1(K(7RwAuKKyTSugoz6jwliqaD7AdahvLzS4GPpuImNG5JpigvjgaoQZU2iFWWCyNknqVR4qWoQnYhmuG5JBIsrMtW8XvxciA0zxFnOMKTHQajzOpKVuoGm9evrAOjzz0G4KBR7zOV8ijKqrMtW8XvCiyh1g5dgQajzOpEHQuoGm9evxEKAswgnio526EgA2Gct0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybrMezobZhxXHGDuBKpyOcKKH(q(YkxtImNG5JRUeq0OZU(AqnjBdvbsYqFiFzLBzgloy6dLiZjy(4dIrvIJgy)GUT2iFWWCyNQuoGm9evjWnGGOo7ArMtW8XhLzVsTs(dSwJKS2lRD0IbquYdwl71IYCbxltxl0R9AWADuMRwrMtW8XR9b6G5J51c4tCmQLO2bK9AVg0Rn9z7AbbcOBxlhc2XAnYhmQfeaR9YABYNAjzNRTbWTJ21gmiK9R2HbhevlCuMXIdM(qjYCcMp(GyuLOrGd0fOo7AsOdAoSt94j6NkaCuNDTr(GHjAGExXHGDuBKpyOammrd07QaWrD21g5dgQajzOpEXwaQizzkZyXbtFOezobZhFqmQs0iWb6cuNDnj0bnh2PcI0a9U6sarJo76Rb1KSnubyycePb6D1LaIgD21xdQjzBOkqsg6JxyXbtxXHGDutchd4ehkuguaCO(GKOPwlsPOZ(PiQDazVmJfhm9HsK5emF8bXOkrJahOlqD21Kqh0CyNknqVRcah1zxBKpyOammrd07QaWrD21g5dgQajzOpEXwaQizzmjYCcMpUcLMc(GPRcKbBBsK5emFC1LaIgD21xdQjzBOkqsg6dtTwKsrN9tru7aYEzwzgloy6dvh68utdeovoeSJAs4yaN4WCyNknqVRetKdbpoOBRcKfN5Igg6uLTmJfhm9HQdDEQPbcNyuLihc2rn9Khxzgloy6dvh68utdeoXOkroeSJAAoc2glZkZELALmBqV2aWDOBxlcVgmQ9AWATSQnJAjGKzTt0gDqoG4W8AFWAFy)Q9YALmKM1sJ9mWAVgSwcKxltIT0Rw7d0bZhvTs(dSw4vlpQDKPxlpQ91KVATn8O2o0HJgeS2eiQ9bFlfRDyG(vBce1kA4WghLzS4GPpuD4Ob6260aDmOIstbFW0nh2Psza4ypdBuDiPrg8u)WHbHesza4ypdBunGgnPRhxgKMATuoGm9evgbAamNAuAsvwkOWeL0a9UkaCuNDTr(GHcmFCcj0iqPABbOswfhc2rnnhbBJuysK5emFCva4Oo7AJ8bdvGKm0hLzVsTVUETp4BPyTDOdhniyTjquRiZjy(41(aDW8zul7G1omq)QnbIAfnCyJdZR1iGzapOKhSwjdPzTPumQfLIr7Rb621IZbwMXIdM(q1HJgOBRtd0XGyuLiknf8bt3CyN6Xt0pva4Oo7AJ8bdtImNG5JRcah1zxBKpyOcKKH(WKiZjy(4koeSJAJ8bdvGKm0hMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHcmFCtgbkvBlavYQ4qWoQP5iyBSmJfhm9HQdhnq3wNgOJbXOkXomqn9KhN5Wo1aWXEg2OceoeqJj05OTwKKKSdAIgO3vGWHaAmHohT1IKKKDqDpYXPamkZyXbtFO6Wrd0T1Pb6yqmQsSh540EkLnh2Pgao2ZWgv2bCmBRHcOyIMizNvgIt(TqcQmJfhm9HQdhnq3wNgOJbXOkroeSJAs4yaN4WCyNAa4ypdBuXHGDu3Wbz6Tnrd07koeSJ6goitVTACSGOxOb6Dfhc2rDdhKP3wrYYOhhliYeLusd07koeSJAJ8bdfy(4MezobZhxXHGDuBKpyOcKbBtbHecI0a9U6sarJo76Rb1KSnubyqH5Igg6uLTmJfhm9HQdhnq3wNgOJbXOkXaWrD21g5dgMd7udah7zyJQb0OjD94YGSmJfhm9HQdhnq3wNgOJbXOkroeSJ6mOnh2PkYCcMpUkaCuNDTr(GHkqgSDzgloy6dvhoAGUTonqhdIrvICiyh10tECMd7ufzobZhxfaoQZU2iFWqfid22enqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGOYmwCW0hQoC0aDBDAGogeJQebr(AOZWrZHDQToaCSNHnQoK0idEQF4WGqcfPdcapLnSF6SRVgupHIMYmwCW0hQoC0aDBDAGogeJQedah1zxBKpyuM9k1(661(GVdSw(QLKLP2XXcIg1M9ABvRQLDWAFWAByPO)(QfyGG12YscuBB8mVwGbwlx74ybr1EzTgbkf9Rwsax0aD7Ab8jog1gaUdD7AVgSwjV5Gm921orB0b5ODzgloy6dvhoAGUTonqhdIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilot0a9Usmroe84GUTACSGiQ0a9Usmroe84GUTIKLrpowqKjrkfD2pLu0VM2HjrMtW8XvKWiYyOZU(YGe9tfid22uRLYbKPNOcjnYhmqqnnhbBJMezobZhxXHGDuBKpyOcKbBxM9k1kPmi55SDTpyTgmmQ1ipy61cmWAFGxtTT0RAET0axTWR2h4Cw7KhxTZ0TRf9eWUP2Eg1sNxtTxdw7RjF1AzhS2w6vR9b6G5ZOwaFIJrTbG7q3U2RbR1YQ2mQLasM1orB0b5aIJYmwCW0hQoC0aDBDAGogeJQenYdMU5Wo1whao2ZWgvhsAKbp1pCyyIYwhao2ZWgvdOrt66XLbjHesPuoGm9evgbAamNAuAsvwt0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybruqrzgloy6dvhoAGUTonqhdIrvIGiFn0z4O5WovAGExfaoQZU2iFWqbMpoHeAeOuTTaujRIdb7OMMJGTXYmwCW0hQoC0aDBDAGogeJQedgeY(PhgCqK5WovAGExfaoQZU2iFWqbMpoHeAeOuTTaujRIdb7OMMJGTXYmwCW0hQoC0aDBDAGogeJQejHrKXqND9Lbj6N5WovAGExfaoQZU2iFWqfijd9Xluk5iM8A5bGJ9mSr1aA0KUECzqsrz2RuRKzd61gaUdD7AVgSwjV5Gm921orB0b5OT51cmWABPxTwASNbwlbYRLv7L1ccqAulxBhyoBx74ybriyT0CeSnwMXIdM(q1HJgOBRtd0XGyuLihc2rTr(GH5WovPCaz6jQqsJ8bdeutZrW2OjAGExfaoQZU2iFWqbyyIss2zLH4EHs5rqeJszLBlxKsrN9tru7aYofuqiH0a9Usmroe84GUTACSGiQ0a9Usmroe84GUTIKLrpowqefLzS4GPpuD4Ob6260aDmigvjYHGDutZrW2O5WovPCaz6jQqsJ8bdeutZrW2OjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGit0a9UIdb7O2iFWqbyuMXIdM(q1HJgOBRtd0XGyuLiWa1Wdjn3zsK6ibMt8oOBRda62Md7uPb6Dva4Oo7AJ8bdfy(4esOrGs12cqLSkoeSJAAoc2gjKqJaLQTfGkzvbdcz)0ddoiIqcP0iqPABbOswfiYxdDgoAQ1bGJ9mSr1aA0KUECzqsrzgloy6dvhoAGUTonqhdIrvIxciA0zxFnOMKTHMd7uPb6Dva4Oo7AJ8bdfy(4esOrGs12cqLSkoeSJAAoc2gjKqJaLQTfGkzvbdcz)0ddoiIqcP0iqPABbOswfiYxdDgoAQ1bGJ9mSr1aA0KUECzqsrzgloy6dvhoAGUTonqhdIrvICiyh1g5dgMd7uncuQ2waQKvDjGOrND91GAs2gwM9k1k5pWAF1SLv7L1oAXaik5bRL9ArzUGRTLcb7yTsyYJRwqGa621EnyTeiVwMeBPxT2hOdMp1c4tCmQnaCh6212sHGDSwjdrtQQ911RTLcb7yTsgIMSw4O2JNOFiO51(G1ky)9vlWaR9vZwwTpWRb61EnyTeiVwMeBPxT2hOdMp1c4tCmQ9bRf6hgbGXv71G12sTSAfnS7408AhzTp475S2blfRfEQYmwCW0hQoC0aDBDAGogeJQencCGUa1zxtcDqZHDQT(4j6NIdb7OgfnPjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF8cvkzXbtxXHGDutp5XPqzqbWH6dsITCAGExze4aDbQZUMe6Gkswg94ybruuM9k1(661(QzlR2gE4VVAPr0RfyGG1cceq3U2RbRLa51YQ9b6G5J51(GVNZAbgyTWR2lRD0IbquYdwl71IYCbxBlfc2XALWKhxTqV2RbR91KVQeBPxT2hOdMpQYmwCW0hQoC0aDBDAGogeJQencCGUa1zxtcDqZHDQ0a9UIdb7O2iFWqbyyIgO3vbGJ6SRnYhmubsYqF8cvkzXbtxXHGDutp5XPqzqbWH6dsITCAGExze4aDbQZUMe6Gkswg94ybruuMXIdM(q1HJgOBRtd0XGyuLihc2rn9KhN5WovW8ubdcz)0ddoisfijd9H8jicjeePb6DvWGq2p9WGdI0sbMogmnCcV2QXXcIKVClZELALmXAFy)Q9YAjzIWAhabw7dwBdlfRf9eWUPws25A7zu71G1I(bdS2w6vR9b6G5J51IsrVwyV2Rbd89O2XbNZApijwBGKm0HUDTPx7RjFvvTVU79O20NTRLgVdJAVSwAGWR9YAL8Grwl7G1kzinRf2RnaCh621EnyTww1MrTeqYS2jAJoihqCOkZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMMJGTrZHDQImNG5JR4qWoQnYhmubYGTnrYoRme3lukzLlXOuw52YfPu0z)ue1oGStbfMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSm6XXcImrzRdah7zyJQb0OjD94YGKqcLYbKPNOYiqdG5uJstQYsHPwhao2ZWgvhsAKbp1pCyyQ1bGJ9mSrfhc2rDdhKP3Um7vQvcCeSnw7OjbMG165vlnwlWabRLVAVgSw0bRn712sVATWETsgstbFW0RfoQnqgSDT8OwWinmGUDTIgoSXrTpW5SwsMiSw4v7XeH1ot3gJAVSwAGWR9AIeWUP2ajzOdD7AjzNlZyXbtFO6Wrd0T1Pb6yqmQsKdb7OMMJGTrZHDQ0a9UIdb7O2iFWqbyyIgO3vCiyh1g5dgQajzOpEHQTa0KiZjy(4kuAk4dMUkqsg6JYSxPwjWrW2yTJMeycwlpF42JAPXAVgS2jpUAf84Qf61EnyTVM8vR9b6G5tT8OwcKxlR2h4CwBGJldS2RbRv0WHnoQDyG(vMXIdM(q1HJgOBRtd0XGyuLihc2rnnhbBJMd7uPb6Dva4Oo7AJ8bdfGHjAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOcKKH(4fQ2cqtToaCSNHnQ4qWoQB4Gm92LzS4GPpuD4Ob6260aDmigvjYHGDutchd4ehMd7ubrAGExDjGOrND91GAs2gQammD8e9tXHGDuJIM0eL0a9Uce5RHodhvG5JtiHS4Gsrn6ijehuLLctGinqVRUeq0OZU(AqnjBdvbsYqFiFwCW0vCiyh1KWXaoXHcLbfahQpijAUOHHovznh5y2wlAyORHDQ0a9Usmroe84GUTw0WUJtfy(4MOKgO3vCiyh1g5dgkadcjKYwF8e9tLsXWiFWabnrjnqVRcah1zxBKpyOamiKqrMtW8XvO0uWhmDvGmyBkOGIYSxP2xxV2h8DG1kf9RPDyETqsseeYhoBxlWaRTvTQ2Ng0RvWggiyTxwRNxTp84WAnIumQThjzTTSKaLzS4GPpuD4Ob6260aDmigvjYHGDutchd4ehMd7ufPu0z)usr)AAhMOb6DLyICi4XbDB14ybruPb6DLyICi4XbDBfjlJECSGOYSxPwRJJRwGb0TRTvTQ2wQLv7td612sVATn8OwAe9Abgiyzgloy6dvhoAGUTonqhdIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilotImNG5JR4qWoQnYhmubsYqFyIsAGExfaoQZU2iFWqbyqiH0a9UIdb7O2iFWqbyqH5Igg6uLTmJfhm9HQdhnq3wNgOJbXOkroeSJ6mOnh2Psd07koeSJArdh2OACSGOxOkLditpr1LhPMKLrlA4WghLzS4GPpuD4Ob6260aDmigvjYHGDutp5XzoStLgO3vbGJ6SRnYhmuagesij7SYqCYxwcQmJfhm9HQdhnq3wNgOJbXOkruAk4dMU5WovAGExfaoQZU2iFWqbMpUjAGExXHGDuBKpyOaZh3COFyeagNg2PsYoRmeN8P2ciiZH(HrayCAijjcc5dPkBzgloy6dvhoAGUTonqhdIrvICiyh10CeSnwMvM9kVsTs((aWWiJdbRvWUaNAwCW0F9PALmKMc(GPx7dCoRLgR15di45SDT0rse61c71ksheEW0h1YbwljEQYSx5vQLfhm9HQHdY0BtvWUaNAwCW0nh2PYIdMUcLMc(GPRenS74e62MizNvgIt(uBHeuz2Ru7RRx7mFQn9AjzNRLDWAfzobZhFulhyTIKe621cyyET2zTCdYG1YoyTO0SmJfhm9HQHdY0BtmQseLMc(GPBoStLKDwziUxOsCY1KuoGm9evjWnGGOo7ArMtW8XhMO84j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF8ISYLIYSxPwjtS2h2VAVS2XXcIQTHdY0BxBhyoBRQLanyTadS2SxRSsUAhhliAuBdgyTWrTxwllejGF12ZO2RbR9GcIQDI9R20R9AWAfnS74Sw2bR9AWAjHJbCI1c9A7tODZPkZyXbtFOA4Gm92eJQe5qWoQjHJbCIdZHDQukLditpr14ybr6goitVnHeEqs8fzLlfMOb6Dfhc2rDdhKP3wnowq0lYk5mx0WqNQSLzVsTsMnOxlWa621kzqA0oqEw7Rxa6SlqZRvWJRwU2o(ulkZfCTKWXaoXrTpnWjw7ddpOBxBpJAVgSwAGEVw(Q9AWAhhhxTzV2RbRTdTBUYmwCW0hQgoitVnXOkroeSJAs4yaN4WCyNk2IbGggiOcjnAhip1za6SlqthKeFH4KRPlTTNOsK5emF8HjrMtW8XviPr7a5PodqNDbQcKKH(q(Yk5AbMAnloy6kK0ODG8uNbOZUavGWbtprWYmwCW0hQgoitVnXOkrGbQHhsAUZKi1rcmN4Dq3wha0Tnh2Psd07koeSJAJ8bdfGHPJdB8uGWXXUaFHQSYTmJfhm9HQHdY0BtmQseyGA4HKM7mjsDKaZjEh0T1baDBZHDQs5aY0tuHKg5dgiOMMJGTrtImNG5JRUeq0OZU(AqnjBdvbsYqF8cvuguaCO(GKOjrMtW8XvCiyh1g5dgQajzOpEHkLOmOa4q9bjXwU8OW0XHnEkq44yxGYxw5wMXIdM(q1Wbz6TjgvjgmiK9tpm4GiZHDQs5aY0tuHKg5dgiOMMJGTrtImNG5JRUeq0OZU(AqnjBdvbsYqF8cvuguaCO(GKOjrMtW8XvCiyh1g5dgQajzOpEHkLOmOa4q9bjXwU8OWeLTgBXaqddeunsG5eVd626aGUnHeksheaEkoeSJAJibH2Tvb7ejFQeeHeEb0jcp1ibMt8oOBRda62krMtW8XvbsYqFiFzLvUuuMXIdM(q1Wbz6TjgvjEjGOrND91GAs2gAoStvkhqMEIQwuGXPbgiOEyWbrMezobZhxXHGDuBKpyOcKKH(4fQOmOa4q9bjrtu2ASfdanmqq1ibMt8oOBRda62esOiDqa4P4qWoQnIeeA3wfStK8Psqes4fqNi8uJeyoX7GUToaOBRezobZhxfijd9H8Lvw5srzgloy6dvdhKP3MyuLihc2rTr(GH5WovJaLQTfGkzvxciA0zxFnOMKTHLzS4GPpunCqMEBIrvIbGJ6SRnYhmmh2PkLditprfsAKpyGGAAoc2gnjYCcMpUkyqi7NEyWbrQajzOpEHkkdkaouFqs0KuoGm9evhKe1a(bNA2q(uLNCnrzRfPdcapfhc2rTrKGq72esyRLYbKPNOINpC7HE02fArMtW8XhesOiZjy(4Qlben6SRVgutY2qvGKm0hVqLsuguaCO(GKylxEuqrzgloy6dvdhKP3MyuLyWGq2p9WGdImh2PkLditprfsAKpyGGAAoc2gnzeOuTTaujRkaCuNDTr(Grzgloy6dvdhKP3MyuL4LaIgD21xdQjzBO5WovPCaz6jQArbgNgyGG6HbhezQ1s5aY0tu1KtqOBRV8ilZELAL8hyTYZbRLdb7yT0CeSnwl0RTLEvI9AE9E1AtF2UwyVwjmZeCcmUAzhSw(QDI84QvE12QwnQ1isHablZyXbtFOA4Gm92eJQe5qWoQP5iyB0CyNknqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowqKjAGExfaoQZU2iFWqbyyIgO3vCiyh1g5dgkadt0a9UIdb7OUHdY0BRghlis(uLvYzIgO3vCiyh1g5dgQajzOpEHkloy6koeSJAAoc2gvOmOa4q9bjrt0a9UIEMj4eyCkaJYSxPwj)bwR8CWAFn5Rwl0RTLE1AtF2UwyVwjmZeCcmUAzhSw5vBRA1OwJifLzS4GPpunCqMEBIrvIbGJ6SRnYhmmh2Psd07QaWrD21g5dgkW8Xnrd07k6zMGtGXPammrPuoGm9evhKe1a(bNA2q(eNCjKqrMtW8Xvbdcz)0ddoisfijd9H8LvEuyIsAGExXHGDu3Wbz6TvJJfejFQYsqesinqVRetKdbpoOBRghlis(uLLctu2Ar6GaWtXHGDuBeji0UnHe2APCaz6jQ45d3EOhTDHwK5emF8bfLzS4GPpunCqMEBIrvIbGJ6SRnYhmmh2Psd07koeSJAJ8bdfy(4MOukhqMEIQdsIAa)GtnBiFItUesOiZjy(4QGbHSF6HbhePcKKH(q(YkpkmrzRfPdcapfhc2rTrKGq72esyRLYbKPNOINpC7HE02fArMtW8XhuuMXIdM(q1Wbz6TjgvjgmiK9tpm4GiZHDQs5aY0tuHKg5dgiOMMJGTrtusd07koeSJArdh2OACSGi5tvEesOiZjy(4koeSJ6mOvbYGTPWeLT(4j6NkaCuNDTr(GbHekYCcMpUkaCuNDTr(GHkqsg6d5tquysK5emFCfhc2rTr(GHkqsg6dnkJbkoeu(ujo5AIYwlsheaEkoeSJAJibH2TjKWwlLditprfpF42d9OTl0ImNG5JpOOm7vQvYSb9Ada3HUDTgrccTBBETadS2lpYAPBxl8g4Sxl0RndqmQ9YA5j02RfE1(aVMAzJYmwCW0hQgoitVnXOkXlben6SRVgutY2qZHDQs5aY0tuDqsud4hCQzJxii5AskhqMEIQdsIAa)GtnBiFItUMOS1ylgaAyGGQrcmN4Dq3wha0TjKqr6GaWtXHGDuBeji0UTkyNi5tLGOOmJfhm9HQHdY0BtmQsKdb7OodAZHDQs5aY0tu1IcmonWab1ddoiYenqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGOYmwCW0hQgoitVnXOkroeSJAAoc2gnh2PcI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybrubrAGExfmiK9tpm4GiTuGPJbtdNWRTIKLrpowquzgloy6dvdhKP3MyuLihc2rn9KhN5WovPCaz6jQArbgNgyGG6HbheriHucI0a9Ukyqi7NEyWbrAPathdMgoHxBfGHjqKgO3vbdcz)0ddoislfy6yW0Wj8ARghli6fqKgO3vbdcz)0ddoislfy6yW0Wj8ARizz0JJferrz2RuRK)aRLe6WALahbBJ1sJ3dIETbdcz)QDyWbrJAH9AbCqmQvceCTpWRjbUAbXj3g621(Ayqi7xTwgCquTqqKNZ2LzS4GPpunCqMEBIrvICiyh10CeSnAoStLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UIEMj4eyCkadtImNG5JRcgeY(PhgCqKkqsg6JxOkRCnrd07koeSJ6goitVTACSGi5tvwjxz2RuRK)aRnd6AtVwbyTa(ehJAzJAHJAfjj0TRfWO2rMEzgloy6dvdhKP3MyuLihc2rDg0Md7uPb6Dfhc2rTOHdBunowq0leNjPCaz6jQoijQb8do1SH8LvUMOuK5emFC1LaIgD21xdQjzBOkqsg6d5tqesyRfPdcapfhc2rTrKGq72uuMXIdM(q1Wbz6TjgvjYHGDutchd4ehMd7uPb6DLyICi4XbDBvGS4mrd07koeSJAJ8bdfGH5Igg6uLTm7vQ911R9bR1gVAnYhmQf6DGbm9AbbcOBx7eyC1(GVNZAByPyTONa2n12WJdR9YATXR2S3RLRDCr621sZrW2yTGab0TR9AWAJ0qISrTpqhmFkZyXbtFOA4Gm92eJQe5qWoQP5iyB0CyNknqVRcah1zxBKpyOammrd07QaWrD21g5dgQajzOpEHkloy6koeSJAs4yaN4qHYGcGd1hKenrd07koeSJAJ8bdfGHjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGit0a9UIdb7OUHdY0BRghliYenqVRmYhm0qVdmGPRammrd07k6zMGtGXPamkZELAFD9AFWATXRwJ8bJAHEhyatVwqGa621obgxTp475S2gwkwl6jGDtTn84WAVSwB8Qn79A5AhxKUDT0CeSnwliqaD7AVgS2inKiBu7d0bZhZRDK1(GVNZAtF2UwGbwl6jGDtT0tECJAHo8G8C2U2lR1gVAVS2Ece1kA4WghLzS4GPpunCqMEBIrvICiyh10tECMd7uPb6DLrGd0fOo7AsOdQammrjnqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGicjS1usd07kJ8bdn07ady6kadt0a9UIEMj4eyCkadkOOm7vQLanyT044QfyG1M9AnsYAHJAVSwGbwl8Q9YABXaqbrZ21sdaNG1kA4Wgh1cceq3Uw2OwUFyu71GTR1gVAbbinqWAPBx71G12Wbz6TRLMJGTXYmwCW0hQgoitVnXOkrJahOlqD21Kqh0CyNknqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGit0a9UIdb7O2iFWqbyuM9k1kzI1(W(v7L1oowquTnCqME7A7aZzBvTeObRfyG1M9ALvYv74ybrJABWaRfoQ9YAzHib8R2Eg1EnyThuquTtSF1METxdwROHDhN1YoyTxdwljCmGtSwOxBFcTBovzgloy6dvdhKP3MyuLihc2rnjCmGtCyoStLgO3vCiyh1nCqMEB14ybrViRKZCrddDQYAo0pmcaJJQSMd9dJaW402ZKMNuLTmJfhm9HQHdY0BtmQsKdb7OMMJGTrZHDQ0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybrMKYbKPNOcjnYhmqqnnhbBJLzS4GPpunCqMEBIrvIO0uWhmDZHDQKSZkdX9ISeuz2Ru7RNpBxlWaRLEYJR2lRLgaobRv0WHnoQf2R9bRLNbYGTRTHLI1ossS2EKK1MbDzgloy6dvdhKP3MyuLihc2rn9KhN5WovAGExXHGDulA4WgvJJfezIgO3vCiyh1IgoSr14ybrVqd07koeSJArdh2OIKLrpowquz2Ru7RVGZzTpWRPwMSwaFIJrTSrTWrTIKe621cyul7G1(GVdS2z(uB61sYoxMXIdM(q1Wbz6TjgvjYHGDutchd4ehMd7uBnLs5aY0tuDqsud4hCQzJxOkRCnrYoRme3leNCPWCrddDQYAo0pmcaJJQSMd9dJaW402ZKMNuLTm7vQ9vJSdN4O2h41u7mFQLKhhgTnV2gODtTn84qZRnJAPZRPwsUDTEE12WsXArpbSBQLKDU2lRDayyKXvBt(ulj7CTq)qFaLI1gmiK9R2HbhevRG9APrZRDK1(GVNZAbgyTDyG1sp5Xvl7G12JCC058Q9Pb9AN5tTPxlj7Czgloy6dvdhKP3MyuLyhgOMEYJRmJfhm9HQHdY0BtmQsSh54OZ5vMvMXIdM(qLgOJb1omqn9KhN5Wo1aWXEg2OceoeqJj05OTwKKKSdAIgO3vGWHaAmHohT1IKKKDqDpYXPamkZyXbtFOsd0XGyuLypYXP9ukBoStnaCSNHnQSd4y2wdfqXenrYoRmeN8BHeuzgloy6dvAGogeJQebgOgEiP5otIuhjWCI3bDBDaq3UmJfhm9HknqhdIrvIGiFn0z4yzgloy6dvAGogeJQedgeY(PhgCqK5Wovs2zLH4KVKvULzS4GPpuPb6yqmQsKegrgdD21xgKOFLzS4GPpuPb6yqmQsC0a7h0T1g5dgMd7uPb6Dfhc2rTr(GHcmFCtImNG5JR4qWoQnYhmubsYqFuMXIdM(qLgOJbXOkroeSJ6mOnh2PkYCcMpUIdb7O2iFWqfid22enqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGOYmwCW0hQ0aDmigvjYHGDutp5XzoStvKsrN9tjf9RPDysK5emFCfjmImg6SRVmir)ubsYqFi)wGKTmJfhm9HknqhdIrvIxciA0zxFnOMKTHLzS4GPpuPb6yqmQsKdb7O2iFWOmJfhm9HknqhdIrvIbGJ6SRnYhmmh2Psd07koeSJAJ8bdfy(4LzVsTs(dS2xnBz1EzTJwmaIsEWAzVwuMl4ABPqWowReM84QfeiGUDTxdwlbYRLjXw6vR9b6G5tTa(ehJAda3HUDTTuiyhRvYq0KQAFD9ABPqWowRKHOjRfoQ94j6hcAETpyTc2FF1cmWAF1SLv7d8AGETxdwlbYRLjXw6vR9b6G5tTa(ehJAFWAH(HrayC1EnyTTulRwrd7oonV2rw7d(EoRDWsXAHNQmJfhm9HknqhdIrvIgboqxG6SRjHoO5Wo1wF8e9tXHGDuJIM0eisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpEHkLS4GPR4qWoQPN84uOmOa4q9bjXwonqVRmcCGUa1zxtcDqfjlJECSGikkZELAFD9AF1SLvBdp83xT0i61cmqWAbbcOBx71G1sG8Az1(aDW8X8AFW3ZzTadSw4v7L1oAXaik5bRL9ArzUGRTLcb7yTsyYJRwOx71G1(AYxvIT0Rw7d0bZhvzgloy6dvAGogeJQencCGUa1zxtcDqZHDQ0a9UIdb7O2iFWqbyyIgO3vbGJ6SRnYhmubsYqF8cvkzXbtxXHGDutp5XPqzqbWH6dsITCAGExze4aDbQZUMe6Gkswg94ybruuMXIdM(qLgOJbXOkroeSJA6jpoZHDQG5PcgeY(PhgCqKkqsg6d5tqesiisd07QGbHSF6HbhePLcmDmyA4eETvJJfejF5wM9k12sZhU9OwjWrW2yT8v71G1IoyTzV2w6vR9Pb9Ada3HUDTxdwBlfc2XAL8MdY0Bx7eTrhKJ2LzS4GPpuPb6yqmQsKdb7OMMJGTrZHDQ0a9UIdb7O2iFWqbyyIgO3vCiyh1g5dgQajzOpEXwaAkaCSNHnQ4qWoQB4Gm92LzVsTT08HBpQvcCeSnwlF1EnyTOdwB2R9AWAFn5Rw7d0bZNAFAqV2aWDOBx71G12sHGDSwjV5Gm921orB0b5ODzgloy6dvAGogeJQe5qWoQP5iyB0CyNknqVRcah1zxBKpyOammrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdvGKm0hVq1waAkaCSNHnQ4qWoQB4Gm92LzS4GPpuPb6yqmQsKdb7OMeogWjomh2PcI0a9U6sarJo76Rb1KSnubyy64j6NIdb7OgfnPjkPb6DfiYxdDgoQaZhNqczXbLIA0rsioOklfMarAGExDjGOrND91GAs2gQcKKH(q(S4GPR4qWoQjHJbCIdfkdkaouFqs0CrddDQYAoYXSTw0Wqxd7uPb6DLyICi4XbDBTOHDhNkW8XnrjnqVR4qWoQnYhmuagesiLT(4j6NkLIHr(GbcAIsAGExfaoQZU2iFWqbyqiHImNG5JRqPPGpy6QazW2uqbfLzS4GPpuPb6yqmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QXXcIOsd07kXe5qWJd62kswg94ybrMePu0z)usr)AAhLzS4GPpuPb6yqmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QazXzsK5emFCfhc2rTr(GHkqsg6dtusd07QaWrD21g5dgkadcjKgO3vCiyh1g5dgkadkmx0WqNQSLzS4GPpuPb6yqmQsKdb7OodAZHDQ0a9UIdb7Ow0WHnQghli6fQs5aY0tuD5rQjzz0IgoSXrzgloy6dvAGogeJQe5qWoQPN84mh2Psd07QaWrD21g5dgkadcjKKDwzio5llbvMXIdM(qLgOJbXOkruAk4dMU5WovAGExfaoQZU2iFWqbMpUjAGExXHGDuBKpyOaZh3COFyeagNg2PsYoRmeN8P2ciiZH(HrayCAijjcc5dPkBzgloy6dvAGogeJQe5qWoQP5iyBSmRm7vELAzXbtFOI84dMovb7cCQzXbt3CyNkloy6kuAk4dMUs0WUJtOBBIKDwzio5tTfsqMOS1bGJ9mSr1aA0KUECzqsiH0a9UAanAsxpUmivJJferLgO3vdOrt66XLbPIKLrpowqefLzVsTs(dSwuAwlSx7d(oWAN5tTPxlj7CTSdwRiZjy(4JA5aRLPtGR2lRLgRfWOmJfhm9HkYJpy6eJQerPPGpy6Md7uBDa4ypdBunGgnPRhxgKMizNvgI7fQs5aY0tuHstTH4mrPiZjy(4Qlben6SRVgutY2qvGKm0hVqLfhmDfknf8btxHYGcGd1hKejKqrMtW8XvCiyh1g5dgQajzOpEHkloy6kuAk4dMUcLbfahQpijsiHuE8e9tfaoQZU2iFWWKiZjy(4QaWrD21g5dgQajzOpEHkloy6kuAk4dMUcLbfahQpijsbfMOb6Dva4Oo7AJ8bdfy(4MOb6Dfhc2rTr(GHcmFCtGinqVRUeq0OZU(AqnjBdvG5JBQ1gbkvBlavYQUeq0OZU(AqnjBdlZyXbtFOI84dMoXOkruAk4dMU5Wo1aWXEg2OAanAsxpUmin1ArkfD2pLu0VM2HjrMtW8XvCiyh1g5dgQajzOpEHkloy6kuAk4dMUcLbfahQpijwMXIdM(qf5XhmDIrvIO0uWhmDZHDQbGJ9mSr1aA0KUECzqAsKsrN9tjf9RPDysK5emFCfjmImg6SRVmir)ubsYqF8cvwCW0vO0uWhmDfkdkaouFqs0KiZjy(4Qlben6SRVgutY2qvGKm0hVqLsPCaz6jQiZtBeOarq9LhPMUnXyXbtxHstbFW0vOmOa4q9bjrIrCuysK5emFCfhc2rTr(GHkqsg6JxOsPuoGm9evK5PncuGiO(YJut3MyS4GPRqPPGpy6kuguaCO(GKiXiokkZELALahbBJ1c71cV3JApijw7L1cmWAV8iRLDWAFWAByPyTxM1sYE7AfnCyJJYmwCW0hQip(GPtmQsKdb7OMMJGTrZHDQImNG5JRUeq0OZU(AqnjBdvbYGTnrjnqVR4qWoQfnCyJQXXcIKVuoGm9evxEKAswgTOHdBCysK5emFCfhc2rTr(GHkqsg6JxOIYGcGd1hKenrYoRmeN8LYbKPNOIn0KqhscqQjzN1gIZenqVRcah1zxBKpyOaZhNIYmwCW0hQip(GPtmQsKdb7OMMJGTrZHDQImNG5JRUeq0OZU(AqnjBdvbYGTnrjnqVR4qWoQfnCyJQXXcIKVuoGm9evxEKAswgTOHdBCy64j6NkaCuNDTr(GHjrMtW8XvbGJ6SRnYhmubsYqF8cvuguaCO(GKOjPCaz6jQoijQb8do1SH8LYbKPNO6YJutYYObXj3w3ZqZguuMXIdM(qf5XhmDIrvICiyh10CeSnAoStvK5emFC1LaIgD21xdQjzBOkqgSTjkPb6Dfhc2rTOHdBunowqK8LYbKPNO6YJutYYOfnCyJdtu26JNOFQaWrD21g5dgesOiZjy(4QaWrD21g5dgQajzOpKVuoGm9evxEKAswgnio526Eg6inOWKuoGm9evhKe1a(bNA2q(s5aY0tuD5rQjzz0G4KBR7zOzdkkZyXbtFOI84dMoXOkroeSJAAoc2gnh2PcI0a9Ukyqi7NEyWbrAPathdMgoHxB14ybrubrAGExfmiK9tpm4GiTuGPJbtdNWRTIKLrpowqKjkPb6Dfhc2rTr(GHcmFCcjKgO3vCiyh1g5dgQajzOpEHQTaKctusd07QaWrD21g5dgkW8XjKqAGExfaoQZU2iFWqfijd9XluTfGuuMXIdM(qf5XhmDIrvICiyh10tECMd7uLYbKPNOQffyCAGbcQhgCqeHesjisd07QGbHSF6HbhePLcmDmyA4eETvagMarAGExfmiK9tpm4GiTuGPJbtdNWRTACSGOxarAGExfmiK9tpm4GiTuGPJbtdNWRTIKLrpowqefLzS4GPpurE8btNyuLihc2rn9KhN5WovAGExze4aDbQZUMe6GkadtGinqVRUeq0OZU(AqnjBdvagMarAGExDjGOrND91GAs2gQcKKH(4fQS4GPR4qWoQPN84uOmOa4q9bjXYmwCW0hQip(GPtmQsKdb7OMeogWjomh2PcI0a9U6sarJo76Rb1KSnubyy64j6NIdb7OgfnPjkPb6DfiYxdDgoQaZhNqczXbLIA0rsioOklfMOeePb6D1LaIgD21xdQjzBOkqsg6d5ZIdMUIdb7OMeogWjouOmOa4q9bjrcjuK5emFCLrGd0fOo7AsOdQcKKH(GqcfPu0z)ue1oGStH5Igg6uL1CKJzBTOHHUg2Psd07kXe5qWJd62Ard7oovG5JBIsAGExXHGDuBKpyOamiKqkB9Xt0pvkfdJ8bde0eL0a9UkaCuNDTr(GHcWGqcfzobZhxHstbFW0vbYGTPGckkZELABv6dasS2RbRfLXGDqeSwJ8q)G8SwAGEVwEWg1EzTEE1oZbwRrEOFqEwRrKIrzgloy6dvKhFW0jgvjYHGDutchd4ehMd7uPb6DLyICi4XbDBvGS4mrd07kugd2brqTrEOFqEQamkZyXbtFOI84dMoXOkroeSJAs4yaN4WCyNknqVRetKdbpoOBRcKfNjkPb6Dfhc2rTr(GHcWGqcPb6Dva4Oo7AJ8bdfGbHecI0a9U6sarJo76Rb1KSnufijd9H8zXbtxXHGDutchd4ehkuguaCO(GKifMlAyOtv2YmwCW0hQip(GPtmQsKdb7OMeogWjomh2Psd07kXe5qWJd62QazXzIgO3vIjYHGhh0TvJJferLgO3vIjYHGhh0TvKSm6XXcImx0WqNQSLzVsTT08HBpQ9I21EzT0StuTTQv12ZOwrMtW8XR9b6G5ZOwAGRwqasJAVgKSwyV2RbB)oWAz6e4Q9YArzmGbwMXIdM(qf5XhmDIrvICiyh1KWXaoXH5WovAGExjMihcECq3wfilot0a9Usmroe84GUTkqsg6JxOsjL0a9Usmroe84GUTACSGOwoloy6koeSJAs4yaN4qHYGcGd1hKePGy2cqfjldfMlAyOtv2YmwCW0hQip(GPtmQs0XRbd9HKg44mh2PszG9ahnm9ejKWwFqbrq3Mct0a9UIdb7Ow0WHnQghliIknqVR4qWoQfnCyJkswg94ybrMOb6Dfhc2rTr(GHcmFCtGinqVRUeq0OZU(AqnjBdvG5JxMXIdM(qf5XhmDIrvICiyh1zqBoStLgO3vCiyh1IgoSr14ybrVqvkhqMEIQlpsnjlJw0WHnokZyXbtFOI84dMoXOkXbGbgEkLnh2PkLditprvcCdiiQZUwK5emF8Hjs2zLH4EHAlKGkZyXbtFOI84dMoXOkroeSJA6jpoZHDQ0a9UkaMOo76RjqCOammrd07koeSJArdh2OACSGi5tCLzVsTsEbqAuROHdBCulSx7dwBNNZAPXz(u71G1ksFGHuSws25AVMahn5eSw2bRfLMc(GPxlCu74GZzTPxRiZjy(4LzS4GPpurE8btNyuLihc2rnnhbBJMd7uBDa4ypdBunGgnPRhxgKMKYbKPNOkbUbee1zxlYCcMp(WenqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowqKPJNOFkoeSJ6mOnjYCcMpUIdb7OodAvGKm0hVq1waAIKDwziUxO2cLRjrMtW8XvO0uWhmDvGKm0hLzS4GPpurE8btNyuLihc2rnnhbBJMd7udah7zyJQb0OjD94YG0KuoGm9evjWnGGOo7ArMtW8XhMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSm6XXcImD8e9tXHGDuNbTjrMtW8XvCiyh1zqRcKKH(4fQ2cqtKSZkdX9c1wOCnjYCcMpUcLMc(GPRcKKH(4fItULzVsTsEbqAuROHdBCulSxBg01ch1gid2UmJfhm9HkYJpy6eJQe5qWoQP5iyB0CyNQuoGm9evjWnGGOo7ArMtW8XhMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSm6XXcImD8e9tXHGDuNbTjrMtW8XvCiyh1zqRcKKH(4fQ2cqtKSZkdX9c1wOCnjYCcMpUcLMc(GPRcKKH(WeLToaCSNHnQgqJM01JldscjKgO3vdOrt66XLbPkqsg6JxOkBlGIYSxP2wkeSJ1kboc2gRD0KatWATrhdEoBxlnw71G1o5XvRGhxTzV2RbRTLE1AFGoy(uMXIdM(qf5XhmDIrvICiyh10CeSnAoStLgO3vCiyh1g5dgkadt0a9UIdb7O2iFWqfijd9XluTfGMOb6Dfhc2rTOHdBunowqevAGExXHGDulA4WgvKSm6XXcImrPiZjy(4kuAk4dMUkqsg6dcjmaCSNHnQ4qWoQB4Gm92uuM9k12sHGDSwjWrW2yTJMeycwRn6yWZz7APXAVgS2jpUAf84Qn71EnyTVM8vR9b6G5tzgloy6dvKhFW0jgvjYHGDutZrW2O5WovAGExfaoQZU2iFWqbyyIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgQajzOpEHQTa0enqVR4qWoQfnCyJQXXcIOsd07koeSJArdh2OIKLrpowqKjkfzobZhxHstbFW0vbsYqFqiHbGJ9mSrfhc2rDdhKP3MIYSxP2wkeSJ1kboc2gRD0KatWAPXAVgS2jpUAf84Qn71EnyTeiVwwTpqhmFQf2RfE1ch165vlWabR9bEn1(AYxT2mQTLE1YmwCW0hQip(GPtmQsKdb7OMMJGTrZHDQ0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF8cvBbOjAGExXHGDulA4WgvJJferLgO3vCiyh1IgoSrfjlJECSGOYSxPwjZg0R9AWApoSXRw4OwOxlkdkaoS2GDBSw2bR9AWaRfoQLmdS2RH9AthRfDKST51cmWAP5iyBSwEu7itVwEuB7eO2gwkwl6jGDtTIgoSXrTxwBd8QLNZArhjH4OwyV2RbRTLcb7yTsijP5aKe9R2jAJoihTRfoQfBXaqddeSmJfhm9HkYJpy6eJQe5qWoQP5iyB0CyNQuoGm9eviPr(GbcQP5iyB0enqVR4qWoQfnCyJQXXcIKpvkzXbLIA0rsioArKLctS4Gsrn6ijehYxwt0a9Uce5RHodhvG5JxMXIdM(qf5XhmDIrvICiyh1OmgZCat3CyNQuoGm9eviPr(GbcQP5iyB0enqVR4qWoQfnCyJQXXcIEHgO3vCiyh1IgoSrfjlJECSGitS4Gsrn6ijehYxwt0a9Uce5RHodhvG5JxMXIdM(qf5XhmDIrvICiyh10tECLzS4GPpurE8btNyuLiknf8bt3CyNQuoGm9evjWnGGOo7ArMtW8XhLzS4GPpurE8btNyuLihc2rnnhbBJ)7F)pa]] )

    
end