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
        if action.evocation.lastCast >= state.combat and not ( runeforge.siphon_storm or runeforge.temporal_warp ) then return 1 end
        if buff.arcane_power.down and ( action.arcane_power.lastCast >= state.combat or cooldown.arcane_power.remains > 0 ) and ( runeforge.siphon_storm or runeforge.temporal_warp ) then return 1 end
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


    spec:RegisterPack( "Arcane", 20201206, [[dW0RMeqisk6rkuQUefQc1MijFIczueLofrXQuOu6vQk1SOGUffQc2fu)svjdte5yKuTmkuEMiuMMcLCnskSnrOQVjcvghfQQZPqbRJKsMNcv3tb7tvLoOcLIfQQIhsHktKcvj5IuOk1hvOq6KkuuwjfyMKuQBsHQKANke)uHcvdLcvHSukuf9ukAQkKUQcfvFvHcLXkczVI6VqgmPomQftKhJyYQ4YGntPplfJwkDAcRMcvjETiy2s1Tv0Uf(nvdNehxHISCjpxLMUsxxv2or13fPXRQQZlIA9kuiMVQI9J0z1ZJMnp8c5rmwsglj1nwsjESXssnmMXsCzZnzfiBQWKe4giBg8eYMJnfHdiBQWj3D(KhnBE9xrGSz7Ukx16RVAeB7tct85xxX815v4bPy7(1vmjFLnLEI(oMfzPS5HxipIXsYyjPUXskXJnwsQHXuFmKnVkajpsI3yzZwX5arwkBEGljBo2PAJxZnavp2ueoaQbJDQ24vabMsqr1jEdPAJLKXsIAa1GXovB8eMUCGQLZLGL6aMNORcpPArq1wwUxuTBP6lSRiAUyEIUk8KQLL0cKeO6K9xr1xfGq1UYk84kdMAWyNQhZvo8chQwelub3P6wooDr0q1ULQLZLGL6aULLdixbc4q1Rt1savRovN2cbvFHDfrZfZt0vHNu9avRoMAWyNQhZVavVjRiiCNQnftJJQB540frdv7wQM0YraDQwelu1tzfEq1I4UaFOA3s1gr4GaDetwHhgHPgm2PAJ33lee4s1fmD5WHQ5lv7wQEexomLGIQnMXNQxNQl48iavBCgpAmNQL92fnTBpzzWzZU4U38OztxbcOYJMhr98OztiyPoCY)KnjLyHsWztzP66fG1RgaFfkTEGURxtmeSuhou9NpuD9cW6vdGxyQ4f3rPCPGHGL6WHQLHQvr1l3HyX1laKBrkEkuyiyPoCOAvunX9(XtdC9ca5wKINcfUGjlIlvRIQLLQLEwlUEbGClsXtHcF80GQ)8HQvkqoQHCWQJ5IWbGK4Q4gGQLjBYKv4r2eK7eEfEK38iglpA2ecwQdN8pztsjwOeC2SEby9QbWhXLiu6IGRKreFo54GHGL6WHQvr1spRfFexIqPlcUsgr85KJdYw(DXpLSjtwHhztROaKuNVBEZJKy5rZMqWsD4K)jBskXcLGZM1laRxnaUPe3EYibrq6agcwQdhQwfvp5GXkKLQ)LQhdQr2KjRWJSPT87IcxoN38iJvE0SjeSuho5FYMKsSqj4SPAs11laRxna(kuA9aDxVMyiyPoCYMmzfEKnpaVTsEfqEZJOg5rZMqWsD4K)jBskXcLGZMtoySczP6FP6XkPSjtwHhzZIpcow0vHReYBEKeFE0SjeSuho5FYMKsSqj4SP0ZAXCr4aqkEku4JNguTkQM4E)4PbMlchasXtHcxWKfXLQvr1QjvlNlbl1bSiKd1chKRabuu9avRE2KjRWJS5Tvyxr0Gu8uOYBEKexE0SjeSuho5FYMKsSqj4SPCUeSuhWIqoulCqUceqr1duT6uTkQM4E)4PbUEbGClsXtHcxWKfXLQhO6KYMmzfEKn5IWbG8skV5rm(5rZMqWsD4K)jBskXcLGZMY5sWsDalc5qTWb5kqafvpq1Qt1QOAI79JNg46faYTifpfkCbtwexQEGQtIQvr1spRfZfHdarA5QbW3Ljjq1Jt1spRfZfHdarA5QbWt(p6UmjHSjtwHhztUiCaiPoF38MhzmKhnBcbl1Ht(NSjPelucoBkNlbl1bSiKd1chKRabuu9avRovRIQLEwlUEbGClsXtHcF80iBYKv4r2SEbGClsXtHkV5rupP8OztiyPoCY)KnjLyHsWzt5CjyPoGfHCOw4GCfiGIQhOA1PAvuTAs1Ys11laRxna(kuA9aDxVMyiyPoCO6pFO66fG1RgaVWuXlUJs5sbdbl1Hdvlt2KjRWJSPIVcpYBEe1vppA2ecwQdN8pztsjwOeC2u6zT46faYTifpfk8XtJSjtwHhzZdWBRKxbK38iQBS8OztiyPoCY)KnjLyHsWztPN1IRxai3Iu8uOWhpnO6pFOALcKJAihS6yUiCaijUkUbYMmzfEKnNIQ86IClA9AcXM38iQNy5rZMqWsD4K)jBskXcLGZMspRfxVaqUfP4PqHpEAq1F(q1kfih1qoy1XCr4aqsCvCdKnzYk8iBU(J0IClABb0KBe5npI6JvE0SjeSuho5FYMKsSqj4SPsbYrnKdwD86pslYTOTfqtUrKnzYk8iBYfHdaP4PqL38iQRg5rZMqWsD4K)jBskXcLGZMspRfxVaqUfP4PqHpEAKnzYk8iBwVaqUfP4PqL38iQN4ZJMnHGL6Wj)t2KuIfkbNnpG0ZAXR)iTi3I2wan5gb(Pq1QO6di9Sw86pslYTOTfqtUrGlyYI4s1Jt1mzfEG5IWbGMI7v0Hlg(dK3cOvmHSjtwHhztLcUqqaKBrtrCYBEe1tC5rZMqWsD4K)jBskXcLGZMl3HyX1laKBrkEkuyiyPoCOAvuT0ZAXCr4aqkEku4NcvRIQLEwlUEbGClsXtHcxWKfXLQhNQBih8K)NnzYk8iBQuWfccGClAkItEZJOUXppA2ecwQdN8pztsjwOeC284lU4JGJfDv4kbCbtwexQ(xQwnO6pFO6di9SwCXhbhl6QWvci5VEaflj6Inz8Dzscu9VuDsztMScpYMCr4aqsD(U5npI6JH8OztiyPoCY)KnjLyHsWztPN1Ivk4cbbqUfnfXb)uOAvu9bKEwlE9hPf5w02cOj3iWpfQwfvFaPN1Ix)rArUfTTaAYncCbtwexQE8bQMjRWdmxeoaKuNVlg(dK3cOvmHSjtwHhztUiCaiPoF38MhXyjLhnBcbl1Ht(NSjPelucoBk9SwC9ca5wKINcf(Pq1QOAI79JNgyUiCaifpfkCb8jzQwfvp5GXkKLQhNQhRKOAvuT0ZAXCr4aqKwUAa8Dzscu9avl9SwmxeoaePLRgap5)O7YKeOAvuTAs11laRxna(kuA9aDxVMyiyPoCOAvuTAs11laRxnaEHPIxChLYLcgcwQdNSjtwHhztUiCaijUkUbYBEeJPEE0SjeSuho5FYMKsSqj4SP0ZAX1laKBrkEku4NcvRIQLEwlMlchasXtHcF80GQvr1spRfxVaqUfP4PqHlyYI4s1Jpq1nKdvRIQLEwlMlchaI0YvdGVltsGQhOAPN1I5IWbGiTC1a4j)hDxMKavRIQLZLGL6aweYHAHdYvGaQSjtwHhztUiCaijUkUbYBEeJzS8OztiyPoCY)KnjTSiYMQNnbU6jJiTSiqcB2u6zTysh4IW3venislhb0XhpnujR0ZAXCr4aqkEku4NYNpYQMl3HyXUCOu8uOGJkzLEwlUEbGClsXtHc)u(8H4E)4PbgK7eEfEGlGpjlJmYKnjLyHsWzZdi9Sw86pslYTOTfqtUrGFkuTkQE5oelMlchaciTogcwQdhQwfvllvl9Sw8b4TvYRaWhpnO6pFOAMSc5accykGlvpq1Qt1Yq1QO6di9Sw86pslYTOTfqtUrGlyYI4s1)s1mzfEG5IWbGMI7v0Hlg(dK3cOvmbQwfvllvRMunpgbkXcyUiCaiL3CcDr0GHGL6WHQ)8HQLEwlM0bUi8DfrdI0YraD8XtdQwMSjtwHhztUiCaOP4EfD4M38iglXYJMnHGL6Wj)t2KjRWJSjxeoa0uCVIoCZMKwwezt1ZMKsSqj4SP0ZAXKoWfHVRiAWfWKLQvr1e37hpnWCr4aqkEku4cMSiUuTkQwwQw6zT46faYTifpfk8tHQ)8HQLEwlMlchasXtHc)uOAzYBEeJnw5rZMqWsD4K)jBskXcLGZMspRfZfHdarA5QbW3Ljjq1Jpq1Y5sWsDaV(ort(pI0YvdCPAvuTSunX9(XtdmxeoaKINcfUGjlIlv)lvREsu9NpuntwHCabbmfWLQhFGQngvlt2KjRWJSjxeoaKxs5npIXuJ8OztiyPoCY)KnjLyHsWztPN1IRxai3Iu8uOWpfQ(ZhQEYbJvilv)lvRUAKnzYk8iBYfHdaj157M38iglXNhnBcbl1Ht(NSjtwHhztqUt4v4r2uelu1tzrcB2CYbJvi7VdgF1iBkIfQ6PSiXCchbVq2u9SjPelucoBk9SwC9ca5wKINcf(4PbvRIQLEwlMlchasXtHcF80iV5rmwIlpA2KjRWJSjxeoaKexf3aztiyPoCY)K38MnNUCycXMhnpI65rZMqWsD4K)jBskXcLGZMtxomHyXhXD5Gau9VduT6jLnzYk8iBk1frc5npIXYJMnzYk8iBQuWfccGClAkIt2ecwQdN8p5npsILhnBcbl1Ht(NSjPelucoBoD5WeIfFe3Ldcq1Jt1QNu2KjRWJSjxeoa0uCVIoCZBEKXkpA2KjRWJSjxeoaKxsztiyPoCY)K38iQrE0SjtwHhztROaKuNVB2ecwQdN8p5nVzZYxEfEKhnpI65rZMqWsD4K)jBYKv4r2eK7eEfEKnfXcv9uwKWMnNCWyfY(7WyqnujRAwVaSE1a4RqP1d0D9A(5J0ZAXxHsRhO761eFxMKWG0ZAXxHsRhO761ep5)O7YKeKjBkIfQ6PSiXCchbVq2u9SjPelucoBo5GXkKLQhFGQLZLGL6agK7ifYs1QOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhFGQzYk8adYDcVcpWWFG8waTIjq1F(q1e37hpnWCr4aqkEku4cMSiUu94duntwHhyqUt4v4bg(dK3cOvmbQ(ZhQwwQE5oelUEbGClsXtHcdbl1HdvRIQjU3pEAGRxai3Iu8uOWfmzrCP6XhOAMScpWGCNWRWdm8hiVfqRycuTmuTmuTkQw6zT46faYTifpfk8XtdQwfvl9SwmxeoaKINcf(4PbvRIQpG0ZAXR)iTi3I2wan5gb(4PrEZJyS8OztiyPoCY)KnjLyHsWzZ6fG1RgaFfkTEGURxtmeSuhouTkQM4E)4PbMlchasXtHcxWKfXLQhFGQzYk8adYDcVcpWWFG8waTIjKnzYk8iBcYDcVcpYBEKelpA2ecwQdN8pztsjwOeC2K4E)4PbE9hPf5w02cOj3iWfWNKPAvuTSuT0ZAXCr4aqKwUAa8Dzscu9VuTCUeSuhWRVt0K)JiTC1axQwfvtCVF80aZfHdaP4PqHlyYI4s1Jpq1WFG8waTIjq1YKnzYk8iBYfHdajXvXnqEZJmw5rZMqWsD4K)jBskXcLGZMe37hpnWR)iTi3I2wan5gbUa(KmvRIQLLQLEwlMlchaI0YvdGVltsGQ)LQLZLGL6aE9DIM8FePLRg4s1QO6L7qS46faYTifpfkmeSuhouTkQM4E)4PbUEbGClsXtHcxWKfXLQhFGQH)a5TaAftGQvr1e37hpnWCr4aqkEku4cMSiUu9VuTCUeSuhWRVt0K)JoqNtgz9cXkuTmztMScpYMCr4aqsCvCdK38iQrE0SjeSuho5FYMKsSqj4SjX9(Xtd86pslYTOTfqtUrGlGpjt1QOAzPAPN1I5IWbGiTC1a47YKeO6FPA5CjyPoGxFNOj)hrA5QbUuTkQwwQwnP6L7qS46faYTifpfkmeSuhou9NpunX9(XtdC9ca5wKINcfUGjlIlv)lvlNlbl1b867en5)Od05KrwVqLRq1Yq1QOAI79JNgyUiCaifpfkCbtwexQ(xQwoxcwQd413jAY)rhOZjJSEHyfQwMSjtwHhztUiCaijUkUbYBEKeFE0SjeSuho5FYMKsSqj4S5bKEwlU4JGJfDv4kbK8xpGILeDXMm(UmjbQEGQpG0ZAXfFeCSORcxjGK)6buSKOl2KXt(p6UmjbQwfvllvl9SwmxeoaKINcf(4Pbv)5dvl9SwmxeoaKINcfUGjlIlvp(av3qouTmuTkQwwQw6zT46faYTifpfk8XtdQ(ZhQw6zT46faYTifpfkCbtwexQE8bQUHCOAzYMmzfEKn5IWbGK4Q4giV5rsC5rZMqWsD4K)jBskXcLGZMhFXfFeCSORcxjGlyYI4s1)s1gFQ(ZhQwwQ(aspRfx8rWXIUkCLas(RhqXsIUytgFxMKav)lvNevRIQpG0ZAXfFeCSORcxjGK)6buSKOl2KX3Ljjq1Jt1hq6zT4Ipcow0vHReqYF9akws0fBY4j)hDxMKavlt2KjRWJSjxeoaKuNVBEZJy8ZJMnHGL6Wj)t2KuIfkbNnLEwlwPGleea5w0ueh8tHQvr1hq6zT41FKwKBrBlGMCJa)uOAvu9bKEwlE9hPf5w02cOj3iWfmzrCP6XhOAMScpWCr4aqsD(Uy4pqElGwXeYMmzfEKn5IWbGK68DZBEKXqE0SjeSuho5FYMKwwezt1ZMax9KrKwweiHnBk9SwmPdCr47kIgePLJa64JNgQKv6zTyUiCaifpfk8t5ZhzvZL7qSyxoukEkuWrLSspRfxVaqUfP4PqHFkF(qCVF80adYDcVcpWfWNKLrgzYMKsSqj4S5bKEwlE9hPf5w02cOj3iWpfQwfvVChIfZfHdabKwhdbl1HdvRIQLLQLEwl(a82k5va4JNgu9NpuntwHCabbmfWLQhOA1PAzOAvuTSu9bKEwlE9hPf5w02cOj3iWfmzrCP6FPAMScpWCr4aqtX9k6Wfd)bYBb0kMav)5dvtCVF80aRuWfccGClAkIdUGjlIlv)5dvtC5qWXIti5sWbvldvRIQLLQvtQMhJaLybmxeoaKYBoHUiAWqWsD4q1F(q1spRft6axe(UIObrA5iGo(4Pbvlt2KjRWJSjxeoa0uCVIoCZBEe1tkpA2ecwQdN8pztsjwOeC2u6zTysh4IW3ven4cyYs1QOAPN1IH)kCCGdsXxiwb3XpLSjtwHhztUiCaOP4EfD4M38iQREE0SjeSuho5FYMmzfEKn5IWbGMI7v0HB2K0YIiBQE2KuIfkbNnLEwlM0bUi8DfrdUaMSuTkQwwQw6zTyUiCaifpfk8tHQ)8HQLEwlUEbGClsXtHc)uO6pFO6di9Sw86pslYTOTfqtUrGlyYI4s1)s1mzfEG5IWbGMI7v0Hlg(dK3cOvmbQwM8MhrDJLhnBcbl1Ht(NSjtwHhztUiCaOP4EfD4MnjTSiYMQNnjLyHsWztPN1IjDGlcFxr0GlGjlvRIQLEwlM0bUi8Dfrd(UmjbQEGQLEwlM0bUi8DfrdEY)r3LjjK38iQNy5rZMqWsD4K)jBYKv4r2KlchaAkUxrhUztsllISP6ztsjwOeC2u6zTysh4IW3ven4cyYs1QOAPN1IjDGlcFxr0GlyYI4s1Jpq1Ys1Ys1spRft6axe(UIObFxMKavp2s1mzfEG5IWbGMI7v0Hlg(dK3cOvmbQwgQ(BQUHCOAzYBEe1hR8OztiyPoCY)KnjLyHsWztzP6cSfCBzPoq1F(q1QjvVcscIOHQLHQvr1spRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQvr1spRfZfHdaP4PqHpEAq1QO6di9Sw86pslYTOTfqtUrGpEAKnzYk8iBgW2cfAHPcC38MhrD1ipA2ecwQdN8pztsjwOeC2u6zTyUiCaislxna(UmjbQE8bQwoxcwQd413jAY)rKwUAGB2KjRWJSjxeoaKxs5npI6j(8OztiyPoCY)KnjLyHsWzZjhmwHSu94du9yqnOAvuT0ZAXCr4aqkEku4JNguTkQw6zT46faYTifpfk8XtdQwfvFaPN1Ix)rArUfTTaAYnc8XtJSjtwHhzZ7tbQWLZ5npI6jU8OztiyPoCY)KnjLyHsWztPN1IRxhqUfTTfax8tHQvr1spRfZfHdarA5QbW3Ljjq1)s1jw2KjRWJSjxeoaKuNVBEZJOUXppA2ecwQdN8pztsjwOeC2CYbJvilvp(avlNlbl1bSexf3aOjhmsHSuTkQw6zTyUiCaifpfk8XtdQwfvl9SwC9ca5wKINcf(4PbvRIQpG0ZAXR)iTi3I2wan5gb(4PbvRIQLEwlMlchaI0YvdGVltsGQhOAPN1I5IWbGiTC1a4j)hDxMKavRIQjU3pEAGb5oHxHh4cMSiUztMScpYMCr4aqsCvCdK38iQpgYJMnHGL6Wj)t2KuIfkbNnLEwlMlchasXtHcF80GQvr1spRfxVaqUfP4PqHpEAq1QO6di9Sw86pslYTOTfqtUrGpEAq1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1QO6L7qSyUiCaiVKWqWsD4q1QOAI79JNgyUiCaiVKWfmzrCP6XhO6gYHQvr1toySczP6XhO6XqsuTkQM4E)4PbgK7eEfEGlyYI4MnzYk8iBYfHdajXvXnqEZJySKYJMnHGL6Wj)t2KuIfkbNnLEwlMlchasXtHc)uOAvuT0ZAXCr4aqkEku4cMSiUu94duDd5q1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1QOAI79JNgyqUt4v4bUGjlIB2KjRWJSjxeoaKexf3a5npIXuppA2ecwQdN8pztsjwOeC2u6zT46faYTifpfk8tHQvr1spRfZfHdaP4PqHpEAq1QOAPN1IRxai3Iu8uOWfmzrCP6XhO6gYHQvr1spRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQvr1e37hpnWGCNWRWdCbtwe3SjtwHhztUiCaijUkUbYBEeJzS8OztiyPoCY)KnjLyHsWztPN1I5IWbGu8uOWhpnOAvuT0ZAX1laKBrkEku4JNguTkQ(aspRfV(J0IClABb0KBe4NcvRIQpG0ZAXR)iTi3I2wan5gbUGjlIlvp(av3qouTkQw6zTyUiCaislxna(UmjbQEGQLEwlMlchaI0YvdGN8F0DzscztMScpYMCr4aqsCvCdK38iglXYJMnHGL6Wj)t2KuIfkbNnxUAGf3cCFBXkKLQhNQtm1GQvr1spRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQvr11laRxnaMlchasYNsCDMqSyiyPoCOAvuntwHCabbmfWLQ)LQvNQvr1spRfFaEBL8ka8XtJSjtwHhztUiCaijUkUbYBEeJnw5rZMqWsD4K)jBskXcLGZMlxnWIBbUVTyfYs1Jt1jMAq1QOAPN1I5IWbGiTC1a47YKeO6XPAPN1I5IWbGiTC1a4j)hDxMKavRIQRxawVAamxeoaKKpL46mHyXqWsD4q1QOAMSc5accykGlv)lvRovRIQLEwl(a82k5va4JNgztMScpYMCr4aqWFLUFfEK38igtnYJMnzYk8iBYfHdaj157MnHGL6Wj)tEZJySeFE0SjeSuho5FYMKsSqj4SP0ZAX1laKBrkEku4JNguTkQw6zTyUiCaifpfk8XtdQwfvFaPN1Ix)rArUfTTaAYnc8XtJSjtwHhztqUt4v4rEZJySexE0SjtwHhztUiCaijUkUbYMqWsD4K)jV5nBYoKhnpI65rZMqWsD4K)jBskXcLGZM1laRxna(iUeHsxeCLmI4ZjhhmeSuhouTkQM4E)4Pbw6zTOJ4sekDrWvYiIpNCCWfWNKPAvuT0ZAXhXLiu6IGRKreFo54GSLFx8XtdQwfvllvl9SwmxeoaKINcf(4PbvRIQLEwlUEbGClsXtHcF80GQvr1hq6zT41FKwKBrBlGMCJaF80GQLHQvr1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAzPAPN1I5IWbGiTC1a47YKeO6XhOA5CjyPoGzhqRVt0K)JiTC1axQwfvllvllvVChIfxVaqUfP4PqHHGL6WHQvr1e37hpnW1laKBrkEku4cMSiUu94duDd5q1QOAI79JNgyUiCaifpfkCbtwexQ(xQwoxcwQd413jAY)rhOZjJSEHyfQwgQ(ZhQwwQwnP6L7qS46faYTifpfkmeSuhouTkQM4E)4PbMlchasXtHcxWKfXLQ)LQLZLGL6aE9DIM8F0b6CYiRxiwHQLHQ)8HQjU3pEAG5IWbGu8uOWfmzrCP6XhO6gYHQLHQLjBYKv4r20w(DL8(M38iglpA2ecwQdN8pztsjwOeC2uwQUEby9QbWhXLiu6IGRKreFo54GHGL6WHQvr1e37hpnWspRfDexIqPlcUsgr85KJdUa(KmvRIQLEwl(iUeHsxeCLmI4ZjhhKvua(4PbvRIQvkqoQHCWQJTLFxjVVuTmu9NpuTSuD9cW6vdGpIlrO0fbxjJi(CYXbdbl1HdvRIQxXeO6bQojQwMSjtwHhztROaKuNVBEZJKy5rZMqWsD4K)jBskXcLGZM1laRxnaUPe3EYibrq6agcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1jwsuTkQM4E)4PbE9hPf5w02cOj3iWfmzrCP6bQojQwfvllvl9SwmxeoaePLRgaFxMKavp(avlNlbl1bm7aA9DIM8FePLRg4s1QOAzPAzP6L7qS46faYTifpfkmeSuhouTkQM4E)4PbUEbGClsXtHcxWKfXLQhFGQBihQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1Y5sWsDaV(ort(p6aDozK1leRq1Yq1F(q1Ys1QjvVChIfxVaqUfP4PqHHGL6WHQvr1e37hpnWCr4aqkEku4cMSiUu9VuTCUeSuhWRVt0K)JoqNtgz9cXkuTmu9NpunX9(XtdmxeoaKINcfUGjlIlvp(av3qouTmuTmztMScpYM2YVlkC5CEZJmw5rZMqWsD4K)jBskXcLGZM1laRxnaUPe3EYibrq6agcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1duDsuTkQwwQwwQwwQM4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGzf0K)JoqNtgz9cT(oPAvuT0ZAXCr4aqKwUAa8Dzscu9avl9SwmxeoaePLRgap5)O7YKeOAzO6pFOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvuT0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvldvldvRIQLEwlUEbGClsXtHcF80GQLjBYKv4r20w(DrHlNZBEe1ipA2ecwQdN8pztsjwOeC2SEby9QbWxHsRhO761edbl1HdvRIQvkqoQHCWQJb5oHxHhztMScpYMR)iTi3I2wan5grEZJK4ZJMnHGL6Wj)t2KuIfkbNnRxawVAa8vO06b6UEnXqWsD4q1QOAzPALcKJAihS6yqUt4v4bv)5dvRuGCud5GvhV(J0IClABb0KBeuTmztMScpYMCr4aqkEku5npsIlpA2ecwQdN8pztsjwOeC2CftGQ)LQtSKOAvuD9cW6vdGVcLwpq31RjgcwQdhQwfvl9SwmxeoaePLRgaFxMKavp(avlNlbl1bm7aA9DIM8FePLRg4s1QOAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvunX9(XtdmxeoaKINcfUGjlIlvp(av3qoztMScpYMGCNWRWJ8MhX4NhnBcbl1Ht(NSjtwHhztqUt4v4r2uelu1tzrcB2u6zT4RqP1d0D9AIVltsyq6zT4RqP1d0D9AIN8F0DzscztrSqvpLfjMt4i4fYMQNnjLyHsWzZvmbQ(xQoXsIQvr11laRxna(kuA9aDxVMyiyPoCOAvunX9(XtdmxeoaKINcfUGjlIlvpq1jr1QOAzPAzPAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQ)LQLZLGL6aMvqt(p6aDozK1l067KQvr1spRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQLHQ)8HQLLQjU3pEAGx)rArUfTTaAYncCbtwexQEGQtIQvr1spRfZfHdarA5QbW3Ljjq1Jpq1Y5sWsDaZoGwFNOj)hrA5QbUuTmuTmuTkQw6zT46faYTifpfk8XtdQwM8MhzmKhnBcbl1Ht(NSjPelucoBklvtCVF80aZfHdaP4PqHlyYI4s1)s1JLAq1F(q1e37hpnWCr4aqkEku4cMSiUu94duDIr1Yq1QOAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvuTSuT0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvRIQLLQLLQxUdXIRxai3Iu8uOWqWsD4q1QOAI79JNg46faYTifpfkCbtwexQE8bQUHCOAvunX9(XtdmxeoaKINcfUGjlIlv)lvRguTmu9NpuTSuTAs1l3HyX1laKBrkEkuyiyPoCOAvunX9(XtdmxeoaKINcfUGjlIlv)lvRguTmu9NpunX9(XtdmxeoaKINcfUGjlIlvp(av3qouTmuTmztMScpYMtrvEDrUfTEnHyZBEe1tkpA2ecwQdN8pztsjwOeC2K4E)4PbE9hPf5w02cOj3iWfmzrCP6XPA4pqElGwXeOAvuTSuT0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvRIQLLQLLQxUdXIRxai3Iu8uOWqWsD4q1QOAI79JNg46faYTifpfkCbtwexQE8bQUHCOAvunX9(XtdmxeoaKINcfUGjlIlv)lvlNlbl1b867en5)Od05KrwVqScvldv)5dvllvRMu9YDiwC9ca5wKINcfgcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1Y5sWsDaV(ort(p6aDozK1leRq1Yq1F(q1e37hpnWCr4aqkEku4cMSiUu94duDd5q1Yq1YKnzYk8iBw8rWXIUkCLqEZJOU65rZMqWsD4K)jBskXcLGZMe37hpnWCr4aqkEku4cMSiUu94un8hiVfqRycuTkQwwQwwQwwQM4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGzf0K)JoqNtgz9cT(oPAvuT0ZAXCr4aqKwUAa8Dzscu9avl9SwmxeoaePLRgap5)O7YKeOAzO6pFOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvuT0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvldvldvRIQLEwlUEbGClsXtHcF80GQLjBYKv4r2S4JGJfDv4kH8MhrDJLhnBcbl1Ht(NSjPelucoBsCVF80aZfHdaP4PqHlyYI4s1duDsuTkQwwQwwQwwQM4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGzf0K)JoqNtgz9cT(oPAvuT0ZAXCr4aqKwUAa8Dzscu9avl9SwmxeoaePLRgap5)O7YKeOAzO6pFOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvuT0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvldvldvRIQLEwlUEbGClsXtHcF80GQLjBYKv4r28a82k5va5npI6jwE0SjeSuho5FYMKsSqj4SP0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWSdO13jAY)rKwUAGlvRIQLLQLLQxUdXIRxai3Iu8uOWqWsD4q1QOAI79JNg46faYTifpfkCbtwexQE8bQUHCOAvunX9(XtdmxeoaKINcfUGjlIlv)lvlNlbl1b867en5)Od05KrwVqScvldv)5dvllvRMu9YDiwC9ca5wKINcfgcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1Y5sWsDaV(ort(p6aDozK1leRq1Yq1F(q1e37hpnWCr4aqkEku4cMSiUu94duDd5q1YKnzYk8iBU(J0IClABb0KBe5npI6JvE0SjeSuho5FYMKsSqj4SPSuTSunX9(Xtd86pslYTOTfqtUrGlyYI4s1)s1Y5sWsDaZkOj)hDGoNmY6fA9Ds1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1Yq1F(q1Ys1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAPN1I5IWbGiTC1a47YKeO6XhOA5CjyPoGzhqRVt0K)JiTC1axQwgQwgQwfvl9SwC9ca5wKINcf(4Pr2KjRWJSjxeoaKINcvEZJOUAKhnBcbl1Ht(NSjPelucoBk9SwC9ca5wKINcf(4PbvRIQLLQLLQjU3pEAGx)rArUfTTaAYncCbtwexQ(xQ2yjr1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1Yq1F(q1Ys1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAPN1I5IWbGiTC1a47YKeO6XhOA5CjyPoGzhqRVt0K)JiTC1axQwgQwgQwfvllvtCVF80aZfHdaP4PqHlyYI4s1)s1QBmQ(ZhQ(aspRfV(J0IClABb0KBe4Ncvlt2KjRWJSz9ca5wKINcvEZJOEIppA2ecwQdN8pztsjwOeC2K4E)4PbMlchaYljCbtwexQ(xQwnYMmzfEKnVTc7kIgKINcvEZJOEIlpA2ecwQdN8pztsjwOeC2unP6L7qSyUiCaiVKWqWsD4q1QOAPN1I5IWbGu8uOWhpnOAvuT0ZAX1laKBrkEku4JNguTkQ(aspRfV(J0IClABb0KBe4JNgztMScpYM3wHDfrdsXtHkV5ru34NhnBcbl1Ht(NSjPelucoBk9Sw8b4TvYRaWpfQwfvFaPN1Ix)rArUfTTaAYnc8tHQvr1hq6zT41FKwKBrBlGMCJaxWKfXLQhFGQLEwlwPGleea5w0ueh8K)JUltsGQhBPAMScpWCr4aqsD(Uy4pqElGwXeYMmzfEKnvk4cbbqUfnfXjV5ruFmKhnBcbl1Ht(NSjPelucoBk9Sw8b4TvYRaWpfQwfvllvllvVChIfxW1doiagcwQdhQwfvZKvihqqatbCP6XP6XIQLHQ)8HQzYkKdiiGPaUu94uTAq1Yq1QOAzPA1KQRxawVAamxeoaKKpL46mHyXqWsD4q1F(q1lxnWIBbUVTyfYs1)s1jMAq1YKnzYk8iBYfHdaj157M38iglP8OztMScpYM3NcuHlNZMqWsD4K)jV5rmM65rZMqWsD4K)jBskXcLGZMspRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsiBYKv4r2KlchasIRIBG8MhXyglpA2ecwQdN8pztsjwOeC2u6zTyUiCaislxna(UmjbQEGQtkBYKv4r2KlchaYlP8MhXyjwE0SjeSuho5FYMKsSqj4SPSuDb2cUTSuhO6pFOA1KQxbjbr0q1Yq1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3LjjKnzYk8iBgW2cfAHPcC38MhXyJvE0SjeSuho5FYMKsSqj4SP0ZAXKoWfHVRiAWfWKLQvr11laRxnaMlchasewri2KXqWsD4q1QO6L7qSyEQ0fwbHxHhyiyPoCOAvuntwHCabbmfWLQhNQn(ztMScpYMCr4aqtX9k6WnV5rmMAKhnBcbl1Ht(NSjPelucoBk9SwmPdCr47kIgCbmzPAvuTSuD9cW6vdG5IWbGeHveInzmeSuhou9Npu9YDiwmpv6cRGWRWdmeSuhouTmuTkQMjRqoGGaMc4s1Jt1Qr2KjRWJSjxeoa0uCVIoCZBEeJL4ZJMnHGL6Wj)t2KuIfkbNnLEwlMlchaI0YvdGVltsGQhNQLEwlMlchaI0YvdGN8F0DzscztMScpYMCr4aqWFLUFfEK38iglXLhnBcbl1Ht(NSjPelucoBk9SwmxeoaePLRgaFxMKavpq1spRfZfHdarA5QbWt(p6UmjbQwfvRuGCud5GvhZfHdajXvXnq2KjRWJSjxeoae8xP7xHh5npIXm(5rZMIyHQEklsyZMtoyScz)DW4RgztrSqvpLfjMt4i4fYMQNnzYk8iBcYDcVcpYMqWsD4K)jV5nBEal)6BE08iQNhnBcbl1Ht(NSjPelucoBUC1al(aspRft47kIgCbmzZMmzfEKnj(lwOUkqVN38iglpA2ecwQdN8pztxjBEHnBYKv4r2uoxcwQdzt5C)bzt1ZMKsSqj4SPCUeSuhWTSCa5kqahQEGQtIQvr1kfih1qoy1XGCNWRWdQwfvRMuTSuD9cW6vdGVcLwpq31RjgcwQdhQ(ZhQUEby9QbWlmv8I7OuUuWqWsD4q1YKnLZfk4jKnBz5aYvGao5npsILhnBcbl1Ht(NSPRKnVWMnzYk8iBkNlbl1HSPCU)GSP6ztsjwOeC2uoxcwQd4wwoGCfiGdvpq1jr1QOAPN1I5IWbGu8uOWhpnOAvunX9(XtdmxeoaKINcfUGjlIlvRIQLLQRxawVAa8vO06b6UEnXqWsD4q1F(q11laRxnaEHPIxChLYLcgcwQdhQwMSPCUqbpHSzllhqUceWjV5rgR8OztiyPoCY)KnDLS5f2SjtwHhzt5CjyPoKnLZ9hKnvpBskXcLGZMspRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQvr1Qjvl9SwC96aYTOTTa4IFkuTkQ2kAAxubtwexQE8bQwwQwwQEYbt1Fr1mzfEG5IWbGK68DXe)UuTmu9ylvZKv4bMlchasQZ3fd)bYBb0kMavlt2uoxOGNq20kcUJKEvK38iQrE0SjeSuho5FYMmzfEKnjCVJyYk8a1f3nB2f3ff8eYM3wUGdICU5npsIppA2ecwQdN8pztsjwOeC2KjRqoGGaMc4s1)s1glBYKv4r2KW9oIjRWduxC3SzxCxuWtiBYoK38ijU8OztiyPoCY)KnjLyHsWzt5CjyPoGBz5aYvGaou9avNu2KjRWJSjH7DetwHhOU4UzZU4UOGNq20vGaQ8MhX4NhnBcbl1Ht(NSjPelucoBEHDfrZfZt0vHNu9avRE2KjRWJSjH7DetwHhOU4UzZU4UOGNq2KNORcpZBEKXqE0SjeSuho5FYMmzfEKnjCVJyYk8a1f3nB2f3ff8eYMe37hpnU5npI6jLhnBcbl1Ht(NSjPelucoBkNlbl1bSveChj9QGQhO6KYMmzfEKnjCVJyYk8a1f3nB2f3ff8eYMLV8k8iV5rux98OztiyPoCY)KnjLyHsWzt5CjyPoGTIG7iPxfu9avRE2KjRWJSjH7DetwHhOU4UzZU4UOGNq20kcUJKEvK38iQBS8OztiyPoCY)KnzYk8iBs4EhXKv4bQlUB2SlUlk4jKnNUCycXM38MnvkG4tjEZJMhr98OztiyPoCY)KnDLSzbxyZMmzfEKnLZLGL6q2uoxOGNq2uPaLxVJa5E28aw(13Szs5npIXYJMnHGL6Wj)t20vYMxyZMmzfEKnLZLGL6q2uo3Fq2u9SjPelucoBkNlbl1bSsbkVEhbYDQEGQtIQvr11laRxna(kuA9aDxVMyiyPoCOAvuntwHCabbmfWLQ)LQnw2uoxOGNq2uPaLxVJa5EEZJKy5rZMqWsD4K)jB6kzZlSztMScpYMY5sWsDiBkN7piBQE2KuIfkbNnLZLGL6awPaLxVJa5ovpq1jr1QO66fG1RgaFfkTEGURxtmeSuhouTkQM4YHGJfhaP8UxhQwfvZKvihqqatbCP6FPA1ZMY5cf8eYMkfO86Dei3ZBEKXkpA2ecwQdN8pztxjBEHnBYKv4r2uoxcwQdzt5C)bzZKYMY5cf8eYMTSCa5kqaN8MhrnYJMnHGL6Wj)t20vYMxyZMmzfEKnLZLGL6q2uo3Fq2u9SjPelucoBkNlbl1bCllhqUceWHQhO6KOAvuntwHCabbmfWLQ)LQnw2uoxOGNq2SLLdixbc4K38ij(8OztiyPoCY)KnDLS5f2SjtwHhzt5CjyPoKnLZ9hKnvpBskXcLGZMY5sWsDa3YYbKRabCO6bQojQwfvlNlbl1bSsbkVEhbYDQEGQvpBkNluWtiB2YYbKRabCYBEKexE0SjeSuho5FYMUs28cB2KjRWJSPCUeSuhYMY5(dYMjLnLZfk4jKnTIG7iPxf5npIXppA2ecwQdN8pztxjBwWf2SjtwHhzt5CjyPoKnLZfk4jKnRlAY)rhOZjJSEHwFNzZdy5xFZMQrEZJmgYJMnHGL6Wj)t20vYMfCHnBYKv4r2uoxcwQdzt5CHcEczZ6IM8F0b6CYiRxOYvYMhWYV(MnvJ8Mhr9KYJMnHGL6Wj)t20vYMfCHnBYKv4r2uoxcwQdzt5CHcEczZ6IM8F0b6CYiRxiwjBEal)6B20yjL38iQREE0SjeSuho5FYMUs2SGlSztMScpYMY5sWsDiBkNluWtiBYkOj)hDGoNmY6fA9DMnpGLF9nBQEs5npI6glpA2ecwQdN8pztxjBwWf2SjtwHhzt5CjyPoKnLZfk4jKnlxbn5)Od05KrwVqRVZS5bS8RVztJLuEZJOEILhnBcbl1Ht(NSPRKnl4cB2KjRWJSPCUeSuhYMY5cf8eYMRVt0K)JoqNtgz9cXkzZdy5xFZMjL38iQpw5rZMqWsD4K)jB6kzZlSztMScpYMY5sWsDiBkN7piBMyztsjwOeC2uoxcwQd413jAY)rhOZjJSEHyfQEGQtIQvr11laRxna(iUeHsxeCLmI4ZjhhmeSuhozt5CHcEczZ13jAY)rhOZjJSEHyL8MhrD1ipA2ecwQdN8pztxjBEHnBYKv4r2uoxcwQdzt5C)bzt1vJSjPelucoBkNlbl1b867en5)Od05KrwVqScvpq1jr1QOAIlhcowCiAAxKLHSPCUqbpHS567en5)Od05KrwVqSsEZJOEIppA2ecwQdN8pztxjBEHnBYKv4r2uoxcwQdzt5C)bzt1vJSjPelucoBkNlbl1b867en5)Od05KrwVqScvpq1jr1QOAIhNNyXCr4aqkLFenjJHGL6WHQvr1mzfYbeeWuaxQECQoXYMY5cf8eYMRVt0K)JoqNtgz9cXk5npI6jU8OztiyPoCY)KnDLS5f2SjtwHhzt5CjyPoKnLZ9hKnvJSjPelucoBkNlbl1b867en5)Od05KrwVqScvpq1jLnLZfk4jKnxFNOj)hDGoNmY6fIvYBEe1n(5rZMqWsD4K)jB6kzZcUWMnzYk8iBkNlbl1HSPCUqbpHS567en5)Od05KrwVqLRKnpGLF9nBASKYBEe1hd5rZMqWsD4K)jB6kzZcUWMnzYk8iBkNlbl1HSPCUqbpHSPexf3aOjhmsHSzZdy5xFZMjL38iglP8OztiyPoCY)KnDLS5f2SjtwHhzt5CjyPoKnLZ9hKnLLQt8jr1gpq1Ys1t(UqLmso3Favp2s1QNusuTmuTmztsjwOeC2uoxcwQdyjUkUbqtoyKczP6bQojQwfvtC5qWXIdrt7ISmKnLZfk4jKnL4Q4gan5GrkKnV5rmM65rZMqWsD4K)jB6kzZlSztMScpYMY5sWsDiBkN7piBklvB8tIQnEGQLLQN8DHkzKCU)aQESLQvpPKOAzOAzYMKsSqj4SPCUeSuhWsCvCdGMCWifYs1duDszt5CHcEcztjUkUbqtoyKczZBEeJzS8OztiyPoCY)KnDLSzbxyZMmzfEKnLZLGL6q2uoxOGNq2KvqtriMVjAYbJuiB28aw(13Szs5npIXsS8OztiyPoCY)KnDLS5f2SjtwHhzt5CjyPoKnLZ9hKnvJKYMKsSqj4SPCUeSuhWScAkcX8nrtoyKczP6bQojQwfvxVaSE1a4J4sekDrWvYiIpNCCWqWsD4KnLZfk4jKnzf0ueI5BIMCWifYM38igBSYJMnHGL6Wj)t20vYMxyZMmzfEKnLZLGL6q2uo3Fq2unskBskXcLGZMY5sWsDaZkOPieZ3en5GrkKLQhO6KOAvuD9cW6vdGBkXTNmsqeKoGHGL6WjBkNluWtiBYkOPieZ3en5GrkKnV5rmMAKhnBcbl1Ht(NSPRKnVWMnzYk8iBkNlbl1HSPCU)GSP6Qr2KuIfkbNnLZLGL6aMvqtriMVjAYbJuilvpq1jLnLZfk4jKnzf0ueI5BIMCWifYM38iglXNhnBcbl1Ht(NSPRKnl4cB2KjRWJSPCUeSuhYMY5cf8eYMRVt0K)JiTC1a3S5bS8RVztJL38iglXLhnBcbl1Ht(NSPRKnl4cB2KjRWJSPCUeSuhYMY5cf8eYMIqoulCqUceqLnpGLF9nBMuEZJymJFE0SjeSuho5FYMUs28cB2KjRWJSPCUeSuhYMY5(dYMQNnjLyHsWzt5CjyPoGfHCOw4GCfiGIQhO6KOAvu9YDiwC9ca5wKINcfgcwQdhQwfvllvVChIfZfHdabKwhdbl1Hdv)5dvRMunXLdbhloHKlbhuTmuTkQwwQwnPAIlhcowCaKY7EDO6pFOAMSc5accykGlvpq1Qt1F(q11laRxna(kuA9aDxVMyiyPoCOAzYMY5cf8eYMIqoulCqUceqL38igBmKhnBcbl1Ht(NSPRKnVWMnzYk8iBkNlbl1HSPCU)GSzsztsjwOeC2uoxcwQdyrihQfoixbcOO6bQoPSPCUqbpHSPiKd1chKRabu5npsILuE0SjeSuho5FYMUs28cB2KjRWJSPCUeSuhYMY5(dYMWy6juuGdEYewQa0TfGfnFxbHQ)8HQHX0tOOahCtNpcE96IK4tdq1F(q1Wy6juuGdUPZhbVEDrt4W9UWdQ(ZhQggtpHIcCWhUsy6EGoajbKYBl4sGGau9NpunmMEcff4GfXLuVLL6aAm94yFt0bKliav)5dvdJPNqrbo4R)6Dyxr0GQNuYu9NpunmMEcff4GVVqQ7(bXtyBt(Uu9NpunmMEcff4Gt5eGaQlYwECO6pFOAym9ekkWbB78eqUfjX72HSPCUqbpHSjRG8a9UqEZJKyQNhnBcbl1Ht(NSPRKnl4cB2KjRWJSPCUeSuhYMY5cf8eYMSdO13jAY)rKwUAGB28aw(13SPXYBEKeZy5rZMqWsD4K)jB6kzZlSztMScpYMY5sWsDiBkN7piBQE2KuIfkbNnLZLGL6aULLdixbc4q1duDsuTkQ(c7kIMlMNORcpP6bQw9SPCUqbpHSzllhqUceWjV5rsSelpA2ecwQdN8pztxjBwWf2SjtwHhzt5CjyPoKnLZfk4jKnb5osHSzZdy5xFZMQRg5npsInw5rZMqWsD4K)jV5rsm1ipA2ecwQdN8p5npsIL4ZJMnHGL6Wj)tEZJKyjU8OztMScpYM33C6bIlchaYYtrxWv2ecwQdN8p5npsIz8ZJMnzYk8iBYfHdajIf6DGSztiyPoCY)K38ij2yipA2KjRWJSjXdJxEfGMCWOgyMnHGL6Wj)tEZJmwjLhnBcbl1Ht(N8MhzSuppA2KjRWJS5uuLxiXKBGSjeSuho5FYBEKXYy5rZMqWsD4K)jBskXcLGZMQjvlNlbl1bSsbkVEhbYDQEGQvNQvr11laRxna(iUeHsxeCLmI4ZjhhmeSuhoztMScpYM2YVRK338MhzSsS8OztiyPoCY)KnjLyHsWzt1KQLZLGL6awPaLxVJa5ovpq1Qt1QOA1KQRxawVAa8rCjcLUi4kzeXNtooyiyPoCYMmzfEKn5IWbGK68DZBEKXASYJMnHGL6Wj)t2KuIfkbNnLZLGL6awPaLxVJa5ovpq1QNnzYk8iBcYDcVcpYBEZM8eDv4zE08iQNhnBcbl1Ht(NSjPelucoBo5GXkKLQhFGQLZLGL6agK7ifYs1QOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhFGQzYk8adYDcVcpWWFG8waTIjq1F(q1e37hpnWCr4aqkEku4cMSiUu94duntwHhyqUt4v4bg(dK3cOvmbQ(ZhQwwQE5oelUEbGClsXtHcdbl1HdvRIQjU3pEAGRxai3Iu8uOWfmzrCP6XhOAMScpWGCNWRWdm8hiVfqRycuTmuTmuTkQw6zT46faYTifpfk8XtdQwfvl9SwmxeoaKINcf(4PbvRIQpG0ZAXR)iTi3I2wan5gb(4Pr2KjRWJSji3j8k8iV5rmwE0SjeSuho5FYMKsSqj4SjX9(XtdmxeoaKINcfUGjlIlvpq1jr1QOAzPAPN1IRxai3Iu8uOWhpnOAvuTSunX9(Xtd86pslYTOTfqtUrGlyYI4s1)s1Y5sWsDaZkOj)hDGoNmY6fA9Ds1F(q1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1Yq1YKnzYk8iBEaEBL8kG8MhjXYJMnHGL6Wj)t2KuIfkbNnjU3pEAG5IWbGu8uOWfmzrCP6bQojQwfvllvl9SwC9ca5wKINcf(4PbvRIQLLQjU3pEAGx)rArUfTTaAYncCbtwexQ(xQwoxcwQdywbn5)Od05KrwVqRVtQ(ZhQM4E)4PbE9hPf5w02cOj3iWfmzrCP6bQojQwgQwMSjtwHhzZPOkVUi3IwVMqS5npYyLhnBYKv4r2S4JGJfDv4kHSjeSuho5FYBEe1ipA2ecwQdN8pztsjwOeC2u6zTyUiCaifpfk8XtdQwfvtCVF80aZfHdaP4PqH36bOcMSiUu9VuntwHh4BRWUIObP4PqHjNIQvr1spRfxVaqUfP4PqHpEAq1QOAI79JNg46faYTifpfk8wpavWKfXLQ)LQzYk8aFBf2venifpfkm5uuTkQ(aspRfV(J0IClABb0KBe4JNgztMScpYM3wHDfrdsXtHkV5rs85rZMqWsD4K)jBskXcLGZMspRfxVaqUfP4PqHpEAq1QOAI79JNgyUiCaifpfkCbtwe3SjtwHhzZ6faYTifpfQ8MhjXLhnBcbl1Ht(NSjPelucoBklvtCVF80aZfHdaP4PqHlyYI4s1duDsuTkQw6zT46faYTifpfk8XtdQwgQ(ZhQwPa5OgYbRoUEbGClsXtHkBYKv4r2C9hPf5w02cOj3iYBEeJFE0SjeSuho5FYMKsSqj4SjX9(XtdmxeoaKINcfUGjlIlvpovRgjr1QOAPN1IRxai3Iu8uOWhpnOAvunCVqqaSCXv4bYTifOSazfEGHGL6WjBYKv4r2C9hPf5w02cOj3iYBEKXqE0SjeSuho5FYMKsSqj4SP0ZAX1laKBrkEku4JNguTkQM4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGzf0K)JoqNtgz9cT(oZMmzfEKn5IWbGu8uOYBEe1tkpA2ecwQdN8pztsjwOeC2u6zTyUiCaifpfk8tHQvr1spRfZfHdaP4PqHlyYI4s1Jpq1mzfEG5IWbGMI7v0Hlg(dK3cOvmbQwfvl9SwmxeoaePLRgaFxMKavpq1spRfZfHdarA5QbWt(p6UmjHSjtwHhztUiCaijUkUbYBEe1vppA2ecwQdN8pztsjwOeC2u6zTyUiCaislxna(UmjbQECQw6zTyUiCaislxnaEY)r3Ljjq1QOAPN1IRxai3Iu8uOWhpnOAvuT0ZAXCr4aqkEku4JNguTkQ(aspRfV(J0IClABb0KBe4JNgztMScpYMCr4aqEjL38iQBS8OztiyPoCY)KnjLyHsWztPN1IRxai3Iu8uOWhpnOAvuT0ZAXCr4aqkEku4JNguTkQ(aspRfV(J0IClABb0KBe4JNguTkQw6zTyUiCaislxna(UmjbQEGQLEwlMlchaI0YvdGN8F0DzscztMScpYMCr4aqsCvCdK38iQNy5rZMqWsD4K)jBsAzrKnvpBcC1tgrAzrGe2SP0ZAXKoWfHVRiAqKwocOJpEAOswPN1I5IWbGu8uOWpLpFKEwlUEbGClsXtHc)u(8H4E)4PbgK7eEfEGlGpjlt2KuIfkbNnLEwlM0bUi8DfrdUaMSztMScpYMCr4aqtX9k6WnV5ruFSYJMnHGL6Wj)t2K0YIiBQE2e4QNmI0YIajSztPN1IjDGlcFxr0GiTCeqhF80qLSspRfZfHdaP4PqHFkF(i9SwC9ca5wKINcf(P85dX9(Xtdmi3j8k8axaFswMSjPelucoBQMunpgbkXcyUiCaiL3CcDr0GHGL6WHQ)8HQLEwlM0bUi8DfrdI0YraD8XtJSjtwHhztUiCaOP4EfD4M38iQRg5rZMqWsD4K)jBskXcLGZMspRfxVaqUfP4PqHpEAq1QOAPN1I5IWbGu8uOWhpnOAvu9bKEwlE9hPf5w02cOj3iWhpnYMmzfEKnb5oHxHh5npI6j(8OztiyPoCY)KnjLyHsWztPN1I5IWbGiTC1a47YKeO6XPAPN1I5IWbGiTC1a4j)hDxMKq2KjRWJSjxeoaKxs5npI6jU8OztMScpYMCr4aqsCvCdKnHGL6Wj)tEZJOUXppA2KjRWJSjxeoaKuNVB2ecwQdN8p5nVzZBlxWbro38O5ruppA2ecwQdN8pztsjwOeC2uwQE5oelgIUOPDHaoyiyPoCOAvu9KdgRqwQE8bQ24NevRIQNCWyfYs1)oq1jE1GQLHQ)8HQLLQvtQE5oelgIUOPDHaoyiyPoCOAvu9KdgRqwQE8bQ24RguTmztMScpYMtoyudmZBEeJLhnBcbl1Ht(NSjPelucoBk9SwmxeoaKINcf(PKnzYk8iBQ4RWJ8MhjXYJMnHGL6Wj)t2KuIfkbNnRxawVAa8ctfV4okLlfmeSuhouTkQw6zTy4Fl)URWd8tHQvr1Ys1e37hpnWCr4aqkEku4c4tYu9NpuTv00UOcMSiUu94du9yLevlt2KjRWJS5kMakLlL8MhzSYJMnHGL6Wj)t2KuIfkbNnLEwlMlchasXtHcF80GQvr1spRfxVaqUfP4PqHpEAq1QO6di9Sw86pslYTOTfqtUrGpEAKnzYk8iB2fnT7fz8Y70mHyZBEe1ipA2ecwQdN8pztsjwOeC2u6zTyUiCaifpfk8XtdQwfvl9SwC9ca5wKINcf(4PbvRIQpG0ZAXR)iTi3I2wan5gb(4Pr2KjRWJSPe3GClAlbjHBEZJK4ZJMnHGL6Wj)t2KuIfkbNnLEwlMlchasXtHc)uYMmzfEKnLG6cvcIOjV5rsC5rZMqWsD4K)jBskXcLGZMspRfZfHdaP4PqHFkztMScpYMsD3pi7RsoV5rm(5rZMqWsD4K)jBskXcLGZMspRfZfHdaP4PqHFkztMScpYMwrbsD3p5npYyipA2ecwQdN8pztsjwOeC2u6zTyUiCaifpfk8tjBYKv4r2KdcC3I7ic375npI6jLhnBcbl1Ht(NSjPelucoBk9SwmxeoaKINcf(PKnzYk8iB(UasSW8M38iQREE0SjeSuho5FYMmzfEKnB68rWRxxKeFAGSjPelucoBk9SwmxeoaKINcf(Pq1F(q1e37hpnWCr4aqkEku4cMSiUu9VduTAOguTkQ(aspRfV(J0IClABb0KBe4Ns2eSwGSOGNq2SPZhbVEDrs8PbYBEe1nwE0SjeSuho5FYMmzfEKnHPsYfWDKxNGdcKnjLyHsWztI79JNgyUiCaifpfkCbtwexQE8bQ2yjLndEcztyQKCbCh51j4Ga5npI6jwE0SjeSuho5FYMmzfEKnpfWhROaKC4EHE2KuIfkbNnjU3pEAG5IWbGu8uOWfmzrCP6FhOAJLev)5dvRMuTCUeSuhWScYd07cu9avRov)5dvllvVIjq1duDsuTkQwoxcwQdyrihQfoixbcOO6bQwDQwfvxVaSE1a4RqP1d0D9AIHGL6WHQLjBg8eYMNc4JvuasoCVqpV5ruFSYJMnHGL6Wj)t2KjRWJS51FDKOjeluztsjwOeC2K4E)4PbMlchasXtHcxWKfXLQ)DGQnwsu9NpuTAs1Y5sWsDaZkipqVlq1duT6u9NpuTSu9kMavpq1jr1QOA5CjyPoGfHCOw4GCfiGIQhOA1PAvuD9cW6vdGVcLwpq31RjgcwQdhQwMSzWtiBE9xhjAcXcvEZJOUAKhnBcbl1Ht(NSjtwHhzZMEYkTi3I47vmfDEfEKnjLyHsWztI79JNgyUiCaifpfkCbtwexQ(3bQ2yjr1F(q1QjvlNlbl1bmRG8a9Uavpq1Qt1F(q1Ys1Rycu9avNevRIQLZLGL6aweYHAHdYvGakQEGQvNQvr11laRxna(kuA9aDxVMyiyPoCOAzYMbpHSztpzLwKBr89kMIoVcpYBEe1t85rZMqWsD4K)jBYKv4r2CYewQa0TfGfnFxbjBskXcLGZMe37hpnWCr4aqkEku4cMSiUu94duTAq1QOAzPA1KQLZLGL6aweYHAHdYvGakQEGQvNQ)8HQxXeO6FP6eljQwMSzWtiBozclva62cWIMVRGK38iQN4YJMnHGL6Wj)t2KjRWJS5KjSubOBlalA(Ucs2KuIfkbNnjU3pEAG5IWbGu8uOWfmzrCP6XhOA1GQvr1Y5sWsDalc5qTWb5kqafvpq1Qt1QOAPN1IRxai3Iu8uOWpfQwfvl9SwC9ca5wKINcfUGjlIlvp(avllvREsuTXduTAq1JTuD9cW6vdGVcLwpq31RjgcwQdhQwgQwfvVIjq1Jt1jwszZGNq2CYewQa0TfGfnFxbjV5nBsCVF804MhnpI65rZMqWsD4K)jBskXcLGZM1laRxnaUPe3EYibrq6agcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1jwsuTkQM4E)4PbE9hPf5w02cOj3iWfmzrCP6bQojQwfvllvl9SwmxeoaePLRgaFxMKavp(avlNlbl1b867en5)islxnWLQvr1Ys1Ys1l3HyX1laKBrkEkuyiyPoCOAvunX9(XtdC9ca5wKINcfUGjlIlvp(av3qouTkQM4E)4PbMlchasXtHcxWKfXLQ)LQLZLGL6aE9DIM8F0b6CYiRxiwHQLHQ)8HQLLQvtQE5oelUEbGClsXtHcdbl1HdvRIQjU3pEAG5IWbGu8uOWfmzrCP6FPA5CjyPoGxFNOj)hDGoNmY6fIvOAzO6pFOAI79JNgyUiCaifpfkCbtwexQE8bQUHCOAzOAzYMmzfEKnTLFxu4Y58MhXy5rZMqWsD4K)jBskXcLGZM1laRxnaUPe3EYibrq6agcwQdhQwfvtCVF80aZfHdaP4PqHlyYI4s1duDsuTkQwwQwnP6L7qSyi6IM2fc4GHGL6WHQ)8HQLLQxUdXIHOlAAxiGdgcwQdhQwfvp5GXkKLQ)DGQtCjr1Yq1Yq1QOAzPAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQ)LQvpjQwfvl9SwmxeoaePLRgaFxMKavpq1spRfZfHdarA5QbWt(p6UmjbQwgQ(ZhQwwQM4E)4PbE9hPf5w02cOj3iWfmzrCP6bQojQwfvl9SwmxeoaePLRgaFxMKavpq1jr1Yq1Yq1QOAPN1IRxai3Iu8uOWhpnOAvu9KdgRqwQ(3bQwoxcwQdywbnfHy(MOjhmsHSztMScpYM2YVlkC5CEZJKy5rZMqWsD4K)jBskXcLGZM1laRxna(iUeHsxeCLmI4ZjhhmeSuhouTkQM4E)4Pbw6zTOJ4sekDrWvYiIpNCCWfWNKPAvuT0ZAXhXLiu6IGRKreFo54GSLFx8XtdQwfvllvl9SwmxeoaKINcf(4PbvRIQLEwlUEbGClsXtHcF80GQvr1hq6zT41FKwKBrBlGMCJaF80GQLHQvr1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAzPAPN1I5IWbGiTC1a47YKeO6XhOA5CjyPoGxFNOj)hrA5QbUuTkQwwQwwQE5oelUEbGClsXtHcdbl1HdvRIQjU3pEAGRxai3Iu8uOWfmzrCP6XhO6gYHQvr1e37hpnWCr4aqkEku4cMSiUu9VuTCUeSuhWRVt0K)JoqNtgz9cXkuTmu9NpuTSuTAs1l3HyX1laKBrkEkuyiyPoCOAvunX9(XtdmxeoaKINcfUGjlIlv)lvlNlbl1b867en5)Od05KrwVqScvldv)5dvtCVF80aZfHdaP4PqHlyYI4s1Jpq1nKdvldvlt2KjRWJSPT87k59nV5rgR8OztiyPoCY)KnjLyHsWzZ6fG1RgaFexIqPlcUsgr85KJdgcwQdhQwfvtCVF80al9Sw0rCjcLUi4kzeXNtoo4c4tYuTkQw6zT4J4sekDrWvYiIpNCCqwrb4JNguTkQwPa5OgYbRo2w(DL8(MnzYk8iBAffGK68DZBEe1ipA2ecwQdN8pztsjwOeC2K4E)4PbE9hPf5w02cOj3iWfmzrCP6bQojQwfvl9SwmxeoaePLRgaFxMKavp(avlNlbl1b867en5)islxnWLQvr1e37hpnWCr4aqkEku4cMSiUu94duDd5KnzYk8iBofv51f5w061eInV5rs85rZMqWsD4K)jBskXcLGZMe37hpnWCr4aqkEku4cMSiUu9avNevRIQLLQvtQE5oelgIUOPDHaoyiyPoCO6pFOAzP6L7qSyi6IM2fc4GHGL6WHQvr1toySczP6FhO6exsuTmuTmuTkQwwQwwQM4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGzf0K)JoqNtgz9cT(oPAvuT0ZAXCr4aqKwUAa8Dzscu9avl9SwmxeoaePLRgap5)O7YKeOAzO6pFOAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQhO6KOAvuT0ZAXCr4aqKwUAa8Dzscu9avNevldvldvRIQLEwlUEbGClsXtHcF80GQvr1toySczP6FhOA5CjyPoGzf0ueI5BIMCWifYMnzYk8iBofv51f5w061eInV5rsC5rZMqWsD4K)jBskXcLGZMe37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAPN1I5IWbGiTC1a47YKeO6XhOA5CjyPoGxFNOj)hrA5QbUuTkQM4E)4PbMlchasXtHcxWKfXLQhFGQBiNSjtwHhzZdWBRKxbK38ig)8OztiyPoCY)KnjLyHsWztI79JNgyUiCaifpfkCbtwexQEGQtIQvr1Ys1QjvVChIfdrx00UqahmeSuhou9NpuTSu9YDiwmeDrt7cbCWqWsD4q1QO6jhmwHSu9VduDIljQwgQwgQwfvllvllvtCVF80aV(J0IClABb0KBe4cMSiUu9VuT6jr1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1Yq1F(q1Ys1e37hpnWR)iTi3I2wan5gbUGjlIlvpq1jr1QOAPN1I5IWbGiTC1a47YKeO6bQojQwgQwgQwfvl9SwC9ca5wKINcf(4PbvRIQNCWyfYs1)oq1Y5sWsDaZkOPieZ3en5GrkKnBYKv4r28a82k5va5npYyipA2ecwQdN8pztsjwOeC2K4E)4PbE9hPf5w02cOj3iWfmzrCP6FPA5CjyPoGRlAY)rhOZjJSEHwFNuTkQM4E)4PbMlchasXtHcxWKfXLQ)LQLZLGL6aUUOj)hDGoNmY6fIvOAvuTSu9YDiwC9ca5wKINcfgcwQdhQwfvllvtCVF80axVaqUfP4PqHlyYI4s1Jt1WFG8waTIjq1F(q1e37hpnW1laKBrkEku4cMSiUu9VuTCUeSuhW1fn5)Od05KrwVqLRq1Yq1F(q1QjvVChIfxVaqUfP4PqHHGL6WHQLHQvr1spRfZfHdarA5QbW3Ljjq1)s1gJQvr1hq6zT41FKwKBrBlGMCJaF80GQvr1spRfxVaqUfP4PqHpEAq1QOAPN1I5IWbGu8uOWhpnYMmzfEKnl(i4yrxfUsiV5rupP8OztiyPoCY)KnjLyHsWztI79JNg41FKwKBrBlGMCJaxWKfXLQhNQH)a5TaAftGQvr1spRfZfHdarA5QbW3Ljjq1Jpq1Y5sWsDaV(ort(pI0YvdCPAvunX9(XtdmxeoaKINcfUGjlIlvpovllvd)bYBb0kMav)nvZKv4bE9hPf5w02cOj3iWWFG8waTIjq1YKnzYk8iBw8rWXIUkCLqEZJOU65rZMqWsD4K)jBskXcLGZMe37hpnWCr4aqkEku4cMSiUu94un8hiVfqRycuTkQwwQwwQwnP6L7qSyi6IM2fc4GHGL6WHQ)8HQLLQxUdXIHOlAAxiGdgcwQdhQwfvp5GXkKLQ)DGQtCjr1Yq1Yq1QOAzPAzPAI79JNg41FKwKBrBlGMCJaxWKfXLQ)LQLZLGL6aMvqt(p6aDozK1l067KQvr1spRfZfHdarA5QbW3Ljjq1duT0ZAXCr4aqKwUAa8K)JUltsGQLHQ)8HQLLQjU3pEAGx)rArUfTTaAYncCbtwexQEGQtIQvr1spRfZfHdarA5QbW3Ljjq1duDsuTmuTmuTkQw6zT46faYTifpfk8XtdQwfvp5GXkKLQ)DGQLZLGL6aMvqtriMVjAYbJuilvlt2KjRWJSzXhbhl6QWvc5npI6glpA2ecwQdN8pztsjwOeC2u6zTyUiCaislxna(UmjbQE8bQwoxcwQd413jAY)rKwUAGlvRIQjU3pEAG5IWbGu8uOWfmzrCP6XhOA4pqElGwXeYMmzfEKnx)rArUfTTaAYnI8Mhr9elpA2ecwQdN8pztsjwOeC2u6zTyUiCaislxna(UmjbQE8bQwoxcwQd413jAY)rKwUAGlvRIQxUdXIRxai3Iu8uOWqWsD4q1QOAI79JNg46faYTifpfkCbtwexQE8bQg(dK3cOvmbQwfvtCVF80aZfHdaP4PqHlyYI4s1)s1Y5sWsDaV(ort(p6aDozK1leRKnzYk8iBU(J0IClABb0KBe5npI6JvE0SjeSuho5FYMKsSqj4SP0ZAXCr4aqKwUAa8Dzscu94duTCUeSuhWRVt0K)JiTC1axQwfvllvRMu9YDiwC9ca5wKINcfgcwQdhQ(ZhQM4E)4PbUEbGClsXtHcxWKfXLQ)LQLZLGL6aE9DIM8F0b6CYiRxOYvOAzOAvunX9(XtdmxeoaKINcfUGjlIlv)lvlNlbl1b867en5)Od05KrwVqSs2KjRWJS56pslYTOTfqtUrK38iQRg5rZMqWsD4K)jBskXcLGZMe37hpnWR)iTi3I2wan5gbUGjlIlv)lvlNlbl1bmRGM8F0b6CYiRxO13jvRIQLEwlMlchaI0YvdGVltsGQhOAPN1I5IWbGiTC1a4j)hDxMKavRIQLEwlUEbGClsXtHcF80GQvr1toySczP6FhOA5CjyPoGzf0ueI5BIMCWifYMnzYk8iBYfHdaP4PqL38iQN4ZJMnHGL6Wj)t2KuIfkbNnLEwlMlchasXtHcF80GQvr1e37hpnWR)iTi3I2wan5gbUGjlIlv)lvlNlbl1bC5kOj)hDGoNmY6fA9Ds1QOAPN1I5IWbGiTC1a47YKeO6bQw6zTyUiCaislxnaEY)r3Ljjq1QOAzPAI79JNgyUiCaifpfkCbtwexQ(xQwDJr1F(q1hq6zT41FKwKBrBlGMCJa)uOAzYMmzfEKnRxai3Iu8uOYBEe1tC5rZMqWsD4K)jBskXcLGZMspRfZfHdaP4PqHpEAq1QOAI79JNgyUiCaifpfk8wpavWKfXLQ)LQzYk8aFBf2venifpfkm5uuTkQw6zT46faYTifpfk8XtdQwfvtCVF80axVaqUfP4PqH36bOcMSiUu9VuntwHh4BRWUIObP4PqHjNIQvr1hq6zT41FKwKBrBlGMCJaF80iBYKv4r282kSRiAqkEku5npI6g)8OztiyPoCY)KnjLyHsWzZL7qS46faYTifpfkmeSuhouTkQw6zTyUiCaifpfk8tHQvr1spRfxVaqUfP4PqHlyYI4s1Jt1nKdEY)ZMmzfEKnvk4cbbqUfnfXjV5ruFmKhnBcbl1Ht(NSjPelucoBEaPN1Ix)rArUfTTaAYnc8tHQvr1hq6zT41FKwKBrBlGMCJaxWKfXLQhNQzYk8aZfHdanf3ROdxm8hiVfqRycuTkQwnPAIlhcowCcjxcoYMmzfEKnvk4cbbqUfnfXjV5rmws5rZMqWsD4K)jBskXcLGZMspRfxVaqUfP4PqHFkuTkQw6zT46faYTifpfkCbtwexQECQUHCWt(pvRIQjU3pEAGb5oHxHh4c4tYuTkQwnPAIlhcowCcjxcoYMmzfEKnvk4cbbqUfnfXjV5nBAfb3rsVkYJMhr98OztiyPoCY)KnzYk8iBYfHdanf3ROd3SjPLfr2u9SjPelucoBk9SwmPdCr47kIgCbmzZBEeJLhnBYKv4r2KlchasQZ3nBcbl1Ht(N8MhjXYJMnzYk8iBYfHdajXvXnq2ecwQdN8p5nV5nBkhQRWJ8igljJLK6glj1ZMPCfIO5MnhJn2y8CKXSrgJQwunvpAlq1IPIxlvB9IQnYvGakJO6cgtprbhQ(6tGQ536tEHdvtA5ObUyQbQTiaQwD1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlR6)LbtnqTfbq1QRwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzn2FzWuduBrauTXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSQ)xgm1a1weavNyQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQhl1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevZlvB8EmUAt1YQ(FzWuduBrauT6jPwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzn2FzWuduBrauT6jo1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlR6)LbtnqTfbq1glj1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1glj1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevZlvB8EmUAt1YQ(FzWuduBrauTXmMAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgqnym2yJXZrgZgzmQAr1u9OTavlMkETuT1lQ2i2bJO6cgtprbhQ(6tGQ536tEHdvtA5ObUyQbQTiaQwD1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlRX(ldMAGAlcGQvxTOAJZd5qTWHQnQEby9QbWjYiQEDQ2O6fG1RgaNimeSuhogr1YQ(FzWuduBrauTXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSg7VmyQbQTiaQoXulQ248qoulCOAJwUdXItKru96uTrl3HyXjcdbl1HJruTSg7VmyQbQTiaQoXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSQ)xgm1a1weavpwQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQvd1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1jE1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1jo1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1gF1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1Jb1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlRX(ldMAGAlcGQvpj1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlRX(ldMAGAlcGQvpXulQ248qoulCOAJwUdXItKru96uTrl3HyXjcdbl1HJruTSg7VmyQbQTiaQw9eNAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgO2IaOA1hdQfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQww1)ldMAGAlcGQvFmOwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzv)VmyQbQTiaQ2yJLAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgO2IaOAJnwQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQnMAOwuTX5HCOw4q1gTChIfNiJO61PAJwUdXItegcwQdhJOAzv)VmyQbQTiaQ2yQHAr1gNhYHAHdvBu9cW6vdGtKru96uTr1laRxnaoryiyPoCmIQLv9)YGPgqnym2yJXZrgZgzmQAr1u9OTavlMkETuT1lQ2OYxEfEyevxWy6jk4q1xFcun)wFYlCOAslhnWftnqTfbq1QRwuTX5HCOw4q1gTChIfNiJO61PAJwUdXItegcwQdhJOAzv)VmyQbQTiaQ2yQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQhl1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlR6)LbtnqTfbq1QHAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgO2IaO6XGAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgO2IaOA1hdQfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQww1)ldMAGAlcGQnwIPwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzv)VmyQbQTiaQ2yJLAr1gNhYHAHdvBu9cW6vdGtKru96uTr1laRxnaoryiyPoCmIQLv9)YGPgqnym2yJXZrgZgzmQAr1u9OTavlMkETuT1lQ2Ody5xFnIQlym9efCO6RpbQMFRp5founPLJg4IPgO2IaOAJPwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzn2FzWuduBrauDIPwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzn2FzWuduBrau9yPwuTX5HCOw4q1MIPXr13KJL)t1gpMQxNQv7ht1hHCXv4bv7kqXRxuTSFjdvlR6)LbtnGAWySXgJNJmMnYyu1IQP6rBbQwmv8APARxuTrkfq8PeVgr1fmMEIcou91NavZV1N8chQM0YrdCXuduBrauTXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSQ)xgm1a1weavNyQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQvFSulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJrunVuTX7X4QnvlR6)LbtnqTfbq1QN4vlQ248qoulCOAJiECEIfNiJO61PAJiECEIfNimeSuhogr1YQ(FzWuduBrauTXsm1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevZlvB8EmUAt1YQ(FzWuduBrauTXgl1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevZlvB8EmUAt1YQ(FzWuduBrauTXm(QfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQwwJ9xgm1a1weavBmJVAr1gNhYHAHdvBu9cW6vdGtKru96uTr1laRxnaoryiyPoCmIQLv9)YGPgO2IaO6XYyQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQMxQ249yC1MQLv9)YGPgO2IaO6XkXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJrunVuTX7X4QnvlR6)LbtnGAWySXgJNJmMnYyu1IQP6rBbQwmv8APARxuTre37hpnUgr1fmMEIcou91NavZV1N8chQM0YrdCXuduBrauT6QfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQwwJ9xgm1a1weavRUAr1gNhYHAHdvBu9cW6vdGtKru96uTr1laRxnaoryiyPoCmIQLv9)YGPgO2IaOAJPwuTX5HCOw4q1gTChIfNiJO61PAJwUdXItegcwQdhJOAzn2FzWuduBrauTXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSQ)xgm1a1weavNyQfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQwwJ9xgm1a1weavNyQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAGAlcGQhl1IQnopKd1chQ2O6fG1RgaNiJO61PAJQxawVAaCIWqWsD4yevlR6)LbtnqTfbq1jE1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlRX(ldMAGAlcGQn(QfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQwwJ9xgm1a1weavpgulQ248qoulCOAJwUdXItKru96uTrl3HyXjcdbl1HJruTSg7VmyQbQTiaQwD1vlQ248qoulCOAJwUdXItKru96uTrl3HyXjcdbl1HJruTSg7VmyQbQTiaQw9etTOAJZd5qTWHQnA5oelorgr1Rt1gTChIfNimeSuhogr1YQ(FzWuduBrauT6JLAr1gNhYHAHdvB0YDiwCImIQxNQnA5oeloryiyPoCmIQLv9)YGPgO2IaOA1n(QfvBCEihQfouTrl3HyXjYiQEDQ2OL7qS4eHHGL6WXiQww1)ldMAa1GXyJngphzmBKXOQfvt1J2cuTyQ41s1wVOAJUTCbhe5CnIQlym9efCO6RpbQMFRp5founPLJg4IPgO2IaOA1vlQ248qoulCOAJwUdXItKru96uTrl3HyXjcdbl1HJruTSg7VmyQbQTiaQoXulQ248qoulCOAJQxawVAaCImIQxNQnQEby9QbWjcdbl1HJruTSQ)xgm1a1weavREIPwuTX5HCOw4q1gvVaSE1a4ezevVovBu9cW6vdGtegcwQdhJOAzv)VmyQbQTiaQw9XsTOAJZd5qTWHQnQEby9QbWjYiQEDQ2O6fG1RgaNimeSuhogr1YQ(FzWuduBrauT6QHAr1gNhYHAHdvBu9cW6vdGtKru96uTr1laRxnaoryiyPoCmIQLv9)YGPgO2IaOA1tCQfvBCEihQfouTr1laRxnaorgr1Rt1gvVaSE1a4eHHGL6WXiQww1)ldMAa1GXyJngphzmBKXOQfvt1J2cuTyQ41s1wVOAJ4j6QWtJO6cgtprbhQ(6tGQ536tEHdvtA5ObUyQbQTiaQwD1IQnopKd1chQ2OL7qS4ezevVovB0YDiwCIWqWsD4yevlR6)LbtnGAWy2uXRfouT6jr1mzfEq1DXDVyQbzt(TTELnnfZxNxHhgxX2nBQuUv0HS5yNQnEn3au9ytr4aOgm2PAJxbeykbfvN4nKQnwsgljQbudg7uTXty6YbQwoxcwQdyEIUk8KQfbvBz5Er1ULQVWUIO5I5j6QWtQwwslqsGQt2FfvFvacv7kRWJRmyQbJDQEmx5WlCOArSqfCNQB540frdv7wQwoxcwQd4wwoGCfiGdvVovlbuT6uDAleu9f2venxmprxfEs1duT6yQbJDQEm)cu9MSIGWDQ2umnoQULJtxenuTBPAslhb0PArSqvpLv4bvlI7c8HQDlvBeHdc0rmzfEyeMAWyNQnEFVqqGlvxW0LdhQMVuTBP6rC5WuckQ2ygFQEDQUGZJauTXz8OXCQw2Bx00U9KLbtnGAatwHhxSsbeFkX7GCUeSuhmm4jmOuGYR3rGC3qxzOGlSgEal)67qsudyYk84IvkG4tjE)E4l5CjyPoyyWtyqPaLxVJa5UHUYWfwdLZ9hmOUHc7GCUeSuhWkfO86Dei3hssv9cW6vdGVcLwpq31RPkMSc5accykG7VgJAatwHhxSsbeFkX73dFjNlbl1bddEcdkfO86Dei3n0vgUWAOCU)Gb1nuyhKZLGL6awPaLxVJa5(qsQQxawVAa8vO06b6UEnvrC5qWXIdGuE3RJkMSc5accykG7VQtnGjRWJlwPaIpL497HVKZLGL6GHbpHHwwoGCfiGJHUYWfwdLZ9hmKe1aMScpUyLci(uI3Vh(soxcwQdgg8egAz5aYvGaog6kdxynuo3FWG6gkSdY5sWsDa3YYbKRabCgssftwHCabbmfW9xJrnGjRWJlwPaIpL497HVKZLGL6GHbpHHwwoGCfiGJHUYWfwdLZ9hmOUHc7GCUeSuhWTSCa5kqaNHKujNlbl1bSsbkVEhbY9b1PgWKv4XfRuaXNs8(9WxY5sWsDWWGNWGveChj9QWqxz4cRHY5(dgsIAatwHhxSsbeFkX73dFjNlbl1bddEcd1fn5)Od05KrwVqRVtdDLHcUWA4bS8RVdQb1aMScpUyLci(uI3Vh(soxcwQdgg8egQlAY)rhOZjJSEHkxXqxzOGlSgEal)67GAqnGjRWJlwPaIpL497HVKZLGL6GHbpHH6IM8F0b6CYiRxiwXqxzOGlSgEal)67GXsIAatwHhxSsbeFkX73dFjNlbl1bddEcdScAY)rhOZjJSEHwFNg6kdfCH1Wdy5xFhupjQbmzfECXkfq8PeVFp8LCUeSuhmm4jmuUcAY)rhOZjJSEHwFNg6kdfCH1Wdy5xFhmwsudyYk84IvkG4tjE)E4l5CjyPoyyWtyy9DIM8F0b6CYiRxiwXqxzOGlSgEal)67qsudyYk84IvkG4tjE)E4l5CjyPoyyWtyy9DIM8F0b6CYiRxiwXqxz4cRHY5(dgsmdf2b5CjyPoGxFNOj)hDGoNmY6fIvgssv9cW6vdGpIlrO0fbxjJi(CYXHAatwHhxSsbeFkX73dFjNlbl1bddEcdRVt0K)JoqNtgz9cXkg6kdxynuo3FWG6QHHc7GCUeSuhWRVt0K)JoqNtgz9cXkdjPI4YHGJfhIM2fzzGAatwHhxSsbeFkX73dFjNlbl1bddEcdRVt0K)JoqNtgz9cXkg6kdxynuo3FWG6QHHc7GCUeSuhWRVt0K)JoqNtgz9cXkdjPI4X5jwmxeoaKs5hrtYQyYkKdiiGPaUJNyudyYk84IvkG4tjE)E4l5CjyPoyyWtyy9DIM8F0b6CYiRxiwXqxz4cRHY5(dguddf2b5CjyPoGxFNOj)hDGoNmY6fIvgsIAatwHhxSsbeFkX73dFjNlbl1bddEcdRVt0K)JoqNtgz9cvUIHUYqbxyn8aw(13bJLe1aMScpUyLci(uI3Vh(soxcwQdgg8egK4Q4gan5GrkK1qxzOGlSgEal)67qsudyYk84IvkG4tjE)E4l5CjyPoyyWtyqIRIBa0KdgPqwdDLHlSgkN7pyq2eFsgpi7KVlujJKZ9hm2QEsjjJmgkSdY5sWsDalXvXnaAYbJui7qsQiUCi4yXHOPDrwgOgWKv4XfRuaXNs8(9WxY5sWsDWWGNWGexf3aOjhmsHSg6kdxynuo3FWGSg)KmEq2jFxOsgjN7pySv9KssgzmuyhKZLGL6awIRIBa0KdgPq2HKOgWKv4XfRuaXNs8(9WxY5sWsDWWGNWaRGMIqmFt0KdgPqwdDLHcUWA4bS8RVdjrnGjRWJlwPaIpL497HVKZLGL6GHbpHbwbnfHy(MOjhmsHSg6kdxynuo3FWGAKKHc7GCUeSuhWScAkcX8nrtoyKczhssv9cW6vdGpIlrO0fbxjJi(CYXHAatwHhxSsbeFkX73dFjNlbl1bddEcdScAkcX8nrtoyKczn0vgUWAOCU)Gb1ijdf2b5CjyPoGzf0ueI5BIMCWifYoKKQ6fG1Rga3uIBpzKGiiDGAatwHhxSsbeFkX73dFjNlbl1bddEcdScAkcX8nrtoyKczn0vgUWAOCU)Gb1vddf2b5CjyPoGzf0ueI5BIMCWifYoKe1aMScpUyLci(uI3Vh(soxcwQdgg8egwFNOj)hrA5QbUg6kdfCH1Wdy5xFhmg1aMScpUyLci(uI3Vh(soxcwQdgg8egeHCOw4GCfiGYqxzOGlSgEal)67qsudyYk84IvkG4tjE)E4l5CjyPoyyWtyqeYHAHdYvGakdDLHlSgkN7pyqDdf2b5CjyPoGfHCOw4GCfiGAijvl3HyX1laKBrkEkuQKD5oelMlchaciT(NpQjXLdbhloHKlbhYOsw1K4YHGJfhaP8UxNpFyYkKdiiGPaUdQ)5t9cW6vdGVcLwpq31RPmudyYk84IvkG4tjE)E4l5CjyPoyyWtyqeYHAHdYvGakdDLHlSgkN7pyijdf2b5CjyPoGfHCOw4GCfiGAijQbmzfECXkfq8PeVFp8LCUeSuhmm4jmWkipqVlyORmCH1q5C)bdWy6juuGdEYewQa0TfGfnFxb5Zhym9ekkWb305JGxVUij(0aF(aJPNqrbo4MoFe861fnHd37cp(8bgtpHIcCWhUsy6EGoajbKYBl4sGGaF(aJPNqrboyrCj1BzPoGgtpo23eDa5cc85dmMEcff4GV(R3HDfrdQEsj)5dmMEcff4GVVqQ7(bXtyBt(UF(aJPNqrbo4uobiG6ISLhNpFGX0tOOahSTZta5wKeVBhOgWKv4XfRuaXNs8(9WxY5sWsDWWGNWa7aA9DIM8FePLRg4AORmuWfwdpGLF9DWyudyYk84IvkG4tjE)E4l5CjyPoyyWtyOLLdixbc4yORmCH1q5C)bdQBOWoiNlbl1bCllhqUceWzijvxyxr0CX8eDv45G6udyYk84IvkG4tjE)E4l5CjyPoyyWtyaK7ifYAORmuWfwdpGLF9DqD1GAatwHhxSsbeFkX73dFz78nbQbmzfECXkfq8PeVFp8L19d1aMScpUyLci(uI3Vh(IFntiwEfEqnGjRWJlwPaIpL497HV4IWbGS8u0fCrnGjRWJlwPaIpL497HV4IWbGeXc9oqwQbmzfECXkfq8PeVFp8fXdJxEfGMCWOgysnGjRWJlwPaIpL497HVUbRCB9fDxEVudyYk84IvkG4tjE)E4RPOkVqIj3audyYk84IvkG4tjE)E4lB53vY7RHc7GAkNlbl1bSsbkVEhbY9b1vvVaSE1a4J4sekDrWvYiIpNCCOgWKv4XfRuaXNs8(9WxCr4aqsD(UgkSdQPCUeSuhWkfO86Dei3huxLAwVaSE1a4J4sekDrWvYiIpNCCOgWKv4XfRuaXNs8(9WxGCNWRWddf2b5CjyPoGvkq517iqUpOo1aQbmzfEC)E4lI)IfQRc07gkSdlxnWIpG0ZAXe(UIObxatwQbmzfEC)E4l5CjyPoyyWtyOLLdixbc4yORmCH1q5C)bdQBOWoiNlbl1bCllhqUceWzijvkfih1qoy1XGCNWRWdvQPS1laRxna(kuA9aDxVMF(uVaSE1a4fMkEXDukxkYqnGjRWJ73dFjNlbl1bddEcdTSCa5kqahdDLHlSgkN7pyqDdf2b5CjyPoGBz5aYvGaodjPs6zTyUiCaifpfk8Xtdve37hpnWCr4aqkEku4cMSiUQKTEby9QbWxHsRhO7618ZN6fG1RgaVWuXlUJs5srgQbmzfEC)E4l5CjyPoyyWtyWkcUJKEvyORmCH1q5C)bdQBOWoi9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsqLAk9SwC96aYTOTTa4IFkQSIM2fvWKfXD8bzLDYbB8yMScpWCr4aqsD(UyIFxzgBzYk8aZfHdaj157IH)a5TaAftqgQbmzfEC)E4lc37iMScpqDXDnm4jmCB5coiY5snGjRWJ73dFr4EhXKv4bQlURHbpHb2bdf2bMSc5accykG7VgJAatwHh3Vh(IW9oIjRWduxCxddEcdUceqzOWoiNlbl1bCllhqUceWzijQbmzfEC)E4lc37iMScpqDXDnm4jmWt0vHNgkSdxyxr0CX8eDv45G6udyYk84(9WxeU3rmzfEG6I7AyWtyG4E)4PXLAatwHh3Vh(IW9oIjRWduxCxddEcdLV8k8WqHDqoxcwQdyRi4os6vXqsudyYk84(9WxeU3rmzfEG6I7AyWtyWkcUJKEvyOWoiNlbl1bSveChj9QyqDQbmzfEC)E4lc37iMScpqDXDnm4jmmD5WeILAa1GXovZKv4XfZt0vHNdeoiqhXKv4HHc7atwHhyqUt4v4bM0YraDr0OAYbJvi7VdJb1GAatwHhxmprxfE(9WxGCNWRWddf2HjhmwHSJpiNlbl1bmi3rkKvLSe37hpnWR)iTi3I2wan5gbUGjlI74dmzfEGb5oHxHhy4pqElGwXe(8H4E)4PbMlchasXtHcxWKfXD8bMScpWGCNWRWdm8hiVfqRycF(i7YDiwC9ca5wKINcLkI79JNg46faYTifpfkCbtwe3XhyYk8adYDcVcpWWFG8waTIjiJmQKEwlUEbGClsXtHcF80qL0ZAXCr4aqkEku4JNgQoG0ZAXR)iTi3I2wan5gb(4Pb1aMScpUyEIUk887HVoaVTsEfGHc7aX9(XtdmxeoaKINcfUGjlI7qsQKv6zT46faYTifpfk8XtdvYsCVF80aV(J0IClABb0KBe4cMSiU)kNlbl1bmRGM8F0b6CYiRxO135Npe37hpnWR)iTi3I2wan5gbUGjlI7qsYid1aMScpUyEIUk887HVMIQ86IClA9AcXAOWoqCVF80aZfHdaP4PqHlyYI4oKKkzLEwlUEbGClsXtHcF80qLSe37hpnWR)iTi3I2wan5gbUGjlI7VY5sWsDaZkOj)hDGoNmY6fA9D(5dX9(Xtd86pslYTOTfqtUrGlyYI4oKKmYqnGjRWJlMNORcp)E4RIpcow0vHReOgWKv4XfZt0vHNFp81Tvyxr0Gu8uOmuyhKEwlMlchasXtHcF80qfX9(XtdmxeoaKINcfERhGkyYI4(ltwHh4BRWUIObP4PqHjNsL0ZAX1laKBrkEku4JNgQiU3pEAGRxai3Iu8uOWB9aubtwe3FzYk8aFBf2venifpfkm5uQoG0ZAXR)iTi3I2wan5gb(4Pb1aMScpUyEIUk887HVQxai3Iu8uOmuyhKEwlUEbGClsXtHcF80qfX9(XtdmxeoaKINcfUGjlIl1aMScpUyEIUk887HVw)rArUfTTaAYncdf2bzjU3pEAG5IWbGu8uOWfmzrChssL0ZAX1laKBrkEku4JNgY85JsbYrnKdwDC9ca5wKINcf1aMScpUyEIUk887HVw)rArUfTTaAYncdf2bI79JNgyUiCaifpfkCbtwe3XvJKuj9SwC9ca5wKINcf(4PHk4EHGay5IRWdKBrkqzbYk8adbl1Hd1aMScpUyEIUk887HV4IWbGu8uOmuyhKEwlUEbGClsXtHcF80qfX9(Xtd86pslYTOTfqtUrGlyYI4(RCUeSuhWScAY)rhOZjJSEHwFNudyYk84I5j6QWZVh(IlchasIRIBadf2bPN1I5IWbGu8uOWpfvspRfZfHdaP4PqHlyYI4o(atwHhyUiCaOP4EfD4IH)a5TaAftqL0ZAXCr4aqKwUAa8DzscdspRfZfHdarA5QbWt(p6UmjbQbmzfECX8eDv453dFXfHda5LKHc7G0ZAXCr4aqKwUAa8DzscJl9SwmxeoaePLRgap5)O7YKeuj9SwC9ca5wKINcf(4PHkPN1I5IWbGu8uOWhpnuDaPN1Ix)rArUfTTaAYnc8XtdQbmzfECX8eDv453dFXfHdajXvXnGHc7G0ZAX1laKBrkEku4JNgQKEwlMlchasXtHcF80q1bKEwlE9hPf5w02cOj3iWhpnuj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsGAatwHhxmprxfE(9WxCr4aqtX9k6W1qHDq6zTysh4IW3ven4cyYAiPLfXG6gcC1tgrAzrGe2bPN1IjDGlcFxr0GiTCeqhF80qLSspRfZfHdaP4PqHFkF(i9SwC9ca5wKINcf(P85dX9(Xtdmi3j8k8axaFswgQbmzfECX8eDv453dFXfHdanf3ROdxdf2b1KhJaLybmxeoaKYBoHUiAWqWsD485J0ZAXKoWfHVRiAqKwocOJpEAyiPLfXG6gcC1tgrAzrGe2bPN1IjDGlcFxr0GiTCeqhF80qLSspRfZfHdaP4PqHFkF(i9SwC9ca5wKINcf(P85dX9(Xtdmi3j8k8axaFswgQbmzfECX8eDv453dFbYDcVcpmuyhKEwlUEbGClsXtHcF80qL0ZAXCr4aqkEku4JNgQoG0ZAXR)iTi3I2wan5gb(4Pb1aMScpUyEIUk887HV4IWbG8sYqHDq6zTyUiCaislxna(UmjHXLEwlMlchaI0YvdGN8F0DzscudyYk84I5j6QWZVh(IlchasIRIBaQbmzfECX8eDv453dFXfHdaj157snGAatwHhxm7WGT87k591qHDOEby9QbWhXLiu6IGRKreFo54OI4E)4Pbw6zTOJ4sekDrWvYiIpNCCWfWNKvj9Sw8rCjcLUi4kzeXNtooiB53fF80qLSspRfZfHdaP4PqHpEAOs6zT46faYTifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80qgve37hpnWR)iTi3I2wan5gbUGjlI7qsQKv6zTyUiCaislxna(UmjHXhKZLGL6aMDaT(ort(pI0YvdCvjRSl3HyX1laKBrkEkuQiU3pEAGRxai3Iu8uOWfmzrChFOHCurCVF80aZfHdaP4PqHlyYI4(RCUeSuhWRVt0K)JoqNtgz9cXkY85JSQ5YDiwC9ca5wKINcLkI79JNgyUiCaifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxiwrMpFiU3pEAG5IWbGu8uOWfmzrChFOHCKrgQbmzfECXSdFp8LvuasQZ31qHDq26fG1RgaFexIqPlcUsgr85KJJkI79JNgyPN1IoIlrO0fbxjJi(CYXbxaFswL0ZAXhXLiu6IGRKreFo54GSIcWhpnuPuGCud5GvhBl)UsEFL5ZhzRxawVAa8rCjcLUi4kzeXNtooQwXegssgQbmzfECXSdFp8LT87IcxoBOWouVaSE1a4MsC7jJeebPdQiU3pEAG5IWbGu8uOWfmzrC)nXssfX9(Xtd86pslYTOTfqtUrGlyYI4oKKkzLEwlMlchaI0YvdGVltsy8b5CjyPoGzhqRVt0K)JiTC1axvYk7YDiwC9ca5wKINcLkI79JNg46faYTifpfkCbtwe3XhAihve37hpnWCr4aqkEku4cMSiU)kNlbl1b867en5)Od05KrwVqSImF(iRAUChIfxVaqUfP4PqPI4E)4PbMlchasXtHcxWKfX9x5CjyPoGxFNOj)hDGoNmY6fIvK5ZhI79JNgyUiCaifpfkCbtwe3XhAihzKHAatwHhxm7W3dFzl)UOWLZgkSd1laRxnaUPe3EYibrq6GkI79JNgyUiCaifpfkCbtwe3HKujRSYsCVF80aV(J0IClABb0KBe4cMSiU)kNlbl1bmRGM8F0b6CYiRxO13PkPN1I5IWbGiTC1a47YKegKEwlMlchaI0YvdGN8F0DzscY85JSe37hpnWR)iTi3I2wan5gbUGjlI7qsQKEwlMlchaI0YvdGVltsy8b5CjyPoGzhqRVt0K)JiTC1axzKrL0ZAX1laKBrkEku4JNgYqnGjRWJlMD47HVw)rArUfTTaAYncdf2H6fG1RgaFfkTEGURxtvkfih1qoy1XGCNWRWdQbmzfECXSdFp8fxeoaKINcLHc7q9cW6vdGVcLwpq31RPkzvkqoQHCWQJb5oHxHhF(OuGCud5GvhV(J0IClABb0KBeYqnGjRWJlMD47HVa5oHxHhgkSdRyc)MyjPQEby9QbWxHsRhO761uL0ZAXCr4aqKwUAa8DzscJpiNlbl1bm7aA9DIM8FePLRg4QI4E)4PbE9hPf5w02cOj3iWfmzrChssfX9(XtdmxeoaKINcfUGjlI74dnKd1aMScpUy2HVh(cK7eEfEyOWoSIj8BILKQ6fG1RgaFfkTEGURxtve37hpnWCr4aqkEku4cMSiUdjPswzLL4E)4PbE9hPf5w02cOj3iWfmzrC)voxcwQdywbn5)Od05KrwVqRVtvspRfZfHdarA5QbW3Ljjmi9SwmxeoaePLRgap5)O7YKeK5ZhzjU3pEAGx)rArUfTTaAYncCbtwe3HKuj9SwmxeoaePLRgaFxMKW4dY5sWsDaZoGwFNOj)hrA5QbUYiJkPN1IRxai3Iu8uOWhpnKXqrSqvpLfjSdspRfFfkTEGURxt8DzscdspRfFfkTEGURxt8K)JUltsWqrSqvpLfjMt4i4fguNAatwHhxm7W3dFnfv51f5w061eI1qHDqwI79JNgyUiCaifpfkCbtwe3Fhl14ZhI79JNgyUiCaifpfkCbtwe3XhsmzurCVF80aV(J0IClABb0KBe4cMSiUdjPswPN1I5IWbGiTC1a47YKegFqoxcwQdy2b067en5)islxnWvLSYUChIfxVaqUfP4PqPI4E)4PbUEbGClsXtHcxWKfXD8HgYrfX9(XtdmxeoaKINcfUGjlI7VQHmF(iRAUChIfxVaqUfP4PqPI4E)4PbMlchasXtHcxWKfX9x1qMpFiU3pEAG5IWbGu8uOWfmzrChFOHCKrgQbmzfECXSdFp8vXhbhl6QWvcgkSde37hpnWR)iTi3I2wan5gbUGjlI74WFG8waTIjOswPN1I5IWbGiTC1a47YKegFqoxcwQdy2b067en5)islxnWvLSYUChIfxVaqUfP4PqPI4E)4PbUEbGClsXtHcxWKfXD8HgYrfX9(XtdmxeoaKINcfUGjlI7VY5sWsDaV(ort(p6aDozK1leRiZNpYQMl3HyX1laKBrkEkuQiU3pEAG5IWbGu8uOWfmzrC)voxcwQd413jAY)rhOZjJSEHyfz(8H4E)4PbMlchasXtHcxWKfXD8HgYrgzOgWKv4XfZo89WxfFeCSORcxjyOWoqCVF80aZfHdaP4PqHlyYI4oo8hiVfqRycQKvwzjU3pEAGx)rArUfTTaAYncCbtwe3FLZLGL6aMvqt(p6aDozK1l067uL0ZAXCr4aqKwUAa8DzscdspRfZfHdarA5QbWt(p6Umjbz(8rwI79JNg41FKwKBrBlGMCJaxWKfXDijvspRfZfHdarA5QbW3Ljjm(GCUeSuhWSdO13jAY)rKwUAGRmYOs6zT46faYTifpfk8XtdzOgWKv4XfZo89WxhG3wjVcWqHDG4E)4PbMlchasXtHcxWKfXDijvYkRSe37hpnWR)iTi3I2wan5gbUGjlI7VY5sWsDaZkOj)hDGoNmY6fA9DQs6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGmF(ilX9(Xtd86pslYTOTfqtUrGlyYI4oKKkPN1I5IWbGiTC1a47YKegFqoxcwQdy2b067en5)islxnWvgzuj9SwC9ca5wKINcf(4PHmudyYk84Izh(E4R1FKwKBrBlGMCJWqHDq6zTyUiCaislxna(UmjHXhKZLGL6aMDaT(ort(pI0YvdCvjRSl3HyX1laKBrkEkuQiU3pEAGRxai3Iu8uOWfmzrChFOHCurCVF80aZfHdaP4PqHlyYI4(RCUeSuhWRVt0K)JoqNtgz9cXkY85JSQ5YDiwC9ca5wKINcLkI79JNgyUiCaifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxiwrMpFiU3pEAG5IWbGu8uOWfmzrChFOHCKHAatwHhxm7W3dFXfHdaP4PqzOWoiRSe37hpnWR)iTi3I2wan5gbUGjlI7VY5sWsDaZkOj)hDGoNmY6fA9DQs6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGmF(ilX9(Xtd86pslYTOTfqtUrGlyYI4oKKkPN1I5IWbGiTC1a47YKegFqoxcwQdy2b067en5)islxnWvgzuj9SwC9ca5wKINcf(4Pb1aMScpUy2HVh(QEbGClsXtHYqHDq6zT46faYTifpfk8XtdvYklX9(Xtd86pslYTOTfqtUrGlyYI4(RXssL0ZAXCr4aqKwUAa8DzscdspRfZfHdarA5QbWt(p6Umjbz(8rwI79JNg41FKwKBrBlGMCJaxWKfXDijvspRfZfHdarA5QbW3Ljjm(GCUeSuhWSdO13jAY)rKwUAGRmYOswI79JNgyUiCaifpfkCbtwe3Fv3yF(CaPN1Ix)rArUfTTaAYnc8trgQbmzfECXSdFp81Tvyxr0Gu8uOmuyhiU3pEAG5IWbG8scxWKfX9x1GAatwHhxm7W3dFDBf2venifpfkdf2b1C5oelMlchaYljvspRfZfHdaP4PqHpEAOs6zT46faYTifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80GAatwHhxm7W3dFPuWfccGClAkIJHc7G0ZAXhG3wjVca)uuDaPN1Ix)rArUfTTaAYnc8tr1bKEwlE9hPf5w02cOj3iWfmzrChFq6zTyLcUqqaKBrtrCWt(p6UmjHXwMScpWCr4aqsD(Uy4pqElGwXeOgWKv4XfZo89WxCr4aqsD(UgkSdspRfFaEBL8ka8trLSYUChIfxW1doiGkMSc5accykG74JLmF(WKvihqqatbChxnKrLSQz9cW6vdG5IWbGK8PexNje7NplxnWIBbUVTyfY(BIPgYqnGjRWJlMD47HVUpfOcxotnGjRWJlMD47HV4IWbGK4Q4gWqHDq6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKa1aMScpUy2HVh(IlchaYljdf2bPN1I5IWbGiTC1a47YKegsIAatwHhxm7W3dFfW2cfAHPcCxdf2bzlWwWTLL6WNpQ5kijiIgzuj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsGAatwHhxm7W3dFXfHdanf3ROdxdf2bPN1IjDGlcFxr0GlGjRQ6fG1RgaZfHdajcRieBYQwUdXI5PsxyfeEfEOIjRqoGGaMc4oUXNAatwHhxm7W3dFXfHdanf3ROdxdf2bPN1IjDGlcFxr0GlGjRkzRxawVAamxeoaKiSIqSj)5ZYDiwmpv6cRGWRWdzuXKvihqqatbChxnOgWKv4XfZo89WxCr4aqWFLUFfEyOWoi9SwmxeoaePLRgaFxMKW4spRfZfHdarA5QbWt(p6UmjbQbmzfECXSdFp8fxeoae8xP7xHhgkSdspRfZfHdarA5QbW3Ljjmi9SwmxeoaePLRgap5)O7YKeuPuGCud5GvhZfHdajXvXna1aMScpUy2HVh(cK7eEfEyOiwOQNYIe2HjhmwHS)oy8vddfXcv9uwKyoHJGxyqDQbudg7uTXJkHxIvmgbO63venuDtjU9KPAbrq6avNk2wQMvWu9y(fOAXs1PITLQxFNuTVTqLkUaMAatwHhxmX9(XtJ7GT87IcxoBOWouVaSE1a4MsC7jJeebPdQiU3pEAG5IWbGu8uOWfmzrC)nXssfX9(Xtd86pslYTOTfqtUrGlyYI4oKKkzLEwlMlchaI0YvdGVltsy8b5CjyPoGxFNOj)hrA5QbUQKv2L7qS46faYTifpfkve37hpnW1laKBrkEku4cMSiUJp0qoQiU3pEAG5IWbGu8uOWfmzrC)voxcwQd413jAY)rhOZjJSEHyfz(8rw1C5oelUEbGClsXtHsfX9(XtdmxeoaKINcfUGjlI7VY5sWsDaV(ort(p6aDozK1leRiZNpe37hpnWCr4aqkEku4cMSiUJp0qoYid1aMScpUyI79JNg3Vh(Yw(DrHlNnuyhQxawVAaCtjU9KrcIG0bve37hpnWCr4aqkEku4cMSiUdjPsw1C5oelgIUOPDHaoF(i7YDiwmeDrt7cbCun5GXkK93HexsYiJkzLL4E)4PbE9hPf5w02cOj3iWfmzrC)v9Kuj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsqMpFKL4E)4PbE9hPf5w02cOj3iWfmzrChssL0ZAXCr4aqKwUAa8DzscdjjJmQKEwlUEbGClsXtHcF80q1KdgRq2FhKZLGL6aMvqtriMVjAYbJuil1aMScpUyI79JNg3Vh(Yw(DL8(AOWouVaSE1a4J4sekDrWvYiIpNCCurCVF80al9Sw0rCjcLUi4kzeXNtoo4c4tYQKEwl(iUeHsxeCLmI4ZjhhKT87IpEAOswPN1I5IWbGu8uOWhpnuj9SwC9ca5wKINcf(4PHQdi9Sw86pslYTOTfqtUrGpEAiJkI79JNg41FKwKBrBlGMCJaxWKfXDijvYk9SwmxeoaePLRgaFxMKW4dY5sWsDaV(ort(pI0YvdCvjRSl3HyX1laKBrkEkuQiU3pEAGRxai3Iu8uOWfmzrChFOHCurCVF80aZfHdaP4PqHlyYI4(RCUeSuhWRVt0K)JoqNtgz9cXkY85JSQ5YDiwC9ca5wKINcLkI79JNgyUiCaifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxiwrMpFiU3pEAG5IWbGu8uOWfmzrChFOHCKrgQbmzfECXe37hpnUFp8LvuasQZ31qHDOEby9QbWhXLiu6IGRKreFo54OI4E)4Pbw6zTOJ4sekDrWvYiIpNCCWfWNKvj9Sw8rCjcLUi4kzeXNtooiROa8Xtdvkfih1qoy1X2YVRK3xQbJDQESPNYjFP63fO6POkVUuDQyBPAwbt1JzwQE9Ds1IlvxaFsMQ5lvNc9UHu9KtaO67RaQEDQMW3LQflvlbwVaQE9DIPgWKv4XftCVF804(9WxtrvEDrUfTEnHynuyhiU3pEAGx)rArUfTTaAYncCbtwe3HKuj9SwmxeoaePLRgaFxMKW4dY5sWsDaV(ort(pI0YvdCvrCVF80aZfHdaP4PqHlyYI4o(qd5qnGjRWJlM4E)4PX97HVMIQ86IClA9AcXAOWoqCVF80aZfHdaP4PqHlyYI4oKKkzvZL7qSyi6IM2fc485JSl3HyXq0fnTleWr1KdgRq2FhsCjjJmQKvwI79JNg41FKwKBrBlGMCJaxWKfX9x5CjyPoGzf0K)JoqNtgz9cT(ovj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsqMpFKL4E)4PbE9hPf5w02cOj3iWfmzrChssL0ZAXCr4aqKwUAa8DzscdjjJmQKEwlUEbGClsXtHcF80q1KdgRq2FhKZLGL6aMvqtriMVjAYbJuil1GXovp20t5KVu97cu9b4TvYRaO6uX2s1ScMQhZSu967KQfxQUa(KmvZxQof6DdP6jNaq13xbu96unHVlvlwQwcSEbu967etnGjRWJlM4E)4PX97HVoaVTsEfGHc7aX9(Xtd86pslYTOTfqtUrGlyYI4oKKkPN1I5IWbGiTC1a47YKegFqoxcwQd413jAY)rKwUAGRkI79JNgyUiCaifpfkCbtwe3XhAihQbmzfECXe37hpnUFp81b4TvYRamuyhiU3pEAG5IWbGu8uOWfmzrChssLSQ5YDiwmeDrt7cbC(8r2L7qSyi6IM2fc4OAYbJvi7VdjUKKrgvYklX9(Xtd86pslYTOTfqtUrGlyYI4(R6jPs6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGmF(ilX9(Xtd86pslYTOTfqtUrGlyYI4oKKkPN1I5IWbGiTC1a47YKegssgzuj9SwC9ca5wKINcf(4PHQjhmwHS)oiNlbl1bmRGMIqmFt0KdgPqwQbJDQEm)cu9vHReOAHLQxFNunhhQMvOAUaQ2dQMCOAoouDQhgTuTeq1pfQ26fv39ObkQEB5GQ3wGQN8FQ(aDozdP6jNGiAO67RaQofO6wwoq18s1DGVlvVPovZfHdGQjTC1axQMJdvVT8s1RVtQoLVHrlvB8Y7Uu97chm1aMScpUyI79JNg3Vh(Q4JGJfDv4kbdf2bI79JNg41FKwKBrBlGMCJaxWKfX9x5CjyPoGRlAY)rhOZjJSEHwFNQiU3pEAG5IWbGu8uOWfmzrC)voxcwQd46IM8F0b6CYiRxiwrLSl3HyX1laKBrkEkuQKL4E)4PbUEbGClsXtHcxWKfXDC4pqElGwXe(8H4E)4PbUEbGClsXtHcxWKfX9x5CjyPoGRlAY)rhOZjJSEHkxrMpFuZL7qS46faYTifpfkzuj9SwmxeoaePLRgaFxMKWVgt1bKEwlE9hPf5w02cOj3iWhpnuj9SwC9ca5wKINcf(4PHkPN1I5IWbGu8uOWhpnOgm2P6X8lq1xfUsGQtfBlvZkuDAleuTIFVcPoGP6XmlvV(oPAXLQlGpjt18LQtHE3qQEYjau99vavVovt47s1ILQLaRxavV(oXudyYk84IjU3pEAC)E4RIpcow0vHRemuyhiU3pEAGx)rArUfTTaAYncCbtwe3XH)a5TaAftqL0ZAXCr4aqKwUAa8DzscJpiNlbl1b867en5)islxnWvfX9(XtdmxeoaKINcfUGjlI74Yc)bYBb0kMW3mzfEGx)rArUfTTaAYncm8hiVfqRycYqnGjRWJlM4E)4PX97HVk(i4yrxfUsWqHDG4E)4PbMlchasXtHcxWKfXDC4pqElGwXeujRSQ5YDiwmeDrt7cbC(8r2L7qSyi6IM2fc4OAYbJvi7VdjUKKrgvYklX9(Xtd86pslYTOTfqtUrGlyYI4(RCUeSuhWScAY)rhOZjJSEHwFNQKEwlMlchaI0YvdGVltsyq6zTyUiCaislxnaEY)r3LjjiZNpYsCVF80aV(J0IClABb0KBe4cMSiUdjPs6zTyUiCaislxna(UmjHHKKrgvspRfxVaqUfP4PqHpEAOAYbJvi7VdY5sWsDaZkOPieZ3en5GrkKvgQbJDQEm)cu967KQtfBlvZkuTWs1I1OlvNk2wrq1Blq1t(pvFGoNmMQhZSuD4RHu97cuDQyBP6YvOAHLQ3wGQxUdXs1IlvVCcqyivZXHQfRrxQovSTIGQ3wGQN8FQ(aDozm1aMScpUyI79JNg3Vh(A9hPf5w02cOj3imuyhKEwlMlchaI0YvdGVltsy8b5CjyPoGxFNOj)hrA5QbUQiU3pEAG5IWbGu8uOWfmzrChFa(dK3cOvmbQbmzfECXe37hpnUFp816pslYTOTfqtUryOWoi9SwmxeoaePLRgaFxMKW4dY5sWsDaV(ort(pI0YvdCvTChIfxVaqUfP4PqPI4E)4PbUEbGClsXtHcxWKfXD8b4pqElGwXeurCVF80aZfHdaP4PqHlyYI4(RCUeSuhWRVt0K)JoqNtgz9cXkudyYk84IjU3pEAC)E4R1FKwKBrBlGMCJWqHDq6zTyUiCaislxna(UmjHXhKZLGL6aE9DIM8FePLRg4Qsw1C5oelUEbGClsXtH6ZhI79JNg46faYTifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxOYvKrfX9(XtdmxeoaKINcfUGjlI7VY5sWsDaV(ort(p6aDozK1leRqnySt1J5xGQzfQwyP613jvlUuThun5q1CCO6upmAPAjGQFkuT1lQU7rduu92YbvVTavp5)u9b6CYgs1tobr0q13xbu92YlvNcuDllhOAi8xtlvp5GPAoou92YlvVTqbuT4s1HVun3lGpjt1mvxVaOA3s1kEkuu9Xtdm1aMScpUyI79JNg3Vh(IlchasXtHYqHDG4E)4PbE9hPf5w02cOj3iWfmzrC)voxcwQdywbn5)Od05KrwVqRVtvspRfZfHdarA5QbW3Ljjmi9SwmxeoaePLRgap5)O7YKeuj9SwC9ca5wKINcf(4PHQjhmwHS)oiNlbl1bmRGMIqmFt0KdgPqwQbJDQEm)cuD5kuTWs1RVtQwCPApOAYHQ54q1PEy0s1sav)uOARxuD3JgOO6TLdQEBbQEY)P6d05KnKQNCcIOHQVVcO6TfkGQf3WOLQ5Eb8jzQMP66favF80GQ54q1BlVunRq1PEy0s1saXNavZYzrNL6avFELiAO66faMAatwHhxmX9(XtJ73dFvVaqUfP4PqzOWoi9SwmxeoaKINcf(4PHkI79JNg41FKwKBrBlGMCJaxWKfX9x5CjyPoGlxbn5)Od05KrwVqRVtvspRfZfHdarA5QbW3Ljjmi9SwmxeoaePLRgap5)O7YKeujlX9(XtdmxeoaKINcfUGjlI7VQBSpFoG0ZAXR)iTi3I2wan5gb(Pid1aMScpUyI79JNg3Vh(62kSRiAqkEkugkSdspRfZfHdaP4PqHpEAOI4E)4PbMlchasXtHcV1dqfmzrC)LjRWd8Tvyxr0Gu8uOWKtPs6zT46faYTifpfk8Xtdve37hpnW1laKBrkEku4TEaQGjlI7VmzfEGVTc7kIgKINcfMCkvhq6zT41FKwKBrBlGMCJaF80GAWyNQhZVavR4tQEDQ(oMEamgbOAoOA4)wmvZsuTiO6TfO6a(VunX9(XtdQovehp1qQ(fD4EP6esUeCq1BleuTh9KP6ZRerdvZfHdGQv8uOO6ZdO61P6wpLQNCWuD7lAQKP6IpcowQ(QWvcuT4snGjRWJlM4E)4PX97HVuk4cbbqUfnfXXqHDy5oelUEbGClsXtHsL0ZAXCr4aqkEku4NIkPN1IRxai3Iu8uOWfmzrChVHCWt(p1aMScpUyI79JNg3Vh(sPGleea5w0uehdf2Hdi9Sw86pslYTOTfqtUrGFkQoG0ZAXR)iTi3I2wan5gbUGjlI74mzfEG5IWbGMI7v0Hlg(dK3cOvmbvQjXLdbhloHKlbhudyYk84IjU3pEAC)E4lLcUqqaKBrtrCmuyhKEwlUEbGClsXtHc)uuj9SwC9ca5wKINcfUGjlI74nKdEY)vrCVF80adYDcVcpWfWNKvPMexoeCS4esUeCqnGAatwHhxSveChj9Q47HV4IWbGMI7v0HRHc7G0ZAXKoWfHVRiAWfWK1qsllIb1PgWKv4XfBfb3rsVk(E4lUiCaiPoFxQbmzfECXwrWDK0RIVh(IlchasIRIBaQbudyYk84INUCycX(9WxsDrKaIJKnuyhMUCycXIpI7Ybb(Dq9KOgWKv4XfpD5WeI97HVuk4cbbqUfnfXHAatwHhx80Ldti2Vh(IlchaAkUxrhUgkSdtxomHyXhXD5GaJREsudyYk84INUCycX(9WxCr4aqEjrnGjRWJlE6YHje73dFzffGK68DPgqnGjRWJl2vGaQbqUt4v4HHc7GS1laRxna(kuA9aDxVMF(uVaSE1a4fMkEXDukxkYOA5oelUEbGClsXtHsfX9(XtdC9ca5wKINcfUGjlIRkzLEwlUEbGClsXtHcF804ZhLcKJAihS6yUiCaijUkUbKHAatwHhxSRabuFp8LvuasQZ31qHDOEby9QbWhXLiu6IGRKreFo54Os6zT4J4sekDrWvYiIpNCCq2YVl(PqnGjRWJl2vGaQVh(Yw(DrHlNnuyhQxawVAaCtjU9KrcIG0bvtoyScz)DmOgudyYk84IDfiG67HVoaVTsEfGHc7GAwVaSE1a4RqP1d0D9AsnGjRWJl2vGaQVh(Q4JGJfDv4kbdf2HjhmwHS)owjrnGjRWJl2vGaQVh(62kSRiAqkEkugkSdspRfZfHdaP4PqHpEAOI4E)4PbMlchasXtHcxWKfXvLAkNlbl1bSiKd1chKRabudQtnGjRWJl2vGaQVh(IlchaYljdf2b5CjyPoGfHCOw4GCfiGAqDve37hpnW1laKBrkEku4cMSiUdjrnGjRWJl2vGaQVh(IlchasQZ31qHDqoxcwQdyrihQfoixbcOguxfX9(XtdC9ca5wKINcfUGjlI7qsQKEwlMlchaI0YvdGVltsyCPN1I5IWbGiTC1a4j)hDxMKa1aMScpUyxbcO(E4R6faYTifpfkdf2b5CjyPoGfHCOw4GCfiGAqDvspRfxVaqUfP4PqHpEAqnGjRWJl2vGaQVh(sXxHhgkSdY5sWsDalc5qTWb5kqa1G6QutzRxawVAa8vO06b6UEn)8PEby9QbWlmv8I7OuUuKHAatwHhxSRabuFp81b4TvYRamuyhKEwlUEbGClsXtHcF80GAatwHhxSRabuFp81uuLxxKBrRxtiwdf2bPN1IRxai3Iu8uOWhpn(8rPa5OgYbRoMlchasIRIBaQbmzfECXUceq99WxR)iTi3I2wan5gHHc7G0ZAX1laKBrkEku4JNgF(OuGCud5GvhZfHdajXvXna1aMScpUyxbcO(E4lUiCaifpfkdf2bLcKJAihS641FKwKBrBlGMCJGAatwHhxSRabuFp8v9ca5wKINcLHc7G0ZAX1laKBrkEku4JNgudyYk84IDfiG67HVuk4cbbqUfnfXXqHD4aspRfV(J0IClABb0KBe4NIQdi9Sw86pslYTOTfqtUrGlyYI4ootwHhyUiCaOP4EfD4IH)a5TaAftGAatwHhxSRabuFp8LsbxiiaYTOPiogkSdl3HyX1laKBrkEkuQKEwlMlchasXtHc)uuj9SwC9ca5wKINcfUGjlI74nKdEY)PgWKv4Xf7kqa13dFXfHdaj157AOWoC8fx8rWXIUkCLaUGjlI7VQXNphq6zT4Ipcow0vHReqYF9akws0fBY47YKe(njQbmzfECXUceq99WxCr4aqsD(UgkSdspRfRuWfccGClAkId(PO6aspRfV(J0IClABb0KBe4NIQdi9Sw86pslYTOTfqtUrGlyYI4o(atwHhyUiCaiPoFxm8hiVfqRycudyYk84IDfiG67HV4IWbGK4Q4gWqHDq6zT46faYTifpfk8trfX9(XtdmxeoaKINcfUa(KSQjhmwHSJpwjPs6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGk1SEby9QbWxHsRhO761uLAwVaSE1a4fMkEXDukxkudyYk84IDfiG67HV4IWbGK4Q4gWqHDq6zT46faYTifpfk8trL0ZAXCr4aqkEku4JNgQKEwlUEbGClsXtHcxWKfXD8HgYrL0ZAXCr4aqKwUAa8DzscdspRfZfHdarA5QbWt(p6UmjbvY5sWsDalc5qTWb5kqaf1aMScpUyxbcO(E4lUiCaOP4EfD4AOWoCaPN1Ix)rArUfTTaAYnc8tr1YDiwmxeoaeqADvYk9Sw8b4TvYRaWhpn(8HjRqoGGaMc4oOUmQoG0ZAXR)iTi3I2wan5gbUGjlI7VmzfEG5IWbGMI7v0Hlg(dK3cOvmbvYQM8yeOelG5IWbGuEZj0frdgcwQdNpFKEwlM0bUi8DfrdI0YraD8XtdzmK0YIyqDdbU6jJiTSiqc7G0ZAXKoWfHVRiAqKwocOJpEAOswPN1I5IWbGu8uOWpLpFKvnxUdXID5qP4PqbhvYk9SwC9ca5wKINcf(P85dX9(Xtdmi3j8k8axaFswgzKHAatwHhxSRabuFp8fxeoa0uCVIoCnuyhKEwlM0bUi8DfrdUaMSQiU3pEAG5IWbGu8uOWfmzrCvjR0ZAX1laKBrkEku4NYNpspRfZfHdaP4PqHFkYyiPLfXG6udyYk84IDfiG67HV4IWbG8sYqHDq6zTyUiCaislxna(UmjHXhKZLGL6aE9DIM8FePLRg4QswI79JNgyUiCaifpfkCbtwe3FvpPpFyYkKdiiGPaUJpymzOgWKv4Xf7kqa13dFXfHdaj157AOWoi9SwC9ca5wKINcf(P85ZKdgRq2FvxnOgWKv4Xf7kqa13dFbYDcVcpmuyhKEwlUEbGClsXtHcF80qL0ZAXCr4aqkEku4JNggkIfQ6PSiHDyYbJvi7VdgF1WqrSqvpLfjMt4i4fguNAatwHhxSRabuFp8fxeoaKexf3audOgm2PAMScpU4YxEfE89WxeoiqhXKv4HHc7atwHhyqUt4v4bM0YraDr0OAYbJvi7VdJb1qLSQz9cW6vdGVcLwpq31R5NpspRfFfkTEGURxt8DzscdspRfFfkTEGURxt8K)JUltsqgQbmzfECXLV8k847HVa5oHxHhgkSdtoySczhFqoxcwQdyqUJuiRkzjU3pEAGx)rArUfTTaAYncCbtwe3XhyYk8adYDcVcpWWFG8waTIj85dX9(XtdmxeoaKINcfUGjlI74dmzfEGb5oHxHhy4pqElGwXe(8r2L7qS46faYTifpfkve37hpnW1laKBrkEku4cMSiUJpWKv4bgK7eEfEGH)a5TaAftqgzuj9SwC9ca5wKINcf(4PHkPN1I5IWbGu8uOWhpnuDaPN1Ix)rArUfTTaAYnc8XtddfXcv9uwKWom5GXkK93HXGAOsw1SEby9QbWxHsRhO7618ZhPN1IVcLwpq31Rj(UmjHbPN1IVcLwpq31RjEY)r3LjjiJHIyHQEklsmNWrWlmOo1aMScpU4YxEfE89WxGCNWRWddf2H6fG1RgaFfkTEGURxtve37hpnWCr4aqkEku4cMSiUJpWKv4bgK7eEfEGH)a5TaAftGAWyNQ)HRIBaQwyPAXA0LQxXeO61P63fO613jvZXHQtbQULLdu96ovp5izQM0YvdCPgWKv4Xfx(YRWJVh(IlchasIRIBadf2bI79JNg41FKwKBrBlGMCJaxaFswLSspRfZfHdarA5QbW3Ljj8RCUeSuhWRVt0K)JiTC1axve37hpnWCr4aqkEku4cMSiUJpa)bYBb0kMGmudyYk84IlF5v4X3dFXfHdajXvXnGHc7aX9(Xtd86pslYTOTfqtUrGlGpjRswPN1I5IWbGiTC1a47YKe(voxcwQd413jAY)rKwUAGRQL7qS46faYTifpfkve37hpnW1laKBrkEku4cMSiUJpa)bYBb0kMGkI79JNgyUiCaifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxiwrgQbmzfECXLV8k847HV4IWbGK4Q4gWqHDG4E)4PbE9hPf5w02cOj3iWfWNKvjR0ZAXCr4aqKwUAa8Dzsc)kNlbl1b867en5)islxnWvLSQ5YDiwC9ca5wKINc1Npe37hpnW1laKBrkEku4cMSiU)kNlbl1b867en5)Od05KrwVqLRiJkI79JNgyUiCaifpfkCbtwe3FLZLGL6aE9DIM8F0b6CYiRxiwrgQbmzfECXLV8k847HV4IWbGK4Q4gWqHD4aspRfx8rWXIUkCLas(RhqXsIUytgFxMKWWbKEwlU4JGJfDv4kbK8xpGILeDXMmEY)r3LjjOswPN1I5IWbGu8uOWhpn(8r6zTyUiCaifpfkCbtwe3XhAihzujR0ZAX1laKBrkEku4JNgF(i9SwC9ca5wKINcfUGjlI74dnKJmudyYk84IlF5v4X3dFXfHdaj157AOWoC8fx8rWXIUkCLaUGjlI7Vg)pFK9aspRfx8rWXIUkCLas(RhqXsIUytgFxMKWVjP6aspRfx8rWXIUkCLas(RhqXsIUytgFxMKW4hq6zT4Ipcow0vHReqYF9akws0fBY4j)hDxMKGmudyYk84IlF5v4X3dFXfHdaj157AOWoi9SwSsbxiiaYTOPio4NIQdi9Sw86pslYTOTfqtUrGFkQoG0ZAXR)iTi3I2wan5gbUGjlI74dmzfEG5IWbGK68DXWFG8waTIjqnGjRWJlU8LxHhFp8fxeoa0uCVIoCnuyhoG0ZAXR)iTi3I2wan5gb(POA5oelMlchaciTUkzLEwl(a82k5va4JNgF(WKvihqqatbChuxgvYEaPN1Ix)rArUfTTaAYncCbtwe3FzYk8aZfHdanf3ROdxm8hiVfqRycF(qCVF80aRuWfccGClAkIdUGjlI7NpexoeCS4esUeCiJkzvtEmcuIfWCr4aqkV5e6IObdbl1HZNpspRft6axe(UIObrA5iGo(4PHmgsAzrmOUHax9KrKwweiHDq6zTysh4IW3venislhb0XhpnujR0ZAXCr4aqkEku4NYNpYQMl3HyXUCOu8uOGJkzLEwlUEbGClsXtHc)u(8H4E)4PbgK7eEfEGlGpjlJmYqnGjRWJlU8LxHhFp8fxeoa0uCVIoCnuyhKEwlM0bUi8DfrdUaMSQKEwlg(RWXboifFHyfCh)uOgWKv4Xfx(YRWJVh(IlchaAkUxrhUgkSdspRft6axe(UIObxatwvYk9SwmxeoaKINcf(P85J0ZAX1laKBrkEku4NYNphq6zT41FKwKBrBlGMCJaxWKfX9xMScpWCr4aqtX9k6Wfd)bYBb0kMGmgsAzrmOo1aMScpU4YxEfE89WxCr4aqtX9k6W1qHDq6zTysh4IW3ven4cyYQs6zTysh4IW3ven47YKegKEwlM0bUi8DfrdEY)r3LjjyiPLfXG6udyYk84IlF5v4X3dFXfHdanf3ROdxdf2bPN1IjDGlcFxr0GlGjRkPN1IjDGlcFxr0GlyYI4o(GSYk9SwmPdCr47kIg8DzscJTmzfEG5IWbGMI7v0Hlg(dK3cOvmbz(UHCKXqsllIb1PgWKv4Xfx(YRWJVh(kGTfk0ctf4UgkSdYwGTGBll1HpFuZvqsqenYOs6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGkPN1I5IWbGu8uOWhpnuDaPN1Ix)rArUfTTaAYnc8XtdQbmzfECXLV8k847HV4IWbG8sYqHDq6zTyUiCaislxna(UmjHXhKZLGL6aE9DIM8FePLRg4snGjRWJlU8LxHhFp819Pav4Yzdf2HjhmwHSJpmgudvspRfZfHdaP4PqHpEAOs6zT46faYTifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80GAatwHhxC5lVcp(E4lUiCaiPoFxdf2bPN1IRxhqUfTTfax8trL0ZAXCr4aqKwUAa8Dzsc)MyudyYk84IlF5v4X3dFXfHdajXvXnGHc7WKdgRq2XhKZLGL6awIRIBa0KdgPqwvspRfZfHdaP4PqHpEAOs6zT46faYTifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80qL0ZAXCr4aqKwUAa8DzscdspRfZfHdarA5QbWt(p6Umjbve37hpnWGCNWRWdCbtwexQbmzfECXLV8k847HV4IWbGK4Q4gWqHDq6zTyUiCaifpfk8XtdvspRfxVaqUfP4PqHpEAO6aspRfV(J0IClABb0KBe4JNgQKEwlMlchaI0YvdGVltsyq6zTyUiCaislxnaEY)r3LjjOA5oelMlchaYljve37hpnWCr4aqEjHlyYI4o(qd5OAYbJvi74dJHKurCVF80adYDcVcpWfmzrCPgWKv4Xfx(YRWJVh(IlchasIRIBadf2bPN1I5IWbGu8uOWpfvspRfZfHdaP4PqHlyYI4o(qd5Os6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGkI79JNgyqUt4v4bUGjlIl1aMScpU4YxEfE89WxCr4aqsCvCdyOWoi9SwC9ca5wKINcf(POs6zTyUiCaifpfk8XtdvspRfxVaqUfP4PqHlyYI4o(qd5Os6zTyUiCaislxna(UmjHbPN1I5IWbGiTC1a4j)hDxMKGkI79JNgyqUt4v4bUGjlIl1aMScpU4YxEfE89WxCr4aqsCvCdyOWoi9SwmxeoaKINcf(4PHkPN1IRxai3Iu8uOWhpnuDaPN1Ix)rArUfTTaAYnc8tr1bKEwlE9hPf5w02cOj3iWfmzrChFOHCuj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsGAatwHhxC5lVcp(E4lUiCaijUkUbmuyhwUAGf3cCFBXkKD8etnuj9SwmxeoaePLRgaFxMKWG0ZAXCr4aqKwUAa8K)JUltsqv9cW6vdG5IWbGK8PexNjeRkMSc5accykG7VQRs6zT4dWBRKxbGpEAqnGjRWJlU8LxHhFp8fxeoae8xP7xHhgkSdlxnWIBbUVTyfYoEIPgQKEwlMlchaI0YvdGVltsyCPN1I5IWbGiTC1a4j)hDxMKGQ6fG1RgaZfHdaj5tjUotiwvmzfYbeeWua3FvxL0ZAXhG3wjVcaF80GAatwHhxC5lVcp(E4lUiCaiPoFxQbmzfECXLV8k847HVa5oHxHhgkSdspRfxVaqUfP4PqHpEAOs6zTyUiCaifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80GAatwHhxC5lVcp(E4lUiCaijUkUbOgqnGjRWJl(2YfCqKZ97HVExan5GrnW0qHDq2L7qSyi6IM2fc4OAYbJvi74dg)Kun5GXkK93HeVAiZNpYQMl3HyXq0fnTleWr1KdgRq2Xhm(QHmudyYk84IVTCbhe5C)E4lfFfEyOWoi9SwmxeoaKINcf(PqnGjRWJl(2YfCqKZ97HVwXeqPCPyOWouVaSE1a4fMkEXDukxkQKEwlg(3YV7k8a)uujlX9(XtdmxeoaKINcfUa(K8Npwrt7IkyYI4o(WyLKmudyYk84IVTCbhe5C)E4RUOPDViJxENMjeRHc7G0ZAXCr4aqkEku4JNgQKEwlUEbGClsXtHcF80q1bKEwlE9hPf5w02cOj3iWhpnOgWKv4XfFB5coiY5(9WxsCdYTOTeKeUgkSdspRfZfHdaP4PqHpEAOs6zT46faYTifpfk8Xtdvhq6zT41FKwKBrBlGMCJaF80GAatwHhx8TLl4GiN73dFjb1fQeerJHc7G0ZAXCr4aqkEku4Nc1aMScpU4BlxWbro3Vh(sQ7(bzFvYgkSdspRfZfHdaP4PqHFkudyYk84IVTCbhe5C)E4lROaPU7hdf2bPN1I5IWbGu8uOWpfQbmzfECX3wUGdICUFp8fhe4Uf3reU3nuyhKEwlMlchasXtHc)uOgWKv4XfFB5coiY5(9WxVlGelmVgkSdspRfZfHdaP4PqHFkudyYk84IVTCbhe5C)E4R3fqIfMgcwlqwuWtyOPZhbVEDrs8PbmuyhKEwlMlchasXtHc)u(8H4E)4PbMlchasXtHcxWKfX93b1qnuDaPN1Ix)rArUfTTaAYnc8tHAatwHhx8TLl4GiN73dF9UasSW0WGNWamvsUaUJ86eCqadf2bI79JNgyUiCaifpfkCbtwe3XhmwsudyYk84IVTCbhe5C)E4R3fqIfMgg8egofWhROaKC4EHUHc7aX9(XtdmxeoaKINcfUGjlI7VdglPpFut5CjyPoGzfKhO3fgu)ZhzxXegssLCUeSuhWIqoulCqUceqnOUQ6fG1RgaFfkTEGURxtzOgWKv4XfFB5coiY5(9WxVlGelmnm4jmC9xhjAcXcLHc7aX9(XtdmxeoaKINcfUGjlI7VdglPpFut5CjyPoGzfKhO3fgu)ZhzxXegssLCUeSuhWIqoulCqUceqnOUQ6fG1RgaFfkTEGURxtzOgWKv4XfFB5coiY5(9WxVlGelmnm4jm00twPf5weFVIPOZRWddf2bI79JNgyUiCaifpfkCbtwe3FhmwsF(OMY5sWsDaZkipqVlmO(NpYUIjmKKk5CjyPoGfHCOw4GCfiGAqDv1laRxna(kuA9aDxVMYqnGjRWJl(2YfCqKZ97HVExajwyAyWtyyYewQa0TfGfnFxbXqHDG4E)4PbMlchasXtHcxWKfXD8b1qLSQPCUeSuhWIqoulCqUceqnO(NpRyc)Myjjd1aMScpU4BlxWbro3Vh(6DbKyHPHbpHHjtyPcq3waw08Dfedf2bI79JNgyUiCaifpfkCbtwe3XhudvY5sWsDalc5qTWb5kqa1G6QKEwlUEbGClsXtHc)uuj9SwC9ca5wKINcfUGjlI74dYQEsgpOgJT1laRxna(kuA9aDxVMYOAfty8elP8M3Cga]] )


end
