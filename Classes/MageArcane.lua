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
        if settings.am_spam then return 1 end
        if active_enemies > 2 or variable.prepull_evo == 1 then return 1 end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then return 1 end
        return 0
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


    spec:RegisterPack( "Arcane", 20201118, [[dWu5VeqiGQArIIGhbufCjrrfQnbKpPuvAuKuDkssRcOkQxbumlsIBjkQKDb1VuQYWiHoMOWYuQQEMOOmnrrQRbuPTPuv03efrJtuKCorrvRdOk18uk6EIQ9Pu4GavjwiqPhQuvOpcufjJeOks1jffv0kfL6LIIkLzcuf6MIIkKDQuQHcufPSuGQiEkfMQsjxfOkPVkkQunwrrO9kYFbnysDyKftWJv1KvYLrTzk9zP0OLItdz1IIk41KGzROBRWUf(nvdNqhhOILl55s10v56a2oj67u04jPCErjRxPQG5Ruz)eDkJ0wjJfDCA79R4(vmJmYitHZiZRygzSptgxwICYqKEfOwoze0GtgGxQNcozisznDAL2kz0DG65KrZDIDW792RfDnac43h71rdGjDip(IS3ED043lziaGMxMZijKmw0XPT3VI7xXmYiJmfoJmVIzOyMpz0f5pT9(C)jJg0AXrsizS4(Nmapi1zoIAzPg8s9uWYSbpi1B7k5HaxsDgzsvK69R4(vuMTmBWdsn4j8WvYsTsQqKWKX0a2fPHuJcP2sk9sQDRu357qrBhtdyxKgsT6Fd)ki1z5aLu3f5xQDXd5rxvSmBWdsn4vXfD8sQrXXvqtPUHI1efTsTBLALuHiHjJBiLm0f5Gxs95sTal1zi1MnCi1D(ou02X0a2fPHuNl1zGLzdEqQbV2zP(Yse90uQnqJ9rPUHI1efTsTBL6VHIGNsnkoUkaXd5HuJI(X0sQDRuVVpfppH0Fip2xCYyI6xpTvYWf5GR0wPTZiTvYGdsyYReytgUyYOZxYG(d5rYqjvisyYjdL0eGtgzKm(cDCHOKHyXkHT)cNbMv6pDipKAqsn4l1fqWwVAzChj24bSFEnWm4aGef5vYqjvWGgCYOHuYqxKdELU027pTvYGdsyYReytgUyYOZxYG(d5rYqjvisyYjdL0eGtgzKm(cDCHOKHaG1IP6PGHIUjx4LBgsniP(DFUCZat1tbdfDtUWfpiu0L6nKAfLAqsDbeS1Rwg3rInEa7NxdmdoairrELmusfmObNmAiLm0f5GxPlTDML2kzWbjm5vcSjJVqhxikzuabB9QLXDKyJhW(51aZGdasuKxsniP(OjhhUacg6wOOBYfMdsyYlPgKu)UpxUzGlGGHUfk6MCHlEqOOl1Bi1kk1GKA1LAbaRfxabdDlu0n5cVCZqQ3TtQflwjS9x4mWu9uWqbQkQLLAvtg0FipsgSs)Pd5r6sBNPtBLm4GeM8kb2KXxOJleLmkGGTE1Y4fQ)iXjkOkl47JbflmdoairrEj1GKAbaRfVq9hjorbvzbFFmOybTL3pmGyYG(d5rYWIkgkmP(LU02GBARKbhKWKxjWMm(cDCHOKrbeS1Rwg3wO(mli6r)KXm4aGef5LudsQhuqyX)K6nK6mp4MmO)qEKmSL3py4kP0L2EFM2kzWbjm5vcSjJVqhxikza(sDbeS1Rwg3rInEa7NxdmdoairrELmO)qEKmwmDncEfC6sBNjtBLm4GeM8kb2KXxOJleLmguqyX)K6nK6mTIjd6pKhjJIwikoyxKkfsxA7mvARKbhKWKxjWMm(cDCHOKb9hYdCVbzpu0cfDtUWFdfbprrRudsQB)fU4bHIUuNl1kMmO)qEKmEkEEcP)qEKU02z(0wjdoiHjVsGnz8f64crjJUdmfqXcBr8CbDluy69Up6yoiHjVsg0Fipsg9gK9qrlu0n5kDPTZqX0wjdoiHjVsGnz8f64crjdLuHiHjJrHsUoEbDro4sQZL6mKAqs97(C5MbUacg6wOOBYfU4bHIUuNl1kMmO)qEKmO6PGHEjKU02zKrARKbhKWKxjWMm(cDCHOKHsQqKWKXOqjxhVGUihCj15sDgsniP(DFUCZaxabdDlu0n5cx8GqrxQZLAfLAqsTaG1IP6PGHFdvTmUF0RGuVPulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOWK6x6sBNX(tBLm4GeM8kb2KXxOJleLmusfIeMmgfk564f0f5GlPoxQZqQbj1cawlUacg6wOOBYfE5MrYG(d5rYOacg6wOOBYv6sBNrML2kzWbjm5vcSjJVqhxikziayT4ciyOBHIUjx4LBgjd6pKhjJftxJGxbNU02zKPtBLm4GeM8kb2KXxOJleLmeaSwCbem0Tqr3Kl8YndPE3oPwSyLW2FHZat1tbdfOQOwozq)H8izmqv5vh6w451GJlDPTZaCtBLm4GeM8kb2KXxOJleLmeaSwCbem0Tqr3Kl8YndPE3oPwSyLW2FHZat1tbdfOQOwozq)H8izCoW3aDl8Ay4GArPlTDg7Z0wjdoiHjVsGnz8f64crjdXIvcB)fod85aFd0TWRHHdQfLmO)qEKmO6PGHIUjxPlTDgzY0wjdoiHjVsGnz8f64crjdbaRfxabdDlu0n5cVCZizq)H8izuabdDlu0n5kDPTZitL2kzWbjm5vcSjJVqhxikzSybaRfFoW3aDl8Ay4GAryarPgKuVybaRfFoW3aDl8Ay4GAr4Ihek6s9Msn9hYdmvpfmCG6D0K7ywn(bogEObNmO)qEKmelUZXZq3chOyLU02zK5tBLm4GeM8kb2KXxOJleLmw(HlAHO4GDrQuax8GqrxQ3qQbxPE3oPEXcawlUOfIId2fPsbOsGzWfjGMOllC)OxbPEdPwXKb9hYJKbvpfmuys9lDPT3VIPTsgCqctELaBY4l0XfIsgcawlwS4ohpdDlCGIfgquQbj1lwaWAXNd8nq3cVggoOwegquQbj1lwaWAXNd8nq3cVggoOweU4bHIUuVzUut)H8at1tbdfMu)WSA8dCm8qdozq)H8izq1tbdfMu)sxA79NrARKbhKWKxjWMm(cDCHOKHaG1IlGGHUfk6MCHbeLAqsTaG1IlGGHUfk6MCHlEqOOl1BMl1T)sQbj1cawlMQNcg(nu1Y4(rVcsDUulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOavf1YPlT9(3FARKbhKWKxjWMm(cDCHOKHaG1IlGGHUfk6MCHbeLAqs97(C5MbMQNcgk6MCHlEqOOl15sTIsniPEqbHf)tQ3uQZmfLAqsn4l1fqWwVAzChj24bSFEnWm4aGef5vYG(d5rYGQNcgkqvrTC6sBV)mlTvYGdsyYReytgFHoUquYqaWAXu9uWqr3KlmGOudsQfaSwmvpfmu0n5cx8GqrxQ3mxQB)LudsQfaSwmvpfm8BOQLX9JEfK6CPwaWAXu9uWWVHQwgpi1G9JEfsg0Fipsgu9uWqbQkQLtxA79NPtBLm4GeM8kb2KX3qOizKrYGPAMf8Biuar2KHaG1I)jt1t9dfTWVHIGN4LBgGuxaWAXu9uWqr3KlmG4UDQd(hn54WUsUeDtU4fMdsyYlqQlayT4ciyOBHIUjxyaXD7E3Nl3mWSs)Pd5bUyALLQQQAY4l0XfIsglwaWAXNd8nq3cVggoOwegquQbj1hn54Wu9uWq(BCmhKWKxsniPwaWAXlMUgbVcgVCZqQbj1lwaWAXNd8nq3cVggoOweU4bHIUuVHut)H8at1tbdhOEhn5oMvJFGJHhAWsniPwDPg8LAAFGl0XyQEkyOiWyWtu0I5GeM8sQ3TtQfaSw8pzQEQFOOf(nue8eVCZqQvnzq)H8izq1tbdhOEhn5E6sBVFWnTvYGdsyYReytg0Fipsgu9uWWbQ3rtUNm(gcfjJmsgFHoUquYqaWAX)KP6P(HIwCX0FsniP(DFUCZat1tbdfDtUWfpiu0L6nKAftxA79VptBLm4GeM8kb2Kb9hYJKbvpfmCG6D0K7jJVHqrYiJKXxOJleLmeaSw8pzQEQFOOfxm9NudsQfaSw8pzQEQFOOf3p6vqQZLAbaRf)tMQN6hkAXdsny)OxH0L2E)zY0wjdoiHjVsGnz8f64crjdbaRft1tbd)gQAzC)OxbPEZCPwjvisyY4ZVbCqQb)gQA5UudsQvxQF3Nl3mWu9uWqr3KlCXdcfDPEdPodfL6D7KA6pKsgYbpqCxQ3mxQ3VuRAYG(d5rYGQNcg6Lq6sBV)mvARKbhKWKxjWMm(cDCHOKHaG1IlGGHUfk6MCHbeL6D7K6bfew8pPEdPodWnzq)H8izq1tbdfMu)sxA79N5tBLm4GeM8kb2Kb9hYJKbR0F6qEKmqXXvbiEqKnzmOGWI)TrEMcCtgO44QaepiAm4fIoozKrY4l0XfIsgcawlUacg6wOOBYfE5Mr6sBNzkM2kzq)H8izq1tbdfOQOwozWbjm5vcSPlDjdU3545EAR02zK2kzWbjm5vcSjJVqhxikz8UpxUzGph4BGUfEnmCqTiCXdcfDPoxQvuQbj1cawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXNFd4Gud(nu1YDPgKu)UpxUzGP6PGHIUjx4Ihek6s9M5sD7VK6D7KAlQT5Gfpiu0L6nL6395Yndmvpfmu0n5cx8Gqrpzq)H8izimDFbDl8Ayih8iR0L2E)PTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuNl1kk1GKA1LAWxQpAYXH5yIABoo4fMdsyYlPE3oPwDP(OjhhMJjQT54GxyoiHjVKAqs9Gccl(NuVrUuNjvuQ3TtQ78DOOTJPbSlsdPoxQZqQvvQvvQbj1Ql1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQ3qQvsfIeMmMeHdsn4INuwsniPwDPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQ3TtQ78DOOTJPbSlsdPoxQZqQvvQvvQ3TtQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKAbaRft1tbd)gQAzC)OxbPoxQvuQvvQvvQbj1cawlUacg6wOOBYfE5MHudsQhuqyX)K6nYLALuHiHjJjr4afObWaoOGGI)LmO)qEKmeMUVGUfEnmKdEKv6sBNzPTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuVrUudUkk1GK6395Ynd85aFd0TWRHHdQfHlEqOOl1BMl1T)sQbj1cawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXNFd4Gud(nu1YDPgKuF0KJdxabdDlu0n5cZbjm5LudsQF3Nl3mWfqWq3cfDtUWfpiu0L6nZL62Fj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMm(8BahKAWfpPSsg0FipsgMEnxkzualU7bfpNU02z60wjdoiHjVsGnz8f64crjJ395Ynd85aFd0TWRHHdQfHlEqOOl15sTIsniPwaWAXu9uWWVHQwg3p6vqQ3mxQvsfIeMm(8BahKAWVHQwUl1GK6395Yndmvpfmu0n5cx8GqrxQ3mxQB)LuVBNuBrTnhS4bHIUuVPu)UpxUzGP6PGHIUjx4Ihek6jd6pKhjdtVMlLmkGf39GINtxABWnTvYGdsyYReytgFHoUquY4DFUCZat1tbdfDtUWfpiu0L6CPwrPgKuRUud(s9rtoomhtuBZXbVWCqctEj172j1Ql1hn54WCmrTnhh8cZbjm5LudsQhuqyX)K6nYL6mPIs9UDsDNVdfTDmnGDrAi15sDgsTQsTQsniPwDPwDP(DFUCZaFoW3aDl8Ay4GAr4Ihek6s9gsTsQqKWKXKiCqQbx8KYsQbj1Ql1cawlMQNcg(nu1Y4(rVcsDUulayTyQEky43qvlJhKAW(rVcs9UDsDNVdfTDmnGDrAi15sDgsTQsTQs9UDsT6s97(C5Mb(CGVb6w41WWb1IWfpiu0L6CPwrPgKulayTyQEky43qvlJ7h9ki15sTIsTQsTQsniPwaWAXfqWq3cfDtUWl3mKAqs9Gccl(NuVrUuRKkejmzmjchOanagWbfeu8VKb9hYJKHPxZLsgfWI7EqXZPlT9(mTvYGdsyYReytgFHoUquY4DFUCZaFoW3aDl8Ay4GAr4Ihek6sDUuROudsQfaSwmvpfm8BOQLX9JEfK6nZLALuHiHjJp)gWbPg8BOQL7sniP(DFUCZat1tbdfDtUWfpiu0L6nZL62Fj172j1wuBZblEqOOl1Bk1V7ZLBgyQEkyOOBYfU4bHIEYG(d5rYOfGQfIcOBH0(ax(1KU02zY0wjdoiHjVsGnz8f64crjJ395Yndmvpfmu0n5cx8GqrxQZLAfLAqsT6sn4l1hn54WCmrTnhh8cZbjm5LuVBNuRUuF0KJdZXe12CCWlmhKWKxsniPEqbHf)tQ3ixQZKkk172j1D(ou02X0a2fPHuNl1zi1Qk1Qk1GKA1LA1L6395Ynd85aFd0TWRHHdQfHlEqOOl1Bi1kPcrctgtIWbPgCXtklPgKuRUulayTyQEky43qvlJ7h9ki15sTaG1IP6PGHFdvTmEqQb7h9ki172j1D(ou02X0a2fPHuNl1zi1Qk1Qk172j1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsTaG1IP6PGHFdvTmUF0RGuNl1kk1Qk1Qk1GKAbaRfxabdDlu0n5cVCZqQbj1dkiS4Fs9g5sTsQqKWKXKiCGc0ayahuqqX)sg0FipsgTauTquaDlK2h4YVM0L2otL2kzWbjm5vcSjd6pKhjJ3JNJROJxq7KgCY4l0XfIsgcawlMQNcgk6MCHxUzi1GKAbaRfxabdDlu0n5cVCZqQbj1lwaWAXNd8nq3cVggoOweE5MHudsQhuq4dny45WbPMuVrUuZQXpWXWdn4KXefm8xjJ9z6sBN5tBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cVCZqQbj1cawlUacg6wOOBYfE5MHudsQxSaG1Iph4BGUfEnmCqTi8YndPgKupOGWhAWWZHdsnPEJCPMvJFGJHhAWjd6pKhjJIjru0cTtAW90L2odftBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cVCZqQbj1cawlUacg6wOOBYfE5MHudsQxSaG1Iph4BGUfEnmCqTi8YnJKb9hYJKH1FGoVG0(axOJHcmnsxA7mYiTvYGdsyYReytgFHoUquYqaWAXu9uWqr3Kl8YndPgKulayT4ciyOBHIUjx4LBgsniPEXcawl(CGVb6w41WWb1IWl3msg0FipsgIafYMfkAHctQFPlTDg7pTvYGdsyYReytgFHoUquYqaWAXu9uWqr3Kl8YndPgKulayT4ciyOBHIUjx4LBgsniPEXcawl(CGVb6w41WWb1IWl3msg0FipsgfsuCYqua7I0ZPlTDgzwARKbhKWKxjWMm(cDCHOKHaG1IP6PGHIUjx4LBgsniPwaWAXfqWq3cfDtUWl3mKAqs9IfaSw85aFd0TWRHHdQfHxUzKmO)qEKmUggcecoqSGwVEoDPTZitN2kzWbjm5vcSjJVqhxikziayTyQEkyOOBYfE5MHudsQfaSwCbem0Tqr3Kl8YndPgKuVybaRfFoW3aDl8Ay4GAr4LBgjd6pKhjJbp8klOBHtGhTGRIPrpDPlz8UpxUz0tBL2oJ0wjdoiHjVsGnz8f64crjJciyRxTmUTq9zwq0J(jJzWbajkYlPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsDMPOudsQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKA1LAbaRft1tbd)gQAzC)OxbPEZCPwjvisyY4ZVbCqQb)gQA5UudsQvxQvxQpAYXHlGGHUfk6MCH5GeM8sQbj1V7ZLBg4ciyOBHIUjx4Ihek6s9M5sD7VKAqs97(C5MbMQNcgk6MCHlEqOOl1Bi1kPcrctgF(nGdsn4INuwsTQs9UDsT6sn4l1hn54WfqWq3cfDtUWCqctEj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMm(8BahKAWfpPSKAvL6D7K6395Yndmvpfmu0n5cx8GqrxQ3mxQB)LuRQuRAYG(d5rYWwE)GHRKsxA79N2kzWbjm5vcSjJVqhxikzuabB9QLXTfQpZcIE0pzmdoairrEj1GK6395Yndmvpfmu0n5cx8GqrxQZLAfLAqsT6sn4l1hn54WCmrTnhh8cZbjm5LuVBNuRUuF0KJdZXe12CCWlmhKWKxsniPEqbHf)tQ3ixQZKkk1Qk1Qk1GKA1LA1L6395Ynd85aFd0TWRHHdQfHlEqOOl1Bi1zOOudsQfaSwmvpfm8BOQLX9JEfK6CPwaWAXu9uWWVHQwgpi1G9JEfKAvL6D7KA1L6395Ynd85aFd0TWRHHdQfHlEqOOl15sTIsniPwaWAXu9uWWVHQwg3p6vqQZLAfLAvLAvLAqsTaG1IlGGHUfk6MCHxUzi1GK6bfew8pPEJCPwjvisyYyseoqbAamGdkiO4Fjd6pKhjdB59dgUskDPTZS0wjdoiHjVsGnz8f64crjJciyRxTmEH6psCIcQYc((yqXcZGdasuKxsniP(DFUCZalayTWfQ)iXjkOkl47JbflCX0klPgKulayT4fQ)iXjkOkl47JbflOT8(HxUzi1GKA1LAbaRft1tbdfDtUWl3mKAqsTaG1IlGGHUfk6MCHxUzi1GK6flayT4Zb(gOBHxddhulcVCZqQvvQbj1V7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsT6sTaG1IP6PGHFdvTmUF0RGuVzUuRKkejmz853aoi1GFdvTCxQbj1Ql1Ql1hn54WfqWq3cfDtUWCqctEj1GK6395YndCbem0Tqr3KlCXdcfDPEZCPU9xsniP(DFUCZat1tbdfDtUWfpiu0L6nKALuHiHjJp)gWbPgCXtklPwvPE3oPwDPg8L6JMCC4ciyOBHIUjxyoiHjVKAqs97(C5MbMQNcgk6MCHlEqOOl1Bi1kPcrctgF(nGdsn4INuwsTQs9UDs97(C5MbMQNcgk6MCHlEqOOl1BMl1T)sQvvQvnzq)H8izylVFc(8sxA7mDARKbhKWKxjWMm(cDCHOKrbeS1RwgVq9hjorbvzbFFmOyHzWbajkYlPgKu)UpxUzGfaSw4c1FK4efuLf89XGIfUyALLudsQfaSw8c1FK4efuLf89XGIf0IkgVCZqQbj1IfRe2(lCgyB59tWNxYG(d5rYWIkgkmP(LU02GBARKbhKWKxjWMm(cDCHOKX7(C5Mb(CGVb6w41WWb1IWfpiu0L6CPwrPgKulayTyQEky43qvlJ7h9ki1BMl1kPcrctgF(nGdsn43qvl3LAqs97(C5MbMQNcgk6MCHlEqOOl1BMl1T)kzq)H8izmqv5vh6w451GJlDPT3NPTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuNl1kk1GKA1LAWxQpAYXH5yIABoo4fMdsyYlPE3oPwDP(OjhhMJjQT54GxyoiHjVKAqs9Gccl(NuVrUuNjvuQvvQvvQbj1Ql1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQ3qQvsfIeMmMeHdsn4INuwsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQvvQ3TtQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKAbaRft1tbd)gQAzC)OxbPoxQvuQvvQvvQbj1cawlUacg6wOOBYfE5MHudsQhuqyX)K6nYLALuHiHjJjr4afObWaoOGGI)LmO)qEKmgOQ8QdDl88AWXLU02zY0wjdoiHjVsGnz8f64crjJ395Ynd85aFd0TWRHHdQfHlEqOOl15sTIsniPwaWAXu9uWWVHQwg3p6vqQ3mxQvsfIeMm(8BahKAWVHQwUl1GK6395Yndmvpfmu0n5cx8GqrxQ3mxQB)vYG(d5rYyX01i4vWPlTDMkTvYGdsyYReytgFHoUquY4DFUCZat1tbdfDtUWfpiu0L6CPwrPgKuRUud(s9rtoomhtuBZXbVWCqctEj172j1Ql1hn54WCmrTnhh8cZbjm5LudsQhuqyX)K6nYL6mPIsTQsTQsniPwDPwDP(DFUCZaFoW3aDl8Ay4GAr4Ihek6s9gsDgkk1GKAbaRft1tbd)gQAzC)OxbPoxQfaSwmvpfm8BOQLXdsny)OxbPwvPE3oPwDP(DFUCZaFoW3aDl8Ay4GAr4Ihek6sDUuROudsQfaSwmvpfm8BOQLX9JEfK6CPwrPwvPwvPgKulayT4ciyOBHIUjx4LBgsniPEqbHf)tQ3ixQvsfIeMmMeHduGgad4Gcck(xYG(d5rYyX01i4vWPlTDMpTvYGdsyYReytgFHoUquY4DFUCZaFoW3aDl8Ay4GAr4Ihek6s9gsTsQqKWKXvhoi1GlEszj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMmU6WbPgCXtklPgKuRUuF0KJdxabdDlu0n5cZbjm5LudsQF3Nl3mWfqWq3cfDtUWfpiu0L6nZL62Fj172j1hn54WfqWq3cfDtUWCqctEj1GK6395YndCbem0Tqr3KlCXdcfDPEdPwjvisyY4QdhKAWfpPSK6D7KAWxQpAYXHlGGHUfk6MCH5GeM8sQvvQbj1cawlMQNcg(nu1Y4(rVcs9gs9(LAqs9IfaSw85aFd0TWRHHdQfHxUzKmO)qEKmkAHO4GDrQuiDPTZqX0wjdoiHjVsGnz8f64crjJ395Ynd85aFd0TWRHHdQfHlEqOOl15sTIsniPwaWAXu9uWWVHQwg3p6vqQ3mxQvsfIeMm(8BahKAWVHQwUl1GK6395Yndmvpfmu0n5cx8GqrxQ3mxQB)vYG(d5rYOOfIId2fPsH0L2oJmsBLm4GeM8kb2KXxOJleLmE3Nl3mWu9uWqr3KlCXdcfDPoxQvuQbj1Ql1Ql1GVuF0KJdZXe12CCWlmhKWKxs9UDsT6s9rtoomhtuBZXbVWCqctEj1GK6bfew8pPEJCPotQOuRQuRQudsQvxQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuVHuRKkejmzmjchKAWfpPSKAqsTaG1IP6PGHFdvTmUF0RGuNl1cawlMQNcg(nu1Y4bPgSF0RGuRQuVBNuRUu)UpxUzGph4BGUfEnmCqTiCXdcfDPoxQvuQbj1cawlMQNcg(nu1Y4(rVcsDUuROuRQuRQudsQfaSwCbem0Tqr3Kl8YndPgKupOGWI)j1BKl1kPcrctgtIWbkqdGbCqbbf)tQvnzq)H8izu0crXb7IuPq6sBNX(tBLm4GeM8kb2KXxOJleLmE3Nl3mWu9uWqr3KlCXdcfDPEtPgCvuQbj1CVZXZyLOoYdOBHICz5)qEGhOWRKb9hYJKX5aFd0TWRHHdQfLU02zKzPTsgCqctELaBY4l0XfIsgcawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXNFd4Gud(nu1YDPgKuF0KJdxabdDlu0n5cZbjm5LudsQF3Nl3mWfqWq3cfDtUWfpiu0L6nZL62Fj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMm(8BahKAWfpPSKAqs97k5GIdRqwfIcPgKu)UpxUzGlAHO4GDrQuax8GqrxQ3mxQZujd6pKhjJZb(gOBHxddhulkDPTZitN2kzWbjm5vcSjJVqhxikziayTyQEky43qvlJ7h9ki1BMl1kPcrctgF(nGdsn43qvl3LAqs9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3mxQB)LudsQF3Nl3mWu9uWqr3KlCXdcfDPEdPwjvisyY4ZVbCqQbx8KYsQbj1GVu)UsoO4WkKvHOizq)H8izCoW3aDl8Ay4GArPlTDgGBARKbhKWKxjWMm(cDCHOKHaG1IP6PGHFdvTmUF0RGuVzUuRKkejmz853aoi1GFdvTCxQbj1GVuF0KJdxabdDlu0n5cZbjm5LudsQF3Nl3mWu9uWqr3KlCXdcfDPEdPwjvisyY4ZVbCqQbx8KYkzq)H8izCoW3aDl8Ay4GArPlTDg7Z0wjdoiHjVsGnz8f64crjdbaRft1tbd)gQAzC)OxbPEZCPwjvisyY4ZVbCqQb)gQA5UudsQF3Nl3mWu9uWqr3KlCXdcfDPEZCPU9xjd6pKhjJZb(gOBHxddhulkDPTZitM2kzWbjm5vcSjJVqhxikz8UpxUzGph4BGUfEnmCqTiCXdcfDPEdPwjvisyYyseoi1GlEszj1GKAbaRft1tbd)gQAzC)OxbPoxQfaSwmvpfm8BOQLXdsny)OxbPgKulayT4ciyOBHIUjx4LBgsniPEqbHf)tQ3ixQvsfIeMmMeHduGgad4Gcck(xYG(d5rYGQNcgk6MCLU02zKPsBLm4GeM8kb2KXxOJleLmeaSwCbem0Tqr3Kl8YndPgKu)UpxUzGph4BGUfEnmCqTiCXdcfDPEdPwjvisyY4YfHdsn4INuwsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQbj1Ql1V7ZLBgyQEkyOOBYfU4bHIUuVHuNb4k172j1lwaWAXNd8nq3cVggoOwegquQvnzq)H8izuabdDlu0n5kDPTZiZN2kzWbjm5vcSjJVqhxikziayTyQEky43qvlJ7h9ki15sTIsniP(DLCqXHviRcrrYG(d5rYqS4ohpdDlCGIv6sBVFftBLm4GeM8kb2KXxOJleLmwSaG1Iph4BGUfEnmCqTimGOudsQbFP(DLCqXHviRcrrYG(d5rYqS4ohpdDlCGIv6sxYO8JoKhPTsBNrARKbhKWKxjWMm(cDCHOKX7(C5Mb(CGVb6w41WWb1IWfpiu0L6CPwrPgKuRUulayTyQEky43qvlJ7h9ki1Bi1kPcrctgF(nGdsn43qvl3LAqs9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3mxQB)LudsQF3Nl3mWu9uWqr3KlCXdcfDPEdPwjvisyY4ZVbCqQbx8KYsQbj1VRKdkoSczvikKAqs97(C5MbUOfIId2fPsbCXdcfDPEZCPotj1QMmO)qEKmO6PGHcuvulNU027pTvYGdsyYReytg0FipsgSs)Pd5rYafhxfG4br2KXGccl(3g5zEWfK6GFbeS1Rwg3rInEa7NxdmdoairrETBNaG1I7iXgpG9ZRbUF0RqUaG1I7iXgpG9ZRbEqQb7h9kOAYafhxfG4brJbVq0XjJmsgFHoUquYyqbHf)tQ3mxQvsfIeMmMv6qX)KAqsT6s97(C5Mb(CGVb6w41WWb1IWfpiu0L6nZLA6pKhywP)0H8aZQXpWXWdnyPE3oP(DFUCZat1tbdfDtUWfpiu0L6nZLA6pKhywP)0H8aZQXpWXWdnyPE3oPwDP(OjhhUacg6wOOBYfMdsyYlPgKu)UpxUzGlGGHUfk6MCHlEqOOl1BMl10FipWSs)Pd5bMvJFGJHhAWsTQsTQsniPwaWAXfqWq3cfDtUWl3mKAqsTaG1IP6PGHIUjx4LBgsniPEXcawl(CGVb6w41WWb1IWl3msxA7mlTvYGdsyYReytgFHoUquYOac26vlJ7iXgpG9ZRbMbhaKOiVKAqs97(C5MbMQNcgk6MCHlEqOOl1BMl10FipWSs)Pd5bMvJFGJHhAWjd6pKhjdwP)0H8iDPTZ0PTsgCqctELaBY4l0XfIsgV7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsT6sTaG1IP6PGHFdvTmUF0RGuVHuRKkejmz853aoi1GFdvTCxQbj1hn54WfqWq3cfDtUWCqctEj1GK6395YndCbem0Tqr3KlCXdcfDPEZCPU9xsniP(DFUCZat1tbdfDtUWfpiu0L6nKALuHiHjJp)gWbPgCXtklPgKud(s97k5GIdRqwfIcPw1Kb9hYJKbvpfmuGQIA50L2gCtBLm4GeM8kb2KXxOJleLmE3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKA1LAbaRft1tbd)gQAzC)OxbPEdPwjvisyY4ZVbCqQb)gQA5UudsQbFP(OjhhUacg6wOOBYfMdsyYlPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsTsQqKWKXNFd4GudU4jLLuRAYG(d5rYGQNcgkqvrTC6sBVptBLm4GeM8kb2KXxOJleLmE3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKA1LAbaRft1tbd)gQAzC)OxbPEdPwjvisyY4ZVbCqQb)gQA5UudsQF3Nl3mWu9uWqr3KlCXdcfDPEZCPU9xsTQjd6pKhjdQEkyOavf1YPlTDMmTvYGdsyYReytgFHoUquYyXcawlUOfIId2fPsbOsGzWfjGMOllC)OxbPoxQxSaG1IlAHO4GDrQuaQeygCrcOj6Ycpi1G9JEfKAqsT6sTaG1IP6PGHIUjx4LBgs9UDsTaG1IP6PGHIUjx4Ihek6s9M5sD7VKAvLAqsT6sTaG1IlGGHUfk6MCHxUzi172j1cawlUacg6wOOBYfU4bHIUuVzUu3(lPw1Kb9hYJKbvpfmuGQIA50L2otL2kzWbjm5vcSjJVqhxikzS8dx0crXb7IuPaU4bHIUuVHudUs9UDs9IfaSwCrlefhSlsLcqLaZGlsanrxw4(rVcs9gsTIjd6pKhjdQEkyOWK6x6sBN5tBLm4GeM8kb2KXxOJleLmeaSwSyXDoEg6w4aflmGOudsQxSaG1Iph4BGUfEnmCqTimGOudsQxSaG1Iph4BGUfEnmCqTiCXdcfDPEZCPM(d5bMQNcgkmP(Hz14h4y4HgCYG(d5rYGQNcgkmP(LU02zOyARKbhKWKxjWMm(gcfjJmsgmvZSGFdHciYMmeaSw8pzQEQFOOf(nue8eVCZaK6cawlMQNcgk6MCHbe3TtDW)Ojhh2vYLOBYfVWCqctEbsDbaRfxabdDlu0n5cdiUB37(C5MbMv6pDipWftRSuvvvtgFHoUquYyXcawl(CGVb6w41WWb1IWaIsniP(OjhhMQNcgYFJJ5GeM8sQbj1cawlEX01i4vW4LBgsniPwDPEXcawl(CGVb6w41WWb1IWfpiu0L6nKA6pKhyQEky4a17Oj3XSA8dCm8qdwQ3TtQF3Nl3mWIf354zOBHduSWfpiu0L6nKAfL6D7K63vYbfhwHSkefsTQsniPwDPg8LAAFGl0XyQEkyOiWyWtu0I5GeM8sQ3TtQfaSw8pzQEQFOOf(nue8eVCZqQvnzq)H8izq1tbdhOEhn5E6sBNrgPTsgCqctELaBY4l0XfIsgcawl(Nmvp1pu0IlM(tQbj1cawlMvtKIfVGI(XXHOjgqmzq)H8izq1tbdhOEhn5E6sBNX(tBLm4GeM8kb2Kb9hYJKbvpfmCG6D0K7jJVHqrYiJKXxOJleLmeaSw8pzQEQFOOfxm9NudsQvxQfaSwmvpfmu0n5cdik172j1cawlUacg6wOOBYfgquQ3TtQxSaG1Iph4BGUfEnmCqTiCXdcfDPEdPM(d5bMQNcgoq9oAYDmRg)ahdp0GLAvtxA7mYS0wjdoiHjVsGnzq)H8izq1tbdhOEhn5EY4BiuKmYiz8f64crjdbaRf)tMQN6hkAXft)j1GKAbaRf)tMQN6hkAX9JEfK6CPwaWAX)KP6P(HIw8Gud2p6viDPTZitN2kzWbjm5vcSjd6pKhjdQEky4a17Oj3tgFdHIKrgjJVqhxikziayT4FYu9u)qrlUy6pPgKulayT4FYu9u)qrlU4bHIUuVzUuRUuRUulayT4FYu9u)qrlUF0RGudEwQP)qEGP6PGHduVJMChZQXpWXWdnyPwvPgmsD7VKAvtxA7ma30wjdoiHjVsGnz8f64crjd1L6ITf3BiHjl172j1GVuFOxbu0k1Qk1GKAbaRft1tbd)gQAzC)OxbPoxQfaSwmvpfm8BOQLXdsny)OxbPgKulayTyQEkyOOBYfE5MHudsQxSaG1Iph4BGUfEnmCqTi8YnJKb9hYJKrWxdxWJhIC)sxA7m2NPTsgCqctELaBY4l0XfIsgcawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXNFd4Gud(nu1Y9Kb9hYJKbvpfm0lH0L2oJmzARKbhKWKxjWMm(cDCHOKXGccl(NuVzUuN5bxPgKulayTyQEkyOOBYfE5MHudsQfaSwCbem0Tqr3Kl8YndPgKuVybaRfFoW3aDl8Ay4GAr4LBgjd6pKhjJoGixHRKsxA7mYuPTsgCqctELaBY4l0XfIsgcawlMQNcgk6MCHxUzi1GKAbaRfxabdDlu0n5cVCZqQbj1lwaWAXNd8nq3cVggoOweE5MHudsQF3Nl3mWSs)Pd5bU4bHIUuVHuROudsQF3Nl3mWu9uWqr3KlCXdcfDPEdPwrPgKu)UpxUzGph4BGUfEnmCqTiCXdcfDPEdPwrPgKuRUud(s9rtooCbem0Tqr3KlmhKWKxs9UDsT6s9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3qQvuQvvQvnzq)H8iz0Bq2dfTqr3KR0L2oJmFARKbhKWKxjWMm(cDCHOKHaG1IlGjdDl8AkM7yarPgKulayTyQEky43qvlJ7h9ki1Bi1zwYG(d5rYGQNcgkmP(LU027xX0wjdoiHjVsGnz8f64crjJbfew8pPEtPwjvisyYybQkQLHdkiO4FsniP(DFUCZaZk9NoKh4Ihek6s9gsTIsniPwaWAXu9uWqr3Kl8YndPgKulayTyQEky43qvlJ7h9ki15sTaG1IP6PGHFdvTmEqQb7h9ki1GKAU354zSsuh5b0TqrUS8FipWdu4vYG(d5rYGQNcgkqvrTC6sBV)msBLm4GeM8kb2KXxOJleLmE3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKA1L6395YndCbem0Tqr3KlCXdcfDPoxQvuQ3TtQF3Nl3mWu9uWqr3KlCXdcfDPoxQvuQvvQbj1cawlMQNcg(nu1Y4(rVcsDUulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOavf1YPlT9(3FARKbhKWKxjWMm(cDCHOKXGccl(NuVzUuRKkejmzSavf1YWbfeu8pPgKulayTyQEkyOOBYfE5MHudsQfaSwCbem0Tqr3Kl8YndPgKuVybaRfFoW3aDl8Ay4GAr4LBgsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQbj1V7ZLBgywP)0H8ax8GqrxQ3qQvmzq)H8izq1tbdfOQOwoDPT3FML2kzWbjm5vcSjJVqhxikziayTyQEkyOOBYfE5MHudsQfaSwCbem0Tqr3Kl8YndPgKuVybaRfFoW3aDl8Ay4GAr4LBgsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQbj1hn54Wu9uWqVeWCqctEj1GK6395Yndmvpfm0lbCXdcfDPEZCPU9xsniPEqbHf)tQ3mxQZ8kk1GK6395YndmR0F6qEGlEqOOl1Bi1kMmO)qEKmO6PGHcuvulNU027ptN2kzWbjm5vcSjJVqhxikziayTyQEkyOOBYfgquQbj1cawlMQNcgk6MCHlEqOOl1BMl1T)sQbj1cawlMQNcg(nu1Y4(rVcsDUulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOavf1YPlT9(b30wjdoiHjVsGnz8f64crjdbaRfxabdDlu0n5cdik1GKAbaRfxabdDlu0n5cx8GqrxQ3mxQB)LudsQfaSwmvpfm8BOQLX9JEfK6CPwaWAXu9uWWVHQwgpi1G9JEfsg0Fipsgu9uWqbQkQLtxA79VptBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cVCZqQbj1cawlUacg6wOOBYfE5MHudsQxSaG1Iph4BGUfEnmCqTimGOudsQxSaG1Iph4BGUfEnmCqTiCXdcfDPEZCPU9xsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vizq)H8izq1tbdfOQOwoDPT3FMmTvYG(d5rYGQNcgkmP(Lm4GeM8kb20L2E)zQ0wjdoiHjVsGnz8f64crjdbaRfxabdDlu0n5cVCZqQbj1cawlMQNcgk6MCHxUzi1GK6flayT4Zb(gOBHxddhulcVCZizq)H8izWk9NoKhPlT9(Z8PTsg0Fipsgu9uWqbQkQLtgCqctELaB6sBNzkM2kzWbjm5vcSjdxmz05lzq)H8izOKkejm5KHsAcWjJmsgFHoUquYqaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQbj1GVulayT4cyYq3cVMI5ogquQbj1wuBZblEqOOl1BMl1Ql1Ql1dkiPEpPM(d5bMQNcgkmP(HFVFsTQsn4zPM(d5bMQNcgkmP(Hz14h4y4HgSuRAYqjvWGgCYWIcAcfaQiDPlzqdyxKgPTsBNrARKbhKWKxjWMm(cDCHOKXGccl(NuVzUuRKkejmzmR0HI)j1GKA1L6395Ynd85aFd0TWRHHdQfHlEqOOl1BMl10FipWSs)Pd5bMvJFGJHhAWs9UDs97(C5MbMQNcgk6MCHlEqOOl1BMl10FipWSs)Pd5bMvJFGJHhAWs9UDsT6s9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3mxQP)qEGzL(thYdmRg)ahdp0GLAvLAvLAqsTaG1IlGGHUfk6MCHxUzi1GKAbaRft1tbdfDtUWl3mKAqs9IfaSw85aFd0TWRHHdQfHxUzKmO)qEKmyL(thYJ0L2E)PTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuNl1kk1GKA1LAbaRfxabdDlu0n5cVCZqQbj1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQ3qQvsfIeMmMeHdsn4INuws9UDs97(C5Mb(CGVb6w41WWb1IWfpiu0L6CPwrPwvPw1Kb9hYJKXIPRrWRGtxA7mlTvYGdsyYReytgFHoUquY4DFUCZat1tbdfDtUWfpiu0L6CPwrPgKuRUulayT4ciyOBHIUjx4LBgsniPwDP(DFUCZaFoW3aDl8Ay4GAr4Ihek6s9gsTsQqKWKXKiCqQbx8KYsQ3TtQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1Qk1QMmO)qEKmgOQ8QdDl88AWXLU02z60wjd6pKhjJIwikoyxKkfsgCqctELaB6sBdUPTsgCqctELaBY4l0XfIsgcawlMQNcgk6MCHxUzi1GKAbaRfxabdDlu0n5cVCZqQbj1lwaWAXNd8nq3cVggoOweE5MrYG(d5rYO3GShkAHIUjxPlT9(mTvYGdsyYReytgFHoUquYqaWAXfqWq3cfDtUWl3mKAqs97(C5MbMQNcgk6MCHlEqOOl1Bi1kMmO)qEKmkGGHUfk6MCLU02zY0wjdoiHjVsGnz8f64crjd1L6395Yndmvpfmu0n5cx8GqrxQZLAfLAqsTaG1IlGGHUfk6MCHxUzi1Qk172j1IfRe2(lCg4ciyOBHIUjxjd6pKhjJZb(gOBHxddhulkDPTZuPTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuVPudUkk1GKAbaRfxabdDlu0n5cVCZqQbj1CVZXZyLOoYdOBHICz5)qEG5GeM8kzq)H8izCoW3aDl8Ay4GArPlTDMpTvYGdsyYReytgFHoUquYqaWAXfqWq3cfDtUWl3mKAqs97(C5Mb(CGVb6w41WWb1IWfpiu0L6nKALuHiHjJjr4GudU4jLvYG(d5rYGQNcgk6MCLU02zOyARKbhKWKxjWMm(cDCHOKHaG1IP6PGHIUjxyarPgKulayTyQEkyOOBYfU4bHIUuVzUut)H8at1tbdhOEhn5oMvJFGJHhAWsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vizq)H8izq1tbdfOQOwoDPTZiJ0wjdoiHjVsGnz8f64crjdbaRft1tbd)gQAzC)OxbPEtPwaWAXu9uWWVHQwgpi1G9JEfKAqsTaG1IlGGHUfk6MCHxUzi1GKAbaRft1tbdfDtUWl3mKAqs9IfaSw85aFd0TWRHHdQfHxUzKmO)qEKmO6PGHEjKU02zS)0wjdoiHjVsGnz8f64crjdbaRfxabdDlu0n5cVCZqQbj1cawlMQNcgk6MCHxUzi1GK6flayT4Zb(gOBHxddhulcVCZqQbj1cawlMQNcg(nu1Y4(rVcsDUulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOavf1YPlTDgzwARKbhKWKxjWMm(gcfjJmsgmvZSGFdHciYMmeaSw8pzQEQFOOf(nue8eVCZaK6cawlMQNcgk6MCHbe3TtaWAXfqWq3cfDtUWaI729UpxUzGzL(thYdCX0klvtgFHoUquYqaWAX)KP6P(HIwCX0Fjd6pKhjdQEky4a17Oj3txA7mY0PTsgCqctELaBY4BiuKmYizWunZc(nekGiBYqaWAX)KP6P(HIw43qrWt8YndqQlayTyQEkyOOBYfgqC3obaRfxabdDlu0n5cdiUB37(C5MbMv6pDipWftRSunz8f64crjdWxQP9bUqhJP6PGHIaJbprrlMdsyYlPE3oPwaWAX)KP6P(HIw43qrWt8YnJKb9hYJKbvpfmCG6D0K7PlTDgGBARKbhKWKxjWMm(cDCHOKHaG1IlGGHUfk6MCHxUzi1GKAbaRft1tbdfDtUWl3mKAqs9IfaSw85aFd0TWRHHdQfHxUzKmO)qEKmyL(thYJ0L2oJ9zARKbhKWKxjWMm(cDCHOKHaG1IP6PGHFdvTmUF0RGuVPulayTyQEky43qvlJhKAW(rVcjd6pKhjdQEkyOxcPlTDgzY0wjd6pKhjdQEkyOavf1YjdoiHjVsGnDPTZitL2kzq)H8izq1tbdfMu)sgCqctELaB6sxYy4k5bhxAR02zK2kzWbjm5vcSjJVqhxikzmCL8GJdVq9JINL6nYL6mumzq)H8izimrHcPlT9(tBLmO)qEKmelUZXZq3chOyLm4GeM8kb20L2oZsBLm4GeM8kb2KXxOJleLmgUsEWXHxO(rXZs9MsDgkMmO)qEKmO6PGHduVJMCpDPTZ0PTsg0Fipsgu9uWqVesgCqctELaB6sBdUPTsg0FipsgwuXqHj1VKbhKWKxjWMU0Lmel(9HaDPTsBNrARKbhKWKxjWMmCXKrXD(sg0FipsgkPcrctozOKkyqdoziwSiWCczLEYyXwcyEjdftxA79N2kzWbjm5vcSjdxmz05lzq)H8izOKkejm5KHsAcWjJmsgFHoUquYqjvisyYyXIfbMtiR0L6CPwrPgKuxabB9QLXDKyJhW(51aZGdasuKxsniPM(dPKHCWde3L6nK69NmusfmObNmelweyoHSspDPTZS0wjdoiHjVsGnz4IjJoFjd6pKhjdLuHiHjNmustaozKrY4l0XfIsgkPcrctglwSiWCczLUuNl1kk1GK6ciyRxTmUJeB8a2pVgygCaqII8sQbj1VRKdkoCWF5tVwsniPM(dPKHCWde3L6nK6msgkPcg0GtgIflcmNqwPNU02z60wjdoiHjVsGnz4IjJI78LmO)qEKmusfIeMCYqjvWGgCYOHuYqxKdELmwSLaMxYqX0L2gCtBLm4GeM8kb2KHlMm68LmO)qEKmusfIeMCYqjnb4KrgjJVqhxikzOKkejmzCdPKHUih8sQZLAfLAqsn9hsjd5GhiUl1Bi17pzOKkyqdoz0qkzOlYbVsxA79zARKbhKWKxjWMmCXKrNVKb9hYJKHsQqKWKtgkPjaNmYiz8f64crjdLuHiHjJBiLm0f5GxsDUuROudsQvsfIeMmwSyrG5eYkDPoxQZizOKkyqdoz0qkzOlYbVsxA7mzARKbhKWKxjWMmCXKrNVKb9hYJKHsQqKWKtgkPjaNmumzOKkyqdozyrbnHcavKU02zQ0wjdoiHjVsGnz4IjJI78LmO)qEKmusfIeMCYqjvWGgCYO6WbPgCXtkRKXITeW8sgGB6sBN5tBLm4GeM8kb2KHlMmkUZxYG(d5rYqjvisyYjdLubdAWjdseoi1GlEszLmwSLaMxYidftxA7mumTvYGdsyYReytgUyYO4oFjd6pKhjdLuHiHjNmusfmObNmkxeoi1GlEszLmwSLaMxYy)kMU02zKrARKbhKWKxjWMmCXKrXD(sg0FipsgkPcrctozOKkyqdozC(nGdsn4INuwjJfBjG5Lma30L2oJ9N2kzWbjm5vcSjdxmz05lzq)H8izOKkejm5KHsAcWjJmlz8f64crjdLuHiHjJp)gWbPgCXtklPoxQbxPgKuxabB9QLXlu)rItuqvwW3hdkwygCaqII8kzOKkyqdozC(nGdsn4INuwPlTDgzwARKbhKWKxjWMmCXKrNVKb9hYJKHsQqKWKtgkPjaNmYaCtgFHoUquYqjvisyY4ZVbCqQbx8KYsQZLAWvQbj1VRKdkoCGABoOL4KHsQGbn4KX53aoi1GlEszLU02zKPtBLm4GeM8kb2KHlMm68LmO)qEKmusfIeMCYqjnb4KrgGBY4l0XfIsgkPcrctgF(nGdsn4INuwsDUudUsniP(9ybGomvpfmuS8fQnlmhKWKxsniPM(dPKHCWde3L6nL6mlzOKkyqdozC(nGdsn4INuwPlTDgGBARKbhKWKxjWMmCXKrNVKb9hYJKHsQqKWKtgkPjaNmYmftgFHoUquYqjvisyY4ZVbCqQbx8KYsQZLAWvQbj1CVZXZyLOoYdOBHICz5)qEGhOWRKHsQGbn4KX53aoi1GlEszLU02zSptBLm4GeM8kb2KHlMmkUZxYG(d5rYqjvisyYjdLubdAWjdbQkQLHdkiO4FjJfBjG5LmYqrftxA7mYKPTsgCqctELaBYWftgD(sg0FipsgkPcrctozOKMaCYqDPEFQOuN5sQvxQhu)4klOsAcWsn4zPodfvuQvvQvnz8f64crjdLuHiHjJfOQOwgoOGGI)j15sDgkQOudsQFxjhuC4a12CqlXjdLubdAWjdbQkQLHdkiO4FPlTDgzQ0wjdoiHjVsGnz4IjJoFjd6pKhjdLuHiHjNmustaozOUuNPuuQZCj1Ql1dQFCLfujnbyPg8SuNHIkk1Qk1QMm(cDCHOKHsQqKWKXcuvuldhuqqX)K6CPodfvmzOKkyqdoziqvrTmCqbbf)lDPTZiZN2kzWbjm5vcSjdxmzuCNVKb9hYJKHsQqKWKtgkPcg0GtgKiCGc0ayahuqqX)sgl2saZlzKb4MU027xX0wjdoiHjVsGnz4IjJoFjd6pKhjdLuHiHjNmustaozaUkMm(cDCHOKHsQqKWKXKiCGc0ayahuqqX)K6CPoZuuQbj1fqWwVAz8c1FK4efuLf89XGIfMbhaKOiVsgkPcg0GtgKiCGc0ayahuqqX)sxA79NrARKbhKWKxjWMmCXKrNVKb9hYJKHsQqKWKtgkPjaNmaxftgFHoUquYqjvisyYyseoqbAamGdkiO4FsDUuNzkk1GK6ciyRxTmUTq9zwq0J(jJzWbajkYRKHsQGbn4KbjchOanagWbfeu8V0L2E)7pTvYGdsyYReytgUyYO4oFjd6pKhjdLuHiHjNmusfmObNmo)gWbPg8BOQL7jJfBjG5Lm2F6sBV)mlTvYGdsyYReytgUyYO4oFjd6pKhjdLuHiHjNmusfmObNmqHsUoEbDro4kzSylbmVKHIPlT9(Z0PTsgCqctELaBYWftgD(sg0FipsgkPcrctozOKMaCYiJKXxOJleLmusfIeMmgfk564f0f5GlPoxQvuQbj1hn54WfqWq3cfDtUWCqctEj1GK6JMCCyQEkyi)noMdsyYRKHsQGbn4KbkuY1XlOlYbxPlT9(b30wjdoiHjVsGnz4IjJoFjd6pKhjdLuHiHjNmustaozWGdasuKx4b9KqXWEdZhCa0rVuVBNuZGdasuKx42jTq05vhkqRwwQ3TtQzWbajkYlC7Kwi68Qdh8IMtKhs9UDsndoairrEHxuPWW9aU4xbOiWvC)54zPE3oPMbhaKOiVWOO)fWrctgcoauCad4IvIEwQ3TtQzWbajkYlC3bMt(ou0claHSK6D7KAgCaqII8c3bcHP7lin4RjR(j172j1m4aGef5f2KuGdU6qB5XsQ3TtQzWbajkYlSDsdg6wOaD3KtgkPcg0GtgKi0diqNtxA79VptBLm4GeM8kb2KHlMmkUZxYG(d5rYqjvisyYjdLubdAWjdYz453aoi1GFdvTCpzSylbmVKX(txA79NjtBLm4GeM8kb2KHlMm68LmO)qEKmusfIeMCYqjnb4KrgjJVqhxikzOKkejmzCdPKHUih8sQZLAfLAqsDNVdfTDmnGDrAi15sDgjdLubdAWjJgsjdDro4v6sBV)mvARKbhKWKxjWMmCXKrXD(sg0FipsgkPcrctozOKkyqdozWkDO4FjJfBjG5LmYaCtxA79N5tBLm4GeM8kb20L2oZumTvYGdsyYReytxA7mlJ0wjdoiHjVsGnDPTZS9N2kzq)H8iz0bgdpGu9uWqlnqtevjdoiHjVsGnDPTZSmlTvYG(d5rYGQNcgIIJNt(VKbhKWKxjWMU02zwMoTvYG(d5rY49iZbGIHdkiylpsgCqctELaB6sBNzGBARKbhKWKxjWMU02z2(mTvYG(d5rYyGQYliAqTCYGdsyYReytxA7mltM2kzWbjm5vcSjJVqhxikzOKkejmzSyXIaZjKv6s9M5sTIsniPUac26vlJxO(JeNOGQSGVpguSWm4aGef5vYG(d5rYWwE)e85LU02zwMkTvYGdsyYReytgFHoUquYqjvisyYyXIfbMtiR0L6nZLAfLAqsn4l1fqWwVAz8c1FK4efuLf89XGIfMbhaKOiVsg0Fipsgu9uWqHj1V0L2oZY8PTsgCqctELaBY4l0XfIsgkPcrctglwSiWCczLUuVHuRyYG(d5rYGv6pDipsx6sgKZPTsBNrARKbhKWKxjWMm(cDCHOKrbeS1RwgVq9hjorbvzbFFmOyHzWbajkYlPgKu)UpxUzGfaSw4c1FK4efuLf89XGIfUyALLudsQfaSw8c1FK4efuLf89XGIf0wE)Wl3mKAqsT6sTaG1IP6PGHIUjx4LBgsniPwaWAXfqWq3cfDtUWl3mKAqs9IfaSw85aFd0TWRHHdQfHxUzi1Qk1GK6395Ynd85aFd0TWRHHdQfHlEqOOl15sTIsniPwDPwaWAXu9uWWVHQwg3p6vqQ3mxQvsfIeMmMCgE(nGdsn43qvl3LAqsT6sT6s9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3mxQB)LudsQF3Nl3mWu9uWqr3KlCXdcfDPEdPwjvisyY4ZVbCqQbx8KYsQvvQ3TtQvxQbFP(OjhhUacg6wOOBYfMdsyYlPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsTsQqKWKXNFd4GudU4jLLuRQuVBNu)UpxUzGP6PGHIUjx4Ihek6s9M5sD7VKAvLAvtg0Fipsg2Y7NGpV0L2E)PTsgCqctELaBY4l0XfIsgQl1fqWwVAz8c1FK4efuLf89XGIfMbhaKOiVKAqs97(C5MbwaWAHlu)rItuqvwW3hdkw4IPvwsniPwaWAXlu)rItuqvwW3hdkwqlQy8YndPgKulwSsy7VWzGTL3pbFEsTQs9UDsT6sDbeS1RwgVq9hjorbvzbFFmOyHzWbajkYlPgKuFObl15sTIsTQjd6pKhjdlQyOWK6x6sBNzPTsgCqctELaBY4l0XfIsgfqWwVAzCBH6ZSGOh9tgZGdasuKxsniP(DFUCZat1tbdfDtUWfpiu0L6nK6mtrPgKu)UpxUzGph4BGUfEnmCqTiCXdcfDPoxQvuQbj1Ql1cawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXKZWZVbCqQb)gQA5UudsQvxQvxQpAYXHlGGHUfk6MCH5GeM8sQbj1V7ZLBg4ciyOBHIUjx4Ihek6s9M5sD7VKAqs97(C5MbMQNcgk6MCHlEqOOl1Bi1kPcrctgF(nGdsn4INuwsTQs9UDsT6sn4l1hn54WfqWq3cfDtUWCqctEj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMm(8BahKAWfpPSKAvL6D7K6395Yndmvpfmu0n5cx8GqrxQ3mxQB)LuRQuRAYG(d5rYWwE)GHRKsxA7mDARKbhKWKxjWMm(cDCHOKrbeS1Rwg3wO(mli6r)KXm4aGef5LudsQF3Nl3mWu9uWqr3KlCXdcfDPoxQvuQbj1Ql1Ql1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQ3qQvsfIeMmMeHdsn4INuwsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQvvQ3TtQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKAbaRft1tbd)gQAzC)OxbPEZCPwjvisyYyYz453aoi1GFdvTCxQvvQvvQbj1cawlUacg6wOOBYfE5MHuRAYG(d5rYWwE)GHRKsxABWnTvYGdsyYReytgFHoUquYOac26vlJ7iXgpG9ZRbMbhaKOiVKAqsTyXkHT)cNbMv6pDipsg0FipsgNd8nq3cVggoOwu6sBVptBLm4GeM8kb2KXxOJleLmkGGTE1Y4osSXdy)8AGzWbajkYlPgKuRUulwSsy7VWzGzL(thYdPE3oPwSyLW2FHZaFoW3aDl8Ay4GArsTQjd6pKhjdQEkyOOBYv6sBNjtBLm4GeM8kb2KXxOJleLmo0GL6nK6mtrPgKuxabB9QLXDKyJhW(51aZGdasuKxsniPwaWAXu9uWWVHQwg3p6vqQ3mxQvsfIeMmMCgE(nGdsn43qvl3LAqs97(C5Mb(CGVb6w41WWb1IWfpiu0L6CPwrPgKu)UpxUzGP6PGHIUjx4Ihek6s9M5sD7Vsg0FipsgSs)Pd5r6sBNPsBLm4GeM8kb2Kb9hYJKbR0F6qEKmqXXvbiEqKnziayT4osSXdy)8AG7h9kKlayT4osSXdy)8AGhKAW(rVcjduCCvaIheng8crhNmYiz8f64crjJdnyPEdPoZuuQbj1fqWwVAzChj24bSFEnWm4aGef5LudsQF3Nl3mWu9uWqr3KlCXdcfDPoxQvuQbj1Ql1Ql1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQ3qQvsfIeMmMeHdsn4INuwsniPwaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQvvQ3TtQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKAbaRft1tbd)gQAzC)OxbPEZCPwjvisyYyYz453aoi1GFdvTCxQvvQvvQbj1cawlUacg6wOOBYfE5MHuRA6sBN5tBLm4GeM8kb2KXxOJleLmuxQF3Nl3mWu9uWqr3KlCXdcfDPEdPotdUs9UDs97(C5MbMQNcgk6MCHlEqOOl1BMl1zMuRQudsQF3Nl3mWNd8nq3cVggoOweU4bHIUuNl1kk1GKA1LAbaRft1tbd)gQAzC)OxbPEZCPwjvisyYyYz453aoi1GFdvTCxQbj1Ql1Ql1hn54WfqWq3cfDtUWCqctEj1GK6395YndCbem0Tqr3KlCXdcfDPEZCPU9xsniP(DFUCZat1tbdfDtUWfpiu0L6nKAWvQvvQ3TtQvxQbFP(OjhhUacg6wOOBYfMdsyYlPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsn4k1Qk172j1V7ZLBgyQEkyOOBYfU4bHIUuVzUu3(lPwvPw1Kb9hYJKXavLxDOBHNxdoU0L2odftBLm4GeM8kb2KXxOJleLmE3Nl3mWNd8nq3cVggoOweU4bHIUuVHuRKkejmzC1Hdsn4INuwsniP(DFUCZat1tbdfDtUWfpiu0L6nKALuHiHjJRoCqQbx8KYsQbj1Ql1hn54WfqWq3cfDtUWCqctEj1GK6395YndCbem0Tqr3KlCXdcfDPEZCPU9xs9UDs9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZaxabdDlu0n5cx8GqrxQ3qQvsfIeMmU6WbPgCXtklPE3oPg8L6JMCC4ciyOBHIUjxyoiHjVKAvLAqsTaG1IP6PGHFdvTmUF0RGuVzUuRKkejmzm5m88BahKAWVHQwUl1GK6flayT4Zb(gOBHxddhulcVCZizq)H8izu0crXb7IuPq6sBNrgPTsgCqctELaBY4l0XfIsgV7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsT6sTaG1IP6PGHFdvTmUF0RGuVzUuRKkejmzm5m88BahKAWVHQwUl1GKA1LA1L6JMCC4ciyOBHIUjxyoiHjVKAqs97(C5MbUacg6wOOBYfU4bHIUuVzUu3(lPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsTsQqKWKXNFd4GudU4jLLuRQuVBNuRUud(s9rtooCbem0Tqr3KlmhKWKxsniP(DFUCZat1tbdfDtUWfpiu0L6nKALuHiHjJp)gWbPgCXtklPwvPE3oP(DFUCZat1tbdfDtUWfpiu0L6nZL62Fj1Qk1QMmO)qEKmkAHO4GDrQuiDPTZy)PTsgCqctELaBY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuNl1kk1GKA1LA1LA1L6395Ynd85aFd0TWRHHdQfHlEqOOl1Bi1kPcrctgtIWbPgCXtklPgKulayTyQEky43qvlJ7h9ki15sTaG1IP6PGHFdvTmEqQb7h9ki1Qk172j1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsTaG1IP6PGHFdvTmUF0RGuVzUuRKkejmzm5m88BahKAWVHQwUl1Qk1Qk1GKAbaRfxabdDlu0n5cVCZqQvnzq)H8izu0crXb7IuPq6sBNrML2kzWbjm5vcSjJVqhxikz8UpxUzGP6PGHIUjx4Ihek6sDUuROudsQvxQvxQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuVHuRKkejmzmjchKAWfpPSKAqsTaG1IP6PGHFdvTmUF0RGuNl1cawlMQNcg(nu1Y4bPgSF0RGuRQuVBNuRUu)UpxUzGph4BGUfEnmCqTiCXdcfDPoxQvuQbj1cawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXKZWZVbCqQb)gQA5UuRQuRQudsQfaSwCbem0Tqr3Kl8YndPw1Kb9hYJKXIPRrWRGtxA7mY0PTsgCqctELaBY4l0XfIsgcawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXKZWZVbCqQb)gQA5UudsQvxQvxQpAYXHlGGHUfk6MCH5GeM8sQbj1V7ZLBg4ciyOBHIUjx4Ihek6s9M5sD7VKAqs97(C5MbMQNcgk6MCHlEqOOl1Bi1kPcrctgF(nGdsn4INuwsTQs9UDsT6sn4l1hn54WfqWq3cfDtUWCqctEj1GK6395Yndmvpfmu0n5cx8GqrxQ3qQvsfIeMm(8BahKAWfpPSKAvL6D7K6395Yndmvpfmu0n5cx8GqrxQ3mxQB)LuRAYG(d5rY4CGVb6w41WWb1IsxA7ma30wjdoiHjVsGnz8f64crjd1LA1L6395Ynd85aFd0TWRHHdQfHlEqOOl1Bi1kPcrctgtIWbPgCXtklPgKulayTyQEky43qvlJ7h9ki15sTaG1IP6PGHFdvTmEqQb7h9ki1Qk172j1Ql1V7ZLBg4Zb(gOBHxddhulcx8GqrxQZLAfLAqsTaG1IP6PGHFdvTmUF0RGuVzUuRKkejmzm5m88BahKAWVHQwUl1Qk1Qk1GKAbaRfxabdDlu0n5cVCZizq)H8izq1tbdfDtUsxA7m2NPTsgCqctELaBY4l0XfIsgcawlUacg6wOOBYfE5MHudsQvxQvxQF3Nl3mWNd8nq3cVggoOweU4bHIUuVHuVFfLAqsTaG1IP6PGHFdvTmUF0RGuNl1cawlMQNcg(nu1Y4bPgSF0RGuRQuVBNuRUu)UpxUzGph4BGUfEnmCqTiCXdcfDPoxQvuQbj1cawlMQNcg(nu1Y4(rVcs9M5sTsQqKWKXKZWZVbCqQb)gQA5UuRQuRQudsQvxQF3Nl3mWu9uWqr3KlCXdcfDPEdPodWvQ3TtQxSaG1Iph4BGUfEnmCqTimGOuRAYG(d5rYOacg6wOOBYv6sBNrMmTvYGdsyYReytgFHoUquYqaWAXlMUgbVcgdik1GK6flayT4Zb(gOBHxddhulcdik1GK6flayT4Zb(gOBHxddhulcx8GqrxQ3mxQfaSwSyXDoEg6w4afl8Gud2p6vqQbpl10FipWu9uWqHj1pmRg)ahdp0Gtg0FipsgIf354zOBHduSsxA7mYuPTsgCqctELaBY4l0XfIsgcawlEX01i4vWyarPgKuRUuRUuF0KJdxC3dkEgZbjm5LudsQP)qkzih8aXDPEtPotl1Qk172j10FiLmKdEG4UuVPudUsTQsniPwDPg8L6ciyRxTmMQNcgk4dbQwdoomdoairrEj172j1hvT8HByAEnyX)K6nK6mdCLAvtg0Fipsgu9uWqHj1V0L2oJmFARKb9hYJKrhqKRWvsjdoiHjVsGnDPT3VIPTsgCqctELaBY4l0XfIsgcawlMQNcg(nu1Y4(rVcsDUuRyYG(d5rYGQNcg6Lq6sBV)msBLm4GeM8kb2KXxOJleLmuxQl2wCVHeMSuVBNud(s9HEfqrRuRQudsQfaSwmvpfm8BOQLX9JEfK6CPwaWAXu9uWWVHQwgpi1G9JEfsg0FipsgbFnCbpEiY9lDPT3)(tBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cVCZqQbj1cawlUacg6wOOBYfE5MHudsQxSaG1Iph4BGUfEnmCqTi8YndPgKu)UpxUzGP6PGHIUjx4Ihek6s9gsTIsniP(DFUCZaFoW3aDl8Ay4GAr4Ihek6s9gsTIsniPwDPg8L6JMCC4ciyOBHIUjxyoiHjVK6D7KA1L6JMCC4ciyOBHIUjxyoiHjVKAqs97(C5MbUacg6wOOBYfU4bHIUuVHuROuRQuRAYG(d5rYO3GShkAHIUjxPlT9(ZS0wjdoiHjVsGnz8f64crjdbaRf)tMQN6hkAXft)j1GK6ciyRxTmMQNcgIclkqxwygCaqII8sQbj1hn54W0qCISONoKhyoiHjVKAqsn9hsjd5GhiUl1Bk1zQKb9hYJKbvpfmCG6D0K7PlT9(Z0PTsgCqctELaBY4l0XfIsgcawl(Nmvp1pu0IlM(tQbj1Ql1fqWwVAzmvpfmefwuGUSWm4aGef5LuVBNuF0KJdtdXjYIE6qEG5GeM8sQvvQbj10FiLmKdEG4UuVPudUjd6pKhjdQEky4a17Oj3txA79dUPTsgCqctELaBY4l0XfIsgcawlMQNcg(nu1Y4(rVcs9MsTaG1IP6PGHFdvTmEqQb7h9kKmO)qEKmO6PGHSAItVJ8iDPT3)(mTvYGdsyYReytgFHoUquYqaWAXu9uWWVHQwg3p6vqQZLAbaRft1tbd)gQAz8Gud2p6vqQbj1IfRe2(lCgyQEkyOavf1Yjd6pKhjdQEkyiRM407ipsxA79NjtBLm4GeM8kb2KXxOJleLmeaSwmvpfm8BOQLX9JEfK6CPwaWAXu9uWWVHQwgpi1G9JEfsg0Fipsgu9uWqbQkQLtxA79NPsBLmqXXvbiEqKnzmOGWI)TrEMcCtgO44QaepiAm4fIoozKrYG(d5rYGv6pDipsgCqctELaB6sxYO3qfVG)QN2kTDgPTsgCqctELaBY4l0XfIsgQl1hn54WCmrTnhh8cZbjm5LudsQhuqyX)K6nZL6mLIsniPEqbHf)tQ3ixQ3NGRuRQuVBNuRUud(s9rtoomhtuBZXbVWCqctEj1GK6bfew8pPEZCPotbUsTQjd6pKhjJbfeSLhPlT9(tBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cdiMmO)qEKme9d5r6sBNzPTsgCqctELaBY4l0XfIsgfqWwVAz8XdrVOj0KkrmdoairrEj1GKAbaRfZQ1qa9d5bgquQbj1Ql1V7ZLBgyQEkyOOBYfU4bHIUuNl1kk172j1cEVl1GKAlQT5Gfpiu0L6nZL6mTIsTQjd6pKhjJdnyOjvIPlTDMoTvYGdsyYReytgFHoUquYqaWAXu9uWqr3Kl8YndPgKulayT4ciyOBHIUjx4LBgsniPEXcawl(CGVb6w41WWb1IWl3msg0FipsgtuBZ1HzoaSAhCCPlTn4M2kzWbjm5vcSjJVqhxikziayTyQEkyOOBYfE5MHudsQfaSwCbem0Tqr3Kl8YndPgKuVybaRfFoW3aDl8Ay4GAr4LBgjd6pKhjdbQf6w4vOxHE6sBVptBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cdiMmO)qEKme4QZLcOOnDPTZKPTsgCqctELaBY4l0XfIsgcawlMQNcgk6MCHbetg0Fipsgct3xqlqLv6sBNPsBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cdiMmO)qEKmSOIfMUVsxA7mFARKbhKWKxjWMm(cDCHOKHaG1IP6PGHIUjxyaXKb9hYJKbfp3VIMWNMZ0L2odftBLm4GeM8kb2KXxOJleLmeaSwmvpfmu0n5cdiMmO)qEKma6meD8ONU02zKrARKbhKWKxjWMmO)qEKmAN0crNxDOaTA5KXxOJleLmeaSwmvpfmu0n5cdik172j1V7ZLBgyQEkyOOBYfU4bHIUuVrUudUGRudsQxSaG1Iph4BGUfEnmCqTimGyYGTw(pyqdoz0oPfIoV6qbA1YPlTDg7pTvYGdsyYReytg0Fipsg8qmRIPj0RvqXZjJVqhxikz8UpxUzGP6PGHIUjx4Ihek6s9M5s9(vmze0Gtg8qmRIPj0RvqXZPlTDgzwARKbhKWKxjWMmO)qEKmwftllQyOsU35zY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuVrUuVFfL6D7KAWxQvsfIeMmMeHEab6SuNl1zi172j1Ql1hAWsDUuROudsQvsfIeMmgfk564f0f5GlPoxQZqQbj1fqWwVAzChj24bSFEnWm4aGef5LuRAYiObNmwftllQyOsU35z6sBNrMoTvYGdsyYReytg0FipsgDhycrTb64kz8f64crjJ395Yndmvpfmu0n5cx8GqrxQ3ixQ3VIs9UDsn4l1kPcrctgtIqpGaDwQZL6mK6D7KA1L6dnyPoxQvuQbj1kPcrctgJcLCD8c6ICWLuNl1zi1GK6ciyRxTmUJeB8a2pVgygCaqII8sQvnze0GtgDhycrTb64kDPTZaCtBLm4GeM8kb2Kb9hYJKr7mlXgOBHuVJgOjDipsgFHoUquY4DFUCZat1tbdfDtUWfpiu0L6nYL69ROuVBNud(sTsQqKWKXKi0diqNL6CPodPE3oPwDP(qdwQZLAfLAqsTsQqKWKXOqjxhVGUihCj15sDgsniPUac26vlJ7iXgpG9ZRbMbhaKOiVKAvtgbn4Kr7mlXgOBHuVJgOjDipsxA7m2NPTsgCqctELaBYG(d5rYyqpjumS3W8bhaD0Nm(cDCHOKX7(C5MbMQNcgk6MCHlEqOOl1BMl1GRudsQvxQbFPwjvisyYyuOKRJxqxKdUK6CPodPE3oP(qdwQ3qQZmfLAvtgbn4KXGEsOyyVH5doa6OpDPTZitM2kzWbjm5vcSjd6pKhjJb9KqXWEdZhCa0rFY4l0XfIsgV7ZLBgyQEkyOOBYfU4bHIUuVzUudUsniPwjvisyYyuOKRJxqxKdUK6CPodPgKulayT4ciyOBHIUjxyarPgKulayT4ciyOBHIUjx4Ihek6s9M5sT6sDgkk1zUKAWvQbpl1fqWwVAzChj24bSFEnWm4aGef5LuRQudsQp0GL6nL6mtXKrqdozmONekg2By(GdGo6tx6sgl2saZlTvA7msBLm4GeM8kb2KXxOJleLmoQA5dVybaRf)u)qrlUy6VKb9hYJKX7aXXvxKNZ0L2E)PTsgCqctELaBYG(d5rY4P5es)H8aor9lzmr9dg0Gtg9gQ4f8x90L2oZsBLm4GeM8kb2Kb9hYJKXtZjK(d5bCI6xYyI6hmObNm4ENJN7PlTDMoTvYGdsyYReytgFHoUquYG(dPKHCWde3L6nK69NmO)qEKmEAoH0FipGtu)sgtu)Gbn4Kb5C6sBdUPTsgCqctELaBY4l0XfIsgkPcrctg3qkzOlYbVK6nZLAftg0FipsgpnNq6pKhWjQFjJjQFWGgCYWf5GR0L2EFM2kzWbjm5vcSjJVqhxikz057qrBhtdyxKgsDUuNrYG(d5rY4P5es)H8aor9lzmr9dg0Gtg0a2fPr6sBNjtBLm4GeM8kb2Kb9hYJKXtZjK(d5bCI6xYyI6hmObNmE3Nl3m6PlTDMkTvYGdsyYReytgFHoUquYqjvisyYylkOjuaOcPoxQvmzq)H8iz80CcP)qEaNO(LmMO(bdAWjJYp6qEKU02z(0wjdoiHjVsGnz8f64crjdLuHiHjJTOGMqbGkK6CPoJKb9hYJKXtZjK(d5bCI6xYyI6hmObNmSOGMqbGksxA7mumTvYGdsyYReytg0FipsgpnNq6pKhWjQFjJjQFWGgCYy4k5bhx6sxYWIcAcfaQiTvA7msBLm4GeM8kb2Kb9hYJKbvpfmCG6D0K7jJVHqrYiJKXxOJleLmeaSw8pzQEQFOOfxm9x6sBV)0wjd6pKhjdQEkyOWK6xYGdsyYReytxA7mlTvYG(d5rYGQNcgkqvrTCYGdsyYReytx6sxYqjxDKhPT3VI7xXmYqXmsgMufOOTNmYCh8c4jBN5CBWtbEl1s9wnSuJgIEDsT1lPEFl)Od5X(k1fdoaOIxsD3hSutaNpOJxs93qrl3XYSbpIcwQZa8wQ3h9qjxhVK699DLCqXHZeXCqctETVs95s9((UsoO4WzI7RuREgQPkwMn4ruWsDMg8wQ3h9qjxhVK699DLCqXHZeXCqctETVs95s9((UsoO4WzI7RuREgQPkwMn4ruWsDgkcEl17JEOKRJxs9((UsoO4WzIyoiHjV2xP(CPEFFxjhuC4mX9vQvpd1uflZg8ikyPoZue8wQ3h9qjxhVKAd0yFuQ7zfhPMuN5yP(CPg8iaj1lKsuh5Hu7ICrNxsT67PQuREgQPkwMTm7m3bVaEY2zo3g8uG3sTuVvdl1OHOxNuB9sQ3xXIFFiq3(k1fdoaOIxsD3hSutaNpOJxs93qrl3XYSbpIcwQZmWBPEF0dLCD8sQ333vYbfhoteZbjm51(k1Nl1777k5GIdNjUVsT6zOMQyz2Ghrbl1zKzG3s9(Ohk564LuVVVRKdkoCMiMdsyYR9vQpxQ333vYbfhotCFLA1ZqnvXYSbpIcwQZitcEl17JEOKRJxs9((UsoO4WzIyoiHjV2xP(CPEFFxjhuC4mX9vQvpd1uflZwMDM7Gxapz7mNBdEkWBPwQ3QHLA0q0RtQTEj1777(C5MrFFL6IbhauXlPU7dwQjGZh0XlP(BOOL7yz2Ghrbl1zKzG3s9(Ohk564LuVVVRKdkoCMiMdsyYR9vQpxQ333vYbfhotCFLA1ZqnvXYSbpIcwQZitdEl17JEOKRJxs9((UsoO4WzIyoiHjV2xP(CPEFFxjhuC4mX9vQvpd1uflZg8ikyPoJmp4TuVp6HsUoEj1777k5GIdNjI5GeM8AFL6ZL699DLCqXHZe3xPw9mutvSmBWJOGL69Ri4TuVp6HsUoEj1777k5GIdNjI5GeM8AFL6ZL699DLCqXHZe3xPw9mutvSmBz2zohIED8sQZidPM(d5Hupr9RJLzNmel3IMCYa8GuN5iQLLAWl1tblZg8GuVTRKhcCj1zKjvrQ3VI7xrz2YSbpi1GNWdxjl1kPcrctgtdyxKgsnkKAlP0lP2TsDNVdfTDmnGDrAi1Q)n8RGuNLdusDxKFP2fpKhDvXYSbpi1Gxfx0XlPgfhxbnL6gkwtu0k1UvQvsfIeMmUHuYqxKdEj1Nl1cSuNHuB2WHu357qrBhtdyxKgsDUuNbwMn4bPg8ANL6llr0ttP2an2hL6gkwtu0k1UvQ)gkcEk1O44QaepKhsnk6htlP2Ts9((u88es)H8yFXYSLzt)H8OJfl(9HaDGjFpLuHiHjRsqdoxSyrG5eYkDvCX8I78PYITeW8YvuMn9hYJowS43hc0bM89usfIeMSkbn4CXIfbMtiR0vXfZ78PIsAcW5zOcYMRKkejmzSyXIaZjKv65kcQac26vlJ7iXgpG9ZRbMbhaKOiVar)HuYqo4bI7BSFz20Fip6yXIFFiqhyY3tjvisyYQe0GZflweyoHSsxfxmVZNkkPjaNNHkiBUsQqKWKXIflcmNqwPNRiOciyRxTmUJeB8a2pVgygCaqII8c07k5GIdh8x(0RfMdsyYlq0FiLmKdEG4(gziZM(d5rhlw87db6at(EkPcrctwLGgCEdPKHUih8sfxmV4oFQSylbmVCfLzt)H8OJfl(9HaDGjFpLuHiHjRsqdoVHuYqxKdEPIlM35tfL0eGZZqfKnxjvisyY4gsjdDro4vUIGO)qkzih8aX9n2VmB6pKhDSyXVpeOdm57PKkejmzvcAW5nKsg6ICWlvCX8oFQOKMaCEgQGS5kPcrctg3qkzOlYbVYveKsQqKWKXIflcmNqwPNNHmB6pKhDSyXVpeOdm57PKkejmzvcAW5wuqtOaqfQ4I5D(urjnb4CfLzt)H8OJfl(9HaDGjFpLuHiHjRsqdoV6WbPgCXtklvCX8I78PYITeW8Ybxz20Fip6yXIFFiqhyY3tjvisyYQe0GZjr4GudU4jLLkUyEXD(uzXwcyE5zOOmB6pKhDSyXVpeOdm57PKkejmzvcAW5LlchKAWfpPSuXfZlUZNkl2saZlF)kkZM(d5rhlw87db6at(EkPcrctwLGgC(53aoi1GlEszPIlMxCNpvwSLaMxo4kZM(d5rhlw87db6at(EkPcrctwLGgC(53aoi1GlEszPIlM35tfL0eGZZmvq2CLuHiHjJp)gWbPgCXtkRCWfubeS1RwgVq9hjorbvzbFFmOyHzWbajkYlz20Fip6yXIFFiqhyY3tjvisyYQe0GZp)gWbPgCXtklvCX8oFQOKMaCEgGRkiBUsQqKWKXNFd4GudU4jLvo4c6DLCqXHduBZbTeJ5GeM8sMn9hYJowS43hc0bM89usfIeMSkbn48ZVbCqQbx8KYsfxmVZNkkPjaNNb4QcYMRKkejmz853aoi1GlEszLdUGEpwaOdt1tbdflFHAZcZbjm5fi6pKsgYbpqCFZmtMn9hYJowS43hc0bM89usfIeMSkbn48ZVbCqQbx8KYsfxmVZNkkPjaNNzkQcYMRKkejmz853aoi1GlEszLdUG4ENJNXkrDKhq3cf5YY)H8apqHxYSP)qE0XIf)(qGoWKVNsQqKWKvjObNlqvrTmCqbbf)tfxmV4oFQSylbmV8muurz20Fip6yXIFFiqhyY3tjvisyYQe0GZfOQOwgoOGGI)PIlM35tfL0eGZvFFQyMl1hu)4klOsAcWGNZqrfvvvvq2CLuHiHjJfOQOwgoOGGI)LNHIkc6DLCqXHduBZbTeJ5GeM8sMn9hYJowS43hc0bM89usfIeMSkbn4CbQkQLHdkiO4FQ4I5D(urjnb4C1ZukM5s9b1pUYcQKMam45muurvvvfKnxjvisyYybQkQLHdkiO4F5zOOIYSP)qE0XIf)(qGoWKVNsQqKWKvjObNtIWbkqdGbCqbbf)tfxmV4oFQSylbmV8maxz20Fip6yXIFFiqhyY3tjvisyYQe0GZjr4afObWaoOGGI)PIlM35tfL0eGZbxfvbzZvsfIeMmMeHduGgad4Gcck(xEMPiOciyRxTmEH6psCIcQYc((yqXcZGdasuKxYSP)qE0XIf)(qGoWKVNsQqKWKvjObNtIWbkqdGbCqbbf)tfxmVZNkkPjaNdUkQcYMRKkejmzmjchOanagWbfeu8V8mtrqfqWwVAzCBH6ZSGOh9tgZGdasuKxYSP)qE0XIf)(qGoWKVNsQqKWKvjObNF(nGdsn43qvl3vXfZlUZNkl2saZlF)YSP)qE0XIf)(qGoWKVNsQqKWKvjObNJcLCD8c6ICWLkUyEXD(uzXwcyE5kkZM(d5rhlw87db6at(EkPcrctwLGgCokuY1XlOlYbxQ4I5D(urjnb48mubzZvsfIeMmgfk564f0f5GRCfbD0KJdxabdDlu0n5cZbjm5fOJMCCyQEkyi)noMdsyYlz20Fip6yXIFFiqhyY3tjvisyYQe0GZjrOhqGoRIlM35tfL0eGZzWbajkYl8GEsOyyVH5doa6OF3ogCaqII8c3oPfIoV6qbA1Y72XGdasuKx42jTq05vho4fnNip2TJbhaKOiVWlQuy4Eax8Raue4kU)C88UDm4aGef5fgf9VaosyYqWbGIdyaxSs0Z72XGdasuKx4UdmN8DOOfwaczTBhdoairrEH7aHW09fKg81Kv)2TJbhaKOiVWMKcCWvhAlpw72XGdasuKxy7Kgm0Tqb6UjlZM(d5rhlw87db6at(EkPcrctwLGgCo5m88BahKAWVHQwURIlMxCNpvwSLaMx((Lzt)H8OJfl(9HaDGjFpLuHiHjRsqdoVHuYqxKdEPIlM35tfL0eGZZqfKnxjvisyY4gsjdDro4vUIG68DOOTJPbSlsJ8mKzt)H8OJfl(9HaDGjFpLuHiHjRsqdoNv6qX)uXfZlUZNkl2saZlpdWvMn9hYJowS43hc0bM89StQRGmB6pKhDSyXVpeOdm57zDFjZM(d5rhlw87db6at(Eeq7GJJoKhYSP)qE0XIf)(qGoWKVhvpfm0sd0erLmB6pKhDSyXVpeOdm57r1tbdrXXZj)NmB6pKhDSyXVpeOdm579EK5aqXWbfeSLhYSP)qE0XIf)(qGoWKVxpiXEJFW(rxxMn9hYJowS43hc0bM89gOQ8cIgullZM(d5rhlw87db6at(E2Y7NGppvq2CLuHiHjJflweyoHSsFZCfbvabB9QLXlu)rItuqvwW3hdkwygCaqII8sMn9hYJowS43hc0bM89O6PGHctQFQGS5kPcrctglwSiWCczL(M5kcc8lGGTE1Y4fQ)iXjkOkl47JbflmdoairrEjZM(d5rhlw87db6at(ESs)Pd5HkiBUsQqKWKXIflcmNqwPVHIYSLzt)H8OdM89EhioU6I8CQcYMFu1YhEXcawl(P(HIwCX0FYSP)qE0bt(EpnNq6pKhWjQFQe0GZ7nuXl4V6YSP)qE0bt(EpnNq6pKhWjQFQe0GZ5ENJN7YSP)qE0bt(EpnNq6pKhWjQFQe0GZjNvbzZP)qkzih8aX9n2VmB6pKhDWKV3tZjK(d5bCI6Nkbn4CxKdUubzZvsfIeMmUHuYqxKdETzUIYSP)qE0bt(EpnNq6pKhWjQFQe0GZPbSlsdvq28oFhkA7yAa7I0ipdz20Fip6GjFVNMti9hYd4e1pvcAW5V7ZLBgDz20Fip6GjFVNMti9hYd4e1pvcAW5LF0H8qfKnxjvisyYylkOjuaOICfLzt)H8OdM89EAoH0FipGtu)ujObNBrbnHcavOcYMRKkejmzSff0ekaurEgYSP)qE0bt(EpnNq6pKhWjQFQe0GZhUsEWXjZwMn9hYJoU3qfVG)QdM89a6mCqbbB5HkiBU6hn54WCmrTnhh8cZbjm5fObfew8VnZZukcAqbHf)BJ89j4Q6UDQd(hn54WCmrTnhh8cZbjm5fObfew8VnZZuGRQYSP)qE0X9gQ4f8xDWKVNOFipubzZfaSwmvpfmu0n5cdikZM(d5rh3BOIxWF1bt(EhAWqtQevbzZlGGTE1Y4JhIErtOjvIygCaqII8cKaG1Iz1AiG(H8adics9395Yndmvpfmu0n5cx8GqrpxXD7e8EhKf12CWIhek6BMNPvuvz20Fip64Edv8c(RoyY3BIABUomZbGv7GJtfKnxaWAXu9uWqr3Kl8YndqcawlUacg6wOOBYfE5MbOflayT4Zb(gOBHxddhulcVCZqMn9hYJoU3qfVG)QdM89eOwOBHxHEf6QGS5cawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0X9gQ4f8xDWKVNaxDUuafTQGS5cawlMQNcgk6MCHbeLzt)H8OJ7nuXl4V6GjFpHP7lOfOYsfKnxaWAXu9uWqr3KlmGOmB6pKhDCVHkEb)vhm57zrflmDFPcYMlayTyQEkyOOBYfgquMn9hYJoU3qfVG)QdM89O45(v0e(0CQcYMlayTyQEkyOOBYfgquMn9hYJoU3qfVG)QdM89a6meD8ORcYMlayTyQEkyOOBYfgquMn9hYJoU3qfVG)QdM89a6meD8qf2A5)Gbn482jTq05vhkqRwwfKnxaWAXu9uWqr3KlmG4UDV7ZLBgyQEkyOOBYfU4bHI(g5Gl4cAXcawl(CGVb6w41WWb1IWaIYSP)qE0X9gQ4f8xDWKVhqNHOJhQe0GZ5HywfttOxRGINvbzZF3Nl3mWu9uWqr3KlCXdcf9nZ3VIYSP)qE0X9gQ4f8xDWKVhqNHOJhQe0GZxftllQyOsU35PkiB(7(C5MbMQNcgk6MCHlEqOOVr((vC3oWxjvisyYyse6beOZ5zSBN6hAW5kcsjvisyYyuOKRJxqxKdUYZaubeS1Rwg3rInEa7NxdmdoairrEPQmB6pKhDCVHkEb)vhm57b0zi64Hkbn48UdmHO2aDCPcYM)UpxUzGP6PGHIUjx4Ihek6BKVFf3Td8vsfIeMmMeHEab6CEg72P(HgCUIGusfIeMmgfk564f0f5GR8mavabB9QLXDKyJhW(51aZGdasuKxQkZM(d5rh3BOIxWF1bt(EaDgIoEOsqdoVDMLyd0TqQ3rd0KoKhQGS5V7ZLBgyQEkyOOBYfU4bHI(g57xXD7aFLuHiHjJjrOhqGoNNXUDQFObNRiiLuHiHjJrHsUoEbDro4kpdqfqWwVAzChj24bSFEnWm4aGef5LQYSP)qE0X9gQ4f8xDWKVhqNHOJhQe0GZh0tcfd7nmFWbqh9QGS5V7ZLBgyQEkyOOBYfU4bHI(M5Gli1bFLuHiHjJrHsUoEbDro4kpJD7o0G3iZuuvz20Fip64Edv8c(RoyY3dOZq0XdvcAW5d6jHIH9gMp4aOJEvq28395Yndmvpfmu0n5cx8GqrFZCWfKsQqKWKXOqjxhVGUihCLNbibaRfxabdDlu0n5cdicsaWAXfqWq3cfDtUWfpiu03mx9mumZf4cEUac26vlJ7iXgpG9ZRbMbhaKOiVuf0Hg8MzMIYSLzt)H8OJ5ENJN7GjFpHP7lOBHxdd5GhzPcYM)UpxUzGph4BGUfEnmCqTiCXdcf9CfbjayTyQEky43qvlJ7h9kSzUsQqKWKXNFd4Gud(nu1YDqV7ZLBgyQEkyOOBYfU4bHI(M5T)A3olQT5Gfpiu038DFUCZat1tbdfDtUWfpiu0Lzt)H8OJ5ENJN7GjFpHP7lOBHxdd5GhzPcYM)UpxUzGP6PGHIUjx4Ihek65kcsDW)OjhhMJjQT54GxyoiHjV2Tt9JMCCyoMO2MJdEH5GeM8c0Gccl(3g5zsf3TRZ3HI2oMgWUinYZqvvbPU6V7ZLBg4Zb(gOBHxddhulcx8GqrFdLuHiHjJjr4GudU4jLfi1faSwmvpfm8BOQLX9JEfYfaSwmvpfm8BOQLXdsny)OxHD768DOOTJPbSlsJ8muv1D7u)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsaWAXu9uWWVHQwg3p6vixrvvfKaG1IlGGHUfk6MCHxUzaAqbHf)BJCLuHiHjJjr4afObWaoOGGI)jZM(d5rhZ9ohp3bt(EMEnxkzualU7bfpRcYM)UpxUzGP6PGHIUjx4Ihek6BKdUkc6DFUCZaFoW3aDl8Ay4GAr4Ihek6BM3(lqcawlMQNcg(nu1Y4(rVcBMRKkejmz853aoi1GFdvTCh0rtooCbem0Tqr3KlmhKWKxGE3Nl3mWfqWq3cfDtUWfpiu03mV9xGE3Nl3mWu9uWqr3KlCXdcf9nusfIeMm(8BahKAWfpPSKzt)H8OJ5ENJN7GjFptVMlLmkGf39GINvbzZF3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEf2mxjvisyY4ZVbCqQb)gQA5oO395Yndmvpfmu0n5cx8GqrFZ82FTBNf12CWIhek6B(UpxUzGP6PGHIUjx4Ihek6YSP)qE0XCVZXZDWKVNPxZLsgfWI7EqXZQGS5V7ZLBgyQEkyOOBYfU4bHIEUIGuh8pAYXH5yIABoo4fMdsyYRD7u)OjhhMJjQT54GxyoiHjVanOGWI)TrEMuXD768DOOTJPbSlsJ8muvvqQR(7(C5Mb(CGVb6w41WWb1IWfpiu03qjvisyYyseoi1GlEszbsDbaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vy3UoFhkA7yAa7I0ipdvvD3o1F3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEfYvuvvbjayT4ciyOBHIUjx4LBgGguqyX)2ixjvisyYyseoqbAamGdkiO4FYSP)qE0XCVZXZDWKVxlavlefq3cP9bU8RrfKn)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsaWAXu9uWWVHQwg3p6vyZCLuHiHjJp)gWbPg8BOQL7GE3Nl3mWu9uWqr3KlCXdcf9nZB)1UDwuBZblEqOOV57(C5MbMQNcgk6MCHlEqOOlZM(d5rhZ9ohp3bt(ETauTquaDlK2h4YVgvq28395Yndmvpfmu0n5cx8GqrpxrqQd(hn54WCmrTnhh8cZbjm51UDQF0KJdZXe12CCWlmhKWKxGguqyX)2iptQ4UDD(ou02X0a2fPrEgQQki1v)DFUCZaFoW3aDl8Ay4GAr4Ihek6BOKkejmzmjchKAWfpPSaPUaG1IP6PGHFdvTmUF0RqUaG1IP6PGHFdvTmEqQb7h9kSBxNVdfTDmnGDrAKNHQQUBN6V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqcawlMQNcg(nu1Y4(rVc5kQQQGeaSwCbem0Tqr3Kl8YndqdkiS4FBKRKkejmzmjchOanagWbfeu8pz20Fip6yU3545oyY379454k64f0oPbRYefm8x57tvq2CbaRft1tbdfDtUWl3majayT4ciyOBHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8Yndqdki8Hgm8C4GuBJCwn(bogEOblZM(d5rhZ9ohp3bt(EftIOOfAN0G7QGS5cawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgGguq4dny45WbP2g5SA8dCm8qdwMn9hYJoM7DoEUdM89S(d05fK2h4cDmuGPHkiBUaG1IP6PGHIUjx4LBgGeaSwCbem0Tqr3Kl8YndqlwaWAXNd8nq3cVggoOweE5MHmB6pKhDm37C8Chm57jcuiBwOOfkmP(PcYMlayTyQEkyOOBYfE5MbibaRfxabdDlu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUziZM(d5rhZ9ohp3bt(EfsuCYqua7I0ZQGS5cawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0XCVZXZDWKV31WqGqWbIf061ZQGS5cawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0XCVZXZDWKV3GhELf0TWjWJwWvX0ORcYMlayTyQEkyOOBYfE5MbibaRfxabdDlu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUziZwMn9hYJo2f5GRCLuHiHjRsqdoVHuYqxKdEPIlM35tfL0eGZZqfKnxSyLW2FHZaZk9NoKhGa)ciyRxTmUJeB8a2pVgygCaqII8sMn9hYJo2f5GlWKVNsQqKWKvjObN3qkzOlYbVuXfZ78PIsAcW5zOcYMlayTyQEkyOOBYfE5MbO395Yndmvpfmu0n5cx8GqrFdfbvabB9QLXDKyJhW(51aZGdasuKxYSP)qE0XUihCbM89yL(thYdvq28ciyRxTmUJeB8a2pVgygCaqII8c0rtooCbem0Tqr3KlmhKWKxGE3Nl3mWfqWq3cfDtUWfpiu03qrqQlayT4ciyOBHIUjx4LBg72jwSsy7VWzGP6PGHcuvulRQmB6pKhDSlYbxGjFplQyOWK6NkiBEbeS1RwgVq9hjorbvzbFFmOyHzWbajkYlqcawlEH6psCIcQYc((yqXcAlVFyarz20Fip6yxKdUat(E2Y7hmCLKkiBEbeS1Rwg3wO(mli6r)KXm4aGef5fObfew8VnY8GRmB6pKhDSlYbxGjFVftxJGxbRcYMd(fqWwVAzChj24bSFEnWm4aGef5LmB6pKhDSlYbxGjFVIwikoyxKkfubzZhuqyX)2itROmB6pKhDSlYbxGjFVNINNq6pKhQGS50FipW9gK9qrlu0n5c)nue8efTGA)fU4bHIEUIYSP)qE0XUihCbM896ni7HIwOOBYLkiBE3bMcOyHTiEUGUfkm9E3hDmhKWKxYSP)qE0XUihCbM89O6PGHEjOcYMRKkejmzmkuY1XlOlYbx5za6DFUCZaxabdDlu0n5cx8Gqrpxrz20Fip6yxKdUat(Eu9uWqHj1pvq2CLuHiHjJrHsUoEbDro4kpdqV7ZLBg4ciyOBHIUjx4Ihek65kcsaWAXu9uWWVHQwg3p6vytbaRft1tbd)gQAz8Gud2p6vqMn9hYJo2f5GlWKVxbem0Tqr3Klvq2CLuHiHjJrHsUoEbDro4kpdqcawlUacg6wOOBYfE5MHmB6pKhDSlYbxGjFVftxJGxbRcYMlayT4ciyOBHIUjx4LBgYSP)qE0XUihCbM89gOQ8QdDl88AWXPcYMlayT4ciyOBHIUjx4LBg72jwSsy7VWzGP6PGHcuvullZM(d5rh7ICWfyY37CGVb6w41WWb1IubzZfaSwCbem0Tqr3Kl8YnJD7elwjS9x4mWu9uWqbQkQLLzt)H8OJDro4cm57r1tbdfDtUubzZflwjS9x4mWNd8nq3cVggoOwKmB6pKhDSlYbxGjFVciyOBHIUjxQGS5cawlUacg6wOOBYfE5MHmB6pKhDSlYbxGjFpXI7C8m0TWbkwQGS5lwaWAXNd8nq3cVggoOwegqe0IfaSw85aFd0TWRHHdQfHlEqOOVj9hYdmvpfmCG6D0K7ywn(bogEOblZM(d5rh7ICWfyY3JQNcgkmP(PcYMV8dx0crXb7IuPaU4bHI(gG7UDlwaWAXfTquCWUivkavcmdUib0eDzH7h9kSHIYSP)qE0XUihCbM89O6PGHctQFQGS5cawlwS4ohpdDlCGIfgqe0IfaSw85aFd0TWRHHdQfHbebTybaRfFoW3aDl8Ay4GAr4Ihek6BMt)H8at1tbdfMu)WSA8dCm8qdwMn9hYJo2f5GlWKVhvpfmuGQIAzvq2CbaRfxabdDlu0n5cdicsaWAXfqWq3cfDtUWfpiu03mV9xGeaSwmvpfm8BOQLX9JEfYfaSwmvpfm8BOQLXdsny)Oxbz20Fip6yxKdUat(Eu9uWqbQkQLvbzZfaSwCbem0Tqr3KlmGiO395Yndmvpfmu0n5cx8GqrpxrqdkiS4FBMzkcc8lGGTE1Y4osSXdy)8AGzWbajkYlz20Fip6yxKdUat(Eu9uWqbQkQLvbzZfaSwmvpfmu0n5cdicsaWAXu9uWqr3KlCXdcf9nZB)fibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vqMn9hYJo2f5GlWKVhvpfmCG6D0K7QGS5lwaWAXNd8nq3cVggoOwegqe0rtoomvpfmK)ghZbjm5fibaRfVy6Ae8ky8YndqlwaWAXNd8nq3cVggoOweU4bHI(g0FipWu9uWWbQ3rtUJz14h4y4Hgmi1bFAFGl0XyQEkyOiWyWtu0I5GeM8A3obaRf)tMQN6hkAHFdfbpXl3muvLVHqrEgQWunZc(nekGiBUaG1I)jt1t9dfTWVHIGN4LBgGuxaWAXu9uWqr3KlmG4UDQd(hn54WUsUeDtU4fMdsyYlqQlayT4ciyOBHIUjxyaXD7E3Nl3mWSs)Pd5bUyALLQQQQmB6pKhDSlYbxGjFpQEky4a17Oj3vbzZfaSw8pzQEQFOOfxm9hO395Yndmvpfmu0n5cx8GqrFdfv5BiuKNHmB6pKhDSlYbxGjFpQEky4a17Oj3vbzZfaSw8pzQEQFOOfxm9hibaRf)tMQN6hkAX9JEfYfaSw8pzQEQFOOfpi1G9JEfu5BiuKNHmB6pKhDSlYbxGjFpQEkyOxcQGS5cawlMQNcg(nu1Y4(rVcBMRKkejmz853aoi1GFdvTChK6V7ZLBgyQEkyOOBYfU4bHI(gzO4UD0FiLmKdEG4(M57xvz20Fip6yxKdUat(Eu9uWqHj1pvq2CbaRfxabdDlu0n5cdiUB3Gccl(3gzaUYSP)qE0XUihCbM89yL(thYdvq2CbaRfxabdDlu0n5cVCZqfuCCvaIhezZhuqyX)2iptbUQGIJRcq8GOXGxi648mKzt)H8OJDro4cm57r1tbdfOQOwwMTmB6pKhD87(C5Mrhm57zlVFWWvsQGS5fqWwVAzCBH6ZSGOh9tgZGdasuKxGE3Nl3mWu9uWqr3KlCXdcf9nYmfb9UpxUzGph4BGUfEnmCqTiCXdcf9CfbPUaG1IP6PGHFdvTmUF0RWM5kPcrctgF(nGdsn43qvl3bPU6hn54WfqWq3cfDtUWCqctEb6DFUCZaxabdDlu0n5cx8GqrFZ82Fb6DFUCZat1tbdfDtUWfpiu03qjvisyY4ZVbCqQbx8KYs1D7uh8pAYXHlGGHUfk6MCH5GeM8c07(C5MbMQNcgk6MCHlEqOOVHsQqKWKXNFd4GudU4jLLQ729UpxUzGP6PGHIUjx4Ihek6BM3(lvvntqfPota80kKxOdTpWsnqhfTsDBH6ZSKA0J(jl1MORrQjrSudETZsn6KAt01i1NFdP2VgUmrDglZM(d5rh)UpxUz0bt(E2Y7hmCLKkiBEbeS1Rwg3wO(mli6r)KXm4aGef5fO395Yndmvpfmu0n5cx8GqrpxrqQd(hn54WCmrTnhh8cZbjm51UDQF0KJdZXe12CCWlmhKWKxGguqyX)2iptQOQQcsD1F3Nl3mWNd8nq3cVggoOweU4bHI(gzOiibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vq1D7u)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsaWAXu9uWWVHQwg3p6vixrvvfKaG1IlGGHUfk6MCHxUzaAqbHf)BJCLuHiHjJjr4afObWaoOGGI)jZM(d5rh)UpxUz0bt(E2Y7NGppvq28ciyRxTmEH6psCIcQYc((yqXcZGdasuKxGE3Nl3mWcawlCH6psCIcQYc((yqXcxmTYcKaG1IxO(JeNOGQSGVpguSG2Y7hE5Mbi1faSwmvpfmu0n5cVCZaKaG1IlGGHUfk6MCHxUzaAXcawl(CGVb6w41WWb1IWl3muf07(C5Mb(CGVb6w41WWb1IWfpiu0ZveK6cawlMQNcg(nu1Y4(rVcBMRKkejmz853aoi1GFdvTChK6QF0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nZB)fO395Yndmvpfmu0n5cx8GqrFdLuHiHjJp)gWbPgCXtklv3TtDW)OjhhUacg6wOOBYfMdsyYlqV7ZLBgyQEkyOOBYfU4bHI(gkPcrctgF(nGdsn4INuwQUB37(C5MbMQNcgk6MCHlEqOOVzE7Vuvvz20Fip64395YnJoyY3ZIkgkmP(PcYMxabB9QLXlu)rItuqvwW3hdkwygCaqII8c07(C5MbwaWAHlu)rItuqvwW3hdkw4IPvwGeaSw8c1FK4efuLf89XGIf0IkgVCZaKyXkHT)cNb2wE)e85jZM(d5rh)UpxUz0bt(EduvE1HUfEEn44ubzZF3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEf2mxjvisyY4ZVbCqQb)gQA5oO395Yndmvpfmu0n5cx8GqrFZ82FLjOIuNjaEzAsz1LAGol1duvE1LAt01i1KiwQZCAL6ZVHuJ6sDX0klPM6sTjpNQi1dsbwQ7afl1Nl1p1pPgDsTaB9IL6ZVbwMn9hYJo(DFUCZOdM89gOQ8QdDl88AWXPcYM)UpxUzGP6PGHIUjx4Ihek65kcsDW)OjhhMJjQT54GxyoiHjV2Tt9JMCCyoMO2MJdEH5GeM8c0Gccl(3g5zsfvvvqQR(7(C5Mb(CGVb6w41WWb1IWfpiu03qjvisyYyseoi1GlEszbsaWAXu9uWWVHQwg3p6vixaWAXu9uWWVHQwgpi1G9JEfuD3o1F3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEfYvuvvbjayT4ciyOBHIUjx4LBgGguqyX)2ixjvisyYyseoqbAamGdkiO4FYSP)qE0XV7ZLBgDWKV3IPRrWRGvbzZF3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEf2mxjvisyY4ZVbCqQb)gQA5oO395Yndmvpfmu0n5cx8GqrFZ82FLjOIuNjaEzAsz1LAGol1lMUgbVcwQnrxJutIyPoZPvQp)gsnQl1ftRSKAQl1M8CQIupifyPUduSuFUu)u)KA0j1cS1lwQp)gyz20Fip64395YnJoyY3BX01i4vWQGS5V7ZLBgyQEkyOOBYfU4bHIEUIGuh8pAYXH5yIABoo4fMdsyYRD7u)OjhhMJjQT54GxyoiHjVanOGWI)TrEMurvvfK6Q)UpxUzGph4BGUfEnmCqTiCXdcf9nYqrqcawlMQNcg(nu1Y4(rVc5cawlMQNcg(nu1Y4bPgSF0RGQ72P(7(C5Mb(CGVb6w41WWb1IWfpiu0ZveKaG1IP6PGHFdvTmUF0RqUIQQkibaRfxabdDlu0n5cVCZa0Gccl(3g5kPcrctgtIWbkqdGbCqbbf)tMn9hYJo(DFUCZOdM89kAHO4GDrQuqfKn)DFUCZaFoW3aDl8Ay4GAr4Ihek6BOKkejmzC1Hdsn4INuwGE3Nl3mWu9uWqr3KlCXdcf9nusfIeMmU6WbPgCXtklqQF0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nZB)1UDhn54WfqWq3cfDtUWCqctEb6DFUCZaxabdDlu0n5cx8GqrFdLuHiHjJRoCqQbx8KYA3oW)OjhhUacg6wOOBYfMdsyYlvbjayTyQEky43qvlJ7h9kSX(bTybaRfFoW3aDl8Ay4GAr4LBgzcQi1zcGx7Su3fPsbPgzL6ZVHutXsQjrPMkwQ9qQ)LutXsQn9yFpPwGLAarP26Lup9OLlP(AOqQVgwQhKAs9INuwQi1dsbu0k1DGILAtwQBiLSutNupzQFs9z6snvpfSu)nu1YDPMILuFn0j1NFdP2K6X(EsDMda9tQb68clZM(d5rh)UpxUz0bt(EfTquCWUivkOcYM)UpxUzGph4BGUfEnmCqTiCXdcf9CfbjayTyQEky43qvlJ7h9kSzUsQqKWKXNFd4Gud(nu1YDqV7ZLBgyQEkyOOBYfU4bHI(M5T)ktqfPota8ANL6Uivki1MORrQjrP2SHdPw07DKWKXsDMtRuF(nKAuxQlMwzj1uxQn55ufPEqkWsDhOyP(CP(P(j1OtQfyRxSuF(nWYSP)qE0XV7ZLBgDWKVxrlefhSlsLcQGS5V7ZLBgyQEkyOOBYfU4bHIEUIGuxDW)OjhhMJjQT54GxyoiHjV2Tt9JMCCyoMO2MJdEH5GeM8c0Gccl(3g5zsfvvvqQR(7(C5Mb(CGVb6w41WWb1IWfpiu03qjvisyYyseoi1GlEszbsaWAXu9uWWVHQwg3p6vixaWAXu9uWWVHQwgpi1G9JEfuD3o1F3Nl3mWNd8nq3cVggoOweU4bHIEUIGeaSwmvpfm8BOQLX9JEfYvuvvbjayT4ciyOBHIUjx4LBgGguqyX)2ixjvisyYyseoqbAamGdkiO4FQkZM(d5rh)UpxUz0bt(ENd8nq3cVggoOwKkiB(7(C5MbMQNcgk6MCHlEqOOVj4QiiU354zSsuh5b0TqrUS8FipWdu4LmB6pKhD87(C5Mrhm57DoW3aDl8Ay4GArQGS5cawlMQNcg(nu1Y4(rVcBMRKkejmz853aoi1GFdvTCh0rtooCbem0Tqr3KlmhKWKxGE3Nl3mWfqWq3cfDtUWfpiu03mV9xGE3Nl3mWu9uWqr3KlCXdcf9nusfIeMm(8BahKAWfpPSa9UsoO4WkKvHOaZbjm5fO395YndCrlefhSlsLc4Ihek6BMNPYeurQZeYClRcrb4TudETZs953qQrwPMeLAuxQ9qQ)LutXsQn9yFpPwGLAarP26Lup9OLlP(AOqQVgwQhKAs9INuwyPg8Ye1gsTj6AK6YfLAKvQVgwQpAYXj1OUuFKcCGLAWt3NlPMKAb0j1Nl1dsbwQ7afl1MSu)ui1GNyi1OXGxi64zwsnzpUK6ZVHuZXQlZM(d5rh)UpxUz0bt(ENd8nq3cVggoOwKkiBUaG1IP6PGHFdvTmUF0RWM5kPcrctgF(nGdsn43qvl3bD0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nZB)fO395Yndmvpfmu0n5cx8GqrFdLuHiHjJp)gWbPgCXtklqG)7k5GIdRqwfIcmhKWKxzcQi1zcB7rMRm3YQquaEl1Gx7SuF(nKAKvQjrPg1LApK6Fj1uSKAtp23tQfyPgquQTEj1tpA5sQVgkK6RHL6bPMuV4jLfwQbVmrTHuBIUgPUCrPgzL6RHL6JMCCsnQl1hPahyz20Fip64395YnJoyY37CGVb6w41WWb1IubzZfaSwmvpfm8BOQLX9JEf2mxjvisyY4ZVbCqQb)gQA5oiW)OjhhUacg6wOOBYfMdsyYlqV7ZLBgyQEkyOOBYfU4bHI(gkPcrctgF(nGdsn4INuwYSP)qE0XV7ZLBgDWKV35aFd0TWRHHdQfPcYMlayTyQEky43qvlJ7h9kSzUsQqKWKXNFd4Gud(nu1YDqV7ZLBgyQEkyOOBYfU4bHI(M5T)sMn9hYJo(DFUCZOdM89O6PGHIUjxQGS5V7ZLBg4Zb(gOBHxddhulcx8GqrFdLuHiHjJjr4GudU4jLfibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vaKaG1IlGGHUfk6MCHxUzaAqbHf)BJCLuHiHjJjr4afObWaoOGGI)jZM(d5rh)UpxUz0bt(EfqWq3cfDtUubzZfaSwCbem0Tqr3Kl8YndqV7ZLBg4Zb(gOBHxddhulcx8GqrFdLuHiHjJlxeoi1GlEszbsaWAXu9uWWVHQwg3p6vixaWAXu9uWWVHQwgpi1G9JEfaP(7(C5MbMQNcgk6MCHlEqOOVrgG7UDlwaWAXNd8nq3cVggoOwegqu1mbvK6mbWRDwQlxuQrwP(8Bi1OUu7Hu)lPMILuB6X(EsTal1aIsT1lPE6rlxs91qHuFnSupi1K6fpPSurQhKcOOvQ7afl1xdxSuJ6X(EsnnlMwzj1Kuxabl1l3mKAkws91qNutIsTPh77j1c87dwQjLeAsctwQxafkAL6ciySmB6pKhD87(C5Mrhm57jwCNJNHUfoqXsfKnxaWAXu9uWWVHQwg3p6vixrqVRKdkoSczvikWCqctELjOIuNjK5wwfIcWBPg8edPg1L6bfKu3aeTvwsnflPg8cyZ0DPMkwQp3LAwnro6iLSuFUud0zPw0hs95sDhCayEFGLAkKAwTRiPMeKAui1xdl1NFdP2efl3el1Gh5BF7snqNLA0j1Nl1dsbwQNUPu)nu1Ysn4fW2LAu0pkoSmB6pKhD87(C5Mrhm57jwCNJNHUfoqXsfKnFXcawl(CGVb6w41WWb1IWaIGa)3vYbfhwHSkefyoiHjVYeurQZe22JmxzULvHOa8wQbV2zPw0hs95sDhCayEFGLAkKAwTRiPMeKAui1xdl1NFdP2efl3elZwMn9hYJoU8JoKhGjFpQEkyOavf1YQGS5V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqQlayTyQEky43qvlJ7h9kSHsQqKWKXNFd4Gud(nu1YDqhn54WfqWq3cfDtUWCqctEb6DFUCZaxabdDlu0n5cx8GqrFZ82Fb6DFUCZat1tbdfDtUWfpiu03qjvisyY4ZVbCqQbx8KYc07k5GIdRqwfIcmhKWKxGE3Nl3mWfTquCWUivkGlEqOOVzEMsvz2GhKA6pKhDC5hDipat(EpfppH0FipubzZP)qEGzL(thYd83qrWtu0cAqbHf)BJ8mp4csDWVac26vlJ7iXgpG9ZRbMbhaKOiV2TtaWAXDKyJhW(51a3p6vixaWAXDKyJhW(51api1G9JEfuvMn9hYJoU8JoKhGjFpwP)0H8qfKnFqbHf)BZCLuHiHjJzLou8pqQ)UpxUzGph4BGUfEnmCqTiCXdcf9nZP)qEGzL(thYdmRg)ahdp0G3T7DFUCZat1tbdfDtUWfpiu03mN(d5bMv6pDipWSA8dCm8qdE3o1pAYXHlGGHUfk6MCH5GeM8c07(C5MbUacg6wOOBYfU4bHI(M50FipWSs)Pd5bMvJFGJHhAWQQkibaRfxabdDlu0n5cVCZaKaG1IP6PGHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8YndvqXXvbiEqKnFqbHf)BJ8mp4csDWVac26vlJ7iXgpG9ZRbMbhaKOiV2TtaWAXDKyJhW(51a3p6vixaWAXDKyJhW(51api1G9JEfuvfuCCvaIheng8crhNNHmB6pKhDC5hDipat(ESs)Pd5HkiBEbeS1Rwg3rInEa7NxdmdoairrEb6DFUCZat1tbdfDtUWfpiu03mN(d5bMv6pDipWSA8dCm8qdwMn9hYJoU8JoKhGjFpQEkyOavf1YQGS5V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqQlayTyQEky43qvlJ7h9kSHsQqKWKXNFd4Gud(nu1YDqhn54WfqWq3cfDtUWCqctEb6DFUCZaxabdDlu0n5cx8GqrFZ82Fb6DFUCZat1tbdfDtUWfpiu03qjvisyY4ZVbCqQbx8KYce4)UsoO4WkKvHOaZbjm5LQYSP)qE0XLF0H8am57r1tbdfOQOwwfKn)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsDbaRft1tbd)gQAzC)OxHnusfIeMm(8BahKAWVHQwUdc8pAYXHlGGHUfk6MCH5GeM8c07(C5MbMQNcgk6MCHlEqOOVHsQqKWKXNFd4GudU4jLLQYSP)qE0XLF0H8am57r1tbdfOQOwwfKn)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsDbaRft1tbd)gQAzC)OxHnusfIeMm(8BahKAWVHQwUd6DFUCZat1tbdfDtUWfpiu03mV9xQkZg8GuVnZlP(CPgneN8GJtQ7xH(tQ7m4aWXZDP2lPwaanxsnfsnnpUc6qkzPUHlglZg8Gut)H8OJl)Od5byY3RFf6pyNbhaoEwfKnFXcawlUOfIId2fPsbOsGzWfjGMOllC)OxH8flayT4IwikoyxKkfGkbMbxKaAIUSWdsny)OxbqcawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3mujObNpP(b7IuPaSF0Ra4nvpfmuys9d8MQNcgkqvrTSmB6pKhDC5hDipat(Eu9uWqbQkQLvbzZxSaG1IlAHO4GDrQuaQeygCrcOj6Yc3p6viFXcawlUOfIId2fPsbOsGzWfjGMOll8Gud2p6vaK6cawlMQNcgk6MCHxUzSBNaG1IP6PGHIUjx4Ihek6BM3(lvbPUaG1IlGGHUfk6MCHxUzSBNaG1IlGGHUfk6MCHlEqOOVzE7VuvMn9hYJoU8JoKhGjFpQEkyOWK6NkiB(YpCrlefhSlsLc4Ihek6BaU72TybaRfx0crXb7IuPaujWm4Ieqt0LfUF0RWgkkZM(d5rhx(rhYdWKVhvpfmuys9tfKnxaWAXIf354zOBHduSWaIGwSaG1Iph4BGUfEnmCqTimGiOflayT4Zb(gOBHxddhulcx8GqrFZC6pKhyQEkyOWK6hMvJFGJHhAWYSP)qE0XLF0H8am57r1tbdhOEhn5UkiB(IfaSw85aFd0TWRHHdQfHbebD0KJdt1tbd5VXXCqctEbsaWAXlMUgbVcgVCZaK6lwaWAXNd8nq3cVggoOweU4bHI(g0FipWu9uWWbQ3rtUJz14h4y4Hg8UDV7ZLBgyXI7C8m0TWbkw4Ihek6BO4UDVRKdkoSczvikWCqctEPki1bFAFGl0XyQEkyOiWyWtu0I5GeM8A3obaRf)tMQN6hkAHFdfbpXl3muvLVHqrEgQWunZc(nekGiBUaG1I)jt1t9dfTWVHIGN4LBgGuxaWAXu9uWqr3KlmG4UDQd(hn54WUsUeDtU4fMdsyYlqQlayT4ciyOBHIUjxyaXD7E3Nl3mWSs)Pd5bUyALLQQQQmB6pKhDC5hDipat(Eu9uWWbQ3rtURcYMlayT4FYu9u)qrlUy6pqcawlMvtKIfVGI(XXHOjgquMn9hYJoU8JoKhGjFpQEky4a17Oj3vbzZfaSw8pzQEQFOOfxm9hi1faSwmvpfmu0n5cdiUBNaG1IlGGHUfk6MCHbe3TBXcawl(CGVb6w41WWb1IWfpiu03G(d5bMQNcgoq9oAYDmRg)ahdp0GvvLVHqrEgYSP)qE0XLF0H8am57r1tbdhOEhn5UkiBUaG1I)jt1t9dfT4IP)ajayT4FYu9u)qrlUF0RqUaG1I)jt1t9dfT4bPgSF0RGkFdHI8mKzt)H8OJl)Od5byY3JQNcgoq9oAYDvq2CbaRf)tMQN6hkAXft)bsaWAX)KP6P(HIwCXdcf9nZvxDbaRf)tMQN6hkAX9JEfapt)H8at1tbdhOEhn5oMvJFGJHhAWQcM2FPQkFdHI8mKzt)H8OJl)Od5byY3l4RHl4XdrUFQGS5QxST4Edjm5D7a)d9kGIwvbjayTyQEky43qvlJ7h9kKlayTyQEky43qvlJhKAW(rVcGeaSwmvpfmu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUziZM(d5rhx(rhYdWKVhvpfm0lbvq2CbaRft1tbd)gQAzC)OxHnZvsfIeMm(8BahKAWVHQwUlZM(d5rhx(rhYdWKVxhqKRWvsQGS5dkiS4FBMN5bxqcawlMQNcgk6MCHxUzasaWAXfqWq3cfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0XLF0H8am571Bq2dfTqr3Klvq2CbaRft1tbdfDtUWl3majayT4ciyOBHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8YndqV7ZLBgywP)0H8ax8GqrFdfb9UpxUzGP6PGHIUjx4Ihek6BOiO395Ynd85aFd0TWRHHdQfHlEqOOVHIGuh8pAYXHlGGHUfk6MCH5GeM8A3o1pAYXHlGGHUfk6MCH5GeM8c07(C5MbUacg6wOOBYfU4bHI(gkQQQYSP)qE0XLF0H8am57r1tbdfMu)ubzZfaSwCbmzOBHxtXChdicsaWAXu9uWWVHQwg3p6vyJmtMn9hYJoU8JoKhGjFpQEkyOavf1YQGS5dkiS4FBQKkejmzSavf1YWbfeu8pqV7ZLBgywP)0H8ax8GqrFdfbjayTyQEkyOOBYfE5MbibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vae37C8mwjQJ8a6wOixw(pKh4bk8sMn9hYJoU8JoKhGjFpQEkyOavf1YQGS5V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqQ)UpxUzGlGGHUfk6MCHlEqOONR4UDV7ZLBgyQEkyOOBYfU4bHIEUIQcsaWAXu9uWWVHQwg3p6vixaWAXu9uWWVHQwgpi1G9JEfKzt)H8OJl)Od5byY3JQNcgkqvrTSkiB(Gccl(3M5kPcrctglqvrTmCqbbf)dKaG1IP6PGHIUjx4LBgGeaSwCbem0Tqr3Kl8YndqlwaWAXNd8nq3cVggoOweE5MbibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6va07(C5MbMv6pDipWfpiu03qrz20Fip64Yp6qEaM89O6PGHcuvulRcYMlayTyQEkyOOBYfE5MbibaRfxabdDlu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUzasaWAXu9uWWVHQwg3p6vixaWAXu9uWWVHQwgpi1G9JEfaD0KJdt1tbd9saZbjm5fO395Yndmvpfm0lbCXdcf9nZB)fObfew8VnZZ8kc6DFUCZaZk9NoKh4Ihek6BOOmB6pKhDC5hDipat(Eu9uWqbQkQLvbzZfaSwmvpfmu0n5cdicsaWAXu9uWqr3KlCXdcf9nZB)fibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vqMn9hYJoU8JoKhGjFpQEkyOavf1YQGS5cawlUacg6wOOBYfgqeKaG1IlGGHUfk6MCHlEqOOVzE7VajayTyQEky43qvlJ7h9kKlayTyQEky43qvlJhKAW(rVcYSP)qE0XLF0H8am57r1tbdfOQOwwfKnxaWAXu9uWqr3Kl8YndqcawlUacg6wOOBYfE5MbOflayT4Zb(gOBHxddhulcdicAXcawl(CGVb6w41WWb1IWfpiu03mV9xGeaSwmvpfm8BOQLX9JEfYfaSwmvpfm8BOQLXdsny)Oxbz20Fip64Yp6qEaM89O6PGHctQFYSP)qE0XLF0H8am57Xk9NoKhQGS5cawlUacg6wOOBYfE5MbibaRft1tbdfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0XLF0H8am57r1tbdfOQOwwMn9hYJoU8JoKhGjFpLuHiHjRsqdo3IcAcfaQqfxmVZNkkPjaNNHkiBUaG1IP6PGHFdvTmUF0RqUaG1IP6PGHFdvTmEqQb7h9kac8faSwCbmzOBHxtXChdicYIABoyXdcf9nZvx9bfuMJP)qEGP6PGHctQF437NQGNP)qEGP6PGHctQFywn(bogEObRQmBz20Fip6ylkOjuaOcWKVhvpfmCG6D0K7QGS5cawl(Nmvp1pu0IlM(tLVHqrEgYSP)qE0XwuqtOaqfGjFpQEkyOWK6NmB6pKhDSff0ekaubyY3JQNcgkqvrTSmBz20Fip6yYzWKVNT8(j4ZtfKnVac26vlJxO(JeNOGQSGVpguSWm4aGef5fO395YndSaG1cxO(JeNOGQSGVpguSWftRSajayT4fQ)iXjkOkl47JbflOT8(HxUzasDbaRft1tbdfDtUWl3majayT4ciyOBHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8Yndvb9UpxUzGph4BGUfEnmCqTiCXdcf9CfbPUaG1IP6PGHFdvTmUF0RWM5kPcrctgtodp)gWbPg8BOQL7Gux9JMCC4ciyOBHIUjxyoiHjVa9UpxUzGlGGHUfk6MCHlEqOOVzE7Va9UpxUzGP6PGHIUjx4Ihek6BOKkejmz853aoi1GlEszP6UDQd(hn54WfqWq3cfDtUWCqctEb6DFUCZat1tbdfDtUWfpiu03qjvisyY4ZVbCqQbx8KYs1D7E3Nl3mWu9uWqr3KlCXdcf9nZB)LQQkZM(d5rhtodM89SOIHctQFQGS5QxabB9QLXlu)rItuqvwW3hdkwygCaqII8c07(C5MbwaWAHlu)rItuqvwW3hdkw4IPvwGeaSw8c1FK4efuLf89XGIf0IkgVCZaKyXkHT)cNb2wE)e85P6UDQxabB9QLXlu)rItuqvwW3hdkwygCaqII8c0HgCUIQkZM(d5rhtodM89SL3py4kjvq28ciyRxTmUTq9zwq0J(jJzWbajkYlqV7ZLBgyQEkyOOBYfU4bHI(gzMIGE3Nl3mWNd8nq3cVggoOweU4bHIEUIGuxaWAXu9uWWVHQwg3p6vyZCLuHiHjJjNHNFd4Gud(nu1YDqQR(rtooCbem0Tqr3KlmhKWKxGE3Nl3mWfqWq3cfDtUWfpiu03mV9xGE3Nl3mWu9uWqr3KlCXdcf9nusfIeMm(8BahKAWfpPSuD3o1b)JMCC4ciyOBHIUjxyoiHjVa9UpxUzGP6PGHIUjx4Ihek6BOKkejmz853aoi1GlEszP6UDV7ZLBgyQEkyOOBYfU4bHI(M5T)svvLzt)H8OJjNbt(E2Y7hmCLKkiBEbeS1Rwg3wO(mli6r)KXm4aGef5fO395Yndmvpfmu0n5cx8GqrpxrqQRU6V7ZLBg4Zb(gOBHxddhulcx8GqrFdLuHiHjJjr4GudU4jLfibaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vq1D7u)DFUCZaFoW3aDl8Ay4GAr4Ihek65kcsaWAXu9uWWVHQwg3p6vyZCLuHiHjJjNHNFd4Gud(nu1YDvvfKaG1IlGGHUfk6MCHxUzOQmB6pKhDm5myY37CGVb6w41WWb1IubzZlGGTE1Y4osSXdy)8AGzWbajkYlqIfRe2(lCgywP)0H8qMn9hYJoMCgm57r1tbdfDtUubzZlGGTE1Y4osSXdy)8AGzWbajkYlqQlwSsy7VWzGzL(thYJD7elwjS9x4mWNd8nq3cVggoOwKQYSP)qE0XKZGjFpwP)0H8qfKn)qdEJmtrqfqWwVAzChj24bSFEnWm4aGef5fibaRft1tbd)gQAzC)OxHnZvsfIeMmMCgE(nGdsn43qvl3b9UpxUzGph4BGUfEnmCqTiCXdcf9Cfb9UpxUzGP6PGHIUjx4Ihek6BM3(lz20Fip6yYzWKVhR0F6qEOcYMFObVrMPiOciyRxTmUJeB8a2pVgygCaqII8c07(C5MbMQNcgk6MCHlEqOONRii1vx9395Ynd85aFd0TWRHHdQfHlEqOOVHsQqKWKXKiCqQbx8KYcKaG1IP6PGHFdvTmUF0RqUaG1IP6PGHFdvTmEqQb7h9kO6UDQ)UpxUzGph4BGUfEnmCqTiCXdcf9CfbjayTyQEky43qvlJ7h9kSzUsQqKWKXKZWZVbCqQb)gQA5UQQcsaWAXfqWq3cfDtUWl3muvfuCCvaIhezZfaSwChj24bSFEnW9JEfYfaSwChj24bSFEnWdsny)OxbvqXXvbiEq0yWleDCEgYSP)qE0XKZGjFVbQkV6q3cpVgCCQGS5Q)UpxUzGP6PGHIUjx4Ihek6BKPb3D7E3Nl3mWu9uWqr3KlCXdcf9nZZmvb9UpxUzGph4BGUfEnmCqTiCXdcf9CfbPUaG1IP6PGHFdvTmUF0RWM5kPcrctgtodp)gWbPg8BOQL7Gux9JMCC4ciyOBHIUjxyoiHjVa9UpxUzGlGGHUfk6MCHlEqOOVzE7Va9UpxUzGP6PGHIUjx4Ihek6BaUQUBN6G)rtooCbem0Tqr3KlmhKWKxGE3Nl3mWu9uWqr3KlCXdcf9naxv3T7DFUCZat1tbdfDtUWfpiu03mV9xQQQmB6pKhDm5myY3ROfIId2fPsbvq28395Ynd85aFd0TWRHHdQfHlEqOOVHsQqKWKXvhoi1GlEszb6DFUCZat1tbdfDtUWfpiu03qjvisyY4QdhKAWfpPSaP(rtooCbem0Tqr3KlmhKWKxGE3Nl3mWfqWq3cfDtUWfpiu03mV9x72D0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nusfIeMmU6WbPgCXtkRD7a)JMCC4ciyOBHIUjxyoiHjVufKaG1IP6PGHFdvTmUF0RWM5kPcrctgtodp)gWbPg8BOQL7GwSaG1Iph4BGUfEnmCqTi8Yndz20Fip6yYzWKVxrlefhSlsLcQGS5V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqQlayTyQEky43qvlJ7h9kSzUsQqKWKXKZWZVbCqQb)gQA5oi1v)OjhhUacg6wOOBYfMdsyYlqV7ZLBg4ciyOBHIUjx4Ihek6BM3(lqV7ZLBgyQEkyOOBYfU4bHI(gkPcrctgF(nGdsn4INuwQUBN6G)rtooCbem0Tqr3KlmhKWKxGE3Nl3mWu9uWqr3KlCXdcf9nusfIeMm(8BahKAWfpPSuD3U395Yndmvpfmu0n5cx8GqrFZ82FPQQYSP)qE0XKZGjFVIwikoyxKkfubzZF3Nl3mWu9uWqr3KlCXdcf9CfbPU6Q)UpxUzGph4BGUfEnmCqTiCXdcf9nusfIeMmMeHdsn4INuwGeaSwmvpfm8BOQLX9JEfYfaSwmvpfm8BOQLXdsny)Oxbv3Tt9395Ynd85aFd0TWRHHdQfHlEqOONRiibaRft1tbd)gQAzC)OxHnZvsfIeMmMCgE(nGdsn43qvl3vvvqcawlUacg6wOOBYfE5MHQYSP)qE0XKZGjFVftxJGxbRcYM)UpxUzGP6PGHIUjx4Ihek65kcsD1v)DFUCZaFoW3aDl8Ay4GAr4Ihek6BOKkejmzmjchKAWfpPSajayTyQEky43qvlJ7h9kKlayTyQEky43qvlJhKAW(rVcQUBN6V7ZLBg4Zb(gOBHxddhulcx8GqrpxrqcawlMQNcg(nu1Y4(rVcBMRKkejmzm5m88BahKAWVHQwURQQGeaSwCbem0Tqr3Kl8YndvLzt)H8OJjNbt(ENd8nq3cVggoOwKkiBUaG1IP6PGHFdvTmUF0RWM5kPcrctgtodp)gWbPg8BOQL7Gux9JMCC4ciyOBHIUjxyoiHjVa9UpxUzGlGGHUfk6MCHlEqOOVzE7Va9UpxUzGP6PGHIUjx4Ihek6BOKkejmz853aoi1GlEszP6UDQd(hn54WfqWq3cfDtUWCqctEb6DFUCZat1tbdfDtUWfpiu03qjvisyY4ZVbCqQbx8KYs1D7E3Nl3mWu9uWqr3KlCXdcf9nZB)LQYSP)qE0XKZGjFpQEkyOOBYLkiBU6Q)UpxUzGph4BGUfEnmCqTiCXdcf9nusfIeMmMeHdsn4INuwGeaSwmvpfm8BOQLX9JEfYfaSwmvpfm8BOQLXdsny)Oxbv3Tt9395Ynd85aFd0TWRHHdQfHlEqOONRiibaRft1tbd)gQAzC)OxHnZvsfIeMmMCgE(nGdsn43qvl3vvvqcawlUacg6wOOBYfE5MHmB6pKhDm5myY3Racg6wOOBYLkiBUaG1IlGGHUfk6MCHxUzasD1F3Nl3mWNd8nq3cVggoOweU4bHI(g7xrqcawlMQNcg(nu1Y4(rVc5cawlMQNcg(nu1Y4bPgSF0RGQ72P(7(C5Mb(CGVb6w41WWb1IWfpiu0ZveKaG1IP6PGHFdvTmUF0RWM5kPcrctgtodp)gWbPg8BOQL7QQki1F3Nl3mWu9uWqr3KlCXdcf9nYaC3TBXcawl(CGVb6w41WWb1IWaIQkZM(d5rhtodM89elUZXZq3chOyPcYMlayT4ftxJGxbJbebTybaRfFoW3aDl8Ay4GAryarqlwaWAXNd8nq3cVggoOweU4bHI(M5cawlwS4ohpdDlCGIfEqQb7h9kaEM(d5bMQNcgkmP(Hz14h4y4HgSmB6pKhDm5myY3JQNcgkmP(PcYMlayT4ftxJGxbJbebPU6hn54Wf39GINXCqctEbI(dPKHCWde33mtR6UD0FiLmKdEG4(MGRQGuh8lGGTE1YyQEkyOGpeOAn44Wm4aGef51UDhvT8HByAEnyX)2iZaxvLzt)H8OJjNbt(EDarUcxjjZM(d5rhtodM89O6PGHEjOcYMlayTyQEky43qvlJ7h9kKROmB6pKhDm5myY3l4RHl4XdrUFQGS5QxST4Edjm5D7a)d9kGIwvbjayTyQEky43qvlJ7h9kKlayTyQEky43qvlJhKAW(rVcYSP)qE0XKZGjFVEdYEOOfk6MCPcYMlayTyQEkyOOBYfE5MbibaRfxabdDlu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUza6DFUCZat1tbdfDtUWfpiu03qrqV7ZLBg4Zb(gOBHxddhulcx8GqrFdfbPo4F0KJdxabdDlu0n5cZbjm51UDQF0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nuuvvLzt)H8OJjNbt(Eu9uWWbQ3rtURcYMlayT4FYu9u)qrlUy6pqfqWwVAzmvpfmefwuGUSWm4aGef5fOJMCCyAiorw0thYdmhKWKxGO)qkzih8aX9nZuYSP)qE0XKZGjFpQEky4a17Oj3vbzZfaSw8pzQEQFOOfxm9hi1lGGTE1YyQEkyikSOaDzHzWbajkYRD7oAYXHPH4ezrpDipWCqctEPki6pKsgYbpqCFtWvMn9hYJoMCgm57r1tbdz1eNEh5HkiBUaG1IP6PGHFdvTmUF0RWMcawlMQNcg(nu1Y4bPgSF0RGmB6pKhDm5myY3JQNcgYQjo9oYdvq2CbaRft1tbd)gQAzC)OxHCbaRft1tbd)gQAz8Gud2p6vaKyXkHT)cNbMQNcgkqvrTSmB6pKhDm5myY3JQNcgkqvrTSkiBUaG1IP6PGHFdvTmUF0RqUaG1IP6PGHFdvTmEqQb7h9kiZM(d5rhtodM89yL(thYdvqXXvbiEqKnFqbHf)BJ8mf4QckoUkaXdIgdEHOJZZqMTmBWdsn9hYJoMgWUinYFkEEcP)qEOcYMt)H8aZk9NoKh4VHIGNOOf0Gccl(3g5zEWvMn9hYJoMgWUinat(ESs)Pd5HkiB(Gccl(3M5kPcrctgZkDO4FGu)DFUCZaFoW3aDl8Ay4GAr4Ihek6BMt)H8aZk9NoKhywn(bogEObVB37(C5MbMQNcgk6MCHlEqOOVzo9hYdmR0F6qEGz14h4y4Hg8UDQF0KJdxabdDlu0n5cZbjm5fO395YndCbem0Tqr3KlCXdcf9nZP)qEGzL(thYdmRg)ahdp0GvvvqcawlUacg6wOOBYfE5MbibaRft1tbdfDtUWl3maTybaRfFoW3aDl8Ay4GAr4LBgYSP)qE0X0a2fPbyY3BX01i4vWQGS5V7ZLBgyQEkyOOBYfU4bHIEUIGuxaWAXfqWq3cfDtUWl3maP(7(C5Mb(CGVb6w41WWb1IWfpiu03qjvisyYyseoi1GlEszTB37(C5Mb(CGVb6w41WWb1IWfpiu0ZvuvvLzt)H8OJPbSlsdWKV3avLxDOBHNxdoovq28395Yndmvpfmu0n5cx8GqrpxrqQlayT4ciyOBHIUjx4LBgGu)DFUCZaFoW3aDl8Ay4GAr4Ihek6BOKkejmzmjchKAWfpPS2T7DFUCZaFoW3aDl8Ay4GAr4Ihek65kQQQYSP)qE0X0a2fPbyY3ROfIId2fPsbz20Fip6yAa7I0am571Bq2dfTqr3Klvq2CbaRft1tbdfDtUWl3majayT4ciyOBHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8Yndz20Fip6yAa7I0am57vabdDlu0n5sfKnxaWAXfqWq3cfDtUWl3ma9UpxUzGP6PGHIUjx4Ihek6BOOmB6pKhDmnGDrAaM89oh4BGUfEnmCqTivq2C1F3Nl3mWu9uWqr3KlCXdcf9CfbjayT4ciyOBHIUjx4LBgQUBNyXkHT)cNbUacg6wOOBYLmB6pKhDmnGDrAaM89oh4BGUfEnmCqTivq28395Yndmvpfmu0n5cx8GqrFtWvrqcawlUacg6wOOBYfE5MbiU354zSsuh5b0TqrUS8FipWCqctEjZM(d5rhtdyxKgGjFpQEkyOOBYLkiBUaG1IlGGHUfk6MCHxUza6DFUCZaFoW3aDl8Ay4GAr4Ihek6BOKkejmzmjchKAWfpPSKzt)H8OJPbSlsdWKVhvpfmuGQIAzvq2CbaRft1tbdfDtUWaIGeaSwmvpfmu0n5cx8GqrFZC6pKhyQEky4a17Oj3XSA8dCm8qdgKaG1IP6PGHFdvTmUF0RqUaG1IP6PGHFdvTmEqQb7h9kiZM(d5rhtdyxKgGjFpQEkyOxcQGS5cawlMQNcg(nu1Y4(rVcBkayTyQEky43qvlJhKAW(rVcGeaSwCbem0Tqr3Kl8YndqcawlMQNcgk6MCHxUzaAXcawl(CGVb6w41WWb1IWl3mKzt)H8OJPbSlsdWKVhvpfmuGQIAzvq2CbaRfxabdDlu0n5cVCZaKaG1IP6PGHIUjx4LBgGwSaG1Iph4BGUfEnmCqTi8YndqcawlMQNcg(nu1Y4(rVc5cawlMQNcg(nu1Y4bPgSF0RGmB6pKhDmnGDrAaM89O6PGHduVJMCxfKnxaWAX)KP6P(HIwCX0FQ8nekYZqfMQzwWVHqbezZfaSw8pzQEQFOOf(nue8eVCZaK6cawlMQNcgk6MCHbe3TtaWAXfqWq3cfDtUWaI729UpxUzGzL(thYdCX0klvLzt)H8OJPbSlsdWKVhvpfmCG6D0K7QGS5GpTpWf6ymvpfmueym4jkAXCqctETBNaG1I)jt1t9dfTWVHIGN4LBgQ8nekYZqfMQzwWVHqbezZfaSw8pzQEQFOOf(nue8eVCZaK6cawlMQNcgk6MCHbe3TtaWAXfqWq3cfDtUWaI729UpxUzGzL(thYdCX0klvLzt)H8OJPbSlsdWKVhR0F6qEOcYMlayT4ciyOBHIUjx4LBgGeaSwmvpfmu0n5cVCZa0IfaSw85aFd0TWRHHdQfHxUziZM(d5rhtdyxKgGjFpQEkyOxcQGS5cawlMQNcg(nu1Y4(rVcBkayTyQEky43qvlJhKAW(rVcYSP)qE0X0a2fPbyY3JQNcgkqvrTSmB6pKhDmnGDrAaM89O6PGHctQFYSLzt)H8OJhUsEWXbM89eMOqbifzPcYMpCL8GJdVq9JIN3ipdfLzt)H8OJhUsEWXbM89elUZXZq3chOyjZM(d5rhpCL8GJdm57r1tbdhOEhn5UkiB(WvYdoo8c1pkEEZmuuMn9hYJoE4k5bhhyY3JQNcg6LGmB6pKhD8WvYdooWKVNfvmuys9lzqaxJxjdd0ayshYJ9XISx6sxkb]] )


end
