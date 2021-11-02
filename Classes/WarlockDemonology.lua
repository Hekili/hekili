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


        if #dreadstalkers_v > 0  then wipe( dreadstalkers_v ) end
        if #vilefiend_v > 0      then wipe( vilefiend_v )     end
        if #grim_felguard_v > 0  then wipe( grim_felguard_v ) end
        if #demonic_tyrant_v > 0 then wipe( demonic_tyrant_v ) end

        -- Pull major demons from Totem API.
        for i = 1, 5 do
            local exists, name, summoned, duration, texture = GetTotemInfo( i )

            if exists then
                local demon

                -- Grimoire Felguard
                if texture == 136216 then demon = grim_felguard_v
                elseif texture == 1616211 then demon = vilefiend_v
                elseif texture == 1378282 then demon = dreadstalkers_v
                elseif texture == 135002 then demon = demonic_tyrant_v end

                if demon then
                    insert( demon, summoned + duration )
                end
            end

            if #grim_felguard_v > 1 then table.sort( grim_felguard_v ) end
            if #vilefiend_v > 1 then table.sort( vilefiend_v ) end
            if #dreadstalkers_v > 1 then table.sort( dreadstalkers_v ) end
            if #demonic_tyrant_v > 1 then table.sort( demonic_tyrant_v ) end
        end

        last_summon.name = nil
        last_summon.at = nil
        last_summon.count = nil

        if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > query_time then
            summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - query_time )
        end

        if buff.demonic_power.up and buff.demonic_power.remains > pet.demonic_tyrant.remains then
            summonPet( "demonic_tyrant", buff.demonic_power.remains )
        end

        tyrant_ready = nil

        if cooldown.summon_demonic_tyrant.remains > 5 then
            tyrant_ready = false
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


    spec:RegisterPack( "Demonology", 20211101, [[d0KtUbqiKk8iKICjvrrBsv4tkrnkQIofvHvrvP0RirMfjQBPeXUK0VucnmLu5yiLwMsWZusvtdPsDnQkzBkrQVrvPyCivIZPkkzDiv08qkCpQs7tjLdQkIAHkj9qvr1ePQuDrvrWgvfLIpIujzKQIi1jvIeRuP0mrkQDsvXpvfHgksLulvveXtrYurQ6QQIsPTQkIKVQkkmwvrAVu8xknyGdRyXK0JrzYO6YqBwI(mvvJwcDAPETQuZMu3Mk7w43IgUs1XvIKwoONJy6exxvTDj47kfJxvY5jH1RkkvZxjX(vzdTg6nu8rqJplSUfOLwAxhT1fwG2fOBAnuIID0qTpS3JF0qfJdnu(o6Yi1PFfgQ9rHohUHEdfj)qgAOOA3ZnuQ)wllLWOAO4JGgFwyDlqlT0UoARlSaTlSE6IHISJmJplS0lTHQyZ5yyunuCKWmu(o6Yi1PFfh4zmqDYEFBlkYoHoxCr)Tu8RwzPBrs7(6r6myWPuwK0o2I32NitsveEGfwALpWcRBbAVT32NxCc)iHoVTl5au7OwFaAozVR32LCGNyOvCaiYsNdd(b8D0LHAQLdSdXLWsN6ihOlpqlhOjhOdImHCapt4bkoqoBiYbkt4butcbjEuVTl5a015geEaQEVyghy06CdYpWoexclDQJCajpWomzhOdImHCaFhDzOMAPEBxYbORlqxFaz0yihOdbHW)UuVTl5ap5czZpa1QlzTN0jD1bi7J7aBkIXbuK)LH4bIuoWOMF5asEaY35Y4aZbOxbCcPEBxYbE2OrsrgCkLfFsL6rAnEaQuxad5aSjyO22LhGvCc)i)asEGoeec)7ITlR32LCa6HkoGKhykKn)aBgI0H)d47OlJMDGNNq8aezyVj1B7soa9qfhqYd4M34bYDmq4b2HDcBrXbYqR4aBs47d0LhydEa2ehyyYF0Afhi3X4aBAP4bMdqVc4es1qPBIqm0BOi6CJvGD8gfIHEJp0AO3qHXOQrUzvd1WKoddfj)Anksh(TWVQcdfd2cc7XqXYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hGghqgOFuQ8MitWWdS4b81bECaPD4bw7afgypQASw2qIyffWjeR0o8al5aEEazG(rPYBImbdpWIhWxhWddvmo0qrYVwJI0HFl8RQWigFwWqVHcJrvJCZQgQHjDggkYpu1zYTJdLIkiIHIbBbH9yOyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dqJdid0pkvEtKjy4bw8a(6apoG0o8aRDGcdShvnwlBirSIc4eIvAhEGLCappGmq)Ou5nrMGHhyXd4Rd4HHkghAOi)qvNj3ooukQGigX4Z6n0BOWyu1i3SQHIJegS3Lodd1teYJjy4bkoKdmhG2foabzzWpah1JIdmb)an5asreILjepa5DVVJ8duMWdu2qICa6vaNqoGKhq3bEG)(b20sXdifXdarIyOIXHgk0TRaIJ2MqEmbdnumyliShdfltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFaACappGmq)Ou5nrMGHhyXd4Rd4Xbu6a0UWbECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aRDappGNhWZdid0pkvEtKjy4bw8a(6aECaLoaTlCapoWsoaT(6aECGhhqAhEG1oqHb2JQgRLnKiwrbCcXkTdpWsoGNhWZdid0pkvEtKjy4bw8a(6aECaLoaTlCapmudt6mmuOBxbehTnH8ycgAeJyOkUBfyhVjg6n(qRHEdfgJQg5MvnuX4qdfPJYV26xp8EKesSOtvJod1WKoddfPJYV26xp8EKesSOtvJoJy8zbd9gkmgvnYnRAOIXHgkshLFTDi7nCcHyrNQgDgQHjDggkshLFTDi7nCcHyrNQgDgXigkwwaJje7O26wuyO34dTg6nuymQAKBw1qXGTGWEmuK8Rv7Gx9dZcOTJcT)eosNrfJrvJ8d84aEEawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04alSUdSYkhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhy9R7aEyOgM0zyOi5xBHPyeJplyO3qHXOQrUzvdfd2cc7XqrYVwTdETSrn3MLwvDsiPJuXyu1i)apoWokvo6YOzwrbCcPomPlGgQHjDggks(1wykgX4Z6n0BOWyu1i3SQHIbBbH9yOi5xR2bVUP1CBXFiwzysZivmgvnYpWJdqhhyhLkhDz0mROaoHuhM0fWd84aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bw7a0sxmudt6mmuK8RTWumIXh62qVHcJrvJCZQgkgSfe2JHYZdqYVwTdEvJd3QQWIVg3UgRymQAKFGvw5aK8Rv7GxFJf6GyZ8zh1D4VIXOQr(b84apoGNhyhLkhDz0mROaoHuhM0fWd84aK8RTKIdKFaACGfoWkRCa64a7Ou5OlJMzffWjK6WKUaEGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhGUx3b8WqnmPZWqXrw7gPd)w1ulgX4JVm0BOWyu1i3SQHIbBbH9yO88aK8Rv7GxltOFunHbAHybe2iPIXOQr(bwzLd45bi5xR2bVwi1J0A0ssDbmKkgJQg5h4XbOJdqYVwTdE9nwOdInZNDu3H)kgJQg5hWJd4XbECa64a7Ou5OlJMzffWjK6WKUaAOgM0zyO4iRDJ0HFRAQfJy8zPn0BOWyu1i3SQHAysNHHQuJKIm4ukgkgSfe2JHIKFTAh8AHupsRrlj1fWqQymQAKBO6qqi8Vl2U0qP(llRfs9iTgTKuxadP(3nIXhFJHEdfgJQg5MvnumyliShdfj)A1o4vw6uhX6qElJ0zuXyu1i)apoWokvo6YOzwrbCcPomPlGgQHjDggkcl)Wo8BLwkIgX4dDXqVHcJrvJCZQgkgSfe2JHIooaj)A1o4vw6uhX6qElJ0zuXyu1i3qnmPZWqry5h2HFR0sr0igFEwg6nuymQAKBw1qXGTGWEmu7Ou5OlJMzffWjK6WKUaEGhhGKFTLuCG8d49aRZqnmPZWq1UDm4D43Ygzicm3lIgXigkrbCcXsq5VBO34dTg6nuymQAKBw1qXGTGWEmuSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbO1xgQHjDggQaLIi0UNqz0gX4Zcg6nuymQAKBw1qXGTGWEmuSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbO13CGLCappWWKoJk57Czy5OlJMzffWjKk(czFbTs7WdO0bgM0zujfhEUXQMAPIVq2xqR0o8aECGhhWZdWYuZZnrLnATLdXHtKr)gHKkeDthKdqJdqRV5al5aEEGHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HhqPdmmPZOs(oxg2cTglBm4v8fY(cAL2HhqPdmmPZOsko8CJvn1sfFHSVGwPD4b84aRSYb2rPYH4WjYOFJWkeDthKdS2byzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dO0bgM0zujFNldlhDz0mROaoHuXxi7lOvAhEapmudt6mmu(HTlBiAlrT))a5gX4Z6n0BOWyu1i3SQHIbBbH9yO88aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbO1xhyjhWZdmmPZOs(oxgwo6YOzwrbCcPIVq2xqR0o8aECGhhWZdWYuZZnrLnATLdXHtKr)gHKkeDthKdqJdqRVoWsoGNhyysNrL8DUmSC0LrZSIc4esfFHSVGwPD4bu6adt6mQKVZLHTqRXYgdEfFHSVGwPD4b84aRSYb2rPYH4WjYOFJWkeDthKdS2byzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dO0bgM0zujFNldlhDz0mROaoHuXxi7lOvAhEapoGhhyLvoGNhGooa8hyzc9J1nTUeICIL0(BTnlTK)oc7eAjFNlJo8xXyu1i)apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oaDVUd4HHAysNHHI8DUmSfAnw2yWnIXh62qVHcJrvJCZQgkgSfe2JHILPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpanoaTlCGLCappWWKoJk57Czy5OlJMzffWjKk(czFbTs7WdO0bgM0zujfhEUXQMAPIVq2xqR0o8aEyOgM0zyOyJwB5qC4ez0VriXigF8LHEdfgJQg5MvnumyliShdL0o8aRDGcdShvnwlBirSIc4eIvAhEGhhWZdSJsLdXHtKr)gH1HjDb8apoWokvoehorg9BewHOB6GCG1oWWKoJk57Czy5OlJMzffWjKk(czFbTs7Wd4XbECappaDCaz0yivY35YWwO1yzJbVIXOQr(bwzLdSJsTqRXYgdEDysxapGhh4Xb88aK8RTKIdKFaVhyDhyLvoGNhyhLkhIdNiJ(ncRdt6c4bECGDuQCioCIm63iScr30b5a04adt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdpGshyysNrLuC45gRAQLk(czFbTs7Wd4XbwzLd45b2rPwO1yzJbVomPlGh4Xb2rPwO1yzJbVcr30b5a04adt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdpGshyysNrLuC45gRAQLk(czFbTs7Wd4XbwzLd45bu)LLv)W2LneTLO2)FG86F)apoG6VSS6h2USHOTe1()dKxHOB6GCaACGHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HhqPdmmPZOsko8CJvn1sfFHSVGwPD4b84aEyOgM0zyOiFNldlhDz0mROaoHyeJyO4y581IHEJp0AO3qHXOQrUzvdfhjmyVlDggQNWlK9fKFaSacvCaPD4bKI4bgMKWd0KdmfMwpQASAOgM0zyOi7OwB1j7Trm(SGHEd1WKoddfB0ABjQl(dbHgkmgvnYnRAeJpR3qVHAysNHHAEHwjjedfgJQg5MvnIXh62qVHAysNHHIJfYp06g)nZqHXOQrUzvJy8Xxg6nuymQAKBw1qnmPZWqXgT2omPZWQBIyO0nrSX4qdLa74nkeJy8zPn0BOWyu1i3SQHIbBbH9yOK0VFnwzzQ55MGCGhhqAhEaACGcdShvnwlBirSIc4eIvAhEGhhGLPMNBIk57Czy5OlJMzffWjKkeDthKdqJduyG9OQXAzdjIvuaNqSs7WdSKdiTdnueb2mX4dTgQHjDggk2O12HjDgwDtedLUjInghAOYDmqOrm(4Bm0BOWyu1i3SQHIbBbH9yOGyjejfhvnAOgM0zyO4z6mIXh6IHEdfgJQg5MvnumyliShdfj)A1o4v)WSaA7Oq7pHJ0zuXyu1i)aRSYbi5xR2bVw2OMBZsRQojK0rQymQAKFGvw5aK8Rv7GxzPtDeRd5TmsNrfJrvJ8dSYkhGLfWycPgidM6eYnueb2mX4dTgQHjDggk2O12HjDgwDtedLUjInghAOyzbmMqSJARBrHrm(8Sm0BOWyu1i3SQHIbBbH9yO88aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(b8EG1DGhhqAhEG1oqHb2JQgRLnKiwrbCcXkTdpWkRCas(1QDWRqSSdKB3h9iyfJrvJ8d84aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbwpD5aEyOgM0zyO2tPZWigFODDg6nuymQAKBw1qnmPZWqXgT2omPZWQBIyO0nrSX4qdLOaoHyjO83nIXhAP1qVHcJrvJCZQgkgSfe2JHAhLkhDz0mROaoHuhM0fqdfrGntm(qRHAysNHHInATDysNHv3eXqPBIyJXHgQ0pJBeJp0UGHEdfgJQg5MvnumyliShdLNhGooa8hyzc9J1nTUeICIL0(BTnlTK)oc7eAjFNlJo8xXyu1i)apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oWZ6aECGvw5aEEGDuQC0LrZSIc4esDysxapWJdSJsLJUmAMvuaNqQq0nDqoanoWsFaF7b8Z4v386aEyOgM0zyO4OlJMzjced)srJy8H21BO3qHXOQrUzvdfd2cc7XqXYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hyTdSW6oWsoGVoGV9a0XbG)altOFSUP1LqKtSK2FRTzPL83ryNql57Cz0H)kgJQg5gQHjDggk2O1woehorg9BesmIXhAPBd9gkmgvnYnRAOyWwqypgk1FzzDtR522TtQezyVpWAhG2d84aQ)YYkhDz0mllHyLid79bOXbwVHAysNHHAp3GqlP3lMHrm(qRVm0BOWyu1i3SQHIbBbH9yOu)LLvrbCcPYZnXbECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aRDaFzOgM0zyOuBnsy5h6hTQPtfHeJy8H2L2qVHcJrvJCZQgkgSfe2JHAysxaTyGUgjhyTdq7bu6aEEaApGV9aYOXqQKHb7YMHClj)AsfJrvJ8d4XbECa1FzzDtR522TtQezyVpWAEpWsFGhhq9xwwffWjKkp3eh4XbyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dS2b8LHAysNHHQD76K0zyeJp06Bm0BOWyu1i3SQHIbBbH9yOgM0fqlgORrYbw7alCGhhq9xww30AUTD7Kkrg27dSM3dS0h4Xbu)LLvrbCcPYZnXbECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aRDaFDGhhGooa8hyzc9J12TRtsxaT7PGH0JUIXOQr(bECappaDCaz0yi1sy6Ssr0sko8CdPIXOQr(bwzLdO(llRLW0zLIOLuC45gs9VFapmudt6mmuTBxNKodJy8Hw6IHEdfgJQg5MvnumyliShd1WKUaAXaDnsoWAhyHd84aQ)YY6MwZTTBNujYWEFG18EGL(apoG6VSS2UDDs6cODpfmKE0vi6MoihGghyHd84aWFGLj0pwB3UojDb0UNcgsp6kgJQg5gQHjDggQ2TRtsNHrm(q7ZYqVHcJrvJCZQgkgSfe2JHs9xww30AUTD7Kkrg27dSM3dq7ch4XbKrJHuj5xBzzW)TuXyu1i)apoGmAmKAjmDwPiAjfhEUHuXyu1i)apoa8hyzc9J12TRtsxaT7PGH0JUIXOQr(bECa1FzzvuaNqQ8CtCGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhWxgQHjDggQ2TRtsNHrm(SW6m0BOWyu1i3SQHIbBbH9yOutc5apoG0o0kPL34bOXbw)6mudt6mmu(HTlBiAlrT))a5gX4Zc0AO3qHXOQrUzvdfd2cc7XqPMeYbECaPDOvslVXdqJdSaDXqnmPZWqr(oxg2cTglBm4gX4ZclyO3qHXOQrUzvdfd2cc7XqPMeYbECaPDOvslVXdqJdqRVmudt6mmuKVZLHLJUmAMvuaNqmIXNfwVHEdfgJQg5MvnumyliShdfj)AlP4a5hW7b8LHAysNHHQ4eCBwA9)18jmIXNfOBd9gkmgvnYnRAOgM0zyOkob3MLw)FnFcdfhjmyVlDggQLs5b8DioCIm63iKCGbIhy0qC4koWWKUaQ8bI8abI8di5bitb8aKIdKtmumyliShdfj)AlP4a5hynVhy9h4Xb88a7Ou5qC4ez0VryDysxapWkRCGDuQC0LrZSIc4esDysxapGhgX4Zc(YqVHcJrvJCZQgkgSfe2JHIKFTLuCG8dSM3dq7bECa1FzznqPicT7jugD9VFGhhGLPMNBIkB0AlhIdNiJ(ncjvi6MoihyTdSWb8ThWpJxDZld1WKoddvXj42S06)R5tyeJplS0g6nuymQAKBw1qXGTGWEmuK8RTKIdKFG18EaApWJdWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hGghWpJxDZRd84as7WdS2bODHdSKd4NXRU51bECappG6VSSYH4WjYOFJqs9VFGhhq9xww5qC4ez0VriPcr30b5aRDGHjDg1ItWTzP1)xZNOIVq2xqR0o8akDGHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HhWJd84aEEa64aYOXqQKVZLHTqRXYgdEfJrvJ8dSYkhq9xwwl0ASSXGx)7hWdd1WKoddvXj42S06)R5tyeJpl4Bm0BOWyu1i3SQHIbBbH9yOOJdWYcymHulGHuub0qreyZeJp0AOgM0zyOyJwBhM0zy1nrmu6Mi2yCOHILfWycXoQTUffgX4Zc0fd9gkmgvnYnRAOgM0zyOi5xBjcSFJgkosyWEx6mmupJwkMF5audd2Lnd5hGk)AIYhGk)6dqjW(nEGMCaIaZWpcpGuCId47Old1ulkFasEGwoqXHCG5afB)fr4b2HDcBrHHIbBbH9yOOJdiJgdPsggSlBgYTK8RjvmgvnYnIXNfEwg6nuymQAKBw1qnmPZWqXrxgQPwmuCKWG9U0zyOO2XGFaFhDz0Sd88eIKduMWdqLF9bOkoqo5a)qA9bOxbCc5aSm18CtCGMCaMoj4bK8aqC4kmumyliShdL6VSSYrxgnZYsiwH4WKd84aK8RTKIdKFaACa6(apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oWcRZigFw)6m0BOWyu1i3SQHAysNHHIJUmutTyO4iHb7DPZWq57Fyh(pa9kGtihGGYFx5dq2XGFaFhDz0Sd88eIKduMWdqLF9bOkoqoXqXGTGWEmuQ)YYkhDz0mllHyfIdtoWJdqYV2skoq(bOXbO7d84aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbODbJy8z90AO3qHXOQrUzvdfd2cc7XqP(llRC0LrZSSeIviom5apoaj)AlP4a5hGghGUpWJd45bu)LLvo6YOzwwcXkrg27dS2bw4aRSYbKrJHujdd2Lnd5ws(1KkgJQg5hWdd1WKoddfhDzOMAXigFw)cg6nuymQAKBw1qXGTGWEmuQ)YYkhDz0mllHyfIdtoWJdqYV2skoq(bOXbO7d84adt6cOfd01i5aRDaAnudt6mmuC0LHAQfJy8z9R3qVHAysNHHIKFTLiW(nAOWyu1i3SQrm(SE62qVHcJrvJCZQgQHjDggk2O12HjDgwDtedLUjInghAOyzbmMqSJARBrHrm(SEFzO3qHXOQrUzvd1WKoddvXj42S06)R5tyO4iHb7DPZWqTukpGI8Fa2ehWpkhqDyVpGKhWxhGk)6dqvCGCYbuXYeIhW3H4WjYOFJqYbyzQ55M4an5aqC4ku(aTSm5a57rXbK8aKDm4hqkIUde5gdfd2cc7XqrYV2skoq(bwZ7bw)bECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aRDGf81bECappGmAmKkhDz0mlB06o8xXyu1i)aRSYbyzQ55MOYgT2YH4WjYOFJqsfIUPdYbw7aEEappGVoWsoaj)AlP4a5hWJd4BpWWKoJkP4WZnw1ulv8fY(cAL2HhWJdO0bgM0zulob3MLw)FnFIk(czFbTs7Wd4Hrm(S(L2qVHcJrvJCZQgQHjDggkEModfd2cc7XqbXsiskoQA8apoG0o8aRDGcdShvnwlBirSIc4eIvAhAOykyA0kd0pkeJp0AeJpR33yO3qHXOQrUzvd1WKoddfhDzOMAXqXrcd27sNHH6zlbpGVJUmutTCGU8akY)Yq8a(Zo8FajpGoj4b8D0LrZoWZtiEaImS3eLpawaJd0LhOLL5hyZqe8aZbi5xFasXbYRgkgSfe2JHs9xww5OlJMzzjeRqCyYbECa1FzzLJUmAMLLqScr30b5a04a0EaLoGFgV6MxhW3Ea1FzzLJUmAMLLqSsKH92igFwpDXqVHAysNHHIuC45gRAQfdfgJQg5MvnIrmu7qKLo1rm0B8Hwd9gkmgvnYnRAOYDdfbfdfd2cc7XqP(llRQ6m56prQ)DdfhjmyVlDggQNWlK9fKFavSmH4byPtDKdOI(7GupWtMXWDHCGiJLuCGUYV(adt6mihidTIQHQWaTX4qdvzdjIvuaNqSs7qd1WKoddvHb2JQgnufg9hTOMGgkAxWqvy0F0qr76mIXNfm0BOWyu1i3SQHkghAOifhEUb52eQAZsRKqhgIHAysNHHIuC45gKBtOQnlTscDyigX4Z6n0BOWyu1i3SQHIbBbH9yOK2HhyTdSUd84a0Xb2rPo6UaAOgM0zyOkrTLNUogPZWigFOBd9gQHjDggkY35YWwIA))bYnuymQAKBw1igF8LHEdfgJQg5MvnuX4qdLKo0MLwxgebMFILLbrGFM0zqmudt6mmus6qBwADzqey(jwwgeb(zsNbXigFwAd9gkmgvnYnRAOIXHgksQXPiXsqgefRGSIrVu)OHAysNHHIKACksSeKbrXkiRy0l1pAeJp(gd9gQHjDggQsnskYGtPyOWyu1i3SQrm(qxm0BOWyu1i3SQHIbBbH9yOu)LL1nTMBB3oPsKH9(aRDaApWJdO(llRC0LrZSSeIvImS3hGgEpWcgQHjDggQ9CdcTKEVyggX4ZZYqVHcJrvJCZQgkgSfe2JHYZdOMeYbwzLdmmPZOYrxgQPwQSHihW7bw3b84apoaj)AlP4a5KdqJdq3gQHjDggko6Yqn1Irm(q76m0BOWyu1i3SQHIbBbH9yOOJd45butc5aRSYbgM0zu5Old1ulv2qKd49aR7aECGvw5aK8RTKIdKtoWAhy9gQHjDggksXHNBSQPwmIrmu5ogi0qVXhAn0BOWyu1i3SQHIbBbH9yOi5xR2bV6hMfqBhfA)jCKoJkgJQg5gQHjDggks(1wykgX4Zcg6nudt6mmu(HTlBiAlrT))a5gkmgvnYnRAeJpR3qVHAysNHHI8DUmSfAnw2yWnuymQAKBw1igFOBd9gkmgvnYnRAOyWwqypgk1FzzLJUmAMLLqScXHjh4Xbi5xBjfhi)a04a09bECawMAEUjQSrRTCioCIm63iKu)7gQHjDggko6Yqn1Irm(4ld9gkmgvnYnRAOyWwqypgks(1wsXbYpanoGVoWJdWYuZZnrLnATLdXHtKr)gHK6F3qnmPZWqrko8CJvn1Irm(S0g6nudt6mmuSrRTCioCIm63iKyOWyu1i3SQrmIHsGD8gfIHEJp0AO3qHXOQrUzvd1WKoddfP4WZni3MqvBwALe6WqmumyliShdfltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFaACGfwWqfJdnuKIdp3GCBcvTzPvsOddXigFwWqVHcJrvJCZQgkgSfe2JHsgngsLJUmAMLLb572LoJkgJQg5h4XbyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dqJdSW6mudt6mmuSrRTdt6mS6MigkDteBmo0qvC3kWoEtmIXN1BO3qHXOQrUzvdfhjmyVlDggQNqzjYeYbKIJCabofq9bi6CJwXbK8aYa9JYbG4s93q8adN3sNXOv(aeCFGJGhO4eCDh(nudt6mmuSrRTdt6mS6MigkDteBmo0qr05gRa74nkeJy8HUn0BOWyu1i3SQHAysNHHklGWsDUPd)2jA3yzJF0qXGTGWEmu7Ou5OlJMzffWjK6WKUaAOIXHgQSacl15Mo8BNODJLn(rJy8Xxg6nuymQAKBw1qXGTGWEmucSJ3OufARfhI9tqR6VS8apoWokvo6YOzwrbCcPomPlGgQHjDggkb2XBuO1igFwAd9gkmgvnYnRAOyWwqypgkb2XBuQYc1IdX(jOv9xwEGhhyhLkhDz0mROaoHuhM0fqd1WKoddLa74nklyeJp(gd9gkmgvnYnRAOyWwqypgkPD4bw7afgypQASw2qIyffWjeR0o8apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oWcRZqnmPZWqXgT2omPZWQBIyO0nrSX4qd1(hIw(4g)OvGD8MyeJyO2)q0Yh34hTcSJ3ed9gFO1qVHcJrvJCZQgQyCOHIdXHx2q0wajeuBOgM0zyO4qC4LneTfqcb1gX4Zcg6nuymQAKBw1qfJdnuK8RTT)OfeAOgM0zyOi5xBB)rli0igFwVHEdfgJQg5Mvnudt6mmu(1k2lAZs7qiTR1J0zyOyWwqypgQHjDb0Ib6AKCaVhGwdvmo0q5xRyVOnlTdH0UwpsNHrm(q3g6nuymQAKBw1qfJdnu8b(2Lzy5i7TD)lqKWWGHgQHjDggk(aF7YmSCK92U)fisyyWqJy8Xxg6nuymQAKBw1qfJdnuOAgK8RTfAcAOgM0zyOq1mi5xBl0e0igFwAd9gkmgvnYnRAOIXHgQFWkoDGCRF9W7rsiXskoS3AKyOgM0zyO(bR40bYT(1dVhjHelP4WERrIrmIHk9Z4g6n(qRHEd1WKoddLkcji8Dh(nuymQAKBw1igFwWqVHAysNHHsvNj3w(HkmuymQAKBw1igFwVHEd1WKoddvzdrvDMCdfgJQg5MvnIXh62qVHAysNHH6tqBlOJyOWyu1i3SQrmIrmufqiPZW4ZcRBbAxhDz90AO2mWOd)ed1Z4j)K4ZsXh6k68ahG(I4bA3EcLduMWdSmrNBScSJ3Oqw(aqCP(BiYpajD4bMVKUrq(byfNWpsQ3wAUd8a0sNh45zuaHcYpav7E(bikczEDGN5bK8a08FoaVl0KoJdK7iCKeEapx0Jd45cV8OEBP5oWdSaDEGNNrbeki)auT75hGOiK51bEMhqYdqZ)5a8Uqt6moqUJWrs4b8CrpoGNl8YJ6TLM7apW6PZd88mkGqb5hGQDp)aefHmVoWZ8asEaA(phG3fAsNXbYDeoscpGNl6Xb8C9V8OEBVTpJN8tIplfFOROZdCa6lIhOD7juoqzcpWYSSagti2rT1TOy5daXL6VHi)aK0Hhy(s6gb5hGvCc)iPEBP5oWdqlDEGNNrbeki)altYVwTdE9PlFajpWYK8Rv7GxFAfJrvJ8LpGN0(YJ6TLM7apWc05bEEgfqOG8dSmj)A1o41NU8bK8altYVwTdE9PvmgvnYx(aEs7lpQ3wAUd8aRNopWZZOacfKFGLj5xR2bV(0LpGKhyzs(1QDWRpTIXOQr(YhWtAF5r92sZDGhGUPZd88mkGqb5hyzs(1QDWRpD5di5bwMKFTAh86tRymQAKV8b8CHxEuVT0Ch4b8fDEGNNrbeki)altYVwTdE9PlFajpWYK8Rv7GxFAfJrvJ8LpGNR)Lh1Bln3bEGLMopWZZOacfKFGLj5xR2bV(0LpGKhyzs(1QDWRpTIXOQr(YhyKd8eEI08b8K2xEuVT0Ch4b8n05bEEgfqOG8dSmj)A1o41NU8bK8altYVwTdE9PvmgvnYx(aEs7lpQ3wAUd8a0f68appJciuq(bwMKFTAh86tx(asEGLj5xR2bV(0kgJQg5lFGroWt4jsZhWtAF5r92EBFgp5NeFwk(qxrNh4a0xepq72tOCGYeEGLffWjelbL)(YhaIl1Fdr(biPdpW8L0ncYpaR4e(rs92sZDGhy905bEEgfqOG8dSm8hyzc9J1NU8bK8ald)bwMq)y9PvmgvnYx(aEs7lpQ32B7Z4j)K4ZsXh6k68ahG(I4bA3EcLduMWdSmhlNVww(aqCP(BiYpajD4bMVKUrq(byfNWpsQ3wAUd8a0f68appJciuq(bwMKFTAh86tx(asEGLj5xR2bV(0kgJQg5lFapx)lpQ3wAUd8apl68appJciuq(bwMKFTAh86tx(asEGLj5xR2bV(0kgJQg5lFapP9Lh1Bln3bEaAxGopWZZOacfKFGLH)altOFS(0LpGKhyz4pWYe6hRpTIXOQr(YhWtAF5r92sZDGhG21tNh45zuaHcYpWYWFGLj0pwF6YhqYdSm8hyzc9J1NwXyu1iF5dmYbEcprA(aEs7lpQ3wAUd8a06BOZd88mkGqb5hyz4pWYe6hRpD5di5bwg(dSmH(X6tRymQAKV8b8K2xEuVT0Ch4bOLUqNh45zuaHcYpWYWFGLj0pwF6YhqYdSm8hyzc9J1NwXyu1iF5dmYbEcprA(aEs7lpQ3wAUd8a0(SOZd88mkGqb5hyz4pWYe6hRpD5di5bwg(dSmH(X6tRymQAKV8b8K2xEuVT32NXt(jXNLIp0v05boa9fXd0U9ekhOmHhyzb2XBuilFaiUu)ne5hGKo8aZxs3ii)aSIt4hj1Bln3bEaFrNh45zuaHcYpWYcSJ3OuPT(0LpGKhyzb2XBuQcT1NU8b8K2xEuVT0Ch4bwA68appJciuq(bwwGD8gL6c1NU8bK8allWoEJsvwO(0LpGN0(YJ6T92(mEYpj(Su8HUIopWbOViEG2TNq5aLj8alN7yGWLpaexQ)gI8dqshEG5lPBeKFawXj8JK6TLM7apaT05bEEgfqOG8dSmj)A1o41NU8bK8altYVwTdE9PvmgvnYx(aJCGNWtKMpGN0(YJ6T92UuC7juq(bODDhyysNXb0nri1BRHA(sXeAOmu7WSS1OHIMOPd47OlJuN(vCGNXa1j79TLMOPduuKDcDU4I(BP4xTYs3IK291J0zWGtPSiPDSfVT0enDGNitsveEGfwALpWcRBbAVT3wAIMoWZloHFKqN3wAIMoWsoa1oQ1hGMt276TLMOPdSKd8edTIdarw6CyWpGVJUmutTCGDiUew6uh5aD5bA5an5aDqKjKd4zcpqXbYzdroqzcpGAsiiXJ6TLMOPdSKdqxNBq4bO69IzCGrRZni)a7qCjS0PoYbK8a7WKDGoiYeYb8D0LHAQL6TLMOPdSKdqxxGU(aYOXqoqhccH)DPEBPjA6al5ap5czZpa1QlzTN0jD1bi7J7aBkIXbuK)LH4bIuoWOMF5asEaY35Y4aZbOxbCcPEBPjA6al5apB0iPidoLYIpPs9iTgpavQlGHCa2emuB7YdWkoHFKFajpqhccH)DX2L1BlnrthyjhGEOIdi5bMczZpWMHiD4)a(o6YOzh45jeparg2Bs92st00bwYbOhQ4asEa38gpqUJbcpWoStylkoqgAfhytcFFGU8aBWdWM4adt(JwR4a5oghytlfpWCa6vaNqQ32BlnDGNWlK9fKFavSmH4byPtDKdOI(7GupWtMXWDHCGiJLuCGUYV(adt6mihidTI6TDysNbPUdrw6uhrjVlwyG9OQrLJXHElBirSIc4eIvAhQCU7LGIYDPx1FzzvvNjx)js9VRCHr)rV0UoLlm6pArnb9s7c32HjDgK6oezPtDeL8U4NG2wqNYX4qVKIdp3GCBcvTzPvsOdd52omPZGu3HilDQJOK3flrTLNUogPZq5U0R0oCT19Go2rPo6UaEBhM0zqQ7qKLo1ruY7IKVZLHDhLB7WKodsDhIS0PoIsEx8tqBlOt5yCOxjDOnlTUmicm)elldIa)mPZGCBhM0zqQ7qKLo1ruY7IFcABbDkhJd9ssnofjwcYGOyfKvm6L6hVTdt6mi1DiYsN6ik5DXsnskYGtPCBhM0zqQ7qKLo1ruY7I75geAj9EXmuUl9Q(llRBAn32UDsLid79A0(q9xww5OlJMzzjeRezyVPH3fUTdt6mi1DiYsN6ik5Dro6Yqn1IYDPxpvtczLvgM0zu5Old1ulv2qeVRZJhK8RTKIdKtObDFBhM0zqQ7qKLo1ruY7IKIdp3yvtTOCx6Lo8unjKvwzysNrLJUmutTuzdr8Uopwzfs(1wsXbYjRT(B7TLMoWt4fY(cYpawaHkoG0o8asr8adts4bAYbMctRhvnwVTdt6miEj7OwB1j79TDysNbrjVlYgT2wI6I)qq4TDysNbrjVloVqRKeYTDysNbrjVlYXc5hADJ)MDBhM0zquY7ISrRTdt6mS6MikhJd9kWoEJc52omPZGOK3fzJwBhM0zy1nruogh6n3XaHkteyZeV0QCx6vs)(1yLLPMNBcYdPDinkmWEu1yTSHeXkkGtiwPD4dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqOrHb2JQgRLnKiwrbCcXkTdxI0o82omPZGOK3f5z6uUl9cXsiskoQA82omPZGOK3fzJwBhM0zy1nruogh6LLfWycXoQTUffkteyZeV0QCx6LKFTAh8QFywaTDuO9NWr6mwzfs(1QDWRLnQ52S0QQtcjDKvwHKFTAh8klDQJyDiVLr6mwzfwwaJjKAGmyQti)2omPZGOK3f3tPZq5U0RNSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqU319qAhUwHb2JQgRLnKiwrbCcXkTdxzfs(1QDWRqSSdKB3h9i4dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiNgRNU4XTDysNbrjVlYgT2omPZWQBIOCmo0ROaoHyjO83VTdt6mik5Dr2O12HjDgwDteLJXHEt)mUYeb2mXlTk3LE3rPYrxgnZkkGti1HjDb82omPZGOK3f5OlJMzjced)srL7sVEshWFGLj0pw306siYjws7V12S0s(7iStOL8DUm6W)dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiFTNLhRSIN7Ou5OlJMzffWjK6WKUa(yhLkhDz0mROaoHuHOB6GqJL236NXRU5Lh32HjDgeL8UiB0AlhIdNiJ(ncjk3LEzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG81wyDlXx(w6a(dSmH(X6MwxcroXsA)T2MLwYFhHDcTKVZLrh(VTdt6mik5DX9CdcTKEVygk3LEv)LL1nTMBB3oPsKH9EnAFO(llRC0LrZSSeIvImS30y932HjDgeL8UOARrcl)q)OvnDQiKOCx6v9xwwffWjKkp3epyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8181TDysNbrjVl2UDDs6muUl9omPlGwmqxJK1OvjpP13kJgdPsggSlBgYTK8RjvmgvnY94H6VSSUP1CB72jvImS3R5DPFO(llRIc4esLNBIhSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(A(62omPZGOK3fB3UojDgk3LEhM0fqlgORrYAl8q9xww30AUTD7Kkrg2718U0pu)LLvrbCcPYZnXdwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiFnF9GoG)altOFS2UDDs6cODpfmKE0p8KoKrJHulHPZkfrlP4WZnKkgJQg5RSI6VSSwctNvkIwsXHNBi1)Uh32HjDgeL8Uy721jPZq5U07WKUaAXaDnswBHhQ)YY6MwZTTBNujYWEVM3L(H6VSS2UDDs6cODpfmKE0vi6Moi0yHhWFGLj0pwB3UojDb0UNcgsp6B7WKodIsExSD76K0zOCx6v9xww30AUTD7Kkrg2718s7cpKrJHuj5xBzzW)TuXyu1i)HmAmKAjmDwPiAjfhEUHuXyu1i)b8hyzc9J12TRtsxaT7PGH0J(H6VSSkkGtivEUjEWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5R5RB7WKodIsEx0pSDzdrBjQ9)hix5U0RAsipK2HwjT8gPX6x3TDysNbrjVls(oxg2cTglBm4k3LEvtc5H0o0kPL3inwGUCBhM0zquY7IKVZLHLJUmAMvuaNquUl9QMeYdPDOvslVrAqRVUTdt6mik5DXItWTzP1)xZNq5U0lj)AlP4a5E91TLMoWsP8a(oehorg9BesoWaXdmAioCfhyysxav(arEGar(bK8aKPaEasXbYj32HjDgeL8UyXj42S06)R5tOCx6LKFTLuCG818U(hEUJsLdXHtKr)gH1HjDbCLv2rPYrxgnZkkGti1HjDb0JB7WKodIsExS4eCBwA9)18juUl9sYV2skoq(AEP9H6VSSgOueH29ekJU(3FWYuZZnrLnATLdXHtKr)gHKkeDthK1wW36NXRU51TDysNbrjVlwCcUnlT()A(ek3LEj5xBjfhiFnV0(GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPHFgV6MxpK2HRr7clXpJxDZRhEQ(llRCioCIm63iKu)7pu)LLvoehorg9BesQq0nDqwBysNrT4eCBwA9)18jQ4lK9f0kTdvAysNrL8DUmSC0LrZSIc4esfFHSVGwPDOhp8KoKrJHujFNldBHwJLng8kgJQg5RSI6VSSwO1yzJbV(3942omPZGOK3fzJwBhM0zy1nruogh6LLfWycXoQTUffkteyZeV0QCx6LoyzbmMqQfWqkQaEBPPd8mAPy(Ldqnmyx2mKFaQ8RjkFaQ8RpaLa734bAYbicmd)i8asXjoGVJUmutTO8bi5bA5afhYbMduS9xeHhyh2jSff32HjDgeL8Uij)AlrG9Bu5U0lDiJgdPsggSlBgYTK8RjvmgvnYVT00bO2XGFaFhDz0Sd88eIKduMWdqLF9bOkoqo5a)qA9bOxbCc5aSm18CtCGMCaMoj4bK8aqC4kUTdt6mik5Dro6Yqn1IYDPx1FzzLJUmAMLLqScXHjpi5xBjfhiNg09dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiFTfw3TLMoGV)HD4)a0RaoHCack)DLpazhd(b8D0LrZoWZtisoqzcpav(1hGQ4a5KB7WKodIsExKJUmutTOCx6v9xww5OlJMzzjeRqCyYds(1wsXbYPbD)GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPbTlCBhM0zquY7IC0LHAQfL7sVQ)YYkhDz0mllHyfIdtEqYV2skoqonO7hEQ(llRC0LrZSSeIvImS3RTWkRiJgdPsggSlBgYTK8RjvmgvnY942omPZGOK3f5Old1ulk3LEv)LLvo6YOzwwcXkehM8GKFTLuCGCAq3pgM0fqlgORrYA0EBhM0zquY7IK8RTeb2VXB7WKodIsExKnATDysNHv3er5yCOxwwaJje7O26wuCBPPdSukpGI8Fa2ehWpkhqDyVpGKhWxhGk)6dqvCGCYbuXYeIhW3H4WjYOFJqYbyzQ55M4an5aqC4ku(aTSm5a57rXbK8aKDm4hqkIUde5MB7WKodIsExS4eCBwA9)18juUl9sYV2skoq(AEx)dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiFTf81dpLrJHu5OlJMzzJw3H)kgJQg5RScltnp3ev2O1woehorg9BesQq0nDqwZtp91si5xBjfhi3dF7WKoJkP4WZnw1ulv8fY(cAL2HEO0WKoJAXj42S06)R5tuXxi7lOvAh6XTDysNbrjVlYZ0PmtbtJwzG(rH4LwL7sVqSeIKIJQgFiTdxRWa7rvJ1YgseROaoHyL2H3wA6apBj4b8D0LHAQLd0Lhqr(xgIhWF2H)di5b0jbpGVJUmA2bEEcXdqKH9MO8bWcyCGU8aTSm)aBgIGhyoaj)6dqkoqE92omPZGOK3f5Old1ulk3LEv)LLvo6YOzwwcXkehM8q9xww5OlJMzzjeRq0nDqObTk5NXRU5LVv9xww5OlJMzzjeRezyVVTdt6mik5DrsXHNBSQPwUT32HjDgKkrNBScSJ3Oq8(jOTf0PCmo0lj)Anksh(TWVQcL7sVSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqonKb6hLkVjYem8z6Rhs7W1kmWEu1yTSHeXkkGtiwPD4s8ugOFuQ8MitWWNPV842omPZGuj6CJvGD8gfIsEx8tqBlOt5yCOxYpu1zYTJdLIkiIYDPxwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiNgYa9JsL3ezcg(m91dPD4AfgypQASw2qIyffWjeR0oCjEkd0pkvEtKjy4Z0xECBPPd8eH8ycgEGId5aZbODHdqqwg8dWr9O4atWpqtoGueHyzcXdqE377i)aLj8aLnKihGEfWjKdi5b0DGh4VFGnTu8asr8aqKi32HjDgKkrNBScSJ3OquY7IFcABbDkhJd9IUDfqC02eYJjyOYDPxwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiNgEkd0pkvEtKjy4Z0xEOeTl8GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYxZtp9ugOFuQ8MitWWNPV8qjAxWJLqRV84H0oCTcdShvnwlBirSIc4eIvAhUep9ugOFuQ8MitWWNPV8qjAxWJB7TDysNbPYYcymHyh1w3IcVK8RTWuuUl9sYVwTdE1pmlG2ok0(t4iDgp8KLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPXcRBLvyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG81w)6842omPZGuzzbmMqSJARBrHsExKKFTfMIYDPxs(1QDWRLnQ52S0QQtcjDKh7Ou5OlJMzffWjK6WKUaEBhM0zqQSSagti2rT1TOqjVlsYV2ctr5U0lj)A1o41nTMBl(dXkdtAg5bDSJsLJUmAMvuaNqQdt6c4dwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiFnAPl32HjDgKkllGXeIDuBDlkuY7ICK1Ur6WVvn1IYDPxpj5xR2bVQXHBvvyXxJBxJRScj)A1o413yHoi2mF2rDh(94HN7Ou5OlJMzffWjK6WKUa(GKFTLuCGCASWkRqh7Ou5OlJMzffWjK6WKUa(GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYxJUxNh32HjDgKkllGXeIDuBDlkuY7ICK1Ur6WVvn1IYDPxpj5xR2bVwMq)OAcd0cXciSrYkR4jj)A1o41cPEKwJwsQlGH8Goi5xR2bV(gl0bXM5ZoQ7WVhE8Go2rPYrxgnZkkGti1HjDb82omPZGuzzbmMqSJARBrHsExSuJKIm4ukk3LEj5xR2bVwi1J0A0ssDbmeL7qqi8Vl2U0R6VSSwi1J0A0ssDbmK6F)2omPZGuzzbmMqSJARBrHsExKWYpSd)wPLIOYDPxs(1QDWRS0PoI1H8wgPZ4Xokvo6YOzwrbCcPomPlG32HjDgKkllGXeIDuBDlkuY7Iew(HD43kTuevUl9shK8Rv7GxzPtDeRd5TmsNXTDysNbPYYcymHyh1w3IcL8Uy72XG3HFlBKHiWCViQCx6DhLkhDz0mROaoHuhM0fWhK8RTKIdK7DD32B7WKodsT4UvGD8M49tqBlOt5yCOxshLFT1VE49ijKyrNQgD32HjDgKAXDRa74nrjVl(jOTf0PCmo0lPJYV2oK9goHqSOtvJUB7TDysNbPM(zCVQiKGW3D4)2omPZGut)mUsExuvNj3w(HkUTdt6mi10pJRK3flBiQQZKFBhM0zqQPFgxjVl(jOTf0rUT32HjDgKAUJbc9sYV2ctr5U0lj)A1o4v)WSaA7Oq7pHJ0zCBhM0zqQ5ogiujVl6h2USHOTe1()dKFBhM0zqQ5ogiujVls(oxg2cTglBm432HjDgKAUJbcvY7IC0LHAQfL7sVQ)YYkhDz0mllHyfIdtEqYV2skoqonO7hSm18CtuzJwB5qC4ez0VriP(3VTdt6mi1ChdeQK3fjfhEUXQMAr5U0lj)AlP4a50WxpyzQ55MOYgT2YH4WjYOFJqs9VFBhM0zqQ5ogiujVlYgT2YH4WjYOFJqYT92omPZGu3)q0Yh34hTcSJ3eVFcABbDkhJd9YH4WlBiAlGecQVTdt6mi19peT8Xn(rRa74nrjVl(jOTf0PCmo0lj)AB7pAbH32HjDgK6(hIw(4g)OvGD8MOK3f)e02c6uogh61VwXErBwAhcPDTEKodL7sVdt6cOfd01iXlT32HjDgK6(hIw(4g)OvGD8MOK3f)e02c6uogh6LpW3UmdlhzVT7FbIeggm82omPZGu3)q0Yh34hTcSJ3eL8U4NG2wqNYX4qVOAgK8RTfAcEBhM0zqQ7FiA5JB8Jwb2XBIsEx8tqBlOt5yCO3FWkoDGCRF9W7rsiXskoS3AKCBVTdt6mivb2XBuiE)e02c6uogh6LuC45gKBtOQnlTscDyik3LEzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCASWc32HjDgKQa74nkeL8UiB0A7WKodRUjIYX4qVf3TcSJ3eL7sVYOXqQC0LrZSSmiF3U0zuXyu1i)bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKtJfw3TLMoWtOSezc5asXroGaNcO(aeDUrR4asEazG(r5aqCP(BiEGHZBPZy0kFacUpWrWduCcUUd)32HjDgKQa74nkeL8UiB0A7WKodRUjIYX4qVeDUXkWoEJc52omPZGufyhVrHOK3f)e02c6uogh6nlGWsDUPd)2jA3yzJFu5U07okvo6YOzwrbCcPomPlG32HjDgKQa74nkeL8UOa74nk0QCx6vGD8gLkT1IdX(jOv9xw(yhLkhDz0mROaoHuhM0fWB7WKodsvGD8gfIsExuGD8gLfuUl9kWoEJsDHAXHy)e0Q(llFSJsLJUmAMvuaNqQdt6c4TDysNbPkWoEJcrjVlYgT2omPZWQBIOCmo07(hIw(4g)OvGD8MOCx6vAhUwHb2JQgRLnKiwrbCcXkTdFWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5RTW6UT32HjDgKQOaoHyjO839gOueH29ekJw5U0lltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKtdA91TDysNbPkkGtiwck)DL8UOFy7YgI2su7)pqUYDPxwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjiNg06BwINdt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdvAysNrLuC45gRAQLk(czFbTs7qpE4jltnp3ev2O1woehorg9BesQq0nDqObT(ML45WKoJk57Czy5OlJMzffWjKk(czFbTs7qLgM0zujFNldBHwJLng8k(czFbTs7qLgM0zujfhEUXQMAPIVq2xqR0o0JvwzhLkhIdNiJ(ncRq0nDqwJLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYvAysNrL8DUmSC0LrZSIc4esfFHSVGwPDOh32HjDgKQOaoHyjO83vY7IKVZLHTqRXYgdUYDPxpzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCAqRVwINdt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTd94HNSm18CtuzJwB5qC4ez0VriPcr30bHg06RL45WKoJk57Czy5OlJMzffWjKk(czFbTs7qLgM0zujFNldBHwJLng8k(czFbTs7qpwzLDuQCioCIm63iScr30bznwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjixPHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HE4XkR4jDa)bwMq)yDtRlHiNyjT)wBZsl5VJWoHwY35YOd)pyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG81O715XTDysNbPkkGtiwck)DL8UiB0AlhIdNiJ(ncjk3LEzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCAq7clXZHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HknmPZOsko8CJvn1sfFHSVGwPDOh32HjDgKQOaoHyjO83vY7IKVZLHLJUmAMvuaNquUl9kTdxRWa7rvJ1YgseROaoHyL2Hp8ChLkhIdNiJ(ncRdt6c4JDuQCioCIm63iScr30bzTHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HE8Wt6qgngsL8DUmSfAnw2yWRymQAKVYk7Oul0ASSXGxhM0fqpE4jj)AlP4a5Ex3kR45okvoehorg9BewhM0fWh7Ou5qC4ez0VryfIUPdcngM0zujFNldlhDz0mROaoHuXxi7lOvAhQ0WKoJkP4WZnw1ulv8fY(cAL2HESYkEUJsTqRXYgdEDysxaFSJsTqRXYgdEfIUPdcngM0zujFNldlhDz0mROaoHuXxi7lOvAhQ0WKoJkP4WZnw1ulv8fY(cAL2HESYkEQ(llR(HTlBiAlrT))a51)(d1Fzz1pSDzdrBjQ9)hiVcr30bHgdt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdvAysNrLuC45gRAQLk(czFbTs7qp8WigXya]] )


end
