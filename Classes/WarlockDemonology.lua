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


    spec:RegisterPack( "Demonology", 20210628.1, [[dGeKCbqieP6rkPuxsjrztQI(KssJIe6uKiRsjr6vKKMfjLBjbAxs6xsOgMschtvQLrI6zkPyAKaUgjOTjb03KayCKa5CQsuToejnpvjDpQk7tc6GQsuwOsQEiIetujLCrLevFujr0jLa0kvkntePStsQ(jjqzOKavlvjr4PimvsIVQkrmwvjSxk9xsnyGdRyXuLhJYKr1LH2Ss8zQQgTe50IEnIy2u52uSBHFl1WvQoUQePLd65inDIRRQ2Ue13vkgVQW5ruZxcz)QS9TvflbFe0QUYRq53ROavwbvvEnkqbqzfAjeY7OLyFyKm(rlrmg0sSwOPJ21(jBj2hYUE4wvSe0(dzOLGinKILW7NoPagwplbFe0QUYRq53ROavwbvvEnkqbqzlbDhzw1vUalqlrPKZXW6zj4iLzjwl00r7A)KpWlzGUMrYTTKi7usT4I9NsPVxL1MIPP57gj7GbNfPyAAyfFB3(d8akRGu7akVcLFFBVTKsPj8Jus92wWdqSJo3biTMrs92wWdOGfoYhaIS2yWGFG1cnD41o5a7qSGS24nYbYLdKYbs6bYGktihqXgEGsdKZgQCGLgEaVMsrQs1BBbpGcEVbHhGi3l1XbgNR3G8dSdXcYAJ3ihq6dSdB2bYGktihyTqthETtQ32cEaf8Yk4hqghgYbYqqi8VlvlHlPc1QILG66nAbMbjOqTQyv)TvflbgJNd521TedtYoSe0(7COiz4xd)EKTemykimhlbRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGxpGmq)Ou5jvMGHhO4dOWd88asAWdu4bkpWC8CyDjHurlKHtiAjn4bk4bu8aYa9JsLNuzcgEGIpGcpGswIymOLG2FNdfjd)A43JSvSQRSvflbgJNd521TedtYoSe0F456MRhdkLitflbdMccZXsW62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5h41did0pkvEsLjy4bk(ak8appGKg8afEGYdmhphwxsiv0cz4eIwsdEGcEafpGmq)Ou5jvMGHhO4dOWdOKLigdAjO)WZ1nxpgukrMkwXQ(ASQyjWy8Ci3UULGJugm3LSdlHcgKhtWWduAOhyoWBLpafzDWpahDd5dmb)aj9asjeIlnepaLKCFh5hyPHhyjHu5aQqgoHCaPpGld8a)9dSjLshqkHhaIuXseJbTeOzNmehNUH8ycgAjyWuqyowcw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKji)aVEafpGmq)Ou5jvMGHhO4dOWdO0bu9aVv(appaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGcpGIhqXdO4bKb6hLkpPYem8afFafEaLoGQh4TYhqPduWd8wHhqPd88asAWdu4bkpWC8CyDjHurlKHtiAjn4bk4bu8akEazG(rPYtQmbdpqXhqHhqPdO6bER8buYsmmj7WsGMDYqCC6gYJjyOvSILO0UwGzqc1QIv93wvSeymEoKBx3seJbTe0mw(oTF3WZrAivJgphASedtYoSe0mw(oTF3WZrAivJgphASIvDLTQyjWy8Ci3UULigdAjOzS8D6HUNWjeQgnEo0yjgMKDyjOzS8D6HUNWjeQgnEo0yfRyjyDzmMq0Jx6sHSvfR6VTQyjWy8Ci3UULGbtbH5yjO935LbV6h2LrDgLt)nCKSJkgJNd5h45bu8aSUD8EtuPFJPdnhnDKmTqgoHuHOzYGQXh7itq(bE9akVIduurhG1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYpqHhynR4akzjgMKDyjO93PHTyfR6kBvXsGX45qUDDlbdMccZXsq7VZldEDjrhx3lApxtPTHwXy8Ci)appWokvoA6izAHmCcPomjlJwIHjzhwcA)DAylwXQ(ASQyjWy8Ci3UULGbtbH5yjO935LbVUjDCDPFiAzysYOvmgphYTedtYoSe0(70WwSIvDfWQILaJXZHC76wcgmfeMJLG2FNxg8QdhU2JSgFmMDhwXy8Ci)appGIhyhLkhnDKmTqgoHuhMKLXd88a0(700sdKFGxpGYhOOIoaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGcpGcSIdOKLyys2HLGJS0msg(1ETtSIvDfAvXsGX45qUDDlbdMccZXsq6hG2FNxg8QdhU2JSgFmMDhwXy8Ci)appaPFGDuQC00rY0cz4esDyswgTedtYoSeCKLMrYWV2RDIvSQxGwvSeymEoKBx3sWGPGWCSe0(78YGxzTXBeTb5Pms2rfJXZH8d88a7Ou5OPJKPfYWjK6WKSmAjgMKDyjOS(dZWVwsPeAfR6faRkwcmgphYTRBjyWuqyowcs)a0(78YGxzTXBeTb5Pms2rfJXZHClXWKSdlbL1Fyg(1skLqRyvxbzvXsGX45qUDDlbdMccZXsSJsLJMosMwidNqQdtYY4bEEaA)DAAPbYpGVdSclXWKSdlrA2XGNHFnBKHkWEVeAfRyjeYWjenfL)UvfR6VTQyjWy8Ci3UULGbtbH5yjyD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8d86bERqlXWKSdlrGsjeQ3BOmoRyvxzRkwcmgphYTRBjyWuqyowcw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKji)aVEG3fGduWdO4bgMKDuPFJPdnhnDKmTqgoHuXhi7lOwsdEavpWWKSJkT0W7nAV2jv8bY(cQL0GhqPd88akEaw3oEVjQSX50CioCQmosqiTcrZKb9aVEG3fGduWdO4bgMKDuPFJPdnhnDKmTqgoHuXhi7lOwsdEavpWWKSJk9BmDOlNoCjXGxXhi7lOwsdEavpWWKSJkT0W7nAV2jv8bY(cQL0GhqPduurhyhLkhIdNkJJeewHOzYGEGcpaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFavpWWKSJk9BmDO5OPJKPfYWjKk(azFb1sAWdOKLyys2HLWpmnDcr9c68)hi3kw1xJvflbgJNd521TemykimhlHIhG1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYpWRh4TcpqbpGIhyys2rL(nMo0C00rY0cz4esfFGSVGAjn4bu6appGIhG1TJ3BIkBConhIdNkJJeesRq0mzqpWRh4TcpqbpGIhyys2rL(nMo0C00rY0cz4esfFGSVGAjn4bu9adtYoQ0VX0HUC6WLedEfFGSVGAjn4bu6afv0b2rPYH4WPY4ibHviAMmOhOWdW62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5hq1dmmj7Os)gthAoA6izAHmCcPIpq2xqTKg8akDaLoqrfDafpaPFa4pWLg6hRBs3ce5unn9NoDVOP)DeMnut)gthz4VIX45q(bEEaw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKji)afEafyfhqjlXWKSdlb9BmDOlNoCjXGBfR6kGvflbgJNd521TemykimhlbRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGxpWBLpqbpGIhyys2rL(nMo0C00rY0cz4esfFGSVGAjn4bu9adtYoQ0sdV3O9ANuXhi7lOwsdEaLoWZdiPbpqHhO8aZXZH1LesfTqgoHOL0GhOGh4TYwIHjzhwc24CAoehovghjiKAfR6k0QILaJXZHC76wcgmfeMJLqsdEGcpq5bMJNdRljKkAHmCcrlPbpWZdO4b2rPYH4WPY4ibH1Hjzz8appWokvoehovghjiScrZKb9afEGHjzhv63y6qZrthjtlKHtiv8bY(cQL0GhqPd88akEas)aY4WqQ0VX0HUC6WLedEfJXZH8duurhyhLA50Hljg86WKSmEaLoWZdO4bO93PPLgi)a(oWkoqrfDafpWokvoehovghjiSomjlJh45b2rPYH4WPY4ibHviAMmOh41dmmj7Os)gthAoA6izAHmCcPIpq2xqTKg8aQEGHjzhvAPH3B0ETtQ4dK9fulPbpGshOOIoGIhyhLA50Hljg86WKSmEGNhyhLA50Hljg8kentg0d86bgMKDuPFJPdnhnDKmTqgoHuXhi7lOwsdEavpWWKSJkT0W7nAV2jv8bY(cQL0GhqPduurhqXd49xwQ(HPPtiQxqN))a51)(bEEaV)Ys1pmnDcr9c68)hiVcrZKb9aVEGHjzhv63y6qZrthjtlKHtiv8bY(cQL0Ghq1dmmj7Osln8EJ2RDsfFGSVGAjn4bu6akzjgMKDyjOFJPdnhnDKmTqgoHyfRyj44Y8DIvfR6VTQyjWy8Ci3UULGJugm3LSdlXk)bY(cYpawgHKpGKg8asj8adtA4bs6bMYt6gphwTedtYoSe0D050UMrIvSQRSvflXWKSdlbBCo9c6k9dbHwcmgphYTRBfR6RXQILyys2HLyEGAPPulbgJNd521TIvDfWQILyys2HLGJL7puBg)jZsGX45qUDDRyvxHwvSeymEoKBx3smmj7WsWgNtpmj7q7sQyjCjv0XyqlHaZGeuOwXQEbAvXsGX45qUDDlbdMccZXsaXfislnEo0smmj7WsW72yfR6faRkwcmgphYTRBjyWuqyowcA)DEzWR(HDzuNr50Fdhj7OIX45q(bkQOdq7VZldEDjrhx3lApxtPTHwXy8Ci)afv0bO935LbVYAJ3iAdYtzKSJkgJNd5hOOIoaRlJXesnqgSDnKBjOcmzIv93wIHjzhwc24C6HjzhAxsflHlPIogdAjyDzmMq0Jx6sHSvSQRGSQyjWy8Ci3UULyys2HLGnoNEys2H2LuXs4sQOJXGwcHmCcrtr5VBfR6VCRkwcmgphYTRBjyWuqyowcfpaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGxpW7vCGNhqsdEGcpq5bMJNdRljKkAHmCcrlPbpqbpW7vCGIk6a0(78YGxH4sgixVpUrWkgJNd5h45byD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8d86bwJc6akzjgMKDyj2Bj7Wkw1FVcRkwcmgphYTRBjyWuqyowIDuQC00rY0cz4esDyswgTeubMmXQ(BlXWKSdlbBCo9WKSdTlPILWLurhJbTeTFg3kw1F)2QILaJXZHC76wcgmfeMJLqXdq6ha(dCPH(X6M0Tarovtt)Pt3lA6FhHzd10VX0rg(RymEoKFGNhG1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYpqHh4LFaLoqrfDafpWokvoA6izAHmCcPomjlJh45b2rPYrthjtlKHtiviAMmOh41duGhyLEa)mE1mpoGswIHjzhwcoA6izAQaXWVuYkw1FRSvflbgJNd521TemykimhlbRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGcpGYR4af8ak8aR0dq6ha(dCPH(X6M0Tarovtt)Pt3lA6FhHzd10VX0rg(RymEoKBjgMKDyjyJZP5qC4uzCKGqQvSQ)EnwvSeymEoKBx3sWGPGWCSeE)LL6M0X1PzNwPYWi5afEG3h45b8(llvoA6izAwdXkvggjh41dSglXWKSdlXEVbHAAUxQdRyv)TcyvXsGX45qUDDlbdMccZXs49xwQcz4esL3BId88aSUD8EtuPFJPdnhnDKmTqgoHuHOzYGQXh7itq(bk8ak0smmj7Ws4LoKY6p0pQ9AJhcPwXQ(BfAvXsGX45qUDDlbdMccZXsmmjlJAmqtI0du4bEFavpGIh49bwPhqghgsLomyUKmKRP93rRymEoKFaLoWZd49xwQBshxNMDALkdJKduOVduGh45b8(llvHmCcPY7nXbEEaw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKji)afEafAjgMKDyjsZURPzhwXQ(7c0QILaJXZHC76wcgmfeMJLyyswg1yGMePhOWdO8bEEaV)YsDt6460StRuzyKCGc9DGc8appG3FzPkKHtivEVjoWZdW62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5hOWdOWd88aK(bG)axAOFSMMDxtZYOEVfmKCCvmgphYpWZdO4bi9diJddPUaBJwkHAAPH3BOvmgphYpqrfDaV)YsDb2gTuc10sdV3qR)9dOKLyys2HLin7UMMDyfR6VlawvSeymEoKBx3sWGPGWCSedtYYOgd0Ki9afEaLpWZd49xwQBshxNMDALkdJKduOVduGh45b8(ll10S7AAwg17TGHKJRcrZKb9aVEaLpWZda)bU0q)ynn7UMMLr9Elyi54QymEoKFGNhqXdq6hqghgsLJMosMM1b9B2LSJkgJNd5hOOIoGIhW7VSufYWjKkV3eh45byD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8du4bu4bu6akzjgMKDyjsZURPzhwXQ(BfKvflbgJNd521TemykimhlH3FzPUjDCDA2PvQmmsoqH(oWBLpWZdiJddPs7VtZ6G)tPIX45q(bEEazCyi1fyB0sjutln8EdTIX45q(bEEa4pWLg6hRPz310SmQ3BbdjhxfJXZH8d88aE)LLQqgoHu59M4appaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGcpGcTedtYoSePz310SdRyv)9l3QILaJXZHC76wcgmfeMJLqsdQLwZt8aVEG1SclXWKSdlHFyA6eI6f05)pqUvSQR8kSQyjWy8Ci3UULGbtbH5yjK0GAP18epWRhqzfKLyys2HLG(nMo0LthUKyWTIvDLFBvXsGX45qUDDlbdMccZXsiPb1sR5jEGxpWBfAjgMKDyjOFJPdnhnDKmTqgoHyfR6kRSvflbgJNd521TemykimhlbT)onT0a5hW3buOLyys2HLO0eCDVO9)D8jSIvDLxJvflbgJNd521TedtYoSeLMGR7fT)VJpHLGJugm3LSdlrbC5aRfehovghjiKEGbIhyCqC4KpWWKSmQ2bI(abI8di9bOtz8a0sdKtTemykimhlbT)onT0a5hOqFhynh45bu8a7Ou5qC4uzCKGW6WKSmEGIk6a7Ou5OPJKPfYWjK6WKSmEaLSIvDLvaRkwcmgphYTRBjyWuqyowcA)DAAPbYpqH(oW7d88aE)LLAGsjeQ3BOmU6F)appaRBhV3ev24CAoehovghjiKwHOzYGEGcpGYhyLEa)mE1mpSedtYoSeLMGR7fT)VJpHvSQRScTQyjWy8Ci3UULGbtbH5yjO93PPLgi)af67aVpWZdW62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5h41d4NXRM5XbEEajn4bk8aLhyoEoSUKqQOfYWjeTKg8af8a(z8QzEyjgMKDyjknbx3lA)FhFcRyvx5c0QILaJXZHC76wcgmfeMJLG0paRlJXesTmgsjYqlbvGjtSQ)2smmj7WsWgNtpmj7q7sQyjCjv0XyqlbRlJXeIE8sxkKTIvDLlawvSeymEoKBx3smmj7Wsq7VttfyscAj4iLbZDj7Ws8ssPu)LdqmmyUKmKFaI(7OQDaI(7oaHatsWdK0dqfyh(r4bKstCG1cnD41orTdq7dKYbkn0dmhOu6VecpWomBykKTemykimhlbPFazCyiv6WG5sYqUM2FhTIX45qUvSQRScYQILaJXZHC76wIHjzhwcoA6WRDILGJugm3LSdlbXog8dSwOPJKDasPHi9aln8ae93DaIsdKtpWpK0DavidNqoaRBhV3ehiPhG5AkEaPpaehozlbdMccZXs49xwQC00rY0SgIviom5appaT)onT0a5h41dOah45byD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8du4buEfwXQUYVCRkwcmgphYTRBjgMKDyj4OPdV2jwcoszWCxYoSeR1hMH)dOcz4eYbOO83v7a0Dm4hyTqthj7aKsdr6bwA4bi6V7aeLgiNAjyWuqyowcV)YsLJMosMM1qScXHjh45bO93PPLgi)aVEaf4appaRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKFGxpWBLTIv91ScRkwcmgphYTRBjyWuqyowcV)YsLJMosMM1qScXHjh45bO93PPLgi)aVEaf4appGIhW7VSu5OPJKPzneRuzyKCGcpGYhOOIoGmomKkDyWCjzixt7VJwXy8Ci)akzjgMKDyj4OPdV2jwXQ(AEBvXsGX45qUDDlbdMccZXs49xwQC00rY0SgIviom5appaT)onT0a5h41dOah45bgMKLrngOjr6bk8aVTedtYoSeC00Hx7eRyvFnkBvXsmmj7Wsq7VttfyscAjWy8Ci3UUvSQVM1yvXsGX45qUDDlXWKSdlbBCo9WKSdTlPILWLurhJbTeSUmgti6XlDPq2kw1xJcyvXsGX45qUDDlXWKSdlrPj46Er7)74tyj4iLbZDj7Wsuaxoa5(Fa2ehWpkhWByKCaPpGcpar)DhGO0a50d4HlnepWAbXHtLXrccPhG1TJ3BIdK0daXHtwTdKYQ0d0KmKpG0hGUJb)asj0CGO3yjyWuqyowcA)DAAPbYpqH(oWAoWZdW62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5hOWdOScpWZdO4bKXHHu5OPJKPzJZLH)kgJNd5hOOIoaRBhV3ev24CAoehovghjiKwHOzYGEGcpGIhqXdOWduWdq7Vttlnq(bu6aR0dmmj7Osln8EJ2RDsfFGSVGAjn4bu6aQEGHjzh1stW19I2)3XNOIpq2xqTKg8akzfR6RrHwvSeymEoKBx3smmj7WsW72yjyWuqyowciUarAPXZHh45bK0GhOWduEG545W6scPIwidNq0sAqlbJmZHAzG(rHAv)TvSQVMc0QILyys2HLGwA49gTx7elbgJNd521TIvSe7qK1gVrSQyv)TvflbgJNd521TedtYoSelOtZBtgJKDyj4iLbZDj7WsSYFGSVG8d4HlnepaRnEJCap0Fg06bEzmgUl0deDuWsd0S8Dhyys2b9aD4ixTemykimhlHKg8afEGvCGNhG0pWok1XLLrRyvxzRkwIHjzhwc63y6qVGo))bYTeymEoKBx3kw1xJvflbgJNd521TemykimhlH3FzPUjDCDA2PvQmmsoqHh49bEEaV)YsLJMosMM1qSsLHrYbE13bu2smmj7WsS3BqOMM7L6Wkw1vaRkwcmgphYTRBjyWuqyowcfpGxtPhOOIoWWKSJkhnD41oPYgQCaFhyfhqPd88a0(700sdKtpWRhqbSedtYoSeC00Hx7eRyvxHwvSeymEoKBx3sWGPGWCSeK(bu8aEnLEGIk6adtYoQC00Hx7KkBOYb8DGvCaLoqrfDaA)DAAPbYPhOWdSglXWKSdlbT0W7nAV2jwXQEbAvXsGX45qUDDlrVBjOOyjgMKDyjkpWC8COLO84(OL4TYwIYduhJbTeljKkAHmCcrlPbTIvSecmdsqHAvXQ(BRkwcmgphYTRBjyWuqyowczCyivoA6izAwh0VzxYoQymEoKFGNhG1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYpWRhq5vyjgMKDyjyJZPhMKDODjvSeUKk6ymOLO0UwGzqc1kw1v2QILaJXZHC76wcoszWCxYoSeR8LfKj0diLg5acCkJUdqD9gh5di9bKb6hLdaXx6pH4bgopLSJXP2bO4(ahbpqPj4Um8BjgMKDyjyJZPhMKDODjvSeUKk6ymOLG66nAbMbjOqTIv91yvXsGX45qUDDlXWKSdlrxgHlUEtg(1tKMrZg)OLGbtbH5yj2rPYrthjtlKHti1Hjzz0seJbTeDzeU46nz4xprAgnB8JwXQUcyvXsGX45qUDDlbdMccZXsiWmibLQ8UwAO6pf1E)LLd88a7Ou5OPJKPfYWjK6WKSmAjgMKDyjeygKGYBRyvxHwvSeymEoKBx3sWGPGWCSecmdsqPkkxlnu9NIAV)YYbEEGDuQC00rY0cz4esDyswgTedtYoSecmdsqrzRyvVaTQyjWy8Ci3UULGbtbH5yjK0GhOWduEG545W6scPIwidNq0sAqlXWKSdlbBCo9WKSdTlPILWLurhJbTe7FiQ5Jz8JAbMbjuRyflX(hIA(yg)OwGzqc1QIv93wvSeymEoKBx3seJbTeCio8LeI6YiLIolXWKSdlbhIdFjHOUmsPOZkw1v2QILaJXZHC76wIymOLG2FNo9hPGqlXWKSdlbT)oD6psbHwXQ(ASQyjWy8Ci3UULyys2HLWVJ8EjDVOhknnPBKSdlbdMccZXsmmjlJAmqtI0d47aVTeXyqlHFh59s6ErpuAAs3izhwXQUcyvXsGX45qUDDlrmg0sWhijMUdnhzKO3)cePmmyOLyys2HLGpqsmDhAoYirV)fiszyWqRyflr7NXTQyv)TvflXWKSdlHhcPiKKm8BjWy8Ci3UUvSQRSvflXWKSdlHNRBUE5djBjWy8Ci3UUvSQVgRkwIHjzhwILeIEUU5wcmgphYTRBfR6kGvflXWKSdlXNI6uqd1sGX45qUDDRyfRyjkJqA2HvDLxHYVxrbQScYsSzGrg(PwIxYlBLq9cO6RKK6boGkLWdKM9gkhyPHhyvQR3OfygKGcD1daXx6pHi)a02Ghy(sBgb5hGvAc)iTEBjTmWd8MupaP0rzeki)aePHuoaLCiZJdSYoG0hG0(Zb4z5KMDCGEhHJ0WdOyXkDafv(Hs1BlPLbEaLj1dqkDugHcYparAiLdqjhY84aRSdi9biT)CaEwoPzhhO3r4in8akwSshqrLFOu92sAzGhynK6biLokJqb5hGinKYbOKdzECGv2bK(aK2FoaplN0SJd07iCKgEaflwPdO4AEOu92EBFjVSvc1lGQVssQh4aQucpqA2BOCGLgEGvzDzmMq0Jx6sH8QhaIV0Fcr(bOTbpW8L2mcYpaR0e(rA92sAzGh4nPEasPJYiuq(bwL2FNxg86lw9asFGvP935LbV(IkgJNd5REafF)qP6TL0YapGYK6biLokJqb5hyvA)DEzWRVy1di9bwL2FNxg86lQymEoKV6bu89dLQ3wsld8aRHupaP0rzeki)aRs7VZldE9fREaPpWQ0(78YGxFrfJXZH8vpWihyLRGrAhqX3puQEBjTmWdOaK6biLokJqb5hyvA)DEzWRVy1di9bwL2FNxg86lQymEoKV6bu89dLQ3wsld8akKupaP0rzeki)aRs7VZldE9fREaPpWQ0(78YGxFrfJXZH8vpGIVFOu92sAzGhOaj1dqkDugHcYpWQ0(78YGxFXQhq6dSkT)oVm41xuXy8CiF1dO47hkvVTKwg4bkaK6biLokJqb5hyvA)DEzWRVy1di9bwL2FNxg86lQymEoKV6bg5aRCfms7ak((Hs1B7T9L8YwjuVaQ(kjPEGdOsj8aPzVHYbwA4bwvidNq0uu(7REai(s)je5hG2g8aZxAZii)aSst4hP1BlPLbEG1qQhGu6OmcfKFGvH)axAOFS(IvpG0hyv4pWLg6hRVOIX45q(QhqX3puQEBVTVKx2kH6fq1xjj1dCavkHhin7nuoWsdpWQCCz(oz1daXx6pHi)a02Ghy(sBgb5hGvAc)iTEBjTmWduai1dqkDugHcYpWQ0(78YGxFXQhq6dSkT)oVm41xuXy8CiF1dO4AEOu92sAzGh4LtQhGu6OmcfKFGvP935LbV(IvpG0hyvA)DEzWRVOIX45q(QhqX3puQEBjTmWd8(nPEasPJYiuq(bwf(dCPH(X6lw9asFGvH)axAOFS(IkgJNd5REafF)qP6TL0YapWBLj1dqkDugHcYpWQWFGln0pwFXQhq6dSk8h4sd9J1xuXy8CiF1dmYbw5kyK2bu89dLQ3wsld8aVlqs9aKshLrOG8dSk8h4sd9J1xS6bK(aRc)bU0q)y9fvmgphYx9ak((Hs1BlPLbEG3fas9aKshLrOG8dSk8h4sd9J1xS6bK(aRc)bU0q)y9fvmgphYx9ak((Hs1BlPLbEG3kis9aKshLrOG8dSk8h4sd9J1xS6bK(aRc)bU0q)y9fvmgphYx9ak((Hs1B7T9L8YwjuVaQ(kjPEGdOsj8aPzVHYbwA4bwvGzqck0vpaeFP)eI8dqBdEG5lTzeKFawPj8J06TL0YapGcqQhGu6OmcfKFGvfygKGs9D9fREaPpWQcmdsqPkVRVy1dO47hkvVTKwg4buiPEasPJYiuq(bwvGzqckvLRVy1di9bwvGzqckvr56lw9ak((Hs1B7TTaA2BOG8d8YpWWKSJd4sQqR3wlX8Lsn0syj2H9s6qlXAFG1cnD0U2p5d8sgORzKCBx7dusKDkPwCX(tP03RYAtX008DJKDWGZIumnnSIVTR9b2(d8akRGu7akVcLFFBVTR9biLst4hPK6TDTpqbpaXo6ChG0Agj1B7AFGcEafSWr(aqK1gdg8dSwOPdV2jhyhIfK1gVroqUCGuoqspqguzc5ak2WduAGC2qLdS0Wd41uksvQEBx7duWdOG3Bq4biY9sDCGX56ni)a7qSGS24nYbK(a7WMDGmOYeYbwl00Hx7K6TDTpqbpGcEzf8diJdd5aziie(3L6T92U2hyL)azFb5hWdxAiEawB8g5aEO)mO1d8YymCxOhi6OGLgOz57oWWKSd6b6WrUEBhMKDqR7qK1gVru1xXlOtZBtgJKDOwU4tsdw4kEs67OuhxwgVTdtYoO1DiYAJ3iQ6Ry63y6qVJYTDys2bTUdrwB8grvFfV3BqOMM7L6qTCXN3FzPUjDCDA2PvQmmsk89tV)YsLJMosMM1qSsLHrYR(u(2omj7Gw3HiRnEJOQVI5OPdV2jQLl(u0RP0IkAys2rLJMo8ANuzdv8TcLEs7Vttlnqo9vf42omj7Gw3HiRnEJOQVIPLgEVr71orTCXhPROxtPfv0WKSJkhnD41oPYgQ4Bfkvur0(700sdKtlCn32Hjzh06oezTXBev9vC5bMJNdvlgd6BjHurlKHtiAjnOA9UpkkQvECF03BLVT321(aR8hi7li)ayzes(asAWdiLWdmmPHhiPhykpPB8Cy92omj7G6JUJoN21msUTdtYoOQ6Ry24C6f0v6hccVTdtYoOQ6R45bQLMsVTdtYoOQ6RyowU)qTz8NSB7WKSdQQ(kMnoNEys2H2LurTymOpbMbjOqVTdtYoOQ6RyE3g1YfFqCbI0sJNdVTdtYoOQ6Ry24C6HjzhAxsf1IXG(yDzmMq0Jx6sHSAubMmX3B1YfF0(78YGx9d7YOoJYP)gos2rrfr7VZldEDjrhx3lApxtPTHwur0(78YGxzTXBeTb5Pms2rrfX6YymHudKbBxd532Hjzhuv9vmBCo9WKSdTlPIAXyqFcz4eIMIYF)2omj7GQQVI3Bj7qTCXNISUD8EtuPFJPdnhnDKmTqgoHuHOzYGQXh7itq(RVxXtjnyHLhyoEoSUKqQOfYWjeTKgSGVxrrfr7VZldEfIlzGC9(4gbFY62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5VUgfKs32Hjzhuv9vmBCo9WKSdTlPIAXyqFTFgxnQatM47TA5IVDuQC00rY0cz4esDyswgVTdtYoOQ6RyoA6izAQaXWVusTCXNIKo8h4sd9J1nPBbICQMM(tNUx00)ocZgQPFJPJm8)K1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYl8LRurfP4okvoA6izAHmCcPomjlJp3rPYrthjtlKHtiviAMmOVwGRu)mE1mpu62omj7GQQVIzJZP5qC4uzCKGqQA5Ipw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKjiVqLxrbv4kL0H)axAOFSUjDlqKt100F609IM(3ry2qn9BmDKH)B7WKSdQQ(kEV3Gqnn3l1HA5IpV)YsDt6460StRuzyKu47NE)LLkhnDKmnRHyLkdJKxxZTDys2bvvFf7LoKY6p0pQ9AJhcPQLl(8(llvHmCcPY7nXtw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKjiVqfEBhMKDqv1xXPz310Sd1YfFdtYYOgd0KiTW3QQ47vQmomKkDyWCjzixt7VJwXy8CixPNE)LL6M0X1PzNwPYWiPqFf4tV)YsvidNqQ8Et8K1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYluH32Hjzhuv9vCA2Dnn7qTCX3WKSmQXanjslu5NE)LL6M0X1PzNwPYWiPqFf4tV)YsvidNqQ8Et8K1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYluHpjD4pWLg6hRPz310SmQ3Bbdjh3tfjDzCyi1fyB0sjutln8EdTIX45qErf59xwQlW2OLsOMwA49gA9VR0TDys2bvvFfNMDxtZoulx8nmjlJAmqtI0cv(P3FzPUjDCDA2PvQmmsk0xb(07VSutZURPzzuV3cgsoUkentg0xv(j8h4sd9J10S7AAwg17TGHKJ7PIKUmomKkhnDKmnRd63SlzhvmgphYlQif9(llvHmCcPY7nXtw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKjiVqfQKs32Hjzhuv9vCA2Dnn7qTCXN3FzPUjDCDA2PvQmmsk03BLFkJddPs7VtZ6G)tPIX45q(tzCyi1fyB0sjutln8EdTIX45q(t4pWLg6hRPz310SmQ3Bbdjh3tV)YsvidNqQ8Et8K1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYluH32Hjzhuv9vSFyA6eI6f05)pqUA5IpjnOwAnpXxxZkUTdtYoOQ6Ry63y6qxoD4sIbxTCXNKgulTMN4RkRGUTdtYoOQ6Ry63y6qZrthjtlKHtiQLl(K0GAP18eF9TcVTdtYoOQ6R4stW19I2)3XNqTCXhT)onT0a5(u4TDTpqbC5aRfehovghjiKEGbIhyCqC4KpWWKSmQ2bI(abI8di9bOtz8a0sdKtVTdtYoOQ6R4stW19I2)3XNqTCXhT)onT0a5f6BnpvChLkhIdNkJJeewhMKLXIkAhLkhnDKmTqgoHuhMKLrLUTdtYoOQ6R4stW19I2)3XNqTCXhT)onT0a5f679tV)YsnqPec17nugx9V)K1TJ3BIkBConhIdNkJJeesRq0mzqlu5vQFgVAMh32Hjzhuv9vCPj46Er7)74tOwU4J2FNMwAG8c99(jRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeK)QFgVAMhpL0GfwEG545W6scPIwidNq0sAWc6NXRM5XTDys2bvvFfZgNtpmj7q7sQOwmg0hRlJXeIE8sxkKvJkWKj(ERwU4J0zDzmMqQLXqkrgEBx7d8ssPu)LdqmmyUKmKFaI(7OQDaI(7oaHatsWdK0dqfyh(r4bKstCG1cnD41orTdq7dKYbkn0dmhOu6VecpWomBykKVTdtYoOQ6RyA)DAQatsq1YfFKUmomKkDyWCjzixt7VJwXy8Ci)2U2hGyhd(bwl00rYoaP0qKEGLgEaI(7oarPbYPh4hs6oGkKHtihG1TJ3BIdK0dWCnfpG0haIdN8TDys2bvvFfZrthETtulx859xwQC00rY0SgIviom5jT)onT0a5VQapzD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8cvEf321(aR1hMH)dOcz4eYbOO83v7a0Dm4hyTqthj7aKsdr6bwA4bi6V7aeLgiNEBhMKDqv1xXC00Hx7e1YfFE)LLkhnDKmnRHyfIdtEs7Vttlnq(RkWtw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKji)13kFBhMKDqv1xXC00Hx7e1YfFE)LLkhnDKmnRHyfIdtEs7Vttlnq(RkWtf9(llvoA6izAwdXkvggjfQCrfjJddPshgmxsgY10(7OvmgphYv62omj7GQQVI5OPdV2jQLl(8(llvoA6izAwdXkehM8K2FNMwAG8xvGNdtYYOgd0KiTW332Hjzhuv9vmT)onvGjj4TDys2bvvFfZgNtpmj7q7sQOwmg0hRlJXeIE8sxkKVTR9bkGlhGC)paBId4hLd4nmsoG0hqHhGO)UdquAGC6b8WLgIhyTG4WPY4ibH0dW62X7nXbs6bG4WjR2bszv6bAsgYhq6dq3XGFaPeAoq0BUTdtYoOQ6R4stW19I2)3XNqTCXhT)onT0a5f6BnpzD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8cvwHpvughgsLJMosMMnoxg(RymEoKxurSUD8EtuzJZP5qC4uzCKGqAfIMjdAHkQOcliT)onT0a5kTshMKDuPLgEVr71oPIpq2xqTKgujvhMKDulnbx3lA)FhFIk(azFb1sAqLUTdtYoOQ6RyE3g1yKzould0pkuFVvlx8bXfislnEo8PKgSWYdmhphwxsiv0cz4eIwsdEBhMKDqv1xX0sdV3O9ANCBVTdtYoOvQR3OfygKGc13NI6uqJAXyqF0(7COiz4xd)EKvlx8X62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5Vkd0pkvEsLjy4ktHpL0GfwEG545W6scPIwidNq0sAWcQOmq)Ou5jvMGHRmfQ0TDys2bTsD9gTaZGeuOQ6R4pf1PGg1IXG(O)WZ1nxpgukrMkQLl(yD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8xLb6hLkpPYemCLPWNsAWclpWC8CyDjHurlKHtiAjnybvugOFuQ8KktWWvMcv62U2hqbdYJjy4bkn0dmh4TYhGISo4hGJUH8bMGFGKEaPecXLgIhGssUVJ8dS0WdSKqQCavidNqoG0hWLbEG)(b2KsPdiLWdarQCBhMKDqRuxVrlWmibfQQ(k(trDkOrTymOp0StgIJt3qEmbdvlx8X62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5VQOmq)Ou5jvMGHRmfQKQVv(jRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKxOIkQOmq)Ou5jvMGHRmfQKQVvwPc(wHk9usdwy5bMJNdRljKkAHmCcrlPblOIkkd0pkvEsLjy4ktHkP6BLv62EBhMKDqRSUmgti6XlDPq2hT)onSf1YfF0(78YGx9d7YOoJYP)gos2XtfzD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8xvEffveRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeKx4AwHs32Hjzh0kRlJXeIE8sxkKv1xX0(70Wwulx8r7VZldEDjrhx3lApxtPTH(ChLkhnDKmTqgoHuhMKLXB7WKSdAL1LXycrpEPlfYQ6RyA)DAylQLl(O935LbVUjDCDPFiAzysYO32Hjzh0kRlJXeIE8sxkKv1xXCKLMrYWV2RDIA5IpA)DEzWRoC4ApYA8Xy2D4tf3rPYrthjtlKHti1Hjzz8jT)onT0a5VQCrfX62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5fQaRqPB7WKSdAL1LXycrpEPlfYQ6RyoYsZiz4x71orTCXhPt7VZldE1Hdx7rwJpgZUdFs67Ou5OPJKPfYWjK6WKSmEBhMKDqRSUmgti6XlDPqwvFftz9hMHFTKsjuTCXhT)oVm4vwB8grBqEkJKD8ChLkhnDKmTqgoHuhMKLXB7WKSdAL1LXycrpEPlfYQ6RykR)Wm8RLukHQLl(iDA)DEzWRS24nI2G8ugj742omj7GwzDzmMq0Jx6sHSQ(kon7yWZWVMnYqfyVxcvlx8TJsLJMosMwidNqQdtYY4tA)DAAPbY9TIB7TDys2bTwAxlWmiH67trDkOrTymOpAglFN2VB45inKQrJNdn32Hjzh0APDTaZGeQQ(k(trDkOrTymOpAglFNEO7jCcHQrJNdn32B7WKSdAT9Z4(8qifHKKH)B7WKSdAT9Z4Q6Rypx3C9Yhs(2omj7GwB)mUQ(kEjHONRB(TDys2bT2(zCv9v8NI6uqd92EBhMKDqR7FiQ5Jz8JAbMbjuFFkQtbnQfJb9XH4WxsiQlJuk6UTdtYoO19pe18Xm(rTaZGeQQ(k(trDkOrTymOpA)D60FKccVTdtYoO19pe18Xm(rTaZGeQQ(k(trDkOrTymOp)oY7L09IEO00KUrYoulx8nmjlJAmqtIuFVVTdtYoO19pe18Xm(rTaZGeQQ(k(trDkOrTymOp(ajX0DO5iJe9(xGiLHbdVT32Hjzh0QaZGeuO(yJZPhMKDODjvulgd6R0UwGzqcvTCXNmomKkhnDKmnRd63SlzhvmgphYFY62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5VQ8kUTR9bw5llitOhqknYbe4ugDhG66noYhq6did0pkhaIV0FcXdmCEkzhJtTdqX9bocEGstWDz4)2omj7GwfygKGcvvFfZgNtpmj7q7sQOwmg0h11B0cmdsqHEBhMKDqRcmdsqHQQVI)uuNcAulgd6RlJWfxVjd)6jsZOzJFuTCX3okvoA6izAHmCcPomjlJ32Hjzh0QaZGeuOQ6RybMbjO8wTCXNaZGeuQVRLgQ(trT3Fz55okvoA6izAHmCcPomjlJ32Hjzh0QaZGeuOQ6RybMbjOOSA5IpbMbjOuvUwAO6pf1E)LLN7Ou5OPJKPfYWjK6WKSmEBhMKDqRcmdsqHQQVIzJZPhMKDODjvulgd6B)drnFmJFulWmiHQwU4tsdwy5bMJNdRljKkAHmCcrlPbVT32Hjzh0QqgoHOPO839fOucH69gkJtTCXhRBhV3ev63y6qZrthjtlKHtiviAMmOA8XoYeK)6BfEBhMKDqRcz4eIMIYFxvFf7hMMoHOEbD()dKRwU4J1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYF9DbOGkomj7Os)gthAoA6izAHmCcPIpq2xqTKgu1HjzhvAPH3B0ETtQ4dK9fulPbv6PISUD8EtuzJZP5qC4uzCKGqAfIMjd6RVlafuXHjzhv63y6qZrthjtlKHtiv8bY(cQL0GQomj7Os)gth6YPdxsm4v8bY(cQL0GQomj7Osln8EJ2RDsfFGSVGAjnOsfv0okvoehovghjiScrZKbTqw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKjix1Hjzhv63y6qZrthjtlKHtiv8bY(cQL0GkDBhMKDqRcz4eIMIYFxvFft)gth6YPdxsm4QLl(uK1TJ3BIk9BmDO5OPJKPfYWjKkentgun(yhzcYF9TclOIdtYoQ0VX0HMJMosMwidNqQ4dK9fulPbv6PISUD8EtuzJZP5qC4uzCKGqAfIMjd6RVvybvCys2rL(nMo0C00rY0cz4esfFGSVGAjnOQdtYoQ0VX0HUC6WLedEfFGSVGAjnOsfv0okvoehovghjiScrZKbTqw3oEVjQ0VX0HMJMosMwidNqQq0mzq14JDKjix1Hjzhv63y6qZrthjtlKHtiv8bY(cQL0GkPurfPiPd)bU0q)yDt6wGiNQPP)0P7fn9VJWSHA63y6id)pzD749MOs)gthAoA6izAHmCcPcrZKbvJp2rMG8cvGvO0TDys2bTkKHtiAkk)Dv9vmBConhIdNkJJeesvlx8X62X7nrL(nMo0C00rY0cz4esfIMjdQgFSJmb5V(w5cQ4WKSJk9BmDO5OPJKPfYWjKk(azFb1sAqvhMKDuPLgEVr71oPIpq2xqTKguPNsAWclpWC8CyDjHurlKHtiAjnybFR8TDys2bTkKHtiAkk)Dv9vm9BmDO5OPJKPfYWje1YfFsAWclpWC8CyDjHurlKHtiAjn4tf3rPYH4WPY4ibH1Hjzz85okvoehovghjiScrZKbTWHjzhv63y6qZrthjtlKHtiv8bY(cQL0Gk9ursxghgsL(nMo0LthUKyWRymEoKxur7OulNoCjXGxhMKLrLEQiT)onT0a5(wrrfP4okvoehovghjiSomjlJp3rPYH4WPY4ibHviAMmOVomj7Os)gthAoA6izAHmCcPIpq2xqTKgu1HjzhvAPH3B0ETtQ4dK9fulPbvQOIuChLA50Hljg86WKSm(ChLA50Hljg8kentg0xhMKDuPFJPdnhnDKmTqgoHuXhi7lOwsdQ6WKSJkT0W7nAV2jv8bY(cQL0Gkvurk69xwQ(HPPtiQxqN))a51)(tV)Ys1pmnDcr9c68)hiVcrZKb91Hjzhv63y6qZrthjtlKHtiv8bY(cQL0GQomj7Osln8EJ2RDsfFGSVGAjnOskzfRyTa]] )


end
