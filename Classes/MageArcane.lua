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


    spec:RegisterPack( "Arcane", 20201128, [[dW0BKeqisQYJuivDjfsLQnrs(efQrru1PiQSksQeELQkMff0TuivYUq5xQkmmbYXiPSmkKEMaIPPqkxJKk2Mcj13uiHXrsL6Cci16OqyEkuDpP0(uvPdQqsSqvf9qkeDrsQK8rbKKtQqsALuGxssLu1mjPQUjjvsLDQq8tbKOHQqQuwkjvIEkfnvfkxvHuXxfqsnwbu7vO)czWK6WilMipgQjRsxgSzk9zfmAP40OA1KujLxlaZwQUTI2TKFt1WjXXvirlx0ZvX0v66QY2jkFxqJxvvNxGA9ciH5RQ0(jCuT4yrZlTqCeJgKrdsn1mQ6MP2OoOrlqgfrZnyfiAQq4aObiAw0eIMJkjMkiAQqb3D6ghlAE8xIHOzZUkhJ4Jpg4BZtIH95hh(81PL7foj7(XHpXFenLE8(oQwrPO5LwioIrdYObPMAgvDZuBuh0OPMrJMhfahhzuB0Ozd)EHkkfnVWbhnh9cT66ObqOhvsmvGWGrVqpIldMsqk0gvDBOqB0GmAqcdegm6fA1LW0LbcTmk5Kuhy0eDuOPqZlH2sY8uODRqFGD51WHrt0rHMcT84gahGqhS)sH(OayH2vwUxh5ycdg9c9OJYLw4k08AHSOUq3q1TZRbH2TcTmk5KuhynKma5kqbxHEDHwceA1e6WgOe6dSlVgomAIok0uOBfA1ycdg9c9OZbe6nyfoM6cTjFAKcDdv3oVgeA3k04gQkOl08AHmFkl3lHMxNfORq7wH2ymvyOJi8Y9YyMWGrVqRU6CGcdhHoHPldUcnDeA3k0J4YGPeKcTrv3c96cDc3hgeAJC0TrhHw(tNp0S9GLJfn78ZEIJfnDfOGmowCe1IJfnHIK6Wn(z0eN8fsofnLxOZxbwpha2HR04f6SEozqrsD4k0F)k05RaRNdaBHPINuhfsPcdksQdxHwoHwLqVuhQLLVcqUfP4HqYGIK6WvOvj0y37xpSy5RaKBrkEiKSeMeVoc9VcDqcTkHwEHw6zTS8vaYTifpes21dlH(7xHwjbzOb8LPgJsmvasIYKgaHwUOjHxUxrtqMJPL7vCJJy04yrtOiPoCJFgnXjFHKtrZ8vG1ZbGD5hmxPZlkdgH95KQldksQdxHwLql9Sw2LFWCLoVOmye2NtQUiB6NL9uIMeE5EfnT8eqsD6SXnosGehlAcfj1HB8ZOjo5lKCkAMVcSEoaSHKF6bJ4yoUdmOiPoCfAvc9KkIPGxH(xHoqRortcVCVIM20plQCzuCJJmAXXIMqrsD4g)mAIt(cjNIMQNqNVcSEoaSdxPXl0z9CYGIK6WnAs4L7v08c02i5zbXnoI6ehlAcfj1HB8ZOjo5lKCkAoPIyk4vO)vOhTGIMeE5Efnt6YPArhfkdiUXrg1XXIMqrsD4g)mAIt(cjNIMspRLrjMkaP4HqYUEyj0QeAS79RhwmkXubifpeswctIxhHwLqREcTmk5Kuhy8sgKlCrUcuqk0TcTArtcVCVIMNgUD51asXdHmUXrgfXXIMqrsD4g)mAIt(cjNIMYOKtsDGXlzqUWf5kqbPq3k0Qj0QeAS79RhwS8vaYTifpeswctIxhHUvOdkAs4L7v0KsmvaYtP4ghrDhhlAcfj1HB8ZOjo5lKCkAkJsoj1bgVKb5cxKRafKcDRqRMqRsOXU3VEyXYxbi3Iu8qizjmjEDe6wHoiHwLql9SwgLyQaeUHYbGDwchGqpUql9SwgLyQaeUHYbGnP)OZs4aIMeE5EfnPetfGK60zJBCKaDCSOjuKuhUXpJM4KVqYPOPmk5Kuhy8sgKlCrUcuqk0TcTAcTkHw6zTS8vaYTifpes21dROjHxUxrZ8vaYTifpeY4ghrTGIJfnHIK6Wn(z0eN8fsofnLrjNK6aJxYGCHlYvGcsHUvOvtOvj0QNqlVqNVcSEoaSdxPXl0z9CYGIK6WvO)(vOZxbwpha2ctfpPokKsfguKuhUcTCrtcVCVIMk(Y9kUXrutT4yrtOiPoCJFgnXjFHKtrtPN1YYxbi3Iu8qizxpSIMeE5EfnVaTnsEwqCJJOMrJJfnHIK6Wn(z0eN8fsofnLEwllFfGClsXdHKD9WsO)(vOvsqgAaFzQXOetfGKOmPbiAs4L7v0CYZ0ZdYTO1ZjuBCJJOwGehlAcfj1HB8ZOjo5lKCkAk9Sww(ka5wKIhcj76HLq)9RqRKGm0a(YuJrjMkajrzsdq0KWl3RO56pCdYTOTbqtAGh34iQnAXXIMqrsD4g)mAIt(cjNIMkjidnGVm1yR)Wni3I2ganPbE0KWl3ROjLyQaKIhczCJJOM6ehlAcfj1HB8ZOjo5lKCkAk9Sww(ka5wKIhcj76Hv0KWl3ROz(ka5wKIhczCJJO2Ooow0eksQd34NrtCYxi5u08cspRLT(d3GClABa0Kg4SNIqRsOVG0ZAzR)Wni3I2ganPbolHjXRJqpUqt4L7fJsmvaAYphEhom4pGFlGw(eIMeE5Efnvs4afgqUfn51nUXruBuehlAcfj1HB8ZOjo5lKCkAE9LL0Lt1IokugalHjXRJq)RqRoc93Vc9fKEwllPlNQfDuOmaKSxVGKK4D(gm7SeoaH(xHoOOjHxUxrtkXubiPoD24ghrn1DCSOjuKuhUXpJM4KVqYPOP0ZAzkjCGcdi3IM86YEkcTkH(cspRLT(d3GClABa0Kg4SNIqRsOVG0ZAzR)Wni3I2ganPbolHjXRJqpERqt4L7fJsmvasQtNLb)b8Bb0YNq0KWl3ROjLyQaKuNoBCJJOwGoow0eksQd34NrtCYxi5u0u6zTS8vaYTifpes2trOvj0y37xpSyuIPcqkEiKSeOBWcTkHEsfXuWRqpUqpAbj0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbi0QeA1tOZxbwpha2HR04f6SEozqrsD4k0QeA1tOZxbwpha2ctfpPokKsfguKuhUrtcVCVIMuIPcqsuM0ae34ignO4yrtOiPoCJFgnXjFHKtrtPN1YYxbi3Iu8qizpfHwLql9SwgLyQaKIhcj76HLqRsOLEwllFfGClsXdHKLWK41rOhVvOhWxHwLql9SwgLyQaeUHYbGDwchGq3k0spRLrjMkaHBOCayt6p6SeoaHwLqlJsoj1bgVKb5cxKRafKrtcVCVIMuIPcqsuM0ae34igvT4yrtOiPoCJFgnXneVIMQfnbk7bJWneVqCB0u6zTmChOetNLxdiCdvf0zxpSujV0ZAzuIPcqkEiKSNY3VYREl1HAzUmiv8qiHRk5LEwllFfGClsXdHK9u((f7E)6HfdK5yA5EXsGUblNCYfnXjFHKtrZli9Sw26pCdYTOTbqtAGZEkcTkHEPoulJsmvacWnodksQdxHwLqlVql9Sw2fOTrYZcyxpSe6VFfAcVCzackyYHJq3k0Qj0Yj0Qe6li9Sw26pCdYTOTbqtAGZsys86i0)k0eE5EXOetfGM8ZH3Hdd(d43cOLpbHwLqlVqREcnfOas(cmkXubiL3CcDEnWGIK6WvO)(vOLEwld3bkX0z51ac3qvbD21dlHwUOjHxUxrtkXubOj)C4D4e34ig1OXXIMqrsD4g)mAs4L7v0KsmvaAYphEhortCdXROPArtCYxi5u0u6zTmChOetNLxdSei8k0QeAS79RhwmkXubifpeswctIxhHwLqlVql9Sww(ka5wKIhcj7Pi0F)k0spRLrjMkaP4HqYEkcTCXnoIrdK4yrtOiPoCJFgnXjFHKtrtPN1YOetfGWnuoaSZs4ae6XBfAzuYjPoWwFNOj9hHBOCaocTkHwEHg7E)6HfJsmvasXdHKLWK41rO)vOvliH(7xHMWlxgGGcMC4i0J3k0gvOLlAs4L7v0KsmvaYtP4ghXOJwCSOjuKuhUXpJM4KVqYPOP0ZAz5RaKBrkEiKSNIq)9RqpPIyk4vO)vOvtDIMeE5EfnPetfGK60zJBCeJQoXXIMqrsD4g)mAs4L7v0eK5yA5Efn51cz(uwe3gnNurmf8(BR6wDIM8AHmFklIpNWLtlenvlAIt(cjNIMspRLLVcqUfP4HqYUEyj0QeAPN1YOetfGu8qizxpSIBCeJoQJJfnj8Y9kAsjMkajrzsdq0eksQd34NXnUrZPldMqTXXIJOwCSOjuKuhUXpJM4KVqYPO50LbtOw2LFwQWGq)BRqRwqrtcVCVIMsDEfqCJJy04yrtcVCVIMkjCGcdi3IM86gnHIK6Wn(zCJJeiXXIMqrsD4g)mAIt(cjNIMtxgmHAzx(zPcdc94cTAbfnj8Y9kAsjMkan5NdVdN4ghz0IJfnj8Y9kAsjMka5Pu0eksQd34NXnoI6ehlAs4L7v00Ytaj1PZgnHIK6Wn(zCJB0m9LwUxXXIJOwCSOjuKuhUXpJMeE5EfnbzoMwUxrtETqMpLfXTrZjvetbV)2gOvhvYRE5RaRNda7WvA8cDwpNF)k9Sw2HR04f6SEozNLWb0k9Sw2HR04f6SEozt6p6Seoa5IM8AHmFklIpNWLtlenvlAIt(cjNIMtQiMcEf6XBfAzuYjPoWazosbVcTkHwEHg7E)6HfB9hUb5w02aOjnWzjmjEDe6XBfAcVCVyGmhtl3lg8hWVfqlFcc93Vcn29(1dlgLyQaKIhcjlHjXRJqpERqt4L7fdK5yA5EXG)a(TaA5tqO)(vOLxOxQd1YYxbi3Iu8qizqrsD4k0QeAS79RhwS8vaYTifpeswctIxhHE8wHMWl3lgiZX0Y9Ib)b8Bb0YNGqlNqlNqRsOLEwllFfGClsXdHKD9WsOvj0spRLrjMkaP4HqYUEyj0Qe6li9Sw26pCdYTOTbqtAGZUEyf34ignow0eksQd34NrtCYxi5u0mFfy9CayhUsJxOZ65Kbfj1HRqRsOXU3VEyXOetfGu8qizjmjEDe6XBfAcVCVyGmhtl3lg8hWVfqlFcrtcVCVIMGmhtl3R4ghjqIJfnHIK6Wn(z0eN8fsofnXU3VEyXw)HBqUfTnaAsdCwc0nyHwLqlVql9SwgLyQaeUHYbGDwchGq)RqlJsoj1b267enP)iCdLdWrOvj0y37xpSyuIPcqkEiKSeMeVoc94Tcn8hWVfqlFccTCrtcVCVIMuIPcqsuM0ae34iJwCSOjuKuhUXpJM4KVqYPOj29(1dl26pCdYTOTbqtAGZsGUbl0QeA5fAPN1YOetfGWnuoaSZs4ae6FfAzuYjPoWwFNOj9hHBOCaocTkHEPoullFfGClsXdHKbfj1HRqRsOXU3VEyXYxbi3Iu8qizjmjEDe6XBfA4pGFlGw(eeAvcn29(1dlgLyQaKIhcjlHjXRJq)RqlJsoj1b267enP)Ol0PGrwprKIqlx0KWl3ROjLyQaKeLjnaXnoI6ehlAcfj1HB8ZOjo5lKCkAIDVF9WIT(d3GClABa0Kg4SeOBWcTkHwEHw6zTmkXubiCdLda7SeoaH(xHwgLCsQdS13jAs)r4gkhGJqRsOLxOvpHEPoullFfGClsXdHKbfj1HRq)9RqJDVF9WILVcqUfP4HqYsys86i0)k0YOKtsDGT(ort6p6cDkyK1tu6kcTCcTkHg7E)6HfJsmvasXdHKLWK41rO)vOLrjNK6aB9DIM0F0f6uWiRNisrOLlAs4L7v0KsmvasIYKgG4ghzuhhlAcfj1HB8ZOjo5lKCkAEbPN1Ys6YPArhfkdaj71lijjENVbZolHdqOBf6li9Swwsxovl6OqzaizVEbjjX78ny2K(JolHdqOvj0Yl0spRLrjMkaP4HqYUEyj0F)k0spRLrjMkaP4HqYsys86i0J3k0d4RqlNqRsOLxOLEwllFfGClsXdHKD9WsO)(vOLEwllFfGClsXdHKLWK41rOhVvOhWxHwUOjHxUxrtkXubijktAaIBCKrrCSOjuKuhUXpJM4KVqYPO51xwsxovl6OqzaSeMeVoc9VcT6wO)(vOLxOVG0ZAzjD5uTOJcLbGK96fKKeVZ3GzNLWbi0)k0bj0Qe6li9Swwsxovl6OqzaizVEbjjX78ny2zjCac94c9fKEwllPlNQfDuOmaKSxVGKK4D(gmBs)rNLWbi0Yfnj8Y9kAsjMkaj1PZg34iQ74yrtOiPoCJFgnXjFHKtrtPN1Yus4afgqUfn51L9ueAvc9fKEwlB9hUb5w02aOjnWzpfHwLqFbPN1Yw)HBqUfTnaAsdCwctIxhHE8wHMWl3lgLyQaKuNold(d43cOLpHOjHxUxrtkXubiPoD24ghjqhhlAcfj1HB8ZOjUH4v0uTOjqzpyeUH4fIBJMspRLH7aLy6S8AaHBOQGo76HLk5LEwlJsmvasXdHK9u((vE1BPoulZLbPIhcjCvjV0ZAz5RaKBrkEiKSNY3Vy37xpSyGmhtl3lwc0ny5KtUOjo5lKCkAEbPN1Yw)HBqUfTnaAsdC2trOvj0l1HAzuIPcqaUXzqrsD4k0QeA5fAPN1YUaTnsEwa76HLq)9Rqt4LldqqbtoCe6wHwnHwoHwLqlVqFbPN1Yw)HBqUfTnaAsdCwctIxhH(xHMWl3lgLyQa0KFo8oCyWFa)waT8ji0F)k0y37xpSykjCGcdi3IM86Ysys86i0)k0bj0F)k0yxguuTSaco5uj0Yj0QeA5fA1tOPafqYxGrjMkaP8MtOZRbguKuhUc93VcT0ZAz4oqjMolVgq4gQkOZUEyj0Yfnj8Y9kAsjMkan5NdVdN4ghrTGIJfnHIK6Wn(z0eN8fsofnLEwld3bkX0z51albcVcTkHw6zTm4Vcvx4Iu8fQLtD2tjAs4L7v0KsmvaAYphEhoXnoIAQfhlAcfj1HB8ZOjHxUxrtkXubOj)C4D4enXneVIMQfnXjFHKtrtPN1YWDGsmDwEnWsGWRqRsOLxOLEwlJsmvasXdHK9ue6VFfAPN1YYxbi3Iu8qizpfH(7xH(cspRLT(d3GClABa0Kg4SeMeVoc9VcnHxUxmkXubOj)C4D4WG)a(TaA5tqOLlUXruZOXXIMqrsD4g)mAs4L7v0KsmvaAYphEhortCdXROPArtCYxi5u0u6zTmChOetNLxdSei8k0QeAPN1YWDGsmDwEnWolHdqOBfAPN1YWDGsmDwEnWM0F0zjCaXnoIAbsCSOjuKuhUXpJMeE5EfnPetfGM8ZH3Ht0e3q8kAQw0eN8fsofnLEwld3bkX0z51albcVcTkHw6zTmChOetNLxdSeMeVoc94TcT8cT8cT0ZAz4oqjMolVgyNLWbi0QleAcVCVyuIPcqt(5W7WHb)b8Bb0YNGqlNq)JqpGVcTCXnoIAJwCSOjuKuhUXpJM4KVqYPOP8cDc2eonKuhe6VFfA1tOxooaEni0Yj0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbi0QeAPN1YOetfGu8qizxpSeAvc9fKEwlB9hUb5w02aOjnWzxpSIMeE5EfnlyBGeTWuboBCJJOM6ehlAcfj1HB8ZOjo5lKCkAk9SwgLyQaeUHYbGDwchGqpERqlJsoj1b267enP)iCdLdWjAs4L7v0KsmvaYtP4ghrTrDCSOjuKuhUXpJM4KVqYPO5KkIPGxHE8wHoqRocTkHw6zTmkXubifpes21dlHwLql9Sww(ka5wKIhcj76HLqRsOVG0ZAzR)Wni3I2ganPbo76Hv0KWl3RO55Paz5YO4ghrTrrCSOjuKuhUXpJM4KVqYPOP0ZAz5Rdi3I2MeGd7Pi0QeAPN1YOetfGWnuoaSZs4ae6Ff6ajAs4L7v0KsmvasQtNnUXrutDhhlAcfj1HB8ZOjo5lKCkAoPIyk4vOhVvOLrjNK6atIYKga0KkcPGxHwLql9SwgLyQaKIhcj76HLqRsOLEwllFfGClsXdHKD9WsOvj0xq6zTS1F4gKBrBdGM0aND9WsOvj0spRLrjMkaHBOCayNLWbi0TcT0ZAzuIPcq4gkha2K(JolHdqOvj0y37xpSyGmhtl3lwctIxhH(xHoOOjHxUxrtkXubijktAaIBCe1c0XXIMqrsD4g)mAIt(cjNIMspRLrjMkaP4HqYUEyj0QeAPN1YYxbi3Iu8qizxpSeAvc9fKEwlB9hUb5w02aOjnWzxpSeAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aeAvc9sDOwgLyQaKNsmOiPoCfAvcn29(1dlgLyQaKNsSeMeVoc94Tc9a(k0Qe6jvetbVc94TcDGoiHwLqJDVF9WIbYCmTCVyjmjEDIMeE5EfnPetfGKOmPbiUXrmAqXXIMqrsD4g)mAIt(cjNIMspRLrjMkaP4HqYEkcTkHw6zTmkXubifpeswctIxhHE8wHEaFfAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aeAvcn29(1dlgiZX0Y9ILWK41jAs4L7v0KsmvasIYKgG4ghXOQfhlAcfj1HB8ZOjo5lKCkAk9Sww(ka5wKIhcj7Pi0QeAPN1YOetfGu8qizxpSeAvcT0ZAz5RaKBrkEiKSeMeVoc94Tc9a(k0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbi0QeAS79RhwmqMJPL7flHjXRt0KWl3ROjLyQaKeLjnaXnoIrnACSOjuKuhUXpJM4KVqYPOP0ZAzuIPcqkEiKSRhwcTkHw6zTS8vaYTifpes21dlHwLqFbPN1Yw)HBqUfTnaAsdC2trOvj0xq6zTS1F4gKBrBdGM0aNLWK41rOhVvOhWxHwLql9SwgLyQaeUHYbGDwchGq3k0spRLrjMkaHBOCayt6p6SeoGOjHxUxrtkXubijktAaIBCeJgiXXIMqrsD4g)mAIt(cjNIMlLdWYAaQVnmf8k0Jl0bI6i0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbi0Qe68vG1ZbGrjMkaj5tjkVtOwguKuhUcTkHMWlxgGGcMC4i0)k0Qj0QeAPN1YUaTnsEwa76Hv0KWl3ROjLyQaKeLjnaXnoIrhT4yrtOiPoCJFgnXjFHKtrZLYbyzna13gMcEf6Xf6arDeAvcT0ZAzuIPcq4gkha2zjCac94cT0ZAzuIPcq4gkha2K(JolHdqOvj05RaRNdaJsmvasYNsuENqTmOiPoCfAvcnHxUmabfm5WrO)vOvtOvj0spRLDbABK8Sa21dROjHxUxrtkXubi4Vs3pCVIBCeJQoXXIMeE5EfnPetfGK60zJMqrsD4g)mUXrm6Ooow0eksQd34NrtCYxi5u0u6zTS8vaYTifpes21dlHwLql9SwgLyQaKIhcj76HLqRsOVG0ZAzR)Wni3I2ganPbo76Hv0KWl3ROjiZX0Y9kUXrm6Oiow0KWl3ROjLyQaKeLjnartOiPoCJFg34gnjhIJfhrT4yrtOiPoCJFgnXjFHKtrZ8vG1ZbGD5hmxPZlkdgH95KQldksQdxHwLqJDVF9WIj9Sw0LFWCLoVOmye2NtQUSeOBWcTkHw6zTSl)G5kDErzWiSpNuDr20pl76HLqRsOLxOLEwlJsmvasXdHKD9WsOvj0spRLLVcqUfP4HqYUEyj0Qe6li9Sw26pCdYTOTbqtAGZUEyj0Yj0QeAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT8cT0ZAzuIPcq4gkha2zjCac94TcTmk5KuhyKdO13jAs)r4gkhGJqRsOLxOLxOxQd1YYxbi3Iu8qizqrsD4k0QeAS79RhwS8vaYTifpeswctIxhHE8wHEaFfAvcn29(1dlgLyQaKIhcjlHjXRJq)RqlJsoj1b267enP)Ol0PGrwprKIqlNq)9RqlVqREc9sDOww(ka5wKIhcjdksQdxHwLqJDVF9WIrjMkaP4HqYsys86i0)k0YOKtsDGT(ort6p6cDkyK1tePi0Yj0F)k0y37xpSyuIPcqkEiKSeMeVoc94Tc9a(k0Yj0Yfnj8Y9kAAt)SsEFJBCeJghlAcfj1HB8ZOjo5lKCkAkVqNVcSEoaSl)G5kDErzWiSpNuDzqrsD4k0QeAS79RhwmPN1IU8dMR05fLbJW(Cs1LLaDdwOvj0spRLD5hmxPZlkdgH95KQlYYtGD9WsOvj0kjidnGVm1y20pRK3xHwoH(7xHwEHoFfy9Cayx(bZv68IYGryFoP6YGIK6WvOvj0lFccDRqhKqlx0KWl3ROPLNasQtNnUXrcK4yrtOiPoCJFgnXjFHKtrZ8vG1ZbGnK8tpyehZXDGbfj1HRqRsOXU3VEyXOetfGu8qizjmjEDe6Ff6ajiHwLqJDVF9WIT(d3GClABa0Kg4SeMeVocDRqhKqRsOLxOLEwlJsmvac3q5aWolHdqOhVvOLrjNK6aJCaT(ort6pc3q5aCeAvcT8cT8c9sDOww(ka5wKIhcjdksQdxHwLqJDVF9WILVcqUfP4HqYsys86i0J3k0d4RqRsOXU3VEyXOetfGu8qizjmjEDe6FfAzuYjPoWwFNOj9hDHofmY6jIueA5e6VFfA5fA1tOxQd1YYxbi3Iu8qizqrsD4k0QeAS79RhwmkXubifpeswctIxhH(xHwgLCsQdS13jAs)rxOtbJSEIifHwoH(7xHg7E)6HfJsmvasXdHKLWK41rOhVvOhWxHwoHwUOjHxUxrtB6NfvUmkUXrgT4yrtOiPoCJFgnXjFHKtrZ8vG1ZbGnK8tpyehZXDGbfj1HRqRsOXU3VEyXOetfGu8qizjmjEDe6wHoiHwLqlVqlVqlVqJDVF9WIT(d3GClABa0Kg4SeMeVoc9VcTmk5KuhyKcAs)rxOtbJSEIwFNcTkHw6zTmkXubiCdLda7SeoaHUvOLEwlJsmvac3q5aWM0F0zjCacTCc93VcT8cn29(1dl26pCdYTOTbqtAGZsys86i0TcDqcTkHw6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOLtOLtOvj0spRLLVcqUfP4HqYUEyj0Yfnj8Y9kAAt)SOYLrXnoI6ehlAcfj1HB8ZOjo5lKCkAMVcSEoaSdxPXl0z9CYGIK6WvOvj0kjidnGVm1yGmhtl3ROjHxUxrZ1F4gKBrBdGM0apUXrg1XXIMqrsD4g)mAIt(cjNIM5RaRNda7WvA8cDwpNmOiPoCfAvcT8cTscYqd4ltngiZX0Y9sO)(vOvsqgAaFzQXw)HBqUfTnaAsdCHwUOjHxUxrtkXubifpeY4ghzuehlAcfj1HB8ZOjo5lKCkAU8ji0)k0bsqcTkHoFfy9CayhUsJxOZ65Kbfj1HRqRsOLEwlJsmvac3q5aWolHdqOhVvOLrjNK6aJCaT(ort6pc3q5aCeAvcn29(1dl26pCdYTOTbqtAGZsys86i0TcDqcTkHg7E)6HfJsmvasXdHKLWK41rOhVvOhW3OjHxUxrtqMJPL7vCJJOUJJfnHIK6Wn(z0KWl3ROjiZX0Y9kAYRfY8PSiUnAk9Sw2HR04f6SEozNLWb0k9Sw2HR04f6SEozt6p6SeoGOjVwiZNYI4ZjC50crt1IM4KVqYPO5YNGq)Rqhibj0Qe68vG1ZbGD4knEHoRNtguKuhUcTkHg7E)6HfJsmvasXdHKLWK41rOBf6GeAvcT8cT8cT8cn29(1dl26pCdYTOTbqtAGZsys86i0)k0YOKtsDGrkOj9hDHofmY6jA9Dk0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbi0Yj0F)k0Yl0y37xpSyR)Wni3I2ganPbolHjXRJq3k0bj0QeAPN1YOetfGWnuoaSZs4ae6XBfAzuYjPoWihqRVt0K(JWnuoahHwoHwoHwLql9Sww(ka5wKIhcj76HLqlxCJJeOJJfnHIK6Wn(z0eN8fsofnLxOXU3VEyXOetfGu8qizjmjEDe6Ff6rtDe6VFfAS79RhwmkXubifpeswctIxhHE8wHoqeA5eAvcn29(1dl26pCdYTOTbqtAGZsys86i0TcDqcTkHwEHw6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOvj0Yl0Yl0l1HAz5RaKBrkEiKmOiPoCfAvcn29(1dlw(ka5wKIhcjlHjXRJqpERqpGVcTkHg7E)6HfJsmvasXdHKLWK41rO)vOvhHwoH(7xHwEHw9e6L6qTS8vaYTifpesguKuhUcTkHg7E)6HfJsmvasXdHKLWK41rO)vOvhHwoH(7xHg7E)6HfJsmvasXdHKLWK41rOhVvOhWxHwoHwUOjHxUxrZjptppi3IwpNqTXnoIAbfhlAcfj1HB8ZOjo5lKCkAIDVF9WIT(d3GClABa0Kg4SeMeVoc94cn8hWVfqlFccTkHwEHw6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOvj0Yl0Yl0l1HAz5RaKBrkEiKmOiPoCfAvcn29(1dlw(ka5wKIhcjlHjXRJqpERqpGVcTkHg7E)6HfJsmvasXdHKLWK41rO)vOLrjNK6aB9DIM0F0f6uWiRNisrOLtO)(vOLxOvpHEPoullFfGClsXdHKbfj1HRqRsOXU3VEyXOetfGu8qizjmjEDe6FfAzuYjPoWwFNOj9hDHofmY6jIueA5e6VFfAS79RhwmkXubifpeswctIxhHE8wHEaFfA5eA5IMeE5Efnt6YPArhfkdiUXrutT4yrtOiPoCJFgnXjFHKtrtS79RhwmkXubifpeswctIxhHECHg(d43cOLpbHwLqlVqlVqlVqJDVF9WIT(d3GClABa0Kg4SeMeVoc9VcTmk5KuhyKcAs)rxOtbJSEIwFNcTkHw6zTmkXubiCdLda7SeoaHUvOLEwlJsmvac3q5aWM0F0zjCacTCc93VcT8cn29(1dl26pCdYTOTbqtAGZsys86i0TcDqcTkHw6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOLtOLtOvj0spRLLVcqUfP4HqYUEyj0Yfnj8Y9kAM0Lt1IokugqCJJOMrJJfnHIK6Wn(z0eN8fsofnXU3VEyXOetfGu8qizjmjEDe6wHoiHwLqlVqlVqlVqJDVF9WIT(d3GClABa0Kg4SeMeVoc9VcTmk5KuhyKcAs)rxOtbJSEIwFNcTkHw6zTmkXubiCdLda7SeoaHUvOLEwlJsmvac3q5aWM0F0zjCacTCc93VcT8cn29(1dl26pCdYTOTbqtAGZsys86i0TcDqcTkHw6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOLtOLtOvj0spRLLVcqUfP4HqYUEyj0Yfnj8Y9kAEbABK8SG4ghrTajow0eksQd34NrtCYxi5u0u6zTmkXubiCdLda7SeoaHE8wHwgLCsQdmYb067enP)iCdLdWrOvj0Yl0Yl0l1HAz5RaKBrkEiKmOiPoCfAvcn29(1dlw(ka5wKIhcjlHjXRJqpERqpGVcTkHg7E)6HfJsmvasXdHKLWK41rO)vOLrjNK6aB9DIM0F0f6uWiRNisrOLtO)(vOLxOvpHEPoullFfGClsXdHKbfj1HRqRsOXU3VEyXOetfGu8qizjmjEDe6FfAzuYjPoWwFNOj9hDHofmY6jIueA5e6VFfAS79RhwmkXubifpeswctIxhHE8wHEaFfA5IMeE5Efnx)HBqUfTnaAsd84ghrTrlow0eksQd34NrtCYxi5u0uEHwEHg7E)6HfB9hUb5w02aOjnWzjmjEDe6FfAzuYjPoWif0K(JUqNcgz9eT(ofAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aeA5e6VFfA5fAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT0ZAzuIPcq4gkha2zjCac94TcTmk5KuhyKdO13jAs)r4gkhGJqlNqlNqRsOLEwllFfGClsXdHKD9WkAs4L7v0KsmvasXdHmUXrutDIJfnHIK6Wn(z0eN8fsofnLEwllFfGClsXdHKD9WsOvj0Yl0Yl0y37xpSyR)Wni3I2ganPbolHjXRJq)RqB0GeAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aeA5e6VFfA5fAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT0ZAzuIPcq4gkha2zjCac94TcTmk5KuhyKdO13jAs)r4gkhGJqlNqlNqRsOLxOXU3VEyXOetfGu8qizjmjEDe6FfA1mQq)9RqFbPN1Yw)HBqUfTnaAsdC2trOLlAs4L7v0mFfGClsXdHmUXruBuhhlAcfj1HB8ZOjo5lKCkAk9SwgLyQaKIhcj76HLqRsOXU3VEyXOetfGu8qizB(auctIxhH(xHMWl3l2PHBxEnGu8qiz4Bk0QeAPN1YYxbi3Iu8qizxpSeAvcn29(1dlw(ka5wKIhcjBZhGsys86i0)k0eE5EXonC7YRbKIhcjdFtHwLqFbPN1Yw)HBqUfTnaAsdC21dROjHxUxrZtd3U8AaP4Hqg34iQnkIJfnHIK6Wn(z0eN8fsofnLEwl7c02i5zbSNIqRsOVG0ZAzR)Wni3I2ganPbo7Pi0Qe6li9Sw26pCdYTOTbqtAGZsys86i0J3k0spRLPKWbkmGClAYRlBs)rNLWbi0QleAcVCVyuIPcqsD6Sm4pGFlGw(eIMeE5Efnvs4afgqUfn51nUXrutDhhlAcfj1HB8ZOjo5lKCkAk9Sw2fOTrYZcypfHwLqlVqlVqVuhQLLWXlQWadksQdxHwLqt4LldqqbtoCe6Xf6rtOLtO)(vOj8YLbiOGjhoc94cT6i0Yj0QeA5fA1tOZxbwphagLyQaKKpLO8oHAzqrsD4k0F)k0lLdWYAaQVnmf8k0)k0bI6i0Yfnj8Y9kAsjMkaj1PZg34iQfOJJfnj8Y9kAEEkqwUmkAcfj1HB8Z4ghXObfhlAcfj1HB8ZOjo5lKCkAk9SwgLyQaeUHYbGDwchGq3k0bfnj8Y9kAsjMka5PuCJJyu1IJfnHIK6Wn(z0eN8fsofnLxOtWMWPHK6Gq)9RqREc9YXbWRbHwoHwLql9SwgLyQaeUHYbGDwchGq3k0spRLrjMkaHBOCayt6p6SeoGOjHxUxrZc2girlmvGZg34ig1OXXIMqrsD4g)mAIt(cjNIMspRLH7aLy6S8AGLaHxHwLqNVcSEoamkXubiEz5fFdMbfj1HRqRsOxQd1YOPsNB5yA5EXGIK6WvOvj0eE5YaeuWKdhHECHwDhnj8Y9kAsjMkan5NdVdN4ghXObsCSOjuKuhUXpJM4KVqYPOP0ZAz4oqjMolVgyjq4vOvj0Yl05RaRNdaJsmvaIxwEX3GzqrsD4k0F)k0l1HAz0uPZTCmTCVyqrsD4k0Yj0QeAcVCzackyYHJqpUqRortcVCVIMuIPcqt(5W7WjUXrm6OfhlAcfj1HB8ZOjo5lKCkAk9SwgLyQaeUHYbGDwchGqpUql9SwgLyQaeUHYbGnP)OZs4aIMeE5EfnPetfGG)kD)W9kUXrmQ6ehlAcfj1HB8ZOjo5lKCkAk9SwgLyQaeUHYbGDwchGq3k0spRLrjMkaHBOCayt6p6SeoaHwLqRKGm0a(YuJrjMkajrzsdq0KWl3ROjLyQae8xP7hUxXnoIrh1XXIMqrsD4g)mAIt(cjNIMspRLrjMkaHBOCayNLWbi0TcT0ZAzuIPcq4gkha2K(JolHdiAs4L7v0KsmvasIYKgG4ghXOJI4yrtETqMpLfXTrZjvetbV)2QUvNOjVwiZNYI4ZjC50crt1IMeE5EfnbzoMwUxrtOiPoCJFg34gnVGLE9nowCe1IJfnHIK6Wn(z0eN8fsofnxkhGLDbPN1YW0z51albcVrtcVCVIMy)vlKhfO3JBCeJghlAcfj1HB8ZOPRenpWgnj8Y9kAkJsoj1HOPmQ)GOPArtCYxi5u0ugLCsQdSgsgGCfOGRqpERqhKqRsOvsqgAaFzQXazoMwUxcTkHw9e68vG1ZbGD4knEHoRNtguKuhUrtzuIkAcrZgsgGCfOGBCJJeiXXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQw0eN8fsofnLrjNK6aRHKbixbk4k0J3k0bj0QeAPN1YOetfGu8qizxpSeAvcn29(1dlgLyQaKIhcjlHjXRJq)RqhKqRsOZxbwpha2HR04f6SEozqrsD4gnLrjQOjenBizaYvGcUXnoYOfhlAcfj1HB8ZOPRenpWgnj8Y9kAkJsoj1HOPmQ)GOPArtCYxi5u0u6zTmkXubiCdLda7SeoaHUvOLEwlJsmvac3q5aWM0F0zjCacTkHw9eAPN1YYxhqUfTnjah2trOvj0w(qZIsys86i0J3k0Yl0Yl0tQiH(dHMWl3lgLyQaKuNold7NvOLtOvxi0eE5EXOetfGK60zzWFa)waT8ji0YfnLrjQOjenT8I6iPxwXnoI6ehlAcfj1HB8ZOjHxUxrtm17icVCVqD(zJMD(zrfnHO5PHs4IW3tCJJmQJJfnHIK6Wn(z0eN8fsofnj8YLbiOGjhoc9VcTrJMeE5EfnXuVJi8Y9c15NnA25Nfv0eIMKdXnoYOiow0eksQd34NrtCYxi5u0ugLCsQdSgsgGCfOGRqpERqhu0KWl3ROjM6DeHxUxOo)SrZo)SOIMq00vGcY4ghrDhhlAcfj1HB8ZOjo5lKCkAEGD51WHrt0rHMcDRqRw0KWl3ROjM6DeHxUxOo)SrZo)SOIMq0KMOJcnJBCKaDCSOjuKuhUXpJMeE5EfnXuVJi8Y9c15NnA25Nfv0eIMy37xpSoXnoIAbfhlAcfj1HB8ZOjo5lKCkAkJsoj1bMLxuhj9YsOBf6GIMeE5EfnXuVJi8Y9c15NnA25Nfv0eIMPV0Y9kUXrutT4yrtOiPoCJFgnXjFHKtrtzuYjPoWS8I6iPxwcDRqRw0KWl3ROjM6DeHxUxOo)SrZo)SOIMq00YlQJKEzf34iQz04yrtOiPoCJFgnj8Y9kAIPEhr4L7fQZpB0SZplQOjenNUmyc1g34gnvsa7tjAJJfhrT4yrtOiPoCJFgnDLOzchyJMeE5EfnLrjNK6q0ugLOIMq0ujbLxVJazE08cw613OzqXnoIrJJfnHIK6Wn(z00vIMhyJMeE5EfnLrjNK6q0ug1Fq0uTOjo5lKCkAkJsoj1bMsckVEhbYCHUvOdsOvj05RaRNda7WvA8cDwpNmOiPoCfAvcnHxUmabfm5WrO)vOnA0ugLOIMq0ujbLxVJazECJJeiXXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQw0eN8fsofnLrjNK6atjbLxVJazUq3k0bj0Qe68vG1ZbGD4knEHoRNtguKuhUcTkHg7YGIQLvao9UNxHwLqt4LldqqbtoCe6FfA1IMYOev0eIMkjO86DeiZJBCKrlow0eksQd34NrtxjAEGnAs4L7v0ugLCsQdrtzu)brZGIM4KVqYPOPmk5KuhykjO86DeiZf6wHoOOPmkrfnHOPsckVEhbY84ghrDIJfnHIK6Wn(z00vIMhyJMeE5EfnLrjNK6q0ug1Fq0mOOPmkrfnHOzdjdqUcuWnUXrg1XXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQw0eN8fsofnLrjNK6aRHKbixbk4k0TcDqcTkHMWlxgGGcMC4i0)k0gnAkJsurtiA2qYaKRafCJBCKrrCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMQfnXjFHKtrtzuYjPoWAizaYvGcUcDRqhKqRsOLrjNK6atjbLxVJazUq3k0QfnLrjQOjenBizaYvGcUXnoI6oow0eksQd34NrtxjAEGnAs4L7v0ugLCsQdrtzu)brZGIMYOev0eIMwErDK0lR4ghjqhhlAcfj1HB8ZOPRent4aB0KWl3ROPmk5KuhIMYOev0eIM5bnP)Ol0PGrwprRVZO5fS0RVrt1jUXrulO4yrtOiPoCJFgnDLOzchyJMeE5EfnLrjNK6q0ugLOIMq0mpOj9hDHofmY6jkDLO5fS0RVrt1jUXrutT4yrtOiPoCJFgnDLOzchyJMeE5EfnLrjNK6q0ugLOIMq0mpOj9hDHofmY6jIuIMxWsV(gnnAqXnoIAgnow0eksQd34NrtxjAMWb2OjHxUxrtzuYjPoenLrjQOjenjf0K(JUqNcgz9eT(oJMxWsV(gnvlO4ghrTajow0eksQd34NrtxjAMWb2OjHxUxrtzuYjPoenLrjQOjentxbnP)Ol0PGrwprRVZO5fS0RVrtJguCJJO2OfhlAcfj1HB8ZOPRent4aB0KWl3ROPmk5KuhIMYOev0eIMRVt0K(JUqNcgz9erkrZlyPxFJMbf34iQPoXXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAgirtCYxi5u0ugLCsQdS13jAs)rxOtbJSEIifHUvOdsOvj05RaRNda7YpyUsNxugmc7ZjvxguKuhUrtzuIkAcrZ13jAs)rxOtbJSEIiL4ghrTrDCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMQPortCYxi5u0ugLCsQdS13jAs)rxOtbJSEIifHUvOdsOvj0yxguuTSIp0SilbrtzuIkAcrZ13jAs)rxOtbJSEIiL4ghrTrrCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMQPortCYxi5u0ugLCsQdS13jAs)rxOtbJSEIifHUvOdsOvj0yVUp(YOetfGus)YhcMbfj1HRqRsOj8YLbiOGjhoc94cDGenLrjQOjenxFNOj9hDHofmY6jIuIBCe1u3XXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQortCYxi5u0ugLCsQdS13jAs)rxOtbJSEIifHUvOdkAkJsurtiAU(ort6p6cDkyK1tePe34iQfOJJfnHIK6Wn(z00vIMjCGnAs4L7v0ugLCsQdrtzuIkAcrZ13jAs)rxOtbJSEIsxjAEbl96B00Obf34ignO4yrtOiPoCJFgnDLOzchyJMeE5EfnLrjNK6q0ugLOIMq0uIYKga0KkcPG3O5fS0RVrZGIBCeJQwCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMYl0J6Ge6rxcT8c9KolKbJKr9hi0QleA1ckiHwoHwUOjo5lKCkAkJsoj1bMeLjnaOjvesbVcDRqhKqRsOXUmOOAzfFOzrwcIMYOev0eIMsuM0aGMurif8g34ig1OXXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAkVqRUdsOhDj0Yl0t6Sqgmsg1FGqRUqOvlOGeA5eA5IM4KVqYPOPmk5KuhysuM0aGMurif8k0TcDqrtzuIkAcrtjktAaqtQiKcEJBCeJgiXXIMqrsD4g)mA6krZeoWgnj8Y9kAkJsoj1HOPmkrfnHOjPGM8IpFt0KkcPG3O5fS0RVrZGIBCeJoAXXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQobfnXjFHKtrtzuYjPoWif0Kx85BIMurif8k0TcDqcTkHoFfy9Cayx(bZv68IYGryFoP6YGIK6WnAkJsurtiAskOjV4Z3enPIqk4nUXrmQ6ehlAcfj1HB8ZOPRenpWgnj8Y9kAkJsoj1HOPmQ)GOP6eu0eN8fsofnLrjNK6aJuqtEXNVjAsfHuWRq3k0bj0Qe68vG1ZbGnK8tpyehZXDGbfj1HB0ugLOIMq0KuqtEXNVjAsfHuWBCJJy0rDCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMQPortCYxi5u0ugLCsQdmsbn5fF(MOjvesbVcDRqhu0ugLOIMq0KuqtEXNVjAsfHuWBCJJy0rrCSOjuKuhUXpJMUs0mHdSrtcVCVIMYOKtsDiAkJsurtiAU(ort6pc3q5aCIMxWsV(gnnACJJyu1DCSOjuKuhUXpJMUs0mHdSrtcVCVIMYOKtsDiAkJsurtiAYlzqUWf5kqbz08cw613OzqXnoIrd0XXIMqrsD4g)mA6krZdSrtcVCVIMYOKtsDiAkJ6piAQw0eN8fsofnLrjNK6aJxYGCHlYvGcsHUvOdsOvj0l1HAz5RaKBrkEiKmOiPoCfAvcT8c9sDOwgLyQaeGBCguKuhUc93VcT6j0yxguuTSaco5uj0Yj0QeA5fA1tOXUmOOAzfGtV75vO)(vOj8YLbiOGjhocDRqRMq)9RqNVcSEoaSdxPXl0z9CYGIK6WvOLlAkJsurtiAYlzqUWf5kqbzCJJeibfhlAcfj1HB8ZOPRenpWgnj8Y9kAkJsoj1HOPmQ)GOzqrtCYxi5u0ugLCsQdmEjdYfUixbkif6wHoOOPmkrfnHOjVKb5cxKRafKXnosGOwCSOjuKuhUXpJMUs08aB0KWl3ROPmk5KuhIMYO(dIMWO8XvuGlBsyskb0PbGfnFhowO)(vOHr5JROax2qNUCA98GKO7ai0F)k0WO8XvuGlBOtxoTEEqt4s9o3lH(7xHggLpUIcCzxkdy6EHUaoaKYBt4GHcdc93VcnmkFCff4Y41bNVLK6aAu(OAFt0fKXXGq)9RqdJYhxrbUSJ)6DyxEnGYNuWc93VcnmkFCff4YoVsQ7(frtyBc(Sc93VcnmkFCff4YcPaGcYdYMEDf6VFfAyu(4kkWLz70eqUfjr72HOPmkrfnHOjPG8c9oqCJJeignow0eksQd34NrtxjAMWb2OjHxUxrtzuYjPoenLrjQOjenjhqRVt0K(JWnuoaNO5fS0RVrtJg34ibsGehlAcfj1HB8ZOPRenpWgnj8Y9kAkJsoj1HOPmQ)GOPArtCYxi5u0ugLCsQdSgsgGCfOGRq3k0bj0Qe6dSlVgomAIok0uOBfA1IMYOev0eIMnKma5kqb34ghjqgT4yrtOiPoCJFgnDLOzchyJMeE5EfnLrjNK6q0ugLOIMq0eK5if8gnVGLE9nAQM6e34ibI6ehlAcfj1HB8Z4ghjqg1XXIMqrsD4g)mUXrcKrrCSOjuKuhUXpJBCKarDhhlAs4L7v088MtVquIPcqwAY7CkJMqrsD4g)mUXrcKaDCSOjHxUxrtkXubiETqVd4nAcfj1HB8Z4ghz0ckow0KWl3ROj2l11EjGMurObygnHIK6Wn(zCJJmAQfhlAcfj1HB8Z4ghz0mACSOjHxUxrZjptpr8jnartOiPoCJFg34iJwGehlAcfj1HB8ZOjo5lKCkAQEcTmk5KuhykjO86DeiZf6wHwnHwLqNVcSEoaSl)G5kDErzWiSpNuDzqrsD4gnj8Y9kAAt)SsEFJBCKrB0IJfnHIK6Wn(z0eN8fsofnvpHwgLCsQdmLeuE9ocK5cDRqRMqRsOvpHoFfy9Cayx(bZv68IYGryFoP6YGIK6WnAs4L7v0KsmvasQtNnUXrgn1jow0eksQd34NrtCYxi5u0ugLCsQdmLeuE9ocK5cDRqRw0KWl3ROjiZX0Y9kUXnAst0rHMXXIJOwCSOjuKuhUXpJM4KVqYPO5KkIPGxHE8wHwgLCsQdmqMJuWRqRsOLxOXU3VEyXw)HBqUfTnaAsdCwctIxhHE8wHMWl3lgiZX0Y9Ib)b8Bb0YNGq)9RqJDVF9WIrjMkaP4HqYsys86i0J3k0eE5EXazoMwUxm4pGFlGw(ee6VFfA5f6L6qTS8vaYTifpesguKuhUcTkHg7E)6HflFfGClsXdHKLWK41rOhVvOj8Y9IbYCmTCVyWFa)waT8ji0Yj0Yj0QeAPN1YYxbi3Iu8qizxpSeAvcT0ZAzuIPcqkEiKSRhwcTkH(cspRLT(d3GClABa0Kg4SRhwrtcVCVIMGmhtl3R4ghXOXXIMqrsD4g)mAIt(cjNIMy37xpSyuIPcqkEiKSeMeVocDRqhKqRsOLxOLEwllFfGClsXdHKD9WsOvj0Yl0y37xpSyR)Wni3I2ganPbolHjXRJq)RqlJsoj1bgPGM0F0f6uWiRNO13Pq)9RqJDVF9WIT(d3GClABa0Kg4SeMeVocDRqhKqlNqlx0KWl3RO5fOTrYZcIBCKajow0eksQd34NrtCYxi5u0e7E)6HfJsmvasXdHKLWK41rOBf6GeAvcT8cT0ZAz5RaKBrkEiKSRhwcTkHwEHg7E)6HfB9hUb5w02aOjnWzjmjEDe6FfAzuYjPoWif0K(JUqNcgz9eT(of6VFfAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeA5eA5IMeE5EfnN8m98GClA9Cc1g34iJwCSOjHxUxrZKUCQw0rHYaIMqrsD4g)mUXruN4yrtOiPoCJFgnXjFHKtrtPN1YOetfGu8qizxpSeAvcn29(1dlgLyQaKIhcjBZhGsys86i0)k0eE5EXonC7YRbKIhcjdFtHwLql9Sww(ka5wKIhcj76HLqRsOXU3VEyXYxbi3Iu8qizB(auctIxhH(xHMWl3l2PHBxEnGu8qiz4Bk0Qe6li9Sw26pCdYTOTbqtAGZUEyfnj8Y9kAEA42LxdifpeY4ghzuhhlAcfj1HB8ZOjo5lKCkAk9Sww(ka5wKIhcj76HLqRsOXU3VEyXOetfGu8qizjmjEDe6Ff6GIMeE5EfnZxbi3Iu8qiJBCKrrCSOjuKuhUXpJM4KVqYPOP8cn29(1dlgLyQaKIhcjlHjXRJq3k0bj0QeAPN1YYxbi3Iu8qizxpSeA5e6VFfALeKHgWxMAS8vaYTifpeYOjHxUxrZ1F4gKBrBdGM0apUXru3XXIMqrsD4g)mAIt(cjNIMy37xpSyuIPcqkEiKSeMeVoc94cT6eKqRsOLEwllFfGClsXdHKD9WsOvj0W5afgyY4hUxi3IuG0c4L7fdksQd3OjHxUxrZ1F4gKBrBdGM0apUXrc0XXIMqrsD4g)mAIt(cjNIMspRLLVcqUfP4HqYUEyj0QeAS79RhwS1F4gKBrBdGM0aNLWK41rO)vOLrjNK6aJuqt6p6cDkyK1t067mAs4L7v0KsmvasXdHmUXrulO4yrtOiPoCJFgnXjFHKtrtPN1YOetfGu8qizpfHwLql9SwgLyQaKIhcjlHjXRJqpERqt4L7fJsmvaAYphEhom4pGFlGw(eeAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aIMeE5EfnPetfGKOmPbiUXrutT4yrtOiPoCJFgnXjFHKtrtPN1YOetfGWnuoaSZs4ae6XfAPN1YOetfGWnuoaSj9hDwchGqRsOLEwllFfGClsXdHKD9WsOvj0spRLrjMkaP4HqYUEyj0Qe6li9Sw26pCdYTOTbqtAGZUEyfnj8Y9kAsjMka5PuCJJOMrJJfnHIK6Wn(z0eN8fsofnLEwllFfGClsXdHKD9WsOvj0spRLrjMkaP4HqYUEyj0Qe6li9Sw26pCdYTOTbqtAGZUEyj0QeAPN1YOetfGWnuoaSZs4ae6wHw6zTmkXubiCdLdaBs)rNLWbenj8Y9kAsjMkajrzsdqCJJOwGehlAcfj1HB8ZOjUH4v0uTOjqzpyeUH4fIBJMspRLH7aLy6S8AaHBOQGo76HLk5LEwlJsmvasXdHK9u((v6zTS8vaYTifpes2t57xS79RhwmqMJPL7flb6gSCrtCYxi5u0u6zTmChOetNLxdSei8gnj8Y9kAsjMkan5NdVdN4ghrTrlow0eksQd34NrtCdXROPArtGYEWiCdXle3gnLEwld3bkX0z51ac3qvbD21dlvYl9SwgLyQaKIhcj7P89R0ZAz5RaKBrkEiKSNY3Vy37xpSyGmhtl3lwc0ny5IM4KVqYPOP6j0uGci5lWOetfGuEZj051adksQdxH(7xHw6zTmChOetNLxdiCdvf0zxpSIMeE5EfnPetfGM8ZH3HtCJJOM6ehlAcfj1HB8ZOjo5lKCkAk9Sww(ka5wKIhcj76HLqRsOLEwlJsmvasXdHKD9WsOvj0xq6zTS1F4gKBrBdGM0aND9WkAs4L7v0eK5yA5Ef34iQnQJJfnHIK6Wn(z0eN8fsofnLEwlJsmvac3q5aWolHdqOhxOLEwlJsmvac3q5aWM0F0zjCartcVCVIMuIPcqEkf34iQnkIJfnj8Y9kAsjMkajrzsdq0eksQd34NXnoIAQ74yrtcVCVIMuIPcqsD6SrtOiPoCJFg34gnpnucxe(EIJfhrT4yrtOiPoCJFgnXjFHKtrt5f6L6qTmO68HMfk4YGIK6WvOvj0tQiMcEf6XBfA1DqcTkHEsfXuWRq)BRqpQvhHwoH(7xHwEHw9e6L6qTmO68HMfk4YGIK6WvOvj0tQiMcEf6XBfA1T6i0Yfnj8Y9kAoPIqdWmUXrmACSOjuKuhUXpJM4KVqYPOP0ZAzuIPcqkEiKSNs0KWl3ROPIVCVIBCKajow0eksQd34NrtCYxi5u0mFfy9Caylmv8K6OqkvyqrsD4k0QeAPN1YG)n07SCVypfHwLqlVqJDVF9WIrjMkaP4HqYsGUbl0F)k0w(qZIsys86i0J3k0JwqcTCrtcVCVIMlFcOqkvIBCKrlow0eksQd34NrtCYxi5u0u6zTmkXubifpes21dlHwLql9Sww(ka5wKIhcj76HLqRsOVG0ZAzR)Wni3I2ganPbo76Hv0KWl3ROzNp0ShK6AV7WeQnUXruN4yrtOiPoCJFgnXjFHKtrtPN1YOetfGu8qizxpSeAvcT0ZAz5RaKBrkEiKSRhwcTkH(cspRLT(d3GClABa0Kg4SRhwrtcVCVIMs0aYTOn54aoXnoYOoow0eksQd34NrtCYxi5u0u6zTmkXubifpes2tjAs4L7v0ucYdKbWRH4ghzuehlAcfj1HB8ZOjo5lKCkAk9SwgLyQaKIhcj7Penj8Y9kAk1D)ISVm44ghrDhhlAcfj1HB8ZOjo5lKCkAk9SwgLyQaKIhcj7Penj8Y9kAA5ji1D)g34ib64yrtOiPoCJFgnXjFHKtrtPN1YOetfGu8qizpLOjHxUxrtQWWztQJWuVh34iQfuCSOjuKuhUXpJM4KVqYPOP0ZAzuIPcqkEiKSNs0KWl3RO57ai(cZtCJJOMAXXIMqrsD4g)mAs4L7v0COtxoTEEqs0DaIM4KVqYPOP0ZAzuIPcqkEiKSNIq)9RqJDVF9WIrjMkaP4HqYsys86i0)2k0QJ6i0Qe6li9Sw26pCdYTOTbqtAGZEkrtWAb8IkAcrZHoD5065bjr3biUXruZOXXIMqrsD4g)mAs4L7v0eMkbNa1rEElQWq0eN8fsofnXU3VEyXOetfGu8qizjmjEDe6XBfAJgu0SOjenHPsWjqDKN3Ikme34iQfiXXIMqrsD4g)mAs4L7v08MaDT8eqYGZb6rtCYxi5u0e7E)6HfJsmvasXdHKLWK41rO)TvOnAqc93VcT6j0YOKtsDGrkiVqVdi0TcTAc93VcT8c9YNGq3k0bj0QeAzuYjPoW4Lmix4ICfOGuOBfA1eAvcD(kW65aWoCLgVqN1ZjdksQdxHwUOzrtiAEtGUwEcizW5a94ghrTrlow0eksQd34NrtcVCVIMh)1r8HIVqgnXjFHKtrtS79RhwmkXubifpeswctIxhH(3wH2Obj0F)k0QNqlJsoj1bgPG8c9oGq3k0Qj0F)k0Yl0lFccDRqhKqRsOLrjNK6aJxYGCHlYvGcsHUvOvtOvj05RaRNda7WvA8cDwpNmOiPoCfA5IMfnHO5XFDeFO4lKXnoIAQtCSOjuKuhUXpJMeE5Efnh6bR0GClIoh(K3PL7v0eN8fsofnXU3VEyXOetfGu8qizjmjEDe6FBfAJgKq)9RqREcTmk5KuhyKcYl07acDRqRMq)9RqlVqV8ji0TcDqcTkHwgLCsQdmEjdYfUixbkif6wHwnHwLqNVcSEoaSdxPXl0z9CYGIK6WvOLlAw0eIMd9GvAqUfrNdFY70Y9kUXruBuhhlAcfj1HB8ZOjHxUxrZjHjPeqNgaw08D44Ojo5lKCkAIDVF9WIrjMkaP4HqYsys86i0J3k0QJqRsOLxOvpHwgLCsQdmEjdYfUixbkif6wHwnH(7xHE5tqO)vOdKGeA5IMfnHO5KWKucOtdalA(oCCCJJO2Oiow0eksQd34NrtcVCVIMtctsjGonaSO57WXrtCYxi5u0e7E)6HfJsmvasXdHKLWK41rOhVvOvhHwLqlJsoj1bgVKb5cxKRafKcDRqRMqRsOLEwllFfGClsXdHK9ueAvcT0ZAz5RaKBrkEiKSeMeVoc94TcT8cTAbj0JUeA1rOvxi05RaRNda7WvA8cDwpNmOiPoCfA5eAvc9YNGqpUqhibfnlAcrZjHjPeqNgaw08D444g3Oj29(1dRtCS4iQfhlAcfj1HB8ZOjo5lKCkAMVcSEoaSHKF6bJ4yoUdmOiPoCfAvcn29(1dlgLyQaKIhcjlHjXRJq)Rqhibj0QeAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT8cT0ZAzuIPcq4gkha2zjCac94TcTmk5KuhyRVt0K(JWnuoahHwLqlVqlVqVuhQLLVcqUfP4HqYGIK6WvOvj0y37xpSy5RaKBrkEiKSeMeVoc94Tc9a(k0QeAS79RhwmkXubifpeswctIxhH(xHwgLCsQdS13jAs)rxOtbJSEIifHwoH(7xHwEHw9e6L6qTS8vaYTifpesguKuhUcTkHg7E)6HfJsmvasXdHKLWK41rO)vOLrjNK6aB9DIM0F0f6uWiRNisrOLtO)(vOXU3VEyXOetfGu8qizjmjEDe6XBf6b8vOLtOLlAs4L7v00M(zrLlJIBCeJghlAcfj1HB8ZOjo5lKCkAMVcSEoaSHKF6bJ4yoUdmOiPoCfAvcn29(1dlgLyQaKIhcjlHjXRJq3k0bj0QeA5fA1tOxQd1YGQZhAwOGldksQdxH(7xHwEHEPouldQoFOzHcUmOiPoCfAvc9KkIPGxH(3wHEueKqlNqlNqRsOLxOLxOXU3VEyXw)HBqUfTnaAsdCwctIxhH(xHwTGeAvcT0ZAzuIPcq4gkha2zjCacDRql9SwgLyQaeUHYbGnP)OZs4aeA5e6VFfA5fAS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT0ZAzuIPcq4gkha2zjCacDRqhKqlNqlNqRsOLEwllFfGClsXdHKD9WsOvj0tQiMcEf6FBfAzuYjPoWif0Kx85BIMurif8gnj8Y9kAAt)SOYLrXnosGehlAcfj1HB8ZOjo5lKCkAMVcSEoaSl)G5kDErzWiSpNuDzqrsD4k0QeAS79RhwmPN1IU8dMR05fLbJW(Cs1LLaDdwOvj0spRLD5hmxPZlkdgH95KQlYM(zzxpSeAvcT8cT0ZAzuIPcqkEiKSRhwcTkHw6zTS8vaYTifpes21dlHwLqFbPN1Yw)HBqUfTnaAsdC21dlHwoHwLqJDVF9WIT(d3GClABa0Kg4SeMeVocDRqhKqRsOLxOLEwlJsmvac3q5aWolHdqOhVvOLrjNK6aB9DIM0FeUHYb4i0QeA5fA5f6L6qTS8vaYTifpesguKuhUcTkHg7E)6HflFfGClsXdHKLWK41rOhVvOhWxHwLqJDVF9WIrjMkaP4HqYsys86i0)k0YOKtsDGT(ort6p6cDkyK1tePi0Yj0F)k0Yl0QNqVuhQLLVcqUfP4HqYGIK6WvOvj0y37xpSyuIPcqkEiKSeMeVoc9VcTmk5KuhyRVt0K(JUqNcgz9erkcTCc93Vcn29(1dlgLyQaKIhcjlHjXRJqpERqpGVcTCcTCrtcVCVIM20pRK334ghz0IJfnHIK6Wn(z0eN8fsofnZxbwpha2LFWCLoVOmye2NtQUmOiPoCfAvcn29(1dlM0ZArx(bZv68IYGryFoP6YsGUbl0QeAPN1YU8dMR05fLbJW(Cs1fz5jWUEyj0QeALeKHgWxMAmB6NvY7B0KWl3ROPLNasQtNnUXruN4yrtOiPoCJFgnXjFHKtrtS79RhwS1F4gKBrBdGM0aNLWK41rOBf6GeAvcT0ZAzuIPcq4gkha2zjCac94TcTmk5KuhyRVt0K(JWnuoahHwLqJDVF9WIrjMkaP4HqYsys86i0J3k0d4B0KWl3RO5KNPNhKBrRNtO24ghzuhhlAcfj1HB8ZOjo5lKCkAIDVF9WIrjMkaP4HqYsys86i0TcDqcTkHwEHw9e6L6qTmO68HMfk4YGIK6WvO)(vOLxOxQd1YGQZhAwOGldksQdxHwLqpPIyk4vO)TvOhfbj0Yj0Yj0QeA5fA5fAS79RhwS1F4gKBrBdGM0aNLWK41rO)vOLrjNK6aJuqt6p6cDkyK1t067uOvj0spRLrjMkaHBOCayNLWbi0TcT0ZAzuIPcq4gkha2K(JolHdqOLtO)(vOLxOXU3VEyXw)HBqUfTnaAsdCwctIxhHUvOdsOvj0spRLrjMkaHBOCayNLWbi0TcDqcTCcTCcTkHw6zTS8vaYTifpes21dlHwLqpPIyk4vO)TvOLrjNK6aJuqtEXNVjAsfHuWB0KWl3RO5KNPNhKBrRNtO24ghzuehlAcfj1HB8ZOjo5lKCkAIDVF9WIT(d3GClABa0Kg4SeMeVocDRqhKqRsOLEwlJsmvac3q5aWolHdqOhVvOLrjNK6aB9DIM0FeUHYb4i0QeAS79RhwmkXubifpeswctIxhHE8wHEaFJMeE5EfnVaTnsEwqCJJOUJJfnHIK6Wn(z0eN8fsofnXU3VEyXOetfGu8qizjmjEDe6wHoiHwLqlVqREc9sDOwguD(qZcfCzqrsD4k0F)k0Yl0l1HAzq15dnluWLbfj1HRqRsONurmf8k0)2k0JIGeA5eA5eAvcT8cT8cn29(1dl26pCdYTOTbqtAGZsys86i0)k0QfKqRsOLEwlJsmvac3q5aWolHdqOBfAPN1YOetfGWnuoaSj9hDwchGqlNq)9RqlVqJDVF9WIT(d3GClABa0Kg4SeMeVocDRqhKqRsOLEwlJsmvac3q5aWolHdqOBf6GeA5eA5eAvcT0ZAz5RaKBrkEiKSRhwcTkHEsfXuWRq)BRqlJsoj1bgPGM8IpFt0KkcPG3OjHxUxrZlqBJKNfe34ib64yrtOiPoCJFgnXjFHKtrtS79RhwS1F4gKBrBdGM0aNLWK41rO)vOLrjNK6alpOj9hDHofmY6jA9Dk0QeAS79RhwmkXubifpeswctIxhH(xHwgLCsQdS8GM0F0f6uWiRNisrOvj0Yl0l1HAz5RaKBrkEiKmOiPoCfAvcT8cn29(1dlw(ka5wKIhcjlHjXRJqpUqd)b8Bb0YNGq)9RqJDVF9WILVcqUfP4HqYsys86i0)k0YOKtsDGLh0K(JUqNcgz9eLUIqlNq)9RqREc9sDOww(ka5wKIhcjdksQdxHwoHwLql9SwgLyQaeUHYbGDwchGq)RqBuHwLqFbPN1Yw)HBqUfTnaAsdC21dlHwLql9Sww(ka5wKIhcj76HLqRsOLEwlJsmvasXdHKD9WkAs4L7v0mPlNQfDuOmG4ghrTGIJfnHIK6Wn(z0eN8fsofnXU3VEyXw)HBqUfTnaAsdCwctIxhHECHg(d43cOLpbHwLql9SwgLyQaeUHYbGDwchGqpERqlJsoj1b267enP)iCdLdWrOvj0y37xpSyuIPcqkEiKSeMeVoc94cT8cn8hWVfqlFcc9pcnHxUxS1F4gKBrBdGM0aNb)b8Bb0YNGqlx0KWl3ROzsxovl6OqzaXnoIAQfhlAcfj1HB8ZOjo5lKCkAIDVF9WIrjMkaP4HqYsys86i0Jl0WFa)waT8ji0QeA5fA5fA1tOxQd1YGQZhAwOGldksQdxH(7xHwEHEPouldQoFOzHcUmOiPoCfAvc9KkIPGxH(3wHEueKqlNqlNqRsOLxOLxOXU3VEyXw)HBqUfTnaAsdCwctIxhH(xHwgLCsQdmsbnP)Ol0PGrwprRVtHwLql9SwgLyQaeUHYbGDwchGq3k0spRLrjMkaHBOCayt6p6SeoaHwoH(7xHwEHg7E)6HfB9hUb5w02aOjnWzjmjEDe6wHoiHwLql9SwgLyQaeUHYbGDwchGq3k0bj0Yj0Yj0QeAPN1YYxbi3Iu8qizxpSeAvc9KkIPGxH(3wHwgLCsQdmsbn5fF(MOjvesbVcTCrtcVCVIMjD5uTOJcLbe34iQz04yrtOiPoCJFgnXjFHKtrtPN1YOetfGWnuoaSZs4ae6XBfAzuYjPoWwFNOj9hHBOCaocTkHg7E)6HfJsmvasXdHKLWK41rOhVvOH)a(TaA5tiAs4L7v0C9hUb5w02aOjnWJBCe1cK4yrtOiPoCJFgnXjFHKtrtPN1YOetfGWnuoaSZs4ae6XBfAzuYjPoWwFNOj9hHBOCaocTkHEPoullFfGClsXdHKbfj1HRqRsOXU3VEyXYxbi3Iu8qizjmjEDe6XBfA4pGFlGw(eeAvcn29(1dlgLyQaKIhcjlHjXRJq)RqlJsoj1b267enP)Ol0PGrwprKs0KWl3RO56pCdYTOTbqtAGh34iQnAXXIMqrsD4g)mAIt(cjNIMspRLrjMkaHBOCayNLWbi0J3k0YOKtsDGT(ort6pc3q5aCeAvcT8cT6j0l1HAz5RaKBrkEiKmOiPoCf6VFfAS79RhwS8vaYTifpeswctIxhH(xHwgLCsQdS13jAs)rxOtbJSEIsxrOLtOvj0y37xpSyuIPcqkEiKSeMeVoc9VcTmk5KuhyRVt0K(JUqNcgz9erkrtcVCVIMR)Wni3I2ganPbECJJOM6ehlAcfj1HB8ZOjo5lKCkAIDVF9WIT(d3GClABa0Kg4SeMeVoc9VcTmk5KuhyKcAs)rxOtbJSEIwFNcTkHw6zTmkXubiCdLda7SeoaHUvOLEwlJsmvac3q5aWM0F0zjCacTkHw6zTS8vaYTifpes21dlHwLqpPIyk4vO)TvOLrjNK6aJuqtEXNVjAsfHuWB0KWl3ROjLyQaKIhczCJJO2Ooow0eksQd34NrtCYxi5u0u6zTmkXubifpes21dlHwLqJDVF9WIT(d3GClABa0Kg4SeMeVoc9VcTmk5KuhyPRGM0F0f6uWiRNO13PqRsOLEwlJsmvac3q5aWolHdqOBfAPN1YOetfGWnuoaSj9hDwchGqRsOLxOXU3VEyXOetfGu8qizjmjEDe6FfA1mQq)9RqFbPN1Yw)HBqUfTnaAsdC2trOLlAs4L7v0mFfGClsXdHmUXruBuehlAcfj1HB8ZOjo5lKCkAk9SwgLyQaKIhcj76HLqRsOXU3VEyXOetfGu8qizB(auctIxhH(xHMWl3l2PHBxEnGu8qiz4Bk0QeAPN1YYxbi3Iu8qizxpSeAvcn29(1dlw(ka5wKIhcjBZhGsys86i0)k0eE5EXonC7YRbKIhcjdFtHwLqFbPN1Yw)HBqUfTnaAsdC21dROjHxUxrZtd3U8AaP4Hqg34iQPUJJfnHIK6Wn(z0eN8fsofnLEwlJsmvac3q5aWolHdqOBf6GeAvcn2LbfvllGGtovrtcVCVIMkjCGcdi3IM86g34iQfOJJfnHIK6Wn(z0eN8fsofnVG0ZAzR)Wni3I2ganPbo7Pi0Qe6li9Sw26pCdYTOTbqtAGZsys86i0Jl0eE5EXOetfGM8ZH3Hdd(d43cOLpbHwLqREcn2LbfvllGGtovrtcVCVIMkjCGcdi3IM86g34gnT8I6iPxwXXIJOwCSOjuKuhUXpJMeE5EfnPetfGM8ZH3Ht0e3q8kAQw0eN8fsofnLEwld3bkX0z51albcVXnoIrJJfnj8Y9kAsjMkaj1PZgnHIK6Wn(zCJJeiXXIMeE5EfnPetfGKOmPbiAcfj1HB8Z4g34gnLb5H7vCeJgKrdsn1mQ6endPS41WjAgOEurD5iJQJeOYieAHESgqO5tfpxH26PqBSRafKgl0jmkF8eUc9XNGqtV1N0cxHg3q1aCycduFEbcTAgHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwE1(lhtyG6ZlqOvZieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YB0)YXegO(8ceAJAecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbQpVaHoqmcH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqpAgHqBKEjdYfUcTX5RaRNdalWgl0Rl0gNVcSEoaSaZGIK6W1yHMwHwDvGs1xOLxT)YXegO(8ceA1cYieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YB0)YXegO(8ceA1c0gHqBKEjdYfUcTX5RaRNdalWgl0Rl0gNVcSEoaSaZGIK6W1yHwE1(lhtyG6ZlqOvlqBecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfAAfA1vbkvFHwE1(lhtyG6ZlqOnQAgHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwE1(lhtyGWGa1JkQlhzuDKavgHql0J1acnFQ45k0wpfAJjhmwOtyu(4jCf6JpbHMERpPfUcnUHQb4WegO(8ceA1mcH2i9sgKlCfAJxQd1YcSXc96cTXl1HAzbMbfj1HRXcT8g9VCmHbQpVaHwnJqOnsVKb5cxH248vG1ZbGfyJf61fAJZxbwphawGzqrsD4ASqlVA)LJjmq95fi0g1ieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YB0)YXegO(8ce6aXieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YB0)YXegO(8ce6aXieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YR2F5ycduFEbc9OzecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbQpVaHwDmcH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqpQncH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqpkmcH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqRUncH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqhOncH2i9sgKlCfAJxQd1YcSXc96cTXl1HAzbMbfj1HRXcT8g9VCmHbQpVaHwTGmcH2i9sgKlCfAJxQd1YcSXc96cTXl1HAzbMbfj1HRXcT8g9VCmHbQpVaHwTaXieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YB0)YXegO(8ceA1u3gHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwE1(lhtyG6ZlqOvtDBecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbQpVaH2Og1ieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YR2F5ycduFEbcTrnQri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOLxT)YXegO(8ceAJgigHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwE1(lhtyG6ZlqOnAGyecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbcdcupQOUCKr1rcuzecTqpwdi08PINRqB9uOno9LwUxgl0jmkF8eUc9XNGqtV1N0cxHg3q1aCycduFEbcTAgHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwE1(lhtyG6ZlqOnQri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOLxT)YXegO(8ce6rZieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YR2F5ycduFEbcT6yecTr6Lmix4k0gVuhQLfyJf61fAJxQd1YcmdksQdxJfA5v7VCmHbQpVaHoqBecTr6Lmix4k0gVuhQLfyJf61fAJxQd1YcmdksQdxJfA5v7VCmHbQpVaHwTaTri0gPxYGCHRqB8sDOwwGnwOxxOnEPoullWmOiPoCnwOLxT)YXegO(8ceAJgigHqBKEjdYfUcTX5RaRNdalWgl0Rl0gNVcSEoaSaZGIK6W1yHwE1(lhtyG6ZlqOn6OzecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbcdcupQOUCKr1rcuzecTqpwdi08PINRqB9uOn(cw61xJf6egLpEcxH(4tqOP36tAHRqJBOAaomHbQpVaH2OgHqBKEjdYfUcTX5RaRNdalWgl0Rl0gNVcSEoaSaZGIK6W1yHMwHwDvGs1xOLxT)YXegO(8ce6aXieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl00k0QRcuQ(cT8Q9xoMWa1NxGqpAgHqBKEjdYfUcTjFAKc9j4AP)c9O7c96cT6)iH(YLXpCVeAxbsA9uOL)d5eA5v7VCmHbcdcupQOUCKr1rcuzecTqpwdi08PINRqB9uOnwjbSpLO1yHoHr5JNWvOp(eeA6T(Kw4k04gQgGdtyG6ZlqOnQri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOLxT)YXegO(8ce6aXieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YR2F5ycduFEbcTAQJri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOPvOvxfOu9fA5v7VCmHbQpVaHwTrHri0gPxYGCHRqBm2R7JVSaBSqVUqBm2R7JVSaZGIK6W1yHwE1(lhtyG6ZlqOn6OzecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfAAfA1vbkvFHwE1(lhtyG6ZlqOnQ6yecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfAAfA1vbkvFHwE1(lhtyG6ZlqOnAG2ieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YB0)YXegO(8ceAJgOncH2i9sgKlCfAJZxbwphawGnwOxxOnoFfy9CaybMbfj1HRXcT8Q9xoMWa1NxGqpAbIri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOPvOvxfOu9fA5v7VCmHbQpVaHE0gnJqOnsVKb5cxH248vG1ZbGfyJf61fAJZxbwphawGzqrsD4ASqtRqRUkqP6l0YR2F5ycdegeOEurD5iJQJeOYieAHESgqO5tfpxH26PqBm29(1dRJXcDcJYhpHRqF8ji00B9jTWvOXnunahMWa1NxGqRMri0gPxYGCHRqB8sDOwwGnwOxxOnEPoullWmOiPoCnwOL3O)LJjmq95fi0QzecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbQpVaH2OgHqBKEjdYfUcTXl1HAzb2yHEDH24L6qTSaZGIK6W1yHwEJ(xoMWa1NxGqBuJqOnsVKb5cxH248vG1ZbGfyJf61fAJZxbwphawGzqrsD4ASqlVA)LJjmq95fi0bIri0gPxYGCHRqB8sDOwwGnwOxxOnEPoullWmOiPoCnwOL3O)LJjmq95fi0bIri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOLxT)YXegO(8ce6rZieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YR2F5ycduFEbc9O2ieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YB0)YXegO(8ceA1Tri0gPxYGCHRqB8sDOwwGnwOxxOnEPoullWmOiPoCnwOL3O)LJjmq95fi0bAJqOnsVKb5cxH24L6qTSaBSqVUqB8sDOwwGzqrsD4ASqlVr)lhtyG6ZlqOvtnJqOnsVKb5cxH24L6qTSaBSqVUqB8sDOwwGzqrsD4ASqlVr)lhtyG6ZlqOvlqmcH2i9sgKlCfAJxQd1YcSXc96cTXl1HAzbMbfj1HRXcT8Q9xoMWa1NxGqR2OzecTr6Lmix4k0gVuhQLfyJf61fAJxQd1YcmdksQdxJfA5v7VCmHbcdcupQOUCKr1rcuzecTqpwdi08PINRqB9uOn(0qjCr47XyHoHr5JNWvOp(eeA6T(Kw4k04gQgGdtyG6ZlqOvZieAJ0lzqUWvOnEPoullWgl0Rl0gVuhQLfyguKuhUgl0YB0)YXegO(8ce6aXieAJ0lzqUWvOnoFfy9Cayb2yHEDH248vG1ZbGfyguKuhUgl0YR2F5ycduFEbcTAbIri0gPxYGCHRqBC(kW65aWcSXc96cTX5RaRNdalWmOiPoCnwOLxT)YXegO(8ceA1gnJqOnsVKb5cxH248vG1ZbGfyJf61fAJZxbwphawGzqrsD4ASqlVA)LJjmq95fi0QPogHqBKEjdYfUcTX5RaRNdalWgl0Rl0gNVcSEoaSaZGIK6W1yHwE1(lhtyG6ZlqOvBuyecTr6Lmix4k0gNVcSEoaSaBSqVUqBC(kW65aWcmdksQdxJfA5v7VCmHbcdcupQOUCKr1rcuzecTqpwdi08PINRqB9uOnMMOJcnnwOtyu(4jCf6JpbHMERpPfUcnUHQb4WegO(8ceA1mcH2i9sgKlCfAJxQd1YcSXc96cTXl1HAzbMbfj1HRXcT8Q9xoMWaHbJQtfpx4k0QfKqt4L7Lq35N9WegenP324z00KpFDA5EzKjz3OPs6wEhIMJEHwDD0ai0JkjMkqyWOxOhXLbtjifAJQUnuOnAqgniHbcdg9cT6sy6YaHwgLCsQdmAIok0uO5LqBjzEk0UvOpWU8A4WOj6OqtHwECdGdqOd2FPqFuaSq7kl3RJCmHbJEHE0r5slCfAETqwuxOBO6251Gq7wHwgLCsQdSgsgGCfOGRqVUqlbcTAcDyduc9b2LxdhgnrhfAk0TcTAmHbJEHE05ac9gSchtDH2KpnsHUHQBNxdcTBfACdvf0fAETqMpLL7LqZRZc0vODRqBmMkm0reE5EzmtyWOxOvxDoqHHJqNW0LbxHMocTBf6rCzWucsH2OQBHEDHoH7ddcTro62OJql)PZhA2EWYXegimGWl3RdtjbSpLOTvgLCsQdgw0eAvsq517iqMBOR0MWbwdVGLE9TniHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0QKGYR3rGm3qxP9aRHYO(dAvZqUTvgLCsQdmLeuE9ocK5TbPkFfy9CayhUsJxOZ65ufHxUmabfm5W5xJkmGWl3RdtjbSpLO9N2pKrjNK6GHfnHwLeuE9ocK5g6kThynug1FqRAgYTTYOKtsDGPKGYR3rGmVniv5RaRNda7WvA8cDwpNQWUmOOAzfGtV75vfHxUmabfm5W5x1egq4L71HPKa2Ns0(t7hYOKtsDWWIMqRsckVEhbYCdDL2dSgkJ6pOnid52wzuYjPoWusq517iqM3gKWacVCVomLeW(uI2FA)qgLCsQdgw0eABizaYvGcUg6kThynug1FqBqcdi8Y96Wusa7tjA)P9dzuYjPoyyrtOTHKbixbk4AOR0EG1qzu)bTQzi32kJsoj1bwdjdqUcuWTniveE5YaeuWKdNFnQWacVCVomLeW(uI2FA)qgLCsQdgw0eABizaYvGcUg6kThynug1FqRAgYTTYOKtsDG1qYaKRafCBdsLmk5KuhykjO86DeiZBvtyaHxUxhMscyFkr7pTFiJsoj1bdlAcTwErDK0lldDL2dSgkJ6pOniHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0Mh0K(JUqNcgz9eT(on0vAt4aRHxWsV(2Qocdi8Y96Wusa7tjA)P9dzuYjPoyyrtOnpOj9hDHofmY6jkDfdDL2eoWA4fS0RVTQJWacVCVomLeW(uI2FA)qgLCsQdgw0eAZdAs)rxOtbJSEIifdDL2eoWA4fS0RVTgniHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0skOj9hDHofmY6jA9DAOR0MWbwdVGLE9TvTGegq4L71HPKa2Ns0(t7hYOKtsDWWIMqB6kOj9hDHofmY6jA9DAOR0MWbwdVGLE9T1ObjmGWl3RdtjbSpLO9N2pKrjNK6GHfnH213jAs)rxOtbJSEIifdDL2eoWA4fS0RVTbjmGWl3RdtjbSpLO9N2pKrjNK6GHfnH213jAs)rxOtbJSEIifdDL2dSgkJ6pOnqmKBBLrjNK6aB9DIM0F0f6uWiRNisPniv5RaRNda7YpyUsNxugmc7ZjvxHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0U(ort6p6cDkyK1tePyOR0EG1qzu)bTQPogYTTYOKtsDGT(ort6p6cDkyK1teP0gKkSldkQwwXhAwKLaHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0U(ort6p6cDkyK1tePyOR0EG1qzu)bTQPogYTTYOKtsDGT(ort6p6cDkyK1teP0gKkSx3hFzuIPcqkPF5dbRIWlxgGGcMC4mEGimGWl3RdtjbSpLO9N2pKrjNK6GHfnH213jAs)rxOtbJSEIifdDL2dSgkJ6pOvDmKBBLrjNK6aB9DIM0F0f6uWiRNisPniHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0U(ort6p6cDkyK1tu6kg6kTjCG1WlyPxFBnAqcdi8Y96Wusa7tjA)P9dzuYjPoyyrtOvIYKga0KkcPGxdDL2eoWA4fS0RVTbjmGWl3RdtjbSpLO9N2pKrjNK6GHfnHwjktAaqtQiKcEn0vApWAOmQ)Gw5h1bn6s(jDwidgjJ6pqDHAbfKCYzi32kJsoj1bMeLjnaOjvesbVTbPc7YGIQLv8HMfzjqyaHxUxhMscyFkr7pTFiJsoj1bdlAcTsuM0aGMurif8AOR0EG1qzu)bTYRUdA0L8t6Sqgmsg1FG6c1cki5KZqUTvgLCsQdmjktAaqtQiKcEBdsyaHxUxhMscyFkr7pTFiJsoj1bdlAcTKcAYl(8nrtQiKcEn0vAt4aRHxWsV(2gKWacVCVomLeW(uI2FA)qgLCsQdgw0eAjf0Kx85BIMurif8AOR0EG1qzu)bTQtqgYTTYOKtsDGrkOjV4Z3enPIqk4Tniv5RaRNda7YpyUsNxugmc7ZjvxHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0skOjV4Z3enPIqk41qxP9aRHYO(dAvNGmKBBLrjNK6aJuqtEXNVjAsfHuWBBqQYxbwpha2qYp9GrCmh3bHbeE5EDykjG9PeT)0(Hmk5KuhmSOj0skOjV4Z3enPIqk41qxP9aRHYO(dAvtDmKBBLrjNK6aJuqtEXNVjAsfHuWBBqcdi8Y96Wusa7tjA)P9dzuYjPoyyrtOD9DIM0FeUHYb4yOR0MWbwdVGLE9T1Ocdi8Y96Wusa7tjA)P9dzuYjPoyyrtOLxYGCHlYvGcsdDL2eoWA4fS0RVTbjmGWl3RdtjbSpLO9N2pKrjNK6GHfnHwEjdYfUixbkin0vApWAOmQ)Gw1mKBBLrjNK6aJxYGCHlYvGcY2GuTuhQLLVcqUfP4HqQs(L6qTmkXubia34F)QEyxguuTSaco5ujNk5vpSldkQwwb407EE)(LWlxgGGcMC40Q23V5RaRNda7WvA8cDwpNYjmGWl3RdtjbSpLO9N2pKrjNK6GHfnHwEjdYfUixbkin0vApWAOmQ)G2GmKBBLrjNK6aJxYGCHlYvGcY2Gegq4L71HPKa2Ns0(t7hYOKtsDWWIMqlPG8c9oGHUs7bwdLr9h0cJYhxrbUSjHjPeqNgaw08D44VFHr5JROax2qNUCA98GKO7a89lmkFCff4Yg60LtRNh0eUuVZ967xyu(4kkWLDPmGP7f6c4aqkVnHdgkm89lmkFCff4Y41bNVLK6aAu(OAFt0fKXXW3VWO8XvuGl74VEh2LxdO8jf83VWO8XvuGl78kPU7xenHTj4Z(9lmkFCff4YcPaGcYdYMED)(fgLpUIcCz2onbKBrs0UDqyaHxUxhMscyFkr7pTFiJsoj1bdlAcTKdO13jAs)r4gkhGJHUsBchyn8cw613wJkmGWl3RdtjbSpLO9N2pKrjNK6GHfnH2gsgGCfOGRHUs7bwdLr9h0QMHCBRmk5KuhynKma5kqb32GuDGD51WHrt0rHMTQjmGWl3RdtjbSpLO9N2pKrjNK6GHfnHwqMJuWRHUsBchyn8cw613w1uhHbeE5EDykjG9PeT)0(HTtNaegq4L71HPKa2Ns0(t7hw3Vcdi8Y96Wusa7tjA)P9d6nmHAPL7LWacVCVomLeW(uI2FA)GsmvaYstENtPWacVCVomLeW(uI2FA)GsmvaIxl07aEfgq4L71HPKa2Ns0(t7hyVux7LaAsfHgGPWacVCVomLeW(uI2FA)4uKYPXx0zP9imGWl3RdtjbSpLO9N2pM8m9eXN0aimGWl3RdtjbSpLO9N2pSPFwjVVgYTTQNmk5KuhykjO86DeiZBvtv(kW65aWU8dMR05fLbJW(Cs1vyaHxUxhMscyFkr7pTFqjMkaj1PZAi32QEYOKtsDGPKGYR3rGmVvnvQx(kW65aWU8dMR05fLbJW(Cs1vyaHxUxhMscyFkr7pTFaYCmTCVmKBBLrjNK6atjbLxVJazERAcdegq4L715N2pW(RwipkqVBi32Uuoal7cspRLHPZYRbwceEfgq4L715N2pKrjNK6GHfnH2gsgGCfOGRHUs7bwdLr9h0QMHCBRmk5KuhynKma5kqb3XBdsLscYqd4ltngiZX0Y9sL6LVcSEoaSdxPXl0z9CkmGWl3RZpTFiJsoj1bdlAcTnKma5kqbxdDL2dSgkJ6pOvnd52wzuYjPoWAizaYvGcUJ3gKkPN1YOetfGu8qizxpSuHDVF9WIrjMkaP4HqYsys868BqQYxbwpha2HR04f6SEofgq4L715N2pKrjNK6GHfnHwlVOos6LLHUs7bwdLr9h0QMHCBR0ZAzuIPcq4gkha2zjCaTspRLrjMkaHBOCayt6p6SeoavQN0ZAz5Rdi3I2MeGd7POYYhAwuctIxNXBLx(jv0O7eE5EXOetfGK60zzy)SYPUGWl3lgLyQaKuNold(d43cOLpb5egq4L715N2pWuVJi8Y9c15N1WIMq7PHs4IW3JWacVCVo)0(bM6DeHxUxOo)Sgw0eAjhmKBBj8YLbiOGjho)AuHbeE5ED(P9dm17icVCVqD(znSOj06kqbPHCBRmk5KuhynKma5kqb3XBdsyaHxUxNFA)at9oIWl3luNFwdlAcT0eDuOPHCB7b2LxdhgnrhfA2QMWacVCVo)0(bM6DeHxUxOo)Sgw0eAXU3VEyDegq4L715N2pWuVJi8Y9c15N1WIMqB6lTCVmKBBLrjNK6aZYlQJKEz1gKWacVCVo)0(bM6DeHxUxOo)Sgw0eAT8I6iPxwgYTTYOKtsDGz5f1rsVSAvtyaHxUxNFA)at9oIWl3luNFwdlAcTtxgmHAfgimy0l0eE5EDy0eDuOzlMkm0reE5Ezi32s4L7fdK5yA5EXWnuvqNxdQMurmf8(BBGwDegq4L71Hrt0rHM)0(biZX0Y9YqUTDsfXuW74TYOKtsDGbYCKcEvjp29(1dl26pCdYTOTbqtAGZsys86mElHxUxmqMJPL7fd(d43cOLpHVFXU3VEyXOetfGu8qizjmjEDgVLWl3lgiZX0Y9Ib)b8Bb0YNW3VYVuhQLLVcqUfP4HqQc7E)6HflFfGClsXdHKLWK41z8wcVCVyGmhtl3lg8hWVfqlFcYjNkPN1YYxbi3Iu8qizxpSuj9SwgLyQaKIhcj76HLQli9Sw26pCdYTOTbqtAGZUEyjmGWl3RdJMOJcn)P9JlqBJKNfyi32IDVF9WIrjMkaP4HqYsys860gKk5LEwllFfGClsXdHKD9WsL8y37xpSyR)Wni3I2ganPbolHjXRZVYOKtsDGrkOj9hDHofmY6jA9D(9l29(1dl26pCdYTOTbqtAGZsys860gKCYjmGWl3RdJMOJcn)P9Jjptppi3IwpNqTgYTTy37xpSyuIPcqkEiKSeMeVoTbPsEPN1YYxbi3Iu8qizxpSujp29(1dl26pCdYTOTbqtAGZsys868Rmk5KuhyKcAs)rxOtbJSEIwFNF)IDVF9WIT(d3GClABa0Kg4SeMeVoTbjNCcdi8Y96WOj6OqZFA)iPlNQfDuOmaHbeE5EDy0eDuO5pTFCA42Lxdifpesd52wPN1YOetfGu8qizxpSuHDVF9WIrjMkaP4HqY28bOeMeVo)s4L7f70WTlVgqkEiKm8nvj9Sww(ka5wKIhcj76HLkS79RhwS8vaYTifpes2MpaLWK415xcVCVyNgUD51asXdHKHVPQli9Sw26pCdYTOTbqtAGZUEyjmGWl3RdJMOJcn)P9J8vaYTifpesd52wPN1YYxbi3Iu8qizxpSuHDVF9WIrjMkaP4HqYsys868Bqcdi8Y96WOj6OqZFA)y9hUb5w02aOjnWnKBBLh7E)6HfJsmvasXdHKLWK41PnivspRLLVcqUfP4HqYUEyj33VkjidnGVm1y5RaKBrkEiKcdi8Y96WOj6OqZFA)y9hUb5w02aOjnWnKBBXU3VEyXOetfGu8qizjmjEDgxDcsL0ZAz5RaKBrkEiKSRhwQGZbkmWKXpCVqUfPaPfWl3lguKuhUcdi8Y96WOj6OqZFA)GsmvasXdH0qUTv6zTS8vaYTifpes21dlvy37xpSyR)Wni3I2ganPbolHjXRZVYOKtsDGrkOj9hDHofmY6jA9DkmGWl3RdJMOJcn)P9dkXubijktAamKBBLEwlJsmvasXdHK9uuj9SwgLyQaKIhcjlHjXRZ4TeE5EXOetfGM8ZH3Hdd(d43cOLpbvspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4aegq4L71Hrt0rHM)0(bLyQaKNsgYTTspRLrjMkaHBOCayNLWbmU0ZAzuIPcq4gkha2K(JolHdqL0ZAz5RaKBrkEiKSRhwQKEwlJsmvasXdHKD9Ws1fKEwlB9hUb5w02aOjnWzxpSegq4L71Hrt0rHM)0(bLyQaKeLjnagYTTspRLLVcqUfP4HqYUEyPs6zTmkXubifpes21dlvxq6zTS1F4gKBrBdGM0aND9WsL0ZAzuIPcq4gkha2zjCaTspRLrjMkaHBOCayt6p6SeoaHbeE5EDy0eDuO5pTFqjMkan5NdVdhd52wPN1YWDGsmDwEnWsGWRH4gIxTQziqzpyeUH4fIBBLEwld3bkX0z51ac3qvbD21dlvYl9SwgLyQaKIhcj7P89R0ZAz5RaKBrkEiKSNY3Vy37xpSyGmhtl3lwc0ny5egq4L71Hrt0rHM)0(bLyQa0KFo8oCmKBBvpkqbK8fyuIPcqkV5e68AGbfj1H73VspRLH7aLy6S8AaHBOQGo76HLH4gIxTQziqzpyeUH4fIBBLEwld3bkX0z51ac3qvbD21dlvYl9SwgLyQaKIhcj7P89R0ZAz5RaKBrkEiKSNY3Vy37xpSyGmhtl3lwc0ny5egq4L71Hrt0rHM)0(biZX0Y9YqUTv6zTS8vaYTifpes21dlvspRLrjMkaP4HqYUEyP6cspRLT(d3GClABa0Kg4SRhwcdi8Y96WOj6OqZFA)GsmvaYtjd52wPN1YOetfGWnuoaSZs4agx6zTmkXubiCdLdaBs)rNLWbimGWl3RdJMOJcn)P9dkXubijktAaegq4L71Hrt0rHM)0(bLyQaKuNoRWaHbeE5EDyKdT20pRK3xd5228vG1ZbGD5hmxPZlkdgH95KQRkS79RhwmPN1IU8dMR05fLbJW(Cs1LLaDdwL0ZAzx(bZv68IYGryFoP6ISPFw21dlvYl9SwgLyQaKIhcj76HLkPN1YYxbi3Iu8qizxpSuDbPN1Yw)HBqUfTnaAsdC21dl5uHDVF9WIT(d3GClABa0Kg4SeMeVoTbPsEPN1YOetfGWnuoaSZs4agVvgLCsQdmYb067enP)iCdLdWrL8YVuhQLLVcqUfP4HqQc7E)6HflFfGClsXdHKLWK41z82b8vf29(1dlgLyQaKIhcjlHjXRZVYOKtsDGT(ort6p6cDkyK1tePi33VYREl1HAz5RaKBrkEiKQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIif5((f7E)6HfJsmvasXdHKLWK41z82b8vo5egq4L71Hro8t7hwEciPoDwd52w5Zxbwpha2LFWCLoVOmye2NtQUQWU3VEyXKEwl6YpyUsNxugmc7Zjvxwc0nyvspRLD5hmxPZlkdgH95KQlYYtGD9WsLscYqd4ltnMn9Zk59vUVFLpFfy9Cayx(bZv68IYGryFoP6QA5tOni5egq4L71Hro8t7h20plQCzKHCBB(kW65aWgs(PhmIJ54oOc7E)6HfJsmvasXdHKLWK4153ajivy37xpSyR)Wni3I2ganPbolHjXRtBqQKx6zTmkXubiCdLda7SeoGXBLrjNK6aJCaT(ort6pc3q5aCujV8l1HAz5RaKBrkEiKQWU3VEyXYxbi3Iu8qizjmjEDgVDaFvHDVF9WIrjMkaP4HqYsys868Rmk5KuhyRVt0K(JUqNcgz9erkY99R8Q3sDOww(ka5wKIhcPkS79RhwmkXubifpeswctIxNFLrjNK6aB9DIM0F0f6uWiRNisrUVFXU3VEyXOetfGu8qizjmjEDgVDaFLtoHbeE5EDyKd)0(Hn9ZIkxgzi32MVcSEoaSHKF6bJ4yoUdQWU3VEyXOetfGu8qizjmjEDAdsL8Ylp29(1dl26pCdYTOTbqtAGZsys868Rmk5KuhyKcAs)rxOtbJSEIwFNQKEwlJsmvac3q5aWolHdOv6zTmkXubiCdLdaBs)rNLWbi33VYJDVF9WIT(d3GClABa0Kg4SeMeVoTbPs6zTmkXubiCdLda7SeoGXBLrjNK6aJCaT(ort6pc3q5aCKtovspRLLVcqUfP4HqYUEyjNWacVCVomYHFA)y9hUb5w02aOjnWnKBBZxbwpha2HR04f6SEovPKGm0a(YuJbYCmTCVegq4L71Hro8t7huIPcqkEiKgYTT5RaRNda7WvA8cDwpNQKxjbzOb8LPgdK5yA5E99RscYqd4ltn26pCdYTOTbqtAGlNWacVCVomYHFA)aK5yA5Ezi32U8j8BGeKQ8vG1ZbGD4knEHoRNtvspRLrjMkaHBOCayNLWbmERmk5KuhyKdO13jAs)r4gkhGJkS79RhwS1F4gKBrBdGM0aNLWK41Pnivy37xpSyuIPcqkEiKSeMeVoJ3oGVcdi8Y96Wih(P9dqMJPL7LHCB7YNWVbsqQYxbwpha2HR04f6SEovHDVF9WIrjMkaP4HqYsys860gKk5LxES79RhwS1F4gKBrBdGM0aNLWK415xzuYjPoWif0K(JUqNcgz9eT(ovj9SwgLyQaeUHYbGDwchqR0ZAzuIPcq4gkha2K(JolHdqUVFLh7E)6HfB9hUb5w02aOjnWzjmjEDAdsL0ZAzuIPcq4gkha2zjCaJ3kJsoj1bg5aA9DIM0FeUHYb4iNCQKEwllFfGClsXdHKD9Wsod51cz(uwe32k9Sw2HR04f6SEozNLWb0k9Sw2HR04f6SEozt6p6Seoad51cz(uweFoHlNwOvnHbeE5EDyKd)0(XKNPNhKBrRNtOwd52w5XU3VEyXOetfGu8qizjmjED(D0uNVFXU3VEyXOetfGu8qizjmjEDgVnqKtf29(1dl26pCdYTOTbqtAGZsys860gKk5LEwlJsmvac3q5aWolHdy8wzuYjPoWihqRVt0K(JWnuoahvYl)sDOww(ka5wKIhcPkS79RhwS8vaYTifpeswctIxNXBhWxvy37xpSyuIPcqkEiKSeMeVo)QoY99R8Q3sDOww(ka5wKIhcPkS79RhwmkXubifpeswctIxNFvh5((f7E)6HfJsmvasXdHKLWK41z82b8vo5egq4L71Hro8t7hjD5uTOJcLbyi32IDVF9WIT(d3GClABa0Kg4SeMeVoJd)b8Bb0YNGk5LEwlJsmvac3q5aWolHdy8wzuYjPoWihqRVt0K(JWnuoahvYl)sDOww(ka5wKIhcPkS79RhwS8vaYTifpeswctIxNXBhWxvy37xpSyuIPcqkEiKSeMeVo)kJsoj1b267enP)Ol0PGrwprKICF)kV6TuhQLLVcqUfP4HqQc7E)6HfJsmvasXdHKLWK415xzuYjPoWwFNOj9hDHofmY6jIuK77xS79RhwmkXubifpeswctIxNXBhWx5KtyaHxUxhg5WpTFK0Lt1IokugGHCBl29(1dlgLyQaKIhcjlHjXRZ4WFa)waT8jOsE5Lh7E)6HfB9hUb5w02aOjnWzjmjED(vgLCsQdmsbnP)Ol0PGrwprRVtvspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4aK77x5XU3VEyXw)HBqUfTnaAsdCwctIxN2Guj9SwgLyQaeUHYbGDwchW4TYOKtsDGroGwFNOj9hHBOCaoYjNkPN1YYxbi3Iu8qizxpSKtyaHxUxhg5WpTFCbABK8Sad52wS79RhwmkXubifpeswctIxN2GujV8YJDVF9WIT(d3GClABa0Kg4SeMeVo)kJsoj1bgPGM0F0f6uWiRNO13PkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaY99R8y37xpSyR)Wni3I2ganPbolHjXRtBqQKEwlJsmvac3q5aWolHdy8wzuYjPoWihqRVt0K(JWnuoah5KtL0ZAz5RaKBrkEiKSRhwYjmGWl3RdJC4N2pw)HBqUfTnaAsdCd52wPN1YOetfGWnuoaSZs4agVvgLCsQdmYb067enP)iCdLdWrL8YVuhQLLVcqUfP4HqQc7E)6HflFfGClsXdHKLWK41z82b8vf29(1dlgLyQaKIhcjlHjXRZVYOKtsDGT(ort6p6cDkyK1tePi33VYREl1HAz5RaKBrkEiKQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIif5((f7E)6HfJsmvasXdHKLWK41z82b8voHbeE5EDyKd)0(bLyQaKIhcPHCBR8YJDVF9WIT(d3GClABa0Kg4SeMeVo)kJsoj1bgPGM0F0f6uWiRNO13PkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaY99R8y37xpSyR)Wni3I2ganPbolHjXRtBqQKEwlJsmvac3q5aWolHdy8wzuYjPoWihqRVt0K(JWnuoah5KtL0ZAz5RaKBrkEiKSRhwcdi8Y96Wih(P9J8vaYTifpesd52wPN1YYxbi3Iu8qizxpSujV8y37xpSyR)Wni3I2ganPbolHjXRZVgnivspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4aK77x5XU3VEyXw)HBqUfTnaAsdCwctIxN2Guj9SwgLyQaeUHYbGDwchW4TYOKtsDGroGwFNOj9hHBOCaoYjNk5XU3VEyXOetfGu8qizjmjED(vnJ(97fKEwlB9hUb5w02aOjnWzpf5egq4L71Hro8t7hNgUD51asXdH0qUTv6zTmkXubifpes21dlvy37xpSyuIPcqkEiKSnFakHjXRZVeE5EXonC7YRbKIhcjdFtvspRLLVcqUfP4HqYUEyPc7E)6HflFfGClsXdHKT5dqjmjED(LWl3l2PHBxEnGu8qiz4BQ6cspRLT(d3GClABa0Kg4SRhwcdi8Y96Wih(P9dLeoqHbKBrtEDnKBBLEwl7c02i5zbSNIQli9Sw26pCdYTOTbqtAGZEkQUG0ZAzR)Wni3I2ganPbolHjXRZ4TspRLPKWbkmGClAYRlBs)rNLWbOUGWl3lgLyQaKuNold(d43cOLpbHbeE5EDyKd)0(bLyQaKuNoRHCBR0ZAzxG2gjplG9uujV8l1HAzjC8IkmOIWlxgGGcMC4m(Oj33VeE5YaeuWKdNXvh5ujV6LVcSEoamkXubijFkr5Dc1(97s5aSSgG6BdtbV)giQJCcdi8Y96Wih(P9JZtbYYLrcdi8Y96Wih(P9dkXubipLmKBBLEwlJsmvac3q5aWolHdOniHbeE5EDyKd)0(rbBdKOfMkWznKBBLpbBcNgsQdF)QElhhaVgKtL0ZAzuIPcq4gkha2zjCaTspRLrjMkaHBOCayt6p6SeoaHbeE5EDyKd)0(bLyQa0KFo8oCmKBBLEwld3bkX0z51albcVQYxbwphagLyQaeVS8IVbRAPoulJMkDULJPL7LkcVCzackyYHZ4QBHbeE5EDyKd)0(bLyQa0KFo8oCmKBBLEwld3bkX0z51albcVQKpFfy9CayuIPcq8YYl(g83Vl1HAz0uPZTCmTCVKtfHxUmabfm5WzC1ryaHxUxhg5WpTFqjMkab)v6(H7LHCBR0ZAzuIPcq4gkha2zjCaJl9SwgLyQaeUHYbGnP)OZs4aegq4L71Hro8t7huIPcqWFLUF4Ezi32k9SwgLyQaeUHYbGDwchqR0ZAzuIPcq4gkha2K(JolHdqLscYqd4ltngLyQaKeLjnacdi8Y96Wih(P9dkXubijktAamKBBLEwlJsmvac3q5aWolHdOv6zTmkXubiCdLdaBs)rNLWbimGWl3RdJC4N2pazoMwUxgYRfY8PSiUTDsfXuW7VTQB1XqETqMpLfXNt4YPfAvtyGWGrVqp6wY9KV8afGq)o8AqOhs(PhSqZXCChe6q(2i0KctOhDoGqZxHoKVnc967uO9TbYq(bycdi8Y96WWU3VEyDATPFwu5Yid5228vG1ZbGnK8tpyehZXDqf29(1dlgLyQaKIhcjlHjXRZVbsqQWU3VEyXw)HBqUfTnaAsdCwctIxN2GujV0ZAzuIPcq4gkha2zjCaJ3kJsoj1b267enP)iCdLdWrL8YVuhQLLVcqUfP4HqQc7E)6HflFfGClsXdHKLWK41z82b8vf29(1dlgLyQaKIhcjlHjXRZVYOKtsDGT(ort6p6cDkyK1tePi33VYREl1HAz5RaKBrkEiKQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIif5((f7E)6HfJsmvasXdHKLWK41z82b8vo5egq4L71HHDVF9W68t7h20plQCzKHCBB(kW65aWgs(PhmIJ54oOc7E)6HfJsmvasXdHKLWK41PnivYREl1HAzq15dnluW97x5xQd1YGQZhAwOGRQjvetbV)2okcso5ujV8y37xpSyR)Wni3I2ganPbolHjXRZVQfKkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaY99R8y37xpSyR)Wni3I2ganPbolHjXRtBqQKEwlJsmvac3q5aWolHdOni5KtL0ZAz5RaKBrkEiKSRhwQMurmf8(BRmk5KuhyKcAYl(8nrtQiKcEfgq4L71HHDVF9W68t7h20pRK3xd5228vG1ZbGD5hmxPZlkdgH95KQRkS79RhwmPN1IU8dMR05fLbJW(Cs1LLaDdwL0ZAzx(bZv68IYGryFoP6ISPFw21dlvYl9SwgLyQaKIhcj76HLkPN1YYxbi3Iu8qizxpSuDbPN1Yw)HBqUfTnaAsdC21dl5uHDVF9WIT(d3GClABa0Kg4SeMeVoTbPsEPN1YOetfGWnuoaSZs4agVvgLCsQdS13jAs)r4gkhGJk5LFPoullFfGClsXdHuf29(1dlw(ka5wKIhcjlHjXRZ4Td4RkS79RhwmkXubifpeswctIxNFLrjNK6aB9DIM0F0f6uWiRNisrUVFLx9wQd1YYxbi3Iu8qivHDVF9WIrjMkaP4HqYsys868Rmk5KuhyRVt0K(JUqNcgz9erkY99l29(1dlgLyQaKIhcjlHjXRZ4Td4RCYjmGWl3Rdd7E)6H15N2pS8eqsD6SgYTT5RaRNda7YpyUsNxugmc7Zjvxvy37xpSyspRfD5hmxPZlkdgH95KQllb6gSkPN1YU8dMR05fLbJW(Cs1fz5jWUEyPsjbzOb8LPgZM(zL8(kmy0l0Jk9qk4Jq)oGqp5z65rOd5BJqtkmHEu1k0RVtHMFe6eOBWcnDe6qO3nuONuaGqFEji0Rl0y6ScnFfAjW6ji0RVtMWacVCVomS79RhwNFA)yYZ0ZdYTO1ZjuRHCBl29(1dl26pCdYTOTbqtAGZsys860gKkPN1YOetfGWnuoaSZs4agVvgLCsQdS13jAs)r4gkhGJkS79RhwmkXubifpeswctIxNXBhWxHbeE5EDyy37xpSo)0(XKNPNhKBrRNtOwd52wS79RhwmkXubifpeswctIxN2GujV6TuhQLbvNp0Sqb3VFLFPouldQoFOzHcUQMurmf8(B7Oii5KtL8YJDVF9WIT(d3GClABa0Kg4SeMeVo)kJsoj1bgPGM0F0f6uWiRNO13PkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaY99R8y37xpSyR)Wni3I2ganPbolHjXRtBqQKEwlJsmvac3q5aWolHdOni5KtL0ZAz5RaKBrkEiKSRhwQMurmf8(BRmk5KuhyKcAYl(8nrtQiKcEfgm6f6rLEif8rOFhqOVaTnsEwGqhY3gHMuyc9OQvOxFNcn)i0jq3GfA6i0HqVBOqpPaaH(8sqOxxOX0zfA(k0sG1tqOxFNmHbeE5EDyy37xpSo)0(XfOTrYZcmKBBXU3VEyXw)HBqUfTnaAsdCwctIxN2Guj9SwgLyQaeUHYbGDwchW4TYOKtsDGT(ort6pc3q5aCuHDVF9WIrjMkaP4HqYsys86mE7a(kmGWl3Rdd7E)6H15N2pUaTnsEwGHCBl29(1dlgLyQaKIhcjlHjXRtBqQKx9wQd1YGQZhAwOG73VYVuhQLbvNp0SqbxvtQiMcE)TDueKCYPsE5XU3VEyXw)HBqUfTnaAsdCwctIxNFvlivspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4aK77x5XU3VEyXw)HBqUfTnaAsdCwctIxN2Guj9SwgLyQaeUHYbGDwchqBqYjNkPN1YYxbi3Iu8qizxpSunPIyk493wzuYjPoWif0Kx85BIMurif8kmy0l0JohqOpkugGqZTc967uOP6k0KIqtji0Ej04Rqt1vOd9Y4vOLaH(Pi0wpf6Uxdqk0Bdvc92ac9K(l0xOtbBOqpPa41GqFEji0HGq3qYaHMwHUd0zf6n0fAkXubcnUHYb4i0uDf6THwHE9Dk0H0PmEfA11ENvOFh4Yegq4L71HHDVF9W68t7hjD5uTOJcLbyi32IDVF9WIT(d3GClABa0Kg4SeMeVo)kJsoj1bwEqt6p6cDkyK1t067uf29(1dlgLyQaKIhcjlHjXRZVYOKtsDGLh0K(JUqNcgz9erkQKFPoullFfGClsXdHuL8y37xpSy5RaKBrkEiKSeMeVoJd)b8Bb0YNW3Vy37xpSy5RaKBrkEiKSeMeVo)kJsoj1bwEqt6p6cDkyK1tu6kY99R6TuhQLLVcqUfP4HqkNkPN1YOetfGWnuoaSZs4a(1OQUG0ZAzR)Wni3I2ganPbo76HLkPN1YYxbi3Iu8qizxpSuj9SwgLyQaKIhcj76HLWGrVqp6CaH(OqzacDiFBeAsrOdBGsOv8ZHl1bMqpQAf613PqZpcDc0nyHMocDi07gk0tkaqOpVee61fAmDwHMVcTey9ee613jtyaHxUxhg29(1dRZpTFK0Lt1IokugGHCBl29(1dl26pCdYTOTbqtAGZsys86mo8hWVfqlFcQKEwlJsmvac3q5aWolHdy8wzuYjPoWwFNOj9hHBOCaoQWU3VEyXOetfGu8qizjmjEDgxE4pGFlGw(e(HWl3l26pCdYTOTbqtAGZG)a(TaA5tqoHbeE5EDyy37xpSo)0(rsxovl6OqzagYTTy37xpSyuIPcqkEiKSeMeVoJd)b8Bb0YNGk5Lx9wQd1YGQZhAwOG73VYVuhQLbvNp0SqbxvtQiMcE)TDueKCYPsE5XU3VEyXw)HBqUfTnaAsdCwctIxNFLrjNK6aJuqt6p6cDkyK1t067uL0ZAzuIPcq4gkha2zjCaTspRLrjMkaHBOCayt6p6Seoa5((vES79RhwS1F4gKBrBdGM0aNLWK41PnivspRLrjMkaHBOCayNLWb0gKCYPs6zTS8vaYTifpes21dlvtQiMcE)TvgLCsQdmsbn5fF(MOjvesbVYjmy0l0JohqOxFNcDiFBeAsrO5wHMVgFe6q(2WlHEBaHEs)f6l0PGzc9OQvOlFnuOFhqOd5BJqNUIqZTc92ac9sDOwHMFe6LcakdfAQUcnFn(i0H8THxc92ac9K(l0xOtbZegq4L71HHDVF9W68t7hR)Wni3I2ganPbUHCBR0ZAzuIPcq4gkha2zjCaJ3kJsoj1b267enP)iCdLdWrf29(1dlgLyQaKIhcjlHjXRZ4TWFa)waT8jimGWl3Rdd7E)6H15N2pw)HBqUfTnaAsdCd52wPN1YOetfGWnuoaSZs4agVvgLCsQdS13jAs)r4gkhGJQL6qTS8vaYTifpesvy37xpSy5RaKBrkEiKSeMeVoJ3c)b8Bb0YNGkS79RhwmkXubifpeswctIxNFLrjNK6aB9DIM0F0f6uWiRNisryaHxUxhg29(1dRZpTFS(d3GClABa0Kg4gYTTspRLrjMkaHBOCayNLWbmERmk5KuhyRVt0K(JWnuoahvYREl1HAz5RaKBrkEiKF)IDVF9WILVcqUfP4HqYsys868Rmk5KuhyRVt0K(JUqNcgz9eLUICQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIifHbJEHE05acnPi0CRqV(ofA(rO9sOXxHMQRqh6LXRqlbc9trOTEk0DVgGuO3gQe6Tbe6j9xOVqNc2qHEsbWRbH(8sqO3gAf6qqOBizGqdL)gAe6jvKqt1vO3gAf6TbsqO5hHU8vOPEc0nyHMe68vGq7wHwXdHuOVEyXegq4L71HHDVF9W68t7huIPcqkEiKgYTTy37xpSyR)Wni3I2ganPbolHjXRZVYOKtsDGrkOj9hDHofmY6jA9DQs6zTmkXubiCdLda7SeoGwPN1YOetfGWnuoaSj9hDwchGkPN1YYxbi3Iu8qizxpSunPIyk493wzuYjPoWif0Kx85BIMurif8kmy0l0JohqOtxrO5wHE9Dk08Jq7LqJVcnvxHo0lJxHwce6NIqB9uO7EnaPqVnuj0Bdi0t6VqFHofSHc9KcGxdc95LGqVnqccn)ugVcn1tGUbl0KqNVce6RhwcnvxHEBOvOjfHo0lJxHwcW(eeAsgX7Kuhe67l51GqNVcycdi8Y96WWU3VEyD(P9J8vaYTifpesd52wPN1YOetfGu8qizxpSuHDVF9WIT(d3GClABa0Kg4SeMeVo)kJsoj1bw6kOj9hDHofmY6jA9DQs6zTmkXubiCdLda7SeoGwPN1YOetfGWnuoaSj9hDwchGk5XU3VEyXOetfGu8qizjmjED(vnJ(97fKEwlB9hUb5w02aOjnWzpf5egq4L71HHDVF9W68t7hNgUD51asXdH0qUTv6zTmkXubifpes21dlvy37xpSyuIPcqkEiKSnFakHjXRZVeE5EXonC7YRbKIhcjdFtvspRLLVcqUfP4HqYUEyPc7E)6HflFfGClsXdHKT5dqjmjED(LWl3l2PHBxEnGu8qiz4BQ6cspRLT(d3GClABa0Kg4SRhwcdg9cT66do5uzecT6stHMFe6jvKq38QHmyHMQRqpQ85ODeAkbHEDxOH)kqD4YaHEDH(DaHwXNc96c9zu(aiqbi0uj0W)njHMKeAEj0Bdi0RVtHoKxxpKj0QpSgFe63beA(k0Rl0tkaqO7EOqJBOCae6rLppcnVolvltyaHxUxhg29(1dRZpTFOKWbkmGClAYRRHCBR0ZAzuIPcq4gkha2zjCaTbPc7YGIQLfqWjNkHbJEHEeVgDPU(GtovgHqp6CaHwXNc96c9zu(aiqbi0uj0W)njHMKeAEj0Bdi0RVtHoKxxpKjmGWl3Rdd7E)6H15N2pus4afgqUfn511qUT9cspRLT(d3GClABa0Kg4SNIQli9Sw26pCdYTOTbqtAGZsys86moHxUxmkXubOj)C4D4WG)a(TaA5tqL6HDzqr1Yci4KtLWaHbeE5EDywErDK0lRFA)GsmvaAYphEhogYTTspRLH7aLy6S8AGLaHxdXneVAvtyaHxUxhMLxuhj9Y6N2pOetfGK60zfgq4L71Hz5f1rsVS(P9dkXubijktAaegimGWl3RdB6YGju7pTFi15vaiQc2qUTD6YGjul7Yplvy43w1csyaHxUxh20LbtO2FA)qjHduya5w0KxxHbeE5EDytxgmHA)P9dkXubOj)C4D4yi32oDzWeQLD5NLkmmUAbjmGWl3RdB6YGju7pTFqjMka5PKWacVCVoSPldMqT)0(HLNasQtNvyGWacVCVomxbkiBbzoMwUxgYTTYNVcSEoaSdxPXl0z9C(9B(kW65aWwyQ4j1rHuQiNQL6qTS8vaYTifpesvy37xpSy5RaKBrkEiKSeMeVo)gKk5LEwllFfGClsXdHKD9W67xLeKHgWxMAmkXubijktAaKtyaHxUxhMRafK)0(HLNasQtN1qUTnFfy9Cayx(bZv68IYGryFoP6Qs6zTSl)G5kDErzWiSpNuDr20pl7PimGWl3RdZvGcYFA)WM(zrLlJmKBBZxbwpha2qYp9GrCmh3bvtQiMcE)nqRocdi8Y96WCfOG8N2pUaTnsEwGHCBR6LVcSEoaSdxPXl0z9CkmGWl3RdZvGcYFA)iPlNQfDuOmad522jvetbV)oAbjmGWl3RdZvGcYFA)40WTlVgqkEiKgYTTspRLrjMkaP4HqYUEyPc7E)6HfJsmvasXdHKLWK41rL6jJsoj1bgVKb5cxKRafKTQjmGWl3RdZvGcYFA)GsmvaYtjd52wzuYjPoW4Lmix4ICfOGSvnvy37xpSy5RaKBrkEiKSeMeVoTbjmGWl3RdZvGcYFA)GsmvasQtN1qUTvgLCsQdmEjdYfUixbkiBvtf29(1dlw(ka5wKIhcjlHjXRtBqQKEwlJsmvac3q5aWolHdyCPN1YOetfGWnuoaSj9hDwchGWacVCVomxbki)P9J8vaYTifpesd52wzuYjPoW4Lmix4ICfOGSvnvspRLLVcqUfP4HqYUEyjmGWl3RdZvGcYFA)qXxUxgYTTYOKtsDGXlzqUWf5kqbzRAQup5Zxbwpha2HR04f6SEo)(nFfy9Caylmv8K6OqkvKtyaHxUxhMRafK)0(XfOTrYZcmKBBLEwllFfGClsXdHKD9WsyaHxUxhMRafK)0(XKNPNhKBrRNtOwd52wPN1YYxbi3Iu8qizxpS((vjbzOb8LPgJsmvasIYKgaHbeE5EDyUcuq(t7hR)Wni3I2ganPbUHCBR0ZAz5RaKBrkEiKSRhwF)QKGm0a(YuJrjMkajrzsdGWacVCVomxbki)P9dkXubifpesd52wLeKHgWxMAS1F4gKBrBdGM0axyaHxUxhMRafK)0(r(ka5wKIhcPHCBR0ZAz5RaKBrkEiKSRhwcdi8Y96WCfOG8N2pus4afgqUfn511qUT9cspRLT(d3GClABa0Kg4SNIQli9Sw26pCdYTOTbqtAGZsys86moHxUxmkXubOj)C4D4WG)a(TaA5tqyaHxUxhMRafK)0(bLyQaKuNoRHCB71xwsxovl6OqzaSeMeVo)QoF)EbPN1Ys6YPArhfkdaj71lijjENVbZolHd43Gegq4L71H5kqb5pTFqjMkaj1PZAi32k9SwMschOWaYTOjVUSNIQli9Sw26pCdYTOTbqtAGZEkQUG0ZAzR)Wni3I2ganPbolHjXRZ4TeE5EXOetfGK60zzWFa)waT8jimGWl3RdZvGcYFA)GsmvasIYKgad52wPN1YYxbi3Iu8qizpfvy37xpSyuIPcqkEiKSeOBWQMurmf8o(OfKkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaQuV8vG1ZbGD4knEHoRNtvQx(kW65aWwyQ4j1rHuQimGWl3RdZvGcYFA)GsmvasIYKgad52wPN1YYxbi3Iu8qizpfvspRLrjMkaP4HqYUEyPs6zTS8vaYTifpeswctIxNXBhWxvspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4aujJsoj1bgVKb5cxKRafKcdi8Y96WCfOG8N2pOetfGM8ZH3HJHCB7fKEwlB9hUb5w02aOjnWzpfvl1HAzuIPcqaUXvjV0ZAzxG2gjplGD9W67xcVCzackyYHtRAYP6cspRLT(d3GClABa0Kg4SeMeVo)s4L7fJsmvaAYphEhom4pGFlGw(eujV6rbkGKVaJsmvas5nNqNxdmOiPoC)(v6zTmChOetNLxdiCdvf0zxpSKZqCdXRw1meOShmc3q8cXTTspRLH7aLy6S8AaHBOQGo76HLk5LEwlJsmvasXdHK9u((vE1BPoulZLbPIhcjCvjV0ZAz5RaKBrkEiKSNY3Vy37xpSyGmhtl3lwc0ny5KtoHbeE5EDyUcuq(t7huIPcqt(5W7WXqUTv6zTmChOetNLxdSei8Qc7E)6HfJsmvasXdHKLWK41rL8spRLLVcqUfP4HqYEkF)k9SwgLyQaKIhcj7PiNH4gIxTQjmGWl3RdZvGcYFA)GsmvaYtjd52wPN1YOetfGWnuoaSZs4agVvgLCsQdS13jAs)r4gkhGJk5XU3VEyXOetfGu8qizjmjED(vTG((LWlxgGGcMC4mERrLtyaHxUxhMRafK)0(bLyQaKuNoRHCBR0ZAz5RaKBrkEiKSNY3VtQiMcE)vn1ryaHxUxhMRafK)0(biZX0Y9YqUTv6zTS8vaYTifpes21dlvspRLrjMkaP4HqYUEyziVwiZNYI422jvetbV)2QUvhd51cz(uweFoHlNwOvnHbeE5EDyUcuq(t7huIPcqsuM0aimqyWOxOj8Y96WsFPL71pTFGPcdDeHxUxgYTTeE5EXazoMwUxmCdvf051GQjvetbV)2gOvhvYRE5RaRNda7WvA8cDwpNF)k9Sw2HR04f6SEozNLWb0k9Sw2HR04f6SEozt6p6Seoa5egq4L71HL(sl3RFA)aK5yA5Ezi32oPIyk4D8wzuYjPoWazosbVQKh7E)6HfB9hUb5w02aOjnWzjmjEDgVLWl3lgiZX0Y9Ib)b8Bb0YNW3Vy37xpSyuIPcqkEiKSeMeVoJ3s4L7fdK5yA5EXG)a(TaA5t47x5xQd1YYxbi3Iu8qivHDVF9WILVcqUfP4HqYsys86mElHxUxmqMJPL7fd(d43cOLpb5KtL0ZAz5RaKBrkEiKSRhwQKEwlJsmvasXdHKD9Ws1fKEwlB9hUb5w02aOjnWzxpSmKxlK5tzrCB7KkIPG3FBd0QJk5vV8vG1ZbGD4knEHoRNZVFLEwl7WvA8cDwpNSZs4aALEwl7WvA8cDwpNSj9hDwchGCgYRfY8PSi(CcxoTqRAcdi8Y96WsFPL71pTFaYCmTCVmKBBZxbwpha2HR04f6SEovHDVF9WIrjMkaP4HqYsys86mElHxUxmqMJPL7fd(d43cOLpbHbJEH(tktAaeAUvO5RXhHE5tqOxxOFhqOxFNcnvxHoee6gsgi0R7c9KQGfACdLdWryaHxUxhw6lTCV(P9dkXubijktAamKBBXU3VEyXw)HBqUfTnaAsdCwc0nyvYl9SwgLyQaeUHYbGDwchWVYOKtsDGT(ort6pc3q5aCuHDVF9WIrjMkaP4HqYsys86mEl8hWVfqlFcYjmGWl3Rdl9LwUx)0(bLyQaKeLjnagYTTy37xpSyR)Wni3I2ganPbolb6gSk5LEwlJsmvac3q5aWolHd4xzuYjPoWwFNOj9hHBOCaoQwQd1YYxbi3Iu8qivHDVF9WILVcqUfP4HqYsys86mEl8hWVfqlFcQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIif5egq4L71HL(sl3RFA)GsmvasIYKgad52wS79RhwS1F4gKBrBdGM0aNLaDdwL8spRLrjMkaHBOCayNLWb8Rmk5KuhyRVt0K(JWnuoahvYREl1HAz5RaKBrkEiKF)IDVF9WILVcqUfP4HqYsys868Rmk5KuhyRVt0K(JUqNcgz9eLUICQWU3VEyXOetfGu8qizjmjED(vgLCsQdS13jAs)rxOtbJSEIif5egq4L71HL(sl3RFA)GsmvasIYKgad522li9Swwsxovl6OqzaizVEbjjX78ny2zjCaTxq6zTSKUCQw0rHYaqYE9cssI35BWSj9hDwchGk5LEwlJsmvasXdHKD9W67xPN1YOetfGu8qizjmjEDgVDaFLtL8spRLLVcqUfP4HqYUEy99R0ZAz5RaKBrkEiKSeMeVoJ3oGVYjmGWl3Rdl9LwUx)0(bLyQaKuNoRHCB71xwsxovl6OqzaSeMeVo)QU)(v(li9Swwsxovl6OqzaizVEbjjX78ny2zjCa)gKQli9Swwsxovl6OqzaizVEbjjX78ny2zjCaJFbPN1Ys6YPArhfkdaj71lijjENVbZM0F0zjCaYjmGWl3Rdl9LwUx)0(bLyQaKuNoRHCBR0ZAzkjCGcdi3IM86YEkQUG0ZAzR)Wni3I2ganPbo7PO6cspRLT(d3GClABa0Kg4SeMeVoJ3s4L7fJsmvasQtNLb)b8Bb0YNGWacVCVoS0xA5E9t7huIPcqt(5W7WXqUT9cspRLT(d3GClABa0Kg4SNIQL6qTmkXubia34QKx6zTSlqBJKNfWUEy99lHxUmabfm5WPvn5uj)fKEwlB9hUb5w02aOjnWzjmjED(LWl3lgLyQa0KFo8oCyWFa)waT8j89l29(1dlMschOWaYTOjVUSeMeVo)g03VyxguuTSaco5ujNk5vpkqbK8fyuIPcqkV5e68AGbfj1H73VspRLH7aLy6S8AaHBOQGo76HLCgIBiE1QMHaL9Gr4gIxiUTv6zTmChOetNLxdiCdvf0zxpSujV0ZAzuIPcqkEiKSNY3VYREl1HAzUmiv8qiHRk5LEwllFfGClsXdHK9u((f7E)6HfdK5yA5EXsGUblNCYjmGWl3Rdl9LwUx)0(bLyQa0KFo8oCmKBBLEwld3bkX0z51albcVQKEwld(Rq1fUifFHA5uN9uegq4L71HL(sl3RFA)GsmvaAYphEhogYTTspRLH7aLy6S8AGLaHxvYl9SwgLyQaKIhcj7P89R0ZAz5RaKBrkEiKSNY3Vxq6zTS1F4gKBrBdGM0aNLWK415xcVCVyuIPcqt(5W7WHb)b8Bb0YNGCgIBiE1QMWacVCVoS0xA5E9t7huIPcqt(5W7WXqUTv6zTmChOetNLxdSei8Qs6zTmChOetNLxdSZs4aALEwld3bkX0z51aBs)rNLWbyiUH4vRAcdi8Y96WsFPL71pTFqjMkan5NdVdhd52wPN1YWDGsmDwEnWsGWRkPN1YWDGsmDwEnWsys86mER8Yl9SwgUduIPZYRb2zjCaQli8Y9IrjMkan5NdVdhg8hWVfqlFcY9Za(kNH4gIxTQjmGWl3Rdl9LwUx)0(rbBdKOfMkWznKBBLpbBcNgsQdF)QElhhaVgKtL0ZAzuIPcq4gkha2zjCaTspRLrjMkaHBOCayt6p6SeoavspRLrjMkaP4HqYUEyP6cspRLT(d3GClABa0Kg4SRhwcdi8Y96WsFPL71pTFqjMka5PKHCBR0ZAzuIPcq4gkha2zjCaJ3kJsoj1b267enP)iCdLdWryaHxUxhw6lTCV(P9JZtbYYLrgYTTtQiMcEhVnqRoQKEwlJsmvasXdHKD9WsL0ZAz5RaKBrkEiKSRhwQUG0ZAzR)Wni3I2ganPbo76HLWacVCVoS0xA5E9t7huIPcqsD6SgYTTspRLLVoGClABsaoSNIkPN1YOetfGWnuoaSZs4a(nqegq4L71HL(sl3RFA)GsmvasIYKgad522jvetbVJ3kJsoj1bMeLjnaOjvesbVQKEwlJsmvasXdHKD9WsL0ZAz5RaKBrkEiKSRhwQUG0ZAzR)Wni3I2ganPbo76HLkPN1YOetfGWnuoaSZs4aALEwlJsmvac3q5aWM0F0zjCaQWU3VEyXazoMwUxSeMeVo)gKWacVCVoS0xA5E9t7huIPcqsuM0ayi32k9SwgLyQaKIhcj76HLkPN1YYxbi3Iu8qizxpSuDbPN1Yw)HBqUfTnaAsdC21dlvspRLrjMkaHBOCayNLWb0k9SwgLyQaeUHYbGnP)OZs4auTuhQLrjMka5PKkS79RhwmkXubipLyjmjEDgVDaFvnPIyk4D82aDqQWU3VEyXazoMwUxSeMeVocdi8Y96WsFPL71pTFqjMkajrzsdGHCBR0ZAzuIPcqkEiKSNIkPN1YOetfGu8qizjmjEDgVDaFvj9SwgLyQaeUHYbGDwchqR0ZAzuIPcq4gkha2K(JolHdqf29(1dlgiZX0Y9ILWK41ryaHxUxhw6lTCV(P9dkXubijktAamKBBLEwllFfGClsXdHK9uuj9SwgLyQaKIhcj76HLkPN1YYxbi3Iu8qizjmjEDgVDaFvj9SwgLyQaeUHYbGDwchqR0ZAzuIPcq4gkha2K(JolHdqf29(1dlgiZX0Y9ILWK41ryaHxUxhw6lTCV(P9dkXubijktAamKBBLEwlJsmvasXdHKD9WsL0ZAz5RaKBrkEiKSRhwQUG0ZAzR)Wni3I2ganPbo7PO6cspRLT(d3GClABa0Kg4SeMeVoJ3oGVQKEwlJsmvac3q5aWolHdOv6zTmkXubiCdLdaBs)rNLWbimGWl3Rdl9LwUx)0(bLyQaKeLjnagYTTlLdWYAaQVnmf8oEGOoQKEwlJsmvac3q5aWolHdOv6zTmkXubiCdLdaBs)rNLWbOkFfy9CayuIPcqs(uIY7eQvfHxUmabfm5W5x1uj9Sw2fOTrYZcyxpSegq4L71HL(sl3RFA)Gsmvac(R09d3ld522LYbyzna13gMcEhpquhvspRLrjMkaHBOCayNLWbmU0ZAzuIPcq4gkha2K(JolHdqv(kW65aWOetfGK8PeL3juRkcVCzackyYHZVQPs6zTSlqBJKNfWUEyjmGWl3Rdl9LwUx)0(bLyQaKuNoRWacVCVoS0xA5E9t7hGmhtl3ld52wPN1YYxbi3Iu8qizxpSuj9SwgLyQaKIhcj76HLQli9Sw26pCdYTOTbqtAGZUEyjmGWl3Rdl9LwUx)0(bLyQaKeLjnacdegq4L71HDAOeUi898t7hVdGMurObyAi32k)sDOwguD(qZcfCvnPIyk4D8w1DqQMurmf8(B7OwDK77x5vVL6qTmO68HMfk4QAsfXuW74TQB1roHbeE5EDyNgkHlcFp)0(HIVCVmKBBLEwlJsmvasXdHK9uegq4L71HDAOeUi898t7hlFcOqkvmKBBZxbwpha2ctfpPokKsfvspRLb)BO3z5EXEkQKh7E)6HfJsmvasXdHKLaDd(7xlFOzrjmjEDgVD0csoHbeE5EDyNgkHlcFp)0(rNp0ShK6AV7WeQ1qUTv6zTmkXubifpes21dlvspRLLVcqUfP4HqYUEyP6cspRLT(d3GClABa0Kg4SRhwcdi8Y96Wonucxe(E(P9djAa5w0MCCahd52wPN1YOetfGu8qizxpSuj9Sww(ka5wKIhcj76HLQli9Sw26pCdYTOTbqtAGZUEyjmGWl3Rd70qjCr475N2pKG8aza8AWqUTv6zTmkXubifpes2tryaHxUxh2PHs4IW3ZpTFi1D)ISVmyd52wPN1YOetfGu8qizpfHbeE5EDyNgkHlcFp)0(HLNGu39RHCBR0ZAzuIPcqkEiKSNIWacVCVoStdLWfHVNFA)GkmC2K6im17gYTTspRLrjMkaP4HqYEkcdi8Y96Wonucxe(E(P9J3bq8fMhd52wPN1YOetfGu8qizpfHbeE5EDyNgkHlcFp)0(X7ai(ctdbRfWlQOj0o0PlNwppij6oagYTTspRLrjMkaP4HqYEkF)IDVF9WIrjMkaP4HqYsys868BR6OoQUG0ZAzR)Wni3I2ganPbo7PimGWl3Rd70qjCr475N2pEhaXxyAyrtOfMkbNa1rEElQWGHCBl29(1dlgLyQaKIhcjlHjXRZ4TgniHbeE5EDyNgkHlcFp)0(X7ai(ctdlAcT3eORLNasgCoq3qUTf7E)6HfJsmvasXdHKLWK4153wJg03VQNmk5KuhyKcYl07aTQ99R8lFcTbPsgLCsQdmEjdYfUixbkiBvtv(kW65aWoCLgVqN1ZPCcdi8Y96Wonucxe(E(P9J3bq8fMgw0eAp(RJ4dfFH0qUTf7E)6HfJsmvasXdHKLWK4153wJg03VQNmk5KuhyKcYl07aTQ99R8lFcTbPsgLCsQdmEjdYfUixbkiBvtv(kW65aWoCLgVqN1ZPCcdi8Y96Wonucxe(E(P9J3bq8fMgw0eAh6bR0GClIoh(K3PL7LHCBl29(1dlgLyQaKIhcjlHjXRZVTgnOVFvpzuYjPoWifKxO3bAv77x5x(eAdsLmk5Kuhy8sgKlCrUcuq2QMQ8vG1ZbGD4knEHoRNt5egq4L71HDAOeUi898t7hVdG4lmnSOj0ojmjLa60aWIMVdhBi32IDVF9WIrjMkaP4HqYsys86mER6OsE1tgLCsQdmEjdYfUixbkiBv773LpHFdKGKtyaHxUxh2PHs4IW3ZpTF8oaIVW0WIMq7KWKucOtdalA(oCSHCBl29(1dlgLyQaKIhcjlHjXRZ4TQJkzuYjPoW4Lmix4ICfOGSvnvspRLLVcqUfP4HqYEkQKEwllFfGClsXdHKLWK41z8w5vlOrxQJ6I8vG1ZbGD4knEHoRNt5uT8jmEGeuCJBmc]] )


end
