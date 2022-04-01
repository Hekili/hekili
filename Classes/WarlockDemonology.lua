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

    -- March 27 APL Update
    -- actions.precombat+=/variable,name=first_tyrant_time,op=set,value=12
    -- actions.precombat+=/variable,name=first_tyrant_time,op=add,value=action.grimoire_felguard.execute_time,if=talent.grimoire_felguard.enabled
    -- actions.precombat+=/variable,name=first_tyrant_time,op=add,value=action.summon_vilefiend.execute_time,if=talent.summon_vilefiend.enabled
    -- actions.precombat+=/variable,name=first_tyrant_time,op=add,value=gcd.max,if=talent.grimoire_felguard.enabled|talent.summon_vilefiend.enabled
    -- actions.precombat+=/variable,name=first_tyrant_time,op=sub,value=action.summon_demonic_tyrant.execute_time+action.shadow_bolt.execute_time
    -- actions.precombat+=/variable,name=first_tyrant_time,op=min,value=10
    spec:RegisterStateExpr( "first_tyrant_time", function()
        if first_combat_tyrant and combat > 0 then
            return first_combat_tyrant - combat
        end

        -- Tyrant is on CD, we're not starting fresh, skip opener.
        if cooldown.summon_demonic_tyrant.true_remains > gcd.max then
            return 0
        end

        local ftt = 12
        local bonus_demon = false

        if talent.grimoire_felguard.enabled then
            ftt = ftt + action.grimoire_felguard.execute_time
            bonus_demon = true
        end

        if talent.summon_vilefiend.enabled then
            ftt = ftt + action.summon_vilefiend.execute_time
            bonus_demon = true
        end

        if bonus_demon then
            ftt = ftt + gcd.max
        end

        return min( 10, ftt - ( action.summon_demonic_tyrant.execute_time - action.shadow_bolt.execute_time ) )
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

            startsCombat = false,

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


    spec:RegisterPack( "Demonology", 20220327, [[dafQlcqiQiEekQ6sQsi2KuLprf1OOs1PKkSkLc1RirMfkYTukQDjLFjvYWOI0XqPAzsL6zkfzAQsLRjvKTPkv5BkfY4uLQ6CsfvTovj6DOOsY8uL09iH9PkL)jvuIoikQOfkvvpefftuvcUikQuBefvs9rPIcJuQOK6KsfvwPsPzIIs3uQOuTtQu(PQesdffvILkvu0tb1ujrDvPIsyRsfLKVIIkmwLc2lP(lQgmKdlSyv1JjAYu1Lr2mj9zuYOPsoTOxJcnBc3wj7wYVvmCvXXvLqTCGNd10PCDq2Us13rPmEuW5PcRxQOuMVuv2VkRzxRSg2hgPDRBN2D3oDtDVrn23i2F)nTjnS54H0WpHKXGfPHRyrA4xGwtnIHLdn8t4qmHxRSggpqajPHHZfZOH)qPW6CL(RH9HrA362PD3Tt3u3BuJ9nI93N93PHXpKu7w3V37PHDLEpv6Vg2tyPg(fO1uJyy54qmhbqmsgVTUm7b)YU6IvAUG(n5S6cNliry5usqOADHZLSRBBN9aiDDOU3iMou3oT7UVT3wMXvuSi8lVTB(qWpKqCiMDKm2UTB(qVOLWXHaKCwlQ8h6fO1u)ryh6bqBwoRFyhkvpuAhkXhklSfLDi3hWHCfaVmW2HuhWH(dgt4oyU6q(PC2o0Staz8CiSRa4XhkvpKJbYzaDOWouNouwhYCrhAEOIaTB7MpeZLHncCi48X1uhkeIHnYFOhaTz5S(HDiBo0dyKhklSfLDOxGwt9hH1UTB(qmx2zUCileuzhklJaaOhRDB38Hyo3N0Fi4(38BDwpDghc)eRdXMlQoKJbYzaDOASdf)bYoKnhcdTwtDO4qk7aeL1UTB(qmxliSljiuTU6SAeHLc6qWJyNk7qYOKKGNQhs6kkwK)q2COSmcaGEmEQ2UTB(qkdCCiBouSpP)qSfyllwh6fO1uP8qmZaOdHTqYiUDB38Hug44q2COvWiDO5HkcCOhqoG0CCOPeooeBdGXdLQhIn6qYOouinOqiCCO5HQdXwAUouCiLDaIYA32nFOo36bm70HKZ6jS8NI0CCi2sZ1H6SR0H(qPWJBAyrInSwznmwmSXnqwmsgwRS2n21kRHPk(cYR7xdxXI0W4bsiiZYIfha9DOHLoKcIBbGfzyTBSRHdPLtPHXdKqqMLfloa67qdlbPrGm0W7biJVGAFivvo2rj5s)HE9qwayrwZNylkjDOUouNo0MpK7hQ7dTXhIL03wbdhAJp0EaY4lOgeM4)ryClxzXcFOo0M2TU1kRHPk(cYR7xdhslNsdJHQVygppwK5Yb20WsqAeidn8EaY4lO2hsvLJDusU0FOxpKfawK18j2IsshQRd1PdP0HC)qDFOn(q7biJVGAqyI)hHXTCLfl8H6qdxXI0WyO6lMXZJfzUCGnTPDBtAL1WufFb519RHdPLtPHP1Jdafc(a8vussdlbPrGm0W7biJVGAFivvo2rj5s)HE9qUFilaSiR5tSfLKouxhQthQJdP0HyV7dP0HC)qDFOn(q7biJVGAqyI)hHXTCLfl8H6qdxXI0W06XbGcbFa(kkjPnTPHD9WnqwmI1kRDJDTYAyQIVG86(1WvSinmolvibNLi8zydaZP1xqlnCiTCknmolvibNLi8zydaZP1xqlTPDRBTYAyQIVG86(1WvSinmolvibpWpjikdZP1xqlnCiTCknmolvibpWpjikdZP1xqlTPnnSC2PkkJh)uKMdTYA3yxRSgMQ4liVUFnSeKgbYqd7(HWdK4NLVPMKWZhv(xmy8SWnQIVG8hQV(oeaQi1bWIAEsgoYIfhpqcoomPls0Ok(cYFOoouVd9qwZtRPsj3CaIYAH0YDsdhslNsdJhibhmM20U1TwznmvXxqED)AyjincKHggpqIFw(glWSt8S2twdiSCQgvXxq(d17qo5qaOIuhalQ5jz4ilwC8aj44WKUirJQ4li)H6Di3p0EaY4lOwrmyCZbikJl9h61d1TtpuF9DO9aKXxqTIyW4Mdqugx6p0BhAto9qDOHdPLtPHXdKGdgtBA32KwznmvXxqED)AyjincKHggpqIFw(gBPWZDbvg3cPLsCJQ4li)H6DiNCiaurQdGf18KmCKfloEGeCCysxKOrv8fK)q9oKto0dznpTMkLCZbikRfsl3Pd17q7biJVGAfXGXnhGOmU0FO3oe7VVgoKwoLggpqcoymTPD7DAL1WufFb519RHdPLtPH9KmxHLfl(FeMgwcsJazOHDYH2dqgFb1GWe)pcJB5klw4d17q4bs8ZY3eu45FhCIHy9iOgvXxq(d17qUFOhYAEAnvk5MdquwlKwUthQ3HWdKGJDfa)HE9qDFO(67qo5qpK180AQuYnhGOSwiTCNouVdThGm(cQvedg3CaIY4s)HE7qVZPhQdnS0HuqClaSidRDJDTPDRtAL1WufFb519RHdPLtPH9KmxHLfl(FeMgwcsJazOHDYH2dqgFb1GWe)pcJB5klw4d17q4bs8ZY3yK2ZcZNPZgjYIvJQ4li)H6Di3p0dznpTMkLCZbikRfsl3Pd1xFhYjh6HSMNwtLsU5aeL1cPL70H6DO9aKXxqTIyW4Mdqugx6p0Bh6Do9qDOHLoKcIBbGfzyTBSRnTBVNwznmvXxqED)A4qA5uAypjZvyzXI)hHPHLG0iqgAyNCO9aKXxqnimX)JW4wUYIf(q9oK7hcpqIFw(M6ayr)buehq7eijCJQ4li)H6RVd5(HWdK4NLVTpIWsbXXJyNkRrv8fK)q9oKtoeEGe)S8ngP9SW8z6SrISy1Ok(cYFOoouhhQ3HCYHEiR5P1uPKBoarzTqA5oPHLoKcIBbGfzyTBSRnTBBKwznmvXxqED)A4qA5uAypjZvyzXI)hHPHLG0iqgA49aKXxqnimX)JW4wUYIf(q9oK7hYjhYcbvw7zyJaCC(4AQgvXxq(d1xFhsoJWpSvTNHncWX5JRPAaAfzHp0RhkKwovZtYCfwwS4)rynIbscze3YfDOoouVd5KdjNr4h2QggATMI7P1uPKBoarznONd17qUFOhYAEAnvk5MdquwdqRil8HE9qV)H6RVdjNr4h2QggATMI7P1uPKBoarznaTISWCIHhsAK)qVEOn50d1Hgw6qkiUfawKH1UXU20U9(AL1WufFb519RHdPLtPHvfe2LeeQMgwcsJazOHXdK4NLVTpIWsbXXJyNkRrv8fK)q9o0hsvTTpIWsbXXJyNkR5h2knCwgbaqpgpv1WFiv12(iclfehpIDQSg0J20U151kRHPk(cYR7xdlbPrGm0W4bs8ZY3KZ6hgFr(0clNQrv8fK)q9o0dznpTMkLCZbikRfsl3jnCiTCknmwoqGSyXT0CrAt7g7ovRSgMQ4liVUFnSeKgbYqd7KdHhiXplFtoRFy8f5tlSCQgvXxqEnCiTCknmwoqGSyXT0CrAt7g7SRvwdtv8fKx3VgwcsJazOHFiR5P1uPKBoarzTqA5oDOEhcpqco2va8hsXHCQgoKwoLgoxpu5ZIfxgwGnW84I0M20WMdqughtg0JwzTBSRvwdtv8fKx3VgwcsJazOH3dqgFb1kIbJBoarzCP)qVEi27KgoKwoLgUiZfb4pdWcH20U1TwznmvXxqED)AyjincKHgEpaz8fuRigmU5aeLXL(d96HyFJo0MpK7hkKwovddTwtX90AQuYnhGOSgXajHmIB5IoKshkKwovd7k8dB8)iSgXajHmIB5IouhhQ3HC)qYze(HTQjdHG7bu4XwiyKa4gGwrw4d96HyFJo0MpK7hkKwovddTwtX90AQuYnhGOSgXajHmIB5IoKshkKwovddTwtX3tbPMu5BedKeYiULl6qkDOqA5unSRWpSX)JWAedKeYiULl6qDCO(67qpK18ak8ylemsGgGwrw4d92H2dqgFb1kIbJBoarzCP)qkDOqA5unm0Anf3tRPsj3CaIYAedKeYiULl6qDOHdPLtPHzbY1KaIRscwqbWRnTBBsRSgMQ4liVUFnSeKgbYqd7(H2dqgFb1kIbJBoarzCP)qVEi270H28HC)qH0YPAyO1AkUNwtLsU5aeL1igijKrClx0H64q9oK7hsoJWpSvnzieCpGcp2cbJea3a0kYcFOxpe7D6qB(qUFOqA5unm0Anf3tRPsj3CaIYAedKeYiULl6qkDOqA5unm0AnfFpfKAsLVrmqsiJ4wUOd1XH6RVd9qwZdOWJTqWibAaAfzHp0BhApaz8fuRigmU5aeLXL(dP0HcPLt1WqR1uCpTMkLCZbikRrmqsiJ4wUOd1XH64q913HC)qo5qaOIuhalQXwkubKhZXjRuWhvog6Ha5a4yO1AQSy1Ok(cYFOEhApaz8fuRigmU5aeLXL(d92HENtpuhA4qA5uAym0AnfFpfKAsLxBA3ENwznmvXxqED)AyjincKHgEpaz8fuRigmU5aeLXL(d96HyV7dT5d5(HcPLt1WqR1uCpTMkLCZbikRrmqsiJ4wUOdP0HcPLt1WUc)Wg)pcRrmqsiJ4wUOd1HgoKwoLgwgcb3dOWJTqWibWAt7wN0kRHPk(cYR7xdlbPrGm0WwUOd92Huta24Mdqug3YfDOEhY9d9qwZdOWJTqWibAH0YD6q9o0dznpGcp2cbJeObOvKf(qVDOqA5unm0Anf3tRPsj3CaIYAedKeYiULl6qDCOEhY9d5KdzHGkRHHwRP47PGutQ8nQIVG8hQV(o0dzT9uqQjv(wiTCNouhhQ3HC)q4bsWXUcG)qkoKtpuF9Di3p0dznpGcp2cbJeOfsl3Pd17qpK18ak8ylemsGgGwrw4d96HcPLt1WqR1uCpTMkLCZbikRrmqsiJ4wUOdP0HcPLt1WUc)Wg)pcRrmqsiJ4wUOd1XH6RVd5(HEiRTNcsnPY3cPL70H6DOhYA7PGutQ8naTISWh61dfslNQHHwRP4EAnvk5MdquwJyGKqgXTCrhsPdfslNQHDf(Hn(FewJyGKqgXTCrhQJd1xFhY9d9HuvBSa5AsaXvjblOa4BqphQ3H(qQQnwGCnjG4QKGfua8naTISWh61dfslNQHHwRP4EAnvk5MdquwJyGKqgXTCrhsPdfslNQHDf(Hn(FewJyGKqgXTCrhQJd1HgoKwoLggdTwtX90AQuYnhGOmTPnnSNudiHPvw7g7AL1WufFb519RH9ewcYhlNsdZCZajHmYFiANaooKLl6qMl6qH0gWHs8HI9ifXxqnnCiTCknm(HecUyKmQnTBDRvwdhslNsdldHGRscxqLranmvXxqED)At72M0kRHdPLtPHdgiUnySgMQ4liVUFTPD7DAL1WH0YP0WEAFGa8vWkLAyQIVG86(1M2ToPvwdtv8fKx3VgEE0WyY0WH0YP0W7biJVG0W7HaI0WYze(HTQHHwRP4EAnvk5MdquwdqRilmNy4HKg51WsqAeidnStoeEGe)S8n1KeE(OY)IbJNfUrv8fK)q913HKZi8dBvddTwtX90AQuYnhGOSgGwrwyoXWdjnYFO3oKCgHFyRA4bsWbJ1a0kYcZjgEiPrEn8Ea4vSinCrmyCZbikJl9At727Pvwdtv8fKx3VgEE0WyY0WH0YP0W7biJVG0W7HaI0WYze(HTQHhibhmwdqRilmNy4HKg51WsqAeidnmEGe)S8n1KeE(OY)IbJNfUrv8fK)q9oKCgHFyRAyO1AkUNwtLsU5aeL1a0kYcZjgEiPr(d96HKZi8dBvdpqcoySgGwrwyoXWdjnYRH3daVIfPHlIbJBoarzCPxBA32iTYAyQIVG86(1WZJggtMgoKwoLgEpaz8fKgEpeqKgEpaz8fuRigmU5aeLXLEnSeKgbYqd7KdThGm(cQbHj(Feg3YvwSWhQ3HCYHYIppuran8Ea4vSin8hsvLJDusU0RnTBVVwznmvXxqED)A45rdJjtdhslNsdVhGm(csdVhcisdZE3AyjincKHg2jhApaz8fudct8)imULRSyHpuVdLfFEOIahQ3HCYHEiR5bu4XwiyKaTqA5oPH3daVIfPH)qQQCSJsYLETPDRZRvwdtv8fKx3VgEE0WyY0WH0YP0W7biJVG0W7HaI0WovdlbPrGm0Wo5q7biJVGAqyI)hHXTCLfl8H6DOS4Zdve4q9o0dznpGcp2cbJeOfsl3Pd17qFiv1gBPWZZ1dUHTqY4HE7qo9q9oKtoKfcQS2Eki1KkFJQ4liVgEpa8kwKg(dPQYXokjx61M2n2DQwznmvXxqED)A45rdJjtdhslNsdVhGm(csdVhcisd7unSeKgbYqd7KdThGm(cQbHj(Feg3YvwSWhQ3HYIppurGd17qpK18ak8ylemsGwiTCNouVd9aODolPVXEZvuE(OYzbj8rDOEhYcbvwBpfKAsLVrv8fKxdVhaEflsd)Huv5yhLKl9At7g7SRvwdtv8fKx3VgEE0WyY0WH0YP0W7biJVG0W7HaI0WYze(HTQ5jzUcllw8)iSgGwrwyoXWdjnYRHLG0iqgA49aKXxqnimX)JW4wUYIfwdVhaEflsd)Huv5yhLKl9At7g7DRvwdtv8fKx3VgoKwoLgwgcbpKwofxKytdlsSXRyrAydKfJKH1M2n23KwznmvXxqED)AyjincKHg29d5KdThGm(cQbHj(Feg3YvwSWhQ3HEiR5P1uPKBoarzTqA5oDOoouF9Di3p0EaY4lOgeM4)ryClxzXcFOEh6dPQ2WUcGNpQ8OQ0vkclNQb9COEhY9d5KdzHGkR9mSraooFCnvJQ4li)H6RVd9HuvBpdBeGJZhxt1GEouhhQdnCiTCknSmecEiTCkUiXMgwKyJxXI0WdlPxBA3y)DAL1WufFb519RHLG0iqgA4)GXhQ3HutwUmoGwrw4d96H6(qB8Hyj9A4qA5uA4C9igCoL20UXEN0kRHPk(cYR7xdlbPrGm0W2WILGAYze(HTcFOEhYYfDOxpKAcWg3CaIY4wUinm2aP00UXUgoKwoLgwgcbpKwofxKytdlsSXRyrA45HkcOnTBS)EAL1WufFb519RHLG0iqgAyaPciSR4linCiTCknSFML20UX(gPvwdtv8fKx3VgwcsJazOHXdK4NLVXcm7epR9K1aclNQrv8fK)q913HWdK4NLVPMKWZhv(xmy8SWnQIVG8hQV(oeEGe)S8n5S(HXxKpTWYPAufFb5puF9Di5StvuwRijyedWRHXgiLM2n21WH0YP0WYqi4H0YP4IeBAyrInEflsdlNDQIY4XpfP5qBA3y)91kRHPk(cYR7xdlbPrGm0W7biJVGAqyI)hHXTCLfl8H6DOpKQAd7kaE(OYJQsxPiSCQg0JgoKwoLg(zyJaCC(4AkTPDJ9oVwznmvXxqED)AyjincKHg29d5KdThGm(cQbHj(Feg3YvwSWhQ3H2dqgFb1kIbJBoarzCP)qVEiwsFBfmCOEhYYfDO3oKAcWg3CaIY4wUOd1xFhcpqIFw(gGuZI88Nqeg1Ok(cYFOEhApaz8fuRigmU5aeLXL(d96H207FOoouF9Di3p0EaY4lOgeM4)ryClxzXcFOEh6dPQ2WUcGNpQ8OQ0vkclNQb9COo0WH0YP0WpJLtPnTBD7uTYAyQIVG86(1WH0YP0WYqi4H0YP4IeBAyrInEflsdBoarzCmzqpAt7w3SRvwdtv8fKx3VgwcsJazOHD)qo5qaOIuhalQXwkubKhZXjRuWhvog6Ha5a4yO1AQSy1Ok(cYFOEhApaz8fuRigmU5aeLXL(d92H68hQJd1xFhY9d9qwZtRPsj3CaIYAH0YD6q9o0dznpTMkLCZbikRbOvKf(qVEO37qB8Hyj9TvWWH6qdhslNsd7P1uPKJnavSmxAt7w3DRvwdtv8fKx3VgwcsJazOH3dqgFb1GWe)pcJB5klw4d17qYze(HTQHHwRP4EAnvk5MdquwdqRilmNy4HKg5p0BhQ7U1WH0YP0WYqi4EafESfcgjawBA36EtAL1WufFb519RHLG0iqgAyNCO9aKXxqnimX)JW4wUYIf(q9oK7hApaz8fuRigmU5aeLXL(d92H62PhAZhQthAJpKtoeaQi1bWIASLcva5XCCYkf8rLJHEiqoaogATMklwnQIVG8hQdnCiTCknSmecUhqHhBHGrcG1M2TUFNwznmvXxqED)AyjincKHg2jhApaz8fudct8)imULRSyHpuVd9HuvBSLcppxp4g2cjJh6TdX(H6DOpKQAZtRPsjxoaQHTqY4HE9qBsdhslNsd)mSraooFCnL20U1DN0kRHPk(cYR7xdlbPrGm0WFiv1M5aeL18dB1H6DO9aKXxqTIyW4Mdqugx6p0BhQtA4qA5uA4FkiSCGaSi(FwFcG1M2TUFpTYAyQIVG86(1WsqAeidnCiTCN4urRKWh6TdX(Hu6qUFi2p0gFileuznCibPAkjphpqcCJQ4li)H64q9o0hsvTXwk88C9GBylKmEO3uCO37q9o0hsvTzoarzn)WwDOEhApaz8fuRigmU5aeLXL(d92H6KgoKwoLgoxpIbNtPnTBDVrAL1WufFb519RHLG0iqgA4qA5oXPIwjHp0BhQ7d17qFiv1gBPWZZ1dUHTqY4HEtXHEVd17qFiv1M5aeL18dB1H6DO9aKXxqTIyW4Mdqugx6p0BhQthQ3HCYHaqfPoawulxpIbN7e)zmQSmenQIVG8hQ3HC)qo5qwiOYAQGzXnxeh7k8dB4gvXxq(d1xFhYtFiv1MkywCZfXXUc)WgUb9COo0WH0YP0W56rm4CkTPDR73xRSgMQ4liVUFnSeKgbYqdhsl3jov0kj8HE7qDFOEh6dPQ2ylfEEUEWnSfsgp0Bko07DOEh6dPQ2Y1JyW5oXFgJkldrdqRil8HE9qDFOEhcavK6ayrTC9igCUt8NXOYYq0Ok(cYRHdPLtPHZ1JyW5uAt7w3DETYAyQIVG86(1WsqAeidn8hsvTXwk88C9GBylKmEO3uCi27(q9oKfcQSgEGeC5uEO0AufFb5puVdzHGkRPcMf3CrCSRWpSHBufFb5puVdbGksDaSOwUEedo3j(ZyuzziAufFb5puVd9HuvBMdquwZpSvhQ3H2dqgFb1kIbJBoarzCP)qVDOoPHdPLtPHZ1JyW5uAt72MCQwznmvXxqED)AyjincKHg(py8H6Dilxe3gUpPd96H2Kt1WH0YP0WSa5AsaXvjblOa41M2TnXUwznmvXxqED)AyjincKHg(py8H6Dilxe3gUpPd96H6(91WH0YP0WyO1Ak(Eki1KkV20UTPU1kRHPk(cYR7xdlbPrGm0W)bJpuVdz5I42W9jDOxpe7DsdhslNsdJHwRP4EAnvk5MdquM20UTPnPvwdtv8fKx3VgwcsJazOHXdKGJDfa)HuCOoPHdPLtPHDfLNpQCwqcFuAt72MENwznmvXxqED)AyjincKHggpqco2va8h61d1Pd17qaOIuhalQ9dbHFspbW8peOYIfxoaQrv8fK)q9o0hsvT9dbHFspbW8peOYIfxoaQbOvKf(qVEOoPHdPLtPHXUc)Wg)pctBA32uN0kRHPk(cYR7xdhslNsd7kkpFu5SGe(O0WEclb5JLtPH7CQh6fau4XwiyKa4dfa6qHaqH3XHcPL7ethQMdve5pKnhch70HWUcGhRHLG0iqgAy8aj4yxbWFO3uCOnDOEhY9d9qwZdOWJTqWibAH0YD6q913HEiR5P1uPKBoarzTqA5oDOo0M2Tn9EAL1WufFb519RHLG0iqgAy8aj4yxbWFO3uCi2puVd9HuvBfzUia)zawiAqphQ3HKZi8dBvtgcb3dOWJTqWibWnaTISWh6Td19H24dXs6BRGbnCiTCknSRO88rLZcs4JsBA320gPvwdtv8fKx3VgwcsJazOHXdKGJDfa)HEtXHy)q9o0hsvTXwk88C9GBylKmEO3ou3hQ3HEiR5bu4XwiyKanaTISWh6Td50wNoKshsgyJB5IoKshkKwovddTwtX90AQuYnhGOSMmWg3YfDOEh6HSMhqHhBHGrc0a0kYcFOxpKtBD6qkDizGnULl6qkDOqA5unm0Anf3tRPsj3CaIYAYaBClx0Hu6qUFiNEO36S8qUFOnDOnFi8aj4yxbWFOoouhhAJpuiTCQg2v4h24)rynzGnULl6q9o0EaY4lOwrmyCZbikJl9h61dXs6BRGHd17qwUOd92Huta24Mdqug3YfDOnFiwsFBfmOHdPLtPHDfLNpQCwqcFuAt72MEFTYAyQIVG86(1WsqAeidnStoKC2PkkRTtL5YbqdJnqknTBSRHdPLtPHLHqWdPLtXfj20WIeB8kwKgwo7ufLXJFksZH20UTPoVwznmvXxqED)A4qA5uAy8aj4ydKmsAypHLG8XYP0WmhP5AGSdbhsqQMsYFi4bsGz6qWdK4qWgizKouIpe2atXIahYCf1HEbAn1FegthcphkTd5kWhkoKRKLlcCOhqoG0COHLG0iqgAyNCileuznCibPAkjphpqcCJQ4liV20U9oNQvwdtv8fKx3VgoKwoLg2tRP(JW0WEclb5JLtPHHFOYFOxGwtLYdXmdGWhsDahcEGehc2va84dbvwkoKYoarzhsoJWpSvhkXhskgmDiBoeGcVdnSeKgbYqd)HuvBEAnvk5Ybqnafs7q9oeEGeCSRa4p0Rh6DhQ3H2dqgFb1kIbJBoarzCP)qVDOUDQ20U9o21kRHPk(cYR7xdhslNsd7P1u)ryAypHLG8XYP0WVaeilwhszhGOSdHjd6HPdHFOYFOxGwtLYdXmdGWhsDahcEGehc2va8ynSeKgbYqd)HuvBEAnvk5Ybqnafs7q9oeEGeCSRa4p0Rh6DhQ3H2dqgFb1kIbJBoarzCP)qVEi27wBA3Ex3AL1WufFb519RHLG0iqgA4pKQAZtRPsjxoaQbOqAhQ3HWdKGJDfa)HE9qV7q9oK7h6dPQ280AQuYLdGAylKmEO3ou3hQV(oKfcQSgoKGunLKNJhibUrv8fK)qDOHdPLtPH90AQ)imTPD7DBsRSgMQ4liVUFnSeKgbYqdJjJ)Ncc3SKaD)(8UFKhQ3HWdKGJDfa)HE9qV7q9oK7hY9d9EhAZhcpqco2va8hQJdTXhkKwovd7k8dB8)iSgXajHmIB5Io0Bh6HSMhqHhBHGrc0a0kYcFOnFOqA5unxr55JkNfKWhvJyGKqgXTCrhAZhkKwovZtRP(JWAedKeYiULl6qDCOEh6dPQ280AQuYLdGAylKmEO3uCi21WH0YP0WEAn1FeM20U9U3Pvwdtv8fKx3VgwcsJazOH)qQQnpTMkLC5aOgGcPDOEhcpqco2va8h61d9Ud17qH0YDItfTscFO3oe7A4qA5uAypTM6pctBA3ExN0kRHdPLtPHXdKGJnqYiPHPk(cYR7xBA3E37Pvwdtv8fKx3VgoKwoLgwgcbpKwofxKytdlsSXRyrAy5Stvugp(PinhAt7272iTYAyQIVG86(1WH0YP0WUIYZhvoliHpknSNWsq(y5uA4oN6HCmqhsg1Hyr2H(HKXdzZH60HGhiXHGDfap(qFsDa0HEbafESfcgja(qYze(HT6qj(qak8oy6qP5m(qdJHJdzZHWpu5pK5IwhQg20WsqAeidnmEGeCSRa4p0Bko0MouVdThGm(cQvedg3CaIY4s)HE7qD3Pd17qUFileuznpTMkLCziezXQrv8fK)q913HKZi8dBvtgcb3dOWJTqWibWnaTISWh6Td5(HC)qD6qB(q4bsWXUcG)qDCOn(qH0YPAyxHFyJ)hH1igijKrClx0H64qkDOqA5unxr55JkNfKWhvJyGKqgXTCrhQdTPD7DVVwznmvXxqED)A4qA5uAy)mlnSeKgbYqddivaHDfFbDOEhYYfDO3oKAcWg3CaIY4wUinS0HuqClaSidRDJDTPD7DDETYAyQIVG86(1WH0YP0WEAn1FeMg2tyjiFSCknCNfy6qVaTM6pc7qP6HCmqodOdXAYI1HS5qIbth6fO1uP8qmZaOdHTqYiMPdr7uDOu9qP5S)qSfyJouCi8ajoe2va8nnSeKgbYqd)HuvBEAnvk5Ybqnafs7q9o0hsvT5P1uPKlha1a0kYcFOxpe7hsPdXs6BRGHdTXh6dPQ280AQuYLdGAylKmQnTBDYPAL1WH0YP0WyxHFyJ)hHPHPk(cYR7xBAtd)ai5S(HPvw7g7AL1WufFb519RHdPLtPHvjb3pRSclNsd7jSeKpwoLgM5MbsczK)qFsDa0HKZ6h2H(eRSWTdXCkL0JHpun1MDfGLkK4qH0YPWhAkHJMgwcsJazOHTCrh6Td50d17qo5qpK1crUtAt7w3AL1WH0YP0WyO1AkUkjybfaVgMQ4liVUFTPDBtAL1WufFb519RHRyrAyBweFu5RPWgyGWC5uydajTCkSgoKwoLg2MfXhv(AkSbgimxof2aqslNcRnTBVtRSgMQ4liVUFnCflsdJhbfUWCmjbKXns6QYxmePHdPLtPHXJGcxyoMKaY4gjDv5lgI0M2ToPvwdhslNsdRkiSljiunnmvXxqED)At727Pvwdtv8fKx3VgwcsJazOH)qQQn2sHNNRhCdBHKXd92Hy)q9o0hsvT5P1uPKlha1Wwiz8qVQ4qDRHdPLtPHFg2iahNpUMsBA32iTYAyQIVG86(1WvSinm2v4h2ipFaF(OYTbSOY0WH0YP0WyxHFyJ88b85Jk3gWIktBA3EFTYAyQIVG86(1WsqAeidnmEGeCSRa4Xh61d1Pd17qUFO)GXhQV(ouiTCQMNwt9hH1Kb2oKId50d1HgoKwoLg2tRP(JW0M2ToVwznmvXxqED)AyjincKHggpqco2va84d96H60H6DiNCi3p0FW4d1xFhkKwovZtRP(JWAYaBhsXHC6H6qdhslNsdJDf(Hn(FeM20UXUt1kRHPk(cYR7xdppAymzA4qA5uA49aKXxqA49qarAyaurQdGf1(HGWpPNay(hcuzXIlha1Ok(cYFOEhcavK6ayrnSRa45JkpQkDLIWYPAufFb51W7bGxXI0WqyI)hHXTCLflS20MgEEOIaAL1UXUwznmvXxqED)AyjincKHggpqIFw(glWSt8S2twdiSCQgvXxqEnCiTCknmEGeCWyAt7w3AL1WH0YP0WfzUia)zawi0WufFb519RnTBBsRSgoKwoLgMfixtciUkjybfaVgMQ4liVUFTPD7DAL1WH0YP0WyO1Ak(Eki1KkVgMQ4liVUFTPDRtAL1WufFb519RHLG0iqgAy8aj4yxbWFOxpuNouVdjNr4h2QMmecUhqHhBHGrcGBqpA4qA5uAySRWpSX)JW0M2T3tRSgMQ4liVUFnSeKgbYqdVhGm(cQbHj(Feg3YvwSWhQ3HWdKGJDfa)HE9qD6q9o0hsvT9dbHFspbW8peOYIfxoaQHTqY4HE9qVtdhslNsdJDf(Hn(FeM20UTrAL1WH0YP0WYqi4EafESfcgjawdtv8fKx3V20Mg2azXizyTYA3yxRSgMQ4liVUFn88OHXKPHdPLtPH3dqgFbPH3dbePHD)qo5q7biJVGAqyI)hHXTCLfl8H6DOhYAEAnvk5MdquwlKwUthQJd1xFhY9dThGm(cQbHj(Feg3YvwSWhQ3H(qQQnSRa45JkpQkDLIWYPAqphQdn8Ea4vSinmeM4FivvUbYIrYWAt7w3AL1WufFb519RHdPLtPHXYaG5JkxfegbQqWXgivjnSeKgbYqd7Kd9HuvByzaW8rLRccJavi4ydKQe)DnOhnCflsdJLbaZhvUkimcuHGJnqQsAt72M0kRHPk(cYR7xdhslNsdJLbaZhvUkimcuHGJnqQsAyjincKHg(dPQ2WYaG5JkxfegbQqWXgivj(7AqphQ3HEiR5P1uPKBoarzTqA5oPHRyrAySmay(OYvbHrGkeCSbsvsBA3ENwznmvXxqED)A4qA5uAySRWpSrE(a(8rLBdyrLPHLG0iqgA49aKXxqTpKQkh7OKCP)qVEOU7wdxXI0WyxHFyJ88b85Jk3gWIktBA36KwznmvXxqED)A4qA5uAywGCXjPiFWKgwcsJazOH3dqgFb1(qQQCSJsYL(d96H2inCflsdZcKlojf5dM0M2T3tRSgMQ4liVUFnCiTCknmlqU4KuKpysdlbPrGm0W7biJVGAFivvo2rj5s)HE9qBKgUIfPHzbYfNKI8btAt72gPvwdtv8fKx3VgwcsJazOHTqqL180AQuYLtHHwpwovJQ4li)H6DO9aKXxqTIyW4Mdqugx6p0RhQBNQHdPLtPHLHqWdPLtXfj20WIeB8kwKg21d3azXiwBA3EFTYAyQIVG86(1WEclb5JLtPHzUvvjPHpK5kSdzGyNehclg2eooKkywhYCrhYcalYoeGEXqjGou49PLtfcMoeMEcqy0HCfLxKflnCiTCknSmecEiTCkUiXMgwKyJxXI0WyXWg3azXizyTPDRZRvwdtv8fKx3VgoKwoLgE2jGQyyllw8OYvWLblsdlbPrGm0W7biJVGAqyI)Huv5gilgjdRHRyrA4zNaQIHTSyXJkxbxgSiTPDJDNQvwdtv8fKx3VgoKwoLg2azXizSRHLG0iqgAydKfJK1m2BUcmhct8pKQ6H6DO9aKXxqnimX)qQQCdKfJKH1WyXyAydKfJKXU20UXo7AL1WufFb519RHdPLtPHnqwmsw3AyjincKHg2azXiznR7MRaZHWe)dPQEOEhApaz8fudct8pKQk3azXizynmwmMg2azXizDRnTBS3TwznmvXxqED)AyjincKHg2YfDO3oKAcWg3CaIY4wUOd17q7biJVGAFivvo2rj5s)HE7qD7unCiTCknSmecEiTCkUiXMgwKyJxXI0WpqaI7JvWI4gilgXAtBA4hiaX9XkyrCdKfJyTYA3yxRSgMQ4liVUFnCflsd7bu4vtaX3jmMeA4qA5uAypGcVAci(oHXKqBA36wRSgMQ4liVUFnCflsddi8urzCaHjW(KanCiTCknmGWtfLXbeMa7tc0M2TnPvwdtv8fKx3VgUIfPHdG0vAK0W8SyrfuAo4YbqA4qA5uA4aiDLgjnmplwubLMdUCaK20U9oTYAyQIVG86(1WvSinSCWRuYzjcFg2aWCaHNkSbOHdPLtPHLdELsolr4ZWgaMdi8uHnaTPDRtAL1WufFb519RHRyrAypGcVAci(oHXKqdhslNsd7bu4vtaX3jmMeAt727Pvwdtv8fKx3VgUIfPHXdKGNSQ0iGgoKwoLggpqcEYQsJaAt72gPvwdtv8fKx3VgoKwoLgMLWXJl(OYdmoxPiSCknSeKgbYqdhsl3jov0kj8HuCi21WvSinmlHJhx8rLhyCUsry5uAt727Rvwdtv8fKx3VgUIfPH9bGX1mf3tsg5pqgGWsQKKgoKwoLg2hagxZuCpjzK)azaclPssAt7wNxRSgMQ4liVUFnCflsdt)PWdKGVNysdhslNsdt)PWdKGVNysBA3y3PAL1WufFb519RHRyrAyOs6kYI8CwIWNHnamh7kKmkiSgoKwoLggQKUISipNLi8zydaZXUcjJccRnTPHhwsVwzTBSRvwdhslNsd)jaMamMflnmvXxqED)At7w3AL1WH0YP0WFXmEUkeWHgMQ4liVUFTPDBtAL1WH0YP0WQjG(Iz8AyQIVG86(1M2T3PvwdhslNsddHjEA0cRHPk(cYR7xBAtBA4DcGZP0U1Tt7UBNUPU3KgMTauzXcRHzoyo7mDRZ5wNXlp0Hu2fDOC9ma7qQd4qoJfdBCdKfJKHD(qa6fdLaYFi8SOdfq2ScJ8hs6kkweUDBz2SOdX(lpeZm1obmYFi4CXmhc7OSGHd9ICiBoeZcfhYN7joN6qZdbcBahY9U64qUZodD0UTmBw0H6(LhIzMANag5peCUyMdHDuwWWHEroKnhIzHId5Z9eNtDO5HaHnGd5ExDCi3zNHoA3wMnl6qB6LhIzMANag5peCUyMdHDuwWWHEroKnhIzHId5Z9eNtDO5HaHnGd5ExDCi3zNHoA32BlZbZzNPBDo36mE5HoKYUOdLRNbyhsDahYz5Stvugp(PinhoFia9IHsa5peEw0HciBwHr(djDfflc3UTmBw0Hy)LhIzMANag5pKZaOIuhalQTbNpKnhYzaurQdGf12qJQ4liVZhYD2zOJ2TLzZIoe7V8qmZu7eWi)HCgpqIFw(2gC(q2CiNXdK4NLVTHgvXxqENpK7SZqhTBlZMfDOUF5HyMP2jGr(d5maQi1bWIABW5dzZHCgavK6ayrTn0Ok(cY78HCNDg6ODBz2SOd19lpeZm1obmYFiNXdK4NLVTbNpKnhYz8aj(z5BBOrv8fK35d5o7m0r72YSzrhAtV8qmZu7eWi)HCgavK6ayrTn48HS5qodGksDaSO2gAufFb5D(qUZodD0UTmBw0H20lpeZm1obmYFiNXdK4NLVTbNpKnhYz8aj(z5BBOrv8fK35d5o7m0r72YSzrh6DV8qDM0A2j)Hwz9YnCiPlsY4HCVg7qXEKI4lOdL1HOfKiSCQooK7SZqhTBlZMfDO39YdXmtTtaJ8hYz8aj(z5BBW5dzZHCgpqIFw(2gAufFb5D(qUZodD0UTmBw0H60lpuNjTMDYFOvwVCdhs6IKmEi3RXouShPi(c6qzDiAbjclNQJd5o7m0r72YSzrhQtV8qmZu7eWi)HCgpqIFw(2gC(q2CiNXdK4NLVTHgvXxqENpK7SZqhTBlZMfDO37LhIzMANag5pKZ4bs8ZY32GZhYMd5mEGe)S8Tn0Ok(cY78HCFtm0r72YSzrhAJE5HyMP2jGr(d5SfcQS2gC(q2CiNTqqL12qJQ4liVZhYD2zOJ2TLzZIo07)YdXmtTtaJ8hYz8aj(z5BBW5dzZHCgpqIFw(2gAufFb5D(qUZodD0UTmBw0H68V8qmZu7eWi)HCgpqIFw(2gC(q2CiNXdK4NLVTHgvXxqENpK7SZqhTBlZMfDi2D6lpeZm1obmYFiNXdK4NLVTbNpKnhYz8aj(z5BBOrv8fK35df2HyUFrz2d5o7m0r72EBzoyo7mDRZ5wNXlp0Hu2fDOC9ma7qQd4qoBoarzCmzqpoFia9IHsa5peEw0HciBwHr(djDfflc3UTmBw0H20lpeZm1obmYFiNbqfPoawuBdoFiBoKZaOIuhalQTHgvXxqENpK7SZqhTB7TL5G5SZ0ToNBDgV8qhszx0HY1ZaSdPoGd5SNudiH58Ha0lgkbK)q4zrhkGSzfg5pK0vuSiC72YSzrhQtV8qmZu7eWi)HCgpqIFw(2gC(q2CiNXdK4NLVTHgvXxqENpK7SZqhTBlZMfDO37LhIzMANag5pKZ4bs8ZY32GZhYMd5mEGe)S8Tn0Ok(cY78HCNDg6ODBz2SOdX(g9YdXmtTtaJ8hYz8aj(z5BBW5dzZHCgpqIFw(2gAufFb5D(qUVjg6ODBz2SOdXEN)LhIzMANag5pKZ4bs8ZY32GZhYMd5mEGe)S8Tn0Ok(cY78HCNDg6ODBz2SOd1n7V8qmZu7eWi)HCgavK6ayrTn48HS5qodGksDaSO2gAufFb5D(qUZodD0UTmBw0H6EtV8qmZu7eWi)HCgavK6ayrTn48HS5qodGksDaSO2gAufFb5D(qUZodD0UTmBw0H6EJE5HyMP2jGr(d5maQi1bWIABW5dzZHCgavK6ayrTn0Ok(cY78HCNDg6ODBz2SOd197)YdXmtTtaJ8hYzaurQdGf12GZhYMd5maQi1bWIABOrv8fK35df2HyUFrz2d5o7m0r72YSzrhQ7o)lpeZm1obmYFiNbqfPoawuBdoFiBoKZaOIuhalQTHgvXxqENpK7SZqhTBlZMfDOn9UxEiMzQDcyK)qodGksDaSO2gC(q2CiNbqfPoawuBdnQIVG8oFi3zNHoA32BlZbZzNPBDo36mE5HoKYUOdLRNbyhsDahY5hajN1pmNpeGEXqjG8hcpl6qbKnRWi)HKUIIfHB3wMnl6qS70xEiMzQDcyK)qodGksDaSO2gC(q2CiNbqfPoawuBdnQIVG8oFOWoeZ9lkZEi3zNHoA3wMnl6qS70xEiMzQDcyK)qodGksDaSO2gC(q2CiNbqfPoawuBdnQIVG8oFi3zNHoA32BlZbZzNPBDo36mE5HoKYUOdLRNbyhsDahYzdKfJKHD(qa6fdLaYFi8SOdfq2ScJ8hs6kkweUDBz2SOdXUtF5HyMP2jGr(d5SbYIrYAS32GZhYMd5SbYIrYAg7Tn48HCNDg6ODBz2SOdXo7V8qmZu7eWi)HC2azXizTUBBW5dzZHC2azXiznR72gC(qUZodD0UT3wMdMZot36CU1z8YdDiLDrhkxpdWoK6aoKZZdveW5dbOxmuci)HWZIouazZkmYFiPROyr42TLzZIoe7V8qmZu7eWi)HCgpqIFw(2gC(q2CiNXdK4NLVTHgvXxqENpuyhI5(fLzpK7SZqhTB7TTZTEgGr(dXUtpuiTCQdjsSHB3wn8dyutbPHzEM)qVaTMAedlhhI5iaIrY4TL5z(d5YSh8l7QlwP5c63KZQlCUGeHLtjbHQ1foxYUUTmpZFOo7bq66qDVrmDOUDA3DFBVTmpZFiMXvuSi8lVTmpZFOnFi4hsioeZosgB3wMN5p0Mp0lAjCCiajN1Ik)HEbAn1Fe2HEa0MLZ6h2Hs1dL2Hs8HYcBrzhY9bCixbWldSDi1bCO)GXeUdMRoKFkNTdn7eqgphc7kaE8Hs1d5yGCgqhkSd1PdL1Hmx0HMhQiq72Y8m)H28HyUmSrGdbNpUM6qHqmSr(d9aOnlN1pSdzZHEaJ8qzHTOSd9c0AQ)iS2TL5z(dT5dXCzN5YHSqqLDOSmcaGES2TL5z(dT5dXCUpP)qW9V536SE6moe(jwhInxuDihdKZa6q1yhk(dKDiBoegATM6qXHu2bikRDBzEM)qB(qmxliSljiuTU6SAeHLc6qWJyNk7qYOKKGNQhs6kkwK)q2COSmcaGEmEQ2UTmpZFOnFiLbooKnhk2N0Fi2cSLfRd9c0AQuEiMza0HWwize3UTmpZFOnFiLbooKnhAfmshAEOIah6bKdinhhAkHJdX2ay8qP6HyJoKmQdfsdkechhAEO6qSLMRdfhszhGOS2TL5z(dT5d15wpGzNoKCwpHL)uKMJdXwAUouNDLo0hkfEC72EBz(dXCZajHmYFOpPoa6qYz9d7qFIvw42HyoLs6XWhQMAZUcWsfsCOqA5u4dnLWr72gslNc3EaKCw)WusrxQKG7NvwHLtXuQQWYf9Mt75KhYAHi3PBBiTCkC7bqYz9dtjfDHHwRP4pKDBdPLtHBpasoRFykPOlimXtJwmvXIuyZI4JkFnf2adeMlNcBaiPLtHVTH0YPWThajN1pmLu0feM4PrlMQyrkWJGcxyoMKaY4gjDv5lgIUTH0YPWThajN1pmLu0LQGWUKGq1UTH0YPWThajN1pmLu01ZWgb448X1umLQk(qQQn2sHNNRhCdBHKX3yV3hsvT5P1uPKlha1Wwiz8vfDFBdPLtHBpasoRFykPOlimXtJwmvXIuGDf(HnYZhWNpQCBalQSBBiTCkC7bqYz9dtjfD5P1u)rymLQkWdKGJDfap(1o1Z9)GX91xiTCQMNwt9hH1Kb2u40oUTH0YPWThajN1pmLu0f2v4h24)rymLQkWdKGJDfap(1o1ZjU)hmUV(cPLt180AQ)iSMmWMcN2XTL5z(dfslNc3EaKCw)Wusrx7biJVGyQIfPqnbyJBoarzClxetZJcmzmThcisb7o92Y8m)HcPLtHBpasoRFykPOR9aKXxqmvXIuKfFEOIamnpkWKX0EiGifSFBdPLtHBpasoRFykPOR9aKXxqmvXIuaHj(Feg3YvwSWmnpkWKX0EiGifaOIuhalQ9dbHFspbW8peOYIfxoaQhaQi1bWIAyxbWZhvEuv6kfHLtDBVT3wM)qm3mqsiJ8hI2jGJdz5IoK5IouiTbCOeFOypsr8fu72gslNcRa)qcbxmsgVTH0YPWkPOlzieCvs4cQmcCBdPLtHvsrxbde3gm(2gslNcRKIU80(ab4RGvkVTH0YPWk2dqgFbXuflsrrmyCZbikJl9mnpkWKX0EiGifYze(HTQHHwRP4EAnvk5MdquwdqRilmNy4HKg5zkvv4e8aj(z5BQjj88rL)fdgplCF9jNr4h2QggATMI7P1uPKBoarznaTISWCIHhsAK)n5mc)Ww1WdKGdgRbOvKfMtm8qsJ832qA5uyLu01EaY4liMQyrkkIbJBoarzCPNP5rbMmM2dbePqoJWpSvn8aj4GXAaAfzH5edpK0iptPQc8aj(z5BQjj88rL)fdgplCp5mc)Ww1WqR1uCpTMkLCZbikRbOvKfMtm8qsJ8VkNr4h2QgEGeCWynaTISWCIHhsAK)2Y8m)HcPLtHvsrx7biJVGyQIfPil(8qfbyAEuGjJP9qarkCktPQIhYAEAnvk5MdquwlKwUt32qA5uyLu01EaY4liMQyrk(qQQCSJsYLEMMhfyYyApeqKI9aKXxqTIyW4Mdqugx6zkvv4K9aKXxqnimX)JW4wUYIfUNtYIppurGBBiTCkSsk6Apaz8fetvSifFivvo2rj5sptZJcmzmThcisb7DZuQQWj7biJVGAqyI)hHXTCLflCVS4ZdveONtEiR5bu4XwiyKaTqA5oDBdPLtHvsrx7biJVGyQIfP4dPQYXokjx6zAEuGjJP9qarkCktPQcNShGm(cQbHj(Feg3YvwSW9YIppurGEpK18ak8ylemsGwiTCN69HuvBSLcppxp4g2cjJV50EoXcbvwBpfKAsLVrv8fK)2gslNcRKIU2dqgFbXuflsXhsvLJDusU0Z08Oatgt7HaIu4uMsvfozpaz8fudct8)imULRSyH7LfFEOIa9EiR5bu4XwiyKaTqA5o17bq7CwsFJ9MRO88rLZcs4JQNfcQS2Eki1KkFJQ4li)TnKwofwjfDThGm(cIPkwKIpKQkh7OKCPNP5rbMmM2dbePqoJWpSvnpjZvyzXI)hH1a0kYcZjgEiPrEMsvf7biJVGAqyI)hHXTCLfl8TnKwofwjfDjdHGhslNIlsSXuflsHbYIrYW32qA5uyLu0LmecEiTCkUiXgtvSifdlPNPuvH7ozpaz8fudct8)imULRSyH79qwZtRPsj3CaIYAH0YDQJ(6Z99aKXxqnimX)JW4wUYIfU3hsvTHDfapFu5rvPRuewovd6PN7oXcbvw7zyJaCC(4AQgvXxq((67dPQ2Eg2iahNpUMQb90rh32qA5uyLu0vUEedoNIPuvXFW4EQjlxghqRil8RDVXSK(BBiTCkSsk6sgcbpKwofxKyJPkwKI5HkcWe2aP0uWotPQcByXsqn5mc)WwH7z5IEvnbyJBoarzClx0TnKwofwjfD5NzXuQQaqQac7k(c62gslNcRKIUKHqWdPLtXfj2yQIfPqo7ufLXJFksZbtydKstb7mLQkWdK4NLVXcm7epR9K1aclNQV(WdK4NLVPMKWZhv(xmy8SW91hEGe)S8n5S(HXxKpTWYP6Rp5StvuwRijyedWFBdPLtHvsrxpdBeGJZhxtXuQQypaz8fudct8)imULRSyH79HuvByxbWZhvEuv6kfHLt1GEUTH0YPWkPORNXYPykvv4Ut2dqgFb1GWe)pcJB5klw4E7biJVGAfXGXnhGOmU0)klPVTcg6z5IEtnbyJBoarzClxuF9HhiXplFdqQzrE(ticJ6ThGm(cQvedg3CaIY4s)RB697OV(CFpaz8fudct8)imULRSyH79HuvByxbWZhvEuv6kfHLt1GE642gslNcRKIUKHqWdPLtXfj2yQIfPWCaIY4yYGEUTH0YPWkPOlpTMkLCSbOIL5IPuvH7obavK6ayrn2sHkG8yoozLc(OYXqpeihahdTwtLfRE7biJVGAfXGXnhGOmU0)wNVJ(6Z9hYAEAnvk5MdquwlKwUt9EiR5P1uPKBoarznaTISWV(EBmlPVTcg642gslNcRKIUKHqW9ak8ylemsamtPQI9aKXxqnimX)JW4wUYIfUNCgHFyRAyO1AkUNwtLsU5aeL1a0kYcZjgEiPr(36U7BBiTCkSsk6sgcb3dOWJTqWibWmLQkCYEaY4lOgeM4)ryClxzXc3Z99aKXxqTIyW4Mdqugx6FRBNU5oTXobavK6ayrn2sHkG8yoozLc(OYXqpeihahdTwtLfRoUTH0YPWkPORNHncWX5JRPykvv4K9aKXxqnimX)JW4wUYIfU3hsvTXwk88C9GBylKm(g79(qQQnpTMkLC5aOg2cjJVUPBBiTCkSsk66NcclhialI)N1NayMsvfFiv1M5aeL18dBvV9aKXxqTIyW4Mdqugx6FRt32qA5uyLu0vUEedoNIPuvriTCN4urRKWVXUsUZ(gBHGkRHdjivtj554bsGBufFb57O3hsvTXwk88C9GBylKm(MI3R3hsvTzoarzn)Ww1Bpaz8fuRigmU5aeLXL(360TnKwofwjfDLRhXGZPykvvesl3jov0kj8BD37dPQ2ylfEEUEWnSfsgFtX717dPQ2mhGOSMFyR6ThGm(cQvedg3CaIY4s)BDQNtaqfPoawulxpIbN7e)zmQSme9C3jwiOYAQGzXnxeh7k8dB4gvXxq((6ZtFiv1MkywCZfXXUc)WgUb90XTnKwofwjfDLRhXGZPykvvesl3jov0kj8BD37dPQ2ylfEEUEWnSfsgFtX717dPQ2Y1JyW5oXFgJkldrdqRil8RD3davK6ayrTC9igCUt8NXOYYqCBdPLtHvsrx56rm4CkMsvfFiv1gBPWZZ1dUHTqY4BkyV7EwiOYA4bsWLt5HsRrv8fKVNfcQSMkywCZfXXUc)WgUrv8fKVhaQi1bWIA56rm4CN4pJrLLHO3hsvTzoarzn)Ww1Bpaz8fuRigmU5aeLXL(360TnKwofwjfDXcKRjbexLeSGcGNPuvXFW4EwUiUnCFsVUjNEBdPLtHvsrxyO1Ak(Eki1KkptPQI)GX9SCrCB4(KET73)2gslNcRKIUWqR1uCpTMkLCZbikJPuvXFW4EwUiUnCFsVYENUTH0YPWkPOlxr55JkNfKWhftPQc8aj4yxbWROt32qA5uyLu0f2v4h24)rymLQkWdKGJDfa)RDQhaQi1bWIA)qq4N0tam)dbQSyXLdG69HuvB)qq4N0tam)dbQSyXLdGAaAfzHFTt3wM)qDo1d9cak8ylemsa8HcaDOqaOW74qH0YDIPdvZHkI8hYMdHJD6qyxbWJVTH0YPWkPOlxr55JkNfKWhftPQc8aj4yxbW)MIn1Z9hYAEafESfcgjqlKwUt913dznpTMkLCZbikRfsl3PoUTH0YPWkPOlxr55JkNfKWhftPQc8aj4yxbW)Mc279HuvBfzUia)zawiAqp9KZi8dBvtgcb3dOWJTqWibWnaTISWV19gZs6BRGHBBiTCkSsk6YvuE(OYzbj8rXuQQapqco2va8VPG9EFiv1gBPWZZ1dUHTqY4BD37HSMhqHhBHGrc0a0kYc)MtBDsjzGnULlsPqA5unm0Anf3tRPsj3CaIYAYaBClxuVhYAEafESfcgjqdqRil8RoT1jLKb24wUiLcPLt1WqR1uCpTMkLCZbikRjdSXTCrk5UtFRZs330MXdKGJDfaFhDSXH0YPAyxHFyJ)hH1Kb24wUOE7biJVGAfXGXnhGOmU0)klPVTcg6z5IEtnbyJBoarzClx0Mzj9TvWWTnKwofwjfDjdHGhslNIlsSXuflsHC2PkkJh)uKMdMWgiLMc2zkvv4e5StvuwBNkZLdWTL5peZrAUgi7qWHeKQPK8hcEGeyMoe8ajoeSbsgPdL4dHnWuSiWHmxrDOxGwt9hHX0HWZHs7qUc8HId5kz5Iah6bKdinh32qA5uyLu0fEGeCSbsgjMsvfoXcbvwdhsqQMsYZXdKa3Ok(cYFBz(db)qL)qVaTMkLhIzgaHpK6aoe8ajoeSRa4XhcQSuCiLDaIYoKCgHFyRouIpKumy6q2CiafEh32qA5uyLu0LNwt9hHXuQQ4dPQ280AQuYLdGAakKwp8aj4yxbW)676ThGm(cQvedg3CaIY4s)BD70BlZFOxacKfRdPSdqu2HWKb9W0HWpu5p0lqRPs5HyMbq4dPoGdbpqIdb7kaE8TnKwofwjfD5P1u)rymLQk(qQQnpTMkLC5aOgGcP1dpqco2va8V(UE7biJVGAfXGXnhGOmU0)k7DFBdPLtHvsrxEAn1FegtPQIpKQAZtRPsjxoaQbOqA9WdKGJDfa)RVRN7Fiv1MNwtLsUCaudBHKX36UV(SqqL1WHeKQPK8C8ajWnQIVG8DCBdPLtHvsrxEAn1FegtPQcmz8)uq4MLeO73N39JShEGeCSRa4F9D9C393BZ4bsWXUcGVJnoKwovd7k8dB8)iSgXajHmIB5IE7HSMhqHhBHGrc0a0kYcV5qA5unxr55JkNfKWhvJyGKqgXTCrBoKwovZtRP(JWAedKeYiULlQJEFiv1MNwtLsUCaudBHKX3uW(TnKwofwjfD5P1u)rymLQk(qQQnpTMkLC5aOgGcP1dpqco2va8V(UEH0YDItfTsc)g732qA5uyLu0fEGeCSbsgPBBiTCkSsk6sgcbpKwofxKyJPkwKc5Stvugp(Pinh3wM)qDo1d5yGoKmQdXISd9djJhYMd1PdbpqIdb7kaE8H(K6aOd9cak8ylemsa8HKZi8dB1Hs8Hau4DW0HsZz8HggdhhYMdHFOYFiZfTounSDBdPLtHvsrxUIYZhvoliHpkMsvf4bsWXUcG)nfBQ3EaY4lOwrmyCZbikJl9V1DN65UfcQSMNwtLsUmeISy1Ok(cY3xFYze(HTQjdHG7bu4XwiyKa4gGwrw43C39oTz8aj4yxbW3XghslNQHDf(Hn(FewJyGKqgXTCrDOuiTCQMRO88rLZcs4JQrmqsiJ4wUOoUTH0YPWkPOl)mlMKoKcIBbGfzyfSZuQQaqQac7k(cQNLl6n1eGnU5aeLXTCr3wM)qDwGPd9c0AQ)iSdLQhYXa5mGoeRjlwhYMdjgmDOxGwtLYdXmdGoe2cjJyMoeTt1Hs1dLMZ(dXwGn6qXHWdK4qyxbW3UTH0YPWkPOlpTM6pcJPuvXhsvT5P1uPKlha1auiTEFiv1MNwtLsUCaudqRil8RSRelPVTcg24pKQAZtRPsjxoaQHTqY4TnKwofwjfDHDf(Hn(Fe2T92gslNc3WIHnUbYIrYWkGWepnAXuflsbEGecYSSyXbqFhmjDife3calYWkyNPuvXEaY4lO2hsvLJDusU0)QfawK18j2IssViDAZU39gZs6BRGHnEpaz8fudct8)imULRSyH742gslNc3WIHnUbYIrYWkPOlimXtJwmvXIuGHQVygppwK5Yb2ykvvShGm(cQ9Huv5yhLKl9VAbGfznFITOK0lsNuY9U349aKXxqnimX)JW4wUYIfUJBBiTCkCdlg24gilgjdRKIUGWepnAXuflsbTECaOqWhGVIssmLQk2dqgFb1(qQQCSJsYL(xD3calYA(eBrjPxKo1HsS3TsU39gVhGm(cQbHj(Feg3YvwSWDCBVTH0YPWn5Stvugp(PinhkWdKGdgJPuvH74bs8ZY3uts45Jk)lgmEw4(6davK6ayrnpjdhzXIJhibhhM0fj6O3dznpTMkLCZbikRfsl3PBBiTCkCto7ufLXJFksZHsk6cpqcoymMsvf4bs8ZY3ybMDIN1EYAaHLt1ZjaOIuhalQ5jz4ilwC8aj44WKUirp33dqgFb1kIbJBoarzCP)1UDAF9ThGm(cQvedg3CaIY4s)BBYPDCBdPLtHBYzNQOmE8trAousrx4bsWbJXuQQapqIFw(gBPWZDbvg3cPLsCpNaGksDaSOMNKHJSyXXdKGJdt6Ie9CYdznpTMkLCZbikRfsl3PE7biJVGAfXGXnhGOmU0)g7V)TnKwofUjNDQIY4XpfP5qjfD5jzUcllw8)imMKoKcIBbGfzyfSZuQQyL1lTaWISMlkeMR2J0ykvv4K9aKXxqnimX)JW4wUYIfUhEGe)S8nbfE(3bNyiwpcQN7pK180AQuYnhGOSwiTCN6Hhibh7ka(x7UV(CYdznpTMkLCZbikRfsl3PE7biJVGAfXGXnhGOmU0)27CAh32qA5u4MC2PkkJh)uKMdLu0LNK5kSSyX)JWys6qkiUfawKHvWotPQIvwV0calYAUOqyUApsJPuvHt2dqgFb1GWe)pcJB5klw4E4bs8ZY3yK2ZcZNPZgjYIvp3FiR5P1uPKBoarzTqA5o1xFo5HSMNwtLsU5aeL1cPL7uV9aKXxqTIyW4Mdqugx6F7DoTJBBiTCkCto7ufLXJFksZHsk6YtYCfwwS4)rymjDife3calYWkyNPuvHt2dqgFb1GWe)pcJB5klw4EUJhiXplFtDaSO)akIdODcKeUV(ChpqIFw(2(iclfehpIDQSEobpqIFw(gJ0Ewy(mD2irwS6OJEo5HSMNwtLsU5aeL1cPL70TnKwofUjNDQIY4XpfP5qjfD5jzUcllw8)imMKoKcIBbGfzyfSZuQQypaz8fudct8)imULRSyH75UtSqqL1Eg2iahNpUMQV(KZi8dBv7zyJaCC(4AQgGwrw4xdPLt18KmxHLfl(FewJyGKqgXTCrD0ZjYze(HTQHHwRP4EAnvk5Mdquwd6PN7pK180AQuYnhGOSgGwrw4xF)(6toJWpSvnm0Anf3tRPsj3CaIYAaAfzH5edpK0i)RBYPDCBdPLtHBYzNQOmE8trAousrxQcc7sccvJPuvbEGe)S8T9rewkioEe7uz9(qQQT9rewkioEe7uzn)WwXuwgbaqpgpvv8HuvB7JiSuqC8i2PYAqp32qA5u4MC2PkkJh)uKMdLu0fwoqGSyXT0CrmLQkWdK4NLVjN1pm(I8PfwovVhYAEAnvk5MdquwlKwUt32qA5u4MC2PkkJh)uKMdLu0fwoqGSyXT0CrmLQkCcEGe)S8n5S(HXxKpTWYPUTH0YPWn5Stvugp(PinhkPORC9qLplwCzyb2aZJlIPuvXdznpTMkLCZbikRfsl3PE4bsWXUcGxHtVT32qA5u4MRhUbYIrScimXtJwmvXIuGZsfsWzjcFg2aWCA9f062gslNc3C9WnqwmIvsrxqyINgTyQIfPaNLkKGh4NeeLH506lO1T92gslNc3gwsVIpbWeGXSyDBdPLtHBdlPxjfD9fZ45Qqah32qA5u42Ws6vsrxQjG(Iz832qA5u42Ws6vsrxqyINgTW32BBiTCkCBEOIakWdKGdgJPuvbEGe)S8nwGzN4zTNSgqy5u32qA5u428qfbusrxfzUia)zawiUTH0YPWT5HkcOKIUybY1KaIRscwqbWFBdPLtHBZdveqjfDHHwRP47PGutQ832qA5u428qfbusrxyxHFyJ)hHXuQQapqco2va8V2PEYze(HTQjdHG7bu4XwiyKa4g0ZTnKwofUnpuraLu0f2v4h24)rymLQk2dqgFb1GWe)pcJB5klw4E4bsWXUcG)1o17dPQ2(HGWpPNay(hcuzXIlha1Wwiz813DBdPLtHBZdveqjfDjdHG7bu4XwiyKa4B7TnKwofU9abiUpwblIBGSyeRact80OftvSifEafE1eq8DcJjXTnKwofU9abiUpwblIBGSyeRKIUGWepnAXuflsbGWtfLXbeMa7tcUTH0YPWThiaX9XkyrCdKfJyLu0feM4PrlMQyrkcG0vAK0W8SyrfuAo4Ybq32qA5u42deG4(yfSiUbYIrSsk6cct80OftvSifYbVsjNLi8zydaZbeEQWgWTnKwofU9abiUpwblIBGSyeRKIUGWepnAXuflsHhqHxnbeFNWysCBdPLtHBpqaI7JvWI4gilgXkPOlimXtJwmvXIuGhibpzvPrGBBiTCkC7bcqCFScwe3azXiwjfDbHjEA0IPkwKcwchpU4JkpW4CLIWYPykvvesl3jov0kjSc2VTH0YPWThiaX9XkyrCdKfJyLu0feM4PrlMQyrk8bGX1mf3tsg5pqgGWsQK0TnKwofU9abiUpwblIBGSyeRKIUGWepnAXuflsb9Ncpqc(EIPBBiTCkC7bcqCFScwe3azXiwjfDbHjEA0IPkwKcOs6kYI8CwIWNHnamh7kKmki8T92gslNc3mqwmsgwXEaY4liMQyrkGWe)dPQYnqwmsgMP9qarkC3j7biJVGAqyI)hHXTCLflCVhYAEAnvk5MdquwlKwUtD0xFUVhGm(cQbHj(Feg3YvwSW9(qQQnSRa45JkpQkDLIWYPAqpDCBdPLtHBgilgjdRKIUGWepnAXuflsbwgamFu5QGWiqfco2aPkXuQQWjFiv1gwgamFu5QGWiqfco2aPkXFxd652gslNc3mqwmsgwjfDbHjEA0IPkwKcSmay(OYvbHrGkeCSbsvIPuvXhsvTHLbaZhvUkimcuHGJnqQs831GE69qwZtRPsj3CaIYAH0YD62gslNc3mqwmsgwjfDbHjEA0IPkwKcSRWpSrE(a(8rLBdyrLXuQQypaz8fu7dPQYXokjx6FT7UVTH0YPWndKfJKHvsrxqyINgTyQIfPGfixCskYhmXuQQypaz8fu7dPQYXokjx6FDJUTH0YPWndKfJKHvsrxqyINgTyQIfPGfixCskYhmXuQQypaz8fu7dPQYXokjx6FDJUTH0YPWndKfJKHvsrxYqi4H0YP4IeBmvXIu46HBGSyeZuQQWcbvwZtRPsjxofgA9y5unQIVG892dqgFb1kIbJBoarzCP)1UD6TL5peZTQkjn8HmxHDide7K4qyXWMWXHubZ6qMl6qwayr2Ha0lgkb0HcVpTCQqW0HW0tacJoKRO8ISyDBdPLtHBgilgjdRKIUKHqWdPLtXfj2yQIfPalg24gilgjdFBdPLtHBgilgjdRKIUGWepnAXuflsXStavXWwwS4rLRGldwetPQI9aKXxqnimX)qQQCdKfJKHVTH0YPWndKfJKHvsrxqyINgTyclgtHbYIrYyNPuvHbYIrYAS3CfyoeM4Fiv1E7biJVGAqyI)Huv5gilgjdFBdPLtHBgilgjdRKIUGWepnAXewmMcdKfJK1ntPQcdKfJK16U5kWCimX)qQQ92dqgFb1GWe)dPQYnqwmsg(2gslNc3mqwmsgwjfDjdHGhslNIlsSXuflsXdeG4(yfSiUbYIrmtPQclx0BQjaBCZbikJB5I6ThGm(cQ9Huv5yhLKl9V1TtVT32qA5u4M5aeLXXKb9OOiZfb4pdWcbtPQI9aKXxqTIyW4Mdqugx6FL9oDBdPLtHBMdqughtg0Jsk6IfixtciUkjybfaptPQI9aKXxqTIyW4Mdqugx6FL9nAZUhslNQHHwRP4EAnvk5MdquwJyGKqgXTCrkfslNQHDf(Hn(FewJyGKqgXTCrD0ZD5mc)Ww1KHqW9ak8ylemsaCdqRil8RSVrB29qA5unm0Anf3tRPsj3CaIYAedKeYiULlsPqA5unm0AnfFpfKAsLVrmqsiJ4wUiLcPLt1WUc)Wg)pcRrmqsiJ4wUOo6RVhYAEafESfcgjqdqRil8B7biJVGAfXGXnhGOmU0RuiTCQggATMI7P1uPKBoarznIbscze3Yf1XTnKwofUzoarzCmzqpkPOlm0AnfFpfKAsLNPuvH77biJVGAfXGXnhGOmU0)k7DAZUhslNQHHwRP4EAnvk5MdquwJyGKqgXTCrD0ZD5mc)Ww1KHqW9ak8ylemsaCdqRil8RS3Pn7EiTCQggATMI7P1uPKBoarznIbscze3YfPuiTCQggATMIVNcsnPY3igijKrClxuh913dznpGcp2cbJeObOvKf(T9aKXxqTIyW4Mdqugx6vkKwovddTwtX90AQuYnhGOSgXajHmIB5I6OJ(6ZDNaGksDaSOgBPqfqEmhNSsbFu5yOhcKdGJHwRPYIvV9aKXxqTIyW4Mdqugx6F7DoTJBBiTCkCZCaIY4yYGEusrxYqi4EafESfcgjaMPuvXEaY4lOwrmyCZbikJl9VYE3B29qA5unm0Anf3tRPsj3CaIYAedKeYiULlsPqA5unSRWpSX)JWAedKeYiULlQJBBiTCkCZCaIY4yYGEusrxyO1AkUNwtLsU5aeLXuQQWYf9MAcWg3CaIY4wUOEU)qwZdOWJTqWibAH0YDQ3dznpGcp2cbJeObOvKf(TqA5unm0Anf3tRPsj3CaIYAedKeYiULlQJEU7eleuznm0AnfFpfKAsLVrv8fKVV(EiRTNcsnPY3cPL7uh9Chpqco2va8kCAF95(dznpGcp2cbJeOfsl3PEpK18ak8ylemsGgGwrw4xdPLt1WqR1uCpTMkLCZbikRrmqsiJ4wUiLcPLt1WUc)Wg)pcRrmqsiJ4wUOo6Rp3FiRTNcsnPY3cPL7uVhYA7PGutQ8naTISWVgslNQHHwRP4EAnvk5MdquwJyGKqgXTCrkfslNQHDf(Hn(FewJyGKqgXTCrD0xFU)HuvBSa5AsaXvjblOa4Bqp9(qQQnwGCnjG4QKGfua8naTISWVgslNQHHwRP4EAnvk5MdquwJyGKqgXTCrkfslNQHDf(Hn(FewJyGKqgXTCrD0HgoGmxdqdRnTP1]] )


end
