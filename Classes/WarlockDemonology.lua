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


    spec:RegisterSetting( "implosion_imps", 4, {
        name = "Wild Imps for |T2065588:0|t Implosion",
        desc = "When using |T2065588:0|t Implosion, the default priority will require you to have at least this many Wild Imps.\n\n" ..
            "Sims from 9.0 reflected that a minimum of 3 imps are needed for optimal DPS in Hectic Add Cleave (but will result in a lot of repetitive Hand of Guldan -> Implosion casts), while using " ..
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


    spec:RegisterPack( "Demonology", 20210705, [[dKKQJbqiKs1JuLGlPKOSjLkFsjPrrk1PiLSkLevVIu0SOk6wuvQDjQFjIAykjCmKILjc9mLIAAuvIRHuY2usKVHukghPq5CQsOwhPGMNQKUhvP9jcoOsrQfQu4HKcmrLI4IkfjFePuQrIukPtsvjzLkvntsHStQk(jPqLHsku1srkL4PizQuf(QQeYyvLO9sP)sYGHCyflMu9yuMmQUmyZI0NvcJMQQtl1RvLA2u52uSBHFlz4QIJtvj1Yr8COMoX1vvBxj67kPgVsPZJunFrK9RYwASEyP4JawFsCfjsZkOnRGw5vOXOLgJgAzPe6pGL6zyVNfGLkgdyP2eWur5Qf0TupdDxnCRhwkC9jmWsr1gnWsP)BN4RcRULIpcy9jXvKinRG2ScALxHgJwAmASu4hGz9jXvALSu(BohcRULIdyMLAtatfLRwq)qVOH4k27BVFrEWAyYjVOf)F9mRmjJBZ3nsxbJmPsY42Ws(2V)7OFiFXZdL4ksKMB)Txd8pXcaRH3EFFiQhW5oKgvS35BVVpKgx4OFicWkJbc(H2eWuHE5Kd9qaFZkJ(ihQtpulhQXhQdSmHCiTlYH8peoBWYHslYH0lmgWALV9((qA81AGCiQ(XFfhACUAnWp0db8nRm6JCiPo0dPyhQdSmHCOnbmvOxojF799H04xQXFizCqihQdbiK)JKV9((qB6LvZpe1g(obARfT9HWpJ5qR9dXHOx)vjWHIso0OxF5qsDi83yQ4qZH8GozcjBPCnwWwpSuyxTwjKoEdc26H1hASEyPGy0Da3UHLAysxHLcxFNdePJfkYxNULIrAbi9yPyv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8d96HKHSaKmVXYem4qjFiADODhsAdCOeo0YH0JUdYPnblkHozcrjTboKVpK2hsgYcqY8gltWGdL8HO1H0YsfJbSu467CGiDSqr(60TI1NeTEyPGy0Da3UHLAysxHLc)dDxvC1yaXpDSyPyKwaspwkwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qVEizilajZBSmbdouYhIwhA3HK2ahkHdTCi9O7GCAtWIsOtMqusBGd57dP9HKHSaKmVXYem4qjFiADiTSuXyalf(h6UQ4QXaIF6yXkwF2S1dlfeJUd42nSuCaZi9J0vyP04i8ycgCi)d(qZHOjXdHbwf8dXb3q)qtWpuJpK4hiqArGdHF3ppa)qPf5qPnblhYd6KjKdj1HCDah6)CO1T4)qIF4qealwQymGLcmp0jW4ufHhtWalfJ0cq6XsXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4h61dP9HKHSaKmVXYem4qjFiADiToKMhIMep0UdXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4hkHdP9H0(qAFizilajZBSmbdouYhIwhsRdP5HOjXdP1H89HOHwhsRdT7qsBGdLWHwoKE0DqoTjyrj0jtikPnWH89H0(qAFizilajZBSmbdouYhIwhsRdP5HOjXdPLLAysxHLcmp0jW4ufHhtWaRyflL)hLq64n26H1hASEyPGy0Da3UHLkgdyPWDK(DQfUH3JueScm6oWyPgM0vyPWDK(DQfUH3JueScm6oWyfRpjA9WsbXO7aUDdlvmgWsH7i97ud(Pjtiyfy0DGXsnmPRWsH7i97ud(Pjtiyfy0DGXkwXsXQLqmHOg921cDRhwFOX6HLcIr3bC7gwkgPfG0JLcxFNEh88csTeuDSSxuKr6kYqm6oGFODhs7dXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4h61dL4kousjDiwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qjCOnVIdPLLAysxHLcxFNIuIvS(KO1dlfeJUd42nSumslaPhlfU(o9o450gCCvLQ0DfgxgCgIr3b8dT7qpGK5GPIMPe6KjK8WKEjyPgM0vyPW13PiLyfRpB26HLcIr3bC7gwkgPfG0JLcxFNEh8862Xv()HOKHjndNHy0Da3snmPRWsHRVtrkXkwF8fRhwkigDhWTByPyKwaspwkC9D6DWZoy4kD6ky7yECqgIr3b8dT7qAFOhqYCWurZucDYesEysVeo0UdHRVtH9pe(HE9qjEOKs6qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hs4q(YkoKwwQHjDfwkoWAZiDSqPxoXkwFOL1dlfeJUd42nSumslaPhlfTFiC9D6DWZoy4kD6ky7yECqgIr3b8dT7q0(HEajZbtfntj0jti5Hj9sWsnmPRWsXbwBgPJfk9YjwX6Zkz9WsbXO7aUDdlfJ0cq6XsHRVtVdEMvg9rugG3YiDfzigDhWp0Ud9asMdMkAMsOtMqYdt6LGLAysxHLcZQpPJfkPf)GvS(qBSEyPGy0Da3UHLIrAbi9yPO9dHRVtVdEMvg9rugG3YiDfzigDhWTudt6kSuyw9jDSqjT4hSI1hnM1dlfeJUd42nSumslaPhl1dizoyQOzkHozcjpmPxchA3HW13PW(hc)qEp0kSudt6kSuT5bcEhluSrgSqQh)GvSILsOtMquyq(pwpS(qJ1dlfeJUd42nSumslaPhlfRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGFOxpen0YsnmPRWsfG4hiQNIiJZkwFs06HLcIr3bC7gwkgPfG0JLIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhIgAZH89H0(qdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTboKMhAysxrg7F41ALE5KmSfyFbusBGdP1H2DiTpeRkhVwhz24Ckobgowg3BGGZeWmDGp0RhIgAZH89H0(qdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTboKMhAysxrg)nMkulBhK2qWZWwG9fqjTboKMhAysxrg7F41ALE5KmSfyFbusBGdP1HskPd9asMtGHJLX9gizcyMoWhkHdXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4hsZdnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qAzPgM0vyPwqAt1eqLcUf)HWTI1NnB9WsbXO7aUDdlfJ0cq6XsP9Hyv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8d96HOHwhY3hs7dnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qADODhs7dXQYXR1rMnoNItGHJLX9gi4mbmth4d96HOHwhY3hs7dnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qAEOHjDfz83yQqTSDqAdbpdBb2xaL0g4qADOKs6qpGK5ey4yzCVbsMaMPd8Hs4qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(H08qdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTboKwhsRdLushs7dr7hI8diTilG862LsaowH7fTtvPk8)biDru4VXurhlYqm6oGFODhIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWpuchYxwXH0YsnmPRWsH)gtfQLTdsBi4wX6JVy9WsbXO7aUDdlfJ0cq6XsXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4h61drtIhY3hs7dnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qAEOHjDfzS)HxRv6LtYWwG9fqjTboKwhA3HK2ahkHdTCi9O7GCAtWIsOtMqusBGd57drtIhY3hAysxrMnoNItGHJLX9gi4mSfyFbusBGdP5HgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdCinp0WKUIm2)WR1k9YjzylW(cOK2awQHjDfwk24Ckobgowg3BGGTI1hAz9WsbXO7aUDdlfJ0cq6XsjTbouchA5q6r3b50MGfLqNmHOK2ahA3H0(qpGK5ey4yzCVbsEysVeo0Ud9asMtGHJLX9gizcyMoWhkHdnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qADODhs7dr7hsghesg)nMkulBhK2qWZqm6oGFOKs6qpGKx2oiTHGNhM0lHdP1H2DiTpeU(of2)q4hY7HwXHskPdP9HEajZjWWXY4EdK8WKEjCODh6bKmNadhlJ7nqYeWmDGp0RhAysxrg)nMkuCWurZucDYesg2cSVakPnWH08qdt6kYy)dVwR0lNKHTa7lGsAdCiTousjDiTp0di5LTdsBi45Hj9s4q7o0di5LTdsBi4zcyMoWh61dnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qAEOHjDfzS)HxRv6LtYWwG9fqjTboKwhkPKoK2hs)NMMxqAt1eqLcUf)HWZ)NdT7q6)008csBQMaQuWT4peEMaMPd8HE9qdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTboKMhAysxrg7F41ALE5KmSfyFbusBGdP1H0YsnmPRWsH)gtfkoyQOzkHozcXkwXsXH057eRhwFOX6HLcIr3bC7gwkoGzK(r6kSuBQTa7la)qWsGq)qsBGdj(HdnmPihQXhAwoTB0Dq2snmPRWsHFaNt5k2BRy9jrRhwQHjDfwk24CQuW5)hcqSuqm6oGB3WkwF2S1dl1WKUcl1SfusHXwkigDhWTByfRp(I1dl1WKUclfhwwFIYmlAMLcIr3bC7gwX6dTSEyPGy0Da3UHLAysxHLInoNAysxHY1yXs5ASOIXawkH0XBqWwX6Zkz9WsbXO7aUDdlfJ0cq6XsrGucG9p6oWsnmPRWsXRYyfRp0gRhwkigDhWTByPyKwaspwkC9D6DWZli1sq1XYErrgPRidXO7a(HskPdHRVtVdEoTbhxvPkDxHXLbNHy0Da)qjL0HW13P3bpZkJ(ikdWBzKUImeJUd4hkPKoeRwcXesoagPCfHBPWcPzI1hASudt6kSuSX5udt6kuUglwkxJfvmgWsXQLqmHOg921cDRy9rJz9WsbXO7aUDdl1WKUclfBCo1WKUcLRXILY1yrfJbSucDYeIcdY)XkwFEXwpSuqm6oGB3WsXiTaKESuAFiwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qVEiAwXH2DiPnWHs4qlhsp6oiN2eSOe6KjeL0g4q((q0SIdLushcxFNEh8mbs7a4QNXncKHy0Da)q7oeRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGFOxp0M1yhsll1WKUcl1tjDfwX6dnRW6HLcIr3bC7gwkgPfG0JL6bKmhmv0mLqNmHKhM0lblfwintS(qJLAysxHLInoNAysxHY1yXs5ASOIXawQAbJBfRp0qJ1dlfeJUd42nSumslaPhlL2hI2pe5hqArwa51TlLaCSc3lANQsv4)dq6IOWFJPIowKHy0Da)q7oeRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGFOeo0l(qADOKs6qAFOhqYCWurZucDYesEysVeo0Ud9asMdMkAMsOtMqYeWmDGp0RhALo0k)qly8Sz2EiTSudt6kSuCWurZuyHaXcXVvS(qtIwpSuqm6oGB3WsXiTaKESuSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hs4qjUId57drRdTYpeTFiYpG0ISaYRBxkb4yfUx0ovLQW)hG0frH)gtfDSidXO7aULAysxHLInoNItGHJLX9giyRy9HMnB9WsbXO7aUDdlfJ0cq6XsP)ttZRBhx1MhCgld79Hs4q0CODhs)NMM5GPIMPyfbYyzyVp0RhAZwQHjDfwQNAnqu4(XFfwX6dn(I1dlfeJUd42nSumslaPhlL(pnnl0jtizEToo0UdXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4hkHdrll1WKUclLE7amR(KfGsVm6abBfRp0qlRhwkigDhWTByPyKwaspwQHj9sqbbyAaFOeoenhsZdP9HO5qR8djJdcjJhgPtBgWv467WzigDhWpKwhA3H0)PP51TJRAZdoJLH9(qj49qR0H2Di9FAAwOtMqY8ADCODhIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWpuchIwwQHjDfwQ284kCxHvS(qZkz9WsbXO7aUDdlfJ0cq6XsnmPxckiatd4dLWHs8q7oK(pnnVUDCvBEWzSmS3hkbVhALo0UdP)ttZcDYesMxRJdT7qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hs4q06q7oeTFiYpG0ISaYT5Xv4EjOEkbcPhxgIr3b8dT7qAFiA)qY4GqYPKYOe)Gc7F41ACgIr3b8dLushs)NMMtjLrj(bf2)WR148)5qAzPgM0vyPAZJRWDfwX6dn0gRhwkigDhWTByPyKwaspwQHj9sqbbyAaFOeouIhA3H0)PP51TJRAZdoJLH9(qj49qR0H2Di9FAAUnpUc3lb1tjqi94YeWmDGp0RhkXdT7qKFaPfzbKBZJRW9sq9ucespUmeJUd4hA3H0(q0(HKXbHK5GPIMPyvG)MhPRidXO7a(HskPdP9H0)PPzHozcjZR1XH2DiwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qjCiADiToKwwQHjDfwQ284kCxHvS(qJgZ6HLcIr3bC7gwkgPfG0JLs)NMMx3oUQnp4mwg27dLG3drtIhA3HKXbHKX13PyvW)TKHy0Da)q7oKmoiKCkPmkXpOW(hETgNHy0Da)q7oe5hqArwa5284kCVeupLaH0JldXO7a(H2Di9FAAwOtMqY8ADCODhIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWpuchIwwQHjDfwQ284kCxHvS(qZl26HLcIr3bC7gwkgPfG0JLsVW4dT7qsBaLukEdh61dT5vyPgM0vyPwqAt1eqLcUf)HWTI1NexH1dlfeJUd42nSumslaPhlLEHXhA3HK2akPu8go0RhkrnMLAysxHLc)nMkulBhK2qWTI1NePX6HLcIr3bC7gwkgPfG0JLsVW4dT7qsBaLukEdh61drdTSudt6kSu4VXuHIdMkAMsOtMqSI1Net06HLcIr3bC7gwkgPfG0JLcxFNc7Fi8d59q0YsnmPRWs5FcUQsvl(o(ewX6tIB26HLcIr3bC7gwQHjDfwk)tWvvQAX3XNWsXbmJ0psxHLYxLEOnHadhlJ7nqWhAiWHghbgo9dnmPxcEEOOouaa)qsDi8Seoe2)q4ylfJ0cq6XsHRVtH9pe(HsW7H28H2DiTp0dizobgowg3BGKhM0lHdLush6bKmhmv0mLqNmHKhM0lHdPLvS(KOVy9WsbXO7aUDdlfJ0cq6XsHRVtH9pe(HsW7HO5q7oK(pnnhG4hiQNIiJl)Fo0UdXQYXR1rMnoNItGHJLX9gi4mbmth4dLWHs8qR8dTGXZMzRLAysxHLY)eCvLQw8D8jSI1NePL1dlfeJUd42nSumslaPhlfU(of2)q4hkbVhIMdT7qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(HE9qly8Sz2EODhsAdCOeoenjEiFFOfmE2mBp0UdP9H0)PPzobgowg3BGGZ)NdT7q6)00mNadhlJ7nqWzcyMoWhkHdnmPRi7FcUQsvl(o(ezylW(cOK2ahsZdnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qADODhs7dr7hsghesg)nMkulBhK2qWZqm6oGFOKs6q6)008Y2bPne88)5qAzPgM0vyP8pbxvPQfFhFcRy9jXvY6HLcIr3bC7gwkgPfG0JLI2peRwcXesEjeIF6elfwintS(qJLAysxHLInoNAysxHY1yXs5ASOIXawkwTeIje1O3UwOBfRpjsBSEyPGy0Da3UHLAysxHLcxFNclK(nyP4aMr6hPRWs9IAXF9LdrnmsN2mGFiQ67WEEiQ67oeLq63WHA8HWcPIfa5qI)jo0MaMk0lN45HW1HA5q(h8HMd5Vx4hih6H0fPf6wkgPfG0JLI2pKmoiKmEyKoTzaxHRVdNHy0Da3kwFsuJz9WsbXO7aUDdl1WKUclfhmvOxoXsXbmJ0psxHLI6bc(H2eWurZoKgueaFO0ICiQ67oeL)HWXh6hs7oKh0jtihIvLJxRJd14dXCfgoKuhIadNULIrAbi9yP0)PPzoyQOzkwrGmbgMCODhcxFNc7Fi8d96H8LdT7qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hs4qjUcRy9jXxS1dlfeJUd42nSudt6kSuCWuHE5elfhWms)iDfwQn5t6yXH8Gozc5qyq(pEEi8de8dTjGPIMDinOia(qPf5qu13Dik)dHJTumslaPhlL(pnnZbtfntXkcKjWWKdT7q467uy)dHFOxpKVCODhIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhIMeTI1NnVcRhwkigDhWTByPyKwaspwk9FAAMdMkAMIveitGHjhA3HW13PW(hc)qVEiF5q7oK2hs)NMM5GPIMPyfbYyzyVpuchkXdLushsghesgpmsN2mGRW13HZqm6oGFiTSudt6kSuCWuHE5eRy9zZ0y9WsbXO7aUDdlfJ0cq6XsP)ttZCWurZuSIazcmm5q7oeU(of2)q4h61d5lhA3HgM0lbfeGPb8Hs4q0yPgM0vyP4GPc9YjwX6ZMt06HLAysxHLcxFNclK(nyPGy0Da3UHvS(S5nB9WsbXO7aUDdl1WKUclfBCo1WKUcLRXILY1yrfJbSuSAjetiQrVDTq3kwF2SVy9WsbXO7aUDdl1WKUclL)j4QkvT474tyP4aMr6hPRWs5Rspe96Fi2ehAbihsFyVpKuhIwhIQ(Udr5FiC8H0H0IahAtiWWXY4Ede8Hyv54164qn(qey4098qTSk(q17H(HK6q4hi4hs8dMdf1AlfJ0cq6XsHRVtH9pe(HsW7H28H2DiwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qjCOeP1H2DiTpKmoiKmhmv0mfBCUowKHy0Da)qjL0Hyv5416iZgNtXjWWXY4EdeCMaMPd8Hs4qAFiTpeToKVpeU(of2)q4hsRdTYp0WKUIm2)WR1k9YjzylW(cOK2ahsRdP5HgM0vK9pbxvPQfFhFImSfyFbusBGdPLvS(SzAz9WsbXO7aUDdl1WKUclfVkJLIrAbi9yPiqkbW(hDhCODhsAdCOeo0YH0JUdYPnblkHozcrjTbSum6mhOKHSaeS1hASI1NnVswpSudt6kSuy)dVwR0lNyPGy0Da3UHvSIL6HaSYOpI1dRp0y9WsbXO7aUDdl1WKUclvk4u8Y0XiDfwkoGzK(r6kSuBQTa7la)q6qArGdXkJ(ihshw0boFOnnJbpc(qrf(2)qmPF3HgM0vGpufo6zlfJ0cq6XsjTbouchAfhA3HO9d9asEC9sWkwFs06HLAysxHLc)nMkuPGBXFiClfeJUd42nSI1NnB9WsbXO7aUDdlvmgWsjLbuvQYubwi1hRyvGfYNjDfyl1WKUclLugqvPktfyHuFSIvbwiFM0vGTI1hFX6HLcIr3bC7gwQymGLcxoy8JvyGrarjaZF0(6pyPgM0vyPWLdg)yfgyequcW8hTV(dwX6dTSEyPgM0vyPsDa2pJmPILcIr3bC7gwX6Zkz9WsbXO7aUDdlfJ0cq6XsP)ttZRBhx1MhCgld79Hs4q0CODhs)NMM5GPIMPyfbYyzyVp0REpuIwQHjDfwQNAnqu4(XFfwX6dTX6HLcIr3bC7gwkgPfG0JLs7dPxy8HskPdnmPRiZbtf6LtYSblhY7HwXH06q7oeU(of2)q44d96H8fl1WKUclfhmvOxoXkwF0ywpSuqm6oGB3WsXiTaKESu0(H0(q6fgFOKs6qdt6kYCWuHE5KmBWYH8EOvCiTousjDiC9DkS)HWXhkHdTzl1WKUclf2)WR1k9YjwX6Zl26HLcIr3bC7gwQ6XsHbXsnmPRWsTCi9O7al1YX9blfnjAPwoevmgWsL2eSOe6KjeL0gWkwXsjKoEdc26H1hASEyPGy0Da3UHLAysxHLc7F41AGRkIUQsvsrmqiwkgPfG0JLIvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhIgAzPIXawkS)HxRbUQi6QkvjfXaHyfRpjA9WsbXO7aUDdlfJ0cq6XsjJdcjZbtfntXQa)npsxrgIr3b8dT7qSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(HE9qjUcl1WKUclfBCo1WKUcLRXILY1yrfJbSu(FucPJ3yRy9zZwpSuqm6oGB3WsXbmJ0psxHLAtLMcmbFiX)ihsiZsWDiSRw7OFiPoKmKfGCic4R)nbo0W5T0vmoppegEgYiWH8pb31Xcl1WKUclfBCo1WKUcLRXILY1yrfJbSuyxTwjKoEdc2kwF8fRhwkigDhWTByPgM0vyPQLaj1vR7yHAI2mk2SaSumslaPhl1dizoyQOzkHozcjpmPxcwQymGLQwcKuxTUJfQjAZOyZcWkwFOL1dlfeJUd42nSumslaPhlLq64nizHMS)bR(yqP)ttp0Ud9asMdMkAMsOtMqYdt6LGLAysxHLsiD8geASI1NvY6HLcIr3bC7gwkgPfG0JLsiD8gKSKy2)GvFmO0)PPhA3HEajZbtfntj0jti5Hj9sWsnmPRWsjKoEdsIwX6dTX6HLcIr3bC7gwkgPfG0JLsAdCOeo0YH0JUdYPnblkHozcrjTbo0UdXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4hkHdL4kSudt6kSuSX5udt6kuUglwkxJfvmgWs98jGIpMzbOeshVXwXkwQNpbu8XmlaLq64n26H1hASEyPGy0Da3UHLkgdyP4ey4PnbulbmgCwQHjDfwkobgEAta1saJbNvS(KO1dlfeJUd42nSuXyalfU(ovViAbiwQHjDfwkC9DQEr0cqSI1NnB9WsbXO7aUDdl1WKUcl1ch9h)QkvnyCBA3iDfwkgPfG0JLAysVeuqaMgWhY7HOXsfJbSulC0F8RQu1GXTPDJ0vyfRp(I1dlfeJUd42nSuXyalfFiVnvfkoWERE(cbWmiyGLAysxHLIpK3MQcfhyVvpFHaygemWkwFOL1dlfeJUd42nSuXyalfOxbU(o1YgdwQHjDfwkqVcC9DQLngSI1NvY6HLcIr3bC7gwQymGL6hm)thaxTWn8EKIGvy)d7TdWwQHjDfwQFW8pDaC1c3W7rkcwH9pS3oaBfRyPQfmU1dRp0y9WsnmPRWsPdemqE3XclfeJUd42nSI1NeTEyPgM0vyP0DvXvPFcDlfeJUd42nSI1NnB9WsnmPRWsL2eq3vf3sbXO7aUDdRy9XxSEyPgM0vyP(yq1cyWwkigDhWTByfRyfl1sGG7kS(K4ksKMvqBwbnwQ1dj6yb2s9I200w8Xx5dTTgEOd5HF4qT5PiYHslYHwf7Q1kH0XBqWREic4R)nb4hcxg4qZxkZia)qm)tSaW5BVg1bCiA0WdPbvSeicWpevB0GdHPhYS9qRSdj1H0O)CiEVSXDfhQEaYif5qANSwhs7e3Qv(2RrDahkrn8qAqflbIa8dr1gn4qy6HmBp0k7qsDin6phI3lBCxXHQhGmsroK2jR1H0oXTALV9AuhWH2SgEinOILara(HOAJgCim9qMThALDiPoKg9NdX7LnUR4q1dqgPihs7K16qAV5TALV93(x0MM2Ip(kFOT1WdDip8dhQnpfrouAro0QSAjetiQrVDTqF1draF9Vja)q4YahA(szgb4hI5FIfaoF71OoGdrJgEinOILara(HwfxFNEh88lx9qsDOvX13P3bp)YmeJUd4REiTPzRw5BVg1bCOe1WdPbvSeicWp0Q46707GNF5QhsQdTkU(o9o45xMHy0DaF1dPnnB1kF71OoGdTzn8qAqflbIa8dTkU(o9o45xU6HK6qRIRVtVdE(LzigDhWx9qJCOnLgNgDiTPzRw5BVg1bCiFrdpKguXsGia)qRIRVtVdE(LREiPo0Q46707GNFzgIr3b8vpK20SvR8TxJ6aoeT0WdPbvSeicWp0Q46707GNF5QhsQdTkU(o9o45xMHy0DaF1dPnnB1kF71OoGdTsA4H0Gkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6H0MMTALV9AuhWHOnA4H0Gkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6Hg5qBknon6qAtZwTY3(B)lAttBXhFLp02A4HoKh(Hd1MNIihkTihAvHozcrHb5)S6HiGV(3eGFiCzGdnFPmJa8dX8pXcaNV9AuhWH2SgEinOILara(HwL8diTilG8lx9qsDOvj)aslYci)YmeJUd4REiTPzRw5B)T)fTPPT4JVYhABn8qhYd)WHAZtrKdLwKdTkhsNVtw9qeWx)BcWpeUmWHMVuMra(Hy(NybGZ3EnQd4q0gn8qAqflbIa8dTkU(o9o45xU6HK6qRIRVtVdE(LzigDhWx9qAV5TALV9AuhWHEXA4H0Gkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6H0MMTALV9AuhWHOHgn8qAqflbIa8dTk5hqArwa5xU6HK6qRs(bKwKfq(LzigDhWx9qAtZwTY3EnQd4q0KOgEinOILara(HwL8diTilG8lx9qsDOvj)aslYci)YmeJUd4REOro0MsJtJoK20SvR8TxJ6aoenRKgEinOILara(HwL8diTilG8lx9qsDOvj)aslYci)YmeJUd4REiTPzRw5BVg1bCiAOnA4H0Gkwceb4hAvYpG0ISaYVC1dj1HwL8diTilG8lZqm6oGV6H0MMTALV9AuhWHOrJPHhsdQyjqeGFOvj)aslYci)YvpKuhAvYpG0ISaYVmdXO7a(QhsBA2Qv(2F7FrBAAl(4R8H2wdp0H8WpCO28ue5qPf5qRkKoEdcE1draF9Vja)q4YahA(szgb4hI5FIfaoF71OoGdrln8qAqflbIa8dTQq64nizAYVC1dj1HwviD8gKSqt(LREiTPzRw5BVg1bCOvsdpKguXsGia)qRkKoEdsoX8lx9qsDOvfshVbjljMF5QhsBA2Qv(2F79vMNIia)qV4dnmPR4qUgl48T3s9qQ02bwQx4qBcyQOC1c6h6fnexXEF7FHd5xKhSgMCYlAX)xpZktY428DJ0vWitQKmUnSKV9VWH2)D0pKV45HsCfjsZT)2)chsd8pXcaRH3(x4q((qupGZDinQyVZ3(x4q((qACHJ(HiaRmgi4hAtatf6Lto0db8nRm6JCOo9qTCOgFOoWYeYH0UihY)q4SblhkTihsVWyaRv(2)chY3hsJVwdKdr1p(R4qJZvRb(HEiGVzLrFKdj1HEif7qDGLjKdTjGPc9Yj5B)lCiFFin(LA8hsgheYH6qac5)i5B)lCiFFOn9YQ5hIAdFNaT1I2(q4NXCO1(H4q0R)Qe4qrjhA0RVCiPoe(BmvCO5qEqNmHKV93(x4qBQTa7la)q6qArGdXkJ(ihshw0boFOnnJbpc(qrf(2)qmPF3HgM0vGpufo65B)WKUcC(HaSYOpIMEtofCkEz6yKUcp7uVsBGewXoA)bK846LWTFysxbo)qawz0hrtVjJ)gtfQhqU9dt6kW5hcWkJ(iA6n5pguTagpJXaELYaQkvzQalK6JvSkWc5ZKUc8TFysxbo)qawz0hrtVj)XGQfW4zmgWlUCW4hRWaJaIsaM)O91F42pmPRaNFiaRm6JOP3KtDa2pJmPYTFysxbo)qawz0hrtVj)uRbIc3p(RWZo1R(pnnVUDCvBEWzSmS3jqZo9FAAMdMkAMIveiJLH9(vVjE7hM0vGZpeGvg9r00BYCWuHE5ep7uVARxyCsjnmPRiZbtf6LtYSblExHw7W13PW(hch)QVC7hM0vGZpeGvg9r00BYy)dVwR0lN4zN6L21wVW4KsAysxrMdMk0lNKzdw8UcTskjC9DkS)HWXjS5B)WKUcC(HaSYOpIMEtE5q6r3bEgJb8M2eSOe6KjeL0gWZ6XlgepxoUp4LMeV93(x4qBQTa7la)qWsGq)qsBGdj(HdnmPihQXhAwoTB0Dq(2pmPRa7f)aoNYvS33(HjDfyn9MmBCovk48)dbi3(HjDfyn9M8SfusHX3(HjDfyn9MmhwwFIYmlA2TFysxbwtVjZgNtnmPRq5AS4zmgWRq64ni4B)WKUcSMEtMxLXZo1lbsja2)O7GB)WKUcSMEtMnoNAysxHY1yXZymGxwTeIje1O3UwO7jwint8sJNDQxC9D6DWZli1sq1XYErrgPRiPKW13P3bpN2GJRQuLURW4YGtkjC9D6DWZSYOpIYa8wgPRiPKy1siMqYbWiLRi8B)WKUcSMEtMnoNAysxHY1yXZymGxHozcrHb5)C7hM0vG10BYpL0v4zN6vBwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)vAwXoPnqclhsp6oiN2eSOe6KjeL0gW30SIKscxFNEh8mbs7a4QNXncSJvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWFDZAmTU9dt6kWA6nz24CQHjDfkxJfpJXaERfmUNyH0mXlnE2PEFajZbtfntj0jti5Hj9s42pmPRaRP3K5GPIMPWcbIfIFp7uVAt7KFaPfzbKx3UucWXkCVODQkvH)paPlIc)nMk6yXowvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGjapHxSwjLK2pGK5GPIMPe6KjK8WKEjS7bKmhmv0mLqNmHKjGz6a)6kTYxW4zZSvRB)WKUcSMEtMnoNItGHJLX9giyp7uVSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpataEcjUcFtRvoTt(bKwKfqED7sjahRW9I2PQuf()aKUik83yQOJf3(HjDfyn9M8tTgikC)4Vcp7uV6)00862XvT5bNXYWENan70)PPzoyQOzkwrGmwg27x38TFysxbwtVjR3oaZQpzbO0lJoqWE2PE1)PPzHozcjZR1XowvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGjapbAD7hM0vG10BYT5Xv4Ucp7uVdt6LGccW0aobA0uBAw5Y4GqY4Hr60MbCfU(oCgIr3bCT2P)ttZRBhx1MhCgld7DcExPD6)00SqNmHK516yhRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGNaTU9dt6kWA6n5284kCxHNDQ3Hj9sqbbyAaNqI70)PP51TJRAZdoJLH9obVR0o9FAAwOtMqY8ADSJvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWtGw7ODYpG0ISaYT5Xv4EjOEkbcPh3oTPDzCqi5uszuIFqH9p8AnodXO7aEsjP)ttZPKYOe)Gc7F41AC()O1TFysxbwtVj3MhxH7k8St9omPxckiatd4esCN(pnnVUDCvBEWzSmS3j4DL2P)ttZT5Xv4EjOEkbcPhxMaMPd8RjUJ8diTilGCBECfUxcQNsGq6XTtBAxghesMdMkAMIvb(BEKUImeJUd4jLK26)00SqNmHK516yhRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGNaT0sRB)WKUcSMEtUnpUc3v4zN6v)NMMx3oUQnp4mwg27e8stI7KXbHKX13PyvW)TKHy0DaFNmoiKCkPmkXpOW(hETgNHy0DaFh5hqArwa5284kCVeupLaH0JBN(pnnl0jtizETo2XQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4jqRB)WKUcSMEtEbPnvtavk4w8hc3Zo1REHX7K2akPu8gEDZR42pmPRaRP3KXFJPc1Y2bPneCp7uV6fgVtAdOKsXB41e1y3(HjDfyn9Mm(BmvO4GPIMPe6Kjep7uV6fgVtAdOKsXB4vAO1TFysxbwtVj7FcUQsvl(o(eE2PEX13PW(hc3lTU9VWH8vPhAtiWWXY4Ede8HgcCOXrGHt)qdt6LGNhkQdfaWpKuhcplHdH9peo(2pmPRaRP3K9pbxvPQfFhFcp7uV467uy)dHNG3nVt7hqYCcmCSmU3ajpmPxcjL0dizoyQOzkHozcjpmPxcAD7hM0vG10BY(NGRQu1IVJpHNDQxC9DkS)HWtWln70)PP5ae)ar9uezC5)ZowvoEToYSX5uCcmCSmU3abNjGz6aNqIR8fmE2mBV9dt6kWA6nz)tWvvQAX3XNWZo1lU(of2)q4j4LMDSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Rly8Sz2UtAdKanj67fmE2mB3PT(pnnZjWWXY4EdeC()St)NMM5ey4yzCVbcotaZ0boHHjDfz)tWvvQAX3XNidBb2xaL0gqZHjDfz83yQqXbtfntj0jtizylW(cOK2aATtBAxghesg)nMkulBhK2qWZqm6oGNus6)008Y2bPne88)rRB)WKUcSMEtMnoNAysxHY1yXZymGxwTeIje1O3UwO7jwint8sJNDQxANvlHycjVecXpDYT)fo0lQf)1xoe1WiDAZa(HOQVd75HOQV7qucPFdhQXhclKkwaKdj(N4qBcyQqVCINhcxhQLd5FWhAoK)EHFGCOhsxKwOF7hM0vG10BY467uyH0Vbp7uV0UmoiKmEyKoTzaxHRVdNHy0Da)2)chI6bc(H2eWurZoKgueaFO0ICiQ67oeL)HWXh6hs7oKh0jtihIvLJxRJd14dXCfgoKuhIadN(TFysxbwtVjZbtf6Lt8St9Q)ttZCWurZuSIazcmmzhU(of2)q4V6l7yv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8esCf3(x4qBYN0XId5bDYeYHWG8F88q4hi4hAtatfn7qAqra8HslYHOQV7qu(hchF7hM0vG10BYCWuHE5ep7uV6)00mhmv0mfRiqMadt2HRVtH9pe(R(YowvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)vAs82pmPRaRP3K5GPc9YjE2PE1)PPzoyQOzkwrGmbgMSdxFNc7Fi8x9LDAR)ttZCWurZuSIazSmS3jKysjjJdcjJhgPtBgWv467WzigDhW162pmPRaRP3K5GPc9YjE2PE1)PPzoyQOzkwrGmbgMSdxFNc7Fi8x9LDdt6LGccW0aobAU9dt6kWA6nzC9DkSq63WTFysxbwtVjZgNtnmPRq5AS4zmgWlRwcXeIA0Bxl0V9VWH8vPhIE9peBIdTaKdPpS3hsQdrRdrvF3HO8peo(q6qArGdTjey4yzCVbc(qSQC8ADCOgFicmC6EEOwwfFO69q)qsDi8de8dj(bZHIA9TFysxbwtVj7FcUQsvl(o(eE2PEX13PW(hcpbVBEhRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeGNqI0AN2Y4GqYCWurZuSX56yrgIr3b8KsIvLJxRJmBCofNadhlJ7nqWzcyMoWjOT20Y3467uy)dHR1kFysxrg7F41ALE5KmSfyFbusBaT0Cysxr2)eCvLQw8D8jYWwG9fqjTb062pmPRaRP3K5vz8KrN5aLmKfGG9sJNDQxcKsaS)r3b7K2ajSCi9O7GCAtWIsOtMqusBGB)WKUcSMEtg7F41ALE5KB)TFysxboJD1ALq64niyVFmOAbmEgJb8IRVZbI0Xcf5Rt3Zo1lRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeG)QmKfGK5nwMGbRmATtAdKWYH0JUdYPnblkHozcrjTb8T2YqwasM3yzcgSYOLw3(HjDf4m2vRvcPJ3GG10BYFmOAbmEgJb8I)HURkUAmG4Now8St9YQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4VkdzbizEJLjyWkJw7K2ajSCi9O7GCAtWIsOtMqusBaFRTmKfGK5nwMGbRmAP1T)foKghHhtWGd5FWhAoenjEimWQGFio4g6hAc(HA8He)abslcCi87(5b4hkTihkTjy5qEqNmHCiPoKRd4q)NdTUf)hs8dhIay52pmPRaNXUATsiD8geSMEt(JbvlGXZymGxW8qNaJtveEmbd8St9YQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4VQTmKfGK5nwMGbRmAPLM0K4owvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGjapbT1wBzilajZBSmbdwz0slnPjrT8nn0sRDsBGewoKE0DqoTjyrj0jtikPnGV1wBzilajZBSmbdwz0slnPjrTU93(HjDf4mRwcXeIA0Bxl09IRVtrkXZo1lU(o9o45fKAjO6yzVOiJ0vStBwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)1exrsjXQYXR1rg)nMkuCWurZucDYesMaMPdSc2(amb4jS5vO1TFysxboZQLqmHOg921cDn9MmU(ofPep7uV46707GNtBWXvvQs3vyCzW7EajZbtfntj0jti5Hj9s42pmPRaNz1siMquJE7AHUMEtgxFNIuINDQxC9D6DWZRBhx5)hIsgM0m8TFysxboZQLqmHOg921cDn9MmhyTzKowO0lN4zN6fxFNEh8SdgUsNUc2oMhhSt7hqYCWurZucDYesEysVe2HRVtH9pe(RjMusSQC8ADKXFJPcfhmv0mLqNmHKjGz6aRGTpataEc(Yk062pmPRaNz1siMquJE7AHUMEtMdS2mshlu6Lt8St9s746707GNDWWv60vW2X84GD0(dizoyQOzkHozcjpmPxc3(HjDf4mRwcXeIA0Bxl010BYyw9jDSqjT4h8St9IRVtVdEMvg9rugG3YiDf7EajZbtfntj0jti5Hj9s42pmPRaNz1siMquJE7AHUMEtgZQpPJfkPf)GNDQxAhxFNEh8mRm6JOmaVLr6kU9dt6kWzwTeIje1O3UwORP3KBZde8owOyJmyHup(bp7uVpGK5GPIMPe6KjK8WKEjSdxFNc7FiCVR42F7hM0vGZ(FucPJ3yVFmOAbmEgJb8I7i97ulCdVhPiyfy0DG52pmPRaN9)OeshVXA6n5pguTagpJXaEXDK(DQb)0KjeScm6oWC7V9dt6kW5AbJ7vhiyG8UJf3(HjDf4CTGX10BY6UQ4Q0pH(TFysxboxlyCn9MCAtaDxv8B)WKUcCUwW4A6n5pguTag8T)2pmPRaNF(eqXhZSaucPJ3yVFmOAbmEgJb8YjWWtBcOwcym4U9dt6kW5Npbu8XmlaLq64nwtVj)XGQfW4zmgWlU(ovViAbi3(HjDf48ZNak(yMfGsiD8gRP3K)yq1cy8mgd4DHJ(JFvLQgmUnTBKUcp7uVdt6LGccW0a2ln3(HjDf48ZNak(yMfGsiD8gRP3K)yq1cy8mgd4LpK3MQcfhyVvpFHaygem42pmPRaNF(eqXhZSaucPJ3yn9M8hdQwaJNXyaVGEf467ulBmC7hM0vGZpFcO4JzwakH0XBSMEt(JbvlGXZymG3FW8pDaC1c3W7rkcwH9pS3oaF7V9dt6kWzH0XBqWE)yq1cy8mgd4f7F41AGRkIUQsvsrmqiE2PEzv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8xPHw3(HjDf4Sq64niyn9MmBCo1WKUcLRXINXyaV(FucPJ3yp7uVY4GqYCWurZuSkWFZJ0vKHy0DaFhRkhVwhz83yQqXbtfntj0jtizcyMoWky7dWeG)AIR42)chAtLMcmbFiX)ihsiZsWDiSRw7OFiPoKmKfGCic4R)nbo0W5T0vmoppegEgYiWH8pb31XIB)WKUcCwiD8geSMEtMnoNAysxHY1yXZymGxSRwReshVbbF7hM0vGZcPJ3GG10BYFmOAbmEgJb8wlbsQRw3Xc1eTzuSzb4zN69bKmhmv0mLqNmHKhM0lHB)WKUcCwiD8geSMEtwiD8geA8St9kKoEdsMMS)bR(yqP)tt39asMdMkAMsOtMqYdt6LWTFysxbolKoEdcwtVjlKoEdsIE2PEfshVbjNy2)GvFmO0)PP7EajZbtfntj0jti5Hj9s42pmPRaNfshVbbRP3KzJZPgM0vOCnw8mgd495tafFmZcqjKoEJ9St9kTbsy5q6r3b50MGfLqNmHOK2a7yv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8esCf3(B)WKUcCwOtMquyq(pEdq8de1trKX5zN6LvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWFLgAD7hM0vGZcDYeIcdY)rtVjVG0MQjGkfCl(dH7zN6LvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWFLgAJV1Eysxrg)nMkuCWurZucDYesg2cSVakPnGMdt6kYy)dVwR0lNKHTa7lGsAdO1oTzv5416iZgNtXjWWXY4EdeCMaMPd8R0qB8T2dt6kY4VXuHIdMkAMsOtMqYWwG9fqjTb0Cysxrg)nMkulBhK2qWZWwG9fqjTb0Cysxrg7F41ALE5KmSfyFbusBaTskPhqYCcmCSmU3ajtaZ0bobwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaxZHjDfz83yQqXbtfntj0jtizylW(cOK2aAD7hM0vGZcDYeIcdY)rtVjJ)gtfQLTdsBi4E2PE1MvLJxRJm(BmvO4GPIMPe6KjKmbmthyfS9bycWFLgA5BThM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdO1oTzv5416iZgNtXjWWXY4EdeCMaMPd8R0qlFR9WKUIm(BmvO4GPIMPe6KjKmSfyFbusBanhM0vKXFJPc1Y2bPne8mSfyFbusBaTskPhqYCcmCSmU3ajtaZ0bobwvoEToY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaxZHjDfz83yQqXbtfntj0jtizylW(cOK2aAPvsjPnTt(bKwKfqED7sjahRW9I2PQuf()aKUik83yQOJf7yv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8e8LvO1TFysxbol0jtikmi)hn9MmBCofNadhlJ7nqWE2PEzv5416iJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8xPjrFR9WKUIm(BmvO4GPIMPe6KjKmSfyFbusBanhM0vKX(hETwPxojdBb2xaL0gqRDsBGewoKE0DqoTjyrj0jtikPnGVPjrFpmPRiZgNtXjWWXY4EdeCg2cSVakPnGMdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTb0Cysxrg7F41ALE5KmSfyFbusBGB)WKUcCwOtMquyq(pA6nz83yQqXbtfntj0jtiE2PEL2ajSCi9O7GCAtWIsOtMqusBGDA)asMtGHJLX9gi5Hj9sy3dizobgowg3BGKjGz6aNWWKUIm(BmvO4GPIMPe6KjKmSfyFbusBaT2PnTlJdcjJ)gtfQLTdsBi4zigDhWtkPhqYlBhK2qWZdt6LGw70gxFNc7FiCVRiPK0(bKmNadhlJ7nqYdt6LWUhqYCcmCSmU3ajtaZ0b(1HjDfz83yQqXbtfntj0jtizylW(cOK2aAomPRiJ9p8ATsVCsg2cSVakPnGwjLK2pGKx2oiTHGNhM0lHDpGKx2oiTHGNjGz6a)6WKUIm(BmvO4GPIMPe6KjKmSfyFbusBanhM0vKX(hETwPxojdBb2xaL0gqRKssB9FAAEbPnvtavk4w8hcp)F2P)ttZliTPAcOsb3I)q4zcyMoWVomPRiJ)gtfkoyQOzkHozcjdBb2xaL0gqZHjDfzS)HxRv6LtYWwG9fqjTb0sll18f)fXszfRyTa]] )


end
