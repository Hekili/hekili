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


    spec:RegisterPack( "Arcane", 20210824, [[def4vhqiPK8ivjLlHKQQYMOiFsvQrHeofc1QKseVcjYSOO6wsje7IKFHKYWiQYXikTmIkEgcKPHKkDnKOSnKuLVPkjmoPe4CsjO1HevVdjvvvMNQe3JiTpIQ6GsjQfIK4Hsj1evLujUisQWgvLuj5JQsQuJejvv5KQsIwjfLxQkPsQzIa1nLsK2jss)uvsfdvvsAPQsQ6PuYuraxfjvLTIKQQQ(ksQOXsuP9QQ(lPgSshg1IrQhtyYaDzOnlvFMsnAP40GwTucPxJqMTc3gr7MQFlA4u44sjulx45kA6QCDaBNi(UQy8efNxk16rsvL5JG2VK)Y(jW3cKp8tv5ip5iR8AbYH6QKTfsDBbYkNV112a)wgSGi2g)wotIFRwoeSJFldU9izWpb(wZeie43Q5oJjLtnQzdVgaALijP2escm4dMUi4(rTjKuqTVfnaCCVs)t)Ta5d)uvoYtoYkVwGCOUkzBHu3xbLrD)wtdu8Pk1toFRgiii6F6VfiofFRwkBJ12YHGDSmRLbSbMxTYHGmVw5ip5iBzwzwRBy3gNuEzwlsTuFtS2RTbuWJATGKTU2g2bhq3U2SxROHDhh1c9dJaW4GPxl0NhYG1M9AFlyxGdnloy6VvLzTi126g2TXA5qWoQHEh6WRDTxwlhc2rDdhKP3UwkGxTokbJAFq)QDaLG1YZA5qWoQB4Gm92eRkZArQ91L0FF1sDijf8H1c9AB5xhQJABrbMxT0OGbMyTTtG3bwBcC1M9Ad2TXAzhSwpVAbMq3U2woeSJ1sDiJXiNW0vFRbCEZpb(wPb6y8jWNQY(jW3cDMEGGFQ8Teb8WaYFRaWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQLgO3vGWPaAmGohT1IKKKDqDpY5Pam(wS4GP)T6Wa10dEE)7tv58jW3cDMEGGFQ8Teb8WaYFRaWXEg2OYoGZrBnuafduHotpqWAnvlj7SYqC1k)ABHu23Ifhm9VvpY5P9uc)VpvjOpb(wOZ0de8tLVLZK43AMaJbEh0T1baD7Vfloy6FRzcmg4Dq3wha0T)3NQu3pb(wS4GP)Tar(AOZWXVf6m9ab)u5FFQszFc8TqNPhi4NkFlrapmG83IKDwziUALFTux59TyXbt)BfmiK9tpn4GO)9Pk17tGVfloy6Flsyezm1zxFzqI(9TqNPhi4Nk)7t1xXNaFl0z6bc(PY3seWddi)TOb6Dfhc2rTr(GHcmF8AnvRiZby(4koeSJAJ8bdvGKm0NFlwCW0)wZgy)GUT2iFW4FFQ2c(e4BHotpqWpv(wIaEya5VLiZby(4koeSJAJ8bdvGmy7AnvlnqVR4qWoQfnCyJQ5XcIQ9LAPb6Dfhc2rTOHdBurYYONhli6BXIdM(3Idb7Ood6)9PAl8tGVf6m9ab)u5Bjc4HbK)wIuc6SFkjOFnTJAnvRiZby(4ksyezm1zxFzqI(PcKKH(Sw5xBlG6(TyXbt)BXHGDutp459VpvLvEFc8TyXbt)BDjGOrND91GAs2g(TqNPhi4Nk)7tvzL9tGVfloy6FloeSJAJ8bJVf6m9ab)u5FFQkRC(e4BHotpqWpv(wIaEya5VfnqVR4qWoQnYhmuG5J)TyXbt)BfaoQZU2iFW4FFQklb9jW3cDMEGGFQ8TyXbt)Bze4eDbQZUMe6GFlqCkcOXbt)Br9nXAF1SLw7L1oBXais9dRL9ArzUGRTLdb7yTuzWZRwqGa621EnyTeiVwk1A5xT2hOdMp1c4dCoRnaCh6212YHGDSwQdrtQQ9v2RTLdb7yTuhIMSw4S2JhOFiO51(G1ky)9vlWeR9vZwATpWRb61EnyTeiVwk1A5xT2hOdMp1c4dCoR9bRf6hgbGXv71G12YT0AfnS74W8ANzTp47XO2jlbRfEQVLiGhgq(B1QApEG(P4qWoQrrtQqNPhiyTMQfePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9zTViTwkQLfhmDfhc2rn9GNNcLbfahQpijwBlPwAGExze4eDbQZUMe6Gkswg98ybr1s8)(uvwQ7NaFl0z6bc(PY3Ifhm9VLrGt0fOo7AsOd(TaXPiGghm9V1RSx7RMT0AB4P)(QLgrVwGjcwliqaD7AVgSwcKxlT2hOdMpMx7d(EmQfyI1cVAVS2zlgarQFyTSxlkZfCTTCiyhRLkdEE1c9AVgS2xF(QuRLF1AFGoy(O(wIaEya5VfnqVR4qWoQnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTViTwkQLfhmDfhc2rn9GNNcLbfahQpijwBlPwAGExze4eDbQZUMe6Gkswg98ybr1s8)(uvwk7tGVf6m9ab)u5Bjc4HbK)wG5PcgeY(PNgCqKkqsg6ZALFTuwTesyTGinqVRcgeY(PNgCqKwcWWXGPHd41wnpwquTYVw59TyXbt)BXHGDutp459VpvLL69jW3cDMEGGFQ8TyXbt)BXHGDutZrW243ceNIaACW0)wT84HBpRLkCeSnwlF1EnyTOdwB2RTLF1AFAqV2aWDOBx71G12YHGDSwQ)4Gm921oqB0b5O93seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07koeSJAJ8bdvGKm0N1(sT2cWAnvBa4ypdBuXHGDu3Wbz6TvOZ0de8FFQk7R4tGVf6m9ab)u5BXIdM(3Idb7OMMJGTXVfiofb04GP)TA5Xd3Ewlv4iyBSw(Q9AWArhS2Sx71G1(6ZxT2hOdMp1(0GETbG7q3U2RbRTLdb7yTu)Xbz6TRDG2OdYr7VLiGhgq(Brd07QaWrD21g5dgkaJAnvlnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdvGKm0N1(I0ATfG1AQ2aWXEg2OIdb7OUHdY0BRqNPhi4)(uv2wWNaFl0z6bc(PY3s0Wq)Bj73c5y0wlAyORH9VfnqVRedKdbppOBRfnS74qbMpUjkOb6Dfhc2rTr(GHcWGqcPOvhpq)uPemmYhmqqtuqd07QaWrD21g5dgkadcjuK5amFCfkjf8btxfid2MyIj(Bjc4HbK)wGinqVRUeq0OZU(AqnjBdvag1AQ2JhOFkoeSJAu0Kk0z6bcwRPAPOwAGExbI81qNHJkW8XRLqcRLfhucQrhjH4SwP1kBTexRPAbrAGExDjGOrND91GAs2gQcKKH(Sw5xlloy6koeSJAs4Cch4uHYGcGd1hKe)wS4GP)T4qWoQjHZjCGZ)9PQSTWpb(wOZ0de8tLVLiGhgq(Brd07kXa5qWZd62Q5XcIQvAT0a9Usmqoe88GUTIKLrppwquTMQvKsqN9tjb9RPD8TyXbt)BXHGDutcNt4aN)7tv5iVpb(wOZ0de8tLVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQwrMdW8XvCiyh1g5dgQajzOpR1uTuulnqVRcah1zxBKpyOamQLqcRLgO3vCiyh1g5dgkaJAj(FFQkhz)e4BHotpqWpv(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQ9fP1kHditpq1LhPMKLrlA4WgNFlwCW0)wCiyh1zq)VpvLJC(e4BHotpqWpv(wIaEya5VfnqVRcah1zxBKpyOamQLqcRLKDwziUALFTYszFlwCW0)wCiyh10dEE)7tv5qqFc8TqNPhi4NkFlwCW0)wOKuWhm9Vf0pmcaJtd7Fls2zLH4KV0waL9TG(HrayCAijjcc5d)wY(Teb8WaYFlAGExfaoQZU2iFWqbMpETMQLgO3vCiyh1g5dgkW8X)3NQYH6(jW3Ifhm9Vfhc2rnnhbBJFl0z6bc(PY)(33QdNnq3wNgOJXNaFQk7NaFl0z6bc(PY3Ifhm9Vfkjf8bt)BbItranoy6FlQZg0RnaCh621IWRbJAVgSwlRAZOwcqDw7aTrhKdionV2hS2h2VAVSwQdjzT0ypdS2RbRLa51sPwl)Q1(aDW8rvl13eRfE1YZANz61YZAF95RwBdpRTdD4SbbRnbIAFW3sWANgOF1MarTIgoSX53seWddi)TOO2aWXEg2O6qsJm4H(Hddf6m9abRLqcRLIAdah7zyJQj0OjD98YGuHotpqWAnvBRQvchqMEGkJanagdnkjRvATYwlX1sCTMQLIAPb6Dva4Oo7AJ8bdfy(41siH1AeOeTTaujRIdb7OMMJGTXAjUwt1kYCaMpUkaCuNDTr(GHkqsg6Z)9PQC(e4BHotpqWpv(wS4GP)TqjPGpy6FlqCkcOXbt)B9k71(GVLG12HoC2GG1MarTImhG5Jx7d0bZNzTSdw70a9R2eiQv0WHnonVwJaMb8Gu)WAPoKK1MsWOwucgTVgOBxloM43seWddi)ToEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1AQwrMdW8XvCiyh1g5dgQajzOpR1uT0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmuG5JxRPAncuI2waQKvXHGDutZrW24)(uLG(e4BHotpqWpv(wIaEya5Vva4ypdBubcNcOXa6C0wlsss2bvOZ0deSwt1sd07kq4uangqNJ2ArssYoOUh58uagFlwCW0)wDyGA6bpV)9Pk19tGVf6m9ab)u5Bjc4HbK)wbGJ9mSrLDaNJ2AOakgOcDMEGG1AQws2zLH4Qv(12cPSVfloy6FREKZt7Pe(FFQszFc8TqNPhi4NkFlwCW0)wCiyh1KW5eoW53s0Wq)Bj73seWddi)Tcah7zyJkoeSJ6goitVTcDMEGG1AQwAGExXHGDu3Wbz6TvZJfev7l1sd07koeSJ6goitVTIKLrppwquTMQLIAPOwAGExXHGDuBKpyOaZhVwt1kYCaMpUIdb7O2iFWqfid2UwIRLqcRfePb6D1LaIgD21xdQjzBOcWOwI)3NQuVpb(wOZ0de8tLVLiGhgq(Bfao2ZWgvtOrt665LbPcDMEGGFlwCW0)wbGJ6SRnYhm(3NQVIpb(wOZ0de8tLVLiGhgq(BjYCaMpUkaCuNDTr(GHkqgS93Ifhm9Vfhc2rDg0)7t1wWNaFl0z6bc(PY3seWddi)TezoaZhxfaoQZU2iFWqfid2Uwt1sd07koeSJArdh2OAESGOAFPwAGExXHGDulA4WgvKSm65XcI(wS4GP)T4qWoQPh88(3NQTWpb(wOZ0de8tLVLiGhgq(B1QAdah7zyJQdjnYGh6homuOZ0deSwcjSwr6GaWtzd7No76Rb1dOOrHotpqWVfloy6FlqKVg6mC8FFQkR8(e4BXIdM(3kaCuNDTr(GX3cDMEGGFQ8VpvLv2pb(wOZ0de8tLVfloy6FloeSJAs4Cch48BbItranoy6FRxzV2h8DG1YxTKSm1opwq0S2SxBRBDTSdw7dwBdlb93xTateS2wAsGABJN51cmXA5ANhliQ2lR1iqjOF1sc4IgOBxlGpW5S2aWDOBx71G1s9hhKP3U2bAJoihT)wIaEya5VfnqVRedKdbppOBRcKfxTMQLgO3vIbYHGNh0TvZJfevR0APb6DLyGCi45bDBfjlJEESGOAnvRiLGo7Nsc6xt7Owt1kYCaMpUIegrgtD21xgKOFQazW21AQ2wvReoGm9aviPr(GbcQP5iyBSwt1kYCaMpUIdb7O2iFWqfid2(FFQkRC(e4BHotpqWpv(wIaEya5VvRQnaCSNHnQoK0idEOF4WqHotpqWAnvlf12QAdah7zyJQj0OjD98YGuHotpqWAjKWAPOwjCaz6bQmc0aym0OKSwP1kBTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4Aj(BbItranoy6FlQMbjpgTR9bR1GHrTg5btVwGjw7d8AQTLFvZRLg4QfE1(ahJAh88QDKUDTONa2n12ZOw68AQ9AWAF95Rwl7G12YVATpqhmFM1c4dCoRnaCh621EnyTww1MrTeG6S2bAJoihqC(TyXbt)BzKhm9)9PQSe0NaFl0z6bc(PY3seWddi)TOb6Dva4Oo7AJ8bdfy(41siH1AeOeTTaujRIdb7OMMJGTXVfloy6FlqKVg6mC8FFQkl19tGVf6m9ab)u5Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AjKWAncuI2waQKvXHGDutZrW243Ifhm9VvWGq2p90GdI(3NQYszFc8TqNPhi4NkFlrapmG83IgO3vbGJ6SRnYhmubsYqFw7l1srTuVAPuTYP2wsTbGJ9mSr1eA0KUEEzqQqNPhiyTe)TyXbt)BrcJiJPo76lds0V)9PQSuVpb(wOZ0de8tLVfloy6FloeSJAJ8bJVfiofb04GP)TOoBqV2aWDOBx71G1s9hhKP3U2bAJoihTnVwGjwBl)Q1sJ9mWAjqET0AVSwqasJA5A7aJr7ANhlicbRLMJGTXVLiGhgq(BjHditpqfsAKpyGGAAoc2gR1uT0a9UkaCuNDTr(GHcWOwt1srTKSZkdXv7l1srTYHYQLs1srTYkVABj1ksjOZ(PiQDazVwIRL4AjKWAPb6DLyGCi45bDB18ybr1kTwAGExjgihcEEq3wrYYONhliQwI)3NQY(k(e4BHotpqWpv(wIaEya5VLeoGm9aviPr(GbcQP5iyBSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybr1AQwAGExXHGDuBKpyOam(wS4GP)T4qWoQP5iyB8FFQkBl4tGVf6m9ab)u5BXIdM(3AMaJbEh0T1baD7VLiGhgq(Brd07QaWrD21g5dgkW8XRLqcR1iqjABbOswfhc2rnnhbBJ1siH1AeOeTTaujRkyqi7NEAWbr1siH1srTgbkrBlavYQar(AOZWXAnvBRQnaCSNHnQMqJM01Zldsf6m9abRL4VLZK43AMaJbEh0T1baD7)9PQSTWpb(wOZ0de8tLVLiGhgq(Brd07QaWrD21g5dgkW8XRLqcR1iqjABbOswfhc2rnnhbBJ1siH1AeOeTTaujRkyqi7NEAWbr1siH1srTgbkrBlavYQar(AOZWXAnvBRQnaCSNHnQMqJM01Zldsf6m9abRL4Vfloy6FRlben6SRVgutY2W)9PQCK3NaFl0z6bc(PY3seWddi)TmcuI2waQKvDjGOrND91GAs2g(TyXbt)BXHGDuBKpy8VpvLJSFc8TqNPhi4NkFlwCW0)wgborxG6SRjHo43ceNIaACW0)wuFtS2xnBP1EzTZwmaIu)WAzVwuMl4AB5qWowlvg88QfeiGUDTxdwlbYRLsTw(vR9b6G5tTa(aNZAda3HUDTTCiyhRL6q0KQAFL9AB5qWowl1HOjRfoR94b6hcAETpyTc2FF1cmXAF1SLw7d8AGETxdwlbYRLsTw(vR9b6G5tTa(aNZAFWAH(HrayC1EnyTTClTwrd7oomV2zw7d(EmQDYsWAHN6Bjc4HbK)wTQ2JhOFkoeSJAu0Kk0z6bcwRPAbrAGExDjGOrND91GAs2gQamQ1uTGinqVRUeq0OZU(AqnjBdvbsYqFw7lsRLIAzXbtxXHGDutp45PqzqbWH6dsI12sQLgO3vgborxG6SRjHoOIKLrppwquTe)VpvLJC(e4BHotpqWpv(wS4GP)TmcCIUa1zxtcDWVfiofb04GP)TEL9AF1SLwBdp93xT0i61cmrWAbbcOBx71G1sG8AP1(aDW8X8AFW3JrTatSw4v7L1oBXais9dRL9ArzUGRTLdb7yTuzWZRwOx71G1(6ZxLAT8Rw7d0bZh13seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07QaWrD21g5dgQajzOpR9fP1srTS4GPR4qWoQPh88uOmOa4q9bjXABj1sd07kJaNOlqD21KqhurYYONhliQwI)3NQYHG(e4BHotpqWpv(wIaEya5VfyEQGbHSF6PbhePcKKH(Sw5xlLvlHewlisd07QGbHSF6PbhePLamCmyA4aETvZJfevR8RvEFlwCW0)wCiyh10dEE)7tv5qD)e4BHotpqWpv(wS4GP)T4qWoQP5iyB8BbItranoy6FlQtS2h2VAVSwsMiS2jqG1(G12WsWArpbSBQLKDU2Eg1EnyTOFWaRTLF1AFGoy(yETOe0Rf2R9AWaFpRDEWXO2dsI1gijdDOBxB61(6Zxvv7R8EpRn9r7APX7WO2lRLgi8AVSwQFyK1YoyTuhsYAH9Ada3HUDTxdwRLvTzulbOoRDG2OdYbeNQVLiGhgq(BjYCaMpUIdb7O2iFWqfid2Uwt1sYoRmexTVulf1sDLxTuQwkQvw5vBlPwrkbD2pfrTdi71sCTexRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOAnvlf12QAdah7zyJQj0OjD98YGuHotpqWAjKWALWbKPhOYiqdGXqJsYALwRS1sCTMQTv1gao2ZWgvhsAKbp0pCyOqNPhiyTMQTv1gao2ZWgvCiyh1nCqMEBf6m9ab)3NQYHY(e4BHotpqWpv(wS4GP)T4qWoQP5iyB8BbItranoy6FlQWrW2yTZMeyawRNxT0yTateSw(Q9AWArhS2SxBl)Q1c71sDijf8btVw4S2azW21YZAbJ0Wa621kA4WgN1(ahJAjzIWAHxThtew7iDBmQ9YAPbcV2Rjsa7MAdKKHo0TRLKD(Bjc4HbK)w0a9UIdb7O2iFWqbyuRPAPb6Dfhc2rTr(GHkqsg6ZAFrAT2cWAnvRiZby(4kusk4dMUkqsg6Z)9PQCOEFc8TqNPhi4NkFlwCW0)wCiyh10CeSn(TaXPiGghm9Vfv4iyBS2ztcmaRLhpC7zT0yTxdw7GNxTcEE1c9AVgS2xF(Q1(aDW8PwEwlbYRLw7dCmQnW5Lbw71G1kA4WgN1onq)(wIaEya5VfnqVRcah1zxBKpyOamQ1uT0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmubsYqFw7lsR1wawRPABvTbGJ9mSrfhc2rDdhKP3wHotpqW)9PQCEfFc8TqNPhi4NkFlrdd9VLSFlKJrBTOHHUg2)w0a9Usmqoe88GUTw0WUJdfy(4MOGgO3vCiyh1g5dgkadcjKIwD8a9tLsWWiFWabnrbnqVRcah1zxBKpyOamiKqrMdW8XvOKuWhmDvGmyBIjM4VLiGhgq(BbI0a9U6sarJo76Rb1KSnubyuRPApEG(P4qWoQrrtQqNPhiyTMQLIAPb6DfiYxdDgoQaZhVwcjSwwCqjOgDKeIZALwRS1sCTMQfePb6D1LaIgD21xdQjzBOkqsg6ZALFTS4GPR4qWoQjHZjCGtfkdkaouFqs8BXIdM(3Idb7OMeoNWbo)3NQYPf8jW3cDMEGGFQ8TyXbt)BXHGDutcNt4aNFlqCkcOXbt)B9k71(GVdSwjOFnTdZRfssIGq(Wr7AbMyTTU11(0GETc2WabR9YA98Q9HNhwRrKIzT9ijRTLMe4Bjc4HbK)wIuc6SFkjOFnTJAnvlnqVRedKdbppOBRMhliQwP1sd07kXa5qWZd62kswg98ybr)7tv50c)e4BHotpqWpv(wG4ueqJdM(3Y644QfycD7ABDRRTLBP1(0GETT8RwBdpRLgrVwGjc(Teb8WaYFlAGExjgihcEEq3wfilUAnvRiZby(4koeSJAJ8bdvGKm0N1AQwkQLgO3vbGJ6SRnYhmuag1siH1sd07koeSJAJ8bdfGrTe)Tenm0)wY(TyXbt)BXHGDutcNt4aN)7tvcsEFc8TqNPhi4NkFlrapmG83IgO3vCiyh1IgoSr18ybr1(I0ALWbKPhO6YJutYYOfnCyJZVfloy6FloeSJ6mO)3NQeKSFc8TqNPhi4NkFlrapmG83IgO3vbGJ6SRnYhmuag1siH1sYoRmexTYVwzPSVfloy6FloeSJA6bpV)9PkbjNpb(wOZ0de8tLVfloy6Flusk4dM(3c6hgbGXPH9Vfj7SYqCYxAlGY(wq)WiamonKKebH8HFlz)wIaEya5VfnqVRcah1zxBKpyOaZhVwt1sd07koeSJAJ8bdfy(4)7tvcIG(e4BXIdM(3Idb7OMMJGTXVf6m9ab)u5F)7Bf5Xhm9pb(uv2pb(wOZ0de8tLVfloy6Flusk4dM(3ceNIaACW0)wuFtSwuswlSx7d(oWAh5tTPxlj7CTSdwRiZby(4ZA5aRLPtGR2lRLgRfW4Bjc4HbK)wTQ2aWXEg2OAcnAsxpVmivOZ0deSwt1sYoRmexTViTwjCaz6bQqjP2qC1AQwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZAFrATS4GPRqjPGpy6kuguaCO(GKyTesyTImhG5JR4qWoQnYhmubsYqFw7lsRLfhmDfkjf8btxHYGcGd1hKeRLqcRLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0AzXbtxHssbFW0vOmOa4q9bjXAjUwIR1uT0a9UkaCuNDTr(GHcmF8AnvlnqVR4qWoQnYhmuG5JxRPAbrAGExDjGOrND91GAs2gQaZhVwt12QAncuI2waQKvDjGOrND91GAs2g(VpvLZNaFl0z6bc(PY3seWddi)Tcah7zyJQj0OjD98YGuHotpqWAnvBRQvKsqN9tjb9RPDuRPAfzoaZhxXHGDuBKpyOcKKH(S2xKwlloy6kusk4dMUcLbfahQpij(TyXbt)BHssbFW0)3NQe0NaFl0z6bc(PY3seWddi)Tcah7zyJQj0OjD98YGuHotpqWAnvRiLGo7Nsc6xt7Owt1kYCaMpUIegrgtD21xgKOFQajzOpR9fP1YIdMUcLKc(GPRqzqbWH6dsI1AQwrMdW8XvxciA0zxFnOMKTHQajzOpR9fP1srTs4aY0durMN2iqbIG6lpsnD7APuTS4GPRqjPGpy6kuguaCO(GKyTuQwcQwIR1uTImhG5JR4qWoQnYhmubsYqFw7lsRLIALWbKPhOImpTrGceb1xEKA621sPAzXbtxHssbFW0vOmOa4q9bjXAPuTeuTe)TyXbt)BHssbFW0)3NQu3pb(wOZ0de8tLVfloy6FloeSJAAoc2g)wG4ueqJdM(3IkCeSnwlSxl8EpR9GKyTxwlWeR9YJSw2bR9bRTHLG1Ezwlj7TRv0WHno)wIaEya5VLiZby(4Qlben6SRVgutY2qvGmy7Anvlf1sd07koeSJArdh2OAESGOALFTs4aY0duD5rQjzz0IgoSXzTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATOmOa4q9bjXAnvlj7SYqC1k)ALWbKPhOIn0KqhscqQjzN1gIRwt1sd07QaWrD21g5dgkW8XRL4)9PkL9jW3cDMEGGFQ8Teb8WaYFlrMdW8XvxciA0zxFnOMKTHQazW21AQwkQLgO3vCiyh1IgoSr18ybr1k)ALWbKPhO6YJutYYOfnCyJZAnv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xKwlkdkaouFqsSwt1kHditpq1bjrnGFWHMnQv(1kHditpq1LhPMKLrdIdUTUNHMnQL4Vfloy6FloeSJAAoc2g)3NQuVpb(wOZ0de8tLVLiGhgq(BjYCaMpU6sarJo76Rb1KSnufid2Uwt1srT0a9UIdb7Ow0WHnQMhliQw5xReoGm9avxEKAswgTOHdBCwRPAPO2wv7Xd0pva4Oo7AJ8bdf6m9abRLqcRvK5amFCva4Oo7AJ8bdvGKm0N1k)ALWbKPhO6YJutYYObXb3w3ZqhPrTexRPALWbKPhO6GKOgWp4qZg1k)ALWbKPhO6YJutYYObXb3w3ZqZg1s83Ifhm9Vfhc2rnnhbBJ)7t1xXNaFl0z6bc(PY3seWddi)TarAGExfmiK9tpn4GiTeGHJbtdhWRTAESGOALwlisd07QGbHSF6PbhePLamCmyA4aETvKSm65XcIQ1uTuulnqVR4qWoQnYhmuG5JxlHewlnqVR4qWoQnYhmubsYqFw7lsR1wawlX1AQwkQLgO3vbGJ6SRnYhmuG5JxlHewlnqVRcah1zxBKpyOcKKH(S2xKwRTaSwI)wS4GP)T4qWoQP5iyB8FFQ2c(e4BHotpqWpv(wIaEya5VLeoGm9avTOaZtdmrq90GdIQLqcRLIAbrAGExfmiK9tpn4GiTeGHJbtdhWRTcWOwt1cI0a9Ukyqi7NEAWbrAjadhdMgoGxB18ybr1(sTGinqVRcgeY(PNgCqKwcWWXGPHd41wrYYONhliQwI)wS4GP)T4qWoQPh88(3NQTWpb(wOZ0de8tLVLiGhgq(Brd07kJaNOlqD21KqhubyuRPAbrAGExDjGOrND91GAs2gQamQ1uTGinqVRUeq0OZU(AqnjBdvbsYqFw7lsRLfhmDfhc2rn9GNNcLbfahQpij(TyXbt)BXHGDutp459VpvLvEFc8TqNPhi4NkFlrdd9VLSFlKJrBTOHHUg2)w0a9Usmqoe88GUTw0WUJdfy(4MOGgO3vCiyh1g5dgkadcjKIwD8a9tLsWWiFWabnrbnqVRcah1zxBKpyOamiKqrMdW8XvOKuWhmDvGmyBIjM4VLiGhgq(BbI0a9U6sarJo76Rb1KSnubyuRPApEG(P4qWoQrrtQqNPhiyTMQLIAPb6DfiYxdDgoQaZhVwcjSwwCqjOgDKeIZALwRS1sCTMQLIAbrAGExDjGOrND91GAs2gQcKKH(Sw5xlloy6koeSJAs4Cch4uHYGcGd1hKeRLqcRvK5amFCLrGt0fOo7AsOdQcKKH(SwcjSwrkbD2pfrTdi71s83Ifhm9Vfhc2rnjCoHdC(VpvLv2pb(wOZ0de8tLVfloy6FloeSJAs4Cch48BbItranoy6FRwN(eGeR9AWArzmyhebR1ip0pipQLgO3RLNSrTxwRNxTJCI1AKh6hKh1AePy(Teb8WaYFlAGExjgihcEEq3wfilUAnvlnqVRqzmyheb1g5H(b5HcW4FFQkRC(e4BHotpqWpv(wS4GP)T4qWoQjHZjCGZVLOHH(3s2VLiGhgq(Brd07kXa5qWZd62QazXvRPAPOwAGExXHGDuBKpyOamQLqcRLgO3vbGJ6SRnYhmuag1siH1cI0a9U6sarJo76Rb1KSnufijd9zTYVwwCW0vCiyh1KW5eoWPcLbfahQpijwlX)7tvzjOpb(wOZ0de8tLVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQwAGExjgihcEEq3wnpwquTsRLgO3vIbYHGNh0TvKSm65XcI(3NQYsD)e4BHotpqWpv(wG4ueqJdM(3QLhpC7zTx0U2lRLMDIQT1TU2Eg1kYCaMpETpqhmFM1sdC1ccqAu71GK1c71Eny73bwltNaxTxwlkJbmWVLiGhgq(Brd07kXa5qWZd62QazXvRPAPb6DLyGCi45bDBvGKm0N1(I0APOwkQLgO3vIbYHGNh0TvZJfevBlPwwCW0vCiyh1KW5eoWPcLbfahQpijwlX1sPATfGkswMAj(BjAyO)TK9BXIdM(3Idb7OMeoNWbo)3NQYszFc8TqNPhi4NkFlrapmG83IIAdSh4SHPhyTesyTTQ2dkic621sCTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQ1uT0a9UIdb7O2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8Vfloy6FlhVgm0hsAGZ7FFQkl17tGVf6m9ab)u5Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQ2xKwReoGm9avxEKAswgTOHdBC(TyXbt)BXHGDuNb9)(uv2xXNaFl0z6bc(PY3seWddi)TKWbKPhOkbUjee1zxlYCaMp(Swt1sYoRmexTViT2wiL9TyXbt)BnbmWWtj8)(uv2wWNaFl0z6bc(PY3seWddi)TOb6DvamqD21xtG4ubyuRPAPb6Dfhc2rTOHdBunpwquTYVwc6BXIdM(3Idb7OMEWZ7FFQkBl8tGVf6m9ab)u5BXIdM(3Idb7OMMJGTXVfiofb04GP)TEDbG0Owrdh24SwyV2hS2opg1sJJ8P2RbRvK(edjyTKSZ1EnboBYbyTSdwlkjf8btVw4S25bhJAtVwrMdW8X)wIaEya5VvRQnaCSNHnQMqJM01Zldsf6m9abR1uTs4aY0duLa3ecI6SRfzoaZhFwRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOAnv7Xd0pfhc2rDg0k0z6bcwRPAfzoaZhxXHGDuNbTkqsg6ZAFrAT2cWAnvlj7SYqC1(I0ABHYRwt1kYCaMpUcLKc(GPRcKKH(8FFQkh59jW3cDMEGGFQ8Teb8WaYFRaWXEg2OAcnAsxpVmivOZ0deSwt1kHditpqvcCtiiQZUwK5amF8zTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQ1uThpq)uCiyh1zqRqNPhiyTMQvK5amFCfhc2rDg0QajzOpR9fP1AlaR1uTKSZkdXv7lsRTfkVAnvRiZby(4kusk4dMUkqsg6ZAFPwcsEFlwCW0)wCiyh10CeSn(VpvLJSFc8TqNPhi4NkFlwCW0)wCiyh10CeSn(TaXPiGghm9V1RlaKg1kA4WgN1c71MbDTWzTbYGT)wIaEya5VLeoGm9avjWnHGOo7ArMdW8XN1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1E8a9tXHGDuNbTcDMEGG1AQwrMdW8XvCiyh1zqRcKKH(S2xKwRTaSwt1sYoRmexTViT2wO8Q1uTImhG5JRqjPGpy6QajzOpR1uTuuBRQnaCSNHnQMqJM01Zldsf6m9abRLqcRLgO3vtOrt665LbPkqsg6ZAFrATY2cQL4)9PQCKZNaFl0z6bc(PY3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)B1YHGDSwQWrW2yTZMeyawRn6yWJr7APXAVgS2bpVAf88Qn71EnyTT8Rw7d0bZNVLiGhgq(Brd07koeSJAJ8bdfGrTMQLgO3vCiyh1g5dgQajzOpR9fP1AlaR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTMQLIAfzoaZhxHssbFW0vbsYqFwlHewBa4ypdBuXHGDu3Wbz6TvOZ0deSwI)3NQYHG(e4BHotpqWpv(wS4GP)T4qWoQP5iyB8BbItranoy6FRwoeSJ1sfoc2gRD2KadWATrhdEmAxlnw71G1o45vRGNxTzV2RbR91NVATpqhmF(wIaEya5VfnqVRcah1zxBKpyOamQ1uT0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmubsYqFw7lsR1wawRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOAnvlf1kYCaMpUcLKc(GPRcKKH(SwcjS2aWXEg2OIdb7OUHdY0BRqNPhiyTe)VpvLd19tGVf6m9ab)u5BXIdM(3Idb7OMMJGTXVfiofb04GP)TA5qWowlv4iyBS2ztcmaRLgR9AWAh88QvWZR2Sx71G1sG8AP1(aDW8PwyVw4vlCwRNxTateS2h41u7RpF1AZO2w(v)wIaEya5VfnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwqKgO3vxciA0zxFnOMKTHkaJAnvlisd07Qlben6SRVgutY2qvGKm0N1(I0ATfG1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhli6FFQkhk7tGVf6m9ab)u5BXIdM(3Idb7OMMJGTXVfiofb04GP)TOoBqV2RbR94WgVAHZAHETOmOa4WAd2TXAzhS2RbdSw4SwYmWAVg2RnDSw0rY2MxlWeRLMJGTXA5zTZm9A5zTTtGAByjyTONa2n1kA4WgN1EzTnWRwEmQfDKeIZAH9AVgS2woeSJ1sLKKMdqs0VAhOn6GC0Uw4SwSfdanmqWVLiGhgq(BjHditpqfsAKpyGGAAoc2gR1uT0a9UIdb7Ow0WHnQMhliQw5lTwkQLfhucQrhjH4S2wKALTwIR1uTS4Gsqn6ijeN1k)ALTwt1sd07kqKVg6mCubMp()(uvouVpb(wOZ0de8tLVLiGhgq(BjHditpqfsAKpyGGAAoc2gR1uT0a9UIdb7Ow0WHnQMhliQ2xQLgO3vCiyh1IgoSrfjlJEESGOAnvlloOeuJoscXzTYVwzR1uT0a9Uce5RHodhvG5J)TyXbt)BXHGDuJYymYjm9)9PQCEfFc8TyXbt)BXHGDutp459TqNPhi4Nk)7tv50c(e4BHotpqWpv(wIaEya5VLeoGm9avjWnHGOo7ArMdW8XNFlwCW0)wOKuWhm9)9PQCAHFc8TyXbt)BXHGDutZrW243cDMEGGFQ8V)9TezoaZhF(jWNQY(jW3cDMEGGFQ8TyXbt)B1JCEApLWFlqCkcOXbt)B9Qbmd4bP(H1cmHUDT2bCoAxluafdS2h41ulBOQL6BI1cVAFGxtTxEK1MxdgpWjQ(wIaEya5Vva4ypdBuzhW5OTgkGIbQqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTeK8Q1uTImhG5JRUeq0OZU(AqnjBdvbYGTR1uTuulnqVR4qWoQfnCyJQ5XcIQ9fP1kHditpq1LhPMKLrlA4WgN1AQwkQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ATfG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kHditpq1LhPMKLrdIdUTUNHMnQL4AjKWAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RvchqMEGQlpsnjlJgehCBDpdnBulX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTwBbyTexlX)7tv58jW3cDMEGGFQ8Teb8WaYFRaWXEg2OYoGZrBnuafduHotpqWAnvRiZby(4koeSJAJ8bdvGmy7Anvlf12QApEG(PqFaTBo0rqf6m9abRLqcRLIApEG(PqFaTBo0rqf6m9abR1uTKSZkdXvR8Lw7RqE1sCTexRPAPOwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALFTYkVAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfevlX1siH1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR0ALxTMQLgO3vCiyh1IgoSr18ybr1kTw5vlX1sCTMQLgO3vbGJ6SRnYhmuG5JxRPAjzNvgIRw5lTwjCaz6bQydnj0HKaKAs2zTH4(wS4GP)T6ropTNs4)9Pkb9jW3cDMEGGFQ8Teb8WaYFRaWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQvK5amFCfnqVRbHtb0yaDoARfjjj7GQazW21AQwAGExbcNcOXa6C0wlsss2b19iNNcmF8Anvlf1sd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8AjUwt1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwkQLgO3vCiyh1IgoSr18ybr1(I0ALWbKPhO6YJutYYOfnCyJZAnvlf1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFrAT2cWAnvRiZby(4koeSJAJ8bdvGKm0N1k)ALWbKPhO6YJutYYObXb3w3ZqZg1sCTesyTuuBRQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kHditpq1LhPMKLrdIdUTUNHMnQL4AjKWAfzoaZhxXHGDuBKpyOcKKH(S2xKwRTaSwIRL4Vfloy6FREKZJoh3)(uL6(jW3cDMEGGFQ8Teb8WaYFRaWXEg2OceofqJb05OTwKKKSdQqNPhiyTMQvK5amFCfnqVRbHtb0yaDoARfjjj7GQazW21AQwAGExbcNcOXa6C0wlsss2b1DyGkW8XR1uTgbkrBlavYQ6rop6CCFlwCW0)wDyGA6bpV)9PkL9jW3cDMEGGFQ8TyXbt)BrcJiJPo76lds0VVfiofb04GP)TEvgg12stcu7d8AQTLF1AH9AH37zTIKe621cyu7mtxv7RSxl8Q9bog1sJ1cmrWAFGxtTeiVwQ51k45vl8QDoG2n3ODT0ypd8Bjc4HbK)wuuBRQnaCSNHnQMqJM01Zldsf6m9abRLqcRLgO3vtOrt665LbPcWOwIR1uTImhG5JRUeq0OZU(AqnjBdvbsYqFw7l1kHditpqfzEAJaficQV8i10TRLqcRLIALWbKPhO6GKOgWp4qZg1k)ALWbKPhOImpnjlJgehCBDpdnBuRPAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xReoGm9avK5Pjzz0G4GBR7zOV8iRL4)9Pk17tGVf6m9ab)u5Bjc4HbK)wImhG5JR4qWoQnYhmubYGTR1uTuuBRQ94b6Nc9b0U5qhbvOZ0deSwcjSwkQ94b6Nc9b0U5qhbvOZ0deSwt1sYoRmexTYxATVc5vlX1sCTMQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1kHditpqfBOjzz0G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwAGExXHGDulA4WgvZJfevR0ALxTexlX1AQwAGExfaoQZU2iFWqbMpETMQLKDwziUALV0ALWbKPhOIn0KqhscqQjzN1gI7BXIdM(3IegrgtD21xgKOF)7t1xXNaFl0z6bc(PY3seWddi)TKWbKPhOkbUjee1zxlYCaMp(Swt1srTZeyqdDqLKCWhCG6zoKG(PqNPhiyTesyTZeyqdDqLbW8agOgdaJdMUcDMEGG1s83Ifhm9VvFGZgrW97FFQ2c(e4BHotpqWpv(wS4GP)Tar(AOZWXVfiofb04GP)TA5Xd3EwlWeRfe5RHodhR9bEn1YgQAFL9AV8iRfoRnqgSDT8S2hCmmVwsMiS2jqG1EzTcEE1cVAPXEgyTxEKQVLiGhgq(BjYCaMpU6sarJo76Rb1KSnufid2Uwt1sd07koeSJArdh2OAESGOAFrATs4aY0duD5rQjzz0IgoSXzTMQvK5amFCfhc2rTr(GHkqsg6ZAFrAT2cW)9PAl8tGVf6m9ab)u5Bjc4HbK)wImhG5JR4qWoQnYhmubYGTR1uTuuBRQ94b6Nc9b0U5qhbvOZ0deSwcjSwkQ94b6Nc9b0U5qhbvOZ0deSwt1sYoRmexTYxATVc5vlX1sCTMQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1kR8Q1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufid2Uwt1sd07koeSJArdh2OAESGOALwR8QL4AjUwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8LwReoGm9avSHMe6qsasnj7S2qCFlwCW0)wGiFn0z44)(uvw59jW3cDMEGGFQ8TyXbt)BfmiK9tpn4GOVfiofb04GP)TO(MyTtdoiQwyV2lpYAzhSw2OwoWAtVwbyTSdw7t6VVAPXAbmQTNrTJ0TXO2RH9AVgSwswMAbXb328AjzIGUDTtGaR9bRTHLG1YxTdKNxT3twlhc2XAfnCyJZAzhS2RHVAV8iR9HN(7R2wuG5vlWebvFlrapmG83sK5amFC1LaIgD21xdQjzBOkqsg6ZALFTs4aY0duftnjlJgehCBDpd9LhzTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs4aY0duftnjlJgehCBDpdnBuRPAPO2JhOFQaWrD21g5dgk0z6bcwRPAPOwrMdW8XvbGJ6SRnYhmubsYqFw7l1IYGcGd1hKeRLqcRvK5amFCva4Oo7AJ8bdvGKm0N1k)ALWbKPhOkMAswgnio426Eg6inQL4AjKWABvThpq)ubGJ6SRnYhmuOZ0deSwIR1uT0a9UIdb7Ow0WHnQMhliQw5xRCQ1uTGinqVRUeq0OZU(AqnjBdvG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwAGExXHGDuBKpyOaZh)FFQkRSFc8TqNPhi4NkFlwCW0)wbdcz)0tdoi6BbItranoy6FlQVjw70GdIQ9bEn1Yg1(0GETg5CcPhOQ2xzV2lpYAHZAdKbBxlpR9bhdZRLKjcRDceyTxwRGNxTWRwASNbw7LhP6Bjc4HbK)wImhG5JRUeq0OZU(AqnjBdvbsYqFw7l1IYGcGd1hKeR1uT0a9UIdb7Ow0WHnQMhliQ2xKwReoGm9avxEKAswgTOHdBCwRPAfzoaZhxXHGDuBKpyOcKKH(S2xQLIArzqbWH6dsI1sPAzXbtxDjGOrND91GAs2gQqzqbWH6dsI1s8)(uvw58jW3cDMEGGFQ8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpR9LArzqbWH6dsI1AQwkQLIABvThpq)uOpG2nh6iOcDMEGG1siH1srThpq)uOpG2nh6iOcDMEGG1AQws2zLH4Qv(sR9viVAjUwIR1uTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwjCaz6bQydnjlJgehCBDpd9LhzTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1sd07koeSJArdh2OAESGOALwR8QL4AjUwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8LwReoGm9avSHMe6qsasnj7S2qC1s83Ifhm9VvWGq2p90GdI(3NQYsqFc8TqNPhi4NkFlwCW0)wZeymW7GUToaOB)Teb8WaYFlkQTv1gao2ZWgvtOrt665LbPcDMEGG1siH1sd07Qj0OjD98YGubyulX1AQwAGExXHGDulA4WgvZJfev7lsRvchqMEGQlpsnjlJw0WHnoR1uTImhG5JR4qWoQnYhmubsYqFw7lsRfLbfahQpijwRPAjzNvgIRw5xReoGm9avSHMe6qsasnj7S2qC1AQwAGExfaoQZU2iFWqbMp(3Yzs8BntGXaVd626aGU9)(uvwQ7NaFl0z6bc(PY3Ifhm9V1LaIgD21xdQjzB43ceNIaACW0)wuFtS2lpYAFGxtTSrTWETW79S2h41a9AVgSwswMAbXb3wv7RSxRNN51cmXAFGxtTrAulSx71G1E8a9Rw4S2JjcDZRLDWAH37zTpWRb61EnyTKSm1cIdUT6Bjc4HbK)wuuBRQnaCSNHnQMqJM01Zldsf6m9abRLqcRLgO3vtOrt665LbPcWOwIR1uT0a9UIdb7Ow0WHnQMhliQ2xKwReoGm9avxEKAswgTOHdBCwRPAfzoaZhxXHGDuBKpyOcKKH(S2xKwlkdkaouFqsSwt1sYoRmexTYVwjCaz6bQydnj0HKaKAs2zTH4Q1uT0a9UkaCuNDTr(GHcmF8)9PQSu2NaFl0z6bc(PY3seWddi)TOb6Dfhc2rTOHdBunpwquTViTwjCaz6bQU8i1KSmArdh24Swt1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9fP1IYGcGd1hKeR1uTs4aY0duDqsud4hCOzJALFTs4aY0duD5rQjzz0G4GBR7zOzJVfloy6FRlben6SRVgutY2W)9PQSuVpb(wOZ0de8tLVLiGhgq(Brd07koeSJArdh2OAESGOAFrATs4aY0duD5rQjzz0IgoSXzTMQLIABvThpq)ubGJ6SRnYhmuOZ0deSwcjSwrMdW8XvbGJ6SRnYhmubsYqFwR8RvchqMEGQlpsnjlJgehCBDpdDKg1sCTMQvchqMEGQdsIAa)GdnBuR8RvchqMEGQlpsnjlJgehCBDpdnB8TyXbt)BDjGOrND91GAs2g(VpvL9v8jW3cDMEGGFQ8TyXbt)BXHGDuBKpy8TaXPiGghm9Vf13eRLnQf2R9YJSw4S20Rvawl7G1(K(7RwASwaJA7zu7iDBmQ9AyV2RbRLKLPwqCWTnVwsMiOBx7eiWAVg(Q9bRTHLG1IEcy3ulj7CTSdw71WxTxdgyTWzTEE1YJazW21Y1gaowB2R1iFWOwW8XvFlrapmG83sK5amFC1LaIgD21xdQjzBOkqsg6ZALFTs4aY0duXgAswgnio426Eg6lpYAnvlf12QAfPe0z)usq)AAh1siH1kYCaMpUIegrgtD21xgKOFQajzOpRv(1kHditpqfBOjzz0G4GBR7zOjZRwIR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTMQLgO3vbGJ6SRnYhmuG5JxRPAjzNvgIRw5lTwjCaz6bQydnj0HKaKAs2zTH4(3NQY2c(e4BHotpqWpv(wS4GP)Tcah1zxBKpy8TaXPiGghm9Vf13eRnsJAH9AV8iRfoRn9AfG1YoyTpP)(QLgRfWO2Eg1os3gJAVg2R9AWAjzzQfehCBZRLKjc621obcS2RbdSw40FF1YJazW21Y1gaowly(41YoyTxdF1Yg1(K(7RwAuKKyTSegoy6bwliqaD7AdahvFlrapmG83IgO3vCiyh1g5dgkW8XR1uTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)ALWbKPhOksdnjlJgehCBDpd9LhzTesyTImhG5JR4qWoQnYhmubsYqFw7lsRvchqMEGQlpsnjlJgehCBDpdnBulX1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1kYCaMpUIdb7O2iFWqfijd9zTYVwzLxTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZALFTYkV)9PQSTWpb(wOZ0de8tLVLiGhgq(BjHditpqvcCtiiQZUwK5amF853Ifhm9V1Sb2pOBRnYhm(3NQYrEFc8TqNPhi4NkFlwCW0)wgborxG6SRjHo43ceNIaACW0)wuFtSwJKS2lRD2IbqK6hwl71IYCbxltxl0R9AWADuMRwrMdW8XR9b6G5J51c4dCoRLO2bK9AVg0Rn9r7AbbcOBxlhc2XAnYhmQfeaR9YABYNAjzNRTbWTJ21gmiK9R2PbhevlC(Teb8WaYFRJhOFQaWrD21g5dgk0z6bcwRPAPb6Dfhc2rTr(GHcWOwt1sd07QaWrD21g5dgQajzOpR9LATfGkswM)9PQCK9tGVf6m9ab)u5Bjc4HbK)wGinqVRUeq0OZU(AqnjBdvag1AQwqKgO3vxciA0zxFnOMKTHQajzOpR9LAzXbtxXHGDutcNt4aNkuguaCO(GKyTMQTv1ksjOZ(PiQDaz)BXIdM(3YiWj6cuNDnj0b)3NQYroFc8TqNPhi4NkFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExfaoQZU2iFWqfijd9zTVuRTaurYYuRPAfzoaZhxHssbFW0vbYGTR1uTImhG5JRUeq0OZU(AqnjBdvbsYqFwRPABvTIuc6SFkIAhq2)wS4GP)TmcCIUa1zxtcDW)9VVfi2zGX9jWNQY(jW3Ifhm9VLib8dJPbogFl0z6bc(PY)(uvoFc8TqNPhi4NkFlrapmG83IIApEG(PqFaTBo0rqf6m9abR1uTKSZkdXv7lsRTfiVAnvlj7SYqC1kFP1s9OSAjUwcjSwkQTv1E8a9tH(aA3COJGk0z6bcwRPAjzNvgIR2xKwBlGYQL4Vfloy6Fls2zTns(VpvjOpb(wOZ0de8tLVLiGhgq(Brd07koeSJAJ8bdfGX3Ifhm9VLrEW0)3NQu3pb(wOZ0de8tLVLiGhgq(Bfao2ZWgvhsAKbp0pCyOqNPhiyTMQLgO3vOmnmW8GPRamQ1uTuuRiZby(4koeSJAJ8bdvGmy7AjKWAPZ5Swt12H2nNoqsg6ZAFrATux5vlXFlwCW0)whKe1pCy8VpvPSpb(wOZ0de8tLVLiGhgq(Brd07koeSJAJ8bdfy(41AQwAGExfaoQZU2iFWqbMpETMQfePb6D1LaIgD21xdQjzBOcmF8Vfloy6FRb0U5M6wuaqBs0V)9Pk17tGVf6m9ab)u5Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmuG5JxRPAbrAGExDjGOrND91GAs2gQaZh)BXIdM(3IMT1zxFbuq08FFQ(k(e4BHotpqWpv(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)w0ymXGiOB)VpvBbFc8TqNPhi4NkFlrapmG83IgO3vCiyh1g5dgkaJVfloy6Fl6rMG6oq0(FFQ2c)e4BHotpqWpv(wIaEya5VfnqVR4qWoQnYhmuagFlwCW0)wDyG0Jmb)3NQYkVpb(wOZ0de8tLVLiGhgq(Brd07koeSJAJ8bdfGX3Ifhm9Vf7cCEbp0cEm(3NQYk7NaFl0z6bc(PY3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3cyIA4HKZ)9PQSY5tGVf6m9ab)u5BXIdM(3YEWGq(YyQPzqB8Bjc4HbK)w0a9UIdb7O2iFWqbyulHewRiZby(4koeSJAJ8bdvGKm0N1kFP1szuwTMQfePb6D1LaIgD21xdQjzBOcW4BH9okoTZK43YEWGq(YyQPzqB8FFQklb9jW3cDMEGGFQ8TyXbt)BHKgTdKh6maD2f43seWddi)TezoaZhxXHGDuBKpyOcKKH(S2xKwRSuwTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZAFrATYszFlNjXVfsA0oqEOZa0zxG)7tvzPUFc8TqNPhi4NkFlwCW0)wGbYGDyGAj4CIJVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTYxATYrE1siH12QALWbKPhOIn0PRbMyTsRv2AjKWAPO2dsI1kTw5vRPALWbKPhOQdNnq3wNgOJrTsRv2AnvBa4ypdBunHgnPRNxgKk0z6bcwlXFlNjXVfyGmyhgOwcoN44FFQklL9jW3cDMEGGFQ8TyXbt)BntGHgA7WdJVLiGhgq(BjYCaMpUIdb7O2iFWqfijd9zTYxATeK8QLqcRTv1kHditpqfBOtxdmXALwRSFlNjXV1mbgAOTdpm(3NQYs9(e4BHotpqWpv(wS4GP)TShTnA0zxZZjKeo4dM(3seWddi)TezoaZhxXHGDuBKpyOcKKH(Sw5lTw5iVAjKWABvTs4aY0duXg601atSwP1kBTesyTuu7bjXALwR8Q1uTs4aY0du1HZgOBRtd0XOwP1kBTMQnaCSNHnQMqJM01Zldsf6m9abRL4VLZK43YE02OrNDnpNqs4Gpy6)7tvzFfFc8TqNPhi4NkFlwCW0)wKSGPdupBq80KatO4Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7lsRLYQ1uTuuBRQvchqMEGQoC2aDBDAGog1kTwzRLqcR9GKyTYVwcsE1s83Yzs8BrYcMoq9SbXttcmHI)9PQSTGpb(wOZ0de8tLVfloy6FlswW0bQNniEAsGju8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpR9fP1sz1AQwjCaz6bQ6Wzd0T1Pb6yuR0ALTwt1sd07QaWrD21g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(S2xKwlf1kR8QTfPwkR2wsTbGJ9mSr1eA0KUEEzqQqNPhiyTexRPApijw7l1sqY7B5mj(TizbthOE2G4PjbMqX)(uv2w4NaFl0z6bc(PY3Ifhm9V1SHbZheuNbTo76lds0VVLiGhgq(BDqsSwP1kVAjKWAPOwjCaz6bQsGBcbrD21ImhG5JpR1uTuulf1ksjOZ(PiQDazVwt1kYCaMpUkyqi7NEAWbrQajzOpR9fP1kNAnvRiZby(4koeSJAJ8bdvGKm0N1(I0APSAnvRiZby(4Qlben6SRVgutY2qvGKm0N1(I0APSAjUwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1kNAjKWA7q7Mthijd9zTVuRiZby(4koeSJAJ8bdvGKm0N1sCTe)TCMe)wZggmFqqDg06SRVmir)(3NQYrEFc8TqNPhi4NkFlqCkcOXbt)BrzkQxTWzTxdw70arWAZETxdwRvcmg4Dq3U2xpaD7AnISfffhCGFlNjXV1mbgd8oOBRda62FlrapmG83IIALWbKPhO6GKOgWp4qZg1sPAPOwwCW0vbdcz)0tdoisHYGcGd1hKeRTLuRiLGo7NIO2bK9AjUwkvlf1YIdMUce5RHodhvOmOa4q9bjXABj1ksjOZ(PCue5idWAjUwkvlloy6Qlben6SRVgutY2qfkdkaouFqsS2xQ94WgpfiCESlWAPwTuMI6vlX1AQwkQvchqMEGQgwcQtd0rWAjKWAPOwrkbD2pfrTdi71AQ2aWXEg2OIdb7Og6DOdV2k0z6bcwlX1sCTMQ94WgpfiCESlWALFTYHY(wS4GP)TMjWyG3bDBDaq3(FFQkhz)e4BHotpqWpv(wS4GP)Te8yOzXbtxpGZ7BnGZt7mj(Te8qam4dM(8FFQkh58jW3cDMEGGFQ8Teb8WaYFlwCqjOgDKeIZALV0ALWbKPhOItuFCyJNwKa(9TMxaf3NQY(TyXbt)Bj4XqZIdMUEaN33AaNN2zs8BXj(VpvLdb9jW3cDMEGGFQ8Teb8WaYFlrkbD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhi43Ifhm9VLGhdnloy66bCEFRbCEANjXVvdhKP3(FFQkhQ7NaFl0z6bc(PY3seWddi)TKWbKPhOQHLG60aDeSwP1kVAnvReoGm9avD4Sb6260aDmQ1uTTQwkQvKsqN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwlXFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wD4Sb6260aDm(3NQYHY(e4BHotpqWpv(wIaEya5VLeoGm9avnSeuNgOJG1kTw5vRPABvTuuRiLGo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwI)wS4GP)Te8yOzXbtxpGZ7BnGZt7mj(Tsd0X4FFQkhQ3NaFl0z6bc(PY3seWddi)TAvTuuRiLGo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwI)wS4GP)Te8yOzXbtxpGZ7BnGZt7mj(TezoaZhF(VpvLZR4tGVf6m9ab)u5Bjc4HbK)ws4aY0du1Hop00aHxR0ALxTMQTv1srTIuc6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAj(BXIdM(3sWJHMfhmD9aoVV1aopTZK43kYJpy6)7tv50c(e4BHotpqWpv(wIaEya5VLeoGm9avDOZdnnq41kTwzR1uTTQwkQvKsqN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwlXFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wDOZdnnq4)7FFlJafjjnFFc8PQSFc8TyXbt)BXHGDud9dhduCFl0z6bc(PY)(uvoFc8TyXbt)BnbijtxZHGDu3zs4aYX3cDMEGGFQ8VpvjOpb(wS4GP)TeP3IceOMKDwBJKFl0z6bc(PY)(uL6(jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXVfNO(4WgpTib87BbIDgyCFlc6FFQszFc8TqNPhi4NkFR04Bf4eVVfloy6FljCaz6b(TKWH2zs8BHssTH4(wGyNbg33swk7FFQs9(e4BHotpqWpv(wPX3AI33Ifhm9VLeoGm9a)ws4q7mj(Tmc0aym0OK8Bjc4HbK)wuuBa4ypdBunHgnPRNxgKk0z6bcwRPAPOwrkbD2pLe0VM2rTesyTIuc6SFkhfroYaSwcjSwr6GaWtXHGDuBeji0UTcDMEGG1sCTe)TKWdauJJj(TK33scpaWVLS)7t1xXNaFl0z6bc(PY3kn(wt8(wS4GP)TKWbKPh43schANjXVvdlb1Pb6i43seWddi)TyXbLGA0rsioRv(sRvchqMEGkor9XHnEArc433scpaqnoM43sEFlj8aa)wY(VpvBbFc8TqNPhi4NkFR04BnX7BXIdM(3schqMEGFlj8aa)wY7BjHdTZK43QdDEOPbc)FFQ2c)e4BHotpqWpv(wPX3kWjEFlwCW0)ws4aY0d8BjHdTZK43QHdY0BRNhlisFqs8BbIDgyCFRw4)(uvw59jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXVfpE42t9STl0ImhG5Jp)wGyNbg33sE)7tvzL9tGVf6m9ab)u5BLgFRaN49TyXbt)BjHditpWVLeo0otIFRyQjzz0G4GBR7zOV8i)wGyNbg33IY(3NQYkNpb(wOZ0de8tLVvA8TcCI33Ifhm9VLeoGm9a)ws4q7mj(TIPMKLrdIdUTUNHosJVfi2zGX9TOS)9PQSe0NaFl0z6bc(PY3kn(wboX7BXIdM(3schqMEGFljCODMe)wXutYYObXb3w3ZqZgFlqSZaJ7Bjh59VpvLL6(jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXVfzEAJaficQV8i10T)wGyNbg33Qf8VpvLLY(e4BHotpqWpv(wPX3kWjEFlwCW0)ws4aY0d8BjHdTZK43ImpnjlJgehCBDpd9Lh53ce7mW4(wYkV)9PQSuVpb(wOZ0de8tLVvA8TcCI33Ifhm9VLeoGm9a)ws4q7mj(TiZttYYObXb3w3ZqZgFlqSZaJ7BjlL9VpvL9v8jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXVfBOjzz0G4GBR7zOV8i)wIaEya5VLiDqa4P4qWoQnIeeA3(BjHhaOght8BjR8(ws4ba(Tii59VpvLTf8jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXVfBOjzz0G4GBR7zOV8i)wGyNbg33soY7FFQkBl8tGVf6m9ab)u5BLgFRaN49TyXbt)BjHditpWVLeo0otIFl2qtYYObXb3w3ZqtM33ce7mW4(wYrE)7tv5iVpb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFl5iVABrQLIAPSABj1ksheaEkoeSJAJibH2TvOZ0deSwI)ws4q7mj(TI0qtYYObXb3w3ZqF5r(VpvLJSFc8TqNPhi4NkFR04BnX7BXIdM(3schqMEGFlj8aa)wuwTuQw5iVABj1srTIuc6SFkhA3C6oJ1siH1srTI0bbGNIdb7O2isqODBf6m9abR1uTS4Gsqn6ijeN1(sTs4aY0duXjQpoSXtlsa)QL4AjUwkvRSuwTTKAPOwrkbD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLfhucQrhjH4Sw5lTwjCaz6bQ4e1hh24PfjGF1s83schANjXV1LhPMKLrdIdUTUNHMn(3NQYroFc8TqNPhi4NkFR04BnX7BXIdM(3schqMEGFlj8aa)wYrE12Iulf12cQTLuRiDqa4P4qWoQnIeeA3wHotpqWAj(BjHdTZK436YJutYYObXb3w3ZqhPX)(uvoe0NaFl0z6bc(PY3kn(wt8(wS4GP)TKWbKPh43scpaWVf1tE12Iulf1sYZdJ2Aj8aaRTLuRSYtE1s83seWddi)TePe0z)uo0U50Dg)ws4q7mj(TO5iyButYoRne3)(uvou3pb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFRwiLvBlsTuuljppmARLWdaS2wsTYkp5vlXFlrapmG83sKsqN9tru7aY(3schANjXVfnhbBJAs2zTH4(3NQYHY(e4BHotpqWpv(wPX3AI33Ifhm9VLeoGm9a)ws4ba(TAbYR2wKAPOwsEEy0wlHhayTTKALvEYRwI)wIaEya5VLeoGm9av0CeSnQjzN1gIRwP1kVVLeo0otIFlAoc2g1KSZAdX9VpvLd17tGVf6m9ab)u5BLgFRaN49TyXbt)BjHditpWVLeo0otIFl2qtcDijaPMKDwBiUVfi2zGX9TKLY(3NQY5v8jW3cDMEGGFQ8TsJVvGt8(wS4GP)TKWbKPh43schANjXV1LhPMKLrlA4WgNFlqSZaJ7BjN)9PQCAbFc8TqNPhi4NkFR04Bf4eVVfloy6FljCaz6b(TKWH2zs8BXjQV8i1KSmArdh248BbIDgyCFl58VpvLtl8tGVf6m9ab)u5BLgFRjEFlwCW0)ws4aY0d8BjHha43s2ABj1srTylgaAyGGkK0ODG8qNbOZUaRLqcRLIApEG(Pcah1zxBKpyOqNPhiyTMQLIApEG(P4qWoQrrtQqNPhiyTesyTTQwrkbD2pfrTdi71sCTMQLIABvTIuc6SFkhfroYaSwcjSwwCqjOgDKeIZALwRS1siH1gao2ZWgvtOrt665LbPcDMEGG1sCTMQTv1ksjOZ(PKG(10oQL4Aj(BjHdTZK43QdNnq3wNgOJX)(uLGK3NaFl0z6bc(PY3kn(wt8(wS4GP)TKWbKPh43scpaWVf2IbGggiOIKfmDG6zdINMeycf1siH1ITyaOHbcQShmiKVmMAAg0gRLqcRfBXaqddeuzpyqiFzm1KiipgW0RLqcRfBXaqddeubYbrKz6AquqK2a4cCkqxG1siH1ITyaOHbcQG(ueahtpqDlgG9dGudIsGcSwcjSwSfdanmqq1mbgd8oOBRda621siH1ITyaOHbcQMao9itqntIxt75vlHewl2IbGggiO6HjcDmM6EKoyTesyTylgaAyGGQ(GjrD2108Dd8BjHdTZK43In0PRbM4)(uLGK9tGVfloy6FlsyezOHKSn(TqNPhi4Nk)7tvcsoFc8TqNPhi4NkFlrapmG83AMadAOdQKKd(GdupZHe0pf6m9abRLqcRDMadAOdQmaMhWa1yayCW0vOZ0de8BXIdM(3QpWzJi4(9Vpvjic6tGVf6m9ab)u5Bjc4HbK)wIuc6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAnvRiDqa4P4qWoQnIeeA3wHotpqWAnvReoGm9av84HBp1Z2UqlYCaMp(Swt1YIdkb1OJKqCw7l1kHditpqfNO(4WgpTib87BXIdM(3kaCuNDTr(GX)(uLGOUFc8TqNPhi4NkFlrapmG83Qv1kHditpqLrGgaJHgLK1kTwzR1uTbGJ9mSrfiCkGgdOZrBTijjzhuHotpqWVfloy6FREKZJoh3)(uLGOSpb(wOZ0de8tLVLiGhgq(B1QALWbKPhOYiqdGXqJsYALwRS1AQ2wvBa4ypdBubcNcOXa6C0wlsss2bvOZ0deSwt1srTTQwrkbD2pLe0VM2rTesyTs4aY0du1HZgOBRtd0XOwI)wS4GP)T4qWoQPh88(3NQee17tGVf6m9ab)u5Bjc4HbK)wTQwjCaz6bQmc0aym0OKSwP1kBTMQTv1gao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uTIuc6SFkjOFnTJAnvBRQvchqMEGQoC2aDBDAGogFlwCW0)wKWiYyQZU(YGe97FFQsqVIpb(wOZ0de8tLVLiGhgq(BjHditpqLrGgaJHgLK1kTwz)wS4GP)TqjPGpy6)7FFloXpb(uv2pb(wOZ0de8tLVLiGhgq(Bfao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uTImhG5JROb6DniCkGgdOZrBTijjzhufid2Uwt1sd07kq4uangqNJ2ArssYoOUh58uG5JxRPAPOwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5JxlX1AQwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1srT0a9UIdb7Ow0WHnQMhliQ2xKwReoGm9avCI6lpsnjlJw0WHnoR1uTuulf1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9fP1AlaR1uTImhG5JR4qWoQnYhmubsYqFwR8RvchqMEGQlpsnjlJgehCBDpdnBulX1siH1srTTQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xReoGm9avxEKAswgnio426EgA2OwIRLqcRvK5amFCfhc2rTr(GHkqsg6ZAFrAT2cWAjUwI)wS4GP)T6rop6CC)7tv58jW3cDMEGGFQ8Teb8WaYFlkQnaCSNHnQaHtb0yaDoARfjjj7Gk0z6bcwRPAfzoaZhxrd07Aq4uangqNJ2ArssYoOkqgSDTMQLgO3vGWPaAmGohT1IKKKDqDhgOcmF8AnvRrGs02cqLSQEKZJohxTexlHewlf1gao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uThKeRvATYRwI)wS4GP)T6Wa10dEE)7tvc6tGVf6m9ab)u5Bjc4HbK)wbGJ9mSrLDaNJ2AOakgOcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sqYRwt1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwkQLgO3vCiyh1IgoSr18ybr1(I0ALWbKPhOItuF5rQjzz0IgoSXzTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwBbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs4aY0duD5rQjzz0G4GBR7zOzJAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)ALWbKPhO6YJutYYObXb3w3ZqZg1sCTesyTImhG5JR4qWoQnYhmubsYqFw7lsR1wawlX1s83Ifhm9VvpY5P9uc)VpvPUFc8TqNPhi4NkFlrapmG83kaCSNHnQSd4C0wdfqXavOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTsRvE1AQwkQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1kHditpqfBOjzz0G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLrppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwAGExXHGDulA4WgvZJfev7lsRvchqMEGkor9LhPMKLrlA4WgN1sCTexRPAPb6Dva4Oo7AJ8bdfy(41s83Ifhm9VvpY5P9uc)VpvPSpb(wOZ0de8tLVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)wIuc6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAnvlnqVR4qWoQB4Gm92Q5XcIQ9LALLYQ1uTImhG5JRcgeY(PNgCqKkqsg6ZAFrATs4aY0du1Wbz6T1ZJfePpijwlLQfLbfahQpijwRPAfzoaZhxDjGOrND91GAs2gQcKKH(S2xKwReoGm9avnCqMEB98ybr6dsI1sPArzqbWH6dsI1sPAzXbtxfmiK9tpn4GifkdkaouFqsSwt1kYCaMpUIdb7O2iFWqfijd9zTViTwjCaz6bQA4Gm9265XcI0hKeRLs1IYGcGd1hKeRLs1YIdMUkyqi7NEAWbrkuguaCO(GKyTuQwwCW0vxciA0zxFnOMKTHkuguaCO(GK4)(uL69jW3cDMEGGFQ8Teb8WaYFlrkbD2pLe0VM2rTMQ94b6NIdb7OgfnPcDMEGG1AQ2dsI1(sTYkVAnvRiZby(4ksyezm1zxFzqI(PcKKH(Swt1sd07kXa5qWZd62Q5XcIQ9LAjOVfloy6FloeSJA6bpV)9P6R4tGVf6m9ab)u5BXIdM(3AMaJbEh0T1baD7VLiGhgq(Bfao2ZWgvtOrt665LbPcDMEGG1AQwJaLOTfGkzvOKuWhm9VLZK43AMaJbEh0T1baD7)9PAl4tGVf6m9ab)u5Bjc4HbK)wbGJ9mSr1eA0KUEEzqQqNPhiyTMQ1iqjABbOswfkjf8bt)BXIdM(36sarJo76Rb1KSn8FFQ2c)e4BHotpqWpv(wIaEya5Vva4ypdBunHgnPRNxgKk0z6bcwRPAPOwJaLOTfGkzvOKuWhm9AjKWAncuI2waQKvDjGOrND91GAs2gwlXFlwCW0)wCiyh1g5dg)7tvzL3NaFl0z6bc(PY3seWddi)TezoaZhxXHGDuBKpyOcKKH(S2xKwBlOwt1kYCaMpU6sarJo76Rb1KSnufijd9zTViT2wqTMQLIAPb6Dfhc2rTOHdBunpwquTViTwjCaz6bQ4e1xEKAswgTOHdBCwRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7lsR1wawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlLvlX1siH1srTTQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlLvlX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTwBbyTexlXFlwCW0)wKWiYyQZU(YGe97FFQkRSFc8TqNPhi4NkFlrapmG836GKyTYVwcsE1AQ2aWXEg2OAcnAsxpVmivOZ0deSwt1ksjOZ(PKG(10oQ1uTgbkrBlavYQiHrKXuND9Lbj633Ifhm9Vfkjf8bt)FFQkRC(e4BHotpqWpv(wIaEya5V1bjXALFTeK8Q1uTbGJ9mSr1eA0KUEEzqQqNPhiyTMQLgO3vCiyh1IgoSr18ybr1(I0ALWbKPhOItuF5rQjzz0IgoSXzTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZALwR8Q1uTImhG5JR4qWoQnYhmubsYqFw7lsR1wa(TyXbt)BHssbFW0)3NQYsqFc8TqNPhi4NkFlwCW0)wOKuWhm9Vf0pmcaJtd7FlAGExnHgnPRNxgKQ5XcIKsd07Qj0OjD98YGurYYONhli6Bb9dJaW40qsseeYh(TK9Bjc4HbK)whKeRv(1sqYRwt1gao2ZWgvtOrt665LbPcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRvATYRwt1srTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwjCaz6bQydnjlJgehCBDpd9LhzTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1sd07koeSJArdh2OAESGOAFrATs4aY0duXjQV8i1KSmArdh24SwIRL4AnvlnqVRcah1zxBKpyOaZhVwI)3NQYsD)e4BHotpqWpv(wIaEya5VLiZby(4Qlben6SRVgutY2qvGKm0N1(sTOmOa4q9bjXAnvlf1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFrAT2cWAnvRiZby(4koeSJAJ8bdvGKm0N1k)ALWbKPhO6YJutYYObXb3w3ZqZg1sCTesyTuuBRQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1kHditpq1LhPMKLrdIdUTUNHMnQL4AjKWAfzoaZhxXHGDuBKpyOcKKH(S2xKwRTaSwI)wS4GP)TcgeY(PNgCq0)(uvwk7tGVf6m9ab)u5Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7l1IYGcGd1hKeR1uTuulf1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RvchqMEGk2qtYYObXb3w3ZqF5rwRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlJEESGOAjUwcjSwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALwR8Q1uT0a9UIdb7Ow0WHnQMhliQ2xKwReoGm9avCI6lpsnjlJw0WHnoRL4AjUwt1sd07QaWrD21g5dgkW8XRL4Vfloy6FRGbHSF6Pbhe9VpvLL69jW3cDMEGGFQ8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpRvATYRwt1srTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwjCaz6bQydnjlJgehCBDpd9LhzTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1sd07koeSJArdh2OAESGOAFrATs4aY0duXjQV8i1KSmArdh24SwIRL4AnvlnqVRcah1zxBKpyOaZhVwI)wS4GP)Tar(AOZWX)9PQSVIpb(wOZ0de8tLVfloy6FRzcmg4Dq3wha0T)wIaEya5Vff1sd07koeSJArdh2OAESGOAFrATs4aY0duXjQV8i1KSmArdh24SwcjSwJaLOTfGkzvbdcz)0tdoiQwIR1uTuulf1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9fP1AlaR1uTImhG5JR4qWoQnYhmubsYqFwR8RvchqMEGQlpsnjlJgehCBDpdnBulX1siH1srTTQ2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xReoGm9avxEKAswgnio426EgA2OwIRLqcRvK5amFCfhc2rTr(GHkqsg6ZAFrAT2cWAj(B5mj(TMjWyG3bDBDaq3(FFQkBl4tGVf6m9ab)u5Bjc4HbK)wuulnqVR4qWoQfnCyJQ5XcIQ9fP1kHditpqfNO(YJutYYOfnCyJZAjKWAncuI2waQKvfmiK9tpn4GOAjUwt1srTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xKwRTaSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwjCaz6bQU8i1KSmAqCWT19m0SrTexlHewlf12QApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTs4aY0duD5rQjzz0G4GBR7zOzJAjUwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1AlaRL4Vfloy6FRlben6SRVgutY2W)9PQSTWpb(wOZ0de8tLVLiGhgq(BrrTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)ALWbKPhOIn0KSmAqCWT19m0xEK1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwIRLqcRLIAfzoaZhxDjGOrND91GAs2gQcKKH(SwP1kVAnvlnqVR4qWoQfnCyJQ5XcIQ9fP1kHditpqfNO(YJutYYOfnCyJZAjUwIR1uT0a9UkaCuNDTr(GHcmF8Vfloy6FloeSJAJ8bJ)9PQCK3NaFl0z6bc(PY3seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwkQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xRCKxTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSm65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1sd07koeSJArdh2OAESGOAFrATs4aY0duXjQV8i1KSmArdh24SwIRL4Anvlf1kYCaMpUIdb7O2iFWqfijd9zTYVwzLtTesyTGinqVRUeq0OZU(AqnjBdvag1s83Ifhm9Vva4Oo7AJ8bJ)9PQCK9tGVf6m9ab)u5Bjc4HbK)wImhG5JR4qWoQZGwfijd9zTYVwkRwcjS2wv7Xd0pfhc2rDg0k0z6bc(TyXbt)BnBG9d62AJ8bJ)9PQCKZNaFl0z6bc(PY3seWddi)TePe0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1AQwAGExXHGDuBKpyOamQ1uTGinqVRcgeY(PNgCqKwcWWXGPHd41wnpwquTsRL6wRPAncuI2waQKvXHGDuNbDTMQLfhucQrhjH4S2xQ9v8TyXbt)BXHGDutp459VpvLdb9jW3cDMEGGFQ8Teb8WaYFlrkbD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLgO3vCiyh1g5dgkaJAnvlisd07QGbHSF6PbhePLamCmyA4aETvZJfevR0APUFlwCW0)wCiyh10CeSn(VpvLd19tGVf6m9ab)u5Bjc4HbK)wIuc6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAnvlnqVR4qWoQnYhmuag1AQwkQfmpvWGq2p90GdIubsYqFwR8RL6vlHewlisd07QGbHSF6PbhePLamCmyA4aETvag1sCTMQfePb6DvWGq2p90GdI0sagogmnCaV2Q5XcIQ9LAPU1AQwwCqjOgDKeIZALwlb9TyXbt)BXHGDutp459VpvLdL9jW3cDMEGGFQ8Teb8WaYFlrkbD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLgO3vCiyh1g5dgkaJAnvlisd07QGbHSF6PbhePLamCmyA4aETvZJfevR0AjOVfloy6FloeSJ6mO)3NQYH69jW3cDMEGGFQ8Teb8WaYFlrkbD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLgO3vCiyh1g5dgkaJAnvlisd07QGbHSF6PbhePLamCmyA4aETvZJfevR0ALZ3Ifhm9Vfhc2rnnhbBJ)7tv58k(e4BHotpqWpv(wIaEya5VLiLGo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQ1iqjABbOsoQGbHSF6PbhevRPAzXbLGA0rsioRv(1sqFlwCW0)wCiyh1OmgJCct)FFQkNwWNaFl0z6bc(PY3seWddi)TePe0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1AQwAGExXHGDuBKpyOamQ1uTGinqVRcgeY(PNgCqKwcWWXGPHd41wnpwquTsRv2AnvlloOeuJoscXzTYVwc6BXIdM(3Idb7OgLXyKty6)7tv50c)e4BHotpqWpv(wIaEya5VfnqVRar(AOZWrfGrTMQfePb6D1LaIgD21xdQjzBOcWOwt1cI0a9U6sarJo76Rb1KSnufijd9zTViTwAGExze4eDbQZUMe6Gkswg98ybr12sQLfhmDfhc2rn9GNNcLbfahQpijwRPAPOwkQ94b6NkWz6Slqf6m9abR1uTS4Gsqn6ijeN1(sTu3AjUwcjSwwCqjOgDKeIZAFPwkRwIR1uTuuBRQnaCSNHnQ4qWoQPtsAoajr)uOZ0deSwcjS2JdB8unipUgLH4Qv(1squwTe)TyXbt)Bze4eDbQZUMe6G)7tvcsEFc8TqNPhi4NkFlrapmG83IgO3vGiFn0z4OcWOwt1srTuu7Xd0pvGZ0zxGk0z6bcwRPAzXbLGA0rsioR9LAPU1sCTesyTS4Gsqn6ijeN1(sTuwTexRPAPO2wvBa4ypdBuXHGDutNK0CasI(PqNPhiyTesyThh24PAqECnkdXvR8RLGOSAj(BXIdM(3Idb7OMEWZ7FFQsqY(jW3Ifhm9V1eWadpLWFl0z6bc(PY)(uLGKZNaFl0z6bc(PY3seWddi)TOb6Dfhc2rTOHdBunpwquTYxATuulloOeuJoscXzTTi1kBTexRPAdah7zyJkoeSJA6KKMdqs0pf6m9abR1uThh24PAqECnkdXv7l1squ23Ifhm9Vfhc2rnnhbBJ)7tvcIG(e4BHotpqWpv(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizz0ZJfe9TyXbt)BXHGDutZrW24)(uLGOUFc8TqNPhi4NkFlrapmG83IgO3vCiyh1IgoSr18ybr1kTw5vRPAPOwrMdW8XvCiyh1g5dgQajzOpRv(1klLvlHewBRQLIAfPe0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGG1sCTe)TyXbt)BXHGDuNb9)(uLGOSpb(wOZ0de8tLVLiGhgq(BrrTb2dC2W0dSwcjS2wv7bfebD7AjUwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJkswg98ybrFlwCW0)woEnyOpK0aN3)(uLGOEFc8TqNPhi4NkFlrapmG83IgO3vIbYHGNh0TvbYIRwt1gao2ZWgvCiyh1nCqMEBf6m9abR1uTuulf1E8a9tXKgdyhk4dMUcDMEGG1AQwwCqjOgDKeIZAFP2wqTexlHewlloOeuJoscXzTVulLvlXFlwCW0)wCiyh1KW5eoW5)(uLGEfFc8TqNPhi4NkFlrapmG83IgO3vIbYHGNh0TvbYIRwt1E8a9tXHGDuJIMuHotpqWAnvlisd07Qlben6SRVgutY2qfGrTMQLIApEG(PysJbSdf8btxHotpqWAjKWAzXbLGA0rsioR9LABH1s83Ifhm9Vfhc2rnjCoHdC(VpvjOwWNaFl0z6bc(PY3seWddi)TOb6DLyGCi45bDBvGS4Q1uThpq)umPXa2Hc(GPRqNPhiyTMQLfhucQrhjH4S2xQL6(TyXbt)BXHGDutcNt4aN)7tvcQf(jW3cDMEGGFQ8Teb8WaYFlAGExXHGDulA4WgvZJfev7l1sd07koeSJArdh2OIKLrppwq03Ifhm9Vfhc2rnkJXiNW0)3NQux59jW3cDMEGGFQ8Teb8WaYFlAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1AeOeTTaujRIdb7OMMJGTXVfloy6FloeSJAugJroHP)V)9TA4Gm92Fc8PQSFc8TqNPhi4NkFlwCW0)wOKuWhm9Vfiofb04GP)TEL9Ah5tTPxlj7CTSdwRiZby(4ZA5aRvKKq3UwadZR1oRLBqgSw2bRfLKFlrapmG83IKDwziUAFrATeK8Q1uTs4aY0duLa3ecI6SRfzoaZhFwRPAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTVuRSYRwI)3NQY5tGVf6m9ab)u5BbItranoy6FlQtS2h2VAVS25XcIQTHdY0BxBhymARQLanyTatS2SxRSuVANhliAwBdgyTWzTxwllejGF12ZO2RbR9GcIQDG9R20R9AWAfnS74Ow2bR9AWAjHZjCG1c9A7dODZP(wIaEya5Vff1kHditpq18ybr6goitVDTesyThKeR9LALvE1sCTMQLgO3vCiyh1nCqMEB18ybr1(sTYs9(wIgg6Flz)wS4GP)T4qWoQjHZjCGZ)9Pkb9jW3cDMEGGFQ8TyXbt)BXHGDutcNt4aNFlqCkcOXbt)BrD2GETatOBxl1bPr7a5rTVobOZUanVwbpVA5A74tTOmxW1scNt4aN1(0ahyTpm8GUDT9mQ9AWAPb69A5R2RbRDECC1M9AVgS2o0U5(wIaEya5Vf2IbGggiOcjnAhip0za6SlWAnv7bjXAFPwcsE1AQ2lTThOsK5amF8zTMQvK5amFCfsA0oqEOZa0zxGQajzOpRv(1kl1RfuRPABvTS4GPRqsJ2bYdDgGo7cubcNm9ab)3NQu3pb(wOZ0de8tLVfloy6FRzcmg4Dq3wha0T)wIaEya5VLeoGm9aviPr(GbcQP5iyBSwt1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwuguaCO(GKyTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATuulkdkaouFqsS2wsTYPwI)wotIFRzcmg4Dq3wha0T)3NQu2NaFl0z6bc(PY3seWddi)TKWbKPhOcjnYhmqqnnhbBJ1AQwrMdW8XvxciA0zxFnOMKTHQajzOpR9fP1IYGcGd1hKeR1uTImhG5JR4qWoQnYhmubsYqFw7lsRLIArzqbWH6dsI12sQvo1sCTMQLIABvTylgaAyGGQzcmg4Dq3wha0TRLqcRvKoia8uCiyh1grccTBRc2jQw5lTwkRwcjSwrMdW8XvZeymW7GUToaOBRcKKH(Sw5xRSYkVAj(BXIdM(3kyqi7NEAWbr)7tvQ3NaFl0z6bc(PY3seWddi)TKWbKPhOQffyEAGjcQNgCquTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATOmOa4q9bjXAnvlf12QAXwma0WabvZeymW7GUToaOBxlHewRiDqa4P4qWoQnIeeA3wfStuTYxATuwTesyTImhG5JRMjWyG3bDBDaq3wfijd9zTYVwzLvE1s83Ifhm9V1LaIgD21xdQjzB4)(u9v8jW3cDMEGGFQ8Teb8WaYFlJaLOTfGkzvxciA0zxFnOMKTHFlwCW0)wCiyh1g5dg)7t1wWNaFl0z6bc(PY3seWddi)TKWbKPhOcjnYhmqqnnhbBJ1AQwrMdW8Xvbdcz)0tdoisfijd9zTViTwuguaCO(GKyTMQvchqMEGQdsIAa)GdnBuR8LwRCKxTMQLIABvTI0bbGNIdb7O2isqODBf6m9abRLqcRTv1kHditpqfpE42t9STl0ImhG5JpRLqcRvK5amFC1LaIgD21xdQjzBOkqsg6ZAFrATuulkdkaouFqsS2wsTYPwIRL4Vfloy6FRaWrD21g5dg)7t1w4NaFl0z6bc(PY3seWddi)TKWbKPhOcjnYhmqqnnhbBJ1AQwJaLOTfGkzvbGJ6SRnYhm(wS4GP)TcgeY(PNgCq0)(uvw59jW3cDMEGGFQ8Teb8WaYFljCaz6bQArbMNgyIG6PbhevRPABvTs4aY0du1KdqOBRV8i)wS4GP)TUeq0OZU(AqnjBd)3NQYk7NaFl0z6bc(PY3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)Br9nXALJdwlhc2XAP5iyBSwOxBl)Qu61)68Q1M(ODTWETuzKj4ayE1YoyT8v7a55vRCQT1TEwRrKcbc(Teb8WaYFlAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1sd07QaWrD21g5dgkaJAnvlnqVR4qWoQnYhmuag1AQwAGExXHGDu3Wbz6TvZJfevR8LwRSuVAnvlnqVR4qWoQnYhmubsYqFw7lsRLfhmDfhc2rnnhbBJkuguaCO(GKyTMQLgO3v0JmbhaZtby8VpvLvoFc8TqNPhi4NkFlwCW0)wbGJ6SRnYhm(wG4ueqJdM(3I6BI1khhS2xF(Q1c9AB5xT20hTRf2RLkJmbhaZRw2bRvo126wpR1isX3seWddi)TOb6Dva4Oo7AJ8bdfy(41AQwAGExrpYeCampfGrTMQLIALWbKPhO6GKOgWp4qZg1k)Aji5vlHewRiZby(4QGbHSF6PbhePcKKH(Sw5xRSYPwIR1uTuulnqVR4qWoQB4Gm92Q5XcIQv(sRvwkRwcjSwAGExjgihcEEq3wnpwquTYxATYwlX1AQwkQTv1ksheaEkoeSJAJibH2TvOZ0deSwcjS2wvReoGm9av84HBp1Z2UqlYCaMp(SwI)3NQYsqFc8TqNPhi4NkFlrapmG83IgO3vCiyh1g5dgkW8XR1uTuuReoGm9avhKe1a(bhA2Ow5xlbjVAjKWAfzoaZhxfmiK9tpn4GivGKm0N1k)ALvo1sCTMQLIABvTI0bbGNIdb7O2isqODBf6m9abRLqcRTv1kHditpqfpE42t9STl0ImhG5JpRL4Vfloy6FRaWrD21g5dg)7tvzPUFc8TqNPhi4NkFlrapmG83schqMEGkK0iFWab10CeSnwRPAPOwAGExXHGDulA4WgvZJfevR8LwRCQLqcRvK5amFCfhc2rDg0QazW21sCTMQLIABvThpq)ubGJ6SRnYhmuOZ0deSwcjSwrMdW8XvbGJ6SRnYhmubsYqFwR8RLYQL4AnvReoGm9av48GK8HGA2qlYCaMpETYxATeK8Q1uTuuBRQvKoia8uCiyh1grccTBRqNPhiyTesyTTQwjCaz6bQ4Xd3EQNTDHwK5amF8zTe)TyXbt)BfmiK9tpn4GO)9PQSu2NaFl0z6bc(PY3Ifhm9V1LaIgD21xdQjzB43ceNIaACW0)wuNnOxBa4o0TR1isqODBZRfyI1E5rwlD7AH3eh9AHETzaIrTxwlpG2ETWR2h41ulB8Teb8WaYFljCaz6bQoijQb8do0SrTVulLjVAnvReoGm9avhKe1a(bhA2Ow5xlbjVAnvlf12QAXwma0WabvZeymW7GUToaOBxlHewRiDqa4P4qWoQnIeeA3wfStuTYxATuwTe)VpvLL69jW3cDMEGGFQ8Teb8WaYFljCaz6bQArbMNgyIG6PbhevRPAPb6Dfhc2rTOHdBunpwquTVulnqVR4qWoQfnCyJkswg98ybrFlwCW0)wCiyh1zq)VpvL9v8jW3cDMEGGFQ8Teb8WaYFlqKgO3vbdcz)0tdoislby4yW0Wb8ARMhliQwP1cI0a9Ukyqi7NEAWbrAjadhdMgoGxBfjlJEESGOVfloy6FloeSJAAoc2g)3NQY2c(e4BHotpqWpv(wIaEya5VLeoGm9avTOaZtdmrq90GdIQLqcRLIAbrAGExfmiK9tpn4GiTeGHJbtdhWRTcWOwt1cI0a9Ukyqi7NEAWbrAjadhdMgoGxB18ybr1(sTGinqVRcgeY(PNgCqKwcWWXGPHd41wrYYONhliQwI)wS4GP)T4qWoQPh88(3NQY2c)e4BHotpqWpv(wS4GP)T4qWoQP5iyB8BbItranoy6FlQVjwlj0H1sfoc2gRLgVhe9AdgeY(v70GdIM1c71c4Gyulvi4AFGxtcC1cIdUn0TR91ZGq2VATm4GOAHGipgT)wIaEya5VfnqVRcah1zxBKpyOamQ1uT0a9UIdb7O2iFWqbMpETMQLgO3v0JmbhaZtbyuRPAfzoaZhxfmiK9tpn4GivGKm0N1(I0ALvE1AQwAGExXHGDu3Wbz6TvZJfevR8LwRSuV)9PQCK3NaFl0z6bc(PY3Ifhm9Vfhc2rDg0FlqCkcOXbt)Br9nXAZGU20RvawlGpW5Sw2Ow4SwrscD7AbmQDMP)Teb8WaYFlAGExXHGDulA4WgvZJfev7l1sq1AQwjCaz6bQoijQb8do0SrTYVwzLxTMQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlLvlHewBRQvKoia8uCiyh1grccTBRqNPhiyTe)VpvLJSFc8TqNPhi4NkFlwCW0)wCiyh1KW5eoW53s0Wq)Bj73seWddi)TOb6DLyGCi45bDBvGS4Q1uT0a9UIdb7O2iFWqby8VpvLJC(e4BHotpqWpv(wS4GP)T4qWoQP5iyB8BbItranoy6FRxzV2hSwB8Q1iFWOwO3bMW0RfeiGUDTdG5v7d(EmQTHLG1IEcy3uBdppS2lR1gVAZEVwU25fPBxlnhbBJ1cceq3U2RbRnsdQXg1(aDW85Bjc4HbK)w0a9UkaCuNDTr(GHcWOwt1sd07QaWrD21g5dgQajzOpR9fP1YIdMUIdb7OMeoNWbovOmOa4q9bjXAnvlnqVR4qWoQnYhmuag1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1sd07koeSJ6goitVTAESGOAnvlnqVRmYhm0qVdmHPRamQ1uT0a9UIEKj4ayEkaJ)9PQCiOpb(wOZ0de8tLVfloy6FloeSJA6bpVVfiofb04GP)TEL9AFWATXRwJ8bJAHEhyctVwqGa621oaMxTp47XO2gwcwl6jGDtTn88WAVSwB8Qn79A5ANxKUDT0CeSnwliqaD7AVgS2inOgBu7d0bZhZRDM1(GVhJAtF0UwGjwl6jGDtT0dEEZAHo8G8y0U2lR1gVAVS2Ece1kA4WgNFlrapmG83IgO3vgborxG6SRjHoOcWOwt1srT0a9UIdb7Ow0WHnQMhliQ2xQLgO3vCiyh1IgoSrfjlJEESGOAjKWABvTuulnqVRmYhm0qVdmHPRamQ1uT0a9UIEKj4ayEkaJAjUwI)3NQYH6(jW3cDMEGGFQ8TyXbt)Bze4eDbQZUMe6GFlqCkcOXbt)BrGgSwACE1cmXAZETgjzTWzTxwlWeRfE1EzTTyaOGOr7APbGdWAfnCyJZAbbcOBxlBul3pmQ9AW21AJxTGaKgiyT0TR9AWAB4Gm921sZrW243seWddi)TOb6Dfhc2rTOHdBunpwquTVulnqVR4qWoQfnCyJkswg98ybr1AQwAGExXHGDuBKpyOam(3NQYHY(e4BHotpqWpv(wG4ueqJdM(3I6eR9H9R2lRDESGOAB4Gm9212bgJ2QAjqdwlWeRn71kl1R25XcIM12GbwlCw7L1Ycrc4xT9mQ9AWApOGOAhy)Qn9AVgSwrd7ooQLDWAVgSws4CchyTqV2(aA3CQVfloy6FloeSJAs4Cch48Bb9dJaW4(wY(Tenm0)wY(Teb8WaYFlAGExXHGDu3Wbz6TvZJfev7l1kl17Bb9dJaW402JKMhFlz)3NQYH69jW3cDMEGGFQ8Teb8WaYFlAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt1kHditpqfsAKpyGGAAoc2g)wS4GP)T4qWoQP5iyB8FFQkNxXNaFl0z6bc(PY3seWddi)TizNvgIR2xQvwk7BXIdM(3cLKc(GP)VpvLtl4tGVf6m9ab)u5BXIdM(3Idb7OMEWZ7BbItranoy6FRxhF0UwGjwl9GNxTxwlnaCawROHdBCwlSx7dwlpcKbBxBdlbRDMKyT9ijRnd6VLiGhgq(Brd07koeSJArdh2OAESGOAnvlnqVR4qWoQfnCyJQ5XcIQ9LAPb6Dfhc2rTOHdBurYYONhli6FFQkNw4NaFl0z6bc(PY3ceNIaACW0)wVUcog1(aVMAzYAb8boN1Yg1cN1kssOBxlGrTSdw7d(oWAh5tTPxlj783Ifhm9Vfhc2rnjCoHdC(TG(HrayCFlz)wIgg6Flz)wIaEya5VvRQLIALWbKPhO6GKOgWp4qZg1(I0ALvE1AQws2zLH4Q9LAji5vlXFlOFyeagN2EK084Bj7)(uLGK3NaFl0z6bc(PY3ceNIaACW0)wVAKD4aN1(aVMAh5tTK88WOT512aTBQTHNhAETzulDEn1sYTR1ZR2gwcwl6jGDtTKSZ1EzTtadJmUABYNAjzNRf6h6tOeS2GbHSF1on4GOAfSxlnAETZS2h89yulWeRTddSw6bpVAzhS2EKZJohxTpnOx7iFQn9AjzN)wS4GP)T6Wa10dEE)7tvcs2pb(wS4GP)T6rop6CCFl0z6bc(PY)(33sWdbWGpy6Zpb(uv2pb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFlz)wIaEya5VLeoGm9avnSeuNgOJG1kTw5vRPAncuI2waQKvHssbFW0R1uTTQwkQnaCSNHnQMqJM01Zldsf6m9abRLqcRnaCSNHnQoK0idEOF4WqHotpqWAj(BjHdTZK43QHLG60aDe8FFQkNpb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFlz)wIaEya5VLeoGm9avnSeuNgOJG1kTw5vRPAPb6Dfhc2rTr(GHcmF8AnvRiZby(4koeSJAJ8bdvGKm0N1AQwkQnaCSNHnQMqJM01Zldsf6m9abRLqcRnaCSNHnQoK0idEOF4WqHotpqWAj(BjHdTZK43QHLG60aDe8FFQsqFc8TqNPhi4NkFR04BnX7BXIdM(3schqMEGFlj8aa)wY(Teb8WaYFlAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYYONhliQwt12QAPb6DvamqD21xtG4ubyuRPA7q7Mthijd9zTViTwkQLIAjzNRLA1YIdMUIdb7OMEWZtjY5vlX12sQLfhmDfhc2rn9GNNcLbfahQpijwlXFljCODMe)wDOZdnnq4)7tvQ7NaFl0z6bc(PY3kn(wt8(wS4GP)TKWbKPh43scpaWVfnqVR4qWoQB4Gm92Q5XcIQv(sRvwkRwcjSwkQnaCSNHnQ4qWoQPtsAoajr)uOZ0deSwt1ECyJNQb5X1OmexTVulbrz1s83ceNIaACW0)wuhWRbJA5A7aJr7ANhlicbRTHdY0BxBg1c9ArzqbWH1gSBJ1(aVMAPsssZbij633schANjXVfsAKpyGGAAoc2g)3NQu2NaFl0z6bc(PY3kn(wt8(wS4GP)TKWbKPh43schANjXV1GNNMn0at8BbIDgyCFl59Teb8WaYFlAGExXHGDuBKpyOamQ1uTuuReoGm9avdEEA2qdmXALwR8QLqcR9GKyTYxATs4aY0dun45PzdnWeRLs1klLvlXFlj8aa)whKe)3NQuVpb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFlkQvK5amFCfhc2rTr(GHcei4dMETTKAPOwzRTfPwkQvEk5rq12sQvKoia8uCiyh1grccTBRc2jQwIRL4AjU2wKAPO2dsI12IuReoGm9avdEEA2qdmXAj(BbItranoy6FRwoeSJ1(QrccTBxRnucoRLRvchqMEG1YKjGF1M9AfGH51sdC1(GVhJAbMyTCT9bF1IZdsYhm9ABWav1sGgS2jKuuRrKsGGiyTbsYqFQrzmqXHG1IYye4CctVwWeN165v7tgev7dog12ZOwJibH2TRfeaR9YAVgSwAGyETR15diWAZETxdwRamuFljCODMe)w48GK8HGA2qlYCaMp()(u9v8jW3cDMEGGFQ8TsJV1eVVfloy6FljCaz6b(TKWda8BjHditpqfopijFiOMn0ImhG5J)Teb8WaYFlr6GaWtXHGDuBeji0U93schANjXV1bjrnGFWHMn(3NQTGpb(wOZ0de8tLVvA8TM49TyXbt)BjHditpWVLeEaGFlrMdW8XvCiyh1g5dgQajzOp)wIaEya5VvRQvKoia8uCiyh1grccTBRqNPhi43schANjXV1bjrnGFWHMn(3NQTWpb(wOZ0de8tLVvA8Tizz(wS4GP)TKWbKPh43schANjXV1bjrnGFWHMn(wIaEya5Vff1kYCaMpU6sarJo76Rb1KSnufijd9zTTi1kHditpq1bjrnGFWHMnQL4AFPw5iVVfiofb04GP)TOoX3JrTG4GBxBl)Q1cyu7L1kh5nrrT9mQLa51s)ws4ba(TezoaZhxDjGOrND91GAs2gQcKKH(8FFQkR8(e4BHotpqWpv(wPX3IKL5BXIdM(3schqMEGFljCODMe)whKe1a(bhA24Bjc4HbK)wI0bbGNIdb7O2isqOD7AnvRiDqa4P4qWoQnIeeA3wfStuTVulLvRPAXwma0WabvZeymW7GUToaOBxRPAfPe0z)ue1oGSxRPAdah7zyJkoeSJ6goitVTcDMEGGFlqCkcOXbt)BzbDbw7RhGUDTWzTtartTCTg5dgDGrTxaDIWR2Eg1(662bKDZR9bFpg1opOGOAVS2RbR9EYAjHoWH1kAlgyTa(bh1(G1AJxTCTnq7MArpbSBQnyNOAZETgrccTB)TKWda8BjYCaMpUAMaJbEh0T1baDBvGKm0N)7tvzL9tGVf6m9ab)u5BLgFRjEFlwCW0)ws4aY0d8BjHha43sK5amFC1LaIgD21xdQjzBOkqgSDTMQvchqMEGQdsIAa)GdnBu7l1kh59TaXPiGghm9Vf1j(EmQfehC7AjqET0AbmQ9YALJ8MOO2Eg12YV63schANjXVvtoaHUT(YJ8FFQkRC(e4BHotpqWpv(wPX3AI33Ifhm9VLeoGm9a)ws4ba(TOOwJaLOTfGkzvbdcz)0tdoiQwcjSwJaLOTfGk5OcgeY(PNgCquTesyTgbkrBlaveKkyqi7NEAWbr1sCTMQLfhmDvWGq2p90GdIuhKe1tOlWAFPwBbOIKLP2wsTu3Vfiofb04GP)TE9miK9RwldoiQwWeN165vlKKebH8HJ21AaC1cyu71G1kby4yW0Wb8Axlisd071oZAHxTc2RLgRfe27qbW4Q9YAbHtbgETxdF1(GVdSw(Q9AWAP(HrEn1kby4yW0Wb8Ax78ybrFljCODMe)wTOaZtdmrq90GdI(3NQYsqFc8TqNPhi4NkFR04BnX7BXIdM(3schqMEGFlj8aa)w0a9UIdb7O2iFWqbMpETMQLgO3vbGJ6SRnYhmuG5JxRPAbrAGExDjGOrND91GAs2gQaZhVwt12QALWbKPhOQffyEAGjcQNgCquTMQfePb6DvWGq2p90GdI0sagogmnCaV2kW8X)ws4q7mj(TsGBcbrD21ImhG5Jp)3NQYsD)e4BHotpqWpv(wPX3AI33Ifhm9VLeoGm9a)ws4ba(Tcah7zyJkoeSJ6goitVTcDMEGG1AQwkQLIAfPe0z)ue1oGSxRPAfzoaZhxfmiK9tpn4GivGKm0N1(sTs4aY0du1Wbz6T1ZJfePpijwlX1s83schANjXV18ybr6goitV9)(33QdDEOPbc)tGpvL9tGVf6m9ab)u5BXIdM(3Idb7OMeoNWbo)wIgg6Flz)wIaEya5VfnqVRedKdbppOBRcKf3)(uvoFc8TyXbt)BXHGDutp459TqNPhi4Nk)7tvc6tGVfloy6FloeSJAAoc2g)wOZ0de8tL)9V)9TKGXeM(NQYrEYrw51cKdbPK9B9WHdD753I6SLF9u9vs1x3uET1sGgSwiPrgxT9mQ9DdhKP3(DTb2IbGbcw7mjXAzGlj5dbRv0WUnovLzem0XALLYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XAPmkV2wNUemoeS23xaDIWtX0cLiZby(4VR9YAFlYCaMpUIPfVRLczLHyvzgbdDSwQhLxBRtxcghcw77lGor4PyAHsK5amF831EzTVfzoaZhxX0I31sHSYqSQmJGHowBlGYRT1PlbJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6bc(UwkKvgIvLzem0XALvouETToDjyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSYqSQmJGHowRSeeLxBRtxcghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRmeRkZiyOJ1kl1LYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XALL6s51260LGXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkdXQYmcg6yTYrEuETToDjyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSYqSQmRmJ6SLF9u9vs1x3uET1sGgSwiPrgxT9mQ9DhoBGUTonqhJ31gylgagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLc5idXQYmcg6yTYHYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XAjikV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwQlLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowlLr51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1s9O8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(Uw(QL641HGRLczLHyvzgbdDS2wiLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowBlKYRT1PlbJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6bc(Uw(QL641HGRLczLHyvzgbdDSwzLdLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHCKHyvzgbdDSwzPmkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwzBbuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTY2cP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALJSuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSYqSQmJGHowRCOUuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYrgIvLzem0XALd1LYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47A5RwQJxhcUwkKvgIvLzem0XALd1JYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47A5RwQJxhcUwkKvgIvLzem0XALZRGYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzLzuNT8RNQVsQ(6MYRTwc0G1cjnY4QTNrTVJ84dM(7AdSfdadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1klLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZiyOJ1klLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowRCO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XAjikV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwkJYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XAPEuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSYqSQmJGHowRSYJYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XALTfs51260LGXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkdXQYmcg6yTY2cP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALJ8O8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLHyvzgbdDSw5ipkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw5ilLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZiyOJ1khzP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALJCO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALdbr51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZkZOoB5xpvFLu91nLxBTeObRfsAKXvBpJAFNgOJX7AdSfdadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1klLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowRCO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALLGO8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLczLHyvzgbdDSwzPEuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlF1sD86qW1sHSYqSQmJGHowRSVckV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLVAPoEDi4APqwziwvMrWqhRv2waLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZkZOoB5xpvFLu91nLxBTeObRfsAKXvBpJAFdIDgyCVRnWwmamqWANjjwldCjjFiyTIg2TXPQmJGHowRCO8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLc5idXQYmcg6yTuxkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwzPUuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTYs9O8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALTfq51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1kh5r51260LGXHG1AbjBDTZ2(XYul1)Q9YAjyaUwqOe4eMETPbg8LrTuqnIRLczLHyvzgbdDSw5ipkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw5qquETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlF1sD86qW1sHSYqSQmJGHowRCOUuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTYHYO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALd1JYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRvoVckV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw50cO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzLzuNT8RNQVsQ(6MYRTwc0G1cjnY4QTNrTVncuKK089U2aBXaWabRDMKyTmWLK8HG1kAy3gNQYmcg6yTupkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwQhLxBRtxcghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRmeRkZiyOJ1kh5r51260LGXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkdXQYmcg6yTYrwkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw5ilLxBRtxcghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRmeRkZiyOJ1kh5q51260LGXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkdXQYmcg6yTYPfs51260LGXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYrgIvLzem0XALtlKYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRLGKdLxBRtxcghcw77zcmOHoOsUVR9YAFptGbn0bvYvHotpqW31sHSYqSQmJGHowlbjhkV2wNUemoeS23ZeyqdDqLCFx7L1(EMadAOdQKRcDMEGGVRLVAPoEDi4APqwziwvMrWqhRLGiikV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwcIGO8ABD6sW4qWAFlsheaEk5(U2lR9TiDqa4PKRcDMEGGVRLczLHyvzgbdDSwcI6s51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DT8vl1XRdbxlfYkdXQYmcg6yTeeLr51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1squpkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzwzg1zl)6P6RKQVUP8ARLanyTqsJmUA7zu7BrMdW8XNVRnWwmamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHCKHyvzgbdDSwzP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALdLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuihziwvMrWqhRvouETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTeeLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuihziwvMrWqhRLGO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XAPUuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTugLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowl1JYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJmeRkZiyOJ1(kO8ABD6sW4qWAFptGbn0bvY9DTxw77zcmOHoOsUk0z6bc(UwkKJmeRkZiyOJ12cP8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLc5idXQYmcg6yTYkpkV2wNUemoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqoYqSQmJGHowRSYHYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJmeRkZiyOJ1klbr51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1kl1LYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRvwkJYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XALL6r51260LGXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkdXQYmcg6yTYrEuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSYqSQmRmJ6SLF9u9vs1x3uET1sGgSwiPrgxT9mQ9nN47AdSfdadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1klLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuihziwvMrWqhRvwkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw5q51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuihziwvMrWqhRLGO8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLc5idXQYmcg6yTeeLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowl1LYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRLYO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XAPEuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSYqSQmJGHow7RGYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRTfq51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ12cP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALvEuETToDjyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHCKHyvzgbdDSwzLLYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRvw5q51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1klbr51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRmeRkZiyOJ1kl1LYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJmeRkZiyOJ1k7RGYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJmeRkZiyOJ1kBlGYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJmeRkZiyOJ1khzP8ABD6sW4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLVAPoEDi4APqwziwvMrWqhRvoYHYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRvoeeLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowRCOUuETToDjyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkdXQYmcg6yTYHYO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALd1JYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRvoVckV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSw50cO8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XALtlKYRT1PlbJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvgIvLzem0XALtlKYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRLGKhLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZiyOJ1sqYJYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRLGKdLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSYqSQmJGHowlbrDP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzem0XAjiQhLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZiyOJ1squpkV2wNUemoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLHyvzgbdDSwc6vq51260LGXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYrgIvLzem0XAjOwaLxBRtxcghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRmeRkZkZOoB5xpvFLu91nLxBTeObRfsAKXvBpJAFl4HayWhm957AdSfdadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1klLxBRtxcghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHCKHyvzgbdDSw5q51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuihziwvMrWqhRLGO8ABD6sW4qWATGKTU2zB)yzQL6F1EzTemaxliucCctV20ad(YOwkOgX1sHSYqSQmJGHowl1LYRT1PlbJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwziwvMrWqhRTfq51260LGXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlF1sD86qW1sHSYqSQmJGHowRSYJYRT1PlbJdbR99fqNi8umTqjYCaMp(7AVS23ImhG5JRyAX7APqwziwvMrWqhRvw5r51260LGXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DT8vl1XRdbxlfYkdXQYmcg6yTYsDP8ABD6sW4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvgIvLzLzVssJmoeSwzLxTS4GPx7aoVPQm7BzezhoWV1R9A12szBS2woeSJLzV2RvBldydmVALdbzETYrEYr2YSYSx71QT1nSBJtkVm71ETABrQL6BI1ETnGcEuRfKS112Wo4a621M9AfnS74OwOFyeaghm9AH(8qgS2Sx7Bb7cCOzXbt)TQm71ETABrQT1nSBJ1YHGDud9o0Hx7AVSwoeSJ6goitVDTuaVADucg1(G(v7akbRLN1YHGDu3Wbz6TjwvM9AVwTTi1(6s6VVAPoKKc(WAHETT8Rd1rTTOaZRwAuWatS22jW7aRnbUAZETb72yTSdwRNxTatOBxBlhc2XAPoKXyKty6QYSYmwCW0NkJafjjnFusk14qWoQH(HJbkUYmwCW0NkJafjjnFusk14qWoQ7mjCa5OmJfhm9PYiqrssZhLKsnr6TOabQjzN12izzgloy6tLrGIKKMpkjLAs4aY0d0CNjrPCI6JdB80IeWpZtdPboXZCqSZaJtkbvMXIdM(uzeOijP5JssPMeoGm9an3zsukkj1gIZ80qAGt8mhe7mW4KklLvMXIdM(uzeOijP5JssPMeoGm9an3zsuQrGgaJHgLKMNgsN4zoSlLIaWXEg2OAcnAsxpVminrHiLGo7Nsc6xt7GqcfPe0z)uokICKbiHeksheaEkoeSJAJibH2TjMyZLWdauQSMlHhaOghtuQ8kZyXbtFQmcuKK08rjPutchqMEGM7mjkTHLG60aDe080q6epZHDPS4Gsqn6ijeNYxQeoGm9avCI6JdB80IeWpZLWdauQSMlHhaOghtuQ8kZyXbtFQmcuKK08rjPutchqMEGM7mjkTdDEOPbc380q6epZLWdauQ8kZyXbtFQmcuKK08rjPutchqMEGM7mjkTHdY0BRNhlisFqs080qAGt8mhe7mW4K2clZyXbtFQmcuKK08rjPutchqMEGM7mjkLhpC7PE22fArMdW8XNMNgsdCIN5GyNbgNu5vMXIdM(uzeOijP5JssPMeoGm9an3zsuAm1KSmAqCWT19m0xEKMNgsdCIN5GyNbgNukRmJfhm9PYiqrssZhLKsnjCaz6bAUZKO0yQjzz0G4GBR7zOJ0W80qAGt8mhe7mW4KszLzS4GPpvgbkssA(OKuQjHditpqZDMeLgtnjlJgehCBDpdnByEAinWjEMdIDgyCsLJ8kZyXbtFQmcuKK08rjPutchqMEGM7mjkLmpTrGceb1xEKA62MNgsdCIN5GyNbgN0wqzgloy6tLrGIKKMpkjLAs4aY0d0CNjrPK5Pjzz0G4GBR7zOV8inpnKg4epZbXodmoPYkVYmwCW0NkJafjjnFusk1KWbKPhO5otIsjZttYYObXb3w3ZqZgMNgsdCIN5GyNbgNuzPSYmwCW0NkJafjjnFusk1KWbKPhO5otIszdnjlJgehCBDpd9LhP5PH0aN4zoSlvKoia8uCiyh1grccTBBUeEaGsji5zUeEaGACmrPYkVYmwCW0NkJafjjnFusk1KWbKPhO5otIszdnjlJgehCBDpd9LhP5PH0aN4zoi2zGXjvoYRmJfhm9PYiqrssZhLKsnjCaz6bAUZKOu2qtYYObXb3w3ZqtMN5PH0aN4zoi2zGXjvoYRmJfhm9PYiqrssZhLKsnjCaz6bAUZKO0in0KSmAqCWT19m0xEKMNgsN4zUeEaGsLJ8ArOGYAjI0bbGNIdb7O2isqODBIlZyXbtFQmcuKK08rjPutchqMEGM7mjk9YJutYYObXb3w3ZqZgMNgsN4zUeEaGsPmkjh51sOqKsqN9t5q7Mt3zKqcPqKoia8uCiyh1grccTBBIfhucQrhjH48fjCaz6bQ4e1hh24PfjGFetmLKLYAjuisjOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TnXIdkb1OJKqCkFPs4aY0duXjQpoSXtlsa)iUmJfhm9PYiqrssZhLKsnjCaz6bAUZKO0lpsnjlJgehCBDpdDKgMNgsN4zUeEaGsLJ8ArOOf0sePdcapfhc2rTrKGq72exMXIdM(uzeOijP5JssPMeoGm9an3zsuknhbBJAs2zTH4mpnKoXZCyxQiLGo7NYH2nNUZO5s4bakL6jVweki55HrBTeEaGTezLN8iUmJfhm9PYiqrssZhLKsnjCaz6bAUZKOuAoc2g1KSZAdXzEAiDIN5WUurkbD2pfrTdi7MlHhaO0wiL1IqbjppmARLWdaSLiR8KhXLzS4GPpvgbkssA(OKuQjHditpqZDMeLsZrW2OMKDwBioZtdPt8mh2LkHditpqfnhbBJAs2zTH4KkpZLWdauAlqETiuqYZdJ2Aj8aaBjYkp5rCzgloy6tLrGIKKMpkjLAs4aY0d0CNjrPSHMe6qsasnj7S2qCMNgsdCIN5GyNbgNuzPSYmwCW0NkJafjjnFusk1KWbKPhO5otIsV8i1KSmArdh24080qAGt8mhe7mW4KkNYmwCW0NkJafjjnFusk1KWbKPhO5otIs5e1xEKAswgTOHdBCAEAinWjEMdIDgyCsLtzgloy6tLrGIKKMpkjLAs4aY0d0CNjrPD4Sb6260aDmmpnKoXZCj8aaLkBlHcSfdanmqqfsA0oqEOZa0zxGesifhpq)ubGJ6SRnYhmmrXXd0pfhc2rnkAscjSvIuc6SFkIAhq2j2efTsKsqN9t5OiYrgGesiloOeuJoscXPuzjKWaWXEg2OAcnAsxpVmij2uRePe0z)usq)AAhetCzgloy6tLrGIKKMpkjLAs4aY0d0CNjrPSHoDnWenpnKoXZCj8aaLITyaOHbcQizbthOE2G4PjbMqbHeITyaOHbcQShmiKVmMAAg0gjKqSfdanmqqL9GbH8LXutIG8yatNqcXwma0WabvGCqezMUgefePnaUaNc0fiHeITyaOHbcQG(ueahtpqDlgG9dGudIsGcKqcXwma0WabvZeymW7GUToaOBtiHylgaAyGGQjGtpYeuZK410EEesi2IbGggiO6HjcDmM6EKoiHeITyaOHbcQ6dMe1zxtZ3nWYmwCW0NkJafjjnFusk1iHrKHgsY2yzgloy6tLrGIKKMpkjLA9boBeb3pZHDPZeyqdDqLKCWhCG6zoKG(riHZeyqdDqLbW8agOgdaJdMEzgloy6tLrGIKKMpkjLAbGJ6SRnYhmmh2LksjOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TnjsheaEkoeSJAJibH2TnjHditpqfpE42t9STl0ImhG5JpnXIdkb1OJKqC(IeoGm9avCI6JdB80IeWVYmwCW0NkJafjjnFusk16rop6CCMd7sBLeoGm9avgbAamgAuskvwtbGJ9mSrfiCkGgdOZrBTijjzhSmJfhm9PYiqrssZhLKsnoeSJA6bppZHDPTschqMEGkJanagdnkjLkRPwfao2ZWgvGWPaAmGohT1IKKKDqtu0krkbD2pLe0VM2bHekHditpqvhoBGUTonqhdIlZyXbtFQmcuKK08rjPuJegrgtD21xgKOFMd7sBLeoGm9avgbAamgAuskvwtTkaCSNHnQaHtb0yaDoARfjjj7GMePe0z)usq)AAhMALeoGm9avD4Sb6260aDmkZyXbtFQmcuKK08rjPudLKc(GPBoSlvchqMEGkJanagdnkjLkBzwzgloy6tkjLAIeWpmMg4yuMXIdM(KssPgWe1KSZABK0Cyxkfhpq)uOpG2nh6iOjs2zLH4ErAlqEMizNvgIt(sPEugXesifT64b6Nc9b0U5qhbnrYoRme3lsBbugXLzS4GPpPKuQzKhmDZHDP0a9UIdb7O2iFWqbyuMXIdM(KssP2bjr9dhgMd7sdah7zyJQdjnYGh6hommrd07kuMggyEW0vagMOqK5amFCfhc2rTr(GHkqgSnHesNZPPo0U50bsYqF(IuQR8iUmJfhm9jLKsTb0U5M6wuaqBs0pZHDP0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFsjPuJMT1zxFbuq00CyxknqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmuG5JBcePb6D1LaIgD21xdQjzBOcmF8YmwCW0Nusk1OXyIbrq32CyxknqVR4qWoQnYhmuagLzS4GPpPKuQrpYeu3bI2Md7sPb6Dfhc2rTr(GHcWOmJfhm9jLKsTomq6rMGMd7sPb6Dfhc2rTr(GHcWOmJfhm9jLKsn2f48cEOf8yyoSlLgO3vCiyh1g5dgkaJYmwCW0Nusk1aMOgEi50CyxknqVR4qWoQnYhmuagLzS4GPpPKuQbmrn8qsZXEhfN2zsuQ9GbH8LXutZG2O5WUuAGExXHGDuBKpyOamiKqrMdW8XvCiyh1g5dgQajzOpLVukJYmbI0a9U6sarJo76Rb1KSnubyuMXIdM(KssPgWe1Wdjn3zsuksA0oqEOZa0zxGMd7sfzoaZhxXHGDuBKpyOcKKH(8fPYszMezoaZhxDjGOrND91GAs2gQcKKH(8fPYszLzS4GPpPKuQbmrn8qsZDMeLcgid2HbQLGZjomh2LkYCaMpUIdb7O2iFWqfijd9P8Lkh5riHTschqMEGk2qNUgyIsLLqcP4GKOu5zschqMEGQoC2aDBDAGogsL1ua4ypdBunHgnPRNxgKexMXIdM(KssPgWe1Wdjn3zsu6mbgAOTdpmmh2LkYCaMpUIdb7O2iFWqfijd9P8LsqYJqcBLeoGm9avSHoDnWeLkBzgloy6tkjLAatudpK0CNjrP2J2gn6SR55esch8bt3CyxQiZby(4koeSJAJ8bdvGKm0NYxQCKhHe2kjCaz6bQydD6AGjkvwcjKIdsIsLNjjCaz6bQ6Wzd0T1Pb6yivwtbGJ9mSr1eA0KUEEzqsCzgloy6tkjLAatudpK0CNjrPKSGPdupBq80KatOWCyxQiZby(4koeSJAJ8bdvGKm0NViLYmrrRKWbKPhOQdNnq3wNgOJHuzjKWdsIYNGKhXLzS4GPpPKuQbmrn8qsZDMeLsYcMoq9SbXttcmHcZHDPImhG5JR4qWoQnYhmubsYqF(IukZKeoGm9avD4Sb6260aDmKkRjAGExfaoQZU2iFWqbyyIgO3vbGJ6SRnYhmubsYqF(IukKvETiuwljaCSNHnQMqJM01ZldsInDqs8fcsELzS4GPpPKuQbmrn8qsZDMeLoByW8bb1zqRZU(YGe9ZCyx6bjrPYJqcPqchqMEGQe4MqquNDTiZby(4ttuqHiLGo7NIO2bKDtImhG5JRcgeY(PNgCqKkqsg6ZxKkhtImhG5JR4qWoQnYhmubsYqF(IukZKiZby(4Qlben6SRVgutY2qvGKm0NViLYiMqcfzoaZhxXHGDuBKpyOcKKH(8fPYHqc7q7Mthijd95lImhG5JR4qWoQnYhmubsYqFsmXLzVwTuMI6vlCw71G1onqeS2Sx71G1ALaJbEh0TR91dq3UwJiBrrXbhyzgloy6tkjLAatudpK0CNjrPZeymW7GUToaOBBoSlLcjCaz6bQoijQb8do0SbLOGfhmDvWGq2p90GdIuOmOa4q9bjXwIiLGo7NIO2bKDIPefS4GPRar(AOZWrfkdkaouFqsSLisjOZ(PCue5idqIPeloy6Qlben6SRVgutY2qfkdkaouFqs8LJdB8uGW5XUaP(hLPOEeBIcjCaz6bQAyjOonqhbjKqkePe0z)ue1oGSBkaCSNHnQ4qWoQHEh6WRnXeB64WgpfiCESlq5lhkRm71ETAzXbtFsjPuZXNEc4G6aN5qcAoWe1pnWbQf88GUTuznh2Lsd07koeSJAJ8bdfGbHecI0a9U6sarJo76Rb1KSnubyqiHG5PcgeY(PNgCqK6GcIGUDzgloy6tkjLAcEm0S4GPRhW5zUZKOubpead(GPplZyXbtFsjPutWJHMfhmD9aopZDMeLYjA(8cO4KkR5WUuwCqjOgDKeIt5lvchqMEGkor9XHnEArc4xzgloy6tkjLAcEm0S4GPRhW5zUZKO0goitVT5WUurkbD2pfrTdi7Mcah7zyJkoeSJ6goitVDzgloy6tkjLAcEm0S4GPRhW5zUZKO0oC2aDBDAGogMd7sLWbKPhOQHLG60aDeuQ8mjHditpqvhoBGUTonqhdtTIcrkbD2pfrTdi7Mcah7zyJkoeSJ6goitVnXLzS4GPpPKuQj4XqZIdMUEaNN5otIstd0XWCyxQeoGm9avnSeuNgOJGsLNPwrHiLGo7NIO2bKDtbGJ9mSrfhc2rDdhKP3M4YmwCW0Nusk1e8yOzXbtxpGZZCNjrPImhG5Jpnh2L2kkePe0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92exMXIdM(KssPMGhdnloy66bCEM7mjknYJpy6Md7sLWbKPhOQdDEOPbcxQ8m1kkePe0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92exMXIdM(KssPMGhdnloy66bCEM7mjkTdDEOPbc3CyxQeoGm9avDOZdnnq4sL1uROqKsqN9tru7aYUPaWXEg2OIdb7OUHdY0BtCzwzgloy6tfNO0EKZJohN5WU0aWXEg2OceofqJb05OTwKKKSdAsK5amFCfnqVRbHtb0yaDoARfjjj7GQazW2MOb6DfiCkGgdOZrBTijjzhu3JCEkW8XnrbnqVR4qWoQnYhmuG5JBIgO3vbGJ6SRnYhmuG5JBcePb6D1LaIgD21xdQjzBOcmFCInjYCaMpU6sarJo76Rb1KSnufijd9Pu5zIcAGExXHGDulA4WgvZJfe9IujCaz6bQ4e1xEKAswgTOHdBCAIckoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NVi1waAsK5amFCfhc2rTr(GHkqsg6t5lHditpq1LhPMKLrdIdUTUNHMniMqcPOvhpq)ubGJ6SRnYhmmjYCaMpUIdb7O2iFWqfijd9P8LWbKPhO6YJutYYObXb3w3ZqZgetiHImhG5JR4qWoQnYhmubsYqF(IuBbiXexMXIdM(uXjsjPuRddutp45zoSlLIaWXEg2OceofqJb05OTwKKKSdAsK5amFCfnqVRbHtb0yaDoARfjjj7GQazW2MOb6DfiCkGgdOZrBTijjzhu3HbQaZh3KrGs02cqLSQEKZJohhXesifbGJ9mSrfiCkGgdOZrBTijjzh00bjrPYJ4YmwCW0NkorkjLA9iNN2tjS5WU0aWXEg2OYoGZrBnuafd0KiZby(4koeSJAJ8bdvGKm0NYNGKNjrMdW8XvxciA0zxFnOMKTHQajzOpLkptuqd07koeSJArdh2OAESGOxKkHditpqfNO(YJutYYOfnCyJttuqXXd0pva4Oo7AJ8bdtImhG5JRcah1zxBKpyOcKKH(8fP2cqtImhG5JR4qWoQnYhmubsYqFkFjCaz6bQU8i1KSmAqCWT19m0SbXesifT64b6NkaCuNDTr(GHjrMdW8XvCiyh1g5dgQajzOpLVeoGm9avxEKAswgnio426EgA2GycjuK5amFCfhc2rTr(GHkqsg6ZxKAlajM4YmwCW0NkorkjLA9iNN2tjS5WU0aWXEg2OYoGZrBnuafd0KiZby(4koeSJAJ8bdvGKm0NsLNjkOGcrMdW8XvxciA0zxFnOMKTHQajzOpLVeoGm9avSHMKLrdIdUTUNH(YJ0enqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwqeXesifImhG5JRUeq0OZU(AqnjBdvbsYqFkvEMOb6Dfhc2rTOHdBunpwq0lsLWbKPhOItuF5rQjzz0IgoSXjXeBIgO3vbGJ6SRnYhmuG5JtCzgloy6tfNiLKsnoeSJAs4Cch40CyxQiLGo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQB4Gm92Q5XcIErwkZKiZby(4QGbHSF6PbhePcKKH(8fPs4aY0du1Wbz6T1ZJfePpijsjuguaCO(GKOjrMdW8XvxciA0zxFnOMKTHQajzOpFrQeoGm9avnCqMEB98ybr6dsIucLbfahQpijsjwCW0vbdcz)0tdoisHYGcGd1hKenjYCaMpUIdb7O2iFWqfijd95lsLWbKPhOQHdY0BRNhlisFqsKsOmOa4q9bjrkXIdMUkyqi7NEAWbrkuguaCO(GKiLyXbtxDjGOrND91GAs2gQqzqbWH6dsIMlAyOlv2YmwCW0NkorkjLACiyh10dEEMd7sfPe0z)usq)AAhMoEG(P4qWoQrrtA6GK4lYkptImhG5JRiHrKXuND9Lbj6Nkqsg6tt0a9Usmqoe88GUTAESGOxiOYmwCW0NkorkjLAatudpK0CNjrPZeymW7GUToaOBBoSlnaCSNHnQMqJM01ZldstgbkrBlavYQqjPGpy6LzS4GPpvCIusk1Ueq0OZU(AqnjBdnh2Lgao2ZWgvtOrt665LbPjJaLOTfGkzvOKuWhm9YmwCW0NkorkjLACiyh1g5dgMd7sdah7zyJQj0OjD98YG0efgbkrBlavYQqjPGpy6esOrGs02cqLSQlben6SRVgutY2qIlZyXbtFQ4ePKuQrcJiJPo76lds0pZHDPImhG5JR4qWoQnYhmubsYqF(I0wGjrMdW8XvxciA0zxFnOMKTHQajzOpFrAlWef0a9UIdb7Ow0WHnQMhli6fPs4aY0duXjQV8i1KSmArdh240efuC8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrQTa0KiZby(4koeSJAJ8bdvGKm0NYNYiMqcPOvhpq)ubGJ6SRnYhmmjYCaMpUIdb7O2iFWqfijd9P8PmIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaKyIlZyXbtFQ4ePKuQHssbFW0nh2LEqsu(eK8mfao2ZWgvtOrt665LbPjrkbD2pLe0VM2HjJaLOTfGkzvKWiYyQZU(YGe9RmJfhm9PItKssPgkjf8bt3Cyx6bjr5tqYZua4ypdBunHgnPRNxgKMOb6Dfhc2rTOHdBunpwq0lsLWbKPhOItuF5rQjzz0IgoSXPjrMdW8XvxciA0zxFnOMKTHQajzOpLkptImhG5JR4qWoQnYhmubsYqF(IuBbyzgloy6tfNiLKsnusk4dMU5WU0dsIYNGKNPaWXEg2OAcnAsxpVminjYCaMpUIdb7O2iFWqfijd9Pu5zIckOqK5amFC1LaIgD21xdQjzBOkqsg6t5lHditpqfBOjzz0G4GBR7zOV8inrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfe9IujCaz6bQ4e1xEKAswgTOHdBCsmXMOb6Dva4Oo7AJ8bdfy(4eBo0pmcaJtd7sPb6D1eA0KUEEzqQMhlisknqVRMqJM01ZldsfjlJEESGiZH(HrayCAijjcc5dLkBzgloy6tfNiLKsTGbHSF6PbhezoSlvK5amFC1LaIgD21xdQjzBOkqsg6ZxqzqbWH6dsIMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(s4aY0duD5rQjzz0G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFjCaz6bQU8i1KSmAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasCzgloy6tfNiLKsTGbHSF6PbhezoSlvK5amFCfhc2rTr(GHkqsg6ZxqzqbWH6dsIMOGckezoaZhxDjGOrND91GAs2gQcKKH(u(s4aY0duXgAswgnio426Eg6lpst0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybretiHuiYCaMpU6sarJo76Rb1KSnufijd9Pu5zIgO3vCiyh1IgoSr18ybrVivchqMEGkor9LhPMKLrlA4WgNetSjAGExfaoQZU2iFWqbMpoXLzS4GPpvCIusk1ar(AOZWrZHDPImhG5JR4qWoQnYhmubsYqFkvEMOGckezoaZhxDjGOrND91GAs2gQcKKH(u(s4aY0duXgAswgnio426Eg6lpst0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybretiHuiYCaMpU6sarJo76Rb1KSnufijd9Pu5zIgO3vCiyh1IgoSr18ybrVivchqMEGkor9LhPMKLrlA4WgNetSjAGExfaoQZU2iFWqbMpoXLzS4GPpvCIusk1aMOgEiP5otIsNjWyG3bDBDaq32Cyxkf0a9UIdb7Ow0WHnQMhli6fPs4aY0duXjQV8i1KSmArdh24KqcncuI2waQKvfmiK9tpn4GiInrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8LWbKPhO6YJutYYObXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(s4aY0duD5rQjzz0G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaK4YmwCW0NkorkjLAxciA0zxFnOMKTHMd7sPGgO3vCiyh1IgoSr18ybrVivchqMEGkor9LhPMKLrlA4WgNesOrGs02cqLSQGbHSF6PbherSjkO44b6NkaCuNDTr(GHjrMdW8XvbGJ6SRnYhmubsYqF(IuBbOjrMdW8XvCiyh1g5dgQajzOpLVeoGm9avxEKAswgnio426EgA2GycjKIwD8a9tfaoQZU2iFWWKiZby(4koeSJAJ8bdvGKm0NYxchqMEGQlpsnjlJgehCBDpdnBqmHekYCaMpUIdb7O2iFWqfijd95lsTfGexMXIdM(uXjsjPuJdb7O2iFWWCyxkfuiYCaMpU6sarJo76Rb1KSnufijd9P8LWbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYZenqVR4qWoQfnCyJQ5XcIErQeoGm9avCI6lpsnjlJw0WHnojMyt0a9UkaCuNDTr(GHcmF8YmwCW0NkorkjLAbGJ6SRnYhmmh2Lsd07QaWrD21g5dgkW8XnrbfImhG5JRUeq0OZU(AqnjBdvbsYqFkF5ipt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybretiHuiYCaMpU6sarJo76Rb1KSnufijd9Pu5zIgO3vCiyh1IgoSr18ybrVivchqMEGkor9LhPMKLrlA4WgNetSjkezoaZhxXHGDuBKpyOcKKH(u(YkhcjeePb6D1LaIgD21xdQjzBOcWG4YmwCW0NkorkjLAZgy)GUT2iFWWCyxQiZby(4koeSJ6mOvbsYqFkFkJqcB1Xd0pfhc2rDg0LzS4GPpvCIusk14qWoQPh88mh2LksjOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0tdoislby4yW0Wb8ARMhlisk11KrGs02cqLSkoeSJ6mOnXIdkb1OJKqC(YROmJfhm9PItKssPghc2rnnhbBJMd7sfPe0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92MOb6Dfhc2rTr(GHcWWeisd07QGbHSF6PbhePLamCmyA4aETvZJfejL6wMXIdM(uXjsjPuJdb7OMEWZZCyxQiLGo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMOampvWGq2p90GdIubsYqFkFQhHecI0a9Ukyqi7NEAWbrAjadhdMgoGxBfGbXMarAGExfmiK9tpn4GiTeGHJbtdhWRTAESGOxOUMyXbLGA0rsioLsqLzS4GPpvCIusk14qWoQZG2CyxQiLGo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMarAGExfmiK9tpn4GiTeGHJbtdhWRTAESGiPeuzgloy6tfNiLKsnoeSJAAoc2gnh2LksjOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjqKgO3vbdcz)0tdoislby4yW0Wb8ARMhlisQCkZyXbtFQ4ePKuQXHGDuJYymYjmDZHDPIuc6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyyYiqjABbOsoQGbHSF6PbhezIfhucQrhjH4u(euzgloy6tfNiLKsnoeSJAugJroHPBoSlvKsqN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqKwcWWXGPHd41wnpwqKuznXIdkb1OJKqCkFcQmJfhm9PItKssPMrGt0fOo7AsOdAoSlLgO3vGiFn0z4OcWWeisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFrknqVRmcCIUa1zxtcDqfjlJEESGOwcloy6koeSJA6bppfkdkaouFqs0efuC8a9tf4mD2fOjwCqjOgDKeIZxOUetiHS4Gsqn6ijeNVqzeBIIwfao2ZWgvCiyh10jjnhGKOFes4XHnEQgKhxJYqCYNGOmIlZyXbtFQ4ePKuQXHGDutp45zoSlLgO3vGiFn0z4OcWWefuC8a9tf4mD2fOjwCqjOgDKeIZxOUetiHS4Gsqn6ijeNVqzeBIIwfao2ZWgvCiyh10jjnhGKOFes4XHnEQgKhxJYqCYNGOmIlZyXbtFQ4ePKuQnbmWWtjCzgloy6tfNiLKsnoeSJAAoc2gnh2Lsd07koeSJArdh2OAESGi5lLcwCqjOgDKeIZwezj2ua4ypdBuXHGDutNK0CasI(z64WgpvdYJRrziUxiikRmJfhm9PItKssPghc2rnnhbBJMd7sPb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIkZyXbtFQ4ePKuQXHGDuNbT5WUuAGExXHGDulA4WgvZJfejvEMOqK5amFCfhc2rTr(GHkqsg6t5llLriHTIcrkbD2pfrTdi7Mcah7zyJkoeSJ6goitVnXexMXIdM(uXjsjPuZXRbd9HKg48mh2LsrG9aNnm9ajKWwDqbrq3Myt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrLzS4GPpvCIusk14qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMcah7zyJkoeSJ6goitVTjkO44b6NIjngWouWhmDtS4Gsqn6ijeNV0ciMqczXbLGA0rsioFHYiUmJfhm9PItKssPghc2rnjCoHdCAoSlLgO3vIbYHGNh0TvbYIZ0Xd0pfhc2rnkAstGinqVRUeq0OZU(AqnjBdvagMO44b6NIjngWouWhmDcjKfhucQrhjH48LwiXLzS4GPpvCIusk14qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMoEG(PysJbSdf8bt3eloOeuJoscX5lu3YmwCW0NkorkjLACiyh1OmgJCct3CyxknqVR4qWoQfnCyJQ5XcIEHgO3vCiyh1IgoSrfjlJEESGOYmwCW0NkorkjLACiyh1OmgJCct3CyxknqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwqKjJaLOTfGkzvCiyh10CeSnwM9AVwTS4GPpvCIusk1qjPGpy6Md9dJaW40WUus2zLH4KV0waLzo0pmcaJtdjjrqiFOuzlZkZyXbtFQe8qam4dM(uQeoGm9an3zsuAdlb1Pb6iO5PH0jEMlHhaOuznh2LkHditpqvdlb1Pb6iOu5zYiqjABbOswfkjf8bt3uROiaCSNHnQMqJM01ZldscjmaCSNHnQoK0idEOF4WG4YmwCW0Nkbpead(GPpPKuQjHditpqZDMeL2WsqDAGocAEAiDIN5s4bakvwZHDPs4aY0du1WsqDAGockvEMOb6Dfhc2rTr(GHcmFCtImhG5JR4qWoQnYhmubsYqFAIIaWXEg2OAcnAsxpVmijKWaWXEg2O6qsJm4H(HddIlZyXbtFQe8qam4dM(KssPMeoGm9an3zsuAh68qtdeU5PH0jEMlHhaOuznh2Lsd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfezQv0a9UkagOo76RjqCQamm1H2nNoqsg6ZxKsbfKSZu)JfhmDfhc2rn9GNNsKZJ4wcloy6koeSJA6bppfkdkaouFqsK4YSxRwQd41GrTCTDGXODTZJfeHG12Wbz6TRnJAHETOmOa4WAd2TXAFGxtTujjP5aKe9RmJfhm9PsWdbWGpy6tkjLAs4aY0d0CNjrPiPr(GbcQP5iyB080q6epZLWdauknqVR4qWoQB4Gm92Q5XcIKVuzPmcjKIaWXEg2OIdb7OMojP5aKe9Z0XHnEQgKhxJYqCVqqugXLzS4GPpvcEiag8btFsjPutchqMEGM7mjkDWZtZgAGjAoi2zGXjvEMNgsN4zoSlLgO3vCiyh1g5dgkadtuiHditpq1GNNMn0atuQ8iKWdsIYxQeoGm9avdEEA2qdmrkjlLrS5s4bak9GKyz2RvBlhc2XAF1ibH2TR1gkbN1Y1kHditpWAzYeWVAZETcWW8APbUAFW3JrTatSwU2(GVAX5bj5dMETnyGQAjqdw7eskQ1isjqqeS2ajzOp1OmgO4qWArzmcCoHPxlyIZA98Q9jdIQ9bhJA7zuRrKGq721ccG1EzTxdwlnqmV2168beyTzV2RbRvagQYmwCW0Nkbpead(GPpPKuQjHditpqZDMeLIZdsYhcQzdTiZby(4MNgsN4zUeEaGsPqK5amFCfhc2rTr(GHcei4dMElHczBrOqEk5rqTer6GaWtXHGDuBeji0UTkyNiIjM4wekoij2IiHditpq1GNNMn0atK4YmwCW0Nkbpead(GPpPKuQjHditpqZDMeLEqsud4hCOzdZtdPt8mh2LksheaEkoeSJAJibH2TnxcpaqPs4aY0duHZdsYhcQzdTiZby(4LzS4GPpvcEiag8btFsjPutchqMEGM7mjk9GKOgWp4qZgMNgsN4zoSlTvI0bbGNIdb7O2isqODBZLWdauQiZby(4koeSJAJ8bdvGKm0NLzVwTuN47XOwqCWTRTLF1AbmQ9YALJ8MOO2Eg1sG8APLzS4GPpvcEiag8btFsjPutchqMEGM7mjk9GKOgWp4qZgMNgsjzzmxcpaqPImhG5JRUeq0OZU(AqnjBdvbsYqFAoSlLcrMdW8XvxciA0zxFnOMKTHQajzOpBrKWbKPhO6GKOgWp4qZge)ICKxz2RvRf0fyTVEa621cN1oben1Y1AKpy0bg1Eb0jcVA7zu7RRBhq2nV2h89yu78GcIQ9YAVgS27jRLe6ahwROTyG1c4hCu7dwRnE1Y12aTBQf9eWUP2GDIQn71Aeji0UDzgloy6tLGhcGbFW0Nusk1KWbKPhO5otIspijQb8do0SH5PHuswgZLWdau6fqNi8uZeymW7GUToaOBRezoaZhxfijd9P5WUur6GaWtXHGDuBeji0UTjr6GaWtXHGDuBeji0UTkyNOxOmtylgaAyGGQzcmg4Dq3wha0TnjsjOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6TlZETAPoX3JrTG4GBxlbYRLwlGrTxwRCK3ef12ZO2w(vlZyXbtFQe8qam4dM(KssPMeoGm9an3zsuAtoaHUT(YJ080q6epZLWdauQiZby(4Qlben6SRVgutY2qvGmyBts4aY0duDqsud4hCOzJxKJ8kZETAF9miK9RwldoiQwWeN165vlKKebH8HJ21AaC1cyu71G1kby4yW0Wb8Axlisd071oZAHxTc2RLgRfe27qbW4Q9YAbHtbgETxdF1(GVdSw(Q9AWAP(HrEn1kby4yW0Wb8Ax78ybrLzS4GPpvcEiag8btFsjPutchqMEGM7mjkTffyEAGjcQNgCqK5PH0jEMlHhaOukmcuI2waQKvfmiK9tpn4Gicj0iqjABbOsoQGbHSF6PbheriHgbkrBlaveKkyqi7NEAWbreBIfhmDvWGq2p90GdIuhKe1tOlWxSfGkswMwc1Tm71ETAFDcOn05rTwqYwxRObfeHG1cI0a9Ukyqi7NEAWbrAjadhdMgoGxBfy(4MxlnWv71WxTGjo93xTpzquTpnOx71G1YGGPxlBymG4S2xVf1)xl0Nh73OTQm71ETAzXbtFQe8qam4dM(KssPMeoGm9an3zsuAlkW80ateupn4GiZtdPt8mxcpaqPuyeOeTTaujRkyqi7NEAWbresOrGs02cqLCubdcz)0tdoiIqcncuI2waQiivWGq2p90GdIi2eisd07QGbHSF6PbhePLamCmyA4aETvG5JxMXIdM(uj4HayWhm9jLKsnjCaz6bAUZKO0e4MqquNDTiZby(4tZtdPt8mxcpaqP0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kjCaz6bQArbMNgyIG6PbhezcePb6DvWGq2p90GdI0sagogmnCaV2kW8XlZyXbtFQe8qam4dM(KssPMeoGm9an3zsu68ybr6goitVT5PH0jEMlHhaO0aWXEg2OIdb7OUHdY0BBIckePe0z)ue1oGSBsK5amFCvWGq2p90GdIubsYqF(IeoGm9avnCqMEB98ybr6dsIetCzwz2Rv7RgWmGhK6hwlWe621AhW5ODTqbumWAFGxtTSHQwQVjwl8Q9bEn1E5rwBEny8aNOQmJfhm9PsK5amF8P0EKZt7Pe2CyxAa4ypdBuzhW5OTgkGIbAsK5amFCfhc2rTr(GHkqsg6t5tqYZKiZby(4Qlben6SRVgutY2qvGmyBtuqd07koeSJArdh2OAESGOxKkHditpq1LhPMKLrlA4WgNMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(s4aY0duD5rQjzz0G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFjCaz6bQU8i1KSmAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasmXLzS4GPpvImhG5JpPKuQ1JCEApLWMd7sdah7zyJk7aohT1qbumqtImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqEetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lR8mrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfejvEetSjAGExfaoQZU2iFWqbMpUjs2zLH4KVujCaz6bQydnj0HKaKAs2zTH4kZyXbtFQezoaZhFsjPuRh58OZXzoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b19iNNcmFCtuqd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MarAGExDjGOrND91GAs2gQaZhNytImhG5JRUeq0OZU(AqnjBdvbsYqFkvEMOGgO3vCiyh1IgoSr18ybrVivchqMEGQlpsnjlJw0WHnonrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8LWbKPhO6YJutYYObXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(s4aY0duD5rQjzz0G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaKyIlZyXbtFQezoaZhFsjPuRddutp45zoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b1DyGkW8XnzeOeTTaujRQh58OZXvM9A1(QmmQTLMeO2h41uBl)Q1c71cV3ZAfjj0TRfWO2zMUQ2xzVw4v7dCmQLgRfyIG1(aVMAjqETuZRvWZRw4v7CaTBUr7APXEgyzgloy6tLiZby(4tkjLAKWiYyQZU(YGe9ZCyxkfTkaCSNHnQMqJM01ZldscjKgO3vtOrt665LbPcWGytImhG5JRUeq0OZU(AqnjBdvbsYqF(IeoGm9avK5PncuGiO(YJut3MqcPqchqMEGQdsIAa)GdnBiFjCaz6bQiZttYYObXb3w3ZqZgMezoaZhxDjGOrND91GAs2gQcKKH(u(s4aY0durMNMKLrdIdUTUNH(YJK4YmwCW0NkrMdW8XNusk1iHrKXuND9Lbj6N5WUurMdW8XvCiyh1g5dgQazW2MOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vipIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8LWbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYZenqVR4qWoQfnCyJQ5XcIKkpIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxQeoGm9avSHMe6qsasnj7S2qCLzS4GPpvImhG5JpPKuQ1h4SreC)mh2LkHditpqvcCtiiQZUwK5amF8PjkMjWGg6Gkj5Gp4a1ZCib9JqcNjWGg6GkdG5bmqngaghmDIlZETAB5Xd3EwlWeRfe5RHodhR9bEn1YgQAFL9AV8iRfoRnqgSDT8S2hCmmVwsMiS2jqG1EzTcEE1cVAPXEgyTxEKQYmwCW0NkrMdW8XNusk1ar(AOZWrZHDPImhG5JRUeq0OZU(AqnjBdvbYGTnrd07koeSJArdh2OAESGOxKkHditpq1LhPMKLrlA4WgNMezoaZhxXHGDuBKpyOcKKH(8fP2cWYmwCW0NkrMdW8XNusk1ar(AOZWrZHDPImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqEetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lR8mrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermHesHiZby(4Qlben6SRVgutY2qvGmyBt0a9UIdb7Ow0WHnQMhlisQ8iMyt0a9UkaCuNDTr(GHcmFCtKSZkdXjFPs4aY0duXgAsOdjbi1KSZAdXvM9A1s9nXANgCquTWETxEK1YoyTSrTCG1METcWAzhS2N0FF1sJ1cyuBpJAhPBJrTxd71EnyTKSm1cIdUT51sYebD7ANabw7dwBdlbRLVAhipVAVNSwoeSJ1kA4WgN1YoyTxdF1E5rw7dp93xTTOaZRwGjcQkZyXbtFQezoaZhFsjPulyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(u(s4aY0duftnjlJgehCBDpd9LhPjrMdW8XvCiyh1g5dgQajzOpLVeoGm9avXutYYObXb3w3ZqZgMO44b6NkaCuNDTr(GHjkezoaZhxfaoQZU2iFWqfijd95lOmOa4q9bjrcjuK5amFCva4Oo7AJ8bdvGKm0NYxchqMEGQyQjzz0G4GBR7zOJ0GycjSvhpq)ubGJ6SRnYhmi2enqVR4qWoQfnCyJQ5XcIKVCmbI0a9U6sarJo76Rb1KSnubMpUjAGExfaoQZU2iFWqbMpUjAGExXHGDuBKpyOaZhVm71QL6BI1on4GOAFGxtTSrTpnOxRroNq6bQQ9v2R9YJSw4S2azW21YZAFWXW8AjzIWANabw7L1k45vl8QLg7zG1E5rQkZyXbtFQezoaZhFsjPulyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(8fuguaCO(GKOjAGExXHGDulA4WgvZJfe9IujCaz6bQU8i1KSmArdh240KiZby(4koeSJAJ8bdvGKm0NVqbkdkaouFqsKsS4GPRUeq0OZU(AqnjBdvOmOa4q9bjrIlZyXbtFQezoaZhFsjPulyqi7NEAWbrMd7sfzoaZhxXHGDuBKpyOcKKH(8fuguaCO(GKOjkOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vipIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8LWbKPhOIn0KSmAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYZenqVR4qWoQfnCyJQ5XcIKkpIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxQeoGm9avSHMe6qsasnj7S2qCexMXIdM(ujYCaMp(KssPgWe1Wdjn3zsu6mbgd8oOBRda62Md7sPOvbGJ9mSr1eA0KUEEzqsiH0a9UAcnAsxpVmivageBIgO3vCiyh1IgoSr18ybrVivchqMEGQlpsnjlJw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrzqbWH6dsIMizNvgIt(s4aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JxM9A1s9nXAV8iR9bEn1Yg1c71cV3ZAFGxd0R9AWAjzzQfehCBvTVYETEEMxlWeR9bEn1gPrTWETxdw7Xd0VAHZApMi0nVw2bRfEVN1(aVgOx71G1sYYulio42QYmwCW0NkrMdW8XNusk1Ueq0OZU(AqnjBdnh2LsrRcah7zyJQj0OjD98YGKqcPb6D1eA0KUEEzqQami2enqVR4qWoQfnCyJQ5XcIErQeoGm9avxEKAswgTOHdBCAsK5amFCfhc2rTr(GHkqsg6ZxKIYGcGd1hKenrYoRmeN8LWbKPhOIn0KqhscqQjzN1gIZenqVRcah1zxBKpyOaZhVmJfhm9PsK5amF8jLKsTlben6SRVgutY2qZHDP0a9UIdb7Ow0WHnQMhli6fPs4aY0duD5rQjzz0IgoSXPPJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsrzqbWH6dsIMKWbKPhO6GKOgWp4qZgYxchqMEGQlpsnjlJgehCBDpdnBuMXIdM(ujYCaMp(KssP2LaIgD21xdQjzBO5WUuAGExXHGDulA4WgvZJfe9IujCaz6bQU8i1KSmArdh240efT64b6NkaCuNDTr(GbHekYCaMpUkaCuNDTr(GHkqsg6t5lHditpq1LhPMKLrdIdUTUNHosdInjHditpq1bjrnGFWHMnKVeoGm9avxEKAswgnio426EgA2Om71QL6BI1Yg1c71E5rwlCwB61kaRLDWAFs)9vlnwlGrT9mQDKUng1EnSx71G1sYYulio42Mxljte0TRDceyTxdF1(G12WsWArpbSBQLKDUw2bR9A4R2RbdSw4SwpVA5rGmy7A5AdahRn71AKpyuly(4QYmwCW0NkrMdW8XNusk14qWoQnYhmmh2LkYCaMpU6sarJo76Rb1KSnufijd9P8LWbKPhOIn0KSmAqCWT19m0xEKMOOvIuc6SFkjOFnTdcjuK5amFCfjmImM6SRVmir)ubsYqFkFjCaz6bQydnjlJgehCBDpdnzEeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYenqVRcah1zxBKpyOaZh3ej7SYqCYxQeoGm9avSHMe6qsasnj7S2qCLzVwTuFtS2inQf2R9YJSw4S20Rvawl7G1(K(7RwASwaJA7zu7iDBmQ9AyV2RbRLKLPwqCWTnVwsMiOBx7eiWAVgmWAHt)9vlpcKbBxlxBa4yTG5Jxl7G1En8vlBu7t6VVAPrrsI1Ysy4GPhyTGab0TRnaCuvMXIdM(ujYCaMp(KssPwa4Oo7AJ8bdZHDP0a9UIdb7O2iFWqbMpUjkezoaZhxDjGOrND91GAs2gQcKKH(u(s4aY0dufPHMKLrdIdUTUNH(YJKqcfzoaZhxXHGDuBKpyOcKKH(8fPs4aY0duD5rQjzz0G4GBR7zOzdInrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfezsK5amFCfhc2rTr(GHkqsg6t5lR8mjYCaMpU6sarJo76Rb1KSnufijd9P8LvELzS4GPpvImhG5JpPKuQnBG9d62AJ8bdZHDPs4aY0duLa3ecI6SRfzoaZhFwM9A1s9nXAnsYAVS2zlgarQFyTSxlkZfCTmDTqV2RbR1rzUAfzoaZhV2hOdMpMxlGpW5SwIAhq2R9AqV20hTRfeiGUDTCiyhR1iFWOwqaS2lRTjFQLKDU2ga3oAxBWGq2VANgCquTWzzgloy6tLiZby(4tkjLAgborxG6SRjHoO5WU0JhOFQaWrD21g5dgMOb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKLPmJfhm9PsK5amF8jLKsnJaNOlqD21Kqh0Cyxkisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFHfhmDfhc2rnjCoHdCQqzqbWH6dsIMALiLGo7NIO2bK9YmwCW0NkrMdW8XNusk1mcCIUa1zxtcDqZHDP0a9UkaCuNDTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKLXKiZby(4kusk4dMUkqgSTjrMdW8XvxciA0zxFnOMKTHQajzOpn1krkbD2pfrTdi7LzLzS4GPpvDOZdnnq4s5qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMlAyOlv2YmwCW0NQo05HMgiCkjLACiyh10dEELzS4GPpvDOZdnnq4usk14qWoQP5iyBSmRm71QL6Sb9Ada3HUDTi8AWO2RbR1YQ2mQLauN1oqB0b5aItZR9bR9H9R2lRL6qswln2ZaR9AWAjqETuQ1YVATpqhmFu1s9nXAHxT8S2zMET8S2xF(Q12WZA7qhoBqWAtGO2h8TeS2Pb6xTjquROHdBCwMXIdM(u1HZgOBRtd0Xqkkjf8bt3CyxkfbGJ9mSr1HKgzWd9dhgesifbGJ9mSr1eA0KUEEzqAQvs4aY0duzeObWyOrjPuzjMytuqd07QaWrD21g5dgkW8XjKqJaLOTfGkzvCiyh10CeSnsSjrMdW8XvbGJ6SRnYhmubsYqFwM9A1(k71(GVLG12HoC2GG1MarTImhG5Jx7d0bZNzTSdw70a9R2eiQv0WHnonVwJaMb8Gu)WAPoKK1MsWOwucgTVgOBxloMyzgloy6tvhoBGUTonqhdkjLAOKuWhmDZHDPhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ttImhG5JR4qWoQnYhmubsYqFAIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnzeOeTTaujRIdb7OMMJGTXYmwCW0NQoC2aDBDAGogusk16Wa10dEEMd7sdah7zyJkq4uangqNJ2ArssYoOjAGExbcNcOXa6C0wlsss2b19iNNcWOmJfhm9PQdNnq3wNgOJbLKsTEKZt7Pe2CyxAa4ypdBuzhW5OTgkGIbAIKDwzio53cPSYmwCW0NQoC2aDBDAGogusk14qWoQjHZjCGtZHDPbGJ9mSrfhc2rDdhKP32enqVR4qWoQB4Gm92Q5XcIEHgO3vCiyh1nCqMEBfjlJEESGituqbnqVR4qWoQnYhmuG5JBsK5amFCfhc2rTr(GHkqgSnXesiisd07Qlben6SRVgutY2qfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusk1cah1zxBKpyyoSlnaCSNHnQMqJM01ZldYYmwCW0NQoC2aDBDAGogusk14qWoQZG2CyxQiZby(4QaWrD21g5dgQazW2LzS4GPpvD4Sb6260aDmOKuQXHGDutp45zoSlvK5amFCva4Oo7AJ8bdvGmyBt0a9UIdb7Ow0WHnQMhli6fAGExXHGDulA4WgvKSm65XcIkZyXbtFQ6Wzd0T1Pb6yqjPude5RHodhnh2L2QaWXEg2O6qsJm4H(HddcjuKoia8u2W(PZU(Aq9akAkZyXbtFQ6Wzd0T1Pb6yqjPulaCuNDTr(Grz2Rv7RSx7d(oWA5RwswMANhliAwB2RT1TUw2bR9bRTHLG(7RwGjcwBlnjqTTXZ8AbMyTCTZJfev7L1AeOe0VAjbCrd0TRfWh4CwBa4o0TR9AWAP(JdY0Bx7aTrhKJ2LzS4GPpvD4Sb6260aDmOKuQXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrMePe0z)usq)AAhMezoaZhxrcJiJPo76lds0pvGmyBtTschqMEGkK0iFWab10CeSnAsK5amFCfhc2rTr(GHkqgSDz2RvlvZGKhJ21(G1AWWOwJ8GPxlWeR9bEn12YVQ51sdC1cVAFGJrTdEE1os3Uw0ta7MA7zulDEn1EnyTV(8vRLDWAB5xT2hOdMpZAb8boN1gaUdD7AVgSwlRAZOwcqDw7aTrhKdiolZyXbtFQ6Wzd0T1Pb6yqjPuZipy6Md7sBva4ypdBuDiPrg8q)WHHjkAva4ypdBunHgnPRNxgKesifs4aY0duzeObWyOrjPuznrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizz0ZJfermXLzS4GPpvD4Sb6260aDmOKuQbI81qNHJMd7sPb6Dva4Oo7AJ8bdfy(4esOrGs02cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPulyqi7NEAWbrMd7sPb6Dva4Oo7AJ8bdfy(4esOrGs02cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPuJegrgtD21xgKOFMd7sPb6Dva4Oo7AJ8bdvGKm0NVqb1JsYPLeao2ZWgvtOrt665LbjXLzVwTuNnOxBa4o0TR9AWAP(JdY0Bx7aTrhKJ2MxlWeRTLF1APXEgyTeiVwATxwliaPrTCTDGXODTZJfeHG1sZrW2yzgloy6tvhoBGUTonqhdkjLACiyh1g5dgMd7sLWbKPhOcjnYhmqqnnhbBJMOb6Dva4Oo7AJ8bdfGHjkizNvgI7fkKdLrjkKvETerkbD2pfrTdi7etmHesd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrexMXIdM(u1HZgOBRtd0XGssPghc2rnnhbBJMd7sLWbKPhOcjnYhmqqnnhbBJMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSm65XcImrd07koeSJAJ8bdfGrzgloy6tvhoBGUTonqhdkjLAatudpK0CNjrPZeymW7GUToaOBBoSlLgO3vbGJ6SRnYhmuG5JtiHgbkrBlavYQ4qWoQP5iyBKqcncuI2waQKvfmiK9tpn4GicjKcJaLOTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKuQDjGOrND91GAs2gAoSlLgO3vbGJ6SRnYhmuG5JtiHgbkrBlavYQ4qWoQP5iyBKqcncuI2waQKvfmiK9tpn4GicjKcJaLOTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKuQXHGDuBKpyyoSl1iqjABbOsw1LaIgD21xdQjzByz2Rvl13eR9vZwATxw7SfdGi1pSw2RfL5cU2woeSJ1sLbpVAbbcOBx71G1sG8APuRLF1AFGoy(ulGpW5S2aWDOBxBlhc2XAPoenPQ2xzV2woeSJ1sDiAYAHZApEG(HGMx7dwRG93xTatS2xnBP1(aVgOx71G1sG8APuRLF1AFGoy(ulGpW5S2hSwOFyeagxTxdwBl3sRv0WUJdZRDM1(GVhJANSeSw4PkZyXbtFQ6Wzd0T1Pb6yqjPuZiWj6cuNDnj0bnh2L2QJhOFkoeSJAu0KMarAGExDjGOrND91GAs2gQammbI0a9U6sarJo76Rb1KSnufijd95lsPGfhmDfhc2rn9GNNcLbfahQpij2sOb6DLrGt0fOo7AsOdQizz0ZJferCz2Rv7RSx7RMT0AB4P)(QLgrVwGjcwliqaD7AVgSwcKxlT2hOdMpMx7d(EmQfyI1cVAVS2zlgarQFyTSxlkZfCTTCiyhRLkdEE1c9AVgS2xF(QuRLF1AFGoy(OkZyXbtFQ6Wzd0T1Pb6yqjPuZiWj6cuNDnj0bnh2Lsd07koeSJAJ8bdfGHjAGExfaoQZU2iFWqfijd95lsPGfhmDfhc2rn9GNNcLbfahQpij2sOb6DLrGt0fOo7AsOdQizz0ZJferCzgloy6tvhoBGUTonqhdkjLACiyh10dEEMd7sbZtfmiK9tpn4GivGKm0NYNYiKqqKgO3vbdcz)0tdoislby4yW0Wb8ARMhlis(YRm71QL6eR9H9R2lRLKjcRDceyTpyTnSeSw0ta7MAjzNRTNrTxdwl6hmWAB5xT2hOdMpMxlkb9AH9AVgmW3ZANhCmQ9GKyTbsYqh621METV(8vv1(kV3ZAtF0UwA8omQ9YAPbcV2lRL6hgzTSdwl1HKSwyV2aWDOBx71G1AzvBg1saQZAhOn6GCaXPQmJfhm9PQdNnq3wNgOJbLKsnoeSJAAoc2gnh2LkYCaMpUIdb7O2iFWqfid22ej7SYqCVqb1vEuIczLxlrKsqN9tru7aYoXeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYefTkaCSNHnQMqJM01ZldscjuchqMEGkJanagdnkjLklXMAva4ypdBuDiPrg8q)WHHPwfao2ZWgvCiyh1nCqME7YSxRwQWrW2yTZMeyawRNxT0yTateSw(Q9AWArhS2SxBl)Q1c71sDijf8btVw4S2azW21YZAbJ0Wa621kA4WgN1(ahJAjzIWAHxThtew7iDBmQ9YAPbcV2Rjsa7MAdKKHo0TRLKDUmJfhm9PQdNnq3wNgOJbLKsnoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqtImhG5JRqjPGpy6QajzOplZETAPchbBJ1oBsGbyT84HBpRLgR9AWAh88QvWZRwOx71G1(6ZxT2hOdMp1YZAjqET0AFGJrTboVmWAVgSwrdh24S2Pb6xzgloy6tvhoBGUTonqhdkjLACiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlan1QaWXEg2OIdb7OUHdY0BxMXIdM(u1HZgOBRtd0XGssPghc2rnjCoHdCAoSlfePb6D1LaIgD21xdQjzBOcWW0Xd0pfhc2rnkAstuqd07kqKVg6mCubMpoHeYIdkb1OJKqCkvwInbI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkuguaCO(GKO5Igg6sL1CKJrBTOHHUg2Lsd07kXa5qWZd62Ard7oouG5JBIcAGExXHGDuBKpyOamiKqkA1Xd0pvkbdJ8bde0ef0a9UkaCuNDTr(GHcWGqcfzoaZhxHssbFW0vbYGTjMyIlZETAFL9AFW3bwRe0VM2H51cjjrqiF4ODTatS2w36AFAqVwbByGG1EzTEE1(WZdR1isXS2EKK12stcuMXIdM(u1HZgOBRtd0XGssPghc2rnjCoHdCAoSlvKsqN9tjb9RPDyIgO3vIbYHGNh0TvZJfejLgO3vIbYHGNh0TvKSm65XcIkZETATooUAbMq3U2w36AB5wATpnOxBl)Q12WZAPr0RfyIGLzS4GPpvD4Sb6260aDmOKuQXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusk14qWoQZG2CyxknqVR4qWoQfnCyJQ5XcIErQeoGm9avxEKAswgTOHdBCwMXIdM(u1HZgOBRtd0XGssPghc2rn9GNN5WUuAGExfaoQZU2iFWqbyqiHKSZkdXjFzPSYmwCW0NQoC2aDBDAGogusk1qjPGpy6Md7sPb6Dva4Oo7AJ8bdfy(4MOb6Dfhc2rTr(GHcmFCZH(HrayCAyxkj7SYqCYxAlGYmh6hgbGXPHKKiiKpuQSLzS4GPpvD4Sb6260aDmOKuQXHGDutZrW2yzwz2R9A1s95tadJmoeSwb7cCOzXbtN6)QL6qsk4dMETpWXOwASwNpGGhJ21shjrOxlSxRiDq4btFwlhyTK4PkZETxRwwCW0NQgoitVTub7cCOzXbt3Cyxkloy6kusk4dMUs0WUJdOBBIKDwzio5lTfszLzVwTVYETJ8P20RLKDUw2bRvK5amF8zTCG1kssOBxlGH51AN1Ynidwl7G1IsYYmwCW0NQgoitVnLKsnusk4dMU5WUus2zLH4Erkbjpts4aY0duLa3ecI6SRfzoaZhFAIIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lYkpIlZETAPoXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYs9QDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPuJdb7OMeoNWbonh2LsHeoGm9avZJfePB4Gm92es4bjXxKvEeBIgO3vCiyh1nCqMEB18ybrVil1ZCrddDPYwM9A1sD2GETatOBxl1bPr7a5rTVobOZUanVwbpVA5A74tTOmxW1scNt4aN1(0ahyTpm8GUDT9mQ9AWAPb69A5R2RbRDECC1M9AVgS2o0U5kZyXbtFQA4Gm92usk14qWoQjHZjCGtZHDPylgaAyGGkK0ODG8qNbOZUanDqs8fcsEMU02EGkrMdW8XNMezoaZhxHKgTdKh6maD2fOkqsg6t5ll1RfyQvS4GPRqsJ2bYdDgGo7cubcNm9ablZyXbtFQA4Gm92usk1aMOgEiP5otIsNjWyG3bDBDaq32CyxQeoGm9aviPr(GbcQP5iyB0KiZby(4Qlben6SRVgutY2qvGKm0NVifLbfahQpijAsK5amFCfhc2rTr(GHkqsg6ZxKsbkdkaouFqsSLihIlZyXbtFQA4Gm92usk1cgeY(PNgCqK5WUujCaz6bQqsJ8bdeutZrW2OjrMdW8XvxciA0zxFnOMKTHQajzOpFrkkdkaouFqs0KiZby(4koeSJAJ8bdvGKm0NViLcuguaCO(GKylroeBIIwHTyaOHbcQMjWyG3bDBDaq3MqcfPdcapfhc2rTrKGq72QGDIKVukJqcVa6eHNAMaJbEh0T1baDBLiZby(4QajzOpLVSYkpIlZyXbtFQA4Gm92usk1Ueq0OZU(AqnjBdnh2LkHditpqvlkW80ateupn4GitImhG5JR4qWoQnYhmubsYqF(IuuguaCO(GKOjkAf2IbGggiOAMaJbEh0T1baDBcjuKoia8uCiyh1grccTBRc2js(sPmcj8cOteEQzcmg4Dq3wha0TvImhG5JRcKKH(u(YkR8iUmJfhm9PQHdY0BtjPuJdb7O2iFWWCyxQrGs02cqLSQlben6SRVgutY2WYmwCW0NQgoitVnLKsTaWrD21g5dgMd7sLWbKPhOcjnYhmqqnnhbBJMezoaZhxfmiK9tpn4GivGKm0NVifLbfahQpijAschqMEGQdsIAa)GdnBiFPYrEMOOvI0bbGNIdb7O2isqODBcjSvs4aY0duXJhU9upB7cTiZby(4tcjuK5amFC1LaIgD21xdQjzBOkqsg6ZxKsbkdkaouFqsSLihIjUmJfhm9PQHdY0BtjPulyqi7NEAWbrMd7sLWbKPhOcjnYhmqqnnhbBJMmcuI2waQKvfaoQZU2iFWOmJfhm9PQHdY0BtjPu7sarJo76Rb1KSn0CyxQeoGm9avTOaZtdmrq90GdIm1kjCaz6bQAYbi0T1xEKLzVwTuFtSw54G1YHGDSwAoc2gRf612YVkLE9VoVATPpAxlSxlvgzcoaMxTSdwlF1oqEE1kNABDRN1AePqGGLzS4GPpvnCqMEBkjLACiyh10CeSnAoSlLgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYenqVRcah1zxBKpyOammrd07koeSJAJ8bdfGHjAGExXHGDu3Wbz6TvZJfejFPYs9mrd07koeSJAJ8bdvGKm0NViLfhmDfhc2rnnhbBJkuguaCO(GKOjAGExrpYeCampfGrz2Rvl13eRvooyTV(8vRf612YVATPpAxlSxlvgzcoaMxTSdwRCQT1TEwRrKIYmwCW0NQgoitVnLKsTaWrD21g5dgMd7sPb6Dva4Oo7AJ8bdfy(4MOb6Df9itWbW8uagMOqchqMEGQdsIAa)GdnBiFcsEesOiZby(4QGbHSF6PbhePcKKH(u(YkhInrbnqVR4qWoQB4Gm92Q5XcIKVuzPmcjKgO3vIbYHGNh0TvZJfejFPYsSjkALiDqa4P4qWoQnIeeA3MqcBLeoGm9av84HBp1Z2UqlYCaMp(K4YmwCW0NQgoitVnLKsTaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmFCtuiHditpq1bjrnGFWHMnKpbjpcjuK5amFCvWGq2p90GdIubsYqFkFzLdXMOOvI0bbGNIdb7O2isqODBcjSvs4aY0duXJhU9upB7cTiZby(4tIlZyXbtFQA4Gm92usk1cgeY(PNgCqK5WUujCaz6bQqsJ8bdeutZrW2OjkOb6Dfhc2rTOHdBunpwqK8LkhcjuK5amFCfhc2rDg0QazW2eBIIwD8a9tfaoQZU2iFWGqcfzoaZhxfaoQZU2iFWqfijd9P8PmInjHditpqfopijFiOMn0ImhG5JlFPeK8mrrRePdcapfhc2rTrKGq72esyRKWbKPhOIhpC7PE22fArMdW8XNexM9A1sD2GETbG7q3UwJibH2TnVwGjw7LhzT0TRfEtC0Rf61Mbig1EzT8aA71cVAFGxtTSrzgloy6tvdhKP3MssP2LaIgD21xdQjzBO5WUujCaz6bQoijQb8do0SXluM8mjHditpq1bjrnGFWHMnKpbjptu0kSfdanmqq1mbgd8oOBRda62esOiDqa4P4qWoQnIeeA3wfStK8LszexMXIdM(u1Wbz6TPKuQXHGDuNbT5WUujCaz6bQArbMNgyIG6PbhezIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwquzgloy6tvdhKP3MssPghc2rnnhbBJMd7sbrAGExfmiK9tpn4GiTeGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKwcWWXGPHd41wrYYONhliQmJfhm9PQHdY0BtjPuJdb7OMEWZZCyxQeoGm9avTOaZtdmrq90GdIiKqkarAGExfmiK9tpn4GiTeGHJbtdhWRTcWWeisd07QGbHSF6PbhePLamCmyA4aETvZJfe9cisd07QGbHSF6PbhePLamCmyA4aETvKSm65XcIiUm71QL6BI1scDyTuHJGTXAPX7brV2GbHSF1on4GOzTWETaoig1sfcU2h41KaxTG4GBdD7AF9miK9RwldoiQwiiYJr7YmwCW0NQgoitVnLKsnoeSJAAoc2gnh2Lsd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbMpUjAGExrpYeCampfGHjrMdW8Xvbdcz)0tdoisfijd95lsLvEMOb6Dfhc2rDdhKP3wnpwqK8Lkl1Rm71QL6BI1MbDTPxRaSwaFGZzTSrTWzTIKe621cyu7mtVmJfhm9PQHdY0BtjPuJdb7OodAZHDP0a9UIdb7Ow0WHnQMhli6fcYKeoGm9avhKe1a(bhA2q(YkptuiYCaMpU6sarJo76Rb1KSnufijd9P8PmcjSvI0bbGNIdb7O2isqODBIlZyXbtFQA4Gm92usk14qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6Dfhc2rTr(GHcWWCrddDPYwM9A1(k71(G1AJxTg5dg1c9oWeMETGab0TRDamVAFW3JrTnSeSw0ta7MAB45H1EzT24vB271Y1oViD7AP5iyBSwqGa621EnyTrAqn2O2hOdMpLzS4GPpvnCqMEBkjLACiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dva4Oo7AJ8bdvGKm0NViLfhmDfhc2rnjCoHdCQqzqbWH6dsIMOb6Dfhc2rTr(GHcWWenqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwqKjAGExXHGDu3Wbz6TvZJfezIgO3vg5dgAO3bMW0vagMOb6Df9itWbW8uagLzVwTVYETpyT24vRr(GrTqVdmHPxliqaD7AhaZR2h89yuBdlbRf9eWUP2gEEyTxwRnE1M9ETCTZls3UwAoc2gRfeiGUDTxdwBKguJnQ9b6G5J51oZAFW3JrTPpAxlWeRf9eWUPw6bpVzTqhEqEmAx7L1AJxTxwBpbIAfnCyJZYmwCW0NQgoitVnLKsnoeSJA6bppZHDP0a9UYiWj6cuNDnj0bvagMOGgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqeHe2kkOb6DLr(GHg6DGjmDfGHjAGExrpYeCampfGbXexM9A1sGgSwACE1cmXAZETgjzTWzTxwlWeRfE1EzTTyaOGOr7APbGdWAfnCyJZAbbcOBxlBul3pmQ9AW21AJxTGaKgiyT0TR9AWAB4Gm921sZrW2yzgloy6tvdhKP3MssPMrGt0fOo7AsOdAoSlLgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqKjAGExXHGDuBKpyOamkZETAPoXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYs9QDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPuJdb7OMeoNWbonh2Lsd07koeSJ6goitVTAESGOxKL6zUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwMXIdM(u1Wbz6TPKuQXHGDutZrW2O5WUuAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGits4aY0duHKg5dgiOMMJGTXYmwCW0NQgoitVnLKsnusk4dMU5WUus2zLH4ErwkRm71Q91XhTRfyI1sp45v7L1sdahG1kA4WgN1c71(G1YJazW212WsWANjjwBpsYAZGUmJfhm9PQHdY0BtjPuJdb7OMEWZZCyxknqVR4qWoQfnCyJQ5XcImrd07koeSJArdh2OAESGOxOb6Dfhc2rTOHdBurYYONhliQm71Q91vWXO2h41ultwlGpW5Sw2Ow4SwrscD7AbmQLDWAFW3bw7iFQn9AjzNlZyXbtFQA4Gm92usk14qWoQjHZjCGtZHDPTIcjCaz6bQoijQb8do0SXlsLvEMizNvgI7fcsEeBUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwM9A1(Qr2HdCw7d8AQDKp1sYZdJ2MxBd0UP2gEEO51MrT051ulj3UwpVAByjyTONa2n1sYox7L1obmmY4QTjFQLKDUwOFOpHsWAdgeY(v70GdIQvWET0O51oZAFW3JrTatS2omWAPh88QLDWA7rop6CC1(0GETJ8P20RLKDUmJfhm9PQHdY0BtjPuRddutp45vMXIdM(u1Wbz6TPKuQ1JCE054kZkZyXbtFQsd0XqAhgOMEWZZCyxAa4ypdBubcNcOXa6C0wlsss2bnrd07kq4uangqNJ2ArssYoOUh58uagLzS4GPpvPb6yqjPuRh580EkHnh2Lgao2ZWgv2bCoARHcOyGMizNvgIt(TqkRmJfhm9PknqhdkjLAatudpK0CNjrPZeymW7GUToaOBxMXIdM(uLgOJbLKsnqKVg6mCSmJfhm9PknqhdkjLAbdcz)0tdoiYCyxkj7SYqCYN6kVYmwCW0NQ0aDmOKuQrcJiJPo76lds0VYmwCW0NQ0aDmOKuQnBG9d62AJ8bdZHDP0a9UIdb7O2iFWqbMpUjrMdW8XvCiyh1g5dgQajzOplZyXbtFQsd0XGssPghc2rDg0Md7sfzoaZhxXHGDuBKpyOcKbBBIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwquzgloy6tvAGogusk14qWoQPh88mh2LksjOZ(PKG(10omjYCaMpUIegrgtD21xgKOFQajzOpLFlG6wMXIdM(uLgOJbLKsTlben6SRVgutY2WYmwCW0NQ0aDmOKuQXHGDuBKpyuMXIdM(uLgOJbLKsTaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmF8YSxRwQVjw7RMT0AVS2zlgarQFyTSxlkZfCTTCiyhRLkdEE1cceq3U2RbRLa51sPwl)Q1(aDW8PwaFGZzTbG7q3U2woeSJ1sDiAsvTVYETTCiyhRL6q0K1cN1E8a9dbnV2hSwb7VVAbMyTVA2sR9bEnqV2RbRLa51sPwl)Q1(aDW8PwaFGZzTpyTq)WiamUAVgS2wULwROHDhhMx7mR9bFpg1ozjyTWtvMXIdM(uLgOJbLKsnJaNOlqD21Kqh0CyxARoEG(P4qWoQrrtAcePb6D1LaIgD21xdQjzBOcWWeisd07Qlben6SRVgutY2qvGKm0NViLcwCW0vCiyh10dEEkuguaCO(GKylHgO3vgborxG6SRjHoOIKLrppwqeXLzVwTVYETVA2sRTHN(7RwAe9AbMiyTGab0TR9AWAjqET0AFGoy(yETp47XOwGjwl8Q9YANTyaeP(H1YETOmxW12YHGDSwQm45vl0R9AWAF95RsTw(vR9b6G5JQmJfhm9PknqhdkjLAgborxG6SRjHoO5WUuAGExXHGDuBKpyOammrd07QaWrD21g5dgQajzOpFrkfS4GPR4qWoQPh88uOmOa4q9bjXwcnqVRmcCIUa1zxtcDqfjlJEESGiIlZyXbtFQsd0XGssPghc2rn9GNN5WUuW8ubdcz)0tdoisfijd9P8PmcjeePb6DvWGq2p90GdI0sagogmnCaV2Q5XcIKV8kZETAB5Xd3Ewlv4iyBSw(Q9AWArhS2SxBl)Q1(0GETbG7q3U2RbRTLdb7yTu)Xbz6TRDG2OdYr7YmwCW0NQ0aDmOKuQXHGDutZrW2O5WUuAGExXHGDuBKpyOammrd07koeSJAJ8bdvGKm0NVylanfao2ZWgvCiyh1nCqME7YSxR2wE8WTN1sfoc2gRLVAVgSw0bRn71EnyTV(8vR9b6G5tTpnOxBa4o0TR9AWAB5qWowl1FCqME7AhOn6GC0UmJfhm9PknqhdkjLACiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlanfao2ZWgvCiyh1nCqME7YmwCW0NQ0aDmOKuQXHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gsqn6ijeNsLLytGinqVRUeq0OZU(AqnjBdvbsYqFkFwCW0vCiyh1KW5eoWPcLbfahQpijAUOHHUuznh5y0wlAyORHDP0a9Usmqoe88GUTw0WUJdfy(4MOGgO3vCiyh1g5dgkadcjKIwD8a9tLsWWiFWabnrbnqVRcah1zxBKpyOamiKqrMdW8XvOKuWhmDvGmyBIjM4YmwCW0NQ0aDmOKuQXHGDutcNt4aNMd7sPb6DLyGCi45bDB18ybrsPb6DLyGCi45bDBfjlJEESGitIuc6SFkjOFnTJYmwCW0NQ0aDmOKuQXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQ0aDmOKuQXHGDuNbT5WUuAGExXHGDulA4WgvZJfe9IujCaz6bQU8i1KSmArdh24SmJfhm9PknqhdkjLACiyh10dEEMd7sPb6Dva4Oo7AJ8bdfGbHesYoRmeN8LLYkZyXbtFQsd0XGssPgkjf8bt3CyxknqVRcah1zxBKpyOaZh3enqVR4qWoQnYhmuG5JBo0pmcaJtd7sjzNvgIt(sBbuM5q)WiamonKKebH8HsLTmJfhm9PknqhdkjLACiyh10CeSnwMvM9AVwTS4GPpvrE8btxQGDbo0S4GPBoSlLfhmDfkjf8btxjAy3Xb0TnrYoRmeN8L2cPmtu0QaWXEg2OAcnAsxpVmijKqAGExnHgnPRNxgKQ5XcIKsd07Qj0OjD98YGurYYONhliI4YSxRwQVjwlkjRf2R9bFhyTJ8P20RLKDUw2bRvK5amF8zTCG1Y0jWv7L1sJ1cyuMXIdM(uf5XhmDkjLAOKuWhmDZHDPTkaCSNHnQMqJM01ZldstKSZkdX9IujCaz6bQqjP2qCMOqK5amFC1LaIgD21xdQjzBOkqsg6ZxKYIdMUcLKc(GPRqzqbWH6dsIesOiZby(4koeSJAJ8bdvGKm0NViLfhmDfkjf8btxHYGcGd1hKejKqkoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NViLfhmDfkjf8btxHYGcGd1hKejMyt0a9UkaCuNDTr(GHcmFCt0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kJaLOTfGkzvxciA0zxFnOMKTHLzS4GPpvrE8btNssPgkjf8bt3CyxAa4ypdBunHgnPRNxgKMALiLGo7Nsc6xt7WKiZby(4koeSJAJ8bdvGKm0NViLfhmDfkjf8btxHYGcGd1hKelZyXbtFQI84dMoLKsnusk4dMU5WU0aWXEg2OAcnAsxpVminjsjOZ(PKG(10omjYCaMpUIegrgtD21xgKOFQajzOpFrkloy6kusk4dMUcLbfahQpijAsK5amFC1LaIgD21xdQjzBOkqsg6ZxKsHeoGm9avK5PncuGiO(YJut3MsS4GPRqjPGpy6kuguaCO(GKiLiiInjYCaMpUIdb7O2iFWqfijd95lsPqchqMEGkY80gbkqeuF5rQPBtjwCW0vOKuWhmDfkdkaouFqsKseeXLzVwTuHJGTXAH9AH37zThKeR9YAbMyTxEK1YoyTpyTnSeS2lZAjzVDTIgoSXzzgloy6tvKhFW0PKuQXHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYxchqMEGQlpsnjlJw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrzqbWH6dsIMizNvgIt(s4aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JtCzgloy6tvKhFW0PKuQXHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYxchqMEGQlpsnjlJw0WHnonD8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrkkdkaouFqs0KeoGm9avhKe1a(bhA2q(s4aY0duD5rQjzz0G4GBR7zOzdIlZyXbtFQI84dMoLKsnoeSJAAoc2gnh2LkYCaMpU6sarJo76Rb1KSnufid22ef0a9UIdb7Ow0WHnQMhlis(s4aY0duD5rQjzz0IgoSXPjkA1Xd0pva4Oo7AJ8bdcjuK5amFCva4Oo7AJ8bdvGKm0NYxchqMEGQlpsnjlJgehCBDpdDKgeBschqMEGQdsIAa)GdnBiFjCaz6bQU8i1KSmAqCWT19m0SbXLzS4GPpvrE8btNssPghc2rnnhbBJMd7sbrAGExfmiK9tpn4GiTeGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKwcWWXGPHd41wrYYONhliYef0a9UIdb7O2iFWqbMpoHesd07koeSJAJ8bdvGKm0NVi1wasSjkOb6Dva4Oo7AJ8bdfy(4esinqVRcah1zxBKpyOcKKH(8fP2cqIlZyXbtFQI84dMoLKsnoeSJA6bppZHDPs4aY0du1IcmpnWeb1tdoiIqcPaePb6DvWGq2p90GdI0sagogmnCaV2kadtGinqVRcgeY(PNgCqKwcWWXGPHd41wnpwq0lGinqVRcgeY(PNgCqKwcWWXGPHd41wrYYONhliI4YmwCW0NQip(GPtjPuJdb7OMEWZZCyxknqVRmcCIUa1zxtcDqfGHjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF(IuwCW0vCiyh10dEEkuguaCO(GKyzgloy6tvKhFW0PKuQXHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gsqn6ijeNsLLytuaI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkuguaCO(GKiHekYCaMpUYiWj6cuNDnj0bvbsYqFsiHIuc6SFkIAhq2j2CrddDPYAoYXOTw0Wqxd7sPb6DLyGCi45bDBTOHDhhkW8XnrbnqVR4qWoQnYhmuagesifT64b6NkLGHr(GbcAIcAGExfaoQZU2iFWqbyqiHImhG5JRqjPGpy6QazW2etmXLzVwTTo9jajw71G1IYyWoicwRrEOFqEulnqVxlpzJAVSwpVAh5eR1ip0pipQ1isXSmJfhm9PkYJpy6usk14qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6DfkJb7GiO2ip0pipuagLzS4GPpvrE8btNssPghc2rnjCoHdCAoSlLgO3vIbYHGNh0TvbYIZef0a9UIdb7O2iFWqbyqiH0a9UkaCuNDTr(GHcWGqcbrAGExDjGOrND91GAs2gQcKKH(u(S4GPR4qWoQjHZjCGtfkdkaouFqsKyZfnm0LkBzgloy6tvKhFW0PKuQXHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62kswg98ybrMlAyOlv2YSxR2wE8WTN1Er7AVSwA2jQ2w36A7zuRiZby(41(aDW8zwlnWvliaPrTxdswlSx71GTFhyTmDcC1EzTOmgWalZyXbtFQI84dMoLKsnoeSJAs4Cch40CyxknqVRedKdbppOBRcKfNjAGExjgihcEEq3wfijd95lsPGcAGExjgihcEEq3wnpwqulHfhmDfhc2rnjCoHdCQqzqbWH6dsIetjBbOIKLHyZfnm0LkBzgloy6tvKhFW0PKuQ541GH(qsdCEMd7sPiWEGZgMEGesyRoOGiOBtSjAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlJEESGit0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFQI84dMoLKsnoeSJ6mOnh2Lsd07koeSJArdh2OAESGOxKkHditpq1LhPMKLrlA4WgNLzS4GPpvrE8btNssP2eWadpLWMd7sLWbKPhOkbUjee1zxlYCaMp(0ej7SYqCViTfszLzS4GPpvrE8btNssPghc2rn9GNN5WUuAGExfaduND91eiovagMOb6Dfhc2rTOHdBunpwqK8jOYSxR2xxainQv0WHnoRf2R9bRTZJrT04iFQ9AWAfPpXqcwlj7CTxtGZMCawl7G1IssbFW0RfoRDEWXO20RvK5amF8YmwCW0NQip(GPtjPuJdb7OMMJGTrZHDPTkaCSNHnQMqJM01Zldsts4aY0duLa3ecI6SRfzoaZhFAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliY0Xd0pfhc2rDg0MezoaZhxXHGDuNbTkqsg6ZxKAlanrYoRme3lsBHYZKiZby(4kusk4dMUkqsg6ZYmwCW0NQip(GPtjPuJdb7OMMJGTrZHDPbGJ9mSr1eA0KUEEzqAschqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAluEMezoaZhxHssbFW0vbsYqF(cbjVYSxR2xxainQv0WHnoRf2Rnd6AHZAdKbBxMXIdM(uf5XhmDkjLACiyh10CeSnAoSlvchqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAluEMezoaZhxHssbFW0vbsYqFAIIwfao2ZWgvtOrt665LbjHesd07Qj0OjD98YGufijd95lsLTfqCz2RvBlhc2XAPchbBJ1oBsGbyT2OJbpgTRLgR9AWAh88QvWZR2Sx71G12YVATpqhmFkZyXbtFQI84dMoLKsnoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJkswg98ybrMOqK5amFCfkjf8btxfijd9jHegao2ZWgvCiyh1nCqMEBIlZETAB5qWowlv4iyBS2ztcmaR1gDm4XODT0yTxdw7GNxTcEE1M9AVgS2xF(Q1(aDW8PmJfhm9PkYJpy6usk14qWoQP5iyB0CyxknqVRcah1zxBKpyOammrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdvGKm0NVi1waAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYYONhliYefImhG5JRqjPGpy6QajzOpjKWaWXEg2OIdb7OUHdY0BtCz2RvBlhc2XAPchbBJ1oBsGbyT0yTxdw7GNxTcEE1M9AVgSwcKxlT2hOdMp1c71cVAHZA98QfyIG1(aVMAF95RwBg12YVAzgloy6tvKhFW0PKuQXHGDutZrW2O5WUuAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFrQTa0enqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLrppwquz2Rvl1zd61EnyThh24vlCwl0RfLbfahwBWUnwl7G1EnyG1cN1sMbw71WETPJ1Ios228AbMyT0CeSnwlpRDMPxlpRTDcuBdlbRf9eWUPwrdh24S2lRTbE1YJrTOJKqCwlSx71G12YHGDSwQKK0CasI(v7aTrhKJ21cN1ITyaOHbcwMXIdM(uf5XhmDkjLACiyh10CeSnAoSlvchqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrYxkfS4Gsqn6ijeNTiYsSjwCqjOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKsnoeSJAugJroHPBoSlvchqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLrppwqKjwCqjOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKsnoeSJA6bpVYmwCW0NQip(GPtjPudLKc(GPBoSlvchqMEGQe4MqquNDTiZby(4ZYmwCW0NQip(GPtjPuJdb7OMMJGTXVfdCnz8TSGKad(GP36G73)(3)d]] )

    
end