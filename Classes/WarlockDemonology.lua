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


    spec:RegisterPack( "Demonology", 20210701, [[dKuVIbqiKs6rQsWLusLSjLsFsjPrrk6uKswLsQWROkmlQIULiu7su)se1WeHCmvPwgvLEMsIMgPqDnsbBtjH(gsjmoLuPoNQeQ1HuQMNQKUhvP9jcoOsQQwOskpePuMOsQYfvLq(OscyKiLiDsLe0kvQmtsHStQk(jsjQHQKaTuKsepfjtLuQVQKQYyvLO9sP)sYGHCyflMu9yuMmQUmyZI0NvcJMQQtl1RrkMnvUnf7w43sgUQ44kPIwoINd10jUUQA7krFxPy8kvDEKQ5lISFv2(2QTLIpcy9X3e577erls07SVR033RuJTuc9hWs9mmAMfGLkgdyPwpWur5Qf0TupdDxnCR2wkC9jmWsr1gAZsP)BNScdRULIpcy9X3e577erls07SVR03eTsAHLc)amRp(UIROLYFZ5qy1TuCaZSuRhyQOC1c6hA9nexXO525xKhmTNCYlAX)xpZktY428DJ0vWitQKmUnSKVD7(o6h6TNhY3e577B3TJ28pXcat73UeFiQhW5oKgvmAY3UeFiA5Wr)qeGvgde8dTEGPc9Yjh6HajMvg9rouNEOwouJpuhyzc5qAwKd5FiC2GLdLwKdPxymG1kF7s8HwbRna5qu9J)ko04C1gGFOhcKywz0h5qsDOhsXouhyzc5qRhyQqVCs(2L4dTcUCf8qY4Gqouhcqi)hjF7s8Hw)lRMFiQ1sCc0sRvGdHFgZH24hIdrV(RsGdfLCOrV(YHK6q4VXuXHMdPnDYes2s5ASGTABPWUAJsiDqdiyR2wFEB12sbXO7aUDnl1WKUclfU(ohishluKVoDlfJ0cq6XsXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4h61djdzbizEJLjyWHs(qA4qBpK0g4qjCOLdPhDhKtBcwucDYeIsAdCOeFinpKmKfGK5nwMGbhk5dPHdPLLkgdyPW135ar6yHI81PBfRp(A12sbXO7aUDnl1WKUclf(h6UQ4QXaIF6yXsXiTaKESuSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(HE9qYqwasM3yzcgCOKpKgo02djTbouchA5q6r3b50MGfLqNmHOK2ahkXhsZdjdzbizEJLjyWHs(qA4qAzPIXawk8p0DvXvJbe)0XIvS(SsR2wkigDhWTRzP4aMr6hPRWsrlt4Xem4q(h8HMd923dHbwf8dXb3q)qtWpuJpK4hiqArGdHPPFEa(HslYHsBcwoK20jtihsQd56ao0)5qBAX)He)WHiawSuXyalfyEOtGXPkcpMGbwkgPfG0JLIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWp0RhsZdjdzbizEJLjyWHs(qA4qADipo0BFp02dXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4hkHdP5H08qAEizilajZBSmbdouYhsdhsRd5XHE77H06qj(qV1WH06qBpK0g4qjCOLdPhDhKtBcwucDYeIsAdCOeFinpKMhsgYcqY8gltWGdL8H0WH06qECO3(EiTSudt6kSuG5HobgNQi8ycgyfRyP8)Oesh0GTAB95TvBlfeJUd421SuXyalfUJ0VtTWn8EKIGvGr3bgl1WKUclfUJ0VtTWn8EKIGvGr3bgRy9XxR2wkigDhWTRzPIXawkChPFNAWpnzcbRaJUdmwQHjDfwkChPFNAWpnzcbRaJUdmwXkwkwTeIje1O3UwOB126ZBR2wkigDhWTRzPyKwaspwkC9D6DWZli1sq1XYErrgPRidXO7a(H2EinpeRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeGFOxpKVj6qjL0Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8dLWHwzIoKwwQHjDfwkC9DksjwX6JVwTTuqm6oGBxZsXiTaKESu46707GNtBWXvvQs3vyCzWzigDhWp02d9asMdMkAMsOtMqYdt6LGLAysxHLcxFNIuIvS(SsR2wkigDhWTRzPyKwaspwkC9D6DWZBAhx5)hIsgM0mCgIr3bCl1WKUclfU(ofPeRy9rJTABPGy0Da3UMLIrAbi9yPW13P3bp7GHR0PRG9J5XbzigDhWp02dP5HEajZbtfntj0jti5Hj9s4qBpeU(of2)q4h61d57HskPdXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4hkHdPXj6qAzPgM0vyP4aRnJ0XcLE5eRy9rdwTTuqm6oGBxZsXiTaKESu06HW13P3bp7GHR0PRG9J5XbzigDhWp02drRh6bKmhmv0mLqNmHKhM0lbl1WKUclfhyTzKowO0lNyfRpROvBlfeJUd421SumslaPhlfU(o9o4zwz0hrzaElJ0vKHy0Da)qBp0dizoyQOzkHozcjpmPxcwQHjDfwkmR(KowOKw8dwX6dTWQTLcIr3bC7AwkgPfG0JLIwpeU(o9o4zwz0hrzaElJ0vKHy0Da3snmPRWsHz1N0XcL0IFWkwFw3wTTuqm6oGBxZsXiTaKESupGK5GPIMPe6KjK8WKEjCOThcxFNc7Fi8d59qjYsnmPRWs1Mhi4DSqXgzWcPE8dwXkwkHozcrHb5)y126ZBR2wkigDhWTRzPyKwaspwkwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qVEO3AWsnmPRWsfG4hiQNIiJZkwF81QTLcIr3bC7AwkgPfG0JLIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWp0Rh6nT4qj(qAEOHjDfz83yQqXbtfntj0jtizypW(cOK2ahYJdnmPRiJ9p8AJsVCsg2dSVakPnWH06qBpKMhIvLJxBImBCofNadhlJJgGGZeWmDGp0Rh6nT4qj(qAEOHjDfz83yQqXbtfntj0jtizypW(cOK2ahYJdnmPRiJ)gtfQLTdsBi4zypW(cOK2ahYJdnmPRiJ9p8AJsVCsg2dSVakPnWH06qjL0HEajZjWWXY4ObizcyMoWhkHdXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4hYJdnmPRiJ)gtfkoyQOzkHozcjd7b2xaL0g4qAzPgM0vyPwqAt1eqLcUf)HWTI1NvA12sbXO7aUDnlfJ0cq6XsP5Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8d96HERHdL4dP5HgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdCiTo02dP5Hyv541MiZgNtXjWWXY4Obi4mbmth4d96HERHdL4dP5HgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdCipo0WKUIm(BmvOw2oiTHGNH9a7lGsAdCiTousjDOhqYCcmCSmoAasMaMPd8Hs4qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(H84qdt6kY4VXuHIdMkAMsOtMqYWEG9fqjTboKwhsRdLushsZdrRhI8diTilG8M2LsaowH7fTtvPk8)biDru4VXurhlYqm6oGFOThIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWpuchsJt0H0YsnmPRWsH)gtfQLTdsBi4wX6JgB12sbXO7aUDnlfJ0cq6XsXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4h61d923dL4dP5HgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdCipo0WKUIm2)WRnk9YjzypW(cOK2ahsRdT9qsBGdLWHwoKE0DqoTjyrj0jtikPnWHs8HE7RLAysxHLInoNItGHJLXrdqWwX6JgSABPGy0Da3UMLIrAbi9yPK2ahkHdTCi9O7GCAtWIsOtMqusBGdT9qAEOhqYCcmCSmoAasEysVeo02d9asMtGHJLXrdqYeWmDGpuchAysxrg)nMkuCWurZucDYesg2dSVakPnWH06qBpKMhIwpKmoiKm(BmvOw2oiTHGNHy0Da)qjL0HEajVSDqAdbppmPxchsRdT9qAEiC9DkS)HWpK3dLOdLushsZd9asMtGHJLXrdqYdt6LWH2EOhqYCcmCSmoAasMaMPd8HE9qdt6kY4VXuHIdMkAMsOtMqYWEG9fqjTboKhhAysxrg7F41gLE5KmShyFbusBGdP1HskPdP5HEajVSDqAdbppmPxchA7HEajVSDqAdbptaZ0b(qVEOHjDfz83yQqXbtfntj0jtizypW(cOK2ahYJdnmPRiJ9p8AJsVCsg2dSVakPnWH06qjL0H08q6)008csBQMaQuWT4peE()COThs)NMMxqAt1eqLcUf)HWZeWmDGp0RhAysxrg)nMkuCWurZucDYesg2dSVakPnWH84qdt6kYy)dV2O0lNKH9a7lGsAdCiToKwwQHjDfwk83yQqXbtfntj0jtiwXkwkoKoFNy126ZBR2wkigDhWTRzP4aMr6hPRWs9I2dSVa8dblbc9djTboK4ho0WKICOgFOz50Ur3bzl1WKUclf(bCoLRy0yfRp(A12snmPRWsXgNtLco))qaILcIr3bC7AwX6ZkTABPgM0vyPM9Gskm2sbXO7aUDnRy9rJTABPgM0vyP4WY6tuMzrZSuqm6oGBxZkwF0GvBlfeJUd421Sudt6kSuSX5udt6kuUglwkxJfvmgWsjKoObeSvS(SIwTTuqm6oGBxZsXiTaKESueiLay)JUdSudt6kSu8QmwX6dTWQTLcIr3bC7AwkgPfG0JLcxFNEh88csTeuDSSxuKr6kYqm6oGFOKs6q46707GNtBWXvvQs3vyCzWzigDhWpusjDiC9D6DWZSYOpIYa8wgPRidXO7a(HskPdXQLqmHKdGrkxr4wkSqAMy95TLAysxHLInoNAysxHY1yXs5ASOIXawkwTeIje1O3UwOBfRpRBR2wkigDhWTRzPgM0vyPyJZPgM0vOCnwSuUglQymGLsOtMquyq(pwX6Zl2QTLcIr3bC7AwkgPfG0JLsZdXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4h61d9orhA7HK2ahkHdTCi9O7GCAtWIsOtMqusBGdL4d9orhkPKoeU(o9o4zcK2bWvpJBeidXO7a(H2EiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qVEOvUUpKwwQHjDfwQNs6kSI1N3jYQTLcIr3bC7AwkgPfG0JL6bKmhmv0mLqNmHKhM0lblfwintS(82snmPRWsXgNtnmPRq5ASyPCnwuXyalvTGXTI1N3VTABPGy0Da3UMLIrAbi9yP08q06Hi)aslYciVPDPeGJv4Er7uvQc)Fasxef(Bmv0XImeJUd4hA7Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8dLWHEXhsRdLushsZd9asMdMkAMsOtMqYdt6LWH2EOhqYCWurZucDYesMaMPd8HE9qR4HwhhAbJNnZ(dPLLAysxHLIdMkAMcleiwi(TI1N3(A12sbXO7aUDnlfJ0cq6XsXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4hkHd5BIouIpKgo064q06Hi)aslYciVPDPeGJv4Er7uvQc)Fasxef(Bmv0XImeJUd4wQHjDfwk24CkobgowghnabBfRpVxPvBlfeJUd421SumslaPhlL(pnnVPDCvBEWzSmmAouch69H2Ei9FAAMdMkAMIveiJLHrZHE9qR0snmPRWs9uBaIc3p(RWkwFERXwTTuqm6oGBxZsXiTaKESu6)00SqNmHK51M4qBpeRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeGFOeoKgSudt6kSu6TdWS6twak9YOdeSvS(8wdwTTuqm6oGBxZsXiTaKESudt6LGccW0a(qjCO3hYJdP5HEFO1XHKXbHKXdJ0Pnd4kC9D4meJUd4hsRdT9q6)008M2XvT5bNXYWO5qj49qR4H2Ei9FAAwOtMqY8AtCOThIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWpuchsdwQHjDfwQ284kCxHvS(8EfTABPGy0Da3UMLIrAbi9yPgM0lbfeGPb8Hs4q(EOThs)NMM30oUQnp4mwggnhkbVhAfp02dP)ttZcDYesMxBIdT9qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(Hs4qA4qBpeTEiYpG0ISaYT5Xv4EjOEkbcPhxgIr3b8dT9qAEiA9qY4GqYPKYOe)Gc7F41gCgIr3b8dLushs)NMMtjLrj(bf2)WRn48)5qAzPgM0vyPAZJRWDfwX6ZBAHvBlfeJUd421SumslaPhl1WKEjOGamnGpuchY3dT9q6)008M2XvT5bNXYWO5qj49qR4H2Ei9FAAUnpUc3lb1tjqi94YeWmDGp0RhY3dT9qKFaPfzbKBZJRW9sq9ucespUmeJUd4hA7H08q06HKXbHK5GPIMPyvG)MhPRidXO7a(HskPdP5H0)PPzHozcjZRnXH2EiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qjCinCiToKwwQHjDfwQ284kCxHvS(8EDB12sbXO7aUDnlfJ0cq6XsP)ttZBAhx1MhCgldJMdLG3d923dT9qY4GqY467uSk4)wYqm6oGFOThsghesoLugL4huy)dV2GZqm6oGFOThI8diTilGCBECfUxcQNsGq6XLHy0Da)qBpK(pnnl0jtizETjo02dXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4hkHdPbl1WKUclvBECfURWkwFE)ITABPGy0Da3UMLIrAbi9yP0lm(qBpK0gqjLI3WHE9qRmrwQHjDfwQfK2unbuPGBXFiCRy9X3ez12sbXO7aUDnlfJ0cq6XsPxy8H2EiPnGskfVHd96H8DDBPgM0vyPWFJPc1Y2bPneCRy9X33wTTuqm6oGBxZsXiTaKESu6fgFOThsAdOKsXB4qVEO3AWsnmPRWsH)gtfkoyQOzkHozcXkwF81xR2wkigDhWTRzPyKwaspwkC9DkS)HWpK3dPbl1WKUclL)j4QkvT474tyfRp(UsR2wkigDhWTRzPgM0vyP8pbxvPQfFhFclfhWms)iDfwQvy6HwpcmCSmoAac(qdbo04iWWPFOHj9sWZdf1Hca4hsQdHNLWHW(hchBPyKwaspwkC9DkS)HWpucEp0kp02dP5HEajZjWWXY4Obi5Hj9s4qjL0HEajZbtfntj0jti5Hj9s4qAzfRp(QXwTTuqm6oGBxZsXiTaKESu467uy)dHFOe8EO3hA7H0)PP5ae)ar9uezC5)ZH2EiwvoETjYSX5uCcmCSmoAacotaZ0b(qjCiFp064qly8Sz2BPgM0vyP8pbxvPQfFhFcRy9Xxny12sbXO7aUDnlfJ0cq6XsHRVtH9pe(HsW7HEFOThIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWp0RhAbJNnZ(dT9qsBGdLWHE77Hs8HwW4zZS)qBpKMhs)NMM5ey4yzC0aeC()COThs)NMM5ey4yzC0aeCMaMPd8Hs4qdt6kY(NGRQu1IVJprg2dSVakPnWH84qdt6kY4VXuHIdMkAMsOtMqYWEG9fqjTboKwhA7H08q06HKXbHKXFJPc1Y2bPne8meJUd4hkPKoK(pnnVSDqAdbp)FoKwwQHjDfwk)tWvvQAX3XNWkwF8DfTABPGy0Da3UMLIrAbi9yPO1dXQLqmHKxcH4NoXsHfsZeRpVTudt6kSuSX5udt6kuUglwkxJfvmgWsXQLqmHOg921cDRy9XxAHvBlfeJUd421Sudt6kSu467uyH00awkoGzK(r6kSuRVw8xF5qudJ0Pnd4hIQ(oSNhIQ(UdrjKMg4qn(qyHuXcGCiX)ehA9atf6Lt88q46qTCi)d(qZH83l8dKd9q6I0cDlfJ0cq6XsrRhsghesgpmsN2mGRW13HZqm6oGBfRp(UUTABPGy0Da3UMLAysxHLIdMk0lNyP4aMr6hPRWsr9ab)qRhyQOzhI2kcGpuAroev9DhIY)q44d9dPDhsB6KjKdXQYXRnXHA8HyUcdhsQdrGHt3sXiTaKESu6)00mhmv0mfRiqMadto02dHRVtH9pe(HE9qA8H2EiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qjCiFtKvS(47l2QTLcIr3bC7AwQHjDfwkoyQqVCILIdygPFKUcl169jDS4qAtNmHCimi)hppe(bc(HwpWurZoeTveaFO0ICiQ67oeL)HWXwkgPfG0JLs)NMM5GPIMPyfbYeyyYH2EiC9DkS)HWp0RhsJp02dXQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4h61d92xRy9zLjYQTLcIr3bC7AwkgPfG0JLs)NMM5GPIMPyfbYeyyYH2EiC9DkS)HWp0RhsJp02dP5H0)PPzoyQOzkwrGmwggnhkHd57HskPdjJdcjJhgPtBgWv467WzigDhWpKwwQHjDfwkoyQqVCIvS(SY3wTTuqm6oGBxZsXiTaKESu6)00mhmv0mfRiqMadto02dHRVtH9pe(HE9qA8H2EOHj9sqbbyAaFOeo0Bl1WKUclfhmvOxoXkwFwPVwTTudt6kSu467uyH00awkigDhWTRzfRpRCLwTTuqm6oGBxZsnmPRWsXgNtnmPRq5ASyPCnwuXyalfRwcXeIA0Bxl0TI1NvQXwTTuqm6oGBxZsnmPRWs5FcUQsvl(o(ewkoGzK(r6kSuRW0drV(hInXHwaYH0hgnhsQdPHdrvF3HO8peo(q6qArGdTEey4yzC0ae8Hyv541M4qn(qey4098qTSk(qfnd9dj1HWpqWpK4hmhkQnwkgPfG0JLcxFNc7Fi8dLG3dTYdT9qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(Hs4q(QHdT9qAEizCqizoyQOzk24CDSidXO7a(HskPdXQYXRnrMnoNItGHJLXrdqWzcyMoWhkHdP5H08qA4qj(q467uy)dHFiTo064qdt6kYy)dV2O0lNKH9a7lGsAdCiToKhhAysxr2)eCvLQw8D8jYWEG9fqjTboKwwX6Zk1GvBlfeJUd421Sudt6kSu8QmwkgPfG0JLIaPea7F0DWH2EiPnWHs4qlhsp6oiN2eSOe6KjeL0gWsXOZCGsgYcqWwFEBfRpRCfTABPgM0vyPW(hETrPxoXsbXO7aUDnRyfl1dbyLrFeR2wFEB12sbXO7aUDnl1WKUclvk4u8Y0XiDfwkoGzK(r6kSuVO9a7la)q6qArGdXkJ(ihshw0boFO1pJbpc(qrfj2)qmPF3HgM0vGpufo6zlfJ0cq6XsjTbouchkrhA7HO1d9asEC9sWkwF81QTLAysxHLc)nMkuPGBXFiClfeJUd421SI1NvA12sbXO7aUDnlvmgWsjLbuvQYubwi1hRyvGfYNjDfyl1WKUclLugqvPktfyHuFSIvbwiFM0vGTI1hn2QTLcIr3bC7AwQymGLcxoy8JvyGrarjaZF0RZpyPgM0vyPWLdg)yfgyequcW8h968dwX6JgSABPgM0vyPsDa2pJmPILcIr3bC7AwX6ZkA12sbXO7aUDnlfJ0cq6XsP)ttZBAhx1MhCgldJMdLWHEFOThs)NMM5GPIMPyfbYyzy0COx9EiFTudt6kSup1gGOW9J)kSI1hAHvBlfeJUd421SumslaPhlLMhsVW4dLushAysxrMdMk0lNKzdwoK3dLOdP1H2EiC9DkS)HWXh61dPXwQHjDfwkoyQqVCIvS(SUTABPGy0Da3UMLIrAbi9yPO1dP5H0lm(qjL0HgM0vK5GPc9Yjz2GLd59qj6qADOKs6q467uy)dHJpuchALwQHjDfwkS)HxBu6LtSI1NxSvBlfeJUd421Su1JLcdILAysxHLA5q6r3bwQLJ7dwQ3(APwoevmgWsL2eSOe6KjeL0gWkwXsjKoObeSvBRpVTABPGy0Da3UMLAysxHLc7F41gGRkIUQsvsrmqiwkgPfG0JLIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWp0Rh6TgSuXyalf2)WRnaxveDvLQKIyGqSI1hFTABPGy0Da3UMLIrAbi9yPKXbHK5GPIMPyvG)MhPRidXO7a(H2EiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qVEiFtKLAysxHLInoNAysxHY1yXs5ASOIXawk)pkH0bnyRy9zLwTTuqm6oGBxZsXbmJ0psxHL6fLMcmbFiX)ihsiZsWDiSR24OFiPoKmKfGCicSo)nbo0W5T0vmoppegEgYiWH8pb31Xcl1WKUclfBCo1WKUcLRXILY1yrfJbSuyxTrjKoObeSvS(OXwTTuqm6oGBxZsnmPRWsvlbsQR20Xc1eTzuSzbyPyKwaspwQhqYCWurZucDYesEysVeSuXyalvTeiPUAthlut0MrXMfGvS(ObR2wkigDhWTRzPyKwaspwkH0bnGKL3z)dw9XGs)NMEOTh6bKmhmv0mLqNmHKhM0lbl1WKUclLq6GgqEBfRpROvBlfeJUd421SumslaPhlLq6GgqYIVz)dw9XGs)NMEOTh6bKmhmv0mLqNmHKhM0lbl1WKUclLq6Ggq81kwFOfwTTuqm6oGBxZsXiTaKESusBGdLWHwoKE0DqoTjyrj0jtikPnWH2EiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)qjCiFtKLAysxHLInoNAysxHY1yXs5ASOIXawQNpbu8XmlaLq6GgSvSIL65tafFmZcqjKoObB126ZBR2wkigDhWTRzPIXawkobgEAta1saJbNLAysxHLItGHN2eqTeWyWzfRp(A12sbXO7aUDnlvmgWsHRVt1lIwaILAysxHLcxFNQxeTaeRy9zLwTTuqm6oGBxZsnmPRWsTWr)XVQsvdg3M2nsxHLIrAbi9yPgM0lbfeGPb8H8EO3wQymGLAHJ(JFvLQgmUnTBKUcRy9rJTABPGy0Da3UMLkgdyP4dHgtvHIdmAupFHaygemWsnmPRWsXhcnMQcfhy0OE(cbWmiyGvS(ObR2wkigDhWTRzPIXawkqVcC9DQLngSudt6kSuGEf467ulBmyfRpROvBlfeJUd421SuXyal1py(NoaUAHB49ifbRW(hgnoaBPgM0vyP(bZ)0bWvlCdVhPiyf2)WOXbyRyflvTGXTAB95TvBl1WKUclLoqWaHMowyPGy0Da3UMvS(4RvBl1WKUclLURkUk9tOBPGy0Da3UMvS(SsR2wQHjDfwQ0Ma6UQ4wkigDhWTRzfRpASvBl1WKUcl1hdQwad2sbXO7aUDnRyfRyPwceCxH1hFtKVVteTirVTuBgs0XcSLA9T(PL4Zk0NvaA)qhsB)WHAZtrKdLwKdTk2vBucPdAabV6HiW683eGFiCzGdnFPmJa8dX8pXcaNVDAuhWHEt7hI2QyjqeGFiQ2qBhctpKz)HwxhsQdPr)5q8EzJ7kou9aKrkYH0mzToKM(UxR8TtJ6aoKV0(HOTkwceb4hIQn02HW0dz2FO11HK6qA0FoeVx24UIdvpazKICintwRdPPV71kF70OoGdTsA)q0wflbIa8dr1gA7qy6Hm7p066qsDin6phI3lBCxXHQhGmsroKMjR1H0CL71kF7UDRV1pTeFwH(Scq7h6qA7houBEkICO0ICOvz1siMquJE7AH(QhIaRZFta(HWLbo08LYmcWpeZ)elaC(2PrDah6nTFiARILara(HwfxFNEh88lx9qsDOvX13P3bp)YmeJUd4REinFVxR8TtJ6aoKV0(HOTkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6H089ETY3onQd4qRK2peTvXsGia)qRIRVtVdE(LREiPo0Q46707GNFzgIr3b8vp0ih6frlRrhsZ371kF70OoGdPX0(HOTkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6H089ETY3onQd4qAG2peTvXsGia)qRIRVtVdE(LREiPo0Q46707GNFzgIr3b8vpKMV3Rv(2PrDahAfP9drBvSeicWp0Q46707GNF5QhsQdTkU(o9o45xMHy0DaF1dP579ALVDAuhWHOf0(HOTkwceb4hAvC9D6DWZVC1dj1HwfxFNEh88lZqm6oGV6Hg5qViAzn6qA(EVw5B3TB9T(PL4Zk0NvaA)qhsB)WHAZtrKdLwKdTQqNmHOWG8Fw9qeyD(BcWpeUmWHMVuMra(Hy(NybGZ3onQd4qRK2peTvXsGia)qRs(bKwKfq(LREiPo0QKFaPfzbKFzgIr3b8vpKMV3Rv(2D7wFRFAj(Sc9zfG2p0H02pCO28ue5qPf5qRYH057KvpebwN)Ma8dHldCO5lLzeGFiM)jwa48TtJ6aoeTG2peTvXsGia)qRIRVtVdE(LREiPo0Q46707GNFzgIr3b8vpKMRCVw5BNg1bCOxmTFiARILara(HwfxFNEh88lx9qsDOvX13P3bp)YmeJUd4REinFVxR8TtJ6ao0730(HOTkwceb4hAvYpG0ISaYVC1dj1HwL8diTilG8lZqm6oGV6H089ETY3onQd4qV9L2peTvXsGia)qRs(bKwKfq(LREiPo0QKFaPfzbKFzgIr3b8vp0ih6frlRrhsZ371kF70OoGd9EfP9drBvSeicWp0QKFaPfzbKF5QhsQdTk5hqArwa5xMHy0DaF1dP579ALVDAuhWHEtlO9drBvSeicWp0QKFaPfzbKF5QhsQdTk5hqArwa5xMHy0DaF1dP579ALVDAuhWHEVUP9drBvSeicWp0QKFaPfzbKF5QhsQdTk5hqArwa5xMHy0DaF1dP579ALVD3U136NwIpRqFwbO9dDiT9dhQnpfrouAro0QcPdAabV6HiW683eGFiCzGdnFPmJa8dX8pXcaNVDAuhWH0aTFiARILara(HwviDqdi535xU6HK6qRkKoObKS8o)YvpKMV3Rv(2PrDahAfP9drBvSeicWp0QcPdAaj7B(LREiPo0QcPdAajl(MF5QhsZ371kF7UDRqZtreGFOx8HgM0vCixJfC(2zPMV4Viwkl1dPsBhyPEHdTEGPIYvlOFO13qCfJMB3lCi)I8GP9KtErl()6zwzsg3MVBKUcgzsLKXTHL8T7fo0UVJ(HE75H8nr(((2D7EHdrB(NybGP9B3lCOeFiQhW5oKgvmAY3Ux4qj(q0YHJ(HiaRmgi4hA9atf6Lto0dbsmRm6JCOo9qTCOgFOoWYeYH0SihY)q4SblhkTihsVWyaRv(29chkXhAfS2aKdr1p(R4qJZvBa(HEiqIzLrFKdj1HEif7qDGLjKdTEGPc9Yj5B3lCOeFOvWLRGhsgheYH6qac5)i5B3lCOeFO1)YQ5hIATeNaT0Af4q4NXCOn(H4q0R)Qe4qrjhA0RVCiPoe(BmvCO5qAtNmHKVD3Ux4qVO9a7la)q6qArGdXkJ(ihshw0boFO1pJbpc(qrfj2)qmPF3HgM0vGpufo65B3WKUcC(HaSYOpIhEtofCkEz6yKUcp7uVsBGes0wA9bK846LWTBysxbo)qawz0hXdVjJ)gtfQhqUDdt6kW5hcWkJ(iE4n5pguTagpJXaELYaQkvzQalK6JvSkWc5ZKUc8TBysxbo)qawz0hXdVj)XGQfW4zmgWlUCW4hRWaJaIsaM)OxNF42nmPRaNFiaRm6J4H3KtDa2pJmPYTBysxbo)qawz0hXdVj)uBaIc3p(RWZo1R(pnnVPDCvBEWzSmmAs49w9FAAMdMkAMIveiJLHrZRE992nmPRaNFiaRm6J4H3K5GPc9YjE2PE1uVW4KsAysxrMdMk0lNKzdw8MiT2IRVtH9peo(vn(2nmPRaNFiaRm6J4H3KX(hETrPxoXZo1lTQPEHXjL0WKUImhmvOxojZgS4nrALus467uy)dHJtyL3UHjDf48dbyLrFep8M8YH0JUd8mgd4nTjyrj0jtikPnGN1JxmiEUCCFW7BFVD3Ux4qVO9a7la)qWsGq)qsBGdj(HdnmPihQXhAwoTB0Dq(2nmPRa7f)aoNYvmAUDdt6kWE4nz24CQuW5)hcqUDdt6kWE4n5zpOKcJVDdt6kWE4nzoSS(eLzw0SB3WKUcShEtMnoNAysxHY1yXZymGxH0bnGGVDdt6kWE4nzEvgp7uVeiLay)JUdUDdt6kWE4nz24CQHjDfkxJfpJXaEz1siMquJE7AHUNyH0mX7Bp7uV46707GNxqQLGQJL9IImsxrsjHRVtVdEoTbhxvPkDxHXLbNus46707GNzLrFeLb4TmsxrsjXQLqmHKdGrkxr43UHjDfyp8MmBCo1WKUcLRXINXyaVcDYeIcdY)52nmPRa7H3KFkPRWZo1RMSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(RVt0wPnqclhsp6oiN2eSOe6KjeL0giXVtusjHRVtVdEMaPDaC1Z4gb2YQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4VUY1Tw3UHjDfyp8MmBCo1WKUcLRXINXyaV1cg3tSqAM49TNDQ3hqYCWurZucDYesEysVeUDdt6kWE4nzoyQOzkSqGyH43Zo1RM0k5hqArwa5nTlLaCSc3lANQsv4)dq6IOWFJPIowSLvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWt4fRvsjP5dizoyQOzkHozcjpmPxcBFajZbtfntj0jtizcyMoWVUIRJfmE2m7162nmPRa7H3KzJZP4ey4yzC0aeSNDQxwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGjapbFtuI1W6Gwj)aslYciVPDPeGJv4Er7uvQc)Fasxef(Bmv0XIB3WKUcShEt(P2aefUF8xHNDQx9FAAEt74Q28GZyzy0KW7T6)00mhmv0mfRiqgldJMxx5TBysxb2dVjR3oaZQpzbO0lJoqWE2PE1)PPzHozcjZRnXwwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGjapbnC7gM0vG9WBYT5Xv4Ucp7uVdt6LGccW0aoH3EO571HmoiKmEyKoTzaxHRVdNHy0DaxRT6)008M2XvT5bNXYWOjbVR4w9FAAwOtMqY8AtSLvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWtqd3UHjDfyp8MCBECfURWZo17WKEjOGamnGtW3T6)008M2XvT5bNXYWOjbVR4w9FAAwOtMqY8AtSLvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWtqdBPvYpG0ISaYT5Xv4EjOEkbcPh3wnPvzCqi5uszuIFqH9p8AdodXO7aEsjP)ttZPKYOe)Gc7F41gC()O1TBysxb2dVj3MhxH7k8St9omPxckiatd4e8DR(pnnVPDCvBEWzSmmAsW7kUv)NMMBZJRW9sq9ucespUmbmth4x9Dl5hqArwa5284kCVeupLaH0JBRM0QmoiKmhmv0mfRc838iDfzigDhWtkjn1)PPzHozcjZRnXwwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGjapbnOLw3UHjDfyp8MCBECfURWZo1R(pnnVPDCvBEWzSmmAsW7BF3kJdcjJRVtXQG)BjdXO7a(wzCqi5uszuIFqH9p8AdodXO7a(wYpG0ISaYT5Xv4EjOEkbcPh3w9FAAwOtMqY8AtSLvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWtqd3UHjDfyp8M8csBQMaQuWT4peUNDQx9cJ3kTbusP4n86kt0TBysxb2dVjJ)gtfQLTdsBi4E2PE1lmER0gqjLI3WR(UUVDdt6kWE4nz83yQqXbtfntj0jtiE2PE1lmER0gqjLI3WRV1WTBysxb2dVj7FcUQsvl(o(eE2PEX13PW(hc3RgUDVWHwHPhA9iWWXY4Obi4dne4qJJadN(HgM0lbppuuhkaGFiPoeEwchc7FiC8TBysxb2dVj7FcUQsvl(o(eE2PEX13PW(hcpbVRCRMpGK5ey4yzC0aK8WKEjKuspGK5GPIMPe6KjK8WKEjO1TBysxb2dVj7FcUQsvl(o(eE2PEX13PW(hcpbVV3Q)ttZbi(bI6PiY4Y)NTSQC8AtKzJZP4ey4yzC0aeCMaMPdCc(UowW4zZS)2nmPRa7H3K9pbxvPQfFhFcp7uV467uy)dHNG33Bzv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8xxW4zZSFR0giH3(M4fmE2m73QP(pnnZjWWXY4Obi48)zR(pnnZjWWXY4Obi4mbmth4egM0vK9pbxvPQfFhFImShyFbusBapgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdO1wnPvzCqiz83yQqTSDqAdbpdXO7aEsjP)ttZlBhK2qWZ)hTUDdt6kWE4nz24CQHjDfkxJfpJXaEz1siMquJE7AHUNyH0mX7Bp7uV0kRwcXesEjeIF6KB3lCO1xl(RVCiQHr60Mb8drvFh2ZdrvF3HOestdCOgFiSqQybqoK4FIdTEGPc9YjEEiCDOwoK)bFO5q(7f(bYHEiDrAH(TBysxb2dVjJRVtHfstd4zN6LwLXbHKXdJ0Pnd4kC9D4meJUd43Ux4qupqWp06bMkA2HOTIa4dLwKdrvF3HO8peo(q)qA3H0Mozc5qSQC8AtCOgFiMRWWHK6qey40VDdt6kWE4nzoyQqVCINDQx9FAAMdMkAMIveitGHjBX13PW(hc)vnElRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeGNGVj629chA9(KowCiTPtMqoegK)JNhc)ab)qRhyQOzhI2kcGpuAroev9DhIY)q44B3WKUcShEtMdMk0lN4zN6v)NMM5GPIMPyfbYeyyYwC9DkS)HWFvJ3YQYXRnrg)nMkuCWurZucDYesMaMPdSc2)amb4V(23B3WKUcShEtMdMk0lN4zN6v)NMM5GPIMPyfbYeyyYwC9DkS)HWFvJ3QP(pnnZbtfntXkcKXYWOjbFtkjzCqiz8WiDAZaUcxFhodXO7aUw3UHjDfyp8MmhmvOxoXZo1R(pnnZbtfntXkcKjWWKT467uy)dH)QgVDysVeuqaMgWj8(2nmPRa7H3KX13PWcPPbUDdt6kWE4nz24CQHjDfkxJfpJXaEz1siMquJE7AH(T7fo0km9q0R)HytCOfGCi9HrZHK6qA4qu13Dik)dHJpKoKwe4qRhbgowghnabFiwvoETjouJpebgoDppulRIpurZq)qsDi8de8dj(bZHIAZTBysxb2dVj7FcUQsvl(o(eE2PEX13PW(hcpbVRClRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeGNGVAyRMY4GqYCWurZuSX56yrgIr3b8KsIvLJxBImBCofNadhlJJgGGZeWmDGtqtn1qIX13PW(hcxR1XWKUIm2)WRnk9YjzypW(cOK2aA5XWKUIS)j4QkvT474tKH9a7lGsAdO1TBysxb2dVjZRY4jJoZbkzilab79TNDQxcKsaS)r3bBL2ajSCi9O7GCAtWIsOtMqusBGB3WKUcShEtg7F41gLE5KB3TBysxboJD1gLq6GgqWE)yq1cy8mgd4fxFNdePJfkYxNUNDQxwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)vzilajZBSmbdwxAyR0giHLdPhDhKtBcwucDYeIsAdKynLHSaKmVXYemyDPbTUDdt6kWzSR2Oesh0ac2dVj)XGQfW4zmgWl(h6UQ4QXaIF6yXZo1lRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeG)QmKfGK5nwMGbRlnSvAdKWYH0JUdYPnblkHozcrjTbsSMYqwasM3yzcgSU0Gw3Ux4q0YeEmbdoK)bFO5qV99qyGvb)qCWn0p0e8d14dj(bcKwe4qyA6NhGFO0ICO0MGLdPnDYeYHK6qUoGd9Fo0Mw8FiXpCicGLB3WKUcCg7QnkH0bnGG9WBYFmOAbmEgJb8cMh6eyCQIWJjyGNDQxwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)vnLHSaKmVXYemyDPbT84TVBzv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8e0utnLHSaKmVXYemyDPbT84TVAL43AqRTsBGewoKE0DqoTjyrj0jtikPnqI1utzilajZBSmbdwxAqlpE7Rw3UB3WKUcCMvlHycrn6TRf6EX13PiL4zN6fxFNEh88csTeuDSSxuKr6k2QjRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeG)QVjkPKyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMa8ewzI062nmPRaNz1siMquJE7AHUhEtgxFNIuINDQxC9D6DWZPn44QkvP7kmUm4TpGK5GPIMPe6KjK8WKEjC7gM0vGZSAjetiQrVDTq3dVjJRVtrkXZo1lU(o9o45nTJR8)drjdtAg(2nmPRaNz1siMquJE7AHUhEtMdS2mshlu6Lt8St9IRVtVdE2bdxPtxb7hZJd2Q5dizoyQOzkHozcjpmPxcBX13PW(hc)vFtkjwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGjapbnorAD7gM0vGZSAjetiQrVDTq3dVjZbwBgPJfk9YjE2PEPvC9D6DWZoy4kD6ky)yECWwA9bKmhmv0mLqNmHKhM0lHB3WKUcCMvlHycrn6TRf6E4nzmR(KowOKw8dE2PEX13P3bpZkJ(ikdWBzKUITpGK5GPIMPe6KjK8WKEjC7gM0vGZSAjetiQrVDTq3dVjJz1N0XcL0IFWZo1lTIRVtVdEMvg9rugG3YiDf3UHjDf4mRwcXeIA0Bxl09WBYT5bcEhluSrgSqQh)GNDQ3hqYCWurZucDYesEysVe2IRVtH9peU3eD7UDdt6kWz)pkH0bnyVFmOAbmEgJb8I7i97ulCdVhPiyfy0DG52nmPRaN9)Oesh0G9WBYFmOAbmEgJb8I7i97ud(Pjtiyfy0DG52D7gM0vGZ1cg3RoqWaHMowC7gM0vGZ1cg3dVjR7QIRs)e63UHjDf4CTGX9WBYPnb0DvXVDdt6kW5AbJ7H3K)yq1cyW3UB3WKUcC(5tafFmZcqjKoOb79JbvlGXZymGxobgEAta1saJb3TBysxbo)8jGIpMzbOesh0G9WBYFmOAbmEgJb8IRVt1lIwaYTBysxbo)8jGIpMzbOesh0G9WBYFmOAbmEgJb8UWr)XVQsvdg3M2nsxHNDQ3Hj9sqbbyAa799TBysxbo)8jGIpMzbOesh0G9WBYFmOAbmEgJb8YhcnMQcfhy0OE(cbWmiyWTBysxbo)8jGIpMzbOesh0G9WBYFmOAbmEgJb8c6vGRVtTSXWTBysxbo)8jGIpMzbOesh0G9WBYFmOAbmEgJb8(dM)PdGRw4gEpsrWkS)HrJdW3UB3WKUcCwiDqdiyVFmOAbmEgJb8I9p8AdWvfrxvPkPigiep7uVSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(RV1WTBysxbolKoObeShEtMnoNAysxHY1yXZymGx)pkH0bnyp7uVY4GqYCWurZuSkWFZJ0vKHy0DaFlRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeG)QVj629ch6fLMcmbFiX)ihsiZsWDiSR24OFiPoKmKfGCicSo)nbo0W5T0vmoppegEgYiWH8pb31XIB3WKUcCwiDqdiyp8MmBCo1WKUcLRXINXyaVyxTrjKoObe8TBysxbolKoObeShEt(JbvlGXZymG3AjqsD1MowOMOnJInlap7uVpGK5GPIMPe6KjK8WKEjC7gM0vGZcPdAab7H3Kfsh0aYBp7uVcPdAaj)o7FWQpgu6)00TpGK5GPIMPe6KjK8WKEjC7gM0vGZcPdAab7H3Kfsh0aIVE2PEfsh0as23S)bR(yqP)tt3(asMdMkAMsOtMqYdt6LWTBysxbolKoObeShEtMnoNAysxHY1yXZymG3Npbu8XmlaLq6GgSNDQxPnqclhsp6oiN2eSOe6KjeL0gylRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeGNGVj62D7gM0vGZcDYeIcdY)XBaIFGOEkImop7uVSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRG9pata(RV1WTBysxbol0jtikmi)hp8M8csBQMaQuWT4peUNDQxwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)130IeR5WKUIm(BmvO4GPIMPe6KjKmShyFbusBapgM0vKX(hETrPxojd7b2xaL0gqRTAYQYXRnrMnoNItGHJLXrdqWzcyMoWV(MwKynhM0vKXFJPcfhmv0mLqNmHKH9a7lGsAd4XWKUIm(BmvOw2oiTHGNH9a7lGsAd4XWKUIm2)WRnk9YjzypW(cOK2aALuspGK5ey4yzC0aKmbmth4eyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMaCpgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdO1TBysxbol0jtikmi)hp8Mm(BmvOw2oiTHG7zN6vtwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW(hGja)13AiXAomPRiJ)gtfkoyQOzkHozcjd7b2xaL0gqRTAYQYXRnrMnoNItGHJLXrdqWzcyMoWV(wdjwZHjDfz83yQqXbtfntj0jtizypW(cOK2aEmmPRiJ)gtfQLTdsBi4zypW(cOK2aALuspGK5ey4yzC0aKmbmth4eyv541MiJ)gtfkoyQOzkHozcjtaZ0bwb7FaMaCpgM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdOLwjLKM0k5hqArwa5nTlLaCSc3lANQsv4)dq6IOWFJPIowSLvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS)bycWtqJtKw3UHjDf4SqNmHOWG8F8WBYSX5uCcmCSmoAac2Zo1lRkhV2ez83yQqXbtfntj0jtizcyMoWky)dWeG)6BFtSMdt6kY4VXuHIdMkAMsOtMqYWEG9fqjTb8yysxrg7F41gLE5KmShyFbusBaT2kTbsy5q6r3b50MGfLqNmHOK2aj(TV3UHjDf4SqNmHOWG8F8WBY4VXuHIdMkAMsOtMq8St9kTbsy5q6r3b50MGfLqNmHOK2aB18bKmNadhlJJgGKhM0lHTpGK5ey4yzC0aKmbmth4egM0vKXFJPcfhmv0mLqNmHKH9a7lGsAdO1wnPvzCqiz83yQqTSDqAdbpdXO7aEsj9asEz7G0gcEEysVe0ARM467uy)dH7nrjLKMpGK5ey4yzC0aK8WKEjS9bKmNadhlJJgGKjGz6a)6WKUIm(BmvO4GPIMPe6KjKmShyFbusBapgM0vKX(hETrPxojd7b2xaL0gqRKssZhqYlBhK2qWZdt6LW2hqYlBhK2qWZeWmDGFDysxrg)nMkuCWurZucDYesg2dSVakPnGhdt6kYy)dV2O0lNKH9a7lGsAdOvsjPP(pnnVG0MQjGkfCl(dHN)pB1)PP5fK2unbuPGBXFi8mbmth4xhM0vKXFJPcfhmv0mLqNmHKH9a7lGsAd4XWKUIm2)WRnk9YjzypW(cOK2aAPLvSI1c]] )


end
