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

    local malicious_imps = {}
    local malicious_imps_v = {}

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
                -- Wild Imp: 104317 (40) and 279910 (20).
                if spellID == 104317 or spellID == 279910 then
                    local dur = ( spellID == 279910 and 20 or 40 )
                    table.insert( wild_imps, now + dur )

                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + dur ),
                        max = math.ceil( now + dur )
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


                elseif spellID == 364198 then
                    -- Tier 28: Malicious Imp
                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + 40 ),
                        max = math.ceil( now + 40 ),
                        malicious = true
                    }
                    table.insert( malicious_imps, now + 40 )


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
                    hog_time = now

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
        wipe( malicious_imps_v )

        for n, t in pairs( imps ) do
            if t.malicious then table.insert( malicious_imps_v, t.expires )
            else table.insert( wild_imps_v, t.expires ) end
        end

        table.sort( wild_imps_v )
        table.sort( malicious_imps_v )

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
                            " - Malicious Imp: %d, %.2f\n" ..
                            "Next Demon Exp. : %.2f",
                            tyrant_ready and "Yes" or "No",
                            buff.dreadstalkers.stack, buff.dreadstalkers.remains,
                            buff.vilefiend.stack, buff.vilefiend.remains,
                            buff.grimoire_felguard.stack, buff.grimoire_felguard.remains,
                            buff.wild_imps.stack, buff.wild_imps.remains,
                            buff.malicious_imps.stack, buff.malicious_imps.remains,
                            major_demon_expires )
        end
    end )


    spec:RegisterHook( "advance_end", function ()
        for i = #guldan_v, 1, -1 do
            local imp = guldan_v[i]

            if imp <= query_time then
                if ( imp + 40 ) > query_time then
                    insert( wild_imps_v, imp + 40 )
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
        elseif name == "malicious_imps" then db = malicious_imps_v
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

        for k, v in pairs( dreadstalkers_v ) do dreadstalkers_v [ k ] = v + duration end
        for k, v in pairs( vilefiend_v     ) do vilefiend_v     [ k ] = v + duration end
        for k, v in pairs( wild_imps_v     ) do wild_imps_v     [ k ] = v + duration end
        for k, v in pairs( malicious_imps_v) do malicious_imps_v[ k ] = v + duration end
        for k, v in pairs( grim_felguard_v ) do grim_felguard_v [ k ] = v + duration end
        for k, v in pairs( other_demon_v   ) do other_demon_v   [ k ] = v + duration end
    end )


    spec:RegisterStateFunction( "consume_demons", function( name, count )
        local db = other_demon_v

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
        elseif name == "malicious_imps" then db = malicious_imps_v
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
                        if exp >= query_time then c = c + ( set_bonus.tier28_2pc > 0 and 3 or 2 ) end
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
            duration = 40,

            meta = {
                up = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = wild_imps_v[ 1 ]; return exp and ( exp - 40 ) or 0 end,
                remains = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( wild_imps_v ) do
                        if exp > query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },


        malicious_imps = {
            duration = 40,

            meta = {
                up = function () local exp = malicious_imps_v[ #malicious_imps_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = malicious_imps_v[ 1 ]; return exp and ( exp - 40 ) or 0 end,
                remains = function () local exp = malicious_imps_v[ #malicious_imps_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( malicious_imps_v ) do
                        if exp > query_time then c = c + 1 end
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

    spec:RegisterStateExpr( "last_cast_imps", function ()
        local count = 0

        for i, imp in ipairs( wild_imps_v ) do
            if imp - query_time <= 2 * haste then count = count + 1 end
        end

        return count
    end )

    spec:RegisterStateExpr( "last_cast_imps", function ()
        local count = 0

        for i, imp in ipairs( wild_imps_v ) do
            if imp - query_time <= 4 * haste then count = count + 1 end
        end

        return count
    end )


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

    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364436, "tier28_4pc", 3643951 )
    -- 2-Set - Ripped From the Portal - Call Dreadstalkers has a 100% chance to summon an additional Dreadstalker.
    -- 4-Set - Malicious Imp-Pact - Your Hand of Gul'dan has a 15% chance per Soul Shard to summon a Malicious Imp. When slain, Malicious Imp will either deal (85% of Spell power) Fire damage to all nearby enemies of your Implosion or deal it to your current target.
    


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
                summon_demon( "dreadstalkers", 12, set_bonus.tier28_2pc > 0 and 3 or 2 )
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
                removeStack( "power_siphon" )
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
                if buff.malicious_imps.up then
                    consume_demons( "malicious_imps", "all" )
                end
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
                addStack( "power_siphon", 20, num )
            end,

            auras = {
                power_siphon = {
                    id = 334581,
                    duration = 20,
                    max_stack = 2,
                    generate = function( t )
                        -- Detect via hidden aura.
                        local name, _, count, _, duration, expires, caster, _, _, spellID = GetPlayerAuraBySpellID( 334581 )

                        if name then
                            t.count = max( 1, count )
                            t.expires = expires
                            t.applied = expires - duration
                            t.caster = caster
                            return
                        end
            
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
                }
            }
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


    spec:RegisterPack( "Demonology", 20220221, [[d0K26bqiPI8ikr5suIeSjPQ(KuHrrP4uukTkuq6vuHMfkQBPuKDjLFjvQHjvPogvWYKk5zkf10qbCnPkzBsfLVrjsnouqCoPIQwhLiMNQIUhk1(uv4GOaPfkvXdrb1evkKlIcu2iLiP(OurfJKsKiNuPq1kvkntkr1oPI6NkfknuPIkTuLcfpfutLs4QuIeARuIe1xrbQgRsb7LI)syWiDyHfRkpMOjtvxgAZuPpJsgnLQtl61OqZgv3wj7wYVvmCvvhhfiwoWZrmDsxhKTRu9DuKXRQ05PKwpLijZNkY(vzJdglmW(qrJZD17U6Q3D1LdTU2SdD(EzPnWQ1F0a)hsgdwObUIfAG3iCn1WhwwnW)Hv(eEJfgyYabKObgoxmSb(bLCDJxMNb2hkACURE3vx9URUCO11MDOZ3RoZat(rPX5U6SoZaBp9ESmpdShjsd8gHRPg(WY6rzWdaFKmEBTR6pXs6UBwPAh61KZQBsUG4HMtjbHR2njxYUVTwQXhakawpAxoW8r7Q3D11T92YW2JIfsSKB7Mok8pY5h1YhjJTB7Mo6gBXTEuakN1cl)r3iCn1B46r)b4MKZ6f6rt3JM6rtYrZIOrPh1MbCu7bWldIEu3bC03qiiX22TDthTZDycbhfo)Tp1rdoFyc9h9hGBsoRxOhvNJ(dg5rZIOrPhDJW1uVHRTB7MoAN7EN7r1GJLE0SueaG(12TDthLbDFs)rH7ztFyP005CuYFSokt2X6OwhOoa4rRrpA8gi9O6Cuc0An1rJJAHvquA72UPJAPMJe7sq4QDBP8Wdn54rHh(ow6rLrjrUiDpQ0EuSq)r15OzPiaa9RI0TDB30rTay9O6C0yFs)rzkiAwSo6gHRPs5rz4bGhLOHKrs72UPJAbW6r15ORGr8OZpwi4O)GCaPA9OtXTEuMgaJhnDpkt4rLrD0qQqbNB9OZpwhLPuTF04OwyfeL2mW8KOeJfg45hleySW4SdglmWyfpo6n9yGLGurqggyYaXFz5BSaZokYApznGqZPAyfpo6nWHuZPmWKbIlaJAuJZDzSWahsnNYaxOAhbI)bOb3aJv84O30JrnoVzJfg4qQ5ugywGCnjafUiNfua8gySIhh9MEmQXzgWyHboKAoLbMaTwtj2to6My5nWyfpo6n9yuJZ9YyHbgR4XrVPhdSeKkcYWatgiUGypa(J(5r71r7Fu5mC)Wu1KbNl8am8en4mIasd63ahsnNYatSh(HjXB4Qrno3zglmWyfpo6n9yGLGurqgg49aKXJJnickEdxfAUYIf5O9pkzG4cI9a4p6NhTxhT)rFqUUTxWrYF6rar8GavwSeYbGnIgsgp6NhLbmWHuZPmWe7HFys8gUAuJZwAJfg4qQ5ugyzW5cpadprdoJiGyGXkEC0B6XOg1aB)xOGSyKySW4SdglmWyfpo6n9yGRyHgyswUqCblE4ZqharGRhhxg4qQ5ugyswUqCblE4ZqharGRhhxg14CxglmWyfpo6n9yGRyHgyswUqCrq(tqukrGRhhxg4qQ5ugyswUqCrq(tqukrGRhhxg1Ogy5SJvuQiEjpvRglmo7GXcdmwXJJEtpgyjiveKHbMmq8xw(glWSJIS2twdi0CQgwXJJ(J2)O2C09aKXJJTc)Qc1kikvi9h9ZJ2vVpQtoD09aKXJJTc)Qc1kikvi9h9JJU5EFuBnWHuZPmWKbIlaJAuJZDzSWaJv84O30JbwcsfbzyGjde)LLV5Mi3lgxXJpeYSinSIhh9hT)r)rT5X1uPuOwbrPTqQ5oAGdPMtzGjdexag1OgN3SXcdmwXJJEtpgyjiveKHbMmq8xw(gtj3lSdvQqdPMssdR4Xr)r7F0oD0FuBECnvkfQvquAlKAUJhT)r3dqgpo2k8RkuRGOuH0F0poQdmedCi1CkdmzG4cWOg14mdySWaJv84O30JboKAoLb2JYCfAwSeVHRgyjiveKHbUthDpaz84ydIGI3WvHMRSyroA)JAZrjde)LLVXXWlEwf43y9ZXgwXJJ(J6KthLmq8xw(gJ4EweXmwQqEwSAyfpo6pQThT)rT5O)O284AQukuRGO0wi1ChpA)JsgiUGypa(J(5r76Oo50r70r)rT5X1uPuOwbrPTqQ5oE0(hDpaz84yRWVQqTcIsfs)r)4OmqVpQTgyPvjhfAayHkX4Sdg14CVmwyGXkEC0B6XahsnNYa7rzUcnlwI3WvdSeKkcYWa3PJUhGmECSbrqXB4QqZvwSihT)rT5OKbI)YY3Chal8nGcfaChbjsAyfpo6pQtoDuBokzG4VS8T9HhAYrbz47yPnSIhh9hT)r70rjde)LLVXiUNfrmJLkKNfRgwXJJ(JA7rT9O9pANo6pQnpUMkLc1kikTfsn3rdS0QKJcnaSqLyC2bJACUZmwyGXkEC0B6XahsnNYa7rzUcnlwI3WvdSeKkcYWaVhGmECSbrqXB4QqZvwSihT)rT5OD6OAWXsB)dtiqqYF7t1WkEC0FuNC6OYz4(HPQ9pmHabj)TpvdGRilYr)8OHuZPAEuMRqZIL4nCTHFrjKIcnx4rT9O9pANoQCgUFyQAeO1AkHhxtLsHAfeL2G(pA)JAZr)rT5X1uPuOwbrPnaUISih9ZJYqoQtoDu5mC)Wu1iqR1ucpUMkLc1kikTbWvKfrGF)rPI(J(5r3CVpQTgyPvjhfAayHkX4Sdg14SL2yHbgR4XrVPhdCi1CkdSlhj2LGWvnWsqQiiddmzG4VS8T9HhAYrbz47yPnSIhh9hT)rFqUUT9HhAYrbz47yPn)WuzGZsraa6xfPRb(b5622hEOjhfKHVJL2G(nQXzgIXcdmwXJJEtpgyjiveKHbMmq8xw(MCwVqfl0NAO5unSIhh9hT)r)rT5X1uPuOwbrPTqQ5oAGdPMtzGjYbcKflHMQD0OgN78glmWyfpo6n9yGLGurqgg4oDuYaXFz5BYz9cvSqFQHMt1WkEC0BGdPMtzGjYbcKflHMQD0OgNDO3glmWyfpo6n9yGLGurqgg4FuBECnvkfQvquAlKAUJhT)rjdexqSha)rzF0EBGdPMtzGZ1pw(SyjKHgefm)2rJAudSAfeLkiOc9BSW4SdglmWyfpo6n9yGLGurqgg49aKXJJTc)Qc1kikvi9h9ZJ6qVmWHuZPmWfQ2rG4FaAWnQX5UmwyGXkEC0B6XalbPIGmmW7biJhhBf(vfQvquQq6p6Nh1bl9r30rT5OHuZPAeO1AkHhxtLsHAfeL2WVOesrHMl8OoE0qQ5unI9WpmjEdxB4xucPOqZfEuBpA)JAZrLZW9dtvtgCUWdWWt0GZicinaUISih9ZJ6GL(OB6O2C0qQ5unc0AnLWJRPsPqTcIsB4xucPOqZfEuhpAi1CQgbATMsSNC0nXY3WVOesrHMl8OoE0qQ5unI9WpmjEdxB4xucPOqZfEuBpQtoD0FuBEagEIgCgrqdGRilYr)4O7biJhhBf(vfQvquQq6pQJhnKAovJaTwtj84AQukuRGO0g(fLqkk0CHh1wdCi1CkdmlqUMeGcxKZckaEJACEZglmWyfpo6n9yGLGurqggyBo6EaY4XXwHFvHAfeLkK(J(5rDOxhDth1MJgsnNQrGwRPeECnvkfQvquAd)IsiffAUWJA7r7FuBoQCgUFyQAYGZfEagEIgCgraPbWvKf5OFEuh61r30rT5OHuZPAeO1AkHhxtLsHAfeL2WVOesrHMl8OoE0qQ5unc0AnLyp5OBILVHFrjKIcnx4rT9Oo50r)rT5by4jAWzebnaUISih9JJUhGmECSv4xvOwbrPcP)OoE0qQ5unc0AnLWJRPsPqTcIsB4xucPOqZfEuBpQTh1jNoQnhTthfavO7ayHnMsUla9ebjzLCX4kiq)iihGGaTwtLfRgwXJJ(J2)O7biJhhBf(vfQvquQq6p6hhLb69rT1ahsnNYatGwRPe7jhDtS8g14mdySWaJv84O30JbwcsfbzyG3dqgpo2k8RkuRGOuH0F0ppQdDD0nDuBoAi1CQgbATMs4X1uPuOwbrPn8lkHuuO5cpQJhnKAovJyp8dtI3W1g(fLqkk0CHh1wdCi1CkdSm4CHhGHNObNreqmQX5EzSWaJv84O30JbwcsfbzyG1CHh9JJUhGmECS5MaIkuRGOuHMl8O9pQnh9h1MhGHNObNre0cPM74r7F0FuBEagEIgCgrqdGRilYr)4OHuZPAeO1AkHhxtLsHAfeL2WVOesrHMl8O2E0(h1MJ2PJQbhlTrGwRPe7jhDtS8nSIhh9h1jNo6pQT9KJUjw(wi1ChpQThT)rT5OKbIli2dG)OSpAVpQtoDuBo6pQnpadprdoJiOfsn3XJ2)O)O28am8en4mIGgaxrwKJ(5rdPMt1iqR1ucpUMkLc1kikTHFrjKIcnx4rD8OHuZPAe7HFys8gU2WVOesrHMl8O2EuNC6O2C0FuB7jhDtS8TqQ5oE0(h9h12EYr3elFdGRilYr)8OHuZPAeO1AkHhxtLsHAfeL2WVOesrHMl8OoE0qQ5unI9WpmjEdxB4xucPOqZfEuBpQtoDuBo6dY1TXcKRjbOWf5SGcGVb9F0(h9b562ybY1Kau4ICwqbW3a4kYIC0ppAi1CQgbATMs4X1uPuOwbrPn8lkHuuO5cpQJhnKAovJyp8dtI3W1g(fLqkk0CHh12JARboKAoLbMaTwtj84AQukuRGOuJAudShDdiUASW4SdglmWyfpo6n9yG9ircYFnNYaZG9fLqk6pkUJaRhvZfEu1oE0qQd4Oj5OXEK84XXMboKAoLbM8JCUGpsgnQX5UmwyGdPMtzGLbNlCrUDOsrGbgR4XrVPhJACEZglmWHuZPmWXxuOdHyGXkEC0B6XOgNzaJfg4qQ5ugypUpqaXkyLsdmwXJJEtpg14CVmwyGXkEC0B6Xap)gycQg4qQ5ug49aKXJJg49GdHgy5mC)Wu1iqR1ucpUMkLc1kikTbWvKfrGF)rPIEdSeKkcYWa3PJsgi(llFZnrUxmUIhFiKzrAyfpo6pQtoDu5mC)Wu1iqR1ucpUMkLc1kikTbWvKfrGF)rPI(J(XrLZW9dtvJmqCby0gaxrweb(9hLk6nW7bquXcnWf(vfQvquQq6nQX5oZyHbgR4XrVPhd88BGjOAGdPMtzG3dqgpoAG3doeAGLZW9dtvJmqCby0gaxrweb(9hLk6nWsqQiiddmzG4VS8n3e5EX4kE8HqMfPHv84O)O9pQCgUFyQAeO1AkHhxtLsHAfeL2a4kYIiWV)Our)r)8OYz4(HPQrgiUamAdGRilIa)(Jsf9g49aiQyHg4c)Qc1kikvi9g14SL2yHbgR4XrVPhd88BGjOAGdPMtzG3dqgpoAG3doeAG3dqgpo2CtarfQvquQqZfE0nDunxObwcsfbzyG1CHh9ZJUhGmECS5MaIkuRGOuHMl0aVharfl0ax4xvOwbrPcP3OgNziglmWyfpo6n9yGNFdmbvdCi1Ckd8EaY4Xrd8EWHqd8EaY4XXwHFvHAfeLkKEdSeKkcYWa3PJUhGmECSbrqXB4QqZvwSig49aiQyHg4hKRRGyTKcP3OgN78glmWyfpo6n9yGNFdmbvdCi1Ckd8EaY4Xrd8EWHqdSCgUFyQAEuMRqZIL4nCTbWvKfrGF)rPIEdSeKkcYWaVhGmECSbrqXB4QqZvwSig49aiQyHg4hKRRGyTKcP3OgNDO3glmWyfpo6n9yGdPMtzGLbNlcPMtj4jrnW8KOIkwObwbzXiQeJAC2bhmwyGXkEC0B6XalbPIGmmW2C0oD09aKXJJnickEdxfAUYIf5O9p6pQnpUMkLc1kikTfsn3XJA7rDYPJAZr3dqgpo2GiO4nCvO5klwKJ2)Opix3gXEa8IXvevL2tEO5unO)J2)O2C0oDun4yPT)Hjeii5V9PAyfpo6pQtoD0hKRB7Fycbcs(BFQg0)rT9O2AGdPMtzGLbNlcPMtj4jrnW8KOIkwObEyj9g14SdDzSWaJv84O30JbwcsfbzyG1Hflo2KZW9dtf5O9pQMl8OFE09aKXJJn3equHAfeLk0CHgyIcsPAC2bdCi1CkdSm4Cri1CkbpjQbMNevuXcnWZpwiWOgNDyZglmWyfpo6n9yGLGurqggya6cqI94XrdCi1CkdSFMLrno7adySWaJv84O30JbwcsfbzyGjde)LLVXcm7OiR9K1acnNQHv84O)Oo50rjde)LLV5Mi3lgxXJpeYSinSIhh9h1jNokzG4VS8n5SEHkwOp1qZPAyfpo6pQtoDu5SJvuARqjy4dWBGjkiLQXzhmWHuZPmWYGZfHuZPe8KOgyEsurfl0alNDSIsfXl5PA1OgNDOxglmWyfpo6n9yGLGurqgg49aKXJJnickEdxfAUYIf5O9p6dY1TrShaVyCfrvP9KhAovd63ahsnNYa)pmHabj)TpLrno7qNzSWaJv84O30JbwcsfbzyGT5OD6O7biJhhBqeu8gUk0CLflYr7F09aKXJJTc)Qc1kikvi9hL9r79r7Funx4r)4O7biJhhBUjGOc1kikvO5cpQtoDuYaXFz5Ba0nl0l(dEOydR4Xr)r7F09aKXJJTc)Qc1kikvi9h9ZJUzgYrT9Oo50rT5O7biJhhBqeu8gUk0CLflYr7F0hKRBJypaEX4kIQs7jp0CQg0)rT1ahsnNYa)pAoLrno7GL2yHbgR4XrVPhdCi1CkdSm4Cri1CkbpjQbMNevuXcnWQvquQGGk0Vrno7adXyHbgR4XrVPhdSeKkcYWaBZr70rbqf6oawyJPK7cqprqswjxmUcc0pcYbiiqR1uzXQHv84O)O9p6EaY4XXwHFvHAfeLkK(J(Xr78h12J6Kth1MJ(JAZJRPsPqTcIsBHuZD8O9p6pQnpUMkLc1kikTbWvKf5OFE0o7Om0JYs6BR47rT1ahsnNYa7X1uPuquawSu7g14SdDEJfgySIhh9MEmWsqQiidd8EaY4XXgebfVHRcnxzXIC0(hvod3pmvnc0AnLWJRPsPqTcIsBaCfzre43FuQO)OFC0U6YahsnNYaldox4by4jAWzebeJACUREBSWaJv84O30JbwcsfbzyG70r3dqgpo2GiO4nCvO5klwKJ2)O2C09aKXJJTc)Qc1kikvi9h9JJ2vVp6MoAVokd9OD6OaOcDhalSXuYDbONiijRKlgxbb6hb5aeeO1AQSy1WkEC0FuBnWHuZPmWYGZfEagEIgCgraXOgN7YbJfgySIhh9MEmWsqQiiddCNo6EaY4XXgebfVHRcnxzXIC0(h9b562yk5ErU(jnIgsgp6hh1HJ2)Opix3MhxtLsHCayJOHKXJ(5r3SboKAoLb(Fycbcs(BFkJACURUmwyGXkEC0B6XalbPIGmmWpix3MAfeL28dt1r7F09aKXJJTc)Qc1kikvi9h9JJ2ldCi1Ckd8l5iroqawO4nRhcig14CxB2yHbgR4XrVPhdSeKkcYWahsn3rbw4krYr)4OoCuhpQnh1HJYqpQgCS0gjKG0nLOxqgioPHv84O)O2E0(h9b562yk5ErU(jnIgsgp6hSpAND0(h9b562uRGO0MFyQoA)JUhGmECSv4xvOwbrPcP)OFC0EzGdPMtzGZ1pFi5ug14CxmGXcdmwXJJEtpgyjiveKHboKAUJcSWvIKJ(Xr76O9p6dY1TXuY9IC9tAenKmE0pyF0o7O9p6dY1TPwbrPn)WuD0(hDpaz84yRWVQqTcIsfs)r)4O96O9pANokaQq3bWcB56NpKChf)JILMbVHv84O)O9pQnhTthvdowAZfmlHAhfe7HFyI0WkEC0FuNC6OE8b562CbZsO2rbXE4hMinO)JARboKAoLbox)8HKtzuJZD1lJfgySIhh9MEmWsqQiiddCi1ChfyHRejh9JJ21r7F0hKRBJPK7f56N0iAiz8OFW(OD2r7F0hKRBlx)8HK7O4FuS0m4naUISih9ZJ21r7FuauHUdGf2Y1pFi5ok(hflndEdR4XrVboKAoLbox)8HKtzuJZD1zglmWyfpo6n9yGLGurqgg4hKRBJPK7f56N0iAiz8OFW(Oo01r7Fun4yPnYaXfYP8qP2WkEC0F0(hvdowAZfmlHAhfe7HFyI0WkEC0F0(hfavO7ayHTC9ZhsUJI)rXsZG3WkEC0F0(h9b562uRGO0MFyQoA)JUhGmECSv4xvOwbrPcP)OFC0EzGdPMtzGZ1pFi5ug14CxwAJfgySIhh9MEmWsqQiidd8BiKJ2)OAUqHocFIh9ZJU5EBGdPMtzGzbY1Kau4ICwqbWBuJZDXqmwyGXkEC0B6XalbPIGmmWVHqoA)JQ5cf6i8jE0ppAxmedCi1CkdmbATMsSNC0nXYBuJZD15nwyGXkEC0B6XalbPIGmmWVHqoA)JQ5cf6i8jE0ppQd9YahsnNYatGwRPeECnvkfQvquQrnoV5EBSWaJv84O30JbwcsfbzyGjdexqSha)rzF0EzGdPMtzGThLxmUcwqCFug148MDWyHbgR4XrVPhdSeKkcYWatgiUGypa(J(5r71r7FuauHUdGf2Ebhj)PhbeXdcuzXsiha2WkEC0F0(h9b562Ebhj)PhbeXdcuzXsiha2a4kYIC0ppAVmWHuZPmWe7HFys8gUAuJZBUlJfgySIhh9MEmWHuZPmW2JYlgxbliUpkdShjsq(R5ug4nU7r3iagEIgCgra5ObapAWby4TE0qQ5oY8rR5OfI(JQZrjXoEuI9a4jgyjiveKHbMmqCbXEa8h9d2hDZhT)rT5O)O28am8en4mIGwi1ChpQtoD0FuBECnvkfQvquAlKAUJh1wJACEZB2yHbgR4XrVPhdSeKkcYWatgiUGypa(J(b7J6Wr7F0hKRBRq1oce)dqdEd6)O9pQCgUFyQAYGZfEagEIgCgraPbWvKf5OFC0Uokd9OSK(2k(AGdPMtzGThLxmUcwqCFug148MzaJfgySIhh9MEmWsqQiiddmzG4cI9a4p6hSpQdhT)r3dqgpo2k8RkuRGOuH0F0ppklPVTIVhT)r1CHh9JJUhGmECS5MaIkuRGOuHMl8OB6OSK(2k(AGdPMtzGThLxmUcwqCFug148M7LXcdmwXJJEtpgyjiveKHbUthvo7yfL22XsTBfyGjkiLQXzhmWHuZPmWYGZfHuZPe8KOgyEsurfl0alNDSIsfXl5PA1OgN3CNzSWaJv84O30JboKAoLbMmqCbrbjJOb2Jeji)1CkdmdEQ2hi9OWHeKUPe9hfEG4eMpk8aXpkScsgXJMKJsuWuSqWrv7rD0ncxt9gUY8rjZrt9O2dYrJJApzzhbh9hKdivRgyjiveKHbUthvdowAJesq6Ms0lideN0WkEC0BuJZB2sBSWaJv84O30JboKAoLb2JRPEdxnWEKib5VMtzGH)XYF0ncxtLYJYWdajh1DahfEG4hf2Ea8KJcvAYpQfwbrPhvod3pmvhnjhvYhcEuDokadVvdSeKkcYWa)GCDBECnvkfYbGnags9O9pkzG4cI9a4p6NhLboA)JUhGmECSv4xvOwbrPcP)OFC0U6TrnoVzgIXcdmwXJJEtpg4qQ5ugypUM6nC1a7rIeK)AoLbEJGazX6OwyfeLEucQq)mFuYpw(JUr4AQuEugEai5OUd4OWde)OW2dGNyGLGurqgg4hKRBZJRPsPqoaSbWqQhT)rjdexqSha)r)8OmWr7F09aKXJJTc)Qc1kikvi9h9ZJ6qxg148M78glmWyfpo6n9yGLGurqgg4hKRBZJRPsPqoaSbWqQhT)rjdexqSha)r)8OmWr7FuBo6dY1T5X1uPuiha2iAiz8OFC0UoQtoDun4yPnsibPBkrVGmqCsdR4Xr)rT1ahsnNYa7X1uVHRg14md0BJfgySIhh9MEmWsqQiiddmbvXBkistte0fdr01V8O9pkzG4cI9a4p6NhLboA)JAZrT5OD2r30rjdexqSha)rT9Om0JgsnNQrSh(HjXB4Ad)IsiffAUWJ(Xr)rT5by4jAWzebnaUISihDthnKAovZEuEX4kybX9r1WVOesrHMl8OB6OHuZPAECn1B4Ad)IsiffAUWJA7r7F0hKRBZJRPsPqoaSr0qY4r)G9rDWahsnNYa7X1uVHRg14md4GXcdmwXJJEtpgyjiveKHb(b56284AQukKdaBamK6r7FuYaXfe7bWF0ppkdC0(hnKAUJcSWvIKJ(XrDWahsnNYa7X1uVHRg14md0LXcdCi1CkdmzG4cIcsgrdmwXJJEtpg14mdSzJfgySIhh9MEmWHuZPmWYGZfHuZPe8KOgyEsurfl0alNDSIsfXl5PA1OgNzagWyHbgR4XrVPhdCi1CkdS9O8IXvWcI7JYa7rIeK)AoLbEJ7EuRd0rLrDuwOE0xiz8O6C0EDu4bIFuy7bWto6dDhaE0ncGHNObNreqoQCgUFyQoAsokadVvMpAQDqo6Wyy9O6CuYpw(JQ2X1rRHjdSeKkcYWatgiUGypa(J(b7JU5J2)O7biJhhBf(vfQvquQq6p6hhTRED0(h1MJQbhlT5X1uPuidoplwnSIhh9h1jNoQCgUFyQAYGZfEagEIgCgraPbWvKf5OFCuBoQnhTxhDthLmqCbXEa8h12JYqpAi1CQgXE4hMeVHRn8lkHuuO5cpQTh1XJgsnNQzpkVyCfSG4(OA4xucPOqZfEuBnQXzgOxglmWyfpo6n9yGdPMtzG9ZSmWsqQiiddmaDbiXE844r7Funx4r)4O7biJhhBUjGOc1kikvO5cnWsRsok0aWcvIXzhmQXzgOZmwyGXkEC0B6XahsnNYa7X1uVHRgypsKG8xZPmWwksWJUr4AQ3W1JMUh16a1bapkRjlwhvNJYhcE0ncxtLYJYWdapkrdjJeMpkUJ1rt3JMAh(JYuqu8OXrjde)Oe7bW3mWsqQiidd8dY1T5X1uPuiha2ayi1J2)Opix3MhxtLsHCaydGRilYr)8OoCuhpklPVTIVhLHE0hKRBZJRPsPqoaSr0qYOrnoZawAJfg4qQ5ugyI9WpmjEdxnWyfpo6n9yuJAG)bOCwVqnwyC2bJfgySIhh9MEmWHuZPmWUix4NvwHMtzG9ircYFnNYaZG9fLqk6p6dDhaEu5SEHE0hYkls7OmOsj(RKJwtTj7by5cXpAi1CkYrNIBTzGLGurqggynx4r)4O9(O9pANo6pQTGN7Orno3LXcdCi1CkdmbATMs4ICwqbWBGXkEC0B6XOgN3SXcdmwXJJEtpg453atq1ahsnNYaVhGmEC0aVhCi0a7qVnW7bquXcnWUjGOc1kikvO5cnQXzgWyHbgR4XrVPhd88BGjOAGdPMtzG3dqgpoAG3doeAGbqf6oawy7fCK8NEeqepiqLflHCaydR4Xr)r7FuauHUdGf2i2dGxmUIOQ0EYdnNQHv84O3aVharfl0adrqXB4QqZvwSig14CVmwyGXkEC0B6XaxXcnWe7HFyc9Ib8eJRqhWcl1ahsnNYatSh(Hj0lgWtmUcDalSuJACUZmwyGXkEC0B6XaxXcnW6SqX4kwtruWareYPikasQ5uedCi1CkdSolumUI1uefmqeHCkIcGKAofXOgNT0glmWyfpo6n9yGRyHgyYWXWorqqjavHIs7vYGaHg4qQ5ugyYWXWorqqjavHIs7vYGaHg14mdXyHboKAoLb2LJe7sq4QgySIhh9MEmQX5oVXcdmwXJJEtpgyjiveKHb(b562yk5ErU(jnIgsgp6hh1HJ2)Opix3MhxtLsHCayJOHKXJ(j7J2LboKAoLb(Fycbcs(BFkJAC2HEBSWaJv84O30JbwcsfbzyGT5OVHqoQtoD0qQ5unpUM6nCTjdIEu2hT3h12J2)OKbIli2dGNC0ppkdyGdPMtzG94AQ3WvJAC2bhmwyGXkEC0B6XalbPIGmmWD6O2C03qih1jNoAi1CQMhxt9gU2Kbrpk7J27JA7rDYPJsgiUGypaEYr)4OB2ahsnNYatSh(HjXB4QrnQbwbzXiQeJfgNDWyHbgR4XrVPhdCi1CkdmXE4hMqVyapX4k0bSWsnWsqQiidd8EaY4XX2dY1vqSwsH0F0ppAxDzGRyHgyI9WpmHEXaEIXvOdyHLAuJZDzSWaJv84O30JbwcsfbzyG1GJL284AQukKtrGw)AovdR4Xr)r7F09aKXJJTc)Qc1kikvi9h9ZJ2vVnWHuZPmWYGZfHuZPe8KOgyEsurfl0aB)xOGSyKyuJZB2yHbgR4XrVPhdShjsq(R5ugygmxxuQKJQ2d9Oki2r(rj8HjU1JQZr1aWc1JcqgeOeGhn8(uZPcoZhLG)biu8O2JYZZILboKAoLbwgCUiKAoLGNe1aZtIkQyHgycFysOGSyevIrnoZaglmWyfpo6n9yGdPMtzGNDe4YhMYILiQCfczWcnWsqQiiddSnhTthDpaz84ydIGI3WvHMRSyroA)J(JAZJRPsPqTcIsBHuZD8O2EuNC6O2C09aKXJJnickEdxfAUYIf5O9p6dY1TrShaVyCfrvP9KhAovd6)O2AGRyHg4zhbU8HPSyjIkxHqgSqJACUxglmWyfpo6n9yGdPMtzGvqwmIQdgyjiveKHbwbzXiQn1HM9GiGiO4b56E0(h1MJAZr70r3dqgpo2GiO4nCvO5klwKJ2)O)O284AQukuRGO0wi1ChpQTh1jNoQnhDpaz84ydIGI3WvHMRSyroA)J(GCDBe7bWlgxruvAp5HMt1G(pQTh1wdmHpQbwbzXiQoyuJZDMXcdmwXJJEtpg4qQ5ugyfKfJO2LbwcsfbzyGvqwmIAt7QzpicickEqUUhT)rT5O2C0oD09aKXJJnickEdxfAUYIf5O9p6pQnpUMkLc1kikTfsn3XJA7rDYPJAZr3dqgpo2GiO4nCvO5klwKJ2)Opix3gXEa8IXvevL2tEO5unO)JA7rT1at4JAGvqwmIAxg14SL2yHbgR4XrVPhdSeKkcYWaR5cp6hhDpaz84yZnbevOwbrPcnx4r7F09aKXJJThKRRGyTKcP)OFC0U6TboKAoLbwgCUiKAoLGNe1aZtIkQyHg4Fiak8XkyHcfKfJeJAud8peaf(yfSqHcYIrIXcJZoySWaJv84O30JbUIfAG9am8Ujaf7iHGCdCi1CkdShGH3nbOyhjeKBuJZDzSWaJv84O30JbUIfAGbizQOubajiyFsGboKAoLbgGKPIsfaKGG9jbg148MnwyGXkEC0B6XaxXcnWbqApvuQerwSWckvRc5aqdCi1CkdCaK2tfLkrKflSGs1Qqoa0OgNzaJfgySIhh9MEmWvSqdSCiRukyXdFg6aicasMk0byGdPMtzGLdzLsblE4ZqharaqYuHoaJACUxglmWyfpo6n9yGRyHgypadVBcqXosii3ahsnNYa7by4Dtak2rcb5g14CNzSWaJv84O30JbUIfAGjdexKSQurGboKAoLbMmqCrYQsfbg14SL2yHbgR4XrVPhdCi1CkdmlU1F7IXveesUsEO5ugyjiveKHboKAUJcSWvIKJY(OoyGRyHgywCR)2fJRiiKCL8qZPmQXzgIXcdmwXJJEtpg4kwOb2hagxZucpkzu8dPaKiXsIg4qQ5ugyFayCntj8OKrXpKcqIeljAuJZDEJfgySIhh9MEmWvSqdm(MImqCXEsqdCi1Ckdm(MImqCXEsqJAC2HEBSWaJv84O30JbUIfAGHkP9il0lyXdFg6aicI9qYihjg4qQ5ugyOsApYc9cw8WNHoaIGypKmYrIrnQbEyj9glmo7GXcdCi1Ckd8dbeeWywSmWyfpo6n9yuJZDzSWahsnNYa)4Z4fUqaRgySIhh9MEmQX5nBSWahsnNYa7Ma8XNXBGXkEC0B6XOgNzaJfg4qQ5ugyicksfxedmwXJJEtpg1Og1aVJasoLX5U6DxD17U6YbdmtbOYIfXaZGZGUX48g35ohl5Oh1c74rZ1)a0J6oGJ2X8Jfc64OaKbbkbO)OKzHhnG0zfk6pQ0EuSqs72A5zHh1bl5Om8u7iqr)r7Gmq8xw(2g64O6C0oide)LLVTHgwXJJ(ooAOhLbBJ1YpQno8122T92YGZGUX48g35ohl5Oh1c74rZ1)a0J6oGJ2HC2XkkveVKNQ1ookazqGsa6pkzw4rdiDwHI(JkThflK0UTwEw4rDWsokdp1ocu0F0oide)LLVTHooQohTdYaXFz5BBOHv84OVJJAJdFTTDBT8SWJ2LLCugEQDeOO)ODqgi(llFBdDCuDoAhKbI)YY32qdR4XrFhh1gh(AB72A5zHhDZwYrz4P2rGI(J2bzG4VS8Tn0Xr15ODqgi(llFBdnSIhh9DCuBC4RTTBRLNfEugWsokdp1ocu0F0oide)LLVTHooQohTdYaXFz5BBOHv84OVJJAtxFTTDBT8SWJ2ll5Om8u7iqr)r7Gmq8xw(2g64O6C0oide)LLVTHgwXJJ(ooQnB(RTTBRLNfE0oZsokdp1ocu0F0o0GJL22qhhvNJ2HgCS02gAyfpo674O24WxBB3wlpl8OwAl5Om8u7iqr)r7Gmq8xw(2g64O6C0oide)LLVTHgwXJJ(ooQno8122T1YZcpkdXsokdp1ocu0F0oide)LLVTHooQohTdYaXFz5BBOHv84OVJJAJdFTTDBT8SWJ25TKJYWtTJaf9hTdYaXFz5BBOJJQZr7Gmq8xw(2gAyfpo674OHEugSnwl)O24WxBB32Bldod6gJZBCN7CSKJEulSJhnx)dqpQ7aoAhQvquQGGk0FhhfGmiqja9hLml8ObKoRqr)rL2JIfsA3wlpl8OB2sokdp1ocu0F0oaqf6oawyBdDCuDoAhaOcDhalSTHgwXJJ(ooQno8122T92YGZGUX48g35ohl5Oh1c74rZ1)a0J6oGJ2HhDdiU2Xrbidcucq)rjZcpAaPZku0FuP9OyHK2T1YZcpAVSKJYWtTJaf9hTdYaXFz5BBOJJQZr7Gmq8xw(2gAyfpo674O24WxBB3wlpl8ODMLCugEQDeOO)ODqgi(llFBdDCuDoAhKbI)YY32qdR4XrFhh1gh(AB72A5zHh1bgWsokdp1ocu0F0oide)LLVTHooQohTdYaXFz5BBOHv84OVJJAZM)AB72A5zHh1HoZsokdp1ocu0F0oide)LLVTHooQohTdYaXFz5BBOHv84OVJJAJdFTTDBT8SWJ6adXsokdp1ocu0F0oaqf6oawyBdDCuDoAhaOcDhalSTHgwXJJ(ooQno8122T1YZcpAx92sokdp1ocu0F0oaqf6oawyBdDCuDoAhaOcDhalSTHgwXJJ(ooQno8122T1YZcpAxmGLCugEQDeOO)ODaGk0DaSW2g64O6C0oaqf6oawyBdnSIhh9DCuBC4RTTBRLNfE0U6LLCugEQDeOO)ODaGk0DaSW2g64O6C0oaqf6oawyBdnSIhh9DC0qpkd2gRLFuBC4RTTBRLNfE0U6ml5Om8u7iqr)r7aavO7ayHTn0Xr15ODaGk0DaSW2gAyfpo674O24WxBB3wlpl8OB2bl5Om8u7iqr)r7aavO7ayHTn0Xr15ODaGk0DaSW2gAyfpo674O24WxBB32Bldod6gJZBCN7CSKJEulSJhnx)dqpQ7aoAh)auoRxODCuaYGaLa0FuYSWJgq6Scf9hvApkwiPDBT8SWJYawYrz4P2rGI(J2baQq3bWcBBOJJQZr7aavO7ayHTn0WkEC03Xrd9OmyBSw(rTXHV22UTwEw4rzal5Om8u7iqr)r7aavO7ayHTn0Xr15ODaGk0DaSW2gAyfpo674O24WxBB32Bldod6gJZBCN7CSKJEulSJhnx)dqpQ7aoAhkilgrL0Xrbidcucq)rjZcpAaPZku0FuP9OyHK2T1YZcpAVSKJYWtTJaf9hTdfKfJO2COTHooQohTdfKfJO2uhABOJJAJdFTTDBT8SWJ2zwYrz4P2rGI(J2HcYIruBD12qhhvNJ2HcYIruBAxTn0XrTXHV22UT32n(6Fak6pAN)OHuZPokpjkPDBnWbKAFagyd8pyCtoAGTml7OBeUMA4dlRhLbpa8rY4T1YSSJAx1FIL0D3Ss1o0RjNv3KCbXdnNsccxTBsUKDFBTml7OwQXhakawpAxoW8r7Q3D11T92Azw2rzy7rXcjwYT1YSSJUPJc)JC(rT8rYy72Azw2r30r3ylU1Jcq5Swy5p6gHRPEdxp6pa3KCwVqpA6E0upAsoAwenk9O2mGJApaEzq0J6oGJ(gcbj22UTwMLD0nD0o3HjeCu483(uhn48Hj0F0FaUj5SEHEuDo6pyKhnlIgLE0ncxt9gU2UTwMLD0nD0o39o3JQbhl9OzPiaa9RTBRLzzhDthLbDFs)rH7ztFyP005CuYFSokt2X6OwhOoa4rRrpA8gi9O6Cuc0An1rJJAHvquA72Azw2r30rTuZrIDjiC1UTuE4HMC8OWdFhl9OYOKixKUhvApkwO)O6C0SueaG(vr62UTwMLD0nDulawpQohn2N0FuMcIMfRJUr4AQuEugEa4rjAizK0UTwMLD0nDulawpQohDfmIhD(Xcbh9hKdivRhDkU1JY0ay8OP7rzcpQmQJgsfk4CRhD(X6OmLQ9Jgh1cRGO02T92AzhLb7lkHu0F0h6oa8OYz9c9OpKvwK2rzqLs8xjhTMAt2dWYfIF0qQ5uKJof3A72gsnNI0(bOCwVqDKD3Uix4NvwHMtXC6YwZf(rV73PFuBbp3XBBi1Cks7hGYz9c1r2DtGwRPe)OEBdPMtrA)auoRxOoYU79aKXJJmxXcz7MaIkuRGOuHMlK55NnbvM3doeY2HEFBdPMtrA)auoRxOoYU79aKXJJmxXczdrqXB4QqZvwSimp)SjOY8EWHq2aOcDhalS9cos(tpciIheOYILqoaSpaQq3bWcBe7bWlgxruvAp5HMtDBdPMtrA)auoRxOoYUBicksfxmxXcztSh(Hj0lgWtmUcDalS0BBi1Cks7hGYz9c1r2DdrqrQ4I5kwiBDwOyCfRPikyGic5uefaj1CkYTnKAofP9dq5SEH6i7UHiOivCXCflKnz4yyNiiOeGQqrP9kzqGWBBi1Cks7hGYz9c1r2D7YrIDjiC1BBi1Cks7hGYz9c1r2D)pmHabj)TpfZPl7hKRBJPK7f56N0iAiz8dh6)GCDBECnvkfYbGnIgsg)KDx32qQ5uK2paLZ6fQJS72JRPEdxzoDzBZBieNCkKAovZJRPEdxBYGOS7TT9jdexqShap5tg42gsnNI0(bOCwVqDKD3e7HFys8gUYC6YUt28gcXjNcPMt184AQ3W1Mmik7EBRtorgiUGypaEYhB(2EBTSJYG9fLqk6pkUJaRhvZfEu1oE0qQd4Oj5OXEK84XX2TnKAofHn5h5CbFKmEBdPMtrCKD3YGZfUi3ouPi42gsnNI4i7UJVOqhc52gsnNI4i7U94(abeRGvkVTHuZPiS3dqgpoYCflKDHFvHAfeLkKEMNF2euzEp4qiB5mC)Wu1iqR1ucpUMkLc1kikTbWvKfrGF)rPIEMtx2DImq8xw(MBICVyCfp(qiZI4KtYz4(HPQrGwRPeECnvkfQvquAdGRilIa)(Jsf9FiNH7hMQgzG4cWOnaUISic87pkv0FBdPMtrCKD37biJhhzUIfYUWVQqTcIsfspZZpBcQmVhCiKTCgUFyQAKbIlaJ2a4kYIiWV)OurpZPlBYaXFz5BUjY9IXv84dHmlsF5mC)Wu1iqR1ucpUMkLc1kikTbWvKfrGF)rPI(pLZW9dtvJmqCby0gaxrweb(9hLk6VTHuZPioYU79aKXJJmxXczx4xvOwbrPcPN55NnbvM3doeYEpaz84yZnbevOwbrPcnx4M0CHmNUS1CHFUhGmECS5MaIkuRGOuHMl82gsnNI4i7U3dqgpoYCflK9dY1vqSwsH0Z88ZMGkZ7bhczVhGmECSv4xvOwbrPcPN50LDN2dqgpo2GiO4nCvO5klwKBBi1CkIJS7Epaz84iZvSq2pixxbXAjfspZZpBcQmVhCiKTCgUFyQAEuMRqZIL4nCTbWvKfrGF)rPIEMtx27biJhhBqeu8gUk0CLflYTnKAofXr2DldoxesnNsWtIYCflKTcYIruj32qQ5uehz3Tm4Cri1CkbpjkZvSq2dlPN50LTnDApaz84ydIGI3WvHMRSyr6)JAZJRPsPqTcIsBHuZD0wNCYM9aKXJJnickEdxfAUYIfP)dY1TrShaVyCfrvP9KhAovd6VVnDsdowA7Fycbcs(BFQgwXJJENC6b562(hMqGGK)2NQb9BRT32qQ5uehz3Tm4Cri1CkbpjkZvSq2ZpwiGzIcsPY2bMtx26WIfhBYz4(HPI0xZf(5EaY4XXMBciQqTcIsfAUWBBi1CkIJS72pZI50LnaDbiXE844TnKAofXr2DldoxesnNsWtIYCflKTC2XkkveVKNQvMjkiLkBhyoDztgi(llFJfy2rrw7jRbeAoLtorgi(llFZnrUxmUIhFiKzrCYjYaXFz5BYz9cvSqFQHMt5KtYzhRO0wHsWWhG)2gsnNI4i7U)hMqGGK)2NI50L9EaY4XXgebfVHRcnxzXI0)b562i2dGxmUIOQ0EYdnNQb9FBdPMtrCKD3)JMtXC6Y2MoThGmECSbrqXB4QqZvwSi93dqgpo2k8RkuRGOuH0ZU391CHFShGmECS5MaIkuRGOuHMl0jNide)LLVbq3SqV4p4HI93dqgpo2k8RkuRGOuH0)5Mzi26Kt2ShGmECSbrqXB4QqZvwSi9FqUUnI9a4fJRiQkTN8qZPAq)2EBdPMtrCKD3YGZfHuZPe8KOmxXczRwbrPccQq)32qQ5uehz3ThxtLsbrbyXsTZC6Y2MobGk0DaSWgtj3fGEIGKSsUyCfeOFeKdqqGwRPYIv)9aKXJJTc)Qc1kikvi9F05T1jNS5h1MhxtLsHAfeL2cPM7y)FuBECnvkfQvquAdGRilYNDgdLL03wXxBVTHuZPioYUBzW5cpadprdoJiGWC6YEpaz84ydIGI3WvHMRSyr6lNH7hMQgbATMs4X1uPuOwbrPnaUISic87pkv0)rxDDBdPMtrCKD3YGZfEagEIgCgraH50LDN2dqgpo2GiO4nCvO5klwK(2ShGmECSv4xvOwbrPcP)JU69M6fdTtaOcDhalSXuYDbONiijRKlgxbb6hb5aeeO1AQSyz7TnKAofXr2D)pmHabj)TpfZPl7oThGmECSbrqXB4QqZvwSi9FqUUnMsUxKRFsJOHKXpCO)dY1T5X1uPuiha2iAiz8ZnFBdPMtrCKD3VKJe5abyHI3SEiGWC6Y(b562uRGO0MFyQ6VhGmECSv4xvOwbrPcP)JEDBdPMtrCKD356NpKCkMtx2HuZDuGfUsK8HdoAJdmun4yPnsibPBkrVGmqCsdR4XrVT9FqUUnMsUxKRFsJOHKXpy3z9FqUUn1kikT5hMQ(7biJhhBf(vfQvquQq6)Ox32qQ5uehz3DU(5djNI50LDi1ChfyHRejF0v)hKRBJPK7f56N0iAiz8d2Dw)hKRBtTcIsB(HPQ)EaY4XXwHFvHAfeLkK(p6v)obGk0DaSWwU(5dj3rX)OyPzW7BtN0GJL2CbZsO2rbXE4hMinSIhh9o5KhFqUUnxWSeQDuqSh(Hjsd632BBi1CkIJS7ox)8HKtXC6YoKAUJcSWvIKp6Q)dY1TXuY9IC9tAenKm(b7oR)dY1TLRF(qYDu8pkwAg8gaxrwKp7QpaQq3bWcB56NpKChf)JILMb)2gsnNI4i7UZ1pFi5umNUSFqUUnMsUxKRFsJOHKXpy7qx91GJL2idexiNYdLAdR4XrFFn4yPnxWSeQDuqSh(HjsdR4XrFFauHUdGf2Y1pFi5ok(hflndE)hKRBtTcIsB(HPQ)EaY4XXwHFvHAfeLkK(p61TnKAofXr2DZcKRjbOWf5SGcGN50L9BiK(AUqHocFIFU5EFBdPMtrCKD3eO1AkXEYr3elpZPl73qi91CHcDe(e)SlgYTnKAofXr2DtGwRPeECnvkfQvqukZPl73qi91CHcDe(e)0HEDBdPMtrCKD32JYlgxbliUpkMtx2KbIli2dGNDVUTHuZPioYUBI9WpmjEdxzoDztgiUGypa(p7vFauHUdGf2Ebhj)PhbeXdcuzXsiha2)b562Ebhj)PhbeXdcuzXsiha2a4kYI8zVUTw2r34UhDJay4jAWzebKJga8ObhGH36rdPM7iZhTMJwi6pQohLe74rj2dGNCBdPMtrCKD32JYlgxbliUpkMtx2KbIli2dG)d2BUVn)O28am8en4mIGwi1ChDYPFuBECnvkfQvquAlKAUJ2EBdPMtrCKD32JYlgxbliUpkMtx2KbIli2dG)d2o0)b562kuTJaX)a0G3G(7lNH7hMQMm4CHhGHNObNreqAaCfzr(OlgklPVTIV32qQ5uehz3T9O8IXvWcI7JI50LnzG4cI9a4)GTd93dqgpo2k8RkuRGOuH0)jlPVTIV91CHFShGmECS5MaIkuRGOuHMlCtSK(2k(EBdPMtrCKD3YGZfHuZPe8KOmxXczlNDSIsfXl5PALzIcsPY2bMtx2Dso7yfL22XsTBfCBTSJYGNQ9bspkCibPBkr)rHhioH5Jcpq8JcRGKr8Oj5OefmfleCu1EuhDJW1uVHRmFuYC0upQ9GC04O2tw2rWr)b5as16TnKAofXr2DtgiUGOGKrK50LDN0GJL2iHeKUPe9cYaXjnSIhh93wl7OW)y5p6gHRPs5rz4bGKJ6oGJcpq8JcBpaEYrHkn5h1cRGO0JkNH7hMQJMKJk5dbpQohfGH36TnKAofXr2D7X1uVHRmNUSFqUUnpUMkLc5aWgadP2NmqCbXEa8FYa93dqgpo2k8RkuRGOuH0)rx9(2AzhDJGazX6OwyfeLEucQq)mFuYpw(JUr4AQuEugEai5OUd4OWde)OW2dGNCBdPMtrCKD3ECn1B4kZPl7hKRBZJRPsPqoaSbWqQ9jdexqSha)Nmq)9aKXJJTc)Qc1kikvi9F6qx32qQ5uehz3Thxt9gUYC6Y(b56284AQukKdaBamKAFYaXfe7bW)jd03MhKRBZJRPsPqoaSr0qY4hD5KtAWXsBKqcs3uIEbzG4KgwXJJEBVTHuZPioYUBpUM6nCL50LnbvXBkistte0fdr01VSpzG4cI9a4)Kb6BJnD2MidexqShaVTm0qQ5unI9WpmjEdxB4xucPOqZf(XpQnpadprdoJiObWvKfztHuZPA2JYlgxbliUpQg(fLqkk0CHBkKAovZJRPEdxB4xucPOqZfAB)hKRBZJRPsPqoaSr0qY4hSD42gsnNI4i7U94AQ3WvMtx2pix3MhxtLsHCaydGHu7tgiUGypa(pzG(HuZDuGfUsK8Hd32qQ5uehz3nzG4cIcsgXBBi1CkIJS7wgCUiKAoLGNeL5kwiB5SJvuQiEjpvR3wl7OBC3JADGoQmQJYc1J(cjJhvNJ2RJcpq8JcBpaEYrFO7aWJUram8en4mIaYrLZW9dt1rtYrby4TY8rtTdYrhgdRhvNJs(XYFu1oUoAnmDBdPMtrCKD32JYlgxbliUpkMtx2KbIli2dG)d2BU)EaY4XXwHFvHAfeLkK(p6Qx9TrdowAZJRPsPqgCEwSAyfpo6DYj5mC)Wu1KbNl8am8en4mIasdGRilYh2ytV2ezG4cI9a4TLHgsnNQrSh(HjXB4Ad)IsiffAUqBDmKAovZEuEX4kybX9r1WVOesrHMl02BBi1CkIJS72pZIzPvjhfAayHkHTdmNUSbOlaj2Jhh7R5c)ypaz84yZnbevOwbrPcnx4T1YoQLIe8OBeUM6nC9OP7rToqDaWJYAYI1r15O8HGhDJW1uP8Om8aWJs0qYiH5JI7yD009OP2H)OmfefpACuYaXpkXEa8TBBi1CkIJS72JRPEdxzoDz)GCDBECnvkfYbGnagsT)dY1T5X1uPuiha2a4kYI8PdoYs6BR4ld9b56284AQukKdaBenKmEBdPMtrCKD3e7HFys8gUEBVToE0qQ5uKgHpmjuqwmIkHnebfPIlMRyHSjdeNJQMflba6zLzPvjhfAayHkHTdmNUS3dqgpo2EqUUcI1skK(p1aWc1MpjAus0sHETjB6IHYs6BR4ldDpaz84ydIGI3WvHMRSyrS9264rdPMtrAe(WKqbzXiQehz3nebfPIlMRyHSjq1JpJxeluTBLOmNUS3dqgpo2EqUUcI1skK(p1aWc1MpjAus0sHE5OnDXq3dqgpo2GiO4nCvO5klweBVToE0qQ5uKgHpmjuqwmIkXr2DdrqrQ4I5kwiBC9BfGbxmaFfLezoDzVhGmECS9GCDfeRLui9FAJgawO28jrJsIwk0lBD0HUC0MUyO7biJhhBqeu8gUk0CLflIT32BBi1Cksto7yfLkIxYt1kBYaXfGrzoDztgi(llFJfy2rrw7jRbeAovFB2dqgpo2k8RkuRGOuH0)zx92jN2dqgpo2k8RkuRGOuH0)XM7TT32qQ5uKMC2XkkveVKNQvhz3nzG4cWOmNUSjde)LLV5Mi3lgxXJpeYSi9)rT5X1uPuOwbrPTqQ5oEBdPMtrAYzhROur8sEQwDKD3KbIlaJYC6YMmq8xw(gtj3lSdvQqdPMss)o9JAZJRPsPqTcIsBHuZDS)EaY4XXwHFvHAfeLkK(pCGHCBdPMtrAYzhROur8sEQwDKD3EuMRqZIL4nCLzPvjhfAayHkHTdmNUS70EaY4XXgebfVHRcnxzXI03gYaXFz5BCm8INvb(nw)C0jNide)LLVXiUNfrmJLkKNflB7BZpQnpUMkLc1kikTfsn3X(KbIli2dG)ZUCYPo9JAZJRPsPqTcIsBHuZDS)EaY4XXwHFvHAfeLkK(pyGEB7TnKAofPjNDSIsfXl5PA1r2D7rzUcnlwI3WvMLwLCuObGfQe2oWC6YUt7biJhhBqeu8gUk0CLflsFBide)LLV5oaw4Bafka4ocsK4Kt2qgi(llFBF4HMCuqg(owA)orgi(llFJrCplIyglviplw2AB)o9JAZJRPsPqTcIsBHuZD82gsnNI0KZowrPI4L8uT6i7U9OmxHMflXB4kZsRsok0aWcvcBhyoDzVhGmECSbrqXB4QqZvwSi9TPtAWXsB)dtiqqYF7t5KtYz4(HPQ9pmHabj)TpvdGRilYNHuZPAEuMRqZIL4nCTHFrjKIcnxOT97KCgUFyQAeO1AkHhxtLsHAfeL2G(7BZpQnpUMkLc1kikTbWvKf5tgItojNH7hMQgbATMs4X1uPuOwbrPnaUISic87pkv0)5M7TT32qQ5uKMC2XkkveVKNQvhz3Tlhj2LGWvzoDztgi(llFBF4HMCuqg(owA)hKRBBF4HMCuqg(owAZpmvmNLIaa0Vksx2pix32(Wdn5OGm8DS0g0)TnKAofPjNDSIsfXl5PA1r2DtKdeilwcnv7iZPlBYaXFz5BYz9cvSqFQHMt1)h1MhxtLsHAfeL2cPM74TnKAofPjNDSIsfXl5PA1r2DtKdeilwcnv7iZPl7orgi(llFtoRxOIf6tn0CQBBi1Cksto7yfLkIxYt1QJS7ox)y5ZILqgAquW8BhzoDz)JAZJRPsPqTcIsBHuZDSpzG4cI9a4z37B7TnKAofPz)xOGSyKWgIGIuXfZvSq2KSCH4cw8WNHoaIaxpoUUTHuZPin7)cfKfJehz3nebfPIlMRyHSjz5cXfb5pbrPebUECCDBVTHuZPiTHL0Z(Haccymlw32qQ5uK2Ws6DKD3p(mEHleW6TnKAofPnSKEhz3TBcWhFg)TnKAofPnSKEhz3nebfPIlYT92gsnNI0MFSqaBYaXfGrzoDztgi(llFJfy2rrw7jRbeAo1TnKAofPn)yHahz3DHQDei(hGg8BBi1CksB(XcboYUBwGCnjafUiNfua832qQ5uK28JfcCKD3eO1AkXEYr3el)TnKAofPn)yHahz3nXE4hMeVHRmNUSjdexqSha)N9QVCgUFyQAYGZfEagEIgCgraPb9FBdPMtrAZpwiWr2DtSh(HjXB4kZPl79aKXJJnickEdxfAUYIfPpzG4cI9a4)Sx9FqUUTxWrYF6rar8GavwSeYbGnIgsg)KbUTHuZPiT5hle4i7ULbNl8am8en4mIaYT92gsnNI0(HaOWhRGfkuqwmsydrqrQ4I5kwiBpadVBcqXosii)2gsnNI0(HaOWhRGfkuqwmsCKD3qeuKkUyUIfYgGKPIsfaKGG9jb32qQ5uK2peaf(yfSqHcYIrIJS7gIGIuXfZvSq2bqApvuQerwSWckvRc5aWBBi1Cks7hcGcFScwOqbzXiXr2DdrqrQ4I5kwiB5qwPuWIh(m0bqeaKmvOd42gsnNI0(HaOWhRGfkuqwmsCKD3qeuKkUyUIfY2dWW7MauSJecYVTHuZPiTFiak8XkyHcfKfJehz3nebfPIlMRyHSjdexKSQurWTnKAofP9dbqHpwbluOGSyK4i7UHiOivCXCflKnlU1F7IXveesUsEO5umNUSdPM7OalCLiHTd32qQ5uK2peaf(yfSqHcYIrIJS7gIGIuXfZvSq2(aW4AMs4rjJIFifGejws82gsnNI0(HaOWhRGfkuqwmsCKD3qeuKkUyUIfYgFtrgiUypj4TnKAofP9dbqHpwbluOGSyK4i7UHiOivCXCflKnujThzHEblE4ZqharqShsg5i52EBdPMtrAkilgrLWgIGIuXfZvSq2e7HFyc9Ib8eJRqhWclL50L9EaY4XX2dY1vqSwsH0)zxDDBdPMtrAkilgrL4i7ULbNlcPMtj4jrzUIfY2(VqbzXiH50LTgCS0MhxtLsHCkc06xZPAyfpo67VhGmECSv4xvOwbrPcP)ZU69T1YokdMRlkvYrv7HEufe7i)Oe(We36r15OAayH6rbidcucWJgEFQ5ubN5JsW)aekEu7r55zX62gsnNI0uqwmIkXr2DldoxesnNsWtIYCflKnHpmjuqwmIk52gsnNI0uqwmIkXr2DdrqrQ4I5kwi7zhbU8HPSyjIkxHqgSqMtx220P9aKXJJnickEdxfAUYIfP)pQnpUMkLc1kikTfsn3rBDYjB2dqgpo2GiO4nCvO5klwK(pix3gXEa8IXvevL2tEO5unOFBVTHuZPinfKfJOsCKD3qeuKkUyMWhLTcYIruDG50LTcYIruBo0Shebebfpix3(2ytN2dqgpo2GiO4nCvO5klwK()O284AQukuRGO0wi1ChT1jNSzpaz84ydIGI3WvHMRSyr6)GCDBe7bWlgxruvAp5HMt1G(T12BBi1CkstbzXiQehz3nebfPIlMj8rzRGSye1UyoDzRGSye1wxn7brarqXdY1TVn20P9aKXJJnickEdxfAUYIfP)pQnpUMkLc1kikTfsn3rBDYjB2dqgpo2GiO4nCvO5klwK(pix3gXEa8IXvevL2tEO5unOFBT92gsnNI0uqwmIkXr2DldoxesnNsWtIYCflK9peaf(yfSqHcYIrcZPlBnx4h7biJhhBUjGOc1kikvO5c7VhGmECS9GCDfeRLui9F0vVVT32qQ5uKMAfeLkiOc9ZUq1oce)dqdoZPl79aKXJJTc)Qc1kikvi9F6qVUTHuZPin1kikvqqf63r2DZcKRjbOWf5SGcGN50L9EaY4XXwHFvHAfeLkK(pDWsVjBcPMt1iqR1ucpUMkLc1kikTHFrjKIcnxOJHuZPAe7HFys8gU2WVOesrHMl02(2iNH7hMQMm4CHhGHNObNreqAaCfzr(0bl9MSjKAovJaTwtj84AQukuRGO0g(fLqkk0CHogsnNQrGwRPe7jhDtS8n8lkHuuO5cDmKAovJyp8dtI3W1g(fLqkk0CH26Kt)O28am8en4mIGgaxrwKp2dqgpo2k8RkuRGOuH07yi1CQgbATMs4X1uPuOwbrPn8lkHuuO5cT92gsnNI0uRGOubbvOFhz3nbATMsSNC0nXYZC6Y2M9aKXJJTc)Qc1kikvi9F6qV2KnHuZPAeO1AkHhxtLsHAfeL2WVOesrHMl02(2iNH7hMQMm4CHhGHNObNreqAaCfzr(0HETjBcPMt1iqR1ucpUMkLc1kikTHFrjKIcnxOJHuZPAeO1AkXEYr3elFd)IsiffAUqBDYPFuBEagEIgCgrqdGRilYh7biJhhBf(vfQvquQq6DmKAovJaTwtj84AQukuRGO0g(fLqkk0CH2ARtoztNaqf6oawyJPK7cqprqswjxmUcc0pcYbiiqR1uzXQ)EaY4XXwHFvHAfeLkK(pyGEB7TnKAofPPwbrPccQq)oYUBzW5cpadprdoJiGWC6YEpaz84yRWVQqTcIsfs)No01MSjKAovJaTwtj84AQukuRGO0g(fLqkk0CHogsnNQrSh(HjXB4Ad)IsiffAUqBVTHuZPin1kikvqqf63r2DtGwRPeECnvkfQvqukZPlBnx4h7biJhhBUjGOc1kikvO5c7BZpQnpadprdoJiOfsn3X()O28am8en4mIGgaxrwKpcPMt1iqR1ucpUMkLc1kikTHFrjKIcnxOT9TPtAWXsBeO1AkXEYr3elFdR4XrVto9JABp5OBILVfsn3rB7BdzG4cI9a4z3BNCYMFuBEagEIgCgrqlKAUJ9)rT5by4jAWzebnaUISiFgsnNQrGwRPeECnvkfQvquAd)IsiffAUqhdPMt1i2d)WK4nCTHFrjKIcnxOTo5Kn)O22to6My5BHuZDS)pQT9KJUjw(gaxrwKpdPMt1iqR1ucpUMkLc1kikTHFrjKIcnxOJHuZPAe7HFys8gU2WVOesrHMl0wNCYMhKRBJfixtcqHlYzbfaFd6V)dY1TXcKRjbOWf5SGcGVbWvKf5ZqQ5unc0AnLWJRPsPqTcIsB4xucPOqZf6yi1CQgXE4hMeVHRn8lkHuuO5cT1wJAuJb]] )


end
