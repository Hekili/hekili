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


    local first_combat_tyrant

    spec:RegisterStateExpr( "first_tyrant_time", function()
        if first_combat_tyrant then
            return first_combat_tyrant - state.combat
        end
        if cooldown.summon_demonic_tyrant.remains_expected > 0 then
            return min( 20, max( 10, time + cooldown.summon_demonic_tyrant.remains ) )
        end
        return 10
    end )

    spec:RegisterStateExpr( "in_opener", function()
        if time > 20 or time < first_tyrant_time - 10 or cooldown.summon_demonic_tyrant.remains_expected > 20 then return false end
        if time < first_tyrant_time then return true end
        return false
    end )


    local hog_time = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if source == state.GUID then
            local now = GetTime()

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

                elseif spellID == 265187 and InCombatLockdown() and not first_combat_tyrant then
                    first_combat_tyrant = now
                
                end
            end
        
        elseif imps[ source ] and subtype == "SPELL_CAST_START" then
            local demonic_power = GetPlayerAuraBySpellID( "player", 265273 )
            local now = GetTime()

            if not demonic_power then
                local imp = imps[ source ]

                imp.start = now
                imp.casts = imp.casts + 1

                imp.expires = min( imp.max, now + ( ( ( state.level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
            end
        end
    end )

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        first_combat_tyrant = nil
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

        first_tyrant_time = nil

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


    spec:RegisterPack( "Demonology", 20220227, [[d0ukccqikHEeLaxIsqHnjv6tsfnkkvDkQuwfLG8kkPMfk0Tuvr7sk)sQsdJsLogLKLjvXZuvjttvfUMsj2Muv03uvPmovvQoNuvO1HcY8qbUhk1(uk1brbvTqPQ6HuQWevkjxefuAJucQ8rPQaJKsqPoPsjvRuPyMuQODsLQFQusXqvkP0sLQc6PGAQuIUkLGs2kLGI(kkOYyLQs7LI)syWiDyHfRkpMOjtvxgAZuXNrjJMk50IEnkYSr1TvYUL8BfdxP64OGILd8CetN01bz7QkFhf14vv15PuwpLGQMVuH9RYgRmwAG9HIg37XU90JD7PNFRzx7(J(8x)UbwTTJg49qYuWcnWvSqd8wHRPg(WYMbEpSXNWBS0atgiGenWW5YomWpOKRB9Y8mW(qrJ79y3E6XU90ZV1SRD)rF(RFZat2rPX9E6Z(0a7k9ESmpdShjsd8wHRPg(WY2rz4caFKmDBCP6oHH6TxwP6c61KZQxsUG4HMtjbHJ2ljxYEVnw4Whaka2oAp9jJhTh72tp3MBJD4kkwiHHUn)8OW7iNFu7CKm1Un)8OBnf32rbOCwlS8hDRW1uVHRhDhG)uoRxOhnDoAQhnjhnlIgLEu7hWrDfaVmi6rDgWrFdHGe3A3MFE0T2HzeCu4C31uhn48Hz0F0Da(t5SEHEuDo6oyKhnlIgLE0Tcxt9gU2Un)8OBTFBThvdow6rZsraaAxB3MFEug(Vj9hfU)FUTf2tFWrj7X6Om7cRJABG6eGhTg9OXBG0JQZrjqR1uhnoQL2arPTBZppQfoosCjbHJ2RfMdp0KJhfE4FyPhvgLe5I05OsxrXc9hvNJMLIaa0UksN2T5Nh1sGTJQZrJVj9hL5GOzX6OBfUMkLh1ogaEuIgsMiTBZppQLaBhvNJUcMWJo7yHGJUdYbKQTJof32rzEamD005OmJhvg1rdPcfCUTJo7yDuMt11rJJAPnquAZaZtIsmwAGNDSqGXsJ7wzS0aJv84O30VbwcsfbzyGjde)LLVXcmFOiRVK1acnNQHv84O3ahsnNYatgiUamQrnU3JXsdCi1CkdCHQlei2hGgCdmwXJJEt)g14(VmwAGdPMtzGzbY1Kau4GCwqbWBGXkEC0B63Og3)HXsdCi1CkdmbATMs8LC0jXYBGXkEC0B63Og33IXsdmwXJJEt)gyjiveKHbMmqCbXva8hLbhDlhT7rLZW9dZvtgCUWdWWt0GZecinODdCi1CkdmXv4hMfVHRg14EFAS0aJv84O30VbwcsfbzyG)cqgpo2GiO4nCvO5klwKJ29OKbIliUcG)Om4OB5ODp6dYXP9cos2tpciIheOYILqoaSr0qY0rzWr)HboKAoLbM4k8dZI3WvJAC)3mwAGdPMtzGLbNl8am8en4mHaIbgR4XrVPFJAudSRDHcYIjIXsJ7wzS0aJv84O30VbUIfAGjz5aXfS4HpdDaebUECCzGdPMtzGjz5aXfS4HpdDaebUECCzuJ79yS0aJv84O30VbUIfAGjz5aXfbzpbrPebUECCzGdPMtzGjz5aXfbzpbrPebUECCzuJAGLZhwrPI4L8uTzS04UvglnWyfpo6n9BGLGurqggyYaXFz5BSaZhkY6lznGqZPAyfpo6pA3JA)r)cqgpo2k8VkuBGOuH0FugC0ES7r7OJJ(fGmECSv4FvO2arPcP)OBF0Fz3J6MboKAoLbMmqCbyuJACVhJLgySIhh9M(nWsqQiiddmzG4VS8nNe5EX4iE8HqMfPHv84O)ODp6oQnpUMkLc1gikTfsn)qdCi1CkdmzG4cWOg14(VmwAGXkEC0B63albPIGmmWKbI)YY3yo5EHlOsfAi1usAyfpo6pA3JAXJUJAZJRPsPqTbIsBHuZp8ODp6xaY4XXwH)vHAdeLkK(JU9rT63nWHuZPmWKbIlaJAuJ7)WyPbgR4XrVPFdCi1CkdShL5k0SyjEdxnWsqQiiddSfp6xaY4XXgebfVHRcnxzXIC0UhLmq8xw(ghdV4ztG)J1ohByfpo6pA3JA)r3rT5X1uPuO2arPTqQ5hE0UhLmqCbXva8hLbhTNJ2rhh1IhDh1MhxtLsHAdeL2cPMF4r7E0VaKXJJTc)Rc1gikvi9hD7J(d7Eu3mWsBsok0aWcvIXDRmQX9TyS0aJv84O30VboKAoLb2JYCfAwSeVHRgyjiveKHb2Ih9laz84ydIGI3WvHMRSyroA3Jsgi(llFJj8llIygl8iplwnSIhh9hT7rT)O7O284AQukuBGO0wi18dpAhDCulE0DuBECnvkfQnquAlKA(HhT7r)cqgpo2k8VkuBGOuH0F0Tp6pS7rDZalTj5Oqdalujg3TYOg37tJLgySIhh9M(nWHuZPmWEuMRqZIL4nC1albPIGmmWw8OFbiJhhBqeu8gUk0CLflYr7Eu7pkzG4VS8nNbWcFdOqba)qqIKgwXJJ(J2rhh1(Jsgi(llF7B4HMCuqg(hwAdR4Xr)r7EulEuYaXFz5BmHFzreZyHh5zXQHv84O)OUDu3oA3JAXJUJAZJRPsPqTbIsBHuZp0alTj5Oqdalujg3TYOg3)nJLgySIhh9M(nWHuZPmWEuMRqZIL4nC1albPIGmmWFbiJhhBqeu8gUk0CLflYr7Eu7pQfpQgCS02(WmceKC31unSIhh9hTJooQCgUFyUA7dZiqqYDxt1a4kYICugC0qQ5unpkZvOzXs8gU2W)OesrHMl8OUD0Uh1Ihvod3pmxnc0AnLWJRPsPqTbIsBq7hT7rT)O7O284AQukuBGO0gaxrwKJYGJ(7hTJooQCgUFyUAeO1AkHhxtLsHAdeL2a4kYIiW)7Our)rzWr)LDpQBgyPnjhfAayHkX4Uvg14(VBS0aJv84O30VboKAoLb2HJexsq4OgyjiveKHbMmq8xw(23Wdn5OGm8pS0gwXJJ(J29OpihN23Wdn5OGm8pS0MFyUmWzPiaaTRI0Xa)GCCAFdp0KJcYW)WsBq7g14EF0yPbgR4XrVPFdSeKkcYWatgi(llFtoRxOIf6tn0CQgwXJJ(J29O7O284AQukuBGO0wi18dnWHuZPmWe5abYILqt1fAuJ7wzxJLgySIhh9M(nWsqQiiddSfpkzG4VS8n5SEHkwOp1qZPAyfpo6nWHuZPmWe5abYILqt1fAuJ7wzLXsdmwXJJEt)gyjiveKHbEh1MhxtLsHAdeL2cPMF4r7EuYaXfexbWFu2h1Ug4qQ5ug4CTJLplwczObrbZUl0Og1aR2arPccQq7glnUBLXsdmwXJJEt)gyjiveKHb(laz84yRW)QqTbIsfs)rzWrTAlg4qQ5ug4cvxiqSpan4g14EpglnWyfpo6n9BGLGurqgg4VaKXJJTc)Rc1gikvi9hLbh1QF7O)8O2F0qQ5unc0AnLWJRPsPqTbIsB4FucPOqZfEuRpAi1CQgXv4hMfVHRn8pkHuuO5cpQBhT7rT)OYz4(H5Qjdox4by4jAWzcbKgaxrwKJYGJA1VD0FEu7pAi1CQgbATMs4X1uPuO2arPn8pkHuuO5cpQ1hnKAovJaTwtj(so6Ky5B4FucPOqZfEuRpAi1CQgXv4hMfVHRn8pkHuuO5cpQBhTJoo6oQnpadprdotiObWvKf5OBF0VaKXJJTc)Rc1gikvi9h16JgsnNQrGwRPeECnvkfQnquAd)JsiffAUWJ6MboKAoLbMfixtcqHdYzbfaVrnU)lJLgySIhh9M(nWsqQiiddS9h9laz84yRW)QqTbIsfs)rzWrTAlh9Nh1(JgsnNQrGwRPeECnvkfQnquAd)JsiffAUWJ62r7Eu7pQCgUFyUAYGZfEagEIgCMqaPbWvKf5Om4OwTLJ(ZJA)rdPMt1iqR1ucpUMkLc1gikTH)rjKIcnx4rT(OHuZPAeO1AkXxYrNelFd)JsiffAUWJ62r7OJJUJAZdWWt0GZecAaCfzro62h9laz84yRW)QqTbIsfs)rT(OHuZPAeO1AkHhxtLsHAdeL2W)OesrHMl8OUDu3oAhDCu7pQfpkaQqNbWcBmNCha6jcsYk5IXrqG2rqoabbATMklwnSIhh9hT7r)cqgpo2k8VkuBGOuH0F0Tp6pS7rDZahsnNYatGwRPeFjhDsS8g14(pmwAGXkEC0B63albPIGmmWFbiJhhBf(xfQnquQq6pkdoQv9C0FEu7pAi1CQgbATMs4X1uPuO2arPn8pkHuuO5cpQ1hnKAovJ4k8dZI3W1g(hLqkk0CHh1ndCi1CkdSm4CHhGHNObNjeqmQX9TyS0aJv84O30VbwcsfbzyG1CHhD7J6KaIkuBGOuHMl8ODpQ9hDh1MhGHNObNje0cPMF4r7E0DuBEagEIgCMqqdGRilYr3(OHuZPAeO1AkHhxtLsHAdeL2W)OesrHMl8OUD0Uh1(JAXJQbhlTrGwRPeFjhDsS8nSIhh9hTJoo6oQTVKJojw(wi18dpQBhT7rT)OKbIliUcG)OSpQDpAhDCu7p6oQnpadprdotiOfsn)WJ29O7O28am8en4mHGgaxrwKJYGJgsnNQrGwRPeECnvkfQnquAd)JsiffAUWJA9rdPMt1iUc)WS4nCTH)rjKIcnx4rD7OD0XrT)O7O2(so6Ky5BHuZp8ODp6oQTVKJojw(gaxrwKJYGJgsnNQrGwRPeECnvkfQnquAd)JsiffAUWJA9rdPMt1iUc)WS4nCTH)rjKIcnx4rD7OD0XrT)OpihNglqUMeGchKZcka(g0(r7E0hKJtJfixtcqHdYzbfaFdGRilYrzWrdPMt1iqR1ucpUMkLc1gikTH)rjKIcnx4rT(OHuZPAexHFyw8gU2W)OesrHMl8OUDu3mWHuZPmWeO1AkHhxtLsHAdeLAuJAG9OtaXvJLg3TYyPbgR4XrVPFdShjsqUR5ugyg2)Oesr)rXpey7OAUWJQUWJgsDahnjhn(IKhpo2mWHuZPmWKDKZf8rYKrnU3JXsdCi1CkdSm4CHdYDbvkcmWyfpo6n9BuJ7)YyPboKAoLbo(JcDiedmwXJJEt)g14(pmwAGdPMtzG943abeRGvknWyfpo6n9BuJ7BXyPbgR4XrVPFd8SBGjOAGdPMtzG)cqgpoAG)coeAGLZW9dZvJaTwtj84AQukuBGO0gaxrweb(FhLk6nWsqQiiddSfpkzG4VS8nNe5EX4iE8HqMfPHv84O)OD0XrLZW9dZvJaTwtj84AQukuBGO0gaxrweb(FhLk6p62hvod3pmxnYaXfGrBaCfzre4)DuQO3a)farfl0ax4FvO2arPcP3Og37tJLgySIhh9M(nWZUbMGQboKAoLb(laz84Ob(l4qObwod3pmxnYaXfGrBaCfzre4)DuQO3albPIGmmWKbI)YY3CsK7fJJ4XhczwKgwXJJ(J29OYz4(H5QrGwRPeECnvkfQnquAdGRilIa)VJsf9hLbhvod3pmxnYaXfGrBaCfzre4)DuQO3a)farfl0ax4FvO2arPcP3Og3)nJLgySIhh9M(nWZUbMGQboKAoLb(laz84Ob(l4qOb(laz84yRW)QqTbIsfsVbwcsfbzyGT4r)cqgpo2GiO4nCvO5klwKJ29Ow8OzjMDSqGb(laIkwOb(b54ii2kPq6nQX9F3yPbgR4XrVPFd8SBGjOAGdPMtzG)cqgpoAG)coeAGTQhdSeKkcYWaBXJ(fGmECSbrqXB4QqZvwSihT7rZsm7yHGJ29Ow8O7O28am8en4mHGwi18dnWFbquXcnWpihhbXwjfsVrnU3hnwAGXkEC0B63ap7gycQg4qQ5ug4VaKXJJg4VGdHgy7AGLGurqggylE0VaKXJJnickEdxfAUYIf5ODpAwIzhleC0UhDh1MhGHNObNje0cPMF4r7E0hKJtJ5K7f5AN0iAiz6OBFu7E0Uh1IhvdowA7l5OtILVHv84O3a)farfl0a)GCCeeBLui9g14Uv21yPbgR4XrVPFd8SBGjOAGdPMtzG)cqgpoAG)coeAGTRbwcsfbzyGT4r)cqgpo2GiO4nCvO5klwKJ29OzjMDSqWr7E0DuBEagEIgCMqqlKA(HhT7r3b4NGL03SQ5kkVyCeSG4(OoA3JQbhlT9LC0jXY3WkEC0BG)cGOIfAGFqoocITskKEJAC3kRmwAGXkEC0B63ap7gycQg4qQ5ug4VaKXJJg4VGdHgy5mC)WC18OmxHMflXB4AdGRilIa)VJsf9gyjiveKHb(laz84ydIGI3WvHMRSyrmWFbquXcnWpihhbXwjfsVrnUBvpglnWyfpo6n9BGdPMtzGLbNlcPMtj4jrnW8KOIkwObwbzXeQeJAC3QFzS0aJv84O30VbwcsfbzyGT)Ow8OFbiJhhBqeu8gUk0CLflYr7E0DuBECnvkfQnquAlKA(Hh1TJ2rhh1(J(fGmECSbrqXB4QqZvwSihT7rFqoonIRa4fJJiQkDL8qZPAq7hT7rT)Ow8OAWXsB7dZiqqYDxt1WkEC0F0o64OpihN2(WmceKC31unO9J62rDZahsnNYaldoxesnNsWtIAG5jrfvSqd8Ws6nQXDR(HXsdmwXJJEt)gyjiveKHb(neYr7EuNKLlvaWvKf5Om4O9Cul0rzj9g4qQ5ug4CTZhsoLrnUB1wmwAGXkEC0B63albPIGmmW6WIfhBYz4(H5IC0UhvZfEugCuNequHAdeLk0CHgyIcsPAC3kdCi1CkdSm4Cri1CkbpjQbMNevuXcnWZowiWOg3TQpnwAGXkEC0B63albPIGmmWa0bGexXJJg4qQ5ugy)mlJAC3QFZyPbgR4XrVPFdSeKkcYWatgi(llFJfy(qrwFjRbeAovdR4Xr)r7OJJsgi(llFZjrUxmoIhFiKzrAyfpo6pAhDCuYaXFz5BYz9cvSqFQHMt1WkEC0F0o64OY5dRO0wHsWWhG3atuqkvJ7wzGdPMtzGLbNlcPMtj4jrnW8KOIkwObwoFyfLkIxYt1MrnUB1VBS0aJv84O30VbwcsfbzyG)cqgpo2GiO4nCvO5klwKJ29OpihNgXva8IXrevLUsEO5unODdCi1Ckd8(WmceKC31ug14Uv9rJLgySIhh9M(nWsqQiiddS9h1Ih9laz84ydIGI3WvHMRSyroA3J(fGmECSv4FvO2arPcP)Om4OSK(2k(F0UhvZfE0TpQtciQqTbIsfAUWJ2rhhLmq8xw(gaDYc9I9Ghk2WkEC0F0Uh9laz84yRW)QqTbIsfs)rzWr)1VFu3oAhDCu7p6xaY4XXgebfVHRcnxzXIC0Uh9b540iUcGxmoIOQ0vYdnNQbTFu3mWHuZPmW7JMtzuJ79yxJLgySIhh9M(nWHuZPmWYGZfHuZPe8KOgyEsurfl0aR2arPccQq7g14EpwzS0aJv84O30VbwcsfbzyGT)Ow8OaOcDgalSXCYDaONiijRKlghbbAhb5aeeO1AQSy1WkEC0F0Uh9laz84yRW)QqTbIsfs)r3(O9XJ62r7OJJA)r3rT5X1uPuO2arPTqQ5hE0UhDh1MhxtLsHAdeL2a4kYICugC0(8OwOJYs6BR4)rDZahsnNYa7X1uPuquawSuxg14Ep9yS0aJv84O30VbwcsfbzyG)cqgpo2GiO4nCvO5klwKJ29OYz4(H5QrGwRPeECnvkfQnquAdGRilIa)VJsf9hD7J2tpg4qQ5ugyzW5cpadprdotiGyuJ798lJLgySIhh9M(nWsqQiiddSfp6xaY4XXgebfVHRcnxzXIC0Uh1(J(fGmECSv4FvO2arPcP)OBF0ES7r)5r3YrTqh1IhfavOZayHnMtUda9ebjzLCX4iiq7iihGGaTwtLfRgwXJJ(J6MboKAoLbwgCUWdWWt0GZecig14Ep)WyPbgR4XrVPFdSeKkcYWaBXJ(fGmECSbrqXB4QqZvwSihT7rFqoonMtUxKRDsJOHKPJU9rT6ODp6dYXP5X1uPuiha2iAiz6Om4O)YahsnNYaVpmJabj3DnLrnU3ZwmwAGXkEC0B63albPIGmmWpihNMAdeL28dZ1r7E0VaKXJJTc)Rc1gikvi9hD7JUfdCi1Ckd8l5iroqawO4nRhcig14Ep9PXsdmwXJJEt)gyjiveKHboKA(HcSWvIKJU9rT6OwFu7pQvh1cDun4yPnsibPtkrVGmqCsdR4Xr)rD7ODp6dYXPXCY9ICTtAenKmD0TzF0(8ODp6dYXPP2arPn)WCD0Uh9laz84yRW)QqTbIsfs)r3(OBXahsnNYaNRD(qYPmQX9E(nJLgySIhh9M(nWsqQiiddCi18dfyHRejhD7J2Zr7E0hKJtJ5K7f5AN0iAiz6OBZ(O95r7E0hKJttTbIsB(H56ODp6xaY4XXwH)vHAdeLkK(JU9r3Yr7EulEuauHodGf2Y1oFi5hk2hflndEdR4Xr)r7Eu7pQfpQgCS0Mdywc1fkiUc)WmPHv84O)OD0Xr94dYXP5aMLqDHcIRWpmtAq7h1ndCi1CkdCU25djNYOg3753nwAGXkEC0B63albPIGmmWHuZpuGfUsKC0TpAphT7rFqoonMtUxKRDsJOHKPJUn7J2NhT7rFqooTCTZhs(HI9rXsZG3a4kYICugC0EoA3JcGk0zaSWwU25dj)qX(OyPzWByfpo6nWHuZPmW5ANpKCkJACVN(OXsdmwXJJEt)gyjiveKHb(b540yo5ErU2jnIgsMo62SpQv9C0UhvdowAJmqCHCkpuQnSIhh9hT7r1GJL2CaZsOUqbXv4hMjnSIhh9hT7rbqf6mawylx78HKFOyFuS0m4nSIhh9hT7rFqoon1gikT5hMRJ29OFbiJhhBf(xfQnquQq6p62hDlg4qQ5ug4CTZhsoLrnU)l7AS0aJv84O30VbwcsfbzyGFdHC0UhvZfk0r4t8Om4O)YUg4qQ5ugywGCnjafoiNfua8g14(VSYyPbgR4XrVPFdSeKkcYWa)gc5ODpQMluOJWN4rzWr753nWHuZPmWeO1AkXxYrNelVrnU)REmwAGXkEC0B63albPIGmmWVHqoA3JQ5cf6i8jEugCuR2IboKAoLbMaTwtj84AQukuBGOuJAC)x)YyPbgR4XrVPFdSeKkcYWatgiUG4ka(JY(OBXahsnNYa7kkVyCeSG4(OmQX9F9dJLgySIhh9M(nWsqQiiddmzG4cIRa4pkdo6woA3JcGk0zaSW2l4izp9iGiEqGklwc5aWgwXJJ(J29OpihN2l4izp9iGiEqGklwc5aWgaxrwKJYGJUfdCi1CkdmXv4hMfVHRg14(V2IXsdmwXJJEt)g4qQ5ugyxr5fJJGfe3hLb2Jeji31Ckd8w35OBfadprdotiGC0aGhn4am82oAi18dz8O1C0cr)r15OK4dpkXva8edSeKkcYWatgiUG4ka(JUn7J(RJ29O2F0DuBEagEIgCMqqlKA(HhTJoo6oQnpUMkLc1gikTfsn)WJ6MrnU)R(0yPbgR4XrVPFdSeKkcYWatgiUG4ka(JUn7JA1r7E0hKJtRq1fce7dqdEdA)ODpQCgUFyUAYGZfEagEIgCMqaPbWvKf5OBF0EoQf6OSK(2k(BGdPMtzGDfLxmocwqCFug14(V(nJLgySIhh9M(nWsqQiiddmzG4cIRa4p62SpQvhT7rFqoonMtUxKRDsJOHKPJU9r75ODp6xaY4XXwH)vHAdeLkK(JYGJYs6BR4)r7Eunx4r3(OojGOc1gikvO5cp6ppklPVTI)g4qQ5ugyxr5fJJGfe3hLrnU)RF3yPbgR4XrVPFdSeKkcYWaBXJkNpSIsBFyPUSbmWefKs14Uvg4qQ5ugyzW5IqQ5ucEsudmpjQOIfAGLZhwrPI4L8uTzuJ7)QpAS0aJv84O30VboKAoLbMmqCbrbjtOb2Jeji31CkdmdxQUgi9OWHeKoPe9hfEG4egpk8aXpkScsMWJMKJsuWuSqWrvxrD0Tcxt9gUY4rjZrt9OUcYrJJ6kz5cbhDhKdivBgyjiveKHb2IhvdowAJesq6Ks0lideN0WkEC0BuJ7)WUglnWyfpo6n9BGdPMtzG94AQ3WvdShjsqUR5ugy4DS8hDRW1uP8O2XaqYrDgWrHhi(rHDfap5OqLM8JAPnqu6rLZW9dZ1rtYrL8HGhvNJcWWBZalbPIGmmWpihNMhxtLsHCaydGHupA3JsgiUG4ka(JYGJ(JJ29OFbiJhhBf(xfQnquQq6p62hTh7AuJ7)WkJLgySIhh9M(nWHuZPmWECn1B4Qb2Jeji31Ckd8wbbYI1rT0gik9OeuH2z8OKDS8hDRW1uP8O2XaqYrDgWrHhi(rHDfapXalbPIGmmWpihNMhxtLsHCaydGHupA3JsgiUG4ka(JYGJ(JJ29OFbiJhhBf(xfQnquQq6pkdoQv9yuJ7)OhJLgySIhh9M(nWsqQiidd8dYXP5X1uPuiha2ayi1J29OKbIliUcG)Om4O)4ODpQ9h9b54084AQukKdaBenKmD0TpAphTJooQgCS0gjKG0jLOxqgioPHv84O)OUzGdPMtzG94AQ3WvJAC)h)YyPbgR4XrVPFdSeKkcYWatqv8McI00eb987IE2LhT7rjdexqCfa)rzWr)Xr7Eu7pQ9hTpp6ppkzG4cIRa4pQBh1cD0qQ5unIRWpmlEdxB4FucPOqZfE0Tp6oQnpadprdotiObWvKf5O)8OHuZPAUIYlghbliUpQg(hLqkk0CHh9NhnKAovZJRPEdxB4FucPOqZfEu3oA3J(GCCAECnvkfYbGnIgsMo62SpQvg4qQ5ugypUM6nC1Og3)XpmwAGXkEC0B63albPIGmmWpihNMhxtLsHCaydGHupA3JsgiUG4ka(JYGJ(JJ29OHuZpuGfUsKC0TpQvg4qQ5ugypUM6nC1Og3)XwmwAGdPMtzGjdexquqYeAGXkEC0B63Og3)rFAS0aJv84O30VboKAoLbwgCUiKAoLGNe1aZtIkQyHgy58HvuQiEjpvBg14(p(nJLgySIhh9M(nWHuZPmWUIYlghbliUpkdShjsqUR5ug4TUZrTnqhvg1rzH6rFHKPJQZr3YrHhi(rHDfap5Op0za4r3kagEIgCMqa5OYz4(H56Oj5Oam82y8OP2j5OdtHTJQZrj7y5pQ6cxhTgMnWsqQiiddmzG4cIRa4p62Sp6VoA3J(fGmECSv4FvO2arPcP)OBF0E2Yr7Eu7pQgCS0MhxtLsHm48Sy1WkEC0F0o64OYz4(H5Qjdox4by4jAWzcbKgaxrwKJU9rT)O2F0TC0FEuYaXfexbWFu3oQf6OHuZPAexHFyw8gU2W)OesrHMl8OUDuRpAi1CQMRO8IXrWcI7JQH)rjKIcnx4rDZOg3)XVBS0aJv84O30VboKAoLb2pZYalbPIGmmWa0bGexXJJhT7r1CHhD7J6KaIkuBGOuHMl0alTj5Oqdalujg3TYOg3)rF0yPbgR4XrVPFdCi1CkdShxt9gUAG9ircYDnNYaBHfbp6wHRPEdxpA6CuBduNa8OSMSyDuDokFi4r3kCnvkpQDma8OenKmry8O4hwhnDoAQD6pkZbrXJghLmq8JsCfaFZalbPIGmmWpihNMhxtLsHCaydGHupA3J(GCCAECnvkfYbGnaUISihLbh1QJA9rzj9Tv8)OwOJ(GCCAECnvkfYbGnIgsMmQX9TyxJLg4qQ5ugyIRWpmlEdxnWyfpo6n9BuJAG3bOCwVqnwAC3kJLgySIhh9M(nWHuZPmWoix4NvwHMtzG9ircYDnNYaZW(hLqk6p6dDgaEu5SEHE0hYkls7Om8sjURKJwt9txby5aXpAi1CkYrNIBRzGLGurqggynx4r3(O29ODpQfp6oQTGNFOrnU3JXsdCi1CkdmbATMs4GCwqbWBGXkEC0B63Og3)LXsdmwXJJEt)g4kwObwNfkghXAkIcgiIqofrbqsnNIyGdPMtzG1zHIXrSMIOGbIiKtruaKuZPig14(pmwAGXkEC0B63axXcnWKHJHlIGGsaQcfLUQKHbcnWHuZPmWKHJHlIGGsaQcfLUQKHbcnQX9TyS0ahsnNYa7WrIljiCudmwXJJEt)g14EFAS0aJv84O30VbwcsfbzyGFqoonMtUxKRDsJOHKPJU9rT6ODp6dYXP5X1uPuiha2iAiz6OmG9r7XahsnNYaVpmJabj3DnLrnU)BglnWyfpo6n9BGRyHgyIRWpmJEXaEIXrOdyHLAGdPMtzGjUc)Wm6fd4jghHoGfwQrnU)7glnWyfpo6n9BGLGurqggy7p6BiKJ2rhhnKAovZJRPEdxBYGOhL9rT7rD7ODpkzG4cIRa4jhLbh9hg4qQ5ugypUM6nC1Og37JglnWyfpo6n9BGLGurqggylEu7p6BiKJ2rhhnKAovZJRPEdxBYGOhL9rT7rD7OD0XrjdexqCfap5OBF0FzGdPMtzGjUc)WS4nC1Og3TYUglnWyfpo6n9BGNDdmbvdCi1Ckd8xaY4Xrd8xWHqdmaQqNbWcBVGJK90JaI4bbQSyjKdaByfpo6pA3JcGk0zaSWgXva8IXrevLUsEO5unSIhh9g4VaiQyHgyickEdxfAUYIfXOg1aRGSycvIXsJ7wzS0aJv84O30VboKAoLbM4k8dZOxmGNyCe6awyPgyjiveKHb(laz84y7b54ii2kPq6pkdoAp9yGRyHgyIRWpmJEXaEIXrOdyHLAuJ79yS0aJv84O30VbUIfAGjYaqeJJWbekcQGlikiDqdCi1CkdmrgaIyCeoGqrqfCbrbPdAuJ7)YyPbgR4XrVPFdSeKkcYWaRbhlT5X1uPuiNIaT21CQgwXJJ(J29OFbiJhhBf(xfQnquQq6pkdoAp21ahsnNYaldoxesnNsWtIAG5jrfvSqdSRDHcYIjIrnU)dJLgySIhh9M(nWEKib5UMtzGzyDCqPsoQ6k0JQG4d5hLWhM52oQohvdalupkazyGsaE0W7tnNk4mEucUhGqXJ6kkpplwg4qQ5ugyzW5IqQ5ucEsudmpjQOIfAGj8HzHcYIjujg14(wmwAGXkEC0B63ahsnNYapFiWHpmNflru5keYGfAGLGurqggy7pQfp6xaY4XXgebfVHRcnxzXIC0UhDh1MhxtLsHAdeL2cPMF4rD7OD0XrT)OFbiJhhBqeu8gUk0CLflYr7E0hKJtJ4kaEX4iIQsxjp0CQg0(rDZaxXcnWZhcC4dZzXsevUcHmyHg14EFAS0aJv84O30VboKAoLbwbzXeQwzGLGurqggyfKftO2uRAUcIaIGIhKJZr7Eu7pQ9h1Ih9laz84ydIGI3WvHMRSyroA3JUJAZJRPsPqTbIsBHuZp8OUD0o64O2F0VaKXJJnickEdxfAUYIf5ODp6dYXPrCfaVyCervPRKhAovdA)OUDu3mWe(OgyfKftOALrnU)BglnWyfpo6n9BGdPMtzGvqwmHApgyjiveKHbwbzXeQnTNMRGiGiO4b54C0Uh1(JA)rT4r)cqgpo2GiO4nCvO5klwKJ29O7O284AQukuBGO0wi18dpQBhTJooQ9h9laz84ydIGI3WvHMRSyroA3J(GCCAexbWlghruv6k5HMt1G2pQBh1ndmHpQbwbzXeQ9yuJ7)UXsdmwXJJEt)gyjiveKHbwZfE0TpQtciQqTbIsfAUWJ29OFbiJhhBpihhbXwjfs)r3(O9yxdCi1CkdSm4Cri1CkbpjQbMNevuXcnW7qau4JvWcfkilMig1Og4Diak8XkyHcfKfteJLg3TYyPbgR4XrVPFdCfl0a7by4Dsak(qcb5g4qQ5ugypadVtcqXhsii3Og37XyPbgR4XrVPFdCfl0aZcKlbk55obnWHuZPmWSa5sGsEUtqJAC)xglnWyfpo6n9BGRyHgyasMkkvaqcc(MeyGdPMtzGbizQOubaji4BsGrnU)dJLgySIhh9M(nWvSqdCaKUsfLkrKflSGs1Mqoa0ahsnNYahaPRurPsezXclOuTjKdanQX9TyS0aJv84O30VbUIfAGLdzLsblE4ZqharaqYuHoadCi1CkdSCiRukyXdFg6aicasMk0byuJ79PXsdmwXJJEt)g4kwOb2dWW7Kau8HecYnWHuZPmWEagENeGIpKqqUrnU)BglnWyfpo6n9BGRyHgyYaXfjRkveyGdPMtzGjdexKSQurGrnU)7glnWyfpo6n9BGdPMtzGzXTT7smoIGqYvYdnNYalbPIGmmWHuZpuGfUsKCu2h1kdCfl0aZIBB3LyCebHKRKhAoLrnU3hnwAGXkEC0B63axXcnW(aW0AMs4rjtIDifGejws0ahsnNYa7datRzkHhLmj2HuasKyjrJAC3k7AS0aJv84O30VbUIfAGX3uKbIl(scAGdPMtzGX3uKbIl(scAuJ7wzLXsdmwXJJEt)g4kwObgQKUISqVGfp8zOdGiiUcjtCKyGdPMtzGHkPRil0lyXdFg6aicIRqYehjg1Og4HL0BS04UvglnWHuZPmWpeqqatzXYaJv84O30VrnU3JXsdCi1Ckd8JpJx4abSzGXkEC0B63Og3)LXsdCi1CkdStcWhFgVbgR4XrVPFJAC)hglnWHuZPmWqeuKkUigySIhh9M(nQrnQb(dbKCkJ79y3E6XU90ZVzGzoavwSigygog((q336U3hWqh9Ow6cpAU2hGEuNbC0oNDSqqNhfGmmqja9hLml8ObKoRqr)rLUIIfsA3g7ml8OwXqh1oM6dbk6pANKbI)YY36BNhvNJ2jzG4VS8T(2WkEC035rd9OmSBn25rT3Q)U1Un3ggog((q336U3hWqh9Ow6cpAU2hGEuNbC0oLZhwrPI4L8uT15rbidducq)rjZcpAaPZku0FuPROyHK2TXoZcpQvm0rTJP(qGI(J2jzG4VS8T(25r15ODsgi(llFRVnSIhh9DEu7T6VBTBJDMfE0EyOJAht9Haf9hTtYaXFz5B9TZJQZr7Kmq8xw(wFByfpo678O2B1F3A3g7ml8O)IHoQDm1hcu0F0ojde)LLV13opQohTtYaXFz5B9THv84OVZJAVv)DRDBSZSWJ(dg6O9H4A(q)rxzXq99OsxOKPJAFn6rJVi5XJJhnRJIliEO5uUDu7T6VBTBJDMfE0FWqh1oM6dbk6pANKbI)YY36BNhvNJ2jzG4VS8T(2WkEC035rT3Q)U1Un2zw4r3cdD0(qCnFO)ORSyO(EuPluY0rTVg9OXxK84XXJM1rXfep0Ck3oQ9w93T2TXoZcp6wyOJAht9Haf9hTtYaXFz5B9TZJQZr7Kmq8xw(wFByfpo678O2B1F3A3g7ml8O9jdDu7yQpeOO)ODsgi(llFRVDEuDoANKbI)YY36BdR4XrFNh1(F93T2TXoZcp6VXqh1oM6dbk6pANAWXsB9TZJQZr7udowARVnSIhh9DEu7T6VBTBJDMfE0FNHoQDm1hcu0F0ojde)LLV13opQohTtYaXFz5B9THv84OVZJAVv)DRDBSZSWJ2hzOJAht9Haf9hTtYaXFz5B9TZJQZr7Kmq8xw(wFByfpo678O2B1F3A3g7ml8Owzxg6O2XuFiqr)r7Kmq8xw(wF78O6C0ojde)LLV13gwXJJ(opAOhLHDRXopQ9w93T2T52WWXW3h6(w39(ag6Oh1sx4rZ1(a0J6mGJ2PAdeLkiOcT35rbidducq)rjZcpAaPZku0FuPROyHK2TXoZcp6VyOJAht9Haf9hTtauHodGf26BNhvNJ2jaQqNbWcB9THv84OVZJAVv)DRDBUnmCm89HUV1DVpGHo6rT0fE0CTpa9Ood4OD6rNaIRDEuaYWaLa0FuYSWJgq6Scf9hv6kkwiPDBSZSWJUfg6O2XuFiqr)r7Kmq8xw(wF78O6C0ojde)LLV13gwXJJ(opQ9w93T2TXoZcpAFYqh1oM6dbk6pANKbI)YY36BNhvNJ2jzG4VS8T(2WkEC035rT3Q)U1Un2zw4rT63yOJAht9Haf9hTtYaXFz5B9TZJQZr7Kmq8xw(wFByfpo678O2)R)U1Un2zw4rTQpYqh1oM6dbk6pANKbI)YY36BNhvNJ2jzG4VS8T(2WkEC035rT3Q)U1Un2zw4r7Xkg6O2XuFiqr)r7eavOZayHT(25r15ODcGk0zaSWwFByfpo678O2B1F3A3g7ml8O98lg6O2XuFiqr)r7eavOZayHT(25r15ODcGk0zaSWwFByfpo678O2B1F3A3g7ml8O98Bm0rTJP(qGI(J2jaQqNbWcB9TZJQZr7eavOZayHT(2WkEC035rT3Q)U1Un2zw4r753zOJAht9Haf9hTtauHodGf26BNhvNJ2jaQqNbWcB9THv84OVZJg6rzy3ASZJAVv)DRDBSZSWJ2tFKHoQDm1hcu0F0obqf6mawyRVDEuDoANaOcDgalS13gwXJJ(opQ9w93T2TXoZcp6V(bdDu7yQpeOO)ODcGk0zaSWwF78O6C0obqf6mawyRVnSIhh9DEu7T6VBTBZTHHJHVp09TU79bm0rpQLUWJMR9bOh1zahTZDakN1l0opkazyGsa6pkzw4rdiDwHI(JkDfflK0Un2zw4rTYUm0rTJP(qGI(J2jaQqNbWcB9TZJQZr7eavOZayHT(2WkEC035rd9OmSBn25rT3Q)U1Un2zw4rTYUm0rTJP(qGI(J2jaQqNbWcB9TZJQZr7eavOZayHT(2WkEC035rT3Q)U1Un3ggog((q336U3hWqh9Ow6cpAU2hGEuNbC0ovqwmHkPZJcqggOeG(JsMfE0asNvOO)OsxrXcjTBJDMfE0(KHoQDm1hcu0F0ovqwmHAZQwF78O6C0ovqwmHAtTQ13opQ9w93T2TXoZcp6VXqh1oM6dbk6pANkilMqT1tRVDEuDoANkilMqTP906BNh1ER(7w72CB26R9bOO)O9XJgsnN6O8KOK2TXaVdgNKJgylWco6wHRPg(WY2rz4caFKmDBSal4OUuDNWq92lRuDb9AYz1ljxq8qZPKGWr7LKlzV3glWcoQfo8bGcGTJ2tFY4r7XU90ZT52ybwWrTdxrXcjm0TXcSGJ(ZJcVJC(rTZrYu72ybwWr)5r3AkUTJcq5Swy5p6wHRPEdxp6oa)PCwVqpA6C0upAsoAwenk9O2pGJ6kaEzq0J6mGJ(gcbjU1UnwGfC0FE0T2HzeCu4C31uhn48Hz0F0Da(t5SEHEuDo6oyKhnlIgLE0Tcxt9gU2UnwGfC0FE0T2VT2JQbhl9OzPiaaTRTBJfybh9NhLH)Bs)rH7)NBBH90hCuYESokZUW6O2gOob4rRrpA8gi9O6Cuc0An1rJJAPnquA72ybwWr)5rTWXrIljiC0ETWC4HMC8OWd)dl9OYOKixKohv6kkwO)O6C0SueaG2vr60UnwGfC0FEulb2oQohn(M0FuMdIMfRJUv4AQuEu7ya4rjAizI0UnwGfC0FEulb2oQohDfmHhD2XcbhDhKdivBhDkUTJY8ay6OPZrzgpQmQJgsfk4CBhD2X6OmNQRJgh1sBGO02T52ybhLH9pkHu0F0h6ma8OYz9c9OpKvwK2rz4LsCxjhTM6NUcWYbIF0qQ5uKJof3w72esnNI02bOCwVqTMDVoix4NvwHMtXy6WwZfUTD7AXDuBbp)WBti1CksBhGYz9c1A29sGwRPe7OEBcPMtrA7auoRxOwZUxicksfxmwXczRZcfJJynfrbderiNIOaiPMtrUnHuZPiTDakN1luRz3lebfPIlgRyHSjdhdxebbLaufkkDvjddeEBcPMtrA7auoRxOwZUxhosCjbHJEBcPMtrA7auoRxOwZU39Hzeii5URPymDy)GCCAmNCVix7KgrdjtBBv3hKJtZJRPsPqoaSr0qYedy3ZTjKAofPTdq5SEHAn7EHiOivCXyflKnXv4hMrVyapX4i0bSWsVnHuZPiTDakN1luRz3Rhxt9gUYy6W2(3qiD0ri1CQMhxt9gU2KbrzBx36sgiUG4kaEcd(XTjKAofPTdq5SEHAn7EjUc)WS4nCLX0HTfT)neshDesnNQ5X1uVHRnzqu221To6GmqCbXva8KT)1TXcSGJgsnNI02bOCwVqTMDVFbiJhhzSIfY2jbevO2arPcnxiJZoBcQm(fCiKTv292ybwWrdPMtrA7auoRxOwZU3VaKXJJmwXczNLy2Xcbmo7SjOY4xWHq2wDBcPMtrA7auoRxOwZU3VaKXJJmwXczdrqXB4QqZvwSimo7SjOY4xWHq2aOcDgalS9cos2tpciIheOYILqoaSlaQqNbWcBexbWlghruv6k5HMtDBUn3gl4OmS)rjKI(JIFiW2r1CHhvDHhnK6aoAsoA8fjpECSDBcPMtryt2roxWhjt3MqQ5ueRz3Rm4CHdYDbvkcUnHuZPiwZU34pk0HqUnHuZPiwZUxp(nqaXkyLYBti1Ckc7VaKXJJmwXczx4FvO2arPcPNXzNnbvg)coeYwod3pmxnc0AnLWJRPsPqTbIsBaCfzre4)DuQONX0HTfjde)LLV5Ki3lghXJpeYSiD0HCgUFyUAeO1AkHhxtLsHAdeL2a4kYIiW)7Our)2Yz4(H5QrgiUamAdGRilIa)VJsf93MqQ5ueRz37xaY4XrgRyHSl8VkuBGOuH0Z4SZMGkJFbhczlNH7hMRgzG4cWOnaUISic8)okv0Zy6WMmq8xw(MtICVyCep(qiZI0vod3pmxnc0AnLWJRPsPqTbIsBaCfzre4)DuQONbYz4(H5QrgiUamAdGRilIa)VJsf93glWcoAi1CkI1S79laz84iJvSq2zjMDSqaJZoBcQm(fCiKTDzmDyVJAZJRPsPqTbIsBHuZp82esnNIyn7E)cqgpoYyflK9dYXrqSvsH0Z4SZMGkJFbhcz)fGmECSv4FvO2arPcPNX0HTf)cqgpo2GiO4nCvO5klwKUwmlXSJfcUnHuZPiwZU3VaKXJJmwXcz)GCCeeBLui9mo7SjOY4xWHq2w1dJPdBl(fGmECSbrqXB4QqZvwSiDZsm7yHGUwCh1MhGHNObNje0cPMF4TjKAofXA29(fGmECKXkwi7hKJJGyRKcPNXzNnbvg)coeY2UmMoST4xaY4XXgebfVHRcnxzXI0nlXSJfc6UJAZdWWt0GZecAHuZpS7dYXPXCY9ICTtAenKmTTD7Arn4yPTVKJojw(gwXJJ(Bti1CkI1S79laz84iJvSq2pihhbXwjfspJZoBcQm(fCiKTDzmDyBXVaKXJJnickEdxfAUYIfPBwIzhle0Dh1MhGHNObNje0cPMFy3Da(jyj9nRAUIYlghbliUpQUAWXsBFjhDsS8nSIhh93MqQ5ueRz37xaY4XrgRyHSFqoocITskKEgND2euz8l4qiB5mC)WC18OmxHMflXB4AdGRilIa)VJsf9mMoS)cqgpo2GiO4nCvO5klwKBti1CkI1S7vgCUiKAoLGNeLXkwiBfKftOsUnHuZPiwZUxzW5IqQ5ucEsugRyHShwspJPdB7T4xaY4XXgebfVHRcnxzXI0Dh1MhxtLsHAdeL2cPMFOBD0H9FbiJhhBqeu8gUk0CLfls3hKJtJ4kaEX4iIQsxjp0CQg0Ex7TOgCS02(WmceKC31unSIhh9D0XdYXPTpmJabj3DnvdA3n3UnHuZPiwZU3CTZhsofJPd73qiDDswUubaxrweg0JfIL0FBcPMtrSMDVYGZfHuZPe8KOmwXczp7yHagjkiLkBRymDyRdlwCSjNH7hMlsxnxidCsarfQnquQqZfEBcPMtrSMDV(zwmMoSbOdajUIhhVnHuZPiwZUxzW5IqQ5ucEsugRyHSLZhwrPI4L8uTXirbPuzBfJPdBYaXFz5BSaZhkY6lznGqZP6OdYaXFz5BojY9IXr84dHmlshDqgi(llFtoRxOIf6tn0CQo6qoFyfL2kucg(a83MqQ5ueRz37(WmceKC31umMoS)cqgpo2GiO4nCvO5klwKUpihNgXva8IXrevLUsEO5unO9Bti1CkI1S7DF0Ckgth22BXVaKXJJnickEdxfAUYIfP7xaY4XXwH)vHAdeLkKEgWs6BR4Fxnx42ojGOc1gikvO5c7OdYaXFz5Ba0jl0l2dEOy3VaKXJJTc)Rc1gikvi9m4x)UBD0H9FbiJhhBqeu8gUk0CLfls3hKJtJ4kaEX4iIQsxjp0CQg0UB3MqQ5ueRz3Rm4Cri1CkbpjkJvSq2QnquQGGk0(TjKAofXA296X1uPuquawSuxmMoST3IaOcDgalSXCYDaONiijRKlghbbAhb5aeeO1AQSy19laz84yRW)QqTbIsfs)29r36Od73rT5X1uPuO2arPTqQ5h2Dh1MhxtLsHAdeL2a4kYIWG(0cXs6BR4VB3MqQ5ueRz3Rm4CHhGHNObNjeqymDy)fGmECSbrqXB4QqZvwSiDLZW9dZvJaTwtj84AQukuBGO0gaxrweb(FhLk63UNEUnHuZPiwZUxzW5cpadprdotiGWy6W2IFbiJhhBqeu8gUk0CLflsx7)cqgpo2k8VkuBGOuH0VDp29NBXczrauHodGf2yo5oa0teKKvYfJJGaTJGCacc0AnvwSC72esnNIyn7E3hMrGGK7UMIX0HTf)cqgpo2GiO4nCvO5klwKUpihNgZj3lY1oPr0qY02w19b54084AQukKdaBenKmXGFDBcPMtrSMDVVKJe5abyHI3SEiGWy6W(b540uBGO0MFyU6(fGmECSv4FvO2arPcPF7TCBcPMtrSMDV5ANpKCkgth2HuZpuGfUsKSTvwBVvwin4yPnsibPtkrVGmqCsdR4XrVBDFqoonMtUxKRDsJOHKPTz3NDFqoon1gikT5hMRUFbiJhhBf(xfQnquQq63El3MqQ5ueRz3BU25djNIX0HDi18dfyHRejB3t3hKJtJ5K7f5AN0iAizAB29z3hKJttTbIsB(H5Q7xaY4XXwH)vHAdeLkK(T3sxlcGk0zaSWwU25dj)qX(OyPzW7AVf1GJL2CaZsOUqbXv4hMjnSIhh9D0HhFqoonhWSeQluqCf(HzsdA3TBti1CkI1S7nx78HKtXy6WoKA(HcSWvIKT7P7dYXPXCY9ICTtAenKmTn7(S7dYXPLRD(qYpuSpkwAg8gaxrweg0txauHodGf2Y1oFi5hk2hflnd(TjKAofXA29MRD(qYPymDy)GCCAmNCVix7KgrdjtBZ2QE6QbhlTrgiUqoLhk1gwXJJ(UAWXsBoGzjuxOG4k8dZKgwXJJ(UaOcDgalSLRD(qYpuSpkwAg8UpihNMAdeL28dZv3VaKXJJTc)Rc1gikvi9BVLBti1CkI1S7LfixtcqHdYzbfapJPd73qiD1CHcDe(ezWVS7TjKAofXA29sGwRPeFjhDsS8mMoSFdH0vZfk0r4tKb9873MqQ5ueRz3lbATMs4X1uPuO2arPmMoSFdH0vZfk0r4tKbwTLBti1CkI1S71vuEX4iybX9rXy6WMmqCbXva8S3YTjKAofXA29sCf(HzXB4kJPdBYaXfexbWZGT0favOZayHTxWrYE6rar8GavwSeYbGDFqooTxWrYE6rar8GavwSeYbGnaUISimyl3gl4OBDNJUvam8en4mHaYrdaE0GdWWB7OHuZpKXJwZrle9hvNJsIp8OexbWtUnHuZPiwZUxxr5fJJGfe3hfJPdBYaXfexbWVn7F11(DuBEagEIgCMqqlKA(HD0XoQnpUMkLc1gikTfsn)q3UnHuZPiwZUxxr5fJJGfe3hfJPdBYaXfexbWVnBR6(GCCAfQUqGyFaAWBq7DLZW9dZvtgCUWdWWt0GZecinaUISiB3JfIL03wX)Bti1CkI1S71vuEX4iybX9rXy6WMmqCbXva8BZ2QUpihNgZj3lY1oPr0qY02909laz84yRW)QqTbIsfspdyj9Tv8VRMlCBNequHAdeLk0CH)KL03wX)Bti1CkI1S7vgCUiKAoLGNeLXkwiB58HvuQiEjpvBmsuqkv2wXy6W2IY5dRO02hwQlBGBJfCugUuDnq6rHdjiDsj6pk8aXjmEu4bIFuyfKmHhnjhLOGPyHGJQUI6OBfUM6nCLXJsMJM6rDfKJgh1vYYfco6oihqQ2UnHuZPiwZUxYaXfefKmHmMoSTOgCS0gjKG0jLOxqgioPHv84O)2ybhfEhl)r3kCnvkpQDmaKCuNbCu4bIFuyxbWtokuPj)OwAdeLEu5mC)WCD0KCujFi4r15Oam82UnHuZPiwZUxpUM6nCLX0H9dYXP5X1uPuiha2ayi1UKbIliUcGNb)O7xaY4XXwH)vHAdeLkK(T7XU3gl4OBfeilwh1sBGO0JsqfANXJs2XYF0TcxtLYJAhdajh1zahfEG4hf2va8KBti1CkI1S71JRPEdxzmDy)GCCAECnvkfYbGnagsTlzG4cIRa4zWp6(fGmECSv4FvO2arPcPNbw1ZTjKAofXA296X1uVHRmMoSFqoonpUMkLc5aWgadP2LmqCbXva8m4hDT)b54084AQukKdaBenKmTDpD0HgCS0gjKG0jLOxqgioPHv84O3TBti1CkI1S71JRPEdxzmDytqv8McI00eb987IE2LDjdexqCfapd(rx7TVp)jzG4cIRa4DZcfsnNQrCf(HzXB4Ad)JsiffAUWT3rT5by4jAWzcbnaUISi)mKAovZvuEX4iybX9r1W)OesrHMl8NHuZPAECn1B4Ad)JsiffAUq36(GCCAECnvkfYbGnIgsM2MTv3MqQ5ueRz3Rhxt9gUYy6W(b54084AQukKdaBamKAxYaXfexbWZGF0nKA(HcSWvIKTT62esnNIyn7EjdexquqYeEBcPMtrSMDVYGZfHuZPe8KOmwXczlNpSIsfXl5PA72ybhDR7CuBd0rLrDuwOE0xiz6O6C0TCu4bIFuyxbWto6dDgaE0TcGHNObNjeqoQCgUFyUoAsokadVngpAQDso6Wuy7O6CuYow(JQUW1rRH5Bti1CkI1S71vuEX4iybX9rXy6WMmqCbXva8BZ(xD)cqgpo2k8VkuBGOuH0VDpBPR9AWXsBECnvkfYGZZIvdR4XrFhDiNH7hMRMm4CHhGHNObNjeqAaCfzr22E73YpjdexqCfaVBwOqQ5unIRWpmlEdxB4FucPOqZf6M1HuZPAUIYlghbliUpQg(hLqkk0CHUDBcPMtrSMDV(zwmkTj5OqdalujSTIX0HnaDaiXv84yxnx42ojGOc1gikvO5cVnwWrTWIGhDRW1uVHRhnDoQTbQtaEuwtwSoQohLpe8OBfUMkLh1ogaEuIgsMimEu8dRJMohn1o9hL5GO4rJJsgi(rjUcGVDBcPMtrSMDVECn1B4kJPd7hKJtZJRPsPqoaSbWqQDFqoonpUMkLc5aWgaxrwegyL1SK(2k(BHEqoonpUMkLc5aWgrdjt3MqQ5ueRz3lXv4hMfVHR3MBJ1hnKAofPr4dZcfKftOsydrqrQ4IXkwiBYaX5OQzXsaGE2yuAtYrHgawOsyBfJPd7VaKXJJThKJJGyRKcPNbAayHAZNenkjAHXw(P99yHyj9Tv83c9fGmECSbrqXB4QqZvwSiUDBS(OHuZPincFywOGSycvI1S7fIGIuXfJvSq2eO6XNXlIfQUSrugth2FbiJhhBpihhbXwjfspd0aWc1MpjAus0cJTyT99yH(cqgpo2GiO4nCvO5klwe3UnwF0qQ5uKgHpmluqwmHkXA29crqrQ4IXkwiBCTBdGbxmaFfLezmDy)fGmECS9GCCeeBLui9mWEnaSqT5tIgLeTWylUzTv9yT99yH(cqgpo2GiO4nCvO5klwe3Un3MqQ5uKMC(WkkveVKNQn2KbIlaJYy6WMmq8xw(glW8HIS(swdi0CQU2)fGmECSv4FvO2arPcPNb9y3o64laz84yRW)QqTbIsfs)2)YUUDBcPMtrAY5dROur8sEQ2SMDVKbIlaJYy6WMmq8xw(MtICVyCep(qiZI0Dh1MhxtLsHAdeL2cPMF4TjKAofPjNpSIsfXl5PAZA29sgiUamkJPdBYaXFz5BmNCVWfuPcnKAkjDT4oQnpUMkLc1gikTfsn)WUFbiJhhBf(xfQnquQq632QF)2esnNI0KZhwrPI4L8uTzn7E9OmxHMflXB4kJsBsok0aWcvcBRymDyVYIH0aWc1Mlm4QR2UuzmDyBXVaKXJJnickEdxfAUYIfPlzG4VS8nogEXZMa)hRDo21(DuBECnvkfQnquAlKA(HDjdexqCfapd6PJoS4oQnpUMkLc1gikTfsn)WUFbiJhhBf(xfQnquQq63(h21TBti1CkstoFyfLkIxYt1M1S71JYCfAwSeVHRmkTj5OqdalujSTIX0H9klgsdaluBUWGRUA7sLX0HTf)cqgpo2GiO4nCvO5klwKUKbI)YY3yc)YIiMXcpYZIvx73rT5X1uPuO2arPTqQ5h2rhwCh1MhxtLsHAdeL2cPMFy3VaKXJJTc)Rc1gikvi9B)d762TjKAofPjNpSIsfXl5PAZA296rzUcnlwI3WvgL2KCuObGfQe2wXy6W2IFbiJhhBqeu8gUk0CLflsx7jde)LLV5maw4Bafka4hcsK0rh2tgi(llF7B4HMCuqg(hwAxlsgi(llFJj8llIygl8iplwU5wxlUJAZJRPsPqTbIsBHuZp82esnNI0KZhwrPI4L8uTzn7E9OmxHMflXB4kJsBsok0aWcvcBRymDy)fGmECSbrqXB4QqZvwSiDT3IAWXsB7dZiqqYDxt1rhYz4(H5QTpmJabj3DnvdGRilcdcPMt18OmxHMflXB4Ad)JsiffAUq36Ar5mC)WC1iqR1ucpUMkLc1gikTbT31(DuBECnvkfQnquAdGRilcd(9o6qod3pmxnc0AnLWJRPsPqTbIsBaCfzre4)DuQONb)YUUDBcPMtrAY5dROur8sEQ2SMDVoCK4scchLX0HnzG4VS8TVHhAYrbz4FyPDFqooTVHhAYrbz4FyPn)WCXywkcaq7QiDy)GCCAFdp0KJcYW)WsBq73MqQ5uKMC(WkkveVKNQnRz3lroqGSyj0uDHmMoSjde)LLVjN1luXc9PgAov3DuBECnvkfQnquAlKA(H3MqQ5uKMC(WkkveVKNQnRz3lroqGSyj0uDHmMoSTizG4VS8n5SEHkwOp1qZPUnHuZPin58HvuQiEjpvBwZU3CTJLplwczObrbZUlKX0H9oQnpUMkLc1gikTfsn)WUKbIliUcGNTDVn3MqQ5uKMRDHcYIjcBicksfxmwXcztYYbIlyXdFg6aicC94462esnNI0CTluqwmrSMDVqeuKkUySIfYMKLdexeK9eeLse46XX1T52esnNI0gwsp7hciiGPSyDBcPMtrAdlP3A29(4Z4foqaB3MqQ5uK2Ws6TMDVojaF8z83MqQ5uK2Ws6TMDVqeuKkUi3MBti1CksB2XcbSjdexagLX0HnzG4VS8nwG5dfz9LSgqO5u3MqQ5uK2SJfcSMDVfQUqGyFaAWVnHuZPiTzhleyn7EzbY1Kau4GCwqbWFBcPMtrAZowiWA29sGwRPeFjhDsS83MqQ5uK2SJfcSMDVexHFyw8gUYy6WMmqCbXva8mylDLZW9dZvtgCUWdWWt0GZecinO9Bti1CksB2XcbwZUxIRWpmlEdxzmDy)fGmECSbrqXB4QqZvwSiDjdexqCfapd2s3hKJt7fCKSNEeqepiqLflHCayJOHKjg8JBti1CksB2XcbwZUxzW5cpadprdotiGCBUnHuZPiTDiak8XkyHcfKfte2qeuKkUySIfY2dWW7Kau8HecYVnHuZPiTDiak8XkyHcfKfteRz3lebfPIlgRyHSzbYLaL8CNG3MqQ5uK2oeaf(yfSqHcYIjI1S7fIGIuXfJvSq2aKmvuQaGee8nj42esnNI02HaOWhRGfkuqwmrSMDVqeuKkUySIfYoasxPIsLiYIfwqPAtihaEBcPMtrA7qau4JvWcfkilMiwZUxicksfxmwXczlhYkLcw8WNHoaIaGKPcDa3MqQ5uK2oeaf(yfSqHcYIjI1S7fIGIuXfJvSq2EagENeGIpKqq(TjKAofPTdbqHpwbluOGSyIyn7EHiOivCXyflKnzG4IKvLkcUnHuZPiTDiak8XkyHcfKfteRz3lebfPIlgRyHSzXTT7smoIGqYvYdnNIX0HDi18dfyHRejST62esnNI02HaOWhRGfkuqwmrSMDVqeuKkUySIfY2haMwZucpkzsSdPaKiXsI3MqQ5uK2oeaf(yfSqHcYIjI1S7fIGIuXfJvSq24BkYaXfFjbVnHuZPiTDiak8XkyHcfKfteRz3lebfPIlgRyHSHkPRil0lyXdFg6aicIRqYehj3MBti1CkstbzXeQe2qeuKkUySIfYM4k8dZOxmGNyCe6awyPmMoS)cqgpo2EqoocITskKEg0tp3MqQ5uKMcYIjujwZUxicksfxmwXcztKbGighHdiueubxquq6G3MqQ5uKMcYIjujwZUxzW5IqQ5ucEsugRyHSDTluqwmrymDyRbhlT5X1uPuiNIaT21CQgwXJJ(UFbiJhhBf(xfQnquQq6zqp292ybhLH1XbLk5OQRqpQcIpKFucFyMB7O6CunaSq9OaKHbkb4rdVp1CQGZ4rj4EacfpQRO88SyDBcPMtrAkilMqLyn7ELbNlcPMtj4jrzSIfYMWhMfkilMqLCBcPMtrAkilMqLyn7EHiOivCXyflK98Hah(WCwSerLRqidwiJPdB7T4xaY4XXgebfVHRcnxzXI0Dh1MhxtLsHAdeL2cPMFOBD0H9FbiJhhBqeu8gUk0CLfls3hKJtJ4kaEX4iIQsxjp0CQg0UB3MqQ5uKMcYIjujwZUxicksfxms4JYwbzXeQwXy6WwbzXeQnRAUcIaIGIhKJtx7T3IFbiJhhBqeu8gUk0CLfls3DuBECnvkfQnquAlKA(HU1rh2)fGmECSbrqXB4QqZvwSiDFqoonIRa4fJJiQkDL8qZPAq7U52TjKAofPPGSycvI1S7fIGIuXfJe(OSvqwmHApmMoSvqwmHARNMRGiGiO4b5401E7T4xaY4XXgebfVHRcnxzXI0Dh1MhxtLsHAdeL2cPMFOBD0H9FbiJhhBqeu8gUk0CLfls3hKJtJ4kaEX4iIQsxjp0CQg0UBUDBcPMtrAkilMqLyn7ELbNlcPMtj4jrzSIfYEhcGcFScwOqbzXeHX0HTMlCBNequHAdeLk0CHD)cqgpo2EqoocITskK(T7XU3MBti1CkstTbIsfeuH2zxO6cbI9bObNX0H9xaY4XXwH)vHAdeLkKEgy1wUnHuZPin1gikvqqfA3A29YcKRjbOWb5SGcGNX0H9xaY4XXwH)vHAdeLkKEgy1V9t7dPMt1iqR1ucpUMkLc1gikTH)rjKIcnxO1HuZPAexHFyw8gU2W)OesrHMl0TU2lNH7hMRMm4CHhGHNObNjeqAaCfzryGv)2pTpKAovJaTwtj84AQukuBGO0g(hLqkk0CHwhsnNQrGwRPeFjhDsS8n8pkHuuO5cToKAovJ4k8dZI3W1g(hLqkk0CHU1rh7O28am8en4mHGgaxrwKT)cqgpo2k8VkuBGOuH0BDi1CQgbATMs4X1uPuO2arPn8pkHuuO5cD72esnNI0uBGOubbvODRz3lbATMs8LC0jXYZy6W2(VaKXJJTc)Rc1gikvi9mWQT8t7dPMt1iqR1ucpUMkLc1gikTH)rjKIcnxOBDTxod3pmxnzW5cpadprdotiG0a4kYIWaR2YpTpKAovJaTwtj84AQukuBGO0g(hLqkk0CHwhsnNQrGwRPeFjhDsS8n8pkHuuO5cDRJo2rT5by4jAWzcbnaUISiB)fGmECSv4FvO2arPcP36qQ5unc0AnLWJRPsPqTbIsB4FucPOqZf6MBD0H9weavOZayHnMtUda9ebjzLCX4iiq7iihGGaTwtLfRUFbiJhhBf(xfQnquQq63(h21TBti1CkstTbIsfeuH2TMDVYGZfEagEIgCMqaHX0H9xaY4XXwH)vHAdeLkKEgyvp)0(qQ5unc0AnLWJRPsPqTbIsB4FucPOqZfADi1CQgXv4hMfVHRn8pkHuuO5cD72esnNI0uBGOubbvODRz3lbATMs4X1uPuO2arPmMoS1CHB7KaIkuBGOuHMlSR97O28am8en4mHGwi18d7UJAZdWWt0GZecAaCfzr2oKAovJaTwtj84AQukuBGO0g(hLqkk0CHU11ElQbhlTrGwRPeFjhDsS8nSIhh9D0XoQTVKJojw(wi18dDRR9KbIliUcGNTD7Od73rT5by4jAWzcbTqQ5h2Dh1MhGHNObNje0a4kYIWGqQ5unc0AnLWJRPsPqTbIsB4FucPOqZfADi1CQgXv4hMfVHRn8pkHuuO5cDRJoSFh12xYrNelFlKA(HD3rT9LC0jXY3a4kYIWGqQ5unc0AnLWJRPsPqTbIsB4FucPOqZfADi1CQgXv4hMfVHRn8pkHuuO5cDRJoS)b540ybY1Kau4GCwqbW3G27(GCCASa5AsakCqolOa4BaCfzryqi1CQgbATMs4X1uPuO2arPn8pkHuuO5cToKAovJ4k8dZI3W1g(hLqkk0CHU5MboGuxdWaBuJAma]] )


end
