-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] borne_of_blood
-- [-] carnivorous_stalkers
-- [-] fel_commando
-- [x] tyrants_soul


if UnitClassBase( "player" ) == "WARLOCK" then
    local spec = Hekili:NewSpecialization( 266, true )

    spec:RegisterResource( Enum.PowerType.SoulShards )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        dreadlash = 19290, -- 264078
        bilescourge_bombers = 22048, -- 267211
        demonic_strength = 23138, -- 267171

        demonic_calling = 22045, -- 205145
        power_siphon = 21694, -- 264130
        doom = 23158, -- 603

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        from_the_shadows = 22477, -- 267170
        soul_strike = 22042, -- 264057
        summon_vilefiend = 23160, -- 264119

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        howl_of_terror = 23465, -- 5484

        soul_conduit = 23147, -- 215941
        inner_demons = 23146, -- 267216
        grimoire_felguard = 21717, -- 111898

        sacrificed_souls = 23161, -- 267214
        demonic_consumption = 22479, -- 267215
        nether_portal = 23091, -- 267217
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        amplify_curse = 3507, -- 328774
        bane_of_fragility = 3505, -- 199954
        call_fel_lord = 162, -- 212459
        call_felhunter = 156, -- 212619
        call_observer = 165, -- 201996
        casting_circle = 3626, -- 221703
        essence_drain = 3625, -- 221711
        gateway_mastery = 3506, -- 248855
        master_summoner = 1213, -- 212628
        nether_ward = 3624, -- 212295
        pleasure_through_pain = 158, -- 212618
        singe_magic = 154, -- 212623
    } )


    -- Demon Handling
    local dreadstalkers = {}
    local dreadstalkers_v = {}

    local vilefiend = {}
    local vilefiend_v = {}

    local wild_imps = {}
    local wild_imps_v = {}

    local demonic_tyrant = {}
    local demonic_tyrant_v = {}

    local grim_felguard = {}
    local grim_felguard_v = {}

    local other_demon = {}
    local other_demon_v = {}

    local imps = {}
    local guldan = {}
    local guldan_v = {}

    local last_summon = {}

    local FindUnitBuffByID = ns.FindUnitBuffByID


    local shards_for_guldan = 0

    local function UpdateShardsForGuldan()
        shards_for_guldan = UnitPower( "player", Enum.PowerType.SoulShards )
    end


    -- tyrant_ready needs to be handled internally, as the priority interpreter can't keep variable state in the same way that simc does.
    local tyrant_ready_actual = false

    spec:RegisterStateExpr( "tyrant_ready", function ()
        return tyrant_ready_actual
    end )

    spec:RegisterStateFunction( "update_tyrant_readiness", function( hog_shards )
        if not IsSpellKnown( 265187 ) then return end

        hog_shards = hog_shards or 1

        -- The last part of a Tyrant Prep phase should be a HoG cast.
        if cooldown.summon_demonic_tyrant.remains < 4 then
            if  ( talent.doom.enabled and not debuff.doom.up ) or
                ( talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.remains < 4 ) or
                ( talent.nether_portal.enabled and cooldown.nether_portal.remains < 4 ) or
                ( talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < 4 ) or
                ( talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.remains < 4 ) or
                ( cooldown.call_dreadstalkers.remains < 4 ) or
                ( buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) ) then
                    if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false due to missed APL conditions." ) end
                    tyrant_ready = false
                    return
            end

            if ( soul_shard + hog_shards >= ( buff.nether_portal.up and 1 or 5 ) ) then
                if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as true as all conditions were met." ) end
                tyrant_ready = true
            end

            if Hekili.ActiveDebug then Hekili:Debug( "Leaving 'tyrant_ready' as " .. tostring( tyrant_ready ) .. "." ) end
            return
        end

        if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false based on cooldown." ) end
        tyrant_ready = false
    end )


    local hog_time = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        local now = GetTime()

        if source == state.GUID then
            if subtype == "SPELL_SUMMON" then
                -- Dreadstalkers: 104316, 12 seconds uptime.
                -- if spellID == 193332 or spellID == 193331 then table.insert( dreadstalkers, now + 12 )

                -- Vilefiend: 264119, 15 seconds uptime.
                -- elseif spellID == 264119 then table.insert( vilefiend, now + 15 )

                -- Wild Imp: 104317 and 279910, 20 seconds uptime.
                -- else
                if spellID == 104317 or spellID == 279910 then
                    table.insert( wild_imps, now + 20 )

                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + 20 ),
                        max = math.ceil( now + 20 )
                    }

                    if guldan[ 1 ] then
                        -- If this imp is impacting within 0.15s of the expected queued imp, remove that imp from the queue.
                        if abs( now - guldan[ 1 ] ) < 0.15 then
                            table.remove( guldan, 1 )
                        end
                    end

                    -- Expire missed/lost Gul'dan predictions.
                    while( guldan[ 1 ] ) do
                        if guldan[ 1 ] < now then
                            table.remove( guldan, 1 )
                        else
                            break
                        end
                    end

                -- Grimoire Felguard
                -- elseif spellID == 111898 then table.insert( grim_felguard, now + 17 )

                -- Demonic Tyrant: 265187, 15 seconds uptime.
                elseif spellID == 265187 then table.insert( demonic_tyrant, now + 15 )
                    -- for i = 1, #dreadstalkers do dreadstalkers[ i ] = dreadstalkers[ i ] + 15 end
                    -- for i = 1, #vilefiend do vilefiend[ i ] = vilefiend[ i ] + 15 end
                    -- for i = 1, #grim_felguard do grim_felguard[ i ] = grim_felguard[ i ] + 15 end
                    for i = 1, #wild_imps do wild_imps[ i ] = wild_imps[ i ] + 15 end

                    for _, imp in pairs( imps ) do
                        imp.expires = imp.expires + 15
                        imp.max = imp.max + 15
                    end


                -- Other Demons, 15 seconds uptime.
                -- 267986 - Prince Malchezaar
                -- 267987 - Illidari Satyr
                -- 267988 - Vicious Hellhound
                -- 267989 - Eyes of Gul'dan
                -- 267991 - Void Terror
                -- 267992 - Bilescourge
                -- 267994 - Shivarra
                -- 267995 - Wrathguard
                -- 267996 - Darkhound
                elseif spellID >= 267986 and spellID <= 267996 then table.insert( other_demon, now + 15 ) end

            elseif subtype == "SPELL_CAST_START" and spellID == 105174 then
                C_Timer.After( 0.25, UpdateShardsForGuldan )

            elseif subtype == "SPELL_CAST_SUCCESS" then
                -- Implosion.
                if spellID == 196277 then
                    table.wipe( wild_imps )
                    table.wipe( imps )

                -- Power Siphon.
                elseif spellID == 264130 then
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end

                    for i = 1, 2 do
                        local lowest

                        for id, imp in pairs( imps ) do
                            if not lowest then lowest = id
                            elseif imp.expires < imps[ lowest ].expires then
                                lowest = id
                            end
                        end

                        if lowest then
                            imps[ lowest ] = nil
                        end
                    end

                -- Hand of Guldan (queue imps).
                elseif spellID == 105174 then
                    hog_time = GetTime()

                    if shards_for_guldan >= 1 then table.insert( guldan, now + 0.6 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, now + 0.8 ) end
                    if shards_for_guldan >= 3 then table.insert( guldan, now + 1 ) end

                    -- Per SimC APL, we go into Tyrant with 5 shards -OR- with Nether Portal up.
                    if IsSpellKnown( 265187 ) then
                        local start, duration = GetSpellCooldown( 265187 )

                        if start and duration and start + duration - now < 4 then
                            state.reset()

                            local np = state.talent.nether_portal.enabled and FindUnitBuffByID( "player", 267218 )

                            if ( not state.talent.doom.enabled or state.action.doom.lastCast - now < 30 ) and 
                            ( state.cooldown.demonic_strength.remains > 4 or not state.talent.demonic_strength.enabled or state.talent.demonic_consumption.enabled ) and 
                            ( state.cooldown.nether_portal.remains > 4 or not state.talent.nether_portal.enabled ) and
                            ( state.cooldown.grimoire_felguard.remains > 4 or not state.talent.grimoire_felguard.enabled ) and 
                            ( state.cooldown.summon_vilefiend.remains > 4 or not state.talent.summon_vilefiend.enabled ) and
                            ( state.cooldown.call_dreadstalkers.remains > 4 ) and
                            ( state.buff.demonic_core.down or shards_for_guldan > 3 or ( not state.talent.demonic_consumption.enabled or np ) ) and
                            ( shards_for_guldan == 5 or np ) then
                                tyrant_ready_actual = true
                            end
                        else
                            tyrant_ready_actual = false
                        end
                    end

                -- Summon Demonic Tyrant.
                elseif spellID == 265187 then
                    tyrant_ready_actual = false

                end
            end
        
        elseif imps[ source ] and subtype == "SPELL_CAST_START" then
            local demonic_power = FindUnitBuffByID( "player", 265273 )

            if not demonic_power then
                local imp = imps[ source ]

                imp.start = now
                imp.casts = imp.casts + 1

                imp.expires = min( imp.max, now + ( ( ( state.level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
            end
        end
    end )


    local wipe = table.wipe

    spec:RegisterHook( "reset_precast", function()
        local i = 1

        for id, imp in pairs( imps ) do
            if imp.expires < now then
                imps[ id ] = nil
            end
        end

        while( wild_imps[ i ] ) do
            if wild_imps[ i ] < now then
                table.remove( wild_imps, i )
            else
                i = i + 1
            end
        end

        wipe( wild_imps_v )
        for n, t in pairs( imps ) do table.insert( wild_imps_v, t.expires ) end
        table.sort( wild_imps_v )

        local difference = #wild_imps_v - GetSpellCount( 196277 )

        while difference > 0 do
            table.remove( wild_imps_v, 1 )
            difference = difference - 1
        end

        wipe( guldan_v )
        for n, t in ipairs( guldan ) do guldan_v[ n ] = t end


        i = 1
        while( other_demon[ i ] ) do
            if other_demon[ i ] < now then
                table.remove( other_demon, i )
            else
                i = i + 1
            end
        end

        wipe( other_demon_v )
        for n, t in ipairs( other_demon ) do other_demon_v[ n ] = t end


        if #dreadstalkers_v > 0 then wipe( dreadstalkers_v ) end
        if #vilefiend_v > 0     then wipe( vilefiend_v )     end
        if #grim_felguard_v > 0 then wipe( grim_felguard_v ) end

        -- Pull major demons from Totem API.
        for i = 1, 5 do
            local exists, name, summoned, duration, texture = GetTotemInfo( i )

            if exists then
                local demon

                -- Grimoire Felguard
                if texture == 136216 then demon = grim_felguard_v
                elseif texture == 1616211 then demon = vilefiend_v
                elseif texture == 1378282 then demon = dreadstalkers_v end

                if demon then
                    insert( demon, summoned + duration )
                end
            end

            if #grim_felguard_v > 1 then table.sort( grim_felguard_v ) end
            if #vilefiend_v > 1 then table.sort( vilefiend_v ) end
            if #dreadstalkers_v > 1 then table.sort( dreadstalkers_v ) end
        end

        last_summon.name = nil
        last_summon.at = nil
        last_summon.count = nil

        if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > query_time then
            summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - query_time )
        end

        tyrant_ready = nil

        if cooldown.summon_demonic_tyrant.remains > 5 then
            tyrant_ready = false
        end

        if buff.demonic_power.up then
            summonPet( "demonic_tyrant", buff.demonic_power.remains )
        end

        if Hekili.ActiveDebug then
            Hekili:Debug(   "Is Tyrant Ready?: %s\n" ..
                            " - Dreadstalkers: %d, %.2f\n" ..
                            " - Vilefiend    : %d, %.2f\n" ..
                            " - Grim Felguard: %d, %.2f\n" ..
                            " - Wild Imps    : %d, %.2f\n" ..
                            "Next Demon Exp. : %.2f",
                            tyrant_ready and "Yes" or "No",
                            buff.dreadstalkers.stack, buff.dreadstalkers.remains,
                            buff.vilefiend.stack, buff.vilefiend.remains,
                            buff.grimoire_felguard.stack, buff.grimoire_felguard.remains,
                            buff.wild_imps.stack, buff.wild_imps.remains,
                            major_demon_expires )
        end
    end )


    spec:RegisterHook( "advance_end", function ()
        for i = #guldan_v, 1, -1 do
            local imp = guldan_v[i]

            if imp <= query_time then
                if ( imp + 20 ) > query_time then
                    insert( wild_imps_v, imp + 20 )
                end
                remove( guldan_v, i )
            end
        end
    end )


    -- Provide a way to confirm if all Hand of Gul'dan imps have landed.
    spec:RegisterStateExpr( "spawn_remains", function ()
        if #guldan_v > 0 then
            return max( 0, guldan_v[ #guldan_v ] - query_time )
        end
        return 0
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shards" and amt > 0 then
            if buff.nether_portal.up then
                summon_demon( "other", 15, amt )
            end

            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end
        end
    end )


    spec:RegisterStateFunction( "summon_demon", function( name, duration, count )
        local db = other_demon_v

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
        elseif name == "grimoire_felguard" then db = grim_felguard_v
        elseif name == "demonic_tyrant" then db = demonic_tyrant_v end

        count = count or 1
        local expires = query_time + duration

        last_summon.name = name
        last_summon.at = query_time
        last_summon.count = count

        for i = 1, count do
            table.insert( db, expires )
        end
    end )


    spec:RegisterStateFunction( "extend_demons", function( duration )
        duration = duration or 15

        for k, v in pairs( dreadstalkers_v ) do dreadstalkers_v[ k ] = v + duration end
        for k, v in pairs( vilefiend_v     ) do vilefiend_v    [ k ] = v + duration end
        for k, v in pairs( wild_imps_v     ) do wild_imps_v    [ k ] = v + duration end
        for k, v in pairs( grim_felguard_v ) do grim_felguard_v[ k ] = v + duration end
        for k, v in pairs( other_demon_v   ) do other_demon_v  [ k ] = v + duration end
    end )


    spec:RegisterStateFunction( "consume_demons", function( name, count )
        local db = other_demon_v

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
        elseif name == "grimoire_felguard" then db = grim_felguard_v
        elseif name == "demonic_tyrant" then db = demonic_tyrant_v end

        if type( count ) == "string" and count == "all" then
            table.wipe( db )

            -- Wipe queued Guldan imps that should have landed by now.
            if name == "wild_imps" then
                while( guldan_v[ 1 ] ) do
                    if guldan_v[ 1 ] < now then table.remove( guldan_v, 1 )
                    else break end
                end
            end
            return
        end

        count = count or 0

        if count >= #db then
            count = count - #db
            table.wipe( db )
        end

        while( count > 0 ) do
            if not db[1] then break end
            table.remove( db, 1 )
            count = count - 1
        end

        if name == "wild_imps" and count > 0 then
            while( count > 0 ) do
                if not guldan_v[1] or guldan_v[1] > now then break end
                table.remove( guldan_v, 1 )
                count = count - 1
            end
        end
    end )


    spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )

    -- How long before you can complete a 3 Soul Shard HoG cast.
    spec:RegisterStateExpr( "time_to_hog", function ()
        local shards_needed = max( 0, 3 - soul_shards.current )
        local cast_time = action.hand_of_guldan.cast_time

        if shards_needed > 0 then
            local cores = min( shards_needed, buff.demonic_core.stack )

            if cores > 0 then
                cast_time = cast_time + cores * gcd.execute
                shards_needed = shards_needed - cores
            end

            cast_time = cast_time + shards_needed * action.shadow_bolt.cast_time
        end

        return cast_time
    end )


    spec:RegisterStateExpr( "major_demons_active", function ()
        return ( buff.grimoire_felguard.up and 1 or 0 ) + ( buff.vilefiend.up and 1 or 0 ) + ( buff.dreadstalkers.up and 1 or 0 )
    end )


    -- When the next major demon (anything but Wild Imps) expires.
    spec:RegisterStateExpr( "major_demon_expires", function ()
        local expire = 3600

        if buff.grimoire_felguard.up then expire = min( expire, buff.grimoire_felguard.remains ) end
        if buff.vilefiend.up then expire = min( expire, buff.vilefiend.remains ) end
        if buff.dreadstalkers.up then expire = min( expire, buff.dreadstalkers.remains ) end

        if expire == 3600 then return 0 end
        return expire
    end )


    -- New imp forecasting expressions for Demo.
    spec:RegisterStateExpr( "incoming_imps", function ()
        local n = 0

        for i, time in ipairs( guldan_v ) do
            if time < query_time then break end
            n = n + 1
        end

        return n
    end )


    local time_to_n = 0

    spec:RegisterStateTable( "query_imp_spawn", setmetatable( {}, {
        __index = function( t, k )
            if k ~= "remains" then return 0 end

            local queued = #guldan_v

            if queued == 0 then return 0 end

            if time_to_n == 0 or time_to_n >= queued then
                return max( 0, guldan_v[ queued ] - query_time )
            end

            local count = 0
            local remains = 0

            for i, time in ipairs( guldan_v ) do
                if time > query_time then
                    count = count + 1
                    remains = time - query_time

                    if count >= time_to_n then break end
                end
            end

            return remains
        end,
    } ) )

    spec:RegisterStateTable( "time_to_imps", setmetatable( {}, {
        __index = function( t, k )
            if type( k ) == "number" then
                time_to_n = min( #guldan_v, k )
            elseif k == "all" then
                time_to_n = #guldan_v
            else
                time_to_n = 0
            end

            return query_imp_spawn
        end
    } ) )

    local debugstack = debugstack

    spec:RegisterStateTable( "imps_spawned_during", setmetatable( {}, {
        __index = function( t, k, v )
            local cap = query_time

            if type(k) == "number" then cap = cap + ( k / 1000 )
            else
                if not class.abilities[ k ] then k = "summon_demonic_tyrant" end
                cap = cap + action[ k ].cast
            end

            -- In SimC, k would be a numeric value to be interpreted but I don't see the point.
            -- We're only using it for SDT now, and I don't know what else we'd really use it for.

            -- So imps_spawned_during.summon_demonic_tyrant would be the syntax I'll use here.

            local n = 0

            for i, spawn in ipairs( guldan_v ) do
                if spawn > cap then break end
                if spawn > query_time then n = n + 1 end
            end

            return n
        end,
    } ) )


    -- Auras
    spec:RegisterAuras( {
        axe_toss = {
            id = 89766,
            duration = 4,
            max_stack = 1,
        },
        bile_spit = {
            id = 267997,
            duration = 10,
            max_stack = 1,
        },
        burning_rush = {
            id = 111400,
            duration = 3600,
            max_stack = 1,
        },
        corruption = {
            id = 146739,
            duration = 14,
            type = "Magic",
            max_stack = 1,
        },
        curse_of_tongues = {
            id = 1714,
            duration = 30,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_weakness = {
            id = 702,
            duration = 120,
            type = "Curse",
            max_stack = 1,
        },
        dark_pact = {
            id = 108416,
            duration = 20,
            max_stack = 1,
        },
        demonic_calling = {
            id = 205146,
            duration = 20,
            type = "Magic",
            max_stack = 1,
        },
        demonic_circle = {
            id = 48018,
            duration = 900,
            max_stack = 1,
        },
        demonic_circle_teleport = {
            id = 48020,
        },
        demonic_core = {
            id = 264173,
            duration = 20,
            max_stack = 4,
        },
        demonic_power = {
            id = 265273,
            duration = 15,
            max_stack = 1,
            copy = "tyrant"
        },
        demonic_strength = {
            id = 267171,
            duration = 20,
            max_stack = 1,
        },
        doom = {
            id = 603,
            duration = function () return 20 * haste end,
            tick_time = function () return 20 * haste end,
            max_stack = 1,
        },
        drain_life = {
            id = 234153,
            duration = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            tick_time = function () return haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            max_stack = 1,
        },
        eye_of_kilrogg = {
            id = 126,
        },
        fear = {
            id = 118699,
            duration = 20,
            type = "Magic",
            max_stack = 1,
        },
        fel_domination = {
            id = 333889,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        felstorm = {
            id = 89751,
            duration = function () return 5 * haste end,
            tick_time = function () return 1 * haste end,
            max_stack = 1,

            generate = function ()
                local fs = buff.felstorm

                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 89751 )

                if name then
                    fs.count = 1
                    fs.applied = expires - duration
                    fs.expires = expires
                    fs.caster = "pet"
                    return
                end

                fs.count = 0
                fs.applied = 0
                fs.expires = 0
                fs.caster = "nobody"
            end,
        },
        from_the_shadows = {
            id = 270569,
            duration = 12,
            max_stack = 1,
        },
        howl_of_terror = {
            id = 5484,
            duration = 20,
            type = "Magic",
            max_stack = 1,
        },
        legion_strike = {
            id = 30213,
            duration = 6,
            max_stack = 1,
        },
        mortal_coil = {
            id = 6789,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        nether_portal = {
            id = 267218,
            duration = 15,
            max_stack = 1,
        },
        ritual_of_summoning = {
            id = 698,
        },
        shadowfury = {
            id = 30283,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        soul_leech = {
            id = 108366,
            duration = 15,
            max_stack = 1,
        },

        soul_link = {
            id = 108415,
        },
        soulstone = {
            id = 20707,
            duration = 900,
            max_stack = 1,
        },
        unending_breath = {
            id = 5697,
            duration = 600,
            max_stack = 1,
        },
        unending_resolve = {
            id = 104773,
            duration = 8,
            max_stack = 1,
        },

        dreadstalkers = {
            duration = 12,

            meta = {
                up = function ()
                    local exp = dreadstalkers_v[ #dreadstalkers_v ]
                    return exp and exp >= query_time or false
                end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = dreadstalkers_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
                remains = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( dreadstalkers_v ) do
                        if exp >= query_time then c = c + 2 end
                    end
                    return c
                end,
            }
        },

        grimoire_felguard = {
            duration = 17,

            meta = {
                up = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = grim_felguard_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
                remains = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( grim_felguard_v ) do
                        if exp > query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },

        vilefiend = {
            duration = 15,

            meta = {
                up = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = vilefiend_v[ 1 ]; return exp and ( exp - 15 ) or 0 end,
                remains = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( vilefiend_v ) do
                        if exp > query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },

        wild_imps = {
            duration = 25,

            meta = {
                up = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = wild_imps_v[ 1 ]; return exp and ( exp - 20 ) or 0 end,
                remains = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( wild_imps_v ) do
                        if exp > query_time then c = c + 1 end
                    end

                    -- Count queued HoG imps.
                    for i, spawn in ipairs( guldan_v ) do
                        if spawn <= query_time and ( spawn + 20 ) >= query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },

        other_demon = {
            duration = 20,

            meta = {
                up = function () local exp = other_demon_v[ 1 ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = other_demon_v[ 1 ]; return exp and ( exp - 15 ) or 0 end,
                remains = function () local exp = other_demon_v[ 1 ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( other_demon_v ) do
                        if exp > query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },


        -- Azerite Powers
        forbidden_knowledge = {
            id = 279666,
            duration = 15,
            max_stack = 1,
        },
    } )


    local Glyphed = IsSpellKnownOrOverridesKnown

    -- Fel Imp          58959
    spec:RegisterPet( "imp",
        function() return Glyphed( 112866 ) and 58959 or 416 end,
        "summon_imp",
        3600 )

    -- Voidlord         58960
    spec:RegisterPet( "voidwalker",
        function() return Glyphed( 112867 ) and 58960 or 1860 end,
        "summon_voidwalker",
        3600 )

    -- Observer         58964
    spec:RegisterPet( "felhunter",
        function() return Glyphed( 112869 ) and 58964 or 417 end,
        "summon_felhunter",
        3600 )

    -- Fel Succubus     120526
    -- Shadow Succubus  120527
    -- Shivarra         58963
    spec:RegisterPet( "succubus",
        function()
            if Glyphed( 240263 ) then return 120526
            elseif Glyphed( 240266 ) then return 120527
            elseif Glyphed( 112868 ) then return 58963 end
            return 1863
        end,
        3600 )

    -- Wrathguard       58965
    spec:RegisterPet( "felguard",
        function() return Glyphed( 112870 ) and 58965 or 17252 end,
        "summon_felguard",
        3600 )
    
    
    --[[ Demonic Tyrant
    spec:RegisterPet( "demonic_tyrant",
        135002,
        "summon_demonic_tyrant",
        15 ) ]]
    
    spec:RegisterTotem( "demonic_tyrant", 135002 )


    spec:RegisterStateExpr( "extra_shards", function () return 0 end )

    --[[ spec:RegisterVariable( "tyrant_ready", function ()
        if cooldown.summon_demonic_tyrant.remains > 5 then return false end
        if talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.ready then return false end
        if talent.nether_portal.enabled and cooldown.nether_portal.ready then return false end
        if talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.ready then return false end
        if talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.ready then return false end
        if cooldown.call_dreadstalkers.ready then return false end
        if buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) then return false end
        if soul_shard < ( buff.nether_portal.up and 1 or 5 ) then return false end
        return true
    end ) ]]


    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 119914,
            known = function () return IsSpellKnownOrOverridesKnown( 119914 ) end,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,

            toggle = "interrupts",
            interrupt = true,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            usable = function () return pet.exists end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "axe_toss", 4 )
            end,

            copy = 119914
        },


        banish = {
            id = 710,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                applyDebuff( "target", "banish", 30 )
            end,
        },


        bilescourge_bombers = {
            id = 267211,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 2,
            spendType = "soul_shards",

            talent = "bilescourge_bombers",

            startsCombat = true,

            handler = function ()
            end,
        },


        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,

            talent = "burning_rush",

            handler = function ()
                if buff.burning_rush.up then removeBuff( "burning_rush" )
                else applyBuff( "burning_rush", 3600 ) end
            end,
        },


        call_felhunter = {
            id = 212619,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136174,

            toggle = "interrupts",
            interrupt = true,

            pvptalent = "call_felhunter",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        -- PvP:master_summoner.
        call_dreadstalkers = {
            id = 104316,
            cast = function () if pvptalent.master_summoner.enabled then return 0 end
                return buff.demonic_calling.up and 0 or ( ( level > 53 and 1.5 or 2 ) * haste )
            end,
            cooldown = 20,
            gcd = "spell",

            spend = function () return buff.demonic_calling.up and 0 or 2 end,
            spendType = "soul_shards",

            startsCombat = true,

            handler = function ()
                summon_demon( "dreadstalkers", 12, 2 )
                removeStack( "demonic_calling" )

                if talent.from_the_shadows.enabled then applyDebuff( "target", "from_the_shadows" ) end
            end,
        },


        --[[ command_demon = {
            id = 119898,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
                if pet.felguard.up then runHandler( "axe_toss" )
                elseif pet.felhunter.up then runHandler( "spell_lock" )
                elseif pet.voidwalker.up then runHandler( "shadow_bulwark" )
                elseif pet.succubus.up then runHandler( "seduction" )
                elseif pet.imp.up then runHandler( "singe_magic" ) end
            end,
        }, ]]


        create_healthstone = {
            id = 6201,
            cast = function () return 3 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        },


        create_soulwell = {
            id = 29893,
            cast = function () return 3 * haste end,
            cooldown = 120,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        },


        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,

            talent = "dark_pact",

            handler = function ()
                applyBuff( "dark_pact", 20 )
            end,
        },


        demonbolt = {
            id = 264178,
            cast = function () return ( buff.demonic_core.up and 0 or 4.5 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                if buff.forbidden_knowledge.up and buff.demonic_core.down then
                    removeBuff( "forbidden_knowledge" )
                end

                removeStack( "demonic_core" )
                removeStack( "decimating_bolt" )
                gain( 2, "soul_shards" )
            end,
        },


        demonic_circle = {
            id = 48018,
            cast = 0.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            nobuff = "demonic_circle",

            handler = function ()
                applyBuff( "demonic_circle" )
            end,
        },


        demonic_circle_teleport = {
            id = 48020,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,

            talent = "demonic_circle",
            buff = "demonic_circle",

            handler = function ()
                if conduit.demonic_momentum.enabled then applyBuff( "demonic_momentum" ) end
            end,

            auras = {
                -- Conduit
                demonic_momentum = {
                    id = 339412,
                    duration = 5,
                    max_stack = 1
                }
            }
        },


        demonic_gateway = {
            id = 111771,
            cast = function () return legendary.pillars_of_the_dark_portal.enabled and 0 or 2 end,
            cooldown = 10,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        },


        demonic_strength = {
            id = 267171,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            nobuff = "felstorm",

            handler = function ()
                applyBuff( "demonic_strength" )
            end,
        },


        doom = {
            id = 603,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,

            talent = "doom",

            cycle = "doom",
            min_ttd = function () return 3 + debuff.doom.duration end,

            -- readyTime = function () return IsCycling() and 0 or debuff.doom.remains end,
            -- usable = function () return IsCycling() or ( target.time_to_die < 3600 and target.time_to_die > debuff.doom.duration ) end,
            handler = function ()
                applyDebuff( "target", "doom" )
            end,
        },


        drain_life = {
            id = 234153,
            cast = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            cooldown = 0,
            channeled = true,
            gcd = "spell",

            spend = function () return debuff.soul_rot.up and 0 or 0.03 end,
            spendType = "mana",

            startsCombat = true,

            start = function ()
                applyDebuff( "drain_life" )
            end,

            finish = function ()
                if conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
            end,
        },


        eye_of_kilrogg = {
            id = 126,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        },


        fear = {
            id = 5782,
            cast = function () return 1.7 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                applyDebuff( "target", "fear" )
            end,
        },


        fel_domination = {
            id = 333889,
            cast = 0,
            cooldown = function () return 180 + conduit.fel_celerity.mod * 0.001 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237564,

            essential = true,
            nomounted = true,
            nobuff = "grimoire_of_sacrifice",

            handler = function ()
                applyBuff( "fel_domination" )
            end,
        },


        grimoire_felguard = {
            id = 111898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            toggle = "cooldowns",

            startsCombat = true,

            handler = function ()
                summon_demon( "grimoire_felguard", 15 )
                applyBuff( "grimoire_felguard" )
            end,
        },


        hand_of_guldan = {
            id = 105174,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = true,

            -- usable = function () return soul_shards.current >= 3 end,
            handler = function ()
                extra_shards = min( 2, soul_shards.current )
                if Hekili.ActiveDebug then Hekili:Debug( "Extra Shards: %d", extra_shards ) end
                spend( extra_shards, "soul_shards" )
                update_tyrant_readiness( 1 + extra_shards )
                insert( guldan_v, query_time + 0.6 )
                if extra_shards > 0 then insert( guldan_v, query_time + 0.8 ) end
                if extra_shards > 1 then insert( guldan_v, query_time + 1 ) end
            end,
        },


        health_funnel = {
            id = 755,
            cast = function () return 5 * haste end,
            cooldown = 0,
            gcd = "spell",

            channeled = true,

            startsCombat = false,
            texture = 607852,

            usable = function () return pet.alive and pet.health_pct < 100, "requires injured demon" end,

            start = function ()
                applyBuff( "health_funnel" )
            end,
        },


        implosion = {
            id = 196277,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 2065588,

            velocity = 30,

            usable = function ()
                if buff.wild_imps.stack < 3 and azerite.explosive_potential.enabled then return false, "too few imps for explosive_potential"
                elseif buff.wild_imps.stack < 1 then return false, "no imps available" end
                return true
            end,

            handler = function ()
                if azerite.explosive_potential.enabled and buff.wild_imps.stack >= 3 then applyBuff( "explosive_potential" ) end
                if legendary.implosive_potential.enabled and active_enemies > 2 then
                    if buff.implosive_potential.down then stat.haste = stat.haste + 0.05 * buff.wild_imps.stack end
                    applyBuff( "implosive_potential" )
                end
                consume_demons( "wild_imps", "all" )
            end,

            auras = {
                implosive_potential = {
                    id = 337139,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        mortal_coil = {
            id = 6789,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 607853,

            handler = function ()
                applyDebuff( "target", "mortal_coil" )
            end,
        },


        nether_portal = {
            id = 267217,
            cast = function () return 2.5 * haste end,
            cooldown = 180,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 2065615,

            handler = function ()
                applyBuff( "nether_portal" )
            end,
        },


        power_siphon = {
            id = 264130,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236290,

            talent = "power_siphon",

            readyTime = function ()
                if buff.wild_imps.stack >= 2 then return 0 end

                local imp_deficit = 2 - buff.wild_imps.stack

                for i, imp in ipairs( guldan_v ) do
                    if imp > query_time then
                        imp_deficit = imp_deficit - 1
                        if imp_deficit == 0 then return imp - query_time end
                    end
                end

                return 3600
            end,

            handler = function ()
                local num = min( 2, buff.wild_imps.count )
                consume_demons( "wild_imps", num )

                addStack( "demonic_core", 20, num )
            end,
        },


        ritual_of_summoning = {
            id = 698,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0,
            spendType = "mana",

            startsCombat = true,
            texture = 136223,

            handler = function ()
            end,
        },


        shadow_bolt = {
            id = 686,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136197,

            handler = function ()
                gain( 1, "soul_shards" )

                if legendary.balespiders_burning_core.enabled then
                    addStack( "balespiders_burning_core", nil, 1 )
                end
            end,

            auras = {
                balespiders_burning_core = {
                    id = 337161,
                    duration = 15,
                    max_stack = 4
                }
            }
        },


        shadowfury = {
            id = 30283,
            cast = function () return 1.5 * haste end,
            cooldown = function () return talent.darkfury.enabled and 45 or 60 end,
            gcd = "spell",

            startsCombat = true,
            texture = 607865,

            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },


        soul_strike = {
            id = 264057,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = true,
            texture = 1452864,

            usable = function () return pet.felguard.up and pet.alive, "requires living felguard" end,
            handler = function ()
                gain( 1, "soul_shards" )
            end,
        },


        soulstone = {
            id = 20707,
            cast = 3,
            cooldown = 600,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136210,

            handler = function ()
                applyBuff( "soulstone" )
            end,
        },


        subjugate_demon = {
            id = 1098,
            cast = 2.828,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 136154,

            usable = function () return target.is_demon and target.level < level + 2, "requires demon enemy" end,
            handler = function ()
                summonPet( "controlled_demon" )
            end,
        },


        summon_demonic_tyrant = {
            id = 265187,
            cast = function () return 2 * haste end,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 2065628,

            handler = function ()
                summonPet( "demonic_tyrant", 15 )
                summon_demon( "demonic_tyrant", 15 )
                applyBuff( "demonic_power", 15 )

                tyrant_ready = false

                --[[ if talent.demonic_consumption.enabled then
                    consume_demons( "wild_imps", "all" )
                end ]]

                extend_demons()

                if azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
                if level > 57 then gain( 5, "soul_shards" ) end
            end,

            auras = {
                -- Conduit
                -- Note:  Should set up a queued event for this to start when Tyrant finishes.
                tyrants_soul = {
                    id = 339766,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        summon_felguard = {
            id = 30146,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            startsCombat = false,
            essential = true,

            bind = "summon_pet",
            nomounted = true,

            usable = function () return not pet.exists end,
            handler = function ()
                removeBuff( "fel_domination" )
                summonPet( "felguard", 3600 )
            end,

            copy = { "summon_pet", 112870 }
        },


        summon_vilefiend = {
            id = 264119,
            cast = function () return 2 * haste end,
            cooldown = 45,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 1616211,

            handler = function ()
                summon_demon( "vilefiend", 15 )
            end,
        },


        unending_breath = {
            id = 5697,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        },


        unending_resolve = {
            id = 104773,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "defensives",

            startsCombat = true,

            handler = function ()
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
            end,
        }, ]]
    } )


    spec:RegisterSetting( "implosion_imps", 4, {
        name = "Wild Imps for |T2065588:0|t Implosion",
        desc = "When using |T2065588:0|t Implosion, the default priority will require you to have at least this many Wild Imps.\n\n" ..
            "Current sims reflect that a minimum of 3 imps are needed for optimal DPS in Hectic Add Cleave (but will result in a lot of repetitive Hand of Guldan -> Implosion casts), while using " ..
            "Implosion with 4+ imps is more optimal in 5+ target sustained scenarios.",
        type = "range",
        min = 3,
        max = 10,
        step = 1,
        width = "full"
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        cycle = true,

        damage = true,
        damageExpiration = 6,

        potion = "spectral_intellect",

        package = "Demonology",
    } )

    spec:RegisterPack( "Demonology", 20210121, [[dCeZYaqiLQ8iLuztQk(eKkgLsuNsjLvbrP8kiYSqQ6wkvLDjYVuvAyquDmiLLrj1ZGOyAqQ6AkvABqQuFtjvLXbrjDoivI1PuvzEus6EqyFkroiKkPfIu5HkPknrkj4IkvvPpQuvvojLe1kvcZujvv7uvLFQuvfdLsISuikXtvPPQQQVcrPASkPk2lWFf1GfCyjlgjpgvtMIltSzv8ziz0iLtR41kvmBe3wODt63snCk1XvQQQwoONJY0P66QY2vk(UsPXtjHoVsY8Pe7hQbOb(dUMYfWpRrU1OHC0SgTK1i3AKJ81h46RSfW1U47uOeWvROaUwbj2AtAuRax7AfPld4p4Y6hKlGln3Tz733VOgN2JkX74x2eFKYNw5W64FztK)fCPEdXTYkGcCnLlGFwJCRrd5OznAjRrU1ih5id4YSfo4N1OB0n4sBmgrbuGRryCWDD4GvqIT2Kg1kCazVGKMVdEX6WbAUBZ2VVFrnoThvI3XVSj(iLpTYH1X)YMi)lEX6WHfL(k4kCWA0OhhSg5wJgEbEX6WH1lTsrjS9dVyD4W(WHRTqi4W6V57KWlwhoSpCy)rjRWbOW7yuudoyfKyRunXXbBOSpEhPkhhMdomoommCyuMxQJdl3qCGwbn8I54WPH4avZycBTeEX6WH9HdwPERaXH7ytRvCOiKERyWbBOSpEhPkhh8ghSHnhhgL5L64GvqITs1epHxSoCyF4aYISzycoyLJ2KMnTIdNgIdebLOMcUkHxSoCyF4GvAJvch8IiQJdJ6ce(S9e4Ad7ZqeWDD4GvqIT2Kg1kCazVGKMVdEX6WbAUBZ2VVFrnoThvI3XVSj(iLpTYH1X)YMi)lEX6WHfL(k4kCWA0OhhSg5wJgEbEX6WH1lTsrjS9dVyD4W(WHRTqi4W6V57KWlwhoSpCy)rjRWbOW7yuudoyfKyRunXXbBOSpEhPkhhMdomoommCyuMxQJdl3qCGwbn8I54WPH4avZycBTeEX6WH9HdwPERaXH7ytRvCOiKERyWbBOSpEhPkhh8ghSHnhhgL5L64GvqITs1epHxSoCyF4aYISzycoyLJ2KMnTIdNgIdebLOMcUkHxSoCyF4GvAJvch8IiQJdJ6ce(S9eEbEX6WH9xROWFUyWbk50qbh4DKQCCGsqnklHdORCUy7mCqBDF0ky88i4qX9Pvgo0kzvcVO4(0klzdfEhPkhjeFpcjB64OLpTs)Cq4tuwc5F2Zw8urMncErX9PvwYgk8osvosi(YEXyRzBXXlkUpTYs2qH3rQYrcXx7ERaZSXMwR0pheuVZjTDiM8eTzjMx8DwcTpuVZjzKyRdpZBOKyEX3XQiSgVO4(0klzdfEhPkhjeFnsSvQM40phelt1mMflf3Nwtgj2kvt8eVyocKV2hw)izgTcAywf94fRdhkUpTYs2qH3rQYrcX3nfCkkIqVwrbHVcwQNHszwr)MI8ee8UjMERMyVyS1SrITo8SVcwQNGsSgLz1D)S8EEre1tMUJjrlkIySyXiuVZjz6oME2R9zzQ35KmsS1HNzouuuoT0Z2IL98IiQNmsS1HNzouuuoTKOffrmwS4frupzKyRdpZBL9I2(0As0IIiM1(S8EEre1tQ40ey2UHErsIwueXyXc17CsQ40ey2UHErspBlw4Dtm9wnPIttGz7g6fjbLynkBj02DTplVNxer9ek4e7bk5Jqq9kOjjArreJfl8UjMERMqbNypqjFecQxbnjOeRrzlH2UR9z598IiQNyVyS18MHiNruts0IIiglw4Dtm9wnXEXyR5ndroJOMeuI1OSLqB31(S8EEre1tgj26WZ8wzVOTpTMeTOiIXIfQ35K2oetEI2S0Z2Ifw)izgTcAqSRfluVZjPIttGz7g6fj9S)W6hjZOvqZsiFn8c8I1Hd7VwrH)CXGdYgbUch8jk4GttWHI7nehggouBQHuuejHxuCFALHGzlesM08DWlkUpTYqcXxEri5JqO9uxG4ff3NwziH4BzfLS3mgErX9Pvgsi(AKn9dMJfQHJxuCFALHeIV8IqYf3NwZKH50Rvuq0Ntgf3GxuCFALHeIVWNMlUpTMjdZPxROGWxbl1Z2qXMEMdhUJan6NdcE3etVvtSxm2A2iXwhE2xbl1tqjwJYSk6)SNVcwQNHszwHxuCFALHeIVWNMlUpTMjdZPxROGG9IXwZ(kyPo9mhoChbA0phe(kyPEgkLzfErX9Pvgsi(YEXyR5ndroJOg6NdcE3etVvtSxm2A2iXwhE2xbl1tqjwJYwc9i3ILZGIMNHsSgLzvE3etVvtSxm2A2iXwhE2xbl1tqjwJYqY6DXlkUpTYqcXxErizdukdZlYocKHxuCFALHeIVMUJ0pheq5afgTIIi4ff3NwziH4RrITo8mZHIIYPHxuCFALHeIVudry8(brjzQosjqgErX9Pvgsi(orBsZMwPFoikUpBKSOsCe2sO9zpViI6jwXHZz4IjZ6hHLeTOiI5d17CsBhIjprBwI5fFNLqWe3hfflnrBsZMwZt0M9H6DojFfSupz6T6hE3etVvtSxm2A2iXwhE2xbl1tqjwJYwA3plt9oN0eTjnB2iz72f1NIKm9w1IL9GpvoneLKMOnPzZgjB3UO(uKKOffrmRHxuCFALHeIVt0M0SPv6NdII7ZgjlQehHTK1FOENtA7qm5jAZsmV47SecM4(OOyPjAtA20AEI2SpuVZj5RGL6jtVv)Sm17Cst0M0SzJKTBxuFksY0Bvlw2d(u50qusAI2KMnBKSD7I6trsIwueXSgErX9Pvgsi(sRutUpzupIPu6Ndcw)izgTcAqSRfluVZjPIttGz7g6fj9SXlkUpTYqcXxALAY9jJ6rmLs)CqW6hjZOvqZsiqMp8UjMERMyVyS1SrITo8SVcwQNGsSgLTK1i)ZY8UjMERMyVyS18MHiNrutckXAu2s7AXYEEre1tSxm2AEZqKZiQjjArreZAF4Dtm9wnXlcjBGszyEr2rGSeuI1OSLSgVO4(0kdjeF5fHKlUpTMjdZPxROGG3BeTuNEMdhUJan6NdIL59grl1tQWHnPHglw49grl1t6GIMNpLS2N98IiQNuXPjWSDd9IKeTOiIbVO4(0kdjeFnsSvQM40pheuVZjzKyRdpZBOKGsX9pS(rYmAf0yv0JxuCFALHeIVOGtShOKpcb1RGg6NdcE3etVvtSxm2A2iXwhE2xbl1tqjwJYqI3nX0B1e7fJTMnsS1HN9vWs9K5blFADPZGIMNHsSgLzXYzqrZZqjwJYSkVBIP3Qj2lgBnBKyRdp7RGL6jOeRrziH2U4ff3NwziH47Jj5XLidVO4(0kdjeFT7TcmZgBATs)Cqq9oN02HyYt0MLyEX3zj0(q9oNKrITo8mVHsI5fFhRIm4ff3NwziH4lRFKmZHZocErX9Pvgsi(YlcjxCFAntgMtVwrbbV3iAPoErX9Pvgsi(YOvMEBMQjoEbErX9PvwI3BeTuhXeTf1mkQmV8I5W2MMq)CqSNxer9eR4W5mCXKz9JWsIwueXyXsX9zJKfvIJWwcn8II7tRSeV3iAPosi(Y49dokQSponH(5GWlIOEIvC4CgUyYS(ryjrlkIy(uCF2izrL4imeOHxuCFALL49grl1rcXxgVFWrrL9XPj0phe75frupXkoCodxmzw)iSKOffrmFkUpBKSOsCeMvrpErX9PvwI3BeTuhjeFz9JKHTJxuCFALL49grl1rcXxJWNy5JIkt1ehVaVO4(0kl1Ntgf3GGsGmbUZOOOFoiSfpzKyRdp7RGL6PI7ZgbVO4(0kl1Ntgf3GeIV2TpTs)Cqq9oNeLazcCNrrLE2wSylEYiXwhE2xbl1tf3NnYN9GfxsoSje8II7tRSuFozuCdsi(sr62Kpp4k6NdcBXtgj26WZ(kyPEQ4(SrWlkUpTYs95KrXniH47zGcfPBd9ZbHT4jJeBD4zFfSupvCF2i4f4ff3Nwzj2lgBn7RGL6iOvQj3NmQhXuk9ZbbRFKmJwbni2fVO4(0klXEXyRzFfSuhjeFnsSvQM40pheuVZjzKyRdpZBOKE2Fw2lIOEYiXwhEM3k7fT9P1KOffrmwSq9oNKkonbMTBOxKKP3QRrpzujZniSg54ff3Nwzj2lgBn7RGL6iH4lJwz6TzQM40pheuVZjTDiM8eTzjMx8DqAuEhhfvEI2mRI(pl7frupzKyRdpZBL9I2(0As0IIiglwOENtsfNMaZ2n0lsY0B11ONmQK5gewJC8II7tRSe7fJTM9vWsDKq8ffCI9aL8riOEf0GxuCFALLyVyS1SVcwQJeIVSxm2AEZqKZiQbVO4(0klXEXyRzFfSuhjeF5fHKnqPmmVi7iqgErX9PvwI9IXwZ(kyPosi(sRutUpzupIPu8II7tRSe7fJTM9vWsDKq81iXwPAIt)Cqq9oNKrITo8mVHs6z)H6DojvCAcmB3qViPN9NLxM6DoPndroJOMeuI1OSL21IL98IiQNyVyS18MHiNruts0IIiM1(Sm17CsOGtShOKpcb1RGMeuI1OSL21IfQ35KqbNypqjFecQxbnjtVvxBn8II7tRSe7fJTM9vWsDKq8L1psM5WzhH(5GG6DojvCAcmB3qViPN9NLxM6DoPndroJOMeuI1OSL21IL98IiQNyVyS18MHiNruts0IIiM1(Sm17CsOGtShOKpcb1RGMeuI1OSL21IfQ35KqbNypqjFecQxbnjtVvxBn8II7tRSe7fJTM9vWsDKq8LrRm92mvtC6NdcQ35KuXPjWSDd9IKE2FwEzQ35K2me5mIAsqjwJYwAxlw2ZlIOEI9IXwZBgICgrnjrlkIyw7ZYuVZjHcoXEGs(ieuVcAsqjwJYwAxlwOENtcfCI9aL8riOEf0Km9wDT1WlwhouCFALLyVyS1SVcwQJeIVBk4uueHETIccFfSupdLYSI(nf5ji2J3nX0B1e7fJTMnsS1HN9vWs9eukZk8II7tRSe7fJTM9vWsDKq8L9IXwZgj26WZ(kyPo9ZbXEEre1tgj26WZ8wzVOTpTAXc17CsBhIjprBwI5fFhKMOnlZSRTQyYMhCuuj2lgBnBKyRdp7RGL6lHm4ff3Nwzj2lgBn7RGL6iH4lJwz6TzQM44f4ff3NwzjFfSupBdfBeMUJ0tgvYCdcKb54ff3NwzjFfSupBdfBKq8vfNMaZ2n0lcErX9PvwYxbl1Z2qXgjeFrbNypqjFecQxbn0pheS(rYmAf0Gyx8II7tRSKVcwQNTHInsi(YEXyR5ndroJOg6Ndcw)izgTcAqG(plVNxer9ek4e7bk5Jqq9kOXIfE3etVvtOGtShOKpcb1RGMeuI1OS1WlkUpTYs(kyPE2gk2iH4lViKSbkLH5fzhbYOFoi2ZlIOEcfCI9aL8riOEf0yXcVBIP3QjuWj2duYhHG6vqtckXAugErX9PvwYxbl1Z2qXgjeFnsSvQM40pheuVZjzKyRdpZBOKE2Fy9JKz0kOXQO)ZYEre1tgj26WZ8wzVOTpTMeTOiIXIfQ35KuXPjWSDd9IKm9wDn8II7tRSKVcwQNTHInsi(Y6hjZC4SJq)CqW6hjZOvqJv3DFOhzJ6DojvCAcmB3qViPNnErX9PvwYxbl1Z2qXgjeFz0ktVnt1eN(5GG1psMrRGgRU7(qpYg17CsQ40ey2UHErspB8I1Hdf3NwzjFfSupBdfBKq8DtbNIIi0Rvuq4RGL6zOuMv0VPipbbA4ff3NwzjFfSupBdfBKq8LwPMCFYOEetPG7gbYMwb)Sg5wJC0S2ARtObUBlOokkg4ISJUIS8Zk)B)B)WbC4pnbhMODdDC40qCaDyVyS1SVcwQJo4au2)Fdum4aRJcoupVJLlgCGtRuuclHxS(hvWb0qB)WH1BRBeOlgCaD8IiQNwpOdo4noGoEre1tRNKOffrmOdoSmAwX1s4f4fi7ORil)SY)2)2pCah(ttWHjA3qhhonehqhFfSupBdfB0bhGY()BGIbhyDuWH65DSCXGdCALIsyj8I1)OcoG(9dhwVTUrGUyWb0XlIOEA9Go4G34a64frupTEsIwueXGo4WYOzfxlHxS(hvWHD3pCy926gb6IbhqhViI6P1d6GdEJdOJxer906jjArred6GdlJMvCTeEbEHvoA3qxm4a6ghkUpTIdKH5SeEb4sgMZa)bxEVr0sDWFWp0a)bxrlkIya0bUC44cCkWDpCWlIOEIvC4CgUyYS(ryjrlkIyWblwWHI7ZgjlQehHHdlHdObUf3Nwb3jAlQzuuzE5fZHTnnb4GFwd(dUIwueXaOdC5WXf4uGRxer9eR4W5mCXKz9JWsIwueXGdFWHI7ZgjlQehHHdiWb0a3I7tRGlJ3p4OOY(40eGd(HmG)GROffrma6axoCCbof4Uho4frupXkoCodxmzw)iSKOffrm4WhCO4(SrYIkXry4GvXb0dUf3NwbxgVFWrrL9XPjah8d9G)GBX9PvWL1psg2o4kArredGoGd(Tl4p4wCFAfCncFILpkQmvtCWv0IIigaDah4GRro1J4G)GFOb(dUf3NwbxMTqizsZ3bCfTOiIbqhWb)Sg8hClUpTcU8IqYhHq7PUabxrlkIya0bCWpKb8hClUpTcULvuYEZyGROffrma6ao4h6b)b3I7tRGRr20pyowOgo4kArredGoGd(Tl4p4kArredGoWT4(0k4YlcjxCFAntgMdUKH5zTIc42Ntgf3aCWp0n4p4kArredGoWLdhxGtbU8UjMERMyVyS1SrITo8SVcwQNGsSgLHdwfhqpo8bh2dh8vWs9mukZkWL5WH7GFObUf3Nwbx4tZf3NwZKH5GlzyEwROaU(kyPE2gk2ah8B9b(dUIwueXaOdC5WXf4uGRVcwQNHszwbUmhoCh8dnWT4(0k4cFAU4(0AMmmhCjdZZAffWL9IXwZ(kyPoWb)qwb)bxrlkIya0bUC44cCkWL3nX0B1e7fJTMnsS1HN9vWs9euI1OmCyjCa9ihhSybhodkAEgkXAugoyvCG3nX0B1e7fJTMnsS1HN9vWs9euI1OmCajCW6Db3I7tRGl7fJTM3me5mIAao4h6c4p4wCFAfC5fHKnqPmmVi7iqg4kArredGoGd(HgYb)bxrlkIya0bUC44cCkWfkhOWOvuebClUpTcUMUJah8dn0a)b3I7tRGRrITo8mZHIIYPbUIwueXaOd4GFOzn4p4wCFAfCPgIW49dIsYuDKsGmWv0IIigaDah8dnKb8hCfTOiIbqh4YHJlWPa3I7ZgjlQehHHdlHdOHdFWH9WbViI6jwXHZz4IjZ6hHLeTOiIbh(GduVZjTDiM8eTzjMx8DWHLqGdmX9rrXst0M0SP18eTz4WhCG6DojFfSupz6Tko8bh4Dtm9wnXEXyRzJeBD4zFfSupbLynkdhwch2fh(GdlJduVZjnrBsZMns2UDr9PijtVvXblwWH9Wb4tLtdrjPjAtA2SrY2TlQpfjjArredoSg4wCFAfCNOnPztRah8dn0d(dUIwueXaOdC5WXf4uGBX9zJKfvIJWWHLWbRXHp4a17CsBhIjprBwI5fFhCyje4atCFuuS0eTjnBAnprBgo8bhOENtYxbl1tMERIdFWHLXbQ35KMOnPzZgjB3UO(uKKP3Q4Gfl4WE4a8PYPHOK0eTjnB2iz72f1NIKeTOiIbhwdClUpTcUt0M0SPvGd(H2UG)GROffrma6axoCCbof4Y6hjZOvqdoGah2fhSybhOENtsfNMaZ2n0ls6zdUf3NwbxALAY9jJ6rmLcCWp0q3G)GROffrma6axoCCbof4Y6hjZOvqdoSecCazWHp4aVBIP3Qj2lgBnBKyRdp7RGL6jOeRrz4Ws4G1ihh(GdlJd8UjMERMyVyS18MHiNrutckXAugoSeoSloyXcoSho4frupXEXyR5ndroJOMKOffrm4WA4WhCG3nX0B1eViKSbkLH5fzhbYsqjwJYWHLWbRb3I7tRGlTsn5(Kr9iMsbo4hARpWFWv0IIigaDGlhoUaNcCxgh49grl1tQWHnPHgCWIfCG3BeTupPdkAE(ucoSgo8bh2dh8IiQNuXPjWSDd9IKeTOiIbCzoC4o4hAGBX9PvWLxesU4(0AMmmhCjdZZAffWL3BeTuh4GFOHSc(dUIwueXaOdC5WXf4uGl17Csgj26WZ8gkjOuChh(GdS(rYmAf0Gdwfhqp4wCFAfCnsSvQM4ah8dn0fWFWv0IIigaDGlhoUaNcC5Dtm9wnXEXyRzJeBD4zFfSupbLynkdhqch4Dtm9wnXEXyRzJeBD4zFfSupzEWYNwXHLWHZGIMNHsSgLHdwSGdNbfnpdLynkdhSkoW7My6TAI9IXwZgj26WZ(kyPEckXAugoGeoG2UGBX9PvWffCI9aL8riOEf0aCWpRro4p4wCFAfCFmjpUezGROffrma6ao4N1Ob(dUIwueXaOdC5WXf4uGl17CsBhIjprBwI5fFhCyjCanC4doq9oNKrITo8mVHsI5fFhCWQ4aYaUf3Nwbx7ERaZSXMwRah8ZARb)b3I7tRGlRFKmZHZoc4kArredGoGd(znYa(dUIwueXaOdClUpTcU8IqYf3NwZKH5GlzyEwROaU8EJOL6ah8ZA0d(dUf3NwbxgTY0BZunXbxrlkIya0bCGdU2qH3rQYb)b)qd8hCfTOiIbqh4YHJlWPaxFIcoSeoGCC4doShoylEQiZgbClUpTcUhHKnDC0YNwbo4N1G)GBX9PvWL9IXwZhHG6vqd4kArredGoGd(HmG)GROffrma6axoCCbof4s9oN02HyYt0MLyEX3bhwchqdh(GduVZjzKyRdpZBOKyEX3bhSkcCWAWT4(0k4A3BfyMn20Af4GFOh8hCfTOiIbqh4YHJlWPa3LXbQMXWblwWHI7tRjJeBLQjEIxmhhqGdihhwdh(GdS(rYmAf0WWbRIdOhClUpTcUgj2kvtCGdCWL9IXwZ(kyPo4p4hAG)GROffrma6axoCCbof4Y6hjZOvqdoGah2fClUpTcU0k1K7tg1Jykf4GFwd(dUIwueXaOdC5WXf4uGl17Csgj26WZ8gkPNno8bhwgh8IiQNmsS1HN5TYErBFAnjArredoyXcoq9oNKkonbMTBOxKKP3Q4WAGBX9PvW1iXwPAIdUKrLm3aUwJCGd(HmG)GROffrma6axoCCbof4s9oN02HyYt0MLyEX3bhqchgL3XrrLNOndhSkoGEC4doSmo4frupzKyRdpZBL9I2(0As0IIigCWIfCG6DojvCAcmB3qVijtVvXH1a3I7tRGlJwz6TzQM4GlzujZnGR1ih4GFOh8hClUpTcUOGtShOKpcb1RGgWv0IIigaDah8BxWFWT4(0k4YEXyR5ndroJOgWv0IIigaDah8dDd(dUf3NwbxErizdukdZlYocKbUIwueXaOd4GFRpWFWT4(0k4sRutUpzupIPuWv0IIigaDah8dzf8hCfTOiIbqh4YHJlWPaxQ35KmsS1HN5nuspBC4doq9oNKkonbMTBOxK0Zgh(GdlJdlJduVZjTziYze1KGsSgLHdlHd7IdwSGd7HdEre1tSxm2AEZqKZiQjjArredoSgo8bhwghOENtcfCI9aL8riOEf0KGsSgLHdlHd7IdwSGduVZjHcoXEGs(ieuVcAsMERIdRHdRbUf3NwbxJeBLQjoWb)qxa)bxrlkIya0bUC44cCkWL6DojvCAcmB3qViPNno8bhwghwghOENtAZqKZiQjbLynkdhwch2fhSybh2dh8IiQNyVyS18MHiNruts0IIigCynC4doSmoq9oNek4e7bk5Jqq9kOjbLynkdhwch2fhSybhOENtcfCI9aL8riOEf0Km9wfhwdhwdClUpTcUS(rYmho7iah8dnKd(dUIwueXaOdC5WXf4uGl17CsQ40ey2UHErspBC4doSmoSmoq9oN0MHiNrutckXAugoSeoSloyXcoSho4frupXEXyR5ndroJOMKOffrm4WA4WhCyzCG6DojuWj2duYhHG6vqtckXAugoSeoSloyXcoq9oNek4e7bk5Jqq9kOjz6TkoSgoSg4wCFAfCz0ktVnt1eh4GFOHg4p4kArredGoWLdhxGtbU7HdEre1tgj26WZ8wzVOTpTMeTOiIbhSybhOENtA7qm5jAZsmV47GdiHdt0MLz21wvmzZdokQe7fJTMnsS1HN9vWsDCyjCaza3I7tRGl7fJTMnsS1HN9vWsDGd(HM1G)GBX9PvWLrRm92mvtCWv0IIigaDah4GBFozuCd4p4hAG)GROffrma6axoCCbof4AlEYiXwhE2xbl1tf3Nnc4wCFAfCPeitG7mkkGd(zn4p4kArredGoWLdhxGtbUuVZjrjqMa3zuuPNnoyXcoylEYiXwhE2xbl1tf3Nnco8bh2dhGfxsoSjeWT4(0k4A3(0kWb)qgWFWv0IIigaDGlhoUaNcCTfpzKyRdp7RGL6PI7ZgbClUpTcUuKUn5ZdUc4GFOh8hCfTOiIbqh4YHJlWPaxBXtgj26WZ(kyPEQ4(Sra3I7tRG7zGcfPBdWbo46RGL6zBOyd(d(Hg4p4kArredGoWT4(0k4A6ocUKrLm3aUidYbo4N1G)GBX9PvWvfNMaZ2n0lc4kArredGoGd(HmG)GROffrma6axoCCbof4Y6hjZOvqdoGah2fClUpTcUOGtShOKpcb1RGgGd(HEWFWv0IIigaDGlhoUaNcCz9JKz0kObhqGdOhh(GdlJd7HdEre1tOGtShOKpcb1RGMKOffrm4Gfl4aVBIP3QjuWj2duYhHG6vqtckXAugoSg4wCFAfCzVyS18MHiNrudWb)2f8hCfTOiIbqh4YHJlWPa39WbViI6juWj2duYhHG6vqts0IIigCWIfCG3nX0B1ek4e7bk5Jqq9kOjbLynkdClUpTcU8IqYgOugMxKDeid4GFOBWFWv0IIigaDGlhoUaNcCPENtYiXwhEM3qj9SXHp4aRFKmJwbn4GvXb0JdFWHLXbViI6jJeBD4zERSx02NwtIwueXGdwSGduVZjPIttGz7g6fjz6TkoSg4wCFAfCnsSvQM4ah8B9b(dUIwueXaOdC5WXf4uGlRFKmJwbn4GvXHDXH9HdOhhq2WbQ35KuXPjWSDd9IKE2GBX9PvWL1psM5Wzhb4GFiRG)GROffrma6axoCCbof4Y6hjZOvqdoyvCyxCyF4a6XbKnCG6DojvCAcmB3qViPNn4wCFAfCz0ktVnt1eh4GFOlG)GBX9PvWLwPMCFYOEetPGROffrma6aoWbo4wpNwdb37exVah4aaa]] )


end
