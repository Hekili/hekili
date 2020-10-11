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

    spec:RegisterResource( Enum.PowerType.Mana, {
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
    } )

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
            max_stack = 3,
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
            duration = 15,
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


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
            -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
            burn_info.__start = 0
        end

        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        fake_mana_gem = nil

        incanters_flow.reset()
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


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
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
        end
    end )


    spec:RegisterVariable( "have_opened", function ()
        if active_enemies > 2 or variable.prepull_evo == 1 then return 1 end
        if state.combat > 0 and action.evocation.lastCast - state.combat > -5 then return 1 end
        return 0
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
                if buff.rule_of_threes.up then return 0 end
                return buff.clearcasting.up and 0 or 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            start = function ()
                if buff.rule_of_threes.up then removeBuff( "rule_of_threes" )
                else
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeStack( "clearcasting" ) end
                end

                if conduit.arcane_prodigy.enabled and cooldown.arcane_power.remains > 0 then
                    reduceCooldown( "arcane_power", conduit.arcane_prodigy.mod * 0.1 )
                end
            end,
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
            cast = 6,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,

            start = function ()
                stop_burn_phase()
                applyBuff( "evocation" )
                if azerite.brain_storm.enabled then
                    gain( 2, "arcane_charges" )
                    applyBuff( "brain_storm" ) 
                end
            end,
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
            cast = function () return 4 * haste * ( 1 - ( conduit.discipline_of_the_grove.mod * 0.01 ) ) end,
            channeled = true,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3636841,

            toggle = "essences",

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
                    duration = function () return 4 * haste * ( 1 - ( conduit.discipline_of_the_grove.mod * 0.01 ) ) end,
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
        order = 1,
    } )

    
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


    spec:RegisterPack( "Arcane", 20201008.1, [[d4uLGdqikO6ree0LiivsBIaFIcvnksOtrISkkOOELcvZIe1TOGISlq)sHyyuGJPqAzuqEgfkMgfu6AeKSnkuX3iiLXrqKZrHkTocczEkuUNOAFIsoibPQfkr1djiuMibbkUibbk9rkOGgjbbQ6KeeLwjfYljivQzsqa3KGuj2PeLFsqGmuccuzPeeQEkjnvrPUkfuOVsbfySeev7vK)IQbtQdJSyGESQMSIUm0MP0NvWOLWPrz1eefVMGA2s62k1Uf(nvdNqhNcLwUupxjtxLRdy7IIVtrJxI48sKwpbPI5tc2prNgnLDsDshMkZqgyidg1adesqdmyuJzuJts9kvetQI0lmnGj1G2ysvOVFkWKQivA1Pzk7K6Yb6htQf3jUeIgzKb2vaacFFpYITbQ0X84BYEJSy7FKKkiaREczJeysDshMkZqgyidg1adeAqdzmgwJRXiuj1Li(PYmogkPwWMtmsGj1jU(KQqOul03pfOul0fAaLgjek1cb9NdITul0uwQnKbgYGKALTUvk7KQlIb2PStLnAk7KkgeyfNPYtQFZoSzusfeWAHu)uGCr3eB40ndPwGudcyTWgiqUB5IUj2WPBgsTaPEIGawl8CGVG7w(vG8nnWGt3msQ0FmpsQv2qXT4czaMdBmU0LkZqPStQyqGvCMkpP(n7WMrjvqaRfs9tbYfDtSHt3mKAbsniG1cBGa5ULl6MydNUzi1cK6jccyTWZb(cUB5xbY30adoDZiPs)X8iPcsdC3YVM9cVsxQmJjLDsfdcSIZu5j1Vzh2mkPccyTqQFkqUOBIneqmPs)X8iPcSqo7W9kDPYmSPStQyqGvCMkpP(n7WMrjvqaRfs9tbYfDtSHaIjv6pMhjvqSxylmlgsxQmHkLDsfdcSIZu5j1Vzh2mkPccyTqQFkqUOBIneqmPs)X8iPcwDFYTaDPPlvMXjLDsfdcSIZu5j1Vzh2mkPccyTqQFkqUOBIneqmPs)X8iPAzncwDFMUuzcTu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qaXKk9hZJKkfpUUMQ8NQ10LktiLYoPIbbwXzQ8K63SdBgLuBGaTEpGWjB9mXklOUu(77nftiASamrrCk1cKAqaRfozRNjwzb1LYFFVPyYTTVoiGysL(J5rs1YAKdwP1LUuzg3u2jvmiWkotLNu)MDyZOKAdeO17beo0SvTuo7zFfHOXcWefXPulqQ3uqqX)K6SKAJRqLuP)yEKuTTVoE4zO0LkBudszNuP)yEKu3SU9EXDl)8EJXLuXGaR4mvE6sLn6OPStQ0FmpsQtKUcqVdmPIbbwXzQ80LkBudLYoPIbbwXzQ8K63SdBgLu3uqqX)K6SKAdRbjv6pMhj1MMmko(sKAHtxQSrnMu2jvmiWkotLNu)MDyZOKk9hZd4QGzpwmWfDtSHFbfbwzXqsL(J5rs9P4XkN(J5r6sLnQHnLDsfdcSIZu5j1Vzh2mkPUCGkilMqldRtUB5GvFT89cIbbwXzsL(J5rsDvWShlg4IUj2Plv2Ocvk7Kk9hZJK65aFb3T8Ra5BAGLuXGaR4mvE6sLnQXjLDsL(J5rsL6NcKl6MyNuXGaR4mvE6sLnQqlLDsfdcSIZu5j1Vzh2mkPccyTWgiqUB5IUj2WPBgjv6pMhj1giqUB5IUj2Plv2OcPu2jvmiWkotLNu)MDyZOKQIs9rvmoigv2qXHboHyqGvCk1cK6nfeu8pPESCPwizGulqQ3uqqX)K6SYLAJJqj1kj1kOGuROuB4s9rvmoigv2qXHboHyqGvCk1cK6nfeu8pPESCPwijusTsjv6pMhj1nfeFa3Plv2Og3u2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qaXKk9hZJKki2lSfMfdPlvMHmiLDsfdcSIZu5j1Vzh2mkP2abA9EaHhUf9MQCtQfHOXcWefXzsL(J5rs9yBKBsTy6sLzOrtzNuXGaR4mvEs9B2HnJsQteeWAHNd8fC3YVcKVPbgequQfi1teeWAHNd8fC3YVcKVPbgSXnXILupwUudcyTqXgxy8i3T8nlMWnvcFD0lSuBywQP)yEaP(Pa5GvADqSe8boKFSnMuP)yEKufBCHXJC3Y3SyMUuzgYqPStQyqGvCMkpP(n7WMrj1PFWMMmko(sKAHHnUjwSK6SKAHsQvqbPEIGawlSPjJIJVePwyEgGAGnbYQSRu46OxyPolP2GKk9hZJKk1pfihSsRlDPYmKXKYoPIbbwXzQ8K63SdBgLubbSwOyJlmEK7w(MftiGOulqQNiiG1cph4l4ULFfiFtdmiGOulqQNiiG1cph4l4ULFfiFtdmyJBIflPESCPM(J5bK6NcKdwP1bXsWh4q(X2ysL(J5rsL6NcKdwP1LUuzgYWMYoPIbbwXzQ8K63SdBgLubbSwi1pfix0nXgcik1cKAqaRfs9tbYfDtSHnUjwSK6XYL6HFk1cKAqaRfs9tbY)cQhq46OxyPoxQbbSwi1pfi)lOEaHBQe(6Ox4Kk9hZJKk1pfihK6MgW0LkZqcvk7KkgeyfNPYtQFbXIK6Oj1Vzh2mkPorqaRfEoWxWDl)kq(MgyqarPwGuFufJds9tbYXVWHyqGvCk1cKAqaRfor6ka9oq40ndPwGuprqaRfEoWxWDl)kq(MgyWg3elwsDwsn9hZdi1pfiFZwlwfxqSe8boKFSnMuP)yEKuP(Pa5B2AXQ4kDPYmKXjLDsfdcSIZu5j1VGyrsD0K63SdBgLubbSw4xrQFADSya2i9xsL(J5rsL6NcKVzRfRIR0LkZqcTu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5Fb1diCD0lSupwUuBiPwGuROu)UxNUzaP(Pa5IUj2Wg3elwsDws9Ogi1kOGut)XYGCmWndxs9y5sTHKALsQ0FmpsQu)uGCVbtxQmdjKszNuXGaR4mvEs9B2HnJsQGawlSbcK7wUOBInequQvqbPEtbbf)tQZsQhvOsQ0FmpsQu)uGCWkTU0LkZqg3u2jvmiWkotLNuP)yEKuXm(thZJKkloSBaXJZSj1nfeu8VSYfscvsLfh2nG4Xz7noz0Hj1rtQFZoSzusfeWAHnqGC3YfDtSHt3msxQmJXGu2jv6pMhjvQFkqoi1nnGjvmiWkotLNU0LuX1cJhxPStLnAk7KkgeyfNPYtQFZoSzus9DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQbbSwi1pfi)lOEaHRJEHL6XYLAdj1cK63960ndi1pfix0nXg24MyXsQhlxQh(PuRGcs9r9aEWJTr(58jdL6XK63960ndi1pfix0nXg24MyXkPs)X8iPcwDFYDl)kqog4U00LkZqPStQyqGvCMkpP(n7WMrj13960ndi1pfix0nXg24MyXsQZLAdKAbsTIsTHl1hvX4Gyuzdfhg4eIbbwXPuRGcsTIs9rvmoigv2qXHboHyqGvCk1cK6nfeu8pPoRCPwOzGuRKuRKulqQvuQvuQF3Rt3mGNd8fC3YVcKVPbgSXnXILuNLupQbsTaPgeWAHu)uG8VG6beUo6fwQZLAqaRfs9tbY)cQhq4MkHVo6fwQvsQvqbPwrP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQbbSwi1pfi)lOEaHRJEHL6CP2aPwjPwjPwGudcyTWgiqUB5IUj2WPBgsTaPEtbbf)tQZkxQZqnJaRiKe5BwW2aB(McIl(xsL(J5rsfS6(K7w(vGCmWDPPlvMXKYoPIbbwXzQ8K63SdBgLuF3Rt3mGNd8fC3YVcKVPbgSXnXILuNl1gi1cKAqaRfs9tbY)cQhq46OxyPESCP2qsTaP(DVoDZas9tbYfDtSHnUjwSK6XYL6HFk1kOGuFupGh8yBKFoFYqPEmP(DVoDZas9tbYfDtSHnUjwSsQ0FmpsQMExNzqwWBC5bfpMUuzg2u2jvmiWkotLNu)MDyZOK67ED6MbK6NcKl6MydBCtSyj15sTbsTaPwrP2WL6JQyCqmQSHIddCcXGaR4uQvqbPwrP(OkgheJkBO4WaNqmiWkoLAbs9Mcck(NuNvUul0mqQvsQvsQfi1kk1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZsQh1aPwGudcyTqQFkq(xq9acxh9cl15sniG1cP(Pa5Fb1diCtLWxh9cl1kj1kOGuROu)UxNUzaph4l4ULFfiFtdmyJBIflPoxQnqQfi1GawlK6NcK)fupGW1rVWsDUuBGuRKuRKulqQbbSwydei3TCr3eB40ndPwGuVPGGI)j1zLl1zOMrGvesI8nlyBGnFtbXf)lPs)X8iPA6DDMbzbVXLhu8y6sLjuPStQyqGvCMkpP(n7WMrj13960nd45aFb3T8Ra5BAGbBCtSyj15sTbsTaPgeWAHu)uG8VG6beUo6fwQhlxQnKulqQF3Rt3mGu)uGCr3eByJBIflPESCPE4NsTcki1h1d4bp2g5NZNmuQhtQF3Rt3mGu)uGCr3eByJBIfRKk9hZJK6aa1tgfC3YjHoy7xr6sLzCszNuXGaR4mvEs9B2HnJsQV71PBgqQFkqUOBInSXnXILuNl1gi1cKAfLAdxQpQIXbXOYgkomWjedcSItPwbfKAfL6JQyCqmQSHIddCcXGaR4uQfi1BkiO4FsDw5sTqZaPwjPwjPwGuROuROu)UxNUzaph4l4ULFfiFtdmyJBIflPolPEudKAbsniG1cP(Pa5Fb1diCD0lSuNl1GawlK6NcK)fupGWnvcFD0lSuRKuRGcsTIs97ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGudcyTqQFkq(xq9acxh9cl15sTbsTssTssTaPgeWAHnqGC3YfDtSHt3mKAbs9Mcck(NuNvUuNHAgbwrijY3SGTb28nfex8VKk9hZJK6aa1tgfC3YjHoy7xr6sLj0szNuXGaR4mvEsL(J5rs994X4A6Wj3wPnMu)MDyZOKkiG1cP(Pa5IUj2WPBgsTaPgeWAHnqGC3YfDtSHt3mKAbs9ebbSw45aFb3T8Ra5BAGbNUzi1cK6nfe8yBKFoFtLi1zLl1yj4dCi)yBmPwzbY)zs14KUuzcPu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2WPBgsTaPgeWAHnqGC3YfDtSHt3mKAbs9ebbSw45aFb3T8Ra5BAGbNUzi1cK6nfe8yBKFoFtLi1zLl1yj4dCi)yBmPs)X8iP2ijYIbUTsBCLUuzg3u2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2WPBgsTaPgeWAHnqGC3YfDtSHt3mKAbs9ebbSw45aFb3T8Ra5BAGbNUzKuP)yEKuT(dSWjNe6Gn7qois70LkBudszNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydNUzi1cKAqaRf2abYDlx0nXgoDZqQfi1teeWAHNd8fC3YVcKVPbgC6MrsL(J5rsveOz2szXahSsRlDPYgD0u2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2WPBgsTaPgeWAHnqGC3YfDtSHt3mKAbs9ebbSw45aFb3T8Ra5BAGbNUzKuP)yEKuBMOyf5SGVePhtxQSrnuk7KkgeyfNPYtQFZoSzusfeWAHu)uGCr3eB40ndPwGudcyTWgiqUB5IUj2WPBgsTaPEIGawl8CGVG7w(vG8nnWGt3msQ0FmpsQxbYbcqhiMCR3pMUuzJAmPStQyqGvCMkpP(n7WMrjvqaRfs9tbYfDtSHt3mKAbsniG1cBGa5ULl6MydNUzi1cK6jccyTWZb(cUB5xbY30adoDZiPs)X8iPUXT3LYDlVc8SjF2iTxPlDj12p6yEKYov2OPStQyqGvCMkpP6Ij1fEjv6pMhj1muZiWkMuZqvamPoAs9B2HnJsQGawlK6NcK)fupGW1rVWsDUudcyTqQFkq(xq9ac3uj81rVWsTaP2WLAqaRf2avK7w(v0iUGaIsTaP(OEap4X2i)C(KHs9y5sTIsTIs9McsQf6Qut)X8as9tbYbR06GVVoPwjP2WSut)X8as9tbYbR06Gyj4dCi)yBuQvkPMHAEqBmPAzbv5GaDKUuzgkLDsfdcSIZu5j1Vzh2mkPorqaRf20KrXXxIulmpdqnWMazv2vkCD0lSuNl1teeWAHnnzuC8Li1cZZaudSjqwLDLc3uj81rVWsTaPwrPgeWAHnqGC3YfDtSHt3mKAfuqQbbSwydei3TCr3eByJBIflPESCPE4NsTsjv6pMhjvQFkqoi1nnGPlvMXKYoPIbbwXzQ8K63SdBgLuN(bBAYO44lrQfg24MyXsQZsQfkPwbfK6jccyTWMMmko(sKAH5zaQb2eiRYUsHRJEHL6SKAdsQ0FmpsQu)uGCWkTU0LkZWMYoPIbbwXzQ8K63SdBgLubbSwOyJlmEK7w(MftiGOulqQNiiG1cph4l4ULFfiFtdmiGOulqQNiiG1cph4l4ULFfiFtdmyJBIflPESCPM(J5bK6NcKdwP1bXsWh4q(X2ysL(J5rsL6NcKdwP1LUuzcvk7KkgeyfNPYtQFbXIK6Oj1Vzh2mkPorqaRfEoWxWDl)kq(MgyqarPwGuFufJds9tbYXVWHyqGvCk1cKAqaRfor6ka9oq40ndPwGuROuprqaRfEoWxWDl)kq(MgyWg3elwsDwsn9hZdi1pfiFZwlwfxqSe8boKFSnk1kOGu)UxNUzafBCHXJC3Y3SycBCtSyj1zj1gi1kOGu)EgmO4GcxAZOqQvkPs)X8iPs9tbY3S1IvXv6sLzCszNuXGaR4mvEs9B2HnJsQGawl8Ri1pTowmaBK(tQfi1GawlelrKIjo5I(HXXOkeqmPs)X8iPs9tbY3S1IvXv6sLj0szNuXGaR4mvEs9liwKuhnP(n7WMrjvqaRf(vK6NwhlgGns)j1cKAfLAqaRfs9tbYfDtSHaIsTcki1GawlSbcK7wUOBInequQvqbPEIGawl8CGVG7w(vG8nnWGnUjwSK6SKA6pMhqQFkq(MTwSkUGyj4dCi)yBuQvkPs)X8iPs9tbY3S1IvXv6sLjKszNuXGaR4mvEs9liwKuhnP(n7WMrjvqaRf(vK6NwhlgGns)j1cKAqaRf(vK6NwhlgGRJEHL6CPgeWAHFfP(P1XIb4MkHVo6foPs)X8iPs9tbY3S1IvXv6sLzCtzNuXGaR4mvEs9liwKuhnP(n7WMrjvqaRf(vK6NwhlgGns)j1cKAqaRf(vK6NwhlgGnUjwSK6XYLAfLAfLAqaRf(vK6NwhlgGRJEHLAdZsn9hZdi1pfiFZwlwfxqSe8boKFSnk1kj1Jl1d)uQvkPs)X8iPs9tbY3S1IvXv6sLnQbPStQyqGvCMkpP(n7WMrjvfL6gTnUkiWkk1kOGuB4s9XEHzXGuRKulqQbbSwi1pfi)lOEaHRJEHL6CPgeWAHu)uG8VG6beUPs4RJEHLAbsniG1cP(Pa5IUj2WPBgsTaPEIGawl8CGVG7w(vG8nnWGt3msQ0FmpsQbEfyZpClIRlDPYgD0u2jvmiWkotLNu)MDyZOKkiG1cP(Pa5Fb1diCD0lSupwUuBOKk9hZJKk1pfi3BW0LkBudLYoPIbbwXzQ8K63SdBgLu3uqqX)K6XYLAJRqj1cKAqaRfs9tbYfDtSHt3mKAbsniG1cBGa5ULl6MydNUzi1cK6jccyTWZb(cUB5xbY30adoDZiPs)X8iPUaeXo8mu6sLnQXKYoPIbbwXzQ8K63SdBgLubbSwi1pfix0nXgoDZqQfi1GawlSbcK7wUOBInC6MHulqQNiiG1cph4l4ULFfiFtdm40ndPwGu)UxNUzaXm(thZdyJBIflPolP2aPwGu)UxNUzaP(Pa5IUj2Wg3elwsDwsTbsTaP(DVoDZaEoWxWDl)kq(MgyWg3elwsDwsTbsTaPwrP2WL6JQyCWgiqUB5IUj2qmiWkoLAfuqQvuQpQIXbBGa5ULl6MydXGaR4uQfi1V71PBgWgiqUB5IUj2Wg3elwsDwsTbsTssTsjv6pMhj1vbZESyGl6MyNUuzJAytzNuXGaR4mvEs9B2HnJsQGawlSbQi3T8ROrCbbeLAbsniG1cP(Pa5Fb1diCD0lSuNLuBmjv6pMhjvQFkqoyLwx6sLnQqLYoPIbbwXzQ8K63SdBgLu3uqqX)K6XK6muZiWkcbPUPbKVPG4I)j1cK63960ndiMXF6yEaBCtSyj1zj1gi1cKAqaRfs9tbYfDtSHt3mKAbsniG1cP(Pa5Fb1diCD0lSuNl1GawlK6NcK)fupGWnvcFD0lSulqQX1cJhHzylMhC3YfX2I)X8aUzH3jv6pMhjvQFkqoi1nnGPlv2OgNu2jvmiWkotLNu)MDyZOK67ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGuROu)UxNUzaBGa5ULl6MydBCtSyj15sTbsTcki1V71PBgqQFkqUOBInSXnXILuNl1gi1kj1cKAqaRfs9tbY)cQhq46OxyPoxQbbSwi1pfi)lOEaHBQe(6Ox4Kk9hZJKk1pfihK6MgW0LkBuHwk7KkgeyfNPYtQFZoSzusDtbbf)tQhlxQZqnJaRieK6Mgq(McIl(NulqQbbSwi1pfix0nXgoDZqQfi1GawlSbcK7wUOBInC6MHulqQNiiG1cph4l4ULFfiFtdm40ndPwGudcyTqQFkq(xq9acxh9cl15sniG1cP(Pa5Fb1diCtLWxh9cl1cK63960ndiMXF6yEaBCtSyj1zj1gKuP)yEKuP(Pa5Gu30aMUuzJkKszNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydNUzi1cKAqaRf2abYDlx0nXgoDZqQfi1teeWAHNd8fC3YVcKVPbgC6MHulqQbbSwi1pfi)lOEaHRJEHL6CPgeWAHu)uG8VG6beUPs4RJEHLAbs9rvmoi1pfi3BqigeyfNsTaP(DVoDZas9tbY9ge24MyXsQhlxQh(PulqQ3uqqX)K6XYLAJRbsTaP(DVoDZaIz8NoMhWg3elwsDwsTbjv6pMhjvQFkqoi1nnGPlv2Og3u2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qarPwGudcyTqQFkqUOBInSXnXILupwUup8tPwGudcyTqQFkq(xq9acxh9cl15sniG1cP(Pa5Fb1diCtLWxh9cNuP)yEKuP(Pa5Gu30aMUuzgYGu2jvmiWkotLNu)MDyZOKkiG1cBGa5ULl6MydbeLAbsniG1cBGa5ULl6MydBCtSyj1JLl1d)uQfi1GawlK6NcK)fupGW1rVWsDUudcyTqQFkq(xq9ac3uj81rVWjv6pMhjvQFkqoi1nnGPlvMHgnLDsL(J5rsL6NcKdwP1LuXGaR4mvE6sLzidLYoPYId7gq84mBsDtbbf)lRCHKqLuzXHDdiEC2EJtgDysD0Kk9hZJKkMXF6yEKuXGaR4mvE6sLziJjLDsL(J5rsL6NcKdsDtdysfdcSIZu5PlDj1jAjG6LYov2OPStQyqGvCMkpP(n7WMrj1J6b8GteeWAHpTowmaBK(lPs)X8iP(oqCyVeXAnDPYmuk7KkgeyfNPYtQ0FmpsQpvRC6pMh8kBDj1kBD8G2ysfxlmECLUuzgtk7KkgeyfNPYtQFZoSzusL(JLb5yGBgUK6SKAdLuP)yEKuFQw50Fmp4v26sQv264bTXKk5y6sLzytzNuXGaR4mvEs9B2HnJsQzOMrGvewqzqUlIboL6CP2GKk9hZJK6t1kN(J5bVYwxsTYwhpOnMuDrmWoDPYeQu2jvmiWkotLNuP)yEKuFQw50Fmp4v26sQv264bTXK67ED6MXkDPYmoPStQyqGvCMkpP(n7WMrj1muZiWkcTSGQCqGoK6CP2GKk9hZJK6t1kN(J5bVYwxsTYwhpOnMuB)OJ5r6sLj0szNuXGaR4mvEs9B2HnJsQzOMrGveAzbv5GaDi15s9Ojv6pMhj1NQvo9hZdELTUKALToEqBmPAzbv5GaDKUuzcPu2jvmiWkotLNuP)yEKuFQw50Fmp4v26sQv264bTXK62ZGBmU0LUKQyJVVbPlLDQSrtzNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQays1GKAgQ5bTXKQyJIa1khZ4PlvMHszNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQaysD0K63SdBgLuBGaTEpGWftSWd(68EdrJfGjkItPwGut)XYGCmWndxsDwsTHsQzOMh0gtQInkcuRCmJNUuzgtk7KkgeyfNPYtQUysDHxsL(J5rsnd1mcSIj1mufatQJMu)MDyZOKAdeO17beUyIfEWxN3BiASamrrCk1cK63ZGbfhmWV9Q3tPwGut)XYGCmWndxsDws9Oj1muZdAJjvXgfbQvoMXtxQmdBk7KkgeyfNPYtQUysDHxsL(J5rsnd1mcSIj1mufatQJMu)MDyZOKAdeO17beUyIfEWxN3BiASamrrCk1cK63ZGbfhmydfh3sysnd18G2ysvSrrGALJz80LktOszNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQays1GKAgQ5bTXKQLfuLdc0r6sLzCszNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQaysvOsQzOMh0gtQ9IVPs4tSsLMUuzcTu2jvmiWkotLNuDXK6cVKk9hZJKAgQzeyftQzOkaMuh1GKAgQ5bTXKkjY3uj8jwPstxQmHuk7KkgeyfNPYtQUysDHxsL(J5rsnd1mcSIj1mufatQgYGKAgQ5bTXKA7I8nvcFIvQ00LkZ4MYoPIbbwXzQ8KQlMux4LuP)yEKuZqnJaRysndvbWKQqLuZqnpOnMup)28nvcFIvQ00LkBudszNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQays1ysQFZoSzusTbc069acNS1ZeRSG6s5VV3umHOXcWefXzsnd18G2ys98BZ3uj8jwPstxQSrhnLDsfdcSIZu5jvxmPUWlPs)X8iPMHAgbwXKAgQcGj1rfQK63SdBgLuFpdguCWGnuCClHj1muZdAJj1ZVnFtLWNyLknDPYg1qPStQyqGvCMkpP6Ij1fEjv6pMhj1muZiWkMuZqvamPoQqLu)MDyZOK67XeGDqQFkqUy7t2qPqmiWkoLAbsn9hldYXa3mCj1Jj1gtsnd18G2ys98BZ3uj8jwPstxQSrnMu2jvmiWkotLNuDXK6cVKk9hZJKAgQzeyftQzOkaMungdsQFZoSzusfxlmEeMHTyEWDlxeBl(hZd4MfENuZqnpOnMup)28nvcFIvQ00LkBudBk7KkgeyfNPYtQUysDHxsL(J5rsnd1mcSIj1mufatQgxdsQzOMh0gtQGu30aY3uqCX)sxQSrfQu2jvmiWkotLNuDXK6cVKk9hZJKAgQzeyftQzOkaMufsgKu)MDyZOK67zWGIdgSHIJBjmPMHAEqBmPcsDtdiFtbXf)lDPYg14KYoPIbbwXzQ8KQlMux4LuP)yEKuZqnJaRysndvbWKQXyqsnd18G2ysLe5BwW2aB(McIl(x6sLnQqlLDsfdcSIZu5jvxmPUWlPs)X8iPMHAgbwXKAgQcGjvHYGK63SdBgLuBGaTEpGWjB9mXklOUu(77nftiASamrrCMuZqnpOnMujr(MfSnWMVPG4I)LUuzJkKszNuXGaR4mvEs1ftQl8sQ0FmpsQzOMrGvmPMHQaysvOmiP(n7WMrj1giqR3diCOzRAPC2Z(kcrJfGjkIZKAgQ5bTXKkjY3SGTb28nfex8V0LkBuJBk7KkgeyfNPYtQUysDHxsL(J5rsnd1mcSIj1mufatQgkPMHAEqBmPsoYp)28VG6bCLUuzgYGu2jvmiWkotLNUuzgA0u2jvmiWkotLNUuzgYqPStQyqGvCMkpDPYmKXKYoPs)X8iPUa2Bp4u)uGClTzvg1jvmiWkotLNUuzgYWMYoPs)X8iPs9tbYzXH1k(xsfdcSIZu5PlvMHeQu2jv6pMhj13dHmanY3uq8bCNuXGaR4mvE6sLziJtk7KkgeyfNPYtxQmdj0szNuP)yEKu3SU9MZ20aMuXGaR4mvE6sLziHuk7Kk9hZJKQOFmpsQyqGvCMkpDPYmKXnLDsfdcSIZu5j1Vzh2mkPMHAgbwrOyJIa1khZ4sDUuBqsL(J5rs12(6a96LUuzgJbPStQyqGvCMkpP(n7WMrj1muZiWkcfBueOw5ygxQZL6rtQ0FmpsQyg)PJ5r6sxs9DVoDZyLYov2OPStQyqGvCMkpP(n7WMrjvqaRfs9tbYfDtSHt3mKAbsniG1cBGa5ULl6MydNUzi1cK6jccyTWZb(cUB5xbY30adoDZiPs)X8iPwzdf3IlKbyoSX4sxQmdLYoPIbbwXzQ8K63SdBgLubbSwi1pfix0nXgoDZqQfi1GawlSbcK7wUOBInC6MHulqQNiiG1cph4l4ULFfiFtdm40nJKk9hZJKkinWDl)A2l8kDPYmMu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qaXKk9hZJKkWc5Sd3R0LkZWMYoPIbbwXzQ8K63SdBgLubbSwi1pfix0nXgciMuP)yEKubXEHTWSyiDPYeQu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qaXKk9hZJKky19j3c0LMUuzgNu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2qaXKk9hZJKQL1iy19z6sLj0szNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydbetQ0FmpsQu846AQYFQwtxQmHuk7KkgeyfNPYtQFZoSzusTbc069achA2QwkN9SVIq0ybyII4uQfi1V71PBgqQFkqUOBInSXnXILuNLuBmgi1cK63960nd45aFb3T8Ra5BAGbBCtSyj15sTbsTaPwrPgeWAHu)uG8VG6beUo6fwQhlxQnKulqQvuQvuQpQIXbBGa5ULl6MydXGaR4uQfi1V71PBgWgiqUB5IUj2Wg3elws9y5s9WpLAbs97ED6MbK6NcKl6MydBCtSyj1zj1zOMrGveE(T5BQe(eRuPsTssTcki1kk1gUuFufJd2abYDlx0nXgIbbwXPulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWZVnFtLWNyLkvQvsQvqbP(DVoDZas9tbYfDtSHnUjwSK6XYL6HFk1kj1kLuP)yEKuTTVoE4zO0LkZ4MYoPIbbwXzQ8K63SdBgLuBGaTEpGWHMTQLYzp7RienwaMOioLAbs97ED6MbK6NcKl6MydBCtSyj15sTbsTaPwrP2WL6JQyCqmQSHIddCcXGaR4uQvqbPwrP(OkgheJkBO4WaNqmiWkoLAbs9Mcck(NuNvUul0mqQvsQvsQfi1kk1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZsQh1aPwGudcyTqQFkq(xq9acxh9cl15sniG1cP(Pa5Fb1diCtLWxh9cl1kj1kOGuROu)UxNUzaph4l4ULFfiFtdmyJBIflPoxQnqQfi1GawlK6NcK)fupGW1rVWsDUuBGuRKuRKulqQbbSwydei3TCr3eB40ndPwGuVPGGI)j1zLl1zOMrGvesI8nlyBGnFtbXf)lPs)X8iPABFD8WZqPlv2OgKYoPIbbwXzQ8K63SdBgLuBGaTEpGWjB9mXklOUu(77nftiASamrrCk1cK63960ndiiG1YNS1ZeRSG6s5VV3umHnsZsLAbsniG1cNS1ZeRSG6s5VV3um522xhC6MHulqQvuQbbSwi1pfix0nXgoDZqQfi1GawlSbcK7wUOBInC6MHulqQNiiG1cph4l4ULFfiFtdm40ndPwjPwGu)UxNUzaph4l4ULFfiFtdmyJBIflPoxQnqQfi1kk1GawlK6NcK)fupGW1rVWs9y5sTHKAbsTIsTIs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQhlxQh(PulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWZVnFtLWNyLkvQvsQvqbPwrP2WL6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbK6NcKl6MydBCtSyj1zj1zOMrGveE(T5BQe(eRuPsTssTcki1V71PBgqQFkqUOBInSXnXILupwUup8tPwjPwPKk9hZJKQT91b61lDPYgD0u2jvmiWkotLNu)MDyZOKAdeO17beozRNjwzb1LYFFVPycrJfGjkItPwGu)UxNUzabbSw(KTEMyLfuxk)99MIjSrAwQulqQbbSw4KTEMyLfuxk)99MIj3YAeoDZqQfi1InMHp8t4OqB7Rd0RxsL(J5rs1YAKdwP1LUuzJAOu2jvmiWkotLNu)MDyZOK67ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGudcyTqQFkq(xq9acxh9cl1JLl1gsQfi1V71PBgqQFkqUOBInSXnXILupwUup8ZKk9hZJK6M1T3lUB5N3BmU0LkBuJjLDsfdcSIZu5j1Vzh2mkP(UxNUzaP(Pa5IUj2Wg3elwsDUuBGulqQvuQnCP(OkgheJkBO4WaNqmiWkoLAfuqQvuQpQIXbXOYgkomWjedcSItPwGuVPGGI)j1zLl1cndKALKALKAbsTIsTIs97ED6Mb8CGVG7w(vG8nnWGnUjwSK6SK6muZiWkcjr(MkHpXkvQulqQbbSwi1pfi)lOEaHRJEHL6CPgeWAHu)uG8VG6beUPs4RJEHLALKAfuqQvuQF3Rt3mGNd8fC3YVcKVPbgSXnXILuNl1gi1cKAqaRfs9tbY)cQhq46OxyPoxQnqQvsQvsQfi1GawlSbcK7wUOBInC6MHulqQ3uqqX)K6SYL6muZiWkcjr(MfSnWMVPG4I)LuP)yEKu3SU9EXDl)8EJXLUuzJAytzNuXGaR4mvEs9B2HnJsQV71PBgWZb(cUB5xbY30ad24MyXsQZLAdKAbsniG1cP(Pa5Fb1diCD0lSupwUuBiPwGu)UxNUzaP(Pa5IUj2Wg3elws9y5s9WptQ0FmpsQtKUcqVdmDPYgvOszNuXGaR4mvEs9B2HnJsQV71PBgqQFkqUOBInSXnXILuNl1gi1cKAfLAdxQpQIXbXOYgkomWjedcSItPwbfKAfL6JQyCqmQSHIddCcXGaR4uQfi1BkiO4FsDw5sTqZaPwjPwjPwGuROuROu)UxNUzaph4l4ULFfiFtdmyJBIflPolPEudKAbsniG1cP(Pa5Fb1diCD0lSuNl1GawlK6NcK)fupGWnvcFD0lSuRKuRGcsTIs97ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGudcyTqQFkq(xq9acxh9cl15sTbsTssTssTaPgeWAHnqGC3YfDtSHt3mKAbs9Mcck(NuNvUuNHAgbwrijY3SGTb28nfex8VKk9hZJK6ePRa07atxQSrnoPStQyqGvCMkpP(n7WMrj13960nd45aFb3T8Ra5BAGbBCtSyj1zj1zOMrGve2l(MkHpXkvQulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWEX3uj8jwPsLAbsTIs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQhlxQh(PuRGcs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQZsQZqnJaRiSx8nvcFIvQuPwbfKAdxQpQIXbBGa5ULl6MydXGaR4uQvsQfi1GawlK6NcK)fupGW1rVWsDwsTHKAbs9ebbSw45aFb3T8Ra5BAGbNUzKuP)yEKuBAYO44lrQfoDPYgvOLYoPIbbwXzQ8K63SdBgLuF3Rt3mGNd8fC3YVcKVPbgSXnXILuNl1gi1cKAqaRfs9tbY)cQhq46OxyPESCP2qsTaP(DVoDZas9tbYfDtSHnUjwSK6XYL6HFMuP)yEKuBAYO44lrQfoDPYgviLYoPIbbwXzQ8K63SdBgLuF3Rt3mGu)uGCr3eByJBIflPoxQnqQfi1kk1kk1gUuFufJdIrLnuCyGtigeyfNsTcki1kk1hvX4Gyuzdfhg4eIbbwXPulqQ3uqqX)K6SYLAHMbsTssTssTaPwrPwrP(DVoDZaEoWxWDl)kq(MgyWg3elwsDwsDgQzeyfHKiFtLWNyLkvQfi1GawlK6NcK)fupGW1rVWsDUudcyTqQFkq(xq9ac3uj81rVWsTssTcki1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZLAdKAbsniG1cP(Pa5Fb1diCD0lSuNl1gi1kj1kj1cKAqaRf2abYDlx0nXgoDZqQfi1BkiO4FsDw5sDgQzeyfHKiFZc2gyZ3uqCX)KALsQ0FmpsQnnzuC8Li1cNUuzJACtzNuXGaR4mvEs9B2HnJsQGawlK6NcK)fupGW1rVWs9y5sTHKAbs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQhlxQh(PulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWZVnFtLWNyLkvQfi1VNbdkoOWL2mkKAbs97ED6MbSPjJIJVePwyyJBIflPESCPwiLuP)yEKuph4l4ULFfiFtdS0LkZqgKYoPIbbwXzQ8K63SdBgLubbSwi1pfi)lOEaHRJEHL6XYLAdj1cK6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbSbcK7wUOBInSXnXILupwUup8tPwGu)UxNUzaP(Pa5IUj2Wg3elwsDwsDgQzeyfHNFB(MkHpXkvQulqQnCP(9myqXbfU0MrrsL(J5rs9CGVG7w(vG8nnWsxQmdnAk7KkgeyfNPYtQFZoSzusfeWAHu)uG8VG6beUo6fwQhlxQnKulqQnCP(OkghSbcK7wUOBInedcSItPwGu)UxNUzaP(Pa5IUj2Wg3elwsDwsDgQzeyfHNFB(MkHpXkvAsL(J5rs9CGVG7w(vG8nnWsxQmdzOu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5Fb1diCD0lSupwUuBiPwGu)UxNUzaP(Pa5IUj2Wg3elws9y5s9WptQ0FmpsQNd8fC3YVcKVPbw6sLziJjLDsfdcSIZu5j1Vzh2mkPQOuB4s9rvmoigv2qXHboHyqGvCk1kOGuROuFufJdIrLnuCyGtigeyfNsTaPEtbbf)tQZkxQfAgi1kj1kj1cK63960nd45aFb3T8Ra5BAGbBCtSyj1zj1zOMrGvesI8nvcFIvQuPwGudcyTqQFkq(xq9acxh9cl15sniG1cP(Pa5Fb1diCtLWxh9cl1cKAqaRf2abYDlx0nXgoDZqQfi1BkiO4FsDw5sDgQzeyfHKiFZc2gyZ3uqCX)sQ0FmpsQu)uGCr3e70LkZqg2u2jvmiWkotLNu)MDyZOKkiG1cBGa5ULl6MydNUzi1cK63960nd45aFb3T8Ra5BAGbBCtSyj1zj1zOMrGve2UiFtLWNyLkvQfi1GawlK6NcK)fupGW1rVWsDUudcyTqQFkq(xq9ac3uj81rVWsTaPwrP(DVoDZas9tbYfDtSHnUjwSK6SK6rfkPwbfK6jccyTWZb(cUB5xbY30adcik1kLuP)yEKuBGa5ULl6MyNUuzgsOszNuXGaR4mvEs9B2HnJsQGawlK6NcK)fupGW1rVWsDUuBGulqQFpdguCqHlTzuKuP)yEKufBCHXJC3Y3SyMUuzgY4KYoPIbbwXzQ8K63SdBgLuNiiG1cph4l4ULFfiFtdmiGOulqQnCP(9myqXbfU0MrrsL(J5rsvSXfgpYDlFZIz6sLziHwk7KkgeyfNPYtQFZoSzus9DVoDZaIz8NoMhWg3elwsDwsTbsTaPwrPwrP(OkgheJkBO4WaNqmiWkoLAbs9Mcck(NupwUulKmqQfi1BkiO4FsDw5sTXrOKALKAfuqQvuQnCP(OkgheJkBO4WaNqmiWkoLAbs9Mcck(NupwUulKekPwjPwPKk9hZJK6McIpG70LUKk5yk7uzJMYoPIbbwXzQ8K63SdBgLuvuQpQIXbXOYgkomWjedcSItPwGuVPGGI)j1JLl1cjdKAbs9Mcck(NuNvUuBCekPwjPwbfKAfLAdxQpQIXbXOYgkomWjedcSItPwGuVPGGI)j1JLl1cjHsQvkPs)X8iPUPG4d4oDPYmuk7KkgeyfNPYtQFZoSzusfeWAHu)uGCr3eB40nJKk9hZJKALnuClUqgG5WgJlDPYmMu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5IUj2WPBgjv6pMhjvqAG7w(1Sx4v6sLzytzNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydbetQ0FmpsQalKZoCVsxQmHkLDsfdcSIZu5j1Vzh2mkPccyTqQFkqUOBIneqmPs)X8iPcI9cBHzXq6sLzCszNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydbetQ0FmpsQGv3NClqxA6sLj0szNuXGaR4mvEs9B2HnJsQGawlK6NcKl6MydbetQ0FmpsQwwJGv3NPlvMqkLDsfdcSIZu5j1Vzh2mkPccyTqQFkqUOBIneqmPs)X8iPsXJRRPk)PAnDPYmUPStQyqGvCMkpP(n7WMrj1giqR3di8WTO3uLBsTienwaMOiotQ0FmpsQhBJCtQftxQSrniLDsfdcSIZu5j1Vzh2mkP2abA9EaHt26zIvwqDP833BkMq0ybyII4uQfi1V71PBgqqaRLpzRNjwzb1LYFFVPycBKMLk1cKAqaRfozRNjwzb1LYFFVPyYTTVo40ndPwGuROudcyTqQFkqUOBInC6MHulqQbbSwydei3TCr3eB40ndPwGuprqaRfEoWxWDl)kq(MgyWPBgsTssTaP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQvuQbbSwi1pfi)lOEaHRJEHL6XYL6muZiWkcjh5NFB(xq9aUKAbsTIsTIs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQhlxQh(PulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWZVnFtLWNyLkvQvsQvqbPwrP2WL6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbK6NcKl6MydBCtSyj1zj1zOMrGveE(T5BQe(eRuPsTssTcki1V71PBgqQFkqUOBInSXnXILupwUup8tPwjPwPKk9hZJKQT91b61lDPYgD0u2jvmiWkotLNu)MDyZOKQIsDdeO17beozRNjwzb1LYFFVPycrJfGjkItPwGu)UxNUzabbSw(KTEMyLfuxk)99MIjSrAwQulqQbbSw4KTEMyLfuxk)99MIj3YAeoDZqQfi1InMHp8t4OqB7Rd0RNuRKuRGcsTIsDdeO17beozRNjwzb1LYFFVPycrJfGjkItPwGuFSnk15sTbsTsjv6pMhjvlRroyLwx6sLnQHszNuXGaR4mvEs9B2HnJsQnqGwVhq4qZw1s5SN9veIglatueNsTaP(DVoDZas9tbYfDtSHnUjwSK6SKAJXaPwGu)UxNUzaph4l4ULFfiFtdmyJBIflPoxQnqQfi1kk1GawlK6NcK)fupGW1rVWs9y5sDgQzeyfHKJ8ZVn)lOEaxsTaPwrPwrP(OkghSbcK7wUOBInedcSItPwGu)UxNUzaBGa5ULl6MydBCtSyj1JLl1d)uQfi1V71PBgqQFkqUOBInSXnXILuNLuNHAgbwr453MVPs4tSsLk1kj1kOGuROuB4s9rvmoydei3TCr3eBigeyfNsTaP(DVoDZas9tbYfDtSHnUjwSK6SK6muZiWkcp)28nvcFIvQuPwjPwbfK63960ndi1pfix0nXg24MyXsQhlxQh(PuRKuRusL(J5rs12(64HNHsxQSrnMu2jvmiWkotLNu)MDyZOKAdeO17beo0SvTuo7zFfHOXcWefXPulqQF3Rt3mGu)uGCr3eByJBIflPoxQnqQfi1kk1kk1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZsQZqnJaRiKe5BQe(eRuPsTaPgeWAHu)uG8VG6beUo6fwQZLAqaRfs9tbY)cQhq4MkHVo6fwQvsQvqbPwrP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQbbSwi1pfi)lOEaHRJEHL6XYL6muZiWkcjh5NFB(xq9aUKALKALKAbsniG1cBGa5ULl6MydNUzi1kLuP)yEKuTTVoE4zO0LkBudBk7KkgeyfNPYtQFZoSzusTbc069acxmXcp4RZ7nenwaMOioLAbsTyJz4d)eokeZ4pDmpsQ0FmpsQNd8fC3YVcKVPbw6sLnQqLYoPIbbwXzQ8K63SdBgLuBGaTEpGWftSWd(68EdrJfGjkItPwGuROul2yg(WpHJcXm(thZdPwbfKAXgZWh(jCu45aFb3T8Ra5BAGj1kLuP)yEKuP(Pa5IUj2Plv2OgNu2jvmiWkotLNu)MDyZOK6X2OuNLuBmgi1cK6giqR3diCXel8GVoV3q0ybyII4uQfi1GawlK6NcK)fupGW1rVWs9y5sDgQzeyfHKJ8ZVn)lOEaxsTaP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQF3Rt3mGu)uGCr3eByJBIflPESCPE4Njv6pMhjvmJ)0X8iDPYgvOLYoPIbbwXzQ8Kk9hZJKkMXF6yEKuzXHDdiECMnPccyTWftSWd(68Edxh9cNdcyTWftSWd(68Ed3uj81rVWjvwCy3aIhNT34KrhMuhnP(n7WMrj1JTrPolP2ymqQfi1nqGwVhq4Ijw4bFDEVHOXcWefXPulqQF3Rt3mGu)uGCr3eByJBIflPoxQnqQfi1kk1kk1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZsQZqnJaRiKe5BQe(eRuPsTaPgeWAHu)uG8VG6beUo6fwQZLAqaRfs9tbY)cQhq4MkHVo6fwQvsQvqbPwrP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQbbSwi1pfi)lOEaHRJEHL6XYL6muZiWkcjh5NFB(xq9aUKALKALKAbsniG1cBGa5ULl6MydNUzi1kLUuzJkKszNuXGaR4mvEs9B2HnJsQkk1V71PBgqQFkqUOBInSXnXILuNLuByfkPwbfK63960ndi1pfix0nXg24MyXsQhlxQngPwjPwGu)UxNUzaph4l4ULFfiFtdmyJBIflPoxQnqQfi1kk1GawlK6NcK)fupGW1rVWs9y5sDgQzeyfHKJ8ZVn)lOEaxsTaPwrPwrP(OkghSbcK7wUOBInedcSItPwGu)UxNUzaBGa5ULl6MydBCtSyj1JLl1d)uQfi1V71PBgqQFkqUOBInSXnXILuNLulusTssTcki1kk1gUuFufJd2abYDlx0nXgIbbwXPulqQF3Rt3mGu)uGCr3eByJBIflPolPwOKALKAfuqQF3Rt3mGu)uGCr3eByJBIflPESCPE4NsTssTsjv6pMhj1nRBVxC3YpV3yCPlv2Og3u2jvmiWkotLNu)MDyZOK67ED6Mb8CGVG7w(vG8nnWGnUjwSK6SK6muZiWkc7fFtLWNyLkvQfi1V71PBgqQFkqUOBInSXnXILuNLuNHAgbwryV4BQe(eRuPsTaPwrP(OkghSbcK7wUOBInedcSItPwGu)UxNUzaBGa5ULl6MydBCtSyj1JLl1d)uQvqbP(OkghSbcK7wUOBInedcSItPwGu)UxNUzaBGa5ULl6MydBCtSyj1zj1zOMrGve2l(MkHpXkvQuRGcsTHl1hvX4GnqGC3YfDtSHyqGvCk1kj1cKAqaRfs9tbY)cQhq46OxyPESCPod1mcSIqYr(53M)fupGlPwGuprqaRfEoWxWDl)kq(MgyWPBgjv6pMhj1MMmko(sKAHtxQmdzqk7KkgeyfNPYtQFZoSzus9DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQvuQbbSwi1pfi)lOEaHRJEHL6XYL6muZiWkcjh5NFB(xq9aUKAbsTIsTIs9rvmoydei3TCr3eBigeyfNsTaP(DVoDZa2abYDlx0nXg24MyXsQhlxQh(PulqQF3Rt3mGu)uGCr3eByJBIflPolPod1mcSIWZVnFtLWNyLkvQvsQvqbPwrP2WL6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbK6NcKl6MydBCtSyj1zj1zOMrGveE(T5BQe(eRuPsTssTcki1V71PBgqQFkqUOBInSXnXILupwUup8tPwjPwPKk9hZJKAttgfhFjsTWPlvMHgnLDsfdcSIZu5j1Vzh2mkP(UxNUzaP(Pa5IUj2Wg3elwsDUuBGulqQvuQvuQvuQF3Rt3mGNd8fC3YVcKVPbgSXnXILuNLuNHAgbwrijY3uj8jwPsLAbsniG1cP(Pa5Fb1diCD0lSuNl1GawlK6NcK)fupGWnvcFD0lSuRKuRGcsTIs97ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGudcyTqQFkq(xq9acxh9cl1JLl1zOMrGvesoYp)28VG6bCj1kj1kj1cKAqaRf2abYDlx0nXgoDZqQvkPs)X8iP20KrXXxIulC6sLzidLYoPIbbwXzQ8K63SdBgLuF3Rt3mGu)uGCr3eByJBIflPoxQnqQfi1kk1kk1kk1V71PBgWZb(cUB5xbY30ad24MyXsQZsQZqnJaRiKe5BQe(eRuPsTaPgeWAHu)uG8VG6beUo6fwQZLAqaRfs9tbY)cQhq4MkHVo6fwQvsQvqbPwrP(DVoDZaEoWxWDl)kq(MgyWg3elwsDUuBGulqQbbSwi1pfi)lOEaHRJEHL6XYL6muZiWkcjh5NFB(xq9aUKALKALKAbsniG1cBGa5ULl6MydNUzi1kLuP)yEKuNiDfGEhy6sLziJjLDsfdcSIZu5j1Vzh2mkPccyTqQFkq(xq9acxh9cl1JLl1zOMrGvesoYp)28VG6bCj1cKAfLAfL6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbSbcK7wUOBInSXnXILupwUup8tPwGu)UxNUzaP(Pa5IUj2Wg3elwsDwsDgQzeyfHNFB(MkHpXkvQuRKuRGcsTIsTHl1hvX4GnqGC3YfDtSHyqGvCk1cK63960ndi1pfix0nXg24MyXsQZsQZqnJaRi88BZ3uj8jwPsLALKAfuqQF3Rt3mGu)uGCr3eByJBIflPESCPE4NsTsjv6pMhj1Zb(cUB5xbY30alDPYmKHnLDsfdcSIZu5j1Vzh2mkPQOuROu)UxNUzaph4l4ULFfiFtdmyJBIflPolPod1mcSIqsKVPs4tSsLk1cKAqaRfs9tbY)cQhq46OxyPoxQbbSwi1pfi)lOEaHBQe(6OxyPwjPwbfKAfL63960nd45aFb3T8Ra5BAGbBCtSyj15sTbsTaPgeWAHu)uG8VG6beUo6fwQhlxQZqnJaRiKCKF(T5Fb1d4sQvsQvsQfi1GawlSbcK7wUOBInC6MrsL(J5rsL6NcKl6MyNUuzgsOszNuXGaR4mvEs9B2HnJsQGawlSbcK7wUOBInC6MHulqQvuQvuQF3Rt3mGNd8fC3YVcKVPbgSXnXILuNLuBidKAbsniG1cP(Pa5Fb1diCD0lSuNl1GawlK6NcK)fupGWnvcFD0lSuRKuRGcsTIs97ED6Mb8CGVG7w(vG8nnWGnUjwSK6CP2aPwGudcyTqQFkq(xq9acxh9cl1JLl1zOMrGvesoYp)28VG6bCj1kj1kj1cKAfL63960ndi1pfix0nXg24MyXsQZsQhvOKAfuqQNiiG1cph4l4ULFfiFtdmiGOuRusL(J5rsTbcK7wUOBID6sLziJtk7KkgeyfNPYtQFZoSzusfeWAHtKUcqVdecik1cK6jccyTWZb(cUB5xbY30adcik1cK6jccyTWZb(cUB5xbY30ad24MyXsQhlxQbbSwOyJlmEK7w(Mft4MkHVo6fwQnml10FmpGu)uGCWkToiwc(ahYp2gtQ0FmpsQInUW4rUB5BwmtxQmdj0szNuXGaR4mvEs9B2HnJsQGawlCI0va6DGqarPwGuROuROuFufJd24YdkEeIbbwXPulqQP)yzqog4MHlPEmP2Wk1kj1kOGut)XYGCmWndxs9ysTqj1kLuP)yEKuP(Pa5GvADPlvMHesPStQ0FmpsQlarSdpdLuXGaR4mvE6sLziJBk7KkgeyfNPYtQFZoSzusfeWAHu)uG8VG6beUo6fwQZLAdsQ0FmpsQu)uGCVbtxQmJXGu2jvmiWkotLNu)MDyZOKQIsDJ2gxfeyfLAfuqQnCP(yVWSyqQvsQfi1GawlK6NcK)fupGW1rVWsDUudcyTqQFkq(xq9ac3uj81rVWjv6pMhj1aVcS5hUfX1LUuzgZOPStQyqGvCMkpP(n7WMrjvqaRfs9tbYfDtSHt3mKAbsniG1cBGa5ULl6MydNUzi1cK6jccyTWZb(cUB5xbY30adoDZqQfi1V71PBgqQFkqUOBInSXnXILuNLuBGulqQF3Rt3mGNd8fC3YVcKVPbgSXnXILuNLuBGulqQvuQnCP(OkghSbcK7wUOBInedcSItPwbfKAfL6JQyCWgiqUB5IUj2qmiWkoLAbs97ED6MbSbcK7wUOBInSXnXILuNLuBGuRKuRusL(J5rsDvWShlg4IUj2PlvMXyOu2jvmiWkotLNu)MDyZOKkiG1c)ks9tRJfdWgP)KAbsDdeO17bes9tbYzHLfSRuiASamrrCk1cK6JQyCqAlwzw2thZdigeyfNsTaPM(JLb5yGBgUK6XKAdBsL(J5rsL6NcKVzRfRIR0LkZymMu2jvmiWkotLNu)MDyZOKkiG1cP(Pa5Fb1diCD0lSupMudcyTqQFkq(xq9ac3uj81rVWjv6pMhjvQFkqowIy1xmpsxQmJXWMYoPIbbwXzQ8K63SdBgLubbSwi1pfi)lOEaHRJEHL6CPgeWAHu)uG8VG6beUPs4RJEHtQ0FmpsQu)uGCqQBAatxQmJrOszNuzXHDdiECMnPUPGGI)LvUqsOsQS4WUbepoBVXjJomPoAsL(J5rsfZ4pDmpsQyqGvCMkpDPlPU9m4gJlLDQSrtzNuXGaR4mvEs9B2HnJsQBpdUX4Gt26O4rPoRCPEudsQ0FmpsQGvwiC6sLzOu2jv6pMhjvXgxy8i3T8nlMjvmiWkotLNUuzgtk7KkgeyfNPYtQFZoSzusD7zWnghCYwhfpk1Jj1JAqsL(J5rsL6NcKVzRfRIR0LkZWMYoPs)X8iPs9tbY9gmPIbbwXzQ80LUKQLfuLdc0rk7uzJMYoPIbbwXzQ8K6xqSiPoAs9B2HnJsQGawl8Ri1pTowmaBK(lPs)X8iPs9tbY3S1IvXv6sLzOu2jv6pMhjvQFkqoyLwxsfdcSIZu5PlvMXKYoPs)X8iPs9tbYbPUPbmPIbbwXzQ80LU0LuZG9I5rQmdzGHmWaJRbgdC0KQj1blgwjvdde6fIxMq2YmmuisQL6SlqPMTf9(KAR3sTX3(rhZdJxQB0ybynoL6LVrPMaoFthoL6VGIbCbLgjeGfOulucrsTqmpYG9HtP24FpdguCqHCigeyfNgVuFUuB8VNbdkoOqUXl1koAjkbLgLDbk1wVwDtwmi1eqtlP2eBuQbw4uQzHuFfOut)X8qQRS1j1GaNuBInk1HFsT1bIPuZcP(kqPMMtpK6jDeiTqHiPrsTHjPglrKIjo5I(HXXOQ0iPrggi0leVmHSLzyOqKul1zxGsnBl69j1wVLAJxSX33G0z8sDJglaRXPuV8nk1eW5B6WPu)fumGlO0iHaSaLAJrisQfI5rgSpCk1g)7zWGIdkKdXGaR404L6ZLAJ)9myqXbfYnEPwXrlrjO0iHaSaLAdRqKuleZJmyF4uQn(3ZGbfhuihIbbwXPXl1Nl1g)7zWGIdkKB8sTIJwIsqPrcbybk1JoQqKuleZJmyF4uQn(3ZGbfhuihIbbwXPXl1Nl1g)7zWGIdkKB8sTIJwIsqPrcbybk1JkucrsTqmpYG9HtP24FpdguCqHCigeyfNgVuFUuB8VNbdkoOqUXl1koAjkbLgjnYWaHEH4LjKTmddfIKAPo7cuQzBrVpP26TuB8KJgVu3OXcWACk1lFJsnbC(MoCk1Fbfd4cknk7cuQTET6MSyqQjGMwsTj2OudSWPuZcP(kqPM(J5HuxzRtQbboP2eBuQd)KARdetPMfs9vGsnnNEi1t6iqAHcrsJKAdts9Ijw4bFDEVLgjnYWaHEH4LjKTmddfIKAPo7cuQzBrVpP26TuB8V71PBglJxQB0ybynoL6LVrPMaoFthoL6VGIbCbLgjeGfOupQXvisQfI5rgSpCk1g)7zWGIdkKdXGaR404L6ZLAJ)9myqXbfYnEPwXrlrjO0iHaSaLAdzGqKuleZJmyF4uQn(3ZGbfhuihIbbwXPXl1Nl1g)7zWGIdkKB8sTIJwIsqPrcbybk1gsOeIKAHyEKb7dNsTX)EgmO4Gc5qmiWkonEP(CP24FpdguCqHCJxQvC0sucknsialqP2qghHiPwiMhzW(WPuB8VNbdkoOqoedcSItJxQpxQn(3ZGbfhui34LAfhTeLGsJKgjKDl69HtP24k10FmpK6kBDlO0OKQy7wwftQcHsTqxObuQf67NcuAKqOule0Foi2sTqtzP2qgyidKgjnI(J5Xck247Bq6YZqnJaROYbTXCXgfbQvoMXv2fZx4PCgQcG5ginI(J5Xck247Bq6gpFKmuZiWkQCqBmxSrrGALJzCLDX8fEkNHQay(OkZS5nqGwVhq4Ijw4bFDEVHOXcWefXPa6pwgKJbUz4kldjnI(J5Xck247Bq6gpFKmuZiWkQCqBmxSrrGALJzCLDX8fEkNHQay(OkZS5nqGwVhq4Ijw4bFDEVHOXcWefXPG3ZGbfhmWV9Q3tigeyfNcO)yzqog4MHRSgvAe9hZJfuSX33G0nE(izOMrGvu5G2yUyJIa1khZ4k7I5l8uodvbW8rvMzZBGaTEpGWftSWd(68EdrJfGjkItbVNbdkoyWgkoULqigeyfNsJecLA6pMhlOyJVVbPB88rYqnJaROYbTX8ckdYDrmWPYUy(cpLZqvam3aPrcHsn9hZJfuSX33G0nE(izOMrGvu5G2yEbLb5Uig4uzxmFHNYzOkaMpQYmBo9hldYXa3mCLLHKgjek10FmpwqXgFFds345JKHAgbwrLdAJ5fugK7IyGtLDX8fEkNHQay(OkZS5zOMrGvek2OiqTYXmE(OsJO)yESGIn((gKUXZhjd1mcSIkh0gZTSGQCqGou2fZx4PCgQcG5ginI(J5Xck247Bq6gpFKmuZiWkQCqBmVx8nvcFIvQuLDX8fEkNHQayUqjnI(J5Xck247Bq6gpFKmuZiWkQCqBmNe5BQe(eRuPk7I5l8uodvbW8rnqAe9hZJfuSX33G0nE(izOMrGvu5G2yE7I8nvcFIvQuLDX8fEkNHQayUHmqAe9hZJfuSX33G0nE(izOMrGvu5G2y(53MVPs4tSsLQSlMVWt5mufaZfkPr0FmpwqXgFFds345JKHAgbwrLdAJ5NFB(MkHpXkvQYUy(cpLZqvam3yuMzZBGaTEpGWjB9mXklOUu(77nftiASamrrCknI(J5Xck247Bq6gpFKmuZiWkQCqBm)8BZ3uj8jwPsv2fZx4PCgQcG5JkukZS5VNbdkoyWgkoULqigeyfNsJO)yESGIn((gKUXZhjd1mcSIkh0gZp)28nvcFIvQuLDX8fEkNHQay(OcLYmB(7XeGDqQFkqUy7t2qPqmiWkofq)XYGCmWndxJzmsJecL6YTc9sTHjPwioU9mOuleGoSLgr)X8ybfB89niDJNpsgQzeyfvoOnMF(T5BQe(eRuPk7I5l8uodvbWCJXaLz2CCTW4ryg2I5b3TCrST4FmpGBw4T0i6pMhlOyJVVbPB88rYqnJaROYbTXCqQBAa5BkiU4Fk7I5l8uodvbWCJRbsJO)yESGIn((gKUXZhjd1mcSIkh0gZbPUPbKVPG4I)PSlMVWt5mufaZfsgOmZM)EgmO4GbBO44wcHyqGvCknI(J5Xck247Bq6gpFKmuZiWkQCqBmNe5BwW2aB(McIl(NYUy(cpLZqvam3ymqAe9hZJfuSX33G0nE(izOMrGvu5G2yojY3SGTb28nfex8pLDX8fEkNHQayUqzGYmBEdeO17beozRNjwzb1LYFFVPycrJfGjkItPr0FmpwqXgFFds345JKHAgbwrLdAJ5KiFZc2gyZ3uqCX)u2fZx4PCgQcG5cLbkZS5nqGwVhq4qZw1s5SN9veIglatueNsJO)yESGIn((gKUXZhjd1mcSIkh0gZjh5NFB(xq9aUu2fZx4PCgQcG5gsAe9hZJfuSX33G0nE(i2kTewAe9hZJfuSX33G0nE(iw3NsJO)yESGIn((gKUXZhHag2yC0X8qAe9hZJfuSX33G0nE(iu)uGClTzvg1sJO)yESGIn((gKUXZhH6NcKZIdRv8pPr0FmpwqXgFFds345J8EiKbOr(McIpGBPr0FmpwqXgFFds345JScsCv4hFD0TKgr)X8ybfB89niDJNpYM1T3C2MgqPr0FmpwqXgFFds345Ji6hZdPr0FmpwqXgFFds345JyBFDGE9uMzZZqnJaRiuSrrGALJz8CdKgr)X8ybfB89niDJNpcMXF6yEOmZMNHAgbwrOyJIa1khZ45JknsAKqOuleSLGpWHtPgZGDPs9X2OuFfOut)5TuZwsnLHyvcSIqPr0Fmpw5Vdeh2lrSwvMzZpQhWdorqaRf(06yXaSr6pPrcHsD5wHEP2WKuleh3EguQfcqh2sJO)yESgpFKNQvo9hZdELToLdAJ54AHXJlPr0FmpwJNpYt1kN(J5bVYwNYbTXCYrLz2C6pwgKJbUz4kldjnI(J5XA88rEQw50Fmp4v26uoOnM7IyGTYmBEgQzeyfHfugK7IyGZCdKgr)X8ynE(ipvRC6pMh8kBDkh0gZF3Rt3mwsJO)yESgpFKNQvo9hZdELToLdAJ5TF0X8qzMnpd1mcSIqllOkheOJCdKgr)X8ynE(ipvRC6pMh8kBDkh0gZTSGQCqGouMzZZqnJaRi0YcQYbb6iFuPr0FmpwJNpYt1kN(J5bVYwNYbTX8TNb3yCsJKgr)X8ybjhZbwiFtbXhWTYmBUIhvX4Gyuzdfhg4eIbbwXPGnfeu8VXYfsgiytbbf)lRCJJqPKckOOHFufJdIrLnuCyGtigeyfNc2uqqX)glxijukjnI(J5XcsooE(iv2qXT4czaMdBmoLz2CqaRfs9tbYfDtSHt3mKgr)X8ybjhhpFeqAG7w(1Sx4LYmBoiG1cP(Pa5IUj2WPBgsJO)yESGKJJNpcWc5Sd3lLz2CqaRfs9tbYfDtSHaIsJO)yESGKJJNpci2lSfMfdkZS5GawlK6NcKl6MydbeLgr)X8ybjhhpFeWQ7tUfOlvzMnheWAHu)uGCr3eBiGO0i6pMhli5445JyzncwDFQmZMdcyTqQFkqUOBInequAe9hZJfKCC88rO4X11uL)uTQmZMdcyTqQFkqUOBInequAe9hZJfKCC88ro2g5MulQmZM3abA9EaHhUf9MQCtQfHOXcWefXP0i6pMhli5445JyBFDGE9uMzZBGaTEpGWjB9mXklOUu(77nftiASamrrCk4DVoDZaccyT8jB9mXklOUu(77nftyJ0SubGawlCYwptSYcQlL)(EtXKBBFDWPBgcueeWAHu)uGCr3eB40ndbGawlSbcK7wUOBInC6MHGjccyTWZb(cUB5xbY30adoDZqjbV71PBgWZb(cUB5xbY30ad24MyXk3abkccyTqQFkq(xq9acxh9cpwEgQzeyfHKJ8ZVn)lOEaxcuuXJQyCWgiqUB5IUj2qmiWkof8UxNUzaBGa5ULl6MydBCtSynw(Wpf8UxNUzaP(Pa5IUj2Wg3elwzLHAgbwr453MVPs4tSsLQKckOOHFufJd2abYDlx0nXgIbbwXPG3960ndi1pfix0nXg24MyXkRmuZiWkcp)28nvcFIvQuLuqH3960ndi1pfix0nXg24MyXAS8HFQKssJO)yESGKJJNpIL1ihSsRtzMnxXgiqR3diCYwptSYcQlL)(EtXeIglatueNcE3Rt3mGGawlFYwptSYcQlL)(EtXe2inlvaiG1cNS1ZeRSG6s5VV3um5wwJWPBgceBmdF4NWrH22xhOxpLuqbfBGaTEpGWjB9mXklOUu(77nftiASamrrCk4yBm3aLKgr)X8ybjhhpFeB7RJhEgszMnVbc069achA2QwkN9SVIq0ybyII4uW7ED6MbK6NcKl6MydBCtSyLLXyGG3960nd45aFb3T8Ra5BAGbBCtSyLBGafbbSwi1pfi)lOEaHRJEHhlpd1mcSIqYr(53M)fupGlbkQ4rvmoydei3TCr3eBigeyfNcE3Rt3mGnqGC3YfDtSHnUjwSglF4NcE3Rt3mGu)uGCr3eByJBIfRSYqnJaRi88BZ3uj8jwPsvsbfu0WpQIXbBGa5ULl6MydXGaR4uW7ED6MbK6NcKl6MydBCtSyLvgQzeyfHNFB(MkHpXkvQskOW7ED6MbK6NcKl6MydBCtSynw(WpvsjPr0FmpwqYXXZhX2(64HNHuMzZBGaTEpGWHMTQLYzp7RienwaMOiof8UxNUzaP(Pa5IUj2Wg3elw5giqrfv8DVoDZaEoWxWDl)kq(MgyWg3elwzLHAgbwrijY3uj8jwPsfacyTqQFkq(xq9acxh9cNdcyTqQFkq(xq9ac3uj81rVWkPGck(UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cpwEgQzeyfHKJ8ZVn)lOEaxkPKaqaRf2abYDlx0nXgoDZqjPrcHsD2cbjemcbjej1cXQifsnGOuFf4cLAvvPgZ4sDLf4sAe9hZJfKCC88roh4l4ULFfiFtdmLz28giqR3diCXel8GVoV3q0ybyII4uGyJz4d)eokeZ4pDmpKgr)X8ybjhhpFeQFkqUOBITYmBEdeO17beUyIfEWxN3BiASamrrCkqrXgZWh(jCuiMXF6yEOGcInMHp8t4OWZb(cUB5xbY30atjPr0FmpwqYXXZhbZ4pDmpuMzZp2gZYymqqdeO17beUyIfEWxN3BiASamrrCkaeWAHu)uG8VG6beUo6fES8muZiWkcjh5NFB(xq9aUe8UxNUzaph4l4ULFfiFtdmyJBIfRCde8UxNUzaP(Pa5IUj2Wg3elwJLp8tPr0FmpwqYXXZhbZ4pDmpuMzZp2gZYymqqdeO17beUyIfEWxN3BiASamrrCk4DVoDZas9tbYfDtSHnUjwSYnqGIkQ47ED6Mb8CGVG7w(vG8nnWGnUjwSYkd1mcSIqsKVPs4tSsLkaeWAHu)uG8VG6beUo6foheWAHu)uG8VG6beUPs4RJEHvsbfu8DVoDZaEoWxWDl)kq(MgyWg3elw5giaeWAHu)uG8VG6beUo6fES8muZiWkcjh5NFB(xq9aUusjbGawlSbcK7wUOBInC6MHskZId7gq84mBoiG1cxmXcp4RZ7nCD0lCoiG1cxmXcp4RZ7nCtLWxh9cRmloSBaXJZ2BCYOdZhvAe9hZJfKCC88r2SU9EXDl)8EJXPmZMR47ED6MbK6NcKl6MydBCtSyLLHvOuqH3960ndi1pfix0nXg24MyXASCJrjbV71PBgWZb(cUB5xbY30ad24MyXk3abkccyTqQFkq(xq9acxh9cpwEgQzeyfHKJ8ZVn)lOEaxcuuXJQyCWgiqUB5IUj2qmiWkof8UxNUzaBGa5ULl6MydBCtSynw(Wpf8UxNUzaP(Pa5IUj2Wg3elwzjukPGckA4hvX4GnqGC3YfDtSHyqGvCk4DVoDZas9tbYfDtSHnUjwSYsOusbfE3Rt3mGu)uGCr3eByJBIfRXYh(PskjnI(J5XcsooE(innzuC8Li1cRmZM)UxNUzaph4l4ULFfiFtdmyJBIfRSYqnJaRiSx8nvcFIvQubV71PBgqQFkqUOBInSXnXIvwzOMrGve2l(MkHpXkvQafpQIXbBGa5ULl6MydXGaR4uW7ED6MbSbcK7wUOBInSXnXI1y5d)ubfoQIXbBGa5ULl6MydXGaR4uW7ED6MbSbcK7wUOBInSXnXIvwzOMrGve2l(MkHpXkvQcky4hvX4GnqGC3YfDtSHyqGvCQKaqaRfs9tbY)cQhq46Ox4XYZqnJaRiKCKF(T5Fb1d4sWebbSw45aFb3T8Ra5BAGbNUzinI(J5XcsooE(innzuC8Li1cRmZM)UxNUzaph4l4ULFfiFtdmyJBIfRCdeOiiG1cP(Pa5Fb1diCD0l8y5zOMrGvesoYp)28VG6bCjqrfpQIXbBGa5ULl6MydXGaR4uW7ED6MbSbcK7wUOBInSXnXI1y5d)uW7ED6MbK6NcKl6MydBCtSyLvgQzeyfHNFB(MkHpXkvQskOGIg(rvmoydei3TCr3eBigeyfNcE3Rt3mGu)uGCr3eByJBIfRSYqnJaRi88BZ3uj8jwPsvsbfE3Rt3mGu)uGCr3eByJBIfRXYh(PskjnI(J5XcsooE(innzuC8Li1cRmZM)UxNUzaP(Pa5IUj2Wg3elw5giqrfv8DVoDZaEoWxWDl)kq(MgyWg3elwzLHAgbwrijY3uj8jwPsfacyTqQFkq(xq9acxh9cNdcyTqQFkq(xq9ac3uj81rVWkPGck(UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cpwEgQzeyfHKJ8ZVn)lOEaxkPKaqaRf2abYDlx0nXgoDZqjPr0FmpwqYXXZhzI0va6DGkZS5V71PBgqQFkqUOBInSXnXIvUbcuurfF3Rt3mGNd8fC3YVcKVPbgSXnXIvwzOMrGvesI8nvcFIvQubGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lSskOGIV71PBgWZb(cUB5xbY30ad24MyXk3abGawlK6NcK)fupGW1rVWJLNHAgbwri5i)8BZ)cQhWLskjaeWAHnqGC3YfDtSHt3musAe9hZJfKCC88roh4l4ULFfiFtdmLz2CqaRfs9tbY)cQhq46Ox4XYZqnJaRiKCKF(T5Fb1d4sGIkEufJd2abYDlx0nXgIbbwXPG3960ndydei3TCr3eByJBIfRXYh(PG3960ndi1pfix0nXg24MyXkRmuZiWkcp)28nvcFIvQuLuqbfn8JQyCWgiqUB5IUj2qmiWkof8UxNUzaP(Pa5IUj2Wg3elwzLHAgbwr453MVPs4tSsLQKck8UxNUzaP(Pa5IUj2Wg3elwJLp8tLKgr)X8ybjhhpFeQFkqUOBITYmBUIk(UxNUzaph4l4ULFfiFtdmyJBIfRSYqnJaRiKe5BQe(eRuPcabSwi1pfi)lOEaHRJEHZbbSwi1pfi)lOEaHBQe(6OxyLuqbfF3Rt3mGNd8fC3YVcKVPbgSXnXIvUbcabSwi1pfi)lOEaHRJEHhlpd1mcSIqYr(53M)fupGlLusaiG1cBGa5ULl6MydNUzinI(J5XcsooE(inqGC3YfDtSvMzZbbSwydei3TCr3eB40ndbkQ47ED6Mb8CGVG7w(vG8nnWGnUjwSYYqgiaeWAHu)uG8VG6beUo6foheWAHu)uG8VG6beUPs4RJEHvsbfu8DVoDZaEoWxWDl)kq(MgyWg3elw5giaeWAHu)uG8VG6beUo6fES8muZiWkcjh5NFB(xq9aUusjbk(UxNUzaP(Pa5IUj2Wg3elwznQqPGcteeWAHNd8fC3YVcKVPbgequjPr0FmpwqYXXZhrSXfgpYDlFZIPYmBoiG1cNiDfGEhiequWebbSw45aFb3T8Ra5BAGbbefmrqaRfEoWxWDl)kq(MgyWg3elwJLdcyTqXgxy8i3T8nlMWnvcFD0lSHz6pMhqQFkqoyLwhelbFGd5hBJsJO)yESGKJJNpc1pfihSsRtzMnheWAHtKUcqVdecikqrfpQIXbBC5bfpcXGaR4ua9hldYXa3mCnMHvjfuG(JLb5yGBgUgtOusAe9hZJfKCC88rwaIyhEgsAe9hZJfKCC88rO(Pa5EdQmZMdcyTqQFkq(xq9acxh9cNBG0i6pMhli5445Je4vGn)WTiUoLz2CfB024QGaROcky4h7fMfdkjaeWAHu)uG8VG6beUo6foheWAHu)uG8VG6beUPs4RJEHLgr)X8ybjhhpFKvbZESyGl6MyRmZMdcyTqQFkqUOBInC6MHaqaRf2abYDlx0nXgoDZqWebbSw45aFb3T8Ra5BAGbNUzi4DVoDZas9tbYfDtSHnUjwSYYabV71PBgWZb(cUB5xbY30ad24MyXkldeOOHFufJd2abYDlx0nXgIbbwXPckO4rvmoydei3TCr3eBigeyfNcE3Rt3mGnqGC3YfDtSHnUjwSYYaLusAe9hZJfKCC88rO(Pa5B2AXQ4szMnheWAHFfP(P1XIbyJ0FcAGaTEpGqQFkqolSSGDLcrJfGjkItbhvX4G0wSYSSNoMhqmiWkofq)XYGCmWndxJzyLgr)X8ybjhhpFeQFkqowIy1xmpuMzZbbSwi1pfi)lOEaHRJEHhdeWAHu)uG8VG6beUPs4RJEHLgr)X8ybjhhpFeQFkqoi1nnGkZS5GawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lS0i6pMhli5445JGz8NoMhkZId7gq84mB(Mcck(xw5cjHszwCy3aIhNT34KrhMpQ0iPr0FmpwW3960nJvELnuClUqgG5WgJtzMnheWAHu)uGCr3eB40ndbGawlSbcK7wUOBInC6MHGjccyTWZb(cUB5xbY30adoDZqAe9hZJf8DVoDZynE(iG0a3T8RzVWlLz2CqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndPr0FmpwW3960nJ145JaSqo7W9szMnheWAHu)uGCr3eBiGO0i6pMhl47ED6MXA88raXEHTWSyqzMnheWAHu)uGCr3eBiGO0i6pMhl47ED6MXA88raRUp5wGUuLz2CqaRfs9tbYfDtSHaIsJO)yESGV71PBgRXZhXYAeS6(uzMnheWAHu)uGCr3eBiGO0i6pMhl47ED6MXA88rO4X11uL)uTQmZMdcyTqQFkqUOBInequAKqOuleCnZB2Xe6GsnWIfds9qZw1sLA2Z(kk1MSRqQjrOuByCHsn7KAt2vi1NFBP2VcSnzlek1sJO)yESGV71PBgRXZhX2(64HNHuMzZBGaTEpGWHMTQLYzp7RienwaMOiof8UxNUzaP(Pa5IUj2Wg3elwzzmgi4DVoDZaEoWxWDl)kq(MgyWg3elw5giqrqaRfs9tbY)cQhq46Ox4XYnKafv8OkghSbcK7wUOBInedcSItbV71PBgWgiqUB5IUj2Wg3elwJLp8tbV71PBgqQFkqUOBInSXnXIvwzOMrGveE(T5BQe(eRuPkPGckA4hvX4GnqGC3YfDtSHyqGvCk4DVoDZas9tbYfDtSHnUjwSYkd1mcSIWZVnFtLWNyLkvjfu4DVoDZas9tbYfDtSHnUjwSglF4NkPK0i6pMhl47ED6MXA88rSTVoE4ziLz28giqR3diCOzRAPC2Z(kcrJfGjkItbV71PBgqQFkqUOBInSXnXIvUbcu0WpQIXbXOYgkomWjedcSItfuqXJQyCqmQSHIddCcXGaR4uWMcck(xw5cndusjbkQ47ED6Mb8CGVG7w(vG8nnWGnUjwSYAudeacyTqQFkq(xq9acxh9cNdcyTqQFkq(xq9ac3uj81rVWkPGck(UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cNBGskjaeWAHnqGC3YfDtSHt3meSPGGI)LvEgQzeyfHKiFZc2gyZ3uqCX)Kgr)X8ybF3Rt3mwJNpIT91b61tzMnVbc069acNS1ZeRSG6s5VV3umHOXcWefXPG3960ndiiG1YNS1ZeRSG6s5VV3umHnsZsfacyTWjB9mXklOUu(77nftUT91bNUziqrqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndLe8UxNUzaph4l4ULFfiFtdmyJBIfRCdeOiiG1cP(Pa5Fb1diCD0l8y5gsGIkEufJd2abYDlx0nXgIbbwXPG3960ndydei3TCr3eByJBIfRXYh(PG3960ndi1pfix0nXg24MyXkRmuZiWkcp)28nvcFIvQuLuqbfn8JQyCWgiqUB5IUj2qmiWkof8UxNUzaP(Pa5IUj2Wg3elwzLHAgbwr453MVPs4tSsLQKck8UxNUzaP(Pa5IUj2Wg3elwJLp8tLusAe9hZJf8DVoDZynE(iwwJCWkToLz28giqR3diCYwptSYcQlL)(EtXeIglatueNcE3Rt3mGGawlFYwptSYcQlL)(EtXe2inlvaiG1cNS1ZeRSG6s5VV3um5wwJWPBgceBmdF4NWrH22xhOxpPrcHsTqF1KkDj1aluQ3SU9Ej1MSRqQjrOulK1k1NFBPMTK6gPzPsnTKAtSwvwQ3KWOuVaAuQpxQFADsn7KAq06nk1NFBO0i6pMhl47ED6MXA88r2SU9EXDl)8EJXPmZM)UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cpwUHe8UxNUzaP(Pa5IUj2Wg3elwJLp8tPr0FmpwW3960nJ145JSzD79I7w(59gJtzMn)DVoDZas9tbYfDtSHnUjwSYnqGIg(rvmoigv2qXHboHyqGvCQGckEufJdIrLnuCyGtigeyfNc2uqqX)YkxOzGskjqrfF3Rt3mGNd8fC3YVcKVPbgSXnXIvwzOMrGvesI8nvcFIvQubGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lSskOGIV71PBgWZb(cUB5xbY30ad24MyXk3abGawlK6NcK)fupGW1rVW5gOKscabSwydei3TCr3eB40ndbBkiO4FzLNHAgbwrijY3SGTb28nfex8pPrcHsTqF1KkDj1aluQNiDfGEhOuBYUcPMeHsTqwRuF(TLA2sQBKMLk10sQnXAvzPEtcJs9cOrP(CP(P1j1StQbrR3OuF(THsJO)yESGV71PBgRXZhzI0va6DGkZS5V71PBgWZb(cUB5xbY30ad24MyXk3abGawlK6NcK)fupGW1rVWJLBibV71PBgqQFkqUOBInSXnXI1y5d)uAe9hZJf8DVoDZynE(itKUcqVduzMn)DVoDZas9tbYfDtSHnUjwSYnqGIg(rvmoigv2qXHboHyqGvCQGckEufJdIrLnuCyGtigeyfNc2uqqX)YkxOzGskjqrfF3Rt3mGNd8fC3YVcKVPbgSXnXIvwJAGaqaRfs9tbY)cQhq46Ox4CqaRfs9tbY)cQhq4MkHVo6fwjfuqX3960nd45aFb3T8Ra5BAGbBCtSyLBGaqaRfs9tbY)cQhq46Ox4CdusjbGawlSbcK7wUOBInC6MHGnfeu8VSYZqnJaRiKe5BwW2aB(McIl(N0iHqPoBHGecgHGeIKAvrQfwQFpMSJ5XsQTEl1nU8GIhLAkMsDCsTHXfk1lrQfwQzwP(8Bl1umLAsuQPgLApK6Fk1umLAtpm(tQbrPgquQTEl1vpgWwQVckK6RaL6nvIupXkvQYs9MeMfds9cOrP2eL6ckdk10j1vKwNuFMUut9tbk1Fb1d4sQPyk1xbDs953wQnPvy8NulKbyDsnWcNqPr0FmpwW3960nJ145J00KrXXxIulSYmB(7ED6Mb8CGVG7w(vG8nnWGnUjwSYkd1mcSIWEX3uj8jwPsf8UxNUzaP(Pa5IUj2Wg3elwzLHAgbwryV4BQe(eRuPcu8OkghSbcK7wUOBInedcSItbV71PBgWgiqUB5IUj2Wg3elwJLp8tfu4OkghSbcK7wUOBInedcSItbV71PBgWgiqUB5IUj2Wg3elwzLHAgbwryV4BQe(eRuPkOGHFufJd2abYDlx0nXgIbbwXPscabSwi1pfi)lOEaHRJEHZYqcMiiG1cph4l4ULFfiFtdm40ndPrcHsTHXfk1lrQfwQnzxHutIsTzbgsTOVwmWkcLAHSwP(8Bl1SLu3inlvQPLuBI1QYs9MegL6fqJs95s9tRtQzNudIwVrP(8BdLgr)X8ybF3Rt3mwJNpsttgfhFjsTWkZS5V71PBgWZb(cUB5xbY30ad24MyXk3abGawlK6NcK)fupGW1rVWJLBibV71PBgqQFkqUOBInSXnXI1y5d)uAe9hZJf8DVoDZynE(innzuC8Li1cRmZM)UxNUzaP(Pa5IUj2Wg3elw5giqrfn8JQyCqmQSHIddCcXGaR4ubfu8OkgheJkBO4WaNqmiWkofSPGGI)LvUqZaLusGIk(UxNUzaph4l4ULFfiFtdmyJBIfRSYqnJaRiKe5BQe(eRuPcabSwi1pfi)lOEaHRJEHZbbSwi1pfi)lOEaHBQe(6OxyLuqbfF3Rt3mGNd8fC3YVcKVPbgSXnXIvUbcabSwi1pfi)lOEaHRJEHZnqjLeacyTWgiqUB5IUj2WPBgc2uqqX)Ykpd1mcSIqsKVzbBdS5BkiU4FkjnsiuQf6U0MrHqKuByCHs953wQzwPMeLA2sQ9qQ)PutXuQn9W4pPgeLAarP26Tux9yaBP(kOqQVcuQ3ujs9eRuPqPwOVYgcP2KDfsD7IsnZk1xbk1hvX4KA2sQpsymGsTqW71Putsni7K6ZL6njmk1lGgLAtuQFkKAH4QsnBVXjJoSwQut2dBP(8Bl1ymxsJO)yESGV71PBgRXZh5CGVG7w(vG8nnWuMzZbbSwi1pfi)lOEaHRJEHhl3qcoQIXbBGa5ULl6MydXGaR4uW7ED6MbSbcK7wUOBInSXnXI1y5d)uW7ED6MbK6NcKl6MydBCtSyLvgQzeyfHNFB(MkHpXkvQG3ZGbfhu4sBgfqmiWkof8UxNUzaBAYO44lrQfg24MyXASCHK0iHqPUmpmmj0DPnJcHiP2W4cL6ZVTuZSsnjk1SLu7Hu)tPMIPuB6HXFsnik1aIsT1BPU6Xa2s9vqHuFfOuVPsK6jwPsHsTqFLnesTj7kK62fLAMvQVcuQpQIXj1SLuFKWyaLgr)X8ybF3Rt3mwJNpY5aFb3T8Ra5BAGPmZMdcyTqQFkq(xq9acxh9cpwUHeCufJd2abYDlx0nXgIbbwXPG3960ndydei3TCr3eByJBIfRXYh(PG3960ndi1pfix0nXg24MyXkRmuZiWkcp)28nvcFIvQubg(7zWGIdkCPnJcigeyfNsJO)yESGV71PBgRXZh5CGVG7w(vG8nnWuMzZbbSwi1pfi)lOEaHRJEHhl3qcm8JQyCWgiqUB5IUj2qmiWkof8UxNUzaP(Pa5IUj2Wg3elwzLHAgbwr453MVPs4tSsLknI(J5Xc(UxNUzSgpFKZb(cUB5xbY30atzMnheWAHu)uG8VG6beUo6fESCdj4DVoDZas9tbYfDtSHnUjwSglF4NsJecLAdJluQjrPMzL6ZVTuZwsThs9pLAkMsTPhg)j1GOudik1wVL6Qhdyl1xbfs9vGs9MkrQNyLkvzPEtcZIbPEb0OuFf0j1MOuxqzqPgdhyOqQ3uqsnftP(kOtQVcSrPMTK6WpPMQnsZsLAsQBGaLA3k1IUj2s90ndO0i6pMhl47ED6MXA88rO(Pa5IUj2kZS5kA4hvX4Gyuzdfhg4eIbbwXPckO4rvmoigv2qXHboHyqGvCkytbbf)lRCHMbkPKG3960nd45aFb3T8Ra5BAGbBCtSyLvgQzeyfHKiFtLWNyLkvaiG1cP(Pa5Fb1diCD0lCoiG1cP(Pa5Fb1diCtLWxh9claeWAHnqGC3YfDtSHt3meSPGGI)LvEgQzeyfHKiFZc2gyZ3uqCX)Kgjek1ggxOu3UOuZSs953wQzlP2dP(NsnftP20dJ)KAquQbeLAR3sD1JbSL6RGcP(kqPEtLi1tSsLQSuVjHzXGuVaAuQVcSrPMTcJ)KAQ2inlvQjPUbcuQNUzi1umL6RGoPMeLAtpm(tQbX33OutziwLaROupbAwmi1nqGqPr0FmpwW3960nJ145J0abYDlx0nXwzMnheWAHnqGC3YfDtSHt3me8UxNUzaph4l4ULFfiFtdmyJBIfRSYqnJaRiSDr(MkHpXkvQaqaRfs9tbY)cQhq46Ox4CqaRfs9tbY)cQhq4MkHVo6fwGIV71PBgqQFkqUOBInSXnXIvwJkukOWebbSw45aFb3T8Ra5BAGbbevsAKqOul0DPnJcHiPwiUQuZws9McsQlaIHUuPMIPul0xUHDj1uJs95UuJLiIXILbL6ZLAGfk1I(wQpxQxglaIcDqPMcPgl5AsQjqPMfs9vGs953wQnzX0nHsTqa8m(LudSqPMDs95s9MegL6QBk1Fb1dOul0x(sQzX6O4GsJO)yESGV71PBgRXZhrSXfgpYDlFZIPYmBoiG1cP(Pa5Fb1diCD0lCUbcEpdguCqHlTzuaXGaR4uAKqOuxMhgMe6U0MrHqKuByCHsTOVL6ZL6LXcGOqhuQPqQXsUMKAcuQzHuFfOuF(TLAtwmDtO0i6pMhl47ED6MXA88reBCHXJC3Y3SyQmZMprqaRfEoWxWDl)kq(Mgyqarbg(7zWGIdkCPnJcigeyfNsJO)yESGV71PBgRXZhbyH8nfeFa3kZS5V71PBgqmJ)0X8a24MyXkldeOOIhvX4Gyuzdfhg4eIbbwXPGnfeu8VXYfsgiytbbf)lRCJJqPKckOOHFufJdIrLnuCyGtigeyfNc2uqqX)glxijukPK0iPrcHsD5wHEP2WKuleh3EguQfcqh2sJO)yESG4AHXJRCWQ7tUB5xbYXa3LQmZM)UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cpwUHe8UxNUzaP(Pa5IUj2Wg3elwJLp8tfu4OEap4X2i)C(KHJ9UxNUzaP(Pa5IUj2Wg3elwsJO)yESG4AHXJRXZhbS6(K7w(vGCmWDPkZS5V71PBgqQFkqUOBInSXnXIvUbcu0WpQIXbXOYgkomWjedcSItfuqXJQyCqmQSHIddCcXGaR4uWMcck(xw5cndusjbkQ47ED6Mb8CGVG7w(vG8nnWGnUjwSYAudeacyTqQFkq(xq9acxh9cNdcyTqQFkq(xq9ac3uj81rVWkPGck(UxNUzaph4l4ULFfiFtdmyJBIfRCdeacyTqQFkq(xq9acxh9cNBGskjaeWAHnqGC3YfDtSHt3meSPGGI)LvEgQzeyfHKiFZc2gyZ3uqCX)Kgr)X8ybX1cJhxJNpIP31zgKf8gxEqXJkZS5V71PBgWZb(cUB5xbY30ad24MyXk3abGawlK6NcK)fupGW1rVWJLBibV71PBgqQFkqUOBInSXnXI1y5d)ubfoQhWdESnYpNpz4yV71PBgqQFkqUOBInSXnXIL0i6pMhliUwy84A88rm9UoZGSG34YdkEuzMn)DVoDZas9tbYfDtSHnUjwSYnqGIg(rvmoigv2qXHboHyqGvCQGckEufJdIrLnuCyGtigeyfNc2uqqX)YkxOzGskjqrfF3Rt3mGNd8fC3YVcKVPbgSXnXIvwJAGaqaRfs9tbY)cQhq46Ox4CqaRfs9tbY)cQhq4MkHVo6fwjfuqX3960nd45aFb3T8Ra5BAGbBCtSyLBGaqaRfs9tbY)cQhq46Ox4CdusjbGawlSbcK7wUOBInC6MHGnfeu8VSYZqnJaRiKe5BwW2aB(McIl(N0i6pMhliUwy84A88rgaOEYOG7woj0bB)kuMzZF3Rt3mGNd8fC3YVcKVPbgSXnXIvUbcabSwi1pfi)lOEaHRJEHhl3qcE3Rt3mGu)uGCr3eByJBIfRXYh(PckCupGh8yBKFoFYWXE3Rt3mGu)uGCr3eByJBIflPr0FmpwqCTW4X145Jmaq9Krb3TCsOd2(vOmZM)UxNUzaP(Pa5IUj2Wg3elw5giqrd)OkgheJkBO4WaNqmiWkovqbfpQIXbXOYgkomWjedcSItbBkiO4FzLl0mqjLeOOIV71PBgWZb(cUB5xbY30ad24MyXkRrnqaiG1cP(Pa5Fb1diCD0lCoiG1cP(Pa5Fb1diCtLWxh9cRKckO47ED6Mb8CGVG7w(vG8nnWGnUjwSYnqaiG1cP(Pa5Fb1diCD0lCUbkPKaqaRf2abYDlx0nXgoDZqWMcck(xw5zOMrGvesI8nlyBGnFtbXf)tAe9hZJfexlmECnE(iVhpgxtho52kTrLRSa5)m34OmZMdcyTqQFkqUOBInC6MHaqaRf2abYDlx0nXgoDZqWebbSw45aFb3T8Ra5BAGbNUziytbbp2g5NZ3ujzLJLGpWH8JTrPr0FmpwqCTW4X145J0ijYIbUTsBCPmZMdcyTqQFkqUOBInC6MHaqaRf2abYDlx0nXgoDZqWebbSw45aFb3T8Ra5BAGbNUziytbbp2g5NZ3ujzLJLGpWH8JTrPr0FmpwqCTW4X145Jy9hyHtoj0bB2HCqK2kZS5GawlK6NcKl6MydNUziaeWAHnqGC3YfDtSHt3memrqaRfEoWxWDl)kq(MgyWPBgsJO)yESG4AHXJRXZhreOz2szXahSsRtzMnheWAHu)uGCr3eB40ndbGawlSbcK7wUOBInC6MHGjccyTWZb(cUB5xbY30adoDZqAe9hZJfexlmECnE(intuSICwWxI0JkZS5GawlK6NcKl6MydNUziaeWAHnqGC3YfDtSHt3memrqaRfEoWxWDl)kq(MgyWPBgsJO)yESG4AHXJRXZh5kqoqa6aXKB9(rLz2CqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndPr0FmpwqCTW4X145JSXT3LYDlVc8SjF2iTxkZS5GawlK6NcKl6MydNUziaeWAHnqGC3YfDtSHt3memrqaRfEoWxWDl)kq(MgyWPBgsJKgr)X8ybTSGQCqGoYP(Pa5B2AXQ4szMnheWAHFfP(P1XIbyJ0Fk)felYhvAe9hZJf0YcQYbb6y88rO(Pa5GvADsJO)yESGwwqvoiqhJNpc1pfihK6MgqPrsJO)yESGBpdUX4YxfS9gBLz28TNb3yCWjBDu8yw5JAG0i6pMhl42ZGBmUXZhrSXfgpYDlFZIP0i6pMhl42ZGBmUXZhH6NcKVzRfRIlLz28TNb3yCWjBDu84yJAG0i6pMhl42ZGBmUXZhH6NcK7nO0iPrcHsn9hZJf0fXa78muZiWkQCqBmVGYGCxedCQSlMVWt5mufaZhvzMnxSXm8HFchfIz8NoMhsJO)yESGUigypE(iv2qXT4czaMdBmoLz2CqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndPr0FmpwqxedShpFeqAG7w(1Sx4LYmBoiG1cP(Pa5IUj2WPBgcabSwydei3TCr3eB40ndbteeWAHNd8fC3YVcKVPbgC6MH0i6pMhlOlIb2JNpcWc5Sd3lLz2CqaRfs9tbYfDtSHaIsJO)yESGUigypE(iGyVWwywmOmZMdcyTqQFkqUOBInequAe9hZJf0fXa7XZhbS6(KBb6svMzZbbSwi1pfix0nXgciknI(J5Xc6IyG945JyzncwDFQmZMdcyTqQFkqUOBInequAe9hZJf0fXa7XZhHIhxxtv(t1QYmBoiG1cP(Pa5IUj2qarPr0FmpwqxedShpFelRroyLwNYmBEdeO17beozRNjwzb1LYFFVPycrJfGjkItbGawlCYwptSYcQlL)(EtXKBBFDqarPr0FmpwqxedShpFeB7RJhEgszMnVbc069achA2QwkN9SVIq0ybyII4uWMcck(xwgxHsAe9hZJf0fXa7XZhzZ627f3T8Z7ngN0i6pMhlOlIb2JNpYePRa07aLgr)X8ybDrmWE88rAAYO44lrQfwzMnFtbbf)lldRbsJO)yESGUigypE(ipfpw50FmpuMzZP)yEaxfm7XIbUOBIn8lOiWklgKgr)X8ybDrmWE88rwfm7XIbUOBITYmB(YbQGSycTmSo5ULdw91Y3ligeyfNsJO)yESGUigypE(iNd8fC3YVcKVPbM0i6pMhlOlIb2JNpc1pfix0nXwAe9hZJf0fXa7XZhPbcK7wUOBITYmBoiG1cBGa5ULl6MydNUzinI(J5Xc6IyG945JaSq(McIpGBLz2CfpQIXbXOYgkomWjedcSItbBkiO4FJLlKmqWMcck(xw5ghHsjfuqrd)OkgheJkBO4WaNqmiWkofSPGGI)nwUqsOusAe9hZJf0fXa7XZhbe7f2cZIbLz2CqaRfs9tbYfDtSHaIsJO)yESGUigypE(ihBJCtQfvMzZBGaTEpGWd3IEtvUj1Iq0ybyII4uAe9hZJf0fXa7XZhrSXfgpYDlFZIPYmB(ebbSw45aFb3T8Ra5BAGbbefmrqaRfEoWxWDl)kq(MgyWg3elwJLdcyTqXgxy8i3T8nlMWnvcFD0lSHz6pMhqQFkqoyLwhelbFGd5hBJsJO)yESGUigypE(iu)uGCWkToLz28PFWMMmko(sKAHHnUjwSYsOuqHjccyTWMMmko(sKAH5zaQb2eiRYUsHRJEHZYaPr0FmpwqxedShpFeQFkqoyLwNYmBoiG1cfBCHXJC3Y3SycbefmrqaRfEoWxWDl)kq(MgyqarbteeWAHNd8fC3YVcKVPbgSXnXI1y50FmpGu)uGCWkToiwc(ahYp2gLgr)X8ybDrmWE88rO(Pa5Gu30aQmZMdcyTqQFkqUOBInequaiG1cP(Pa5IUj2Wg3elwJLp8tbGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lS0i6pMhlOlIb2JNpc1pfiFZwlwfxkZS5teeWAHNd8fC3YVcKVPbgequWrvmoi1pfih)chIbbwXPaqaRfor6ka9oq40ndbteeWAHNd8fC3YVcKVPbgSXnXIvw0FmpGu)uG8nBTyvCbXsWh4q(X2OYFbXI8rLgr)X8ybDrmWE88rO(Pa5B2AXQ4szMnheWAHFfP(P1XIbyJ0Fk)felYhvAe9hZJf0fXa7XZhH6NcK7nOYmBoiG1cP(Pa5Fb1diCD0l8y5gsGIV71PBgqQFkqUOBInSXnXIvwJAGckq)XYGCmWndxJLBiLKgr)X8ybDrmWE88rO(Pa5GvADkZS5GawlSbcK7wUOBInequbf2uqqX)YAuHsAe9hZJf0fXa7XZhbZ4pDmpuMzZbbSwydei3TCr3eB40ndLzXHDdiECMnFtbbf)lRCHKqPmloSBaXJZ2BCYOdZhvAe9hZJf0fXa7XZhH6NcKdsDtdO0iPr0FmpwW2p6yEKNHAgbwrLdAJ5wwqvoiqhk7I5l8uodvbW8rvMzZbbSwi1pfi)lOEaHRJEHZbbSwi1pfi)lOEaHBQe(6OxybgoiG1cBGkYDl)kAexqarbh1d4bp2g5NZNmCSCfvCtbj0v6pMhqQFkqoyLwh891PKHz6pMhqQFkqoyLwhelbFGd5hBJkjnI(J5Xc2(rhZJXZhH6NcKdsDtdOYmB(ebbSwyttgfhFjsTW8ma1aBcKvzxPW1rVW5teeWAHnnzuC8Li1cZZaudSjqwLDLc3uj81rVWcueeWAHnqGC3YfDtSHt3muqbqaRf2abYDlx0nXg24MyXAS8HFQK0i6pMhly7hDmpgpFeQFkqoyLwNYmB(0pyttgfhFjsTWWg3elwzjukOWebbSwyttgfhFjsTW8ma1aBcKvzxPW1rVWzzG0i6pMhly7hDmpgpFeQFkqoyLwNYmBoiG1cfBCHXJC3Y3SycbefmrqaRfEoWxWDl)kq(MgyqarbteeWAHNd8fC3YVcKVPbgSXnXI1y50FmpGu)uGCWkToiwc(ahYp2gLgr)X8ybB)OJ5X45Jq9tbY3S1IvXLYmB(ebbSw45aFb3T8Ra5BAGbbefCufJds9tbYXVWHyqGvCkaeWAHtKUcqVdeoDZqGIteeWAHNd8fC3YVcKVPbgSXnXIvw0FmpGu)uG8nBTyvCbXsWh4q(X2Ock8UxNUzafBCHXJC3Y3SycBCtSyLLbkOW7zWGIdkCPnJcigeyfNkP8xqSiFuPr0FmpwW2p6yEmE(iu)uG8nBTyvCPmZMdcyTWVIu)06yXaSr6pbGawlelrKIjo5I(HXXOkequAe9hZJfS9JoMhJNpc1pfiFZwlwfxkZS5Gawl8Ri1pTowmaBK(tGIGawlK6NcKl6MydbevqbqaRf2abYDlx0nXgciQGcteeWAHNd8fC3YVcKVPbgSXnXIvw0FmpGu)uG8nBTyvCbXsWh4q(X2Osk)felYhvAe9hZJfS9JoMhJNpc1pfiFZwlwfxkZS5Gawl8Ri1pTowmaBK(taiG1c)ks9tRJfdW1rVW5Gawl8Ri1pTowma3uj81rVWk)felYhvAe9hZJfS9JoMhJNpc1pfiFZwlwfxkZS5Gawl8Ri1pTowmaBK(taiG1c)ks9tRJfdWg3elwJLROIGawl8Ri1pTowmaxh9cByM(J5bK6NcKVzRfRIliwc(ahYp2gvA8HFQKYFbXI8rLgr)X8ybB)OJ5X45Je4vGn)WTiUoLz2CfB024QGaROcky4h7fMfdkjaeWAHu)uG8VG6beUo6foheWAHu)uG8VG6beUPs4RJEHfacyTqQFkqUOBInC6MHGjccyTWZb(cUB5xbY30adoDZqAe9hZJfS9JoMhJNpc1pfi3BqLz2CqaRfs9tbY)cQhq46Ox4XYnK0i6pMhly7hDmpgpFKfGi2HNHuMzZ3uqqX)gl34kucabSwi1pfix0nXgoDZqaiG1cBGa5ULl6MydNUziyIGawl8CGVG7w(vG8nnWGt3mKgr)X8ybB)OJ5X45JSky2JfdCr3eBLz2CqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndbV71PBgqmJ)0X8a24MyXklde8UxNUzaP(Pa5IUj2Wg3elwzzGG3960nd45aFb3T8Ra5BAGbBCtSyLLbcu0WpQIXbBGa5ULl6MydXGaR4ubfu8OkghSbcK7wUOBInedcSItbV71PBgWgiqUB5IUj2Wg3elwzzGskjnI(J5Xc2(rhZJXZhH6NcKdwP1PmZMdcyTWgOIC3YVIgXfequaiG1cP(Pa5Fb1diCD0lCwgJ0iHqPUCRqVuBysQfIJBpdk1cbOdBPr0FmpwW2p6yEmE(iu)uGCqQBAavMzZ3uqqX)gld1mcSIqqQBAa5BkiU4FcE3Rt3mGyg)PJ5bSXnXIvwgiaeWAHu)uGCr3eB40ndbGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lSaCTW4ryg2I5b3TCrST4FmpGBw4T0i6pMhly7hDmpgpFeQFkqoi1nnGkZS5V71PBgWZb(cUB5xbY30ad24MyXk3abk(UxNUzaBGa5ULl6MydBCtSyLBGck8UxNUzaP(Pa5IUj2Wg3elw5gOKaqaRfs9tbY)cQhq46Ox4CqaRfs9tbY)cQhq4MkHVo6fwAe9hZJfS9JoMhJNpc1pfihK6MgqLz28nfeu8VXYZqnJaRieK6Mgq(McIl(NaqaRfs9tbYfDtSHt3meacyTWgiqUB5IUj2WPBgcMiiG1cph4l4ULFfiFtdm40ndbGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lSG3960ndiMXF6yEaBCtSyLLbsJO)yESGTF0X8y88rO(Pa5Gu30aQmZMdcyTqQFkqUOBInC6MHaqaRf2abYDlx0nXgoDZqWebbSw45aFb3T8Ra5BAGbNUziaeWAHu)uG8VG6beUo6foheWAHu)uG8VG6beUPs4RJEHfCufJds9tbY9geIbbwXPG3960ndi1pfi3BqyJBIfRXYh(PGnfeu8VXYnUgi4DVoDZaIz8NoMhWg3elwzzG0i6pMhly7hDmpgpFeQFkqoi1nnGkZS5GawlK6NcKl6MydbefacyTqQFkqUOBInSXnXI1y5d)uaiG1cP(Pa5Fb1diCD0lCoiG1cP(Pa5Fb1diCtLWxh9clnI(J5Xc2(rhZJXZhH6NcKdsDtdOYmBoiG1cBGa5ULl6MydbefacyTWgiqUB5IUj2Wg3elwJLp8tbGawlK6NcK)fupGW1rVW5GawlK6NcK)fupGWnvcFD0lS0i6pMhly7hDmpgpFeQFkqoyLwN0i6pMhly7hDmpgpFemJ)0X8qzwCy3aIhNzZ3uqqX)YkxijukZId7gq84S9gNm6W8rLgr)X8ybB)OJ5X45Jq9tbYbPUPbmPsaxH3jvv2gOshZdHynzV0LUuc]] )


end
