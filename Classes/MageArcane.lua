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

            toggle = "essences",

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


    spec:RegisterPack( "Arcane", 20201124, [[dWKcafqisQ0Jea4scevLnHQ8jkQgfQQofQkRsrvv9kvvmlks3srvLSlu(LQsnmb0XiPSmbONjaAAkQkxJKk2MIQOVjqKXja05uuLADKuL5POY9Ks7tvLoOIQGfQQKhkq4IcaQpkquCsfvvSskIxkquLMjjv1nfiQIDQO4NceLgQarv1svuvLNsHPQO0vfaKVkquzScK2Rq)fYGj1HrwmQ8yOMSsDzWMP0NvKrlfNMOvROQs9AkkZwHBlv7w0VPA4K44kQswUKNRKPRY1vLTts(UGgVQQoVa16vufA(Qk2pHJQfNnASPdIZeWadyGQPwaNpwadq1cGbQorJlyfiAOqyZOjiAKuhIgZdfMsiAOqbpCAhNnAS8xHHOrZDkl177VNKxZJJH9(3lz)nOt6jUi799s2XFhn4EYXn)KrUOXMoiotadmGbQMAbC(ybmavliP28oASuaCCM5zaJgnY9gYix0ydlC0iaqOdYdnbc98qHPeeMeai0Z4QGohucDaNptf6agyaduyIWKaaHE(d6UkqOvrLK4gaJ6OLc1fAzk0wsLxcTBf6fCNmNwmQJwkuxO5h3ayZe6G9xj0lfal0UYj9CXhtysaGqhaszthSfAzEqL0qOBOCpK5Kq7wHwfvsIBaSgsfGCfiHTqFUqZbcTAcDydKc9cUtMtlg1rlfQl0TcTAmHjbacDaOfi0xWksmneAdzpie6gk3dzoj0UvOXnuMWqOL5bv9uoPNcTmxhqBH2TcT5ykXWar4t6P5SOXqUUvC2OHRajuXzJZOwC2ObKe3a2XVIg4sEqjPOb)cD9sW61eWwsLgprRZRodsIBaBH(ZhHUEjy9Acyh0v8IgOqQuyqsCdyl08j08e6JgqES6LaYTifpekgKe3a2cnpHg7(y7HjREjGClsXdHIvqNK5sO)vOduO5j08l0CpRLvVeqUfP4HqX2Eyk0F(i0kfOcnH3m1yuHPeqCuv0ei08fni8j9mAaQCmDspJxCMagNnAajXnGD8RObUKhuskAuVeSEnbSTCHLkdzsvWiS37uUzqsCdyl08eAUN1Y2YfwQmKjvbJWEVt5gzlFDSNs0GWN0ZOHvwaIBqRlEXzcW4SrdijUbSJFfnWL8GssrJ6LG1RjGnvY1iyKelXdGbjXnGTqZtO7usmf8j0)k0ZB1jAq4t6z0Ww(6qPRIIxCM5loB0asIBa74xrdCjpOKu0qDf66LG1RjGTKknEIwNxDgKe3a2rdcFspJgBGUgoVsiEXzuN4SrdijUbSJFfnWL8GssrJoLetbFc9Vc98fy0GWN0ZOrrBjLhAPqLzXloZ8moB0asIBa74xrdCjpOKu0y5VbNm3mRegBKBrCdFT8(IbjXnGD0GWN0ZOXQrApzoHu8qOIxCMGuC2ObKe3a2XVIg4sEqjPOHkQKe3ayYufuhSrUcKqj0TcTAcnpHg7(y7HjREjGClsXdHIvqNK5sOBf6aJge(KEgnOctjG8IlEXzcGXzJgqsCdyh)kAGl5bLKIgQOssCdGjtvqDWg5kqcLq3k0Qj08eAS7JThMS6LaYTifpekwbDsMlHUvOduO5j0CpRLrfMsaHBOAcyRJWMj0Zj0CpRLrfMsaHBOAcyD6pADe2SObHpPNrdQWuciUbTU4fNzEhNnAajXnGD8RObUKhuskAOIkjXnaMmvb1bBKRajucDRqRMqZtO5EwlREjGClsXdHIT9WmAq4t6z0OEjGClsXdHkEXzulW4SrdijUbSJFfnWL8GssrdUN1YQxci3Iu8qOyBpmJge(KEgn2aDnCELq8IZOMAXzJgqsCdyh)kAGl5bLKIgCpRLvVeqUfP4HqX2Eyk0F(i0kfOcnH3m1yuHPeqCuv0eeni8j9mA0Lv51c5w05vhYlEXzulGXzJgqsCdyh)kAGl5bLKIgCpRLvVeqUfP4HqX2Eyk0F(i0kfOcnH3m1yuHPeqCuv0eeni8j9mAC(d3GCl6AauNMKXloJAbyC2ObKe3a2XVIg4sEqjPOHsbQqt4ntn25pCdYTORbqDAsgni8j9mAqfMsaP4HqfV4mQnFXzJgqsCdyh)kAGl5bLKIgCpRLvVeqUfP4HqX2Eygni8j9mAuVeqUfP4HqfV4mQPoXzJgqsCdyh)kAGl5bLKIgBG7zTSZF4gKBrxdG60KK9ueAEc9g4Ewl78hUb5w01aOonjzf0jzUe65eAcFspzuHPeqD5AjhWIb)b87a0j7q0GWN0ZOHsbliXaYTOUm3XloJAZZ4SrdijUbSJFfnWL8GssrJTFSI2skp0sHkZyf0jzUe6FfA1rO)8rO3a3ZAzfTLuEOLcvMHu9gjueNCiVGzRJWMj0)k0bgni8j9mAqfMsaXnO1fV4mQfKIZgnGK4gWo(v0axYdkjfn4EwltPGfKya5wuxMB2trO5j0BG7zTSZF4gKBrxdG60KK9ueAEc9g4Ewl78hUb5w01aOonjzf0jzUe65AfAcFspzuHPeqCdADm4pGFhGozhIge(KEgnOctjG4g06IxCg1cGXzJgqsCdyh)kAGl5bLKIgCpRLvVeqUfP4HqXEkcnpHg7(y7HjJkmLasXdHIvaTdwO5j0DkjMc(e65e65lqHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqRUcD9sW61eWwsLgprRZRodsIBaBHMNqRUcD9sW61eWoOR4fnqHuPWGK4gWoAq4t6z0GkmLaIJQIMG4fNrT5DC2ObKe3a2XVIg4sEqjPOb3ZAz1lbKBrkEiuSNIqZtO5EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqXkOtYCj0Z1k0t4TqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZtOvrLK4gatMQG6GnYvGeQObHpPNrdQWucioQkAcIxCMagyC2ObKe3a2XVIg4gsMrd1IgavJGr4gsMiPnAW9SwgEauHP1jZjeUHYegSThM84N7zTmQWucifpek2t5Zh(v3JgqEmxfukEiuWMh)CpRLvVeqUfP4HqXEkF(GDFS9WKbQCmDspzfq7G5Jp(Ig4sEqjPOXg4Ewl78hUb5w01aOonjzpfHMNqF0aYJrfMsab4gNbjXnGTqZtO5xO5EwlBd01W5vcSThMc9NpcnHpPkabj0LWsOBfA1eA(eAEc9g4Ewl78hUb5w01aOonjzf0jzUe6FfAcFspzuHPeqD5AjhWIb)b87a0j7GqZtO5xOvxHMMhHsEaJkmLas517WqMtmijUbSf6pFeAUN1YWdGkmTozoHWnuMWGT9WuO5lAq4t6z0GkmLaQlxl5awXlotavloB0asIBa74xrdcFspJguHPeqD5AjhWkAGBizgnulAGl5bLKIgCpRLHhavyADYCIvaHpHMNqJDFS9WKrfMsaP4HqXkOtYCj08eA(fAUN1YQxci3Iu8qOypfH(ZhHM7zTmQWucifpek2trO5lEXzcyaJZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntONRvOvrLK4ga78RJ60FeUHQjyj08eA(fAS7JThMmQWucifpekwbDsMlH(xHwTaf6pFeAcFsvacsOlHLqpxRqhqHMVObHpPNrdQWuciV4IxCMagGXzJgqsCdyh)kAGl5bLKIgCpRLvVeqUfP4HqXEkc9NpcDNsIPGpH(xHwn1jAq4t6z0GkmLaIBqRlEXzc48fNnAajXnGD8RObHpPNrdqLJPt6z0qMhu1t5qsB0OtjXuW3VTbq1jAiZdQ6PCizVdBjDq0qTObUKhuskAW9Sww9sa5wKIhcfB7Hz8IZeq1joB0GWN0ZObvykbehvfnbrdijUbSJFfV4fnG1csmSIZgNrT4SrdijUbSJFfnWL8GssrdS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayNFDuN(JWnunblHMNqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0t4Tq)5JqBLtnhQGojZLqpNqJDFS9WKrfMsaP4HqXkOtYCfni8j9mAWnCFJCl6AaeKqp44fNjGXzJgqsCdyh)kAGl5bLKIgy3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5xOvxH(ObKhdYHCQ5Ge2mijUbSf6pFeA(f6JgqEmihYPMdsyZGK4gWwO5j0DkjMc(e6FBf6GuGc9NpcTkQKe3ayuhTuOUq3k0Qj08j08j08eA(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaJuqD6pAddkyK1l05xxO5j08l0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO)8rOvrLK4gaJ6OLc1f6wHwnHMpHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMq3k0bk08j08j08eAUN1YQxci3Iu8qOyBpmfAEcDNsIPGpH(3wHwfvsIBamsb1LPS)6OoLesbFrdcFspJgCd33i3IUgabj0doEXzcW4SrdijUbSJFfnWL8GssrdS7JThMmQWucifpekwbDsMlH(3wHwDcuO5j0y3hBpmzN)Wni3IUga1PjjRGojZLqpxRqpH3cnpHM7zTmQWuciCdvtaBDe2mHEUwHwfvsIBaSZVoQt)r4gQMGLqZtOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMS6LaYTifpekwbDsMlHEUwHEcVfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKs0GWN0ZOrOxJTkqMOcwEsjgIxCM5loB0asIBa74xrdCjpOKu0a7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEl0F(i0w5uZHkOtYCj0Zj0y3hBpmzuHPeqkEiuSc6KmxrdcFspJgHEn2QazIky5jLyiEXzuN4SrdijUbSJFfnWL8GssrdS7JThMmQWucifpekwbDsMlHUvOduO5j08l0QRqF0aYJb5qo1CqcBgKe3a2c9Npcn)c9rdipgKd5uZbjSzqsCdyl08e6oLetbFc9VTcDqkqH(ZhHwfvsIBamQJwkuxOBfA1eA(eA(eAEcn)cn)cn29X2dt25pCdYTORbqDAsYkOtYCj0)k0QOssCdGrkOo9hTHbfmY6f68Rl08eA(fAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj0F(i0QOssCdGrD0sH6cDRqRMqZNqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntOBf6afA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnpHUtjXuWNq)BRqRIkjXnagPG6Yu2FDuNscPGVObHpPNrJqVgBvGmrfS8KsmeV4mZZ4SrdijUbSJFfnWL8GssrdS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayNFDuN(JWnunblHMNqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0t4Tq)5JqBLtnhQGojZLqpNqJDFS9WKrfMsaP4HqXkOtYCfni8j9mAm9OAlPe5wenpcLFnXlotqkoB0asIBa74xrdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sOBf6afAEcn)cT6k0hnG8yqoKtnhKWMbjXnGTq)5JqZVqF0aYJb5qo1CqcBgKe3a2cnpHUtjXuWNq)BRqhKcuO)8rOvrLK4gaJ6OLc1f6wHwnHMpHMpHMNqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcTkQKe3ayKcQt)rByqbJSEHo)6cnpHMFHM7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzc9NpcTkQKe3ayuhTuOUq3k0Qj08j08j0F(i08l0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe6wHoqHMpHMpHMNqZ9Sww9sa5wKIhcfB7HPqZtO7usmf8j0)2k0QOssCdGrkOUmL9xh1PKqk4lAq4t6z0y6r1wsjYTiAEek)AIxCMayC2ObKe3a2XVIge(KEgnWEIH8k6GnYoOoenWL8GssrdUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMcnpHUtjXozhqNJ60FH(3wHg(d43bOt2HOXqMacVJgZZ4fNzEhNnAajXnGD8RObUKhuskAW9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0Dkj2j7a6CuN(l0)2k0WFa)oaDYoeni8j9mAuaPiZjKDqDyfV4mQfyC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dZObHpPNrdRJFlyJO5rOKhG4aQhV4mQPwC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dZObHpPNrdLxjTblZje3Gwx8IZOwaJZgnGK4gWo(v0axYdkjfn4EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqX2Eyk08e6nW9Sw25pCdYTORbqDAsY2Eygni8j9mAusfLbGKjAPqyiEXzulaJZgnGK4gWo(v0axYdkjfn4EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqX2Eyk08e6nW9Sw25pCdYTORbqDAsY2Eygni8j9mACna6LC(l3iRxyiEXzuB(IZgnGK4gWo(v0axYdkjfn4EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqX2Eyk08e6nW9Sw25pCdYTORbqDAsY2Eygni8j9mA0HUxbJClA8WYnAxa1xXlErdYH4SXzuloB0asIBa74xrdCjpOKu0OEjy9AcyB5clvgYKQGryV3PCZGK4gWwO5j0y3hBpmzCpRfTLlSuzitQcgH9ENYnRaAhSqZtO5EwlBlxyPYqMufmc79oLBKT81X2Eyk08eA(fAUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMcnFcnpHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZVqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXnag5a68RJ60FeUHQjyj08eA(fA(f6JgqES6LaYTifpekgKe3a2cnpHg7(y7HjREjGClsXdHIvqNK5sONRvONWBHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePi08j0F(i08l0QRqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9crkcnFc9Npcn29X2dtgvykbKIhcfRGojZLqpxRqpH3cnFcnFrdcFspJg2YxhNpU4fNjGXzJgqsCdyh)kAGl5bLKIg8l01lbRxtaBlxyPYqMufmc79oLBgKe3a2cnpHg7(y7HjJ7zTOTCHLkdzsvWiS37uUzfq7GfAEcn3ZAzB5clvgYKQGryV3PCJSYcyBpmfAEcTsbQqt4ntnMT81X5JtO5tO)8rO5xORxcwVMa2wUWsLHmPkye27Dk3mijUbSfAEc9j7Gq3k0bk08fni8j9mAyLfG4g06IxCMamoB0asIBa74xrdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHoaduO5j0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eA(fAUN1YOctjGWnunbS1ryZe65AfAvujjUbWihqNFDuN(JWnunblHMNqZVqZVqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmz1lbKBrkEiuSc6Kmxc9CTc9eEl08eAS7JThMmQWucifpekwbDsMlH(xHwfvsIBaSZVoQt)rByqbJSEHifHMpH(ZhHMFHwDf6JgqES6LaYTifpekgKe3a2cnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisrO5tO)8rOXUp2EyYOctjGu8qOyf0jzUe65Af6j8wO5tO5lAq4t6z0Ww(6qPRIIxCM5loB0asIBa74xrdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08eAS7JThMmQWucifpekwbDsMlHUvOduO5j08l08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnFrdcFspJg2YxhkDvu8IZOoXzJgqsCdyh)kAGl5bLKIg1lbRxtaBjvA8eToV6mijUbSfAEcTsbQqt4ntngOYX0j9mAq4t6z048hUb5w01aOonjJxCM5zC2ObKe3a2XVIg4sEqjPOr9sW61eWwsLgprRZRodsIBaBHMNqZVqRuGk0eEZuJbQCmDspf6pFeALcuHMWBMASZF4gKBrxdG60KuO5lAq4t6z0GkmLasXdHkEXzcsXzJgqsCdyh)kAGl5bLKIgNSdc9VcDagOqZtORxcwVMa2sQ04jADE1zqsCdyl08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWihqNFDuN(JWnunblHMNqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtOXUp2EyYOctjGu8qOyf0jzUe65Af6j8oAq4t6z0au5y6KEgV4mbW4SrdijUbSJFfni8j9mAaQCmDspJgY8GQEkhsAJgCpRLTKknEIwNxD26iSzTCpRLTKknEIwNxDwN(JwhHnlAiZdQ6PCizVdBjDq0qTObUKhuskACYoi0)k0byGcnpHUEjy9AcylPsJNO15vNbjXnGTqZtOXUp2EyYOctjGu8qOyf0jzUe6wHoqHMNqZVqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcTkQKe3ayKcQt)rByqbJSEHo)6cnpHM7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzcnFc9Npcn)cn29X2dt25pCdYTORbqDAsYkOtYCj0TcDGcnpHM7zTmQWuciCdvtaBDe2mHEUwHwfvsIBamYb05xh1P)iCdvtWsO5tO5tO5j0CpRLvVeqUfP4HqX2Eyk08fV4mZ74SrdijUbSJFfnWL8Gssrd(fAS7JThMmQWucifpekwbDsMlH(xHE(uhH(ZhHg7(y7HjJkmLasXdHIvqNK5sONRvOdqHMpHMNqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5xO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeAEcn)cn)c9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKvVeqUfP4HqXkOtYCj0Z1k0t4TqZtOXUp2EyYOctjGu8qOyf0jzUe6FfA1rO5tO)8rO5xOvxH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYOctjGu8qOyf0jzUe6FfA1rO5tO)8rOXUp2EyYOctjGu8qOyf0jzUe65Af6j8wO5tO5lAq4t6z0OlRYRfYTOZRoKx8IZOwGXzJgqsCdyh)kAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRGojZLqpNqd)b87a0j7GqZtO5xO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeAEcn)cn)c9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKvVeqUfP4HqXkOtYCj0Z1k0t4TqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(e6pFeA(fA1vOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHwfvsIBaSZVoQt)rByqbJSEHifHMpH(ZhHg7(y7HjJkmLasXdHIvqNK5sONRvONWBHMpHMVObHpPNrJI2skp0sHkZIxCg1uloB0asIBa74xrdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sONtOH)a(Da6KDqO5j08l08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnFrdcFspJgfTLuEOLcvMfV4mQfW4SrdijUbSJFfnWL8GssrdS7JThMmQWucifpekwbDsMlHUvOduO5j08l08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnFrdcFspJgBGUgoVsiEXzulaJZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeAEcn)cn)c9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKvVeqUfP4HqXkOtYCj0Z1k0t4TqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(e6pFeA(fA1vOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHwfvsIBaSZVoQt)rByqbJSEHifHMpH(ZhHg7(y7HjJkmLasXdHIvqNK5sONRvONWBHMVObHpPNrJZF4gKBrxdG60KmEXzuB(IZgnGK4gWo(v0axYdkjfn4xO5xOXUp2EyYo)HBqUfDnaQttswbDsMlH(xHwfvsIBamsb1P)OnmOGrwVqNFDHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXnag5a68RJ60FeUHQjyj08j08j08eAUN1YQxci3Iu8qOyBpmJge(KEgnOctjGu8qOIxCg1uN4SrdijUbSJFfnWL8GssrdUN1YQxci3Iu8qOyBpmfAEcn)cn)cn29X2dt25pCdYTORbqDAsYkOtYCj0)k0bmqHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXnag5a68RJ60FeUHQjyj08j08j08eA(fAS7JThMmQWucifpekwbDsMlH(xHwTak0F(i0BG7zTSZF4gKBrxdG60KK9ueA(Ige(KEgnQxci3Iu8qOIxCg1MNXzJgqsCdyh)kAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgnwns7jZjKIhcv8IZOwqkoB0asIBa74xrdCjpOKu0G7zTSnqxdNxjWEkcnpHEdCpRLD(d3GCl6AauNMKSNIqZtO3a3ZAzN)Wni3IUga1PjjRGojZLqpxRqZ9SwMsbliXaYTOUm3So9hTocBMqp)l0e(KEYOctjG4g06yWFa)oaDYoeni8j9mAOuWcsmGClQlZD8IZOwamoB0asIBa74xrdCjpOKu0G7zTSnqxdNxjWEkcnpHMFHMFH(ObKhRGLNuIbgKe3a2cnpHMWNufGGe6syj0Zj0ZNqZNq)5Jqt4tQcqqcDjSe65eA1rO5tO5j08l0QRqxVeSEnbmQWucioVZr1Ud5XGK4gWwO)8rOpQMGJ1a04Ayk4tO)vOdq1rO5lAq4t6z0GkmLaIBqRlEXzuBEhNnAq4t6z0y9uGkDvu0asIBa74xXlotadmoB0asIBa74xrdCjpOKu0G7zTmQWuciCdvtaBDe2mHUvOdmAq4t6z0GkmLaYlU4fNjGQfNnAajXnGD8RObUKhuskAWVqxGTGvdXnaH(ZhHwDf6tIntMtcnFcnpHM7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzrdcFspJgjCnqHoORaRlEXzcyaJZgnGK4gWo(v0axYdkjfn4EwldpaQW06K5eRacFcnpHUEjy9AcyuHPeqY0kt5fmdsIBaBHMNqF0aYJrDLH0kX0j9KbjXnGTqZtOj8jvbiiHUewc9CcDamAq4t6z0GkmLaQlxl5awXlotadW4SrdijUbSJFfnWL8GssrdUN1YWdGkmTozoXkGWNqZtO5xORxcwVMagvykbKmTYuEbZGK4gWwO)8rOpAa5XOUYqALy6KEYGK4gWwO5tO5j0e(KQaeKqxclHEoHwDIge(KEgnOctjG6Y1soGv8IZeW5loB0asIBa74xrdCjpOKu0G7zTmQWuciCdvtaBDe2mHEoHM7zTmQWuciCdvtaRt)rRJWMfni8j9mAqfMsab)vg(s6z8IZeq1joB0asIBa74xrdCjpOKu0G7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzcnpHwPavOj8MPgJkmLaIJQIMGObHpPNrdQWuci4VYWxspJxCMaopJZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBw0GWN0ZObvykbehvfnbXlotadsXzJgY8GQEkhsAJgDkjMc((TnaQordzEqvpLdj7DylPdIgQfni8j9mAaQCmDspJgqsCdyh)kEXlAu(rN0Z4SXzuloB0asIBa74xrdcFspJgGkhtN0ZOHmpOQNYHK2OrNsIPGVFBN3Qdp(v36LG1RjGTKknEIwNx9pF4EwlBjvA8eToV6S1ryZA5EwlBjvA8eToV6So9hTocBgFrdzEqvpLdj7DylPdIgQfnWL8GssrJoLetbFc9CTcTkQKe3ayGkhPGpHMNqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9CTcnHpPNmqLJPt6jd(d43bOt2bH(ZhHg7(y7HjJkmLasXdHIvqNK5sONRvOj8j9KbQCmDspzWFa)oaDYoi0F(i08l0hnG8y1lbKBrkEiumijUbSfAEcn29X2dtw9sa5wKIhcfRGojZLqpxRqt4t6jdu5y6KEYG)a(Da6KDqO5tO5tO5j0CpRLvVeqUfP4HqX2Eyk08eAUN1YOctjGu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJxCMagNnAajXnGD8RObUKhuskAuVeSEnbSLuPXt068QZGK4gWwO5j0y3hBpmzuHPeqkEiuSc6Kmxc9CTcnHpPNmqLJPt6jd(d43bOt2HObHpPNrdqLJPt6z8IZeGXzJgqsCdyh)kAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRaAhSqZtO5xO5EwlJkmLac3q1eWwhHntO)vOvrLK4ga78RJ60FeUHQjyj08eAS7JThMmQWucifpekwbDsMlHEUwHg(d43bOt2bHMVObHpPNrdQWucioQkAcIxCM5loB0asIBa74xrdCjpOKu0a7(y7Hj78hUb5w01aOonjzfq7GfAEcn)cn3ZAzuHPeq4gQMa26iSzc9VcTkQKe3ayNFDuN(JWnunblHMNqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmz1lbKBrkEiuSc6Kmxc9CTcn8hWVdqNSdcnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisrO5lAq4t6z0GkmLaIJQIMG4fNrDIZgnGK4gWo(v0axYdkjfnWUp2EyYo)HBqUfDnaQttswb0oyHMNqZVqZ9SwgvykbeUHQjGTocBMq)RqRIkjXna25xh1P)iCdvtWsO5j08l0QRqF0aYJvVeqUfP4HqXGK4gWwO)8rOXUp2EyYQxci3Iu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fQCfHMpHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePi08fni8j9mAqfMsaXrvrtq8IZmpJZgnGK4gWo(v0axYdkjfn2a3ZAzfTLuEOLcvMHu9gjueNCiVGzRJWMj0Tc9g4EwlROTKYdTuOYmKQ3iHI4Kd5fmRt)rRJWMj08eA(fAUN1YOctjGu8qOyBpmf6pFeAUN1YOctjGu8qOyf0jzUe65Af6j8wO5tO5j08l0CpRLvVeqUfP4HqX2Eyk0F(i0CpRLvVeqUfP4HqXkOtYCj0Z1k0t4TqZx0GWN0ZObvykbehvfnbXlotqkoB0asIBa74xrdCjpOKu0y7hROTKYdTuOYmwbDsMlH(xHoak0F(i08l0BG7zTSI2skp0sHkZqQEJekItoKxWS1ryZe6Ff6afAEc9g4EwlROTKYdTuOYmKQ3iHI4Kd5fmBDe2mHEoHEdCpRLv0ws5Hwkuzgs1BKqrCYH8cM1P)O1ryZeA(Ige(KEgnOctjG4g06IxCMayC2ObKe3a2XVIg4sEqjPOb3ZAzkfSGedi3I6YCZEkcnpHEdCpRLD(d3GCl6AauNMKSNIqZtO3a3ZAzN)Wni3IUga1PjjRGojZLqpxRqt4t6jJkmLaIBqRJb)b87a0j7q0GWN0ZObvykbe3Gwx8IZmVJZgnGK4gWo(v0a3qYmAOw0aOAemc3qYejTrdUN1YWdGkmTozoHWnuMWGT9WKh)CpRLrfMsaP4HqXEkF(WV6E0aYJ5QGsXdHc284N7zTS6LaYTifpek2t5ZhS7JThMmqLJPt6jRaAhmF8Xx0axYdkjfn2a3ZAzN)Wni3IUga1Pjj7Pi08e6JgqEmQWucia34mijUbSfAEcn)cn3ZAzBGUgoVsGT9WuO)8rOj8jvbiiHUewcDRqRMqZNqZtO5xO3a3ZAzN)Wni3IUga1PjjRGojZLq)Rqt4t6jJkmLaQlxl5awm4pGFhGozhe6pFeAS7JThMmLcwqIbKBrDzUzf0jzUe6Ff6af6pFeASRcskpMzbxskfA(eAEcn)cT6k008iuYdyuHPeqkVEhgYCIbjXnGTq)5JqZ9SwgEauHP1jZjeUHYegSThMcnFrdcFspJguHPeqD5AjhWkEXzulW4SrdijUbSJFfnWL8GssrdUN1YWdGkmTozoXkGWNqZtO5Ewld(Rq5g2if)G8K0G9uIge(KEgnOctjG6Y1soGv8IZOMAXzJgqsCdyh)kAq4t6z0GkmLaQlxl5awrdCdjZOHArdCjpOKu0G7zTm8aOctRtMtSci8j08eA(fAUN1YOctjGu8qOypfH(ZhHM7zTS6LaYTifpek2trO)8rO3a3ZAzN)Wni3IUga1PjjRGojZLq)Rqt4t6jJkmLaQlxl5awm4pGFhGozheA(IxCg1cyC2ObKe3a2XVIge(KEgnOctjG6Y1soGv0a3qYmAOw0axYdkjfn4EwldpaQW06K5eRacFcnpHM7zTm8aOctRtMtS1ryZe6wHM7zTm8aOctRtMtSo9hTocBw8IZOwagNnAajXnGD8RObHpPNrdQWucOUCTKdyfnWnKmJgQfnWL8GssrdUN1YWdGkmTozoXkGWNqZtO5EwldpaQW06K5eRGojZLqpxRqZVqZVqZ9SwgEauHP1jZj26iSzc98Vqt4t6jJkmLaQlxl5awm4pGFhGozheA(e6Fe6j8wO5lEXzuB(IZgnGK4gWo(v0axYdkjfn4xOlWwWQH4gGq)5JqRUc9jXMjZjHMpHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqZ9SwgvykbKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZOrcxduOd6kW6IxCg1uN4SrdijUbSJFfnWL8GssrdUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwrdcFspJguHPeqEXfV4mQnpJZgnGK4gWo(v0axYdkjfn6usmf8j0Z1k0ZB1rO5j0CpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgnwpfOsxffV4mQfKIZgnGK4gWo(v0axYdkjfn4EwlREda5w01uaSypfHMNqZ9SwgvykbeUHQjGTocBMq)RqhGrdcFspJguHPeqCdADXloJAbW4SrdijUbSJFfnWL8GssrJoLetbFc9CcTkQKe3ayCuv0eG6usif8j08eAS7JThMmqLJPt6jRGojZLq)RqhOqZtO5EwlJkmLasXdHIT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0WAbjgyQKlPNi3IuGYc4t6jRltVIge(KEgnOctjG4OQOjiEXzuBEhNnAajXnGD8RObUKhuskA0PKyk4tONRvOvrLK4gaJJQIMauNscPGpHMNqZ9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0y3hBpmzGkhtN0twbDsMlH(xHoWObHpPNrdQWucioQkAcIxCMagyC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dtHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqF0aYJrfMsa5fhdsIBaBHMNqJDFS9WKrfMsa5fhRGojZLqpxRqpH3cnpHUtjXuWNqpxRqpVduO5j0y3hBpmzGkhtN0twbDsMRObHpPNrdQWucioQkAcIxCMaQwC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSNIqZtO5EwlJkmLasXdHIvqNK5sONRvONWBHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqJDFS9WKbQCmDspzf0jzUIge(KEgnOctjG4OQOjiEXzcyaJZgnGK4gWo(v0axYdkjfn4EwlREjGClsXdHI9ueAEcn3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpekwbDsMlHEUwHEcVfAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeAEcn29X2dtgOYX0j9KvqNK5kAq4t6z0GkmLaIJQIMG4fNjGbyC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts2trO5j0BG7zTSZF4gKBrxdG60KKvqNK5sONRvONWBHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2SObHpPNrdQWucioQkAcIxCMaoFXzJgqsCdyh)kAGl5bLKIghvtWXAaACnmf8j0Zj0bO6i08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08e66LG1RjGrfMsaX5DoQ2DipgKe3a2cnpHMWNufGGe6syj0)k0Qj08eAUN1Y2aDnCELaB7Hz0GWN0ZObvykbehvfnbXlotavN4SrdijUbSJFfnWL8GssrJJQj4ynanUgMc(e65e6auDeAEcn3ZAzuHPeq4gQMa26iSzc9Ccn3ZAzuHPeq4gQMawN(JwhHntO5j01lbRxtaJkmLaIZ7CuT7qEmijUbSfAEcnHpPkabj0LWsO)vOvtO5j0CpRLTb6A48kb22dZObHpPNrdQWuci4VYWxspJxCMaopJZgni8j9mAqfMsaXnO1fnGK4gWo(v8IZeWGuC2ObKe3a2XVIg4sEqjPOb3ZAz1lbKBrkEiuSThMcnpHM7zTmQWucifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dZObHpPNrdqLJPt6z8IZeWayC2ObHpPNrdQWucioQkAcIgqsCdyh)kEXlAGDFS9WCfNnoJAXzJgqsCdyh)kAGl5bLKIg1lbRxtaBQKRrWijwIhadsIBaBHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0byGcnpHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZVqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j08l08l0hnG8y1lbKBrkEiumijUbSfAEcn29X2dtw9sa5wKIhcfRGojZLqpxRqpH3cnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisrO5tO)8rO5xOvxH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(e6pFeAS7JThMmQWucifpekwbDsMlHEUwHEcVfA(eA(Ige(KEgnSLVou6QO4fNjGXzJgqsCdyh)kAGl5bLKIg1lbRxtaBQKRrWijwIhadsIBaBHMNqJDFS9WKrfMsaP4HqXkOtYCj0TcDGcnpHMFHwDf6JgqEmihYPMdsyZGK4gWwO)8rO5xOpAa5XGCiNAoiHndsIBaBHMNq3PKyk4tO)TvOdsbk08j08j08eA(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvlqHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMq3k0bk08j08j08eAUN1YQxci3Iu8qOyBpmfAEcDNsIPGpH(3wHwfvsIBamsb1LPS)6OoLesbFrdcFspJg2YxhkDvu8IZeGXzJgqsCdyh)kAGl5bLKIg1lbRxtaBlxyPYqMufmc79oLBgKe3a2cnpHg7(y7HjJ7zTOTCHLkdzsvWiS37uUzfq7GfAEcn3ZAzB5clvgYKQGryV3PCJSLVo22dtHMNqZVqZ9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5tO5j0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eA(fAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpHMFHMFH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe65Af6j8wO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9crkcnFc9Npcn)cT6k0hnG8y1lbKBrkEiumijUbSfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKIqZNq)5JqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0t4TqZNqZx0GWN0ZOHT81X5JlEXzMV4SrdijUbSJFfnWL8GssrJ6LG1RjGTLlSuzitQcgH9ENYndsIBaBHMNqJDFS9WKX9Sw0wUWsLHmPkye27Dk3ScODWcnpHM7zTSTCHLkdzsvWiS37uUrwzbSThMcnpHwPavOj8MPgZw(648Xfni8j9mAyLfG4g06IxCg1joB0asIBa74xrdCjpOKu0a7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEhni8j9mA0Lv51c5w05vhYlEXzMNXzJgqsCdyh)kAGl5bLKIgy3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5xOvxH(ObKhdYHCQ5Ge2mijUbSf6pFeA(f6JgqEmihYPMdsyZGK4gWwO5j0DkjMc(e6FBf6GuGcnFcnFcnpHMFHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6FfAvujjUbWifuN(J2WGcgz9cD(1fAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeA(e6pFeA(fAS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzcDRqhOqZNqZNqZtO5EwlREjGClsXdHIT9WuO5j0DkjMc(e6FBfAvujjUbWifuxMY(RJ6usif8fni8j9mA0Lv51c5w05vhYlEXzcsXzJgqsCdyh)kAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpHg7(y7HjJkmLasXdHIvqNK5sONRvONW7ObHpPNrJnqxdNxjeV4mbW4SrdijUbSJFfnWL8GssrdS7JThMmQWucifpekwbDsMlHUvOduO5j08l0QRqF0aYJb5qo1CqcBgKe3a2c9Npcn)c9rdipgKd5uZbjSzqsCdyl08e6oLetbFc9VTcDqkqHMpHMpHMNqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcTAbk08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08j0F(i08l0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe6wHoqHMpHMpHMNqZ9Sww9sa5wKIhcfB7HPqZtO7usmf8j0)2k0QOssCdGrkOUmL9xh1PKqk4lAq4t6z0yd01W5vcXloZ8ooB0asIBa74xrdCjpOKu0a7(y7Hj78hUb5w01aOonjzf0jzUe6FfAvujjUbWQfQt)rByqbJSEHo)6cnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4gaRwOo9hTHbfmY6fIueAEcn)c9rdipw9sa5wKIhcfdsIBaBHMNqZVqJDFS9WKvVeqUfP4HqXkOtYCj0Zj0WFa)oaDYoi0F(i0y3hBpmz1lbKBrkEiuSc6Kmxc9VcTkQKe3ay1c1P)OnmOGrwVqLRi08j0F(i0QRqF0aYJvVeqUfP4HqXGK4gWwO5tO5j0CpRLrfMsaHBOAcyRJWMj0)k0buO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0CpRLvVeqUfP4HqX2Eyk08eAUN1YOctjGu8qOyBpmJge(KEgnkAlP8qlfQmlEXzulW4SrdijUbSJFfnWL8GssrdS7JThMSZF4gKBrxdG60KKvqNK5sONtOH)a(Da6KDqO5j0CpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGD(1rD6pc3q1eSeAEcn29X2dtgvykbKIhcfRGojZLqpNqZVqd)b87a0j7Gq)Jqt4t6j78hUb5w01aOonjzWFa)oaDYoi08fni8j9mAu0ws5Hwkuzw8IZOMAXzJgqsCdyh)kAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9Ccn8hWVdqNSdcnpHMFHMFHwDf6JgqEmihYPMdsyZGK4gWwO)8rO5xOpAa5XGCiNAoiHndsIBaBHMNq3PKyk4tO)TvOdsbk08j08j08eA(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaJuqD6pAddkyK1l05xxO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5tO)8rO5xOXUp2EyYo)HBqUfDnaQttswbDsMlHUvOduO5j0CpRLrfMsaHBOAcyRJWMj0TcDGcnFcnFcnpHM7zTS6LaYTifpek22dtHMNq3PKyk4tO)TvOvrLK4gaJuqDzk7VoQtjHuWNqZx0GWN0ZOrrBjLhAPqLzXloJAbmoB0asIBa74xrdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sONtOvNafAEcnSwqIbMk5s6jYTifOSa(KEY6Y0RObHpPNrJZF4gKBrxdG60KmEXzulaJZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntONRvOvrLK4ga78RJ60FeUHQjyj08eAS7JThMmQWucifpekwbDsMlHEUwHg(d43bOt2HObHpPNrJZF4gKBrxdG60KmEXzuB(IZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntONRvOvrLK4ga78RJ60FeUHQjyj08e6JgqES6LaYTifpekgKe3a2cnpHg7(y7HjREjGClsXdHIvqNK5sONRvOH)a(Da6KDqO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9crkrdcFspJgN)Wni3IUga1Pjz8IZOM6eNnAajXnGD8RObUKhuskAW9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j08l0QRqF0aYJvVeqUfP4HqXGK4gWwO)8rOXUp2EyYQxci3Iu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fQCfHMpHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePeni8j9mAC(d3GCl6AauNMKXloJAZZ4SrdijUbSJFfnWL8GssrdS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaJuqD6pAddkyK1l05xxO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0CpRLvVeqUfP4HqX2Eyk08e6oLetbFc9VTcTkQKe3ayKcQltz)1rDkjKc(Ige(KEgnOctjGu8qOIxCg1csXzJgqsCdyh)kAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaRCfuN(J2WGcgz9cD(1fAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeAEcn)cn29X2dtgvykbKIhcfRGojZLq)RqRwaf6pFe6nW9Sw25pCdYTORbqDAsYEkcnFrdcFspJg1lbKBrkEiuXloJAbW4SrdijUbSJFfnWL8GssrdUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMrdcFspJgRgP9K5esXdHkEXzuBEhNnAajXnGD8RObUKhuskAW9SwgvykbeUHQjGTocBMq3k0bk08eASRcskpMzbxskJge(KEgnukybjgqUf1L5oEXzcyGXzJgqsCdyh)kAGl5bLKIgBG7zTSZF4gKBrxdG60KK9ueAEc9g4Ewl78hUb5w01aOonjzf0jzUe65eAcFspzuHPeqD5AjhWIb)b87a0j7GqZtOvxHg7QGKYJzwWLKYObHpPNrdLcwqIbKBrDzUJx8IgDxf0H8IZgNrT4SrdijUbSJFfnWL8GssrJURc6qESTCDuIbH(3wHwTaJge(KEgn4gY0S4fNjGXzJge(KEgnukybjgqUf1L5oAajXnGD8R4fNjaJZgnGK4gWo(v0axYdkjfn6UkOd5X2Y1rjge65eA1cmAq4t6z0GkmLaQlxl5awXloZ8fNnAq4t6z0GkmLaYlUObKe3a2XVIxCg1joB0GWN0ZOHvwaIBqRlAajXnGD8R4fVOHsbyVZrxC24mQfNnAajXnGD8ROHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIgkfO8gdeOYJgBWsVXfncmEXzcyC2ObKe3a2XVIgUs0ybx0GWN0ZOHkQKe3aIgQOXdIgQfnWL8GssrdvujjUbWukq5ngiqLl0TcDGcnpHUEjy9AcylPsJNO15vNbjXnGTqZtOj8jvbiiHUewc9VcDaJgQOcLuhIgkfO8gdeOYJxCMamoB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brd1Ig4sEqjPOHkQKe3aykfO8gdeOYf6wHoqHMNqxVeSEnbSLuPXt068QZGK4gWwO5j0yxfKuESeWLp8Al08eAcFsvacsOlHLq)RqRw0qfvOK6q0qPaL3yGavE8IZmFXzJgqsCdyh)kA4krJfCrdcFspJgQOssCdiAOIgpiAey0axYdkjfnurLK4gatPaL3yGavUq3k0bgnurfkPoenukq5ngiqLhV4mQtC2ObKe3a2XVIgUs0ybx0GWN0ZOHkQKe3aIgQOXdIgbgnurfkPoenAivaYvGe2XloZ8moB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brd1Ig4sEqjPOHkQKe3aynKka5kqcBHUvOduO5j0e(KQaeKqxclH(xHoGrdvuHsQdrJgsfGCfiHD8IZeKIZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qTObUKhuskAOIkjXnawdPcqUcKWwOBf6afAEcTkQKe3aykfO8gdeOYf6wHwTOHkQqj1HOrdPcqUcKWoEXzcGXzJgqsCdyh)kA4krJfCrdcFspJgQOssCdiAOIgpiAey0qfvOK6q0WktAG4EvgV4mZ74SrdijUbSJFfnCLOrbl4Ige(KEgnurLK4gq0qfvOK6q0OwOo9hTHbfmY6f68Rhn2GLEJlAOoXloJAbgNnAajXnGD8ROHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIg1c1P)OnmOGrwVqLRen2GLEJlAOoXloJAQfNnAajXnGD8ROHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIg1c1P)OnmOGrwVqKs0ydw6nUOradmEXzulGXzJgqsCdyh)kA4krJcwWfni8j9mAOIkjXnGOHkQqj1HObPG60F0gguWiRxOZVE0ydw6nUOHAbgV4mQfGXzJgqsCdyh)kA4krJcwWfni8j9mAOIkjXnGOHkQqj1HOr5kOo9hTHbfmY6f68Rhn2GLEJlAeWaJxCg1MV4SrdijUbSJFfnCLOrbl4Ige(KEgnurLK4gq0qfvOK6q048RJ60F0gguWiRxisjASbl9gx0iW4fNrn1joB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brJamAGl5bLKIgQOssCdGD(1rD6pAddkyK1lePi0TcDGcnpHUEjy9AcyB5clvgYKQGryV3PCZGK4gWoAOIkusDiAC(1rD6pAddkyK1lePeV4mQnpJZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qn1jAGl5bLKIgQOssCdGD(1rD6pAddkyK1lePi0TcDGcnpHg7QGKYJLYPMdzjiAOIkusDiAC(1rD6pAddkyK1lePeV4mQfKIZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qn1jAGl5bLKIgQOssCdGD(1rD6pAddkyK1lePi0TcDGcnpHg75(jpgvykbKs5B5uWmijUbSfAEcnHpPkabj0LWsONtOdWOHkQqj1HOX5xh1P)OnmOGrwVqKs8IZOwamoB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brJamWObUKhuskAOIkjXna25xh1P)OnmOGrwVqKIq3k0bk08eAyTGedmvYL0tKBrkqzb8j9K1LPxrdvuHsQdrJZVoQt)rByqbJSEHiL4fNrT5DC2ObKe3a2XVIgUs0ybx0GWN0ZOHkQKe3aIgQOXdIgQt0axYdkjfnurLK4ga78RJ60F0gguWiRxisrOBf6aJgQOcLuhIgNFDuN(J2WGcgz9crkXlotadmoB0asIBa74xrdxjAuWcUObHpPNrdvujjUbenurfkPoeno)6Oo9hTHbfmY6fQCLOXgS0BCrJagy8IZeq1IZgnGK4gWo(v0WvIgfSGlAq4t6z0qfvsIBardvuHsQdrdoQkAcqDkjKc(IgBWsVXfncmEXzcyaJZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0GFHEEgOqp)sO5xO706GkyKkA8aHE(xOvlWafA(eA(Ig4sEqjPOHkQKe3ayCuv0eG6usif8j0TcDGcnpHg7QGKYJLYPMdzjiAOIkusDiAWrvrtaQtjHuWx8IZeWamoB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brd(f6ayGc98lHMFHUtRdQGrQOXde65FHwTaduO5tO5lAGl5bLKIgQOssCdGXrvrtaQtjHuWNq3k0bgnurfkPoen4OQOja1PKqk4lEXzc48fNnAajXnGD8ROHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIgKcQltz)1rDkjKc(IgBWsVXfncmEXzcO6eNnAajXnGD8ROHRenwWfni8j9mAOIkjXnGOHkA8GOH6ey0axYdkjfnurLK4gaJuqDzk7VoQtjHuWNq3k0bk08e66LG1RjGTLlSuzitQcgH9ENYndsIBa7OHkQqj1HObPG6Yu2FDuNscPGV4fNjGZZ4SrdijUbSJFfnCLOXcUObHpPNrdvujjUbenurJhenuNaJg4sEqjPOHkQKe3ayKcQltz)1rDkjKc(e6wHoqHMNqxVeSEnbSPsUgbJKyjEamijUbSJgQOcLuhIgKcQltz)1rDkjKc(IxCMagKIZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qn1jAGl5bLKIgQOssCdGrkOUmL9xh1PKqk4tOBf6aJgQOcLuhIgKcQltz)1rDkjKc(IxCMagaJZgnGK4gWo(v0WvIgfSGlAq4t6z0qfvsIBardvuHsQdrJZVoQt)r4gQMGv0ydw6nUOraJxCMaoVJZgnGK4gWo(v0WvIgfSGlAq4t6z0qfvsIBardvuHsQdrdzQcQd2ixbsOIgBWsVXfncmEXzcWaJZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qTObUKhuskAOIkjXnaMmvb1bBKRajucDRqhOqZtOpAa5XQxci3Iu8qOyqsCdyl08eA(f6JgqEmQWucia34mijUbSf6pFeA1vOXUkiP8yMfCjPuO5tO5j08l0QRqJDvqs5Xsax(WRTq)5Jqt4tQcqqcDjSe6wHwnH(ZhHUEjy9AcylPsJNO15vNbjXnGTqZx0qfvOK6q0qMQG6GnYvGeQ4fNjavloB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brJaJg4sEqjPOHkQKe3ayYufuhSrUcKqj0TcDGrdvuHsQdrdzQcQd2ixbsOIxCMamGXzJgqsCdyh)kA4krJfCrdcFspJgQOssCdiAOIgpiAaZRNurb2SoHjUcqRgaou)TKyH(ZhHgMxpPIcSztdAlPZRfIJ2tGq)5JqdZRNurb2SPbTL051c1Hnngspf6pFeAyE9KkkWMTPYSU7jAdyZqkVRGfgsmi0F(i0W86jvuGntMlC9oIBaO51JY71rBqLedc9NpcnmVEsffyZw(BmG7K5eQECbl0F(i0W86jvuGnB9sUH7Be1HRj41j0F(i0W86jvuGnlKmdsOwiB55wO)8rOH51tQOaBMDqDa5wehD3aIgQOcLuhIgKcYt0BbXlotagGXzJgqsCdyh)kA4krJcwWfni8j9mAOIkjXnGOHkQqj1HOb5a68RJ60FeUHQjyfn2GLEJlAeW4fNjaNV4SrdijUbSJFfnCLOXcUObHpPNrdvujjUbenurJhenulAGl5bLKIgQOssCdG1qQaKRajSf6wHoqHMNqVG7K50IrD0sH6cDRqRw0qfvOK6q0OHubixbsyhV4mbO6eNnAajXnGD8ROHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIgGkhPGVOXgS0BCrd1uN4fNjaNNXzJgqsCdyh)kEXzcWGuC2ObKe3a2XVIxCMamagNnAajXnGD8R4fNjaN3XzJge(KEgnwVE3tevykbKL6YHKQObKe3a2XVIxCM5lW4SrdcFspJguHPeqY8GXaWx0asIBa74xXloZ8PwC2ObHpPNrdSNZVFfG6usOjOhnGK4gWo(v8IZmFbmoB0asIBa74xXloZ8fGXzJge(KEgn6YQ8cj70eenGK4gWo(v8IZmFZxC2ObKe3a2XVIg4sEqjPOH6k0QOssCdGPuGYBmqGkxOBfA1eAEcD9sW61eW2YfwQmKjvbJWEVt5MbjXnGD0GWN0ZOHT81X5JlEXzMp1joB0asIBa74xrdCjpOKu0qDfAvujjUbWukq5ngiqLl0TcTAcnpHwDf66LG1RjGTLlSuzitQcgH9ENYndsIBa7ObHpPNrdQWuciUbTU4fNz(MNXzJgqsCdyh)kAGl5bLKIgQOssCdGPuGYBmqGkxOBfA1Ige(KEgnavoMoPNXlErdQJwkupoBCg1IZgnGK4gWo(v0axYdkjfn6usmf8j0Z1k0QOssCdGbQCKc(eAEcn)cn29X2dt25pCdYTORbqDAsYkOtYCj0Z1k0e(KEYavoMoPNm4pGFhGozhe6pFeAS7JThMmQWucifpekwbDsMlHEUwHMWN0tgOYX0j9Kb)b87a0j7Gq)5JqZVqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmz1lbKBrkEiuSc6Kmxc9CTcnHpPNmqLJPt6jd(d43bOt2bHMpHMpHMNqZ9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0au5y6KEgV4mbmoB0asIBa74xrdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sOBf6afAEcn)cn3ZAz1lbKBrkEiuSThMcnpHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6FfAvujjUbWifuN(J2WGcgz9cD(1f6pFeAS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afA(eA(Ige(KEgn2aDnCELq8IZeGXzJgqsCdyh)kAGl5bLKIgy3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5xO5EwlREjGClsXdHIT9WuO5j08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUq)5JqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZNqZx0GWN0ZOrxwLxlKBrNxDiV4fNz(IZgni8j9mAu0ws5Hwkuzw0asIBa74xXloJ6eNnAajXnGD8RObUKhuskAW9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0y1iTNmNqkEiuXloZ8moB0asIBa74xrdCjpOKu0G7zTS6LaYTifpek22dtHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0bgni8j9mAuVeqUfP4HqfV4mbP4SrdijUbSJFfnWL8Gssrd(fAS7JThMmQWucifpekwbDsMlHUvOduO5j0CpRLvVeqUfP4HqX2Eyk08j0F(i0kfOcnH3m1y1lbKBrkEiurdcFspJgN)Wni3IUga1Pjz8IZeaJZgnGK4gWo(v0axYdkjfnWUp2EyYOctjGu8qOyf0jzUe65eA1jqHMNqZ9Sww9sa5wKIhcfB7HPqZtOH1csmWujxsprUfPaLfWN0tgKe3a2rdcFspJgN)Wni3IUga1Pjz8IZmVJZgnGK4gWo(v0axYdkjfn4EwlREjGClsXdHIT9WuO5j0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVE0GWN0ZObvykbKIhcv8IZOwGXzJgqsCdyh)kAGl5bLKIgCpRLrfMsaP4HqXEkcnpHM7zTmQWucifpekwbDsMlHEUwHMWN0tgvykbuxUwYbSyWFa)oaDYoi08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMfni8j9mAqfMsaXrvrtq8IZOMAXzJgqsCdyh)kAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0Zj0CpRLrfMsaHBOAcyD6pADe2mHMNqZ9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0GkmLaYlU4fNrTagNnAajXnGD8RObUKhuskAW9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHnlAq4t6z0GkmLaIJQIMG4fNrTamoB0asIBa74xrdCdjZOHArdGQrWiCdjtK0gn4EwldpaQW06K5ec3qzcd22dtE8Z9SwgvykbKIhcf7P85d3ZAz1lbKBrkEiuSNYNpy3hBpmzGkhtN0twb0oy(Ig4sEqjPOb3ZAz4bqfMwNmNyfq4lAq4t6z0GkmLaQlxl5awXloJAZxC2ObKe3a2XVIg4gsMrd1IgavJGr4gsMiPnAW9SwgEauHP1jZjeUHYegSThM84N7zTmQWucifpek2t5ZhUN1YQxci3Iu8qOypLpFWUp2EyYavoMoPNScODW8fnWL8Gssrd1vOP5rOKhWOctjGuE9omK5edsIBaBH(ZhHM7zTm8aOctRtMtiCdLjmyBpmJge(KEgnOctjG6Y1soGv8IZOM6eNnAajXnGD8RObUKhuskAW9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0au5y6KEgV4mQnpJZgnGK4gWo(v0axYdkjfn4EwlJkmLac3q1eWwhHntONtO5EwlJkmLac3q1eW60F06iSzrdcFspJguHPeqEXfV4mQfKIZgni8j9mAqfMsaXrvrtq0asIBa74xXloJAbW4SrdcFspJguHPeqCdADrdijUbSJFfV4fnwnubBeEVIZgNrT4SrdijUbSJFfnWL8Gssrd(f6JgqEmihYPMdsyZGK4gWwO5j0DkjMc(e65Af6ayGcnpHUtjXuWNq)BRqppvhHMpH(ZhHMFHwDf6JgqEmihYPMdsyZGK4gWwO5j0DkjMc(e65Af6aO6i08fni8j9mA0PKqtqpEXzcyC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSNs0GWN0ZOHIFspJxCMamoB0asIBa74xrdCjpOKu0OEjy9Acyh0v8IgOqQuyqsCdyl08eAUN1YG)n0BDspzpfHMNqZVqJDFS9WKrfMsaP4HqXkG2bl0F(i0w5uZHkOtYCj0Z1k0ZxGcnFrdcFspJgNSdOqQuIxCM5loB0asIBa74xrdCjpOKu0G7zTmQWucifpek22dtHMNqZ9Sww9sa5wKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZOXqo1Cl0873EQd5fV4mQtC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dZObHpPNrdoAc5w0vsSzR4fNzEgNnAajXnGD8RObUKhuskAW9SwgvykbKIhcf7Peni8j9mAWb1ckZK5u8IZeKIZgnGK4gWo(v0axYdkjfn4EwlJkmLasXdHI9uIge(KEgn4gUVr2xfC8IZeaJZgnGK4gWo(v0axYdkjfn4EwlJkmLasXdHI9uIge(KEgnSYc4gUVJxCM5DC2ObKe3a2XVIg4sEqjPOb3ZAzuHPeqkEiuSNs0GWN0ZObLyyDfnqyAmIxCg1cmoB0asIBa74xrdCjpOKu0G7zTmQWucifpek2tjAq4t6z04TaK8G(kEXzutT4SrdijUbSJFfni8j9mAmnOTKoVwioApbrdCjpOKu0G7zTmQWucifpek2trO)8rOXUp2EyYOctjGu8qOyf0jzUe6FBfA1rDeAEc9g4Ewl78hUb5w01aOonjzpLObyTa(qj1HOX0G2s68AH4O9eeV4mQfW4SrdijUbSJFfni8j9mAaDLGlGgiV2jLyiAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9CTcDadmAKuhIgqxj4cObYRDsjgIxCg1cW4SrdijUbSJFfni8j9mASlG2wzbivWAbJObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0)2k0bmqH(ZhHwDfAvujjUbWifKNO3ce6wHwnH(ZhHMFH(KDqOBf6afAEcTkQKe3ayYufuhSrUcKqj0TcTAcnpHUEjy9AcylPsJNO15vNbjXnGTqZx0iPoen2fqBRSaKkyTGr8IZO28fNnAajXnGD8RObHpPNrJL)gi5ukpOIg4sEqjPOb29X2dtgvykbKIhcfRGojZLq)BRqhWaf6pFeA1vOvrLK4gaJuqEIElqOBfA1e6pFeA(f6t2bHUvOduO5j0QOssCdGjtvqDWg5kqcLq3k0Qj08e66LG1RjGTKknEIwNxDgKe3a2cnFrJK6q0y5VbsoLYdQ4fNrn1joB0asIBa74xrdcFspJgtJGvAqUfrRLSlh0j9mAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9VTcDaduO)8rOvxHwfvsIBamsb5j6TaHUvOvtO)8rO5xOpzhe6wHoqHMNqRIkjXnaMmvb1bBKRajucDRqRMqZtORxcwVMa2sQ04jADE1zqsCdyl08fnsQdrJPrWkni3IO1s2Ld6KEgV4mQnpJZgnGK4gWo(v0GWN0ZOrNWexbOvdahQ)wsC0axYdkjfnWUp2EyYOctjGu8qOyf0jzUe65AfA1rO5j08l0QRqRIkjXnaMmvb1bBKRajucDRqRMq)5JqFYoi0)k0byGcnFrJK6q0OtyIRa0QbGd1FljoEXzulifNnAajXnGD8RObHpPNrJoHjUcqRgaou)TK4ObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0Z1k0QJqZtOvrLK4gatMQG6GnYvGekHUvOvtO5j0CpRLvVeqUfP4HqXEkcnpHM7zTS6LaYTifpekwbDsMlHEUwHMFHwTaf65xcT6i0Z)cD9sW61eWwsLgprRZRodsIBaBHMpHMNqFYoi0Zj0byGrJK6q0OtyIRa0QbGd1FljoEXlASbl9gxC24mQfNnAajXnGD8RObUKhuskACunbhBdCpRLHP1jZjwbe(Ige(KEgnW(lpOwkWyeV4mbmoB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brd1Ig4sEqjPOHkQKe3aynKka5kqcBHEUwHoqHMNqRuGk0eEZuJbQCmDspfAEcT6k01lbRxtaBjvA8eToV6mijUbSJgQOcLuhIgnKka5kqc74fNjaJZgnGK4gWo(v0WvIgl4Ige(KEgnurLK4gq0qfnEq0qTObUKhuskAOIkjXnawdPcqUcKWwONRvOduO5j0CpRLrfMsaP4HqX2Eyk08eAS7JThMmQWucifpekwbDsMlH(xHoqHMNqxVeSEnbSLuPXt068QZGK4gWoAOIkusDiA0qQaKRajSJxCM5loB0asIBa74xrdxjASGlAq4t6z0qfvsIBardv04brd1Ig4sEqjPOb3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeAEcT6k0CpRLvVbGCl6AkawSNIqZtOTYPMdvqNK5sONRvO5xO5xO7usc93cnHpPNmQWuciUbTog2xNqZNqp)l0e(KEYOctjG4g06yWFa)oaDYoi08fnurfkPoenSYKgiUxLXloJ6eNnAajXnGD8RObHpPNrdmngicFsprd56Igd56qj1HOXQHkyJW7v8IZmpJZgnGK4gWo(v0GWN0ZObMgdeHpPNOHCDrJHCDOK6q0awliXWkEXzcsXzJgqsCdyh)kAGl5bLKIge(KQaeKqxclH(xHoGrdcFspJgyAmqe(KEIgY1fngY1HsQdrdYH4fNjagNnAajXnGD8RObUKhuskAOIkjXnawdPcqUcKWwONRvOdmAq4t6z0atJbIWN0t0qUUOXqUousDiA4kqcv8IZmVJZgnGK4gWo(v0axYdkjfnwWDYCAXOoAPqDHUvOvlAq4t6z0atJbIWN0t0qUUOXqUousDiAqD0sH6XloJAbgNnAajXnGD8RObHpPNrdmngicFsprd56Igd56qj1HOb29X2dZv8IZOMAXzJgqsCdyh)kAGl5bLKIgQOssCdGzLjnqCVkf6wHoWObHpPNrdmngicFsprd56Igd56qj1HOr5hDspJxCg1cyC2ObKe3a2XVIg4sEqjPOHkQKe3aywzsde3RsHUvOvlAq4t6z0atJbIWN0t0qUUOXqUousDiAyLjnqCVkJxCg1cW4SrdijUbSJFfni8j9mAGPXar4t6jAixx0yixhkPoen6UkOd5fV4fnSYKgiUxLXzJZOwC2ObKe3a2XVIge(KEgnOctjG6Y1soGv0a3qYmAOw0axYdkjfn4EwldpaQW06K5eRacFXlotaJZgni8j9mAqfMsaXnO1fnGK4gWo(v8IZeGXzJge(KEgnOctjG4OQOjiAajXnGD8R4fV4fnub1s6zCMagyadun1cyagncPkL50kAeKBEy(BM5NzcYOEcTqpBdi0YUIxNqB9sOn3vGekZf6cMxpzbBHE5DqOP35D6GTqJBOCcwmHjQVmbHwn1tOdcpvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZVA)5Jjmr9Lji0QPEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(d4F(yctuFzccDavpHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqhGQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1(ZhtyI6ltqONp1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqtNqhaoiR6l08R2F(yctuFzccTAbq1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZVA)5Jjmr9Lji0QfavpHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cnDcDa4GSQVqZVA)5Jjmr9Lji0bmq1tOdcpvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZVA)5JjmrysqU5H5VzMFMjiJ6j0c9SnGql7kEDcT1lH2CyTGedlZf6cMxpzbBHE5DqOP35D6GTqJBOCcwmHjQVmbHoGQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)a(NpMWe1xMGqhGQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1(ZhtyI6ltqOvh1tOdcpvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZFa)ZhtyI6ltqOdsQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)a(NpMWeHjb5MhM)Mz(zMGmQNql0Z2acTSR41j0wVeAZjhmxOlyE9KfSf6L3bHMEN3Pd2cnUHYjyXeMO(YeeA1upHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)b8pFmHjQVmbHwn1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZVA)5Jjmr9Lji0bu9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08hW)8XeMO(Yee6au9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hW)8XeMO(Yee6au9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R2F(yctuFzcc98PEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v7pFmHjQVmbHwDupHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqppvpHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqhKupHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqhavpHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqpVvpHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)b8pFmHjQVmbHwTavpHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)b8pFmHjQVmbHwTau9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hW)8XeMO(YeeA1cGQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1(ZhtyI6ltqOvlaQEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v7pFmHjQVmbHoGbu9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R2F(yctuFzccDadO6j0bHNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5xT)8XeMO(Yee6agGQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1(ZhtyI6ltqOdyaQEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v7pFmHjctcYnpm)nZ8ZmbzupHwONTbeAzxXRtOTEj0Mx(rN0tZf6cMxpzbBHE5DqOP35D6GTqJBOCcwmHjQVmbHwn1tOdcpvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZVA)5Jjmr9Lji0bu9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R2F(yctuFzcc98PEcDq4PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(v7pFmHjQVmbHwDupHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)Q9NpMWe1xMGqpVvpHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)Q9NpMWe1xMGqhWavpHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)Q9NpMWe1xMGqhW5t9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R2F(yctuFzccDavh1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZVA)5JjmrysqU5H5VzMFMjiJ6j0c9SnGql7kEDcT1lH28nyP34mxOlyE9KfSf6L3bHMEN3Pd2cnUHYjyXeMO(Yee6aQEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA6e6aWbzvFHMF1(ZhtyI6ltqOdq1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqtNqhaoiR6l08R2F(yctuFzcc98PEcDq4PkOoyl0gYEqi0RGZJ(l0b5tOpxOv)hj0BPk5s6Pq7kqrNxcn)FZNqZVA)5JjmrysqU5H5VzMFMjiJ6j0c9SnGql7kEDcT1lH2CLcWENJoZf6cMxpzbBHE5DqOP35D6GTqJBOCcwmHjQVmbHoGQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1(ZhtyI6ltqOdq1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZVA)5Jjmr9Lji0QPoQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMoHoaCqw1xO5xT)8XeMO(YeeA1csQNqheEQcQd2cT5yp3p5XcQ5c95cT5yp3p5XckdsIBaBZfA(v7pFmHjQVmbHoGQJ6j0bHNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxOPtOdahKv9fA(v7pFmHjQVmbHoGZt1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqtNqhaoiR6l08R2F(yctuFzccDagO6j0bHNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pG)5Jjmr9Lji0byGQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1(ZhtyI6ltqONV5t9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml00j0bGdYQ(cn)Q9NpMWe1xMGqpFQJ6j0bHNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxOPtOdahKv9fA(v7pFmHjctcYnpm)nZ8ZmbzupHwONTbeAzxXRtOTEj0MJDFS9WCzUqxW86jlyl0lVdcn9oVthSfACdLtWIjmr9Lji0QPEcDq4PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(d4F(yctuFzccTAQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1(ZhtyI6ltqOdO6j0bHNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pG)5Jjmr9Lji0bu9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R2F(yctuFzccDaQEcDq4PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(d4F(yctuFzccDaQEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v7pFmHjQVmbHE(upHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqppvpHoi8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)b8pFmHjQVmbHoaQEcDq4PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(d4F(yctuFzcc98w9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hW)8XeMO(YeeA1ut9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hW)8XeMO(YeeA1Mp1tOdcpvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZVA)5Jjmr9Lji0QPoQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1(ZhtyIWKGCZdZFZm)mtqg1tOf6zBaHw2v86eARxcT5RgQGncVxMl0fmVEYc2c9Y7GqtVZ70bBHg3q5eSyctuFzccTAQNqheEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)a(NpMWe1xMGqhGQNqheEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1(ZhtyI6ltqOvlavpHoi8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q9NpMWe1xMGqR28PEcDq4PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v7pFmHjQVmbHwn1r9e6GWtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R2F(yctuFzccTAbj1tOdcpvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZVA)5JjmrysqU5H5VzMFMjiJ6j0c9SnGql7kEDcT1lH2CQJwku3CHUG51twWwOxEheA6DENoyl04gkNGftyI6ltqOvt9e6GWtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R2F(ycteMm)0v86GTqRMAcnHpPNc9qUUftys0qPCRCarJaaHoip0ei0ZdfMsqysaGqpJRc6Cqj0bC(mvOdyGbmqHjctcae65pO7QaHwfvsIBamQJwkuxOLPqBjvEj0UvOxWDYCAXOoAPqDHMFCdGntOd2FLqVuaSq7kN0ZfFmHjbacDaiLnDWwOL5bvsdHUHY9qMtcTBfAvujjUbWAivaYvGe2c95cnhi0Qj0Hnqk0l4ozoTyuhTuOUq3k0QXeMeai0bGwGqFbRiX0qOnK9GqOBOCpK5Kq7wHg3qzcdHwMhu1t5KEk0YCDaTfA3k0MJPeddeHpPNMZeMimHWN0ZftPaS35ORvfvsIBaMMuhAvkq5ngiqLBQR0wWcot3GLEJRnqHje(KEUykfG9ohD)0(TkQKe3amnPo0QuGYBmqGk3uxPDbNPQOXdAvZuPTvfvsIBamLcuEJbcu5TbYREjy9AcylPsJNO15vNhHpPkabj0LW63akmHWN0ZftPaS35O7N2VvrLK4gGPj1HwLcuEJbcu5M6kTl4mvfnEqRAMkTTQOssCdGPuGYBmqGkVnqE1lbRxtaBjvA8eToV68WUkiP8yjGlF41MhHpPkabj0LW6x1eMq4t65IPua27C09t73QOssCdW0K6qRsbkVXabQCtDL2fCMQIgpOnqtL2wvujjUbWukq5ngiqL3gOWecFspxmLcWENJUFA)wfvsIBaMMuhABivaYvGe2M6kTl4mvfnEqBGcti8j9CXuka7Do6(P9BvujjUbyAsDOTHubixbsyBQR0UGZuv04bTQzQ02QIkjXnawdPcqUcKWUnqEe(KQaeKqxcRFdOWecFspxmLcWENJUFA)wfvsIBaMMuhABivaYvGe2M6kTl4mvfnEqRAMkTTQOssCdG1qQaKRajSBdKNkQKe3aykfO8gdeOYBvtycHpPNlMsbyVZr3pTFRIkjXnattQdTwzsde3RstDL2fCMQIgpOnqHje(KEUykfG9ohD)0(TkQKe3amnPo0wluN(J2WGcgz9cD(1n1vAlybNPBWsVX1Qocti8j9CXuka7Do6(P9BvujjUbyAsDOTwOo9hTHbfmY6fQCftDL2cwWz6gS0BCTQJWecFspxmLcWENJUFA)wfvsIBaMMuhARfQt)rByqbJSEHiftDL2cwWz6gS0BCTbmqHje(KEUykfG9ohD)0(TkQKe3amnPo0skOo9hTHbfmY6f68RBQR0wWcot3GLEJRvTafMq4t65IPua27C09t73QOssCdW0K6qB5kOo9hTHbfmY6f68RBQR0wWcot3GLEJRnGbkmHWN0ZftPaS35O7N2VvrLK4gGPj1H2ZVoQt)rByqbJSEHiftDL2cwWz6gS0BCTbkmHWN0ZftPaS35O7N2VvrLK4gGPj1H2ZVoQt)rByqbJSEHiftDL2fCMQIgpOnanvABvrLK4ga78RJ60F0gguWiRxisPnqE1lbRxtaBlxyPYqMufmc79oLBHje(KEUykfG9ohD)0(TkQKe3amnPo0E(1rD6pAddkyK1lePyQR0UGZuv04bTQPoMkTTQOssCdGD(1rD6pAddkyK1leP0gipSRcskpwkNAoKLaHje(KEUykfG9ohD)0(TkQKe3amnPo0E(1rD6pAddkyK1lePyQR0UGZuv04bTQPoMkTTQOssCdGD(1rD6pAddkyK1leP0gipSN7N8yuHPeqkLVLtbZJWNufGGe6synxakmHWN0ZftPaS35O7N2VvrLK4gGPj1H2ZVoQt)rByqbJSEHiftDL2fCMQIgpOnad0uPTvfvsIBaSZVoQt)rByqbJSEHiL2a5bRfKyGPsUKEIClsbklGpPNSUm9sycHpPNlMsbyVZr3pTFRIkjXnattQdTNFDuN(J2WGcgz9crkM6kTl4mvfnEqR6yQ02QIkjXna25xh1P)OnmOGrwVqKsBGcti8j9CXuka7Do6(P9BvujjUbyAsDO98RJ60F0gguWiRxOYvm1vAlybNPBWsVX1gWafMq4t65IPua27C09t73QOssCdW0K6qlhvfnbOoLesbFM6kTfSGZ0nyP34AduycHpPNlMsbyVZr3pTFRIkjXnattQdTCuv0eG6usif8zQR0UGZuv04bT8ppdC(f)DADqfmsfnEW8VAbgiF8zQ02QIkjXnaghvfnbOoLesbFTbYd7QGKYJLYPMdzjqycHpPNlMsbyVZr3pTFRIkjXnattQdTCuv0eG6usif8zQR0UGZuv04bT8hadC(f)DADqfmsfnEW8VAbgiF8zQ02QIkjXnaghvfnbOoLesbFTbkmHWN0ZftPaS35O7N2VvrLK4gGPj1Hwsb1LPS)6OoLesbFM6kTfSGZ0nyP34AduycHpPNlMsbyVZr3pTFRIkjXnattQdTKcQltz)1rDkjKc(m1vAxWzQkA8Gw1jqtL2wvujjUbWifuxMY(RJ6usif81giV6LG1RjGTLlSuzitQcgH9ENYTWecFspxmLcWENJUFA)wfvsIBaMMuhAjfuxMY(RJ6usif8zQR0UGZuv04bTQtGMkTTQOssCdGrkOUmL9xh1PKqk4RnqE1lbRxtaBQKRrWijwIhGWecFspxmLcWENJUFA)wfvsIBaMMuhAjfuxMY(RJ6usif8zQR0UGZuv04bTQPoMkTTQOssCdGrkOUmL9xh1PKqk4RnqHje(KEUykfG9ohD)0(TkQKe3amnPo0E(1rD6pc3q1eSm1vAlybNPBWsVX1gqHje(KEUykfG9ohD)0(TkQKe3amnPo0ktvqDWg5kqcLPUsBbl4mDdw6nU2afMq4t65IPua27C09t73QOssCdW0K6qRmvb1bBKRajuM6kTl4mvfnEqRAMkTTQOssCdGjtvqDWg5kqcvBG8oAa5XQxci3Iu8qO4X)rdipgvykbeGB8pFuxSRcskpMzbxsk5Jh)Ql2vbjLhlbC5dV2F(q4tQcqqcDjSAv7ZN6LG1RjGTKknEIwNxD(eMq4t65IPua27C09t73QOssCdW0K6qRmvb1bBKRajuM6kTl4mvfnEqBGMkTTQOssCdGjtvqDWg5kqcvBGcti8j9CXuka7Do6(P9BvujjUbyAsDOLuqEIElWuxPDbNPQOXdAH51tQOaBwNWexbOvdahQ)ws8NpW86jvuGnBAqBjDETqC0Ec(8bMxpPIcSztdAlPZRfQdBAmKE(5dmVEsffyZ2uzw39eTbSziL3vWcdjg(8bMxpPIcSzYCHR3rCdanVEuEVoAdQKy4ZhyE9KkkWMT83ya3jZju94c(ZhyE9KkkWMTEj3W9nI6W1e86(8bMxpPIcSzHKzqc1czlp3F(aZRNurb2m7G6aYTio6UbimHWN0ZftPaS35O7N2VvrLK4gGPj1HwYb05xh1P)iCdvtWYuxPTGfCMUbl9gxBafMq4t65IPua27C09t73QOssCdW0K6qBdPcqUcKW2uxPDbNPQOXdAvZuPTvfvsIBaSgsfGCfiHDBG8wWDYCAXOoAPq9w1eMq4t65IPua27C09t73QOssCdW0K6qlOYrk4ZuxPTGfCMUbl9gxRAQJWecFspxmLcWENJUFA)2oOLzcti8j9CXuka7Do6(P9BR7BHje(KEUykfG9ohD)0(n9M6qE0j9uycHpPNlMsbyVZr3pTFtfMsazPUCiPsycHpPNlMsbyVZr3pTFtfMsajZdgdaFcti8j9CXuka7Do6(P9BSNZVFfG6usOjOlmHWN0ZftPaS35O7N2VxjPSA8dTo6wcti8j9CXuka7Do6(P97USkVqYonbcti8j9CXuka7Do6(P9BB5RJZhNPsBR6QIkjXnaMsbkVXabQ8w14vVeSEnbSTCHLkdzsvWiS37uUfMq4t65IPua27C09t73uHPeqCdADMkTTQRkQKe3aykfO8gdeOYBvJN6wVeSEnbSTCHLkdzsvWiS37uUfMq4t65IPua27C09t73GkhtN0ttL2wvujjUbWukq5ngiqL3QMWeHje(KEU(P9BS)YdQLcmgMkTThvtWX2a3ZAzyADYCIvaHpHje(KEU(P9BvujjUbyAsDOTHubixbsyBQR0UGZuv04bTQzQ02QIkjXnawdPcqUcKWEU2a5PuGk0eEZuJbQCmDsp5PU1lbRxtaBjvA8eToV6cti8j9C9t73QOssCdW0K6qBdPcqUcKW2uxPDbNPQOXdAvZuPTvfvsIBaSgsfGCfiH9CTbYJ7zTmQWucifpek22dtEy3hBpmzuHPeqkEiuSc6Kmx)giV6LG1RjGTKknEIwNxDHje(KEU(P9BvujjUbyAsDO1ktAG4EvAQR0UGZuv04bTQzQ02Y9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJN6Y9Sww9gaYTORPayXEk8SYPMdvqNK5AUw(5VtjfKpcFspzuHPeqCdADmSVo(M)j8j9KrfMsaXnO1XG)a(Da6KDGpHje(KEU(P9BmngicFsprd56mnPo0UAOc2i8EjmHWN0Z1pTFJPXar4t6jAixNPj1HwyTGedlHje(KEU(P9BmngicFsprd56mnPo0soyQ02s4tQcqqcDjS(nGcti8j9C9t73yAmqe(KEIgY1zAsDO1vGektL2wvujjUbWAivaYvGe2Z1gOWecFspx)0(nMgdeHpPNOHCDMMuhAPoAPqDtL22fCNmNwmQJwkuVvnHje(KEU(P9BmngicFsprd56mnPo0IDFS9WCjmHWN0Z1pTFJPXar4t6jAixNPj1H2Yp6KEAQ02QIkjXnaMvM0aX9QSnqHje(KEU(P9BmngicFsprd56mnPo0ALjnqCVknvABvrLK4gaZktAG4Ev2QMWecFspx)0(nMgdeHpPNOHCDMMuhA7UkOd5jmrysaGqt4t65IrD0sH6TykXWar4t6PPsBlHpPNmqLJPt6jd3qzcdzoXRtjXuW3VTZB1rycHpPNlg1rlfQ)t73GkhtN0ttL22oLetbFZ1QIkjXnagOYrk4Jh)y3hBpmzN)Wni3IUga1PjjRGojZ1CTe(KEYavoMoPNm4pGFhGozh(8b7(y7HjJkmLasXdHIvqNK5AUwcFspzGkhtN0tg8hWVdqNSdF(W)rdipw9sa5wKIhcfpS7JThMS6LaYTifpekwbDsMR5Aj8j9KbQCmDspzWFa)oaDYoWhF84EwlREjGClsXdHIT9WKh3ZAzuHPeqkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxmQJwku)N2V3aDnCELGPsBl29X2dtgvykbKIhcfRGojZvBG84N7zTS6LaYTifpek22dtE8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZV(Npy3hBpmzN)Wni3IUga1PjjRGojZvBG8XNWecFspxmQJwku)N2V7YQ8AHCl68Qd5zQ02IDFS9WKrfMsaP4HqXkOtYC1gip(5EwlREjGClsXdHIT9WKh)y3hBpmzN)Wni3IUga1PjjRGojZ1VQOssCdGrkOo9hTHbfmY6f68R)5d29X2dt25pCdYTORbqDAsYkOtYC1giF8jmHWN0ZfJ6OLc1)P97I2skp0sHkZeMq4t65IrD0sH6)0(9QrApzoHu8qOmvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxmQJwku)N2VRxci3Iu8qOmvAB5EwlREjGClsXdHIT9WKh29X2dtgvykbKIhcfRGojZ1VbkmHWN0ZfJ6OLc1)P97ZF4gKBrxdG60K0uPTLFS7JThMmQWucifpekwbDsMR2a5X9Sww9sa5wKIhcfB7HjFF(OuGk0eEZuJvVeqUfP4HqjmHWN0ZfJ6OLc1)P97ZF4gKBrxdG60K0uPTf7(y7HjJkmLasXdHIvqNK5Ao1jqECpRLvVeqUfP4HqX2EyYdwliXatLCj9e5wKcuwaFspzqsCdylmHWN0ZfJ6OLc1)P9BQWucifpektL2wUN1YQxci3Iu8qOyBpm5HDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZVUWecFspxmQJwku)N2VPctjG4OQOjWuPTL7zTmQWucifpek2tHh3ZAzuHPeqkEiuSc6KmxZ1s4t6jJkmLaQlxl5awm4pGFhGozh4X9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHntycHpPNlg1rlfQ)t73uHPeqEXzQ02Y9SwgvykbeUHQjGTocB2CCpRLrfMsaHBOAcyD6pADe2mECpRLvVeqUfP4HqX2EyYJ7zTmQWucifpek22dtEBG7zTSZF4gKBrxdG60KKT9WuycHpPNlg1rlfQ)t73uHPeqCuv0eyQ02Y9Sww9sa5wKIhcfB7HjpUN1YOctjGu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZeMq4t65IrD0sH6)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacFMIBiz2QMPavJGr4gsMiPTL7zTm8aOctRtMtiCdLjmyBpm5Xp3ZAzuHPeqkEiuSNYNpCpRLvVeqUfP4HqXEkF(GDFS9WKbQCmDspzfq7G5tycHpPNlg1rlfQ)t73uHPeqD5AjhWYuPTvDP5rOKhWOctjGuE9omK5edsIBa7pF4EwldpaQW06K5ec3qzcd22dttXnKmBvZuGQrWiCdjtK02Y9SwgEauHP1jZjeUHYegSThM84N7zTmQWucifpek2t5ZhUN1YQxci3Iu8qOypLpFWUp2EyYavoMoPNScODW8jmHWN0ZfJ6OLc1)P9BqLJPt6PPsBl3ZAz1lbKBrkEiuSThM84EwlJkmLasXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMq4t65IrD0sH6)0(nvykbKxCMkTTCpRLrfMsaHBOAcyRJWMnh3ZAzuHPeq4gQMawN(JwhHntycHpPNlg1rlfQ)t73uHPeqCuv0eimHWN0ZfJ6OLc1)P9BQWuciUbToHjcti8j9CXihATLVooFCMkTT1lbRxtaBlxyPYqMufmc79oLBEy3hBpmzCpRfTLlSuzitQcgH9ENYnRaAhmpUN1Y2YfwQmKjvbJWEVt5gzlFDSThM84N7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThM8Xd7(y7Hj78hUb5w01aOonjzf0jzUAdKh)CpRLrfMsaHBOAcyRJWMnxRkQKe3ayKdOZVoQt)r4gQMGfp(5)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTt4npS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisHVpF4xDpAa5XQxci3Iu8qO4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crk895d29X2dtgvykbKIhcfRGojZ1CTt4nF8jmHWN0ZfJC4N2VTYcqCdADMkTT8xVeSEnbSTCHLkdzsvWiS37uU5HDFS9WKX9Sw0wUWsLHmPkye27Dk3ScODW84EwlBlxyPYqMufmc79oLBKvwaB7HjpLcuHMWBMAmB5RJZhhFF(WF9sW61eW2YfwQmKjvbJWEVt5M3j7qBG8jmHWN0ZfJC4N2VTLVou6QitL226LG1RjGnvY1iyKelXdGh29X2dtgvykbKIhcfRGojZ1VbyG8WUp2EyYo)HBqUfDnaQttswbDsMR2a5Xp3ZAzuHPeq4gQMa26iSzZ1QIkjXnag5a68RJ60FeUHQjyXJF(pAa5XQxci3Iu8qO4HDFS9WKvVeqUfP4HqXkOtYCnx7eEZd7(y7HjJkmLasXdHIvqNK56xvujjUbWo)6Oo9hTHbfmY6fIu47Zh(v3JgqES6LaYTifpekEy3hBpmzuHPeqkEiuSc6Kmx)QIkjXna25xh1P)OnmOGrwVqKcFF(GDFS9WKrfMsaP4HqXkOtYCnx7eEZhFcti8j9CXih(P9BB5RdLUkYuPTTEjy9AcytLCncgjXs8a4HDFS9WKrfMsaP4HqXkOtYC1gip(5NFS7JThMSZF4gKBrxdG60KKvqNK56xvujjUbWifuN(J2WGcgz9cD(15X9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJVpF4h7(y7Hj78hUb5w01aOonjzf0jzUAdKh3ZAzuHPeq4gQMa26iSzZ1QIkjXnag5a68RJ60FeUHQjyXhF84EwlREjGClsXdHIT9WKpHje(KEUyKd)0(95pCdYTORbqDAsAQ02wVeSEnbSLuPXt068QZtPavOj8MPgdu5y6KEkmHWN0ZfJC4N2VPctjGu8qOmvABRxcwVMa2sQ04jADE15XVsbQqt4ntngOYX0j98ZhLcuHMWBMASZF4gKBrxdG60KKpHje(KEUyKd)0(nOYX0j90uPT9KD43amqE1lbRxtaBjvA8eToV684EwlJkmLac3q1eWwhHnBUwvujjUbWihqNFDuN(JWnunblEy3hBpmzN)Wni3IUga1PjjRGojZvBG8WUp2EyYOctjGu8qOyf0jzUMRDcVfMq4t65Iro8t73GkhtN0ttL22t2HFdWa5vVeSEnbSLuPXt068QZd7(y7HjJkmLasXdHIvqNK5QnqE8Zp)y3hBpmzN)Wni3IUga1PjjRGojZ1VQOssCdGrkOo9hTHbfmY6f68RZJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgFF(Wp29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZMRvfvsIBamYb05xh1P)iCdvtWIp(4X9Sww9sa5wKIhcfB7HjFMkZdQ6PCiPTL7zTSLuPXt068QZwhHnRL7zTSLuPXt068QZ60F06iSzMkZdQ6PCizVdBjDqRActi8j9CXih(P97USkVwi3IoV6qEMkTT8JDFS9WKrfMsaP4HqXkOtYC978PoF(GDFS9WKrfMsaP4HqXkOtYCnxBaYhpS7JThMSZF4gKBrxdG60KKvqNK5QnqE8Z9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw84N)JgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vD47Zh(v3JgqES6LaYTifpekEy3hBpmzuHPeqkEiuSc6Kmx)Qo895d29X2dtgvykbKIhcfRGojZ1CTt4nF8jmHWN0ZfJC4N2VlAlP8qlfQmZuPTf7(y7Hj78hUb5w01aOonjzf0jzUMd(d43bOt2bE8Z9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw84N)JgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif((8HF19ObKhREjGClsXdHIh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePW3Npy3hBpmzuHPeqkEiuSc6KmxZ1oH38XNWecFspxmYHFA)UOTKYdTuOYmtL2wS7JThMmQWucifpekwbDsMR5G)a(Da6KDGh)8Zp29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayKcQt)rByqbJSEHo)684EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S5AvrLK4gaJCaD(1rD6pc3q1eS4JpECpRLvVeqUfP4HqX2EyYNWecFspxmYHFA)Ed01W5vcMkTTy3hBpmzuHPeqkEiuSc6KmxTbYJF(5h7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw8XhpUN1YQxci3Iu8qOyBpm5tycHpPNlg5WpTFF(d3GCl6AauNMKMkTTCpRLrfMsaHBOAcyRJWMnxRkQKe3ayKdOZVoQt)r4gQMGfp(5)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTt4npS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisHVpF4xDpAa5XQxci3Iu8qO4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crk895d29X2dtgvykbKIhcfRGojZ1CTt4nFcti8j9CXih(P9BQWucifpektL2w(5h7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw8XhpUN1YQxci3Iu8qOyBpmfMq4t65Iro8t731lbKBrkEiuMkTTCpRLvVeqUfP4HqX2EyYJF(XUp2EyYo)HBqUfDnaQttswbDsMRFdyG84EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S5AvrLK4gaJCaD(1rD6pc3q1eS4JpE8JDFS9WKrfMsaP4HqXkOtYC9RAb8ZNnW9Sw25pCdYTORbqDAsYEk8jmHWN0ZfJC4N2Vxns7jZjKIhcLPsBl3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMq4t65Iro8t73kfSGedi3I6YCBQ02Y9Sw2gORHZReypfEBG7zTSZF4gKBrxdG60KK9u4TbUN1Yo)HBqUfDnaQttswbDsMR5A5EwltPGfKya5wuxMBwN(JwhHnB(NWN0tgvykbe3Gwhd(d43bOt2bHje(KEUyKd)0(nvykbe3GwNPsBl3ZAzBGUgoVsG9u4Xp)hnG8yfS8KsmWJWNufGGe6syn38X3Npe(KQaeKqxcR5uh(4XV6wVeSEnbmQWucioVZr1Ud595Zr1eCSgGgxdtbF)gGQdFcti8j9CXih(P971tbQ0vrcti8j9CXih(P9BQWuciV4mvAB5EwlJkmLac3q1eWwhHnRnqHje(KEUyKd)0(DcxduOd6kW6mvAB5VaBbRgIBaF(OUNeBMmN4Jh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mHje(KEUyKd)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacF8QxcwVMagvykbKmTYuEbZ7ObKhJ6kdPvIPt6jpcFsvacsOlH1CbqHje(KEUyKd)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacF84VEjy9AcyuHPeqY0kt5f8NphnG8yuxziTsmDsp5JhHpPkabj0LWAo1rycHpPNlg5WpTFtfMsab)vg(s6PPsBl3ZAzuHPeq4gQMa26iSzZX9SwgvykbeUHQjG1P)O1ryZeMq4t65Iro8t73uHPeqWFLHVKEAQ02Y9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJNsbQqt4ntngvykbehvfnbcti8j9CXih(P9BQWucioQkAcmvAB5EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMjmHWN0ZfJC4N2VbvoMoPNMkZdQ6PCiPTTtjXuW3VTbq1XuzEqvpLdj7DylPdAvtyIWKaaHoi)L0l5jNhbH(TK5KqpvY1iyHwIL4bi0HYRrOjfMqhaAbcT8e6q51i0NFDH2VgOcLlGjmHWN0Zfd7(y7H5Q1w(6qPRImvABRxcwVMa2ujxJGrsSepaEy3hBpmzuHPeqkEiuSc6Kmx)gGbYd7(y7Hj78hUb5w01aOonjzf0jzUAdKh)CpRLrfMsaHBOAcyRJWMnxRkQKe3ayNFDuN(JWnunblE8Z)rdipw9sa5wKIhcfpS7JThMS6LaYTifpekwbDsMR5ANWBEy3hBpmzuHPeqkEiuSc6Kmx)QIkjXna25xh1P)OnmOGrwVqKcFF(WV6E0aYJvVeqUfP4HqXd7(y7HjJkmLasXdHIvqNK56xvujjUbWo)6Oo9hTHbfmY6fIu47ZhS7JThMmQWucifpekwbDsMR5ANWB(4tycHpPNlg29X2dZ1pTFBlFDO0vrMkTT1lbRxtaBQKRrWijwIhapS7JThMmQWucifpekwbDsMR2a5XV6E0aYJb5qo1Cqc7pF4)ObKhdYHCQ5Ge286usmf89BBqkq(4Jh)8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QwG84EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S2a5JpECpRLvVeqUfP4HqX2EyYRtjXuW3VTQOssCdGrkOUmL9xh1PKqk4tycHpPNlg29X2dZ1pTFBlFDC(4mvABRxcwVMa2wUWsLHmPkye27Dk38WUp2EyY4EwlAlxyPYqMufmc79oLBwb0oyECpRLTLlSuzitQcgH9ENYnYw(6yBpm5Xp3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpm5Jh29X2dt25pCdYTORbqDAsYkOtYC1gip(5EwlJkmLac3q1eWwhHnBUwvujjUbWo)6Oo9hHBOAcw84N)JgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif((8HF19ObKhREjGClsXdHIh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePW3Npy3hBpmzuHPeqkEiuSc6KmxZ1oH38XNWecFspxmS7JThMRFA)2klaXnO1zQ02wVeSEnbSTCHLkdzsvWiS37uU5HDFS9WKX9Sw0wUWsLHmPkye27Dk3ScODW84EwlBlxyPYqMufmc79oLBKvwaB7HjpLcuHMWBMAmB5RJZhNWKaaHEEyesbVe63ce6USkVwcDO8AeAsHj0ZpwH(8Rl0YLqxaTdwOPLqhcJHPcDNmde61RaH(CHgtRtOLNqZbwVaH(8RZeMq4t65IHDFS9WC9t73DzvETqUfDE1H8mvABXUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnx7eElmHWN0Zfd7(y7H56N2V7YQ8AHCl68Qd5zQ02IDFS9WKrfMsaP4HqXkOtYC1gip(v3JgqEmihYPMdsy)5d)hnG8yqoKtnhKWMxNsIPGVFBdsbYhF84NFS7JThMSZF4gKBrxdG60KKvqNK56xvujjUbWifuN(J2WGcgz9cD(15X9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJVpF4h7(y7Hj78hUb5w01aOonjzf0jzUAdKh3ZAzuHPeq4gQMa26iSzTbYhF84EwlREjGClsXdHIT9WKxNsIPGVFBvrLK4gaJuqDzk7VoQtjHuWNWKaaHEEyesbVe63ce6nqxdNxji0HYRrOjfMqp)yf6ZVUqlxcDb0oyHMwcDimgMk0DYmqOxVce6ZfAmToHwEcnhy9ce6ZVotycHpPNlg29X2dZ1pTFVb6A48kbtL2wS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWMnxRkQKe3ayNFDuN(JWnunblEy3hBpmzuHPeqkEiuSc6KmxZ1oH3cti8j9CXWUp2EyU(P97nqxdNxjyQ02IDFS9WKrfMsaP4HqXkOtYC1gip(v3JgqEmihYPMdsy)5d)hnG8yqoKtnhKWMxNsIPGVFBdsbYhF84NFS7JThMSZF4gKBrxdG60KKvqNK56x1cKh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2m((8HFS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWM1giF8XJ7zTS6LaYTifpek22dtEDkjMc((TvfvsIBamsb1LPS)6OoLesbFctcae6aqlqOxkuzMqlTc95xxOPCl0KIqtfi0Ek04Tqt5wOd908tO5aH(Pi0wVe6HNtqj0xdLc91acDN(l0ByqbBQq3jZK5KqVEfi0HGq3qQaHMoHEa06e6l0fAQWuccnUHQjyj0uUf6RHoH(8Rl0H0kn)e653V1j0VfSzcti8j9CXWUp2EyU(P97I2skp0sHkZmvABXUp2EyYo)HBqUfDnaQttswbDsMRFvrLK4gaRwOo9hTHbfmY6f68RZd7(y7HjJkmLasXdHIvqNK56xvujjUbWQfQt)rByqbJSEHifE8F0aYJvVeqUfP4HqXJFS7JThMS6LaYTifpekwbDsMR5G)a(Da6KD4ZhS7JThMS6LaYTifpekwbDsMRFvrLK4gaRwOo9hTHbfmY6fQCf((8rDpAa5XQxci3Iu8qO4Jh3ZAzuHPeq4gQMa26iSz)gqEBG7zTSZF4gKBrxdG60KKT9WKh3ZAz1lbKBrkEiuSThM84EwlJkmLasXdHIT9WuysaGqhaAbc9sHkZe6q51i0KIqh2aPqR4RLKBamHE(Xk0NFDHwUe6cODWcnTe6qymmvO7KzGqVEfi0Nl0yADcT8eAoW6fi0NFDMWecFspxmS7JThMRFA)UOTKYdTuOYmtL2wS7JThMSZF4gKBrxdG60KKvqNK5Ao4pGFhGozh4X9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnh)WFa)oaDYo8dHpPNSZF4gKBrxdG60KKb)b87a0j7aFcti8j9CXWUp2EyU(P97I2skp0sHkZmvABXUp2EyYOctjGu8qOyf0jzUMd(d43bOt2bE8ZV6E0aYJb5qo1Cqc7pF4)ObKhdYHCQ5Ge286usmf89BBqkq(4Jh)8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZVopUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz895d)y3hBpmzN)Wni3IUga1PjjRGojZvBG84EwlJkmLac3q1eWwhHnRnq(4Jh3ZAz1lbKBrkEiuSThM86usmf89BRkQKe3ayKcQltz)1rDkjKc(4tycHpPNlg29X2dZ1pTFF(d3GCl6AauNMKMkTTy3hBpmzuHPeqkEiuSc6KmxZPobYdwliXatLCj9e5wKcuwaFspzDz6LWKaaHoa0ce6ZVUqhkVgHMueAPvOLN5lHouEnYuOVgqO70FHEddkyMqp)yf60ptf63ce6q51i0LRi0sRqFnGqF0aYtOLlH(iZG0uHMYTqlpZxcDO8AKPqFnGq3P)c9gguWmHje(KEUyy3hBpmx)0(95pCdYTORbqDAsAQ02Y9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnxl8hWVdqNSdcti8j9CXWUp2EyU(P97ZF4gKBrxdG60K0uPTL7zTmQWuciCdvtaBDe2S5AvrLK4ga78RJ60FeUHQjyX7ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTWFa)oaDYoWd7(y7HjJkmLasXdHIvqNK56xvujjUbWo)6Oo9hTHbfmY6fIueMq4t65IHDFS9WC9t73N)Wni3IUga1PjPPsBl3ZAzuHPeq4gQMa26iSzZ1QIkjXna25xh1P)iCdvtWIh)Q7rdipw9sa5wKIhc1Npy3hBpmz1lbKBrkEiuSc6Kmx)QIkjXna25xh1P)OnmOGrwVqLRWhpS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisrysaGqhaAbcnPi0sRqF(1fA5sO9uOXBHMYTqh6P5NqZbc9trOTEj0dpNGsOVgkf6Rbe6o9xO3WGc2uHUtMjZjHE9kqOVg6e6qqOBivGqdP)MAe6oLKqt5wOVg6e6RbkqOLlHo9tOPrb0oyHMe66LGq7wHwXdHsO3EyYeMq4t65IHDFS9WC9t73uHPeqkEiuMkTTy3hBpmzN)Wni3IUga1PjjRGojZ1VQOssCdGrkOo9hTHbfmY6f68RZJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgpUN1YQxci3Iu8qOyBpm51PKyk473wvujjUbWifuxMY(RJ6usif8jmjaqOdaTaHUCfHwAf6ZVUqlxcTNcnEl0uUf6qpn)eAoqOFkcT1lHE45euc91qPqFnGq3P)c9gguWMk0DYmzoj0Rxbc91afi0YvA(j00OaAhSqtcD9sqO3Eyk0uUf6RHoHMue6qpn)eAoa7DqOjvKCqCdqO3VsMtcD9sGjmHWN0Zfd7(y7H56N2VRxci3Iu8qOmvAB5EwlJkmLasXdHIT9WKh29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayLRG60F0gguWiRxOZVopUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz84h7(y7HjJkmLasXdHIvqNK56x1c4NpBG7zTSZF4gKBrxdG60KK9u4tycHpPNlg29X2dZ1pTFVAK2tMtifpektL2wUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EykmjaqOdYBWLKs1tON)meA5sO7uscDZlNQGfAk3c98WxZ3sOPce6ZDHg(Ra5sQce6Zf63ceAfVl0Nl0R51dG5rqOPuOH)xrcnXj0YuOVgqOp)6cDOm3EitOvF4mFj0Vfi0YtOpxO7KzGqp8qHg3q1ei0ZdFTeAzUokpMWecFspxmS7JThMRFA)wPGfKya5wuxMBtL2wUN1YOctjGWnunbS1ryZAdKh2vbjLhZSGljLctcae6z8C(vqEdUKuQEcDaOfi0kExOpxOxZRhaZJGqtPqd)VIeAItOLPqFnGqF(1f6qzU9qMWecFspxmS7JThMRFA)wPGfKya5wuxMBtL22nW9Sw25pCdYTORbqDAsYEk82a3ZAzN)Wni3IUga1PjjRGojZ1Ce(KEYOctjG6Y1soGfd(d43bOt2bEQl2vbjLhZSGljLcteMq4t65IbRfKyy1YnCFJCl6AaeKqpytL2wS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWMnxRkQKe3ayNFDuN(JWnunblEy3hBpmzuHPeqkEiuSc6KmxZ1oH3F(yLtnhQGojZ1Cy3hBpmzuHPeqkEiuSc6Kmxcti8j9CXG1csmS(P9BUH7BKBrxdGGe6bBQ02IDFS9WKrfMsaP4HqXkOtYC1gip(v3JgqEmihYPMdsy)5d)hnG8yqoKtnhKWMxNsIPGVFBdsb(5JkQKe3ayuhTuOERA8Xhp(5h7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDE8Z9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHn7ZhvujjUbWOoAPq9w14JVpF4h7(y7Hj78hUb5w01aOonjzf0jzUAdKh3ZAzuHPeq4gQMa26iSzTbYhF84EwlREjGClsXdHIT9WKxNsIPGVFBvrLK4gaJuqDzk7VoQtjHuWNWecFspxmyTGedRFA)o0RXwfitublpPedMkTTy3hBpmzuHPeqkEiuSc6Kmx)2QobYd7(y7Hj78hUb5w01aOonjzf0jzUMRDcV5X9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4D0aYJvVeqUfP4HqXd7(y7HjREjGClsXdHIvqNK5AU2j8Mh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePimHWN0ZfdwliXW6N2Vd9ASvbYevWYtkXGPsBl29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGfpS7JThMmQWucifpekwbDsMR5ANW7pFSYPMdvqNK5AoS7JThMmQWucifpekwbDsMlHje(KEUyWAbjgw)0(DOxJTkqMOcwEsjgmvABXUp2EyYOctjGu8qOyf0jzUAdKh)Q7rdipgKd5uZbjS)8H)JgqEmihYPMdsyZRtjXuW3VTbPa)8rfvsIBamQJwkuVvn(4Jh)8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZVop(5EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWM95JkQKe3ayuhTuOERA8X3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S2a5JpECpRLvVeqUfP4HqX2EyYRtjXuW3VTQOssCdGrkOUmL9xh1PKqk4tycHpPNlgSwqIH1pTFp9OAlPe5wenpcLFnMkTTy3hBpmzN)Wni3IUga1PjjRGojZvBG84EwlJkmLac3q1eWwhHnBUwvujjUbWo)6Oo9hHBOAcw8WUp2EyYOctjGu8qOyf0jzUMRDcV)8XkNAoubDsMR5WUp2EyYOctjGu8qOyf0jzUeMq4t65IbRfKyy9t73tpQ2skrUfrZJq5xJPsBl29X2dtgvykbKIhcfRGojZvBG84xDpAa5XGCiNAoiH9Np8F0aYJb5qo1CqcBEDkjMc((Tnif4NpQOssCdGrD0sH6TQXhF84NFS7JThMSZF4gKBrxdG60KKvqNK56xvujjUbWifuN(J2WGcgz9cD(15Xp3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2SpFurLK4gaJ6OLc1BvJp((8HFS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWM1giF8XJ7zTS6LaYTifpek22dtEDkjMc((TvfvsIBamsb1LPS)6OoLesbFcti8j9CXG1csmS(P9BSNyiVIoyJSdQdMoKjGW725PPsBl3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpm51PKyNSdOZrD6)VTWFa)oaDYoimHWN0ZfdwliXW6N2VlGuK5eYoOoSmvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HjVoLe7KDaDoQt))Tf(d43bOt2bHje(KEUyWAbjgw)0(T1XVfSr08iuYdqCa1nvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxmyTGedRFA)w5vsBWYCcXnO1zQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHje(KEUyWAbjgw)0(DjvugasMOLcHbtL2wUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EykmHWN0ZfdwliXW6N2VVga9so)LBK1lmyQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHje(KEUyWAbjgw)0(Dh6EfmYTOXdl3ODbuFzQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHjcti8j9CXSYKgiUxL)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacFMIBiz2QMWecFspxmRmPbI7v5pTFtfMsaXnO1jmHWN0ZfZktAG4Ev(t73uHPeqCuv0eimrycHpPNlw3vbDiVFA)MBitZqugSPsBB3vbDip2wUokXWVTQfOWecFspxSURc6qE)0(TsbliXaYTOUm3cti8j9CX6UkOd59t73uHPeqD5AjhWYuPTT7QGoKhBlxhLyyo1cuycHpPNlw3vbDiVFA)MkmLaYloHje(KEUyDxf0H8(P9BRSae3GwNWeHje(KEUyUcKq1cQCmDspnvAB5VEjy9AcylPsJNO15v)ZN6LG1RjGDqxXlAGcPsHpEhnG8y1lbKBrkEiu8WUp2EyYQxci3Iu8qOyf0jzU(nqE8Z9Sww9sa5wKIhcfB7H5NpkfOcnH3m1yuHPeqCuv0eWNWecFspxmxbsO(P9BRSae3GwNPsBB9sW61eW2YfwQmKjvbJWEVt5Mh3ZAzB5clvgYKQGryV3PCJSLVo2trycHpPNlMRaju)0(TT81HsxfzQ02wVeSEnbSPsUgbJKyjEa86usmf8978wDeMq4t65I5kqc1pTFVb6A48kbtL2w1TEjy9AcylPsJNO15vxycHpPNlMRaju)0(DrBjLhAPqLzMkTTDkjMc((D(cuycHpPNlMRaju)0(9QrApzoHu8qOmvABx(BWjZnZkHXg5we3WxlVVyqsCdylmHWN0ZfZvGeQFA)MkmLaYlotL2wvujjUbWKPkOoyJCfiHQvnEy3hBpmz1lbKBrkEiuSc6KmxTbkmHWN0ZfZvGeQFA)MkmLaIBqRZuPTvfvsIBamzQcQd2ixbsOAvJh29X2dtw9sa5wKIhcfRGojZvBG84EwlJkmLac3q1eWwhHnBoUN1YOctjGWnunbSo9hTocBMWecFspxmxbsO(P976LaYTifpektL2wvujjUbWKPkOoyJCfiHQvnECpRLvVeqUfP4HqX2EykmHWN0ZfZvGeQFA)Ed01W5vcMkTTCpRLvVeqUfP4HqX2EykmHWN0ZfZvGeQFA)UlRYRfYTOZRoKNPsBl3ZAz1lbKBrkEiuSThMF(OuGk0eEZuJrfMsaXrvrtGWecFspxmxbsO(P97ZF4gKBrxdG60K0uPTL7zTS6LaYTifpek22dZpFukqfAcVzQXOctjG4OQOjqycHpPNlMRaju)0(nvykbKIhcLPsBRsbQqt4ntn25pCdYTORbqDAskmHWN0ZfZvGeQFA)UEjGClsXdHYuPTL7zTS6LaYTifpek22dtHje(KEUyUcKq9t73kfSGedi3I6YCBQ02UbUN1Yo)HBqUfDnaQtts2tH3g4Ewl78hUb5w01aOonjzf0jzUMJWN0tgvykbuxUwYbSyWFa)oaDYoimHWN0ZfZvGeQFA)MkmLaIBqRZuPTD7hROTKYdTuOYmwbDsMRFvNpF2a3ZAzfTLuEOLcvMHu9gjueNCiVGzRJWM9BGcti8j9CXCfiH6N2VPctjG4g06mvAB5EwltPGfKya5wuxMB2tH3g4Ewl78hUb5w01aOonjzpfEBG7zTSZF4gKBrxdG60KKvqNK5AUwcFspzuHPeqCdADm4pGFhGozheMq4t65I5kqc1pTFtfMsaXrvrtGPsBl3ZAz1lbKBrkEiuSNcpS7JThMmQWucifpekwb0oyEDkjMc(MB(cKh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mEQB9sW61eWwsLgprRZRop1TEjy9Acyh0v8IgOqQueMq4t65I5kqc1pTFtfMsaXrvrtGPsBl3ZAz1lbKBrkEiuSNcpUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfRGojZ1CTt4npUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz8urLK4gatMQG6GnYvGekHje(KEUyUcKq9t73uHPeqD5AjhWYuPTDdCpRLD(d3GCl6AauNMKSNcVJgqEmQWucia3484N7zTSnqxdNxjW2Ey(5dHpPkabj0LWQvn(4TbUN1Yo)HBqUfDnaQttswbDsMRFj8j9KrfMsa1LRLCalg8hWVdqNSd84xDP5rOKhWOctjGuE9omK5edsIBa7pF4EwldpaQW06K5ec3qzcd22dt(mf3qYSvntbQgbJWnKmrsBl3ZAz4bqfMwNmNq4gktyW2EyYJFUN1YOctjGu8qOypLpF4xDpAa5XCvqP4HqbBE8Z9Sww9sa5wKIhcf7P85d29X2dtgOYX0j9KvaTdMp(4tycHpPNlMRaju)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacF8WUp2EyYOctjGu8qOyf0jzU4Xp3ZAz1lbKBrkEiuSNYNpCpRLrfMsaP4HqXEk8zkUHKzRActi8j9CXCfiH6N2VPctjG8IZuPTL7zTmQWuciCdvtaBDe2S5AvrLK4ga78RJ60FeUHQjyXJFS7JThMmQWucifpekwbDsMRFvlWpFi8jvbiiHUewZ1gq(eMq4t65I5kqc1pTFtfMsaXnO1zQ02Y9Sww9sa5wKIhcf7P85tNsIPGVFvtDeMq4t65I5kqc1pTFdQCmDspnvAB5EwlREjGClsXdHIT9W0uzEqvpLdjTTDkjMc((TnaQoMkZdQ6PCizVdBjDqRActi8j9CXCfiH6N2VPctjG4OQOjqyIWKaaHMWN0ZfR8JoPN)0(nMsmmqe(KEAQ02s4t6jdu5y6KEYWnuMWqMt86usmf89B78wD4XV6wVeSEnbSLuPXt068Q)5d3ZAzlPsJNO15vNTocBwl3ZAzlPsJNO15vN1P)O1ryZ4tycHpPNlw5hDsp)P9BqLJPt6PPsBBNsIPGV5AvrLK4gadu5if8XJFS7JThMSZF4gKBrxdG60KKvqNK5AUwcFspzGkhtN0tg8hWVdqNSdF(GDFS9WKrfMsaP4HqXkOtYCnxlHpPNmqLJPt6jd(d43bOt2HpF4)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTe(KEYavoMoPNm4pGFhGozh4JpECpRLvVeqUfP4HqX2EyYJ7zTmQWucifpek22dtEBG7zTSZF4gKBrxdG60KKT9W0uzEqvpLdjTTDkjMc((TDERo84xDRxcwVMa2sQ04jADE1)8H7zTSLuPXt068QZwhHnRL7zTSLuPXt068QZ60F06iSz8zQmpOQNYHK9oSL0bTQjmHWN0ZfR8JoPN)0(nOYX0j90uPTTEjy9AcylPsJNO15vNh29X2dtgvykbKIhcfRGojZ1CTe(KEYavoMoPNm4pGFhGozheMeai0FrvrtGqlTcT8mFj0NSdc95c9Bbc95xxOPCl0HGq3qQaH(CxO7ugSqJBOAcwcti8j9CXk)Ot65pTFtfMsaXrvrtGPsBl29X2dt25pCdYTORbqDAsYkG2bZJFUN1YOctjGWnunbS1ryZ(vfvsIBaSZVoQt)r4gQMGfpS7JThMmQWucifpekwbDsMR5AH)a(Da6KDGpHje(KEUyLF0j98N2VPctjG4OQOjWuPTf7(y7Hj78hUb5w01aOonjzfq7G5Xp3ZAzuHPeq4gQMa26iSz)QIkjXna25xh1P)iCdvtWI3rdipw9sa5wKIhcfpS7JThMS6LaYTifpekwbDsMR5AH)a(Da6KDGh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePWNWecFspxSYp6KE(t73uHPeqCuv0eyQ02IDFS9WKD(d3GCl6AauNMKScODW84N7zTmQWuciCdvtaBDe2SFvrLK4ga78RJ60FeUHQjyXJF19ObKhREjGClsXdH6ZhS7JThMS6LaYTifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxOYv4Jh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePWNWecFspxSYp6KE(t73uHPeqCuv0eyQ02UbUN1YkAlP8qlfQmdP6nsOio5qEbZwhHnRDdCpRLv0ws5Hwkuzgs1BKqrCYH8cM1P)O1ryZ4Xp3ZAzuHPeqkEiuSThMF(W9SwgvykbKIhcfRGojZ1CTt4nF84N7zTS6LaYTifpek22dZpF4EwlREjGClsXdHIvqNK5AU2j8MpHje(KEUyLF0j98N2VPctjG4g06mvAB3(XkAlP8qlfQmJvqNK563a4Np8VbUN1YkAlP8qlfQmdP6nsOio5qEbZwhHn73a5TbUN1YkAlP8qlfQmdP6nsOio5qEbZwhHnBUnW9SwwrBjLhAPqLzivVrcfXjhYlywN(JwhHnJpHje(KEUyLF0j98N2VPctjG4g06mvAB5EwltPGfKya5wuxMB2tH3g4Ewl78hUb5w01aOonjzpfEBG7zTSZF4gKBrxdG60KKvqNK5AUwcFspzuHPeqCdADm4pGFhGozheMq4t65Iv(rN0ZFA)MkmLaQlxl5awMkTTBG7zTSZF4gKBrxdG60KK9u4D0aYJrfMsab4gNh)CpRLTb6A48kb22dZpFi8jvbiiHUewTQXhp(3a3ZAzN)Wni3IUga1PjjRGojZ1Ve(KEYOctjG6Y1soGfd(d43bOt2HpFWUp2EyYukybjgqUf1L5MvqNK563a)8b7QGKYJzwWLKs(4XV6sZJqjpGrfMsaP86DyiZjgKe3a2F(W9SwgEauHP1jZjeUHYegSThM8zkUHKzRAMcuncgHBizIK2wUN1YWdGkmTozoHWnuMWGT9WKh)CpRLrfMsaP4HqXEkF(WV6E0aYJ5QGsXdHc284N7zTS6LaYTifpek2t5ZhS7JThMmqLJPt6jRaAhmF8XNWecFspxSYp6KE(t73uHPeqD5AjhWYuPTL7zTm8aOctRtMtSci8XJ7zTm4VcLByJu8dYtsd2trycHpPNlw5hDsp)P9BQWucOUCTKdyzQ02Y9SwgEauHP1jZjwbe(4Xp3ZAzuHPeqkEiuSNYNpCpRLvVeqUfP4HqXEkF(SbUN1Yo)HBqUfDnaQttswbDsMRFj8j9KrfMsa1LRLCalg8hWVdqNSd8zkUHKzRActi8j9CXk)Ot65pTFtfMsa1LRLCaltL2wUN1YWdGkmTozoXkGWhpUN1YWdGkmTozoXwhHnRL7zTm8aOctRtMtSo9hTocBMP4gsMTQjmHWN0ZfR8JoPN)0(nvykbuxUwYbSmvAB5EwldpaQW06K5eRacF84EwldpaQW06K5eRGojZ1CT8Zp3ZAz4bqfMwNmNyRJWMn)t4t6jJkmLaQlxl5awm4pGFhGozh47Nj8MptXnKmBvtycHpPNlw5hDsp)P97eUgOqh0vG1zQ02YFb2cwne3a(8rDpj2mzoXhpUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz84EwlJkmLasXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMq4t65Iv(rN0ZFA)MkmLaYlotL2wUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGLWecFspxSYp6KE(t73RNcuPRImvAB7usmf8nx78wD4X9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHje(KEUyLF0j98N2VPctjG4g06mvAB5EwlREda5w01uaSypfECpRLrfMsaHBOAcyRJWM9BakmHWN0ZfR8JoPN)0(nvykbehvfnbMkTTDkjMc(MtfvsIBamoQkAcqDkjKc(4HDFS9WKbQCmDspzf0jzU(nqECpRLrfMsaP4HqX2EyYJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgpyTGedmvYL0tKBrkqzb8j9K1LPxcti8j9CXk)Ot65pTFtfMsaXrvrtGPsBBNsIPGV5AvrLK4gaJJQIMauNscPGpECpRLrfMsaP4HqX2EyYJ7zTS6LaYTifpek22dtEBG7zTSZF4gKBrxdG60KKT9WKh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mEy3hBpmzGkhtN0twbDsMRFduycHpPNlw5hDsp)P9BQWucioQkAcmvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HjpUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz8oAa5XOctjG8IJh29X2dtgvykbKxCSc6KmxZ1oH386usmf8nx78oqEy3hBpmzGkhtN0twbDsMlHje(KEUyLF0j98N2VPctjG4OQOjWuPTL7zTmQWucifpek2tHh3ZAzuHPeqkEiuSc6KmxZ1oH384EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMXd7(y7Hjdu5y6KEYkOtYCjmHWN0ZfR8JoPN)0(nvykbehvfnbMkTTCpRLvVeqUfP4HqXEk84EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSc6KmxZ1oH384EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMXd7(y7Hjdu5y6KEYkOtYCjmHWN0ZfR8JoPN)0(nvykbehvfnbMkTTCpRLrfMsaP4HqX2EyYJ7zTS6LaYTifpek22dtEBG7zTSZF4gKBrxdG60KK9u4TbUN1Yo)HBqUfDnaQttswbDsMR5ANWBECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZeMq4t65Iv(rN0ZFA)MkmLaIJQIMatL22JQj4ynanUgMc(MlavhECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ4vVeSEnbmQWucioVZr1Ud5XJWNufGGe6sy9RA84EwlBd01W5vcSThMcti8j9CXk)Ot65pTFtfMsab)vg(s6PPsB7r1eCSgGgxdtbFZfGQdpUN1YOctjGWnunbS1ryZMJ7zTmQWuciCdvtaRt)rRJWMXREjy9AcyuHPeqCENJQDhYJhHpPkabj0LW6x14X9Sw2gORHZReyBpmfMq4t65Iv(rN0ZFA)MkmLaIBqRtycHpPNlw5hDsp)P9BqLJPt6PPsBl3ZAz1lbKBrkEiuSThM84EwlJkmLasXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMq4t65Iv(rN0ZFA)MkmLaIJQIMaHjcti8j9CXwnubBeEV(P973cqDkj0e0nvAB5)ObKhdYHCQ5Ge286usmf8nxBamqEDkjMc((TDEQo895d)Q7rdipgKd5uZbjS51PKyk4BU2aO6WNWecFspxSvdvWgH3RFA)wXpPNMkTTCpRLrfMsaP4HqXEkcti8j9CXwnubBeEV(P97t2buivkMkTT1lbRxta7GUIx0afsLcpUN1YG)n0BDspzpfE8JDFS9WKrfMsaP4HqXkG2b)5Jvo1COc6KmxZ1oFbYNWecFspxSvdvWgH3RFA)EiNAUfA(9Bp1H8mvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxSvdvWgH3RFA)MJMqUfDLeB2YuPTL7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThMcti8j9CXwnubBeEV(P9BoOwqzMmNmvAB5EwlJkmLasXdHI9ueMq4t65ITAOc2i8E9t73Cd33i7Rc2uPTL7zTmQWucifpek2trycHpPNl2QHkyJW71pTFBLfWnCFBQ02Y9SwgvykbKIhcf7PimHWN0ZfB1qfSr496N2VPedRRObctJHPsBl3ZAzuHPeqkEiuSNIWecFspxSvdvWgH3RFA)(TaK8G(YuPTL7zTmQWucifpek2trycHpPNl2QHkyJW71pTF)wasEq3uWAb8HsQdTtdAlPZRfIJ2tGPsBl3ZAzuHPeqkEiuSNYNpy3hBpmzuHPeqkEiuSc6Kmx)2QoQdVnW9Sw25pCdYTORbqDAsYEkcti8j9CXwnubBeEV(P973cqYd6MMuhAHUsWfqdKx7KsmyQ02IDFS9WKrfMsaP4HqXkOtYCnxBaduycHpPNl2QHkyJW71pTF)wasEq30K6q7UaABLfGubRfmmvABXUp2EyYOctjGu8qOyf0jzU(TnGb(5J6QIkjXnagPG8e9wqRAF(W)j7qBG8urLK4gatMQG6GnYvGeQw14vVeSEnbSLuPXt068QZNWecFspxSvdvWgH3RFA)(TaK8GUPj1H2L)gi5ukpOmvABXUp2EyYOctjGu8qOyf0jzU(TnGb(5J6QIkjXnagPG8e9wqRAF(W)j7qBG8urLK4gatMQG6GnYvGeQw14vVeSEnbSLuPXt068QZNWecFspxSvdvWgH3RFA)(TaK8GUPj1H2PrWkni3IO1s2Ld6KEAQ02IDFS9WKrfMsaP4HqXkOtYC9BBad8Zh1vfvsIBamsb5j6TGw1(8H)t2H2a5PIkjXnaMmvb1bBKRajuTQXREjy9AcylPsJNO15vNpHje(KEUyRgQGncVx)0(9Bbi5bDttQdTDctCfGwnaCO(BjXMkTTy3hBpmzuHPeqkEiuSc6KmxZ1Qo84xDvrLK4gatMQG6GnYvGeQw1(85KD43amq(eMq4t65ITAOc2i8E9t73VfGKh0nnPo02jmXvaA1aWH6VLeBQ02IDFS9WKrfMsaP4HqXkOtYCnxR6WtfvsIBamzQcQd2ixbsOAvJh3ZAz1lbKBrkEiuSNcpUN1YQxci3Iu8qOyf0jzUMRLF1cC(L6m)xVeSEnbSLuPXt068QZhVt2H5cWaJg07A8kAyi7VbDspdIISx8Ixmc]] )


end
