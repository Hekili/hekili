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


    spec:RegisterPack( "Demonology", 20220315, [[d8KRhcqiQO8iuu1LukvXMKQ8jPcJIkLtrLQvPQQ4vurMfk0Tuvj7sk)sQOHrfvhJiAzsv1ZuvPMMsjDnPsSnLsX3qrjJtPu5CsLuwNQQQ3jvsuMNQkUhk1(uvLdQQQKfkvQhIIIjQukDruukBuQKi(OujHrkvsKoPujvRuPyMOOYnLkjr7Ki1pLkj1qvkvPLIIs1tb1ujsUQujr1wLkjHVQQQuJvPe7LK)syWiDyHfRkpMutMQUm0MjQpJsgnvYPf9AuKzJQBRKDl53kgUQYXvkv1YbEoIPt56GSDLQVtegpk48uH1lvssZxQk7xLvsQKsb7ddvs3VZ7VFN)Bj7stYTBRB15BNc2C8Hk4VqZuWcvWvSqf82IRPg(WYHc(lCWNWRKsbtgiGgvWW5IzuWpOKBD9s9uW(WqL0978(735)wYU0KC726wD(2OGjFOwjD)BZ2OGDLEpwQNc2JeTcEBX1udFy54O)7aWhnt3gxM9r(FNDYknxqVMEwDsYfepSCkniKToj5s35TPRYaODDuj7cJhTFN3F)3MBdZ4kkwi5)3MFDu4pKZpkZnAMA3MFD0U6I74OaupRfw(JUT4AQ3WTJ(bWFPN1lSJMYhnTJMKJMfXIYoQBd4OUcGxhe7OYd4OVHqqI7DLDu)uDyhD2rGo(okXva8KJMYh1Xa1bapAyhTlhnRJAUWJoFyHG2T5xhD7DKabhfo)Cn1rdoFKa9h9dG)spRxyh1MJ(bg9rZIyrzhDBX1uVHBTBZVo627(27rTGJLD0SmeaG(S2T5xh9FTpP)OWD)R)6kD6kok5lwhvcxyDuhduha8O1yhnEdKDuBokbATM6OXrLYbikRDB(1r7kHJexAqiBD2vXWdl54rHh(ow2r1rPrUiLpQ2vuSq)rT5Ozziaa9zIuUDB(1rLc44O2C0yFs)rLiiwwSo62IRPs9rzMbGhLyHMjs728RJkfWXrT5ORGj8OZhwi4OFGCaP54OtXDCujgathnLpQe4r1rD0qBqbN74OZhwhvI0CD04Os5aeL1uW8KyeLukycFKqyGSycnIskL0sQKsbJv84Ox1TcUIfQGjdeNJMLflba65qbRDO5OWcal0ikPLubhAlNsbtgiohnllwca0ZHcwdsdbzOG3dqgpo2EqYYcIJsl0(J(ZrTaWcTMpjwuA8ODE0UC0FDu3oA)h9FoklTVTcgo6)C09aKXJJnickEd3ewUYIf5OURmL09RKsbJv84Ox1Tco0woLcMavp(mErSqZLdIPG1G0qqgk49aKXJJThKSSG4O0cT)O)CulaSqR5tIfLgpANhTlh1PJ62r7)O)Zr3dqgpo2GiO4nCty5klwKJ6UcUIfQGjq1JpJxel0C5Gyktj9VvsPGXkEC0R6wbhAlNsbJRpham4Ib4RO0OcwdsdbzOG3dqgpo2EqYYcIJsl0(J(ZrD7OwayHwZNelknE0opAxoQ7h1PJkz)h1PJ62r7)O)Zr3dqgpo2GiO4nCty5klwKJ6UcUIfQGX1NdagCXa8vuAuzktb76tyGSyIOKsjTKkPuWyfpo6vDRGRyHkyswYqCblE4ZWgarGRhhxk4qB5ukyswYqCblE4ZWgarGRhhxktjD)kPuWyfpo6vDRGRyHkyswYqCrq(squgrGRhhxk4qB5ukyswYqCrq(squgrGRhhxktzky9SJvuMiEjpnhkPuslPskfmwXJJEv3kynineKHcMmq8xw(glWSJIS2twdiSCQgwXJJ(J27OUD09aKXJJTczWeMdquMq7p6phTFNF0(67O7biJhhBfYGjmhGOmH2F0)o6VD(rDxbhAlNsbtgiUamMYus3VskfmwXJJEv3kynineKHcMmq8xw(MCICVyKfp(qiZI0WkEC0F0Eh9dTMhxtLAH5aeL1cTL7Oco0woLcMmqCbymLPK(3kPuWyfpo6vDRG1G0qqgkyYaXFz5BsKCVWfuzcl0wQjnSIhh9hT3rD2r)qR5X1uPwyoarzTqB5oE0EhDpaz84yRqgmH5aeLj0(J(3rLC7uWH2YPuWKbIlaJPmL0BvjLcgR4XrVQBfCOTCkfSh15kSSyjEd3uWAqAiidfSZo6EaY4XXgebfVHBclxzXIC0EhLmq8xw(ghdV45qGmeRpo2WkEC0F0Eh1TJ(HwZJRPsTWCaIYAH2YD8O9okzG4cIRa4p6phT)J2xFh1zh9dTMhxtLAH5aeL1cTL74r7D09aKXJJTczWeMdquMq7p6FhDRo)OURG1o0CuybGfAeL0sQmL0DrjLcgR4XrVQBfCOTCkfSh15kSSyjEd3uWAqAiidfSZo6EaY4XXgebfVHBclxzXIC0EhLmq8xw(gt4EweXmDvrEwSAyfpo6pAVJ62r)qR5X1uPwyoarzTqB5oE0(67Oo7OFO184AQulmhGOSwOTChpAVJUhGmECSvidMWCaIYeA)r)7OB15h1DfS2HMJclaSqJOKwsLPKEBusPGXkEC0R6wbhAlNsb7rDUcllwI3WnfSgKgcYqb7SJUhGmECSbrqXB4MWYvwSihT3rD7OKbI)YY3Khal8nGcfaChbjsAyfpo6pAF9Du3okzG4VS8T9HhwYrbz47yznSIhh9hT3rD2rjde)LLVXeUNfrmtxvKNfRgwXJJ(J6(rD)O9oQZo6hAnpUMk1cZbikRfAl3rfS2HMJclaSqJOKwsLPKMzPKsbJv84Ox1Tco0woLc2J6CfwwSeVHBkynineKHcEpaz84ydIGI3WnHLRSyroAVJ62rD2rTGJL1(gjqGGKFUMQHv84O)O913r1ZW9Jev7BKabcs(5AQgaxrwKJ(ZrdTLt18OoxHLflXB4wdza1qgkSCHh19J27Oo7O6z4(rIQrGwRPeECnvQfMdquwd67O9oQBh9dTMhxtLAH5aeL1a4kYIC0Fo62D0(67O6z4(rIQrGwRPeECnvQfMdquwdGRilIaz4d1g6p6ph93o)OURG1o0CuybGfAeL0sQmL0BNskfmwXJJEv3k4qB5ukyzosCPbHSPG1G0qqgkyYaXFz5B7dpSKJcYW3XYAyfpo6pAVJ(GKLB7dpSKJcYW3XYA(rIsbNLHaa0Njszf8dswUTp8WsokidFhlRb9PmL0DnLukySIhh9QUvWAqAiidfmzG4VS8n9SEHjwOpTWYPAyfpo6pAVJ(HwZJRPsTWCaIYAH2YDubhAlNsbt0deilwclnxOYuslPZvsPGXkEC0R6wbRbPHGmuWo7OKbI)YY30Z6fMyH(0clNQHv84OxbhAlNsbt0deilwclnxOYuslPKkPuWyfpo6vDRG1G0qqgk4p0AECnvQfMdquwl0wUJhT3rjdexqCfa)rzFuNRGdTLtPGZ1hw(Syj0HfedmFUqLPmfS5aeLjiOb9PKsjTKkPuWyfpo6vDRG1G0qqgk49aKXJJTczWeMdquMq7p6phvYUOGdTLtPGl0CHaX3aSGRmL09RKsbJv84Ox1TcwdsdbzOG3dqgpo2kKbtyoarzcT)O)Cujzwh9xh1TJgAlNQrGwRPeECnvQfMdquwdza1qgkSCHh1PJgAlNQrCf(rcXB4wdza1qgkSCHh19J27OUDu9mC)ir10bNl8am8el4mHasdGRilYr)5OsYSo6VoQBhn0wovJaTwtj84AQulmhGOSgYaQHmuy5cpQthn0wovJaTwtj2tokNy5BidOgYqHLl8OoD0qB5unIRWpsiEd3AidOgYqHLl8OUF0(67OFO18am8el4mHGgaxrwKJ(3r3dqgpo2kKbtyoarzcT)OoD0qB5unc0AnLWJRPsTWCaIYAidOgYqHLl8OURGdTLtPGzbY1KauiJCwqbWRmL0)wjLcgR4XrVQBfSgKgcYqb72r3dqgpo2kKbtyoarzcT)O)Cuj7Yr)1rD7OH2YPAeO1AkHhxtLAH5aeL1qgqnKHclx4rD)O9oQBhvpd3psunDW5cpadpXcotiG0a4kYIC0FoQKD5O)6OUD0qB5unc0AnLWJRPsTWCaIYAidOgYqHLl8OoD0qB5unc0AnLyp5OCILVHmGAidfwUWJ6(r7RVJ(HwZdWWtSGZecAaCfzro6FhDpaz84yRqgmH5aeLj0(J60rdTLt1iqR1ucpUMk1cZbikRHmGAidfwUWJ6(rD)O913rD7Oo7OaOcLhalSjrYLbONiijRKlgzbb6db5aeeO1AQSy1WkEC0F0EhDpaz84yRqgmH5aeLj0(J(3r3QZpQ7k4qB5ukyc0AnLyp5OCILxzkP3QskfmwXJJEv3kynineKHcEpaz84yRqgmH5aeLj0(J(ZrLS)J(RJ62rdTLt1iqR1ucpUMk1cZbikRHmGAidfwUWJ60rdTLt1iUc)iH4nCRHmGAidfwUWJ6Uco0woLcwhCUWdWWtSGZeciktjDxusPGXkEC0R6wbRbPHGmuWwUWJ(3rLtaXeMdquMWYfE0Eh1TJ(HwZdWWtSGZecAH2YD8O9o6hAnpadpXcotiObWvKf5O)D0qB5unc0AnLWJRPsTWCaIYAidOgYqHLl8OUF0Eh1TJ6SJAbhlRrGwRPe7jhLtS8nSIhh9hTV(o6hAT9KJYjw(wOTChpQ7hT3rD7OKbIliUcG)OSpQZpAF9Du3o6hAnpadpXcotiOfAl3XJ27OFO18am8el4mHGgaxrwKJ(ZrdTLt1iqR1ucpUMk1cZbikRHmGAidfwUWJ60rdTLt1iUc)iH4nCRHmGAidfwUWJ6(r7RVJ62r)qRTNCuoXY3cTL74r7D0p0A7jhLtS8naUISih9NJgAlNQrGwRPeECnvQfMdquwdza1qgkSCHh1PJgAlNQrCf(rcXB4wdza1qgkSCHh19J2xFh1TJ(GKLBSa5AsakKrolOa4BqFhT3rFqYYnwGCnjafYiNfua8naUISih9NJgAlNQrGwRPeECnvQfMdquwdza1qgkSCHh1PJgAlNQrCf(rcXB4wdza1qgkSCHh19J6Uco0woLcMaTwtj84AQulmhGOmLPmfShLdiUPKsjTKkPuWyfpo6vDRG9irdYplNsbZSXaQHm0FuChbooQLl8OMl8OH2gWrtYrJ9i5XJJnfCOTCkfm5d5CbF0mPmL09RKsbhAlNsbRdoxiJCxqLHafmwXJJEv3ktj9VvsPGdTLtPGdgqHneIcgR4XrVQBLPKERkPuWH2YPuWECFGaIvWk1kySIhh9QUvMs6UOKsbJv84Ox1TcE(uWe0uWH2YPuW7biJhhvW7bhcvW6z4(rIQrGwRPeECnvQfMdquwdGRilIaz4d1g6vWAqAiidfSZokzG4VS8n5e5EXilE8HqMfPHv84O)O913r1ZW9JevJaTwtj84AQulmhGOSgaxrwebYWhQn0F0)oQEgUFKOAKbIlaJ1a4kYIiqg(qTHEf8EaevSqfCHmycZbiktO9ktj92OKsbJv84Ox1TcE(uWe0uWH2YPuW7biJhhvW7bhcvW6z4(rIQrgiUamwdGRilIaz4d1g6vWAqAiidfmzG4VS8n5e5EXilE8HqMfPHv84O)O9oQEgUFKOAeO1AkHhxtLAH5aeL1a4kYIiqg(qTH(J(Zr1ZW9JevJmqCbySgaxrwebYWhQn0RG3dGOIfQGlKbtyoarzcTxzkPzwkPuWyfpo6vDRGNpfmbnfCOTCkf8EaY4Xrf8EWHqf8EaY4XXwHmycZbiktO9kynineKHc2zhDpaz84ydIGI3WnHLRSyroAVJ6SJMLy(Wcbk49aiQyHk4hKSSG4O0cTxzkP3oLukySIhh9QUvWZNcMGMco0woLcEpaz84OcEp4qOcwY(vWAqAiidfSZo6EaY4XXgebfVHBclxzXIC0EhnlX8HfcoAVJ6SJ(HwZdWWtSGZecAH2YDubVharflub)GKLfehLwO9ktjDxtjLcgR4XrVQBf88PGjOPGdTLtPG3dqgpoQG3doeQGDUcwdsdbzOGD2r3dqgpo2GiO4nCty5klwKJ27OzjMpSqWr7D0p0AEagEIfCMqql0wUJhT3rFqYYnjsUxKRpsJyHMPJ(3rD(r7DuNDul4yzT9KJYjw(gwXJJEf8EaevSqf8dswwqCuAH2RmL0s6CLukySIhh9QUvWZNcMGMco0woLcEpaz84OcEp4qOc25kynineKHc2zhDpaz84ydIGI3WnHLRSyroAVJMLy(WcbhT3r)qR5by4jwWzcbTqB5oE0Eh9dG7cwAFtYMRO8IrwWcI7J6O9oQfCSS2EYr5elFdR4XrVcEpaIkwOc(bjlliokTq7vMsAjLujLcgR4XrVQBf88PGjOPGdTLtPG3dqgpoQG3doeQG1ZW9JevZJ6CfwwSeVHBnaUISicKHpuBOxbRbPHGmuW7biJhhBqeu8gUjSCLflIcEpaIkwOc(bjlliokTq7vMsAj7xjLcgR4XrVQBfCOTCkfSo4CrOTCkbpjMcMNetuXcvWgilMqJOmL0s(BLukySIhh9QUvWAqAiidfSBh1zhDpaz84ydIGI3WnHLRSyroAVJ(HwZJRPsTWCaIYAH2YD8OUF0(67OUD09aKXJJnickEd3ewUYIf5O9o6dswUrCfaVyKfrvPRKhwovd67O9oQBh1zh1coww7BKabcs(5AQgwXJJ(J2xFh9bjl3(gjqGGKFUMQb9Du3pQ7k4qB5ukyDW5IqB5ucEsmfmpjMOIfQGhwAVYusl5wvsPGXkEC0R6wbRbPHGmuWVHqoAVJkNSCzcaUISih9NJ2)r)NJYs7vWH2YPuW56JpKCkLPKwYUOKsbJv84Ox1TcwdsdbzOGTHflo20ZW9Jef5O9oQLl8O)Cu5eqmH5aeLjSCHkyIbsTPKwsfCOTCkfSo4CrOTCkbpjMcMNetuXcvWZhwiqzkPLCBusPGXkEC0R6wbRbPHGmuWaugGexXJJk4qB5uky)mlLPKwsMLskfmwXJJEv3kynineKHcMmq8xw(glWSJIS2twdiSCQgwXJJ(J2xFhLmq8xw(MCICVyKfp(qiZI0WkEC0F0(67OKbI)YY30Z6fMyH(0clNQHv84O)O913r1ZowrzTc1GHpaVcMyGuBkPLubhAlNsbRdoxeAlNsWtIPG5jXevSqfSE2XkkteVKNMdLPKwYTtjLcgR4XrVQBfSgKgcYqbVhGmECSbrqXB4MWYvwSihT3rFqYYnIRa4fJSiQkDL8WYPAqFk4qB5uk4Vrceii5NRPuMsAj7AkPuWyfpo6vDRG1G0qqgky3oQZo6EaY4XXgebfVHBclxzXIC0EhDpaz84yRqgmH5aeLj0(J(ZrzP9TvWWr7Dulx4r)7OYjGycZbikty5cpAF9DuYaXFz5Bauol0l(cEyydR4Xr)r7D09aKXJJTczWeMdquMq7p6ph93B3rD)O913rD7O7biJhhBqeu8gUjSCLflYr7D0hKSCJ4kaEXilIQsxjpSCQg03rDxbhAlNsb)nwoLYus3VZvsPGXkEC0R6wbhAlNsbRdoxeAlNsWtIPG5jXevSqfS5aeLjiOb9PmL09lPskfmwXJJEv3kynineKHc2TJ6SJcGkuEaSWMejxgGEIGKSsUyKfeOpeKdqqGwRPYIvdR4Xr)r7D09aKXJJTczWeMdquMq7p6FhTRDu3pAF9Du3o6hAnpUMk1cZbikRfAl3XJ27OFO184AQulmhGOSgaxrwKJ(Zr3MJ(phLL23wbdh1DfCOTCkfShxtLAbXayXYCPmL093VskfmwXJJEv3kynineKHcEpaz84ydIGI3WnHLRSyroAVJQNH7hjQgbATMs4X1uPwyoarznaUISicKHpuBO)O)D0(7xbhAlNsbRdox4by4jwWzcbeLPKU)FRKsbJv84Ox1TcwdsdbzOGD2r3dqgpo2GiO4nCty5klwKJ27OUD09aKXJJTczWeMdquMq7p6FhTFNF0FD0UC0)5Oo7OaOcLhalSjrYLbONiijRKlgzbb6db5aeeO1AQSy1WkEC0Fu3vWH2YPuW6GZfEagEIfCMqarzkP7FRkPuWyfpo6vDRG1G0qqgkyND09aKXJJnickEd3ewUYIf5O9o6dswUjrY9IC9rAel0mD0)oQKhT3rFqYYnpUMk1c9aWgXcnth9NJ(BfCOTCkf83ibceK8Z1uktjD)DrjLcgR4XrVQBfSgKgcYqb)GKLBMdquwZpsuhT3r3dqgpo2kKbtyoarzcT)O)D0UOGdTLtPGFjhj6bcWcfVz9qarzkP7FBusPGXkEC0R6wbRbPHGmuWH2YDuGfUsKC0)oQKh1PJ62rL8O)ZrTGJL1iHgKYPg9cYaXjnSIhh9h19J27Opiz5Mej3lY1hPrSqZ0r)J9r3MJ27Opiz5M5aeL18Je1r7D09aKXJJTczWeMdquMq7p6FhTlk4qB5uk4C9XhsoLYus3pZsjLcgR4XrVQBfSgKgcYqbhAl3rbw4krYr)7O9F0Eh9bjl3Ki5ErU(inIfAMo6FSp62C0Eh9bjl3mhGOSMFKOoAVJUhGmECSvidMWCaIYeA)r)7OD5O9oQZokaQq5bWcB56JpKChfFJHLLbVHv84O)O9oQBh1zh1cowwtgmlH5cfexHFKG0WkEC0F0(67OE8bjl3KbZsyUqbXv4hjinOVJ6Uco0woLcoxF8HKtPmL09VDkPuWyfpo6vDRG1G0qqgk4qB5okWcxjso6FhT)J27Opiz5Mej3lY1hPrSqZ0r)J9r3MJ27Opiz5wU(4dj3rX3yyzzWBaCfzro6phT)J27OaOcLhalSLRp(qYDu8ngwwg8gwXJJEfCOTCkfCU(4djNszkP7VRPKsbJv84Ox1TcwdsdbzOGFqYYnjsUxKRpsJyHMPJ(h7Jkz)hT3rTGJL1idexONYdLwdR4Xr)r7Dul4yznzWSeMluqCf(rcsdR4Xr)r7DuauHYdGf2Y1hFi5ok(gdlldEdR4Xr)r7D0hKSCZCaIYA(rI6O9o6EaY4XXwHmycZbiktO9h9VJ2ffCOTCkfCU(4djNszkP)TZvsPGXkEC0R6wbRbPHGmuWVHqoAVJA5cf2i8jE0Fo6VDUco0woLcMfixtcqHmYzbfaVYus)BjvsPGXkEC0R6wbRbPHGmuWVHqoAVJA5cf2i8jE0FoA)BNco0woLcMaTwtj2tokNy5vMs6F3VskfmwXJJEv3kynineKHc(neYr7DulxOWgHpXJ(ZrLSlk4qB5ukyc0AnLWJRPsTWCaIYuMs6F)BLukySIhh9QUvWAqAiidfmzG4cIRa4pk7J2ffCOTCkfSRO8IrwWcI7JszkP)9wvsPGXkEC0R6wbRbPHGmuWKbIliUcG)O)C0UC0EhfavO8ayHTxWrYx6rar8GavwSe6bGnSIhh9hT3rFqYYTxWrYx6rar8GavwSe6bGnaUISih9NJ2ffCOTCkfmXv4hjeVHBktj9V7IskfmwXJJEv3k4qB5ukyxr5fJSGfe3hLc2Jeni)SCkfCxx(OBladpXcotiGC0aGhn4am8ooAOTChz8O1C0cr)rT5OKyhpkXva8efSgKgcYqbtgiUG4ka(J(h7J(7J27OUD0p0AEagEIfCMqql0wUJhTV(o6hAnpUMk1cZbikRfAl3XJ6UYus)7TrjLcgR4XrVQBfSgKgcYqbtgiUG4ka(J(h7Jk5r7D0hKSCRqZfceFdWcEd67O9oQEgUFKOA6GZfEagEIfCMqaPbWvKf5O)D0(p6)CuwAFBfmOGdTLtPGDfLxmYcwqCFuktj9VzwkPuWyfpo6vDRG1G0qqgkyYaXfexbWF0)yFujpAVJ(GKLBsKCVixFKgXcnth9VJ2)r7D09aKXJJTczWeMdquMq7p6phLL23wbdhT3rTCHh9VJkNaIjmhGOmHLl8O)6OS0(2kyqbhAlNsb7kkVyKfSG4(OuMs6FVDkPuWyfpo6vDRG1G0qqgkyNDu9SJvuwBhlZLdGcMyGuBkPLubhAlNsbRdoxeAlNsWtIPG5jXevSqfSE2XkkteVKNMdLPK(3DnLukySIhh9QUvWH2YPuWKbIligizcvWEKOb5NLtPG)3P5AGSJchAqkNA0Fu4bIty8OWde)OWgizcpAsokXatXcbh1Cf1r3wCn1B4gJhLmhnTJ6kihnoQRKLleC0pqoG0COG1G0qqgkyNDul4yznsObPCQrVGmqCsdR4XrVYusVvNRKsbJv84Ox1Tco0woLc2JRPEd3uWEKOb5NLtPGH)WYF0TfxtL6JYmdajhvEahfEG4hf2va8KJcvwYpQuoarzhvpd3psuhnjhvZhcEuBokadVdfSgKgcYqb)GKLBECnvQf6bGnagA7O9okzG4cIRa4p6phDRhT3r3dqgpo2kKbtyoarzcT)O)D0(DUYusVvjvsPGXkEC0R6wbhAlNsb7X1uVHBkyps0G8ZYPuWBleilwhvkhGOSJsqd6JXJs(WYF0TfxtL6JYmdajhvEahfEG4hf2va8efSgKgcYqb)GKLBECnvQf6bGnagA7O9okzG4cIRa4p6phDRhT3r3dqgpo2kKbtyoarzcT)O)Cuj7xzkP3A)kPuWyfpo6vDRG1G0qqgk4hKSCZJRPsTqpaSbWqBhT3rjdexqCfa)r)5OB9O9oQBh9bjl384AQul0daBel0mD0)oA)hTV(oQfCSSgj0Guo1OxqgioPHv84O)OURGdTLtPG94AQ3WnLPKER)wjLcgR4XrVQBfSgKgcYqbtqt8McI0Seb9VDI()0hT3rjdexqCfa)r)5OB9O9oQBh1TJUnh9xhLmqCbXva8h19J(phn0wovJ4k8JeI3WTgYaQHmuy5cp6Fh9dTMhGHNybNje0a4kYIC0FD0qB5unxr5fJSGfe3hvdza1qgkSCHh9xhn0wovZJRPEd3AidOgYqHLl8OUF0Eh9bjl384AQul0daBel0mD0)yFujvWH2YPuWECn1B4MYusV1TQKsbJv84Ox1TcwdsdbzOGFqYYnpUMk1c9aWgadTD0EhLmqCbXva8h9NJU1J27OH2YDuGfUsKC0)oQKk4qB5ukypUM6nCtzkP3AxusPGdTLtPGjdexqmqYeQGXkEC0R6wzkP362OKsbJv84Ox1Tco0woLcwhCUi0woLGNetbZtIjQyHky9SJvuMiEjpnhktj9wzwkPuWyfpo6vDRGdTLtPGDfLxmYcwqCFukyps0G8ZYPuWDD5J6yGoQoQJYcTJ(cnth1MJ2LJcpq8Jc7kaEYrFO8aWJUTam8el4mHaYr1ZW9Je1rtYrby4DW4rtRdYrhMchh1MJs(WYFuZfUoAnsOG1G0qqgkyYaXfexbWF0)yF0FF0EhDpaz84yRqgmH5aeLj0(J(3r7VlhT3rD7OwWXYAECnvQf6GZZIvdR4Xr)r7RVJQNH7hjQMo4CHhGHNybNjeqAaCfzro6Fh1TJ62r7Yr)1rjdexqCfa)rD)O)ZrdTLt1iUc)iH4nCRHmGAidfwUWJ6(rD6OH2YPAUIYlgzbliUpQgYaQHmuy5cpQ7ktj9w3oLukySIhh9QUvWH2YPuW(zwkynineKHcgGYaK4kEC8O9oQLl8O)Du5eqmH5aeLjSCHkyTdnhfwayHgrjTKktj9w7AkPuWyfpo6vDRGdTLtPG94AQ3WnfShjAq(z5uk4UYj4r3wCn1B42rt5J6yG6aGhL1KfRJAZr5dbp62IRPs9rzMbGhLyHMjcJhf3X6OP8rtRd)rLiigE04OKbIFuIRa4BkynineKHc(bjl384AQul0daBam02r7D0hKSCZJRPsTqpaSbWvKf5O)CujpQthLL23wbdh9Fo6dswU5X1uPwOha2iwOzszkP7IZvsPGdTLtPGjUc)iH4nCtbJv84Ox1TYuMc(dG6z9ctjLsAjvsPGXkEC0R6wbhAlNsblJCHFwzfwoLc2Jeni)SCkfmZgdOgYq)rFO8aWJQN1lSJ(qwzrAh9FP14NroAn1VCfGLme)OH2YPihDkUJMcwdsdbzOGTCHh9VJ68J27Oo7OFO1cEUJktjD)kPuWH2YPuWeO1AkHmYzbfaVcgR4XrVQBLPK(3kPuWyfpo6vDRGRyHkyBwOyKfRPigyGic9uedaPTCkIco0woLc2MfkgzXAkIbgiIqpfXaqAlNIOmL0BvjLcgR4XrVQBfCflubtgogUiccQbOjmu7QYTpeQGdTLtPGjdhdxebb1a0egQDv52hcvMs6UOKsbhAlNsblZrIlniKnfmwXJJEv3ktj92OKsbJv84Ox1TcwdsdbzOGFqYYnjsUxKRpsJyHMPJ(3rL8O9o6dswU5X1uPwOha2iwOz6O)W(O9RGdTLtPG)gjqGGKFUMszkPzwkPuWyfpo6vDRGRyHkyIRWpsGEXaEIrwydyHLPGdTLtPGjUc)ib6fd4jgzHnGfwMYusVDkPuWyfpo6vDRG1G0qqgkyYaXfexbWto6phTlhT3rD7OVHqoAF9D0qB5unpUM6nCRPdIDu2h15h1DfCOTCkfShxt9gUPmL0DnLukySIhh9QUvWAqAiidfmzG4cIRa4jh9NJ2LJ27Oo7OUD03qihTV(oAOTCQMhxt9gU10bXok7J68J6Uco0woLcM4k8JeI3WnLPKwsNRKsbJv84Ox1TcE(uWe0uWH2YPuW7biJhhvW7bhcvWaOcLhalS9cos(spciIheOYILqpaSHv84O)O9okaQq5bWcBexbWlgzruv6k5HLt1WkEC0RG3dGOIfQGHiO4nCty5klweLPmf88HfcusPKwsLukySIhh9QUvWAqAiidfmzG4VS8nwGzhfzTNSgqy5unSIhh9k4qB5ukyYaXfGXuMs6(vsPGdTLtPGl0CHaX3aSGRGXkEC0R6wzkP)TskfCOTCkfmlqUMeGczKZckaEfmwXJJEv3ktj9wvsPGdTLtPGjqR1uI9KJYjwEfmwXJJEv3ktjDxusPGXkEC0R6wbRbPHGmuWKbIliUcG)O)C0UC0Ehvpd3psunDW5cpadpXcotiG0G(uWH2YPuWexHFKq8gUPmL0BJskfmwXJJEv3kynineKHcEpaz84ydIGI3WnHLRSyroAVJsgiUG4ka(J(Zr7Yr7D0hKSC7fCK8LEeqepiqLflHEayJyHMPJ(Zr3Qco0woLcM4k8JeI3WnLPKMzPKsbhAlNsbRdox4by4jwWzcbefmwXJJEv3ktzkydKftOrusPKwsLukySIhh9QUvWZNcMGMco0woLcEpaz84OcEp4qOc2TJ6SJUhGmECSbrqXB4MWYvwSihT3r)qR5X1uPwyoarzTqB5oEu3pAF9Du3o6EaY4XXgebfVHBclxzXIC0Eh9bjl3iUcGxmYIOQ0vYdlNQb9Du3vW7bquXcvWqeu8GKLfgilMqJOmL09RKsbJv84Ox1Tco0woLcMOdarmYczqyiOcUGyGugvWAqAiidfSZo6dswUr0bGigzHmimeubxqmqkJIT2G(uWvSqfmrhaIyKfYGWqqfCbXaPmQmL0)wjLcgR4XrVQBfCOTCkfmrhaIyKfYGWqqfCbXaPmQG1G0qqgk4hKSCJOdarmYczqyiOcUGyGugfBTb9D0Eh9dTMhxtLAH5aeL1cTL7OcUIfQGj6aqeJSqgegcQGligiLrLPKERkPuWyfpo6vDRGdTLtPGjUc)ib6fd4jgzHnGfwMcwdsdbzOG3dqgpo2EqYYcIJsl0(J(Zr7VFfCflubtCf(rc0lgWtmYcBalSmLPKUlkPuWyfpo6vDRGdTLtPGzbYLa188JGkynineKHcEpaz84y7bjlliokTq7p6phLzPGRyHkywGCjqnp)iOYusVnkPuWyfpo6vDRGdTLtPGzbYLa188JGkynineKHcEpaz84y7bjlliokTq7p6phLzPGRyHkywGCjqnp)iOYusZSusPGXkEC0R6wbRbPHGmuWwWXYAECnvQf6PiqRplNQHv84O)O9o6EaY4XXwHmycZbiktO9h9NJ2VZvWH2YPuW6GZfH2YPe8KykyEsmrflub76tyGSyIOmL0BNskfmwXJJEv3kyps0G8ZYPuWmBYYO2ih1Cf2rnqSJ8Js4JeChhvgmRJAUWJAbGfAhfGBFOeGhn8(0YPcoJhLGFbim8OUIYZZILco0woLcwhCUi0woLGNetbZtIjQyHkycFKqyGSycnIYus31usPGXkEC0R6wbhAlNsbp7iqMpsKflru5ke6GfQG1G0qqgk49aKXJJnickEqYYcdKftOruWvSqf8SJaz(irwSerLRqOdwOYuslPZvsPGXkEC0R6wbhAlNsbBGSycnjvWAqAiidfSbYIj0AMKnxbrarqXdsw(O9o6EaY4XXgebfpizzHbYIj0ikycFmfSbYIj0KuzkPLusLukySIhh9QUvWH2YPuWgilMqRFfSgKgcYqbBGSycTM1FZvqeqeu8GKLpAVJUhGmECSbrqXdswwyGSycnIcMWhtbBGSycT(vMsAj7xjLcgR4XrVQBfSgKgcYqbB5cp6Fhvobetyoarzclx4r7D09aKXJJThKSSG4O0cT)O)D0(DUco0woLcwhCUi0woLGNetbZtIjQyHk4piak8XkyHcdKfteLPmf8heaf(yfSqHbYIjIskL0sQKsbJv84Ox1TcUIfQG9am8Yjaf7iHGCfCOTCkfShGHxobOyhjeKRmL09RKsbJv84Ox1TcUIfQGbizQOmbajiyFsGco0woLcgGKPIYeaKGG9jbktj9VvsPGXkEC0R6wbxXcvWbq7knuBerwSWcknhc9aqfCOTCkfCa0Usd1grKflSGsZHqpauzkP3QskfmwXJJEv3k4kwOcwpKvQfS4HpdBaebajtf2auWH2YPuW6HSsTGfp8zydGiaizQWgGYus3fLukySIhh9QUvWvSqfShGHxobOyhjeKRGdTLtPG9am8Yjaf7iHGCLPKEBusPGXkEC0R6wbxXcvWKbIlswvAiqbhAlNsbtgiUizvPHaLPKMzPKsbJv84Ox1Tco0woLcMf3XNlXilccjxjpSCkfSgKgcYqbhAl3rbw4krYrzFujvWvSqfmlUJpxIrweesUsEy5uktj92PKsbJv84Ox1TcUIfQG9bGP1mLWJAMeFqgajAS0Oco0woLc2haMwZucpQzs8bzaKOXsJktjDxtjLcgR4XrVQBfCflubJVPidexSNeubhAlNsbJVPidexSNeuzkPL05kPuWyfpo6vDRGRyHkyOs7kYc9cw8WNHnaIG4k0mXrIco0woLcgQ0UISqVGfp8zydGiiUcntCKOmLPGhwAVskL0sQKsbhAlNsb)qabbmLflfmwXJJEv3ktjD)kPuWH2YPuWp(mEHmeWHcgR4XrVQBLPK(3kPuWH2YPuWYjaF8z8kySIhh9QUvMs6TQKsbhAlNsbdrqrA4IOGXkEC0R6wzktzk4DeqYPus3VZ7VFN)BNVDkyjcqLflIc(F)Vy2LURlDxX)p6rLYfE0C9na7OYd4ODq4JecdKftOr64OaC7dLa0FuYSWJgq2Scd9hv7kkwiPDByUSWJk5)pkZm1ocm0Fu4CXmhL4OSGHJU9CuBokZbfh1N7jjN6OZhccBah1ToD)OUjjdU3Unmxw4r7))hLzMAhbg6pkCUyMJsCuwWWr3EoQnhL5GIJ6Z9KKtD05dbHnGJ6wNUFu3KKb3B3gMll8O)()hLzMAhbg6pkCUyMJsCuwWWr3EoQnhL5GIJ6Z9KKtD05dbHnGJ6wNUFu3KKb3B3MBZ)(FXSlDxx6UI)F0JkLl8O56Ba2rLhWr7qp7yfLjIxYtZrhhfGBFOeG(JsMfE0aYMvyO)OAxrXcjTBdZLfEuj))rzMP2rGH(J2bzG4VS8TT0XrT5ODqgi(llFBlnSIhh9DCu3KKb3B3gMll8O9))JYmtTJad9hTdYaXFz5BBPJJAZr7Gmq8xw(2wAyfpo674OUjjdU3Unmxw4r)9)pkZm1ocm0F0oide)LLVTLooQnhTdYaXFz5BBPHv84OVJJ6MKm4E72WCzHhDR))Om74A2r)rxz9)TCuTluZ0rDRg7OXEK84XXJM1rXfepSCk3pQBsYG7TBdZLfE0T()JYmtTJad9hTdYaXFz5BBPJJAZr7Gmq8xw(2wAyfpo674OUjjdU3Unmxw4r7Y)pkZoUMD0F0vw)Flhv7c1mDu3QXoAShjpEC8OzDuCbXdlNY9J6MKm4E72WCzHhTl))OmZu7iWq)r7Gmq8xw(2w64O2C0oide)LLVTLgwXJJ(ooQBsYG7TBdZLfE0T5)hLzMAhbg6pAhKbI)YY32shh1MJ2bzG4VS8TT0WkEC03XrD73m4E72WCzHhLz9)JYmtTJad9hTdl4yzTT0XrT5ODybhlRTLgwXJJ(ooQBsYG7TBdZLfE0T7)hLzMAhbg6pAhKbI)YY32shh1MJ2bzG4VS8TT0WkEC03XrDtsgCVDByUSWJ21()rzMP2rGH(J2bzG4VS8TT0XrT5ODqgi(llFBlnSIhh9DCu3KKb3B3gMll8Os68)FuMzQDeyO)ODqgi(llFBlDCuBoAhKbI)YY32sdR4XrFhhnSJYS1vZCh1njzW92T528V)xm7s31LUR4)h9Os5cpAU(gGDu5bC0omhGOmbbnOVooka3(qja9hLml8ObKnRWq)r1UIIfsA3gMll8O)()hLzMAhbg6pAhaOcLhalSTLooQnhTdauHYdGf22sdR4XrFhh1njzW92T528V)xm7s31LUR4)h9Os5cpAU(gGDu5bC0o8OCaXTooka3(qja9hLml8ObKnRWq)r1UIIfsA3gMll8OD5)hLzMAhbg6pAhKbI)YY32shh1MJ2bzG4VS8TT0WkEC03XrDtsgCVDByUSWJUn))OmZu7iWq)r7Gmq8xw(2w64O2C0oide)LLVTLgwXJJ(ooQBsYG7TBdZLfEujzw))OmZu7iWq)r7Gmq8xw(2w64O2C0oide)LLVTLgwXJJ(ooQB)Mb3B3gMll8Os21()rzMP2rGH(J2bzG4VS8TT0XrT5ODqgi(llFBlnSIhh9DCu3KKb3B3gMll8O9l5)pkZm1ocm0F0oaqfkpawyBlDCuBoAhaOcLhalSTLgwXJJ(ooQBsYG7TBdZLfE0()9)pkZm1ocm0F0oaqfkpawyBlDCuBoAhaOcLhalSTLgwXJJ(ooQBsYG7TBdZLfE0(zw))OmZu7iWq)r7aavO8ayHTT0XrT5ODaGkuEaSW2wAyfpo674OUjjdU3Unmxw4r7F7()rzMP2rGH(J2baQq5bWcBBPJJAZr7aavO8ayHTT0WkEC03Xrd7OmBD1m3rDtsgCVDByUSWJ2Fx7)hLzMAhbg6pAhaOcLhalSTLooQnhTdauHYdGf22sdR4XrFhh1njzW92TH5Ycp6V36)pkZm1ocm0F0oaqfkpawyBlDCuBoAhaOcLhalSTLgwXJJ(ooQBsYG7TBZT5F)Vy2LURlDxX)p6rLYfE0C9na7OYd4OD8bq9SEH1Xrb42hkbO)OKzHhnGSzfg6pQ2vuSqs72WCzHhvsN))JYmtTJad9hTdauHYdGf22shh1MJ2baQq5bWcBBPHv84OVJJg2rz26QzUJ6MKm4E72WCzHhvsN))JYmtTJad9hTdauHYdGf22shh1MJ2baQq5bWcBBPHv84OVJJ6MKm4E72CB(3)lMDP76s3v8)JEuPCHhnxFdWoQ8aoAhgilMqJ0Xrb42hkbO)OKzHhnGSzfg6pQ2vuSqs72WCzHhvsN))JYmtTJad9hTddKftO1KSTLooQnhTddKftO1mjBBPJJ6MKm4E72WCzHhvsj))rzMP2rGH(J2HbYIj0A932shh1MJ2HbYIj0Aw)TT0XrDtsgCVDBUn)7)fZU0DDP7k()rpQuUWJMRVbyhvEahTJ5dle0Xrb42hkbO)OKzHhnGSzfg6pQ2vuSqs72WCzHhvY)FuMzQDeyO)ODqgi(llFBlDCuBoAhKbI)YY32sdR4XrFhhnSJYS1vZCh1njzW92T5201xFdWq)rL05hn0wo1r5jXiTBJcoGmxdqbRG)aJCYrfmZZ8hDBX1udFy54O)7aWhnt3gMN5pQlZ(i)VZozLMlOxtpRoj5cIhwoLgeYwNKCP782W8m)r7QmaAxhvYUW4r73593)T52W8m)rzgxrXcj))2W8m)r)1rH)qo)Om3OzQDByEM)O)6OD1f3XrbOEwlS8hDBX1uVHBh9dG)spRxyhnLpAAhnjhnlIfLDu3gWrDfaVoi2rLhWrFdHGe37k7O(P6Wo6SJaD8DuIRa4jhnLpQJbQdaE0WoAxoAwh1CHhD(WcbTBdZZ8h9xhD7DKabhfo)Cn1rdoFKa9h9dG)spRxyh1MJ(bg9rZIyrzhDBX1uVHBTBdZZ8h9xhD7DF79OwWXYoAwgcaqFw72W8m)r)1r)x7t6pkC3)6VUsNUIJs(I1rLWfwh1Xa1bapAn2rJ3azh1MJsGwRPoACuPCaIYA3gMN5p6VoAxjCK4sdczRZUkgEyjhpk8W3XYoQoknYfP8r1UIIf6pQnhnldbaOptKYTBdZZ8h9xhvkGJJAZrJ9j9hvIGyzX6OBlUMk1hLzgaEuIfAMiTBdZZ8h9xhvkGJJAZrxbt4rNpSqWr)a5asZXrNI74OsmaMoAkFujWJQJ6OH2Gco3XrNpSoQeP56OXrLYbikRDBUnm)rz2ya1qg6p6dLhaEu9SEHD0hYkls7O)lTg)mYrRP(LRaSKH4hn0wof5OtXD0UnH2YPiTpaQN1lmNy3PmYf(zLvy5umMYSTCH)58Eo7dTwWZD82eAlNI0(aOEwVWCIDNeO1AkXhA3MqB5uK2ha1Z6fMtS7eIGI0WfJvSq22SqXilwtrmWare6PigasB5uKBtOTCks7dG6z9cZj2DcrqrA4IXkwiBYWXWfrqqnanHHAxvU9HWBtOTCks7dG6z9cZj2DkZrIlniKTBtOTCks7dG6z9cZj2D(nsGabj)CnfJPm7hKSCtIK7f56J0iwOz6pj79GKLBECnvQf6bGnIfAM(HD)3MqB5uK2ha1Z6fMtS7eIGI0WfJvSq2exHFKa9Ib8eJSWgWcl72eAlNI0(aOEwVWCIDNECn1B4gJPmBYaXfexbWt(Pl9C7nesF9fAlNQ5X1uVHBnDqm2o39BtOTCks7dG6z9cZj2DsCf(rcXB4gJPmBYaXfexbWt(Pl9CMBVHq6RVqB5unpUM6nCRPdIX25UFByEM)OH2YPiTpaQN1lmNy35EaY4XrgRyHSLtaXeMdquMWYfY48XMGgJ7bhczlPZVnmpZF0qB5uK2ha1Z6fMtS7Cpaz84iJvSq2zjMpSqaJZhBcAmUhCiKTK3MqB5uK2ha1Z6fMtS7Cpaz84iJvSq2qeu8gUjSCLflcJZhBcAmUhCiKnaQq5bWcBVGJKV0JaI4bbQSyj0da7bGkuEaSWgXva8IrwevLUsEy5u3MBZTH5pkZgdOgYq)rXDe44OwUWJAUWJgABahnjhn2JKhpo2UnH2YPiSjFiNl4JMPBtOTCkItS7uhCUqg5UGkdb3MqB5ueNy3zWakSHqUnH2YPioXUtpUpqaXkyL6BtOTCkc79aKXJJmwXczxidMWCaIYeApJZhBcAmUhCiKTEgUFKOAeO1AkHhxtLAH5aeL1a4kYIiqg(qTHEgtz2oJmq8xw(MCICVyKfp(qiZI0xF6z4(rIQrGwRPeECnvQfMdquwdGRilIaz4d1g6)tpd3psunYaXfGXAaCfzreidFO2q)Tj0wofXj2DUhGmECKXkwi7czWeMdquMq7zC(ytqJX9GdHS1ZW9JevJmqCbySgaxrwebYWhQn0ZykZMmq8xw(MCICVyKfp(qiZI0tpd3psunc0AnLWJRPsTWCaIYAaCfzreidFO2q)p6z4(rIQrgiUamwdGRilIaz4d1g6VnmpZF0qB5ueNy35EaY4XrgRyHSZsmFyHagNp2e0yCp4qiBNZykZ(dTMhxtLAH5aeL1cTL74Tj0wofXj2DUhGmECKXkwi7hKSSG4O0cTNX5Jnbng3doeYEpaz84yRqgmH5aeLj0Egtz2oBpaz84ydIGI3WnHLRSyr65SSeZhwi42eAlNI4e7o3dqgpoYyflK9dswwqCuAH2Z48XMGgJ7bhczlz)mMYSD2EaY4XXgebfVHBclxzXI0llX8Hfc65Sp0AEagEIfCMqql0wUJ3MqB5ueNy35EaY4XrgRyHSFqYYcIJsl0EgNp2e0yCp4qiBNZykZ2z7biJhhBqeu8gUjSCLflsVSeZhwiO3hAnpadpXcotiOfAl3XEpiz5Mej3lY1hPrSqZ0FoVNZSGJL12tokNy5Byfpo6VnH2YPioXUZ9aKXJJmwXcz)GKLfehLwO9moFSjOX4EWHq2oNXuMTZ2dqgpo2GiO4nCty5klwKEzjMpSqqVp0AEagEIfCMqql0wUJ9(a4UGL23KS5kkVyKfSG4(O6zbhlRTNCuoXY3WkEC0FBcTLtrCIDN7biJhhzSIfY(bjlliokTq7zC(ytqJX9GdHS1ZW9JevZJ6CfwwSeVHBnaUISicKHpuBONXuM9EaY4XXgebfVHBclxzXICBcTLtrCIDN6GZfH2YPe8KymwXczBGSycnYTj0wofXj2DQdoxeAlNsWtIXyflK9Ws7zmLz7MZ2dqgpo2GiO4nCty5klwKEFO184AQulmhGOSwOTChDVV(CBpaz84ydIGI3WnHLRSyr69GKLBexbWlgzruv6k5HLt1G(65MZSGJL1(gjqGGKFUMQHv84OVV(EqYYTVrceii5NRPAqFU7(Tj0wofXj2DMRp(qYPymLz)gcPNCYYLja4kYI8t))dlT)2eAlNI4e7o1bNlcTLtj4jXySIfYE(WcbmsmqQn2sYykZ2gwS4ytpd3psuKEwUWFKtaXeMdquMWYfEBcTLtrCIDN(zwmMYSbOmajUIhhVnH2YPioXUtDW5IqB5ucEsmgRyHS1ZowrzI4L80CWiXaP2yljJPmBYaXFz5BSaZokYApznGWYP6RpYaXFz5BYjY9Irw84dHmlsF9rgi(llFtpRxyIf6tlSCQ(6tp7yfL1kudg(a83MqB5ueNy353ibceK8Z1umMYS3dqgpo2GiO4nCty5klwKEpiz5gXva8IrwevLUsEy5unOVBtOTCkItS78BSCkgtz2U5S9aKXJJnickEd3ewUYIfP3EaY4XXwHmycZbiktO9)Ws7BRGHEwUW)KtaXeMdquMWYf2xFKbI)YY3aOCwOx8f8WWE7biJhhBfYGjmhGOmH2)ZV3o37Rp32dqgpo2GiO4nCty5klwKEpiz5gXva8IrwevLUsEy5unOp3VnH2YPioXUtDW5IqB5ucEsmgRyHSnhGOmbbnOVBtOTCkItS70JRPsTGyaSyzUymLz7MZaqfkpawytIKldqprqswjxmYcc0hcYbiiqR1uzXQ3EaY4XXwHmycZbiktO9)11CVV(C7dTMhxtLAH5aeL1cTL7yVp0AECnvQfMdquwdGRilYpBZ)Ws7BRGb3VnH2YPioXUtDW5cpadpXcotiGWykZEpaz84ydIGI3WnHLRSyr6PNH7hjQgbATMs4X1uPwyoarznaUISicKHpuBO)V(7)2eAlNI4e7o1bNl8am8el4mHacJPmBNThGmECSbrqXB4MWYvwSi9CBpaz84yRqgmH5aeLj0()635)Ql)JZaqfkpawytIKldqprqswjxmYcc0hcYbiiqR1uzXY9BtOTCkItS78BKabcs(5Akgtz2oBpaz84ydIGI3WnHLRSyr69GKLBsKCVixFKgXcnt)jzVhKSCZJRPsTqpaSrSqZ0p)(2eAlNI4e7oFjhj6bcWcfVz9qaHXuM9dswUzoarzn)ir1Bpaz84yRqgmH5aeLj0()6YTj0wofXj2DMRp(qYPymLzhAl3rbw4krYFs6KBs(pwWXYAKqds5uJEbzG4KgwXJJE379GKLBsKCVixFKgXcnt)XEB69GKLBMdquwZpsu92dqgpo2kKbtyoarzcT)VUCBcTLtrCIDN56JpKCkgtz2H2YDuGfUsK8x)9EqYYnjsUxKRpsJyHMP)yVn9EqYYnZbikR5hjQE7biJhhBfYGjmhGOmH2)xx65mauHYdGf2Y1hFi5ok(gdlldEp3CMfCSSMmywcZfkiUc)ibPHv84OVV(84dswUjdMLWCHcIRWpsqAqFUFBcTLtrCIDN56JpKCkgtz2H2YDuGfUsK8x)9EqYYnjsUxKRpsJyHMP)yVn9EqYYTC9XhsUJIVXWYYG3a4kYI8t)9aqfkpawylxF8HK7O4BmSSm43MqB5ueNy3zU(4djNIXuM9dswUjrY9IC9rAel0m9hBj7VNfCSSgzG4c9uEO0Ayfpo67zbhlRjdMLWCHcIRWpsqAyfpo67bGkuEaSWwU(4dj3rX3yyzzW79GKLBMdquwZpsu92dqgpo2kKbtyoarzcT)VUCBcTLtrCIDNSa5AsakKrolOa4zmLz)gcPNLluyJWN4p)253MqB5ueNy3jbATMsSNCuoXYZykZ(nesplxOWgHpXF6F7UnH2YPioXUtc0AnLWJRPsTWCaIYymLz)gcPNLluyJWN4ps2LBtOTCkItS70vuEXilybX9rXykZMmqCbXva8S7YTj0wofXj2DsCf(rcXB4gJPmBYaXfexbW)tx6bGkuEaSW2l4i5l9iGiEqGklwc9aWEpiz52l4i5l9iGiEqGklwc9aWgaxrwKF6YTH5pAxx(OBladpXcotiGC0aGhn4am8ooAOTChz8O1C0cr)rT5OKyhpkXva8KBtOTCkItS70vuEXilybX9rXykZMmqCbXva8)X(39C7dTMhGHNybNje0cTL7yF99HwZJRPsTWCaIYAH2YD09BtOTCkItS70vuEXilybX9rXykZMmqCbXva8)XwYEpiz5wHMlei(gGf8g0xp9mC)ir10bNl8am8el4mHasdGRilYF9)pS0(2ky42eAlNI4e7oDfLxmYcwqCFumMYSjdexqCfa)FSLS3dswUjrY9IC9rAel0m9x)92dqgpo2kKbtyoarzcT)hwAFBfm0ZYf(NCciMWCaIYewUWFXs7BRGHBtOTCkItS7uhCUi0woLGNeJXkwiB9SJvuMiEjpnhmsmqQn2sYykZ2z6zhROS2owMlhGBdZF0)DAUgi7OWHgKYPg9hfEG4egpk8aXpkSbsMWJMKJsmWuSqWrnxrD0Tfxt9gUX4rjZrt7OUcYrJJ6kz5cbh9dKdinh3MqB5ueNy3jzG4cIbsMqgtz2oZcowwJeAqkNA0lideN0WkEC0FBy(Jc)HL)OBlUMk1hLzgasoQ8aok8aXpkSRa4jhfQSKFuPCaIYoQEgUFKOoAsoQMpe8O2CuagEh3MqB5ueNy3Phxt9gUXykZ(bjl384AQul0daBam0wpYaXfexbW)Zw7ThGmECSvidMWCaIYeA)F978BdZF0TfcKfRJkLdqu2rjOb9X4rjFy5p62IRPs9rzMbGKJkpGJcpq8Jc7kaEYTj0wofXj2D6X1uVHBmMYSFqYYnpUMk1c9aWgadT1JmqCbXva8)S1E7biJhhBfYGjmhGOmH2)JK9FBcTLtrCIDNECn1B4gJPm7hKSCZJRPsTqpaSbWqB9idexqCfa)pBTNBpiz5MhxtLAHEayJyHMP)6VV(SGJL1iHgKYPg9cYaXjnSIhh9UFBcTLtrCIDNECn1B4gJPmBcAI3uqKMLiO)Tt0)NUhzG4cIRa4)zR9CZTT5xKbIliUcG39)j0wovJ4k8JeI3WTgYaQHmuy5c)7dTMhGHNybNje0a4kYI8RqB5unxr5fJSGfe3hvdza1qgkSCH)k0wovZJRPEd3AidOgYqHLl09Epiz5MhxtLAHEayJyHMP)yl5Tj0wofXj2D6X1uVHBmMYSFqYYnpUMk1c9aWgadT1JmqCbXva8)S1EH2YDuGfUsK8NK3MqB5ueNy3jzG4cIbsMWBtOTCkItS7uhCUi0woLGNeJXkwiB9SJvuMiEjpnh3gM)ODD5J6yGoQoQJYcTJ(cnth1MJ2LJcpq8Jc7kaEYrFO8aWJUTam8el4mHaYr1ZW9Je1rtYrby4DW4rtRdYrhMchh1MJs(WYFuZfUoAnsCBcTLtrCIDNUIYlgzbliUpkgtz2KbIliUcG)p2)U3EaY4XXwHmycZbiktO9)1Fx65MfCSSMhxtLAHo48Sy1WkEC03xF6z4(rIQPdox4by4jwWzcbKgaxrwK)CZTU8lYaXfexbW7()eAlNQrCf(rcXB4wdza1qgkSCHU7uOTCQMRO8IrwWcI7JQHmGAidfwUq3VnH2YPioXUt)mlg1o0CuybGfAe2sYykZgGYaK4kECSNLl8p5eqmH5aeLjSCH3gM)ODLtWJUT4AQ3WTJMYh1Xa1bapkRjlwh1MJYhcE0TfxtL6JYmdapkXcntegpkUJ1rt5JMwh(Jkrqm8OXrjde)OexbW3UnH2YPioXUtpUM6nCJXuM9dswU5X1uPwOha2ayOTEpiz5MhxtLAHEaydGRilYps6elTVTcg(NhKSCZJRPsTqpaSrSqZ0Tj0wofXj2DsCf(rcXB42T52eAlNI0i8rcHbYIj0iSHiOinCXyflKnzG4C0SSyjaqphmQDO5OWcal0iSLKXuM9EaY4XX2dswwqCuAH2)JfawO18jXIsJBpD5xU1))Ws7BRGH)zpaz84ydIGI3WnHLRSyrC)2eAlNI0i8rcHbYIj0ioXUticksdxmwXcztGQhFgViwO5YbXymLzVhGmECS9GKLfehLwO9)ybGfAnFsSO042txCYT()N9aKXJJnickEd3ewUYIfX9BtOTCksJWhjegilMqJ4e7oHiOinCXyflKnU(CaWGlgGVIsJmMYS3dqgpo2EqYYcIJsl0(FCZcal0A(KyrPXTNU4Uts2VtU1))ShGmECSbrqXB4MWYvwSiUFBUnH2YPin9SJvuMiEjpnhSjdexagJXuMnzG4VS8nwGzhfzTNSgqy5u9CBpaz84yRqgmH5aeLj0(F635913EaY4XXwHmycZbiktO9)9BN7(Tj0wofPPNDSIYeXl5P5Wj2DsgiUamgJPmBYaXFz5BYjY9Irw84dHmlsVp0AECnvQfMdquwl0wUJ3MqB5uKME2XkkteVKNMdNy3jzG4cWymMYSjde)LLVjrY9cxqLjSqBPM0ZzFO184AQulmhGOSwOTCh7ThGmECSvidMWCaIYeA)FsUD3MqB5uKME2XkkteVKNMdNy3Ph15kSSyjEd3yu7qZrHfawOryljJPm7vw)3cal0AUWGBUAFAJXuMTZ2dqgpo2GiO4nCty5klwKEKbI)YY34y4fphcKHy9XXEU9HwZJRPsTWCaIYAH2YDShzG4cIRa4)P)(6ZzFO184AQulmhGOSwOTCh7ThGmECSvidMWCaIYeA)FB15UFBcTLtrA6zhROmr8sEAoCIDNEuNRWYIL4nCJrTdnhfwayHgHTKmMYSxz9FlaSqR5cdU5Q9Pngtz2oBpaz84ydIGI3WnHLRSyr6rgi(llFJjCplIyMUQiplw9C7dTMhxtLAH5aeL1cTL7yF95Sp0AECnvQfMdquwl0wUJ92dqgpo2kKbtyoarzcT)VT6C3VnH2YPin9SJvuMiEjpnhoXUtpQZvyzXs8gUXO2HMJclaSqJWwsgtz2oBpaz84ydIGI3WnHLRSyr65gzG4VS8n5bWcFdOqba3rqIK(6ZnYaXFz5B7dpSKJcYW3XY65mYaXFz5BmH7zreZ0vf5zXYD375Sp0AECnvQfMdquwl0wUJ3MqB5uKME2XkkteVKNMdNy3Ph15kSSyjEd3yu7qZrHfawOryljJPm79aKXJJnickEd3ewUYIfPNBoZcoww7BKabcs(5AQ(6tpd3psuTVrceii5NRPAaCfzr(j0wovZJ6CfwwSeVHBnKbudzOWYf6EpNPNH7hjQgbATMs4X1uPwyoarznOVEU9HwZJRPsTWCaIYAaCfzr(z76Rp9mC)ir1iqR1ucpUMk1cZbikRbWvKfrGm8HAd9)8BN7(Tj0wofPPNDSIYeXl5P5Wj2DkZrIlniKngtz2KbI)YY32hEyjhfKHVJL17bjl32hEyjhfKHVJL18JefJzziaa9zIuM9dswUTp8WsokidFhlRb9DBcTLtrA6zhROmr8sEAoCIDNe9abYILWsZfYykZMmq8xw(MEwVWel0Nwy5u9(qR5X1uPwyoarzTqB5oEBcTLtrA6zhROmr8sEAoCIDNe9abYILWsZfYykZ2zKbI)YY30Z6fMyH(0clN62eAlNI00ZowrzI4L80C4e7oZ1hw(Syj0HfedmFUqgtz2FO184AQulmhGOSwOTCh7rgiUG4kaE2o)2CBcTLtrAU(egilMiSHiOinCXyflKnjlziUGfp8zydGiW1JJRBtOTCksZ1NWazXeXj2DcrqrA4IXkwiBswYqCrq(squgrGRhhx3MBtOTCksByP9SFiGGaMYI1Tj0wofPnS0ENy35JpJxidbCCBcTLtrAdlT3j2DkNa8XNXFBcTLtrAdlT3j2DcrqrA4ICBUnH2YPiT5dleWMmqCbymgtz2KbI)YY3ybMDuK1EYAaHLtDBcTLtrAZhwiWj2DwO5cbIVbyb)2eAlNI0MpSqGtS7KfixtcqHmYzbfa)Tj0wofPnFyHaNy3jbATMsSNCuoXYFBcTLtrAZhwiWj2DsCf(rcXB4gJPmBYaXfexbW)tx6PNH7hjQMo4CHhGHNybNjeqAqF3MqB5uK28HfcCIDNexHFKq8gUXykZEpaz84ydIGI3WnHLRSyr6rgiUG4ka(F6sVhKSC7fCK8LEeqepiqLflHEayJyHMPF26Tj0wofPnFyHaNy3Po4CHhGHNybNjeqUn3MqB5uK2heaf(yfSqHbYIjcBicksdxmwXcz7by4Ltak2rcb53MqB5uK2heaf(yfSqHbYIjItS7eIGI0WfJvSq2aKmvuMaGeeSpj42eAlNI0(GaOWhRGfkmqwmrCIDNqeuKgUySIfYoaAxPHAJiYIfwqP5qOhaEBcTLtrAFqau4JvWcfgilMioXUticksdxmwXczRhYk1cw8WNHnaIaGKPcBa3MqB5uK2heaf(yfSqHbYIjItS7eIGI0WfJvSq2EagE5eGIDKqq(Tj0wofP9bbqHpwbluyGSyI4e7oHiOinCXyflKnzG4IKvLgcUnH2YPiTpiak8XkyHcdKfteNy3jebfPHlgRyHSzXD85smYIGqYvYdlNIXuMDOTChfyHRejSL82eAlNI0(GaOWhRGfkmqwmrCIDNqeuKgUySIfY2haMwZucpQzs8bzaKOXsJ3MqB5uK2heaf(yfSqHbYIjItS7eIGI0WfJvSq24BkYaXf7jbVnH2YPiTpiak8XkyHcdKfteNy3jebfPHlgRyHSHkTRil0lyXdFg2aicIRqZehj3MBtOTCksZazXeAe27biJhhzSIfYgIGIhKSSWazXeAeg3doeY2nNThGmECSbrqXB4MWYvwSi9(qR5X1uPwyoarzTqB5o6EF952EaY4XXgebfVHBclxzXI07bjl3iUcGxmYIOQ0vYdlNQb95(Tj0wofPzGSycnItS7eIGI0WfJvSq2eDaiIrwidcdbvWfedKYiJPmBN9GKLBeDaiIrwidcdbvWfedKYOyRnOVBtOTCksZazXeAeNy3jebfPHlgRyHSj6aqeJSqgegcQGligiLrgtz2piz5grhaIyKfYGWqqfCbXaPmk2Ad6R3hAnpUMk1cZbikRfAl3XBtOTCksZazXeAeNy3jebfPHlgRyHSjUc)ib6fd4jgzHnGfwgJPm79aKXJJThKSSG4O0cT)N(7)2eAlNI0mqwmHgXj2DcrqrA4IXkwiBwGCjqnp)iiJPm79aKXJJThKSSG4O0cT)hM1Tj0wofPzGSycnItS7eIGI0WfJvSq2Sa5sGAE(rqgtz27biJhhBpizzbXrPfA)pmRBtOTCksZazXeAeNy3Po4CrOTCkbpjgJvSq2U(egilMimMYSTGJL184AQul0trGwFwovdR4XrFV9aKXJJTczWeMdquMq7)PFNFBy(JYSjlJAJCuZvyh1aXoYpkHpsWDCuzWSoQ5cpQfawODuaU9HsaE0W7tlNk4mEuc(fGWWJ6kkpplw3MqB5uKMbYIj0ioXUtDW5IqB5ucEsmgRyHSj8rcHbYIj0i3MqB5uKMbYIj0ioXUticksdxmwXczp7iqMpsKflru5ke6GfYykZEpaz84ydIGIhKSSWazXeAKBtOTCksZazXeAeNy3jebfPHlgj8XyBGSycnjzmLzBGSycTMKnxbrarqXdswU3EaY4XXgebfpizzHbYIj0i3MqB5uKMbYIj0ioXUticksdxms4JX2azXeA9ZykZ2azXeAT(BUcIaIGIhKSCV9aKXJJnickEqYYcdKftOrUnH2YPindKftOrCIDN6GZfH2YPe8KymwXcz)bbqHpwbluyGSyIWykZ2Yf(NCciMWCaIYewUWE7biJhhBpizzbXrPfA)F978BZTj0wofPzoarzccAqFSl0CHaX3aSGZykZEpaz84yRqgmH5aeLj0(FKSl3MqB5uKM5aeLjiOb95e7ozbY1KauiJCwqbWZykZEpaz84yRqgmH5aeLj0(FKKz9l3cTLt1iqR1ucpUMk1cZbikRHmGAidfwUqNcTLt1iUc)iH4nCRHmGAidfwUq375MEgUFKOA6GZfEagEIfCMqaPbWvKf5hjzw)YTqB5unc0AnLWJRPsTWCaIYAidOgYqHLl0PqB5unc0AnLyp5OCILVHmGAidfwUqNcTLt1iUc)iH4nCRHmGAidfwUq37RVp0AEagEIfCMqqdGRilYF7biJhhBfYGjmhGOmH27uOTCQgbATMs4X1uPwyoarznKbudzOWYf6(Tj0wofPzoarzccAqFoXUtc0AnLyp5OCILNXuMTB7biJhhBfYGjmhGOmH2)JKD5xUfAlNQrGwRPeECnvQfMdquwdza1qgkSCHU3Zn9mC)ir10bNl8am8el4mHasdGRilYps2LF5wOTCQgbATMs4X1uPwyoarznKbudzOWYf6uOTCQgbATMsSNCuoXY3qgqnKHclxO7913hAnpadpXcotiObWvKf5V9aKXJJTczWeMdquMq7Dk0wovJaTwtj84AQulmhGOSgYaQHmuy5cD39(6ZnNbGkuEaSWMejxgGEIGKSsUyKfeOpeKdqqGwRPYIvV9aKXJJTczWeMdquMq7)BRo39BtOTCksZCaIYee0G(CIDN6GZfEagEIfCMqaHXuM9EaY4XXwHmycZbiktO9)iz))YTqB5unc0AnLWJRPsTWCaIYAidOgYqHLl0PqB5unIRWpsiEd3AidOgYqHLl09BtOTCksZCaIYee0G(CIDNeO1AkHhxtLAH5aeLXykZ2Yf(NCciMWCaIYewUWEU9HwZdWWtSGZecAH2YDS3hAnpadpXcotiObWvKf5VqB5unc0AnLWJRPsTWCaIYAidOgYqHLl09EU5ml4yznc0AnLyp5OCILVHv84OVV((qRTNCuoXY3cTL7O79CJmqCbXva8SDEF952hAnpadpXcotiOfAl3XEFO18am8el4mHGgaxrwKFcTLt1iqR1ucpUMk1cZbikRHmGAidfwUqNcTLt1iUc)iH4nCRHmGAidfwUq37Rp3(qRTNCuoXY3cTL7yVp0A7jhLtS8naUISi)eAlNQrGwRPeECnvQfMdquwdza1qgkSCHofAlNQrCf(rcXB4wdza1qgkSCHU3xFU9GKLBSa5AsakKrolOa4BqF9EqYYnwGCnjafYiNfua8naUISi)eAlNQrGwRPeECnvQfMdquwdza1qgkSCHofAlNQrCf(rcXB4wdza1qgkSCHU7UYuMsb]] )


end
