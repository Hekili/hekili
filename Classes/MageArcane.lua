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


    spec:RegisterPack( "Arcane", 20201012.1, [[d4uXFdqikI6ruuvDjcsbTjc8jkQYOiHofjYQiiL6vkunlsu3IIkvTlq)sHYWOiDmjQwgfHNrqW0OisxJGKTrrL8nkIyCee5CuuvwhbHAEkKUNOAFIsDqcsvluH4HuuPmrkQuHlsrLk6JeeImsccr1jjifTskkVKGuOzsqQCtcsb2PeLFsqimuccrzPeeLEkjnvjsxLGuYxPOsLglbr1Ef5VqnysDyKfd0Jv1Kv0LrTzk9zfmAjCAiRMGO41euZws3wP2TWVPA4e64uuXYL65kz6QCDaBxu8DkmEjIZlkz9eesZNeSFIovEQ0K6KoovMjm1eMwUPLBcOjk3KAQPMKK6LLiNufPxyAGtQbT5KQqF)uWjvrkRQtZuPj1Ld0pNulUtCjep2ydORaae((ESfAduPd5X3K9gBH2)yjvqau9eAgjWK6KoovMjm1eMwUPLBcOjk3KAQPMiPUe5pvM5Yej1c0CYrcmPo51Nun)sTqF)uWsTqdObwAM5xQfI4phKBP28PSuBctnHPj1kADRuPjvxKdUtLMkR8uPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUrKuP)qEKuROHIBHfYamh2CCPlvMjsLMu5GaR8mnss9B0XnIsQGawlK6Ncgl6gCdNUri1cKAqaRf2abJDlw0n4goDJqQfi1tgeWAHNd8fy3IVcgVPbeC6grsL(d5rsfKgWUfFn6fELUuzcHuPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3qaXKk9hYJKkWIXOJ3R0LkZKMknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKub5EXTWOyiDPYeQuPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3qaXKk9hYJKky19j2c0zLUuzMRuPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3qaXKk9hYJKQf1my19z6sLzssLMu5GaR8mnss9B0XnIsQGawlK6Ncgl6gCdbetQ0FipsQu886AQIFQwtxQmHuQ0KkheyLNPrsQFJoUrusTbc269adNO1JeROG6SWVV3umHS5aGef5PulqQbbSw4eTEKyffuNf(99MIj22(6GaIjv6pKhjvlQzmyLwx6sLz(sLMu5GaR8mnss9B0XnIsQnqWwVhy4qJw1SWOh9vgYMdasuKNsTaPEtbbf)tQZwQnFcvsL(d5rs12(6WHNHsxQSYnnvAsL(d5rsDJ627f2T4Z7nhxsLdcSYZ0iPlvw5LNknPs)H8iPoz6ka9o4KkheyLNPrsxQSYnrQ0KkheyLNPrsQFJoUrusDtbbf)tQZwQnPMMuP)qEKuBAIO4WlrQfoDPYkxiKknPYbbw5zAKK63OJBeLuP)qEaxfi7HIbSOBWn8lOi4kkgsQ0FipsQpfpxX0FipsxQSYnPPstQCqGvEMgjP(n64grj1LdubrXeArCDIDlgS6RLVxqoiWkptQ0FipsQRcK9qXaw0n4oDPYkxOsLMuP)qEKuph4lWUfFfmEtdOKkheyLNPrsxQSYnxPstQ0FipsQu)uWyr3G7KkheyLNPrsxQSYnjPstQCqGvEMgjP(n64grjvqaRf2abJDlw0n4goDJiPs)H8iP2abJDlw0n4oDPYkxiLknPYbbw5zAKK63OJBeLuvuQpQYXb5OIgkoo4jKdcSYtPwGuVPGGI)j1JMl1cjtLAbs9Mcck(NuNDUuBUekPwjPwbfKAfLAtwQpQYXb5OIgkoo4jKdcSYtPwGuVPGGI)j1JMl1cjHsQvkPs)H8iPUPGWd8oDPYk38LknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKub5EXTWOyiDPYmHPPstQCqGvEMgjP(n64grj1giyR3dm84TO3ufBqTiKnhaKOiptQ0FipsQhAZydQftxQmtuEQ0KkheyLNPrsQFJoUrusDYGawl8CGVa7w8vW4nnGGaIsTaPEYGawl8CGVa7w8vW4nnGGnVjuSK6rZLAqaRfk28IJNXUfVrXeUPsWRJEHLAH2sn9hYdi1pfmgSsRdYLWpWX4dT5Kk9hYJKQyZloEg7w8gfZ0LkZeMivAsLdcSYZ0ij1Vrh3ikPo9d20erXHxIulmS5nHILuNTulusTcki1tgeWAHnnruC4Li1cJZaudUjqufDzbxh9cl1zl1MMuP)qEKuP(PGXGvADPlvMjecPstQCqGvEMgjP(n64grjvqaRfk28IJNXUfVrXecik1cK6jdcyTWZb(cSBXxbJ30accik1cK6jdcyTWZb(cSBXxbJ30ac28MqXsQhnxQP)qEaP(PGXGvADqUe(bogFOnNuP)qEKuP(PGXGvADPlvMjmPPstQCqGvEMgjP(n64grjvqaRfs9tbJfDdUHaIsTaPgeWAHu)uWyr3GByZBcflPE0CPE4NsTaPgeWAHu)uW4VG6bgUo6fwQZLAqaRfs9tbJ)cQhy4MkbVo6foPs)H8iPs9tbJbPUPboDPYmHqLknPYbbw5zAKKk9hYJKk1pfmEJwluLxj1VGqrsT8K63OJBeLuNmiG1cph4lWUfFfmEtdiiGOulqQpQYXbP(PGX8x4qoiWkpLAbsniG1cNmDfGEhmC6gHulqQNmiG1cph4lWUfFfmEtdiyZBcflPoBPM(d5bK6NcgVrRfQYlixc)ahJp0MtxQmtyUsLMu5GaR8mnssL(d5rsL6NcgVrRfQYRK6xqOiPwEs9B0XnIsQGawl8Rm1pToumaBM(lDPYmHjjvAsLdcSYZ0ij1Vrh3ikPccyTqQFky8xq9adxh9cl1JMl1MqQfi1kk1V71PBeqQFkySOBWnS5nHILuNTuxUPsTcki10FOmmMdEJ4LupAUuBcPwPKk9hYJKk1pfm2BW0LkZecPuPjvoiWkptJKu)gDCJOKkiG1cBGGXUfl6gCdbeLAfuqQ3uqqX)K6SL6YfQKk9hYJKk1pfmgSsRlDPYmH5lvAsLdcSYZ0ijv6pKhjvoJ)0H8iPIIJ7gq8WiBsDtbbf)l7CHKqLurXXDdiEy0EZteDCsT8K63OJBeLubbSwydem2Tyr3GB40nI0LktiyAQ0Kk9hYJKk1pfmgK6Mg4KkheyLNPrsx6sQ8AXXZRuPPYkpvAsLdcSYZ0ij1Vrh3ikP(UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1GawlK6Ncg)fupWW1rVWs9O5sTjKAbs97ED6gbK6Ncgl6gCdBEtOyj1JMl1d)uQvqbP(OEGp4H2m(C8eXs9Os97ED6gbK6Ncgl6gCdBEtOyLuP)qEKubRUpXUfFfmMdENv6sLzIuPjvoiWkptJKu)gDCJOK67ED6gbK6Ncgl6gCdBEtOyj15sTPsTaPwrP2KL6JQCCqoQOHIJdEc5GaR8uQvqbPwrP(OkhhKJkAO44GNqoiWkpLAbs9Mcck(NuNDUuBsmvQvsQvsQfi1kk1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZwQl3uPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cl1kj1kOGuROu)UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1GawlK6Ncg)fupWW1rVWsDUuBQuRKuRKulqQbbSwydem2Tyr3GB40ncPwGuVPGGI)j1zNl1zOgrGvgsI4nkqBGnEtbHf)lPs)H8iPcwDFIDl(kymh8oR0LktiKknPYbbw5zAKK63OJBeLuF3Rt3iGNd8fy3IVcgVPbeS5nHILuNl1Mk1cKAqaRfs9tbJ)cQhy46OxyPE0CP2esTaP(DVoDJas9tbJfDdUHnVjuSK6rZL6HFk1kOGuFupWh8qBgFoEIyPEuP(DVoDJas9tbJfDdUHnVjuSsQ0FipsQgExNzyuGBE5bfpNUuzM0uPjvoiWkptJKu)gDCJOK67ED6gbK6Ncgl6gCdBEtOyj15sTPsTaPwrP2KL6JQCCqoQOHIJdEc5GaR8uQvqbPwrP(OkhhKJkAO44GNqoiWkpLAbs9Mcck(NuNDUuBsmvQvsQvsQfi1kk1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZwQl3uPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cl1kj1kOGuROu)UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1GawlK6Ncg)fupWW1rVWsDUuBQuRKuRKulqQbbSwydem2Tyr3GB40ncPwGuVPGGI)j1zNl1zOgrGvgsI4nkqBGnEtbHf)lPs)H8iPA4DDMHrbU5Lhu8C6sLjuPstQCqGvEMgjP(n64grj13960nc45aFb2T4RGXBAabBEtOyj15sTPsTaPgeWAHu)uW4VG6bgUo6fwQhnxQnHulqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4NsTcki1h1d8bp0MXNJNiwQhvQF3Rt3iGu)uWyr3GByZBcfRKk9hYJK6aa1tefy3IjHOC7xr6sLzUsLMu5GaR8mnss9B0XnIsQV71PBeqQFkySOBWnS5nHILuNl1Mk1cKAfLAtwQpQYXb5OIgkoo4jKdcSYtPwbfKAfL6JQCCqoQOHIJdEc5GaR8uQfi1BkiO4FsD25sTjXuPwjPwjPwGuROuROu)UxNUraph4lWUfFfmEtdiyZBcflPoBPUCtLAbsniG1cP(PGXFb1dmCD0lSuNl1GawlK6Ncg)fupWWnvcED0lSuRKuRGcsTIs97ED6gb8CGVa7w8vW4nnGGnVjuSK6CP2uPwGudcyTqQFky8xq9adxh9cl15sTPsTssTssTaPgeWAHnqWy3IfDdUHt3iKAbs9Mcck(NuNDUuNHAebwzijI3OaTb24nfew8VKk9hYJK6aa1tefy3IjHOC7xr6sLzssLMu5GaR8mnssL(d5rs99454A64j2wPnNu)gDCJOKkiG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUri1cK6nfe8qBgFoEtLi1zNl1Cj8dCm(qBoPwrbJ)zs1CLUuzcPuPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUri1cK6nfe8qBgFoEtLi1zNl1Cj8dCm(qBoPs)H8iP2mjIIbSTsBELUuzMVuPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUrKuP)qEKuT(dS4jMeIYn6ymit70LkRCttLMu5GaR8mnss9B0XnIsQGawlK6Ncgl6gCdNUri1cKAqaRf2abJDlw0n4goDJqQfi1tgeWAHNd8fy3IVcgVPbeC6grsL(d5rsveOr2SqXagSsRlDPYkV8uPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUrKuP)qEKuBKOyLXOaVePNtxQSYnrQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GB40ncPwGudcyTWgiySBXIUb3WPBesTaPEYGawl8CGVa7w8vW4nnGGt3isQ0FipsQxbJbcqhiMyR3pNUuzLlesLMu5GaR8mnss9B0XnIsQGawlK6Ncgl6gCdNUri1cKAqaRf2abJDlw0n4goDJqQfi1tgeWAHNd8fy3IVcgVPbeC6grsL(d5rsDZBVZc7wCf4rt8SzAVsx6sQTF0H8ivAQSYtLMu5GaR8mnss1ftQl(sQ0FipsQzOgrGvoPMHQaCsT8K63OJBeLubbSwi1pfm(lOEGHRJEHL6CPgeWAHu)uW4VG6bgUPsWRJEHLAbsTjl1GawlSbQm2T4ROzEbbeLAbs9r9aFWdTz854jIL6rZLAfLAfL6nfKupMut)H8as9tbJbR06GVVoPwjPwOTut)H8as9tbJbR06GCj8dCm(qBwQvkPMHACqBoPArbvXGaDKUuzMivAsLdcSYZ0ij1Vrh3ikPozqaRf20erXHxIulmodqn4Marv0LfCD0lSuNl1tgeWAHnnruC4Li1cJZaudUjqufDzb3uj41rVWsTaPwrPgeWAHnqWy3IfDdUHt3iKAfuqQbbSwydem2Tyr3GByZBcflPE0CPE4NsTsjv6pKhjvQFkymi1nnWPlvMqivAsLdcSYZ0ij1Vrh3ikPo9d20erXHxIulmS5nHILuNTulusTcki1tgeWAHnnruC4Li1cJZaudUjqufDzbxh9cl1zl1MMuP)qEKuP(PGXGvADPlvMjnvAsLdcSYZ0ij1Vrh3ikPccyTqXMxC8m2T4nkMqarPwGupzqaRfEoWxGDl(ky8MgqqarPwGupzqaRfEoWxGDl(ky8MgqWM3ekws9O5sn9hYdi1pfmgSsRdYLWpWX4dT5Kk9hYJKk1pfmgSsRlDPYeQuPjvoiWkptJKuP)qEKuP(PGXB0AHQ8kP(feksQLNu)gDCJOK6KbbSw45aFb2T4RGXBAabbeLAbs9rvooi1pfmM)chYbbw5PulqQbbSw4KPRa07GHt3iKAbsTIs9KbbSw45aFb2T4RGXBAabBEtOyj1zl10FipGu)uW4nATqvEb5s4h4y8H2SuRGcs97ED6gbuS5fhpJDlEJIjS5nHILuNTuBQuRGcs97z4GIdkCwnIcPwP0LkZCLknPYbbw5zAKK63OJBeLubbSw4xzQFADOya2m9NulqQbbSwixIiftEIf9JJdrviGysL(d5rsL6NcgVrRfQYR0LkZKKknPYbbw5zAKKk9hYJKk1pfmEJwluLxj1VGqrsT8K63OJBeLubbSw4xzQFADOya2m9NulqQvuQbbSwi1pfmw0n4gcik1kOGudcyTWgiySBXIUb3qarPwbfK6jdcyTWZb(cSBXxbJ30ac28MqXsQZwQP)qEaP(PGXB0AHQ8cYLWpWX4dTzPwP0LktiLknPYbbw5zAKKk9hYJKk1pfmEJwluLxj1VGqrsT8K63OJBeLubbSw4xzQFADOya2m9NulqQbbSw4xzQFADOyaUo6fwQZLAqaRf(vM6NwhkgGBQe86Ox40LkZ8LknPYbbw5zAKKk9hYJKk1pfmEJwluLxj1VGqrsT8K63OJBeLubbSw4xzQFADOya2m9NulqQbbSw4xzQFADOya28MqXsQhnxQvuQvuQbbSw4xzQFADOyaUo6fwQfAl10FipGu)uW4nATqvEb5s4h4y8H2SuRKupUup8tPwP0LkRCttLMu5GaR8mnss9B0XnIsQkk1nBBEvqGvwQvqbP2KL6d9cJIbPwjPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cl1cKAqaRfs9tbJfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUrKuP)qEKud(k4gF8wKxx6sLvE5PstQCqGvEMgjP(n64grjvqaRfs9tbJ)cQhy46OxyPE0CP2ejv6pKhjvQFkyS3GPlvw5MivAsLdcSYZ0ij1Vrh3ikPUPGGI)j1JMl1MpHsQfi1GawlK6Ncgl6gCdNUri1cKAqaRf2abJDlw0n4goDJqQfi1tgeWAHNd8fy3IVcgVPbeC6grsL(d5rsDbiYD4zO0LkRCHqQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GB40ncPwGudcyTWgiySBXIUb3WPBesTaPEYGawl8CGVa7w8vW4nnGGt3iKAbs97ED6gbKZ4pDipGnVjuSK6SLAtLAbs97ED6gbK6Ncgl6gCdBEtOyj1zl1Mk1cK63960nc45aFb2T4RGXBAabBEtOyj1zl1Mk1cKAfLAtwQpQYXbBGGXUfl6gCd5GaR8uQvqbPwrP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1zl1Mk1kj1kLuP)qEKuxfi7HIbSOBWD6sLvUjnvAsLdcSYZ0ij1Vrh3ikPccyTWgOYy3IVIM5fequQfi1GawlK6Ncg)fupWW1rVWsD2sTqiPs)H8iPs9tbJbR06sxQSYfQuPjvoiWkptJKu)gDCJOK6Mcck(NupQuNHAebwzii1nnW4nfew8pPwGu)UxNUra5m(thYdyZBcflPoBP2uPwGudcyTqQFkySOBWnC6gHulqQbbSwi1pfm(lOEGHRJEHL6CPgeWAHu)uW4VG6bgUPsWRJEHLAbsnVwC8mmdAH8a7wSi3w(pKhWnk8oPs)H8iPs9tbJbPUPboDPYk3CLknPYbbw5zAKK63OJBeLuF3Rt3iGNd8fy3IVcgVPbeS5nHILuNl1Mk1cKAfL63960ncydem2Tyr3GByZBcflPoxQnvQvqbP(DVoDJas9tbJfDdUHnVjuSK6CP2uPwjPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cNuP)qEKuP(PGXGu30aNUuzLBssLMu5GaR8mnss9B0XnIsQBkiO4Fs9O5sDgQreyLHGu30aJ3uqyX)KAbsniG1cP(PGXIUb3WPBesTaPgeWAHnqWy3IfDdUHt3iKAbs9KbbSw45aFb2T4RGXBAabNUri1cKAqaRfs9tbJ)cQhy46OxyPoxQbbSwi1pfm(lOEGHBQe86OxyPwGu)UxNUra5m(thYdyZBcflPoBP20Kk9hYJKk1pfmgK6Mg40LkRCHuQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GB40ncPwGudcyTWgiySBXIUb3WPBesTaPEYGawl8CGVa7w8vW4nnGGt3iKAbsniG1cP(PGXFb1dmCD0lSuNl1GawlK6Ncg)fupWWnvcED0lSulqQpQYXbP(PGXEdc5GaR8uQfi1V71PBeqQFkyS3GWM3ekws9O5s9WpLAbs9Mcck(NupAUuB(mvQfi1V71PBeqoJ)0H8a28MqXsQZwQnnPs)H8iPs9tbJbPUPboDPYk38LknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gcik1cKAqaRfs9tbJfDdUHnVjuSK6rZL6HFk1cKAqaRfs9tbJ)cQhy46OxyPoxQbbSwi1pfm(lOEGHBQe86Ox4Kk9hYJKk1pfmgK6Mg40LkZeMMknPYbbw5zAKK63OJBeLubbSwydem2Tyr3GBiGOulqQbbSwydem2Tyr3GByZBcflPE0CPE4NsTaPgeWAHu)uW4VG6bgUo6fwQZLAqaRfs9tbJ)cQhy4MkbVo6foPs)H8iPs9tbJbPUPboDPYmr5PstQ0FipsQu)uWyWkTUKkheyLNPrsxQmtyIuPjvuCC3aIhgztQBkiO4FzNlKeQKkkoUBaXdJ2BEIOJtQLNuP)qEKu5m(thYJKkheyLNPrsxQmtiesLMuP)qEKuP(PGXGu30aNu5GaR8mns6sxsDYwcOEPstLvEQ0KkheyLNPrsQFJoUrus9OEGp4KbbSw4tRdfdWMP)sQ0FipsQVdeh3lrUwtxQmtKknPYbbw5zAKKk9hYJK6t1kM(d5bUIwxsTIwhoOnNu51IJNxPlvMqivAsLdcSYZ0ij1Vrh3ikPs)HYWyo4nIxsD2sTjsQ0FipsQpvRy6pKh4kADj1kAD4G2CsLCoDPYmPPstQCqGvEMgjP(n64grj1muJiWkdlOmm2f5GNsDUuBAsL(d5rs9PAft)H8axrRlPwrRdh0MtQUihCNUuzcvQ0KkheyLNPrsQ0FipsQpvRy6pKh4kADj1kAD4G2Cs9DVoDJyLUuzMRuPjvoiWkptJKu)gDCJOKAgQreyLHwuqvmiqhsDUuBAsL(d5rs9PAft)H8axrRlPwrRdh0MtQTF0H8iDPYmjPstQCqGvEMgjP(n64grj1muJiWkdTOGQyqGoK6CPU8Kk9hYJK6t1kM(d5bUIwxsTIwhoOnNuTOGQyqGosxQmHuQ0KkheyLNPrsQ0FipsQpvRy6pKh4kADj1kAD4G2CsD7z4nhx6sxsvS533G0Lknvw5PstQCqGvEMgjP6Ij1fFjv6pKhj1muJiWkNuZqvaoPAAsnd14G2CsvSzrGAfZz80LkZePstQCqGvEMgjP6Ij1fFjv6pKhj1muJiWkNuZqvaoPwEs9B0XnIsQnqWwVhy4cjw4bEDEVHS5aGef5PulqQP)qzymh8gXlPoBP2ej1muJdAZjvXMfbQvmNXtxQmHqQ0KkheyLNPrsQUysDXxsL(d5rsnd1icSYj1mufGtQLNu)gDCJOKAdeS17bgUqIfEGxN3BiBoairrEk1cK63ZWbfhm4V9Q3tPwGut)HYWyo4nIxsD2sD5j1muJdAZjvXMfbQvmNXtxQmtAQ0KkheyLNPrsQUysDXxsL(d5rsnd1icSYj1mufGtQLNu)gDCJOKAdeS17bgUqIfEGxN3BiBoairrEk1cK63ZWbfhmqdfh2sCsnd14G2CsvSzrGAfZz80LktOsLMu5GaR8mnss1ftQl(sQ0FipsQzOgrGvoPMHQaCs10KAgQXbT5KQffufdc0r6sLzUsLMu5GaR8mnss1ftQl(sQ0FipsQzOgrGvoPMHQaCsvOsQzOgh0MtQ9cVPsWtUszLUuzMKuPjvoiWkptJKuDXK6IVKk9hYJKAgQreyLtQzOkaNul30KAgQXbT5KkjI3uj4jxPSsxQmHuQ0KkheyLNPrsQUysDXxsL(d5rsnd1icSYj1mufGtQMW0KAgQXbT5KA7I4nvcEYvkR0LkZ8LknPYbbw5zAKKQlMux8LuP)qEKuZqnIaRCsndvb4KQqLuZqnoOnNup)24nvcEYvkR0LkRCttLMu5GaR8mnss1ftQl(sQ0FipsQzOgrGvoPMHQaCsviKu)gDCJOKAdeS17bgorRhjwrb1zHFFVPyczZbajkYZKAgQXbT5K653gVPsWtUszLUuzLxEQ0KkheyLNPrsQUysDXxsL(d5rsnd1icSYj1mufGtQLluj1Vrh3ikP(EgoO4GbAO4WwItQzOgh0MtQNFB8Mkbp5kLv6sLvUjsLMu5GaR8mnss1ftQl(sQ0FipsQzOgrGvoPMHQaCsTCHkP(n64grj13Jja6Gu)uWyX2NOHSGCqGvEk1cKA6puggZbVr8sQhvQfcj1muJdAZj1ZVnEtLGNCLYkDPYkxiKknPYbbw5zAKKQlMux8LuP)qEKuZqnIaRCsndvb4KQqW0K63OJBeLu51IJNHzqlKhy3If52Y)H8aUrH3j1muJdAZj1ZVnEtLGNCLYkDPYk3KMknPYbbw5zAKKQlMux8LuP)qEKuZqnIaRCsndvb4KQ5Z0KAgQXbT5Kki1nnW4nfew8V0LkRCHkvAsLdcSYZ0ijvxmPU4lPs)H8iPMHAebw5KAgQcWjvHKPj1Vrh3ikP(EgoO4GbAO4WwItQzOgh0MtQGu30aJ3uqyX)sxQSYnxPstQCqGvEMgjP6Ij1fFjv6pKhj1muJiWkNuZqvaoPkemnPMHACqBoPsI4nkqBGnEtbHf)lDPYk3KKknPYbbw5zAKKQlMux8LuP)qEKuZqnIaRCsndvb4KQqzAs9B0XnIsQnqWwVhy4eTEKyffuNf(99MIjKnhaKOiptQzOgh0MtQKiEJc0gyJ3uqyX)sxQSYfsPstQCqGvEMgjP6Ij1fFjv6pKhj1muJiWkNuZqvaoPkuMMu)gDCJOKAdeS17bgo0Ovnlm6rFLHS5aGef5zsnd14G2CsLeXBuG2aB8Mccl(x6sLvU5lvAsLdcSYZ0ijvxmPU4lPs)H8iPMHAebw5KAgQcWjvtKuZqnoOnNujNXNFB8xq9aVsxQmtyAQ0Kk9hYJK6cyV9at9tbJT0gvruNu5GaR8mns6sLzIYtLMuP)qEKuP(PGXO44AL)lPYbbw5zAK0LkZeMivAsL(d5rs99qidqZ4nfeEG3jvoiWkptJKUuzMqiKknPs)H8iPUrD7ngTPboPYbbw5zAK0LkZeM0uPjv6pKhjvr)qEKu5GaR8mns6sLzcHkvAsLdcSYZ0ij1Vrh3ikPMHAebwzOyZIa1kMZ4sDUuBQulqQBGGTEpWWjA9iXkkOol877nftiBoairrEk1cK63960nciiG1INO1JeROG6SWVV3umHntZSKAbsniG1cNO1JeROG6SWVV3umX22xhC6grsL(d5rs12(6a96LUuzMWCLknPYbbw5zAKK63OJBeLuZqnIaRmuSzrGAfZzCPoxQlpPs)H8iPYz8NoKhPlDj13960nIvQ0uzLNknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4goDJqQfi1GawlSbcg7wSOBWnC6gHulqQNmiG1cph4lWUfFfmEtdi40nIKk9hYJKAfnuClSqgG5WMJlDPYmrQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GB40ncPwGudcyTWgiySBXIUb3WPBesTaPEYGawl8CGVa7w8vW4nnGGt3isQ0FipsQG0a2T4RrVWR0LktiKknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKubwmgD8ELUuzM0uPjvoiWkptJKu)gDCJOKkiG1cP(PGXIUb3qaXKk9hYJKki3lUfgfdPlvMqLknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKubRUpXwGoR0LkZCLknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKuTOMbRUptxQmtsQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GBiGysL(d5rsLINxxtv8t1A6sLjKsLMu5GaR8mnss9B0XnIsQnqWwVhy4qJw1SWOh9vgYMdasuKNsTaP(DVoDJas9tbJfDdUHnVjuSK6SLAHGPsTaP(DVoDJaEoWxGDl(ky8MgqWM3ekwsDUuBQulqQvuQbbSwi1pfm(lOEGHRJEHL6rZLAti1cKAfLAfL6JQCCWgiySBXIUb3qoiWkpLAbs97ED6gbSbcg7wSOBWnS5nHILupAUup8tPwGu)UxNUraP(PGXIUb3WM3ekwsD2sDgQreyLHNFB8Mkbp5kLLuRKuRGcsTIsTjl1hv54GnqWy3IfDdUHCqGvEk1cK63960nci1pfmw0n4g28MqXsQZwQZqnIaRm88BJ3uj4jxPSKALKAfuqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4NsTssTsjv6pKhjvB7RdhEgkDPYmFPstQCqGvEMgjP(n64grj1giyR3dmCOrRAwy0J(kdzZbajkYtPwGu)UxNUraP(PGXIUb3WM3ekwsDUuBQulqQvuQnzP(OkhhKJkAO44GNqoiWkpLAfuqQvuQpQYXb5OIgkoo4jKdcSYtPwGuVPGGI)j1zNl1MetLALKALKAbsTIsTIs97ED6gb8CGVa7w8vW4nnGGnVjuSK6SL6YnvQfi1GawlK6Ncg)fupWW1rVWsDUudcyTqQFky8xq9ad3uj41rVWsTssTcki1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsniG1cP(PGXFb1dmCD0lSuNl1Mk1kj1kj1cKAqaRf2abJDlw0n4goDJqQfi1BkiO4FsD25sDgQreyLHKiEJc0gyJ3uqyX)sQ0FipsQ22xho8mu6sLvUPPstQCqGvEMgjP(n64grj1giyR3dmCIwpsSIcQZc)(EtXeYMdasuKNsTaP(DVoDJaccyT4jA9iXkkOol877nftyZ0mlPwGudcyTWjA9iXkkOol877nftST91bNUri1cKAfLAqaRfs9tbJfDdUHt3iKAbsniG1cBGGXUfl6gCdNUri1cK6jdcyTWZb(cSBXxbJ30acoDJqQvsQfi1V71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsTIsniG1cP(PGXFb1dmCD0lSupAUuBcPwGuROuROuFuLJd2abJDlw0n4gYbbw5PulqQF3Rt3iGnqWy3IfDdUHnVjuSK6rZL6HFk1cK63960nci1pfmw0n4g28MqXsQZwQZqnIaRm88BJ3uj4jxPSKALKAfuqQvuQnzP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraP(PGXIUb3WM3ekwsD2sDgQreyLHNFB8Mkbp5kLLuRKuRGcs97ED6gbK6Ncgl6gCdBEtOyj1JMl1d)uQvsQvkPs)H8iPABFDGE9sxQSYlpvAsLdcSYZ0ij1Vrh3ikP2abB9EGHt06rIvuqDw433BkMq2CaqII8uQfi1V71PBeqqaRfprRhjwrb1zHFFVPycBMMzj1cKAqaRforRhjwrb1zHFFVPyITOMHt3iKAbsTyZzWd)ewo02(6a96LuP)qEKuTOMXGvADPlvw5MivAsLdcSYZ0ij1Vrh3ikP(UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1GawlK6Ncg)fupWW1rVWs9O5sTjKAbs97ED6gbK6Ncgl6gCdBEtOyj1JMl1d)mPs)H8iPUrD79c7w859MJlDPYkxiKknPYbbw5zAKK63OJBeLuF3Rt3iGu)uWyr3GByZBcflPoxQnvQfi1kk1MSuFuLJdYrfnuCCWtiheyLNsTcki1kk1hv54GCurdfhh8eYbbw5PulqQ3uqqX)K6SZLAtIPsTssTssTaPwrPwrP(DVoDJaEoWxGDl(ky8MgqWM3ekwsD2sDgQreyLHKiEtLGNCLYsQfi1GawlK6Ncg)fupWW1rVWsDUudcyTqQFky8xq9ad3uj41rVWsTssTcki1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsniG1cP(PGXFb1dmCD0lSuNl1Mk1kj1kj1cKAqaRf2abJDlw0n4goDJqQfi1BkiO4FsD25sDgQreyLHKiEJc0gyJ3uqyX)sQ0FipsQBu3EVWUfFEV54sxQSYnPPstQCqGvEMgjP(n64grj13960nc45aFb2T4RGXBAabBEtOyj15sTPsTaPgeWAHu)uW4VG6bgUo6fwQhnxQnHulqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4Njv6pKhj1jtxbO3bNUuzLluPstQCqGvEMgjP(n64grj13960nci1pfmw0n4g28MqXsQZLAtLAbsTIsTjl1hv54GCurdfhh8eYbbw5PuRGcsTIs9rvooihv0qXXbpHCqGvEk1cK6nfeu8pPo7CP2KyQuRKuRKulqQvuQvuQF3Rt3iGNd8fy3IVcgVPbeS5nHILuNTuxUPsTaPgeWAHu)uW4VG6bgUo6fwQZLAqaRfs9tbJ)cQhy4MkbVo6fwQvsQvqbPwrP(DVoDJaEoWxGDl(ky8MgqWM3ekwsDUuBQulqQbbSwi1pfm(lOEGHRJEHL6CP2uPwjPwjPwGudcyTWgiySBXIUb3WPBesTaPEtbbf)tQZoxQZqnIaRmKeXBuG2aB8Mccl(xsL(d5rsDY0va6DWPlvw5MRuPjvoiWkptJKu)gDCJOK67ED6gb8CGVa7w8vW4nnGGnVjuSK6SL6muJiWkd7fEtLGNCLYsQfi1V71PBeqQFkySOBWnS5nHILuNTuNHAebwzyVWBQe8KRuwsTaPwrP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1JMl1d)uQvqbP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1zl1zOgrGvg2l8Mkbp5kLLuRGcsTjl1hv54GnqWy3IfDdUHCqGvEk1kj1cKAqaRfs9tbJ)cQhy46OxyPoBP2esTaPEYGawl8CGVa7w8vW4nnGGt3isQ0FipsQnnruC4Li1cNUuzLBssLMu5GaR8mnss9B0XnIsQV71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsniG1cP(PGXFb1dmCD0lSupAUuBcPwGu)UxNUraP(PGXIUb3WM3ekws9O5s9WptQ0FipsQnnruC4Li1cNUuzLlKsLMu5GaR8mnss9B0XnIsQV71PBeqQFkySOBWnS5nHILuNl1Mk1cKAfLAfLAtwQpQYXb5OIgkoo4jKdcSYtPwbfKAfL6JQCCqoQOHIJdEc5GaR8uQfi1BkiO4FsD25sTjXuPwjPwjPwGuROuROu)UxNUraph4lWUfFfmEtdiyZBcflPoBPod1icSYqseVPsWtUszj1cKAqaRfs9tbJ)cQhy46OxyPoxQbbSwi1pfm(lOEGHBQe86OxyPwjPwbfKAfL63960nc45aFb2T4RGXBAabBEtOyj15sTPsTaPgeWAHu)uW4VG6bgUo6fwQZLAtLALKALKAbsniG1cBGGXUfl6gCdNUri1cK6nfeu8pPo7CPod1icSYqseVrbAdSXBkiS4FsTsjv6pKhj1MMiko8sKAHtxQSYnFPstQCqGvEMgjP(n64grjvqaRfs9tbJ)cQhy46OxyPE0CP2esTaP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1JMl1d)uQfi1V71PBeqQFkySOBWnS5nHILuNTuNHAebwz453gVPsWtUszj1cK63ZWbfhu4SAefsTaP(DVoDJa20erXHxIulmS5nHILupAUulKsQ0FipsQNd8fy3IVcgVPbu6sLzcttLMu5GaR8mnss9B0XnIsQGawlK6Ncg)fupWW1rVWs9O5sTjKAbs9rvooydem2Tyr3GBiheyLNsTaP(DVoDJa2abJDlw0n4g28MqXsQhnxQh(PulqQF3Rt3iGu)uWyr3GByZBcflPoBPod1icSYWZVnEtLGNCLYsQfi1MSu)EgoO4GcNvJOiPs)H8iPEoWxGDl(ky8MgqPlvMjkpvAsLdcSYZ0ij1Vrh3ikPccyTqQFky8xq9adxh9cl1JMl1MqQfi1MSuFuLJd2abJDlw0n4gYbbw5PulqQF3Rt3iGu)uWyr3GByZBcflPoBPod1icSYWZVnEtLGNCLYkPs)H8iPEoWxGDl(ky8MgqPlvMjmrQ0KkheyLNPrsQFJoUrusfeWAHu)uW4VG6bgUo6fwQhnxQnHulqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4Njv6pKhj1Zb(cSBXxbJ30akDPYmHqivAsLdcSYZ0ij1Vrh3ikPQOuBYs9rvooihv0qXXbpHCqGvEk1kOGuROuFuLJdYrfnuCCWtiheyLNsTaPEtbbf)tQZoxQnjMk1kj1kj1cK63960nc45aFb2T4RGXBAabBEtOyj1zl1zOgrGvgsI4nvcEYvklPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cl1cKAqaRf2abJDlw0n4goDJqQfi1BkiO4FsD25sDgQreyLHKiEJc0gyJ3uqyX)sQ0FipsQu)uWyr3G70LkZeM0uPjvoiWkptJKu)gDCJOKkiG1cBGGXUfl6gCdNUri1cK63960nc45aFb2T4RGXBAabBEtOyj1zl1zOgrGvg2UiEtLGNCLYsQfi1GawlK6Ncg)fupWW1rVWsDUudcyTqQFky8xq9ad3uj41rVWsTaPwrP(DVoDJas9tbJfDdUHnVjuSK6SL6YfkPwbfK6jdcyTWZb(cSBXxbJ30accik1kLuP)qEKuBGGXUfl6gCNUuzMqOsLMu5GaR8mnss9B0XnIsQGawlK6Ncg)fupWW1rVWsDUuBQulqQFpdhuCqHZQruKuP)qEKufBEXXZy3I3OyMUuzMWCLknPYbbw5zAKK63OJBeLuNmiG1cph4lWUfFfmEtdiiGOulqQnzP(9mCqXbfoRgrrsL(d5rsvS5fhpJDlEJIz6sLzctsQ0KkheyLNPrsQFJoUrus9DVoDJaYz8NoKhWM3ekwsD2sTPsTaPwrPwrP(OkhhKJkAO44GNqoiWkpLAbs9Mcck(NupAUulKmvQfi1BkiO4FsD25sT5sOKALKAfuqQvuQnzP(OkhhKJkAO44GNqoiWkpLAbs9Mcck(NupAUulKekPwjPwPKk9hYJK6MccpW70LUKk5CQ0uzLNknPYbbw5zAKK63OJBeLuvuQpQYXb5OIgkoo4jKdcSYtPwGuVPGGI)j1JMl1cjtLAbs9Mcck(NuNDUuBUekPwjPwbfKAfLAtwQpQYXb5OIgkoo4jKdcSYtPwGuVPGGI)j1JMl1cjHsQvkPs)H8iPUPGWd8oDPYmrQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GB40nIKk9hYJKAfnuClSqgG5WMJlDPYecPstQCqGvEMgjP(n64grjvqaRfs9tbJfDdUHt3isQ0FipsQG0a2T4RrVWR0LkZKMknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKubwmgD8ELUuzcvQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GBiGysL(d5rsfK7f3cJIH0LkZCLknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKubRUpXwGoR0LkZKKknPYbbw5zAKK63OJBeLubbSwi1pfmw0n4gciMuP)qEKuTOMbRUptxQmHuQ0KkheyLNPrsQFJoUrusfeWAHu)uWyr3GBiGysL(d5rsLINxxtv8t1A6sLz(sLMu5GaR8mnss9B0XnIsQnqWwVhy4XBrVPk2GAriBoairrEMuP)qEKup0MXgulMUuzLBAQ0KkheyLNPrsQFJoUrusTbc269adNO1JeROG6SWVV3umHS5aGef5PulqQF3Rt3iGGawlEIwpsSIcQZc)(EtXe2mnZsQfi1GawlCIwpsSIcQZc)(EtXeBBFDWPBesTaPwrPgeWAHu)uWyr3GB40ncPwGudcyTWgiySBXIUb3WPBesTaPEYGawl8CGVa7w8vW4nnGGt3iKALKAbs97ED6gb8CGVa7w8vW4nnGGnVjuSK6CP2uPwGuROudcyTqQFky8xq9adxh9cl1JMl1zOgrGvgsoJp)24VG6bEj1cKAfLAfL6JQCCWgiySBXIUb3qoiWkpLAbs97ED6gbSbcg7wSOBWnS5nHILupAUup8tPwGu)UxNUraP(PGXIUb3WM3ekwsD2sDgQreyLHNFB8Mkbp5kLLuRKuRGcsTIsTjl1hv54GnqWy3IfDdUHCqGvEk1cK63960nci1pfmw0n4g28MqXsQZwQZqnIaRm88BJ3uj4jxPSKALKAfuqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4NsTssTsjv6pKhjvB7Rd0Rx6sLvE5PstQCqGvEMgjP(n64grjvfL6giyR3dmCIwpsSIcQZc)(EtXeYMdasuKNsTaP(DVoDJaccyT4jA9iXkkOol877nftyZ0mlPwGudcyTWjA9iXkkOol877nftSf1mC6gHulqQfBodE4NWYH22xhOxpPwjPwbfKAfL6giyR3dmCIwpsSIcQZc)(EtXeYMdasuKNsTaP(qBwQZLAtLALsQ0FipsQwuZyWkTU0LkRCtKknPYbbw5zAKK63OJBeLuBGGTEpWWHgTQzHrp6RmKnhaKOipLAbs97ED6gbK6Ncgl6gCdBEtOyj1zl1cbtLAbs97ED6gb8CGVa7w8vW4nnGGnVjuSK6CP2uPwGuROudcyTqQFky8xq9adxh9cl1JMl1zOgrGvgsoJp)24VG6bEj1cKAfLAfL6JQCCWgiySBXIUb3qoiWkpLAbs97ED6gbSbcg7wSOBWnS5nHILupAUup8tPwGu)UxNUraP(PGXIUb3WM3ekwsD2sDgQreyLHNFB8Mkbp5kLLuRKuRGcsTIsTjl1hv54GnqWy3IfDdUHCqGvEk1cK63960nci1pfmw0n4g28MqXsQZwQZqnIaRm88BJ3uj4jxPSKALKAfuqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4NsTssTsjv6pKhjvB7RdhEgkDPYkxiKknPYbbw5zAKK63OJBeLuBGGTEpWWHgTQzHrp6RmKnhaKOipLAbs97ED6gbK6Ncgl6gCdBEtOyj15sTPsTaPwrPwrPwrP(DVoDJaEoWxGDl(ky8MgqWM3ekwsD2sDgQreyLHKiEtLGNCLYsQfi1GawlK6Ncg)fupWW1rVWsDUudcyTqQFky8xq9ad3uj41rVWsTssTcki1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsniG1cP(PGXFb1dmCD0lSupAUuNHAebwzi5m(8BJ)cQh4LuRKuRKulqQbbSwydem2Tyr3GB40ncPwPKk9hYJKQT91HdpdLUuzLBstLMu5GaR8mnss9B0XnIsQnqWwVhy4cjw4bEDEVHS5aGef5PulqQfBodE4NWYHCg)Pd5rsL(d5rs9CGVa7w8vW4nnGsxQSYfQuPjvoiWkptJKu)gDCJOKAdeS17bgUqIfEGxN3BiBoairrEk1cKAfLAXMZGh(jSCiNXF6qEi1kOGul2Cg8WpHLdph4lWUfFfmEtdiPwPKk9hYJKk1pfmw0n4oDPYk3CLknPYbbw5zAKK63OJBeLup0ML6SLAHGPsTaPUbc269adxiXcpWRZ7nKnhaKOipLAbsniG1cP(PGXFb1dmCD0lSupAUuNHAebwzi5m(8BJ)cQh4LulqQF3Rt3iGNd8fy3IVcgVPbeS5nHILuNl1Mk1cK63960nci1pfmw0n4g28MqXsQhnxQh(zsL(d5rsLZ4pDipsxQSYnjPstQCqGvEMgjPs)H8iPYz8NoKhjvuCC3aIhgztQGawlCHel8aVoV3W1rVW5GawlCHel8aVoV3WnvcED0lCsffh3nG4Hr7npr0Xj1YtQFJoUrus9qBwQZwQfcMk1cK6giyR3dmCHel8aVoV3q2CaqII8uQfi1V71PBeqQFkySOBWnS5nHILuNl1Mk1cKAfLAfLAfL63960nc45aFb2T4RGXBAabBEtOyj1zl1zOgrGvgsI4nvcEYvklPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cl1kj1kOGuROu)UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1GawlK6Ncg)fupWW1rVWs9O5sDgQreyLHKZ4ZVn(lOEGxsTssTssTaPgeWAHnqWy3IfDdUHt3iKALsxQSYfsPstQCqGvEMgjP(n64grjvfL63960nci1pfmw0n4g28MqXsQZwQnPcLuRGcs97ED6gbK6Ncgl6gCdBEtOyj1JMl1cbPwjPwGu)UxNUraph4lWUfFfmEtdiyZBcflPoxQnvQfi1kk1GawlK6Ncg)fupWW1rVWs9O5sDgQreyLHKZ4ZVn(lOEGxsTaPwrPwrP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1JMl1d)uQfi1V71PBeqQFkySOBWnS5nHILuNTulusTssTcki1kk1MSuFuLJd2abJDlw0n4gYbbw5PulqQF3Rt3iGu)uWyr3GByZBcflPoBPwOKALKAfuqQF3Rt3iGu)uWyr3GByZBcflPE0CPE4NsTssTsjv6pKhj1nQBVxy3IpV3CCPlvw5MVuPjvoiWkptJKu)gDCJOK67ED6gb8CGVa7w8vW4nnGGnVjuSK6SL6muJiWkd7fEtLGNCLYsQfi1V71PBeqQFkySOBWnS5nHILuNTuNHAebwzyVWBQe8KRuwsTaPwrP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1JMl1d)uQvqbP(OkhhSbcg7wSOBWnKdcSYtPwGu)UxNUraBGGXUfl6gCdBEtOyj1zl1zOgrGvg2l8Mkbp5kLLuRGcsTjl1hv54GnqWy3IfDdUHCqGvEk1kj1cKAqaRfs9tbJ)cQhy46OxyPE0CPod1icSYqYz853g)fupWlPwGupzqaRfEoWxGDl(ky8MgqWPBejv6pKhj1MMiko8sKAHtxQmtyAQ0KkheyLNPrsQFJoUrus9DVoDJaEoWxGDl(ky8MgqWM3ekwsDUuBQulqQvuQbbSwi1pfm(lOEGHRJEHL6rZL6muJiWkdjNXNFB8xq9aVKAbsTIsTIs9rvooydem2Tyr3GBiheyLNsTaP(DVoDJa2abJDlw0n4g28MqXsQhnxQh(PulqQF3Rt3iGu)uWyr3GByZBcflPoBPod1icSYWZVnEtLGNCLYsQvsQvqbPwrP2KL6JQCCWgiySBXIUb3qoiWkpLAbs97ED6gbK6Ncgl6gCdBEtOyj1zl1zOgrGvgE(TXBQe8KRuwsTssTcki1V71PBeqQFkySOBWnS5nHILupAUup8tPwjPwPKk9hYJKAttefhEjsTWPlvMjkpvAsLdcSYZ0ij1Vrh3ikP(UxNUraP(PGXIUb3WM3ekwsDUuBQulqQvuQvuQvuQF3Rt3iGNd8fy3IVcgVPbeS5nHILuNTuNHAebwzijI3uj4jxPSKAbsniG1cP(PGXFb1dmCD0lSuNl1GawlK6Ncg)fupWWnvcED0lSuRKuRGcsTIs97ED6gb8CGVa7w8vW4nnGGnVjuSK6CP2uPwGudcyTqQFky8xq9adxh9cl1JMl1zOgrGvgsoJp)24VG6bEj1kj1kj1cKAqaRf2abJDlw0n4goDJqQvkPs)H8iP20erXHxIulC6sLzctKknPYbbw5zAKK63OJBeLuF3Rt3iGu)uWyr3GByZBcflPoxQnvQfi1kk1kk1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZwQZqnIaRmKeXBQe8KRuwsTaPgeWAHu)uW4VG6bgUo6fwQZLAqaRfs9tbJ)cQhy4MkbVo6fwQvsQvqbPwrP(DVoDJaEoWxGDl(ky8MgqWM3ekwsDUuBQulqQbbSwi1pfm(lOEGHRJEHL6rZL6muJiWkdjNXNFB8xq9aVKALKALKAbsniG1cBGGXUfl6gCdNUri1kLuP)qEKuNmDfGEhC6sLzcHqQ0KkheyLNPrsQFJoUrusfeWAHu)uW4VG6bgUo6fwQhnxQZqnIaRmKCgF(TXFb1d8sQfi1kk1kk1hv54GnqWy3IfDdUHCqGvEk1cK63960ncydem2Tyr3GByZBcflPE0CPE4NsTaP(DVoDJas9tbJfDdUHnVjuSK6SL6muJiWkdp)24nvcEYvklPwjPwbfKAfLAtwQpQYXbBGGXUfl6gCd5GaR8uQfi1V71PBeqQFkySOBWnS5nHILuNTuNHAebwz453gVPsWtUszj1kj1kOGu)UxNUraP(PGXIUb3WM3ekws9O5s9WpLALsQ0FipsQNd8fy3IVcgVPbu6sLzctAQ0KkheyLNPrsQFJoUrusvrPwrP(DVoDJaEoWxGDl(ky8MgqWM3ekwsD2sDgQreyLHKiEtLGNCLYsQfi1GawlK6Ncg)fupWW1rVWsDUudcyTqQFky8xq9ad3uj41rVWsTssTcki1kk1V71PBeWZb(cSBXxbJ30ac28MqXsQZLAtLAbsniG1cP(PGXFb1dmCD0lSupAUuNHAebwzi5m(8BJ)cQh4LuRKuRKulqQbbSwydem2Tyr3GB40nIKk9hYJKk1pfmw0n4oDPYmHqLknPYbbw5zAKK63OJBeLubbSwydem2Tyr3GB40ncPwGuROuROu)UxNUraph4lWUfFfmEtdiyZBcflPoBP2eMk1cKAqaRfs9tbJ)cQhy46OxyPoxQbbSwi1pfm(lOEGHBQe86OxyPwjPwbfKAfL63960nc45aFb2T4RGXBAabBEtOyj15sTPsTaPgeWAHu)uW4VG6bgUo6fwQhnxQZqnIaRmKCgF(TXFb1d8sQvsQvsQfi1kk1V71PBeqQFkySOBWnS5nHILuNTuxUqj1kOGupzqaRfEoWxGDl(ky8MgqqarPwPKk9hYJKAdem2Tyr3G70LkZeMRuPjvoiWkptJKu)gDCJOKkiG1cNmDfGEhmequQfi1tgeWAHNd8fy3IVcgVPbeequQfi1tgeWAHNd8fy3IVcgVPbeS5nHILupAUudcyTqXMxC8m2T4nkMWnvcED0lSul0wQP)qEaP(PGXGvADqUe(bogFOnNuP)qEKufBEXXZy3I3OyMUuzMWKKknPYbbw5zAKK63OJBeLubbSw4KPRa07GHaIsTaPwrPwrP(OkhhS5Lhu8mKdcSYtPwGut)HYWyo4nIxs9OsTjvQvsQvqbPM(dLHXCWBeVK6rLAHsQvkPs)H8iPs9tbJbR06sxQmtiKsLMuP)qEKuxaIChEgkPYbbw5zAK0LkZeMVuPjvoiWkptJKu)gDCJOKkiG1cP(PGXFb1dmCD0lSuNl1MMuP)qEKuP(PGXEdMUuzcbttLMu5GaR8mnss9B0XnIsQkk1nBBEvqGvwQvqbP2KL6d9cJIbPwjPwGudcyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cNuP)qEKud(k4gF8wKxx6sLjekpvAsLdcSYZ0ij1Vrh3ikPccyTqQFkySOBWnC6gHulqQbbSwydem2Tyr3GB40ncPwGupzqaRfEoWxGDl(ky8MgqWPBesTaP(DVoDJas9tbJfDdUHnVjuSK6SLAtLAbs97ED6gb8CGVa7w8vW4nnGGnVjuSK6SLAtLAbsTIsTjl1hv54GnqWy3IfDdUHCqGvEk1kOGuROuFuLJd2abJDlw0n4gYbbw5PulqQF3Rt3iGnqWy3IfDdUHnVjuSK6SLAtLALKALsQ0FipsQRcK9qXaw0n4oDPYecMivAsLdcSYZ0ij1Vrh3ikPccyTWVYu)06qXaSz6pPwGu3abB9EGHu)uWyuyrb6YcYMdasuKNsTaP(OkhhK2IvKf90H8aYbbw5PulqQP)qzymh8gXlPEuP2KMuP)qEKuP(PGXB0AHQ8kDPYeccHuPjvoiWkptJKu)gDCJOKkiG1cP(PGXFb1dmCD0lSupQudcyTqQFky8xq9ad3uj41rVWjv6pKhjvQFkymxIy1xipsxQmHGjnvAsLdcSYZ0ij1Vrh3ikPccyTqQFky8xq9adxh9cl15sniG1cP(PGXFb1dmCtLGxh9cNuP)qEKuP(PGXGu30aNUuzcbHkvAsffh3nG4Hr2K6Mcck(x25cjHkPIIJ7gq8WO9MNi64KA5jv6pKhjvoJ)0H8iPYbbw5zAK0LUK62ZWBoUuPPYkpvAsLdcSYZ0ij1Vrh3ikPU9m8MJdorRJINL6SZL6YnnPs)H8iPcwrHWPlvMjsLMuP)qEKufBEXXZy3I3OyMu5GaR8mns6sLjesLMu5GaR8mnss9B0XnIsQBpdV54Gt06O4zPEuPUCttQ0FipsQu)uW4nATqvELUuzM0uPjv6pKhjvQFkyS3GjvoiWkptJKU0LuTOGQyqGosLMkR8uPjvoiWkptJKuP)qEKuP(PGXB0AHQ8kP(feksQLNu)gDCJOKkiG1c)kt9tRdfdWMP)sxQmtKknPs)H8iPs9tbJbR06sQCqGvEMgjDPYecPstQ0FipsQu)uWyqQBAGtQCqGvEMgjDPlDj1mCVqEKkZeMActl3utfsWYtQguhOyyLun3vOxiBzcnltiscXsTuxAbl1OTO3NuB9wQnV2p6qEyEsDZMdaQ5PuV8nl1eW5B64Pu)fumWlO0mHouWsD5cXsT5Mhz4(4PuRI2MBs9kR4OsKAHgk1Nl1cDaKuprzqlKhsTlYnDEl1koMssTILxIsqPzcDOGLAHsiwQn38id3hpLAZ79mCqXbfYHCqGvEAEs95sT59EgoO4Gc5MNuRy5LOeuAM0mZDf6fYwMqZYeIKqSul1LwWsnAl69j1wVLAZtS533G0zEsDZMdaQ5PuV8nl1eW5B64Pu)fumWlO0mHouWsTqqiwQn38id3hpLAZ79mCqXbfYHCqGvEAEs95sT59EgoO4Gc5MNuRy5LOeuAMqhkyP2Kkel1MBEKH7JNsT59EgoO4Gc5qoiWkpnpP(CP28EpdhuCqHCZtQvS8suckntOdfSuxE5cXsT5Mhz4(4PuBEVNHdkoOqoKdcSYtZtQpxQnV3ZWbfhui38KAflVeLGsZe6qbl1LlucXsT5Mhz4(4PuBEVNHdkoOqoKdcSYtZtQpxQnV3ZWbfhui38KAflVeLGsZKMzURqVq2YeAwMqKeILAPU0cwQrBrVpP26TuBEV71PBelZtQB2CaqnpL6LVzPMaoFthpL6VGIbEbLMj0HcwQl38jel1MBEKH7JNsT59EgoO4Gc5qoiWkpnpP(CP28EpdhuCqHCZtQvS8suckntOdfSuBctfILAZnpYW9XtP28EpdhuCqHCiheyLNMNuFUuBEVNHdkoOqU5j1kwEjkbLMj0HcwQnHqjel1MBEKH7JNsT59EgoO4Gc5qoiWkpnpP(CP28EpdhuCqHCZtQvS8suckntOdfSuBcZLqSuBU5rgUpEk1M37z4GIdkKd5GaR808K6ZLAZ79mCqXbfYnpPwXYlrjO0mPzcn3IEF8uQnFsn9hYdPUIw3cknlPk2Ufv5KQ5xQfAanWsTqF)uWsZm)sTqe)5GCl1MpLLAtyQjmvAM0m6pKhlOyZVVbPlpd1icSYkh0MZfBweOwXCgxzxmFXNYzOkaNBQ0m6pKhlOyZVVbPB88XYqnIaRSYbT5CXMfbQvmNXv2fZx8PCgQcW5LRmYM3abB9EGHlKyHh4159gYMdasuKNcO)qzymh8gXRSnH0m6pKhlOyZVVbPB88XYqnIaRSYbT5CXMfbQvmNXv2fZx8PCgQcW5LRmYM3abB9EGHlKyHh4159gYMdasuKNcEpdhuCWG)2REpHCqGvEkG(dLHXCWBeVYUCPz0FipwqXMFFds345JLHAebwzLdAZ5InlcuRyoJRSlMV4t5mufGZlxzKnVbc269adxiXcpWRZ7nKnhaKOipf8EgoO4GbAO4WwIHCqGvEknZ8l10FipwqXMFFds345JLHAebwzLdAZ5fugg7ICWtLDX8fFkNHQaCUPsZm)sn9hYJfuS533G0nE(yzOgrGvw5G2CEbLHXUih8uzxmFXNYzOkaNxUYiBo9hkdJ5G3iELTjKMz(LA6pKhlOyZVVbPB88XYqnIaRSYbT58ckdJDro4PYUy(IpLZqvaoVCLr28muJiWkdfBweOwXCgpVCPz0FipwqXMFFds345JLHAebwzLdAZ5wuqvmiqhk7I5l(uodvb4CtLMr)H8ybfB(9niDJNpwgQreyLvoOnN3l8Mkbp5kLLYUy(IpLZqvaoxOKMr)H8ybfB(9niDJNpwgQreyLvoOnNtI4nvcEYvklLDX8fFkNHQaCE5MknJ(d5Xck287Bq6gpFSmuJiWkRCqBoVDr8Mkbp5kLLYUy(IpLZqvao3eMknJ(d5Xck287Bq6gpFSmuJiWkRCqBo)8BJ3uj4jxPSu2fZx8PCgQcW5cL0m6pKhlOyZVVbPB88XYqnIaRSYbT58ZVnEtLGNCLYszxmFXNYzOkaNleugzZBGGTEpWWjA9iXkkOol877nftiBoairrEknJ(d5Xck287Bq6gpFSmuJiWkRCqBo)8BJ3uj4jxPSu2fZx8PCgQcW5LlukJS5VNHdkoyGgkoSLyiheyLNsZO)qESGIn)(gKUXZhld1icSYkh0MZp)24nvcEYvklLDX8fFkNHQaCE5cLYiB(7XeaDqQFkySy7t0qwqoiWkpfq)HYWyo4nIxJkeKMz(L6rSc9sT5EPwilV9mSul0rh3sZO)qESGIn)(gKUXZhld1icSYkh0MZp)24nvcEYvklLDX8fFkNHQaCUqWuLr2CET44zyg0c5b2TyrUT8FipGBu4T0m6pKhlOyZVVbPB88XYqnIaRSYbT5CqQBAGXBkiS4Fk7I5l(uodvb4CZNPsZO)qESGIn)(gKUXZhld1icSYkh0MZbPUPbgVPGWI)PSlMV4t5mufGZfsMQmYM)EgoO4GbAO4WwIHCqGvEknJ(d5Xck287Bq6gpFSmuJiWkRCqBoNeXBuG2aB8Mccl(NYUy(IpLZqvaoxiyQ0m6pKhlOyZVVbPB88XYqnIaRSYbT5CseVrbAdSXBkiS4Fk7I5l(uodvb4CHYuLr28giyR3dmCIwpsSIcQZc)(EtXeYMdasuKNsZO)qESGIn)(gKUXZhld1icSYkh0MZjr8gfOnWgVPGWI)PSlMV4t5mufGZfktvgzZBGGTEpWWHgTQzHrp6RmKnhaKOipLMr)H8ybfB(9niDJNpwgQreyLvoOnNtoJp)24VG6bEPSlMV4t5mufGZnH0m6pKhlOyZVVbPB88XO(PGXwAJQiQLMr)H8ybfB(9niDJNpg1pfmgfhxR8FsZO)qESGIn)(gKUXZh79qidqZ4nfeEG3sZO)qESGIn)(gKUXZhBJ62BmAtdS0m6pKhlOyZVVbPB88Xe9d5H0m6pKhlOyZVVbPB88XSTVoqVEkJS5zOgrGvgk2SiqTI5mEUPcAGGTEpWWjA9iXkkOol877nftiBoairrEk4DVoDJaccyT4jA9iXkkOol877nftyZ0mlbGawlCIwpsSIcQZc)(EtXeBBFDWPBesZO)qESGIn)(gKUXZhJZ4pDipugzZZqnIaRmuSzrGAfZz88YLMjnZ8l1M7Se(boEk1CgUZsQp0ML6RGLA6pVLA0sQPmeQsGvgknJ(d5Xk)DG44EjY1QYiB(r9aFWjdcyTWNwhkgGnt)jnZ8l1Jyf6LAZ9sTqwE7zyPwOJoULMr)H8ynE(ypvRy6pKh4kADkh0MZ51IJNxsZO)qESgpFSNQvm9hYdCfToLdAZ5KZkJS50FOmmMdEJ4v2MqAg9hYJ145J9uTIP)qEGRO1PCqBo3f5GBLr28muJiWkdlOmm2f5GN5MknJ(d5XA88XEQwX0FipWv06uoOnN)UxNUrSKMr)H8ynE(ypvRy6pKh4kADkh0MZB)Od5HYiBEgQreyLHwuqvmiqh5MknJ(d5XA88XEQwX0FipWv06uoOnNBrbvXGaDOmYMNHAebwzOffufdc0rE5sZO)qESgpFSNQvm9hYdCfToLdAZ5BpdV54KMjnJ(d5XcsoNdSy8MccpWBLr2CfpQYXb5OIgkoo4jKdcSYtbBkiO4FJMlKmvWMcck(x25MlHsjfuqrt(OkhhKJkAO44GNqoiWkpfSPGGI)nAUqsOusAg9hYJfKCE88XQOHIBHfYamh2CCkJS5GawlK6Ncgl6gCdNUrinJ(d5XcsopE(yG0a2T4RrVWlLr2CqaRfs9tbJfDdUHt3iKMr)H8ybjNhpFmGfJrhVxkJS5GawlK6Ncgl6gCdbeLMr)H8ybjNhpFmqUxClmkgugzZbbSwi1pfmw0n4gciknJ(d5XcsopE(yGv3NylqNLYiBoiG1cP(PGXIUb3qarPz0FipwqY5XZhZIAgS6(uzKnheWAHu)uWyr3GBiGO0m6pKhli5845JrXZRRPk(PAvzKnheWAHu)uWyr3GBiGO0m6pKhli5845JDOnJnOwuzKnVbc269adpEl6nvXgulczZbajkYtPz0FipwqY5XZhZ2(6a96PmYM3abB9EGHt06rIvuqDw433BkMq2CaqII8uW7ED6gbeeWAXt06rIvuqDw433BkMWMPzwcabSw4eTEKyffuNf(99MIj22(6Gt3ieOiiG1cP(PGXIUb3WPBecabSwydem2Tyr3GB40ncbtgeWAHNd8fy3IVcgVPbeC6gHscE3Rt3iGNd8fy3IVcgVPbeS5nHIvUPcueeWAHu)uW4VG6bgUo6fE08muJiWkdjNXNFB8xq9aVeOOIhv54GnqWy3IfDdUHCqGvEk4DVoDJa2abJDlw0n4g28MqXA08HFk4DVoDJas9tbJfDdUHnVjuSYod1icSYWZVnEtLGNCLYsjfuqrt(OkhhSbcg7wSOBWnKdcSYtbV71PBeqQFkySOBWnS5nHIv2zOgrGvgE(TXBQe8KRuwkPGcV71PBeqQFkySOBWnS5nHI1O5d)ujLKMr)H8ybjNhpFmlQzmyLwNYiBUInqWwVhy4eTEKyffuNf(99MIjKnhaKOipf8UxNUrabbSw8eTEKyffuNf(99MIjSzAMLaqaRforRhjwrb1zHFFVPyITOMHt3iei2Cg8WpHLdTTVoqVEkPGck2abB9EGHt06rIvuqDw433BkMq2CaqII8uWH2CUPkjnJ(d5XcsopE(y22xho8mKYiBEdeS17bgo0Ovnlm6rFLHS5aGef5PG3960nci1pfmw0n4g28MqXkBHGPcE3Rt3iGNd8fy3IVcgVPbeS5nHIvUPcueeWAHu)uW4VG6bgUo6fE08muJiWkdjNXNFB8xq9aVeOOIhv54GnqWy3IfDdUHCqGvEk4DVoDJa2abJDlw0n4g28MqXA08HFk4DVoDJas9tbJfDdUHnVjuSYod1icSYWZVnEtLGNCLYsjfuqrt(OkhhSbcg7wSOBWnKdcSYtbV71PBeqQFkySOBWnS5nHIv2zOgrGvgE(TXBQe8KRuwkPGcV71PBeqQFkySOBWnS5nHI1O5d)ujLKMr)H8ybjNhpFmB7RdhEgszKnVbc269adhA0QMfg9OVYq2CaqII8uW7ED6gbK6Ncgl6gCdBEtOyLBQafvuX3960nc45aFb2T4RGXBAabBEtOyLDgQreyLHKiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0l8O5zOgrGvgsoJp)24VG6bEPKscabSwydem2Tyr3GB40ncLKMz(L6sfIWChcriel1MBvMcPgquQVcEXsTQQuZzCPUIcEjnJ(d5XcsopE(yNd8fy3IVcgVPbKYiBEdeS17bgUqIfEGxN3BiBoairrEkqS5m4HFclhYz8NoKhsZO)qESGKZJNpg1pfmw0n4wzKnVbc269adxiXcpWRZ7nKnhaKOipfOOyZzWd)ewoKZ4pDipuqbXMZGh(jSC45aFb2T4RGXBAaPK0m6pKhli5845JXz8NoKhkJS5hAZzlemvqdeS17bgUqIfEGxN3BiBoairrEkaeWAHu)uW4VG6bgUo6fE08muJiWkdjNXNFB8xq9aVe8UxNUraph4lWUfFfmEtdiyZBcfRCtf8UxNUraP(PGXIUb3WM3ekwJMp8tPz0FipwqY5XZhJZ4pDipugzZp0MZwiyQGgiyR3dmCHel8aVoV3q2CaqII8uW7ED6gbK6Ncgl6gCdBEtOyLBQafvuX3960nc45aFb2T4RGXBAabBEtOyLDgQreyLHKiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0l8O5zOgrGvgsoJp)24VG6bEPKscabSwydem2Tyr3GB40ncLugfh3nG4Hr2CqaRfUqIfEGxN3B46Ox4CqaRfUqIfEGxN3B4MkbVo6fwzuCC3aIhgT38erhNxU0m6pKhli5845JTrD79c7w859MJtzKnxX3960nci1pfmw0n4g28MqXkBtQqPGcV71PBeqQFkySOBWnS5nHI1O5cbLe8UxNUraph4lWUfFfmEtdiyZBcfRCtfOiiG1cP(PGXFb1dmCD0l8O5zOgrGvgsoJp)24VG6bEjqrfpQYXbBGGXUfl6gCd5GaR8uW7ED6gbSbcg7wSOBWnS5nHI1O5d)uW7ED6gbK6Ncgl6gCdBEtOyLTqPKckOOjFuLJd2abJDlw0n4gYbbw5PG3960nci1pfmw0n4g28MqXkBHsjfu4DVoDJas9tbJfDdUHnVjuSgnF4NkPK0m6pKhli5845J10erXHxIulSYiB(7ED6gb8CGVa7w8vW4nnGGnVjuSYod1icSYWEH3uj4jxPSe8UxNUraP(PGXIUb3WM3ekwzNHAebwzyVWBQe8KRuwcu8OkhhSbcg7wSOBWnKdcSYtbV71PBeWgiySBXIUb3WM3ekwJMp8tfu4OkhhSbcg7wSOBWnKdcSYtbV71PBeWgiySBXIUb3WM3ekwzNHAebwzyVWBQe8KRuwkOGjFuLJd2abJDlw0n4gYbbw5PscabSwi1pfm(lOEGHRJEHhnpd1icSYqYz853g)fupWlbtgeWAHNd8fy3IVcgVPbeC6gH0m6pKhli5845J10erXHxIulSYiB(7ED6gb8CGVa7w8vW4nnGGnVjuSYnvGIGawlK6Ncg)fupWW1rVWJMNHAebwzi5m(8BJ)cQh4Lafv8OkhhSbcg7wSOBWnKdcSYtbV71PBeWgiySBXIUb3WM3ekwJMp8tbV71PBeqQFkySOBWnS5nHIv2zOgrGvgE(TXBQe8KRuwkPGckAYhv54GnqWy3IfDdUHCqGvEk4DVoDJas9tbJfDdUHnVjuSYod1icSYWZVnEtLGNCLYsjfu4DVoDJas9tbJfDdUHnVjuSgnF4NkPK0m6pKhli5845J10erXHxIulSYiB(7ED6gbK6Ncgl6gCdBEtOyLBQafvuX3960nc45aFb2T4RGXBAabBEtOyLDgQreyLHKiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0l8O5zOgrGvgsoJp)24VG6bEPKscabSwydem2Tyr3GB40ncLKMr)H8ybjNhpFSjtxbO3bRmYM)UxNUraP(PGXIUb3WM3ekw5Mkqrfv8DVoDJaEoWxGDl(ky8MgqWM3ekwzNHAebwzijI3uj4jxPSeacyTqQFky8xq9adxh9cNdcyTqQFky8xq9ad3uj41rVWkPGck(UxNUraph4lWUfFfmEtdiyZBcfRCtfacyTqQFky8xq9adxh9cpAEgQreyLHKZ4ZVn(lOEGxkPKaqaRf2abJDlw0n4goDJqjPz0FipwqY5XZh7CGVa7w8vW4nnGugzZbbSwi1pfm(lOEGHRJEHhnpd1icSYqYz853g)fupWlbkQ4rvooydem2Tyr3GBiheyLNcE3Rt3iGnqWy3IfDdUHnVjuSgnF4NcE3Rt3iGu)uWyr3GByZBcfRSZqnIaRm88BJ3uj4jxPSusbfu0KpQYXbBGGXUfl6gCd5GaR8uW7ED6gbK6Ncgl6gCdBEtOyLDgQreyLHNFB8Mkbp5kLLskOW7ED6gbK6Ncgl6gCdBEtOynA(WpvsAg9hYJfKCE88XO(PGXIUb3kJS5kQ47ED6gb8CGVa7w8vW4nnGGnVjuSYod1icSYqseVPsWtUszjaeWAHu)uW4VG6bgUo6foheWAHu)uW4VG6bgUPsWRJEHvsbfu8DVoDJaEoWxGDl(ky8MgqWM3ekw5MkaeWAHu)uW4VG6bgUo6fE08muJiWkdjNXNFB8xq9aVusjbGawlSbcg7wSOBWnC6gH0m6pKhli5845J1abJDlw0n4wzKnheWAHnqWy3IfDdUHt3ieOOIV71PBeWZb(cSBXxbJ30ac28MqXkBtyQaqaRfs9tbJ)cQhy46Ox4CqaRfs9tbJ)cQhy4MkbVo6fwjfuqX3960nc45aFb2T4RGXBAabBEtOyLBQaqaRfs9tbJ)cQhy46Ox4rZZqnIaRmKCgF(TXFb1d8sjLeO47ED6gbK6Ncgl6gCdBEtOyLD5cLckmzqaRfEoWxGDl(ky8MgqqarLKMr)H8ybjNhpFmXMxC8m2T4nkMkJS5GawlCY0va6DWqarbtgeWAHNd8fy3IVcgVPbeequWKbbSw45aFb2T4RGXBAabBEtOynAoiG1cfBEXXZy3I3Oyc3uj41rVWcTP)qEaP(PGXGvADqUe(bogFOnlnJ(d5XcsopE(yu)uWyWkToLr2CqaRfoz6ka9oyiGOafv8OkhhS5Lhu8mKdcSYtb0FOmmMdEJ41OMuLuqb6puggZbVr8AuHsjPz0FipwqY5XZhBbiYD4ziPz0FipwqY5XZhJ6Ncg7nOYiBoiG1cP(PGXFb1dmCD0lCUPsZO)qESGKZJNpwWxb34J3I86ugzZvSzBZRccSYkOGjFOxyumOKaqaRfs9tbJ)cQhy46Ox4CqaRfs9tbJ)cQhy4MkbVo6fwAg9hYJfKCE88Xwfi7HIbSOBWTYiBoiG1cP(PGXIUb3WPBecabSwydem2Tyr3GB40ncbtgeWAHNd8fy3IVcgVPbeC6gHG3960nci1pfmw0n4g28MqXkBtf8UxNUraph4lWUfFfmEtdiyZBcfRSnvGIM8rvooydem2Tyr3GBiheyLNkOGIhv54GnqWy3IfDdUHCqGvEk4DVoDJa2abJDlw0n4g28MqXkBtvsjPz0FipwqY5XZhJ6NcgVrRfQYlLr2CqaRf(vM6NwhkgGnt)jObc269adP(PGXOWIc0LfKnhaKOipfCuLJdsBXkYIE6qEa5GaR8ua9hkdJ5G3iEnQjvAg9hYJfKCE88XO(PGXCjIvFH8qzKnheWAHu)uW4VG6bgUo6fEuqaRfs9tbJ)cQhy4MkbVo6fwAg9hYJfKCE88XO(PGXGu30aRmYMdcyTqQFky8xq9adxh9cNdcyTqQFky8xq9ad3uj41rVWsZO)qESGKZJNpgNXF6qEOmkoUBaXdJS5BkiO4FzNlKekLrXXDdiEy0EZteDCE5sZKMr)H8ybF3Rt3iw5v0qXTWczaMdBooLr2CqaRfs9tbJfDdUHt3ieacyTWgiySBXIUb3WPBecMmiG1cph4lWUfFfmEtdi40ncPz0FipwW3960nI145Jbsdy3IVg9cVugzZbbSwi1pfmw0n4goDJqaiG1cBGGXUfl6gCdNUriyYGawl8CGVa7w8vW4nnGGt3iKMr)H8ybF3Rt3iwJNpgWIXOJ3lLr2CqaRfs9tbJfDdUHaIsZO)qESGV71PBeRXZhdK7f3cJIbLr2CqaRfs9tbJfDdUHaIsZO)qESGV71PBeRXZhdS6(eBb6SugzZbbSwi1pfmw0n4gciknJ(d5Xc(UxNUrSgpFmlQzWQ7tLr2CqaRfs9tbJfDdUHaIsZO)qESGV71PBeRXZhJINxxtv8t1QYiBoiG1cP(PGXIUb3qarPzMFPwiYAK3OdjeLLAGfkgK6HgTQzj1Oh9vwQnqxHutIqPwO1ILA0j1gORqQp)2sTFfCBGwmuQLMr)H8ybF3Rt3iwJNpMT91HdpdPmYM3abB9EGHdnAvZcJE0xziBoairrEk4DVoDJas9tbJfDdUHnVjuSYwiyQG3960nc45aFb2T4RGXBAabBEtOyLBQafbbSwi1pfm(lOEGHRJEHhn3ecuuXJQCCWgiySBXIUb3qoiWkpf8UxNUraBGGXUfl6gCdBEtOynA(Wpf8UxNUraP(PGXIUb3WM3ekwzNHAebwz453gVPsWtUszPKckOOjFuLJd2abJDlw0n4gYbbw5PG3960nci1pfmw0n4g28MqXk7muJiWkdp)24nvcEYvklLuqH3960nci1pfmw0n4g28MqXA08HFQKssZO)qESGV71PBeRXZhZ2(6WHNHugzZBGGTEpWWHgTQzHrp6RmKnhaKOipf8UxNUraP(PGXIUb3WM3ekw5Mkqrt(OkhhKJkAO44GNqoiWkpvqbfpQYXb5OIgkoo4jKdcSYtbBkiO4FzNBsmvjLeOOIV71PBeWZb(cSBXxbJ30ac28MqXk7YnvaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0lCUPkPKaqaRf2abJDlw0n4goDJqWMcck(x25zOgrGvgsI4nkqBGnEtbHf)tAg9hYJf8DVoDJynE(y22xhOxpLr28giyR3dmCIwpsSIcQZc)(EtXeYMdasuKNcE3Rt3iGGawlEIwpsSIcQZc)(EtXe2mnZsaiG1cNO1JeROG6SWVV3umX22xhC6gHafbbSwi1pfmw0n4goDJqaiG1cBGGXUfl6gCdNUriyYGawl8CGVa7w8vW4nnGGt3iusW7ED6gb8CGVa7w8vW4nnGGnVjuSYnvGIGawlK6Ncg)fupWW1rVWJMBcbkQ4rvooydem2Tyr3GBiheyLNcE3Rt3iGnqWy3IfDdUHnVjuSgnF4NcE3Rt3iGu)uWyr3GByZBcfRSZqnIaRm88BJ3uj4jxPSusbfu0KpQYXbBGGXUfl6gCd5GaR8uW7ED6gbK6Ncgl6gCdBEtOyLDgQreyLHNFB8Mkbp5kLLskOW7ED6gbK6Ncgl6gCdBEtOynA(WpvsjPz0FipwW3960nI145JzrnJbR06ugzZBGGTEpWWjA9iXkkOol877nftiBoairrEk4DVoDJaccyT4jA9iXkkOol877nftyZ0mlbGawlCIwpsSIcQZc)(EtXeBrndNUriqS5m4HFclhABFDGE9KMz(LAH(QbL1sQbwSuVrD79sQnqxHutIqPwOPvQp)2snAj1ntZSKAAj1gCTQSuVjHzPEb0SuFUu)06KA0j1GS1BwQp)2qPz0FipwW3960nI145JTrD79c7w859MJtzKn)DVoDJaEoWxGDl(ky8MgqWM3ekw5MkaeWAHu)uW4VG6bgUo6fE0Cti4DVoDJas9tbJfDdUHnVjuSgnF4NsZO)qESGV71PBeRXZhBJ627f2T4Z7nhNYiB(7ED6gbK6Ncgl6gCdBEtOyLBQafn5JQCCqoQOHIJdEc5GaR8ubfu8OkhhKJkAO44GNqoiWkpfSPGGI)LDUjXuLusGIk(UxNUraph4lWUfFfmEtdiyZBcfRSZqnIaRmKeXBQe8KRuwcabSwi1pfm(lOEGHRJEHZbbSwi1pfm(lOEGHBQe86OxyLuqbfF3Rt3iGNd8fy3IVcgVPbeS5nHIvUPcabSwi1pfm(lOEGHRJEHZnvjLeacyTWgiySBXIUb3WPBec2uqqX)Yopd1icSYqseVrbAdSXBkiS4FsZm)sTqF1GYAj1alwQNmDfGEhSuBGUcPMeHsTqtRuF(TLA0sQBMMzj10sQn4AvzPEtcZs9cOzP(CP(P1j1OtQbzR3SuF(THsZO)qESGV71PBeRXZhBY0va6DWkJS5V71PBeWZb(cSBXxbJ30ac28MqXk3ubGawlK6Ncg)fupWW1rVWJMBcbV71PBeqQFkySOBWnS5nHI1O5d)uAg9hYJf8DVoDJynE(ytMUcqVdwzKn)DVoDJas9tbJfDdUHnVjuSYnvGIM8rvooihv0qXXbpHCqGvEQGckEuLJdYrfnuCCWtiheyLNc2uqqX)Yo3KyQskjqrfF3Rt3iGNd8fy3IVcgVPbeS5nHIv2LBQaqaRfs9tbJ)cQhy46Ox4CqaRfs9tbJ)cQhy4MkbVo6fwjfuqX3960nc45aFb2T4RGXBAabBEtOyLBQaqaRfs9tbJ)cQhy46Ox4CtvsjbGawlSbcg7wSOBWnC6gHGnfeu8VSZZqnIaRmKeXBuG2aB8Mccl(N0mZVuxQqeM7qicHyPwvKAHL63Jj6qESKAR3sDZlpO4zPMIPuhNul0AXs9sKAHLAKvQp)2snftPMeLAQzP2dP(NsnftP2WdZ7KAqwQbeLAR3sD1JbUL6RGcP(kyPEtLi1tUszPSuVjHrXGuVaAwQnyPUGYWsnDsDLP1j1NHl1u)uWs9xq9aVKAkMs9vqNuF(TLAdAfM3j1czawNudS4juAg9hYJf8DVoDJynE(ynnruC4Li1cRmYM)UxNUraph4lWUfFfmEtdiyZBcfRSZqnIaRmSx4nvcEYvklbV71PBeqQFkySOBWnS5nHIv2zOgrGvg2l8Mkbp5kLLafpQYXbBGGXUfl6gCd5GaR8uW7ED6gbSbcg7wSOBWnS5nHI1O5d)ubfoQYXbBGGXUfl6gCd5GaR8uW7ED6gbSbcg7wSOBWnS5nHIv2zOgrGvg2l8Mkbp5kLLckyYhv54GnqWy3IfDdUHCqGvEQKaqaRfs9tbJ)cQhy46Ox4SnHGjdcyTWZb(cSBXxbJ30acoDJqAM5xQfATyPEjsTWsTb6kKAsuQnk4qQf91cbwzOul00k1NFBPgTK6MPzwsnTKAdUwvwQ3KWSuVaAwQpxQFADsn6KAq26nl1NFBO0m6pKhl47ED6gXA88XAAIO4WlrQfwzKn)DVoDJaEoWxGDl(ky8MgqWM3ekw5MkaeWAHu)uW4VG6bgUo6fE0Cti4DVoDJas9tbJfDdUHnVjuSgnF4NsZO)qESGV71PBeRXZhRPjIIdVePwyLr283960nci1pfmw0n4g28MqXk3ubkQOjFuLJdYrfnuCCWtiheyLNkOGIhv54GCurdfhh8eYbbw5PGnfeu8VSZnjMQKscuuX3960nc45aFb2T4RGXBAabBEtOyLDgQreyLHKiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0lCUPkPKaqaRf2abJDlw0n4goDJqWMcck(x25zOgrGvgsI4nkqBGnEtbHf)tjPzMFPwOXSAefcXsTqRfl1NFBPgzLAsuQrlP2dP(NsnftP2WdZ7KAqwQbeLAR3sD1JbUL6RGcP(kyPEtLi1tUszbLAH(kAiKAd0vi1Tlk1iRuFfSuFuLJtQrlP(iH5ak1crUxNsnj1GOtQpxQ3KWSuVaAwQnyP(PqQfYQk1O9MNi64AwsnzpUL6ZVTuZXCjnJ(d5Xc(UxNUrSgpFSZb(cSBXxbJ30aszKnheWAHu)uW4VG6bgUo6fE0Cti4OkhhSbcg7wSOBWnKdcSYtbV71PBeWgiySBXIUb3WM3ekwJMp8tbV71PBeqQFkySOBWnS5nHIv2zOgrGvgE(TXBQe8KRuwcEpdhuCqHZQrua5GaR8uW7ED6gbSPjIIdVePwyyZBcfRrZfssZm)sDzEyUxOXSAefcXsTqRfl1NFBPgzLAsuQrlP2dP(NsnftP2WdZ7KAqwQbeLAR3sD1JbUL6RGcP(kyPEtLi1tUszbLAH(kAiKAd0vi1Tlk1iRuFfSuFuLJtQrlP(iH5aknJ(d5Xc(UxNUrSgpFSZb(cSBXxbJ30aszKnheWAHu)uW4VG6bgUo6fE0Cti4OkhhSbcg7wSOBWnKdcSYtbV71PBeWgiySBXIUb3WM3ekwJMp8tbV71PBeqQFkySOBWnS5nHIv2zOgrGvgE(TXBQe8KRuwcm53ZWbfhu4SAefqoiWkpLMr)H8ybF3Rt3iwJNp25aFb2T4RGXBAaPmYMdcyTqQFky8xq9adxh9cpAUjeyYhv54GnqWy3IfDdUHCqGvEk4DVoDJas9tbJfDdUHnVjuSYod1icSYWZVnEtLGNCLYsAg9hYJf8DVoDJynE(yNd8fy3IVcgVPbKYiBoiG1cP(PGXFb1dmCD0l8O5MqW7ED6gbK6Ncgl6gCdBEtOynA(WpLMz(LAHwlwQjrPgzL6ZVTuJwsThs9pLAkMsTHhM3j1GSudik1wVL6QhdCl1xbfs9vWs9MkrQNCLYszPEtcJIbPEb0SuFf0j1gSuxqzyPMdhyOqQ3uqsnftP(kOtQVcUzPgTK6WpPMQntZSKAsQBGGLA3k1IUb3s90ncO0m6pKhl47ED6gXA88XO(PGXIUb3kJS5kAYhv54GCurdfhh8eYbbw5PckO4rvooihv0qXXbpHCqGvEkytbbf)l7CtIPkPKG3960nc45aFb2T4RGXBAabBEtOyLDgQreyLHKiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9claeWAHnqWy3IfDdUHt3ieSPGGI)LDEgQreyLHKiEJc0gyJ3uqyX)KMz(LAHwlwQBxuQrwP(8Bl1OLu7Hu)tPMIPuB4H5Dsnil1aIsT1BPU6Xa3s9vqHuFfSuVPsK6jxPSuwQ3KWOyqQxanl1xb3SuJwH5DsnvBMMzj1Ku3abl1t3iKAkMs9vqNutIsTHhM3j1G87BwQPmeQsGvwQNankgK6giyO0m6pKhl47ED6gXA88XAGGXUfl6gCRmYMdcyTWgiySBXIUb3WPBecE3Rt3iGNd8fy3IVcgVPbeS5nHIv2zOgrGvg2UiEtLGNCLYsaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9clqX3960nci1pfmw0n4g28MqXk7YfkfuyYGawl8CGVa7w8vW4nnGGaIkjnZ8l1cnMvJOqiwQfYQk1OLuVPGK6cGyOZsQPyk1c9Jysxsn1SuFUl1CjICSqzyP(CPgyXsTOVL6ZL6L5aWSquwQPqQ5sUMKAcuQrHuFfSuF(TLAdumDdOul0XN5TKAGfl1OtQpxQ3KWSuxDdP(lOEGLAH(rwsnkwhfhuAg9hYJf8DVoDJynE(yInV44zSBXBumvgzZbbSwi1pfm(lOEGHRJEHZnvW7z4GIdkCwnIciheyLNsZm)sDzEyUxOXSAefcXsTqRfl1I(wQpxQxMdaZcrzPMcPMl5AsQjqPgfs9vWs953wQnqX0nGsZO)qESGV71PBeRXZhtS5fhpJDlEJIPYiB(KbbSw45aFb2T4RGXBAabbefyYVNHdkoOWz1ikGCqGvEknJ(d5Xc(UxNUrSgpFmGfJ3uq4bERmYM)UxNUra5m(thYdyZBcfRSnvGIkEuLJdYrfnuCCWtiheyLNc2uqqX)gnxizQGnfeu8VSZnxcLskOGIM8rvooihv0qXXbpHCqGvEkytbbf)B0CHKqPKssZKMz(L6rSc9sT5EPwilV9mSul0rh3sZO)qESG8AXXZRCWQ7tSBXxbJ5G3zPmYM)UxNUraph4lWUfFfmEtdiyZBcfRCtfacyTqQFky8xq9adxh9cpAUje8UxNUraP(PGXIUb3WM3ekwJMp8tfu4OEGp4H2m(C8eXJ(UxNUraP(PGXIUb3WM3ekwsZO)qESG8AXXZRXZhdS6(e7w8vWyo4DwkJS5V71PBeqQFkySOBWnS5nHIvUPcu0KpQYXb5OIgkoo4jKdcSYtfuqXJQCCqoQOHIJdEc5GaR8uWMcck(x25MetvsjbkQ47ED6gb8CGVa7w8vW4nnGGnVjuSYUCtfacyTqQFky8xq9adxh9cNdcyTqQFky8xq9ad3uj41rVWkPGck(UxNUraph4lWUfFfmEtdiyZBcfRCtfacyTqQFky8xq9adxh9cNBQskjaeWAHnqWy3IfDdUHt3ieSPGGI)LDEgQreyLHKiEJc0gyJ3uqyX)KMr)H8yb51IJNxJNpMH31zggf4MxEqXZkJS5V71PBeWZb(cSBXxbJ30ac28MqXk3ubGawlK6Ncg)fupWW1rVWJMBcbV71PBeqQFkySOBWnS5nHI1O5d)ubfoQh4dEOnJphpr8OV71PBeqQFkySOBWnS5nHIL0m6pKhliVwC88A88Xm8UoZWOa38YdkEwzKn)DVoDJas9tbJfDdUHnVjuSYnvGIM8rvooihv0qXXbpHCqGvEQGckEuLJdYrfnuCCWtiheyLNc2uqqX)Yo3KyQskjqrfF3Rt3iGNd8fy3IVcgVPbeS5nHIv2LBQaqaRfs9tbJ)cQhy46Ox4CqaRfs9tbJ)cQhy4MkbVo6fwjfuqX3960nc45aFb2T4RGXBAabBEtOyLBQaqaRfs9tbJ)cQhy46Ox4CtvsjbGawlSbcg7wSOBWnC6gHGnfeu8VSZZqnIaRmKeXBuG2aB8Mccl(N0m6pKhliVwC88A88XgaOEIOa7wmjeLB)kugzZF3Rt3iGNd8fy3IVcgVPbeS5nHIvUPcabSwi1pfm(lOEGHRJEHhn3ecE3Rt3iGu)uWyr3GByZBcfRrZh(PckCupWh8qBgFoEI4rF3Rt3iGu)uWyr3GByZBcflPz0FipwqET445145Jnaq9erb2Tysik3(vOmYM)UxNUraP(PGXIUb3WM3ekw5Mkqrt(OkhhKJkAO44GNqoiWkpvqbfpQYXb5OIgkoo4jKdcSYtbBkiO4FzNBsmvjLeOOIV71PBeWZb(cSBXxbJ30ac28MqXk7YnvaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cRKckO47ED6gb8CGVa7w8vW4nnGGnVjuSYnvaiG1cP(PGXFb1dmCD0lCUPkPKaqaRf2abJDlw0n4goDJqWMcck(x25zOgrGvgsI4nkqBGnEtbHf)tAg9hYJfKxloEEnE(yVhphxthpX2kTzLROGX)m3CPmYMdcyTqQFkySOBWnC6gHaqaRf2abJDlw0n4goDJqWKbbSw45aFb2T4RGXBAabNUriytbbp0MXNJ3ujzNZLWpWX4dTzPz0FipwqET445145J1mjIIbSTsBEPmYMdcyTqQFkySOBWnC6gHaqaRf2abJDlw0n4goDJqWKbbSw45aFb2T4RGXBAabNUriytbbp0MXNJ3ujzNZLWpWX4dTzPz0FipwqET445145Jz9hyXtmjeLB0XyqM2kJS5GawlK6Ncgl6gCdNUriaeWAHnqWy3IfDdUHt3iemzqaRfEoWxGDl(ky8MgqWPBesZO)qESG8AXXZRXZhteOr2SqXagSsRtzKnheWAHu)uWyr3GB40ncbGawlSbcg7wSOBWnC6gHGjdcyTWZb(cSBXxbJ30acoDJqAg9hYJfKxloEEnE(ynsuSYyuGxI0ZkJS5GawlK6Ncgl6gCdNUriaeWAHnqWy3IfDdUHt3iemzqaRfEoWxGDl(ky8MgqWPBesZO)qESG8AXXZRXZh7kymqa6aXeB9(zLr2CqaRfs9tbJfDdUHt3ieacyTWgiySBXIUb3WPBecMmiG1cph4lWUfFfmEtdi40ncPz0FipwqET445145JT5T3zHDlUc8OjE2mTxkJS5GawlK6Ncgl6gCdNUriaeWAHnqWy3IfDdUHt3iemzqaRfEoWxGDl(ky8MgqWPBesZKMr)H8ybTOGQyqGoYP(PGXB0AHQ8szKnheWAHFLP(P1HIbyZ0Fk)fekYlxAg9hYJf0IcQIbb6y88XO(PGXGvADsZO)qESGwuqvmiqhJNpg1pfmgK6MgyPzsZO)qESGBpdV54YxfO9MBLr28TNH3CCWjADu8C25LBQ0m6pKhl42ZWBoUXZhtS5fhpJDlEJIP0m6pKhl42ZWBoUXZhJ6NcgVrRfQYlLr28TNH3CCWjADu88OLBQ0m6pKhl42ZWBoUXZhJ6Ncg7nO0mPzMFPM(d5Xc6ICWDEgQreyLvoOnNxqzySlYbpv2fZx8PCgQcW5LRmYMl2Cg8WpHLd5m(thYdPz0FipwqxKdUhpFSkAO4wyHmaZHnhNYiBoiG1cP(PGXIUb3WPBecabSwydem2Tyr3GB40ncbtgeWAHNd8fy3IVcgVPbeC6gH0m6pKhlOlYb3JNpginGDl(A0l8szKnheWAHu)uWyr3GB40ncbGawlSbcg7wSOBWnC6gHGjdcyTWZb(cSBXxbJ30acoDJqAg9hYJf0f5G7XZhdyXy0X7LYiBoiG1cP(PGXIUb3qarPz0FipwqxKdUhpFmqUxClmkgugzZbbSwi1pfmw0n4gciknJ(d5Xc6ICW945JbwDFITaDwkJS5GawlK6Ncgl6gCdbeLMr)H8ybDro4E88XSOMbRUpvgzZbbSwi1pfmw0n4gciknJ(d5Xc6ICW945JrXZRRPk(PAvzKnheWAHu)uWyr3GBiGO0m6pKhlOlYb3JNpMf1mgSsRtzKnVbc269adNO1JeROG6SWVV3umHS5aGef5PaqaRforRhjwrb1zHFFVPyITTVoiGO0m6pKhlOlYb3JNpMT91HdpdPmYM3abB9EGHdnAvZcJE0xziBoairrEkytbbf)lBZNqjnJ(d5Xc6ICW945JTrD79c7w859MJtAg9hYJf0f5G7XZhBY0va6DWsZO)qESGUihCpE(ynnruC4Li1cRmYMVPGGI)LTj1uPz0FipwqxKdUhpFSNINRy6pKhkJS50FipGRcK9qXaw0n4g(fueCffdsZO)qESGUihCpE(yRcK9qXaw0n4wzKnF5avqumHwexNy3IbR(A57fKdcSYtPz0FipwqxKdUhpFSZb(cSBXxbJ30asAg9hYJf0f5G7XZhJ6Ncgl6gClnJ(d5Xc6ICW945J1abJDlw0n4wzKnheWAHnqWy3IfDdUHt3iKMr)H8ybDro4E88XawmEtbHh4TYiBUIhv54GCurdfhh8eYbbw5PGnfeu8VrZfsMkytbbf)l7CZLqPKckOOjFuLJdYrfnuCCWtiheyLNc2uqqX)gnxijukjnJ(d5Xc6ICW945JbY9IBHrXGYiBoiG1cP(PGXIUb3qarPz0FipwqxKdUhpFSdTzSb1IkJS5nqWwVhy4XBrVPk2GAriBoairrEknJ(d5Xc6ICW945Jj28IJNXUfVrXuzKnFYGawl8CGVa7w8vW4nnGGaIcMmiG1cph4lWUfFfmEtdiyZBcfRrZbbSwOyZloEg7w8gft4MkbVo6fwOn9hYdi1pfmgSsRdYLWpWX4dTzPz0FipwqxKdUhpFmQFkymyLwNYiB(0pyttefhEjsTWWM3ekwzlukOWKbbSwyttefhEjsTW4ma1GBcevrxwW1rVWzBQ0m6pKhlOlYb3JNpg1pfmgSsRtzKnheWAHInV44zSBXBumHaIcMmiG1cph4lWUfFfmEtdiiGOGjdcyTWZb(cSBXxbJ30ac28MqXA0C6pKhqQFkymyLwhKlHFGJXhAZsZO)qESGUihCpE(yu)uWyqQBAGvgzZbbSwi1pfmw0n4gcikaeWAHu)uWyr3GByZBcfRrZh(PaqaRfs9tbJ)cQhy46Ox4CqaRfs9tbJ)cQhy4MkbVo6fwAg9hYJf0f5G7XZhJ6NcgVrRfQYlLr28jdcyTWZb(cSBXxbJ30accik4OkhhK6NcgZFHd5GaR8uaiG1cNmDfGEhmC6gHGjdcyTWZb(cSBXxbJ30ac28MqXkB6pKhqQFky8gTwOkVGCj8dCm(qBw5VGqrE5sZO)qESGUihCpE(yu)uW4nATqvEPmYMdcyTWVYu)06qXaSz6pL)ccf5LlnJ(d5Xc6ICW945Jr9tbJ9guzKnheWAHu)uW4VG6bgUo6fE0CtiqX3960nci1pfmw0n4g28MqXk7YnvbfO)qzymh8gXRrZnHssZO)qESGUihCpE(yu)uWyWkToLr2CqaRf2abJDlw0n4gciQGcBkiO4FzxUqjnJ(d5Xc6ICW945JXz8NoKhkJS5GawlSbcg7wSOBWnC6gHYO44UbepmYMVPGGI)LDUqsOugfh3nG4Hr7npr0X5LlnJ(d5Xc6ICW945Jr9tbJbPUPbwAM0m6pKhly7hDipYZqnIaRSYbT5ClkOkgeOdLDX8fFkNHQaCE5kJS5GawlK6Ncg)fupWW1rVW5GawlK6Ncg)fupWWnvcED0lSatgeWAHnqLXUfFfnZliGOGJ6b(GhAZ4ZXtepAUIkUPGeAi9hYdi1pfmgSsRd((6usOn9hYdi1pfmgSsRdYLWpWX4dTzLKMr)H8ybB)Od5X45Jr9tbJbPUPbwzKnFYGawlSPjIIdVePwyCgGAWnbIQOll46Ox48jdcyTWMMiko8sKAHXzaQb3eiQIUSGBQe86OxybkccyTWgiySBXIUb3WPBekOaiG1cBGGXUfl6gCdBEtOynA(WpvsAg9hYJfS9JoKhJNpg1pfmgSsRtzKnF6hSPjIIdVePwyyZBcfRSfkfuyYGawlSPjIIdVePwyCgGAWnbIQOll46Ox4SnvAg9hYJfS9JoKhJNpg1pfmgSsRtzKnheWAHInV44zSBXBumHaIcMmiG1cph4lWUfFfmEtdiiGOGjdcyTWZb(cSBXxbJ30ac28MqXA0C6pKhqQFkymyLwhKlHFGJXhAZsZO)qESGTF0H8y88XO(PGXB0AHQ8szKnFYGawl8CGVa7w8vW4nnGGaIcoQYXbP(PGX8x4qoiWkpfacyTWjtxbO3bdNUriqXjdcyTWZb(cSBXxbJ30ac28MqXkB6pKhqQFky8gTwOkVGCj8dCm(qBwbfE3Rt3iGInV44zSBXBumHnVjuSY2ufu49mCqXbfoRgrbKdcSYtLu(liuKxU0m6pKhly7hDipgpFmQFky8gTwOkVugzZbbSw4xzQFADOya2m9NaqaRfYLisXKNyr)44qufciknJ(d5Xc2(rhYJXZhJ6NcgVrRfQYlLr2CqaRf(vM6NwhkgGnt)jqrqaRfs9tbJfDdUHaIkOaiG1cBGGXUfl6gCdbevqHjdcyTWZb(cSBXxbJ30ac28MqXkB6pKhqQFky8gTwOkVGCj8dCm(qBwjL)ccf5LlnJ(d5Xc2(rhYJXZhJ6NcgVrRfQYlLr2CqaRf(vM6NwhkgGnt)jaeWAHFLP(P1HIb46Ox4CqaRf(vM6NwhkgGBQe86OxyL)ccf5LlnJ(d5Xc2(rhYJXZhJ6NcgVrRfQYlLr2CqaRf(vM6NwhkgGnt)jaeWAHFLP(P1HIbyZBcfRrZvurqaRf(vM6NwhkgGRJEHfAt)H8as9tbJ3O1cv5fKlHFGJXhAZkn(Wpvs5VGqrE5sZO)qESGTF0H8y88Xc(k4gF8wKxNYiBUInBBEvqGvwbfm5d9cJIbLeacyTqQFky8xq9adxh9cNdcyTqQFky8xq9ad3uj41rVWcabSwi1pfmw0n4goDJqWKbbSw45aFb2T4RGXBAabNUrinJ(d5Xc2(rhYJXZhJ6Ncg7nOYiBoiG1cP(PGXFb1dmCD0l8O5MqAg9hYJfS9JoKhJNp2cqK7WZqkJS5BkiO4FJMB(ekbGawlK6Ncgl6gCdNUriaeWAHnqWy3IfDdUHt3iemzqaRfEoWxGDl(ky8MgqWPBesZO)qESGTF0H8y88Xwfi7HIbSOBWTYiBoiG1cP(PGXIUb3WPBecabSwydem2Tyr3GB40ncbtgeWAHNd8fy3IVcgVPbeC6gHG3960nciNXF6qEaBEtOyLTPcE3Rt3iGu)uWyr3GByZBcfRSnvW7ED6gb8CGVa7w8vW4nnGGnVjuSY2ubkAYhv54GnqWy3IfDdUHCqGvEQGckEuLJd2abJDlw0n4gYbbw5PG3960ncydem2Tyr3GByZBcfRSnvjLKMr)H8ybB)Od5X45Jr9tbJbR06ugzZbbSwyduzSBXxrZ8ccikaeWAHu)uW4VG6bgUo6foBHG0mZVupIvOxQn3l1cz5TNHLAHo64wAg9hYJfS9JoKhJNpg1pfmgK6MgyLr28nfeu8VrZqnIaRmeK6Mgy8Mccl(NG3960nciNXF6qEaBEtOyLTPcabSwi1pfmw0n4goDJqaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9clGxloEgMbTqEGDlwKBl)hYd4gfElnJ(d5Xc2(rhYJXZhJ6NcgdsDtdSYiB(7ED6gb8CGVa7w8vW4nnGGnVjuSYnvGIV71PBeWgiySBXIUb3WM3ekw5MQGcV71PBeqQFkySOBWnS5nHIvUPkjaeWAHu)uW4VG6bgUo6foheWAHu)uW4VG6bgUPsWRJEHLMr)H8ybB)Od5X45Jr9tbJbPUPbwzKnFtbbf)B08muJiWkdbPUPbgVPGWI)jaeWAHu)uWyr3GB40ncbGawlSbcg7wSOBWnC6gHGjdcyTWZb(cSBXxbJ30acoDJqaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9cl4DVoDJaYz8NoKhWM3ekwzBQ0m6pKhly7hDipgpFmQFkymi1nnWkJS5GawlK6Ncgl6gCdNUriaeWAHnqWy3IfDdUHt3iemzqaRfEoWxGDl(ky8MgqWPBecabSwi1pfm(lOEGHRJEHZbbSwi1pfm(lOEGHBQe86Oxybhv54Gu)uWyVbHCqGvEk4DVoDJas9tbJ9ge28MqXA08HFkytbbf)B0CZNPcE3Rt3iGCg)Pd5bS5nHIv2MknJ(d5Xc2(rhYJXZhJ6NcgdsDtdSYiBoiG1cP(PGXIUb3qarbGawlK6Ncgl6gCdBEtOynA(WpfacyTqQFky8xq9adxh9cNdcyTqQFky8xq9ad3uj41rVWsZO)qESGTF0H8y88XO(PGXGu30aRmYMdcyTWgiySBXIUb3qarbGawlSbcg7wSOBWnS5nHI1O5d)uaiG1cP(PGXFb1dmCD0lCoiG1cP(PGXFb1dmCtLGxh9clnJ(d5Xc2(rhYJXZhJ6NcgdwP1jnJ(d5Xc2(rhYJXZhJZ4pDipugfh3nG4Hr28nfeu8VSZfscLYO44UbepmAV5jIooVCPz0FipwW2p6qEmE(yu)uWyqQBAGtQeWv4DsvfTbQ0H8WCRj7LU0Ls]] )


end
