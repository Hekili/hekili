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
        fel_obelisk = 5400, -- 353601
        gateway_mastery = 3506, -- 248855
        master_summoner = 1213, -- 212628
        nether_ward = 3624, -- 212295
        pleasure_through_pain = 158, -- 212618
        shadow_rift = 5394, -- 353294
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
        banish = {
            id = 710,
            duration = 30,
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
            duration = 60,
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
    
    spec:RegisterTotem( "vilefiend", 1616211 )
    spec:RegisterTotem( "grimoire_felguard", 136216 )
    spec:RegisterTotem( "dreadstalker", 1378282 )


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
                summonPet( "dreadstalker", 12 )
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
                summonPet( "grimoire_felguard" )
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

                if azerite.baleful_invocation.enabled or level > 57 then gain( 5, "soul_shards" ) end
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
                summonPet( "vilefiend", 15 )
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


    spec:RegisterPack( "Demonology", 20210707, [[dSuKKbqisb9isbUKsQkBsPQpPK0OivCksPwLsQIxrkAwKQClsLAxI6xIedtKKJHuAzkHEMQennsL4AKcTnLuX3usLghPsQZjsQADif18qkCpQQ2NsWbvLqTqLuEisrMOQeCrrsPnsQKeFKujXijvssNuKuzLkLMPQKANKQ6NQsidvKuyPIKIEksMkPKTsQKuFvjvvJvvs2lv(ljdgYHvSyQYJrzYO6YGnlIplsnAQkNwYRvLA2uCBkTBHFl1WvfhxjvPLJ45qnDIRRQ2Us03vkgVsLZJunFLe7xLD060YrXhbC6VyQwK2uTUPADZPsxRlPEnUUokH(d4OEg27jn4OIXcoQxaSD0MonDh1Zq30d3PLJc3FcdCuuLLMCuE)YiPUW55O4Jao9xmvlsBQw3uTU5uPR1LuVgP1rHFaMt)fxN1Xr5R4CiCEokoGzoQxaSD0Mon9dT(hIPzVVT(e5btZPKs6s899YS2McUSFZivhmYKiPGlllLB72VH(Hwx9o0IPArAVT3wAY3ePbmnFB19HOEaJ5qVUzVZ3wDFOxuyOFicWARfc(HEbW2HxBKd9qaDZAR3ihQsoujhQWhQcSmHCiDAYH8neoBWYHsAYH8AmgWANVT6(qPg9gGCiQ6XxhhAmMEdWp0db0nRTEJCiPp0dPzhQcSmHCOxaSD41gjFB19HsnwMACizmqihQcbiK)JKVT6(qV4LDXpe1A6EbDvBDLdHFg7H24dIdrV)RsGdfTCOXR)YHK(q4V12XHMdPfDYes(2Q7dPRIbW(yKjrsrxDBgPmWHOAZsiKdXMGbgvLCiMVjsd8dj9HQqac5)iQkj7OmfwWoTCuytVrjKkEdc2PLtFADA5OGy8ma3TMJAys1HJc3FJbePI0kY3JUJIrkbi14OyDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8drJdjdjnizEHLjyWHs5qA8q7pKuw4qlCOLdPgpdKtkcwucDYeIsklCiDFiDoKmK0GK5fwMGbhkLdPXdPTJkgl4OW93yarQiTI89O7eN(l60YrbX4zaUBnh1WKQdhf(hEMU5QXcIp6yXrXiLaKACuSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(HOXHKHKgKmVWYem4qPCinEO9hsklCOfo0YHuJNbYjfblkHozcrjLfoKUpKohsgsAqY8cltWGdLYH04H02rfJfCu4F4z6MRgli(OJfN40)LoTCuqmEgG7wZrXbmJups1HJ6fr4Xem4q(g8HMdr7IhcdSo4hIdMH(HMGFOcFiXhqGKMahc)UEEa(HsAYHskcwoKw0jtihs6dzQao0)5qBkX3HeFWHiawCuXybhfyFOtGXOAcpMGbokgPeGuJJI1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWpenoKohsgsAqY8cltWGdLYH04H0(qAEiAx8q7peRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFOfoKohsNdPZHKHKgKmVWYem4qPCinEiTpKMhI2fpK2hs3hIwnEiTp0(djLfo0chA5qQXZa5KIGfLqNmHOKYchs3hsNdPZHKHKgKmVWYem4qPCinEiTpKMhI2fpK2oQHjvhokW(qNaJr1eEmbdCItCu(EucPI3yNwo9P1PLJcIXZaC3AoQySGJcxrY3OsBgEnstWkW6zaRJAys1HJcxrY3OsBgEnstWkW6zaRtC6VOtlhfeJNb4U1CuXybhfUIKVrn4NImHGvG1Zawh1WKQdhfUIKVrn4NImHGvG1ZawN4ehfRxcXeIA8ktj0DA50NwNwokigpdWDR5OyKsasnokC)nEvWZPj9sqvXYkDtgP6idX4za(H2FiDoeRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFiACOft1HwzLdX62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4hAHd9YuDiTDudtQoCu4(BuKwCIt)fDA5OGy8ma3TMJIrkbi14OW934vbpNuGHR6eLNPX42IZqmEgGFO9h6bKmhSDumLqNmHKhMulbh1WKQdhfU)gfPfN40)LoTCuqmEgG7wZrXiLaKACu4(B8QGN3ugUY3peLmmPy4meJNb4oQHjvhokC)nksloXPVU40YrbX4zaUBnhfJucqQXrH7VXRcE2adx5rxb7g7JbYqmEgGFO9hsNd9asMd2okMsOtMqYdtQLWH2FiC)nkSVHWpeno0IhALvoeRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFOfoKUKQdPTJAys1HJIdSYosfPvETrCItFn60YrbX4zaUBnhfJucqQXrPHhc3FJxf8SbgUYJUc2n2hdKHy8ma)q7pKgEOhqYCW2rXucDYesEysTeCudtQoCuCGv2rQiTYRnItC6VooTCuqmEgG7wZrnmP6WrLyaSpgzsehfJucqQXrH7VXRcEEzBgPmGc3MLqizigpdWDuviaH8FevL4O8(jj5LTzKYakCBwcHK)poXP)660YrbX4zaUBnhfJucqQXrH7VXRcEM1wVruwGxYivhzigpdWp0(d9asMd2okMsOtMqYdtQLGJAys1HJcZ6pPI0kPeFGtC6RRDA5OGy8ma3TMJIrkbi14O0WdH7VXRcEM1wVruwGxYivhzigpdWDudtQoCuyw)jvKwjL4dCIt)uVtlhfeJNb4U1CumsjaPgh1dizoy7OykHozcjpmPwchA)HW93OW(gc)q(puQCudtQoCuL9bcEfPvSrgSq6hFGtCIJsOtMquyq(poTC6tRtlhfeJNb4U1CumsjaPghfRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFiACiA1OJAys1HJkaXhqupnrgJtC6VOtlhfeJNb4U1CumsjaPghfRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFiACiAx3dP7dPZHgMuDKXFRTdfhSDumLqNmHKHDa7lGsklCinp0WKQJm23W7nkV2izyhW(cOKYchs7dT)q6Ciw3gEVjYSXyuCcmCSmM3abNjGDQaFiACiAx3dP7dPZHgMuDKXFRTdfhSDumLqNmHKHDa7lGsklCinp0WKQJm(BTDOwwgiPGGNHDa7lGsklCinp0WKQJm23W7nkV2izyhW(cOKYchs7dTYkh6bKmNadhlJ5nqYeWovGp0chI1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWpKMhAys1rg)T2ouCW2rXucDYesg2bSVakPSWH02rnmP6WrLMu2UiGkbmP)dH7eN(V0PLJcIXZaC3AokgPeGuJJsNdX62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4hIghIwnEiDFiDo0WKQJm(BTDO4GTJIPe6KjKmSdyFbuszHdP9H2FiDoeRBdV3ez2ymkobgowgZBGGZeWovGpenoeTA8q6(q6COHjvhz83A7qXbBhftj0jtizyhW(cOKYchsZdnmP6iJ)wBhQLLbski4zyhW(cOKYchs7dTYkh6bKmNadhlJ5nqYeWovGp0chI1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWpKMhAys1rg)T2ouCW2rXucDYesg2bSVakPSWH0(qAFOvw5q6Cin8qKFajnjnK3uMecWXkCLUmQorH)paPAIc)T2oQiDgIXZa8dT)qSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(Hw4q6sQoK2oQHjvhok83A7qTSmqsbb3jo91fNwokigpdWDR5OyKsasnokw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGja)q04q0U4H09H05qdtQoY4V12HId2okMsOtMqYWoG9fqjLfoKMhAys1rg7B49gLxBKmSdyFbuszHdP9H2FiPSWHw4qlhsnEgiNueSOe6KjeLuw4q6(q0U4H09HgMuDKzJXO4ey4yzmVbcod7a2xaLuw4qAEOHjvhz83A7qXbBhftj0jtizyhW(cOKYchsZdnmP6iJ9n8EJYRnsg2bSVakPSGJAys1HJIngJItGHJLX8giyN40xJoTCuqmEgG7wZrXiLaKACuszHdTWHwoKA8mqoPiyrj0jtikPSWH2FiDo0dizobgowgZBGKhMulHdT)qpGK5ey4yzmVbsMa2Pc8Hw4qdtQoY4V12HId2okMsOtMqYWoG9fqjLfoK2hA)H05qA4HKXaHKXFRTd1YYajfe8meJNb4hALvo0di5LLbski45Hj1s4qAFO9hsNdH7VrH9ne(H8FOuDOvw5q6COhqYCcmCSmM3ajpmPwchA)HEajZjWWXYyEdKmbStf4drJdnmP6iJ)wBhkoy7OykHozcjd7a2xaLuw4qAEOHjvhzSVH3BuETrYWoG9fqjLfoK2hALvoKoh6bK8YYajfe88WKAjCO9h6bK8YYajfe8mbStf4drJdnmP6iJ)wBhkoy7OykHozcjd7a2xaLuw4qAEOHjvhzSVH3BuETrYWoG9fqjLfoK2hALvoKohY7NKKttkBxeqLaM0)HWZ)NdT)qE)KKCAsz7IaQeWK(peEMa2Pc8HOXHgMuDKXFRTdfhSDumLqNmHKHDa7lGsklCinp0WKQJm23W7nkV2izyhW(cOKYchs7dPTJAys1HJc)T2ouCW2rXucDYeItCIJIdjZ3ioTC6tRtlhfeJNb4U1CuCaZi1JuD4OsT7a2xa(HGLaH(HKYchs8bhAystouHp0SCkZ4zGSJAys1HJc)agJY0S3oXP)IoTCudtQoCuSXyujGX3peG4OGy8ma3TMtC6)sNwoQHjvhoQzhOKgJDuqmEgG7wZjo91fNwoQHjvhokoSS)eLDsxmhfeJNb4U1CItFn60YrbX4zaUBnh1WKQdhfBmg1WKQdLPWIJYuyrfJfCucPI3GGDIt)1XPLJcIXZaC3AokgPeGuJJIajea7B8mGJAys1HJI3T1jo9xxNwokigpdWDR5OyKsasnokC)nEvWZPj9sqvXYkDtgP6idX4za(HwzLdH7VXRcEoPadx1jkptJXTfNHy8ma)qRSYHW934vbpZAR3iklWlzKQJmeJNb4hALvoeRxcXesoagPnnH7OWcPyItFADudtQoCuSXyudtQouMcloktHfvmwWrX6LqmHOgVYucDN40xx70YrbX4zaUBnh1WKQdhfBmg1WKQdLPWIJYuyrfJfCucDYeIcdY)Xjo9t9oTCuqmEgG7wZrXiLaKACu6Ciw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGja)q04q0MQdT)qszHdTWHwoKA8mqoPiyrj0jtikPSWH09HOnvhALvoeU)gVk4zcKubWvpJzeidX4za(H2Fiw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGja)q04qVuxFiTDudtQoCupTuD4eN(0MkNwokigpdWDR5OyKsasnoQhqYCW2rXucDYesEysTeCuyHumXPpToQHjvhok2ymQHjvhktHfhLPWIkgl4O60mUtC6tlToTCuqmEgG7wZrXiLaKACu6Cin8qKFajnjnK3uMecWXkCLUmQorH)paPAIc)T2oQiDgIXZa8dT)qSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(Hw4qP(dP9HwzLdPZHEajZbBhftj0jti5Hj1s4q7p0dizoy7OykHozcjta7ub(q04qRZHwphknJNTZUdPTJAys1HJId2okMcleisl(CItFAx0PLJcIXZaC3AokgPeGuJJI1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWp0chAXuDiDFinEO1ZH0Wdr(bK0K0qEtzsiahRWv6YO6ef()aKQjk83A7OI0zigpdWDudtQoCuSXyuCcmCSmM3ab7eN(0(sNwokigpdWDR5OyKsasnokVFssEtz4QY(GZyzyVp0chI2dT)qE)KKmhSDumfRjqgld79HOXHEPJAys1HJ6P3aefUE81HtC6tRU40YrbX4zaUBnhfJucqQXr59tsYcDYesM3BIdT)qSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(Hw4qA0rnmP6Wr5vgaZ6pjnO8ARhqWoXPpTA0PLJcIXZaC3AokgPeGuJJAysTeuqa2cWhAHdr7H08q6CiAp065qYyGqY4HrQKIbCfU)gCgIXZa8dP9H2FiVFssEtz4QY(GZyzyVp0c(p06CO9hY7NKKf6KjKmV3ehA)HyDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8dTWH0OJAys1HJQSpMgxD4eN(0UooTCuqmEgG7wZrXiLaKACudtQLGccWwa(qlCOfp0(d59tsYBkdxv2hCgld79HwW)HwNdT)qE)KKSqNmHK59M4q7peRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFOfoKgp0(dPHhI8diPjPHCzFmnUwcQNwGqQXKHy8ma)q7pKohsdpKmgiKCcPTkXhOW(gEVbNHy8ma)qRSYH8(jj5esBvIpqH9n8Edo)FoK2oQHjvhoQY(yAC1HtC6t7660YrbX4zaUBnhfJucqQXrnmPwckiaBb4dTWHw8q7pK3pjjVPmCvzFWzSmS3hAb)hADo0(d59tsYL9X04AjOEAbcPgtMa2Pc8HOXHw8q7pe5hqstsd5Y(yACTeupTaHuJjdX4zaUJAys1HJQSpMgxD4eN(0QRDA5OGy8ma3TMJIrkbi14O8(jj5nLHRk7doJLH9(ql4)q0U4H2FizmqizC)nkwh8FjzigpdWp0(djJbcjNqARs8bkSVH3BWzigpdWp0(dr(bK0K0qUSpMgxlb1tlqi1yYqmEgGFO9hY7NKKf6KjKmV3ehA)HyDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8dTWH0OJAys1HJQSpMgxD4eN(0M6DA5OGy8ma3TMJIrkbi14O8Am(q7pKuwqjTIxWHOXHEzQCudtQoCuPjLTlcOsat6)q4oXP)IPYPLJcIXZaC3AokgPeGuJJYRX4dT)qszbL0kEbhIghArDTJAys1HJc)T2oulldKuqWDIt)fP1PLJcIXZaC3AokgPeGuJJYRX4dT)qszbL0kEbhIghIwn6OgMuD4OWFRTdfhSDumLqNmH4eN(lUOtlhfeJNb4U1CumsjaPghfU)gf23q4hY)H0OJAys1HJY3eCvNOs)n8jCIt)fFPtlhfeJNb4U1CudtQoCu(MGR6ev6VHpHJIdygPEKQdhvQl5qVabgowgZBGGp0qGdngcmC6hAysTe07qrFOaa(HK(q4zjCiSVHWXokgPeGuJJc3FJc7Bi8dTG)d9YdT)q6COhqYCcmCSmM3ajpmPwchALvo0dizoy7OykHozcjpmPwchsBN40FrDXPLJcIXZaC3AokgPeGuJJc3FJc7Bi8dTG)dr7H2FiVFssoaXhqupnrgt()CO9hI1TH3BImBmgfNadhlJ5nqWzcyNkWhAHdT4HwphknJNTZoh1WKQdhLVj4QorL(B4t4eN(lQrNwokigpdWDR5OyKsasnokC)nkSVHWp0c(peThA)HyDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8drJdLMXZ2z3H2FiPSWHw4q0U4H09HsZ4z7S7q7pKohY7NKK5ey4yzmVbco)Fo0(d59tsYCcmCSmM3abNjGDQaFOfo0WKQJSVj4QorL(B4tKHDa7lGsklCinp0WKQJm(BTDO4GTJIPe6KjKmSdyFbuszHdP9H2FiDoKgEizmqiz83A7qTSmqsbbpdX4za(HwzLd59tsYlldKuqWZ)NdPTJAys1HJY3eCvNOs)n8jCIt)fxhNwokigpdWDR5OyKsasnokn8qSEjeti5Lqi(OtCuyHumXPpToQHjvhok2ymQHjvhktHfhLPWIkgl4Oy9siMquJxzkHUtC6V4660YrbX4zaUBnh1WKQdhfU)gfwi1BWrXbmJups1HJA9xIV(lhIAyKkPya)qu93G17qu93CikHuVHdv4dHfshPbYHeFtCOxaSD41grVdH7dvYH8n4dnhYxL2hqo0dPAsj0DumsjaPghLgEizmqiz8WivsXaUc3FdodX4zaUtC6VOU2PLJcIXZaC3AoQHjvhokoy7WRnIJIdygPEKQdhf1de8d9cGTJIDiAQja(qjn5qu93CikFdHJp0pKYCiTOtMqoeRBdV3ehQWhIzAmCiPpebgoDhfJucqQXr59tsYCW2rXuSMazcmm5q7peU)gf23q4hIghsxo0(dX62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4hAHdTyQCIt)ft9oTCuqmEgG7wZrnmP6WrXbBhETrCuCaZi1JuD4OEHpPI0hsl6KjKdHb5)O3HWpqWp0la2ok2HOPMa4dL0Kdr1FZHO8neo2rXiLaKACuE)KKmhSDumfRjqMadto0(dH7VrH9ne(HOXH0LdT)qSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(HOXHODrN40)LPYPLJcIXZaC3AokgPeGuJJY7NKK5GTJIPynbYeyyYH2FiC)nkSVHWpenoKUCO9hsNd59tsYCW2rXuSMazSmS3hAHdT4HwzLdjJbcjJhgPskgWv4(BWzigpdWpK2oQHjvhokoy7WRnItC6)sADA5OGy8ma3TMJIrkbi14O8(jjzoy7OykwtGmbgMCO9hc3FJc7Bi8drJdPlhA)HgMulbfeGTa8Hw4q06OgMuD4O4GTdV2ioXP)lx0PLJAys1HJc3FJclK6n4OGy8ma3TMtC6)Yx60YrbX4zaUBnh1WKQdhfBmg1WKQdLPWIJYuyrfJfCuSEjetiQXRmLq3jo9FPU40YrbX4zaUBnh1WKQdhLVj4QorL(B4t4O4aMrQhP6WrL6soe9(Fi2ehknihYByVpK0hsJhIQ)Mdr5BiC8H8GKMah6fiWWXYyEde8HyDB49M4qf(qey4017qLSk(q97H(HK(q4hi4hs8b2df9ghfJucqQXrH7VrH9ne(HwW)HE5H2Fiw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGja)qlCOf14H2FiDoKmgiKmhSDumfBmMksNHy8ma)qRSYHyDB49MiZgJrXjWWXYyEdeCMa2Pc8Hw4q6CiDoKgpKUpeU)gf23q4hs7dTEo0WKQJm23W7nkV2izyhW(cOKYchs7dP5HgMuDK9nbx1jQ0FdFImSdyFbuszHdPTtC6)sn60YrbX4zaUBnh1WKQdhfVBRJIrkbi14OiqcbW(gpdCO9hsklCOfo0YHuJNbYjfblkHozcrjLfCum6mdOKHKgeStFADIt)xUooTCudtQoCuyFdV3O8AJ4OGy8ma3TMtCIJ6HaS26nItlN(060YrbX4zaUBnh1WKQdhvcyu82wXivhokoGzK6rQoCuP2Da7la)qEqstGdXAR3ihYdsxboFOxmJbpc(qrh623qSjFZHgMuDGpuhg6zhfJucqQXrjLfo0chkvhA)H0Wd9asEm1sWjo9x0PLJAys1HJc)T2oujGj9FiChfeJNb4U1CIt)x60YrbX4zaUBnhvmwWrjTfuDIY2bwi9hRyDGfYNjvhyh1WKQdhL0wq1jkBhyH0FSI1bwiFMuDGDItFDXPLJcIXZaC3AoQySGJc3gy8HvyGrarjaZxuR3p4OgMuD4OWTbgFyfgyequcW8f169doXPVgDA5OgMuD4Osma2hJmjIJcIXZaC3AoXP)640YrbX4zaUBnhfJucqQXr59tsYBkdxv2hCgld79Hw4q0EO9hY7NKK5GTJIPynbYyzyVpen8FOfDudtQoCup9gGOW1JVoCIt)11PLJcIXZaC3AokgPeGuJJsNd51y8HwzLdnmP6iZbBhETrYSblhY)Hs1H0(q7peU)gf23q44drJdPloQHjvhokoy7WRnItC6RRDA5OGy8ma3TMJIrkbi14O0WdPZH8Am(qRSYHgMuDK5GTdV2iz2GLd5)qP6qAFOvw5q4(BuyFdHJp0ch6LoQHjvhokSVH3BuETrCIt)uVtlhfeJNb4U1Cu9JJcdIJAys1HJA5qQXZaoQLJ5dokAx0rTCiQySGJkPiyrj0jtikPSGtCIJsiv8geStlN(060YrbX4zaUBnh1WKQdhf23W7nax1epvNOKMyHqCumsjaPghfRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFiACiA1OJkgl4OW(gEVb4QM4P6eL0eleItC6VOtlhfeJNb4U1CumsjaPghLmgiKmhSDumfRd83(ivhzigpdWp0(dX62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4hIghAXu5OgMuD4OyJXOgMuDOmfwCuMclQySGJY3Jsiv8g7eN(V0PLJcIXZaC3AokoGzK6rQoCuP2KeGj4dj(g5qczwcMdHn9gd9dj9HKHKgKdrG17ViWHgoVKQJXO3HWWZqgboKVj4Mks7OgMuD4OyJXOgMuDOmfwCuMclQySGJcB6nkHuXBqWoXPVU40YrbX4zaUBnh1WKQdhvVeijMEtfPvtu2rXM0GJIrkbi14OEajZbBhftj0jti5Hj1sWrfJfCu9sGKy6nvKwnrzhfBsdoXPVgDA5OGy8ma3TMJIrkbi14OesfVbjl0M9ny1hdkVFsYH2FOhqYCW2rXucDYesEysTeCudtQoCucPI3GqRtC6VooTCuqmEgG7wZrXiLaKACucPI3GKLfZ(gS6JbL3pj5q7p0dizoy7OykHozcjpmPwcoQHjvhokHuXBqw0jo9xxNwokigpdWDR5OyKsasnokPSWHw4qlhsnEgiNueSOe6KjeLuw4q7peRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGFOfo0IPYrnmP6WrXgJrnmP6qzkS4OmfwuXybh1ZNak(yN0Gsiv8g7eN4OE(eqXh7KgucPI3yNwo9P1PLJcIXZaC3AoQySGJItGHNueqTeWyW4OgMuD4O4ey4jfbulbmgmoXP)IoTCuqmEgG7wZrfJfCu4(Buv6OeG4OgMuD4OW93OQ0rjaXjo9FPtlhfeJNb4U1CudtQoCuPn0F8P6e1GXLTmJuD4OyKsasnoQHj1sqbbylaFi)hIwhvmwWrL2q)XNQtudgx2Yms1HtC6RloTCuqmEgG7wZrfJfCu8H822DO4a7T65leaZGGboQHjvhok(qEB7ouCG9w98fcGzqWaN40xJoTCuqmEgG7wZrfJfCuGxh4(Bullm4OgMuD4OaVoW93OwwyWjo9xhNwokigpdWDR5OIXcoQFW8nvaCvAZWRrAcwH9nS3ga7OgMuD4O(bZ3ubWvPndVgPjyf23WEBaStCIJQtZ4oTC6tRtlh1WKQdhLhqWa5DfPDuqmEgG7wZjo9x0PLJAys1HJYZ0nxL8j0DuqmEgG7wZjo9FPtlh1WKQdhvsrapt3ChfeJNb4U1CItFDXPLJAys1HJ6JbvjGf7OGy8ma3TMtCItCulbcU6WP)IPArAt16MQ1XrTzirfPXoQ1)lo1u)uN(6k08HoKw(Gdv2NMihkPjhAvSP3OesfVbbV6HiW69xeGFiCBHdnFPTJa8dX8nrAaNVTVUc4q0sZhIM6yjqeGFiQYsthctpKz3HwFhs6d96)CiETSWvhhQFaYin5q6KI2hsNf3PD(2(6kGdTinFiAQJLara(HOklnDim9qMDhA9DiPp0R)ZH41YcxDCO(biJ0KdPtkAFiDwCN25B7RRao0lP5drtDSeicWpevzPPdHPhYS7qRVdj9HE9FoeVww4QJd1pazKMCiDsr7dPZl3PD(2EBx)V4ut9tD6RRqZh6qA5douzFAICOKMCOvz9siMquJxzkH(QhIaR3Fra(HWTfo08L2ocWpeZ3ePbC(2(6kGdrlnFiAQJLara(Hwf3FJxf88Rw9qsFOvX934vbp)QmeJNb4REiDODN25B7RRao0I08HOPowceb4hAvC)nEvWZVA1dj9Hwf3FJxf88RYqmEgGV6H0H2DANVTVUc4qVKMpen1XsGia)qRI7VXRcE(vREiPp0Q4(B8QGNFvgIXZa8vp0ihk1(IE9H0H2DANVTVUc4q6cnFiAQJLara(Hwf3FJxf88Rw9qsFOvX934vbp)QmeJNb4REiDODN25B7RRaoKgP5drtDSeicWp0Q4(B8QGNF1Qhs6dTkU)gVk45xLHy8maF1dPdT70oFBFDfWHwhA(q0uhlbIa8dTkU)gVk45xT6HK(qRI7VXRcE(vzigpdWx9qJCOu7l61hshA3PD(2(6kGdTU08HOPowceb4hAvC)nEvWZVA1dj9Hwf3FJxf88RYqmEgGV6H0H2DANVTVUc4q6AA(q0uhlbIa8dTkU)gVk45xT6HK(qRI7VXRcE(vzigpdWx9qJCOu7l61hshA3PD(2EBx)V4ut9tD6RRqZh6qA5douzFAICOKMCOvf6KjefgK)ZQhIaR3Fra(HWTfo08L2ocWpeZ3ePbC(2(6kGd9sA(q0uhlbIa8dTk5hqstsd5xT6HK(qRs(bK0K0q(vzigpdWx9q6q7oTZ32B76)fNAQFQtFDfA(qhslFWHk7ttKdL0KdTkhsMVrw9qey9(lcWpeUTWHMV02ra(Hy(MinGZ32xxbCO1LMpen1XsGia)qRI7VXRcE(vREiPp0Q4(B8QGNFvgIXZa8vpKoVCN25B7RRaouQNMpen1XsGia)qRI7VXRcE(vREiPp0Q4(B8QGNFvgIXZa8vpKo0Ut78T91vahIwAP5drtDSeicWp0QKFajnjnKF1Qhs6dTk5hqstsd5xLHy8maF1dPdT70oFBFDfWHODrA(q0uhlbIa8dTk5hqstsd5xT6HK(qRs(bK0K0q(vzigpdWx9qJCOu7l61hshA3PD(2(6kGdr76qZhIM6yjqeGFOvj)asAsAi)QvpK0hAvYpGKMKgYVkdX4za(QhshA3PD(2(6kGdr76sZhIM6yjqeGFOvj)asAsAi)QvpK0hAvYpGKMKgYVkdX4za(QhAKdLAFrV(q6q7oTZ32xxbCiA1108HOPowceb4hAvYpGKMKgYVA1dj9HwL8diPjPH8RYqmEgGV6H0H2DANVT321)lo1u)uN(6k08HoKw(Gdv2NMihkPjhAvHuXBqWREicSE)fb4hc3w4qZxA7ia)qmFtKgW5B7RRaoKgP5drtDSeicWp0QcPI3GKPn)QvpK0hAvHuXBqYcT5xT6H0H2DANVTVUc4qRdnFiAQJLara(Hwviv8gK8I5xT6HK(qRkKkEdswwm)QvpKo0Ut78T92M6Spnra(Hs9hAys1XHmfwW5BRJ6H0jLbCuAGgCOxaSD0Mon9dT(hIPzVVTAGgCiFI8GP5usjDj((EzwBtbx2VzKQdgzsKuWLLLYTvd0GdT9BOFO1vVdTyQwK2B7Tvd0Gdrt(MinGP5BRgObhs3hI6bmMd96M9oFB1an4q6(qVOWq)qeG1wle8d9cGTdV2ih6Ha6M1wVrouLCOsouHpufyzc5q60Kd5BiC2GLdL0Kd51ymG1oFB1an4q6(qPg9gGCiQ6XxhhAmMEdWp0db0nRTEJCiPp0dPzhQcSmHCOxaSD41gjFB1an4q6(qPgltnoKmgiKdvHaeY)rY3wnqdoKUp0lEzx8drTMUxqx1wx5q4NXEOn(G4q07)Qe4qrlhA86VCiPpe(BTDCO5qArNmHKVTAGgCiDFiDvma2hJmjsk6QBZiLboevBwcHCi2emWOQKdX8nrAGFiPpufcqi)hrvj5B7TvdouQDhW(cWpKhK0e4qS26nYH8G0vGZh6fZyWJGpu0HU9neBY3COHjvh4d1HHE(2omP6aNFiaRTEJOP)usaJI32kgP6qVkXVuwyHuTxdFajpMAjCBhMuDGZpeG1wVr00Fk4V12H6bKB7WKQdC(HaS26nIM(t5JbvjGvVySGFPTGQtu2oWcP)yfRdSq(mP6aFBhMuDGZpeG1wVr00FkFmOkbS6fJf8JBdm(WkmWiGOeG5lQ17hUTdtQoW5hcWAR3iA6pLedG9XitICBhMuDGZpeG1wVr00Fkp9gGOW1JVo0Rs879tsYBkdxv2hCgld79c0U37NKK5GTJIPynbYyzyVPH)fVTdtQoW5hcWAR3iA6pfoy7WRnIEvIFD8AmELvgMuDK5GTdV2iz2Gf)Ps794(BuyFdHJPHUCBhMuDGZpeG1wVr00FkyFdV3O8AJOxL4xd1XRX4vwzys1rMd2o8AJKzdw8NkTxzfC)nkSVHWXl8YB7WKQdC(HaS26nIM(tz5qQXZa6fJf8NueSOe6KjeLuwqV(Xpge9woMp4N2fVT3wn4qP2Da7la)qWsGq)qszHdj(GdnmPjhQWhAwoLz8mq(2omP6a7h)agJY0S332Hjvhyn9NcBmgvcy89dbi32Hjvhyn9NYSdusJX32Hjvhyn9Nchw2FIYoPl2TDys1bwt)PWgJrnmP6qzkSOxmwWVqQ4ni4B7WKQdSM(tH3TvVkXpbsia234zGB7WKQdSM(tHngJAys1HYuyrVySGFwVeIje14vMsORhwift8tREvIFC)nEvWZPj9sqvXYkDtgP6yLvW934vbpNuGHR6eLNPX42IxzfC)nEvWZS26nIYc8sgP6yLvy9siMqYbWiTPj8B7WKQdSM(tHngJAys1HYuyrVySGFHozcrHb5)CBhMuDG10FkpTuDOxL4xhw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGjaNg0MQ9szHfwoKA8mqoPiyrj0jtikPSGUPnvRScU)gVk4zcKubWvpJzeypRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGtJxQR1(2omP6aRP)uyJXOgMuDOmfw0lgl4VtZ46HfsXe)0QxL4)bKmhSDumLqNmHKhMulHB7WKQdSM(tHd2okMcleisl(0Rs8RJgs(bK0K0qEtzsiahRWv6YO6ef()aKQjk83A7OI07zDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8fs9AVYk68asMd2okMsOtMqYdtQLW(hqYCW2rXucDYesMa2PcmnwN1tAgpBNDAFBhMuDG10FkSXyuCcmCSmM3abRxL4N1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWxyXuPBnUE0qYpGKMKgYBktcb4yfUsxgvNOW)hGunrH)wBhvK(2omP6aRP)uE6narHRhFDOxL437NKK3ugUQSp4mwg27fODV3pjjZbBhftXAcKXYWEtJxEBhMuDG10FkELbWS(tsdkV26beSEvIFVFsswOtMqY8EtSN1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWxqJ32Hjvhyn9NszFmnU6qVkX)WKAjOGaSfGxGwn1H21JmgiKmEyKkPyaxH7VbNHy8max79E)KK8MYWvL9bNXYWEVG)1zV3pjjl0jtizEVj2Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4lOXB7WKQdSM(tPSpMgxDOxL4FysTeuqa2cWlS4EVFssEtz4QY(GZyzyVxW)6S37NKKf6KjKmV3e7zDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMa8f04EnK8diPjPHCzFmnUwcQNwGqQXSxhnugdesoH0wL4duyFdV3GZqmEgGVYkE)KKCcPTkXhOW(gEVbN)pAFBhMuDG10FkL9X04Qd9Qe)dtQLGccWwaEHf379tsYBkdxv2hCgld79c(xN9E)KKCzFmnUwcQNwGqQXKjGDQatJf3t(bK0K0qUSpMgxlb1tlqi1yUTdtQoWA6pLY(yAC1HEvIFVFssEtz4QY(GZyzyVxWpTlUxgdesg3FJI1b)xsgIXZa89YyGqYjK2QeFGc7B49gCgIXZa89KFajnjnKl7JPX1sq90cesnM9E)KKSqNmHK59MypRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGVGgVTdtQoWA6pL0KY2fbujGj9FiC9Qe)EngVxklOKwXlGgVmv32Hjvhyn9Nc(BTDOwwgiPGGRxL43RX49szbL0kEb0yrD9TDys1bwt)PG)wBhkoy7OykHozcrVkXVxJX7LYckPv8cObTA82omP6aRP)u8nbx1jQ0FdFc9Qe)4(BuyFdH7xJ3wn4qPUKd9cey4yzmVbc(qdbo0yiWWPFOHj1sqVdf9Hca4hs6dHNLWHW(gchFBhMuDG10Fk(MGR6ev6VHpHEvIFC)nkSVHWxW)l3RZdizobgowgZBGKhMulHvw5bKmhSDumLqNmHKhMulbTVTdtQoWA6pfFtWvDIk93WNqVkXpU)gf23q4l4N29E)KKCaIpGOEAImM8)zpRBdV3ez2ymkobgowgZBGGZeWovGxyX1tAgpBND32Hjvhyn9NIVj4QorL(B4tOxL4h3FJc7Bi8f8t7Ew3gEVjY4V12HId2okMsOtMqYeWovGvWUhGjaNgPz8SD2TxklSaTlQ70mE2o72RJ3pjjZjWWXYyEdeC()S37NKK5ey4yzmVbcota7ubEHHjvhzFtWvDIk93WNid7a2xaLuwqZHjvhz83A7qXbBhftj0jtizyhW(cOKYcAVxhnugdesg)T2oulldKuqWZqmEgGVYkE)KK8YYajfe88)r7B7WKQdSM(tHngJAys1HYuyrVySGFwVeIje14vMsORhwift8tREvIFnK1lHycjVecXhDYTvdo06VeF9xoe1WivsXa(HO6VbR3HO6V5qucPEdhQWhclKosdKdj(M4qVay7WRnIEhc3hQKd5BWhAoKVkTpGCOhs1KsOFBhMuDG10Fk4(BuyHuVb9Qe)AOmgiKmEyKkPyaxH7VbNHy8ma)2QbhI6bc(HEbW2rXoen1eaFOKMCiQ(BoeLVHWXh6hszoKw0jtihI1TH3BIdv4dXmngoK0hIadN(TDys1bwt)PWbBhETr0Rs879tsYCW2rXuSMazcmmzpU)gf23q40qx2Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb4lSyQUTAWHEHpPI0hsl6KjKdHb5)O3HWpqWp0la2ok2HOPMa4dL0Kdr1FZHO8neo(2omP6aRP)u4GTdV2i6vj(9(jjzoy7OykwtGmbgMSh3FJc7BiCAOl7zDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMaCAq7I32Hjvhyn9NchSD41grVkXV3pjjZbBhftXAcKjWWK94(BuyFdHtdDzVoE)KKmhSDumfRjqgld79clUYkYyGqY4HrQKIbCfU)gCgIXZaCTVTdtQoWA6pfoy7WRnIEvIFVFssMd2okMI1eitGHj7X93OW(gcNg6Y(Hj1sqbbylaVaT32Hjvhyn9NcU)gfwi1B42omP6aRP)uyJXOgMuDOmfw0lgl4N1lHycrnELPe63wn4qPUKdrV)hInXHsdYH8g27dj9H04HO6V5qu(gchFipiPjWHEbcmCSmM3abFiw3gEVjouHpebgoD9oujRIpu)EOFiPpe(bc(HeFG9qrV52omP6aRP)u8nbx1jQ0FdFc9Qe)4(BuyFdHVG)xUN1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWxyrnUxhzmqizoy7Oyk2ymvKodX4za(kRW62W7nrMngJItGHJLX8gi4mbStf4f0rhnQBC)nkSVHW1E9mmP6iJ9n8EJYRnsg2bSVakPSG2AomP6i7BcUQtuP)g(ezyhW(cOKYcAFBhMuDG10Fk8UT6XOZmGsgsAqW(PvVkXpbsia234zG9szHfwoKA8mqoPiyrj0jtikPSWTDys1bwt)PG9n8EJYRnYT92omP6aNXMEJsiv8geS)pguLaw9IXc(X93yarQiTI89ORxL4N1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWPHmK0GK5fwMGbRpnUxklSWYHuJNbYjfblkHozcrjLf0ToYqsdsMxyzcgS(0O232Hjvh4m20BucPI3GG10FkFmOkbS6fJf8J)HNPBUASG4Jow0Rs8Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb40qgsAqY8cltWG1Ng3lLfwy5qQXZa5KIGfLqNmHOKYc6whziPbjZlSmbdwFAu7BRgCOxeHhtWGd5BWhAoeTlEimW6GFioyg6hAc(Hk8HeFabsAcCi8765b4hkPjhkPiy5qArNmHCiPpKPc4q)NdTPeFhs8bhIay52omP6aNXMEJsiv8geSM(t5JbvjGvVySGFW(qNaJr1eEmbd0Rs8Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb40qhziPbjZlSmbdwFAuBnPDX9SUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(c6OJoYqsdsMxyzcgS(0O2As7IARBA1O27LYclSCi14zGCsrWIsOtMquszbDRJoYqsdsMxyzcgS(0O2As7IAFBVTdtQoWzwVeIje14vMsO7h3FJI0IEvIFC)nEvWZPj9sqvXYkDtgP6yVoSUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpataonwmvRScRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGVWltL232Hjvh4mRxcXeIA8ktj010Fk4(BuKw0Rs8J7VXRcEoPadx1jkptJXTfV)bKmhSDumLqNmHKhMulHB7WKQdCM1lHycrnELPe6A6pfC)nksl6vj(X934vbpVPmCLVFikzysXW32Hjvh4mRxcXeIA8ktj010FkCGv2rQiTYRnIEvIFC)nEvWZgy4kp6ky3yFmWEDEajZbBhftj0jti5Hj1sypU)gf23q40yXvwH1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWxqxsL232Hjvh4mRxcXeIA8ktj010FkCGv2rQiTYRnIEvIFne3FJxf8SbgUYJUc2n2hdSxdFajZbBhftj0jti5Hj1s42omP6aNz9siMquJxzkHUM(tjXayFmYKi6vj(X934vbpVSnJugqHBZsie9Qqac5)iQkXV3pjjVSnJugqHBZsiK8)52omP6aNz9siMquJxzkHUM(tbZ6pPI0kPeFGEvIFC)nEvWZS26nIYc8sgP6y)dizoy7OykHozcjpmPwc32Hjvh4mRxcXeIA8ktj010Fkyw)jvKwjL4d0Rs8RH4(B8QGNzT1BeLf4Lms1XTDys1boZ6LqmHOgVYucDn9NszFGGxrAfBKblK(XhOxL4)bKmhSDumLqNmHKhMulH94(BuyFdH7pv32B7WKQdC23Jsiv8g7)JbvjGvVySGFCfjFJkTz41inbRaRNbS32Hjvh4SVhLqQ4nwt)P8XGQeWQxmwWpUIKVrn4NImHGvG1Za2B7TDys1bo3PzC)EabdK3vK(2omP6aN70mUM(tXZ0nxL8j0VTdtQoW5onJRP)uskc4z6MFBhMuDGZDAgxt)P8XGQeWIVT32Hjvh48ZNak(yN0Gsiv8g7)JbvjGvVySGFobgEsra1saJbZTDys1bo)8jGIp2jnOesfVXA6pLpguLaw9IXc(X93OQ0rja52omP6aNF(eqXh7KgucPI3yn9NYhdQsaREXyb)Pn0F8P6e1GXLTmJuDOxL4FysTeuqa2cW(P92omP6aNF(eqXh7KgucPI3yn9NYhdQsaREXyb)8H822DO4a7T65leaZGGb32Hjvh48ZNak(yN0Gsiv8gRP)u(yqvcy1lgl4h86a3FJAzHHB7WKQdC(5tafFStAqjKkEJ10FkFmOkbS6fJf8)dMVPcGRsBgEnstWkSVH92a4B7TDys1bolKkEdc2)hdQsaREXyb)yFdV3aCvt8uDIsAIfcrVkXpRBdV3ez83A7qXbBhftj0jtizcyNkWky3dWeGtdA14TDys1bolKkEdcwt)PWgJrnmP6qzkSOxmwWVVhLqQ4nwVkXVmgiKmhSDumfRd83(ivhzigpdW3Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb40yXuDB1GdLAtsaMGpK4BKdjKzjyoe20Bm0pK0hsgsAqoebwV)IahA48sQogJEhcdpdze4q(MGBQi9TDys1bolKkEdcwt)PWgJrnmP6qzkSOxmwWp20BucPI3GGVTdtQoWzHuXBqWA6pLpguLaw9IXc(7LajX0BQiTAIYok2Kg0Rs8)asMd2okMsOtMqYdtQLWTDys1bolKkEdcwt)PiKkEdcT6vj(fsfVbjtB23GvFmO8(jj7FajZbBhftj0jti5Hj1s42omP6aNfsfVbbRP)uesfVbzr9Qe)cPI3GKxm7BWQpguE)KK9pGK5GTJIPe6KjK8WKAjCBhMuDGZcPI3GG10FkSXyudtQouMcl6fJf8)8jGIp2jnOesfVX6vj(LYclSCi14zGCsrWIsOtMquszH9SUn8EtKXFRTdfhSDumLqNmHKjGDQaRGDpata(clMQB7TDys1bol0jtikmi)h)bi(aI6PjYy0Rs8Z62W7nrg)T2ouCW2rXucDYesMa2PcSc29amb40GwnEBhMuDGZcDYeIcdY)rt)PKMu2UiGkbmP)dHRxL4N1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWPbTRRU1zys1rg)T2ouCW2rXucDYesg2bSVakPSGMdtQoYyFdV3O8AJKHDa7lGsklO9EDyDB49MiZgJrXjWWXYyEdeCMa2PcmnODD1TodtQoY4V12HId2okMsOtMqYWoG9fqjLf0Cys1rg)T2oulldKuqWZWoG9fqjLf0Cys1rg7B49gLxBKmSdyFbuszbTxzLhqYCcmCSmM3ajta7ubEbw3gEVjY4V12HId2okMsOtMqYeWovGvWUhGjaxZHjvhz83A7qXbBhftj0jtizyhW(cOKYcAFBhMuDGZcDYeIcdY)rt)PG)wBhQLLbski46vj(1H1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWPbTAu36mmP6iJ)wBhkoy7OykHozcjd7a2xaLuwq796W62W7nrMngJItGHJLX8gi4mbStfyAqRg1TodtQoY4V12HId2okMsOtMqYWoG9fqjLf0Cys1rg)T2oulldKuqWZWoG9fqjLf0ELvEajZjWWXYyEdKmbStf4fyDB49MiJ)wBhkoy7OykHozcjta7ubwb7EaMaCnhMuDKXFRTdfhSDumLqNmHKHDa7lGsklOT2RSIoAi5hqstsd5nLjHaCScxPlJQtu4)dqQMOWFRTJksVN1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWxqxsL232Hjvh4SqNmHOWG8F00FkSXyuCcmCSmM3abRxL4N1TH3BIm(BTDO4GTJIPe6KjKmbStfyfS7bycWPbTlQBDgMuDKXFRTdfhSDumLqNmHKHDa7lGsklO5WKQJm23W7nkV2izyhW(cOKYcAVxklSWYHuJNbYjfblkHozcrjLf0nTlQ7Hjvhz2ymkobgowgZBGGZWoG9fqjLf0Cys1rg)T2ouCW2rXucDYesg2bSVakPSGMdtQoYyFdV3O8AJKHDa7lGsklCBhMuDGZcDYeIcdY)rt)PG)wBhkoy7OykHozcrVkXVuwyHLdPgpdKtkcwucDYeIsklSxNhqYCcmCSmM3ajpmPwc7FajZjWWXYyEdKmbStf4fgMuDKXFRTdfhSDumLqNmHKHDa7lGsklO9ED0qzmqiz83A7qTSmqsbbpdX4za(kR8asEzzGKccEEysTe0EVo4(BuyFdH7pvRSIopGK5ey4yzmVbsEysTe2)asMtGHJLX8gizcyNkW0yys1rg)T2ouCW2rXucDYesg2bSVakPSGMdtQoYyFdV3O8AJKHDa7lGsklO9kROZdi5LLbski45Hj1sy)di5LLbski4zcyNkW0yys1rg)T2ouCW2rXucDYesg2bSVakPSGMdtQoYyFdV3O8AJKHDa7lGsklO9kROJ3pjjNMu2UiGkbmP)dHN)p79(jj50KY2fbujGj9Fi8mbStfyAmmP6iJ)wBhkoy7OykHozcjd7a2xaLuwqZHjvhzSVH3BuETrYWoG9fqjLf0wBh18fFnXr5eN4Ca]] )


end
