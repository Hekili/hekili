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
            duration = 3600,
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
        }
    } )


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

            spend = function ()
                if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
                return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 136116,

            usable = function () return target.distance < 10, "target out of range" end,
            handler = function ()
                removeStack( "clearcasting" )
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
                else removeStack( "clearcasting" )
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
            
            startsCombat = true,
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
            cast = 0,
            cooldown = 120,
            gcd = "off",
    
            startsCombat = false,
            texture = 134132,
    
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
            }
        }


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


    spec:RegisterPack( "Arcane", 20200903.1, [[d0e4vbqivvPhjuPlPKuQ2KK4tcvWOeQ6usswLsQ4vuuMfj0TusQ2fL(LqXWKK6ykPSmsuEgjQMMQQ4AuuPTPKQ6BKisJtOI6CkPsRJerL5PK4EkX(ir6GkjzHcrpuOImrsev1fvsvSrsev5JkjfXjjruwPQkVujPOMPssr6MKiI2PqPFQKukdvOcTuLKsEkbtviCvLKcFLeryVK6Venyihg1IvQhd1Kr0LbBwIpRQmAj1PrA1kPk9AsWSr42K0UP63snCcDCsewUONly6QCDvz7uKVtHXRQQopfvTEkQy(cP9Ry9A6i0cK8b6yvw1kR6Qx3QvUDT1v5MB1)rlCMxe0cImwb(d0coRcAHvLy2bTGiBEIMj1rOfc9lXGwO(oXGsUyI5JE1VTf3QXeOQpc(OTJtUCXeOQ4y0c7hL4uYC9wlqYhOJvzvRSQREDRw521wxLBUvRCTqqeW6yxFLPfQPKKGR3AbsiG1cXDqRkXSddsjj)bZV4oibq8a1nKds5koiLvTYQE(n)I7GIt1S)bbLCZV4oOvFqHJZtUFPlfR5aO4Gcxlk3V0LI1CauCqStoi2eK8hi3V0LeG)D1dItyq1StsaKdAB(bD1WGysY2TZV4oOvFqhNFWzpQkiVwssHbT6kDqXFuvqETKKcvnOqpORMVbzadIS94Wni4FmecutaH5h0(L(GAFqxYH6brldYagez7XHBqgSFd6A78lUdA1h0QHijFWGe7J2(Gi6pk2QfiOHlOJqlGBpaPjqhHo210rOfy8rBxlOsZStjvL)aTa48Mai1rQpDSkthHwaCEtaK6i1c4KEqszTq8dkHscHAEtadkA0b93bDuScu)BqvnOkdA)kflNy2bjUMZpWgogRWGwg0(vkwoXSdsCnNFGvL)xgogRWGQmO9RuS5ZbzxKITbKwY2WhuLbTFLILtm7GuSnG0s2gUwGXhTDTGdxnKYdufHWPpDSkxhHwaCEtaK6i1c4KEqszTW(vkwoXSdsCnNFGnCmwHbTmOQhuLbX4JAcKGdQuimiLoO1guLbX4JAcKK9zV(HRLDrE1GuL)OdAzqvRfy8rBxlC9dxl7I8QbPk)r1No2)OJqlaoVjasDKAbCspiPSwy)kflNy2bjUMZpWgogRWGwzzqkBqvgu8dc3nbzB4woXSdsX2asBcQm1ddsPdATQhu0OdIXh1eibhuPqyqRSmiLnOQ0cm(OTRf4eZoi7CRpDSMRocTa48Mai1rQfWj9GKYAH9RuS5JaKDrE1jab7tCqvg0(vkwoXSdsCnNFGnCmwHbP0bPCTaJpA7AboXSdYnbho9PJD91rOfaN3eaPosTaJpA7AHJscHRtvjUjH)1c4KEqszTW(vk285GSlsX2aslzB4dQYG(7G2VsXYjMDqk2gqAtGX3GQmiC3eKTHB5eZoifBdiTjOYupmiLoiLvTwWzvqlCusiCDQkXnj8V(0XQKQJqlaoVjasDKAbgF021cyZJj6lBNILBcoCAbCspiPSwy)kfB(Cq2fPyBaPLSn8bvzq)Dq7xPy5eZoifBdiTjW4BqvgeUBcY2WTCIzhKITbK2euzQhgKshKYQwlaLcGpPZQGwaBEmrFz7uSCtWHtF6yJZ6i0cGZBcGuhPwaN0dskRf2VsXMphKDrk2gqAjBdFqvg0(vkwoXSdsCnNFGnCmwHbTmO9RuSCIzhK4Ao)aRk)VmCmwHbvzqXpOYJGqMaUMZpqEuvyqRSmi4Fa)oqEuvyqrJoOYJGqMaUMZpqEuvyqRSmiC3eKTHB5eZoifBdiTjOYupmOOrh0X5hC2JQcYRLKuyqRSmiC3eKTHB5eZoifBdiTjOYupmOQ0cm(OTRfYNdYUifBdi1No21vhHwaCEtaK6i1cm(OTRf4eZoivPHaLacAbCntDTWAAbCspiPSwqLD2kIVbTYYGwxZDqvg0(vkwmbWjMdh1)SjW4BqvgeJpQjqcoOsHWGwzqkxF6yxRADeAbW5nbqQJulGt6bjL1cXpO4h0(vkwoXSdsCnNFGnCmwHbTmO9RuSCIzhK4Ao)aRk)VmCmwHbv1GQmO4hu8dsLD2kIVbTYYGmXjL3eGf3EastGuLDEqvnOOrhu8d6ycWpB(Cq2fPyBaPfCEtaKdQYGWDtq2gULtm7GuSnG0MGkt9WGu6GWDtq2gUnFoi7IuSnG0wEeeYeW1C(bYJQcdQYGuzNTI4BqRSmitCs5nbyXThG0eivzNhKzdszM7GQAqvnOOrhu8d6ycWplNy2bzNBl48MaihuLbH7MGSnClNy2bzNBBcQm1ddALLb9HjhuLbH7MGSnClNy2bPyBaPnbvM6HbP0bTw1dQQbv1GIgDqQSZwr8nOvwgu8dYeNuEtawC7binbsv25bT6dATQhuvAbgF021cCIzhKBot(d0No21wthHwaCEtaK6i1c4KEqszTGk7SveFdALLbTUMRwGXhTDTq4jcP3My9PJDnLPJqlaoVjasDKAbCspiPSwy)kflNy2bjUMZpWgogRWGwg0FguLbTFLILtm7GuSnG0s2gUwGXhTDTqYKu2pzqKtf0No21uUocTa48Mai1rQfWj9GKYAH9RuSCIzhK4Ao)aB4yScdAzq)zqvg0(vkwoXSdsX2aslzB4dQYGIFq4UjiBd3YjMDqk2gqAtqLPEyqRmiLpO1zqFyYbfn6GWDtq2gULtm7GuSnG0MGkt9WGu6GwR6bvLwGXhTDTajWx9Uth0No21(JocTa48Mai1rQfWj9GKYAbgFutGeCqLcHbP0LbP8bvzqXpiv2zRi(gKsxgKjoP8MaS42dqAcKQSZdkA0bTFLILtm7GexZ5hydhJvyqlds5dQkTaJpA7AboXSds4FrIoqBxF6yxZC1rOfy8rBxlWjMDqUj4WPfaN3eaPos9PJDT1xhHwGXhTDTaNy2b5MZK)aTa48Mai1rQp9PfiHc)ioDe6yxthHwGXhTDTaUF(bzqeii0cGZBcGuhP(0XQmDeAbgF021cbrGGiCatOfaN3eaPos9PJv56i0cm(OTRfsqTnbs8ldGwaCEtaK6i1No2)OJqlaoVjasDKAbgF021cyMGqY4J2UKGgoTabnCsNvbTaecGJHqCwF6ynxDeAbW5nbqQJulW4J2UwGnNqnNCqwA)KDrk2gqQfWj9GKYAH9RuS5ZbzxKITbKwY2WhuLbTFLILtm7GuSnG0s2g(GQmO4heUBcY2WTCIzhKITbK2euzQhg0kld6pdYSbTw1dADgKjoP8MaSL2pjz)2eGSD5ladQYGWDtq2gUfm1y(OTBtqLPEyqRSmitCs5nbyztqYFGC)sxsa(3vpiZg0FgKzdATQh06mitCs5nbylTFsY(Tjaz7Yxagu0Od6OQG8Ajjfg0kdc3nbzB4woXSdsX2asBcQm1ddQkTGZQGwGnNqnNCqwA)KDrk2gqQpDSRVocTa48Mai1rQfWj9GKYAH9lDPynhGbfn6GIFqhvfKxljPWGwzqSji5pqUFPlja)7QhuvAbgF021cyMGqY4J2UKGgoTabnCsNvbTW(LU(0XQKQJqlaoVjasDKAbCspiPSwa3nbzB4woXSdsX2asBcQm1ddAzqvpOkdc3nbzB4wWuJ5J2UnbvM6HbTYYGytqYFGC)sxsa(3vpOkdk(bTFLILtm7GexZ5hydhJvyqldA)kflNy2bjUMZpWQY)ldhJvyqvPfy8rBxlGzccjJpA7scA40ce0WjDwf0c7x66thBCwhHwaCEtaK6i1c4KEqszTWFh0(LUuSMdGwGXhTDTaMjiKm(OTljOHtlqqdN0zvqlGBpaPjqF6yxxDeAbW5nbqQJulW4J2UwaZeesgF02Le0WPfiOHt6SkOfuBtGk4N(0NwqmbCRU5thHo210rOfy8rBxlWjMDqs9diia8PfaN3eaPos9PJvz6i0cm(OTRfcpv12LCIzhKfwLsq5ulaoVjasDK6thRY1rOfaN3eaPosTqlQfcWPfy8rBxlyItkVjaTGjM4bAH1V6bz2Guw1dADgeBoqspWckXJk20aybN3eaPwWeNsNvbTaU9aKMaPk7S(0X(hDeAbW5nbqQJul0IAHaCAbgF021cM4KYBcqlyIjEGwauIhvueiTS5eQ5KdYs7NSlsX2aYbvzqXpiqjEurrG0QYoTaHRLDrQYKoecdkA0bbkXJkkcK2pcMKYxNb5Mj)Gbfn6GaL4rffbs7hbts5RZGufizccA7dkA0bbkXJkkcKw6NtpA7sv(dcYYladkA0bbkXJkkcK2ZCyhcYnNkeePoegu0OdcuIhvueiTS58s4Q7Gmq9pGuks8u5pyqrJoiqjEurrG0YoMc(jvW7t2fPbnq2QdkA0bbkXJkkcK2qDJvytpidYc7FdkA0bbkXJkkcKwhEjtidM3zXaibVMDmKdkA0bbkXJkkcK2ntafAcYDYoUEqvPfmXP0zvqluA)KK9BtaY2LVaOpDSMRocTa48Mai1rQfArTqaoTaJpA7AbtCs5nbOfmXepqlSMY0c4KEqszTGjoP8MaSL2pjz)2eGSD5ladQYGmXjL3eGT0(j7IuSnGukMaUv38jX1S7aXGwgu1AbtCkDwf0cL2pzxKITbKsXeWT6MpjUMDhi0No21xhHwaCEtaK6i1coRcAb2Cc1CYbzP9t2fPyBaPwGXhTDTaBoHAo5GS0(j7IuSnGuF6yvs1rOfy8rBxlOsZStjvL)aTa48Mai1rQpDSXzDeAbgF021cI9rBxlaoVjasDK6th76QJqlaoVjasDKAbCspiPSwy)kflNy2bjUMZpWgogRWGwgu1AbgF021cx)W1YUiVAqQYFu9PpTW(LUocDSRPJqlW4J2UwqLMzNsQk)bAbW5nbqQJuF6yvMocTa48Mai1rQfWj9GKYAH4hucLec18Magu0Od6Vd6OyfO(3GQAqvg0(vkwoXSdsCnNFGnCmwHbTmO9RuSCIzhK4Ao)aRk)VmCmwHbvzq7xPyZNdYUifBdiTKTHpOkdA)kflNy2bPyBaPLSnCTaJpA7AbhUAiLhOkcHtF6yvUocTa48Mai1rQfWj9GKYAH9RuS5JaKDrE1jab7tCqvg0XeGF22eKITbKaPfCEtaKdQYGy8rnbsWbvkeg0kds5AbgF021cCIzhKBcoC6th7F0rOfaN3eaPosTaoPhKuwlSFLILtm7GuSnG0s2gUwGXhTDTab9R(cY17J8tf8tF6ynxDeAbW5nbqQJulGt6bjL1c7xPy5eZoifBdiTKTHRfy8rBxlS5pzxKxsXke0No21xhHwaCEtaK6i1c4KEqszTW(vk285GSlsX2aslzB4dQYG(7G2VsXYjMDqk2gqAFIdQYGIFqQSZwr8niLUmiZT6bfn6GWDtq2gULtm7GuSnG0MGkt9WGwgu1dQQbvzqXpO9RuSCIzhK4Ao)aB4yScdAzq7xPy5eZoiX1C(bwv(Fz4yScdQkTaJpA7AH85GSlsX2as9PJvjvhHwGXhTDTWgYaKkq9pTa48Mai1rQpDSXzDeAbW5nbqQJulGt6bjL1c7xPy5eZoiX1C(b2WXyfg0YG(ZGQmO9RuSCIzhKITbKwY2W1cm(OTRfsMKY(jdICQG(0XUU6i0cGZBcGuhPwaN0dskRf2VsXYjMDqIR58dSHJXkmOLb9Nbvzq7xPy5eZoifBdiTKTHpOkdk(bH7MGSnClNy2bPyBaPnbvM6HbTYGu(GwNb9Hjhu0Odc3nbzB4woXSdsX2asBcQm1ddsPdATQhuvAbgF021cKaF17oDqF6yxRADeAbgF021cCIzhKITbKAbW5nbqQJuF6yxBnDeAbW5nbqQJulGt6bjL1c7xPy5eZoifBdiTpXbfn6GoQkiVwssHbTYGWDtq2gULtm7GuSnG0MGkt9GwGXhTDTWlas6bQb9PJDnLPJqlW4J2Uwyt0nPS8sZRfaN3eaPos9PJDnLRJqlW4J2UwOqtyt0nPwaCEtaK6i1No21(JocTaJpA7Ab2Xq4sMqIzccTa48Mai1rQpDSRzU6i0cGZBcGuhPwaN0dskRfIFqhta(zZNdYUifBdiTGZBcGCqvg0(vk285GSlsX2asBcQm1ddALLbTFLIvmHa4yq2fPk1jTQ8)YWXyfg06migF02TCIzhKBcoCw4Fa)oqEuvyqvnOOrh0(vkwoXSdsX2asBcQm1ddALLbTFLIvmHa4yq2fPk1jTQ8)YWXyfg06migF02TCIzhKBcoCw4Fa)oqEuvqlW4J2UwqmHa4yq2fPk1j1No21wFDeAbW5nbqQJulGt6bjL1c7xPy5eZoifBdiTpXbvzqXpO4h0FheecGJblUDsWdaPKGwGsNyWQYR3ohu0OdccbWXGf3oj4bGusqlqPtmyt2vyqRmiLnOQguLbf)G2VsXUHmaPcu)Z(ehu0OdA)kf7MOBsz5LM3(ehu0Od6Vdk(bLmgSx2eedkA0bLmgSDIhuvdQQbfn6G2VsX(94KKYUSls2CGSVA7tCqvnOOrh0rvb51sskmOvgeUBcY2WTCIzhKITbK2euzQh0cm(OTRfe7J2U(0XUMsQocTa48Mai1rQfWj9GKYAH9RuSCIzhK4Ao)aB4yScdAzqvpOOrhu8dIXh1eibhuPqyqRmiLpOOrhu8dIXh1eibhuPqyqRmiLnOkd6ycWpBcH2zhdwW5nbqoOQguvAbgF021cCIzhKDU1No21IZ6i0cGZBcGuhPwaN0dskRf2VsXYjMDqIR58dSHJXkmOLbv9GQmigFutGeCqLcHbP0bT2GQmigFutGKSp71pCTSlYRgKQ8hDqldQATaJpA7AHRF4AzxKxniv5pQ(0XU26QJqlaoVjasDKAbCspiPSwGXh1eibhuPqyqkDzqkFqvgu8dA)kflNy2bjUMZpWgogRWGwg0(vkwoXSdsCnNFGvL)xgogRWGQslW4J2UwGtm7GCZzYFG(0XQSQ1rOfaN3eaPosTaoPhKuwlW4JAcKGdQuimiLUmiLRfy8rBxlWjMDqc)ls0bA76thRYwthHwaCEtaK6i1cm(OTRf4eZoivPHaLacAbCntDTWAAbCspiPSwy)kflMa4eZHJ6F2ey8nOkdIXh1eibhuPqyqRmiLpOkdk(bDmb4NLvfjOfkMpA7wW5nbqoOOrhu8d6Vd6ycWpBBcsX2asG0coVjaYbvzqS5aj9alNy2bP4tvfiO(NnzxHbP0LbPSbv1GIgDq7xPy5eZoifBdiTKTHpOQ0NowLPmDeAbW5nbqQJulGt6bjL1c7xPy5eZoiX1C(b2WXyfg0YGQwlW4J2Uw46hUw2f5vdsv(JQpDSkt56i0cGZBcGuhPwaN0dskRfy8rnbsWbvkeg0kds5AbgF021cCIzhKBcoC6thRY(JocTa1piZN4jPfTGk7SveFkDjoBUAbQFqMpXtsvvbskFGwynTaJpA7AbWuJ5J2UwaCEtaK6i1NowLzU6i0cm(OTRf4eZoi3CM8hOfaN3eaPos9PpTaecGJHGocDSRPJqlaoVjasDKAbCspiPSwy)sxkwZbyqvg0(vkwoXSdsX2aslzB4dQYG2VsXMphKDrk2gqAjBdFqvg0(vkwoXSdsCnNFGnCmwHbTmO9RuSCIzhK4Ao)aRk)VmCmwHbfn6GoQkiVwssHbTYGWDtq2gULtm7GuSnG0MGkt9GwGXhTDTWMOBszxKxnibhunV(0XQmDeAbW5nbqQJulW4J2Uwa3og8l5diLfcwf0c4KEqszTW(vk285GSlsX2aslzB4dQYG2VsXYjMDqk2gqAjBdFqvgu8d6VdA)sxkwZbyqrJoOJQcYRLKuyqRmiC3eKTHB5eZoifBdiTjOYupmOQguLbPYoBpQkiVwQY)piLUmi4Fa)oqEuvqlqqDqIj1cRV(0XQCDeAbW5nbqQJulGt6bjL1c7xPyZNdYUifBdiTKTHpOkdA)kflNy2bPyBaPLSn8bvzqXpO)oO9lDPynhGbfn6GoQkiVwssHbTYGWDtq2gULtm7GuSnG0MGkt9WGQAqvgKk7S9OQG8APk))Gu6YGG)b87a5rvbTaJpA7AHeyrQ)jleSke0No2)OJqlaoVjasDKAbCspiPSwy)kfB(Cq2fPyBaPLSn8bvzq7xPy5eZoifBdiTKTHRfy8rBxluA8laKs2CGKEGCdSQ(0XAU6i0cGZBcGuhPwaN0dskRf2VsXMphKDrk2gqAjBdFqvg0(vkwoXSdsX2aslzB4AbgF021cFpojPSl7IKnhi7RwF6yxFDeAbW5nbqQJulGt6bjL1c7xPyZNdYUifBdiTKTHpOkdA)kflNy2bPyBaPLSnCTaJpA7AbXxslMN6FYnbho9PJvjvhHwaCEtaK6i1c4KEqszTW(vk285GSlsX2aslzB4dQYG2VsXYjMDqk2gqAjBdxlW4J2UwiPIIeGK6YGiJb9PJnoRJqlaoVjasDKAbCspiPSwy)kfB(Cq2fPyBaPLSn8bvzq7xPy5eZoifBdiTKTHRfy8rBxlC1G857(5KYsNyqF6yxxDeAbW5nbqQJulGt6bjL1c)Dq7x6sXAoadQYG2VsXYjMDqk2gqAjBdFqvgeUBcY2WTCIzhKITbK2euzQhguLbTFLILtm7GexZ5hydhJvyqldA)kflNy2bjUMZpWQY)ldhJvyqvgu8d6Vd6ycWpB(Cq2fPyBaPfCEtaKdkA0bX4J2UnFoi7IuSnG0IR58dcdQQbfn6GoQkiVwssHbTYGWDtq2gULtm7GuSnG0MGkt9GwGXhTDTGkO2P5LDrs8WusjzcSAqF6yxRADeAbW5nbqQJulGt6bjL1c7x6sXAoadQYG2VsXYjMDqk2gqAjBdFqvg0(vk285GSlsX2aslzB4dQYG2VsXYjMDqIR58dSHJXkmOLbTFLILtm7GexZ5hyv5)LHJXkmOOrh0rvb51sskmOvgeUBcY2WTCIzhKITbK2euzQh0cm(OTRfm6KG0eqDzcH2zhd6tFAb12eOc(PJqh7A6i0cGZBcGuhPwaN0dskRfuBtGk4NLKgo2XWGu6YGwRATaJpA7AHnb1vqF6yvMocTa48Mai1rQfWj9GKYAb12eOc(zjPHJDmmiLUmO1QwlW4J2UwytqDf0NowLRJqlW4J2UwqmHa4yq2fPk1j1cGZBcGuhP(0X(hDeAbgF021cCIzhKQ0qGsabTa48Mai1rQpDSMRocTaJpA7AboXSdYo3AbW5nbqQJuF6yxFDeAbgF021cHNiKEBI1cGZBcGuhP(0N(0cMGmqBxhRYQwzvx96wTY1cgC6u)lOfuYuf78aYbT(dIXhT9brqdxWo)0c87Q7uliqvFe8rBpoLC50cIzxOeGwiUdAvjMDyqkj5py(f3bjaIhOUHCqkxXbPSQvw1ZV5xChuCQM9piOKB(f3bT6dkCCEY9lDPynhafhu4Ar5(LUuSMdGIdIDYbXMGK)a5(LUKa8VREqCcdQMDscGCqBZpORggets2UD(f3bT6d648do7rvb51sskmOvxPdk(JQcYRLKuOQbf6bD18nidyqKThhUbb)JHqGAcim)G2V0hu7d6soupiAzqgWGiBpoCdYG9BqxBNFXDqR(Gwnej5dgKyF02her)rX2538lUdA98pGFhqoOnu6egeUv38nOn8r9GDqRcJbXlmiV9vVMt1YJyqm(OThgu7eM3o)I7Gy8rBpyfta3QB(wkeCqH5xCheJpA7bRyc4wDZNzlXu6MC(f3bX4J2EWkMaUv38z2sm87tf8JpA7ZpgF02dwXeWT6MpZwIHtm7GK6hqqa4B(X4J2EWkMaUv38z2smCIzhKfwLsq5C(f3bHBpaPjqQYopiAyqxnmiv25bjcjg8J)GbzadYG9BqxpOVEqKTHpORhe5lP(3GWThG0eyhKs2nihaYWGUEqeaBcge497REqz3Qd66bz0z4geMdWGcyW5K2dkiYQdAvroO2jm)GiFj1)g0QIJ25hJpA7bRyc4wDZNzlXyItkVjafDwfwWThG0eivzNvSfxcWPOjM4blRF1MPSQxh2CGKEGfuIhvSPbWcoVjaY5hJpA7bRyc4wDZNzlXyItkVjafDwfwkTFsY(Tjaz7YxauSfxcWPOjM4blGs8OIIaPLnNqnNCqwA)KDrk2gqwjEqjEurrG0QYoTaHRLDrQYKoecrJckXJkkcK2pcMKYxNb5Mj)GOrbL4rffbs7hbts5RZGufizccA7rJckXJkkcKw6NtpA7sv(dcYYlarJckXJkkcK2ZCyhcYnNkeePoeIgfuIhvueiTS58s4Q7Gmq9pGuks8u5piAuqjEurrG0YoMc(jvW7t2fPbnq2QrJckXJkkcK2qDJvytpidYc7FrJckXJkkcKwhEjtidM3zXaibVMDmKrJckXJkkcK2ntafAcYDYoUUQ5hJpA7bRyc4wDZNzlXyItkVjafDwfwkTFYUifBdiLIjGB1nFsCn7oqOylUeGtrtmXdwwtzksllM4KYBcWwA)KK9BtaY2LVauXeNuEta2s7NSlsX2asPyc4wDZNexZUdelvp)y8rBpyfta3QB(mBjMxaK0duv0zvyHnNqnNCqwA)KDrk2gqo)y8rBpyfta3QB(mBjgvAMDkPQ8hm)y8rBpyfta3QB(mBjgX(OTp)y8rBpyfta3QB(mBjMRF4AzxKxniv5pQI0YY(vkwoXSdsCnNFGnCmwHLQNFZV4oO1Z)a(Da5GatqA(bDuvyqxnmigFDoiAyqSjMsWBcWo)y8rBpSG7NFqgebcI5hJpA7bZwIjiceeHdyI5hJpA7bZwIjb12eiXVmaZpgF02dMTedMjiKm(OTljOHtrNvHfieahdH488JXhT9GzlX8cGKEGQIoRclS5eQ5KdYs7NSlsX2asfPLL9RuS5ZbzxKITbKwY2WRSFLILtm7GuSnG0s2gEL4XDtq2gULtm7GuSnG0MGkt9Wkl)XS1QEDmXjL3eGT0(jj73MaKTlFbOcUBcY2WTGPgZhTDBcQm1dRSyItkVjalBcs(dK7x6scW)UAZ(JzRv96yItkVjaBP9ts2VnbiBx(cq0OhvfKxljPWk4UjiBd3YjMDqk2gqAtqLPEOQ5xCh0Qj9GUEqr(sFqXXAoadYOg8bXejWKMFq7x6u)tXb15GmQbFq7oegKbLGyqKuyqHUD78JXhT9GzlXGzccjJpA7scA4u0zvyz)sxrAzz)sxkwZbiA04pQkiVwssHvytqYFGC)sxsa(3vx18lUds448guKV0huCSMdWGmQbFqRkXSddko2gqoiAyqjWKMFqStoO1JPgZhT9bzqjig0ggucmP5hu8Tpi2eK8hu1G2qPtyqxnmO9l9bjwZbyq0WGAtqAh0Qic9GuzfGbfEjmidyqF9nO)mOvLy2HbfNQ58dckoOoheM9b9b3G(ZGwvIzhguCQMZpimid6vpO4unNFa5GwneTZpgF02dMTedMjiKm(OTljOHtrNvHL9lDfPLfC3eKTHB5eZoifBdiTjOYupSuDfC3eKTHBbtnMpA72euzQhwzHnbj)bY9lDjb4FxDL43VsXYjMDqIR58dSHJXkSSFLILtm7GexZ5hyv5)LHJXku18JXhT9GzlXGzccjJpA7scA4u0zvyb3EastGI0YYF3V0LI1CaMFm(OThmBjgmtqiz8rBxsqdNIoRclQTjqf8B(n)I7GuYCCcQGFdQF5G2V0hKynhGbH7NFqAhKsIAWbtqoidyqGFqoORggeA)shnigF02ddYGE197g0gO(3GO(G4bTFPpiXAoakoi6nivG9WGUA(gKbmioHbX7(Dd66bfooVb1oyNFXDqm(OThS7x6lM4KYBcqrNvHLRpMqUFPhuSfxyssfnXepyznfPLL)UFPlfR5am)I7Gy8rBpy3V0nBjMWX5j3V0LI1CauKww(7(LUuSMdW8lUdA94Kd6QHbTFPpiXAoadYOg8bzadA9(c3GatnMpG0o)I7Gy8rBpy3V0nBjMW1IY9lDPynhafPLL9lDPynhGkIjys(HjTRzbtnMpA7vI)OQG8AjjfQsPM4KYBcWYMGK)a5(LUKa8VRUY(LUuSMdGK8L8rBxPvp)I7GwnfcHbD1SpO1ge1dhWKdQldcuIhteg01dQAfh0gW8ladQldsmHvhZHBqRkXSddkscoCZpgF02d29lDZwIrLMzNsQk)bZpgF02d29lDZwIXHRgs5bQIq4uKwwIpHscHAEtarJ(3JIvG6Fvvz)kflNy2bjUMZpWgogRWY(vkwoXSdsCnNFGvL)xgogRqL9RuS5ZbzxKITbKwY2WRSFLILtm7GuSnG0s2g(8lUdsjrn4dkFUt9VbTAZeKITbKaPIdIDYbzad6RVbXdA16radQldkI6eGWGeZgpO4x1Q5vnidyqF9nO(Ld6px9GwvIzhguCQMZpyqMO8GIt1C(bKdA1qSkfh0ladIEdAdLoHb9cu)BqRwDC0SvfhvCqBaZVamORggKk78GsG8HpA7dIgguF1qAqdWGi48dim)Gm4WbKdkqDmmORgg0QICqgCyqLeGbXU5nyZBNFm(OThS7x6MTedNy2b5MGdNI0YY(vk28raYUiV6eGG9jw5ycWpBBcsX2asG0coVjaYkm(OMaj4GkfcRO85hJpA7b7(LUzlXqq)QVGC9(i)ub)uKww2VsXYjMDqk2gqAjBdF(X4J2EWUFPB2smB(t2f5LuScbfPLL9RuSCIzhKITbKwY2WNFm(OThS7x6MTet(Cq2fPyBaPI0YY(vk285GSlsX2aslzB4v(7(vkwoXSdsX2as7tSs8QSZwr8P0fZT6OrXDtq2gULtm7GuSnG0MGkt9Ws1vvj(9RuSCIzhK4Ao)aB4yScl7xPy5eZoiX1C(bwv(Fz4yScvn)y8rBpy3V0nBjMnKbivG6FZpgF02d29lDZwIjzsk7NmiYPcksll7xPy5eZoiX1C(b2WXyfw(tL9RuSCIzhKITbKwY2WNFm(OThS7x6MTedjWx9UthuKww2VsXYjMDqIR58dSHJXkS8Nk7xPy5eZoifBdiTKTHxjEC3eKTHB5eZoifBdiTjOYupSIYxNpmz0O4UjiBd3YjMDqk2gqAtqLPEqPRvDvZpgF02d29lDZwIHtm7GuSnGC(X4J2EWUFPB2smVaiPhOguKww2VsXYjMDqk2gqAFIrJEuvqETKKcRG7MGSnClNy2bPyBaPnbvM6H5hJpA7b7(LUzlXSj6MuwEP5NFm(OThS7x6MTetHMWMOBY5hJpA7b7(LUzlXWogcxYesmtqm)y8rBpy3V0nBjgXecGJbzxKQuNurAzj(Jja)S5ZbzxKITbKwW5nbqwz)kfB(Cq2fPyBaPnbvM6Hvw2VsXkMqaCmi7IuL6Kwv(Fz4yScRdJpA7woXSdYnbhol8pGFhipQkuv0O7xPy5eZoifBdiTjOYupSYY(vkwXecGJbzxKQuN0QY)ldhJvyDy8rB3YjMDqUj4WzH)b87a5rvH5hJpA7b7(LUzlXi2hTDfPLL9RuSCIzhKITbK2NyL4J)VqiaogS42jbpaKscAbkDIbRkVE7mAuieahdwC7KGhasjbTaLoXGnzxHvuwvvIF)kf7gYaKkq9p7tmA09RuSBIUjLLxAE7tmA0)gFYyWEztqenAYyW2jUQQIgD)kf73Jtsk7YUizZbY(QTpXQIg9OQG8Ajjfwb3nbzB4woXSdsX2asBcQm1dZpgF02d29lDZwIHtm7GSZTI0YY(vkwoXSdsCnNFGnCmwHLQJgnEgFutGeCqLcHvuE0OXZ4JAcKGdQuiSIYQCmb4NnHq7SJbl48MaiRQQ5hJpA7b7(LUzlXC9dxl7I8QbPk)rvKww2VsXYjMDqIR58dSHJXkSuDfgFutGeCqLcbLUwfgFutGKSp71pCTSlYRgKQ8hDP65hJpA7b7(LUzlXWjMDqU5m5pqrAzHXh1eibhuPqqPlkVs87xPy5eZoiX1C(b2WXyfw2VsXYjMDqIR58dSQ8)YWXyfQA(X4J2EWUFPB2smCIzhKW)IeDG2UI0YcJpQjqcoOsHGsxu(8lUdsj7Z7eg0Qsm7WGussdbkbege5lP(3GwvIzhguCSnGuXbXbkjmOs2Qdk0QWGmbP5huqeW0cfpi4FmiE02dkoicQcWG8(gunBI6FdA1MjifBdibYbDmb4hqoOkdkFUt9VbP8)h0Qsm7WGIJpvvGG6F25hJpA7b7(LUzlXWjMDqQsdbkbeuKww2VsXIjaoXC4O(NnbgFvy8rnbsWbvkewr5vI)ycWplRksqlumF02TGZBcGmA04)7XeGF22eKITbKaPfCEtaKvyZbs6bwoXSdsXNQkqq9pBYUckDrzvfn6(vkwoXSdsX2aslzB4vPiUMP(YAZpgF02d29lDZwI56hUw2f5vdsv(JQiTSSFLILtm7GexZ5hydhJvyP65hJpA7b7(LUzlXWjMDqUj4WPiTSW4JAcKGdQuiSIYNFXDqX2gd6Q5BqgqCiHbr2omO9lDQ)P4GmGbHzFqprs(GbD1WGytqYFGC)sxsa(3vpid6vpORggeb4Fx9G6YGUAAyq7x625xCheJpA7b7(LUzlXyItkVjafDwfwytqYFGC)sxsa(3vRylUeGtrtmXdwI3eNuEtaw2eK8hi3V0LeG)D1RJjoP8MaSxFmHC)spS6M4KYBcWYMGK)a5(LUKa8VR2S43V0LI1CaKKVKpA7vv1QDtCs5nbyV(yc5(LEy(X4J2EWUFPB2smGPgZhTDfP(bz(epjTSOYoBfXNsxIZMRIu)GmFINKQQcKu(GL1MFXDqk515GUAyqjNWGAmMd02hKrnKWGmGb91dQB1bTHsNWGatnMpA7dIgg0MXkmONODqXVAeEmbH5h0gW8ladYag0hCdYeKMFqBMCqP)nOqpORgg0(L(GOHbHF3GmbP5huOUZRQ5hJpA7b7(LUzlXWjMDqU5m5py(n)y8rBpyXThG0eSOsZStjvL)G5hJpA7blU9aKMaZwIXHRgs5bQIq4uKwwIpHscHAEtarJ(3JIvG6Fvvz)kflNy2bjUMZpWgogRWY(vkwoXSdsCnNFGvL)xgogRqL9RuS5ZbzxKITbKwY2WRSFLILtm7GuSnG0s2g(8JXhT9Gf3EastGzlXC9dxl7I8QbPk)rvKww2VsXYjMDqIR58dSHJXkSuDfgFutGeCqLcbLUwfgFutGKSp71pCTSlYRgKQ8hDP65hJpA7blU9aKMaZwIHtm7GSZTI0YY(vkwoXSdsCnNFGnCmwHvwuwL4XDtq2gULtm7GuSnG0MGkt9GsxR6Orz8rnbsWbvkewzrzvn)I7GwvIzhguKeC4guOMwUWGEIdI6dsmPDspZpiJAWhu(CN6FdkFeWG6YGU6eGGD(X4J2EWIBpaPjWSLy4eZoi3eC4uKww2VsXMpcq2f5vNaeSpXk7xPy5eZoiX1C(b2WXyfuQYNFm(OThS42dqAcmBjMxaK0duv0zvy5OKq46uvIBs4FfPLL9RuS5ZbzxKITbKwY2WR839RuSCIzhKITbK2ey8vb3nbzB4woXSdsX2asBcQm1dkvzvp)y8rBpyXThG0ey2smVaiPhOQiuka(KoRclyZJj6lBNILBcoCksll7xPyZNdYUifBdiTKTHx5V7xPy5eZoifBdiTjW4RcUBcY2WTCIzhKITbK2euzQhuQYQE(X4J2EWIBpaPjWSLyYNdYUifBdivKww2VsXMphKDrk2gqAjBdVY(vkwoXSdsCnNFGnCmwHL9RuSCIzhK4Ao)aRk)VmCmwHkXxEeeYeW1C(bYJQcRSa)d43bYJQcrJwEeeYeW1C(bYJQcRSG7MGSnClNy2bPyBaPnbvM6HOrpo)GZEuvqETKKcRSG7MGSnClNy2bPyBaPnbvM6HQMFm(OThS42dqAcmBjgoXSdsvAiqjGGI0YIk7SveFRSSUMBL9RuSycGtmhoQ)ztGXxfgFutGeCqLcHvuUI4AM6lRn)I7GuY)Lu)Bq42dqAcuCqgWGchLGyqR3x4gKb73GUEq42pQ)Gb59niYSffP(3GW1C(bHbXHbr0(3G4WGe7qGUjaRqpifaqCqXH9lDQ)fhgehger7FdIddsSdb6Magu8Sc8GWThG0eivzNh0vNqOUUjiRAqStoORg8bfmyXbD9G4b9N)h0QIC1v6Q2CMdc3EastWGY(4J2UDqkzLbzadIShK33GQztWG(ZGwvCsXbzadcZ(GiPIdkqq)QpcZpiI2aYbD9G(GBq8G(ZvpOvfNSdsjbmiMi0dk8cht9bX3G4bvt)QHCqQSZdsesm4h)bdYOg8bzadsKG9bD9GEbyq8GwTEomOUmO4yBa5GiFj1)geU9aKMGbjwZbqXbf6bzadcZ(G2V0he5lP(3GUAyqRwphguxguCSnG0o)y8rBpyXThG0ey2smCIzhKBot(duKwwIp(9RuSCIzhK4Ao)aB4yScl7xPy5eZoiX1C(bwv(Fz4yScvvj(4vzNTI4BLftCs5nbyXThG0eivzNRkA04pMa8ZMphKDrk2gqAbN3eazfC3eKTHB5eZoifBdiTjOYupOuC3eKTHBZNdYUifBdiTLhbHmbCnNFG8OQqfv2zRi(wzXeNuEtawC7binbsv2zZuM5wvvrJg)XeGFwoXSdYo3wW5nbqwb3nbzB4woXSdYo32euzQhwz5dtwb3nbzB4woXSdsX2asBcQm1dkDTQRQQOrvzNTI4BLL4nXjL3eGf3EastGuLDE1xR6QMFXDqcpri92epiAyqBobcZpiJoV6bH5Wr9pfhKrnfxpiAyqg1MFq0Bq0WGc9GkCoiY2WvCqTty(bTEFHBq8UnbdAvrAh08JXhT9Gf3EastGzlXeEIq6TjwrAzrLD2kIVvwwxZD(X4J2EWIBpaPjWSLysMKY(jdICQGI0YY(vkwoXSdsCnNFGnCmwHL)uz)kflNy2bPyBaPLSn85hJpA7blU9aKMaZwIHe4RE3Pdksll7xPy5eZoiX1C(b2WXyfw(tL9RuSCIzhKITbKwY2WRepUBcY2WTCIzhKITbK2euzQhwr5RZhMmAuC3eKTHB5eZoifBdiTjOYupO01QUQ5xCh0QzaehuCy)sN6FXHbr9bXnmOa9E8rBpmONFuIbHBpaPjqQYopir8zh0QkhKd6Q5BqTty(bH5WnOvTEgKb9QhKYh0Qsm7WGW1C(bbfhuG6yyq0loegetO2HBqGs8yIbPYopiChUbD9G4bP8bfogRWGwvKdIDZBWM3oOvDd6Q5BqIn1VbTQE9mOSp(OTpidkbXG2WGwvKd6FLV6kDvRNvxPRAZzo)y8rBpyXThG0ey2smCIzhKW)IeDG2UI0YcJpQjqcoOsHGsxuEL4vzNTI4tPlM4KYBcWIBpaPjqQYohn6(vkwoXSdsCnNFGnCmwHfLx18JXhT9Gf3EastGzlXWjMDqUj4Wn)y8rBpyXThG0ey2smCIzhKBot(dMFZpgF02dwieahdHLnr3KYUiVAqcoOAEfPLL9lDPynhGk7xPy5eZoifBdiTKTHxz)kfB(Cq2fPyBaPLSn8k7xPy5eZoiX1C(b2WXyfw2VsXYjMDqIR58dSQ8)YWXyfIg9OQG8Ajjfwb3nbzB4woXSdsX2asBcQm1dZpgF02dwieahdbZwIb3og8l5diLfcwfuKG6GetUS(ksll7xPyZNdYUifBdiTKTHxz)kflNy2bPyBaPLSn8kX)39lDPynhGOrpQkiVwssHvWDtq2gULtm7GuSnG0MGkt9qvvuzNThvfKxlv5)v6c8pGFhipQkm)y8rBpyHqaCmemBjMeyrQ)jleSkeuKww2VsXMphKDrk2gqAjBdVY(vkwoXSdsX2aslzB4vI)V7x6sXAoarJEuvqETKKcRG7MGSnClNy2bPyBaPnbvM6HQQOYoBpQkiVwQY)R0f4Fa)oqEuvy(X4J2EWcHa4yiy2smLg)caPKnhiPhi3aRQiTSSFLInFoi7IuSnG0s2gEL9RuSCIzhKITbKwY2WNFm(OThSqiaogcMTeZ3Jtsk7YUizZbY(QvKww2VsXMphKDrk2gqAjBdVY(vkwoXSdsX2aslzB4ZpgF02dwieahdbZwIr8L0I5P(NCtWHtrAzz)kfB(Cq2fPyBaPLSn8k7xPy5eZoifBdiTKTHp)y8rBpyHqaCmemBjMKkksasQldImguKww2VsXMphKDrk2gqAjBdVY(vkwoXSdsX2aslzB4ZpgF02dwieahdbZwI5Qb5Z39ZjLLoXGI0YY(vk285GSlsX2aslzB4v2VsXYjMDqk2gqAjBdF(X4J2EWcHa4yiy2smQGANMx2fjXdtjLKjWQbfPLL)UFPlfR5auz)kflNy2bPyBaPLSn8k4UjiBd3YjMDqk2gqAtqLPEOY(vkwoXSdsCnNFGnCmwHL9RuSCIzhK4Ao)aRk)VmCmwHkX)3Jja)S5ZbzxKITbKwW5nbqgnkJpA7285GSlsX2aslUMZpiuv0OhvfKxljPWk4UjiBd3YjMDqk2gqAtqLPEy(X4J2EWcHa4yiy2smgDsqAcOUmHq7SJbfPLL9lDPynhGk7xPy5eZoifBdiTKTHxz)kfB(Cq2fPyBaPLSn8k7xPy5eZoiX1C(b2WXyfw2VsXYjMDqIR58dSQ8)YWXyfIg9OQG8Ajjfwb3nbzB4woXSdsX2asBcQm1dZV5hJpA7bRABcub)wc1uvvivKwwuBtGk4NLKgo2XGsxwR65hJpA7bRABcub)mBjMnb1vqrAzrTnbQGFwsA4yhdkDzTQNFm(OThSQTjqf8ZSLyetiaogKDrQsDY5hJpA7bRABcub)mBjgoXSdsvAiqjGW8JXhT9GvTnbQGFMTedNy2bzN75hJpA7bRABcub)mBjMWtesVnX6tFAn]] )


end
