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
            return first_combat_tyrant - state.combat
        end

        -- We don't have a first_combat_tyrant yet or we aren't actually in combat.
        if cooldown.summon_demonic_tyrant.true_remains > 20 then
            return 0
        end

        return 10
    end )

    spec:RegisterStateExpr( "in_opener", function()
        return time < first_tyrant_time
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

                --[[ elseif spellID == 265187 and InCombatLockdown() and not first_combat_tyrant then
                    first_combat_tyrant = now ]]
                
                end
            end
        
        elseif imps[ source ] and subtype == "SPELL_CAST_START" then
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
        local start, duration = GetSpellCooldown( 265187 )

        if start == 0 then
            first_combat_tyrant = GetTime() + 10
            return
        end

        local tyrant_cd = start + duration
        local now = GetTime()

        if tyrant_cd - now > 20 then
            first_combat_tyrant = now
            return
        end

        first_combat_tyrant = tyrant_cd
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


    spec:RegisterPack( "Demonology", 20220302, [[d4uMfcqiksEekQ6skLc2KuLpjv0OOqDkkKvPuk9kQqZcf6wQQKDjLFjvYWOi1XqPAzsL6zkLQPPQsDnPQQTjvv6BOOKXPQk15KQkADQQI5PQQUhfSpvvCqvvjwOuvEikkMOsj1frrPSrPQcvFuQQGrkvvOCsLsIvQumtuu5MkLK0oPc(PsjPgQsPqlffLQNc0uPiUQuvHyRsvfsFvvvsJvPe7Ls)LWGHCyHfRkpMOjtvxgzZuPpJsgnv0Pf9AuKzJQBRKDl53kgUQYXvkfTCqphQPt66a2Us13rPmEuW5POwVsjjMVuH9RYw2TMyb9Hswh620D3TP3UP7UXoZ63M20)Tfun)rwWVqYuWISGvSil4wtRPg(WYSf8lmZNWBnXcIhaOKSGG5IzSGpGKRBLY(SG(qjRdDB6U720B30D3yNz9BtB6(1cI)iP1HU73(1c6m9EQSplONWsl4wtRPg(WY8H(RbKpsMUnov9d)NU6IvQobEn5S6cNlaEO5usy4QDHZLSRBZw1akDEOUz8qDB6U7(2CBygNrXIW)528Rdb(rC(HyUrYu728RdTvxCZhcsYzTOYFOTMwt9gUEOpi9l5SEHEO09qPEOeFOSWAu6HmEGhYza9YaRhYDGh6nymHnQDB(1H2gh2i4HaZpNtDOGZh2i)H(G0VKZ6f6H05qFWrEOSWAu6H2AAn1B4A728RdTnUVnEin4uPhklLGqGpTDB(1H(l7t6peyF)6N(XM(HdH)I1HyZjvhY8a0jKoun6HI3aOhsNdHbwRPouCitmdJsB3MFDO(X5e2PegUAx9Jo8qtoDiWHVtLEizusIls3djDgflYFiDouwkbHaFQiDB3MFDitGMpKohk2N0Fi2cSMfRdT10AQuEiMzG0HWAizc3Un)6qManFiDo0kyIo08rfbp0hmhyQMp0uCZhITbY0Hs3dXgDizuhkKkqW5Mp08r1HylvNhkoKjMHrPnlipXk2AIfeZh2ekmlMifBnX6a7wtSGufpo5T9zbRyrwq8aW5KQzXsabEMTGsZsoj0aYIuS1b2TGHuZPSG4bGZjvZILac8mBbLWujygwW9aMXJtThGRRaBUKcP)q)FinGSiT5tSgLKouxhQ)h6xhY4d19H22dXs6BRGHdTThApGz84udatI3WvHMRSyHpKrw16q3wtSGufpo5T9zbdPMtzbXa1JpJxelsDAgRwqjmvcMHfCpGz84u7b46kWMlPq6p0)hsdilsB(eRrjPd11H6)HC8qgFOUp02EO9aMXJtnamjEdxfAUYIf(qgzbRyrwqmq94Z4fXIuNMXQvToSDRjwqQIhN82(SGHuZPSG06ZmKcUyG(kkjzbLWujygwW9aMXJtThGRRaBUKcP)q)FiJpKgqwK28jwJsshQRd1)dz0HC8qS39HC8qgFOUp02EO9aMXJtnamjEdxfAUYIf(qgzbRyrwqA9zgsbxmqFfLKSQvTGo)ekmlMWwtSoWU1elivXJtEBFwWkwKfeNLlaxWIh(m0bIf06XPLfmKAoLfeNLlaxWIh(m0bIf06XPLvTo0T1elivXJtEBFwWkwKfeNLlaxe4VegLIf06XPLfmKAoLfeNLlaxe4VegLIf06XPLvTQfuo7ufLkIxYt1S1eRdSBnXcsv84K32NfuctLGzybXda)LLVXco7KiR9K1adnNQrv84K)q9oKXhApGz84uRiguHAggLkK(d9)H620hQJoo0EaZ4XPwrmOc1mmkvi9h6NdTDtFiJSGHuZPSG4bGlGJAvRdDBnXcsv84K32NfuctLGzybXda)LLV5Me3lgxXJpy8SWnQIhN8hQ3H(iT5P1uPuOMHrPTqQ5ozbdPMtzbXdaxah1Qwh2U1elivXJtEBFwqjmvcMHfepa8xw(gBj3lCcuQqdPMsCJQ4Xj)H6DitDOpsBEAnvkfQzyuAlKAUthQ3H2dygpo1kIbvOMHrPcP)q)Ci2)Blyi1CkliEa4c4Ow16WVTMybPkECYB7ZcgsnNYc6jzUcnlwI3WvlOeMkbZWcAQdThWmECQbGjXB4QqZvwSWhQ3HWda)LLVXPWlEMfedX6JtnQIhN8hQ3Hm(qFK280AQukuZWO0wi1CNouVdHhaUa7mG(d9)H6(qD0XHm1H(iT5P1uPuOMHrPTqQ5oDOEhApGz84uRiguHAggLkK(d9ZH(TPpKrwqPzjNeAazrk26a7w16q)TMybPkECYB7ZcgsnNYc6jzUcnlwI3WvlOeMkbZWcAQdThWmECQbGjXB4QqZvwSWhQ3HWda)LLVXeTNfwmZwfINfRgvXJt(d17qgFOpsBEAnvkfQzyuAlKAUthQJooKPo0hPnpTMkLc1mmkTfsn3Pd17q7bmJhNAfXGkuZWOuH0FOFo0Vn9HmYcknl5KqdilsXwhy3Qwh6xRjwqQIhN82(SGHuZPSGEsMRqZIL4nC1ckHPsWmSGM6q7bmJhNAays8gUk0CLfl8H6DiJpeEa4VS8n3bYIEdSibK2jys4gvXJt(d1rhhY4dHha(llFBF4HMCsGh(ovAJQ4Xj)H6DitDi8aWFz5Bmr7zHfZSvH4zXQrv84K)qgDiJouVdzQd9rAZtRPsPqndJsBHuZDYcknl5KqdilsXwhy3QwhywwtSGufpo5T9zbdPMtzb9KmxHMflXB4QfuctLGzyb3dygpo1aWK4nCvO5klw4d17qgFitDin4uPTVHnckW5NZPAufpo5puhDCi5mC)Ww1(g2iOaNFoNQbPvKf(q)FOqQ5unpjZvOzXs8gU2igijGscnx0Hm6q9oKPoKCgUFyRAyG1AkHNwtLsHAggL2a(ouVdz8H(iT5P1uPuOMHrPniTISWh6)d93hQJooKCgUFyRAyG1AkHNwtLsHAggL2G0kYclig(iPs(d9)H2UPpKrwqPzjNeAazrk26a7w16WFBnXcsv84K32NfmKAoLf0LtyNsy4QwqjmvcMHfepa8xw(2(Wdn5Kap8DQ0gvXJt(d17qpax32(Wdn5Kap8DQ0MFyRSGzPeec8PI01c(aCDB7dp0Ktc8W3PsBaFw16q)0AIfKQ4XjVTplOeMkbZWcIha(llFtoRxOIf5tn0CQgvXJt(d17qFK280AQukuZWO0wi1CNSGHuZPSGy5aaZILqt1jzvRdSBARjwqQIhN82(SGsyQemdlOPoeEa4VS8n5SEHkwKp1qZPAufpo5TGHuZPSGy5aaZILqt1jzvRdSZU1elivXJtEBFwqjmvcMHf8J0MNwtLsHAggL2cPM70H6Di8aWfyNb0FidhY0wWqQ5uwWC9rLplwczObwHZNtYQw1cQMHrPcmPaFwtSoWU1elivXJtEBFwqjmvcMHfCpGz84uRiguHAggLkK(d9)HyV)wWqQ5uwWIuNeu8nqn4w16q3wtSGufpo5T9zbLWujygwW9aMXJtTIyqfQzyuQq6p0)hIDM1H(1Hm(qHuZPAyG1AkHNwtLsHAggL2igijGscnx0HC8qHuZPAyNHFyt8gU2igijGscnx0Hm6q9oKXhsod3pSvnzW5cpKcpwdotee3G0kYcFO)pe7mRd9Rdz8HcPMt1WaR1ucpTMkLc1mmkTrmqsaLeAUOd54HcPMt1WaR1uI9KtUjv(gXajbusO5IoKJhkKAovd7m8dBI3W1gXajbusO5IoKrhQJoo0hPnpKcpwdoteSbPvKf(q)CO9aMXJtTIyqfQzyuQq6pKJhkKAovddSwtj80AQukuZWO0gXajbusO5IoKrwWqQ5uwqwWCnjKeUeNfqa9w16W2TMybPkECYB7ZckHPsWmSGgFO9aMXJtTIyqfQzyuQq6p0)hI9(FOFDiJpui1CQggyTMs4P1uPuOMHrPnIbscOKqZfDiJouVdz8HKZW9dBvtgCUWdPWJ1GZebXniTISWh6)dXE)p0VoKXhkKAovddSwtj80AQukuZWO0gXajbusO5IoKJhkKAovddSwtj2to5Mu5BedKeqjHMl6qgDOo64qFK28qk8yn4mrWgKwrw4d9ZH2dygpo1kIbvOMHrPcP)qoEOqQ5unmWAnLWtRPsPqndJsBedKeqjHMl6qgDiJouhDCiJpKPoeeOi3bYIASLCxi5XcCYk5IXvGb(iyoqbgyTMklwnQIhN8hQ3H2dygpo1kIbvOMHrPcP)q)COFB6dzKfmKAoLfedSwtj2to5Mu5TQ1HFBnXcsv84K32NfuctLGzyb3dygpo1kIbvOMHrPcP)q)Fi27(q)6qgFOqQ5unmWAnLWtRPsPqndJsBedKeqjHMl6qoEOqQ5unSZWpSjEdxBedKeqjHMl6qgzbdPMtzbLbNl8qk8yn4mrqSvTo0FRjwqQIhN82(SGsyQemdlOMl6q)Ci3eIvHAggLk0CrhQ3Hm(qFK28qk8yn4mrWwi1CNouVd9rAZdPWJ1GZebBqAfzHp0phkKAovddSwtj80AQukuZWO0gXajbusO5IoKrhQ3Hm(qM6qAWPsByG1AkXEYj3KkFJQ4Xj)H6OJd9rABp5KBsLVfsn3Pdz0H6DiJpeEa4cSZa6pKHdz6d1rhhY4d9rAZdPWJ1GZebBHuZD6q9o0hPnpKcpwdoteSbPvKf(q)FOqQ5unmWAnLWtRPsPqndJsBedKeqjHMl6qoEOqQ5unSZWpSjEdxBedKeqjHMl6qgDOo64qgFOpsB7jNCtQ8TqQ5oDOEh6J02EYj3KkFdsRil8H()qHuZPAyG1AkHNwtLsHAggL2igijGscnx0HC8qHuZPAyNHFyt8gU2igijGscnx0Hm6qD0XHm(qpax3glyUMescxIZciG(gW3H6DOhGRBJfmxtcjHlXzbeqFdsRil8H()qHuZPAyG1AkHNwtLsHAggL2igijGscnx0HC8qHuZPAyNHFyt8gU2igijGscnx0Hm6qgzbdPMtzbXaR1ucpTMkLc1mmk1Qw1c6j3aGRwtSoWU1elivXJtEBFwqpHLW8tZPSGmBmqsaL8hI2jO5dP5IoK6Koui1bEOeFOypsE84uZcgsnNYcI)ioxWhjtw16q3wtSGHuZPSGYGZfUe3jqPe0csv84K32NvToSDRjwWqQ5uwWGbsOdgBbPkECYB7ZQwh(T1elyi1CklON2haOyfSsPfKQ4XjVTpRADO)wtSGufpo5T9zbNpliMulyi1Ckl4EaZ4Xjl4EWbilOCgUFyRAyG1AkHNwtLsHAggL2G0kYclig(iPsElOeMkbZWcAQdHha(llFZnjUxmUIhFW4zHBufpo5puhDCi5mC)Ww1WaR1ucpTMkLc1mmkTbPvKfwqm8rsL8h6NdjNH7h2QgEa4c4OniTISWcIHpsQK3cUhqrflYcwedQqndJsfsVvTo0VwtSGufpo5T9zbNpliMulyi1Ckl4EaZ4Xjl4EWbilOCgUFyRA4bGlGJ2G0kYclig(iPsElOeMkbZWcIha(llFZnjUxmUIhFW4zHBufpo5puVdjNH7h2QggyTMs4P1uPuOMHrPniTISWcIHpsQK)q)Fi5mC)Ww1WdaxahTbPvKfwqm8rsL8wW9akQyrwWIyqfQzyuQq6TQ1bML1elivXJtEBFwW5ZcIj1cgsnNYcUhWmECYcUhCaYcUhWmECQvedQqndJsfsVfuctLGzybn1H2dygpo1aWK4nCvO5klw4d17qM6qzjMpQiOfCpGIkwKf8b46kWMlPq6TQ1H)2AIfKQ4XjVTpl48zbXKAbdPMtzb3dygpozb3doazbzVBlOeMkbZWcAQdThWmECQbGjXB4QqZvwSWhQ3HYsmFurWd17qM6qFK28qk8yn4mrWwi1CNSG7buuXISGpaxxb2CjfsVvTo0pTMybPkECYB7ZcoFwqmPwWqQ5uwW9aMXJtwW9GdqwqtBbLWujygwqtDO9aMXJtnamjEdxfAUYIf(q9ouwI5JkcEOEh6J0MhsHhRbNjc2cPM70H6DOhGRBJTK7f56d3WAiz6q)CitFOEhYuhsdovABp5KBsLVrv84K3cUhqrflYc(aCDfyZLui9w16a7M2AIfKQ4XjVTpl48zbXKAbdPMtzb3dygpozb3doazbnTfuctLGzybn1H2dygpo1aWK4nCvO5klw4d17qzjMpQi4H6DOpsBEifESgCMiylKAUthQ3H(G0UGL03yV5mkVyCfSa4(OouVdPbNkTTNCYnPY3OkECYBb3dOOIfzbFaUUcS5skKERADGD2TMybPkECYB7ZcoFwqmPwWqQ5uwW9aMXJtwW9Gdqwq5mC)Ww18KmxHMflXB4AdsRilSGy4JKk5TGsyQemdl4EaZ4XPgaMeVHRcnxzXcBb3dOOIfzbFaUUcS5skKERADG9UTMybPkECYB7ZcgsnNYckdoxesnNsWtSAb5jwfvSilOcZIjsXw16a7B3AIfKQ4XjVTplOeMkbZWcA8Hm1H2dygpo1aWK4nCvO5klw4d17qFK280AQukuZWO0wi1CNoKrhQJooKXhApGz84udatI3WvHMRSyHpuVd9aCDByNb0lgxruv6m5HMt1a(ouVdz8Hm1H0GtL2(g2iOaNFoNQrv84K)qD0XHEaUUTVHnckW5NZPAaFhYOdzKfmKAoLfugCUiKAoLGNy1cYtSkQyrwWHL0BvRdS)BRjwqQIhN82(SGsyQemdl4BW4d17qUjlNQasRil8H()qDFOT9qSKElyi1CklyU(4doNYQwhyV)wtSGufpo5T9zbLWujygwqDyXItn5mC)WwHpuVdP5Io0)hYnHyvOMHrPcnxKfeRWuQwhy3cgsnNYckdoxesnNsWtSAb5jwfvSil48rfbTQ1b27xRjwqQIhN82(SGsyQemdliKCHe2z84KfmKAoLf0pZYQwhyNzznXcsv84K32NfuctLGzybXda)LLVXco7KiR9K1adnNQrv84K)qD0XHWda)LLV5Me3lgxXJpy8SWnQIhN8hQJooeEa4VS8n5SEHkwKp1qZPAufpo5puhDCi5StvuARijC4d0BbXkmLQ1b2TGHuZPSGYGZfHuZPe8eRwqEIvrflYckNDQIsfXl5PA2Qwhy)VTMybPkECYB7ZckHPsWmSG7bmJhNAays8gUk0CLfl8H6DOhGRBd7mGEX4kIQsNjp0CQgWNfmKAoLf8ByJGcC(5CkRADG9(P1elivXJtEBFwqjmvcMHf04dzQdThWmECQbGjXB4QqZvwSWhQ3H2dygpo1kIbvOMHrPcP)q)FiwsFBfmCOEhsZfDOFoKBcXQqndJsfAUOd1rhhcpa8xw(gKCZI8IVGhk1OkECYFOEhApGz84uRiguHAggLkK(d9)H2(FFiJouhDCiJp0EaZ4XPgaMeVHRcnxzXcFOEh6b462WodOxmUIOQ0zYdnNQb8DiJSGHuZPSGFJMtzvRdDBARjwqQIhN82(SGHuZPSGYGZfHuZPe8eRwqEIvrflYcQMHrPcmPaFw16q3SBnXcsv84K32NfuctLGzybn(qM6qqGIChilQXwYDHKhlWjRKlgxbg4JG5afyG1AQSy1OkECYFOEhApGz84uRiguHAggLkK(d9ZH6NhYOd1rhhY4d9rAZtRPsPqndJsBHuZD6q9o0hPnpTMkLc1mmkTbPvKf(q)FO(9qB7Hyj9TvWWHmYcgsnNYc6P1uPuGvivSuNw16q3DBnXcsv84K32NfuctLGzyb3dygpo1aWK4nCvO5klw4d17qYz4(HTQHbwRPeEAnvkfQzyuAdsRilSGy4JKk5p0phQ7UTGHuZPSGYGZfEifESgCMii2Qwh6E7wtSGufpo5T9zbLWujygwqtDO9aMXJtnamjEdxfAUYIf(q9oKXhApGz84uRiguHAggLkK(d9ZH620h6xhQ)hABpKPoeeOi3bYIASLCxi5XcCYk5IXvGb(iyoqbgyTMklwnQIhN8hYilyi1CklOm4CHhsHhRbNjcITQ1HU)T1elivXJtEBFwqjmvcMHf0uhApGz84udatI3WvHMRSyHpuVd9aCDBSLCVixF4gwdjth6NdX(H6DOhGRBZtRPsPqoqQH1qY0H()qB3cgsnNYc(nSrqbo)CoLvTo0D)TMybPkECYB7ZckHPsWmSGpax3MAggL28dB1H6DO9aMXJtTIyqfQzyuQq6p0phQ)wWqQ5uwWxYjSCaGSiXBwpcITQ1HU7xRjwqQIhN82(SGsyQemdlyi1CNeurRKWh6NdX(HC8qgFi2p02Ein4uPnCiHPBkjVapaCCJQ4Xj)Hm6q9o0dW1TXwY9IC9HBynKmDOFmCO(9q9o0dW1TPMHrPn)WwDOEhApGz84uRiguHAggLkK(d9ZH6VfmKAoLfmxF8bNtzvRdDZSSMybPkECYB7ZckHPsWmSGHuZDsqfTscFOFou3hQ3HEaUUn2sUxKRpCdRHKPd9JHd1VhQ3HEaUUn1mmkT5h2Qd17q7bmJhNAfXGkuZWOuH0FOFou)puVdzQdbbkYDGSOwU(4do3jX3OuPzWBufpo5puVdz8Hm1H0GtL2CHZsOojb2z4h2WnQIhN8hQJooKNEaUUnx4SeQtsGDg(HnCd47qgzbdPMtzbZ1hFW5uw16q3)T1elivXJtEBFwqjmvcMHfmKAUtcQOvs4d9ZH6(q9o0dW1TXwY9IC9HBynKmDOFmCO(9q9o0dW1TLRp(GZDs8nkvAg8gKwrw4d9)H6(q9oeeOi3bYIA56Jp4CNeFJsLMbVrv84K3cgsnNYcMRp(GZPSQ1HU7NwtSGufpo5T9zbLWujygwWhGRBJTK7f56d3WAiz6q)y4qS39H6Din4uPn8aWfYP8aP2OkECYFOEhsdovAZfolH6KeyNHFyd3OkECYFOEhccuK7azrTC9XhCUtIVrPsZG3OkECYFOEh6b462uZWO0MFyRouVdThWmECQvedQqndJsfs)H(5q93cgsnNYcMRp(GZPSQ1HTBARjwqQIhN82(SGsyQemdl4BW4d17qAUiHocFsh6)dTDtBbdPMtzbzbZ1Kqs4sCwab0BvRdBNDRjwqQIhN82(SGsyQemdl4BW4d17qAUiHocFsh6)d19FBbdPMtzbXaR1uI9KtUjvERADy7DBnXcsv84K32NfuctLGzybFdgFOEhsZfj0r4t6q)Fi27VfmKAoLfedSwtj80AQukuZWOuRADy7B3AIfKQ4XjVTplOeMkbZWcIhaUa7mG(dz4q93cgsnNYc6mkVyCfSa4(OSQ1HT)BRjwqQIhN82(SGsyQemdliEa4cSZa6p0)hQ)hQ3HGaf5oqwu7fCc)LEcIfpayLflHCGuJQ4Xj)H6DOhGRB7fCc)LEcIfpayLflHCGudsRil8H()q93cgsnNYcIDg(HnXB4QvToS9(BnXcsv84K32NfmKAoLf0zuEX4kybW9rzb9ewcZpnNYcUvCp0wdPWJ1GZebXhkG0HcoKcV5dfsn3jgpunhQiYFiDoeo2PdHDgqp2ckHPsWmSG4bGlWodO)q)y4qB)q9oKXh6J0MhsHhRbNjc2cPM70H6OJd9rAZtRPsPqndJsBHuZD6qgzvRdBVFTMybPkECYB7ZckHPsWmSG4bGlWodO)q)y4qSFOEh6b462ksDsqX3a1G3a(ouVdjNH7h2QMm4CHhsHhRbNjcIBqAfzHp0phQ7dTThIL03wbdwWqQ5uwqNr5fJRGfa3hLvToSDML1elivXJtEBFwqjmvcMHfepaCb2za9h6hdhI9d17qpax3gBj3lY1hUH1qY0H(5qDFOEhApGz84uRiguHAggLkK(d9)Hyj9TvWWH6Dinx0H(5qUjeRc1mmkvO5Io0VoelPVTcgSGHuZPSGoJYlgxblaUpkRADy7)T1elivXJtEBFwqjmvcMHf0uhso7ufL22PsDAgAbXkmLQ1b2TGHuZPSGYGZfHuZPe8eRwqEIvrflYckNDQIsfXl5PA2Qwh2E)0AIfKQ4XjVTplyi1CkliEa4cSctMilONWsy(P5uwW)AQoha9qGHeMUPK8hcCa4ygpe4aWpeOctMOdL4dHv4uSi4HuNrDOTMwt9gUY4HWZHs9qod8HId5mz5KGh6dMdmvZwqjmvcMHf0uhsdovAdhsy6MsYlWdah3OkECYBvRd)20wtSGufpo5T9zbdPMtzb90AQ3WvlONWsy(P5uwqWpQ8hARP1uP8qmZaj8HCh4Haha(HaDgqp(qaLM8dzIzyu6HKZW9dB1Hs8HK8bthsNdbPWB2ckHPsWmSGpax3MNwtLsHCGudsHupuVdHhaUa7mG(d9)H(9H6DO9aMXJtTIyqfQzyuQq6p0phQBtBvRd)MDRjwqQIhN82(SGHuZPSGEAn1B4Qf0tyjm)0Ckl4wdaZI1HmXmmk9qysb(y8q4pQ8hARP1uP8qmZaj8HCh4Haha(HaDgqp2ckHPsWmSGpax3MNwtLsHCGudsHupuVdHhaUa7mG(d9)H(9H6DO9aMXJtTIyqfQzyuQq6p0)hI9UTQ1HF3T1elivXJtEBFwqjmvcMHf8b46280AQukKdKAqkK6H6Di8aWfyNb0FO)p0VpuVdz8HEaUUnpTMkLc5aPgwdjth6Nd19H6OJdPbNkTHdjmDtj5f4bGJBufpo5pKrwWqQ5uwqpTM6nC1Qwh(92TMybPkECYB7ZckHPsWmSGysfVPaWnnjy3)TO7p5H6Di8aWfyNb0FO)p0VpuVdz8Hm(q97H(1HWdaxGDgq)Hm6qB7HcPMt1Wod)WM4nCTrmqsaLeAUOd9ZH(iT5Hu4XAWzIGniTISWh6xhkKAovZzuEX4kybW9r1igijGscnx0H(1HcPMt180AQ3W1gXajbusO5IoKrhQ3HEaUUnpTMkLc5aPgwdjth6hdhIDlyi1CklONwt9gUAvRd)(3wtSGufpo5T9zbLWujygwWhGRBZtRPsPqoqQbPqQhQ3HWdaxGDgq)H()q)(q9oui1CNeurRKWh6NdXUfmKAoLf0tRPEdxTQ1HF3FRjwWqQ5uwq8aWfyfMmrwqQIhN82(SQ1HF3VwtSGufpo5T9zbdPMtzbLbNlcPMtj4jwTG8eRIkwKfuo7ufLkIxYt1SvTo8BML1elivXJtEBFwWqQ5uwqNr5fJRGfa3hLf0tyjm)0Ckl4wX9qMhGdjJ6qSi9qVqY0H05q9)qGda)qGodOhFOh5oq6qBnKcpwdoteeFi5mC)WwDOeFiifEZmEOu7eFOHPW8H05q4pQ8hsDsRdvdBwqjmvcMHfepaCb2za9h6hdhA7hQ3H2dygpo1kIbvOMHrPcP)q)COU7)H6DiJpKgCQ0MNwtLsHm48Sy1OkECYFOo64qYz4(HTQjdox4Hu4XAWzIG4gKwrw4d9ZHm(qgFO(FOFDi8aWfyNb0FiJo02EOqQ5unSZWpSjEdxBedKeqjHMl6qgDihpui1CQMZO8IXvWcG7JQrmqsaLeAUOdzKvTo87)2AIfKQ4XjVTplyi1CklOFMLfuctLGzybHKlKWoJhNouVdP5Io0phYnHyvOMHrPcnxKfuAwYjHgqwKIToWUvTo87(P1elivXJtEBFwWqQ5uwqpTM6nC1c6jSeMFAoLfSFemDOTMwt9gUEO09qMhGoH0HynzX6q6Ci(GPdT10AQuEiMzG0HWAizcZ4HODQou6EOu70Fi2cSshkoeEa4hc7mG(MfuctLGzybFaUUnpTMkLc5aPgKcPEOEh6b46280AQukKdKAqAfzHp0)hI9d54Hyj9TvWWH22d9aCDBEAnvkfYbsnSgsMSQ1H(BARjwWqQ5uwqSZWpSjEdxTGufpo5T9zvRAb)GKCwVqTMyDGDRjwqQIhN82(SGHuZPSGUex4NvwHMtzb9ewcZpnNYcYSXajbuYFOh5oq6qYz9c9qpIvw42H(lsj9P4dvt9lNbC5cWpui1Ck8HMIBUzbLWujygwqnx0H(5qM(q9oKPo0hPTGN7KvTo0T1elyi1CkligyTMs4sCwab0BbPkECYB7ZQwh2U1elivXJtEBFwWkwKfuNfjgxXAkSchaSqofwHasnNcBbdPMtzb1zrIXvSMcRWbalKtHviGuZPWw16WVTMybPkECYB7ZcwXISG4HtHtSatsiPcLKoRCBcqwWqQ5uwq8WPWjwGjjKuHssNvUnbiRADO)wtSGHuZPSGUCc7ucdx1csv84K32NvTo0VwtSGufpo5T9zbLWujygwWhGRBJTK7f56d3WAiz6q)Ci2puVd9aCDBEAnvkfYbsnSgsMo0)gou3wWqQ5uwWVHnckW5NZPSQ1bML1elivXJtEBFwWkwKfe7m8dBKxmWNyCf6axuPwWqQ5uwqSZWpSrEXaFIXvOdCrLAvRd)T1elivXJtEBFwqjmvcMHf04d9gm(qD0XHcPMt180AQ3W1MmW6HmCitFiJouVdHhaUa7mGE8H()q)2cgsnNYc6P1uVHRw16q)0AIfKQ4XjVTplOeMkbZWcAQdz8HEdgFOo64qHuZPAEAn1B4Atgy9qgoKPpKrhQJooeEa4cSZa6Xh6NdTDlyi1Ckli2z4h2eVHRw16a7M2AIfKQ4XjVTpl48zbXKAbdPMtzb3dygpozb3doazbHaf5oqwu7fCc)LEcIfpayLflHCGuJQ4Xj)H6DiiqrUdKf1WodOxmUIOQ0zYdnNQrv84K3cUhqrflYccGjXB4QqZvwSWw1QwW5JkcAnX6a7wtSGufpo5T9zbLWujygwq8aWFz5BSGZojYApznWqZPAufpo5TGHuZPSG4bGlGJAvRdDBnXcgsnNYcwK6KGIVbQb3csv84K32NvToSDRjwWqQ5uwqwWCnjKeUeNfqa9wqQIhN82(SQ1HFBnXcgsnNYcIbwRPe7jNCtQ8wqQIhN82(SQ1H(BnXcsv84K32NfuctLGzybXdaxGDgq)H()q9)q9oKCgUFyRAYGZfEifESgCMiiUb8zbdPMtzbXod)WM4nC1Qwh6xRjwqQIhN82(SGsyQemdl4EaZ4XPgaMeVHRcnxzXcFOEhcpaCb2za9h6)d1)d17qpax32l4e(l9eelEaWklwc5aPgwdjth6)d9Blyi1Ckli2z4h2eVHRw16aZYAIfmKAoLfugCUWdPWJ1GZebXwqQIhN82(SQvTGkmlMifBnX6a7wtSGufpo5T9zbdPMtzbXod)Wg5fd8jgxHoWfvQfuctLGzyb3dygpo1EaUUcS5skK(d9)H6UBlyflYcIDg(HnYlg4tmUcDGlQuRADOBRjwqQIhN82(SGvSiliwgqSyCfUWqjyfCbwHPlzbdPMtzbXYaIfJRWfgkbRGlWkmDjRADy7wtSGufpo5T9zbLWujygwqn4uPnpTMkLc5uyG1NMt1OkECYFOEhApGz84uRiguHAggLkK(d9)H620wWqQ5uwqzW5IqQ5ucEIvlipXQOIfzbD(juywmHTQ1HFBnXcsv84K32Nf0tyjm)0CkliZMRljv8HuNHEifg7e)qy(Wg38H05qAazr6HG02eiH0HcVp1CQGZ4HW0xadLoKZO88SyzbdPMtzbLbNlcPMtj4jwTG8eRIkwKfeZh2ekmlMifBvRd93AIfKQ4XjVTplyi1Ckl4Stqx(WwwSerLRqidwKfuctLGzybn(qM6q7bmJhNAays8gUk0CLfl8H6DOpsBEAnvkfQzyuAlKAUthYOd1rhhY4dThWmECQbGjXB4QqZvwSWhQ3HEaUUnSZa6fJRiQkDM8qZPAaFhYilyflYco7e0LpSLflru5keYGfzvRd9R1elivXJtEBFwWqQ5uwqfMftKYUfuctLGzybvywmrAtzV5mWcamjEaUUhQ3Hm(qgFitDO9aMXJtnamjEdxfAUYIf(q9o0hPnpTMkLc1mmkTfsn3Pdz0H6OJdz8H2dygpo1aWK4nCvO5klw4d17qpax3g2za9IXvevLotEO5unGVdz0HmYcI5JAbvywmrk7w16aZYAIfKQ4XjVTplyi1CklOcZIjs72ckHPsWmSGkmlMiTPD3CgybaMepax3d17qgFiJpKPo0EaZ4XPgaMeVHRcnxzXcFOEh6J0MNwtLsHAggL2cPM70Hm6qD0XHm(q7bmJhNAays8gUk0CLfl8H6DOhGRBd7mGEX4kIQsNjp0CQgW3Hm6qgzbX8rTGkmlMiTBRAD4VTMybPkECYB7ZckHPsWmSGAUOd9ZHCtiwfQzyuQqZfDOEhApGz84u7b46kWMlPq6p0phQBtBbdPMtzbLbNlcPMtj4jwTG8eRIkwKf8dascFScwKqHzXe2Qw1c(bajHpwblsOWSycBnX6a7wtSGufpo5T9zbRyrwqpKcVBcjXoHXe3cgsnNYc6Hu4Dtij2jmM4w16q3wtSGufpo5T9zbRyrwqwWCjijp)WKfmKAoLfKfmxcsYZpmzvRdB3AIfKQ4XjVTplyflYccj8urPciHj4(Kqlyi1CkliKWtfLkGeMG7tcTQ1HFBnXcsv84K32NfSIfzbdO0zQKuXISyrfqQMfYbswWqQ5uwWakDMkjvSilwubKQzHCGKvTo0FRjwqQIhN82(SGvSilOCWRukyXdFg6aXciHNk0bAbdPMtzbLdELsblE4Zqhiwaj8uHoqRADOFTMybPkECYB7ZcwXISGEifE3esIDcJjUfmKAoLf0dPW7MqsStymXTQ1bML1elivXJtEBFwWkwKfepaCrYQsLGwWqQ5uwq8aWfjRkvcAvRd)T1elivXJtEBFwWqQ5uwqwCZFofJRiW4CL8qZPSGsyQemdlyi1CNeurRKWhYWHy3cwXISGS4M)CkgxrGX5k5HMtzvRd9tRjwqQIhN82(SGvSilOpGmTMPeEsYK4dqHewsLKSGHuZPSG(aY0AMs4jjtIpafsyjvsYQwhy30wtSGufpo5T9zbRyrwq6nfEa4I9etwWqQ5uwq6nfEa4I9etw16a7SBnXcsv84K32NfSIfzbbkPZilYlyXdFg6aXcSZqYeNWwWqQ5uwqGs6mYI8cw8WNHoqSa7mKmXjSvTQfCyj9wtSoWU1elyi1Ckl4JGycYuwSSGufpo5T9zvRdDBnXcgsnNYc(4Z4fUaqZwqQIhN82(SQ1HTBnXcgsnNYc6Mq6XNXBbPkECYB7ZQwh(T1elyi1CkliaMePslSfKQ4XjVTpRAvRAb3jioNY6q3MU7UnD3DZSSGSfWklwyl4F9VWS7WwXH(H)COdzIt6q56BG6HCh4H6eZh2ekmlMif35HG02eiHK)q4zrhka0zfk5pK0zuSiC72WCzrhI9)CiMzQDcQK)qG5Izoe2CPbdhAB4q6CiMdioKp3tCo1HMpcg6apKXDz0HmMDgmQDByUSOd19FoeZm1obvYFiWCXmhcBU0GHdTnCiDoeZbehYN7joN6qZhbdDGhY4Um6qgZodg1Unmxw0H2(FoeZm1obvYFiWCXmhcBU0GHdTnCiDoeZbehYN7joN6qZhbdDGhY4Um6qgZodg1Un3M)6FHz3HTId9d)5qhYeN0HY13a1d5oWd1PC2PkkveVKNQ5opeK2MajK8hcpl6qbGoRqj)HKoJIfHB3gMll6qS)NdXmtTtqL8hQt8aWFz5BBPZdPZH6epa8xw(2wAufpo578qgZodg1Unmxw0H6(phIzMANGk5puN4bG)YY32sNhsNd1jEa4VS8TT0OkECY35HmMDgmQDByUSOdT9)CiMzQDcQK)qDIha(llFBlDEiDouN4bG)YY32sJQ4XjFNhYy2zWO2TH5YIo0V)ZHy2P1St(dTY6pB5qsNKKPdzCn6HI9i5XJthkRdrlaEO5ugDiJzNbJA3gMll6q)(phIzMANGk5puN4bG)YY32sNhsNd1jEa4VS8TT0OkECY35HmMDgmQDByUSOd1))CiMDAn7K)qRS(ZwoK0jjz6qgxJEOypsE840HY6q0cGhAoLrhYy2zWO2TH5YIou))ZHyMP2jOs(d1jEa4VS8TT05H05qDIha(llFBlnQIhN8DEiJzNbJA3gMll6q97FoeZm1obvYFOoXda)LLVTLopKohQt8aWFz5BBPrv84KVZdz82zWO2TH5YIoeZ6phIzMANGk5puNAWPsBBPZdPZH6udovABlnQIhN8DEiJzNbJA3gMll6q)9FoeZm1obvYFOoXda)LLVTLopKohQt8aWFz5BBPrv84KVZdzm7myu72WCzrhQF(NdXmtTtqL8hQt8aWFz5BBPZdPZH6epa8xw(2wAufpo578qgZodg1Unmxw0Hy30)5qmZu7euj)H6epa8xw(2w68q6COoXda)LLVTLgvXJt(opuOhIzBRM5oKXSZGrTBZT5V(xy2DyR4q)WFo0HmXjDOC9nq9qUd8qDQMHrPcmPaFDEiiTnbsi5peEw0HcaDwHs(djDgflc3Unmxw0H2(FoeZm1obvYFOoHaf5oqwuBlDEiDouNqGIChilQTLgvXJt(opKXSZGrTBZT5V(xy2DyR4q)WFo0HmXjDOC9nq9qUd8qD6j3aGRDEiiTnbsi5peEw0HcaDwHs(djDgflc3Unmxw0H6)FoeZm1obvYFOoXda)LLVTLopKohQt8aWFz5BBPrv84KVZdzm7myu72WCzrhQF)ZHyMP2jOs(d1jEa4VS8TT05H05qDIha(llFBlnQIhN8DEiJzNbJA3gMll6qSZS(ZHyMP2jOs(d1jEa4VS8TT05H05qDIha(llFBlnQIhN8DEiJ3odg1Unmxw0HyVF(NdXmtTtqL8hQt8aWFz5BBPZdPZH6epa8xw(2wAufpo578qgZodg1Unmxw0H6M9)CiMzQDcQK)qDcbkYDGSO2w68q6COoHaf5oqwuBlnQIhN8DEiJzNbJA3gMll6qDV9)CiMzQDcQK)qDcbkYDGSO2w68q6COoHaf5oqwuBlnQIhN8DEiJzNbJA3gMll6qDZS(ZHyMP2jOs(d1jeOi3bYIABPZdPZH6ecuK7azrTT0OkECY35HmMDgmQDByUSOd19F)NdXmtTtqL8hQtiqrUdKf12sNhsNd1jeOi3bYIABPrv84KVZdf6Hy22QzUdzm7myu72WCzrhQ7(5FoeZm1obvYFOoHaf5oqwuBlDEiDouNqGIChilQTLgvXJt(opKXSZGrTBdZLfDOT)7)CiMzQDcQK)qDcbkYDGSO2w68q6COoHaf5oqwuBlnQIhN8DEiJzNbJA3MBZF9VWS7WwXH(H)COdzIt6q56BG6HCh4H68dsYz9cTZdbPTjqcj)HWZIouaOZkuYFiPZOyr42TH5YIoe7M(phIzMANGk5puNqGIChilQTLopKohQtiqrUdKf12sJQ4XjFNhk0dXSTvZChYy2zWO2TH5YIoe7M(phIzMANGk5puNqGIChilQTLopKohQtiqrUdKf12sJQ4XjFNhYy2zWO2T528x)lm7oSvCOF4ph6qM4KouU(gOEi3bEOovywmrkUZdbPTjqcj)HWZIouaOZkuYFiPZOyr42TH5YIou)(NdXmtTtqL8hQtfMftK2yVTLopKohQtfMftK2u2BBPZdzm7myu72WCzrhIz9NdXmtTtqL8hQtfMftK26UTLopKohQtfMftK20UBBPZdzm7myu72CB(R)fMDh2ko0p8NdDitCshkxFdupK7apuNZhveSZdbPTjqcj)HWZIouaOZkuYFiPZOyr42TH5YIoe7)5qmZu7euj)H6epa8xw(2w68q6COoXda)LLVTLgvXJt(opuOhIzBRM5oKXSZGrTBZTzRS(gOs(dXUPpui1CQdXtSIB3glyaOohOf0c(bh3KtwqMN5p0wtRPg(WY8H(RbKpsMUnmpZFiNQ(H)txDXkvNaVMCwDHZfap0CkjmC1UW5s21TH5z(dTvnGsNhQBgpu3MU7UVn3gMN5peZ4mkwe(p3gMN5p0Voe4hX5hI5gjtTBdZZ8h6xhARU4MpeKKZArL)qBnTM6nC9qFq6xYz9c9qP7Hs9qj(qzH1O0dz8apKZa6LbwpK7ap0BWycBu72W8m)H(1H2gh2i4HaZpNtDOGZh2i)H(G0VKZ6f6H05qFWrEOSWAu6H2AAn1B4A72W8m)H(1H2g33gpKgCQ0dLLsqiWN2UnmpZFOFDO)Y(K(db23V(PFSPF4q4VyDi2Cs1HmpaDcPdvJEO4na6H05qyG1AQdfhYeZWO02TH5z(d9Rd1poNWoLWWv7QF0HhAYPdbo8DQ0djJssCr6EiPZOyr(dPZHYsjie4tfPB72W8m)H(1HmbA(q6COyFs)HylWAwSo0wtRPs5HyMbshcRHKjC72W8m)H(1HmbA(q6COvWeDO5JkcEOpyoWunFOP4MpeBdKPdLUhIn6qYOouivGGZnFO5JQdXwQopuCitmdJsB3MBdZFiMngijGs(d9i3bshsoRxOh6rSYc3o0FrkPpfFOAQF5mGlxa(HcPMtHp0uCZTBti1CkC7dsYz9c1rdD5sCHFwzfAofJPRbnx0pMUNP(iTf8CNUnHuZPWTpijN1luhn0fgyTMs8r6TjKAofU9bj5SEH6OHUaWKivAXyflYGolsmUI1uyfoayHCkScbKAof(2esnNc3(GKCwVqD0qxaysKkTySIfzapCkCIfyscjvOK0zLBta62esnNc3(GKCwVqD0qxUCc7ucdx92esnNc3(GKCwVqD0qxFdBeuGZpNtXy6A4b462yl5ErU(WnSgsM(H9Epax3MNwtLsHCGudRHKP)n09TjKAofU9bj5SEH6OHUaWKivAXyflYa2z4h2iVyGpX4k0bUOsVnHuZPWTpijN1luhn0LNwt9gUYy6AW43GXD0ri1CQMNwt9gU2KbwnyAJ6HhaUa7mGE8))(2esnNc3(GKCwVqD0qxyNHFyt8gUYy6AWug)gmUJocPMt180AQ3W1MmWQbtBuhDGhaUa7mGE8pB)2W8m)HcPMtHBFqsoRxOoAOR9aMXJtmwXIm4MqSkuZWOuHMlIX5ZaMug3doazGDtFByEM)qHuZPWTpijN1luhn01EaZ4XjgRyrgYsmFurqgNpdyszCp4aKb2VnHuZPWTpijN1luhn01EaZ4XjgRyrgaWK4nCvO5klwygNpdyszCp4aKbiqrUdKf1EbNWFPNGyXdawzXsihi1dcuK7azrnSZa6fJRiQkDM8qZPUn3MBdZFiMngijGs(dr7e08H0CrhsDshkK6apuIpuShjpECQDBcPMtHnG)ioxWhjt3MqQ5uyhn0Lm4CHlXDcukbVnHuZPWoAORGbsOdgFBcPMtHD0qxEAFaGIvWkL3MqQ5uyd7bmJhNySIfzOiguHAggLkKEgNpdyszCp4aKb5mC)Ww1WaR1ucpTMkLc1mmkTbPvKfwqm8rsL8mMUgmfEa4VS8n3K4EX4kE8bJNfUJoKZW9dBvddSwtj80AQukuZWO0gKwrwybXWhjvY)JCgUFyRA4bGlGJ2G0kYclig(iPs(Bti1CkSJg6ApGz84eJvSidfXGkuZWOuH0Z48zatkJ7bhGmiNH7h2QgEa4c4OniTISWcIHpsQKNX01aEa4VS8n3K4EX4kE8bJNfUNCgUFyRAyG1AkHNwtLsHAggL2G0kYclig(iPs()LZW9dBvdpaCbC0gKwrwybXWhjvYFByEM)qHuZPWoAOR9aMXJtmwXImKLy(OIGmoFgWKY4EWbidMMX01WhPnpTMkLc1mmkTfsn3PBti1CkSJg6ApGz84eJvSidpaxxb2CjfspJZNbmPmUhCaYWEaZ4XPwrmOc1mmkvi9mMUgm1EaZ4XPgaMeVHRcnxzXc3ZuzjMpQi4TjKAof2rdDThWmECIXkwKHhGRRaBUKcPNX5ZaMug3doazG9UzmDnyQ9aMXJtnamjEdxfAUYIfUxwI5Jkc2ZuFK28qk8yn4mrWwi1CNUnHuZPWoAOR9aMXJtmwXIm8aCDfyZLui9moFgWKY4EWbidMMX01GP2dygpo1aWK4nCvO5klw4EzjMpQiyVpsBEifESgCMiylKAUt9EaUUn2sUxKRpCdRHKPFmDptPbNkTTNCYnPY3OkECYFBcPMtHD0qx7bmJhNySIfz4b46kWMlPq6zC(mGjLX9GdqgmnJPRbtThWmECQbGjXB4QqZvwSW9YsmFurWEFK28qk8yn4mrWwi1CN69bPDblPVXEZzuEX4kybW9r1tdovABp5KBsLVrv84K)2esnNc7OHU2dygpoXyflYWdW1vGnxsH0Z48zatkJ7bhGmiNH7h2QMNK5k0SyjEdxBqAfzHfedFKujpJPRH9aMXJtnamjEdxfAUYIf(2esnNc7OHUKbNlcPMtj4jwzSIfzqHzXeP4Bti1CkSJg6sgCUiKAoLGNyLXkwKHHL0Zy6AWytThWmECQbGjXB4QqZvwSW9(iT5P1uPuOMHrPTqQ5ozuhDy8EaZ4XPgaMeVHRcnxzXc37b462WodOxmUIOQ0zYdnNQb81ZytPbNkT9nSrqbo)CovJQ4XjFhD8aCDBFdBeuGZpNt1a(mYOBti1CkSJg6kxF8bNtXy6A4nyCp3KLtvaPvKf()U3wws)TjKAof2rdDjdoxesnNsWtSYyflYW8rfbzeRWuQgyNX01GoSyXPMCgUFyRW90Cr)7MqSkuZWOuHMl62esnNc7OHU8ZSymDnajxiHDgpoDBcPMtHD0qxYGZfHuZPe8eRmwXImiNDQIsfXl5PAMrSctPAGDgtxd4bG)YY3ybNDsK1EYAGHMt1rh4bG)YY3CtI7fJR4XhmEw4o6apa8xw(MCwVqflYNAO5uD0HC2PkkTvKeo8b6VnHuZPWoAORVHnckW5NZPymDnShWmECQbGjXB4QqZvwSW9EaUUnSZa6fJRiQkDM8qZPAaF3MqQ5uyhn013O5umMUgm2u7bmJhNAays8gUk0CLflCV9aMXJtTIyqfQzyuQq6)NL03wbd90Cr)4MqSkuZWOuHMlQJoWda)LLVbj3SiV4l4Hs92dygpo1kIbvOMHrPcP))T)3g1rhgVhWmECQbGjXB4QqZvwSW9EaUUnSZa6fJRiQkDM8qZPAaFgDBcPMtHD0qxYGZfHuZPe8eRmwXImOMHrPcmPaF3MqQ5uyhn0LNwtLsbwHuXsDYy6AWytbbkYDGSOgBj3fsESaNSsUyCfyGpcMduGbwRPYIvV9aMXJtTIyqfQzyuQq6)PFAuhDy8hPnpTMkLc1mmkTfsn3PEFK280AQukuZWO0gKwrw4)73TLL03wbdgDBcPMtHD0qxYGZfEifESgCMiiMX01WEaZ4XPgaMeVHRcnxzXc3tod3pSvnmWAnLWtRPsPqndJsBqAfzHfedFKuj)pD39TjKAof2rdDjdox4Hu4XAWzIGygtxdMApGz84udatI3WvHMRSyH7z8EaZ4XPwrmOc1mmkvi9)0TP)v)3wtbbkYDGSOgBj3fsESaNSsUyCfyGpcMduGbwRPYILr3MqQ5uyhn013Wgbf48Z5umMUgm1EaZ4XPgaMeVHRcnxzXc37b462yl5ErU(WnSgsM(H9Epax3MNwtLsHCGudRHKP)3(TjKAof2rdD9soHLdaKfjEZ6rqmJPRHhGRBtndJsB(HTQ3EaZ4XPwrmOc1mmkvi9)0)Bti1CkSJg6kxF8bNtXy6AiKAUtcQOvs4Fy3rJzFB1GtL2WHeMUPK8c8aWXnQIhN8g17b462yl5ErU(WnSgsM(Xq)27b462uZWO0MFyR6ThWmECQvedQqndJsfs)p9)2esnNc7OHUY1hFW5umMUgcPM7KGkALe(NU79aCDBSLCVixF4gwdjt)yOF79aCDBQzyuAZpSv92dygpo1kIbvOMHrPcP)N(3ZuqGIChilQLRp(GZDs8nkvAg8EgBkn4uPnx4SeQtsGDg(HnCJQ4XjFhD4PhGRBZfolH6KeyNHFyd3a(m62esnNc7OHUY1hFW5umMUgcPM7KGkALe(NU79aCDBSLCVixF4gwdjt)yOF79aCDB56Jp4CNeFJsLMbVbPvKf()U7bbkYDGSOwU(4do3jX3OuPzWVnHuZPWoAORC9XhCofJPRHhGRBJTK7f56d3WAiz6hdS3Dpn4uPn8aWfYP8aP2OkECY3tdovAZfolH6KeyNHFyd3OkECY3dcuK7azrTC9XhCUtIVrPsZG37b462uZWO0MFyR6ThWmECQvedQqndJsfs)p9)2esnNc7OHUybZ1Kqs4sCwab0Zy6A4nyCpnxKqhHpP)3UPVnHuZPWoAOlmWAnLyp5KBsLNX01WBW4EAUiHocFs)39FFBcPMtHD0qxyG1AkHNwtLsHAggLYy6A4nyCpnxKqhHpP)zV)3MqQ5uyhn0LZO8IXvWcG7JIX01aEa4cSZa6n0)Bti1CkSJg6c7m8dBI3Wvgtxd4bGlWodO))(3dcuK7azrTxWj8x6jiw8aGvwSeYbs9EaUUTxWj8x6jiw8aGvwSeYbsniTISW)3)BdZFOTI7H2AifESgCMii(qbKouWHu4nFOqQ5oX4HQ5qfr(dPZHWXoDiSZa6X3MqQ5uyhn0LZO8IXvWcG7JIX01aEa4cSZa6)XW27z8hPnpKcpwdoteSfsn3Po64J0MNwtLsHAggL2cPM7Kr3MqQ5uyhn0LZO8IXvWcG7JIX01aEa4cSZa6)Xa79EaUUTIuNeu8nqn4nGVEYz4(HTQjdox4Hu4XAWzIG4gKwrw4F6EBzj9TvWWTjKAof2rdD5mkVyCfSa4(OymDnGhaUa7mG(FmWEVhGRBJTK7f56d3WAiz6NU7ThWmECQvedQqndJsfs))SK(2kyONMl6h3eIvHAggLk0Cr)IL03wbd3MqQ5uyhn0Lm4Cri1CkbpXkJvSidYzNQOur8sEQMzeRWuQgyNX01GPKZovrPTDQuNMH3gM)q)1uDoa6HadjmDtj5pe4aWXmEiWbGFiqfMmrhkXhcRWPyrWdPoJ6qBnTM6nCLXdHNdL6HCg4dfhYzYYjbp0hmhyQMVnHuZPWoAOl8aWfyfMmrmMUgmLgCQ0goKW0nLKxGhaoUrv84K)2W8hc8Jk)H2AAnvkpeZmqcFi3bEiWbGFiqNb0JpeqPj)qMyggLEi5mC)WwDOeFijFW0H05qqk8MVnHuZPWoAOlpTM6nCLX01WdW1T5P1uPuihi1Gui1E4bGlWodO))F3BpGz84uRiguHAggLkK(F6203gM)qBnamlwhYeZWO0dHjf4JXdH)OYFOTMwtLYdXmdKWhYDGhcCa4hc0za94Bti1CkSJg6YtRPEdxzmDn8aCDBEAnvkfYbsnifsThEa4cSZa6))392dygpo1kIbvOMHrPcP)F27(2esnNc7OHU80AQ3Wvgtxdpax3MNwtLsHCGudsHu7HhaUa7mG())DpJFaUUnpTMkLc5aPgwdjt)0DhDObNkTHdjmDtj5f4bGJBufpo5n62esnNc7OHU80AQ3WvgtxdysfVPaWnnjy3)TO7pzp8aWfyNb0))V7zSX97VWdaxGDgqVrBBi1CQg2z4h2eVHRnIbscOKqZf9ZhPnpKcpwdoteSbPvKf(xHuZPAoJYlgxblaUpQgXajbusO5I(vi1CQMNwt9gU2igijGscnxKr9EaUUnpTMkLc5aPgwdjt)yG9Bti1CkSJg6YtRPEdxzmDn8aCDBEAnvkfYbsnifsThEa4cSZa6))39cPM7KGkALe(h2VnHuZPWoAOl8aWfyfMmr3MqQ5uyhn0Lm4Cri1CkbpXkJvSidYzNQOur8sEQMVnm)H2kUhY8aCizuhIfPh6fsMoKohQ)hcCa4hc0za94d9i3bshARHu4XAWzIG4djNH7h2QdL4dbPWBMXdLAN4dnmfMpKohc)rL)qQtADOAy72esnNc7OHUCgLxmUcwaCFumMUgWdaxGDgq)pg2EV9aMXJtTIyqfQzyuQq6)P7(3Zyn4uPnpTMkLczW5zXQrv84KVJoKZW9dBvtgCUWdPWJ1GZebXniTISW)ySX9)x4bGlWodO3OTnKAovd7m8dBI3W1gXajbusO5ImYXqQ5unNr5fJRGfa3hvJyGKakj0CrgDBcPMtHD0qx(zwmknl5KqdilsXgyNX01aKCHe2z84upnx0pUjeRc1mmkvO5IUnm)H6hbthARP1uVHRhkDpK5bOtiDiwtwSoKohIpy6qBnTMkLhIzgiDiSgsMWmEiANQdLUhk1o9hITaR0HIdHha(HWodOVDBcPMtHD0qxEAn1B4kJPRHhGRBZtRPsPqoqQbPqQ9EaUUnpTMkLc5aPgKwrw4)z3rwsFBfmSTpax3MNwtLsHCGudRHKPBti1CkSJg6c7m8dBI3W1BZTjKAofUH5dBcfMftKInaGjrQ0IXkwKb8aW5KQzXsabEMzuAwYjHgqwKInWoJPRH9aMXJtThGRRaBUKcP)FnGSiT5tSgLK2g6)VmU7TLL03wbdB7EaZ4XPgaMeVHRcnxzXcB0TjKAofUH5dBcfMftKID0qxaysKkTySIfzadup(mErSi1PzSYy6AypGz84u7b46kWMlPq6)xdilsB(eRrjPTH(7OXDVT7bmJhNAays8gUk0CLflSr3MqQ5u4gMpSjuywmrk2rdDbGjrQ0IXkwKbA9zgsbxmqFfLKymDnShWmECQ9aCDfyZLui9)BSgqwK28jwJssBd93ihzVBhnU7TDpGz84udatI3WvHMRSyHn62CBcPMtHBYzNQOur8sEQMnGhaUaokJPRb8aWFz5BSGZojYApznWqZP6z8EaZ4XPwrmOc1mmkvi9)3TP7OJ9aMXJtTIyqfQzyuQq6)z7M2OBti1CkCto7ufLkIxYt1SJg6cpaCbCugtxd4bG)YY3CtI7fJR4XhmEw4EFK280AQukuZWO0wi1CNUnHuZPWn5StvuQiEjpvZoAOl8aWfWrzmDnGha(llFJTK7fobkvOHutjUNP(iT5P1uPuOMHrPTqQ5o1BpGz84uRiguHAggLkK(Fy)VVnHuZPWn5StvuQiEjpvZoAOlpjZvOzXs8gUYO0SKtcnGSifBGDgtxdRS(JgqwK2CsbxD2(KkJPRbtThWmECQbGjXB4QqZvwSW9Wda)LLVXPWlEMfedX6Jt9m(J0MNwtLsHAggL2cPM7up8aWfyNb0)F3D0HP(iT5P1uPuOMHrPTqQ5o1BpGz84uRiguHAggLkK(F(TPn62esnNc3KZovrPI4L8un7OHU8KmxHMflXB4kJsZsoj0aYIuSb2zmDnSY6pAazrAZjfC1z7tQmMUgm1EaZ4XPgaMeVHRcnxzXc3dpa8xw(gt0EwyXmBviEwS6z8hPnpTMkLc1mmkTfsn3Po6WuFK280AQukuZWO0wi1CN6ThWmECQvedQqndJsfs)p)20gDBcPMtHBYzNQOur8sEQMD0qxEsMRqZIL4nCLrPzjNeAazrk2a7mMUgm1EaZ4XPgaMeVHRcnxzXc3Zy8aWFz5BUdKf9gyrciTtWKWD0HX4bG)YY32hEOjNe4HVtL2Zu4bG)YY3yI2ZclMzRcXZILrg1ZuFK280AQukuZWO0wi1CNUnHuZPWn5StvuQiEjpvZoAOlpjZvOzXs8gUYO0SKtcnGSifBGDgtxd7bmJhNAays8gUk0CLflCpJnLgCQ023Wgbf48Z5uD0HCgUFyRAFdBeuGZpNt1G0kYc)Fi1CQMNK5k0SyjEdxBedKeqjHMlYOEMsod3pSvnmWAnLWtRPsPqndJsBaF9m(J0MNwtLsHAggL2G0kYc))F3rhYz4(HTQHbwRPeEAnvkfQzyuAdsRilSGy4JKk5)F7M2OBti1CkCto7ufLkIxYt1SJg6YLtyNsy4QmMUgWda)LLVTp8qtojWdFNkT3dW1TTp8qtojWdFNkT5h2kgZsjie4tfPRHhGRBBF4HMCsGh(ovAd472esnNc3KZovrPI4L8un7OHUWYbaMflHMQtIX01aEa4VS8n5SEHkwKp1qZP69rAZtRPsPqndJsBHuZD62esnNc3KZovrPI4L8un7OHUWYbaMflHMQtIX01GPWda)LLVjN1luXI8PgAo1TjKAofUjNDQIsfXl5PA2rdDLRpQ8zXsidnWkC(CsmMUg(iT5P1uPuOMHrPTqQ5o1dpaCb2za9gm9T52esnNc3C(juywmHnaGjrQ0IXkwKbCwUaCblE4ZqhiwqRhNw3MqQ5u4MZpHcZIjSJg6catIuPfJvSid4SCb4Ia)LWOuSGwpoTUn3MqQ5u42Ws6n8iiMGmLfRBti1CkCByj9oAORhFgVWfaA(2esnNc3gwsVJg6YnH0JpJ)2esnNc3gwsVJg6catIuPf(2CBcPMtHBZhve0aEa4c4OmMUgWda)LLVXco7KiR9K1adnN62esnNc3MpQiOJg6Qi1jbfFdud(TjKAofUnFurqhn0flyUMescxIZciG(Bti1CkCB(OIGoAOlmWAnLyp5KBsL)2esnNc3MpQiOJg6c7m8dBI3Wvgtxd4bGlWodO))(3tod3pSvnzW5cpKcpwdotee3a(UnHuZPWT5Jkc6OHUWod)WM4nCLX01WEaZ4XPgaMeVHRcnxzXc3dpaCb2za9)3)Epax32l4e(l9eelEaWklwc5aPgwdjt))7Bti1CkCB(OIGoAOlzW5cpKcpwdoteeFBUnHuZPWTpaij8XkyrcfMftydaysKkTySIfzWdPW7MqsStymXVnHuZPWTpaij8XkyrcfMftyhn0faMePslgRyrgybZLGK88dt3MqQ5u42haKe(yfSiHcZIjSJg6catIuPfJvSidqcpvuQasycUpj82esnNc3(aGKWhRGfjuywmHD0qxaysKkTySIfziGsNPssflYIfvaPAwihiDBcPMtHBFaqs4JvWIekmlMWoAOlamjsLwmwXImih8kLcw8WNHoqSas4PcDG3MqQ5u42haKe(yfSiHcZIjSJg6catIuPfJvSidEifE3esIDcJj(TjKAofU9bajHpwblsOWSyc7OHUaWKivAXyflYaEa4IKvLkbVnHuZPWTpaij8XkyrcfMftyhn0faMePslgRyrgyXn)5umUIaJZvYdnNIX01qi1CNeurRKWgy)2esnNc3(aGKWhRGfjuywmHD0qxaysKkTySIfzWhqMwZucpjzs8bOqclPss3MqQ5u42haKe(yfSiHcZIjSJg6catIuPfJvSid0Bk8aWf7jMUnHuZPWTpaij8XkyrcfMftyhn0faMePslgRyrgakPZilYlyXdFg6aXcSZqYeNW3MBti1CkCtHzXePydaysKkTySIfza7m8dBKxmWNyCf6axuPmMUg2dygpo1EaUUcS5skK()7U7Bti1CkCtHzXePyhn0faMePslgRyrgWYaIfJRWfgkbRGlWkmDPBti1CkCtHzXePyhn0Lm4Cri1CkbpXkJvSido)ekmlMWmMUg0GtL280AQukKtHbwFAovJQ4XjFV9aMXJtTIyqfQzyuQq6)VBtFBy(dXS56ssfFi1zOhsHXoXpeMpSXnFiDoKgqwKEiiTnbsiDOW7tnNk4mEim9fWqPd5mkpplw3MqQ5u4McZIjsXoAOlzW5IqQ5ucEIvgRyrgW8HnHcZIjsX3MqQ5u4McZIjsXoAOlamjsLwmwXImm7e0LpSLflru5keYGfXy6AWytThWmECQbGjXB4QqZvwSW9(iT5P1uPuOMHrPTqQ5ozuhDy8EaZ4XPgaMeVHRcnxzXc37b462WodOxmUIOQ0zYdnNQb8z0TjKAofUPWSyIuSJg6catIuPfJy(Oguywmrk7mMUguywmrAJ9MZalaWK4b462ZyJn1EaZ4XPgaMeVHRcnxzXc37J0MNwtLsHAggL2cPM7KrD0HX7bmJhNAays8gUk0CLflCVhGRBd7mGEX4kIQsNjp0CQgWNrgDBcPMtHBkmlMif7OHUaWKivAXiMpQbfMftK2nJPRbfMftK26U5mWcamjEaUU9m2ytThWmECQbGjXB4QqZvwSW9(iT5P1uPuOMHrPTqQ5ozuhDy8EaZ4XPgaMeVHRcnxzXc37b462WodOxmUIOQ0zYdnNQb8zKr3MqQ5u4McZIjsXoAOlzW5IqQ5ucEIvgRyrg(aGKWhRGfjuywmHzmDnO5I(XnHyvOMHrPcnxuV9aMXJtThGRRaBUKcP)NUn9T52esnNc3uZWOubMuGpdfPojO4BGAWzmDnShWmECQvedQqndJsfs))S3)Bti1CkCtndJsfysb(C0qxSG5AsijCjolGa6zmDnShWmECQvedQqndJsfs))SZS(LXHuZPAyG1AkHNwtLsHAggL2igijGscnxKJHuZPAyNHFyt8gU2igijGscnxKr9mwod3pSvnzW5cpKcpwdotee3G0kYc)p7mRFzCi1CQggyTMs4P1uPuOMHrPnIbscOKqZf5yi1CQggyTMsSNCYnPY3igijGscnxKJHuZPAyNHFyt8gU2igijGscnxKrD0XhPnpKcpwdoteSbPvKf(N9aMXJtTIyqfQzyuQq6DmKAovddSwtj80AQukuZWO0gXajbusO5Im62esnNc3uZWOubMuGphn0fgyTMsSNCYnPYZy6AW49aMXJtTIyqfQzyuQq6)N9()lJdPMt1WaR1ucpTMkLc1mmkTrmqsaLeAUiJ6zSCgUFyRAYGZfEifESgCMiiUbPvKf(F27)VmoKAovddSwtj80AQukuZWO0gXajbusO5ICmKAovddSwtj2to5Mu5BedKeqjHMlYOo64J0MhsHhRbNjc2G0kYc)ZEaZ4XPwrmOc1mmkvi9ogsnNQHbwRPeEAnvkfQzyuAJyGKakj0CrgzuhDySPGaf5oqwuJTK7cjpwGtwjxmUcmWhbZbkWaR1uzXQ3EaZ4XPwrmOc1mmkvi9)8BtB0TjKAofUPMHrPcmPaFoAOlzW5cpKcpwdoteeZy6AypGz84uRiguHAggLkK()zV7FzCi1CQggyTMs4P1uPuOMHrPnIbscOKqZf5yi1CQg2z4h2eVHRnIbscOKqZfz0TjKAofUPMHrPcmPaFoAOlmWAnLWtRPsPqndJszmDnO5I(XnHyvOMHrPcnxupJ)iT5Hu4XAWzIGTqQ5o17J0MhsHhRbNjc2G0kYc)ti1CQggyTMs4P1uPuOMHrPnIbscOKqZfzupJnLgCQ0ggyTMsSNCYnPY3OkECY3rhFK22to5Mu5BHuZDYOEgJhaUa7mGEdMUJom(J0MhsHhRbNjc2cPM7uVpsBEifESgCMiydsRil8)HuZPAyG1AkHNwtLsHAggL2igijGscnxKJHuZPAyNHFyt8gU2igijGscnxKrD0HXFK22to5Mu5BHuZDQ3hPT9KtUjv(gKwrw4)dPMt1WaR1ucpTMkLc1mmkTrmqsaLeAUihdPMt1Wod)WM4nCTrmqsaLeAUiJ6OdJFaUUnwWCnjKeUeNfqa9nGVEpax3glyUMescxIZciG(gKwrw4)dPMt1WaR1ucpTMkLc1mmkTrmqsaLeAUihdPMt1Wod)WM4nCTrmqsaLeAUiJmYQw1Ab]] )


end
