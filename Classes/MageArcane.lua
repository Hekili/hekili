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


    spec:RegisterPack( "Arcane", 20210823.1, [[deL3vhqiPK8ivjLljLav2ef5tQsnkKWPqOwLuI4virMffv3skbzxK8lIcdJOkhJO0YiQ4ziqMgrr5AirzBefPVPkjmoIIQZjLqToKO6DsjqvMNQe3JiTpIQ6GsjQfse8qPKAIQsQexKOiSrvjvs(OQKk1iLsGYjvLeTskkVuvsLuZebQBkLiTtIq)uvsfdvvsAPQsQ6PuYuraxvkbSvPeOQ(krr0yjQ0Evv)LudwPdJAXi1JjmzGUm0MLQptPgTuCAqRwkb1RriZwHBJODt1VfnCkCCPeYYfEUIMUkxhW2rsFxvmEIOZlLA9sjqMpcA)s(l7NaFlq(WVeLJ8KJSYtMlhcsjRmxMjhzgb9TU2g43YGfeX243Yzs8B1YHGD8BzWThjd(jW3AMaHa)wn3zmPCzidB41aqRejPmMqsGbFW0fb3pzmHKcz8TObGJ7v6F6VfiF4xIYrEYrw5jZLdbPKvMlZKdbrzFRPbk(suMkNVvdeee9p93ceNIVvlLTXAB5qWowM1Ya2aZRw5qqMxRCKNCKTmRmR1nSBJtkVmRfQ2wGjw712ak4rTwqYwxBd7GdOBxB2Rv0WUJJAH(HrayCW0Rf6ZdzWAZETVfSlWHMfhm93QYSwOABDd72yTCiyh1qVdD41U2lRLdb7OUHdY0BxlfWRwhPIrTpOF1oGuXA5zTCiyh1nCqMEBIvLzTq1(6s6VVALjOMc(WAHETT8RJmrTTWaZRwAuWatS22jW7aRnbUAZETb72yTSdwRNxTatOBxBlhc2XALjK0yKty6QV1aoV5NaFR0aDm(e4lrz)e4BHotpqWVe(wIaEya5Vva4ypdBubcNcOXa6C0wlsss2bvOZ0deSwt1sd07kq4uangqNJ2ArssYoOUh58uagFlwCW0)wDyGA6bpV)9LOC(e4BHotpqWVe(wIaEya5Vva4ypdBuzhW5OTgkGIbQqNPhiyTMQLKDwziUALFTTyk7BXIdM(3Qh580EsL)3xIe0NaFl0z6bc(LW3Yzs8BntGXaVd626aGU93Ifhm9V1mbgd8oOBRda62)7lrz2NaFlwCW0)wGiFn0z443cDMEGGFj8VVePSpb(wOZ0de8lHVLiGhgq(BrYoRmexTYVwzM8(wS4GP)TcgeY(PNgCq0)(suM(jW3Ifhm9VfjmImM6SRVmir)(wOZ0de8lH)9L4R4tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7O2iFWqbMpETMQvK5amFCfhc2rTr(GHkqsg6ZVfloy6FRzdSFq3wBKpy8VVeL5Fc8TqNPhi4xcFlrapmG83sK5amFCfhc2rTr(GHkqgSDTMQLgO3vCiyh1IgoSr18ybr1(sT0a9UIdb7Ow0WHnQizj1ZJfe9TyXbt)BXHGDuNb9)(sSf)jW3cDMEGGFj8Teb8WaYFlrsfD2pfv0VM2rTMQvK5amFCfjmImM6SRVmir)ubsYqFwR8RvMlZ(wS4GP)T4qWoQPh88(3xIYkVpb(wS4GP)TUeq0OZU(AqnjBd)wOZ0de8lH)9LOSY(jW3Ifhm9Vfhc2rTr(GX3cDMEGGFj8VVeLvoFc8TqNPhi4xcFlrapmG83IgO3vCiyh1g5dgkW8X)wS4GP)Tcah1zxBKpy8VVeLLG(e4BHotpqWVe(wS4GP)TmcCIUa1zxtcDWVfiofb04GP)TAbMyTVA2sR9YANTiaeBbH1YETOKxW12YHGDSwjm45vliqaD7AVgSwcKxlvgT8Rw7d0bZNAb8boN1gaUdD7AB5qWowRmHOjv1(k712YHGDSwzcrtwlCw7Xd0pe08AFWAfS)(QfyI1(QzlT2h41a9AVgSwcKxlvgT8Rw7d0bZNAb8boN1(G1c9dJaW4Q9AWAB5wATIg2DCyETZS2h89yu7KPI1cp13seWddi)TAvThpq)uCiyh1OOjvOZ0deSwt1cI0a9U6sarJo76Rb1KSnubyuRPAbrAGExDjGOrND91GAs2gQcKKH(S2xKwlf1YIdMUIdb7OMEWZtHsIcGd1hKeRTLulnqVRmcCIUa1zxtcDqfjlPEESGOAj(FFjkRm7tGVf6m9ab)s4BXIdM(3YiWj6cuNDnj0b)wG4ueqJdM(36v2R9vZwATn80FF1sJOxlWebRfeiGUDTxdwlbYRLw7d0bZhZR9bFpg1cmXAHxTxw7SfbGyliSw2RfL8cU2woeSJ1kHbpVAHETxdw7RpFvz0YVATpqhmFuFlrapmG83IgO3vCiyh1g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(S2xKwlf1YIdMUIdb7OMEWZtHsIcGd1hKeRTLulnqVRmcCIUa1zxtcDqfjlPEESGOAj(FFjklL9jW3cDMEGGFj8Teb8WaYFlW8ubdcz)0tdoisfijd9zTYVwkRwcjSwqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhliQw5xR8(wS4GP)T4qWoQPh88(3xIYkt)e4BHotpqWVe(wS4GP)T4qWoQP5iyB8BbItranoy6FRwE8WTN1kboc2gRLVAVgSw0bRn712YVATpnOxBa4o0TR9AWAB5qWowBlyCqME7AhOn6GC0(Bjc4HbK)w0a9UIdb7O2iFWqbyuRPAPb6Dfhc2rTr(GHkqsg6ZAFPwBbyTMQnaCSNHnQ4qWoQB4Gm92k0z6bc(VVeL9v8jW3cDMEGGFj8TyXbt)BXHGDutZrW243ceNIaACW0)wT84HBpRvcCeSnwlF1EnyTOdwB2R9AWAF95Rw7d0bZNAFAqV2aWDOBx71G12YHGDS2wW4Gm921oqB0b5O93seWddi)TOb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHkqsg6ZAFrAT2cWAnvBa4ypdBuXHGDu3Wbz6TvOZ0de8FFjkRm)tGVf6m9ab)s4BjAyO)TK9BHCmARfnm01W(3IgO3vIbYHGNh0T1Ig2DCOaZh3ef0a9UIdb7O2iFWqbyqiHu0QJhOFQKkgg5dgiOjkOb6Dva4Oo7AJ8bdfGbHekYCaMpUcPMc(GPRcKbBtmXe)Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnv7Xd0pfhc2rnkAsf6m9abR1uTuulnqVRar(AOZWrfy(41siH1YIdsf1OJKqCwR0ALTwIR1uTGinqVRUeq0OZU(AqnjBdvbsYqFwR8RLfhmDfhc2rnjCoHdCQqjrbWH6dsIFlwCW0)wCiyh1KW5eoW5)(su2w8NaFl0z6bc(LW3seWddi)TOb6DLyGCi45bDB18ybr1kTwAGExjgihcEEq3wrYsQNhliQwt1ksQOZ(POI(10o(wS4GP)T4qWoQjHZjCGZ)9LOCK3NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(Tenm0)wY(Teb8WaYFlAGExjgihcEEq3wfilUAnvRiZby(4koeSJAJ8bdvGKm0N1AQwkQLgO3vbGJ6SRnYhmuag1siH1sd07koeSJAJ8bdfGrTe)VVeLJSFc8TqNPhi4xcFlrapmG83IgO3vCiyh1IgoSr18ybr1(I0APYbKPhO6YJutYsQfnCyJZVfloy6FloeSJ6mO)3xIYroFc8TqNPhi4xcFlrapmG83IgO3vbGJ6SRnYhmuag1siH1sYoRmexTYVwzPSVfloy6FloeSJA6bpV)9LOCiOpb(wOZ0de8lHVfloy6FlKAk4dM(3c6hgbGXPH9Vfj7SYqCYxQmNY(wq)WiamonKKebH8HFlz)wIaEya5VfnqVRcah1zxBKpyOaZhVwt1sd07koeSJAJ8bdfy(4)7lr5iZ(e4BXIdM(3Idb7OMMJGTXVf6m9ab)s4F)7B1HZgOBRtd0X4tGVeL9tGVf6m9ab)s4BXIdM(3cPMc(GP)TaXPiGghm9VLmzd61gaUdD7Ar41GrTxdwRLvTzulbKjRDG2OdYbeNMx7dw7d7xTxwRmb1SwASNbw71G1sG8APYOLF1AFGoy(OQTfyI1cVA5zTZm9A5zTV(8vRTHN12HoC2GG1MarTp4BQyTtd0VAtGOwrdh248Bjc4HbK)wuuBa4ypdBuDiPrg8q)WHHcDMEGG1siH1srTbGJ9mSr1eA0KUEEzqQqNPhiyTMQTv1sLditpqLrGgaJHgPM1kTwzRL4AjUwt1srT0a9UkaCuNDTr(GHcmF8AjKWAncKQ2waQKvXHGDutZrW2yTexRPAfzoaZhxfaoQZU2iFWqfijd95)(suoFc8TqNPhi4xcFlwCW0)wi1uWhm9Vfiofb04GP)TEL9AFW3uXA7qhoBqWAtGOwrMdW8XR9b6G5ZSw2bRDAG(vBce1kA4WgNMxRraZaEWwqyTYeuZAtQyulsfJ2xd0TRfht8Bjc4HbK)whpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAnvRiZby(4koeSJAJ8bdvGKm0N1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTgbsvBlavYQ4qWoQP5iyB8FFjsqFc8TqNPhi4xcFlrapmG83kaCSNHnQaHtb0yaDoARfjjj7Gk0z6bcwRPAPb6DfiCkGgdOZrBTijjzhu3JCEkaJVfloy6FRomqn9GN3)(suM9jW3cDMEGGFj8Teb8WaYFRaWXEg2OYoGZrBnuafduHotpqWAnvlj7SYqC1k)ABXu23Ifhm9VvpY5P9Kk)VVePSpb(wOZ0de8lHVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)wbGJ9mSrfhc2rDdhKP3wHotpqWAnvlnqVR4qWoQB4Gm92Q5XcIQ9LAPb6Dfhc2rDdhKP3wrYsQNhliQwt1srTuulnqVR4qWoQnYhmuG5JxRPAfzoaZhxXHGDuBKpyOcKbBxlX1siH1cI0a9U6sarJo76Rb1KSnubyulX)7lrz6NaFl0z6bc(LW3seWddi)Tcah7zyJQj0OjD98YGuHotpqWVfloy6FRaWrD21g5dg)7lXxXNaFl0z6bc(LW3seWddi)TezoaZhxfaoQZU2iFWqfid2(BXIdM(3Idb7Ood6)9LOm)tGVf6m9ab)s4Bjc4HbK)wImhG5JRcah1zxBKpyOcKbBxRPAPb6Dfhc2rTOHdBunpwquTVulnqVR4qWoQfnCyJksws98ybrFlwCW0)wCiyh10dEE)7lXw8NaFl0z6bc(LW3seWddi)TAvTbGJ9mSr1HKgzWd9dhgk0z6bcwlHewRiDqa4PSH9tND91G6bu0OqNPhi43Ifhm9VfiYxdDgo(VVeLvEFc8TyXbt)BfaoQZU2iFW4BHotpqWVe(3xIYk7NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(TaXPiGghm9V1RSx7d(oWA5RwswYANhliAwB2RT1TUw2bR9bRTHPI(7RwGjcwBlnjqTTXZ8AbMyTCTZJfev7L1Aeiv0VAjbCrd0TRfWh4CwBa4o0TR9AWABbJdY0Bx7aTrhKJ2FlrapmG83IgO3vIbYHGNh0TvbYIRwt1sd07kXa5qWZd62Q5XcIQvAT0a9Usmqoe88GUTIKLuppwquTMQvKurN9trf9RPDuRPAfzoaZhxrcJiJPo76lds0pvGmy7AnvBRQLkhqMEGkK0iFWab10CeSnwRPAfzoaZhxXHGDuBKpyOcKbB)VVeLvoFc8TqNPhi4xcFlrapmG83Qv1gao2ZWgvhsAKbp0pCyOqNPhiyTMQLIABvTbGJ9mSr1eA0KUEEzqQqNPhiyTesyTuulvoGm9avgbAamgAKAwR0ALTwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1sCTe)TaXPiGghm9VLeZGKhJ21(G1AWWOwJ8GPxlWeR9bEn12YVQ51sdC1cVAFGJrTdEE1os3Uw0ta7MA7zulDEn1EnyTV(8vRLDWAB5xT2hOdMpZAb8boN1gaUdD7AVgSwlRAZOwcitw7aTrhKdio)wS4GP)TmYdM()(suwc6tGVf6m9ab)s4Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AjKWAncKQ2waQKvXHGDutZrW243Ifhm9VfiYxdDgo(VVeLvM9jW3cDMEGGFj8Teb8WaYFlAGExfaoQZU2iFWqbMpETesyTgbsvBlavYQ4qWoQP5iyB8BXIdM(3kyqi7NEAWbr)7lrzPSpb(wOZ0de8lHVLiGhgq(Brd07QaWrD21g5dgQajzOpR9LAPOwzATuQw5uBlP2aWXEg2OAcnAsxpVmivOZ0deSwI)wS4GP)TiHrKXuND9Lbj63)(suwz6NaFl0z6bc(LW3Ifhm9Vfhc2rTr(GX3ceNIaACW0)wYKnOxBa4o0TR9AWABbJdY0Bx7aTrhKJ2MxlWeRTLF1APXEgyTeiVwATxwliaPrTCTDGXODTZJfeHG1sZrW243seWddi)TOYbKPhOcjnYhmqqnnhbBJ1AQwAGExfaoQZU2iFWqbyuRPAPOws2zLH4Q9LAPOw5qz1sPAPOwzLxTTKAfjv0z)ue1oGSxlX1sCTesyT0a9Usmqoe88GUTAESGOALwlnqVRedKdbppOBRizj1ZJfevlX)7lrzFfFc8TqNPhi4xcFlrapmG83IkhqMEGkK0iFWab10CeSnwRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlPEESGOAnvlnqVR4qWoQnYhmuagFlwCW0)wCiyh10CeSn(VVeLvM)jW3cDMEGGFj8TyXbt)BntGXaVd626aGU93seWddi)TOb6Dva4Oo7AJ8bdfy(41siH1AeivTTaujRIdb7OMMJGTXAjKWAncKQ2waQKvfmiK9tpn4GOAjKWAPOwJaPQTfGkzvGiFn0z4yTMQTv1gao2ZWgvtOrt665LbPcDMEGG1s83Yzs8BntGXaVd626aGU9)(su2w8NaFl0z6bc(LW3seWddi)TOb6Dva4Oo7AJ8bdfy(41siH1AeivTTaujRIdb7OMMJGTXAjKWAncKQ2waQKvfmiK9tpn4GOAjKWAPOwJaPQTfGkzvGiFn0z4yTMQTv1gao2ZWgvtOrt665LbPcDMEGG1s83Ifhm9V1LaIgD21xdQjzB4)(suoY7tGVf6m9ab)s4Bjc4HbK)wgbsvBlavYQUeq0OZU(AqnjBd)wS4GP)T4qWoQnYhm(3xIYr2pb(wOZ0de8lHVfloy6FlJaNOlqD21Kqh8BbItranoy6FRwGjw7RMT0AVS2zlcaXwqyTSxlk5fCTTCiyhRvcdEE1cceq3U2RbRLa51sLrl)Q1(aDW8PwaFGZzTbG7q3U2woeSJ1ktiAsvTVYETTCiyhRvMq0K1cN1E8a9dbnV2hSwb7VVAbMyTVA2sR9bEnqV2RbRLa51sLrl)Q1(aDW8PwaFGZzTpyTq)WiamUAVgS2wULwROHDhhMx7mR9bFpg1ozQyTWt9Teb8WaYFRwv7Xd0pfhc2rnkAsf6m9abR1uTGinqVRUeq0OZU(AqnjBdvag1AQwqKgO3vxciA0zxFnOMKTHQajzOpR9fP1srTS4GPR4qWoQPh88uOKOa4q9bjXABj1sd07kJaNOlqD21KqhurYsQNhliQwI)3xIYroFc8TqNPhi4xcFlwCW0)wgborxG6SRjHo43ceNIaACW0)wVYETVA2sRTHN(7RwAe9AbMiyTGab0TR9AWAjqET0AFGoy(yETp47XOwGjwl8Q9YANTiaeBbH1YETOKxW12YHGDSwjm45vl0R9AWAF95RkJw(vR9b6G5J6Bjc4HbK)w0a9UIdb7O2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(I0APOwwCW0vCiyh10dEEkusuaCO(GKyTTKAPb6DLrGt0fOo7AsOdQizj1ZJfevlX)7lr5qqFc8TqNPhi4xcFlrapmG83cmpvWGq2p90GdIubsYqFwR8RLYQLqcRfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQv(1kVVfloy6FloeSJA6bpV)9LOCKzFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9VLmjw7d7xTxwljtew7eiWAFWAByQyTONa2n1sYoxBpJAVgSw0pyG12YVATpqhmFmVwKk61c71EnyGVN1op4yu7bjXAdKKHo0TRn9AF95RQQ9vEVN1M(ODT04Dyu7L1sdeETxwBlimYAzhSwzcQzTWETbG7q3U2RbR1YQ2mQLaYK1oqB0b5aIt13seWddi)TezoaZhxXHGDuBKpyOcKbBxRPAjzNvgIR2xQLIALzYRwkvlf1kR8QTLuRiPIo7NIO2bK9AjUwIR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLuppwquTMQLIABvTbGJ9mSr1eA0KUEEzqQqNPhiyTesyTu5aY0duzeObWyOrQzTsRv2AjUwt12QAdah7zyJQdjnYGh6homuOZ0deSwt12QAdah7zyJkoeSJ6goitVTcDMEGG)7lr5qzFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9VLe4iyBS2ztcmaR1ZRwASwGjcwlF1EnyTOdwB2RTLF1AH9ALjOMc(GPxlCwBGmy7A5zTGrAyaD7AfnCyJZAFGJrTKmryTWR2JjcRDKUng1EzT0aHx71ejGDtTbsYqh621sYo)Teb8WaYFlAGExXHGDuBKpyOamQ1uT0a9UIdb7O2iFWqfijd9zTViTwBbyTMQvK5amFCfsnf8btxfijd95)(suoY0pb(wOZ0de8lHVfloy6FloeSJAAoc2g)wG4ueqJdM(3scCeSnw7SjbgG1YJhU9SwAS2RbRDWZRwbpVAHETxdw7RpF1AFGoy(ulpRLa51sR9bog1g48YaR9AWAfnCyJZANgOFFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgQajzOpR9fP1AlaR1uTTQ2aWXEg2OIdb7OUHdY0BRqNPhi4)(suoVIpb(wOZ0de8lHVLOHH(3s2VfYXOTw0Wqxd7FlAGExjgihcEEq3wlAy3XHcmFCtuqd07koeSJAJ8bdfGbHesrRoEG(PsQyyKpyGGMOGgO3vbGJ6SRnYhmuagesOiZby(4kKAk4dMUkqgSnXet83seWddi)TarAGExDjGOrND91GAs2gQamQ1uThpq)uCiyh1OOjvOZ0deSwt1srT0a9Uce5RHodhvG5JxlHewlloivuJoscXzTsRv2AjUwt1cI0a9U6sarJo76Rb1KSnufijd9zTYVwwCW0vCiyh1KW5eoWPcLefahQpij(TyXbt)BXHGDutcNt4aN)7lr5iZ)e4BHotpqWVe(wS4GP)T4qWoQjHZjCGZVfiofb04GP)TEL9AFW3bwlv0VM2H51cjjrqiF4ODTatS2w36AFAqVwbByGG1EzTEE1(WZdR1isXS2EKK12stc8Teb8WaYFlrsfD2pfv0VM2rTMQLgO3vIbYHGNh0TvZJfevR0APb6DLyGCi45bDBfjlPEESGO)9LOCAXFc8TqNPhi4xcFlqCkcOXbt)BzDCC1cmHUDTTU112YT0AFAqV2w(vRTHN1sJOxlWeb)wIaEya5VfnqVRedKdbppOBRcKfxTMQvK5amFCfhc2rTr(GHkqsg6ZAnvlf1sd07QaWrD21g5dgkaJAjKWAPb6Dfhc2rTr(GHcWOwI)wIgg6Flz)wS4GP)T4qWoQjHZjCGZ)9LibjVpb(wOZ0de8lHVLiGhgq(Brd07koeSJArdh2OAESGOAFrATu5aY0duD5rQjzj1IgoSX53Ifhm9Vfhc2rDg0)7lrcs2pb(wOZ0de8lHVLiGhgq(Brd07QaWrD21g5dgkaJAjKWAjzNvgIRw5xRSu23Ifhm9Vfhc2rn9GN3)(sKGKZNaFl0z6bc(LW3Ifhm9Vfsnf8bt)Bb9dJaW40W(3IKDwzio5lvMtzFlOFyeagNgssIGq(WVLSFlrapmG83IgO3vbGJ6SRnYhmuG5JxRPAPb6Dfhc2rTr(GHcmF8)9LibrqFc8TyXbt)BXHGDutZrW243cDMEGGFj8V)9TI84dM(NaFjk7NaFl0z6bc(LW3Ifhm9Vfsnf8bt)BbItranoy6FRwGjwlsnRf2R9bFhyTJ8P20RLKDUw2bRvK5amF8zTCG1Y0jWv7L1sJ1cy8Teb8WaYFRwvBa4ypdBunHgnPRNxgKk0z6bcwRPAjzNvgIR2xKwlvoGm9avi1uBiUAnvlf1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwwCW0vi1uWhmDfkjkaouFqsSwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1YIdMUcPMc(GPRqjrbWH6dsI1siH1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFrATS4GPRqQPGpy6kusuaCO(GKyTexlX1AQwAGExfaoQZU2iFWqbMpETMQLgO3vCiyh1g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5JxRPABvTgbsvBlavYQUeq0OZU(AqnjBd)3xIY5tGVf6m9ab)s4Bjc4HbK)wbGJ9mSr1eA0KUEEzqQqNPhiyTMQTv1ksQOZ(POI(10oQ1uTImhG5JR4qWoQnYhmubsYqFw7lsRLfhmDfsnf8btxHsIcGd1hKe)wS4GP)TqQPGpy6)7lrc6tGVf6m9ab)s4Bjc4HbK)wbGJ9mSr1eA0KUEEzqQqNPhiyTMQvKurN9trf9RPDuRPAfzoaZhxrcJiJPo76lds0pvGKm0N1(I0AzXbtxHutbFW0vOKOa4q9bjXAnvRiZby(4Qlben6SRVgutY2qvGKm0N1(I0APOwQCaz6bQiZtBeOarq9LhPMUDTuQwwCW0vi1uWhmDfkjkaouFqsSwkvlbvlX1AQwrMdW8XvCiyh1g5dgQajzOpR9fP1srTu5aY0durMN2iqbIG6lpsnD7APuTS4GPRqQPGpy6kusuaCO(GKyTuQwcQwI)wS4GP)TqQPGpy6)7lrz2NaFl0z6bc(LW3Ifhm9Vfhc2rnnhbBJFlqCkcOXbt)Bjboc2gRf2RfEVN1EqsS2lRfyI1E5rwl7G1(G12WuXAVmRLK921kA4WgNFlrapmG83sK5amFC1LaIgD21xdQjzBOkqgSDTMQLIAPb6Dfhc2rTOHdBunpwquTYVwQCaz6bQU8i1KSKArdh24Swt1kYCaMpUIdb7O2iFWqfijd9zTViTwusuaCO(GKyTMQLKDwziUALFTu5aY0duXgAsOdjbi1KSZAdXvRPAPb6Dva4Oo7AJ8bdfy(41s8)(sKY(e4BHotpqWVe(wIaEya5VLiZby(4Qlben6SRVgutY2qvGmy7Anvlf1sd07koeSJArdh2OAESGOALFTu5aY0duD5rQjzj1IgoSXzTMQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7lsRfLefahQpijwRPAPYbKPhO6GKOgWp4qZg1k)APYbKPhO6YJutYsQbXb3w3ZqZg1s83Ifhm9Vfhc2rnnhbBJ)7lrz6NaFl0z6bc(LW3seWddi)TezoaZhxDjGOrND91GAs2gQcKbBxRPAPOwAGExXHGDulA4WgvZJfevR8RLkhqMEGQlpsnjlPw0WHnoR1uTuuBRQ94b6NkaCuNDTr(GHcDMEGG1siH1kYCaMpUkaCuNDTr(GHkqsg6ZALFTu5aY0duD5rQjzj1G4GBR7zOJ0OwIR1uTu5aY0duDqsud4hCOzJALFTu5aY0duD5rQjzj1G4GBR7zOzJAj(BXIdM(3Idb7OMMJGTX)9L4R4tGVf6m9ab)s4Bjc4HbK)wGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwquTsRfePb6DvWGq2p90GdI0ubgogmnCaV2ksws98ybr1AQwkQLgO3vCiyh1g5dgkW8XRLqcRLgO3vCiyh1g5dgQajzOpR9fP1AlaRL4Anvlf1sd07QaWrD21g5dgkW8XRLqcRLgO3vbGJ6SRnYhmubsYqFw7lsR1wawlXFlwCW0)wCiyh10CeSn(VVeL5Fc8TqNPhi4xcFlrapmG83IkhqMEGQwyG5PbMiOEAWbr1siH1srTGinqVRcgeY(PNgCqKMkWWXGPHd41wbyuRPAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOAFPwqKgO3vbdcz)0tdoistfy4yW0Wb8ARizj1ZJfevlXFlwCW0)wCiyh10dEE)7lXw8NaFl0z6bc(LW3seWddi)TOb6DLrGt0fOo7AsOdQamQ1uTGinqVRUeq0OZU(AqnjBdvag1AQwqKgO3vxciA0zxFnOMKTHQajzOpR9fP1YIdMUIdb7OMEWZtHsIcGd1hKe)wS4GP)T4qWoQPh88(3xIYkVpb(wOZ0de8lHVLOHH(3s2VfYXOTw0Wqxd7FlAGExjgihcEEq3wlAy3XHcmFCtuqd07koeSJAJ8bdfGbHesrRoEG(PsQyyKpyGGMOGgO3vbGJ6SRnYhmuagesOiZby(4kKAk4dMUkqgSnXet83seWddi)TarAGExDjGOrND91GAs2gQamQ1uThpq)uCiyh1OOjvOZ0deSwt1srT0a9Uce5RHodhvG5JxlHewlloivuJoscXzTsRv2AjUwt1srTGinqVRUeq0OZU(AqnjBdvbsYqFwR8RLfhmDfhc2rnjCoHdCQqjrbWH6dsI1siH1kYCaMpUYiWj6cuNDnj0bvbsYqFwlHewRiPIo7NIO2bK9Aj(BXIdM(3Idb7OMeoNWbo)3xIYk7NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(TaXPiGghm9VvRtFcqI1EnyTOKgSdIG1AKh6hKh1sd071Yt2O2lR1ZR2roXAnYd9dYJAnIum)wIaEya5VfnqVRedKdbppOBRcKfxTMQLgO3vOKgSdIGAJ8q)G8qby8VVeLvoFc8TqNPhi4xcFlwCW0)wCiyh1KW5eoW53s0Wq)Bj73seWddi)TOb6DLyGCi45bDBvGS4Q1uTuulnqVR4qWoQnYhmuag1siH1sd07QaWrD21g5dgkaJAjKWAbrAGExDjGOrND91GAs2gQcKKH(Sw5xlloy6koeSJAs4Cch4uHsIcGd1hKeRL4)9LOSe0NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(Tenm0)wY(Teb8WaYFlAGExjgihcEEq3wfilUAnvlnqVRedKdbppOBRMhliQwP1sd07kXa5qWZd62ksws98ybr)7lrzLzFc8TqNPhi4xcFlqCkcOXbt)B1YJhU9S2lAx7L1sZor126wxBpJAfzoaZhV2hOdMpZAPbUAbbinQ9AqYAH9AVgS97aRLPtGR2lRfL0ag43seWddi)TOb6DLyGCi45bDBvGS4Q1uT0a9Usmqoe88GUTkqsg6ZAFrATuulf1sd07kXa5qWZd62Q5XcIQTLulloy6koeSJAs4Cch4uHsIcGd1hKeRL4APuT2cqfjlzTe)Tenm0)wY(TyXbt)BXHGDutcNt4aN)7lrzPSpb(wOZ0de8lHVLiGhgq(BrrTb2dC2W0dSwcjS2wv7bfebD7AjUwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1AQwAGExXHGDuBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubMp(3Ifhm9VLJxdg6djnW59VVeLvM(jW3cDMEGGFj8Teb8WaYFlAGExXHGDulA4WgvZJfev7lsRLkhqMEGQlpsnjlPw0WHno)wS4GP)T4qWoQZG(FFjk7R4tGVf6m9ab)s4Bjc4HbK)wu5aY0duLa3ecI6SRfzoaZhFwRPAjzNvgIR2xKwBlMY(wS4GP)TMagy4jv(FFjkRm)tGVf6m9ab)s4Bjc4HbK)w0a9UkagOo76RjqCQamQ1uT0a9UIdb7Ow0WHnQMhliQw5xlb9TyXbt)BXHGDutp459VVeLTf)jW3cDMEGGFj8TyXbt)BXHGDutZrW243ceNIaACW0)wVUaqAuROHdBCwlSx7dwBNhJAPXr(u71G1ksFIbvSws25AVMaNn5aSw2bRfPMc(GPxlCw78GJrTPxRiZby(4FlrapmG83Qv1gao2ZWgvtOrt665LbPcDMEGG1AQwQCaz6bQsGBcbrD21ImhG5JpR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLuppwquTMQ94b6NIdb7OodAf6m9abR1uTImhG5JR4qWoQZGwfijd9zTViTwBbyTMQLKDwziUAFrATTy5vRPAfzoaZhxHutbFW0vbsYqF(VVeLJ8(e4BHotpqWVe(wIaEya5Vva4ypdBunHgnPRNxgKk0z6bcwRPAPYbKPhOkbUjee1zxlYCaMp(Swt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1AQ2JhOFkoeSJ6mOvOZ0deSwt1kYCaMpUIdb7OodAvGKm0N1(I0ATfG1AQws2zLH4Q9fP12ILxTMQvK5amFCfsnf8btxfijd9zTVulbjVVfloy6FloeSJAAoc2g)3xIYr2pb(wOZ0de8lHVfloy6FloeSJAAoc2g)wG4ueqJdM(361fasJAfnCyJZAH9AZGUw4S2azW2FlrapmG83IkhqMEGQe4MqquNDTiZby(4ZAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPApEG(P4qWoQZGwHotpqWAnvRiZby(4koeSJ6mOvbsYqFw7lsR1wawRPAjzNvgIR2xKwBlwE1AQwrMdW8Xvi1uWhmDvGKm0N1AQwkQTv1gao2ZWgvtOrt665LbPcDMEGG1siH1sd07Qj0OjD98YGufijd9zTViTwzL51s8)(suoY5tGVf6m9ab)s4BXIdM(3Idb7OMMJGTXVfiofb04GP)TA5qWowRe4iyBS2ztcmaR1gDm4XODT0yTxdw7GNxTcEE1M9AVgS2w(vR9b6G5Z3seWddi)TOb6Dfhc2rTr(GHcWOwt1sd07koeSJAJ8bdvGKm0N1(I0ATfG1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYsQNhliQwt1srTImhG5JRqQPGpy6QajzOpRLqcRnaCSNHnQ4qWoQB4Gm92k0z6bcwlX)7lr5qqFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9Vvlhc2XALahbBJ1oBsGbyT2OJbpgTRLgR9AWAh88QvWZR2Sx71G1(6ZxT2hOdMpFlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgQajzOpR9fP1AlaR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLuppwquTMQLIAfzoaZhxHutbFW0vbsYqFwlHewBa4ypdBuXHGDu3Wbz6TvOZ0deSwI)3xIYrM9jW3cDMEGGFj8TyXbt)BXHGDutZrW243ceNIaACW0)wTCiyhRvcCeSnw7SjbgG1sJ1EnyTdEE1k45vB2R9AWAjqET0AFGoy(ulSxl8QfoR1ZRwGjcw7d8AQ91NVATzuBl)QFlrapmG83IgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfGrTMQfePb6D1LaIgD21xdQjzBOkqsg6ZAFrAT2cWAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfe9VVeLdL9jW3cDMEGGFj8TyXbt)BXHGDutZrW243ceNIaACW0)wYKnOx71G1ECyJxTWzTqVwusuaCyTb72yTSdw71GbwlCwlzgyTxd71Mowl6izBZRfyI1sZrW2yT8S2zMET8S22jqTnmvSw0ta7MAfnCyJZAVS2g4vlpg1IoscXzTWETxdwBlhc2XALqssZbij6xTd0gDqoAxlCwl2IaGggi43seWddi)TOYbKPhOcjnYhmqqnnhbBJ1AQwAGExXHGDulA4WgvZJfevR8Lwlf1YIdsf1OJKqCwBluTYwlX1AQwwCqQOgDKeIZALFTYwRPAPb6DfiYxdDgoQaZh)FFjkhz6NaFl0z6bc(LW3seWddi)TOYbKPhOcjnYhmqqnnhbBJ1AQwAGExXHGDulA4WgvZJfev7l1sd07koeSJArdh2OIKLuppwquTMQLfhKkQrhjH4Sw5xRS1AQwAGExbI81qNHJkW8X)wS4GP)T4qWoQrjng5eM()(suoVIpb(wS4GP)T4qWoQPh88(wOZ0de8lH)9LOCK5Fc8TqNPhi4xcFlrapmG83IkhqMEGQe4MqquNDTiZby(4ZVfloy6FlKAk4dM()(suoT4pb(wS4GP)T4qWoQP5iyB8BHotpqWVe(3)(wImhG5Jp)e4lrz)e4BHotpqWVe(wS4GP)T6ropTNu5Vfiofb04GP)TE1aMb8GTGWAbMq3Uw7aohTRfkGIbw7d8AQLnu12cmXAHxTpWRP2lpYAZRbJh4evFlrapmG83kaCSNHnQSd4C0wdfqXavOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwcsE1AQwrMdW8XvxciA0zxFnOMKTHQazW21AQwkQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhO6YJutYsQfnCyJZAnvlf1srThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUkaCuNDTr(GHkqsg6ZAFrAT2cWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APYbKPhO6YJutYsQbXb3w3ZqZg1sCTesyTuuBRQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sLditpq1LhPMKLudIdUTUNHMnQL4AjKWAfzoaZhxXHGDuBKpyOcKKH(S2xKwRTaSwIRL4)9LOC(e4BHotpqWVe(wIaEya5Vva4ypdBuzhW5OTgkGIbQqNPhiyTMQvK5amFCfhc2rTr(GHkqgSDTMQLIABvThpq)uOpG2nh6iOcDMEGG1siH1srThpq)uOpG2nh6iOcDMEGG1AQws2zLH4Qv(sR9viVAjUwIR1uTuulf1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwzLxTMQLgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSK65XcIQL4AjKWAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRvATYRwt1sd07koeSJArdh2OAESGOALwR8QL4AjUwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8LwlvoGm9avSHMe6qsasnj7S2qCFlwCW0)w9iNN2tQ8)(sKG(e4BHotpqWVe(wIaEya5Vva4ypdBubcNcOXa6C0wlsss2bvOZ0deSwt1kYCaMpUIgO31GWPaAmGohT1IKKKDqvGmy7AnvlnqVRaHtb0yaDoARfjjj7G6EKZtbMpETMQLIAPb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubMpETexRPAfzoaZhxDjGOrND91GAs2gQcKKH(SwP1kVAnvlf1sd07koeSJArdh2OAESGOAFrATu5aY0duD5rQjzj1IgoSXzTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwBbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzj1G4GBR7zOzJAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APYbKPhO6YJutYsQbXb3w3ZqZg1sCTesyTImhG5JR4qWoQnYhmubsYqFw7lsR1wawlX1s83Ifhm9VvpY5rNJ7FFjkZ(e4BHotpqWVe(wIaEya5Vva4ypdBubcNcOXa6C0wlsss2bvOZ0deSwt1kYCaMpUIgO31GWPaAmGohT1IKKKDqvGmy7AnvlnqVRaHtb0yaDoARfjjj7G6omqfy(41AQwJaPQTfGkzv9iNhDoUVfloy6FRomqn9GN3)(sKY(e4BHotpqWVe(wS4GP)TiHrKXuND9Lbj633ceNIaACW0)wVkdJABPjbQ9bEn12YVATWETW79SwrscD7AbmQDMPRQ9v2RfE1(ahJAPXAbMiyTpWRPwcKxl18Af88QfE1ohq7MB0UwASNb(Teb8WaYFlkQTv1gao2ZWgvtOrt665LbPcDMEGG1siH1sd07Qj0OjD98YGubyulX1AQwrMdW8XvxciA0zxFnOMKTHQajzOpR9LAPYbKPhOImpTrGceb1xEKA621siH1srTu5aY0duDqsud4hCOzJALFTu5aY0durMNMKLudIdUTUNHMnQ1uTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RLkhqMEGkY80KSKAqCWT19m0xEK1s8)(suM(jW3cDMEGGFj8Teb8WaYFlrMdW8XvCiyh1g5dgQazW21AQwkQTv1E8a9tH(aA3COJGk0z6bcwlHewlf1E8a9tH(aA3COJGk0z6bcwRPAjzNvgIRw5lT2xH8QL4AjUwt1srTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)APYbKPhOIn0KSKAqCWT19m0xEK1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYsQNhliQwIRLqcRLIAfzoaZhxDjGOrND91GAs2gQcKKH(SwP1kVAnvlnqVR4qWoQfnCyJQ5XcIQvATYRwIRL4AnvlnqVRcah1zxBKpyOaZhVwt1sYoRmexTYxATu5aY0duXgAsOdjbi1KSZAdX9TyXbt)BrcJiJPo76lds0V)9L4R4tGVf6m9ab)s4Bjc4HbK)wu5aY0duLa3ecI6SRfzoaZhFwRPAPO2zcmOHoOIAo4doq9mhur)uOZ0deSwcjS2zcmOHoOYayEaduJbGXbtxHotpqWAj(BXIdM(3QpWzJi4(9VVeL5Fc8TqNPhi4xcFlwCW0)wGiFn0z443ceNIaACW0)wT84HBpRfyI1cI81qNHJ1(aVMAzdvTVYETxEK1cN1gid2UwEw7dogMxljtew7eiWAVSwbpVAHxT0ypdS2lps13seWddi)TezoaZhxDjGOrND91GAs2gQcKbBxRPAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQU8i1KSKArdh24Swt1kYCaMpUIdb7O2iFWqfijd9zTViTwBb4)(sSf)jW3cDMEGGFj8Teb8WaYFlrMdW8XvCiyh1g5dgQazW21AQwkQTv1E8a9tH(aA3COJGk0z6bcwlHewlf1E8a9tH(aA3COJGk0z6bcwRPAjzNvgIRw5lT2xH8QL4AjUwt1srTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)ALvE1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYsQNhliQwIRLqcRLIAfzoaZhxDjGOrND91GAs2gQcKbBxRPAPb6Dfhc2rTOHdBunpwquTsRvE1sCTexRPAPb6Dva4Oo7AJ8bdfy(41AQws2zLH4Qv(sRLkhqMEGk2qtcDijaPMKDwBiUVfloy6FlqKVg6mC8FFjkR8(e4BHotpqWVe(wS4GP)TcgeY(PNgCq03ceNIaACW0)wTatS2PbhevlSx7LhzTSdwlBulhyTPxRaSw2bR9j93xT0yTag12ZO2r62yu71WETxdwljlzTG4GBBETKmrq3U2jqG1(G12WuXA5R2bYZR27jRLdb7yTIgoSXzTSdw71WxTxEK1(Wt)9vBlmW8QfyIGQVLiGhgq(BjYCaMpU6sarJo76Rb1KSnufijd9zTYVwQCaz6bQIPMKLudIdUTUNH(YJSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQIPMKLudIdUTUNHMnQ1uTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTuuRiZby(4QaWrD21g5dgQajzOpR9LArjrbWH6dsI1siH1kYCaMpUkaCuNDTr(GHkqsg6ZALFTu5aY0duftnjlPgehCBDpdDKg1sCTesyTTQ2JhOFQaWrD21g5dgk0z6bcwlX1AQwAGExXHGDulA4WgvZJfevR8Rvo1AQwqKgO3vxciA0zxFnOMKTHkW8XR1uT0a9UkaCuNDTr(GHcmF8AnvlnqVR4qWoQnYhmuG5J)VVeLv2pb(wOZ0de8lHVfloy6FRGbHSF6Pbhe9TaXPiGghm9VvlWeRDAWbr1(aVMAzJAFAqVwJCoH0duv7RSx7LhzTWzTbYGTRLN1(GJH51sYeH1obcS2lRvWZRw4vln2ZaR9YJu9Teb8WaYFlrMdW8XvxciA0zxFnOMKTHQajzOpR9LArjrbWH6dsI1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGQlpsnjlPw0WHnoR1uTImhG5JR4qWoQnYhmubsYqFw7l1srTOKOa4q9bjXAPuTS4GPRUeq0OZU(AqnjBdvOKOa4q9bjXAj(FFjkRC(e4BHotpqWVe(wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1(sTOKOa4q9bjXAnvlf1srTTQ2JhOFk0hq7MdDeuHotpqWAjKWAPO2JhOFk0hq7MdDeuHotpqWAnvlj7SYqC1kFP1(kKxTexlX1AQwkQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlvoGm9avSHMKLudIdUTUNH(YJSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1sCTesyTuuRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5vRPAPb6Dfhc2rTOHdBunpwquTsRvE1sCTexRPAPb6Dva4Oo7AJ8bdfy(41AQws2zLH4Qv(sRLkhqMEGk2qtcDijaPMKDwBiUAj(BXIdM(3kyqi7NEAWbr)7lrzjOpb(wOZ0de8lHVfloy6FRzcmg4Dq3wha0T)wIaEya5Vff12QAdah7zyJQj0OjD98YGuHotpqWAjKWAPb6D1eA0KUEEzqQamQL4AnvlnqVR4qWoQfnCyJQ5XcIQ9fP1sLditpq1LhPMKLulA4WgN1AQwrMdW8XvCiyh1g5dgQajzOpR9fP1IsIcGd1hKeR1uTKSZkdXvR8RLkhqMEGk2qtcDijaPMKDwBiUAnvlnqVRcah1zxBKpyOaZh)B5mj(TMjWyG3bDBDaq3(FFjkRm7tGVf6m9ab)s4BXIdM(36sarJo76Rb1KSn8BbItranoy6FRwGjw7LhzTpWRPw2OwyVw49Ew7d8AGETxdwljlzTG4GBRQ9v2R1ZZ8AbMyTpWRP2inQf2R9AWApEG(vlCw7XeHU51YoyTW79S2h41a9AVgSwswYAbXb3w9Teb8WaYFlkQTv1gao2ZWgvtOrt665LbPcDMEGG1siH1sd07Qj0OjD98YGubyulX1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGQlpsnjlPw0WHnoR1uTImhG5JR4qWoQnYhmubsYqFw7lsRfLefahQpijwRPAjzNvgIRw5xlvoGm9avSHMe6qsasnj7S2qC1AQwAGExfaoQZU2iFWqbMp()(suwk7tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avxEKAswsTOHdBCwRPApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ArjrbWH6dsI1AQwQCaz6bQoijQb8do0SrTYVwQCaz6bQU8i1KSKAqCWT19m0SX3Ifhm9V1LaIgD21xdQjzB4)(suwz6NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTOHdBunpwquTViTwQCaz6bQU8i1KSKArdh24Swt1srTTQ2JhOFQaWrD21g5dgk0z6bcwlHewRiZby(4QaWrD21g5dgQajzOpRv(1sLditpq1LhPMKLudIdUTUNHosJAjUwt1sLditpq1bjrnGFWHMnQv(1sLditpq1LhPMKLudIdUTUNHMn(wS4GP)TUeq0OZU(AqnjBd)3xIY(k(e4BHotpqWVe(wS4GP)T4qWoQnYhm(wG4ueqJdM(3QfyI1Yg1c71E5rwlCwB61kaRLDWAFs)9vlnwlGrT9mQDKUng1EnSx71G1sYswlio42Mxljte0TRDceyTxdF1(G12WuXArpbSBQLKDUw2bR9A4R2RbdSw4SwpVA5rGmy7A5AdahRn71AKpyuly(4QVLiGhgq(BjYCaMpU6sarJo76Rb1KSnufijd9zTYVwQCaz6bQydnjlPgehCBDpd9LhzTMQLIABvTIKk6SFkQOFnTJAjKWAfzoaZhxrcJiJPo76lds0pvGKm0N1k)APYbKPhOIn0KSKAqCWT19m0K5vlX1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYsQNhliQwt1sd07QaWrD21g5dgkW8XR1uTKSZkdXvR8LwlvoGm9avSHMe6qsasnj7S2qC)7lrzL5Fc8TqNPhi4xcFlwCW0)wbGJ6SRnYhm(wG4ueqJdM(3QfyI1gPrTWETxEK1cN1METcWAzhS2N0FF1sJ1cyuBpJAhPBJrTxd71EnyTKSK1cIdUT51sYebD7ANabw71GbwlC6VVA5rGmy7A5AdahRfmF8AzhS2RHVAzJAFs)9vlnkssSwMkdhm9aRfeiGUDTbGJQVLiGhgq(Brd07koeSJAJ8bdfy(41AQwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALFTu5aY0dufPHMKLudIdUTUNH(YJSwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1sLditpq1LhPMKLudIdUTUNHMnQL4AnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xRSYRwt1kYCaMpU6sarJo76Rb1KSnufijd9zTYVwzL3)(su2w8NaFl0z6bc(LW3seWddi)TOYbKPhOkbUjee1zxlYCaMp(8BXIdM(3A2a7h0T1g5dg)7lr5iVpb(wOZ0de8lHVfloy6FlJaNOlqD21Kqh8BbItranoy6FRwGjwRrsw7L1oBrai2ccRL9ArjVGRLPRf61EnyTok5vRiZby(41(aDW8X8Ab8boN1su7aYETxd61M(ODTGab0TRLdb7yTg5dg1ccG1EzTn5tTKSZ12a42r7AdgeY(v70GdIQfo)wIaEya5V1Xd0pva4Oo7AJ8bdf6m9abR1uT0a9UIdb7O2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(sT2cqfjl5)(suoY(jW3cDMEGGFj8Teb8WaYFlqKgO3vxciA0zxFnOMKTHkaJAnvlisd07Qlben6SRVgutY2qvGKm0N1(sTS4GPR4qWoQjHZjCGtfkjkaouFqsSwt12QAfjv0z)ue1oGS)TyXbt)Bze4eDbQZUMe6G)7lr5iNpb(wOZ0de8lHVLiGhgq(Brd07QaWrD21g5dgkaJAnvlnqVRcah1zxBKpyOcKKH(S2xQ1waQizjR1uTImhG5JRqQPGpy6QazW21AQwrMdW8XvxciA0zxFnOMKTHQajzOpR1uTTQwrsfD2pfrTdi7FlwCW0)wgborxG6SRjHo4)(33ce7mW4(e4lrz)e4BXIdM(3sKa(HX0ahJVf6m9ab)s4FFjkNpb(wOZ0de8lHVLiGhgq(BrrThpq)uOpG2nh6iOcDMEGG1AQws2zLH4Q9fP1kZLxTMQLKDwziUALV0ALPuwTexlHewlf12QApEG(PqFaTBo0rqf6m9abR1uTKSZkdXv7lsRvMtz1s83Ifhm9Vfj7S2gj)3xIe0NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3Yipy6)7lrz2NaFl0z6bc(LW3seWddi)Tcah7zyJQdjnYGh6homuOZ0deSwt1sd07kuYggyEW0vag1AQwkQvK5amFCfhc2rTr(GHkqgSDTesyT05CwRPA7q7Mthijd9zTViTwzM8QL4Vfloy6FRdsI6hom(3xIu2NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcmF8AnvlnqVRcah1zxBKpyOaZhVwt1cI0a9U6sarJo76Rb1KSnubMp(3Ifhm9V1aA3CtDlmaOnj63)(suM(jW3cDMEGGFj8Teb8WaYFlAGExXHGDuBKpyOaZhVwt1sd07QaWrD21g5dgkW8XR1uTGinqVRUeq0OZU(AqnjBdvG5J)TyXbt)BrZ26SRVakiA(VVeFfFc8TqNPhi4xcFlrapmG83IgO3vCiyh1g5dgkaJVfloy6FlAmMyqe0T)3xIY8pb(wOZ0de8lHVLiGhgq(Brd07koeSJAJ8bdfGX3Ifhm9Vf9itqDhiA)VVeBXFc8TqNPhi4xcFlrapmG83IgO3vCiyh1g5dgkaJVfloy6FRomq6rMG)7lrzL3NaFl0z6bc(LW3seWddi)TOb6Dfhc2rTr(GHcW4BXIdM(3IDboVGhAbpg)7lrzL9tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7O2iFWqby8TyXbt)Bbmrn8qY5)(suw58jW3cDMEGGFj8TyXbt)BzpyqiFzm10mOn(Teb8WaYFlAGExXHGDuBKpyOamQLqcRvK5amFCfhc2rTr(GHkqsg6ZALV0APmkRwt1cI0a9U6sarJo76Rb1KSnuby8TWEhfN2zs8BzpyqiFzm10mOn(VVeLLG(e4BHotpqWVe(wS4GP)TqsJ2bYdDgGo7c8Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7lsRvwkRwt1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwzPSVLZK43cjnAhip0za6SlW)9LOSYSpb(wOZ0de8lHVfloy6FlWazWomqnvCoXX3seWddi)TezoaZhxXHGDuBKpyOcKKH(Sw5lTw5iVAjKWABvTu5aY0duXg601atSwP1kBTesyTuu7bjXALwR8Q1uTu5aY0du1HZgOBRtd0XOwP1kBTMQnaCSNHnQMqJM01Zldsf6m9abRL4VLZK43cmqgSddutfNtC8VVeLLY(e4BHotpqWVe(wS4GP)TMjWqdTD4HX3seWddi)TezoaZhxXHGDuBKpyOcKKH(Sw5lTwcsE1siH12QAPYbKPhOIn0PRbMyTsRv2VLZK43AMadn02Hhg)7lrzLPFc8TqNPhi4xcFlwCW0)w2J2gn6SR55esch8bt)Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFwR8LwRCKxTesyTTQwQCaz6bQydD6AGjwR0ALTwcjSwkQ9GKyTsRvE1AQwQCaz6bQ6Wzd0T1Pb6yuR0ALTwt1gao2ZWgvtOrt665LbPcDMEGG1s83Yzs8BzpAB0OZUMNtijCWhm9)9LOSVIpb(wOZ0de8lHVfloy6FlswW0bQNniEAsGju8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpR9fP1sz1AQwkQTv1sLditpqvhoBGUTonqhJALwRS1siH1EqsSw5xlbjVAj(B5mj(TizbthOE2G4PjbMqX)(suwz(NaFl0z6bc(LW3Ifhm9Vfjly6a1ZgepnjWek(wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1(I0APSAnvlvoGm9avD4Sb6260aDmQvATYwRPAPb6Dva4Oo7AJ8bdfGrTMQLgO3vbGJ6SRnYhmubsYqFw7lsRLIALvE12cvlLvBlP2aWXEg2OAcnAsxpVmivOZ0deSwIR1uThKeR9LAji59TCMe)wKSGPdupBq80KatO4FFjkBl(tGVf6m9ab)s4BXIdM(3A2WG5dcQZGwND9Lbj633seWddi)ToijwR0ALxTesyTuulvoGm9avjWnHGOo7ArMdW8XN1AQwkQLIAfjv0z)ue1oGSxRPAfzoaZhxfmiK9tpn4GivGKm0N1(I0ALtTMQvK5amFCfhc2rTr(GHkqsg6ZAFrATuwTMQvK5amFC1LaIgD21xdQjzBOkqsg6ZAFrATuwTexlHewRiZby(4koeSJAJ8bdvGKm0N1(I0ALtTesyTDODZPdKKH(S2xQvK5amFCfhc2rTr(GHkqsg6ZAjUwI)wotIFRzddMpiOodAD21xgKOF)7lr5iVpb(wOZ0de8lHVfiofb04GP)TOmLmTw4S2RbRDAGiyTzV2RbR1kbgd8oOBx7RhGUDTgr2cJIdoWVLZK43AMaJbEh0T1baD7VLiGhgq(BrrTu5aY0duDqsud4hCOzJAPuTuulloy6QGbHSF6PbhePqjrbWH6dsI12sQvKurN9tru7aYETexlLQLIAzXbtxbI81qNHJkusuaCO(GKyTTKAfjv0z)uokICKbyTexlLQLfhmD1LaIgD21xdQjzBOcLefahQpijw7l1ECyJNceop2fyTYOwktjtRL4Anvlf1sLditpqvdtf1Pb6iyTesyTuuRiPIo7NIO2bK9AnvBa4ypdBuXHGDud9o0HxBf6m9abRL4AjUwt1ECyJNceop2fyTYVw5qzFlwCW0)wZeymW7GUToaOB)VVeLJSFc8TqNPhi4xcFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wcEiag8btF(VVeLJC(e4BHotpqWVe(wIaEya5VfloivuJoscXzTYxATu5aY0duXjQpoSXtlsa)(wZlGI7lrz)wS4GP)Te8yOzXbtxpGZ7BnGZt7mj(T4e)3xIYHG(e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0de8BXIdM(3sWJHMfhmD9aoVV1aopTZK43QHdY0B)VVeLJm7tGVf6m9ab)s4Bjc4HbK)wu5aY0du1WurDAGocwR0ALxTMQLkhqMEGQoC2aDBDAGog1AQ2wvlf1ksQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abRL4Vfloy6FlbpgAwCW01d48(wd480otIFRoC2aDBDAGog)7lr5qzFc8TqNPhi4xcFlrapmG83IkhqMEGQgMkQtd0rWALwR8Q1uTTQwkQvKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwlXFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wPb6y8VVeLJm9tGVf6m9ab)s4Bjc4HbK)wTQwkQvKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwlXFlwCW0)wcEm0S4GPRhW59TgW5PDMe)wImhG5Jp)3xIY5v8jW3cDMEGGFj8Teb8WaYFlQCaz6bQ6qNhAAGWRvATYRwt12QAPOwrsfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTe)TyXbt)Bj4XqZIdMUEaN33AaNN2zs8Bf5Xhm9)9LOCK5Fc8TqNPhi4xcFlrapmG83IkhqMEGQo05HMgi8ALwRS1AQ2wvlf1ksQOZ(PiQDazVwt1gao2ZWgvCiyh1nCqMEBf6m9abRL4Vfloy6FlbpgAwCW01d48(wd480otIFRo05HMgi8)9VVLrGIKKMVpb(su2pb(wS4GP)T4qWoQH(HJbkUVf6m9ab)s4FFjkNpb(wS4GP)TMaKKPR5qWoQ7mjCa54BHotpqWVe(3xIe0NaFlwCW0)wI0BHbcutYoRTrYVf6m9ab)s4FFjkZ(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43ItuFCyJNwKa(9TaXodmUVfb9VVePSpb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(TqQP2qCFlqSZaJ7BjlL9VVeLPFc8TqNPhi4xcFR04BnX7BXIdM(3IkhqMEGFlQCODMe)wgbAamgAKA(Teb8WaYFlkQnaCSNHnQMqJM01Zldsf6m9abR1uTuuRiPIo7NIk6xt7OwcjSwrsfD2pLJIihzawlHewRiDqa4P4qWoQnIeeA3wHotpqWAjUwI)wu5baQXXe)wY7BrLha43s2)9L4R4tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLdTZK43QHPI60aDe8Bjc4HbK)wS4Gurn6ijeN1kFP1sLditpqfNO(4WgpTib87BrLhaOght8BjVVfvEaGFlz)3xIY8pb(wOZ0de8lHVvA8TM49TyXbt)BrLditpWVfvEaGFl59TOYH2zs8B1Hop00aH)VVeBXFc8TqNPhi4xcFR04Bf4eVVfloy6FlQCaz6b(TOYH2zs8B1Wbz6T1ZJfePpij(TaXodmUVvl(FFjkR8(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43IhpC7PE22fArMdW8XNFlqSZaJ7BjV)9LOSY(jW3cDMEGGFj8TsJVvGt8(wS4GP)TOYbKPh43IkhANjXVvm1KSKAqCWT19m0xEKFlqSZaJ7Brz)7lrzLZNaFl0z6bc(LW3kn(wboX7BXIdM(3IkhqMEGFlQCODMe)wXutYsQbXb3w3ZqhPX3ce7mW4(wu2)(suwc6tGVf6m9ab)s4BLgFRaN49TyXbt)BrLditpWVfvo0otIFRyQjzj1G4GBR7zOzJVfi2zGX9TKJ8(3xIYkZ(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43ImpTrGceb1xEKA62FlqSZaJ7BjZ)3xIYszFc8TqNPhi4xcFR04Bf4eVVfloy6FlQCaz6b(TOYH2zs8BrMNMKLudIdUTUNH(YJ8BbIDgyCFlzL3)(suwz6NaFl0z6bc(LW3kn(wboX7BXIdM(3IkhqMEGFlQCODMe)wK5Pjzj1G4GBR7zOzJVfi2zGX9TKLY(3xIY(k(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43In0KSKAqCWT19m0xEKFlrapmG83sKoia8uCiyh1grccTB)TOYdauJJj(TKvEFlQ8aa)weK8(3xIYkZ)e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK43In0KSKAqCWT19m0xEKFlqSZaJ7Bjh59VVeLTf)jW3cDMEGGFj8TsJVvGt8(wS4GP)TOYbKPh43IkhANjXVfBOjzj1G4GBR7zOjZ7BbIDgyCFl5iV)9LOCK3NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVLCKxTTq1srTuwTTKAfPdcapfhc2rTrKGq72k0z6bcwlXFlQCODMe)wrAOjzj1G4GBR7zOV8i)3xIYr2pb(wOZ0de8lHVvA8TM49TyXbt)BrLditpWVfvEaGFlkRwkvRCKxTTKAPOwrsfD2pLdTBoDNXAjKWAPOwr6GaWtXHGDuBeji0UTcDMEGG1AQwwCqQOgDKeIZAFPwQCaz6bQ4e1hh24PfjGF1sCTexlLQvwkR2wsTuuRiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1YIdsf1OJKqCwR8LwlvoGm9avCI6JdB80IeWVAj(BrLdTZK436YJutYsQbXb3w3ZqZg)7lr5iNpb(wOZ0de8lHVvA8TM49TyXbt)BrLditpWVfvEaGFl5iVABHQLIAL512sQvKoia8uCiyh1grccTBRqNPhiyTe)TOYH2zs8BD5rQjzj1G4GBR7zOJ04FFjkhc6tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43sMkVABHQLIAj55HrBnvEaG12sQvw5jVAj(Bjc4HbK)wIKk6SFkhA3C6oJFlQCODMe)w0CeSnQjzN1gI7FFjkhz2NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVvlMYQTfQwkQLKNhgT1u5bawBlPwzLN8QL4VLiGhgq(BjsQOZ(PiQDaz)BrLdTZK43IMJGTrnj7S2qC)7lr5qzFc8TqNPhi4xcFR04BnX7BXIdM(3IkhqMEGFlQ8aa)wYC5vBluTuuljppmARPYdaS2wsTYkp5vlXFlrapmG83IkhqMEGkAoc2g1KSZAdXvR0AL33IkhANjXVfnhbBJAs2zTH4(3xIYrM(jW3cDMEGGFj8TsJVvGt8(wS4GP)TOYbKPh43IkhANjXVfBOjHoKeGutYoRne33ce7mW4(wYsz)7lr58k(e4BHotpqWVe(wPX3kWjEFlwCW0)wu5aY0d8BrLdTZK436YJutYsQfnCyJZVfi2zGX9TKZ)(suoY8pb(wOZ0de8lHVvA8TcCI33Ifhm9VfvoGm9a)wu5q7mj(T4e1xEKAswsTOHdBC(TaXodmUVLC(3xIYPf)jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8BjBTTKAPOwSfbanmqqfsA0oqEOZa0zxG1siH1srThpq)ubGJ6SRnYhmuOZ0deSwt1srThpq)uCiyh1OOjvOZ0deSwcjS2wvRiPIo7NIO2bK9AjUwt1srTTQwrsfD2pLJIihzawlHewlloivuJoscXzTsRv2AjKWAdah7zyJQj0OjD98YGuHotpqWAjUwt12QAfjv0z)uur)AAh1sCTe)TOYH2zs8B1HZgOBRtd0X4FFjsqY7tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43cBraqddeurYcMoq9SbXttcmHIAjKWAXwea0Wabv2dgeYxgtnndAJ1siH1ITiaOHbcQShmiKVmMAseKhdy61siH1ITiaOHbcQa5GiYmDnikisBaCbofOlWAjKWAXwea0WabvqFkcGJPhOUfbW(bqQbrQqbwlHewl2IaGggiOAMaJbEh0T1baD7AjKWAXwea0WabvtaNEKjOMjXRP98QLqcRfBraqddeu9WeHogtDpshSwcjSwSfbanmqqvFWKOo7AA(Ub(TOYH2zs8BXg601at8FFjsqY(jW3Ifhm9VfjmIm0qs2g)wOZ0de8lH)9LibjNpb(wOZ0de8lHVLiGhgq(BntGbn0bvuZbFWbQN5Gk6NcDMEGG1siH1otGbn0bvgaZdyGAmamoy6k0z6bc(TyXbt)B1h4SreC)(3xIeeb9jW3cDMEGGFj8Teb8WaYFlrsfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQvKoia8uCiyh1grccTBRqNPhiyTMQLkhqMEGkE8WTN6zBxOfzoaZhFwRPAzXbPIA0rsioR9LAPYbKPhOItuFCyJNwKa(9TyXbt)BfaoQZU2iFW4FFjsqYSpb(wOZ0de8lHVLiGhgq(B1QAPYbKPhOYiqdGXqJuZALwRS1AQ2aWXEg2OceofqJb05OTwKKKSdQqNPhi43Ifhm9VvpY5rNJ7FFjsqu2NaFl0z6bc(LW3seWddi)TAvTu5aY0duzeObWyOrQzTsRv2AnvBRQnaCSNHnQaHtb0yaDoARfjjj7Gk0z6bcwRPAPO2wvRiPIo7NIk6xt7OwcjSwQCaz6bQ6Wzd0T1Pb6yulXFlwCW0)wCiyh10dEE)7lrcsM(jW3cDMEGGFj8Teb8WaYFRwvlvoGm9avgbAamgAKAwR0ALTwt12QAdah7zyJkq4uangqNJ2ArssYoOcDMEGG1AQwrsfD2pfv0VM2rTMQTv1sLditpqvhoBGUTonqhJVfloy6Flsyezm1zxFzqI(9VVejOxXNaFl0z6bc(LW3seWddi)TOYbKPhOYiqdGXqJuZALwRSFlwCW0)wi1uWhm9)9VVfN4NaFjk7NaFl0z6bc(LW3seWddi)Tcah7zyJkq4uangqNJ2ArssYoOcDMEGG1AQwrMdW8Xv0a9UgeofqJb05OTwKKKSdQcKbBxRPAPb6DfiCkGgdOZrBTijjzhu3JCEkW8XR1uTuulnqVR4qWoQnYhmuG5JxRPAPb6Dva4Oo7AJ8bdfy(41AQwqKgO3vxciA0zxFnOMKTHkW8XRL4AnvRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5vRPAPOwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLulA4WgN1AQwkQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ATfG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sLditpq1LhPMKLudIdUTUNHMnQL4AjKWAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RLkhqMEGQlpsnjlPgehCBDpdnBulX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTwBbyTexlXFlwCW0)w9iNhDoU)9LOC(e4BHotpqWVe(wIaEya5Vff1gao2ZWgvGWPaAmGohT1IKKKDqf6m9abR1uTImhG5JROb6DniCkGgdOZrBTijjzhufid2Uwt1sd07kq4uangqNJ2ArssYoOUddubMpETMQ1iqQABbOswvpY5rNJRwIRLqcRLIAdah7zyJkq4uangqNJ2ArssYoOcDMEGG1AQ2dsI1kTw5vlXFlwCW0)wDyGA6bpV)9Lib9jW3cDMEGGFj8Teb8WaYFRaWXEg2OYoGZrBnuafduHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)Aji5vRPAfzoaZhxDjGOrND91GAs2gQcKKH(SwP1kVAnvlf1sd07koeSJArdh2OAESGOAFrATu5aY0duXjQV8i1KSKArdh24Swt1srTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xKwRTaSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQU8i1KSKAqCWT19m0SrTexlHewlf12QApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzj1G4GBR7zOzJAjUwcjSwrMdW8XvCiyh1g5dgQajzOpR9fP1AlaRL4Aj(BXIdM(3Qh580EsL)3xIYSpb(wOZ0de8lHVLiGhgq(Bfao2ZWgv2bCoARHcOyGk0z6bcwRPAfzoaZhxXHGDuBKpyOcKKH(SwP1kVAnvlf1srTuuRiZby(4Qlben6SRVgutY2qvGKm0N1k)APYbKPhOIn0KSKAqCWT19m0xEK1AQwAGExXHGDulA4WgvZJfevR0APb6Dfhc2rTOHdBurYsQNhliQwIRLqcRLIAfzoaZhxDjGOrND91GAs2gQcKKH(SwP1kVAnvlnqVR4qWoQfnCyJQ5XcIQ9fP1sLditpqfNO(YJutYsQfnCyJZAjUwIR1uT0a9UkaCuNDTr(GHcmF8Aj(BXIdM(3Qh580EsL)3xIu2NaFl0z6bc(LW3Ifhm9Vfhc2rnjCoHdC(Tenm0)wY(Teb8WaYFlrsfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLgO3vCiyh1nCqMEB18ybr1(sTYsz1AQwrMdW8Xvbdcz)0tdoisfijd9zTViTwQCaz6bQA4Gm9265XcI0hKeRLs1IsIcGd1hKeR1uTImhG5JRUeq0OZU(AqnjBdvbsYqFw7lsRLkhqMEGQgoitVTEESGi9bjXAPuTOKOa4q9bjXAPuTS4GPRcgeY(PNgCqKcLefahQpijwRPAfzoaZhxXHGDuBKpyOcKKH(S2xKwlvoGm9avnCqMEB98ybr6dsI1sPArjrbWH6dsI1sPAzXbtxfmiK9tpn4GifkjkaouFqsSwkvlloy6Qlben6SRVgutY2qfkjkaouFqs8FFjkt)e4BHotpqWVe(wIaEya5VLiPIo7NIk6xt7Owt1E8a9tXHGDuJIMuHotpqWAnv7bjXAFPwzLxTMQvK5amFCfjmImM6SRVmir)ubsYqFwRPAPb6DLyGCi45bDB18ybr1(sTe03Ifhm9Vfhc2rn9GN3)(s8v8jW3cDMEGGFj8TyXbt)BntGXaVd626aGU93seWddi)Tcah7zyJQj0OjD98YGuHotpqWAnvRrGu12cqLSkKAk4dM(3Yzs8BntGXaVd626aGU9)(suM)jW3cDMEGGFj8Teb8WaYFRaWXEg2OAcnAsxpVmivOZ0deSwt1AeivTTaujRcPMc(GP)TyXbt)BDjGOrND91GAs2g(VVeBXFc8TqNPhi4xcFlrapmG83kaCSNHnQMqJM01Zldsf6m9abR1uTuuRrGu12cqLSkKAk4dMETesyTgbsvBlavYQUeq0OZU(AqnjBdRL4Vfloy6FloeSJAJ8bJ)9LOSY7tGVf6m9ab)s4Bjc4HbK)wImhG5JR4qWoQnYhmubsYqFw7lsRvMxRPAfzoaZhxDjGOrND91GAs2gQcKKH(S2xKwRmVwt1srT0a9UIdb7Ow0WHnQMhliQ2xKwlvoGm9avCI6lpsnjlPw0WHnoR1uTuulf1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4QaWrD21g5dgQajzOpR9fP1AlaR1uTImhG5JR4qWoQnYhmubsYqFwR8RLYQL4AjKWAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RLYQL4AjKWAfzoaZhxXHGDuBKpyOcKKH(S2xKwRTaSwIRL4Vfloy6Flsyezm1zxFzqI(9VVeLv2pb(wOZ0de8lHVLiGhgq(BDqsSw5xlbjVAnvBa4ypdBunHgnPRNxgKk0z6bcwRPAfjv0z)uur)AAh1AQwJaPQTfGkzvKWiYyQZU(YGe97BXIdM(3cPMc(GP)VVeLvoFc8TqNPhi4xcFlrapmG836GKyTYVwcsE1AQ2aWXEg2OAcnAsxpVmivOZ0deSwt1sd07koeSJArdh2OAESGOAFrATu5aY0duXjQV8i1KSKArdh24Swt1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwrMdW8XvCiyh1g5dgQajzOpR9fP1Ala)wS4GP)TqQPGpy6)7lrzjOpb(wOZ0de8lHVfloy6FlKAk4dM(3c6hgbGXPH9VfnqVRMqJM01Zlds18ybrsPb6D1eA0KUEEzqQizj1ZJfe9TG(HrayCAijjcc5d)wY(Teb8WaYFRdsI1k)Aji5vRPAdah7zyJQj0OjD98YGuHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1kTw5vRPAPOwkQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlvoGm9avSHMKLudIdUTUNH(YJSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1sCTesyTuuRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5vRPAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswsTOHdBCwlX1sCTMQLgO3vbGJ6SRnYhmuG5JxlX)7lrzLzFc8TqNPhi4xcFlrapmG83sK5amFC1LaIgD21xdQjzBOkqsg6ZAFPwusuaCO(GKyTMQLIAPO2JhOFQaWrD21g5dgk0z6bcwRPAfzoaZhxfaoQZU2iFWqfijd9zTViTwBbyTMQvK5amFCfhc2rTr(GHkqsg6ZALFTu5aY0duD5rQjzj1G4GBR7zOzJAjUwcjSwkQTv1E8a9tfaoQZU2iFWqHotpqWAnvRiZby(4koeSJAJ8bdvGKm0N1k)APYbKPhO6YJutYsQbXb3w3ZqZg1sCTesyTImhG5JR4qWoQnYhmubsYqFw7lsR1wawlXFlwCW0)wbdcz)0tdoi6FFjklL9jW3cDMEGGFj8Teb8WaYFlrMdW8XvCiyh1g5dgQajzOpR9LArjrbWH6dsI1AQwkQLIAPOwrMdW8XvxciA0zxFnOMKTHQajzOpRv(1sLditpqfBOjzj1G4GBR7zOV8iR1uT0a9UIdb7Ow0WHnQMhliQwP1sd07koeSJArdh2OIKLuppwquTexlHewlf1kYCaMpU6sarJo76Rb1KSnufijd9zTsRvE1AQwAGExXHGDulA4WgvZJfev7lsRLkhqMEGkor9LhPMKLulA4WgN1sCTexRPAPb6Dva4Oo7AJ8bdfy(41s83Ifhm9VvWGq2p90GdI(3xIYkt)e4BHotpqWVe(wIaEya5VLiZby(4koeSJAJ8bdvGKm0N1kTw5vRPAPOwkQLIAfzoaZhxDjGOrND91GAs2gQcKKH(Sw5xlvoGm9avSHMKLudIdUTUNH(YJSwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1sCTesyTuuRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5vRPAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswsTOHdBCwlX1sCTMQLgO3vbGJ6SRnYhmuG5JxlXFlwCW0)wGiFn0z44)(su2xXNaFl0z6bc(LW3Ifhm9V1mbgd8oOBRda62FlrapmG83IIAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswsTOHdBCwlHewRrGu12cqLSQGbHSF6PbhevlX1AQwkQLIApEG(Pcah1zxBKpyOqNPhiyTMQvK5amFCva4Oo7AJ8bdvGKm0N1(I0ATfG1AQwrMdW8XvCiyh1g5dgQajzOpRv(1sLditpq1LhPMKLudIdUTUNHMnQL4AjKWAPO2wv7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JR4qWoQnYhmubsYqFwR8RLkhqMEGQlpsnjlPgehCBDpdnBulX1siH1kYCaMpUIdb7O2iFWqfijd9zTViTwBbyTe)TCMe)wZeymW7GUToaOB)VVeLvM)jW3cDMEGGFj8Teb8WaYFlkQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhOItuF5rQjzj1IgoSXzTesyTgbsvBlavYQcgeY(PNgCquTexRPAPOwkQ94b6NkaCuNDTr(GHcDMEGG1AQwrMdW8XvbGJ6SRnYhmubsYqFw7lsR1wawRPAfzoaZhxXHGDuBKpyOcKKH(Sw5xlvoGm9avxEKAswsnio426EgA2OwIRLqcRLIABvThpq)ubGJ6SRnYhmuOZ0deSwt1kYCaMpUIdb7O2iFWqfijd9zTYVwQCaz6bQU8i1KSKAqCWT19m0SrTexlHewRiZby(4koeSJAJ8bdvGKm0N1(I0ATfG1s83Ifhm9V1LaIgD21xdQjzB4)(su2w8NaFl0z6bc(LW3seWddi)TOOwkQvK5amFC1LaIgD21xdQjzBOkqsg6ZALFTu5aY0duXgAswsnio426Eg6lpYAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevlX1siH1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR0ALxTMQLgO3vCiyh1IgoSr18ybr1(I0APYbKPhOItuF5rQjzj1IgoSXzTexlX1AQwAGExfaoQZU2iFWqbMp(3Ifhm9Vfhc2rTr(GX)(suoY7tGVf6m9ab)s4Bjc4HbK)w0a9UkaCuNDTr(GHcmF8Anvlf1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RvoYRwt1sd07koeSJArdh2OAESGOALwlnqVR4qWoQfnCyJksws98ybr1sCTesyTuuRiZby(4Qlben6SRVgutY2qvGKm0N1kTw5vRPAPb6Dfhc2rTOHdBunpwquTViTwQCaz6bQ4e1xEKAswsTOHdBCwlX1sCTMQLIAfzoaZhxXHGDuBKpyOcKKH(Sw5xRSYPwcjSwqKgO3vxciA0zxFnOMKTHkaJAj(BXIdM(3kaCuNDTr(GX)(suoY(jW3cDMEGGFj8Teb8WaYFlrMdW8XvCiyh1zqRcKKH(Sw5xlLvlHewBRQ94b6NIdb7OodAf6m9ab)wS4GP)TMnW(bDBTr(GX)(suoY5tGVf6m9ab)s4Bjc4HbK)wIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAnvlnqVR4qWoQnYhmuag1AQwqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhliQwP1kZQ1uTgbsvBlavYQ4qWoQZGUwt1YIdsf1OJKqCw7l1(k(wS4GP)T4qWoQPh88(3xIYHG(e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQvATYSVfloy6FloeSJAAoc2g)3xIYrM9jW3cDMEGGFj8Teb8WaYFlrsfD2pfrTdi71AQ2aWXEg2OIdb7OUHdY0BRqNPhiyTMQLgO3vCiyh1g5dgkaJAnvlf1cMNkyqi7NEAWbrQajzOpRv(1ktRLqcRfePb6DvWGq2p90GdI0ubgogmnCaV2kaJAjUwt1cI0a9Ukyqi7NEAWbrAQadhdMgoGxB18ybr1(sTYSAnvlloivuJoscXzTsRLG(wS4GP)T4qWoQPh88(3xIYHY(e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQvATe03Ifhm9Vfhc2rDg0)7lr5it)e4BHotpqWVe(wIaEya5VLiPIo7NIO2bK9AnvBa4ypdBuXHGDu3Wbz6TvOZ0deSwt1sd07koeSJAJ8bdfGrTMQfePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIQvATY5BXIdM(3Idb7OMMJGTX)9LOCEfFc8TqNPhi4xcFlrapmG83sKurN9tru7aYETMQnaCSNHnQ4qWoQB4Gm92k0z6bcwRPAPb6Dfhc2rTr(GHcWOwt1AeivTTaujhvWGq2p90GdIQ1uTS4Gurn6ijeN1k)AjOVfloy6FloeSJAusJroHP)VVeLJm)tGVf6m9ab)s4Bjc4HbK)wIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAnvlnqVR4qWoQnYhmuag1AQwqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhliQwP1kBTMQLfhKkQrhjH4Sw5xlb9TyXbt)BXHGDuJsAmYjm9)9LOCAXFc8TqNPhi4xcFlrapmG83IgO3vGiFn0z4OcWOwt1cI0a9U6sarJo76Rb1KSnubyuRPAbrAGExDjGOrND91GAs2gQcKKH(S2xKwlnqVRmcCIUa1zxtcDqfjlPEESGOABj1YIdMUIdb7OMEWZtHsIcGd1hKeR1uTuulf1E8a9tf4mD2fOcDMEGG1AQwwCqQOgDKeIZAFPwzwTexlHewlloivuJoscXzTVulLvlX1AQwkQTv1gao2ZWgvCiyh10jjnhGKOFk0z6bcwlHew7XHnEQgKhxJYqC1k)AjikRwI)wS4GP)TmcCIUa1zxtcDW)9LibjVpb(wOZ0de8lHVLiGhgq(Brd07kqKVg6mCubyuRPAPOwkQ94b6NkWz6Slqf6m9abR1uTS4Gurn6ijeN1(sTYSAjUwcjSwwCqQOgDKeIZAFPwkRwIR1uTuuBRQnaCSNHnQ4qWoQPtsAoajr)uOZ0deSwcjS2JdB8unipUgLH4Qv(1squwTe)TyXbt)BXHGDutp459VVejiz)e4BXIdM(3AcyGHNu5Vf6m9ab)s4FFjsqY5tGVf6m9ab)s4Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQw5lTwkQLfhKkQrhjH4S2wOALTwIR1uTbGJ9mSrfhc2rnDssZbij6NcDMEGG1AQ2JdB8unipUgLH4Q9LAjik7BXIdM(3Idb7OMMJGTX)9LibrqFc8TqNPhi4xcFlrapmG83IgO3vCiyh1IgoSr18ybr1kTwAGExXHGDulA4WgvKSK65XcI(wS4GP)T4qWoQP5iyB8FFjsqYSpb(wOZ0de8lHVLiGhgq(Brd07koeSJArdh2OAESGOALwR8Q1uTuuRiZby(4koeSJAJ8bdvGKm0N1k)ALLYQLqcRTv1srTIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWAjUwI)wS4GP)T4qWoQZG(FFjsqu2NaFl0z6bc(LW3seWddi)TOO2a7boBy6bwlHewBRQ9GcIGUDTexRPAPb6Dfhc2rTOHdBunpwquTsRLgO3vCiyh1IgoSrfjlPEESGOVfloy6FlhVgm0hsAGZ7FFjsqY0pb(wOZ0de8lHVLiGhgq(Brd07kXa5qWZd62QazXvRPAdah7zyJkoeSJ6goitVTcDMEGG1AQwkQLIApEG(PysJbSdf8btxHotpqWAnvlloivuJoscXzTVuRmVwIRLqcRLfhKkQrhjH4S2xQLYQL4Vfloy6FloeSJAs4Cch48FFjsqVIpb(wOZ0de8lHVLiGhgq(Brd07kXa5qWZd62QazXvRPApEG(P4qWoQrrtQqNPhiyTMQfePb6D1LaIgD21xdQjzBOcWOwt1srThpq)umPXa2Hc(GPRqNPhiyTesyTS4Gurn6ijeN1(sTT4Aj(BXIdM(3Idb7OMeoNWbo)3xIeKm)tGVf6m9ab)s4Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQ2JhOFkM0ya7qbFW0vOZ0deSwt1YIdsf1OJKqCw7l1kZ(wS4GP)T4qWoQjHZjCGZ)9Lib1I)e4BHotpqWVe(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQ9LAPb6Dfhc2rTOHdBurYsQNhli6BXIdM(3Idb7OgL0yKty6)7lrzM8(e4BHotpqWVe(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPAncKQ2waQKvXHGDutZrW243Ifhm9Vfhc2rnkPXiNW0)3)(wnCqME7pb(su2pb(wOZ0de8lHVfloy6FlKAk4dM(3ceNIaACW0)wVYETJ8P20RLKDUw2bRvK5amF8zTCG1kssOBxlGH51AN1Ynidwl7G1IuZVLiGhgq(BrYoRmexTViTwcsE1AQwQCaz6bQsGBcbrD21ImhG5JpR1uTuu7Xd0pva4Oo7AJ8bdf6m9abR1uTImhG5JRcah1zxBKpyOcKKH(S2xQvw5vlX)7lr58jW3cDMEGGFj8TaXPiGghm9VLmjw7d7xTxw78ybr12Wbz6TRTdmgTv1sGgSwGjwB2RvwzATZJfenRTbdSw4S2lRLfIeWVA7zu71G1Eqbr1oW(vB61EnyTIg2DCul7G1EnyTKW5eoWAHET9b0U5uFlrapmG83IIAPYbKPhOAESGiDdhKP3UwcjS2dsI1(sTYkVAjUwt1sd07koeSJ6goitVTAESGOAFPwzLPFlrdd9VLSFlwCW0)wCiyh1KW5eoW5)(sKG(e4BHotpqWVe(wS4GP)T4qWoQjHZjCGZVfiofb04GP)TKjBqVwGj0TRvMG0ODG8O2xNa0zxGMxRGNxTCTD8PwuYl4AjHZjCGZAFAGdS2hgEq3U2Eg1EnyT0a9ET8v71G1opoUAZETxdwBhA3CFlrapmG83cBraqddeuHKgTdKh6maD2fyTMQ9GKyTVulbjVAnv7L22dujYCaMp(Swt1kYCaMpUcjnAhip0za6SlqvGKm0N1k)ALvMkZR1uTTQwwCW0viPr7a5HodqNDbQaHtMEGG)7lrz2NaFl0z6bc(LW3Ifhm9V1mbgd8oOBRda62FlrapmG83IkhqMEGkK0iFWab10CeSnwRPAfzoaZhxDjGOrND91GAs2gQcKKH(S2xKwlkjkaouFqsSwt1kYCaMpUIdb7O2iFWqfijd9zTViTwkQfLefahQpijwBlPw5ulXFlNjXV1mbgd8oOBRda62)7lrk7tGVf6m9ab)s4Bjc4HbK)wu5aY0duHKg5dgiOMMJGTXAnvRiZby(4Qlben6SRVgutY2qvGKm0N1(I0ArjrbWH6dsI1AQwrMdW8XvCiyh1g5dgQajzOpR9fP1srTOKOa4q9bjXABj1kNAjUwt1srTTQwSfbanmqq1mbgd8oOBRda621siH1ksheaEkoeSJAJibH2Tvb7evR8LwlLvlHewRiZby(4Qzcmg4Dq3wha0TvbsYqFwR8RvwzLxTe)TyXbt)BfmiK9tpn4GO)9LOm9tGVf6m9ab)s4Bjc4HbK)wu5aY0du1cdmpnWeb1tdoiQwt1kYCaMpUIdb7O2iFWqfijd9zTViTwusuaCO(GKyTMQLIABvTylcaAyGGQzcmg4Dq3wha0TRLqcRvKoia8uCiyh1grccTBRc2jQw5lTwkRwcjSwrMdW8XvZeymW7GUToaOBRcKKH(Sw5xRSYkVAj(BXIdM(36sarJo76Rb1KSn8FFj(k(e4BHotpqWVe(wIaEya5VLrGu12cqLSQlben6SRVgutY2WVfloy6FloeSJAJ8bJ)9LOm)tGVf6m9ab)s4Bjc4HbK)wu5aY0duHKg5dgiOMMJGTXAnvRiZby(4QGbHSF6PbhePcKKH(S2xKwlkjkaouFqsSwt1sLditpq1bjrnGFWHMnQv(sRvoYRwt1srTTQwr6GaWtXHGDuBeji0UTcDMEGG1siH12QAPYbKPhOIhpC7PE22fArMdW8XN1siH1kYCaMpU6sarJo76Rb1KSnufijd9zTViTwkQfLefahQpijwBlPw5ulX1s83Ifhm9Vva4Oo7AJ8bJ)9Lyl(tGVf6m9ab)s4Bjc4HbK)wu5aY0duHKg5dgiOMMJGTXAnvRrGu12cqLSQaWrD21g5dgFlwCW0)wbdcz)0tdoi6FFjkR8(e4BHotpqWVe(wIaEya5VfvoGm9avTWaZtdmrq90GdIQ1uTTQwQCaz6bQAYbi0T1xEKFlwCW0)wxciA0zxFnOMKTH)7lrzL9tGVf6m9ab)s4BXIdM(3Idb7OMMJGTXVfiofb04GP)TAbMyTYXbRLdb7yT0CeSnwl0RTLFvk96FDE1AtF0UwyVwjmYeCamVAzhSw(QDG88Qvo126wpR1isHab)wIaEya5VfnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPAPb6Dva4Oo7AJ8bdfGrTMQLgO3vCiyh1g5dgkaJAnvlnqVR4qWoQB4Gm92Q5XcIQv(sRvwzATMQLgO3vCiyh1g5dgQajzOpR9fP1YIdMUIdb7OMMJGTrfkjkaouFqsSwt1sd07k6rMGdG5Pam(3xIYkNpb(wOZ0de8lHVfloy6FRaWrD21g5dgFlqCkcOXbt)B1cmXALJdw7RpF1AHETT8RwB6J21c71kHrMGdG5vl7G1kNABDRN1AeP4Bjc4HbK)w0a9UkaCuNDTr(GHcmF8AnvlnqVROhzcoaMNcWOwt1srTu5aY0duDqsud4hCOzJALFTeK8QLqcRvK5amFCvWGq2p90GdIubsYqFwR8Rvw5ulX1AQwkQLgO3vCiyh1nCqMEB18ybr1kFP1klLvlHewlnqVRedKdbppOBRMhliQw5lTwzRL4Anvlf12QAfPdcapfhc2rTrKGq72k0z6bcwlHewBRQLkhqMEGkE8WTN6zBxOfzoaZhFwlX)7lrzjOpb(wOZ0de8lHVLiGhgq(Brd07koeSJAJ8bdfy(41AQwkQLkhqMEGQdsIAa)GdnBuR8RLGKxTesyTImhG5JRcgeY(PNgCqKkqsg6ZALFTYkNAjUwt1srTTQwr6GaWtXHGDuBeji0UTcDMEGG1siH12QAPYbKPhOIhpC7PE22fArMdW8XN1s83Ifhm9Vva4Oo7AJ8bJ)9LOSYSpb(wOZ0de8lHVLiGhgq(BrLditpqfsAKpyGGAAoc2gR1uTuulnqVR4qWoQfnCyJQ5XcIQv(sRvo1siH1kYCaMpUIdb7OodAvGmy7AjUwt1srTTQ2JhOFQaWrD21g5dgk0z6bcwlHewRiZby(4QaWrD21g5dgQajzOpRv(1sz1sCTMQLkhqMEGkCEqs(qqnBOfzoaZhVw5lTwcsE1AQwkQTv1ksheaEkoeSJAJibH2TvOZ0deSwcjS2wvlvoGm9av84HBp1Z2UqlYCaMp(SwI)wS4GP)TcgeY(PNgCq0)(suwk7tGVf6m9ab)s4BXIdM(36sarJo76Rb1KSn8BbItranoy6FlzYg0RnaCh621Aeji0UT51cmXAV8iRLUDTWBIJETqV2maXO2lRLhqBVw4v7d8AQLn(wIaEya5VfvoGm9avhKe1a(bhA2O2xQLYKxTMQLkhqMEGQdsIAa)GdnBuR8RLGKxTMQLIABvTylcaAyGGQzcmg4Dq3wha0TRLqcRvKoia8uCiyh1grccTBRc2jQw5lTwkRwI)3xIYkt)e4BHotpqWVe(wIaEya5VfvoGm9avTWaZtdmrq90GdIQ1uT0a9UIdb7Ow0WHnQMhliQ2xQLgO3vCiyh1IgoSrfjlPEESGOVfloy6FloeSJ6mO)3xIY(k(e4BHotpqWVe(wIaEya5Vfisd07QGbHSF6PbhePPcmCmyA4aETvZJfevR0AbrAGExfmiK9tpn4GinvGHJbtdhWRTIKLuppwq03Ifhm9Vfhc2rnnhbBJ)7lrzL5Fc8TqNPhi4xcFlrapmG83IkhqMEGQwyG5PbMiOEAWbr1siH1srTGinqVRcgeY(PNgCqKMkWWXGPHd41wbyuRPAbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGOAFPwqKgO3vbdcz)0tdoistfy4yW0Wb8ARizj1ZJfevlXFlwCW0)wCiyh10dEE)7lrzBXFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9VvlWeRLe6WALahbBJ1sJ3dIETbdcz)QDAWbrZAH9AbCqmQvceCTpWRjbUAbXb3g621(6zqi7xTwgCquTqqKhJ2FlrapmG83IgO3vbGJ6SRnYhmuag1AQwAGExXHGDuBKpyOaZhVwt1sd07k6rMGdG5PamQ1uTImhG5JRcgeY(PNgCqKkqsg6ZAFrATYkVAnvlnqVR4qWoQB4Gm92Q5XcIQv(sRvwz6)(suoY7tGVf6m9ab)s4BXIdM(3Idb7Ood6Vfiofb04GP)TAbMyTzqxB61kaRfWh4CwlBulCwRijHUDTag1oZ0)wIaEya5VfnqVR4qWoQfnCyJQ5XcIQ9LAjOAnvlvoGm9avhKe1a(bhA2Ow5xRSYRwt1srTImhG5JRUeq0OZU(AqnjBdvbsYqFwR8RLYQLqcRTv1ksheaEkoeSJAJibH2TvOZ0deSwI)3xIYr2pb(wOZ0de8lHVfloy6FloeSJAs4Cch48BjAyO)TK9Bjc4HbK)w0a9Usmqoe88GUTkqwC1AQwAGExXHGDuBKpyOam(3xIYroFc8TqNPhi4xcFlwCW0)wCiyh10CeSn(TaXPiGghm9V1RSx7dwRnE1AKpyul07aty61cceq3U2bW8Q9bFpg12WuXArpbSBQTHNhw7L1AJxTzVxlx78I0TRLMJGTXAbbcOBx71G1gPHmyJAFGoy(8Teb8WaYFlAGExfaoQZU2iFWqbyuRPAPb6Dva4Oo7AJ8bdvGKm0N1(I0AzXbtxXHGDutcNt4aNkusuaCO(GKyTMQLgO3vCiyh1g5dgkaJAnvlnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPAPb6Dfhc2rDdhKP3wnpwquTMQLgO3vg5dgAO3bMW0vag1AQwAGExrpYeCampfGX)(suoe0NaFl0z6bc(LW3Ifhm9Vfhc2rn9GN33ceNIaACW0)wVYETpyT24vRr(GrTqVdmHPxliqaD7AhaZR2h89yuBdtfRf9eWUP2gEEyTxwRnE1M9ETCTZls3UwAoc2gRfeiGUDTxdwBKgYGnQ9b6G5J51oZAFW3JrTPpAxlWeRf9eWUPw6bpVzTqhEqEmAx7L1AJxTxwBpbIAfnCyJZVLiGhgq(Brd07kJaNOlqD21KqhubyuRPAPOwAGExXHGDulA4WgvZJfev7l1sd07koeSJArdh2OIKLuppwquTesyTTQwkQLgO3vg5dgAO3bMW0vag1AQwAGExrpYeCampfGrTexlX)7lr5iZ(e4BHotpqWVe(wS4GP)TmcCIUa1zxtcDWVfiofb04GP)TiqdwlnoVAbMyTzVwJKSw4S2lRfyI1cVAVS2weauq0ODT0aWbyTIgoSXzTGab0TRLnQL7hg1Eny7ATXRwqasdeSw621EnyTnCqME7AP5iyB8Bjc4HbK)w0a9UIdb7Ow0WHnQMhliQ2xQLgO3vCiyh1IgoSrfjlPEESGOAnvlnqVR4qWoQnYhmuag)7lr5qzFc8TqNPhi4xcFlqCkcOXbt)BjtI1(W(v7L1opwquTnCqME7A7aJrBvTeObRfyI1M9ALvMw78ybrZABWaRfoR9YAzHib8R2Eg1EnyThuquTdSF1METxdwROHDhh1YoyTxdwljCoHdSwOxBFaTBo13Ifhm9Vfhc2rnjCoHdC(TG(HrayCFlz)wIgg6Flz)wIaEya5VfnqVR4qWoQB4Gm92Q5XcIQ9LALvM(TG(HrayCA7rsZJVLS)7lr5it)e4BHotpqWVe(wIaEya5VfnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPAPYbKPhOcjnYhmqqnnhbBJFlwCW0)wCiyh10CeSn(VVeLZR4tGVf6m9ab)s4Bjc4HbK)wKSZkdXv7l1klL9TyXbt)BHutbFW0)3xIYrM)jW3cDMEGGFj8TyXbt)BXHGDutp459TaXPiGghm9V1RJpAxlWeRLEWZR2lRLgaoaRv0WHnoRf2R9bRLhbYGTRTHPI1otsS2EKK1Mb93seWddi)TOb6Dfhc2rTOHdBunpwquTMQLgO3vCiyh1IgoSr18ybr1(sT0a9UIdb7Ow0WHnQizj1ZJfe9VVeLtl(tGVf6m9ab)s4BbItranoy6FRxxbhJAFGxtTmzTa(aNZAzJAHZAfjj0TRfWOw2bR9bFhyTJ8P20RLKD(BXIdM(3Idb7OMeoNWbo)wq)WiamUVLSFlrdd9VLSFlrapmG83Qv1srTu5aY0duDqsud4hCOzJAFrATYkVAnvlj7SYqC1(sTeK8QL4Vf0pmcaJtBpsAE8TK9FFjsqY7tGVf6m9ab)s4BbItranoy6FRxnYoCGZAFGxtTJ8PwsEEy028ABG2n12WZdnV2mQLoVMAj52165vBdtfRf9eWUPws25AVS2jGHrgxTn5tTKSZ1c9d9jKkwBWGq2VANgCquTc2RLgnV2zw7d(EmQfyI12Hbwl9GNxTSdwBpY5rNJR2Ng0RDKp1METKSZFlwCW0)wDyGA6bpV)9Libj7NaFlwCW0)w9iNhDoUVf6m9ab)s4F)7Bj4HayWhm95NaFjk7NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVLSFlrapmG83IkhqMEGQgMkQtd0rWALwR8Q1uTgbsvBlavYQqQPGpy61AQ2wvlf1gao2ZWgvtOrt665LbPcDMEGG1siH1gao2ZWgvhsAKbp0pCyOqNPhiyTe)TOYH2zs8B1WurDAGoc(VVeLZNaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVLSFlrapmG83IkhqMEGQgMkQtd0rWALwR8Q1uT0a9UIdb7O2iFWqbMpETMQvK5amFCfhc2rTr(GHkqsg6ZAnvlf1gao2ZWgvtOrt665LbPcDMEGG1siH1gao2ZWgvhsAKbp0pCyOqNPhiyTe)TOYH2zs8B1WurDAGoc(VVejOpb(wOZ0de8lHVvA8TM49TyXbt)BrLditpWVfvEaGFlz)wIaEya5VfnqVR4qWoQfnCyJQ5XcIQvAT0a9UIdb7Ow0WHnQizj1ZJfevRPABvT0a9UkagOo76RjqCQamQ1uTDODZPdKKH(S2xKwlf1srTKSZ1kJAzXbtxXHGDutp45Pe58QL4ABj1YIdMUIdb7OMEWZtHsIcGd1hKeRL4Vfvo0otIFRo05HMgi8)9LOm7tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43IgO3vCiyh1nCqMEB18ybr1kFP1klLvlHewlf1gao2ZWgvCiyh10jjnhGKOFk0z6bcwRPApoSXt1G84AugIR2xQLGOSAj(BbItranoy6Flzc41GrTCTDGXODTZJfeHG12Wbz6TRnJAHETOKOa4WAd2TXAFGxtTsijP5aKe97BrLdTZK43cjnYhmqqnnhbBJ)7lrk7tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLdTZK43AWZtZgAGj(TaXodmUVL8(wIaEya5VfnqVR4qWoQnYhmuag1AQwkQLkhqMEGQbppnBObMyTsRvE1siH1EqsSw5lTwQCaz6bQg880SHgyI1sPALLYQL4VfvEaGFRdsI)7lrz6NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVff1kYCaMpUIdb7O2iFWqbce8btV2wsTuuRS12cvlf1kpL8iOABj1ksheaEkoeSJAJibH2Tvb7evlX1sCTexBluTuu7bjXABHQLkhqMEGQbppnBObMyTe)TaXPiGghm9Vvlhc2XAF1ibH2TR1gsfN1Y1sLditpWAzYeWVAZETcWW8APbUAFW3JrTatSwU2(GVAX5bj5dMETnyGQAjqdw7eskQ1isQqqeS2ajzOp1OKgO4qWArjncCoHPxlyIZA98Q9jdIQ9bhJA7zuRrKGq721ccG1EzTxdwlnqmV2168beyTzV2RbRvagQVfvo0otIFlCEqs(qqnBOfzoaZh)FFj(k(e4BHotpqWVe(wPX3AI33Ifhm9VfvoGm9a)wu5ba(TOYbKPhOcNhKKpeuZgArMdW8X)wIaEya5VLiDqa4P4qWoQnIeeA3(BrLdTZK436GKOgWp4qZg)7lrz(NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVLiZby(4koeSJAJ8bdvGKm0NFlrapmG83Qv1ksheaEkoeSJAJibH2TvOZ0de8BrLdTZK436GKOgWp4qZg)7lXw8NaFl0z6bc(LW3kn(wKSKFlwCW0)wu5aY0d8BrLdTZK436GKOgWp4qZgFlrapmG83IIAfzoaZhxDjGOrND91GAs2gQcKKH(S2wOAPYbKPhO6GKOgWp4qZg1sCTVuRCK33ceNIaACW0)wYK47XOwqCWTRTLF1AbmQ9YALJ8MOO2Eg1sG8APFlQ8aa)wImhG5JRUeq0OZU(AqnjBdvbsYqF(VVeLvEFc8TqNPhi4xcFR04BrYs(TyXbt)BrLditpWVfvo0otIFRdsIAa)GdnB8Teb8WaYFlr6GaWtXHGDuBeji0UDTMQvKoia8uCiyh1grccTBRc2jQ2xQLYQ1uTylcaAyGGQzcmg4Dq3wha0TR1uTIKk6SFkIAhq2R1uTbGJ9mSrfhc2rDdhKP3wHotpqWVfiofb04GP)TSGUaR91dq3Uw4S2jGOPwUwJ8bJoWO2lGor4vBpJAFDD7aYU51(GVhJANhuquTxw71G1EpzTKqh4WAfTfdSwa)GJAFWATXRwU2gODtTONa2n1gStuTzVwJibH2T)wu5ba(TezoaZhxntGXaVd626aGUTkqsg6Z)9LOSY(jW3cDMEGGFj8TsJV1eVVfloy6FlQCaz6b(TOYda8BjYCaMpU6sarJo76Rb1KSnufid2Uwt1sLditpq1bjrnGFWHMnQ9LALJ8(wG4ueqJdM(3sMeFpg1cIdUDTeiVwATag1EzTYrEtuuBpJAB5x9BrLdTZK43QjhGq3wF5r(VVeLvoFc8TqNPhi4xcFR04BnX7BXIdM(3IkhqMEGFlQ8aa)wuuRrGu12cqLSQGbHSF6PbhevlHewRrGu12cqLCubdcz)0tdoiQwcjSwJaPQTfGkcsfmiK9tpn4GOAjUwt1YIdMUkyqi7NEAWbrQdsI6j0fyTVuRTaurYswBlPw58TaXPiGghm9V1RNbHSF1AzWbr1cM4SwpVAHKKiiKpC0UwdGRwaJAVgSwQadhdMgoGx7AbrAGEV2zwl8QvWET0yTGWEhkagxTxwliCkWWR9A4R2h8DG1YxTxdwBlimYRPwQadhdMgoGx7ANhli6BrLdTZK43QfgyEAGjcQNgCq0)(suwc6tGVf6m9ab)s4BLgFRjEFlwCW0)wu5aY0d8BrLha43IgO3vCiyh1g5dgkW8XR1uT0a9UkaCuNDTr(GHcmF8Anvlisd07Qlben6SRVgutY2qfy(41AQ2wvlvoGm9avTWaZtdmrq90GdIQ1uTGinqVRcgeY(PNgCqKMkWWXGPHd41wbMp(3IkhANjXVvcCtiiQZUwK5amF85)(suwz2NaFl0z6bc(LW3kn(wt8(wS4GP)TOYbKPh43IkpaWVva4ypdBuXHGDu3Wbz6TvOZ0deSwt1srTuuRiPIo7NIO2bK9AnvRiZby(4QGbHSF6PbhePcKKH(S2xQLkhqMEGQgoitVTEESGi9bjXAjUwI)wu5q7mj(TMhlis3Wbz6T)3)(wDOZdnnq4Fc8LOSFc8TqNPhi4xcFlwCW0)wCiyh1KW5eoW53s0Wq)Bj73seWddi)TOb6DLyGCi45bDBvGS4(3xIY5tGVfloy6FloeSJA6bpVVf6m9ab)s4FFjsqFc8TyXbt)BXHGDutZrW243cDMEGGFj8V)9VVfvmMW0)suoYtoYkpzUCiOV1dho0TNFlzYw(1lXxPeFDt51wlbAWAHKgzC12ZO23nCqME731gylcagiyTZKeRLbUKKpeSwrd724uvMrWqhRvwkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRLYO8ABD6uX4qWAFFb0jcpftluImhG5J)U2lR9TiZby(4kMw8UwkKvsIvLzem0XALPuETToDQyCiyTVVa6eHNIPfkrMdW8XFx7L1(wK5amFCftlExlfYkjXQYmcg6yTYCkV2wNovmoeS23I0bbGNsUVR9YAFlsheaEk5QqNPhi47APqwjjwvMrWqhRvw5q51260PIXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkjXQYmcg6yTYsquETToDQyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSssSQmJGHowRSYmkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRvwzgLxBRtNkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRKeRkZiyOJ1kh5r51260PIXHG1(wKoia8uY9DTxw7Br6GaWtjxf6m9abFxlfYkjXQYSYmzYw(1lXxPeFDt51wlbAWAHKgzC12ZO23D4Sb6260aDmExBGTiayGG1otsSwg4ss(qWAfnSBJtvzgbdDSwzP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKJKeRkZiyOJ1khkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRLGO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALzuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTugLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowRmLYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47A5RwzIxhcUwkKvsIvLzem0XABXuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTTykV2wNovmoeS23I0bbGNsUVR9YAFlsheaEk5QqNPhi47A5RwzIxhcUwkKvsIvLzem0XALvouETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYrsIvLzem0XALLYO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALvMt51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1kBlMYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoYs51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjXQYmcg6yTYrMr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuihjjwvMrWqhRvoYmkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLVALjEDi4APqwjjwvMrWqhRvoYukV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLVALjEDi4APqwjjwvMrWqhRvoVckV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMvMjt2YVEj(kL4RBkV2AjqdwlK0iJR2Eg1(oYJpy6VRnWweamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmJGHowRSuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTYHYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRLGO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XAPmkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRvMs51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjXQYmcg6yTYkpkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRv2wmLxBRtNkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKeRkZiyOJ1kBlMYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoYJYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvsIvLzem0XALJ8O8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALJSuETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmJGHowRCKLYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoYHYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoeeLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmRmtMSLF9s8vkXx3uET1sGgSwiPrgxT9mQ9DAGogVRnWweamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTYHYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvwcIYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKvsIvLzem0XALvMs51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DT8vRmXRdbxlfYkjXQYmcg6yTY(kO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(Uw(QvM41HGRLczLKyvzgbdDSwzL5uETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmRmtMSLF9s8vkXx3uET1sGgSwiPrgxT9mQ9ni2zGX9U2aBraWabRDMKyTmWLK8HG1kAy3gNQYmcg6yTYHYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJKeRkZiyOJ1kZO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALvMr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1kRmLYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvwzoLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowRCKhLxBRtNkghcwRfKS11oB7hlzTTGR2lRLGb4AbHuHty61MgyWxg1sHmiUwkKvsIvLzem0XALJ8O8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALdbr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DT8vRmXRdbxlfYkjXQYmcg6yTYrMr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1khkJYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoYukV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSw58kO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALJmNYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMvMjt2YVEj(kL4RBkV2AjqdwlK0iJR2Eg1(2iqrssZ37AdSfbadeS2zsI1YaxsYhcwROHDBCQkZiyOJ1ktP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALPuETToDQyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSssSQmJGHowRCKhLxBRtNkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRKeRkZiyOJ1khzP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALJSuETToDQyCiyTVfPdcapLCFx7L1(wKoia8uYvHotpqW31sHSssSQmJGHowRCKdLxBRtNkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DTuiRKeRkZiyOJ1kNwmLxBRtNkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuihjjwvMrWqhRvoTykV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwcsouETToDQyCiyTVNjWGg6Gk5(U2lR99mbg0qhujxf6m9abFxlfYkjXQYmcg6yTeKCO8ABD6uX4qWAFptGbn0bvY9DTxw77zcmOHoOsUk0z6bc(Uw(QvM41HGRLczLKyvzgbdDSwcIGO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XAjicIYRT1PtfJdbR9TiDqa4PK77AVS23I0bbGNsUk0z6bc(UwkKvsIvLzem0XAjizgLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31YxTYeVoeCTuiRKeRkZiyOJ1squgLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowlbjtP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzLzYKT8RxIVsj(6MYRTwc0G1cjnY4QTNrTVfzoaZhF(U2aBraWabRDMKyTmWLK8HG1kAy3gNQYmcg6yTYs51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYrsIvLzem0XALLYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvouETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHCKKyvzgbdDSw5q51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1squETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHCKKyvzgbdDSwcIYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvMr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1szuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTYukV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqossSQmJGHow7RGYRT1PtfJdbR99mbg0qhuj331EzTVNjWGg6Gk5QqNPhi47APqossSQmJGHowBlMYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJKeRkZiyOJ1kR8O8ABD6uX4qWAFF8a9tj331EzTVpEG(PKRcDMEGGVRLc5ijXQYmcg6yTYkhkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqossSQmJGHowRSeeLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowRSYmkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwzPmkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRvwzkLxBRtNkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuiRKeRkZiyOJ1kh5r51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjXQYSYmzYw(1lXxPeFDt51wlbAWAHKgzC12ZO23CIVRnWweamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHCKKyvzgbdDSwzP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALdLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHCKKyvzgbdDSwcIYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(UwkKJKeRkZiyOJ1squETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTYmkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwkJYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvMs51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYkjXQYmcg6yTVckV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwzoLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowBlMYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvw5r51260PIXHG1((4b6NsUVR9YAFF8a9tjxf6m9abFxlfYrsIvLzem0XALvwkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwzLdLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowRSeeLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHSssSQmJGHowRSYmkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqossSQmJGHowRSVckV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqossSQmJGHowRSYCkV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqossSQmJGHowRCKLYRT1PtfJdbR99Xd0pLCFx7L1((4b6NsUk0z6bc(Uw(QvM41HGRLczLKyvzgbdDSw5ihkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSw5qquETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTYrMr51260PIXHG1(oaCSNHnQK77AVS23bGJ9mSrLCvOZ0de8DTuiRKeRkZiyOJ1khkJYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoYukV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSw58kO8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XALJmNYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRvoTykV2wNovmoeS23hpq)uY9DTxw77JhOFk5QqNPhi47APqwjjwvMrWqhRvoTykV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwcsEuETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmJGHowlbjpkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwcsouETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYkjXQYmcg6yTeKmJYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMrWqhRLGKPuETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmJGHowlbjtP8ABD6uX4qWAFhao2ZWgvY9DTxw77aWXEg2OsUk0z6bc(UwkKvsIvLzem0XAjOxbLxBRtNkghcw77JhOFk5(U2lR99Xd0pLCvOZ0de8DTuihjjwvMrWqhRLGK5uETToDQyCiyTVpEG(PK77AVS23hpq)uYvHotpqW31sHSssSQmRmtMSLF9s8vkXx3uET1sGgSwiPrgxT9mQ9TGhcGbFW0NVRnWweamqWANjjwldCjjFiyTIg2TXPQmJGHowRSuETToDQyCiyTVdah7zyJk5(U2lR9Da4ypdBujxf6m9abFxlfYrsIvLzem0XALdLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31sHCKKyvzgbdDSwcIYRT1PtfJdbR1cs26ANT9JLS2wWv7L1sWaCTGqQWjm9Atdm4lJAPqgexlfYkjXQYmcg6yTYmkV2wNovmoeS23bGJ9mSrLCFx7L1(oaCSNHnQKRcDMEGGVRLczLKyvzgbdDSwzoLxBRtNkghcw7Br6GaWtj331EzTVfPdcapLCvOZ0de8DT8vRmXRdbxlfYkjXQYmcg6yTYkpkV2wNovmoeS23xaDIWtX0cLiZby(4VR9YAFlYCaMpUIPfVRLczLKyvzgbdDSwzLhLxBRtNkghcw77aWXEg2OsUVR9YAFhao2ZWgvYvHotpqW31YxTYeVoeCTuiRKeRkZiyOJ1kRmJYRT1PtfJdbR9Da4ypdBuj331EzTVdah7zyJk5QqNPhi47APqwjjwvMvM9kjnY4qWALvE1YIdMETd48MQYSVLrKD4a)wV2RvBlLTXAB5qWowM9AVwTTmGnW8QvoeK51kh5jhzlZkZETxR2w3WUnoP8YSx71QTfQ2wGjw712ak4rTwqYwxBd7GdOBxB2Rv0WUJJAH(HrayCW0Rf6ZdzWAZETVfSlWHMfhm93QYSx71QTfQ2w3WUnwlhc2rn07qhETR9YA5qWoQB4Gm921sb8Q1rQyu7d6xTdivSwEwlhc2rDdhKP3Myvz2R9A12cv7RlP)(QvMGAk4dRf612YVoYe12cdmVAPrbdmXABNaVdS2e4Qn71gSBJ1YoyTEE1cmHUDTTCiyhRvMqsJroHPRkZkZyXbtFQmcuKK08rjPYGdb7Og6hogO4kZyXbtFQmcuKK08rjPYGdb7OUZKWbKJYmwCW0NkJafjjnFusQmeP3cdeOMKDwBJKLzS4GPpvgbkssA(OKuzqLditpqZDMeLYjQpoSXtlsa)mpnKg4epZbXodmoPeuzgloy6tLrGIKKMpkjvgu5aY0d0CNjrPi1uBioZtdPboXZCqSZaJtQSuwzgloy6tLrGIKKMpkjvgu5aY0d0CNjrPgbAamgAKAAEAiDIN5WUukcah7zyJQj0OjD98YG0efIKk6SFkQOFnTdcjuKurN9t5OiYrgGesOiDqa4P4qWoQnIeeA3MyInNkpaqPYAovEaGACmrPYRmJfhm9PYiqrssZhLKkdQCaz6bAUZKO0gMkQtd0rqZtdPt8mh2LYIdsf1OJKqCkFPu5aY0duXjQpoSXtlsa)mNkpaqPYAovEaGACmrPYRmJfhm9PYiqrssZhLKkdQCaz6bAUZKO0o05HMgiCZtdPt8mNkpaqPYRmJfhm9PYiqrssZhLKkdQCaz6bAUZKO0goitVTEESGi9bjrZtdPboXZCqSZaJtAlUmJfhm9PYiqrssZhLKkdQCaz6bAUZKOuE8WTN6zBxOfzoaZhFAEAinWjEMdIDgyCsLxzgloy6tLrGIKKMpkjvgu5aY0d0CNjrPXutYsQbXb3w3ZqF5rAEAinWjEMdIDgyCsPSYmwCW0NkJafjjnFusQmOYbKPhO5otIsJPMKLudIdUTUNHosdZtdPboXZCqSZaJtkLvMXIdM(uzeOijP5JssLbvoGm9an3zsuAm1KSKAqCWT19m0SH5PH0aN4zoi2zGXjvoYRmJfhm9PYiqrssZhLKkdQCaz6bAUZKOuY80gbkqeuF5rQPBBEAinWjEMdIDgyCsL5LzS4GPpvgbkssA(OKuzqLditpqZDMeLsMNMKLudIdUTUNH(YJ080qAGt8mhe7mW4KkR8kZyXbtFQmcuKK08rjPYGkhqMEGM7mjkLmpnjlPgehCBDpdnByEAinWjEMdIDgyCsLLYkZyXbtFQmcuKK08rjPYGkhqMEGM7mjkLn0KSKAqCWT19m0xEKMNgsdCIN5WUur6GaWtXHGDuBeji0UT5u5bakLGKN5u5baQXXeLkR8kZyXbtFQmcuKK08rjPYGkhqMEGM7mjkLn0KSKAqCWT19m0xEKMNgsdCIN5GyNbgNu5iVYmwCW0NkJafjjnFusQmOYbKPhO5otIszdnjlPgehCBDpdnzEMNgsdCIN5GyNbgNu5iVYmwCW0NkJafjjnFusQmOYbKPhO5otIsJ0qtYsQbXb3w3ZqF5rAEAiDIN5u5bakvoYRfIckRLisheaEkoeSJAJibH2TjUmJfhm9PYiqrssZhLKkdQCaz6bAUZKO0lpsnjlPgehCBDpdnByEAiDIN5u5bakLYOKCKxlHcrsfD2pLdTBoDNrcjKcr6GaWtXHGDuBeji0UTjwCqQOgDKeIZxOYbKPhOItuFCyJNwKa(rmXuswkRLqHiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32eloivuJoscXP8LsLditpqfNO(4WgpTib8J4YmwCW0NkJafjjnFusQmOYbKPhO5otIsV8i1KSKAqCWT19m0rAyEAiDIN5u5bakvoYRfIczElrKoia8uCiyh1grccTBtCzgloy6tLrGIKKMpkjvgu5aY0d0CNjrP0CeSnQjzN1gIZ80q6epZHDPIKk6SFkhA3C6oJMtLhaOuzQ8AHOGKNhgT1u5ba2sKvEYJ4YmwCW0NkJafjjnFusQmOYbKPhO5otIsP5iyButYoRneN5PH0jEMd7sfjv0z)ue1oGSBovEaGsBXuwlefK88WOTMkpaWwISYtEexMXIdM(uzeOijP5JssLbvoGm9an3zsuknhbBJAs2zTH4mpnKoXZCyxkvoGm9av0CeSnQjzN1gItQ8mNkpaqPYC51crbjppmARPYdaSLiR8KhXLzS4GPpvgbkssA(OKuzqLditpqZDMeLYgAsOdjbi1KSZAdXzEAinWjEMdIDgyCsLLYkZyXbtFQmcuKK08rjPYGkhqMEGM7mjk9YJutYsQfnCyJtZtdPboXZCqSZaJtQCkZyXbtFQmcuKK08rjPYGkhqMEGM7mjkLtuF5rQjzj1IgoSXP5PH0aN4zoi2zGXjvoLzS4GPpvgbkssA(OKuzqLditpqZDMeL2HZgOBRtd0XW80q6epZPYdauQSTekWwea0WabviPr7a5HodqNDbsiHuC8a9tfaoQZU2iFWWefhpq)uCiyh1OOjjKWwjsQOZ(PiQDazNytu0krsfD2pLJIihzasiHS4Gurn6ijeNsLLqcdah7zyJQj0OjD98YGKytTsKurN9trf9RPDqmXLzS4GPpvgbkssA(OKuzqLditpqZDMeLYg601at080q6epZPYdauk2IaGggiOIKfmDG6zdINMeycfesi2IaGggiOYEWGq(YyQPzqBKqcXwea0Wabv2dgeYxgtnjcYJbmDcjeBraqddeubYbrKz6AquqK2a4cCkqxGesi2IaGggiOc6traCm9a1Tia2pasnisfkqcjeBraqddeuntGXaVd626aGUnHeITiaOHbcQMao9itqntIxt75riHylcaAyGGQhMi0XyQ7r6Gesi2IaGggiOQpysuNDnnF3alZyXbtFQmcuKK08rjPYGegrgAijBJLzS4GPpvgbkssA(OKuz0h4SreC)mh2LotGbn0bvuZbFWbQN5Gk6hHeotGbn0bvgaZdyGAmamoy6LzS4GPpvgbkssA(OKuzeaoQZU2iFWWCyxQiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32KiDqa4P4qWoQnIeeA32evoGm9av84HBp1Z2UqlYCaMp(0eloivuJoscX5lu5aY0duXjQpoSXtlsa)kZyXbtFQmcuKK08rjPYOh58OZXzoSlTvu5aY0duzeObWyOrQPuznfao2ZWgvGWPaAmGohT1IKKKDWYmwCW0NkJafjjnFusQm4qWoQPh88mh2L2kQCaz6bQmc0aym0i1uQSMAva4ypdBubcNcOXa6C0wlsss2bnrrRejv0z)uur)AAhesivoGm9avD4Sb6260aDmiUmJfhm9PYiqrssZhLKkdsyezm1zxFzqI(zoSlTvu5aY0duzeObWyOrQPuzn1QaWXEg2OceofqJb05OTwKKKSdAsKurN9trf9RPDyQvu5aY0du1HZgOBRtd0XOmJfhm9PYiqrssZhLKkdKAk4dMU5WUuQCaz6bQmc0aym0i1uQSLzLzS4GPpPKuzisa)WyAGJrzgloy6tkjvgatutYoRTrsZHDPuC8a9tH(aA3COJGMizNvgI7fPYC5zIKDwzio5lvMszetiHu0QJhOFk0hq7MdDe0ej7SYqCVivMtzexMXIdM(KssLHrEW0nh2Lsd07koeSJAJ8bdfGrzgloy6tkjvghKe1pCyyoSlnaCSNHnQoK0idEOF4WWenqVRqjByG5btxbyyIcrMdW8XvCiyh1g5dgQazW2esiDoNM6q7Mthijd95lsLzYJ4YmwCW0NusQmgq7MBQBHbaTjr)mh2Lsd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MarAGExDjGOrND91GAs2gQaZhVmJfhm9jLKkdA2wND9fqbrtZHDP0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFsjPYGgJjgebDBZHDP0a9UIdb7O2iFWqbyuMXIdM(KssLb9itqDhiABoSlLgO3vCiyh1g5dgkaJYmwCW0NusQm6WaPhzcAoSlLgO3vCiyh1g5dgkaJYmwCW0NusQmyxGZl4HwWJH5WUuAGExXHGDuBKpyOamkZyXbtFsjPYayIA4HKtZHDP0a9UIdb7O2iFWqbyuMXIdM(KssLbWe1Wdjnh7DuCANjrP2dgeYxgtnndAJMd7sPb6Dfhc2rTr(GHcWGqcfzoaZhxXHGDuBKpyOcKKH(u(sPmkZeisd07Qlben6SRVgutY2qfGrzgloy6tkjvgatudpK0CNjrPiPr7a5HodqNDbAoSlvK5amFCfhc2rTr(GHkqsg6ZxKklLzsK5amFC1LaIgD21xdQjzBOkqsg6ZxKklLvMXIdM(KssLbWe1Wdjn3zsukyGmyhgOMkoN4WCyxQiZby(4koeSJAJ8bdvGKm0NYxQCKhHe2kQCaz6bQydD6AGjkvwcjKIdsIsLNjQCaz6bQ6Wzd0T1Pb6yivwtbGJ9mSr1eA0KUEEzqsCzgloy6tkjvgatudpK0CNjrPZeyOH2o8WWCyxQiZby(4koeSJAJ8bdvGKm0NYxkbjpcjSvu5aY0duXg601atuQSLzS4GPpPKuzamrn8qsZDMeLApAB0OZUMNtijCWhmDZHDPImhG5JR4qWoQnYhmubsYqFkFPYrEesyROYbKPhOIn0PRbMOuzjKqkoijkvEMOYbKPhOQdNnq3wNgOJHuznfao2ZWgvtOrt665LbjXLzS4GPpPKuzamrn8qsZDMeLsYcMoq9SbXttcmHcZHDPImhG5JR4qWoQnYhmubsYqF(IukZefTIkhqMEGQoC2aDBDAGogsLLqcpijkFcsEexMXIdM(KssLbWe1Wdjn3zsukjly6a1ZgepnjWekmh2LkYCaMpUIdb7O2iFWqfijd95lsPmtu5aY0du1HZgOBRtd0XqQSMOb6Dva4Oo7AJ8bdfGHjAGExfaoQZU2iFWqfijd95lsPqw51crzTKaWXEg2OAcnAsxpVmij20bjXxii5vMXIdM(KssLbWe1Wdjn3zsu6SHbZheuNbTo76lds0pZHDPhKeLkpcjKcQCaz6bQsGBcbrD21ImhG5JpnrbfIKk6SFkIAhq2njYCaMpUkyqi7NEAWbrQajzOpFrQCmjYCaMpUIdb7O2iFWqfijd95lsPmtImhG5JRUeq0OZU(AqnjBdvbsYqF(IukJycjuK5amFCfhc2rTr(GHkqsg6ZxKkhcjSdTBoDGKm0NViYCaMpUIdb7O2iFWqfijd9jXexM9A1szkzATWzTxdw70arWAZETxdwRvcmg4Dq3U2xpaD7AnISfgfhCGLzS4GPpPKuzamrn8qsZDMeLotGXaVd626aGUT5WUukOYbKPhO6GKOgWp4qZguIcwCW0vbdcz)0tdoisHsIcGd1hKeBjIKk6SFkIAhq2jMsuWIdMUce5RHodhvOKOa4q9bjXwIiPIo7NYrrKJmajMsS4GPRUeq0OZU(AqnjBdvOKOa4q9bjXxooSXtbcNh7cSfCuMsMsSjkOYbKPhOQHPI60aDeKqcPqKurN9tru7aYUPaWXEg2OIdb7Og6DOdV2etSPJdB8uGW5XUaLVCOSYSx71QLfhm9jLKkdhF6jGdQdCMdQO5atu)0ahOwWZd62sL1CyxknqVR4qWoQnYhmuagesiisd07Qlben6SRVgutY2qfGbHecMNkyqi7NEAWbrQdkic62LzS4GPpPKuzi4XqZIdMUEaNN5otIsf8qam4dM(SmJfhm9jLKkdbpgAwCW01d48m3zsukNO5ZlGItQSMd7szXbPIA0rsioLVuQCaz6bQ4e1hh24PfjGFLzS4GPpPKuzi4XqZIdMUEaNN5otIsB4Gm92Md7sfjv0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92LzS4GPpPKuzi4XqZIdMUEaNN5otIs7Wzd0T1Pb6yyoSlLkhqMEGQgMkQtd0rqPYZevoGm9avD4Sb6260aDmm1kkejv0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92exMXIdM(KssLHGhdnloy66bCEM7mjknnqhdZHDPu5aY0du1WurDAGockvEMAffIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBIlZyXbtFsjPYqWJHMfhmD9aopZDMeLkYCaMp(0CyxAROqKurN9tru7aYUPaWXEg2OIdb7OUHdY0BtCzgloy6tkjvgcEm0S4GPRhW5zUZKO0ip(GPBoSlLkhqMEGQo05HMgiCPYZuROqKurN9tru7aYUPaWXEg2OIdb7OUHdY0BtCzgloy6tkjvgcEm0S4GPRhW5zUZKO0o05HMgiCZHDPu5aY0du1Hop00aHlvwtTIcrsfD2pfrTdi7Mcah7zyJkoeSJ6goitVnXLzLzS4GPpvCIs7rop6CCMd7sdah7zyJkq4uangqNJ2ArssYoOjrMdW8Xv0a9UgeofqJb05OTwKKKSdQcKbBBIgO3vGWPaAmGohT1IKKKDqDpY5PaZh3ef0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xj2KiZby(4Qlben6SRVgutY2qvGKm0NsLNjkOb6Dfhc2rTOHdBunpwq0lsPYbKPhOItuF5rQjzj1IgoSXPjkO44b6NkaCuNDTr(GHjrMdW8XvbGJ6SRnYhmubsYqF(IuBbOjrMdW8XvCiyh1g5dgQajzOpLpvoGm9avxEKAswsnio426EgA2GycjKIwD8a9tfaoQZU2iFWWKiZby(4koeSJAJ8bdvGKm0NYNkhqMEGQlpsnjlPgehCBDpdnBqmHekYCaMpUIdb7O2iFWqfijd95lsTfGetCzgloy6tfNiLKkJomqn9GNN5WUukcah7zyJkq4uangqNJ2ArssYoOjrMdW8Xv0a9UgeofqJb05OTwKKKSdQcKbBBIgO3vGWPaAmGohT1IKKKDqDhgOcmFCtgbsvBlavYQ6rop6CCetiHueao2ZWgvGWPaAmGohT1IKKKDqthKeLkpIlZyXbtFQ4ePKuz0JCEApPYMd7sdah7zyJk7aohT1qbumqtImhG5JR4qWoQnYhmubsYqFkFcsEMezoaZhxDjGOrND91GAs2gQcKKH(uQ8mrbnqVR4qWoQfnCyJQ5XcIErkvoGm9avCI6lpsnjlPw0WHnonrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYsQbXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzj1G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaKyIlZyXbtFQ4ePKuz0JCEApPYMd7sdah7zyJk7aohT1qbumqtImhG5JR4qWoQnYhmubsYqFkvEMOGckezoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0duXgAswsnio426Eg6lpst0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJksws98ybretiHuiYCaMpU6sarJo76Rb1KSnufijd9Pu5zIgO3vCiyh1IgoSr18ybrViLkhqMEGkor9LhPMKLulA4WgNetSjAGExfaoQZU2iFWqbMpoXLzS4GPpvCIusQm4qWoQjHZjCGtZHDPIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7OUHdY0BRMhli6fzPmtImhG5JRcgeY(PNgCqKkqsg6ZxKsLditpqvdhKP3wppwqK(GKiLqjrbWH6dsIMezoaZhxDjGOrND91GAs2gQcKKH(8fPu5aY0du1Wbz6T1ZJfePpijsjusuaCO(GKiLyXbtxfmiK9tpn4GifkjkaouFqs0KiZby(4koeSJAJ8bdvGKm0NViLkhqMEGQgoitVTEESGi9bjrkHsIcGd1hKePeloy6QGbHSF6PbhePqjrbWH6dsIuIfhmD1LaIgD21xdQjzBOcLefahQpijAUOHHUuzlZyXbtFQ4ePKuzWHGDutp45zoSlvKurN9trf9RPDy64b6NIdb7OgfnPPdsIViR8mjYCaMpUIegrgtD21xgKOFQajzOpnrd07kXa5qWZd62Q5XcIEHGkZyXbtFQ4ePKuzamrn8qsZDMeLotGXaVd626aGUT5WU0aWXEg2OAcnAsxpVminzeivTTaujRcPMc(GPxMXIdM(uXjsjPY4sarJo76Rb1KSn0CyxAa4ypdBunHgnPRNxgKMmcKQ2waQKvHutbFW0lZyXbtFQ4ePKuzWHGDuBKpyyoSlnaCSNHnQMqJM01ZldstuyeivTTaujRcPMc(GPtiHgbsvBlavYQUeq0OZU(AqnjBdjUmJfhm9PItKssLbjmImM6SRVmir)mh2LkYCaMpUIdb7O2iFWqfijd95lsL5MezoaZhxDjGOrND91GAs2gQcKKH(8fPYCtuqd07koeSJArdh2OAESGOxKsLditpqfNO(YJutYsQfnCyJttuqXXd0pva4Oo7AJ8bdtImhG5JRcah1zxBKpyOcKKH(8fP2cqtImhG5JR4qWoQnYhmubsYqFkFkJycjKIwD8a9tfaoQZU2iFWWKiZby(4koeSJAJ8bdvGKm0NYNYiMqcfzoaZhxXHGDuBKpyOcKKH(8fP2cqIjUmJfhm9PItKssLbsnf8bt3Cyx6bjr5tqYZua4ypdBunHgnPRNxgKMejv0z)uur)AAhMmcKQ2waQKvrcJiJPo76lds0VYmwCW0Nkorkjvgi1uWhmDZHDPhKeLpbjptbGJ9mSr1eA0KUEEzqAIgO3vCiyh1IgoSr18ybrViLkhqMEGkor9LhPMKLulA4WgNMezoaZhxDjGOrND91GAs2gQcKKH(uQ8mjYCaMpUIdb7O2iFWqfijd95lsTfGLzS4GPpvCIusQmqQPGpy6Md7spijkFcsEMcah7zyJQj0OjD98YG0KiZby(4koeSJAJ8bdvGKm0NsLNjkOGcrMdW8XvxciA0zxFnOMKTHQajzOpLpvoGm9avSHMKLudIdUTUNH(YJ0enqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLuppwqeXesifImhG5JRUeq0OZU(AqnjBdvbsYqFkvEMOb6Dfhc2rTOHdBunpwq0lsPYbKPhOItuF5rQjzj1IgoSXjXeBIgO3vbGJ6SRnYhmuG5JtS5q)WiamonSlLgO3vtOrt665LbPAESGiP0a9UAcnAsxpVmivKSK65XcImh6hgbGXPHKKiiKpuQSLzS4GPpvCIusQmcgeY(PNgCqK5WUurMdW8XvxciA0zxFnOMKTHQajzOpFbLefahQpijAIckoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NVi1waAsK5amFCfhc2rTr(GHkqsg6t5tLditpq1LhPMKLudIdUTUNHMniMqcPOvhpq)ubGJ6SRnYhmmjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYsQbXb3w3ZqZgetiHImhG5JR4qWoQnYhmubsYqF(IuBbiXLzS4GPpvCIusQmcgeY(PNgCqK5WUurMdW8XvCiyh1g5dgQajzOpFbLefahQpijAIckOqK5amFC1LaIgD21xdQjzBOkqsg6t5tLditpqfBOjzj1G4GBR7zOV8inrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfe9IuQCaz6bQ4e1xEKAswsTOHdBCsmXMOb6Dva4Oo7AJ8bdfy(4exMXIdM(uXjsjPYae5RHodhnh2LkYCaMpUIdb7O2iFWqfijd9Pu5zIckOqK5amFC1LaIgD21xdQjzBOkqsg6t5tLditpqfBOjzj1G4GBR7zOV8inrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfe9IuQCaz6bQ4e1xEKAswsTOHdBCsmXMOb6Dva4Oo7AJ8bdfy(4exMXIdM(uXjsjPYayIA4HKM7mjkDMaJbEh0T1baDBZHDPuqd07koeSJArdh2OAESGOxKsLditpqfNO(YJutYsQfnCyJtcj0iqQABbOswvWGq2p90GdIi2efuC8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrQTa0KiZby(4koeSJAJ8bdvGKm0NYNkhqMEGQlpsnjlPgehCBDpdnBqmHesrRoEG(Pcah1zxBKpyysK5amFCfhc2rTr(GHkqsg6t5tLditpq1LhPMKLudIdUTUNHMniMqcfzoaZhxXHGDuBKpyOcKKH(8fP2cqIlZyXbtFQ4ePKuzCjGOrND91GAs2gAoSlLcAGExXHGDulA4WgvZJfe9IuQCaz6bQ4e1xEKAswsTOHdBCsiHgbsvBlavYQcgeY(PNgCqeXMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzj1G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFQCaz6bQU8i1KSKAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasCzgloy6tfNiLKkdoeSJAJ8bdZHDPuqHiZby(4Qlben6SRVgutY2qvGKm0NYNkhqMEGk2qtYsQbXb3w3ZqF5rAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliIycjKcrMdW8XvxciA0zxFnOMKTHQajzOpLkpt0a9UIdb7Ow0WHnQMhli6fPu5aY0duXjQV8i1KSKArdh24KyInrd07QaWrD21g5dgkW8XlZyXbtFQ4ePKuzeaoQZU2iFWWCyxknqVRcah1zxBKpyOaZh3efuiYCaMpU6sarJo76Rb1KSnufijd9P8LJ8mrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfe9IuQCaz6bQ4e1xEKAswsTOHdBCsmXMOqK5amFCfhc2rTr(GHkqsg6t5lRCiKqqKgO3vxciA0zxFnOMKTHkadIlZyXbtFQ4ePKuzmBG9d62AJ8bdZHDPImhG5JR4qWoQZGwfijd9P8PmcjSvhpq)uCiyh1zqxMXIdM(uXjsjPYGdb7OMEWZZCyxQiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMarAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPYmtgbsvBlavYQ4qWoQZG2eloivuJoscX5lVIYmwCW0NkorkjvgCiyh10CeSnAoSlvKurN9tru7aYUPaWXEg2OIdb7OUHdY0BBIgO3vCiyh1g5dgkadtGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwqKuzwzgloy6tfNiLKkdoeSJA6bppZHDPIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyyIcW8ubdcz)0tdoisfijd9P8LPesiisd07QGbHSF6PbhePPcmCmyA4aETvageBcePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIErMzIfhKkQrhjH4ukbvMXIdM(uXjsjPYGdb7OodAZHDPIKk6SFkIAhq2nfao2ZWgvCiyh1nCqMEBt0a9UIdb7O2iFWqbyycePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIKsqLzS4GPpvCIusQm4qWoQP5iyB0CyxQiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP32enqVR4qWoQnYhmuagMarAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPYPmJfhm9PItKssLbhc2rnkPXiNW0nh2LksQOZ(PiQDaz3ua4ypdBuXHGDu3Wbz6Tnrd07koeSJAJ8bdfGHjJaPQTfGk5OcgeY(PNgCqKjwCqQOgDKeIt5tqLzS4GPpvCIusQm4qWoQrjng5eMU5WUursfD2pfrTdi7Mcah7zyJkoeSJ6goitVTjAGExXHGDuBKpyOammbI0a9Ukyqi7NEAWbrAQadhdMgoGxB18ybrsL1eloivuJoscXP8jOYmwCW0NkorkjvggborxG6SRjHoO5WUuAGExbI81qNHJkadtGinqVRUeq0OZU(AqnjBdvagMarAGExDjGOrND91GAs2gQcKKH(8fP0a9UYiWj6cuNDnj0bvKSK65XcIAjS4GPR4qWoQPh88uOKOa4q9bjrtuqXXd0pvGZ0zxGMyXbPIA0rsioFrMrmHeYIdsf1OJKqC(cLrSjkAva4ypdBuXHGDutNK0CasI(riHhh24PAqECnkdXjFcIYiUmJfhm9PItKssLbhc2rn9GNN5WUuAGExbI81qNHJkadtuqXXd0pvGZ0zxGMyXbPIA0rsioFrMrmHeYIdsf1OJKqC(cLrSjkAva4ypdBuXHGDutNK0CasI(riHhh24PAqECnkdXjFcIYiUmJfhm9PItKssLXeWadpPYLzS4GPpvCIusQm4qWoQP5iyB0CyxknqVR4qWoQfnCyJQ5XcIKVukyXbPIA0rsioBHKLytbGJ9mSrfhc2rnDssZbij6NPJdB8unipUgLH4EHGOSYmwCW0NkorkjvgCiyh10CeSnAoSlLgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliQmJfhm9PItKssLbhc2rDg0Md7sPb6Dfhc2rTOHdBunpwqKu5zIcrMdW8XvCiyh1g5dgQajzOpLVSugHe2kkejv0z)ue1oGSBkaCSNHnQ4qWoQB4Gm92etCzgloy6tfNiLKkdhVgm0hsAGZZCyxkfb2dC2W0dKqcB1bfebDBInrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfevMXIdM(uXjsjPYGdb7OMeoNWbonh2Lsd07kXa5qWZd62QazXzkaCSNHnQ4qWoQB4Gm92MOGIJhOFkM0ya7qbFW0nXIdsf1OJKqC(ImNycjKfhKkQrhjH48fkJ4YmwCW0NkorkjvgCiyh1KW5eoWP5WUuAGExjgihcEEq3wfilothpq)uCiyh1OOjnbI0a9U6sarJo76Rb1KSnubyyIIJhOFkM0ya7qbFW0jKqwCqQOgDKeIZxAXexMXIdM(uXjsjPYGdb7OMeoNWbonh2Lsd07kXa5qWZd62QazXz64b6NIjngWouWhmDtS4Gurn6ijeNViZkZyXbtFQ4ePKuzWHGDuJsAmYjmDZHDP0a9UIdb7Ow0WHnQMhli6fAGExXHGDulA4WgvKSK65XcIkZyXbtFQ4ePKuzWHGDuJsAmYjmDZHDP0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJksws98ybrMmcKQ2waQKvXHGDutZrW2yz2R9A1YIdM(uXjsjPYaPMc(GPBo0pmcaJtd7sjzNvgIt(sL5uM5q)WiamonKKebH8HsLTmRmJfhm9PsWdbWGpy6tPu5aY0d0CNjrPnmvuNgOJGMNgsN4zovEaGsL1CyxkvoGm9avnmvuNgOJGsLNjJaPQTfGkzvi1uWhmDtTIIaWXEg2OAcnAsxpVmijKWaWXEg2O6qsJm4H(HddIlZyXbtFQe8qam4dM(KssLbvoGm9an3zsuAdtf1Pb6iO5PH0jEMtLhaOuznh2LsLditpqvdtf1Pb6iOu5zIgO3vCiyh1g5dgkW8XnjYCaMpUIdb7O2iFWqfijd9Pjkcah7zyJQj0OjD98YGKqcdah7zyJQdjnYGh6homiUmJfhm9PsWdbWGpy6tkjvgu5aY0d0CNjrPDOZdnnq4MNgsN4zovEaGsL1CyxknqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLuppwqKPwrd07QayG6SRVMaXPcWWuhA3C6ajzOpFrkfuqYo3cowCW0vCiyh10dEEkropIBjS4GPR4qWoQPh88uOKOa4q9bjrIlZETALjGxdg1Y12bgJ21opwqecwBdhKP3U2mQf61IsIcGdRny3gR9bEn1kHKKMdqs0VYmwCW0Nkbpead(GPpPKuzqLditpqZDMeLIKg5dgiOMMJGTrZtdPt8mNkpaqP0a9UIdb7OUHdY0BRMhlis(sLLYiKqkcah7zyJkoeSJA6KKMdqs0pthh24PAqECnkdX9cbrzexMXIdM(uj4HayWhm9jLKkdQCaz6bAUZKO0bppnBObMO5GyNbgNu5zEAiDIN5WUuAGExXHGDuBKpyOammrbvoGm9avdEEA2qdmrPYJqcpijkFPu5aY0dun45PzdnWePKSugXMtLhaO0dsILzVwTTCiyhR9vJeeA3UwBivCwlxlvoGm9aRLjta)Qn71kadZRLg4Q9bFpg1cmXA5A7d(QfNhKKpy612GbQQLanyTtiPOwJiPcbrWAdKKH(uJsAGIdbRfL0iW5eMETGjoR1ZR2NmiQ2hCmQTNrTgrccTBxliaw7L1EnyT0aX8AxRZhqG1M9AVgSwbyOkZyXbtFQe8qam4dM(KssLbvoGm9an3zsukopijFiOMn0ImhG5JBEAiDIN5u5bakLcrMdW8XvCiyh1g5dgkqGGpy6TekKTfIc5PKhb1sePdcapfhc2rTrKGq72QGDIiMyIBHO4GKylevoGm9avdEEA2qdmrIlZyXbtFQe8qam4dM(KssLbvoGm9an3zsu6bjrnGFWHMnmpnKoXZCyxQiDqa4P4qWoQnIeeA32CQ8aaLsLditpqfopijFiOMn0ImhG5JxMXIdM(uj4HayWhm9jLKkdQCaz6bAUZKO0dsIAa)GdnByEAiDIN5WU0wjsheaEkoeSJAJibH2TnNkpaqPImhG5JR4qWoQnYhmubsYqFwM9A1ktIVhJAbXb3U2w(vRfWO2lRvoYBIIA7zulbYRLwMXIdM(uj4HayWhm9jLKkdQCaz6bAUZKO0dsIAa)GdnByEAiLKL0CQ8aaLkYCaMpU6sarJo76Rb1KSnufijd9P5WUukezoaZhxDjGOrND91GAs2gQcKKH(SfIkhqMEGQdsIAa)GdnBq8lYrELzVwTwqxG1(6bOBxlCw7eq0ulxRr(Grhyu7fqNi8QTNrTVUUDaz38AFW3JrTZdkiQ2lR9AWAVNSwsOdCyTI2IbwlGFWrTpyT24vlxBd0UPw0ta7MAd2jQ2SxRrKGq72LzS4GPpvcEiag8btFsjPYGkhqMEGM7mjk9GKOgWp4qZgMNgsjzjnNkpaqPxaDIWtntGXaVd626aGUTsK5amFCvGKm0NMd7sfPdcapfhc2rTrKGq72MePdcapfhc2rTrKGq72QGDIEHYmHTiaOHbcQMjWyG3bDBDaq32KiPIo7NIO2bKDtbGJ9mSrfhc2rDdhKP3Um71QvMeFpg1cIdUDTeiVwATag1EzTYrEtuuBpJAB5xTmJfhm9PsWdbWGpy6tkjvgu5aY0d0CNjrPn5ae626lpsZtdPt8mNkpaqPImhG5JRUeq0OZU(AqnjBdvbYGTnrLditpq1bjrnGFWHMnEroYRm71Q91ZGq2VATm4GOAbtCwRNxTqsseeYhoAxRbWvlGrTxdwlvGHJbtdhWRDTGinqVx7mRfE1kyVwASwqyVdfaJR2lRfeofy41En8v7d(oWA5R2RbRTfeg51ulvGHJbtdhWRDTZJfevMXIdM(uj4HayWhm9jLKkdQCaz6bAUZKO0wyG5PbMiOEAWbrMNgsN4zovEaGsPWiqQABbOswvWGq2p90GdIiKqJaPQTfGk5OcgeY(PNgCqeHeAeivTTaurqQGbHSF6PbherSjwCW0vbdcz)0tdoisDqsupHUaFXwaQizjBjYPm71ETAFDcOn05rTwqYwxRObfeHG1cI0a9Ukyqi7NEAWbrAQadhdMgoGxBfy(4MxlnWv71WxTGjo93xTpzquTpnOx71G1YGGPxlBymG4S2xVvl4xl0Nh73OTQm71ETAzXbtFQe8qam4dM(KssLbvoGm9an3zsuAlmW80ateupn4GiZtdPt8mNkpaqPuyeivTTaujRkyqi7NEAWbresOrGu12cqLCubdcz)0tdoiIqcncKQ2waQiivWGq2p90GdIi2eisd07QGbHSF6PbhePPcmCmyA4aETvG5JxMXIdM(uj4HayWhm9jLKkdQCaz6bAUZKO0e4MqquNDTiZby(4tZtdPt8mNkpaqP0a9UIdb7O2iFWqbMpUjAGExfaoQZU2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kQCaz6bQAHbMNgyIG6PbhezcePb6DvWGq2p90GdI0ubgogmnCaV2kW8XlZyXbtFQe8qam4dM(KssLbvoGm9an3zsu68ybr6goitVT5PH0jEMtLhaO0aWXEg2OIdb7OUHdY0BBIckejv0z)ue1oGSBsK5amFCvWGq2p90GdIubsYqF(cvoGm9avnCqMEB98ybr6dsIetCzwz2Rv7RgWmGhSfewlWe621AhW5ODTqbumWAFGxtTSHQ2wGjwl8Q9bEn1E5rwBEny8aNOQmJfhm9PsK5amF8P0EKZt7jv2CyxAa4ypdBuzhW5OTgkGIbAsK5amFCfhc2rTr(GHkqsg6t5tqYZKiZby(4Qlben6SRVgutY2qvGmyBtuqd07koeSJArdh2OAESGOxKsLditpq1LhPMKLulA4WgNMOGIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsTfGMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzj1G4GBR7zOzdIjKqkA1Xd0pva4Oo7AJ8bdtImhG5JR4qWoQnYhmubsYqFkFQCaz6bQU8i1KSKAqCWT19m0SbXesOiZby(4koeSJAJ8bdvGKm0NVi1wasmXLzS4GPpvImhG5JpPKuz0JCEApPYMd7sdah7zyJk7aohT1qbumqtImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqEetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lR8mrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermHesHiZby(4Qlben6SRVgutY2qvGKm0NsLNjAGExXHGDulA4WgvZJfejvEetSjAGExfaoQZU2iFWqbMpUjs2zLH4KVuQCaz6bQydnj0HKaKAs2zTH4kZyXbtFQezoaZhFsjPYOh58OZXzoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b19iNNcmFCtuqd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdfy(4MarAGExDjGOrND91GAs2gQaZhNytImhG5JRUeq0OZU(AqnjBdvbsYqFkvEMOGgO3vCiyh1IgoSr18ybrViLkhqMEGQlpsnjlPw0WHnonrbfhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ZxKAlanjYCaMpUIdb7O2iFWqfijd9P8PYbKPhO6YJutYsQbXb3w3ZqZgetiHu0QJhOFQaWrD21g5dgMezoaZhxXHGDuBKpyOcKKH(u(u5aY0duD5rQjzj1G4GBR7zOzdIjKqrMdW8XvCiyh1g5dgQajzOpFrQTaKyIlZyXbtFQezoaZhFsjPYOddutp45zoSlnaCSNHnQaHtb0yaDoARfjjj7GMezoaZhxrd07Aq4uangqNJ2ArssYoOkqgSTjAGExbcNcOXa6C0wlsss2b1DyGkW8XnzeivTTaujRQh58OZXvM9A1(QmmQTLMeO2h41uBl)Q1c71cV3ZAfjj0TRfWO2zMUQ2xzVw4v7dCmQLgRfyIG1(aVMAjqETuZRvWZRw4v7CaTBUr7APXEgyzgloy6tLiZby(4tkjvgKWiYyQZU(YGe9ZCyxkfTkaCSNHnQMqJM01ZldscjKgO3vtOrt665LbPcWGytImhG5JRUeq0OZU(AqnjBdvbsYqF(cvoGm9avK5PncuGiO(YJut3MqcPGkhqMEGQdsIAa)GdnBiFQCaz6bQiZttYsQbXb3w3ZqZgMezoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0durMNMKLudIdUTUNH(YJK4YmwCW0NkrMdW8XNusQmiHrKXuND9Lbj6N5WUurMdW8XvCiyh1g5dgQazW2MOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vipIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSKAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSK65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYZenqVR4qWoQfnCyJQ5XcIKkpIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCLzS4GPpvImhG5JpPKuz0h4SreC)mh2LsLditpqvcCtiiQZUwK5amF8PjkMjWGg6GkQ5Gp4a1ZCqf9JqcNjWGg6GkdG5bmqngaghmDIlZETAB5Xd3EwlWeRfe5RHodhR9bEn1YgQAFL9AV8iRfoRnqgSDT8S2hCmmVwsMiS2jqG1EzTcEE1cVAPXEgyTxEKQYmwCW0NkrMdW8XNusQmar(AOZWrZHDPImhG5JRUeq0OZU(AqnjBdvbYGTnrd07koeSJArdh2OAESGOxKsLditpq1LhPMKLulA4WgNMezoaZhxXHGDuBKpyOcKKH(8fP2cWYmwCW0NkrMdW8XNusQmar(AOZWrZHDPImhG5JR4qWoQnYhmubYGTnrrRoEG(PqFaTBo0rqcjKIJhOFk0hq7MdDe0ej7SYqCYx6RqEetSjkOqK5amFC1LaIgD21xdQjzBOkqsg6t5lR8mrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermHesHiZby(4Qlben6SRVgutY2qvGmyBt0a9UIdb7Ow0WHnQMhlisQ8iMyt0a9UkaCuNDTr(GHcmFCtKSZkdXjFPu5aY0duXgAsOdjbi1KSZAdXvM9A12cmXANgCquTWETxEK1YoyTSrTCG1METcWAzhS2N0FF1sJ1cyuBpJAhPBJrTxd71EnyTKSK1cIdUT51sYebD7ANabw7dwBdtfRLVAhipVAVNSwoeSJ1kA4WgN1YoyTxdF1E5rw7dp93xTTWaZRwGjcQkZyXbtFQezoaZhFsjPYiyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0duftnjlPgehCBDpd9LhPjrMdW8XvCiyh1g5dgQajzOpLpvoGm9avXutYsQbXb3w3ZqZgMO44b6NkaCuNDTr(GHjkezoaZhxfaoQZU2iFWqfijd95lOKOa4q9bjrcjuK5amFCva4Oo7AJ8bdvGKm0NYNkhqMEGQyQjzj1G4GBR7zOJ0GycjSvhpq)ubGJ6SRnYhmi2enqVR4qWoQfnCyJQ5XcIKVCmbI0a9U6sarJo76Rb1KSnubMpUjAGExfaoQZU2iFWqbMpUjAGExXHGDuBKpyOaZhVm71QTfyI1on4GOAFGxtTSrTpnOxRroNq6bQQ9v2R9YJSw4S2azW21YZAFWXW8AjzIWANabw7L1k45vl8QLg7zG1E5rQkZyXbtFQezoaZhFsjPYiyqi7NEAWbrMd7sfzoaZhxDjGOrND91GAs2gQcKKH(8fusuaCO(GKOjAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSKArdh240KiZby(4koeSJAJ8bdvGKm0NVqbkjkaouFqsKsS4GPRUeq0OZU(AqnjBdvOKOa4q9bjrIlZyXbtFQezoaZhFsjPYiyqi7NEAWbrMd7sfzoaZhxXHGDuBKpyOcKKH(8fusuaCO(GKOjkOOvhpq)uOpG2nh6iiHesXXd0pf6dODZHocAIKDwzio5l9vipIj2efuiYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSKAqCWT19m0xEKMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSK65XcIiMqcPqK5amFC1LaIgD21xdQjzBOkqsg6tPYZenqVR4qWoQfnCyJQ5XcIKkpIj2enqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCexMXIdM(ujYCaMp(KssLbWe1Wdjn3zsu6mbgd8oOBRda62Md7sPOvbGJ9mSr1eA0KUEEzqsiH0a9UAcnAsxpVmivageBIgO3vCiyh1IgoSr18ybrViLkhqMEGQlpsnjlPw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrjrbWH6dsIMizNvgIt(u5aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JxM9A12cmXAV8iR9bEn1Yg1c71cV3ZAFGxd0R9AWAjzjRfehCBvTVYETEEMxlWeR9bEn1gPrTWETxdw7Xd0VAHZApMi0nVw2bRfEVN1(aVgOx71G1sYswlio42QYmwCW0NkrMdW8XNusQmUeq0OZU(AqnjBdnh2LsrRcah7zyJQj0OjD98YGKqcPb6D1eA0KUEEzqQami2enqVR4qWoQfnCyJQ5XcIErkvoGm9avxEKAswsTOHdBCAsK5amFCfhc2rTr(GHkqsg6ZxKIsIcGd1hKenrYoRmeN8PYbKPhOIn0KqhscqQjzN1gIZenqVRcah1zxBKpyOaZhVmJfhm9PsK5amF8jLKkJlben6SRVgutY2qZHDP0a9UIdb7Ow0WHnQMhli6fPu5aY0duD5rQjzj1IgoSXPPJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lsrjrbWH6dsIMOYbKPhO6GKOgWp4qZgYNkhqMEGQlpsnjlPgehCBDpdnBuMXIdM(ujYCaMp(KssLXLaIgD21xdQjzBO5WUuAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSKArdh240efT64b6NkaCuNDTr(GbHekYCaMpUkaCuNDTr(GHkqsg6t5tLditpq1LhPMKLudIdUTUNHosdInrLditpq1bjrnGFWHMnKpvoGm9avxEKAswsnio426EgA2Om71QTfyI1Yg1c71E5rwlCwB61kaRLDWAFs)9vlnwlGrT9mQDKUng1EnSx71G1sYswlio42Mxljte0TRDceyTxdF1(G12WuXArpbSBQLKDUw2bR9A4R2RbdSw4SwpVA5rGmy7A5AdahRn71AKpyuly(4QYmwCW0NkrMdW8XNusQm4qWoQnYhmmh2LkYCaMpU6sarJo76Rb1KSnufijd9P8PYbKPhOIn0KSKAqCWT19m0xEKMOOvIKk6SFkQOFnTdcjuK5amFCfjmImM6SRVmir)ubsYqFkFQCaz6bQydnjlPgehCBDpdnzEeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliYenqVRcah1zxBKpyOaZh3ej7SYqCYxkvoGm9avSHMe6qsasnj7S2qCLzVwTTatS2inQf2R9YJSw4S20Rvawl7G1(K(7RwASwaJA7zu7iDBmQ9AyV2RbRLKLSwqCWTnVwsMiOBx7eiWAVgmWAHt)9vlpcKbBxlxBa4yTG5Jxl7G1En8vlBu7t6VVAPrrsI1Yuz4GPhyTGab0TRnaCuvMXIdM(ujYCaMp(KssLra4Oo7AJ8bdZHDP0a9UIdb7O2iFWqbMpUjkezoaZhxDjGOrND91GAs2gQcKKH(u(u5aY0dufPHMKLudIdUTUNH(YJKqcfzoaZhxXHGDuBKpyOcKKH(8fPu5aY0duD5rQjzj1G4GBR7zOzdInrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfezsK5amFCfhc2rTr(GHkqsg6t5lR8mjYCaMpU6sarJo76Rb1KSnufijd9P8LvELzS4GPpvImhG5JpPKuzmBG9d62AJ8bdZHDPu5aY0duLa3ecI6SRfzoaZhFwM9A12cmXAnsYAVS2zlcaXwqyTSxlk5fCTmDTqV2RbR1rjVAfzoaZhV2hOdMpMxlGpW5SwIAhq2R9AqV20hTRfeiGUDTCiyhR1iFWOwqaS2lRTjFQLKDU2ga3oAxBWGq2VANgCquTWzzgloy6tLiZby(4tkjvggborxG6SRjHoO5WU0JhOFQaWrD21g5dgMOb6Dfhc2rTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKLSmJfhm9PsK5amF8jLKkdJaNOlqD21Kqh0Cyxkisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFHfhmDfhc2rnjCoHdCQqjrbWH6dsIMALiPIo7NIO2bK9YmwCW0NkrMdW8XNusQmmcCIUa1zxtcDqZHDP0a9UkaCuNDTr(GHcWWenqVRcah1zxBKpyOcKKH(8fBbOIKL0KiZby(4kKAk4dMUkqgSTjrMdW8XvxciA0zxFnOMKTHQajzOpn1krsfD2pfrTdi7LzLzS4GPpvDOZdnnq4s5qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMlAyOlv2YmwCW0NQo05HMgiCkjvgCiyh10dEELzS4GPpvDOZdnnq4usQm4qWoQP5iyBSmRm71QvMSb9Ada3HUDTi8AWO2RbR1YQ2mQLaYK1oqB0b5aItZR9bR9H9R2lRvMGAwln2ZaR9AWAjqETuz0YVATpqhmFu12cmXAHxT8S2zMET8S2xF(Q12WZA7qhoBqWAtGO2h8nvS2Pb6xTjquROHdBCwMXIdM(u1HZgOBRtd0Xqksnf8bt3CyxkfbGJ9mSr1HKgzWd9dhgesifbGJ9mSr1eA0KUEEzqAQvu5aY0duzeObWyOrQPuzjMytuqd07QaWrD21g5dgkW8XjKqJaPQTfGkzvCiyh10CeSnsSjrMdW8XvbGJ6SRnYhmubsYqFwM9A1(k71(GVPI12HoC2GG1MarTImhG5Jx7d0bZNzTSdw70a9R2eiQv0WHnonVwJaMb8GTGWALjOM1MuXOwKkgTVgOBxloMyzgloy6tvhoBGUTonqhdkjvgi1uWhmDZHDPhpq)ubGJ6SRnYhmmjYCaMpUkaCuNDTr(GHkqsg6ttImhG5JR4qWoQnYhmubsYqFAIgO3vCiyh1g5dgkW8Xnrd07QaWrD21g5dgkW8XnzeivTTaujRIdb7OMMJGTXYmwCW0NQoC2aDBDAGogusQm6Wa10dEEMd7sdah7zyJkq4uangqNJ2ArssYoOjAGExbcNcOXa6C0wlsss2b19iNNcWOmJfhm9PQdNnq3wNgOJbLKkJEKZt7jv2CyxAa4ypdBuzhW5OTgkGIbAIKDwzio53IPSYmwCW0NQoC2aDBDAGogusQm4qWoQjHZjCGtZHDPbGJ9mSrfhc2rDdhKP32enqVR4qWoQB4Gm92Q5XcIEHgO3vCiyh1nCqMEBfjlPEESGituqbnqVR4qWoQnYhmuG5JBsK5amFCfhc2rTr(GHkqgSnXesiisd07Qlben6SRVgutY2qfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusQmcah1zxBKpyyoSlnaCSNHnQMqJM01ZldYYmwCW0NQoC2aDBDAGogusQm4qWoQZG2CyxQiZby(4QaWrD21g5dgQazW2LzS4GPpvD4Sb6260aDmOKuzWHGDutp45zoSlvK5amFCva4Oo7AJ8bdvGmyBt0a9UIdb7Ow0WHnQMhli6fAGExXHGDulA4WgvKSK65XcIkZyXbtFQ6Wzd0T1Pb6yqjPYae5RHodhnh2L2QaWXEg2O6qsJm4H(HddcjuKoia8u2W(PZU(Aq9akAkZyXbtFQ6Wzd0T1Pb6yqjPYiaCuNDTr(Grz2Rv7RSx7d(oWA5RwswYANhliAwB2RT1TUw2bR9bRTHPI(7RwGjcwBlnjqTTXZ8AbMyTCTZJfev7L1Aeiv0VAjbCrd0TRfWh4CwBa4o0TR9AWABbJdY0Bx7aTrhKJ2LzS4GPpvD4Sb6260aDmOKuzWHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62ksws98ybrMejv0z)uur)AAhMezoaZhxrcJiJPo76lds0pvGmyBtTIkhqMEGkK0iFWab10CeSnAsK5amFCfhc2rTr(GHkqgSDz2RvReZGKhJ21(G1AWWOwJ8GPxlWeR9bEn12YVQ51sdC1cVAFGJrTdEE1os3Uw0ta7MA7zulDEn1EnyTV(8vRLDWAB5xT2hOdMpZAb8boN1gaUdD7AVgSwlRAZOwcitw7aTrhKdiolZyXbtFQ6Wzd0T1Pb6yqjPYWipy6Md7sBva4ypdBuDiPrg8q)WHHjkAva4ypdBunHgnPRNxgKesifu5aY0duzeObWyOrQPuznrd07koeSJArdh2OAESGiP0a9UIdb7Ow0WHnQizj1ZJfermXLzS4GPpvD4Sb6260aDmOKuzaI81qNHJMd7sPb6Dva4Oo7AJ8bdfy(4esOrGu12cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPYiyqi7NEAWbrMd7sPb6Dva4Oo7AJ8bdfy(4esOrGu12cqLSkoeSJAAoc2glZyXbtFQ6Wzd0T1Pb6yqjPYGegrgtD21xgKOFMd7sPb6Dva4Oo7AJ8bdvGKm0NVqHmLsYPLeao2ZWgvtOrt665LbjXLzVwTYKnOxBa4o0TR9AWABbJdY0Bx7aTrhKJ2MxlWeRTLF1APXEgyTeiVwATxwliaPrTCTDGXODTZJfeHG1sZrW2yzgloy6tvhoBGUTonqhdkjvgCiyh1g5dgMd7sPYbKPhOcjnYhmqqnnhbBJMOb6Dva4Oo7AJ8bdfGHjkizNvgI7fkKdLrjkKvETersfD2pfrTdi7etmHesd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62ksws98ybrexMXIdM(u1HZgOBRtd0XGssLbhc2rnnhbBJMd7sPYbKPhOcjnYhmqqnnhbBJMOb6Dfhc2rTOHdBunpwqKuAGExXHGDulA4WgvKSK65XcImrd07koeSJAJ8bdfGrzgloy6tvhoBGUTonqhdkjvgatudpK0CNjrPZeymW7GUToaOBBoSlLgO3vbGJ6SRnYhmuG5JtiHgbsvBlavYQ4qWoQP5iyBKqcncKQ2waQKvfmiK9tpn4GicjKcJaPQTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKuzCjGOrND91GAs2gAoSlLgO3vbGJ6SRnYhmuG5JtiHgbsvBlavYQ4qWoQP5iyBKqcncKQ2waQKvfmiK9tpn4GicjKcJaPQTfGkzvGiFn0z4OPwfao2ZWgvtOrt665LbjXLzS4GPpvD4Sb6260aDmOKuzWHGDuBKpyyoSl1iqQABbOsw1LaIgD21xdQjzByz2RvBlWeR9vZwATxw7SfbGyliSw2RfL8cU2woeSJ1kHbpVAbbcOBx71G1sG8APYOLF1AFGoy(ulGpW5S2aWDOBxBlhc2XALjenPQ2xzV2woeSJ1ktiAYAHZApEG(HGMx7dwRG93xTatS2xnBP1(aVgOx71G1sG8APYOLF1AFGoy(ulGpW5S2hSwOFyeagxTxdwBl3sRv0WUJdZRDM1(GVhJANmvSw4PkZyXbtFQ6Wzd0T1Pb6yqjPYWiWj6cuNDnj0bnh2L2QJhOFkoeSJAu0KMarAGExDjGOrND91GAs2gQammbI0a9U6sarJo76Rb1KSnufijd95lsPGfhmDfhc2rn9GNNcLefahQpij2sOb6DLrGt0fOo7AsOdQizj1ZJferCz2Rv7RSx7RMT0AB4P)(QLgrVwGjcwliqaD7AVgSwcKxlT2hOdMpMx7d(EmQfyI1cVAVS2zlcaXwqyTSxlk5fCTTCiyhRvcdEE1c9AVgS2xF(QYOLF1AFGoy(OkZyXbtFQ6Wzd0T1Pb6yqjPYWiWj6cuNDnj0bnh2Lsd07koeSJAJ8bdfGHjAGExfaoQZU2iFWqfijd95lsPGfhmDfhc2rn9GNNcLefahQpij2sOb6DLrGt0fOo7AsOdQizj1ZJferCzgloy6tvhoBGUTonqhdkjvgCiyh10dEEMd7sbZtfmiK9tpn4GivGKm0NYNYiKqqKgO3vbdcz)0tdoistfy4yW0Wb8ARMhlis(YRm71QvMeR9H9R2lRLKjcRDceyTpyTnmvSw0ta7MAjzNRTNrTxdwl6hmWAB5xT2hOdMpMxlsf9AH9AVgmW3ZANhCmQ9GKyTbsYqh621METV(8vv1(kV3ZAtF0UwA8omQ9YAPbcV2lRTfegzTSdwRmb1SwyV2aWDOBx71G1AzvBg1sazYAhOn6GCaXPQmJfhm9PQdNnq3wNgOJbLKkdoeSJAAoc2gnh2LkYCaMpUIdb7O2iFWqfid22ej7SYqCVqHmtEuIczLxlrKurN9tru7aYoXeBIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliYefTkaCSNHnQMqJM01ZldscjKkhqMEGkJanagdnsnLklXMAva4ypdBuDiPrg8q)WHHPwfao2ZWgvCiyh1nCqME7YSxRwjWrW2yTZMeyawRNxT0yTateSw(Q9AWArhS2SxBl)Q1c71ktqnf8btVw4S2azW21YZAbJ0Wa621kA4WgN1(ahJAjzIWAHxThtew7iDBmQ9YAPbcV2Rjsa7MAdKKHo0TRLKDUmJfhm9PQdNnq3wNgOJbLKkdoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqtImhG5JRqQPGpy6QajzOplZETALahbBJ1oBsGbyT84HBpRLgR9AWAh88QvWZRwOx71G1(6ZxT2hOdMp1YZAjqET0AFGJrTboVmWAVgSwrdh24S2Pb6xzgloy6tvhoBGUTonqhdkjvgCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlan1QaWXEg2OIdb7OUHdY0BxMXIdM(u1HZgOBRtd0XGssLbhc2rnjCoHdCAoSlfePb6D1LaIgD21xdQjzBOcWW0Xd0pfhc2rnkAstuqd07kqKVg6mCubMpoHeYIdsf1OJKqCkvwInbI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkusuaCO(GKO5Igg6sL1CKJrBTOHHUg2Lsd07kXa5qWZd62Ard7oouG5JBIcAGExXHGDuBKpyOamiKqkA1Xd0pvsfdJ8bde0ef0a9UkaCuNDTr(GHcWGqcfzoaZhxHutbFW0vbYGTjMyIlZETAFL9AFW3bwlv0VM2H51cjjrqiF4ODTatS2w36AFAqVwbByGG1EzTEE1(WZdR1isXS2EKK12stcuMXIdM(u1HZgOBRtd0XGssLbhc2rnjCoHdCAoSlvKurN9trf9RPDyIgO3vIbYHGNh0TvZJfejLgO3vIbYHGNh0TvKSK65XcIkZETATooUAbMq3U2w36AB5wATpnOxBl)Q12WZAPr0RfyIGLzS4GPpvD4Sb6260aDmOKuzWHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQoC2aDBDAGogusQm4qWoQZG2CyxknqVR4qWoQfnCyJQ5XcIErkvoGm9avxEKAswsTOHdBCwMXIdM(u1HZgOBRtd0XGssLbhc2rn9GNN5WUuAGExfaoQZU2iFWqbyqiHKSZkdXjFzPSYmwCW0NQoC2aDBDAGogusQmqQPGpy6Md7sPb6Dva4Oo7AJ8bdfy(4MOb6Dfhc2rTr(GHcmFCZH(HrayCAyxkj7SYqCYxQmNYmh6hgbGXPHKKiiKpuQSLzS4GPpvD4Sb6260aDmOKuzWHGDutZrW2yzwz2R9A12c4tadJmoeSwb7cCOzXbtVf8QvMGAk4dMETpWXOwASwNpGGhJ21shjrOxlSxRiDq4btFwlhyTK4PkZETxRwwCW0NQgoitVTub7cCOzXbt3Cyxkloy6kKAk4dMUs0WUJdOBBIKDwzio5lTftzLzVwTVYETJ8P20RLKDUw2bRvK5amF8zTCG1kssOBxlGH51AN1Ynidwl7G1IuZYmwCW0NQgoitVnLKkdKAk4dMU5WUus2zLH4Erkbjptu5aY0duLa3ecI6SRfzoaZhFAIIJhOFQaWrD21g5dgMezoaZhxfaoQZU2iFWqfijd95lYkpIlZETALjXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYktRDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPYGdb7OMeoNWbonh2LsbvoGm9avZJfePB4Gm92es4bjXxKvEeBIgO3vCiyh1nCqMEB18ybrViRm1CrddDPYwM9A1kt2GETatOBxRmbPr7a5rTVobOZUanVwbpVA5A74tTOKxW1scNt4aN1(0ahyTpm8GUDT9mQ9AWAPb69A5R2RbRDECC1M9AVgS2o0U5kZyXbtFQA4Gm92usQm4qWoQjHZjCGtZHDPylcaAyGGkK0ODG8qNbOZUanDqs8fcsEMU02EGkrMdW8XNMezoaZhxHKgTdKh6maD2fOkqsg6t5lRmvMBQvS4GPRqsJ2bYdDgGo7cubcNm9ablZyXbtFQA4Gm92usQmaMOgEiP5otIsNjWyG3bDBDaq32CyxkvoGm9aviPr(GbcQP5iyB0KiZby(4Qlben6SRVgutY2qvGKm0NVifLefahQpijAsK5amFCfhc2rTr(GHkqsg6ZxKsbkjkaouFqsSLihIlZyXbtFQA4Gm92usQmcgeY(PNgCqK5WUuQCaz6bQqsJ8bdeutZrW2OjrMdW8XvxciA0zxFnOMKTHQajzOpFrkkjkaouFqs0KiZby(4koeSJAJ8bdvGKm0NViLcusuaCO(GKylroeBIIwHTiaOHbcQMjWyG3bDBDaq3MqcfPdcapfhc2rTrKGq72QGDIKVukJqcVa6eHNAMaJbEh0T1baDBLiZby(4QajzOpLVSYkpIlZyXbtFQA4Gm92usQmUeq0OZU(AqnjBdnh2LsLditpqvlmW80ateupn4GitImhG5JR4qWoQnYhmubsYqF(IuusuaCO(GKOjkAf2IaGggiOAMaJbEh0T1baDBcjuKoia8uCiyh1grccTBRc2js(sPmcj8cOteEQzcmg4Dq3wha0TvImhG5JRcKKH(u(YkR8iUmJfhm9PQHdY0BtjPYGdb7O2iFWWCyxQrGu12cqLSQlben6SRVgutY2WYmwCW0NQgoitVnLKkJaWrD21g5dgMd7sPYbKPhOcjnYhmqqnnhbBJMezoaZhxfmiK9tpn4GivGKm0NVifLefahQpijAIkhqMEGQdsIAa)GdnBiFPYrEMOOvI0bbGNIdb7O2isqODBcjSvu5aY0duXJhU9upB7cTiZby(4tcjuK5amFC1LaIgD21xdQjzBOkqsg6ZxKsbkjkaouFqsSLihIjUmJfhm9PQHdY0BtjPYiyqi7NEAWbrMd7sPYbKPhOcjnYhmqqnnhbBJMmcKQ2waQKvfaoQZU2iFWOmJfhm9PQHdY0BtjPY4sarJo76Rb1KSn0CyxkvoGm9avTWaZtdmrq90GdIm1kQCaz6bQAYbi0T1xEKLzVwTTatSw54G1YHGDSwAoc2gRf612YVkLE9VoVATPpAxlSxRegzcoaMxTSdwlF1oqEE1kNABDRN1AePqGGLzS4GPpvnCqMEBkjvgCiyh10CeSnAoSlLgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliYenqVRcah1zxBKpyOammrd07koeSJAJ8bdfGHjAGExXHGDu3Wbz6TvZJfejFPYktnrd07koeSJAJ8bdvGKm0NViLfhmDfhc2rnnhbBJkusuaCO(GKOjAGExrpYeCampfGrz2RvBlWeRvooyTV(8vRf612YVATPpAxlSxRegzcoaMxTSdwRCQT1TEwRrKIYmwCW0NQgoitVnLKkJaWrD21g5dgMd7sPb6Dva4Oo7AJ8bdfy(4MOb6Df9itWbW8uagMOGkhqMEGQdsIAa)GdnBiFcsEesOiZby(4QGbHSF6PbhePcKKH(u(YkhInrbnqVR4qWoQB4Gm92Q5XcIKVuzPmcjKgO3vIbYHGNh0TvZJfejFPYsSjkALiDqa4P4qWoQnIeeA3MqcBfvoGm9av84HBp1Z2UqlYCaMp(K4YmwCW0NQgoitVnLKkJaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmFCtuqLditpq1bjrnGFWHMnKpbjpcjuK5amFCvWGq2p90GdIubsYqFkFzLdXMOOvI0bbGNIdb7O2isqODBcjSvu5aY0duXJhU9upB7cTiZby(4tIlZyXbtFQA4Gm92usQmcgeY(PNgCqK5WUuQCaz6bQqsJ8bdeutZrW2OjkOb6Dfhc2rTOHdBunpwqK8LkhcjuK5amFCfhc2rDg0QazW2eBIIwD8a9tfaoQZU2iFWGqcfzoaZhxfaoQZU2iFWqfijd9P8PmInrLditpqfopijFiOMn0ImhG5JlFPeK8mrrRePdcapfhc2rTrKGq72esyROYbKPhOIhpC7PE22fArMdW8XNexM9A1kt2GETbG7q3UwJibH2TnVwGjw7LhzT0TRfEtC0Rf61Mbig1EzT8aA71cVAFGxtTSrzgloy6tvdhKP3MssLXLaIgD21xdQjzBO5WUuQCaz6bQoijQb8do0SXluM8mrLditpq1bjrnGFWHMnKpbjptu0kSfbanmqq1mbgd8oOBRda62esOiDqa4P4qWoQnIeeA3wfStK8LszexMXIdM(u1Wbz6TPKuzWHGDuNbT5WUuQCaz6bQAHbMNgyIG6PbhezIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLuppwquzgloy6tvdhKP3MssLbhc2rnnhbBJMd7sbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKMkWWXGPHd41wrYsQNhliQmJfhm9PQHdY0BtjPYGdb7OMEWZZCyxkvoGm9avTWaZtdmrq90GdIiKqkarAGExfmiK9tpn4GinvGHJbtdhWRTcWWeisd07QGbHSF6PbhePPcmCmyA4aETvZJfe9cisd07QGbHSF6PbhePPcmCmyA4aETvKSK65XcIiUm71QTfyI1scDyTsGJGTXAPX7brV2GbHSF1on4GOzTWETaoig1kbcU2h41KaxTG4GBdD7AF9miK9RwldoiQwiiYJr7YmwCW0NQgoitVnLKkdoeSJAAoc2gnh2Lsd07QaWrD21g5dgkadt0a9UIdb7O2iFWqbMpUjAGExrpYeCampfGHjrMdW8Xvbdcz)0tdoisfijd95lsLvEMOb6Dfhc2rDdhKP3wnpwqK8LkRmTm71QTfyI1MbDTPxRaSwaFGZzTSrTWzTIKe621cyu7mtVmJfhm9PQHdY0BtjPYGdb7OodAZHDP0a9UIdb7Ow0WHnQMhli6fcYevoGm9avhKe1a(bhA2q(YkptuiYCaMpU6sarJo76Rb1KSnufijd9P8PmcjSvI0bbGNIdb7O2isqODBIlZyXbtFQA4Gm92usQm4qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6Dfhc2rTr(GHcWWCrddDPYwM9A1(k71(G1AJxTg5dg1c9oWeMETGab0TRDamVAFW3JrTnmvSw0ta7MAB45H1EzT24vB271Y1oViD7AP5iyBSwqGa621EnyTrAid2O2hOdMpLzS4GPpvnCqMEBkjvgCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dva4Oo7AJ8bdvGKm0NViLfhmDfhc2rnjCoHdCQqjrbWH6dsIMOb6Dfhc2rTr(GHcWWenqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLuppwqKjAGExXHGDu3Wbz6TvZJfezIgO3vg5dgAO3bMW0vagMOb6Df9itWbW8uagLzVwTVYETpyT24vRr(GrTqVdmHPxliqaD7AhaZR2h89yuBdtfRf9eWUP2gEEyTxwRnE1M9ETCTZls3UwAoc2gRfeiGUDTxdwBKgYGnQ9b6G5J51oZAFW3JrTPpAxlWeRf9eWUPw6bpVzTqhEqEmAx7L1AJxTxwBpbIAfnCyJZYmwCW0NQgoitVnLKkdoeSJA6bppZHDP0a9UYiWj6cuNDnj0bvagMOGgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLuppwqeHe2kkOb6DLr(GHg6DGjmDfGHjAGExrpYeCampfGbXexM9A1sGgSwACE1cmXAZETgjzTWzTxwlWeRfE1EzTTiaOGOr7APbGdWAfnCyJZAbbcOBxlBul3pmQ9AW21AJxTGaKgiyT0TR9AWAB4Gm921sZrW2yzgloy6tvdhKP3MssLHrGt0fOo7AsOdAoSlLgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLuppwqKjAGExXHGDuBKpyOamkZETALjXAFy)Q9YANhliQ2goitVDTDGXOTQwc0G1cmXAZETYktRDESGOzTnyG1cN1EzTSqKa(vBpJAVgS2dkiQ2b2VAtV2RbRv0WUJJAzhS2RbRLeoNWbwl0RTpG2nNQmJfhm9PQHdY0BtjPYGdb7OMeoNWbonh2Lsd07koeSJ6goitVTAESGOxKvMAUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwMXIdM(u1Wbz6TPKuzWHGDutZrW2O5WUuAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlPEESGitu5aY0duHKg5dgiOMMJGTXYmwCW0NQgoitVnLKkdKAk4dMU5WUus2zLH4ErwkRm71Q91XhTRfyI1sp45v7L1sdahG1kA4WgN1c71(G1YJazW212WuXANjjwBpsYAZGUmJfhm9PQHdY0BtjPYGdb7OMEWZZCyxknqVR4qWoQfnCyJQ5XcImrd07koeSJArdh2OAESGOxOb6Dfhc2rTOHdBurYsQNhliQm71Q91vWXO2h41ultwlGpW5Sw2Ow4SwrscD7AbmQLDWAFW3bw7iFQn9AjzNlZyXbtFQA4Gm92usQm4qWoQjHZjCGtZHDPTIcQCaz6bQoijQb8do0SXlsLvEMizNvgI7fcsEeBUOHHUuznh6hgbGXjvwZH(HrayCA7rsZdPYwM9A1(Qr2HdCw7d8AQDKp1sYZdJ2MxBd0UP2gEEO51MrT051ulj3UwpVAByQyTONa2n1sYox7L1obmmY4QTjFQLKDUwOFOpHuXAdgeY(v70GdIQvWET0O51oZAFW3JrTatS2omWAPh88QLDWA7rop6CC1(0GETJ8P20RLKDUmJfhm9PQHdY0BtjPYOddutp45vMXIdM(u1Wbz6TPKuz0JCE054kZkZyXbtFQsd0XqAhgOMEWZZCyxAa4ypdBubcNcOXa6C0wlsss2bnrd07kq4uangqNJ2ArssYoOUh58uagLzS4GPpvPb6yqjPYOh580EsLnh2Lgao2ZWgv2bCoARHcOyGMizNvgIt(TykRmJfhm9PknqhdkjvgatudpK0CNjrPZeymW7GUToaOBxMXIdM(uLgOJbLKkdqKVg6mCSmJfhm9Pknqhdkjvgbdcz)0tdoiYCyxkj7SYqCYxMjVYmwCW0NQ0aDmOKuzqcJiJPo76lds0VYmwCW0NQ0aDmOKuzmBG9d62AJ8bdZHDP0a9UIdb7O2iFWqbMpUjrMdW8XvCiyh1g5dgQajzOplZyXbtFQsd0XGssLbhc2rDg0Md7sfzoaZhxXHGDuBKpyOcKbBBIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLuppwquzgloy6tvAGogusQm4qWoQPh88mh2LksQOZ(POI(10omjYCaMpUIegrgtD21xgKOFQajzOpLVmxMvMXIdM(uLgOJbLKkJlben6SRVgutY2WYmwCW0NQ0aDmOKuzWHGDuBKpyuMXIdM(uLgOJbLKkJaWrD21g5dgMd7sPb6Dfhc2rTr(GHcmF8YSxR2wGjw7RMT0AVS2zlcaXwqyTSxlk5fCTTCiyhRvcdEE1cceq3U2RbRLa51sLrl)Q1(aDW8PwaFGZzTbG7q3U2woeSJ1ktiAsvTVYETTCiyhRvMq0K1cN1E8a9dbnV2hSwb7VVAbMyTVA2sR9bEnqV2RbRLa51sLrl)Q1(aDW8PwaFGZzTpyTq)WiamUAVgS2wULwROHDhhMx7mR9bFpg1ozQyTWtvMXIdM(uLgOJbLKkdJaNOlqD21Kqh0CyxARoEG(P4qWoQrrtAcePb6D1LaIgD21xdQjzBOcWWeisd07Qlben6SRVgutY2qvGKm0NViLcwCW0vCiyh10dEEkusuaCO(GKylHgO3vgborxG6SRjHoOIKLuppwqeXLzVwTVYETVA2sRTHN(7RwAe9AbMiyTGab0TR9AWAjqET0AFGoy(yETp47XOwGjwl8Q9YANTiaeBbH1YETOKxW12YHGDSwjm45vl0R9AWAF95RkJw(vR9b6G5JQmJfhm9PknqhdkjvggborxG6SRjHoO5WUuAGExXHGDuBKpyOammrd07QaWrD21g5dgQajzOpFrkfS4GPR4qWoQPh88uOKOa4q9bjXwcnqVRmcCIUa1zxtcDqfjlPEESGiIlZyXbtFQsd0XGssLbhc2rn9GNN5WUuW8ubdcz)0tdoisfijd9P8PmcjeePb6DvWGq2p90GdI0ubgogmnCaV2Q5XcIKV8kZETAB5Xd3EwRe4iyBSw(Q9AWArhS2SxBl)Q1(0GETbG7q3U2RbRTLdb7yTTGXbz6TRDG2OdYr7YmwCW0NQ0aDmOKuzWHGDutZrW2O5WUuAGExXHGDuBKpyOammrd07koeSJAJ8bdvGKm0NVylanfao2ZWgvCiyh1nCqME7YSxR2wE8WTN1kboc2gRLVAVgSw0bRn71EnyTV(8vR9b6G5tTpnOxBa4o0TR9AWAB5qWowBlyCqME7AhOn6GC0UmJfhm9PknqhdkjvgCiyh10CeSnAoSlLgO3vbGJ6SRnYhmuagMOb6Dfhc2rTr(GHcmFCt0a9UkaCuNDTr(GHkqsg6ZxKAlanfao2ZWgvCiyh1nCqME7YmwCW0NQ0aDmOKuzWHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gurn6ijeNsLLytGinqVRUeq0OZU(AqnjBdvbsYqFkFwCW0vCiyh1KW5eoWPcLefahQpijAUOHHUuznh5y0wlAyORHDP0a9Usmqoe88GUTw0WUJdfy(4MOGgO3vCiyh1g5dgkadcjKIwD8a9tLuXWiFWabnrbnqVRcah1zxBKpyOamiKqrMdW8Xvi1uWhmDvGmyBIjM4YmwCW0NQ0aDmOKuzWHGDutcNt4aNMd7sPb6DLyGCi45bDB18ybrsPb6DLyGCi45bDBfjlPEESGitIKk6SFkQOFnTJYmwCW0NQ0aDmOKuzWHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mjYCaMpUIdb7O2iFWqfijd9PjkOb6Dva4Oo7AJ8bdfGbHesd07koeSJAJ8bdfGbXMlAyOlv2YmwCW0NQ0aDmOKuzWHGDuNbT5WUuAGExXHGDulA4WgvZJfe9IuQCaz6bQU8i1KSKArdh24SmJfhm9PknqhdkjvgCiyh10dEEMd7sPb6Dva4Oo7AJ8bdfGbHesYoRmeN8LLYkZyXbtFQsd0XGssLbsnf8bt3CyxknqVRcah1zxBKpyOaZh3enqVR4qWoQnYhmuG5JBo0pmcaJtd7sjzNvgIt(sL5uM5q)WiamonKKebH8HsLTmJfhm9PknqhdkjvgCiyh10CeSnwMvM9AVwTS4GPpvrE8btxQGDbo0S4GPBoSlLfhmDfsnf8btxjAy3Xb0TnrYoRmeN8L2IPmtu0QaWXEg2OAcnAsxpVmijKqAGExnHgnPRNxgKQ5XcIKsd07Qj0OjD98YGurYsQNhliI4YSxR2wGjwlsnRf2R9bFhyTJ8P20RLKDUw2bRvK5amF8zTCG1Y0jWv7L1sJ1cyuMXIdM(uf5XhmDkjvgi1uWhmDZHDPTkaCSNHnQMqJM01ZldstKSZkdX9IuQCaz6bQqQP2qCMOqK5amFC1LaIgD21xdQjzBOkqsg6ZxKYIdMUcPMc(GPRqjrbWH6dsIesOiZby(4koeSJAJ8bdvGKm0NViLfhmDfsnf8btxHsIcGd1hKejKqkoEG(Pcah1zxBKpyysK5amFCva4Oo7AJ8bdvGKm0NViLfhmDfsnf8btxHsIcGd1hKejMyt0a9UkaCuNDTr(GHcmFCt0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8Xn1kJaPQTfGkzvxciA0zxFnOMKTHLzS4GPpvrE8btNssLbsnf8bt3CyxAa4ypdBunHgnPRNxgKMALiPIo7NIk6xt7WKiZby(4koeSJAJ8bdvGKm0NViLfhmDfsnf8btxHsIcGd1hKelZyXbtFQI84dMoLKkdKAk4dMU5WU0aWXEg2OAcnAsxpVminjsQOZ(POI(10omjYCaMpUIegrgtD21xgKOFQajzOpFrkloy6kKAk4dMUcLefahQpijAsK5amFC1LaIgD21xdQjzBOkqsg6ZxKsbvoGm9avK5PncuGiO(YJut3MsS4GPRqQPGpy6kusuaCO(GKiLiiInjYCaMpUIdb7O2iFWqfijd95lsPGkhqMEGkY80gbkqeuF5rQPBtjwCW0vi1uWhmDfkjkaouFqsKseeXLzVwTsGJGTXAH9AH37zThKeR9YAbMyTxEK1YoyTpyTnmvS2lZAjzVDTIgoSXzzgloy6tvKhFW0PKuzWHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYNkhqMEGQlpsnjlPw0WHnonjYCaMpUIdb7O2iFWqfijd95lsrjrbWH6dsIMizNvgIt(u5aY0duXgAsOdjbi1KSZAdXzIgO3vbGJ6SRnYhmuG5JtCzgloy6tvKhFW0PKuzWHGDutZrW2O5WUurMdW8XvxciA0zxFnOMKTHQazW2MOGgO3vCiyh1IgoSr18ybrYNkhqMEGQlpsnjlPw0WHnonD8a9tfaoQZU2iFWWKiZby(4QaWrD21g5dgQajzOpFrkkjkaouFqs0evoGm9avhKe1a(bhA2q(u5aY0duD5rQjzj1G4GBR7zOzdIlZyXbtFQI84dMoLKkdoeSJAAoc2gnh2LkYCaMpU6sarJo76Rb1KSnufid22ef0a9UIdb7Ow0WHnQMhlis(u5aY0duD5rQjzj1IgoSXPjkA1Xd0pva4Oo7AJ8bdcjuK5amFCva4Oo7AJ8bdvGKm0NYNkhqMEGQlpsnjlPgehCBDpdDKgeBIkhqMEGQdsIAa)GdnBiFQCaz6bQU8i1KSKAqCWT19m0SbXLzS4GPpvrE8btNssLbhc2rnnhbBJMd7sbrAGExfmiK9tpn4GinvGHJbtdhWRTAESGiPGinqVRcgeY(PNgCqKMkWWXGPHd41wrYsQNhliYef0a9UIdb7O2iFWqbMpoHesd07koeSJAJ8bdvGKm0NVi1wasSjkOb6Dva4Oo7AJ8bdfy(4esinqVRcah1zxBKpyOcKKH(8fP2cqIlZyXbtFQI84dMoLKkdoeSJA6bppZHDPu5aY0du1cdmpnWeb1tdoiIqcPaePb6DvWGq2p90GdI0ubgogmnCaV2kadtGinqVRcgeY(PNgCqKMkWWXGPHd41wnpwq0lGinqVRcgeY(PNgCqKMkWWXGPHd41wrYsQNhliI4YmwCW0NQip(GPtjPYGdb7OMEWZZCyxknqVRmcCIUa1zxtcDqfGHjqKgO3vxciA0zxFnOMKTHkadtGinqVRUeq0OZU(AqnjBdvbsYqF(IuwCW0vCiyh10dEEkusuaCO(GKyzgloy6tvKhFW0PKuzWHGDutcNt4aNMd7sbrAGExDjGOrND91GAs2gQammD8a9tXHGDuJIM0ef0a9Uce5RHodhvG5JtiHS4Gurn6ijeNsLLytuaI0a9U6sarJo76Rb1KSnufijd9P8zXbtxXHGDutcNt4aNkusuaCO(GKiHekYCaMpUYiWj6cuNDnj0bvbsYqFsiHIKk6SFkIAhq2j2CrddDPYAoYXOTw0Wqxd7sPb6DLyGCi45bDBTOHDhhkW8XnrbnqVR4qWoQnYhmuagesifT64b6NkPIHr(GbcAIcAGExfaoQZU2iFWqbyqiHImhG5JRqQPGpy6QazW2etmXLzVwTTo9jajw71G1IsAWoicwRrEOFqEulnqVxlpzJAVSwpVAh5eR1ip0pipQ1isXSmJfhm9PkYJpy6usQm4qWoQjHZjCGtZHDP0a9Usmqoe88GUTkqwCMOb6DfkPb7GiO2ip0pipuagLzS4GPpvrE8btNssLbhc2rnjCoHdCAoSlLgO3vIbYHGNh0TvbYIZef0a9UIdb7O2iFWqbyqiH0a9UkaCuNDTr(GHcWGqcbrAGExDjGOrND91GAs2gQcKKH(u(S4GPR4qWoQjHZjCGtfkjkaouFqsKyZfnm0LkBzgloy6tvKhFW0PKuzWHGDutcNt4aNMd7sPb6DLyGCi45bDBvGS4mrd07kXa5qWZd62Q5XcIKsd07kXa5qWZd62ksws98ybrMlAyOlv2YSxR2wE8WTN1Er7AVSwA2jQ2w36A7zuRiZby(41(aDW8zwlnWvliaPrTxdswlSx71GTFhyTmDcC1EzTOKgWalZyXbtFQI84dMoLKkdoeSJAs4Cch40CyxknqVRedKdbppOBRcKfNjAGExjgihcEEq3wfijd95lsPGcAGExjgihcEEq3wnpwqulHfhmDfhc2rnjCoHdCQqjrbWH6dsIetjBbOIKLKyZfnm0LkBzgloy6tvKhFW0PKuz441GH(qsdCEMd7sPiWEGZgMEGesyRoOGiOBtSjAGExXHGDulA4WgvZJfejLgO3vCiyh1IgoSrfjlPEESGit0a9UIdb7O2iFWqbMpUjqKgO3vxciA0zxFnOMKTHkW8XlZyXbtFQI84dMoLKkdoeSJ6mOnh2Lsd07koeSJArdh2OAESGOxKsLditpq1LhPMKLulA4WgNLzS4GPpvrE8btNssLXeWadpPYMd7sPYbKPhOkbUjee1zxlYCaMp(0ej7SYqCViTftzLzS4GPpvrE8btNssLbhc2rn9GNN5WUuAGExfaduND91eiovagMOb6Dfhc2rTOHdBunpwqK8jOYSxR2xxainQv0WHnoRf2R9bRTZJrT04iFQ9AWAfPpXGkwlj7CTxtGZMCawl7G1IutbFW0RfoRDEWXO20RvK5amF8YmwCW0NQip(GPtjPYGdb7OMMJGTrZHDPTkaCSNHnQMqJM01Zldstu5aY0duLa3ecI6SRfzoaZhFAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliY0Xd0pfhc2rDg0MezoaZhxXHGDuNbTkqsg6ZxKAlanrYoRme3lsBXYZKiZby(4kKAk4dMUkqsg6ZYmwCW0NQip(GPtjPYGdb7OMMJGTrZHDPbGJ9mSr1eA0KUEEzqAIkhqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJksws98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAlwEMezoaZhxHutbFW0vbsYqF(cbjVYSxR2xxainQv0WHnoRf2Rnd6AHZAdKbBxMXIdM(uf5XhmDkjvgCiyh10CeSnAoSlLkhqMEGQe4MqquNDTiZby(4tt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJksws98ybrMoEG(P4qWoQZG2KiZby(4koeSJ6mOvbsYqF(IuBbOjs2zLH4ErAlwEMezoaZhxHutbFW0vbsYqFAIIwfao2ZWgvtOrt665LbjHesd07Qj0OjD98YGufijd95lsLvMtCz2RvBlhc2XALahbBJ1oBsGbyT2OJbpgTRLgR9AWAh88QvWZR2Sx71G12YVATpqhmFkZyXbtFQI84dMoLKkdoeSJAAoc2gnh2Lsd07koeSJAJ8bdfGHjAGExXHGDuBKpyOcKKH(8fP2cqt0a9UIdb7Ow0WHnQMhlisknqVR4qWoQfnCyJksws98ybrMOqK5amFCfsnf8btxfijd9jHegao2ZWgvCiyh1nCqMEBIlZETAB5qWowRe4iyBS2ztcmaR1gDm4XODT0yTxdw7GNxTcEE1M9AVgS2xF(Q1(aDW8PmJfhm9PkYJpy6usQm4qWoQP5iyB0CyxknqVRcah1zxBKpyOammrd07koeSJAJ8bdfy(4MOb6Dva4Oo7AJ8bdvGKm0NVi1waAIgO3vCiyh1IgoSr18ybrsPb6Dfhc2rTOHdBurYsQNhliYefImhG5JRqQPGpy6QajzOpjKWaWXEg2OIdb7OUHdY0BtCz2RvBlhc2XALahbBJ1oBsGbyT0yTxdw7GNxTcEE1M9AVgSwcKxlT2hOdMp1c71cVAHZA98QfyIG1(aVMAF95RwBg12YVAzgloy6tvKhFW0PKuzWHGDutZrW2O5WUuAGExXHGDuBKpyOaZh3enqVRcah1zxBKpyOaZh3eisd07Qlben6SRVgutY2qfGHjqKgO3vxciA0zxFnOMKTHQajzOpFrQTa0enqVR4qWoQfnCyJQ5XcIKsd07koeSJArdh2OIKLuppwquz2RvRmzd61EnyThh24vlCwl0RfLefahwBWUnwl7G1EnyG1cN1sMbw71WETPJ1Ios228AbMyT0CeSnwlpRDMPxlpRTDcuBdtfRf9eWUPwrdh24S2lRTbE1YJrTOJKqCwlSx71G12YHGDSwjKK0CasI(v7aTrhKJ21cN1ITiaOHbcwMXIdM(uf5XhmDkjvgCiyh10CeSnAoSlLkhqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrYxkfS4Gurn6ijeNTqYsSjwCqQOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKkdoeSJAusJroHPBoSlLkhqMEGkK0iFWab10CeSnAIgO3vCiyh1IgoSr18ybrVqd07koeSJArdh2OIKLuppwqKjwCqQOgDKeIt5lRjAGExbI81qNHJkW8XlZyXbtFQI84dMoLKkdoeSJA6bpVYmwCW0NQip(GPtjPYaPMc(GPBoSlLkhqMEGQe4MqquNDTiZby(4ZYmwCW0NQip(GPtjPYGdb7OMMJGTXVfdCnz8TSGKad(GP36G73)(3)da]] )

    
end