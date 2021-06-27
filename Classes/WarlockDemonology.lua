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
    spec:RegisterTotem( "dreadstalkers", 1378282 )


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


    spec:RegisterPack( "Demonology SimC", 20210403, [[dCezYaqiLQ6rKsytQk9jivmkLuoLsQwfeL0RGiZcP0TuQIDjXVuvmmivDmiLLPu4zqumniQUMssBJus(geLY4iLOCoLevRtPkzEkjCpvv7JuQdskPAHifpKuImrivQlcPs8rsjQojPKYkjvntLeLDcb)eIsyOkjILcrP6PQyQqOVcPsASkjs7f4VsAWcoSOfJKhJYKj5YeBwL(mKmAKQtR41kfnBe3wODt53snCL44quIwoONJQPt11vLTRu67kvgVsvQZtkMpPY(HAaAaebhv6caHnq)gOHEKJEKPGgARQvihCCnlc4SKSntuc4yzuah0TeBRjnkn4WzIAjWzj1q6ubqeC49dYeWHU7l896ZhuJt)rvyD8dFIps6tBmyE9p8jY(aouVH4AndqboQ0facBG(nqd9ih9itbn0wvRqMvo4WxegaHn0kTcCOpkLyakWrjCg4GULyBnPrPbhqxtiPzBI1t39f(E95dQXP)OkSo(HpXhj9PngmV(h(ezFW616lWHGdBqloSb63anSESETe90qj89cRFp4WzrieCyL1Snly97bhqwyen4auyDmkMchq3sSnQM44Wcu2dRJuPJdZfhghhgoomg3tZXH1AioqpHkwYDC42qCGQ5CHVEbRFp4WkP3jqC4ml0BdhscP3jkCybk7H1rQ0XbVXHfyZWHX4EAooGULyBunXly97bhq2LTdxWbTwCH08PnC42qCGiOetLqnfS(9GdRKTReCWtIyoomMlq4BXlGZcSVdrahTahq3sSTM0O0GdORjK0SnX61cCGU7l896ZhuJt)rvyD8dFIps6tBmyE9p8jY(G1Rf4GwFboeCydAXHnq)gOH1J1Rf4GwIEAOe(EH1Rf4WEWHZIqi4WkRzBwW61cCyp4aYcJObhGcRJrXu4a6wITr1ehhwGYEyDKkDCyU4W44WWXHX4EAooSwdXb6juXsUJd3gIdunNl81ly9AboShCyL07eioCMf6THdjH07efoSaL9W6iv64G34WcSz4WyCpnhhq3sSnQM4fSETah2doGSlBhUGdAT4cP5tB4WTH4arqjMkHAky9AboShCyLSDLGdEseZXHXCbcFlEbRhRxlWb0L9wypxu4aLCBOGdSosLooqjOgJxWbToJjlohhS22d9egVpcoKmFAJJdTr0uW6tMpTXllqH1rQ0r6)Zvivvhhl9PnAN7VprrB0)D)fXljz2ky9jZN24LfOW6iv6i9)H)IX2QlIJ1NmFAJxwGcRJuPJ0)NLENaR8zHEB0o3FQ39w2nevDIl8c3t2MAJ2xQ39wusSTHvznukCpzBUI)nW6tMpTXllqH1rQ0r6)JsITr1eN25(VgvZ560LmFAROKyBunXlSK7)OF9V8(rQC6juXxbYX61cCiz(0gVSafwhPshP)pBt4KueHwlJYVRbMMxHsQ0q72K8KFw3evVZk8xm2wvjX2gw11atZlqjMJXxXQFxBFpjI5fv3XIyjfru60PeQ39wuDhlVL1)Ug17Elkj22WQChkgkNE5TOt3(EseZlkj22WQChkgkNErSKIikD68KiMxusSTHvzTXFXfFARiwsre16FxBFpjI5ftC6cSU0qpjfXskIO0PJ6DVftC6cSU0qpjL3IoDSUjQENvmXPlW6sd9KuGsmhJRnARU(3123tIyEbfCI9aL6viOEjuvelPiIsNow3evVZkOGtShOuVcb1lHQcuI5yCTrB11)U2(EseZl8xm2wD7qK7iMQiwsreLoDSUjQENv4VyST62Hi3rmvbkXCmU2OT66FxBFpjI5fLeBByvwB8xCXN2kILuerPth17El7gIQoXfE5TOthVFKkNEcv)RQth17ElM40fyDPHEskVLV8(rQC6juPn6xhRhRxlWb0L9wypxu4GSvGAWbFIco40fCizEdXHHJd52Cijfrky9jZN24)8fHqQKMTjwFY8Pnos)FyjHuVcH(ZCbI1NmFAJJ0)NCVLQ3CowFY8Pnos)FuY2(bRXe1WW6tMpTXr6)dljKAY8PTkz4oTwgL)(EROykS(K5tBCK()aFwnz(0wLmCNwlJYVRbMMxxGYcTChom)hnAN7pRBIQ3zf(lgBRQKyBdR6AGP5fOeZX4Ra5F331atZRqjvAW6tMpTXr6)d8z1K5tBvYWDATmk)8xm2w11atZPL7WH5)Or7C)DnW08kusLgS(K5tBCK()WFXyB1TdrUJykAN7pRBIQ3zf(lgBRQKyBdR6AGP5fOeZX4AJC0Rt3Dqr3RqjMJXxbRBIQ3zf(lgBRQKyBdR6AGP5fOeZX4iTXQy9jZN24i9)HLesvbLuX9KSPa5y9jZN24i9)r1DK25(dLlu40tkIG1NmFAJJ0)hLeBByvUdfdLthRpz(0ghP)pudr4S(brjvQosjqowFY8Pnos)FM4cP5tB0o3)K5ZwPkMehHRnAF33tIyEHNm4ChMOQ8(r4fXskIO(s9U3YUHOQtCHx4EY2u7FT6l17ElUgyAEr17SVSUjQENv4VySTQsITnSQRbMMxGsmhJR9Qy9jZN24i9)zIlKMpTr7C)tMpBLQysCeU2B8L6DVLDdrvN4cVW9KTP2)A1xQ39wCnW08IQ3zy9jZN24i9)HEAQAFROEevA0o3FE)ivo9eQ(xvNoQ39wmXPlW6sd9KuEly9jZN24i9)HEAQAFROEevA0o3FE)ivo9eQ0(hz(Y6MO6DwH)IX2Qkj22WQUgyAEbkXCmU2BG(VRX6MO6DwH)IX2QBhIChXufOeZX4AVQoD77jrmVWFXyB1TdrUJyQIyjfruR)L1nr17ScljKQckPI7jztbYlqjMJX1EdS(K5tBCK()WscPMmFARsgUtRLr5N1BflnNwUdhM)JgTZ9FnwVvS08IjmytAOsNowVvS08InOO71BkR)DFpjI5ftC6cSU0qpjfXskIOW6tMpTXr6)JsITr1eN25(t9U3IsITnSkRHsbkjZ)Y7hPYPNq1kqowFY8Pnos)FqbNypqPEfcQxcv0o3Fw3evVZk8xm2wvjX2gw11atZlqjMJXrI1nr17Sc)fJTvvsSTHvDnW08I6btFAt77GIUxHsmhJRt3Dqr3RqjMJXxbRBIQ3zf(lgBRQKyBdR6AGP5fOeZX4iH2Qy9jZN24i9)5XL64sKJ1NmFAJJ0)NLENaR8zHEB0o3FQ39w2nevDIl8c3t2MAJ2xQ39wusSTHvznukCpzBUcKbRpz(0ghP)p8(rQChoBky9jZN24i9)HLesnz(0wLmCNwlJYpR3kwAowFY8Pnos)F40tvVRs1ehRhRpz(0gVW6TILM)pXfXuJHQYsp5oSxOl0o3)99KiMx4jdo3HjQkVFeErSKIikD6sMpBLQysCeU2OH1NmFAJxy9wXsZr6)dN1p4yOQ(40fAN7VNeX8cpzW5omrv59JWlILuer9nz(SvQIjXr4)OH1NmFAJxy9wXsZr6)dN1p4yOQ(40fAN7)(EseZl8KbN7WevL3pcViwsre13K5ZwPkMehHVcKJ1NmFAJxy9wXsZr6)dVFKkSDS(K5tB8cR3kwAos)FucBIPpgQkvtCSES(K5tB8sFVvum1pLa5cCZXqr7C)xeVOKyBdR6AGP5LK5ZwbRpz(0gV03BfftH0)NL2N2ODU)uV7TqjqUa3CmuL3IoDlIxusSTHvDnW08sY8zR8DFyYKIdBcbRpz(0gV03BfftH0)hks3Q69b1q7C)xeVOKyBdR6AGP5LK5ZwbRpz(0gV03BfftH0)N7afks3kAN7)I4fLeBByvxdmnVKmF2ky9y9jZN24f(lgBR6AGP5)0ttv7Bf1JOsJ25(Z7hPYPNq1)Qy9jZN24f(lgBR6AGP5i9)rjX2OAIt7C)PE3BrjX2gwL1qP8w(UMNeX8IsITnSkRn(lU4tBfXskIO0PJ6DVftC6cSU0qpjfvVZwNwYysLP(3a9y9jZN24f(lgBR6AGP5i9)Htpv9UkvtCAN7p17El7gIQoXfEH7jBtKgJ1XXqvN4cFfi)7AEseZlkj22WQS24V4IpTvelPiIsNoQ39wmXPlW6sd9Kuu9oBDAjJjvM6Fd0J1NmFAJx4VySTQRbMMJ0)huWj2duQxHG6LqfwFY8PnEH)IX2QUgyAos)F4VyST62Hi3rmfwFY8PnEH)IX2QUgyAos)FyjHuvqjvCpjBkqowFY8PnEH)IX2QUgyAos)FONMQ23kQhrLgwFY8PnEH)IX2QUgyAos)FusSnQM40o3FQ39wusSTHvznukVLVuV7TyItxG1Lg6jP8w(U2AuV7TSDiYDetvGsmhJR9Q60TVNeX8c)fJTv3oe5oIPkILuerT(31OE3BbfCI9aL6viOEjuvGsmhJR9Q60r9U3ck4e7bk1Rqq9sOQO6D26RJ1NmFAJx4VySTQRbMMJ0)hE)ivUdNnfAN7p17ElM40fyDPHEskVLVRTg17ElBhIChXufOeZX4AVQoD77jrmVWFXyB1TdrUJyQIyjfruR)DnQ39wqbNypqPEfcQxcvfOeZX4AVQoDuV7TGcoXEGs9keuVeQkQENT(6y9jZN24f(lgBR6AGP5i9)Htpv9UkvtCAN7p17ElM40fyDPHEskVLVRTg17ElBhIChXufOeZX4AVQoD77jrmVWFXyB1TdrUJyQIyjfruR)DnQ39wqbNypqPEfcQxcvfOeZX4AVQoDuV7TGcoXEGs9keuVeQkQENT(6y9AboKmFAJx4VySTQRbMMJ0)NTjCskIqRLr531atZRqjvAODBsEY)(SUjQENv4VySTQsITnSQRbMMxGsQ0G1NmFAJx4VySTQRbMMJ0)h(lgBRQKyBdR6AGP50o3)99KiMxusSTHvzTXFXfFAtNoQ39w2nevDIl8c3t2MinXfELVK7mrvvp4yOk8xm2wvjX2gw11atZ1gzW6tMpTXl8xm2w11atZr6)dNEQ6DvQM4y9y9jZN24fxdmnVUaLLFv3rAjJjvM6hzqpwFY8PnEX1atZRlqzbP)pM40fyDPHEsW6tMpTXlUgyAEDbkli9)bfCI9aL6viOEjur7C)59Ju50tO6FvS(K5tB8IRbMMxxGYcs)F4VyST62Hi3rmfTZ9N3psLtpHQFK)DT99KiMxqbNypqPEfcQxcv60X6MO6DwbfCI9aL6viOEjuvGsmhJVowFY8PnEX1atZRlqzbP)pSKqQkOKkUNKnfiN25(VVNeX8ck4e7bk1Rqq9sOsNow3evVZkOGtShOuVcb1lHQcuI5yCS(K5tB8IRbMMxxGYcs)FusSnQM40o3FQ39wusSTHvznukVLV8(rQC6juTcK)DnpjI5fLeBByvwB8xCXN2kILuerPth17ElM40fyDPHEskQENTowFY8PnEX1atZRlqzbP)p8(rQChoBk0o3FE)ivo9eQwXQ7b5iRuV7TyItxG1Lg6jP8wW6tMpTXlUgyAEDbkli9)Htpv9UkvtCAN7pVFKkNEcvRy19GCKvQ39wmXPlW6sd9KuEly9AboKmFAJxCnW086cuwq6)Z2eojfrO1YO87AGP5vOKkn0Unjp5hnS(K5tB8IRbMMxxGYcs)FONMQ23kQhrLg4SvG8PnacBG(nqd9OTbAGZUeAJHIdoORADKDe0AiOLVx4aoGiDbhM4sdDC42qCaD4VySTQRbMMJo4auqw(gOOWbEhfCiFEhtxu4aJEAOeEbRFLnMGdOH2EHdAP22kqxu4a64jrmVSsrhCWBCaD8KiMxwPfXskIOqhCyn0271ly9y9ORADKDe0AiOLVx4aoGiDbhM4sdDC42qCaDCnW086cuwqhCakilFduu4aVJcoKpVJPlkCGrpnucVG1VYgtWbKVx4GwQTTc0ffoGoEseZlRu0bh8ghqhpjI5LvArSKIik0bhwdT9E9cw)kBmbhwDVWbTuBBfOlkCaD8KiMxwPOdo4noGoEseZlR0IyjfruOdoSgA796fSESETwCPHUOWbTchsMpTHdKH78cwp4qgUZbicoSERyP5aebiGgarWrSKIikanGddoUaNeC2hh8KiMx4jdo3HjQkVFeErSKIikCqNoCiz(SvQIjXr44G24aAGtY8PnWzIlIPgdvLLEYDyVqxaoaHnaicoILuerbObCyWXf4KGJNeX8cpzW5omrv59JWlILuerHdFXHK5ZwPkMehHJd)4aAGtY8PnWHZ6hCmuvFC6cWbiGmaebhXskIOa0aom44cCsWzFCWtIyEHNm4ChMOQ8(r4fXskIOWHV4qY8zRuftIJWXHvGdihCsMpTboCw)GJHQ6JtxaoabKdqeCsMpTbo8(rQW2bhXskIOa0aCacRcqeCsMpTbokHnX0hdvLQjo4iwsrefGgGdCWrj38rCaIaeqdGi4iwsrefGgWrjCgCw8PnWbDzVf2ZffoiBfOgCWNOGdoDbhsM3qCy44qUnhssrKc4KmFAdC4lcHujnBtGdqydaIGtY8PnWHLes9ke6pZfi4iwsrefGgGdqazaicojZN2aNCVLQ3Co4iwsrefGgGdqa5aebNK5tBGJs22pynMOgg4iwsrefGgGdqyvaIGJyjfruaAaNK5tBGdljKAY8PTkz4o4qgUxTmkGtFVvumfWbiOvaebhXskIOa0aom44cCsWH1nr17Sc)fJTvvsSTHvDnW08cuI5yCCyf4aYXHV4W(4GRbMMxHsQ0aoChomhGaAGtY8PnWb(SAY8PTkz4o4qgUxTmkGJRbMMxxGYcWbiGSbqeCelPiIcqd4WGJlWjbhxdmnVcLuPbC4oCyoab0aNK5tBGd8z1K5tBvYWDWHmCVAzuah(lgBR6AGP5ahGGwgarWrSKIikanGddoUaNeCyDtu9oRWFXyBvLeBByvxdmnVaLyoghh0ghqo6XbD6WH7GIUxHsmhJJdRahyDtu9oRWFXyBvLeBByvxdmnVaLyoghhqch2yvWjz(0g4WFXyB1TdrUJykGdqyLdqeCsMpTboSKqQkOKkUNKnfihCelPiIcqdWbiGg6bicoILuerbObCyWXf4KGduUqHtpPic4KmFAdCuDhboab0qdGi4KmFAdCusSTHv5oumuoDWrSKIikanahGaABaqeCsMpTboudr4S(brjvQosjqo4iwsrefGgGdqanKbGi4iwsrefGgWHbhxGtcojZNTsvmjochh0ghqdh(Id7JdEseZl8KbN7WevL3pcViwsrefo8fhOE3Bz3qu1jUWlCpzBIdA)JdAfo8fhOE3BX1atZlQENHdFXbw3evVZk8xm2wvjX2gw11atZlqjMJXXbTXHvbNK5tBGZexinFAd4aeqd5aebhXskIOa0aom44cCsWjz(SvQIjXr44G24Wg4WxCG6DVLDdrvN4cVW9KTjoO9poOv4WxCG6DVfxdmnVO6Dg4KmFAdCM4cP5tBahGaARcqeCelPiIcqd4WGJlWjbhE)ivo9eQWHFCyvCqNoCG6DVftC6cSU0qpjL3c4KmFAdCONMQ23kQhrLgWbiGMwbqeCelPiIcqd4WGJlWjbhE)ivo9eQWbT)XbKbh(IdSUjQENv4VySTQsITnSQRbMMxGsmhJJdAJdBGEC4loSgoW6MO6DwH)IX2QBhIChXufOeZX44G24WQ4GoD4W(4GNeX8c)fJTv3oe5oIPkILuerHdRJdFXbw3evVZkSKqQkOKkUNKnfiVaLyoghh0gh2aCsMpTbo0ttv7Bf1JOsd4aeqdzdGi4iwsrefGgWHbhxGtcoRHdSERyP5ftyWM0qfoOthoW6TILMxSbfDVEtbhwhh(Id7JdEseZlM40fyDPHEskILuerboChomhGaAGtY8PnWHLesnz(0wLmChCid3RwgfWH1Bflnh4aeqtldGi4iwsrefGgWHbhxGtcouV7TOKyBdRYAOuGsYCC4loW7hPYPNqfoScCa5GtY8PnWrjX2OAIdCacOTYbicoILuerbObCyWXf4KGdRBIQ3zf(lgBRQKyBdR6AGP5fOeZX44as4aRBIQ3zf(lgBRQKyBdR6AGP5f1dM(0goOnoChu09kuI5yCCqNoC4oOO7vOeZX44WkWbw3evVZk8xm2wvjX2gw11atZlqjMJXXbKWb0wfCsMpTboOGtShOuVcb1lHkGdqyd0dqeCsMpTbopUuhxICWrSKIikanahGWgObqeCelPiIcqd4WGJlWjbhQ39w2nevDIl8c3t2M4G24aA4WxCG6DVfLeBByvwdLc3t2M4WkWbKbCsMpTbol9obw5Zc92aoaHn2aGi4KmFAdC49Ju5oC2uahXskIOa0aCacBGmaebhXskIOa0aojZN2ahwsi1K5tBvYWDWHmCVAzuahwVvS0CGdqydKdqeCsMpTboC6PQ3vPAIdoILuerbOb4ahCwGcRJuPdqeGaAaebhXskIOa0aojZN2aNRqQQoow6tBGJs4m4S4tBGd6YElSNlkCGsUnuWbwhPshhOeuJXl4GwNXKfNJdwB7HEcJ3hbhsMpTXXH2iAkGddoUaNeC8jk4G24a6XHV4W(4WI4LKmBfGdqydaIGtY8PnWH)IX2QxHG6Lqf4iwsrefGgGdqazaicoILuerbObCyWXf4KGd17El7gIQoXfEH7jBtCqBCanC4loq9U3IsITnSkRHsH7jBtCyf)4WgGtY8PnWzP3jWkFwO3gWbiGCaIGJyjfruaAahgCCboj4Sgoq1CooOthoKmFAROKyBunXlSK74WpoGECyDC4loW7hPYPNqfhhwboGCWjz(0g4OKyBunXboWbh(lgBR6AGP5aebiGgarWrSKIikanGddoUaNeC49Ju50tOch(XHvbNK5tBGd90u1(wr9iQ0aoaHnaicoILuerbObCyWXf4KGd17Elkj22WQSgkL3co8fhwdh8KiMxusSTHvzTXFXfFARiwsrefoOthoq9U3IjoDbwxAONKIQ3z4W6GtY8PnWrjX2OAIdoKXKktboBGEGdqazaicoILuerbObCyWXf4KGd17El7gIQoXfEH7jBtCajCymwhhdvDIlCCyf4aYXHV4WA4GNeX8IsITnSkRn(lU4tBfXskIOWbD6WbQ39wmXPlW6sd9Kuu9odhwhCsMpTboC6PQ3vPAIdoKXKktboBGEGdqa5aebNK5tBGdk4e7bk1Rqq9sOcCelPiIcqdWbiSkarWjz(0g4WFXyB1TdrUJykWrSKIikanahGGwbqeCsMpTboSKqQkOKkUNKnfihCelPiIcqdWbiGSbqeCsMpTbo0ttv7Bf1JOsdCelPiIcqdWbiOLbqeCelPiIcqd4WGJlWjbhQ39wusSTHvznukVfC4loq9U3IjoDbwxAONKYBbh(IdRHdRHduV7TSDiYDetvGsmhJJdAJdRId60Hd7JdEseZl8xm2wD7qK7iMQiwsrefoSoo8fhwdhOE3BbfCI9aL6viOEjuvGsmhJJdAJdRId60HduV7TGcoXEGs9keuVeQkQENHdRJdRdojZN2ahLeBJQjoWbiSYbicoILuerbObCyWXf4KGd17ElM40fyDPHEskVfC4loSgoSgoq9U3Y2Hi3rmvbkXCmooOnoSkoOthoSpo4jrmVWFXyB1TdrUJyQIyjfru4W64WxCynCG6DVfuWj2duQxHG6LqvbkXCmooOnoSkoOthoq9U3ck4e7bk1Rqq9sOQO6DgoSooSo4KmFAdC49Ju5oC2uaoab0qparWrSKIikanGddoUaNeCOE3BXeNUaRln0ts5TGdFXH1WH1WbQ39w2oe5oIPkqjMJXXbTXHvXbD6WH9XbpjI5f(lgBRUDiYDetvelPiIchwhh(IdRHduV7TGcoXEGs9keuVeQkqjMJXXbTXHvXbD6WbQ39wqbNypqPEfcQxcvfvVZWH1XH1bNK5tBGdNEQ6DvQM4ahGaAObqeCelPiIcqd4KmFAdC4VySTQsITnSQRbMMdokHZGZIpTbojZN24f(lgBR6AGP5i9)zBcNKIi0Azu(DnW08kusLgA3MKN8VpRBIQ3zf(lgBRQKyBdR6AGP5fOKknGddoUaNeC2hh8KiMxusSTHvzTXFXfFARiwsrefoOthoq9U3YUHOQtCHx4EY2ehqchM4cVYxYDMOQQhCmuf(lgBRQKyBdR6AGP54G24aYaCacOTbarWjz(0g4WPNQExLQjo4iwsrefGgGdCWPV3kkMcGiab0aicoILuerbObCyWXf4KGZI4fLeBByvxdmnVKmF2kGtY8PnWHsGCbU5yOaoaHnaicoILuerbObCyWXf4KGd17ElucKlWnhdv5TGd60HdlIxusSTHvDnW08sY8zRGdFXH9XbyYKIdBcbCsMpTbolTpTbCacidarWrSKIikanGddoUaNeCweVOKyBdR6AGP5LK5ZwbCsMpTbouKUv17dQb4aeqoarWrSKIikanGddoUaNeCweVOKyBdR6AGP5LK5ZwbCsMpTbo3bkuKUvah4GJRbMMxxGYcaracObqeCelPiIcqd4KmFAdCuDhbhYysLPahKb9ahGWgaebNK5tBGJjoDbwxAONeWrSKIikanahGaYaqeCelPiIcqd4WGJlWjbhE)ivo9eQWHFCyvWjz(0g4GcoXEGs9keuVeQaoabKdqeCelPiIcqd4WGJlWjbhE)ivo9eQWHFCa54WxCynCyFCWtIyEbfCI9aL6viOEjuvelPiIch0PdhyDtu9oRGcoXEGs9keuVeQkqjMJXXH1bNK5tBGd)fJTv3oe5oIPaoaHvbicoILuerbObCyWXf4KGZ(4GNeX8ck4e7bk1Rqq9sOQiwsrefoOthoW6MO6DwbfCI9aL6viOEjuvGsmhJdojZN2ahwsivfusf3tYMcKdCacAfarWrSKIikanGddoUaNeCOE3BrjX2gwL1qP8wWHV4aVFKkNEcv4WkWbKJdFXH1WbpjI5fLeBByvwB8xCXN2kILuerHd60HduV7TyItxG1Lg6jPO6DgoSo4KmFAdCusSnQM4ahGaYgarWrSKIikanGddoUaNeC49Ju50tOchwboSkoShCa54aYkoq9U3IjoDbwxAONKYBbCsMpTbo8(rQChoBkahGGwgarWrSKIikanGddoUaNeC49Ju50tOchwboSkoShCa54aYkoq9U3IjoDbwxAONKYBbCsMpTboC6PQ3vPAIdCacRCaIGJyjfruaAahLWzWzXN2aNK5tB8IRbMMxxGYcs)F2MWjPicTwgLFxdmnVcLuPH2Tj5j)ObojZN2ah6PPQ9TI6ruPbCGdCWjFo9gcoNjQLaoWbaa]] )

    spec:RegisterPack( "Demonology", 20210317, [[devgcbqivr8iqvUKQOkTjqPpHkzuQc5ukLYQeujELGYSei3ssPSlL8ljjdduXXafltPKNjjLPjOQRjPKTPkQ8nvHQXjjvohsPY6eOmpvb3dvSpqL(NGkjhePKSquPEiOQAIGQsUOKu1grkXhrkLrIus1jLuQwPaEPQOkMPQiDtKsv7eP4NGQIHcQk1svfkpvvnvLIRkOsQTkOs9vbvmwbQoRQOQAVi(RqdgQdRyXOQhtQjtYLj2ms(Ss1OfKtt1QvfvLxlPy2OCBj2nLFl1WvLoosjLLd8Citx01bz7sQ(UKy8kLQZJunFvrz)QmbgYgYxnPqOzl4SfmWPAW84lyQUQbh4uDKFs)vi)3rxZSlKVnfH8HVKsBnR3Pt(VdDwpkYgYh1qaTq(HZayTUMddF5iDduhU2o8MqsdORbdv62o5Zd5SS2ncp5RMui0SfC2cg4unyE8fmvhCODHhgYh9kAcnB9Cph5hYvkXi8KVsqAYh(skT1SEN(HdNbWADnxaA)a0HommpEqhEl4SfmxGla8hASDbfSlqTDyAVa2f1HrDro8lq0DHFYdpM6WqPZ8K(HhD6THomfOlh(7f4)W0k47NUUa12HP9Jso8g6GXYdRhuo8m5Wvcj2Hd3otOCXuhUbhMwe2o0auh2rhMAym32pCtrf0HL6ID4kEgQHYdx7Lx0I8zokrKnKV1XkoJcikuejj0lzdHgyiBiFXgEMOiCt(Jo92iFeuP0wSUZekxmf5ReKg4VP3g5ttFyAd4fAH2c2Hp8g6GXYdl1fa9dt7GtqhoCtlhwQla6ho816WirViFnWtb4d5NdtSCHGkL2I1DMq5IPwIn8mrDyyp8JoSUBMQRyleuP0wujL2CDmPdglxaPmUHo8dhgMQD4N9SdR7MP6k2cbvkTfvsPnxht6GXYfqkJBOdd3dh(AD4TrscnBr2q(In8mrr4M81apfGpKVUBMQRyleuP0wujL2CDmPdglxaPmUHo8dhgg4q(Jo92iF9Wyrfqgfkhwncarsss(whR4mkGOqXDQ9issOxYgcnWq2q(In8mrr4M8hD6Tr(7aV0oqIucBhAakYxjinWFtVnYN2aEHwOTGD4n0bJLhwQla6hgMTGtqhoCtlh2TAJxYkIyhUINHo8VHyh(X6Cr(AGNcWhYx3nt1vSfcQuAlQKsBUoM0bJLlGug3qh(HddtTijHMTiBiFXgEMOiCt(AGNcWhYphMy5cbvkTfR7mHYftTeB4zI6WWE4hD4hDyD3mvxXwiOsPTOskT56yshmwUaszCdD4hommBDyypSUBMQRyRDGxAhirkHTdna1ciLXn0HF4WWaNdVTd)SNDyD3mvxXw7aV0oqIucBhAaQfqkJBOdd3dhE4C4Tr(Jo92iFeuP0wSUZekxmfjj0unYgYxSHNjkc3KVg4Pa8H81DZuDfBHGkL2IkP0MRJjDWy5ciLXn0HF4WWahYF0P3g5RhglQaYOq5WQraisssYp0BmbUvdISHqdmKnKVydptueUjFBkc5JCJcIf3zJYNSbOOu4zsH8hD6Tr(i3OGyXD2O8jBakkfEMuijHMTiBiFXgEMOiCt(2ueYh5gfeloOxhmwIIsHNjfYF0P3g5JCJcIfh0RdglrrPWZKcjjj5JEfTpSycCRgjrKneAGHSH8fB4zIIWn5RbEkaFi)CyILlLuAZ1rDBiOYB6TTeB4zI6WWEyD3mvxXwiOsPTOskT56yshmwUaszCdD4ho8wWH8hD6Tr(6HXIJo92ImhLKpZrz0MIq(HEJjWTAqKKqZwKnKVydptueUj)rNEBKVuEPdKHfBGYgtlKVg4Pa8H81DZuDfBHGkL2IkP0MRJjDWy5ciLXn0HF4WWulY3MIq(s5LoqgwSbkBmTqscnvJSH8fB4zIIWn5p60BJ8rneJjz62EeaXtN81apfGpKVUBMQRyleuP0wujL2CDmPdglxaPmUHo8dh(XjFBkc5JAigtY0T9iaINojjj5N0bJLrKKqVKneAGHSH8fB4zIIWn5RbEkaFiFD3mvxXwiOsPTOskT56yshmwUaszCdD4ho8wWH8hD6Tr(MKHeq8Tb5WijHMTiBiFXgEMOiCt(AGNcWhYhazcvd2LvfNrbefkI8DNfBQic6vaEdIiOsPn32xIn8mrr(Jo92iF9WyXrNEBrMJsYN5OmAtri)koJcikuejj0ljj0unYgYxSHNjkc3KVg4Pa8H8FYHbqMq1GDzvXzuarHIiF3zXMkIGEfG3GicQuAZT9Lydptuhg2d)KdNdtSCTd8s7ajsjSDObOwIn8mrr(Jo92iF9WyXrNEBrMJsYN5OmAtriFRJvCgfquOissOxssOj8KnKVydptueUjFnWtb4d5)KddGmHQb7YQIZOaIcfr(UZInveb9kaVbreuP0MB7lXgEMOomShohMy5Ah4L2bsKsy7qdqTeB4zII8hD6Tr(6HXIJo92ImhLKpZrz0MIq(whR4mkGOqXDQ9issOxsssYVIZOaIcfrsc9s2qObgYgYxSHNjkc3K)OtVnYFh4L2bsKsy7qdqr(kbPb(B6Tr(Whtlh(vahU4gukb7WC77h(dvkTHomCpCTxErhgUhEdDWyj5RbEkaFi)CyILRDGxAhirkHTdna1sSHNjQdd7H1DZuDfBHGkL2IkP0MRJjDWy5ciLXn0HF4WWuDKKqZwKnKVydptueUjFnWtb4d5NdtSCHGkL2I1DMq5IPwIn8mrDyypSUBMQRyleuP0wujL2CDmPdglxaPmUHo8dhgMAr(Jo92iFeuP0wSUZekxmfjj0unYgYxSHNjkc3KVg4Pa8H81DZuDfBHGkL2IkP0MRJjDWy5ciLXn0HF4WWSf5p60BJ81dJfvazuOCy1iaejjj5)ceDx4NKSHqdmKnKVydptueUjFnWtb4d5NEromCpmComSh(jh(vY1W86c5p60BJ8Pewu1f3M0BJKeA2ISH8hD6Tr(iOsPTiLW2HgGI8fB4zIIWnjj0unYgYF0P3g5tXeuinyOsYxSHNjkc3KKqt4jBiFXgEMOiCt(AGNcWhYNhIIAvXzQOxErluo6AomCpmmhg2dZdrrTusPnxh1nqwOC01C4h4C4Ti)rNEBK)BxrarK)gQnssOPwKnKVydptueUjFnWtb4d5)OdZ3i0HF2Zo8OtVTLskTX3SCPhuEyohgohEBhg2dJAiwefAak0HF4WHN8hD6Tr(kP0gFZsssO55iBiFXgEMOiCt(AGNcWhYh1qSik0auOd)WHRf5p60BJ8rHgvxjY3SKKKK8PCgtaiYgcnWq2q(In8mrr4M81apfGpKpFJqhg2dt57HYiqkJBOd)WHR2wK)OtVnYFh4L2bsKsy7qdqrscnBr2q(In8mrr4M81apfGpKpFJqhg2dt57HYiqkJBOd)WHRgCi)rNEBKpcQuAlw3zcLlMIKeAQgzd5l2WZefHBYxd8ua(q(8ncDyypmLVhkJaPmUHo8dhgMAr(Jo92iFeuP0wujL2CDmPdgljjHMWt2q(In8mrr4M81apfGpKpQHyruObOomNdxlYF0P3g5hAmvSPI7qm1yKKqtTiBiFXgEMOiCt(AGNcWhYh1qSik0auhgUCoC1omSh(rh(vYLciJcLdRgbSgD61Ld)SND4xjxkP0MRJjDWy5A0Pxxo82i)rNEBKFOXuXMkUdXuJrscnphzd5l2WZefHBYxd8ua(q(OgIfrHgG6WWLZHH5WWEyEikQLjzibeFBqoSf0l5p60BJ8dnMk2uXDiMAmssO5XjBiFXgEMOiCt(AGNcWhYNhIIAPKsBUoQBGSaYOZdd7HrnelIcna1HF4WHN8hD6Tr(kP0gFZsssOP6iBi)rNEBKpQHyruc8AeYxSHNjkc3KKqdTJSH8hD6Tr(OqJQRe5Bws(In8mrr4MKKK8vc1aXsYgcnWq2q(In8mrr4M8vcsd830BJ8R(TlAOuuhwQla6ho9IC4mKC4rNn4Wo6Wt9XzdptwK)OtVnYh9kmwK16AijHMTiBi)rNEBKVEySiLWcbzPaiFXgEMOiCtscnvJSH8hD6Tr(Z2Ly2ie5l2WZefHBssOj8KnK)OtVnYxj1BiqSm7UM8fB4zIIWnjj0ulYgYxSHNjkc3K)OtVnYxpmwC0P3wK5OK8zokJ2ueYx31fBSmo8oZt6KKqZZr2q(In8mrr4M8hD6Tr(6HXIJo92ImhLKpZrz0MIq(Oxr7dlMa3Qrsejj084KnKVydptueUj)rNEBKVEyS4OtVTiZrj5ZCugTPiKFshmwgrsc9sscnvhzd5l2WZefHBYxd8ua(q(8quuRkotf9YlAHYrxZHd7WE5ffrVtfturfeWT9fcQuAlQKsBUoM0bJLhgUhUAhg2dZdrrTuazuOCy1ia0c69WWEyEikQLciJcLdRgbGwaPmUHo8dho8h(zp7W8quuRDGxAhirkHTdna1c69WWEyEikQ1oWlTdKiLW2HgGAbKY4g6WW9WBD4WLdhAqPCyypmpef1Ah4L2bsKsy7qdqTaszCdD4hoC4p8ZE2H5HOOw1DMq5IPwqVhg2dZdrrTQ7mHYftTaszCdDy4E4ToC4YHdnOuomShMhIIAv3zcLlMAbKY4g6WpC4Wt(Jo92iFeuP0wujL2CDmPdgljjHgAhzd5l2WZefHBYxd8ua(q(VsUusPnxht6GXY1OtVUq(Jo92iF9WyXrNEBrMJsYN5OmAtriFfeWT9yshmwsscnWahYgYxSHNjkc3KVg4Pa8H8FYHbqMq1GDzvXzuarHIiF3zXMkIGEfG3GicQuAZT9Lydptuhg2dR7MP6k2cbvkTfvsPnxht6GXYfqkJBOdd3dt7i)rNEBKVskT56ikbITNHijHgyGHSH8fB4zIIWn5RbEkaFiFD3mvxXwiOsPTOskT56yshmwUaszCdDy4E4TGd5p60BJ81dJfvazuOCy1iaejj0aZwKnKVydptueUjFnWtb4d5dekGGcn8mH8hD6Tr(QUlKKqdmvJSH8fB4zIIWn5RbEkaFiFEikQvfNPIE5fTq5OR5WW9WWCyypComXY1BxrarK)gQTLydptuhg2dZdrrTusPnxh1nqwOC01Cyohgohg2d)Kd)k5sbKrHYHvJawJo96c5p60BJ8F7kciI83qTrscnWeEYgYF0P3g5Z7mbPBiWUe57cVaqKVydptueUjjHgyQfzd5l2WZefHBYxd8ua(q(Jo96sumP4c6WW9WWCyyp8toComXYfA0aNY1IkIAigAj2WZe1HH9W8quuRkotf9YlAHYrxZHHlNdxDhg2dZdrrTs6GXYLQRyhg2dR7MP6k2cbvkTfvsPnxht6GXYfqkJBOdd3dxlYF0P3g57LxwJ82ijHgyEoYgYxSHNjkc3KVg4Pa8H8hD61LOysXf0HH7H36WWEyEikQvfNPIE5fTq5OR5WWLZHRUdd7H5HOOwjDWy5s1vSdd7HFYHbqMq1GDz5LxwJ86s8TtXsFylXgEMOi)rNEBKVxEznYBJKeAG5XjBiFXgEMOiCt(AGNcWhYF0PxxIIjfxqhgUhERdd7H5HOOwvCMk6Lx0cLJUMddxoh(5omShMhIIA5LxwJ86s8TtXsFylGug3qh(HdV1HH9WaitOAWUS8YlRrEDj(2PyPpSLydptuK)OtVnY3lVSg5TrscnWuDKnKVydptueUjFnWtb4d5)k5sjL2CDmPdglxJo96c5p60BJ8Hqs0tPGijHgyODKnKVydptueUj)rNEBKVEyS4OtVTiZrj5ZCugTPiKpLZycarsss(6UUyJLXH3zEsNSHqdmKnKVydptueUj)rNEBKpQHyrqNKVsqAG)MEBKp3dsomeA2LGD4QVUaOF4n0bJLhgjj07I81apfGpKpQHy8UPw7GUUeDRUV3Gj92wIn8mrDyypSUBMQRyleuP0wujL2CDmPdglxaPmUHo8dhEl4qscnBr2q(In8mrr4M8hD6Tr(OgIfbDs(kbPb(B6Tr(HJNHomT4ctD4M6WCZAeQlOGo8Zhekp8B)Eypp8GomQB7Wd6WBOdglpSJom07I81apfGpKpQHy8UPwuUWuXMkYZAeQlOLydptuhg2d)k5sjL2CDmPdglxJo96cjj0unYgYxSHNjkc3K)OtVnYh1qSiOtYxjinWFtVnYpC8m0HPnGxAhihMwe2o0auhEm1HT(WHJZOaIIluWomTEZuhEdDWy5HPAWHL6cG(HPnGxOfA7WJPoCBYHlnqomeA2Ld3uh(3qSd)yDEy3QnEjRiITiFnWtb4d5)KddGmHQb7YQIZOaIcfr(UZInveb9kaVbreuP0MB7lXgEMOomShohMy5Ah4L2bsKsy7qdqTeB4zI6WWEyD3mvxXw7aV0oqIucBhAaQfqkJBOdd3dhE4qscnHNSH8fB4zIIWn5p60BJ8rnelc6K8vcsd830BJ8dhpdD4NNgm0TGD4aqO8Wqi5WEE4kHetQlGf5RbEkaFiFudX4DtTQ4mvmeKLXC0PRrlXgEMOijHMAr2q(In8mrr4M8hD6Tr(kr7LjDBpY3SK8vcsd830BJ8PLgC4AvBWuTN3d7wEyGVhkp8qLc4WBOdglxKVg4Pa8H8rneJ3n1IjJkYtpkBFkVmzj2WZe1HH9WVsUusPnxht6GXY1OtVUqscnphzd5l2WZefHBYF0P3g5ReTxM0T9iFZsYxjinWFtVnYh(KHeWHPr0GM1a1HrneJ3nfAr(AGNcWhY)jhg1qmE3ulMmQip9OS9P8YKLydptuhg2d)Kd)k5sjL2CDmPdglxJo96cjj084KnKVydptueUj)rNEBKps3qa32JPNHeYxjinWFtVnYh(wyZEJc2H1dkpCBm6hUsiXo8g6GXYd7Odp60Rlho7dlgccihUmOua0pmpef1HB7WBOdgldxr(AGNcWhYh1qmE3ulDx4NmweLNt6TTeB4zI6WWE4xjxkP0MRJjDWy5A0PxxijHMQJSH8fB4zIIWn5p60BJ8r6gc42Em9mKq(kbPb(B6Tr(0(XTuSX0YHvDE4odjGkoswKVg4Pa8H8FYHrneJ3n1s3f(jJfr55KEBlXgEMOijHgAhzd5p60BJ89YRyk32J6jhuc63qc5l2WZefHBsssYxbbCBpM0bJLKneAGHSH8hD6Tr(8cajGACBN8fB4zIIWnjj0Sfzd5p60BJ85zDRIuqa6KVydptueUjjHMQr2q(Jo92iFkhi8SUvKVydptueUjjHMWt2q(Jo92i)3o92iFXgEMOiCtscn1ISH8hD6Tr(kP0MRJOei2EgI8fB4zIIWnjj08CKnK)OtVnYhcjrpLcI8fB4zIIWnjjjjj)6ca5TrOzl4SfmWPAWeEYVYam32rKF4qREmAQDAOTGD4dVjKCyV82G8Wun4WCHEfTpSycCRgjrCDyGqRb5arDyuxKdpqzxMuuhwhASDbTUap1n5WWeSdd)TvxaPOomx5WelxbNRdN9H5khMy5k4lXgEMO46WpcMTVT1f4ceo0QhJMANgAlyh(WBcjh2lVnipmvdomxjDWyzejj0lxhgi0Aqoquhg1f5Wdu2Ljf1H1HgBxqRlWtDto8wb7WWFB1fqkQdZfaYeQgSlRGZ1HZ(WCbGmHQb7Yk4lXgEMO46WtE4Qh(80d)iy2(2wxGN6MC4QfSdd)TvxaPOomxaitOAWUScoxho7dZfaYeQgSlRGVeB4zIIRd)iy2(2wxGN6MC4WhSdd)TvxaPOomxaitOAWUScoxho7dZfaYeQgSlRGVeB4zIIRd)iy2(2wxGlq4qREmAQDAOTGD4dVjKCyV82G8Wun4WCP76InwghEN5jDUomqO1GCGOomQlYHhOSltkQdRdn2UGwxGN6MCyyc2HH)2QlGuuhMludX4DtTcoxho7dZfQHy8UPwbFj2WZefxh(rWS9TTUap1n5WBfSdd)TvxaPOomxOgIX7MAfCUoC2hMludX4DtTc(sSHNjkUo8JGz7BBDbEQBYHRwWom83wDbKI6WCbGmHQb7Yk4CD4SpmxaitOAWUSc(sSHNjkUo8JGz7BBDbEQBYHdFWom83wDbKI6WCHAigVBQvW56WzFyUqneJ3n1k4lXgEMO46WtE4Qh(80d)iy2(2wxGN6MC4AfSdd)TvxaPOomxOgIX7MAfCUoC2hMludX4DtTc(sSHNjkUo8JGz7BBDbEQBYHFUGDy4VT6cif1H5c1qmE3uRGZ1HZ(WCHAigVBQvWxIn8mrX1HFemBFBRlWtDto8JhSdd)TvxaPOomxOgIX7MAfCUoC2hMludX4DtTc(sSHNjkUo8JGz7BBDbEQBYHRUGDy4VT6cif1H5c1qmE3uRGZ1HZ(WCHAigVBQvWxIn8mrX1HN8Wvp85Ph(rWS9TTUaxGWHw9y0u70qBb7WhEti5WE5Tb5HPAWH5sjudel56WaHwdYbI6WOUihEGYUmPOoSo0y7cADbEQBYHHbob7WWFB1fqkQdZfaYeQgSlRGZ1HZ(WCbGmHQb7Yk4lXgEMO46WpcMTVT1f4PUjhgMQfSdd)nai6uuhwO1GgMN0pSoKOR5WuGUCyU4WHRdN9H5Idxh(rWS9TTUap1n5WW8Cb7WWFB1fqkQdZfaYeQgSlRGZ1HZ(WCbGmHQb7Yk4lXgEMO46WtE4Qh(80d)iy2(2wxGN6MCyyE8GDy4VT6cif1H5cazcvd2LvW56WzFyUaqMq1GDzf8LydptuCD4jpC1dFE6HFemBFBRlWfO2lVnif1HHbMdp60B7WmhLO1fG8hOmudi)AprfH8FbnLZeYhEW7WWxsPTM170pC4mawRR5cap4DyA)a0HommpEqhEl4SfmxGla8G3HH)qJTlOGDbGh8oCTDyAVa2f1HrDro8lq0DHFYdpM6WqPZ8K(HhD6THomfOlh(7f4)W0k47NUUaWdEhU2omTFuYH3qhmwEy9GYHNjhUsiXoC42zcLlM6Wn4W0IW2HgG6Wo6WudJ52(HBkQGoSuxSdxXZqnuE4AV8IwxGla8G3HR(TlAOuuhMxOAGCyDx4N8W8YUBO1HPvAT8MOdBTvBHgqHcID4rNEBOd3gJ(6cm60BdTEbIUl8tYHsyrvxCBsVTGCkoPxe4chyFYRKRH51LlWOtVn06fi6UWpzyCQcbvkTfFL8cm60BdTEbIUl8tggNQOyckKgmu5fy0P3gA9ceDx4Nmmov92veqe5VHAliNIdpef1QIZurV8IwOC01axyGLhIIAPKsBUoQBGSq5OR5boBDbgD6THwVar3f(jdJtvkP0gFZYGCkopIVrON9SrNEBlLuAJVz5spOKdC2gSOgIfrHgGc9q4VaJo92qRxGO7c)KHXPkuOr1vI8nldYP4GAiwefAak0d16cCbG3HR(TlAOuuhwQla6ho9IC4mKC4rNn4Wo6Wt9XzdptwxGrNEBioOxHXISwxZfy0P3gkmovPhglsjSqqwkGlWOtVnuyCQA2UeZgHUaJo92qHXPkLuVHaXYS76lWOtVnuyCQspmwC0P3wK5OmiBkchDxxSXY4W7mpPFbgD6THcJtv6HXIJo92ImhLbztr4GEfTpSycCRgjrxGrNEBOW4uLEyS4OtVTiZrzq2ueojDWyzejj07fy0P3gkmovHGkL2IkP0MRJjDWyzqofhEikQvfNPIE5fTq5ORjmV8IIO3PIjQOcc42(cbvkTfvsPnxht6GXs4wny5HOOwkGmkuoSAeaAb9clpef1sbKrHYHvJaqlGug3qpe(N9mEikQ1oWlTdKiLW2HgGAb9clpef1Ah4L2bsKsy7qdqTaszCdb3TcxcnOuGLhIIATd8s7ajsjSDObOwaPmUHEi8p7z8quuR6otOCXulOxy5HOOw1DMq5IPwaPmUHG7wHlHgukWYdrrTQ7mHYftTaszCd9q4VaJo92qHXPk9WyXrNEBrMJYGSPiCuqa32JjDWyzqofNxjxkP0MRJjDWy5A0PxxUaJo92qHXPkLuAZ1ruceBpdfKtX5jaitOAWUSQ4mkGOqrKV7SytfrqVcWBqebvkT52oS6UzQUITqqLsBrLuAZ1XKoySCbKY4gcU0UlWOtVnuyCQspmwubKrHYHvJaqb5uC0DZuDfBHGkL2IkP0MRJjDWy5ciLXneC3coxGrNEBOW4uLQ7sqofhGqbeuOHNjxGrNEBOW4u1BxrarK)gQTGCko8quuRkotf9YlAHYrxdCHb2CyILR3UIaIi)nuBlXgEMOGLhIIAPKsBUoQBGSq5ORHdh4a7tELCPaYOq5WQraRrNED5cm60BdfgNQ4DMG0neyxI8DHxaOlWOtVnuyCQYlVSg5TfKtXz0PxxIIjfxqWfgyFsomXYfA0aNY1IkIAigAj2WZefS8quuRkotf9YlAHYrxdC5uDWYdrrTs6GXYLQRyWQ7MP6k2cbvkTfvsPnxht6GXYfqkJBi4wRlWOtVnuyCQYlVSg5TfKtXz0PxxIIjfxqWDly5HOOwvCMk6Lx0cLJUg4YP6GLhIIAL0bJLlvxXG9jaitOAWUS8YlRrEDj(2PyPpSlWOtVnuyCQYlVSg5TfKtXz0PxxIIjfxqWDly5HOOwvCMk6Lx0cLJUg4Y55GLhIIA5LxwJ86s8TtXsFylGug3qpSfSaitOAWUS8YlRrEDj(2PyPpSlWOtVnuyCQccjrpLckiNIZRKlLuAZ1XKoySCn60RlxGrNEBOW4uLEyS4OtVTiZrzq2ueouoJja0f4cm60BdTs6GXYissOxoMKHeq8Tb5WcYP4O7MP6k2cbvkTfvsPnxht6GXYfqkJBOh2coxGrNEBOvshmwgrsc9ggNQ0dJfhD6TfzokdYMIWPIZOaIcfrsc9gKtXbazcvd2LvfNrbefkI8DNfBQic6vaEdIiOsPn32VaJo92qRKoySmIKe6nmovPhglo60BlYCugKnfHJ1XkoJcikuejj0BqofNNaGmHQb7YQIZOaIcfr(UZInveb9kaVbreuP0MB7W(KCyILRDGxAhirkHTdna1sSHNjQlWOtVn0kPdglJijHEdJtv6HXIJo92ImhLbztr4yDSIZOaIcf3P2JijHEdYP48eaKjunyxwvCgfquOiY3DwSPIiOxb4niIGkL2CBh2CyILRDGxAhirkHTdna1sSHNjQlWf4cap4DyAQDAJwFZHPfAv1FbG3H5EqYHHqZUeSdx91fa9dVHoyS8WijHExxGrNEBOLURl2yzC4DMN05GAiwe0zqofhudX4DtT2bDDj6wDFVbt6TbRUBMQRyleuP0wujL2CDmPdglxaPmUHEyl4CbG3HdhpdDyAXfM6Wn1H5M1iuxqbD4NpiuE43(9WEE4bDyu32Hh0H3qhmwEyhDyO31fy0P3gAP76InwghEN5j9W4ufQHyrqNb5uCqneJ3n1IYfMk2urEwJqDbb7RKlLuAZ1XKoySCn60Rlxa4D4WXZqhM2aEPDGCyAry7qdqD4Xuh26dhooJcikUqb7W06ntD4n0bJLhMQbhwQla6hM2aEHwOTdpM6WTjhU0a5WqOzxoCtD4FdXo8J15HDR24LSIi26cm60BdT0DDXglJdVZ8KEyCQc1qSiOZGCkopbazcvd2LvfNrbefkI8DNfBQic6vaEdIiOsPn32HnhMy5Ah4L2bsKsy7qdqTeB4zIcwD3mvxXw7aV0oqIucBhAaQfqkJBi4gE4CbG3HdhpdD4NNgm0TGD4aqO8Wqi5WEE4kHetQlG1fy0P3gAP76InwghEN5j9W4ufQHyrqNb5uCqneJ3n1QIZuXqqwgZrNUgDbUaWdEhMMQh(Fm4ZtHppg81faEW7WvFrm)cap4D4W1i32pmTWeuinyOYd)8bHYdt1GdNHKdxRN3dhsgwg6W8quuhEm1HZqIDy9yAH52(HD0HhDcnmg9dphw9IomRrO1faEW7WJo92qlDxxSXY4W7mpPhgNQOyckKgmuzqofhudX4DtTyYOI80JY2NYltGv3nt1vSfcQuAlQKsBUoM0bJLlGug3qpSfCUaWdEhE0P3gAP76InwghEN5j9W4uLEmTWIJo92cYP4m60BBrXeuinyOYLo0yMWCB)caVdtln4W1Q2GPApVh2T8WaFpuE4HkfWH3qhmwUUaJo92qlDxxSXY4W7mpPhgNQuI2lt62EKVzzqofhudX4DtTyYOI80JY2NYltG9vYLskT56yshmwUgD61Lla8om8jdjGdtJObnRbQdJAigVBk06cm60BdT0DDXglJdVZ8KEyCQsjAVmPB7r(MLb5uCEcQHy8UPwmzurE6rz7t5LjW(KxjxkP0MRJjDWy5A0PxxUaxa4bVd)888)y1oTIMla8om8TWM9gfSdRhuE42y0pCLqID4n0bJLh2rhE0PxxoC2hwmeeqoCzqPaOFyEikQd32H3qhmwgU6cm60BdT0DDXglJdVZ8KEyCQcPBiGB7X0ZqsqofhudX4DtT0DHFYyruEoP3gSVsUusPnxht6GXY1OtVUCbG3HP9JBPyJPLdR68WDgsavCKSUaJo92qlDxxSXY4W7mpPhgNQq6gc42Em9mKeKtX5jOgIX7MAP7c)KXIO8CsVTlWfaEW7WH7QNMn06p)p2HRTdxPbzOdRhu62EqhMhkpS1hgr3eWo9dNHMKl0HR0Gm0Hd1mLB7h2ZlWOtVn0s31fBSmo8oZt6HXPkV8kMYT9OEYbLG(nKCbUaxa4Dy4JPLd)kGdxCdkLGDyU99d)HkL2qhgUhU2lVOdd3dVHoyS8cm60BdTQ4mkGOqrKKqVC2bEPDGePe2o0aub5uCYHjwU2bEPDGePe2o0aulXgEMOGv3nt1vSfcQuAlQKsBUoM0bJLlGug3qpat1DbgD6THwvCgfquOissO3W4ufcQuAlw3zcLlMkiNItomXYfcQuAlw3zcLlMAj2WZefS6UzQUITqqLsBrLuAZ1XKoySCbKY4g6byQ1fy0P3gAvXzuarHIijHEdJtv6HXIkGmkuoSAeakiNIJUBMQRyleuP0wujL2CDmPdglxaPmUHEaMTUaxa4DyA6dtBaVql0wWo8H3qhmwEyPUaOFyAhCc6WHBA5WsDbq)WHVwhgj61fy0P3gAzDSIZOaIcfrsc9YbbvkTfR7mHYftfKtXjhMy5cbvkTfR7mHYftTeB4zIc2hP7MP6k2cbvkTfvsPnxht6GXYfqkJBOhGPAp7z6UzQUITqqLsBrLuAZ1XKoySCbKY4gcUHVwB7cm60BdTSowXzuarHIijHEdJtv6HXIkGmkuoSAeakiNIJUBMQRyleuP0wujL2CDmPdglxaPmUHEag4CbUaW7W0gWl0cTfSdVHoyS8WsDbq)WWSfCc6WHBA5WUvB8swre7Wv8m0H)ne7WpwNRlWOtVn0Y6yfNrbefkUtThrsc9Yzh4L2bsKsy7qdqfKtXr3nt1vSfcQuAlQKsBUoM0bJLlGug3qpatTUaJo92qlRJvCgfquO4o1Eejj0ByCQcbvkTfR7mHYftfKtXjhMy5cbvkTfR7mHYftTeB4zIc2h9iD3mvxXwiOsPTOskT56yshmwUaszCd9amBbRUBMQRyRDGxAhirkHTdna1ciLXn0dWaNT9SNP7MP6k2Ah4L2bsKsy7qdqTaszCdb3WdNTDbgD6THwwhR4mkGOqXDQ9issO3W4uLEySOciJcLdRgbGcYP4O7MP6k2cbvkTfvsPnxht6GXYfqkJBOhGboxGlWOtVn0c9kAFyXe4wnsI4Ohglo60BlYCugKnfHtO3ycCRguqofNCyILlLuAZ1rDBiOYB6TbRUBMQRyleuP0wujL2CDmPdglxaPmUHEyl4CbgD6THwOxr7dlMa3QrsuyCQccjrpLsq2ueos5LoqgwSbkBmTeKtXr3nt1vSfcQuAlQKsBUoM0bJLlGug3qpatTUaJo92ql0RO9HftGB1ijkmovbHKONsjiBkchudXysMUThbq80dYP4O7MP6k2cbvkTfvsPnxht6GXYfqkJBOhE8lWfy0P3gAf6nMa3QbfgNQGqs0tPeKnfHdYnkiwCNnkFYgGIsHNjLlWOtVn0k0BmbUvdkmovbHKONsjiBkchKBuqS4GEDWyjkkfEMuUaxGrNEBOLcc42EmPdgl5WlaKaQXT9lWOtVn0sbbCBpM0bJLHXPkEw3QifeG(fy0P3gAPGaUTht6GXYW4ufLdeEw3QlWOtVn0sbbCBpM0bJLHXPQ3o92UaJo92qlfeWT9yshmwggNQusPnxhrjqS9m0fy0P3gAPGaUTht6GXYW4ufesIEkf0f4cap4Dy47(9W8((HrqLsBOdxjKyhMY3dLh2rhE4BO8WzFyXuRlWOtVn0IYzmbG4Sd8s7ajsjSDObOcYP4W3ieSu(EOmcKY4g6HQT1fy0P3gAr5mMaqHXPkeuP0wSUZekxmvqofh(gHGLY3dLrGug3qpun4CbgD6THwuoJjauyCQcbvkTfvsPnxht6GXYGCko8ncblLVhkJaPmUHEaMADbUaWdEhMwPtOHDykNXea6cm60BdTOCgtaOW4uvOXuXMkUdXuJfKtXb1qSik0auCQ1fy0P3gAr5mMaqHXPQqJPInvChIPgliNIdQHyruObOGlNQb7JELCPaYOq5WQraRrNED5zp7vYLskT56yshmwUgD61LTDbgD6THwuoJjauyCQk0yQytf3HyQXcYP4GAiwefAak4Ybgy5HOOwMKHeq8Tb5WwqVxGrNEBOfLZycafgNQusPn(MLb5uC4HOOwkP0MRJ6gilGm6ewudXIOqdq9q4VaJo92qlkNXeakmovHAiweLaVg5cm60BdTOCgtaOW4ufk0O6kr(MLKKKeca]] )


end
