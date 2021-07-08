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


    spec:RegisterPack( "Demonology", 20210708, [[dWuCLbqiQI4riv0LuIQAtkv9jLKgfjYPqQAvkPs9ksuZIQKBrvu7su)sj0WuIYXqkTmLiptvctJQiDnKkTnLuX3uLKgNQKQZPKkzDivyEifUhvv7tjXbvLuSqLuEisrnrLuvxujQYgvsvQ(OQKsJujQqNujQ0kvkntKIStQs9tvjHHQev0svsvYtrYuPkSvLuLYxvLenwvjAVu6VKAWqoSIftspgLjJQld2Si9zr0OPQCAPETQuZMIBtLDl8BjdxvCCLuflhXZHA6exxvTDr47kfJxPY5jH1RevW8vc2VkBP16HLIpcy9EPLTeTl7vx2RNPLwpLUlBDzPefpGL6zyVNKGLkghyPwFWvrzQKkSupJctnCRhwkC9jmWsr1oA2sP(BJSCdRQLIpcy9EPLTeTl7vx2RNPLwpLUlJUwk8dWSEV06SowkFnNdHv1sXbmZsT(GRIYujvCOx5qmf79T1Nipy6yXft2IVVAMvUfXT7BgPRGrMuzrC7ylEB3(nko0R71HwAzlr7T92sZ(MijGPJBRNpe1dymhIMk278T1Zh6vegfhIaSY5GGFO1hCvOwg5qpeWZSYPoYH60d1YHA8H6altihsPICiFdHZgSCO0ICi1cJbm95BRNp0YzTbihIQF8vXHgJP2a8d9qapZkN6ihsQd9qk2H6altihA9bxfQLrY3wpFOLZelNhsgdeYH6qac5)i5BRNp0Rjr18drTMNxz5y9Ape(zChAJpioKI6VkbouuYHg16lhsQdH)oxfhAoKhkiti5BRNp06DdG9XitQS46TYmsBGdrvMeqihInbdm6o9qmFtKe4hsQd1HaeY)r0DA2szASGTEyPWMAJwiD8geS1dR30A9WsbXOAaUDnl1WKUclfU(gdishj1KVQclfJ0cq6XsXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIghsgssqY8gltWGdT4HO7H2FiPDWHw5qjgspQgiN2eSOffKjeT0o4qE(qkDizijbjZBSmbdo0IhIUhIElvmoWsHRVXaI0rsn5RQWkwVxY6HLcIr1aC7AwQHjDfwk8punvX1JdeFkWILIrAbi9yPyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8drJdjdjjizEJLjyWHw8q09q7pK0o4qRCOedPhvdKtBcw0IcYeIwAhCipFiLoKmKKGK5nwMGbhAXdr3drVLkghyPW)q1ufxpoq8PalwX69lSEyPGyuna3UMLIdygPFKUcl1RGWJjyWH8n4dnhI2LoegyvWpehmJIdnb)qn(qIpGaPfboe(D)8a8dLwKdL2eSCipuqMqoKuhY0bCO)ZH20IVdj(GdraSyPIXbwkW9OGaJrxeEmbdSumslaPhlfRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGFiACiLoKmKKGK5nwMGbhAXdr3dr)Hu(q0U0H2FiwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGja)qRCiLoKshsPdjdjjizEJLjyWHw8q09q0FiLpeTlDi6pKNpeT09q0FO9hsAhCOvouIH0JQbYPnblArbzcrlTdoKNpKshsPdjdjjizEJLjyWHw8q09q0FiLpeTlDi6Tudt6kSuG7rbbgJUi8ycgyfRyP89OfshVXwpSEtR1dlfeJQb421SuX4alfUJ0VrN0m8EKIG1Gt1aol1WKUclfUJ0VrN0m8EKIG1Gt1aoRy9EjRhwkigvdWTRzPIXbwkChPFJEWpnzcbRbNQbCwQHjDfwkChPFJEWpnzcbRbNQbCwXkwkwLaIje9O2Mwuy9W6nTwpSuqmQgGBxZsXiTaKESu46Bu7GNtsQeGUJeDYImsxrgIr1a8dT)qkDiwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGja)q04qlTSdTWchIvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWp0kh6fl7q0BPgM0vyPW13OjLyfR3lz9WsbXOAaUDnlfJ0cq6XsHRVrTdEoTbdxxPAvtHXLdNHyuna)q7p0dizo4QOzArbzcjpmPtawQHjDfwkC9nAsjwX69lSEyPGyuna3UMLIrAbi9yPW13O2bpVPnCTVFiAzysZWzigvdWTudt6kSu46B0KsSI1Bp16HLcIr1aC7AwkgPfG0JLsPdHRVrTdE2adxRQqd7g3JbYqmQgGFOfw4q46Bu7GNFdj6aRRA5ay6izgIr1a8dr)H2FiLo0dizo4QOzArbzcjpmPtahA)HW13OX(gc)q04qlDOfw4qSQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpata(Hw5qE6Yoe9wQHjDfwkoWA3iDKuRwgXkwVPR1dlfeJQb421SumslaPhlLshcxFJAh8CArscQfjanbsaKgWzigvdWp0clCiLoeU(g1o45eLzK2aACzsaHKHyuna)q7pKNCiC9nQDWZVHeDG1vTCamDKmdXOAa(HO)q0FO9hYto0dizo4QOzArbzcjpmPtawQHjDfwkoWA3iDKuRwgXkwVxhRhwkigvdWTRzPgM0vyPsna2hJmPILIrAbi9yPW13O2bpNOmJ0gqJltciKmeJQb4wQoeGq(pIUtTuQ)00CIYmsBanUmjGqY)hRy9(vTEyPGyuna3UMLIrAbi9yPW13O2bpZkN6iAhWBzKUImeJQb4hA)HEajZbxfntlkiti5HjDcWsnmPRWsHz1N0rsT0IpWkwVFDRhwkigvdWTRzPyKwaspwkp5q46Bu7GNzLtDeTd4TmsxrgIr1aCl1WKUclfMvFshj1sl(aRy9EDz9WsbXOAaUDnlfJ0cq6Xs9asMdUkAMwuqMqYdt6eWH2FiC9nASVHWpK)dTml1WKUclv7EGG3rsnBKblK6XhyfRyPefKjengK)J1dR30A9WsbXOAaUDnlfJ0cq6XsXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIghIw6APgM0vyPcq8be9trKXyfR3lz9WsbXOAaUDnlfJ0cq6XsXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIghI2x9qE(qkDOHjDfz835QqZbxfntlkitizyhW(cOL2bhs5dnmPRiJ9n8AJwTmsg2bSVaAPDWHO)q7pKshIvLHxBImBmgnNadhlJ5nqWzc4MoWhIghI2x9qE(qkDOHjDfz835QqZbxfntlkitizyhW(cOL2bhs5dnmPRiJ)oxf6eTbsBi4zyhW(cOL2bhs5dnmPRiJ9n8AJwTmsg2bSVaAPDWHO)qlSWHEajZjWWXYyEdKmbCth4dTYHyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8dP8HgM0vKXFNRcnhCv0mTOGmHKHDa7lGwAhCi6Tudt6kSujjTRAcOtbtY)q4wX69lSEyPGyuna3UMLIrAbi9yPu6qSQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpata(HOXHOLUhYZhsPdnmPRiJ)oxfAo4QOzArbzcjd7a2xaT0o4q0FO9hsPdXQYWRnrMngJMtGHJLX8gi4mbCth4drJdrlDpKNpKshAysxrg)DUk0CWvrZ0IcYesg2bSVaAPDWHu(qdt6kY4VZvHorBG0gcEg2bSVaAPDWHO)qlSWHEajZjWWXYyEdKmbCth4dTYHyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8dP8HgM0vKXFNRcnhCv0mTOGmHKHDa7lGwAhCi6pe9hAHfoKshYtoe5hqArsc5nTjLaCSg3jBJUs14)dq6IOXFNRIosMHyuna)q7peRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGFOvoKNUSdrVLAysxHLc)DUk0jAdK2qWTI1Bp16HLcIr1aC7AwkgPfG0JLIvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWpenoeTlDipFiLo0WKUIm(7CvO5GRIMPffKjKmSdyFb0s7GdP8HgM0vKX(gETrRwgjd7a2xaT0o4q0FO9hsAhCOvouIH0JQbYPnblArbzcrlTdoKNpeTlDipFOHjDfz2ymAobgowgZBGGZWoG9fqlTdoKYhAysxrg)DUk0CWvrZ0IcYesg2bSVaAPDWHu(qdt6kYyFdV2OvlJKHDa7lGwAhyPgM0vyPyJXO5ey4yzmVbc2kwVPR1dlfeJQb421SumslaPhlL0o4qRCOedPhvdKtBcw0IcYeIwAhCO9hsPd9asMtGHJLX8gi5HjDc4q7p0dizobgowgZBGKjGB6aFOvo0WKUIm(7CvO5GRIMPffKjKmSdyFb0s7Gdr)H2FiLoKNCizmqiz835QqNOnqAdbpdXOAa(HwyHd9asorBG0gcEEysNaoe9hA)Hu6q46B0yFdHFi)hAzhAHfoKsh6bKmNadhlJ5nqYdt6eWH2FOhqYCcmCSmM3ajta30b(q04qdt6kY4VZvHMdUkAMwuqMqYWoG9fqlTdoKYhAysxrg7B41gTAzKmSdyFb0s7Gdr)HwyHdP0HEajNOnqAdbppmPtahA)HEajNOnqAdbpta30b(q04qdt6kY4VZvHMdUkAMwuqMqYWoG9fqlTdoKYhAysxrg7B41gTAzKmSdyFb0s7Gdr)HwyHdP0Hu)PP5KK2vnb0PGj5Fi88)5q7pK6pnnNK0UQjGofmj)dHNjGB6aFiACOHjDfz835QqZbxfntlkitizyhW(cOL2bhs5dnmPRiJ9n8AJwTmsg2bSVaAPDWHO)q0BPgM0vyPWFNRcnhCv0mTOGmHyfRyP4q68nI1dR30A9WsbXOAaUDnlfhWms)iDfwQL3oG9fGFiibquCiPDWHeFWHgMuKd14dnjM2mQgiBPgM0vyPWpGXOnf7TvSEVK1dl1WKUclfBmgDky89dbiwkigvdWTRzfR3VW6HLAysxHLA2bAPWylfeJQb421SI1Bp16HLAysxHLIdjQpr7MKnZsbXOAaUDnRy9MUwpSuqmQgGBxZsnmPRWsXgJrpmPRqBASyPmnw0X4alLq64niyRy9EDSEyPGyuna3UMLIrAbi9yPiqkbW(gvdyPgM0vyP4v5SI17x16HLcIr1aC7AwkgPfG0JLcxFJAh8CssLa0DKOtwKr6kYqmQgGFOfw4q46Bu7GNtBWW1vQw1uyC5WzigvdWp0clCiC9nQDWZSYPoI2b8wgPRidXOAa(HwyHdXQeqmHKdGrktr4wkSqAMy9Mwl1WKUclfBmg9WKUcTPXILY0yrhJdSuSkbeti6rTnTOWkwVFDRhwkigvdWTRzPgM0vyPyJXOhM0vOnnwSuMgl6yCGLsuqMq0yq(pwX696Y6HLcIr1aC7AwkgPfG0JLsPdXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIghI2LDO9hsAhCOvouIH0JQbYPnblArbzcrlTdoKNpeTl7qlSWHW13O2bptG0oaU(zmJazigvdWp0(dXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIgh6fV(HO3snmPRWs9usxHvSEt7YSEyPGyuna3UMLIrAbi9yPEajZbxfntlkiti5HjDcWsHfsZeR30APgM0vyPyJXOhM0vOnnwSuMgl6yCGLQsY4wX6nT0A9WsbXOAaUDnlfJ0cq6XsP0H8Kdr(bKwKKqEtBsjahRXDY2ORun()aKUiA835QOJKzigvdWp0(dXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hALdTUoe9hAHfoKsh6bKmhCv0mTOGmHKhM0jGdT)qpGK5GRIMPffKjKmbCth4drJdTohADFOKmE2n7oe9wQHjDfwko4QOzASqGiP4ZkwVPDjRhwkigvdWTRzPyKwaspwkwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGja)qRCOLw2H88HO7Hw3hYtoe5hqArsc5nTjLaCSg3jBJUs14)dq6IOXFNRIosMHyuna3snmPRWsXgJrZjWWXYyEdeSvSEt7lSEyPGyuna3UMLIrAbi9yPu)PP5nTHRB3doJLH9(qRCiAp0(dP(ttZCWvrZ0SIazSmS3hIgh6fwQHjDfwQNAdq04(XxfwX6nTEQ1dlfeJQb421SumslaPhlL6pnnlkitizETjo0(dXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hALdrxl1WKUclLABamR(KKGwTCQabBfR30sxRhwkigvdWTRzPyKwaspwQHjDcqdb4AaFOvoeThs5dP0HO9qR7djJbcjJhgPtBgW146BWzigvdWpe9hA)Hu)PP5nTHRB3doJLH9(qR4)qRZH2Fi1FAAwuqMqY8AtCO9hIvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWp0khIUwQHjDfwQ29ykCxHvSEt76y9WsbXOAaUDnlfJ0cq6XsnmPtaAiaxd4dTYHw6q7pK6pnnVPnCD7EWzSmS3hAf)hADo0(dP(ttZIcYesMxBIdT)qSQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpata(Hw5q09q7pKNCiYpG0IKeYT7Xu4obOFkbcPhtgIr1a8dT)qkDip5qYyGqYPKYPfFGg7B41gCgIr1a8dTWchs9NMMtjLtl(an23WRn48)5q0BPgM0vyPA3JPWDfwX6nTVQ1dlfeJQb421SumslaPhl1WKobOHaCnGp0khAPdT)qQ)008M2W1T7bNXYWEFOv8FO15q7pK6pnn3UhtH7eG(PeiKEmzc4MoWhIghAPdT)qKFaPfjjKB3JPWDcq)ucespMmeJQb4wQHjDfwQ29ykCxHvSEt7RB9WsbXOAaUDnlfJ0cq6XsP(ttZBAdx3UhCgld79HwX)HODPdT)qYyGqY46B0Sk4)wYqmQgGFO9hsgdesoLuoT4d0yFdV2GZqmQgGFO9hI8diTijHC7EmfUta6NsGq6XKHyuna)q7pK6pnnlkitizETjo0(dXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hALdrxl1WKUclv7EmfURWkwVPDDz9WsbXOAaUDnlfJ0cq6XsPwy8H2FiPDGwknVHdrJd9ILzPgM0vyPssAx1eqNcMK)HWTI17LwM1dlfeJQb421SumslaPhlLAHXhA)HK2bAP08goeno0sVULAysxHLc)DUk0jAdK2qWTI17LO16HLcIr1aC7AwkgPfG0JLsTW4dT)qs7aTuAEdhIghIw6APgM0vyPWFNRcnhCv0mTOGmHyfR3lTK1dlfeJQb421SumslaPhlfU(gn23q4hY)HORLAysxHLY3eCDLQt(n8jSI17LEH1dlfeJQb421Sudt6kSu(MGRRuDYVHpHLIdygPFKUcl1Yn9qRpbgowgZBGGp0qGdngcmCfhAysNa86qrDOaa(HK6q4jbCiSVHWXwkgPfG0JLcxFJg7Bi8dTI)d9IdT)qkDOhqYCcmCSmM3ajpmPtahAHfo0dizo4QOzArbzcjpmPtahIERy9Ejp16HLcIr1aC7AwkgPfG0JLcxFJg7Bi8dTI)dr7H2Fi1FAAoaXhq0pfrgt()CO9hIvLHxBImBmgnNadhlJ5nqWzc4MoWhALdT0Hw3hkjJNDZol1WKUclLVj46kvN8B4tyfR3lrxRhwkigvdWTRzPyKwaspwkC9nASVHWp0k(peThA)Hyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8drJdLKXZUz3H2FiPDWHw5q0U0H88HsY4z3S7q7pKshs9NMM5ey4yzmVbco)Fo0(dP(ttZCcmCSmM3abNjGB6aFOvo0WKUISVj46kvN8B4tKHDa7lGwAhCiLp0WKUIm(7CvO5GRIMPffKjKmSdyFb0s7Gdr)H2FiLoKNCizmqiz835QqNOnqAdbpdXOAa(HwyHdP(ttZjAdK2qWZ)NdrVLAysxHLY3eCDLQt(n8jSI17LwhRhwkigvdWTRzPyKwaspwkp5qSkbeti5eqi(uqSuyH0mX6nTwQHjDfwk2ym6HjDfAtJflLPXIoghyPyvciMq0JABArHvSEV0RA9WsbXOAaUDnl1WKUclfU(gnwi9BWsXbmJ0psxHL6v2IV6lhIAyKoTza)qu13G96qu13CikH0VHd14dHfsfjbYHeFtCO1hCvOwgXRdHRd1YH8n4dnhYxN0hqo0dPlslkSumslaPhlLNCizmqiz8WiDAZaUgxFdodXOAaUvSEV0RB9WsbXOAaUDnl1WKUclfhCvOwgXsXbmJ0psxHLI6bc(HwFWvrZoenxeaFO0ICiQ6BoeLVHWXh6hsBoKhkitihIvLHxBId14dXmfgoKuhIadxHLIrAbi9yPu)PPzo4QOzAwrGmbgMCO9hcxFJg7Bi8drJd5PhA)Hyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8dTYHwAzwX69sRlRhwkigvdWTRzPgM0vyP4GRc1YiwkoGzK(r6kSuR)N0rYd5HcYeYHWG8F86q4hi4hA9bxfn7q0Cra8HslYHOQV5qu(gchBPyKwaspwk1FAAMdUkAMMveitGHjhA)HW13OX(gc)q04qE6H2FiwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGja)q04q0UKvSE)ILz9WsbXOAaUDnlfJ0cq6XsP(ttZCWvrZ0SIazcmm5q7peU(gn23q4hIghYtp0(dP0Hu)PPzo4QOzAwrGmwg27dTYHw6qlSWHKXaHKXdJ0Pnd4AC9n4meJQb4hIEl1WKUclfhCvOwgXkwVFbTwpSuqmQgGBxZsXiTaKESuQ)00mhCv0mnRiqMadto0(dHRVrJ9ne(HOXH80dT)qdt6eGgcW1a(qRCiATudt6kSuCWvHAzeRy9(flz9WsnmPRWsHRVrJfs)gSuqmQgGBxZkwVFXlSEyPGyuna3UMLAysxHLIngJEysxH20yXszASOJXbwkwLaIje9O2MwuyfR3VWtTEyPGyuna3UMLAysxHLY3eCDLQt(n8jSuCaZi9J0vyPwUPhsr9peBIdLeKdPoS3hsQdr3drvFZHO8neo(qQqArGdT(ey4yzmVbc(qSQm8AtCOgFicmCfEDOwwfFO69O4qsDi8de8dj(a3HIAJLIrAbi9yPW13OX(gc)qR4)qV4q7peRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGFOvo0s09q7pKshsgdesMdUkAMMngthjZqmQgGFOfw4qSQm8AtKzJXO5ey4yzmVbcota30b(qRCiLoKshIUhYZhcxFJg7Bi8dr)Hw3hAysxrg7B41gTAzKmSdyFb0s7Gdr)Hu(qdt6kY(MGRRuDYVHprg2bSVaAPDWHO3kwVFbDTEyPGyuna3UMLAysxHLIxLZsXiTaKESueiLayFJQbo0(djTdo0khkXq6r1a50MGfTOGmHOL2bwkMcMb0Yqscc26nTwX69lwhRhwQHjDfwkSVHxB0QLrSuqmQgGBxZkwXs9qaw5uhX6H1BATEyPGyuna3UMLAysxHLkfmAE56yKUclfhWms)iDfwQL3oG9fGFiviTiWHyLtDKdPcj7aNp0RHXGhbFOOcp7BiU0V5qdt6kWhQcJISLIrAbi9yPK2bhALdTSdT)qEYHEajpMobyfR3lz9WsnmPRWsH)oxf6uWK8peULcIr1aC7AwX69lSEyPGyuna3UMLkghyPKYb6kv7QalK6J1SkWc5ZKUcSLAysxHLskhORuTRcSqQpwZQalKpt6kWwX6TNA9WsbXOAaUDnlvmoWsHldm(WAmWiGOfG5l61ZhSudt6kSu4YaJpSgdmciAby(IE98bRy9MUwpSudt6kSuPga7JrMuXsbXOAaUDnRy9EDSEyPGyuna3UMLIrAbi9yPu)PP5nTHRB3doJLH9(qRCiAp0(dP(ttZCWvrZ0SIazSmS3hIg(p0swQHjDfwQNAdq04(XxfwX69RA9WsbXOAaUDnlfJ0cq6XsP0Hulm(qlSWHgM0vK5GRc1Yiz2GLd5)ql7q0FO9hcxFJg7BiC8HOXH8ul1WKUclfhCvOwgXkwVFDRhwkigvdWTRzPyKwaspwkp5qkDi1cJp0clCOHjDfzo4QqTmsMny5q(p0Yoe9hAHfoeU(gn23q44dTYHEHLAysxHLc7B41gTAzeRy9EDz9WsbXOAaUDnlv9yPWGyPgM0vyPsmKEunGLkXy(GLI2LSujgIoghyPsBcw0IcYeIwAhyfRyPeshVbbB9W6nTwpSuqmQgGBxZsnmPRWsH9n8AdW1frvxPAPioielfJ0cq6XsXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hIghIw6APIXbwkSVHxBaUUiQ6kvlfXbHyfR3lz9WsbXOAaUDnlfJ0cq6XsjJbcjZbxfntZQa)DpsxrgIr1a8dT)qSQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpata(HOXHwAzwQHjDfwk2ym6HjDfAtJflLPXIoghyP89OfshVXwX69lSEyPGyuna3UMLIdygPFKUcl1Ylnfyc(qIVroKqMeG5qytTXO4qsDizijb5qey98BcCOHZBPRymEDim8mKrGd5BcUPJKwQHjDfwk2ym6HjDfAtJflLPXIoghyPWMAJwiD8geSvSE7PwpSuqmQgGBxZsnmPRWsvjasQP20rs9eTB0SjjyPyKwaspwQhqYCWvrZ0IcYesEysNaSuX4alvLaiPMAthj1t0UrZMKGvSEtxRhwkigvdWTRzPyKwaspwkH0XBqYcTzFdw)XGw9NMEO9h6bKmhCv0mTOGmHKhM0jal1WKUclLq64ni0AfR3RJ1dlfeJQb421SumslaPhlLq64nizzPSVbR)yqR(ttp0(d9asMdUkAMwuqMqYdt6eGLAysxHLsiD8gKLSI17x16HLcIr1aC7AwkgPfG0JLsAhCOvouIH0JQbYPnblArbzcrlTdo0(dXQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4hALdT0YSudt6kSuSXy0dt6k0MglwktJfDmoWs98jGMpUjjOfshVXwXkwQNpb08XnjbTq64n26H1BATEyPGyuna3UMLkghyP4ey4Pnb0jamgmwQHjDfwkobgEAtaDcaJbJvSEVK1dlfeJQb421SuX4alfU(gDNmAbiwQHjDfwkC9n6oz0cqSI17xy9WsbXOAaUDnl1WKUclvsJIhF6kvpyC7AZiDfwkgPfG0JLAysNa0qaUgWhY)HO1sfJdSujnkE8PRu9GXTRnJ0vyfR3EQ1dlfeJQb421SuX4alfFiVDvfAoWERF(cbWmiyGLAysxHLIpK3UQcnhyV1pFHaygemWkwVPR1dlfeJQb421SuX4alfOwbU(gDIgdwQHjDfwkqTcC9n6engSI171X6HLcIr1aC7AwQyCGL6hmFthaxN0m8EKIG1yFd7TbWwQHjDfwQFW8nDaCDsZW7rkcwJ9nS3gaBfRyPQKmU1dR30A9WsnmPRWsPcemqE3rslfeJQb421SI17LSEyPgM0vyPunvX1PFIclfeJQb421SI17xy9WsnmPRWsL2eq1uf3sbXOAaUDnRy92tTEyPgM0vyP(yq3c4WwkigvdWTRzfRyflvcGG7kSEV0YwI2L9Ql7vTuBgs0rsSL6v(AwV8E569RLoo0H8WhCO29ue5qPf5qRIn1gTq64ni4vpebwp)Ma8dHlhCO5lLBeGFiMVjsc48TLM6aoeT0XHO5ksaeb4hIQD08HWkcz2DOL)HK6q00FoeVt04UIdvpazKICiLwK(dP0s7OpFBPPoGdTeDCiAUIeara(HOAhnFiSIqMDhA5FiPoen9NdX7enUR4q1dqgPihsPfP)qkT0o6Z3wAQd4qVGooenxrcGia)quTJMpewriZUdT8pKuhIM(ZH4DIg3vCO6biJuKdP0I0FiLEXo6Z32B7R81SE59Y17xlDCOd5Hp4qT7PiYHslYHwLvjGycrpQTPffREicSE(nb4hcxo4qZxk3ia)qmFtKeW5Bln1bCiAPJdrZvKaicWp0Q46Bu7GNF5QhsQdTkU(g1o45xMHyunaF1dPeT7OpFBPPoGdTeDCiAUIeara(HwfxFJAh88lx9qsDOvX13O2bp)YmeJQb4REiLODh95Bln1bCOxqhhIMRibqeGFOvX13O2bp)YvpKuhAvC9nQDWZVmdXOAa(QhAKdT8Ef00HuI2D0NVT0uhWH8u64q0CfjaIa8dTkU(g1o45xU6HK6qRIRVrTdE(LzigvdWx9qkT0o6Z3wAQd4q0LooenxrcGia)qRIRVrTdE(LREiPo0Q46Bu7GNFzgIr1a8vpKsVyh95Bln1bCO1HooenxrcGia)qRIRVrTdE(LREiPo0Q46Bu7GNFzgIr1a8vp0ihA59kOPdPeT7OpFBPPoGd9Q0XHO5ksaeb4hAvC9nQDWZVC1dj1HwfxFJAh88lZqmQgGV6HuI2D0NVT0uhWHED64q0CfjaIa8dTkU(g1o45xU6HK6qRIRVrTdE(LzigvdWx9qJCOL3RGMoKs0UJ(8T92(kFnRxEVC9(1shh6qE4dou7EkICO0ICOvffKjengK)ZQhIaRNFta(HWLdo08LYncWpeZ3ejbC(2stDah6f0XHO5ksaeb4hAvYpG0IKeYVC1dj1HwL8diTijH8lZqmQgGV6HuI2D0NVT32x5Rz9Y7LR3Vw64qhYdFWHA3trKdLwKdTkhsNVrw9qey98BcWpeUCWHMVuUra(Hy(MijGZ3wAQd4qVkDCiAUIeara(HwfxFJAh88lx9qsDOvX13O2bp)YmeJQb4REiLEXo6Z3wAQd4qRl64q0CfjaIa8dTkU(g1o45xU6HK6qRIRVrTdE(LzigvdWx9qkr7o6Z3wAQd4q0slDCiAUIeara(HwL8diTijH8lx9qsDOvj)aslssi)YmeJQb4REiLODh95Bln1bCiAxIooenxrcGia)qRs(bKwKKq(LREiPo0QKFaPfjjKFzgIr1a8vp0ihA59kOPdPeT7OpFBPPoGdr76qhhIMRibqeGFOvj)aslssi)YvpKuhAvYpG0IKeYVmdXOAa(QhsjA3rF(2stDahI2xLooenxrcGia)qRs(bKwKKq(LREiPo0QKFaPfjjKFzgIr1a8vp0ihA59kOPdPeT7OpFBPPoGdr7RthhIMRibqeGFOvj)aslssi)YvpKuhAvYpG0IKeYVmdXOAa(QhsjA3rF(2EBFLVM1lVxUE)APJdDip8bhQDpfrouAro0QcPJ3GGx9qey98BcWpeUCWHMVuUra(Hy(MijGZ3wAQd4q0LooenxrcGia)qRkKoEdsM28lx9qsDOvfshVbjl0MF5QhsjA3rF(2stDahADOJdrZvKaicWp0QcPJ3GKxk)YvpKuhAvH0XBqYYs5xU6HuI2D0NVT32LR7PicWp066qdt6koKPXcoFBTupKkTnGLIoPZdT(GRIYujvCOx5qmf79TLoPZd5tKhmDS4IjBX3xnZk3I429nJ0vWitQSiUDSfVT0jDEOTFJId96EDOLw2s0EBVT0jDEiA23ejbmDCBPt68qE(qupGXCiAQyVZ3w6KopKNp0RimkoebyLZbb)qRp4QqTmYHEiGNzLtDKd1PhQLd14d1bwMqoKsf5q(gcNny5qPf5qQfgdy6Z3w6KopKNp0YzTbihIQF8vXHgJP2a8d9qapZkN6ihsQd9qk2H6altihA9bxfQLrY3w6KopKNp0YzILZdjJbc5qDiaH8FK8TLoPZd55d9Asun)quR55vwowV2dHFg3H24dIdPO(RsGdfLCOrT(YHK6q4VZvXHMd5HcYes(2sN05H88HwVBaSpgzsLfxVvMrAdCiQYKac5qSjyGr3PhI5BIKa)qsDOoeGq(pIUtZ32BlDEOL3oG9fGFiviTiWHyLtDKdPcj7aNp0RHXGhbFOOcp7BiU0V5qdt6kWhQcJI8TDysxbo)qaw5uhrz)lMcgnVCDmsxHxDQFPDWklBVN8asEmDc42omPRaNFiaRCQJOS)fXFNRc9di32HjDf48dbyLtDeL9V4hd6waNxX4a)s5aDLQDvGfs9XAwfyH8zsxb(2omPRaNFiaRCQJOS)f)yq3c48kgh4hxgy8H1yGrarlaZx0RNpCBhM0vGZpeGvo1ru2)IPga7JrMu52omPRaNFiaRCQJOS)fFQnarJ7hFv4vN6x9NMM30gUUDp4mwg27vODV6pnnZbxfntZkcKXYWEtd)lDBhM0vGZpeGvo1ru2)ICWvHAzeV6u)kPwy8clmmPRiZbxfQLrYSbl(xg97X13OX(gchtdp92omPRaNFiaRCQJOS)fX(gETrRwgXRo1VNOKAHXlSWWKUImhCvOwgjZgS4Fz0VWc46B0yFdHJx5f32HjDf48dbyLtDeL9VyIH0JQb8kgh4pTjyrlkitiAPDGx1JFmiELymFWpTlDBVT05HwE7a2xa(HGearXHK2bhs8bhAysrouJp0KyAZOAG8TDysxb2p(bmgTPyVVTdt6kWk7Fr2ym6uW47hcqUTdt6kWk7FXzhOLcJVTdt6kWk7FroKO(eTBs2SB7WKUcSY(xKngJEysxH20yXRyCGFH0XBqW32HjDfyL9ViVkNxDQFcKsaSVr1a32HjDfyL9ViBmg9WKUcTPXIxX4a)Skbeti6rTnTOWlSqAM4NwV6u)46Bu7GNtsQeGUJeDYImsxXclGRVrTdEoTbdxxPAvtHXLdVWc46Bu7GNzLtDeTd4TmsxXclWQeqmHKdGrktr432HjDfyL9ViBmg9WKUcTPXIxX4a)IcYeIgdY)52omPRaRS)fFkPRWRo1VsSQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpataonODz7L2bRKyi9OAGCAtWIwuqMq0s7apt7YwybC9nQDWZeiTdGRFgZiWEwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGjaNgV41P)2omPRaRS)fzJXOhM0vOnnw8kgh4VsY4EHfsZe)06vN6)bKmhCv0mTOGmHKhM0jGB7WKUcSY(xKdUkAMgleisk(8Qt9RKNq(bKwKKqEtBsjahRXDY2ORun()aKUiA835QOJK7zvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8vwx0VWck9asMdUkAMwuqMqYdt6eW(hqYCWvrZ0IcYesMaUPdmnwN1Dsgp7MD0FBhM0vGv2)ISXy0CcmCSmM3ab7vN6NvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWxzPL5z6UU9eYpG0IKeYBAtkb4ynUt2gDLQX)hG0frJ)oxfDK82omPRaRS)fFQnarJ7hFv4vN6x9NMM30gUUDp4mwg27vODV6pnnZbxfntZkcKXYWEtJxCBhM0vGv2)IQTbWS6tscA1YPceSxDQF1FAAwuqMqY8AtSNvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWxHU32HjDfyL9Vy7EmfURWRo1)WKobOHaCnGxHwLvI21TmgiKmEyKoTzaxJRVbNHyunaN(9Q)008M2W1T7bNXYWEVI)1zV6pnnlkitizETj2ZQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4Rq3B7WKUcSY(xSDpMc3v4vN6FysNa0qaUgWRS0E1FAAEtB4629GZyzyVxX)6Sx9NMMffKjKmV2e7zvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8vO7EpH8diTijHC7EmfUta6NsGq6XSxjprgdesoLuoT4d0yFdV2GZqmQgGVWcQ)00CkPCAXhOX(gETbN)p0FBhM0vGv2)IT7Xu4UcV6u)dt6eGgcW1aELL2R(ttZBAdx3UhCgld79k(xN9Q)00C7EmfUta6NsGq6XKjGB6atJL2t(bKwKKqUDpMc3ja9tjqi9yUTdt6kWk7FX29ykCxHxDQF1FAAEtB4629GZyzyVxXpTlTxgdesgxFJMvb)3sgIr1a89YyGqYPKYPfFGg7B41gCgIr1a89KFaPfjjKB3JPWDcq)ucespM9Q)00SOGmHK51MypRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGVcDVTdt6kWk7FXKK2vnb0PGj5FiCV6u)QfgVxAhOLsZBGgVyz32HjDfyL9Vi(7CvOt0giTHG7vN6xTW49s7aTuAEd0yPx)2omPRaRS)fXFNRcnhCv0mTOGmH4vN6xTW49s7aTuAEd0Gw6EBhM0vGv2)I(MGRRuDYVHpHxDQFC9nASVHW9t3BlDEOLB6HwFcmCSmM3abFOHahAmey4ko0WKob41HI6qba8dj1HWtc4qyFdHJVTdt6kWk7FrFtW1vQo53WNWRo1pU(gn23q4R4)f7v6bKmNadhlJ5nqYdt6eWcl8asMdUkAMwuqMqYdt6ea932HjDfyL9VOVj46kvN8B4t4vN6hxFJg7Bi8v8t7E1FAAoaXhq0pfrgt()SNvLHxBImBmgnNadhlJ5nqWzc4MoWRS06ojJNDZUB7WKUcSY(x03eCDLQt(n8j8Qt9JRVrJ9ne(k(PDpRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGtJKmE2n72lTdwH2L8Csgp7MD7vs9NMM5ey4yzmVbco)F2R(ttZCcmCSmM3abNjGB6aVYWKUISVj46kvN8B4tKHDa7lGwAhO8WKUIm(7CvO5GRIMPffKjKmSdyFb0s7a63RKNiJbcjJ)oxf6eTbsBi4zigvdWxyb1FAAorBG0gcE()q)TDysxbwz)lYgJrpmPRqBAS4vmoWpRsaXeIEuBtlk8clKMj(P1Ro1VNWQeqmHKtaH4tb52sNh6v2IV6lhIAyKoTza)qu13G96qu13CikH0VHd14dHfsfjbYHeFtCO1hCvOwgXRdHRd1YH8n4dnhYxN0hqo0dPlslkUTdt6kWk7FrC9nASq63GxDQFprgdesgpmsN2mGRX13GZqmQgGFBPZdr9ab)qRp4QOzhIMlcGpuAroev9nhIY3q44d9dPnhYdfKjKdXQYWRnXHA8HyMcdhsQdrGHR42omPRaRS)f5GRc1YiE1P(v)PPzo4QOzAwrGmbgMShxFJg7BiCA4P7zvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMa8vwAz3w68qR)N0rYd5HcYeYHWG8F86q4hi4hA9bxfn7q0Cra8HslYHOQV5qu(gchFBhM0vGv2)ICWvHAzeV6u)Q)00mhCv0mnRiqMadt2JRVrJ9neon809SQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpataonODPB7WKUcSY(xKdUkulJ4vN6x9NMM5GRIMPzfbYeyyYEC9nASVHWPHNUxj1FAAMdUkAMMveiJLH9ELLwybzmqiz8WiDAZaUgxFdodXOAao932HjDfyL9VihCvOwgXRo1V6pnnZbxfntZkcKjWWK946B0yFdHtdpD)WKobOHaCnGxH2B7WKUcSY(xexFJglK(nCBhM0vGv2)ISXy0dt6k0MglEfJd8ZQeqmHOh120IIBlDEOLB6Huu)dXM4qjb5qQd79HK6q09qu13CikFdHJpKkKwe4qRpbgowgZBGGpeRkdV2ehQXhIadxHxhQLvXhQEpkoKuhc)ab)qIpWDOO2CBhM0vGv2)I(MGRRuDYVHpHxDQFC9nASVHWxX)l2ZQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4RSeD3RKmgiKmhCv0mnBmMosMHyunaFHfyvz41MiZgJrZjWWXYyEdeCMaUPd8kkPeD9mU(gn23q40VUhM0vKX(gETrRwgjd7a2xaT0oGELhM0vK9nbxxP6KFdFImSdyFb0s7a6VTdt6kWk7FrEvoVykygqldjjiy)06vN6NaPea7BunWEPDWkjgspQgiN2eSOffKjeT0o42omPRaRS)fX(gETrRwg52EBhM0vGZytTrlKoEdc2)hd6waNxX4a)46BmGiDKut(Qk8Qt9ZQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb40qgssqY8gltWGLpD3lTdwjXq6r1a50MGfTOGmHOL2bEwjzijbjZBSmbdw(0L(B7WKUcCgBQnAH0XBqWk7FXpg0TaoVIXb(X)q1ufxpoq8PalE1P(zvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMaCAidjjizEJLjyWYNU7L2bRKyi9OAGCAtWIwuqMq0s7apRKmKKGK5nwMGblF6s)TLop0RGWJjyWH8n4dnhI2LoegyvWpehmJIdnb)qn(qIpGaPfboe(D)8a8dLwKdL2eSCipuqMqoKuhY0bCO)ZH20IVdj(GdraSCBhM0vGZytTrlKoEdcwz)l(XGUfW5vmoWp4EuqGXOlcpMGbE1P(zvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMaCAOKmKKGK5nwMGblF6sVY0U0EwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGjaFfLusjzijbjZBSmbdw(0LELPDj69mT0L(9s7GvsmKEunqoTjyrlkitiAPDGNvsjzijbjZBSmbdw(0LELPDj6VT32HjDf4mRsaXeIEuBtlk8JRVrtkXRo1pU(g1o45KKkbO7irNSiJ0vSxjwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGjaNglTSfwGvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWx5flJ(B7WKUcCMvjGycrpQTPffk7FrC9nAsjE1P(X13O2bpN2GHRRuTQPW4YH3)asMdUkAMwuqMqYdt6eWTDysxboZQeqmHOh120IcL9ViU(gnPeV6u)46Bu7GN30gU23peTmmPz4B7WKUcCMvjGycrpQTPffk7FroWA3iDKuRwgXRo1Vs46Bu7GNnWW1Qk0WUX9yGfwaxFJAh88BirhyDvlhathjPFVspGK5GRIMPffKjK8WKobShxFJg7BiCAS0clWQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb4R4PlJ(B7WKUcCMvjGycrpQTPffk7FroWA3iDKuRwgXRo1Vs46Bu7GNtlssqTibOjqcG0aEHfucxFJAh8CIYmsBanUmjGq27j46Bu7GNFdj6aRRA5ay6ij90V3tEajZbxfntlkiti5HjDc42omPRaNzvciMq0JABArHY(xm1ayFmYKkE1P(X13O2bpNOmJ0gqJltcieV6qac5)i6o1V6pnnNOmJ0gqJltciK8)52omPRaNzvciMq0JABArHY(xeZQpPJKAPfFGxDQFC9nQDWZSYPoI2b8wgPRy)dizo4QOzArbzcjpmPta32HjDf4mRsaXeIEuBtlku2)Iyw9jDKulT4d8Qt97j46Bu7GNzLtDeTd4TmsxXTDysxboZQeqmHOh120IcL9Vy7EGG3rsnBKblK6Xh4vN6)bKmhCv0mTOGmHKhM0jG946B0yFdH7Fz32B7WKUcC23JwiD8g7)JbDlGZRyCGFChPFJoPz49ifbRbNQbC32HjDf4SVhTq64nwz)l(XGUfW5vmoWpUJ0Vrp4NMmHG1Gt1aUB7TDysxboxjzC)QabdK3DK82omPRaNRKmUY(xu1ufxN(jkUTdt6kW5kjJRS)ftBcOAQIFBhM0vGZvsgxz)l(XGUfWHVT32HjDf48ZNaA(4MKGwiD8g7)JbDlGZRyCGFobgEAtaDcaJbZTDysxbo)8jGMpUjjOfshVXk7FXpg0TaoVIXb(X13O7Krla52omPRaNF(eqZh3Ke0cPJ3yL9V4hd6waNxX4a)jnkE8PRu9GXTRnJ0v4vN6FysNa0qaUgW(P92omPRaNF(eqZh3Ke0cPJ3yL9V4hd6waNxX4a)8H82vvO5a7T(5leaZGGb32HjDf48ZNaA(4MKGwiD8gRS)f)yq3c48kgh4huRaxFJorJHB7WKUcC(5tanFCtsqlKoEJv2)IFmOBbCEfJd8)dMVPdGRtAgEpsrWASVH92a4B7TDysxbolKoEdc2)hd6waNxX4a)yFdV2aCDru1vQwkIdcXRo1pRkdV2ez835QqZbxfntlkitizc4MoWAy3dWeGtdAP7TDysxbolKoEdcwz)lYgJrpmPRqBAS4vmoWVVhTq64n2Ro1VmgiKmhCv0mnRc839iDfzigvdW3ZQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb40yPLDBPZdT8stbMGpK4BKdjKjbyoe2uBmkoKuhsgssqoebwp)MahA48w6kgJxhcdpdze4q(MGB6i5TDysxbolKoEdcwz)lYgJrpmPRqBAS4vmoWp2uB0cPJ3GGVTdt6kWzH0XBqWk7FXpg0TaoVIXb(Reaj1uB6iPEI2nA2Ke8Qt9)asMdUkAMwuqMqYdt6eWTDysxbolKoEdcwz)lkKoEdcTE1P(fshVbjtB23G1FmOv)PP7FajZbxfntlkiti5HjDc42omPRaNfshVbbRS)ffshVbzjV6u)cPJ3GKxk7BW6pg0Q)009pGK5GRIMPffKjK8WKobCBhM0vGZcPJ3GGv2)ISXy0dt6k0MglEfJd8)8jGMpUjjOfshVXE1P(L2bRKyi9OAGCAtWIwuqMq0s7G9SQm8AtKXFNRcnhCv0mTOGmHKjGB6aRHDpata(klTSB7TDysxbolkitiAmi)h)bi(aI(PiYy8Qt9ZQYWRnrg)DUk0CWvrZ0IcYesMaUPdSg29amb40Gw6EBhM0vGZIcYeIgdY)rz)lMK0UQjGofmj)dH7vN6NvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWPbTVQNvAysxrg)DUk0CWvrZ0IcYesg2bSVaAPDGYdt6kYyFdV2OvlJKHDa7lGwAhq)ELyvz41MiZgJrZjWWXYyEdeCMaUPdmnO9v9Ssdt6kY4VZvHMdUkAMwuqMqYWoG9fqlTduEysxrg)DUk0jAdK2qWZWoG9fqlTduEysxrg7B41gTAzKmSdyFb0s7a6xyHhqYCcmCSmM3ajta30bEfwvgETjY4VZvHMdUkAMwuqMqYeWnDG1WUhGjax5HjDfz835QqZbxfntlkitizyhW(cOL2b0FBhM0vGZIcYeIgdY)rz)lI)oxf6eTbsBi4E1P(vIvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWPbT01ZknmPRiJ)oxfAo4QOzArbzcjd7a2xaT0oG(9kXQYWRnrMngJMtGHJLX8gi4mbCthyAqlD9Ssdt6kY4VZvHMdUkAMwuqMqYWoG9fqlTduEysxrg)DUk0jAdK2qWZWoG9fqlTdOFHfEajZjWWXYyEdKmbCth4vyvz41MiJ)oxfAo4QOzArbzcjta30bwd7EaMaCLhM0vKXFNRcnhCv0mTOGmHKHDa7lGwAhqp9lSGsEc5hqArsc5nTjLaCSg3jBJUs14)dq6IOXFNRIosUNvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWxXtxg932HjDf4SOGmHOXG8Fu2)ISXy0CcmCSmM3ab7vN6NvLHxBIm(7CvO5GRIMPffKjKmbCthynS7bycWPbTl5zLgM0vKXFNRcnhCv0mTOGmHKHDa7lGwAhO8WKUIm23WRnA1YizyhW(cOL2b0VxAhSsIH0JQbYPnblArbzcrlTd8mTl55HjDfz2ymAobgowgZBGGZWoG9fqlTduEysxrg)DUk0CWvrZ0IcYesg2bSVaAPDGYdt6kYyFdV2OvlJKHDa7lGwAhCBhM0vGZIcYeIgdY)rz)lI)oxfAo4QOzArbzcXRo1V0oyLedPhvdKtBcw0IcYeIwAhSxPhqYCcmCSmM3ajpmPta7FajZjWWXYyEdKmbCth4vgM0vKXFNRcnhCv0mTOGmHKHDa7lGwAhq)EL8ezmqiz835QqNOnqAdbpdXOAa(cl8asorBG0gcEEysNaOFVs46B0yFdH7FzlSGspGK5ey4yzmVbsEysNa2)asMtGHJLX8gizc4MoW0yysxrg)DUk0CWvrZ0IcYesg2bSVaAPDGYdt6kYyFdV2OvlJKHDa7lGwAhq)clO0di5eTbsBi45HjDcy)di5eTbsBi4zc4MoW0yysxrg)DUk0CWvrZ0IcYesg2bSVaAPDGYdt6kYyFdV2OvlJKHDa7lGwAhq)clOK6pnnNK0UQjGofmj)dHN)p7v)PP5KK2vnb0PGj5Fi8mbCthyAmmPRiJ)oxfAo4QOzArbzcjd7a2xaT0oq5HjDfzSVHxB0QLrYWoG9fqlTdONEl18fFfXszfRyT]] )


end
