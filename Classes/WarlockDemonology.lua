-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


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

        local subjugated, icon, count, debuffType, duration, expirationTime = FindUnitDebuffByID( "pet", 1098 )
        if subjugated then
            summonPet( "subjugated_demon", expirationTime - now )
        else
            dismissPet( "subjugated_demon" )
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
        subjugate_demon = {
            id = 1098,
            duration = 300,
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

    spec:RegisterPet( "doomguard",
        11859,
        "ritual_of_doom",
        300 )
    
    
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

            startsCombat = false,
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

            startsCombat = false,

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
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 136154,

            usable = function () return target.is_demon and target.level < level + 2, "requires demon enemy" end,
            handler = function ()
                summonPet( "subjugate_demon" )
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

            usable = function () return not pet.exists, "cannot have an existing pet" end,
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


    spec:RegisterPack( "Demonology", 20210812, [[dW0SLbqiKk8iKk6sQsGnPu5tkjnksjNcPQvPKc9ksPMfvj3IQO2LO(LiLHPKWXqkwMiYZusPPrvKUgsL2Msk6BufHXrveDoLeP1HuQMhsj3JQQ9js1bvsblujvpePuMOQe6IkjkBuvsO(OQKuJujrOtQKOALkLMPQKANuL6NQsIgQsIOLQkj4PizQuf2QQKq(QQKKXQkr7Lk)LKbd5WkwmP6XOmzuDzWMvIplsgnvLtl51QsnBkUnL2TWVLA4QIJRkbTCephQPtCDv12fHVRumELQopPy9kjcMViQ9RYoACE4O4JaoVtAfjrZk8K0KuEfRuAwlDxRJs08aoQNH9EsboQySGJ6fbBhTPtPXr9mAm9WDE4OW9NWahfvzPnhL(VmYkpC6ok(iGZ7Kwrs0ScpjnjLxXkLM1s3KCu4hG58oP1CnDu(kohcNUJIdyMJ6fbBhTPtP5qVQHyA27BRprEW0EAPLQeFF9mRTPHl73ms1bJmlsA4YYs72Ug(P(y5q0KKxhkPvKen32BlT5BIuaM2VTE(qupGXCOx3S35BRNp0RmmAoebyT1cb)qViy7qVnYHEiGNzTvFKdvlhQKdv4dvbwMqoKwn5q(gcNny5qln5q6ngdy6Z3wpFOvYEdqoev94RJdngtVb4h6HaEM1w9roK0h6H0SdvbwMqo0lc2o0BJKVTE(qRKjwjpKmgiKdvHaeY)rY3wpFO1qIU4hIADpN(kX(vFi8Zyp0gFqCin9FvcCOOLdn69xoK0hc)T2oo0Cip0qMqY3wpFOxXga7JrMfjTxrTzKYahIQnjGqoeBcgyu1YHy(MifWpK0hQcbiK)JOQLSJYuyb78WrHn9gLqQ4niyNhoVPX5HJcIr3aC36oQHjvhokC)ngqKksPiFDnokgPeGuJJI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpeToKmKuGK5fwMGbhkTdr3dT7qszHdL(HsmKA0nqEPiyrjAitikPSWH88H06qYqsbsMxyzcgCO0oeDpe9oQySGJc3FJbePIukYxxJtCENKZdhfeJUb4U1DudtQoCu4FOB6MRgli(0GfhfJucqQXrX62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb4hIwhsgskqY8cltWGdL2HO7H2DiPSWHs)qjgsn6giVueSOenKjeLuw4qE(qADiziPajZlSmbdouAhIUhIEhvmwWrH)HUPBUASG4tdwCIZ7168WrbXOBaUBDhfhWms9ivhoQxjHhtWGd5BWhAoenjDimW6GFioygnhAc(Hk8HeFabwAcCi8765b4hAPjhAPiy5qEOHmHCiPpKPc4q)NdTPeFhs8bhIayXrfJfCuG9rdbgJQj8ycg4OyKsasnokw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGja)q06qADiziPajZlSmbdouAhIUhI(dP9HOjPdT7qSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pata(Hs)qADiToKwhsgskqY8cltWGdL2HO7HO)qAFiAs6q0FipFiAO7HO)q7oKuw4qPFOedPgDdKxkcwuIgYeIsklCipFiToKwhsgskqY8cltWGdL2HO7HO)qAFiAs6q07OgMuD4Oa7Jgcmgvt4XemWjoXr57rjKkEJDE48MgNhokigDdWDR7OIXcokCflFJkLz41inbRaRUbSoQHjvhokCflFJkLz41inbRaRUbSoX5DsopCuqm6gG7w3rfJfCu4kw(g1GFkYecwbwDdyDudtQoCu4kw(g1GFkYecwbwDdyDItCuSobetiQrVmLOX5HZBACE4OGy0na3TUJIrkbi14OW93OxbpNI0javfjQunzKQJmeJUb4hA3H06qSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pata(HO1HsAfhk5KpeRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFO0p0AxXHO3rnmP6WrH7VrrAXjoVtY5HJcIr3aC36okgPeGuJJc3FJEf88sbgUQxu6MgJBlodXOBa(H2DOhqYCW2rXuIgYesEysLaCudtQoCu4(BuKwCIZ7168WrbXOBaUBDhfJucqQXrH7VrVcEEtz4kF)quYWKIHZqm6gG7OgMuD4OW93OiT4eN3EQZdhfeJUb4U1DumsjaPghLwhc3FJEf8SbgUsxJc2p2hdKHy0na)qjN8HW93Oxbp)gsubw19kbWurQmeJUb4hI(dT7qADOhqYCW2rXuIgYesEysLao0UdH7VrH9ne(HO1Hs6qjN8HOJd9asMd2okMs0qMqYdtQeWH2Diw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGja)qPFipDfhIEh1WKQdhfhyLDKksP0BJ4eN3015HJcIr3aC36okgPeGuJJsRdH7VrVcEEPjPa9MeGIajasb4meJUb4hk5KpKwhc3FJEf8CI2mszafUnjGqYqm6gGFODhIooeU)g9k453qIkWQUxjaMksLHy0na)q0Fi6p0Udrhh6bKmhSDumLOHmHKhMujah1WKQdhfhyLDKksP0BJ4eN3RPZdhfeJUb4U1DudtQoCulga7JrMfXrXiLaKACu4(B0RGNt0MrkdOWTjbesgIr3aChvfcqi)hrvlok9)YsorBgPmGc3Meqi5)JtCE7jCE4OGy0na3TUJIrkbi14OW93OxbpZAR(iklWlzKQJmeJUb4hA3HEajZbBhftjAiti5HjvcWrnmP6WrHz9NurkLuIpWjoV9KopCuqm6gG7w3rXiLaKACu0XHW93OxbpZAR(iklWlzKQJmeJUb4oQHjvhokmR)KksPKs8boX59k15HJcIr3aC36okgPeGuJJ6bKmhSDumLOHmHKhMujGdT7q4(BuyFdHFi)hAfoQHjvhoQY(abVIuk2idwi9JpWjoXrjAitikmi)hNhoVPX5HJcIr3aC36okgPeGuJJI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpeToen01rnmP6WrfG4diQNMiJXjoVtY5HJcIr3aC36okgPeGuJJI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpeToenEId55dP1HgMuDKXFRTdfhSDumLOHmHKH9a7lGsklCiTp0WKQJm23W7nk92izypW(cOKYchI(dT7qADiw3gEVjYSXyuCcmCSmM3abNjGDQaFiADiA8ehYZhsRdnmP6iJ)wBhkoy7Oykrdzcjd7b2xaLuw4qAFOHjvhz83A7qLOmWsbbpd7b2xaLuw4qAFOHjvhzSVH3Bu6TrYWEG9fqjLfoe9hk5Kp0dizobgowgZBGKjGDQaFO0peRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFiTp0WKQJm(BTDO4GTJIPenKjKmShyFbuszHdrVJAys1HJkfPSDra1cys9hc3joVxRZdhfeJUb4U1DumsjaPghLwhI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpeToen09qE(qADOHjvhz83A7qXbBhftjAitizypW(cOKYchI(dT7qADiw3gEVjYSXyuCcmCSmM3abNjGDQaFiADiAO7H88H06qdtQoY4V12HId2okMs0qMqYWEG9fqjLfoK2hAys1rg)T2oujkdSuqWZWEG9fqjLfoe9hk5Kp0dizobgowgZBGKjGDQaFO0peRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFiTp0WKQJm(BTDO4GTJIPenKjKmShyFbuszHdr)HO)qjN8H06q0XHi)awAskiVPmleGJv4kvzu9Ic)Fas1ef(BTDurQmeJUb4hA3HyDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMa8dL(H80vCi6DudtQoCu4V12HkrzGLccUtCE7PopCuqm6gG7w3rXiLaKACuSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pata(HO1HOjPd55dP1HgMuDKXFRTdfhSDumLOHmHKH9a7lGsklCiTp0WKQJm23W7nk92izypW(cOKYchI(dT7qszHdL(HsmKA0nqEPiyrjAitikPSWH88HOjPd55dnmP6iZgJrXjWWXYyEdeCg2dSVakPSWH0(qdtQoY4V12HId2okMs0qMqYWEG9fqjLfoK2hAys1rg7B49gLEBKmShyFbuszbh1WKQdhfBmgfNadhlJ5nqWoX5nDDE4OGy0na3TUJIrkbi14OKYchk9dLyi1OBG8srWIs0qMquszHdT7qADOhqYCcmCSmM3ajpmPsahA3HEajZjWWXYyEdKmbStf4dL(HgMuDKXFRTdfhSDumLOHmHKH9a7lGsklCi6p0UdP1HOJdjJbcjJ)wBhQeLbwki4zigDdWpuYjFOhqYjkdSuqWZdtQeWHO)q7oKwhc3FJc7Bi8d5)qR4qjN8H06qpGK5ey4yzmVbsEysLao0Ud9asMtGHJLX8gizcyNkWhIwhAys1rg)T2ouCW2rXuIgYesg2dSVakPSWH0(qdtQoYyFdV3O0BJKH9a7lGsklCi6puYjFiTo0di5eLbwki45Hjvc4q7o0di5eLbwki4zcyNkWhIwhAys1rg)T2ouCW2rXuIgYesg2dSVakPSWH0(qdtQoYyFdV3O0BJKH9a7lGsklCi6puYjFiToK(FzjNIu2UiGAbmP(dHN)phA3H0)ll5uKY2fbulGj1Fi8mbStf4drRdnmP6iJ)wBhkoy7Oykrdzcjd7b2xaLuw4qAFOHjvhzSVH3Bu6TrYWEG9fqjLfoe9hIEh1WKQdhf(BTDO4GTJIPenKjeN4ehfhwMVrCE48MgNhokigDdWDR7O4aMrQhP6WrTY2dSVa8dbjaIMdjLfoK4do0WKMCOcFOjXuMr3azh1WKQdhf(bmgLPzVDIZ7KCE4OgMuD4OyJXOwaJVFiaXrbXOBaUBDN48ETopCudtQoCuZEqjng7OGy0na3TUtCE7PopCudtQoCuCir)jk7KQyokigDdWDR7eN3015HJcIr3aC36oQHjvhok2ymQHjvhktHfhLPWIkgl4OesfVbb7eN3RPZdhfeJUb4U1DumsjaPghfbwia23OBah1WKQdhfVBRtCE7jCE4OGy0na3TUJIrkbi14OW93OxbpNI0javfjQunzKQJmeJUb4hk5KpeU)g9k45LcmCvVO0nng3wCgIr3a8dLCYhc3FJEf8mRT6JOSaVKrQoYqm6gGFOKt(qSobeti5ayK20eUJclKIjoVPXrnmP6WrXgJrnmP6qzkS4OmfwuXybhfRtaXeIA0ltjACIZBpPZdhfeJUb4U1DudtQoCuSXyudtQouMcloktHfvmwWrjAitikmi)hN48EL68WrbXOBaUBDhfJucqQXrP1HyDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMa8drRdrZko0UdjLfou6hkXqQr3a5LIGfLOHmHOKYchYZhIMvCOKt(q4(B0RGNjWsfax9mMrGmeJUb4hA3HyDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMa8drRdTwp5HO3rnmP6Wr90s1HtCEtZkCE4OGy0na3TUJIrkbi14OEajZbBhftjAiti5HjvcWrHfsXeN304OgMuD4OyJXOgMuDOmfwCuMclQySGJQtX4oX5nn048WrbXOBaUBDhfJucqQXrP1HOJdr(bS0KuqEtzwiahRWvQYO6ff()aKQjk83A7OIuzigDdWp0UdX62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb4hk9dTspe9hk5KpKwh6bKmhSDumLOHmHKhMujGdT7qpGK5GTJIPenKjKmbStf4drRdTMhAnEOumE2o7pe9oQHjvhokoy7OykSqGiL4ZjoVPjjNhokigDdWDR7OyKsasnokw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGja)qPFOKwXH88HO7HwJhIooe5hWstsb5nLzHaCScxPkJQxu4)dqQMOWFRTJksLHy0na3rnmP6WrXgJrXjWWXYyEdeStCEtZADE4OGy0na3TUJIrkbi14O0)ll5nLHRk7doJLH9(qPFiAo0UdP)xwYCW2rXuSMazSmS3hIwhAToQHjvhoQNEdqu46XxhoX5nnEQZdhfeJUb4U1DumsjaPghL(FzjlAitizEVjo0UdX62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb4hk9drxh1WKQdhLEzamR)KuGsVT6ab7eN30qxNhokigDdWDR7OyKsasnoQHjvcqbbylaFO0penhs7dP1HO5qRXdjJbcjJhgPwkgWv4(BWzigDdWpe9hA3H0)ll5nLHRk7doJLH9(qP7)qR5H2Di9)Ysw0qMqY8EtCODhI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpu6hIUoQHjvhoQY(yAC1HtCEtZA68WrbXOBaUBDhfJucqQXrnmPsakiaBb4dL(Hs6q7oK(FzjVPmCvzFWzSmS3hkD)hAnp0UdP)xwYIgYesM3BIdT7qSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pata(Hs)q09q7oeDCiYpGLMKcYL9X04kbOEAbcPgtgIr3a8dT7qADi64qYyGqYlK2QeFGc7B49gCgIr3a8dLCYhs)VSKxiTvj(af23W7n48)5q07OgMuD4Ok7JPXvhoX5nnEcNhokigDdWDR7OyKsasnoQHjvcqbbylaFO0pushA3H0)ll5nLHRk7doJLH9(qP7)qR5H2Di9)YsUSpMgxja1tlqi1yYeWovGpeToushA3Hi)awAskix2htJReG6PfiKAmzigDdWDudtQoCuL9X04QdN48MgpPZdhfeJUb4U1DumsjaPghL(FzjVPmCvzFWzSmS3hkD)hIMKo0UdjJbcjJ7VrX6G)ljdXOBa(H2Dizmqi5fsBvIpqH9n8EdodXOBa(H2DiYpGLMKcYL9X04kbOEAbcPgtgIr3a8dT7q6)LLSOHmHK59M4q7oeRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFO0peDDudtQoCuL9X04QdN48MMvQZdhfeJUb4U1DumsjaPghLEJXhA3HKYckPv8coeTo0AxHJAys1HJkfPSDra1cys9hc3joVtAfopCuqm6gG7w3rXiLaKACu6ngFODhsklOKwXl4q06qj5jDudtQoCu4V12HkrzGLccUtCENenopCuqm6gG7w3rXiLaKACu6ngFODhsklOKwXl4q06q0qxh1WKQdhf(BTDO4GTJIPenKjeN48oPKCE4OGy0na3TUJIrkbi14OW93OW(gc)q(peDDudtQoCu(MGR6fvQVHpHtCEN0ADE4OGy0na3TUJAys1HJY3eCvVOs9n8jCuCaZi1JuD4Ow5lh6fjWWXYyEde8HgcCOXqGHR5qdtQeGxhk6dfaWpK0hcpjGdH9neo2rXiLaKACu4(BuyFdHFO09FO1EODhsRd9asMtGHJLX8gi5Hjvc4qjN8HEajZbBhftjAiti5Hjvc4q07eN3j5PopCuqm6gG7w3rXiLaKACu4(BuyFdHFO09FiAo0UdP)xwYbi(aI6PjYyY)NdT7qSUn8EtKzJXO4ey4yzmVbcota7ub(qPFOKo0A8qPy8SD27OgMuD4O8nbx1lQuFdFcN48oj668WrbXOBaUBDhfJucqQXrH7VrH9ne(Hs3)HO5q7oeRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFiADOumE2o7p0UdjLfou6hIMKoKNpukgpBN9hA3H06q6)LLmNadhlJ5nqW5)ZH2Di9)YsMtGHJLX8gi4mbStf4dL(HgMuDK9nbx1lQuFdFImShyFbuszHdP9HgMuDKXFRTdfhSDumLOHmHKH9a7lGsklCi6p0UdP1HOJdjJbcjJ)wBhQeLbwki4zigDdWpuYjFi9)YsorzGLccE()Ci6DudtQoCu(MGR6fvQVHpHtCEN0A68WrbXOBaUBDhfJucqQXrrhhI1jGycjNacXNgIJclKIjoVPXrnmP6WrXgJrnmP6qzkS4OmfwuXybhfRtaXeIA0ltjACIZ7K8eopCuqm6gG7w3rnmP6WrH7VrHfs9gCuCaZi1JuD4OEvL4R)YHOggPwkgWpev)nyVoev)nhIsi1B4qf(qyH0rkGCiX3eh6fbBh6Tr86q4(qLCiFd(qZH8vP8bKd9qQMuIghfJucqQXrrhhsgdesgpmsTumGRW93GZqm6gG7eN3j5jDE4OGy0na3TUJAys1HJId2o0BJ4O4aMrQhP6Wrr9ab)qViy7OyhI2AcGp0stoev)nhIY3q44d9dPmhYdnKjKdX62W7nXHk8HyMgdhs6drGHRXrXiLaKACu6)LLmhSDumfRjqMadto0UdH7VrH9ne(HO1H80dT7qSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pata(Hs)qjTcN48oPvQZdhfeJUb4U1DudtQoCuCW2HEBehfhWms9ivhoQx8tQi1H8qdzc5qyq(pEDi8de8d9IGTJIDiARja(qln5qu93CikFdHJDumsjaPghL(FzjZbBhftXAcKjWWKdT7q4(BuyFdHFiADip9q7oeRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFiADiAsYjoVx7kCE4OGy0na3TUJIrkbi14O0)llzoy7OykwtGmbgMCODhc3FJc7Bi8drRd5PhA3H06q6)LLmhSDumfRjqgld79Hs)qjDOKt(qYyGqY4HrQLIbCfU)gCgIr3a8drVJAys1HJId2o0BJ4eN3RLgNhokigDdWDR7OyKsasnok9)YsMd2okMI1eitGHjhA3HW93OW(gc)q06qE6H2DOHjvcqbbylaFO0penoQHjvhokoy7qVnItCEV2KCE4OgMuD4OW93OWcPEdokigDdWDR7eN3RDTopCuqm6gG7w3rnmP6WrXgJrnmP6qzkS4OmfwuXybhfRtaXeIA0ltjACIZ716PopCuqm6gG7w3rnmP6Wr5BcUQxuP(g(eokoGzK6rQoCuR8LdPP)hInXHsbYH0h27dj9HO7HO6V5qu(gchFiDyPjWHErcmCSmM3abFiw3gEVjouHpebgUgVoujRIpu)E0CiPpe(bc(HeFG9qrVXrXiLaKACu4(BuyFdHFO09FO1EODhI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpu6hkj6EODhsRdjJbcjZbBhftXgJPIuzigDdWpuYjFiw3gEVjYSXyuCcmCSmM3abNjGDQaFO0pKwhsRdr3d55dH7VrH9ne(HO)qRXdnmP6iJ9n8EJsVnsg2dSVakPSWHO)qAFOHjvhzFtWv9Ik13WNid7b2xaLuw4q07eN3RLUopCuqm6gG7w3rnmP6WrX726OyKsasnokcSqaSVr3ahA3HKYchk9dLyi1OBG8srWIs0qMquszbhftdZakziPab78MgN48ETRPZdh1WKQdhf23W7nk92iokigDdWDR7eN4OEiaRT6J48W5nnopCuqm6gG7w3rnmP6WrTagfVTvms1HJIdygPEKQdh1kBpW(cWpKoS0e4qS2QpYH0HuvGZhAnWyWJGpu0HN9ne7Y3COHjvh4d1Hrt2rXiLaKACuszHdL(HwXH2Di64qpGKhtLaCIZ7KCE4OgMuD4OWFRTd1cys9hc3rbXOBaUBDN48ETopCuqm6gG7w3rfJfCusBbvVOSDGfs)XkwhyH8zs1b2rnmP6WrjTfu9IY2bwi9hRyDGfYNjvhyN482tDE4OGy0na3TUJkgl4OWTbgFyfgyequcW8f1l8doQHjvhokCBGXhwHbgbeLamFr9c)GtCEtxNhoQHjvhoQfdG9XiZI4OGy0na3TUtCEVMopCuqm6gG7w3rXiLaKACu6)LL8MYWvL9bNXYWEFO0penhA3H0)llzoy7OykwtGmwg27drl)hkjh1WKQdh1tVbikC94RdN482t48WrbXOBaUBDhfJucqQXrP1H0Bm(qjN8HgMuDK5GTd92iz2GLd5)qR4q0FODhc3FJc7BiC8HO1H8uh1WKQdhfhSDO3gXjoV9KopCuqm6gG7w3rXiLaKACu0XH06q6ngFOKt(qdtQoYCW2HEBKmBWYH8FOvCi6puYjFiC)nkSVHWXhk9dTwh1WKQdhf23W7nk92ioX59k15HJcIr3aC36oQ(XrHbXrnmP6WrLyi1OBahvIX8bhfnj5OsmevmwWrTueSOenKjeLuwWjoXrjKkEdc25HZBACE4OGy0na3TUJAys1HJc7B49gGRAIUQxustSqiokgPeGuJJI1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWpeToen01rfJfCuyFdV3aCvt0v9IsAIfcXjoVtY5HJcIr3aC36okgPeGuJJsgdesMd2okMI1b(BFKQJmeJUb4hA3HyDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMa8drRdL0kCudtQoCuSXyudtQouMcloktHfvmwWr57rjKkEJDIZ7168WrbXOBaUBDhfhWms9ivhoQv2YcWe8HeFJCiHmjaZHWMEJrZHK(qYqsbYHiWl8xe4qdNxs1Xy86qy4ziJahY3eCtfPCudtQoCuSXyudtQouMcloktHfvmwWrHn9gLqQ4niyN482tDE4OGy0na3TUJAys1HJQtaKftVPIuQjk7OytkWrXiLaKACupGK5GTJIPenKjK8WKkb4OIXcoQobqwm9MksPMOSJInPaN48MUopCuqm6gG7w3rXiLaKACucPI3GKfAY(gS6JbL(Fz5q7o0dizoy7OykrdzcjpmPsaoQHjvhokHuXBqOXjoVxtNhokigDdWDR7OyKsasnokHuXBqYsszFdw9XGs)VSCODh6bKmhSDumLOHmHKhMujah1WKQdhLqQ4nij5eN3EcNhokigDdWDR7OyKsasnokPSWHs)qjgsn6giVueSOenKjeLuw4q7oeRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGFO0pusRWrnmP6WrXgJrnmP6qzkS4OmfwuXybh1ZNak(yNuGsiv8g7eN4OE(eqXh7KcucPI3yNhoVPX5HJcIr3aC36oQySGJItGHVueqLaWyW4OgMuD4O4ey4lfbujamgmoX5DsopCuqm6gG7w3rfJfCu4(BuvQOeG4OgMuD4OW93OQurjaXjoVxRZdhfeJUb4U1DudtQoCuPmAE8P6f1GXLTmJuD4OyKsasnoQHjvcqbbylaFi)hIghvmwWrLYO5XNQxudgx2Yms1HtCE7PopCuqm6gG7w3rfJfCu8H822DO4a7T65leaZGGboQHjvhok(qEB7ouCG9w98fcGzqWaN48MUopCuqm6gG7w3rfJfCuGEh4(Bujkm4OgMuD4Oa9oW93OsuyWjoVxtNhokigDdWDR7OIXcoQFW8nvaCvkZWRrAcwH9nS3ga7OgMuD4O(bZ3ubWvPmdVgPjyf23WEBaStCIJQtX4opCEtJZdh1WKQdhLoqWa5DfPCuqm6gG7w3joVtY5HJAys1HJs30nxT8jACuqm6gG7w3joVxRZdh1WKQdh1sraDt3ChfeJUb4U1DIZBp15HJAys1HJ6JbvjGf7OGy0na3TUtCItCujacU6W5DsRijAwHNyfEsh1MHevKc7OEvRHxbVx5E)QP9dDip8bhQSpnro0sto0QytVrjKkEdcE1drGx4Via)q42chA(sBhb4hI5BIuaoFBFDfWHOH2peT1rcGia)quLL2oewtiZ(d9coK0h61)5q8krHRoou)aKrAYH0kn6pKwjTN(8T91vahkjA)q0whjaIa8drvwA7qynHm7p0l4qsFOx)NdXRefU64q9dqgPjhsR0O)qAL0E6Z32xxbCO1s7hI26ibqeGFiQYsBhcRjKz)HEbhs6d96)CiELOWvhhQFaYin5qALg9hsR1UN(8T92(QwdVcEVY9(vt7h6qE4douzFAICOLMCOvzDciMquJEzkrZQhIaVWFra(HWTfo08L2ocWpeZ3ePaC(2(6kGdrdTFiARJeara(Hwf3FJEf88lx9qsFOvX93Oxbp)YmeJUb4REiTOzp95B7RRaous0(HOTosaeb4hAvC)n6vWZVC1dj9Hwf3FJEf88lZqm6gGV6H0IM90NVTVUc4qRL2peT1rcGia)qRI7VrVcE(LREiPp0Q4(B0RGNFzgIr3a8vp0ihAL9kF9H0IM90NVTVUc4qEkTFiARJeara(Hwf3FJEf88lx9qsFOvX93Oxbp)YmeJUb4REiTsAp95B7RRaoeDP9drBDKaicWp0Q4(B0RGNF5Qhs6dTkU)g9k45xMHy0naF1dP1A3tF(2(6kGdTM0(HOTosaeb4hAvC)n6vWZVC1dj9Hwf3FJEf88lZqm6gGV6Hg5qRSx5RpKw0SN(8T91vahYtq7hI26ibqeGFOvX93Oxbp)YvpK0hAvC)n6vWZVmdXOBa(QhslA2tF(2(6kGd5jP9drBDKaicWp0Q4(B0RGNF5Qhs6dTkU)g9k45xMHy0naF1dnYHwzVYxFiTOzp95B7T9vTgEf8EL79RM2p0H8WhCOY(0e5qln5qRkAitikmi)NvpebEH)Ia8dHBlCO5lTDeGFiMVjsb48T91vahAT0(HOTosaeb4hAvYpGLMKcYVC1dj9HwL8dyPjPG8lZqm6gGV6H0IM90NVT32x1A4vW7vU3VAA)qhYdFWHk7ttKdT0KdTkhwMVrw9qe4f(lcWpeUTWHMV02ra(Hy(MifGZ32xxbCipbTFiARJeara(Hwf3FJEf88lx9qsFOvX93Oxbp)YmeJUb4REiTw7E6Z32xxbCOvkTFiARJeara(Hwf3FJEf88lx9qsFOvX93Oxbp)YmeJUb4REiTOzp95B7RRaoen0q7hI26ibqeGFOvj)awAski)YvpK0hAvYpGLMKcYVmdXOBa(QhslA2tF(2(6kGdrts0(HOTosaeb4hAvYpGLMKcYVC1dj9HwL8dyPjPG8lZqm6gGV6Hg5qRSx5RpKw0SN(8T91vahIM1K2peT1rcGia)qRs(bS0Kuq(LREiPp0QKFalnjfKFzgIr3a8vpKw0SN(8T91vahIgpbTFiARJeara(HwL8dyPjPG8lx9qsFOvj)awAski)YmeJUb4REOro0k7v(6dPfn7PpFBFDfWHOXts7hI26ibqeGFOvj)awAski)YvpK0hAvYpGLMKcYVmdXOBa(QhslA2tF(2EBFvRHxbVx5E)QP9dDip8bhQSpnro0sto0QcPI3GGx9qe4f(lcWpeUTWHMV02ra(Hy(MifGZ32xxbCi6s7hI26ibqeGFOvfsfVbjtt(LREiPp0QcPI3GKfAYVC1dPfn7PpFBFDfWHwtA)q0whjaIa8dTQqQ4ni5KYVC1dj9Hwviv8gKSKu(LREiTOzp95B7TDLBFAIa8dTsp0WKQJdzkSGZ3wh18fFnXr5OEi9szahfDsNh6fbBhTPtP5qVQHyA27BlDsNhYNipyApT0svIVVEM120WL9BgP6GrMfjnCzzPDBPt68qRHFQpwoenj51HsAfjrZT92sN05HOnFtKcW0(TLoPZd55dr9agZHEDZENVT0jDEipFOxzy0CicWARfc(HErW2HEBKd9qapZAR(ihQwoujhQWhQcSmHCiTAYH8neoBWYHwAYH0BmgW0NVT0jDEipFOvYEdqoev94RJdngtVb4h6HaEM1w9roK0h6H0SdvbwMqo0lc2o0BJKVT0jDEipFOvYeRKhsgdeYHQqac5)i5BlDsNhYZhAnKOl(HOw3ZPVsSF1hc)m2dTXhehst)xLahkA5qJE)Ldj9HWFRTJdnhYdnKjK8TLoPZd55d9k2ayFmYSiP9kQnJug4quTjbeYHytWaJQwoeZ3ePa(HK(qviaH8FevTKVT3w68qRS9a7la)q6WstGdXAR(ihshsvboFO1aJbpc(qrhE23qSlFZHgMuDGpuhgn5B7WKQdC(HaS2QpI2(tBbmkEBRyKQdVQf)szH0xXo64bK8yQeWTDys1bo)qawB1hrB)PH)wBhQhqUTdtQoW5hcWAR(iA7pTpguLawVIXc(L2cQErz7alK(JvSoWc5ZKQd8TDys1bo)qawB1hrB)P9XGQeW6vmwWpUnW4dRWaJaIsaMVOEHF42omP6aNFiaRT6JOT)0wma2hJmlYTDys1bo)qawB1hrB)P90BaIcxp(6WRAXV(FzjVPmCvzFWzSmS3PtZo9)YsMd2okMI1eiJLH9Mw(t62omP6aNFiaRT6JOT)04GTd92iEvl(1sVX4KtEys1rMd2o0BJKzdw8Vc63H7VrH9neoMwE6TDys1bo)qawB1hrB)PH9n8EJsVnIx1IF6ql9gJto5Hjvhzoy7qVnsMnyX)kOp5KX93OW(gchN(AVTdtQoW5hcWAR(iA7pTedPgDd4vmwW)srWIs0qMquszbV6h)yq8kXy(GFAs62EBPZdTY2dSVa8dbjaIMdjLfoK4do0WKMCOcFOjXuMr3a5B7WKQdSF8dymktZEFBhMuDG12FASXyulGX3peGCBhMuDG12FAZEqjngFBhMuDG12FACir)jk7KQy32HjvhyT9NgBmg1WKQdLPWIxXyb)cPI3GGVTdtQoWA7pnE3wVQf)eyHayFJUbUTdtQoWA7pn2ymQHjvhktHfVIXc(zDciMquJEzkrJxyHumXpnEvl(X93OxbpNI0javfjQunzKQJKtg3FJEf88sbgUQxu6MgJBlo5KX93OxbpZAR(iklWlzKQJKtM1jGycjhaJ0MMWVTdtQoWA7pn2ymQHjvhktHfVIXc(fnKjefgK)ZTDys1bwB)P90s1Hx1IFTyDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMaCArZk2jLfspXqQr3a5LIGfLOHmHOKYcEMMvKCY4(B0RGNjWsfax9mMrGDSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataoTwRNK(B7WKQdS2(tJngJAys1HYuyXRySG)ofJ7fwift8tJx1I)hqYCW2rXuIgYesEysLaUTdtQoWA7pnoy7OykSqGiL4ZRAXVw0b5hWstsb5nLzHaCScxPkJQxu4)dqQMOWFRTJksTJ1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWtFLsFYjR1dizoy7OykrdzcjpmPsa7EajZbBhftjAitizcyNkW0AnxJPy8SD2t)TDys1bwB)PXgJrXjWWXYyEdeSx1IFw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGjap9KwHNP7AKoi)awAskiVPmleGJv4kvzu9Ic)Fas1ef(BTDurQB7WKQdS2(t7P3aefUE81Hx1IF9)YsEtz4QY(GZyzyVtNMD6)LLmhSDumfRjqgld7nTw7TDys1bwB)PPxgaZ6pjfO0BRoqWEvl(1)llzrdzcjZ7nXow3gEVjY4V12HId2okMs0qMqYeWovGvW(hGjapD6EBhMuDG12FAL9X04QdVQf)dtQeGccWwaoDA0wlAwJYyGqY4HrQLIbCfU)gCgIr3aC63P)xwYBkdxv2hCgld7D6(xZD6)LLSOHmHK59MyhRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGNoDVTdtQoWA7pTY(yAC1Hx1I)HjvcqbbylaNEs70)ll5nLHRk7doJLH9oD)R5o9)Ysw0qMqY8EtSJ1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWtNU7OdYpGLMKcYL9X04kbOEAbcPgZoTOdzmqi5fsBvIpqH9n8EdodXOBaEYjR)xwYlK2QeFGc7B49gC()q)TDys1bwB)Pv2htJRo8Qw8pmPsakiaBb40tAN(FzjVPmCvzFWzSmS3P7Fn3P)xwYL9X04kbOEAbcPgtMa2PcmTsAh5hWstsb5Y(yACLaupTaHuJ52omP6aRT)0k7JPXvhEvl(1)ll5nLHRk7doJLH9oD)0K0ozmqizC)nkwh8FjzigDdW3jJbcjVqARs8bkSVH3BWzigDdW3r(bS0KuqUSpMgxja1tlqi1y2P)xwYIgYesM3BIDSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataE6092omP6aRT)0srkBxeqTaMu)HW9Qw8R3y8oPSGsAfVaAT2vCBhMuDG12FA4V12HkrzGLccUx1IF9gJ3jLfusR4fqRK8K32HjvhyT9Ng(BTDO4GTJIPenKjeVQf)6ngVtklOKwXlGw0q3B7WKQdS2(tZ3eCvVOs9n8j8Qw8J7VrH9neUF6EBPZdTYxo0lsGHJLX8gi4dne4qJHadxZHgMujaVou0hkaGFiPpeEsahc7BiC8TDys1bwB)P5BcUQxuP(g(eEvl(X93OW(gcpD)RDNwpGK5ey4yzmVbsEysLaso5hqYCW2rXuIgYesEysLaO)2omP6aRT)08nbx1lQuFdFcVQf)4(BuyFdHNUFA2P)xwYbi(aI6PjYyY)NDSUn8EtKzJXO4ey4yzmVbcota7ubo9KwJPy8SD2FBhMuDG12FA(MGR6fvQVHpHx1IFC)nkSVHWt3pn7yDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMaCALIXZ2z)oPSq60KKNtX4z7SFNw6)LLmNadhlJ5nqW5)Zo9)YsMtGHJLX8gi4mbStf40hMuDK9nbx1lQuFdFImShyFbuszbThMuDKXFRTdfhSDumLOHmHKH9a7lGsklq)oTOdzmqiz83A7qLOmWsbbpdXOBaEYjR)xwYjkdSuqWZ)h6VTdtQoWA7pn2ymQHjvhktHfVIXc(zDciMquJEzkrJxyHumXpnEvl(PdwNaIjKCcieFAi3w68qVQs81F5qudJulfd4hIQ)gSxhIQ)MdrjK6nCOcFiSq6ifqoK4BId9IGTd92iEDiCFOsoKVbFO5q(Qu(aYHEivtkrZTDys1bwB)PH7VrHfs9g8Qw8thYyGqY4HrQLIbCfU)gCgIr3a8BlDEiQhi4h6fbBhf7q0wta8HwAYHO6V5qu(gchFOFiL5qEOHmHCiw3gEVjouHpeZ0y4qsFicmCn32HjvhyT9NghSDO3gXRAXV(FzjZbBhftXAcKjWWKD4(BuyFdHtlpDhRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGNEsR42sNh6f)KksDip0qMqoegK)Jxhc)ab)qViy7OyhI2AcGp0stoev)nhIY3q44B7WKQdS2(tJd2o0BJ4vT4x)VSK5GTJIPynbYeyyYoC)nkSVHWPLNUJ1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWPfnjDBhMuDG12FACW2HEBeVQf)6)LLmhSDumfRjqMadt2H7VrH9neoT80DAP)xwYCW2rXuSMazSmS3PNuYjlJbcjJhgPwkgWv4(BWzigDdWP)2omP6aRT)04GTd92iEvl(1)llzoy7OykwtGmbgMSd3FJc7BiCA5P7gMujafeGTaC60CBhMuDG12FA4(BuyHuVHB7WKQdS2(tJngJAys1HYuyXRySGFwNaIje1OxMs0CBPZdTYxoKM(Fi2ehkfihsFyVpK0hIUhIQ)Mdr5BiC8H0HLMah6fjWWXYyEde8HyDB49M4qf(qey4A86qLSk(q97rZHK(q4hi4hs8b2df9MB7WKQdS2(tZ3eCvVOs9n8j8Qw8J7VrH9neE6(x7ow3gEVjY4V12HId2okMs0qMqYeWovGvW(hGjap9KO7oTKXaHK5GTJIPyJXurQmeJUb4jNmRBdV3ez2ymkobgowgZBGGZeWovGtxlTORNX93OW(gcN(14WKQJm23W7nk92izypW(cOKYc0R9WKQJSVj4QErL6B4tKH9a7lGsklq)TDys1bwB)PX726ftdZakziPab7NgVQf)eyHayFJUb2jLfspXqQr3a5LIGfLOHmHOKYc32HjvhyT9Ng23W7nk92i32B7WKQdCgB6nkHuXBqW()yqvcy9kgl4h3FJbePIukYxxJx1IFw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGjaNwYqsbsMxyzcg8cO7oPSq6jgsn6giVueSOenKjeLuwWZAjdjfizEHLjyWlGU0FBhMuDGZytVrjKkEdcwB)P9XGQeW6vmwWp(h6MU5QXcIpnyXRAXpRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGtlziPajZlSmbdEb0DNuwi9edPgDdKxkcwuIgYeIskl4zTKHKcKmVWYem4fqx6VT05HELeEmbdoKVbFO5q0K0HWaRd(H4Gz0COj4hQWhs8beyPjWHWVRNhGFOLMCOLIGLd5HgYeYHK(qMkGd9Fo0Ms8DiXhCicGLB7WKQdCgB6nkHuXBqWA7pTpguLawVIXc(b7Jgcmgvt4XemWRAXpRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGtlTKHKcKmVWYem4fqx61MMK2X62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb4PRLwAjdjfizEHLjyWlGU0RnnjrVNPHU0VtklKEIHuJUbYlfblkrdzcrjLf8SwAjdjfizEHLjyWlGU0Rnnjr)T92omP6aNzDciMquJEzkrJFC)nkslEvl(X93OxbpNI0javfjQunzKQJDAX62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb40kPvKCYSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataE6RDf0FBhMuDGZSobetiQrVmLOrB)PH7VrrAXRAXpU)g9k45LcmCvVO0nng3w8UhqYCW2rXuIgYesEysLaUTdtQoWzwNaIje1OxMs0OT)0W93OiT4vT4h3FJEf88MYWv((HOKHjfdFBhMuDGZSobetiQrVmLOrB)PXbwzhPIuk92iEvl(1c3FJEf8SbgUsxJc2p2hdKCY4(B0RGNFdjQaR6ELayQif9706bKmhSDumLOHmHKhMujGD4(BuyFdHtRKsoz64bKmhSDumLOHmHKhMujGDSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataE6E6kO)2omP6aNzDciMquJEzkrJ2(tJdSYosfPu6Tr8Qw8RfU)g9k45LMKc0BsakcKaifGtozTW93OxbpNOnJugqHBtciKD0bU)g9k453qIkWQUxjaMksrp97OJhqYCW2rXuIgYesEysLaUTdtQoWzwNaIje1OxMs0OT)0wma2hJmlIx1IFC)n6vWZjAZiLbu42KacXRkeGq(pIQw8R)xwYjAZiLbu42Kacj)FUTdtQoWzwNaIje1OxMs0OT)0WS(tQiLskXh4vT4h3FJEf8mRT6JOSaVKrQo29asMd2okMs0qMqYdtQeWTDys1boZ6eqmHOg9YuIgT9NgM1FsfPusj(aVQf)0bU)g9k4zwB1hrzbEjJuDCBhMuDGZSobetiQrVmLOrB)Pv2hi4vKsXgzWcPF8bEvl(FajZbBhftjAiti5HjvcyhU)gf23q4(xXT92omP6aN99OesfVX()yqvcy9kgl4hxXY3OszgEnstWkWQBa7TDys1bo77rjKkEJ12FAFmOkbSEfJf8JRy5Bud(Pitiyfy1nG92EBhMuDGZDkg3VoqWa5DfPUTdtQoW5ofJRT)00nDZvlFIMB7WKQdCUtX4A7pTLIa6MU532Hjvh4CNIX12FAFmOkbS4B7TDys1bo)8jGIp2jfOesfVX()yqvcy9kgl4NtGHVueqLaWyWCBhMuDGZpFcO4JDsbkHuXBS2(t7JbvjG1RySGFC)nQkvucqUTdtQoW5Npbu8XoPaLqQ4nwB)P9XGQeW6vmwWFkJMhFQErnyCzlZivhEvl(hMujafeGTaSFAUTdtQoW5Npbu8XoPaLqQ4nwB)P9XGQeW6vmwWpFiVTDhkoWERE(cbWmiyWTDys1bo)8jGIp2jfOesfVXA7pTpguLawVIXc(b9oW93Osuy42omP6aNF(eqXh7KcucPI3yT9N2hdQsaRxXyb))G5BQa4QuMHxJ0eSc7ByVna(2EBhMuDGZcPI3GG9)XGQeW6vmwWp23W7nax1eDvVOKMyHq8Qw8Z62W7nrg)T2ouCW2rXuIgYesMa2PcSc2)amb40Ig6EBhMuDGZcPI3GG12FASXyudtQouMclEfJf877rjKkEJ9Qw8lJbcjZbBhftX6a)Tps1rgIr3a8DSUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataoTsAf3w68qRSLfGj4dj(g5qczsaMdHn9gJMdj9HKHKcKdrGx4ViWHgoVKQJX41HWWZqgboKVj4MksDBhMuDGZcPI3GG12FASXyudtQouMclEfJf8Jn9gLqQ4ni4B7WKQdCwiv8geS2(t7JbvjG1RySG)obqwm9MksPMOSJInPaVQf)pGK5GTJIPenKjK8WKkbCBhMuDGZcPI3GG12FAcPI3GqJx1IFHuXBqY0K9ny1hdk9)YYUhqYCW2rXuIgYesEysLaUTdtQoWzHuXBqWA7pnHuXBqsYRAXVqQ4ni5KY(gS6JbL(Fzz3dizoy7OykrdzcjpmPsa32Hjvh4SqQ4niyT9NgBmg1WKQdLPWIxXyb)pFcO4JDsbkHuXBSx1IFPSq6jgsn6giVueSOenKjeLuwyhRBdV3ez83A7qXbBhftjAitizcyNkWky)dWeGNEsR42EBhMuDGZIgYeIcdY)XFaIpGOEAImgVQf)SUn8EtKXFRTdfhSDumLOHmHKjGDQaRG9pataoTOHU32Hjvh4SOHmHOWG8F02FAPiLTlcOwatQ)q4Evl(zDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMaCArJNWZAnmP6iJ)wBhkoy7Oykrdzcjd7b2xaLuwq7HjvhzSVH3Bu6TrYWEG9fqjLfOFNwSUn8EtKzJXO4ey4yzmVbcota7ubMw04j8SwdtQoY4V12HId2okMs0qMqYWEG9fqjLf0Eys1rg)T2oujkdSuqWZWEG9fqjLf0Eys1rg7B49gLEBKmShyFbuszb6to5hqYCcmCSmM3ajta7uboDw3gEVjY4V12HId2okMs0qMqYeWovGvW(hGjax7Hjvhz83A7qXbBhftjAitizypW(cOKYc0FBhMuDGZIgYeIcdY)rB)PH)wBhQeLbwki4Evl(1I1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWPfn01ZAnmP6iJ)wBhkoy7Oykrdzcjd7b2xaLuwG(DAX62W7nrMngJItGHJLX8gi4mbStfyArdD9SwdtQoY4V12HId2okMs0qMqYWEG9fqjLf0Eys1rg)T2oujkdSuqWZWEG9fqjLfOp5KFajZjWWXYyEdKmbStf40zDB49MiJ)wBhkoy7Oykrdzcjta7ubwb7FaMaCThMuDKXFRTdfhSDumLOHmHKH9a7lGsklqp9jNSw0b5hWstsb5nLzHaCScxPkJQxu4)dqQMOWFRTJksTJ1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWt3txb932Hjvh4SOHmHOWG8F02FASXyuCcmCSmM3ab7vT4N1TH3BIm(BTDO4GTJIPenKjKmbStfyfS)bycWPfnj5zTgMuDKXFRTdfhSDumLOHmHKH9a7lGsklO9WKQJm23W7nk92izypW(cOKYc0VtklKEIHuJUbYlfblkrdzcrjLf8mnj55Hjvhz2ymkobgowgZBGGZWEG9fqjLf0Eys1rg)T2ouCW2rXuIgYesg2dSVakPSG2dtQoYyFdV3O0BJKH9a7lGsklCBhMuDGZIgYeIcdY)rB)PH)wBhkoy7OykrdzcXRAXVuwi9edPgDdKxkcwuIgYeIsklStRhqYCcmCSmM3ajpmPsa7EajZjWWXYyEdKmbStf40hMuDKXFRTdfhSDumLOHmHKH9a7lGsklq)oTOdzmqiz83A7qLOmWsbbpdXOBaEYj)asorzGLccEEysLaOFNw4(BuyFdH7FfjNSwpGK5ey4yzmVbsEysLa29asMtGHJLX8gizcyNkW0Ays1rg)T2ouCW2rXuIgYesg2dSVakPSG2dtQoYyFdV3O0BJKH9a7lGsklqFYjR1di5eLbwki45Hjvcy3di5eLbwki4zcyNkW0Ays1rg)T2ouCW2rXuIgYesg2dSVakPSG2dtQoYyFdV3O0BJKH9a7lGsklqFYjRL(FzjNIu2UiGAbmP(dHN)p70)ll5uKY2fbulGj1Fi8mbStfyAnmP6iJ)wBhkoy7Oykrdzcjd7b2xaLuwq7HjvhzSVH3Bu6TrYWEG9fqjLfONEN4eNd]] )


end
