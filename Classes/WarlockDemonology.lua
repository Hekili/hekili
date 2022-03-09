-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local GetPlayerAuraBySpellID = _G.GetPlayerAuraBySpellID

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
        if first_combat_tyrant and combat > 0 then
            return first_combat_tyrant - combat
        end

        -- Tyrant is on CD, we're not starting fresh, skip opener.
        if cooldown.summon_demonic_tyrant.true_remains > gcd.max then
            return 0
        end

        return 10
    end )

    spec:RegisterStateExpr( "in_opener", function()
        return time < first_tyrant_time
    end )


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

                --[[ elseif spellID == 265187 and InCombatLockdown() and not first_combat_tyrant then
                    first_combat_tyrant = now ]]
                
                end
            end
        
        elseif imps[ source ] and subtype == "SPELL_CAST_SUCCESS" then
            local demonic_power = GetPlayerAuraBySpellID( 265273 )
            local now = GetTime()

            if not demonic_power then
                local imp = imps[ source ]

                imp.start = now
                imp.casts = imp.casts + 1

                imp.expires = min( imp.max, now + ( ( ( state.level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
            end
        end
    end )

    spec:RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
        -- Rethinking this.
        -- We'll try to make the opener work if Tyrant will be off CD anywhere from 10-20 seconds into the fight.
        -- If it's later, we'll assume we're starting from the middle.
        local tyrant, duration = GetSpellCooldown( 265187 )
        local gcd, gcd_duration = GetSpellCooldown( 61304 )

        tyrant = tyrant + duration
        gcd = gcd + gcd_duration

        if tyrant > gcd then
            first_combat_tyrant = GetTime()
            return
        end

        first_combat_tyrant = GetTime() + 10
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
                            major_demon_remains )
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
    spec:RegisterStateExpr( "major_demon_remains", function ()
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
                applied = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and ( exp - 12 ) or 0 end,
                expires = function () return dreadstalkers_v[ #dreadstalkers_v ] or 0 end,
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
                applied = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and ( exp - 12 ) or 0 end,
                expires = function () return grim_felguard_v[ #grim_felguard_v ] or 0 end,
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
                applied = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and ( exp - 15 ) or 0 end,
                expires = function () return vilefiend_v[ #vilefiend_v ] or 0 end,
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
                applied = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and ( exp - 40 ) or 0 end,
                expires = function () return wild_imps_v[ #wild_imps_v ] or 0 end,
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
                applied = function () local exp = malicious_imps_v[ #malicious_imps_v ]; return exp and ( exp - 40 ) or 0 end,
                expires = function () return malicious_imps_v[ #malicious_imps_v ] or 0 end,
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
                up = function () local exp = other_demon_v[ #other_demon_v ]; return exp and exp >= query_time or false end,
                down = function ( t ) return not t.up end,
                applied = function () local exp = other_demon_v[ #other_demon_v ]; return exp and ( exp - 15 ) or 0 end,
                expires = function () return other_demon_v[ #other_demon_v ] or 0 end,
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

    spec:RegisterSetting( "dcon_imps", 0, {
        type = "range",
        name = "Wild Imps Required",
        desc = "If set above zero, Summon Demonic Tyrant will not be recommended unless the specified number of imps are summoned.\n\n" ..
            "This can backfire horribly, letting your Felguard or Vilefiend expire when you could've extended them with Summon Demonic Tyrant.",
        min = 0,
        max = 10,
        step = 1,
        width= "full"
    } )


    spec:RegisterPack( "Demonology", 20220308, [[d8eegcqikQ8ius1LukLytsjFskyuuiNIc1QuLiVIkQzHcDlvjSlP6xsrggfvDmuQwMukptPunnvPQRjfLTPus(gkPyCkLuNtkQY6uLkVtkQOmpvPCpkyFQs6GQsuTqPu9qusmrLsXfrjLSrPOI4JsrfgPuur6KsrvTsLIzIss3ukQeTtQi)ukQudvPuslfLuQNcQPsr5QsrfvBvkQe(QQeLXQuI9sP)syWqoSWIvvpMOjtvxgzZuPpJIgnv40IEnkXSr1TvYUL8BfdxvCCLsPwoWZHA6KUoiBxP67Ougpk48uK1lfvsZxk0(vzl7wZSW(qjRtTz(2AZ8B38BDVTT)Ewd7wy10dzHFcjlbtYcxXISWBdTMA4dttw4NWeFcV1mlmEGasYcdNlwXc)HsU28l73c7dLSo1M5BRnZVDZV1922(7znMV5zHXpK06uBB1wzHDKEpv2Vf2tyPfEBO1udFyA6qVSaWhjl3ghQ(GFxtnXmvhq)UCwnHZfep0CkjiC1MW5s20TP5YaiDCOTMXd1M5BRTBZTHvCeftc)UBZloe8dX5hIvhjl9BZlouZDXnDiajN1Ik)H2gAn1F46HEa0lKZ6h6Hs3dL6Hs8HYcRrPhYObCihbWldSEi3bCO)GXe24MZoKFQg0dn7eqgphc7iaE8Hs3dzAGAaqhk0d1SdL1Huh0HMhQiq)28IdTToSrGdbNpoM6qbNpSr(d9aOxiN1p0dPZHEaJ8qzH1O0dTn0AQ)W1(T5fhABDFB9qAWPspuwkbaqpA)28Id9Y3N0Fi42FXRnNonhhc)eRdXMdQoKPbQbaDOA0df)bspKohcdTwtDO4qMzceL2VnV4qnNWjSdjiC1MAUy4HMC6qWdFNk9qYOKexKUhs6ikMK)q6COSucaGEur62VnV4qMbmDiDouSpP)qSfynlMhABO1uP8qSYaOdH1qYcUFBEXHmdy6q6COvWcDO5HkcCOhqoGunDOP4MoeBdGLdLUhIn6qYOouivOGZnDO5HQdXwQoouCiZmbIs7wyEIvS1mlmMpSjuqwSqk2AM1j2TMzHPk(CYBB3cxXISW4bIZjvZIPaa9nzHLMKCsObGjPyRtSBHdPMtzHXdeNtQMftba6BYclbPsGmSW7biJpN6Fixxb2ujfs)HE7qAaysA3NynkjDOMouZo0loKrhQTd9shIP03xbdh6Lo0EaY4ZPoeMe)HRcnxzXeFiJTQ1P2SMzHPk(CYBB3chsnNYcJHQpFgViwK6WewTWsqQeidl8EaY4ZP(hY1vGnvsH0FO3oKgaMK29jwJsshQPd1Sd58Hm6qTDOx6q7biJpN6qys8hUk0CLft8Hm2cxXISWyO6ZNXlIfPomHvRADA7wZSWufFo5TTBHdPMtzHP1JjafCXa8vusYclbPsGmSW7biJpN6Fixxb2ujfs)HE7qgDinamjT7tSgLKouthQzhY4d58HyVTd58Hm6qTDOx6q7biJpN6qys8hUk0CLft8Hm2cxXISW06XeGcUya(kkjzvRAHD8iuqwSGTMzDIDRzwyQIpN822TWvSilmolxiUGjp8zOdalO1NtllCi1CklmolxiUGjp8zOdalO1NtlRADQnRzwyQIpN822TWvSilmolxiUiWpjikflO1NtllCi1CklmolxiUiWpjikflO1NtlRAvlSC2Pkkve)KNQjRzwNy3AMfMQ4ZjVTDlSeKkbYWcJhi(plFNjy2jrw7jZbeAovNQ4Zj)HADiJo0EaY4ZPErmOc1eikvi9h6Td1M5puJnEO9aKXNt9IyqfQjquQq6p0RhA7M)qgBHdPMtzHXdexag1QwNAZAMfMQ4ZjVTDlSeKkbYWcJhi(plF3njUxmUIpFW4zH7ufFo5puRd9qA3tRPsPqnbIs7HuZDYchsnNYcJhiUamQvToTDRzwyQIpN822TWsqQeidlmEG4)S8D2sUx4aQuHgsnL4ovXNt(d16qM7qpK290AQukutGO0Ei1CNouRdThGm(CQxedQqnbIsfs)HE9qSV1w4qQ5uwy8aXfGrTQ1P3BnZctv85K32UfoKAoLf2tYCfAwmf)HRwyjivcKHf2ChApaz85uhctI)WvHMRSyIpuRdHhi(plFNtHx8njigI1dN6ufFo5puRdz0HEiT7P1uPuOMarP9qQ5oDOwhcpqCb2ra8h6Td12HASXdzUd9qA3tRPsPqnbIs7HuZD6qTo0EaY4ZPErmOc1eikvi9h61d9EZFiJTWstsoj0aWKuS1j2TQ1PMznZctv85K32UfoKAoLf2tYCfAwmf)HRwyjivcKHf2ChApaz85uhctI)WvHMRSyIpuRdHhi(plFNfAplSyMMReplMDQIpN8hQ1Hm6qpK290AQukutGO0Ei1CNouJnEiZDOhs7EAnvkfQjquApKAUthQ1H2dqgFo1lIbvOMarPcP)qVEO3B(dzSfwAsYjHgaMKIToXUvToTvwZSWufFo5TTBHdPMtzH9KmxHMftXF4QfwcsLazyHn3H2dqgFo1HWK4pCvO5klM4d16qgDi8aX)z57UdGj9hqrcaTtGKWDQIpN8hQXgpKrhcpq8Fw(((Wdn5Kap8DQ0ovXNt(d16qM7q4bI)ZY3zH2ZclMP5kXZIzNQ4Zj)Hm(qgFOwhYCh6H0UNwtLsHAceL2dPM7KfwAsYjHgaMKIToXUvToXASMzHPk(CYBB3chsnNYc7jzUcnlMI)WvlSeKkbYWcVhGm(CQdHjXF4QqZvwmXhQ1Hm6qM7qAWPs7pdBeqGZhht1Pk(CYFOgB8qYz4(HTQ)mSraboFCmvhqRil8HE7qHuZP6EsMRqZIP4pCTtmqsiLeAUOdz8HADiZDi5mC)Ww1XqR1ucpTMkLc1eikTd9COwhYOd9qA3tRPsPqnbIs7aAfzHp0BhARpuJnEi5mC)Ww1XqR1ucpTMkLc1eikTdOvKfwqm8qsL8h6TdTDZFiJTWstsoj0aWKuS1j2TQ1PT2AMfMQ4ZjVTDlCi1CklSlNWoKGWvTWsqQeidlmEG4)S899HhAYjbE47uPDQIpN8hQ1H(qUU99HhAYjbE47uPD)WwzHZsjaa6rfPRf(d5623hEOjNe4HVtL2HESQ1PMN1mlmvXNtEB7wyjivcKHfgpq8Fw(UCw)qflYNAO5uDQIpN8hQ1HEiT7P1uPuOMarP9qQ5ozHdPMtzHXYbcKftHMQdYQwNy38wZSWufFo5TTBHLGujqgwyZDi8aX)z57Yz9dvSiFQHMt1Pk(CYBHdPMtzHXYbcKftHMQdYQwNyNDRzwyQIpN822TWsqQeidl8dPDpTMkLc1eikThsn3Pd16q4bIlWocG)qgoK5TWHuZPSW56HkFwmfYqdScMhhKvTQfwnbIsfysHESMzDIDRzwyQIpN822TWsqQeidl8EaY4ZPErmOc1eikvi9h6TdXEZSWHuZPSWfPoiG4zaAWTQ1P2SMzHPk(CYBB3clbPsGmSW7biJpN6fXGkutGOuH0FO3oe7SMd9Idz0HcPMt1XqR1ucpTMkLc1eikTtmqsiLeAUOd58HcPMt1Xoc)WM4pCTtmqsiLeAUOdz8HADiJoKCgUFyR6YGZfEafESgCwiaUdOvKf(qVDi2znh6fhYOdfsnNQJHwRPeEAnvkfQjquANyGKqkj0CrhY5dfsnNQJHwRPe7jNCtQ8DIbscPKqZfDiNpui1CQo2r4h2e)HRDIbscPKqZfDiJpuJnEOhs7EafESgCwiqhqRil8HE9q7biJpN6fXGkutGOuH0FiNpui1CQogATMs4P1uPuOMarPDIbscPKqZfDiJTWHuZPSWmb5AsajCjotOa4TQ1PTBnZctv85K32UfwcsLazyHn6q7biJpN6fXGkutGOuH0FO3oe7n7qV4qgDOqQ5uDm0AnLWtRPsPqnbIs7edKesjHMl6qgFOwhYOdjNH7h2QUm4CHhqHhRbNfcG7aAfzHp0BhI9MDOxCiJoui1CQogATMs4P1uPuOMarPDIbscPKqZfDiNpui1CQogATMsSNCYnPY3jgijKscnx0Hm(qn24HEiT7bu4XAWzHaDaTISWh61dThGm(CQxedQqnbIsfs)HC(qHuZP6yO1AkHNwtLsHAceL2jgijKscnx0Hm(qgFOgB8qgDiZDiaurUdGj1zl5UaYJf4KzYfJRad9qGCacm0Anvwm7ufFo5puRdThGm(CQxedQqnbIsfs)HE9qV38hYylCi1CklmgATMsSNCYnPYBvRtV3AMfMQ4ZjVTDlSeKkbYWcVhGm(CQxedQqnbIsfs)HE7qS32HEXHm6qHuZP6yO1AkHNwtLsHAceL2jgijKscnx0HC(qHuZP6yhHFyt8hU2jgijKscnx0Hm2chsnNYcldox4bu4XAWzHayRADQzwZSWufFo5TTBHLGujqgwynx0HE9qUjaRc1eikvO5IouRdz0HEiT7bu4XAWzHa9qQ5oDOwh6H0UhqHhRbNfc0b0kYcFOxpui1CQogATMs4P1uPuOMarPDIbscPKqZfDiJpuRdz0Hm3H0GtL2XqR1uI9KtUjv(ovXNt(d1yJh6H0(EYj3KkFpKAUthY4d16qgDi8aXfyhbWFidhY8hQXgpKrh6H0UhqHhRbNfc0dPM70HADOhs7EafESgCwiqhqRil8HE7qHuZP6yO1AkHNwtLsHAceL2jgijKscnx0HC(qHuZP6yhHFyt8hU2jgijKscnx0Hm(qn24Hm6qpK23to5Mu57HuZD6qTo0dP99KtUjv(oGwrw4d92HcPMt1XqR1ucpTMkLc1eikTtmqsiLeAUOd58HcPMt1Xoc)WM4pCTtmqsiLeAUOdz8HASXdz0H(qUUDMGCnjGeUeNjua8DONd16qFix3otqUMeqcxIZeka(oGwrw4d92HcPMt1XqR1ucpTMkLc1eikTtmqsiLeAUOd58HcPMt1Xoc)WM4pCTtmqsiLeAUOdz8Hm2chsnNYcJHwRPeEAnvkfQjquQvTQf2tUbexTMzDIDRzwyQIpN822TWEclb5JMtzHzTyGKqk5peTtathsZfDi1bDOqQd4qj(qXEK84ZPUfoKAoLfg)qCUGpswSQ1P2SMzHdPMtzHLbNlCjUdOsjGfMQ4ZjVTDRADA7wZSWHuZPSWbdKqhm2ctv85K32UvTo9ERzw4qQ5uwypTpqaXkyMslmvXNtEB7w16uZSMzHPk(CYBB3cppwymPw4qQ5uw49aKXNtw49Gdrwy5mC)Ww1XqR1ucpTMkLc1eikTdOvKfwqm8qsL8wyjivcKHf2Chcpq8Fw(UBsCVyCfF(GXZc3Pk(CYFOgB8qYz4(HTQJHwRPeEAnvkfQjquAhqRilSGy4HKk5p0Rhsod3pSvD8aXfGr7aAfzHfedpKujVfEpaIkwKfUiguHAceLkKERADARSMzHPk(CYBB3cppwymPw4qQ5uw49aKXNtw49Gdrwy5mC)Ww1XdexagTdOvKfwqm8qsL8wyjivcKHfgpq8Fw(UBsCVyCfF(GXZc3Pk(CYFOwhsod3pSvDm0AnLWtRPsPqnbIs7aAfzHfedpKuj)HE7qYz4(HTQJhiUamAhqRilSGy4HKk5TW7bquXISWfXGkutGOuH0BvRtSgRzwyQIpN822TWZJfgtQfoKAoLfEpaz85KfEp4qKfEpaz85uViguHAceLkKElSeKkbYWcBUdThGm(CQdHjXF4QqZvwmXhQ1Hm3HYsmpural8EaevSil8hY1vGnvsH0BvRtBT1mlmvXNtEB7w45XcJj1chsnNYcVhGm(CYcVhCiYcZEBwyjivcKHf2ChApaz85uhctI)WvHMRSyIpuRdLLyEOIahQ1Hm3HEiT7bu4XAWzHa9qQ5ozH3dGOIfzH)qUUcSPskKERADQ5znZctv85K32UfEESWysTWHuZPSW7biJpNSW7bhISWM3clbPsGmSWM7q7biJpN6qys8hUk0CLft8HADOSeZdve4qTo0dPDpGcpwdoleOhsn3Pd16qFix3oBj3lY1dUJ1qYYHE9qM)qToK5oKgCQ0(EYj3KkFNQ4ZjVfEpaIkwKf(d56kWMkPq6TQ1j2nV1mlmvXNtEB7w45XcJj1chsnNYcVhGm(CYcVhCiYcBElSeKkbYWcBUdThGm(CQdHjXF4QqZvwmXhQ1HYsmpurGd16qpK29ak8yn4SqGEi1CNouRd9aODbtPVZE3ruEX4kycX9rDOwhsdovAFp5KBsLVtv85K3cVharflYc)HCDfytLui9w16e7SBnZctv85K32UfEESWysTWHuZPSW7biJpNSW7bhISWYz4(HTQ7jzUcnlMI)W1oGwrwybXWdjvYBHLGujqgw49aKXNtDimj(dxfAUYIj2cVharflYc)HCDfytLui9w16e7TznZctv85K32UfoKAoLfwgCUiKAoLGNy1cZtSkQyrwyfKflKITQ1j23U1mlmvXNtEB7wyjivcKHf2OdzUdThGm(CQdHjXF4QqZvwmXhQ1HEiT7P1uPuOMarP9qQ5oDiJpuJnEiJo0EaY4ZPoeMe)HRcnxzXeFOwh6d562XocGxmUIOQ0rYdnNQd9COwhYOdzUdPbNkT)mSraboFCmvNQ4Zj)HASXd9HCD7pdBeqGZhht1HEoKXhYylCi1CklSm4Cri1CkbpXQfMNyvuXISWdtP3QwNy)9wZSWufFo5TTBHLGujqgw4)GXhQ1HCtMoubGwrw4d92HA7qV0Hyk9w4qQ5uw4C9WhCoLvToXEZSMzHPk(CYBB3clbPsGmSW6WKjN6Yz4(HTcFOwhsZfDO3oKBcWQqnbIsfAUilmwbPuToXUfoKAoLfwgCUiKAoLGNy1cZtSkQyrw45HkcyvRtSVvwZSWufFo5TTBHLGujqgwya5ciSJ4ZjlCi1CklSFMLvToXoRXAMfMQ4ZjVTDlSeKkbYWcJhi(plFNjy2jrw7jZbeAovNQ4Zj)HASXdHhi(plF3njUxmUIpFW4zH7ufFo5puJnEi8aX)z57Yz9dvSiFQHMt1Pk(CYFOgB8qYzNQO0ErsWWhG3cJvqkvRtSBHdPMtzHLbNlcPMtj4jwTW8eRIkwKfwo7ufLkIFYt1KvToX(wBnZctv85K32UfwcsLazyH3dqgFo1HWK4pCvO5klM4d16qFix3o2ra8IXvevLosEO5uDOhlCi1Ckl8ZWgbe48XXuw16e7npRzwyQIpN822TWsqQeidlSrhYChApaz85uhctI)WvHMRSyIpuRdThGm(CQxedQqnbIsfs)HE7qmL((ky4qToKMl6qVEi3eGvHAceLk0CrhQXgpeEG4)S8Da5Mf5fpbpuQtv85K)qTo0EaY4ZPErmOc1eikvi9h6TdT9T(qgFOgB8qgDO9aKXNtDimj(dxfAUYIj(qTo0hY1TJDeaVyCfrvPJKhAovh65qgBHdPMtzHFgnNYQwNAZ8wZSWufFo5TTBHdPMtzHLbNlcPMtj4jwTW8eRIkwKfwnbIsfysHESQ1P2y3AMfMQ4ZjVTDlSeKkbYWcB0Hm3Haqf5oaMuNTK7cipwGtMjxmUcm0dbYbiWqR1uzXStv85K)qTo0EaY4ZPErmOc1eikvi9h61d18oKXhQXgpKrh6H0UNwtLsHAceL2dPM70HADOhs7EAnvkfQjquAhqRil8HE7qB1HEPdXu67RGHdzSfoKAoLf2tRPsPaRaQyQoSQ1P2AZAMfMQ4ZjVTDlSeKkbYWcVhGm(CQdHjXF4QqZvwmXhQ1HKZW9dBvhdTwtj80AQukutGO0oGwrwybXWdjvYFOxpuBTzHdPMtzHLbNl8ak8yn4SqaSvTo122TMzHPk(CYBB3clbPsGmSWM7q7biJpN6qys8hUk0CLft8HADiJo0EaY4ZPErmOc1eikvi9h61d1M5p0louZo0lDiZDiaurUdGj1zl5UaYJf4KzYfJRad9qGCacm0Anvwm7ufFo5pKXw4qQ5uwyzW5cpGcpwdoleaBvRtT9ERzwyQIpN822TWsqQeidlS5o0EaY4ZPoeMe)HRcnxzXeFOwh6d562zl5ErUEWDSgswo0RhI9d16qFix3UNwtLsHCauhRHKLd92H2UfoKAoLf(zyJacC(4ykRADQTMznZctv85K32UfwcsLazyH)qUUD1eikT7h2Qd16q7biJpN6fXGkutGOuH0FOxpuZSWHuZPSW)Kty5abysI)S(eaBvRtTTvwZSWufFo5TTBHLGujqgw4qQ5ojOIwjHp0RhI9d58Hm6qSFOx6qAWPs74qcs3usEbEG44ovXNt(dz8HADOpKRBNTK7f56b3XAiz5qVA4qB1HADOpKRBxnbIs7(HT6qTo0EaY4ZPErmOc1eikvi9h61d1mlCi1CklCUE4doNYQwNAJ1ynZctv85K32UfwcsLazyHdPM7KGkALe(qVEO2ouRd9HCD7SLCVixp4owdjlh6vdhARouRd9HCD7QjquA3pSvhQ1H2dqgFo1lIbvOMarPcP)qVEOMDOwhYChcavK7ays9C9WhCUtINrPsZG3Pk(CYFOwhYOdzUdPbNkT7cMLqDqcSJWpSH7ufFo5puJnEip9HCD7UGzjuhKa7i8dB4o0ZHm2chsnNYcNRh(GZPSQ1P22ARzwyQIpN822TWsqQeidlCi1CNeurRKWh61d12HADOpKRBNTK7f56b3XAiz5qVA4qB1HADOpKRBpxp8bN7K4zuQ0m4DaTISWh6Td12HADiaurUdGj1Z1dFW5ojEgLkndENQ4ZjVfoKAoLfoxp8bNtzvRtT18SMzHPk(CYBB3clbPsGmSWFix3oBj3lY1dUJ1qYYHE1WHyVTd16qAWPs74bIlKt5HsTtv85K)qToKgCQ0Ulywc1bjWoc)WgUtv85K)qToeaQi3bWK656Hp4CNepJsLMbVtv85K)qTo0hY1TRMarPD)WwDOwhApaz85uViguHAceLkK(d96HAMfoKAoLfoxp8bNtzvRtB38wZSWufFo5TTBHLGujqgw4)GXhQ1H0CrcDe(Ko0BhA7M3chsnNYcZeKRjbKWL4mHcG3QwN2o7wZSWufFo5TTBHLGujqgw4)GXhQ1H0CrcDe(Ko0BhQTT2chsnNYcJHwRPe7jNCtQ8w1602BZAMfMQ4ZjVTDlSeKkbYWc)hm(qToKMlsOJWN0HE7qS3mlCi1CklmgATMs4P1uPuOMarPw16023U1mlmvXNtEB7wyjivcKHfgpqCb2ra8hYWHAMfoKAoLf2ruEX4kycX9rzvRtB)9wZSWufFo5TTBHLGujqgwy8aXfyhbWFO3ouZouRdbGkYDamP(p4e(j9eal(qGklMc5aOovXNt(d16qFix3(p4e(j9eal(qGklMc5aOoGwrw4d92HAMfoKAoLfg7i8dBI)WvRADA7nZAMfMQ4ZjVTDlCi1CklSJO8IXvWeI7JYc7jSeKpAoLfU57EOTbqHhRbNfcGpuaOdfCafEthkKAUtmEOAourK)q6CiCSthc7iaESfwcsLazyHXdexGDea)HE1WH2(HADiJo0dPDpGcpwdoleOhsn3Pd1yJh6H0UNwtLsHAceL2dPM70Hm2QwN2(wznZctv85K32UfwcsLazyHXdexGDea)HE1WHy)qTo0hY1TxK6GaINbObVd9COwhsod3pSvDzW5cpGcpwdolea3b0kYcFOxpuBh6LoetPVVcgSWHuZPSWoIYlgxbtiUpkRADA7SgRzwyQIpN822TWsqQeidlmEG4cSJa4p0Rgoe7hQ1H(qUUD2sUxKRhChRHKLd96HA7qTo0EaY4ZPErmOc1eikvi9h6TdXu67RGHd16qAUOd96HCtawfQjquQqZfDOxCiMsFFfmyHdPMtzHDeLxmUcMqCFuw16023ARzwyQIpN822TWsqQeidlS5oKC2PkkTVtL6WeWcJvqkvRtSBHdPMtzHLbNlcPMtj4jwTW8eRIkwKfwo7ufLkIFYt1KvToT9MN1mlmvXNtEB7w4qQ5uwy8aXfyfKSqwypHLG8rZPSWVSuDmq6HGdjiDtj5pe8aXXmEi4bIFiyfKSqhkXhcRGPysGdPoI6qBdTM6pCLXdHNdL6HCe4dfhYrY0bbo0dihqQMSWsqQeidlS5oKgCQ0ooKG0nLKxGhioUtv85K3QwNEV5TMzHPk(CYBB3chsnNYc7P1u)HRwypHLG8rZPSWWpu5p02qRPs5HyLbq4d5oGdbpq8db7iaE8HGkn5hYmtGO0djNH7h2QdL4dj5dMoKohcqH3KfwcsLazyH)qUUDpTMkLc5aOoGcPEOwhcpqCb2ra8h6Td9(d16q7biJpN6fXGkutGOuH0FOxpuBM3QwNEp7wZSWufFo5TTBHdPMtzH90AQ)WvlSNWsq(O5uw4TbcKfZdzMjqu6HWKc9W4HWpu5p02qRPs5HyLbq4d5oGdbpq8db7iaESfwcsLazyH)qUUDpTMkLc5aOoGcPEOwhcpqCb2ra8h6Td9(d16q7biJpN6fXGkutGOuH0FO3oe7TzvRtVVnRzwyQIpN822TWsqQeidl8hY1T7P1uPuiha1bui1d16q4bIlWocG)qVDO3FOwhYOd9HCD7EAnvkfYbqDSgswo0RhQTd1yJhsdovAhhsq6MsYlWdeh3Pk(CYFiJTWHuZPSWEAn1F4QvTo9(TBnZctv85K32UfwcsLazyHXKk(tbH7AsG22ArBpYd16q4bIlWocG)qVDO3FOwhYOdz0H2Qd9IdHhiUa7ia(dz8HEPdfsnNQJDe(HnXF4ANyGKqkj0Crh61d9qA3dOWJ1GZcb6aAfzHp0loui1CQUJO8IXvWeI7JQtmqsiLeAUOd9IdfsnNQ7P1u)HRDIbscPKqZfDiJpuRd9HCD7EAnvkfYbqDSgswo0Rgoe7w4qQ5uwypTM6pC1QwNE)7TMzHPk(CYBB3clbPsGmSWFix3UNwtLsHCauhqHupuRdHhiUa7ia(d92HE)HADOqQ5ojOIwjHp0RhIDlCi1CklSNwt9hUAvRtVVzwZSWHuZPSW4bIlWkizHSWufFo5TTBvRtVFRSMzHPk(CYBB3chsnNYcldoxesnNsWtSAH5jwfvSilSC2Pkkve)KNQjRAD69SgRzwyQIpN822TWHuZPSWoIYlgxbtiUpklSNWsq(O5uw4MV7Hmnqhsg1Hys6H(HKLdPZHA2HGhi(HGDeap(qFYDa0H2gafESgCwia(qYz4(HT6qj(qak8My8qP2a(qdlHPdPZHWpu5pK6GwhQg2SWsqQeidlmEG4cSJa4p0Rgo02puRdThGm(CQxedQqnbIsfs)HE9qT1Sd16qgDin4uPDpTMkLczW5zXStv85K)qn24HKZW9dBvxgCUWdOWJ1GZcbWDaTISWh61dz0Hm6qn7qV4q4bIlWocG)qgFOx6qHuZP6yhHFyt8hU2jgijKscnx0Hm(qoFOqQ5uDhr5fJRGje3hvNyGKqkj0CrhYyRAD69BT1mlmvXNtEB7w4qQ5uwy)mllSeKkbYWcdixaHDeFoDOwhsZfDOxpKBcWQqnbIsfAUilS0KKtcnamjfBDIDRAD69npRzwyQIpN822TWHuZPSWEAn1F4Qf2tyjiF0CklCZ5y6qBdTM6pC9qP7HmnqnaOdXCYI5H05q8bthABO1uP8qSYaOdH1qYcMXdr7uDO09qP2G)qSfyLouCi8aXpe2ra8DlSeKkbYWc)HCD7EAnvkfYbqDafs9qTo0hY1T7P1uPuiha1b0kYcFO3oe7hY5dXu67RGHd9sh6d56290AQukKdG6ynKSyvRtnZ8wZSWHuZPSWyhHFyt8hUAHPk(CYBB3Qw1c)ai5S(HAnZ6e7wZSWufFo5TTBHdPMtzHDjUWpRScnNYc7jSeKpAoLfM1IbscPK)qFYDa0HKZ6h6H(eZSW9d9YLs6rXhQM6focWYfIFOqQ5u4dnf3u3clbPsGmSWAUOd96Hm)HADiZDOhs7bp3jRADQnRzw4qQ5uwym0AnLWL4mHcG3ctv85K32UvToTDRzwyQIpN822TWvSilSolsmUI1uyfmqyHCkScGKAof2chsnNYcRZIeJRynfwbdewiNcRaiPMtHTQ1P3BnZctv85K32UfUIfzHXdNchybMKasfkjDu52gISWHuZPSW4HtHdSatsaPcLKoQCBdrw16uZSMzHdPMtzHD5e2HeeUQfMQ4ZjVTDRADARSMzHPk(CYBB3clbPsGmSWFix3oBj3lY1dUJ1qYYHE9qSFOwh6d56290AQukKdG6ynKSCO3mCO2SWHuZPSWpdBeqGZhhtzvRtSgRzwyQIpN822TWvSilm2r4h2iVyaFX4k0bSOsTWHuZPSWyhHFyJ8Ib8fJRqhWIk1QwN2ARzwyQIpN822TWsqQeidlmEG4cSJa4Xh6Td1Sd16qgDO)GXhQXgpui1CQUNwt9hU2LbwpKHdz(dzSfoKAoLf2tRP(dxTQ1PMN1mlmvXNtEB7wyjivcKHfgpqCb2ra84d92HA2HADiZDiJo0FW4d1yJhkKAov3tRP(dx7YaRhYWHm)Hm2chsnNYcJDe(HnXF4QvToXU5TMzHPk(CYBB3cppwymPw4qQ5uw49aKXNtw49GdrwyaurUdGj1)bNWpPNayXhcuzXuiha1Pk(CYFOwhcavK7aysDSJa4fJRiQkDK8qZP6ufFo5TW7bquXISWqys8hUk0CLftSvTQfEEOIawZSoXU1mlmvXNtEB7wyjivcKHfgpq8Fw(otWStIS2tMdi0CQovXNtElCi1CklmEG4cWOw16uBwZSWHuZPSWfPoiG4zaAWTWufFo5TTBvRtB3AMfoKAoLfMjixtciHlXzcfaVfMQ4ZjVTDRAD69wZSWHuZPSWyO1AkXEYj3KkVfMQ4ZjVTDRADQzwZSWufFo5TTBHLGujqgwy8aXfyhbWFO3ouZouRdjNH7h2QUm4CHhqHhRbNfcG7qpw4qQ5uwySJWpSj(dxTQ1PTYAMfMQ4ZjVTDlSeKkbYWcVhGm(CQdHjXF4QqZvwmXhQ1HWdexGDea)HE7qn7qTo0hY1T)doHFspbWIpeOYIPqoaQJ1qYYHE7qV3chsnNYcJDe(HnXF4QvToXASMzHdPMtzHLbNl8ak8yn4SqaSfMQ4ZjVTDRAvlScYIfsXwZSoXU1mlmvXNtEB7w4qQ5uwySJWpSrEXa(IXvOdyrLAHLGujqgw49aKXNt9pKRRaBQKcP)qVDO2AZcxXISWyhHFyJ8Ib8fJRqhWIk1QwNAZAMfMQ4ZjVTDlCflYcJLbalgxHliucubxGvq6sw4qQ5uwySmayX4kCbHsGk4cScsxYQwN2U1mlmvXNtEB7wyjivcKHfwdovA3tRPsPqofgA9O5uDQIpN8hQ1H2dqgFo1lIbvOMarPcP)qVDO2mVfoKAoLfwgCUiKAoLGNy1cZtSkQyrwyhpcfKflyRAD69wZSWufFo5TTBH9ewcYhnNYcZA56ssfFi1rOhsbXoXpeMpSXnDiDoKgaMKEiaTTHsaDOW7tnNk4mEim9eGqPd5ikpplMw4qQ5uwyzW5IqQ5ucEIvlmpXQOIfzHX8HnHcYIfsXw16uZSMzHPk(CYBB3chsnNYcp7eWLpSLftru5keYGjzHLGujqgwyJoK5o0EaY4ZPoeMe)HRcnxzXeFOwh6H0UNwtLsHAceL2dPM70Hm(qn24Hm6q7biJpN6qys8hUk0CLft8HADOpKRBh7iaEX4kIQshjp0CQo0ZHm2cxXISWZobC5dBzXuevUcHmysw160wznZctv85K32UfoKAoLfwbzXcPSBHLGujqgwyfKflK2v27ocSactIpKR7HADiJoKrhYChApaz85uhctI)WvHMRSyIpuRd9qA3tRPsPqnbIs7HuZD6qgFOgB8qgDO9aKXNtDimj(dxfAUYIj(qTo0hY1TJDeaVyCfrvPJKhAovh65qgFiJTWy(OwyfKflKYUvToXASMzHPk(CYBB3chsnNYcRGSyH02SWsqQeidlScYIfs7ABDhbwaHjXhY19qToKrhYOdzUdThGm(CQdHjXF4QqZvwmXhQ1HEiT7P1uPuOMarP9qQ5oDiJpuJnEiJo0EaY4ZPoeMe)HRcnxzXeFOwh6d562XocGxmUIOQ0rYdnNQd9CiJpKXwymFulScYIfsBZQwN2ARzwyQIpN822TWsqQeidlSMl6qVEi3eGvHAceLk0CrhQ1H2dqgFo1)qUUcSPskK(d96HAZ8w4qQ5uwyzW5IqQ5ucEIvlmpXQOIfzHFGaKWhRGjjuqwSGTQvTWpqas4JvWKekilwWwZSoXU1mlmvXNtEB7w4kwKf2dOW7MasStymXTWHuZPSWEafE3eqIDcJjUvTo1M1mlmvXNtEB7w4kwKfMjixcsYZhmzHdPMtzHzcYLGK88btw1602TMzHPk(CYBB3cxXISWacpvuQaqycSpjWchsnNYcdi8urPcaHjW(KaRAD69wZSWufFo5TTBHRyrw4aiDKkjvSilMubLQjHCaKfoKAoLfoashPssflYIjvqPAsihazvRtnZAMfMQ4ZjVTDlCflYclh8kLcM8WNHoaSaq4PcDaw4qQ5uwy5GxPuWKh(m0bGfacpvOdWQwN2kRzwyQIpN822TWvSilShqH3nbKyNWyIBHdPMtzH9ak8UjGe7egtCRADI1ynZctv85K32UfUIfzHXdexKmRujGfoKAoLfgpqCrYSsLaw160wBnZctv85K32UfoKAoLfMj30JdX4kcmoxjp0CklSeKkbYWchsn3jbv0kj8HmCi2TWvSilmtUPhhIXveyCUsEO5uw16uZZAMfMQ4ZjVTDlCflYc7dalRzkHNKSiEGuaHLujjlCi1CklSpaSSMPeEsYI4bsbewsLKSQ1j2nV1mlmvXNtEB7w4kwKfM(tHhiUypXKfoKAoLfM(tHhiUypXKvToXo7wZSWufFo5TTBHRyrwyOs6iYI8cM8WNHoaSa7iKSWjSfoKAoLfgQKoISiVGjp8zOdalWocjlCcBvRAHhMsV1mRtSBnZchsnNYc)jaMaSKftlmvXNtEB7w16uBwZSWHuZPSWF(mEHleWKfMQ4ZjVTDRADA7wZSWHuZPSWUjG(8z8wyQIpN822TQ1P3BnZchsnNYcdHjrQ0cBHPk(CYBB3Qw1Qw4DcGZPSo1M5BRnZVDZ3MfMTauzXeBHFzVCwBNA(o1C8UdDiZCqhkxpdqpK7aoudy(WMqbzXcP4goeG22qjG8hcpl6qbKoRqj)HKoIIjH73gwnl6qS)UdXktTtaL8hcoxSYHWMkny4qBlhsNdXQqXH85EIZPo08qGqhWHmQjJpKrSZGX9BdRMfDO2E3HyLP2jGs(dbNlw5qytLgmCOTLdPZHyvO4q(CpX5uhAEiqOd4qg1KXhYi2zW4(THvZIo02F3HyLP2jGs(dbNlw5qytLgmCOTLdPZHyvO4q(CpX5uhAEiqOd4qg1KXhYi2zW4(T528YE5S2o18DQ54Dh6qM5GouUEgGEi3bCOgKZovrPI4N8un1WHa02gkbK)q4zrhkG0zfk5pK0rumjC)2WQzrhI93DiwzQDcOK)qnGhi(plFFlnCiDoud4bI)ZY33sNQ4ZjFdhYi2zW4(THvZIouBV7qSYu7eqj)HAapq8Fw((wA4q6COgWde)NLVVLovXNt(goKrSZGX9BdRMfDOT)UdXktTtaL8hQb8aX)z57BPHdPZHAapq8Fw((w6ufFo5B4qgXodg3VnSAw0HE)7oeRnTMDYFOvwVBlhs6GKSCiJQrpuShjp(C6qzDiAbXdnNY4dze7myC)2WQzrh69V7qSYu7eqj)HAapq8Fw((wA4q6COgWde)NLVVLovXNt(goKrSZGX9BdRMfDOM9UdXAtRzN8hAL172YHKoijlhYOA0df7rYJpNouwhIwq8qZPm(qgXodg3VnSAw0HA27oeRm1obuYFOgWde)NLVVLgoKohQb8aX)z57BPtv85KVHdze7myC)2WQzrhARE3HyLP2jGs(d1aEG4)S89T0WH05qnGhi(plFFlDQIpN8nCiJ2odg3VnSAw0HynV7qSYu7eqj)HAqdovAFlnCiDoudAWPs7BPtv85KVHdze7myC)2WQzrhARF3HyLP2jGs(d1aEG4)S89T0WH05qnGhi(plFFlDQIpN8nCiJyNbJ73gwnl6qnV3DiwzQDcOK)qnGhi(plFFlnCiDoud4bI)ZY33sNQ4ZjFdhYi2zW4(THvZIoe7M)DhIvMANak5pud4bI)ZY33sdhsNd1aEG4)S89T0Pk(CY3WHc9qSwn3S6HmIDgmUFBUnVSxoRTtnFNAoE3HoKzoOdLRNbOhYDahQb1eikvGjf6PHdbOTnuci)HWZIouaPZkuYFiPJOys4(THvZIo02F3HyLP2jGs(d1aaQi3bWK6BPHdPZHAaavK7ays9T0Pk(CY3WHmIDgmUFBUnVSxoRTtnFNAoE3HoKzoOdLRNbOhYDahQbp5gqCTHdbOTnuci)HWZIouaPZkuYFiPJOys4(THvZIouZE3HyLP2jGs(d1aEG4)S89T0WH05qnGhi(plFFlDQIpN8nCiJyNbJ73gwnl6qB17oeRm1obuYFOgWde)NLVVLgoKohQb8aX)z57BPtv85KVHdze7myC)2WQzrhIDwZ7oeRm1obuYFOgWde)NLVVLgoKohQb8aX)z57BPtv85KVHdz02zW4(THvZIoe7nV3DiwzQDcOK)qnGhi(plFFlnCiDoud4bI)ZY33sNQ4ZjFdhYi2zW4(THvZIouBS)UdXktTtaL8hQbaurUdGj13sdhsNd1aaQi3bWK6BPtv85KVHdze7myC)2WQzrhQTT)UdXktTtaL8hQbaurUdGj13sdhsNd1aaQi3bWK6BPtv85KVHdze7myC)2WQzrhQnwZ7oeRm1obuYFOgaqf5oaMuFlnCiDoudaOIChatQVLovXNt(goKrSZGX9BdRMfDO2263DiwzQDcOK)qnaGkYDamP(wA4q6COgaqf5oaMuFlDQIpN8nCOqpeRvZnREiJyNbJ73gwnl6qT18E3HyLP2jGs(d1aaQi3bWK6BPHdPZHAaavK7ays9T0Pk(CY3WHmIDgmUFBy1SOdT93)UdXktTtaL8hQbaurUdGj13sdhsNd1aaQi3bWK6BPtv85KVHdze7myC)2CBEzVCwBNA(o1C8UdDiZCqhkxpdqpK7aoudpasoRFOnCiaTTHsa5peEw0HciDwHs(djDeftc3VnSAw0Hy38V7qSYu7eqj)HAaavK7ays9T0WH05qnaGkYDamP(w6ufFo5B4qHEiwRMBw9qgXodg3VnSAw0Hy38V7qSYu7eqj)HAaavK7ays9T0WH05qnaGkYDamP(w6ufFo5B4qgXodg3Vn3Mx2lN12PMVtnhV7qhYmh0HY1Za0d5oGd1GcYIfsXnCiaTTHsa5peEw0HciDwHs(djDeftc3VnSAw0H2Q3DiwzQDcOK)qnOGSyH0o79T0WH05qnOGSyH0UYEFlnCiJyNbJ73gwnl6qSM3DiwzQDcOK)qnOGSyH0EB9T0WH05qnOGSyH0U2wFlnCiJyNbJ73MBZl7LZA7uZ3PMJ3DOdzMd6q56za6HChWHAyEOIanCiaTTHsa5peEw0HciDwHs(djDeftc3VnSAw0Hy)DhIvMANak5pud4bI)ZY33sdhsNd1aEG4)S89T0Pk(CY3WHc9qSwn3S6HmIDgmUFBUnn)1ZauYFi2n)HcPMtDiEIvC)2yHdi1XaSWw4hW4MCYcZ6S(H2gAn1WhMMo0lla8rYYTH1z9d5q1h87AQjMP6a63LZQjCUG4HMtjbHR2eoxYMUnSoRFOMldG0XH2AgpuBMVT2Un3gwN1peR4ikMe(D3gwN1p0loe8dX5hIvhjl9BdRZ6h6fhQ5U4MoeGKZArL)qBdTM6pC9qpa6fYz9d9qP7Hs9qj(qzH1O0dz0aoKJa4LbwpK7ao0FWycBCZzhYpvd6HMDciJNdHDeap(qP7HmnqnaOdf6HA2HY6qQd6qZdveOFByDw)qV4qBRdBe4qW5JJPouW5dBK)qpa6fYz9d9q6COhWipuwynk9qBdTM6pCTFByDw)qV4qBR7BRhsdov6HYsjaa6r73gwN1p0lo0lFFs)HGB)fV2C60CCi8tSoeBoO6qMgOga0HQrpu8hi9q6Cim0An1HIdzMjquA)2W6S(HEXHAoHtyhsq4Qn1CXWdn50HGh(ov6HKrjjUiDpK0rumj)H05qzPeaa9OI0TFByDw)qV4qMbmDiDouSpP)qSfynlMhABO1uP8qSYaOdH1qYcUFByDw)qV4qMbmDiDo0kyHo08qfbo0dihqQMo0uCthITbWYHs3dXgDizuhkKkuW5Mo08q1HylvhhkoKzMarP9BZTH1peRfdKesj)H(K7aOdjN1p0d9jMzH7h6LlL0JIpun1lCeGLle)qHuZPWhAkUP(TjKAofU)ai5S(H6SHMCjUWpRScnNIX01GMl6vZ3YCpK2dEUt3MqQ5u4(dGKZ6hQZgAcdTwtjEi92esnNc3FaKCw)qD2qtqysKkTySIfzqNfjgxXAkScgiSqofwbqsnNcFBcPMtH7pasoRFOoBOjimjsLwmwXImGhofoWcmjbKkus6OYTneDBcPMtH7pasoRFOoBOjxoHDibHREBcPMtH7pasoRFOoBOPNHnciW5JJPymDn8HCD7SLCVixp4owdjlVYERpKRB3tRPsPqoaQJ1qYYBgA72esnNc3FaKCw)qD2qtqysKkTySIfza7i8dBKxmGVyCf6awuP3MqQ5u4(dGKZ6hQZgAYtRP(dxzmDnGhiUa7iaE8BnRLr)bJBSXqQ5uDpTM6pCTldSAW8gFBcPMtH7pasoRFOoBOjSJWpSj(dxzmDnGhiUa7iaE8BnRL5m6pyCJngsnNQ7P1u)HRDzGvdM34BdRZ6hkKAofU)ai5S(H6SHM2dqgFoXyflYGBcWQqnbIsfAUigNhdyszCp4qKb2n)TH1z9dfsnNc3FaKCw)qD2qt7biJpNySIfzilX8qfbyCEmGjLX9Gdrgy)2esnNc3FaKCw)qD2qt7biJpNySIfzactI)WvHMRSyIzCEmGjLX9Gdrgaqf5oaMu)hCc)KEcGfFiqLftHCaulaurUdGj1XocGxmUIOQ0rYdnN62CBUnS(HyTyGKqk5peTtathsZfDi1bDOqQd4qj(qXEK84ZP(TjKAof2a(H4CbFKSCBcPMtHD2qtYGZfUe3buPe42esnNc7SHMcgiHoy8TjKAof2zdn5P9bciwbZuEBcPMtHnShGm(CIXkwKHIyqfQjquQq6zCEmGjLX9GdrgKZW9dBvhdTwtj80AQukutGO0oGwrwybXWdjvYZy6AWC4bI)ZY3DtI7fJR4ZhmEw4gBuod3pSvDm0AnLWtRPsPqnbIs7aAfzHfedpKuj)RYz4(HTQJhiUamAhqRilSGy4HKk5VnHuZPWoBOP9aKXNtmwXImuedQqnbIsfspJZJbmPmUhCiYGCgUFyR64bIlaJ2b0kYcligEiPsEgtxd4bI)ZY3DtI7fJR4ZhmEw4wYz4(HTQJHwRPeEAnvkfQjquAhqRilSGy4HKk5Ftod3pSvD8aXfGr7aAfzHfedpKuj)TH1z9dfsnNc7SHM2dqgFoXyflYqwI5HkcW48yatkJ7bhImyEgtxdpK290AQukutGO0Ei1CNUnHuZPWoBOP9aKXNtmwXIm8HCDfytLui9mopgWKY4EWHid7biJpN6fXGkutGOuH0Zy6AWC7biJpN6qys8hUk0CLftClZLLyEOIa3MqQ5uyNn00EaY4ZjgRyrg(qUUcSPskKEgNhdyszCp4qKb2BJX01G52dqgFo1HWK4pCvO5klM4wzjMhQiqlZ9qA3dOWJ1GZcb6HuZD62esnNc7SHM2dqgFoXyflYWhY1vGnvsH0Z48yatkJ7bhImyEgtxdMBpaz85uhctI)WvHMRSyIBLLyEOIaTEiT7bu4XAWzHa9qQ5o16d562zl5ErUEWDSgswE18TmNgCQ0(EYj3KkFNQ4Zj)TjKAof2zdnThGm(CIXkwKHpKRRaBQKcPNX5XaMug3doezW8mMUgm3EaY4ZPoeMe)HRcnxzXe3klX8qfbA9qA3dOWJ1GZcb6HuZDQ1dG2fmL(o7Dhr5fJRGje3hvln4uP99KtUjv(ovXNt(Bti1CkSZgAApaz85eJvSidFixxb2ujfspJZJbmPmUhCiYGCgUFyR6EsMRqZIP4pCTdOvKfwqm8qsL8mMUg2dqgFo1HWK4pCvO5klM4Bti1CkSZgAsgCUiKAoLGNyLXkwKbfKflKIVnHuZPWoBOjzW5IqQ5ucEIvgRyrggMspJPRbJm3EaY4ZPoeMe)HRcnxzXe36H0UNwtLsHAceL2dPM7KXn2Or7biJpN6qys8hUk0CLftCRpKRBh7iaEX4kIQshjp0CQo0tlJmNgCQ0(ZWgbe48XXuDQIpN8n24hY1T)mSraboFCmvh6XyJVnHuZPWoBOPC9WhCofJPRH)GXTCtMoubGwrw43A7Lyk93MqQ5uyNn0Km4Cri1CkbpXkJvSidZdveGrScsPAGDgtxd6WKjN6Yz4(HTc3sZf9MBcWQqnbIsfAUOBti1CkSZgAYpZIX01aGCbe2r850TjKAof2zdnjdoxesnNsWtSYyflYGC2Pkkve)KNQjgXkiLQb2zmDnGhi(plFNjy2jrw7jZbeAovJnIhi(plF3njUxmUIpFW4zHBSr8aX)z57Yz9dvSiFQHMt1yJYzNQO0ErsWWhG)2esnNc7SHMEg2iGaNpoMIX01WEaY4ZPoeMe)HRcnxzXe36d562XocGxmUIOQ0rYdnNQd9CBcPMtHD2qtpJMtXy6AWiZThGm(CQdHjXF4QqZvwmXT2dqgFo1lIbvOMarPcP)nMsFFfm0sZf9QBcWQqnbIsfAUOgBepq8Fw(oGCZI8INGhk1Apaz85uViguHAceLkK(32(wBCJnA0EaY4ZPoeMe)HRcnxzXe36d562XocGxmUIOQ0rYdnNQd9y8TjKAof2zdnjdoxesnNsWtSYyflYGAceLkWKc9CBcPMtHD2qtEAnvkfyfqft1bJPRbJmhaQi3bWK6SLCxa5XcCYm5IXvGHEiqoabgATMklMT2dqgFo1lIbvOMarPcP)1MNXn2OrpK290AQukutGO0Ei1CNA9qA3tRPsPqnbIs7aAfzHFBREjMsFFfmy8TjKAof2zdnjdox4bu4XAWzHaygtxd7biJpN6qys8hUk0CLftCl5mC)Ww1XqR1ucpTMkLc1eikTdOvKfwqm8qsL8V2wB3MqQ5uyNn0Km4CHhqHhRbNfcGzmDnyU9aKXNtDimj(dxfAUYIjULr7biJpN6fXGkutGOuH0)ABM)fn7LmhaQi3bWK6SLCxa5XcCYm5IXvGHEiqoabgATMklMgFBcPMtHD2qtpdBeqGZhhtXy6AWC7biJpN6qys8hUk0CLftCRpKRBNTK7f56b3XAiz5v2B9HCD7EAnvkfYbqDSgswEB73MqQ5uyNn00p5ewoqaMK4pRpbWmMUg(qUUD1eikT7h2Qw7biJpN6fXGkutGOuH0)AZUnHuZPWoBOPC9WhCofJPRHqQ5ojOIwjHFLDNnI9xsdovAhhsq6MsYlWdeh3Pk(CYBCRpKRBNTK7f56b3XAiz5vdBvRpKRBxnbIs7(HTQ1EaY4ZPErmOc1eikvi9V2SBti1CkSZgAkxp8bNtXy6AiKAUtcQOvs4xBR1hY1TZwY9IC9G7ynKS8QHTQ1hY1TRMarPD)Ww1Apaz85uViguHAceLkK(xBwlZbGkYDamPEUE4do3jXZOuPzWBzK50GtL2DbZsOoib2r4h2WDQIpN8n2ON(qUUDxWSeQdsGDe(HnCh6X4Bti1CkSZgAkxp8bNtXy6AiKAUtcQOvs4xBR1hY1TZwY9IC9G7ynKS8QHTQ1hY1TNRh(GZDs8mkvAg8oGwrw43ARfaQi3bWK656Hp4CNepJsLMb)2esnNc7SHMY1dFW5umMUg(qUUD2sUxKRhChRHKLxnWEBT0GtL2XdexiNYdLANQ4ZjFln4uPDxWSeQdsGDe(HnCNQ4ZjFlaurUdGj1Z1dFW5ojEgLkndERpKRBxnbIs7(HTQ1EaY4ZPErmOc1eikvi9V2SBti1CkSZgAIjixtciHlXzcfapJPRH)GXT0CrcDe(KEB7M)2esnNc7SHMWqR1uI9KtUjvEgtxd)bJBP5Ie6i8j9wBB9TjKAof2zdnHHwRPeEAnvkfQjqukJPRH)GXT0CrcDe(KEJ9MDBcPMtHD2qtoIYlgxbtiUpkgtxd4bIlWocG3qZUnHuZPWoBOjSJWpSj(dxzmDnGhiUa7ia(3AwlaurUdGj1)bNWpPNayXhcuzXuiha16d562)bNWpPNayXhcuzXuiha1b0kYc)wZUnS(HA(UhABau4XAWzHa4dfa6qbhqH30HcPM7eJhQMdve5pKohch70HWocGhFBcPMtHD2qtoIYlgxbtiUpkgtxd4bIlWocG)vdBVLrpK29ak8yn4SqGEi1CNASXhs7EAnvkfQjquApKAUtgFBcPMtHD2qtoIYlgxbtiUpkgtxd4bIlWocG)vdS36d562lsDqaXZa0G3HEAjNH7h2QUm4CHhqHhRbNfcG7aAfzHFTTxIP03xbd3MqQ5uyNn0KJO8IXvWeI7JIX01aEG4cSJa4F1a7T(qUUD2sUxKRhChRHKLxBR1EaY4ZPErmOc1eikvi9VXu67RGHwAUOxDtawfQjquQqZf9cMsFFfmCBcPMtHD2qtYGZfHuZPe8eRmwXImiNDQIsfXp5PAIrScsPAGDgtxdMto7ufL23PsDycCBy9d9Ys1XaPhcoKG0nLK)qWdehZ4HGhi(HGvqYcDOeFiScMIjboK6iQdTn0AQ)WvgpeEouQhYrGpuCihjthe4qpGCaPA62esnNc7SHMWdexGvqYcXy6AWCAWPs74qcs3usEbEG44ovXNt(BdRFi4hQ8hABO1uP8qSYai8HChWHGhi(HGDeap(qqLM8dzMjqu6HKZW9dB1Hs8HK8bthsNdbOWB62esnNc7SHM80AQ)WvgtxdFix3UNwtLsHCauhqHuBHhiUa7ia(3EFR9aKXNt9IyqfQjquQq6FTnZFBy9dTnqGSyEiZmbIspeMuOhgpe(Hk)H2gAnvkpeRmacFi3bCi4bIFiyhbWJVnHuZPWoBOjpTM6pCLX01WhY1T7P1uPuiha1bui1w4bIlWocG)T33Apaz85uViguHAceLkK(3yVTBti1CkSZgAYtRP(dxzmDn8HCD7EAnvkfYbqDafsTfEG4cSJa4F79Tm6d56290AQukKdG6ynKS8ABn2OgCQ0ooKG0nLKxGhioUtv85K34Bti1CkSZgAYtRP(dxzmDnGjv8Ncc31KaTT1I2EKTWdexGDea)BVVLrgTvVapqCb2ra8g)sHuZP6yhHFyt8hU2jgijKscnx0RpK29ak8yn4SqGoGwrw4xesnNQ7ikVyCfmH4(O6edKesjHMl6fHuZP6EAn1F4ANyGKqkj0Crg36d56290AQukKdG6ynKS8Qb2VnHuZPWoBOjpTM6pCLX01WhY1T7P1uPuiha1bui1w4bIlWocG)T33kKAUtcQOvs4xz)2esnNc7SHMWdexGvqYcDBcPMtHD2qtYGZfHuZPe8eRmwXImiNDQIsfXp5PA62W6hQ57Eitd0HKrDiMKEOFiz5q6COMDi4bIFiyhbWJp0NChaDOTbqHhRbNfcGpKCgUFyRouIpeGcVjgpuQnGp0Wsy6q6Ci8dv(dPoO1HQHTBti1CkSZgAYruEX4kycX9rXy6AapqCb2ra8VAy7T2dqgFo1lIbvOMarPcP)12AwlJ0GtL290AQukKbNNfZovXNt(gBuod3pSvDzW5cpGcpwdolea3b0kYc)Qrg1SxGhiUa7iaEJFPqQ5uDSJWpSj(dx7edKesjHMlYyNdPMt1DeLxmUcMqCFuDIbscPKqZfz8TjKAof2zdn5NzXO0KKtcnamjfBGDgtxdaYfqyhXNtT0CrV6MaSkutGOuHMl62W6hQ5CmDOTHwt9hUEO09qMgOga0HyozX8q6Ci(GPdTn0AQuEiwza0HWAizbZ4HODQou6EOuBWFi2cSshkoeEG4hc7ia((TjKAof2zdn5P1u)HRmMUg(qUUDpTMkLc5aOoGcP26d56290AQukKdG6aAfzHFJDNzk99vWWl9HCD7EAnvkfYbqDSgswUnHuZPWoBOjSJWpSj(dxVn3MqQ5u4oMpSjuqwSqk2aeMePslgRyrgWdeNtQMftba6BIrPjjNeAaysk2a7mMUg2dqgFo1)qUUcSPskK(30aWK0UpXAusABPzVWO2EjMsFFfm8s7biJpN6qys8hUk0CLftSX3MqQ5u4oMpSjuqwSqk2zdnbHjrQ0IXkwKbmu95Z4fXIuhMWkJPRH9aKXNt9pKRRaBQKcP)nnamjT7tSgLK2wAMZg12lThGm(CQdHjXF4QqZvwmXgFBcPMtH7y(WMqbzXcPyNn0eeMePslgRyrgO1JjafCXa8vusIX01WEaY4ZP(hY1vGnvsH0)MrAaysA3NynkjTT0mJDM92C2O2EP9aKXNtDimj(dxfAUYIj24BZTjKAofUlNDQIsfXp5PAYaEG4cWOmMUgWde)NLVZem7KiR9K5acnNQLr7biJpN6fXGkutGOuH0)wBMVXg3dqgFo1lIbvOMarPcP)1TBEJVnHuZPWD5StvuQi(jpvtoBOj8aXfGrzmDnGhi(plF3njUxmUIpFW4zHB9qA3tRPsPqnbIs7HuZD62esnNc3LZovrPI4N8un5SHMWdexagLX01aEG4)S8D2sUx4aQuHgsnL4wM7H0UNwtLsHAceL2dPM7uR9aKXNt9IyqfQjquQq6FL9T(2esnNc3LZovrPI4N8un5SHM8KmxHMftXF4kJstsoj0aWKuSb2zmDnSY6DAaysA3bfC1r)rQmMUgm3EaY4ZPoeMe)HRcnxzXe3cpq8Fw(oNcV4BsqmeRho1YOhs7EAnvkfQjquApKAUtTWdexGDea)BT1yJM7H0UNwtLsHAceL2dPM7uR9aKXNt9IyqfQjquQq6F99M34Bti1CkCxo7ufLkIFYt1KZgAYtYCfAwmf)HRmknj5KqdatsXgyNX01WkR3PbGjPDhuWvh9hPYy6AWC7biJpN6qys8hUk0CLftCl8aX)z57Sq7zHfZ0CL4zXSLrpK290AQukutGO0Ei1CNASrZ9qA3tRPsPqnbIs7HuZDQ1EaY4ZPErmOc1eikvi9V(EZB8TjKAofUlNDQIsfXp5PAYzdn5jzUcnlMI)WvgLMKCsObGjPydSZy6AWC7biJpN6qys8hUk0CLftClJWde)NLV7oaM0Fafja0obsc3yJgHhi(plFFF4HMCsGh(ovAlZHhi(plFNfAplSyMMReplMgBClZ9qA3tRPsPqnbIs7HuZD62esnNc3LZovrPI4N8un5SHM8KmxHMftXF4kJstsoj0aWKuSb2zmDnShGm(CQdHjXF4QqZvwmXTmYCAWPs7pdBeqGZhht1yJYz4(HTQ)mSraboFCmvhqRil8BHuZP6EsMRqZIP4pCTtmqsiLeAUiJBzo5mC)Ww1XqR1ucpTMkLc1eikTd90YOhs7EAnvkfQjquAhqRil8BBDJnkNH7h2QogATMs4P1uPuOMarPDaTISWcIHhsQK)TTBEJVnHuZPWD5StvuQi(jpvtoBOjxoHDibHRYy6Aapq8Fw(((Wdn5Kap8DQ0wFix3((Wdn5Kap8DQ0UFyRymlLaaOhvKUg(qUU99HhAYjbE47uPDONBti1CkCxo7ufLkIFYt1KZgAclhiqwmfAQoigtxd4bI)ZY3LZ6hQyr(udnNQ1dPDpTMkLc1eikThsn3PBti1CkCxo7ufLkIFYt1KZgAclhiqwmfAQoigtxdMdpq8Fw(UCw)qflYNAO5u3MqQ5u4UC2Pkkve)KNQjNn0uUEOYNftHm0aRG5XbXy6A4H0UNwtLsHAceL2dPM7ul8aXfyhbWBW83MBti1CkC3XJqbzXc2aeMePslgRyrgWz5cXfm5HpdDaybT(CADBcPMtH7oEekilwWoBOjimjsLwmwXImGZYfIlc8tcIsXcA95062CBcPMtH7dtP3WNaycWswmVnHuZPW9HP07SHM(8z8cxiGPBti1CkCFyk9oBOj3eqF(m(Bti1CkCFyk9oBOjimjsLw4BZTjKAofUppurad4bIlaJYy6Aapq8Fw(otWStIS2tMdi0CQBti1CkCFEOIaoBOPIuheq8man43MqQ5u4(8qfbC2qtmb5AsajCjotOa4VnHuZPW95Hkc4SHMWqR1uI9KtUjv(Bti1CkCFEOIaoBOjSJWpSj(dxzmDnGhiUa7ia(3Awl5mC)Ww1LbNl8ak8yn4SqaCh652esnNc3NhQiGZgAc7i8dBI)Wvgtxd7biJpN6qys8hUk0CLftCl8aXfyhbW)wZA9HCD7)Gt4N0taS4dbQSykKdG6ynKS827VnHuZPW95Hkc4SHMKbNl8ak8yn4Sqa8T52esnNc3FGaKWhRGjjuqwSGnaHjrQ0IXkwKbpGcVBciXoHXe)2esnNc3FGaKWhRGjjuqwSGD2qtqysKkTySIfzGjixcsYZhmDBcPMtH7pqas4JvWKekilwWoBOjimjsLwmwXImai8urPcaHjW(KGBti1CkC)bcqcFScMKqbzXc2zdnbHjrQ0IXkwKHaiDKkjvSilMubLQjHCa0TjKAofU)abiHpwbtsOGSyb7SHMGWKivAXyflYGCWRukyYdFg6aWcaHNk0bCBcPMtH7pqas4JvWKekilwWoBOjimjsLwmwXIm4bu4Dtaj2jmM43MqQ5u4(deGe(yfmjHcYIfSZgAcctIuPfJvSid4bIlsMvQe42esnNc3FGaKWhRGjjuqwSGD2qtqysKkTySIfzGj30JdX4kcmoxjp0CkgtxdHuZDsqfTscBG9Bti1CkC)bcqcFScMKqbzXc2zdnbHjrQ0IXkwKbFayzntj8KKfXdKciSKkjDBcPMtH7pqas4JvWKekilwWoBOjimjsLwmwXImq)PWdexSNy62esnNc3FGaKWhRGjjuqwSGD2qtqysKkTySIfzaQKoISiVGjp8zOdalWocjlCcFBUnHuZPWDfKflKInaHjrQ0IXkwKbSJWpSrEXa(IXvOdyrLYy6Aypaz85u)d56kWMkPq6FRT2UnHuZPWDfKflKID2qtqysKkTySIfzaldawmUcxqOeOcUaRG0LUnHuZPWDfKflKID2qtYGZfHuZPe8eRmwXIm44rOGSybZy6AqdovA3tRPsPqofgA9O5uDQIpN8T2dqgFo1lIbvOMarPcP)T2m)TH1peRLRljv8HuhHEife7e)qy(Wg30H05qAays6Ha02gkb0HcVp1CQGZ4HW0tacLoKJO88SyEBcPMtH7kilwif7SHMKbNlcPMtj4jwzSIfzaZh2ekilwifFBcPMtH7kilwif7SHMGWKivAXyflYWStax(WwwmfrLRqidMeJPRbJm3EaY4ZPoeMe)HRcnxzXe36H0UNwtLsHAceL2dPM7KXn2Or7biJpN6qys8hUk0CLftCRpKRBh7iaEX4kIQshjp0CQo0JX3MqQ5u4UcYIfsXoBOjimjsLwmI5JAqbzXcPSZy6AqbzXcPD27ocSactIpKRBlJmYC7biJpN6qys8hUk0CLftCRhs7EAnvkfQjquApKAUtg3yJgThGm(CQdHjXF4QqZvwmXT(qUUDSJa4fJRiQkDK8qZP6qpgB8TjKAofURGSyHuSZgAcctIuPfJy(OguqwSqABmMUguqwSqAVTUJalGWK4d562YiJm3EaY4ZPoeMe)HRcnxzXe36H0UNwtLsHAceL2dPM7KXn2Or7biJpN6qys8hUk0CLftCRpKRBh7iaEX4kIQshjp0CQo0JXgFBcPMtH7kilwif7SHMKbNlcPMtj4jwzSIfz4bcqcFScMKqbzXcMX01GMl6v3eGvHAceLk0CrT2dqgFo1)qUUcSPskK(xBZ83MBti1CkCxnbIsfysHEmuK6GaINbObNX01WEaY4ZPErmOc1eikvi9VXEZUnHuZPWD1eikvGjf6XzdnXeKRjbKWL4mHcGNX01WEaY4ZPErmOc1eikvi9VXoR5fgfsnNQJHwRPeEAnvkfQjquANyGKqkj0CrohsnNQJDe(HnXF4ANyGKqkj0Crg3Yi5mC)Ww1LbNl8ak8yn4SqaChqRil8BSZAEHrHuZP6yO1AkHNwtLsHAceL2jgijKscnxKZHuZP6yO1AkXEYj3KkFNyGKqkj0CrohsnNQJDe(HnXF4ANyGKqkj0Crg3yJpK29ak8yn4SqGoGwrw4x3dqgFo1lIbvOMarPcP35qQ5uDm0AnLWtRPsPqnbIs7edKesjHMlY4Bti1CkCxnbIsfysHEC2qtyO1AkXEYj3KkpJPRbJ2dqgFo1lIbvOMarPcP)n2B2lmkKAovhdTwtj80AQukutGO0oXajHusO5ImULrYz4(HTQldox4bu4XAWzHa4oGwrw43yVzVWOqQ5uDm0AnLWtRPsPqnbIs7edKesjHMlY5qQ5uDm0AnLyp5KBsLVtmqsiLeAUiJBSXhs7EafESgCwiqhqRil8R7biJpN6fXGkutGOuH07Ci1CQogATMs4P1uPuOMarPDIbscPKqZfzSXn2OrMdavK7aysD2sUlG8ybozMCX4kWqpeihGadTwtLfZw7biJpN6fXGkutGOuH0)67nVX3MqQ5u4UAceLkWKc94SHMKbNl8ak8yn4SqamJPRH9aKXNt9IyqfQjquQq6FJ92EHrHuZP6yO1AkHNwtLsHAceL2jgijKscnxKZHuZP6yhHFyt8hU2jgijKscnxKX3MqQ5u4UAceLkWKc94SHMWqR1ucpTMkLc1eikLX01GMl6v3eGvHAceLk0CrTm6H0UhqHhRbNfc0dPM7uRhs7EafESgCwiqhqRil8RHuZP6yO1AkHNwtLsHAceL2jgijKscnxKXTmYCAWPs7yO1AkXEYj3KkFNQ4ZjFJn(qAFp5KBsLVhsn3jJBzeEG4cSJa4ny(gB0Ohs7EafESgCwiqpKAUtTEiT7bu4XAWzHaDaTISWVfsnNQJHwRPeEAnvkfQjquANyGKqkj0CrohsnNQJDe(HnXF4ANyGKqkj0Crg3yJg9qAFp5KBsLVhsn3PwpK23to5Mu57aAfzHFlKAovhdTwtj80AQukutGO0oXajHusO5ICoKAovh7i8dBI)W1oXajHusO5ImUXgn6d562zcY1Kas4sCMqbW3HEA9HCD7mb5AsajCjotOa47aAfzHFlKAovhdTwtj80AQukutGO0oXajHusO5ICoKAovh7i8dBI)W1oXajHusO5Im2yRAvRf]] )


end
