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


    spec:RegisterPack( "Demonology", 20210628, [[dGuXBbqisqEKsr6skHkBsv0NusmksOtrISkLqPxrsAwKuULKq7sIFPemmLqoMQulJe1ZukQPrcQRrcSnjb9nvjQXjjGZHivADisAEQs6Euv2NKOdIivSqLcperIjQuexuju1hvcfDsjbALkLMjIu2jjv)erQYqrKQAPkHcpfHPss8vvjIXQkH9sP)sQbdCyflMQ8yuMmQUm0MLuFMQQrljDArVgrmBQCBk2TWVLA4kvhxvI0Yb9CKMoX1vvBxj67kPgVQW5ruZxjP9RY23wvSe8rqR6kViLFVOku5kqzrvaLvw5x2siK3rlX(Wiz8JwIymOLytqthTR9t2sSpKD9WTQyjO9hYqlbrAiflH3pDsfmSEwc(iOvDLxKYVxufQCfOSOkGYkRScSe0DKzvx5kScTevtohdRNLGJuMLytqthTR9t(aVKb6Agj32QIStj1fwWFkv)EfwBwGMMVBKSdgCQLfOPHTWTD7pWdO8lR2buErk)(2EBjLQt4hPK6TTIhGyhDUdqAnJKYTTIhG0lCKpaezTXGb)aBcA6WRDYb2HyfzTXBKdK1hiLdK0dKbvMqoGIn8avhiNnu5a1n8aEnLIuLk32kEas)EncparUxTJdmoxVg5hyhIvK1gVroG0hyh2SdKbvMqoWMGMo8ANuUTv8aK(lj9pGmomKdKHGq4FxkwcxsfQvflb11R1cmdsqHAvXQ(BRkwcmgphYTByjgMKDyjO935qrYWVg(9iBjyWuqyowcw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)aVEazG(rPWtQmbdpWchqbh45bK0GhOYdSCG545WsDcPIwidNq0sAWduXdO4bKb6hLcpPYem8alCafCaLSeXyqlbT)ohksg(1WVhzRyvxzRkwcmgphYTByjgMKDyjO)WZ1nxpguQsMkwcgmfeMJLG1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYpWRhqgOFuk8KktWWdSWbuWbEEajn4bQ8alhyoEoSuNqQOfYWjeTKg8av8akEazG(rPWtQmbdpWchqbhqjlrmg0sq)HNRBUEmOuLmvSIv9nBvXsGX45qUDdlbhPmyUlzhwcspipMGHhO6qpWCG3kFakY6GFao6gYhyc(bs6bKQieRBiEakj5(oYpqDdpqDcPYbuHmCc5asFaxg4b(7hyDkvpGufpaePILigdAjqZoziooDd5Xem0sWGPGWCSeSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(bE9akEazG(rPWtQmbdpWchqbhqPdO6bER8bEEaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)avEafpGIhqXdid0pkfEsLjy4bw4ak4akDavpWBLpGshOIh4TcoGsh45bK0GhOYdSCG545WsDcPIwidNq0sAWduXdO4bu8aYa9JsHNuzcgEGfoGcoGshq1d8w5dOKLyys2HLan7KH440nKhtWqRyflr1DTaZGeQvfR6VTQyjWy8Ci3UHLigdAjOzu)DA)UHNJ0qQgnEo0yjgMKDyjOzu)DA)UHNJ0qQgnEo0yfR6kBvXsGX45qUDdlrmg0sqZO(70dDpHtiunA8COXsmmj7WsqZO(70dDpHtiunA8COXkwXsW6LymHOhV0LczRkw1FBvXsGX45qUDdlbdMccZXsq7VZldEXpSxI6mwM(B4izhfmgphYpWZdO4byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8d86buErhy1vpaRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKFGkpWMx0buYsmmj7Wsq7VtdBXkw1v2QILaJXZHC7gwcgmfeMJLG2FNxg8sDIoUUR1EUMsBdTGX45q(bEEGDukC00rY0cz4eszysUeTedtYoSe0(70WwSIv9nBvXsGX45qUDdlbdMccZXsq7VZldEzD646Q)q0YWKKrlymEoKBjgMKDyjO93PHTyfR6kSvflbgJNd52nSemykimhlbT)oVm4fhoCThzn(ym7oSGX45q(bEEafpWokfoA6izAHmCcPmmjxIh45bO93PPvhi)aVEaLpWQREaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)avEafErhqjlXWKSdlbhzPzKm8R9ANyfR6kWQILaJXZHC7gwcgmfeMJLqHoaT)oVm4fhoCThzn(ym7oSGX45q(bEEaf6a7Ou4OPJKPfYWjKYWKCjAjgMKDyj4ilnJKHFTx7eRyvVcTQyjWy8Ci3UHLGbtbH5yjO935LbVWAJ3iAdYtzKSJcgJNd5h45b2rPWrthjtlKHtiLHj5s0smmj7Wsqz9hMHFTKsv0kw1FzRkwcmgphYTByjyWuqyowcf6a0(78YGxyTXBeTb5Pms2rbJXZHClXWKSdlbL1Fyg(1skvrRyvVcyvXsGX45qUDdlbdMccZXsSJsHJMosMwidNqkdtYL4bEEaA)DAA1bYpGVdSilXWKSdlrA2XGNHFnBKHkWEVkAfRyjeYWjenfL)UvfR6VTQyjWy8Ci3UHLGbtbH5yjyD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8d86bERalXWKSdlrGsveQ3BOmoRyvxzRkwcmgphYTByjyWuqyowcw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)aVEG3V8bQ4bu8adtYok0VX0HMJMosMwidNqk4dK9fulPbpGQhyys2rHwD49ATx7Kc(azFb1sAWdO0bEEafpaRBhVxhf24CAoehovghjiKwGOzYGEGxpW7x(av8akEGHjzhf63y6qZrthjtlKHtif8bY(cQL0Ghq1dmmj7Oq)gth6LPdRtm4f8bY(cQL0Ghq1dmmj7OqRo8ET2RDsbFGSVGAjn4bu6aRU6b2rPWH4WPY4ibHfiAMmOhOYdW62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5hq1dmmj7Oq)gthAoA6izAHmCcPGpq2xqTKg8akzjgMKDyj8dttNquxJo))bYTIv9nBvXsGX45qUDdlbdMccZXsO4byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8d86bERGduXdO4bgMKDuOFJPdnhnDKmTqgoHuWhi7lOwsdEaLoWZdO4byD7496OWgNtZH4WPY4ibH0centg0d86bERGduXdO4bgMKDuOFJPdnhnDKmTqgoHuWhi7lOwsdEavpWWKSJc9BmDOxMoSoXGxWhi7lOwsdEaLoWQREGDukCioCQmosqybIMjd6bQ8aSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(bu9adtYok0VX0HMJMosMwidNqk4dK9fulPbpGshqPdS6QhqXdOqha(dSUH(XY60vdrovtt)Pt31A6FhHzd10VX0rg(lymEoKFGNhG1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYpqLhqHx0buYsmmj7Wsq)gth6LPdRtm4wXQUcBvXsGX45qUDdlbdMccZXsW62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5h41d8w5duXdO4bgMKDuOFJPdnhnDKmTqgoHuWhi7lOwsdEavpWWKSJcT6W71AV2jf8bY(cQL0GhqPd88asAWdu5bwoWC8CyPoHurlKHtiAjn4bQ4bERSLyys2HLGnoNMdXHtLXrccPwXQUcSQyjWy8Ci3UHLGbtbH5yjK0GhOYdSCG545WsDcPIwidNq0sAWd88akEGDukCioCQmosqyzysUepWZdSJsHdXHtLXrcclq0mzqpqLhyys2rH(nMo0C00rY0cz4esbFGSVGAjn4bu6appGIhqHoGmomKc9BmDOxMoSoXGxWy8Ci)aRU6b2rPSmDyDIbVmmjxIhqPd88akEaA)DAA1bYpGVdSOdS6QhqXdSJsHdXHtLXrccldtYL4bEEGDukCioCQmosqybIMjd6bE9adtYok0VX0HMJMosMwidNqk4dK9fulPbpGQhyys2rHwD49ATx7Kc(azFb1sAWdO0bwD1dO4b2rPSmDyDIbVmmjxIh45b2rPSmDyDIbVarZKb9aVEGHjzhf63y6qZrthjtlKHtif8bY(cQL0Ghq1dmmj7OqRo8ET2RDsbFGSVGAjn4bu6aRU6bu8aE)66IFyA6eI6A05)pqE5VFGNhW7xxx8dttNquxJo))bYlq0mzqpWRhyys2rH(nMo0C00rY0cz4esbFGSVGAjn4bu9adtYok0QdVxR9ANuWhi7lOwsdEaLoGswIHjzhwc63y6qZrthjtlKHtiwXkwcowpFNyvXQ(BRkwcmgphYTByj4iLbZDj7WsS4FGSVG8dGlri5diPbpGufpWWKgEGKEGz5KUXZHflXWKSdlbDhDoTRzKyfR6kBvXsmmj7WsWgNtxJUQ)qqOLaJXZHC7gwXQ(MTQyjgMKDyjMhOwAk1sGX45qUDdRyvxHTQyjgMKDyj44Y(d1MXFYSeymEoKB3Wkw1vGvflbgJNd52nSedtYoSeSX50dtYo0UKkwcxsfDmg0siWmibfQvSQxHwvSeymEoKB3WsWGPGWCSeqSgI0QJNdTedtYoSe8UnwXQ(lBvXsGX45qUDdlbdMccZXsq7VZldEXpSxI6mwM(B4izhfmgphYpWQREaA)DEzWl1j646Uw75AkTn0cgJNd5hy1vpaT)oVm4fwB8grBqEkJKDuWy8Ci)aRU6by9smMqkbYGTRHClbvGjtSQ)2smmj7WsWgNtpmj7q7sQyjCjv0XyqlbRxIXeIE8sxkKTIv9kGvflbgJNd52nSedtYoSeSX50dtYo0UKkwcxsfDmg0siKHtiAkk)DRyvN01QILaJXZHC7gwcgmfeMJLqXdW62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5h41d8Erh45bK0GhOYdSCG545WsDcPIwidNq0sAWduXd8Erhy1vpaT)oVm4fiwNbY17JBeSGX45q(bEEaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)aVEGnxboGswIHjzhwI9wYoSIv93lYQILaJXZHC7gwcgmfeMJLyhLchnDKmTqgoHugMKlrlbvGjtSQ)2smmj7WsWgNtpmj7q7sQyjCjv0Xyqlr7NXTIv93VTQyjWy8Ci3UHLGbtbH5yju8ak0bG)aRBOFSSoD1qKt100F60DTM(3ry2qn9BmDKH)cgJNd5h45byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8du5biDpGshy1vpGIhyhLchnDKmTqgoHugMKlXd88a7Ou4OPJKPfYWjKcentg0d86bQWdSypGFgVyMhhqjlXWKSdlbhnDKmnvGy4xQAfR6Vv2QILaJXZHC7gwcgmfeMJLG1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYpqLhq5fDGkEafCGf7buOda)bw3q)yzD6QHiNQPP)0P7An9VJWSHA63y6id)fmgphYTedtYoSeSX50CioCQmosqi1kw1FVzRkwcmgphYTByjyWuqyowcVFDDzD6460StluzyKCGkpW7d88aE)66chnDKmnRHyHkdJKd86b2SLyys2HLyVxJqnn3R2HvSQ)wHTQyjWy8Ci3UHLGbtbH5yj8(11fHmCcPW71XbEEaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)avEafyjgMKDyj8shsz9h6h1ETXdHuRyv)TcSQyjWy8Ci3UHLGbtbH5yjgMKlrngOjr6bQ8aVpGQhqXd8(al2diJddPqhgmRtgY10(7OfmgphYpGsh45b8(11L1PJRtZoTqLHrYbQ03bQWd88aE)66IqgoHu4964appaRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKFGkpGcSedtYoSePz310SdRyv)DfAvXsGX45qUDdlbdMccZXsmmjxIAmqtI0du5bu(appG3VUUSoDCDA2PfQmmsoqL(oqfEGNhW7xxxeYWjKcVxhh45byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8du5buWbEEaf6aWFG1n0pwsZURP5suV3cgsoUcgJNd5h45bu8ak0bKXHHuQHTrlvrnT6W710cgJNd5hy1vpG3VUUudBJwQIAA1H3RPL)(buYsmmj7WsKMDxtZoSIv93VSvflbgJNd52nSemykimhlXWKCjQXanjspqLhq5d88aE)66Y60X1PzNwOYWi5av67av4bEEaVFDDjn7UMMlr9Elyi54kq0mzqpWRhq5d88aWFG1n0pwsZURP5suV3cgsoUcgJNd5h45bu8ak0bKXHHu4OPJKPzDq)MDj7OGX45q(bwD1dO4b8(11fHmCcPW71XbEEaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)avEafCaLoGswIHjzhwI0S7AA2HvSQ)UcyvXsGX45qUDdlbdMccZXs49RRlRthxNMDAHkdJKduPVd8w5d88aY4Wqk0(70So4)ukymEoKFGNhqghgsPg2gTuf10QdVxtlymEoKFGNha(dSUH(XsA2DnnxI69wWqYXvWy8Ci)appG3VUUiKHtifEVooWZdW62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5hOYdOalXWKSdlrA2Dnn7Wkw1Ft6AvXsGX45qUDdlbdMccZXsiPb1sR5jEGxpWMxKLyys2HLWpmnDcrDn68)hi3kw1vErwvSeymEoKB3WsWGPGWCSesAqT0AEIh41dOCfWsmmj7Wsq)gth6LPdRtm4wXQUYVTQyjWy8Ci3UHLGbtbH5yjK0GAP18epWRh4TcSedtYoSe0VX0HMJMosMwidNqSIvDLv2QILaJXZHC7gwcgmfeMJLG2FNMwDG8d47akWsmmj7WsuDcUUR1()o(ewXQUYB2QILaJXZHC7gwIHjzhwIQtW1DT2)3XNWsWrkdM7s2HLOcwFGnbIdNkJJeespWaXdmoioCYhyysUev7arFGar(bK(a0zjEaA1bYPwcgmfeMJLG2FNMwDG8duPVdS5d88akEGDukCioCQmosqyzysUepWQREGDukC00rY0cz4eszysUepGswXQUYkSvflbgJNd52nSemykimhlbT)onT6a5hOsFh49bEEaVFDDjqPkc17nugx5VFGNhG1TJ3RJcBConhIdNkJJeeslq0mzqpqLhq5dSypGFgVyMhwIHjzhwIQtW1DT2)3XNWkw1vwbwvSeymEoKB3WsWGPGWCSe0(700QdKFGk9DG3h45byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8d86b8Z4fZ84appGKg8avEGLdmhphwQtiv0cz4eIwsdEGkEa)mEXmpSedtYoSevNGR7AT)VJpHvSQRCfAvXsGX45qUDdlbdMccZXsOqhG1lXycPSedPkzOLGkWKjw1FBjgMKDyjyJZPhMKDODjvSeUKk6ymOLG1lXycrpEPlfYwXQUYVSvflbgJNd52nSedtYoSe0(70ubMKGwcoszWCxYoSeVKuQ2F5aeddM1jd5hGO)oQAhGO)UdqiWKe8aj9aub2HFeEaP6ehytqthETtu7a0(aPCGQd9aZbQM(RIWdSdZgMczlbdMccZXsOqhqghgsHomywNmKRP93rlymEoKBfR6kxbSQyjWy8Ci3UHLyys2HLGJMo8ANyj4iLbZDj7WsqSJb)aBcA6izhGuAispqDdpar)DhGO6a50d8djDhqfYWjKdW62X71Xbs6byUMIhq6daXHt2sWGPGWCSeE)66chnDKmnRHybIdtoWZdq7VttRoq(bE9ak8bEEaw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)avEaLxKvSQRmPRvflbgJNd52nSedtYoSeC00Hx7elbhPmyUlzhwIn5dZW)buHmCc5auu(7QDa6og8dSjOPJKDasPHi9a1n8ae93DaIQdKtTemykimhlH3VUUWrthjtZAiwG4WKd88a0(700QdKFGxpGcFGNhG1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYpWRh4TYwXQ(MxKvflbgJNd52nSemykimhlH3VUUWrthjtZAiwG4WKd88a0(700QdKFGxpGcFGNhqXd49RRlC00rY0SgIfQmmsoqLhq5dS6QhqghgsHomywNmKRP93rlymEoKFaLSedtYoSeC00Hx7eRyvFZVTQyjWy8Ci3UHLGbtbH5yj8(11foA6izAwdXcehMCGNhG2FNMwDG8d86bu4d88adtYLOgd0Ki9avEG3wIHjzhwcoA6WRDIvSQVzLTQyjgMKDyjO93PPcmjbTeymEoKB3Wkw138MTQyjWy8Ci3UHLyys2HLGnoNEys2H2LuXs4sQOJXGwcwVeJje94LUuiBfR6BwHTQyjWy8Ci3UHLyys2HLO6eCDxR9)D8jSeCKYG5UKDyjQG1hGC)paBId4hLd4nmsoG0hqbhGO)UdquDGC6b8W6gIhytG4WPY4ibH0dW62X71Xbs6bG4WjR2bszf6bAsgYhq6dq3XGFaPkAoq0RTemykimhlbT)onT6a5hOsFhyZh45byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8du5buwbh45bu8aY4WqkC00rY0SX5YWFbJXZH8dS6QhG1TJ3RJcBConhIdNkJJeeslq0mzqpqLhqXdO4buWbQ4bO93PPvhi)akDGf7bgMKDuOvhEVw71oPGpq2xqTKg8akDavpWWKSJs1j46Uw7)74tuWhi7lOwsdEaLSIv9nRaRkwcmgphYTByjgMKDyj4DBSemykimhlbeRHiT645Wd88asAWdu5bwoWC8CyPoHurlKHtiAjnOLGrM5qTmq)OqTQ)2kw13CfAvXsmmj7WsqRo8ET2RDILaJXZHC7gwXkwIDiYAJ3iwvSQ)2QILaJXZHC7gwIHjzhwIA0P5TjJrYoSeCKYG5UKDyjw8pq2xq(b8W6gIhG1gVroGh6pdA5aKomgUl0deDuXQd0u)Dhyys2b9aD4ixSemykimhlHKg8avEGfDGNhqHoWokLXLlrRyvxzRkwIHjzhwc63y6qxJo))bYTeymEoKB3Wkw13SvflbgJNd52nSemykimhlH3VUUSoDCDA2PfQmmsoqLh49bEEaVFDDHJMosMM1qSqLHrYbE13bu2smmj7WsS3RrOMM7v7Wkw1vyRkwcmgphYTByjyWuqyowcfpGxtPhy1vpWWKSJchnD41oPWgQCaFhyrhqPd88a0(700QdKtpWRhqHTedtYoSeC00Hx7eRyvxbwvSeymEoKB3Ws07wckkwIHjzhwILdmhphAjwoUpAjERSLy5a1XyqlrDcPIwidNq0sAqRyflHaZGeuOwvSQ)2QILaJXZHC7gwcgmfeMJLqghgsHJMosMM1b9B2LSJcgJNd5h45byD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8d86buErwIHjzhwc24C6HjzhAxsflHlPIogdAjQURfygKqTIvDLTQyjWy8Ci3UHLGJugm3LSdlXIVUgzc9as1roGaNLO7auxV2r(asFazG(r5aq8L(tiEGHZtj7yCQDakUpWrWduDcUld)wIHjzhwc24C6HjzhAxsflHlPIogdAjOUETwGzqckuRyvFZwvSeymEoKB3Wsmmj7Ws0lryTRxNHF9ePz0SXpAjyWuqyowIDukC00rY0cz4eszysUeTeXyqlrVeH1UEDg(1tKMrZg)OvSQRWwvSeymEoKB3WsWGPGWCSecmdsqPiVlvhQ(trT3VU(appWokfoA6izAHmCcPmmjxIwIHjzhwcbMbjO82kw1vGvflbgJNd52nSemykimhlHaZGeukIYLQdv)PO27xxFGNhyhLchnDKmTqgoHugMKlrlXWKSdlHaZGeuu2kw1RqRkwcmgphYTByjyWuqyowcjn4bQ8alhyoEoSuNqQOfYWjeTKg0smmj7WsWgNtpmj7q7sQyjCjv0XyqlX(hIA(yg)OwGzqc1kwXsS)HOMpMXpQfygKqTQyv)TvflbgJNd52nSeXyqlbhIdVoHOEjsPOZsmmj7WsWH4WRtiQxIuk6SIvDLTQyjWy8Ci3UHLigdAjO93Pt)rki0smmj7Wsq7VtN(JuqOvSQVzRkwcmgphYTByjgMKDyj87iVxv316Hstt6gj7WsWGPGWCSedtYLOgd0Ki9a(oWBlrmg0s43rEVQUR1dLMM0ns2HvSQRWwvSeymEoKB3WseJbTe8bsIP7qZrgj69VarkddgAjgMKDyj4dKet3HMJms07FbIuggm0kwXs0(zCRkw1FBvXsmmj7Ws4Hqkcjjd)wcmgphYTByfR6kBvXsmmj7Ws456MRR)qYwcmgphYTByfR6B2QILyys2HLOoHONRBULaJXZHC7gwXQUcBvXsmmj7Ws8POof0qTeymEoKB3WkwXkwILiKMDyvx5fP87fvHk)YwI1dmYWp1s8siDwmuVcQ(IjPEGdOsv8aPzVHYbQB4bwH661AbMbjOqx5aq8L(tiYpaTn4bMV0Mrq(byvNWpsl3wsld8aVj1dqkDSeHcYparAiLdqjhY84alUdi9biT)CaEUmPzhhO3r4in8akUGshqrLFOu52sAzGhqzs9aKshlrOG8dqKgs5auYHmpoWI7asFas7phGNltA2Xb6DeosdpGIlO0buu5hkvUTKwg4b2mPEasPJLiuq(bisdPCak5qMhhyXDaPpaP9NdWZLjn74a9ochPHhqXfu6akU5hkvUT32xcPZIH6vq1xmj1dCavQIhin7nuoqDdpWkSEjgti6XlDPqELdaXx6pHi)a02Ghy(sBgb5hGvDc)iTCBjTmWd8MupaP0Xseki)aRq7VZldE5fRCaPpWk0(78YGxErbJXZH8voGIVFOu52sAzGhqzs9aKshlrOG8dScT)oVm4LxSYbK(aRq7VZldE5ffmgphYx5ak((HsLBlPLbEGntQhGu6yjcfKFGvO935LbV8IvoG0hyfA)DEzWlVOGX45q(khyKdS4j9iTdO47hkvUTKwg4buys9aKshlrOG8dScT)oVm4LxSYbK(aRq7VZldE5ffmgphYx5ak((HsLBlPLbEafqQhGu6yjcfKFGvO935LbV8IvoG0hyfA)DEzWlVOGX45q(khqX3puQCBjTmWduHK6biLowIqb5hyfA)DEzWlVyLdi9bwH2FNxg8YlkymEoKVYbu89dLk3wsld8aVmPEasPJLiuq(bwH2FNxg8Ylw5asFGvO935LbV8IcgJNd5RCGroWIN0J0oGIVFOu52EBFjKolgQxbvFXKupWbuPkEG0S3q5a1n8aRiKHtiAkk)9voaeFP)eI8dqBdEG5lTzeKFaw1j8J0YTL0YapWMj1dqkDSeHcYpWkWFG1n0pwEXkhq6dSc8hyDd9JLxuWy8CiFLdO47hkvUT32xcPZIH6vq1xmj1dCavQIhin7nuoqDdpWkCSE(ozLdaXx6pHi)a02Ghy(sBgb5hGvDc)iTCBjTmWd8YK6biLowIqb5hyfA)DEzWlVyLdi9bwH2FNxg8YlkymEoKVYbuCZpuQCBjTmWdq6sQhGu6yjcfKFGvO935LbV8IvoG0hyfA)DEzWlVOGX45q(khqX3puQCBjTmWd8(nPEasPJLiuq(bwb(dSUH(XYlw5asFGvG)aRBOFS8IcgJNd5RCafF)qPYTL0YapWBLj1dqkDSeHcYpWkWFG1n0pwEXkhq6dSc8hyDd9JLxuWy8CiFLdmYbw8KEK2bu89dLk3wsld8aVRqs9aKshlrOG8dSc8hyDd9JLxSYbK(aRa)bw3q)y5ffmgphYx5ak((HsLBlPLbEG3VmPEasPJLiuq(bwb(dSUH(XYlw5asFGvG)aRBOFS8IcgJNd5RCafF)qPYTL0YapW7kaPEasPJLiuq(bwb(dSUH(XYlw5asFGvG)aRBOFS8IcgJNd5RCafF)qPYT92(siDwmuVcQ(IjPEGdOsv8aPzVHYbQB4bwrGzqck0voaeFP)eI8dqBdEG5lTzeKFaw1j8J0YTL0YapGctQhGu6yjcfKFGveygKGs5D5fRCaPpWkcmdsqPiVlVyLdO47hkvUTKwg4buaPEasPJLiuq(bwrGzqckfLlVyLdi9bwrGzqckfr5Ylw5ak((HsLB7TTcA2BOG8dq6EGHjzhhWLuHwUTwI5lvBOLWsSd760HwIn9aBcA6ODTFYh4LmqxZi52UPhOQi7usDHf8Ns1VxH1MfOP57gj7GbNAzbAAylCB30dS9h4bu(Lv7akViLFFBVTB6biLQt4hPK6TDtpqfpaXo6ChG0AgjLB7MEGkEasVWr(aqK1gdg8dSjOPdV2jhyhIvK1gVroqwFGuoqspqguzc5ak2WduDGC2qLdu3Wd41uksvQCB30duXdq63Rr4biY9QDCGX561i)a7qSIS24nYbK(a7WMDGmOYeYb2e00Hx7KYTDtpqfpaP)ss)diJdd5aziie(3LYT92UPhyX)azFb5hWdRBiEawB8g5aEO)mOLdq6Wy4Uqpq0rfRoqt93DGHjzh0d0HJC52omj7Gw2HiRnEJOQVfQrNM3Mmgj7qTS2NKgSYf9uH2rPmUCjEBhMKDql7qK1gVru13c0VX0HEhLB7WKSdAzhIS24nIQ(wyVxJqnn3R2HAzTpVFDDzD6460StluzyKu57NE)66chnDKmnRHyHkdJKx9P8TDys2bTSdrwB8grvFlWrthETtulR9POxtPRU6WKSJchnD41oPWgQ4Brk9K2FNMwDGC6Rk8TDys2bTSdrwB8grvFlSCG545q1IXG(Qtiv0cz4eIwsdQwV7JIIAlh3h99w5B7TDtpWI)bY(cYpaUeHKpGKg8asv8adtA4bs6bMLt6gphwUTdtYoO(O7OZPDnJKB7WKSdQQ(wGnoNUgDv)HGWB7WKSdQQ(wyEGAPP0B7WKSdQQ(wGJl7puBg)j72omj7GQQVfyJZPhMKDODjvulgd6tGzqck0B7WKSdQQ(wG3TrTS2heRHiT645WB7WKSdQQ(wGnoNEys2H2LurTymOpwVeJje94LUuiRgvGjt89wTS2hT)oVm4f)WEjQZyz6VHJKDS6Q0(78YGxQt0X1DT2Z1uABORUkT)oVm4fwB8grBqEkJKDS6QSEjgtiLazW21q(TDys2bvvFlWgNtpmj7q7sQOwmg0NqgoHOPO83VTdtYoOQ6BH9wYoulR9PiRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeK)67f9usdw5YbMJNdl1jKkAHmCcrlPbR47fT6Q0(78YGxGyDgixVpUrWNSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(RBUcO0TDys2bvvFlWgNtpmj7q7sQOwmg0x7NXvJkWKj(ERww7BhLchnDKmTqgoHugMKlXB7WKSdQQ(wGJMosMMkqm8lvvlR9POcb)bw3q)yzD6QHiNQPP)0P7An9VJWSHA63y6id)pzD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8kjDvA1vvChLchnDKmTqgoHugMKlXN7Ou4OPJKPfYWjKcentg0xRWfRFgVyMhkDBhMKDqv13cSX50CioCQmosqivTS2hRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKxPYlQIkyXQqWFG1n0pwwNUAiYPAA6pD6Uwt)7imBOM(nMoYW)TDys2bvvFlS3RrOMM7v7qTS2N3VUUSoDCDA2PfQmmsQ89tVFDDHJMosMM1qSqLHrYRB(2omj7GQQVf8shsz9h6h1ETXdHu1YAFE)66IqgoHu4964jRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKxPcUTdtYoOQ6BH0S7AA2HAzTVHj5suJbAsKw5Bvv89IvghgsHomywNmKRP93rlymEoKR0tVFDDzD6460StluzyKuPVk8P3VUUiKHtifEVoEY62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5vQGB7WKSdQQ(win7UMMDOww7BysUe1yGMePvQ8tVFDDzD6460StluzyKuPVk8P3VUUiKHtifEVoEY62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5vQGNke8hyDd9JL0S7AAUe17TGHKJ7PIkKmomKsnSnAPkQPvhEVMwWy8CiF1v9(11LAyB0svutRo8EnT83v62omj7GQQVfsZURPzhQL1(gMKlrngOjrALk)07xxxwNoUon70cvggjv6RcF69RRlPz310CjQ3BbdjhxbIMjd6Rk)e(dSUH(XsA2DnnxI69wWqYX9urfsghgsHJMosMM1b9B2LSJcgJNd5RUQIE)66IqgoHu4964jRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKxPcusPB7WKSdQQ(win7UMMDOww7Z7xxxwNoUon70cvggjv67TYpLXHHuO93PzDW)PuWy8Ci)PmomKsnSnAPkQPvhEVMwWy8Ci)j8hyDd9JL0S7AAUe17TGHKJ7P3VUUiKHtifEVoEY62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5vQGB7WKSdQQ(wWpmnDcrDn68)hixTS2NKgulTMN4RBEr32Hjzhuv9Ta9BmDOxMoSoXGRww7tsdQLwZt8vLRa32Hjzhuv9Ta9BmDO5OPJKPfYWje1YAFsAqT0AEIV(wb32Hjzhuv9Tq1j46Uw7)74tOww7J2FNMwDGCFk42UPhOcwFGnbIdNkJJeespWaXdmoioCYhyysUev7arFGar(bK(a0zjEaA1bYP32Hjzhuv9Tq1j46Uw7)74tOww7J2FNMwDG8k9T5NkUJsHdXHtLXrccldtYL4QRUJsHJMosMwidNqkdtYLOs32Hjzhuv9Tq1j46Uw7)74tOww7J2FNMwDG8k99(P3VUUeOufH69gkJR83FY62X71rHnoNMdXHtLXrccPfiAMmOvQ8I1pJxmZJB7WKSdQQ(wO6eCDxR9)D8julR9r7VttRoqEL(E)K1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYF1pJxmZJNsAWkxoWC8CyPoHurlKHtiAjnyf9Z4fZ842omj7GQQVfyJZPhMKDODjvulgd6J1lXycrpEPlfYQrfyYeFVvlR9PqSEjgtiLLyivjdVTB6bEjPuT)YbiggmRtgYpar)Du1oar)DhGqGjj4bs6bOcSd)i8as1joWMGMo8ANO2bO9bs5avh6bMdun9xfHhyhMnmfY32Hjzhuv9TaT)onvGjjOAzTpfsghgsHomywNmKRP93rlymEoKFB30dqSJb)aBcA6izhGuAispqDdpar)DhGO6a50d8djDhqfYWjKdW62X71Xbs6byUMIhq6daXHt(2omj7GQQVf4OPdV2jQL1(8(11foA6izAwdXcehM8K2FNMwDG8xv4NSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itqELkVOB7MEGn5dZW)buHmCc5auu(7QDa6og8dSjOPJKDasPHi9a1n8ae93DaIQdKtVTdtYoOQ6BboA6WRDIAzTpVFDDHJMosMM1qSaXHjpP93PPvhi)vf(jRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeK)6BLVTdtYoOQ6BboA6WRDIAzTpVFDDHJMosMM1qSaXHjpP93PPvhi)vf(PIE)66chnDKmnRHyHkdJKkvE1vLXHHuOddM1jd5AA)D0cgJNd5kDBhMKDqv13cC00Hx7e1YAFE)66chnDKmnRHybIdtEs7VttRoq(Rk8ZHj5suJbAsKw57B7WKSdQQ(wG2FNMkWKe82omj7GQQVfyJZPhMKDODjvulgd6J1lXycrpEPlfY32n9avW6dqU)hGnXb8JYb8ggjhq6dOGdq0F3biQoqo9aEyDdXdSjqC4uzCKGq6byD74964aj9aqC4Kv7aPSc9anjd5di9bO7yWpGufnhi6132Hjzhuv9Tq1j46Uw7)74tOww7J2FNMwDG8k9T5NSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itqELkRGNkkJddPWrthjtZgNld)fmgphYxDvw3oEVokSX50CioCQmosqiTarZKbTsfvubvK2FNMwDGCLwSdtYok0QdVxR9ANuWhi7lOwsdQKQdtYokvNGR7AT)VJprbFGSVGAjnOs32Hjzhuv9TaVBJAmYmhQLb6hfQV3QL1(GynePvhph(usdw5YbMJNdl1jKkAHmCcrlPbVTdtYoOQ6BbA1H3R1ETtUT32Hjzh0c11R1cmdsqH67trDkOrTymOpA)DouKm8RHFpYQL1(yD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8xLb6hLcpPYemCXPGNsAWkxoWC8CyPoHurlKHtiAjnyfvugOFuk8KktWWfNcu62omj7GwOUETwGzqckuv9TWNI6uqJAXyqF0F456MRhdkvjtf1YAFSUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(RYa9JsHNuzcgU4uWtjnyLlhyoEoSuNqQOfYWjeTKgSIkkd0pkfEsLjy4ItbkDB30dq6b5Xem8avh6bMd8w5dqrwh8dWr3q(atWpqspGufHyDdXdqjj33r(bQB4bQtivoGkKHtihq6d4YapWF)aRtP6bKQ4bGivUTdtYoOfQRxRfygKGcvvFl8POof0Owmg0hA2jdXXPBipMGHQL1(yD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8xvugOFuk8KktWWfNcus13k)K1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYRurfvugOFuk8KktWWfNcus13kRufFRaLEkPbRC5aZXZHL6esfTqgoHOL0GvurfLb6hLcpPYemCXPaLu9TYkDBVTdtYoOfwVeJje94LUui7J2FNg2IAzTpA)DEzWl(H9suNXY0Fdhj74PISUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(RkVOvxL1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYRCZlsPB7WKSdAH1lXycrpEPlfYQ6BbA)DAylQL1(O935LbVuNOJR7ATNRP02qFUJsHJMosMwidNqkdtYL4TDys2bTW6LymHOhV0Lczv9TaT)onSf1YAF0(78YGxwNoUU6peTmmjz0B7WKSdAH1lXycrpEPlfYQ6BboYsZiz4x71orTS2hT)oVm4fhoCThzn(ym7o8PI7Ou4OPJKPfYWjKYWKCj(K2FNMwDG8xvE1vzD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8kv4fP0TDys2bTW6LymHOhV0Lczv9TahzPzKm8R9ANOww7tHO935LbV4WHR9iRXhJz3HpvODukC00rY0cz4eszysUeVTdtYoOfwVeJje94LUuiRQVfOS(dZWVwsPkQww7J2FNxg8cRnEJOnipLrYoEUJsHJMosMwidNqkdtYL4TDys2bTW6LymHOhV0Lczv9TaL1Fyg(1skvr1YAFkeT)oVm4fwB8grBqEkJKDCBhMKDqlSEjgti6XlDPqwvFlKMDm4z4xZgzOcS3RIQL1(2rPWrthjtlKHtiLHj5s8jT)onT6a5(w0T92omj7GwQURfygKq99POof0Owmg0hnJ6Vt73n8CKgs1OXZHMB7WKSdAP6UwGzqcvvFl8POof0Owmg0hnJ6Vtp09eoHq1OXZHMB7TDys2bT0(zCFEiKIqsYW)TDys2bT0(zCv9TGNRBUU(djFBhMKDqlTFgxvFluNq0Z1n)2omj7GwA)mUQ(w4trDkOHEBVTdtYoOL9pe18Xm(rTaZGeQVpf1PGg1IXG(4qC41je1lrkfD32Hjzh0Y(hIA(yg)OwGzqcvvFl8POof0Owmg0hT)oD6psbH32Hjzh0Y(hIA(yg)OwGzqcvvFl8POof0Owmg0NFh59Q6UwpuAAs3izhQL1(gMKlrngOjrQV332Hjzh0Y(hIA(yg)OwGzqcvvFl8POof0Owmg0hFGKy6o0CKrIE)lqKYWGH32B7WKSdArGzqckuFSX50dtYo0UKkQfJb9vDxlWmiHQww7tghgsHJMosMM1b9B2LSJcgJNd5pzD7496Oq)gthAoA6izAHmCcParZKbvJp2rMG8xvEr32n9al(6AKj0divh5acCwIUdqD9Ah5di9bKb6hLdaXx6pH4bgopLSJXP2bO4(ahbpq1j4Um8FBhMKDqlcmdsqHQQVfyJZPhMKDODjvulgd6J661AbMbjOqVTdtYoOfbMbjOqv13cFkQtbnQfJb91lryTRxNHF9ePz0SXpQww7BhLchnDKmTqgoHugMKlXB7WKSdArGzqckuv9TGaZGeuERww7tGzqckL3LQdv)PO27xx)ChLchnDKmTqgoHugMKlXB7WKSdArGzqckuv9TGaZGeuuwTS2NaZGeukkxQou9NIAVFD9ZDukC00rY0cz4eszysUeVTdtYoOfbMbjOqv13cSX50dtYo0UKkQfJb9T)HOMpMXpQfygKqvlR9jPbRC5aZXZHL6esfTqgoHOL0G32B7WKSdAridNq0uu(7(cuQIq9EdLXPww7J1TJ3RJc9BmDO5OPJKPfYWjKcentgun(yhzcYF9TcUTdtYoOfHmCcrtr5VRQVf8dttNquxJo))bYvlR9X62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5V((LROIdtYok0VX0HMJMosMwidNqk4dK9fulPbvDys2rHwD49ATx7Kc(azFb1sAqLEQiRBhVxhf24CAoehovghjiKwGOzYG(67xUIkomj7Oq)gthAoA6izAHmCcPGpq2xqTKgu1Hjzhf63y6qVmDyDIbVGpq2xqTKgu1HjzhfA1H3R1ETtk4dK9fulPbvA1v3rPWH4WPY4ibHfiAMmOvY62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5Qomj7Oq)gthAoA6izAHmCcPGpq2xqTKguPB7WKSdAridNq0uu(7Q6Bb63y6qVmDyDIbxTS2NISUD8EDuOFJPdnhnDKmTqgoHuGOzYGQXh7itq(RVvqfvCys2rH(nMo0C00rY0cz4esbFGSVGAjnOspvK1TJ3RJcBConhIdNkJJeeslq0mzqF9TcQOIdtYok0VX0HMJMosMwidNqk4dK9fulPbvDys2rH(nMo0lthwNyWl4dK9fulPbvA1v3rPWH4WPY4ibHfiAMmOvY62X71rH(nMo0C00rY0cz4esbIMjdQgFSJmb5Qomj7Oq)gthAoA6izAHmCcPGpq2xqTKgujLwDvfvi4pW6g6hlRtxne5unn9NoDxRP)DeMnut)gthz4)jRBhVxhf63y6qZrthjtlKHtifiAMmOA8XoYeKxPcViLUTdtYoOfHmCcrtr5VRQVfyJZP5qC4uzCKGqQAzTpw3oEVok0VX0HMJMosMwidNqkq0mzq14JDKji)13kxrfhMKDuOFJPdnhnDKmTqgoHuWhi7lOwsdQ6WKSJcT6W71AV2jf8bY(cQL0Gk9usdw5YbMJNdl1jKkAHmCcrlPbR4BLVTdtYoOfHmCcrtr5VRQVfOFJPdnhnDKmTqgoHOww7tsdw5YbMJNdl1jKkAHmCcrlPbFQ4okfoehovghjiSmmjxIp3rPWH4WPY4ibHfiAMmOvomj7Oq)gthAoA6izAHmCcPGpq2xqTKguPNkQqY4Wqk0VX0HEz6W6edEbJXZH8vxDhLYY0H1jg8YWKCjQ0tfP93PPvhi33IwDvf3rPWH4WPY4ibHLHj5s85okfoehovghjiSarZKb91Hjzhf63y6qZrthjtlKHtif8bY(cQL0GQomj7OqRo8ET2RDsbFGSVGAjnOsRUQI7OuwMoSoXGxgMKlXN7OuwMoSoXGxGOzYG(6WKSJc9BmDO5OPJKPfYWjKc(azFb1sAqvhMKDuOvhEVw71oPGpq2xqTKguPvxvrVFDDXpmnDcrDn68)hiV83F69RRl(HPPtiQRrN))a5fiAMmOVomj7Oq)gthAoA6izAHmCcPGpq2xqTKgu1HjzhfA1H3R1ETtk4dK9fulPbvsjRyfRfa]] )


end
