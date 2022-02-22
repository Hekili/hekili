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


    spec:RegisterPack( "Demonology", 20220221, [[d0KYUbqisiEesrUKQOOnPk8jLOgfvKtrfAvkPIEfjYSirDlLi2LK(LeQHPePJHuAzur9mLu10iHQRjHyBQIW3KqIXrcfNtvuyDif18qkCpQK9PKYbvfrwOsspuvunrjK6IkPsTrsOu(OQOuJuvuIoPsQWkvkntsiTtQGFscLmujKKLkHK6PizQKGRscLQTQkkHVQkIASQI0EP4VuAWahwXIjPhJYKr1LH2Se9zLWOLGtl1RvLA2K62u1Uf(TOHRuDCLujlh0ZrmDIRRQ2ovQVRumEvjNhPA9QIsA(kj2VkBO1OGHIpcACW5L6SZl1zNPT6mTfzPl1zdLqFhnu7d79SanuX4rdvrJ(msDUGUHAFORZHBuWqrYpKHgkQ2)CdL6V1Y6imQgk(iOXbNxQZoVuNDM2QZ0Q4pJIOymuKDKzCW5N4jmufAohdJQHIJeMHQOrFgPoxq)ap5bQt27BBbr2j0CXfVOLcF1kl9ftA)xpsNbdoLsXK2Zk(2QydvH)bs)aotRYhW5L6SZ32B7ZlmXcKqZ32LCaQDuRpGIMS31B7soGIvOPFaiYsVhd(bkA0NHAQLdSdXLWsV6ihOlpqlhOjhOdImHCaNs4bkmqoBiYbkt4butcbjowVTl5afv5geEaQEVqghy06CdYpWoexcl9QJCajpWomzhOdImHCGIg9zOMAPEBxYbkQCxuDaz0yihOdbHW)UuVTl5apj3zZpa1QlzTNL5Z(aK9XFGnfW4a0Z)Yq8arkhyuZVCajpa579zCG5akqhoHuVTl5ak20iPadoLsXpls9iTgpavQDJHCa2emuB7YdWkmXcKFajpqhccH)DX2L1B7soGcq6hqYdmUZMFGndr6yXbkA0NrZoWZtiEaImS3K6TDjhqbi9di5b8ZB8a5ogi8a7WoHTq)azOPFGnj89b6YdSbpaBIdmm5pAn9dK7yCGnTu4aZbuGoCcPAO0nrigfmueDUXkWoEJcXOGXbAnkyOWyu1i3SQHAysNHHIKFTgfPJfw4xLUHIbBbH9yOyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dqJdidCbkvEtKjy4bk(af5apoG0E8aRDa3dShvnwlBirScD4eIvApEGLCaNoGmWfOu5nrMGHhO4duKd4OHkgpAOi5xRrr6yHf(vPBeJdoBuWqHXOQrUzvd1WKoddf5hQ6m52XJsb6eXqXGTGWEmuSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(bOXbKbUaLkVjYem8afFGICGhhqApEG1oG7b2JQgRLnKiwHoCcXkThpWsoGthqg4cuQ8MitWWdu8bkYbC0qfJhnuKFOQZKBhpkfOteJyCy9gfmuymQAKBw1qXrcd27sNHHsXcYJjy4bkmKdmhGwNpabzzWpah1d9dmb)an5asbeILjepa5DVVJ8duMWdu2qICafOdNqoGKhq3bEG)(b20sHdifWdarIyOIXJgk0VthIJ2MqEmbdnumyliShdfltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKFaACaNoGmWfOu5nrMGHhO4duKd44bu6a068bECawMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKji)aRDaNoGthWPdidCbkvEtKjy4bk(af5aoEaLoaToFahpWsoaTf5aoEGhhqApEG1oG7b2JQgRLnKiwHoCcXkThpWsoGthWPdidCbkvEtKjy4bk(af5aoEaLoaToFahnudt6mmuOFNoehTnH8ycgAeJyOkSBfyhVjgfmoqRrbdfgJQg5MvnuX4rdfPJYV2Uqp8EKesSOxvJEd1WKoddfPJYV2Uqp8EKesSOxvJEJyCWzJcgkmgvnYnRAOIXJgkshLFTDi7nCcHyrVQg9gQHjDggkshLFTDi7nCcHyrVQg9gXigkw6gJje7O26wOBuW4aTgfmuymQAKBw1qXGTGWEmuK8Rv7Gxxat3OTd39IeosNrfJrvJ8d84aoDawMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKji)a04aoV0dSYkhGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpWAhy9l9aoAOgM0zyOi5xBHPyeJdoBuWqHXOQrUzvdfd2cc7XqrYVwTdETSrn3MLwvDsiPNuXyu1i)apoWokvo6ZOzwHoCcPomPDJgQHjDggks(1wykgX4W6nkyOWyu1i3SQHIbBbH9yOi5xR2bVUP1CBHFiwzysZivmgvnYpWJdOihyhLkh9z0mRqhoHuhM0UXd84aSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(bw7a0Qymudt6mmuK8RTWumIXbf3OGHcJrvJCZQgkgSfe2JHYPdqYVwTdEvJd3Qs3IVg)UgRymQAKFGvw5aK8Rv7GxFJU7GyZ8zf1DSOIXOQr(bC8apoGthyhLkh9z0mRqhoHuhM0UXd84aK8RTKcdKFaACaNpWkRCaf5a7Ou5OpJMzf6WjK6WK2nEGhhGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpWAhqXx6bC0qnmPZWqXrw7hPJfw1ulgX4qrmkyOWyu1i3SQHIbBbH9yOC6aK8Rv7Gxlt4cunHbAHOBe2iPIXOQr(bwzLd40bi5xR2bV6o1J0A0ssTBmKkgJQg5h4XbuKdqYVwTdE9n6UdInZNvu3XIkgJQg5hWXd44bECaf5a7Ou5OpJMzf6WjK6WK2nAOgM0zyO4iR9J0XcRAQfJyC4jmkyOWyu1i3SQHAysNHHQuJKcm4ukgkgSfe2JHIKFTAh8Q7upsRrlj1UXqQymQAKFGhhq9xwwDN6rAnAjP2ngsLNBcdvhccH)DX2Lgk1Fzz1DQhP1OLKA3yi1)UrmouumkyOWyu1i3SQHIbBbH9yOi5xR2bVYsV6iwpYBzKoJkgJQg5h4Xb2rPYrFgnZk0Hti1HjTB0qnmPZWqry5h2XcR0sb0ighumgfmuymQAKBw1qXGTGWEmukYbi5xR2bVYsV6iwpYBzKoJkgJQg5gQHjDggkcl)WowyLwkGgX4WZWOGHcJrvJCZQgkgSfe2JHAhLkh9z0mRqhoHuhM0UXd84aK8RTKcdKFaxhyPgQHjDggQ2VJbVJfw2idrG5Eb0igXqj0Htiwck)DJcghO1OGHcJrvJCZQgkgSfe2JHILPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpanoaTfXqnmPZWqfOuaH29ekJ2ighC2OGHcJrvJCZQgkgSfe2JHILPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpanoaTfLdSKd40bgM0zujFVpdlh9z0mRqhoHuXxi7lOvApEaLoWWKoJkPWWZnw1ulv8fY(cAL2JhWXd84aoDawMAEUjQSrRTCioCIm63iKuHOF6GCaACaAlkhyjhWPdmmPZOs(EFgwo6ZOzwHoCcPIVq2xqR0E8akDGHjDgvY37ZW6U1yzJbVIVq2xqR0E8akDGHjDgvsHHNBSQPwQ4lK9f0kThpGJhyLvoWokvoehorg9BewHOF6GCG1oaltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKFaLoWWKoJk579zy5OpJMzf6WjKk(czFbTs7Xd4OHAysNHHAbS9zdrBjQx8hi3ighwVrbdfgJQg5MvnumyliShdLthGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpanoaTf5al5aoDGHjDgvY37ZWYrFgnZk0Htiv8fY(cAL2JhWXd84aoDawMAEUjQSrRTCioCIm63iKuHOF6GCaACaAlYbwYbC6adt6mQKV3NHLJ(mAMvOdNqQ4lK9f0kThpGshyysNrL89(mSUBnw2yWR4lK9f0kThpGJhyLvoWokvoehorg9BewHOF6GCG1oaltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKFaLoWWKoJk579zy5OpJMzf6WjKk(czFbTs7Xd44bC8aRSYbC6akYbG)alt4cSUP1LqKtSKErRTzPL83ryNql579z0XIkgJQg5h4XbyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dS2bu8LEahnudt6mmuKV3NH1DRXYgdUrmoO4gfmuymQAKBw1qXGTGWEmuSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(bOXbO15dSKd40bgM0zujFVpdlh9z0mRqhoHuXxi7lOvApEaLoWWKoJkPWWZnw1ulv8fY(cAL2JhWrd1WKoddfB0AlhIdNiJ(ncjgX4qrmkyOWyu1i3SQHIbBbH9yOK2JhyTd4EG9OQXAzdjIvOdNqSs7Xd84aoDGDuQCioCIm63iSomPDJh4Xb2rPYH4WjYOFJWke9thKdS2bgM0zujFVpdlh9z0mRqhoHuXxi7lOvApEahpWJd40buKdiJgdPs(EFgw3TglBm4vmgvnYpWkRCGDuQUBnw2yWRdtA34bC8apoGthGKFTLuyG8d46al9aRSYbC6a7Ou5qC4ez0VryDys7gpWJdSJsLdXHtKr)gHvi6NoihGghyysNrL89(mSC0NrZScD4esfFHSVGwP94bu6adt6mQKcdp3yvtTuXxi7lOvApEahpWkRCaNoWokv3TglBm41HjTB8apoWokv3TglBm4vi6NoihGghyysNrL89(mSC0NrZScD4esfFHSVGwP94bu6adt6mQKcdp3yvtTuXxi7lOvApEahpWkRCaNoG6VSSUa2(SHOTe1l(dKx)7h4Xbu)LL1fW2NneTLOEXFG8ke9thKdqJdmmPZOs(EFgwo6ZOzwHoCcPIVq2xqR0E8akDGHjDgvsHHNBSQPwQ4lK9f0kThpGJhWrd1WKoddf579zy5OpJMzf6WjeJyedfhlNVwmkyCGwJcgkmgvnYnRAO4iHb7DPZWqTUFHSVG8dGUri9diThpGuapWWKeEGMCGX906rvJvd1WKoddfzh1ARozVnIXbNnkyOgM0zyOyJwBlrDHFii0qHXOQrUzvJyCy9gfmudt6mmuZl0kjHyOWyu1i3SQrmoO4gfmudt6mmuC0D(Hw)SOzgkmgvnYnRAeJdfXOGHcJrvJCZQgQHjDggk2O12HjDgwDtedLUjIngpAOeyhVrHyeJdpHrbdfgJQg5MvnumyliShdLKlwOXkltnp3eKd84as7XdqJd4EG9OQXAzdjIvOdNqSs7Xd84aSm18CtujFVpdlh9z0mRqhoHuHOF6GCaACa3dShvnwlBirScD4eIvApEGLCaP9OHIiWMjghO1qnmPZWqXgT2omPZWQBIyO0nrSX4rdvUJbcnIXHIIrbdfgJQg5MvnumyliShdfelHiPWOQrd1WKoddfptVrmoOymkyOWyu1i3SQHIbBbH9yOi5xR2bVUaMUrBhU7fjCKoJkgJQg5hyLvoaj)A1o41Yg1CBwAv1jHKEsfJrvJ8dSYkhGKFTAh8kl9QJy9iVLr6mQymQAKFGvw5aS0ngti1azWuNqUHIiWMjghO1qnmPZWqXgT2omPZWQBIyO0nrSX4rdflDJXeIDuBDl0nIXHNHrbdfgJQg5MvnumyliShdLthGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpGRdS0d84as7XdS2bCpWEu1yTSHeXk0HtiwP94bwzLdqYVwTdEfILDGC7(OhbRymQAKFGhhGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpanoW6vmhWrd1WKodd1EkDggX4aTl1OGHcJrvJCZQgQHjDggk2O12HjDgwDtedLUjIngpAOe6WjelbL)UrmoqlTgfmuymQAKBw1qXGTGWEmu7Ou5OpJMzf6WjK6WK2nAOicSzIXbAnudt6mmuSrRTdt6mS6MigkDteBmE0qLlyCJyCGwNnkyOWyu1i3SQHIbBbH9yOC6akYbG)alt4cSUP1LqKtSKErRTzPL83ryNql579z0XIkgJQg5h4XbyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dS2bEghWXdSYkhWPdSJsLJ(mAMvOdNqQdtA34bECGDuQC0NrZScD4esfI(PdYbOXbEIdSopWcgV6NxhWrd1WKoddfh9z0mlrGySqkyeJd0UEJcgkmgvnYnRAOyWwqypgkwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKji)aRDaNx6bwYbkYbwNhqroa8hyzcxG1nTUeICIL0lATnlTK)oc7eAjFVpJowuXyu1i3qnmPZWqXgT2YH4WjYOFJqIrmoqRIBuWqHXOQrUzvdfd2cc7XqP(llRBAn32(DsLid79bw7a0EGhhq9xww5OpJMzzjeRezyVpanoW6nudt6mmu75geAj9EHmmIXbAlIrbdfgJQg5MvnumyliShdL6VSSk0HtivEUjoWJdWYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5hyTdued1WKoddLARrcl)WfOvn9QiKyeJd0(egfmuymQAKBw1qXGTGWEmudtA3Ofd03i5aRDaApGshWPdq7bwNhqgngsLmmyx2mKBj5xtQymQAKFahpWJdO(llRBAn32(DsLid79bwZ1bEId84aQ)YYQqhoHu55M4apoaltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKFG1oqrmudt6mmuTFxNKodJyCG2IIrbdfgJQg5MvnumyliShd1WK2nAXa9nsoWAhW5d84aQ)YY6MwZTTFNujYWEFG1CDGN4apoG6VSSk0HtivEUjoWJdWYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5hyTduKd84akYbG)alt4cS2(DDsA3ODpfmKE0vmgvnYpWJd40buKdiJgdPwctVvkGwsHHNBivmgvnYpWkRCa1FzzTeMERuaTKcdp3qQ)9d4OHAysNHHQ976K0zyeJd0QymkyOWyu1i3SQHIbBbH9yOgM0UrlgOVrYbw7aoFGhhq9xww30AUT97Kkrg27dSMRd8eh4Xbu)LL12VRts7gT7PGH0JUcr)0b5a04aoFGhha(dSmHlWA731jPDJ29uWq6rxXyu1i3qnmPZWq1(DDs6mmIXbAFggfmuymQAKBw1qXGTGWEmuQ)YY6MwZTTFNujYWEFG1CDaAD(apoGmAmKkj)Alld(VLkgJQg5h4XbKrJHulHP3kfqlPWWZnKkgJQg5h4XbG)alt4cS2(DDsA3ODpfmKE0vmgvnYpWJdO(llRcD4esLNBId84aSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(bw7afXqnmPZWq1(DDs6mmIXbNxQrbdfgJQg5MvnumyliShdLAsih4XbK2JwjT8gpanoW6xQHAysNHHAbS9zdrBjQx8hi3ighCMwJcgkmgvnYnRAOyWwqypgk1KqoWJdiThTsA5nEaACaNvmgQHjDggkY37ZW6U1yzJb3ighC2zJcgkmgvnYnRAOyWwqypgk1KqoWJdiThTsA5nEaACaAlIHAysNHHI89(mSC0NrZScD4eIrmo486nkyOWyu1i3SQHIbBbH9yOi5xBjfgi)aUoqrmudt6mmufMGBZs7IVMpHrmo4SIBuWqHXOQrUzvd1WKoddvHj42S0U4R5tyO4iHb7DPZWqTokpqrdXHtKr)gHKdmq8aJgIdN(bgM0UrLpqKhiqKFajpazCJhGuyGCIHIbBbH9yOi5xBjfgi)aR56aR)apoGthyhLkhIdNiJ(ncRdtA34bwzLdSJsLJ(mAMvOdNqQdtA34bC0ighCUigfmuymQAKBw1qXGTGWEmuK8RTKcdKFG1CDaApWJdO(llRbkfqODpHYOR)9d84aSm18CtuzJwB5qC4ez0VriPcr)0b5aRDaNpW68aly8QFEzOgM0zyOkmb3ML2fFnFcJyCW5NWOGHcJrvJCZQgkgSfe2JHIKFTLuyG8dSMRdq7bECawMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKji)a04aly8QFEDGhhqApEG1oaToFGLCGfmE1pVoWJd40bu)LLvoehorg9BesQ)9d84aQ)YYkhIdNiJ(ncjvi6NoihyTdmmPZOwycUnlTl(A(ev8fY(cAL2JhqPdmmPZOs(EFgwo6ZOzwHoCcPIVq2xqR0E8aoEGhhWPdOihqgngsL89(mSUBnw2yWRymQAKFGvw5aQ)YYQ7wJLng86F)aoAOgM0zyOkmb3ML2fFnFcJyCW5IIrbdfgJQg5MvnumyliShdLICaw6gJjKQBmKc0HgkIaBMyCGwd1WKoddfB0A7WKodRUjIHs3eXgJhnuS0ngti2rT1Tq3ighCwXyuWqHXOQrUzvd1WKoddfj)AlrG9B0qXrcd27sNHH6j3sH8lhGAyWUSzi)au5xtu(au5xFakb2VXd0Kdqeyglq4bKctCGIg9zOMAr5dqYd0YbkmKdmhOqVOacpWoStyl0numyliShdLICaz0yivYWGDzZqULKFnPIXOQrUrmo48ZWOGHcJrvJCZQgQHjDggko6Zqn1IHIJegS3Loddf1og8du0OpJMDGNNqKCGYeEaQ8RpavHbYjh4hsRpGc0HtihGLPMNBId0KdW0jbpGKhaIdNUHIbBbH9yOu)LLvo6ZOzwwcXkehMCGhhGKFTLuyG8dqJdO4h4XbyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dS2bCEPgX4W6xQrbdfgJQg5Mvnudt6mmuC0NHAQfdfhjmyVlDggQI(d7yXbuGoCc5aeu(7kFaYog8du0OpJMDGNNqKCGYeEaQ8RpavHbYjgkgSfe2JHs9xww5OpJMzzjeRqCyYbECas(1wsHbYpanoGIFGhhGLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYpanoaToBeJdRNwJcgkmgvnYnRAOyWwqypgk1FzzLJ(mAMLLqScXHjh4Xbi5xBjfgi)a04ak(bECaNoG6VSSYrFgnZYsiwjYWEFG1oGZhyLvoGmAmKkzyWUSzi3sYVMuXyu1i)aoAOgM0zyO4Opd1ulgX4W6D2OGHcJrvJCZQgkgSfe2JHs9xww5OpJMzzjeRqCyYbECas(1wsHbYpanoGIFGhhyys7gTyG(gjhyTdqRHAysNHHIJ(mutTyeJdRF9gfmudt6mmuK8RTeb2VrdfgJQg5MvnIXH1R4gfmuymQAKBw1qnmPZWqXgT2omPZWQBIyO0nrSX4rdflDJXeIDuBDl0nIXH1xeJcgkmgvnYnRAOgM0zyOkmb3ML2fFnFcdfhjmyVlDggQ1r5bON)dWM4alq5aQd79bK8af5au5xFaQcdKtoGkwMq8afnehorg9Besoaltnp3ehOjhaIdNUYhOLLjhiFp0pGKhGSJb)asb0FGi3yOyWwqypgks(1wsHbYpWAUoW6pWJdWYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5hyTd4CroWJd40bKrJHu5OpJMzzJw3XIkgJQg5hyLvoaltnp3ev2O1woehorg9BesQq0pDqoWAhWPd40bkYbwYbi5xBjfgi)aoEG15bgM0zujfgEUXQMAPIVq2xqR0E8aoEaLoWWKoJAHj42S0U4R5tuXxi7lOvApEahnIXH1)egfmuymQAKBw1qnmPZWqXZ0BOyWwqypgkiwcrsHrvJh4XbK2JhyTd4EG9OQXAzdjIvOdNqSs7rdfJotJwzGlqHyCGwJyCy9ffJcgkmgvnYnRAOgM0zyO4Opd1ulgkosyWEx6mmuk2j4bkA0NHAQLd0LhGE(xgIhyr2XIdi5b0jbpqrJ(mA2bEEcXdqKH9MO8bq3yCGU8aTSm)aBgIGhyoaj)6dqkmqE1qXGTGWEmuQ)YYkh9z0mllHyfIdtoWJdO(llRC0NrZSSeIvi6NoihGghG2dO0bwW4v)86aRZdO(llRC0NrZSSeIvImS3gX4W6vmgfmudt6mmuKcdp3yvtTyOWyu1i3SQrmIHAhIS0RoIrbJd0AuWqHXOQrUzvdvUBOiOyOyWwqypgk1FzzvvNjx)js9VBO4iHb7DPZWqTUFHSVG8dOILjepal9QJCavCrhK6bEsmgUlKdezSKcd0x(1hyysNb5azOPxnuUhOngpAOkBirScD4eIvApAOgM0zyOCpWEu1OHY9O)Of1e0qrRZgk3J(JgkAxQrmo4SrbdfgJQg5MvnuX4rdfPWWZni3MqvBwALe6Xqmudt6mmuKcdp3GCBcvTzPvsOhdXighwVrbdfgJQg5MvnumyliShdL0E8aRDGLEGhhqroWok1r3Urd1WKoddvjQT803XiDggX4GIBuWqnmPZWqr(EFg2suV4pqUHcJrvJCZQgX4qrmkyOWyu1i3SQHkgpAOK0J2S06ZGiW8tSSmic8ZKodIHAysNHHsspAZsRpdIaZpXYYGiWpt6migX4WtyuWqHXOQrUzvdvmE0qrsnofiwcYGOyfKvi611hnudt6mmuKuJtbILGmikwbzfIED9rJyCOOyuWqnmPZWqvQrsbgCkfdfgJQg5MvnIXbfJrbdfgJQg5MvnumyliShdL6VSSUP1CB73jvImS3hyTdq7bECa1FzzLJ(mAMLLqSsKH9(a0W1bC2qnmPZWqTNBqOL07fYWighEggfmuymQAKBw1qXGTGWEmuoDa1KqoWkRCGHjDgvo6Zqn1sLne5aUoWspGJh4Xbi5xBjfgiNCaACaf3qnmPZWqXrFgQPwmIXbAxQrbdfgJQg5MvnumyliShdLICaNoGAsihyLvoWWKoJkh9zOMAPYgICaxhyPhWXdSYkhGKFTLuyGCYbw7aR3qnmPZWqrkm8CJvn1IrmIHk3XaHgfmoqRrbdfgJQg5MvnumyliShdfj)A1o41fW0nA7WDViHJ0zuXyu1i3qnmPZWqrYV2ctXighC2OGHAysNHHkqPacT7jugTHcJrvJCZQgX4W6nkyOgM0zyOwaBF2q0wI6f)bYnuymQAKBw1ighuCJcgQHjDggkY37ZW6U1yzJb3qHXOQrUzvJyCOigfmuymQAKBw1qXGTGWEmuQ)YYkh9z0mllHyfIdtoWJdqYV2skmq(bOXbu8d84aSm18CtuzJwB5qC4ez0VriP(3nudt6mmuC0NHAQfJyC4jmkyOWyu1i3SQHIbBbH9yOi5xBjfgi)a04af5apoaltnp3ev2O1woehorg9BesQ)Dd1WKoddfPWWZnw1ulgX4qrXOGHAysNHHInATLdXHtKr)gHedfgJQg5MvnIrmucSJ3OqmkyCGwJcgkmgvnYnRAOgM0zyOifgEUb52eQAZsRKqpgIHIbBbH9yOyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dqJd4SZgQy8OHIuy45gKBtOQnlTsc9yigX4GZgfmuymQAKBw1qXGTGWEmuYOXqQC0NrZSSmiF)U0zuXyu1i)apoaltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKFaACaNxQHAysNHHInATDysNHv3eXqPBIyJXJgQc7wb2XBIrmoSEJcgkmgvnYnRAO4iHb7DPZWqTUllrMqoGuyKdiWXnQparNB00pGKhqg4cuoaexx)gIhy48w6mgTYhGG7dCe8afMGR7yHHAysNHHInATDysNHv3eXqPBIyJXJgkIo3yfyhVrHyeJdkUrbdfgJQg5Mvnudt6mmuPBewQZnDSWor7hlBwGgkgSfe2JHAhLkh9z0mRqhoHuhM0UrdvmE0qLUryPo30Xc7eTFSSzbAeJdfXOGHcJrvJCZQgkgSfe2JHsGD8gLQqBTWqSFcAv)LLh4Xb2rPYrFgnZk0Hti1HjTB0qnmPZWqjWoEJcTgX4WtyuWqHXOQrUzvdfd2cc7XqjWoEJsvCUwyi2pbTQ)YYd84a7Ou5OpJMzf6WjK6WK2nAOgM0zyOeyhVrXzJyCOOyuWqHXOQrUzvdfd2cc7XqjThpWAhW9a7rvJ1YgseRqhoHyL2Jh4XbyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG8dS2bCEPgQHjDggk2O12HjDgwDtedLUjIngpAO2)q0Yh)SaTcSJ3eJyed1(hIw(4NfOvGD8MyuW4aTgfmuymQAKBw1qfJhnuCio8YgIw3iHGAd1WKoddfhIdVSHO1nsiO2ighC2OGHcJrvJCZQgQy8OHIKFTTxeTGqd1WKoddfj)ABViAbHgX4W6nkyOWyu1i3SQHAysNHHAHM(EbBwAhcP9TEKoddfd2cc7XqnmPDJwmqFJKd46a0AOIXJgQfA67fSzPDiK236r6mmIXbf3OGHcJrvJCZQgQy8OHIpW3(mdlhzVT7FbIeggm0qnmPZWqXh4BFMHLJS329VarcddgAeJdfXOGHcJrvJCZQgQy8OHcvZGKFT1Dtqd1WKoddfQMbj)AR7MGgX4WtyuWqHXOQrUzvdvmE0q9dwHPdKBxOhEpscjwsHH9wJed1WKodd1pyfMoqUDHE49ijKyjfg2BnsmIrmu5cg3OGXbAnkyOgM0zyOuribHV7yHHcJrvJCZQgX4GZgfmudt6mmuQ6m52YpKUHcJrvJCZQgX4W6nkyOgM0zyOkBiQQZKBOWyu1i3SQrmoO4gfmudt6mmuFcABb9edfgJQg5MvnIrmIHYncjDgghCEPotlT0UuNnuBgy0XcIH6j)KkQDyD4WZMMpWbuOaEG2VNq5aLj8alt05gRa74nkKLpaexx)gI8dqspEG5lPFeKFawHjwGK6Tvr7apaT08bEEgUrOG8dq1(NFac9qMxh4zEajpGI(NdWB3nPZ4a5ochjHhWPID8ao58lhR3wfTd8aotZh45z4gHcYpav7F(bi0dzEDGN5bK8ak6FoaVD3KoJdK7iCKeEaNk2Xd4KZVCSEBv0oWdSEA(appd3iuq(bOA)ZpaHEiZRd8mpGKhqr)Zb4T7M0zCGChHJKWd4uXoEaNw)lhR32B7t(jvu7W6WHNnnFGdOqb8aTFpHYbkt4bwMLUXycXoQTUf6lFaiUU(ne5hGKE8aZxs)ii)aSctSaj1BRI2bEaAP5d88mCJqb5hyzs(1QDWRpD5di5bwMKFTAh86tRymQAKV8bCI2xowVTkAh4bCMMpWZZWncfKFGLj5xR2bV(0LpGKhyzs(1QDWRpTIXOQr(YhWjAF5y92QODGhy908bEEgUrOG8dSmj)A1o41NU8bK8altYVwTdE9PvmgvnYx(aor7lhR3wfTd8akonFGNNHBeki)altYVwTdE9PlFajpWYK8Rv7GxFAfJrvJ8LpGto)YX6Tvr7apqrO5d88mCJqb5hyzs(1QDWRpD5di5bwMKFTAh86tRymQAKV8bCA9VCSEBv0oWd8e08bEEgUrOG8dSmj)A1o41NU8bK8altYVwTdE9PvmgvnYx(aor7lhR3wfTd8affA(appd3iuq(bwMKFTAh86tx(asEGLj5xR2bV(0kgJQg5lFaNO9LJ1BRI2bEafdnFGNNHBeki)altYVwTdE9PlFajpWYK8Rv7GxFAfJrvJ8LpWihyDRyPOhWjAF5y92EBFYpPIAhwho8SP5dCafkGhO97juoqzcpWYcD4eILGYFF5daX11VHi)aK0Jhy(s6hb5hGvyIfiPEBv0oWdSEA(appd3iuq(bwg(dSmHlW6tx(asEGLH)alt4cS(0kgJQg5lFaNO9LJ1B7T9j)KkQDyD4WZMMpWbuOaEG2VNq5aLj8alZXY5RLLpaexx)gI8dqspEG5lPFeKFawHjwGK6Tvr7apGIHMpWZZWncfKFGLj5xR2bV(0LpGKhyzs(1QDWRpTIXOQr(YhWP1)YX6Tvr7apWZGMpWZZWncfKFGLj5xR2bV(0LpGKhyzs(1QDWRpTIXOQr(YhWjAF5y92QODGhGwNP5d88mCJqb5hyz4pWYeUaRpD5di5bwg(dSmHlW6tRymQAKV8bCI2xowVTkAh4bOD908bEEgUrOG8dSm8hyzcxG1NU8bK8ald)bwMWfy9PvmgvnYx(aJCG1TILIEaNO9LJ1BRI2bEaAlk08bEEgUrOG8dSm8hyzcxG1NU8bK8ald)bwMWfy9PvmgvnYx(aor7lhR3wfTd8a0QyO5d88mCJqb5hyz4pWYeUaRpD5di5bwg(dSmHlW6tRymQAKV8bg5aRBflf9aor7lhR3wfTd8a0(mO5d88mCJqb5hyz4pWYeUaRpD5di5bwg(dSmHlW6tRymQAKV8bCI2xowVT32N8tQO2H1HdpBA(ahqHc4bA)EcLduMWdSSa74nkKLpaexx)gI8dqspEG5lPFeKFawHjwGK6Tvr7apqrO5d88mCJqb5hyzb2XBuQ0wF6YhqYdSSa74nkvH26tx(aor7lhR3wfTd8apbnFGNNHBeki)allWoEJs156tx(asEGLfyhVrPkoxF6YhWjAF5y92EBFYpPIAhwho8SP5dCafkGhO97juoqzcpWY5ogiC5daX11VHi)aK0Jhy(s6hb5hGvyIfiPEBv0oWdqlnFGNNHBeki)altYVwTdE9PlFajpWYK8Rv7GxFAfJrvJ8LpWihyDRyPOhWjAF5y92EBxh(9eki)a0U0dmmPZ4a6MiK6T1qnFPqcnugQDyw2A0qrt00bkA0NrQZf0pWtEG6K9(2st00bkiYoHMlU4fTu4RwzPVys7)6r6myWPukM0EwX3wAIMoGInuf(hi9d4mTkFaNxQZoFBVT0enDGNxyIfiHMVT0enDGLCaQDuRpGIMS31BlnrthyjhqXk00paezP3Jb)afn6Zqn1Yb2H4syPxDKd0LhOLd0Kd0brMqoGtj8afgiNne5aLj8aQjHGehR3wAIMoWsoqrvUbHhGQ3lKXbgTo3G8dSdXLWsV6ihqYdSdt2b6GitihOOrFgQPwQ3wAIMoWsoqrL7IQdiJgd5aDiie(3L6TLMOPdSKd8KCNn)auRUK1EwMp7dq2h)b2uaJdqp)ldXdePCGrn)YbK8aKV3NXbMdOaD4es92st00bwYbuSPrsbgCkLIFwK6rAnEaQu7gd5aSjyO22LhGvyIfi)asEGoeec)7ITlR3wAIMoWsoGcq6hqYdmUZMFGndr6yXbkA0NrZoWZtiEaImS3K6TLMOPdSKdOaK(bK8a(5nEGChdeEGDyNWwOFGm00pWMe((aD5b2GhGnXbgM8hTM(bYDmoWMwkCG5akqhoHuVT3wA6aR7xi7li)aQyzcXdWsV6ihqfx0bPEGNeJH7c5arglPWa9LF9bgM0zqoqgA61B7WKodsDhIS0RoIsUk29a7rvJkhJhDv2qIyf6WjeR0Eu5C3fbfL7sxQ)YYQQotU(tK6Fxz3J(JUODPk7E0F0IAc6IwNVTdt6mi1DiYsV6ik5Q4pbTTGELJXJUifgEUb52eQAZsRKqpgYTDysNbPUdrw6vhrjxfxIAlp9DmsNHYDPlP94Al9HISJsD0TB82omPZGu3Hil9QJOKRIjFVpd7ok32HjDgK6oezPxDeLCv8NG2wqVYX4rxs6rBwA9zqey(jwwgeb(zsNb52omPZGu3Hil9QJOKRI)e02c6vogp6IKACkqSeKbrXkiRq0RRpEBhM0zqQ7qKLE1ruYvXLAKuGbNs52omPZGu3Hil9QJOKRI3Zni0s69czOCx6s9xww30AUT97Kkrg271O9H6VSSYrFgnZYsiwjYWEtdxoFBhM0zqQ7qKLE1ruYvXC0NHAQfL7sxoPMeYkRmmPZOYrFgQPwQSHiUwQJpi5xBjfgiNqdf)2omPZGu3Hil9QJOKRIjfgEUXQMAr5U0LI4KAsiRSYWKoJkh9zOMAPYgI4APoUYkK8RTKcdKtwB932BlnDG19lK9fKFa0ncPFaP94bKc4bgMKWd0KdmUNwpQASEBhM0zqCr2rT2Qt27B7WKodIsUkMnATTe1f(HGWB7WKodIsUkEEHwjjKB7WKodIsUkMJUZp06Nfn72omPZGOKRIzJwBhM0zy1nruogp6sGD8gfYTDysNbrjxfZgT2omPZWQBIOCmE0vUJbcvMiWMjUOv5U0LKlwOXkltnp3eKhs7rA4EG9OQXAzdjIvOdNqSs7XhSm18CtujFVpdlh9z0mRqhoHuHOF6Gqd3dShvnwlBirScD4eIvApUeP94TDysNbrjxfZZ0RCx6cILqKuyu14TDysNbrjxfZgT2omPZWQBIOCmE0flDJXeIDuBDl0vMiWMjUOv5U0fj)A1o41fW0nA7WDViHJ0zSYkK8Rv7GxlBuZTzPvvNes6jRScj)A1o4vw6vhX6rElJ0zSYkS0ngti1azWuNq(TDysNbrjxfVNsNHYDPlNyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCxl9H0ECn3dShvnwlBirScD4eIvApUYkK8Rv7GxHyzhi3Up6rWhSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itqonwVIXXB7WKodIsUkMnATDysNHv3er5y8OlHoCcXsq5VFBhM0zquYvXSrRTdt6mS6MikhJhDLlyCLjcSzIlAvUlDTJsLJ(mAMvOdNqQdtA34TDysNbrjxfZrFgnZseiglKck3LUCsrG)alt4cSUP1LqKtSKErRTzPL83ryNql579z0XIhSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(ApdhxzfN2rPYrFgnZk0Hti1HjTB8Xokvo6ZOzwHoCcPcr)0bHgpX6CbJx9ZlhVTdt6mik5Qy2O1woehorg9BesuUlDXYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5R58sxsrwNkc8hyzcxG1nTUeICIL0lATnlTK)oc7eAjFVpJowCBhM0zquYvX75geAj9EHmuUlDP(llRBAn32(DsLid79A0(q9xww5OpJMzzjeRezyVPX6VTdt6mik5Qy1wJew(HlqRA6vrir5U0L6VSSk0HtivEUjEWYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5RvKB7WKodIsUkU976K0zOCx6Ays7gTyG(gjRrRsor76ugngsLmmyx2mKBj5xtQymQAK74d1FzzDtR522VtQezyVxZ1t8q9xwwf6WjKkp3epyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG81kYTDysNbrjxf3(DDs6muUlDnmPDJwmqFJK1C(H6VSSUP1CB73jvImS3R56jEO(llRcD4esLNBIhSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(Af5HIa)bwMWfyT976K0Ur7Ekyi9OF4KIiJgdPwctVvkGwsHHNBivmgvnYxzf1FzzTeMERuaTKcdp3qQ)DhVTdt6mik5Q42VRtsNHYDPRHjTB0Ib6BKSMZpu)LL1nTMBB)oPsKH9EnxpXd1FzzT976K0Ur7Ekyi9ORq0pDqOHZpG)alt4cS2(DDsA3ODpfmKE032HjDgeLCvC731jPZq5U0L6VSSUP1CB73jvImS3R5IwNFiJgdPsYV2YYG)BPIXOQr(dz0yi1sy6Tsb0skm8CdPIXOQr(d4pWYeUaRTFxNK2nA3tbdPh9d1FzzvOdNqQ8Ct8GLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYxRi32HjDgeLCv8cy7ZgI2suV4pqUYDPl1KqEiThTsA5nsJ1V0B7WKodIsUkM89(mSUBnw2yWvUlDPMeYdP9OvslVrA4SI52omPZGOKRIjFVpdlh9z0mRqhoHOCx6snjKhs7rRKwEJ0G2ICBhM0zquYvXfMGBZs7IVMpHYDPls(1wsHbYDvKBlnDG1r5bkAioCIm63iKCGbIhy0qC40pWWK2nQ8bI8abI8di5biJB8aKcdKtUTdt6mik5Q4ctWTzPDXxZNq5U0fj)AlPWa5R5A9pCAhLkhIdNiJ(ncRdtA34kRSJsLJ(mAMvOdNqQdtA3OJ32HjDgeLCvCHj42S0U4R5tOCx6IKFTLuyG81Cr7d1FzznqPacT7jugD9V)GLPMNBIkB0AlhIdNiJ(ncjvi6NoiR586CbJx9ZRB7WKodIsUkUWeCBwAx818juUlDrYV2skmq(AUO9bltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKtJfmE1pVEiThxJwNxYcgV6NxpCs9xww5qC4ez0VriP(3FO(llRCioCIm63iKuHOF6GS2WKoJAHj42S0U4R5tuXxi7lOvApQ0WKoJk579zy5OpJMzf6WjKk(czFbTs7rhF4KIiJgdPs(EFgw3TglBm4vmgvnYxzf1Fzz1DRXYgdE9V74TDysNbrjxfZgT2omPZWQBIOCmE0flDJXeIDuBDl0vMiWMjUOv5U0LIWs3ymHuDJHuGo82sth4j3sH8lhGAyWUSzi)au5xtu(au5xFakb2VXd0Kdqeyglq4bKctCGIg9zOMAr5dqYd0YbkmKdmhOqVOacpWoStyl0VTdt6mik5Qys(1wIa73OYDPlfrgngsLmmyx2mKBj5xtQymQAKFBPPdqTJb)afn6ZOzh45jejhOmHhGk)6dqvyGCYb(H06dOaD4eYbyzQ55M4an5amDsWdi5bG4WPFBhM0zquYvXC0NHAQfL7sxQ)YYkh9z0mllHyfIdtEqYV2skmqonu8hSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(AoV0BlnDGI(d7yXbuGoCc5aeu(7kFaYog8du0OpJMDGNNqKCGYeEaQ8RpavHbYj32HjDgeLCvmh9zOMAr5U0L6VSSYrFgnZYsiwH4WKhK8RTKcdKtdf)bltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKtdAD(2omPZGOKRI5Opd1ulk3LUu)LLvo6ZOzwwcXkehM8GKFTLuyGCAO4pCs9xww5OpJMzzjeRezyVxZ5vwrgngsLmmyx2mKBj5xtQymQAK74TDysNbrjxfZrFgQPwuUlDP(llRC0NrZSSeIviom5bj)AlPWa50qXFmmPDJwmqFJK1O92omPZGOKRIj5xBjcSFJ32HjDgeLCvmB0A7WKodRUjIYX4rxS0ngti2rT1Tq)2sthyDuEa65)aSjoWcuoG6WEFajpqroav(1hGQWa5KdOILjepqrdXHtKr)gHKdWYuZZnXbAYbG4WPR8bAzzYbY3d9di5bi7yWpGua9hiYn32HjDgeLCvCHj42S0U4R5tOCx6IKFTLuyG81CT(hSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itq(AoxKhojJgdPYrFgnZYgTUJfvmgvnYxzfwMAEUjQSrRTCioCIm63iKuHOF6GSMtovKLqYV2skmqUJRZHjDgvsHHNBSQPwQ4lK9f0kThDuPHjDg1ctWTzPDXxZNOIVq2xqR0E0XB7WKodIsUkMNPxzgDMgTYaxGcXfTk3LUGyjejfgvn(qApUM7b2JQgRLnKiwHoCcXkThVT00buStWdu0Opd1ulhOlpa98VmepWISJfhqYdOtcEGIg9z0Sd88eIhGid7nr5dGUX4aD5bAzz(b2mebpWCas(1hGuyG86TDysNbrjxfZrFgQPwuUlDP(llRC0NrZSSeIviom5H6VSSYrFgnZYsiwHOF6GqdAvAbJx9ZR1P6VSSYrFgnZYsiwjYWEFBhM0zquYvXKcdp3yvtTCBVTdt6mivIo3yfyhVrH46tqBlOx5y8Ols(1AuKowyHFv6k3LUyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCAidCbkvEtKjy4ZSipK2JR5EG9OQXAzdjIvOdNqSs7XL4KmWfOu5nrMGHpZI44TDysNbPs05gRa74nkeLCv8NG2wqVYX4rxKFOQZKBhpkfOteL7sxSm18CtujFVpdlh9z0mRqhoHuHOF6GyXx7itqonKbUaLkVjYem8zwKhs7X1CpWEu1yTSHeXk0HtiwP94sCsg4cuQ8MitWWNzrC82sthqXcYJjy4bkmKdmhGwNpabzzWpah1d9dmb)an5asbeILjepa5DVVJ8duMWdu2qICafOdNqoGKhq3bEG)(b20sHdifWdarICBhM0zqQeDUXkWoEJcrjxf)jOTf0RCmE0f63PdXrBtipMGHk3LUyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCA4KmWfOu5nrMGHpZI4Os068dwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKjiFnNCYjzGlqPYBImbdFMfXrLO1zhxcTfXXhs7X1CpWEu1yTSHeXk0HtiwP94sCYjzGlqPYBImbdFMfXrLO1zhVT32HjDgKklDJXeIDuBDl0DrYV2ctr5U0fj)A1o41fW0nA7WDViHJ0z8WjwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKjiNgoV0vwHLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYxB9l1XB7WKodsLLUXycXoQTUf6k5Qys(1wykk3LUi5xR2bVw2OMBZsRQojK0tESJsLJ(mAMvOdNqQdtA34TDysNbPYs3ymHyh1w3cDLCvmj)AlmfL7sxK8Rv7Gx30AUTWpeRmmPzKhkYokvo6ZOzwHoCcPomPDJpyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG81OvXCBhM0zqQS0ngti2rT1TqxjxfZrw7hPJfw1ulk3LUCIKFTAh8QghUvLUfFn(DnUYkK8Rv7GxFJU7GyZ8zf1DSWXhoTJsLJ(mAMvOdNqQdtA34ds(1wsHbYPHZRSIISJsLJ(mAMvOdNqQdtA34dwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKjiFnfFPoEBhM0zqQS0ngti2rT1TqxjxfZrw7hPJfw1ulk3LUCIKFTAh8AzcxGQjmqleDJWgjRSItK8Rv7GxDN6rAnAjP2ngYdfHKFTAh86B0DheBMpROUJfo64dfzhLkh9z0mRqhoHuhM0UXB7WKodsLLUXycXoQTUf6k5Q4snskWGtPOCx6IKFTAh8Q7upsRrlj1UXqEO(llRUt9iTgTKu7gdPYZnHYDiie(3fBx6s9xwwDN6rAnAjP2ngs9VFBhM0zqQS0ngti2rT1Tqxjxfty5h2XcR0sbu5U0fj)A1o4vw6vhX6rElJ0z8yhLkh9z0mRqhoHuhM0UXB7WKodsLLUXycXoQTUf6k5Qycl)WowyLwkGk3LUues(1QDWRS0RoI1J8wgPZ42omPZGuzPBmMqSJARBHUsUkU97yW7yHLnYqeyUxavUlDTJsLJ(mAMvOdNqQdtA34ds(1wsHbYDT0B7TDysNbPwy3kWoEtC9jOTf0RCmE0fPJYV2Uqp8EKesSOxvJ(B7WKodsTWUvGD8MOKRI)e02c6vogp6I0r5xBhYEdNqiw0RQr)T92omPZGuZfmUlvesq47owCBhM0zqQ5cgxjxfRQZKBl)q632HjDgKAUGXvYvXLnev1zYVTdt6mi1CbJRKRI)e02c6j32B7WKodsn3XaHUi5xBHPOCx6IKFTAh86cy6gTD4UxKWr6mUTdt6mi1ChdeQKRIdukGq7EcLrFBhM0zqQ5ogiujxfVa2(SHOTe1l(dKFBhM0zqQ5ogiujxft(EFgw3TglBm432HjDgKAUJbcvYvXC0NHAQfL7sxQ)YYkh9z0mllHyfIdtEqYV2skmqonu8hSm18CtuzJwB5qC4ez0VriP(3VTdt6mi1ChdeQKRIjfgEUXQMAr5U0fj)AlPWa50OipyzQ55MOYgT2YH4WjYOFJqs9VFBhM0zqQ5ogiujxfZgT2YH4WjYOFJqYT92omPZGu3)q0Yh)SaTcSJ3exFcABb9khJhDXH4WlBiADJecQVTdt6mi19peT8XplqRa74nrjxf)jOTf0RCmE0fj)ABViAbH32HjDgK6(hIw(4NfOvGD8MOKRI)e02c6vogp6AHM(EbBwAhcP9TEKodL7sxdtA3Ofd03iXfT32HjDgK6(hIw(4NfOvGD8MOKRI)e02c6vogp6IpW3(mdlhzVT7FbIeggm82omPZGu3)q0Yh)SaTcSJ3eLCv8NG2wqVYX4rxOAgK8RTUBcEBhM0zqQ7FiA5JFwGwb2XBIsUk(tqBlOx5y8ORFWkmDGC7c9W7rsiXskmS3AKCBVTdt6mivb2XBuiU(e02c6vogp6Iuy45gKBtOQnlTsc9yik3LUyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCA4SZ32HjDgKQa74nkeLCvmB0A7WKodRUjIYX4rxf2TcSJ3eL7sxYOXqQC0NrZSSmiF)U0zuXyu1i)bltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKtdNx6TLMoW6USezc5asHroGah3O(aeDUrt)asEazGlq5aqCD9BiEGHZBPZy0kFacUpWrWduycUUJf32HjDgKQa74nkeLCvmB0A7WKodRUjIYX4rxeDUXkWoEJc52omPZGufyhVrHOKRI)e02c6vogp6kDJWsDUPJf2jA)yzZcu5U01okvo6ZOzwHoCcPomPDJ32HjDgKQa74nkeLCvSa74nk0QCx6sGD8gLkT1cdX(jOv9xw(yhLkh9z0mRqhoHuhM0UXB7WKodsvGD8gfIsUkwGD8gfNvUlDjWoEJs15AHHy)e0Q(llFSJsLJ(mAMvOdNqQdtA34TDysNbPkWoEJcrjxfZgT2omPZWQBIOCmE01(hIw(4NfOvGD8MOCx6sApUM7b2JQgRLnKiwHoCcXkThFWYuZZnrL89(mSC0NrZScD4esfI(PdIfFTJmb5R58sVT32HjDgKQqhoHyjO83DfOuaH29ekJw5U0fltnp3evY37ZWYrFgnZk0Htivi6Noiw81oYeKtdAlYTDysNbPk0Htiwck)DLCv8cy7ZgI2suV4pqUYDPlwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKjiNg0wuwItdt6mQKV3NHLJ(mAMvOdNqQ4lK9f0kThvAysNrLuy45gRAQLk(czFbTs7rhF4eltnp3ev2O1woehorg9BesQq0pDqObTfLL40WKoJk579zy5OpJMzf6WjKk(czFbTs7rLgM0zujFVpdR7wJLng8k(czFbTs7rLgM0zujfgEUXQMAPIVq2xqR0E0XvwzhLkhIdNiJ(ncRq0pDqwJLPMNBIk579zy5OpJMzf6WjKke9thel(AhzcYvAysNrL89(mSC0NrZScD4esfFHSVGwP9OJ32HjDgKQqhoHyjO83vYvXKV3NH1DRXYgdUYDPlNyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCAqBrwItdt6mQKV3NHLJ(mAMvOdNqQ4lK9f0kThD8HtSm18CtuzJwB5qC4ez0VriPcr)0bHg0wKL40WKoJk579zy5OpJMzf6WjKk(czFbTs7rLgM0zujFVpdR7wJLng8k(czFbTs7rhxzLDuQCioCIm63iScr)0bznwMAEUjQKV3NHLJ(mAMvOdNqQq0pDqS4RDKjixPHjDgvY37ZWYrFgnZk0Htiv8fY(cAL2Jo64kR4KIa)bwMWfyDtRlHiNyj9IwBZsl5VJWoHwY37ZOJfpyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMG81u8L64TDysNbPk0Htiwck)DLCvmB0AlhIdNiJ(ncjk3LUyzQ55MOs(EFgwo6ZOzwHoCcPcr)0bXIV2rMGCAqRZlXPHjDgvY37ZWYrFgnZk0Htiv8fY(cAL2JknmPZOskm8CJvn1sfFHSVGwP9OJ32HjDgKQqhoHyjO83vYvXKV3NHLJ(mAMvOdNquUlDjThxZ9a7rvJ1YgseRqhoHyL2JpCAhLkhIdNiJ(ncRdtA34JDuQCioCIm63iScr)0bzTHjDgvY37ZWYrFgnZk0Htiv8fY(cAL2Jo(WjfrgngsL89(mSUBnw2yWRymQAKVYk7OuD3ASSXGxhM0UrhF4ej)AlPWa5Uw6kR40okvoehorg9BewhM0UXh7Ou5qC4ez0VryfI(PdcngM0zujFVpdlh9z0mRqhoHuXxi7lOvApQ0WKoJkPWWZnw1ulv8fY(cAL2JoUYkoTJs1DRXYgdEDys7gFSJs1DRXYgdEfI(PdcngM0zujFVpdlh9z0mRqhoHuXxi7lOvApQ0WKoJkPWWZnw1ulv8fY(cAL2JoUYkoP(llRlGTpBiAlr9I)a51)(d1FzzDbS9zdrBjQx8hiVcr)0bHgdt6mQKV3NHLJ(mAMvOdNqQ4lK9f0kThvAysNrLuy45gRAQLk(czFbTs7rhD0igXyaa]] )


end
