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

        -- M+ build; also consider whether to factor in Bloodlust.
        if not ( talent.summon_vilefiend.enabled or talent.grimoire_felguard.enabled ) then
            return 9
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


    spec:RegisterPack( "Demonology", 20220323, [[davn(cqisr9iPu4ssPuztsHpPsPrjsCkrsRskL8kvIzjfDlvkAxI6xOqdtKIJrQQLjLQNHcyAOaDnrkTnsr4BKQiJJufCovkW6ivjVJueHMNss3tj2Nsk)JuejhKufLfIc6HKQutuLcDrsviBukLI8rPuQAKsPuuNuLcALsjZukfDtsreTtLu9tsvOAOsPuyPsPu6PIyQkjUkPisTvsre8vsvunwsrAVk1FrmyQCyklwv9yunzQ6YqBgL(mkA0KkNw41QKMnj3wQ2TKFRy4QWXjfrTCqphy6exxv2Uk67KcJxLQZtkTEsvOmFrQ2psV1FVYoXBcUxV900E7PHbANbYTZaTZGP9gSteTh4o5W4xnM4oPSoUtUrSp1OgMA3jhMw1y(9k7eW8GCCNKeD9EN8FHsUH1(Vt8MG71BpnT3EAyG2zGC7TNw91)gStahiFVE7AcnXorx49yT)7epc47KBe7tnQHPwQtp3GQHFL2sNiha9IrgzgIU3pZNoJGO)uMetXHgRWii6CgPT0K0GCDux7mqtQR900E70w0w6ToRyIa9I26MuxYbQuuxBo8RzARBsD6XlLwQdI8P3XYtD3i2N6pkH6oG4n5t)Bc1fSuxiuxaOUOaIvc1LYaPoDg0ZnGqDSdK6(daGGu1Ki15N6wH6MteYTdQdOZGEa1fSuN25DlePotOU0sDrrDIoK6MdSqyM26MuxBJrdesDjXHUPOotPgnqp1DaXBYN(3eQtgQ7aoCQlkGyLqD3i2N6pkjtBDtQRTXzBdQtmfwc1fLGq47qY0w3K60ZoNWtDjm8MR12802tDGdRtDAOdlQt78UfIuxnc1z)5juNmuh417trDg1TIwOvsM26MuxBtkeOJdnwHrnjmktcfsDjJ6elH64wXrfjyPoUoRyIEQtgQlkbHW3Hqc2mT1nPUvGAPozOo7Ccp1PHbKOysD3i2Nk4uNEpqK6aIXVcY0w3K6wbQL6KH662vK6MdSqi1DaJbgIwQBkLwQtJbEL6cwQtdK64wrDgxEMsPL6MdSOoncrh1zu3kAHwjzARBsD3W(bCorQJp9dtIFOcrl1Pri6OonjVqD)xO8GmTfTLE0DK)e0tDFKDGi1XN(3eQ7JmJcKPo9mohpea1vtDtDgSZ(uuNXLyka1nLsBM2Y4smfiFar(0)MCzHrwur8tpktIPAgSls0X1stdnFGs2uXjsBzCjMcKpGiF6FtUSWi417troqH2Y4smfiFar(0)MCzHXhajHG9ML1Xfz6izyj9PacCEacFkGaFCjMcqBzCjMcKpGiF6FtUSW4dGKqWEZY64cyuOPdqaihIcrqUUk0KFiTLXLykq(aI8P)n5YcJSkeOJdnwH2Y4smfiFar(0)MCzHXJrdesaXHUPAgSl)hlBwJq5jr)aKbIXVUM(n(pw2Sh7tfCcFGygig)6QlTtBzCjMcKpGiF6FtUSW4dGKqWEZY64cqN5hnqpzGFYWsKb2XsOTmUetbYhqKp9Vjxwy0J9P(JsAgSlG5PiaDg0dwnTns5paq6PBCjMk7X(u)rjzUbKL0KkTLXLykq(aI8P)n5YcJaDMF0G8hL0myxaZtra6mOhSAABO5u(daKE6gxIPYESp1FusMBazjnPsBzCjMcKpGiF6FtUSW4Pbd7RWML1Xf2aceIOfALqKOJnNJfaknpn1dx0pn0wgxIPa5diYN(3KllmEAWW(kSzzDCjkYCGfcBohlauAEAQhUOpTLXLykq(aI8P)n5YcJNgmSVcBwwhxEaK8hLqKOhftqZ5ybGsZtt9Wf4Rq2bYeZFtHGJWJqa5)Gvumj8bInGVczhitmd0zqpzyjwvHUqzsmfTfTfTLE0DK)e0tD4jc1sDs0rQt0HuNXLbsDbG6Stlu2xHzAlJlXuGfWbQue1WVsBzCjMcCzHrUPuewuP7vccPTmUetbUSWODhjYaa0wgxIPaxwy0JNZds6gZGtBzCjMcSCAWW(kSzzDCPW7cr0cTsiCFZ5ybGsZtt9Wf(mk)OrLbVEFkIh7tfCIOfALKHy3IcqW7hixqFZGDrZG5P(r5ZSbQ8KHL8vdamDq6PZNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6xJpJYpAuzW8ue4izi2TOae8(bYf0tBzCjMcCzHXtdg2xHnlRJlfExiIwOvcH7BohlauAEAQhUWNr5hnQmyEkcCKme7wuacE)a5c6BgSlG5P(r5ZSbQ8KHL8vdamDqd(mk)OrLbVEFkIh7tfCIOfALKHy3IcqW7hixq)Q8zu(rJkdMNIahjdXUffGG3pqUGEAlJlXuGllmEAWW(kSzzDCjkYCGfcBohlauAEAQhUKMMb7Ybkzp2Nk4erl0kjBCjorAlJlXuGllmEAWW(kSzzDC5)yzjaTfNW9nNJfaknpn1dxonyyFfMl8UqeTqRec33myx08Pbd7RW8dGK)OeIe9OycAO5OiZbwiK2Y4smf4YcJNgmSVcBwwhx(pwwcqBXjCFZ5ybGsZtt9Wf9BVzWUO5tdg2xH5haj)rjej6rXe0ikYCGfcBO5duYEiAEGyQRimBCjorAlJlXuGllmEAWW(kSzzDC5)yzjaTfNW9nNJfaknpn1dxstZGDrZNgmSVcZpas(Jsis0JIjOruK5ale24aLShIMhiM6kcZgxItSX)XYM1iuEs0pazGy8RRLMgAwmfws(muiBGLpJL9vON2Y4smf4YcJNgmSVcBwwhx(pwwcqBXjCFZ5ybGsZtt9WL00myx08Pbd7RW8dGK)OeIe9OycAefzoWcHnoqj7HO5bIPUIWSXL4eBCaXtctUpRFwNvEYWsy(uERAiMcljFgkKnWYNXY(k0tBzCjMcCzHXtdg2xHnlRJl)hllbOT4eUV5CSaqP5PPE4cFgLF0OYEKhDtIIj5pkjdXUffGG3pqUG(Mb7YPbd7RW8dGK)OeIe9OycOTmUetbUSWi3ukIXLykIkasZY64IaJ6kkaAlJlXuGllmYnLIyCjMIOcG0SSoUmm5(Mb7skA(0GH9vy(bqYFucrIEumbnoqj7X(ubNiAHwjzJlXjMA6PNYPbd7RW8dGK)OeIe9OycA8FSSzGod6jdlXQk0fktIPYVJgPOzXuyj5JrdesaXHUPYyzFf6tp9)JLnFmAGqcio0nv(DKAQ0wgxIPaxwym6hQbet1myx(da0GnyQtiqSBrbwT92Ij3tBzCjMcCzHrUPueJlXuevaKML1XL5ale2eiWGll63myxKHjtfM5ZO8JgfOHeDCv2aceIOfALqKOJ0wgxIPaxwy0ptVzWUarwic0zFfsBzCjMcCzHrUPueJlXuevaKML1Xf(CILvcX(HkeTnbcm4YI(nd2fW8u)O8zMW5ejrDgmhOjXuPNoyEQFu(mBGkpzyjF1aathKE6G5P(r5Z8P)nH0rFiMetLE685elRKCHC4OgON2Y4smf4YcJhJgiKaIdDt1myxonyyFfMFaK8hLqKOhftqJ)JLnd0zqpzyjwvHUqzsmv(DqBzCjMcCzHXJrIPAgSlPO5tdg2xH5haj)rjej6rXe040GH9vyUW7cr0cTsiC)Qm5(C3U3qIoUgBabcr0cTsis0X0thmp1pkFgISrHEYHPmbBCAWW(kmx4DHiAHwjeUFvgqpKA6PNYPbd7RW8dGK)OeIe9OycA8FSSzGod6jdlXQk0fktIPYVJuPTmUetbUSWi3ukIXLykIkasZY64IOfALqaO8oOTmUetbUSWOh7tfCcqGyXu01myxsrZWxHSdKjM1iuSq0diGGzOidlb8oqymqc417tffZgNgmSVcZfExiIwOvcH7x7gKA6PNYbkzp2Nk4erl0kjBCjoXghOK9yFQGteTqRKme7wuGv1eTftUp3T7PsBzCjMcCzHrUPuepenpqm1vecAgSlNgmSVcZpas(Jsis0JIjObFgLF0OYGxVpfXJ9Pcor0cTsYqSBrbi49dKlOFT2BN2Y4smf4YcJCtPiEiAEGyQRie0myx08Pbd7RW8dGK)OeIe9OycAKYPbd7RWCH3fIOfALq4(1Apn3mTTLMHVczhitmRrOyHOhqabZqrgwc4DGWyGeWR3NkkMPsBzCjMcCzHXJrdesaXHUPAgSlA(0GH9vy(bqYFucrIEumbn(pw2SgHYtI(bideJFDn9B8FSSzp2Nk4e(aXmqm(1vzaAlJlXuGllm(dfc4ZdYej)P)riOzWU8FSSzrl0kj7hnQgNgmSVcZfExiIwOvcH7xlT0wgxIPaxwym6hQbet1myxmUeNiblShiyn9VKI(TLykSKmW4WGn4ONaMNcKXY(k0NAJ)JLnRrO8KOFaYaX4xxBrt04)yzZIwOvs2pAunonyyFfMl8UqeTqRec3VwAPTmUetbUSWy0pudiMQzWUyCjorcwypqWAT34)yzZAekpj6hGmqm(11w0en(pw2SOfALK9JgvJtdg2xH5cVlerl0kHW9RL2gAg(kKDGmXC0pudiorYXiyjHPAKIMftHLKzHtNi6qcqN5hnazSSVc9PNUh)pw2mlC6erhsa6m)Obi)osL2Y4smf4YcJr)qnGyQMb7IXL4ejyH9abR1EJ)JLnRrO8KOFaYaX4xxBrt04)yzZr)qnG4ejhJGLeMkdXUffy12BaFfYoqMyo6hQbeNi5yeSKWu0wgxIPaxwym6hQbet1myx(pw2SgHYtI(bideJFDTf9BVHykSKmyEkcFk)lKmw2xH(gIPWsYSWPteDibOZ8JgGmw2xH(gWxHSdKjMJ(HAaXjsogbljmvJ)JLnlAHwjz)Or140GH9vyUW7cr0cTsiC)APL2Y4smf4YcJmHrFcisyrfZNb9nd2L)aanKOJezi(axLbsdTLXLykWLfgbVEFkYzOq2alFZGD5paqdj6irgIpWvBxpqBzCjMcCzHrWR3NI4X(ubNiAHwjnd2L)aanKOJezi(axv)0sBzCjMcCzHrDw5jdlH5t5TQzWUaMNIa0zq)sAPTmUetbUSWiqN5hni)rjnd2fW8ueGod6xnTnGVczhitm)nfcocpcbK)dwrXKWhi24)yzZFtHGJWJqa5)Gvumj8bIzi2TOaRMwARBil1DJq08aXuxriG6misDMcIMxl1zCjoXMuxnuxHON6KH6a2jsDaDg0dOTmUetbUSWOoR8KHLW8P8w1myxaZtra6mOFTfgOrkhOK9q08aXuxry24sCIPN(bkzp2Nk4erl0kjBCjoXuPTmUetbUSWOoR8KHLW8P8w1myxaZtra6mOFTf9B8FSS5cfDiKCmqXu53rd(mk)OrL5Msr8q08aXuxriidXUffyT2BlMCFUB3PTmUetbUSWOoR8KHLW8P8w1myxaZtra6mOFTf9B8FSSzncLNe9dqgig)6AT34aLShIMhiM6kcZqSBrbwln50EHBaHirhVyCjMkdE9(uep2Nk4erl0kjZnGqKOJnoqj7HO5bIPUIWme7wuGvttoTx4gqis0XlgxIPYGxVpfXJ9Pcor0cTsYCdiej64LusZAAsLcdCtW8ueGod6tn12Y4smvgOZ8JgK)OKm3acrIo240GH9vyUW7cr0cTsiC)Qm5(C3U3qIoUgBabcr0cTsis0XBYK7ZD7oTLXLykWLfg5MsrmUetrubqAwwhx4Zjwwje7hQq02eiWGll63myx0mFoXYkjFILOtlK2sppeDZtOUeJdd2GJEQlzEkqtQlzEkQlrGXvK6ca1be4umri1j6SI6UrSp1FustQdmuxiuNodqDg1PlyQdHu3bmgyiAPTmUetbUSWiyEkcqGXvSzWUOzXuyjzGXHbBWrpbmpfiJL9vON2k5alp1DJyFQGtD69ara1XoqQlzEkQlrNb9aQ7vsOOUv0cTsOo(mk)OrrDbG64QbGuNmuhenVwAlJlXuGllm6X(u)rjnd2L)JLn7X(ubNWhiMHOXLgG5PiaDg0Vkd240GH9vyUW7cr0cTsiC)ATNgARB8bJIj1TIwOvc1bq5D0K6ahy5PUBe7tfCQtVhicOo2bsDjZtrDj6mOhqBzCjMcCzHrp2N6pkPzWU8FSSzp2Nk4e(aXmenU0ampfbOZG(vzWgNgmSVcZfExiIwOvcH7xv)2PTmUetbUSWOh7t9hL0myx(pw2Sh7tfCcFGygIgxAaMNIa0zq)QmyJu(pw2Sh7tfCcFGygig)6ATNE6IPWsYaJdd2GJEcyEkqgl7RqFQ0wgxIPaxwy0J9P(JsAgSlaui)PEGSeiSD9aP9dEdW8ueGod6xLbBKskAIBcMNIa0zqFQTLXLyQmqN5hni)rjz8oYFcsKOJRDGs2drZdetDfHzi2TOa304smvwNvEYWsy(uERY4DK)eKirhVPXLyQSh7t9hLKX7i)jirIoMAJ)JLn7X(ubNWhiMbIXVU2I(0wgxIPaxwy0J9P(JsAgSl)hlB2J9PcoHpqmdrJlnaZtra6mOFvgSHXL4ejyH9abRPpTLXLykWLfgbZtracmUI0wgxIPaxwyKBkfX4smfrfaPzzDCHpNyzLqSFOcrlT1nKL60opQJBf1XefQ7B8RuNmuxAPUK5POUeDg0dOUpYoqK6UriAEGyQRieqD8zu(rJI6ca1brZRTj1fYTaQBUAAPozOoWbwEQt0HDQRgnOTmUetbUSWOoR8KHLW8P8w1myxaZtra6mOFTfgOXPbd7RWCH3fIOfALq4(1ApTnsrmfws2J9PcoHBkvumZyzFf6tpD(mk)OrL5Msr8q08aXuxriidXUffyTusjT3empfbOZG(uBlJlXuzGoZpAq(JsY4DK)eKirht9IXLyQSoR8KHLW8P8wLX7i)jirIoMkTLXLykWLfg9Z0BY1Yvirmitual63myxGileb6SVcBirhxJnGaHiAHwjej6iTLM0aK6UrSp1Fuc1fSuN25DlePoMtumPozOo1aqQ7gX(ubN607bIuhqm(vqtQdpXI6cwQlKB9uNggqqQZOoW8uuhqNb9zAlJlXuGllm6X(u)rjnd2L)JLn7X(ubNWhiMHOXLg)hlB2J9PcoHpqmdXUffyv9VWK7ZD7EB9FSSzp2Nk4e(aXmqm(vAlJlXuGllmc0z(rdYFucTfTLXLykqgOgnicmQROawEaKec2BwwhxaZtPqrIIjb((ABY1Yvirmitual63myxonyyFfM)pwwcqBXjC)QIbzIs2haXko22L2BMs7TftUp3T7T1Pbd7RW8dGK)OeIe9OycsL2Y4smfiduJgebg1vuaxwy8bqsiyVzzDCb8QVAgpX6OOtlqAgSlNgmSVcZ)hllbOT4eUFvXGmrj7dGyfhB7s7LuAVTonyyFfMFaK8hLqKOhftqQ0wgxIPazGA0GiWOUIc4YcJpascb7nlRJly)qlenfzG(Yko2myxonyyFfM)pwwcqBXjC)QPigKjkzFaeR4yBxAt9I(TFjL2BRtdg2xH5haj)rjej6rXeKkTfTLXLykqMpNyzLqSFOcr7cyEkcCKMb7cyEQFu(mt4CIKOodMd0KyQgPCAWW(kmx4DHiAHwjeUF12tt6PFAWW(kmx4DHiAHwjeUFnginPsBzCjMcK5Zjwwje7hQq0EzHrW8ue4ind2fW8u)O8z2avEYWs(QbaMoOXbkzp2Nk4erl0kjBCjorAlJlXuGmFoXYkHy)qfI2llmcMNIahPzWUaMN6hLpRrO8eDVsiIXLGdAO5duYESpvWjIwOvs24sCInonyyFfMl8UqeTqRec3VM(6bAlJlXuGmFoXYkHy)qfI2llm6rE0njkMK)OKMCTCfsedYefWI(nd2LEu6LyqMOK1HMs0Lp4sZGDrZNgmSVcZpas(Jsis0JIjObyEQFu(Scnp5RLG3T(HcBKYbkzp2Nk4erl0kjBCjoXgG5PiaDg0VA7PNUMpqj7X(ubNiAHwjzJlXj240GH9vyUW7cr0cTsiC)AmyAsL2Y4smfiZNtSSsi2puHO9YcJEKhDtIIj5pkPjxlxHeXGmrbSOFZGDPhLEjgKjkzDOPeD5dU0myx08Pbd7RW8dGK)OeIe9OycAaMN6hLpFfpJcqMrpgQIIzJuoqj7X(ubNiAHwjzJlXjME6A(aLSh7tfCIOfALKnUeNyJtdg2xH5cVlerl0kHW9RXGPjvAlJlXuGmFoXYkHy)qfI2llm6rE0njkMK)OKMCTCfsedYefWI(nd2fnFAWW(km)ai5pkHirpkMGgPaMN6hLpZoqM4FGfsG4jcdeKE6PaMN6hLpFoktcfsaJ6elPHMbZt9JYNVINrbiZOhdvrXm1uBO5duYESpvWjIwOvs24sCI0wgxIPaz(CILvcX(HkeTxwy0J8OBsumj)rjn5A5kKigKjkGf9BgSlNgmSVcZpas(Jsis0JIjOrkAwmfws(y0aHeqCOBQ0tNpJYpAu5JrdesaXHUPYqSBrbw14smv2J8OBsumj)rjz8oYFcsKOJP2qZ8zu(rJkdE9(uep2Nk4erl0kj)oAKYbkzp2Nk4erl0kjdXUffyv9q6PZNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6xLbstQ0wgxIPaz(CILvcX(HkeTxwyKvHaDCOXknd2fW8u)O85ZrzsOqcyuNyjn(pw285OmjuibmQtSKSF0OAgLGq47qib7Y)XYMphLjHcjGrDILKFh0wgxIPaz(CILvcX(HkeTxwyeWNhmkMejeDyZGDbmp1pkFMp9VjKo6dXKyQghOK9yFQGteTqRKSXL4ePTmUetbY85elReI9dviAVSWiGppyumjsi6WMb7IMbZt9JYN5t)BcPJ(qmjMI2Y4smfiZNtSSsi2puHO9YcJr)alFumjCtmGaNdDyZGD5aLSh7tfCIOfALKnUeNydW8ueGod6xsdTfTLXLykqw3brGrDfS8aijeS3SSoUaII9PimvMpmzGac2)kStBzCjMcK1Dqeyuxbxwy8bqsiyVzzDCbef7trmWraTsaeS)vyN2I2Y4smfipm5(Lpcbi8AumPTmUetbYdtU)YcJF1mEc7dQL2Y4smfipm5(llmYgq8RMXtBzCjMcKhMC)LfgFaKec2b0w0wgxIPa55aleUaMNIahPzWUaMN6hLpZeoNijQZG5anjMI2Y4smfiphyHWllmwOOdHKJbkMI2Y4smfiphyHWllmYeg9jGiHfvmFg0tBzCjMcKNdSq4LfgbVEFkYzOq2alpTLXLykqEoWcHxwyeOZ8JgK)OKMb7cyEkcqNb9RM2g8zu(rJkZnLI4HO5bIPUIqq(DqBzCjMcKNdSq4Lfgb6m)Ob5pkPzWUCAWW(km)ai5pkHirpkMGgG5PiaDg0VAAB8FSS5VPqWr4riG8FWkkMe(aXmqm(1vzqAlJlXuG8CGfcVSWi3ukIhIMhiM6kcb0w0wgxIPa5JhejERBmrIaJ6ky5bqsiyVzzDCXdrZZgqKCIaaQOTmUetbYhpis8w3yIebg1vWLfgFaKec2BwwhxGiykRecebi8CciTLXLykq(4brI36gtKiWOUcUSW4dGKqWEZY64Ib56cb5cGeftSEHOLWhisBzCjMcKpEqK4TUXejcmQRGllm(aijeS3SSoUWhqp4eMkZhMmqabIGPmzG0wgxIPa5JhejERBmrIaJ6k4YcJpascb7nlRJlEiAE2aIKteaqfTLXLykq(4brI36gtKiWOUcUSW4dGKqWEZY64cyEksWScbH0wgxIPa5JhejERBmrIaJ6k4YcJpascb7nlRJlmvAp0rgwIbarpuMet1myxmUeNiblShiyrFAlJlXuG8XdIeV1nMirGrDfCzHXhajHG9ML1XfVbV2NPiEKFLC8eic4yXrAlJlXuG8XdIeV1nMirGrDfCzHXhajHG9ML1Xf8pfyEkYzaqAlJlXuG8XdIeV1nMirGrDfCzHXhajHG9ML1XLxX1zrHEctL5dtgiGa0z8RkeqBrBzCjMcKfyuxrbSCAWW(kSzzDC5bqY)XYseyuxrb080upCjfnFAWW(km)ai5pkHirpkMGghOK9yFQGteTqRKSXL4etn90t50GH9vy(bqYFucrIEumbn(pw2mqNb9KHLyvf6cLjXu53rQ0wgxIPazbg1vuaxwy8bqsiyVzzDCbWniGmSewOjiSmfbiWGfBgSlA()yzZaUbbKHLWcnbHLPiabgSiHbZVdAlJlXuGSaJ6kkGllm(aijeS3SSoUa4geqgwcl0eewMIaeyWInd2L)JLnd4geqgwcl0eewMIaeyWIegm)oACGs2J9Pcor0cTsYgxItK2Y4smfilWOUIc4YcJpascb7nlRJlaDMF0a9Kb(jdlrgyhlPzWUCAWW(km)FSSeG2It4(vBVDAlJlXuGSaJ6kkGllm(aijeS3SSoUWegDcYvXbaBgSlNgmSVcZ)hllbOT4eUFv9eTLXLykqwGrDffWLfgFaKec2BwwhxycJob5Q4aGnd2Ltdg2xH5)JLLa0wCc3VQEI2Y4smfilWOUIc4YcJCtPigxIPiQainlRJl6oicmQRGMb7IykSKSh7tfCcFkWRFiXuzSSVc9nonyyFfMl8UqeTqRec3VA7PH2spILf5cG6eDMqDc0orf1buJgkTuhlC6uNOdPoXGmrH6GOM8lGi1zEFiXuMQj1bWddAcsD6SYRIIjTLXLykqwGrDffWLfg5MsrmUetrubqAwwhxaQrdIaJ6kkaAlJlXuGSaJ6kkGllm(aijeS3SSoUmNiKvnAeftIvr3iCJj2myxonyyFfMFaK8FSSebg1vua0wgxIPazbg1vuaxwy8bqsiyVjqnYIaJ6kk63myxeyuxrjRFwNbipas(pw2gNgmSVcZpas(pwwIaJ6kkaAlJlXuGSaJ6kkGllm(aijeS3eOgzrGrDfL2BgSlcmQROKBpRZaKhaj)hlBJtdg2xH5haj)hllrGrDffaTLXLykqwGrDffWLfg5MsrmUetrubqAwwhxoEqK4TUXejcmQRGMb7IeDCn2aceIOfALqKOJnonyyFfM)pwwcqBXjC)ATNgAlAlJlXuGSOfALqaO8owku0HqYXaft1myxonyyFfMl8UqeTqRec3VQ(PL2Y4smfilAHwjeakVJllmYeg9jGiHfvmFg03myxonyyFfMl8UqeTqRec3VQ(6PBMIXLyQm417tr8yFQGteTqRKmEh5pbjs0XlgxIPYaDMF0G8hLKX7i)jirIoMAJu4ZO8JgvMBkfXdrZdetDfHGme7wuGv1xpDZumUetLbVEFkIh7tfCIOfALKX7i)jirIoEX4smvg869PiNHczdS8z8oYFcsKOJxmUetLb6m)Ob5pkjJ3r(tqIeDm10t)aLShIMhiM6kcZqSBrbw70GH9vyUW7cr0cTsiC)fJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJPsBzCjMcKfTqRecaL3XLfgbVEFkYzOq2alFZGDjLtdg2xH5cVlerl0kHW9RQFAVzkgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhtTrk8zu(rJkZnLI4HO5bIPUIqqgIDlkWQ6N2BMIXLyQm417tr8yFQGteTqRKmEh5pbjs0XlgxIPYGxVpf5muiBGLpJ3r(tqIeDm10t)aLShIMhiM6kcZqSBrbw70GH9vyUW7cr0cTsiC)fJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJPMA6PNIMHVczhitmRrOyHOhqabZqrgwc4DGWyGeWR3NkkMnonyyFfMl8UqeTqRec3VgdMMuPTmUetbYIwOvcbGY74YcJCtPiEiAEGyQRie0myxonyyFfMl8UqeTqRec3VQ(TFZumUetLbVEFkIh7tfCIOfALKX7i)jirIoEX4smvgOZ8JgK)OKmEh5pbjs0XuPTmUetbYIwOvcbGY74YcJGxVpfXJ9Pcor0cTsAgSls0X1ydiqiIwOvcrIo2iLduYEiAEGyQRimBCjoXghOK9q08aXuxrygIDlkWAgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhtTrkAwmfwsg869PiNHczdS8zSSVc9PN(bk5ZqHSbw(SXL4etTrkG5PiaDg0VKM0tpLduYEiAEGyQRimBCjoXghOK9q08aXuxrygIDlkWQgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhVyCjMkd0z(rdYFusgVJ8NGej6yQPNEkhOKpdfYgy5ZgxItSXbk5ZqHSbw(me7wuGvnUetLbVEFkIh7tfCIOfALKX7i)jirIoEX4smvgOZ8JgK)OKmEh5pbjs0Xutp9u(pw2mty0NaIewuX8zqF(D04)yzZmHrFcisyrfZNb9zi2TOaRACjMkdE9(uep2Nk4erl0kjJ3r(tqIeD8IXLyQmqN5hni)rjz8oYFcsKOJPM6orfabSxzNauJgebg1vua7v2RR)ELDcw2xH(nd3jL1XDcyEkfksumjW3x7oHRLRqIyqMOa2RR)oHddbHHTtonyyFfM)pwwcqBXjCp1Tk1jgKjkzFaeR4i1Xi1LwQ7Muxkux7uxBrDm5(C3UtDTf1DAWW(km)ai5pkHirpkMaQl1DIXLyQDcyEkfksumjW3x7w2R3(ELDcw2xH(nd3jL1XDc4vF1mEI1rrNwGStmUetTtaV6RMXtSok60cKDchgccdBNCAWW(km)FSSeG2It4EQBvQtmituY(aiwXrQJrQlTu3fQlfQRDQRTOUtdg2xH5haj)rjej6rXeqDPUL96mWELDcw2xH(nd3jL1XDc2p0crtrgOVSIJ7eJlXu7eSFOfIMImqFzfh3jCyiimSDYPbd7RW8)XYsaAloH7PUvPUuOoXGmrj7dGyfhPogPU0sDPsDxOo9BN6UqDPqDTtDTf1DAWW(km)ai5pkHirpkMaQl1TSLDIUdIaJ6kyVYED93RStWY(k0Vz4oPSoUtarX(ueMkZhMmqab7Ff23jgxIP2jGOyFkctL5dtgiGG9Vc7BzVE77v2jyzFf63mCNuwh3jGOyFkIbocOvcGG9Vc77eJlXu7equSpfXahb0kbqW(xH9TSLDcFoXYkHy)qfI29k711FVYobl7Rq)MH7eomeeg2obmp1pkFMjCorsuNbZbAsmvgl7Rqp11G6sH6onyyFfMl8UqeTqRec3tDRsDTNgQl90PUtdg2xH5cVlerl0kHW9u3AuhdKgQl1DIXLyQDcyEkcCKTSxV99k7eSSVc9BgUt4Wqqyy7eW8u)O8z2avEYWs(QbaMoiJL9vON6AqDhOK9yFQGteTqRKSXL4e3jgxIP2jG5PiWr2YEDgyVYobl7Rq)MH7eomeeg2obmp1pkFwJq5j6ELqeJlbhKXY(k0tDnOontDhOK9yFQGteTqRKSXL4ePUgu3Pbd7RWCH3fIOfALq4EQBnQtF9WoX4sm1obmpfboYw2RZG7v2jyzFf63mCNWHHGWW2jAM6onyyFfMFaK8hLqKOhfta11G6aZt9JYNvO5jFTe8U1puygl7Rqp11G6sH6oqj7X(ubNiAHwjzJlXjsDnOoW8ueGod6PUvPU2PU0tN60m1DGs2J9Pcor0cTsYgxItK6AqDNgmSVcZfExiIwOvcH7PU1OogmnuxQ7eJlXu7epYJUjrXK8hLSt4A5kKigKjkG966VL96PDVYobl7Rq)MH7eomeeg2orZu3Pbd7RW8dGK)OeIe9OycOUguhyEQFu(8v8mkazg9yOkkMzSSVc9uxdQlfQ7aLSh7tfCIOfALKnUeNi1LE6uNMPUduYESpvWjIwOvs24sCIuxdQ70GH9vyUW7cr0cTsiCp1Tg1XGPH6sDNyCjMAN4rE0njkMK)OKDcxlxHeXGmrbSxx)TSxxtSxzNGL9vOFZWDchgccdBNOzQ70GH9vy(bqYFucrIEumbuxdQlfQdmp1pkFMDGmX)alKaXtegiiJL9vON6spDQlfQdmp1pkF(CuMekKag1jwsgl7Rqp11G60m1bMN6hLpFfpJcqMrpgQIIzgl7Rqp1Lk1Lk11G60m1DGs2J9Pcor0cTsYgxItCNyCjMAN4rE0njkMK)OKDcxlxHeXGmrbSxx)TSxxpTxzNGL9vOFZWDchgccdBNCAWW(km)ai5pkHirpkMaQRb1Lc1PzQtmfws(y0aHeqCOBQmw2xHEQl90Po(mk)OrLpgnqibeh6MkdXUffG6wL6mUetL9ip6MeftYFusgVJ8NGej6i1Lk11G60m1XNr5hnQm417tr8yFQGteTqRK87G6AqDPqDhOK9yFQGteTqRKme7wuaQBvQtpqDPNo1XNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6PUvPoginuxQ7eJlXu7epYJUjrXK8hLSt4A5kKigKjkG966VL966H9k7KOeecFhcjy3j)hlB(CuMekKag1jws(DStWY(k0Vz4oX4sm1oHvHaDCOXk7eomeeg2obmp1pkF(CuMekKag1jwsgl7Rqp11G6(pw285OmjuibmQtSKSF0O2YE9BWELDcw2xH(nd3jCyiimSDcyEQFu(mF6FtiD0hIjXuzSSVc9uxdQ7aLSh7tfCIOfALKnUeN4oX4sm1obWNhmkMejeD4w2RRFA2RStWY(k0Vz4oHddbHHTt0m1bMN6hLpZN(3esh9Hysmvgl7Rq)oX4sm1obWNhmkMejeD4w2RRV(7v2jyzFf63mCNWHHGWW2jhOK9yFQGteTqRKSXL4ePUguhyEkcqNb9u3c1LMDIXLyQDs0pWYhftc3ediW5qhULTSteTqRecaL3XEL966VxzNGL9vOFZWDchgccdBNCAWW(kmx4DHiAHwjeUN6wL60pT7eJlXu7KcfDiKCmqXuBzVE77v2jyzFf63mCNWHHGWW2jNgmSVcZfExiIwOvcH7PUvPo91tu3nPUuOoJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJu3fQZ4smvgOZ8JgK)OKmEh5pbjs0rQlvQRb1Lc1XNr5hnQm3ukIhIMhiM6kcbzi2TOau3QuN(6jQ7MuxkuNXLyQm417tr8yFQGteTqRKmEh5pbjs0rQ7c1zCjMkdE9(uKZqHSbw(mEh5pbjs0rQ7c1zCjMkd0z(rdYFusgVJ8NGej6i1Lk1LE6u3bkzpenpqm1veMHy3IcqDRrDNgmSVcZfExiIwOvcH7PUluNXLyQm417tr8yFQGteTqRKmEh5pbjs0rQl1DIXLyQDcty0NaIewuX8zq)w2RZa7v2jyzFf63mCNWHHGWW2jPqDNgmSVcZfExiIwOvcH7PUvPo9tl1DtQlfQZ4smvg869PiESpvWjIwOvsgVJ8NGej6i1Lk11G6sH64ZO8JgvMBkfXdrZdetDfHGme7wuaQBvQt)0sD3K6sH6mUetLbVEFkIh7tfCIOfALKX7i)jirIosDxOoJlXuzWR3NICgkKnWYNX7i)jirIosDPsDPNo1DGs2drZdetDfHzi2TOau3Au3Pbd7RWCH3fIOfALq4EQ7c1zCjMkdE9(uep2Nk4erl0kjJ3r(tqIeDK6sL6sL6spDQlfQtZuh8vi7azIzncfle9aciygkYWsaVdegdKaE9(urXmJL9vON6AqDNgmSVcZfExiIwOvcH7PU1OogmnuxQ7eJlXu7eWR3NICgkKnWYVL96m4ELDcw2xH(nd3jCyiimSDYPbd7RWCH3fIOfALq4EQBvQt)2PUBsDPqDgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhPUluNXLyQmqN5hni)rjz8oYFcsKOJuxQ7eJlXu7eUPuepenpqm1vec2YE90UxzNGL9vOFZWDchgccdBNirhPU1Oo2aceIOfALqKOJuxdQlfQ7aLShIMhiM6kcZgxItK6AqDhOK9q08aXuxrygIDlka1Tg1zCjMkdE9(uep2Nk4erl0kjJ3r(tqIeDK6sL6AqDPqDAM6etHLKbVEFkYzOq2alFgl7Rqp1LE6u3bk5ZqHSbw(SXL4ePUuPUguxkuhyEkcqNb9u3c1LgQl90PUuOUduYEiAEGyQRimBCjorQRb1DGs2drZdetDfHzi2TOau3QuNXLyQm417tr8yFQGteTqRKmEh5pbjs0rQ7c1zCjMkd0z(rdYFusgVJ8NGej6i1Lk1LE6uxku3bk5ZqHSbw(SXL4ePUgu3bk5ZqHSbw(me7wuaQBvQZ4smvg869PiESpvWjIwOvsgVJ8NGej6i1DH6mUetLb6m)Ob5pkjJ3r(tqIeDK6sL6spDQlfQ7)yzZmHrFcisyrfZNb953b11G6(pw2mty0NaIewuX8zqFgIDlka1Tk1zCjMkdE9(uep2Nk4erl0kjJ3r(tqIeDK6UqDgxIPYaDMF0G8hLKX7i)jirIosDPsDPUtmUetTtaVEFkIh7tfCIOfALSLTSt8iR9uYEL966VxzNGL9vOFZWDIhbCyCiXu7e9O7i)jON6WteQL6KOJuNOdPoJldK6ca1zNwOSVcZ7eJlXu7eWbQue1WVUL96TVxzNyCjMANWnLIWIkDVsq4obl7Rq)MHBzVodSxzNyCjMANy3rImaWobl7Rq)MHBzVodUxzNyCjMAN4XZ5bjDJzW3jyzFf63mCl71t7ELDcw2xH(nd3jZXobGYoX4sm1o50GH9v4o50upCNWNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c63jNgKuwh3jfExiIwOvcH73jCyiimSDIMPoW8u)O8z2avEYWs(QbaMoiJL9vON6spDQJpJYpAuzWR3NI4X(ubNiAHwjzi2TOae8(bYf0tDRrD8zu(rJkdMNIahjdXUffGG3pqUG(TSxxtSxzNGL9vOFZWDYCStaOStmUetTtonyyFfUton1d3j8zu(rJkdMNIahjdXUffGG3pqUG(DYPbjL1XDsH3fIOfALq4(DchgccdBNaMN6hLpZgOYtgwYxnaW0bzSSVc9uxdQJpJYpAuzWR3NI4X(ubNiAHwjzi2TOae8(bYf0tDRsD8zu(rJkdMNIahjdXUffGG3pqUG(TSxxpTxzNGL9vOFZWDYCStaOStmUetTtonyyFfUton1d3jNgmSVcZfExiIwOvcH73jNgKuwh3j)hllbOT4eUFNWHHGWW2jAM6onyyFfMFaK8hLqKOhfta11G60m1ffzoWcHBzVUEyVYobl7Rq)MH7K5yNaqzNyCjMANCAWW(kCNCAQhUt0V9DYPbjL1XDY)XYsaAloH73jCyiimSDIMPUtdg2xH5haj)rjej6rXeqDnOUOiZbwiK6AqDAM6oqj7HO5bIPUIWSXL4e3YE9BWELDcw2xH(nd3jZXobGYoX4sm1o50GH9v4o50upCNKMDYPbjL1XDY)XYsaAloH73jCyiimSDIMPUtdg2xH5haj)rjej6rXeqDnOUOiZbwiK6AqDhOK9q08aXuxry24sCIuxdQ7)yzZAekpj6hGmqm(vQBnQlnuxdQtZuNykSK8zOq2alFgl7Rq)w2RRFA2RStWY(k0Vz4ozo2jau2jgxIP2jNgmSVc3jNM6H7K0StoniPSoUt(pwwcqBXjC)oHddbHHTt0m1DAWW(km)ai5pkHirpkMaQRb1ffzoWcHuxdQ7aLShIMhiM6kcZgxItK6AqDhq8KWK7Z6N1zLNmSeMpL3kQRb1jMcljFgkKnWYNXY(k0VL966R)ELDcw2xH(nd3jZXobGYoX4sm1o50GH9v4o50upCNWNr5hnQSh5r3KOys(JsYqSBrbi49dKlOFNCAqszDCN8FSSeG2It4(DchgccdBNCAWW(km)ai5pkHirpkMGTSxx)23RStWY(k0Vz4oX4sm1oHBkfX4smfrfazNOcGqkRJ7ebg1vuaBzVU(mWELDcw2xH(nd3jgxIP2jCtPigxIPiQai7eomeeg2ojfQtZu3Pbd7RW8dGK)OeIe9OycOUgu3bkzp2Nk4erl0kjBCjorQlvQl90PUuOUtdg2xH5haj)rjej6rXeqDnOU)JLnd0zqpzyjwvHUqzsmv(DqDnOUuOontDIPWsYhJgiKaIdDtLXY(k0tDPNo19FSS5JrdesaXHUPYVdQlvQl1DIkacPSoUtgMC)w2RRpdUxzNGL9vOFZWDchgccdBN8haG6AqDSbtDcbIDlka1Tk11o11wuhtUFNyCjMANe9d1aIP2YED9t7ELDcw2xH(nd3jCyiimSDImmzQWmFgLF0OauxdQtIosDRsDSbeierl0kHirh3jabgCzVU(7eJlXu7eUPueJlXuevaKDIkacPSoUtMdSq4w2RRVMyVYobl7Rq)MH7eomeeg2obISqeOZ(kCNyCjMAN4NPVL966RN2RStWY(k0Vz4oHddbHHTtaZt9JYNzcNtKe1zWCGMetLXY(k0tDPNo1bMN6hLpZgOYtgwYxnaW0bzSSVc9ux6PtDG5P(r5Z8P)nH0rFiMetLXY(k0tDPNo1XNtSSsYfYHJAG(DcqGbx2RR)oX4sm1oHBkfX4smfrfazNOcGqkRJ7e(CILvcX(HkeTBzVU(6H9k7eSSVc9BgUt4Wqqyy7Ktdg2xH5haj)rjej6rXeqDnOU)JLnd0zqpzyjwvHUqzsmv(DStmUetTtognqibeh6MAl711)gSxzNGL9vOFZWDchgccdBNKc1PzQ70GH9vy(bqYFucrIEumbuxdQ70GH9vyUW7cr0cTsiCp1Tk1XK7ZD7o11G6KOJu3AuhBabcr0cTsis0rQl90PoW8u)O8ziYgf6jhMYemJL9vON6AqDNgmSVcZfExiIwOvcH7PUvPogqpqDPsDPNo1Lc1DAWW(km)ai5pkHirpkMaQRb19FSSzGod6jdlXQk0fktIPYVdQl1DIXLyQDYXiXuBzVE7PzVYobl7Rq)MH7eJlXu7eUPueJlXuevaKDIkacPSoUteTqRecaL3Xw2R3U(7v2jyzFf63mCNWHHGWW2jPqDAM6GVczhitmRrOyHOhqabZqrgwc4DGWyGeWR3NkkMzSSVc9uxdQ70GH9vyUW7cr0cTsiCp1Tg1DdOUuPU0tN6sH6oqj7X(ubNiAHwjzJlXjsDnOUduYESpvWjIwOvsgIDlka1Tk1PjOU2I6yY95UDN6sDNyCjMAN4X(ubNaeiwmfDBzVE7TVxzNGL9vOFZWDchgccdBNCAWW(km)ai5pkHirpkMaQRb1XNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6PU1OU2BFNyCjMANWnLI4HO5bIPUIqWw2R3odSxzNGL9vOFZWDchgccdBNOzQ70GH9vy(bqYFucrIEumbuxdQlfQ70GH9vyUW7cr0cTsiCp1Tg11EAOUBsDPL6AlQtZuh8vi7azIzncfle9aciygkYWsaVdegdKaE9(urXmJL9vON6sDNyCjMANWnLI4HO5bIPUIqWw2R3odUxzNGL9vOFZWDchgccdBNOzQ70GH9vy(bqYFucrIEumbuxdQ7)yzZAekpj6hGmqm(vQBnQtFQRb19FSSzp2Nk4e(aXmqm(vQBvQJb2jgxIP2jhJgiKaIdDtTL96TN29k7eSSVc9BgUt4Wqqyy7K)JLnlAHwjz)OrrDnOUtdg2xH5cVlerl0kHW9u3AuxA3jgxIP2j)qHa(8GmrYF6Fec2YE921e7v2jyzFf63mCNWHHGWW2jgxItKGf2deqDRrD6tDxOUuOo9PU2I6etHLKbghgSbh9eW8uGmw2xHEQlvQRb19FSSzncLNe9dqgig)k1T2c1PjOUgu3)XYMfTqRKSF0OOUgu3Pbd7RWCH3fIOfALq4EQBnQlT7eJlXu7KOFOgqm1w2R3UEAVYobl7Rq)MH7eomeeg2oX4sCIeSWEGaQBnQRDQRb19FSSzncLNe9dqgig)k1T2c1PjOUgu3)XYMfTqRKSF0OOUgu3Pbd7RWCH3fIOfALq4EQBnQlTuxdQtZuh8vi7azI5OFOgqCIKJrWsctLXY(k0tDnOUuOontDIPWsYSWPteDibOZ8JgGmw2xHEQl90Pop(FSSzw40jIoKa0z(rdq(DqDPUtmUetTtI(HAaXuBzVE76H9k7eSSVc9BgUt4Wqqyy7eJlXjsWc7bcOU1OU2PUgu3)XYM1iuEs0pazGy8Ru3AluNMG6AqD)hlBo6hQbeNi5yeSKWuzi2TOau3Qux7uxdQd(kKDGmXC0pudiorYXiyjHPYyzFf63jgxIP2jr)qnGyQTSxV9BWELDcw2xH(nd3jCyiimSDY)XYM1iuEs0pazGy8Ru3AluN(TtDnOoXuyjzW8ue(u(xizSSVc9uxdQtmfwsMfoDIOdjaDMF0aKXY(k0tDnOo4Rq2bYeZr)qnG4ejhJGLeMkJL9vON6AqD)hlBw0cTsY(rJI6AqDNgmSVcZfExiIwOvcH7PU1OU0UtmUetTtI(HAaXuBzVodKM9k7eSSVc9BgUt4Wqqyy7K)aauxdQtIosKH4dK6wL6yG0StmUetTtycJ(eqKWIkMpd63YEDgq)9k7eSSVc9BgUt4Wqqyy7K)aauxdQtIosKH4dK6wL6AxpStmUetTtaVEFkYzOq2al)w2RZaTVxzNGL9vOFZWDchgccdBN8haG6AqDs0rImeFGu3QuN(PDNyCjMANaE9(uep2Nk4erl0kzl71zagyVYobl7Rq)MH7eomeeg2obmpfbOZGEQBH6s7oX4sm1orNvEYWsy(uER2YEDgGb3RStWY(k0Vz4oHddbHHTtaZtra6mON6wL6sl11G6GVczhitm)nfcocpcbK)dwrXKWhiMXY(k0tDnOU)JLn)nfcocpcbK)dwrXKWhiMHy3IcqDRsDPDNyCjMANa0z(rdYFuYw2RZaPDVYobl7Rq)MH7eomeeg2obmpfbOZGEQBTfQJbOUguxku3bkzpenpqm1veMnUeNi1LE6u3bkzp2Nk4erl0kjBCjorQl1DIXLyQDIoR8KHLW8P8wTt8iGdJdjMANCdzPUBeIMhiM6kcbuNbrQZuq08APoJlXj2K6QH6ke9uNmuhWorQdOZGEWw2RZaAI9k7eSSVc9BgUt4Wqqyy7eW8ueGod6PU1wOo9PUgu3)XYMlu0HqYXaftLFhuxdQJpJYpAuzUPuepenpqm1vecYqSBrbOU1OU2PU2I6yY95UDFNyCjMANOZkpzyjmFkVvBzVodON2RStWY(k0Vz4oHddbHHTtaZtra6mON6wBH60N6AqD)hlBwJq5jr)aKbIXVsDRrDTtDnOUduYEiAEGyQRimdXUffG6wJ6stoTu3fQJBaHirhPUluNXLyQm417tr8yFQGteTqRKm3acrIosDnOUduYEiAEGyQRimdXUffG6wL6stoTu3fQJBaHirhPUluNXLyQm417tr8yFQGteTqRKm3acrIosDxOUuOU0qDRPjf1Lc1Xau3nPoW8ueGod6PUuPUuPU2I6mUetLb6m)Ob5pkjZnGqKOJuxdQ70GH9vyUW7cr0cTsiCp1Tk1XK7ZD7o11G6KOJu3AuhBabcr0cTsis0rQ7MuhtUp3T77eJlXu7eDw5jdlH5t5TAl71za9WELDcw2xH(nd3jCyiimSDIMPo(CILvs(elrNw4obiWGl711FNyCjMANWnLIyCjMIOcGStubqiL1XDcFoXYkHy)qfI2TSxNbUb7v2jyzFf63mCNWHHGWW2jAM6etHLKbghgSbh9eW8uGmw2xH(DIXLyQDcyEkcqGXvCN4rahghsm1orppeDZtOUeJdd2GJEQlzEkqtQlzEkQlrGXvK6ca1be4umri1j6SI6UrSp1FustQdmuxiuNodqDg1PlyQdHu3bmgyiA3YEDgmn7v2jyzFf63mCNWHHGWW2j)hlB2J9PcoHpqmdrJluxdQdmpfbOZGEQBvQJbPUgu3Pbd7RWCH3fIOfALq4EQBnQR90StmUetTt8yFQ)OKDIhbCyCiXu7KKdS8u3nI9Pco1P3debuh7aPUK5POUeDg0dOUxjHI6wrl0kH64ZO8Jgf1faQJRgasDYqDq08A3YEDgu)9k7eSSVc9BgUt4Wqqyy7K)JLn7X(ubNWhiMHOXfQRb1bMNIa0zqp1Tk1XGuxdQ70GH9vyUW7cr0cTsiCp1Tk1PF77eJlXu7ep2N6pkzN4rahghsm1o5gFWOysDROfALqDauEhnPoWbwEQ7gX(ubN607bIaQJDGuxY8uuxIod6bBzVod2(ELDcw2xH(nd3jCyiimSDY)XYM9yFQGt4deZq04c11G6aZtra6mON6wL6yqQRb1Lc19FSSzp2Nk4e(aXmqm(vQBnQRDQl90PoXuyjzGXHbBWrpbmpfiJL9vON6sDNyCjMAN4X(u)rjBzVodYa7v2jyzFf63mCNWHHGWW2jaui)PEGSeiSD9aP9do11G6aZtra6mON6wL6yqQRb1Lc1Lc1PjOUBsDG5PiaDg0tDPsDTf1zCjMkd0z(rdYFusgVJ8NGej6i1Tg1DGs2drZdetDfHzi2TOau3nPoJlXuzDw5jdlH5t5TkJ3r(tqIeDK6Uj1zCjMk7X(u)rjz8oYFcsKOJuxQuxdQ7)yzZESpvWj8bIzGy8Ru3AluN(7eJlXu7ep2N6pkzl71zqgCVYobl7Rq)MH7eomeeg2o5)yzZESpvWj8bIziACH6AqDG5PiaDg0tDRsDmi11G6mUeNiblShiG6wJ60FNyCjMAN4X(u)rjBzVodM29k7eJlXu7eW8ueGaJR4obl7Rq)MHBzVodQj2RStWY(k0Vz4oX4sm1oHBkfX4smfrfazNOcGqkRJ7e(CILvcX(HkeTBzVodQN2RStWY(k0Vz4oHddbHHTtaZtra6mON6wBH6yaQRb1DAWW(kmx4DHiAHwjeUN6wJ6ApTuxdQlfQtmfws2J9PcoHBkvumZyzFf6PU0tN64ZO8JgvMBkfXdrZdetDfHGme7wuaQBnQlfQlfQlTu3nPoW8ueGod6PUuPU2I6mUetLb6m)Ob5pkjJ3r(tqIeDK6sL6UqDgxIPY6SYtgwcZNYBvgVJ8NGej6i1L6oX4sm1orNvEYWsy(uER2jEeWHXHetTtUHSuN25rDCROoMOqDFJFL6KH6sl1Lmpf1LOZGEa19r2bIu3ncrZdetDfHaQJpJYpAuuxaOoiAETnPUqUfqDZvtl1jd1boWYtDIoStD1OXw2RZG6H9k7eSSVc9BgUt4Wqqyy7eiYcrGo7RqQRb1jrhPU1Oo2aceIOfALqKOJ7eJlXu7e)m9DcxlxHeXGmrbSxx)TSxNbVb7v2jyzFf63mCNWHHGWW2j)hlB2J9PcoHpqmdrJluxdQ7)yzZESpvWj8bIzi2TOau3QuN(u3fQJj3N72DQRTOU)JLn7X(ubNWhiMbIXVUtmUetTt8yFQ)OKDIhbCyCiXu7enPbi1DJyFQ)OeQlyPoTZ7wisDmNOysDYqDQbGu3nI9Pco1P3dePoGy8RGMuhEIf1fSuxi36PonmGGuNrDG5POoGod6ZBzVEAtZELDIXLyQDcqN5hni)rj7eSSVc9BgULTStoGiF6Ft2RSxx)9k7eSSVc9BgUt4Wqqyy7ej6i1Tg1LgQRb1PzQ7aLSPItCNyCjMANWIkIF6rzsm1oXJaomoKyQDIE0DK)e0tDFKDGi1XN(3eQ7JmJcKPo9mohpea1vtDtDgSZ(uuNXLyka1nLsBEl71BFVYoX4sm1ob869PiSOI5ZG(Dcw2xH(nd3YEDgyVYobl7Rq)MH7KY64orMosgwsFkGaNhGWNciWhxIPa7eJlXu7ez6izyj9PacCEacFkGaFCjMcSL96m4ELDcw2xH(nd3jL1XDcyuOPdqaihIcrqUUk0KF4oX4sm1obmk00biaKdrHiixxfAYpCl71t7ELDIXLyQDcRcb64qJv2jyzFf63mCl711e7v2jyzFf63mCNWHHGWW2j)hlBwJq5jr)aKbIXVsDRrD6tDnOU)JLn7X(ubNWhiMbIXVsDRUqDTVtmUetTtognqibeh6MAl711t7v2jyzFf63mCNuwh3jaDMF0a9Kb(jdlrgyhlzNyCjMANa0z(rd0tg4NmSezGDSKTSxxpSxzNGL9vOFZWDchgccdBNaMNIa0zqpG6wL6sl11G6sH6(daqDPNo1zCjMk7X(u)rjzUbeQBH6sd1L6oX4sm1oXJ9P(Js2YE9BWELDcw2xH(nd3jCyiimSDcyEkcqNb9aQBvQlTuxdQtZuxku3FaaQl90PoJlXuzp2N6pkjZnGqDluxAOUu3jgxIP2jaDMF0G8hLSL966NM9k7eSSVc9BgUtMJDcaLDIXLyQDYPbd7RWDYPPE4ob(kKDGmX83ui4i8ieq(pyfftcFGygl7Rqp11G6GVczhitmd0zqpzyjwvHUqzsmvgl7Rq)o50GKY64o5bqYFucrIEumbBzl7K5aleUxzVU(7v2jyzFf63mCNWHHGWW2jG5P(r5ZmHZjsI6myoqtIPYyzFf63jgxIP2jG5PiWr2YE923RStmUetTtku0HqYXaftTtWY(k0Vz4w2RZa7v2jgxIP2jmHrFcisyrfZNb97eSSVc9BgUL96m4ELDIXLyQDc417trodfYgy53jyzFf63mCl71t7ELDcw2xH(nd3jCyiimSDcyEkcqNb9u3QuxAPUguhFgLF0OYCtPiEiAEGyQRieKFh7eJlXu7eGoZpAq(Js2YEDnXELDcw2xH(nd3jCyiimSDYPbd7RW8dGK)OeIe9OycOUguhyEkcqNb9u3QuxAPUgu3)XYM)McbhHhHaY)bROys4deZaX4xPUvPogCNyCjMANa0z(rdYFuYw2RRN2RStmUetTt4Msr8q08aXuxriyNGL9vOFZWTSLDIaJ6kkG9k711FVYobl7Rq)MH7K5yNaqzNyCjMANCAWW(kCNCAQhUtsH60m1DAWW(km)ai5pkHirpkMaQRb1DGs2J9Pcor0cTsYgxItK6sL6spDQlfQ70GH9vy(bqYFucrIEumbuxdQ7)yzZaDg0tgwIvvOluMetLFhuxQ7KtdskRJ7Khaj)hllrGrDffWw2R3(ELDcw2xH(nd3jL1XDcGBqazyjSqtqyzkcqGblUtmUetTtaCdcidlHfAccltracmyXDchgccdBNOzQ7)yzZaUbbKHLWcnbHLPiabgSiHbZVJTSxNb2RStWY(k0Vz4oPSoUtaCdcidlHfAccltracmyXDIXLyQDcGBqazyjSqtqyzkcqGblUt4Wqqyy7K)JLnd4geqgwcl0eewMIaeyWIegm)oOUgu3bkzp2Nk4erl0kjBCjoXTSxNb3RStWY(k0Vz4oPSoUta6m)Ob6jd8tgwImWowYoX4sm1obOZ8JgONmWpzyjYa7yj7eomeeg2o50GH9vy()yzjaTfNW9u3Qux7TVL96PDVYobl7Rq)MH7KY64oHjm6eKRIdaUtmUetTtycJob5Q4aG7eomeeg2o50GH9vy()yzjaTfNW9u3QuNEAl711e7v2jyzFf63mCNuwh3jmHrNGCvCaWDIXLyQDcty0jixfhaCNWHHGWW2jNgmSVcZ)hllbOT4eUN6wL60tBzVUEAVYobl7Rq)MH7eJlXu7eUPueJlXuevaKDchgccdBNiMclj7X(ubNWNc86hsmvgl7Rqp11G6onyyFfMl8UqeTqRec3tDRsDTNMDIkacPSoUt0DqeyuxbBzVUEyVYobl7Rq)MH7eJlXu7eUPueJlXuevaKDIhbCyCiXu7e9iwwKlaQt0zc1jq7evuhqnAO0sDSWPtDIoK6edYefQdIAYVaIuN59HetzQMuhapmOji1PZkVkkM7evaeszDCNauJgebg1vuaBzV(nyVYobl7Rq)MH7KY64ozoriRA0ikMeRIUr4gtCNyCjMANmNiKvnAeftIvr3iCJjUt4Wqqyy7Ktdg2xH5haj)hllrGrDffWw2RRFA2RStWY(k0Vz4oHddbHHTteyuxrjl6N1zaYdGK)JLL6AqDNgmSVcZpas(pwwIaJ6kkGDIXLyQDIaJ6kk6VtaQr2jcmQROO)w2RRV(7v2jyzFf63mCNWHHGWW2jcmQROKL2Z6ma5bqY)XYsDnOUtdg2xH5haj)hllrGrDffWoX4sm1orGrDfL23ja1i7ebg1vuAFl711V99k7eSSVc9BgUtmUetTt4MsrmUetrubq2jCyiimSDIeDK6wJ6ydiqiIwOvcrIosDnOUtdg2xH5)JLLa0wCc3tDRrDTNMDIkacPSoUtoEqK4TUXejcmQRGTSLDYXdIeV1nMirGrDfSxzVU(7v2jyzFf63mCNuwh3jEiAE2aIKteaq1oX4sm1oXdrZZgqKCIaaQ2YE923RStWY(k0Vz4oPSoUtGiykRecebi8Cc4oX4sm1obIGPSsiqeGWZjGBzVodSxzNGL9vOFZWDszDCNyqUUqqUairXeRxiAj8bI7eJlXu7edY1fcYfajkMy9crlHpqCl71zW9k7eSSVc9BgUtkRJ7e(a6bNWuz(WKbciqemLjdCNyCjMANWhqp4eMkZhMmqabIGPmzGBzVEA3RStWY(k0Vz4oPSoUt8q08SbejNiaGQDIXLyQDIhIMNnGi5ebauTL96AI9k7eSSVc9BgUtkRJ7eW8uKGzfcc3jgxIP2jG5PibZkeeUL966P9k7eSSVc9BgUtkRJ7eMkTh6idlXaGOhktIP2jgxIP2jmvAp0rgwIbarpuMetTt4Wqqyy7eJlXjsWc7bcOUfQt)TSxxpSxzNGL9vOFZWDszDCN4n41(mfXJ8RKJNarahloUtmUetTt8g8AFMI4r(vYXtGiGJfh3YE9BWELDcw2xH(nd3jL1XDc(Ncmpf5ma4oX4sm1ob)tbMNICgaCl711pn7v2jyzFf63mCNuwh3jVIRZIc9eMkZhMmqabOZ4xviyNyCjMAN8kUolk0tyQmFyYabeGoJFvHGTSLDYWK73RSxx)9k7eJlXu7Kpcbi8Aum3jyzFf63mCl71BFVYoX4sm1o5RMXtyFqT7eSSVc9BgUL96mWELDIXLyQDcBaXVAg)obl7Rq)MHBzVodUxzNyCjMAN8aijeSd2jyzFf63mClBzl7KtecIP2R3EAAV90WaTR)orddwrXeSt0Z1ZABx)gUEBVErDu3k6qQl6hduOo2bsD3cuJgebg1vua3sDqut(fq0tDGPJuN9KPBc6PoUoRyIGmTvBgfsD6RxuNEp1jcf0tDjrxVPoG2sS7uxBh1jd11MpJ68XzaIPOU5aHMmqQlfgtL6sr)7PMPTAZOqQRD9I607PorOGEQlj66n1b0wIDN6A7OozOU28zuNpodqmf1nhi0KbsDPWyQuxk6Fp1mTvBgfsDmGErD69uNiuqp1LeD9M6aAlXUtDTDuNmuxB(mQZhNbiMI6MdeAYaPUuymvQlf9VNAM2I2spxpRTD9B46T96f1rDROdPUOFmqH6yhi1DlFoXYkHy)qfI2BPoiQj)ci6PoW0rQZEY0nb9uhxNvmrqM2QnJcPo91lQtVN6eHc6PUBbZt9JYN10BPozOUBbZt9JYN10mw2xH(BPUu0)EQzAR2mkK6AxVOo9EQtekON6Ufmp1pkFwtVL6KH6Ufmp1pkFwtZyzFf6VL6sr)7PMPTAZOqQJb0lQtVN6eHc6PUBbZt9JYN10BPozOUBbZt9JYN10mw2xH(BPUu0)EQzAR2mkK6yq9I6ABX(CIEQRhLEPPuhxhYVsDPuJqD2Pfk7RqQlkQd7pLjXuPsDPO)9uZ0wTzui1XG6f1P3tDIqb9u3TG5P(r5ZA6TuNmu3TG5P(r5ZAAgl7Rq)Tuxk6Fp1mTvBgfsDPvVOU2wSpNON66rPxAk1X1H8Ruxk1iuNDAHY(kK6II6W(tzsmvQuxk6Fp1mTvBgfsDPvVOo9EQtekON6Ufmp1pkFwtVL6KH6Ufmp1pkFwtZyzFf6VL6sr)7PMPTAZOqQttOxuNEp1jcf0tD3cMN6hLpRP3sDYqD3cMN6hLpRPzSSVc93sDPWa3tntB1MrHuNEsVOo9EQtekON6UvmfwswtVL6KH6UvmfwswtZyzFf6VL6sr)7PMPTAZOqQtpOxuNEp1jcf0tD3cMN6hLpRP3sDYqD3cMN6hLpRPzSSVc93sDPO)9uZ0wTzui1Dd0lQtVN6eHc6PUBbZt9JYN10BPozOUBbZt9JYN10mw2xH(BPUu0)EQzAR2mkK60pn6f1P3tDIqb9u3TG5P(r5ZA6TuNmu3TG5P(r5ZAAgl7Rq)TuNjuNEKE82K6sr)7PMPTOT0Z1ZABx)gUEBVErDu3k6qQl6hduOo2bsD3kAHwjeakVJBPoiQj)ci6PoW0rQZEY0nb9uhxNvmrqM2QnJcPogqVOo9EQtekON6Uf(kKDGmXSMEl1jd1Dl8vi7azIznnJL9vO)wQlf9VNAM2I2spxpRTD9B46T96f1rDROdPUOFmqH6yhi1DRhzTNsUL6GOM8lGON6athPo7jt3e0tDCDwXebzAR2mkK6sRErD69uNiuqp1DlyEQFu(SMEl1jd1DlyEQFu(SMMXY(k0Fl1LI(3tntB1MrHuNMqVOo9EQtekON6Ufmp1pkFwtVL6KH6Ufmp1pkFwtZyzFf6VL6sr)7PMPTAZOqQtF9KErD69uNiuqp1DlyEQFu(SMEl1jd1DlyEQFu(SMMXY(k0Fl1LcdCp1mTvBgfsD6Fd0lQtVN6eHc6PUBbZt9JYN10BPozOUBbZt9JYN10mw2xH(BPUu0)EQzAR2mkK6AxF9I607PorOGEQ7w4Rq2bYeZA6TuNmu3TWxHSdKjM10mw2xH(BPUu0)EQzAR2mkK6ANb0lQtVN6eHc6PUBHVczhitmRP3sDYqD3cFfYoqMywtZyzFf6VL6sr)7PMPTAZOqQRD9KErD69uNiuqp1Dl8vi7azIzn9wQtgQ7w4Rq2bYeZAAgl7Rq)Tuxk6Fp1mTvBgfsDTRh0lQtVN6eHc6PUBHVczhitmRP3sDYqD3cFfYoqMywtZyzFf6VL6mH60J0J3Muxk6Fp1mTvBgfsDTFd0lQtVN6eHc6PUBHVczhitmRP3sDYqD3cFfYoqMywtZyzFf6VL6sr)7PMPTAZOqQJbyq9I607PorOGEQ7w4Rq2bYeZA6TuNmu3TWxHSdKjM10mw2xH(BPUu0)EQzAlAl9C9S221VHR32Rxuh1TIoK6I(XafQJDGu3ThqKp9Vj3sDqut(fq0tDGPJuN9KPBc6PoUoRyIGmTvBgfsD6Ng9I607PorOGEQ7w4Rq2bYeZA6TuNmu3TWxHSdKjM10mw2xH(BPotOo9i94Tj1LI(3tntB1MrHuN(PrVOo9EQtekON6Uf(kKDGmXSMEl1jd1Dl8vi7azIznnJL9vO)wQlf9VNAM2I2spxpRTD9B46T96f1rDROdPUOFmqH6yhi1DRaJ6kkGBPoiQj)ci6PoW0rQZEY0nb9uhxNvmrqM2QnJcPo9tJErD69uNiuqp1DRaJ6kkz9ZA6TuNmu3TcmQROKf9ZA6Tuxk6Fp1mTvBgfsD6RVErD69uNiuqp1DRaJ6kk52ZA6TuNmu3TcmQROKL2ZA6Tuxk6Fp1mTfTLEUEwB763W1B71lQJ6wrhsDr)yGc1XoqQ725aleEl1brn5xarp1bMosD2tMUjON646SIjcY0wTzui1PVErD69uNiuqp1DlyEQFu(SMEl1jd1DlyEQFu(SMMXY(k0Fl1zc1PhPhVnPUu0)EQzAlARBy)yGc6Po9td1zCjMI6ubqazARDI9eDdCNStoGdBOWDsB0gu3nI9Pg1Wul1PNBq1WVsB1gTb1PtKdGEXiJmdr37N5tNrq0FktIP4qJvyeeDoJ0wTrBqDAsAqUoQRDgOj11EAAVDAlAR2OnOo9wNvmrGErB1gTb1DtQl5avkQRnh(1mTvB0gu3nPo94Lsl1br(07y5PUBe7t9hLqDhq8M8P)nH6cwQleQlauxuaXkH6szGuNod65gqOo2bsD)baqqQAsK68tDRqDZjc52b1b0zqpG6cwQt78UfIuNjuxAPUOOorhsDZbwimtB1gTb1DtQRTXObcPUK4q3uuNPuJgON6oG4n5t)Bc1jd1Daho1ffqSsOUBe7t9hLKPTAJ2G6Uj1124STb1jMclH6Isqi8DizAR2OnOUBsD6zNt4PUegEZ1ABEA7PoWH1Pon0Hf1PDE3crQRgH6S)8eQtgQd869POoJ6wrl0kjtB1gTb1DtQRTjfc0XHgRWOMegLjHcPUKrDILqDCR4OIeSuhxNvmrp1jd1fLGq47qibBM2QnAdQ7Mu3kqTuNmuNDoHN60WasumPUBe7tfCQtVhisDaX4xbzAR2OnOUBsDRa1sDYqDD7ksDZbwiK6oGXadrl1nLsl1PXaVsDbl1PbsDCROoJlptP0sDZbwuNgHOJ6mQBfTqRKmTvB0gu3nPUBy)aoNi1XN(HjXpuHOL60ieDuNMKxOU)luEqM2I2QnOo9O7i)jON6(i7arQJp9Vju3hzgfitD6zCoEiaQRM6M6myN9POoJlXuaQBkL2mTLXLykq(aI8P)n5YcJSOI4NEuMet1myxKOJRLMgA(aLSPItK2Y4smfiFar(0)MCzHrWR3NICGcTLXLykq(aI8P)n5YcJpascb7nlRJlY0rYWs6tbe48ae(uab(4smfG2Y4smfiFar(0)MCzHXhajHG9ML1XfWOqthGaqoefIGCDvOj)qAlJlXuG8be5t)BYLfgzviqhhAScTLXLykq(aI8P)n5YcJhJgiKaIdDt1myx(pw2SgHYtI(bideJFDn9B8FSSzp2Nk4e(aXmqm(1vxAN2Y4smfiFar(0)MCzHXhajHG9ML1XfGoZpAGEYa)KHLidSJLqBzCjMcKpGiF6FtUSWOh7t9hL0myxaZtra6mOhSAABKYFaG0t34smv2J9P(JsYCdilPjvAlJlXuG8be5t)BYLfgb6m)Ob5pkPzWUaMNIa0zqpy102qZP8hai90nUetL9yFQ)OKm3aYsAsL2QnAdQZ4smfiFar(0)MCzHXtdg2xHnlRJlSbeierl0kHirhBohlauAEAQhUOFAOTAJ2G6mUetbYhqKp9Vjxwy80GH9vyZY64suK5ale2CowaO080upCrFAlJlXuG8be5t)BYLfgpnyyFf2SSoU8ai5pkHirpkMGMZXcaLMNM6HlWxHSdKjM)McbhHhHaY)bROys4deBaFfYoqMygOZGEYWsSQcDHYKykAlAlAR2G60JUJ8NGEQdprOwQtIosDIoK6mUmqQlauNDAHY(kmtBzCjMcSaoqLIOg(vAlJlXuGllmYnLIWIkDVsqiTLXLykWLfgT7irgaG2Y4smf4YcJE8CEqs3ygCAlJlXuGLtdg2xHnlRJlfExiIwOvcH7BohlauAEAQhUWNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6BgSlAgmp1pkFMnqLNmSKVAaGPdspD(mk)OrLbVEFkIh7tfCIOfALKHy3IcqW7hixq)A8zu(rJkdMNIahjdXUffGG3pqUGEAlJlXuGllmEAWW(kSzzDCPW7cr0cTsiCFZ5ybGsZtt9Wf(mk)OrLbZtrGJKHy3IcqW7hixqFZGDbmp1pkFMnqLNmSKVAaGPdAWNr5hnQm417tr8yFQGteTqRKme7wuacE)a5c6xLpJYpAuzW8ue4izi2TOae8(bYf0tB1gTb1zCjMcCzHXtdg2xHnlRJlrrMdSqyZ5ybGsZtt9WL00myxoqj7X(ubNiAHwjzJlXjsBzCjMcCzHXtdg2xHnlRJl)hllbOT4eUV5CSaqP5PPE4YPbd7RWCH3fIOfALq4(Mb7IMpnyyFfMFaK8hLqKOhftqdnhfzoWcH0wgxIPaxwy80GH9vyZY64Y)XYsaAloH7BohlauAEAQhUOF7nd2fnFAWW(km)ai5pkHirpkMGgrrMdSqydnFGs2drZdetDfHzJlXjsBzCjMcCzHXtdg2xHnlRJl)hllbOT4eUV5CSaqP5PPE4sAAgSlA(0GH9vy(bqYFucrIEumbnIImhyHWghOK9q08aXuxry24sCIn(pw2SgHYtI(bideJFDT00qZIPWsYNHczdS8zSSVc90wgxIPaxwy80GH9vyZY64Y)XYsaAloH7BohlauAEAQhUKMMb7IMpnyyFfMFaK8hLqKOhftqJOiZbwiSXbkzpenpqm1veMnUeNyJdiEsyY9z9Z6SYtgwcZNYBvdXuyj5ZqHSbw(mw2xHEAlJlXuGllmEAWW(kSzzDC5)yzjaTfNW9nNJfaknpn1dx4ZO8Jgv2J8OBsumj)rjzi2TOae8(bYf03myxonyyFfMFaK8hLqKOhftaTLXLykWLfg5MsrmUetrubqAwwhxeyuxrbqBzCjMcCzHrUPueJlXuevaKML1XLHj33myxsrZNgmSVcZpas(Jsis0JIjOXbkzp2Nk4erl0kjBCjoXutp9uonyyFfMFaK8hLqKOhftqJ)JLnd0zqpzyjwvHUqzsmv(D0ifnlMcljFmAGqcio0nvgl7RqF6P)FSS5JrdesaXHUPYVJutL2Y4smf4YcJr)qnGyQMb7YFaGgSbtDcbIDlkWQT3wm5EAlJlXuGllmYnLIyCjMIOcG0SSoUmhyHWMabgCzr)Mb7ImmzQWmFgLF0OanKOJRYgqGqeTqReIeDK2Y4smf4YcJ(z6nd2fiYcrGo7RqAlJlXuGllmYnLIyCjMIOcG0SSoUWNtSSsi2puHOTjqGbxw0VzWUaMN6hLpZeoNijQZG5anjMk90bZt9JYNzdu5jdl5Rgay6G0thmp1pkFMp9VjKo6dXKyQ0tNpNyzLKlKdh1a90wgxIPaxwy8y0aHeqCOBQMb7YPbd7RW8dGK)OeIe9OycA8FSSzGod6jdlXQk0fktIPYVdAlJlXuGllmEmsmvZGDjfnFAWW(km)ai5pkHirpkMGgNgmSVcZfExiIwOvcH7xLj3N729gs0X1ydiqiIwOvcrIoME6G5P(r5ZqKnk0tomLjyJtdg2xH5cVlerl0kHW9RYa6Hutp9uonyyFfMFaK8hLqKOhftqJ)JLnd0zqpzyjwvHUqzsmv(DKkTLXLykWLfg5MsrmUetrubqAwwhxeTqRecaL3bTLXLykWLfg9yFQGtacelMIUMb7skAg(kKDGmXSgHIfIEabemdfzyjG3bcJbsaVEFQOy240GH9vyUW7cr0cTsiC)A3Gutp9uoqj7X(ubNiAHwjzJlXj24aLSh7tfCIOfALKHy3IcSQMOTyY95UDpvAlJlXuGllmYnLI4HO5bIPUIqqZGD50GH9vy(bqYFucrIEumbn4ZO8Jgvg869PiESpvWjIwOvsgIDlkabVFGCb9R1E70wgxIPaxwyKBkfXdrZdetDfHGMb7IMpnyyFfMFaK8hLqKOhftqJuonyyFfMl8UqeTqRec3Vw7P5MPTT0m8vi7azIzncfle9aciygkYWsaVdegdKaE9(urXmvAlJlXuGllmEmAGqcio0nvZGDrZNgmSVcZpas(Jsis0JIjOX)XYM1iuEs0pazGy8RRPFJ)JLn7X(ubNWhiMbIXVUkdqBzCjMcCzHXFOqaFEqMi5p9pcbnd2L)JLnlAHwjz)Or140GH9vyUW7cr0cTsiC)APL2Y4smf4YcJr)qnGyQMb7IXL4ejyH9abRP)Lu0VTetHLKbghgSbh9eW8uGmw2xH(uB8FSSzncLNe9dqgig)6AlAIg)hlBw0cTsY(rJQXPbd7RWCH3fIOfALq4(1slTLXLykWLfgJ(HAaXund2fJlXjsWc7bcwR9g)hlBwJq5jr)aKbIXVU2IMOX)XYMfTqRKSF0OACAWW(kmx4DHiAHwjeUFT02qZWxHSdKjMJ(HAaXjsogbljmvJu0SykSKmlC6erhsa6m)ObiJL9vOp9094)XYMzHtNi6qcqN5hna53rQ0wgxIPaxwym6hQbet1myxmUeNiblShiyT2B8FSSzncLNe9dqgig)6AlAIg)hlBo6hQbeNi5yeSKWuzi2TOaR2Ed4Rq2bYeZr)qnG4ejhJGLeMI2Y4smf4YcJr)qnGyQMb7Y)XYM1iuEs0pazGy8RRTOF7netHLKbZtr4t5FHKXY(k03qmfwsMfoDIOdjaDMF0aKXY(k03a(kKDGmXC0pudiorYXiyjHPA8FSSzrl0kj7hnQgNgmSVcZfExiIwOvcH7xlT0wgxIPaxwyKjm6tarclQy(mOVzWU8haOHeDKidXh4QmqAOTmUetbUSWi417trodfYgy5BgSl)baAirhjYq8bUA76bAlJlXuGllmcE9(uep2Nk4erl0kPzWU8haOHeDKidXh4Q6NwAlJlXuGllmQZkpzyjmFkVvnd2fW8ueGod6xslTLXLykWLfgb6m)Ob5pkPzWUaMNIa0zq)QPTb8vi7azI5VPqWr4riG8FWkkMe(aXg)hlB(BkeCeEeci)hSIIjHpqmdXUffy10sB1gu3nKL6UriAEGyQRieqDgePotbrZRL6mUeNytQRgQRq0tDYqDa7ePoGod6b0wgxIPaxwyuNvEYWsy(uERAgSlG5PiaDg0V2cd0iLduYEiAEGyQRimBCjoX0t)aLSh7tfCIOfALKnUeNyQ0wgxIPaxwyuNvEYWsy(uERAgSlG5PiaDg0V2I(n(pw2CHIoesogOyQ87ObFgLF0OYCtPiEiAEGyQRieKHy3IcSw7TftUp3T70wgxIPaxwyuNvEYWsy(uERAgSlG5PiaDg0V2I(n(pw2SgHYtI(bideJFDT2BCGs2drZdetDfHzi2TOaRLMCAVWnGqKOJxmUetLbVEFkIh7tfCIOfALK5gqis0XghOK9q08aXuxrygIDlkWQPjN2lCdiej64fJlXuzWR3NI4X(ubNiAHwjzUbeIeD8skPznnPsHbUjyEkcqNb9PMABzCjMkd0z(rdYFusMBaHirhBCAWW(kmx4DHiAHwjeUFvMCFUB3BirhxJnGaHiAHwjej64nzY95UDN2Y4smf4YcJCtPigxIPiQainlRJl85elReI9dviABceyWLf9BgSlAMpNyzLKpXs0PfsB1guNEEi6MNqDjghgSbh9uxY8uGMuxY8uuxIaJRi1faQdiWPyIqQt0zf1DJyFQ)OKMuhyOUqOoDgG6mQtxWuhcPUdymWq0sBzCjMcCzHrW8ueGaJRyZGDrZIPWsYaJdd2GJEcyEkqgl7RqpTvBqDjhy5PUBe7tfCQtVhicOo2bsDjZtrDj6mOhqDVscf1TIwOvc1XNr5hnkQlauhxnaK6KH6GO51sBzCjMcCzHrp2N6pkPzWU8FSSzp2Nk4e(aXmenU0ampfbOZG(vzWgNgmSVcZfExiIwOvcH7xR90qB1gu3n(GrXK6wrl0kH6aO8oAsDGdS8u3nI9Pco1P3debuh7aPUK5POUeDg0dOTmUetbUSWOh7t9hL0myx(pw2Sh7tfCcFGygIgxAaMNIa0zq)QmyJtdg2xH5cVlerl0kHW9RQF70wgxIPaxwy0J9P(JsAgSl)hlB2J9PcoHpqmdrJlnaZtra6mOFvgSrk)hlB2J9PcoHpqmdeJFDT2tpDXuyjzGXHbBWrpbmpfiJL9vOpvAlJlXuGllm6X(u)rjnd2fakK)upqwce2UEG0(bVbyEkcqNb9RYGnsjfnXnbZtra6mOp12Y4smvgOZ8JgK)OKmEh5pbjs0X1oqj7HO5bIPUIWme7wuGBACjMkRZkpzyjmFkVvz8oYFcsKOJ304smv2J9P(JsY4DK)eKirhtTX)XYM9yFQGt4deZaX4xxBrFAlJlXuGllm6X(u)rjnd2L)JLn7X(ubNWhiMHOXLgG5PiaDg0Vkd2W4sCIeSWEGG10N2Y4smf4YcJG5PiabgxrAlJlXuGllmYnLIyCjMIOcG0SSoUWNtSSsi2puHOL2QnOUBil1PDEuh3kQJjku334xPozOU0sDjZtrDj6mOhqDFKDGi1DJq08aXuxriG64ZO8Jgf1faQdIMxBtQlKBbu3C10sDYqDGdS8uNOd7uxnAqBzCjMcCzHrDw5jdlH5t5TQzWUaMNIa0zq)AlmqJtdg2xH5cVlerl0kHW9R1EABKIykSKSh7tfCc3uQOyMXY(k0NE68zu(rJkZnLI4HO5bIPUIqqgIDlkWAPKsAVjyEkcqNb9P2wgxIPYaDMF0G8hLKX7i)jirIoM6fJlXuzDw5jdlH5t5TkJ3r(tqIeDmvAlJlXuGllm6NP3KRLRqIyqMOaw0VzWUarwic0zFf2qIoUgBabcr0cTsis0rAR2G60KgGu3nI9P(JsOUGL60oVBHi1XCIIj1jd1PgasD3i2Nk4uNEpqK6aIXVcAsD4jwuxWsDHCRN60WacsDg1bMNI6a6mOptBzCjMcCzHrp2N6pkPzWU8FSSzp2Nk4e(aXmenU04)yzZESpvWj8bIzi2TOaRQ)fMCFUB3BR)JLn7X(ubNWhiMbIXVsBzCjMcCzHrGoZpAq(JsOTOTmUetbYa1ObrGrDffWYdGKqWEZY64cyEkfksumjW3xBtUwUcjIbzIcyr)Mb7YPbd7RW8)XYsaAloH7xvmituY(aiwXX2U0EZuAVTyY95UDVTonyyFfMFaK8hLqKOhftqQ0wgxIPazGA0GiWOUIc4YcJpascb7nlRJlGx9vZ4jwhfDAbsZGD50GH9vy()yzjaTfNW9RkgKjkzFaeR4yBxAVKs7T1Pbd7RW8dGK)OeIe9OycsL2Y4smfiduJgebg1vuaxwy8bqsiyVzzDCb7hAHOPid0xwXXMb7YPbd7RW8)XYsaAloH7xnfXGmrj7dGyfhB7sBQx0V9lP0EBDAWW(km)ai5pkHirpkMGuPTOTmUetbY85elReI9dviAxaZtrGJ0myxaZt9JYNzcNtKe1zWCGMet1iLtdg2xH5cVlerl0kHW9R2EAsp9tdg2xH5cVlerl0kHW9RXaPjvAlJlXuGmFoXYkHy)qfI2llmcMNIahPzWUaMN6hLpZgOYtgwYxnaW0bnoqj7X(ubNiAHwjzJlXjsBzCjMcK5Zjwwje7hQq0EzHrW8ue4ind2fW8u)O8zncLNO7vcrmUeCqdnFGs2J9Pcor0cTsYgxItSXPbd7RWCH3fIOfALq4(10xpqBzCjMcK5Zjwwje7hQq0EzHrpYJUjrXK8hL0KRLRqIyqMOaw0VzWU0JsVedYeLSo0uIU8bxAgSlA(0GH9vy(bqYFucrIEumbnaZt9JYNvO5jFTe8U1puyJuoqj7X(ubNiAHwjzJlXj2ampfbOZG(vBp9018bkzp2Nk4erl0kjBCjoXgNgmSVcZfExiIwOvcH7xJbttQ0wgxIPaz(CILvcX(HkeTxwy0J8OBsumj)rjn5A5kKigKjkGf9BgSl9O0lXGmrjRdnLOlFWLMb7IMpnyyFfMFaK8hLqKOhftqdW8u)O85R4zuaYm6XqvumBKYbkzp2Nk4erl0kjBCjoX0txZhOK9yFQGteTqRKSXL4eBCAWW(kmx4DHiAHwjeUFngmnPsBzCjMcK5Zjwwje7hQq0EzHrpYJUjrXK8hL0KRLRqIyqMOaw0VzWUO5tdg2xH5haj)rjej6rXe0ifW8u)O8z2bYe)dSqcepryGG0tpfW8u)O85ZrzsOqcyuNyjn0myEQFu(8v8mkazg9yOkkMPMAdnFGs2J9Pcor0cTsYgxItK2Y4smfiZNtSSsi2puHO9YcJEKhDtIIj5pkPjxlxHeXGmrbSOFZGD50GH9vy(bqYFucrIEumbnsrZIPWsYhJgiKaIdDtLE68zu(rJkFmAGqcio0nvgIDlkWQgxIPYEKhDtIIj5pkjJ3r(tqIeDm1gAMpJYpAuzWR3NI4X(ubNiAHwj53rJuoqj7X(ubNiAHwjzi2TOaRQhspD(mk)OrLbVEFkIh7tfCIOfALKHy3IcqW7hixq)QmqAsL2Y4smfiZNtSSsi2puHO9YcJSkeOJdnwPzWUaMN6hLpFoktcfsaJ6elPX)XYMphLjHcjGrDILK9JgvZOeecFhcjyx(pw285OmjuibmQtSK87G2Y4smfiZNtSSsi2puHO9YcJa(8GrXKiHOdBgSlG5P(r5Z8P)nH0rFiMet14aLSh7tfCIOfALKnUeNiTLXLykqMpNyzLqSFOcr7Lfgb85bJIjrcrh2myx0myEQFu(mF6FtiD0hIjXu0wgxIPaz(CILvcX(HkeTxwym6hy5JIjHBIbe4COdBgSlhOK9yFQGteTqRKSXL4eBaMNIa0zq)sAOTOTmUetbY6oicmQRGLhajHG9ML1XfquSpfHPY8HjdeqW(xHDAlJlXuGSUdIaJ6k4YcJpascb7nlRJlGOyFkIbocOvcGG9Vc70w0wgxIPa5Hj3V8riaHxJIjTLXLykqEyY9xwy8RMXtyFqT0wgxIPa5Hj3FzHr2aIF1mEAlJlXuG8WK7VSW4dGKqWoG2I2Y4smfiphyHWfW8ue4ind2fW8u)O8zMW5ejrDgmhOjXu0wgxIPa55aleEzHXcfDiKCmqXu0wgxIPa55aleEzHrMWOpbejSOI5ZGEAlJlXuG8CGfcVSWi417trodfYgy5PTmUetbYZbwi8YcJaDMF0G8hL0myxaZtra6mOF102GpJYpAuzUPuepenpqm1vecYVdAlJlXuG8CGfcVSWiqN5hni)rjnd2Ltdg2xH5haj)rjej6rXe0ampfbOZG(vtBJ)JLn)nfcocpcbK)dwrXKWhiMbIXVUkdsBzCjMcKNdSq4Lfg5Msr8q08aXuxriG2I2Y4smfiF8GiXBDJjseyuxblpascb7nlRJlEiAE2aIKteaqfTLXLykq(4brI36gtKiWOUcUSW4dGKqWEZY64cebtzLqGiaHNtaPTmUetbYhpis8w3yIebg1vWLfgFaKec2BwwhxmixxiixaKOyI1leTe(arAlJlXuG8XdIeV1nMirGrDfCzHXhajHG9ML1Xf(a6bNWuz(WKbciqemLjdK2Y4smfiF8GiXBDJjseyuxbxwy8bqsiyVzzDCXdrZZgqKCIaaQOTmUetbYhpis8w3yIebg1vWLfgFaKec2BwwhxaZtrcMviiK2Y4smfiF8GiXBDJjseyuxbxwy8bqsiyVzzDCHPs7HoYWsmai6HYKyQMb7IXL4ejyH9abl6tBzCjMcKpEqK4TUXejcmQRGllm(aijeS3SSoU4n41(mfXJ8RKJNarahlosBzCjMcKpEqK4TUXejcmQRGllm(aijeS3SSoUG)PaZtrodasBzCjMcKpEqK4TUXejcmQRGllm(aijeS3SSoU8kUolk0tyQmFyYabeGoJFvHaAlAlJlXuGSaJ6kkGLtdg2xHnlRJlpas(pwwIaJ6kkGMNM6HlPO5tdg2xH5haj)rjej6rXe04aLSh7tfCIOfALKnUeNyQPNEkNgmSVcZpas(Jsis0JIjOX)XYMb6mONmSeRQqxOmjMk)osL2Y4smfilWOUIc4YcJpascb7nlRJlaUbbKHLWcnbHLPiabgSyZGDrZ)hlBgWniGmSewOjiSmfbiWGfjmy(DqBzCjMcKfyuxrbCzHXhajHG9ML1Xfa3GaYWsyHMGWYueGadwSzWU8FSSza3GaYWsyHMGWYueGadwKWG53rJduYESpvWjIwOvs24sCI0wgxIPazbg1vuaxwy8bqsiyVzzDCbOZ8JgONmWpzyjYa7yjnd2Ltdg2xH5)JLLa0wCc3VA7TtBzCjMcKfyuxrbCzHXhajHG9ML1XfMWOtqUkoayZGD50GH9vy()yzjaTfNW9RQNOTmUetbYcmQROaUSW4dGKqWEZY64cty0jixfhaSzWUCAWW(km)FSSeG2It4(v1t0wgxIPazbg1vuaxwyKBkfX4smfrfaPzzDCr3brGrDf0myxetHLK9yFQGt4tbE9djMkJL9vOVXPbd7RWCH3fIOfALq4(vBpn0wTb1PhXYICbqDIotOobANOI6aQrdLwQJfoDQt0HuNyqMOqDqut(fqK6mVpKykt1K6a4HbnbPoDw5vrXK2Y4smfilWOUIc4YcJCtPigxIPiQainlRJla1ObrGrDffaTLXLykqwGrDffWLfgFaKec2BwwhxMteYQgnIIjXQOBeUXeBgSlNgmSVcZpas(pwwIaJ6kkaAlJlXuGSaJ6kkGllm(aijeS3eOgzrGrDff9BgSlcmQROK1pRZaKhaj)hlBJtdg2xH5haj)hllrGrDffaTLXLykqwGrDffWLfgFaKec2BcuJSiWOUIs7nd2fbg1vuYTN1zaYdGK)JLTXPbd7RW8dGK)JLLiWOUIcG2Y4smfilWOUIc4YcJCtPigxIPiQainlRJlhpis8w3yIebg1vqZGDrIoUgBabcr0cTsis0XgNgmSVcZ)hllbOT4eUFT2tdTfTLXLykqw0cTsiauEhlfk6qi5yGIPAgSlNgmSVcZfExiIwOvcH7xv)0sBzCjMcKfTqRecaL3XLfgzcJ(eqKWIkMpd6BgSlNgmSVcZfExiIwOvcH7xvF90ntX4smvg869PiESpvWjIwOvsgVJ8NGej64fJlXuzGoZpAq(JsY4DK)eKirhtTrk8zu(rJkZnLI4HO5bIPUIqqgIDlkWQ6RNUzkgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhVyCjMkdE9(uKZqHSbw(mEh5pbjs0XlgxIPYaDMF0G8hLKX7i)jirIoMA6PFGs2drZdetDfHzi2TOaRDAWW(kmx4DHiAHwjeU)IXLyQm417tr8yFQGteTqRKmEh5pbjs0XuPTmUetbYIwOvcbGY74YcJGxVpf5muiBGLVzWUKYPbd7RWCH3fIOfALq4(v1pT3mfJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJP2if(mk)OrL5Msr8q08aXuxriidXUffyv9t7ntX4smvg869PiESpvWjIwOvsgVJ8NGej64fJlXuzWR3NICgkKnWYNX7i)jirIoMA6PFGs2drZdetDfHzi2TOaRDAWW(kmx4DHiAHwjeU)IXLyQm417tr8yFQGteTqRKmEh5pbjs0Xutn90trZWxHSdKjM1iuSq0diGGzOidlb8oqymqc417tffZgNgmSVcZfExiIwOvcH7xJbttQ0wgxIPazrl0kHaq5DCzHrUPuepenpqm1vecAgSlNgmSVcZfExiIwOvcH7xv)2VzkgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhVyCjMkd0z(rdYFusgVJ8NGej6yQ0wgxIPazrl0kHaq5DCzHrWR3NI4X(ubNiAHwjnd2fj64ASbeierl0kHirhBKYbkzpenpqm1veMnUeNyJduYEiAEGyQRimdXUffynJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJP2ifnlMcljdE9(uKZqHSbw(mw2xH(0t)aL8zOq2alF24sCIP2ifW8ueGod6xst6PNYbkzpenpqm1veMnUeNyJduYEiAEGyQRimdXUffyvJlXuzWR3NI4X(ubNiAHwjz8oYFcsKOJxmUetLb6m)Ob5pkjJ3r(tqIeDm10tpLduYNHczdS8zJlXj24aL8zOq2alFgIDlkWQgxIPYGxVpfXJ9Pcor0cTsY4DK)eKirhVyCjMkd0z(rdYFusgVJ8NGej6yQPNEk)hlBMjm6tarclQy(mOp)oA8FSSzMWOpbejSOI5ZG(me7wuGvnUetLbVEFkIh7tfCIOfALKX7i)jirIoEX4smvgOZ8JgK)OKmEh5pbjs0XutDlBzVb]] )


end
