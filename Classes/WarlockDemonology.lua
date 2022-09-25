-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local GetPlayerAuraBySpellID = _G.GetPlayerAuraBySpellID
local ceil = math.ceil

local RC = LibStub( "LibRangeCheck-2.0" )

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
        vilefiend = 23160, -- 264119

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


    local dreadstalkers_travel_time = 1

    spec:RegisterCombatLogEvent( function( _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName )
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

                -- Call Dreadstalkers (use travel time to determine buffer delay for Demonic Cores).
                elseif spellID == 104316 then
                    -- TODO:  Come up with a good estimate of the time it takes.
                    dreadstalkers_travel_time = ( select( 2, RC:GetRange( "target" ) ) or 25 ) / 25

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
        local gcd, gcd_duration = GetSpellCooldown( state.cooldown.global_cooldown.id )

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


    local ExpireDreadstalkers = setfenv( function()
        addStack( "demonic_core", nil, set_bonus.tier28_2pc > 0 and 3 or 2 )
    end, state )


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
                local demon, extraTime = nil, 0

                -- Grimoire Felguard
                if texture == 136216 then
                    extraTime = action.grimoire_felguard.lastCast % 1
                    demon = grim_felguard_v
                elseif texture == 1616211 then
                    extraTime = action.summon_vilefiend.lastCast % 1
                    demon = vilefiend_v
                elseif texture == 1378282 then
                    extraTime = action.call_dreadstalkers.lastCast % 1
                    demon = dreadstalkers_v
                elseif texture == 135002 then
                    extraTime = action.summon_demonic_tyrant.lastCast % 1
                    demon = demonic_tyrant_v
                end

                if demon then
                    insert( demon, summoned + duration + extraTime )
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

        if buff.dreadstalkers.up then
            state:QueueAuraExpiration( "dreadstalkers", ExpireDreadstalkers, 1 + buff.dreadstalkers.expires + dreadstalkers_travel_time )
        end

        class.abilities.summon_pet = class.abilities.summon_felguard

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
        -- For virtual imps, assume they'll take 0.5s to start casting and then chain cast.
        local longevity = 0.5 + ( state.level > 55 and 7 or 6 ) * 2 * state.haste
        for i = #guldan_v, 1, -1 do
            local imp = guldan_v[i]

            if imp <= query_time then
                if ( imp + longevity ) > query_time then
                    insert( wild_imps_v, imp + longevity )
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
            if time > query_time then
                n = n + 1
            end
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
                return 0
            end

            return query_imp_spawn.remains
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
    spec:RegisterPet( "sayaad",
        function()
            if Glyphed( 240263 ) then return 120526
            elseif Glyphed( 240266 ) then return 120527
            elseif Glyphed( 112868 ) then return 58963
            elseif Glyphed( 365349 ) then return 184600
            end
            return 1863
        end,
        "summon_sayaad",
        3600,
        "incubus", "succubus" )

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

    spec:RegisterStateExpr( "two_cast_imps", function ()
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
                applyBuff( "dreadstalkers", 12, set_bonus.tier28_2pc > 0 and 3 or 2 )
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
                if legendary.implosive_potential.enabled then
                    if buff.implosive_potential.up then
                        stat.haste = stat.haste - 0.01 * buff.implosive_potential.v1
                        removeBuff( "implosive_potential" )
                    end
                    if buff.implosive_potential.down then stat.haste = stat.haste + 0.05 * buff.wild_imps.stack end
                    applyBuff( "implosive_potential", 12 )
                    stat.haste = stat.haste + ( active_enemies > 2 and 0.05 or 0.01 ) * buff.wild_imps.stack
                    buff.implosive_potential.v1 = ( active_enemies > 2 and 5 or 1 ) * buff.wild_imps.stack
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

            readyTime = function ()
                if settings.dcon_imps == 0 or buff.wild_imps.stack > settings.dcon_imps then return 0 end

                local missing = settings.dcon_imps - buff.wild_imps.stack
                if missing <= 0 then return 0 end
                if missing > 3 or missing > #guldan_v then return 3600 end

                -- Still a little risky, because imps can despawn, too.
                for i, time in ipairs( guldan_v ) do
                    if time > query_time then
                        missing = missing - 1
                        if missing <= 0 then return time - query_time end
                    end
                end

                return 3600
            end,

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


    spec:RegisterPack( "Demonology", 20220911, [[Hekili:v3ZAtUnUr(BzQurwAEilXrJ9yFJuQn7MlNDTNtQm7D7(PHIIesI1qrQWhYEUsL(TFDdWhaGaGKsA8M8HD9irWgD3Or)cnA904N(LNE0ZjL80xSgzzn6dJhpC8Oj3BD7tpM(YwYtpU1X9zNvWFe6Sb())eztuyuq0QxWh9sqKJhcIKOSyx4Xp6V5hF6Xfz(bPFk8PfkH94jW43sCHV(DV7Phx775ryJLK4YpdhM)RoXbrUpF4ZRtt3M8X3(2v(PRZwm0nAZBt83Kf4K6hf6g7Smf)S7Bp85hjBtjBwqIpmF84RpmhN6dF(WN)X1oHRijF8WNV5W8h3sccom)NbypK(f)TWay6IjaG3qc9omNIflIcspmFBm5g47x4a)T)s4)W)nb(VWKuNq4d9JGjBTtSNRtc8XL4hxeLKqsg8FCyUxu4BGVnAhj21z7H5j4ityG6LOS3etomhb9DiepmpDn85OTKqsmd1(7rFfjMh93UocEUtqa8fEIOvAe(5ixoKQKaYHYU)ommNac(m)WusCC228N9d7I8ba(4F(Mz)xr)vad36S5W8VUMewHHHrW75SiklF2sY2SHIohM)lVedZidu)NbKK1S1J)3iC1jaE3hJc2rNxxNqxsGns5U0LdpgWkXh4rm48lXVWEKdd3(kWz9dxLtw(aH(JriAbeR7ZjsVZgNNl5HiFXpk2pfEweDr(RrXpZ4(FLqrjysCtZa(6lSxcEaiLvJ0(0gGdVdFLOnBbkBHFafQSb)FFfSMdI9EjdF6Xa)K0e62cyTYon2p8zc9l(cD)gj0zraX7P)CXMky3tqajfPq74SfWwl3xCdi2PoXRWxeEThbCee1vowG6iX(op94oh4FaqpCr2YL2jVe6A7cmVhWvEesd98rPdxGiElvGdiR(WwKdZV8W8vUEd348n6FxcOSeInkezN6VbMrqSDWtPWgxjYOe5Ycxeef5zdKv66xsspjS7koSZigvWgRn7aQERguLSz7lXeNa7OyVqCwBhQ2xl2oGIWJT6oExhvqm)X1BzIogeCwf4457KgfNyd68ciBQOV6pIcuxqegMJuBhM8RkyxXhaYaL3w4h6nCPpjWZoAPnWJtsI2Kmm)vomF)Eq3zwib08TIm0J468ckEIVQDItQ7Asq1Gb(upyxjYbz7LTtz7YqmFhrus3ookvLaxfkwIFRWDN2(H78xfftTlunNWeErhqXE0fWYLUqY3sZrYcXaRrmQw7yMDy(TJORXQihzHYkY5c6u3wMERi(bhd9FHHLi6amr5JVxnzprZEraD834qvPHBrK4hg2c1JJfeqC8Sx8In5BoB2cJwA10m1W4dOLz2YlJ9EsmHjSL)AAYb(WDVM8HNj7aNaSJI()ibWt7aF41KKF3RajlSrbLRxefhsSJjGRw(ePTk8dExURjG4p1Zezj)M5Ld42wzqvMkoX77oNOr2Wff(2nCl6TODc1zrrgGBuuGx0xdfhsmzJdqIuPEgMmucrgs(gXnlLGZjHJSlHhZvqBjwq2wdsC8Z69sONAWL)gWUBiYHucBB6T6L3UxdxEzPdQknIyuYaDgO(iqK(Ph5DHfdas1iZ2Iy2hA2ugZTE7nep)06wYAJPtxiEmCbmfCofDN4lJhzYKtZZSryR3bI2R1D6H5JQMe)nGJ4E4S46Kc((hhTDDUBr5QCsiPa)0O3lMmGp(UQjle8we2rSnkg2ez2BdJG89fouNVrsTKS42PRQg9Ahqus)wU(C7rCHOvS9aFg9aFqdEMeNiSL6uXe2O3bYUG)hGuXrHY4MA6YphAwHLZmyjPgMyeV5CXAvS)Mi)yI9ssWQmqSYSVwn4J347ocUy3xRoMzP1RvFpxhkNT(sEB(v)GLXeVeWMZk)a0B2KSTemSCBgGLDtPf(yuQnsI(v5Mzl3(ADAle63luHT1Lfu5oyf(Yaaq1l9Jtkry23YzCLFLLt9QXv9oqKdQ7MrDXoExnWjU6rfy0aEN24v7xk1CCeZdDIyA1kMagvNs6j)GVl4c1PIAQ4kC0sZtFDXS6BefHkZIThzPtg4rRcJ1ykFJ93YaXFHbEqQa9GhtMhDEOzefMgmTQyExD254hq3fZn7ycDTXCfxA)wyphWpwNHUOXp7fghkgPZ3asdcZwAmt4hJhzh4(J9gNv(UsJtEBC0waViPvVBH2h8VcYWWd6MpV6CARHKe0XzHQDO6DYdFxbYaKJnlnuIAtvfUxx4f6NXVhjMQZCRhoDULCiHnZT0yiRtHpFbM4DBwAY5Xp(CEQkuQMXUXwDcrkXcHiQRBhWeskhvvZi5OtahnzOIQigC5XZgcIjzi9ekO7PgvqE52qRz80e9vl(TF)iWTXKD24PfmE4ANq6oVvzbE4bP07ijozZcntCLB5KZwHjTgA5agroDh2b1Wc7d24j(Wo3NCOuEOpiemgcsJRmgIHUY5aZGGkts94cxTCcd9x7Zo7uU800MKirbKWJX3FqDNC1XxIwLZv17KoE0PuCAP)Q1P28EWuEsvczkau7J)jcvdUshTAfWEkKByZaZbJhu4Fni)blHUPcN9MzkJPifFdzRFD80keYSFBpbad5mI5ea7CFadgUXrbrqSXDMcRD2r47kB7QBY2MciR8ajlxOuhiKaBig06es8S36aY3K2fvjMjX7pBBM42jSnkTqWux(inReHpvxiu0N7Wx1yU)GCir6tPxdj79DIh18aEhRzVeiuscxLUM6hV(KwAEjQZoXbePLvtXPBPpvJnkOBkxtZyNN4n0Jr(YtAHSXCnyPp3Mu56CoeY8AuSGlfQGcbcnXWRqAhl)g2SP3YhtMXg0zUXNWsjX4IJoFmLnuKQbh4Lw67cBQXD5jYoSRXFRPuHTIN3jYQybJ(M52xauf2nd4JVtqoykThwBYVSGkaYzsXhzHOMFkfdlnBXw(lsFgI2AN2DJfwGfS8zP3EQcoT1RjNtq8vfDWR2rWVJLXrBSHW9TzjDqYuNhHIq1gKKsxr2IEhc((iaYG3TcWdds0nk0lZpvjS6ol)F3ew17G0XjS(9Hl)Vuc2697Q0)z09i70iBpFs(XLwbmLhvILSxkTaOw816HIKXBP3NfTWK)W50LxXVCRENdKsWmh0edyLcg9g1LkkeMqqLeWcyTnzRVhyRZErwCi90kJIj1pZyTJK31iEAUkNRuuuVnBWD3ycm8fbCN(Rxu0g67PR23K4cIzH9tlpm)N4DB4WChAnQgGF5lSedVJCnwtOW)rqcLwrOoOlGSQBvhxe3UEBX2dT5yO8eR0e0lL20BVtEchxTqiCsVfH(2QtQBMuzsAuKsVrhd4MQugzv5tTUZXz0qwLsI1ESUthuIrYnuJq)Htf6m1YGRTZ(tfkOVr84FygsUu5PniIMNJifVPDlF6ToDbxG0yjDS(L4Zty03QRQGymlygEMiTp9x9txtlh7hl9pbl1AWbLRz)l8)PVh7utWAOiCfMEV01yQ6kRp8RXvewvTV2jHw2ZR9xTMV0PLybn4xeLE0BjPXqL0UBGBZsHmhvlA(iqlC8XExLKkkgP3oulqhJ5oZWiAfQnr2sMqmXSIbtyP)XTv3rHIAHpj)IhKVYNFjdYahtckQJ9kvDmrcxWDcct5nv1ETGbf4YWqCtP0RKDXjn6(eehpsMYwABIm)jADgvH908GCn150wr(Vo0dTubO0tdHs3LzRVb56zL1JAZbKOIPIOQ(4WpbHFds0gSotsHPjmlzyQpj26EBRTUg5l9PE4x3UHAJgIhr9mtM3UPeaI2aKGXnCfgzolvz9rOF9dTZRBHrVRcDwgYrraT6MwQjoL2yQWfCC6ml1zdCt0La0g9f9LOS8RPdelkWMP8uuN1DYk7wGoMtQ59QOspQMURr7DVb(u0Zo5xAOCLkG)HBqpB)AZUWAuJxzC557zlxibgNqg7eoH(g8aLTB4UJD3WaEN3mkZtDXEISfth(4luhesdUG9K6YHVR2)(FqZwC3qp(Rs3QiQndCjLzEt5ng7AAnMewCH(EJh7kMrOU)KqLQO82HTDhPQNXvKFuop)nSsJ2ck7ySWMtUybf2CcFCl9clUWrzP1uaaiaFBViqLUtbtvzj3uS5P4kfUGScW(HhM)dUUKTPj4MIWBaEYMLi3Hb9e2LQtGlvU6xEE3OkyNa8a8tLQnN8ii2sKOTAfTz(5HeTHGYSW7GUZMLGj4b(RmgYub3MgyA9IeS4M4fqCwNyNqCJbdvPe31H()ZmcVYsnJinVcGk57CvAUaTPp8IJ2ZxqNKLERXYkXZjvQGf4dru8cKxLgfVb0ujl5vFaP1ljevQkt4sAc6EdnzpO2UAwtzxBwwLaQZdgZvnF9z8IJCsLs9Yru2fvjisTFtLA(z8LUKpPRAHlGx1WP4ZKMgWxXd1QgcQYL8ZZ2yf2FrRlVkjVn4VwFfpqSm8vOpOyG1ZDPKxlkuXuLtsXX2Uu1ukwzYsnVdXsIr63YB29BL4G5ukwfX5eTOZ75zqkoNqz7mMUbZnVHOn1bWRFnUuxIhgVnFz6O9sn76amzaMlJDGvTqhMZYljs7eyiGUbBpHkGKR7vlivy7Rt4rlqcZm8wHI6UiNATPOqGNY)5VA14bWB20KI9RfZ8MiWre)u7TX(jBA)gSgzdIWvXwzELs2e3a)TjK2rVVV8wCZ)QkSxZ5BLuWeGVmzB2wZSIPCxynQLrXvD9ZvyWx0jYLljUOhIPRPnJIyNDe0b6GOVI9ub8CTYRIBMF)yqy)ZmF6Hk455JaXjaZRdzRdkSHjIm0ddtQLOQyBwqH3cfqbBchlHbJAlDc934aXJTs9YvDve5RwAGHkNf4w4yazykwZKj2faxC1sXuw6ql7BOHlz462vonwN00qtVL26EmKKfJAdEj0beyTjHRXEwqCle6bFpMChtDEZ8zDttQXcQ0u6)5zc1qSwVVyBg45HNZgyrVAdsQYVxBFBGAUDj6cZosscjGZPx5NOWWedgqi3r0SSa)bjEh4qufuu8mTbv5e7Ug4EWgyBqKMeM5N(c1vIkWPFiAdKYnkzdOHIRluWWj4p54ZggKcD9hdVtwDDryEGFv(RcrPgjptl(wf6Hlv1h8Y21uNmssaBjb5bwxjeYmHuLjowcaZv2R8LvOInNADIFgTbzdEx)S92SuGd5sOTRKsYw7quOjKbvYcWYbsT78t4GK4xRsJwU7tHURDOLzj3shy029zWP0kWzEyM1KHhZKADMAukQpz88GYYmOSQ0UuseWybiTPUxX0szUylEXWXkFJe)m12LqGgcH6WAtnlZIFrAuctnkkthP0GM0k8dWqWsfTEry9FR7TaHWV6qJvag9V(d)JV8PV8x)4H5hM)lOXz)nyOx5NJYBeSP(Mst2EyqjOYuNS0Ono0uhX6Ltyxy6NHvBqw)JyY2cHzN(ySNGbV1lHPyUV(JSCZ9ZzohM75dcA(yzfbbBg7qVHx9Fl4WF)XFBqj4SoVG72Zf4o85gyHY5b)K4IVPkq7F7nmSK)Rk8)7nsuRmuWT30cLUeivFJoyyDwWezOCmyYTNfmrgkTftS4GXeag)dWn8DieG4j(4VHRGem07(SELwXTuK1w3ifnRozXXjhjYWdJ7oxiZDNbK5DhjmULdgVxcg5X9ucHIpRdhU)iXbEy8HZamgp64acgg1F5V9ZTxvd)nfOBQzo1TunIA53(3UHvVgcIDLYonXzbXGJfi87jglVPOTaratKLQpoMI15X4KLSYVJemNNv6BpvIQXTcLNxx32mutlsxrSZeyAM(QfcChju5vGc)2hZP6VkQGFRgfk7JrXGTu8(w8VFJK2r6jSmlVReKogYPtqSJ3PJKZXPbs2AMAG1APX6gh)eLYqOmEuXr9DyoTlScphIvklDnM3b8eZJw6JNnXF4pKxzaYDAy8bTVBdJJwxhhgFwvxhg)uTopC(x(VQDF4C07m0bIlGKUUqC(ZpxDI4CWDw6gX5WQZDKy537vOReNpfTUZetLkHnpNNI(4WNZ)8Ws7Axn9TILBY1(lNIjFD2OExuwgiQFXQAbr9Zls0X1yoOM2qfE0gqORso0qxLYsQFo)PTJuTQA5y24EAQHJhMA1kuw9bJP(vlR1beDOP1JT5)H761hvqSFp7TKkkIPJgOzbQ6qKRdXlAeKOWQkWwKsEgfwlT9xhTDkewZ10dtE6yRtcqoEE5akhpR3WK4leoQ0llutfdKzq68IpgBNBCOJ2(V15bBYRuT2q)73)AIsjzluYGKoZwEU0vfJuxDqEk4dOxRqsCuBbuzNvrsuw9UmX3v(qRfbrdLAuV(nxCrx1qbfDLHIjA24b1SO0Yo3vjTpTQZDv(DaxqSPDX)KIM0f)3X3uUQGSiNu8OWf5JDSDbGBlUO0t3AnOJ977i8M1C)JINApg6shCrsPVjsPHY7AqVosRp0mojSVQT7MgHuI(Qisl7J)CGfHOMIOGU4RTOs6DrvFu6iMZXwna(sOZCNs11N8iM2rTEw1mP9u6Td4ZxQMUb1VpyP2oxvVZjE26wtfsp6lpjzTHSpsRhHCxGZtjrZJepPs6oDdCpT7DgSFFF9VMXQURx)lmy(y)E6ll1nPgmGNEkVZ7uxQbLs9eAkupyDjqATGbW0yWUPMtht9RrQFq1dnz9q9QgPrylFkFcZsPQ1697P97nP3T8z16RtO5f5E5epwYA6qnTCRr72d5E(r5gZQXn4WlXgTKw4D79NG8ZGM5(8h8HOlbmr5I2jeJFuznRnTvhDe1SpG0K2nmQ2kviV(UlZzW1jnHsW1OQHUAZDMLvZZMbzL(64dwJU5Ul7itvGWv02GkJDoNyq6u7cXDA1vWwkkkbNzJVQ)4lBWv3bQTIn9D9Ap(arwJJvxFyjxLN0uCz)Xxn5Y(A65kZSgmy2uTGD3y9kmLycwNdcKB5wb6uPXxxlpz)E9T7KwtjN0Y5v9VT8DrFqLAsmd6c34FlxUpNmGVBId1sarPhbOHP8UhZd3oI)DKtjHYxX6EfVIOgvLV3ybLpI(tkMFSPcJuBA0E4UEnhVoBTPPgkZdcZiEFnXPI)EAIrTFo60lTLhmB6T96RXV897178z7HFEUvLBXl9AXLRDMvHz5opDY7USQh8rXKmA4Dxv2ttkZsL5EOIwO9WXaTR6pA2FQ)T3urhdgCzXRQQZRCKUjEJcU5r488fY9AfQu73X(EIW22OYljpf3AW6JOh5IhnGbxT64PgCRPP5iD620tlN1)a9KmBvx4OJnHKAoXxOOSopGE7R7XPaDIwdvwJO48P2rrEvqUhgBDAWTVgXJzwvjNxNtsVccqAjgvT(djkP)74voPs3eFQ8NPt74n5VOHMCqXqQoPk(Noq3wUzC5T)OwSCK8KvJoMUR6S0K(VtnmJ2B68w9BtbpQtn2Wm4sUUb7597FxxKJgCvZYldQ5rLqRSGzXIZdlnMgPRsFh7FfDwyv13Z84y8v5M1VuZEdnE5INru(dgkCRcMkFE8I)YgRIbxk4GOqr6xFq6xK3)4D30V0JUl1QfBGg06QAN6U8VRWDatUcWKthdQ9leSEmOFnuyWvJTAcnQqez1ktloNgCkpTJkQ5JNP2SxOumF(nKov(irvo)AtJ1dwJ2VxNgPB5RgIgWUlmYEmG7dAg5VqF6g1H6JV3iMlD6eQ2THxLGCXP1G0x66HBDtBWd2sYu63J3EgsykNbsWLLJGuN0WQ0RnTk97eRbA93lYZu6DRKArbqXFeD3VV6XY)GM27cDmGbdmiWEQKIbkr1XnX5XGQF5BFO0pq9)Q3cutJ)A3QCnVyoUVZ1eWdnP4PQE0eumwBnIARw5pATxZxOJtvpooV5vQ9t43cwbeP25wDSQ)RnfxOFomcjFv)MYIaSnkMMoI3izzVrqYfMA)O7Z)s4PWoT6(Hk(aa)QUuO1Eu5nbT2tkV(NcZe94oN2slNuEAd2FKHnmZcjAtXZRLWwfJrobTQgIH0LAUB80mWmRzVCAmNYvworMOy2QJv8ls1VSesctYxNDtVAnpgR3ba60RR9g)3jOy4(93j4CsCc6sz(T6VtVOYBQpk2WuouecVqH81mu1EB97eueUP(D6nnEP8Bas5XNWCOO6QSi0QrAfeSeGGvxGGsfELruwSJMR6jZ46Ti5vOZ376GzqDmTUyQU(TeLvXaV5260johTykAJjC9tU6AxxFKSCvTGEOk0FMmRt)uqE(w0KEm(9kHK603v6cbco5CEfvRVoPn5X5z2(1Rhm1bAsijgTGRQUvkvFvKFlSsWYRysTEPEhheT4HO1jbrrsxt3nsRS1Sj3XLKI2nJQxKQRvLsJkZwzp14ILGZW5JNEwktf8kuGAKp0J7udbvEoAeoV)M(m4CgUBad61VfPx(iNttxTJgrS8Zix15kRHZy(mHvNAB5vcvfqH20On(UoWvAlNUlWSvC6xxoj6KqhliU2L1hPfMgQyWAhW4XWf1jk2K0IiSnOCrx9GOVekAnrmOkxq6Uxsm5a5FC)hWshwrq)f15zhqYhAns2iNoF2LXXEIF5RY8s9gS(L(QO8aQ)KZpwmG2eRE6)p]] )


end
