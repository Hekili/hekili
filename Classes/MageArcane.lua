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
        dampened_magic = 3523, -- 236788
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
                if not legendary.disciplinary_command.enabled then return end

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
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
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
        if active_enemies > 2 or variable.prepull_evo == 1 or settings.am_spam then return 1 end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then return 1 end
        -- TODO:  Review this to make sure it holds up in longer fights.
        if state.combat > 0 and buff.arcane_power.down and cooldown.arcane_power.remains > 0 and runeforge.siphon_storm.enabled then return 1 end
        return 0
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
                if arcane_charges.current < arcane_charges.max then gain( 1, "arcane_charges" ) end
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
                else removeStack( "clearcasting" ) end
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
                    max_stack = 30
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

            toggle = "cooldowns",

            -- -action.shifting_power.execute_time%action.shifting_power.new_tick_time*(dbc.effect.815503.base_value%1000+conduit.discipline_of_the_grove.time_value)
            cdr = function ()
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

    spec:RegisterSetting( "am_spam", 1, {
        type = "toggle",
        name = "Use |T136096:0|t Arcane Missiles Spam",
        icon = 136096,
        width = "full",
        get = function () return Hekili.DB.profile.specs[ 62 ].settings.am_spam == 1 end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 62 ].settings.am_spam = val and 1 or 0
        end,
        order = 2,
    })

    
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

        potion = "potion_of_focused_resolve",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20201125, [[dWehdfqisk6rKukUKifvLnru(efvJIOQtruzvkQQQxPQsZII0Tuuvj7cLFPQIHjs6yKuTmrIEMiHMMIQY1iPW2uuf9nskvJtKICofvPwhjLmpfvUNuAFQk5GkQcwOQs9qrkCrskL6JIuuCsfvvSskIxksrvAMIeCtrkQIDQO4NIuuAOIuuvTufvv5PuyQkkDvskL8vrkQmwrkTxr9xidMuhgzXe5XqnzL6YGntPpRiJwkonQwTIQk1RPOmBfUTuTBHFt1WjXXvuLSCjpxjtxLRRkBNK8DrmEvvDErQwVIQqZxvX(jCw98SzJnDqEMuMAktvD1tPAWsDERUAp1uMnU0vGSHcHnJMGSrqDiBmpuykGSHcL(WPDE2SXYFfgYgn3PSuRF(zIFnpjg27)S493GoUh4IS3plEh)t2q6Xh38tKLYgB6G8mPm1uMQ6QNs1GL68wD1EQQNnwkaopZ8mLzJg(EdrwkBSHfoBO2i0P5HMaHEEOWuactuBe6zCvqxckHoLZNPcDktnLPkmryIAJqp)bDxfi0QOItsdGrD0sH6cnpeAlPYlH2Tc9cUJhtlg1rlfQl0YJBaSzcD6(Re6LcGfAx54ESKJjmrTrOvBPSPd2cnpoOcAi0nuSh8ysODRqRIkojnawdPcqUceWwOpxOLaHwDHoPbcHEb3XJPfJ6OLc1f6wHwDMWe1gHwT1ce6lDfoMgcTbVNgcDdf7bpMeA3k04gkcyi084GQEkh3dHMhRdOTq7wH2CmfyyGi8X9WCw2yWx3kpB2WvGaQ8S5zuppB2acsAa783zdCXpO4u2qEHUEby9AcylUsJhO15vNbbjnGTq)5JqxVaSEnbSd6kErducvkmiiPbSfA5eAzc9rdiow9ca5wKINafdcsAaBHwMqJDFS9KGvVaqUfP4jqXkOt8yj0Fj0Pk0YeA5fAPN1YQxai3Iu8eOyBpje6pFeALcuHMWBM6mQWuaijQkAceA5Yge(4EKnavoMoUh5lptkZZMnGGKgWo)D2ax8dkoLnQxawVMa2MVWCLbpOkDe27Dk2miiPbSfAzcT0ZAzB(cZvg8GQ0ryV3PyJSLVo2tjBq4J7r2WYlajnO1LV8mPyE2SbeK0a25VZg4IFqXPSr9cW61eWMk(AKoIJ54bWGGKgWwOLj0DkiMc(e6Ve65TAKni8X9iBylFDOWvr5lpZ8LNnBabjnGD(7SbU4huCkBOMcD9cW61eWwCLgpqRZRodcsAa7SbHpUhzJnqxJKxbKV8mQrE2SbeK0a25VZg4IFqXPSrNcIPGpH(lHE(snBq4J7r2OOnNIdTuOYS8LNzEMNnBabjnGD(7SbU4huCkBS83qIhBMLdJnYTiPHVwEFXGGKgWoBq4J7r2y1WThpMqkEcu5lpJAppB2acsAa783zdCXpO4u2qfvCsAamEOcQd2ixbcOe6wHwDHwMqJDFS9KGvVaqUfP4jqXkOt8yj0TcDQzdcFCpYguHPaqEjLV8mPP8SzdiiPbSZFNnWf)GItzdvuXjPbW4HkOoyJCfiGsOBfA1fAzcn29X2tcw9ca5wKINafRGoXJLq3k0Pk0YeAPN1YOctbGWnunbS1ryZe65eAPN1YOctbGWnunbSo9hTocBw2GWh3JSbvykaK0Gwx(YZmVZZMnGGKgWo)D2ax8dkoLnurfNKgaJhQG6GnYvGakHUvOvxOLj0spRLvVaqUfP4jqX2EsKni8X9iBuVaqUfP4jqLV8mQNAE2SbeK0a25VZg4IFqXPSH0ZAz1laKBrkEcuSTNezdcFCpYgBGUgjVciF5zux98SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOyBpje6pFeALcuHMWBM6mQWuaijQkAcYge(4EKn68Q8AHCl68QdXLV8mQNY8SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOyBpje6pFeALcuHMWBM6mQWuaijQkAcYge(4EKno)HBqUfDnaQtt88LNr9umpB2acsAa783zdCXpO4u2qPavOj8MPo78hUb5w01aOonXZge(4EKnOctbGu8eOYxEg1NV8SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOyBpjYge(4EKnQxai3Iu8eOYxEg1vJ8SzdiiPbSZFNnWf)GItzJni9Sw25pCdYTORbqDAIZEkcTmHEdspRLD(d3GCl6AauNM4Sc6epwc9CcnHpUhmQWuaOoFT4dyXG)a(Da64DiBq4J7r2qPGfeya5wuNh78LNr95zE2SbeK0a25VZg4IFqXPSX2pwrBofhAPqLzSc6epwc9xcTAi0F(i0Bq6zTSI2Cko0sHkZqQEJaksIp4x6S1ryZe6Ve6uZge(4EKnOctbGKg06YxEg1v75zZgqqsdyN)oBGl(bfNYgspRLPuWccmGClQZJn7Pi0Ye6ni9Sw25pCdYTORbqDAIZEkcTmHEdspRLD(d3GCl6AauNM4Sc6epwc9CTcnHpUhmQWuaiPbTog8hWVdqhVdzdcFCpYguHPaqsdAD5lpJ6PP8SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOypfHwMqJDFS9KGrfMcaP4jqXkG2Pl0Ye6ofetbFc9Cc98LQqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqltOvtHUEby9AcylUsJhO15vNbbjnGTqltOvtHUEby9Acyh0v8IgOeQuyqqsdyNni8X9iBqfMcajrvrtq(YZO(8opB2acsAa783zdCXpO4u2q6zTS6faYTifpbk2trOLj0spRLrfMcaP4jqX2Esi0YeAPN1YQxai3Iu8eOyf0jESe65Af6j8wOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLj0QOItsdGXdvqDWg5kqav2GWh3JSbvykaKevfnb5lptktnpB2acsAa783zdCdXJSH6zdGQr6iCdXde3MnKEwldpaQW064Xec3qrad22tczYl9SwgvykaKINaf7P85J8Q5rdioMRckfpbkyltEPN1YQxai3Iu8eOypLpFWUp2EsWavoMoUhScOD6YjNCzdCXpO4u2ydspRLD(d3GCl6AauNM4SNIqltOpAaXXOctbGaCJZGGKgWwOLj0Yl0spRLTb6AK8ka22tcH(ZhHMWhxfGGa6Cyj0TcT6cTCcTmHEdspRLD(d3GCl6AauNM4Sc6epwc9xcnHpUhmQWuaOoFT4dyXG)a(Da64DqOLj0Yl0QPqtZJqXpGrfMcaP86DyWJjgeK0a2c9NpcT0ZAz4bqfMwhpMq4gkcyW2Esi0YLni8X9iBqfMca15RfFaR8LNjLQNNnBabjnGD(7SbHpUhzdQWuaOoFT4dyLnWnepYgQNnWf)GItzdPN1YWdGkmToEmXkGWNqltOXUp2EsWOctbGu8eOyf0jESeAzcT8cT0ZAz1laKBrkEcuSNIq)5Jql9SwgvykaKINaf7Pi0YLV8mPmL5zZgqqsdyN)oBGl(bfNYgspRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGD(1rD6pc3q1eSeAzcT8cn29X2tcgvykaKINafRGoXJLq)LqREQc9NpcnHpUkabb05WsONRvOtPqlx2GWh3JSbvykaKxs5lptktX8SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOypfH(ZhHUtbXuWNq)LqRUAKni8X9iBqfMcajnO1LV8mPC(YZMnGGKgWo)D2GWh3JSbOYX0X9iBWJdQ6PCiUnB0PGyk47R20KAKn4Xbv9uoeV3HnNoiBOE2ax8dkoLnKEwlREbGClsXtGIT9KiF5zsPAKNnBq4J7r2GkmfasIQIMGSbeK0a25VZx(YgWAbbgw5zZZOEE2SbeK0a25VZg4IFqXPSb29X2tc25pCdYTORbqDAIZkOt8yj0TcDQcTmHw6zTmQWuaiCdvtaBDe2mHEUwHwfvCsAaSZVoQt)r4gQMGLqltOXUp2EsWOctbGu8eOyf0jESe65Af6j8wO)8rOT8PMdvqN4XsONtOXUp2EsWOctbGu8eOyf0jESYge(4EKnKgUVrUfDnaccONE(YZKY8SzdiiPbSZFNnWf)GItzdS7JTNemQWuaifpbkwbDIhlHUvOtvOLj0Yl0QPqF0aIJbXGp1CqaBgeK0a2c9NpcT8c9rdioged(uZbbSzqqsdyl0Ye6ofetbFc9xTcTApvH(ZhHwfvCsAamQJwkuxOBfA1fA5eA5eAzcT8cT8cn29X2tc25pCdYTORbqDAIZkOt8yj0Fj0QOItsdGrkOo9hTHbLoY6f68Rl0YeA5fAPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMj0F(i0QOItsdGrD0sH6cDRqRUqlNqlNq)5JqlVqJDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLEwlJkmfac3q1eWwhHntOBf6ufA5eA5eAzcT0ZAz1laKBrkEcuSTNecTmHUtbXuWNq)vRqRIkojnagPG68G3FDuNccPGVSbHpUhzdPH7BKBrxdGGa6PNV8mPyE2SbeK0a25VZg4IFqXPSb29X2tcgvykaKINafRGoXJLq)vRqRgPk0YeAS7JTNeSZF4gKBrxdG60eNvqN4XsONRvONWBHwMql9SwgvykaeUHQjGTocBMqpxRqRIkojna25xh1P)iCdvtWsOLj0hnG4y1laKBrkEcumiiPbSfAzcn29X2tcw9ca5wKINafRGoXJLqpxRqpH3cTmHg7(y7jbJkmfasXtGIvqN4XsO)sOvrfNKga78RJ60F0ggu6iRxisjBq4J7r2iXRXwfWdublpOad5lpZ8LNnBabjnGD(7SbU4huCkBGDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLEwlJkmfac3q1eWwhHntONRvOvrfNKga78RJ60FeUHQjyj0YeAS7JTNemQWuaifpbkwbDIhlHEUwHEcVf6pFeAlFQ5qf0jESe65eAS7JTNemQWuaifpbkwbDIhRSbHpUhzJeVgBvapqfS8GcmKV8mQrE2SbeK0a25VZg4IFqXPSb29X2tcgvykaKINafRGoXJLq3k0Pk0YeA5fA1uOpAaXXGyWNAoiGndcsAaBH(ZhHwEH(ObehdIbFQ5Ga2miiPbSfAzcDNcIPGpH(RwHwTNQq)5JqRIkojnag1rlfQl0TcT6cTCcTCcTmHwEHwEHg7(y7jb78hUb5w01aOonXzf0jESe6VeAvuXjPbWifuN(J2WGshz9cD(1fAzcT8cT0ZAzuHPaq4gQMa26iSzcDRql9SwgvykaeUHQjG1P)O1ryZe6pFeAvuXjPbWOoAPqDHUvOvxOLtOLtO)8rOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0TcDQcTCcTCcTmHw6zTS6faYTifpbk22tcHwMq3PGyk4tO)QvOvrfNKgaJuqDEW7VoQtbHuWx2GWh3JSrIxJTkGhOcwEqbgYxEM5zE2SbeK0a25VZg4IFqXPSb29X2tc25pCdYTORbqDAIZkOt8yj0TcDQcTmHw6zTmQWuaiCdvtaBDe2mHEUwHwfvCsAaSZVoQt)r4gQMGLqltOXUp2EsWOctbGu8eOyf0jESe65Af6j8wO)8rOT8PMdvqN4XsONtOXUp2EsWOctbGu8eOyf0jESYge(4EKnMEuT5uGClIMhHYVM8LNrTNNnBabjnGD(7SbU4huCkBGDFS9KGrfMcaP4jqXkOt8yj0TcDQcTmHwEHwnf6JgqCmig8PMdcyZGGKgWwO)8rOLxOpAaXXGyWNAoiGndcsAaBHwMq3PGyk4tO)QvOv7Pk0F(i0QOItsdGrD0sH6cDRqRUqlNqlNqltOLxOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlH(lHwfvCsAamsb1P)OnmO0rwVqNFDHwMqlVql9SwgvykaeUHQjGTocBMq3k0spRLrfMcaHBOAcyD6pADe2mH(ZhHwfvCsAamQJwkuxOBfA1fA5eA5e6pFeA5fAS7JTNeSZF4gKBrxdG60eNvqN4XsOBf6ufAzcT0ZAzuHPaq4gQMa26iSzcDRqNQqlNqlNqltOLEwlREbGClsXtGIT9KqOLj0DkiMc(e6VAfAvuXjPbWifuNh8(RJ6uqif8Lni8X9iBm9OAZPa5wenpcLFn5lptAkpB2acsAa783zdcFCpYgypWqCfDWgzhuhYg4IFqXPSH0ZAzuHPaqkEcuSTNecTmHw6zTS6faYTifpbk22tcHwMqVbPN1Yo)HBqUfDnaQttC22tcHwMq3PGyhVdOZrD6Vq)vRqd)b87a0X7q2yWdaH3zJ5z(YZmVZZMnGGKgWo)D2ax8dkoLnKEwlJkmfasXtGIT9KqOLj0spRLvVaqUfP4jqX2Esi0Ye6ni9Sw25pCdYTORbqDAIZ2Esi0Ye6ofe74DaDoQt)f6VAfA4pGFhGoEhYge(4EKnkGu4XeYoOoSYxEg1tnpB2acsAa783zdCXpO4u2q6zTmQWuaifpbk22tcHwMql9Sww9ca5wKINafB7jHqltO3G0ZAzN)Wni3IUga1PjoB7jr2GWh3JSH1XVfSr08iu8dqsa1ZxEg1vppB2acsAa783zdCXpO4u2q6zTmQWuaifpbk22tcHwMql9Sww9ca5wKINafB7jHqltO3G0ZAzN)Wni3IUga1PjoB7jr2GWh3JSHYR4205XesAqRlF5zupL5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqX2Esi0YeAPN1YQxai3Iu8eOyBpjeAzc9gKEwl78hUb5w01aOonXzBpjYge(4EKnkUIYaq8aTuimKV8mQNI5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqX2Esi0YeAPN1YQxai3Iu8eOyBpjeAzc9gKEwl78hUb5w01aOonXzBpjYge(4EKnUga9cj)fBK1lmKV8mQpF5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqX2Esi0YeAPN1YQxai3Iu8eOyBpjeAzc9gKEwl78hUb5w01aOonXzBpjYge(4EKn6q3R0rUfnEy(gTlG6R8LVSb5qE28mQNNnBabjnGD(7SbU4huCkBuVaSEnbSnFH5kdEqv6iS37uSzqqsdyl0YeAS7JTNemPN1I28fMRm4bvPJWEVtXMvaTtxOLj0spRLT5lmxzWdQshH9ENInYw(6yBpjeAzcT8cT0ZAzuHPaqkEcuSTNecTmHw6zTS6faYTifpbk22tcHwMqVbPN1Yo)HBqUfDnaQttC22tcHwoHwMqJDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLxOLEwlJkmfac3q1eWwhHntONRvOvrfNKgaJCaD(1rD6pc3q1eSeAzcT8cT8c9rdiow9ca5wKINafdcsAaBHwMqJDFS9KGvVaqUfP4jqXkOt8yj0Z1k0t4TqltOXUp2EsWOctbGu8eOyf0jESe6VeAvuXjPbWo)6Oo9hTHbLoY6fIueA5e6pFeA5fA1uOpAaXXQxai3Iu8eOyqqsdyl0YeAS7JTNemQWuaifpbkwbDIhlH(lHwfvCsAaSZVoQt)rByqPJSEHifHwoH(ZhHg7(y7jbJkmfasXtGIvqN4XsONRvONWBHwoHwUSbHpUhzdB5RtYhx(YZKY8SzdiiPbSZFNnWf)GItzd5f66fG1RjGT5lmxzWdQshH9ENIndcsAaBHwMqJDFS9KGj9Sw0MVWCLbpOkDe27Dk2ScOD6cTmHw6zTSnFH5kdEqv6iS37uSrwEbSTNecTmHwPavOj8MPoZw(6K8Xj0Yj0F(i0Yl01laRxtaBZxyUYGhuLoc79ofBgeK0a2cTmH(4DqOBf6ufA5Yge(4EKnS8cqsdAD5lptkMNnBabjnGD(7SbU4huCkBuVaSEnbSPIVgPJ4yoEamiiPbSfAzcn29X2tcgvykaKINafRGoXJLq)LqNIPk0YeAS7JTNeSZF4gKBrxdG60eNvqN4XsOBf6ufAzcT8cT0ZAzuHPaq4gQMa26iSzc9CTcTkQ4K0ayKdOZVoQt)r4gQMGLqltOLxOLxOpAaXXQxai3Iu8eOyqqsdyl0YeAS7JTNeS6faYTifpbkwbDIhlHEUwHEcVfAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojna25xh1P)OnmO0rwVqKIqlNq)5JqlVqRMc9rdiow9ca5wKINafdcsAaBHwMqJDFS9KGrfMcaP4jqXkOt8yj0Fj0QOItsdGD(1rD6pAddkDK1lePi0Yj0F(i0y3hBpjyuHPaqkEcuSc6epwc9CTc9eEl0Yj0YLni8X9iBylFDOWvr5lpZ8LNnBabjnGD(7SbU4huCkBuVaSEnbSPIVgPJ4yoEamiiPbSfAzcn29X2tcgvykaKINafRGoXJLq3k0Pk0YeA5fA5fA5fAS7JTNeSZF4gKBrxdG60eNvqN4XsO)sOvrfNKgaJuqD6pAddkDK1l05xxOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLtO)8rOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTCcTCcTmHw6zTS6faYTifpbk22tcHwUSbHpUhzdB5RdfUkkF5zuJ8SzdiiPbSZFNnWf)GItzJ6fG1RjGT4knEGwNxDgeK0a2cTmHwPavOj8MPodu5y64EKni8X9iBC(d3GCl6AauNM45lpZ8mpB2acsAa783zdCXpO4u2OEby9AcylUsJhO15vNbbjnGTqltOLxOvkqfAcVzQZavoMoUhc9NpcTsbQqt4ntD25pCdYTORbqDAIl0YLni8X9iBqfMcaP4jqLV8mQ98SzdiiPbSZFNnWf)GItzJJ3bH(lHoftvOLj01laRxtaBXvA8aToV6miiPbSfAzcT0ZAzuHPaq4gQMa26iSzc9CTcTkQ4K0ayKdOZVoQt)r4gQMGLqltOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0y3hBpjyuHPaqkEcuSc6epwc9CTc9eENni8X9iBaQCmDCpYxEM0uE2SbeK0a25VZge(4EKnavoMoUhzdECqvpLdXTzdPN1YwCLgpqRZRoBDe2SwPN1YwCLgpqRZRoRt)rRJWMLn4Xbv9uoeV3HnNoiBOE2ax8dkoLnoEhe6Ve6umvHwMqxVaSEnbSfxPXd068QZGGKgWwOLj0y3hBpjyuHPaqkEcuSc6epwcDRqNQqltOLxOLxOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlH(lHwfvCsAamsb1P)OnmO0rwVqNFDHwMql9SwgvykaeUHQjGTocBMq3k0spRLrfMcaHBOAcyD6pADe2mHwoH(ZhHwEHg7(y7jb78hUb5w01aOonXzf0jESe6wHovHwMql9SwgvykaeUHQjGTocBMqpxRqRIkojnag5a68RJ60FeUHQjyj0Yj0Yj0YeAPN1YQxai3Iu8eOyBpjeA5YxEM5DE2SbeK0a25VZg4IFqXPSH8cn29X2tcgvykaKINafRGoXJLq)LqpFQHq)5JqJDFS9KGrfMcaP4jqXkOt8yj0Z1k0POqlNqltOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0Yl0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTmHwEHwEH(ObehREbGClsXtGIbbjnGTqltOXUp2EsWQxai3Iu8eOyf0jESe65Af6j8wOLj0y3hBpjyuHPaqkEcuSc6epwc9xcTAi0Yj0F(i0Yl0QPqF0aIJvVaqUfP4jqXGGKgWwOLj0y3hBpjyuHPaqkEcuSc6epwc9xcTAi0Yj0F(i0y3hBpjyuHPaqkEcuSc6epwc9CTc9eEl0Yj0YLni8X9iB05v51c5w05vhIlF5zup18SzdiiPbSZFNnWf)GItzdS7JTNeSZF4gKBrxdG60eNvqN4XsONtOH)a(Da64DqOLj0Yl0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTmHwEHwEH(ObehREbGClsXtGIbbjnGTqltOXUp2EsWQxai3Iu8eOyf0jESe65Af6j8wOLj0y3hBpjyuHPaqkEcuSc6epwc9xcTkQ4K0ayNFDuN(J2WGshz9crkcTCc9NpcT8cTAk0hnG4y1laKBrkEcumiiPbSfAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojna25xh1P)OnmO0rwVqKIqlNq)5JqJDFS9KGrfMcaP4jqXkOt8yj0Z1k0t4TqlNqlx2GWh3JSrrBofhAPqLz5lpJ6QNNnBabjnGD(7SbU4huCkBGDFS9KGrfMcaP4jqXkOt8yj0Zj0WFa)oaD8oi0YeA5fA5fA5fAS7JTNeSZF4gKBrxdG60eNvqN4XsO)sOvrfNKgaJuqD6pAddkDK1l05xxOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLtO)8rOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTCcTCcTmHw6zTS6faYTifpbk22tcHwUSbHpUhzJI2Cko0sHkZYxEg1tzE2SbeK0a25VZg4IFqXPSb29X2tcgvykaKINafRGoXJLq3k0Pk0YeA5fA5fA5fAS7JTNeSZF4gKBrxdG60eNvqN4XsO)sOvrfNKgaJuqD6pAddkDK1l05xxOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLtO)8rOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTCcTCcTmHw6zTS6faYTifpbk22tcHwUSbHpUhzJnqxJKxbKV8mQNI5zZgqqsdyN)oBGl(bfNYgspRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGroGo)6Oo9hHBOAcwcTmHwEHwEH(ObehREbGClsXtGIbbjnGTqltOXUp2EsWQxai3Iu8eOyf0jESe65Af6j8wOLj0y3hBpjyuHPaqkEcuSc6epwc9xcTkQ4K0ayNFDuN(J2WGshz9crkcTCc9NpcT8cTAk0hnG4y1laKBrkEcumiiPbSfAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojna25xh1P)OnmO0rwVqKIqlNq)5JqJDFS9KGrfMcaP4jqXkOt8yj0Z1k0t4Tqlx2GWh3JSX5pCdYTORbqDAINV8mQpF5zZgqqsdyN)oBGl(bfNYgYl0Yl0y3hBpjyN)Wni3IUga1PjoRGoXJLq)LqRIkojnagPG60F0ggu6iRxOZVUqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqlNq)5JqlVqJDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLEwlJkmfac3q1eWwhHntONRvOvrfNKgaJCaD(1rD6pc3q1eSeA5eA5eAzcT0ZAz1laKBrkEcuSTNezdcFCpYguHPaqkEcu5lpJ6QrE2SbeK0a25VZg4IFqXPSH0ZAz1laKBrkEcuSTNecTmHwEHwEHg7(y7jb78hUb5w01aOonXzf0jESe6Ve6uMQqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqlNq)5JqlVqJDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLEwlJkmfac3q1eWwhHntONRvOvrfNKgaJCaD(1rD6pc3q1eSeA5eA5eAzcT8cn29X2tcgvykaKINafRGoXJLq)LqREkf6pFe6ni9Sw25pCdYTORbqDAIZEkcTCzdcFCpYg1laKBrkEcu5lpJ6ZZ8SzdiiPbSZFNnWf)GItzdPN1YOctbGu8eOyBpjeAzcn29X2tcgvykaKINaf7QhGkOt8yj0Fj0e(4EWwnC7XJjKINafdVlHwMql9Sww9ca5wKINafB7jHqltOXUp2EsWQxai3Iu8eOyx9aubDIhlH(lHMWh3d2QHBpEmHu8eOy4Dj0Ye6ni9Sw25pCdYTORbqDAIZ2EsKni8X9iBSA42JhtifpbQ8LNrD1EE2SbeK0a25VZg4IFqXPSH0ZAzBGUgjVcG9ueAzc9gKEwl78hUb5w01aOonXzpfHwMqVbPN1Yo)HBqUfDnaQttCwbDIhlHEUwHw6zTmLcwqGbKBrDESzD6pADe2mHE(xOj8X9GrfMcajnO1XG)a(Da64DiBq4J7r2qPGfeya5wuNh78LNr90uE2SbeK0a25VZg4IFqXPSH0ZAzBGUgjVcG9ueAzcT8cT8c9rdiowblpOadmiiPbSfAzcnHpUkabb05WsONtONpHwoH(ZhHMWhxfGGa6Cyj0Zj0QHqlNqltOLxOvtHUEby9AcyuHPaqsExIQDhIJbbjnGTq)5JqFunbhRbOX1WuWNq)LqNIQHqlx2GWh3JSbvykaK0Gwx(YZO(8opB2GWh3JSX6Pav4QOSbeK0a25VZxEMuMAE2SbeK0a25VZg4IFqXPSH0ZAzuHPaq4gQMa26iSzcDRqNA2GWh3JSbvykaKxs5lptkvppB2acsAa783zdCXpO4u2qEHUaBbRgsAac9NpcTAk0hhBgpMeA5eAzcT0ZAzuHPaq4gQMa26iSzcDRql9SwgvykaeUHQjG1P)O1ryZYge(4EKnc4AGcDqxbwx(YZKYuMNnBabjnGD(7SbU4huCkBi9SwgEauHP1XJjwbe(eAzcD9cW61eWOctbG4HLh8lDgeK0a2cTmH(ObehJ6kdULJPJ7bdcsAaBHwMqt4JRcqqaDoSe65e60u2GWh3JSbvykauNVw8bSYxEMuMI5zZgqqsdyN)oBGl(bfNYgspRLHhavyAD8yIvaHpHwMqlVqxVaSEnbmQWuaiEy5b)sNbbjnGTq)5JqF0aIJrDLb3YX0X9GbbjnGTqlNqltOj8XvbiiGohwc9CcTAKni8X9iBqfMca15RfFaR8LNjLZxE2SbeK0a25VZg4IFqXPSH0ZAzuHPaq4gQMa26iSzc9CcT0ZAzuHPaq4gQMawN(JwhHnlBq4J7r2Gkmfac(Rm8f3J8LNjLQrE2SbeK0a25VZg4IFqXPSH0ZAzuHPaq4gQMa26iSzcDRql9SwgvykaeUHQjG1P)O1ryZeAzcTsbQqt4ntDgvykaKevfnbzdcFCpYguHPaqWFLHV4EKV8mPCEMNnBabjnGD(7SbU4huCkBi9SwgvykaeUHQjGTocBMq3k0spRLrfMcaHBOAcyD6pADe2SSbHpUhzdQWuaijQkAcYxEMuQ2ZZMn4Xbv9uoe3Mn6uqmf89vBAsnYg84GQEkhI37WMthKnupBq4J7r2au5y64EKnGGKgWo)D(Yx2O8JoUh5zZZOEE2SbeK0a25VZge(4EKnavoMoUhzdECqvpLdXTzJofetbFF1oVvdzYRM1laRxtaBXvA8aToV6F(i9Sw2IR04bADE1zRJWM1k9Sw2IR04bADE1zD6pADe2m5Yg84GQEkhI37WMthKnupBGl(bfNYgDkiMc(e65AfAvuXjPbWavosbFcTmHwEHg7(y7jb78hUb5w01aOonXzf0jESe65AfAcFCpyGkhth3dg8hWVdqhVdc9Npcn29X2tcgvykaKINafRGoXJLqpxRqt4J7bdu5y64EWG)a(Da64DqO)8rOLxOpAaXXQxai3Iu8eOyqqsdyl0YeAS7JTNeS6faYTifpbkwbDIhlHEUwHMWh3dgOYX0X9Gb)b87a0X7GqlNqlNqltOLEwlREbGClsXtGIT9KqOLj0spRLrfMcaP4jqX2Esi0Ye6ni9Sw25pCdYTORbqDAIZ2EsKV8mPmpB2acsAa783zdCXpO4u2OEby9AcylUsJhO15vNbbjnGTqltOXUp2EsWOctbGu8eOyf0jESe65AfAcFCpyGkhth3dg8hWVdqhVdzdcFCpYgGkhth3J8LNjfZZMnGGKgWo)D2ax8dkoLnWUp2EsWo)HBqUfDnaQttCwb0oDHwMqlVql9SwgvykaeUHQjGTocBMq)LqRIkojna25xh1P)iCdvtWsOLj0y3hBpjyuHPaqkEcuSc6epwc9CTcn8hWVdqhVdcTCzdcFCpYguHPaqsuv0eKV8mZxE2SbeK0a25VZg4IFqXPSb29X2tc25pCdYTORbqDAIZkG2Pl0YeA5fAPN1YOctbGWnunbS1ryZe6VeAvuXjPbWo)6Oo9hHBOAcwcTmH(ObehREbGClsXtGIbbjnGTqltOXUp2EsWQxai3Iu8eOyf0jESe65AfA4pGFhGoEheAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojna25xh1P)OnmO0rwVqKIqlx2GWh3JSbvykaKevfnb5lpJAKNnBabjnGD(7SbU4huCkBGDFS9KGD(d3GCl6AauNM4ScOD6cTmHwEHw6zTmQWuaiCdvtaBDe2mH(lHwfvCsAaSZVoQt)r4gQMGLqltOLxOvtH(ObehREbGClsXtGIbbjnGTq)5JqJDFS9KGvVaqUfP4jqXkOt8yj0Fj0QOItsdGD(1rD6pAddkDK1lu5kcTCcTmHg7(y7jbJkmfasXtGIvqN4XsO)sOvrfNKga78RJ60F0ggu6iRxisrOLlBq4J7r2GkmfasIQIMG8LNzEMNnBabjnGD(7SbU4huCkBSbPN1YkAZP4qlfQmdP6ncOij(GFPZwhHntOBf6ni9SwwrBofhAPqLzivVrafjXh8lDwN(JwhHntOLj0Yl0spRLrfMcaP4jqX2Esi0F(i0spRLrfMcaP4jqXkOt8yj0Z1k0t4TqlNqltOLxOLEwlREbGClsXtGIT9KqO)8rOLEwlREbGClsXtGIvqN4XsONRvONWBHwUSbHpUhzdQWuaijQkAcYxEg1EE2SbeK0a25VZg4IFqXPSX2pwrBofhAPqLzSc6epwc9xcDAsO)8rOLxO3G0ZAzfT5uCOLcvMHu9gbuKeFWV0zRJWMj0Fj0Pk0Ye6ni9SwwrBofhAPqLzivVrafjXh8lD26iSzc9Cc9gKEwlROnNIdTuOYmKQ3iGIK4d(LoRt)rRJWMj0YLni8X9iBqfMcajnO1LV8mPP8SzdiiPbSZFNnWf)GItzdPN1YukybbgqUf15XM9ueAzc9gKEwl78hUb5w01aOonXzpfHwMqVbPN1Yo)HBqUfDnaQttCwbDIhlHEUwHMWh3dgvykaK0Gwhd(d43bOJ3HSbHpUhzdQWuaiPbTU8LNzENNnBabjnGD(7SbUH4r2q9Sbq1iDeUH4bIBZgspRLHhavyAD8ycHBOiGbB7jHm5LEwlJkmfasXtGI9u(8rE18ObehZvbLINafSLjV0ZAz1laKBrkEcuSNYNpy3hBpjyGkhth3dwb0oD5KtUSbU4huCkBSbPN1Yo)HBqUfDnaQttC2trOLj0hnG4yuHPaqaUXzqqsdyl0YeA5fAPN1Y2aDnsEfaB7jHq)5Jqt4JRcqqaDoSe6wHwDHwoHwMqlVqVbPN1Yo)HBqUfDnaQttCwbDIhlH(lHMWh3dgvykauNVw8bSyWFa)oaD8oi0F(i0y3hBpjykfSGadi3I68yZkOt8yj0Fj0Pk0F(i0yxfeuCmZsV4ui0Yj0YeA5fA1uOP5rO4hWOctbGuE9om4XedcsAaBH(ZhHw6zTm8aOctRJhtiCdfbmyBpjeA5Yge(4EKnOctbG681IpGv(YZOEQ5zZgqqsdyN)oBGl(bfNYgspRLHhavyAD8yIvaHpHwMql9Swg8xHInSrk(bXXPb7PKni8X9iBqfMca15RfFaR8LNrD1ZZMnGGKgWo)D2GWh3JSbvykauNVw8bSYg4gIhzd1Zg4IFqXPSH0ZAz4bqfMwhpMyfq4tOLj0Yl0spRLrfMcaP4jqXEkc9NpcT0ZAz1laKBrkEcuSNIq)5JqVbPN1Yo)HBqUfDnaQttCwbDIhlH(lHMWh3dgvykauNVw8bSyWFa)oaD8oi0YLV8mQNY8SzdiiPbSZFNni8X9iBqfMca15RfFaRSbUH4r2q9SbU4huCkBi9SwgEauHP1XJjwbe(eAzcT0ZAz4bqfMwhpMyRJWMj0TcT0ZAz4bqfMwhpMyD6pADe2S8LNr9umpB2acsAa783zdcFCpYguHPaqD(AXhWkBGBiEKnupBGl(bfNYgspRLHhavyAD8yIvaHpHwMql9SwgEauHP1XJjwbDIhlHEUwHwEHwEHw6zTm8aOctRJhtS1ryZe65FHMWh3dgvykauNVw8bSyWFa)oaD8oi0Yj0)k0t4Tqlx(YZO(8LNnBabjnGD(7SbU4huCkBiVqxGTGvdjnaH(ZhHwnf6JJnJhtcTCcTmHw6zTmQWuaiCdvtaBDe2mHUvOLEwlJkmfac3q1eW60F06iSzcTmHw6zTmQWuaifpbk22tcHwMqVbPN1Yo)HBqUfDnaQttC22tISbHpUhzJaUgOqh0vG1LV8mQRg5zZgqqsdyN)oBGl(bfNYgspRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGD(1rD6pc3q1eSYge(4EKnOctbG8skF5zuFEMNnBabjnGD(7SbU4huCkB0PGyk4tONRvON3QHqltOLEwlJkmfasXtGIT9KqOLj0spRLvVaqUfP4jqX2Esi0Ye6ni9Sw25pCdYTORbqDAIZ2EsKni8X9iBSEkqfUkkF5zuxTNNnBabjnGD(7SbU4huCkBi9Sww9gaYTORPayXEkcTmHw6zTmQWuaiCdvtaBDe2mH(lHofZge(4EKnOctbGKg06YxEg1tt5zZgqqsdyN)oBGl(bfNYgDkiMc(e65eAvuXjPbWKOQOja1PGqk4tOLj0y3hBpjyGkhth3dwbDIhlH(lHovHwMql9SwgvykaKINafB7jHqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqltOH1ccmWuXxCpqUfPaLfWh3dwNhELni8X9iBqfMcajrvrtq(YZO(8opB2acsAa783zdCXpO4u2OtbXuWNqpxRqRIkojnaMevfnbOofesbFcTmHw6zTmQWuaifpbk22tcHwMql9Sww9ca5wKINafB7jHqltO3G0ZAzN)Wni3IUga1PjoB7jHqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqltOXUp2EsWavoMoUhSc6epwc9xcDQzdcFCpYguHPaqsuv0eKV8mPm18SzdiiPbSZFNnWf)GItzdPN1YOctbGu8eOyBpjeAzcT0ZAz1laKBrkEcuSTNecTmHEdspRLD(d3GCl6AauNM4STNecTmHw6zTmQWuaiCdvtaBDe2mHUvOLEwlJkmfac3q1eW60F06iSzcTmH(ObehJkmfaYljgeK0a2cTmHg7(y7jbJkmfaYljwbDIhlHEUwHEcVfAzcDNcIPGpHEUwHEENQqltOXUp2EsWavoMoUhSc6epwzdcFCpYguHPaqsuv0eKV8mPu98SzdiiPbSZFNnWf)GItzdPN1YOctbGu8eOypfHwMql9SwgvykaKINafRGoXJLqpxRqpH3cTmHw6zTmQWuaiCdvtaBDe2mHUvOLEwlJkmfac3q1eW60F06iSzcTmHg7(y7jbdu5y64EWkOt8yLni8X9iBqfMcajrvrtq(YZKYuMNnBabjnGD(7SbU4huCkBi9Sww9ca5wKINaf7Pi0YeAPN1YOctbGu8eOyBpjeAzcT0ZAz1laKBrkEcuSc6epwc9CTc9eEl0YeAPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMj0YeAS7JTNemqLJPJ7bRGoXJv2GWh3JSbvykaKevfnb5lptktX8SzdiiPbSZFNnWf)GItzdPN1YOctbGu8eOyBpjeAzcT0ZAz1laKBrkEcuSTNecTmHEdspRLD(d3GCl6AauNM4SNIqltO3G0ZAzN)Wni3IUga1PjoRGoXJLqpxRqpH3cTmHw6zTmQWuaiCdvtaBDe2mHUvOLEwlJkmfac3q1eW60F06iSzzdcFCpYguHPaqsuv0eKV8mPC(YZMnGGKgWo)D2ax8dkoLnoQMGJ1a04Ayk4tONtOtr1qOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLj01laRxtaJkmfasY7suT7qCmiiPbSfAzcnHpUkabb05WsO)sOvxOLj0spRLTb6AK8ka22tISbHpUhzdQWuaijQkAcYxEMuQg5zZgqqsdyN)oBGl(bfNYghvtWXAaACnmf8j0Zj0POAi0YeAPN1YOctbGWnunbS1ryZe65eAPN1YOctbGWnunbSo9hTocBMqltORxawVMagvykaKK3LOA3H4yqqsdyl0YeAcFCvaccOZHLq)LqRUqltOLEwlBd01i5vaSTNezdcFCpYguHPaqWFLHV4EKV8mPCEMNnBq4J7r2GkmfasAqRlBabjnGD(78LNjLQ98SzdiiPbSZFNnWf)GItzdPN1YQxai3Iu8eOyBpjeAzcT0ZAzuHPaqkEcuSTNecTmHEdspRLD(d3GCl6AauNM4STNezdcFCpYgGkhth3J8LNjLPP8SzdcFCpYguHPaqsuv0eKnGGKgWo)D(Yx2a7(y7jXkpBEg1ZZMnGGKgWo)D2ax8dkoLnQxawVMa2uXxJ0rCmhpageK0a2cTmHg7(y7jbJkmfasXtGIvqN4XsO)sOtXufAzcn29X2tc25pCdYTORbqDAIZkOt8yj0TcDQcTmHwEHw6zTmQWuaiCdvtaBDe2mHEUwHwfvCsAaSZVoQt)r4gQMGLqltOLxOLxOpAaXXQxai3Iu8eOyqqsdyl0YeAS7JTNeS6faYTifpbkwbDIhlHEUwHEcVfAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojna25xh1P)OnmO0rwVqKIqlNq)5JqlVqRMc9rdiow9ca5wKINafdcsAaBHwMqJDFS9KGrfMcaP4jqXkOt8yj0Fj0QOItsdGD(1rD6pAddkDK1lePi0Yj0F(i0y3hBpjyuHPaqkEcuSc6epwc9CTc9eEl0Yj0YLni8X9iBylFDOWvr5lptkZZMnGGKgWo)D2ax8dkoLnQxawVMa2uXxJ0rCmhpageK0a2cTmHg7(y7jbJkmfasXtGIvqN4XsOBf6ufAzcT8cTAk0hnG4yqm4tnheWMbbjnGTq)5JqlVqF0aIJbXGp1CqaBgeK0a2cTmHUtbXuWNq)vRqR2tvOLtOLtOLj0Yl0Yl0y3hBpjyN)Wni3IUga1PjoRGoXJLq)LqREQcTmHw6zTmQWuaiCdvtaBDe2mHUvOLEwlJkmfac3q1eW60F06iSzcTCc9NpcT8cn29X2tc25pCdYTORbqDAIZkOt8yj0TcDQcTmHw6zTmQWuaiCdvtaBDe2mHUvOtvOLtOLtOLj0spRLvVaqUfP4jqX2Esi0Ye6ofetbFc9xTcTkQ4K0ayKcQZdE)1rDkiKc(Yge(4EKnSLVou4QO8LNjfZZMnGGKgWo)D2ax8dkoLnQxawVMa2MVWCLbpOkDe27Dk2miiPbSfAzcn29X2tcM0ZArB(cZvg8GQ0ryV3PyZkG2Pl0YeAPN1Y28fMRm4bvPJWEVtXgzlFDSTNecTmHwEHw6zTmQWuaifpbk22tcHwMql9Sww9ca5wKINafB7jHqltO3G0ZAzN)Wni3IUga1PjoB7jHqlNqltOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0Yl0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGD(1rD6pc3q1eSeAzcT8cT8c9rdiow9ca5wKINafdcsAaBHwMqJDFS9KGvVaqUfP4jqXkOt8yj0Z1k0t4TqltOXUp2EsWOctbGu8eOyf0jESe6VeAvuXjPbWo)6Oo9hTHbLoY6fIueA5e6pFeA5fA1uOpAaXXQxai3Iu8eOyqqsdyl0YeAS7JTNemQWuaifpbkwbDIhlH(lHwfvCsAaSZVoQt)rByqPJSEHifHwoH(ZhHg7(y7jbJkmfasXtGIvqN4XsONRvONWBHwoHwUSbHpUhzdB5RtYhx(YZmF5zZgqqsdyN)oBGl(bfNYg1laRxtaBZxyUYGhuLoc79ofBgeK0a2cTmHg7(y7jbt6zTOnFH5kdEqv6iS37uSzfq70fAzcT0ZAzB(cZvg8GQ0ryV3PyJS8cyBpjeAzcTsbQqt4ntDMT81j5JlBq4J7r2WYlajnO1LV8mQrE2SbeK0a25VZg4IFqXPSb29X2tc25pCdYTORbqDAIZkOt8yj0TcDQcTmHw6zTmQWuaiCdvtaBDe2mHEUwHwfvCsAaSZVoQt)r4gQMGLqltOXUp2EsWOctbGu8eOyf0jESe65Af6j8oBq4J7r2OZRYRfYTOZRoex(YZmpZZMnGGKgWo)D2ax8dkoLnWUp2EsWOctbGu8eOyf0jESe6wHovHwMqlVqRMc9rdioged(uZbbSzqqsdyl0F(i0Yl0hnG4yqm4tnheWMbbjnGTqltO7uqmf8j0F1k0Q9ufA5eA5eAzcT8cT8cn29X2tc25pCdYTORbqDAIZkOt8yj0Fj0QOItsdGrkOo9hTHbLoY6f68Rl0YeAPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMj0Yj0F(i0Yl0y3hBpjyN)Wni3IUga1PjoRGoXJLq3k0Pk0YeAPN1YOctbGWnunbS1ryZe6wHovHwoHwoHwMql9Sww9ca5wKINafB7jHqltO7uqmf8j0F1k0QOItsdGrkOop49xh1PGqk4lBq4J7r2OZRYRfYTOZRoex(YZO2ZZMnGGKgWo)D2ax8dkoLnWUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0Z1k0QOItsdGD(1rD6pc3q1eSeAzcn29X2tcgvykaKINafRGoXJLqpxRqpH3zdcFCpYgBGUgjVciF5zst5zZgqqsdyN)oBGl(bfNYgy3hBpjyuHPaqkEcuSc6epwcDRqNQqltOLxOvtH(ObehdIbFQ5Ga2miiPbSf6pFeA5f6JgqCmig8PMdcyZGGKgWwOLj0DkiMc(e6VAfA1EQcTCcTCcTmHwEHwEHg7(y7jb78hUb5w01aOonXzf0jESe6VeA1tvOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHntOLtO)8rOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlHUvOtvOLj0spRLrfMcaHBOAcyRJWMj0TcDQcTCcTCcTmHw6zTS6faYTifpbk22tcHwMq3PGyk4tO)QvOvrfNKgaJuqDEW7VoQtbHuWx2GWh3JSXgORrYRaYxEM5DE2SbeK0a25VZg4IFqXPSb29X2tc25pCdYTORbqDAIZkOt8yj0Fj0QOItsdGvluN(J2WGshz9cD(1fAzcn29X2tcgvykaKINafRGoXJLq)LqRIkojnawTqD6pAddkDK1lePi0YeA5f6JgqCS6faYTifpbkgeK0a2cTmHwEHg7(y7jbREbGClsXtGIvqN4XsONtOH)a(Da64DqO)8rOXUp2EsWQxai3Iu8eOyf0jESe6VeAvuXjPbWQfQt)rByqPJSEHkxrOLtO)8rOvtH(ObehREbGClsXtGIbbjnGTqlNqltOLEwlJkmfac3q1eWwhHntO)sOtPqltO3G0ZAzN)Wni3IUga1PjoB7jHqltOLEwlREbGClsXtGIT9KqOLj0spRLrfMcaP4jqX2EsKni8X9iBu0MtXHwkuzw(YZOEQ5zZgqqsdyN)oBGl(bfNYgy3hBpjyN)Wni3IUga1PjoRGoXJLqpNqd)b87a0X7GqltOLEwlJkmfac3q1eWwhHntONRvOvrfNKga78RJ60FeUHQjyj0YeAS7JTNemQWuaifpbkwbDIhlHEoHwEHg(d43bOJ3bH(xHMWh3d25pCdYTORbqDAIZG)a(Da64DqOLlBq4J7r2OOnNIdTuOYS8LNrD1ZZMnGGKgWo)D2ax8dkoLnWUp2EsWOctbGu8eOyf0jESe65eA4pGFhGoEheAzcT8cT8cTAk0hnG4yqm4tnheWMbbjnGTq)5JqlVqF0aIJbXGp1CqaBgeK0a2cTmHUtbXuWNq)vRqR2tvOLtOLtOLj0Yl0Yl0y3hBpjyN)Wni3IUga1PjoRGoXJLq)LqRIkojnagPG60F0ggu6iRxOZVUqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqlNq)5JqlVqJDFS9KGD(d3GCl6AauNM4Sc6epwcDRqNQqltOLEwlJkmfac3q1eWwhHntOBf6ufA5eA5eAzcT0ZAz1laKBrkEcuSTNecTmHUtbXuWNq)vRqRIkojnagPG68G3FDuNccPGpHwUSbHpUhzJI2Cko0sHkZYxEg1tzE2SbeK0a25VZg4IFqXPSb29X2tcgvykaKINafRGoXJLqpNqRgPk0YeAyTGadmv8f3dKBrkqzb8X9G15HxzdcFCpYgN)Wni3IUga1PjE(YZOEkMNnBabjnGD(7SbU4huCkBi9SwgvykaeUHQjGTocBMqpxRqRIkojna25xh1P)iCdvtWsOLj0y3hBpjyuHPaqkEcuSc6epwc9CTcn8hWVdqhVdzdcFCpYgN)Wni3IUga1PjE(YZO(8LNnBabjnGD(7SbU4huCkBi9SwgvykaeUHQjGTocBMqpxRqRIkojna25xh1P)iCdvtWsOLj0hnG4y1laKBrkEcumiiPbSfAzcn29X2tcw9ca5wKINafRGoXJLqpxRqd)b87a0X7GqltOXUp2EsWOctbGu8eOyf0jESe6VeAvuXjPbWo)6Oo9hTHbLoY6fIuYge(4EKno)HBqUfDnaQtt88LNrD1ipB2acsAa783zdCXpO4u2q6zTmQWuaiCdvtaBDe2mHEUwHwfvCsAaSZVoQt)r4gQMGLqltOLxOvtH(ObehREbGClsXtGIbbjnGTq)5JqJDFS9KGvVaqUfP4jqXkOt8yj0Fj0QOItsdGD(1rD6pAddkDK1lu5kcTCcTmHg7(y7jbJkmfasXtGIvqN4XsO)sOvrfNKga78RJ60F0ggu6iRxisjBq4J7r248hUb5w01aOonXZxEg1NN5zZgqqsdyN)oBGl(bfNYgy3hBpjyN)Wni3IUga1PjoRGoXJLq)LqRIkojnagPG60F0ggu6iRxOZVUqltOLEwlJkmfac3q1eWwhHntOBfAPN1YOctbGWnunbSo9hTocBMqltOLEwlREbGClsXtGIT9KqOLj0DkiMc(e6VAfAvuXjPbWifuNh8(RJ6uqif8Lni8X9iBqfMcaP4jqLV8mQR2ZZMnGGKgWo)D2ax8dkoLnKEwlJkmfasXtGIT9KqOLj0y3hBpjyN)Wni3IUga1PjoRGoXJLq)LqRIkojnaw5kOo9hTHbLoY6f68Rl0YeAPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMj0YeA5fAS7JTNemQWuaifpbkwbDIhlH(lHw9uk0F(i0Bq6zTSZF4gKBrxdG60eN9ueA5Yge(4EKnQxai3Iu8eOYxEg1tt5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqX2Esi0YeAS7JTNemQWuaifpbk2vpavqN4XsO)sOj8X9GTA42JhtifpbkgExcTmHw6zTS6faYTifpbk22tcHwMqJDFS9KGvVaqUfP4jqXU6bOc6epwc9xcnHpUhSvd3E8ycP4jqXW7sOLj0Bq6zTSZF4gKBrxdG60eNT9KiBq4J7r2y1WThpMqkEcu5lpJ6Z78SzdiiPbSZFNnWf)GItzdPN1YOctbGWnunbS1ryZe6wHovHwMqJDvqqXXml9Itr2GWh3JSHsbliWaYTOop25lptktnpB2acsAa783zdCXpO4u2ydspRLD(d3GCl6AauNM4SNIqltO3G0ZAzN)Wni3IUga1PjoRGoXJLqpNqt4J7bJkmfaQZxl(awm4pGFhGoEheAzcTAk0yxfeuCmZsV4uKni8X9iBOuWccmGClQZJD(Yx2ydw6nU8S5zuppB2acsAa783zdCXpO4u24OAco2gKEwldtRJhtSci8Lni8X9iBG9xCqTuGXiF5zszE2SbeK0a25VZgUs2ybx2GWh3JSHkQ4K0aYgQOXdYgQNnWf)GItzdvuXjPbWAivaYvGa2c9CTcDQcTmHwPavOj8MPodu5y64Ei0YeA1uORxawVMa2IR04bADE1zqqsdyNnurfkOoKnAivaYvGa25lptkMNnBabjnGD(7SHRKnwWLni8X9iBOIkojnGSHkA8GSH6zdCXpO4u2qfvCsAaSgsfGCfiGTqpxRqNQqltOLEwlJkmfasXtGIT9KqOLj0y3hBpjyuHPaqkEcuSc6epwc9xcDQcTmHUEby9AcylUsJhO15vNbbjnGD2qfvOG6q2OHubixbcyNV8mZxE2SbeK0a25VZgUs2ybx2GWh3JSHkQ4K0aYgQOXdYgQNnWf)GItzdPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMj0YeA1uOLEwlREda5w01uaSypfHwMqB5tnhQGoXJLqpxRqlVqlVq3PGe6FeAcFCpyuHPaqsdADmSVoHwoHE(xOj8X9GrfMcajnO1XG)a(Da64DqOLlBOIkuqDiBy5bnqsVkYxEg1ipB2acsAa783zdcFCpYgyAmqe(4EGg81Lng81HcQdzJvdvWgH3R8LNzEMNnBabjnGD(7SbHpUhzdmngicFCpqd(6Ygd(6qb1HSbSwqGHv(YZO2ZZMnGGKgWo)D2ax8dkoLni8XvbiiGohwc9xcDkZge(4EKnW0yGi8X9an4RlBm4RdfuhYgKd5lptAkpB2acsAa783zdCXpO4u2qfvCsAaSgsfGCfiGTqpxRqNA2GWh3JSbMgdeHpUhObFDzJbFDOG6q2WvGaQ8LNzENNnBabjnGD(7SbU4huCkBSG74X0IrD0sH6cDRqRE2GWh3JSbMgdeHpUhObFDzJbFDOG6q2G6OLc1ZxEg1tnpB2acsAa783zdcFCpYgyAmqe(4EGg81Lng81HcQdzdS7JTNeR8LNrD1ZZMnGGKgWo)D2ax8dkoLnurfNKgaZYdAGKEvi0TcDQzdcFCpYgyAmqe(4EGg81Lng81HcQdzJYp64EKV8mQNY8SzdiiPbSZFNnWf)GItzdvuXjPbWS8GgiPxfcDRqRE2GWh3JSbMgdeHpUhObFDzJbFDOG6q2WYdAGKEvKV8mQNI5zZgqqsdyN)oBq4J7r2atJbIWh3d0GVUSXGVouqDiB0DvqhIlF5lBOua27s0LNnpJ65zZgqqsdyN)oB4kzJcwWLni8X9iBOIkojnGSHkQqb1HSHsbkVXabQ8SXgS0BCzJuZxEMuMNnBabjnGD(7SHRKnwWLni8X9iBOIkojnGSHkA8GSH6zdCXpO4u2qfvCsAamLcuEJbcu5cDRqNQqltORxawVMa2IR04bADE1zqqsdyl0YeAcFCvaccOZHLq)LqNYSHkQqb1HSHsbkVXabQ88LNjfZZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2q9SbU4huCkBOIkojnaMsbkVXabQCHUvOtvOLj01laRxtaBXvA8aToV6miiPbSfAzcn2vbbfhlaC5dV2cTmHMWhxfGGa6Cyj0Fj0QNnurfkOoKnukq5ngiqLNV8mZxE2SbeK0a25VZgUs2ybx2GWh3JSHkQ4K0aYgQOXdYgPMnWf)GItzdvuXjPbWukq5ngiqLl0TcDQzdvuHcQdzdLcuEJbcu55lpJAKNnBabjnGD(7SHRKnwWLni8X9iBOIkojnGSHkA8GSrQzdvuHcQdzJgsfGCfiGD(YZmpZZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2q9SbU4huCkBOIkojnawdPcqUceWwOBf6ufAzcnHpUkabb05WsO)sOtz2qfvOG6q2OHubixbcyNV8mQ98SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnupBGl(bfNYgQOItsdG1qQaKRabSf6wHovHwMqRIkojnaMsbkVXabQCHUvOvpBOIkuqDiB0qQaKRabSZxEM0uE2SbeK0a25VZgUs2ybx2GWh3JSHkQ4K0aYgQOXdYgPMnurfkOoKnS8GgiPxf5lpZ8opB2acsAa783zdxjBuWcUSbHpUhzdvuXjPbKnurfkOoKnQfQt)rByqPJSEHo)6zJnyP34YgQr(YZOEQ5zZgqqsdyN)oB4kzJcwWLni8X9iBOIkojnGSHkQqb1HSrTqD6pAddkDK1lu5kzJnyP34YgQr(YZOU65zZgqqsdyN)oB4kzJcwWLni8X9iBOIkojnGSHkQqb1HSrTqD6pAddkDK1lePKn2GLEJlBKYuZxEg1tzE2SbeK0a25VZgUs2OGfCzdcFCpYgQOItsdiBOIkuqDiBqkOo9hTHbLoY6f68RNn2GLEJlBOEQ5lpJ6PyE2SbeK0a25VZgUs2OGfCzdcFCpYgQOItsdiBOIkuqDiBuUcQt)rByqPJSEHo)6zJnyP34YgPm18LNr95lpB2acsAa783zdxjBuWcUSbHpUhzdvuXjPbKnurfkOoKno)6Oo9hTHbLoY6fIuYgBWsVXLnsnF5zuxnYZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2ifZg4IFqXPSHkQ4K0ayNFDuN(J2WGshz9crkcDRqNQqltORxawVMa2MVWCLbpOkDe27Dk2miiPbSZgQOcfuhYgNFDuN(J2WGshz9crk5lpJ6ZZ8SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnuxnYg4IFqXPSHkQ4K0ayNFDuN(J2WGshz9crkcDRqNQqltOXUkiO4ybFQ5qwcYgQOcfuhYgNFDuN(J2WGshz9crk5lpJ6Q98SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnuxnYg4IFqXPSHkQ4K0ayNFDuN(J2WGshz9crkcDRqNQqltOXESF8JrfMcaPu(MpLodcsAaBHwMqt4JRcqqaDoSe65e6umBOIkuqDiBC(1rD6pAddkDK1lePKV8mQNMYZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2iftnBGl(bfNYgQOItsdGD(1rD6pAddkDK1lePi0TcDQcTmHgwliWatfFX9a5wKcuwaFCpyDE4v2qfvOG6q248RJ60F0ggu6iRxisjF5zuFENNnBabjnGD(7SHRKnwWLni8X9iBOIkojnGSHkA8GSHAKnWf)GItzdvuXjPbWo)6Oo9hTHbLoY6fIue6wHo1SHkQqb1HSX5xh1P)OnmO0rwVqKs(YZKYuZZMnGGKgWo)D2WvYgfSGlBq4J7r2qfvCsAazdvuHcQdzJZVoQt)rByqPJSEHkxjBSbl9gx2iLPMV8mPu98SzdiiPbSZFNnCLSrbl4Yge(4EKnurfNKgq2qfvOG6q2qIQIMauNccPGVSXgS0BCzJuZxEMuMY8SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnKxONNPk0ZVeA5f6oToOshPIgpqON)fA1tnvHwoHwUSbU4huCkBOIkojnaMevfnbOofesbFcDRqNQqltOXUkiO4ybFQ5qwcYgQOcfuhYgsuv0eG6uqif8LV8mPmfZZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2qEHonLQqp)sOLxO706GkDKkA8aHE(xOvp1ufA5eA5Yg4IFqXPSHkQ4K0aysuv0eG6uqif8j0TcDQzdvuHcQdzdjQkAcqDkiKc(YxEMuoF5zZgqqsdyN)oB4kzJcwWLni8X9iBOIkojnGSHkQqb1HSbPG68G3FDuNccPGVSXgS0BCzJuZxEMuQg5zZgqqsdyN)oB4kzJfCzdcFCpYgQOItsdiBOIgpiBOgPMnWf)GItzdvuXjPbWifuNh8(RJ6uqif8j0TcDQcTmHUEby9AcyB(cZvg8GQ0ryV3PyZGGKgWoBOIkuqDiBqkOop49xh1PGqk4lF5zs58mpB2acsAa783zdxjBSGlBq4J7r2qfvCsAazdv04bzd1i1SbU4huCkBOIkojnagPG68G3FDuNccPGpHUvOtvOLj01laRxtaBQ4Rr6ioMJhadcsAa7SHkQqb1HSbPG68G3FDuNccPGV8LNjLQ98SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnuxnYg4IFqXPSHkQ4K0ayKcQZdE)1rDkiKc(e6wHo1SHkQqb1HSbPG68G3FDuNccPGV8LNjLPP8SzdiiPbSZFNnCLSrbl4Yge(4EKnurfNKgq2qfvOG6q248RJ60FeUHQjyLn2GLEJlBKY8LNjLZ78SzdiiPbSZFNnCLSrbl4Yge(4EKnurfNKgq2qfvOG6q2GhQG6GnYvGaQSXgS0BCzJuZxEMum18SzdiiPbSZFNnCLSXcUSbHpUhzdvuXjPbKnurJhKnupBGl(bfNYgQOItsdGXdvqDWg5kqaLq3k0Pk0Ye6JgqCS6faYTifpbkgeK0a2cTmHwEH(ObehJkmfacWnodcsAaBH(ZhHwnfASRcckoMzPxCkeA5eAzcT8cTAk0yxfeuCSaWLp8Al0F(i0e(4QaeeqNdlHUvOvxO)8rORxawVMa2IR04bADE1zqqsdyl0YLnurfkOoKn4HkOoyJCfiGkF5zsr1ZZMnGGKgWo)D2WvYgl4Yge(4EKnurfNKgq2qfnEq2i1SbU4huCkBOIkojnagpub1bBKRabucDRqNA2qfvOG6q2GhQG6GnYvGaQ8LNjftzE2SbeK0a25VZgUs2ybx2GWh3JSHkQ4K0aYgQOXdYgW86XvuGnRtysQa0QbGd1FlowO)8rOH51JROaB20G2C68AHKO9ei0F(i0W86XvuGnBAqBoDETqDytJb3dH(ZhHgMxpUIcSzBQmR7EG2a2mKY7kyHHadc9NpcnmVECffyZ4XcxVJKgaAE9O4ED0guXXGq)5JqdZRhxrb2SL)gd4oEmHQNu6c9NpcnmVECffyZwVqA4(grD4AsFDc9NpcnmVECffyZsiZGaQfYwESf6pFeAyE94kkWMzhuhqUfjr3nGSHkQqb1HSbPG8a9wq(YZKIPyE2SbeK0a25VZgUs2OGfCzdcFCpYgQOItsdiBOIkuqDiBqoGo)6Oo9hHBOAcwzJnyP34YgPmF5zsX5lpB2acsAa783zdxjBSGlBq4J7r2qfvCsAazdv04bzd1Zg4IFqXPSHkQ4K0aynKka5kqaBHUvOtvOLj0l4oEmTyuhTuOUq3k0QNnurfkOoKnAivaYvGa25lptkQg5zZgqqsdyN)oB4kzJcwWLni8X9iBOIkojnGSHkQqb1HSbOYrk4lBSbl9gx2qD1iF5zsX5zE2SbeK0a25VZxEMuuTNNnBabjnGD(78LNjftt5zZgqqsdyN)oF5zsX5DE2SbHpUhzJ1R39arfMcazPoFWPkBabjnGD(78LNz(snpB2GWh3JSbvykaepoyma8LnGGKgWo)D(YZmFQNNnBq4J7r2a7X87xbOofeAc6zdiiPbSZFNV8mZxkZZMnGGKgWo)D(YZmFPyE2SbHpUhzJoVkVq8onbzdiiPbSZFNV8mZ38LNnBabjnGD(7SbU4huCkBOMcTkQ4K0aykfO8gdeOYf6wHwDHwMqxVaSEnbSnFH5kdEqv6iS37uSzqqsdyNni8X9iBylFDs(4YxEM5tnYZMnGGKgWo)D2ax8dkoLnutHwfvCsAamLcuEJbcu5cDRqRUqltOvtHUEby9AcyB(cZvg8GQ0ryV3PyZGGKgWoBq4J7r2GkmfasAqRlF5zMV5zE2SbeK0a25VZg4IFqXPSHkQ4K0aykfO8gdeOYf6wHw9SbHpUhzdqLJPJ7r(Yx2G6OLc1ZZMNr98SzdiiPbSZFNnWf)GItzJofetbFc9CTcTkQ4K0ayGkhPGpHwMqlVqJDFS9KGD(d3GCl6AauNM4Sc6epwc9CTcnHpUhmqLJPJ7bd(d43bOJ3bH(ZhHg7(y7jbJkmfasXtGIvqN4XsONRvOj8X9GbQCmDCpyWFa)oaD8oi0F(i0Yl0hnG4y1laKBrkEcumiiPbSfAzcn29X2tcw9ca5wKINafRGoXJLqpxRqt4J7bdu5y64EWG)a(Da64DqOLtOLtOLj0spRLvVaqUfP4jqX2Esi0YeAPN1YOctbGu8eOyBpjeAzc9gKEwl78hUb5w01aOonXzBpjYge(4EKnavoMoUh5lptkZZMnGGKgWo)D2ax8dkoLnWUp2EsWOctbGu8eOyf0jESe6wHovHwMqlVql9Sww9ca5wKINafB7jHqltOLxOXUp2EsWo)HBqUfDnaQttCwbDIhlH(lHwfvCsAamsb1P)OnmO0rwVqNFDH(ZhHg7(y7jb78hUb5w01aOonXzf0jESe6wHovHwoHwUSbHpUhzJnqxJKxbKV8mPyE2SbeK0a25VZg4IFqXPSb29X2tcgvykaKINafRGoXJLq3k0Pk0YeA5fAPN1YQxai3Iu8eOyBpjeAzcT8cn29X2tc25pCdYTORbqDAIZkOt8yj0Fj0QOItsdGrkOo9hTHbLoY6f68Rl0F(i0y3hBpjyN)Wni3IUga1PjoRGoXJLq3k0Pk0Yj0YLni8X9iB05v51c5w05vhIlF5zMV8SzdcFCpYgfT5uCOLcvMLnGGKgWo)D(YZOg5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqX2Esi0YeAS7JTNemQWuaifpbk2vpavqN4XsO)sOj8X9GTA42JhtifpbkgExcTmHw6zTS6faYTifpbk22tcHwMqJDFS9KGvVaqUfP4jqXU6bOc6epwc9xcnHpUhSvd3E8ycP4jqXW7sOLj0Bq6zTSZF4gKBrxdG60eNT9KiBq4J7r2y1WThpMqkEcu5lpZ8mpB2acsAa783zdCXpO4u2q6zTS6faYTifpbk22tcHwMqJDFS9KGrfMcaP4jqXkOt8yj0Fj0PMni8X9iBuVaqUfP4jqLV8mQ98SzdiiPbSZFNnWf)GItzd5fAS7JTNemQWuaifpbkwbDIhlHUvOtvOLj0spRLvVaqUfP4jqX2Esi0Yj0F(i0kfOcnH3m1z1laKBrkEcuzdcFCpYgN)Wni3IUga1PjE(YZKMYZMnGGKgWo)D2ax8dkoLnWUp2EsWOctbGu8eOyf0jESe65eA1ivHwMql9Sww9ca5wKINafB7jHqltOH1ccmWuXxCpqUfPaLfWh3dgeK0a2zdcFCpYgN)Wni3IUga1PjE(YZmVZZMnGGKgWo)D2ax8dkoLnKEwlREbGClsXtGIT9KqOLj0y3hBpjyN)Wni3IUga1PjoRGoXJLq)LqRIkojnagPG60F0ggu6iRxOZVE2GWh3JSbvykaKINav(YZOEQ5zZgqqsdyN)oBGl(bfNYgspRLrfMcaP4jqXEkcTmHw6zTmQWuaifpbkwbDIhlHEUwHMWh3dgvykauNVw8bSyWFa)oaD8oi0YeAPN1YOctbGWnunbS1ryZe6wHw6zTmQWuaiCdvtaRt)rRJWMLni8X9iBqfMcajrvrtq(YZOU65zZgqqsdyN)oBGl(bfNYgspRLrfMcaHBOAcyRJWMj0Zj0spRLrfMcaHBOAcyD6pADe2mHwMql9Sww9ca5wKINafB7jHqltOLEwlJkmfasXtGIT9KqOLj0Bq6zTSZF4gKBrxdG60eNT9KiBq4J7r2GkmfaYlP8LNr9uMNnBabjnGD(7SbU4huCkBi9Sww9ca5wKINafB7jHqltOLEwlJkmfasXtGIT9KqOLj0Bq6zTSZF4gKBrxdG60eNT9KqOLj0spRLrfMcaHBOAcyRJWMj0TcT0ZAzuHPaq4gQMawN(JwhHnlBq4J7r2GkmfasIQIMG8LNr9umpB2acsAa783zdCdXJSH6zdGQr6iCdXde3MnKEwldpaQW064Xec3qrad22tczYl9SwgvykaKINaf7P85J0ZAz1laKBrkEcuSNYNpy3hBpjyGkhth3dwb0oD5Yg4IFqXPSH0ZAz4bqfMwhpMyfq4lBq4J7r2GkmfaQZxl(aw5lpJ6ZxE2SbeK0a25VZg4gIhzd1ZgavJ0r4gIhiUnBi9SwgEauHP1XJjeUHIagSTNeYKx6zTmQWuaifpbk2t5ZhPN1YQxai3Iu8eOypLpFWUp2EsWavoMoUhScOD6YLnWf)GItzd1uOP5rO4hWOctbGuE9om4XedcsAaBH(ZhHw6zTm8aOctRJhtiCdfbmyBpjYge(4EKnOctbG681IpGv(YZOUAKNnBabjnGD(7SbU4huCkBi9Sww9ca5wKINafB7jHqltOLEwlJkmfasXtGIT9KqOLj0Bq6zTSZF4gKBrxdG60eNT9KiBq4J7r2au5y64EKV8mQppZZMnGGKgWo)D2ax8dkoLnKEwlJkmfac3q1eWwhHntONtOLEwlJkmfac3q1eW60F06iSzzdcFCpYguHPaqEjLV8mQR2ZZMni8X9iBqfMcajrvrtq2acsAa7835lpJ6PP8SzdcFCpYguHPaqsdADzdiiPbSZFNV8LnwnubBeEVYZMNr98SzdiiPbSZFNnWf)GItzd5f6JgqCmig8PMdcyZGGKgWwOLj0DkiMc(e65Af60uQcTmHUtbXuWNq)vRqppvdHwoH(ZhHwEHwnf6JgqCmig8PMdcyZGGKgWwOLj0DkiMc(e65Af60KAi0YLni8X9iB0PGqtqpF5zszE2SbeK0a25VZg4IFqXPSH0ZAzuHPaqkEcuSNs2GWh3JSHIFCpYxEMumpB2acsAa783zdCXpO4u2OEby9Acyh0v8IgOeQuyqqsdyl0YeAPN1YG)n0BDCpypfHwMqlVqJDFS9KGrfMcaP4jqXkG2Pl0F(i0w(uZHkOt8yj0Z1k0ZxQcTCzdcFCpYghVdOeQuYxEM5lpB2acsAa783zdCXpO4u2q6zTmQWuaifpbk22tcHwMql9Sww9ca5wKINafB7jHqltO3G0ZAzN)Wni3IUga1PjoB7jr2GWh3JSXGp1Cl0873EQdXLV8mQrE2SbeK0a25VZg4IFqXPSH0ZAzuHPaqkEcuSTNecTmHw6zTS6faYTifpbk22tcHwMqVbPN1Yo)HBqUfDnaQttC22tISbHpUhzdjAc5w0vCSzR8LNzEMNnBabjnGD(7SbU4huCkBi9SwgvykaKINaf7PKni8X9iBib1ckZ4Xu(YZO2ZZMnGGKgWo)D2ax8dkoLnKEwlJkmfasXtGI9uYge(4EKnKgUVr2xLE(YZKMYZMnGGKgWo)D2ax8dkoLnKEwlJkmfasXtGI9uYge(4EKnS8cKgUVZxEM5DE2SbeK0a25VZg4IFqXPSH0ZAzuHPaqkEcuSNs2GWh3JSbfyyDfnqyAmYxEg1tnpB2acsAa783zdCXpO4u2q6zTmQWuaifpbk2tjBq4J7r24Tae)G(kF5zux98SzdiiPbSZFNni8X9iBmnOnNoVwijApbzdCXpO4u2q6zTmQWuaifpbk2trO)8rOXUp2EsWOctbGu8eOyf0jESe6VAfA1qneAzc9gKEwl78hUb5w01aOonXzpLSbyTa(qb1HSX0G2C68AHKO9eKV8mQNY8SzdiiPbSZFNni8X9iBaDL0lGgiV2bfyiBGl(bfNYgy3hBpjyuHPaqkEcuSc6epwc9CTcDktnBeuhYgqxj9cObYRDqbgYxEg1tX8SzdiiPbSZFNni8X9iBSlG2wEbivWAbJSbU4huCkBGDFS9KGrfMcaP4jqXkOt8yj0F1k0PmvH(ZhHwnfAvuXjPbWifKhO3ce6wHwDH(ZhHwEH(4DqOBf6ufAzcTkQ4K0ay8qfuhSrUceqj0TcT6cTmHUEby9AcylUsJhO15vNbbjnGTqlx2iOoKn2fqBlVaKkyTGr(YZO(8LNnBabjnGD(7SbHpUhzJL)gi(uWpOYg4IFqXPSb29X2tcgvykaKINafRGoXJLq)vRqNYuf6pFeA1uOvrfNKgaJuqEGElqOBfA1f6pFeA5f6J3bHUvOtvOLj0QOItsdGXdvqDWg5kqaLq3k0Ql0Ye66fG1RjGT4knEGwNxDgeK0a2cTCzJG6q2y5VbIpf8dQ8LNrD1ipB2acsAa783zdcFCpYgtJ0vAqUfrRfVZh0X9iBGl(bfNYgy3hBpjyuHPaqkEcuSc6epwc9xTcDktvO)8rOvtHwfvCsAamsb5b6TaHUvOvxO)8rOLxOpEhe6wHovHwMqRIkojnagpub1bBKRabucDRqRUqltORxawVMa2IR04bADE1zqqsdyl0YLncQdzJPr6kni3IO1I35d64EKV8mQppZZMnGGKgWo)D2GWh3JSrNWKubOvdahQ)wCC2ax8dkoLnWUp2EsWOctbGu8eOyf0jESe65AfA1qOLj0Yl0QPqRIkojnagpub1bBKRabucDRqRUq)5JqF8oi0Fj0PyQcTCzJG6q2OtysQa0QbGd1FlooF5zuxTNNnBabjnGD(7SbHpUhzJoHjPcqRgaou)T44SbU4huCkBGDFS9KGrfMcaP4jqXkOt8yj0Z1k0QHqltOvrfNKgaJhQG6GnYvGakHUvOvxOLj0spRLvVaqUfP4jqXEkcTmHw6zTS6faYTifpbkwbDIhlHEUwHwEHw9uf65xcTAi0Z)cD9cW61eWwCLgpqRZRodcsAaBHwoHwMqF8oi0Zj0PyQzJG6q2OtysQa0QbGd1FlooF5lB0DvqhIlpBEg1ZZMnGGKgWo)D2ax8dkoLn6UkOdXX281rbge6VAfA1tnBq4J7r2qAWdZYxEMuMNnBq4J7r2qPGfeya5wuNh7SbeK0a25VZxEMumpB2acsAa783zdCXpO4u2O7QGoehBZxhfyqONtOvp1SbHpUhzdQWuaOoFT4dyLV8mZxE2SbHpUhzdQWuaiVKYgqqsdyN)oF5zuJ8SzdcFCpYgwEbiPbTUSbeK0a25VZx(YgwEqdK0RI8S5zuppB2acsAa783zdcFCpYguHPaqD(AXhWkBGBiEKnupBGl(bfNYgspRLHhavyAD8yIvaHV8LNjL5zZge(4EKnOctbGKg06YgqqsdyN)oF5zsX8SzdcFCpYguHPaqsuv0eKnGGKgWo)D(Yx(YgQGAX9iptktnLPQU6PC(Ygjuf8yALnsZnpm)nZ8ZmPzulHwONTbeAExXRtOTEj0M7kqaL5cDbZRhVGTqV8oi0078oDWwOXnumblMWKuGhGqRUAj0PHhQG6GTqB(rdiowAnxOpxOn)ObehlTmiiPbSnxOLx9)YXeMKc8aeA1vlHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8P8VCmHjPapaHoLQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqOtr1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqlV6)LJjmjf4bi0ZNAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOPtOvBNMnfeA5v)VCmHjPapaHw90KAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOLx9)YXeMKc8aeA1ttQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHMoHwTDA2uqOLx9)YXeMKc8ae6uMQAj0PHhQG6GTqB(rdiowAnxOpxOn)ObehlTmiiPbSnxOLx9)YXeMimjn38W83mZpZKMrTeAHE2gqO5DfVoH26LqBoSwqGHL5cDbZRhVGTqV8oi0078oDWwOXnumblMWKuGhGqNs1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlFk)lhtyskWdqOtr1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlV6)LJjmjf4bi0QHAj0PHhQG6GTqB(rdiowAnxOpxOn)ObehlTmiiPbSnxOLpL)LJjmjf4bi0QD1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlFk)lhtyIWK0CZdZFZm)mtAg1sOf6zBaHM3v86eARxcT5KdMl0fmVE8c2c9Y7GqtVZ70bBHg3qXeSyctsbEacT6QLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHw(u(xoMWKuGhGqRUAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOLx9)YXeMKc8ae6uQwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5t5F5yctsbEacDkQwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5t5F5yctsbEacDkQwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5v)VCmHjPapaHE(ulHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8Q)xoMWKuGhGqRgQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqONNQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqOv7QLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqOttQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqON3QLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHw(u(xoMWKuGhGqREQQLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHw(u(xoMWKuGhGqREkQwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5t5F5yctsbEacT6Pj1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlV6)LJjmjf4bi0QNMulHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8Q)xoMWKuGhGqNYuQwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5v)VCmHjPapaHoLPuTe60WdvqDWwOnVEby9AcyP1CH(CH286fG1RjGLwgeK0a2Ml0YR(F5yctsbEacDktr1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlV6)LJjmjf4bi0PmfvlHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8Q)xoMWeHjP5MhM)Mz(zM0mQLql0Z2acnVR41j0wVeAZl)OJ7H5cDbZRhVGTqV8oi0078oDWwOXnumblMWKuGhGqRUAj0PHhQG6GTqB(rdiowAnxOpxOn)ObehlTmiiPbSnxOLx9)YXeMKc8ae6uQwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5v)VCmHjPapaHE(ulHon8qfuhSfAZpAaXXsR5c95cT5hnG4yPLbbjnGT5cT8Q)xoMWKuGhGqRgQLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHwE1)lhtyskWdqON3QLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHwE1)lhtyskWdqOtzQQLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHwE1)lhtyskWdqOt58PwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5v)VCmHjPapaHoLQHAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOLx9)YXeMimjn38W83mZpZKMrTeAHE2gqO5DfVoH26LqB(gS0BCMl0fmVE8c2c9Y7GqtVZ70bBHg3qXeSyctsbEacDkvlHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cnDcTA70SPGqlV6)LJjmjf4bi0POAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOPtOvBNMnfeA5v)VCmHjPapaHE(ulHon8qfuhSfAdEpne6v6Xr)f608j0Nl0PWJe6nxfFX9qODfOOZlHw(FKtOLx9)YXeMimjn38W83mZpZKMrTeAHE2gqO5DfVoH26LqBUsbyVlrN5cDbZRhVGTqV8oi0078oDWwOXnumblMWKuGhGqNs1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqlV6)LJjmjf4bi0POAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOLx9)YXeMKc8aeA1vd1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqtNqR2onBki0YR(F5yctsbEacT6QD1sOtdpub1bBH2CSh7h)yP1CH(CH2CSh7h)yPLbbjnGT5cT8Q)xoMWKuGhGqNs1qTe60WdvqDWwOnVEby9AcyP1CH(CH286fG1RjGLwgeK0a2Ml00j0QTtZMccT8Q)xoMWKuGhGqNY5PAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOPtOvBNMnfeA5v)VCmHjPapaHoftvTe60WdvqDWwOn)ObehlTMl0Nl0MF0aIJLwgeK0a2Ml0YNY)YXeMKc8ae6umv1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqlV6)LJjmjf4bi0Z38PwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA6eA12PztbHwE1)lhtyskWdqONp1qTe60WdvqDWwOnVEby9AcyP1CH(CH286fG1RjGLwgeK0a2Ml00j0QTtZMccT8Q)xoMWeHjP5MhM)Mz(zM0mQLql0Z2acnVR41j0wVeAZXUp2EsSmxOlyE94fSf6L3bHMEN3Pd2cnUHIjyXeMKc8aeA1vlHon8qfuhSfAZpAaXXsR5c95cT5hnG4yPLbbjnGT5cT8P8VCmHjPapaHwD1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqlV6)LJjmjf4bi0PuTe60WdvqDWwOn)ObehlTMl0Nl0MF0aIJLwgeK0a2Ml0YNY)YXeMKc8ae6uQwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5v)VCmHjPapaHofvlHon8qfuhSfAZpAaXXsR5c95cT5hnG4yPLbbjnGT5cT8P8VCmHjPapaHofvlHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8Q)xoMWKuGhGqpFQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqONNQLqNgEOcQd2cT5hnG4yP1CH(CH28JgqCS0YGGKgW2CHw(u(xoMWKuGhGqNMulHon8qfuhSfAZpAaXXsR5c95cT5hnG4yPLbbjnGT5cT8P8VCmHjPapaHEERwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5t5F5yctsbEacT6QRwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5t5F5yctsbEacT6ZNAj0PHhQG6GTqB(rdiowAnxOpxOn)ObehlTmiiPbSnxOLx9)YXeMKc8aeA1vd1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlV6)LJjmrysAU5H5VzMFMjnJAj0c9SnGqZ7kEDcT1lH28vdvWgH3lZf6cMxpEbBHE5DqOP35D6GTqJBOycwmHjPapaHwD1sOtdpub1bBH28JgqCS0AUqFUqB(rdiowAzqqsdyBUqlFk)lhtyskWdqOtr1sOtdpub1bBH286fG1RjGLwZf6ZfAZRxawVMawAzqqsdyBUqlV6)LJjmjf4bi0QNIQLqNgEOcQd2cT51laRxtalTMl0Nl0MxVaSEnbS0YGGKgW2CHwE1)lhtyskWdqOvF(ulHon8qfuhSfAZRxawVMawAnxOpxOnVEby9AcyPLbbjnGT5cT8Q)xoMWKuGhGqRUAOwcDA4HkOoyl0MxVaSEnbS0AUqFUqBE9cW61eWsldcsAaBZfA5v)VCmHjPapaHwD1UAj0PHhQG6GTqBE9cW61eWsR5c95cT51laRxtalTmiiPbSnxOLx9)YXeMimjn38W83mZpZKMrTeAHE2gqO5DfVoH26LqBo1rlfQBUqxW86Xlyl0lVdcn9oVthSfACdftWIjmjf4bi0QRwcDA4HkOoyl0MF0aIJLwZf6ZfAZpAaXXsldcsAaBZfA5v)VCmHjctMF6kEDWwOvxDHMWh3dHEWx3IjmjBqVRXRSHbV)g0X9inkYEzdLYT8bKnuBe608qtGqppuykaHjQnc9mUkOlbLqNs1WuHoLPMYufMimrTrON)GURceAvuXjPbWOoAPqDHMhcTLu5Lq7wHEb3XJPfJ6OLc1fA5Xna2mHoD)vc9sbWcTRCCpwYXeMO2i0QTu20bBHMhhubne6gk2dEmj0UvOvrfNKgaRHubixbcyl0Nl0sGqRUqN0aHqVG74X0IrD0sH6cDRqRotyIAJqR2Abc9LUchtdH2G3tdHUHI9GhtcTBfACdfbmeAECqvpLJ7HqZJ1b0wODRqBoMcmmqe(4EyotyIWecFCpwmLcWExIUwvuXjPbyAqDOvPaL3yGavUPUsBbl4mDdw6nU2ufMq4J7XIPua27s09B7pQOItsdW0G6qRsbkVXabQCtDL2fCMQIgpOvDt52wvuXjPbWukq5ngiqL3MQS6fG1RjGT4knEGwNxDze(4QaeeqNdRVsPWecFCpwmLcWExIUFB)rfvCsAaMguhAvkq5ngiqLBQR0UGZuv04bTQBk32QIkojnaMsbkVXabQ82uLvVaSEnbSfxPXd068Qld7QGGIJfaU8HxBze(4QaeeqNdRVuxycHpUhlMsbyVlr3VT)OIkojnatdQdTkfO8gdeOYn1vAxWzQkA8G2unLBBvrfNKgatPaL3yGavEBQcti8X9yXuka7Dj6(T9hvuXjPbyAqDOTHubixbcyBQR0UGZuv04bTPkmHWh3JftPaS3LO732FurfNKgGPb1H2gsfGCfiGTPUs7cotvrJh0QUPCBRkQ4K0aynKka5kqa72uLr4JRcqqaDoS(kLcti8X9yXuka7Dj6(T9hvuXjPbyAqDOTHubixbcyBQR0UGZuv04bTQBk32QIkojnawdPcqUceWUnvzQOItsdGPuGYBmqGkVvDHje(4ESykfG9UeD)2(JkQ4K0amnOo0A5bnqsVkm1vAxWzQkA8G2ufMq4J7XIPua27s09B7pQOItsdW0G6qBTqD6pAddkDK1l05x3uxPTGfCMUbl9gxRAimHWh3JftPaS3LO732FurfNKgGPb1H2AH60F0ggu6iRxOYvm1vAlybNPBWsVX1Qgcti8X9yXuka7Dj6(T9hvuXjPbyAqDOTwOo9hTHbLoY6fIum1vAlybNPBWsVX1MYufMq4J7XIPua27s09B7pQOItsdW0G6qlPG60F0ggu6iRxOZVUPUsBbl4mDdw6nUw1tvycHpUhlMsbyVlr3VT)OIkojnatdQdTLRG60F0ggu6iRxOZVUPUsBbl4mDdw6nU2uMQWecFCpwmLcWExIUFB)rfvCsAaMguhAp)6Oo9hTHbLoY6fIum1vAlybNPBWsVX1MQWecFCpwmLcWExIUFB)rfvCsAaMguhAp)6Oo9hTHbLoY6fIum1vAxWzQkA8G2u0uUTvfvCsAaSZVoQt)rByqPJSEHiL2uLvVaSEnbSnFH5kdEqv6iS37uSfMq4J7XIPua27s09B7pQOItsdW0G6q75xh1P)OnmO0rwVqKIPUs7cotvrJh0QUAyk32QIkojna25xh1P)OnmO0rwVqKsBQYWUkiO4ybFQ5qwceMq4J7XIPua27s09B7pQOItsdW0G6q75xh1P)OnmO0rwVqKIPUs7cotvrJh0QUAyk32QIkojna25xh1P)OnmO0rwVqKsBQYWESF8JrfMcaPu(MpLUmcFCvaccOZH1CPOWecFCpwmLcWExIUFB)rfvCsAaMguhAp)6Oo9hTHbLoY6fIum1vAxWzQkA8G2umvt52wvuXjPbWo)6Oo9hTHbLoY6fIuAtvgSwqGbMk(I7bYTifOSa(4EW68WlHje(4ESykfG9UeD)2(JkQ4K0amnOo0E(1rD6pAddkDK1lePyQR0UGZuv04bTQHPCBRkQ4K0ayNFDuN(J2WGshz9crkTPkmHWh3JftPaS3LO732FurfNKgGPb1H2ZVoQt)rByqPJSEHkxXuxPTGfCMUbl9gxBktvycHpUhlMsbyVlr3VT)OIkojnatdQdTsuv0eG6uqif8zQR0wWcot3GLEJRnvHje(4ESykfG9UeD)2(JkQ4K0amnOo0krvrtaQtbHuWNPUs7cotvrJh0k)8m15xY3P1bv6iv04bZ)QNAQYjNPCBRkQ4K0aysuv0eG6uqif81MQmSRcckowWNAoKLaHje(4ESykfG9UeD)2(JkQ4K0amnOo0krvrtaQtbHuWNPUs7cotvrJh0kFAk15xY3P1bv6iv04bZ)QNAQYjNPCBRkQ4K0aysuv0eG6uqif81MQWecFCpwmLcWExIUFB)rfvCsAaMguhAjfuNh8(RJ6uqif8zQR0wWcot3GLEJRnvHje(4ESykfG9UeD)2(JkQ4K0amnOo0skOop49xh1PGqk4ZuxPDbNPQOXdAvJunLBBvrfNKgaJuqDEW7VoQtbHuWxBQYQxawVMa2MVWCLbpOkDe27Dk2cti8X9yXuka7Dj6(T9hvuXjPbyAqDOLuqDEW7VoQtbHuWNPUs7cotvrJh0QgPAk32QIkojnagPG68G3FDuNccPGV2uLvVaSEnbSPIVgPJ4yoEacti8X9yXuka7Dj6(T9hvuXjPbyAqDOLuqDEW7VoQtbHuWNPUs7cotvrJh0QUAyk32QIkojnagPG68G3FDuNccPGV2ufMq4J7XIPua27s09B7pQOItsdW0G6q75xh1P)iCdvtWYuxPTGfCMUbl9gxBkfMq4J7XIPua27s09B7pQOItsdW0G6qlpub1bBKRabuM6kTfSGZ0nyP34AtvycHpUhlMsbyVlr3VT)OIkojnatdQdT8qfuhSrUceqzQR0UGZuv04bTQBk32QIkojnagpub1bBKRabuTPk7ObehREbGClsXtGsM8hnG4yuHPaqaUX)8rnXUkiO4yMLEXPqozYRMyxfeuCSaWLp8A)5dHpUkabb05WQv9pFQxawVMa2IR04bADE1LtycHpUhlMsbyVlr3VT)OIkojnatdQdT8qfuhSrUceqzQR0UGZuv04bTPAk32QIkojnagpub1bBKRabuTPkmHWh3JftPaS3LO732FurfNKgGPb1Hwsb5b6TatDL2fCMQIgpOfMxpUIcSzDctsfGwnaCO(BXXF(aZRhxrb2SPbT5051cjr7j4ZhyE94kkWMnnOnNoVwOoSPXG7XNpW86XvuGnBtLzD3d0gWMHuExblmey4ZhyE94kkWMXJfUEhjna086rX96OnOIJHpFG51JROaB2YFJbChpMq1tk9pFG51JROaB26fsd33iQdxt6R7ZhyE94kkWMLqMbbulKT8y)5dmVECffyZSdQdi3IKO7gGWecFCpwmLcWExIUFB)rfvCsAaMguhAjhqNFDuN(JWnunbltDL2cwWz6gS0BCTPuycHpUhlMsbyVlr3VT)OIkojnatdQdTnKka5kqaBtDL2fCMQIgpOvDt52wvuXjPbWAivaYvGa2TPkBb3XJPfJ6OLc1BvxycHpUhlMsbyVlr3VT)OIkojnatdQdTGkhPGptDL2cwWz6gS0BCTQRgcti8X9yXuka7Dj6(T9h7GwMjmHWh3JftPaS3LO732FSUVfMq4J7XIPua27s09B7p0BQdXrh3dHje(4ESykfG9UeD)2(dvykaKL68bNkHje(4ESykfG9UeD)2(dvykaepoyma8jmHWh3JftPaS3LO732FWEm)(vaQtbHMGUWecFCpwmLcWExIUFB)zfKYQXp06OBjmHWh3JftPaS3LO732F68Q8cX70eimHWh3JftPaS3LO732FSLVojFCMYTTQPkQ4K0aykfO8gdeOYBvxw9cW61eW28fMRm4bvPJWEVtXwycHpUhlMsbyVlr3VT)qfMcajnO1zk32QMQOItsdGPuGYBmqGkVvDzQz9cW61eW28fMRm4bvPJWEVtXwycHpUhlMsbyVlr3VT)aQCmDCpmLBBvrfNKgatPaL3yGavER6cteMq4J7X632FW(loOwkWyyk32EunbhBdspRLHP1XJjwbe(eMq4J7X632FurfNKgGPb1H2gsfGCfiGTPUs7cotvrJh0QUPCBRkQ4K0aynKka5kqa75AtvMsbQqt4ntDgOYX0X9qMAwVaSEnbSfxPXd068QlmHWh3J1VT)OIkojnatdQdTnKka5kqaBtDL2fCMQIgpOvDt52wvuXjPbWAivaYvGa2Z1MQmPN1YOctbGu8eOyBpjKHDFS9KGrfMcaP4jqXkOt8y9vQYQxawVMa2IR04bADE1fMq4J7X632FurfNKgGPb1HwlpObs6vHPUs7cotvrJh0QUPCBR0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2mzQP0ZAz1Bai3IUMcGf7PiZYNAoubDIhR5ALx(ofuA(i8X9GrfMcajnO1XW(6KB(NWh3dgvykaK0Gwhd(d43bOJ3b5eMq4J7X632FW0yGi8X9an4RZ0G6q7QHkyJW7LWecFCpw)2(dMgdeHpUhObFDMguhAH1ccmSeMq4J7X632FW0yGi8X9an4RZ0G6ql5GPCBlHpUkabb05W6RukmHWh3J1VT)GPXar4J7bAWxNPb1HwxbcOmLBBvrfNKgaRHubixbcypxBQcti8X9y9B7pyAmqe(4EGg81zAqDOL6OLc1nLBBxWD8yAXOoAPq9w1fMq4J7X632FW0yGi8X9an4RZ0G6ql29X2tILWecFCpw)2(dMgdeHpUhObFDMguhAl)OJ7HPCBRkQ4K0aywEqdK0RI2ufMq4J7X632FW0yGi8X9an4RZ0G6qRLh0aj9QWuUTvfvCsAamlpObs6vrR6cti8X9y9B7pyAmqe(4EGg81zAqDOT7QGoeNWeHjQncnHpUhlg1rlfQ3IPaddeHpUhMYTTe(4EWavoMoUhmCdfbm4XKSofetbFF1oVvdHje(4ESyuhTuO(VT)aQCmDCpmLBB7uqmf8nxRkQ4K0ayGkhPGpzYJDFS9KGD(d3GCl6AauNM4Sc6epwZ1s4J7bdu5y64EWG)a(Da64D4ZhS7JTNemQWuaifpbkwbDIhR5Aj8X9GbQCmDCpyWFa)oaD8o85J8hnG4y1laKBrkEcuYWUp2EsWQxai3Iu8eOyf0jESMRLWh3dgOYX0X9Gb)b87a0X7GCYjt6zTS6faYTifpbk22tczspRLrfMcaP4jqX2EsiBdspRLD(d3GCl6AauNM4STNecti8X9yXOoAPq9FB)zd01i5vaMYTTy3hBpjyuHPaqkEcuSc6epwTPktEPN1YQxai3Iu8eOyBpjKjp29X2tc25pCdYTORbqDAIZkOt8y9LkQ4K0ayKcQt)rByqPJSEHo)6F(GDFS9KGD(d3GCl6AauNM4Sc6epwTPkNCcti8X9yXOoAPq9FB)PZRYRfYTOZRoeNPCBl29X2tcgvykaKINafRGoXJvBQYKx6zTS6faYTifpbk22tczYJDFS9KGD(d3GCl6AauNM4Sc6epwFPIkojnagPG60F0ggu6iRxOZV(Npy3hBpjyN)Wni3IUga1PjoRGoXJvBQYjNWecFCpwmQJwku)32FkAZP4qlfQmtycHpUhlg1rlfQ)B7pRgU94XesXtGYuUTv6zTmQWuaifpbk22tczy3hBpjyuHPaqkEcuSREaQGoXJ1xe(4EWwnC7XJjKINafdVlzspRLvVaqUfP4jqX2Esid7(y7jbREbGClsXtGID1dqf0jES(IWh3d2QHBpEmHu8eOy4DjBdspRLD(d3GCl6AauNM4STNecti8X9yXOoAPq9FB)PEbGClsXtGYuUTv6zTS6faYTifpbk22tczy3hBpjyuHPaqkEcuSc6epwFLQWecFCpwmQJwku)32Fo)HBqUfDnaQttCt52w5XUp2EsWOctbGu8eOyf0jESAtvM0ZAz1laKBrkEcuSTNeY95JsbQqt4ntDw9ca5wKINaLWecFCpwmQJwku)32Fo)HBqUfDnaQttCt52wS7JTNemQWuaifpbkwbDIhR5uJuLj9Sww9ca5wKINafB7jHmyTGadmv8f3dKBrkqzb8X9GbbjnGTWecFCpwmQJwku)32FOctbGu8eOmLBBLEwlREbGClsXtGIT9Kqg29X2tc25pCdYTORbqDAIZkOt8y9LkQ4K0ayKcQt)rByqPJSEHo)6cti8X9yXOoAPq9FB)HkmfasIQIMat52wPN1YOctbGu8eOypfzspRLrfMcaP4jqXkOt8ynxlHpUhmQWuaOoFT4dyXG)a(Da64DqM0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2mHje(4ESyuhTuO(VT)qfMca5LKPCBR0ZAzuHPaq4gQMa26iSzZj9SwgvykaeUHQjG1P)O1ryZKj9Sww9ca5wKINafB7jHmPN1YOctbGu8eOyBpjKTbPN1Yo)HBqUfDnaQttC22tcHje(4ESyuhTuO(VT)qfMcajrvrtGPCBR0ZAz1laKBrkEcuSTNeYKEwlJkmfasXtGIT9Kq2gKEwl78hUb5w01aOonXzBpjKj9SwgvykaeUHQjGTocBwR0ZAzuHPaq4gQMawN(JwhHntycHpUhlg1rlfQ)B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8zkUH4rR6McunshHBiEG42wPN1YWdGkmToEmHWnueWGT9KqM8spRLrfMcaP4jqXEkF(i9Sww9ca5wKINaf7P85d29X2tcgOYX0X9GvaTtxoHje(4ESyuhTuO(VT)qfMca15RfFalt52w1KMhHIFaJkmfas517WGhtmiiPbS)8r6zTm8aOctRJhtiCdfbmyBpjmf3q8OvDtbQgPJWnepqCBR0ZAz4bqfMwhpMq4gkcyW2EsitEPN1YOctbGu8eOypLpFKEwlREbGClsXtGI9u(8b7(y7jbdu5y64EWkG2PlNWecFCpwmQJwku)32FavoMoUhMYTTspRLvVaqUfP4jqX2Esit6zTmQWuaifpbk22tczBq6zTSZF4gKBrxdG60eNT9KqycHpUhlg1rlfQ)B7puHPaqEjzk32k9SwgvykaeUHQjGTocB2CspRLrfMcaHBOAcyD6pADe2mHje(4ESyuhTuO(VT)qfMcajrvrtGWecFCpwmQJwku)32FOctbGKg06eMimHWh3JfJCO1w(6K8Xzk32wVaSEnbSnFH5kdEqv6iS37uSLHDFS9KGj9Sw0MVWCLbpOkDe27Dk2ScOD6YKEwlBZxyUYGhuLoc79ofBKT81X2EsitEPN1YOctbGu8eOyBpjKj9Sww9ca5wKINafB7jHSni9Sw25pCdYTORbqDAIZ2EsiNmS7JTNeSZF4gKBrxdG60eNvqN4XQnvzYl9SwgvykaeUHQjGTocB2CTQOItsdGroGo)6Oo9hHBOAcwYKx(JgqCS6faYTifpbkzy3hBpjy1laKBrkEcuSc6epwZ1oH3YWUp2EsWOctbGu8eOyf0jES(sfvCsAaSZVoQt)rByqPJSEHif5(8rE18ObehREbGClsXtGsg29X2tcgvykaKINafRGoXJ1xQOItsdGD(1rD6pAddkDK1lePi3Npy3hBpjyuHPaqkEcuSc6epwZ1oH3YjNWecFCpwmYHFB)XYlajnO1zk32kF9cW61eW28fMRm4bvPJWEVtXwg29X2tcM0ZArB(cZvg8GQ0ryV3PyZkG2Plt6zTSnFH5kdEqv6iS37uSrwEbSTNeYukqfAcVzQZSLVojFCY95J81laRxtaBZxyUYGhuLoc79ofBzhVdTPkNWecFCpwmYHFB)Xw(6qHRImLBBRxawVMa2uXxJ0rCmhpazy3hBpjyuHPaqkEcuSc6epwFLIPkd7(y7jb78hUb5w01aOonXzf0jESAtvM8spRLrfMcaHBOAcyRJWMnxRkQ4K0ayKdOZVoQt)r4gQMGLm5L)ObehREbGClsXtGsg29X2tcw9ca5wKINafRGoXJ1CTt4TmS7JTNemQWuaifpbkwbDIhRVurfNKga78RJ60F0ggu6iRxisrUpFKxnpAaXXQxai3Iu8eOKHDFS9KGrfMcaP4jqXkOt8y9LkQ4K0ayNFDuN(J2WGshz9crkY95d29X2tcgvykaKINafRGoXJ1CTt4TCYjmHWh3JfJC432FSLVou4Qit5226fG1RjGnv81iDehZXdqg29X2tcgvykaKINafRGoXJvBQYKxE5XUp2EsWo)HBqUfDnaQttCwbDIhRVurfNKgaJuqD6pAddkDK1l05xxM0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2m5(8rES7JTNeSZF4gKBrxdG60eNvqN4XQnvzspRLrfMcaHBOAcyRJWMnxRkQ4K0ayKdOZVoQt)r4gQMGLCYjt6zTS6faYTifpbk22tc5eMq4J7XIro8B7pN)Wni3IUga1PjUPCBB9cW61eWwCLgpqRZRUmLcuHMWBM6mqLJPJ7HWecFCpwmYHFB)HkmfasXtGYuUTTEby9AcylUsJhO15vxM8kfOcnH3m1zGkhth3JpFukqfAcVzQZo)HBqUfDnaQttC5eMq4J7XIro8B7pGkhth3dt522J3HVsXuLvVaSEnbSfxPXd068Qlt6zTmQWuaiCdvtaBDe2S5AvrfNKgaJCaD(1rD6pc3q1eSKHDFS9KGD(d3GCl6AauNM4Sc6epwTPkd7(y7jbJkmfasXtGIvqN4XAU2j8wycHpUhlg5WVT)aQCmDCpmLBBpEh(kftvw9cW61eWwCLgpqRZRUmS7JTNemQWuaifpbkwbDIhR2uLjV8YJDFS9KGD(d3GCl6AauNM4Sc6epwFPIkojnagPG60F0ggu6iRxOZVUmPN1YOctbGWnunbS1ryZALEwlJkmfac3q1eW60F06iSzY95J8y3hBpjyN)Wni3IUga1PjoRGoXJvBQYKEwlJkmfac3q1eWwhHnBUwvuXjPbWihqNFDuN(JWnunbl5KtM0ZAz1laKBrkEcuSTNeYzkpoOQNYH42wPN1YwCLgpqRZRoBDe2SwPN1YwCLgpqRZRoRt)rRJWMzkpoOQNYH49oS50bTQlmHWh3JfJC432F68Q8AHCl68QdXzk32kp29X2tcgvykaKINafRGoXJ1xZNA85d29X2tcgvykaKINafRGoXJ1CTPOCYWUp2EsWo)HBqUfDnaQttCwbDIhR2uLjV0ZAzuHPaq4gQMa26iSzZ1QIkojnag5a68RJ60FeUHQjyjtE5pAaXXQxai3Iu8eOKHDFS9KGvVaqUfP4jqXkOt8ynx7eEld7(y7jbJkmfasXtGIvqN4X6l1qUpFKxnpAaXXQxai3Iu8eOKHDFS9KGrfMcaP4jqXkOt8y9LAi3Npy3hBpjyuHPaqkEcuSc6epwZ1oH3YjNWecFCpwmYHFB)POnNIdTuOYmt52wS7JTNeSZF4gKBrxdG60eNvqN4XAo4pGFhGoEhKjV0ZAzuHPaq4gQMa26iSzZ1QIkojnag5a68RJ60FeUHQjyjtE5pAaXXQxai3Iu8eOKHDFS9KGvVaqUfP4jqXkOt8ynx7eEld7(y7jbJkmfasXtGIvqN4X6lvuXjPbWo)6Oo9hTHbLoY6fIuK7Zh5vZJgqCS6faYTifpbkzy3hBpjyuHPaqkEcuSc6epwFPIkojna25xh1P)OnmO0rwVqKICF(GDFS9KGrfMcaP4jqXkOt8ynx7eElNCcti8X9yXih(T9NI2Cko0sHkZmLBBXUp2EsWOctbGu8eOyf0jESMd(d43bOJ3bzYlV8y3hBpjyN)Wni3IUga1PjoRGoXJ1xQOItsdGrkOo9hTHbLoY6f68Rlt6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMCF(ip29X2tc25pCdYTORbqDAIZkOt8y1MQmPN1YOctbGWnunbS1ryZMRvfvCsAamYb05xh1P)iCdvtWso5Kj9Sww9ca5wKINafB7jHCcti8X9yXih(T9NnqxJKxbyk32IDFS9KGrfMcaP4jqXkOt8y1MQm5LxES7JTNeSZF4gKBrxdG60eNvqN4X6lvuXjPbWifuN(J2WGshz9cD(1Lj9SwgvykaeUHQjGTocBwR0ZAzuHPaq4gQMawN(JwhHntUpFKh7(y7jb78hUb5w01aOonXzf0jESAtvM0ZAzuHPaq4gQMa26iSzZ1QIkojnag5a68RJ60FeUHQjyjNCYKEwlREbGClsXtGIT9KqoHje(4ESyKd)2(Z5pCdYTORbqDAIBk32k9SwgvykaeUHQjGTocB2CTQOItsdGroGo)6Oo9hHBOAcwYKx(JgqCS6faYTifpbkzy3hBpjy1laKBrkEcuSc6epwZ1oH3YWUp2EsWOctbGu8eOyf0jES(sfvCsAaSZVoQt)rByqPJSEHif5(8rE18ObehREbGClsXtGsg29X2tcgvykaKINafRGoXJ1xQOItsdGD(1rD6pAddkDK1lePi3Npy3hBpjyuHPaqkEcuSc6epwZ1oH3YjmHWh3JfJC432FOctbGu8eOmLBBLxES7JTNeSZF4gKBrxdG60eNvqN4X6lvuXjPbWifuN(J2WGshz9cD(1Lj9SwgvykaeUHQjGTocBwR0ZAzuHPaq4gQMawN(JwhHntUpFKh7(y7jb78hUb5w01aOonXzf0jESAtvM0ZAzuHPaq4gQMa26iSzZ1QIkojnag5a68RJ60FeUHQjyjNCYKEwlREbGClsXtGIT9KqycHpUhlg5WVT)uVaqUfP4jqzk32k9Sww9ca5wKINafB7jHm5Lh7(y7jb78hUb5w01aOonXzf0jES(kLPkt6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMCF(ip29X2tc25pCdYTORbqDAIZkOt8y1MQmPN1YOctbGWnunbS1ryZMRvfvCsAamYb05xh1P)iCdvtWso5Kjp29X2tcgvykaKINafRGoXJ1xQNYpF2G0ZAzN)Wni3IUga1Pjo7PiNWecFCpwmYHFB)z1WThpMqkEcuMYTTspRLrfMcaP4jqX2Esid7(y7jbJkmfasXtGID1dqf0jES(IWh3d2QHBpEmHu8eOy4Djt6zTS6faYTifpbk22tczy3hBpjy1laKBrkEcuSREaQGoXJ1xe(4EWwnC7XJjKINafdVlzBq6zTSZF4gKBrxdG60eNT9KqycHpUhlg5WVT)OuWccmGClQZJTPCBR0ZAzBGUgjVcG9uKTbPN1Yo)HBqUfDnaQttC2tr2gKEwl78hUb5w01aOonXzf0jESMRv6zTmLcwqGbKBrDESzD6pADe2S5FcFCpyuHPaqsdADm4pGFhGoEheMq4J7XIro8B7puHPaqsdADMYTTspRLTb6AK8ka2trM8YF0aIJvWYdkWGmcFCvaccOZH1CZNCF(q4JRcqqaDoSMtnKtM8Qz9cW61eWOctbGK8Uev7oe3NphvtWXAaACnmf89vkQgYjmHWh3JfJC432FwpfOcxfjmHWh3JfJC432FOctbG8sYuUTv6zTmQWuaiCdvtaBDe2S2ufMq4J7XIro8B7pbCnqHoORaRZuUTv(cSfSAiPb85JAECSz8ysozspRLrfMcaHBOAcyRJWM1k9SwgvykaeUHQjG1P)O1ryZeMq4J7XIro8B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8jREby9AcyuHPaq8WYd(LUSJgqCmQRm4woMoUhYi8XvbiiGohwZLMeMq4J7XIro8B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8jt(6fG1RjGrfMcaXdlp4x6F(C0aIJrDLb3YX0X9qoze(4QaeeqNdR5udHje(4ESyKd)2(dvykae8xz4lUhMYTTspRLrfMcaHBOAcyRJWMnN0ZAzuHPaq4gQMawN(JwhHntycHpUhlg5WVT)qfMcab)vg(I7HPCBR0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2mzkfOcnH3m1zuHPaqsuv0eimHWh3JfJC432FOctbGKOQOjWuUTv6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMWecFCpwmYHFB)bu5y64EykpoOQNYH422ofetbFF1MMudt5Xbv9uoeV3HnNoOvDHjctuBe608xCV4hFEee63Ihtc9uXxJ0fAoMJhGqNWVgHMuycTARfi08tOt4xJqF(1fA)AGkHVaMWecFCpwmS7JTNeRwB5RdfUkYuUTTEby9AcytfFnshXXC8aKHDFS9KGrfMcaP4jqXkOt8y9vkMQmS7JTNeSZF4gKBrxdG60eNvqN4XQnvzYl9SwgvykaeUHQjGTocB2CTQOItsdGD(1rD6pc3q1eSKjV8hnG4y1laKBrkEcuYWUp2EsWQxai3Iu8eOyf0jESMRDcVLHDFS9KGrfMcaP4jqXkOt8y9LkQ4K0ayNFDuN(J2WGshz9crkY95J8Q5rdiow9ca5wKINaLmS7JTNemQWuaifpbkwbDIhRVurfNKga78RJ60F0ggu6iRxisrUpFWUp2EsWOctbGu8eOyf0jESMRDcVLtoHje(4ESyy3hBpjw)2(JT81Hcxfzk32wVaSEnbSPIVgPJ4yoEaYWUp2EsWOctbGu8eOyf0jESAtvM8Q5rdioged(uZbbS)8r(JgqCmig8PMdcylRtbXuW3xTQ9uLtozYlp29X2tc25pCdYTORbqDAIZkOt8y9L6Pkt6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMCF(ip29X2tc25pCdYTORbqDAIZkOt8y1MQmPN1YOctbGWnunbS1ryZAtvo5Kj9Sww9ca5wKINafB7jHSofetbFF1QIkojnagPG68G3FDuNccPGpHje(4ESyy3hBpjw)2(JT81j5JZuUTTEby9AcyB(cZvg8GQ0ryV3Pyld7(y7jbt6zTOnFH5kdEqv6iS37uSzfq70Lj9Sw2MVWCLbpOkDe27Dk2iB5RJT9KqM8spRLrfMcaP4jqX2Esit6zTS6faYTifpbk22tczBq6zTSZF4gKBrxdG60eNT9Kqozy3hBpjyN)Wni3IUga1PjoRGoXJvBQYKx6zTmQWuaiCdvtaBDe2S5AvrfNKga78RJ60FeUHQjyjtE5pAaXXQxai3Iu8eOKHDFS9KGvVaqUfP4jqXkOt8ynx7eEld7(y7jbJkmfasXtGIvqN4X6lvuXjPbWo)6Oo9hTHbLoY6fIuK7Zh5vZJgqCS6faYTifpbkzy3hBpjyuHPaqkEcuSc6epwFPIkojna25xh1P)OnmO0rwVqKICF(GDFS9KGrfMcaP4jqXkOt8ynx7eElNCcti8X9yXWUp2EsS(T9hlVaK0GwNPCBB9cW61eW28fMRm4bvPJWEVtXwg29X2tcM0ZArB(cZvg8GQ0ryV3PyZkG2Plt6zTSnFH5kdEqv6iS37uSrwEbSTNeYukqfAcVzQZSLVojFCctuBe65HrcL(sOFlqO78Q8Aj0j8RrOjfMqp)yf6ZVUqZxcDb0oDHMwcDcmgMk0DYmqOxVce6ZfAmToHMFcTey9ce6ZVotycHpUhlg29X2tI1VT)05v51c5w05vhIZuUTf7(y7jb78hUb5w01aOonXzf0jESAtvM0ZAzuHPaq4gQMa26iSzZ1QIkojna25xh1P)iCdvtWsg29X2tcgvykaKINafRGoXJ1CTt4TWecFCpwmS7JTNeRFB)PZRYRfYTOZRoeNPCBl29X2tcgvykaKINafRGoXJvBQYKxnpAaXXGyWNAoiG9NpYF0aIJbXGp1CqaBzDkiMc((QvTNQCYjtE5XUp2EsWo)HBqUfDnaQttCwbDIhRVurfNKgaJuqD6pAddkDK1l05xxM0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2m5(8rES7JTNeSZF4gKBrxdG60eNvqN4XQnvzspRLrfMcaHBOAcyRJWM1MQCYjt6zTS6faYTifpbk22tczDkiMc((QvfvCsAamsb15bV)6OofesbFctuBe65HrcL(sOFlqO3aDnsEfGqNWVgHMuyc98JvOp)6cnFj0fq70fAAj0jWyyQq3jZaHE9kqOpxOX06eA(j0sG1lqOp)6mHje(4ESyy3hBpjw)2(ZgORrYRamLBBXUp2EsWo)HBqUfDnaQttCwbDIhR2uLj9SwgvykaeUHQjGTocB2CTQOItsdGD(1rD6pc3q1eSKHDFS9KGrfMcaP4jqXkOt8ynx7eElmHWh3Jfd7(y7jX632F2aDnsEfGPCBl29X2tcgvykaKINafRGoXJvBQYKxnpAaXXGyWNAoiG9NpYF0aIJbXGp1CqaBzDkiMc((QvTNQCYjtE5XUp2EsWo)HBqUfDnaQttCwbDIhRVupvzspRLrfMcaHBOAcyRJWM1k9SwgvykaeUHQjG1P)O1ryZK7Zh5XUp2EsWo)HBqUfDnaQttCwbDIhR2uLj9SwgvykaeUHQjGTocBwBQYjNmPN1YQxai3Iu8eOyBpjK1PGyk47RwvuXjPbWifuNh8(RJ6uqif8jmrTrOvBTaHEPqLzcn3k0NFDHMITqtkcnvGq7HqJ3cnfBHoXdZpHwce6NIqB9sOhEmbLqFnui0xdi0D6VqVHbLUPcDNmJhtc96vGqNacDdPceA6e6bqRtOVexOPctbi04gQMGLqtXwOVg6e6ZVUqNqRW8tONF)wNq)wWMjmHWh3Jfd7(y7jX632FkAZP4qlfQmZuUTf7(y7jb78hUb5w01aOonXzf0jES(sfvCsAaSAH60F0ggu6iRxOZVUmS7JTNemQWuaifpbkwbDIhRVurfNKgaRwOo9hTHbLoY6fIuKj)rdiow9ca5wKINaLm5XUp2EsWQxai3Iu8eOyf0jESMd(d43bOJ3HpFWUp2EsWQxai3Iu8eOyf0jES(sfvCsAaSAH60F0ggu6iRxOYvK7Zh18ObehREbGClsXtGsozspRLrfMcaHBOAcyRJWM9vkLTbPN1Yo)HBqUfDnaQttC22tczspRLvVaqUfP4jqX2Esit6zTmQWuaifpbk22tcHjQncTARfi0lfQmtOt4xJqtkcDsdecTIVwCPbWe65hRqF(1fA(sOlG2Pl00sOtGXWuHUtMbc96vGqFUqJP1j08tOLaRxGqF(1zcti8X9yXWUp2EsS(T9NI2Cko0sHkZmLBBXUp2EsWo)HBqUfDnaQttCwbDIhR5G)a(Da64DqM0ZAzuHPaq4gQMa26iSzZ1QIkojna25xh1P)iCdvtWsg29X2tcgvykaKINafRGoXJ1CYd)b87a0X7WVe(4EWo)HBqUfDnaQttCg8hWVdqhVdYjmHWh3Jfd7(y7jX632FkAZP4qlfQmZuUTf7(y7jbJkmfasXtGIvqN4XAo4pGFhGoEhKjV8Q5rdioged(uZbbS)8r(JgqCmig8PMdcylRtbXuW3xTQ9uLtozYlp29X2tc25pCdYTORbqDAIZkOt8y9LkQ4K0ayKcQt)rByqPJSEHo)6YKEwlJkmfac3q1eWwhHnRv6zTmQWuaiCdvtaRt)rRJWMj3NpYJDFS9KGD(d3GCl6AauNM4Sc6epwTPkt6zTmQWuaiCdvtaBDe2S2uLtozspRLvVaqUfP4jqX2EsiRtbXuW3xTQOItsdGrkOop49xh1PGqk4toHje(4ESyy3hBpjw)2(Z5pCdYTORbqDAIBk32IDFS9KGrfMcaP4jqXkOt8ynNAKQmyTGadmv8f3dKBrkqzb8X9G15HxctuBeA1wlqOp)6cDc)AeAsrO5wHMFMVe6e(1WdH(AaHUt)f6nmO0zc98JvOd)mvOFlqOt4xJqxUIqZTc91ac9rdioHMVe6JmdctfAk2cn)mFj0j8RHhc91acDN(l0ByqPZeMq4J7XIHDFS9Ky9B7pN)Wni3IUga1PjUPCBR0ZAzuHPaq4gQMa26iSzZ1QIkojna25xh1P)iCdvtWsg29X2tcgvykaKINafRGoXJ1CTWFa)oaD8oimHWh3Jfd7(y7jX632Fo)HBqUfDnaQttCt52wPN1YOctbGWnunbS1ryZMRvfvCsAaSZVoQt)r4gQMGLSJgqCS6faYTifpbkzy3hBpjy1laKBrkEcuSc6epwZ1c)b87a0X7GmS7JTNemQWuaifpbkwbDIhRVurfNKga78RJ60F0ggu6iRxisrycHpUhlg29X2tI1VT)C(d3GCl6AauNM4MYTTspRLrfMcaHBOAcyRJWMnxRkQ4K0ayNFDuN(JWnunblzYRMhnG4y1laKBrkEcuF(GDFS9KGvVaqUfP4jqXkOt8y9LkQ4K0ayNFDuN(J2WGshz9cvUICYWUp2EsWOctbGu8eOyf0jES(sfvCsAaSZVoQt)rByqPJSEHifHjQncTARfi0KIqZTc95xxO5lH2dHgVfAk2cDIhMFcTei0pfH26Lqp8yckH(AOqOVgqO70FHEddkDtf6ozgpMe61RaH(AOtOtaHUHubcne(BQrO7uqcnfBH(AOtOVgOaHMVe6WpHMgfq70fAsORxacTBfAfpbkHE7jbtycHpUhlg29X2tI1VT)qfMcaP4jqzk32IDFS9KGD(d3GCl6AauNM4Sc6epwFPIkojnagPG60F0ggu6iRxOZVUmPN1YOctbGWnunbS1ryZALEwlJkmfac3q1eW60F06iSzYKEwlREbGClsXtGIT9KqwNcIPGVVAvrfNKgaJuqDEW7VoQtbHuWNWe1gHwT1ce6YveAUvOp)6cnFj0Ei04TqtXwOt8W8tOLaH(Pi0wVe6Hhtqj0xdfc91acDN(l0ByqPBQq3jZ4XKqVEfi0xduGqZxH5NqtJcOD6cnj01laHE7jHqtXwOVg6eAsrOt8W8tOLaS3bHMur8bjnaHE)kEmj01laMWecFCpwmS7JTNeRFB)PEbGClsXtGYuUTv6zTmQWuaifpbk22tczy3hBpjyN)Wni3IUga1PjoRGoXJ1xQOItsdGvUcQt)rByqPJSEHo)6YKEwlJkmfac3q1eWwhHnRv6zTmQWuaiCdvtaRt)rRJWMjtES7JTNemQWuaifpbkwbDIhRVupLF(SbPN1Yo)HBqUfDnaQttC2troHje(4ESyy3hBpjw)2(ZQHBpEmHu8eOmLBBLEwlJkmfasXtGIT9Kqg29X2tcgvykaKINaf7QhGkOt8y9fHpUhSvd3E8ycP4jqXW7sM0ZAz1laKBrkEcuSTNeYWUp2EsWQxai3Iu8eOyx9aubDIhRVi8X9GTA42JhtifpbkgExY2G0ZAzN)Wni3IUga1PjoB7jHWe1gHonVPxCkulHE(ZqO5lHUtbj0nVyQsxOPyl0ZdFpFlHMkqOp3fA4VcelUkqOpxOFlqOv8UqFUqVMxpaMhbHMcHg(Ffj0KKqZdH(AaH(8Rl0j8y7jmHofGZ8Lq)wGqZpH(CHUtMbc9WteACdvtGqpp89sO5X6O4ycti8X9yXWUp2EsS(T9hLcwqGbKBrDESnLBBLEwlJkmfac3q1eWwhHnRnvzyxfeuCmZsV4uimrTrONXJ5xP5n9ItHAj0QTwGqR4DH(CHEnVEampccnfcn8)ksOjjHMhc91ac95xxOt4X2tycti8X9yXWUp2EsS(T9hLcwqGbKBrDESnLBB3G0ZAzN)Wni3IUga1Pjo7PiBdspRLD(d3GCl6AauNM4Sc6epwZr4J7bJkmfaQZxl(awm4pGFhGoEhKPMyxfeuCmZsV4uimrycHpUhlgSwqGHvR0W9nYTORbqqa90nLBBXUp2EsWo)HBqUfDnaQttCwbDIhR2uLj9SwgvykaeUHQjGTocB2CTQOItsdGD(1rD6pc3q1eSKHDFS9KGrfMcaP4jqXkOt8ynx7eE)5JLp1COc6epwZHDFS9KGrfMcaP4jqXkOt8yjmHWh3JfdwliWW632FKgUVrUfDnaccONUPCBl29X2tcgvykaKINafRGoXJvBQYKxnpAaXXGyWNAoiG9NpYF0aIJbXGp1CqaBzDkiMc((QvTN6NpQOItsdGrD0sH6TQlNCYKxES7JTNeSZF4gKBrxdG60eNvqN4X6lvuXjPbWifuN(J2WGshz9cD(1LjV0ZAzuHPaq4gQMa26iSzTspRLrfMcaHBOAcyD6pADe2SpFurfNKgaJ6OLc1Bvxo5(8rES7JTNeSZF4gKBrxdG60eNvqN4XQnvzspRLrfMcaHBOAcyRJWM1MQCYjt6zTS6faYTifpbk22tczDkiMc((QvfvCsAamsb15bV)6OofesbFcti8X9yXG1ccmS(T9NeVgBvapqfS8Gcmyk32IDFS9KGrfMcaP4jqXkOt8y9vRAKQmS7JTNeSZF4gKBrxdG60eNvqN4XAU2j8wM0ZAzuHPaq4gQMa26iSzZ1QIkojna25xh1P)iCdvtWs2rdiow9ca5wKINaLmS7JTNeS6faYTifpbkwbDIhR5ANWBzy3hBpjyuHPaqkEcuSc6epwFPIkojna25xh1P)OnmO0rwVqKIWecFCpwmyTGadRFB)jXRXwfWdublpOadMYTTy3hBpjyN)Wni3IUga1PjoRGoXJvBQYKEwlJkmfac3q1eWwhHnBUwvuXjPbWo)6Oo9hHBOAcwYWUp2EsWOctbGu8eOyf0jESMRDcV)8XYNAoubDIhR5WUp2EsWOctbGu8eOyf0jESeMq4J7XIbRfeyy9B7pjEn2QaEGky5bfyWuUTf7(y7jbJkmfasXtGIvqN4XQnvzYRMhnG4yqm4tnheW(Zh5pAaXXGyWNAoiGTSofetbFF1Q2t9ZhvuXjPbWOoAPq9w1LtozYlp29X2tc25pCdYTORbqDAIZkOt8y9LkQ4K0ayKcQt)rByqPJSEHo)6YKx6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocB2NpQOItsdGrD0sH6TQlNCF(ip29X2tc25pCdYTORbqDAIZkOt8y1MQmPN1YOctbGWnunbS1ryZAtvo5Kj9Sww9ca5wKINafB7jHSofetbFF1QIkojnagPG68G3FDuNccPGpHje(4ESyWAbbgw)2(Z0JQnNcKBr08iu(1yk32IDFS9KGD(d3GCl6AauNM4Sc6epwTPkt6zTmQWuaiCdvtaBDe2S5AvrfNKga78RJ60FeUHQjyjd7(y7jbJkmfasXtGIvqN4XAU2j8(ZhlFQ5qf0jESMd7(y7jbJkmfasXtGIvqN4XsycHpUhlgSwqGH1VT)m9OAZPa5wenpcLFnMYTTy3hBpjyuHPaqkEcuSc6epwTPktE18ObehdIbFQ5Ga2F(i)rdioged(uZbbSL1PGyk47Rw1EQF(OIkojnag1rlfQ3QUCYjtE5XUp2EsWo)HBqUfDnaQttCwbDIhRVurfNKgaJuqD6pAddkDK1l05xxM8spRLrfMcaHBOAcyRJWM1k9SwgvykaeUHQjG1P)O1ryZ(8rfvCsAamQJwkuVvD5K7Zh5XUp2EsWo)HBqUfDnaQttCwbDIhR2uLj9SwgvykaeUHQjGTocBwBQYjNmPN1YQxai3Iu8eOyBpjK1PGyk47RwvuXjPbWifuNh8(RJ6uqif8jmHWh3JfdwliWW632FWEGH4k6GnYoOoy6GhacVBNNMYTTspRLrfMcaP4jqX2Esit6zTS6faYTifpbk22tczBq6zTSZF4gKBrxdG60eNT9KqwNcID8oGoh1P)F1c)b87a0X7GWecFCpwmyTGadRFB)PasHhti7G6WYuUTv6zTmQWuaifpbk22tczspRLvVaqUfP4jqX2EsiBdspRLD(d3GCl6AauNM4STNeY6uqSJ3b05Oo9)Rw4pGFhGoEheMq4J7XIbRfeyy9B7pwh)wWgrZJqXpajbu3uUTv6zTmQWuaifpbk22tczspRLvVaqUfP4jqX2EsiBdspRLD(d3GCl6AauNM4STNecti8X9yXG1ccmS(T9hLxXTPZJjK0GwNPCBR0ZAzuHPaqkEcuSTNeYKEwlREbGClsXtGIT9Kq2gKEwl78hUb5w01aOonXzBpjeMq4J7XIbRfeyy9B7pfxrzaiEGwkegmLBBLEwlJkmfasXtGIT9KqM0ZAz1laKBrkEcuSTNeY2G0ZAzN)Wni3IUga1PjoB7jHWecFCpwmyTGadRFB)5Aa0lK8xSrwVWGPCBR0ZAzuHPaqkEcuSTNeYKEwlREbGClsXtGIT9Kq2gKEwl78hUb5w01aOonXzBpjeMq4J7XIbRfeyy9B7pDO7v6i3IgpmFJ2fq9LPCBR0ZAzuHPaqkEcuSTNeYKEwlREbGClsXtGIT9Kq2gKEwl78hUb5w01aOonXzBpjeMimHWh3JfZYdAGKEv8B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8zkUH4rR6cti8X9yXS8GgiPxf)2(dvykaK0GwNWecFCpwmlpObs6vXVT)qfMcajrvrtGWeHje(4ESyDxf0H4(T9hPbpmdrr6MYTTDxf0H4yB(6OadF1QEQcti8X9yX6UkOdX9B7pkfSGadi3I68ylmHWh3JfR7QGoe3VT)qfMca15RfFalt522URc6qCSnFDuGH5upvHje(4ESyDxf0H4(T9hQWuaiVKeMq4J7XI1DvqhI732FS8cqsdADcteMq4J7XI5kqavlOYX0X9WuUTv(6fG1RjGT4knEGwNx9pFQxawVMa2bDfVObkHkf5KD0aIJvVaqUfP4jqjd7(y7jbREbGClsXtGIvqN4X6RuLjV0ZAz1laKBrkEcuSTNeF(OuGk0eEZuNrfMcajrvrtGCcti8X9yXCfiG632FS8cqsdADMYTT1laRxtaBZxyUYGhuLoc79ofBzspRLT5lmxzWdQshH9ENInYw(6ypfHje(4ESyUceq9B7p2YxhkCvKPCBB9cW61eWMk(AKoIJ54biRtbXuW3xZB1qycHpUhlMRabu)2(ZgORrYRamLBBvZ6fG1RjGT4knEGwNxDHje(4ESyUceq9B7pfT5uCOLcvMzk322PGyk47R5lvHje(4ESyUceq9B7pRgU94XesXtGYuUTD5VHep2mlhgBKBrsdFT8(IbbjnGTWecFCpwmxbcO(T9hQWuaiVKmLBBvrfNKgaJhQG6GnYvGaQw1LHDFS9KGvVaqUfP4jqXkOt8y1MQWecFCpwmxbcO(T9hQWuaiPbTot52wvuXjPbW4HkOoyJCfiGQvDzy3hBpjy1laKBrkEcuSc6epwTPkt6zTmQWuaiCdvtaBDe2S5KEwlJkmfac3q1eW60F06iSzcti8X9yXCfiG632FQxai3Iu8eOmLBBvrfNKgaJhQG6GnYvGaQw1Lj9Sww9ca5wKINafB7jHWecFCpwmxbcO(T9NnqxJKxbyk32k9Sww9ca5wKINafB7jHWecFCpwmxbcO(T9NoVkVwi3IoV6qCMYTTspRLvVaqUfP4jqX2Es85JsbQqt4ntDgvykaKevfnbcti8X9yXCfiG632Fo)HBqUfDnaQttCt52wPN1YQxai3Iu8eOyBpj(8rPavOj8MPoJkmfasIQIMaHje(4ESyUceq9B7puHPaqkEcuMYTTkfOcnH3m1zN)Wni3IUga1PjUWecFCpwmxbcO(T9N6faYTifpbkt52wPN1YQxai3Iu8eOyBpjeMq4J7XI5kqa1VT)OuWccmGClQZJTPCB7gKEwl78hUb5w01aOonXzpfzBq6zTSZF4gKBrxdG60eNvqN4XAocFCpyuHPaqD(AXhWIb)b87a0X7GWecFCpwmxbcO(T9hQWuaiPbTot522TFSI2Cko0sHkZyf0jES(sn(8zdspRLv0MtXHwkuzgs1Beqrs8b)sNTocB2xPkmHWh3JfZvGaQFB)HkmfasAqRZuUTv6zTmLcwqGbKBrDESzpfzBq6zTSZF4gKBrxdG60eN9uKTbPN1Yo)HBqUfDnaQttCwbDIhR5Aj8X9GrfMcajnO1XG)a(Da64DqycHpUhlMRabu)2(dvykaKevfnbMYTTspRLvVaqUfP4jqXEkYWUp2EsWOctbGu8eOyfq70L1PGyk4BU5lvzspRLrfMcaHBOAcyRJWM1k9SwgvykaeUHQjG1P)O1ryZKPM1laRxtaBXvA8aToV6YuZ6fG1RjGDqxXlAGsOsrycHpUhlMRabu)2(dvykaKevfnbMYTTspRLvVaqUfP4jqXEkYKEwlJkmfasXtGIT9KqM0ZAz1laKBrkEcuSc6epwZ1oH3YKEwlJkmfac3q1eWwhHnRv6zTmQWuaiCdvtaRt)rRJWMjtfvCsAamEOcQd2ixbcOeMq4J7XI5kqa1VT)qfMca15RfFalt522ni9Sw25pCdYTORbqDAIZEkYoAaXXOctbGaCJltEPN1Y2aDnsEfaB7jXNpe(4QaeeqNdRw1Lt2gKEwl78hUb5w01aOonXzf0jES(IWh3dgvykauNVw8bSyWFa)oaD8oitE1KMhHIFaJkmfas517WGhtmiiPbS)8r6zTm8aOctRJhtiCdfbmyBpjKZuCdXJw1nfOAKoc3q8aXTTspRLHhavyAD8ycHBOiGbB7jHm5LEwlJkmfasXtGI9u(8rE18ObehZvbLINafSLjV0ZAz1laKBrkEcuSNYNpy3hBpjyGkhth3dwb0oD5KtoHje(4ESyUceq9B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8jd7(y7jbJkmfasXtGIvqN4XsM8spRLvVaqUfP4jqXEkF(i9SwgvykaKINaf7PiNP4gIhTQlmHWh3JfZvGaQFB)HkmfaYljt52wPN1YOctbGWnunbS1ryZMRvfvCsAaSZVoQt)r4gQMGLm5XUp2EsWOctbGu8eOyf0jES(s9u)8HWhxfGGa6CynxBkLtycHpUhlMRabu)2(dvykaK0GwNPCBR0ZAz1laKBrkEcuSNYNpDkiMc((sD1qycHpUhlMRabu)2(dOYX0X9WuUTv6zTS6faYTifpbk22tct5Xbv9uoe322PGyk47R20KAykpoOQNYH49oS50bTQlmHWh3JfZvGaQFB)HkmfasIQIMaHjctuBeAcFCpwSYp64E8B7pykWWar4J7HPCBlHpUhmqLJPJ7bd3qradEmjRtbXuW3xTZB1qM8Qz9cW61eWwCLgpqRZR(NpspRLT4knEGwNxD26iSzTspRLT4knEGwNxDwN(JwhHntoHje(4ESyLF0X9432FavoMoUhMYTTDkiMc(MRvfvCsAamqLJuWNm5XUp2EsWo)HBqUfDnaQttCwbDIhR5Aj8X9GbQCmDCpyWFa)oaD8o85d29X2tcgvykaKINafRGoXJ1CTe(4EWavoMoUhm4pGFhGoEh(8r(JgqCS6faYTifpbkzy3hBpjy1laKBrkEcuSc6epwZ1s4J7bdu5y64EWG)a(Da64Dqo5Kj9Sww9ca5wKINafB7jHmPN1YOctbGu8eOyBpjKTbPN1Yo)HBqUfDnaQttC22tct5Xbv9uoe322PGyk47R25TAitE1SEby9AcylUsJhO15v)ZhPN1YwCLgpqRZRoBDe2SwPN1YwCLgpqRZRoRt)rRJWMjNP84GQEkhI37WMth0QUWecFCpwSYp64E8B7pGkhth3dt5226fG1RjGT4knEGwNxDzy3hBpjyuHPaqkEcuSc6epwZ1s4J7bdu5y64EWG)a(Da64DqyIAJq)nvfnbcn3k08Z8LqF8oi0Nl0Vfi0NFDHMITqNacDdPce6ZDHUtr6cnUHQjyjmHWh3JfR8JoUh)2(dvykaKevfnbMYTTy3hBpjyN)Wni3IUga1PjoRaANUm5LEwlJkmfac3q1eWwhHn7lvuXjPbWo)6Oo9hHBOAcwYWUp2EsWOctbGu8eOyf0jESMRf(d43bOJ3b5eMq4J7XIv(rh3JFB)HkmfasIQIMat52wS7JTNeSZF4gKBrxdG60eNvaTtxM8spRLrfMcaHBOAcyRJWM9LkQ4K0ayNFDuN(JWnunblzhnG4y1laKBrkEcuYWUp2EsWQxai3Iu8eOyf0jESMRf(d43bOJ3bzy3hBpjyuHPaqkEcuSc6epwFPIkojna25xh1P)OnmO0rwVqKICcti8X9yXk)OJ7XVT)qfMcajrvrtGPCBl29X2tc25pCdYTORbqDAIZkG2PltEPN1YOctbGWnunbS1ryZ(sfvCsAaSZVoQt)r4gQMGLm5vZJgqCS6faYTifpbQpFWUp2EsWQxai3Iu8eOyf0jES(sfvCsAaSZVoQt)rByqPJSEHkxrozy3hBpjyuHPaqkEcuSc6epwFPIkojna25xh1P)OnmO0rwVqKICcti8X9yXk)OJ7XVT)qfMcajrvrtGPCB7gKEwlROnNIdTuOYmKQ3iGIK4d(LoBDe2S2ni9SwwrBofhAPqLzivVrafjXh8lDwN(JwhHntM8spRLrfMcaP4jqX2Es85J0ZAzuHPaqkEcuSc6epwZ1oH3YjtEPN1YQxai3Iu8eOyBpj(8r6zTS6faYTifpbkwbDIhR5ANWB5eMq4J7XIv(rh3JFB)HkmfasAqRZuUTD7hROnNIdTuOYmwbDIhRVstF(i)gKEwlROnNIdTuOYmKQ3iGIK4d(LoBDe2SVsv2gKEwlROnNIdTuOYmKQ3iGIK4d(LoBDe2S52G0ZAzfT5uCOLcvMHu9gbuKeFWV0zD6pADe2m5eMq4J7XIv(rh3JFB)HkmfasAqRZuUTv6zTmLcwqGbKBrDESzpfzBq6zTSZF4gKBrxdG60eN9uKTbPN1Yo)HBqUfDnaQttCwbDIhR5Aj8X9GrfMcajnO1XG)a(Da64DqycHpUhlw5hDCp(T9hQWuaOoFT4dyzk32UbPN1Yo)HBqUfDnaQttC2tr2rdiogvykaeGBCzYl9Sw2gORrYRayBpj(8HWhxfGGa6Cy1QUCYKFdspRLD(d3GCl6AauNM4Sc6epwFr4J7bJkmfaQZxl(awm4pGFhGoEh(8b7(y7jbtPGfeya5wuNhBwbDIhRVs9ZhSRcckoMzPxCkKtM8Qjnpcf)agvykaKYR3HbpMyqqsdy)5J0ZAz4bqfMwhpMq4gkcyW2EsiNP4gIhTQBkq1iDeUH4bIBBLEwldpaQW064Xec3qrad22tczYl9SwgvykaKINaf7P85J8Q5rdioMRckfpbkyltEPN1YQxai3Iu8eOypLpFWUp2EsWavoMoUhScOD6YjNCcti8X9yXk)OJ7XVT)qfMca15RfFalt52wPN1YWdGkmToEmXkGWNmPN1YG)kuSHnsXpioonypfHje(4ESyLF0X9432FOctbG681IpGLPCBR0ZAz4bqfMwhpMyfq4tM8spRLrfMcaP4jqXEkF(i9Sww9ca5wKINaf7P85ZgKEwl78hUb5w01aOonXzf0jES(IWh3dgvykauNVw8bSyWFa)oaD8oiNP4gIhTQlmHWh3JfR8JoUh)2(dvykauNVw8bSmLBBLEwldpaQW064XeRacFYKEwldpaQW064XeBDe2SwPN1YWdGkmToEmX60F06iSzMIBiE0QUWecFCpwSYp64E8B7puHPaqD(AXhWYuUTv6zTm8aOctRJhtSci8jt6zTm8aOctRJhtSc6epwZ1kV8spRLHhavyAD8yITocB28pHpUhmQWuaOoFT4dyXG)a(Da64DqUFNWB5mf3q8OvDHje(4ESyLF0X9432Fc4AGcDqxbwNPCBR8fyly1qsd4Zh184yZ4XKCYKEwlJkmfac3q1eWwhHnRv6zTmQWuaiCdvtaRt)rRJWMjt6zTmQWuaifpbk22tczBq6zTSZF4gKBrxdG60eNT9KqycHpUhlw5hDCp(T9hQWuaiVKmLBBLEwlJkmfac3q1eWwhHnBUwvuXjPbWo)6Oo9hHBOAcwcti8X9yXk)OJ7XVT)SEkqfUkYuUTTtbXuW3CTZB1qM0ZAzuHPaqkEcuSTNeYKEwlREbGClsXtGIT9Kq2gKEwl78hUb5w01aOonXzBpjeMq4J7XIv(rh3JFB)HkmfasAqRZuUTv6zTS6naKBrxtbWI9uKj9SwgvykaeUHQjGTocB2xPOWecFCpwSYp64E8B7puHPaqsuv0eyk322PGyk4BovuXjPbWKOQOja1PGqk4tg29X2tcgOYX0X9GvqN4X6RuLj9SwgvykaKINafB7jHmPN1YOctbGWnunbS1ryZALEwlJkmfac3q1eW60F06iSzYG1ccmWuXxCpqUfPaLfWh3dwNhEjmHWh3JfR8JoUh)2(dvykaKevfnbMYTTDkiMc(MRvfvCsAamjQkAcqDkiKc(Kj9SwgvykaKINafB7jHmPN1YQxai3Iu8eOyBpjKTbPN1Yo)HBqUfDnaQttC22tczspRLrfMcaHBOAcyRJWM1k9SwgvykaeUHQjG1P)O1ryZKHDFS9KGbQCmDCpyf0jES(kvHje(4ESyLF0X9432FOctbGKOQOjWuUTv6zTmQWuaifpbk22tczspRLvVaqUfP4jqX2EsiBdspRLD(d3GCl6AauNM4STNeYKEwlJkmfac3q1eWwhHnRv6zTmQWuaiCdvtaRt)rRJWMj7ObehJkmfaYljzy3hBpjyuHPaqEjXkOt8ynx7eElRtbXuW3CTZ7uLHDFS9KGbQCmDCpyf0jESeMq4J7XIv(rh3JFB)HkmfasIQIMat52wPN1YOctbGu8eOypfzspRLrfMcaP4jqXkOt8ynx7eElt6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMmS7JTNemqLJPJ7bRGoXJLWecFCpwSYp64E8B7puHPaqsuv0eyk32k9Sww9ca5wKINaf7Pit6zTmQWuaifpbk22tczspRLvVaqUfP4jqXkOt8ynx7eElt6zTmQWuaiCdvtaBDe2SwPN1YOctbGWnunbSo9hTocBMmS7JTNemqLJPJ7bRGoXJLWecFCpwSYp64E8B7puHPaqsuv0eyk32k9SwgvykaKINafB7jHmPN1YQxai3Iu8eOyBpjKTbPN1Yo)HBqUfDnaQttC2tr2gKEwl78hUb5w01aOonXzf0jESMRDcVLj9SwgvykaeUHQjGTocBwR0ZAzuHPaq4gQMawN(JwhHntycHpUhlw5hDCp(T9hQWuaijQkAcmLBBpQMGJ1a04Ayk4BUuunKj9SwgvykaeUHQjGTocBwR0ZAzuHPaq4gQMawN(JwhHntw9cW61eWOctbGK8Uev7oeNmcFCvaccOZH1xQlt6zTSnqxJKxbW2EsimHWh3JfR8JoUh)2(dvykae8xz4lUhMYTThvtWXAaACnmf8nxkQgYKEwlJkmfac3q1eWwhHnBoPN1YOctbGWnunbSo9hTocBMS6fG1RjGrfMcaj5DjQ2Dioze(4QaeeqNdRVuxM0ZAzBGUgjVcGT9KqycHpUhlw5hDCp(T9hQWuaiPbToHje(4ESyLF0X9432FavoMoUhMYTTspRLvVaqUfP4jqX2Esit6zTmQWuaifpbk22tczBq6zTSZF4gKBrxdG60eNT9KqycHpUhlw5hDCp(T9hQWuaijQkAceMimHWh3JfB1qfSr49632FEla1PGqtq3uUTv(JgqCmig8PMdcylRtbXuW3CTPPuL1PGyk47R25PAi3NpYRMhnG4yqm4tnheWwwNcIPGV5AttQHCcti8X9yXwnubBeEV(T9hf)4Eyk32k9SwgvykaKINaf7PimHWh3JfB1qfSr49632FoEhqjuPyk32wVaSEnbSd6kErducvkYKEwld(3qV1X9G9uKjp29X2tcgvykaKINafRaAN(Npw(uZHkOt8ynx78LQCcti8X9yXwnubBeEV(T9NbFQ5wO53V9uhIZuUTv6zTmQWuaifpbk22tczspRLvVaqUfP4jqX2EsiBdspRLD(d3GCl6AauNM4STNecti8X9yXwnubBeEV(T9hjAc5w0vCSzlt52wPN1YOctbGu8eOyBpjKj9Sww9ca5wKINafB7jHSni9Sw25pCdYTORbqDAIZ2EsimHWh3JfB1qfSr49632FKGAbLz8yYuUTv6zTmQWuaifpbk2trycHpUhl2QHkyJW71VT)inCFJSVkDt52wPN1YOctbGu8eOypfHje(4ESyRgQGncVx)2(JLxG0W9TPCBR0ZAzuHPaqkEcuSNIWecFCpwSvdvWgH3RFB)HcmSUIgimngMYTTspRLrfMcaP4jqXEkcti8X9yXwnubBeEV(T9N3cq8d6lt52wPN1YOctbGu8eOypfHje(4ESyRgQGncVx)2(ZBbi(bDtbRfWhkOo0onOnNoVwijApbMYTTspRLrfMcaP4jqXEkF(GDFS9KGrfMcaP4jqXkOt8y9vRAOgY2G0ZAzN)Wni3IUga1Pjo7PimHWh3JfB1qfSr49632FElaXpOBAqDOf6kPxanqETdkWGPCBl29X2tcgvykaKINafRGoXJ1CTPmvHje(4ESyRgQGncVx)2(ZBbi(bDtdQdT7cOTLxasfSwWWuUTf7(y7jbJkmfasXtGIvqN4X6R2uM6NpQPkQ4K0ayKcYd0BbTQ)5J8hVdTPktfvCsAamEOcQd2ixbcOAvxw9cW61eWwCLgpqRZRUCcti8X9yXwnubBeEV(T9N3cq8d6MguhAx(BG4tb)GYuUTf7(y7jbJkmfasXtGIvqN4X6R2uM6NpQPkQ4K0ayKcYd0BbTQ)5J8hVdTPktfvCsAamEOcQd2ixbcOAvxw9cW61eWwCLgpqRZRUCcti8X9yXwnubBeEV(T9N3cq8d6MguhANgPR0GClIwlENpOJ7HPCBl29X2tcgvykaKINafRGoXJ1xTPm1pFutvuXjPbWifKhO3cAv)Zh5pEhAtvMkQ4K0ay8qfuhSrUceq1QUS6fG1RjGT4knEGwNxD5eMq4J7XITAOc2i8E9B7pVfG4h0nnOo02jmjvaA1aWH6VfhBk32IDFS9KGrfMcaP4jqXkOt8ynxRAitE1ufvCsAamEOcQd2ixbcOAv)ZNJ3HVsXuLtycHpUhl2QHkyJW71VT)8waIFq30G6qBNWKubOvdahQ)wCSPCBl29X2tcgvykaKINafRGoXJ1CTQHmvuXjPbW4HkOoyJCfiGQvDzspRLvVaqUfP4jqXEkYKEwlREbGClsXtGIvqN4XAUw5vp15xQX8F9cW61eWwCLgpqRZRUCYoEhMlftnF5lNb]] )


end
