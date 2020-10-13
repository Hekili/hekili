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


    spec:RegisterPack( "Arcane", 20201013.1, [[d4KsLdqikQ0JOOkDjcsQQnrGprrvnksOtrISkcsv9kfQMfjQBrqGAxi(LcPHrrCmjQwgfjpJIkMgfP01iiABuufFJGughbjohbbTocczEkuUNOAFIsDqksrluH4HeeWejiPIUibjvYhjiqAKeKuPojbPsRKIYljiv0mPifUjbjvzNsu(jbPcdLGKkSucskpLKMQePRsqQYxjiqmwcsYEf5VinysDyOfd0Jv1KvYLrTzk9zfmAjCAqRMGq1RjOMTKUTsTBQ(TWWj0XPivlxQNROPRY1bSDrX3PW4LioVOK1tqOmFsW(j6u5PstQl84uzMYetzs5MuU5qmriSCH0uczs9YsKtQI4lmoWjvh3Cs10SF05KQiMvnWvQ0K6ma6NtQf3jofIgD0b4vaas(yp6eUbQ4bd)B0EJoH7F0KkiaSEcD9eysDHhNkZuMyktk3KYnhIjcHLlKMQ8K6uK)uzMhtLulGRf7jWK6INFs18k1c1dhyP20SF0zPzMxPwOJ)cqUL6YnhLLAtzIPmjPwHZBMknPgISZDQ0uzLNknPYocw5vAKK63WJBiMubbSwc2p6mvmm4MScdxQfi1GawlPbCMgwQyyWnzfgUulqQxmiG1sUa4lOHLEfmDJdqYkm8Kk(hm8KAfouCtQqCG1WM9lDPYmvQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWGBYkmCPwGudcyTKgWzAyPIHb3Kvy4sTaPEXGawl5cGVGgw6vW0noajRWWtQ4FWWtQG4anS0RHVWZ0LkZCsLMuzhbR8knss9B4XnetQGawlb7hDMkggCtaetQ4FWWtQpwRu8py40kCEj1kCEuh3CsfE8EMUuzM2uPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHb3eaXKk(hm8KQyCWWtxQmHmvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbqmPI)bdpPcY9KBHH(q6sLzEsLMuzhbR8knss9B4XnetQGawlb7hDMkggCtaetQ4FWWtQG1iwulqNv6sLj0sLMuzhbR8knss9B4XnetQGawlb7hDMkggCtaetQ4FWWtQwyZG1iwPlvMqjvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbqmPI)bdpPI(ZZRXk9XAnDPYectLMuzhbR8knss9B4XnetQnGZ2OhyYcoFOyf6yNf9J9g9fHnDaOOiVKAbsniG1swW5dfRqh7SOFS3OVO2oMhbqmPI)bdpPAHntbR48sxQSYnjvAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcB6aqrrEj1cK6n6ir8pPoBPwiuitQ4FWWtQ2oMh1Jmy6sLvE5PstQ4FWWtQBy3rpPHLErVz)sQSJGvELgjDPYk3uPstQ4FWWtQlgVcWODoPYocw5vAK0LkRCZjvAsLDeSYR0ij1VHh3qmPUrhjI)j1zl1MwtsQ4FWWtQnUGOF0Pi2cNUuzLBAtLMuzhbR8knss9B4XnetQ4FWWjZcO9G(avmm4M8fO7Cf6dsTaPE4xKM3i0NsDUuBssf)dgEs9r)5kf)dgE6sLvUqMknPYocw5vAKK63WJBiMuNbqfe6lIfY1fnSuWAmNXEsyhbR8kPI)bdpPolG2d6duXWG70LkRCZtQ0Kk(hm8K6faFbnS0RGPBCaMuzhbR8kns6sLvUqlvAsf)dgEsf7hDMkggCNuzhbR8kns6sLvUqjvAsLDeSYR0ij1VHh3qmPccyTKgWzAyPIHb3Kvy4jv8py4j1gWzAyPIHb3Plvw5cHPstQSJGvELgjP(n84gIjvfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9y5sTqXePwGuVrhjI)j1zNl1MhHuQvsQvqbPwrP2CL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4Fs9y5sTqriLALsQ4FWWtQB0r6aVtxQmtzsQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWGBcGysf)dgEsfK7j3cd9H0LkZuLNknPYocw5vAKK63WJBiMuBaNTrpWKJ3IrJvQb2Ie20bGII8kPI)bdpPEWntnWwmDPYmLPsLMuzhbR8knss9B4XnetQlgeWAjxa8f0WsVcMUXbibquQfi1lgeWAjxa8f0WsVcMUXbiP5nc9PupwUudcyTeXMNS)mnS0n0xKnwcDE4lSul0xQX)GHtW(rNPGvCEeUe(boMEWnNuX)GHNufBEY(Z0Ws3qFLUuzMYCsLMuzhbR8knss9B4XnetQR4inUGOF0Pi2ctAEJqFk1zl1cPuRGcs9IbbSwsJli6hDkITW0mavNBeewHxwK5HVWsD2sTjjv8py4jvSF0zkyfNx6sLzktBQ0Kk7iyLxPrsQFdpUHysfeWAjInpz)zAyPBOViaIsTaPEXGawl5cGVGgw6vW0noajaIsTaPEXGawl5cGVGgw6vW0noajnVrOpL6XYLA8py4eSF0zkyfNhHlHFGJPhCZjv8py4jvSF0zkyfNx6sLzkHmvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbquQfi1Gawlb7hDMkggCtAEJqFk1JLl1d)sQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWjv8py4jvSF0zki2noWPlvMPmpPstQSJGvELgjPI)bdpPI9Jot3W5ew5zs9lqONulpP(n84gIj1fdcyTKla(cAyPxbt34aKaik1cK6dRSFeSF0zk)fbHDeSYlPwGudcyTKfJxby0otwHHl1cK6fdcyTKla(cAyPxbt34aK08gH(uQZwQX)GHtW(rNPB4CcR8KWLWpWX0dU50LkZucTuPjv2rWkVsJKuX)GHNuX(rNPB4CcR8mP(fi0tQLNu)gECdXKkiG1s(kJ9JZd6dKMX)sxQmtjusLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWs9y5sTPKAbsTIs9hrDfgob7hDMkggCtAEJqFk1zl1LBIuRGcsn(hmdtzN3qEk1JLl1MsQvkPI)bdpPI9JotJgmDPYmLqyQ0Kk7iyLxPrsQFdpUHysfeWAjnGZ0WsfddUjaIsTcki1B0rI4FsD2sD5czsf)dgEsf7hDMcwX5LUuzMJjPstQSJGvELgjPI)bdpPYzIhpy4jvOFC3aIhfAtQB0rI4FzNlueYKk0pUBaXJc3BEbXJtQLNu)gECdXKkiG1sAaNPHLkggCtwHHNUuzMt5PstQ4FWWtQy)OZuqSBCGtQSJGvELgjDPlPYZj7pptLMkR8uPjv2rWkVsJKu)gECdXK6hrDfgo5cGVGgw6vW0noajnVrOpL6CP2ePwGudcyTeSF0z6xG9atMh(cl1JLl1MsQfi1Fe1vy4eSF0zQyyWnP5nc9PupwUup8lPwbfK6d7b(ihCZ0lOlil1Jj1Fe1vy4eSF0zQyyWnP5nc9zsf)dgEsfSgXIgw6vWu25DwPlvMPsLMuzhbR8knss9B4XnetQFe1vy4eSF0zQyyWnP5nc9PuNl1Mi1cKAfLAZvQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsD25sTqZePwjPwjPwGuROuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBPUCtKAbsniG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSuRKuRGcsTIs9hrDfgo5cGVGgw6vW0noajnVrOpL6CP2ePwGudcyTeSF0z6xG9atMh(cl15sTjsTssTssTaPgeWAjnGZ0WsfddUjRWWLAbs9gDKi(NuNDUuNbBicwzcks3qhUb20n6iv8VKk(hm8KkynIfnS0RGPSZ7SsxQmZjvAsLDeSYR0ij1VHh3qmP(ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1Gawlb7hDM(fypWK5HVWs9y5sTPKAbs9hrDfgob7hDMkggCtAEJqFk1JLl1d)sQvqbP(WEGpYb3m9c6cYs9ys9hrDfgob7hDMkggCtAEJqFMuX)GHNunIUUYWqN28mC0FoDPYmTPstQSJGvELgjP(n84gIj1pI6kmCc2p6mvmm4M08gH(uQZLAtKAbsTIsT5k1hwz)iSxHdfh78IWocw5LuRGcsTIs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPo7CPwOzIuRKuRKulqQvuQvuQ)iQRWWjxa8f0WsVcMUXbiP5nc9PuNTuxUjsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQvsQvqbPwrP(JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQbbSwc2p6m9lWEGjZdFHL6CP2ePwjPwjPwGudcyTKgWzAyPIHb3Kvy4sTaPEJose)tQZoxQZGnebRmbfPBOd3aB6gDKk(xsf)dgEs1i66kddDAZZWr)50LktitLMuzhbR8knss9B4XnetQFe1vy4Kla(cAyPxbt34aK08gH(uQZLAtKAbsniG1sW(rNPFb2dmzE4lSupwUuBkPwGu)ruxHHtW(rNPIHb3KM3i0Ns9y5s9WVKAfuqQpSh4JCWntVGUGSupMu)ruxHHtW(rNPIHb3KM3i0Njv8py4j1baSxq0PHLIcX4oUI0LkZ8KknPYocw5vAKK63WJBiMu)iQRWWjy)OZuXWGBsZBe6tPoxQnrQfi1kk1MRuFyL9JWEfouCSZlc7iyLxsTcki1kk1hwz)iSxHdfh78IWocw5LulqQ3OJeX)K6SZLAHMjsTssTssTaPwrPwrP(JOUcdNCbWxqdl9ky6ghGKM3i0NsD2sD5Mi1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQZLAtKALKALKAbsniG1sAaNPHLkggCtwHHl1cK6n6ir8pPo7CPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4j1baSxq0PHLIcX4oUI0LktOLknPYocw5vAKKk(hm8K6h(Z(14XlQTIBoP(n84gIjvqaRLG9JotfddUjRWWLAbsniG1sAaNPHLkggCtwHHl1cK6fdcyTKla(cAyPxbt34aKScdxQfi1B0rYb3m9c6glrQZoxQ5s4h4y6b3CsTcDM(RKQ5jDPYekPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjRWWLAbsniG1sAaNPHLkggCtwHHl1cK6fdcyTKla(cAyPxbt34aKScdxQfi1B0rYb3m9c6glrQZoxQ5s4h4y6b3Csf)dgEsTzue6duBf38mDPYectLMuzhbR8knss9B4XnetQGawlb7hDMkggCtwHHl1cKAqaRL0aotdlvmm4MScdxQfi1lgeWAjxa8f0WsVcMUXbizfgEsf)dgEs1gpWKxuuig3WJPGmUtxQSYnjvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnzfgUulqQbbSwsd4mnSuXWGBYkmCPwGuVyqaRLCbWxqdl9ky6ghGKvy4jv8py4jvrGgAZc6duWkoV0LkR8YtLMuzhbR8knss9B4XnetQGawlb7hDMkggCtwHHl1cKAqaRL0aotdlvmm4MScdxQfi1lgeWAjxa8f0WsVcMUXbizfgEsf)dgEsTHIIvMcD6ueFoDPYk3uPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjRWWLAbsniG1sAaNPHLkggCtwHHl1cK6fdcyTKla(cAyPxbt34aKScdpPI)bdpPEfmfWbdaFrTr)C6sLvU5KknPYocw5vAKK63WJBiMubbSwc2p6mvmm4MScdxQfi1GawlPbCMgwQyyWnzfgUulqQxmiG1sUa4lOHLEfmDJdqYkm8Kk(hm8K6M3rNfnS0kWdx0vZ4EMU0LuHhVNPstLvEQ0Kk(hm8KkWKPWJ3ZKk7iyLxPrsx6sQyWPstLvEQ0Kk7iyLxPrsQFdpUHysvrP(Wk7hH9kCO4yNxe2rWkVKAbs9gDKi(NupwUulumrQfi1B0rI4FsD25sT5riLALKAfuqQvuQnxP(Wk7hH9kCO4yNxe2rWkVKAbs9gDKi(NupwUuluesPwPKk(hm8K6gDKoW70LkZuPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjRWWtQ4FWWtQv4qXnPcXbwdB2V0LkZCsLMuzhbR8knss9B4XnetQGawlb7hDMkggCtwHHNuX)GHNubXbAyPxdFHNPlvMPnvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbqmPI)bdpP(yTsX)GHtRW5LuRW5rDCZjv4X7z6sLjKPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjaIjv8py4jvX4GHNUuzMNuPjv2rWkVsJKu)gECdXKkiG1sW(rNPIHb3eaXKk(hm8Kki3tUfg6dPlvMqlvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbqmPI)bdpPcwJyrTaDwPlvMqjvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnbqmPI)bdpPAHndwJyLUuzcHPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjaIjv8py4jv0FEEnwPpwRPlvw5MKknPYocw5vAKK63WJBiMuBaNTrpWKJ3IrJvQb2Ie20bGII8kPI)bdpPEWntnWwmDPYkV8uPjv2rWkVsJKu)gECdXKAd4Sn6bMSGZhkwHo2zr)yVrFrythakkYlPwGu)ruxHHtabSw6coFOyf6yNf9J9g9fPzCLLulqQbbSwYcoFOyf6yNf9J9g9f12X8iRWWLAbsTIsniG1sW(rNPIHb3Kvy4sTaPgeWAjnGZ0WsfddUjRWWLAbs9IbbSwYfaFbnS0RGPBCaswHHl1kj1cK6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPwrPgeWAjy)OZ0Va7bMmp8fwQhlxQZGnebRmbdMEXTPFb2d8uQfi1kk1kk1hwz)inGZ0WsfddUjSJGvEj1cK6pI6kmCsd4mnSuXWGBsZBe6tPESCPE4xsTaP(JOUcdNG9JotfddUjnVrOpL6SL6mydrWktU420nwcDXvmlPwjPwbfKAfLAZvQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNTuNbBicwzYf3MUXsOlUIzj1kj1kOGu)ruxHHtW(rNPIHb3KM3i0Ns9y5s9WVKALKALsQ4FWWtQ2oMhyuV0LkRCtLknPYocw5vAKK63WJBiMuvuQBaNTrpWKfC(qXk0Xol6h7n6lcB6aqrrEj1cK6pI6kmCciG1sxW5dfRqh7SOFS3OVinJRSKAbsniG1swW5dfRqh7SOFS3OVOwyZKvy4sTaPwS5m0HFrkNy7yEGr9KALKAfuqQvuQBaNTrpWKfC(qXk0Xol6h7n6lcB6aqrrEj1cK6dUzPoxQnrQvkPI)bdpPAHntbR48sxQSYnNuPjv2rWkVsJKu)gECdXKAd4Sn6bMm0Wznlk8HFLjSPdaff5LulqQ)iQRWWjy)OZuXWGBsZBe6tPoBP2CmrQfi1Fe1vy4Kla(cAyPxbt34aK08gH(uQZLAtKAbsTIsniG1sW(rNPFb2dmzE4lSupwUuNbBicwzcgm9IBt)cSh4PulqQvuQvuQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4KgWzAyPIHb3KM3i0Ns9y5s9WVKAbs9hrDfgob7hDMkggCtAEJqFk1zl1zWgIGvMCXTPBSe6IRywsTssTcki1kk1MRuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjy)OZuXWGBsZBe6tPoBPod2qeSYKlUnDJLqxCfZsQvsQvqbP(JOUcdNG9JotfddUjnVrOpL6XYL6HFj1kj1kLuX)GHNuTDmpQhzW0LkRCtBQ0Kk7iyLxPrsQFdpUHysTbC2g9atgA4SMff(WVYe20bGII8sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNl1Mi1cKAfLAfLAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1Gawlb7hDM(fypWK5HVWs9y5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfddUjRWWLALsQ4FWWtQ2oMh1Jmy6sLvUqMknPYocw5vAKK63WJBiMuBaNTrpWKjuSiC68IEtythakkYlPwGul2Cg6WViLt4mXJhm8Kk(hm8K6faFbnS0RGPBCaMUuzLBEsLMuzhbR8knss9B4XnetQnGZ2OhyYekweoDErVjSPdaff5LulqQvuQfBodD4xKYjCM4XdgUuRGcsTyZzOd)Iuo5cGVGgw6vW0noaLALsQ4FWWtQy)OZuXWG70LkRCHwQ0Kk7iyLxPrsQFdpUHys9GBwQZwQnhtKAbsDd4Sn6bMmHIfHtNx0BcB6aqrrEj1cKAqaRLG9Jot)cShyY8WxyPESCPod2qeSYemy6f3M(fypWtPwGu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1Fe1vy4eSF0zQyyWnP5nc9PupwUup8RKk(hm8KkNjE8GHNUuzLlusLMuzhbR8knssf)dgEsLZepEWWtQq)4Ubepk0MubbSwYekweoDErVjZdFHZbbSwYekweoDErVjBSe68Wx4Kk0pUBaXJc3BEbXJtQLNu)gECdXK6b3SuNTuBoMi1cK6gWzB0dmzcflcNoVO3e20bGII8sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNl1Mi1cKAfLAfLAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1Gawlb7hDM(fypWK5HVWs9y5sDgSHiyLjyW0lUn9lWEGNsTssTssTaPgeWAjnGZ0WsfddUjRWWLALsxQSYfctLMuzhbR8knss9B4XnetQkk1Fe1vy4eSF0zQyyWnP5nc9PuNTuBAfsPwbfK6pI6kmCc2p6mvmm4M08gH(uQhlxQnhPwjPwGu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1kk1Gawlb7hDM(fypWK5HVWs9y5sDgSHiyLjyW0lUn9lWEGNsTaPwrPwrP(Wk7hPbCMgwQyyWnHDeSYlPwGu)ruxHHtAaNPHLkggCtAEJqFk1JLl1d)sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNTulKsTssTcki1kk1MRuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjy)OZuXWGBsZBe6tPoBPwiLALKAfuqQ)iQRWWjy)OZuXWGBsZBe6tPESCPE4xsTssTsjv8py4j1nS7ON0WsVO3SFPlvMPmjvAsLDeSYR0ij1VHh3qmP(ruxHHtUa4lOHLEfmDJdqsZBe6tPoBPod2qeSYKEs3yj0fxXSKAbs9hrDfgob7hDMkggCtAEJqFk1zl1zWgIGvM0t6glHU4kMLulqQvuQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4KgWzAyPIHb3KM3i0Ns9y5s9WVKAfuqQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4KgWzAyPIHb3KM3i0NsD2sDgSHiyLj9KUXsOlUIzj1kOGuBUs9Hv2psd4mnSuXWGBc7iyLxsTssTaPgeWAjy)OZ0Va7bMmp8fwQhlxQZGnebRmbdMEXTPFb2d8uQfi1lgeWAjxa8f0WsVcMUXbizfgEsf)dgEsTXfe9JofXw40LkZuLNknPYocw5vAKK63WJBiMu)iQRWWjxa8f0WsVcMUXbiP5nc9PuNl1Mi1cKAfLAqaRLG9Jot)cShyY8WxyPESCPod2qeSYemy6f3M(fypWtPwGuROuROuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjnGZ0WsfddUjnVrOpL6XYL6HFj1cK6pI6kmCc2p6mvmm4M08gH(uQZwQZGnebRm5IBt3yj0fxXSKALKAfuqQvuQnxP(Wk7hPbCMgwQyyWnHDeSYlPwGu)ruxHHtW(rNPIHb3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLuRKuRGcs9hrDfgob7hDMkggCtAEJqFk1JLl1d)sQvsQvkPI)bdpP24cI(rNIylC6sLzktLknPYocw5vAKK63WJBiMu)iQRWWjy)OZuXWGBsZBe6tPoxQnrQfi1kk1kk1kk1Fe1vy4Kla(cAyPxbt34aK08gH(uQZwQZGnebRmbfPBSe6IRywsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQvsQvqbPwrP(JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQbbSwc2p6m9lWEGjZdFHL6XYL6mydrWktWGPxCB6xG9apLALKALKAbsniG1sAaNPHLkggCtwHHl1kLuX)GHNuBCbr)OtrSfoDPYmL5KknPYocw5vAKK63WJBiMu)iQRWWjy)OZuXWGBsZBe6tPoxQnrQfi1kk1kk1kk1Fe1vy4Kla(cAyPxbt34aK08gH(uQZwQZGnebRmbfPBSe6IRywsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQvsQvqbPwrP(JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQbbSwc2p6m9lWEGjZdFHL6XYL6mydrWktWGPxCB6xG9apLALKALKAbsniG1sAaNPHLkggCtwHHl1kLuX)GHNuxmEfGr7C6sLzktBQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQhlxQZGnebRmbdMEXTPFb2d8uQfi1kk1kk1hwz)inGZ0WsfddUjSJGvEj1cK6pI6kmCsd4mnSuXWGBsZBe6tPESCPE4xsTaP(JOUcdNG9JotfddUjnVrOpL6SL6mydrWktU420nwcDXvmlPwjPwbfKAfLAZvQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNTuNbBicwzYf3MUXsOlUIzj1kj1kOGu)ruxHHtW(rNPIHb3KM3i0Ns9y5s9WVKALsQ4FWWtQxa8f0WsVcMUXby6sLzkHmvAsLDeSYR0ij1VHh3qmPQOuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBPod2qeSYeuKUXsOlUIzj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQhlxQZGnebRmbdMEXTPFb2d8uQvsQvsQfi1GawlPbCMgwQyyWnzfgEsf)dgEsf7hDMkggCNUuzMY8KknPYocw5vAKK63WJBiMubbSwsd4mnSuXWGBYkmCPwGuROuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBP2uMi1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQhlxQZGnebRmbdMEXTPFb2d8uQvsQvsQfi1kk1Fe1vy4eSF0zQyyWnP5nc9PuNTuxUqk1kOGuVyqaRLCbWxqdl9ky6ghGearPwPKk(hm8KAd4mnSuXWG70LkZucTuPjv2rWkVsJKu)gECdXKkiG1swmEfGr7mbquQfi1lgeWAjxa8f0WsVcMUXbibquQfi1lgeWAjxa8f0WsVcMUXbiP5nc9PupwUudcyTeXMNS)mnS0n0xKnwcDE4lSul0xQX)GHtW(rNPGvCEeUe(boMEWnNuX)GHNufBEY(Z0Ws3qFLUuzMsOKknPYocw5vAKK63WJBiMubbSwYIXRamANjaIsTaPwrPwrP(Wk7hP5z4O)mHDeSYlPwGuJ)bZWu25nKNs9ysTPvQvsQvqbPg)dMHPSZBipL6XKAHuQvkPI)bdpPI9JotbR48sxQmtjeMknPI)bdpPobe52JmysLDeSYR0iPlvM5ysQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQZLAtsQ4FWWtQy)OZ0ObtxQmZP8uPjv2rWkVsJKu)gECdXKQIsDZ2MNfiyLLAfuqQnxP(GVWqFqQvsQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWjv8py4jvNVcUPhVf55LUuzMJPsLMuzhbR8knss9B4XnetQGawlb7hDMkggCtwHHl1cKAqaRL0aotdlvmm4MScdxQfi1lgeWAjxa8f0WsVcMUXbizfgUulqQ)iQRWWjy)OZuXWGBsZBe6tPoBP2ePwGu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBP2ePwGuROuBUs9Hv2psd4mnSuXWGBc7iyLxsTcki1kk1hwz)inGZ0WsfddUjSJGvEj1cK6pI6kmCsd4mnSuXWGBsZBe6tPoBP2ePwjPwPKk(hm8K6SaApOpqfddUtxQmZXCsLMuzhbR8knss9B4XnetQGawl5Rm2popOpqAg)tQfi1nGZ2Ohyc2p6mf6wOdVSiSPdaff5LulqQpSY(rWTyfAHpEWWjSJGvEj1cKA8pygMYoVH8uQhtQnpjv8py4jvSF0z6goNWkptxQmZX0MknPYocw5vAKK63WJBiMubbSwYxzSFCEqFG0m(NulqQBaNTrpWeSF0zk0TqhEzrythakkYlPwGuJ)bZWu25nKNs9ysTPnPI)bdpPI9Jot3W5ew5z6sLzoczQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQhtQbbSwc2p6m9lWEGjBSe68Wx4Kk(hm8Kk2p6mLlrSgty4PlvM5yEsLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWsTaPwS5m0HFrkNG9JotbXUXboPI)bdpPI9Jot5seRXegE6sLzocTuPjv2rWkVsJKu)gECdXKkiG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lCsf)dgEsf7hDMcIDJdC6sLzocLuPjvOFC3aIhfAtQB0rI4FzNlueYKk0pUBaXJc3BEbXJtQLNuX)GHNu5mXJhm8Kk7iyLxPrsx6sQ7idVz)sLMkR8uPjv2rWkVsJKu)gECdXK6oYWB2pYcop0FwQZoxQl3KKk(hm8Kkyf6cNUuzMkvAsf)dgEsvS5j7ptdlDd9vsLDeSYR0iPlvM5KknPYocw5vAKK63WJBiMu3rgEZ(rwW5H(Zs9ysD5MKuX)GHNuX(rNPB4CcR8mDPYmTPstQ4FWWtQy)OZ0ObtQSJGvELgjDPYeYuPjv8py4jvlSzkyfNxsLDeSYR0iPlDjvXM)ydIxQ0uzLNknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQjj1mytDCZjvXMfbQvkNjsxQmtLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KA5j1VHh3qmP2aoBJEGjtOyr405f9MWMoauuKxsTaPg)dMHPSZBipL6SLAtLuZGn1XnNufBweOwPCMiDPYmNuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNulpP(n84gIj1gWzB0dmzcflcNoVO3e20bGII8sQfi1FKHD0pIZFh1OxsTaPg)dMHPSZBipL6SL6YtQzWM64MtQInlcuRuotKUuzM2uPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNulpP(n84gIj1gWzB0dmzcflcNoVO3e20bGII8sQfi1FKHD0pIdhkoQf5KAgSPoU5KQyZIa1kLZePlvMqMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQjj1mytDCZjvl0XkfeO90LkZ8KknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQqMuZGn1XnNu7jDJLqxCfZkDPYeAPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPwUjj1mytDCZjvuKUXsOlUIzLUuzcLuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNunLjj1mytDCZj1oePBSe6IRywPlvMqyQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQczsnd2uh3Cs9IBt3yj0fxXSsxQSYnjvAsLDeSYR0ij1qmPo5lPI)bdpPMbBicw5KAgScWjvZjP(n84gIj1gWzB0dmzbNpuScDSZI(XEJ(IWMoauuKxj1mytDCZj1lUnDJLqxCfZkDPYkV8uPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNulxitQFdpUHys9JmSJ(rC4qXrTiNuZGn1XnNuV420nwcDXvmR0LkRCtLknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KA5czs9B4XnetQF4la4rW(rNPIDSGdzryhbR8sQfi14FWmmLDEd5PupMuBoj1mytDCZj1lUnDJLqxCfZkDPYk3CsLMuzhbR8knssnetQt(sQ4FWWtQzWgIGvoPMbRaCs1CmjP(n84gIjvEoz)zsg4egonSurUT8FWWjBOhDsnd2uh3Cs9IBt3yj0fxXSsxQSYnTPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPkeAssnd2uh3Csfe7ghy6gDKk(x6sLvUqMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQqXKK63WJBiMu)id7OFehouCulYj1mytDCZjvqSBCGPB0rQ4FPlvw5MNuPjv2rWkVsJKudXK6KVKk(hm8KAgSHiyLtQzWkaNunhtsQzWM64MtQOiDdD4gyt3OJuX)sxQSYfAPstQSJGvELgjPgIj1jFjv8py4j1mydrWkNuZGvaoPkKMKu)gECdXKAd4Sn6bMSGZhkwHo2zr)yVrFrythakkYRKAgSPoU5Kkks3qhUb20n6iv8V0LkRCHsQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQcPjj1VHh3qmP2aoBJEGjdnCwZIcF4xzcB6aqrrELuZGn1XnNurr6g6WnWMUrhPI)LUuzLleMknPYocw5vAKKAiMuN8LuX)GHNuZGnebRCsndwb4KQPsQzWM64MtQyW0lUn9lWEGNPlvMPmjvAsf)dgEsDcS3HtX(rNPwCdRqStQSJGvELgjDPYmv5PstQ4FWWtQy)OZuOFCTY)LuzhbR8kns6sLzktLknPI)bdpP(HlehOz6gDKoW7Kk7iyLxPrsxQmtzoPstQ4FWWtQBy3rtHBCGtQSJGvELgjDPYmLPnvAsLDeSYR0ij1VHh3qmPMbBicwzIyZIa1kLZesDUuBIulqQBaNTrpWKfC(qXk0Xol6h7n6lcB6aqrrEj1cK6pI6kmCciG1sxW5dfRqh7SOFS3OVinJRSKAbsniG1swW5dfRqh7SOFS3OVO2oMhzfgEsf)dgEs12X8aJ6LUuzMsitLMuzhbR8knss9B4XnetQzWgIGvMi2SiqTs5mHuNl1LNuX)GHNu5mXJhm80LUK6hrDfg(mvAQSYtLMuzhbR8knss9B4XnetQGawlb7hDMkggCtwHHl1cKAqaRL0aotdlvmm4MScdxQfi1lgeWAjxa8f0WsVcMUXbizfgEsf)dgEsTchkUjvioWAyZ(LUuzMkvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnzfgUulqQbbSwsd4mnSuXWGBYkmCPwGuVyqaRLCbWxqdl9ky6ghGKvy4jv8py4jvqCGgw61Wx4z6sLzoPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjaIjv8py4j1hRvk(hmCAfoVKAfopQJBoPcpEptxQmtBQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZuXWGBcGysf)dgEsvmoy4PlvMqMknPYocw5vAKK63WJBiMubbSwc2p6mvmm4MaiMuX)GHNub5EYTWqFiDPYmpPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjaIjv8py4jvWAelQfOZkDPYeAPstQSJGvELgjP(n84gIjvqaRLG9JotfddUjaIjv8py4jvlSzWAeR0LktOKknPYocw5vAKK63WJBiMubbSwc2p6mvmm4MaiMuX)GHNur)551yL(yTMUuzcHPstQSJGvELgjP(n84gIj1gWzB0dmzOHZAwu4d)ktythakkYlPwGu)ruxHHtW(rNPIHb3KM3i0NsD2sT5yIulqQ)iQRWWjxa8f0WsVcMUXbiP5nc9PuNl1Mi1cKAfLAqaRLG9Jot)cShyY8WxyPESCP2usTaPwrPwrP(Wk7hPbCMgwQyyWnHDeSYlPwGu)ruxHHtAaNPHLkggCtAEJqFk1JLl1d)sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNTuNbBicwzYf3MUXsOlUIzj1kj1kOGuROuBUs9Hv2psd4mnSuXWGBc7iyLxsTaP(JOUcdNG9JotfddUjnVrOpL6SL6mydrWktU420nwcDXvmlPwjPwbfK6pI6kmCc2p6mvmm4M08gH(uQhlxQh(LuRKuRusf)dgEs12X8OEKbtxQSYnjvAsLDeSYR0ij1VHh3qmP2aoBJEGjdnCwZIcF4xzcB6aqrrEj1cK6pI6kmCc2p6mvmm4M08gH(uQZLAtKAbsTIsT5k1hwz)iSxHdfh78IWocw5LuRGcsTIs9Hv2pc7v4qXXoViSJGvEj1cK6n6ir8pPo7CPwOzIuRKuRKulqQvuQvuQ)iQRWWjxa8f0WsVcMUXbiP5nc9PuNTuxUjsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQvsQvqbPwrP(JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQbbSwc2p6m9lWEGjZdFHL6CP2ePwjPwjPwGudcyTKgWzAyPIHb3Kvy4sTaPEJose)tQZoxQZGnebRmbfPBOd3aB6gDKk(xsf)dgEs12X8OEKbtxQSYlpvAsLDeSYR0ij1VHh3qmP2aoBJEGjl48HIvOJDw0p2B0xe20bGII8sQfi1Fe1vy4eqaRLUGZhkwHo2zr)yVrFrAgxzj1cKAqaRLSGZhkwHo2zr)yVrFrTDmpYkmCPwGuROudcyTeSF0zQyyWnzfgUulqQbbSwsd4mnSuXWGBYkmCPwGuVyqaRLCbWxqdl9ky6ghGKvy4sTssTaP(JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQvuQbbSwc2p6m9lWEGjZdFHL6XYLAtj1cKAfLAfL6dRSFKgWzAyPIHb3e2rWkVKAbs9hrDfgoPbCMgwQyyWnP5nc9PupwUup8lPwGu)ruxHHtW(rNPIHb3KM3i0NsD2sDgSHiyLjxCB6glHU4kMLuRKuRGcsTIsT5k1hwz)inGZ0WsfddUjSJGvEj1cK6pI6kmCc2p6mvmm4M08gH(uQZwQZGnebRm5IBt3yj0fxXSKALKAfuqQ)iQRWWjy)OZuXWGBsZBe6tPESCPE4xsTssTsjv8py4jvBhZdmQx6sLvUPsLMuzhbR8knss9B4XnetQnGZ2OhyYcoFOyf6yNf9J9g9fHnDaOOiVKAbs9hrDfgobeWAPl48HIvOJDw0p2B0xKMXvwsTaPgeWAjl48HIvOJDw0p2B0xulSzYkmCPwGul2Cg6WViLtSDmpWOEjv8py4jvlSzkyfNx6sLvU5KknPYocw5vAKK63WJBiMu)iQRWWjxa8f0WsVcMUXbiP5nc9PuNl1Mi1cKAqaRLG9Jot)cShyY8WxyPESCP2usTaP(JOUcdNG9JotfddUjnVrOpL6XYL6HFLuX)GHNu3WUJEsdl9IEZ(LUuzLBAtLMuzhbR8knss9B4XnetQFe1vy4eSF0zQyyWnP5nc9PuNl1Mi1cKAfLAZvQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsD25sTqZePwjPwjPwGuROuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBPod2qeSYeuKUXsOlUIzj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQZLAtKALKALKAbsniG1sAaNPHLkggCtwHHl1cK6n6ir8pPo7CPod2qeSYeuKUHoCdSPB0rQ4Fjv8py4j1nS7ON0WsVO3SFPlvw5czQ0Kk7iyLxPrsQFdpUHys9JOUcdNCbWxqdl9ky6ghGKM3i0NsDUuBIulqQbbSwc2p6m9lWEGjZdFHL6XYLAtj1cK6pI6kmCc2p6mvmm4M08gH(uQhlxQh(vsf)dgEsDX4vagTZPlvw5MNuPjv2rWkVsJKu)gECdXK6hrDfgob7hDMkggCtAEJqFk15sTjsTaPwrP2CL6dRSFe2RWHIJDEryhbR8sQvqbPwrP(Wk7hH9kCO4yNxe2rWkVKAbs9gDKi(NuNDUul0mrQvsQvsQfi1kk1kk1Fe1vy4Kla(cAyPxbt34aK08gH(uQZwQl3ePwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1kj1kOGuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoxQnrQfi1Gawlb7hDM(fypWK5HVWsDUuBIuRKuRKulqQbbSwsd4mnSuXWGBYkmCPwGuVrhjI)j1zNl1zWgIGvMGI0n0HBGnDJosf)lPI)bdpPUy8kaJ250LkRCHwQ0Kk7iyLxPrsQFdpUHys9JOUcdNCbWxqdl9ky6ghGKM3i0NsD2sDgSHiyLj9KUXsOlUIzj1cK6pI6kmCc2p6mvmm4M08gH(uQZwQZGnebRmPN0nwcDXvmlPwGuROuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjnGZ0WsfddUjnVrOpL6XYL6HFj1kOGuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjnGZ0WsfddUjnVrOpL6SL6mydrWkt6jDJLqxCfZsQvqbP2CL6dRSFKgWzAyPIHb3e2rWkVKALKAbsniG1sW(rNPFb2dmzE4lSuNTuBkPwGuVyqaRLCbWxqdl9ky6ghGKvy4jv8py4j1gxq0p6ueBHtxQSYfkPstQSJGvELgjP(n84gIj1pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQhlxQnLulqQ)iQRWWjy)OZuXWGBsZBe6tPESCPE4xjv8py4j1gxq0p6ueBHtxQSYfctLMuzhbR8knss9B4XnetQFe1vy4eSF0zQyyWnP5nc9PuNl1Mi1cKAfLAfLAZvQpSY(ryVchko25fHDeSYlPwbfKAfL6dRSFe2RWHIJDEryhbR8sQfi1B0rI4FsD25sTqZePwjPwjPwGuROuROu)ruxHHtUa4lOHLEfmDJdqsZBe6tPoBPod2qeSYeuKUXsOlUIzj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwjPwbfKAfL6pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPgeWAjy)OZ0Va7bMmp8fwQZLAtKALKALKAbsniG1sAaNPHLkggCtwHHl1cK6n6ir8pPo7CPod2qeSYeuKUHoCdSPB0rQ4FsTsjv8py4j1gxq0p6ueBHtxQmtzsQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQhlxQnLulqQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4KgWzAyPIHb3KM3i0Ns9y5s9WVKAbs9hrDfgob7hDMkggCtAEJqFk1zl1zWgIGvMCXTPBSe6IRywsTaP(JmSJ(reoRgIUulqQ)iQRWWjnUGOF0Pi2ctAEJqFk1JLl1cLKk(hm8K6faFbnS0RGPBCaMUuzMQ8uPjv2rWkVsJKu)gECdXKkiG1sW(rNPFb2dmzE4lSupwUuBkPwGuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjnGZ0WsfddUjnVrOpL6XYL6HFj1cK6pI6kmCc2p6mvmm4M08gH(uQZwQZGnebRm5IBt3yj0fxXSKAbsT5k1FKHD0pIWz1q0tQ4FWWtQxa8f0WsVcMUXby6sLzktLknPYocw5vAKK63WJBiMubbSwc2p6m9lWEGjZdFHL6XYLAtj1cKAZvQpSY(rAaNPHLkggCtyhbR8sQfi1Fe1vy4eSF0zQyyWnP5nc9PuNTuNbBicwzYf3MUXsOlUIzLuX)GHNuVa4lOHLEfmDJdW0LkZuMtQ0Kk7iyLxPrsQFdpUHysfeWAjy)OZ0Va7bMmp8fwQhlxQnLulqQ)iQRWWjy)OZuXWGBsZBe6tPESCPE4xjv8py4j1la(cAyPxbt34amDPYmLPnvAsLDeSYR0ij1VHh3qmPQOuBUs9Hv2pc7v4qXXoViSJGvEj1kOGuROuFyL9JWEfouCSZlc7iyLxsTaPEJose)tQZoxQfAMi1kj1kj1cK6pI6kmCYfaFbnS0RGPBCasAEJqFk1zl1zWgIGvMGI0nwcDXvmlPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1cKAqaRL0aotdlvmm4MScdxQfi1B0rI4FsD25sDgSHiyLjOiDdD4gyt3OJuX)sQ4FWWtQy)OZuXWG70LkZuczQ0Kk7iyLxPrsQFdpUHysfeWAjnGZ0WsfddUjRWWLAbs9hrDfgo5cGVGgw6vW0noajnVrOpL6SL6mydrWkt6qKUXsOlUIzj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwGuROu)ruxHHtW(rNPIHb3KM3i0NsD2sD5cPuRGcs9IbbSwYfaFbnS0RGPBCasaeLALsQ4FWWtQnGZ0WsfddUtxQmtzEsLMuzhbR8knss9B4XnetQGawlb7hDM(fypWK5HVWsDUuBIulqQ)id7OFeHZQHONuX)GHNufBEY(Z0Ws3qFLUuzMsOLknPYocw5vAKK63WJBiMuxmiG1sUa4lOHLEfmDJdqcGOulqQnxP(JmSJ(reoRgIEsf)dgEsvS5j7ptdlDd9v6sLzkHsQ0Kk7iyLxPrsQFdpUHys9JOUcdNWzIhpy4KM3i0NsD2sTjsTaPwrPwrP(Wk7hH9kCO4yNxe2rWkVKAbs9gDKi(NupwUulumrQfi1B0rI4FsD25sT5riLALKAfuqQvuQnxP(Wk7hH9kCO4yNxe2rWkVKAbs9gDKi(NupwUuluesPwjPwPKk(hm8K6gDKoW70LUK6ITiq9sLMkR8uPjv2rWkVsJKu)gECdXK6H9aFKfdcyTKhNh0hinJ)LuX)GHNu)aWpUNICTMUuzMkvAsLDeSYR0ijv8py4j1hRvk(hmCAfoVKAfopQJBoPYZj7pptxQmZjvAsLDeSYR0ij1VHh3qmPI)bZWu25nKNsD2sTPsQ4FWWtQpwRu8py40kCEj1kCEuh3CsfdoDPYmTPstQSJGvELgjP(n84gIj1mydrWktkWmmnezNxsDUuBssf)dgEs9XALI)bdNwHZlPwHZJ64MtQHi7CNUuzczQ0Kk7iyLxPrsQ4FWWtQpwRu8py40kCEj1kCEuh3Cs9JOUcdFMUuzMNuPjv2rWkVsJKu)gECdXKAgSHiyLjwOJvkiq7sDUuBssf)dgEs9XALI)bdNwHZlPwHZJ64MtQDC4bdpDPYeAPstQSJGvELgjP(n84gIj1mydrWktSqhRuqG2L6CPU8Kk(hm8K6J1kf)dgoTcNxsTcNh1XnNuTqhRuqG2txQmHsQ0Kk7iyLxPrsQ4FWWtQpwRu8py40kCEj1kCEuh3CsDhz4n7x6sxsTJdpy4PstLvEQ0Kk7iyLxPrsQHysDYxsf)dgEsnd2qeSYj1myfGtQLNu)gECdXKkiG1sW(rNPFb2dmzE4lSuNl1Gawlb7hDM(fypWKnwcDE4lSulqQnxPgeWAjnqLPHLEfnZtcGOulqQpSh4JCWntVGUGSupwUuROuROuVrhL6rLA8py4eSF0zkyfNh5J5j1kj1c9LA8py4eSF0zkyfNhHlHFGJPhCZsTsj1mytDCZjvl0XkfeO90LkZuPstQSJGvELgjP(n84gIj1fdcyTKgxq0p6ueBHPzaQo3iiScVSiZdFHL6CPEXGawlPXfe9JofXwyAgGQZnccRWllYglHop8fwQfi1kk1Gawlb7hDMkggCtwHHl1kOGudcyTeSF0zQyyWnP5nc9PupwUup8lPwjPwGuROudcyTKgWzAyPIHb3Kvy4sTcki1GawlPbCMgwQyyWnP5nc9PupwUup8lPwPKk(hm8Kk2p6mfe7gh40LkZCsLMuzhbR8knss9B4XnetQR4inUGOF0Pi2ctAEJqFk1zl1cPuRGcs9IbbSwsJli6hDkITW0mavNBeewHxwK5HVWsD2sTjjv8py4jvSF0zkyfNx6sLzAtLMuzhbR8knss9B4XnetQGawlrS5j7ptdlDd9fbquQfi1lgeWAjxa8f0WsVcMUXbibquQfi1lgeWAjxa8f0WsVcMUXbiP5nc9PupwUuJ)bdNG9JotbR48iCj8dCm9GBoPI)bdpPI9JotbR48sxQmHmvAsLDeSYR0ijv8py4jvSF0z6goNWkptQFbc9KA5j1VHh3qmPUyqaRLCbWxqdl9ky6ghGearPwGuFyL9JG9Jot5ViiSJGvEj1cKAqaRLSy8kaJ2zYkmCPwGuROuVyqaRLCbWxqdl9ky6ghGKM3i0NsD2sn(hmCc2p6mDdNtyLNeUe(boMEWnl1kOGu)ruxHHteBEY(Z0Ws3qFrAEJqFk1zl1Mi1kOGu)rg2r)icNvdrxQvkDPYmpPstQSJGvELgjP(n84gIjvqaRL8vg7hNh0hinJ)j1cKAqaRLWLiI(IxuX4y)GyLaiMuX)GHNuX(rNPB4CcR8mDPYeAPstQSJGvELgjPI)bdpPI9Jot3W5ew5zs9lqONulpP(n84gIjvqaRL8vg7hNh0hinJ)j1cKAfLAqaRLG9JotfddUjaIsTcki1GawlPbCMgwQyyWnbquQvqbPEXGawl5cGVGgw6vW0noajnVrOpL6SLA8py4eSF0z6goNWkpjCj8dCm9GBwQvkDPYekPstQSJGvELgjPI)bdpPI9Jot3W5ew5zs9lqONulpP(n84gIjvqaRL8vg7hNh0hinJ)j1cKAqaRL8vg7hNh0hiZdFHL6CPgeWAjFLX(X5b9bYglHop8foDPYectLMuzhbR8knssf)dgEsf7hDMUHZjSYZK6xGqpPwEs9B4XnetQGawl5Rm2popOpqAg)tQfi1Gawl5Rm2popOpqAEJqFk1JLl1kk1kk1Gawl5Rm2popOpqMh(cl1c9LA8py4eSF0z6goNWkpjCj8dCm9GBwQvsQhxQh(LuRu6sLvUjPstQSJGvELgjP(n84gIjvfL6MTnplqWkl1kOGuBUs9bFHH(GuRKulqQbbSwc2p6m9lWEGjZdFHL6CPgeWAjy)OZ0Va7bMSXsOZdFHLAbsniG1sW(rNPIHb3Kvy4sTaPEXGawl5cGVGgw6vW0noajRWWtQ4FWWtQoFfCtpElYZlDPYkV8uPjv2rWkVsJKu)gECdXKkiG1sW(rNPFb2dmzE4lSupwUuBQKk(hm8Kk2p6mnAW0LkRCtLknPYocw5vAKK63WJBiMu3OJeX)K6XYLAHqHuQfi1Gawlb7hDMkggCtwHHl1cKAqaRL0aotdlvmm4MScdxQfi1lgeWAjxa8f0WsVcMUXbizfgEsf)dgEsDciYThzW0LkRCZjvAsLDeSYR0ij1VHh3qmPccyTeSF0zQyyWnzfgUulqQbbSwsd4mnSuXWGBYkmCPwGuVyqaRLCbWxqdl9ky6ghGKvy4sTaP(JOUcdNWzIhpy4KM3i0NsD2sTjsTaP(JOUcdNG9JotfddUjnVrOpL6SLAtKAbs9hrDfgo5cGVGgw6vW0noajnVrOpL6SLAtKAbsTIsT5k1hwz)inGZ0WsfddUjSJGvEj1kOGuROuFyL9J0aotdlvmm4MWocw5LulqQ)iQRWWjnGZ0WsfddUjnVrOpL6SLAtKALKALsQ4FWWtQZcO9G(avmm4oDPYk30MknPYocw5vAKK63WJBiMubbSwsduzAyPxrZ8Kaik1cKAqaRLG9Jot)cShyY8WxyPoBP2CsQ4FWWtQy)OZuWkoV0LkRCHmvAsLDeSYR0ij1VHh3qmPUrhjI)j1Jj1zWgIGvMaIDJdmDJosf)tQfi1Fe1vy4eot84bdN08gH(uQZwQnrQfi1Gawlb7hDMkggCtwHHl1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68WxyPwGuZZj7ptYaNWWPHLkYTL)dgozd9OtQ4FWWtQy)OZuqSBCGtxQSYnpPstQSJGvELgjP(n84gIj1pI6kmCYfaFbnS0RGPBCasAEJqFk15sTjsTaPwrP(JOUcdN0aotdlvmm4M08gH(uQZLAtKAfuqQ)iQRWWjy)OZuXWGBsZBe6tPoxQnrQvsQfi1Gawlb7hDM(fypWK5HVWsDUudcyTeSF0z6xG9at2yj05HVWjv8py4jvSF0zki2noWPlvw5cTuPjv2rWkVsJKu)gECdXK6gDKi(NupwUuNbBicwzci2noW0n6iv8pPwGudcyTeSF0zQyyWnzfgUulqQbbSwsd4mnSuXWGBYkmCPwGuVyqaRLCbWxqdl9ky6ghGKvy4sTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8fwQfi1Fe1vy4eot84bdN08gH(uQZwQnjPI)bdpPI9JotbXUXboDPYkxOKknPYocw5vAKK63WJBiMubbSwc2p6mvmm4MScdxQfi1GawlPbCMgwQyyWnzfgUulqQxmiG1sUa4lOHLEfmDJdqYkmCPwGudcyTeSF0z6xG9atMh(cl15sniG1sW(rNPFb2dmzJLqNh(cl1cK6dRSFeSF0zA0Ge2rWkVKAbs9hrDfgob7hDMgniP5nc9PupwUup8lPwGuVrhjI)j1JLl1cHMi1cK6pI6kmCcNjE8GHtAEJqFk1zl1MKuX)GHNuX(rNPGy34aNUuzLleMknPYocw5vAKK63WJBiMubbSwc2p6mvmm4Maik1cKAqaRLG9JotfddUjnVrOpL6XYL6HFj1cKAqaRLG9Jot)cShyY8WxyPoxQbbSwc2p6m9lWEGjBSe68Wx4Kk(hm8Kk2p6mfe7gh40LkZuMKknPYocw5vAKK63WJBiMubbSwsd4mnSuXWGBcGOulqQbbSwsd4mnSuXWGBsZBe6tPESCPE4xsTaPgeWAjy)OZ0Va7bMmp8fwQZLAqaRLG9Jot)cShyYglHop8foPI)bdpPI9JotbXUXboDPYmv5PstQ4FWWtQy)OZuWkoVKk7iyLxPrsxQmtzQuPjvOFC3aIhfAtQB0rI4FzNlueYKk0pUBaXJc3BEbXJtQLNuX)GHNu5mXJhm8Kk7iyLxPrsxQmtzoPstQ4FWWtQy)OZuqSBCGtQSJGvELgjDPlPAHowPGaTNknvw5PstQSJGvELgjPI)bdpPI9Jot3W5ew5zs9lqONulpP(n84gIjvqaRL8vg7hNh0hinJ)LUuzMkvAsf)dgEsf7hDMcwX5LuzhbR8kns6sLzoPstQ4FWWtQy)OZuqSBCGtQSJGvELgjDPlDj1mCpHHNkZuMyktk3KYnNKQb2o0hMjvHGyAkuRmHULjeuHiPwQlTGLA4wm6tQTrl1MFhhEWWnFPUztha28sQNXMLAe4InE8sQ)c0h4jrAMPb0zPUCHiPwiq4z4(4LuRc3cbK6zw(HLi1c1xQVqQnnaqPEbZaNWWL6qKB8IwQvCuLKAflVeLisZmnGol1cPqKulei8mCF8sQn)pYWo6hrOIWocw5L5l1xi1M)hzyh9Jiuz(sTILxIsePzsZecIPPqTYe6wMqqfIKAPU0cwQHBXOpP2gTuB(In)XgepZxQB20bGnVK6zSzPgbUyJhVK6Va9bEsKMzAaDwQnhHiPwiq4z4(4LuB(FKHD0pIqfHDeSYlZxQVqQn)pYWo6hrOY8LAflVeLisZmnGol1MwHiPwiq4z4(4LuB(FKHD0pIqfHDeSYlZxQVqQn)pYWo6hrOY8LAflVeLisZmnGol1LxUqKulei8mCF8sQn)pYWo6hrOIWocw5L5l1xi1M)hzyh9Jiuz(sTILxIsePzMgqNL6YfsHiPwiq4z4(4LuB(FKHD0pIqfHDeSYlZxQVqQn)pYWo6hrOY8LAflVeLisZKMjeettHALj0TmHGkej1sDPfSud3IrFsTnAP28)iQRWWNMVu3SPdaBEj1ZyZsncCXgpEj1Fb6d8KinZ0a6SuBkteIKAHaHNH7JxsT5)rg2r)icve2rWkVmFP(cP28)id7OFeHkZxQvS8suIinZ0a6SuBQYfIKAHaHNH7JxsT5)rg2r)icve2rWkVmFP(cP28)id7OFeHkZxQvS8suIinZ0a6SuBkZJqKulei8mCF8sQn)pYWo6hrOIWocw5L5l1xi1M)hzyh9Jiuz(sTILxIsePzMgqNLAtj0eIKAHaHNH7JxsT5)rg2r)icve2rWkVmFP(cP28)id7OFeHkZxQvS8suIintAMq3Ty0hVK6YnrQX)GHl1v48MePzjve4kIoPQc3av8GHleOr7Luf7WcRCs18k1c1dhyP20SF0zPzMxPwOJ)cqUL6YnhLLAtzIPmrAM0m8py4tIyZFSbXlpd2qeSYk74MZfBweOwPCMq5qmFYNYzWkaNBI0m8py4tIyZFSbXB88rZGnebRSYoU5CXMfbQvkNjuoeZN8PCgScW5LRm0M3aoBJEGjtOyr405f9MWMoauuKxcW)Gzyk78gYZSnL0m8py4tIyZFSbXB88rZGnebRSYoU5CXMfbQvkNjuoeZN8PCgScW5LRm0M3aoBJEGjtOyr405f9MWMoauuKxc(id7OFeN)oQrViSJGvEja)dMHPSZBipZUCPz4FWWNeXM)ydI345JMbBicwzLDCZ5InlcuRuotOCiMp5t5myfGZlxzOnVbC2g9atMqXIWPZl6nHnDaOOiVe8rg2r)ioCO4OwKjSJGvEjnZ8k14FWWNeXM)ydI345JMbBicwzLDCZ5fygMgISZlLdX8jFkNbRaCUjsZmVsn(hm8jrS5p2G4nE(OzWgIGvwzh3CEbMHPHi78s5qmFYNYzWkaNxUYqBo(hmdtzN3qEMTPKMzELA8py4tIyZFSbXB88rZGnebRSYoU58cmdtdr25LYHy(KpLZGvaoVCLH28mydrWkteBweOwPCMiVCPz4FWWNeXM)ydI345JMbBicwzLDCZ5wOJvkiq7khI5t(uodwb4CtKMH)bdFseB(JniEJNpAgSHiyLv2XnN3t6glHU4kMLYHy(KpLZGvaoxiLMH)bdFseB(JniEJNpAgSHiyLv2XnNJI0nwcDXvmlLdX8jFkNbRaCE5Mind)dg(Ki28hBq8gpF0mydrWkRSJBoVdr6glHU4kMLYHy(KpLZGvao3uMind)dg(Ki28hBq8gpF0mydrWkRSJBo)IBt3yj0fxXSuoeZN8PCgScW5cP0m8py4tIyZFSbXB88rZGnebRSYoU58lUnDJLqxCfZs5qmFYNYzWkaNBokdT5nGZ2OhyYcoFOyf6yNf9J9g9fHnDaOOiVKMH)bdFseB(JniEJNpAgSHiyLv2XnNFXTPBSe6IRywkhI5t(uodwb48YfsLH28pYWo6hXHdfh1ImHDeSYlPz4FWWNeXM)ydI345JMbBicwzLDCZ5xCB6glHU4kMLYHy(KpLZGvaoVCHuzOn)dFbapc2p6mvSJfCilc7iyLxcW)Gzyk78gYZXmhPzMxPEeRPPuleSuluJ3rgwQnnWJBPz4FWWNeXM)ydI345JMbBicwzLDCZ5xCB6glHU4kMLYHy(KpLZGvao3CmrzOnNNt2FMKboHHtdlvKBl)hmCYg6rlnd)dg(Ki28hBq8gpF0mydrWkRSJBohe7ghy6gDKk(NYHy(KpLZGvaoxi0ePz4FWWNeXM)ydI345JMbBicwzLDCZ5Gy34at3OJuX)uoeZN8PCgScW5cftugAZ)id7OFehouCulYe2rWkVKMH)bdFseB(JniEJNpAgSHiyLv2XnNJI0n0HBGnDJosf)t5qmFYNYzWkaNBoMind)dg(Ki28hBq8gpF0mydrWkRSJBohfPBOd3aB6gDKk(NYHy(KpLZGvaoxinrzOnVbC2g9atwW5dfRqh7SOFS3OViSPdaff5L0m8py4tIyZFSbXB88rZGnebRSYoU5CuKUHoCdSPB0rQ4FkhI5t(uodwb4CH0eLH28gWzB0dmzOHZAwu4d)ktythakkYlPz4FWWNeXM)ydI345JMbBicwzLDCZ5yW0lUn9lWEGNkhI5t(uodwb4Ctjnd)dg(Ki28hBq8gpFuSF0zQf3WkeBPz4FWWNeXM)ydI345JI9JotH(X1k)N0m8py4tIyZFSbXB88r)WfId0mDJosh4T0m8py4tIyZFSbXB88r3WUJMc34alnd)dg(Ki28hBq8gpFuBhZdmQNYqBEgSHiyLjInlcuRuotKBIGgWzB0dmzbNpuScDSZI(XEJ(IWMoauuKxc(iQRWWjGawlDbNpuScDSZI(XEJ(I0mUYsaiG1swW5dfRqh7SOFS3OVO2oMhzfgU0m8py4tIyZFSbXB88r5mXJhmCLH28mydrWkteBweOwPCMiVCPzsZmVsTqDvc)ahVKAod3zj1hCZs9vWsn(x0snCk1ygewrWktKMH)bdFM)bGFCpf5AvzOn)WEGpYIbbSwYJZd6dKMX)KMzEL6rSMMsTqWsTqnEhzyP20apULMH)bdFoE(OpwRu8py40kCEk74MZ55K9NNsZW)GHphpF0hRvk(hmCAfopLDCZ5yWkdT54FWmmLDEd5z2MsAg(hm8545J(yTsX)GHtRW5PSJBopezNBLH28mydrWktkWmmnezNx5Mind)dg(C88rFSwP4FWWPv48u2XnN)ruxHHpLMH)bdFoE(OpwRu8py40kCEk74MZ74WdgUYqBEgSHiyLjwOJvkiq75Mind)dg(C88rFSwP4FWWPv48u2XnNBHowPGaTRm0MNbBicwzIf6yLcc0EE5sZW)GHphpF0hRvk(hmCAfopLDCZ57idVz)KMjnd)dg(KGbNdmz6gDKoWBLH2CfpSY(ryVchko25fHDeSYlbB0rI4FJLlumrWgDKi(x25MhHujfuqrZ9Wk7hH9kCO4yNxe2rWkVeSrhjI)nwUqrivsAg(hm8jbdE88rRWHIBsfIdSg2SFkdT5Gawlb7hDMkggCtwHHlnd)dg(KGbpE(OG4anS0RHVWtLH2CqaRLG9JotfddUjRWWLMH)bdFsWGhpF0hRvk(hmCAfopLDCZ5WJ3tLH2CqaRLG9JotfddUjaIsZW)GHpjyWJNpQyCWWvgAZbbSwc2p6mvmm4Maiknd)dg(KGbpE(OGCp5wyOpOm0MdcyTeSF0zQyyWnbquAg(hm8jbdE88rbRrSOwGolLH2CqaRLG9JotfddUjaIsZW)GHpjyWJNpQf2mynILYqBoiG1sW(rNPIHb3earPz4FWWNem4XZhf9NNxJv6J1QYqBoiG1sW(rNPIHb3earPz4FWWNem4XZh9GBMAGTOYqBEd4Sn6bMC8wmASsnWwKWMoauuKxsZW)GHpjyWJNpQTJ5bg1tzOnVbC2g9atwW5dfRqh7SOFS3OViSPdaff5LGpI6kmCciG1sxW5dfRqh7SOFS3OVinJRSeacyTKfC(qXk0Xol6h7n6lQTJ5rwHHlqrqaRLG9JotfddUjRWWfacyTKgWzAyPIHb3Kvy4cwmiG1sUa4lOHLEfmDJdqYkmCLe8ruxHHtUa4lOHLEfmDJdqsZBe6ZCteOiiG1sW(rNPFb2dmzE4l8y5zWgIGvMGbtV420Va7bEkqrfpSY(rAaNPHLkggCtyhbR8sWhrDfgoPbCMgwQyyWnP5nc95y5d)sWhrDfgob7hDMkggCtAEJqFMDgSHiyLjxCB6glHU4kMLskOGIM7Hv2psd4mnSuXWGBc7iyLxc(iQRWWjy)OZuXWGBsZBe6ZSZGnebRm5IBt3yj0fxXSusbf(iQRWWjy)OZuXWGBsZBe6ZXYh(Lskjnd)dg(KGbpE(OwyZuWkopLH2CfBaNTrpWKfC(qXk0Xol6h7n6lcB6aqrrEj4JOUcdNacyT0fC(qXk0Xol6h7n6lsZ4klbGawlzbNpuScDSZI(XEJ(IAHntwHHlqS5m0HFrkNy7yEGr9usbfuSbC2g9atwW5dfRqh7SOFS3OViSPdaff5LGdU5CtusAg(hm8jbdE88rTDmpQhzqLH28gWzB0dmzOHZAwu4d)ktythakkYlbFe1vy4eSF0zQyyWnP5nc9z2MJjc(iQRWWjxa8f0WsVcMUXbiP5nc9zUjcueeWAjy)OZ0Va7bMmp8fES8mydrWktWGPxCB6xG9apfOOIhwz)inGZ0WsfddUjSJGvEj4JOUcdN0aotdlvmm4M08gH(CS8HFj4JOUcdNG9JotfddUjnVrOpZod2qeSYKlUnDJLqxCfZsjfuqrZ9Wk7hPbCMgwQyyWnHDeSYlbFe1vy4eSF0zQyyWnP5nc9z2zWgIGvMCXTPBSe6IRywkPGcFe1vy4eSF0zQyyWnP5nc95y5d)sjLKMH)bdFsWGhpFuBhZJ6rguzOnVbC2g9atgA4SMff(WVYe20bGII8sWhrDfgob7hDMkggCtAEJqFMBIafvuXpI6kmCYfaFbnS0RGPBCasAEJqFMDgSHiyLjOiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4l8y5zWgIGvMGbtV420Va7bEQKscabSwsd4mnSuXWGBYkmCLKMzEL6sf6qOof6qisQfcuz0LAarP(k4jl1QQsnNjK6k05P0m8py4tcg845JEbWxqdl9ky6ghGkdT5nGZ2OhyYekweoDErVjSPdaff5LaXMZqh(fPCcNjE8GHlnd)dg(KGbpE(Oy)OZuXWGBLH28gWzB0dmzcflcNoVO3e20bGII8sGIInNHo8ls5eot84bdxbfeBodD4xKYjxa8f0WsVcMUXbOssZW)GHpjyWJNpkNjE8GHRm0MFWnNT5yIGgWzB0dmzcflcNoVO3e20bGII8saiG1sW(rNPFb2dmzE4l8y5zWgIGvMGbtV420Va7bEk4JOUcdNCbWxqdl9ky6ghGKM3i0N5Mi4JOUcdNG9JotfddUjnVrOphlF4xsZW)GHpjyWJNpkNjE8GHRm0MFWnNT5yIGgWzB0dmzcflcNoVO3e20bGII8sWhrDfgob7hDMkggCtAEJqFMBIafvuXpI6kmCYfaFbnS0RGPBCasAEJqFMDgSHiyLjOiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4l8y5zWgIGvMGbtV420Va7bEQKscabSwsd4mnSuXWGBYkmCLug6h3nG4rH2CqaRLmHIfHtNx0BY8Wx4CqaRLmHIfHtNx0BYglHop8fwzOFC3aIhfU38cIhNxU0m8py4tcg845JUHDh9Kgw6f9M9tzOnxXpI6kmCc2p6mvmm4M08gH(mBtRqQGcFe1vy4eSF0zQyyWnP5nc95y5MJsc(iQRWWjxa8f0WsVcMUXbiP5nc9zUjcueeWAjy)OZ0Va7bMmp8fES8mydrWktWGPxCB6xG9apfOOIhwz)inGZ0WsfddUjSJGvEj4JOUcdN0aotdlvmm4M08gH(CS8HFj4JOUcdNG9JotfddUjnVrOpZwivsbfu0CpSY(rAaNPHLkggCtyhbR8sWhrDfgob7hDMkggCtAEJqFMTqQKck8ruxHHtW(rNPIHb3KM3i0NJLp8lLusAg(hm8jbdE88rBCbr)OtrSfwzOn)JOUcdNCbWxqdl9ky6ghGKM3i0NzNbBicwzspPBSe6IRywc(iQRWWjy)OZuXWGBsZBe6ZSZGnebRmPN0nwcDXvmlbkEyL9J0aotdlvmm4MWocw5LGpI6kmCsd4mnSuXWGBsZBe6ZXYh(LckCyL9J0aotdlvmm4MWocw5LGpI6kmCsd4mnSuXWGBsZBe6ZSZGnebRmPN0nwcDXvmlfuWCpSY(rAaNPHLkggCtyhbR8sjbGawlb7hDM(fypWK5HVWJLNbBicwzcgm9IBt)cSh4PGfdcyTKla(cAyPxbt34aKScdxAg(hm8jbdE88rBCbr)OtrSfwzOn)JOUcdNCbWxqdl9ky6ghGKM3i0N5MiqrqaRLG9Jot)cShyY8Wx4XYZGnebRmbdMEXTPFb2d8uGIkEyL9J0aotdlvmm4MWocw5LGpI6kmCsd4mnSuXWGBsZBe6ZXYh(LGpI6kmCc2p6mvmm4M08gH(m7mydrWktU420nwcDXvmlLuqbfn3dRSFKgWzAyPIHb3e2rWkVe8ruxHHtW(rNPIHb3KM3i0NzNbBicwzYf3MUXsOlUIzPKck8ruxHHtW(rNPIHb3KM3i0NJLp8lLusAg(hm8jbdE88rBCbr)OtrSfwzOn)JOUcdNG9JotfddUjnVrOpZnrGIkQ4hrDfgo5cGVGgw6vW0noajnVrOpZod2qeSYeuKUXsOlUIzjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHvsbfu8JOUcdNCbWxqdl9ky6ghGKM3i0N5MiaeWAjy)OZ0Va7bMmp8fES8mydrWktWGPxCB6xG9apvsjbGawlPbCMgwQyyWnzfgUssZW)GHpjyWJNp6IXRamANvgAZ)iQRWWjy)OZuXWGBsZBe6ZCteOOIk(ruxHHtUa4lOHLEfmDJdqsZBe6ZSZGnebRmbfPBSe6IRywcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyLuqbf)iQRWWjxa8f0WsVcMUXbiP5nc9zUjcabSwc2p6m9lWEGjZdFHhlpd2qeSYemy6f3M(fypWtLusaiG1sAaNPHLkggCtwHHRK0m8py4tcg845JEbWxqdl9ky6ghGkdT5Gawlb7hDM(fypWK5HVWJLNbBicwzcgm9IBt)cSh4Pafv8Wk7hPbCMgwQyyWnHDeSYlbFe1vy4KgWzAyPIHb3KM3i0NJLp8lbFe1vy4eSF0zQyyWnP5nc9z2zWgIGvMCXTPBSe6IRywkPGckAUhwz)inGZ0WsfddUjSJGvEj4JOUcdNG9JotfddUjnVrOpZod2qeSYKlUnDJLqxCfZsjfu4JOUcdNG9JotfddUjnVrOphlF4xkjnd)dg(KGbpE(Oy)OZuXWGBLH2Cfv8JOUcdNCbWxqdl9ky6ghGKM3i0NzNbBicwzcks3yj0fxXSeacyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2yj05HVWkPGck(ruxHHtUa4lOHLEfmDJdqsZBe6ZCteacyTeSF0z6xG9atMh(cpwEgSHiyLjyW0lUn9lWEGNkPKaqaRL0aotdlvmm4MScdxAg(hm8jbdE88rBaNPHLkggCRm0MdcyTKgWzAyPIHb3Kvy4cuuXpI6kmCYfaFbnS0RGPBCasAEJqFMTPmraiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4l8y5zWgIGvMGbtV420Va7bEQKscu8JOUcdNG9JotfddUjnVrOpZUCHubfwmiG1sUa4lOHLEfmDJdqcGOssZW)GHpjyWJNpQyZt2FMgw6g6lLH2CqaRLSy8kaJ2zcGOGfdcyTKla(cAyPxbt34aKaikyXGawl5cGVGgw6vW0noajnVrOphlheWAjInpz)zAyPBOViBSe68WxyH(4FWWjy)OZuWkopcxc)ahtp4MLMH)bdFsWGhpFuSF0zkyfNNYqBoiG1swmEfGr7mbquGIkEyL9J08mC0FMWocw5La8pygMYoVH8CmtRskOa(hmdtzN3qEoMqQK0m8py4tcg845Jobe52JmO0m8py4tcg845JI9JotJguzOnheWAjy)OZ0Va7bMmp8fo3ePz4FWWNem4XZh15RGB6XBrEEkdT5k2ST5zbcwzfuWCp4lm0husaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(clnd)dg(KGbpE(OZcO9G(avmm4wzOnheWAjy)OZuXWGBYkmCbGawlPbCMgwQyyWnzfgUGfdcyTKla(cAyPxbt34aKScdxWhrDfgob7hDMkggCtAEJqFMTjc(iQRWWjxa8f0WsVcMUXbiP5nc9z2MiqrZ9Wk7hPbCMgwQyyWnHDeSYlfuqXdRSFKgWzAyPIHb3e2rWkVe8ruxHHtAaNPHLkggCtAEJqFMTjkPK0m8py4tcg845JI9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)e0aoBJEGjy)OZuOBHo8YIWMoauuKxcoSY(rWTyfAHpEWWjSJGvEja)dMHPSZBiphZ8ind)dg(KGbpE(Oy)OZ0nCoHvEQm0MdcyTKVYy)48G(aPz8pbnGZ2Ohyc2p6mf6wOdVSiSPdaff5La8pygMYoVH8CmtR0m8py4tcg845JI9Jot5seRXegUYqBoiG1sW(rNPFb2dmzE4l8yGawlb7hDM(fypWKnwcDE4lS0m8py4tcg845JI9Jot5seRXegUYqBoiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(clqS5m0HFrkNG9JotbXUXbwAg(hm8jbdE88rX(rNPGy34aRm0MdcyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2yj05HVWsZW)GHpjyWJNpkNjE8GHRm0pUBaXJcT5B0rI4FzNluesLH(XDdiEu4EZliECE5sZKMH)bdFs(iQRWWN5v4qXnPcXbwdB2pLH2CqaRLG9JotfddUjRWWfacyTKgWzAyPIHb3Kvy4cwmiG1sUa4lOHLEfmDJdqYkmCPz4FWWNKpI6km8545JcId0WsVg(cpvgAZbbSwc2p6mvmm4MScdxaiG1sAaNPHLkggCtwHHlyXGawl5cGVGgw6vW0noajRWWLMH)bdFs(iQRWWNJNp6J1kf)dgoTcNNYoU5C4X7PYqBoiG1sW(rNPIHb3earPz4FWWNKpI6km8545JkghmCLH2CqaRLG9JotfddUjaIsZW)GHpjFe1vy4ZXZhfK7j3cd9bLH2CqaRLG9JotfddUjaIsZW)GHpjFe1vy4ZXZhfSgXIAb6SugAZbbSwc2p6mvmm4Maiknd)dg(K8ruxHHphpFulSzWAelLH2CqaRLG9JotfddUjaIsZW)GHpjFe1vy4ZXZhf9NNxJv6J1QYqBoiG1sW(rNPIHb3earPzMxPwOoAy0WdkeJLAGj0hK6HgoRzj1Wh(vwQnGxHuJIePwO3KLA4j1gWRqQV42sDCfCBaNmrQLMH)bdFs(iQRWWNJNpQTJ5r9idQm0M3aoBJEGjdnCwZIcF4xzcB6aqrrEj4JOUcdNG9JotfddUjnVrOpZ2CmrWhrDfgo5cGVGgw6vW0noajnVrOpZnrGIGawlb7hDM(fypWK5HVWJLBkbkQ4Hv2psd4mnSuXWGBc7iyLxc(iQRWWjnGZ0WsfddUjnVrOphlF4xc(iQRWWjy)OZuXWGBsZBe6ZSZGnebRm5IBt3yj0fxXSusbfu0CpSY(rAaNPHLkggCtyhbR8sWhrDfgob7hDMkggCtAEJqFMDgSHiyLjxCB6glHU4kMLskOWhrDfgob7hDMkggCtAEJqFow(WVusjPz4FWWNKpI6km8545JA7yEupYGkdT5nGZ2OhyYqdN1SOWh(vMWMoauuKxc(iQRWWjy)OZuXWGBsZBe6ZCteOO5EyL9JWEfouCSZlc7iyLxkOGIhwz)iSxHdfh78IWocw5LGn6ir8VSZfAMOKscuuXpI6kmCYfaFbnS0RGPBCasAEJqFMD5MiaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHvsbfu8JOUcdNCbWxqdl9ky6ghGKM3i0N5MiaeWAjy)OZ0Va7bMmp8fo3eLusaiG1sAaNPHLkggCtwHHlyJose)l78mydrWktqr6g6WnWMUrhPI)jnd)dg(K8ruxHHphpFuBhZdmQNYqBEd4Sn6bMSGZhkwHo2zr)yVrFrythakkYlbFe1vy4eqaRLUGZhkwHo2zr)yVrFrAgxzjaeWAjl48HIvOJDw0p2B0xuBhZJScdxGIGawlb7hDMkggCtwHHlaeWAjnGZ0WsfddUjRWWfSyqaRLCbWxqdl9ky6ghGKvy4kj4JOUcdNCbWxqdl9ky6ghGKM3i0N5MiqrqaRLG9Jot)cShyY8Wx4XYnLafv8Wk7hPbCMgwQyyWnHDeSYlbFe1vy4KgWzAyPIHb3KM3i0NJLp8lbFe1vy4eSF0zQyyWnP5nc9z2zWgIGvMCXTPBSe6IRywkPGckAUhwz)inGZ0WsfddUjSJGvEj4JOUcdNG9JotfddUjnVrOpZod2qeSYKlUnDJLqxCfZsjfu4JOUcdNG9JotfddUjnVrOphlF4xkPK0m8py4tYhrDfg(C88rTWMPGvCEkdT5nGZ2OhyYcoFOyf6yNf9J9g9fHnDaOOiVe8ruxHHtabSw6coFOyf6yNf9J9g9fPzCLLaqaRLSGZhkwHo2zr)yVrFrTWMjRWWfi2Cg6WViLtSDmpWOEsZmVsTPz1aZAk1atwQ3WUJEk1gWRqQrrIul01k1xCBPgoL6MXvwsnoLAdUwvwQ3OWSupbAwQVqQFCEsn8KAq2gnl1xCBI0m8py4tYhrDfg(C88r3WUJEsdl9IEZ(Pm0M)ruxHHtUa4lOHLEfmDJdqsZBe6ZCteacyTeSF0z6xG9atMh(cpwUPe8ruxHHtW(rNPIHb3KM3i0NJLp8lPz4FWWNKpI6km8545JUHDh9Kgw6f9M9tzOn)JOUcdNG9JotfddUjnVrOpZnrGIM7Hv2pc7v4qXXoViSJGvEPGckEyL9JWEfouCSZlc7iyLxc2OJeX)YoxOzIskjqrf)iQRWWjxa8f0WsVcMUXbiP5nc9z2zWgIGvMGI0nwcDXvmlbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnwcDE4lSskOGIFe1vy4Kla(cAyPxbt34aK08gH(m3ebGawlb7hDM(fypWK5HVW5MOKscabSwsd4mnSuXWGBYkmCbB0rI4FzNNbBicwzcks3qhUb20n6iv8pPzMxP20SAGznLAGjl1lgVcWODwQnGxHuJIePwORvQV42snCk1nJRSKACk1gCTQSuVrHzPEc0SuFHu)48KA4j1GSnAwQV42ePz4FWWNKpI6km8545JUy8kaJ2zLH28pI6kmCYfaFbnS0RGPBCasAEJqFMBIaqaRLG9Jot)cShyY8Wx4XYnLGpI6kmCc2p6mvmm4M08gH(CS8HFjnd)dg(K8ruxHHphpF0fJxby0oRm0M)ruxHHtW(rNPIHb3KM3i0N5MiqrZ9Wk7hH9kCO4yNxe2rWkVuqbfpSY(ryVchko25fHDeSYlbB0rI4FzNl0mrjLeOOIFe1vy4Kla(cAyPxbt34aK08gH(m7YnraiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4lCUjkPKaqaRL0aotdlvmm4MScdxWgDKi(x25zWgIGvMGI0n0HBGnDJosf)tAM5vQf6nzPEkITWsn0k1xCBPg9LuJIsn2SuhUu)lPg9LuBeU5Fsnil1aIsTnAPUg(a3s9vGUuFfSuVXsK6fxXSuwQ3OWqFqQNanl1gSuxGzyPgpPUY48K6ZiKASF0zP(lWEGNsn6lP(kWtQV42sTboDZ)KAH4aZtQbM8Iind)dg(K8ruxHHphpF0gxq0p6ueBHvgAZ)iQRWWjxa8f0WsVcMUXbiP5nc9z2zWgIGvM0t6glHU4kMLGpI6kmCc2p6mvmm4M08gH(m7mydrWkt6jDJLqxCfZsGIhwz)inGZ0WsfddUjSJGvEj4JOUcdN0aotdlvmm4M08gH(CS8HFPGchwz)inGZ0WsfddUjSJGvEj4JOUcdN0aotdlvmm4M08gH(m7mydrWkt6jDJLqxCfZsbfm3dRSFKgWzAyPIHb3e2rWkVusaiG1sW(rNPFb2dmzE4lC2MsWIbbSwYfaFbnS0RGPBCaswHHlnZ8k1c9MSupfXwyP2aEfsnkk1gfSl1IXCcbRmrQf6AL6lUTudNsDZ4klPgNsTbxRkl1BuywQNanl1xi1popPgEsniBJML6lUnrAg(hm8j5JOUcdFoE(OnUGOF0Pi2cRm0M)ruxHHtUa4lOHLEfmDJdqsZBe6ZCteacyTeSF0z6xG9atMh(cpwUPe8ruxHHtW(rNPIHb3KM3i0NJLp8lPz4FWWNKpI6km8545J24cI(rNIylSYqB(hrDfgob7hDMkggCtAEJqFMBIafv0CpSY(ryVchko25fHDeSYlfuqXdRSFe2RWHIJDEryhbR8sWgDKi(x25cntusjbkQ4hrDfgo5cGVGgw6vW0noajnVrOpZod2qeSYeuKUXsOlUIzjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHvsbfu8JOUcdNCbWxqdl9ky6ghGKM3i0N5MiaeWAjy)OZ0Va7bMmp8fo3eLusaiG1sAaNPHLkggCtwHHlyJose)l78mydrWktqr6g6WnWMUrhPI)PK0mZRul0zwneDHiPwO3KL6lUTudTsnkk1WPuhUu)lPg9LuBeU5Fsnil1aIsTnAPUg(a3s9vGUuFfSuVXsK6fxXSisTPzfo4sTb8kK6oeLAOvQVcwQpSY(j1WPuFOWStKAH6oQlPgLAq4j1xi1BuywQNanl1gSu)Ol1c1uLA4EZliECnlPgTh3s9f3wQzFnLMH)bdFs(iQRWWNJNp6faFbnS0RGPBCaQm0MdcyTeSF0z6xG9atMh(cpwUPeCyL9J0aotdlvmm4MWocw5LGpI6kmCsd4mnSuXWGBsZBe6ZXYh(LGpI6kmCc2p6mvmm4M08gH(m7mydrWktU420nwcDXvmlbFKHD0pIWz1q0jSJGvEj4JOUcdN04cI(rNIylmP5nc95y5cfPzMxPUSWfcwOZSAi6crsTqVjl1xCBPgALAuuQHtPoCP(xsn6lP2iCZ)KAqwQbeLAB0sDn8bUL6RaDP(kyPEJLi1lUIzrKAtZkCWLAd4vi1Dik1qRuFfSuFyL9tQHtP(qHzNind)dg(K8ruxHHphpF0la(cAyPxbt34auzOnheWAjy)OZ0Va7bMmp8fESCtj4Wk7hPbCMgwQyyWnHDeSYlbFe1vy4KgWzAyPIHb3KM3i0NJLp8lbFe1vy4eSF0zQyyWnP5nc9z2zWgIGvMCXTPBSe6IRywcm3pYWo6hr4SAi6e2rWkVKMH)bdFs(iQRWWNJNp6faFbnS0RGPBCaQm0MdcyTeSF0z6xG9atMh(cpwUPeyUhwz)inGZ0WsfddUjSJGvEj4JOUcdNG9JotfddUjnVrOpZod2qeSYKlUnDJLqxCfZsAg(hm8j5JOUcdFoE(Oxa8f0WsVcMUXbOYqBoiG1sW(rNPFb2dmzE4l8y5MsWhrDfgob7hDMkggCtAEJqFow(WVKMzELAHEtwQrrPgAL6lUTudNsD4s9VKA0xsTr4M)j1GSudik12OL6A4dCl1xb6s9vWs9glrQxCfZszPEJcd9bPEc0SuFf4j1gSuxGzyPM9ayOqQ3OJsn6lP(kWtQVcUzPgoLApoPgRnJRSKAuQBaNL6Wk1IHb3s9kmCI0m8py4tYhrDfg(C88rX(rNPIHb3kdT5kAUhwz)iSxHdfh78IWocw5LckO4Hv2pc7v4qXXoViSJGvEjyJose)l7CHMjkPKGpI6kmCYfaFbnS0RGPBCasAEJqFMDgSHiyLjOiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(claeWAjnGZ0WsfddUjRWWfSrhjI)LDEgSHiyLjOiDdD4gyt3OJuX)KMzELAHEtwQ7quQHwP(IBl1WPuhUu)lPg9LuBeU5Fsnil1aIsTnAPUg(a3s9vGUuFfSuVXsK6fxXSuwQ3OWqFqQNanl1xb3SudNU5FsnwBgxzj1Ou3aol1RWWLA0xs9vGNuJIsTr4M)j1G8hBwQXmiSIGvwQxan0hK6gWzI0m8py4tYhrDfg(C88rBaNPHLkggCRm0MdcyTKgWzAyPIHb3Kvy4c(iQRWWjxa8f0WsVcMUXbiP5nc9z2zWgIGvM0HiDJLqxCfZsaiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(clqXpI6kmCc2p6mvmm4M08gH(m7YfsfuyXGawl5cGVGgw6vW0noajaIkjnZ8k1cDMvdrxisQfQPk1WPuVrhL6caFOZsQrFj1MMJyANsn2SuFri1CjISpHzyP(cPgyYsTySL6lK6PPdWSqmwQrxQ5sUgLAeuQHUuFfSuFXTLAdOVcdIuBAWN5pLAGjl1WtQVqQ3OWSuxddP(lWEGLAtZrMsn0Nh6hrAg(hm8j5JOUcdFoE(OInpz)zAyPBOVugAZbbSwc2p6m9lWEGjZdFHZnrWhzyh9JiCwneDc7iyLxsZmVsDzHleSqNz1q0fIKAHEtwQfJTuFHupnDaMfIXsn6snxY1OuJGsn0L6RGL6lUTuBa9vyqKMH)bdFs(iQRWWNJNpQyZt2FMgw6g6lLH28fdcyTKla(cAyPxbt34aKaikWC)id7OFeHZQHOtyhbR8sAg(hm8j5JOUcdFoE(OatMUrhPd8wzOn)JOUcdNWzIhpy4KM3i0NzBIafv8Wk7hH9kCO4yNxe2rWkVeSrhjI)nwUqXebB0rI4FzNBEesLuqbfn3dRSFe2RWHIJDEryhbR8sWgDKi(3y5cfHujLKMjnZ8k1JynnLAHGLAHA8oYWsTPbEClnd)dg(KWZj7ppZbRrSOHLEfmLDENLYqB(hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4l8y5MsWhrDfgob7hDMkggCtAEJqFow(WVuqHd7b(ihCZ0lOlip2hrDfgob7hDMkggCtAEJqFknd)dg(KWZj7pphpFuWAelAyPxbtzN3zPm0M)ruxHHtW(rNPIHb3KM3i0N5MiqrZ9Wk7hH9kCO4yNxe2rWkVuqbfpSY(ryVchko25fHDeSYlbB0rI4FzNl0mrjLeOOIFe1vy4Kla(cAyPxbt34aK08gH(m7YnraiG1sW(rNPFb2dmzE4lCoiG1sW(rNPFb2dmzJLqNh(cRKckO4hrDfgo5cGVGgw6vW0noajnVrOpZnraiG1sW(rNPFb2dmzE4lCUjkPKaqaRL0aotdlvmm4MScdxWgDKi(x25zWgIGvMGI0n0HBGnDJosf)tAg(hm8jHNt2FEoE(OgrxxzyOtBEgo6pRm0M)ruxHHtUa4lOHLEfmDJdqsZBe6ZCteacyTeSF0z6xG9atMh(cpwUPe8ruxHHtW(rNPIHb3KM3i0NJLp8lfu4WEGpYb3m9c6cYJ9ruxHHtW(rNPIHb3KM3i0NsZW)GHpj8CY(ZZXZh1i66kddDAZZWr)zLH28pI6kmCc2p6mvmm4M08gH(m3ebkAUhwz)iSxHdfh78IWocw5LckO4Hv2pc7v4qXXoViSJGvEjyJose)l7CHMjkPKafv8JOUcdNCbWxqdl9ky6ghGKM3i0NzxUjcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyLuqbf)iQRWWjxa8f0WsVcMUXbiP5nc9zUjcabSwc2p6m9lWEGjZdFHZnrjLeacyTKgWzAyPIHb3Kvy4c2OJeX)Yopd2qeSYeuKUHoCdSPB0rQ4FsZW)GHpj8CY(ZZXZhDaa7feDAyPOqmUJRqzOn)JOUcdNCbWxqdl9ky6ghGKM3i0N5MiaeWAjy)OZ0Va7bMmp8fESCtj4JOUcdNG9JotfddUjnVrOphlF4xkOWH9aFKdUz6f0fKh7JOUcdNG9JotfddUjnVrOpLMH)bdFs45K9NNJNp6aa2li60WsrHyChxHYqB(hrDfgob7hDMkggCtAEJqFMBIafn3dRSFe2RWHIJDEryhbR8sbfu8Wk7hH9kCO4yNxe2rWkVeSrhjI)LDUqZeLusGIk(ruxHHtUa4lOHLEfmDJdqsZBe6ZSl3ebGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnwcDE4lSskOGIFe1vy4Kla(cAyPxbt34aK08gH(m3ebGawlb7hDM(fypWK5HVW5MOKscabSwsd4mnSuXWGBYkmCbB0rI4FzNNbBicwzcks3qhUb20n6iv8pPz4FWWNeEoz)5545J(H)SFnE8IAR4MvUcDM(RCZJYqBoiG1sW(rNPIHb3Kvy4cabSwsd4mnSuXWGBYkmCblgeWAjxa8f0WsVcMUXbizfgUGn6i5GBMEbDJLKDoxc)ahtp4MLMH)bdFs45K9NNJNpAZOi0hO2kU5PYqBoiG1sW(rNPIHb3Kvy4cabSwsd4mnSuXWGBYkmCblgeWAjxa8f0WsVcMUXbizfgUGn6i5GBMEbDJLKDoxc)ahtp4MLMH)bdFs45K9NNJNpQnEGjVOOqmUHhtbzCRm0MdcyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlnd)dg(KWZj7pphpFurGgAZc6duWkopLH2CqaRLG9JotfddUjRWWfacyTKgWzAyPIHb3Kvy4cwmiG1sUa4lOHLEfmDJdqYkmCPz4FWWNeEoz)5545J2qrXktHoDkIpRm0MdcyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlnd)dg(KWZj7pphpF0RGPaoya4lQn6NvgAZbbSwc2p6mvmm4MScdxaiG1sAaNPHLkggCtwHHlyXGawl5cGVGgw6vW0noajRWWLMH)bdFs45K9NNJNp6M3rNfnS0kWdx0vZ4EQm0MdcyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlntAg(hm8jXcDSsbbAph7hDMUHZjSYtLH2CqaRL8vg7hNh0hinJ)P8xGqpVCPz4FWWNel0XkfeO9XZhf7hDMcwX5jnd)dg(KyHowPGaTpE(Oy)OZuqSBCGLMjnd)dg(KapEpZbMmfE8EkntAg(hm8jzhz4n7xoyf6ctrplLH28DKH3SFKfCEO)C25LBI0m8py4tYoYWB2VXZhvS5j7ptdlDd9L0m8py4tYoYWB2VXZhf7hDMUHZjSYtLH28DKH3SFKfCEO)8yLBI0m8py4tYoYWB2VXZhf7hDMgnO0m8py4tYoYWB2VXZh1cBMcwX5jntAM5vQX)GHpjHi7CNNbBicwzLDCZ5fygMgISZlLdX8jFkNbRaCE5kdT5InNHo8ls5eot84bdxAg(hm8jjezN7XZhTchkUjvioWAyZ(Pm0MdcyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlnd)dg(KeISZ945JcId0WsVg(cpvgAZbbSwc2p6mvmm4MScdxaiG1sAaNPHLkggCtwHHlyXGawl5cGVGgw6vW0noajRWWLMH)bdFscr25E88rFSwP4FWWPv48u2XnNdpEpvgAZbbSwc2p6mvmm4Maiknd)dg(KeISZ945JkghmCLH2CqaRLG9JotfddUjaIsZW)GHpjHi7CpE(OGCp5wyOpOm0MdcyTeSF0zQyyWnbquAg(hm8jjezN7XZhfSgXIAb6SugAZbbSwc2p6mvmm4Maiknd)dg(KeISZ945JAHndwJyPm0MdcyTeSF0zQyyWnbquAg(hm8jjezN7XZhf9NNxJv6J1QYqBoiG1sW(rNPIHb3earPz4FWWNKqKDUhpFulSzkyfNNYqBEd4Sn6bMSGZhkwHo2zr)yVrFrythakkYlbGawlzbNpuScDSZI(XEJ(IA7yEearPz4FWWNKqKDUhpFuBhZJ6rguzOnVbC2g9atgA4SMff(WVYe20bGII8sWgDKi(x2cHcP0m8py4tsiYo3JNp6g2D0tAyPx0B2pPz4FWWNKqKDUhpF0fJxby0olnd)dg(KeISZ945J24cI(rNIylSYqB(gDKi(x2MwtKMH)bdFscr25E88rF0FUsX)GHRm0MJ)bdNmlG2d6duXWGBYxGUZvOpiy4xKM3i0N5Mind)dg(KeISZ945JolG2d6duXWGBLH28zaubH(IyHCDrdlfSgZzSNe2rWkVKMH)bdFscr25E88rVa4lOHLEfmDJdqPz4FWWNKqKDUhpFuSF0zQyyWT0m8py4tsiYo3JNpAd4mnSuXWGBLH2CqaRL0aotdlvmm4MScdxAg(hm8jjezN7XZhfyY0n6iDG3kdT5kEyL9JWEfouCSZlc7iyLxc2OJeX)glxOyIGn6ir8VSZnpcPskOGIM7Hv2pc7v4qXXoViSJGvEjyJose)BSCHIqQK0m8py4tsiYo3JNpki3tUfg6dkdT5Gawlb7hDMkggCtaeLMH)bdFscr25E88rp4MPgylQm0M3aoBJEGjhVfJgRudSfjSPdaff5L0m8py4tsiYo3JNpQyZt2FMgw6g6lLH28fdcyTKla(cAyPxbt34aKaikyXGawl5cGVGgw6vW0noajnVrOphlheWAjInpz)zAyPBOViBSe68WxyH(4FWWjy)OZuWkopcxc)ahtp4MLMH)bdFscr25E88rX(rNPGvCEkdT5R4inUGOF0Pi2ctAEJqFMTqQGclgeWAjnUGOF0Pi2ctZauDUrqyfEzrMh(cNTjsZW)GHpjHi7CpE(Oy)OZuWkopLH2CqaRLi28K9NPHLUH(IaikyXGawl5cGVGgw6vW0noajaIcwmiG1sUa4lOHLEfmDJdqsZBe6ZXYX)GHtW(rNPGvCEeUe(boMEWnlnd)dg(KeISZ945JI9JotbXUXbwzOnheWAjy)OZuXWGBcGOaqaRLG9JotfddUjnVrOphlF4xcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyPz4FWWNKqKDUhpFuSF0z6goNWkpvgAZxmiG1sUa4lOHLEfmDJdqcGOGdRSFeSF0zk)fbHDeSYlbGawlzX4vagTZKvy4cwmiG1sUa4lOHLEfmDJdqsZBe6ZSX)GHtW(rNPB4CcR8KWLWpWX0dUzL)ce65Llnd)dg(KeISZ945JI9Jot3W5ew5PYqBoiG1s(kJ9JZd6dKMX)u(lqONxU0m8py4tsiYo3JNpk2p6mnAqLH2CqaRLG9Jot)cShyY8Wx4XYnLaf)iQRWWjy)OZuXWGBsZBe6ZSl3efua)dMHPSZBiphl3ukjnd)dg(KeISZ945JI9JotbR48ugAZbbSwsd4mnSuXWGBcGOckSrhjI)LD5cP0m8py4tsiYo3JNpkNjE8GHRm0MdcyTKgWzAyPIHb3Kvy4kd9J7gq8OqB(gDKi(x25cfHuzOFC3aIhfU38cIhNxU0m8py4tsiYo3JNpk2p6mfe7ghyPzsZW)GHpjDC4bdppd2qeSYk74MZTqhRuqG2voeZN8PCgScW5LRm0MdcyTeSF0z6xG9atMh(cNdcyTeSF0z6xG9at2yj05HVWcmxqaRL0avMgw6v0mpjaIcoSh4JCWntVGUG8y5kQ4gDuO(4FWWjy)OZuWkopYhZtjH(4FWWjy)OZuWkopcxc)ahtp4MvsAM5vQX)GHpjDC4bdF88rNxd)JozthG9NvgAZxmiG1sACbr)OtrSfMMbO6CJGWk8YImp8foFXGawlPXfe9JofXwyAgGQZnccRWllYglHop8fwaiG1sW(rNPIHb3Kvy4cabSwsd4mnSuXWGBYkmCLDCZ5vCE0Pi2ctNh(cleH9JotbR48eIW(rNPGy34alnd)dg(K0XHhm8XZhf7hDMcIDJdSYqB(IbbSwsJli6hDkITW0mavNBeewHxwK5HVW5lgeWAjnUGOF0Pi2ctZauDUrqyfEzr2yj05HVWcueeWAjy)OZuXWGBYkmCfuaeWAjy)OZuXWGBsZBe6ZXYh(LscueeWAjnGZ0WsfddUjRWWvqbqaRL0aotdlvmm4M08gH(CS8HFPK0m8py4tshhEWWhpFuSF0zkyfNNYqB(kosJli6hDkITWKM3i0NzlKkOWIbbSwsJli6hDkITW0mavNBeewHxwK5HVWzBI0m8py4tshhEWWhpFuSF0zkyfNNYqBoiG1seBEY(Z0Ws3qFraefSyqaRLCbWxqdl9ky6ghGearblgeWAjxa8f0WsVcMUXbiP5nc95y54FWWjy)OZuWkopcxc)ahtp4MLMH)bdFs64Wdg(45JI9Jot3W5ew5PYqB(IbbSwYfaFbnS0RGPBCasaefCyL9JG9Jot5ViiSJGvEjaeWAjlgVcWODMScdxGIlgeWAjxa8f0WsVcMUXbiP5nc9z24FWWjy)OZ0nCoHvEs4s4h4y6b3Sck8ruxHHteBEY(Z0Ws3qFrAEJqFMTjkOWhzyh9JiCwneDc7iyLxkP8xGqpVCPz4FWWNKoo8GHpE(Oy)OZ0nCoHvEQm0MdcyTKVYy)48G(aPz8pbGawlHlre9fVOIXX(bXkbquAg(hm8jPJdpy4JNpk2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)tGIGawlb7hDMkggCtaevqbqaRL0aotdlvmm4MaiQGclgeWAjxa8f0WsVcMUXbiP5nc9z24FWWjy)OZ0nCoHvEs4s4h4y6b3Ssk)fi0ZlxAg(hm8jPJdpy4JNpk2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)taiG1s(kJ9JZd6dK5HVW5Gawl5Rm2popOpq2yj05HVWk)fi0ZlxAg(hm8jPJdpy4JNpk2p6mDdNtyLNkdT5Gawl5Rm2popOpqAg)taiG1s(kJ9JZd6dKM3i0NJLROIGawl5Rm2popOpqMh(cl0h)dgob7hDMUHZjSYtcxc)ahtp4MvA8HFPKYFbc98YLMH)bdFs64Wdg(45J68vWn94TippLH2CfB228SabRSckyUh8fg6dkjaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHfacyTeSF0zQyyWnzfgUGfdcyTKla(cAyPxbt34aKScdxAg(hm8jPJdpy4JNpk2p6mnAqLH2CqaRLG9Jot)cShyY8Wx4XYnL0m8py4tshhEWWhpF0jGi3EKbvgAZ3OJeX)glxiuifacyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlnd)dg(K0XHhm8XZhDwaTh0hOIHb3kdT5Gawlb7hDMkggCtwHHlaeWAjnGZ0WsfddUjRWWfSyqaRLCbWxqdl9ky6ghGKvy4c(iQRWWjCM4XdgoP5nc9z2Mi4JOUcdNG9JotfddUjnVrOpZ2ebFe1vy4Kla(cAyPxbt34aK08gH(mBteOO5EyL9J0aotdlvmm4MWocw5LckO4Hv2psd4mnSuXWGBc7iyLxc(iQRWWjnGZ0WsfddUjnVrOpZ2eLusAg(hm8jPJdpy4JNpk2p6mfSIZtzOnheWAjnqLPHLEfnZtcGOaqaRLG9Jot)cShyY8Wx4SnhPzMxPEeRPPuleSuluJ3rgwQnnWJBPz4FWWNKoo8GHpE(Oy)OZuqSBCGvgAZ3OJeX)gld2qeSYeqSBCGPB0rQ4Fc(iQRWWjCM4XdgoP5nc9z2MiaeWAjy)OZuXWGBYkmCbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnwcDE4lSaEoz)zsg4egonSurUT8FWWjBOhT0m8py4tshhEWWhpFuSF0zki2noWkdT5Fe1vy4Kla(cAyPxbt34aK08gH(m3ebk(ruxHHtAaNPHLkggCtAEJqFMBIck8ruxHHtW(rNPIHb3KM3i0N5MOKaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwAg(hm8jPJdpy4JNpk2p6mfe7ghyLH28n6ir8VXYZGnebRmbe7ghy6gDKk(NaqaRLG9JotfddUjRWWfacyTKgWzAyPIHb3Kvy4cwmiG1sUa4lOHLEfmDJdqYkmCbGawlb7hDM(fypWK5HVW5Gawlb7hDM(fypWKnwcDE4lSGpI6kmCcNjE8GHtAEJqFMTjsZW)GHpjDC4bdF88rX(rNPGy34aRm0MdcyTeSF0zQyyWnzfgUaqaRL0aotdlvmm4MScdxWIbbSwYfaFbnS0RGPBCaswHHlaeWAjy)OZ0Va7bMmp8foheWAjy)OZ0Va7bMSXsOZdFHfCyL9JG9JotJgKWocw5LGpI6kmCc2p6mnAqsZBe6ZXYh(LGn6ir8VXYfcnrWhrDfgoHZepEWWjnVrOpZ2ePz4FWWNKoo8GHpE(Oy)OZuqSBCGvgAZbbSwc2p6mvmm4MaikaeWAjy)OZuXWGBsZBe6ZXYh(LaqaRLG9Jot)cShyY8Wx4CqaRLG9Jot)cShyYglHop8fwAg(hm8jPJdpy4JNpk2p6mfe7ghyLH2CqaRL0aotdlvmm4MaikaeWAjnGZ0WsfddUjnVrOphlF4xcabSwc2p6m9lWEGjZdFHZbbSwc2p6m9lWEGjBSe68WxyPz4FWWNKoo8GHpE(Oy)OZuWkopPz4FWWNKoo8GHpE(OCM4XdgUYq)4Ubepk0MVrhjI)LDUqrivg6h3nG4rH7nVG4X5Llnd)dg(K0XHhm8XZhf7hDMcIDJdC6sxkba]] )


end
