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


    spec:RegisterPack( "Demonology", 20210831, [[d0ewTbqiKk5rif5sQIeBsv4tkjgfvOtrfSkLKIxrImlsu3sjKDjPFPemmQO6yiLwMsKNPKKPHuPUgvu2MQi6BkHIXHuroNssvRdPcZdPW9Os2NsQoOsO0cvs5HQIQjQeQUOssLnQksfFePIYivfPsNujP0kvkntKIANur(PQiPHIur1svfH8uKmvKQUQQiuTvvrO8vvrkJvvu2lf)Lsdg4Wkwmj9yuMmQUm0MLOptLA0sWPL61QsnBsDBQA3c)w0WvQoUQiy5iEoOPtCDv12LqFxPy8QsopjSEvrQA(krTFv2qRHEdfFe040soFjADoDAv0wD(QNwNt3gkrXoAO2h27XnAOIXJgQfh9zK60Tcd1(OqNd3qVHcMFcdnuuT)5gk1FRLvByunu8rqJtl58LO150PvrB15READ(Qw9gk4oYmoT0t(KgQcnNJHr1qXriZqT4OpJuNUvCGN2q0j79TTGi7q6yHfC3sHVALL(fGT)RhPZGrMszby7zlCBxSF3FOCGvrRYhyjNVeT32B7ZlmHBesh32fDaQDuRpanNS31B7IoWtn0koabzP3Jb)alo6Zqn1Yb2j4IyPxDKd0LhOLd0Wd0buMqoGJj5afgcNnq5aLj5aQjeIqhQ32fDa68CdsoavVxiJdmADUb5hyNGlILE1roGKhyNKSd0buMqoWIJ(mutTuVTl6a05fPZpGmAmKd0HGeYFxQ32fDGfBXS5hGATfT(t3Ko7aW9XFGnfW4akY)ke8arkhyuZVCajpa879zCG5a0RGmHuVTl6apD0iSaJmLYcpXs9iTgpavQlIHCa2emuB7YdWkmHBKFajpqhcsi)DX2L1B7Ioa9efhqYdmfZMFGndu6W9bwC0NrZoWZtcEaOmS3WQHs3qbAO3qb15gRq64nkqd9gNO1qVHcJrvJCZAgQHjDggky(1AuKoCBjFvfgkgPfK0JHILPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYpanoGme3Ou5nuMGHhyHd4Sd84as7XdS(bkoKEu1yTSjqXkkitiwP94bw0bC8aYqCJsL3qzcgEGfoGZoGdgQy8OHcMFTgfPd3wYxvHrmoTKHEdfgJQg5M1mudt6mmuWFOQZKBhpkfuafdfJ0cs6XqXYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5hGghqgIBuQ8gktWWdSWbC2bECaP94bw)afhspQASw2eOyffKjeR0E8al6aoEaziUrPYBOmbdpWchWzhWbdvmE0qb)HQotUD8OuqbumIXPvzO3qHXOQrUzndfhHmsVlDggQNkHhtWWduyGhyoaTlDaiYYGFaoQhfhyc(bA4bKcibltcEa47EFh5hOmjhOSjq5a0RGmHCajpGUd8a)9dSPLchqkGhGGqXqfJhnuOFxbbhTnj8ycgAOyKwqspgkwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)a04aoEaziUrPYBOmbdpWchWzhWHdO0bODPd84aSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(bw)aoEahpGJhqgIBuQ8gktWWdSWbC2bC4akDaAx6aoCGfDaAD2bC4apoG0E8aRFGIdPhvnwlBcuSIcYeIvApEGfDahpGJhqgIBuQ8gktWWdSWbC2bC4akDaAx6aoyOgM0zyOq)UccoABs4Xem0igXqvy3kKoEdn0BCIwd9gkmgvnYnRzOIXJgkyhLFT1TE49ijbArVQg9gQHjDggkyhLFT1TE49ijbArVQg9gX40sg6nuymQAKBwZqfJhnuWok)A7a3BYec0IEvn6nudt6mmuWok)A7a3BYec0IEvn6nIrmuSSigti2rT1TOWqVXjAn0BOWyu1i3SMHIrAbj9yOG5xR2bV6MKfrBhfB3jzKoJkgJQg5h4XbC8aSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(bOXbwY5hy5Lpaltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKFG1pWQC(bCWqnmPZWqbZV2ssXigNwYqVHcJrvJCZAgkgPfK0JHcMFTAh8AzJAUnlTQ6ectpSIXOQr(bECGDuQC0NrZSIcYesDysxenudt6mmuW8RTKumIXPvzO3qHXOQrUzndfJ0cs6XqbZVwTdEDtR52c)qSYWKMbRymQAKBOgM0zyOG5xBjPyeJt0THEdfgJQg5M1mumsliPhdLJhaMFTAh8QghUvvHfFn(DnwXyu1i)alV8bG5xR2bV(gl2b0M5tpQ7WDfJrvJ8d4WbECahpWokvo6ZOzwrbzcPomPlIh4XbG5xBHfgc)a04alDGLx(a01b2rPYrFgnZkkiti1HjDr8apoaltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKFG1paD78d4GHAysNHHIJS2pshUTQPwmIXjNzO3qHXOQrUzndfJ0cs6Xq54bG5xR2bVwMe3OAsc0sWIiPryfJrvJ8dS8YhWXdaZVwTdETyQhP1OfM6IyivmgvnYpWJdqxhaMFTAh86BSyhqBMp9OUd3vmgvnYpGdhWHd84a01b2rPYrFgnZkkiti1HjDr0qnmPZWqXrw7hPd3w1ulgX40tAO3qHXOQrUznd1WKoddvPgHfyKPumumsliPhdfm)A1o41IPEKwJwyQlIHuXyu1i3q1HGeYFxSDPHs9xwwlM6rAnAHPUigs9VBeJtlgd9gkmgvnYnRzOyKwqspgky(1QDWRS0RoI1J8wgPZOIXOQr(bECGDuQC0NrZSIcYesDysxenudt6mmuqw(jD42kTuanIXj6KHEdfgJQg5M1mumsliPhdfDDay(1QDWRS0RoI1J8wgPZOIXOQrUHAysNHHcYYpPd3wPLcOrmoT6n0BOWyu1i3SMHIrAbj9yO2rPYrFgnZkkiti1HjDr8apoam)AlSWq4hW1bCUHAysNHHQ97yW7WTLnYafsUxanIrmuIcYeIfIYF3qVXjAn0BOWyu1i3SMHIrAbj9yOyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMG8dqJdqRZmudt6mmubkfqIDpjYOnIXPLm0BOWyu1i3SMHIrAbj9yOyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMG8dqJdq7I5al6aoEGHjDgv437ZWYrFgnZkkitiv8fY(cAL2JhqPdmmPZOclm8CJvn1sfFHSVGwP94bC4apoGJhGLPMNBIkB0AlNGdhkJ(nsGvc6NoGhGghG2fZbw0bC8adt6mQWV3NHLJ(mAMvuqMqQ4lK9f0kThpGshyysNrf(9(mSfBnw2yWR4lK9f0kThpGshyysNrfwy45gRAQLk(czFbTs7Xd4WbwE5dSJsLtWHdLr)gjvc6NoGhy9dWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5hqPdmmPZOc)EFgwo6ZOzwrbzcPIVq2xqR0E8aoyOgM0zyOCtAF2e0wIA3)HWnIXPvzO3qHXOQrUzndfJ0cs6Xq54byzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMG8dqJdqRZoWIoGJhyysNrf(9(mSC0NrZSIcYesfFHSVGwP94bC4apoGJhGLPMNBIkB0AlNGdhkJ(nsGvc6NoGhGghGwNDGfDahpWWKoJk879zy5OpJMzffKjKk(czFbTs7XdO0bgM0zuHFVpdBXwJLng8k(czFbTs7Xd4WbwE5dSJsLtWHdLr)gjvc6NoGhy9dWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5hqPdmmPZOc)EFgwo6ZOzwrbzcPIVq2xqR0E8aoCahoWYlFahpaDDaYpWYK4gRBADjb5qlSD3ABwAH)DK0jXc)EFgD4UIXOQr(bECawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)aRFa625hWbd1WKoddf879zyl2ASSXGBeJt0THEdfgJQg5M1mumsliPhdfltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKFaACaAx6al6aoEGHjDgv437ZWYrFgnZkkitiv8fY(cAL2JhqPdmmPZOclm8CJvn1sfFHSVGwP94bCWqnmPZWqXgT2Yj4WHYOFJeOrmo5md9gkmgvnYnRzOyKwqspgkP94bw)afhspQASw2eOyffKjeR0E8apoGJhyhLkNGdhkJ(nsQdt6I4bECGDuQCcoCOm63iPsq)0b8aRFGHjDgv437ZWYrFgnZkkitiv8fY(cAL2JhWHd84aoEa66aYOXqQWV3NHTyRXYgdEfJrvJ8dS8YhyhLAXwJLng86WKUiEahoWJd44bG5xBHfgc)aUoGZpWYlFahpWokvobhoug9BKuhM0fXd84a7Ou5eC4qz0VrsLG(Pd4bOXbgM0zuHFVpdlh9z0mROGmHuXxi7lOvApEaLoWWKoJkSWWZnw1ulv8fY(cAL2JhWHdS8YhWXdSJsTyRXYgdEDysxepWJdSJsTyRXYgdELG(Pd4bOXbgM0zuHFVpdlh9z0mROGmHuXxi7lOvApEaLoWWKoJkSWWZnw1ulv8fY(cAL2JhWHdS8YhWXdO(llRUjTpBcAlrT7)q41)(bECa1Fzz1nP9ztqBjQD)hcVsq)0b8a04adt6mQWV3NHLJ(mAMvuqMqQ4lK9f0kThpGshyysNrfwy45gRAQLk(czFbTs7Xd4WbCWqnmPZWqb)EFgwo6ZOzwrbzcXigXqXXY5Rfd9gNO1qVHcJrvJCZAgkoczKEx6mmuRUxi7li)ayrKO4as7XdifWdmmjjhOHhykoTEu1y1qnmPZWqb3rT2Qt2BJyCAjd9gQHjDggk2O12sux4hcsmuymQAKBwZigNwLHEd1WKodd18cTscHgkmgvnYnRzeJt0THEd1WKoddfhlMFI1pUBMHcJrvJCZAgX4KZm0BOWyu1i3SMHAysNHHInATDysNHv3qXqPBOyJXJgkH0XBuGgX40tAO3qHXOQrUzndfJ0cs6XqjPB3ASYYuZZnb8apoG0E8a04afhspQASw2eOyffKjeR0E8apoaltnp3ev437ZWYrFgnZkkitivc6NoGhGghO4q6rvJ1YMafROGmHyL2JhyrhqApAOGcPzIXjAnudt6mmuSrRTdt6mS6gkgkDdfBmE0qL7yGeJyCAXyO3qHXOQrUzndfJ0cs6XqrWscclmQA0qnmPZWqXZ0BeJt0jd9gkmgvnYnRzOyKwqspgky(1QDWRUjzr02rX2DsgPZOIXOQr(bwE5daZVwTdETSrn3MLwvDcHPhwXyu1i)alV8bG5xR2bVYsV6iwpYBzKoJkgJQg5hy5LpallIXesnqgj1jHBOGcPzIXjAnudt6mmuSrRTdt6mS6gkgkDdfBmE0qXYIymHyh1w3IcJyCA1BO3qHXOQrUznd1WKoddfB0A7WKodRUHIHs3qXgJhnuIcYeIfIYF3igNO15g6nuymQAKBwZqXiTGKEmuoEawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)a04a068d84as7XdS(bkoKEu1yTSjqXkkitiwP94bw0bO15hy5Lpam)A1o4vcw2bYT7JEeSIXOQr(bECawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)a04aRIoDahmudt6mmu7P0zyeJt0sRHEdfgJQg5M1mumsliPhd1okvo6ZOzwrbzcPomPlIgkOqAMyCIwd1WKoddfB0A7WKodRUHIHs3qXgJhnuPBg3igNODjd9gkmgvnYnRzOyKwqspgkhpaDDaYpWYK4gRBADjb5qlSD3ABwAH)DK0jXc)EFgD4UIXOQr(bECawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)aRFGv)bC4alV8bC8a7Ou5OpJMzffKjK6WKUiEGhhyhLkh9z0mROGmHujOF6aEaACGN8aRMd4MXR(51bCWqnmPZWqXrFgnZcfcgULcgX4eTRYqVHcJrvJCZAgkgPfK0JHILPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYpW6hyjNFGfDaNDGvZbORdq(bwMe3yDtRljihAHT7wBZsl8VJKojw437ZOd3vmgvnYnudt6mmuSrRTCcoCOm63ibAeJt0s3g6nuymQAKBwZqXiTGKEmuQ)YY6MwZTTFhwHYWEFG1paTh4Xbu)LLvo6ZOzwwsWkug27dqJdSkd1WKodd1EUbjwyVxidJyCIwNzO3qHXOQrUzndfJ0cs6XqP(llRIcYesLNBId84aSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(bw)aoZqnmPZWqP2AeYYpXnAvtVksGgX4eTpPHEdfgJQg5M1mumsliPhd1WKUiAXa9ncpW6hG2dO0bC8a0EGvZbKrJHuHdJ0Lnd5wy(1WkgJQg5hWHd84aQ)YY6MwZTTFhwHYWEFG1DDGN8apoG6VSSkkitivEUjoWJdWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5hy9d4md1WKoddv731jSZWigNODXyO3qHXOQrUzndfJ0cs6XqnmPlIwmqFJWdS(bw6apoG6VSSUP1CB73HvOmS3hyDxh4jpWJdO(llRIcYesLNBId84aSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(bw)ao7apoaDDaYpWYK4gRTFxNWUiA3tbdPhDfJrvJ8d84aoEa66aYOXqQLK0BLcOfwy45gyfJrvJ8dS8Yhq9xwwljP3kfqlSWWZnW6F)aoyOgM0zyOA)UoHDggX4eT0jd9gkmgvnYnRzOyKwqspgQHjDr0Ib6BeEG1pWsh4Xbu)LL1nTMBB)oScLH9(aR76ap5bECa1FzzT976e2fr7Ekyi9ORe0pDapanoWsh4Xbi)altIBS2(DDc7IODpfmKE0vmgvnYnudt6mmuTFxNWodJyCI2vVHEdfgJQg5M1mumsliPhdL6VSSUP1CB73HvOmS3hyDxhG2LoWJdiJgdPcZV2YYG)BPIXOQr(bECaz0yi1ss6Tsb0clm8CdSIXOQr(bECaYpWYK4gRTFxNWUiA3tbdPhDfJrvJ8d84aQ)YYQOGmHu55M4apoaltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKFG1pGZmudt6mmuTFxNWodJyCAjNBO3qHXOQrUzndfJ0cs6XqPMq4bECaP9OvslVXdqJdSkNBOgM0zyOCtAF2e0wIA3)HWnIXPLO1qVHcJrvJCZAgkgPfK0JHsnHWd84as7rRKwEJhGghyj6KHAysNHHc(9(mSfBnw2yWnIXPLwYqVHcJrvJCZAgkgPfK0JHsnHWd84as7rRKwEJhGghGwNzOgM0zyOGFVpdlh9z0mROGmHyeJtlTkd9gkmgvnYnRzOyKwqspgky(1wyHHWpGRd4md1WKoddvHj42S06(R5tyeJtlr3g6nuymQAKBwZqnmPZWqvycUnlTU)A(egkoczKEx6mmuR2YdS4eC4qz0Vrc8adbpWOj4WvCGHjDru5de5bce5hqYdaNI4bGfgchAOyKwqspgky(1wyHHWpW6UoWQoWJd44b2rPYj4WHYOFJK6WKUiEGLx(a7Ou5OpJMzffKjK6WKUiEahmIXPLCMHEdfgJQg5M1mumsliPhdfm)AlSWq4hyDxhG2d84aQ)YYAGsbKy3tIm66F)apoaltnp3ev2O1wobhoug9BKaRe0pDapW6hyPdSAoGBgV6NxgQHjDggQctWTzP19xZNWigNw6jn0BOWyu1i3SMHIrAbj9yOG5xBHfgc)aR76a0EGhhGLPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYpanoGBgV6Nxh4XbK2Jhy9dq7shyrhWnJx9ZRd84aoEa1FzzLtWHdLr)gjW6F)apoG6VSSYj4WHYOFJeyLG(Pd4bw)adt6mQfMGBZsR7VMprfFHSVGwP94bu6adt6mQWV3NHLJ(mAMvuqMqQ4lK9f0kThpGdh4XbC8a01bKrJHuHFVpdBXwJLng8kgJQg5hy5LpG6VSSwS1yzJbV(3pGdgQHjDggQctWTzP19xZNWigNwAXyO3qHXOQrUzndfJ0cs6XqrxhGLfXycPwedPGcIHckKMjgNO1qnmPZWqXgT2omPZWQBOyO0nuSX4rdfllIXeIDuBDlkmIXPLOtg6nuymQAKBwZqnmPZWqbZV2cfs)gnuCeYi9U0zyOEATui)YbOggPlBgYpav(1qLpav(1hGsi9B8an8aqHKHBKCaPWehyXrFgQPwu(aW8aTCGcd8aZbk0UlGKdSt6K0IcdfJ0cs6Xqrxhqgngsfomsx2mKBH5xdRymQAKBeJtlT6n0BOWyu1i3SMHAysNHHIJ(mutTyO4iKr6DPZWqrTJb)alo6ZOzh45jbHhOmjhGk)6dqvyiC4b(H06dqVcYeYbyzQ55M4an8amDcXdi5bi4WvyOyKwqspgk1FzzLJ(mAMLLeSsWHjh4XbG5xBHfgc)a04a09bECawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)aRFGLCUrmoTkNBO3qHXOQrUznd1WKoddfh9zOMAXqXriJ07sNHHAX)KoCFa6vqMqoaeL)UYhaUJb)alo6ZOzh45jbHhOmjhGk)6dqvyiCOHIrAbj9yOu)LLvo6ZOzwwsWkbhMCGhhaMFTfwyi8dqJdq3h4XbyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMG8dqJdq7sgX40QO1qVHcJrvJCZAgkgPfK0JHs9xww5OpJMzzjbReCyYbECay(1wyHHWpanoaDFGhhWXdO(llRC0NrZSSKGvOmS3hy9dS0bwE5diJgdPchgPlBgYTW8RHvmgvnYpGdgQHjDggko6Zqn1IrmoTQLm0BOWyu1i3SMHIrAbj9yOu)LLvo6ZOzwwsWkbhMCGhhaMFTfwyi8dqJdq3h4XbgM0frlgOVr4bw)a0AOgM0zyO4Opd1ulgX40QwLHEd1WKoddfm)Alui9B0qHXOQrUznJyCAv0THEdfgJQg5M1mudt6mmuSrRTdt6mS6gkgkDdfBmE0qXYIymHyh1w3IcJyCAvoZqVHcJrvJCZAgQHjDggQctWTzP19xZNWqXriJ07sNHHA1wEaf5)aSjoGBuoG6WEFajpGZoav(1hGQWq4WdOILjbpWItWHdLr)gjWdWYuZZnXbA4bi4WvO8bAzf4bY3JIdi5bG7yWpGua9hiYngkgPfK0JHcMFTfwyi8dSURdSQd84aSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(bw)al5Sd84aoEaz0yivo6ZOzw2O1D4UIXOQr(bwE5dWYuZZnrLnATLtWHdLr)gjWkb9thWdS(bC8aoEaNDGfDay(1wyHHWpGdhy1CGHjDgvyHHNBSQPwQ4lK9f0kThpGdhqPdmmPZOwycUnlTU)A(ev8fY(cAL2JhWbJyCAvpPHEdfgJQg5M1mudt6mmu8m9gkgPfK0JHIGLeewyu14bECaP94bw)afhspQASw2eOyffKjeR0E0qXuW0OvgIBuGgNO1igNw1IXqVHcJrvJCZAgQHjDggko6Zqn1IHIJqgP3Lodd1tCiEGfh9zOMA5aD5buK)vi4bCND4(asEaDcXdS4OpJMDGNNe8aqzyVHkFaSighOlpqlRWpWMbk4bMdaZV(aWcdHxnumsliPhdL6VSSYrFgnZYscwj4WKd84aQ)YYkh9z0mlljyLG(Pd4bOXbO9akDa3mE1pVoWQ5aQ)YYkh9z0mlljyfkd7TrmoTk6KHEd1WKoddfSWWZnw1ulgkmgvnYnRzeJyO2jil9QJyO34eTg6nuymQAKBwZqnmPZWqvIAlp9DmsNHHIJqgP3Lodd1Q7fY(cYpGkwMe8aS0RoYbur3DaRhyXYy4UapqKXIkmeF5xFGHjDgWdKHwr1qXiTGKEmus7XdS(bC(bECa66a7OuhDxenIXPLm0BOgM0zyOGFVpdBjQD)hc3qHXOQrUznJyCAvg6nuymQAKBwZqfJhnus6rBwA9zafs(HwwgqH8zsNb0qnmPZWqjPhTzP1Nbui5hAzzafYNjDgqJyCIUn0BOWyu1i3SMHkgpAOGPgNcqlezeuScYke9t4JgQHjDggkyQXPa0crgbfRGScr)e(Ormo5md9gQHjDggQsnclWitPyOWyu1i3SMrmo9Kg6nuymQAKBwZqXiTGKEmuQ)YY6MwZTTFhwHYWEFG1paTh4Xbu)LLvo6ZOzwwsWkug27dqdxhyjd1WKodd1EUbjwyVxidJyCAXyO3qHXOQrUzndfJ0cs6Xq54buti8alV8bgM0zu5Opd1ulv2aLd46ao)aoCGhhaMFTfwyiC4bOXbOBd1WKoddfh9zOMAXigNOtg6nuymQAKBwZqXiTGKEmu01bC8aQjeEGLx(adt6mQC0NHAQLkBGYbCDaNFahoWYlFay(1wyHHWHhy9dSkd1WKoddfSWWZnw1ulgX40Q3qVHcJrvJCZAgQC3qbrXqnmPZWqvCi9OQrdvXHyJXJgQYMafROGmHyL2JgkgPfK0JHs9xwwv1zY1FOu)7gQIJ(JwudrdfTlzOko6pAOO15gX4eTo3qVHcJrvJCZAgQy8OHcwy45gKBtIQnlTss8yigQHjDggkyHHNBqUnjQ2S0kjXJHyeJyOYDmqIHEJt0AO3qHXOQrUzndfJ0cs6XqbZVwTdE1njlI2ok2UtYiDgvmgvnYnudt6mmuW8RTKumIXPLm0BOgM0zyOCtAF2e0wIA3)HWnuymQAKBwZigNwLHEd1WKoddf879zyl2ASSXGBOWyu1i3SMrmor3g6nuymQAKBwZqXiTGKEmuQ)YYkh9z0mlljyLGdtoWJdaZV2clme(bOXbO7d84aSm18CtuzJwB5eC4qz0VrcS(3nudt6mmuC0NHAQfJyCYzg6nuymQAKBwZqXiTGKEmuW8RTWcdHFaACaNDGhhGLPMNBIkB0AlNGdhkJ(nsG1)UHAysNHHcwy45gRAQfJyC6jn0BOgM0zyOyJwB5eC4qz0Vrc0qHXOQrUznJyedLq64nkqd9gNO1qVHcJrvJCZAgQHjDggkyHHNBqUnjQ2S0kjXJHyOyKwqspgkwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)a04alTKHkgpAOGfgEUb52KOAZsRKepgIrmoTKHEdfgJQg5M1mumsliPhdLmAmKkh9z0mlld43VlDgvmgvnYpWJdWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5hGghyjNBOgM0zyOyJwBhM0zy1numu6gk2y8OHQWUviD8gAeJtRYqVHcJrvJCZAgkoczKEx6mmuRUYsKjWdifg5aczkI6da15gTIdi5bKH4gLdqWNWVj4bgoVLoJrR8bG4(qgbpqHj46oCBOgM0zyOyJwBhM0zy1numu6gk2y8OHcQZnwH0XBuGgX4eDBO3qHXOQrUznd1WKoddvwejL6CthUTt0(XYg3OHIrAbj9yO2rPYrFgnZkkiti1HjDr0qfJhnuzrKuQZnD42or7hlBCJgX4KZm0BOWyu1i3SMHIrAbj9yOeshVrPk0wlmq7hIw1Fz5bECGDuQC0NrZSIcYesDysxenudt6mmucPJ3OqRrmo9Kg6nuymQAKBwZqXiTGKEmucPJ3OuLLQfgO9drR6VS8apoWokvo6ZOzwrbzcPomPlIgQHjDggkH0XBuwYigNwmg6nuymQAKBwZqXiTGKEmus7XdS(bkoKEu1yTSjqXkkitiwP94bECawMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKji)aRFGLCUHAysNHHInATDysNHv3qXqPBOyJXJgQ9pbT8XpUrRq64n0igXqT)jOLp(XnAfshVHg6norRHEdfgJQg5M1muX4rdfNGdVSjOTicHO2qnmPZWqXj4WlBcAlIqiQnIXPLm0BOWyu1i3SMHkgpAOG5xBB3rliXqnmPZWqbZV22UJwqIrmoTkd9gkmgvnYnRzOgM0zyOCRvSxWML2bcBFRhPZWqXiTGKEmudt6IOfd03i8aUoaTgQy8OHYTwXEbBwAhiS9TEKodJyCIUn0BOWyu1i3SMHkgpAO4d5TpZWYr2B7(xiiKHbdnudt6mmu8H82Nzy5i7TD)leeYWGHgX4KZm0BOWyu1i3SMHkgpAOq1mG5xBl2q0qnmPZWqHQzaZV2wSHOrmo9Kg6nuymQAKBwZqfJhnu)Gvy6a5w36H3JKeOfwyyV1i0qnmPZWq9dwHPdKBDRhEpssGwyHH9wJqJyedv6MXn0BCIwd9gQHjDggkvKarY7oCBOWyu1i3SMrmoTKHEd1WKoddLQotUT8tuyOWyu1i3SMrmoTkd9gQHjDggQYMGQ6m5gkmgvnYnRzeJt0THEd1WKodd1hI2wqp0qHXOQrUznJyeJyOkIeyNHXPLC(s06C60sRYqTzirhUHgQN2I9jYPvRt0z0Xboa9fWd0(9KihOmjhyfOo3yfshVrbUYbi4t43eKFay6XdmFj9JG8dWkmHBewVT0Ch4bOLooWZZOiseKFaQ2)8daveY86apLdi5bO5)CaExSHDghi3rYij5aoUGdhWXLE5q92sZDGhyj64appJIirq(bOA)ZpauriZRd8uoGKhGM)Zb4DXg2zCGChjJKKd44coCahx6Ld1Bln3bEGvrhh45zuejcYpav7F(bGkczEDGNYbK8a08FoaVl2WoJdK7izKKCahxWHd44QE5q92EBFAl2NiNwTorNrhh4a0xapq73tICGYKCGvyzrmMqSJARBrXkhGGpHFtq(bGPhpW8L0pcYpaRWeUry92sZDGhGw64appJIirq(bwbMFTAh86Zw5asEGvG5xR2bV(SkgJQg5RCahP9Ld1Bln3bEGLOJd88mkIeb5hyfy(1QDWRpBLdi5bwbMFTAh86ZQymQAKVYbCK2xouVT0Ch4bwfDCGNNrrKii)aRaZVwTdE9zRCajpWkW8Rv7GxFwfJrvJ8voWihy19uP5d4iTVCOEBP5oWdq30XbEEgfrIG8dScm)A1o41NTYbK8aRaZVwTdE9zvmgvnYx5aoU0lhQ3wAUd8aoJooWZZOiseKFGvG5xR2bV(SvoGKhyfy(1QDWRpRIXOQr(khWXv9YH6TLM7apWtshh45zuejcYpWkW8Rv7GxF2khqYdScm)A1o41NvXyu1iFLdmYbwDpvA(aos7lhQ3wAUd8alg64appJIirq(bwbMFTAh86Zw5asEGvG5xR2bV(SkgJQg5RCahP9Ld1Bln3bEa6eDCGNNrrKii)aRaZVwTdE9zRCajpWkW8Rv7GxFwfJrvJ8voWihy19uP5d4iTVCOEBVTpTf7tKtRwNOZOJdCa6lGhO97jroqzsoWkIcYeIfIYFFLdqWNWVji)aW0Jhy(s6hb5hGvyc3iSEBP5oWdSk64appJIirq(bwH8dSmjUX6Zw5asEGvi)altIBS(SkgJQg5RCahP9Ld1B7T9PTyFICA16eDgDCGdqFb8aTFpjYbktYbwHJLZxlRCac(e(nb5haME8aZxs)ii)aSct4gH1Bln3bEa6eDCGNNrrKii)aRaZVwTdE9zRCajpWkW8Rv7GxFwfJrvJ8voGJR6Ld1Bln3bEaADoDCGNNrrKii)aRaZVwTdE9zRCajpWkW8Rv7GxFwfJrvJ8voGJ0(YH6TLM7apaTlrhh45zuejcYpWkKFGLjXnwF2khqYdSc5hyzsCJ1NvXyu1iFLd4iTVCOEBP5oWdq7QOJd88mkIeb5hyfYpWYK4gRpBLdi5bwH8dSmjUX6ZQymQAKVYbg5aRUNknFahP9Ld1Bln3bEaAxm0XbEEgfrIG8dSc5hyzsCJ1NTYbK8aRq(bwMe3y9zvmgvnYx5aos7lhQ3wAUd8a0sNOJd88mkIeb5hyfYpWYK4gRpBLdi5bwH8dSmjUX6ZQymQAKVYbg5aRUNknFahP9Ld1Bln3bEaAx90XbEEgfrIG8dSc5hyzsCJ1NTYbK8aRq(bwMe3y9zvmgvnYx5aos7lhQ32B7tBX(e50Q1j6m64ahG(c4bA)EsKduMKdSIq64nkWvoabFc)MG8datpEG5lPFeKFawHjCJW6TLM7apGZOJd88mkIeb5hyfH0XBuQ0wF2khqYdSIq64nkvH26Zw5aos7lhQ3wAUd8apjDCGNNrrKii)aRiKoEJsDP6Zw5asEGveshVrPklvF2khWrAF5q92EBFAl2NiNwTorNrhh4a0xapq73tICGYKCGvYDmqYkhGGpHFtq(bGPhpW8L0pcYpaRWeUry92sZDGhGw64appJIirq(bwbMFTAh86Zw5asEGvG5xR2bV(SkgJQg5RCGroWQ7PsZhWrAF5q92EBxT(9Kii)a068dmmPZ4a6gkW6T1qTtYYwJgkAIMoWIJ(msD6wXbEAdrNS33wAIMoqbr2H0Xcl4ULcF1kl9laB)xpsNbJmLYcW2Zw42st00bwSF3FOCGvrRYhyjNVeT32Blnrth45fMWncPJBlnrthyrhGAh16dqZj7D92st00bw0bEQHwXbiil9Em4hyXrFgQPwoWobxel9QJCGU8aTCGgEGoGYeYbCmjhOWq4SbkhOmjhqnHqe6q92st00bw0bOZZni5au9EHmoWO15gKFGDcUiw6vh5asEGDsYoqhqzc5alo6Zqn1s92st00bw0bOZlsNFaz0yihOdbjK)UuVT0enDGfDGfBXS5hGATfT(t3Ko7aW9XFGnfW4akY)ke8arkhyuZVCajpa879zCG5a0RGmHuVT0enDGfDGNoAewGrMszHNyPEKwJhGk1fXqoaBcgQTD5byfMWnYpGKhOdbjK)Uy7Y6TLMOPdSOdqprXbK8atXS5hyZaLoCFGfh9z0Sd88KGhakd7nSEBPjA6al6a0tuCajpGFEJhi3XajhyN0jPffhidTIdSjjVpqxEGn4bytCGHj)rRvCGChJdSPLchyoa9kiti1B7TLMoWQ7fY(cYpGkwMe8aS0RoYbur3DaRhyXYy4UapqKXIkmeF5xFGHjDgWdKHwr92omPZaw3jil9QJOKRfkrTLN(ogPZq5U0L0ECDN)GU2rPo6UiEBhM0zaR7eKLE1ruY1cWV3NHDhLB7WKodyDNGS0RoIsUw4drBlOx5y8Olj9OnlT(mGcj)qlldOq(mPZaEBhM0zaR7eKLE1ruY1cFiABb9khJhDbtnofGwiYiOyfKvi6NWhVTdt6mG1DcYsV6ik5AHsnclWitPCBhM0zaR7eKLE1ruY1c75gKyH9EHmuUlDP(llRBAn32(Dyfkd7960(q9xww5OpJMzzjbRqzyVPHRLUTdt6mG1DcYsV6ik5Abo6Zqn1IYDPlhvtiC5LhM0zu5Opd1ulv2afxo3HhW8RTWcdHdPbDFBhM0zaR7eKLE1ruY1cWcdp3yvtTOCx6IUCunHWLxEysNrLJ(mutTuzduC5ChwEzy(1wyHHWHRVQB7WKodyDNGS0RoIsUwO4q6rvJkhJhDv2eOyffKjeR0Eu5C3fefL7sxQ)YYQQotU(dL6Fx5IJ(JUO15kxC0F0IAi6I2LUTdt6mG1DcYsV6ik5AHpeTTGELJXJUGfgEUb52KOAZsRKepgYT92sthy19czFb5halIefhqApEaPaEGHjj5an8atXP1JQgR32HjDgqxWDuRT6K9(2omPZaQKRfyJwBlrDHFii52omPZaQKRfMxOvsi82omPZaQKRf4yX8tS(XDZUTdt6mGk5Ab2O12HjDgwDdfLJXJUeshVrbEBhM0zavY1cSrRTdt6mS6gkkhJhDL7yGeLHcPzIlAvUlDjPB3ASYYuZZnb8H0EKgfhspQASw2eOyffKjeR0E8bltnp3ev437ZWYrFgnZkkitivc6NoG0O4q6rvJ1YMafROGmHyL2JlsApEBhM0zavY1c8m9k3LUiyjbHfgvnEBhM0zavY1cSrRTdt6mS6gkkhJhDXYIymHyh1w3IcLHcPzIlAvUlDbZVwTdE1njlI2ok2UtYiDglVmm)A1o41Yg1CBwAv1jeME4YldZVwTdELLE1rSEK3YiDglVmllIXesnqgj1jHFBhM0zavY1cSrRTdt6mS6gkkhJhDjkitiwik)9B7WKodOsUwypLodL7sxoYYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb50GwN)qApUEXH0JQgRLnbkwrbzcXkThxeToF5LH5xR2bVsWYoqUDF0JGpyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMGCASk6Kd32HjDgqLCTaB0A7WKodRUHIYX4rxPBgxzOqAM4IwL7sx7Ou5OpJMzffKjK6WKUiEBhM0zavY1cC0NrZSqHGHBPGYDPlhPlYpWYK4gRBADjb5qlSD3ABwAH)DK0jXc)EFgD4(bltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKV(Q3HLx2XDuQC0NrZSIcYesDysxeFSJsLJ(mAMvuqMqQe0pDaPXtUACZ4v)8YHB7WKodOsUwGnATLtWHdLr)gjqL7sxSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(6l58f5SvdDr(bwMe3yDtRljihAHT7wBZsl8VJKojw437ZOd332HjDgqLCTWEUbjwyVxidL7sxQ)YY6MwZTTFhwHYWEVoTpu)LLvo6ZOzwwsWkug2BASQB7WKodOsUwqT1iKLFIB0QMEvKavUlDP(llRIcYesLNBIhSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(6o72omPZaQKRfA)UoHDgk3LUgM0frlgOVr460QKJ0UAKrJHuHdJ0Lnd5wy(1WkgJQg5o8q9xww30AUT97Wkug271D9Kpu)LLvrbzcPYZnXdwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKjiFDNDBhM0zavY1cTFxNWodL7sxdt6IOfd03iC9LEO(llRBAn32(Dyfkd796UEYhQ)YYQOGmHu55M4bltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKVUZEqxKFGLjXnwB)UoHDr0UNcgsp6hosxYOXqQLK0BLcOfwy45gyfJrvJ8Lxw9xwwljP3kfqlSWWZnW6F3HB7WKodOsUwO976e2zOCx6AysxeTyG(gHRV0d1FzzDtR522VdRqzyVx31t(q9xwwB)UoHDr0UNcgsp6kb9thqAS0dYpWYK4gRTFxNWUiA3tbdPh9TDysNbujxl0(DDc7muUlDP(llRBAn32(Dyfkd796UODPhYOXqQW8RTSm4)wQymQAK)qgngsTKKERuaTWcdp3aRymQAK)G8dSmjUXA731jSlI29uWq6r)q9xwwffKjKkp3epyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMG81D2TDysNbujxl4M0(SjOTe1U)dHRCx6snHWhs7rRKwEJ0yvo)2omPZaQKRfGFVpdBXwJLngCL7sxQje(qApAL0YBKglrNUTdt6mGk5Ab437ZWYrFgnZkkitik3LUuti8H0E0kPL3inO1z32HjDgqLCTqHj42S06(R5tOCx6cMFTfwyiCxo72sthy1wEGfNGdhkJ(nsGhyi4bgnbhUIdmmPlIkFGipqGi)asEa4uepaSWq4WB7WKodOsUwOWeCBwAD)18juUlDbZV2clme(6Uw1dh3rPYj4WHYOFJK6WKUiU8Y7Ou5OpJMzffKjK6WKUi6WTDysNbujxluycUnlTU)A(ek3LUG5xBHfgcFDx0(q9xwwdukGe7EsKrx)7pyzQ55MOYgT2Yj4WHYOFJeyLG(Pd46lTACZ4v)862omPZaQKRfkmb3MLw3FnFcL7sxW8RTWcdHVUlAFWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb50WnJx9ZRhs7X1PDPf5MXR(51dhv)LLvobhoug9BKaR)9hQ)YYkNGdhkJ(nsGvc6NoGRpmPZOwycUnlTU)A(ev8fY(cAL2JknmPZOc)EFgwo6ZOzwrbzcPIVq2xqR0E0HhosxYOXqQWV3NHTyRXYgdEfJrvJ8Lxw9xwwl2ASSXGx)7oCBhM0zavY1cSrRTdt6mS6gkkhJhDXYIymHyh1w3IcLHcPzIlAvUlDrxSSigti1IyifuqUT00bEATui)YbOggPlBgYpav(1qLpav(1hGsi9B8an8aqHKHBKCaPWehyXrFgQPwu(aW8aTCGcd8aZbk0UlGKdSt6K0IIB7WKodOsUwaMFTfkK(nQCx6IUKrJHuHdJ0Lnd5wy(1WkgJQg53wA6au7yWpWIJ(mA2bEEsq4bktYbOYV(aufgchEGFiT(a0RGmHCawMAEUjoqdpatNq8asEacoCf32HjDgqLCTah9zOMAr5U0L6VSSYrFgnZYscwj4WKhW8RTWcdHtd6(bltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKV(so)2sthyX)KoCFa6vqMqoaeL)UYhaUJb)alo6ZOzh45jbHhOmjhGk)6dqvyiC4TDysNbujxlWrFgQPwuUlDP(llRC0NrZSSKGvcom5bm)AlSWq40GUFWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb50G2LUTdt6mGk5Abo6Zqn1IYDPl1FzzLJ(mAMLLeSsWHjpG5xBHfgcNg09dhv)LLvo6ZOzwwsWkug271xA5LLrJHuHdJ0Lnd5wy(1WkgJQg5oCBhM0zavY1cC0NHAQfL7sxQ)YYkh9z0mlljyLGdtEaZV2clmeonO7hdt6IOfd03iCDAVTdt6mGk5Aby(1wOq634TDysNbujxlWgT2omPZWQBOOCmE0fllIXeIDuBDlkUT00bwTLhqr(paBId4gLdOoS3hqYd4SdqLF9bOkmeo8aQyzsWdS4eC4qz0Vrc8aSm18CtCGgEacoCfkFGwwbEG89O4asEa4og8difq)bICZTDysNbujxluycUnlTU)A(ek3LUG5xBHfgcFDxR6bltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKV(so7HJYOXqQC0NrZSSrR7WDfJrvJ8LxMLPMNBIkB0AlNGdhkJ(nsGvc6NoGR7OJoBrW8RTWcdH7WQzysNrfwy45gRAQLk(czFbTs7rhuAysNrTWeCBwAD)18jQ4lK9f0kThD42omPZaQKRf4z6vMPGPrRme3OaDrRYDPlcwsqyHrvJpK2JRxCi9OQXAztGIvuqMqSs7XBlnDGN4q8alo6Zqn1Yb6YdOi)RqWd4o7W9bK8a6eIhyXrFgn7appj4bGYWEdv(ayrmoqxEGwwHFGnduWdmhaMF9bGfgcVEBhM0zavY1cC0NHAQfL7sxQ)YYkh9z0mlljyLGdtEO(llRC0NrZSSKGvc6NoG0GwLCZ4v)8A1O(llRC0NrZSSKGvOmS332HjDgqLCTaSWWZnw1ul32B7WKodyfQZnwH0XBuGU(q02c6vogp6cMFTgfPd3wYxvHYDPlwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKjiNgYqCJsL3qzcg(uC2dP946fhspQASw2eOyffKjeR0ECrokdXnkvEdLjy4tXzoCBhM0zaRqDUXkKoEJcujxl8HOTf0RCmE0f8hQ6m52XJsbfqr5U0fltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKtdziUrPYBOmbdFko7H0EC9IdPhvnwlBcuSIcYeIvApUihLH4gLkVHYem8P4mhUT00bEQeEmbdpqHbEG5a0U0bGild(b4OEuCGj4hOHhqkGeSmj4bGV79DKFGYKCGYMaLdqVcYeYbK8a6oWd83pWMwkCaPaEaccLB7WKodyfQZnwH0XBuGk5AHpeTTGELJXJUq)UccoABs4Xemu5U0fltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKtdhLH4gLkVHYem8P4mhuI2LEWYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb5R7OJokdXnkvEdLjy4tXzoOeTl5WIO1zo8qApUEXH0JQgRLnbkwrbzcXkThxKJokdXnkvEdLjy4tXzoOeTl5WT92omPZawzzrmMqSJARBrHly(1wskk3LUG5xR2bV6MKfrBhfB3jzKoJhoYYuZZnrf(9(mSC0NrZSIcYesLG(PdOfFTJmb50yjNV8YSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itq(6RY5oCBhM0zaRSSigti2rT1TOqjxlaZV2ssr5U0fm)A1o41Yg1CBwAv1jeME4JDuQC0NrZSIcYesDysxeVTdt6mGvwweJje7O26wuOKRfG5xBjPOCx6cMFTAh86MwZTf(HyLHjndEBhM0zaRSSigti2rT1TOqjxlWrw7hPd3w1ulk3LUCeMFTAh8QghUvvHfFn(DnU8YW8Rv7GxFJf7aAZ8Ph1D42HhoUJsLJ(mAMvuqMqQdt6I4dy(1wyHHWPXslVmDTJsLJ(mAMvuqMqQdt6I4dwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKjiFD625oCBhM0zaRSSigti2rT1TOqjxlWrw7hPd3w1ulk3LUCeMFTAh8AzsCJQjjqlblIKgHlVSJW8Rv7GxlM6rAnAHPUigYd6cMFTAh86BSyhqBMp9OUd3o4Wd6AhLkh9z0mROGmHuhM0fXB7WKodyLLfXycXoQTUffk5AHsnclWitPOCx6cMFTAh8AXupsRrlm1fXquUdbjK)Uy7sxQ)YYAXupsRrlm1fXqQ)9B7WKodyLLfXycXoQTUffk5Abil)KoCBLwkGk3LUG5xR2bVYsV6iwpYBzKoJh7Ou5OpJMzffKjK6WKUiEBhM0zaRSSigti2rT1TOqjxlaz5N0HBR0sbu5U0fDbZVwTdELLE1rSEK3YiDg32HjDgWkllIXeIDuBDlkuY1cTFhdEhUTSrgOqY9cOYDPRDuQC0NrZSIcYesDysxeFaZV2clmeUlNFBVTdt6mG1c7wH0XBORpeTTGELJXJUGDu(1w36H3JKeOf9QA0FBhM0zaRf2TcPJ3qLCTWhI2wqVYX4rxWok)A7a3BYec0IEvn6VT32HjDgWA6MXDPIeisE3H7B7WKodynDZ4k5AbvDMCB5NO42omPZawt3mUsUwOSjOQot(TDysNbSMUzCLCTWhI2wqp82EBhM0zaR5ogiXfm)AljfL7sxW8Rv7GxDtYIOTJIT7KmsNXTDysNbSM7yGeLCTGBs7ZMG2su7(pe(TDysNbSM7yGeLCTa879zyl2ASSXGFBhM0zaR5ogirjxlWrFgQPwuUlDP(llRC0NrZSSKGvcom5bm)AlSWq40GUFWYuZZnrLnATLtWHdLr)gjW6F)2omPZawZDmqIsUwawy45gRAQfL7sxW8RTWcdHtdN9GLPMNBIkB0AlNGdhkJ(nsG1)(TDysNbSM7yGeLCTaB0AlNGdhkJ(nsG32B7WKodyD)tqlF8JB0kKoEdD9HOTf0RCmE0fNGdVSjOTicHO(2omPZaw3)e0Yh)4gTcPJ3qLCTWhI2wqVYX4rxW8RTT7OfKCBhM0zaR7FcA5JFCJwH0XBOsUw4drBlOx5y8Ol3Af7fSzPDGW236r6muUlDnmPlIwmqFJqx0EBhM0zaR7FcA5JFCJwH0XBOsUw4drBlOx5y8Ol(qE7ZmSCK92U)fcczyWWB7WKodyD)tqlF8JB0kKoEdvY1cFiABb9khJhDHQzaZV2wSH4TDysNbSU)jOLp(XnAfshVHk5AHpeTTGELJXJU(bRW0bYTU1dVhjjqlSWWERr4T92omPZawfshVrb66drBlOx5y8OlyHHNBqUnjQ2S0kjXJHOCx6ILPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYPXslDBhM0zaRcPJ3OavY1cSrRTdt6mS6gkkhJhDvy3kKoEdvUlDjJgdPYrFgnZYYa(97sNrfJrvJ8hSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itqonwY53wA6aRUYsKjWdifg5aczkI6da15gTIdi5bKH4gLdqWNWVj4bgoVLoJrR8bG4(qgbpqHj46oCFBhM0zaRcPJ3OavY1cSrRTdt6mS6gkkhJhDb15gRq64nkWB7WKodyviD8gfOsUw4drBlOx5y8ORSisk15MoCBNO9JLnUrL7sx7Ou5OpJMzffKjK6WKUiEBhM0zaRcPJ3OavY1ccPJ3OqRYDPlH0XBuQ0wlmq7hIw1Fz5JDuQC0NrZSIcYesDysxeVTdt6mGvH0XBuGk5AbH0XBuws5U0Lq64nk1LQfgO9drR6VS8Xokvo6ZOzwrbzcPomPlI32HjDgWQq64nkqLCTaB0A7WKodRUHIYX4rx7FcA5JFCJwH0XBOYDPlP946fhspQASw2eOyffKjeR0E8bltnp3ev437ZWYrFgnZkkitivc6NoGw81oYeKV(so)2EBhM0zaRIcYeIfIYF3vGsbKy3tImAL7sxSm18CtuHFVpdlh9z0mROGmHujOF6aAXx7itqonO1z32HjDgWQOGmHyHO83vY1cUjTpBcAlrT7)q4k3LUyzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMGCAq7IzroomPZOc)EFgwo6ZOzwrbzcPIVq2xqR0EuPHjDgvyHHNBSQPwQ4lK9f0kThD4HJSm18CtuzJwB5eC4qz0VrcSsq)0bKg0UywKJdt6mQWV3NHLJ(mAMvuqMqQ4lK9f0kThvAysNrf(9(mSfBnw2yWR4lK9f0kThvAysNrfwy45gRAQLk(czFbTs7rhwE5DuQCcoCOm63iPsq)0bCDwMAEUjQWV3NHLJ(mAMvuqMqQe0pDaT4RDKjixPHjDgv437ZWYrFgnZkkitiv8fY(cAL2JoCBhM0zaRIcYeIfIYFxjxla)EFg2ITglBm4k3LUCKLPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYPbToBroomPZOc)EFgwo6ZOzwrbzcPIVq2xqR0E0HhoYYuZZnrLnATLtWHdLr)gjWkb9thqAqRZwKJdt6mQWV3NHLJ(mAMvuqMqQ4lK9f0kThvAysNrf(9(mSfBnw2yWR4lK9f0kThDy5L3rPYj4WHYOFJKkb9thW1zzQ55MOc)EFgwo6ZOzwrbzcPsq)0b0IV2rMGCLgM0zuHFVpdlh9z0mROGmHuXxi7lOvAp6GdlVSJ0f5hyzsCJ1nTUKGCOf2UBTnlTW)os6KyHFVpJoC)GLPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYxNUDUd32HjDgWQOGmHyHO83vY1cSrRTCcoCOm63ibQCx6ILPMNBIk879zy5OpJMzffKjKkb9thql(AhzcYPbTlTihhM0zuHFVpdlh9z0mROGmHuXxi7lOvApQ0WKoJkSWWZnw1ulv8fY(cAL2JoCBhM0zaRIcYeIfIYFxjxla)EFgwo6ZOzwrbzcr5U0L0EC9IdPhvnwlBcuSIcYeIvAp(WXDuQCcoCOm63iPomPlIp2rPYj4WHYOFJKkb9thW1hM0zuHFVpdlh9z0mROGmHuXxi7lOvAp6WdhPlz0yiv437ZWwS1yzJbVIXOQr(YlVJsTyRXYgdEDysxeD4HJW8RTWcdH7Y5lVSJ7Ou5eC4qz0VrsDysxeFSJsLtWHdLr)gjvc6NoG0yysNrf(9(mSC0NrZSIcYesfFHSVGwP9Osdt6mQWcdp3yvtTuXxi7lOvAp6WYl74ok1ITglBm41HjDr8Xok1ITglBm4vc6NoG0yysNrf(9(mSC0NrZSIcYesfFHSVGwP9Osdt6mQWcdp3yvtTuXxi7lOvAp6WYl7O6VSS6M0(SjOTe1U)dHx)7pu)LLv3K2NnbTLO29Fi8kb9thqAmmPZOc)EFgwo6ZOzwrbzcPIVq2xqR0EuPHjDgvyHHNBSQPwQ4lK9f0kThDWbd18LcjXqzeJyma]] )


end
