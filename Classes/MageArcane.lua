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


    spec:RegisterPack( "Arcane", 20201201, [[dWuJMeqisQ0JuOKUejvvuBIK8jkuJIO0PikwLcLOxPQuZIc6wKuvHDb1VuvYWKO6yKuwgfspJcrttHsDnsQyBkuKVPqbJJKQY5KijRJKQmpfQUNc2NQkDqfkHfQQIhkrIjssvvYfjPQQ(OejLoPcfLvsbMjfc3KKQQu7uH4NsKu1qjPQISusQQ0tPOPQq6Qkuu9vjsQmwjsTxj9xidMuhg1IjYJrmzvCzWMP0NLsJwkonsRMKQQ41seZwQUTI2TWVPA4K44kuOLl65Q00v66QY2jQ(UegVQQoVeL1lrsX8vvSFcxvRoA18WluhXOLB0YvZOLRgwnJuDkvgTAULPavtfMuc3cvZGNq1CSijCavtfUSUZN6OvZR)scunB2v5QEF9vlDBEsyIp)6sNVoVupijB3VU0j5RQP0J23XSOkvnp8c1rmA5gTC1mA5QHvZivNsv5LQQ5vbi1rgtgTA2qphiQsvZdCjvZXQqR(BUfe6XIKWbimySk0Q)ciWucsHwndfAJwUrlxyGWGXQqR(fMUCqOLZjLL6aMNORcpfAAi0wwUNcTBf6lSlnAVyEIUk8uOLL0aKse6Y8xk0xfGi0UYs94kdwyWyvOhZvo8chHMglKb3f6gooDA0k0UvOLZjLL6aUHLdixbc4i0Rl0sGqRMqx0aHqFHDPr7fZt0vHNc9GqRgwyWyvOhZVGqVLPqjCxOnPZsrOB440PrRq7wHM0WraDHMglK5tzPEi004UaFeA3k0gt4GaDetwQhgJfgmwfA1)3lee4k0jmD5WrO5Rq7wHEexomLGuOnQ6tOxxOt48iGqxkQFAmxOL92PTnBVmzWvZo9U36OvtxbciRJwhrT6OvtiyPoCQ)unjjDHKYvtzf68fG1ZwaFPknEGURNtmeSuhoc9NpcD(cW6zlGxyQ4j3rfCQGHGL6WrOLrOvj0l3HyX5laKBrkEbKyiyPoCeAvcnX9(XlcC(ca5wKIxajoHjtJRqRsOLvOLEwloFbGClsXlGeF8IqO)8rOvsqoQLCWQH5KWbGK4m5wqOLPAYKL6r1eK7eEPEu36igToA1ecwQdN6pvtssxiPC1mFby9SfWh6Lqv60GZYqeFo54GHGL6WrOvj0spRfFOxcvPtdoldr85KJdYM(DXpLQjtwQhvtlnbKuNVBDRJyK1rRMqWsD4u)PAss6cjLRM5laRNTaUnP3EzikHs6agcwQdhHwLqp5GXkKvO)vOlvQt1Kjl1JQPn97Icxox36iJDD0QjeSuho1FQMKKUqs5QP6k05laRNTa(svA8aDxpNyiyPoCQMmzPEunpaVnsEgqDRJOo1rRMqWsD4u)PAss6cjLRMtoySczf6Ff6XU8QjtwQhvZKpuow0vHZsQBDKXuD0QjeSuho1FQMKKUqs5QP0ZAXCs4aqkEbK4JxecTkHM4E)4fbMtchasXlGeNWKPXvOvj0QRqlNtkl1bmnKd5chKRabKc9GqRw1Kjl1JQ5THAxA0Iu8ciRBDKXqD0QjeSuho1FQMKKUqs5QPCoPSuhW0qoKlCqUceqk0dcTAcTkHM4E)4fboFbGClsXlGeNWKPXvOhe6YRMmzPEun5KWbG8uQU1ruF1rRMqWsD4u)PAss6cjLRMY5KYsDatd5qUWb5kqaPqpi0Qj0QeAI79Jxe48faYTifVasCctMgxHEqOlxOvj0spRfZjHdarA4SfW3LjLi0Jl0spRfZjHdarA4SfWt(p6UmPKQjtwQhvtojCaiPoF36whPuvhTAcbl1Ht9NQjjPlKuUAkNtkl1bmnKd5chKRabKc9GqRMqRsOLEwloFbGClsXlGeF8IOAYKL6r1mFbGClsXlGSU1ruR86OvtiyPoCQ)unjjDHKYvt5CszPoGPHCix4GCfiGuOheA1eAvcT6k0Yk05laRNTa(svA8aDxpNyiyPoCe6pFe68fG1ZwaVWuXtUJk4ubdbl1HJqlt1Kjl1JQPIVupQBDe1uRoA1ecwQdN6pvtssxiPC1u6zT48faYTifVas8XlIQjtwQhvZdWBJKNbu36iQz06OvtiyPoCQ)unjjDHKYvtPN1IZxai3Iu8ciXhVie6pFeALeKJAjhSAyojCaijotUfQMmzPEunN0m98IClA9CcXw36iQzK1rRMqWsD4u)PAss6cjLRMspRfNVaqUfP4fqIpEri0F(i0kjih1soy1WCs4aqsCMClunzYs9OAU(J0GClABa0KBP1ToIAJDD0QjeSuho1FQMKKUqs5QPscYrTKdwn86psdYTOTbqtULwnzYs9OAYjHdaP4fqw36iQPo1rRMqWsD4u)PAss6cjLRMspRfNVaqUfP4fqIpErunzYs9OAMVaqUfP4fqw36iQnMQJwnHGL6WP(t1KK0fskxnpG0ZAXR)ini3I2gan5wk(Pi0Qe6di9Sw86psdYTOTbqtULItyY04k0Jl0mzPEG5KWbGM07L2Hlg(dK3cOLoHQjtwQhvtLeUqqaKBrtACQBDe1gd1rRMqWsD4u)PAss6cjLRMl3HyX5laKBrkEbKyiyPoCeAvcT0ZAXCs4aqkEbK4NIqRsOLEwloFbGClsXlGeNWKPXvOhxOBjh8K)xnzYs9OAQKWfccGClAsJtDRJOM6RoA1ecwQdN6pvtssxiPC184lo5dLJfDv4SeCctMgxH(xHwDe6pFe6di9SwCYhkhl6QWzji5VEajlr70Tm8Dzsjc9VcD5vtMSupQMCs4aqsD(U1ToIALQ6OvtiyPoCQ)unjjDHKYvtPN1Ivs4cbbqUfnPXb)ueAvc9bKEwlE9hPb5w02aOj3sXpfHwLqFaPN1Ix)rAqUfTnaAYTuCctMgxHE8bHMjl1dmNeoaKuNVlg(dK3cOLoHQjtwQhvtojCaiPoF36whXOLxhTAcbl1Ht9NQjjPlKuUAk9SwC(ca5wKIxaj(Pi0QeAI79JxeyojCaifVasCc8PmHwLqp5GXkKvOhxOh7YfAvcT0ZAXCs4aqKgoBb8Dzsjc9Gql9SwmNeoaePHZwap5)O7YKseAvcT6k05laRNTa(svA8aDxpNyiyPoCeAvcT6k05laRNTaEHPINChvWPcgcwQdNQjtwQhvtojCaijotUfQBDeJQwD0QjeSuho1FQMKKUqs5QP0ZAX5laKBrkEbK4NIqRsOLEwlMtchasXlGeF8IqOvj0spRfNVaqUfP4fqItyY04k0Jpi0TKJqRsOLEwlMtchaI0WzlGVltkrOheAPN1I5KWbGinC2c4j)hDxMuIqRsOLZjLL6aMgYHCHdYvGaYQjtwQhvtojCaijotUfQBDeJA06OvtiyPoCQ)unjnmnQMQvnbo7LHinmnquB1u6zTysh4KW3LgTisdhb0XhViujR0ZAXCs4aqkEbK4NYNpYQUl3HyXUCiv8ciHJkzLEwloFbGClsXlGe)u(8H4E)4fbgK7eEPEGtGpLjJmYunjjDHKYvZdi9Sw86psdYTOTbqtULIFkcTkHE5oelMtchacinogcwQdhHwLqlRql9Sw8b4TrYZaWhVie6pFeAMSu5accysHRqpi0Qj0Yi0Qe6di9Sw86psdYTOTbqtULItyY04k0)k0mzPEG5KWbGM07L2Hlg(dK3cOLobHwLqlRqRUcnxQbs6cyojCaiL3CcDA0IHGL6WrO)8rOLEwlM0boj8DPrlI0WraD8XlcHwMQjtwQhvtojCaOj9EPD4w36ig1iRJwnHGL6WP(t1Kjl1JQjNeoa0KEV0oCRMKgMgvt1QMKKUqs5QP0ZAXKoWjHVlnAXjWKvOvj0e37hViWCs4aqkEbK4eMmnUcTkHwwHw6zT48faYTifVas8trO)8rOLEwlMtchasXlGe)ueAzQBDeJo21rRMqWsD4u)PAss6cjLRMspRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaV(ort(pI0WzlCfAvcTScnX9(XlcmNeoaKIxajoHjtJRq)RqRw5c9NpcntwQCabbmPWvOhFqOnQqlt1Kjl1JQjNeoaKNs1ToIrvN6OvtiyPoCQ)unjjDHKYvtPN1IZxai3Iu8ciXpfH(ZhHEYbJviRq)RqRM6unzYs9OAYjHdaj157w36igDmvhTAcbl1Ht9NQjtwQhvtqUt4L6r1KglK5tzruB1CYbJvi7VdQp1PAsJfY8PSi6CchkVq1uTQjjPlKuUAk9SwC(ca5wKIxaj(4fHqRsOLEwlMtchasXlGeF8IOU1rm6yOoA1Kjl1JQjNeoaKeNj3cvtiyPoCQ)u36wnNUCycXwhToIA1rRMqWsD4u)PAss6cjLRMtxomHyXh6D5Gac9VdcTALxnzYs9OAk1Prj1ToIrRJwnzYs9OAQKWfccGClAsJt1ecwQdN6p1ToIrwhTAcbl1Ht9NQjjPlKuUAoD5WeIfFO3Ldci0Jl0QvE1Kjl1JQjNeoa0KEV0oCRBDKXUoA1Kjl1JQjNeoaKNsvtiyPoCQ)u36iQtD0QjtwQhvtlnbKuNVB1ecwQdN6p1TUvZ0xEPEuhToIA1rRMqWsD4u)PAYKL6r1eK7eEPEunPXcz(uwe1wnNCWyfY(7qPsDujR6MVaSE2c4lvPXd0D9C(5J0ZAXxQsJhO765eFxMuYG0ZAXxQsJhO765ep5)O7YKsKPAsJfY8PSi6CchkVq1uTQjjPlKuUAo5GXkKvOhFqOLZjLL6agK7ifYk0QeAzfAI79Jxe41FKgKBrBdGMClfNWKPXvOhFqOzYs9adYDcVupWWFG8waT0ji0F(i0e37hViWCs4aqkEbK4eMmnUc94dcntwQhyqUt4L6bg(dK3cOLobH(ZhHwwHE5oeloFbGClsXlGedbl1HJqRsOjU3pErGZxai3Iu8ciXjmzACf6XheAMSupWGCNWl1dm8hiVfqlDccTmcTmcTkHw6zT48faYTifVas8XlcHwLql9SwmNeoaKIxaj(4fHqRsOpG0ZAXR)ini3I2gan5wk(4frDRJy06OvtiyPoCQ)unjjDHKYvZ8fG1ZwaFPknEGURNtmeSuhocTkHM4E)4fbMtchasXlGeNWKPXvOhFqOzYs9adYDcVupWWFG8waT0junzYs9OAcYDcVupQBDeJSoA1ecwQdN6pvtssxiPC1K4E)4fbE9hPb5w02aOj3sXjWNYeAvcTScT0ZAXCs4aqKgoBb8Dzsjc9VcTCoPSuhWRVt0K)JinC2cxHwLqtCVF8IaZjHdaP4fqItyY04k0Jpi0WFG8waT0ji0YunzYs9OAYjHdajXzYTqDRJm21rRMqWsD4u)PAss6cjLRMe37hViWR)ini3I2gan5wkob(uMqRsOLvOLEwlMtchaI0WzlGVltkrO)vOLZjLL6aE9DIM8FePHZw4k0Qe6L7qS48faYTifVasmeSuhocTkHM4E)4fboFbGClsXlGeNWKPXvOhFqOH)a5TaAPtqOvj0e37hViWCs4aqkEbK4eMmnUc9VcTCoPSuhWRVt0K)JoqNldz9eXkcTmvtMSupQMCs4aqsCMClu36iQtD0QjeSuho1FQMKKUqs5QjX9(Xlc86psdYTOTbqtULItGpLj0QeAzfAPN1I5KWbGinC2c47YKse6FfA5CszPoGxFNOj)hrA4SfUcTkHwwHwDf6L7qS48faYTifVasmeSuhoc9NpcnX9(XlcC(ca5wKIxajoHjtJRq)RqlNtkl1b867en5)Od05YqwprPRi0Yi0QeAI79JxeyojCaifVasCctMgxH(xHwoNuwQd413jAY)rhOZLHSEIyfHwMQjtwQhvtojCaijotUfQBDKXuD0QjeSuho1FQMKKUqs5Q5bKEwlo5dLJfDv4SeK8xpGKLOD6wg(UmPeHEqOpG0ZAXjFOCSORcNLGK)6bKSeTt3YWt(p6UmPeHwLqlRql9SwmNeoaKIxaj(4fHq)5Jql9SwmNeoaKIxajoHjtJRqp(Gq3socTmcTkHwwHw6zT48faYTifVas8XlcH(ZhHw6zT48faYTifVasCctMgxHE8bHULCeAzQMmzPEun5KWbGK4m5wOU1rgd1rRMqWsD4u)PAss6cjLRMhFXjFOCSORcNLGtyY04k0)k0QpH(ZhHwwH(aspRfN8HYXIUkCwcs(RhqYs0oDldFxMuIq)RqxUqRsOpG0ZAXjFOCSORcNLGK)6bKSeTt3YW3LjLi0Jl0hq6zT4Kpuow0vHZsqYF9aswI2PBz4j)hDxMuIqlt1Kjl1JQjNeoaKuNVBDRJO(QJwnHGL6WP(t1KK0fskxnLEwlwjHleea5w0Kgh8trOvj0hq6zT41FKgKBrBdGMClf)ueAvc9bKEwlE9hPb5w02aOj3sXjmzACf6XheAMSupWCs4aqsD(Uy4pqElGw6eQMmzPEun5KWbGK68DRBDKsvD0QjeSuho1FQMKgMgvt1QMaN9YqKgMgiQTAk9SwmPdCs47sJwePHJa64JxeQKv6zTyojCaifVas8t5Zhzv3L7qSyxoKkEbKWrLSspRfNVaqUfP4fqIFkF(qCVF8IadYDcVupWjWNYKrgzQMKKUqs5Q5bKEwlE9hPb5w02aOj3sXpfHwLqVChIfZjHdabKghdbl1HJqRsOLvOLEwl(a82i5za4Jxec9NpcntwQCabbmPWvOheA1eAzeAvcTSc9bKEwlE9hPb5w02aOj3sXjmzACf6FfAMSupWCs4aqt69s7Wfd)bYBb0sNGq)5JqtCVF8IaRKWfccGClAsJdoHjtJRq)5JqtC5qWXIlPSKYHqlJqRsOLvOvxHMl1ajDbmNeoaKYBoHonAXqWsD4i0F(i0spRft6aNe(U0OfrA4iGo(4fHqlt1Kjl1JQjNeoa0KEV0oCRBDe1kVoA1ecwQdN6pvtssxiPC1u6zTysh4KW3LgT4eyYk0QeAPN1IH)kCCGdsXxiwk3XpLQjtwQhvtojCaOj9EPD4w36iQPwD0QjeSuho1FQMmzPEun5KWbGM07L2HB1K0W0OAQw1KK0fskxnLEwlM0boj8DPrlobMScTkHwwHw6zTyojCaifVas8trO)8rOLEwloFbGClsXlGe)ue6pFe6di9Sw86psdYTOTbqtULItyY04k0)k0mzPEG5KWbGM07L2Hlg(dK3cOLobHwM6whrnJwhTAcbl1Ht9NQjtwQhvtojCaOj9EPD4wnjnmnQMQvnjjDHKYvtPN1IjDGtcFxA0ItGjRqRsOLEwlM0boj8DPrl(UmPeHEqOLEwlM0boj8DPrlEY)r3LjLu36iQzK1rRMqWsD4u)PAYKL6r1KtchaAsVxAhUvtsdtJQPAvtssxiPC1u6zTysh4KW3LgT4eyYk0QeAPN1IjDGtcFxA0ItyY04k0Jpi0Yk0Yk0spRft6aNe(U0OfFxMuIqpwk0mzPEG5KWbGM07L2Hlg(dK3cOLobHwgH(BHULCeAzQBDe1g76OvtiyPoCQ)unjjDHKYvtzf6eSjCByPoi0F(i0QRqVusj0OvOLrOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOvj0spRfZjHdaP4fqIpEri0Qe6di9Sw86psdYTOTbqtULIpErunzYs9OAgW2ajAHPcC36whrn1PoA1ecwQdN6pvtssxiPC1u6zTyojCaisdNTa(UmPeHE8bHwoNuwQd413jAY)rKgoBHB1Kjl1JQjNeoaKNs1ToIAJP6OvtiyPoCQ)unjjDHKYvZjhmwHSc94dcDPsDeAvcT0ZAXCs4aqkEbK4JxecTkHw6zT48faYTifVas8XlcHwLqFaPN1Ix)rAqUfTnaAYTu8XlIQjtwQhvZ7tbYWLZ1ToIAJH6OvtiyPoCQ)unjjDHKYvtPN1IZxhqUfTnjax8trOvj0spRfZjHdarA4SfW3LjLi0)k0gz1Kjl1JQjNeoaKuNVBDRJOM6RoA1ecwQdN6pvtssxiPC1CYbJviRqp(GqlNtkl1bSeNj3cOjhmsHScTkHw6zTyojCaifVas8XlcHwLql9SwC(ca5wKIxaj(4fHqRsOpG0ZAXR)ini3I2gan5wk(4fHqRsOLEwlMtchaI0WzlGVltkrOheAPN1I5KWbGinC2c4j)hDxMuIqRsOjU3pErGb5oHxQh4eMmnUvtMSupQMCs4aqsCMClu36iQvQQJwnHGL6WP(t1KK0fskxnLEwlMtchasXlGeF8IqOvj0spRfNVaqUfP4fqIpEri0Qe6di9Sw86psdYTOTbqtULIpEri0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0Qe6L7qSyojCaipLWqWsD4i0QeAI79JxeyojCaipLWjmzACf6Xhe6wYrOvj0toySczf6Xhe6sv5cTkHM4E)4fbgK7eEPEGtyY04wnzYs9OAYjHdajXzYTqDRJy0YRJwnHGL6WP(t1KK0fskxnLEwlMtchasXlGe)ueAvcT0ZAXCs4aqkEbK4eMmnUc94dcDl5i0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0QeAI79JxeyqUt4L6boHjtJB1Kjl1JQjNeoaKeNj3c1ToIrvRoA1ecwQdN6pvtssxiPC1u6zT48faYTifVas8trOvj0spRfZjHdaP4fqIpEri0QeAPN1IZxai3Iu8ciXjmzACf6Xhe6wYrOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOvj0e37hViWGCNWl1dCctMg3QjtwQhvtojCaijotUfQBDeJA06OvtiyPoCQ)unjjDHKYvtPN1I5KWbGu8ciXhVieAvcT0ZAX5laKBrkEbK4JxecTkH(aspRfV(J0GClABa0KBP4NIqRsOpG0ZAXR)ini3I2gan5wkoHjtJRqp(Gq3socTkHw6zTyojCaisdNTa(UmPeHEqOLEwlMtchaI0WzlGN8F0DzsjvtMSupQMCs4aqsCMClu36ig1iRJwnHGL6WP(t1KK0fskxnxoBHf3aCFBWkKvOhxOns1rOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOvj05laRNTaMtchasYNsCEMqSyiyPoCeAvcntwQCabbmPWvO)vOvtOvj0spRfFaEBK8ma8XlIQjtwQhvtojCaijotUfQBDeJo21rRMqWsD4u)PAss6cjLRMlNTWIBaUVnyfYk0Jl0gP6i0QeAPN1I5KWbGinC2c47YKse6XfAPN1I5KWbGinC2c4j)hDxMuIqRsOZxawpBbmNeoaKKpL48mHyXqWsD4i0QeAMSu5accysHRq)RqRMqRsOLEwl(a82i5za4JxevtMSupQMCs4aqWFLUFPEu36igvDQJwnzYs9OAYjHdaj157wnHGL6WP(tDRJy0XuD0QjeSuho1FQMKKUqs5QP0ZAX5laKBrkEbK4JxecTkHw6zTyojCaifVas8XlcHwLqFaPN1Ix)rAqUfTnaAYTu8XlIQjtwQhvtqUt4L6rDRJy0XqD0QjtwQhvtojCaijotUfQMqWsD4u)PU1TAYt0vHN1rRJOwD0QjeSuho1FQMKKUqs5Q5KdgRqwHE8bHwoNuwQdyqUJuiRqRsOLvOjU3pErGx)rAqUfTnaAYTuCctMgxHE8bHMjl1dmi3j8s9ad)bYBb0sNGq)5JqtCVF8IaZjHdaP4fqItyY04k0Jpi0mzPEGb5oHxQhy4pqElGw6ee6pFeAzf6L7qS48faYTifVasmeSuhocTkHM4E)4fboFbGClsXlGeNWKPXvOhFqOzYs9adYDcVupWWFG8waT0ji0Yi0Yi0QeAPN1IZxai3Iu8ciXhVieAvcT0ZAXCs4aqkEbK4JxecTkH(aspRfV(J0GClABa0KBP4JxevtMSupQMGCNWl1J6whXO1rRMqWsD4u)PAss6cjLRMe37hViWCs4aqkEbK4eMmnUc9GqxUqRsOLvOLEwloFbGClsXlGeF8IqOvj0Yk0e37hViWR)ini3I2gan5wkoHjtJRq)RqlNtkl1bmRGM8F0b6CziRNO13Pq)5JqtCVF8IaV(J0GClABa0KBP4eMmnUc9GqxUqlJqlt1Kjl1JQ5b4TrYZaQBDeJSoA1ecwQdN6pvtssxiPC1K4E)4fbMtchasXlGeNWKPXvOhe6YfAvcTScT0ZAX5laKBrkEbK4JxecTkHwwHM4E)4fbE9hPb5w02aOj3sXjmzACf6FfA5CszPoGzf0K)JoqNldz9eT(of6pFeAI79Jxe41FKgKBrBdGMClfNWKPXvOhe6YfAzeAzQMmzPEunN0m98IClA9CcXw36iJDD0QjtwQhvZKpuow0vHZsQMqWsD4u)PU1ruN6OvtiyPoCQ)unjjDHKYvtPN1I5KWbGu8ciXhVieAvcnX9(XlcmNeoaKIxajEZhGsyY04k0)k0mzPEGVnu7sJwKIxajMCsHwLql9SwC(ca5wKIxaj(4fHqRsOjU3pErGZxai3Iu8ciXB(auctMgxH(xHMjl1d8THAxA0Iu8ciXKtk0Qe6di9Sw86psdYTOTbqtULIpErunzYs9OAEBO2LgTifVaY6whzmvhTAcbl1Ht9NQjjPlKuUAk9SwC(ca5wKIxaj(4fHqRsOjU3pErG5KWbGu8ciXjmzACRMmzPEunZxai3Iu8ciRBDKXqD0QjeSuho1FQMKKUqs5QPScnX9(XlcmNeoaKIxajoHjtJRqpi0Ll0QeAPN1IZxai3Iu8ciXhVieAze6pFeALeKJAjhSA48faYTifVaYQjtwQhvZ1FKgKBrBdGMClTU1ruF1rRMqWsD4u)PAss6cjLRMe37hViWCs4aqkEbK4eMmnUc94cT6uUqRsOLEwloFbGClsXlGeF8IqOvj0W9cbbWYPxQhi3IuG0cKL6bgcwQdNQjtwQhvZ1FKgKBrBdGMClTU1rkv1rRMqWsD4u)PAss6cjLRMspRfNVaqUfP4fqIpEri0QeAI79Jxe41FKgKBrBdGMClfNWKPXvO)vOLZjLL6aMvqt(p6aDUmK1t067SAYKL6r1KtchasXlGSU1ruR86OvtiyPoCQ)unjjDHKYvtPN1I5KWbGu8ciXpfHwLql9SwmNeoaKIxajoHjtJRqp(GqZKL6bMtchaAsVxAhUy4pqElGw6eeAvcT0ZAXCs4aqKgoBb8Dzsjc9Gql9SwmNeoaePHZwap5)O7YKsQMmzPEun5KWbGK4m5wOU1rutT6OvtiyPoCQ)unjjDHKYvtPN1I5KWbGinC2c47YKse6XfAPN1I5KWbGinC2c4j)hDxMuIqRsOLEwloFbGClsXlGeF8IqOvj0spRfZjHdaP4fqIpEri0Qe6di9Sw86psdYTOTbqtULIpErunzYs9OAYjHda5PuDRJOMrRJwnHGL6WP(t1KK0fskxnLEwloFbGClsXlGeF8IqOvj0spRfZjHdaP4fqIpEri0Qe6di9Sw86psdYTOTbqtULIpEri0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLunzYs9OAYjHdajXzYTqDRJOMrwhTAcbl1Ht9NQjPHPr1uTQjWzVmePHPbIARMspRft6aNe(U0OfrA4iGo(4fHkzLEwlMtchasXlGe)u(8r6zT48faYTifVas8t5ZhI79JxeyqUt4L6bob(uMmvtssxiPC1u6zTysh4KW3LgT4eyYwnzYs9OAYjHdanP3lTd36whrTXUoA1ecwQdN6pvtsdtJQPAvtGZEzisdtde1wnLEwlM0boj8DPrlI0WraD8XlcvYk9SwmNeoaKIxaj(P85J0ZAX5laKBrkEbK4NYNpe37hViWGCNWl1dCc8PmzQMKKUqs5QP6k0CPgiPlG5KWbGuEZj0PrlgcwQdhH(ZhHw6zTysh4KW3LgTisdhb0XhViQMmzPEun5KWbGM07L2HBDRJOM6uhTAcbl1Ht9NQjjPlKuUAk9SwC(ca5wKIxaj(4fHqRsOLEwlMtchasXlGeF8IqOvj0hq6zT41FKgKBrBdGMClfF8IOAYKL6r1eK7eEPEu36iQnMQJwnHGL6WP(t1KK0fskxnLEwlMtchaI0WzlGVltkrOhxOLEwlMtchaI0WzlGN8F0DzsjvtMSupQMCs4aqEkv36iQngQJwnzYs9OAYjHdajXzYTq1ecwQdN6p1ToIAQV6OvtMSupQMCs4aqsD(UvtiyPoCQ)u36wnpGLF9ToADe1QJwnHGL6WP(t1KK0fskxnRMmzPEunj(lwiVkqVx36igToA1ecwQdN6pvtxPAEHTAYKL6r1uoNuwQdvt5C)bvt1QMKKUqs5QPCoPSuhWnSCa5kqahHEqOlxOvj0kjih1soy1WGCNWl1dHwLqRUcTScD(cW6zlGVuLgpq31ZjgcwQdhH(ZhHoFby9SfWlmv8K7OcovWqWsD4i0YunLZjk4junBy5aYvGao1ToIrwhTAcbl1Ht9NQPRunVWwnzYs9OAkNtkl1HQPCU)GQPAvtssxiPC1uoNuwQd4gwoGCfiGJqpi0Ll0QeAPN1I5KWbGu8ciXhVieAvcnX9(XlcmNeoaKIxajoHjtJRqRsOLvOZxawpBb8LQ04b6UEoXqWsD4i0F(i05laRNTaEHPINChvWPcgcwQdhHwMQPCorbpHQzdlhqUceWPU1rg76OvtiyPoCQ)unDLQ5f2QjtwQhvt5CszPounLZ9hunvRAss6cjLRMspRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOvj0QRql9SwC(6aYTOTjb4IFkcTkH2sBBwuctMgxHE8bHwwHwwHEYbl0Fj0mzPEG5KWbGK68DXe)UcTmc9yPqZKL6bMtchasQZ3fd)bYBb0sNGqlt1uoNOGNq10sdUJKEzu36iQtD0QjeSuho1FQMmzPEunjCVJyYs9a1P3TA2P3ff8eQM3goHdICU1ToYyQoA1ecwQdN6pvtssxiPC1KjlvoGGaMu4k0)k0gTAYKL6r1KW9oIjl1duNE3QzNExuWtOAYou36iJH6OvtiyPoCQ)unjjDHKYvt5CszPoGBy5aYvGaoc9GqxE1Kjl1JQjH7DetwQhOo9UvZo9UOGNq10vGaY6whr9vhTAcbl1Ht9NQjjPlKuUAEHDPr7fZt0vHNc9GqRw1Kjl1JQjH7DetwQhOo9UvZo9UOGNq1KNORcpRBDKsvD0QjeSuho1FQMmzPEunjCVJyYs9a1P3TA2P3ff8eQMe37hViU1ToIALxhTAcbl1Ht9NQjjPlKuUAkNtkl1bSLgChj9YqOhe6YRMmzPEunjCVJyYs9a1P3TA2P3ff8eQMPV8s9OU1rutT6OvtiyPoCQ)unjjDHKYvt5CszPoGT0G7iPxgc9GqRw1Kjl1JQjH7DetwQhOo9UvZo9UOGNq10sdUJKEzu36iQz06OvtiyPoCQ)unzYs9OAs4EhXKL6bQtVB1StVlk4junNUCycXw36wnvsG4tjERJwhrT6OvtiyPoCQ)unDLQzcxyRMmzPEunLZjLL6q1uoNOGNq1ujbLxVJa5E18aw(13Qz51ToIrRJwnHGL6WP(t10vQMxyRMmzPEunLZjLL6q1uo3Fq1uTQjjPlKuUAkNtkl1bSsckVEhbYDHEqOlxOvj05laRNTa(svA8aDxpNyiyPoCeAvcntwQCabbmPWvO)vOnA1uoNOGNq1ujbLxVJa5EDRJyK1rRMqWsD4u)PA6kvZlSvtMSupQMY5KYsDOAkN7pOAQw1KK0fskxnLZjLL6awjbLxVJa5Uqpi0Ll0Qe68fG1ZwaFPknEGURNtmeSuhocTkHM4YHGJfhaj9UNhHwLqZKLkhqqatkCf6FfA1QMY5ef8eQMkjO86Dei3RBDKXUoA1ecwQdN6pvtxPAEHTAYKL6r1uoNuwQdvt5C)bvZYRMY5ef8eQMnSCa5kqaN6whrDQJwnHGL6WP(t10vQMxyRMmzPEunLZjLL6q1uo3Fq1uTQjjPlKuUAkNtkl1bCdlhqUceWrOhe6YfAvcntwQCabbmPWvO)vOnA1uoNOGNq1SHLdixbc4u36iJP6OvtiyPoCQ)unDLQ5f2QjtwQhvt5CszPounLZ9hunvRAss6cjLRMY5KYsDa3WYbKRabCe6bHUCHwLqlNtkl1bSsckVEhbYDHEqOvRAkNtuWtOA2WYbKRabCQBDKXqD0QjeSuho1FQMUs18cB1Kjl1JQPCoPSuhQMY5(dQMLxnLZjk4junT0G7iPxg1ToI6RoA1ecwQdN6pvtxPAMWf2QjtwQhvt5CszPounLZjk4junZlAY)rhOZLHSEIwFNvZdy5xFRMQtDRJuQQJwnHGL6WP(t10vQMjCHTAYKL6r1uoNuwQdvt5CIcEcvZ8IM8F0b6CziRNO0vQMhWYV(wnvN6whrTYRJwnHGL6WP(t10vQMjCHTAYKL6r1uoNuwQdvt5CIcEcvZ8IM8F0b6CziRNiwPAEal)6B10OLx36iQPwD0QjeSuho1FQMUs1mHlSvtMSupQMY5KYsDOAkNtuWtOAYkOj)hDGoxgY6jA9DwnpGLF9TAQw51ToIAgToA1ecwQdN6pvtxPAMWf2QjtwQhvt5CszPounLZjk4juntxbn5)Od05YqwprRVZQ5bS8RVvtJwEDRJOMrwhTAcbl1Ht9NQPRunt4cB1Kjl1JQPCoPSuhQMY5ef8eQMRVt0K)JoqNldz9eXkvZdy5xFRMLx36iQn21rRMqWsD4u)PA6kvZlSvtMSupQMY5KYsDOAkN7pOAAKvtssxiPC1uoNuwQd413jAY)rhOZLHSEIyfHEqOlxOvj05laRNTa(qVeQsNgCwgI4ZjhhmeSuhovt5CIcEcvZ13jAY)rhOZLHSEIyL6whrn1PoA1ecwQdN6pvtxPAEHTAYKL6r1uoNuwQdvt5C)bvt1uNQjjPlKuUAkNtkl1b867en5)Od05YqwprSIqpi0Ll0QeAIlhcowCqBBwKLHQPCorbpHQ567en5)Od05YqwprSsDRJO2yQoA1ecwQdN6pvtxPAEHTAYKL6r1uoNuwQdvt5C)bvt1uNQjjPlKuUAkNtkl1b867en5)Od05YqwprSIqpi0Ll0QeAIhNhDXCs4aqkPFOTLHHGL6WrOvj0mzPYbeeWKcxHECH2iRMY5ef8eQMRVt0K)JoqNldz9eXk1ToIAJH6OvtiyPoCQ)unDLQ5f2QjtwQhvt5CszPounLZ9hunvNQjjPlKuUAkNtkl1b867en5)Od05YqwprSIqpi0LxnLZjk4junxFNOj)hDGoxgY6jIvQBDe1uF1rRMqWsD4u)PA6kvZeUWwnzYs9OAkNtkl1HQPCorbpHQ567en5)Od05YqwprPRunpGLF9TAA0YRBDe1kv1rRMqWsD4u)PA6kvZeUWwnzYs9OAkNtkl1HQPCorbpHQPeNj3cOjhmsHSvZdy5xFRMLx36igT86OvtiyPoCQ)unDLQ5f2QjtwQhvt5CszPounLZ9hunLvOhtLl0QFi0Yk0t(Uqwgso3FGqpwk0QvE5cTmcTmvtssxiPC1uoNuwQdyjotUfqtoyKczf6bHUCHwLqtC5qWXIdABZISmunLZjk4junL4m5wan5GrkKTU1rmQA1rRMqWsD4u)PA6kvZlSvtMSupQMY5KYsDOAkN7pOAkRqR(kxOv)qOLvON8DHSmKCU)aHESuOvR8YfAzeAzQMKKUqs5QPCoPSuhWsCMClGMCWifYk0dcD5vt5CIcEcvtjotUfqtoyKczRBDeJA06OvtiyPoCQ)unDLQzcxyRMmzPEunLZjLL6q1uoNOGNq1KvqtAqNVjAYbJuiB18aw(13Qz51ToIrnY6OvtiyPoCQ)unDLQ5f2QjtwQhvt5CszPounLZ9hunvNYRMKKUqs5QPCoPSuhWScAsd68nrtoyKczf6bHUCHwLqNVaSE2c4d9sOkDAWzziIpNCCWqWsD4unLZjk4junzf0Kg05BIMCWifYw36igDSRJwnHGL6WP(t10vQMxyRMmzPEunLZjLL6q1uo3Fq1uDkVAss6cjLRMY5KYsDaZkOjnOZ3en5GrkKvOhe6YfAvcD(cW6zlGBt6TxgIsOKoGHGL6WPAkNtuWtOAYkOjnOZ3en5GrkKTU1rmQ6uhTAcbl1Ht9NQPRunVWwnzYs9OAkNtkl1HQPCU)GQPAQt1KK0fskxnLZjLL6aMvqtAqNVjAYbJuiRqpi0LxnLZjk4junzf0Kg05BIMCWifYw36igDmvhTAcbl1Ht9NQPRunt4cB1Kjl1JQPCoPSuhQMY5ef8eQMRVt0K)JinC2c3Q5bS8RVvtJw36igDmuhTAcbl1Ht9NQPRunt4cB1Kjl1JQPCoPSuhQMY5ef8eQM0qoKlCqUceqwnpGLF9TAwEDRJyu1xD0QjeSuho1FQMUs18cB1Kjl1JQPCoPSuhQMY5(dQMQvnjjDHKYvt5CszPoGPHCix4GCfiGuOhe6YfAvc9YDiwC(ca5wKIxajgcwQdhHwLqlRqVChIfZjHdabKghdbl1HJq)5JqRUcnXLdbhlUKYskhcTmcTkHwwHwDfAIlhcowCaK07EEe6pFeAMSu5accysHRqpi0Qj0F(i05laRNTa(svA8aDxpNyiyPoCeAzQMY5ef8eQM0qoKlCqUceqw36igTuvhTAcbl1Ht9NQPRunVWwnzYs9OAkNtkl1HQPCU)GQz5vtssxiPC1uoNuwQdyAihYfoixbcif6bHU8QPCorbpHQjnKd5chKRabK1ToIrwED0QjeSuho1FQMUs18cB1Kjl1JQPCoPSuhQMY5(dQMWy8rvuGdEYewkb0TbGfnFxkrO)8rOHX4JQOahCBNpuE98IK4tli0F(i0Wy8rvuGdUTZhkVEErt4W9o1dH(ZhHggJpQIcCWholz6EGoaPeKYBt4sGGac9NpcnmgFuff4GPXLKVLL6aAm(4yFt0bKtjGq)5JqdJXhvrbo4R)6DyxA0IYNuzc9NpcnmgFuff4GVVqQ7(bXtyBk7Uc9NpcnmgFuff4Gl4sGaYlYMECe6pFeAym(OkkWbB78eqUfjX72HQPCorbpHQjRG8a9UqDRJyKQvhTAcbl1Ht9NQPRunt4cB1Kjl1JQPCoPSuhQMY5ef8eQMSdO13jAY)rKgoBHB18aw(13QPrRBDeJ0O1rRMqWsD4u)PA6kvZlSvtMSupQMY5KYsDOAkN7pOAQw1KK0fskxnLZjLL6aUHLdixbc4i0dcD5cTkH(c7sJ2lMNORcpf6bHwTQPCorbpHQzdlhqUceWPU1rmsJSoA1ecwQdN6pvtxPAMWf2QjtwQhvt5CszPounLZjk4junb5osHSvZdy5xFRMQPo1ToIro21rRMqWsD4u)PU1rms1PoA1ecwQdN6p1ToIroMQJwnHGL6WP(tDRJyKJH6OvtMSupQM33C6bItchaYYtANYz1ecwQdN6p1ToIrQ(QJwnzYs9OAYjHdarJf6DGSvtiyPoCQ)u36igzPQoA1Kjl1JQjXd1FEjGMCWOwywnHGL6WP(tDRJm2LxhTAcbl1Ht9N6whzSvRoA1Kjl1JQ5KMPNi6KBHQjeSuho1FQBDKX2O1rRMqWsD4u)PAss6cjLRMQRqlNtkl1bSsckVEhbYDHEqOvtOvj05laRNTa(qVeQsNgCwgI4ZjhhmeSuhovtMSupQM20VRK336whzSnY6OvtiyPoCQ)unjjDHKYvt1vOLZjLL6awjbLxVJa5Uqpi0Qj0QeA1vOZxawpBb8HEjuLon4SmeXNtooyiyPoCQMmzPEun5KWbGK68DRBDKXESRJwnHGL6WP(t1KK0fskxnLZjLL6awjbLxVJa5Uqpi0QvnzYs9OAcYDcVupQBDRMe37hViU1rRJOwD0QjeSuho1FQMKKUqs5Qz(cW6zlGBt6TxgIsOKoGHGL6WrOvj0e37hViWCs4aqkEbK4eMmnUc9VcTrwUqRsOjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0Yk0spRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaV(ort(pI0WzlCfAvcTScTSc9YDiwC(ca5wKIxajgcwQdhHwLqtCVF8IaNVaqUfP4fqItyY04k0Jpi0TKJqRsOjU3pErG5KWbGu8ciXjmzACf6FfA5CszPoGxFNOj)hDGoxgY6jIveAze6pFeAzfA1vOxUdXIZxai3Iu8ciXqWsD4i0QeAI79JxeyojCaifVasCctMgxH(xHwoNuwQd413jAY)rhOZLHSEIyfHwgH(ZhHM4E)4fbMtchasXlGeNWKPXvOhFqOBjhHwgHwMQjtwQhvtB63ffUCUU1rmAD0QjeSuho1FQMKKUqs5Qz(cW6zlGBt6TxgIsOKoGHGL6WrOvj0e37hViWCs4aqkEbK4eMmnUc9GqxUqRsOLvOvxHE5oelgIoTTzHaoyiyPoCe6pFeAzf6L7qSyi602Mfc4GHGL6WrOvj0toySczf6Fhe6Xq5cTmcTmcTkHwwHwwHM4E)4fbE9hPb5w02aOj3sXjmzACf6FfA1kxOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOLrO)8rOLvOjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0spRfZjHdarA4SfW3LjLi0dcD5cTmcTmcTkHw6zT48faYTifVas8XlcHwLqp5GXkKvO)DqOLZjLL6aMvqtAqNVjAYbJuiB1Kjl1JQPn97Icxox36igzD0QjeSuho1FQMKKUqs5Qz(cW6zlGp0lHQ0PbNLHi(CYXbdbl1HJqRsOjU3pErGLEwl6qVeQsNgCwgI4ZjhhCc8PmHwLql9Sw8HEjuLon4SmeXNtooiB63fF8IqOvj0Yk0spRfZjHdaP4fqIpEri0QeAPN1IZxai3Iu8ciXhVieAvc9bKEwlE9hPb5w02aOj3sXhVieAzeAvcnX9(Xlc86psdYTOTbqtULItyY04k0dcD5cTkHwwHw6zTyojCaisdNTa(UmPeHE8bHwoNuwQd413jAY)rKgoBHRqRsOLvOLvOxUdXIZxai3Iu8ciXqWsD4i0QeAI79Jxe48faYTifVasCctMgxHE8bHULCeAvcnX9(XlcmNeoaKIxajoHjtJRq)RqlNtkl1b867en5)Od05YqwprSIqlJq)5JqlRqRUc9YDiwC(ca5wKIxajgcwQdhHwLqtCVF8IaZjHdaP4fqItyY04k0)k0Y5KYsDaV(ort(p6aDUmK1teRi0Yi0F(i0e37hViWCs4aqkEbK4eMmnUc94dcDl5i0Yi0YunzYs9OAAt)UsEFRBDKXUoA1ecwQdN6pvtssxiPC1mFby9SfWh6Lqv60GZYqeFo54GHGL6WrOvj0e37hViWspRfDOxcvPtdoldr85KJdob(uMqRsOLEwl(qVeQsNgCwgI4ZjhhKLMa(4fHqRsOvsqoQLCWQHTPFxjVVvtMSupQMwAciPoF36whrDQJwnHGL6WP(t1KK0fskxnjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0spRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaV(ort(pI0WzlCfAvcnX9(XlcmNeoaKIxajoHjtJRqp(Gq3sovtMSupQMtAMEErUfTEoHyRBDKXuD0QjeSuho1FQMKKUqs5QjX9(XlcmNeoaKIxajoHjtJRqpi0Ll0QeAzfA1vOxUdXIHOtBBwiGdgcwQdhH(ZhHwwHE5oelgIoTTzHaoyiyPoCeAvc9KdgRqwH(3bHEmuUqlJqlJqRsOLvOLvOjU3pErGx)rAqUfTnaAYTuCctMgxH(xHwoNuwQdywbn5)Od05YqwprRVtHwLql9SwmNeoaePHZwaFxMuIqpi0spRfZjHdarA4SfWt(p6UmPeHwgH(ZhHwwHM4E)4fbE9hPb5w02aOj3sXjmzACf6bHUCHwLql9SwmNeoaePHZwaFxMuIqpi0Ll0Yi0Yi0QeAPN1IZxai3Iu8ciXhVieAvc9KdgRqwH(3bHwoNuwQdywbnPbD(MOjhmsHSvtMSupQMtAMEErUfTEoHyRBDKXqD0QjeSuho1FQMKKUqs5QjX9(Xlc86psdYTOTbqtULItyY04k0dcD5cTkHw6zTyojCaisdNTa(UmPeHE8bHwoNuwQd413jAY)rKgoBHRqRsOjU3pErG5KWbGu8ciXjmzACf6Xhe6wYPAYKL6r18a82i5za1ToI6RoA1ecwQdN6pvtssxiPC1K4E)4fbMtchasXlGeNWKPXvOhe6YfAvcTScT6k0l3HyXq0PTnleWbdbl1HJq)5JqlRqVChIfdrN22SqahmeSuhocTkHEYbJviRq)7GqpgkxOLrOLrOvj0Yk0Yk0e37hViWR)ini3I2gan5wkoHjtJRq)RqRw5cTkHw6zTyojCaisdNTa(UmPeHEqOLEwlMtchaI0WzlGN8F0DzsjcTmc9NpcTScnX9(Xlc86psdYTOTbqtULItyY04k0dcD5cTkHw6zTyojCaisdNTa(UmPeHEqOlxOLrOLrOvj0spRfNVaqUfP4fqIpEri0Qe6jhmwHSc9VdcTCoPSuhWScAsd68nrtoyKczRMmzPEunpaVnsEgqDRJuQQJwnHGL6WP(t1KK0fskxnjU3pErGx)rAqUfTnaAYTuCctMgxH(xHwoNuwQd48IM8F0b6CziRNO13PqRsOjU3pErG5KWbGu8ciXjmzACf6FfA5CszPoGZlAY)rhOZLHSEIyfHwLqlRqVChIfNVaqUfP4fqIHGL6WrOvj0Yk0e37hViW5laKBrkEbK4eMmnUc94cn8hiVfqlDcc9NpcnX9(XlcC(ca5wKIxajoHjtJRq)RqlNtkl1bCErt(p6aDUmK1tu6kcTmc9NpcT6k0l3HyX5laKBrkEbKyiyPoCeAzeAvcT0ZAXCs4aqKgoBb8Dzsjc9VcTrfAvc9bKEwlE9hPb5w02aOj3sXhVieAvcT0ZAX5laKBrkEbK4JxecTkHw6zTyojCaifVas8XlIQjtwQhvZKpuow0vHZsQBDe1kVoA1ecwQdN6pvtssxiPC1K4E)4fbE9hPb5w02aOj3sXjmzACf6XfA4pqElGw6eeAvcT0ZAXCs4aqKgoBb8Dzsjc94dcTCoPSuhWRVt0K)JinC2cxHwLqtCVF8IaZjHdaP4fqItyY04k0Jl0Yk0WFG8waT0ji0Fl0mzPEGx)rAqUfTnaAYTum8hiVfqlDccTmvtMSupQMjFOCSORcNLu36iQPwD0QjeSuho1FQMKKUqs5QjX9(XlcmNeoaKIxajoHjtJRqpUqd)bYBb0sNGqRsOLvOLvOvxHE5oelgIoTTzHaoyiyPoCe6pFeAzf6L7qSyi602Mfc4GHGL6WrOvj0toySczf6Fhe6Xq5cTmcTmcTkHwwHwwHM4E)4fbE9hPb5w02aOj3sXjmzACf6FfA5CszPoGzf0K)JoqNldz9eT(ofAvcT0ZAXCs4aqKgoBb8Dzsjc9Gql9SwmNeoaePHZwap5)O7YKseAze6pFeAzfAI79Jxe41FKgKBrBdGMClfNWKPXvOhe6YfAvcT0ZAXCs4aqKgoBb8Dzsjc9GqxUqlJqlJqRsOLEwloFbGClsXlGeF8IqOvj0toySczf6FheA5CszPoGzf0Kg05BIMCWifYk0YunzYs9OAM8HYXIUkCwsDRJOMrRJwnHGL6WP(t1KK0fskxnLEwlMtchaI0WzlGVltkrOhFqOLZjLL6aE9DIM8FePHZw4k0QeAI79JxeyojCaifVasCctMgxHE8bHg(dK3cOLoHQjtwQhvZ1FKgKBrBdGMClTU1ruZiRJwnHGL6WP(t1KK0fskxnLEwlMtchaI0WzlGVltkrOhFqOLZjLL6aE9DIM8FePHZw4k0Qe6L7qS48faYTifVasmeSuhocTkHM4E)4fboFbGClsXlGeNWKPXvOhFqOH)a5TaAPtqOvj0e37hViWCs4aqkEbK4eMmnUc9VcTCoPSuhWRVt0K)JoqNldz9eXkvtMSupQMR)ini3I2gan5wADRJO2yxhTAcbl1Ht9NQjjPlKuUAk9SwmNeoaePHZwaFxMuIqp(GqlNtkl1b867en5)isdNTWvOvj0Yk0QRqVChIfNVaqUfP4fqIHGL6WrO)8rOjU3pErGZxai3Iu8ciXjmzACf6FfA5CszPoGxFNOj)hDGoxgY6jkDfHwgHwLqtCVF8IaZjHdaP4fqItyY04k0)k0Y5KYsDaV(ort(p6aDUmK1teRunzYs9OAU(J0GClABa0KBP1ToIAQtD0QjeSuho1FQMKKUqs5QjX9(Xlc86psdYTOTbqtULItyY04k0)k0Y5KYsDaZkOj)hDGoxgY6jA9Dk0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0QeAPN1IZxai3Iu8ciXhVieAvc9KdgRqwH(3bHwoNuwQdywbnPbD(MOjhmsHSvtMSupQMCs4aqkEbK1ToIAJP6OvtiyPoCQ)unjjDHKYvtPN1I5KWbGu8ciXhVieAvcnX9(Xlc86psdYTOTbqtULItyY04k0)k0Y5KYsDaNUcAY)rhOZLHSEIwFNcTkHw6zTyojCaisdNTa(UmPeHEqOLEwlMtchaI0WzlGN8F0DzsjcTkHwwHM4E)4fbMtchasXlGeNWKPXvO)vOvZOc9Npc9bKEwlE9hPb5w02aOj3sXpfHwMQjtwQhvZ8faYTifVaY6whrTXqD0QjeSuho1FQMKKUqs5QP0ZAXCs4aqkEbK4JxecTkHM4E)4fbMtchasXlGeV5dqjmzACf6FfAMSupW3gQDPrlsXlGetoPqRsOLEwloFbGClsXlGeF8IqOvj0e37hViW5laKBrkEbK4nFakHjtJRq)RqZKL6b(2qTlnArkEbKyYjfAvc9bKEwlE9hPb5w02aOj3sXhViQMmzPEunVnu7sJwKIxazDRJOM6RoA1ecwQdN6pvtssxiPC1C5oeloFbGClsXlGedbl1HJqRsOLEwlMtchasXlGe)ueAvcT0ZAX5laKBrkEbK4eMmnUc94cDl5GN8)QjtwQhvtLeUqqaKBrtACQBDe1kv1rRMqWsD4u)PAss6cjLRMhq6zT41FKgKBrBdGMClf)ueAvc9bKEwlE9hPb5w02aOj3sXjmzACf6XfAMSupWCs4aqt69s7Wfd)bYBb0sNGqRsOvxHM4YHGJfxszjLJQjtwQhvtLeUqqaKBrtACQBDeJwED0QjeSuho1FQMKKUqs5QP0ZAX5laKBrkEbK4NIqRsOLEwloFbGClsXlGeNWKPXvOhxOBjh8K)l0QeAI79JxeyqUt4L6bob(uMqRsOvxHM4YHGJfxszjLJQjtwQhvtLeUqqaKBrtACQBDRM3goHdICU1rRJOwD0QjeSuho1FQMKKUqs5QPSc9YDiwmeDABZcbCWqWsD4i0Qe6jhmwHSc94dcT6RCHwLqp5GXkKvO)DqOhtQJqlJq)5JqlRqRUc9YDiwmeDABZcbCWqWsD4i0Qe6jhmwHSc94dcT6tDeAzQMmzPEunNCWOwyw36igToA1ecwQdN6pvtssxiPC1u6zTyojCaifVas8tPAYKL6r1uXxQh1ToIrwhTAcbl1Ht9NQjjPlKuUAMVaSE2c4fMkEYDubNkyiyPoCeAvcT0ZAXW)g(DxQh4NIqRsOLvOjU3pErG5KWbGu8ciXjWNYe6pFeAlTTzrjmzACf6Xhe6XUCHwMQjtwQhvZLobubNk1ToYyxhTAcbl1Ht9NQjjPlKuUAk9SwmNeoaKIxaj(4fHqRsOLEwloFbGClsXlGeF8IqOvj0hq6zT41FKgKBrBdGMClfF8IOAYKL6r1StBB2ls9N3PDcXw36iQtD0QjeSuho1FQMKKUqs5QP0ZAXCs4aqkEbK4JxecTkHw6zT48faYTifVas8XlcHwLqFaPN1Ix)rAqUfTnaAYTu8XlIQjtwQhvtjUf5w0Musj36whzmvhTAcbl1Ht9NQjjPlKuUAk9SwmNeoaKIxaj(PunzYs9OAkb5fYsOrBDRJmgQJwnHGL6WP(t1KK0fskxnLEwlMtchasXlGe)uQMmzPEunL6UFq2xwwDRJO(QJwnHGL6WP(t1KK0fskxnLEwlMtchasXlGe)uQMmzPEunT0eK6UFQBDKsvD0QjeSuho1FQMKKUqs5QP0ZAXCs4aqkEbK4Ns1Kjl1JQjhe4Uj3reU3RBDe1kVoA1ecwQdN6pvtssxiPC1u6zTyojCaifVas8tPAYKL6r18DbeDH5TU1rutT6OvtiyPoCQ)unzYs9OA225dLxpVij(0cvtssxiPC1u6zTyojCaifVas8trO)8rOjU3pErG5KWbGu8ciXjmzACf6FheA1rDeAvc9bKEwlE9hPb5w02aOj3sXpLQjyTazrbpHQzBNpuE98IK4tlu36iQz06OvtiyPoCQ)unzYs9OActLYsG7ippbheOAss6cjLRMe37hViWCs4aqkEbK4eMmnUc94dcTrlVAg8eQMWuPSe4oYZtWbbQBDe1mY6OvtiyPoCQ)unzYs9OAEsGpwAci5W9c9QjjPlKuUAsCVF8IaZjHdaP4fqItyY04k0)oi0gTCH(ZhHwDfA5CszPoGzfKhO3fe6bHwnH(ZhHwwHEPtqOhe6YfAvcTCoPSuhW0qoKlCqUceqk0dcTAcTkHoFby9SfWxQsJhO765edbl1HJqlt1m4junpjWhlnbKC4EHEDRJO2yxhTAcbl1Ht9NQjtwQhvZR)6iABqxiRMKKUqs5QjX9(XlcmNeoaKIxajoHjtJRq)7GqB0Yf6pFeA1vOLZjLL6aMvqEGExqOheA1e6pFeAzf6LobHEqOlxOvj0Y5KYsDatd5qUWb5kqaPqpi0Qj0Qe68fG1ZwaFPknEGURNtmeSuhocTmvZGNq186VoI2g0fY6whrn1PoA1ecwQdN6pvtMSupQMT9YuAqUfX3lDs78s9OAss6cjLRMe37hViWCs4aqkEbK4eMmnUc9VdcTrlxO)8rOvxHwoNuwQdywb5b6DbHEqOvtO)8rOLvOx6ee6bHUCHwLqlNtkl1bmnKd5chKRabKc9GqRMqRsOZxawpBb8LQ04b6UEoXqWsD4i0YundEcvZ2Ezkni3I47LoPDEPEu36iQnMQJwnHGL6WP(t1Kjl1JQ5KjSucOBdalA(Uus1KK0fskxnjU3pErG5KWbGu8ciXjmzACf6XheA1rOvj0Yk0QRqlNtkl1bmnKd5chKRabKc9GqRMq)5JqV0ji0)k0gz5cTmvZGNq1CYewkb0TbGfnFxkPU1ruBmuhTAcbl1Ht9NQjtwQhvZjtyPeq3gaw08DPKQjjPlKuUAsCVF8IaZjHdaP4fqItyY04k0Jpi0QJqRsOLZjLL6aMgYHCHdYvGasHEqOvtOvj0spRfNVaqUfP4fqIFkcTkHw6zT48faYTifVasCctMgxHE8bHwwHwTYfA1peA1rOhlf68fG1ZwaFPknEGURNtmeSuhocTmcTkHEPtqOhxOnYYRMbpHQ5KjSucOBdalA(UusDRB1KDOoADe1QJwnHGL6WP(t1KK0fskxnZxawpBb8HEjuLon4SmeXNtooyiyPoCeAvcnX9(XlcS0ZArh6Lqv60GZYqeFo54GtGpLj0QeAPN1Ip0lHQ0PbNLHi(CYXbzt)U4JxecTkHwwHw6zTyojCaifVas8XlcHwLql9SwC(ca5wKIxaj(4fHqRsOpG0ZAXR)ini3I2gan5wk(4fHqlJqRsOjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0Yk0spRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaZoGwFNOj)hrA4SfUcTkHwwHwwHE5oeloFbGClsXlGedbl1HJqRsOjU3pErGZxai3Iu8ciXjmzACf6Xhe6wYrOvj0e37hViWCs4aqkEbK4eMmnUc9VcTCoPSuhWRVt0K)JoqNldz9eXkcTmc9NpcTScT6k0l3HyX5laKBrkEbKyiyPoCeAvcnX9(XlcmNeoaKIxajoHjtJRq)RqlNtkl1b867en5)Od05YqwprSIqlJq)5JqtCVF8IaZjHdaP4fqItyY04k0Jpi0TKJqlJqlt1Kjl1JQPn97k59TU1rmAD0QjeSuho1FQMKKUqs5QPScD(cW6zlGp0lHQ0PbNLHi(CYXbdbl1HJqRsOjU3pErGLEwl6qVeQsNgCwgI4ZjhhCc8PmHwLql9Sw8HEjuLon4SmeXNtooilnb8XlcHwLqRKGCul5GvdBt)UsEFfAze6pFeAzf68fG1ZwaFOxcvPtdoldr85KJdgcwQdhHwLqV0ji0dcD5cTmvtMSupQMwAciPoF36whXiRJwnHGL6WP(t1KK0fskxnZxawpBbCBsV9YqucL0bmeSuhocTkHM4E)4fbMtchasXlGeNWKPXvO)vOnYYfAvcnX9(Xlc86psdYTOTbqtULItyY04k0dcD5cTkHwwHw6zTyojCaisdNTa(UmPeHE8bHwoNuwQdy2b067en5)isdNTWvOvj0Yk0Yk0l3HyX5laKBrkEbKyiyPoCeAvcnX9(XlcC(ca5wKIxajoHjtJRqp(Gq3socTkHM4E)4fbMtchasXlGeNWKPXvO)vOLZjLL6aE9DIM8F0b6CziRNiwrOLrO)8rOLvOvxHE5oeloFbGClsXlGedbl1HJqRsOjU3pErG5KWbGu8ciXjmzACf6FfA5CszPoGxFNOj)hDGoxgY6jIveAze6pFeAI79JxeyojCaifVasCctMgxHE8bHULCeAzeAzQMmzPEunTPFxu4Y56whzSRJwnHGL6WP(t1KK0fskxnZxawpBbCBsV9YqucL0bmeSuhocTkHM4E)4fbMtchasXlGeNWKPXvOhe6YfAvcTScTScTScnX9(Xlc86psdYTOTbqtULItyY04k0)k0Y5KYsDaZkOj)hDGoxgY6jA9Dk0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0Yi0F(i0Yk0e37hViWR)ini3I2gan5wkoHjtJRqpi0Ll0QeAPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwgHwgHwLql9SwC(ca5wKIxaj(4fHqlt1Kjl1JQPn97Icxox36iQtD0QjeSuho1FQMKKUqs5Qz(cW6zlGVuLgpq31ZjgcwQdhHwLqRKGCul5GvddYDcVupQMmzPEunx)rAqUfTnaAYT06whzmvhTAcbl1Ht9NQjjPlKuUAMVaSE2c4lvPXd0D9CIHGL6WrOvj0Yk0kjih1soy1WGCNWl1dH(ZhHwjb5OwYbRgE9hPb5w02aOj3sfAzQMmzPEun5KWbGu8ciRBDKXqD0QjeSuho1FQMKKUqs5Q5sNGq)RqBKLl0Qe68fG1ZwaFPknEGURNtmeSuhocTkHw6zTyojCaisdNTa(UmPeHE8bHwoNuwQdy2b067en5)isdNTWvOvj0e37hViWR)ini3I2gan5wkoHjtJRqpi0Ll0QeAI79JxeyojCaifVasCctMgxHE8bHULCQMmzPEunb5oHxQh1ToI6RoA1ecwQdN6pvtMSupQMGCNWl1JQjnwiZNYIO2QP0ZAXxQsJhO765eFxMuYG0ZAXxQsJhO765ep5)O7YKsQM0yHmFklIoNWHYlunvRAss6cjLRMlDcc9VcTrwUqRsOZxawpBb8LQ04b6UEoXqWsD4i0QeAI79JxeyojCaifVasCctMgxHEqOlxOvj0Yk0Yk0Yk0e37hViWR)ini3I2gan5wkoHjtJRq)RqlNtkl1bmRGM8F0b6CziRNO13PqRsOLEwlMtchaI0WzlGVltkrOheAPN1I5KWbGinC2c4j)hDxMuIqlJq)5JqlRqtCVF8IaV(J0GClABa0KBP4eMmnUc9GqxUqRsOLEwlMtchaI0WzlGVltkrOhFqOLZjLL6aMDaT(ort(pI0WzlCfAzeAzeAvcT0ZAX5laKBrkEbK4JxecTm1TosPQoA1ecwQdN6pvtssxiPC1uwHM4E)4fbMtchasXlGeNWKPXvO)vOhB1rO)8rOjU3pErG5KWbGu8ciXjmzACf6XheAJuOLrOvj0e37hViWR)ini3I2gan5wkoHjtJRqpi0Ll0QeAzfAPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwLqlRqlRqVChIfNVaqUfP4fqIHGL6WrOvj0e37hViW5laKBrkEbK4eMmnUc94dcDl5i0QeAI79JxeyojCaifVasCctMgxH(xHwDeAze6pFeAzfA1vOxUdXIZxai3Iu8ciXqWsD4i0QeAI79JxeyojCaifVasCctMgxH(xHwDeAze6pFeAI79JxeyojCaifVasCctMgxHE8bHULCeAzeAzQMmzPEunN0m98IClA9CcXw36iQvED0QjeSuho1FQMKKUqs5QjX9(Xlc86psdYTOTbqtULItyY04k0Jl0WFG8waT0ji0QeAzfAPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwLqlRqlRqVChIfNVaqUfP4fqIHGL6WrOvj0e37hViW5laKBrkEbK4eMmnUc94dcDl5i0QeAI79JxeyojCaifVasCctMgxH(xHwoNuwQd413jAY)rhOZLHSEIyfHwgH(ZhHwwHwDf6L7qS48faYTifVasmeSuhocTkHM4E)4fbMtchasXlGeNWKPXvO)vOLZjLL6aE9DIM8F0b6CziRNiwrOLrO)8rOjU3pErG5KWbGu8ciXjmzACf6Xhe6wYrOLrOLPAYKL6r1m5dLJfDv4SK6whrn1QJwnHGL6WP(t1KK0fskxnjU3pErG5KWbGu8ciXjmzACf6XfA4pqElGw6eeAvcTScTScTScnX9(Xlc86psdYTOTbqtULItyY04k0)k0Y5KYsDaZkOj)hDGoxgY6jA9Dk0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0Yi0F(i0Yk0e37hViWR)ini3I2gan5wkoHjtJRqpi0Ll0QeAPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwgHwgHwLql9SwC(ca5wKIxaj(4fHqlt1Kjl1JQzYhkhl6QWzj1ToIAgToA1ecwQdN6pvtssxiPC1K4E)4fbMtchasXlGeNWKPXvOhe6YfAvcTScTScTScnX9(Xlc86psdYTOTbqtULItyY04k0)k0Y5KYsDaZkOj)hDGoxgY6jA9Dk0QeAPN1I5KWbGinC2c47YKse6bHw6zTyojCaisdNTaEY)r3LjLi0Yi0F(i0Yk0e37hViWR)ini3I2gan5wkoHjtJRqpi0Ll0QeAPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwgHwgHwLql9SwC(ca5wKIxaj(4fHqlt1Kjl1JQ5b4TrYZaQBDe1mY6OvtiyPoCQ)unjjDHKYvtPN1I5KWbGinC2c47YKse6XheA5CszPoGzhqRVt0K)JinC2cxHwLqlRqlRqVChIfNVaqUfP4fqIHGL6WrOvj0e37hViW5laKBrkEbK4eMmnUc94dcDl5i0QeAI79JxeyojCaifVasCctMgxH(xHwoNuwQd413jAY)rhOZLHSEIyfHwgH(ZhHwwHwDf6L7qS48faYTifVasmeSuhocTkHM4E)4fbMtchasXlGeNWKPXvO)vOLZjLL6aE9DIM8F0b6CziRNiwrOLrO)8rOjU3pErG5KWbGu8ciXjmzACf6Xhe6wYrOLPAYKL6r1C9hPb5w02aOj3sRBDe1g76OvtiyPoCQ)unjjDHKYvtzfAzfAI79Jxe41FKgKBrBdGMClfNWKPXvO)vOLZjLL6aMvqt(p6aDUmK1t067uOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOLrO)8rOLvOjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0spRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaZoGwFNOj)hrA4SfUcTmcTmcTkHw6zT48faYTifVas8XlIQjtwQhvtojCaifVaY6whrn1PoA1ecwQdN6pvtssxiPC1u6zT48faYTifVas8XlcHwLqlRqlRqtCVF8IaV(J0GClABa0KBP4eMmnUc9VcTrlxOvj0spRfZjHdarA4SfW3LjLi0dcT0ZAXCs4aqKgoBb8K)JUltkrOLrO)8rOLvOjU3pErGx)rAqUfTnaAYTuCctMgxHEqOlxOvj0spRfZjHdarA4SfW3LjLi0Jpi0Y5KYsDaZoGwFNOj)hrA4SfUcTmcTmcTkHwwHM4E)4fbMtchasXlGeNWKPXvO)vOvZOc9Npc9bKEwlE9hPb5w02aOj3sXpfHwMQjtwQhvZ8faYTifVaY6whrTXuD0QjeSuho1FQMKKUqs5QP0ZAXCs4aqkEbK4JxecTkHM4E)4fbMtchasXlGeV5dqjmzACf6FfAMSupW3gQDPrlsXlGetoPqRsOLEwloFbGClsXlGeF8IqOvj0e37hViW5laKBrkEbK4nFakHjtJRq)RqZKL6b(2qTlnArkEbKyYjfAvc9bKEwlE9hPb5w02aOj3sXhViQMmzPEunVnu7sJwKIxazDRJO2yOoA1ecwQdN6pvtssxiPC1u6zT4dWBJKNbGFkcTkH(aspRfV(J0GClABa0KBP4NIqRsOpG0ZAXR)ini3I2gan5wkoHjtJRqp(Gql9SwSscxiiaYTOjno4j)hDxMuIqpwk0mzPEG5KWbGK68DXWFG8waT0junzYs9OAQKWfccGClAsJtDRJOM6RoA1ecwQdN6pvtssxiPC1u6zT4dWBJKNbGFkcTkHwwHwwHE5oeloHRhCqameSuhocTkHMjlvoGGaMu4k0Jl0JTqlJq)5JqZKLkhqqatkCf6XfA1rOLrOvj0Yk0QRqNVaSE2cyojCaijFkX5zcXIHGL6WrO)8rOxoBHf3aCFBWkKvO)vOns1rOLPAYKL6r1KtchasQZ3TU1ruRuvhTAYKL6r18(uGmC5C1ecwQdN6p1ToIrlVoA1ecwQdN6pvtssxiPC1u6zTyojCaisdNTa(UmPeHEqOlVAYKL6r1KtchaYtP6whXOQvhTAcbl1Ht9NQjjPlKuUAkRqNGnHBdl1bH(ZhHwDf6LskHgTcTmcTkHw6zTyojCaisdNTa(UmPeHEqOLEwlMtchaI0WzlGN8F0DzsjvtMSupQMbSnqIwyQa3TU1rmQrRJwnHGL6WP(t1KK0fskxnLEwlM0boj8DPrlobMScTkHoFby9SfWCs4aq0Wsd6wggcwQdhHwLqVChIfZtLo1sj8s9adbl1HJqRsOzYsLdiiGjfUc94cT6RAYKL6r1KtchaAsVxAhU1ToIrnY6OvtiyPoCQ)unjjDHKYvtPN1IjDGtcFxA0ItGjRqRsOLvOZxawpBbmNeoaenS0GULHHGL6WrO)8rOxUdXI5PsNAPeEPEGHGL6WrOLrOvj0mzPYbeeWKcxHECHwDQMmzPEun5KWbGM07L2HBDRJy0XUoA1ecwQdN6pvtssxiPC1u6zTyojCaisdNTa(UmPeHECHw6zTyojCaisdNTaEY)r3LjLunzYs9OAYjHdab)v6(L6rDRJyu1PoA1ecwQdN6pvtssxiPC1u6zTyojCaisdNTa(UmPeHEqOLEwlMtchaI0WzlGN8F0DzsjcTkHwjb5OwYbRgMtchasIZKBHQjtwQhvtojCai4Vs3VupQBDeJoMQJwnHGL6WP(t1KK0fskxnLEwlMtchaI0WzlGVltkrOheAPN1I5KWbGinC2c4j)hDxMus1Kjl1JQjNeoaKeNj3c1ToIrhd1rRM0yHmFklIARMtoyScz)Dq9PovtASqMpLfrNt4q5fQMQvnzYs9OAcYDcVupQMqWsD4u)PU1TAAPb3rsVmQJwhrT6OvtiyPoCQ)unzYs9OAYjHdanP3lTd3QjPHPr1uTQjjPlKuUAk9SwmPdCs47sJwCcmzRBDeJwhTAYKL6r1KtchasQZ3TAcbl1Ht9N6whXiRJwnzYs9OAYjHdajXzYTq1ecwQdN6p1TU1TAkhYl1J6igTCJwUAQzu1x1SGZGgT3QzPUXc1VJmMnsPw1tOf6rBaHMov8CfARNcTXUceqASqNWy8rt4i0xFccn)wFYlCeAsdhTWflmWiObi0QPEcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzv7VmyHbgbnaHwn1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRr)ldwyGrqdqOnQ6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwOLvT)YGfgye0aeAJu9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAac9yREcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAEfA1)L6ncHww1(ldwyGrqdqOvRC1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRr)ldwyGrqdqOvBmOEcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzv7VmyHbgbnaH2OLREcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaH2OLREcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAEfA1)L6ncHww1(ldwyGrqdqOnQrvpHUu8qoKlCeAJxUdXIlTXc96cTXl3HyXLgdbl1HJXcTSQ9xgSWaHbL6glu)oYy2iLAvpHwOhTbeA6uXZvOTEk0gZoySqNWy8rt4i0xFccn)wFYlCeAsdhTWflmWiObi0QPEcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzn6FzWcdmcAacTAQNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHww1(ldwyGrqdqOnQ6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwOL1O)LblmWiObi0gP6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOL1O)LblmWiObi0gP6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwOLvT)YGfgye0ae6Xw9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAacT6OEcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaHEmPEcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaHEmOEcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaHw9PEcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaHUuPEcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzn6FzWcdmcAacTALREcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzn6FzWcdmcAacTAgP6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOL1O)LblmWiObi0QP(upHUu8qoKlCeAJxUdXIlTXc96cTXl3HyXLgdbl1HJXcTSQ9xgSWaJGgGqRM6t9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAacTrnQ6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOLvT)YGfgye0aeAJAu1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRA)LblmWiObi0g1ivpHUu8qoKlCeAJxUdXIlTXc96cTXl3HyXLgdbl1HJXcTSQ9xgSWaJGgGqBuJu9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdeguQBSq97iJzJuQv9eAHE0gqOPtfpxH26PqBC6lVupmwOtym(OjCe6RpbHMFRp5focnPHJw4Ifgye0aeA1upHUu8qoKlCeAJxUdXIlTXc96cTXl3HyXLgdbl1HJXcTSQ9xgSWaJGgGqBu1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRA)LblmWiObi0JT6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOLvT)YGfgye0aeA1r9e6sXd5qUWrOnE5oelU0gl0Rl0gVChIfxAmeSuhogl0YQ2FzWcdmcAacDPs9e6sXd5qUWrOnE5oelU0gl0Rl0gVChIfxAmeSuhogl0YQ2FzWcdmcAacTALk1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRA)LblmWiObi0g1ivpHUu8qoKlCeAJZxawpBbCPnwOxxOnoFby9SfWLgdbl1HJXcTSQ9xgSWaJGgGqB0Xw9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdeguQBSq97iJzJuQv9eAHE0gqOPtfpxH26PqB8bS8RVgl0jmgF0eoc91NGqZV1N8chHM0WrlCXcdmcAacTrvpHUu8qoKlCeAJZxawpBbCPnwOxxOnoFby9SfWLgdbl1HJXcTSg9VmyHbgbnaH2ivpHUu8qoKlCeAJZxawpBbCPnwOxxOnoFby9SfWLgdbl1HJXcTSg9VmyHbgbnaHESvpHUu8qoKlCeAt6Sue6BzXY)fA1pl0Rl0gXJf6dvo9s9qODfi51tHw2VKrOLvT)YGfgimOu3yH63rgZgPuR6j0c9OnGqtNkEUcT1tH2yLei(uIxJf6egJpAchH(6tqO536tEHJqtA4OfUyHbgbnaH2OQNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHww1(ldwyGrqdqOns1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRA)LblmWiObi0Qn2QNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHMxHw9FPEJqOLvT)YGfgye0aeA1gtQNqxkEihYfocTXepop6IlTXc96cTXepop6IlngcwQdhJfAzv7VmyHbgbnaH2OgP6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwO5vOv)xQ3ieAzv7VmyHbgbnaH2OJT6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwO5vOv)xQ3ieAzv7VmyHbgbnaH2OQp1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRr)ldwyGrqdqOnQ6t9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAac9yBu1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqZRqR(VuVri0YQ2FzWcdmcAac9yBKQNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHMxHw9FPEJqOLvT)YGfgimOu3yH63rgZgPuR6j0c9OnGqtNkEUcT1tH2yI79JxexJf6egJpAchH(6tqO536tEHJqtA4OfUyHbgbnaHwn1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRr)ldwyGrqdqOvt9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAacTrvpHUu8qoKlCeAJxUdXIlTXc96cTXl3HyXLgdbl1HJXcTSg9VmyHbgbnaH2OQNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHww1(ldwyGrqdqOns1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRr)ldwyGrqdqOns1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRA)LblmWiObi0JT6j0LIhYHCHJqBC(cW6zlGlTXc96cTX5laRNTaU0yiyPoCmwOLvT)YGfgye0ae6XK6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOL1O)LblmWiObi0Qp1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRr)ldwyGrqdqOlvQNqxkEihYfocTXl3HyXL2yHEDH24L7qS4sJHGL6WXyHwwJ(xgSWaJGgGqRMAQNqxkEihYfocTXl3HyXL2yHEDH24L7qS4sJHGL6WXyHwwJ(xgSWaJGgGqRMrQEcDP4HCix4i0gVChIfxAJf61fAJxUdXIlngcwQdhJfAzv7VmyHbgbnaHwTXw9e6sXd5qUWrOnE5oelU0gl0Rl0gVChIfxAmeSuhogl0YQ2FzWcdmcAacTAQp1tOlfpKd5chH24L7qS4sBSqVUqB8YDiwCPXqWsD4ySqlRA)LblmqyqPUXc1VJmMnsPw1tOf6rBaHMov8CfARNcTX3goHdICUgl0jmgF0eoc91NGqZV1N8chHM0WrlCXcdmcAacTAQNqxkEihYfocTXl3HyXL2yHEDH24L7qS4sJHGL6WXyHwwJ(xgSWaJGgGqBKQNqxkEihYfocTX5laRNTaU0gl0Rl0gNVaSE2c4sJHGL6WXyHww1(ldwyGrqdqOvZivpHUu8qoKlCeAJZxawpBbCPnwOxxOnoFby9SfWLgdbl1HJXcTSQ9xgSWaJGgGqR2yREcDP4HCix4i0gNVaSE2c4sBSqVUqBC(cW6zlGlngcwQdhJfAzv7VmyHbgbnaHwn1r9e6sXd5qUWrOnoFby9SfWL2yHEDH248fG1ZwaxAmeSuhogl0YQ2FzWcdmcAacTAJb1tOlfpKd5chH248fG1ZwaxAJf61fAJZxawpBbCPXqWsD4ySqlRA)LblmqyqPUXc1VJmMnsPw1tOf6rBaHMov8CfARNcTX8eDv4PXcDcJXhnHJqF9ji08B9jVWrOjnC0cxSWaJGgGqRM6j0LIhYHCHJqB8YDiwCPnwOxxOnE5oelU0yiyPoCmwOLvT)YGfgimymBQ45chHwTYfAMSupe6o9UxSWGQj)2gpRMM05RZl1Jsjz7wnvs3s7q1CSk0Q)MBbHESijCacdgRcT6VacmLGuOvZqH2OLB0YfgimySk0QFHPlheA5CszPoG5j6QWtHMgcTLL7Pq7wH(c7sJ2lMNORcpfAzjnaPeHUm)Lc9vbicTRSupUYGfgmwf6XCLdVWrOPXczWDHUHJtNgTcTBfA5CszPoGBy5aYvGaoc96cTei0Qj0fnqi0xyxA0EX8eDv4Pqpi0QHfgmwf6X8li0Bzkuc3fAt6Sue6gooDA0k0UvOjnCeqxOPXcz(uwQhcnnUlWhH2TcTXeoiqhXKL6HXyHbJvHw9)9cbbUcDctxoCeA(k0UvOhXLdtjifAJQ(e61f6eopci0LI6NgZfAzVDABZ2ltgSWaHbmzPECXkjq8PeVdY5KYsDWWGNWGsckVEhbYDdDLHeUWA4bS8RVdLlmGjl1JlwjbIpL497HVKZjLL6GHbpHbLeuE9ocK7g6kdxynuo3FWGAgsTdY5KYsDaRKGYR3rGCFOCv5laRNTa(svA8aDxpNQyYsLdiiGjfU)AuHbmzPECXkjq8PeVFp8LCoPSuhmm4jmOKGYR3rGC3qxz4cRHY5(dguZqQDqoNuwQdyLeuE9ocK7dLRkFby9SfWxQsJhO765ufXLdbhloas6DppQyYsLdiiGjfU)QMWaMSupUyLei(uI3Vh(soNuwQdgg8egAy5aYvGaog6kdxynuo3FWq5cdyYs94IvsG4tjE)E4l5CszPoyyWtyOHLdixbc4yORmCH1q5C)bdQzi1oiNtkl1bCdlhqUceWzOCvmzPYbeeWKc3FnQWaMSupUyLei(uI3Vh(soNuwQdgg8egAy5aYvGaog6kdxynuo3FWGAgsTdY5KYsDa3WYbKRabCgkxLCoPSuhWkjO86Dei3hutyatwQhxSsceFkX73dFjNtkl1bddEcdwAWDK0lddDLHlSgkN7pyOCHbmzPECXkjq8PeVFp8LCoPSuhmm4jmKx0K)JoqNldz9eT(on0vgs4cRHhWYV(oOocdyYs94IvsG4tjE)E4l5CszPoyyWtyiVOj)hDGoxgY6jkDfdDLHeUWA4bS8RVdQJWaMSupUyLei(uI3Vh(soNuwQdgg8egYlAY)rhOZLHSEIyfdDLHeUWA4bS8RVdgTCHbmzPECXkjq8PeVFp8LCoPSuhmm4jmWkOj)hDGoxgY6jA9DAORmKWfwdpGLF9DqTYfgWKL6XfRKaXNs8(9WxY5KYsDWWGNWq6kOj)hDGoxgY6jA9DAORmKWfwdpGLF9DWOLlmGjl1JlwjbIpL497HVKZjLL6GHbpHH13jAY)rhOZLHSEIyfdDLHeUWA4bS8RVdLlmGjl1JlwjbIpL497HVKZjLL6GHbpHH13jAY)rhOZLHSEIyfdDLHlSgkN7pyWinKAhKZjLL6aE9DIM8F0b6CziRNiwzOCv5laRNTa(qVeQsNgCwgI4ZjhhHbmzPECXkjq8PeVFp8LCoPSuhmm4jmS(ort(p6aDUmK1teRyORmCH1q5C)bdQPogsTdY5KYsDaV(ort(p6aDUmK1teRmuUkIlhcowCqBBwKLbHbmzPECXkjq8PeVFp8LCoPSuhmm4jmS(ort(p6aDUmK1teRyORmCH1q5C)bdQPogsTdY5KYsDaV(ort(p6aDUmK1teRmuUkIhNhDXCs4aqkPFOTLPIjlvoGGaMu4oUrkmGjl1JlwjbIpL497HVKZjLL6GHbpHH13jAY)rhOZLHSEIyfdDLHlSgkN7pyqDmKAhKZjLL6aE9DIM8F0b6CziRNiwzOCHbmzPECXkjq8PeVFp8LCoPSuhmm4jmS(ort(p6aDUmK1tu6kg6kdjCH1Wdy5xFhmA5cdyYs94IvsG4tjE)E4l5CszPoyyWtyqIZKBb0KdgPqwdDLHeUWA4bS8RVdLlmGjl1JlwjbIpL497HVKZjLL6GHbpHbjotUfqtoyKczn0vgUWAOCU)GbzhtLR(HSt(Uqwgso3FWyPALxUmYyi1oiNtkl1bSeNj3cOjhmsHSdLRI4YHGJfh02MfzzqyatwQhxSsceFkX73dFjNtkl1bddEcdsCMClGMCWifYAORmCH1q5C)bdYQ(kx9dzN8DHSmKCU)GXs1kVCzKXqQDqoNuwQdyjotUfqtoyKczhkxyatwQhxSsceFkX73dFjNtkl1bddEcdScAsd68nrtoyKczn0vgs4cRHhWYV(ouUWaMSupUyLei(uI3Vh(soNuwQdgg8egyf0Kg05BIMCWifYAORmCH1q5C)bdQt5gsTdY5KYsDaZkOjnOZ3en5GrkKDOCv5laRNTa(qVeQsNgCwgI4ZjhhHbmzPECXkjq8PeVFp8LCoPSuhmm4jmWkOjnOZ3en5GrkK1qxz4cRHY5(dguNYnKAhKZjLL6aMvqtAqNVjAYbJui7q5QYxawpBbCBsV9YqucL0bHbmzPECXkjq8PeVFp8LCoPSuhmm4jmWkOjnOZ3en5GrkK1qxz4cRHY5(dgutDmKAhKZjLL6aMvqtAqNVjAYbJui7q5cdyYs94IvsG4tjE)E4l5CszPoyyWtyy9DIM8FePHZw4AORmKWfwdpGLF9DWOcdyYs94IvsG4tjE)E4l5CszPoyyWtyGgYHCHdYvGasdDLHeUWA4bS8RVdLlmGjl1JlwjbIpL497HVKZjLL6GHbpHbAihYfoixbcin0vgUWAOCU)Gb1mKAhKZjLL6aMgYHCHdYvGaYHYvTChIfNVaqUfP4fqQs2L7qSyojCaiG04F(OUexoeCS4sklPCiJkzvxIlhcowCaK07EE(8HjlvoGGaMu4oO2Np5laRNTa(svA8aDxpNYimGjl1JlwjbIpL497HVKZjLL6GHbpHbAihYfoixbcin0vgUWAOCU)GHYnKAhKZjLL6aMgYHCHdYvGaYHYfgWKL6XfRKaXNs8(9WxY5KYsDWWGNWaRG8a9UGHUYWfwdLZ9hmaJXhvrbo4jtyPeq3gaw08DPKpFGX4JQOahCBNpuE98IK4tl85dmgFuff4GB78HYRNx0eoCVt94Zhym(OkkWbF4SKP7b6aKsqkVnHlbcc85dmgFuff4GPXLKVLL6aAm(4yFt0bKtjWNpWy8rvuGd(6VEh2LgTO8jv2NpWy8rvuGd((cPU7hepHTPS7(5dmgFuff4Gl4sGaYlYMEC(8bgJpQIcCW2opbKBrs8UDqyatwQhxSsceFkX73dFjNtkl1bddEcdSdO13jAY)rKgoBHRHUYqcxyn8aw(13bJkmGjl1JlwjbIpL497HVKZjLL6GHbpHHgwoGCfiGJHUYWfwdLZ9hmOMHu7GCoPSuhWnSCa5kqaNHYvDHDPr7fZt0vHNdQjmGjl1JlwjbIpL497HVKZjLL6GHbpHbqUJuiRHUYqcxyn8aw(13b1uhHbmzPECXkjq8PeVFp8LTZ3segWKL6XfRKaXNs8(9Wxw3pcdyYs94IvsG4tjE)E4l(1oHy5L6HWaMSupUyLei(uI3Vh(ItchaYYtANYPWaMSupUyLei(uI3Vh(ItchaIgl07azfgWKL6XfRKaXNs8(9Wxepu)5LaAYbJAHPWaMSupUyLei(uI3Vh(6gSYTXx0D59kmGjl1JlwjbIpL497HVM0m9erNClimGjl1JlwjbIpL497HVSPFxjVVgsTdQRCoPSuhWkjO86Dei3hutv(cW6zlGp0lHQ0PbNLHi(CYXryatwQhxSsceFkX73dFXjHdaj157Ai1oOUY5KYsDaRKGYR3rGCFqnvQB(cW6zlGp0lHQ0PbNLHi(CYXryatwQhxSsceFkX73dFbYDcVupmKAhKZjLL6awjbLxVJa5(GAcdegWKL6X97HVi(lwiVkqVBi1oSC2cl(aspRft47sJwCcmzfgWKL6X97HVKZjLL6GHbpHHgwoGCfiGJHUYWfwdLZ9hmOMHu7GCoPSuhWnSCa5kqaNHYvPKGCul5GvddYDcVupuPUYMVaSE2c4lvPXd0D9C(5t(cW6zlGxyQ4j3rfCQiJWaMSupUFp8LCoPSuhmm4jm0WYbKRabCm0vgUWAOCU)Gb1mKAhKZjLL6aUHLdixbc4muUkPN1I5KWbGu8ciXhViurCVF8IaZjHdaP4fqItyY04Qs28fG1ZwaFPknEGURNZpFYxawpBb8ctfp5oQGtfzegWKL6X97HVKZjLL6GHbpHbln4os6LHHUYWfwdLZ9hmOMHu7G0ZAXCs4aqKgoBb8DzsjdspRfZjHdarA4SfWt(p6UmPevQR0ZAX5Rdi3I2MeGl(POYsBBwuctMg3XhKv2jhS6NzYs9aZjHdaj157Ij(DLzSKjl1dmNeoaKuNVlg(dK3cOLobzegWKL6X97HViCVJyYs9a1P31WGNWWTHt4GiNRWaMSupUFp8fH7DetwQhOo9Ugg8egyhmKAhyYsLdiiGjfU)AuHbmzPEC)E4lc37iMSupqD6Dnm4jm4kqaPHu7GCoPSuhWnSCa5kqaNHYfgWKL6X97HViCVJyYs9a1P31WGNWaprxfEAi1oCHDPr7fZt0vHNdQjmGjl1J73dFr4EhXKL6bQtVRHbpHbI79JxexHbmzPEC)E4lc37iMSupqD6Dnm4jmK(Yl1ddP2b5CszPoGT0G7iPxgdLlmGjl1J73dFr4EhXKL6bQtVRHbpHbln4os6LHHu7GCoPSuhWwAWDK0lJb1egWKL6X97HViCVJyYs9a1P31WGNWW0LdtiwHbcdgRcntwQhxmprxfEoq4GaDetwQhgsTdmzPEGb5oHxQhysdhb0PrRQjhmwHS)ouQuhHbmzPECX8eDv453dFbYDcVupmKAhMCWyfYo(GCoPSuhWGChPqwvYsCVF8IaV(J0GClABa0KBP4eMmnUJpWKL6bgK7eEPEGH)a5TaAPt4ZhI79JxeyojCaifVasCctMg3XhyYs9adYDcVupWWFG8waT0j85JSl3HyX5laKBrkEbKQiU3pErGZxai3Iu8ciXjmzAChFGjl1dmi3j8s9ad)bYBb0sNGmYOs6zT48faYTifVas8XlcvspRfZjHdaP4fqIpErO6aspRfV(J0GClABa0KBP4JxecdyYs94I5j6QWZVh(6a82i5zagsTde37hViWCs4aqkEbK4eMmnUdLRswPN1IZxai3Iu8ciXhViujlX9(Xlc86psdYTOTbqtULItyY04(RCoPSuhWScAY)rhOZLHSEIwFNF(qCVF8IaV(J0GClABa0KBP4eMmnUdLlJmcdyYs94I5j6QWZVh(AsZ0ZlYTO1ZjeRHu7aX9(XlcmNeoaKIxajoHjtJ7q5QKv6zT48faYTifVas8XlcvYsCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bmRGM8F0b6CziRNO135Npe37hViWR)ini3I2gan5wkoHjtJ7q5YiJWaMSupUyEIUk887HVs(q5yrxfolryatwQhxmprxfE(9Wx3gQDPrlsXlG0qQDq6zTyojCaifVas8Xlcve37hViWCs4aqkEbK4nFakHjtJ7VmzPEGVnu7sJwKIxajMCsvspRfNVaqUfP4fqIpErOI4E)4fboFbGClsXlGeV5dqjmzAC)Ljl1d8THAxA0Iu8ciXKtQ6aspRfV(J0GClABa0KBP4JxecdyYs94I5j6QWZVh(kFbGClsXlG0qQDq6zT48faYTifVas8Xlcve37hViWCs4aqkEbK4eMmnUcdyYs94I5j6QWZVh(A9hPb5w02aOj3snKAhKL4E)4fbMtchasXlGeNWKPXDOCvspRfNVaqUfP4fqIpEriZNpkjih1soy1W5laKBrkEbKcdyYs94I5j6QWZVh(A9hPb5w02aOj3snKAhiU3pErG5KWbGu8ciXjmzAChxDkxL0ZAX5laKBrkEbK4JxeQG7fccGLtVupqUfPaPfil1dmeSuhocdyYs94I5j6QWZVh(ItchasXlG0qQDq6zT48faYTifVas8Xlcve37hViWR)ini3I2gan5wkoHjtJ7VY5KYsDaZkOj)hDGoxgY6jA9DkmGjl1JlMNORcp)E4lojCaijotUfmKAhKEwlMtchasXlGe)uuj9SwmNeoaKIxajoHjtJ74dmzPEG5KWbGM07L2Hlg(dK3cOLobvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsegWKL6XfZt0vHNFp8fNeoaKNsgsTdspRfZjHdarA4SfW3LjLmU0ZAXCs4aqKgoBb8K)JUltkrL0ZAX5laKBrkEbK4JxeQKEwlMtchasXlGeF8Iq1bKEwlE9hPb5w02aOj3sXhViegWKL6XfZt0vHNFp8fNeoaKeNj3cgsTdspRfNVaqUfP4fqIpErOs6zTyojCaifVas8Xlcvhq6zT41FKgKBrBdGMClfF8IqL0ZAXCs4aqKgoBb8DzsjdspRfZjHdarA4SfWt(p6UmPeHbmzPECX8eDv453dFXjHdanP3lTdxdP2bPN1IjDGtcFxA0ItGjRHKgMgdQziWzVmePHPbIAhKEwlM0boj8DPrlI0WraD8XlcvYk9SwmNeoaKIxaj(P85J0ZAX5laKBrkEbK4NYNpe37hViWGCNWl1dCc8PmzegWKL6XfZt0vHNFp8fNeoa0KEV0oCnKAhuxUudK0fWCs4aqkV5e60Ofdbl1HZNpspRft6aNe(U0OfrA4iGo(4fHHKgMgdQziWzVmePHPbIAhKEwlM0boj8DPrlI0WraD8XlcvYk9SwmNeoaKIxaj(P85J0ZAX5laKBrkEbK4NYNpe37hViWGCNWl1dCc8PmzegWKL6XfZt0vHNFp8fi3j8s9WqQDq6zT48faYTifVas8XlcvspRfZjHdaP4fqIpErO6aspRfV(J0GClABa0KBP4JxecdyYs94I5j6QWZVh(ItchaYtjdP2bPN1I5KWbGinC2c47YKsgx6zTyojCaisdNTaEY)r3LjLimGjl1JlMNORcp)E4lojCaijotUfegWKL6XfZt0vHNFp8fNeoaKuNVRWaHbmzPECXSdd20VRK3xdP2H8fG1ZwaFOxcvPtdoldr85KJJkI79JxeyPN1Io0lHQ0PbNLHi(CYXbNaFktL0ZAXh6Lqv60GZYqeFo54GSPFx8XlcvYk9SwmNeoaKIxaj(4fHkPN1IZxai3Iu8ciXhViuDaPN1Ix)rAqUfTnaAYTu8XlczurCVF8IaV(J0GClABa0KBP4eMmnUdLRswPN1I5KWbGinC2c47YKsgFqoNuwQdy2b067en5)isdNTWvLSYUChIfNVaqUfP4fqQI4E)4fboFbGClsXlGeNWKPXD8HwYrfX9(XlcmNeoaKIxajoHjtJ7VY5KYsDaV(ort(p6aDUmK1teRiZNpYQUl3HyX5laKBrkEbKQiU3pErG5KWbGu8ciXjmzAC)voNuwQd413jAY)rhOZLHSEIyfz(8H4E)4fbMtchasXlGeNWKPXD8HwYrgzegWKL6XfZo89WxwAciPoFxdP2bzZxawpBb8HEjuLon4SmeXNtooQiU3pErGLEwl6qVeQsNgCwgI4ZjhhCc8PmvspRfFOxcvPtdoldr85KJdYstaF8IqLscYrTKdwnSn97k59vMpFKnFby9SfWh6Lqv60GZYqeFo54OAPtyOCzegWKL6XfZo89Wx20VlkC5SHu7q(cW6zlGBt6TxgIsOKoOI4E)4fbMtchasXlGeNWKPX9xJSCve37hViWR)ini3I2gan5wkoHjtJ7q5QKv6zTyojCaisdNTa(UmPKXhKZjLL6aMDaT(ort(pI0WzlCvjRSl3HyX5laKBrkEbKQiU3pErGZxai3Iu8ciXjmzAChFOLCurCVF8IaZjHdaP4fqItyY04(RCoPSuhWRVt0K)JoqNldz9eXkY85JSQ7YDiwC(ca5wKIxaPkI79JxeyojCaifVasCctMg3FLZjLL6aE9DIM8F0b6CziRNiwrMpFiU3pErG5KWbGu8ciXjmzAChFOLCKrgHbmzPECXSdFp8Ln97IcxoBi1oKVaSE2c42KE7LHOekPdQiU3pErG5KWbGu8ciXjmzAChkxLSYklX9(Xlc86psdYTOTbqtULItyY04(RCoPSuhWScAY)rhOZLHSEIwFNQKEwlMtchaI0WzlGVltkzq6zTyojCaisdNTaEY)r3LjLiZNpYsCVF8IaV(J0GClABa0KBP4eMmnUdLRs6zTyojCaisdNTa(UmPKXhKZjLL6aMDaT(ort(pI0WzlCLrgvspRfNVaqUfP4fqIpEriJWaMSupUy2HVh(A9hPb5w02aOj3snKAhYxawpBb8LQ04b6UEovPKGCul5GvddYDcVupegWKL6XfZo89WxCs4aqkEbKgsTd5laRNTa(svA8aDxpNQKvjb5OwYbRggK7eEPE85JscYrTKdwn86psdYTOTbqtULkJWaMSupUy2HVh(cK7eEPEyi1oS0j8RrwUQ8fG1ZwaFPknEGURNtvspRfZjHdarA4SfW3LjLm(GCoPSuhWSdO13jAY)rKgoBHRkI79Jxe41FKgKBrBdGMClfNWKPXDOCve37hViWCs4aqkEbK4eMmnUJp0socdyYs94Izh(E4lqUt4L6HHu7WsNWVgz5QYxawpBb8LQ04b6UEovrCVF8IaZjHdaP4fqItyY04ouUkzLvwI79Jxe41FKgKBrBdGMClfNWKPX9x5CszPoGzf0K)JoqNldz9eT(ovj9SwmNeoaePHZwaFxMuYG0ZAXCs4aqKgoBb8K)JUltkrMpFKL4E)4fbE9hPb5w02aOj3sXjmzAChkxL0ZAXCs4aqKgoBb8DzsjJpiNtkl1bm7aA9DIM8FePHZw4kJmQKEwloFbGClsXlGeF8IqgdPXcz(uwe1oi9Sw8LQ04b6UEoX3LjLmi9Sw8LQ04b6UEoXt(p6UmPedPXcz(uweDoHdLxyqnHbmzPECXSdFp81KMPNxKBrRNtiwdP2bzjU3pErG5KWbGu8ciXjmzAC)DSvNpFiU3pErG5KWbGu8ciXjmzAChFWiLrfX9(Xlc86psdYTOTbqtULItyY04ouUkzLEwlMtchaI0WzlGVltkz8b5CszPoGzhqRVt0K)JinC2cxvYk7YDiwC(ca5wKIxaPkI79Jxe48faYTifVasCctMg3XhAjhve37hViWCs4aqkEbK4eMmnU)QoY85JSQ7YDiwC(ca5wKIxaPkI79JxeyojCaifVasCctMg3Fvhz(8H4E)4fbMtchasXlGeNWKPXD8HwYrgzegWKL6XfZo89WxjFOCSORcNLyi1oqCVF8IaV(J0GClABa0KBP4eMmnUJd)bYBb0sNGkzLEwlMtchaI0WzlGVltkz8b5CszPoGzhqRVt0K)JinC2cxvYk7YDiwC(ca5wKIxaPkI79Jxe48faYTifVasCctMg3XhAjhve37hViWCs4aqkEbK4eMmnU)kNtkl1b867en5)Od05YqwprSImF(iR6UChIfNVaqUfP4fqQI4E)4fbMtchasXlGeNWKPX9x5CszPoGxFNOj)hDGoxgY6jIvK5ZhI79JxeyojCaifVasCctMg3XhAjhzKryatwQhxm7W3dFL8HYXIUkCwIHu7aX9(XlcmNeoaKIxajoHjtJ74WFG8waT0jOswzLL4E)4fbE9hPb5w02aOj3sXjmzAC)voNuwQdywbn5)Od05YqwprRVtvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsK5ZhzjU3pErGx)rAqUfTnaAYTuCctMg3HYvj9SwmNeoaePHZwaFxMuY4dY5KYsDaZoGwFNOj)hrA4SfUYiJkPN1IZxai3Iu8ciXhViKryatwQhxm7W3dFDaEBK8madP2bI79JxeyojCaifVasCctMg3HYvjRSYsCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bmRGM8F0b6CziRNO13PkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjY85JSe37hViWR)ini3I2gan5wkoHjtJ7q5QKEwlMtchaI0WzlGVltkz8b5CszPoGzhqRVt0K)JinC2cxzKrL0ZAX5laKBrkEbK4JxeYimGjl1JlMD47HVw)rAqUfTnaAYTudP2bPN1I5KWbGinC2c47YKsgFqoNuwQdy2b067en5)isdNTWvLSYUChIfNVaqUfP4fqQI4E)4fboFbGClsXlGeNWKPXD8HwYrfX9(XlcmNeoaKIxajoHjtJ7VY5KYsDaV(ort(p6aDUmK1teRiZNpYQUl3HyX5laKBrkEbKQiU3pErG5KWbGu8ciXjmzAC)voNuwQd413jAY)rhOZLHSEIyfz(8H4E)4fbMtchasXlGeNWKPXD8HwYrgHbmzPECXSdFp8fNeoaKIxaPHu7GSYsCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bmRGM8F0b6CziRNO13PkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjY85JSe37hViWR)ini3I2gan5wkoHjtJ7q5QKEwlMtchaI0WzlGVltkz8b5CszPoGzhqRVt0K)JinC2cxzKrL0ZAX5laKBrkEbK4JxecdyYs94Izh(E4R8faYTifVasdP2bPN1IZxai3Iu8ciXhViujRSe37hViWR)ini3I2gan5wkoHjtJ7VgTCvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsK5ZhzjU3pErGx)rAqUfTnaAYTuCctMg3HYvj9SwmNeoaePHZwaFxMuY4dY5KYsDaZoGwFNOj)hrA4SfUYiJkzjU3pErG5KWbGu8ciXjmzAC)vnJ(5ZbKEwlE9hPb5w02aOj3sXpfzegWKL6XfZo89Wx3gQDPrlsXlG0qQDq6zTyojCaifVas8Xlcve37hViWCs4aqkEbK4nFakHjtJ7VmzPEGVnu7sJwKIxajMCsvspRfNVaqUfP4fqIpErOI4E)4fboFbGClsXlGeV5dqjmzAC)Ljl1d8THAxA0Iu8ciXKtQ6aspRfV(J0GClABa0KBP4JxecdyYs94Izh(E4lLeUqqaKBrtACmKAhKEwl(a82i5za4NIQdi9Sw86psdYTOTbqtULIFkQoG0ZAXR)ini3I2gan5wkoHjtJ74dspRfRKWfccGClAsJdEY)r3LjLmwYKL6bMtchasQZ3fd)bYBb0sNGWaMSupUy2HVh(ItchasQZ31qQDq6zT4dWBJKNbGFkQKv2L7qS4eUEWbbuXKLkhqqatkChFSL5ZhMSu5accysH74QJmQKvDZxawpBbmNeoaKKpL48mHy)8z5SfwCdW9TbRq2Fns1rgHbmzPECXSdFp819Paz4YzHbmzPECXSdFp8fNeoaKNsgsTdspRfZjHdarA4SfW3LjLmuUWaMSupUy2HVh(kGTbs0ctf4UgsTdYMGnHBdl1HpFu3LskHgTYOs6zTyojCaisdNTa(UmPKbPN1I5KWbGinC2c4j)hDxMuIWaMSupUy2HVh(ItchaAsVxAhUgsTdspRft6aNe(U0OfNatwv5laRNTaMtchaIgwAq3YuTChIfZtLo1sj8s9qftwQCabbmPWDC1NWaMSupUy2HVh(ItchaAsVxAhUgsTdspRft6aNe(U0OfNatwvYMVaSE2cyojCaiAyPbDl7ZNL7qSyEQ0PwkHxQhYOIjlvoGGaMu4oU6imGjl1JlMD47HV4KWbGG)kD)s9WqQDq6zTyojCaisdNTa(UmPKXLEwlMtchaI0WzlGN8F0DzsjcdyYs94Izh(E4lojCai4Vs3VupmKAhKEwlMtchaI0WzlGVltkzq6zTyojCaisdNTaEY)r3LjLOsjb5OwYbRgMtchasIZKBbHbmzPECXSdFp8fNeoaKeNj3cgsTdspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsegWKL6XfZo89WxGCNWl1ddPXcz(uwe1om5GXkK93b1N6yinwiZNYIOZjCO8cdQjmqyWyvOv)us9KU0snGq)U0OvOBt6TxMqtjushe6c62i0ScwOhZVGqtxHUGUnc967uO9TbYc6fWcdyYs94IjU3pErChSPFxu4YzdP2H8fG1Zwa3M0BVmeLqjDqfX9(XlcmNeoaKIxajoHjtJ7Vgz5QiU3pErGx)rAqUfTnaAYTuCctMg3HYvjR0ZAXCs4aqKgoBb8DzsjJpiNtkl1b867en5)isdNTWvLSYUChIfNVaqUfP4fqQI4E)4fboFbGClsXlGeNWKPXD8HwYrfX9(XlcmNeoaKIxajoHjtJ7VY5KYsDaV(ort(p6aDUmK1teRiZNpYQUl3HyX5laKBrkEbKQiU3pErG5KWbGu8ciXjmzAC)voNuwQd413jAY)rhOZLHSEIyfz(8H4E)4fbMtchasXlGeNWKPXD8HwYrgzegWKL6XftCVF8I4(9Wx20VlkC5SHu7q(cW6zlGBt6TxgIsOKoOI4E)4fbMtchasXlGeNWKPXDOCvYQUl3HyXq0PTnleW5ZhzxUdXIHOtBBwiGJQjhmwHS)omgkxgzujRSe37hViWR)ini3I2gan5wkoHjtJ7VQvUkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjY85JSe37hViWR)ini3I2gan5wkoHjtJ7q5QKEwlMtchaI0WzlGVltkzOCzKrL0ZAX5laKBrkEbK4JxeQMCWyfY(7GCoPSuhWScAsd68nrtoyKczfgWKL6XftCVF8I4(9Wx20VRK3xdP2H8fG1ZwaFOxcvPtdoldr85KJJkI79JxeyPN1Io0lHQ0PbNLHi(CYXbNaFktL0ZAXh6Lqv60GZYqeFo54GSPFx8XlcvYk9SwmNeoaKIxaj(4fHkPN1IZxai3Iu8ciXhViuDaPN1Ix)rAqUfTnaAYTu8XlczurCVF8IaV(J0GClABa0KBP4eMmnUdLRswPN1I5KWbGinC2c47YKsgFqoNuwQd413jAY)rKgoBHRkzLD5oeloFbGClsXlGufX9(XlcC(ca5wKIxajoHjtJ74dTKJkI79JxeyojCaifVasCctMg3FLZjLL6aE9DIM8F0b6CziRNiwrMpFKvDxUdXIZxai3Iu8civrCVF8IaZjHdaP4fqItyY04(RCoPSuhWRVt0K)JoqNldz9eXkY85dX9(XlcmNeoaKIxajoHjtJ74dTKJmYimGjl1JlM4E)4fX97HVS0eqsD(UgsTd5laRNTa(qVeQsNgCwgI4Zjhhve37hViWspRfDOxcvPtdoldr85KJdob(uMkPN1Ip0lHQ0PbNLHi(CYXbzPjGpErOsjb5OwYbRg2M(DL8(kmySk0Jf9cUSRq)UGqpPz65vOlOBJqZkyHEmZk0RVtHMEf6e4tzcnFf6cO3nuONCjGqFFji0Rl0e(UcnDfAjW6ji0RVtSWaMSupUyI79Jxe3Vh(AsZ0ZlYTO1ZjeRHu7aX9(Xlc86psdYTOTbqtULItyY04ouUkPN1I5KWbGinC2c47YKsgFqoNuwQd413jAY)rKgoBHRkI79JxeyojCaifVasCctMg3XhAjhHbmzPECXe37hViUFp81KMPNxKBrRNtiwdP2bI79JxeyojCaifVasCctMg3HYvjR6UChIfdrN22SqaNpFKD5oelgIoTTzHaoQMCWyfY(7WyOCzKrLSYsCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bmRGM8F0b6CziRNO13PkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjY85JSe37hViWR)ini3I2gan5wkoHjtJ7q5QKEwlMtchaI0WzlGVltkzOCzKrL0ZAX5laKBrkEbK4JxeQMCWyfY(7GCoPSuhWScAsd68nrtoyKczfgmwf6XIEbx2vOFxqOpaVnsEgGqxq3gHMvWc9yMvOxFNcn9k0jWNYeA(k0fqVBOqp5saH((sqOxxOj8DfA6k0sG1tqOxFNyHbmzPECXe37hViUFp81b4TrYZamKAhiU3pErGx)rAqUfTnaAYTuCctMg3HYvj9SwmNeoaePHZwaFxMuY4dY5KYsDaV(ort(pI0WzlCvrCVF8IaZjHdaP4fqItyY04o(ql5imGjl1JlM4E)4fX97HVoaVnsEgGHu7aX9(XlcmNeoaKIxajoHjtJ7q5QKvDxUdXIHOtBBwiGZNpYUChIfdrN22SqahvtoyScz)DymuUmYOswzjU3pErGx)rAqUfTnaAYTuCctMg3FvRCvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsK5ZhzjU3pErGx)rAqUfTnaAYTuCctMg3HYvj9SwmNeoaePHZwaFxMuYq5YiJkPN1IZxai3Iu8ciXhViun5GXkK93b5CszPoGzf0Kg05BIMCWifYkmySk0J5xqOVkCwIqtTc967uO54i0SIqZji0Ei0KJqZXrOl8W4vOLaH(Pi0wpf6UhTqk0Bdhc92ac9K)l0hOZLzOqp5sOrRqFFji0fGq3WYbHMxHUd8Df6TWfAojCacnPHZw4k0CCe6THxHE9Dk0f8nmEfA1FE3vOFx4GfgWKL6XftCVF8I4(9WxjFOCSORcNLyi1oqCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bCErt(p6aDUmK1t067ufX9(XlcmNeoaKIxajoHjtJ7VY5KYsDaNx0K)JoqNldz9eXkQKD5oeloFbGClsXlGuLSe37hViW5laKBrkEbK4eMmnUJd)bYBb0sNWNpe37hViW5laKBrkEbK4eMmnU)kNtkl1bCErt(p6aDUmK1tu6kY85J6UChIfNVaqUfP4fqkJkPN1I5KWbGinC2c47YKs(1OQoG0ZAXR)ini3I2gan5wk(4fHkPN1IZxai3Iu8ciXhViuj9SwmNeoaKIxaj(4fHWGXQqpMFbH(QWzjcDbDBeAwrOlAGqOv87Lk1bSqpMzf613PqtVcDc8PmHMVcDb07gk0tUeqOVVee61fAcFxHMUcTey9ee613jwyatwQhxmX9(XlI73dFL8HYXIUkCwIHu7aX9(Xlc86psdYTOTbqtULItyY04oo8hiVfqlDcQKEwlMtchaI0WzlGVltkz8b5CszPoGxFNOj)hrA4SfUQiU3pErG5KWbGu8ciXjmzAChxw4pqElGw6e(Mjl1d86psdYTOTbqtULIH)a5TaAPtqgHbmzPECXe37hViUFp8vYhkhl6QWzjgsTde37hViWCs4aqkEbK4eMmnUJd)bYBb0sNGkzLvDxUdXIHOtBBwiGZNpYUChIfdrN22SqahvtoyScz)DymuUmYOswzjU3pErGx)rAqUfTnaAYTuCctMg3FLZjLL6aMvqt(p6aDUmK1t067uL0ZAXCs4aqKgoBb8DzsjdspRfZjHdarA4SfWt(p6UmPez(8rwI79Jxe41FKgKBrBdGMClfNWKPXDOCvspRfZjHdarA4SfW3LjLmuUmYOs6zT48faYTifVas8XlcvtoyScz)DqoNuwQdywbnPbD(MOjhmsHSYimySk0J5xqOxFNcDbDBeAwrOPwHMUgFf6c62qdHEBaHEY)f6d05YWc9yMvOdFnuOFxqOlOBJqNUIqtTc92ac9YDiwHMEf6LlbcdfAoocnDn(k0f0THgc92ac9K)l0hOZLHfgWKL6XftCVF8I4(9WxR)ini3I2gan5wQHu7G0ZAXCs4aqKgoBb8DzsjJpiNtkl1b867en5)isdNTWvfX9(XlcmNeoaKIxajoHjtJ74dWFG8waT0jimGjl1JlM4E)4fX97HVw)rAqUfTnaAYTudP2bPN1I5KWbGinC2c47YKsgFqoNuwQd413jAY)rKgoBHRQL7qS48faYTifVasve37hViW5laKBrkEbK4eMmnUJpa)bYBb0sNGkI79JxeyojCaifVasCctMg3FLZjLL6aE9DIM8F0b6CziRNiwryatwQhxmX9(XlI73dFT(J0GClABa0KBPgsTdspRfZjHdarA4SfW3LjLm(GCoPSuhWRVt0K)JinC2cxvYQUl3HyX5laKBrkEbKF(qCVF8IaNVaqUfP4fqItyY04(RCoPSuhWRVt0K)JoqNldz9eLUImQiU3pErG5KWbGu8ciXjmzAC)voNuwQd413jAY)rhOZLHSEIyfHbJvHEm)ccnRi0uRqV(ofA6vO9qOjhHMJJqx4HXRqlbc9trOTEk0DpAHuO3goe6Tbe6j)xOpqNlZqHEYLqJwH((sqO3gEf6cqOBy5GqdH)ABe6jhSqZXrO3gEf6TbsqOPxHo8vO5Ec8PmHMf68fGq7wHwXlGuOpErGfgWKL6XftCVF8I4(9WxCs4aqkEbKgsTde37hViWR)ini3I2gan5wkoHjtJ7VY5KYsDaZkOj)hDGoxgY6jA9DQs6zTyojCaisdNTa(UmPKbPN1I5KWbGinC2c4j)hDxMuIkPN1IZxai3Iu8ciXhViun5GXkK93b5CszPoGzf0Kg05BIMCWifYkmySk0J5xqOtxrOPwHE9Dk00Rq7HqtocnhhHUWdJxHwce6NIqB9uO7E0cPqVnCi0Bdi0t(VqFGoxMHc9KlHgTc99LGqVnqccn9ggVcn3tGpLj0SqNVae6JxecnhhHEB4vOzfHUWdJxHwci(eeAwot7Suhe6ZlPrRqNVaWcdyYs94IjU3pErC)E4R8faYTifVasdP2bPN1I5KWbGu8ciXhViurCVF8IaV(J0GClABa0KBP4eMmnU)kNtkl1bC6kOj)hDGoxgY6jA9DQs6zTyojCaisdNTa(UmPKbPN1I5KWbGinC2c4j)hDxMuIkzjU3pErG5KWbGu8ciXjmzAC)vnJ(5ZbKEwlE9hPb5w02aOj3sXpfzegWKL6XftCVF8I4(9Wx3gQDPrlsXlG0qQDq6zTyojCaifVas8Xlcve37hViWCs4aqkEbK4nFakHjtJ7VmzPEGVnu7sJwKIxajMCsvspRfNVaqUfP4fqIpErOI4E)4fboFbGClsXlGeV5dqjmzAC)Ljl1d8THAxA0Iu8ciXKtQ6aspRfV(J0GClABa0KBP4JxecdgRc9y(feAfFk0Rl03X4dGsnGqZHqd)3KfAwsOPHqVnGqhW)vOjU3pEri0f044fgk0VOd3RqxszjLdHEBGqO9OxMqFEjnAfAojCacTIxaPqFEGqVUq34fc9KdwOBErBwMqN8HYXk0xfolrOPxHbmzPECXe37hViUFp8LscxiiaYTOjnogsTdl3HyX5laKBrkEbKQKEwlMtchasXlGe)uuj9SwC(ca5wKIxajoHjtJ74TKdEY)fgWKL6XftCVF8I4(9WxkjCHGai3IM04yi1oCaPN1Ix)rAqUfTnaAYTu8tr1bKEwlE9hPb5w02aOj3sXjmzAChNjl1dmNeoa0KEV0oCXWFG8waT0jOsDjUCi4yXLuws5qyatwQhxmX9(XlI73dFPKWfccGClAsJJHu7G0ZAX5laKBrkEbK4NIkPN1IZxai3Iu8ciXjmzAChVLCWt(VkI79JxeyqUt4L6bob(uMk1L4YHGJfxszjLdHbcdyYs94IT0G7iPxgFp8fNeoa0KEV0oCnKAhKEwlM0boj8DPrlobMSgsAyAmOMWaMSupUyln4os6LX3dFXjHdaj157kmGjl1Jl2sdUJKEz89WxCs4aqsCMClimqyatwQhx80Ldti2Vh(sQtJsqCuMHu7W0Ldtiw8HExoiWVdQvUWaMSupU4PlhMqSFp8LscxiiaYTOjnocdyYs94INUCycX(9WxCs4aqt69s7W1qQDy6YHjel(qVlheyC1kxyatwQhx80Ldti2Vh(ItchaYtjHbmzPECXtxomHy)E4llnbKuNVRWaHbmzPECXUceqoaYDcVupmKAhKnFby9SfWxQsJhO7658ZN8fG1ZwaVWuXtUJk4urgvl3HyX5laKBrkEbKQiU3pErGZxai3Iu8ciXjmzACvjR0ZAX5laKBrkEbK4JxeF(OKGCul5GvdZjHdajXzYTGmcdyYs94IDfiG87HVS0eqsD(UgsTd5laRNTa(qVeQsNgCwgI4ZjhhvspRfFOxcvPtdoldr85KJdYM(DXpfHbmzPECXUceq(9Wx20VlkC5SHu7q(cW6zlGBt6TxgIsOKoOAYbJvi7VLk1ryatwQhxSRabKFp81b4TrYZamKAhu38fG1ZwaFPknEGURNtHbmzPECXUceq(9WxjFOCSORcNLyi1om5GXkK93XUCHbmzPECXUceq(9Wx3gQDPrlsXlG0qQDq6zTyojCaifVas8Xlcve37hViWCs4aqkEbK4eMmnUQux5CszPoGPHCix4GCfiGCqnHbmzPECXUceq(9WxCs4aqEkzi1oiNtkl1bmnKd5chKRabKdQPI4E)4fboFbGClsXlGeNWKPXDOCHbmzPECXUceq(9WxCs4aqsD(UgsTdY5KYsDatd5qUWb5kqa5GAQiU3pErGZxai3Iu8ciXjmzAChkxL0ZAXCs4aqKgoBb8DzsjJl9SwmNeoaePHZwap5)O7YKsegWKL6Xf7kqa53dFLVaqUfP4fqAi1oiNtkl1bmnKd5chKRabKdQPs6zT48faYTifVas8XlcHbmzPECXUceq(9Wxk(s9WqQDqoNuwQdyAihYfoixbcihutL6kB(cW6zlGVuLgpq31Z5Np5laRNTaEHPINChvWPImcdyYs94IDfiG87HVoaVnsEgGHu7G0ZAX5laKBrkEbK4JxecdyYs94IDfiG87HVM0m98IClA9CcXAi1oi9SwC(ca5wKIxaj(4fXNpkjih1soy1WCs4aqsCMClimGjl1Jl2vGaYVh(A9hPb5w02aOj3snKAhKEwloFbGClsXlGeF8I4ZhLeKJAjhSAyojCaijotUfegWKL6Xf7kqa53dFXjHdaP4fqAi1oOKGCul5GvdV(J0GClABa0KBPcdyYs94IDfiG87HVYxai3Iu8cinKAhKEwloFbGClsXlGeF8IqyatwQhxSRabKFp8LscxiiaYTOjnogsTdhq6zT41FKgKBrBdGMClf)uuDaPN1Ix)rAqUfTnaAYTuCctMg3XzYs9aZjHdanP3lTdxm8hiVfqlDccdyYs94IDfiG87HVus4cbbqUfnPXXqQDy5oeloFbGClsXlGuL0ZAXCs4aqkEbK4NIkPN1IZxai3Iu8ciXjmzAChVLCWt(VWaMSupUyxbci)E4lojCaiPoFxdP2HJV4Kpuow0vHZsWjmzAC)vD(85aspRfN8HYXIUkCwcs(RhqYs0oDldFxMuYVLlmGjl1Jl2vGaYVh(ItchasQZ31qQDq6zTyLeUqqaKBrtACWpfvhq6zT41FKgKBrBdGMClf)uuDaPN1Ix)rAqUfTnaAYTuCctMg3XhyYs9aZjHdaj157IH)a5TaAPtqyatwQhxSRabKFp8fNeoaKeNj3cgsTdspRfNVaqUfP4fqIFkQiU3pErG5KWbGu8ciXjWNYun5GXkKD8XUCvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsuPU5laRNTa(svA8aDxpNQu38fG1ZwaVWuXtUJk4uryatwQhxSRabKFp8fNeoaKeNj3cgsTdspRfNVaqUfP4fqIFkQKEwlMtchasXlGeF8IqL0ZAX5laKBrkEbK4eMmnUJp0soQKEwlMtchaI0WzlGVltkzq6zTyojCaisdNTaEY)r3LjLOsoNuwQdyAihYfoixbcifgWKL6Xf7kqa53dFXjHdanP3lTdxdP2Hdi9Sw86psdYTOTbqtULIFkQwUdXI5KWbGasJRswPN1IpaVnsEga(4fXNpmzPYbeeWKc3b1Kr1bKEwlE9hPb5w02aOj3sXjmzAC)Ljl1dmNeoa0KEV0oCXWFG8waT0jOsw1Ll1ajDbmNeoaKYBoHonAXqWsD485J0ZAXKoWjHVlnArKgocOJpEriJHKgMgdQziWzVmePHPbIAhKEwlM0boj8DPrlI0WraD8XlcvYk9SwmNeoaKIxaj(P85JSQ7YDiwSlhsfVas4OswPN1IZxai3Iu8ciXpLpFiU3pErGb5oHxQh4e4tzYiJmcdyYs94IDfiG87HV4KWbGM07L2HRHu7G0ZAXKoWjHVlnAXjWKvfX9(XlcmNeoaKIxajoHjtJRkzLEwloFbGClsXlGe)u(8r6zTyojCaifVas8trgdjnmngutyatwQhxSRabKFp8fNeoaKNsgsTdspRfZjHdarA4SfW3LjLm(GCoPSuhWRVt0K)JinC2cxvYsCVF8IaZjHdaP4fqItyY04(RAL)5dtwQCabbmPWD8bJkJWaMSupUyxbci)E4lojCaiPoFxdP2bPN1IZxai3Iu8ciXpLpFMCWyfY(RAQJWaMSupUyxbci)E4lqUt4L6HHu7G0ZAX5laKBrkEbK4JxeQKEwlMtchasXlGeF8IWqASqMpLfrTdtoyScz)Dq9PogsJfY8PSi6CchkVWGAcdyYs94IDfiG87HV4KWbGK4m5wqyGWGXQqZKL6XfN(Yl1JVh(IWbb6iMSupmKAhyYs9adYDcVupWKgocOtJwvtoyScz)DOuPoQKvDZxawpBb8LQ04b6UEo)8r6zT4lvPXd0D9CIVltkzq6zT4lvPXd0D9CIN8F0DzsjYimGjl1Jlo9LxQhFp8fi3j8s9WqQDyYbJvi74dY5KYsDadYDKczvjlX9(Xlc86psdYTOTbqtULItyY04o(atwQhyqUt4L6bg(dK3cOLoHpFiU3pErG5KWbGu8ciXjmzAChFGjl1dmi3j8s9ad)bYBb0sNWNpYUChIfNVaqUfP4fqQI4E)4fboFbGClsXlGeNWKPXD8bMSupWGCNWl1dm8hiVfqlDcYiJkPN1IZxai3Iu8ciXhViuj9SwmNeoaKIxaj(4fHQdi9Sw86psdYTOTbqtULIpEryinwiZNYIO2HjhmwHS)ouQuhvYQU5laRNTa(svA8aDxpNF(i9Sw8LQ04b6UEoX3LjLmi9Sw8LQ04b6UEoXt(p6UmPezmKglK5tzr05eouEHb1egWKL6XfN(Yl1JVh(cK7eEPEyi1oKVaSE2c4lvPXd0D9CQI4E)4fbMtchasXlGeNWKPXD8bMSupWGCNWl1dm8hiVfqlDccdgRc9pCMCli0uRqtxJVc9sNGqVUq)UGqV(ofAoocDbi0nSCqOx3f6jhLj0KgoBHRWaMSupU40xEPE89WxCs4aqsCMClyi1oqCVF8IaV(J0GClABa0KBP4e4tzQKv6zTyojCaisdNTa(UmPKFLZjLL6aE9DIM8FePHZw4QI4E)4fbMtchasXlGeNWKPXD8b4pqElGw6eKryatwQhxC6lVup(E4lojCaijotUfmKAhiU3pErGx)rAqUfTnaAYTuCc8PmvYk9SwmNeoaePHZwaFxMuYVY5KYsDaV(ort(pI0WzlCvTChIfNVaqUfP4fqQI4E)4fboFbGClsXlGeNWKPXD8b4pqElGw6eurCVF8IaZjHdaP4fqItyY04(RCoPSuhWRVt0K)JoqNldz9eXkYimGjl1Jlo9LxQhFp8fNeoaKeNj3cgsTde37hViWR)ini3I2gan5wkob(uMkzLEwlMtchaI0WzlGVltk5x5CszPoGxFNOj)hrA4SfUQKvDxUdXIZxai3Iu8ci)8H4E)4fboFbGClsXlGeNWKPX9x5CszPoGxFNOj)hDGoxgY6jkDfzurCVF8IaZjHdaP4fqItyY04(RCoPSuhWRVt0K)JoqNldz9eXkYimGjl1Jlo9LxQhFp8fNeoaKeNj3cgsTdhq6zT4Kpuow0vHZsqYF9aswI2PBz47YKsgoG0ZAXjFOCSORcNLGK)6bKSeTt3YWt(p6UmPevYk9SwmNeoaKIxaj(4fXNpspRfZjHdaP4fqItyY04o(ql5iJkzLEwloFbGClsXlGeF8I4ZhPN1IZxai3Iu8ciXjmzAChFOLCKryatwQhxC6lVup(E4lojCaiPoFxdP2HJV4Kpuow0vHZsWjmzAC)v995JShq6zT4Kpuow0vHZsqYF9aswI2PBz47YKs(TCvhq6zT4Kpuow0vHZsqYF9aswI2PBz47YKsg)aspRfN8HYXIUkCwcs(RhqYs0oDldp5)O7YKsKryatwQhxC6lVup(E4lojCaiPoFxdP2bPN1Ivs4cbbqUfnPXb)uuDaPN1Ix)rAqUfTnaAYTu8tr1bKEwlE9hPb5w02aOj3sXjmzAChFGjl1dmNeoaKuNVlg(dK3cOLobHbmzPECXPV8s947HV4KWbGM07L2HRHu7WbKEwlE9hPb5w02aOj3sXpfvl3HyXCs4aqaPXvjR0ZAXhG3gjpdaF8I4ZhMSu5accysH7GAYOs2di9Sw86psdYTOTbqtULItyY04(ltwQhyojCaOj9EPD4IH)a5TaAPt4ZhI79JxeyLeUqqaKBrtACWjmzAC)8H4YHGJfxszjLdzujR6YLAGKUaMtchas5nNqNgTyiyPoC(8r6zTysh4KW3LgTisdhb0XhViKXqsdtJb1me4SxgI0W0arTdspRft6aNe(U0OfrA4iGo(4fHkzLEwlMtchasXlGe)u(8rw1D5oel2LdPIxajCujR0ZAX5laKBrkEbK4NYNpe37hViWGCNWl1dCc8PmzKrgHbmzPECXPV8s947HV4KWbGM07L2HRHu7G0ZAXKoWjHVlnAXjWKvL0ZAXWFfooWbP4lelL74NIWaMSupU40xEPE89WxCs4aqt69s7W1qQDq6zTysh4KW3LgT4eyYQswPN1I5KWbGu8ciXpLpFKEwloFbGClsXlGe)u(85aspRfV(J0GClABa0KBP4eMmnU)YKL6bMtchaAsVxAhUy4pqElGw6eKXqsdtJb1egWKL6XfN(Yl1JVh(ItchaAsVxAhUgsTdspRft6aNe(U0OfNatwvspRft6aNe(U0OfFxMuYG0ZAXKoWjHVlnAXt(p6UmPedjnmngutyatwQhxC6lVup(E4lojCaOj9EPD4Ai1oi9SwmPdCs47sJwCcmzvj9SwmPdCs47sJwCctMg3XhKvwPN1IjDGtcFxA0IVltkzSKjl1dmNeoa0KEV0oCXWFG8waT0jiZ3TKJmgsAyAmOMWaMSupU40xEPE89WxbSnqIwyQa31qQDq2eSjCByPo85J6Uusj0OvgvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsuj9SwmNeoaKIxaj(4fHQdi9Sw86psdYTOTbqtULIpErimGjl1Jlo9LxQhFp8fNeoaKNsgsTdspRfZjHdarA4SfW3LjLm(GCoPSuhWRVt0K)JinC2cxHbmzPECXPV8s947HVUpfidxoBi1om5GXkKD8HsL6Os6zTyojCaifVas8XlcvspRfNVaqUfP4fqIpErO6aspRfV(J0GClABa0KBP4JxecdyYs94ItF5L6X3dFXjHdaj157Ai1oi9SwC(6aYTOTjb4IFkQKEwlMtchaI0WzlGVltk5xJuyatwQhxC6lVup(E4lojCaijotUfmKAhMCWyfYo(GCoPSuhWsCMClGMCWifYQs6zTyojCaifVas8XlcvspRfNVaqUfP4fqIpErO6aspRfV(J0GClABa0KBP4JxeQKEwlMtchaI0WzlGVltkzq6zTyojCaisdNTaEY)r3LjLOI4E)4fbgK7eEPEGtyY04kmGjl1Jlo9LxQhFp8fNeoaKeNj3cgsTdspRfZjHdaP4fqIpErOs6zT48faYTifVas8Xlcvhq6zT41FKgKBrBdGMClfF8IqL0ZAXCs4aqKgoBb8DzsjdspRfZjHdarA4SfWt(p6UmPevl3HyXCs4aqEkPI4E)4fbMtchaYtjCctMg3XhAjhvtoySczhFOuvUkI79JxeyqUt4L6boHjtJRWaMSupU40xEPE89WxCs4aqsCMClyi1oi9SwmNeoaKIxaj(POs6zTyojCaifVasCctMg3XhAjhvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsurCVF8IadYDcVupWjmzACfgWKL6XfN(Yl1JVh(ItchasIZKBbdP2bPN1IZxai3Iu8ciXpfvspRfZjHdaP4fqIpErOs6zT48faYTifVasCctMg3XhAjhvspRfZjHdarA4SfW3LjLmi9SwmNeoaePHZwap5)O7YKsurCVF8IadYDcVupWjmzACfgWKL6XfN(Yl1JVh(ItchasIZKBbdP2bPN1I5KWbGu8ciXhViuj9SwC(ca5wKIxaj(4fHQdi9Sw86psdYTOTbqtULIFkQoG0ZAXR)ini3I2gan5wkoHjtJ74dTKJkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjcdyYs94ItF5L6X3dFXjHdajXzYTGHu7WYzlS4gG7BdwHSJBKQJkPN1I5KWbGinC2c47YKsgKEwlMtchaI0WzlGN8F0DzsjQYxawpBbmNeoaKKpL48mHyvXKLkhqqatkC)vnvspRfFaEBK8ma8XlcHbmzPECXPV8s947HV4KWbGG)kD)s9WqQDy5SfwCdW9TbRq2Xns1rL0ZAXCs4aqKgoBb8DzsjJl9SwmNeoaePHZwap5)O7YKsuLVaSE2cyojCaijFkX5zcXQIjlvoGGaMu4(RAQKEwl(a82i5za4JxecdyYs94ItF5L6X3dFXjHdaj157kmGjl1Jlo9LxQhFp8fi3j8s9WqQDq6zT48faYTifVas8XlcvspRfZjHdaP4fqIpErO6aspRfV(J0GClABa0KBP4JxecdyYs94ItF5L6X3dFXjHdajXzYTGWaHbmzPECX3goHdICUFp817cOjhmQfMgsTdYUChIfdrN22SqahvtoySczhFq9vUQjhmwHS)omMuhz(8rw1D5oelgIoTTzHaoQMCWyfYo(G6tDKryatwQhx8THt4GiN73dFP4l1ddP2bPN1I5KWbGu8ciXpfHbmzPECX3goHdICUFp81sNaQGtfdP2H8fG1ZwaVWuXtUJk4urL0ZAXW)g(DxQh4NIkzjU3pErG5KWbGu8ciXjWNY(8XsBBwuctMg3Xhg7YLryatwQhx8THt4GiN73dF1PTn7fP(Z70oHynKAhKEwlMtchasXlGeF8IqL0ZAX5laKBrkEbK4JxeQoG0ZAXR)ini3I2gan5wk(4fHWaMSupU4BdNWbro3Vh(sIBrUfTjLuY1qQDq6zTyojCaifVas8XlcvspRfNVaqUfP4fqIpErO6aspRfV(J0GClABa0KBP4JxecdyYs94IVnCche5C)E4ljiVqwcnAnKAhKEwlMtchasXlGe)uegWKL6XfFB4eoiY5(9WxsD3pi7llZqQDq6zTyojCaifVas8tryatwQhx8THt4GiN73dFzPji1D)yi1oi9SwmNeoaKIxaj(PimGjl1Jl(2WjCqKZ97HV4Ga3n5oIW9UHu7G0ZAXCs4aqkEbK4NIWaMSupU4BdNWbro3Vh(6DbeDH51qQDq6zTyojCaifVas8tryatwQhx8THt4GiN73dF9UaIUW0qWAbYIcEcdTD(q51ZlsIpTGHu7G0ZAXCs4aqkEbK4NYNpe37hViWCs4aqkEbK4eMmnU)oOoQJQdi9Sw86psdYTOTbqtULIFkcdyYs94IVnCche5C)E4R3fq0fMgg8egGPszjWDKNNGdcyi1oqCVF8IaZjHdaP4fqItyY04o(GrlxyatwQhx8THt4GiN73dF9UaIUW0WGNWWjb(yPjGKd3l0nKAhiU3pErG5KWbGu8ciXjmzAC)DWOL)5J6kNtkl1bmRG8a9UWGAF(i7sNWq5QKZjLL6aMgYHCHdYvGaYb1uLVaSE2c4lvPXd0D9CkJWaMSupU4BdNWbro3Vh(6DbeDHPHbpHHR)6iABqxinKAhiU3pErG5KWbGu8ciXjmzAC)DWOL)5J6kNtkl1bmRG8a9UWGAF(i7sNWq5QKZjLL6aMgYHCHdYvGaYb1uLVaSE2c4lvPXd0D9CkJWaMSupU4BdNWbro3Vh(6DbeDHPHbpHH2Ezkni3I47LoPDEPEyi1oqCVF8IaZjHdaP4fqItyY04(7Grl)Zh1voNuwQdywb5b6DHb1(8r2LoHHYvjNtkl1bmnKd5chKRabKdQPkFby9SfWxQsJhO765ugHbmzPECX3goHdICUFp817ci6ctddEcdtMWsjGUnaSO57sjgsTde37hViWCs4aqkEbK4eMmnUJpOoQKvDLZjLL6aMgYHCHdYvGaYb1(8zPt4xJSCzegWKL6XfFB4eoiY5(9WxVlGOlmnm4jmmzclLa62aWIMVlLyi1oqCVF8IaZjHdaP4fqItyY04o(G6OsoNuwQdyAihYfoixbcihutL0ZAX5laKBrkEbK4NIkPN1IZxai3Iu8ciXjmzAChFqw1kx9d1zSmFby9SfWxQsJhO765ugvlDcJBKLx36wRa]] )


end
