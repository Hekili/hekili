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


    spec:RegisterPack( "Arcane", 20201013, [[d4eyJdqiku6ruOsxIGKQAte4tuOQrrcDksKvrqk1RuOAwKOUfbbQDb6xkuggf4ykOwgfupJcftJcIUgbrBJcv8nkimocsCoccADeeY8uiDpr1(eL6GeKQwOcXdjiGjsqsfDrcsQKpsqG0ijiPsDscsrRKc5LeKcntcsLBsqsv2PcYpjifmucsQWsjiP8usAQkqxLGuYxjiqmwcsYEf5VqnysDyKfd0Jv1Kv0LrTzk9zP0OLItdz1eeQEnb1SLQBRu7MQFlmCcDCkiTCjpxjtxLRdy7IIVtrJxbCErjRNGqz(KG9t0PHtdMuN0XPHmSbg2GHnyyJbAGbgJXyinKj1llroPksVWulNuDAZjvH(6jNtQIuw9GMPbtQRaOEoP2CN4siASXArxdai8J9yl0gOthk8Vi7n2cT)XsQGaO(j00tGj1jDCAidBGHnyydg2yGgyGXymgYK6sK)0qghdNuBqZj7jWK6KxFs14k1c91tol1c1JAzPrgxPwOH)cqUKAHqLLAdBGHniP2rRBLgmPgISZvAW0qdNgmPYob25zAKK6xOJleLubbSwivp5mwmm5codtxQfi1GawlSaCghwSyyYfCgMUulqQNmiG1cVa4BWHfFnmEtTi4mm9Kk9hk8KAh12ClSqCGz7M9lDPHmCAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKl4mmDPwGudcyTWcWzCyXIHjxWzy6sTaPEYGawl8cGVbhw81W4n1IGZW0tQ0FOWtQGuloS4RqVWR0LgYysdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbbetQ0FOWtQalgJoEVsxAidzAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsfKRfxcJ820LgsitdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbbetQ0FOWtQG9iMylqLv6sdzCsdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbbetQ0FOWtQwuXG9iMPlnKHinysLDcSZZ0ij1VqhxikPccyTqQEYzSyyYfeqmPs)HcpPs(ZRROo(PEpDPHekPbtQStGDEMgjP(f64crj1cWzBuTmCIwpsSJCQYc)XEt(eYgkasuKNsTaPgeWAHt06rIDKtvw4p2BYNyBfRdciMuP)qHNuTOIXGDADPlnKqyAWKk7eyNNPrsQFHoUqusTaC2gvldBl0QNfg9OVZq2qbqII8uQfi1BYjO4FsD2sTqOqMuP)qHNuTvSoShzO0LgAydsdMuP)qHNu3OQIAHdl(IAZ(LuzNa78mns6sdn8WPbtQ0FOWtQtMUgWOCoPYob25zAK0LgAydNgmPYob25zAKK6xOJleLu3KtqX)K6SLAdPbjv6pu4j1IMiYp8sKkHtxAOHnM0Gjv2jWoptJKu)cDCHOKk9hkC4QbzpK3IfdtUGFd5o3rERulqQB)jS4nH8LuNl1gKuP)qHNuFYFUJP)qHNU0qdBitdMuzNa78mnss9l0XfIsQRaOdI8j0I4(ehwmypwRyVGStGDEMuP)qHNuxni7H8wSyyYv6sdnSqMgmPs)HcpPEbW3Gdl(Ay8MArjv2jWoptJKU0qdBCsdMuP)qHNuP6jNXIHjxjv2jWoptJKU0qdBisdMuzNa78mnss9l0XfIsQGawlSaCghwSyyYfCgMEsL(dfEsTaCghwSyyYv6sdnSqjnysLDcSZZ0ij1VqhxikPQOuFuN9dYEh12CSZti7eyNNsTaPEtobf)tQhnxQfkgi1cK6n5eu8pPo7CP24iKsTssTcki1kk1gRuFuN9dYEh12CSZti7eyNNsTaPEtobf)tQhnxQfkcPuRusL(dfEsDtoHB5D6sdnSqyAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsfKRfxcJ820LgYWgKgmPYob25zAKK6xOJleLulaNTr1YWJ3IrrDSjvIq2qbqII8mPs)HcpPEOnJnPsmDPHm8WPbtQStGDEMgjP(f64crj1jdcyTWla(gCyXxdJ3ulccik1cK6jdcyTWla(gCyXxdJ3ulcw8Mq(sQhnxQbbSwOyXl2Fghw8g5t4MgaVo6fwQfAl10FOWHu9KZyWoToipa)ahJp0MtQ0FOWtQIfVy)zCyXBKptxAidB40Gjv2jWoptJKu)cDCHOK6moyrte5hEjsLWWI3eYxsD2sTqk1kOGupzqaRfw0er(HxIujmodq35IarD0LfCD0lSuNTuBqsL(dfEsLQNCgd2P1LU0qg2ysdMuzNa78mnss9l0XfIsQGawluS4f7pJdlEJ8jequQfi1tgeWAHxa8n4WIVggVPweequQfi1tgeWAHxa8n4WIVggVPweS4nH8LupAUut)Hchs1toJb706G8a8dCm(qBoPs)HcpPs1toJb706sxAidBitdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbbeLAbsniG1cP6jNXIHjxWI3eYxs9O5sD7pLAbsniG1cP6jNXFdvTmCD0lSuNl1GawlKQNCg)nu1YWnnaED0lCsL(dfEsLQNCgdsvrTC6sdzyHmnysLDcSZZ0ijv6pu4jvQEYz8gTwOoVsQFdH8K6Wj1VqhxikPozqaRfEbW3Gdl(Ay8MArqarPwGuFuN9ds1toJ5VjGStGDEk1cKAqaRfoz6AaJYz4mmDPwGupzqaRfEbW3Gdl(Ay8MArWI3eYxsD2sn9hkCivp5mEJwluNxqEa(bogFOnNU0qg24KgmPYob25zAKKk9hk8Kkvp5mEJwluNxj1VHqEsD4K6xOJleLubbSw43zQEADiVfwm9x6sdzydrAWKk7eyNNPrsQFHoUqusfeWAHu9KZ4VHQwgUo6fwQhnxQnSulqQvuQ)i6ZW0Hu9KZyXWKlyXBc5lPoBPEydKAfuqQP)qzym78gXlPE0CP2WsTsjv6pu4jvQEYzCuGPlnKHfkPbtQStGDEMgjP(f64crjvqaRfwaoJdlwmm5ccik1kOGuVjNGI)j1zl1dlKjv6pu4jvQEYzmyNwx6sdzyHW0Gjv2jWoptJKuP)qHNu5mXthk8KkYpUkaXdJSj1n5eu8VSZfkczsf5hxfG4Hr7npr0Xj1HtQFHoUqusfeWAHfGZ4WIfdtUGZW0txAiJXG0Gjv6pu4jvQEYzmivf1Yjv2jWoptJKU0Lu51I9NxPbtdnCAWKk7eyNNPrsQFHoUqus9JOpdthEbW3Gdl(Ay8MArWI3eYxsDUuBGulqQbbSwivp5m(BOQLHRJEHL6rZLAdl1cK6pI(mmDivp5mwmm5cw8Mq(sQhnxQB)PuRGcs9rvlFWdTz8f4jIL6rL6pI(mmDivp5mwmm5cw8Mq(kPs)HcpPc2JyIdl(Aym78oR0LgYWPbtQStGDEMgjP(f64crj1pI(mmDivp5mwmm5cw8Mq(sQZLAdKAbsTIsTXk1h1z)GS3rTnh78eYob25PuRGcsTIs9rD2pi7DuBZXopHStGDEk1cK6n5eu8pPo7CP2qyGuRKuRKulqQvuQvuQ)i6ZW0Hxa8n4WIVggVPweS4nH8LuNTupSbsTaPgeWAHu9KZ4VHQwgUo6fwQZLAqaRfs1toJ)gQAz4MgaVo6fwQvsQvqbPwrP(JOpdthEbW3Gdl(Ay8MArWI3eYxsDUuBGulqQbbSwivp5m(BOQLHRJEHL6CP2aPwjPwjPwGudcyTWcWzCyXIHjxWzy6sTaPEtobf)tQZoxQZqfIa7mKeXBKJ2aB8MCcl(xsL(dfEsfShXehw81Wy25DwPlnKXKgmPYob25zAKK6xOJleLu)i6ZW0Hxa8n4WIVggVPweS4nH8LuNl1gi1cKAqaRfs1toJ)gQAz46OxyPE0CP2WsTaP(JOpdths1toJfdtUGfVjKVK6rZL62Fk1kOGuFu1Yh8qBgFbEIyPEuP(JOpdths1toJfdtUGfVjKVsQ0FOWtQMr1NzyKJlEfo5pNU0qgY0Gjv2jWoptJKu)cDCHOK6hrFgMoKQNCglgMCblEtiFj15sTbsTaPwrP2yL6J6SFq27O2MJDEczNa78uQvqbPwrP(Oo7hK9oQT5yNNq2jWopLAbs9MCck(NuNDUuBimqQvsQvsQfi1kk1kk1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZwQh2aPwGudcyTqQEYz83qvldxh9cl15sniG1cP6jNXFdvTmCtdGxh9cl1kj1kOGuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoxQnqQfi1GawlKQNCg)nu1YW1rVWsDUuBGuRKuRKulqQbbSwyb4moSyXWKl4mmDPwGuVjNGI)j1zNl1zOcrGDgsI4nYrBGnEtoHf)lPs)HcpPAgvFMHroU4v4K)C6sdjKPbtQStGDEMgjP(f64crj1pI(mmD4faFdoS4RHXBQfblEtiFj15sTbsTaPgeWAHu9KZ4VHQwgUo6fwQhnxQnSulqQ)i6ZW0Hu9KZyXWKlyXBc5lPE0CPU9NsTcki1hvT8bp0MXxGNiwQhvQ)i6ZW0Hu9KZyXWKlyXBc5RKk9hk8KAlavte54WIjHyCfxt6sdzCsdMuzNa78mnss9l0XfIsQFe9zy6qQEYzSyyYfS4nH8LuNl1gi1cKAfLAJvQpQZ(bzVJABo25jKDcSZtPwbfKAfL6J6SFq27O2MJDEczNa78uQfi1BYjO4FsD25sTHWaPwjPwjPwGuROuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoBPEydKAbsniG1cP6jNXFdvTmCD0lSuNl1GawlKQNCg)nu1YWnnaED0lSuRKuRGcsTIs9hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGudcyTqQEYz83qvldxh9cl15sTbsTssTssTaPgeWAHfGZ4WIfdtUGZW0LAbs9MCck(NuNDUuNHkeb2zijI3ihTb24n5ew8VKk9hk8KAlavte54WIjHyCfxt6sdzisdMuzNa78mnssL(dfEs9d)z)k64j22PnNu)cDCHOKkiG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPl1cK6n5e8qBgFbEtdi1zNl18a8dCm(qBoP2roJ)zs14KU0qcL0Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPl1cK6n5e8qBgFbEtdi1zNl18a8dCm(qBoPs)HcpPwmjI8wSTtBELU0qcHPbtQStGDEMgjP(f64crjvqaRfs1toJfdtUGZW0LAbsniG1claNXHflgMCbNHPl1cK6jdcyTWla(gCyXxdJ3ulcodtpPs)HcpPAJhyXtmjeJl0XyqM2Pln0WgKgmPYob25zAKK6xOJleLubbSwivp5mwmm5codtxQfi1GawlSaCghwSyyYfCgMUulqQNmiG1cVa4BWHfFnmEtTi4mm9Kk9hk8KQiqHSzH8wmyNwx6sdn8WPbtQStGDEMgjP(f64crjvqaRfs1toJfdtUGZW0LAbsniG1claNXHflgMCbNHPl1cK6jdcyTWla(gCyXxdJ3ulcodtpPs)HcpPwirXoJroEjspNU0qdB40Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPNuP)qHNuVggd4GbGpX2OEoDPHg2ysdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbNHPl1cKAqaRfwaoJdlwmm5codtxQfi1tgeWAHxa8n4WIVggVPweCgMEsL(dfEsDZ7OYchwCh4rt8SyAVsx6sQvC0HcpnyAOHtdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCsD4K6xOJleLubbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLAbsTXk1GawlSa6moS4RPyEbbeLAbs9rvlFWdTz8f4jIL6rZLAfLAfL6n5KupMut)Hchs1toJb706GFSoPwjPwOTut)Hchs1toJb706G8a8dCm(qBwQvkPMHkStBoPAro1XGaLNU0qgonysLDcSZZ0ij1VqhxikPozqaRfw0er(HxIujmodq35IarD0LfCD0lSuNl1tgeWAHfnrKF4LivcJZa0DUiquhDzb30a41rVWsTaPwrPgeWAHu9KZyXWKl4mmDPwbfKAqaRfs1toJfdtUGfVjKVK6rZL62Fk1kj1cKAfLAqaRfwaoJdlwmm5codtxQvqbPgeWAHfGZ4WIfdtUGfVjKVK6rZL62Fk1kLuP)qHNuP6jNXGuvulNU0qgtAWKk7eyNNPrsQFHoUqusDghSOjI8dVePsyyXBc5lPoBPwiLAfuqQNmiG1clAIi)WlrQegNbO7CrGOo6YcUo6fwQZwQniPs)HcpPs1toJb706sxAidzAWKk7eyNNPrsQFHoUqusfeWAHIfVy)zCyXBKpHaIsTaPEYGawl8cGVbhw81W4n1IGaIsTaPEYGawl8cGVbhw81W4n1IGfVjKVK6rZLA6pu4qQEYzmyNwhKhGFGJXhAZjv6pu4jvQEYzmyNwx6sdjKPbtQStGDEMgjPs)HcpPs1toJ3O1c15vs9BiKNuhoP(f64crj1jdcyTWla(gCyXxdJ3ulccik1cK6J6SFqQEYzm)nbKDcSZtPwGudcyTWjtxdyuodNHPl1cKAfL6jdcyTWla(gCyXxdJ3ulcw8Mq(sQZwQP)qHdP6jNXB0AH68cYdWpWX4dTzPwbfK6pI(mmDOyXl2Fghw8g5tyXBc5lPoBP2aPwbfK6pYWo5hu4Ske5sTsPlnKXjnysLDcSZZ0ij1VqhxikPccyTWVZu906qElSy6pPwGudcyTqEarYN8elgh7hI6qaXKk9hk8Kkvp5mEJwluNxPlnKHinysLDcSZZ0ijv6pu4jvQEYz8gTwOoVsQFdH8K6Wj1VqhxikPccyTWVZu906qElSy6pPwGuROudcyTqQEYzSyyYfequQvqbPgeWAHfGZ4WIfdtUGaIsTcki1tgeWAHxa8n4WIVggVPweS4nH8LuNTut)Hchs1toJ3O1c15fKhGFGJXhAZsTsPlnKqjnysLDcSZZ0ijv6pu4jvQEYz8gTwOoVsQFdH8K6Wj1VqhxikPccyTWVZu906qElSy6pPwGudcyTWVZu906qElCD0lSuNl1Gawl87mvpToK3c30a41rVWPlnKqyAWKk7eyNNPrsQ0FOWtQu9KZ4nATqDELu)gc5j1HtQFHoUqusfeWAHFNP6P1H8wyX0FsTaPgeWAHFNP6P1H8wyXBc5lPE0CPwrPwrPgeWAHFNP6P1H8w46OxyPwOTut)Hchs1toJ3O1c15fKhGFGJXhAZsTss94sD7pLALsxAOHninysLDcSZZ0ij1VqhxikPQOuxST4vdb2zPwbfKAJvQp0lmYBLALKAbsniG1cP6jNXFdvTmCD0lSuNl1GawlKQNCg)nu1YWnnaED0lSulqQbbSwivp5mwmm5codtxQfi1tgeWAHxa8n4WIVggVPweCgMEsL(dfEs15RHl8XBrEDPln0WdNgmPYob25zAKK6xOJleLubbSwivp5m(BOQLHRJEHL6rZLAdNuP)qHNuP6jNXrbMU0qdB40Gjv2jWoptJKu)cDCHOK6MCck(NupAUulekKsTaPgeWAHu9KZyXWKl4mmDPwGudcyTWcWzCyXIHjxWzy6sTaPEYGawl8cGVbhw81W4n1IGZW0tQ0FOWtQlarU8idLU0qdBmPbtQStGDEMgjP(f64crjvqaRfs1toJfdtUGZW0LAbsniG1claNXHflgMCbNHPl1cK6jdcyTWla(gCyXxdJ3ulcodtxQfi1Fe9zy6qot80Hchw8Mq(sQZwQnqQfi1Fe9zy6qQEYzSyyYfS4nH8LuNTuBGulqQ)i6ZW0Hxa8n4WIVggVPweS4nH8LuNTuBGulqQvuQnwP(Oo7hSaCghwSyyYfKDcSZtPwbfKAfL6J6SFWcWzCyXIHjxq2jWopLAbs9hrFgMoSaCghwSyyYfS4nH8LuNTuBGuRKuRusL(dfEsD1GShYBXIHjxPln0WgY0Gjv2jWoptJKu)cDCHOKkiG1clGoJdl(AkMxqarPwGudcyTqQEYz83qvldxh9cl1zl1gtsL(dfEsLQNCgd2P1LU0qdlKPbtQStGDEMgjP(f64crj1n5eu8pPEuPodvicSZqqQkQLXBYjS4FsTaP(JOpdthYzINou4WI3eYxsD2sTbsTaPgeWAHu9KZyXWKl4mmDPwGudcyTqQEYz83qvldxh9cl15sniG1cP6jNXFdvTmCtdGxh9cl1cKAETy)zyg0cfooSyrUS8FOWHBKhvsL(dfEsLQNCgdsvrTC6sdnSXjnysLDcSZZ0ij1VqhxikP(r0NHPdVa4BWHfFnmEtTiyXBc5lPoxQnqQfi1kk1Fe9zy6WcWzCyXIHjxWI3eYxsDUuBGuRGcs9hrFgMoKQNCglgMCblEtiFj15sTbsTssTaPgeWAHu9KZ4VHQwgUo6fwQZLAqaRfs1toJ)gQAz4MgaVo6foPs)HcpPs1toJbPQOwoDPHg2qKgmPYob25zAKK6xOJleLu3KtqX)K6rZL6muHiWodbPQOwgVjNWI)j1cKAqaRfs1toJfdtUGZW0LAbsniG1claNXHflgMCbNHPl1cK6jdcyTWla(gCyXxdJ3ulcodtxQfi1GawlKQNCg)nu1YW1rVWsDUudcyTqQEYz83qvld30a41rVWsTaP(JOpdthYzINou4WI3eYxsD2sTbjv6pu4jvQEYzmivf1YPln0WcL0Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPl1cKAqaRfs1toJ)gQAz46OxyPoxQbbSwivp5m(BOQLHBAa86OxyPwGuFuN9ds1toJJceYob25PulqQ)i6ZW0Hu9KZ4OaHfVjKVK6rZL62Fk1cK6n5eu8pPE0CPwi0aPwGu)r0NHPd5mXthkCyXBc5lPoBP2GKk9hk8Kkvp5mgKQIA50LgAyHW0Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxqarPwGudcyTqQEYzSyyYfS4nH8LupAUu3(tPwGudcyTqQEYz83qvldxh9cl15sniG1cP6jNXFdvTmCtdGxh9cNuP)qHNuP6jNXGuvulNU0qg2G0Gjv2jWoptJKu)cDCHOKkiG1claNXHflgMCbbeLAbsniG1claNXHflgMCblEtiFj1JMl1T)uQfi1GawlKQNCg)nu1YW1rVWsDUudcyTqQEYz83qvld30a41rVWjv6pu4jvQEYzmivf1YPlnKHhonysL(dfEsLQNCgd2P1LuzNa78mns6sdzydNgmPI8JRcq8WiBsDtobf)l7CHIqMur(XvbiEy0EZteDCsD4Kk9hk8KkNjE6qHNuzNa78mns6sdzyJjnysL(dfEsLQNCgdsvrTCsLDcSZZ0iPlDj1jBjG(Lgmn0WPbtQStGDEMgjP(f64crj1JQw(GtgeWAHpToK3clM(lPs)HcpP(bGFCTe5EpDPHmCAWKk7eyNNPrsQ0FOWtQp17y6pu44oADj1oADyN2CsLxl2FELU0qgtAWKk7eyNNPrsQFHoUqusL(dLHXSZBeVK6SLAdNuP)qHNuFQ3X0FOWXD06sQD06WoT5KkfC6sdzitdMuzNa78mnss9l0XfIsQzOcrGDg2qzyCiYopL6CP2GKk9hk8K6t9oM(dfoUJwxsTJwh2PnNudr25kDPHeY0Gjv2jWoptJKuP)qHNuFQ3X0FOWXD06sQD06WoT5K6hrFgM(kDPHmoPbtQStGDEMgjP(f64crj1muHiWodTiN6yqGYL6CP2GKk9hk8K6t9oM(dfoUJwxsTJwh2PnNuR4OdfE6sdzisdMuzNa78mnss9l0XfIsQzOcrGDgAro1XGaLl15s9Wjv6pu4j1N6Dm9hkCChTUKAhToStBoPAro1XGaLNU0qcL0Gjv2jWoptJKuP)qHNuFQ3X0FOWXD06sQD06WoT5K6oYWB2V0LUKQyXFSbPlnyAOHtdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCs1GKAgQWoT5KQyXIa9oMZePlnKHtdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCsD4K6xOJleLulaNTr1YWfsSjC86IAdzdfajkYtPwGut)HYWy25nIxsD2sTHtQzOc70MtQIflc07yotKU0qgtAWKk7eyNNPrsQHysDXxsL(dfEsndvicSZj1muhGtQdNu)cDCHOKAb4SnQwgUqInHJxxuBiBOairrEk1cK6pYWo5h05VIEutPwGut)HYWy25nIxsD2s9Wj1muHDAZjvXIfb6DmNjsxAidzAWKk7eyNNPrsQHysDXxsL(dfEsndvicSZj1muhGtQdNu)cDCHOKAb4SnQwgUqInHJxxuBiBOairrEk1cK6pYWo5h0rTnh2sCsndvyN2CsvSyrGEhZzI0LgsitdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCs1GKAgQWoT5KQf5uhdcuE6sdzCsdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCsvitQzOc70MtQ1cVPbWtUtzLU0qgI0Gjv2jWoptJKudXK6IVKk9hk8KAgQqeyNtQzOoaNuh2GKAgQWoT5KkjI30a4j3PSsxAiHsAWKk7eyNNPrsQHysDXxsL(dfEsndvicSZj1muhGtQg2GKAgQWoT5KAfI4nnaEYDkR0LgsimnysLDcSZZ0ij1qmPU4lPs)HcpPMHkeb25KAgQdWjvHmPMHkStBoPEXTXBAa8K7uwPln0WgKgmPYob25zAKKAiMux8LuP)qHNuZqfIa7Csnd1b4KQXKu)cDCHOKAb4SnQwgorRhj2rovzH)yVjFczdfajkYZKAgQWoT5K6f3gVPbWtUtzLU0qdpCAWKk7eyNNPrsQHysDXxsL(dfEsndvicSZj1muhGtQdlKj1VqhxikP(rg2j)GoQT5WwItQzOc70MtQxCB8Mgap5oLv6sdnSHtdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCsDyHmP(f64crj1p8ja6Gu9KZyXkMO2SGStGDEk1cKA6puggZoVr8sQhvQnMKAgQWoT5K6f3gVPbWtUtzLU0qdBmPbtQStGDEMgjPgIj1fFjv6pu4j1muHiWoNuZqDaoPAmgKu)cDCHOKkVwS)mmdAHchhwSixw(pu4WnYJkPMHkStBoPEXTXBAa8K7uwPln0WgY0Gjv2jWoptJKudXK6IVKk9hk8KAgQqeyNtQzOoaNufcniPMHkStBoPcsvrTmEtoHf)lDPHgwitdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCsvOyqs9l0XfIsQFKHDYpOJABoSL4KAgQWoT5Kkivf1Y4n5ew8V0LgAyJtAWKk7eyNNPrsQHysDXxsL(dfEsndvicSZj1muhGtQgJbj1muHDAZjvseVroAdSXBYjS4FPln0WgI0Gjv2jWoptJKudXK6IVKk9hk8KAgQqeyNtQzOoaNufsdsQFHoUqusTaC2gvldNO1Je7iNQSWFS3KpHSHcGef5zsndvyN2CsLeXBKJ2aB8MCcl(x6sdnSqjnysLDcSZZ0ij1qmPU4lPs)HcpPMHkeb25KAgQdWjvH0GK6xOJleLulaNTr1YW2cT6zHrp67mKnuaKOiptQzOc70MtQKiEJC0gyJ3KtyX)sxAOHfctdMuzNa78mnssnetQl(sQ0FOWtQzOcrGDoPMH6aCs1Wj1muHDAZjvky8f3g)nu1YR0LgYWgKgmPs)HcpPUa27WXu9KZylTrDevjv2jWoptJKU0qgE40Gjv6pu4jvQEYzmYpU35)sQStGDEMgjDPHmSHtdMuP)qHNu)WfIdumEtoHB5DsLDcSZZ0iPlnKHnM0Gjv6pu4j1nQQOWOn1Yjv2jWoptJKU0qg2qMgmPs)HcpPkghk8Kk7eyNNPrsxAidlKPbtQStGDEMgjP(f64crj1muHiWodflweO3XCMqQZLAdKAbsDb4SnQwgorRhj2rovzH)yVjFczdfajkYtPwGu)r0NHPdbbSw8eTEKyh5uLf(J9M8jSyAMLulqQbbSw4eTEKyh5uLf(J9M8j2wX6GZW0tQ0FOWtQ2kwhy0V0LgYWgN0Gjv2jWoptJKu)cDCHOKAgQqeyNHIflc07yoti15s9Wjv6pu4jvot80HcpDPlP(r0NHPVsdMgA40Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPNuP)qHNu7O2MBHfIdmB3SFPlnKHtdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbNHPl1cKAqaRfwaoJdlwmm5codtxQfi1tgeWAHxa8n4WIVggVPweCgMEsL(dfEsfKAXHfFf6fELU0qgtAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsfyXy0X7v6sdzitdMuzNa78mnss9l0XfIsQGawlKQNCglgMCbbetQ0FOWtQGCT4syK3MU0qczAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsfShXeBbQSsxAiJtAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEs1IkgShXmDPHmePbtQStGDEMgjP(f64crjvqaRfs1toJfdtUGaIjv6pu4jvYFEDf1Xp17PlnKqjnysLDcSZZ0ij1VqhxikPwaoBJQLHTfA1ZcJE03ziBOairrEk1cK6pI(mmDivp5mwmm5cw8Mq(sQZwQngdKAbs9hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGuROudcyTqQEYz83qvldxh9cl1JMl1gwQfi1kk1kk1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDyb4moSyXWKlyXBc5lPE0CPU9NsTaP(JOpdths1toJfdtUGfVjKVK6SL6muHiWodV424nnaEYDklPwjPwbfKAfLAJvQpQZ(blaNXHflgMCbzNa78uQfi1Fe9zy6qQEYzSyyYfS4nH8LuNTuNHkeb2z4f3gVPbWtUtzj1kj1kOGu)r0NHPdP6jNXIHjxWI3eYxs9O5sD7pLALKALsQ0FOWtQ2kwh2Jmu6sdjeMgmPYob25zAKK6xOJleLulaNTr1YW2cT6zHrp67mKnuaKOipLAbs9hrFgMoKQNCglgMCblEtiFj15sTbsTaPwrP2yL6J6SFq27O2MJDEczNa78uQvqbPwrP(Oo7hK9oQT5yNNq2jWopLAbs9MCck(NuNDUuBimqQvsQvsQfi1kk1kk1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZwQh2aPwGudcyTqQEYz83qvldxh9cl15sniG1cP6jNXFdvTmCtdGxh9cl1kj1kOGuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoxQnqQfi1GawlKQNCg)nu1YW1rVWsDUuBGuRKuRKulqQbbSwyb4moSyXWKl4mmDPwGuVjNGI)j1zNl1zOcrGDgsI4nYrBGnEtoHf)lPs)HcpPARyDypYqPln0WgKgmPYob25zAKK6xOJleLulaNTr1YWjA9iXoYPkl8h7n5tiBOairrEk1cK6pI(mmDiiG1INO1Je7iNQSWFS3KpHftZSKAbsniG1cNO1Je7iNQSWFS3KpX2kwhCgMUulqQvuQbbSwivp5mwmm5codtxQfi1GawlSaCghwSyyYfCgMUulqQNmiG1cVa4BWHfFnmEtTi4mmDPwjPwGu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoxQnqQfi1kk1GawlKQNCg)nu1YW1rVWs9O5sTHLAbsTIsTIs9rD2pyb4moSyXWKli7eyNNsTaP(JOpdthwaoJdlwmm5cw8Mq(sQhnxQB)PulqQ)i6ZW0Hu9KZyXWKlyXBc5lPoBPodvicSZWlUnEtdGNCNYsQvsQvqbPwrP2yL6J6SFWcWzCyXIHjxq2jWopLAbs9hrFgMoKQNCglgMCblEtiFj1zl1zOcrGDgEXTXBAa8K7uwsTssTcki1Fe9zy6qQEYzSyyYfS4nH8LupAUu3(tPwjPwPKk9hk8KQTI1bg9lDPHgE40Gjv2jWoptJKu)cDCHOKAb4SnQwgorRhj2rovzH)yVjFczdfajkYtPwGu)r0NHPdbbSw8eTEKyh5uLf(J9M8jSyAMLulqQbbSw4eTEKyh5uLf(J9M8j2IkgodtxQfi1IfNb3(t4WqBfRdm6xsL(dfEs1Ikgd2P1LU0qdB40Gjv2jWoptJKu)cDCHOK6hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGudcyTqQEYz83qvldxh9cl1JMl1gwQfi1Fe9zy6qQEYzSyyYfS4nH8LupAUu3(ZKk9hk8K6gvvulCyXxuB2V0LgAyJjnysLDcSZZ0ij1VqhxikP(r0NHPdP6jNXIHjxWI3eYxsDUuBGulqQvuQnwP(Oo7hK9oQT5yNNq2jWopLAfuqQvuQpQZ(bzVJABo25jKDcSZtPwGuVjNGI)j1zNl1gcdKALKALKAbsTIsTIs9hrFgMo8cGVbhw81W4n1IGfVjKVK6SL6muHiWodjr8Mgap5oLLulqQbbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLALKAfuqQvuQ)i6ZW0Hxa8n4WIVggVPweS4nH8LuNl1gi1cKAqaRfs1toJ)gQAz46OxyPoxQnqQvsQvsQfi1GawlSaCghwSyyYfCgMUulqQ3KtqX)K6SZL6muHiWodjr8g5OnWgVjNWI)LuP)qHNu3OQIAHdl(IAZ(LU0qdBitdMuzNa78mnss9l0XfIsQFe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZLAdKAbsniG1cP6jNXFdvTmCD0lSupAUuByPwGu)r0NHPdP6jNXIHjxWI3eYxs9O5sD7ptQ0FOWtQtMUgWOCoDPHgwitdMuzNa78mnss9l0XfIsQFe9zy6qQEYzSyyYfS4nH8LuNl1gi1cKAfLAJvQpQZ(bzVJABo25jKDcSZtPwbfKAfL6J6SFq27O2MJDEczNa78uQfi1BYjO4FsD25sTHWaPwjPwjPwGuROuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoBPEydKAbsniG1cP6jNXFdvTmCD0lSuNl1GawlKQNCg)nu1YWnnaED0lSuRKuRGcsTIs9hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGudcyTqQEYz83qvldxh9cl15sTbsTssTssTaPgeWAHfGZ4WIfdtUGZW0LAbs9MCck(NuNDUuNHkeb2zijI3ihTb24n5ew8VKk9hk8K6KPRbmkNtxAOHnoPbtQStGDEMgjP(f64crj1pI(mmD4faFdoS4RHXBQfblEtiFj1zl1zOcrGDgwl8Mgap5oLLulqQ)i6ZW0Hu9KZyXWKlyXBc5lPoBPodvicSZWAH30a4j3PSKAbsTIs9rD2pyb4moSyXWKli7eyNNsTaP(JOpdthwaoJdlwmm5cw8Mq(sQhnxQB)PuRGcs9rD2pyb4moSyXWKli7eyNNsTaP(JOpdthwaoJdlwmm5cw8Mq(sQZwQZqfIa7mSw4nnaEYDklPwbfKAJvQpQZ(blaNXHflgMCbzNa78uQvsQfi1GawlKQNCg)nu1YW1rVWsD2sTHLAbs9KbbSw4faFdoS4RHXBQfbNHPNuP)qHNulAIi)WlrQeoDPHg2qKgmPYob25zAKK6xOJleLu)i6ZW0Hxa8n4WIVggVPweS4nH8LuNl1gi1cKAqaRfs1toJ)gQAz46OxyPE0CP2WsTaP(JOpdths1toJfdtUGfVjKVK6rZL62FMuP)qHNulAIi)WlrQeoDPHgwOKgmPYob25zAKK6xOJleLu)i6ZW0Hu9KZyXWKlyXBc5lPoxQnqQfi1kk1kk1gRuFuN9dYEh12CSZti7eyNNsTcki1kk1h1z)GS3rTnh78eYob25PulqQ3KtqX)K6SZLAdHbsTssTssTaPwrPwrP(JOpdthEbW3Gdl(Ay8MArWI3eYxsD2sDgQqeyNHKiEtdGNCNYsQfi1GawlKQNCg)nu1YW1rVWsDUudcyTqQEYz83qvld30a41rVWsTssTcki1kk1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZLAdKAbsniG1cP6jNXFdvTmCD0lSuNl1gi1kj1kj1cKAqaRfwaoJdlwmm5codtxQfi1BYjO4FsD25sDgQqeyNHKiEJC0gyJ3KtyX)KALsQ0FOWtQfnrKF4LivcNU0qdleMgmPYob25zAKK6xOJleLubbSwivp5m(BOQLHRJEHL6rZLAdl1cK6J6SFWcWzCyXIHjxq2jWopLAbs9hrFgMoSaCghwSyyYfS4nH8LupAUu3(tPwGu)r0NHPdP6jNXIHjxWI3eYxsD2sDgQqeyNHxCB8Mgap5oLLulqQ)id7KFqHZQqKl1cK6pI(mmDyrte5hEjsLWWI3eYxs9O5sTqjPs)HcpPEbW3Gdl(Ay8MArPlnKHninysLDcSZZ0ij1VqhxikPccyTqQEYz83qvldxh9cl1JMl1gwQfi1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDyb4moSyXWKlyXBc5lPE0CPU9NsTaP(JOpdths1toJfdtUGfVjKVK6SL6muHiWodV424nnaEYDklPwGuBSs9hzyN8dkCwfI8Kk9hk8K6faFdoS4RHXBQfLU0qgE40Gjv2jWoptJKu)cDCHOKkiG1cP6jNXFdvTmCD0lSupAUuByPwGuBSs9rD2pyb4moSyXWKli7eyNNsTaP(JOpdths1toJfdtUGfVjKVK6SL6muHiWodV424nnaEYDkRKk9hk8K6faFdoS4RHXBQfLU0qg2WPbtQStGDEMgjP(f64crjvqaRfs1toJ)gQAz46OxyPE0CP2WsTaP(JOpdths1toJfdtUGfVjKVK6rZL62FMuP)qHNuVa4BWHfFnmEtTO0LgYWgtAWKk7eyNNPrsQFHoUqusvrP2yL6J6SFq27O2MJDEczNa78uQvqbPwrP(Oo7hK9oQT5yNNq2jWopLAbs9MCck(NuNDUuBimqQvsQvsQfi1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZwQZqfIa7mKeXBAa8K7uwsTaPgeWAHu9KZ4VHQwgUo6fwQZLAqaRfs1toJ)gQAz4MgaVo6fwQfi1GawlSaCghwSyyYfCgMUulqQ3KtqX)K6SZL6muHiWodjr8g5OnWgVjNWI)LuP)qHNuP6jNXIHjxPlnKHnKPbtQStGDEMgjP(f64crjvqaRfwaoJdlwmm5codtxQfi1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZwQZqfIa7mScr8Mgap5oLLulqQbbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLAbsTIs9hrFgMoKQNCglgMCblEtiFj1zl1dlKsTcki1tgeWAHxa8n4WIVggVPweequQvkPs)HcpPwaoJdlwmm5kDPHmSqMgmPYob25zAKK6xOJleLubbSwivp5m(BOQLHRJEHL6CP2aPwGu)rg2j)GcNvHipPs)HcpPkw8I9NXHfVr(mDPHmSXjnysLDcSZZ0ij1VqhxikPozqaRfEbW3Gdl(Ay8MArqarPwGuBSs9hzyN8dkCwfI8Kk9hk8KQyXl2Fghw8g5Z0LgYWgI0Gjv2jWoptJKu)cDCHOK6hrFgMoKZepDOWHfVjKVK6SLAdKAbsTIsTIs9rD2pi7DuBZXopHStGDEk1cK6n5eu8pPE0CPwOyGulqQ3KtqX)K6SZLAJJqk1kj1kOGuROuBSs9rD2pi7DuBZXopHStGDEk1cK6n5eu8pPE0CPwOiKsTssTsjv6pu4j1n5eUL3PlDjvk40GPHgonysLDcSZZ0ij1VqhxikPQOuFuN9dYEh12CSZti7eyNNsTaPEtobf)tQhnxQfkgi1cK6n5eu8pPo7CP24iKsTssTcki1kk1gRuFuN9dYEh12CSZti7eyNNsTaPEtobf)tQhnxQfkcPuRusL(dfEsDtoHB5D6sdz40Gjv2jWoptJKu)cDCHOKkiG1cP6jNXIHjxWzy6jv6pu4j1oQT5wyH4aZ2n7x6sdzmPbtQStGDEMgjP(f64crjvqaRfs1toJfdtUGZW0tQ0FOWtQGuloS4RqVWR0LgYqMgmPYob25zAKK6xOJleLubbSwivp5mwmm5cciMuP)qHNubwmgD8ELU0qczAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsfKRfxcJ820LgY4KgmPYob25zAKK6xOJleLubbSwivp5mwmm5cciMuP)qHNub7rmXwGkR0LgYqKgmPYob25zAKK6xOJleLubbSwivp5mwmm5cciMuP)qHNuTOIb7rmtxAiHsAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKliGysL(dfEsL8NxxrD8t9E6sdjeMgmPYob25zAKK6xOJleLulaNTr1YWJ3IrrDSjvIq2qbqII8mPs)HcpPEOnJnPsmDPHg2G0Gjv2jWoptJKu)cDCHOKAb4SnQwgorRhj2rovzH)yVjFczdfajkYtPwGu)r0NHPdbbSw8eTEKyh5uLf(J9M8jSyAMLulqQbbSw4eTEKyh5uLf(J9M8j2wX6GZW0LAbsTIsniG1cP6jNXIHjxWzy6sTaPgeWAHfGZ4WIfdtUGZW0LAbs9KbbSw4faFdoS4RHXBQfbNHPl1kj1cK6pI(mmD4faFdoS4RHXBQfblEtiFj15sTbsTaPwrPgeWAHu9KZ4VHQwgUo6fwQhnxQZqfIa7mKcgFXTXFdvT8sQfi1kk1kk1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDyb4moSyXWKlyXBc5lPE0CPU9NsTaP(JOpdths1toJfdtUGfVjKVK6SL6muHiWodV424nnaEYDklPwjPwbfKAfLAJvQpQZ(blaNXHflgMCbzNa78uQfi1Fe9zy6qQEYzSyyYfS4nH8LuNTuNHkeb2z4f3gVPbWtUtzj1kj1kOGu)r0NHPdP6jNXIHjxWI3eYxs9O5sD7pLALKALsQ0FOWtQ2kwhy0V0LgA4HtdMuzNa78mnss9l0XfIsQkk1fGZ2OAz4eTEKyh5uLf(J9M8jKnuaKOipLAbs9hrFgMoeeWAXt06rIDKtvw4p2BYNWIPzwsTaPgeWAHt06rIDKtvw4p2BYNylQy4mmDPwGulwCgC7pHddTvSoWOFsTssTcki1kk1fGZ2OAz4eTEKyh5uLf(J9M8jKnuaKOipLAbs9H2SuNl1gi1kLuP)qHNuTOIXGDADPln0WgonysLDcSZZ0ij1VqhxikPwaoBJQLHTfA1ZcJE03ziBOairrEk1cK6pI(mmDivp5mwmm5cw8Mq(sQZwQngdKAbs9hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGuROudcyTqQEYz83qvldxh9cl1JMl1zOcrGDgsbJV424VHQwEj1cKAfLAfL6J6SFWcWzCyXIHjxq2jWopLAbs9hrFgMoSaCghwSyyYfS4nH8LupAUu3(tPwGu)r0NHPdP6jNXIHjxWI3eYxsD2sDgQqeyNHxCB8Mgap5oLLuRKuRGcsTIsTXk1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDivp5mwmm5cw8Mq(sQZwQZqfIa7m8IBJ30a4j3PSKALKAfuqQ)i6ZW0Hu9KZyXWKlyXBc5lPE0CPU9NsTssTsjv6pu4jvBfRd7rgkDPHg2ysdMuzNa78mnss9l0XfIsQfGZ2OAzyBHw9SWOh9DgYgkasuKNsTaP(JOpdths1toJfdtUGfVjKVK6CP2aPwGuROuROuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoBPodvicSZqseVPbWtUtzj1cKAqaRfs1toJ)gQAz46OxyPoxQbbSwivp5m(BOQLHBAa86OxyPwjPwbfKAfL6pI(mmD4faFdoS4RHXBQfblEtiFj15sTbsTaPgeWAHu9KZ4VHQwgUo6fwQhnxQZqfIa7mKcgFXTXFdvT8sQvsQvsQfi1GawlSaCghwSyyYfCgMUuRusL(dfEs1wX6WEKHsxAOHnKPbtQStGDEMgjP(f64crj1cWzBuTmCHeBchVUO2q2qbqII8uQfi1IfNb3(t4Wqot80HcpPs)HcpPEbW3Gdl(Ay8MArPln0WczAWKk7eyNNPrsQFHoUqusTaC2gvldxiXMWXRlQnKnuaKOipLAbsTIsTyXzWT)eomKZepDOWLAfuqQflodU9NWHHxa8n4WIVggVPwKuRusL(dfEsLQNCglgMCLU0qdBCsdMuzNa78mnss9l0XfIsQhAZsD2sTXyGulqQlaNTr1YWfsSjC86IAdzdfajkYtPwGudcyTqQEYz83qvldxh9cl1JMl1zOcrGDgsbJV424VHQwEj1cK6pI(mmD4faFdoS4RHXBQfblEtiFj15sTbsTaP(JOpdths1toJfdtUGfVjKVK6rZL62FMuP)qHNu5mXthk80LgAydrAWKk7eyNNPrsQ0FOWtQCM4PdfEsf5hxfG4Hr2KkiG1cxiXMWXRlQnCD0lCoiG1cxiXMWXRlQnCtdGxh9cNur(XvbiEy0EZteDCsD4K6xOJleLup0ML6SLAJXaPwGuxaoBJQLHlKyt441f1gYgkasuKNsTaP(JOpdths1toJfdtUGfVjKVK6CP2aPwGuROuROuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoBPodvicSZqseVPbWtUtzj1cKAqaRfs1toJ)gQAz46OxyPoxQbbSwivp5m(BOQLHBAa86OxyPwjPwbfKAfL6pI(mmD4faFdoS4RHXBQfblEtiFj15sTbsTaPgeWAHu9KZ4VHQwgUo6fwQhnxQZqfIa7mKcgFXTXFdvT8sQvsQvsQfi1GawlSaCghwSyyYfCgMUuRu6sdnSqjnysLDcSZZ0ij1VqhxikPQOu)r0NHPdP6jNXIHjxWI3eYxsD2sTHuiLAfuqQ)i6ZW0Hu9KZyXWKlyXBc5lPE0CP2yKALKAbs9hrFgMo8cGVbhw81W4n1IGfVjKVK6CP2aPwGuROudcyTqQEYz83qvldxh9cl1JMl1zOcrGDgsbJV424VHQwEj1cKAfLAfL6J6SFWcWzCyXIHjxq2jWopLAbs9hrFgMoSaCghwSyyYfS4nH8LupAUu3(tPwGu)r0NHPdP6jNXIHjxWI3eYxsD2sTqk1kj1kOGuROuBSs9rD2pyb4moSyXWKli7eyNNsTaP(JOpdths1toJfdtUGfVjKVK6SLAHuQvsQvqbP(JOpdths1toJfdtUGfVjKVK6rZL62Fk1kj1kLuP)qHNu3OQIAHdl(IAZ(LU0qdleMgmPYob25zAKK6xOJleLu)i6ZW0Hxa8n4WIVggVPweS4nH8LuNTuNHkeb2zyTWBAa8K7uwsTaP(JOpdths1toJfdtUGfVjKVK6SL6muHiWodRfEtdGNCNYsQfi1kk1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDyb4moSyXWKlyXBc5lPE0CPU9NsTcki1h1z)GfGZ4WIfdtUGStGDEk1cK6pI(mmDyb4moSyXWKlyXBc5lPoBPodvicSZWAH30a4j3PSKAfuqQnwP(Oo7hSaCghwSyyYfKDcSZtPwjPwGudcyTqQEYz83qvldxh9cl1JMl1zOcrGDgsbJV424VHQwEj1cK6jdcyTWla(gCyXxdJ3ulcodtpPs)HcpPw0er(HxIujC6sdzydsdMuzNa78mnss9l0XfIsQFe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZLAdKAbsTIsniG1cP6jNXFdvTmCD0lSupAUuNHkeb2zifm(IBJ)gQA5LulqQvuQvuQpQZ(blaNXHflgMCbzNa78uQfi1Fe9zy6WcWzCyXIHjxWI3eYxs9O5sD7pLAbs9hrFgMoKQNCglgMCblEtiFj1zl1zOcrGDgEXTXBAa8K7uwsTssTcki1kk1gRuFuN9dwaoJdlwmm5cYob25PulqQ)i6ZW0Hu9KZyXWKlyXBc5lPoBPodvicSZWlUnEtdGNCNYsQvsQvqbP(JOpdths1toJfdtUGfVjKVK6rZL62Fk1kj1kLuP)qHNulAIi)WlrQeoDPHm8WPbtQStGDEMgjP(f64crj1pI(mmDivp5mwmm5cw8Mq(sQZLAdKAbsTIsTIsTIs9hrFgMo8cGVbhw81W4n1IGfVjKVK6SL6muHiWodjr8Mgap5oLLulqQbbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLALKAfuqQvuQ)i6ZW0Hxa8n4WIVggVPweS4nH8LuNl1gi1cKAqaRfs1toJ)gQAz46OxyPE0CPodvicSZqky8f3g)nu1YlPwjPwjPwGudcyTWcWzCyXIHjxWzy6sTsjv6pu4j1IMiYp8sKkHtxAidB40Gjv2jWoptJKu)cDCHOK6hrFgMoKQNCglgMCblEtiFj15sTbsTaPwrPwrPwrP(JOpdthEbW3Gdl(Ay8MArWI3eYxsD2sDgQqeyNHKiEtdGNCNYsQfi1GawlKQNCg)nu1YW1rVWsDUudcyTqQEYz83qvld30a41rVWsTssTcki1kk1Fe9zy6Wla(gCyXxdJ3ulcw8Mq(sQZLAdKAbsniG1cP6jNXFdvTmCD0lSupAUuNHkeb2zifm(IBJ)gQA5LuRKuRKulqQbbSwyb4moSyXWKl4mmDPwPKk9hk8K6KPRbmkNtxAidBmPbtQStGDEMgjP(f64crjvqaRfs1toJ)gQAz46OxyPE0CPodvicSZqky8f3g)nu1YlPwGuROuROuFuN9dwaoJdlwmm5cYob25PulqQ)i6ZW0HfGZ4WIfdtUGfVjKVK6rZL62Fk1cK6pI(mmDivp5mwmm5cw8Mq(sQZwQZqfIa7m8IBJ30a4j3PSKALKAfuqQvuQnwP(Oo7hSaCghwSyyYfKDcSZtPwGu)r0NHPdP6jNXIHjxWI3eYxsD2sDgQqeyNHxCB8Mgap5oLLuRKuRGcs9hrFgMoKQNCglgMCblEtiFj1JMl1T)uQvkPs)HcpPEbW3Gdl(Ay8MArPlnKHnKPbtQStGDEMgjP(f64crjvfLAfL6pI(mmD4faFdoS4RHXBQfblEtiFj1zl1zOcrGDgsI4nnaEYDklPwGudcyTqQEYz83qvldxh9cl15sniG1cP6jNXFdvTmCtdGxh9cl1kj1kOGuROu)r0NHPdVa4BWHfFnmEtTiyXBc5lPoxQnqQfi1GawlKQNCg)nu1YW1rVWs9O5sDgQqeyNHuW4lUn(BOQLxsTssTssTaPgeWAHfGZ4WIfdtUGZW0tQ0FOWtQu9KZyXWKR0LgYWczAWKk7eyNNPrsQFHoUqusfeWAHfGZ4WIfdtUGZW0LAbsTIsTIs9hrFgMo8cGVbhw81W4n1IGfVjKVK6SLAdBGulqQbbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLALKAfuqQvuQ)i6ZW0Hxa8n4WIVggVPweS4nH8LuNl1gi1cKAqaRfs1toJ)gQAz46OxyPE0CPodvicSZqky8f3g)nu1YlPwjPwjPwGuROu)r0NHPdP6jNXIHjxWI3eYxsD2s9WcPuRGcs9KbbSw4faFdoS4RHXBQfbbeLALsQ0FOWtQfGZ4WIfdtUsxAidBCsdMuzNa78mnss9l0XfIsQGawlCY01agLZqarPwGupzqaRfEbW3Gdl(Ay8MArqarPwGupzqaRfEbW3Gdl(Ay8MArWI3eYxs9O5sniG1cflEX(Z4WI3iFc30a41rVWsTqBPM(dfoKQNCgd2P1b5b4h4y8H2CsL(dfEsvS4f7pJdlEJ8z6sdzydrAWKk7eyNNPrsQFHoUqusfeWAHtMUgWOCgcik1cKAfLAfL6J6SFWIxHt(Zq2jWopLAbsn9hkdJzN3iEj1Jk1gsPwjPwbfKA6puggZoVr8sQhvQfsPwPKk9hk8Kkvp5mgStRlDPHmSqjnysL(dfEsDbiYLhzOKk7eyNNPrsxAidleMgmPYob25zAKK6xOJleLubbSwivp5m(BOQLHRJEHL6CP2GKk9hk8Kkvp5mokW0LgYyminysLDcSZZ0ij1VqhxikPQOuxST4vdb2zPwbfKAJvQp0lmYBLALKAbsniG1cP6jNXFdvTmCD0lSuNl1GawlKQNCg)nu1YWnnaED0lCsL(dfEs15RHl8XBrEDPlnKXmCAWKk7eyNNPrsQFHoUqusfeWAHu9KZyXWKl4mmDPwGudcyTWcWzCyXIHjxWzy6sTaPEYGawl8cGVbhw81W4n1IGZW0LAbs9hrFgMoKQNCglgMCblEtiFj1zl1gi1cK6pI(mmD4faFdoS4RHXBQfblEtiFj1zl1gi1cKAfLAJvQpQZ(blaNXHflgMCbzNa78uQvqbPwrP(Oo7hSaCghwSyyYfKDcSZtPwGu)r0NHPdlaNXHflgMCblEtiFj1zl1gi1kj1kLuP)qHNuxni7H8wSyyYv6sdzmgonysLDcSZZ0ij1VqhxikPccyTWVZu906qElSy6pPwGuxaoBJQLHu9KZyKBro6YcYgkasuKNsTaP(Oo7hK2IDKf90HchYob25PulqQP)qzym78gXlPEuP24KuP)qHNuP6jNXB0AH68kDPHmgJjnysLDcSZZ0ij1VqhxikPccyTWVZu906qElSy6pPwGuxaoBJQLHu9KZyKBro6YcYgkasuKNsTaPM(dLHXSZBeVK6rLAdzsL(dfEsLQNCgVrRfQZR0LgYymKPbtQStGDEMgjP(f64crjvqaRfs1toJ)gQAz46OxyPEuPgeWAHu9KZ4VHQwgUPbWRJEHtQ0FOWtQu9KZyEaXESqHNU0qgJqMgmPYob25zAKK6xOJleLubbSwivp5m(BOQLHRJEHL6CPgeWAHu9KZ4VHQwgUPbWRJEHLAbsTyXzWT)eomKQNCgdsvrTCsL(dfEsLQNCgZdi2Jfk80LgYymoPbtQStGDEMgjP(f64crjvqaRfs1toJ)gQAz46OxyPoxQbbSwivp5m(BOQLHBAa86Ox4Kk9hk8Kkvp5mgKQIA50LgYymePbtQi)4QaepmYMu3KtqX)YoxOiKjvKFCvaIhgT38erhNuhoPs)HcpPYzINou4jv2jWoptJKU0Lu3rgEZ(Lgmn0WPbtQStGDEMgjP(f64crj1DKH3SFWjADK)SuNDUupSbjv6pu4jvWoYfoDPHmCAWKk9hk8KQyXl2Fghw8g5ZKk7eyNNPrsxAiJjnysLDcSZZ0ij1VqhxikPUJm8M9dorRJ8NL6rL6HniPs)HcpPs1toJ3O1c15v6sdzitdMuP)qHNuP6jNXrbMuzNa78mns6sdjKPbtQ0FOWtQwuXyWoTUKk7eyNNPrsx6sQwKtDmiq5PbtdnCAWKk7eyNNPrsQ0FOWtQu9KZ4nATqDELu)gc5j1HtQFHoUqusfeWAHFNP6P1H8wyX0FPlnKHtdMuP)qHNuP6jNXGDADjv2jWoptJKU0qgtAWKk9hk8Kkvp5mgKQIA5Kk7eyNNPrsx6sxsndxlu4PHmSbg2GHnyyddhoPAsLJ82vsviic9c1gsO5qcbvisQL6bByPgTfJ6KABusTXxXrhkCJxQl2qbqfpL6vSzPMaUythpL6VH8wEbLgj0HCwQhwisQfceEgUoEk1QOTqaPELLF0asTq9L6lKAHoasQNOmOfkCPoe5IUOKAfhtjPwXHhqjO0iHoKZsTqkej1cbcpdxhpLAJ)JmSt(bfQGStGDEA8s9fsTX)rg2j)GcvgVuR4WdOeuAK0iHGi0luBiHMdjeuHiPwQhSHLA0wmQtQTrj1gVyXFSbPZ4L6InuauXtPEfBwQjGl20XtP(BiVLxqPrcDiNLAJrisQfceEgUoEk1g)hzyN8dkubzNa7804L6lKAJ)JmSt(bfQmEPwXHhqjO0iHoKZsTHuisQfceEgUoEk1g)hzyN8dkubzNa7804L6lKAJ)JmSt(bfQmEPwXHhqjO0iHoKZs9Wdlej1cbcpdxhpLAJ)JmSt(bfQGStGDEA8s9fsTX)rg2j)GcvgVuR4WdOeuAKqhYzPEyHuisQfceEgUoEk1g)hzyN8dkubzNa7804L6lKAJ)JmSt(bfQmEPwXHhqjO0iPrcbrOxO2qcnhsiOcrsTupydl1OTyuNuBJsQn(pI(mm9LXl1fBOaOINs9k2SutaxSPJNs93qElVGsJe6qol1dlekej1cbcpdxhpLAJ)JmSt(bfQGStGDEA8s9fsTX)rg2j)GcvgVuR4WdOeuAKqhYzP2Wgiej1cbcpdxhpLAJ)JmSt(bfQGStGDEA8s9fsTX)rg2j)GcvgVuR4WdOeuAKqhYzP2WcPqKulei8mCD8uQn(pYWo5huOcYob25PXl1xi1g)hzyN8dkuz8sTIdpGsqPrcDiNLAdBCeIKAHaHNHRJNsTX)rg2j)Gcvq2jWopnEP(cP24)id7KFqHkJxQvC4bucknsAKqZTyuhpLAHqPM(dfUu3rRBbLgLufRWI6Cs14k1c1JAzPwOVEYzPrgxPwOH)cqUK6HngLLAdBGHnqAK0i6pu4lOyXFSbPlpdvicSZk70MZflweO3XCMq5qmFXNYzOoaNBG0i6pu4lOyXFSbPB88XYqfIa7SYoT5CXIfb6DmNjuoeZx8PCgQdW5dRmYMxaoBJQLHlKyt441f1gYgkasuKNcO)qzym78gXRSnS0i6pu4lOyXFSbPB88XYqfIa7SYoT5CXIfb6DmNjuoeZx8PCgQdW5dRmYMxaoBJQLHlKyt441f1gYgkasuKNc(id7KFqN)k6rnHStGDEkG(dLHXSZBeVYEyPr0FOWxqXI)yds345JLHkeb2zLDAZ5Iflc07yotOCiMV4t5muhGZhwzKnVaC2gvldxiXMWXRlQnKnuaKOipf8rg2j)GoQT5WwIHStGDEknY4k10FOWxqXI)yds345JLHkeb2zLDAZ5nugghISZtLdX8fFkNH6aCUbsJmUsn9hk8fuS4p2G0nE(yzOcrGDwzN2CEdLHXHi78u5qmFXNYzOoaNpSYiBo9hkdJzN3iELTHLgzCLA6pu4lOyXFSbPB88XYqfIa7SYoT58gkdJdr25PYHy(IpLZqDaoFyLr28muHiWodflweO3XCMiFyPr0FOWxqXI)yds345JLHkeb2zLDAZ5wKtDmiq5khI5l(uod1b4CdKgr)HcFbfl(JniDJNpwgQqeyNv2PnNxl8Mgap5oLLYHy(IpLZqDaoxiLgr)HcFbfl(JniDJNpwgQqeyNv2PnNtI4nnaEYDklLdX8fFkNH6aC(WginI(df(ckw8hBq6gpFSmuHiWoRStBoVcr8Mgap5oLLYHy(IpLZqDao3WginI(df(ckw8hBq6gpFSmuHiWoRStBo)IBJ30a4j3PSuoeZx8PCgQdW5cP0i6pu4lOyXFSbPB88XYqfIa7SYoT58lUnEtdGNCNYs5qmFXNYzOoaNBmkJS5fGZ2OAz4eTEKyh5uLf(J9M8jKnuaKOipLgr)HcFbfl(JniDJNpwgQqeyNv2PnNFXTXBAa8K7uwkhI5l(uod1b48HfsLr28pYWo5h0rTnh2smKDcSZtPr0FOWxqXI)yds345JLHkeb2zLDAZ5xCB8Mgap5oLLYHy(IpLZqDaoFyHuzKn)dFcGoivp5mwSIjQnli7eyNNcO)qzym78gXRrngPrgxPEeRqVuleSuluJ3rgwQf6OJlPr0FOWxqXI)yds345JLHkeb2zLDAZ5xCB8Mgap5oLLYHy(IpLZqDao3ymqzKnNxl2FgMbTqHJdlwKll)hkC4g5rjnI(df(ckw8hBq6gpFSmuHiWoRStBohKQIAz8MCcl(NYHy(IpLZqDaoxi0aPr0FOWxqXI)yds345JLHkeb2zLDAZ5GuvulJ3KtyX)uoeZx8PCgQdW5cfdugzZ)id7KFqh12CylXq2jWopLgr)HcFbfl(JniDJNpwgQqeyNv2PnNtI4nYrBGnEtoHf)t5qmFXNYzOoaNBmginI(df(ckw8hBq6gpFSmuHiWoRStBoNeXBKJ2aB8MCcl(NYHy(IpLZqDaoxinqzKnVaC2gvldNO1Je7iNQSWFS3KpHSHcGef5P0i6pu4lOyXFSbPB88XYqfIa7SYoT5CseVroAdSXBYjS4FkhI5l(uod1b4CH0aLr28cWzBuTmSTqREwy0J(odzdfajkYtPr0FOWxqXI)yds345JLHkeb2zLDAZ5uW4lUn(BOQLxkhI5l(uod1b4CdlnI(df(ckw8hBq6gpFmQEYzSL2OoIkPr0FOWxqXI)yds345Jr1toJr(X9o)N0i6pu4lOyXFSbPB88X(WfIdumEtoHB5T0i6pu4lOyXFSbPB88X2OQIcJ2ullnI(df(ckw8hBq6gpFmX4qHlnI(df(ckw8hBq6gpFmBfRdm6NYiBEgQqeyNHIflc07yotKBGGcWzBuTmCIwpsSJCQYc)XEt(eYgkasuKNc(i6ZW0HGawlEIwpsSJCQYc)XEt(ewmnZsaiG1cNO1Je7iNQSWFS3KpX2kwhCgMU0i6pu4lOyXFSbPB88X4mXthkCLr28muHiWodflweO3XCMiFyPrsJmUsTqDna)ahpLAodxzj1hAZs91Wsn9xusnAj1ugc1jWodLgr)HcFL)bGFCTe5ExzKn)OQLp4KbbSw4tRd5TWIP)KgzCL6rSc9sTqWsTqnEhzyPwOJoUKgr)HcFnE(yp17y6pu44oADk70MZ51I9NxsJO)qHVgpFSN6Dm9hkCChToLDAZ5uWkJS50FOmmMDEJ4v2gwAe9hk8145J9uVJP)qHJ7O1PStBopezNlLr28muHiWodBOmmoezNN5ginI(df(A88XEQ3X0FOWXD06u2PnN)r0NHPVKgr)HcFnE(yp17y6pu44oADk70MZR4OdfUYiBEgQqeyNHwKtDmiq55ginI(df(A88XEQ3X0FOWXD06u2PnNBro1XGaLRmYMNHkeb2zOf5uhdcuE(WsJO)qHVgpFSN6Dm9hkCChToLDAZ57idVz)KgjnI(df(csbNdSy8MCc3YBLr2CfpQZ(bzVJABo25jKDcSZtbBYjO4FJMlumqWMCck(x25ghHujfuqrJ9Oo7hK9oQT5yNNq2jWopfSjNGI)nAUqrivsAe9hk8fKcE88X6O2MBHfIdmB3SFkJS5GawlKQNCglgMCbNHPlnI(df(csbpE(yGuloS4RqVWlLr2CqaRfs1toJfdtUGZW0Lgr)HcFbPGhpFmGfJrhVxkJS5GawlKQNCglgMCbbeLgr)HcFbPGhpFmqUwCjmYBvgzZbbSwivp5mwmm5cciknI(df(csbpE(yG9iMylqLLYiBoiG1cP6jNXIHjxqarPr0FOWxqk4XZhZIkgShXuzKnheWAHu9KZyXWKliGO0i6pu4lif845Jr(ZRROo(PExzKnheWAHu9KZyXWKliGO0i6pu4lif845JDOnJnPsuzKnVaC2gvldpElgf1XMujczdfajkYtPr0FOWxqk4XZhZwX6aJ(PmYMxaoBJQLHt06rIDKtvw4p2BYNq2qbqII8uWhrFgMoeeWAXt06rIDKtvw4p2BYNWIPzwcabSw4eTEKyh5uLf(J9M8j2wX6GZW0fOiiG1cP6jNXIHjxWzy6cabSwyb4moSyXWKl4mmDbtgeWAHxa8n4WIVggVPweCgMUsc(i6ZW0Hxa8n4WIVggVPweS4nH8vUbcueeWAHu9KZ4VHQwgUo6fE08muHiWodPGXxCB83qvlVeOOIh1z)GfGZ4WIfdtUGStGDEk4JOpdthwaoJdlwmm5cw8Mq(A082Fk4JOpdths1toJfdtUGfVjKVYodvicSZWlUnEtdGNCNYsjfuqrJ9Oo7hSaCghwSyyYfKDcSZtbFe9zy6qQEYzSyyYfS4nH8v2zOcrGDgEXTXBAa8K7uwkPGcFe9zy6qQEYzSyyYfS4nH81O5T)ujLKgr)HcFbPGhpFmlQymyNwNYiBUIfGZ2OAz4eTEKyh5uLf(J9M8jKnuaKOipf8r0NHPdbbSw8eTEKyh5uLf(J9M8jSyAMLaqaRforRhj2rovzH)yVjFITOIHZW0fiwCgC7pHddTvSoWOFkPGckwaoBJQLHt06rIDKtvw4p2BYNq2qbqII8uWH2CUbkjnI(df(csbpE(y2kwh2JmKYiBEb4SnQwg2wOvplm6rFNHSHcGef5PGpI(mmDivp5mwmm5cw8Mq(kBJXabFe9zy6Wla(gCyXxdJ3ulcw8Mq(k3abkccyTqQEYz83qvldxh9cpAEgQqeyNHuW4lUn(BOQLxcuuXJ6SFWcWzCyXIHjxq2jWopf8r0NHPdlaNXHflgMCblEtiFnAE7pf8r0NHPdP6jNXIHjxWI3eYxzNHkeb2z4f3gVPbWtUtzPKckOOXEuN9dwaoJdlwmm5cYob25PGpI(mmDivp5mwmm5cw8Mq(k7muHiWodV424nnaEYDklLuqHpI(mmDivp5mwmm5cw8Mq(A082FQKssJO)qHVGuWJNpMTI1H9idPmYMxaoBJQLHTfA1ZcJE03ziBOairrEk4JOpdths1toJfdtUGfVjKVYnqGIkQ4hrFgMo8cGVbhw81W4n1IGfVjKVYodvicSZqseVPbWtUtzjaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHvsbfu8JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fE08muHiWodPGXxCB83qvlVusjbGawlSaCghwSyyYfCgMUssJmUs9GcniuNcniej1cb6m5snGOuFn8ILAvvPMZesDh58sAe9hk8fKcE88XUa4BWHfFnmEtTiLr28cWzBuTmCHeBchVUO2q2qbqII8uGyXzWT)eomKZepDOWLgr)HcFbPGhpFmQEYzSyyYLYiBEb4SnQwgUqInHJxxuBiBOairrEkqrXIZGB)jCyiNjE6qHRGcIfNb3(t4WWla(gCyXxdJ3ulsjPr0FOWxqk4XZhJZepDOWvgzZp0MZ2ymqqb4SnQwgUqInHJxxuBiBOairrEkaeWAHu9KZ4VHQwgUo6fE08muHiWodPGXxCB83qvlVe8r0NHPdVa4BWHfFnmEtTiyXBc5RCde8r0NHPdP6jNXIHjxWI3eYxJM3(tPr0FOWxqk4XZhJZepDOWvgzZp0MZ2ymqqb4SnQwgUqInHJxxuBiBOairrEk4JOpdths1toJfdtUGfVjKVYnqGIkQ4hrFgMo8cGVbhw81W4n1IGfVjKVYodvicSZqseVPbWtUtzjaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHvsbfu8JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fE08muHiWodPGXxCB83qvlVusjbGawlSaCghwSyyYfCgMUskJ8JRcq8WiBoiG1cxiXMWXRlQnCD0lCoiG1cxiXMWXRlQnCtdGxh9cRmYpUkaXdJ2BEIOJZhwAe9hk8fKcE88X2OQIAHdl(IAZ(PmYMR4hrFgMoKQNCglgMCblEtiFLTHuivqHpI(mmDivp5mwmm5cw8Mq(A0CJrjbFe9zy6Wla(gCyXxdJ3ulcw8Mq(k3abkccyTqQEYz83qvldxh9cpAEgQqeyNHuW4lUn(BOQLxcuuXJ6SFWcWzCyXIHjxq2jWopf8r0NHPdlaNXHflgMCblEtiFnAE7pf8r0NHPdP6jNXIHjxWI3eYxzlKkPGckASh1z)GfGZ4WIfdtUGStGDEk4JOpdths1toJfdtUGfVjKVYwivsbf(i6ZW0Hu9KZyXWKlyXBc5RrZB)PskjnI(df(csbpE(yfnrKF4LivcRmYM)r0NHPdVa4BWHfFnmEtTiyXBc5RSZqfIa7mSw4nnaEYDklbFe9zy6qQEYzSyyYfS4nH8v2zOcrGDgwl8Mgap5oLLafpQZ(blaNXHflgMCbzNa78uWhrFgMoSaCghwSyyYfS4nH81O5T)ubfoQZ(blaNXHflgMCbzNa78uWhrFgMoSaCghwSyyYfS4nH8v2zOcrGDgwl8Mgap5oLLckySh1z)GfGZ4WIfdtUGStGDEQKaqaRfs1toJ)gQAz46Ox4rZZqfIa7mKcgFXTXFdvT8sWKbbSw4faFdoS4RHXBQfbNHPlnI(df(csbpE(yfnrKF4LivcRmYM)r0NHPdVa4BWHfFnmEtTiyXBc5RCdeOiiG1cP6jNXFdvTmCD0l8O5zOcrGDgsbJV424VHQwEjqrfpQZ(blaNXHflgMCbzNa78uWhrFgMoSaCghwSyyYfS4nH81O5T)uWhrFgMoKQNCglgMCblEtiFLDgQqeyNHxCB8Mgap5oLLskOGIg7rD2pyb4moSyXWKli7eyNNc(i6ZW0Hu9KZyXWKlyXBc5RSZqfIa7m8IBJ30a4j3PSusbf(i6ZW0Hu9KZyXWKlyXBc5RrZB)PskjnI(df(csbpE(yfnrKF4LivcRmYM)r0NHPdP6jNXIHjxWI3eYx5giqrfv8JOpdthEbW3Gdl(Ay8MArWI3eYxzNHkeb2zijI30a4j3PSeacyTqQEYz83qvldxh9cNdcyTqQEYz83qvld30a41rVWkPGck(r0NHPdVa4BWHfFnmEtTiyXBc5RCdeacyTqQEYz83qvldxh9cpAEgQqeyNHuW4lUn(BOQLxkPKaqaRfwaoJdlwmm5codtxjPr0FOWxqk4XZhBY01agLZkJS5Fe9zy6qQEYzSyyYfS4nH8vUbcuurf)i6ZW0Hxa8n4WIVggVPweS4nH8v2zOcrGDgsI4nnaEYDklbGawlKQNCg)nu1YW1rVW5GawlKQNCg)nu1YWnnaED0lSskOGIFe9zy6Wla(gCyXxdJ3ulcw8Mq(k3abGawlKQNCg)nu1YW1rVWJMNHkeb2zifm(IBJ)gQA5LskjaeWAHfGZ4WIfdtUGZW0vsAe9hk8fKcE88XUa4BWHfFnmEtTiLr2CqaRfs1toJ)gQAz46Ox4rZZqfIa7mKcgFXTXFdvT8sGIkEuN9dwaoJdlwmm5cYob25PGpI(mmDyb4moSyXWKlyXBc5RrZB)PGpI(mmDivp5mwmm5cw8Mq(k7muHiWodV424nnaEYDklLuqbfn2J6SFWcWzCyXIHjxq2jWopf8r0NHPdP6jNXIHjxWI3eYxzNHkeb2z4f3gVPbWtUtzPKck8r0NHPdP6jNXIHjxWI3eYxJM3(tLKgr)HcFbPGhpFmQEYzSyyYLYiBUIk(r0NHPdVa4BWHfFnmEtTiyXBc5RSZqfIa7mKeXBAa8K7uwcabSwivp5m(BOQLHRJEHZbbSwivp5m(BOQLHBAa86OxyLuqbf)i6ZW0Hxa8n4WIVggVPweS4nH8vUbcabSwivp5m(BOQLHRJEHhnpdvicSZqky8f3g)nu1YlLusaiG1claNXHflgMCbNHPlnI(df(csbpE(yfGZ4WIfdtUugzZbbSwyb4moSyXWKl4mmDbkQ4hrFgMo8cGVbhw81W4n1IGfVjKVY2WgiaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHvsbfu8JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fE08muHiWodPGXxCB83qvlVusjbk(r0NHPdP6jNXIHjxWI3eYxzpSqQGctgeWAHxa8n4WIVggVPweequjPr0FOWxqk4XZhtS4f7pJdlEJ8PYiBoiG1cNmDnGr5mequWKbbSw4faFdoS4RHXBQfbbefmzqaRfEbW3Gdl(Ay8MArWI3eYxJMdcyTqXIxS)moS4nYNWnnaED0lSqB6pu4qQEYzmyNwhKhGFGJXhAZsJO)qHVGuWJNpgvp5mgStRtzKnheWAHtMUgWOCgcikqrfpQZ(blEfo5pdzNa78ua9hkdJzN3iEnQHujfuG(dLHXSZBeVgvivsAe9hk8fKcE88XwaIC5rgsAe9hk8fKcE88XO6jNXrbQmYMdcyTqQEYz83qvldxh9cNBG0i6pu4lif845J581Wf(4TiVoLr2Cfl2w8QHa7SckySh6fg5TkjaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHLgr)HcFbPGhpFSvdYEiVflgMCPmYMdcyTqQEYzSyyYfCgMUaqaRfwaoJdlwmm5codtxWKbbSw4faFdoS4RHXBQfbNHPl4JOpdths1toJfdtUGfVjKVY2abFe9zy6Wla(gCyXxdJ3ulcw8Mq(kBdeOOXEuN9dwaoJdlwmm5cYob25PckO4rD2pyb4moSyXWKli7eyNNc(i6ZW0HfGZ4WIfdtUGfVjKVY2aLusAe9hk8fKcE88XO6jNXB0AH68szKnheWAHFNP6P1H8wyX0FckaNTr1YqQEYzmYTihDzbzdfajkYtbh1z)G0wSJSONou4q2jWopfq)HYWy25nIxJACKgr)HcFbPGhpFmQEYz8gTwOoVugzZbbSw43zQEADiVfwm9NGcWzBuTmKQNCgJClYrxwq2qbqII8ua9hkdJzN3iEnQHuAe9hk8fKcE88XO6jNX8aI9yHcxzKnheWAHu9KZ4VHQwgUo6fEuqaRfs1toJ)gQAz4MgaVo6fwAe9hk8fKcE88XO6jNX8aI9yHcxzKnheWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHfiwCgC7pHddP6jNXGuvullnI(df(csbpE(yu9KZyqQkQLvgzZbbSwivp5m(BOQLHRJEHZbbSwivp5m(BOQLHBAa86OxyPr0FOWxqk4XZhJZepDOWvg5hxfG4Hr28n5eu8VSZfkcPYi)4QaepmAV5jIooFyPrsJO)qHVGFe9zy6R8oQT5wyH4aZ2n7NYiBoiG1cP6jNXIHjxWzy6cabSwyb4moSyXWKl4mmDbtgeWAHxa8n4WIVggVPweCgMU0i6pu4l4hrFgM(A88XaPwCyXxHEHxkJS5GawlKQNCglgMCbNHPlaeWAHfGZ4WIfdtUGZW0fmzqaRfEbW3Gdl(Ay8MArWzy6sJO)qHVGFe9zy6RXZhdyXy0X7LYiBoiG1cP6jNXIHjxqarPr0FOWxWpI(mm9145JbY1IlHrERYiBoiG1cP6jNXIHjxqarPr0FOWxWpI(mm9145Jb2JyITavwkJS5GawlKQNCglgMCbbeLgr)HcFb)i6ZW0xJNpMfvmypIPYiBoiG1cP6jNXIHjxqarPr0FOWxWpI(mm9145Jr(ZRROo(PExzKnheWAHu9KZyXWKliGO0iJRuluhfkk0HeIXsnWc5TsDBHw9SKA0J(ol1MORrQjrOul0AXsn6KAt01i1xCBPoUgUmrlgk1sJO)qHVGFe9zy6RXZhZwX6WEKHugzZlaNTr1YW2cT6zHrp67mKnuaKOipf8r0NHPdP6jNXIHjxWI3eYxzBmgi4JOpdthEbW3Gdl(Ay8MArWI3eYx5giqrqaRfs1toJ)gQAz46Ox4rZnSafv8Oo7hSaCghwSyyYfKDcSZtbFe9zy6WcWzCyXIHjxWI3eYxJM3(tbFe9zy6qQEYzSyyYfS4nH8v2zOcrGDgEXTXBAa8K7uwkPGckASh1z)GfGZ4WIfdtUGStGDEk4JOpdths1toJfdtUGfVjKVYodvicSZWlUnEtdGNCNYsjfu4JOpdths1toJfdtUGfVjKVgnV9NkPK0i6pu4l4hrFgM(A88XSvSoShziLr28cWzBuTmSTqREwy0J(odzdfajkYtbFe9zy6qQEYzSyyYfS4nH8vUbcu0ypQZ(bzVJABo25jKDcSZtfuqXJ6SFq27O2MJDEczNa78uWMCck(x25gcdusjbkQ4hrFgMo8cGVbhw81W4n1IGfVjKVYEydeacyTqQEYz83qvldxh9cNdcyTqQEYz83qvld30a41rVWkPGck(r0NHPdVa4BWHfFnmEtTiyXBc5RCdeacyTqQEYz83qvldxh9cNBGskjaeWAHfGZ4WIfdtUGZW0fSjNGI)LDEgQqeyNHKiEJC0gyJ3KtyX)Kgr)HcFb)i6ZW0xJNpMTI1bg9tzKnVaC2gvldNO1Je7iNQSWFS3KpHSHcGef5PGpI(mmDiiG1INO1Je7iNQSWFS3KpHftZSeacyTWjA9iXoYPkl8h7n5tSTI1bNHPlqrqaRfs1toJfdtUGZW0facyTWcWzCyXIHjxWzy6cMmiG1cVa4BWHfFnmEtTi4mmDLe8r0NHPdVa4BWHfFnmEtTiyXBc5RCdeOiiG1cP6jNXFdvTmCD0l8O5gwGIkEuN9dwaoJdlwmm5cYob25PGpI(mmDyb4moSyXWKlyXBc5RrZB)PGpI(mmDivp5mwmm5cw8Mq(k7muHiWodV424nnaEYDklLuqbfn2J6SFWcWzCyXIHjxq2jWopf8r0NHPdP6jNXIHjxWI3eYxzNHkeb2z4f3gVPbWtUtzPKck8r0NHPdP6jNXIHjxWI3eYxJM3(tLusAe9hk8f8JOpdtFnE(ywuXyWoToLr28cWzBuTmCIwpsSJCQYc)XEt(eYgkasuKNc(i6ZW0HGawlEIwpsSJCQYc)XEt(ewmnZsaiG1cNO1Je7iNQSWFS3KpXwuXWzy6celodU9NWHH2kwhy0pPrgxPwOVBszTKAGfl1BuvrTKAt01i1KiuQfAAL6lUTuJwsDX0mlPMwsTj37kl1BsywQxafl1xi1pToPgDsniBJIL6lUnuAe9hk8f8JOpdtFnE(yBuvrTWHfFrTz)ugzZ)i6ZW0Hxa8n4WIVggVPweS4nH8vUbcabSwivp5m(BOQLHRJEHhn3Wc(i6ZW0Hu9KZyXWKlyXBc5RrZB)P0i6pu4l4hrFgM(A88X2OQIAHdl(IAZ(PmYM)r0NHPdP6jNXIHjxWI3eYx5giqrJ9Oo7hK9oQT5yNNq2jWopvqbfpQZ(bzVJABo25jKDcSZtbBYjO4FzNBimqjLeOOIFe9zy6Wla(gCyXxdJ3ulcw8Mq(k7muHiWodjr8Mgap5oLLaqaRfs1toJ)gQAz46Ox4CqaRfs1toJ)gQAz4MgaVo6fwjfuqXpI(mmD4faFdoS4RHXBQfblEtiFLBGaqaRfs1toJ)gQAz46Ox4CdusjbGawlSaCghwSyyYfCgMUGn5eu8VSZZqfIa7mKeXBKJ2aB8MCcl(N0iJRul03nPSwsnWIL6jtxdyuol1MORrQjrOul00k1xCBPgTK6IPzwsnTKAtU3vwQ3KWSuVakwQVqQFADsn6KAq2gfl1xCBO0i6pu4l4hrFgM(A88XMmDnGr5SYiB(hrFgMo8cGVbhw81W4n1IGfVjKVYnqaiG1cP6jNXFdvTmCD0l8O5gwWhrFgMoKQNCglgMCblEtiFnAE7pLgr)HcFb)i6ZW0xJNp2KPRbmkNvgzZ)i6ZW0Hu9KZyXWKlyXBc5RCdeOOXEuN9dYEh12CSZti7eyNNkOGIh1z)GS3rTnh78eYob25PGn5eu8VSZnegOKscuuXpI(mmD4faFdoS4RHXBQfblEtiFL9WgiaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHvsbfu8JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fo3aLusaiG1claNXHflgMCbNHPlytobf)l78muHiWodjr8g5OnWgVjNWI)jnY4k1cTwSuVePsyPgzL6lUTut(uQjrPMkwQdxQ)Put(uQnd34pPgKLAarP2gLu3dVLlP(AixQVgwQ30as9K7uwkl1BsyK3k1lGILAtwQBOmSutNu3zADs9zgsnvp5Su)nu1YlPM8PuFn0j1xCBP2KwUXFsTqCG1j1alEcLgr)HcFb)i6ZW0xJNpwrte5hEjsLWkJS5Fe9zy6Wla(gCyXxdJ3ulcw8Mq(k7muHiWodRfEtdGNCNYsWhrFgMoKQNCglgMCblEtiFLDgQqeyNH1cVPbWtUtzjqXJ6SFWcWzCyXIHjxq2jWopf8r0NHPdlaNXHflgMCblEtiFnAE7pvqHJ6SFWcWzCyXIHjxq2jWopf8r0NHPdlaNXHflgMCblEtiFLDgQqeyNH1cVPbWtUtzPGcg7rD2pyb4moSyXWKli7eyNNkjaeWAHu9KZ4VHQwgUo6foBdlyYGawl8cGVbhw81W4n1IGZW0LgzCLAHwlwQxIujSuBIUgPMeLAZg2LAXyTqGDgk1cnTs9f3wQrlPUyAMLutlP2K7DLL6njml1lGIL6lK6NwNuJoPgKTrXs9f3gknI(df(c(r0NHPVgpFSIMiYp8sKkHvgzZ)i6ZW0Hxa8n4WIVggVPweS4nH8vUbcabSwivp5m(BOQLHRJEHhn3Wc(i6ZW0Hu9KZyXWKlyXBc5RrZB)P0i6pu4l4hrFgM(A88XkAIi)WlrQewzKn)JOpdths1toJfdtUGfVjKVYnqGIkASh1z)GS3rTnh78eYob25PckO4rD2pi7DuBZXopHStGDEkytobf)l7CdHbkPKafv8JOpdthEbW3Gdl(Ay8MArWI3eYxzNHkeb2zijI30a4j3PSeacyTqQEYz83qvldxh9cNdcyTqQEYz83qvld30a41rVWkPGck(r0NHPdVa4BWHfFnmEtTiyXBc5RCdeacyTqQEYz83qvldxh9cNBGskjaeWAHfGZ4WIfdtUGZW0fSjNGI)LDEgQqeyNHKiEJC0gyJ3KtyX)usAKXvQfAmRcrUqKul0AXs9f3wQrwPMeLA0sQdxQ)Put(uQnd34pPgKLAarP2gLu3dVLlP(AixQVgwQ30as9K7uwqPwOVJADP2eDnsDfIsnYk1xdl1h1z)KA0sQpsy2HsTqDh9Putsni6K6lK6njml1lGILAtwQFYLAHAQsnAV5jIoUNLut2JlP(IBl1SpxsJO)qHVGFe9zy6RXZh7cGVbhw81W4n1IugzZbbSwivp5m(BOQLHRJEHhn3WcoQZ(blaNXHflgMCbzNa78uWhrFgMoSaCghwSyyYfS4nH81O5T)uWhrFgMoKQNCglgMCblEtiFLDgQqeyNHxCB8Mgap5oLLGpYWo5hu4Ske5q2jWopf8r0NHPdlAIi)WlrQegw8Mq(A0CHI0iJRupu4cbl0ywfICHiPwO1IL6lUTuJSsnjk1OLuhUu)tPM8PuBgUXFsnil1aIsTnkPUhElxs91qUuFnSuVPbK6j3PSGsTqFh16sTj6AK6keLAKvQVgwQpQZ(j1OLuFKWSdLgr)HcFb)i6ZW0xJNp2faFdoS4RHXBQfPmYMdcyTqQEYz83qvldxh9cpAUHfCuN9dwaoJdlwmm5cYob25PGpI(mmDyb4moSyXWKlyXBc5RrZB)PGpI(mmDivp5mwmm5cw8Mq(k7muHiWodV424nnaEYDklbg7hzyN8dkCwfICi7eyNNsJO)qHVGFe9zy6RXZh7cGVbhw81W4n1IugzZbbSwivp5m(BOQLHRJEHhn3Wcm2J6SFWcWzCyXIHjxq2jWopf8r0NHPdP6jNXIHjxWI3eYxzNHkeb2z4f3gVPbWtUtzjnI(df(c(r0NHPVgpFSla(gCyXxdJ3ulszKnheWAHu9KZ4VHQwgUo6fE0Cdl4JOpdths1toJfdtUGfVjKVgnV9NsJmUsTqRfl1KOuJSs9f3wQrlPoCP(Nsn5tP2mCJ)KAqwQbeLABusDp8wUK6RHCP(AyPEtdi1tUtzPSuVjHrERuVakwQVg6KAtwQBOmSuZEa02i1BYjPM8PuFn0j1xdxSuJwsThNut9IPzwsnj1fGZsDyLAXWKlPEgMouAe9hk8f8JOpdtFnE(yu9KZyXWKlLr2Cfn2J6SFq27O2MJDEczNa78ubfu8Oo7hK9oQT5yNNq2jWopfSjNGI)LDUHWaLusWhrFgMo8cGVbhw81W4n1IGfVjKVYodvicSZqseVPbWtUtzjaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHfacyTWcWzCyXIHjxWzy6c2KtqX)YopdvicSZqseVroAdSXBYjS4FsJmUsTqRfl1vik1iRuFXTLA0sQdxQ)Put(uQnd34pPgKLAarP2gLu3dVLlP(AixQVgwQ30as9K7uwkl1BsyK3k1lGIL6RHlwQrl34pPM6ftZSKAsQlaNL6zy6sn5tP(AOtQjrP2mCJ)KAq(Jnl1ugc1jWol1tGc5TsDb4muAe9hk8f8JOpdtFnE(yfGZ4WIfdtUugzZbbSwyb4moSyXWKl4mmDbFe9zy6Wla(gCyXxdJ3ulcw8Mq(k7muHiWodRqeVPbWtUtzjaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHfO4hrFgMoKQNCglgMCblEtiFL9WcPckmzqaRfEbW3Gdl(Ay8MArqarLKgzCLAHgZQqKlej1c1uLA0sQ3KtsDdG3wzj1KpLAH(rmKlPMkwQViKAEar2xOmSuFHudSyPwm2s9fs9Yqbywigl1Kl18axrsnbk1ixQVgwQV42sTjYNHjuQf64Z4xsnWILA0j1xi1BsywQ7HPu)nu1YsTq)ilPg5RJ8dknI(df(c(r0NHPVgpFmXIxS)moS4nYNkJS5GawlKQNCg)nu1YW1rVW5gi4JmSt(bfoRcroKDcSZtPrgxPEOWfcwOXSke5crsTqRfl1IXwQVqQxgkaZcXyPMCPMh4ksQjqPg5s91Ws9f3wQnr(mmHsJO)qHVGFe9zy6RXZhtS4f7pJdlEJ8PYiB(KbbSw4faFdoS4RHXBQfbbefySFKHDYpOWzviYHStGDEknI(df(c(r0NHPVgpFmGfJ3Kt4wERmYM)r0NHPd5mXthkCyXBc5RSnqGIkEuN9dYEh12CSZti7eyNNc2KtqX)gnxOyGGn5eu8VSZnocPskOGIg7rD2pi7DuBZXopHStGDEkytobf)B0CHIqQKssJKgzCL6rSc9sTqWsTqnEhzyPwOJoUKgr)HcFb51I9Nx5G9iM4WIVggZoVZszKn)JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fE0Cdl4JOpdths1toJfdtUGfVjKVgnV9NkOWrvlFWdTz8f4jIh9JOpdths1toJfdtUGfVjKVKgr)HcFb51I9NxJNpgypIjoS4RHXSZ7SugzZ)i6ZW0Hu9KZyXWKlyXBc5RCdeOOXEuN9dYEh12CSZti7eyNNkOGIh1z)GS3rTnh78eYob25PGn5eu8VSZnegOKscuuXpI(mmD4faFdoS4RHXBQfblEtiFL9WgiaeWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHvsbfu8JOpdthEbW3Gdl(Ay8MArWI3eYx5giaeWAHu9KZ4VHQwgUo6fo3aLusaiG1claNXHflgMCbNHPlytobf)l78muHiWodjr8g5OnWgVjNWI)jnI(df(cYRf7pVgpFmZO6ZmmYXfVcN8NvgzZ)i6ZW0Hxa8n4WIVggVPweS4nH8vUbcabSwivp5m(BOQLHRJEHhn3Wc(i6ZW0Hu9KZyXWKlyXBc5RrZB)PckCu1Yh8qBgFbEI4r)i6ZW0Hu9KZyXWKlyXBc5lPr0FOWxqETy)5145JzgvFMHroU4v4K)SYiB(hrFgMoKQNCglgMCblEtiFLBGafn2J6SFq27O2MJDEczNa78ubfu8Oo7hK9oQT5yNNq2jWopfSjNGI)LDUHWaLusGIk(r0NHPdVa4BWHfFnmEtTiyXBc5RSh2abGawlKQNCg)nu1YW1rVW5GawlKQNCg)nu1YWnnaED0lSskOGIFe9zy6Wla(gCyXxdJ3ulcw8Mq(k3abGawlKQNCg)nu1YW1rVW5gOKscabSwyb4moSyXWKl4mmDbBYjO4FzNNHkeb2zijI3ihTb24n5ew8pPr0FOWxqETy)5145J1cq1erooSysigxX1OmYM)r0NHPdVa4BWHfFnmEtTiyXBc5RCdeacyTqQEYz83qvldxh9cpAUHf8r0NHPdP6jNXIHjxWI3eYxJM3(tfu4OQLp4H2m(c8eXJ(r0NHPdP6jNXIHjxWI3eYxsJO)qHVG8AX(ZRXZhRfGQjICCyXKqmUIRrzKn)JOpdths1toJfdtUGfVjKVYnqGIg7rD2pi7DuBZXopHStGDEQGckEuN9dYEh12CSZti7eyNNc2KtqX)Yo3qyGskjqrf)i6ZW0Hxa8n4WIVggVPweS4nH8v2dBGaqaRfs1toJ)gQAz46Ox4CqaRfs1toJ)gQAz4MgaVo6fwjfuqXpI(mmD4faFdoS4RHXBQfblEtiFLBGaqaRfs1toJ)gQAz46Ox4CdusjbGawlSaCghwSyyYfCgMUGn5eu8VSZZqfIa7mKeXBKJ2aB8MCcl(N0i6pu4liVwS)8A88X(WF2VIoEITDAZk3roJ)zUXrzKnheWAHu9KZyXWKl4mmDbGawlSaCghwSyyYfCgMUGjdcyTWla(gCyXxdJ3ulcodtxWMCcEOnJVaVPbYoNhGFGJXhAZsJO)qHVG8AX(ZRXZhRyse5TyBN28szKnheWAHu9KZyXWKl4mmDbGawlSaCghwSyyYfCgMUGjdcyTWla(gCyXxdJ3ulcodtxWMCcEOnJVaVPbYoNhGFGJXhAZsJO)qHVG8AX(ZRXZhZgpWINysigxOJXGmTvgzZbbSwivp5mwmm5codtxaiG1claNXHflgMCbNHPlyYGawl8cGVbhw81W4n1IGZW0Lgr)HcFb51I9NxJNpMiqHSzH8wmyNwNYiBoiG1cP6jNXIHjxWzy6cabSwyb4moSyXWKl4mmDbtgeWAHxa8n4WIVggVPweCgMU0i6pu4liVwS)8A88XkKOyNXihVePNvgzZbbSwivp5mwmm5codtxaiG1claNXHflgMCbNHPlyYGawl8cGVbhw81W4n1IGZW0Lgr)HcFb51I9NxJNp21Wyahma8j2g1ZkJS5GawlKQNCglgMCbNHPlaeWAHfGZ4WIfdtUGZW0fmzqaRfEbW3Gdl(Ay8MArWzy6sJO)qHVG8AX(ZRXZhBZ7OYchwCh4rt8SyAVugzZbbSwivp5mwmm5codtxaiG1claNXHflgMCbNHPlyYGawl8cGVbhw81W4n1IGZW0LgjnI(df(cAro1XGaLNt1toJ3O1c15LYiBoiG1c)ot1tRd5TWIP)u(BiKNpS0i6pu4lOf5uhdcu(45Jr1toJb706Kgr)HcFbTiN6yqGYhpFmQEYzmivf1YsJKgr)HcFb3rgEZ(Ld2rUWyYZszKnFhz4n7hCIwh5pND(WginI(df(cUJm8M9B88XelEX(Z4WI3iFknI(df(cUJm8M9B88XO6jNXB0AH68szKnFhz4n7hCIwh5pp6WginI(df(cUJm8M9B88XO6jNXrbknI(df(cUJm8M9B88XSOIXGDADsJKgzCLA6pu4lyiYox5zOcrGDwzN2CEdLHXHi78u5qmFXNYzOoaNpSYiBUyXzWT)eomKZepDOWLgr)HcFbdr25A88X6O2MBHfIdmB3SFkJS5GawlKQNCglgMCbNHPlaeWAHfGZ4WIfdtUGZW0fmzqaRfEbW3Gdl(Ay8MArWzy6sJO)qHVGHi7CnE(yGuloS4RqVWlLr2CqaRfs1toJfdtUGZW0facyTWcWzCyXIHjxWzy6cMmiG1cVa4BWHfFnmEtTi4mmDPr0FOWxWqKDUgpFmGfJrhVxkJS5GawlKQNCglgMCbbeLgr)HcFbdr25A88Xa5AXLWiVvzKnheWAHu9KZyXWKliGO0i6pu4lyiYoxJNpgypIj2cuzPmYMdcyTqQEYzSyyYfequAe9hk8fmezNRXZhZIkgShXuzKnheWAHu9KZyXWKliGO0i6pu4lyiYoxJNpg5pVUI64N6DLr2CqaRfs1toJfdtUGaIsJO)qHVGHi7CnE(ywuXyWoToLr28cWzBuTmCIwpsSJCQYc)XEt(eYgkasuKNcabSw4eTEKyh5uLf(J9M8j2wX6GaIsJO)qHVGHi7CnE(y2kwh2JmKYiBEb4SnQwg2wOvplm6rFNHSHcGef5PGn5eu8VSfcfsPr0FOWxWqKDUgpFSnQQOw4WIVO2SFsJO)qHVGHi7CnE(ytMUgWOCwAe9hk8fmezNRXZhROjI8dVePsyLr28n5eu8VSnKginI(df(cgISZ145J9K)Cht)HcxzKnN(dfoC1GShYBXIHjxWVHCN7iVvq7pHfVjKVYnqAe9hk8fmezNRXZhB1GShYBXIHjxkJS5RaOdI8j0I4(ehwmypwRyVGStGDEknI(df(cgISZ145JDbW3Gdl(Ay8MArsJO)qHVGHi7CnE(yu9KZyXWKlPr0FOWxWqKDUgpFScWzCyXIHjxkJS5GawlSaCghwSyyYfCgMU0i6pu4lyiYoxJNpgWIXBYjClVvgzZv8Oo7hK9oQT5yNNq2jWopfSjNGI)nAUqXabBYjO4FzNBCesLuqbfn2J6SFq27O2MJDEczNa78uWMCck(3O5cfHujPr0FOWxWqKDUgpFmqUwCjmYBvgzZbbSwivp5mwmm5cciknI(df(cgISZ145JDOnJnPsuzKnVaC2gvldpElgf1XMujczdfajkYtPr0FOWxWqKDUgpFmXIxS)moS4nYNkJS5tgeWAHxa8n4WIVggVPweequWKbbSw4faFdoS4RHXBQfblEtiFnAoiG1cflEX(Z4WI3iFc30a41rVWcTP)qHdP6jNXGDADqEa(bogFOnlnI(df(cgISZ145Jr1toJb706ugzZNXblAIi)WlrQegw8Mq(kBHubfMmiG1clAIi)WlrQegNbO7CrGOo6YcUo6foBdKgr)HcFbdr25A88XO6jNXGDADkJS5GawluS4f7pJdlEJ8jequWKbbSw4faFdoS4RHXBQfbbefmzqaRfEbW3Gdl(Ay8MArWI3eYxJMt)Hchs1toJb706G8a8dCm(qBwAe9hk8fmezNRXZhJQNCgdsvrTSYiBoiG1cP6jNXIHjxqarbGawlKQNCglgMCblEtiFnAE7pfacyTqQEYz83qvldxh9cNdcyTqQEYz83qvld30a41rVWsJO)qHVGHi7CnE(yu9KZ4nATqDEPmYMpzqaRfEbW3Gdl(Ay8MArqarbh1z)Gu9KZy(Bci7eyNNcabSw4KPRbmkNHZW0fmzqaRfEbW3Gdl(Ay8MArWI3eYxzt)Hchs1toJ3O1c15fKhGFGJXhAZk)neYZhwAe9hk8fmezNRXZhJQNCgVrRfQZlLr2CqaRf(DMQNwhYBHft)P83qipFyPr0FOWxWqKDUgpFmQEYzCuGkJS5GawlKQNCg)nu1YW1rVWJMBybk(r0NHPdP6jNXIHjxWI3eYxzpSbkOa9hkdJzN3iEnAUHvsAe9hk8fmezNRXZhJQNCgd2P1PmYMdcyTWcWzCyXIHjxqarfuytobf)l7HfsPr0FOWxWqKDUgpFmot80HcxzKnheWAHfGZ4WIfdtUGZW0vg5hxfG4Hr28n5eu8VSZfkcPYi)4QaepmAV5jIooFyPr0FOWxWqKDUgpFmQEYzmivf1YsJKgr)HcFbR4OdfEEgQqeyNv2PnNBro1XGaLRCiMV4t5muhGZhwzKnheWAHu9KZ4VHQwgUo6foheWAHu9KZ4VHQwgUPbWRJEHfySGawlSa6moS4RPyEbbefCu1Yh8qBgFbEI4rZvuXn5Kq9P)qHdP6jNXGDADWpwNscTP)qHdP6jNXGDADqEa(bogFOnRK0iJRut)HcFbR4Odf(45JTUc9hEXgka7pRmYMpzqaRfw0er(HxIujmodq35IarD0LfCD0lC(KbbSwyrte5hEjsLW4maDNlce1rxwWnnaED0lSaqaRfs1toJfdtUGZW0facyTWcWzCyXIHjxWzy6k70MZ706WlrQegVo6fwiIQNCgd2P1jer1toJbPQOwwAe9hk8fSIJou4JNpgvp5mgKQIAzLr28jdcyTWIMiYp8sKkHXza6oxeiQJUSGRJEHZNmiG1clAIi)WlrQegNbO7CrGOo6YcUPbWRJEHfOiiG1cP6jNXIHjxWzy6kOaiG1cP6jNXIHjxWI3eYxJM3(tLeOiiG1claNXHflgMCbNHPRGcGawlSaCghwSyyYfS4nH81O5T)ujPr0FOWxWko6qHpE(yu9KZyWoToLr28zCWIMiYp8sKkHHfVjKVYwivqHjdcyTWIMiYp8sKkHXza6oxeiQJUSGRJEHZ2aPr0FOWxWko6qHpE(yu9KZyWoToLr2CqaRfkw8I9NXHfVr(ecikyYGawl8cGVbhw81W4n1IGaIcMmiG1cVa4BWHfFnmEtTiyXBc5RrZP)qHdP6jNXGDADqEa(bogFOnlnI(df(cwXrhk8XZhJQNCgVrRfQZlLr28jdcyTWla(gCyXxdJ3ulccik4Oo7hKQNCgZFtazNa78uaiG1cNmDnGr5mCgMUafNmiG1cVa4BWHfFnmEtTiyXBc5RSP)qHdP6jNXB0AH68cYdWpWX4dTzfu4JOpdthkw8I9NXHfVr(ew8Mq(kBduqHpYWo5hu4Ske5q2jWopvs5VHqE(WsJO)qHVGvC0HcF88XO6jNXB0AH68szKnheWAHFNP6P1H8wyX0FcabSwipGi5tEIfJJ9drDiGO0i6pu4lyfhDOWhpFmQEYz8gTwOoVugzZbbSw43zQEADiVfwm9NafbbSwivp5mwmm5cciQGcGawlSaCghwSyyYfequbfMmiG1cVa4BWHfFnmEtTiyXBc5RSP)qHdP6jNXB0AH68cYdWpWX4dTzLu(BiKNpS0i6pu4lyfhDOWhpFmQEYz8gTwOoVugzZbbSw43zQEADiVfwm9NaqaRf(DMQNwhYBHRJEHZbbSw43zQEADiVfUPbWRJEHv(BiKNpS0i6pu4lyfhDOWhpFmQEYz8gTwOoVugzZbbSw43zQEADiVfwm9NaqaRf(DMQNwhYBHfVjKVgnxrfbbSw43zQEADiVfUo6fwOn9hkCivp5mEJwluNxqEa(bogFOnR04T)ujL)gc55dlnI(df(cwXrhk8XZhZ5RHl8XBrEDkJS5kwST4vdb2zfuWyp0lmYBvsaiG1cP6jNXFdvTmCD0lCoiG1cP6jNXFdvTmCtdGxh9claeWAHu9KZyXWKl4mmDbtgeWAHxa8n4WIVggVPweCgMU0i6pu4lyfhDOWhpFmQEYzCuGkJS5GawlKQNCg)nu1YW1rVWJMByPr0FOWxWko6qHpE(ylarU8idPmYMVjNGI)nAUqOqkaeWAHu9KZyXWKl4mmDbGawlSaCghwSyyYfCgMUGjdcyTWla(gCyXxdJ3ulcodtxAe9hk8fSIJou4JNp2QbzpK3IfdtUugzZbbSwivp5mwmm5codtxaiG1claNXHflgMCbNHPlyYGawl8cGVbhw81W4n1IGZW0f8r0NHPd5mXthkCyXBc5RSnqWhrFgMoKQNCglgMCblEtiFLTbc(i6ZW0Hxa8n4WIVggVPweS4nH8v2giqrJ9Oo7hSaCghwSyyYfKDcSZtfuqXJ6SFWcWzCyXIHjxq2jWopf8r0NHPdlaNXHflgMCblEtiFLTbkPK0i6pu4lyfhDOWhpFmQEYzmyNwNYiBoiG1clGoJdl(AkMxqarbGawlKQNCg)nu1YW1rVWzBmsJmUs9iwHEPwiyPwOgVJmSul0rhxsJO)qHVGvC0HcF88XO6jNXGuvulRmYMVjNGI)nAgQqeyNHGuvulJ3KtyX)e8r0NHPd5mXthkCyXBc5RSnqaiG1cP6jNXIHjxWzy6cabSwivp5m(BOQLHRJEHZbbSwivp5m(BOQLHBAa86Oxyb8AX(ZWmOfkCCyXICz5)qHd3ipkPr0FOWxWko6qHpE(yu9KZyqQkQLvgzZ)i6ZW0Hxa8n4WIVggVPweS4nH8vUbcu8JOpdthwaoJdlwmm5cw8Mq(k3afu4JOpdths1toJfdtUGfVjKVYnqjbGawlKQNCg)nu1YW1rVW5GawlKQNCg)nu1YWnnaED0lS0i6pu4lyfhDOWhpFmQEYzmivf1YkJS5BYjO4FJMNHkeb2ziivf1Y4n5ew8pbGawlKQNCglgMCbNHPlaeWAHfGZ4WIfdtUGZW0fmzqaRfEbW3Gdl(Ay8MArWzy6cabSwivp5m(BOQLHRJEHZbbSwivp5m(BOQLHBAa86OxybFe9zy6qot80Hchw8Mq(kBdKgr)HcFbR4Odf(45Jr1toJbPQOwwzKnheWAHu9KZyXWKl4mmDbGawlSaCghwSyyYfCgMUGjdcyTWla(gCyXxdJ3ulcodtxaiG1cP6jNXFdvTmCD0lCoiG1cP6jNXFdvTmCtdGxh9cl4Oo7hKQNCghfiKDcSZtbFe9zy6qQEYzCuGWI3eYxJM3(tbBYjO4FJMleAGGpI(mmDiNjE6qHdlEtiFLTbsJO)qHVGvC0HcF88XO6jNXGuvulRmYMdcyTqQEYzSyyYfequaiG1cP6jNXIHjxWI3eYxJM3(tbGawlKQNCg)nu1YW1rVW5GawlKQNCg)nu1YWnnaED0lS0i6pu4lyfhDOWhpFmQEYzmivf1YkJS5GawlSaCghwSyyYfequaiG1claNXHflgMCblEtiFnAE7pfacyTqQEYz83qvldxh9cNdcyTqQEYz83qvld30a41rVWsJO)qHVGvC0HcF88XO6jNXGDADsJO)qHVGvC0HcF88X4mXthkCLr(XvbiEyKnFtobf)l7CHIqQmYpUkaXdJ2BEIOJZhwAe9hk8fSIJou4JNpgvp5mgKQIA5KkbCnrLuvrBGoDOWfcuK9sx6sja]] )


end
