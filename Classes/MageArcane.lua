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


    spec:RegisterPack( "Arcane", 20201123, [[dWKcafqisk5rcG4scqvPnHQ8jkQgfQQofQkRIKcLxPQIzrr6wKuizxO8lvLmmb0XiPAzcepJKIMgjfCnfv12uuf(MaugNaOoNIQuRJKsnpfvUNuAFQQ0bvufzHQk1dfGCrbOkFuaQ0jvuf1kPiEPauvmtbGBkavv2PIIFkavmubOQQLssHQNsHPQO0vfajFvaKAScK2Rq)fYGj1HrwmQ8yOMSsDzWMP0NvKrlfNMOvtsHuVMIYSv42s1Uf9BQgojoUIQKLl55kz6QCDvz7KKVlOXRQQZlqTEskeZxvX(jCu94SrJnDqCMGeyqcuD1dIAYuF(Q58iiQz04cwbIgke2mAcIgj1HOX8uHPeIgkuWdN2XzJgl)vyiA0CNYsT)6Rj5184yyV)1s2Fd6KEIlYEFTKD8xrdUNCCZZzKlASPdIZeKadsGQREqutM6ZxnNFqcyrJLcGJZmpcs0OrU3qg5IgByHJgbicDa)OjqONNkmLGWKaeHEgxf05GsOdIAAQqhKadsGcteMeGi0QXHURceAvujjUbWOoAPqDHwMcTLu5Lq7wHEb3jZPfJ6OLc1fA(Xna2mHoy)vc9sbWcTRCspx8XeMeGi0bOu20bBHwMhujne6gk3dzoj0UvOvrLK4gaRHubixbsyl0Nl0CGqRUqh2aPqVG7K50IrD0sH6cDRqRotysaIqhGAbc9fSIetdH2q2diHUHY9qMtcTBfACdLjmeAzEqvpLt6PqlZ1b0wODRqBoMsmmqe(KEAolAmKRBfNnA4kqcvC24mQhNnAajXnGD87ObUKhuskAWVqxVeSEnbSLuPXt068QZGK4gWwO)8rORxcwVMa2bDfVObkKkfgKe3a2cnFcnpH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe6Ff6afAEcn)cn3ZAz1lbKBrkEiuSThMc9NpcTsbQqt4ntDgvykbehvfnbcnFrdcFspJgGkhtN0Z4fNjiXzJgqsCdyh)oAGl5bLKIg1lbRxtaBlxyPYqMufmc79oLBgKe3a2cnpHM7zTSTCHLkdzsvWiS37uUr2Yxh7Peni8j9mAyLfG4g06IxCg1moB0asIBa743rdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08e6oLetbFc9Vc98E(rdcFspJg2YxhkDvu8IZOgIZgnGK4gWo(D0axYdkjfnulHUEjy9AcylPsJNO15vNbjXnGD0GWN0ZOXgORHZReIxCM5hNnAajXnGD87ObUKhuskA0PKyk4tO)vOvdbgni8j9mAu0ws5Hwkuzw8IZmpIZgnGK4gWo(D0axYdkjfnw(BWjZnZkHXg5we3WxlVVyqsCdyhni8j9mASAK2tMtifpeQ4fNjGfNnAajXnGD87ObUKhuskAOIkjXnaMmvb1bBKRajucDRqRUqZtOXUp2EyYQxci3Iu8qOyf0jzUe6wHoWObHpPNrdQWuciV4IxCMaCC2ObKe3a2XVJg4sEqjPOHkQKe3ayYufuhSrUcKqj0TcT6cnpHg7(y7HjREjGClsXdHIvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzc9Ccn3ZAzuHPeq4gQMawN(JwhHnlAq4t6z0GkmLaIBqRlEXzM3XzJgqsCdyh)oAGl5bLKIgQOssCdGjtvqDWg5kqcLq3k0Ql08eAUN1YQxci3Iu8qOyBpmJge(KEgnQxci3Iu8qOIxCg1dmoB0asIBa743rdCjpOKu0G7zTS6LaYTifpek22dZObHpPNrJnqxdNxjeV4mQREC2ObKe3a2XVJg4sEqjPOb3ZAz1lbKBrkEiuSThMc9NpcTsbQqt4ntDgvykbehvfnbrdcFspJgDzvETqUfDE1H8IxCg1dsC2ObKe3a2XVJg4sEqjPOb3ZAz1lbKBrkEiuSThMc9NpcTsbQqt4ntDgvykbehvfnbrdcFspJgN)Wni3IUga1Pjz8IZOUAgNnAajXnGD87ObUKhuskAOuGk0eEZuND(d3GCl6AauNMKrdcFspJguHPeqkEiuXloJ6QH4SrdijUbSJFhnWL8GssrdUN1YQxci3Iu8qOyBpmJge(KEgnQxci3Iu8qOIxCg1NFC2ObKe3a2XVJg4sEqjPOXg4Ewl78hUb5w01aOonjzpfHMNqVbUN1Yo)HBqUfDnaQttswbDsMlHEoHMWN0tgvykbuxUwYbSyWFa)oaDYoeni8j9mAOuWcsmGClQlZD8IZO(8ioB0asIBa743rdCjpOKu0y7hROTKYdTuOYmwbDsMlH(xHE(c9Npc9g4EwlROTKYdTuOYmKQ3iHI4Kd5fmBDe2mH(xHoWObHpPNrdQWuciUbTU4fNr9awC2ObKe3a2XVJg4sEqjPOb3ZAzkfSGedi3I6YCZEkcnpHEdCpRLD(d3GCl6AauNMKSNIqZtO3a3ZAzN)Wni3IUga1PjjRGojZLqpxRqt4t6jJkmLaIBqRJb)b87a0j7q0GWN0ZObvykbe3Gwx8IZOEaooB0asIBa743rdCjpOKu0G7zTS6LaYTifpek2trO5j0y3hBpmzuHPeqkEiuScODWcnpHUtjXuWNqpNqRgcuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0QLqxVeSEnbSLuPXt068QZGK4gWwO5j0QLqxVeSEnbSd6kErduivkmijUbSJge(KEgnOctjG4OQOjiEXzuFEhNnAajXnGD87ObUKhuskAW9Sww9sa5wKIhcf7Pi08eAUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSc6Kmxc9CTc9eEl08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08eAvujjUbWKPkOoyJCfiHkAq4t6z0GkmLaIJQIMG4fNjibgNnAajXnGD87ObUKhuskASbUN1Yo)HBqUfDnaQtts2trO5j0hnG8yuHPeqaUXzqsCdyl08eA(fAUN1Y2aDnCELaB7HPq)5Jqt4tQcqqcDjSe6wHwDHMpHMNqVbUN1Yo)HBqUfDnaQttswbDsMlH(xHMWN0tgvykbuxUwYbSyWFa)oaDYoi08eA(fA1sOj1iqjpGrfMsaP86DyiZjgKe3a2c9Npcn3ZAz4bqfMwNmNq4gktyW2Eyk08fnaQgbJWnKmrsB0G7zTm8aOctRtMtiCdLjmyBpm5Xp3ZAzuHPeqkEiuSNYNp8RwhnG8yUkOu8qOGnp(5EwlREjGClsXdHI9u(8b7(y7Hjdu5y6KEYkG2bZhF8fnWnKmJgQhni8j9mAqfMsa1LRLCaR4fNjiQhNnAajXnGD87ObUKhuskAW9SwgEauHP1jZjwbe(eAEcn29X2dtgvykbKIhcfRGojZLqZtO5xO5EwlREjGClsXdHI9ue6pFeAUN1YOctjGu8qOypfHMVObHpPNrdQWucOUCTKdyfnWnKmJgQhV4mbjiXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGD(1rD6pc3q1eSeAEcn)cn29X2dtgvykbKIhcfRGojZLq)RqREGc9NpcnHpPkabj0LWsONRvOdIqZx0GWN0ZObvykbKxCXlotquZ4SrdijUbSJFhnWL8GssrdUN1YQxci3Iu8qOypfH(ZhHUtjXuWNq)RqR(8Jge(KEgnOctjG4g06IxCMGOgIZgnGK4gWo(D0GWN0ZObOYX0j9mAiZdQ6PCiPnA0PKyk4732a88JgY8GQEkhs27WwshenupAGl5bLKIgCpRLvVeqUfP4HqX2EygV4mbz(XzJge(KEgnOctjG4OQOjiAajXnGD874fVObSwqIHvC24mQhNnAajXnGD87ObUKhuskAGDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntONRvOvrLK4ga78RJ60FeUHQjyj08eAS7JThMmQWucifpekwbDsMlHEUwHEcVf6pFeARCQ5qf0jzUe65eAS7JThMmQWucifpekwbDsMRObHpPNrdUH7BKBrxdGGe6bhV4mbjoB0asIBa743rdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sOBf6afAEcn)cTAj0hnG8yqoKtnhKWMbjXnGTq)5JqZVqF0aYJb5qo1CqcBgKe3a2cnpHUtjXuWNq)BRqhWcuO)8rOvrLK4gaJ6OLc1f6wHwDHMpHMpHMNqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcTkQKe3ayKcQt)rByqbJSEHo)6cnpHMFHM7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzc9NpcTkQKe3ayuhTuOUq3k0Ql08j08j0F(i08l0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe6wHoqHMpHMpHMNqZ9Sww9sa5wKIhcfB7HPqZtO7usmf8j0)2k0QOssCdGrkOUmL9xh1PKqk4lAq4t6z0GB4(g5w01aiiHEWXloJAgNnAajXnGD87ObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0)2k0ZpqHMNqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9CTc9eEl08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe65Af6j8wO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9crkrdcFspJgHEn2QazIky5jLyiEXzudXzJgqsCdyh)oAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpHg7(y7HjJkmLasXdHIvqNK5sONRvONWBH(ZhH2kNAoubDsMlHEoHg7(y7HjJkmLasXdHIvqNK5kAq4t6z0i0RXwfitublpPedXloZ8JZgnGK4gWo(D0axYdkjfnWUp2EyYOctjGu8qOyf0jzUe6wHoqHMNqZVqRwc9rdipgKd5uZbjSzqsCdyl0F(i08l0hnG8yqoKtnhKWMbjXnGTqZtO7usmf8j0)2k0bSaf6pFeAvujjUbWOoAPqDHUvOvxO5tO5tO5j08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5xO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMq)5JqRIkjXnag1rlfQl0TcT6cnFcnFc9Npcn)cn29X2dt25pCdYTORbqDAsYkOtYCj0TcDGcnpHM7zTmQWuciCdvtaBDe2mHUvOduO5tO5tO5j0CpRLvVeqUfP4HqX2Eyk08e6oLetbFc9VTcTkQKe3ayKcQltz)1rDkjKc(Ige(KEgnc9ASvbYevWYtkXq8IZmpIZgnGK4gWo(D0axYdkjfnWUp2EyYo)HBqUfDnaQttswbDsMlHUvOduO5j0CpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGD(1rD6pc3q1eSeAEcn29X2dtgvykbKIhcfRGojZLqpxRqpH3c9NpcTvo1COc6Kmxc9Ccn29X2dtgvykbKIhcfRGojZv0GWN0ZOX0JQTKsKBrKAeO8RjEXzcyXzJgqsCdyh)oAGl5bLKIgy3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5xOvlH(ObKhdYHCQ5Ge2mijUbSf6pFeA(f6JgqEmihYPMdsyZGK4gWwO5j0DkjMc(e6FBf6awGc9NpcTkQKe3ayuhTuOUq3k0Ql08j08j08eA(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaJuqD6pAddkyK1l05xxO5j08l0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO)8rOvrLK4gaJ6OLc1f6wHwDHMpHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMq3k0bk08j08j08eAUN1YQxci3Iu8qOyBpmfAEcDNsIPGpH(3wHwfvsIBamsb1LPS)6OoLesbFrdcFspJgtpQ2skrUfrQrGYVM4fNjahNnAajXnGD87ObUKhuskAW9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0Dkj2j7a6CuN(l0)2k0WFa)oaDYoeni8j9mAG9ed5v0bBKDqDiAmKjGW7OX8iEXzM3XzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmfAEcDNsIDYoGoh1P)c9VTcn8hWVdqNSdrdcFspJgfqkYCczhuhwXloJ6bgNnAajXnGD87ObUKhuskAW9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0W643c2isncuYdqCa1JxCg1vpoB0asIBa743rdCjpOKu0G7zTmQWucifpek22dtHMNqZ9Sww9sa5wKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZOHYRK2GL5eIBqRlEXzupiXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgnkPIYaqYeTuimeV4mQRMXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgnUga9so)LBK1lmeV4mQRgIZgnGK4gWo(D0axYdkjfn4EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqX2Eyk08e6nW9Sw25pCdYTORbqDAsY2Eygni8j9mA0HUxbJClA8WYnAxa1xXlErdS7JThMR4SXzupoB0asIBa743rdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHwnduO5j0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eA(fAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpHMFHMFH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe65Af6j8wO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9crkcnFc9Npcn)cTAj0hnG8y1lbKBrkEiumijUbSfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKIqZNq)5JqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0t4TqZNqZx0GWN0ZOHT81HsxffV4mbjoB0asIBa743rdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08eAS7JThMmQWucifpekwbDsMlHUvOduO5j08l0QLqF0aYJb5qo1CqcBgKe3a2c9Npcn)c9rdipgKd5uZbjSzqsCdyl08e6oLetbFc9VTcDalqHMpHMpHMNqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcT6bk08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08j0F(i08l0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe6wHoqHMpHMpHMNqZ9Sww9sa5wKIhcfB7HPqZtO7usmf8j0)2k0QOssCdGrkOUmL9xh1PKqk4lAq4t6z0Ww(6qPRIIxCg1moB0asIBa743rdCjpOKu0OEjy9AcyB5clvgYKQGryV3PCZGK4gWwO5j0y3hBpmzCpRfTLlSuzitQcgH9ENYnRaAhSqZtO5EwlBlxyPYqMufmc79oLBKT81X2Eyk08eA(fAUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMcnFcnpHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZVqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j08l08l0hnG8y1lbKBrkEiumijUbSfAEcn29X2dtw9sa5wKIhcfRGojZLqpxRqpH3cnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisrO5tO)8rO5xOvlH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(e6pFeAS7JThMmQWucifpekwbDsMlHEUwHEcVfA(eA(Ige(KEgnSLVooFCXloJAioB0asIBa743rdCjpOKu0OEjy9AcyB5clvgYKQGryV3PCZGK4gWwO5j0y3hBpmzCpRfTLlSuzitQcgH9ENYnRaAhSqZtO5EwlBlxyPYqMufmc79oLBKvwaB7HPqZtOvkqfAcVzQZSLVooFCrdcFspJgwzbiUbTU4fNz(XzJgqsCdyh)oAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWo)6Oo9hHBOAcwcnpHg7(y7HjJkmLasXdHIvqNK5sONRvONW7ObHpPNrJUSkVwi3IoV6qEXloZ8ioB0asIBa743rdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sOBf6afAEcn)cTAj0hnG8yqoKtnhKWMbjXnGTq)5JqZVqF0aYJb5qo1CqcBgKe3a2cnpHUtjXuWNq)BRqhWcuO5tO5tO5j08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntOBf6afA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnpHUtjXuWNq)BRqRIkjXnagPG6Yu2FDuNscPGVObHpPNrJUSkVwi3IoV6qEXlotaloB0asIBa743rdCjpOKu0a7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXna25xh1P)iCdvtWsO5j0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEhni8j9mASb6A48kH4fNjahNnAajXnGD87ObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0TcDGcnpHMFHwTe6JgqEmihYPMdsyZGK4gWwO)8rO5xOpAa5XGCiNAoiHndsIBaBHMNq3PKyk4tO)TvOdybk08j08j08eA(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvpqHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMq3k0bk08j08j08eAUN1YQxci3Iu8qOyBpmfAEcDNsIPGpH(3wHwfvsIBamsb1LPS)6OoLesbFrdcFspJgBGUgoVsiEXzM3XzJgqsCdyh)oAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnawTqD6pAddkyK1l05xxO5j0y3hBpmzuHPeqkEiuSc6Kmxc9VcTkQKe3ay1c1P)OnmOGrwVqKIqZtO5xOpAa5XQxci3Iu8qOyqsCdyl08eA(fAS7JThMS6LaYTifpekwbDsMlHEoHg(d43bOt2bH(ZhHg7(y7HjREjGClsXdHIvqNK5sO)vOvrLK4gaRwOo9hTHbfmY6fQCfHMpH(ZhHwTe6JgqES6LaYTifpekgKe3a2cnFcnpHM7zTmQWuciCdvtaBDe2mH(xHoicnpHEdCpRLD(d3GCl6AauNMKSThMcnpHM7zTS6LaYTifpek22dtHMNqZ9SwgvykbKIhcfB7Hz0GWN0ZOrrBjLhAPqLzXloJ6bgNnAajXnGD87ObUKhuskAGDFS9WKD(d3GCl6AauNMKSc6Kmxc9Ccn8hWVdqNSdcnpHM7zTmQWuciCdvtaBDe2mHEUwHwfvsIBaSZVoQt)r4gQMGLqZtOXUp2EyYOctjGu8qOyf0jzUe65eA(fA4pGFhGozhe6FeAcFspzN)Wni3IUga1Pjjd(d43bOt2bHMVObHpPNrJI2skp0sHkZIxCg1vpoB0asIBa743rdCjpOKu0a7(y7HjJkmLasXdHIvqNK5sONtOH)a(Da6KDqO5j08l08l0QLqF0aYJb5qo1CqcBgKe3a2c9Npcn)c9rdipgKd5uZbjSzqsCdyl08e6oLetbFc9VTcDalqHMpHMpHMNqZVqZVqJDFS9WKD(d3GCl6AauNMKSc6Kmxc9VcTkQKe3ayKcQt)rByqbJSEHo)6cnpHM7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzcnFc9Npcn)cn29X2dt25pCdYTORbqDAsYkOtYCj0TcDGcnpHM7zTmQWuciCdvtaBDe2mHUvOduO5tO5tO5j0CpRLvVeqUfP4HqX2Eyk08e6oLetbFc9VTcTkQKe3ayKcQltz)1rDkjKc(eA(Ige(KEgnkAlP8qlfQmlEXzupiXzJgqsCdyh)oAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9Cc98duO5j0WAbjgyQKlPNi3IuGYc4t6jRltVIge(KEgno)HBqUfDnaQttY4fNrD1moB0asIBa743rdCjpOKu0G7zTmQWuciCdvtaBDe2mHEUwHwfvsIBaSZVoQt)r4gQMGLqZtOXUp2EyYOctjGu8qOyf0jzUe65AfA4pGFhGozhIge(KEgno)HBqUfDnaQttY4fNrD1qC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayNFDuN(JWnunblHMNqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmz1lbKBrkEiuSc6Kmxc9CTcn8hWVdqNSdcnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisjAq4t6z048hUb5w01aOonjJxCg1NFC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayNFDuN(JWnunblHMNqZVqRwc9rdipw9sa5wKIhcfdsIBaBH(ZhHg7(y7HjREjGClsXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxOYveA(eAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKs0GWN0ZOX5pCdYTORbqDAsgV4mQppIZgnGK4gWo(D0axYdkjfnWUp2EyYo)HBqUfDnaQttswbDsMlH(xHwfvsIBamsb1P)OnmOGrwVqNFDHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqZ9Sww9sa5wKIhcfB7HPqZtO7usmf8j0)2k0QOssCdGrkOUmL9xh1PKqk4lAq4t6z0GkmLasXdHkEXzupGfNnAajXnGD87ObUKhuskAW9SwgvykbKIhcfB7HPqZtOXUp2EyYo)HBqUfDnaQttswbDsMlH(xHwfvsIBaSYvqD6pAddkyK1l05xxO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j08l0y3hBpmzuHPeqkEiuSc6Kmxc9VcT6ZxO)8rO3a3ZAzN)Wni3IUga1Pjj7Pi08fni8j9mAuVeqUfP4HqfV4mQhGJZgnGK4gWo(D0axYdkjfn4EwlJkmLasXdHIT9WuO5j0CpRLvVeqUfP4HqX2Eyk08e6nW9Sw25pCdYTORbqDAsY2Eygni8j9mASAK2tMtifpeQ4fNr95DC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeq4gQMa26iSzcDRqhOqZtOXUkiP8yMfCjPmAq4t6z0qPGfKya5wuxM74fNjibgNnAajXnGD87ObUKhuskASbUN1Yo)HBqUfDnaQtts2trO5j0BG7zTSZF4gKBrxdG60KKvqNK5sONtOj8j9KrfMsa1LRLCalg8hWVdqNSdcnpHwTeASRcskpMzbxskJge(KEgnukybjgqUf1L5oEXlAu(rN0Z4SXzupoB0asIBa743rdcFspJgGkhtN0ZOHmpOQNYHK2OrNsIPGVFBN3ZNh)Qv9sW61eWwsLgprRZR(NpCpRLTKknEIwNxD26iSzTCpRLTKknEIwNxDwN(JwhHnJVOHmpOQNYHK9oSL0brd1Jg4sEqjPOrNsIPGpHEUwHwfvsIBamqLJuWNqZtO5xOXUp2EyYo)HBqUfDnaQttswbDsMlHEUwHMWN0tgOYX0j9Kb)b87a0j7Gq)5JqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0e(KEYavoMoPNm4pGFhGozhe6pFeA(f6JgqES6LaYTifpekgKe3a2cnpHg7(y7HjREjGClsXdHIvqNK5sONRvOj8j9KbQCmDspzWFa)oaDYoi08j08j08eAUN1YQxci3Iu8qOyBpmfAEcn3ZAzuHPeqkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMXlotqIZgnGK4gWo(D0axYdkjfnQxcwVMa2sQ04jADE1zqsCdyl08eAS7JThMmQWucifpekwbDsMlHEUwHMWN0tgOYX0j9Kb)b87a0j7q0GWN0ZObOYX0j9mEXzuZ4SrdijUbSJFhnWL8GssrdS7JThMSZF4gKBrxdG60KKvaTdwO5j08l0CpRLrfMsaHBOAcyRJWMj0)k0QOssCdGD(1rD6pc3q1eSeAEcn29X2dtgvykbKIhcfRGojZLqpxRqd)b87a0j7GqZx0GWN0ZObvykbehvfnbXloJAioB0asIBa743rdCjpOKu0a7(y7Hj78hUb5w01aOonjzfq7GfAEcn)cn3ZAzuHPeq4gQMa26iSzc9VcTkQKe3ayNFDuN(JWnunblHMNqF0aYJvVeqUfP4HqXGK4gWwO5j0y3hBpmz1lbKBrkEiuSc6Kmxc9CTcn8hWVdqNSdcnpHg7(y7HjJkmLasXdHIvqNK5sO)vOvrLK4ga78RJ60F0gguWiRxisrO5lAq4t6z0GkmLaIJQIMG4fNz(XzJgqsCdyh)oAGl5bLKIgy3hBpmzN)Wni3IUga1PjjRaAhSqZtO5xO5EwlJkmLac3q1eWwhHntO)vOvrLK4ga78RJ60FeUHQjyj08eA(fA1sOpAa5XQxci3Iu8qOyqsCdyl0F(i0y3hBpmz1lbKBrkEiuSc6Kmxc9VcTkQKe3ayNFDuN(J2WGcgz9cvUIqZNqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(Ige(KEgnOctjG4OQOjiEXzMhXzJgqsCdyh)oAGl5bLKIgBG7zTSI2skp0sHkZqQEJekItoKxWS1ryZe6wHEdCpRLv0ws5Hwkuzgs1BKqrCYH8cM1P)O1ryZeAEcn)cn3ZAzuHPeqkEiuSThMc9Npcn3ZAzuHPeqkEiuSc6Kmxc9CTc9eEl08j08eA(fAUN1YQxci3Iu8qOyBpmf6pFeAUN1YQxci3Iu8qOyf0jzUe65Af6j8wO5lAq4t6z0GkmLaIJQIMG4fNjGfNnAajXnGD87ObUKhuskAS9Jv0ws5HwkuzgRGojZLq)RqhGf6pFeA(f6nW9SwwrBjLhAPqLzivVrcfXjhYly26iSzc9VcDGcnpHEdCpRLv0ws5Hwkuzgs1BKqrCYH8cMTocBMqpNqVbUN1YkAlP8qlfQmdP6nsOio5qEbZ60F06iSzcnFrdcFspJguHPeqCdADXlotaooB0asIBa743rdCjpOKu0G7zTmLcwqIbKBrDzUzpfHMNqVbUN1Yo)HBqUfDnaQtts2trO5j0BG7zTSZF4gKBrxdG60KKvqNK5sONRvOj8j9KrfMsaXnO1XG)a(Da6KDiAq4t6z0GkmLaIBqRlEXzM3XzJgqsCdyh)oAGl5bLKIgBG7zTSZF4gKBrxdG60KK9ueAEc9rdipgvykbeGBCgKe3a2cnpHMFHM7zTSnqxdNxjW2Eyk0F(i0e(KQaeKqxclHUvOvxO5tO5j08l0BG7zTSZF4gKBrxdG60KKvqNK5sO)vOj8j9KrfMsa1LRLCalg8hWVdqNSdc9Npcn29X2dtMsbliXaYTOUm3Sc6Kmxc9VcDGc9Npcn2vbjLhZSGljLcnFcnpHMFHwTeAsncuYdyuHPeqkVEhgYCIbjXnGTq)5JqZ9SwgEauHP1jZjeUHYegSThMcnFrdGQrWiCdjtK0gn4EwldpaQW06K5ec3qzcd22dtE8Z9SwgvykbKIhcf7P85d)Q1rdipMRckfpekyZJFUN1YQxci3Iu8qOypLpFWUp2EyYavoMoPNScODW8XhFrdCdjZOH6rdcFspJguHPeqD5AjhWkEXzupW4SrdijUbSJFhnWL8GssrdUN1YWdGkmTozoXkGWNqZtO5Ewld(Rq5g2if)G8K0G9uIge(KEgnOctjG6Y1soGv8IZOU6XzJgqsCdyh)oAGl5bLKIgCpRLHhavyADYCIvaHpHMNqZVqZ9SwgvykbKIhcf7Pi0F(i0CpRLvVeqUfP4HqXEkc9Npc9g4Ewl78hUb5w01aOonjzf0jzUe6FfAcFspzuHPeqD5AjhWIb)b87a0j7GqZx0GWN0ZObvykbuxUwYbSIg4gsMrd1JxCg1dsC2ObKe3a2XVJg4sEqjPOb3ZAz4bqfMwNmNyfq4tO5j0CpRLHhavyADYCITocBMq3k0CpRLHhavyADYCI1P)O1ryZIge(KEgnOctjG6Y1soGv0a3qYmAOE8IZOUAgNnAajXnGD87ObUKhuskAW9SwgEauHP1jZjwbe(eAEcn3ZAz4bqfMwNmNyf0jzUe65AfA(fA(fAUN1YWdGkmTozoXwhHntOvJj0e(KEYOctjG6Y1soGfd(d43bOt2bHMpH(hHEcVfA(Ige(KEgnOctjG6Y1soGv0a3qYmAOE8IZOUAioB0asIBa743rdCjpOKu0GFHUaBbRgIBac9NpcTAj0NeBMmNeA(eAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeAEcn3ZAzuHPeqkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMrdcFspJgjCnqHoORaRlEXzuF(XzJgqsCdyh)oAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGD(1rD6pc3q1eSIge(KEgnOctjG8IlEXzuFEeNnAajXnGD87ObUKhuskA0PKyk4tONRvON3ZxO5j0CpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgnwpfOsxffV4mQhWIZgnGK4gWo(D0axYdkjfn4EwlREda5w01uaSypfHMNqZ9SwgvykbeUHQjGTocBMq)RqRMrdcFspJguHPeqCdADXloJ6b44SrdijUbSJFhnWL8GssrJoLetbFc9CcTkQKe3ayCuv0eG6usif8j08eAS7JThMmqLJPt6jRGojZLq)RqhOqZtO5EwlJkmLasXdHIT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0WAbjgyQKlPNi3IuGYc4t6jRltVIge(KEgnOctjG4OQOjiEXzuFEhNnAajXnGD87ObUKhuskA0PKyk4tONRvOvrLK4gaJJQIMauNscPGpHMNqZ9SwgvykbKIhcfB7HPqZtO5EwlREjGClsXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5j0y3hBpmzGkhtN0twbDsMlH(xHoWObHpPNrdQWucioQkAcIxCMGeyC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dtHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqF0aYJrfMsa5fhdsIBaBHMNqJDFS9WKrfMsa5fhRGojZLqpxRqpH3cnpHUtjXuWNqpxRqpVduO5j0y3hBpmzGkhtN0twbDsMRObHpPNrdQWucioQkAcIxCMGOEC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeqkEiuSNIqZtO5EwlJkmLasXdHIvqNK5sONRvONWBHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqJDFS9WKbQCmDspzf0jzUIge(KEgnOctjG4OQOjiEXzcsqIZgnGK4gWo(D0axYdkjfn4EwlREjGClsXdHI9ueAEcn3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpekwbDsMlHEUwHEcVfAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeAEcn29X2dtgOYX0j9KvqNK5kAq4t6z0GkmLaIJQIMG4fNjiQzC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts2trO5j0BG7zTSZF4gKBrxdG60KKvqNK5sONRvONWBHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2SObHpPNrdQWucioQkAcIxCMGOgIZgnGK4gWo(D0axYdkjfnoQMGJ1a04Ayk4tONtOvZ5l08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08e66LG1RjGrfMsaX5DoQ2DipgKe3a2cnpHMWNufGGe6syj0)k0Ql08eAUN1Y2aDnCELaB7Hz0GWN0ZObvykbehvfnbXlotqMFC2ObKe3a2XVJg4sEqjPOXr1eCSgGgxdtbFc9CcTAoFHMNqZ9SwgvykbeUHQjGTocBMqpNqZ9SwgvykbeUHQjG1P)O1ryZeAEcD9sW61eWOctjG48ohv7oKhdsIBaBHMNqt4tQcqqcDjSe6FfA1fAEcn3ZAzBGUgoVsGT9WmAq4t6z0GkmLac(Rm8L0Z4fNjiZJ4SrdcFspJguHPeqCdADrdijUbSJFhV4mbjGfNnAajXnGD87ObUKhuskAW9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0au5y6KEgV4mbjahNnAq4t6z0GkmLaIJQIMGObKe3a2XVJx8IguhTuOEC24mQhNnAajXnGD87ObUKhuskA0PKyk4tONRvOvrLK4gadu5if8j08eA(fAS7JThMSZF4gKBrxdG60KKvqNK5sONRvOj8j9KbQCmDspzWFa)oaDYoi0F(i0y3hBpmzuHPeqkEiuSc6Kmxc9CTcnHpPNmqLJPt6jd(d43bOt2bH(ZhHMFH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe65AfAcFspzGkhtN0tg8hWVdqNSdcnFcnFcnpHM7zTS6LaYTifpek22dtHMNqZ9SwgvykbKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZObOYX0j9mEXzcsC2ObKe3a2XVJg4sEqjPOb29X2dtgvykbKIhcfRGojZLq3k0bk08eA(fAUN1YQxci3Iu8qOyBpmfAEcn)cn29X2dt25pCdYTORbqDAsYkOtYCj0)k0QOssCdGrkOo9hTHbfmY6f68Rl0F(i0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08j08fni8j9mASb6A48kH4fNrnJZgnGK4gWo(D0axYdkjfnWUp2EyYOctjGu8qOyf0jzUe6wHoqHMNqZVqZ9Sww9sa5wKIhcfB7HPqZtO5xOXUp2EyYo)HBqUfDnaQttswbDsMlH(xHwfvsIBamsb1P)OnmOGrwVqNFDH(ZhHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMpHMVObHpPNrJUSkVwi3IoV6qEXloJAioB0GWN0ZOrrBjLhAPqLzrdijUbSJFhV4mZpoB0asIBa743rdCjpOKu0G7zTmQWucifpek22dtHMNqZ9Sww9sa5wKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZOXQrApzoHu8qOIxCM5rC2ObKe3a2XVJg4sEqjPOb3ZAz1lbKBrkEiuSThMcnpHg7(y7HjJkmLasXdHIvqNK5sO)vOdmAq4t6z0OEjGClsXdHkEXzcyXzJgqsCdyh)oAGl5bLKIg8l0y3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5EwlREjGClsXdHIT9WuO5tO)8rOvkqfAcVzQZQxci3Iu8qOIge(KEgno)HBqUfDnaQttY4fNjahNnAajXnGD87ObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0Zj0ZpqHMNqZ9Sww9sa5wKIhcfB7HPqZtOH1csmWujxsprUfPaLfWN0tgKe3a2rdcFspJgN)Wni3IUga1Pjz8IZmVJZgnGK4gWo(D0axYdkjfn4EwlREjGClsXdHIT9WuO5j0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVE0GWN0ZObvykbKIhcv8IZOEGXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqXEkcnpHM7zTmQWucifpekwbDsMlHEUwHMWN0tgvykbuxUwYbSyWFa)oaDYoi08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMfni8j9mAqfMsaXrvrtq8IZOU6XzJgqsCdyh)oAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0Zj0CpRLrfMsaHBOAcyD6pADe2mHMNqZ9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WmAq4t6z0GkmLaYlU4fNr9GeNnAajXnGD87ObUKhuskAW9Sww9sa5wKIhcfB7HPqZtO5EwlJkmLasXdHIT9WuO5j0BG7zTSZF4gKBrxdG60KKT9WuO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHnlAq4t6z0GkmLaIJQIMG4fNrD1moB0asIBa743rdCjpOKu0G7zTm8aOctRtMtSci8fnaQgbJWnKmrsB0G7zTm8aOctRtMtiCdLjmyBpm5Xp3ZAzuHPeqkEiuSNYNpCpRLvVeqUfP4HqXEkF(GDFS9WKbQCmDspzfq7G5lAGBizgnupAq4t6z0GkmLaQlxl5awXloJ6QH4SrdijUbSJFhnWL8Gssrd1sOj1iqjpGrfMsaP86DyiZjgKe3a2c9Npcn3ZAz4bqfMwNmNq4gktyW2EygnaQgbJWnKmrsB0G7zTm8aOctRtMtiCdLjmyBpm5Xp3ZAzuHPeqkEiuSNYNpCpRLvVeqUfP4HqXEkF(GDFS9WKbQCmDspzfq7G5lAGBizgnupAq4t6z0GkmLaQlxl5awXloJ6ZpoB0asIBa743rdCjpOKu0G7zTS6LaYTifpek22dtHMNqZ9SwgvykbKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZObOYX0j9mEXzuFEeNnAajXnGD87ObUKhuskAW9SwgvykbeUHQjGTocBMqpNqZ9SwgvykbeUHQjG1P)O1ryZIge(KEgnOctjG8IlEXzupGfNnAq4t6z0GkmLaIJQIMGObKe3a2XVJxCg1dWXzJge(KEgnOctjG4g06IgqsCdyh)oEXlA0DvqhYloBCg1JZgnGK4gWo(D0axYdkjfn6UkOd5X2Y1rjge6FBfA1dmAq4t6z0GBitZIxCMGeNnAq4t6z0qPGfKya5wuxM7ObKe3a2XVJxCg1moB0asIBa743rdCjpOKu0O7QGoKhBlxhLyqONtOvpWObHpPNrdQWucOUCTKdyfV4mQH4SrdcFspJguHPeqEXfnGK4gWo(D8IZm)4SrdcFspJgwzbiUbTUObKe3a2XVJx8IgkfG9ohDXzJZOEC2ObKe3a2XVJgUs0OGfCrdcFspJgQOssCdiAOIkusDiAOuGYBmqGkpASbl9gx0iW4fNjiXzJgqsCdyh)oA4krJfCrdcFspJgQOssCdiAOIgpiAOE0qfvOK6q0qPaL3yGavE0axYdkjfnurLK4gatPaL3yGavUq3k0bk08e66LG1RjGTKknEIwNxDgKe3a2cnpHMWNufGGe6syj0)k0bjEXzuZ4SrdijUbSJFhnCLOXcUObHpPNrdvujjUbenurJhenupAOIkusDiAOuGYBmqGkpAGl5bLKIgQOssCdGPuGYBmqGkxOBf6afAEcD9sW61eWwsLgprRZRodsIBaBHMNqJDvqs5Xsax(WRTqZtOj8jvbiiHUewc9VcT6XloJAioB0asIBa743rdxjASGlAq4t6z0qfvsIBardv04brJaJgQOcLuhIgkfO8gdeOYJg4sEqjPOHkQKe3aykfO8gdeOYf6wHoW4fNz(XzJgqsCdyh)oA4krJfCrdcFspJgQOssCdiAOIgpiAey0qfvOK6q0OHubixbsyhV4mZJ4SrdijUbSJFhnCLOXcUObHpPNrdvujjUbenurJhenupAOIkusDiA0qQaKRajSJg4sEqjPOHkQKe3aynKka5kqcBHUvOduO5j0e(KQaeKqxclH(xHoiXlotaloB0asIBa743rdxjASGlAq4t6z0qfvsIBardv04brd1JgQOcLuhIgnKka5kqc7ObUKhuskAOIkjXnawdPcqUcKWwOBf6afAEcTkQKe3aykfO8gdeOYf6wHw94fNjahNnAajXnGD87OHRenwWfni8j9mAOIkjXnGOHkA8GOrGrdvuHsQdrdRmPbI7vz8IZmVJZgnGK4gWo(D0WvIgfSGlAq4t6z0qfvsIBardvuHsQdrJAH60F0gguWiRxOZVE0ydw6nUOX8JxCg1dmoB0asIBa743rdxjAuWcUObHpPNrdvujjUbenurfkPoenQfQt)rByqbJSEHkxjASbl9gx0y(XloJ6QhNnAajXnGD87OHRenkybx0GWN0ZOHkQKe3aIgQOcLuhIg1c1P)OnmOGrwVqKs0ydw6nUOrqcmEXzupiXzJgqsCdyh)oA4krJcwWfni8j9mAOIkjXnGOHkQqj1HObPG60F0gguWiRxOZVE0ydw6nUOH6bgV4mQRMXzJgqsCdyh)oA4krJcwWfni8j9mAOIkjXnGOHkQqj1HOr5kOo9hTHbfmY6f68Rhn2GLEJlAeKaJxCg1vdXzJgqsCdyh)oA4krJcwWfni8j9mAOIkjXnGOHkQqj1HOX5xh1P)OnmOGrwVqKs0ydw6nUOrGXloJ6ZpoB0asIBa743rdxjASGlAq4t6z0qfvsIBardv04brd1mAOIkusDiAC(1rD6pAddkyK1lePenWL8GssrdvujjUbWo)6Oo9hTHbfmY6fIue6wHoqHMNqxVeSEnbSTCHLkdzsvWiS37uUzqsCdyhV4mQppIZgnGK4gWo(D0WvIgl4Ige(KEgnurLK4gq0qfnEq0q95hnurfkPoeno)6Oo9hTHbfmY6fIuIg4sEqjPOHkQKe3ayNFDuN(J2WGcgz9crkcDRqhOqZtOXUkiP8yPCQ5qwcIxCg1dyXzJgqsCdyh)oA4krJfCrdcFspJgQOssCdiAOIgpiAO(8JgQOcLuhIgNFDuN(J2WGcgz9crkrdCjpOKu0qfvsIBaSZVoQt)rByqbJSEHifHUvOduO5j0yp3p5XOctjGukFlNcMbjXnGTqZtOj8jvbiiHUewc9CcTAgV4mQhGJZgnGK4gWo(D0WvIgl4Ige(KEgnurLK4gq0qfnEq0qndmAOIkusDiAC(1rD6pAddkyK1lePenWL8GssrdvujjUbWo)6Oo9hTHbfmY6fIue6wHoqHMNqdRfKyGPsUKEIClsbklGpPNSUm9kEXzuFEhNnAajXnGD87OHRenwWfni8j9mAOIkjXnGOHkA8GOX8JgQOcLuhIgNFDuN(J2WGcgz9crkrdCjpOKu0qfvsIBaSZVoQt)rByqbJSEHifHUvOdmEXzcsGXzJgqsCdyh)oA4krJcwWfni8j9mAOIkjXnGOHkQqj1HOX5xh1P)OnmOGrwVqLRen2GLEJlAeKaJxCMGOEC2ObKe3a2XVJgUs0OGfCrdcFspJgQOssCdiAOIkusDiAWrvrtaQtjHuWx0ydw6nUOrGXlotqcsC2ObKe3a2XVJgUs0ybx0GWN0ZOHkQKe3aIgQOXdIg8l0ZJafA1OeA(f6oToOcgPIgpqOvJj0QhyGcnFcnFrdvuHsQdrdoQkAcqDkjKc(Ig4sEqjPOHkQKe3ayCuv0eG6usif8j0TcDGcnpHg7QGKYJLYPMdzjiEXzcIAgNnAajXnGD87OHRenwWfni8j9mAOIkjXnGOHkA8GOb)cDaoqHwnkHMFHUtRdQGrQOXdeA1ycT6bgOqZNqZx0qfvOK6q0GJQIMauNscPGVObUKhuskAOIkjXnaghvfnbOoLesbFcDRqhy8IZee1qC2ObKe3a2XVJgUs0OGfCrdcFspJgQOssCdiAOIkusDiAqkOUmL9xh1PKqk4lASbl9gx0iW4fNjiZpoB0asIBa743rdxjASGlAq4t6z0qfvsIBardv04brJ5hy0qfvOK6q0GuqDzk7VoQtjHuWx0axYdkjfnurLK4gaJuqDzk7VoQtjHuWNq3k0bk08e66LG1RjGTLlSuzitQcgH9ENYndsIBa74fNjiZJ4SrdijUbSJFhnCLOXcUObHpPNrdvujjUbenurJhenMFGrdvuHsQdrdsb1LPS)6OoLesbFrdCjpOKu0qfvsIBamsb1LPS)6OoLesbFcDRqhOqZtORxcwVMa2ujxJGrsSepagKe3a2XlotqcyXzJgqsCdyh)oA4krJfCrdcFspJgQOssCdiAOIgpiAO(8JgQOcLuhIgKcQltz)1rDkjKc(Ig4sEqjPOHkQKe3ayKcQltz)1rDkjKc(e6wHoW4fNjib44SrdijUbSJFhnCLOrbl4Ige(KEgnurLK4gq0qfvOK6q048RJ60FeUHQjyfn2GLEJlAeK4fNjiZ74SrdijUbSJFhnCLOrbl4Ige(KEgnurLK4gq0qfvOK6q0qMQG6GnYvGeQOXgS0BCrJaJxCg1mW4SrdijUbSJFhnCLOXcUObHpPNrdvujjUbenurJhenupAOIkusDiAitvqDWg5kqcv0axYdkjfnurLK4gatMQG6GnYvGekHUvOduO5j0hnG8y1lbKBrkEiumijUbSfAEcn)c9rdipgvykbeGBCgKe3a2c9NpcTAj0yxfKuEmZcUKuk08j08eA(fA1sOXUkiP8yjGlF41wO)8rOj8jvbiiHUewcDRqRUq)5JqxVeSEnbSLuPXt068QZGK4gWwO5lEXzut1JZgnGK4gWo(D0WvIgl4Ige(KEgnurLK4gq0qfnEq0iWOHkQqj1HOHmvb1bBKRajurdCjpOKu0qfvsIBamzQcQd2ixbsOe6wHoW4fNrndsC2ObKe3a2XVJgUs0ybx0GWN0ZOHkQKe3aIgQOXdIgW86jvuGnRtyIRa0QbGd1FljwO)8rOH51tQOaB20G2s68AH4O9ei0F(i0W86jvuGnBAqBjDETqDytJH0tH(ZhHgMxpPIcSzBQmR7EI2a2mKY7kyHHedc9NpcnmVEsffyZK5cxVJ4gaAE9O8ED0gujXGq)5JqdZRNurb2SL)gd4ozoHQhxWc9NpcnmVEsffyZwVKB4(grD4AcEDc9NpcnmVEsffyZcjZGeQfYwEUf6pFeAyE9KkkWMzhuhqUfXr3nGOHkQqj1HObPG8e9wq8IZOMQzC2ObKe3a2XVJgUs0OGfCrdcFspJgQOssCdiAOIkusDiAqoGo)6Oo9hHBOAcwrJnyP34IgbjEXzut1qC2ObKe3a2XVJgUs0ybx0GWN0ZOHkQKe3aIgQOXdIgQhnurfkPoenAivaYvGe2rdCjpOKu0qfvsIBaSgsfGCfiHTq3k0bk08e6fCNmNwmQJwkuxOBfA1JxCg1C(XzJgqsCdyh)oA4krJcwWfni8j9mAOIkjXnGOHkQqj1HObOYrk4lASbl9gx0q95hV4mQ58ioB0asIBa743XloJAgWIZgnGK4gWo(D8IZOMb44SrdijUbSJFhV4mQ58ooB0GWN0ZOX617EIOctjGSuxoKufnGK4gWo(D8IZOgcmoB0GWN0ZObvykbKmpyma8fnGK4gWo(D8IZOgupoB0GWN0ZOb2t1OFfG6usOjOhnGK4gWo(D8IZOgcsC2ObKe3a2XVJxCg1GAgNnAq4t6z0OlRYlKSttq0asIBa743XloJAqneNnAajXnGD87ObUKhuskAOwcTkQKe3aykfO8gdeOYf6wHwDHMNqxVeSEnbSTCHLkdzsvWiS37uUzqsCdyhni8j9mAylFDC(4IxCg1W8JZgnGK4gWo(D0axYdkjfnulHwfvsIBamLcuEJbcu5cDRqRUqZtOvlHUEjy9AcyB5clvgYKQGryV3PCZGK4gWoAq4t6z0GkmLaIBqRlEXzudZJ4SrdijUbSJFhnWL8GssrdvujjUbWukq5ngiqLl0TcT6rdcFspJgGkhtN0Z4fVOb5qC24mQhNnAajXnGD87ObUKhuskAuVeSEnbSTCHLkdzsvWiS37uUzqsCdyl08eAS7JThMmUN1I2YfwQmKjvbJWEVt5MvaTdwO5j0CpRLTLlSuzitQcgH9ENYnYw(6yBpmfAEcn)cn3ZAzuHPeqkEiuSThMcnpHM7zTS6LaYTifpek22dtHMNqVbUN1Yo)HBqUfDnaQtts22dtHMpHMNqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5xO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeAEcn)cn)c9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKvVeqUfP4HqXkOtYCj0Z1k0t4TqZtOXUp2EyYOctjGu8qOyf0jzUe6FfAvujjUbWo)6Oo9hTHbfmY6fIueA(e6pFeA(fA1sOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHwfvsIBaSZVoQt)rByqbJSEHifHMpH(ZhHg7(y7HjJkmLasXdHIvqNK5sONRvONWBHMpHMVObHpPNrdB5RJZhx8IZeK4SrdijUbSJFhnWL8Gssrd(f66LG1RjGTLlSuzitQcgH9ENYndsIBaBHMNqJDFS9WKX9Sw0wUWsLHmPkye27Dk3ScODWcnpHM7zTSTCHLkdzsvWiS37uUrwzbSThMcnpHwPavOj8MPoZw(648Xj08j0F(i08l01lbRxtaBlxyPYqMufmc79oLBgKe3a2cnpH(KDqOBf6afA(Ige(KEgnSYcqCdADXloJAgNnAajXnGD87ObUKhuskAuVeSEnbSPsUgbJKyjEamijUbSfAEcn29X2dtgvykbKIhcfRGojZLq)RqRMbk08eAS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn)cn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZtO5xO5xOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMS6LaYTifpekwbDsMlHEUwHEcVfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKIqZNq)5JqZVqRwc9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePi08j0F(i0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEl08j08fni8j9mAylFDO0vrXloJAioB0asIBa743rdCjpOKu0OEjy9AcytLCncgjXs8ayqsCdyl08eAS7JThMmQWucifpekwbDsMlHUvOduO5j08l08l08l0y3hBpmzN)Wni3IUga1PjjRGojZLq)RqRIkjXnagPG60F0gguWiRxOZVUqZtO5EwlJkmLac3q1eWwhHntOBfAUN1YOctjGWnunbSo9hTocBMqZNq)5JqZVqJDFS9WKD(d3GCl6AauNMKSc6KmxcDRqhOqZtO5EwlJkmLac3q1eWwhHntONRvOvrLK4gaJCaD(1rD6pc3q1eSeA(eA(eAEcn3ZAz1lbKBrkEiuSThMcnFrdcFspJg2YxhkDvu8IZm)4SrdijUbSJFhnWL8GssrJ6LG1RjGTKknEIwNxDgKe3a2cnpHwPavOj8MPodu5y6KEgni8j9mAC(d3GCl6AauNMKXloZ8ioB0asIBa743rdCjpOKu0OEjy9AcylPsJNO15vNbjXnGTqZtO5xOvkqfAcVzQZavoMoPNc9NpcTsbQqt4ntD25pCdYTORbqDAsk08fni8j9mAqfMsaP4HqfV4mbS4SrdijUbSJFhnWL8GssrJt2bH(xHwnduO5j01lbRxtaBjvA8eToV6mijUbSfAEcn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZtOXUp2EyYo)HBqUfDnaQttswbDsMlHUvOduO5j0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEhni8j9mAaQCmDspJxCMaCC2ObKe3a2XVJge(KEgnavoMoPNrdzEqvpLdjTrdUN1YwsLgprRZRoBDe2SwUN1YwsLgprRZRoRt)rRJWMfnK5bv9uoKS3HTKoiAOE0axYdkjfnozhe6FfA1mqHMNqxVeSEnbSLuPXt068QZGK4gWwO5j0y3hBpmzuHPeqkEiuSc6KmxcDRqhOqZtO5xO5xO5xOXUp2EyYo)HBqUfDnaQttswbDsMlH(xHwfvsIBamsb1P)OnmOGrwVqNFDHMNqZ9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMpH(ZhHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6wHoqHMNqZ9SwgvykbeUHQjGTocBMqpxRqRIkjXnag5a68RJ60FeUHQjyj08j08j08eAUN1YQxci3Iu8qOyBpmfA(IxCM5DC2ObKe3a2XVJg4sEqjPOb)cn29X2dtgvykbKIhcfRGojZLq)RqRgMVq)5JqJDFS9WKrfMsaP4HqXkOtYCj0Z1k0QPqZNqZtOXUp2EyYo)HBqUfDnaQttswbDsMlHUvOduO5j08l0CpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGroGo)6Oo9hHBOAcwcnpHMFHMFH(ObKhREjGClsXdHIbjXnGTqZtOXUp2EyYQxci3Iu8qOyf0jzUe65Af6j8wO5j0y3hBpmzuHPeqkEiuSc6Kmxc9Vc98fA(e6pFeA(fA1sOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMmQWucifpekwbDsMlH(xHE(cnFc9Npcn29X2dtgvykbKIhcfRGojZLqpxRqpH3cnFcnFrdcFspJgDzvETqUfDE1H8IxCg1dmoB0asIBa743rdCjpOKu0a7(y7Hj78hUb5w01aOonjzf0jzUe65eA4pGFhGozheAEcn)cn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZtO5xO5xOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMS6LaYTifpekwbDsMlHEUwHEcVfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKIqZNq)5JqZVqRwc9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePi08j0F(i0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEl08j08fni8j9mAu0ws5Hwkuzw8IZOU6XzJgqsCdyh)oAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9Ccn8hWVdqNSdcnpHMFHMFHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6FfAvujjUbWifuN(J2WGcgz9cD(1fAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeA(e6pFeA(fAS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZNqZNqZtO5EwlREjGClsXdHIT9WuO5lAq4t6z0OOTKYdTuOYS4fNr9GeNnAajXnGD87ObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0TcDGcnpHMFHMFHMFHg7(y7Hj78hUb5w01aOonjzf0jzUe6FfAvujjUbWifuN(J2WGcgz9cD(1fAEcn3ZAzuHPeq4gQMa26iSzcDRqZ9SwgvykbeUHQjG1P)O1ryZeA(e6pFeA(fAS7JThMSZF4gKBrxdG60KKvqNK5sOBf6afAEcn3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZNqZNqZtO5EwlREjGClsXdHIT9WuO5lAq4t6z0yd01W5vcXloJ6QzC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeq4gQMa26iSzc9CTcTkQKe3ayKdOZVoQt)r4gQMGLqZtO5xO5xOpAa5XQxci3Iu8qOyqsCdyl08eAS7JThMS6LaYTifpekwbDsMlHEUwHEcVfAEcn29X2dtgvykbKIhcfRGojZLq)RqRIkjXna25xh1P)OnmOGrwVqKIqZNq)5JqZVqRwc9rdipw9sa5wKIhcfdsIBaBHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0QOssCdGD(1rD6pAddkyK1lePi08j0F(i0y3hBpmzuHPeqkEiuSc6Kmxc9CTc9eEl08fni8j9mAC(d3GCl6AauNMKXloJ6QH4SrdijUbSJFhnWL8Gssrd(fA(fAS7JThMSZF4gKBrxdG60KKvqNK5sO)vOvrLK4gaJuqD6pAddkyK1l05xxO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHntO5tO)8rO5xOXUp2EyYo)HBqUfDnaQttswbDsMlHUvOduO5j0CpRLrfMsaHBOAcyRJWMj0Z1k0QOssCdGroGo)6Oo9hHBOAcwcnFcnFcnpHM7zTS6LaYTifpek22dZObHpPNrdQWucifpeQ4fNr95hNnAajXnGD87ObUKhuskAW9Sww9sa5wKIhcfB7HPqZtO5xO5xOXUp2EyYo)HBqUfDnaQttswbDsMlH(xHoibk08eAUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08j0F(i08l0y3hBpmzN)Wni3IUga1PjjRGojZLq3k0bk08eAUN1YOctjGWnunbS1ryZe65AfAvujjUbWihqNFDuN(JWnunblHMpHMpHMNqZVqJDFS9WKrfMsaP4HqXkOtYCj0)k0QpFH(ZhHEdCpRLD(d3GCl6AauNMKSNIqZx0GWN0ZOr9sa5wKIhcv8IZO(8ioB0asIBa743rdCjpOKu0G7zTmQWucifpek22dtHMNqZ9Sww9sa5wKIhcfB7HPqZtO3a3ZAzN)Wni3IUga1PjjB7Hz0GWN0ZOXQrApzoHu8qOIxCg1dyXzJgqsCdyh)oAGl5bLKIgCpRLTb6A48kb2trO5j0BG7zTSZF4gKBrxdG60KK9ueAEc9g4Ewl78hUb5w01aOonjzf0jzUe65AfAUN1YukybjgqUf1L5M1P)O1ryZeA1ycnHpPNmQWuciUbTog8hWVdqNSdrdcFspJgkfSGedi3I6YChV4mQhGJZgnGK4gWo(D0axYdkjfn4EwlBd01W5vcSNIqZtO5xO5xOpAa5Xky5jLyGbjXnGTqZtOj8jvbiiHUewc9CcTAqO5tO)8rOj8jvbiiHUewc9Cc98fA(eAEcn)cTAj01lbRxtaJkmLaIZ7CuT7qEmijUbSf6pFe6JQj4ynanUgMc(e6FfA1C(cnFrdcFspJguHPeqCdADXloJ6Z74SrdcFspJgRNcuPRIIgqsCdyh)oEXzcsGXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0TcDGrdcFspJguHPeqEXfV4mbr94SrdijUbSJFhnWL8Gssrd(f6cSfSAiUbi0F(i0QLqFsSzYCsO5tO5j0CpRLrfMsaHBOAcyRJWMj0Tcn3ZAzuHPeq4gQMawN(JwhHnlAq4t6z0iHRbk0bDfyDXlotqcsC2ObKe3a2XVJg4sEqjPOb3ZAz4bqfMwNmNyfq4tO5j01lbRxtaJkmLasMwzkVGzqsCdyl08e6JgqEmQRmKwjMoPNmijUbSfAEcnHpPkabj0LWsONtOdWrdcFspJguHPeqD5AjhWkEXzcIAgNnAajXnGD87ObUKhuskAW9SwgEauHP1jZjwbe(eAEcn)cD9sW61eWOctjGKPvMYlygKe3a2c9Npc9rdipg1vgsRetN0tgKe3a2cnFcnpHMWNufGGe6syj0Zj0ZpAq4t6z0GkmLaQlxl5awXlotqudXzJgqsCdyh)oAGl5bLKIgCpRLrfMsaHBOAcyRJWMj0Zj0CpRLrfMsaHBOAcyD6pADe2SObHpPNrdQWuci4VYWxspJxCMGm)4SrdijUbSJFhnWL8GssrdUN1YOctjGWnunbS1ryZe6wHM7zTmQWuciCdvtaRt)rRJWMj08eALcuHMWBM6mQWucioQkAcIge(KEgnOctjGG)kdFj9mEXzcY8ioB0asIBa743rdCjpOKu0G7zTmQWuciCdvtaBDe2mHUvO5EwlJkmLac3q1eW60F06iSzrdcFspJguHPeqCuv0eeV4mbjGfNnAiZdQ6PCiPnA0PKyk4732a88JgY8GQEkhs27WwshenupAq4t6z0au5y6KEgnGK4gWo(D8Ix0y1qfSr49koBCg1JZgnGK4gWo(D0axYdkjfn4xOpAa5XGCiNAoiHndsIBaBHMNq3PKyk4tONRvOdWbk08e6oLetbFc9VTc98y(cnFc9Npcn)cTAj0hnG8yqoKtnhKWMbjXnGTqZtO7usmf8j0Z1k0b45l08fni8j9mA0PKqtqpEXzcsC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeqkEiuSNs0GWN0ZOHIFspJxCg1moB0asIBa743rdCjpOKu0OEjy9Acyh0v8IgOqQuyqsCdyl08eAUN1YG)n0BDspzpfHMNqZVqJDFS9WKrfMsaP4HqXkG2bl0F(i0w5uZHkOtYCj0Z1k0QHafA(Ige(KEgnozhqHuPeV4mQH4SrdijUbSJFhnWL8GssrdUN1YOctjGu8qOyBpmfAEcn3ZAz1lbKBrkEiuSThMcnpHEdCpRLD(d3GCl6AauNMKSThMrdcFspJgd5uZTqQr)2tDiV4fNz(XzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqX2Eyk08eAUN1YQxci3Iu8qOyBpmfAEc9g4Ewl78hUb5w01aOonjzBpmJge(KEgn4OjKBrxjXMTIxCM5rC2ObKe3a2XVJg4sEqjPOb3ZAzuHPeqkEiuSNs0GWN0ZObhulOmtMtXlotaloB0asIBa743rdCjpOKu0G7zTmQWucifpek2tjAq4t6z0GB4(gzFvWXlotaooB0asIBa743rdCjpOKu0G7zTmQWucifpek2tjAq4t6z0WklGB4(oEXzM3XzJgqsCdyh)oAGl5bLKIgCpRLrfMsaP4HqXEkrdcFspJguIH1v0aHPXiEXzupW4SrdijUbSJFhnWL8GssrdUN1YOctjGu8qOypLObHpPNrJ3cqYd6R4fNrD1JZgnGK4gWo(D0axYdkjfn4EwlJkmLasXdHI9ue6pFeAS7JThMmQWucifpekwbDsMlH(3wHE(ZxO5j0BG7zTSZF4gKBrxdG60KK9uIge(KEgnMg0wsNxlehTNGObyTa(qj1HOX0G2s68AH4O9eeV4mQhK4SrdijUbSJFhnsQdrdOReCb0a51oPedrdcFspJgqxj4cObYRDsjgIg4sEqjPOb29X2dtgvykbKIhcfRGojZLqpxRqhKaJxCg1vZ4SrdijUbSJFhnsQdrJDb02klaPcwlyeni8j9mASlG2wzbivWAbJObUKhuskAGDFS9WKrfMsaP4HqXkOtYCj0)2k0bjqH(ZhHwTeAvujjUbWifKNO3ce6wHwDH(ZhHMFH(KDqOBf6afAEcTkQKe3ayYufuhSrUcKqj0TcT6cnpHUEjy9AcylPsJNO15vNbjXnGTqZx8IZOUAioB0asIBa743rJK6q0y5VbsoLYdQObHpPNrJL)gi5ukpOIg4sEqjPOb29X2dtgvykbKIhcfRGojZLq)BRqhKaf6pFeA1sOvrLK4gaJuqEIElqOBfA1f6pFeA(f6t2bHUvOduO5j0QOssCdGjtvqDWg5kqcLq3k0Ql08e66LG1RjGTKknEIwNxDgKe3a2cnFXloJ6ZpoB0asIBa743rJK6q0yAeSsdYTiATKD5GoPNrdcFspJgtJGvAqUfrRLSlh0j9mAGl5bLKIgy3hBpmzuHPeqkEiuSc6Kmxc9VTcDqcuO)8rOvlHwfvsIBamsb5j6TaHUvOvxO)8rO5xOpzhe6wHoqHMNqRIkjXnaMmvb1bBKRajucDRqRUqZtORxcwVMa2sQ04jADE1zqsCdyl08fV4mQppIZgnGK4gWo(D0iPoen6eM4kaTAa4q93sIJge(KEgn6eM4kaTAa4q93sIJg4sEqjPOb29X2dtgvykbKIhcfRGojZLqpxRqpFHMNqZVqRwcTkQKe3ayYufuhSrUcKqj0TcT6c9Npc9j7Gq)RqRMbk08fV4mQhWIZgnGK4gWo(D0iPoen6eM4kaTAa4q93sIJge(KEgn6eM4kaTAa4q93sIJg4sEqjPOb29X2dtgvykbKIhcfRGojZLqpxRqpFHMNqRIkjXnaMmvb1bBKRajucDRqRUqZtO5EwlREjGClsXdHI9ueAEcn3ZAz1lbKBrkEiuSc6Kmxc9CTcn)cT6bk0Qrj0ZxOvJj01lbRxtaBjvA8eToV6mijUbSfA(eAEc9j7GqpNqRMbgV4fn2GLEJloBCg1JZgnGK4gWo(D0axYdkjfnoQMGJTbUN1YW06K5eRacFrdcFspJgy)LhulfymIxCMGeNnAajXnGD87OHRenwWfni8j9mAOIkjXnGOHkA8GOH6rdvuHsQdrJgsfGCfiHD0axYdkjfnurLK4gaRHubixbsyl0Z1k0bk08eALcuHMWBM6mqLJPt6PqZtOvlHUEjy9AcylPsJNO15vNbjXnGD8IZOMXzJgqsCdyh)oA4krJfCrdcFspJgQOssCdiAOIgpiAOE0qfvOK6q0OHubixbsyhnWL8GssrdvujjUbWAivaYvGe2c9CTcDGcnpHM7zTmQWucifpek22dtHMNqJDFS9WKrfMsaP4HqXkOtYCj0)k0bk08e66LG1RjGTKknEIwNxDgKe3a2XloJAioB0asIBa743rdxjASGlAq4t6z0qfvsIBardv04brd1JgQOcLuhIgwzsde3RYObUKhuskAW9SwgvykbeUHQjGTocBMq3k0CpRLrfMsaHBOAcyD6pADe2mHMNqRwcn3ZAz1Bai3IUMcGf7Pi08eARCQ5qf0jzUe65AfA(fA(f6oLKq)Lqt4t6jJkmLaIBqRJH91j08j0QXeAcFspzuHPeqCdADm4pGFhGozheA(IxCM5hNnAajXnGD87ObHpPNrdmngicFsprd56Igd56qj1HOXQHkyJW7v8IZmpIZgnGK4gWo(D0GWN0ZObMgdeHpPNOHCDrJHCDOK6q0awliXWkEXzcyXzJgqsCdyh)oAq4t6z0atJbIWN0t0qUUObUKhuskAq4tQcqqcDjSe6Ff6GengY1HsQdrdYH4fNjahNnAajXnGD87ObHpPNrdmngicFsprd56Ig4sEqjPOHkQKe3aynKka5kqcBHEUwHoWOXqUousDiA4kqcv8IZmVJZgnGK4gWo(D0GWN0ZObMgdeHpPNOHCDrdCjpOKu0yb3jZPfJ6OLc1f6wHw9OXqUousDiAqD0sH6XloJ6bgNnAajXnGD87ObHpPNrdmngicFsprd56Igd56qj1HOb29X2dZv8IZOU6XzJgqsCdyh)oAq4t6z0atJbIWN0t0qUUObUKhuskAOIkjXnaMvM0aX9QuOBf6aJgd56qj1HOr5hDspJxCg1dsC2ObKe3a2XVJge(KEgnW0yGi8j9enKRlAGl5bLKIgQOssCdGzLjnqCVkf6wHw9OXqUousDiAyLjnqCVkJxCg1vZ4SrdijUbSJFhni8j9mAGPXar4t6jAixx0yixhkPoen6UkOd5fV4fnSYKgiUxLXzJZOEC2ObKe3a2XVJg4sEqjPOb3ZAz4bqfMwNmNyfq4lAq4t6z0GkmLaQlxl5awrdCdjZOH6XlotqIZgni8j9mAqfMsaXnO1fnGK4gWo(D8IZOMXzJge(KEgnOctjG4OQOjiAajXnGD874fV4fnub1s6zCMGeyqcuD1vpahncPkL50kAeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqBURajuMl0fmVEYc2c9Y7GqtVZ70bBHg3q5eSyctcazccT6QTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1)ZhtysaitqOvxTf6aYtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08hK)8XeMeaYee6GO2cDa5PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v)pFmHjbGmbHwnvBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqRguBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cnDcDaVaobGqZV6)5JjmjaKji0QhGvBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqREawTf6aYtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml00j0b8c4eacn)Q)NpMWKaqMGqhKavBHoG8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)Q)NpMWeHjbONNuJpZ88mbCvBHwONTbeAzxXRtOTEj0MdRfKyyzUqxW86jlyl0lVdcn9oVthSfACdLtWIjmjaKji0brTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hK)8XeMeaYeeA1uTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(yctcazcc98vBHoG8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)b5pFmHjbGmbHoGP2cDa5PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(dYF(ycteMeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqBo5G5cDbZRNSGTqV8oi0078oDWwOXnuoblMWKaqMGqRUAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QR2cDa5PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v)pFmHjbGmbHoiQTqhqEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHM)G8NpMWKaqMGqRMQTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)G8NpMWKaqMGqRMQTqhqEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1)ZhtysaitqOvdQTqhqEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1)ZhtysaitqONVAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYee65HAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYee6aMAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYee6aSAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYee65TAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QhOAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QRMQTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)G8NpMWKaqMGqREawTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(yctcazccT6by1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZV6)5JjmjaKji0bjiQTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHMF1)ZhtysaitqOdsquBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqhe1uTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(yctcazccDqut1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZV6)5Jjmrysa65j14Zmpptax1wOf6zBaHw2v86eARxcT5LF0j90CHUG51twWwOxEheA6DENoyl04gkNGftysaitqOvxTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(yctcazccDquBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqRguBHoG8ufuhSfAZpAa5XcQ5c95cT5hnG8ybLbjXnGT5cn)Q)NpMWKaqMGqpF1wOdipvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZV6)5JjmjaKji0ZB1wOdipvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZV6)5JjmjaKji0bjq1wOdipvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZV6)5JjmjaKji0brnO2cDa5PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v)pFmHjbGmbHoiZxTf6aYtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R(F(ycteMeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqB(gS0BCMl0fmVEYc2c9Y7GqtVZ70bBHg3q5eSyctcazccDquBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cnDcDaVaobGqZV6)5JjmjaKji0QPAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxOPtOd4fWjaeA(v)pFmHjbGmbHwnO2cDa5PkOoyl0gYEaj0RGZJ(l0b8vOpxOdGhj0BPk5s6Pq7kqrNxcn)FXNqZV6)5Jjmrysa65j14Zmpptax1wOf6zBaHw2v86eARxcT5kfG9ohDMl0fmVEYc2c9Y7GqtVZ70bBHg3q5eSyctcazccDquBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqRMQTqhqEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMF1)ZhtysaitqOvF(QTqhqEQcQd2cT51lbRxtalOMl0Nl0MxVeSEnbSGYGK4gW2CHMoHoGxaNaqO5x9)8XeMeaYeeA1dyQTqhqEQcQd2cT5yp3p5XcQ5c95cT5yp3p5XckdsIBaBZfA(v)pFmHjbGmbHoiZxTf6aYtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml00j0b8c4eacn)Q)NpMWKaqMGqhK5HAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxOPtOd4fWjaeA(v)pFmHjbGmbHwnduTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08hK)8XeMeaYeeA1mq1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZV6)5JjmjaKji0Qb1GAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxOPtOd4fWjaeA(v)pFmHjbGmbHwnmF1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqtNqhWlGtai08R(F(ycteMeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqBo29X2dZL5cDbZRNSGTqV8oi0078oDWwOXnuoblMWKaqMGqRUAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QR2cDa5PkOoyl0MxVeSEnbSGAUqFUqBE9sW61eWckdsIBaBZfA(v)pFmHjbGmbHoiQTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)G8NpMWKaqMGqhe1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZV6)5JjmjaKji0QPAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QPAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYeeA1GAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYee65HAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0by1wOdipvb1bBH28JgqESGAUqFUqB(rdipwqzqsCdyBUqZFq(ZhtysaitqON3QTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)G8NpMWKaqMGqRU6QTqhqEQcQd2cT5hnG8yb1CH(CH28JgqESGYGK4gW2CHM)G8NpMWKaqMGqRUAqTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(yctcazccT6ZxTf6aYtvqDWwOn)ObKhlOMl0Nl0MF0aYJfugKe3a2Ml08R(F(ycteMeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqB(QHkyJW7L5cDbZRNSGTqV8oi0078oDWwOXnuoblMWKaqMGqRUAl0bKNQG6GTqB(rdipwqnxOpxOn)ObKhlOmijUbSnxO5pi)5JjmjaKji0QPAl0bKNQG6GTqBE9sW61eWcQ5c95cT51lbRxtalOmijUbSnxO5x9)8XeMeaYeeA1vt1wOdipvb1bBH286LG1RjGfuZf6ZfAZRxcwVMawqzqsCdyBUqZV6)5JjmjaKji0QRguBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqR(8vBHoG8ufuhSfAZRxcwVMawqnxOpxOnVEjy9AcybLbjXnGT5cn)Q)NpMWKaqMGqREatTf6aYtvqDWwOnVEjy9Acyb1CH(CH286LG1RjGfugKe3a2Ml08R(F(ycteMeGEEsn(mZZZeWvTfAHE2gqOLDfVoH26LqBo1rlfQBUqxW86jlyl0lVdcn9oVthSfACdLtWIjmjaKji0QR2cDa5PkOoyl0MF0aYJfuZf6ZfAZpAa5XckdsIBaBZfA(v)pFmHjctMN7kEDWwOvxDHMWN0tHEix3IjmjAOuUvoGOraIqhWpAce65PctjimjarONXvbDoOe6GOMMk0bjWGeOWeHjbicTACO7QaHwfvsIBamQJwkuxOLPqBjvEj0UvOxWDYCAXOoAPqDHMFCdGntOd2FLqVuaSq7kN0ZfFmHjbicDakLnDWwOL5bvsdHUHY9qMtcTBfAvujjUbWAivaYvGe2c95cnhi0Ql0Hnqk0l4ozoTyuhTuOUq3k0QZeMeGi0bOwGqFbRiX0qOnK9asOBOCpK5Kq7wHg3qzcdHwMhu1t5KEk0YCDaTfA3k0MJPeddeHpPNMZeMimHWN0ZftPaS35ORvfvsIBaMMuhAvkq5ngiqLBQR0wWcot3GLEJRnqHje(KEUykfG9ohD)0(LkQKe3amnPo0QuGYBmqGk3uxPDbNPQOXdAv3uPTvfvsIBamLcuEJbcu5TbYREjy9AcylPsJNO15vNhHpPkabj0LW63GimHWN0ZftPaS35O7N2VurLK4gGPj1HwLcuEJbcu5M6kTl4mvfnEqR6MkTTQOssCdGPuGYBmqGkVnqE1lbRxtaBjvA8eToV68WUkiP8yjGlF41MhHpPkabj0LW6x1fMq4t65IPua27C09t7xQOssCdW0K6qRsbkVXabQCtDL2fCMQIgpOnqtL2wvujjUbWukq5ngiqL3gOWecFspxmLcWENJUFA)sfvsIBaMMuhABivaYvGe2M6kTl4mvfnEqBGcti8j9CXuka7Do6(P9lvujjUbyAsDOTHubixbsyBQR0UGZuv04bTQBQ02QIkjXnawdPcqUcKWUnqEe(KQaeKqxcRFdIWecFspxmLcWENJUFA)sfvsIBaMMuhABivaYvGe2M6kTl4mvfnEqR6MkTTQOssCdG1qQaKRajSBdKNkQKe3aykfO8gdeOYBvxycHpPNlMsbyVZr3pTFPIkjXnattQdTwzsde3RstDL2fCMQIgpOnqHje(KEUykfG9ohD)0(LkQKe3amnPo0wluN(J2WGcgz9cD(1n1vAlybNPBWsVX1oFHje(KEUykfG9ohD)0(LkQKe3amnPo0wluN(J2WGcgz9cvUIPUsBbl4mDdw6nU25lmHWN0ZftPaS35O7N2VurLK4gGPj1H2AH60F0gguWiRxisXuxPTGfCMUbl9gxBqcuycHpPNlMsbyVZr3pTFPIkjXnattQdTKcQt)rByqbJSEHo)6M6kTfSGZ0nyP34AvpqHje(KEUykfG9ohD)0(LkQKe3amnPo0wUcQt)rByqbJSEHo)6M6kTfSGZ0nyP34AdsGcti8j9CXuka7Do6(P9lvujjUbyAsDO98RJ60F0gguWiRxisXuxPTGfCMUbl9gxBGcti8j9CXuka7Do6(P9lvujjUbyAsDO98RJ60F0gguWiRxisXuxPDbNPQOXdAvttL2wvujjUbWo)6Oo9hTHbfmY6fIuAdKx9sW61eW2YfwQmKjvbJWEVt5wycHpPNlMsbyVZr3pTFPIkjXnattQdTNFDuN(J2WGcgz9crkM6kTl4mvfnEqR6Z3uPTvfvsIBaSZVoQt)rByqbJSEHiL2a5HDvqs5Xs5uZHSeimHWN0ZftPaS35O7N2VurLK4gGPj1H2ZVoQt)rByqbJSEHiftDL2fCMQIgpOv95BQ02QIkjXna25xh1P)OnmOGrwVqKsBG8WEUFYJrfMsaPu(wofmpcFsvacsOlH1CQPWecFspxmLcWENJUFA)sfvsIBaMMuhAp)6Oo9hTHbfmY6fIum1vAxWzQkA8Gw1mqtL2wvujjUbWo)6Oo9hTHbfmY6fIuAdKhSwqIbMk5s6jYTifOSa(KEY6Y0lHje(KEUykfG9ohD)0(LkQKe3amnPo0E(1rD6pAddkyK1lePyQR0UGZuv04bTZ3uPTvfvsIBaSZVoQt)rByqbJSEHiL2afMq4t65IPua27C09t7xQOssCdW0K6q75xh1P)OnmOGrwVqLRyQR0wWcot3GLEJRnibkmHWN0ZftPaS35O7N2VurLK4gGPj1HwoQkAcqDkjKc(m1vAlybNPBWsVX1gOWecFspxmLcWENJUFA)sfvsIBaMMuhA5OQOja1PKqk4ZuxPDbNPQOXdA5FEeOAu83P1bvWiv04bQXupWa5JptL2wvujjUbW4OQOja1PKqk4RnqEyxfKuESuo1Cilbcti8j9CXuka7Do6(P9lvujjUbyAsDOLJQIMauNscPGptDL2fCMQIgpOL)aCGQrXFNwhubJurJhOgt9adKp(mvABvrLK4gaJJQIMauNscPGV2afMq4t65IPua27C09t7xQOssCdW0K6qlPG6Yu2FDuNscPGptDL2cwWz6gS0BCTbkmHWN0ZftPaS35O7N2VurLK4gGPj1Hwsb1LPS)6OoLesbFM6kTl4mvfnEq78d0uPTvfvsIBamsb1LPS)6OoLesbFTbYREjy9AcyB5clvgYKQGryV3PClmHWN0ZftPaS35O7N2VurLK4gGPj1Hwsb1LPS)6OoLesbFM6kTl4mvfnEq78d0uPTvfvsIBamsb1LPS)6OoLesbFTbYREjy9AcytLCncgjXs8aeMq4t65IPua27C09t7xQOssCdW0K6qlPG6Yu2FDuNscPGptDL2fCMQIgpOv95BQ02QIkjXnagPG6Yu2FDuNscPGV2afMq4t65IPua27C09t7xQOssCdW0K6q75xh1P)iCdvtWYuxPTGfCMUbl9gxBqeMq4t65IPua27C09t7xQOssCdW0K6qRmvb1bBKRajuM6kTfSGZ0nyP34AduycHpPNlMsbyVZr3pTFPIkjXnattQdTYufuhSrUcKqzQR0UGZuv04bTQBQ02QIkjXnaMmvb1bBKRajuTbY7ObKhREjGClsXdHIh)hnG8yuHPeqaUX)8rTWUkiP8yMfCjPKpE8RwyxfKuESeWLp8A)5dHpPkabj0LWQv9pFQxcwVMa2sQ04jADE15tycHpPNlMsbyVZr3pTFPIkjXnattQdTYufuhSrUcKqzQR0UGZuv04bTbAQ02QIkjXnaMmvb1bBKRajuTbkmHWN0ZftPaS35O7N2VurLK4gGPj1Hwsb5j6TatDL2fCMQIgpOfMxpPIcSzDctCfGwnaCO(BjXF(aZRNurb2SPbTL051cXr7j4ZhyE9KkkWMnnOTKoVwOoSPXq65NpW86jvuGnBtLzD3t0gWMHuExblmKy4ZhyE9KkkWMjZfUEhXna086r596OnOsIHpFG51tQOaB2YFJbCNmNq1Jl4pFG51tQOaB26LCd33iQdxtWR7ZhyE9KkkWMfsMbjulKT8C)5dmVEsffyZSdQdi3I4O7gGWecFspxmLcWENJUFA)sfvsIBaMMuhAjhqNFDuN(JWnunbltDL2cwWz6gS0BCTbrycHpPNlMsbyVZr3pTFPIkjXnattQdTnKka5kqcBtDL2fCMQIgpOvDtL2wvujjUbWAivaYvGe2TbYBb3jZPfJ6OLc1BvxycHpPNlMsbyVZr3pTFPIkjXnattQdTGkhPGptDL2cwWz6gS0BCTQpFHje(KEUykfG9ohD)0(LDqlZeMq4t65IPua27C09t7xw33cti8j9CXuka7Do6(P9l6n1H8Ot6PWecFspxmLcWENJUFA)IkmLaYsD5qsLWecFspxmLcWENJUFA)IkmLasMhmga(eMq4t65IPua27C09t7xypvJ(vaQtjHMGUWecFspxmLcWENJUFA)ALKYQXp06OBjmHWN0ZftPaS35O7N2V6YQ8cj70eimHWN0ZftPaS35O7N2VSLVooFCMkTTQLkQKe3aykfO8gdeOYBvNx9sW61eW2YfwQmKjvbJWEVt5wycHpPNlMsbyVZr3pTFrfMsaXnO1zQ02QwQOssCdGPuGYBmqGkVvDEQv9sW61eW2YfwQmKjvbJWEVt5wycHpPNlMsbyVZr3pTFbQCmDspnvABvrLK4gatPaL3yGavER6cteMq4t656N2VW(lpOwkWyyQ02EunbhBdCpRLHP1jZjwbe(eMq4t656N2VurLK4gGPj1H2gsfGCfiHTPUs7cotvrJh0QUPsBRkQKe3aynKka5kqc75AdKNsbQqt4ntDgOYX0j9KNAvVeSEnbSLuPXt068QlmHWN0Z1pTFPIkjXnattQdTnKka5kqcBtDL2fCMQIgpOvDtL2wvujjUbWAivaYvGe2Z1gipUN1YOctjGu8qOyBpm5HDFS9WKrfMsaP4HqXkOtYC9BG8QxcwVMa2sQ04jADE1fMq4t656N2VurLK4gGPj1HwRmPbI7vPPUs7cotvrJh0QUPsBl3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mEQf3ZAz1Bai3IUMcGf7PWZkNAoubDsMR5A5N)oLuaFj8j9KrfMsaXnO1XW(64tngHpPNmQWuciUbTog8hWVdqNSd8jmHWN0Z1pTFHPXar4t6jAixNPj1H2vdvWgH3lHje(KEU(P9lmngicFsprd56mnPo0cRfKyyjmHWN0Z1pTFHPXar4t6jAixNPj1HwYbtL2wcFsvacsOlH1VbrycHpPNRFA)ctJbIWN0t0qUottQdTUcKqzQ02QIkjXnawdPcqUcKWEU2afMq4t656N2VW0yGi8j9enKRZ0K6ql1rlfQBQ02UG7K50IrD0sH6TQlmHWN0Z1pTFHPXar4t6jAixNPj1HwS7JThMlHje(KEU(P9lmngicFsprd56mnPo0w(rN0ttL2wvujjUbWSYKgiUxLTbkmHWN0Z1pTFHPXar4t6jAixNPj1HwRmPbI7vPPsBRkQKe3aywzsde3RYw1fMq4t656N2VW0yGi8j9enKRZ0K6qB3vbDipHjctcqeAcFspxmQJwkuVftjggicFspnvABj8j9KbQCmDspz4gktyiZjEDkjMc((TDEpFHje(KEUyuhTuO(pTFbQCmDspnvAB7usmf8nxRkQKe3ayGkhPGpE8JDFS9WKD(d3GCl6AauNMKSc6KmxZ1s4t6jdu5y6KEYG)a(Da6KD4ZhS7JThMmQWucifpekwbDsMR5Aj8j9KbQCmDspzWFa)oaDYo85d)hnG8y1lbKBrkEiu8WUp2EyYQxci3Iu8qOyf0jzUMRLWN0tgOYX0j9Kb)b87a0j7aF8XJ7zTS6LaYTifpek22dtECpRLrfMsaP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThMcti8j9CXOoAPq9FA)Ad01W5vcMkTTy3hBpmzuHPeqkEiuSc6KmxTbYJFUN1YQxci3Iu8qOyBpm5Xp29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayKcQt)rByqbJSEHo)6F(GDFS9WKD(d3GCl6AauNMKSc6KmxTbYhFcti8j9CXOoAPq9FA)QlRYRfYTOZRoKNPsBl29X2dtgvykbKIhcfRGojZvBG84N7zTS6LaYTifpek22dtE8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZV(Npy3hBpmzN)Wni3IUga1PjjRGojZvBG8XNWecFspxmQJwku)N2VkAlP8qlfQmtycHpPNlg1rlfQ)t7xRgP9K5esXdHYuPTL7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThMcti8j9CXOoAPq9FA)QEjGClsXdHYuPTL7zTS6LaYTifpek22dtEy3hBpmzuHPeqkEiuSc6Kmx)gOWecFspxmQJwku)N2Vo)HBqUfDnaQttstL2w(XUp2EyYOctjGu8qOyf0jzUAdKh3ZAz1lbKBrkEiuSThM895JsbQqt4ntDw9sa5wKIhcLWecFspxmQJwku)N2Vo)HBqUfDnaQttstL2wS7JThMmQWucifpekwbDsMR5MFG84EwlREjGClsXdHIT9WKhSwqIbMk5s6jYTifOSa(KEYGK4gWwycHpPNlg1rlfQ)t7xuHPeqkEiuMkTTCpRLvVeqUfP4HqX2EyYd7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDHje(KEUyuhTuO(pTFrfMsaXrvrtGPsBl3ZAzuHPeqkEiuSNcpUN1YOctjGu8qOyf0jzUMRLWN0tgvykbuxUwYbSyWFa)oaDYoWJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBMWecFspxmQJwku)N2VOctjG8IZuPTL7zTmQWuciCdvtaBDe2S54EwlJkmLac3q1eW60F06iSz84EwlREjGClsXdHIT9WKh3ZAzuHPeqkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxmQJwku)N2VOctjG4OQOjWuPTL7zTS6LaYTifpek22dtECpRLrfMsaP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThM84EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMjmHWN0ZfJ6OLc1)P9lQWucOUCTKdyzQ02Y9SwgEauHP1jZjwbe(mf3qYSvDtbQgbJWnKmrsBl3ZAz4bqfMwNmNq4gktyW2EyYJFUN1YOctjGu8qOypLpF4EwlREjGClsXdHI9u(8b7(y7Hjdu5y6KEYkG2bZNWecFspxmQJwku)N2VOctjG6Y1soGLPsBRArQrGsEaJkmLas517WqMtmijUbS)8H7zTm8aOctRtMtiCdLjmyBpmnf3qYSvDtbQgbJWnKmrsBl3ZAz4bqfMwNmNq4gktyW2EyYJFUN1YOctjGu8qOypLpF4EwlREjGClsXdHI9u(8b7(y7Hjdu5y6KEYkG2bZNWecFspxmQJwku)N2VavoMoPNMkTTCpRLvVeqUfP4HqX2EyYJ7zTmQWucifpek22dtEBG7zTSZF4gKBrxdG60KKT9WuycHpPNlg1rlfQ)t7xuHPeqEXzQ02Y9SwgvykbeUHQjGTocB2CCpRLrfMsaHBOAcyD6pADe2mHje(KEUyuhTuO(pTFrfMsaXrvrtGWecFspxmQJwku)N2VOctjG4g06eMimHWN0ZfJCO1w(648XzQ02wVeSEnbSTCHLkdzsvWiS37uU5HDFS9WKX9Sw0wUWsLHmPkye27Dk3ScODW84EwlBlxyPYqMufmc79oLBKT81X2EyYJFUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EyYhpS7JThMSZF4gKBrxdG60KKvqNK5QnqE8Z9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw84N)JgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif((8HF16ObKhREjGClsXdHIh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePW3Npy3hBpmzuHPeqkEiuSc6KmxZ1oH38XNWecFspxmYHFA)YklaXnO1zQ02YF9sW61eW2YfwQmKjvbJWEVt5Mh29X2dtg3ZArB5clvgYKQGryV3PCZkG2bZJ7zTSTCHLkdzsvWiS37uUrwzbSThM8ukqfAcVzQZSLVooFC895d)1lbRxtaBlxyPYqMufmc79oLBENSdTbYNWecFspxmYHFA)Yw(6qPRImvABRxcwVMa2ujxJGrsSepaEy3hBpmzuHPeqkEiuSc6Kmx)QMbYd7(y7Hj78hUb5w01aOonjzf0jzUAdKh)CpRLrfMsaHBOAcyRJWMnxRkQKe3ayKdOZVoQt)r4gQMGfp(5)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTt4npS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisHVpF4xToAa5XQxci3Iu8qO4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crk895d29X2dtgvykbKIhcfRGojZ1CTt4nF8jmHWN0ZfJC4N2VSLVou6QitL226LG1RjGnvY1iyKelXdGh29X2dtgvykbKIhcfRGojZvBG84NF(XUp2EyYo)HBqUfDnaQttswbDsMRFvrLK4gaJuqD6pAddkyK1l05xNh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2m((8HFS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWMnxRkQKe3ayKdOZVoQt)r4gQMGfF8XJ7zTS6LaYTifpek22dt(eMq4t65Iro8t7xN)Wni3IUga1PjPPsBB9sW61eWwsLgprRZRopLcuHMWBM6mqLJPt6PWecFspxmYHFA)IkmLasXdHYuPTTEjy9AcylPsJNO15vNh)kfOcnH3m1zGkhtN0ZpFukqfAcVzQZo)HBqUfDnaQtts(eMq4t65Iro8t7xGkhtN0ttL22t2HFvZa5vVeSEnbSLuPXt068QZJ7zTmQWuciCdvtaBDe2S5AvrLK4gaJCaD(1rD6pc3q1eS4HDFS9WKD(d3GCl6AauNMKSc6KmxTbYd7(y7HjJkmLasXdHIvqNK5AU2j8wycHpPNlg5WpTFbQCmDspnvABpzh(vndKx9sW61eWwsLgprRZRopS7JThMmQWucifpekwbDsMR2a5Xp)8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZVopUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz895d)y3hBpmzN)Wni3IUga1PjjRGojZvBG84EwlJkmLac3q1eWwhHnBUwvujjUbWihqNFDuN(JWnunbl(4Jh3ZAz1lbKBrkEiuSThM8zQmpOQNYHK2wUN1YwsLgprRZRoBDe2SwUN1YwsLgprRZRoRt)rRJWMzQmpOQNYHK9oSL0bTQlmHWN0ZfJC4N2V6YQ8AHCl68Qd5zQ02Yp29X2dtgvykbKIhcfRGojZ1VQH5)5d29X2dtgvykbKIhcfRGojZ1CTQjF8WUp2EyYo)HBqUfDnaQttswbDsMR2a5Xp3ZAzuHPeq4gQMa26iSzZ1QIkjXnag5a68RJ60FeUHQjyXJF(pAa5XQxci3Iu8qO4HDFS9WKvVeqUfP4HqXkOtYCnx7eEZd7(y7HjJkmLasXdHIvqNK5635Z3Np8RwhnG8y1lbKBrkEiu8WUp2EyYOctjGu8qOyf0jzU(D(895d29X2dtgvykbKIhcfRGojZ1CTt4nF8jmHWN0ZfJC4N2VkAlP8qlfQmZuPTf7(y7Hj78hUb5w01aOonjzf0jzUMd(d43bOt2bE8Z9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw84N)JgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif((8HF16ObKhREjGClsXdHIh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePW3Npy3hBpmzuHPeqkEiuSc6KmxZ1oH38XNWecFspxmYHFA)QOTKYdTuOYmtL2wS7JThMmQWucifpekwbDsMR5G)a(Da6KDGh)8Zp29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayKcQt)rByqbJSEHo)684EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S5AvrLK4gaJCaD(1rD6pc3q1eS4JpECpRLvVeqUfP4HqX2EyYNWecFspxmYHFA)Ad01W5vcMkTTy3hBpmzuHPeqkEiuSc6KmxTbYJF(5h7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw8XhpUN1YQxci3Iu8qOyBpm5tycHpPNlg5WpTFD(d3GCl6AauNMKMkTTCpRLrfMsaHBOAcyRJWMnxRkQKe3ayKdOZVoQt)r4gQMGfp(5)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTt4npS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisHVpF4xToAa5XQxci3Iu8qO4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crk895d29X2dtgvykbKIhcfRGojZ1CTt4nFcti8j9CXih(P9lQWucifpektL2w(5h7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBamsb1P)OnmOGrwVqNFDECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGroGo)6Oo9hHBOAcw8XhpUN1YQxci3Iu8qOyBpmfMq4t65Iro8t7x1lbKBrkEiuMkTTCpRLvVeqUfP4HqX2EyYJF(XUp2EyYo)HBqUfDnaQttswbDsMRFdsG84EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S5AvrLK4gaJCaD(1rD6pc3q1eS4JpE8JDFS9WKrfMsaP4HqXkOtYC9R6Z)ZNnW9Sw25pCdYTORbqDAsYEk8jmHWN0ZfJC4N2Vwns7jZjKIhcLPsBl3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMq4t65Iro8t7xkfSGedi3I6YCBQ02Y9Sw2gORHZReypfEBG7zTSZF4gKBrxdG60KK9u4TbUN1Yo)HBqUfDnaQttswbDsMR5A5EwltPGfKya5wuxMBwN(JwhHntngHpPNmQWuciUbTog8hWVdqNSdcti8j9CXih(P9lQWuciUbTotL2wUN1Y2aDnCELa7PWJF(pAa5Xky5jLyGhHpPkabj0LWAo1aFF(q4tQcqqcDjSMB(8XJF1QEjy9AcyuHPeqCENJQDhY7ZNJQj4ynanUgMc((vnNpFcti8j9CXih(P9R1tbQ0vrcti8j9CXih(P9lQWuciV4mvAB5EwlJkmLac3q1eWwhHnRnqHje(KEUyKd)0(vcxduOd6kW6mvAB5VaBbRgIBaF(OwNeBMmN4Jh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mHje(KEUyKd)0(fvykbuxUwYbSmvAB5EwldpaQW06K5eRacF8QxcwVMagvykbKmTYuEbZ7ObKhJ6kdPvIPt6jpcFsvacsOlH1CbyHje(KEUyKd)0(fvykbuxUwYbSmvAB5EwldpaQW06K5eRacF84VEjy9AcyuHPeqY0kt5f8NphnG8yuxziTsmDsp5JhHpPkabj0LWAU5lmHWN0ZfJC4N2VOctjGG)kdFj90uPTL7zTmQWuciCdvtaBDe2S54EwlJkmLac3q1eW60F06iSzcti8j9CXih(P9lQWuci4VYWxspnvAB5EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMXtPavOj8MPoJkmLaIJQIMaHje(KEUyKd)0(fvykbehvfnbMkTTCpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZeMq4t65Iro8t7xGkhtN0ttL5bv9uoK022PKyk4732a88nvMhu1t5qYEh2s6Gw1fMimjarOd4Fj9sEs1iGq)wYCsONk5AeSqlXs8ae6q51i0KctOdqTaHwEcDO8Ae6ZVUq7xduHYfWeMq4t65IHDFS9WC1AlFDO0vrMkTT1lbRxtaBQKRrWijwIhapS7JThMmQWucifpekwbDsMRFvZa5HDFS9WKD(d3GCl6AauNMKSc6KmxTbYJFUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGfp(5)ObKhREjGClsXdHIh29X2dtw9sa5wKIhcfRGojZ1CTt4npS7JThMmQWucifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxisHVpF4xToAa5XQxci3Iu8qO4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crk895d29X2dtgvykbKIhcfRGojZ1CTt4nF8jmHWN0Zfd7(y7H56N2VSLVou6QitL226LG1RjGnvY1iyKelXdGh29X2dtgvykbKIhcfRGojZvBG84xToAa5XGCiNAoiH9Np8F0aYJb5qo1CqcBEDkjMc((TnGfiF8XJF(XUp2EyYo)HBqUfDnaQttswbDsMRFvpqECpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocBwBG8XhpUN1YQxci3Iu8qOyBpm51PKyk473wvujjUbWifuxMY(RJ6usif8jmHWN0Zfd7(y7H56N2VSLVooFCMkTT1lbRxtaBlxyPYqMufmc79oLBEy3hBpmzCpRfTLlSuzitQcgH9ENYnRaAhmpUN1Y2YfwQmKjvbJWEVt5gzlFDSThM84N7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThM8Xd7(y7Hj78hUb5w01aOonjzf0jzUAdKh)CpRLrfMsaHBOAcyRJWMnxRkQKe3ayNFDuN(JWnunblE8Z)rdipw9sa5wKIhcfpS7JThMS6LaYTifpekwbDsMR5ANWBEy3hBpmzuHPeqkEiuSc6Kmx)QIkjXna25xh1P)OnmOGrwVqKcFF(WVAD0aYJvVeqUfP4HqXd7(y7HjJkmLasXdHIvqNK56xvujjUbWo)6Oo9hTHbfmY6fIu47ZhS7JThMmQWucifpekwbDsMR5ANWB(4tycHpPNlg29X2dZ1pTFzLfG4g06mvABRxcwVMa2wUWsLHmPkye27Dk38WUp2EyY4EwlAlxyPYqMufmc79oLBwb0oyECpRLTLlSuzitQcgH9ENYnYklGT9WKNsbQqt4ntDMT81X5JtysaIqppncPGxc9BbcDxwLxlHouEncnPWe65zRqF(1fA5sOlG2bl00sOdHXWuHUtMbc96vGqFUqJP1j0YtO5aRxGqF(1zcti8j9CXWUp2EyU(P9RUSkVwi3IoV6qEMkTTy3hBpmzN)Wni3IUga1PjjRGojZvBG84EwlJkmLac3q1eWwhHnBUwvujjUbWo)6Oo9hHBOAcw8WUp2EyYOctjGu8qOyf0jzUMRDcVfMq4t65IHDFS9WC9t7xDzvETqUfDE1H8mvABXUp2EyYOctjGu8qOyf0jzUAdKh)Q1rdipgKd5uZbjS)8H)JgqEmihYPMdsyZRtjXuW3VTbSa5JpE8Zp29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayKcQt)rByqbJSEHo)684EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMX3Np8JDFS9WKD(d3GCl6AauNMKSc6KmxTbYJ7zTmQWuciCdvtaBDe2S2a5JpECpRLvVeqUfP4HqX2EyYRtjXuW3VTQOssCdGrkOUmL9xh1PKqk4tysaIqppncPGxc9Bbc9gORHZRee6q51i0KctONNTc95xxOLlHUaAhSqtlHoegdtf6ozgi0Rxbc95cnMwNqlpHMdSEbc95xNjmHWN0Zfd7(y7H56N2V2aDnCELGPsBl29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGfpS7JThMmQWucifpekwbDsMR5ANWBHje(KEUyy3hBpmx)0(1gORHZRemvABXUp2EyYOctjGu8qOyf0jzUAdKh)Q1rdipgKd5uZbjS)8H)JgqEmihYPMdsyZRtjXuW3VTbSa5JpE8Zp29X2dt25pCdYTORbqDAsYkOtYC9R6bYJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgFF(Wp29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZAdKp(4X9Sww9sa5wKIhcfB7HjVoLetbF)2QIkjXnagPG6Yu2FDuNscPGpHjbicDaQfi0lfQmtOLwH(8Rl0uUfAsrOPceApfA8wOPCl0HEA(j0CGq)ueARxc9WZjOe6RHsH(AaHUt)f6nmOGnvO7KzYCsOxVce6qqOBivGqtNqpaADc9f6cnvykbHg3q1eSeAk3c91qNqF(1f6qALMFcTA0V1j0VfSzcti8j9CXWUp2EyU(P9RI2skp0sHkZmvABXUp2EyYo)HBqUfDnaQttswbDsMRFvrLK4gaRwOo9hTHbfmY6f68RZd7(y7HjJkmLasXdHIvqNK56xvujjUbWQfQt)rByqbJSEHifE8F0aYJvVeqUfP4HqXJFS7JThMS6LaYTifpekwbDsMR5G)a(Da6KD4ZhS7JThMS6LaYTifpekwbDsMRFvrLK4gaRwOo9hTHbfmY6fQCf((8rToAa5XQxci3Iu8qO4Jh3ZAzuHPeq4gQMa26iSz)geEBG7zTSZF4gKBrxdG60KKT9WKh3ZAz1lbKBrkEiuSThM84EwlJkmLasXdHIT9WuysaIqhGAbc9sHkZe6q51i0KIqh2aPqR4RLKBamHEE2k0NFDHwUe6cODWcnTe6qymmvO7KzGqVEfi0Nl0yADcT8eAoW6fi0NFDMWecFspxmS7JThMRFA)QOTKYdTuOYmtL2wS7JThMSZF4gKBrxdG60KKvqNK5Ao4pGFhGozh4X9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnh)WFa)oaDYo8dHpPNSZF4gKBrxdG60KKb)b87a0j7aFcti8j9CXWUp2EyU(P9RI2skp0sHkZmvABXUp2EyYOctjGu8qOyf0jzUMd(d43bOt2bE8ZVAD0aYJb5qo1Cqc7pF4)ObKhdYHCQ5Ge286usmf89BBalq(4Jh)8JDFS9WKD(d3GCl6AauNMKSc6Kmx)QIkjXnagPG60F0gguWiRxOZVopUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz895d)y3hBpmzN)Wni3IUga1PjjRGojZvBG84EwlJkmLac3q1eWwhHnRnq(4Jh3ZAz1lbKBrkEiuSThM86usmf89BRkQKe3ayKcQltz)1rDkjKc(4tycHpPNlg29X2dZ1pTFD(d3GCl6AauNMKMkTTy3hBpmzuHPeqkEiuSc6KmxZn)a5bRfKyGPsUKEIClsbklGpPNSUm9sysaIqhGAbc95xxOdLxJqtkcT0k0YZ8LqhkVgzk0xdi0D6VqVHbfmtONNTcD6NPc9BbcDO8Ae6YveAPvOVgqOpAa5j0YLqFKzqAQqt5wOLN5lHouEnYuOVgqO70FHEddkyMWecFspxmS7JThMRFA)68hUb5w01aOonjnvAB5EwlJkmLac3q1eWwhHnBUwvujjUbWo)6Oo9hHBOAcw8WUp2EyYOctjGu8qOyf0jzUMRf(d43bOt2bHje(KEUyy3hBpmx)0(15pCdYTORbqDAsAQ02Y9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4D0aYJvVeqUfP4HqXd7(y7HjREjGClsXdHIvqNK5AUw4pGFhGozh4HDFS9WKrfMsaP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9crkcti8j9CXWUp2EyU(P9RZF4gKBrxdG60K0uPTL7zTmQWuciCdvtaBDe2S5AvrLK4ga78RJ60FeUHQjyXJF16ObKhREjGClsXdH6ZhS7JThMS6LaYTifpekwbDsMRFvrLK4ga78RJ60F0gguWiRxOYv4Jh29X2dtgvykbKIhcfRGojZ1VQOssCdGD(1rD6pAddkyK1lePimjarOdqTaHMueAPvOp)6cTCj0Ek04Tqt5wOd908tO5aH(Pi0wVe6HNtqj0xdLc91acDN(l0ByqbBQq3jZK5KqVEfi0xdDcDii0nKkqOH0FtncDNssOPCl0xdDc91afi0YLqN(j00OaAhSqtcD9sqODRqR4Hqj0Bpmzcti8j9CXWUp2EyU(P9lQWucifpektL2wS7JThMSZF4gKBrxdG60KKvqNK56xvujjUbWifuN(J2WGcgz9cD(15X9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJh3ZAz1lbKBrkEiuSThM86usmf89BRkQKe3ayKcQltz)1rDkjKc(eMeGi0bOwGqxUIqlTc95xxOLlH2tHgVfAk3cDONMFcnhi0pfH26Lqp8CckH(AOuOVgqO70FHEddkytf6ozMmNe61RaH(AGceA5kn)eAAuaTdwOjHUEji0BpmfAk3c91qNqtkcDONMFcnhG9oi0KksoiUbi07xjZjHUEjWeMq4t65IHDFS9WC9t7x1lbKBrkEiuMkTTCpRLrfMsaP4HqX2EyYd7(y7Hj78hUb5w01aOonjzf0jzU(vfvsIBaSYvqD6pAddkyK1l05xNh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mE8JDFS9WKrfMsaP4HqXkOtYC9R6Z)ZNnW9Sw25pCdYTORbqDAsYEk8jmHWN0Zfd7(y7H56N2Vwns7jZjKIhcLPsBl3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmfMeGi0b8j4ssPAl0QXneA5sO7uscDZlNQGfAk3c9803QHLqtfi0N7cn8xbYLufi0Nl0Vfi0kExOpxOxZRhaQraHMsHg(Ffj0eNqltH(AaH(8Rl0HYC7HmHoaGZ8Lq)wGqlpH(CHUtMbc9WdfACdvtGqpp99sOL56O8ycti8j9CXWUp2EyU(P9lLcwqIbKBrDzUnvAB5EwlJkmLac3q1eWwhHnRnqEyxfKuEmZcUKukmjarONXt1Oc4tWLKs1wOdqTaHwX7c95c9AE9aqnci0uk0W)RiHM4eAzk0xdi0NFDHouMBpKjmHWN0Zfd7(y7H56N2VukybjgqUf1L52uPTDdCpRLD(d3GCl6AauNMKSNcVnW9Sw25pCdYTORbqDAsYkOtYCnhHpPNmQWucOUCTKdyXG)a(Da6KDGNAHDvqs5Xml4ssPWeHje(KEUyWAbjgwTCd33i3IUgabj0d2uPTf7(y7Hj78hUb5w01aOonjzf0jzUAdKh3ZAzuHPeq4gQMa26iSzZ1QIkjXna25xh1P)iCdvtWIh29X2dtgvykbKIhcfRGojZ1CTt49Npw5uZHkOtYCnh29X2dtgvykbKIhcfRGojZLWecFspxmyTGedRFA)IB4(g5w01aiiHEWMkTTy3hBpmzuHPeqkEiuSc6KmxTbYJF16ObKhdYHCQ5Ge2F(W)rdipgKd5uZbjS51PKyk4732awGF(OIkjXnag1rlfQ3QoF8XJF(XUp2EyYo)HBqUfDnaQttswbDsMRFvrLK4gaJuqD6pAddkyK1l05xNh)CpRLrfMsaHBOAcyRJWM1Y9SwgvykbeUHQjG1P)O1ryZ(8rfvsIBamQJwkuVvD(47Zh(XUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocBwBG8XhpUN1YQxci3Iu8qOyBpm51PKyk473wvujjUbWifuxMY(RJ6usif8jmHWN0ZfdwliXW6N2Vc9ASvbYevWYtkXGPsBl29X2dtgvykbKIhcfRGojZ1VTZpqEy3hBpmzN)Wni3IUga1PjjRGojZ1CTt4npUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGfVJgqES6LaYTifpekEy3hBpmz1lbKBrkEiuSc6KmxZ1oH38WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHifHje(KEUyWAbjgw)0(vOxJTkqMOcwEsjgmvABXUp2EyYo)HBqUfDnaQttswbDsMR2a5X9SwgvykbeUHQjGTocB2CTQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnx7eE)5Jvo1COc6KmxZHDFS9WKrfMsaP4HqXkOtYCjmHWN0ZfdwliXW6N2Vc9ASvbYevWYtkXGPsBl29X2dtgvykbKIhcfRGojZvBG84xToAa5XGCiNAoiH9Np8F0aYJb5qo1CqcBEDkjMc((TnGf4NpQOssCdGrD0sH6TQZhF84NFS7JThMSZF4gKBrxdG60KKvqNK56xvujjUbWifuN(J2WGcgz9cD(15Xp3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2SpFurLK4gaJ6OLc1BvNp((8HFS7JThMSZF4gKBrxdG60KKvqNK5QnqECpRLrfMsaHBOAcyRJWM1giF8XJ7zTS6LaYTifpek22dtEDkjMc((TvfvsIBamsb1LPS)6OoLesbFcti8j9CXG1csmS(P9RPhvBjLi3Ii1iq5xJPsBl29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZMRvfvsIBaSZVoQt)r4gQMGfpS7JThMmQWucifpekwbDsMR5ANW7pFSYPMdvqNK5AoS7JThMmQWucifpekwbDsMlHje(KEUyWAbjgw)0(10JQTKsKBrKAeO8RXuPTf7(y7HjJkmLasXdHIvqNK5QnqE8RwhnG8yqoKtnhKW(Zh(pAa5XGCiNAoiHnVoLetbF)2gWc8ZhvujjUbWOoAPq9w15JpE8Zp29X2dt25pCdYTORbqDAsYkOtYC9RkQKe3ayKcQt)rByqbJSEHo)684N7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocB2NpQOssCdGrD0sH6TQZhFF(Wp29X2dt25pCdYTORbqDAsYkOtYC1gipUN1YOctjGWnunbS1ryZAdKp(4X9Sww9sa5wKIhcfB7HjVoLetbF)2QIkjXnagPG6Yu2FDuNscPGpHje(KEUyWAbjgw)0(f2tmKxrhSr2b1bthYeq4D78WuPTL7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThM86usSt2b05Oo9)3w4pGFhGozheMq4t65IbRfKyy9t7xfqkYCczhuhwMkTTCpRLrfMsaP4HqX2EyYJ7zTS6LaYTifpek22dtEBG7zTSZF4gKBrxdG60KKT9WKxNsIDYoGoh1P))2c)b87a0j7GWecFspxmyTGedRFA)Y643c2isncuYdqCa1nvAB5EwlJkmLasXdHIT9WKh3ZAz1lbKBrkEiuSThM82a3ZAzN)Wni3IUga1PjjB7HPWecFspxmyTGedRFA)s5vsBWYCcXnO1zQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHje(KEUyWAbjgw)0(vjvugasMOLcHbtL2wUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EykmHWN0ZfdwliXW6N2VUga9so)LBK1lmyQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHje(KEUyWAbjgw)0(vh6EfmYTOXdl3ODbuFzQ02Y9SwgvykbKIhcfB7HjpUN1YQxci3Iu8qOyBpm5TbUN1Yo)HBqUfDnaQtts22dtHjcti8j9CXSYKgiUxL)0(fvykbuxUwYbSmvAB5EwldpaQW06K5eRacFMIBiz2QUWecFspxmRmPbI7v5pTFrfMsaXnO1jmHWN0ZfZktAG4Ev(t7xuHPeqCuv0eimrycHpPNlw3vbDiVFA)IBitZqugSPsBB3vbDip2wUokXWVTQhOWecFspxSURc6qE)0(LsbliXaYTOUm3cti8j9CX6UkOd59t7xuHPeqD5AjhWYuPTT7QGoKhBlxhLyyo1duycHpPNlw3vbDiVFA)IkmLaYloHje(KEUyDxf0H8(P9lRSae3GwNWeHje(KEUyUcKq1cQCmDspnvAB5VEjy9AcylPsJNO15v)ZN6LG1RjGDqxXlAGcPsHpEhnG8y1lbKBrkEiu8WUp2EyYQxci3Iu8qOyf0jzU(nqE8Z9Sww9sa5wKIhcfB7H5NpkfOcnH3m1zuHPeqCuv0eWNWecFspxmxbsO(P9lRSae3GwNPsBB9sW61eW2YfwQmKjvbJWEVt5Mh3ZAzB5clvgYKQGryV3PCJSLVo2trycHpPNlMRaju)0(LT81HsxfzQ02wVeSEnbSPsUgbJKyjEa86usmf8978E(cti8j9CXCfiH6N2V2aDnCELGPsBRAvVeSEnbSLuPXt068QlmHWN0ZfZvGeQFA)QOTKYdTuOYmtL22oLetbF)QgcuycHpPNlMRaju)0(1QrApzoHu8qOmvABx(BWjZnZkHXg5we3WxlVVyqsCdylmHWN0ZfZvGeQFA)IkmLaYlotL2wvujjUbWKPkOoyJCfiHQvDEy3hBpmz1lbKBrkEiuSc6KmxTbkmHWN0ZfZvGeQFA)IkmLaIBqRZuPTvfvsIBamzQcQd2ixbsOAvNh29X2dtw9sa5wKIhcfRGojZvBG84EwlJkmLac3q1eWwhHnBoUN1YOctjGWnunbSo9hTocBMWecFspxmxbsO(P9R6LaYTifpektL2wvujjUbWKPkOoyJCfiHQvDECpRLvVeqUfP4HqX2EykmHWN0ZfZvGeQFA)Ad01W5vcMkTTCpRLvVeqUfP4HqX2EykmHWN0ZfZvGeQFA)QlRYRfYTOZRoKNPsBl3ZAz1lbKBrkEiuSThMF(OuGk0eEZuNrfMsaXrvrtGWecFspxmxbsO(P9RZF4gKBrxdG60K0uPTL7zTS6LaYTifpek22dZpFukqfAcVzQZOctjG4OQOjqycHpPNlMRaju)0(fvykbKIhcLPsBRsbQqt4ntD25pCdYTORbqDAskmHWN0ZfZvGeQFA)QEjGClsXdHYuPTL7zTS6LaYTifpek22dtHje(KEUyUcKq9t7xkfSGedi3I6YCBQ02UbUN1Yo)HBqUfDnaQtts2tH3g4Ewl78hUb5w01aOonjzf0jzUMJWN0tgvykbuxUwYbSyWFa)oaDYoimHWN0ZfZvGeQFA)IkmLaIBqRZuPTD7hROTKYdTuOYmwbDsMRFN)NpBG7zTSI2skp0sHkZqQEJekItoKxWS1ryZ(nqHje(KEUyUcKq9t7xuHPeqCdADMkTTCpRLPuWcsmGClQlZn7PWBdCpRLD(d3GCl6AauNMKSNcVnW9Sw25pCdYTORbqDAsYkOtYCnxlHpPNmQWuciUbTog8hWVdqNSdcti8j9CXCfiH6N2VOctjG4OQOjWuPTL7zTS6LaYTifpek2tHh29X2dtgvykbKIhcfRaAhmVoLetbFZPgcKh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mEQv9sW61eWwsLgprRZRop1QEjy9Acyh0v8IgOqQueMq4t65I5kqc1pTFrfMsaXrvrtGPsBl3ZAz1lbKBrkEiuSNcpUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfRGojZ1CTt4npUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz8urLK4gatMQG6GnYvGekHje(KEUyUcKq9t7xuHPeqD5AjhWYuPTDdCpRLD(d3GCl6AauNMKSNcVJgqEmQWucia3484N7zTSnqxdNxjW2Ey(5dHpPkabj0LWQvD(4TbUN1Yo)HBqUfDnaQttswbDsMRFj8j9KrfMsa1LRLCalg8hWVdqNSd84xTi1iqjpGrfMsaP86DyiZjgKe3a2F(W9SwgEauHP1jZjeUHYegSThM8zkUHKzR6McuncgHBizIK2wUN1YWdGkmTozoHWnuMWGT9WKh)CpRLrfMsaP4HqXEkF(WVAD0aYJ5QGsXdHc284N7zTS6LaYTifpek2t5ZhS7JThMmqLJPt6jRaAhmF8XNWecFspxmxbsO(P9lQWucOUCTKdyzQ02Y9SwgEauHP1jZjwbe(4HDFS9WKrfMsaP4HqXkOtYCXJFUN1YQxci3Iu8qOypLpF4EwlJkmLasXdHI9u4ZuCdjZw1fMq4t65I5kqc1pTFrfMsa5fNPsBl3ZAzuHPeq4gQMa26iSzZ1QIkjXna25xh1P)iCdvtWIh)y3hBpmzuHPeqkEiuSc6Kmx)QEGF(q4tQcqqcDjSMRni8jmHWN0ZfZvGeQFA)IkmLaIBqRZuPTL7zTS6LaYTifpek2t5ZNoLetbF)Q(8fMq4t65I5kqc1pTFbQCmDspnvAB5EwlREjGClsXdHIT9W0uzEqvpLdjTTDkjMc((TnapFtL5bv9uoKS3HTKoOvDHje(KEUyUcKq9t7xuHPeqCuv0eimrysaIqt4t65Iv(rN0ZFA)ctjggicFspnvABj8j9KbQCmDspz4gktyiZjEDkjMc((TDEpFE8Rw1lbRxtaBjvA8eToV6F(W9Sw2sQ04jADE1zRJWM1Y9Sw2sQ04jADE1zD6pADe2m(eMq4t65Iv(rN0ZFA)cu5y6KEAQ022PKyk4BUwvujjUbWavosbF84h7(y7Hj78hUb5w01aOonjzf0jzUMRLWN0tgOYX0j9Kb)b87a0j7WNpy3hBpmzuHPeqkEiuSc6KmxZ1s4t6jdu5y6KEYG)a(Da6KD4Zh(pAa5XQxci3Iu8qO4HDFS9WKvVeqUfP4HqXkOtYCnxlHpPNmqLJPt6jd(d43bOt2b(4Jh3ZAz1lbKBrkEiuSThM84EwlJkmLasXdHIT9WK3g4Ewl78hUb5w01aOonjzBpmnvMhu1t5qsBBNsIPGVFBN3ZNh)Qv9sW61eWwsLgprRZR(NpCpRLTKknEIwNxD26iSzTCpRLTKknEIwNxDwN(JwhHnJptL5bv9uoKS3HTKoOvDHje(KEUyLF0j98N2VavoMoPNMkTT1lbRxtaBjvA8eToV68WUp2EyYOctjGu8qOyf0jzUMRLWN0tgOYX0j9Kb)b87a0j7GWKaeH(BQkAceAPvOLN5lH(KDqOpxOFlqOp)6cnLBHoee6gsfi0N7cDNYGfACdvtWsycHpPNlw5hDsp)P9lQWucioQkAcmvABXUp2EyYo)HBqUfDnaQttswb0oyE8Z9SwgvykbeUHQjGTocB2VQOssCdGD(1rD6pc3q1eS4HDFS9WKrfMsaP4HqXkOtYCnxl8hWVdqNSd8jmHWN0ZfR8JoPN)0(fvykbehvfnbMkTTy3hBpmzN)Wni3IUga1PjjRaAhmp(5EwlJkmLac3q1eWwhHn7xvujjUbWo)6Oo9hHBOAcw8oAa5XQxci3Iu8qO4HDFS9WKvVeqUfP4HqXkOtYCnxl8hWVdqNSd8WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif(eMq4t65Iv(rN0ZFA)IkmLaIJQIMatL2wS7JThMSZF4gKBrxdG60KKvaTdMh)CpRLrfMsaHBOAcyRJWM9RkQKe3ayNFDuN(JWnunblE8RwhnG8y1lbKBrkEiuF(GDFS9WKvVeqUfP4HqXkOtYC9RkQKe3ayNFDuN(J2WGcgz9cvUcF8WUp2EyYOctjGu8qOyf0jzU(vfvsIBaSZVoQt)rByqbJSEHif(eMq4t65Iv(rN0ZFA)IkmLaIJQIMatL22nW9SwwrBjLhAPqLzivVrcfXjhYly26iSzTBG7zTSI2skp0sHkZqQEJekItoKxWSo9hTocBgp(5EwlJkmLasXdHIT9W8ZhUN1YOctjGu8qOyf0jzUMRDcV5Jh)CpRLvVeqUfP4HqX2Ey(5d3ZAz1lbKBrkEiuSc6KmxZ1oH38jmHWN0ZfR8JoPN)0(fvykbe3GwNPsB72pwrBjLhAPqLzSc6Kmx)gG)8H)nW9SwwrBjLhAPqLzivVrcfXjhYly26iSz)giVnW9SwwrBjLhAPqLzivVrcfXjhYly26iSzZTbUN1YkAlP8qlfQmdP6nsOio5qEbZ60F06iSz8jmHWN0ZfR8JoPN)0(fvykbe3GwNPsBl3ZAzkfSGedi3I6YCZEk82a3ZAzN)Wni3IUga1Pjj7PWBdCpRLD(d3GCl6AauNMKSc6KmxZ1s4t6jJkmLaIBqRJb)b87a0j7GWecFspxSYp6KE(t7xuHPeqD5AjhWYuPTDdCpRLD(d3GCl6AauNMKSNcVJgqEmQWucia3484N7zTSnqxdNxjW2Ey(5dHpPkabj0LWQvD(4X)g4Ewl78hUb5w01aOonjzf0jzU(LWN0tgvykbuxUwYbSyWFa)oaDYo85d29X2dtMsbliXaYTOUm3Sc6Kmx)g4NpyxfKuEmZcUKuYhp(vlsncuYdyuHPeqkVEhgYCIbjXnG9NpCpRLHhavyADYCcHBOmHbB7HjFMIBiz2QUPavJGr4gsMiPTL7zTm8aOctRtMtiCdLjmyBpm5Xp3ZAzuHPeqkEiuSNYNp8RwhnG8yUkOu8qOGnp(5EwlREjGClsXdHI9u(8b7(y7Hjdu5y6KEYkG2bZhF8jmHWN0ZfR8JoPN)0(fvykbuxUwYbSmvAB5EwldpaQW06K5eRacF84Ewld(Rq5g2if)G8K0G9ueMq4t65Iv(rN0ZFA)IkmLaQlxl5awMkTTCpRLHhavyADYCIvaHpE8Z9SwgvykbKIhcf7P85d3ZAz1lbKBrkEiuSNYNpBG7zTSZF4gKBrxdG60KKvqNK56xcFspzuHPeqD5AjhWIb)b87a0j7aFMIBiz2QUWecFspxSYp6KE(t7xuHPeqD5AjhWYuPTL7zTm8aOctRtMtSci8XJ7zTm8aOctRtMtS1ryZA5EwldpaQW06K5eRt)rRJWMzkUHKzR6cti8j9CXk)Ot65pTFrfMsa1LRLCaltL2wUN1YWdGkmTozoXkGWhpUN1YWdGkmTozoXkOtYCnxl)8Z9SwgEauHP1jZj26iSzQXi8j9KrfMsa1LRLCalg8hWVdqNSd89ZeEZNP4gsMTQlmHWN0ZfR8JoPN)0(vcxduOd6kW6mvAB5VaBbRgIBaF(OwNeBMmN4Jh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mECpRLrfMsaP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThMcti8j9CXk)Ot65pTFrfMsa5fNPsBl3ZAzuHPeq4gQMa26iSzZ1QIkjXna25xh1P)iCdvtWsycHpPNlw5hDsp)P9R1tbQ0vrMkTTDkjMc(MRDEpFECpRLrfMsaP4HqX2EyYJ7zTS6LaYTifpek22dtEBG7zTSZF4gKBrxdG60KKT9WuycHpPNlw5hDsp)P9lQWuciUbTotL2wUN1YQ3aqUfDnfal2tHh3ZAzuHPeq4gQMa26iSz)QMcti8j9CXk)Ot65pTFrfMsaXrvrtGPsBBNsIPGV5urLK4gaJJQIMauNscPGpEy3hBpmzGkhtN0twbDsMRFdKh3ZAzuHPeqkEiuSThM84EwlJkmLac3q1eWwhHnRL7zTmQWuciCdvtaRt)rRJWMXdwliXatLCj9e5wKcuwaFspzDz6LWecFspxSYp6KE(t7xuHPeqCuv0eyQ022PKyk4BUwvujjUbW4OQOja1PKqk4Jh3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzBpm5X9SwgvykbeUHQjGTocBwl3ZAzuHPeq4gQMawN(JwhHnJh29X2dtgOYX0j9KvqNK563afMq4t65Iv(rN0ZFA)IkmLaIJQIMatL2wUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EyYJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgVJgqEmQWuciV44HDFS9WKrfMsa5fhRGojZ1CTt4nVoLetbFZ1oVdKh29X2dtgOYX0j9KvqNK5sycHpPNlw5hDsp)P9lQWucioQkAcmvAB5EwlJkmLasXdHI9u4X9SwgvykbKIhcfRGojZ1CTt4npUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz8WUp2EyYavoMoPNSc6Kmxcti8j9CXk)Ot65pTFrfMsaXrvrtGPsBl3ZAz1lbKBrkEiuSNcpUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfRGojZ1CTt4npUN1YOctjGWnunbS1ryZA5EwlJkmLac3q1eW60F06iSz8WUp2EyYavoMoPNSc6Kmxcti8j9CXk)Ot65pTFrfMsaXrvrtGPsBl3ZAzuHPeqkEiuSThM84EwlREjGClsXdHIT9WK3g4Ewl78hUb5w01aOonjzpfEBG7zTSZF4gKBrxdG60KKvqNK5AU2j8Mh3ZAzuHPeq4gQMa26iSzTCpRLrfMsaHBOAcyD6pADe2mHje(KEUyLF0j98N2VOctjG4OQOjWuPT9OAcowdqJRHPGV5uZ5ZJ7zTmQWuciCdvtaBDe2SwUN1YOctjGWnunbSo9hTocBgV6LG1RjGrfMsaX5DoQ2DipEe(KQaeKqxcRFvNh3ZAzBGUgoVsGT9WuycHpPNlw5hDsp)P9lQWuci4VYWxspnvABpQMGJ1a04Ayk4Bo1C(84EwlJkmLac3q1eWwhHnBoUN1YOctjGWnunbSo9hTocBgV6LG1RjGrfMsaX5DoQ2DipEe(KQaeKqxcRFvNh3ZAzBGUgoVsGT9WuycHpPNlw5hDsp)P9lQWuciUbToHje(KEUyLF0j98N2VavoMoPNMkTTCpRLvVeqUfP4HqX2EyYJ7zTmQWucifpek22dtEBG7zTSZF4gKBrxdG60KKT9WuycHpPNlw5hDsp)P9lQWucioQkAceMimHWN0ZfB1qfSr496N2VEla1PKqtq3uPTL)JgqEmihYPMdsyZRtjXuW3CTb4a51PKyk47325X857Zh(vRJgqEmihYPMdsyZRtjXuW3CTb45ZNWecFspxSvdvWgH3RFA)sXpPNMkTTCpRLrfMsaP4HqXEkcti8j9CXwnubBeEV(P9Rt2buivkMkTT1lbRxta7GUIx0afsLcpUN1YG)n0BDspzpfE8JDFS9WKrfMsaP4HqXkG2b)5Jvo1COc6KmxZ1QgcKpHje(KEUyRgQGncVx)0(1qo1ClKA0V9uhYZuPTL7zTmQWucifpek22dtECpRLvVeqUfP4HqX2EyYBdCpRLD(d3GCl6AauNMKSThMcti8j9CXwnubBeEV(P9loAc5w0vsSzltL2wUN1YOctjGu8qOyBpm5X9Sww9sa5wKIhcfB7HjVnW9Sw25pCdYTORbqDAsY2EykmHWN0ZfB1qfSr496N2V4GAbLzYCYuPTL7zTmQWucifpek2trycHpPNl2QHkyJW71pTFXnCFJSVkytL2wUN1YOctjGu8qOypfHje(KEUyRgQGncVx)0(Lvwa3W9TPsBl3ZAzuHPeqkEiuSNIWecFspxSvdvWgH3RFA)IsmSUIgimngMkTTCpRLrfMsaP4HqXEkcti8j9CXwnubBeEV(P9R3cqYd6ltL2wUN1YOctjGu8qOypfHje(KEUyRgQGncVx)0(1Bbi5bDtbRfWhkPo0onOTKoVwioApbMkTTCpRLrfMsaP4HqXEkF(GDFS9WKrfMsaP4HqXkOtYC9B78NpVnW9Sw25pCdYTORbqDAsYEkcti8j9CXwnubBeEV(P9R3cqYd6MMuhAHUsWfqdKx7KsmyQ02IDFS9WKrfMsaP4HqXkOtYCnxBqcuycHpPNl2QHkyJW71pTF9wasEq30K6q7UaABLfGubRfmmvABXUp2EyYOctjGu8qOyf0jzU(Tnib(5JAPIkjXnagPG8e9wqR6F(W)j7qBG8urLK4gatMQG6GnYvGeQw15vVeSEnbSLuPXt068QZNWecFspxSvdvWgH3RFA)6TaK8GUPj1H2L)gi5ukpOmvABXUp2EyYOctjGu8qOyf0jzU(Tnib(5JAPIkjXnagPG8e9wqR6F(W)j7qBG8urLK4gatMQG6GnYvGeQw15vVeSEnbSLuPXt068QZNWecFspxSvdvWgH3RFA)6TaK8GUPj1H2PrWkni3IO1s2Ld6KEAQ02IDFS9WKrfMsaP4HqXkOtYC9BBqc8Zh1sfvsIBamsb5j6TGw1)8H)t2H2a5PIkjXnaMmvb1bBKRajuTQZREjy9AcylPsJNO15vNpHje(KEUyRgQGncVx)0(1Bbi5bDttQdTDctCfGwnaCO(BjXMkTTy3hBpmzuHPeqkEiuSc6KmxZ1oFE8RwQOssCdGjtvqDWg5kqcvR6F(CYo8RAgiFcti8j9CXwnubBeEV(P9R3cqYd6MMuhA7eM4kaTAa4q93sInvABXUp2EyYOctjGu8qOyf0jzUMRD(8urLK4gatMQG6GnYvGeQw15X9Sww9sa5wKIhcf7PWJ7zTS6LaYTifpekwbDsMR5A5x9avJA(QXQxcwVMa2sQ04jADE15J3j7WCQzGrd6DnEfnmK93GoPNbur2lEXlgb]] )


end
