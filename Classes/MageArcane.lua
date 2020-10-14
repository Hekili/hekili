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

                if legendary.siphon_storm.enabled then
                    applyBuff( "siphon_storm" )
                end
            end,

            tick = function ()
                if legendary.siphon_storm.enabled then
                    addStack( "siphon_storm", nil, 1 )
                end
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
        fontSize = "medium",
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


    spec:RegisterPack( "Arcane", 20201014, [[d4e0Kdqiku8ikuPlrquvTjc8jku1OiHofjYQiiv1RuOAwKOUfbbQDH4xkuggf4ysuTmkOEgfknnki6AeKSnkuX3iiLXrqKZrqiRJGGMNcP7jQ2NOuhKccTqfIhsqatKGOk6IeevjFKGaPrsquL6KeKkTskKxsqQOzsbb3KGOQStjk)KGuHHsqufwkbrLNsstvI0vjiv5ReeiglbrzVI8xKgmPom0Ib6XQAYk5YO2mL(ScgTeonOvtqO61euZws3wP2nv)wy4e64uqA5s9CfnDvUoGTlk(ofnEjIZlkz9eekZNeSFIovEQ0K6cpovMHnWWguUbLBijgyGXAq5cPK6LLiNufXxyCGtQoU5KQHy)OZjvrmRAGRuPj1za0pNulUtCkeo2ydWRaaK8XESjCduXdg(3O9gBc3)yjvqay9e66jWK6cpovMHnWWguUbLBijgyGXAq5gYK6uK)uzghdNulGRf7jWK6INFs14k1c5dhyP2qSF0zPrgxPwOJ)cqUL6YnwLLAdBGHniPwHZBMknPgISZDQ0uzLNknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MSctxQfi1GawlPbCMgwQyyYnzfMUulqQxmiG1sUa4lOHLEfmDJdqYkm9Kk(hm8KAfouCtQqCG1WM9lDPYmCQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0tQ4FWWtQG4anS0RHVWZ0LkZytLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQpwRu8py40kCEj1kCEuh3CsfE8EMUuzgYuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3eaXKk(hm8KQyCWWtxQmHkvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpPcY9KBHH(q6sLzCsLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQG1iwulqNv6sLj0sLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQwyZG1iwPlvMqkvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpPI(ZZRXk9XAnDPYeIsLMuzhbR8knss9B4XnetQnGZ2OhyYcoFOyf6yNf9J9g9fHnuaOOiVKAbsniG1swW5dfRqh7SOFS3OVO2oMhbqmPI)bdpPAHntbR48sxQSYnivAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcBOaqrrEj1cK6n6ir8pPoBPwisOsQ4FWWtQ2oMh1Jmy6sLvE5PstQ4FWWtQBy3rpPHLErVz)sQSJGvELgjDPYk3WPstQ4FWWtQlgVcWODoPYocw5vAK0LkRCJnvAsLDeSYR0ij1VHh3qmPUrhjI)j1zl1gsdsQ4FWWtQnUGOF0Pi2cNUuzLBitLMuzhbR8knss9B4XnetQ4FWWjZcO9G(avmm5M8fO7Cf6dsTaPE4xKM3i0NsDUuBqsf)dgEs9r)5kf)dgE6sLvUqLknPYocw5vAKK63WJBiMuNbqfe6lIfY1fnSuWAmNXEsyhbR8kPI)bdpPolG2d6duXWK70LkRCJtQ0Kk(hm8K6faFbnS0RGPBCaMuzhbR8kns6sLvUqlvAsf)dgEsf7hDMkgMCNuzhbR8kns6sLvUqkvAsLDeSYR0ij1VHh3qmPccyTKgWzAyPIHj3Kvy6jv8py4j1gWzAyPIHj3Plvw5crPstQSJGvELgjP(n84gIjvfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9O5sTqYaPwGuVrhjI)j1zNl1ghHsQvsQvqbPwrP2yK6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9O5sTqsOKALsQ4FWWtQB0r6aVtxQmdBqQ0Kk7iyLxPrsQFdpUHysTbC2g9atoElgnwPMylsydfakkYRKk(hm8K6b3m1eBX0LkZWLNknPYocw5vAKK63WJBiMuxmiG1sUa4lOHLEfmDJdqcGOulqQxmiG1sUa4lOHLEfmDJdqsZBe6tPE0CPgeWAjInpz)zAyPBOViBSe68WxyPwOVuJ)bdNG9JotbR48iCj8dCm9GBoPI)bdpPk28K9NPHLUH(kDPYmSHtLMuzhbR8knss9B4XnetQR4inUGOF0Pi2ctAEJqFk1zl1cLuRGcs9IbbSwsJli6hDkITW0mavNBeewHxwK5HVWsD2sTbjv8py4jvSF0zkyfNx6sLzyJnvAsLDeSYR0ij1VHh3qmPccyTeXMNS)mnS0n0xearPwGuVyqaRLCbWxqdl9ky6ghGearPwGuVyqaRLCbWxqdl9ky6ghGKM3i0Ns9O5sn(hmCc2p6mfSIZJWLWpWX0dU5Kk(hm8Kk2p6mfSIZlDPYmSHmvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbquQfi1Gawlb7hDMkgMCtAEJqFk1JMl1d)sQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWjv8py4jvSF0zki2noWPlvMHfQuPjv2rWkVsJKuX)GHNuX(rNPB4CcR8mP(fi0tQLNu)gECdXK6IbbSwYfaFbnS0RGPBCasaeLAbs9Hv2pc2p6mL)IGWocw5LulqQbbSwYIXRamANjRW0LAbs9IbbSwYfaFbnS0RGPBCasAEJqFk1zl14FWWjy)OZ0nCoHvEs4s4h4y6b3C6sLzyJtQ0Kk7iyLxPrsQ4FWWtQy)OZ0nCoHvEMu)ce6j1YtQFdpUHysfeWAjFLX(X5b9bsZ4FPlvMHfAPstQSJGvELgjP(n84gIjvqaRLG9Jot)cShyY8WxyPE0CP2WsTaPwrP(JOUctNG9JotfdtUjnVrOpL6SL6YnqQvqbPg)dMHPSZBipL6rZLAdl1kLuX)GHNuX(rNPrdMUuzgwiLknPYocw5vAKK63WJBiMubbSwsd4mnSuXWKBcGOuRGcs9gDKi(NuNTuxUqLuX)GHNuX(rNPGvCEPlvMHfIsLMuzhbR8knssf)dgEsLZepEWWtQq)4Ubepk0Mu3OJeX)YoxijujvOFC3aIhfU38cIhNulpP(n84gIjvqaRL0aotdlvmm5MSctpDPYmwdsLMuX)GHNuX(rNPGy34aNuzhbR8kns6sxsLNt2FEMknvw5PstQSJGvELgjP(n84gIj1pI6kmDYfaFbnS0RGPBCasAEJqFk15sTbsTaPgeWAjy)OZ0Va7bMmp8fwQhnxQnSulqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTcki1h2d8ro4MPxqxqwQhvQ)iQRW0jy)OZuXWKBsZBe6ZKk(hm8KkynIfnS0RGPSZ7SsxQmdNknPYocw5vAKK63WJBiMu)iQRW0jy)OZuXWKBsZBe6tPoxQnqQfi1kk1gJuFyL9JWEfouCSZlc7iyLxsTcki1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6SZLAHMbsTssTssTaPwrPwrP(JOUctNCbWxqdl9ky6ghGKM3i0NsD2sD5gi1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTbsTaPgeWAjy)OZ0Va7bMmp8fwQZLAdKALKALKAbsniG1sAaNPHLkgMCtwHPl1cK6n6ir8pPo7CPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4jvWAelAyPxbtzN3zLUuzgBQ0Kk7iyLxPrsQFdpUHys9JOUctNCbWxqdl9ky6ghGKM3i0NsDUuBGulqQbbSwc2p6m9lWEGjZdFHL6rZLAdl1cK6pI6kmDc2p6mvmm5M08gH(uQhnxQh(LuRGcs9H9aFKdUz6f0fKL6rL6pI6kmDc2p6mvmm5M08gH(mPI)bdpPAgDDLHHoT5z4O)C6sLzitLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gi1cKAfLAJrQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsD25sTqZaPwjPwjPwGuROuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoBPUCdKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGudcyTeSF0z6xG9atMh(cl15sTbsTssTssTaPgeWAjnGZ0WsfdtUjRW0LAbs9gDKi(NuNDUuNbBicwzcks3qhUb20n6iv8VKk(hm8KQz01vgg60MNHJ(ZPlvMqLknPYocw5vAKK63WJBiMu)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cKAqaRLG9Jot)cShyY8WxyPE0CP2WsTaP(JOUctNG9JotfdtUjnVrOpL6rZL6HFj1kOGuFypWh5GBMEbDbzPEuP(JOUctNG9JotfdtUjnVrOptQ4FWWtQdayVGOtdlffIXDCfPlvMXjvAsLDeSYR0ij1VHh3qmP(ruxHPtW(rNPIHj3KM3i0NsDUuBGulqQvuQngP(Wk7hH9kCO4yNxe2rWkVKAfuqQvuQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1zNl1cndKALKALKAbsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6SL6YnqQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWsTssTcki1kk1Fe1vy6Kla(cAyPxbt34aK08gH(uQZLAdKAbsniG1sW(rNPFb2dmzE4lSuNl1gi1kj1kj1cKAqaRL0aotdlvmm5MSctxQfi1B0rI4FsD25sDgSHiyLjOiDdD4gyt3OJuX)sQ4FWWtQdayVGOtdlffIXDCfPlvMqlvAsLDeSYR0ijv8py4j1p8N9RXJxuBf3Cs9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMUulqQ3OJKdUz6f0nwIuNDUuZLWpWX0dU5KAf6m9xjvJt6sLjKsLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMUulqQ3OJKdUz6f0nwIuNDUuZLWpWX0dU5Kk(hm8KAZOi0hO2kU5z6sLjeLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MSctxQfi1GawlPbCMgwQyyYnzfMUulqQxmiG1sUa4lOHLEfmDJdqYkm9Kk(hm8KQnEGjVOOqmUHhtbzCNUuzLBqQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0tQ4FWWtQIan0Mf0hOGvCEPlvw5LNknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MSctxQfi1GawlPbCMgwQyyYnzfMUulqQxmiG1sUa4lOHLEfmDJdqYkm9Kk(hm8KAdffRmf60Pi(C6sLvUHtLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtwHPl1cKAqaRL0aotdlvmm5MSctxQfi1lgeWAjxa8f0WsVcMUXbizfMEsf)dgEs9kykGdga(IAJ(50LkRCJnvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnzfMUulqQbbSwsd4mnSuXWKBYkmDPwGuVyqaRLCbWxqdl9ky6ghGKvy6jv8py4j1nVJolAyPvGhUORMX9mDPlPcpEptLMkR8uPjv8py4jvGjtHhVNjv2rWkVsJKU0Lu)iQRW0NPstLvEQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0tQ4FWWtQv4qXnPcXbwdB2V0LkZWPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpPcId0WsVg(cptxQmJnvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpP(yTsX)GHtRW5LuRW5rDCZjv4X7z6sLzitLMuzhbR8knss9B4XnetQGawlb7hDMkgMCtaetQ4FWWtQIXbdpDPYeQuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3eaXKk(hm8Kki3tUfg6dPlvMXjvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpPcwJyrTaDwPlvMqlvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyYnbqmPI)bdpPAHndwJyLUuzcPuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3eaXKk(hm8Kk6ppVgR0hR10LktikvAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcBOaqrrEj1cK6pI6kmDc2p6mvmm5M08gH(uQZwQnwdKAbs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGuROudcyTeSF0z6xG9atMh(cl1JMl1gwQfi1kk1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPE0CPE4xsTaP(JOUctNG9JotfdtUjnVrOpL6SL6mydrWktU420nwcDXvmlPwjPwbfKAfLAJrQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuNTuNbBicwzYf3MUXsOlUIzj1kj1kOGu)ruxHPtW(rNPIHj3KM3i0Ns9O5s9WVKALKALsQ4FWWtQ2oMh1Jmy6sLvUbPstQSJGvELgjP(n84gIj1gWzB0dmzOHZAwu4d)ktydfakkYlPwGu)ruxHPtW(rNPIHj3KM3i0NsDUuBGulqQvuQngP(Wk7hH9kCO4yNxe2rWkVKAfuqQvuQpSY(ryVchko25fHDeSYlPwGuVrhjI)j1zNl1cndKALKALKAbsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6SL6YnqQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWsTssTcki1kk1Fe1vy6Kla(cAyPxbt34aK08gH(uQZLAdKAbsniG1sW(rNPFb2dmzE4lSuNl1gi1kj1kj1cKAqaRL0aotdlvmm5MSctxQfi1B0rI4FsD25sDgSHiyLjOiDdD4gyt3OJuX)sQ4FWWtQ2oMh1Jmy6sLvE5PstQSJGvELgjP(n84gIj1gWzB0dmzbNpuScDSZI(XEJ(IWgkauuKxsTaP(JOUctNacyT0fC(qXk0Xol6h7n6lsZ4klPwGudcyTKfC(qXk0Xol6h7n6lQTJ5rwHPl1cKAfLAqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQvsQfi1Fe1vy6Kla(cAyPxbt34aK08gH(uQZLAdKAbsTIsniG1sW(rNPFb2dmzE4lSupAUuByPwGuROuROuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jnGZ0WsfdtUjnVrOpL6rZL6HFj1cK6pI6kmDc2p6mvmm5M08gH(uQZwQZGnebRm5IBt3yj0fxXSKALKAfuqQvuQngP(Wk7hPbCMgwQyyYnHDeSYlPwGu)ruxHPtW(rNPIHj3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLuRKuRGcs9hrDfMob7hDMkgMCtAEJqFk1JMl1d)sQvsQvkPI)bdpPA7yEGr9sxQSYnCQ0Kk7iyLxPrsQFdpUHysTbC2g9atwW5dfRqh7SOFS3OViSHcaff5LulqQ)iQRW0jGawlDbNpuScDSZI(XEJ(I0mUYsQfi1GawlzbNpuScDSZI(XEJ(IAHntwHPl1cKAXMZqh(fPCITJ5bg1lPI)bdpPAHntbR48sxQSYn2uPjv2rWkVsJKu)gECdXK6hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGudcyTeSF0z6xG9atMh(cl1JMl1gwQfi1Fe1vy6eSF0zQyyYnP5nc9PupAUup8RKk(hm8K6g2D0tAyPx0B2V0LkRCdzQ0Kk7iyLxPrsQFdpUHys9JOUctNG9JotfdtUjnVrOpL6CP2aPwGuROuBms9Hv2pc7v4qXXoViSJGvEj1kOGuROuFyL9JWEfouCSZlc7iyLxsTaPEJose)tQZoxQfAgi1kj1kj1cKAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnqQfi1Gawlb7hDM(fypWK5HVWsDUuBGuRKuRKulqQbbSwsd4mnSuXWKBYkmDPwGuVrhjI)j1zNl1zWgIGvMGI0n0HBGnDJosf)lPI)bdpPUHDh9Kgw6f9M9lDPYkxOsLMuzhbR8knss9B4XnetQFe1vy6Kla(cAyPxbt34aK08gH(uQZLAdKAbsniG1sW(rNPFb2dmzE4lSupAUuByPwGu)ruxHPtW(rNPIHj3KM3i0Ns9O5s9WVsQ4FWWtQlgVcWODoDPYk34KknPYocw5vAKK63WJBiMu)iQRW0jy)OZuXWKBsZBe6tPoxQnqQfi1kk1gJuFyL9JWEfouCSZlc7iyLxsTcki1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6SZLAHMbsTssTssTaPwrPwrP(JOUctNCbWxqdl9ky6ghGKM3i0NsD2sD5gi1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTbsTaPgeWAjy)OZ0Va7bMmp8fwQZLAdKALKALKAbsniG1sAaNPHLkgMCtwHPl1cK6n6ir8pPo7CPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4j1fJxby0oNUuzLl0sLMuzhbR8knss9B4XnetQFe1vy6Kla(cAyPxbt34aK08gH(uQZwQZGnebRmPN0nwcDXvmlPwGu)ruxHPtW(rNPIHj3KM3i0NsD2sDgSHiyLj9KUXsOlUIzj1cKAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwbfK6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PuNTuNbBicwzspPBSe6IRywsTcki1gJuFyL9J0aotdlvmm5MWocw5LuRKulqQbbSwc2p6m9lWEGjZdFHL6SLAdl1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpP24cI(rNIylC6sLvUqkvAsLDeSYR0ij1VHh3qmP(ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnqQfi1Gawlb7hDM(fypWK5HVWs9O5sTHLAbs9hrDfMob7hDMkgMCtAEJqFk1JMl1d)kPI)bdpP24cI(rNIylC6sLvUquQ0Kk7iyLxPrsQFdpUHys9JOUctNG9JotfdtUjnVrOpL6CP2aPwGuROuROuBms9Hv2pc7v4qXXoViSJGvEj1kOGuROuFyL9JWEfouCSZlc7iyLxsTaPEJose)tQZoxQfAgi1kj1kj1cKAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnqQfi1Gawlb7hDM(fypWK5HVWsDUuBGuRKuRKulqQbbSwsd4mnSuXWKBYkmDPwGuVrhjI)j1zNl1zWgIGvMGI0n0HBGnDJosf)tQvkPI)bdpP24cI(rNIylC6sLzydsLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWs9O5sTHLAbs9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctN0aotdlvmm5M08gH(uQhnxQh(LulqQ)iQRW0jy)OZuXWKBsZBe6tPoBPod2qeSYKlUnDJLqxCfZsQfi1FKHD0pIWz1q0LAbs9hrDfMoPXfe9JofXwysZBe6tPE0CPwiLuX)GHNuVa4lOHLEfmDJdW0LkZWLNknPYocw5vAKK63WJBiMubbSwc2p6m9lWEGjZdFHL6rZLAdl1cK6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLulqQngP(JmSJ(reoRgIEsf)dgEs9cGVGgw6vW0noatxQmdB4uPjv2rWkVsJKu)gECdXKkiG1sW(rNPFb2dmzE4lSupAUuByPwGuBms9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctNG9JotfdtUjnVrOpL6SL6mydrWktU420nwcDXvmRKk(hm8K6faFbnS0RGPBCaMUuzg2ytLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWs9O5sTHLAbs9hrDfMob7hDMkgMCtAEJqFk1JMl1d)kPI)bdpPEbWxqdl9ky6ghGPlvMHnKPstQSJGvELgjP(n84gIjvfLAJrQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsD25sTqZaPwjPwjPwGu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoBPod2qeSYeuKUXsOlUIzj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwGudcyTKgWzAyPIHj3Kvy6sTaPEJose)tQZoxQZGnebRmbfPBOd3aB6gDKk(xsf)dgEsf7hDMkgMCNUuzgwOsLMuzhbR8knss9B4XnetQGawlPbCMgwQyyYnzfMUulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNTuNbBicwzshI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1cKAfL6pI6kmDc2p6mvmm5M08gH(uQZwQlxOKAfuqQxmiG1sUa4lOHLEfmDJdqcGOuRusf)dgEsTbCMgwQyyYD6sLzyJtQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQZLAdKAbs9hzyh9JiCwne9Kk(hm8KQyZt2FMgw6g6R0LkZWcTuPjv2rWkVsJKu)gECdXK6IbbSwYfaFbnS0RGPBCasaeLAbsTXi1FKHD0pIWz1q0tQ4FWWtQInpz)zAyPBOVsxQmdlKsLMuzhbR8knss9B4XnetQFe1vy6eot84bdN08gH(uQZwQnqQfi1kk1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6rZLAHKbsTaPEJose)tQZoxQnocLuRKuRGcsTIsTXi1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6rZLAHKqj1kj1kLuX)GHNu3OJ0bENU0Lu3rgEZ(Lknvw5PstQSJGvELgjP(n84gIj1DKH3SFKfCEO)SuNDUuxUbjv8py4jvWk0foDPYmCQ0Kk(hm8KQyZt2FMgw6g6RKk7iyLxPrsxQmJnvAsLDeSYR0ij1VHh3qmPUJm8M9JSGZd9NL6rL6YniPI)bdpPI9Jot3W5ew5z6sLzitLMuX)GHNuX(rNPrdMuzhbR8kns6sLjuPstQ4FWWtQwyZuWkoVKk7iyLxPrsx6sQIn)XgeVuPPYkpvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvdsQzWM64MtQInlcuRuotKUuzgovAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWj1YtQFdpUHysTbC2g9atMqXIWPZl6nHnuaOOiVKAbsn(hmdtzN3qEk1zl1goPMbBQJBoPk2SiqTs5mr6sLzSPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwEs9B4XnetQnGZ2OhyYekweoDErVjSHcaff5LulqQ)id7OFeN)oQrVKAbsn(hmdtzN3qEk1zl1LNuZGn1XnNufBweOwPCMiDPYmKPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwEs9B4XnetQnGZ2OhyYekweoDErVjSHcaff5LulqQ)id7OFehouCulYj1mytDCZjvXMfbQvkNjsxQmHkvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvdsQzWM64MtQwOJvkiq7PlvMXjvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvHkPMbBQJBoP2t6glHU4kMv6sLj0sLMuzhbR8knssnetQt(sQ4FWWtQzWgIGvoPMbRaCsTCdsQzWM64MtQOiDJLqxCfZkDPYesPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPAydsQzWM64MtQDis3yj0fxXSsxQmHOuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNufQKAgSPoU5K6f3MUXsOlUIzLUuzLBqQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQgBs9B4XnetQnGZ2OhyYcoFOyf6yNf9J9g9fHnuaOOiVsQzWM64MtQxCB6glHU4kMv6sLvE5PstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwUqLu)gECdXK6hzyh9J4WHIJAroPMbBQJBoPEXTPBSe6IRywPlvw5govAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWj1YfQK63WJBiMu)WxaWJG9Jotf7ybhYIWocw5LulqQX)Gzyk78gYtPEuP2ytQzWM64MtQxCB6glHU4kMv6sLvUXMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQXAqs9B4XnetQ8CY(ZKmWjmCAyPICB5)GHt2qp6KAgSPoU5K6f3MUXsOlUIzLUuzLBitLMuzhbR8knssnetQt(sQ4FWWtQzWgIGvoPMbRaCsviYGKAgSPoU5Kki2noW0n6iv8V0LkRCHkvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvHKbj1VHh3qmP(rg2r)ioCO4OwKtQzWM64MtQGy34at3OJuX)sxQSYnoPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPASgKuZGn1XnNurr6g6WnWMUrhPI)LUuzLl0sLMuzhbR8knssnetQt(sQ4FWWtQzWgIGvoPMbRaCsvOmiP(n84gIj1gWzB0dmzbNpuScDSZI(XEJ(IWgkauuKxj1mytDCZjvuKUHoCdSPB0rQ4FPlvw5cPuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNufkdsQFdpUHysTbC2g9atgA4SMff(WVYe2qbGII8kPMbBQJBoPII0n0HBGnDJosf)lDPYkxikvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvdNuZGn1XnNuXGPxCB6xG9aptxQmdBqQ0Kk(hm8K6eyVdNI9JotT4gwHyNuzhbR8kns6sLz4YtLMuX)GHNuX(rNPq)4AL)lPYocw5vAK0LkZWgovAsf)dgEs9dxioqZ0n6iDG3jv2rWkVsJKUuzg2ytLMuX)GHNu3WUJMc34aNuzhbR8kns6sLzydzQ0Kk7iyLxPrsQFdpUHysnd2qeSYeXMfbQvkNjK6CP2aPwGu3aoBJEGjl48HIvOJDw0p2B0xe2qbGII8sQfi1Fe1vy6eqaRLUGZhkwHo2zr)yVrFrAgxzj1cKAqaRLSGZhkwHo2zr)yVrFrTDmpYkm9Kk(hm8KQTJ5bg1lDPYmSqLknPYocw5vAKK63WJBiMuZGnebRmrSzrGALYzcPoxQlpPI)bdpPYzIhpy4PlDjvm4uPPYkpvAsLDeSYR0ij1VHh3qmPQOuFyL9JWEfouCSZlc7iyLxsTaPEJose)tQhnxQfsgi1cK6n6ir8pPo7CP24iusTssTcki1kk1gJuFyL9JWEfouCSZlc7iyLxsTaPEJose)tQhnxQfscLuRusf)dgEsDJosh4D6sLz4uPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3Kvy6jv8py4j1kCO4MuH4aRHn7x6sLzSPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0tQ4FWWtQG4anS0RHVWZ0LkZqMknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNuFSwP4FWWPv48sQv48OoU5Kk849mDPYeQuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3eaXKk(hm8KQyCWWtxQmJtQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGysf)dgEsfK7j3cd9H0LktOLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNubRrSOwGoR0LktiLknPYocw5vAKK63WJBiMubbSwc2p6mvmm5MaiMuX)GHNuTWMbRrSsxQmHOuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3eaXKk(hm8Kk6ppVgR0hR10LkRCdsLMuzhbR8knss9B4XnetQnGZ2OhyYXBXOXk1eBrcBOaqrrELuX)GHNup4MPMylMUuzLxEQ0Kk7iyLxPrsQFdpUHysTbC2g9atwW5dfRqh7SOFS3OViSHcaff5LulqQ)iQRW0jGawlDbNpuScDSZI(XEJ(I0mUYsQfi1GawlzbNpuScDSZI(XEJ(IA7yEKvy6sTaPwrPgeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0LALKAbs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGuROudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cKAfLAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLuRKuRGcsTIsTXi1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDc2p6mvmm5M08gH(uQZwQZGnebRm5IBt3yj0fxXSKALKAfuqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTssTsjv8py4jvBhZdmQx6sLvUHtLMuzhbR8knss9B4XnetQkk1nGZ2OhyYcoFOyf6yNf9J9g9fHnuaOOiVKAbs9hrDfMobeWAPl48HIvOJDw0p2B0xKMXvwsTaPgeWAjl48HIvOJDw0p2B0xulSzYkmDPwGul2Cg6WViLtSDmpWOEsTssTcki1kk1nGZ2OhyYcoFOyf6yNf9J9g9fHnuaOOiVKAbs9b3SuNl1gi1kLuX)GHNuTWMPGvCEPlvw5gBQ0Kk7iyLxPrsQFdpUHysTbC2g9atgA4SMff(WVYe2qbGII8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuNTuBSgi1cK6pI6kmDYfaFbnS0RGPBCasAEJqFk15sTbsTaPwrPgeWAjy)OZ0Va7bMmp8fwQhnxQZGnebRmbdMEXTPFb2d8uQfi1kk1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPE0CPE4xsTaP(JOUctNG9JotfdtUjnVrOpL6SL6mydrWktU420nwcDXvmlPwjPwbfKAfLAJrQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuNTuNbBicwzYf3MUXsOlUIzj1kj1kOGu)ruxHPtW(rNPIHj3KM3i0Ns9O5s9WVKALKALsQ4FWWtQ2oMh1Jmy6sLvUHmvAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcBOaqrrEj1cK6pI6kmDc2p6mvmm5M08gH(uQZLAdKAbsTIsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6SL6mydrWktqr6glHU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXsOZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cKAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwjPwjPwGudcyTKgWzAyPIHj3Kvy6sTsjv8py4jvBhZJ6rgmDPYkxOsLMuzhbR8knss9B4XnetQnGZ2OhyYekweoDErVjSHcaff5LulqQfBodD4xKYjCM4XdgEsf)dgEs9cGVGgw6vW0noatxQSYnoPstQSJGvELgjP(n84gIj1gWzB0dmzcflcNoVO3e2qbGII8sQfi1kk1InNHo8ls5eot84bdxQvqbPwS5m0HFrkNCbWxqdl9ky6ghGsTsjv8py4jvSF0zQyyYD6sLvUqlvAsLDeSYR0ij1VHh3qmPEWnl1zl1gRbsTaPUbC2g9atMqXIWPZl6nHnuaOOiVKAbsniG1sW(rNPFb2dmzE4lSupAUuNbBicwzcgm9IBt)cSh4PulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cK6pI6kmDc2p6mvmm5M08gH(uQhnxQh(vsf)dgEsLZepEWWtxQSYfsPstQSJGvELgjPI)bdpPYzIhpy4jvOFC3aIhfAtQGawlzcflcNoVO3K5HVW5GawlzcflcNoVO3KnwcDE4lCsf6h3nG4rH7nVG4Xj1YtQFdpUHys9GBwQZwQnwdKAbsDd4Sn6bMmHIfHtNx0BcBOaqrrEj1cK6pI6kmDc2p6mvmm5M08gH(uQZLAdKAbsTIsTIsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6SL6mydrWktqr6glHU4kMLulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXsOZdFHLALKAfuqQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cKAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwjPwjPwGudcyTKgWzAyPIHj3Kvy6sTsPlvw5crPstQSJGvELgjP(n84gIjvfL6pI6kmDc2p6mvmm5M08gH(uQZwQnKcLuRGcs9hrDfMob7hDMkgMCtAEJqFk1JMl1gRuRKulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cKAfLAqaRLG9Jot)cShyY8WxyPE0CPod2qeSYemy6f3M(fypWtPwGuROuROuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jnGZ0WsfdtUjnVrOpL6rZL6HFj1cK6pI6kmDc2p6mvmm5M08gH(uQZwQfkPwjPwbfKAfLAJrQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6eSF0zQyyYnP5nc9PuNTulusTssTcki1Fe1vy6eSF0zQyyYnP5nc9PupAUup8lPwjPwPKk(hm8K6g2D0tAyPx0B2V0LkZWgKknPYocw5vAKK63WJBiMu)iQRW0jxa8f0WsVcMUXbiP5nc9PuNTuNbBicwzspPBSe6IRywsTaP(JOUctNG9JotfdtUjnVrOpL6SL6mydrWkt6jDJLqxCfZsQfi1kk1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPE0CPE4xsTcki1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDsd4mnSuXWKBsZBe6tPoBPod2qeSYKEs3yj0fxXSKAfuqQngP(Wk7hPbCMgwQyyYnHDeSYlPwjPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpP24cI(rNIylC6sLz4YtLMuzhbR8knss9B4XnetQFe1vy6Kla(cAyPxbt34aK08gH(uQZLAdKAbsTIsniG1sW(rNPFb2dmzE4lSupAUuNbBicwzcgm9IBt)cSh4PulqQvuQvuQpSY(rAaNPHLkgMCtyhbR8sQfi1Fe1vy6KgWzAyPIHj3KM3i0Ns9O5s9WVKAbs9hrDfMob7hDMkgMCtAEJqFk1zl1zWgIGvMCXTPBSe6IRywsTssTcki1kk1gJuFyL9J0aotdlvmm5MWocw5LulqQ)iQRW0jy)OZuXWKBsZBe6tPoBPod2qeSYKlUnDJLqxCfZsQvsQvqbP(JOUctNG9JotfdtUjnVrOpL6rZL6HFj1kj1kLuX)GHNuBCbr)OtrSfoDPYmSHtLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gi1cKAfLAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnqQfi1Gawlb7hDM(fypWK5HVWs9O5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfdtUjRW0LALsQ4FWWtQnUGOF0Pi2cNUuzg2ytLMuzhbR8knss9B4XnetQFe1vy6eSF0zQyyYnP5nc9PuNl1gi1cKAfLAfLAfL6pI6kmDYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHPtUa4lOHLEfmDJdqsZBe6tPoxQnqQfi1Gawlb7hDM(fypWK5HVWs9O5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfdtUjRW0LALsQ4FWWtQlgVcWODoDPYmSHmvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1cKAfLAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PupAUup8lPwGu)ruxHPtW(rNPIHj3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLuRKuRGcsTIsTXi1hwz)inGZ0WsfdtUjSJGvEj1cK6pI6kmDc2p6mvmm5M08gH(uQZwQZGnebRm5IBt3yj0fxXSKALKAfuqQ)iQRW0jy)OZuXWKBsZBe6tPE0CPE4xsTsjv8py4j1la(cAyPxbt34amDPYmSqLknPYocw5vAKK63WJBiMuvuQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNTuNbBicwzcks3yj0fxXSKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1kj1kj1cKAqaRL0aotdlvmm5MSctpPI)bdpPI9JotfdtUtxQmdBCsLMuzhbR8knss9B4XnetQGawlPbCMgwQyyYnzfMUulqQvuQvuQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNTuBydKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSuRKuRGcsTIs9hrDfMo5cGVGgw6vW0noajnVrOpL6CP2aPwGudcyTeSF0z6xG9atMh(cl1JMl1zWgIGvMGbtV420Va7bEk1kj1kj1cKAfL6pI6kmDc2p6mvmm5M08gH(uQZwQlxOKAfuqQxmiG1sUa4lOHLEfmDJdqcGOuRusf)dgEsTbCMgwQyyYD6sLzyHwQ0Kk7iyLxPrsQFdpUHysfeWAjlgVcWODMaik1cK6fdcyTKla(cAyPxbt34aKaik1cK6fdcyTKla(cAyPxbt34aK08gH(uQhnxQbbSwIyZt2FMgw6g6lYglHop8fwQf6l14FWWjy)OZuWkopcxc)ahtp4MtQ4FWWtQInpz)zAyPBOVsxQmdlKsLMuzhbR8knss9B4XnetQGawlzX4vagTZearPwGuROuROuFyL9J08mC0FMWocw5LulqQX)Gzyk78gYtPEuP2qk1kj1kOGuJ)bZWu25nKNs9OsTqj1kLuX)GHNuX(rNPGvCEPlvMHfIsLMuX)GHNuNaIC7rgmPYocw5vAK0LkZynivAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl15sTbjv8py4jvSF0zA0GPlvMXwEQ0Kk7iyLxPrsQFdpUHysvrPUzBZZceSYsTcki1gJuFWxyOpi1kj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68Wx4Kk(hm8KQZxb30J3I88sxQmJ1WPstQSJGvELgjP(n84gIjvqaRLG9JotfdtUjRW0LAbsniG1sAaNPHLkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctxQfi1Fe1vy6eSF0zQyyYnP5nc9PuNTuBGulqQ)iQRW0jxa8f0WsVcMUXbiP5nc9PuNTuBGulqQvuQngP(Wk7hPbCMgwQyyYnHDeSYlPwbfKAfL6dRSFKgWzAyPIHj3e2rWkVKAbs9hrDfMoPbCMgwQyyYnP5nc9PuNTuBGuRKuRusf)dgEsDwaTh0hOIHj3PlvMXASPstQSJGvELgjP(n84gIjvqaRL8vg7hNh0hinJ)j1cK6gWzB0dmb7hDMcDl0Hxwe2qbGII8sQfi1hwz)i4wScTWhpy4e2rWkVKAbsn(hmdtzN3qEk1Jk1gNKk(hm8Kk2p6mDdNtyLNPlvMXAitLMuzhbR8knss9B4XnetQGawl5Rm2popOpqAg)tQfi1nGZ2Ohyc2p6mf6wOdVSiSHcaff5LulqQX)Gzyk78gYtPEuP2qMuX)GHNuX(rNPB4CcR8mDPYmwHkvAsLDeSYR0ij1VHh3qmPccyTeSF0z6xG9atMh(cl1Jk1Gawlb7hDM(fypWKnwcDE4lCsf)dgEsf7hDMYLiwJjm80LkZynoPstQSJGvELgjP(n84gIjvqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwGul2Cg6WViLtW(rNPGy34aNuX)GHNuX(rNPCjI1ycdpDPYmwHwQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8foPI)bdpPI9JotbXUXboDPYmwHuQ0Kk0pUBaXJcTj1n6ir8VSZfscvsf6h3nG4rH7nVG4Xj1YtQ4FWWtQCM4XdgEsLDeSYR0iPlDj1oo8GHNknvw5PstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwEs9B4XnetQGawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWsTaP2yKAqaRL0avMgw6v0mpjaIsTaP(WEGpYb3m9c6cYs9O5sTIsTIs9gDuQhtQX)GHtW(rNPGvCEKpMNuRKul0xQX)GHtW(rNPGvCEeUe(boMEWnl1kLuZGn1XnNuTqhRuqG2txQmdNknPYocw5vAKK63WJBiMuxmiG1sACbr)OtrSfMMbO6CJGWk8YImp8fwQZL6fdcyTKgxq0p6ueBHPzaQo3iiScVSiBSe68WxyPwGuROudcyTeSF0zQyyYnzfMUuRGcsniG1sW(rNPIHj3KM3i0Ns9O5s9WVKALKAbsTIsniG1sAaNPHLkgMCtwHPl1kOGudcyTKgWzAyPIHj3KM3i0Ns9O5s9WVKALsQ4FWWtQy)OZuqSBCGtxQmJnvAsLDeSYR0ij1VHh3qmPUIJ04cI(rNIylmP5nc9PuNTulusTcki1lgeWAjnUGOF0Pi2ctZauDUrqyfEzrMh(cl1zl1gKuX)GHNuX(rNPGvCEPlvMHmvAsLDeSYR0ij1VHh3qmPccyTeXMNS)mnS0n0xearPwGuVyqaRLCbWxqdl9ky6ghGearPwGuVyqaRLCbWxqdl9ky6ghGKM3i0Ns9O5sn(hmCc2p6mfSIZJWLWpWX0dU5Kk(hm8Kk2p6mfSIZlDPYeQuPjv2rWkVsJKuX)GHNuX(rNPB4CcR8mP(fi0tQLNu)gECdXK6IbbSwYfaFbnS0RGPBCasaeLAbs9Hv2pc2p6mL)IGWocw5LulqQbbSwYIXRamANjRW0LAbsTIs9IbbSwYfaFbnS0RGPBCasAEJqFk1zl14FWWjy)OZ0nCoHvEs4s4h4y6b3SuRGcs9hrDfMorS5j7ptdlDd9fP5nc9PuNTuBGuRGcs9hzyh9JiCwneDPwP0LkZ4KknPYocw5vAKK63WJBiMubbSwYxzSFCEqFG0m(NulqQbbSwcxIi6lErfJJ9dIvcGysf)dgEsf7hDMUHZjSYZ0LktOLknPYocw5vAKKk(hm8Kk2p6mDdNtyLNj1VaHEsT8K63WJBiMubbSwYxzSFCEqFG0m(NulqQvuQbbSwc2p6mvmm5Maik1kOGudcyTKgWzAyPIHj3earPwbfK6fdcyTKla(cAyPxbt34aK08gH(uQZwQX)GHtW(rNPB4CcR8KWLWpWX0dUzPwP0LktiLknPYocw5vAKKk(hm8Kk2p6mDdNtyLNj1VaHEsT8K63WJBiMubbSwYxzSFCEqFG0m(NulqQbbSwYxzSFCEqFGmp8fwQZLAqaRL8vg7hNh0hiBSe68Wx40LktikvAsLDeSYR0ijv8py4jvSF0z6goNWkptQFbc9KA5j1VHh3qmPccyTKVYy)48G(aPz8pPwGudcyTKVYy)48G(aP5nc9PupAUuROuROudcyTKVYy)48G(azE4lSul0xQX)GHtW(rNPB4CcR8KWLWpWX0dUzPwjPECPE4xsTsPlvw5gKknPYocw5vAKK63WJBiMuvuQB228SabRSuRGcsTXi1h8fg6dsTssTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQfi1Gawlb7hDMkgMCtwHPl1cK6fdcyTKla(cAyPxbt34aKSctpPI)bdpP68vWn94TipV0LkR8YtLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWs9O5sTHtQ4FWWtQy)OZ0ObtxQSYnCQ0Kk7iyLxPrsQFdpUHysDJose)tQhnxQfIekPwGudcyTeSF0zQyyYnzfMUulqQbbSwsd4mnSuXWKBYkmDPwGuVyqaRLCbWxqdl9ky6ghGKvy6jv8py4j1jGi3EKbtxQSYn2uPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHj3Kvy6sTaPgeWAjnGZ0WsfdtUjRW0LAbs9IbbSwYfaFbnS0RGPBCaswHPl1cK6pI6kmDcNjE8GHtAEJqFk1zl1gi1cK6pI6kmDc2p6mvmm5M08gH(uQZwQnqQfi1Fe1vy6Kla(cAyPxbt34aK08gH(uQZwQnqQfi1kk1gJuFyL9J0aotdlvmm5MWocw5LuRGcsTIs9Hv2psd4mnSuXWKBc7iyLxsTaP(JOUctN0aotdlvmm5M08gH(uQZwQnqQvsQvkPI)bdpPolG2d6duXWK70LkRCdzQ0Kk7iyLxPrsQFdpUHysfeWAjnqLPHLEfnZtcGOulqQbbSwc2p6m9lWEGjZdFHL6SLAJnPI)bdpPI9JotbR48sxQSYfQuPjv2rWkVsJKu)gECdXK6gDKi(NupQuNbBicwzci2noW0n6iv8pPwGu)ruxHPt4mXJhmCsZBe6tPoBP2aPwGudcyTeSF0zQyyYnzfMUulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXsOZdFHLAbsnpNS)mjdCcdNgwQi3w(py4Kn0JoPI)bdpPI9JotbXUXboDPYk34KknPYocw5vAKK63WJBiMu)iQRW0jxa8f0WsVcMUXbiP5nc9PuNl1gi1cKAfL6pI6kmDsd4mnSuXWKBsZBe6tPoxQnqQvqbP(JOUctNG9JotfdtUjnVrOpL6CP2aPwjPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cNuX)GHNuX(rNPGy34aNUuzLl0sLMuzhbR8knss9B4XnetQB0rI4Fs9O5sDgSHiyLjGy34at3OJuX)KAbsniG1sW(rNPIHj3Kvy6sTaPgeWAjnGZ0WsfdtUjRW0LAbs9IbbSwYfaFbnS0RGPBCaswHPl1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwGu)ruxHPt4mXJhmCsZBe6tPoBP2GKk(hm8Kk2p6mfe7gh40LkRCHuQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBYkmDPwGudcyTKgWzAyPIHj3Kvy6sTaPEXGawl5cGVGgw6vW0noajRW0LAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSulqQpSY(rW(rNPrdsyhbR8sQfi1Fe1vy6eSF0zA0GKM3i0Ns9O5s9WVKAbs9gDKi(NupAUulezGulqQ)iQRW0jCM4XdgoP5nc9PuNTuBqsf)dgEsf7hDMcIDJdC6sLvUquQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWKBcGOulqQbbSwc2p6mvmm5M08gH(uQhnxQh(LulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXsOZdFHtQ4FWWtQy)OZuqSBCGtxQmdBqQ0Kk7iyLxPrsQFdpUHysfeWAjnGZ0WsfdtUjaIsTaPgeWAjnGZ0WsfdtUjnVrOpL6rZL6HFj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68Wx4Kk(hm8Kk2p6mfe7gh40LkZWLNknPI)bdpPI9JotbR48sQSJGvELgjDPYmSHtLMuH(XDdiEuOnPUrhjI)LDUqsOsQq)4UbepkCV5fepoPwEsf)dgEsLZepEWWtQSJGvELgjDPYmSXMknPI)bdpPI9JotbXUXboPYocw5vAK0LUK6ITiq9sLMkR8uPjv2rWkVsJKu)gECdXK6H9aFKfdcyTKhNh0hinJ)LuX)GHNu)aWpUNICTMUuzgovAsLDeSYR0ijv8py4j1hRvk(hmCAfoVKAfopQJBoPYZj7pptxQmJnvAsLDeSYR0ij1VHh3qmPI)bZWu25nKNsD2sTHtQ4FWWtQpwRu8py40kCEj1kCEuh3CsfdoDPYmKPstQSJGvELgjP(n84gIj1mydrWktkWmmnezNxsDUuBqsf)dgEs9XALI)bdNwHZlPwHZJ64MtQHi7CNUuzcvQ0Kk7iyLxPrsQ4FWWtQpwRu8py40kCEj1kCEuh3Cs9JOUctFMUuzgNuPjv2rWkVsJKu)gECdXKAgSHiyLjwOJvkiq7sDUuBqsf)dgEs9XALI)bdNwHZlPwHZJ64MtQDC4bdpDPYeAPstQSJGvELgjP(n84gIj1mydrWktSqhRuqG2L6CPU8Kk(hm8K6J1kf)dgoTcNxsTcNh1XnNuTqhRuqG2txQmHuQ0Kk7iyLxPrsQ4FWWtQpwRu8py40kCEj1kCEuh3CsDhz4n7x6sxs1cDSsbbApvAQSYtLMuzhbR8knssf)dgEsf7hDMUHZjSYZK6xGqpPwEs9B4XnetQGawl5Rm2popOpqAg)lDPYmCQ0Kk(hm8Kk2p6mfSIZlPYocw5vAK0LkZytLMuX)GHNuX(rNPGy34aNuzhbR8kns6sx6sQz4EcdpvMHnWWguUbLBSKYtQMy7qFyMufcIHOqUYe6wMqqfcLAPU0cwQHBXOpP2gTuB8DC4bd34L6MnuayZlPEgBwQrGl24XlP(lqFGNePrgcqNL6YfcLAHaHNH7JxsTkCleqQNz5hwIulKFP(cP2qaaL6fmdCcdxQdrUXlAPwXXusQvS8suIinYqa6SulucHsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kwEjkrKgjnsiigIc5ktOBzcbviuQL6slyPgUfJ(KAB0sTXl28hBq8mEPUzdfa28sQNXMLAe4InE8sQ)c0h4jrAKHa0zP2yfcLAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvS8suIinYqa6SuBifcLAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvS8suIinYqa6SuxE5cHsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kwEjkrKgziaDwQlxOecLAHaHNH7JxsTX)rg2r)icze2rWkVmEP(cP24)id7OFeHmJxQvS8suIinsAKqqmefYvMq3YecQqOul1LwWsnClg9j12OLAJ)JOUctFA8sDZgkaS5LupJnl1iWfB84Lu)fOpWtI0idbOZsTHnqiuQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYlrjI0idbOZsTHlxiuQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYlrjI0idbOZsTHnocHsTqGWZW9XlP24)id7OFeHmc7iyLxgVuFHuB8FKHD0pIqMXl1kwEjkrKgziaDwQnSqtiuQfceEgUpEj1g)hzyh9JiKryhbR8Y4L6lKAJ)JmSJ(reYmEPwXYlrjI0iPrcD3IrF8sQl3aPg)dgUuxHZBsKgLuf7WcRCs14k1c5dhyP2qSF0zPrgxPwOJ)cqUL6YnKkl1g2adBG0iPr4FWWNeXM)ydIxEgSHiyLv2XnNl2SiqTs5mHYHy(KpLZGvao3aPr4FWWNeXM)ydI345JLbBicwzLDCZ5InlcuRuotOCiMp5t5myfGZlxzOnVbC2g9atMqXIWPZl6nHnuaOOiVeG)bZWu25nKNzByPr4FWWNeXM)ydI345JLbBicwzLDCZ5InlcuRuotOCiMp5t5myfGZlxzOnVbC2g9atMqXIWPZl6nHnuaOOiVe8rg2r)io)DuJEryhbR8sa(hmdtzN3qEMD5sJW)GHpjIn)XgeVXZhld2qeSYk74MZfBweOwPCMq5qmFYNYzWkaNxUYqBEd4Sn6bMmHIfHtNx0BcBOaqrrEj4JmSJ(rC4qXrTityhbR8sAKXvQX)GHpjIn)XgeVXZhld2qeSYk74MZlWmmnezNxkhI5t(uodwb4CdKgzCLA8py4tIyZFSbXB88XYGnebRSYoU58cmdtdr25LYHy(KpLZGvaoVCLH2C8pygMYoVH8mBdlnY4k14FWWNeXM)ydI345JLbBicwzLDCZ5fygMgISZlLdX8jFkNbRaCE5kdT5zWgIGvMi2SiqTs5mrE5sJW)GHpjIn)XgeVXZhld2qeSYk74MZTqhRuqG2voeZN8PCgScW5ginc)dg(Ki28hBq8gpFSmydrWkRSJBoVN0nwcDXvmlLdX8jFkNbRaCUqjnc)dg(Ki28hBq8gpFSmydrWkRSJBohfPBSe6IRywkhI5t(uodwb48YnqAe(hm8jrS5p2G4nE(yzWgIGvwzh3CEhI0nwcDXvmlLdX8jFkNbRaCUHnqAe(hm8jrS5p2G4nE(yzWgIGvwzh3C(f3MUXsOlUIzPCiMp5t5myfGZfkPr4FWWNeXM)ydI345JLbBicwzLDCZ5xCB6glHU4kMLYHy(KpLZGvao3yvgAZBaNTrpWKfC(qXk0Xol6h7n6lcBOaqrrEjnc)dg(Ki28hBq8gpFSmydrWkRSJBo)IBt3yj0fxXSuoeZN8PCgScW5LlukdT5FKHD0pIdhkoQfzc7iyLxsJW)GHpjIn)XgeVXZhld2qeSYk74MZV420nwcDXvmlLdX8jFkNbRaCE5cLYqB(h(caEeSF0zQyhl4qwe2rWkVeG)bZWu25nKNJASsJmUs9iwdrPwiyPwihVJmSuBiGh3sJW)GHpjIn)XgeVXZhld2qeSYk74MZV420nwcDXvmlLdX8jFkNbRaCUXAGYqBopNS)mjdCcdNgwQi3w(py4Kn0JwAe(hm8jrS5p2G4nE(yzWgIGvwzh3Coi2noW0n6iv8pLdX8jFkNbRaCUqKbsJW)GHpjIn)XgeVXZhld2qeSYk74MZbXUXbMUrhPI)PCiMp5t5myfGZfsgOm0M)rg2r)ioCO4OwKjSJGvEjnc)dg(Ki28hBq8gpFSmydrWkRSJBohfPBOd3aB6gDKk(NYHy(KpLZGvao3ynqAe(hm8jrS5p2G4nE(yzWgIGvwzh3Coks3qhUb20n6iv8pLdX8jFkNbRaCUqzGYqBEd4Sn6bMSGZhkwHo2zr)yVrFrydfakkYlPr4FWWNeXM)ydI345JLbBicwzLDCZ5OiDdD4gyt3OJuX)uoeZN8PCgScW5cLbkdT5nGZ2OhyYqdN1SOWh(vMWgkauuKxsJW)GHpjIn)XgeVXZhld2qeSYk74MZXGPxCB6xG9apvoeZN8PCgScW5gwAe(hm8jrS5p2G4nE(yy)OZulUHvi2sJW)GHpjIn)XgeVXZhd7hDMc9JRv(pPr4FWWNeXM)ydI345J9HlehOz6gDKoWBPr4FWWNeXM)ydI345JTHDhnfUXbwAe(hm8jrS5p2G4nE(y2oMhyupLH28mydrWkteBweOwPCMi3abnGZ2OhyYcoFOyf6yNf9J9g9fHnuaOOiVe8ruxHPtabSw6coFOyf6yNf9J9g9fPzCLLaqaRLSGZhkwHo2zr)yVrFrTDmpYkmDPr4FWWNeXM)ydI345JXzIhpy4kdT5zWgIGvMi2SiqTs5mrE5sJKgzCLAH8Qe(boEj1CgUZsQp4ML6RGLA8VOLA4uQXmiSIGvMinc)dg(m)da)4EkY1QYqB(H9aFKfdcyTKhNh0hinJ)jnY4k1JyneLAHGLAHC8oYWsTHaEClnc)dg(C88XESwP4FWWPv48u2XnNZZj7ppLgH)bdFoE(ypwRu8py40kCEk74MZXGvgAZX)Gzyk78gYZSnS0i8py4ZXZh7XALI)bdNwHZtzh3CEiYo3kdT5zWgIGvMuGzyAiYoVYnqAe(hm8545J9yTsX)GHtRW5PSJBo)JOUctFknc)dg(C88XESwP4FWWPv48u2XnN3XHhmCLH28mydrWktSqhRuqG2ZnqAe(hm8545J9yTsX)GHtRW5PSJBo3cDSsbbAxzOnpd2qeSYel0XkfeO98YLgH)bdFoE(ypwRu8py40kCEk74MZ3rgEZ(jnsAe(hm8jbdohyY0n6iDG3kdT5kEyL9JWEfouCSZlc7iyLxc2OJeX)gnxizGGn6ir8VSZnocLskOGIgZHv2pc7v4qXXoViSJGvEjyJose)B0CHKqPK0i8py4tcg845JvHdf3KkehynSz)ugAZbbSwc2p6mvmm5MSctxAe(hm8jbdE88XaXbAyPxdFHNkdT5Gawlb7hDMkgMCtwHPlnc)dg(KGbpE(ypwRu8py40kCEk74MZHhVNkdT5Gawlb7hDMkgMCtaeLgH)bdFsWGhpFmX4GHRm0MdcyTeSF0zQyyYnbquAe(hm8jbdE88Xa5EYTWqFqzOnheWAjy)OZuXWKBcGO0i8py4tcg845JbwJyrTaDwkdT5Gawlb7hDMkgMCtaeLgH)bdFsWGhpFmlSzWAelLH2CqaRLG9JotfdtUjaIsJW)GHpjyWJNpg6ppVgR0hRvLH2CqaRLG9JotfdtUjaIsJW)GHpjyWJNp2b3m1eBrLH28gWzB0dm54Ty0yLAITiHnuaOOiVKgH)bdFsWGhpFmBhZdmQNYqBEd4Sn6bMSGZhkwHo2zr)yVrFrydfakkYlbFe1vy6eqaRLUGZhkwHo2zr)yVrFrAgxzjaeWAjl48HIvOJDw0p2B0xuBhZJSctxGIGawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6kj4JOUctNCbWxqdl9ky6ghGKM3i0N5giqrqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8uGIkEyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZrZh(LGpI6kmDc2p6mvmm5M08gH(m7mydrWktU420nwcDXvmlLuqbfnMdRSFKgWzAyPIHj3e2rWkVe8ruxHPtW(rNPIHj3KM3i0NzNbBicwzYf3MUXsOlUIzPKck8ruxHPtW(rNPIHj3KM3i0NJMp8lLusAe(hm8jbdE88XSWMPGvCEkdT5k2aoBJEGjl48HIvOJDw0p2B0xe2qbGII8sWhrDfMobeWAPl48HIvOJDw0p2B0xKMXvwcabSwYcoFOyf6yNf9J9g9f1cBMSctxGyZzOd)IuoX2X8aJ6PKckOyd4Sn6bMSGZhkwHo2zr)yVrFrydfakkYlbhCZ5gOK0i8py4tcg845Jz7yEupYGkdT5nGZ2OhyYqdN1SOWh(vMWgkauuKxc(iQRW0jy)OZuXWKBsZBe6ZSnwde8ruxHPtUa4lOHLEfmDJdqsZBe6ZCdeOiiG1sW(rNPFb2dmzE4l8O5zWgIGvMGbtV420Va7bEkqrfpSY(rAaNPHLkgMCtyhbR8sWhrDfMoPbCMgwQyyYnP5nc95O5d)sWhrDfMob7hDMkgMCtAEJqFMDgSHiyLjxCB6glHU4kMLskOGIgZHv2psd4mnSuXWKBc7iyLxc(iQRW0jy)OZuXWKBsZBe6ZSZGnebRm5IBt3yj0fxXSusbf(iQRW0jy)OZuXWKBsZBe6ZrZh(Lskjnc)dg(KGbpE(y2oMh1JmOYqBEd4Sn6bMm0Wznlk8HFLjSHcaff5LGpI6kmDc2p6mvmm5M08gH(m3abkQOIFe1vy6Kla(cAyPxbt34aK08gH(m7mydrWktqr6glHU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8ujLeacyTKgWzAyPIHj3Kvy6kjnY4k1Lk0HqEk0HqOuleOYOl1aIs9vWtwQvvLAoti1vOZtPr4FWWNem4XZh7cGVGgw6vW0noavgAZBaNTrpWKjuSiC68IEtydfakkYlbInNHo8ls5eot84bdxAe(hm8jbdE88XW(rNPIHj3kdT5nGZ2OhyYekweoDErVjSHcaff5LaffBodD4xKYjCM4XdgUcki2Cg6WViLtUa4lOHLEfmDJdqLKgH)bdFsWGhpFmot84bdxzOn)GBoBJ1abnGZ2OhyYekweoDErVjSHcaff5LaqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8uWhrDfMo5cGVGgw6vW0noajnVrOpZnqWhrDfMob7hDMkgMCtAEJqFoA(WVKgH)bdFsWGhpFmot84bdxzOn)GBoBJ1abnGZ2OhyYekweoDErVjSHcaff5LGpI6kmDc2p6mvmm5M08gH(m3abkQOIFe1vy6Kla(cAyPxbt34aK08gH(m7mydrWktqr6glHU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8ujLeacyTKgWzAyPIHj3Kvy6kPm0pUBaXJcT5GawlzcflcNoVO3K5HVW5GawlzcflcNoVO3KnwcDE4lSYq)4UbepkCV5fepoVCPr4FWWNem4XZhBd7o6jnS0l6n7NYqBUIFe1vy6eSF0zQyyYnP5nc9z2gsHsbf(iQRW0jy)OZuXWKBsZBe6ZrZnwLe8ruxHPtUa4lOHLEfmDJdqsZBe6ZCdeOiiG1sW(rNPFb2dmzE4l8O5zWgIGvMGbtV420Va7bEkqrfpSY(rAaNPHLkgMCtyhbR8sWhrDfMoPbCMgwQyyYnP5nc95O5d)sWhrDfMob7hDMkgMCtAEJqFMTqPKckOOXCyL9J0aotdlvmm5MWocw5LGpI6kmDc2p6mvmm5M08gH(mBHsjfu4JOUctNG9JotfdtUjnVrOphnF4xkPK0i8py4tcg845J14cI(rNIylSYqB(hrDfMo5cGVGgw6vW0noajnVrOpZod2qeSYKEs3yj0fxXSe8ruxHPtW(rNPIHj3KM3i0NzNbBicwzspPBSe6IRywcu8Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NJMp8lfu4Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NzNbBicwzspPBSe6IRywkOGXCyL9J0aotdlvmm5MWocw5LscabSwc2p6m9lWEGjZdFHhnpd2qeSYemy6f3M(fypWtblgeWAjxa8f0WsVcMUXbizfMU0i8py4tcg845J14cI(rNIylSYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnqGIGawlb7hDM(fypWK5HVWJMNbBicwzcgm9IBt)cSh4Pafv8Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NJMp8lbFe1vy6eSF0zQyyYnP5nc9z2zWgIGvMCXTPBSe6IRywkPGckAmhwz)inGZ0WsfdtUjSJGvEj4JOUctNG9JotfdtUjnVrOpZod2qeSYKlUnDJLqxCfZsjfu4JOUctNG9JotfdtUjnVrOphnF4xkPK0i8py4tcg845J14cI(rNIylSYqB(hrDfMob7hDMkgMCtAEJqFMBGafvuXpI6kmDYfaFbnS0RGPBCasAEJqFMDgSHiyLjOiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfMo5cGVGgw6vW0noajnVrOpZnqaiG1sW(rNPFb2dmzE4l8O5zWgIGvMGbtV420Va7bEQKscabSwsd4mnSuXWKBYkmDLKgH)bdFsWGhpFSfJxby0oRm0M)ruxHPtW(rNPIHj3KM3i0N5giqrfv8JOUctNCbWxqdl9ky6ghGKM3i0NzNbBicwzcks3yj0fxXSeacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2yj05HVWkPGck(ruxHPtUa4lOHLEfmDJdqsZBe6ZCdeacyTeSF0z6xG9atMh(cpAEgSHiyLjyW0lUn9lWEGNkPKaqaRL0aotdlvmm5MSctxjPr4FWWNem4XZh7cGVGgw6vW0noavgAZbbSwc2p6m9lWEGjZdFHhnpd2qeSYemy6f3M(fypWtbkQ4Hv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xc(iQRW0jy)OZuXWKBsZBe6ZSZGnebRm5IBt3yj0fxXSusbfu0yoSY(rAaNPHLkgMCtyhbR8sWhrDfMob7hDMkgMCtAEJqFMDgSHiyLjxCB6glHU4kMLskOWhrDfMob7hDMkgMCtAEJqFoA(WVusAe(hm8jbdE88XW(rNPIHj3kdT5kQ4hrDfMo5cGVGgw6vW0noajnVrOpZod2qeSYeuKUXsOlUIzjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHvsbfu8JOUctNCbWxqdl9ky6ghGKM3i0N5giaeWAjy)OZ0Va7bMmp8fE08mydrWktWGPxCB6xG9apvsjbGawlPbCMgwQyyYnzfMU0i8py4tcg845J1aotdlvmm5wzOnheWAjnGZ0WsfdtUjRW0fOOIFe1vy6Kla(cAyPxbt34aK08gH(mBdBGaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4rZZGnebRmbdMEXTPFb2d8ujLeO4hrDfMob7hDMkgMCtAEJqFMD5cLckSyqaRLCbWxqdl9ky6ghGearLKgH)bdFsWGhpFmXMNS)mnS0n0xkdT5GawlzX4vagTZearblgeWAjxa8f0WsVcMUXbibquWIbbSwYfaFbnS0RGPBCasAEJqFoAoiG1seBEY(Z0Ws3qFr2yj05HVWc9X)GHtW(rNPGvCEeUe(boMEWnlnc)dg(KGbpE(yy)OZuWkopLH2CqaRLSy8kaJ2zcGOafv8Wk7hP5z4O)mHDeSYlb4FWmmLDEd55OgsLuqb8pygMYoVH8CuHsjPr4FWWNem4XZhBciYThzqPr4FWWNem4XZhd7hDMgnOYqBoiG1sW(rNPFb2dmzE4lCUbsJW)GHpjyWJNpMZxb30J3I88ugAZvSzBZZceSYkOGXCWxyOpOKaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwAe(hm8jbdE88XMfq7b9bQyyYTYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMUGpI6kmDc2p6mvmm5M08gH(mBde8ruxHPtUa4lOHLEfmDJdqsZBe6ZSnqGIgZHv2psd4mnSuXWKBc7iyLxkOGIhwz)inGZ0WsfdtUjSJGvEj4JOUctN0aotdlvmm5M08gH(mBdusjPr4FWWNem4XZhd7hDMUHZjSYtLH2CqaRL8vg7hNh0hinJ)jObC2g9atW(rNPq3cD4LfHnuaOOiVeCyL9JGBXk0cF8GHtyhbR8sa(hmdtzN3qEoQXrAe(hm8jbdE88XW(rNPB4CcR8uzOnheWAjFLX(X5b9bsZ4FcAaNTrpWeSF0zk0TqhEzrydfakkYlb4FWmmLDEd55OgsPr4FWWNem4XZhd7hDMYLiwJjmCLH2CqaRLG9Jot)cShyY8Wx4rbbSwc2p6m9lWEGjBSe68WxyPr4FWWNem4XZhd7hDMYLiwJjmCLH2CqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwGyZzOd)Iuob7hDMcIDJdS0i8py4tcg845JH9JotbXUXbwzOnheWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHLgH)bdFsWGhpFmot84bdxzOFC3aIhfAZ3OJeX)Yoxijukd9J7gq8OW9Mxq848YLgjnc)dg(K8ruxHPpZRWHIBsfIdSg2SFkdT5Gawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6sJW)GHpjFe1vy6ZXZhdehOHLEn8fEQm0MdcyTeSF0zQyyYnzfMUaqaRL0aotdlvmm5MSctxWIbbSwYfaFbnS0RGPBCaswHPlnc)dg(K8ruxHPphpFShRvk(hmCAfopLDCZ5WJ3tLH2CqaRLG9JotfdtUjaIsJW)GHpjFe1vy6ZXZhtmoy4kdT5Gawlb7hDMkgMCtaeLgH)bdFs(iQRW0NJNpgi3tUfg6dkdT5Gawlb7hDMkgMCtaeLgH)bdFs(iQRW0NJNpgynIf1c0zPm0MdcyTeSF0zQyyYnbquAe(hm8j5JOUctFoE(ywyZG1iwkdT5Gawlb7hDMkgMCtaeLgH)bdFs(iQRW0NJNpg6ppVgR0hRvLH2CqaRLG9JotfdtUjaIsJmUsTqE0WOHhuigl1atOpi1dnCwZsQHp8RSuBcVcPgfjsTqVjl1WtQnHxHuFXTL64k42eozIulnc)dg(K8ruxHPphpFmBhZJ6rguzOnVbC2g9atgA4SMff(WVYe2qbGII8sWhrDfMob7hDMkgMCtAEJqFMTXAGGpI6kmDYfaFbnS0RGPBCasAEJqFMBGafbbSwc2p6m9lWEGjZdFHhn3WcuuXdRSFKgWzAyPIHj3e2rWkVe8ruxHPtAaNPHLkgMCtAEJqFoA(WVe8ruxHPtW(rNPIHj3KM3i0NzNbBicwzYf3MUXsOlUIzPKckOOXCyL9J0aotdlvmm5MWocw5LGpI6kmDc2p6mvmm5M08gH(m7mydrWktU420nwcDXvmlLuqHpI6kmDc2p6mvmm5M08gH(C08HFPKssJW)GHpjFe1vy6ZXZhZ2X8OEKbvgAZBaNTrpWKHgoRzrHp8RmHnuaOOiVe8ruxHPtW(rNPIHj3KM3i0N5giqrJ5Wk7hH9kCO4yNxe2rWkVuqbfpSY(ryVchko25fHDeSYlbB0rI4FzNl0mqjLeOOIFe1vy6Kla(cAyPxbt34aK08gH(m7YnqaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfMo5cGVGgw6vW0noajnVrOpZnqaiG1sW(rNPFb2dmzE4lCUbkPKaqaRL0aotdlvmm5MSctxWgDKi(x25zWgIGvMGI0n0HBGnDJosf)tAe(hm8j5JOUctFoE(y2oMhyupLH28gWzB0dmzbNpuScDSZI(XEJ(IWgkauuKxc(iQRW0jGawlDbNpuScDSZI(XEJ(I0mUYsaiG1swW5dfRqh7SOFS3OVO2oMhzfMUafbbSwc2p6mvmm5MSctxaiG1sAaNPHLkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0vsWhrDfMo5cGVGgw6vW0noajnVrOpZnqGIGawlb7hDM(fypWK5HVWJMBybkQ4Hv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xc(iQRW0jy)OZuXWKBsZBe6ZSZGnebRm5IBt3yj0fxXSusbfu0yoSY(rAaNPHLkgMCtyhbR8sWhrDfMob7hDMkgMCtAEJqFMDgSHiyLjxCB6glHU4kMLskOWhrDfMob7hDMkgMCtAEJqFoA(WVusjPr4FWWNKpI6km9545JzHntbR48ugAZBaNTrpWKfC(qXk0Xol6h7n6lcBOaqrrEj4JOUctNacyT0fC(qXk0Xol6h7n6lsZ4klbGawlzbNpuScDSZI(XEJ(IAHntwHPlqS5m0HFrkNy7yEGr9KgzCLAdXQjM1uQbMSuVHDh9uQnHxHuJIePwORvQV42snCk1nJRSKACk1MCTQSuVrHzPEc0SuFHu)48KA4j1GSnAwQV42ePr4FWWNKpI6km9545JTHDh9Kgw6f9M9tzOn)JOUctNCbWxqdl9ky6ghGKM3i0N5giaeWAjy)OZ0Va7bMmp8fE0Cdl4JOUctNG9JotfdtUjnVrOphnF4xsJW)GHpjFe1vy6ZXZhBd7o6jnS0l6n7NYqB(hrDfMob7hDMkgMCtAEJqFMBGafnMdRSFe2RWHIJDEryhbR8sbfu8Wk7hH9kCO4yNxe2rWkVeSrhjI)LDUqZaLusGIk(ruxHPtUa4lOHLEfmDJdqsZBe6ZSZGnebRmbfPBSe6IRywcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyLuqbf)iQRW0jxa8f0WsVcMUXbiP5nc9zUbcabSwc2p6m9lWEGjZdFHZnqjLeacyTKgWzAyPIHj3Kvy6c2OJeX)Yopd2qeSYeuKUHoCdSPB0rQ4FsJmUsTHy1eZAk1atwQxmEfGr7SuBcVcPgfjsTqxRuFXTLA4uQBgxzj14uQn5AvzPEJcZs9eOzP(cP(X5j1WtQbzB0SuFXTjsJW)GHpjFe1vy6ZXZhBX4vagTZkdT5Fe1vy6Kla(cAyPxbt34aK08gH(m3abGawlb7hDM(fypWK5HVWJMBybFe1vy6eSF0zQyyYnP5nc95O5d)sAe(hm8j5JOUctFoE(ylgVcWODwzOn)JOUctNG9JotfdtUjnVrOpZnqGIgZHv2pc7v4qXXoViSJGvEPGckEyL9JWEfouCSZlc7iyLxc2OJeX)YoxOzGskjqrf)iQRW0jxa8f0WsVcMUXbiP5nc9z2LBGaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4CdusjbGawlPbCMgwQyyYnzfMUGn6ir8VSZZGnebRmbfPBOd3aB6gDKk(N0iJRul0BYs9ueBHLAOvQV42sn6lPgfLASzPoCP(xsn6lP2mCJ)KAqwQbeLAB0sDn8bUL6RaDP(kyPEJLi1lUIzPSuVrHH(GupbAwQnzPUaZWsnEsDLX5j1Nzi1y)OZs9xG9apLA0xs9vGNuFXTLAtC6g)j1cXbMNudm5frAe(hm8j5JOUctFoE(ynUGOF0Pi2cRm0M)ruxHPtUa4lOHLEfmDJdqsZBe6ZSZGnebRmPN0nwcDXvmlbFe1vy6eSF0zQyyYnP5nc9z2zWgIGvM0t6glHU4kMLafpSY(rAaNPHLkgMCtyhbR8sWhrDfMoPbCMgwQyyYnP5nc95O5d)sbfoSY(rAaNPHLkgMCtyhbR8sWhrDfMoPbCMgwQyyYnP5nc9z2zWgIGvM0t6glHU4kMLckymhwz)inGZ0WsfdtUjSJGvEPKaqaRLG9Jot)cShyY8Wx4SnSGfdcyTKla(cAyPxbt34aKSctxAKXvQf6nzPEkITWsTj8kKAuuQnlyxQfJ5ecwzIul01k1xCBPgoL6MXvwsnoLAtUwvwQ3OWSupbAwQVqQFCEsn8KAq2gnl1xCBI0i8py4tYhrDfM(C88XACbr)OtrSfwzOn)JOUctNCbWxqdl9ky6ghGKM3i0N5giaeWAjy)OZ0Va7bMmp8fE0Cdl4JOUctNG9JotfdtUjnVrOphnF4xsJW)GHpjFe1vy6ZXZhRXfe9JofXwyLH28pI6kmDc2p6mvmm5M08gH(m3abkQOXCyL9JWEfouCSZlc7iyLxkOGIhwz)iSxHdfh78IWocw5LGn6ir8VSZfAgOKscuuXpI6kmDYfaFbnS0RGPBCasAEJqFMDgSHiyLjOiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfMo5cGVGgw6vW0noajnVrOpZnqaiG1sW(rNPFb2dmzE4lCUbkPKaqaRL0aotdlvmm5MSctxWgDKi(x25zWgIGvMGI0n0HBGnDJosf)tjPrgxPwOZSAi6cHsTqVjl1xCBPgALAuuQHtPoCP(xsn6lP2mCJ)KAqwQbeLAB0sDn8bUL6RaDP(kyPEJLi1lUIzrKAdXkCWLAt4vi1Dik1qRuFfSuFyL9tQHtP(qHzNi1c5Duxsnk1GWtQVqQ3OWSupbAwQnzP(rxQfYPk1W9Mxq84AwsnApUL6lUTuZ(Aknc)dg(K8ruxHPphpFSla(cAyPxbt34auzOnheWAjy)OZ0Va7bMmp8fE0Cdl4Wk7hPbCMgwQyyYnHDeSYlbFe1vy6KgWzAyPIHj3KM3i0NJMp8lbFe1vy6eSF0zQyyYnP5nc9z2zWgIGvMCXTPBSe6IRywc(id7OFeHZQHOtyhbR8sWhrDfMoPXfe9JofXwysZBe6ZrZfssJmUsDzHleSqNz1q0fcLAHEtwQV42sn0k1OOudNsD4s9VKA0xsTz4g)j1GSudik12OL6A4dCl1xb6s9vWs9glrQxCfZIi1gIv4Gl1MWRqQ7quQHwP(kyP(Wk7NudNs9HcZorAe(hm8j5JOUctFoE(yxa8f0WsVcMUXbOYqBoiG1sW(rNPFb2dmzE4l8O5gwWHv2psd4mnSuXWKBc7iyLxc(iQRW0jnGZ0WsfdtUjnVrOphnF4xc(iQRW0jy)OZuXWKBsZBe6ZSZGnebRm5IBt3yj0fxXSeymFKHD0pIWz1q0jSJGvEjnc)dg(K8ruxHPphpFSla(cAyPxbt34auzOnheWAjy)OZ0Va7bMmp8fE0CdlWyoSY(rAaNPHLkgMCtyhbR8sWhrDfMob7hDMkgMCtAEJqFMDgSHiyLjxCB6glHU4kML0i8py4tYhrDfM(C88XUa4lOHLEfmDJdqLH2CqaRLG9Jot)cShyY8Wx4rZnSGpI6kmDc2p6mvmm5M08gH(C08HFjnY4k1c9MSuJIsn0k1xCBPgoL6WL6Fj1OVKAZWn(tQbzPgquQTrl11Wh4wQVc0L6RGL6nwIuV4kMLYs9gfg6ds9eOzP(kWtQnzPUaZWsn7bWqHuVrhLA0xs9vGNuFfCZsnCk1ECsnwBgxzj1Ou3aol1HvQfdtUL6vy6ePr4FWWNKpI6km9545JH9JotfdtUvgAZv0yoSY(ryVchko25fHDeSYlfuqXdRSFe2RWHIJDEryhbR8sWgDKi(x25cndusjbFe1vy6Kla(cAyPxbt34aK08gH(m7mydrWktqr6glHU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwaiG1sAaNPHLkgMCtwHPlyJose)l78mydrWktqr6g6WnWMUrhPI)jnY4k1c9MSu3HOudTs9f3wQHtPoCP(xsn6lP2mCJ)KAqwQbeLAB0sDn8bUL6RaDP(kyPEJLi1lUIzPSuVrHH(GupbAwQVcUzPgoDJ)KAS2mUYsQrPUbCwQxHPl1OVK6RapPgfLAZWn(tQb5p2SuJzqyfbRSuVaAOpi1nGZePr4FWWNKpI6km9545J1aotdlvmm5wzOnheWAjnGZ0WsfdtUjRW0f8ruxHPtUa4lOHLEfmDJdqsZBe6ZSZGnebRmPdr6glHU4kMLaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwGIFe1vy6eSF0zQyyYnP5nc9z2LlukOWIbbSwYfaFbnS0RGPBCasaevsAKXvQf6mRgIUqOulKtvQHtPEJok1fa(qNLuJ(sQnehXqoLASzP(IqQ5sezFcZWs9fsnWKLAXyl1xi1tdfGzHySuJUuZLCnk1iOudDP(kyP(IBl1MqFfMeP2qGpJFk1atwQHNuFHuVrHzPUgMs9xG9al1gIJmLAOpp0pI0i8py4tYhrDfM(C88XeBEY(Z0Ws3qFPm0MdcyTeSF0z6xG9atMh(cNBGGpYWo6hr4SAi6e2rWkVKgzCL6YcxiyHoZQHOlek1c9MSulgBP(cPEAOamleJLA0LAUKRrPgbLAOl1xbl1xCBP2e6RWKinc)dg(K8ruxHPphpFmXMNS)mnS0n0xkdT5lgeWAjxa8f0WsVcMUXbibquGX8rg2r)icNvdrNWocw5L0i8py4tYhrDfM(C88XaMmDJosh4TYqB(hrDfMoHZepEWWjnVrOpZ2abkQ4Hv2pc7v4qXXoViSJGvEjyJose)B0CHKbc2OJeX)Yo34iukPGckAmhwz)iSxHdfh78IWocw5LGn6ir8VrZfscLskjnsAKXvQhXAik1cbl1c54DKHLAdb84wAe(hm8jHNt2FEMdwJyrdl9kyk78olLH28pI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4rZnSGpI6kmDc2p6mvmm5M08gH(C08HFPGch2d8ro4MPxqxqE0pI6kmDc2p6mvmm5M08gH(uAe(hm8jHNt2FEoE(yG1iw0WsVcMYoVZszOn)JOUctNG9JotfdtUjnVrOpZnqGIgZHv2pc7v4qXXoViSJGvEPGckEyL9JWEfouCSZlc7iyLxc2OJeX)YoxOzGskjqrf)iQRW0jxa8f0WsVcMUXbiP5nc9z2LBGaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwjfuqXpI6kmDYfaFbnS0RGPBCasAEJqFMBGaqaRLG9Jot)cShyY8Wx4CdusjbGawlPbCMgwQyyYnzfMUGn6ir8VSZZGnebRmbfPBOd3aB6gDKk(N0i8py4tcpNS)8C88XmJUUYWqN28mC0FwzOn)JOUctNCbWxqdl9ky6ghGKM3i0N5giaeWAjy)OZ0Va7bMmp8fE0Cdl4JOUctNG9JotfdtUjnVrOphnF4xkOWH9aFKdUz6f0fKh9JOUctNG9JotfdtUjnVrOpLgH)bdFs45K9NNJNpMz01vgg60MNHJ(ZkdT5Fe1vy6eSF0zQyyYnP5nc9zUbcu0yoSY(ryVchko25fHDeSYlfuqXdRSFe2RWHIJDEryhbR8sWgDKi(x25cndusjbkQ4hrDfMo5cGVGgw6vW0noajnVrOpZUCdeacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2yj05HVWkPGck(ruxHPtUa4lOHLEfmDJdqsZBe6ZCdeacyTeSF0z6xG9atMh(cNBGskjaeWAjnGZ0WsfdtUjRW0fSrhjI)LDEgSHiyLjOiDdD4gyt3OJuX)KgH)bdFs45K9NNJNp2aa2li60WsrHyChxHYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnqaiG1sW(rNPFb2dmzE4l8O5gwWhrDfMob7hDMkgMCtAEJqFoA(WVuqHd7b(ihCZ0lOlip6hrDfMob7hDMkgMCtAEJqFknc)dg(KWZj7pphpFSbaSxq0PHLIcX4oUcLH28pI6kmDc2p6mvmm5M08gH(m3abkAmhwz)iSxHdfh78IWocw5LckO4Hv2pc7v4qXXoViSJGvEjyJose)l7CHMbkPKafv8JOUctNCbWxqdl9ky6ghGKM3i0NzxUbcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyLuqbf)iQRW0jxa8f0WsVcMUXbiP5nc9zUbcabSwc2p6m9lWEGjZdFHZnqjLeacyTKgWzAyPIHj3Kvy6c2OJeX)Yopd2qeSYeuKUHoCdSPB0rQ4FsJW)GHpj8CY(ZZXZh7d)z)A84f1wXnRCf6m9x5ghLH2CqaRLG9JotfdtUjRW0facyTKgWzAyPIHj3Kvy6cwmiG1sUa4lOHLEfmDJdqYkmDbB0rYb3m9c6glj7CUe(boMEWnlnc)dg(KWZj7pphpFSMrrOpqTvCZtLH2CqaRLG9JotfdtUjRW0facyTKgWzAyPIHj3Kvy6cwmiG1sUa4lOHLEfmDJdqYkmDbB0rYb3m9c6glj7CUe(boMEWnlnc)dg(KWZj7pphpFmB8atErrHyCdpMcY4wzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8jHNt2FEoE(yIan0Mf0hOGvCEkdT5Gawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6sJW)GHpj8CY(ZZXZhRHIIvMcD6ueFwzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8jHNt2FEoE(yxbtbCWaWxuB0pRm0MdcyTeSF0zQyyYnzfMUaqaRL0aotdlvmm5MSctxWIbbSwYfaFbnS0RGPBCaswHPlnc)dg(KWZj7pphpFSnVJolAyPvGhUORMX9uzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAK0i8py4tIf6yLcc0Eo2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)t5VaHEE5sJW)GHpjwOJvkiq7JNpg2p6mfSIZtAe(hm8jXcDSsbbAF88XW(rNPGy34alnsAe(hm8jbE8EMdmzk849uAK0i8py4tYoYWB2VCWk0fMIEwkdT57idVz)il48q)5SZl3aPr4FWWNKDKH3SFJNpMyZt2FMgw6g6lPr4FWWNKDKH3SFJNpg2p6mDdNtyLNkdT57idVz)il48q)5rl3aPr4FWWNKDKH3SFJNpg2p6mnAqPr4FWWNKDKH3SFJNpMf2mfSIZtAK0iJRuJ)bdFscr25opd2qeSYk74MZlWmmnezNxkhI5t(uodwb48YvgAZfBodD4xKYjCM4XdgU0i8py4tsiYo3JNpwfouCtQqCG1WM9tzOnheWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxAe(hm8jjezN7XZhdehOHLEn8fEQm0MdcyTeSF0zQyyYnzfMUaqaRL0aotdlvmm5MSctxWIbbSwYfaFbnS0RGPBCaswHPlnc)dg(KeISZ945J9yTsX)GHtRW5PSJBohE8EQm0MdcyTeSF0zQyyYnbquAe(hm8jjezN7XZhtmoy4kdT5Gawlb7hDMkgMCtaeLgH)bdFscr25E88Xa5EYTWqFqzOnheWAjy)OZuXWKBcGO0i8py4tsiYo3JNpgynIf1c0zPm0MdcyTeSF0zQyyYnbquAe(hm8jjezN7XZhZcBgSgXszOnheWAjy)OZuXWKBcGO0i8py4tsiYo3JNpg6ppVgR0hRvLH2CqaRLG9JotfdtUjaIsJW)GHpjHi7CpE(ywyZuWkopLH28gWzB0dmzbNpuScDSZI(XEJ(IWgkauuKxcabSwYcoFOyf6yNf9J9g9f12X8iaIsJW)GHpjHi7CpE(y2oMh1JmOYqBEd4Sn6bMm0Wznlk8HFLjSHcaff5LGn6ir8VSfIekPr4FWWNKqKDUhpFSnS7ON0WsVO3SFsJW)GHpjHi7CpE(ylgVcWODwAe(hm8jjezN7XZhRXfe9JofXwyLH28n6ir8VSnKginc)dg(KeISZ945J9O)CLI)bdxzOnh)dgozwaTh0hOIHj3KVaDNRqFqWWVinVrOpZnqAe(hm8jjezN7XZhBwaTh0hOIHj3kdT5ZaOcc9fXc56IgwkynMZypjSJGvEjnc)dg(KeISZ945JDbWxqdl9ky6ghGsJW)GHpjHi7CpE(yy)OZuXWKBPr4FWWNKqKDUhpFSgWzAyPIHj3kdT5GawlPbCMgwQyyYnzfMU0i8py4tsiYo3JNpgWKPB0r6aVvgAZv8Wk7hH9kCO4yNxe2rWkVeSrhjI)nAUqYabB0rI4FzNBCekLuqbfnMdRSFe2RWHIJDEryhbR8sWgDKi(3O5cjHsjPr4FWWNKqKDUhpFSdUzQj2IkdT5nGZ2OhyYXBXOXk1eBrcBOaqrrEjnc)dg(KeISZ945Jj28K9NPHLUH(szOnFXGawl5cGVGgw6vW0noajaIcwmiG1sUa4lOHLEfmDJdqsZBe6ZrZbbSwIyZt2FMgw6g6lYglHop8fwOp(hmCc2p6mfSIZJWLWpWX0dUzPr4FWWNKqKDUhpFmSF0zkyfNNYqB(kosJli6hDkITWKM3i0NzlukOWIbbSwsJli6hDkITW0mavNBeewHxwK5HVWzBG0i8py4tsiYo3JNpg2p6mfSIZtzOnheWAjInpz)zAyPBOViaIcwmiG1sUa4lOHLEfmDJdqcGOGfdcyTKla(cAyPxbt34aK08gH(C0C8py4eSF0zkyfNhHlHFGJPhCZsJW)GHpjHi7CpE(yy)OZuqSBCGvgAZbbSwc2p6mvmm5MaikaeWAjy)OZuXWKBsZBe6ZrZh(LaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwAe(hm8jjezN7XZhd7hDMUHZjSYtLH28fdcyTKla(cAyPxbt34aKaik4Wk7hb7hDMYFrqyhbR8saiG1swmEfGr7mzfMUGfdcyTKla(cAyPxbt34aK08gH(mB8py4eSF0z6goNWkpjCj8dCm9GBw5VaHEE5sJW)GHpjHi7CpE(yy)OZ0nCoHvEQm0MdcyTKVYy)48G(aPz8pL)ce65Llnc)dg(KeISZ945JH9JotJguzOnheWAjy)OZ0Va7bMmp8fE0CdlqXpI6kmDc2p6mvmm5M08gH(m7YnqbfW)Gzyk78gYZrZnSssJW)GHpjHi7CpE(yy)OZuWkopLH2CqaRL0aotdlvmm5MaiQGcB0rI4FzxUqjnc)dg(KeISZ945JXzIhpy4kdT5GawlPbCMgwQyyYnzfMUYq)4Ubepk0MVrhjI)LDUqsOug6h3nG4rH7nVG4X5Llnc)dg(KeISZ945JH9JotbXUXbwAK0i8py4tshhEWWZZGnebRSYoU5Cl0XkfeODLdX8jFkNbRaCE5kdT5Gawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnwcDE4lSaJbeWAjnqLPHLEfnZtcGOGd7b(ihCZ0lOlipAUIkUrhfYp(hmCc2p6mfSIZJ8X8usOp(hmCc2p6mfSIZJWLWpWX0dUzLKgzCLA8py4tshhEWWhpFS51W)Ot2qby)zLH28fdcyTKgxq0p6ueBHPzaQo3iiScVSiZdFHZxmiG1sACbr)OtrSfMMbO6CJGWk8YISXsOZdFHfacyTeSF0zQyyYnzfMUaqaRL0aotdlvmm5MSctxzh3CEfNhDkITW05HVWcHy)OZuWkopHqSF0zki2noWsJW)GHpjDC4bdF88XW(rNPGy34aRm0MVyqaRL04cI(rNIylmndq15gbHv4LfzE4lC(IbbSwsJli6hDkITW0mavNBeewHxwKnwcDE4lSafbbSwc2p6mvmm5MSctxbfabSwc2p6mvmm5M08gH(C08HFPKafbbSwsd4mnSuXWKBYkmDfuaeWAjnGZ0WsfdtUjnVrOphnF4xkjnc)dg(K0XHhm8XZhd7hDMcwX5Pm0MVIJ04cI(rNIylmP5nc9z2cLckSyqaRL04cI(rNIylmndq15gbHv4LfzE4lC2ginc)dg(K0XHhm8XZhd7hDMcwX5Pm0MdcyTeXMNS)mnS0n0xearblgeWAjxa8f0WsVcMUXbibquWIbbSwYfaFbnS0RGPBCasAEJqFoAo(hmCc2p6mfSIZJWLWpWX0dUzPr4FWWNKoo8GHpE(yy)OZ0nCoHvEQm0MVyqaRLCbWxqdl9ky6ghGearbhwz)iy)OZu(lcc7iyLxcabSwYIXRamANjRW0fO4IbbSwYfaFbnS0RGPBCasAEJqFMn(hmCc2p6mDdNtyLNeUe(boMEWnRGcFe1vy6eXMNS)mnS0n0xKM3i0NzBGck8rg2r)icNvdrNWocw5Lsk)fi0ZlxAe(hm8jPJdpy4JNpg2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)taiG1s4serFXlQyCSFqSsaeLgH)bdFs64Wdg(45JH9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)eOiiG1sW(rNPIHj3earfuaeWAjnGZ0WsfdtUjaIkOWIbbSwYfaFbnS0RGPBCasAEJqFMn(hmCc2p6mDdNtyLNeUe(boMEWnRKYFbc98YLgH)bdFs64Wdg(45JH9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)eacyTKVYy)48G(azE4lCoiG1s(kJ9JZd6dKnwcDE4lSYFbc98YLgH)bdFs64Wdg(45JH9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)eacyTKVYy)48G(aP5nc95O5kQiiG1s(kJ9JZd6dK5HVWc9X)GHtW(rNPB4CcR8KWLWpWX0dUzLgF4xkP8xGqpVCPr4FWWNKoo8GHpE(yoFfCtpElYZtzOnxXMTnplqWkRGcgZbFHH(GscabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxybGawlb7hDMkgMCtwHPlyXGawl5cGVGgw6vW0noajRW0LgH)bdFs64Wdg(45JH9JotJguzOnheWAjy)OZ0Va7bMmp8fE0Cdlnc)dg(K0XHhm8XZhBciYThzqLH28n6ir8VrZfIekbGawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6sJW)GHpjDC4bdF88XMfq7b9bQyyYTYqBoiG1sW(rNPIHj3Kvy6cabSwsd4mnSuXWKBYkmDblgeWAjxa8f0WsVcMUXbizfMUGpI6kmDcNjE8GHtAEJqFMTbc(iQRW0jy)OZuXWKBsZBe6ZSnqWhrDfMo5cGVGgw6vW0noajnVrOpZ2abkAmhwz)inGZ0WsfdtUjSJGvEPGckEyL9J0aotdlvmm5MWocw5LGpI6kmDsd4mnSuXWKBsZBe6ZSnqjLKgH)bdFs64Wdg(45JH9JotbR48ugAZbbSwsduzAyPxrZ8KaikaeWAjy)OZ0Va7bMmp8foBJvAKXvQhXAik1cbl1c54DKHLAdb84wAe(hm8jPJdpy4JNpg2p6mfe7ghyLH28n6ir8VrZGnebRmbe7ghy6gDKk(NGpI6kmDcNjE8GHtAEJqFMTbcabSwc2p6mvmm5MSctxaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(clGNt2FMKboHHtdlvKBl)hmCYg6rlnc)dg(K0XHhm8XZhd7hDMcIDJdSYqB(hrDfMo5cGVGgw6vW0noajnVrOpZnqGIFe1vy6KgWzAyPIHj3KM3i0N5gOGcFe1vy6eSF0zQyyYnP5nc9zUbkjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHLgH)bdFs64Wdg(45JH9JotbXUXbwzOnFJose)B08mydrWktaXUXbMUrhPI)jaeWAjy)OZuXWKBYkmDbGawlPbCMgwQyyYnzfMUGfdcyTKla(cAyPxbt34aKSctxaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cl4JOUctNWzIhpy4KM3i0NzBG0i8py4tshhEWWhpFmSF0zki2noWkdT5Gawlb7hDMkgMCtwHPlaeWAjnGZ0WsfdtUjRW0fSyqaRLCbWxqdl9ky6ghGKvy6cabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68Wxybhwz)iy)OZ0ObjSJGvEj4JOUctNG9JotJgK08gH(C08HFjyJose)B0CHide8ruxHPt4mXJhmCsZBe6ZSnqAe(hm8jPJdpy4JNpg2p6mfe7ghyLH2CqaRLG9JotfdtUjaIcabSwc2p6mvmm5M08gH(C08HFjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHLgH)bdFs64Wdg(45JH9JotbXUXbwzOnheWAjnGZ0WsfdtUjaIcabSwsd4mnSuXWKBsZBe6ZrZh(LaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwAe(hm8jPJdpy4JNpg2p6mfSIZtAe(hm8jPJdpy4JNpgNjE8GHRm0pUBaXJcT5B0rI4FzNlKekLH(XDdiEu4EZliECE5sJW)GHpjDC4bdF88XW(rNPGy34aNurGRi6KQkCduXdgUqGgTx6sxkb]] )


end
