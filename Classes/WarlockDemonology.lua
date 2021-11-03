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


    spec:RegisterPack( "Demonology", 20211102, [[d0KLUbqiKk8iKICjvrHnPk8jLiJIQItrv0QOQu6vKiZIQWTusyxs6xkHgMsIogsPLPe8mLu10qQuxJQs2MQi8nKkX4qQKoNQOK1HuuZdPW9OkTpLuoOQiYcvs6HQIQjsvP6IkPI2OsQu1hPQuyKQIsPtQKkSsLsZePI2jjQFQkkAOuvkAPkPs5PizQivDvvrPyRkPsLVQkIASQI0EP4VuAWahwXIjPhJYKr1LH2Se9zj0OPQ60s9AvPMnPUnv2TWVfnCLQJRKkz5GEoIPtCDv12LGVRumEvjNNewVQOunFLO2VkBO1qVHIpcAuEHvUaT0s7kxOUaT0nDzHfmuIID0qTpS3tr0qfJdnu(o6Yi1zrfgQ9rHohUHEdfj)qgAOOA3ZnuQ)wlRJWOAO4JGgLxyLlqlT0UYfQlqlDtxwWqr2rMr5fEINWq5V5CmmQgkosygkFhDzK6SOId8KhOozVVT(fzNqZlUyXw8)vRS0TiPDF9iDgm4uklsAhBXBRYzb0PIWdSGhhyHvUaT32B7Z9prrKqZ32vCaQDuRpaDMS31B7koWZm0koaezPZHb)a(o6Yqn1Yb2H4kyPtDKd0LhOLd0Kd0brMqoGpj8a(hiNne5aLj8aQjHGepR32vCaFZCdcpavV7pJdmADUb5hyhIRGLo1roGKhyhMSd0brMqoGVJUmutTuVTR4a(Mf8npGmAmKd0HGq4FxQ32vCGNuHS5hGA1vS2Z2034aK9XDGn(X4akY)sq8arkhyuZVCajpa57CzCG5a0RaoHuVTR4aR71iXpdoLYIR7s9iTgpavQlGHCa2emuB7YdW8prrKFajpqhccH)DX2L1B7koa9qfhqYdmfYMFGndr6O4b8D0LrZoWZtiEaImS3K6TDfhGEOIdi5bCZB8a5ogi8a7WoHTO4azOvCGnj89b6YdSbpaBIdmm5pATIdK7yCGnT4)aZbOxbCcPAO0nrig6nueDUXkWoEJcXqVrzAn0BOWyu1i3SQHAysNHHIKFTgfPJIw4xvHHIbBbH9yOyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dqJdidSikvEtKjy4bw8a(6apoG0o8aRDGcdShvnwlBirSIc4eIvAhEGvCaFoGmWIOu5nrMGHhyXd4Rd4PHkghAOi5xRrr6OOf(vvyeJYlyO3qHXOQrUzvd1WKoddf5hQ6m52XHIFfeXqXGTGWEmuSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbKbweLkVjYem8alEaFDGhhqAhEG1oqHb2JQgRLnKiwrbCcXkTdpWkoGphqgyruQ8MitWWdS4b81b80qfJdnuKFOQZKBhhk(vqeJyuE9g6nuymQAKBw1qXrcd27sNHH6zc5Xem8a(hYbMdq7chGGSm4hGJ6rXbMGFGMCaXpcXYeIhG8U33r(bkt4bkBiroa9kGtihqYdO7apWF)aBAX)be)4bGirmuX4qdf62vaXrBtipMGHgkgSfe2JHILPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpanoGphqgyruQ8MitWWdS4b81b88akDaAx4apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oGphWNd4ZbKbweLkVjYem8alEaFDappGshG2foGNhyfhGwFDappWJdiTdpWAhOWa7rvJ1YgseROaoHyL2HhyfhWNd4ZbKbweLkVjYem8alEaFDappGshG2foGNgQHjDggk0TRaIJ2MqEmbdnIrmu(3TcSJ3ed9gLP1qVHcJrvJCZQgQyCOHI0r5xBlQhEpscjw0PQrNHAysNHHI0r5xBlQhEpscjw0PQrNrmkVGHEdfgJQg5MvnuX4qdfPJYV2oK9goHqSOtvJod1WKoddfPJYV2oK9goHqSOtvJoJyedfllGXeIDuBDlkm0BuMwd9gkmgvnYnRAOyWwqypgks(1QDWRfHzb02rHUychPZOIXOQr(bECaFoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFaACGfw5bwE5dWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hyTdS(vEapnudt6mmuK8RTWumIr5fm0BOWyu1i3SQHIbBbH9yOi5xR2bVw2OMBZsRQojK0rQymQAKFGhhyhLkhDz0mROaoHuhM0fqd1WKoddfj)AlmfJyuE9g6nuymQAKBw1qXGTGWEmuK8Rv7Gx30AU1)peRmmPzKkgJQg5h4XbOJdSJsLJUmAMvuaNqQdt6c4bECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aRDaAPRgQHjDggks(1wykgXOmDBO3qHXOQrUzvdfd2cc7Xq5Zbi5xR2bVQXHBvvyXxJBxJvmgvnYpWYlFas(1QDWRVXcDqSz(SJ6okwXyu1i)aEEGhhWNdSJsLJUmAMvuaNqQdt6c4bECas(1wI)bYpanoWchy5LpaDCGDuQC0LrZSIc4esDysxapWJdWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hyTdq3R8aEAOgM0zyO4iRDJ0rrRAQfJyu2xg6nuymQAKBw1qXGTGWEmu(Cas(1QDWRLjSiQMWaTqSacBKuXyu1i)alV8b85aK8Rv7GxlK6rAnAjPUagsfJrvJ8d84a0Xbi5xR2bV(gl0bXM5ZoQ7OyfJrvJ8d45b88apoaDCGDuQC0LrZSIc4esDysxanudt6mmuCK1Ur6OOvn1Irmk)eg6nuymQAKBw1qnmPZWqvQrIFgCkfdfd2cc7XqrYVwTdETqQhP1OLK6cyivmgvnYnuDiie(3fBxAOu)LL1cPEKwJwsQlGHu)7gXOmDXqVHcJrvJCZQgkgSfe2JHIKFTAh8klDQJyDiVLr6mQymQAKFGhhyhLkhDz0mROaoHuhM0fqd1WKoddfHLFyhfTsl(rJyuMUAO3qHXOQrUzvdfd2cc7XqrhhGKFTAh8klDQJyDiVLr6mQymQAKBOgM0zyOiS8d7OOvAXpAeJYpld9gkmgvnYnRAOyWwqypgQDuQC0LrZSIc4esDysxapWJdqYV2s8pq(b8EGvAOgM0zyOA3og8okAzJmebM7(rJyedLOaoHyjO83n0BuMwd9gkmgvnYnRAOyWwqypgkwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04a06ld1WKoddvGIFeA3tOmAJyuEbd9gkmgvnYnRAOyWwqypgkwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04a0sxoWkoGphyysNrL8DUmSC0LrZSIc4esfFHSVGwPD4bu6adt6mQe)dp3yvtTuXxi7lOvAhEappWJd4ZbyzQ55MOYgT2YH4WjYOFJqsfIUPdYbOXbOLUCGvCaFoWWKoJk57Czy5OlJMzffWjKk(czFbTs7WdO0bgM0zujFNldBHwJLng8k(czFbTs7WdO0bgM0zuj(hEUXQMAPIVq2xqR0o8aEEGLx(a7Ou5qC4ez0VryfIUPdYbw7aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bu6adt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdpGNgQHjDggQIW2LneTLOU4FGCJyuE9g6nuymQAKBw1qXGTGWEmu(CawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04a06RdSId4ZbgM0zujFNldlhDz0mROaoHuXxi7lOvAhEappWJd4ZbyzQ55MOYgT2YH4WjYOFJqsfIUPdYbOXbO1xhyfhWNdmmPZOs(oxgwo6YOzwrbCcPIVq2xqR0o8akDGHjDgvY35YWwO1yzJbVIVq2xqR0o8aEEGLx(a7Ou5qC4ez0VryfIUPdYbw7aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bu6adt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdpGNhWZdS8YhWNdqhha(dSmHfX6MwxcroXs6IT2MLwYFhHDcTKVZLrhfRymQAKFGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhGUx5b80qnmPZWqr(oxg2cTglBm4gXOmDBO3qHXOQrUzvdfd2cc7XqXYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hGghG2foWkoGphyysNrL8DUmSC0LrZSIc4esfFHSVGwPD4bu6adt6mQe)dp3yvtTuXxi7lOvAhEapnudt6mmuSrRTCioCIm63iKyeJY(YqVHcJrvJCZQgkgSfe2JHsAhEG1oqHb2JQgRLnKiwrbCcXkTdpWJd4Zb2rPYH4WjYOFJW6WKUaEGhhyhLkhIdNiJ(ncRq0nDqoWAhyysNrL8DUmSC0LrZSIc4esfFHSVGwPD4b88apoGphGooGmAmKk57Czyl0ASSXGxXyu1i)alV8b2rPwO1yzJbVomPlGhWZd84a(Cas(1wI)bYpG3dSYdS8YhWNdSJsLdXHtKr)gH1HjDb8apoWokvoehorg9BewHOB6GCaACGHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HhqPdmmPZOs8p8CJvn1sfFHSVGwPD4b88alV8b85a7Oul0ASSXGxhM0fWd84a7Oul0ASSXGxHOB6GCaACGHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HhqPdmmPZOs8p8CJvn1sfFHSVGwPD4b88alV8b85aQ)YYAry7YgI2sux8pqE9VFGhhq9xwwlcBx2q0wI6I)bYRq0nDqoanoWWKoJk57Czy5OlJMzffWjKk(czFbTs7WdO0bgM0zuj(hEUXQMAPIVq2xqR0o8aEEapnudt6mmuKVZLHLJUmAMvuaNqmIrmuCSC(AXqVrzAn0BOWyu1i3SQHIJegS3Lodd168fY(cYpawaHkoG0o8aIF8adts4bAYbMctRhvnwnudt6mmuKDuRT6K92igLxWqVHAysNHHInATTe1()HGqdfgJQg5MvnIr51BO3qnmPZWqnVqRKeIHcJrvJCZQgXOmDBO3qnmPZWqXXc5hADtXMzOWyu1i3SQrmk7ld9gkmgvnYnRAOgM0zyOyJwBhM0zy1nrmu6Mi2yCOHsGD8gfIrmk)eg6nuymQAKBw1qXGTGWEmuswSOgRSm18CtqoWJdiTdpanoqHb2JQgRLnKiwrbCcXkTdpWJdWYuZZnrL8DUmSC0LrZSIc4esfIUPdYbOXbkmWEu1yTSHeXkkGtiwPD4bwXbK2HgkIaBMyuMwd1WKoddfB0A7WKodRUjIHs3eXgJdnu5ogi0igLPlg6nuymQAKBw1qXGTGWEmuqSeIe)JQgnudt6mmu8mDgXOmD1qVHcJrvJCZQgkgSfe2JHIKFTAh8ArywaTDuOlMWr6mQymQAKFGLx(aK8Rv7GxlBuZTzPvvNes6ivmgvnYpWYlFas(1QDWRS0PoI1H8wgPZOIXOQr(bwE5dWYcymHudKbtDc5gkIaBMyuMwd1WKoddfB0A7WKodRUjIHs3eXgJdnuSSagti2rT1TOWigLFwg6nuymQAKBw1qXGTGWEmu(CawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)aEpWkpWJdiTdpWAhOWa7rvJ1YgseROaoHyL2Hhy5Lpaj)A1o4viw2bYT7JEeSIXOQr(bECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04aRNUEapnudt6mmu7P0zyeJY0Usd9gkmgvnYnRAOgM0zyOyJwBhM0zy1nrmu6Mi2yCOHsuaNqSeu(7gXOmT0AO3qHXOQrUzvdfd2cc7XqTJsLJUmAMvuaNqQdt6cOHIiWMjgLP1qnmPZWqXgT2omPZWQBIyO0nrSX4qdvwKXnIrzAxWqVHcJrvJCZQgkgSfe2JHYNdqhha(dSmHfX6MwxcroXs6IT2MLwYFhHDcTKVZLrhfRymQAKFGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAh4zDappWYlFaFoWokvo6YOzwrbCcPomPlGh4Xb2rPYrxgnZkkGtivi6MoihGgh4joGV9afz8QBEDapnudt6mmuC0LrZSebIrrXVrmkt76n0BOWyu1i3SQHIbBbH9yOyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dS2bwyLhyfhWxhW3Ea64aWFGLjSiw306siYjwsxS12S0s(7iStOL8DUm6OyfJrvJCd1WKoddfB0AlhIdNiJ(ncjgXOmT0THEdfgJQg5MvnumyliShdL6VSSUP1CB72jvImS3hyTdq7bECa1FzzLJUmAMLLqSsKH9(a04aR3qnmPZWqTNBqOL07(ZWigLP1xg6nuymQAKBw1qXGTGWEmuQ)YYQOaoHu55M4apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oGVmudt6mmuQTgjS8dlIw10PIqIrmkt7tyO3qHXOQrUzvdfd2cc7XqnmPlGwmqxJKdS2bO9akDaFoaThW3Eaz0yivYWGDzZqULKFnPIXOQr(b88apoG6VSSUP1CB72jvImS3hynVh4joWJdO(llRIc4esLNBId84aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bw7a(YqnmPZWq1UDDs6mmIrzAPlg6nuymQAKBw1qXGTGWEmudt6cOfd01i5aRDGfoWJdO(llRBAn32UDsLid79bwZ7bEId84aQ)YYQOaoHu55M4apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oGVoWJdqhha(dSmHfXA721jPlG29uWq6rxXyu1i)apoGphGooGmAmKAjmDwXpAj(hEUHuXyu1i)alV8bu)LL1sy6SIF0s8p8CdP(3pGNgQHjDggQ2TRtsNHrmktlD1qVHcJrvJCZQgkgSfe2JHAysxaTyGUgjhyTdSWbECa1FzzDtR522TtQezyVpWAEpWtCGhhq9xwwB3UojDb0UNcgsp6keDthKdqJdSWbECa4pWYeweRTBxNKUaA3tbdPhDfJrvJCd1WKoddv721jPZWigLP9zzO3qHXOQrUzvdfd2cc7XqP(llRBAn32UDsLid79bwZ7bODHd84aYOXqQK8RTSm4)wQymQAKFGhhqgngsTeMoR4hTe)dp3qQymQAKFGhha(dSmHfXA721jPlG29uWq6rxXyu1i)apoG6VSSkkGtivEUjoWJdWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5hyTd4ld1WKoddv721jPZWigLxyLg6nuymQAKBw1qXGTGWEmuQjHCGhhqAhAL0YB8a04aRFLgQHjDggQIW2LneTLOU4FGCJyuEbAn0BOWyu1i3SQHIbBbH9yOutc5apoG0o0kPL34bOXbwGUAOgM0zyOiFNldBHwJLngCJyuEHfm0BOWyu1i3SQHIbBbH9yOutc5apoG0o0kPL34bOXbO1xgQHjDggkY35YWYrxgnZkkGtigXO8cR3qVHcJrvJCZQgkgSfe2JHIKFTL4FG8d49a(YqnmPZWq5FcUnlTf)A(egXO8c0THEdfgJQg5Mvnudt6mmu(NGBZsBXVMpHHIJegS3Lodd16O8a(oehorg9BesoWaXdmAioCfhyysxa94arEGar(bK8aKPaEaI)bYjgkgSfe2JHIKFTL4FG8dSM3dS(d84a(CGDuQCioCIm63iSomPlGhy5LpWokvo6YOzwrbCcPomPlGhWtJyuEbFzO3qHXOQrUzvdfd2cc7XqrYV2s8pq(bwZ7bO9apoG6VSSgO4hH29ekJU(3pWJdWYuZZnrLnATLdXHtKr)gHKkeDthKdS2bw4a(2duKXRU5LHAysNHHY)eCBwAl(18jmIr5fEcd9gkmgvnYnRAOyWwqypgks(1wI)bYpWAEpaTh4XbyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8dqJduKXRU51bECaPD4bw7a0UWbwXbkY4v386apoGphq9xww5qC4ez0VriP(3pWJdO(llRCioCIm63iKuHOB6GCG1oWWKoJQ)j42S0w8R5tuXxi7lOvAhEaLoWWKoJk57Czy5OlJMzffWjKk(czFbTs7Wd45bECaFoaDCaz0yivY35YWwO1yzJbVIXOQr(bwE5dO(llRfAnw2yWR)9d4PHAysNHHY)eCBwAl(18jmIr5fOlg6nuymQAKBw1qXGTGWEmu0XbyzbmMqQfWq8RaAOicSzIrzAnudt6mmuSrRTdt6mS6MigkDteBmo0qXYcymHyh1w3IcJyuEb6QHEdfgJQg5Mvnudt6mmuK8RTeb2VrdfhjmyVlDggQNCl(ZVCaQHb7YMH8dqLFnXJdqLF9bOey)gpqtoarGzueHhq8pXb8D0LHAQfpoajpqlhW)qoWCa)Dr)i8a7WoHTOWqXGTGWEmu0XbKrJHujdd2Lnd5ws(1KkgJQg5gXO8cpld9gkmgvnYnRAOgM0zyO4Old1ulgkosyWEx6mmuu7yWpGVJUmA2bEEcrYbkt4bOYV(au(hiNCGFiT(a0RaoHCawMAEUjoqtoatNe8asEaioCfgkgSfe2JHs9xww5OlJMzzjeRqCyYbECas(1wI)bYpanoaDFGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhyHvAeJYRFLg6nuymQAKBw1qnmPZWqXrxgQPwmuCKWG9U0zyO89pSJIhGEfWjKdqq5V7Xbi7yWpGVJUmA2bEEcrYbkt4bOYV(au(hiNyOyWwqypgk1FzzLJUmAMLLqScXHjh4Xbi5xBj(hi)a04a09bECawMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKji)a04a0UGrmkVEAn0BOWyu1i3SQHIbBbH9yOu)LLvo6YOzwwcXkehMCGhhGKFTL4FG8dqJdq3h4Xb85aQ)YYkhDz0mllHyLid79bw7alCGLx(aYOXqQKHb7YMHClj)AsfJrvJ8d4PHAysNHHIJUmutTyeJYRFbd9gkmgvnYnRAOyWwqypgk1FzzLJUmAMLLqScXHjh4Xbi5xBj(hi)a04a09bECGHjDb0Ib6AKCG1oaTgQHjDggko6Yqn1IrmkV(1BO3qnmPZWqrYV2sey)gnuymQAKBw1igLxpDBO3qHXOQrUzvd1WKoddfB0A7WKodRUjIHs3eXgJdnuSSagti2rT1TOWigLxVVm0BOWyu1i3SQHAysNHHY)eCBwAl(18jmuCKWG9U0zyOwhLhqr(paBIdueLdOoS3hqYd4RdqLF9bO8pqo5aQyzcXd47qC4ez0Vri5aSm18CtCGMCaioCfECGwwICG89O4asEaYog8di(r3bICJHIbBbH9yOi5xBj(hi)aR59aR)apoaltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKFG1oWc(6apoGphqgngsLJUmAMLnADhfRymQAKFGLx(aSm18CtuzJwB5qC4ez0VriPcr30b5aRDaFoGphWxhyfhGKFTL4FG8d45b8ThyysNrL4F45gRAQLk(czFbTs7Wd45bu6adt6mQ(NGBZsBXVMprfFHSVGwPD4b80igLx)tyO3qHXOQrUzvd1WKoddfptNHIbBbH9yOGyjej(hvnEGhhqAhEG1oqHb2JQgRLnKiwrbCcXkTdnumfmnALbwefIrzAnIr51txm0BOWyu1i3SQHAysNHHIJUmutTyO4iHb7DPZWq9SHGhW3rxgQPwoqxEaf5FjiEGIzhfpGKhqNe8a(o6YOzh45jeparg2BIhhalGXb6Yd0Ys8dSzicEG5aK8RpaX)a5vdfd2cc7XqP(llRC0LrZSSeIviom5apoG6VSSYrxgnZYsiwHOB6GCaACaApGshOiJxDZRd4BpG6VSSYrxgnZYsiwjYWEBeJYRNUAO3qnmPZWqr8p8CJvn1IHcJrvJCZQgXigQDiYsN6ig6nktRHEdfgJQg5Mvnu5UHIGIHIbBbH9yOu)LLvvDMC9Ni1)UHIJegS3Lodd168fY(cYpGkwMq8aS0PoYbuXIDqQh4jXy4UqoqKXk8pqx5xFGHjDgKdKHwr1qvyG2yCOHQSHeXkkGtiwPDOHAysNHHQWa7rvJgQcJ(JwutqdfTlyOkm6pAOODLgXO8cg6nuymQAKBw1qfJdnue)dp3GCBcvTzPvsOddXqnmPZWqr8p8CdYTju1MLwjHomeJyuE9g6nuymQAKBw1qXGTGWEmus7WdS2bw5bECa64a7OuhDxanudt6mmuLO2YtxhJ0zyeJY0THEd1WKoddf57CzylrDX)a5gkmgvnYnRAeJY(YqVHcJrvJCZQgQyCOHsshAZsRldIaZpXYYGiWpt6migQHjDggkjDOnlTUmicm)elldIa)mPZGyeJYpHHEdfgJQg5MvnuX4qdfj144NyjidIIvqM)OxxF0qnmPZWqrsno(jwcYGOyfK5p611hnIrz6IHEd1WKoddvPgj(zWPumuymQAKBw1igLPRg6nuymQAKBw1qXGTGWEmuQ)YY6MwZTTBNujYWEFG1oaTh4Xbu)LLvo6YOzwwcXkrg27dqdVhybd1WKodd1EUbHwsV7pdJyu(zzO3qHXOQrUzvdfd2cc7Xq5Zbutc5alV8bgM0zu5Old1ulv2qKd49aR8aEEGhhGKFTL4FGCYbOXbOBd1WKoddfhDzOMAXigLPDLg6nuymQAKBw1qXGTGWEmu0Xb85aQjHCGLx(adt6mQC0LHAQLkBiYb8EGvEappWYlFas(1wI)bYjhyTdSEd1WKoddfX)WZnw1ulgXigQChdeAO3OmTg6nuymQAKBw1qXGTGWEmuK8Rv7GxlcZcOTJcDXeosNrfJrvJCd1WKoddfj)AlmfJyuEbd9gQHjDggQaf)i0UNqz0gkmgvnYnRAeJYR3qVHAysNHHQiSDzdrBjQl(hi3qHXOQrUzvJyuMUn0BOgM0zyOiFNldBHwJLngCdfgJQg5MvnIrzFzO3qHXOQrUzvdfd2cc7XqP(llRC0LrZSSeIviom5apoaj)AlX)a5hGghGUpWJdWYuZZnrLnATLdXHtKr)gHK6F3qnmPZWqXrxgQPwmIr5NWqVHcJrvJCZQgkgSfe2JHIKFTL4FG8dqJd4Rd84aSm18CtuzJwB5qC4ez0VriP(3nudt6mmue)dp3yvtTyeJY0fd9gQHjDggk2O1woehorg9BesmuymQAKBw1igXqjWoEJcXqVrzAn0BOWyu1i3SQHAysNHHI4F45gKBtOQnlTscDyigkgSfe2JHILPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpanoWclyOIXHgkI)HNBqUnHQ2S0kj0HHyeJYlyO3qHXOQrUzvdfd2cc7XqjJgdPYrxgnZYYG8D7sNrfJrvJ8d84aSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(bOXbwyLgQHjDggk2O12HjDgwDtedLUjInghAO8VBfyhVjgXO86n0BOWyu1i3SQHIJegS3Lodd16SSezc5aI)roGaNcO(aeDUrR4asEazGfr5aqCD9BiEGHZBPZy0ECacUpWrWd4FcUUJIgQHjDggk2O12HjDgwDtedLUjInghAOi6CJvGD8gfIrmkt3g6nuymQAKBw1qnmPZWqLfqyPo30rr7eTBSSPiAOyWwqypgQDuQC0LrZSIc4esDysxanuX4qdvwaHL6CthfTt0UXYMIOrmk7ld9gkmgvnYnRAOyWwqypgkb2XBuQcTv)dX(jOv9xwEGhhyhLkhDz0mROaoHuhM0fqd1WKoddLa74nk0AeJYpHHEdfgJQg5MvnumyliShdLa74nkvzHQ)Hy)e0Q(llpWJdSJsLJUmAMvuaNqQdt6cOHAysNHHsGD8gLfmIrz6IHEdfgJQg5MvnumyliShdL0o8aRDGcdShvnwlBirSIc4eIvAhEGhhGLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYpWAhyHvAOgM0zyOyJwBhM0zy1nrmu6Mi2yCOHA)drlFCtr0kWoEtmIrmu7FiA5JBkIwb2XBIHEJY0AO3qHXOQrUzvdvmo0qXH4WlBiAlGecQnudt6mmuCio8YgI2ciHGAJyuEbd9gkmgvnYnRAOIXHgks(12Uy0ccnudt6mmuK8RTDXOfeAeJYR3qVHcJrvJCZQgQHjDggQIAf7(TzPDiK216r6mmumyliShd1WKUaAXaDnsoG3dqRHkghAOkQvS73ML2HqAxRhPZWigLPBd9gkmgvnYnRAOIXHgk(aF7YmSCK92U)fisyyWqd1WKoddfFGVDzgwoYEB3)cejmmyOrmk7ld9gkmgvnYnRAOIXHgkunds(12cnbnudt6mmuOAgK8RTfAcAeJYpHHEdfgJQg5MvnuX4qd1py(NoqUTOE49ijKyj(h2Bnsmudt6mmu)G5F6a52I6H3JKqIL4FyV1iXigXqLfzCd9gLP1qVHAysNHHsfHee(UJIgkmgvnYnRAeJYlyO3qnmPZWqPQZKBl)qfgkmgvnYnRAeJYR3qVHAysNHHQSHOQotUHcJrvJCZQgXOmDBO3qnmPZWq9jOTf0rmuymQAKBw1igXigQciK0zyuEHvUaT0s7kP1qTzGrhfjgQN8tADt51HY(g08boa9(Xd0U9ekhOmHhyjIo3yfyhVrHS0bG4663qKFas6WdmFjDJG8dW8prrKuVT0zh4bOLMpWZZOacfKFaQ298dqueY86apJdi5bOZ)CaExOjDghi3r4ij8a(SONhWNfE5z92sNDGhybA(appJciuq(bOA3ZparriZRd8moGKhGo)Zb4DHM0zCGChHJKWd4ZIEEaFw4LN1BlD2bEG1tZh45zuaHcYpav7E(bikczEDGNXbK8a05FoaVl0KoJdK7iCKeEaFw0Zd4Z6F5z92EBFYpP1nLxhk7BqZh4a07hpq72tOCGYeEGLyzbmMqSJARBrXshaIRRFdr(biPdpW8L0ncYpaZ)efrs92sNDGhGwA(appJciuq(bwIKFTAh86tx6asEGLi5xR2bV(0kgJQg5lDaFO9LN1BlD2bEGfO5d88mkGqb5hyjs(1QDWRpDPdi5bwIKFTAh86tRymQAKV0b8H2xEwVT0zh4bwpnFGNNrbeki)alrYVwTdE9PlDajpWsK8Rv7GxFAfJrvJ8LoGp0(YZ6TLo7apaDtZh45zuaHcYpWsK8Rv7GxF6shqYdSej)A1o41NwXyu1iFPd4ZcV8SEBPZoWd4lA(appJciuq(bwIKFTAh86tx6asEGLi5xR2bV(0kgJQg5lDaFw)lpR3w6Sd8apbnFGNNrbeki)alrYVwTdE9PlDajpWsK8Rv7GxFAfJrvJ8LoWihyD(mPZd4dTV8SEBPZoWdqxO5d88mkGqb5hyjs(1QDWRpDPdi5bwIKFTAh86tRymQAKV0b8H2xEwVT0zh4bOR08bEEgfqOG8dSej)A1o41NU0bK8alrYVwTdE9PvmgvnYx6aJCG15ZKopGp0(YZ6T92(KFsRBkVou23GMpWbO3pEG2TNq5aLj8aljkGtiwck)9Loaexx)gI8dqshEG5lPBeKFaM)jkIK6TLo7apW6P5d88mkGqb5hyj4pWYeweRpDPdi5bwc(dSmHfX6tRymQAKV0b8H2xEwVT32N8tADt51HY(g08boa9(Xd0U9ekhOmHhyjowoFTS0bG4663qKFas6WdmFjDJG8dW8prrKuVT0zh4bOR08bEEgfqOG8dSej)A1o41NU0bK8alrYVwTdE9PvmgvnYx6a(S(xEwVT0zh4bEw08bEEgfqOG8dSej)A1o41NU0bK8alrYVwTdE9PvmgvnYx6a(q7lpR3w6Sd8a0UanFGNNrbeki)alb)bwMWIy9PlDajpWsWFGLjSiwFAfJrvJ8LoGp0(YZ6TLo7apaTRNMpWZZOacfKFGLG)altyrS(0LoGKhyj4pWYeweRpTIXOQr(shyKdSoFM05b8H2xEwVT0zh4bOLUqZh45zuaHcYpWsWFGLjSiwF6shqYdSe8hyzclI1NwXyu1iFPd4dTV8SEBPZoWdqlDLMpWZZOacfKFGLG)altyrS(0LoGKhyj4pWYeweRpTIXOQr(shyKdSoFM05b8H2xEwVT0zh4bO9zrZh45zuaHcYpWsWFGLjSiwF6shqYdSe8hyzclI1NwXyu1iFPd4dTV8SEBVTp5N06MYRdL9nO5dCa69JhOD7juoqzcpWscSJ3Oqw6aqCD9BiYpajD4bMVKUrq(by(NOisQ3w6Sd8a(IMpWZZOacfKFGLeyhVrPsB9PlDajpWscSJ3OufARpDPd4dTV8SEBPZoWd8e08bEEgfqOG8dSKa74nk1fQpDPdi5bwsGD8gLQSq9PlDaFO9LN1B7T9j)Kw3uEDOSVbnFGdqVF8aTBpHYbkt4bwk3XaHlDaiUU(ne5hGKo8aZxs3ii)am)tuej1BlD2bEaAP5d88mkGqb5hyjs(1QDWRpDPdi5bwIKFTAh86tRymQAKV0bg5aRZNjDEaFO9LN1B7TDD42tOG8dq7kpWWKoJdOBIqQ3wd18f)j0qzO2HzzRrdfnrthW3rxgPolQ4ap5bQt27BlnrthWVi7eAEXfl2I)VALLUfjT7RhPZGbNszrs7ylEBPjA6akNfqNkcpWcECGfw5c0EBVT0enDGN7FIIiHMVT0enDGvCaQDuRpaDMS31Blnrthyfh4zgAfhaIS05WGFaFhDzOMA5a7qCfS0PoYb6Yd0YbAYb6GitihWNeEa)dKZgICGYeEa1KqqIN1BlnrthyfhW3m3GWdq17(Z4aJwNBq(b2H4kyPtDKdi5b2Hj7aDqKjKd47Old1ul1BlnrthyfhW3SGV5bKrJHCGoeec)7s92st00bwXbEsfYMFaQvxXApBtFJdq2h3b24hJdOi)lbXdePCGrn)YbK8aKVZLXbMdqVc4es92st00bwXbw3RrIFgCkLfx3L6rAnEaQuxad5aSjyO22LhG5FIIi)asEGoeec)7ITlR3wAIMoWkoa9qfhqYdmfYMFGndr6O4b8D0LrZoWZtiEaImS3K6TLMOPdSIdqpuXbK8aU5nEGChdeEGDyNWwuCGm0koWMe((aD5b2GhGnXbgM8hTwXbYDmoWMw8FG5a0RaoHuVT3wA6aRZxi7li)aQyzcXdWsN6ihqfl2bPEGNeJH7c5argRW)aDLF9bgM0zqoqgAf1B7WKodsDhIS0PoIsExSWa7rvJEeJd9w2qIyffWjeR0o0JC3lbfp6sVQ)YYQQotU(tK6F3JcJ(JEPDLEuy0F0IAc6L2fUTdt6mi1DiYsN6ik5DXpbTTGopIXHEj(hEUb52eQAZsRKqhgYTDysNbPUdrw6uhrjVlwIAlpDDmsNHhDPxPD4AR8bDSJsD0Db82omPZGu3HilDQJOK3fjFNld7ok32HjDgK6oezPtDeL8U4NG2wqNhX4qVs6qBwADzqey(jwwgeb(zsNb52omPZGu3HilDQJOK3f)e02c68igh6LKAC8tSeKbrXkiZF0RRpEBhM0zqQ7qKLo1ruY7ILAK4NbNs52omPZGu3HilDQJOK3f3Zni0s6D)z4rx6v9xww30AUTD7Kkrg271O9H6VSSYrxgnZYsiwjYWEtdVlCBhM0zqQ7qKLo1ruY7IC0LHAQfp6sV(OMeYYlpmPZOYrxgQPwQSHiExPNpi5xBj(hiNqd6(2omPZGu3HilDQJOK3fj(hEUXQMAXJU0lD4JAsilV8WKoJkhDzOMAPYgI4DLEU8YK8RTe)dKtwB932BlnDG15lK9fKFaSacvCaPD4be)4bgMKWd0KdmfMwpQASEBhM0zq8s2rT2Qt27B7WKodIsExKnATTe1()HGWB7WKodIsExCEHwjjKB7WKodIsExKJfYp06MIn72omPZGOK3fzJwBhM0zy1nr8igh6vGD8gfYTDysNbrjVlYgT2omPZWQBI4rmo0BUJbc9GiWMjEP1JU0RKflQXkltnp3eKhs7qAuyG9OQXAzdjIvuaNqSs7WhSm18CtujFNldlhDz0mROaoHuHOB6GqJcdShvnwlBirSIc4eIvAhUcPD4TDysNbrjVlYZ05rx6fILqK4Fu14TDysNbrjVlYgT2omPZWQBI4rmo0lllGXeIDuBDlk8GiWMjEP1JU0lj)A1o41IWSaA7OqxmHJ0zS8YK8Rv7GxlBuZTzPvvNes6ilVmj)A1o4vw6uhX6qElJ0zS8YSSagti1azWuNq(TDysNbrjVlUNsNHhDPxFyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCVR8H0oCTcdShvnwlBirSIc4eIvAhU8YK8Rv7GxHyzhi3Up6rWhSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqonwpD1ZB7WKodIsExKnATDysNHv3eXJyCOxrbCcXsq5VFBhM0zquY7ISrRTdt6mS6MiEeJd9MfzCpicSzIxA9Ol9UJsLJUmAMvuaNqQdt6c4TDysNbrjVlYrxgnZseigff)E0LE9HoG)altyrSUP1LqKtSKUyRTzPL83ryNql57Cz0rXhSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(AplpxEzF2rPYrxgnZkkGti1HjDb8Xokvo6YOzwrbCcPcr30bHgpHVTiJxDZlpVTdt6mik5Dr2O1woehorg9Bes8Ol9YYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5RTWkxHV8T0b8hyzclI1nTUeICIL0fBTnlTK)oc7eAjFNlJokEBhM0zquY7I75geAj9U)m8Ol9Q(llRBAn32UDsLid79A0(q9xww5OlJMzzjeRezyVPX6VTdt6mik5Dr1wJew(HfrRA6uriXJU0R6VSSkkGtivEUjEWYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5R5RB7WKodIsExSD76K0z4rx6DysxaTyGUgjRrRs(qRVvgngsLmmyx2mKBj5xtQymQAK75d1FzzDtR522TtQezyVxZ7t8q9xwwffWjKkp3epyzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMG8181TDysNbrjVl2UDDs6m8Ol9omPlGwmqxJK1w4H6VSSUP1CB72jvImS3R59jEO(llRIc4esLNBIhSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(A(6bDa)bwMWIyTD76K0fq7Ekyi9OF4dDiJgdPwctNv8JwI)HNBivmgvnYxEz1FzzTeMoR4hTe)dp3qQ)DpVTdt6mik5DX2TRtsNHhDP3HjDb0Ib6AKS2cpu)LL1nTMBB3oPsKH9EnVpXd1FzzTD76K0fq7Ekyi9ORq0nDqOXcpG)altyrS2UDDs6cODpfmKE032HjDgeL8Uy721jPZWJU0R6VSSUP1CB72jvImS3R5L2fEiJgdPsYV2YYG)BPIXOQr(dz0yi1sy6SIF0s8p8CdPIXOQr(d4pWYeweRTBxNKUaA3tbdPh9d1FzzvuaNqQ8Ct8GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYxZx32HjDgeL8Uyry7YgI2sux8pqUhDPx1KqEiTdTsA5nsJ1VYB7WKodIsExK8DUmSfAnw2yW9Ol9QMeYdPDOvslVrASaD92omPZGOK3fjFNldlhDz0mROaoH4rx6vnjKhs7qRKwEJ0GwFDBhM0zquY7I(NGBZsBXVMpHhDPxs(1wI)bY96RBlnDG1r5b8DioCIm63iKCGbIhy0qC4koWWKUa6XbI8abI8di5bitb8ae)dKtUTdt6mik5Dr)tWTzPT4xZNWJU0lj)AlX)a5R5D9p8zhLkhIdNiJ(ncRdt6c4YlVJsLJUmAMvuaNqQdt6cON32HjDgeL8UO)j42S0w8R5t4rx6LKFTL4FG818s7d1FzznqXpcT7jugD9V)GLPMNBIkB0AlhIdNiJ(ncjvi6MoiRTGVTiJxDZRB7WKodIsEx0)eCBwAl(18j8Ol9sYV2s8pq(AEP9bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKtJImE1nVEiTdxJ2fwrrgV6Mxp8r9xww5qC4ez0VriP(3FO(llRCioCIm63iKuHOB6GS2WKoJQ)j42S0w8R5tuXxi7lOvAhQ0WKoJk57Czy5OlJMzffWjKk(czFbTs7qpF4dDiJgdPs(oxg2cTglBm4vmgvnYxEz1FzzTqRXYgdE9V75TDysNbrjVlYgT2omPZWQBI4rmo0lllGXeIDuBDlk8GiWMjEP1JU0lDWYcymHulGH4xb82sth4j3I)8lhGAyWUSzi)au5xt84au5xFakb2VXd0Kdqeygfr4be)tCaFhDzOMAXJdqYd0Yb8pKdmhWFx0pcpWoStylkUTdt6mik5Drs(1wIa73OhDPx6qgngsLmmyx2mKBj5xtQymQAKFBPPdqTJb)a(o6YOzh45jejhOmHhGk)6dq5FGCYb(H06dqVc4eYbyzQ55M4an5amDsWdi5bG4WvCBhM0zquY7IC0LHAQfp6sVQ)YYkhDz0mllHyfIdtEqYV2s8pqonO7hSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(AlSYBlnDaF)d7O4bOxbCc5aeu(7ECaYog8d47OlJMDGNNqKCGYeEaQ8RpaL)bYj32HjDgeL8UihDzOMAXJU0R6VSSYrxgnZYsiwH4WKhK8RTe)dKtd6(bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKtdAx42omPZGOK3f5Old1ulE0LEv)LLvo6YOzwwcXkehM8GKFTL4FGCAq3p8r9xww5OlJMzzjeRezyVxBHLxwgngsLmmyx2mKBj5xtQymQAK75TDysNbrjVlYrxgQPw8Ol9Q(llRC0LrZSSeIviom5bj)AlX)a50GUFmmPlGwmqxJK1O92omPZGOK3fj5xBjcSFJ32HjDgeL8UiB0A7WKodRUjIhX4qVSSagti2rT1TO42sthyDuEaf5)aSjoqruoG6WEFajpGVoav(1hGY)a5KdOILjepGVdXHtKr)gHKdWYuZZnXbAYbG4Wv4XbAzjYbY3JIdi5bi7yWpG4hDhiYn32HjDgeL8UO)j42S0w8R5t4rx6LKFTL4FG818U(hSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(Al4Rh(iJgdPYrxgnZYgTUJIvmgvnYxEzwMAEUjQSrRTCioCIm63iKuHOB6GSMp(4RvqYV2s8pqUN(2HjDgvI)HNBSQPwQ4lK9f0kTd9uPHjDgv)tWTzPT4xZNOIVq2xqR0o0ZB7WKodIsExKNPZdMcMgTYalIcXlTE0LEHyjej(hvn(qAhUwHb2JQgRLnKiwrbCcXkTdVT00bE2qWd47Old1ulhOlpGI8VeepqXSJIhqYdOtcEaFhDz0Sd88eIhGid7nXJdGfW4aD5bAzj(b2mebpWCas(1hG4FG86TDysNbrjVlYrxgQPw8Ol9Q(llRC0LrZSSeIviom5H6VSSYrxgnZYsiwHOB6GqdAvQiJxDZlFR6VSSYrxgnZYsiwjYWEFBhM0zquY7Ie)dp3yvtTCBVTdt6mivIo3yfyhVrH49tqBlOZJyCOxs(1AuKokAHFvfE0LEzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCAidSikvEtKjy4ZWxpK2HRvyG9OQXAzdjIvuaNqSs7Wv4JmWIOu5nrMGHpdF55TDysNbPs05gRa74nkeL8U4NG2wqNhX4qVKFOQZKBhhk(vqep6sVSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqonKbweLkVjYem8z4Rhs7W1kmWEu1yTSHeXkkGtiwPD4k8rgyruQ8MitWWNHV882sth4zc5Xem8a(hYbMdq7chGGSm4hGJ6rXbMGFGMCaXpcXYeIhG8U33r(bkt4bkBiroa9kGtihqYdO7apWF)aBAX)be)4bGirUTdt6mivIo3yfyhVrHOK3f)e02c68igh6fD7kG4OTjKhtWqp6sVSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqon8rgyruQ8MitWWNHV8ujAx4bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKVMp(4JmWIOu5nrMGHpdF5Ps0UGNRGwF55dPD4AfgypQASw2qIyffWjeR0oCf(4JmWIOu5nrMGHpdF5Ps0UGN32B7WKodsLLfWycXoQTUffEj5xBHP4rx6LKFTAh8ArywaTDuOlMWr6mE4dltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKtJfw5YlZYuZZnrL8DUmSC0LrZSIc4esfIUPdIfFTJmb5RT(v65TDysNbPYYcymHyh1w3IcL8Uij)Almfp6sVK8Rv7GxlBuZTzPvvNes6ip2rPYrxgnZkkGti1HjDb82omPZGuzzbmMqSJARBrHsExKKFTfMIhDPxs(1QDWRBAn36)hIvgM0mYd6yhLkhDz0mROaoHuhM0fWhSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itq(A0sxVTdt6mivwwaJje7O26wuOK3f5iRDJ0rrRAQfp6sV(qYVwTdEvJd3QQWIVg3UgxEzs(1QDWRVXcDqSz(SJ6ok65dF2rPYrxgnZkkGti1HjDb8bj)AlX)a50yHLxMo2rPYrxgnZkkGti1HjDb8bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKVgDVspVTdt6mivwwaJje7O26wuOK3f5iRDJ0rrRAQfp6sV(qYVwTdETmHfr1egOfIfqyJKLx2hs(1QDWRfs9iTgTKuxad5bDqYVwTdE9nwOdInZNDu3rrp98bDSJsLJUmAMvuaNqQdt6c4TDysNbPYYcymHyh1w3IcL8UyPgj(zWPu8Ol9sYVwTdETqQhP1OLK6cyiE0HGq4FxSDPx1FzzTqQhP1OLK6cyi1)(TDysNbPYYcymHyh1w3IcL8UiHLFyhfTsl(rp6sVK8Rv7GxzPtDeRd5TmsNXJDuQC0LrZSIc4esDysxaVTdt6mivwwaJje7O26wuOK3fjS8d7OOvAXp6rx6Loi5xR2bVYsN6iwhYBzKoJB7WKodsLLfWycXoQTUffk5DX2TJbVJIw2idrG5UF0JU07okvo6YOzwrbCcPomPlGpi5xBj(hi37kVT32HjDgKQ)DRa74nX7NG2wqNhX4qVKok)ABr9W7rsiXIovn6UTdt6miv)7wb2XBIsEx8tqBlOZJyCOxshLFTDi7nCcHyrNQgD32B7WKodsnlY4EvribHV7O4TDysNbPMfzCL8UOQotUT8dvCBhM0zqQzrgxjVlw2quvNj)2omPZGuZImUsEx8tqBlOJCBVTdt6mi1Chde6LKFTfMIhDPxs(1QDWRfHzb02rHUychPZ42omPZGuZDmqOsExmqXpcT7jug9TDysNbPM7yGqL8Uyry7YgI2sux8pq(TDysNbPM7yGqL8Ui57Czyl0ASSXGFBhM0zqQ5ogiujVlYrxgQPw8Ol9Q(llRC0LrZSSeIviom5bj)AlX)a50GUFWYuZZnrLnATLdXHtKr)gHK6F)2omPZGuZDmqOsExK4F45gRAQfp6sVK8RTe)dKtdF9GLPMNBIkB0AlhIdNiJ(ncj1)(TDysNbPM7yGqL8UiB0AlhIdNiJ(ncj32B7WKodsD)drlFCtr0kWoEt8(jOTf05rmo0lhIdVSHOTasiO(2omPZGu3)q0Yh3ueTcSJ3eL8U4NG2wqNhX4qVK8RTDXOfeEBhM0zqQ7FiA5JBkIwb2XBIsEx8tqBlOZJyCO3IAf7(TzPDiK216r6m8Ol9omPlGwmqxJeV0EBhM0zqQ7FiA5JBkIwb2XBIsEx8tqBlOZJyCOx(aF7YmSCK92U)fisyyWWB7WKodsD)drlFCtr0kWoEtuY7IFcABbDEeJd9IQzqYV2wOj4TDysNbPU)HOLpUPiAfyhVjk5DXpbTTGopIXHE)bZ)0bYTf1dVhjHelX)WERrYT92omPZGufyhVrH49tqBlOZJyCOxI)HNBqUnHQ2S0kj0HH4rx6LLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPXclCBhM0zqQcSJ3OquY7ISrRTdt6mS6MiEeJd96F3kWoEt8Ol9kJgdPYrxgnZYYG8D7sNrfJrvJ8hSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqonwyL3wA6aRZYsKjKdi(h5acCkG6dq05gTIdi5bKbweLdaX11VH4bgoVLoJr7Xbi4(ahbpG)j46okEBhM0zqQcSJ3OquY7ISrRTdt6mS6MiEeJd9s05gRa74nkKB7WKodsvGD8gfIsEx8tqBlOZJyCO3Sacl15MokANODJLnfrp6sV7Ou5OlJMzffWjK6WKUaEBhM0zqQcSJ3OquY7IcSJ3OqRhDPxb2XBuQ0w9pe7NGw1Fz5JDuQC0LrZSIc4esDysxaVTdt6mivb2XBuik5Drb2XBuwWJU0Ra74nk1fQ(hI9tqR6VS8Xokvo6YOzwrbCcPomPlG32HjDgKQa74nkeL8UiB0A7WKodRUjIhX4qV7FiA5JBkIwb2XBIhDPxPD4AfgypQASw2qIyffWjeR0o8bltnp3evY35YWYrxgnZkkGtivi6Moiw81oYeKV2cR82EBhM0zqQIc4eILGYF3BGIFeA3tOmAp6sVSm18CtujFNldlhDz0mROaoHuHOB6GyXx7itqonO1x32HjDgKQOaoHyjO83vY7IfHTlBiAlrDX)a5E0LEzzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCAqlDzf(mmPZOs(oxgwo6YOzwrbCcPIVq2xqR0ouPHjDgvI)HNBSQPwQ4lK9f0kTd98HpSm18CtuzJwB5qC4ez0VriPcr30bHg0sxwHpdt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdvAysNrL8DUmSfAnw2yWR4lK9f0kTdvAysNrL4F45gRAQLk(czFbTs7qpxE5DuQCioCIm63iScr30bznwMAEUjQKVZLHLJUmAMvuaNqQq0nDqS4RDKjixPHjDgvY35YWYrxgnZkkGtiv8fY(cAL2HEEBhM0zqQIc4eILGYFxjVls(oxg2cTglBm4E0LE9HLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPbT(Af(mmPZOs(oxgwo6YOzwrbCcPIVq2xqR0o0Zh(WYuZZnrLnATLdXHtKr)gHKkeDtheAqRVwHpdt6mQKVZLHLJUmAMvuaNqQ4lK9f0kTdvAysNrL8DUmSfAnw2yWR4lK9f0kTd9C5L3rPYH4WjYOFJWkeDthK1yzQ55MOs(oxgwo6YOzwrbCcPcr30bXIV2rMGCLgM0zujFNldlhDz0mROaoHuXxi7lOvAh6PNlVSp0b8hyzclI1nTUeICIL0fBTnlTK)oc7eAjFNlJok(GLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYxJUxPN32HjDgKQOaoHyjO83vY7ISrRTCioCIm63iK4rx6LLPMNBIk57Czy5OlJMzffWjKkeDthel(AhzcYPbTlScFgM0zujFNldlhDz0mROaoHuXxi7lOvAhQ0WKoJkX)WZnw1ulv8fY(cAL2HEEBhM0zqQIc4eILGYFxjVls(oxgwo6YOzwrbCcXJU0R0oCTcdShvnwlBirSIc4eIvAh(WNDuQCioCIm63iSomPlGp2rPYH4WjYOFJWkeDthK1gM0zujFNldlhDz0mROaoHuXxi7lOvAh65dFOdz0yivY35YWwO1yzJbVIXOQr(YlVJsTqRXYgdEDysxa98HpK8RTe)dK7DLlVSp7Ou5qC4ez0VryDysxaFSJsLdXHtKr)gHvi6Moi0yysNrL8DUmSC0LrZSIc4esfFHSVGwPDOsdt6mQe)dp3yvtTuXxi7lOvAh65Yl7Zok1cTglBm41HjDb8Xok1cTglBm4vi6Moi0yysNrL8DUmSC0LrZSIc4esfFHSVGwPDOsdt6mQe)dp3yvtTuXxi7lOvAh65Yl7J6VSSwe2USHOTe1f)dKx)7pu)LL1IW2LneTLOU4FG8keDtheAmmPZOs(oxgwo6YOzwrbCcPIVq2xqR0ouPHjDgvI)HNBSQPwQ4lK9f0kTd90tJyeJba]] )


end
