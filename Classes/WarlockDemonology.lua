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


    spec:RegisterStateExpr( "first_tyrant_time", function()
        local last = action.summon_demonic_tyrant.lastCast
        if last > combat then return last - combat end
        return max( 10, time + cooldown.summon_demonic_tyrant.remains_expected )
    end )

    spec:RegisterStateExpr( "in_opener", function()
        if action.summon_demonic_tyrant.lastCast > state.combat then return false end
        if cooldown.summon_demonic_tyrant.remains_expected <= 10 then return true end
        return false
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

        local subjugated, icon, count, debuffType, duration, expirationTime = FindUnitDebuffByID( "pet", 1098 )
        if subjugated then
            summonPet( "subjugated_demon", expirationTime - now )
        else
            dismissPet( "subjugated_demon" )
        end

        local sdt = class.abilities.summon_demonic_tyrant

        first_tyrant_cast = nil

        if Hekili.ActiveDebug then
            Hekili:Debug(   " - Dreadstalkers: %d, %.2f\n" ..
                            " - Vilefiend    : %d, %.2f\n" ..
                            " - Grim Felguard: %d, %.2f\n" ..
                            " - Wild Imps    : %d, %.2f\n" ..
                            " - Malicious Imp: %d, %.2f\n" ..
                            "Next Demon Exp. : %.2f",
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

                extend_demons()

                if level > 57 or azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
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


    spec:RegisterPack( "Demonology", 20220226, [[d00I9bqiPI8ikGUefiWMKQ6tsfgffLtrHAvOGQxrr1SqHULsr2Lu(LujdtPGJrbTmPs9muattPOUMuf2Mur5BuG04qbLZPuOADOanpLkDpuQ9PuXbrbPwOuLEifGjQuixefKSrkqKpkvuPrsbc1jvkuwPsPzsbQDsf5Nsfv1qLkQYsLkQ4PGAQuixLceYwPab9vuq0yLQO9sP)syWiDyHfRkpMOjtvxgAZuPpJsgnv40IEnkYSr1TvYUL8Bfdxv54OGWYbEoIPt66GSDvvFhf14vQ68uK1tbIA(urTFv2AO1ilSpu06u3BO7U3q3D3znd7mdnOByJBHvtFOf(lKmfSqlCfl0cVr4AQHpSmzH)ct8j8wJSWKbcirlmCUmal8dk56gRSplSpu06u3BO7U3q3D3znd7md3WMzalm5dLwN6UZ6mlSJ07XY(SWEKiTWBeUMA4dlthLHma8rY0T1HQFegSRUyLQdOxtoRUi5cIhAoLeeUAxKCj762AqcFaOay6OD3dgpA3BO7UVT3wdWruSqcdEB30rH)qo)Og8izQDB30r78lUPJcq5Swy5p6gHRPEdxp6ha3KCwVqpA6E0upAsoAwenk9OMnGJ6iaEzq0J6oGJ(gcbjg3UTB6ODEdZi4OW5NJPoAW5dZO)OFaCtYz9c9O6C0pWipAwenk9OBeUM6nCTDB30r78(78oQgCS0JMLIaa0N2UTB6Om0)t6pkCVBAhdINo3Js(I1rz2bwh10a1bapAn6rJ3aPhvNJsGwRPoACuJmbIsB32nDudsCK4qccxTldchEOjhpk8W)XspQmkjYfP7rLoIIf6pQohnlfbaOpvKUTB7MoQrathvNJg)t6pkZbrZI1r3iCnvkpQbma8OenKmrA32nDuJaMoQohDfmHhD(Wcbh9dKdivthDkUPJY8ay6OP7rzgpQmQJgsfk4CthD(W6OmNQJJgh1itGO0MfMNeLynYcpFyHaRrwNm0AKfgR4XrVTxlSeKkcYWctgi(llFJfy(rrw)jRbeAovdR4XrVfoKAoLfMmqCbyuRADQBRrw4qQ5uw4cvhiq8nan4wySIhh92ETQ1jgWAKfoKAoLfMfixtcqHlYzbfaVfgR4XrVTxRADAZwJSWHuZPSWeO1AkXFYr3elVfgR4XrVTxRADQhwJSWyfpo6T9AHLGurqgwyYaXfehbWF0DpApoA)JkNH7hMRMm4CHhGHNObNjeqAqFw4qQ5uwyIJWpmlEdxTQ1PoZAKfgR4XrVTxlSeKkcYWc)hGmECSbrqXB4QqZvwSihT)rjdexqCea)r39O94O9p6dY1T9cos(spciIheOYILqoaSr0qY0r39OB2chsnNYctCe(HzXB4QvTozqTgzHdPMtzHLbNl8am8en4mHaIfgR4XrVTxRAvlSJpHcYIjI1iRtgAnYcJv84O32RfUIfAHjz5cXfS4HpdDaebUECCzHdPMtzHjz5cXfS4HpdDaebUECCzvRtDBnYcJv84O32RfUIfAHjz5cXfb5lbrPebUECCzHdPMtzHjz5cXfb5lbrPebUECCzvRAHLZpwrPI4L8unznY6KHwJSWyfpo6T9AHLGurqgwyYaXFz5BSaZpkY6pznGqZPAyfpo6pA)JA2r)dqgpo2kCVkutGOuH0F0DpA3B4Oo78r)dqgpo2kCVkutGOuH0F0DokdSHJASfoKAoLfMmqCbyuRADQBRrwySIhh92ETWsqQiidlmzG4VS8n3e5EX4kE8HqMfPHv84O)O9p6hQnpUMkLc1eikTfsn)rlCi1CklmzG4cWOw16edynYcJv84O32RfwcsfbzyHjde)LLVXCY9chqLk0qQPK0WkEC0F0(hTth9d1MhxtLsHAceL2cPM)4r7F0)aKXJJTc3Rc1eikvi9hDNJAidZchsnNYctgiUamQvToTzRrwySIhh92ETWsqQiidlCNo6FaY4XXgebfVHRcnxzXIC0(hLmq8xw(ghdV4zsG7J1hhByfpo6pA)JA2r)qT5X1uPuOMarPTqQ5pE0(hLmqCbXra8hD3J29rD25J2PJ(HAZJRPsPqnbIsBHuZF8O9p6FaY4XXwH7vHAceLkK(JUZr38goQXw4qQ5uwypkZvOzXs8gUAHLMKCuObGfQeRtgAvRt9WAKfgR4XrVTxlSeKkcYWc3PJ(hGmECSbrqXB4QqZvwSihT)rjde)LLVXe(NfrmJbzKNfRgwXJJ(J2)OMD0puBECnvkfQjquAlKA(Jh1zNpANo6hQnpUMkLc1eikTfsn)XJ2)O)biJhhBfUxfQjquQq6p6ohDZB4OgBHdPMtzH9OmxHMflXB4QfwAsYrHgawOsSozOvTo1zwJSWyfpo6T9AHLGurqgw4oD0)aKXJJnickEdxfAUYIf5O9pQzhLmq8xw(M7ayHVbuOaG)iirsdR4Xr)rD25JA2rjde)LLV9p8qtokid)hlTHv84O)O9pANokzG4VS8nMW)SiIzmiJ8Sy1WkEC0FuJpQXhT)r70r)qT5X1uPuOMarPTqQ5pAHdPMtzH9OmxHMflXB4QfwAsYrHgawOsSozOvTozqTgzHXkEC0B71clbPIGmSW)biJhhBqeu8gUk0CLflYr7FuZoANoQgCS023WmceK8ZXunSIhh9h1zNpQCgUFyUAFdZiqqYpht1a4kYIC0DpAi1CQMhL5k0SyjEdxB4EucPOqZfEuJpA)J2PJkNH7hMRgbATMs4X1uPuOMarPnOVJ2)OMD0puBECnvkfQjquAdGRilYr39OmSJ6SZhvod3pmxnc0AnLWJRPsPqnbIsBaCfzre4(puQO)O7Eugydh1ylCi1CklShL5k0SyjEdxTWstsok0aWcvI1jdTQ1jgM1ilCwkcaqFQiDTWpix32)Wdn5OGm8FS0g0NfgR4XrVTxlCi1CklSlhjoKGWvTWsqQiidlmzG4VS8T)HhAYrbz4)yPnSIhh9hT)rFqUUT)HhAYrbz4)yPn)WCzvRtBCRrwySIhh92ETWsqQiidlmzG4VS8n5SEHkwOp1qZPAyfpo6pA)J(HAZJRPsPqnbIsBHuZF0chsnNYctKdeilwcnvhOvToz4gSgzHXkEC0B71clbPIGmSWD6OKbI)YY3KZ6fQyH(udnNQHv84O3chsnNYctKdeilwcnvhOvTozOHwJSWyfpo6T9AHLGurqgw4puBECnvkfQjquAlKA(JhT)rjdexqCea)rzF0nyHdPMtzHZ1hw(SyjKHgefmFoqRAvlSAceLkiOc9znY6KHwJSWyfpo6T9AHLGurqgw4)aKXJJTc3Rc1eikvi9hD3JAypSWHuZPSWfQoqG4BaAWTQ1PUTgzHXkEC0B71clbPIGmSW)biJhhBfUxfQjquQq6p6Uh1qd6r30rn7OHuZPAeO1AkHhxtLsHAceL2W9OesrHMl8OMF0qQ5unIJWpmlEdxB4EucPOqZfEuJpA)JA2rLZW9dZvtgCUWdWWt0GZecinaUISihD3JAOb9OB6OMD0qQ5unc0AnLWJRPsPqnbIsB4EucPOqZfEuZpAi1CQgbATMs8NC0nXY3W9OesrHMl8OMF0qQ5unIJWpmlEdxB4EucPOqZfEuJpQZoF0puBEagEIgCMqqdGRilYr35O)biJhhBfUxfQjquQq6pQ5hnKAovJaTwtj84AQukutGO0gUhLqkk0CHh1ylCi1CklmlqUMeGcxKZckaERADIbSgzHXkEC0B71clbPIGmSWMD0)aKXJJTc3Rc1eikvi9hD3JAypo6MoQzhnKAovJaTwtj84AQukutGO0gUhLqkk0CHh14J2)OMDu5mC)WC1KbNl8am8en4mHasdGRilYr39Og2JJUPJA2rdPMt1iqR1ucpUMkLc1eikTH7rjKIcnx4rn)OHuZPAeO1AkXFYr3elFd3JsiffAUWJA8rD25J(HAZdWWt0GZecAaCfzro6oh9paz84yRW9QqnbIsfs)rn)OHuZPAeO1AkHhxtLsHAceL2W9OesrHMl8OgFuJpQZoFuZoANokaQq3bWcBmNCxa6jcsYk5IXvqG(qqoabbATMklwnSIhh9hT)r)dqgpo2kCVkutGOuH0F0Do6M3Wrn2chsnNYctGwRPe)jhDtS8w160MTgzHXkEC0B71clbPIGmSW)biJhhBfUxfQjquQq6p6Uh1WUp6MoQzhnKAovJaTwtj84AQukutGO0gUhLqkk0CHh18JgsnNQrCe(HzXB4Ad3JsiffAUWJASfoKAoLfwgCUWdWWt0GZeciw16upSgzHXkEC0B71clbPIGmSWAUWJUZrDtarfQjquQqZfE0(h1SJ(HAZdWWt0GZecAHuZF8O9p6hQnpadprdotiObWvKf5O7C0qQ5unc0AnLWJRPsPqnbIsB4EucPOqZfEuJpA)JA2r70r1GJL2iqR1uI)KJUjw(gwXJJ(J6SZh9d12FYr3elFlKA(Jh14J2)OMDuYaXfehbWFu2hDdh1zNpQzh9d1MhGHNObNje0cPM)4r7F0puBEagEIgCMqqdGRilYr39OHuZPAeO1AkHhxtLsHAceL2W9OesrHMl8OMF0qQ5unIJWpmlEdxB4EucPOqZfEuJpQZoFuZo6hQT)KJUjw(wi18hpA)J(HA7p5OBILVbWvKf5O7E0qQ5unc0AnLWJRPsPqnbIsB4EucPOqZfEuZpAi1CQgXr4hMfVHRnCpkHuuO5cpQXh1zNpQzh9b562ybY1Kau4ICwqbW3G(oA)J(GCDBSa5AsakCrolOa4BaCfzro6UhnKAovJaTwtj84AQukutGO0gUhLqkk0CHh18JgsnNQrCe(HzXB4Ad3JsiffAUWJA8rn2chsnNYctGwRPeECnvkfQjquQvTQf2JUbexTgzDYqRrwySIhh92ETWEKib5NMtzHzO2Jsif9hf)rGPJQ5cpQ6apAi1bC0KC04psE84yZchsnNYct(qoxWhjtw16u3wJSWHuZPSWYGZfUi3buPiWcJv84O32RvToXawJSWHuZPSWXEuOdHyHXkEC0B71QwN2S1ilCi1CklSh)hiGyfSsPfgR4XrVTxRADQhwJSWyfpo6T9AHNplmbvlCi1Ckl8FaY4Xrl8FWHqlSCgUFyUAeO1AkHhxtLsHAceL2a4kYIiW9FOurVf(paIkwOfUW9QqnbIsfsVfwcsfbzyH70rjde)LLV5Mi3lgxXJpeYSinSIhh9h1zNpQCgUFyUAeO1AkHhxtLsHAceL2a4kYIiW9FOur)r35OYz4(H5QrgiUamAdGRilIa3)Hsf9w16uNznYcJv84O32RfE(SWeuTWHuZPSW)biJhhTW)bhcTWYz4(H5QrgiUamAdGRilIa3)Hsf9w4)aiQyHw4c3Rc1eikvi9wyjiveKHfMmq8xw(MBICVyCfp(qiZI0WkEC0F0(hvod3pmxnc0AnLWJRPsPqnbIsBaCfzre4(puQO)O7Eu5mC)WC1idexagTbWvKfrG7)qPIERADYGAnYcJv84O32RfE(SWeuTWHuZPSW)biJhhTW)bhcTWUjGOc1eikvO5cp6MoQMl0c)harfl0cx4EvOMarPcP3clbPIGmSWAUWJU7rDtarfQjquQqZfAvRtmmRrwySIhh92ETWZNfMGQfoKAoLf(paz84Of(p4qOf(paz84yRW9QqnbIsfsVf(paIkwOf(b56kiMkPq6TWsqQiidlCNo6FaY4XXgebfVHRcnxzXIyvRtBCRrwySIhh92ETWZNfMGQfoKAoLf(paz84Of(p4qOfwod3pmxnpkZvOzXs8gU2a4kYIiW9FOurVf(paIkwOf(b56kiMkPq6TWsqQiidl8FaY4XXgebfVHRcnxzXIyvRtgUbRrwySIhh92ETWHuZPSWYGZfHuZPe8KOwyEsurfl0cRGSycvIvTozOHwJSWyfpo6T9AHdPMtzHLbNlcPMtj4jrTWsqQiidlSzhTth9paz84ydIGI3WvHMRSyroA)J(HAZJRPsPqnbIsBHuZF8OgFuND(OMD0)aKXJJnickEdxfAUYIf5O9p6dY1TrCeaVyCfrvPJKhAovd67O9pQzhTthvdowA7Bygbcs(5yQgwXJJ(J6SZh9b562(gMrGGKFoMQb9DuJpQXwyEsurfl0cpSKERADYWUTgzHXkEC0B71clbPIGmSW6WIfhBYz4(H5IC0(hvZfE0DpQBciQqnbIsfAUqlmrbPuTozOfoKAoLfwgCUiKAoLGNe1cZtIkQyHw45dleyvRtgYawJSWyfpo6T9AHLGurqgwya6cqIJ4XrlCi1CklSFMLvToz4MTgzHXkEC0B71clbPIGmSWKbI)YY3ybMFuK1FYAaHMt1WkEC0FuND(OKbI)YY3CtK7fJR4XhczwKgwXJJ(J6SZhLmq8xw(MCwVqfl0NAO5unSIhh9h1zNpQC(XkkTvOem8b4TWefKs16KHw4qQ5uwyzW5IqQ5ucEsulmpjQOIfAHLZpwrPI4L8unzvRtg2dRrwySIhh92ETWsqQiidl8FaY4XXgebfVHRcnxzXIC0(h9b562iocGxmUIOQ0rYdnNQb9zHdPMtzH)gMrGGKFoMYQwNmSZSgzHXkEC0B71clbPIGmSWMD0oD0)aKXJJnickEdxfAUYIf5O9p6FaY4XXwH7vHAceLkK(JU7rzj9TvS)O9pQMl8O7Cu3equHAceLk0CHh1zNpkzG4VS8na6Mf6fFbpuSHv84O)O9p6FaY4XXwH7vHAceLkK(JU7rzag2rn(Oo78rn7O)biJhhBqeu8gUk0CLflYr7F0hKRBJ4iaEX4kIQshjp0CQg03rn2chsnNYc)nAoLvTozOb1AKfgR4XrVTxlCi1CklSm4Cri1CkbpjQfMNevuXcTWQjquQGGk0NvTozidZAKfgR4XrVTxlSeKkcYWcB2r70rbqf6oawyJ5K7cqprqswjxmUcc0hcYbiiqR1uzXQHv84O)O9p6FaY4XXwH7vHAceLkK(JUZr34h14J6SZh1SJ(HAZJRPsPqnbIsBHuZF8O9p6hQnpUMkLc1eikTbWvKf5O7E0o7Om8JYs6BRy)rn2chsnNYc7X1uPuquawSuhw16KHBCRrwySIhh92ETWsqQiidl8FaY4XXgebfVHRcnxzXIC0(hvod3pmxnc0AnLWJRPsPqnbIsBaCfzre4(puQO)O7C0U72chsnNYcldox4by4jAWzcbeRADQ7nynYcJv84O32RfwcsfbzyH70r)dqgpo2GiO4nCvO5klwKJ2)OMD0)aKXJJTc3Rc1eikvi9hDNJ29go6MoApokd)OD6OaOcDhalSXCYDbONiijRKlgxbb6db5aeeO1AQSy1WkEC0FuJTWHuZPSWYGZfEagEIgCMqaXQwN62qRrwySIhh92ETWsqQiidlCNo6FaY4XXgebfVHRcnxzXIC0(h9b562yo5ErU(inIgsMo6oh1WJ2)Opix3MhxtLsHCayJOHKPJU7rzalCi1Ckl83WmceK8ZXuw16u3DBnYcJv84O32RfwcsfbzyHFqUUn1eikT5hMRJ2)O)biJhhBfUxfQjquQq6p6ohThw4qQ5uw4xYrICGaSqXBwpeqSQ1PUzaRrwySIhh92ETWsqQiidlCi18hfyHRejhDNJA4rn)OMDudpkd)OAWXsBKqcs3uIEbzG4KgwXJJ(JA8r7F0hKRBJ5K7f56J0iAiz6O7W(OD2r7F0hKRBtnbIsB(H56O9p6FaY4XXwH7vHAceLkK(JUZr7HfoKAoLfoxF8HKtzvRtDVzRrwySIhh92ETWsqQiidlCi18hfyHRejhDNJ29r7F0hKRBJ5K7f56J0iAiz6O7W(OD2r7F0hKRBtnbIsB(H56O9p6FaY4XXwH7vHAceLkK(JUZr7Xr7F0oDuauHUdGf2Y1hFi5pk(gflndEdR4Xr)r7FuZoANoQgCS0Mlywc1bkioc)WmPHv84O)Oo78r94dY1T5cMLqDGcIJWpmtAqFh1ylCi1CklCU(4djNYQwN6UhwJSWyfpo6T9AHLGurqgw4qQ5pkWcxjso6ohT7J2)Opix3gZj3lY1hPr0qY0r3H9r7SJ2)Opix3wU(4dj)rX3OyPzWBaCfzro6UhT7J2)OaOcDhalSLRp(qYFu8nkwAg8gwXJJElCi1CklCU(4djNYQwN6UZSgzHXkEC0B71clbPIGmSWpix3gZj3lY1hPr0qY0r3H9rnS7J2)OAWXsBKbIlKt5HsTHv84O)O9pQgCS0Mlywc1bkioc)WmPHv84O)O9pkaQq3bWcB56JpK8hfFJILMbVHv84O)O9p6dY1TPMarPn)WCD0(h9paz84yRW9QqnbIsfs)r35O9WchsnNYcNRp(qYPSQ1PUnOwJSWyfpo6T9AHLGurqgw43qihT)r1CHcDe(ep6UhLb2GfoKAoLfMfixtcqHlYzbfaVvTo1ndZAKfgR4XrVTxlSeKkcYWc)gc5O9pQMluOJWN4r39ODZWSWHuZPSWeO1AkXFYr3elVvTo19g3AKfgR4XrVTxlSeKkcYWc)gc5O9pQMluOJWN4r39Og2dlCi1CklmbATMs4X1uPuOMarPw16edSbRrwySIhh92ETWsqQiidlmzG4cIJa4pk7J2dlCi1CklSJO8IXvWcI7JYQwNyadTgzHXkEC0B71clbPIGmSWKbIliocG)O7E0EC0(hfavO7ayHTxWrYx6rar8GavwSeYbGnSIhh9hT)rFqUUTxWrYx6rar8GavwSeYbGnaUISihD3J2dlCi1CklmXr4hMfVHRw16ed0T1ilmwXJJEBVwyjiveKHfMmqCbXra8hDh2hLboA)JA2r)qT5by4jAWzcbTqQ5pEuND(OFO284AQukutGO0wi18hpQXw4qQ5uwyhr5fJRGfe3hLf2Jeji)0Ckl8gZ9OBeadprdotiGC0aGhn4am8MoAi18hz8O1C0cr)r15OK4hpkXra8eRADIbyaRrwySIhh92ETWsqQiidlmzG4cIJa4p6oSpQHhT)rFqUUTcvhiq8nan4nOVJ2)OYz4(H5Qjdox4by4jAWzcbKgaxrwKJUZr7(Om8JYs6BRyVfoKAoLf2ruEX4kybX9rzvRtmWMTgzHXkEC0B71clbPIGmSWKbIliocG)O7W(OgE0(h9paz84yRW9QqnbIsfs)r39OSK(2k2F0(hvZfE0DoQBciQqnbIsfAUWJUPJYs6BRyVfoKAoLf2ruEX4kybX9rzvRtmqpSgzHXkEC0B71clbPIGmSWD6OY5hRO02pwQdtalmrbPuTozOfoKAoLfwgCUiKAoLGNe1cZtIkQyHwy58JvuQiEjpvtw16ed0zwJSWyfpo6T9AHLGurqgw4oDun4yPnsibPBkrVGmqCsdR4XrVfoKAoLfMmqCbrbjtOf2Jeji)0CklmdzQogi9OWHeKUPe9hfEG4egpk8aXpkScsMWJMKJsuWuSqWrvhrD0ncxt9gUY4rjZrt9OocYrJJ6iz5abh9dKdivtw16edyqTgzHXkEC0B71clbPIGmSWpix3MhxtLsHCaydGHupA)JsgiUG4ia(JU7r38r7F0)aKXJJTc3Rc1eikvi9hDNJ29gSWHuZPSWECn1B4Qf2Jeji)0Cklm8hw(JUr4AQuEudyai5OUd4OWde)OWocGNCuOst(rnYeik9OYz4(H56Oj5Os(qWJQZrby4nzvRtmadZAKfgR4XrVTxlSeKkcYWc)GCDBECnvkfYbGnags9O9pkzG4cIJa4p6UhDZhT)r)dqgpo2kCVkutGOuH0F0DpQHDBHdPMtzH94AQ3WvlShjsq(P5uw4nccKfRJAKjqu6rjOc9X4rjFy5p6gHRPs5rnGbGKJ6oGJcpq8Jc7iaEIvToXaBCRrwySIhh92ETWsqQiidl8dY1T5X1uPuiha2ayi1J2)OKbIliocG)O7E0nF0(h1SJ(GCDBECnvkfYbGnIgsMo6ohT7J6SZhvdowAJesq6Ms0lideN0WkEC0FuJTWHuZPSWECn1B4QvToT5nynYcJv84O32RfwcsfbzyHjOkEtbrAAIGUzyIU)KhT)rjdexqCea)r39OB(O9pQzh1SJ2zhDthLmqCbXra8h14JYWpAi1CQgXr4hMfVHRnCpkHuuO5cp6oh9d1MhGHNObNje0a4kYIC0nD0qQ5unhr5fJRGfe3hvd3JsiffAUWJUPJgsnNQ5X1uVHRnCpkHuuO5cpQXhT)rFqUUnpUMkLc5aWgrdjthDh2h1qlCi1CklShxt9gUAvRtB2qRrwySIhh92ETWsqQiidl8dY1T5X1uPuiha2ayi1J2)OKbIliocG)O7E0nF0(hnKA(JcSWvIKJUZrn0chsnNYc7X1uVHRw160M72AKfoKAoLfMmqCbrbjtOfgR4XrVTxRADAZmG1ilmwXJJEBVw4qQ5uwyzW5IqQ5ucEsulmpjQOIfAHLZpwrPI4L8unzvRtBEZwJSWyfpo6T9AHLGurqgwyYaXfehbWF0DyFug4O9p6FaY4XXwH7vHAceLkK(JUZr7UhhT)rn7OAWXsBECnvkfYGZZIvdR4Xr)rD25JkNH7hMRMm4CHhGHNObNjeqAaCfzro6oh1SJA2r7Xr30rjdexqCea)rn(Om8JgsnNQrCe(HzXB4Ad3JsiffAUWJA8rn)OHuZPAoIYlgxbliUpQgUhLqkk0CHh1ylCi1CklSJO8IXvWcI7JYc7rIeKFAoLfEJ5Eutd0rLrDuwOE0xiz6O6C0ECu4bIFuyhbWto6dDhaE0ncGHNObNjeqoQCgUFyUoAsokadVjgpAQDqo6Wuy6O6CuYhw(JQoW1rRHzRADAZ9WAKfgR4XrVTxlSeKkcYWcdqxasCepoE0(hvZfE0DoQBciQqnbIsfAUqlCi1CklSFMLfwAsYrHgawOsSozOvToT5oZAKfgR4XrVTxlSeKkcYWc)GCDBECnvkfYbGnags9O9p6dY1T5X1uPuiha2a4kYIC0DpQHh18JYs6BRy)rz4h9b56284AQukKdaBenKmzHdPMtzH94AQ3WvlShjsq(P5uwydIi4r3iCn1B46rt3JAAG6aGhL1KfRJQZr5dbp6gHRPs5rnGbGhLOHKjcJhf)X6OP7rtTd)rzoikE04OKbIFuIJa4Bw160MnOwJSWHuZPSWehHFyw8gUAHXkEC0B71Qw1c)bq5SEHAnY6KHwJSWyfpo6T9AHLGurqgwynx4r35OB4O9pANo6hQTGN)OfoKAoLf2f5c)SYk0CklShjsq(P5uwygQ9Oesr)rFO7aWJkN1l0J(qwzrAhLHwkXpLC0AQn5ialxi(rdPMtro6uCtnRADQBRrw4qQ5uwyc0AnLWf5SGcG3cJv84O32RvToXawJSWyfpo6T9AHRyHwyDwOyCfRPikyGic5uefaj1CkIfoKAoLfwNfkgxXAkIcgiIqofrbqsnNIyvRtB2AKfgR4XrVTxlCfl0ctgogoicckbOkuu6Osgci0chsnNYctgogoicckbOkuu6Osgci0QwN6H1ilCi1CklSlhjoKGWvTWyfpo6T9AvRtDM1ilmwXJJEBVwyjiveKHf(b562yo5ErU(inIgsMo6oh1WJ2)Opix3MhxtLsHCayJOHKPJUl7J2TfoKAoLf(Bygbcs(5ykRADYGAnYcJv84O32RfUIfAHjoc)Wm6fd4jgxHoGfwQfoKAoLfM4i8dZOxmGNyCf6awyPw16edZAKfgR4XrVTxlSeKkcYWcB2rFdHCuND(OHuZPAECn1B4Atge9OSp6goQXhT)rjdexqCeap5O7E0nBHdPMtzH94AQ3WvRADAJBnYcJv84O32RfwcsfbzyH70rn7OVHqoQZoF0qQ5unpUM6nCTjdIEu2hDdh14J6SZhLmqCbXra8KJUZrzalCi1CklmXr4hMfVHRw16KHBWAKfgR4XrVTxl88zHjOAHdPMtzH)dqgpoAH)doeAHbqf6oawy7fCK8LEeqepiqLflHCaydR4Xr)r7FuauHUdGf2iocGxmUIOQ0rYdnNQHv84O3c)harfl0cdrqXB4QqZvwSiw1QwyfKftOsSgzDYqRrwySIhh92ETWvSqlmXr4hMrVyapX4k0bSWsTWHuZPSWehHFyg9Ib8eJRqhWcl1clbPIGmSW)biJhhBpixxbXujfs)r39OD3TvTo1T1ilmwXJJEBVw4kwOfMidarmUcxqOiOcUGOG0fTWHuZPSWezaiIXv4ccfbvWfefKUOvToXawJSWyfpo6T9AHdPMtzHLbNlcPMtj4jrTWsqQiidlSgCS0MhxtLsHCkc06tZPAyfpo6pA)J(hGmECSv4EvOMarPcP)O7E0U3GfMNevuXcTWo(ekilMiw160MTgzHXkEC0B71chsnNYcldoxesnNsWtIAH9ircYpnNYcZq56IsLCu1rOhvbXpYpkHpmZnDuDoQgawOEuaYqaLa8OH3NAovWz8Oe8laHIh1ruEEwSSW8KOIkwOfMWhMfkilMqLyvRt9WAKfgR4XrVTxlCfl0cp)iWLpmNflru5keYGfAHdPMtzHNFe4YhMZILiQCfczWcTWsqQiidlSzhTth9paz84ydIGI3WvHMRSyroA)J(HAZJRPsPqnbIsBHuZF8OgFuND(OMD0)aKXJJnickEdxfAUYIf5O9p6dY1TrCeaVyCfrvPJKhAovd67OgBvRtDM1ilmwXJJEBVwyjiveKHfwbzXeQn1WMJGiGiO4b56E0(h1SJA2r70r)dqgpo2GiO4nCvO5klwKJ2)OFO284AQukutGO0wi18hpQXh1zNpQzh9paz84ydIGI3WvHMRSyroA)J(GCDBehbWlgxruv6i5HMt1G(oQXh1ylCi1CklScYIjun0ct4JAHvqwmHQHw16Kb1AKfgR4XrVTxlSeKkcYWcRGSyc1M2DZrqeqeu8GCDpA)JA2rn7OD6O)biJhhBqeu8gUk0CLflYr7F0puBECnvkfQjquAlKA(Jh14J6SZh1SJ(hGmECSbrqXB4QqZvwSihT)rFqUUnIJa4fJRiQkDK8qZPAqFh14JASfoKAoLfwbzXeQDBHj8rTWkilMqTBRADIHznYcJv84O32RfoKAoLfwgCUiKAoLGNe1clbPIGmSWAUWJUZrDtarfQjquQqZfE0(h9paz84y7b56kiMkPq6p6ohT7nyH5jrfvSql8heaf(yfSqHcYIjIvTQf(dcGcFScwOqbzXeXAK1jdTgzHXkEC0B71cxXcTWEagE3eGIFKqqUfoKAoLf2dWW7Mau8JecYTQ1PUTgzHXkEC0B71cxXcTWSa5sGsE(rqlCi1CklmlqUeOKNFe0QwNyaRrwySIhh92ETWvSqlmajtfLkaibb)tcSWHuZPSWaKmvuQaGee8pjWQwN2S1ilmwXJJEBVw4kwOfoashPIsLiYIfwqPAsihaAHdPMtzHdG0rQOujISyHfuQMeYbGw16upSgzHXkEC0B71cxXcTWYHSsPGfp8zOdGiaizQqhGfoKAoLfwoKvkfS4HpdDaebajtf6aSQ1PoZAKfgR4XrVTxlCfl0c7by4Dtak(rcb5w4qQ5uwypadVBcqXpsii3QwNmOwJSWyfpo6T9AHRyHwyYaXfjRkveyHdPMtzHjdexKSQurGvToXWSgzHXkEC0B71cxXcTWS4M(Cigxrqi5k5HMtzHdPMtzHzXn95qmUIGqYvYdnNYclbPIGmSWHuZFuGfUsKCu2h1qRADAJBnYcJv84O32RfUIfAH9bGP1mLWJsMeFqkajsSKOfoKAoLf2haMwZucpkzs8bPaKiXsIw16KHBWAKfgR4XrVTxlCfl0cJVPidex8Ne0chsnNYcJVPidex8Ne0QwNm0qRrwySIhh92ETWvSqlmujDezHEblE4ZqharqCesM4iXchsnNYcdvshrwOxWIh(m0bqeehHKjosSQvTWdlP3AK1jdTgzHdPMtzHFiGGaMYILfgR4XrVTxRADQBRrw4qQ5uw4hFgVWfcyYcJv84O32RvToXawJSWHuZPSWUjaF8z8wySIhh92ETQ1PnBnYchsnNYcdrqrQ4IyHXkEC0B71Qw1Qw4FeqYPSo19g6U7n0D3gAHzoavwSiwygsg6ohN2yo15YGh9Og5apAU(gGEu3bC0oMpSqqhhfGmeqja9hLml8ObKoRqr)rLoIIfsA3wdol8OgYGh1aM6hbk6pAhKbI)YY36zhhvNJ2bzG4VS8TE2WkEC03Xrd9OmuD(g8rnZW9g3UT3wgsg6ohN2yo15YGh9Og5apAU(gGEu3bC0oKZpwrPI4L8un1Xrbidbucq)rjZcpAaPZku0FuPJOyHK2T1GZcpQHm4rnGP(rGI(J2bzG4VS8TE2Xr15ODqgi(llFRNnSIhh9DCuZmCVXTBRbNfE0UzWJAat9Jaf9hTdYaXFz5B9SJJQZr7Gmq8xw(wpByfpo674OMz4EJB3wdol8OmadEudyQFeOO)ODqgi(llFRNDCuDoAhKbI)YY36zdR4XrFhh1md3BC72AWzHhDZm4r7CW18J(JUYIb75rLoqjth1SA0Jg)rYJhhpAwhfxq8qZPm(OMz4EJB3wdol8OBMbpQbm1pcu0F0oide)LLV1ZooQohTdYaXFz5B9SHv84OVJJAMH7nUDBn4SWJ2dg8ODo4A(r)rxzXG98OshOKPJAwn6rJ)i5XJJhnRJIliEO5ugFuZmCVXTBRbNfE0EWGh1aM6hbk6pAhKbI)YY36zhhvNJ2bzG4VS8TE2WkEC03XrnZW9g3UTgCw4r7mg8OgWu)iqr)r7Gmq8xw(wp74O6C0oide)LLV1ZgwXJJ(ooQzmWEJB3wdol8Ogug8OgWu)iqr)r7qdowARNDCuDoAhAWXsB9SHv84OVJJAMH7nUDBn4SWJYWyWJAat9Jaf9hTdYaXFz5B9SJJQZr7Gmq8xw(wpByfpo674OMz4EJB3wdol8OBCg8OgWu)iqr)r7Gmq8xw(wp74O6C0oide)LLV1ZgwXJJ(ooQzgU342T1GZcpQHBGbpQbm1pcu0F0oide)LLV1ZooQohTdYaXFz5B9SHv84OVJJg6rzO68n4JAMH7nUDBVTmKm0DooTXCQZLbp6rnYbE0C9na9OUd4ODOMarPccQqFDCuaYqaLa0FuYSWJgq6Scf9hv6ikwiPDBn4SWJYam4rnGP(rGI(J2baQq3bWcB9SJJQZr7aavO7ayHTE2WkEC03XrnZW9g3UT3wgsg6ohN2yo15YGh9Og5apAU(gGEu3bC0o8OBaX1ookaziGsa6pkzw4rdiDwHI(JkDeflK0UTgCw4r7bdEudyQFeOO)ODqgi(llFRNDCuDoAhKbI)YY36zdR4XrFhh1md3BC72AWzHhTZyWJAat9Jaf9hTdYaXFz5B9SJJQZr7Gmq8xw(wpByfpo674OMz4EJB3wdol8OgUzg8OgWu)iqr)r7Gmq8xw(wp74O6C0oide)LLV1ZgwXJJ(ooQzmWEJB3wdol8Og2zm4rnGP(rGI(J2bzG4VS8TE2Xr15ODqgi(llFRNnSIhh9DCuZmCVXTBRbNfEudzym4rnGP(rGI(J2baQq3bWcB9SJJQZr7aavO7ayHTE2WkEC03XrnZW9g3UTgCw4r7Edm4rnGP(rGI(J2baQq3bWcB9SJJQZr7aavO7ayHTE2WkEC03XrnZW9g3UTgCw4r7EZm4rnGP(rGI(J2baQq3bWcB9SJJQZr7aavO7ayHTE2WkEC03XrnZW9g3UTgCw4r7Uhm4rnGP(rGI(J2baQq3bWcB9SJJQZr7aavO7ayHTE2WkEC03Xrd9OmuD(g8rnZW9g3UTgCw4r7UZyWJAat9Jaf9hTdauHUdGf26zhhvNJ2baQq3bWcB9SHv84OVJJAMH7nUDBn4SWJYagYGh1aM6hbk6pAhaOcDhalS1ZooQohTdauHUdGf26zdR4XrFhh1md3BC72EBzizO7CCAJ5uNldE0JAKd8O56Ba6rDhWr74dGYz9cTJJcqgcOeG(JsMfE0asNvOO)OshrXcjTBRbNfEud3adEudyQFeOO)ODaGk0DaSWwp74O6C0oaqf6oawyRNnSIhh9DC0qpkdvNVbFuZmCVXTBRbNfEud3adEudyQFeOO)ODaGk0DaSWwp74O6C0oaqf6oawyRNnSIhh9DCuZmCVXTB7TLHKHUZXPnMtDUm4rpQroWJMRVbOh1DahTdfKftOs64OaKHakbO)OKzHhnG0zfk6pQ0ruSqs72AWzHhTZyWJAat9Jaf9hTdfKftO2mS1ZooQohTdfKftO2udB9SJJAMH7nUDBn4SWJAqzWJAat9Jaf9hTdfKftO26U1ZooQohTdfKftO20UB9SJJAMH7nUDBVTBS13au0F0n(rdPMtDuEsus72AH)aJBYrlSbAGhDJW1udFyz6OmKbGpsMUTgObEuhQ(ryWU6IvQoGEn5S6IKliEO5usq4QDrYLSRBRbAGh1Ge(aqbW0r7UhmE0U3q3DFBVTgObEudWruSqcdEBnqd8OB6OWFiNFudEKm1UTgObE0nD0o)IB6OauoRfw(JUr4AQ3W1J(bWnjN1l0JMUhn1JMKJMfrJspQzd4OocGxge9OUd4OVHqqIXTBRbAGhDthTZBygbhfo)Cm1rdoFyg9h9dGBsoRxOhvNJ(bg5rZIOrPhDJW1uVHRTBRbAGhDthTZ7VZ7OAWXspAwkcaqFA72AGg4r30rzO)N0Fu4E30ogepDUhL8fRJYSdSoQPbQdaE0A0JgVbspQohLaTwtD04OgzceL2UTgObE0nDudsCK4qccxTldchEOjhpk8W)XspQmkjYfP7rLoIIf6pQohnlfbaOpvKUTBRbAGhDth1iGPJQZrJ)j9hL5GOzX6OBeUMkLh1agaEuIgsMiTBRbAGhDth1iGPJQZrxbt4rNpSqWr)a5as10rNIB6OmpaMoA6EuMXJkJ6OHuHco30rNpSokZP64OXrnYeikTDBVTg4rzO2Jsif9h9HUdapQCwVqp6dzLfPDugAPe)uYrRP2KJaSCH4hnKAof5OtXn1UTHuZPiTpakN1luZz3LlYf(zLvO5umMUS1CH7SH(D6d1wWZF82gsnNI0(aOCwVqnNDxeO1AkXhQ32qQ5uK2haLZ6fQ5S7cIGIuXfJvSq26SqX4kwtruWareYPikasQ5uKBBi1Cks7dGYz9c1C2DbrqrQ4IXkwiBYWXWbrqqjavHIshvYqaH32qQ5uK2haLZ6fQ5S7YLJehsq4Q32qQ5uK2haLZ6fQ5S76Bygbcs(5ykgtx2pix3gZj3lY1hPr0qY0og2)b56284AQukKdaBenKmTl7UVTHuZPiTpakN1luZz3febfPIlgRyHSjoc)Wm6fd4jgxHoGfw6TnKAofP9bq5SEHAo7U84AQ3Wvgtx2M9gcXzNdPMt184AQ3W1Mmik7nyCFYaXfehbWt2DZ32qQ5uK2haLZ6fQ5S7I4i8dZI3Wvgtx2DYS3qio7Ci1CQMhxt9gU2KbrzVbJD2zYaXfehbWt2HbUTgObE0qQ5uK2haLZ6fQ5S76paz84iJvSq2UjGOc1eikvO5czC(ytqLX)GdHSnCd32qQ5uK2haLZ6fQ5S76paz84iJvSq2qeu8gUk0CLflcJZhBcQm(hCiKnaQq3bWcBVGJKV0JaI4bbQSyjKda7dGk0DaSWgXra8IXvevLosEO5u32B7T1apkd1EucPO)O4pcmDunx4rvh4rdPoGJMKJg)rYJhhB32qQ5ue2KpKZf8rY0TnKAofXC2Djdox4IChqLIGBBi1CkI5S7k2JcDiKBBi1CkI5S7YJ)deqScwP82gsnNIW(paz84iJvSq2fUxfQjquQq6zC(ytqLX)GdHSLZW9dZvJaTwtj84AQukutGO0gaxrwebU)dLk6zmDz3jYaXFz5BUjY9IXv84dHmlIZolNH7hMRgbATMs4X1uPuOMarPnaUISicC)hkv0VJCgUFyUAKbIlaJ2a4kYIiW9FOur)TnKAofXC2D9hGmECKXkwi7c3Rc1eikvi9moFSjOY4FWHq2Yz4(H5QrgiUamAdGRilIa3)Hsf9mMUSjde)LLV5Mi3lgxXJpeYSi9LZW9dZvJaTwtj84AQukutGO0gaxrwebU)dLk63vod3pmxnYaXfGrBaCfzre4(puQO)2gsnNIyo7U(dqgpoYyflKDH7vHAceLkKEgNp2euz8p4qiB3equHAceLk0CHBsZfYy6YwZfURBciQqnbIsfAUWBBi1CkI5S76paz84iJvSq2pixxbXujfspJZhBcQm(hCiK9FaY4XXwH7vHAceLkKEgtx2D6paz84ydIGI3WvHMRSyrUTHuZPiMZUR)aKXJJmwXcz)GCDfetLui9moFSjOY4FWHq2Yz4(H5Q5rzUcnlwI3W1gaxrwebU)dLk6zmDz)hGmECSbrqXB4QqZvwSi32qQ5ueZz3Lm4Cri1CkbpjkJvSq2kilMqLCBdPMtrmNDxYGZfHuZPe8KOmwXczpSKEgtx2M1P)aKXJJnickEdxfAUYIfP)hQnpUMkLc1eikTfsn)rJD2zZ(dqgpo2GiO4nCvO5klwK(pix3gXra8IXvevLosEO5unOV(M1jn4yPTVHzeii5NJPAyfpo6D25hKRB7Bygbcs(5yQg0NXgFBdPMtrmNDxYGZfHuZPe8KOmwXczpFyHagjkiLkBdzmDzRdlwCSjNH7hMlsFnx4UUjGOc1eikvO5cVTHuZPiMZUl)mlgtx2a0fGehXJJ32qQ5ueZz3Lm4Cri1CkbpjkJvSq2Y5hROur8sEQMyKOGuQSnKX0LnzG4VS8nwG5hfz9NSgqO5uo7mzG4VS8n3e5EX4kE8HqMfXzNjde)LLVjN1luXc9PgAoLZolNFSIsBfkbdFa(BBi1CkI5S76Bygbcs(5ykgtx2)biJhhBqeu8gUk0CLfls)hKRBJ4iaEX4kIQshjp0CQg03TnKAofXC2D9nAofJPlBZ60FaY4XXgebfVHRcnxzXI0)paz84yRW9QqnbIsfs)USK(2k23xZfUJBciQqnbIsfAUqNDMmq8xw(gaDZc9IVGhk2)paz84yRW9QqnbIsfs)UmadZyND2S)aKXJJnickEdxfAUYIfP)dY1TrCeaVyCfrvPJKhAovd6Z4BBi1CkI5S7sgCUiKAoLGNeLXkwiB1eikvqqf672gsnNIyo7U84AQukikalwQdgtx2M1jauHUdGf2yo5Ua0teKKvYfJRGa9HGCacc0AnvwS6)hGmECSv4EvOMarPcPFNnUXo7SzFO284AQukutGO0wi18h7)HAZJRPsPqnbIsBaCfzr2TZy4SK(2k2B8TnKAofXC2Djdox4by4jAWzcbegtx2)biJhhBqeu8gUk0CLflsF5mC)WC1iqR1ucpUMkLc1eikTbWvKfrG7)qPI(D6U7BBi1CkI5S7sgCUWdWWt0GZecimMUS70FaY4XXgebfVHRcnxzXI03S)aKXJJTc3Rc1eikvi9709g2upy4DcavO7ayHnMtUla9ebjzLCX4kiqFiihGGaTwtLflJVTHuZPiMZURVHzeii5NJPymDz3P)aKXJJnickEdxfAUYIfP)dY1TXCY9IC9rAenKmTJH9FqUUnpUMkLc5aWgrdjt7Ya32qQ5ueZz31l5iroqawO4nRhcimMUSFqUUn1eikT5hMR()biJhhBfUxfQjquQq63Ph32qQ5ueZz3vU(4djNIX0LDi18hfyHRej7yO5MzidxdowAJesq6Ms0lideN0WkEC0BC)hKRBJ5K7f56J0iAizAh2Dw)hKRBtnbIsB(H5Q)FaY4XXwH7vHAceLkK(D6XTnKAofXC2DLRp(qYPymDzhsn)rbw4krYoD3)b562yo5ErU(inIgsM2HDN1)b562utGO0MFyU6)hGmECSv4EvOMarPcPFNE0VtaOcDhalSLRp(qYFu8nkwAg8(M1jn4yPnxWSeQduqCe(HzsdR4XrVZo7XhKRBZfmlH6afehHFyM0G(m(2gsnNIyo7UY1hFi5umMUSdPM)OalCLizNU7)GCDBmNCVixFKgrdjt7WUZ6)GCDB56JpK8hfFJILMbVbWvKfz3U7dGk0DaSWwU(4dj)rX3OyPzWVTHuZPiMZURC9XhsofJPl7hKRBJ5K7f56J0iAizAh2g2DFn4yPnYaXfYP8qP2WkEC03xdowAZfmlH6afehHFyM0WkEC03havO7ayHTC9Xhs(JIVrXsZG3)b562utGO0MFyU6)hGmECSv4EvOMarPcPFNECBdPMtrmNDxSa5AsakCrolOa4zmDz)gcPVMluOJWN4UmWgUTHuZPiMZUlc0AnL4p5OBILNX0L9BiK(AUqHocFI72nd72gsnNIyo7UiqR1ucpUMkLc1eikLX0L9BiK(AUqHocFI7AypUTHuZPiMZUlhr5fJRGfe3hfJPlBYaXfehbWZUh32qQ5ueZz3fXr4hMfVHRmMUSjdexqCea)U9OpaQq3bWcBVGJKV0JaI4bbQSyjKda7)GCDBVGJKV0JaI4bbQSyjKdaBaCfzr2Th3wd8OBm3JUram8en4mHaYrdaE0GdWWB6OHuZFKXJwZrle9hvNJsIF8OehbWtUTHuZPiMZUlhr5fJRGfe3hfJPlBYaXfehbWVdBgOVzFO28am8en4mHGwi18hD25puBECnvkfQjquAlKA(JgFBdPMtrmNDxoIYlgxbliUpkgtx2KbIliocGFh2g2)b562kuDGaX3a0G3G(6lNH7hMRMm4CHhGHNObNjeqAaCfzr2PBgolPVTI932qQ5ueZz3LJO8IXvWcI7JIX0LnzG4cIJa43HTH9)dqgpo2kCVkutGOuH0VllPVTI991CH74MaIkutGOuHMlCtSK(2k2FBdPMtrmNDxYGZfHuZPe8KOmwXczlNFSIsfXl5PAIrIcsPY2qgtx2Dso)yfL2(XsDycCBnWJYqMQJbspkCibPBkr)rHhioHXJcpq8JcRGKj8Oj5OefmfleCu1ruhDJW1uVHRmEuYC0upQJGC04OoswoqWr)a5as10TnKAofXC2DrgiUGOGKjKX0LDN0GJL2iHeKUPe9cYaXjnSIhh93wd8OWFy5p6gHRPs5rnGbGKJ6oGJcpq8Jc7iaEYrHkn5h1itGO0JkNH7hMRJMKJk5dbpQohfGH30TnKAofXC2D5X1uVHRmMUSFqUUnpUMkLc5aWgadP2NmqCbXra87U5()biJhhBfUxfQjquQq63P7nCBnWJUrqGSyDuJmbIspkbvOpgpk5dl)r3iCnvkpQbmaKCu3bCu4bIFuyhbWtUTHuZPiMZUlpUM6nCLX0L9dY1T5X1uPuiha2ayi1(KbIliocGF3n3)paz84yRW9QqnbIsfs)Ug29TnKAofXC2D5X1uVHRmMUSFqUUnpUMkLc5aWgadP2NmqCbXra87U5(M9GCDBECnvkfYbGnIgsM2PBNDwdowAJesq6Ms0lideN0WkEC0B8TnKAofXC2D5X1uVHRmMUSjOkEtbrAAIGUzyIU)K9jdexqCea)UBUVzM1zBImqCbXra8gZWdPMt1ioc)WS4nCTH7rjKIcnx4oFO28am8en4mHGgaxrwKnfsnNQ5ikVyCfSG4(OA4EucPOqZfUPqQ5unpUM6nCTH7rjKIcnxOX9FqUUnpUMkLc5aWgrdjt7W2WBBi1CkI5S7YJRPEdxzmDz)GCDBECnvkfYbGnagsTpzG4cIJa43DZ9dPM)OalCLizhdVTHuZPiMZUlYaXfefKmH32qQ5ueZz3Lm4Cri1CkbpjkJvSq2Y5hROur8sEQMUTg4r3yUh10aDuzuhLfQh9fsMoQohThhfEG4hf2ra8KJ(q3bGhDJay4jAWzcbKJkNH7hMRJMKJcWWBIXJMAhKJomfMoQohL8HL)OQdCD0Ay(2gsnNIyo7UCeLxmUcwqCFumMUSjdexqCea)oSzG()biJhhBfUxfQjquQq63P7E03mn4yPnpUMkLczW5zXQHv84O3zNLZW9dZvtgCUWdWWt0GZecinaUISi7yMz9ytKbIliocG3ygEi1CQgXr4hMfVHRnCpkHuuO5cn28qQ5unhr5fJRGfe3hvd3JsiffAUqJVTHuZPiMZUl)mlgLMKCuObGfQe2gYy6YgGUaK4iECSVMlCh3equHAceLk0CH3wd8OgerWJUr4AQ3W1JMUh10a1bapkRjlwhvNJYhcE0ncxtLYJAadapkrdjtegpk(J1rt3JMAh(JYCqu8OXrjde)OehbW3UTHuZPiMZUlpUM6nCLX0L9dY1T5X1uPuiha2ayi1(pix3MhxtLsHCaydGRilYUgAolPVTI9m8hKRBZJRPsPqoaSr0qY0TnKAofXC2DrCe(HzXB46T92A(rdPMtrAe(WSqbzXeQe2qeuKkUySIfYMmqCoQAwSeaONjgLMKCuObGfQe2gYy6Y(paz84y7b56kiMkPq63vdaluB(KOrjrdc6XMmRBgolPVTI9m8)aKXJJnickEdxfAUYIfX4BR5hnKAofPr4dZcfKftOsmNDxqeuKkUySIfYMavp(mErSq1HjIYy6Y(paz84y7b56kiMkPq63vdaluB(KOrjrdc6H5M1nd)paz84ydIGI3WvHMRSyrm(2A(rdPMtrAe(WSqbzXeQeZz3febfPIlgRyHSX1NjagCXa8vusKX0L9FaY4XX2dY1vqmvsH0VRzAayHAZNenkjAqqpm2Cd72CZ6MH)hGmECSbrqXB4QqZvwSigFBVTHuZPin58JvuQiEjpvtSjdexagLX0LnzG4VS8nwG5hfz9NSgqO5u9n7paz84yRW9QqnbIsfs)UDVbND(paz84yRW9QqnbIsfs)omWgm(2gsnNI0KZpwrPI4L8unzo7UidexagLX0LnzG4VS8n3e5EX4kE8HqMfP)hQnpUMkLc1eikTfsn)XBBi1Cksto)yfLkIxYt1K5S7ImqCbyugtx2KbI)YY3yo5EHdOsfAi1us63PpuBECnvkfQjquAlKA(J9)dqgpo2kCVkutGOuH0VJHmSBBi1Cksto)yfLkIxYt1K5S7YJYCfAwSeVHRmknj5OqdalujSnKX0L9klgudaluBoWGRoAFsLX0LDN(dqgpo2GiO4nCvO5klwK(KbI)YY34y4fptcCFS(4yFZ(qT5X1uPuOMarPTqQ5p2NmqCbXra872TZo3PpuBECnvkfQjquAlKA(J9)dqgpo2kCVkutGOuH0VZM3GX32qQ5uKMC(XkkveVKNQjZz3LhL5k0SyjEdxzuAsYrHgawOsyBiJPl7vwmOgawO2CGbxD0(KkJPl7o9hGmECSbrqXB4QqZvwSi9jde)LLVXe(NfrmJbzKNfR(M9HAZJRPsPqnbIsBHuZF0zN70hQnpUMkLc1eikTfsn)X()biJhhBfUxfQjquQq63zZBW4BBi1Cksto)yfLkIxYt1K5S7YJYCfAwSeVHRmknj5OqdalujSnKX0LDN(dqgpo2GiO4nCvO5klwK(Mrgi(llFZDaSW3akuaWFeKiXzNnJmq8xw(2)Wdn5OGm8FS0(DImq8xw(gt4FweXmgKrEwSm24(D6d1MhxtLsHAceL2cPM)4TnKAofPjNFSIsfXl5PAYC2D5rzUcnlwI3WvgLMKCuObGfQe2gYy6Y(paz84ydIGI3WvHMRSyr6BwN0GJL2(gMrGGKFoMYzNLZW9dZv7Bygbcs(5yQgaxrwKDdPMt18OmxHMflXB4Ad3JsiffAUqJ73j5mC)WC1iqR1ucpUMkLc1eikTb913SpuBECnvkfQjquAdGRilYUmmNDwod3pmxnc0AnLWJRPsPqnbIsBaCfzre4(puQOFxgydgFBdPMtrAY5hROur8sEQMmNDxUCK4qccxLX0LnzG4VS8T)HhAYrbz4)yP9FqUUT)HhAYrbz4)yPn)WCXywkcaqFQiDz)GCDB)dp0KJcYW)XsBqF32qQ5uKMC(XkkveVKNQjZz3froqGSyj0uDGmMUSjde)LLVjN1luXc9PgAov)puBECnvkfQjquAlKA(J32qQ5uKMC(XkkveVKNQjZz3froqGSyj0uDGmMUS7ezG4VS8n5SEHkwOp1qZPUTHuZPin58JvuQiEjpvtMZURC9HLplwczObrbZNdKX0L9hQnpUMkLc1eikTfsn)X(KbIliocGN9gUT32qQ5uKMJpHcYIjcBicksfxmwXcztYYfIlyXdFg6aicC94462gsnNI0C8juqwmrmNDxqeuKkUySIfYMKLlexeKVeeLse46XX1T92gsnNI0gwsp7hciiGPSyDBdPMtrAdlP3C2D94Z4fUqat32qQ5uK2Ws6nNDxUjaF8z832qQ5uK2Ws6nNDxqeuKkUi32BBi1CksB(WcbSjdexagLX0LnzG4VS8nwG5hfz9NSgqO5u32qQ5uK28HfcmNDxfQoqG4BaAWVTHuZPiT5dleyo7UybY1Kau4ICwqbWFBdPMtrAZhwiWC2DrGwRPe)jhDtS832qQ5uK28HfcmNDxehHFyw8gUYy6YMmqCbXra872J(Yz4(H5Qjdox4by4jAWzcbKg03TnKAofPnFyHaZz3fXr4hMfVHRmMUS)dqgpo2GiO4nCvO5klwK(KbIliocGF3E0)b562EbhjFPhbeXdcuzXsiha2iAizA3nFBdPMtrAZhwiWC2Djdox4by4jAWzcbKB7TnKAofP9bbqHpwbluOGSyIWgIGIuXfJvSq2EagE3eGIFKqq(TnKAofP9bbqHpwbluOGSyIyo7UGiOivCXyflKnlqUeOKNFe82gsnNI0(GaOWhRGfkuqwmrmNDxqeuKkUySIfYgGKPIsfaKGG)jb32qQ5uK2heaf(yfSqHcYIjI5S7cIGIuXfJvSq2bq6ivuQerwSWckvtc5aWBBi1Cks7dcGcFScwOqbzXeXC2DbrqrQ4IXkwiB5qwPuWIh(m0bqeaKmvOd42gsnNI0(GaOWhRGfkuqwmrmNDxqeuKkUySIfY2dWW7Mau8JecYVTHuZPiTpiak8XkyHcfKfteZz3febfPIlgRyHSjdexKSQurWTnKAofP9bbqHpwbluOGSyIyo7UGiOivCXyflKnlUPphIXveesUsEO5umMUSdPM)OalCLiHTH32qQ5uK2heaf(yfSqHcYIjI5S7cIGIuXfJvSq2(aW0AMs4rjtIpifGejws82gsnNI0(GaOWhRGfkuqwmrmNDxqeuKkUySIfYgFtrgiU4pj4TnKAofP9bbqHpwbluOGSyIyo7UGiOivCXyflKnujDezHEblE4ZqharqCesM4i52EBdPMtrAkilMqLWgIGIuXfJvSq2ehHFyg9Ib8eJRqhWclLX0L9FaY4XX2dY1vqmvsH0VB3DFBdPMtrAkilMqLyo7UGiOivCXyflKnrgaIyCfUGqrqfCbrbPlEBdPMtrAkilMqLyo7UKbNlcPMtj4jrzSIfY2XNqbzXeHX0LTgCS0MhxtLsHCkc06tZPAyfpo67)hGmECSv4EvOMarPcPF3U3WT1apkdLRlkvYrvhHEufe)i)Oe(Wm30r15OAayH6rbidbucWJgEFQ5ubNXJsWVaekEuhr55zX62gsnNI0uqwmHkXC2DjdoxesnNsWtIYyflKnHpmluqwmHk52gsnNI0uqwmHkXC2DbrqrQ4IXkwi75hbU8H5SyjIkxHqgSqgtx2M1P)aKXJJnickEdxfAUYIfP)hQnpUMkLc1eikTfsn)rJD2zZ(dqgpo2GiO4nCvO5klwK(pix3gXra8IXvevLosEO5unOpJVTHuZPinfKftOsmNDxqeuKkUyKWhLTcYIjunKX0LTcYIjuBg2Ceebebfpix3(MzwN(dqgpo2GiO4nCvO5klwK(FO284AQukutGO0wi18hn2zNn7paz84ydIGI3WvHMRSyr6)GCDBehbWlgxruv6i5HMt1G(m24BBi1CkstbzXeQeZz3febfPIlgj8rzRGSyc1UzmDzRGSyc1w3nhbrarqXdY1TVzM1P)aKXJJnickEdxfAUYIfP)hQnpUMkLc1eikTfsn)rJD2zZ(dqgpo2GiO4nCvO5klwK(pix3gXra8IXvevLosEO5unOpJn(2gsnNI0uqwmHkXC2DjdoxesnNsWtIYyflK9heaf(yfSqHcYIjcJPlBnx4oUjGOc1eikvO5c7)hGmECS9GCDfetLui9709gUT32qQ5uKMAceLkiOc9XUq1bceFdqdoJPl7)aKXJJTc3Rc1eikvi97AypUTHuZPin1eikvqqf6ZC2DXcKRjbOWf5SGcGNX0L9FaY4XXwH7vHAceLkK(Dn0GUjZcPMt1iqR1ucpUMkLc1eikTH7rjKIcnxO5HuZPAehHFyw8gU2W9OesrHMl04(MjNH7hMRMm4CHhGHNObNjeqAaCfzr21qd6MmlKAovJaTwtj84AQukutGO0gUhLqkk0CHMhsnNQrGwRPe)jhDtS8nCpkHuuO5cnpKAovJ4i8dZI3W1gUhLqkk0CHg7SZFO28am8en4mHGgaxrwKD(dqgpo2kCVkutGOuH0BEi1CQgbATMs4X1uPuOMarPnCpkHuuO5cn(2gsnNI0utGOubbvOpZz3fbATMs8NC0nXYZy6Y2S)aKXJJTc3Rc1eikvi97Ayp2KzHuZPAeO1AkHhxtLsHAceL2W9OesrHMl04(MjNH7hMRMm4CHhGHNObNjeqAaCfzr21WESjZcPMt1iqR1ucpUMkLc1eikTH7rjKIcnxO5HuZPAeO1AkXFYr3elFd3JsiffAUqJD25puBEagEIgCMqqdGRilYo)biJhhBfUxfQjquQq6npKAovJaTwtj84AQukutGO0gUhLqkk0CHgBSZoBwNaqf6oawyJ5K7cqprqswjxmUcc0hcYbiiqR1uzXQ)FaY4XXwH7vHAceLkK(D28gm(2gsnNI0utGOubbvOpZz3Lm4CHhGHNObNjeqymDz)hGmECSv4EvOMarPcPFxd7EtMfsnNQrGwRPeECnvkfQjquAd3JsiffAUqZdPMt1ioc)WS4nCTH7rjKIcnxOX32qQ5uKMAceLkiOc9zo7UiqR1ucpUMkLc1eikLX0LTMlCh3equHAceLk0CH9n7d1MhGHNObNje0cPM)y)puBEagEIgCMqqdGRilYoHuZPAeO1AkHhxtLsHAceL2W9OesrHMl04(M1jn4yPnc0AnL4p5OBILVHv84O3zN)qT9NC0nXY3cPM)OX9nJmqCbXra8S3GZoB2hQnpadprdotiOfsn)X(FO28am8en4mHGgaxrwKDdPMt1iqR1ucpUMkLc1eikTH7rjKIcnxO5HuZPAehHFyw8gU2W9OesrHMl0yND2SpuB)jhDtS8TqQ5p2)d12FYr3elFdGRilYUHuZPAeO1AkHhxtLsHAceL2W9OesrHMl08qQ5unIJWpmlEdxB4EucPOqZfASZoB2dY1TXcKRjbOWf5SGcGVb91)b562ybY1Kau4ICwqbW3a4kYISBi1CQgbATMs4X1uPuOMarPnCpkHuuO5cnpKAovJ4i8dZI3W1gUhLqkk0CHgBSfoGuhdWcBvRATa]] )


end
