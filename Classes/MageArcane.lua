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

        potion = "spectral_intellect",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20201208, [[dWKPNeqisk6rkuQUejLuLnrs(efYOikDkIIvPqP0RuvQzrbDlskjSlu(LQsgMiYXiPAzuO6zIqzAkuY1iPW2uOqFtHcghjL4CIqL1rHI5Pq19uW(uvPdQqr1cvvXdPqPjssjvCrskP8rrOkDsfkkRKcmtsk1njPKQANkK(PiuvnuskPslLKsspLIMQcXvvOu8vrOQmwri7vu)fYGj1HrwmrEmutwfxgSzk9zPy0sPtty1Kus0RfbZwQUTI2TWVPA4K44kuKLl55Q00v66QY2jQ(UinEvvDEruRxeQI5RQy)O6S65rYMhAH8OgpjJNK6gpj1ct9e3yL4ux9S5MScKnviCcudKndAczZX8ctbKnvOK7oDYJKnV(RWq2SDxLRX81xnIT9jXW(8RRy(60k8axKD)6kM4VYMsprFhZISu28qlKh14jz8Ku34jPwyQN4gRexsJv28Qa48OJrJNnBfNdezPS5bU4S5yNRvRp1aC9yEHPa4gm25A16ayykbfxRwmKRnEsgpjUbCdg7CTAvy6YbUwovcsQdmAIUk0KRfbxBj5EX1ULRVWUIO5YOj6QqtUwwClGtGRt2FfxFvamx7kRWJRmmUbJDUESr5qlC4ArSqfuNRBP40frdx7wUwovcsQdSwsoGCfiGdxVoxlbCT6CDAleC9f2venxgnrxfAY1dCT6mUbJDUES5cC9MSIatDU2umnwUULItxenCTB5AClfb05ArSqvpLv4bxlI7c0HRDlxBeMcm0reEfEyelB2f39MhjB6kqavEK8OQNhjBcbj1Ht(NSjUeluckBklxxVaSE1aSRqP1d0D9AYGGK6WHR)8HRRxawVAa2ctfVOokLkfgeKuhoCTmCTkUEPoelREbGClsXtHIbbj1HdxRIRXU3pEAWQxai3Iu8uOyfmjrC5AvCTSCT0ZAz1laKBrkEkuSJNgC9NpCTsbYrn4dtDgvykaKevf1aCTmztcVcpYMGChtRWJ8Mh145rYMqqsD4K)jBIlXcLGYM1laRxna7iUyHsxeuLmc7ZjfhgeKuhoCTkUw6zTSJ4IfkDrqvYiSpNuCq2YVl7PKnj8k8iBAffGK60DZBE0elps2ecsQdN8pztCjwOeu2SEby9QbynL42tgjWcChyqqsD4W1Q46jfetbVC9VCDItnYMeEfEKnTLFxu4YP8MhDSYJKnHGK6Wj)t2exIfkbLnvtUUEby9QbyxHsRhO761Kbbj1Ht2KWRWJS5bOTvYRaYBEu1ips2ecsQdN8pztCjwOeu2CsbXuWlx)lxpwjLnj8k8iBw0rqXIUkuLqEZJogZJKnHGK6Wj)t2exIfkbLnLEwlJkmfasXtHID80GRvX1y37hpnyuHPaqkEkuScMKiUCTkUwn5A5ujiPoWeHCOw4GCfiGIRh4A1ZMeEfEKnVTc7kIgKINcvEZJogYJKnHGK6Wj)t2exIfkbLnLtLGK6ateYHAHdYvGakUEGRvNRvX1y37hpny1laKBrkEkuScMKiUC9axNu2KWRWJSjvykaKxs5npQAjps2ecsQdN8pztCjwOeu2uovcsQdmrihQfoixbcO46bUwDUwfxJDVF80GvVaqUfP4PqXkysI4Y1dCDsCTkUw6zTmQWuaiClvna7UeobUECUw6zTmQWuaiClvnaBs)r3LWjKnj8k8iBsfMcaj1P7M38OjU8iztiiPoCY)KnXLyHsqzt5ujiPoWeHCOw4GCfiGIRh4A15AvCT0ZAz1laKBrkEkuSJNgztcVcpYM1laKBrkEku5npQ6jLhjBcbj1Ht(NSjUeluckBkNkbj1bMiKd1chKRabuC9axRoxRIRvtUwwUUEby9QbyxHsRhO761Kbbj1Hdx)5dxxVaSE1aSfMkErDukvkmiiPoC4AzYMeEfEKnv8v4rEZJQU65rYMqqsD4K)jBIlXcLGYMspRLvVaqUfP4PqXoEAKnj8k8iBEaABL8kG8MhvDJNhjBcbj1Ht(NSjUeluckBk9Sww9ca5wKINcf74Pbx)5dxRuGCud(WuNrfMcajrvrnq2KWRWJS5uuLxxKBrRxti28Mhv9elps2ecsQdN8pztCjwOeu2u6zTS6faYTifpfk2XtdU(ZhUwPa5Og8HPoJkmfasIQIAGSjHxHhzZ1F4wKBrBlGMuJiV5rvFSYJKnHGK6Wj)t2exIfkbLnvkqoQbFyQZw)HBrUfTTaAsnISjHxHhztQWuaifpfQ8MhvD1ips2ecsQdN8pztCjwOeu2u6zTS6faYTifpfk2XtJSjHxHhzZ6faYTifpfQ8Mhv9XyEKSjeKuho5FYM4sSqjOS5bKEwlB9hUf5w02cOj1iypfUwfxFaPN1Yw)HBrUfTTaAsncwbtsexUECUMWRWdgvyka0uCVIoCzWFa)waTIjKnj8k8iBQuWfcmGClAkItEZJQ(yips2ecsQdN8pztCjwOeu2CPoelREbGClsXtHIbbj1HdxRIRLEwlJkmfasXtHI9u4AvCT0ZAz1laKBrkEkuScMKiUC94CDd(WM0)SjHxHhztLcUqGbKBrtrCYBEu1vl5rYMqqsD4K)jBIlXcLGYMhFzfDeuSORcvjWkysI4Y1)Y1Qbx)5dxFaPN1Yk6iOyrxfQsaj)1dOijrxSjZUlHtGR)LRtkBs4v4r2KkmfasQt3nV5rvpXLhjBcbj1Ht(NSjUeluckBk9SwMsbxiWaYTOPioSNcxRIRpG0ZAzR)WTi3I2wanPgb7PW1Q46di9Sw26pClYTOTfqtQrWkysI4Y1JpW1eEfEWOctbGK60DzWFa)waTIjKnj8k8iBsfMcaj1P7M38OgpP8iztiiPoCY)KnXLyHsqztPN1YQxai3Iu8uOypfUwfxJDVF80GrfMcaP4PqXkGojZ1Q46jfetbVC94C9yLexRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxRIRvtUUEby9QbyxHsRhO761Kbbj1HdxRIRvtUUEby9Qbylmv8I6OuQuyqqsD4Knj8k8iBsfMcajrvrnqEZJAC1ZJKnHGK6Wj)t2exIfkbLnLEwlREbGClsXtHI9u4AvCT0ZAzuHPaqkEkuSJNgCTkUw6zTS6faYTifpfkwbtsexUE8bUUbF4AvCT0ZAzuHPaq4wQAa2DjCcC9axl9SwgvykaeULQgGnP)O7s4e4AvCTCQeKuhyIqoulCqUceqLnj8k8iBsfMcajrvrnqEZJACJNhjBcbj1Ht(NSjULer2u9SjqvpzeULebsyZMspRLH7avy6UIObHBPiGo74PHkzLEwlJkmfasXtHI9u(8rw1CPoelZLdLINcfCujR0ZAz1laKBrkEkuSNYNpy37hpnyGChtRWdwb0jzzKrMSjUeluckBEaPN1Yw)HBrUfTTaAsnc2tHRvX1l1HyzuHPaqaU1zqqsD4W1Q4Az5APN1YoaTTsEfa74Pbx)5dxt4vihqqatbC56bUwDUwgUwfxFaPN1Yw)HBrUfTTaAsncwbtsexU(xUMWRWdgvyka0uCVIoCzWFa)waTIjW1Q4Az5A1KRPepqjwGrfMcaP8MtOlIggeKuhoC9NpCT0ZAz4oqfMURiAq4wkcOZoEAW1YKnj8k8iBsfMcanf3ROd38Mh14jwEKSjeKuho5FYMeEfEKnPctbGMI7v0HB2e3sIiBQE2exIfkbLnLEwld3bQW0DfrdRacVCTkUg7E)4PbJkmfasXtHIvWKeXLRvX1YY1spRLvVaqUfP4PqXEkC9NpCT0ZAzuHPaqkEkuSNcxltEZJA8Xkps2ecsQdN8pztCjwOeu2u6zTmQWuaiClvna7UeobUE8bUwovcsQdS13jAs)r4wQAGlxRIRLLRXU3pEAWOctbGu8uOyfmjrC56F5A1tIR)8HRj8kKdiiGPaUC94dCTX5AzYMeEfEKnPctbG8skV5rnUAKhjBcbj1Ht(NSjUeluckBk9Sww9ca5wKINcf7PW1F(W1tkiMcE56F5A1vJSjHxHhztQWuaiPoD38Mh14JX8iztiiPoCY)Knj8k8iBcYDmTcpYMIyHQEklsyZMtkiMcE)DqTOgztrSqvpLfjMt4iOfYMQNnXLyHsqztPN1YQxai3Iu8uOyhpn4AvCT0ZAzuHPaqkEkuSJNg5npQXhd5rYMeEfEKnPctbGKOQOgiBcbj1Ht(N8M3S5bS0RV5rYJQEEKSjeKuho5FYM4sSqjOS5svdSSdi9SwgMURiAyfq4nBs4v4r2e7VyH6Qa9EEZJA88iztiiPoCY)KnDLS5f2SjHxHhzt5ujiPoKnLt9hKnvpBIlXcLGYMYPsqsDG1sYbKRabC46bUojUwfxRuGCud(WuNbYDmTcp4AvCTAY1YY11laRxna7kuA9aDxVMmiiPoC46pF466fG1RgGTWuXlQJsPsHbbj1Hdxlt2uovOGMq2SLKdixbc4K38OjwEKSjeKuho5FYMUs28cB2KWRWJSPCQeKuhYMYP(dYMQNnXLyHsqzt5ujiPoWAj5aYvGaoC9axNexRIRLEwlJkmfasXtHID80GRvX1y37hpnyuHPaqkEkuScMKiUCTkUwwUUEby9QbyxHsRhO761Kbbj1Hdx)5dxxVaSE1aSfMkErDukvkmiiPoC4AzYMYPcf0eYMTKCa5kqaN8MhDSYJKnHGK6Wj)t20vYMxyZMeEfEKnLtLGK6q2uo1Fq2u9SjUeluckBk9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwfxRMCT0ZAz1Rdi3I22cGl7PW1Q4AROPDrfmjrC56Xh4Az5Az56jfex)fxt4v4bJkmfasQt3LH97Y1YW1JTCnHxHhmQWuaiPoDxg8hWVfqRycCTmzt5uHcAcztRiOos6vrEZJQg5rYMqqsD4K)jBs4v4r2et9oIWRWduxC3SzxCxuqtiBEBPcoi85M38OJX8iztiiPoCY)KnXLyHsqztcVc5accykGlx)lxB8SjHxHhztm17icVcpqDXDZMDXDrbnHSj5qEZJogYJKnHGK6Wj)t2exIfkbLnLtLGK6aRLKdixbc4W1dCDsztcVcpYMyQ3reEfEG6I7Mn7I7IcAcztxbcOYBEu1sEKSjeKuho5FYM4sSqjOS5f2venxgnrxfAY1dCT6ztcVcpYMyQ3reEfEG6I7Mn7I7IcAcztAIUk0mV5rtC5rYMqqsD4K)jBs4v4r2et9oIWRWduxC3SzxCxuqtiBIDVF804M38OQNuEKSjeKuho5FYM4sSqjOSPCQeKuhywrqDK0RcUEGRtkBs4v4r2et9oIWRWduxC3SzxCxuqtiBw(sRWJ8MhvD1ZJKnHGK6Wj)t2exIfkbLnLtLGK6aZkcQJKEvW1dCT6ztcVcpYMyQ3reEfEG6I7Mn7I7IcAcztRiOos6vrEZJQUXZJKnHGK6Wj)t2KWRWJSjM6DeHxHhOU4UzZU4UOGMq2C6YHjeBEZB2S8LwHh5rYJQEEKSjeKuho5FYM4sSqjOS5KcIPGxUE8bUwovcsQdmqUJuWlxRIRLLRXU3pEAWw)HBrUfTTaAsncwbtsexUE8bUMWRWdgi3X0k8Gb)b8Bb0kMax)5dxJDVF80GrfMcaP4PqXkysI4Y1JpW1eEfEWa5oMwHhm4pGFlGwXe46pF4Az56L6qSS6faYTifpfkgeKuhoCTkUg7E)4PbREbGClsXtHIvWKeXLRhFGRj8k8GbYDmTcpyWFa)waTIjW1YW1YW1Q4APN1YQxai3Iu8uOyhpn4AvCT0ZAzuHPaqkEkuSJNgCTkU(aspRLT(d3IClABb0KAeSJNgCTkUwn5ALcKJAWhM6S1F4wKBrBlGMuJiBs4v4r2eK7yAfEK38Ogpps2ecsQdN8pztCjwOeu2SEby9QbyxHsRhO761Kbbj1HdxRIRXU3pEAWOctbGu8uOyfmjrC56Xh4AcVcpyGChtRWdg8hWVfqRycztcVcpYMGChtRWJ8MhnXYJKnHGK6Wj)t2exIfkbLnXU3pEAWw)HBrUfTTaAsncwb0jzUwfxllxl9SwgvykaeULQgGDxcNax)lxlNkbj1b267enP)iClvnWLRvX1y37hpnyuHPaqkEkuScMKiUC94dCn8hWVfqRycCTkUEsbXuWlx)lxlNkbj1bgPGMIqmFt0KccPGxUwfxl9Sww9ca5wKINcf74Pbxlt2KWRWJSjvykaKevf1a5np6yLhjBcbj1Ht(NSjUeluckBIDVF80GT(d3IClABb0KAeScOtYCTkUwwUw6zTmQWuaiClvna7UeobU(xUwovcsQdS13jAs)r4wQAGlxRIRxQdXYQxai3Iu8uOyqqsD4W1Q4AS79JNgS6faYTifpfkwbtsexUE8bUg(d43cOvmbUwfxJDVF80GrfMcaP4PqXkysI4Y1)Y1YPsqsDGT(ort6p6aDkzK1lePW1YKnj8k8iBsfMcajrvrnqEZJQg5rYMqqsD4K)jBIlXcLGYMy37hpnyR)WTi3I2wanPgbRa6KmxRIRLLRLEwlJkmfac3svdWUlHtGR)LRLtLGK6aB9DIM0FeULQg4Y1Q4Az5A1KRxQdXYQxai3Iu8uOyqqsD4W1F(W1y37hpny1laKBrkEkuScMKiUC9VCTCQeKuhyRVt0K(JoqNsgz9cvUcxldxRIRXU3pEAWOctbGu8uOyfmjrC56F5A5ujiPoWwFNOj9hDGoLmY6fIu4AzYMeEfEKnPctbGKOQOgiV5rhJ5rYMqqsD4K)jBIlXcLGYMhq6zTSIockw0vHQeqYF9akss0fBYS7s4e46bU(aspRLv0rqXIUkuLas(RhqrsIUytMnP)O7s4e4AvCTSCT0ZAzuHPaqkEkuSJNgC9NpCT0ZAzuHPaqkEkuScMKiUC94dCDd(W1YW1Q4Az5APN1YQxai3Iu8uOyhpn46pF4APN1YQxai3Iu8uOyfmjrC56Xh46g8HRLjBs4v4r2KkmfasIQIAG8MhDmKhjBcbj1Ht(NSjUeluckBE8Lv0rqXIUkuLaRGjjIlx)lxRw46pF4Az56di9Swwrhbfl6Qqvci5VEafjj6Inz2DjCcC9VCDsCTkU(aspRLv0rqXIUkuLas(RhqrsIUytMDxcNaxpoxFaPN1Yk6iOyrxfQsaj)1dOijrxSjZM0F0DjCcCTmztcVcpYMuHPaqsD6U5npQAjps2ecsQdN8pztCjwOeu2u6zTmLcUqGbKBrtrCypfUwfxFaPN1Yw)HBrUfTTaAsnc2tHRvX1hq6zTS1F4wKBrBlGMuJGvWKeXLRhFGRj8k8GrfMcaj1P7YG)a(TaAftiBs4v4r2KkmfasQt3nV5rtC5rYMqqsD4K)jBIBjrKnvpBcu1tgHBjrGe2SP0ZAz4oqfMURiAq4wkcOZoEAOswPN1YOctbGu8uOypLpFKvnxQdXYC5qP4PqbhvYk9Sww9ca5wKINcf7P85d29(Xtdgi3X0k8GvaDswgzKjBIlXcLGYMhq6zTS1F4wKBrBlGMuJG9u4AvC9sDiwgvykaeGBDgeKuhoCTkUwwUw6zTSdqBRKxbWoEAW1F(W1eEfYbeeWuaxUEGRvNRLHRvX1YY1hq6zTS1F4wKBrBlGMuJGvWKeXLR)LRj8k8GrfMcanf3ROdxg8hWVfqRycC9NpCn29(XtdMsbxiWaYTOPioScMKiUC9NpCn2LdbfllHKlbfCTmCTkUwwUwn5AkXduIfyuHPaqkV5e6IOHbbj1Hdx)5dxl9SwgUduHP7kIgeULIa6SJNgCTmztcVcpYMuHPaqtX9k6WnV5rvpP8iztiiPoCY)KnXLyHsqztPN1YWDGkmDxr0WkGWlxRIRLEwld(RqXboifFHyfuN9uYMeEfEKnPctbGMI7v0HBEZJQU65rYMqqsD4K)jBs4v4r2KkmfaAkUxrhUztCljISP6ztCjwOeu2u6zTmChOct3venSci8Y1Q4Az5APN1YOctbGu8uOypfU(ZhUw6zTS6faYTifpfk2tHR)8HRpG0ZAzR)WTi3I2wanPgbRGjjIlx)lxt4v4bJkmfaAkUxrhUm4pGFlGwXe4AzYBEu1nEEKSjeKuho5FYMeEfEKnPctbGMI7v0HB2e3sIiBQE2exIfkbLnLEwld3bQW0DfrdRacVCTkUw6zTmChOct3venS7s4e46bUw6zTmChOct3venSj9hDxcNqEZJQEILhjBcbj1Ht(NSjHxHhztQWuaOP4EfD4MnXTKiYMQNnXLyHsqztPN1YWDGkmDxr0WkGWlxRIRLEwld3bQW0DfrdRGjjIlxp(axllxllxl9SwgUduHP7kIg2DjCcC9ylxt4v4bJkmfaAkUxrhUm4pGFlGwXe4Az46V56g8HRLjV5rvFSYJKnHGK6Wj)t2exIfkbLnLLRlWwWTLK6ax)5dxRMC9kWjiIgUwgUwfxl9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwfxl9SwgvykaKINcf74PbxRIRpG0ZAzR)WTi3I2wanPgb74Pr2KWRWJSzaBluOfMkWDZBEu1vJ8iztiiPoCY)KnXLyHsqztPN1YOctbGWTu1aS7s4e46Xh4A5ujiPoWwFNOj9hHBPQbUztcVcpYMuHPaqEjL38OQpgZJKnHGK6Wj)t2exIfkbLnNuqmf8Y1JpW1jo1GRvX1spRLrfMcaP4PqXoEAW1Q4APN1YQxai3Iu8uOyhpn4AvC9bKEwlB9hUf5w02cOj1iyhpnYMeEfEKnVpfOcxoL38OQpgYJKnHGK6Wj)t2exIfkbLnLEwlREDa5w02waCzpfUwfxl9SwgvykaeULQgGDxcNax)lxNyztcVcpYMuHPaqsD6U5npQ6QL8iztiiPoCY)KnXLyHsqzZjfetbVC94dCTCQeKuhysuvudGMuqif8Y1Q4APN1YOctbGu8uOyhpn4AvCT0ZAz1laKBrkEkuSJNgCTkU(aspRLT(d3IClABb0KAeSJNgCTkUw6zTmQWuaiClvna7UeobUEGRLEwlJkmfac3svdWM0F0DjCcCTkUg7E)4PbdK7yAfEWkysI4Mnj8k8iBsfMcajrvrnqEZJQEIlps2ecsQdN8pztCjwOeu2u6zTmQWuaifpfk2XtdUwfxl9Sww9ca5wKINcf74PbxRIRpG0ZAzR)WTi3I2wanPgb74PbxRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxRIRxQdXYOctbG8sIbbj1HdxRIRXU3pEAWOctbG8sIvWKeXLRhFGRBWhUwfxpPGyk4LRhFGRtCjX1Q4AS79JNgmqUJPv4bRGjjIB2KWRWJSjvykaKevf1a5npQXtkps2ecsQdN8pztCjwOeu2u6zTmQWuaifpfk2tHRvX1spRLrfMcaP4PqXkysI4Y1JpW1n4dxRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxRIRXU3pEAWa5oMwHhScMKiUztcVcpYMuHPaqsuvudK38Ogx98iztiiPoCY)KnXLyHsqztPN1YQxai3Iu8uOypfUwfxl9SwgvykaKINcf74PbxRIRLEwlREbGClsXtHIvWKeXLRhFGRBWhUwfxl9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwfxJDVF80GbYDmTcpyfmjrCZMeEfEKnPctbGKOQOgiV5rnUXZJKnHGK6Wj)t2exIfkbLnLEwlJkmfasXtHID80GRvX1spRLvVaqUfP4PqXoEAW1Q46di9Sw26pClYTOTfqtQrWEkCTkU(aspRLT(d3IClABb0KAeScMKiUC94dCDd(W1Q4APN1YOctbGWTu1aS7s4e46bUw6zTmQWuaiClvnaBs)r3LWjKnj8k8iBsfMcajrvrnqEZJA8elps2ecsQdN8pztCjwOeu2CPQbwwlq9TLPGxUECUoXudUwfxl9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwfxxVaSE1amQWuaijFkr1zcXYGGK6WHRvX1eEfYbeeWuaxU(xUwDUwfxl9Sw2bOTvYRayhpnYMeEfEKnPctbGKOQOgiV5rn(yLhjBcbj1Ht(NSjUeluckBUu1alRfO(2YuWlxpoxNyQbxRIRLEwlJkmfac3svdWUlHtGRhNRLEwlJkmfac3svdWM0F0DjCcCTkUUEby9QbyuHPaqs(uIQZeILbbj1HdxRIRj8kKdiiGPaUC9VCT6CTkUw6zTSdqBRKxbWoEAKnj8k8iBsfMcab)v6(v4rEZJAC1ips2KWRWJSjvykaKuNUB2ecsQdN8p5npQXhJ5rYMqqsD4K)jBIlXcLGYMspRLvVaqUfP4PqXoEAW1Q4APN1YOctbGu8uOyhpn4AvC9bKEwlB9hUf5w02cOj1iyhpnYMeEfEKnb5oMwHh5npQXhd5rYMeEfEKnPctbGKOQOgiBcbj1Ht(N8M3Sj5qEK8OQNhjBcbj1Ht(NSjUeluckBwVaSE1aSJ4IfkDrqvYiSpNuCyqqsD4W1Q4AS79JNgmPN1IoIlwO0fbvjJW(CsXHvaDsMRvX1spRLDexSqPlcQsgH95KIdYw(Dzhpn4AvCTSCT0ZAzuHPaqkEkuSJNgCTkUw6zTS6faYTifpfk2XtdUwfxFaPN1Yw)HBrUfTTaAsnc2XtdUwgUwfxJDVF80GT(d3IClABb0KAeScMKiUC9axNexRIRLLRLEwlJkmfac3svdWUlHtGRhFGRLtLGK6aJCaT(ort6pc3svdC5AvCTSCTSC9sDiww9ca5wKINcfdcsQdhUwfxJDVF80GvVaqUfP4PqXkysI4Y1JpW1n4dxRIRXU3pEAWOctbGu8uOyfmjrC56F5A5ujiPoWwFNOj9hDGoLmY6fIu4Az46pF4Az5A1KRxQdXYQxai3Iu8uOyqqsD4W1Q4AS79JNgmQWuaifpfkwbtsexU(xUwovcsQdS13jAs)rhOtjJSEHifUwgU(ZhUg7E)4PbJkmfasXtHIvWKeXLRhFGRBWhUwgUwMSjHxHhztB53vY7BEZJA88iztiiPoCY)KnXLyHsqztz566fG1RgGDexSqPlcQsgH95KIddcsQdhUwfxJDVF80Gj9Sw0rCXcLUiOkze2NtkoScOtYCTkUw6zTSJ4IfkDrqvYiSpNuCqwrbSJNgCTkUwPa5Og8HPoZw(DL8(Y1YW1F(W1YY11laRxna7iUyHsxeuLmc7ZjfhgeKuhoCTkUEftGRh46K4AzYMeEfEKnTIcqsD6U5npAILhjBcbj1Ht(NSjUeluckBwVaSE1aSMsC7jJeybUdmiiPoC4AvCn29(XtdgvykaKINcfRGjjIlx)lxNyjX1Q4AS79JNgS1F4wKBrBlGMuJGvWKeXLRh46K4AvCTSCT0ZAzuHPaq4wQAa2DjCcC94dCTCQeKuhyKdO13jAs)r4wQAGlxRIRLLRLLRxQdXYQxai3Iu8uOyqqsD4W1Q4AS79JNgS6faYTifpfkwbtsexUE8bUUbF4AvCn29(XtdgvykaKINcfRGjjIlx)lxlNkbj1b267enP)Od0PKrwVqKcxldx)5dxllxRMC9sDiww9ca5wKINcfdcsQdhUwfxJDVF80GrfMcaP4PqXkysI4Y1)Y1YPsqsDGT(ort6p6aDkzK1lePW1YW1F(W1y37hpnyuHPaqkEkuScMKiUC94dCDd(W1YW1YKnj8k8iBAl)UOWLt5np6yLhjBcbj1Ht(NSjUeluckBwVaSE1aSMsC7jJeybUdmiiPoC4AvCn29(XtdgvykaKINcfRGjjIlxpW1jX1Q4Az5Az5Az5AS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aJuqt6p6aDkzK1l067KRvX1spRLrfMcaHBPQby3LWjW1dCT0ZAzuHPaq4wQAa2K(JUlHtGRLHR)8HRLLRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTmCTmCTkUw6zTS6faYTifpfk2XtdUwMSjHxHhztB53ffUCkV5rvJ8iztiiPoCY)KnXLyHsqzZ6fG1RgGDfkTEGURxtgeKuhoCTkUwPa5Og8HPodK7yAfEKnj8k8iBU(d3IClABb0KAe5np6ymps2ecsQdN8pztCjwOeu2SEby9QbyxHsRhO761Kbbj1HdxRIRLLRvkqoQbFyQZa5oMwHhC9NpCTsbYrn4dtD26pClYTOTfqtQrW1YKnj8k8iBsfMcaP4PqL38OJH8iztiiPoCY)KnXLyHsqzZvmbU(xUoXsIRvX11laRxna7kuA9aDxVMmiiPoC4AvCT0ZAzuHPaq4wQAa2DjCcC94dCTCQeKuhyKdO13jAs)r4wQAGlxRIRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1y37hpnyuHPaqkEkuScMKiUC94dCDd(Knj8k8iBcYDmTcpYBEu1sEKSjeKuho5FYMeEfEKnb5oMwHhztrSqvpLfjSztPN1YUcLwpq31Rj7UeoHbPN1YUcLwpq31RjBs)r3LWjKnfXcv9uwKyoHJGwiBQE2exIfkbLnxXe46F56eljUwfxxVaSE1aSRqP1d0D9AYGGK6WHRvX1y37hpnyuHPaqkEkuScMKiUC9axNexRIRLLRLLRLLRXU3pEAWw)HBrUfTTaAsncwbtsexU(xUwovcsQdmsbnP)Od0PKrwVqRVtUwfxl9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwgU(ZhUwwUg7E)4PbB9hUf5w02cOj1iyfmjrC56bUojUwfxl9SwgvykaeULQgGDxcNaxp(axlNkbj1bg5aA9DIM0FeULQg4Y1YW1YW1Q4APN1YQxai3Iu8uOyhpn4AzYBE0exEKSjeKuho5FYM4sSqjOSPSCn29(XtdgvykaKINcfRGjjIlx)lxpwQbx)5dxJDVF80GrfMcaP4PqXkysI4Y1JpW1jgxldxRIRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1YY1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTkUwwUwwUEPoelREbGClsXtHIbbj1HdxRIRXU3pEAWQxai3Iu8uOyfmjrC56Xh46g8HRvX1y37hpnyuHPaqkEkuScMKiUC9VCTAW1YW1F(W1YY1QjxVuhILvVaqUfP4PqXGGK6WHRvX1y37hpnyuHPaqkEkuScMKiUC9VCTAW1YW1F(W1y37hpnyuHPaqkEkuScMKiUC94dCDd(W1YW1YKnj8k8iBofv51f5w061eInV5rvpP8iztiiPoCY)KnXLyHsqztS79JNgS1F4wKBrBlGMuJGvWKeXLRhNRH)a(TaAftGRvX1YY1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTkUwwUwwUEPoelREbGClsXtHIbbj1HdxRIRXU3pEAWQxai3Iu8uOyfmjrC56Xh46g8HRvX1y37hpnyuHPaqkEkuScMKiUC9VCTCQeKuhyRVt0K(JoqNsgz9crkCTmC9NpCTSCTAY1l1Hyz1laKBrkEkumiiPoC4AvCn29(XtdgvykaKINcfRGjjIlx)lxlNkbj1b267enP)Od0PKrwVqKcxldx)5dxJDVF80GrfMcaP4PqXkysI4Y1JpW1n4dxldxlt2KWRWJSzrhbfl6Qqvc5npQ6QNhjBcbj1Ht(NSjUeluckBIDVF80GrfMcaP4PqXkysI4Y1JZ1WFa)waTIjW1Q4Az5Az5Az5AS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aJuqt6p6aDkzK1l067KRvX1spRLrfMcaHBPQby3LWjW1dCT0ZAzuHPaq4wQAa2K(JUlHtGRLHR)8HRLLRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTmCTmCTkUw6zTS6faYTifpfk2XtdUwMSjHxHhzZIockw0vHQeYBEu1nEEKSjeKuho5FYM4sSqjOSj29(XtdgvykaKINcfRGjjIlxpW1jX1Q4Az5Az5Az5AS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aJuqt6p6aDkzK1l067KRvX1spRLrfMcaHBPQby3LWjW1dCT0ZAzuHPaq4wQAa2K(JUlHtGRLHR)8HRLLRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTmCTmCTkUw6zTS6faYTifpfk2XtdUwMSjHxHhzZdqBRKxbK38OQNy5rYMqqsD4K)jBIlXcLGYMspRLrfMcaHBPQby3LWjW1JpW1YPsqsDGroGwFNOj9hHBPQbUCTkUwwUwwUEPoelREbGClsXtHIbbj1HdxRIRXU3pEAWQxai3Iu8uOyfmjrC56Xh46g8HRvX1y37hpnyuHPaqkEkuScMKiUC9VCTCQeKuhyRVt0K(JoqNsgz9crkCTmC9NpCTSCTAY1l1Hyz1laKBrkEkumiiPoC4AvCn29(XtdgvykaKINcfRGjjIlx)lxlNkbj1b267enP)Od0PKrwVqKcxldx)5dxJDVF80GrfMcaP4PqXkysI4Y1JpW1n4dxlt2KWRWJS56pClYTOTfqtQrK38OQpw5rYMqqsD4K)jBIlXcLGYMYY1YY1y37hpnyR)WTi3I2wanPgbRGjjIlx)lxlNkbj1bgPGM0F0b6uYiRxO13jxRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxldx)5dxllxJDVF80GT(d3IClABb0KAeScMKiUC9axNexRIRLEwlJkmfac3svdWUlHtGRhFGRLtLGK6aJCaT(ort6pc3svdC5Az4Az4AvCT0ZAz1laKBrkEkuSJNgztcVcpYMuHPaqkEku5npQ6QrEKSjeKuho5FYM4sSqjOSP0ZAz1laKBrkEkuSJNgCTkUwwUwwUg7E)4PbB9hUf5w02cOj1iyfmjrC56F5AJNexRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxldx)5dxllxJDVF80GT(d3IClABb0KAeScMKiUC9axNexRIRLEwlJkmfac3svdWUlHtGRhFGRLtLGK6aJCaT(ort6pc3svdC5Az4Az4AvCTSCn29(XtdgvykaKINcfRGjjIlx)lxRUX56pF46di9Sw26pClYTOTfqtQrWEkCTmztcVcpYM1laKBrkEku5npQ6JX8iztiiPoCY)KnXLyHsqztS79JNgmQWuaiVKyfmjrC56F5A1GR)8HRvtUEPoelJkmfaYljgeKuhoztcVcpYM3wHDfrdsXtHkV5rvFmKhjBcbj1Ht(NSjUeluckBk9Sw2bOTvYRaypfUwfxFaPN1Yw)HBrUfTTaAsnc2tHRvX1hq6zTS1F4wKBrBlGMuJGvWKeXLRhFGRLEwltPGleya5w0ueh2K(JUlHtGRhB5AcVcpyuHPaqsD6Um4pGFlGwXeYMeEfEKnvk4cbgqUfnfXjV5rvxTKhjBcbj1Ht(NSjUeluckBk9Sw2bOTvYRaypfUwfxllxllxVuhILvW1dkWadcsQdhUwfxt4vihqqatbC56X56XIRLHR)8HRj8kKdiiGPaUC94CTAW1YW1Q4Az5A1KRRxawVAagvykaKKpLO6mHyzqqsD4W1F(W1lvnWYAbQVTmf8Y1)Y1jMAW1YKnj8k8iBsfMcaj1P7M38OQN4YJKnj8k8iBEFkqfUCkBcbj1Ht(N8Mh14jLhjBcbj1Ht(NSjUeluckBk9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeoHSjHxHhztQWuaijQkQbYBEuJREEKSjeKuho5FYM4sSqjOSP0ZAzuHPaq4wQAa2DjCcC9axNu2KWRWJSjvykaKxs5npQXnEEKSjeKuho5FYM4sSqjOSPSCDb2cUTKuh46pF4A1KRxbobr0W1YW1Q4APN1YOctbGWTu1aS7s4e46bUw6zTmQWuaiClvnaBs)r3LWjKnj8k8iBgW2cfAHPcC38Mh14jwEKSjeKuho5FYM4sSqjOSP0ZAz4oqfMURiAyfq4LRvX11laRxnaJkmfasewri2KzqqsD4W1Q4Az5Az56L6qSmAQ0fwbMwHhmiiPoC4AvCnHxHCabbmfWLRhNRvlCTmC9NpCnHxHCabbmfWLRhNRvdUwMSjHxHhztQWuaOP4EfD4M38OgFSYJKnHGK6Wj)t2exIfkbLnLEwld3bQW0DfrdRacVCTkUEPoelJkmfacWTodcsQdhUwfxFaPN1Yw)HBrUfTTaAsnc2tHRvX1YY1l1Hyz0uPlScmTcpyqqsD4W1F(W1eEfYbeeWuaxUECUoXX1YKnj8k8iBsfMcanf3ROd38Mh14QrEKSjeKuho5FYM4sSqjOSP0ZAz4oqfMURiAyfq4LRvX1l1Hyz0uPlScmTcpyqqsD4W1Q4AcVc5accykGlxpoxpwztcVcpYMuHPaqtX9k6WnV5rn(ymps2ecsQdN8pztCjwOeu2u6zTmQWuaiClvna7UeobUECUw6zTmQWuaiClvnaBs)r3LWjKnj8k8iBsfMcab)v6(v4rEZJA8XqEKSjeKuho5FYM4sSqjOSP0ZAzuHPaq4wQAa2DjCcC9axl9SwgvykaeULQgGnP)O7s4e4AvCTsbYrn4dtDgvykaKevf1aztcVcpYMuHPaqWFLUFfEK38OgxTKhjBkIfQ6PSiHnBoPGyk493b1IAKnfXcv9uwKyoHJGwiBQE2KWRWJSji3X0k8iBcbj1Ht(N8M3S50Ldti28i5rvpps2ecsQdN8pztCjwOeu2C6YHjel7iUlfyGR)DGRvpPSjHxHhztPUisiV5rnEEKSjHxHhztLcUqGbKBrtrCYMqqsD4K)jV5rtS8iztiiPoCY)KnXLyHsqzZPlhMqSSJ4UuGbUECUw9KYMeEfEKnPctbGMI7v0HBEZJow5rYMeEfEKnPctbG8skBcbj1Ht(N8MhvnYJKnj8k8iBAffGK60DZMqqsD4K)jV5nBQua2Ns0MhjpQ65rYMqqsD4K)jB6kzZcUWMnj8k8iBkNkbj1HSPCQqbnHSPsbkVEhbY9S5bS0RVzZKYBEuJNhjBcbj1Ht(NSPRKnVWMnj8k8iBkNkbj1HSPCQ)GSP6ztCjwOeu2uovcsQdmLcuE9ocK7C9axNexRIRRxawVAa2vO06b6UEnzqqsD4W1Q4AcVc5accykGlx)lxB8SPCQqbnHSPsbkVEhbY98MhnXYJKnHGK6Wj)t20vYMxyZMeEfEKnLtLGK6q2uo1Fq2u9SjUeluckBkNkbj1bMsbkVEhbYDUEGRtIRvX11laRxna7kuA9aDxVMmiiPoC4AvCn2LdbfllaC5DVoCTkUMWRqoGGaMc4Y1)Y1QNnLtfkOjKnvkq517iqUN38OJvEKSjeKuho5FYMUs28cB2KWRWJSPCQeKuhYMYP(dYMjLnLtfkOjKnBj5aYvGao5npQAKhjBcbj1Ht(NSPRKnVWMnj8k8iBkNkbj1HSPCQ)GSP6ztCjwOeu2uovcsQdSwsoGCfiGdxpW1jX1Q4AcVc5accykGlx)lxB8SPCQqbnHSzljhqUceWjV5rhJ5rYMqqsD4K)jB6kzZlSztcVcpYMYPsqsDiBkN6piBQE2exIfkbLnLtLGK6aRLKdixbc4W1dCDsCTkUwovcsQdmLcuE9ocK7C9axRE2uovOGMq2SLKdixbc4K38OJH8iztiiPoCY)KnDLS5f2SjHxHhzt5ujiPoKnLt9hKntkBkNkuqtiBAfb1rsVkYBEu1sEKSjeKuho5FYMUs2SGlSztcVcpYMYPsqsDiBkNkuqtiBwx0K(JoqNsgz9cT(oZMhWsV(MnvJ8MhnXLhjBcbj1Ht(NSPRKnl4cB2KWRWJSPCQeKuhYMYPcf0eYM1fnP)Od0PKrwVqLRKnpGLE9nBQg5npQ6jLhjBcbj1Ht(NSPRKnl4cB2KWRWJSPCQeKuhYMYPcf0eYM1fnP)Od0PKrwVqKs28aw613SPXtkV5rvx98iztiiPoCY)KnDLSzbxyZMeEfEKnLtLGK6q2uovOGMq2Kuqt6p6aDkzK1l067mBEal96B2u9KYBEu1nEEKSjeKuho5FYMUs2SGlSztcVcpYMYPsqsDiBkNkuqtiBwUcAs)rhOtjJSEHwFNzZdyPxFZMgpP8Mhv9elps2ecsQdN8pztxjBwWf2SjHxHhzt5ujiPoKnLtfkOjKnxFNOj9hDGoLmY6fIuYMhWsV(MntkV5rvFSYJKnHGK6Wj)t20vYMxyZMeEfEKnLtLGK6q2uo1Fq2mXYM4sSqjOSPCQeKuhyRVt0K(JoqNsgz9crkC9axNexRIRRxawVAa2rCXcLUiOkze2NtkomiiPoCYMYPcf0eYMRVt0K(JoqNsgz9crk5npQ6QrEKSjeKuho5FYMUs28cB2KWRWJSPCQeKuhYMYP(dYMQRgztCjwOeu2uovcsQdS13jAs)rhOtjJSEHifUEGRtIRvX1yxoeuSSq00Uilbzt5uHcAczZ13jAs)rhOtjJSEHiL8Mhv9XyEKSjeKuho5FYMUs28cB2KWRWJSPCQeKuhYMYP(dYMQRgztCjwOeu2uovcsQdS13jAs)rhOtjJSEHifUEGRtIRvX1ypopXYOctbGuk)iAsMbbj1HdxRIRj8kKdiiGPaUC94CDILnLtfkOjKnxFNOj9hDGoLmY6fIuYBEu1hd5rYMqqsD4K)jB6kzZlSztcVcpYMYPsqsDiBkN6piBQgztCjwOeu2uovcsQdS13jAs)rhOtjJSEHifUEGRtkBkNkuqtiBU(ort6p6aDkzK1lePK38OQRwYJKnHGK6Wj)t20vYMfCHnBs4v4r2uovcsQdzt5uHcAczZ13jAs)rhOtjJSEHkxjBEal96B204jL38OQN4YJKnHGK6Wj)t20vYMfCHnBs4v4r2uovcsQdzt5uHcAcztjQkQbqtkiKcEZMhWsV(MntkV5rnEs5rYMqqsD4K)jB6kzZlSztcVcpYMYPsqsDiBkN6piBklxpgtIRvRGRLLRN0DHkzKCQ)aUESLRvpPK4Az4AzYM4sSqjOSPCQeKuhysuvudGMuqif8Y1dCDsCTkUg7YHGILfIM2fzjiBkNkuqtiBkrvrnaAsbHuWBEZJAC1ZJKnHGK6Wj)t20vYMxyZMeEfEKnLtLGK6q2uo1Fq2uwUwTKexRwbxllxpP7cvYi5u)bC9ylxREsjX1YW1YKnXLyHsqzt5ujiPoWKOQOganPGqk4LRh46KYMYPcf0eYMsuvudGMuqif8M38Og345rYMqqsD4K)jB6kzZcUWMnj8k8iBkNkbj1HSPCQqbnHSjPGMIqmFt0KccPG3S5bS0RVzZKYBEuJNy5rYMqqsD4K)jB6kzZlSztcVcpYMYPsqsDiBkN6piBQgjLnXLyHsqzt5ujiPoWif0ueI5BIMuqif8Y1dCDsCTkUUEby9QbyhXflu6IGQKryFoP4WGGK6WjBkNkuqtiBskOPieZ3enPGqk4nV5rn(yLhjBcbj1Ht(NSPRKnVWMnj8k8iBkNkbj1HSPCQ)GSPAKu2exIfkbLnLtLGK6aJuqtriMVjAsbHuWlxpW1jX1Q466fG1RgG1uIBpzKalWDGbbj1Ht2uovOGMq2KuqtriMVjAsbHuWBEZJAC1ips2ecsQdN8pztxjBEHnBs4v4r2uovcsQdzt5u)bzt1vJSjUeluckBkNkbj1bgPGMIqmFt0KccPGxUEGRtkBkNkuqtiBskOPieZ3enPGqk4nV5rn(ymps2ecsQdN8pztxjBwWf2SjHxHhzt5ujiPoKnLtfkOjKnxFNOj9hHBPQbUzZdyPxFZMgpV5rn(yips2ecsQdN8pztxjBwWf2SjHxHhzt5ujiPoKnLtfkOjKnfHCOw4GCfiGkBEal96B2mP8Mh14QL8iztiiPoCY)KnDLS5f2SjHxHhzt5ujiPoKnLt9hKnvpBIlXcLGYMYPsqsDGjc5qTWb5kqafxpW1jX1Q46L6qSS6faYTifpfkgeKuhoCTkUwwUEPoelJkmfacWTodcsQdhU(ZhUwn5ASlhckwwcjxck4Az4AvCTSCTAY1yxoeuSSaWL396W1F(W1eEfYbeeWuaxUEGRvNR)8HRRxawVAa2vO06b6UEnzqqsD4W1YKnLtfkOjKnfHCOw4GCfiGkV5rnEIlps2ecsQdN8pztxjBEHnBs4v4r2uovcsQdzt5u)bzZKYM4sSqjOSPCQeKuhyIqoulCqUceqX1dCDszt5uHcAcztrihQfoixbcOYBE0elP8iztiiPoCY)KnDLS5f2SjHxHhzt5ujiPoKnLt9hKnHX0tOOah2KWKubOBlalA(Ucmx)5dxdJPNqrboSMoDe061fjrNgGR)8HRHX0tOOahwtNocA96IMWH6DHhC9NpCnmMEcff4WouLW09aDaCciL3wWfdbg46pF4Aym9ekkWHjIlUElj1b0y6rX(MOdixGbU(ZhUggtpHIcCyx)17WUIObvpPK56pF4Aym9ekkWHDFHu39dIMW2M8D56pF4Aym9ekkWHLsjabuxKT84W1F(W1Wy6juuGdZ2PjGClsI2Tdzt5uHcAcztsb5b6DH8MhnXupps2ecsQdN8pztxjBwWf2SjHxHhzt5ujiPoKnLtfkOjKnjhqRVt0K(JWTu1a3S5bS0RVztJN38OjMXZJKnHGK6Wj)t20vYMxyZMeEfEKnLtLGK6q2uo1Fq2u9SjUeluckBkNkbj1bwljhqUceWHRh46K4AvC9f2venxgnrxfAY1dCT6zt5uHcAczZwsoGCfiGtEZJMyjwEKSjeKuho5FYMUs2SGlSztcVcpYMYPsqsDiBkNkuqtiBcYDKcEZMhWsV(MnvxnYBE0eBSYJKnHGK6Wj)tEZJMyQrEKSjeKuho5FYBE0eBmMhjBcbj1Ht(N8MhnXgd5rYMeEfEKnVV50devykaKLMIUGQSjeKuho5FYBE0etTKhjBs4v4r2Kkmfasel07aEZMqqsD4K)jV5rtSexEKSjHxHhztShQv(kanPGqnWmBcbj1Ht(N8MhDSskps2ecsQdN8p5np6yPEEKSjHxHhzZPOkVqIj1aztiiPoCY)K38OJLXZJKnHGK6Wj)t2exIfkbLnvtUwovcsQdmLcuE9ocK7C9axRoxRIRRxawVAa2rCXcLUiOkze2NtkomiiPoCYMeEfEKnTLFxjVV5np6yLy5rYMqqsD4K)jBIlXcLGYMQjxlNkbj1bMsbkVEhbYDUEGRvNRvX1QjxxVaSE1aSJ4IfkDrqvYiSpNuCyqqsD4Knj8k8iBsfMcaj1P7M38OJ1yLhjBcbj1Ht(NSjUeluckBkNkbj1bMsbkVEhbYDUEGRvpBs4v4r2eK7yAfEK38MnPj6QqZ8i5rvpps2ecsQdN8pztCjwOeu2CsbXuWlxp(axlNkbj1bgi3rk4LRvX1YY1y37hpnyR)WTi3I2wanPgbRGjjIlxp(axt4v4bdK7yAfEWG)a(TaAftGR)8HRXU3pEAWOctbGu8uOyfmjrC56Xh4AcVcpyGChtRWdg8hWVfqRycC9NpCTSC9sDiww9ca5wKINcfdcsQdhUwfxJDVF80GvVaqUfP4PqXkysI4Y1JpW1eEfEWa5oMwHhm4pGFlGwXe4Az4Az4AvCT0ZAz1laKBrkEkuSJNgCTkUw6zTmQWuaifpfk2XtdUwfxFaPN1Yw)HBrUfTTaAsnc2XtJSjHxHhztqUJPv4rEZJA88iztiiPoCY)KnXLyHsqztS79JNgmQWuaifpfkwbtsexUEGRtIRvX1YY1spRLvVaqUfP4PqXoEAW1Q4Az5AS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aJuqt6p6aDkzK1l067KR)8HRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRLHRLjBs4v4r28a02k5va5npAILhjBcbj1Ht(NSjUeluckBIDVF80GrfMcaP4PqXkysI4Y1dCDsCTkUwwUw6zTS6faYTifpfk2XtdUwfxllxJDVF80GT(d3IClABb0KAeScMKiUC9VCTCQeKuhyKcAs)rhOtjJSEHwFNC9NpCn29(Xtd26pClYTOTfqtQrWkysI4Y1dCDsCTmCTmztcVcpYMtrvEDrUfTEnHyZBE0Xkps2KWRWJSzrhbfl6QqvcztiiPoCY)K38OQrEKSjeKuho5FYM4sSqjOSP0ZAzuHPaqkEkuSJNgCTkUg7E)4PbJkmfasXtHIT1dqfmjrC56F5AcVcpy3wHDfrdsXtHIHpfxRIRLEwlREbGClsXtHID80GRvX1y37hpny1laKBrkEkuSTEaQGjjIlx)lxt4v4b72kSRiAqkEkum8P4AvC9bKEwlB9hUf5w02cOj1iyhpnYMeEfEKnVTc7kIgKINcvEZJogZJKnHGK6Wj)t2exIfkbLnLEwlREbGClsXtHID80GRvX1y37hpnyuHPaqkEkuScMKiUztcVcpYM1laKBrkEku5np6yips2ecsQdN8pztCjwOeu2uwUg7E)4PbJkmfasXtHIvWKeXLRh46K4AvCT0ZAz1laKBrkEkuSJNgCTmC9NpCTsbYrn4dtDw9ca5wKINcv2KWRWJS56pClYTOTfqtQrK38OQL8iztiiPoCY)KnXLyHsqztS79JNgmQWuaifpfkwbtsexUECUwnsIRvX1spRLvVaqUfP4PqXoEAW1Q4A4EHadm5IRWdKBrkqzb8k8Gbbj1Ht2KWRWJS56pClYTOTfqtQrK38OjU8iztiiPoCY)KnXLyHsqztPN1YQxai3Iu8uOyhpn4AvCn29(Xtd26pClYTOTfqtQrWkysI4Y1)Y1YPsqsDGrkOj9hDGoLmY6fA9DMnj8k8iBsfMcaP4PqL38OQNuEKSjeKuho5FYM4sSqjOSP0ZAzuHPaqkEkuSNcxRIRLEwlJkmfasXtHIvWKeXLRhFGRj8k8GrfMcanf3ROdxg8hWVfqRycCTkUw6zTmQWuaiClvna7UeobUEGRLEwlJkmfac3svdWM0F0DjCcztcVcpYMuHPaqsuvudK38OQREEKSjeKuho5FYM4sSqjOSP0ZAzuHPaq4wQAa2DjCcC94CT0ZAzuHPaq4wQAa2K(JUlHtGRvX1spRLvVaqUfP4PqXoEAW1Q4APN1YOctbGu8uOyhpn4AvC9bKEwlB9hUf5w02cOj1iyhpnYMeEfEKnPctbG8skV5rv345rYMqqsD4K)jBIlXcLGYMspRLvVaqUfP4PqXoEAW1Q4APN1YOctbGu8uOyhpn4AvC9bKEwlB9hUf5w02cOj1iyhpn4AvCT0ZAzuHPaq4wQAa2DjCcC9axl9SwgvykaeULQgGnP)O7s4eYMeEfEKnPctbGKOQOgiV5rvpXYJKnHGK6Wj)t2e3sIiBQE2eOQNmc3sIajSztPN1YWDGkmDxr0GWTueqND80qLSspRLrfMcaP4PqXEkF(i9Sww9ca5wKINcf7P85d29(Xtdgi3X0k8GvaDswMSjUeluckBk9SwgUduHP7kIgwbeEZMeEfEKnPctbGMI7v0HBEZJQ(yLhjBcbj1Ht(NSjULer2u9SjqvpzeULebsyZMspRLH7avy6UIObHBPiGo74PHkzLEwlJkmfasXtHI9u(8r6zTS6faYTifpfk2t5ZhS79JNgmqUJPv4bRa6KSmztCjwOeu2un5AkXduIfyuHPaqkV5e6IOHbbj1Hdx)5dxl9SwgUduHP7kIgeULIa6SJNgztcVcpYMuHPaqtX9k6WnV5rvxnYJKnHGK6Wj)t2exIfkbLnLEwlREbGClsXtHID80GRvX1spRLrfMcaP4PqXoEAW1Q46di9Sw26pClYTOTfqtQrWoEAKnj8k8iBcYDmTcpYBEu1hJ5rYMqqsD4K)jBIlXcLGYMspRLrfMcaHBPQby3LWjW1JZ1spRLrfMcaHBPQbyt6p6UeoHSjHxHhztQWuaiVKYBEu1hd5rYMeEfEKnPctbGKOQOgiBcbj1Ht(N8MhvD1sEKSjHxHhztQWuaiPoD3SjeKuho5FYBEZM3wQGdcFU5rYJQEEKSjeKuho5FYM4sSqjOSPSC9sDiwgeDrt7cbCyqqsD4W1Q46jfetbVC94dCTAjjUwfxpPGyk4LR)DGRhJQbxldx)5dxllxRMC9sDiwgeDrt7cbCyqqsD4W1Q46jfetbVC94dCTArn4AzYMeEfEKnNuqOgyM38Ogpps2ecsQdN8pztCjwOeu2u6zTmQWuaifpfk2tjBs4v4r2uXxHh5npAILhjBcbj1Ht(NSjUeluckBwVaSE1aSfMkErDukvkmiiPoC4AvCT0ZAzW)w6DxHhSNcxRIRLLRXU3pEAWOctbGu8uOyfqNK56pF4AROPDrfmjrC56Xh46XkjUwMSjHxHhzZvmbukvk5np6yLhjBcbj1Ht(NSjUeluckBk9SwgvykaKINcf74PbxRIRLEwlREbGClsXtHID80GRvX1hq6zTS1F4wKBrBlGMuJGD80iBs4v4r2SlAA3lsTY3PzcXM38OQrEKSjeKuho5FYM4sSqjOSP0ZAzuHPaqkEkuSJNgCTkUw6zTS6faYTifpfk2XtdUwfxFaPN1Yw)HBrUfTTaAsnc2XtJSjHxHhztjQb5w0wcCc38MhDmMhjBcbj1Ht(NSjUeluckBk9SwgvykaKINcf7PKnj8k8iBkb1fQeertEZJogYJKnHGK6Wj)t2exIfkbLnLEwlJkmfasXtHI9uYMeEfEKnL6UFq2xLCEZJQwYJKnHGK6Wj)t2exIfkbLnLEwlJkmfasXtHI9uYMeEfEKnTIcK6UFYBE0exEKSjeKuho5FYM4sSqjOSP0ZAzuHPaqkEkuSNs2KWRWJSjfy4Uf1ryQ3ZBEu1tkps2ecsQdN8pztCjwOeu2u6zTmQWuaifpfk2tjBs4v4r28DbKyH5nV5rvx98iztiiPoCY)Knj8k8iB20PJGwVUij60aztCjwOeu2u6zTmQWuaifpfk2tHR)8HRXU3pEAWOctbGu8uOyfmjrC56Fh4A1qn4AvC9bKEwlB9hUf5w02cOj1iypLSjyTaErbnHSztNocA96IKOtdK38OQB88iztiiPoCY)Knj8k8iBctLKlG6iVobfyiBIlXcLGYMy37hpnyuHPaqkEkuScMKiUC94dCTXtkBg0eYMWuj5cOoYRtqbgYBEu1tS8iztiiPoCY)Knj8k8iBEkGowrbi5W9c9SjUeluckBIDVF80GrfMcaP4PqXkysI4Y1)oW1gpjU(ZhUwn5A5ujiPoWifKhO3f46bUwDU(ZhUwwUEftGRh46K4AvCTCQeKuhyIqoulCqUceqX1dCT6CTkUUEby9QbyxHsRhO761Kbbj1Hdxlt2mOjKnpfqhROaKC4EHEEZJQ(yLhjBcbj1Ht(NSjHxHhzZR)6irtiwOYM4sSqjOSj29(XtdgvykaKINcfRGjjIlx)7axB8K46pF4A1KRLtLGK6aJuqEGExGRh4A156pF4Az56vmbUEGRtIRvX1YPsqsDGjc5qTWb5kqafxpW1QZ1Q466fG1RgGDfkTEGURxtgeKuhoCTmzZGMq286Vos0eIfQ8MhvD1ips2ecsQdN8pztcVcpYMn9KvArUfr3Ryk60k8iBIlXcLGYMy37hpnyuHPaqkEkuScMKiUC9VdCTXtIR)8HRvtUwovcsQdmsb5b6DbUEGRvNR)8HRLLRxXe46bUojUwfxlNkbj1bMiKd1chKRabuC9axRoxRIRRxawVAa2vO06b6UEnzqqsD4W1YKndAczZMEYkTi3IO7vmfDAfEK38OQpgZJKnHGK6Wj)t2KWRWJS5KWKubOBlalA(UcC2exIfkbLnXU3pEAWOctbGu8uOyfmjrC56Xh4A1GRvX1YY1QjxlNkbj1bMiKd1chKRabuC9axRox)5dxVIjW1)Y1jwsCTmzZGMq2CsysQa0TfGfnFxboV5rvFmKhjBcbj1Ht(NSjHxHhzZjHjPcq3waw08Df4SjUeluckBIDVF80GrfMcaP4PqXkysI4Y1JpW1QbxRIRLtLGK6ateYHAHdYvGakUEGRvNRvX1spRLvVaqUfP4PqXEkCTkUw6zTS6faYTifpfkwbtsexUE8bUwwUw9K4A1k4A1GRhB566fG1RgGDfkTEGURxtgeKuhoCTmCTkUEftGRhNRtSKYMbnHS5KWKubOBlalA(UcCEZB2e7E)4PXnpsEu1ZJKnHGK6Wj)t2exIfkbLnRxawVAawtjU9KrcSa3bgeKuhoCTkUg7E)4PbJkmfasXtHIvWKeXLR)LRtSK4AvCn29(Xtd26pClYTOTfqtQrWkysI4Y1dCDsCTkUwwUw6zTmQWuaiClvna7UeobUE8bUwovcsQdS13jAs)r4wQAGlxRIRLLRLLRxQdXYQxai3Iu8uOyqqsD4W1Q4AS79JNgS6faYTifpfkwbtsexUE8bUUbF4AvCn29(XtdgvykaKINcfRGjjIlx)lxlNkbj1b267enP)Od0PKrwVqKcxldx)5dxllxRMC9sDiww9ca5wKINcfdcsQdhUwfxJDVF80GrfMcaP4PqXkysI4Y1)Y1YPsqsDGT(ort6p6aDkzK1lePW1YW1F(W1y37hpnyuHPaqkEkuScMKiUC94dCDd(W1YW1YKnj8k8iBAl)UOWLt5npQXZJKnHGK6Wj)t2exIfkbLnRxawVAawtjU9KrcSa3bgeKuhoCTkUg7E)4PbJkmfasXtHIvWKeXLRh46K4AvCTSCTAY1l1Hyzq0fnTleWHbbj1Hdx)5dxllxVuhILbrx00UqahgeKuhoCTkUEsbXuWlx)7axpgsIRLHRLHRvX1YY1YY1y37hpnyR)WTi3I2wanPgbRGjjIlx)lxREsCTkUw6zTmQWuaiClvna7UeobUEGRLEwlJkmfac3svdWM0F0DjCcCTmC9NpCTSCn29(Xtd26pClYTOTfqtQrWkysI4Y1dCDsCTkUw6zTmQWuaiClvna7UeobUEGRtIRLHRLHRvX1spRLvVaqUfP4PqXoEAW1Q46jfetbVC9VdCTCQeKuhyKcAkcX8nrtkiKcEZMeEfEKnTLFxu4YP8MhnXYJKnHGK6Wj)t2exIfkbLnRxawVAa2rCXcLUiOkze2NtkomiiPoC4AvCn29(XtdM0ZArhXflu6IGQKryFoP4WkGojZ1Q4APN1YoIlwO0fbvjJW(CsXbzl)USJNgCTkUwwUw6zTmQWuaifpfk2XtdUwfxl9Sww9ca5wKINcf74PbxRIRpG0ZAzR)WTi3I2wanPgb74PbxldxRIRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1YY1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGT(ort6pc3svdC5AvCTSCTSC9sDiww9ca5wKINcfdcsQdhUwfxJDVF80GvVaqUfP4PqXkysI4Y1JpW1n4dxRIRXU3pEAWOctbGu8uOyfmjrC56F5A5ujiPoWwFNOj9hDGoLmY6fIu4Az46pF4Az5A1KRxQdXYQxai3Iu8uOyqqsD4W1Q4AS79JNgmQWuaifpfkwbtsexU(xUwovcsQdS13jAs)rhOtjJSEHifUwgU(ZhUg7E)4PbJkmfasXtHIvWKeXLRhFGRBWhUwgUwMSjHxHhztB53vY7BEZJow5rYMqqsD4K)jBIlXcLGYM1laRxna7iUyHsxeuLmc7ZjfhgeKuhoCTkUg7E)4Pbt6zTOJ4IfkDrqvYiSpNuCyfqNK5AvCT0ZAzhXflu6IGQKryFoP4GSIcyhpn4AvCTsbYrn4dtDMT87k59nBs4v4r20kkaj1P7M38OQrEKSjeKuho5FYM4sSqjOSj29(Xtd26pClYTOTfqtQrWkysI4Y1dCDsCTkUw6zTmQWuaiClvna7UeobUE8bUwovcsQdS13jAs)r4wQAGlxRIRXU3pEAWOctbGu8uOyfmjrC56Xh46g8jBs4v4r2CkQYRlYTO1RjeBEZJogZJKnHGK6Wj)t2exIfkbLnXU3pEAWOctbGu8uOyfmjrC56bUojUwfxllxRMC9sDiwgeDrt7cbCyqqsD4W1F(W1YY1l1Hyzq0fnTleWHbbj1HdxRIRNuqmf8Y1)oW1JHK4Az4Az4AvCTSCTSCn29(Xtd26pClYTOTfqtQrWkysI4Y1)Y1YPsqsDGrkOj9hDGoLmY6fA9DY1Q4APN1YOctbGWTu1aS7s4e46bUw6zTmQWuaiClvnaBs)r3LWjW1YW1F(W1YY1y37hpnyR)WTi3I2wanPgbRGjjIlxpW1jX1Q4APN1YOctbGWTu1aS7s4e46bUojUwgUwgUwfxl9Sww9ca5wKINcf74PbxRIRNuqmf8Y1)oW1YPsqsDGrkOPieZ3enPGqk4nBs4v4r2CkQYRlYTO1RjeBEZJogYJKnHGK6Wj)t2exIfkbLnXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1spRLrfMcaHBPQby3LWjW1JpW1YPsqsDGT(ort6pc3svdC5AvCn29(XtdgvykaKINcfRGjjIlxp(ax3GpztcVcpYMhG2wjVciV5rvl5rYMqqsD4K)jBIlXcLGYMy37hpnyuHPaqkEkuScMKiUC9axNexRIRLLRvtUEPoeldIUOPDHaomiiPoC46pF4Az56L6qSmi6IM2fc4WGGK6WHRvX1tkiMcE56Fh46XqsCTmCTmCTkUwwUwwUg7E)4PbB9hUf5w02cOj1iyfmjrC56F5A1tIRvX1spRLrfMcaHBPQby3LWjW1dCT0ZAzuHPaq4wQAa2K(JUlHtGRLHR)8HRLLRXU3pEAWw)HBrUfTTaAsncwbtsexUEGRtIRvX1spRLrfMcaHBPQby3LWjW1dCDsCTmCTmCTkUw6zTS6faYTifpfk2XtdUwfxpPGyk4LR)DGRLtLGK6aJuqtriMVjAsbHuWB2KWRWJS5bOTvYRaYBE0exEKSjeKuho5FYM4sSqjOSj29(Xtd26pClYTOTfqtQrWkysI4Y1)Y1YPsqsDGvx0K(JoqNsgz9cT(o5AvCn29(XtdgvykaKINcfRGjjIlx)lxlNkbj1bwDrt6p6aDkzK1lePW1Q4Az56L6qSS6faYTifpfkgeKuhoCTkUwwUg7E)4PbREbGClsXtHIvWKeXLRhNRH)a(TaAftGR)8HRXU3pEAWQxai3Iu8uOyfmjrC56F5A5ujiPoWQlAs)rhOtjJSEHkxHRLHR)8HRvtUEPoelREbGClsXtHIbbj1HdxldxRIRLEwlJkmfac3svdWUlHtGR)LRnoxRIRpG0ZAzR)WTi3I2wanPgb74PbxRIRLEwlREbGClsXtHID80GRvX1spRLrfMcaP4PqXoEAKnj8k8iBw0rqXIUkuLqEZJQEs5rYMqqsD4K)jBIlXcLGYMy37hpnyR)WTi3I2wanPgbRGjjIlxpoxd)b8Bb0kMaxRIRLEwlJkmfac3svdWUlHtGRhFGRLtLGK6aB9DIM0FeULQg4Y1Q4AS79JNgmQWuaifpfkwbtsexUECUwwUg(d43cOvmbU(BUMWRWd26pClYTOTfqtQrWG)a(TaAftGRLjBs4v4r2SOJGIfDvOkH8MhvD1ZJKnHGK6Wj)t2exIfkbLnXU3pEAWOctbGu8uOyfmjrC56X5A4pGFlGwXe4AvCTSCTSCTAY1l1Hyzq0fnTleWHbbj1Hdx)5dxllxVuhILbrx00UqahgeKuhoCTkUEsbXuWlx)7axpgsIRLHRLHRvX1YY1YY1y37hpnyR)WTi3I2wanPgbRGjjIlx)lxlNkbj1bgPGM0F0b6uYiRxO13jxRIRLEwlJkmfac3svdWUlHtGRh4APN1YOctbGWTu1aSj9hDxcNaxldx)5dxllxJDVF80GT(d3IClABb0KAeScMKiUC9axNexRIRLEwlJkmfac3svdWUlHtGRh46K4Az4Az4AvCT0ZAz1laKBrkEkuSJNgCTkUEsbXuWlx)7axlNkbj1bgPGMIqmFt0KccPGxUwMSjHxHhzZIockw0vHQeYBEu1nEEKSjeKuho5FYM4sSqjOSP0ZAzuHPaq4wQAa2DjCcC94dCTCQeKuhyRVt0K(JWTu1axUwfxJDVF80GrfMcaP4PqXkysI4Y1JpW1WFa)waTIjW1Q46jfetbVC9VCTCQeKuhyKcAkcX8nrtkiKcE5AvCT0ZAz1laKBrkEkuSJNgztcVcpYMR)WTi3I2wanPgrEZJQEILhjBcbj1Ht(NSjUeluckBk9SwgvykaeULQgGDxcNaxp(axlNkbj1b267enP)iClvnWLRvX1l1Hyz1laKBrkEkumiiPoC4AvCn29(Xtdw9ca5wKINcfRGjjIlxp(axd)b8Bb0kMaxRIRXU3pEAWOctbGu8uOyfmjrC56F5A5ujiPoWwFNOj9hDGoLmY6fIuYMeEfEKnx)HBrUfTTaAsnI8Mhv9Xkps2ecsQdN8pztCjwOeu2u6zTmQWuaiClvna7UeobUE8bUwovcsQdS13jAs)r4wQAGlxRIRLLRvtUEPoelREbGClsXtHIbbj1Hdx)5dxJDVF80GvVaqUfP4PqXkysI4Y1)Y1YPsqsDGT(ort6p6aDkzK1lu5kCTmCTkUg7E)4PbJkmfasXtHIvWKeXLR)LRLtLGK6aB9DIM0F0b6uYiRxisjBs4v4r2C9hUf5w02cOj1iYBEu1vJ8iztiiPoCY)KnXLyHsqztS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aJuqt6p6aDkzK1l067KRvX1spRLrfMcaHBPQby3LWjW1dCT0ZAzuHPaq4wQAa2K(JUlHtGRvX1spRLvVaqUfP4PqXoEAW1Q46jfetbVC9VdCTCQeKuhyKcAkcX8nrtkiKcEZMeEfEKnPctbGu8uOYBEu1hJ5rYMqqsD4K)jBIlXcLGYMspRLrfMcaP4PqXoEAW1Q4Az5AS79JNgS1F4wKBrBlGMuJGvWKeXLR)LRLtLGK6aRCf0K(JoqNsgz9cT(o56pF4AS79JNgmQWuaifpfkwbtsexUE8bUwovcsQdS13jAs)rhOtjJSEHifUwgUwfxl9SwgvykaeULQgGDxcNaxpW1spRLrfMcaHBPQbyt6p6UeobUwfxJDVF80GrfMcaP4PqXkysI4Y1)Y1QB8SjHxHhzZ6faYTifpfQ8Mhv9XqEKSjeKuho5FYM4sSqjOSP0ZAzuHPaqkEkuSJNgCTkUg7E)4PbJkmfasXtHIT1dqfmjrC56F5AcVcpy3wHDfrdsXtHIHpfxRIRLEwlREbGClsXtHID80GRvX1y37hpny1laKBrkEkuSTEaQGjjIlx)lxt4v4b72kSRiAqkEkum8P4AvC9bKEwlB9hUf5w02cOj1iyhpnYMeEfEKnVTc7kIgKINcvEZJQUAjps2ecsQdN8pztCjwOeu2CPoelREbGClsXtHIbbj1HdxRIRLEwlJkmfasXtHI9u4AvCT0ZAz1laKBrkEkuScMKiUC94CDd(WM0)SjHxHhztLcUqGbKBrtrCYBEu1tC5rYMqqsD4K)jBIlXcLGYMhq6zTS1F4wKBrBlGMuJG9u4AvC9bKEwlB9hUf5w02cOj1iyfmjrC56X5AcVcpyuHPaqtX9k6WLb)b8Bb0kMaxRIRvtUg7YHGILLqYLGISjHxHhztLcUqGbKBrtrCYBEuJNuEKSjeKuho5FYM4sSqjOSP0ZAz1laKBrkEkuSNcxRIRLEwlREbGClsXtHIvWKeXLRhNRBWh2K(Z1Q4AS79JNgmqUJPv4bRa6KmxRIRXU3pEAWw)HBrUfTTaAsncwbtsexUwfxRMCn2LdbfllHKlbfztcVcpYMkfCHadi3IMI4K38MnTIG6iPxf5rYJQEEKSjeKuho5FYMeEfEKnPctbGMI7v0HB2e3sIiBQE2exIfkbLnLEwld3bQW0DfrdRacV5npQXZJKnj8k8iBsfMcaj1P7MnHGK6Wj)tEZJMy5rYMeEfEKnPctbGKOQOgiBcbj1Ht(N8M38MnLd1v4rEuJNKXtsDJN0ymBMsviIMB2mX3yUA1rhZgnXRXW1C9iTaxlMkETCT1lU2ixbcOmIRlym9efC46RpbUMERpPfoCnULIg4Y4gO2Ia4A1ngU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSQ)xgg3a1weaxRUXW1gRhYHAHdxBu9cW6vdWsKrC96CTr1laRxnalrmiiPoCmIRL14)LHXnqTfbW1g3y4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YQ(FzyCduBraCDIzmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaUESmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCnTCTATe)QnxlR6)LHXnqTfbW1QNKXW1gRhYHAHdxBu9cW6vdWsKrC96CTr1laRxnalrmiiPoCmIRL14)LHXnqTfbW1QpgmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSQ)xgg3a1weaxB8KmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxB8KmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCnTCTATe)QnxlR6)LHXnqTfbW1g34gdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUww1)ldJBa3GeFJ5QvhDmB0eVgdxZ1J0cCTyQ41Y1wV4AJihmIRlym9efC46RpbUMERpPfoCnULIg4Y4gO2Ia4A1ngU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUwDJHRnwpKd1chU2O6fG1RgGLiJ4615AJQxawVAawIyqqsD4yexlR6)LHXnqTfbW1g3y4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YA8)YW4gO2Ia46eZy4AJ1d5qTWHRnAPoellrgX1RZ1gTuhILLigeKuhogX1YA8)YW4gO2Ia46eZy4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YQ(FzyCduBraC9yzmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaUwnmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxpgngU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxpgmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxRwmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxN4mgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUw9KmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUw9eZy4AJ1d5qTWHRnAPoellrgX1RZ1gTuhILLigeKuhogX1YA8)YW4gO2Ia4A1hJgdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUMwUwTwIF1MRLv9)YW4gO2Ia4A1vlgdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUww1)ldJBGAlcGRvxTymCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaU24jMXW1gRhYHAHdxB0sDiwwImIRxNRnAPoellrmiiPoCmIRLv9)YW4gO2Ia4AJNygdxBSEihQfoCTr1laRxnalrgX1RZ1gvVaSE1aSeXGGK6WXiUww1)ldJBGAlcGRn(yzmCTX6HCOw4W1gTuhILLiJ4615AJwQdXYsedcsQdhJ4Azn(FzyCduBraCTXvdJHRnwpKd1chU2OL6qSSezexVoxB0sDiwwIyqqsD4yexlR6)LHXnGBqIVXC1QJoMnAIxJHR56rAbUwmv8A5ARxCTrLV0k8WiUUGX0tuWHRV(e4A6T(Kw4W14wkAGlJBGAlcGRv3y4AJ1d5qTWHRnAPoellrgX1RZ1gTuhILLigeKuhogX1YQ(FzyCduBraCTXngU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxpwgdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUww1)ldJBGAlcGRvdJHRnwpKd1chU2OL6qSSezexVoxB0sDiwwIyqqsD4yexlR6)LHXnqTfbW1joJHRnwpKd1chU2OL6qSSezexVoxB0sDiwwIyqqsD4yexlR6)LHXnqTfbW1QN4mgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSQ)xgg3a1weaxB8eZy4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YQ(FzyCduBraCTXhlJHRnwpKd1chU2O6fG1RgGLiJ4615AJQxawVAawIyqqsD4yexlR6)LHXnGBqIVXC1QJoMnAIxJHR56rAbUwmv8A5ARxCTrhWsV(AexxWy6jk4W1xFcCn9wFslC4AClfnWLXnqTfbW1g3y4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YA8)YW4gO2Ia46eZy4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YA8)YW4gO2Ia46XYy4AJ1d5qTWHRnftJLRVjhl9NRvRhxVoxR2pIRpc5IRWdU2vGIwV4Az)sgUww1)ldJBa3GeFJ5QvhDmB0eVgdxZ1J0cCTyQ41Y1wV4AJuka7tjAnIRlym9efC46RpbUMERpPfoCnULIg4Y4gO2Ia4AJBmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaUoXmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxR(yzmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4AA5A1Aj(vBUww1)ldJBGAlcGRvFmAmCTX6HCOw4W1gH948ellrgX1RZ1gH948ellrmiiPoCmIRLv9)YW4gO2Ia4AJNygdxBSEihQfoCTr1laRxnalrgX1RZ1gvVaSE1aSeXGGK6WXiUMwUwTwIF1MRLv9)YW4gO2Ia4AJpwgdxBSEihQfoCTr1laRxnalrgX1RZ1gvVaSE1aSeXGGK6WXiUMwUwTwIF1MRLv9)YW4gO2Ia4AJRwmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaU24QfJHRnwpKd1chU2O6fG1RgGLiJ4615AJQxawVAawIyqqsD4yexlR6)LHXnqTfbW1JLXngU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCnTCTATe)QnxlR6)LHXnqTfbW1JvIzmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4AA5A1Aj(vBUww1)ldJBa3GeFJ5QvhDmB0eVgdxZ1J0cCTyQ41Y1wV4AJWU3pEACnIRlym9efC46RpbUMERpPfoCnULIg4Y4gO2Ia4A1ngU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUwDJHRnwpKd1chU2O6fG1RgGLiJ4615AJQxawVAawIyqqsD4yexlR6)LHXnqTfbW1g3y4AJ1d5qTWHRnAPoellrgX1RZ1gTuhILLigeKuhogX1YA8)YW4gO2Ia4AJBmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaUoXmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUoXmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3a1weaxpwgdxBSEihQfoCTr1laRxnalrgX1RZ1gvVaSE1aSeXGGK6WXiUww1)ldJBGAlcGRhJgdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUwwJ)xgg3a1weaxRwmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSg)VmmUbQTiaUoXzmCTX6HCOw4W1gTuhILLiJ4615AJwQdXYsedcsQdhJ4Azn(FzyCduBraCT6QBmCTX6HCOw4W1gTuhILLiJ4615AJwQdXYsedcsQdhJ4Azn(FzyCduBraCT6jMXW1gRhYHAHdxB0sDiwwImIRxNRnAPoellrmiiPoCmIRLv9)YW4gO2Ia4A1hlJHRnwpKd1chU2OL6qSSezexVoxB0sDiwwIyqqsD4yexlR6)LHXnqTfbW1QRwmgU2y9qoulC4AJwQdXYsKrC96CTrl1HyzjIbbj1HJrCTSQ)xgg3aUbj(gZvRo6y2OjEngUMRhPf4AXuXRLRTEX1gDBPcoi85AexxWy6jk4W1xFcCn9wFslC4AClfnWLXnqTfbW1QBmCTX6HCOw4W1gTuhILLiJ4615AJwQdXYsedcsQdhJ4Azn(FzyCduBraCDIzmCTX6HCOw4W1gvVaSE1aSezexVoxBu9cW6vdWsedcsQdhJ4Azv)VmmUbQTiaUw9eZy4AJ1d5qTWHRnQEby9QbyjYiUEDU2O6fG1RgGLigeKuhogX1YQ(FzyCduBraCT6JLXW1gRhYHAHdxBu9cW6vdWsKrC96CTr1laRxnalrmiiPoCmIRLv9)YW4gO2Ia4A1vdJHRnwpKd1chU2O6fG1RgGLiJ4615AJQxawVAawIyqqsD4yexlR6)LHXnqTfbW1QpgmgU2y9qoulC4AJQxawVAawImIRxNRnQEby9QbyjIbbj1HJrCTSQ)xgg3aUbj(gZvRo6y2OjEngUMRhPf4AXuXRLRTEX1grt0vHMgX1fmMEIcoC91NaxtV1N0chUg3srdCzCduBraCT6gdxBSEihQfoCTrl1HyzjYiUEDU2OL6qSSeXGGK6WXiUww1)ldJBa3GXSPIxlC4A1tIRj8k8GR7I7EzCdYMkLBfDiBo25A16tnaxpMxykaUbJDUwToagMsqX1Qfd5AJNKXtIBa3GXoxRwfMUCGRLtLGK6aJMORcn5ArW1wsUxCTB56lSRiAUmAIUk0KRLf3c4e46K9xX1xfaZ1UYk84kdJBWyNRhBuo0chUwelub156wkoDr0W1ULRLtLGK6aRLKdixbc4W1RZ1saxRoxN2cbxFHDfrZLrt0vHMC9axRoJBWyNRhBUaxVjRiWuNRnftJLRBP40frdx7wUg3sraDUwelu1tzfEW1I4UaD4A3Y1gHPadDeHxHhgX4gm25A1A3ley4Y1fmD5WHRPlx7wUEuxomLGIRnUAHRxNRl48WaxBSQ1DSHRL92fnTBpzzyCd4gq4v4XLPua2Ns0oiNkbj1bddAcdkfO86Dei3n0vgk4cRHhWsV(oKe3acVcpUmLcW(uI2Vh(sovcsQdgg0egukq517iqUBORmCH1q5u)bdQBOWoiNkbj1bMsbkVEhbY9HKuvVaSE1aSRqP1d0D9AQIWRqoGGaMc4(RX5gq4v4XLPua2Ns0(9WxYPsqsDWWGMWGsbkVEhbYDdDLHlSgkN6pyqDdf2b5ujiPoWukq517iqUpKKQ6fG1RgGDfkTEGURxtvyxoeuSSaWL396OIWRqoGGaMc4(R6Cdi8k84Yuka7tjA)E4l5ujiPoyyqtyOLKdixbc4yORmCH1q5u)bdjXnGWRWJltPaSpLO97HVKtLGK6GHbnHHwsoGCfiGJHUYWfwdLt9hmOUHc7GCQeKuhyTKCa5kqaNHKur4vihqqatbC)14Cdi8k84Yuka7tjA)E4l5ujiPoyyqtyOLKdixbc4yORmCH1q5u)bdQBOWoiNkbj1bwljhqUceWzijvYPsqsDGPuGYR3rGCFqDUbeEfECzkfG9PeTFp8LCQeKuhmmOjmyfb1rsVkm0vgUWAOCQ)GHK4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWqDrt6p6aDkzK1l0670qxzOGlSgEal967GAWnGWRWJltPaSpLO97HVKtLGK6GHbnHH6IM0F0b6uYiRxOYvm0vgk4cRHhWsV(oOgCdi8k84Yuka7tjA)E4l5ujiPoyyqtyOUOj9hDGoLmY6fIum0vgk4cRHhWsV(oy8K4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWaPGM0F0b6uYiRxO13PHUYqbxyn8aw613b1tIBaHxHhxMsbyFkr73dFjNkbj1bddAcdLRGM0F0b6uYiRxO13PHUYqbxyn8aw613bJNe3acVcpUmLcW(uI2Vh(sovcsQdgg0egwFNOj9hDGoLmY6fIum0vgk4cRHhWsV(oKe3acVcpUmLcW(uI2Vh(sovcsQdgg0egwFNOj9hDGoLmY6fIum0vgUWAOCQ)GHeZqHDqovcsQdS13jAs)rhOtjJSEHiLHKuvVaSE1aSJ4IfkDrqvYiSpNuC4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWW67enP)Od0PKrwVqKIHUYWfwdLt9hmOUAyOWoiNkbj1b267enP)Od0PKrwVqKYqsQWUCiOyzHOPDrwc4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWW67enP)Od0PKrwVqKIHUYWfwdLt9hmOUAyOWoiNkbj1b267enP)Od0PKrwVqKYqsQWECEILrfMcaPu(r0KSkcVc5accykG74jg3acVcpUmLcW(uI2Vh(sovcsQdgg0egwFNOj9hDGoLmY6fIum0vgUWAOCQ)Gb1WqHDqovcsQdS13jAs)rhOtjJSEHiLHK4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWW67enP)Od0PKrwVqLRyORmuWfwdpGLE9DW4jXnGWRWJltPaSpLO97HVKtLGK6GHbnHbjQkQbqtkiKcEn0vgk4cRHhWsV(oKe3acVcpUmLcW(uI2Vh(sovcsQdgg0egKOQOganPGqk41qxz4cRHYP(dgKDmMKAfYoP7cvYi5u)bJTQNusYiJHc7GCQeKuhysuvudGMuqif8oKKkSlhckwwiAAxKLaUbeEfECzkfG9PeTFp8LCQeKuhmmOjmirvrnaAsbHuWRHUYWfwdLt9hmiRAjj1kKDs3fQKrYP(dgBvpPKKrgdf2b5ujiPoWKOQOganPGqk4DijUbeEfECzkfG9PeTFp8LCQeKuhmmOjmqkOPieZ3enPGqk41qxzOGlSgEal967qsCdi8k84Yuka7tjA)E4l5ujiPoyyqtyGuqtriMVjAsbHuWRHUYWfwdLt9hmOgjzOWoiNkbj1bgPGMIqmFt0KccPG3HKuvVaSE1aSJ4IfkDrqvYiSpNuC4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWaPGMIqmFt0KccPGxdDLHlSgkN6pyqnsYqHDqovcsQdmsbnfHy(MOjfesbVdjPQEby9QbynL42tgjWcCh4gq4v4XLPua2Ns0(9WxYPsqsDWWGMWaPGMIqmFt0KccPGxdDLHlSgkN6pyqD1WqHDqovcsQdmsbnfHy(MOjfesbVdjXnGWRWJltPaSpLO97HVKtLGK6GHbnHH13jAs)r4wQAGRHUYqbxyn8aw613bJZnGWRWJltPaSpLO97HVKtLGK6GHbnHbrihQfoixbcOm0vgk4cRHhWsV(oKe3acVcpUmLcW(uI2Vh(sovcsQdgg0egeHCOw4GCfiGYqxz4cRHYP(dgu3qHDqovcsQdmrihQfoixbcOgss1sDiww9ca5wKINcLkzxQdXYOctbGaCR)5JAID5qqXYsi5sqHmQKvnXUCiOyzbGlV715ZhcVc5accykG7G6F(uVaSE1aSRqP1d0D9Akd3acVcpUmLcW(uI2Vh(sovcsQdgg0egeHCOw4GCfiGYqxz4cRHYP(dgsYqHDqovcsQdmrihQfoixbcOgsIBaHxHhxMsbyFkr73dFjNkbj1bddAcdKcYd07cg6kdxynuo1FWamMEcff4WMeMKkaDBbyrZ3vG)8bgtpHIcCynD6iO1RlsIonWNpWy6juuGdRPthbTEDrt4q9UWJpFGX0tOOah2HQeMUhOdGtaP82cUyiWWNpWy6juuGdtexC9wsQdOX0JI9nrhqUadF(aJPNqrboSR)6Dyxr0GQNuYF(aJPNqrboS7lK6UFq0e22KV7NpWy6juuGdlLsacOUiB5X5Zhym9ekkWHz70eqUfjr72bUbeEfECzkfG9PeTFp8LCQeKuhmmOjmqoGwFNOj9hHBPQbUg6kdfCH1WdyPxFhmo3acVcpUmLcW(uI2Vh(sovcsQdgg0egAj5aYvGaog6kdxynuo1FWG6gkSdYPsqsDG1sYbKRabCgss1f2venxgnrxfAoOo3acVcpUmLcW(uI2Vh(sovcsQdgg0ega5osbVg6kdfCH1WdyPxFhuxn4gq4v4XLPua2Ns0(9Wx2oDtGBaHxHhxMsbyFkr73dFzD)WnGWRWJltPaSpLO97HVOxZeILwHhCdi8k84Yuka7tjA)E4lQWuailnfDbvCdi8k84Yuka7tjA)E4lQWuairSqVd4LBaHxHhxMsbyFkr73dFH9qTYxbOjfeQbMCdi8k84Yuka7tjA)E4RBqk3wFr3L2l3acVcpUmLcW(uI2Vh(AkQYlKysna3acVcpUmLcW(uI2Vh(Yw(DL8(AOWoOMYPsqsDGPuGYR3rGCFqDv1laRxna7iUyHsxeuLmc7ZjfhUbeEfECzkfG9PeTFp8fvykaKuNURHc7GAkNkbj1bMsbkVEhbY9b1vPM1laRxna7iUyHsxeuLmc7ZjfhUbeEfECzkfG9PeTFp8fi3X0k8WqHDqovcsQdmLcuE9ocK7dQZnGBaHxHh3Vh(c7VyH6Qa9UHc7WsvdSSdi9SwgMURiAyfq4LBaHxHh3Vh(sovcsQdgg0egAj5aYvGaog6kdxynuo1FWG6gkSdYPsqsDG1sYbKRabCgssLsbYrn4dtDgi3X0k8qLAkB9cW6vdWUcLwpq31R5Np1laRxnaBHPIxuhLsLImCdi8k84(9WxYPsqsDWWGMWqljhqUceWXqxz4cRHYP(dgu3qHDqovcsQdSwsoGCfiGZqsQKEwlJkmfasXtHID80qf29(XtdgvykaKINcfRGjjIRkzRxawVAa2vO06b6UEn)8PEby9Qbylmv8I6OuQuKHBaHxHh3Vh(sovcsQdgg0egSIG6iPxfg6kdxynuo1FWG6gkSdspRLrfMcaHBPQby3LWjmi9SwgvykaeULQgGnP)O7s4euPMspRLvVoGClABlaUSNIkROPDrfmjrChFqwzNuqQ1JWRWdgvykaKuNUld73vMXwcVcpyuHPaqsD6Um4pGFlGwXeKHBaHxHh3Vh(ct9oIWRWduxCxddAcd3wQGdcFUCdi8k84(9WxyQ3reEfEG6I7AyqtyGCWqHDGWRqoGGaMc4(RX5gq4v4X97HVWuVJi8k8a1f31WGMWGRabugkSdYPsqsDG1sYbKRabCgsIBaHxHh3Vh(ct9oIWRWduxCxddAcd0eDvOPHc7Wf2venxgnrxfAoOo3acVcpUFp8fM6DeHxHhOU4Ugg0egWU3pEAC5gq4v4X97HVWuVJi8k8a1f31WGMWq5lTcpmuyhKtLGK6aZkcQJKEvmKe3acVcpUFp8fM6DeHxHhOU4Ugg0egSIG6iPxfgkSdYPsqsDGzfb1rsVkguNBaHxHh3Vh(ct9oIWRWduxCxddAcdtxomHy5gWnySZ1eEfECz0eDvO5aMcm0reEfEyOWoq4v4bdK7yAfEWWTueqxenQMuqmf8(7qItn4gq4v4XLrt0vHMFp8fi3X0k8WqHDysbXuW74dYPsqsDGbYDKcEvjl29(Xtd26pClYTOTfqtQrWkysI4o(aHxHhmqUJPv4bd(d43cOvmHpFWU3pEAWOctbGu8uOyfmjrChFGWRWdgi3X0k8Gb)b8Bb0kMWNpYUuhILvVaqUfP4PqPc7E)4PbREbGClsXtHIvWKeXD8bcVcpyGChtRWdg8hWVfqRycYiJkPN1YQxai3Iu8uOyhpnuj9SwgvykaKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJlJMORcn)E4RdqBRKxbyOWoGDVF80GrfMcaP4PqXkysI4oKKkzLEwlREbGClsXtHID80qLSy37hpnyR)WTi3I2wanPgbRGjjI7VYPsqsDGrkOj9hDGoLmY6fA9D(5d29(Xtd26pClYTOTfqtQrWkysI4oKKmYWnGWRWJlJMORcn)E4RPOkVUi3IwVMqSgkSdy37hpnyuHPaqkEkuScMKiUdjPswPN1YQxai3Iu8uOyhpnujl29(Xtd26pClYTOTfqtQrWkysI4(RCQeKuhyKcAs)rhOtjJSEHwFNF(GDVF80GT(d3IClABb0KAeScMKiUdjjJmCdi8k84YOj6QqZVh(QOJGIfDvOkbUbeEfECz0eDvO53dFDBf2venifpfkdf2bPN1YOctbGu8uOyhpnuHDVF80GrfMcaP4PqX26bOcMKiU)s4v4b72kSRiAqkEkum8Puj9Sww9ca5wKINcf74PHkS79JNgS6faYTifpfk2wpavWKeX9xcVcpy3wHDfrdsXtHIHpLQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJlJMORcn)E4R6faYTifpfkdf2bPN1YQxai3Iu8uOyhpnuHDVF80GrfMcaP4PqXkysI4YnGWRWJlJMORcn)E4R1F4wKBrBlGMuJWqHDqwS79JNgmQWuaifpfkwbtse3HKuj9Sww9ca5wKINcf74PHmF(OuGCud(WuNvVaqUfP4PqXnGWRWJlJMORcn)E4R1F4wKBrBlGMuJWqHDa7E)4PbJkmfasXtHIvWKeXDC1ijvspRLvVaqUfP4PqXoEAOcUxiWatU4k8a5wKcuwaVcpyqqsD4WnGWRWJlJMORcn)E4lQWuaifpfkdf2bPN1YQxai3Iu8uOyhpnuHDVF80GT(d3IClABb0KAeScMKiU)kNkbj1bgPGM0F0b6uYiRxO13j3acVcpUmAIUk087HVOctbGKOQOgWqHDq6zTmQWuaifpfk2trL0ZAzuHPaqkEkuScMKiUJpq4v4bJkmfaAkUxrhUm4pGFlGwXeuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtGBaHxHhxgnrxfA(9WxuHPaqEjzOWoi9SwgvykaeULQgGDxcNW4spRLrfMcaHBPQbyt6p6UeobvspRLvVaqUfP4PqXoEAOs6zTmQWuaifpfk2Xtdvhq6zTS1F4wKBrBlGMuJGD80GBaHxHhxgnrxfA(9WxuHPaqsuvudyOWoi9Sww9ca5wKINcf74PHkPN1YOctbGu8uOyhpnuDaPN1Yw)HBrUfTTaAsnc2XtdvspRLrfMcaHBPQby3LWjmi9SwgvykaeULQgGnP)O7s4e4gq4v4XLrt0vHMFp8fvyka0uCVIoCnuyhKEwld3bQW0DfrdRacVgIBjrmOUHav9Kr4wseiHDq6zTmChOct3veniClfb0zhpnujR0ZAzuHPaqkEkuSNYNpspRLvVaqUfP4PqXEkF(GDVF80GbYDmTcpyfqNKLHBaHxHhxgnrxfA(9WxuHPaqtX9k6W1qHDqnPepqjwGrfMcaP8MtOlIggeKuhoF(i9SwgUduHP7kIgeULIa6SJNggIBjrmOUHav9Kr4wseiHDq6zTmChOct3veniClfb0zhpnujR0ZAzuHPaqkEkuSNYNpspRLvVaqUfP4PqXEkF(GDVF80GbYDmTcpyfqNKLHBaHxHhxgnrxfA(9WxGChtRWddf2bPN1YQxai3Iu8uOyhpnuj9SwgvykaKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJlJMORcn)E4lQWuaiVKmuyhKEwlJkmfac3svdWUlHtyCPN1YOctbGWTu1aSj9hDxcNa3acVcpUmAIUk087HVOctbGKOQOgGBaHxHhxgnrxfA(9WxuHPaqsD6UCd4gq4v4XLromyl)UsEFnuyhQxawVAa2rCXcLUiOkze2NtkoQWU3pEAWKEwl6iUyHsxeuLmc7Zjfhwb0jzvspRLDexSqPlcQsgH95KIdYw(DzhpnujR0ZAzuHPaqkEkuSJNgQKEwlREbGClsXtHID80q1bKEwlB9hUf5w02cOj1iyhpnKrf29(Xtd26pClYTOTfqtQrWkysI4oKKkzLEwlJkmfac3svdWUlHty8b5ujiPoWihqRVt0K(JWTu1axvYk7sDiww9ca5wKINcLkS79JNgS6faYTifpfkwbtse3XhAWhvy37hpnyuHPaqkEkuScMKiU)kNkbj1b267enP)Od0PKrwVqKImF(iRAUuhILvVaqUfP4PqPc7E)4PbJkmfasXtHIvWKeX9x5ujiPoWwFNOj9hDGoLmY6fIuK5ZhS79JNgmQWuaifpfkwbtse3XhAWhzKHBaHxHhxg5W3dFzffGK60DnuyhKTEby9QbyhXflu6IGQKryFoP4Oc7E)4Pbt6zTOJ4IfkDrqvYiSpNuCyfqNKvj9Sw2rCXcLUiOkze2NtkoiROa2Xtdvkfih1Gpm1z2YVRK3xz(8r26fG1RgGDexSqPlcQsgH95KIJQvmHHKKHBaHxHhxg5W3dFzl)UOWLtgkSd1laRxnaRPe3EYibwG7GkS79JNgmQWuaifpfkwbtse3FtSKuHDVF80GT(d3IClABb0KAeScMKiUdjPswPN1YOctbGWTu1aS7s4egFqovcsQdmYb067enP)iClvnWvLSYUuhILvVaqUfP4PqPc7E)4PbREbGClsXtHIvWKeXD8Hg8rf29(XtdgvykaKINcfRGjjI7VYPsqsDGT(ort6p6aDkzK1lePiZNpYQMl1Hyz1laKBrkEkuQWU3pEAWOctbGu8uOyfmjrC)vovcsQdS13jAs)rhOtjJSEHifz(8b7E)4PbJkmfasXtHIvWKeXD8Hg8rgz4gq4v4XLro89Wx2YVlkC5KHc7q9cW6vdWAkXTNmsGf4oOc7E)4PbJkmfasXtHIvWKeXDijvYkRSy37hpnyR)WTi3I2wanPgbRGjjI7VYPsqsDGrkOj9hDGoLmY6fA9DQs6zTmQWuaiClvna7UeoHbPN1YOctbGWTu1aSj9hDxcNGmF(il29(Xtd26pClYTOTfqtQrWkysI4oKKkPN1YOctbGWTu1aS7s4egFqovcsQdmYb067enP)iClvnWvgzuj9Sww9ca5wKINcf74PHmCdi8k84Yih(E4R1F4wKBrBlGMuJWqHDOEby9QbyxHsRhO761uLsbYrn4dtDgi3X0k8GBaHxHhxg5W3dFrfMcaP4PqzOWouVaSE1aSRqP1d0D9AQswLcKJAWhM6mqUJPv4XNpkfih1Gpm1zR)WTi3I2wanPgHmCdi8k84Yih(E4lqUJPv4HHc7WkMWVjwsQQxawVAa2vO06b6UEnvj9SwgvykaeULQgGDxcNW4dYPsqsDGroGwFNOj9hHBPQbUQWU3pEAWw)HBrUfTTaAsncwbtse3HKuHDVF80GrfMcaP4PqXkysI4o(qd(WnGWRWJlJC47HVa5oMwHhgkSdRyc)MyjPQEby9QbyxHsRhO761uf29(XtdgvykaKINcfRGjjI7qsQKvwzXU3pEAWw)HBrUfTTaAsncwbtse3FLtLGK6aJuqt6p6aDkzK1l067uL0ZAzuHPaq4wQAa2DjCcdspRLrfMcaHBPQbyt6p6Ueobz(8rwS79JNgS1F4wKBrBlGMuJGvWKeXDijvspRLrfMcaHBPQby3LWjm(GCQeKuhyKdO13jAs)r4wQAGRmYOs6zTS6faYTifpfk2Xtdzmuelu1tzrc7G0ZAzxHsRhO761KDxcNWG0ZAzxHsRhO761KnP)O7s4emuelu1tzrI5eocAHb15gq4v4XLro89WxtrvEDrUfTEnHynuyhKf7E)4PbJkmfasXtHIvWKeX93Xsn(8b7E)4PbJkmfasXtHIvWKeXD8Hetgvy37hpnyR)WTi3I2wanPgbRGjjI7qsQKv6zTmQWuaiClvna7UeoHXhKtLGK6aJCaT(ort6pc3svdCvjRSl1Hyz1laKBrkEkuQWU3pEAWQxai3Iu8uOyfmjrChFObFuHDVF80GrfMcaP4PqXkysI4(RAiZNpYQMl1Hyz1laKBrkEkuQWU3pEAWOctbGu8uOyfmjrC)vnK5ZhS79JNgmQWuaifpfkwbtse3XhAWhzKHBaHxHhxg5W3dFv0rqXIUkuLGHc7a29(Xtd26pClYTOTfqtQrWkysI4oo8hWVfqRycQKv6zTmQWuaiClvna7UeoHXhKtLGK6aJCaT(ort6pc3svdCvjRSl1Hyz1laKBrkEkuQWU3pEAWQxai3Iu8uOyfmjrChFObFuHDVF80GrfMcaP4PqXkysI4(RCQeKuhyRVt0K(JoqNsgz9crkY85JSQ5sDiww9ca5wKINcLkS79JNgmQWuaifpfkwbtse3FLtLGK6aB9DIM0F0b6uYiRxisrMpFWU3pEAWOctbGu8uOyfmjrChFObFKrgUbeEfECzKdFp8vrhbfl6QqvcgkSdy37hpnyuHPaqkEkuScMKiUJd)b8Bb0kMGkzLvwS79JNgS1F4wKBrBlGMuJGvWKeX9x5ujiPoWif0K(JoqNsgz9cT(ovj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtqMpFKf7E)4PbB9hUf5w02cOj1iyfmjrChssL0ZAzuHPaq4wQAa2DjCcJpiNkbj1bg5aA9DIM0FeULQg4kJmQKEwlREbGClsXtHID80qgUbeEfECzKdFp81bOTvYRamuyhWU3pEAWOctbGu8uOyfmjrChssLSYkl29(Xtd26pClYTOTfqtQrWkysI4(RCQeKuhyKcAs)rhOtjJSEHwFNQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjiZNpYIDVF80GT(d3IClABb0KAeScMKiUdjPs6zTmQWuaiClvna7UeoHXhKtLGK6aJCaT(ort6pc3svdCLrgvspRLvVaqUfP4PqXoEAid3acVcpUmYHVh(A9hUf5w02cOj1imuyhKEwlJkmfac3svdWUlHty8b5ujiPoWihqRVt0K(JWTu1axvYk7sDiww9ca5wKINcLkS79JNgS6faYTifpfkwbtse3XhAWhvy37hpnyuHPaqkEkuScMKiU)kNkbj1b267enP)Od0PKrwVqKImF(iRAUuhILvVaqUfP4PqPc7E)4PbJkmfasXtHIvWKeX9x5ujiPoWwFNOj9hDGoLmY6fIuK5ZhS79JNgmQWuaifpfkwbtse3XhAWhz4gq4v4XLro89WxuHPaqkEkugkSdYkl29(Xtd26pClYTOTfqtQrWkysI4(RCQeKuhyKcAs)rhOtjJSEHwFNQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjiZNpYIDVF80GT(d3IClABb0KAeScMKiUdjPs6zTmQWuaiClvna7UeoHXhKtLGK6aJCaT(ort6pc3svdCLrgvspRLvVaqUfP4PqXoEAWnGWRWJlJC47HVQxai3Iu8uOmuyhKEwlREbGClsXtHID80qLSYIDVF80GT(d3IClABb0KAeScMKiU)A8Kuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtqMpFKf7E)4PbB9hUf5w02cOj1iyfmjrChssL0ZAzuHPaq4wQAa2DjCcJpiNkbj1bg5aA9DIM0FeULQg4kJmQKf7E)4PbJkmfasXtHIvWKeX9x1n(Nphq6zTS1F4wKBrBlGMuJG9uKHBaHxHhxg5W3dFDBf2venifpfkdf2bS79JNgmQWuaiVKyfmjrC)vn(8rnxQdXYOctbG8sIBaHxHhxg5W3dFPuWfcmGClAkIJHc7G0ZAzhG2wjVcG9uuDaPN1Yw)HBrUfTTaAsnc2tr1bKEwlB9hUf5w02cOj1iyfmjrChFq6zTmLcUqGbKBrtrCyt6p6UeoHXwcVcpyuHPaqsD6Um4pGFlGwXe4gq4v4XLro89WxuHPaqsD6UgkSdspRLDaABL8ka2trLSYUuhILvW1dkWGkcVc5accykG74JLmF(q4vihqqatbChxnKrLSQz9cW6vdWOctbGK8PevNje7NplvnWYAbQVTmf8(BIPgYWnGWRWJlJC47HVUpfOcxoXnGWRWJlJC47HVOctbGKOQOgWqHDq6zTmQWuaiClvna7UeoHbPN1YOctbGWTu1aSj9hDxcNa3acVcpUmYHVh(IkmfaYljdf2bPN1YOctbGWTu1aS7s4egsIBaHxHhxg5W3dFfW2cfAHPcCxdf2bzlWwWTLK6WNpQ5kWjiIgzuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtGBaHxHhxg5W3dFrfMcanf3ROdxdf2bPN1YWDGkmDxr0WkGWRQ6fG1RgGrfMcajcRieBYQKv2L6qSmAQ0fwbMwHhQi8kKdiiGPaUJRwK5ZhcVc5accykG74QHmCdi8k84Yih(E4lQWuaOP4EfD4AOWoi9SwgUduHP7kIgwbeEvTuhILrfMcab4wx1bKEwlB9hUf5w02cOj1iypfvYUuhILrtLUWkW0k84ZhcVc5accykG74joz4gq4v4XLro89WxuHPaqtX9k6W1qHDq6zTmChOct3venSci8QAPoelJMkDHvGPv4HkcVc5accykG74Jf3acVcpUmYHVh(Ikmfac(R09RWddf2bPN1YOctbGWTu1aS7s4egx6zTmQWuaiClvnaBs)r3LWjWnGWRWJlJC47HVOctbGG)kD)k8WqHDq6zTmQWuaiClvna7UeoHbPN1YOctbGWTu1aSj9hDxcNGkLcKJAWhM6mQWuaijQkQb4gq4v4XLro89WxGChtRWddfXcv9uwKWomPGyk493b1IAyOiwOQNYIeZjCe0cdQZnGBWyNRvRBj8sSIepax)UIOHRBkXTNmxlWcCh46uX2Y1KcJRhBUaxlwUovSTC967KR9TfQuXfyCdi8k84YWU3pEAChSLFxu4Yjdf2H6fG1RgG1uIBpzKalWDqf29(XtdgvykaKINcfRGjjI7VjwsQWU3pEAWw)HBrUfTTaAsncwbtse3HKujR0ZAzuHPaq4wQAa2DjCcJpiNkbj1b267enP)iClvnWvLSYUuhILvVaqUfP4PqPc7E)4PbREbGClsXtHIvWKeXD8Hg8rf29(XtdgvykaKINcfRGjjI7VYPsqsDGT(ort6p6aDkzK1lePiZNpYQMl1Hyz1laKBrkEkuQWU3pEAWOctbGu8uOyfmjrC)vovcsQdS13jAs)rhOtjJSEHifz(8b7E)4PbJkmfasXtHIvWKeXD8Hg8rgz4gq4v4XLHDVF804(9Wx2YVlkC5KHc7q9cW6vdWAkXTNmsGf4oOc7E)4PbJkmfasXtHIvWKeXDijvYQMl1Hyzq0fnTleW5ZhzxQdXYGOlAAxiGJQjfetbV)omgssgzujRSy37hpnyR)WTi3I2wanPgbRGjjI7VQNKkPN1YOctbGWTu1aS7s4egKEwlJkmfac3svdWM0F0DjCcY85JSy37hpnyR)WTi3I2wanPgbRGjjI7qsQKEwlJkmfac3svdWUlHtyijzKrL0ZAz1laKBrkEkuSJNgQMuqmf8(7GCQeKuhyKcAkcX8nrtkiKcE5gq4v4XLHDVF804(9Wx2YVRK3xdf2H6fG1RgGDexSqPlcQsgH95KIJkS79JNgmPN1IoIlwO0fbvjJW(CsXHvaDswL0ZAzhXflu6IGQKryFoP4GSLFx2XtdvYk9SwgvykaKINcf74PHkPN1YQxai3Iu8uOyhpnuDaPN1Yw)HBrUfTTaAsnc2XtdzuHDVF80GT(d3IClABb0KAeScMKiUdjPswPN1YOctbGWTu1aS7s4egFqovcsQdS13jAs)r4wQAGRkzLDPoelREbGClsXtHsf29(Xtdw9ca5wKINcfRGjjI74dn4JkS79JNgmQWuaifpfkwbtse3FLtLGK6aB9DIM0F0b6uYiRxisrMpFKvnxQdXYQxai3Iu8uOuHDVF80GrfMcaP4PqXkysI4(RCQeKuhyRVt0K(JoqNsgz9crkY85d29(XtdgvykaKINcfRGjjI74dn4JmYWnGWRWJld7E)4PX97HVSIcqsD6UgkSd1laRxna7iUyHsxeuLmc7Zjfhvy37hpnyspRfDexSqPlcQsgH95KIdRa6KSkPN1YoIlwO0fbvjJW(CsXbzffWoEAOsPa5Og8HPoZw(DL8(YnySZ1J59uk5lx)Uaxpfv51LRtfBlxtkmUEmZY1RVtUwC56cOtYCnD56uO3nKRNucaxFFfW1RZ1y6UCTy5AjW6fW1RVtg3acVcpUmS79JNg3Vh(AkQYRlYTO1RjeRHc7a29(Xtd26pClYTOTfqtQrWkysI4oKKkPN1YOctbGWTu1aS7s4egFqovcsQdS13jAs)r4wQAGRkS79JNgmQWuaifpfkwbtse3XhAWhUbeEfECzy37hpnUFp81uuLxxKBrRxtiwdf2bS79JNgmQWuaifpfkwbtse3HKujRAUuhILbrx00UqaNpFKDPoeldIUOPDHaoQMuqmf8(7WyijzKrLSYIDVF80GT(d3IClABb0KAeScMKiU)kNkbj1bgPGM0F0b6uYiRxO13PkPN1YOctbGWTu1aS7s4egKEwlJkmfac3svdWM0F0DjCcY85JSy37hpnyR)WTi3I2wanPgbRGjjI7qsQKEwlJkmfac3svdWUlHtyijzKrL0ZAz1laKBrkEkuSJNgQMuqmf8(7GCQeKuhyKcAkcX8nrtkiKcE5gm256X8EkL8LRFxGRpaTTsEfaxNk2wUMuyC9yMLRxFNCT4Y1fqNK5A6Y1PqVBixpPeaU((kGRxNRX0D5AXY1sG1lGRxFNmUbeEfECzy37hpnUFp81bOTvYRamuyhWU3pEAWw)HBrUfTTaAsncwbtse3HKuj9SwgvykaeULQgGDxcNW4dYPsqsDGT(ort6pc3svdCvHDVF80GrfMcaP4PqXkysI4o(qd(WnGWRWJld7E)4PX97HVoaTTsEfGHc7a29(XtdgvykaKINcfRGjjI7qsQKvnxQdXYGOlAAxiGZNpYUuhILbrx00UqahvtkiMcE)DymKKmYOswzXU3pEAWw)HBrUfTTaAsncwbtse3FvpjvspRLrfMcaHBPQby3LWjmi9SwgvykaeULQgGnP)O7s4eK5ZhzXU3pEAWw)HBrUfTTaAsncwbtse3HKuj9SwgvykaeULQgGDxcNWqsYiJkPN1YQxai3Iu8uOyhpnunPGyk493b5ujiPoWif0ueI5BIMuqif8YnySZ1JnxGRVkuLaxlSC967KRP4W1KcxtfW1EW14dxtXHRt9WOLRLaU(PW1wV46UhnqX1BlfC92cC9K(Z1hOtjBixpPeerdxFFfW1Pax3sYbUMwUUd0D56n15AQWuaCnULQg4Y1uC46TLwUE9DY1P0nmA5A1kF3LRFx4W4gq4v4XLHDVF804(9WxfDeuSORcvjyOWoGDVF80GT(d3IClABb0KAeScMKiU)kNkbj1bwDrt6p6aDkzK1l067uf29(XtdgvykaKINcfRGjjI7VYPsqsDGvx0K(JoqNsgz9crkQKDPoelREbGClsXtHsLSy37hpny1laKBrkEkuScMKiUJd)b8Bb0kMWNpy37hpny1laKBrkEkuScMKiU)kNkbj1bwDrt6p6aDkzK1lu5kY85JAUuhILvVaqUfP4PqjJkPN1YOctbGWTu1aS7s4e(14QoG0ZAzR)WTi3I2wanPgb74PHkPN1YQxai3Iu8uOyhpnuj9SwgvykaKINcf74Pb3GXoxp2CbU(QqvcCDQyB5AsHRtBHGRv87vi1bgxpMz5613jxlUCDb0jzUMUCDk07gY1tkbGRVVc4615AmDxUwSCTey9c4613jJBaHxHhxg29(XtJ73dFv0rqXIUkuLGHc7a29(Xtd26pClYTOTfqtQrWkysI4oo8hWVfqRycQKEwlJkmfac3svdWUlHty8b5ujiPoWwFNOj9hHBPQbUQWU3pEAWOctbGu8uOyfmjrChxw4pGFlGwXe(MWRWd26pClYTOTfqtQrWG)a(TaAftqgUbeEfECzy37hpnUFp8vrhbfl6QqvcgkSdy37hpnyuHPaqkEkuScMKiUJd)b8Bb0kMGkzLvnxQdXYGOlAAxiGZNpYUuhILbrx00UqahvtkiMcE)DymKKmYOswzXU3pEAWw)HBrUfTTaAsncwbtse3FLtLGK6aJuqt6p6aDkzK1l067uL0ZAzuHPaq4wQAa2DjCcdspRLrfMcaHBPQbyt6p6Ueobz(8rwS79JNgS1F4wKBrBlGMuJGvWKeXDijvspRLrfMcaHBPQby3LWjmKKmYOs6zTS6faYTifpfk2XtdvtkiMcE)DqovcsQdmsbnfHy(MOjfesbVYWnySZ1JnxGRxFNCDQyB5AsHRfwUwSgD56uX2kcUEBbUEs)56d0PKzC9yMLRdFnKRFxGRtfBlxxUcxlSC92cC9sDiwUwC56Lsacd5AkoCTyn6Y1PITveC92cC9K(Z1hOtjZ4gq4v4XLHDVF804(9WxR)WTi3I2wanPgHHc7G0ZAzuHPaq4wQAa2DjCcJpiNkbj1b267enP)iClvnWvf29(XtdgvykaKINcfRGjjI74dWFa)waTIjOAsbXuW7VYPsqsDGrkOPieZ3enPGqk4vL0ZAz1laKBrkEkuSJNgCdi8k84YWU3pEAC)E4R1F4wKBrBlGMuJWqHDq6zTmQWuaiClvna7UeoHXhKtLGK6aB9DIM0FeULQg4QAPoelREbGClsXtHsf29(Xtdw9ca5wKINcfRGjjI74dWFa)waTIjOc7E)4PbJkmfasXtHIvWKeX9x5ujiPoWwFNOj9hDGoLmY6fIu4gq4v4XLHDVF804(9WxR)WTi3I2wanPgHHc7G0ZAzuHPaq4wQAa2DjCcJpiNkbj1b267enP)iClvnWvLSQ5sDiww9ca5wKINc1Npy37hpny1laKBrkEkuScMKiU)kNkbj1b267enP)Od0PKrwVqLRiJkS79JNgmQWuaifpfkwbtse3FLtLGK6aB9DIM0F0b6uYiRxisHBWyNRhBUaxtkCTWY1RVtUwC5Ap4A8HRP4W1PEy0Y1sax)u4ARxCD3JgO46TLcUEBbUEs)56d0PKnKRNucIOHRVVc46TLwUof46wsoW1q4VMwUEsbX1uC46TLwUEBHc4AXLRdF5AQxaDsMRjUUEbW1ULRv8uO46JNgmUbeEfECzy37hpnUFp8fvykaKINcLHc7a29(Xtd26pClYTOTfqtQrWkysI4(RCQeKuhyKcAs)rhOtjJSEHwFNQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjOs6zTS6faYTifpfk2XtdvtkiMcE)DqovcsQdmsbnfHy(MOjfesbVCdg7C9yZf46Yv4AHLRxFNCT4Y1EW14dxtXHRt9WOLRLaU(PW1wV46UhnqX1BlfC92cC9K(Z1hOtjBixpPeerdxFFfW1BluaxlUHrlxt9cOtYCnX11laU(4PbxtXHR3wA5AsHRt9WOLRLaSpbUMKtIoj1bU(8kr0W11lag3acVcpUmS79JNg3Vh(QEbGClsXtHYqHDq6zTmQWuaifpfk2XtdvYIDVF80GT(d3IClABb0KAeScMKiU)kNkbj1bw5kOj9hDGoLmY6fA9D(5d29(XtdgvykaKINcfRGjjI74dYPsqsDGT(ort6p6aDkzK1lePiJkPN1YOctbGWTu1aS7s4egKEwlJkmfac3svdWM0F0DjCcQWU3pEAWOctbGu8uOyfmjrC)vDJZnGWRWJld7E)4PX97HVUTc7kIgKINcLHc7G0ZAzuHPaqkEkuSJNgQWU3pEAWOctbGu8uOyB9aubtse3Fj8k8GDBf2venifpfkg(uQKEwlREbGClsXtHID80qf29(Xtdw9ca5wKINcfBRhGkysI4(lHxHhSBRWUIObP4PqXWNs1bKEwlB9hUf5w02cOj1iyhpn4gm256XMlW1k(KRxNRVJPhajEaUMcUg(VfX1KexlcUEBbUoG)lxJDVF80GRtfXXtnKRFrhUxUoHKlbfC92cbx7rpzU(8kr0W1uHPa4AfpfkU(8aUEDUU1t56jfex3(IMkzUUOJGILRVkuLaxlUCdi8k84YWU3pEAC)E4lLcUqGbKBrtrCmuyhwQdXYQxai3Iu8uOuj9SwgvykaKINcf7POs6zTS6faYTifpfkwbtse3XBWh2K(ZnGWRWJld7E)4PX97HVuk4cbgqUfnfXXqHD4aspRLT(d3IClABb0KAeSNIQdi9Sw26pClYTOTfqtQrWkysI4ooHxHhmQWuaOP4EfD4YG)a(TaAftqLAID5qqXYsi5sqb3acVcpUmS79JNg3Vh(sPGleya5w0uehdf2bPN1YQxai3Iu8uOypfvspRLvVaqUfP4PqXkysI4oEd(WM0Fvy37hpnyGChtRWdwb0jzvy37hpnyR)WTi3I2wanPgbRGjjIRk1e7YHGILLqYLGcUbCdi8k84YSIG6iPxfFp8fvyka0uCVIoCnuyhKEwld3bQW0DfrdRacVgIBjrmOo3acVcpUmRiOos6vX3dFrfMcaj1P7YnGWRWJlZkcQJKEv89WxuHPaqsuvudWnGBaHxHhx20Ldti2Vh(sQlIequKSHc7W0Ldtiw2rCxkWWVdQNe3acVcpUSPlhMqSFp8LsbxiWaYTOPioCdi8k84YMUCycX(9WxuHPaqtX9k6W1qHDy6YHjel7iUlfyyC1tIBaHxHhx20Ldti2Vh(IkmfaYljUbeEfECztxomHy)E4lROaKuNUl3aUbeEfECzUceqnaYDmTcpmuyhKTEby9QbyxHsRhO7618ZN6fG1RgGTWuXlQJsPsrgvl1Hyz1laKBrkEkuQWU3pEAWQxai3Iu8uOyfmjrCvjR0ZAz1laKBrkEkuSJNgF(OuGCud(WuNrfMcajrvrnGmCdi8k84YCfiG67HVSIcqsD6UgkSd1laRxna7iUyHsxeuLmc7ZjfhvspRLDexSqPlcQsgH95KIdYw(DzpfUbeEfECzUceq99Wx2YVlkC5KHc7q9cW6vdWAkXTNmsGf4oOAsbXuW7Vjo1GBaHxHhxMRabuFp81bOTvYRamuyhuZ6fG1RgGDfkTEGURxtUbeEfECzUceq99WxfDeuSORcvjyOWomPGyk493XkjUbeEfECzUceq99Wx3wHDfrdsXtHYqHDq6zTmQWuaifpfk2Xtdvy37hpnyuHPaqkEkuScMKiUQut5ujiPoWeHCOw4GCfiGAqDUbeEfECzUceq99WxuHPaqEjzOWoiNkbj1bMiKd1chKRabudQRc7E)4PbREbGClsXtHIvWKeXDijUbeEfECzUceq99WxuHPaqsD6UgkSdYPsqsDGjc5qTWb5kqa1G6QWU3pEAWQxai3Iu8uOyfmjrChssL0ZAzuHPaq4wQAa2DjCcJl9SwgvykaeULQgGnP)O7s4e4gq4v4XL5kqa13dFvVaqUfP4PqzOWoiNkbj1bMiKd1chKRabudQRs6zTS6faYTifpfk2XtdUbeEfECzUceq99Wxk(k8WqHDqovcsQdmrihQfoixbcOguxLAkB9cW6vdWUcLwpq31R5Np1laRxnaBHPIxuhLsLImCdi8k84YCfiG67HVoaTTsEfGHc7G0ZAz1laKBrkEkuSJNgCdi8k84YCfiG67HVMIQ86IClA9AcXAOWoi9Sww9ca5wKINcf74PXNpkfih1Gpm1zuHPaqsuvudWnGWRWJlZvGaQVh(A9hUf5w02cOj1imuyhKEwlREbGClsXtHID804ZhLcKJAWhM6mQWuaijQkQb4gq4v4XL5kqa13dFrfMcaP4PqzOWoOuGCud(WuNT(d3IClABb0KAeCdi8k84YCfiG67HVQxai3Iu8uOmuyhKEwlREbGClsXtHID80GBaHxHhxMRabuFp8LsbxiWaYTOPiogkSdhq6zTS1F4wKBrBlGMuJG9uuDaPN1Yw)HBrUfTTaAsncwbtse3Xj8k8GrfMcanf3ROdxg8hWVfqRycCdi8k84YCfiG67HVuk4cbgqUfnfXXqHDyPoelREbGClsXtHsL0ZAzuHPaqkEkuSNIkPN1YQxai3Iu8uOyfmjrChVbFyt6p3acVcpUmxbcO(E4lQWuaiPoDxdf2HJVSIockw0vHQeyfmjrC)vn(85aspRLv0rqXIUkuLas(RhqrsIUytMDxcNWVjXnGWRWJlZvGaQVh(IkmfasQt31qHDq6zTmLcUqGbKBrtrCypfvhq6zTS1F4wKBrBlGMuJG9uuDaPN1Yw)HBrUfTTaAsncwbtse3Xhi8k8GrfMcaj1P7YG)a(TaAftGBaHxHhxMRabuFp8fvykaKevf1agkSdspRLvVaqUfP4PqXEkQWU3pEAWOctbGu8uOyfqNKvnPGyk4D8XkjvspRLrfMcaHBPQby3LWjmi9SwgvykaeULQgGnP)O7s4euPM1laRxna7kuA9aDxVMQuZ6fG1RgGTWuXlQJsPsHBaHxHhxMRabuFp8fvykaKevf1agkSdspRLvVaqUfP4PqXEkQKEwlJkmfasXtHID80qL0ZAz1laKBrkEkuScMKiUJp0GpQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjOsovcsQdmrihQfoixbcO4gq4v4XL5kqa13dFrfMcanf3ROdxdf2Hdi9Sw26pClYTOTfqtQrWEkQwQdXYOctbGaCRRswPN1YoaTTsEfa74PXNpeEfYbeeWua3b1Lr1bKEwlB9hUf5w02cOj1iyfmjrC)LWRWdgvyka0uCVIoCzWFa)waTIjOsw1Ks8aLybgvykaKYBoHUiAyqqsD485J0ZAz4oqfMURiAq4wkcOZoEAiJH4wsedQBiqvpzeULebsyhKEwld3bQW0Dfrdc3sraD2XtdvYk9SwgvykaKINcf7P85JSQ5sDiwMlhkfpfk4OswPN1YQxai3Iu8uOypLpFWU3pEAWa5oMwHhScOtYYiJmCdi8k84YCfiG67HVOctbGMI7v0HRHc7G0ZAz4oqfMURiAyfq4vf29(XtdgvykaKINcfRGjjIRkzLEwlREbGClsXtHI9u(8r6zTmQWuaifpfk2trgdXTKiguNBaHxHhxMRabuFp8fvykaKxsgkSdspRLrfMcaHBPQby3LWjm(GCQeKuhyRVt0K(JWTu1axvYIDVF80GrfMcaP4PqXkysI4(R6j95dHxHCabbmfWD8bJld3acVcpUmxbcO(E4lQWuaiPoDxdf2bPN1YQxai3Iu8uOypLpFMuqmf8(R6Qb3acVcpUmxbcO(E4lqUJPv4HHc7G0ZAz1laKBrkEkuSJNgQKEwlJkmfasXtHID80WqrSqvpLfjSdtkiMcE)DqTOggkIfQ6PSiXCchbTWG6Cdi8k84YCfiG67HVOctbGKOQOgGBa3GXoxt4v4XLv(sRWJVh(ctbg6icVcpmuyhi8k8GbYDmTcpy4wkcOlIgvtkiMcE)DiXPgQKvnRxawVAa2vO06b6UEn)8r6zTSRqP1d0D9AYUlHtyq6zTSRqP1d0D9AYM0F0DjCcYWnGWRWJlR8LwHhFp8fi3X0k8WqHDysbXuW74dYPsqsDGbYDKcEvjl29(Xtd26pClYTOTfqtQrWkysI4o(aHxHhmqUJPv4bd(d43cOvmHpFWU3pEAWOctbGu8uOyfmjrChFGWRWdgi3X0k8Gb)b8Bb0kMWNpYUuhILvVaqUfP4PqPc7E)4PbREbGClsXtHIvWKeXD8bcVcpyGChtRWdg8hWVfqRycYiJkPN1YQxai3Iu8uOyhpnuj9SwgvykaKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAOsnvkqoQbFyQZw)HBrUfTTaAsncUbeEfECzLV0k847HVa5oMwHhgkSd1laRxna7kuA9aDxVMQWU3pEAWOctbGu8uOyfmjrChFGWRWdgi3X0k8Gb)b8Bb0kMa3GXox)dvf1aCTWY1I1OlxVIjW1RZ1VlW1RVtUMIdxNcCDljh461DUEsrYCnULQg4YnGWRWJlR8LwHhFp8fvykaKevf1agkSdy37hpnyR)WTi3I2wanPgbRa6KSkzLEwlJkmfac3svdWUlHt4x5ujiPoWwFNOj9hHBPQbUQWU3pEAWOctbGu8uOyfmjrChFa(d43cOvmbvtkiMcE)vovcsQdmsbnfHy(MOjfesbVQKEwlREbGClsXtHID80qgUbeEfECzLV0k847HVOctbGKOQOgWqHDa7E)4PbB9hUf5w02cOj1iyfqNKvjR0ZAzuHPaq4wQAa2DjCc)kNkbj1b267enP)iClvnWv1sDiww9ca5wKINcLkS79JNgS6faYTifpfkwbtse3XhG)a(TaAftqf29(XtdgvykaKINcfRGjjI7VYPsqsDGT(ort6p6aDkzK1lePid3acVcpUSYxAfE89WxuHPaqsuvudyOWoGDVF80GT(d3IClABb0KAeScOtYQKv6zTmQWuaiClvna7UeoHFLtLGK6aB9DIM0FeULQg4Qsw1CPoelREbGClsXtH6ZhS79JNgS6faYTifpfkwbtse3FLtLGK6aB9DIM0F0b6uYiRxOYvKrf29(XtdgvykaKINcfRGjjI7VYPsqsDGT(ort6p6aDkzK1lePid3acVcpUSYxAfE89WxuHPaqsuvudyOWoCaPN1Yk6iOyrxfQsaj)1dOijrxSjZUlHty4aspRLv0rqXIUkuLas(RhqrsIUytMnP)O7s4eujR0ZAzuHPaqkEkuSJNgF(i9SwgvykaKINcfRGjjI74dn4JmQKv6zTS6faYTifpfk2XtJpFKEwlREbGClsXtHIvWKeXD8Hg8rgUbeEfECzLV0k847HVOctbGK60Dnuyho(Yk6iOyrxfQsGvWKeX9x1YNpYEaPN1Yk6iOyrxfQsaj)1dOijrxSjZUlHt43KuDaPN1Yk6iOyrxfQsaj)1dOijrxSjZUlHty8di9Swwrhbfl6Qqvci5VEafjj6Inz2K(JUlHtqgUbeEfECzLV0k847HVOctbGK60DnuyhKEwltPGleya5w0ueh2tr1bKEwlB9hUf5w02cOj1iypfvhq6zTS1F4wKBrBlGMuJGvWKeXD8bcVcpyuHPaqsD6Um4pGFlGwXe4gq4v4XLv(sRWJVh(IkmfaAkUxrhUgkSdhq6zTS1F4wKBrBlGMuJG9uuTuhILrfMcab4wxLSspRLDaABL8ka2XtJpFi8kKdiiGPaUdQlJkzpG0ZAzR)WTi3I2wanPgbRGjjI7VeEfEWOctbGMI7v0Hld(d43cOvmHpFWU3pEAWuk4cbgqUfnfXHvWKeX9ZhSlhckwwcjxckKrLSQjL4bkXcmQWuaiL3CcDr0WGGK6W5ZhPN1YWDGkmDxr0GWTueqND80qgdXTKigu3qGQEYiCljcKWoi9SwgUduHP7kIgeULIa6SJNgQKv6zTmQWuaifpfk2t5ZhzvZL6qSmxoukEkuWrLSspRLvVaqUfP4PqXEkF(GDVF80GbYDmTcpyfqNKLrgz4gq4v4XLv(sRWJVh(IkmfaAkUxrhUgkSdspRLH7avy6UIOHvaHxvspRLb)vO4ahKIVqScQZEkCdi8k84YkFPv4X3dFrfMcanf3ROdxdf2bPN1YWDGkmDxr0WkGWRkzLEwlJkmfasXtHI9u(8r6zTS6faYTifpfk2t5ZNdi9Sw26pClYTOTfqtQrWkysI4(lHxHhmQWuaOP4EfD4YG)a(TaAftqgdXTKiguNBaHxHhxw5lTcp(E4lQWuaOP4EfD4AOWoi9SwgUduHP7kIgwbeEvj9SwgUduHP7kIg2DjCcdspRLH7avy6UIOHnP)O7s4eme3sIyqDUbeEfECzLV0k847HVOctbGMI7v0HRHc7G0ZAz4oqfMURiAyfq4vL0ZAz4oqfMURiAyfmjrChFqwzLEwld3bQW0Dfrd7UeoHXwcVcpyuHPaqtX9k6WLb)b8Bb0kMGmF3GpYyiULeXG6Cdi8k84YkFPv4X3dFfW2cfAHPcCxdf2bzlWwWTLK6WNpQ5kWjiIgzuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtqL0ZAzuHPaqkEkuSJNgQoG0ZAzR)WTi3I2wanPgb74Pb3acVcpUSYxAfE89WxuHPaqEjzOWoi9SwgvykaeULQgGDxcNW4dYPsqsDGT(ort6pc3svdC5gq4v4XLv(sRWJVh(6(uGkC5KHc7WKcIPG3XhsCQHkPN1YOctbGu8uOyhpnuj9Sww9ca5wKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJlR8LwHhFp8fvykaKuNURHc7G0ZAz1Rdi3I22cGl7POs6zTmQWuaiClvna7UeoHFtmUbeEfECzLV0k847HVOctbGKOQOgWqHDysbXuW74dYPsqsDGjrvrnaAsbHuWRkPN1YOctbGu8uOyhpnuj9Sww9ca5wKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAOs6zTmQWuaiClvna7UeoHbPN1YOctbGWTu1aSj9hDxcNGkS79JNgmqUJPv4bRGjjIl3acVcpUSYxAfE89WxuHPaqsuvudyOWoi9SwgvykaKINcf74PHkPN1YQxai3Iu8uOyhpnuDaPN1Yw)HBrUfTTaAsnc2XtdvspRLrfMcaHBPQby3LWjmi9SwgvykaeULQgGnP)O7s4euTuhILrfMca5LKkS79JNgmQWuaiVKyfmjrChFObFunPGyk4D8HexsQWU3pEAWa5oMwHhScMKiUCdi8k84YkFPv4X3dFrfMcajrvrnGHc7G0ZAzuHPaqkEkuSNIkPN1YOctbGu8uOyfmjrChFObFuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtqf29(Xtdgi3X0k8GvWKeXLBaHxHhxw5lTcp(E4lQWuaijQkQbmuyhKEwlREbGClsXtHI9uuj9SwgvykaKINcf74PHkPN1YQxai3Iu8uOyfmjrChFObFuj9SwgvykaeULQgGDxcNWG0ZAzuHPaq4wQAa2K(JUlHtqf29(Xtdgi3X0k8GvWKeXLBaHxHhxw5lTcp(E4lQWuaijQkQbmuyhKEwlJkmfasXtHID80qL0ZAz1laKBrkEkuSJNgQoG0ZAzR)WTi3I2wanPgb7PO6aspRLT(d3IClABb0KAeScMKiUJp0GpQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjWnGWRWJlR8LwHhFp8fvykaKevf1agkSdlvnWYAbQVTmf8oEIPgQKEwlJkmfac3svdWUlHtyq6zTmQWuaiClvnaBs)r3LWjOQEby9QbyuHPaqs(uIQZeIvfHxHCabbmfW9x1vj9Sw2bOTvYRayhpn4gq4v4XLv(sRWJVh(Ikmfac(R09RWddf2HLQgyzTa13wMcEhpXudvspRLrfMcaHBPQby3LWjmU0ZAzuHPaq4wQAa2K(JUlHtqv9cW6vdWOctbGK8PevNjeRkcVc5accykG7VQRs6zTSdqBRKxbWoEAWnGWRWJlR8LwHhFp8fvykaKuNUl3acVcpUSYxAfE89WxGChtRWddf2bPN1YQxai3Iu8uOyhpnuj9SwgvykaKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJlR8LwHhFp8fvykaKevf1aCd4gq4v4XLDBPcoi85(9WxVlGMuqOgyAOWoi7sDiwgeDrt7cbCunPGyk4D8b1ssQMuqmf8(7WyunK5ZhzvZL6qSmi6IM2fc4OAsbXuW74dQf1qgUbeEfECz3wQGdcFUFp8LIVcpmuyhKEwlJkmfasXtHI9u4gq4v4XLDBPcoi85(9WxRycOuQumuyhQxawVAa2ctfVOokLkfvspRLb)BP3DfEWEkQKf7E)4PbJkmfasXtHIvaDs(ZhROPDrfmjrChFySssgUbeEfECz3wQGdcFUFp8vx00UxKALVtZeI1qHDq6zTmQWuaifpfk2XtdvspRLvVaqUfP4PqXoEAO6aspRLT(d3IClABb0KAeSJNgCdi8k84YUTubhe(C)E4ljQb5w0wcCcxdf2bPN1YOctbGu8uOyhpnuj9Sww9ca5wKINcf74PHQdi9Sw26pClYTOTfqtQrWoEAWnGWRWJl72sfCq4Z97HVKG6cvcIOXqHDq6zTmQWuaifpfk2tHBaHxHhx2TLk4GWN73dFj1D)GSVkzdf2bPN1YOctbGu8uOypfUbeEfECz3wQGdcFUFp8LvuGu39JHc7G0ZAzuHPaqkEkuSNc3acVcpUSBlvWbHp3Vh(IcmC3I6im17gkSdspRLrfMcaP4PqXEkCdi8k84YUTubhe(C)E4R3fqIfMxdf2bPN1YOctbGu8uOypfUbeEfECz3wQGdcFUFp817ciXctdbRfWlkOjm00PJGwVUij60agkSdspRLrfMcaP4PqXEkF(GDVF80GrfMcaP4PqXkysI4(7GAOgQoG0ZAzR)WTi3I2wanPgb7PWnGWRWJl72sfCq4Z97HVExajwyAyqtyaMkjxa1rEDckWGHc7a29(XtdgvykaKINcfRGjjI74dgpjUbeEfECz3wQGdcFUFp817ciXctddAcdNcOJvuasoCVq3qHDa7E)4PbJkmfasXtHIvWKeX93bJN0NpQPCQeKuhyKcYd07cdQ)5JSRycdjPsovcsQdmrihQfoixbcOguxv9cW6vdWUcLwpq31RPmCdi8k84YUTubhe(C)E4R3fqIfMgg0egU(RJenHyHYqHDa7E)4PbJkmfasXtHIvWKeX93bJN0NpQPCQeKuhyKcYd07cdQ)5JSRycdjPsovcsQdmrihQfoixbcOguxv9cW6vdWUcLwpq31RPmCdi8k84YUTubhe(C)E4R3fqIfMgg0egA6jR0IClIUxXu0Pv4HHc7a29(XtdgvykaKINcfRGjjI7VdgpPpFut5ujiPoWifKhO3fgu)ZhzxXegssLCQeKuhyIqoulCqUceqnOUQ6fG1RgGDfkTEGURxtz4gq4v4XLDBPcoi85(9WxVlGelmnmOjmmjmjva62cWIMVRaBOWoGDVF80GrfMcaP4PqXkysI4o(GAOsw1uovcsQdmrihQfoixbcOgu)ZNvmHFtSKKHBaHxHhx2TLk4GWN73dF9UasSW0WGMWWKWKubOBlalA(UcSHc7a29(XtdgvykaKINcfRGjjI74dQHk5ujiPoWeHCOw4GCfiGAqDvspRLvVaqUfP4PqXEkQKEwlREbGClsXtHIvWKeXD8bzvpj1kuJX26fG1RgGDfkTEGURxtzuTIjmEILu2KEBRxzttX81Pv4HXwKDZBEZz]] )


end
