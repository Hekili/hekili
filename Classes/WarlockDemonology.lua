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


    spec:RegisterPack( "Demonology", 20210706, [[dKKWIbqisH8ivj0LuseBsPQpPKYOivCksPwLsI0RifnlsLUfPQAxI6xIGHPKWXqkwMi0ZusvtJuOUgPGTrQk(gsjmoLevNtjv06qkvZtvs3JQY(ucoOQe0cvs6HiL0evsLUOsQWhjvLyKiLO6KKQsTsLkZePu2jPk)ePezOKQsAPiLO8uKmvsjFvvcmwvjAVu6VKmyihwXIPkpgLjJQld2Si9zr0OPQ60s9AvPMnvUnf7w43sgUQ44kjklhXZHA6exxvTDLOVRumELsNhPA(kH2VkBPXQLLIpcy1lXvKinRGwSc9jtZ6PzDQbn2sj0Fal1ZWEpjblvmgWsTUGPIYvjPBPEg6UA4wTSu46tyGLIQn0QLY73orFhwplfFeWQxIRirAwbTyf6tMM1tZ6ud0yPWpaZQxI6J(yP83CoewplfhWml16cMkkxLK(HEbdXvS33o)I8GP9esizl()Ezwzsa3MVBKUcgzsLeWTHLWTB33r)q6JUhkXvKin3UBhT6FIKaM2VD6)qupGZDiARyVZ3o9FiAPWr)qeGvgde8dTUGPcVYjh6Ha6NvgVrouNEOwouJpuhyzc5q6uKd5FiC2GLdLwKd5vymG1oF70)H0xRna5qu9J)ko04C1gGFOhcOFwz8g5qsDOhsXouhyzc5qRlyQWRCs(2P)dPVUuF9qY4Gqouhcqi)hjF70)HEHlRMFiQv1)c0Yl9LdHFgZH24hIdrV(RrGdfLCOXR(YHK6q4VXuXHMdPfDYes2s5ASGTAzPWUAJsiD8geSvlRE0y1YsbX45aUDvl1WKUclfU(ohishjvKVhDlfJ0cq6XsXQYXRnrg)nMkuCWurZucDYesMaMPdSc2(amb4h61djdjjizEJLjyWHs4qA4q7pK0g4qlCOLdPhphKtBcwucDYeIsAdCi9FiDoKmKKGK5nwMGbhkHdPHdPTLkgdyPW135ar6iPI89OBfREjA1YsbX45aUDvl1WKUclf(hEUQ4QXaIF6yXsXiTaKESuSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(HE9qYqscsM3yzcgCOeoKgo0(djTbo0chA5q6XZb50MGfLqNmHOK2ahs)hsNdjdjjizEJLjyWHs4qA4qABPIXawk8p8CvXvJbe)0XIvS6TERwwkigphWTRAP4aMr6hPRWsrlr4Xem4q(h8HMdrtIhcdSk4hIdUH(HMGFOgFiXpqG0Iahc)UFEa(HslYHsBcwoKw0jtihsQd56ao0)5qBAX)He)WHiawSuXyalfyEOtGXPkcpMGbwkgPfG0JLIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhsNdjdjjizEJLjyWHs4qA4qAFinpenjEO9hIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0chsNdPZH05qYqscsM3yzcgCOeoKgoK2hsZdrtIhs7dP)drJgoK2hA)HK2ahAHdTCi945GCAtWIsOtMqusBGdP)dPZH05qYqscsM3yzcgCOeoKgoK2hsZdrtIhsBl1WKUclfyEOtGXPkcpMGbwXkwk)pkH0XBSvlRE0y1YsbX45aUDvlvmgWsH7i97ujDdVhPiyfy8CGXsnmPRWsH7i97ujDdVhPiyfy8CGXkw9s0QLLcIXZbC7QwQymGLc3r63Pg8ttMqWkW45aJLAysxHLc3r63Pg8ttMqWkW45aJvSILIvlHycrnETRf6wTS6rJvllfeJNd42vTumslaPhlfU(oVo45KKAjO6yzNSiJ0vKHy8Ca)q7pKohIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhkXvCOfx8qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hw4qRFfhsBl1WKUclfU(ofPeRy1lrRwwkigphWTRAPyKwaspwkC9DEDWZPn44Qkv55kmUm4meJNd4hA)HEajZbtfntj0jti5Hj9sWsnmPRWsHRVtrkXkw9wVvllfeJNd42vTumslaPhlfU(oVo45nTJR8)drjdtAgodX45aULAysxHLcxFNIuIvS6PXwTSuqmEoGBx1sXiTaKESu46786GNDWWvE0vW2X84GmeJNd4hA)H05qpGK5GPIMPe6KjK8WKEjCO9hcxFNc7Fi8d96Hs8qlU4Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8dTWH04vCiTTudt6kSuCG1Mr6iPYRCIvS6PbRwwkigphWTRAPyKwaspwkn6q46786GNDWWvE0vW2X84GmeJNd4hA)H0Od9asMdMkAMsOtMqYdt6LGLAysxHLIdS2mshjvELtSIvp9XQLLcIXZbC7QwkgPfG0JLcxFNxh8mRmEJOmaVLr6kYqmEoGFO9h6bKmhmv0mLqNmHKhM0lbl1WKUclfMvFshjvsl(bRy1Jwy1YsbX45aUDvlfJ0cq6XsPrhcxFNxh8mRmEJOmaVLr6kYqmEoGBPgM0vyPWS6t6iPsAXpyfRERCRwwkigphWTRAPyKwaspwQhqYCWurZucDYesEysVeo0(dHRVtH9pe(H8DOvyPgM0vyPAZde8osQyJmyHup(bRyflLqNmHOWG8FSAz1JgRwwkigphWTRAPyKwaspwkwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qVEiA0GLAysxHLkaXpqupfrgNvS6LOvllfeJNd42vTumslaPhlfRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOxpen0IdP)dPZHgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdCinp0WKUIm2)WRnkVYjzylW(cOK2ahs7dT)q6CiwvoETjYSX5uCcmCSmU3abNjGz6aFOxpen0IdP)dPZHgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdCinp0WKUIm(BmvOw2oiTHGNHTa7lGsAdCinp0WKUIm2)WRnkVYjzylW(cOK2ahs7dT4Ih6bKmNadhlJ7nqYeWmDGp0chIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWpKMhAysxrg)nMkuCWurZucDYesg2cSVakPnWH02snmPRWsLK0MQjGkfCj)dHBfRER3QLLcIXZbC7QwkgPfG0JLsNdXQYXRnrg)nMkuCWurZucDYesMaMPdSc2(amb4h61drJgoK(pKohAysxrg)nMkuCWurZucDYesg2cSVakPnWH0(q7pKohIvLJxBImBCofNadhlJ7nqWzcyMoWh61drJgoK(pKohAysxrg)nMkuCWurZucDYesg2cSVakPnWH08qdt6kY4VXuHAz7G0gcEg2cSVakPnWH0(qlU4HEajZjWWXY4EdKmbmth4dTWHyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8dP5HgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdCiTpK2hAXfpKohsJoe5hqArsc5nTlLaCSc3jBNQsv4)dq6IOWFJPIosMHy8Ca)q7peRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOfoKgVIdPTLAysxHLc)nMkulBhK2qWTIvpn2QLLcIXZbC7QwkgPfG0JLIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0RhIMepK(pKohAysxrg)nMkuCWurZucDYesg2cSVakPnWH08qdt6kYy)dV2O8kNKHTa7lGsAdCiTp0(djTbo0chA5q6XZb50MGfLqNmHOK2ahs)hIMepK(p0WKUImBCofNadhlJ7nqWzylW(cOK2ahsZdnmPRiJ)gtfkoyQOzkHozcjdBb2xaL0g4qAEOHjDfzS)HxBuELtYWwG9fqjTbSudt6kSuSX5uCcmCSmU3abBfREAWQLLcIXZbC7QwkgPfG0JLsAdCOfo0YH0JNdYPnblkHozcrjTbo0(dPZHEajZjWWXY4EdK8WKEjCO9h6bKmNadhlJ7nqYeWmDGp0chAysxrg)nMkuCWurZucDYesg2cSVakPnWH0(q7pKohsJoKmoiKm(BmvOw2oiTHGNHy8Ca)qlU4HEajVSDqAdbppmPxchs7dT)q6CiC9DkS)HWpKVdTIdT4IhsNd9asMtGHJLX9gi5Hj9s4q7p0dizobgowg3BGKjGz6aFOxp0WKUIm(BmvO4GPIMPe6KjKmSfyFbusBGdP5HgM0vKX(hETr5vojdBb2xaL0g4qAFOfx8q6COhqYlBhK2qWZdt6LWH2FOhqYlBhK2qWZeWmDGp0RhAysxrg)nMkuCWurZucDYesg2cSVakPnWH08qdt6kYy)dV2O8kNKHTa7lGsAdCiTp0IlEiDoK3pnnNK0MQjGkfCj)dHN)phA)H8(PP5KK2unbuPGl5Fi8mbmth4d96HgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdCinp0WKUIm2)WRnkVYjzylW(cOK2ahs7dPTLAysxHLc)nMkuCWurZucDYeIvSILIdPZ3jwTS6rJvllfeJNd42vTuCaZi9J0vyPwhBb2xa(HGLaH(HK2ahs8dhAysrouJp0SCA345GSLAysxHLc)aoNYvS3wXQxIwTSudt6kSuSX5uPGZ)peGyPGy8Ca3UQvS6TERwwQHjDfwQzlOKcJTuqmEoGBx1kw90yRwwQHjDfwkoSS(eLzs2mlfeJNd42vTIvpny1YsbX45aUDvl1WKUclfBCo1WKUcLRXILY1yrfJbSucPJ3GGTIvp9XQLLcIXZbC7QwkgPfG0JLIaPea7F8CGLAysxHLIxLXkw9OfwTSuqmEoGBx1sXiTaKESu46786GNtsQLGQJLDYImsxrgIXZb8dT4IhcxFNxh8CAdoUQsvEUcJldodX45a(HwCXdHRVZRdEMvgVrugG3YiDfzigphWp0IlEiwTeIjKCams5kc3sHfsZeRE0yPgM0vyPyJZPgM0vOCnwSuUglQymGLIvlHycrnETRf6wXQ3k3QLLcIXZbC7QwQHjDfwk24CQHjDfkxJflLRXIkgdyPe6KjefgK)JvS6ToTAzPGy8Ca3UQLIrAbi9yP05qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(HE9q0SIdT)qsBGdTWHwoKE8CqoTjyrj0jtikPnWH0)HOzfhAXfpeU(oVo4zcK2bWvpJBeidX45a(H2FiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qVEO1VYpK2wQHjDfwQNs6kSIvpAwHvllfeJNd42vTumslaPhl1dizoyQOzkHozcjpmPxcwkSqAMy1Jgl1WKUclfBCo1WKUcLRXILY1yrfJbSuvsg3kw9OHgRwwkigphWTRAPyKwaspwkDoKgDiYpG0IKeYBAxkb4yfUt2ovLQW)hG0frH)gtfDKmdX45a(H2FiwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)qlCO15H0(qlU4H05qpGK5GPIMPe6KjK8WKEjCO9h6bKmhmv0mLqNmHKjGz6aFOxpK(COv6HsY4zZS9qABPgM0vyP4GPIMPWcbIKIFRy1JMeTAzPGy8Ca3UQLIrAbi9yPyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8dTWHsCfhs)hsdhALEin6qKFaPfjjK30UucWXkCNSDQkvH)paPlIc)nMk6izgIXZbCl1WKUclfBCofNadhlJ7nqWwXQhnR3QLLcIXZbC7QwkgPfG0JLY7NMM30oUQnp4mwg27dTWHO5q7pK3pnnZbtfntXkcKXYWEFOxp06Tudt6kSup1gGOW9J)kSIvpA0yRwwkigphWTRAPyKwaspwkVFAAwOtMqY8AtCO9hIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0chsdwQHjDfwkV2byw9jjbLxz8ac2kw9OrdwTSuqmEoGBx1sXiTaKESudt6LGccW0a(qlCiAoKMhsNdrZHwPhsghesgpmsN2mGRW13HZqmEoGFiTp0(d59ttZBAhx1MhCgld79HwW3H0NdT)qE)00SqNmHK51M4q7peRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOfoKgSudt6kSuT5Xv4UcRy1Jg9XQLLcIXZbC7QwkgPfG0JLAysVeuqaMgWhAHdL4H2FiVFAAEt74Q28GZyzyVp0c(oK(CO9hY7NMMf6KjKmV2ehA)Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8dTWH0WH2Fin6qKFaPfjjKBZJRW9sq9ucespUmeJNd4hA)H05qA0HKXbHKtjLrj(bf2)WRn4meJNd4hAXfpK3pnnNskJs8dkS)HxBW5)ZH02snmPRWs1MhxH7kSIvpAOfwTSuqmEoGBx1sXiTaKESudt6LGccW0a(qlCOep0(d59ttZBAhx1MhCgld79HwW3H0NdT)qE)00CBECfUxcQNsGq6XLjGz6aFOxpuIhA)Hi)aslssi3MhxH7LG6PeiKECzigphWTudt6kSuT5Xv4UcRy1JMvUvllfeJNd42vTumslaPhlL3pnnVPDCvBEWzSmS3hAbFhIMep0(djJdcjJRVtXQG)BjdX45a(H2FizCqi5uszuIFqH9p8AdodX45a(H2FiYpG0IKeYT5Xv4EjOEkbcPhxgIXZb8dT)qE)00SqNmHK51M4q7peRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOfoKgSudt6kSuT5Xv4UcRy1JM1PvllfeJNd42vTumslaPhlLxHXhA)HK2akPu8go0RhA9RWsnmPRWsLK0MQjGkfCj)dHBfREjUcRwwkigphWTRAPyKwaspwkVcJp0(djTbusP4nCOxpuIRCl1WKUclf(BmvOw2oiTHGBfREjsJvllfeJNd42vTumslaPhlLxHXhA)HK2akPu8go0RhIgnyPgM0vyPWFJPcfhmv0mLqNmHyfREjMOvllfeJNd42vTumslaPhlfU(of2)q4hY3H0GLAysxHLY)eCvLQs(D8jSIvVexVvllfeJNd42vTudt6kSu(NGRQuvYVJpHLIdygPFKUclL(o9qRlbgowg3BGGp0qGdnocmC6hAysVe09qrDOaa(HK6q4zjCiS)HWXwkgPfG0JLcxFNc7Fi8dTGVdT(dT)q6COhqYCcmCSmU3ajpmPxchAXfp0dizoyQOzkHozcjpmPxchsBRy1lrn2QLLcIXZbC7QwkgPfG0JLcxFNc7Fi8dTGVdrZH2FiVFAAoaXpqupfrgx()CO9hIvLJxBImBCofNadhlJ7nqWzcyMoWhAHdL4HwPhkjJNnZwl1WKUclL)j4QkvL874tyfREjQbRwwkigphWTRAPyKwaspwkC9DkS)HWp0c(oenhA)Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8d96HsY4zZS9q7pK0g4qlCiAs8q6)qjz8Sz2EO9hsNd59ttZCcmCSmU3abN)phA)H8(PPzobgowg3BGGZeWmDGp0chAysxr2)eCvLQs(D8jYWwG9fqjTboKMhAysxrg)nMkuCWurZucDYesg2cSVakPnWH0(q7pKohsJoKmoiKm(BmvOw2oiTHGNHy8Ca)qlU4H8(PP5LTdsBi45)ZH02snmPRWs5FcUQsvj)o(ewXQxI6JvllfeJNd42vTumslaPhlLgDiwTeIjK8sie)0jwkSqAMy1Jgl1WKUclfBCo1WKUcLRXILY1yrfJbSuSAjetiQXRDTq3kw9sKwy1YsbX45aUDvl1WKUclfU(ofwi9BWsXbmJ0psxHL6f0I)6lhIAyKoTza)qu13H19qu13DikH0VHd14dHfsfjbYHe)tCO1fmv4vor3dHRd1YH8p4dnhYFN0pqo0dPlsl0TumslaPhlLgDizCqiz8WiDAZaUcxFhodX45aUvS6L4k3QLLcIXZbC7QwQHjDfwkoyQWRCILIdygPFKUclf1de8dTUGPIMDiATia(qPf5qu13Dik)dHJp0pK2DiTOtMqoeRkhV2ehQXhI5kmCiPoebgoDlfJ0cq6Xs59ttZCWurZuSIazcmm5q7peU(of2)q4h61dPXhA)Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8dTWHsCfwXQxIRtRwwkigphWTRAPgM0vyP4GPcVYjwkoGzK(r6kSuR7N0rYdPfDYeYHWG8F09q4hi4hADbtfn7q0Ara8HslYHOQV7qu(hchBPyKwaspwkVFAAMdMkAMIveitGHjhA)HW13PW(hc)qVEin(q7peRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOxpenjAfRERFfwTSuqmEoGBx1sXiTaKESuE)00mhmv0mfRiqMadto0(dHRVtH9pe(HE9qA8H2FiDoK3pnnZbtfntXkcKXYWEFOfouIhAXfpKmoiKmEyKoTzaxHRVdNHy8Ca)qABPgM0vyP4GPcVYjwXQ36PXQLLcIXZbC7QwkgPfG0JLY7NMM5GPIMPyfbYeyyYH2FiC9DkS)HWp0RhsJp0(dnmPxckiatd4dTWHOXsnmPRWsXbtfELtSIvV1NOvll1WKUclfU(ofwi9BWsbX45aUDvRy1B9R3QLLcIXZbC7QwQHjDfwk24CQHjDfkxJflLRXIkgdyPy1siMquJx7AHUvS6TEn2QLLcIXZbC7QwQHjDfwk)tWvvQk53XNWsXbmJ0psxHLsFNEi61)qSjousqoK3WEFiPoKgoev9DhIY)q44d5bPfbo06sGHJLX9gi4dXQYXRnXHA8HiWWPR7HAzn8HQ3d9dj1HWpqWpK4hmhkQnwkgPfG0JLcxFNc7Fi8dTGVdT(dT)qSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(Hw4qjQHdT)q6CizCqizoyQOzk24CDKmdX45a(HwCXdXQYXRnrMnoNItGHJLX9gi4mbmth4dTWH05q6CinCi9FiC9DkS)HWpK2hALEOHjDfzS)HxBuELtYWwG9fqjTboK2hsZdnmPRi7FcUQsvj)o(ezylW(cOK2ahsBRy1B9AWQLLcIXZbC7QwQHjDfwkEvglfJ0cq6XsrGucG9pEo4q7pK0g4qlCOLdPhphKtBcwucDYeIsAdyPy0zoqjdjjiyRE0yfRERxFSAzPgM0vyPW(hETr5voXsbX45aUDvRyfl1dbyLXBeRww9OXQLLcIXZbC7QwQHjDfwQuWP4LPJr6kSuCaZi9J0vyPwhBb2xa(H8G0IahIvgVroKhKSdC(qVqgdEe8HIk0V)Hys)UdnmPRaFOkC0ZwkgPfG0JLsAdCOfo0ko0(dPrh6bK846LGvS6LOvll1WKUclf(BmvOsbxY)q4wkigphWTRAfRER3QLLcIXZbC7QwQymGLskdOQuLPcSqQpwXQalKpt6kWwQHjDfwkPmGQsvMkWcP(yfRcSq(mPRaBfREASvllfeJNd42vTuXyalfUCW4hRWaJaIsaM)OxzFWsnmPRWsHlhm(XkmWiGOeG5p6v2hSIvpny1YsnmPRWsL6aSFgzsflfeJNd42vTIvp9XQLLcIXZbC7QwkgPfG0JLY7NMM30oUQnp4mwg27dTWHO5q7pK3pnnZbtfntXkcKXYWEFOx9DOeTudt6kSup1gGOW9J)kSIvpAHvllfeJNd42vTumslaPhlLohYRW4dT4IhAysxrMdMk8kNKzdwoKVdTIdP9H2FiC9DkS)HWXh61dPXwQHjDfwkoyQWRCIvS6TYTAzPGy8Ca3UQLIrAbi9yP0OdPZH8km(qlU4HgM0vK5GPcVYjz2GLd57qR4qAFOfx8q467uy)dHJp0chA9wQHjDfwkS)HxBuELtSIvV1PvllfeJNd42vTu1JLcdILAysxHLA5q6XZbwQLJ7dwkAs0sTCiQymGLkTjyrj0jtikPnGvSILsiD8geSvlRE0y1YsbX45aUDvl1WKUclf2)WRnaxvepvLQKIyGqSumslaPhlfRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGFOxpenAWsfJbSuy)dV2aCvr8uvQskIbcXkw9s0QLLcIXZbC7QwkgPfG0JLsghesMdMkAMIvb(BEKUImeJNd4hA)Hyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8d96HsCfwQHjDfwk24CQHjDfkxJflLRXIkgdyP8)OeshVXwXQ36TAzPGy8Ca3UQLIdygPFKUcl16infyc(qI)roKqMLG7qyxTXr)qsDizijb5qeyL9BcCOHZBPRyC6Eim8mKrGd5FcURJKwQHjDfwk24CQHjDfkxJflLRXIkgdyPWUAJsiD8geSvS6PXwTSuqmEoGBx1snmPRWsvlbsQR20rs1eTzuSjjyPyKwaspwQhqYCWurZucDYesEysVeSuXyalvTeiPUAthjvt0MrXMKGvS6PbRwwkigphWTRAPyKwaspwkH0XBqYcnz)dw9XGY7NMEO9h6bKmhmv0mLqNmHKhM0lbl1WKUclLq64ni0yfRE6JvllfeJNd42vTumslaPhlLq64nizjXS)bR(yq59ttp0(d9asMdMkAMsOtMqYdt6LGLAysxHLsiD8gKeTIvpAHvllfeJNd42vTumslaPhlL0g4qlCOLdPhphKtBcwucDYeIsAdCO9hIvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWp0chkXvyPgM0vyPyJZPgM0vOCnwSuUglQymGL65tafFmtsqjKoEJTIvSupFcO4JzsckH0XBSvlRE0y1YsbX45aUDvlvmgWsXjWWtBcOwcym4Sudt6kSuCcm80MaQLagdoRy1lrRwwkigphWTRAPIXawkC9DQoz0cqSudt6kSu467uDYOfGyfRER3QLLcIXZbC7QwQHjDfwQKo6p(vvQAW420Ur6kSumslaPhl1WKEjOGamnGpKVdrJLkgdyPs6O)4xvPQbJBt7gPRWkw90yRwwkigphWTRAPIXawk(qEBQkuCG9w98fcGzqWal1WKUclfFiVnvfkoWERE(cbWmiyGvS6PbRwwkigphWTRAPIXawkWRcC9DQLngSudt6kSuGxf467ulBmyfRE6JvllfeJNd42vTuXyal1py(NoaUkPB49ifbRW(h2BhGTudt6kSu)G5F6a4QKUH3JueSc7FyVDa2kwXsvjzCRww9OXQLLAysxHLYdiyG8UJKwkigphWTRAfREjA1YsnmPRWs55QIRs)e6wkigphWTRAfRER3QLLAysxHLkTjGNRkULcIXZbC7QwXQNgB1YsnmPRWs9XGQfWGTuqmEoGBx1kwXkwQLab3vy1lXvKinRGwScnyP2mKOJKyl1l4fsltp9TE6l0(HoKw(Hd1MNIihkTihAnSR2OeshVbbV2HiWk73eGFiCzGdnFPmJa8dX8prsaNVD0whWHOH2peTwXsGia)quTHwpeMEiZ2dTsoKuhI2(ZH49Yg3vCO6biJuKdPtcAFiDsCR25BhT1bCOeP9drRvSeicWpevBO1dHPhYS9qRKdj1HOT)CiEVSXDfhQEaYif5q6KG2hsNe3QD(2rBDahA90(HO1kwceb4hIQn06HW0dz2EOvYHK6q02FoeVx24UIdvpazKICiDsq7dPZ63QD(2D7EbVqAz6PV1tFH2p0H0YpCO28ue5qPf5qRXQLqmHOgV21c91oebwz)Ma8dHldCO5lLzeGFiM)jsc48TJ26aoen0(HO1kwceb4hAnC9DEDWZVCTdj1HwdxFNxh88lZqmEoGV2H0HMTANVD0whWHsK2peTwXsGia)qRHRVZRdE(LRDiPo0A46786GNFzgIXZb81oKo0Sv78TJ26ao06P9drRvSeicWp0A46786GNF5AhsQdTgU(oVo45xMHy8CaFTdnYHwh0s02H0HMTANVD0whWH0yA)q0AflbIa8dTgU(oVo45xU2HK6qRHRVZRdE(LzigphWx7q6qZwTZ3oARd4qAG2peTwXsGia)qRHRVZRdE(LRDiPo0A46786GNFzgIXZb81oKo0Sv78TJ26aoK(q7hIwRyjqeGFO1W1351bp)Y1oKuhAnC9DEDWZVmdX45a(AhshA2QD(2rBDahIwq7hIwRyjqeGFO1W1351bp)Y1oKuhAnC9DEDWZVmdX45a(AhAKdToOLOTdPdnB1oF7UDVGxiTm9036PVq7h6qA5houBEkICO0ICO1e6KjefgK)ZAhIaRSFta(HWLbo08LYmcWpeZ)ejbC(2rBDahA90(HO1kwceb4hAnYpG0IKeYVCTdj1HwJ8diTijH8lZqmEoGV2H0HMTANVD3UxWlKwME6B90xO9dDiT8dhQnpfrouAro0ACiD(ozTdrGv2Vja)q4YahA(szgb4hI5FIKaoF7OToGdrlO9drRvSeicWp0A46786GNF5AhsQdTgU(oVo45xMHy8CaFTdPZ63QD(2rBDahADs7hIwRyjqeGFO1W1351bp)Y1oKuhAnC9DEDWZVmdX45a(AhshA2QD(2rBDahIgAO9drRvSeicWp0AKFaPfjjKF5AhsQdTg5hqArsc5xMHy8CaFTdPdnB1oF7OToGdrtI0(HO1kwceb4hAnYpG0IKeYVCTdj1HwJ8diTijH8lZqmEoGV2Hg5qRdAjA7q6qZwTZ3oARd4q0Op0(HO1kwceb4hAnYpG0IKeYVCTdj1HwJ8diTijH8lZqmEoGV2H0HMTANVD0whWHOHwq7hIwRyjqeGFO1i)aslssi)Y1oKuhAnYpG0IKeYVmdX45a(AhAKdToOLOTdPdnB1oF7OToGdrZkN2peTwXsGia)qRr(bKwKKq(LRDiPo0AKFaPfjjKFzgIXZb81oKo0Sv78T729cEH0Y0tFRN(cTFOdPLF4qT5PiYHslYHwtiD8ge8AhIaRSFta(HWLbo08LYmcWpeZ)ejbC(2rBDahsd0(HO1kwceb4hAnH0XBqY0KF5AhsQdTMq64nizHM8lx7q6qZwTZ3oARd4q6dTFiATILara(HwtiD8gKCI5xU2HK6qRjKoEdswsm)Y1oKo0Sv78T72PVnpfra(HwNhAysxXHCnwW5BNL6HuPTdSuV4HwxWur5QK0p0lyiUI9(29IhYVipyApHes2I)VxMvMeWT57gPRGrMujbCByjC7EXdT77OFi9r3dL4ksKMB3T7fpeT6FIKaM2VDV4H0)HOEaN7q0wXENVDV4H0)HOLch9drawzmqWp06cMk8kNCOhcOFwz8g5qD6HA5qn(qDGLjKdPtroK)HWzdwouAroKxHXaw78T7fpK(pK(ATbihIQF8xXHgNR2a8d9qa9ZkJ3ihsQd9qk2H6altihADbtfELtY3Ux8q6)q6Rl1xpKmoiKd1HaeY)rY3Ux8q6)qVWLvZpe1Q6FbA5L(YHWpJ5qB8dXHOx)1iWHIso04vF5qsDi83yQ4qZH0IozcjF7UDV4HwhBb2xa(H8G0IahIvgVroKhKSdC(qVqgdEe8HIk0V)Hys)UdnmPRaFOkC0Z3UHjDf48dbyLXBen9Lqk4u8Y0XiDf62P(K2alSI9A0di5X1lHB3WKUcC(HaSY4nIM(sa)nMkupGC7gM0vGZpeGvgVr00xcFmOAbm6gJb8jLbuvQYubwi1hRyvGfYNjDf4B3WKUcC(HaSY4nIM(s4JbvlGr3ymGpC5GXpwHbgbeLam)rVY(WTBysxbo)qawz8grtFjK6aSFgzsLB3WKUcC(HaSY4nIM(s4P2aefUF8xHUDQpVFAAEt74Q28GZyzyVxGM9E)00mhmv0mfRiqgld79R(s82nmPRaNFiaRmEJOPVe4GPcVYj62P(0XRW4fxCysxrMdMk8kNKzdw8TcT3JRVtH9peo(vn(2nmPRaNFiaRmEJOPVeW(hETr5vor3o1NgPJxHXlU4WKUImhmv4vojZgS4BfAV4I467uy)dHJxy93UHjDf48dbyLXBen9LWYH0JNd0ngd4lTjyrj0jtikPnGU1Jpmi6UCCFWhnjE7UDV4HwhBb2xa(HGLaH(HK2ahs8dhAysrouJp0SCA345G8TBysxb2h(bCoLRyVVDdt6kWA6lb24CQuW5)hcqUDdt6kWA6lHzlOKcJVDdt6kWA6lboSS(eLzs2SB3WKUcSM(sGnoNAysxHY1yr3ymGpH0XBqW3UHjDfyn9LaVkJUDQpcKsaS)XZb3UHjDfyn9LaBCo1WKUcLRXIUXyaFSAjetiQXRDTqxxSqAM4JgD7uF46786GNtsQLGQJLDYImsxXIlIRVZRdEoTbhxvPkpxHXLbV4I46786GNzLXBeLb4TmsxXIlYQLqmHKdGrkxr43UHjDfyn9LaBCo1WKUcLRXIUXyaFcDYeIcdY)52nmPRaRPVeEkPRq3o1NoSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(R0SI9sBGfwoKE8CqoTjyrj0jtikPnG(PzflUiU(oVo4zcK2bWvpJBeypRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeG)66x5AF7gM0vG10xcSX5udt6kuUgl6gJb8vjzCDXcPzIpA0Tt99asMdMkAMsOtMqYdt6LWTBysxbwtFjWbtfntHfcejf)62P(0rJi)aslssiVPDPeGJv4oz7uvQc)Fasxef(Bmv0rY9SQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(cRtTxCrDEajZbtfntj0jti5Hj9sy)dizoyQOzkHozcjtaZ0b(v9zLMKXZMzR23UHjDfyn9LaBCofNadhlJ7nqW62P(yv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8fsCf6xdRunI8diTijH8M2LsaowH7KTtvPk8)biDru4VXurhjVDdt6kWA6lHNAdqu4(XFf62P(8(PP5nTJRAZdoJLH9EbA279ttZCWurZuSIazSmS3VU(B3WKUcSM(sWRDaMvFssq5vgpGG1Tt959ttZcDYesMxBI9SQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(cA42nmPRaRPVeAZJRWDf62P(gM0lbfeGPb8c0OPo0SsLXbHKXdJ0Pnd4kC9D4meJNd4AV37NMM30oUQnp4mwg27f8Pp79(PPzHozcjZRnXEwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaFbnC7gM0vG10xcT5Xv4UcD7uFdt6LGccW0aEHe379ttZBAhx1MhCgld79c(0N9E)00SqNmHK51MypRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGVGg2RrKFaPfjjKBZJRW9sq9ucespU96OrY4GqYPKYOe)Gc7F41gCgIXZb8fx07NMMtjLrj(bf2)WRn48)r7B3WKUcSM(sOnpUc3vOBN6BysVeuqaMgWlK4EVFAAEt74Q28GZyzyVxWN(S37NMMBZJRW9sq9ucespUmbmth4xtCp5hqArsc5284kCVeupLaH0J72nmPRaRPVeAZJRWDf62P(8(PP5nTJRAZdoJLH9EbF0K4EzCqizC9Dkwf8FlzigphW3lJdcjNskJs8dkS)HxBWzigphW3t(bKwKKqUnpUc3lb1tjqi94279ttZcDYesMxBI9SQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(cA42nmPRaRPVessAt1eqLcUK)HW1Tt95vy8EPnGskfVHxx)kUDdt6kWA6lb83yQqTSDqAdbx3o1NxHX7L2akPu8gEnXv(TBysxbwtFjG)gtfkoyQOzkHozcr3o1NxHX7L2akPu8gELgnC7gM0vG10xc(NGRQuvYVJpHUDQpC9DkS)HW9PHB3lEi9D6HwxcmCSmU3abFOHahACey40p0WKEjO7HI6qba8dj1HWZs4qy)dHJVDdt6kWA6lb)tWvvQk53XNq3o1hU(of2)q4l4B9715bKmNadhlJ7nqYdt6LWIl(asMdMkAMsOtMqYdt6LG23UHjDfyn9LG)j4QkvL874tOBN6dxFNc7Fi8f8rZEVFAAoaXpqupfrgx()SNvLJxBImBCofNadhlJ7nqWzcyMoWlK4knjJNnZ2B3WKUcSM(sW)eCvLQs(D8j0Tt9HRVtH9pe(c(OzpRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeG)AsgpBMT7L2alqtI6pjJNnZ29649ttZCcmCSmU3abN)p79(PPzobgowg3BGGZeWmDGxyysxr2)eCvLQs(D8jYWwG9fqjTb0Cysxrg)nMkuCWurZucDYesg2cSVakPnG271rJKXbHKXFJPc1Y2bPne8meJNd4lUO3pnnVSDqAdbp)F0(2nmPRaRPVeyJZPgM0vOCnw0ngd4JvlHycrnETRf66IfsZeF0OBN6tJy1siMqYlHq8tNC7EXd9cAXF9LdrnmsN2mGFiQ67W6EiQ67oeLq63WHA8HWcPIKa5qI)jo06cMk8kNO7HW1HA5q(h8HMd5Vt6hih6H0fPf63UHjDfyn9LaU(ofwi9Bq3o1NgjJdcjJhgPtBgWv467WzigphWVDV4HOEGGFO1fmv0SdrRfbWhkTihIQ(Udr5FiC8H(H0UdPfDYeYHyv541M4qn(qmxHHdj1HiWWPF7gM0vG10xcCWuHx5eD7uFE)00mhmv0mfRiqMadt2JRVtH9pe(RA8EwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaFHexXT7fp06(jDK8qArNmHCimi)hDpe(bc(HwxWurZoeTweaFO0ICiQ67oeL)HWX3UHjDfyn9Lahmv4vor3o1N3pnnZbtfntXkcKjWWK9467uy)dH)QgVNvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWFLMeVDdt6kWA6lboyQWRCIUDQpVFAAMdMkAMIveitGHj7X13PW(hc)vnEVoE)00mhmv0mfRiqgld79cjU4IY4GqY4Hr60MbCfU(oCgIXZbCTVDdt6kWA6lboyQWRCIUDQpVFAAMdMkAMIveitGHj7X13PW(hc)vnE)WKEjOGamnGxGMB3WKUcSM(saxFNclK(nC7gM0vG10xcSX5udt6kuUgl6gJb8XQLqmHOgV21c9B3lEi9D6HOx)dXM4qjb5qEd79HK6qA4qu13Dik)dHJpKhKwe4qRlbgowg3BGGpeRkhV2ehQXhIadNUUhQL1WhQEp0pKuhc)ab)qIFWCOO2C7gM0vG10xc(NGRQuvYVJpHUDQpC9DkS)HWxW363ZQYXRnrg)nMkuCWurZucDYesMaMPdSc2(amb4lKOg2RJmoiKmhmv0mfBCUosMHy8CaFXfzv541MiZgNtXjWWXY4EdeCMaMPd8c6OJg0pU(of2)q4AVshM0vKX(hETr5vojdBb2xaL0gqBnhM0vK9pbxvPQKFhFImSfyFbusBaTVDdt6kWA6lbEvgDz0zoqjdjjiyF0OBN6JaPea7F8CWEPnWclhspEoiN2eSOe6KjeL0g42nmPRaRPVeW(hETr5vo52D7gM0vGZyxTrjKoEdc23hdQwaJUXyaF467CGiDKur(E01Tt9XQYXRnrg)nMkuCWurZucDYesMaMPdSc2(amb4VkdjjizEJLjyWkrd7L2alSCi945GCAtWIsOtMqusBa9RJmKKGK5nwMGbRenO9TBysxboJD1gLq64niyn9LWhdQwaJUXyaF4F45QIRgdi(PJfD7uFSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(RYqscsM3yzcgSs0WEPnWclhspEoiN2eSOe6KjeL0gq)6idjjizEJLjyWkrdAF7EXdrlr4Xem4q(h8HMdrtIhcdSk4hIdUH(HMGFOgFiXpqG0Iahc)UFEa(HslYHsBcwoKw0jtihsQd56ao0)5qBAX)He)WHiawUDdt6kWzSR2OeshVbbRPVe(yq1cy0ngd4dmp0jW4ufHhtWaD7uFSQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(R6idjjizEJLjyWkrdARjnjUNvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWxqhD0rgssqY8gltWGvIg0wtAsuB9tJg0EV0gyHLdPhphKtBcwucDYeIsAdOFD0rgssqY8gltWGvIg0wtAsu7B3TBysxboZQLqmHOgV21cDF467uKs0Tt9HRVZRdEojPwcQow2jlYiDf71HvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycWFnXvS4ISQC8AtKXFJPcfhmv0mLqNmHKjGz6aRGTpata(cRFfAF7gM0vGZSAjetiQXRDTqxtFjGRVtrkr3o1hU(oVo450gCCvLQ8Cfgxg8(hqYCWurZucDYesEysVeUDdt6kWzwTeIje141UwORPVeW13PiLOBN6dxFNxh88M2Xv()HOKHjndF7gM0vGZSAjetiQXRDTqxtFjWbwBgPJKkVYj62P(W1351bp7GHR8ORGTJ5Xb715bKmhmv0mLqNmHKhM0lH9467uy)dH)AIlUiRkhV2ez83yQqXbtfntj0jtizcyMoWky7dWeGVGgVcTVDdt6kWzwTeIje141UwORPVe4aRnJ0rsLx5eD7uFAeU(oVo4zhmCLhDfSDmpoyVg9asMdMkAMsOtMqYdt6LWTBysxboZQLqmHOgV21cDn9LaMvFshjvsl(bD7uF46786GNzLXBeLb4TmsxX(hqYCWurZucDYesEysVeUDdt6kWzwTeIje141UwORPVeWS6t6iPsAXpOBN6tJW1351bpZkJ3ikdWBzKUIB3WKUcCMvlHycrnETRf6A6lH28abVJKk2idwi1JFq3o13dizoyQOzkHozcjpmPxc7X13PW(hc33kUD3UHjDf4S)hLq64n23hdQwaJUXyaF4os)ovs3W7rkcwbgphyUDdt6kWz)pkH0XBSM(s4JbvlGr3ymGpChPFNAWpnzcbRaJNdm3UB3WKUcCUsY4(8acgiV7i5TBysxboxjzCn9LGNRkUk9tOF7gM0vGZvsgxtFjK2eWZvf)2nmPRaNRKmUM(s4JbvlGbF7UDdt6kW5Npbu8XmjbLq64n23hdQwaJUXyaFCcm80MaQLagdUB3WKUcC(5tafFmtsqjKoEJ10xcFmOAbm6gJb8HRVt1jJwaYTBysxbo)8jGIpMjjOeshVXA6lHpguTagDJXa(s6O)4xvPQbJBt7gPRq3o13WKEjOGamnG9rZTBysxbo)8jGIpMjjOeshVXA6lHpguTagDJXa(4d5TPQqXb2B1ZxiaMbbdUDdt6kW5Npbu8XmjbLq64nwtFj8XGQfWOBmgWh4vbU(o1Ygd3UHjDf48ZNak(yMKGsiD8gRPVe(yq1cy0ngd47hm)thaxL0n8EKIGvy)d7TdW3UB3WKUcCwiD8geSVpguTagDJXa(W(hETb4QI4PQuLuedeIUDQpwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)vA0WTBysxbolKoEdcwtFjWgNtnmPRq5ASOBmgWN)hLq64nw3o1NmoiKmhmv0mfRc838iDfzigphW3ZQYXRnrg)nMkuCWurZucDYesMaMPdSc2(amb4VM4kUDV4HwhPPatWhs8pYHeYSeChc7Qno6hsQdjdjjihIaRSFtGdnCElDfJt3dHHNHmcCi)tWDDK82nmPRaNfshVbbRPVeyJZPgM0vOCnw0ngd4d7QnkH0XBqW3UHjDf4Sq64niyn9LWhdQwaJUXyaF1sGK6QnDKunrBgfBsc62P(EajZbtfntj0jti5Hj9s42nmPRaNfshVbbRPVeeshVbHgD7uFcPJ3GKPj7FWQpguE)009pGK5GPIMPe6KjK8WKEjC7gM0vGZcPJ3GG10xccPJ3GKOUDQpH0XBqYjM9py1hdkVFA6(hqYCWurZucDYesEysVeUDdt6kWzH0XBqWA6lb24CQHjDfkxJfDJXa(E(eqXhZKeucPJ3yD7uFsBGfwoKE8CqoTjyrj0jtikPnWEwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaFHexXT72nmPRaNf6KjefgK)JVae)ar9uezC62P(yv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8xPrd3UHjDf4SqNmHOWG8F00xcjjTPAcOsbxY)q462P(yv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8xPHwOFDgM0vKXFJPcfhmv0mLqNmHKHTa7lGsAdO5WKUIm2)WRnkVYjzylW(cOK2aAVxhwvoETjYSX5uCcmCSmU3abNjGz6a)kn0c9RZWKUIm(BmvO4GPIMPe6KjKmSfyFbusBanhM0vKXFJPc1Y2bPne8mSfyFbusBanhM0vKX(hETr5vojdBb2xaL0gq7fx8bKmNadhlJ7nqYeWmDGxGvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycW1Cysxrg)nMkuCWurZucDYesg2cSVakPnG23UHjDf4SqNmHOWG8F00xc4VXuHAz7G0gcUUDQpDyv541MiJ)gtfkoyQOzkHozcjtaZ0bwbBFaMa8xPrd6xNHjDfz83yQqXbtfntj0jtizylW(cOK2aAVxhwvoETjYSX5uCcmCSmU3abNjGz6a)knAq)6mmPRiJ)gtfkoyQOzkHozcjdBb2xaL0gqZHjDfz83yQqTSDqAdbpdBb2xaL0gq7fx8bKmNadhlJ7nqYeWmDGxGvLJxBIm(BmvO4GPIMPe6KjKmbmthyfS9bycW1Cysxrg)nMkuCWurZucDYesg2cSVakPnG2AV4I6OrKFaPfjjK30UucWXkCNSDQkvH)paPlIc)nMk6i5EwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGjaFbnEfAF7gM0vGZcDYeIcdY)rtFjWgNtXjWWXY4EdeSUDQpwvoETjY4VXuHIdMkAMsOtMqYeWmDGvW2hGja)vAsu)6mmPRiJ)gtfkoyQOzkHozcjdBb2xaL0gqZHjDfzS)HxBuELtYWwG9fqjTb0EV0gyHLdPhphKtBcwucDYeIsAdOFAsu)dt6kYSX5uCcmCSmU3abNHTa7lGsAdO5WKUIm(BmvO4GPIMPe6KjKmSfyFbusBanhM0vKX(hETr5vojdBb2xaL0g42nmPRaNf6KjefgK)JM(sa)nMkuCWurZucDYeIUDQpPnWclhspEoiN2eSOe6KjeL0gyVopGK5ey4yzCVbsEysVe2)asMtGHJLX9gizcyMoWlmmPRiJ)gtfkoyQOzkHozcjdBb2xaL0gq796OrY4GqY4VXuHAz7G0gcEgIXZb8fx8bK8Y2bPne88WKEjO9EDW13PW(hc33kwCrDEajZjWWXY4EdK8WKEjS)bKmNadhlJ7nqYeWmDGFDysxrg)nMkuCWurZucDYesg2cSVakPnGMdt6kYy)dV2O8kNKHTa7lGsAdO9IlQZdi5LTdsBi45Hj9sy)di5LTdsBi4zcyMoWVomPRiJ)gtfkoyQOzkHozcjdBb2xaL0gqZHjDfzS)HxBuELtYWwG9fqjTb0EXf1X7NMMtsAt1eqLcUK)HWZ)N9E)00CssBQMaQuWL8peEMaMPd8Rdt6kY4VXuHIdMkAMsOtMqYWwG9fqjTb0Cysxrg7F41gLx5KmSfyFbusBaT12snFXFrSuwXkwla]] )


end
