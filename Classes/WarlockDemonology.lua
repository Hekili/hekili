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
            state:QueueAuraExpiration( "dreadstalkers", ExpireDreadstalkers, 1 + buff.dreadstalkers.expires )
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


    spec:RegisterPack( "Demonology", 20220428, [[dafUpcqikrEekLCjvjLSjjLpjjmkIsNIsyvOuQxrumluKBPkr7sIFjj1WKe1XqPAzsQ8mvjzAQs4AsISnjvX3OefJtvQY5OevTovPY7KuLIMNQuUhr1(uk6FsQsHdQkPyHkfEikfMOQKQlsjQyJuIsYhPevAKsQsjNusvYkvkntuk6MsQsP2jLQ(jLOedvvsPwkLOupfstLsLRsjkP2QKQu1xvLQQXkPQ2lv(lHbd6Wclwv9ykMmvDzKntKpJsgnLYPf9AuWSr1TvYUL63kgUs1XvLQYYbEoutN01Hy7QIVJIA8OqNNsA9sQsL5ljz)QSJDNDouFOKZ(6QCD1v5xu37vQRU6S8vQECOQ1DYHUhggcwKdTJf5qFDAn9WhwwDO7Hv(eENDou8GamKdfnxSHd9JKCTE1UVd1hk5SVUkxxDv(f19EL6QRol)lSmou8ozC2xx9upouBP3tT77q9e24qFDAn9Whwwp47pa8XWWT1MQ743vD1Ss1gYVyMv14CHWdnN2acjTACUmvFBFn7GKFW6EpMoyDvUU6UT3w2Ww0Si87UTV8GO7eNFq2CmmuUTV8GwwAU1dciZSwu7p4RtRP)dxp4oGEPzw)qpykDWupyIpy2ynA9GYoGdAlaEtG1dknGd(hmMWwuV5b9txHEW5HaMy)GyBbWJpykDqRdsfa6GHEWkDWSpOAJo4Stnbk32xEWx7HzcCq0C320hm48HzYFWDa9sZS(HEqDo4oymhmBSgTEWxNwt)hUwUTV8GV2pV2hudo16bZwjaazxl32xEWxZZK(dIUXl3SERXY9G49yDqMTr9bToivaOd2JEW4pi6b15GyK1A6dgh0oRGO1YT9Lh0YkoHTzaHKwD9(HhAYPdIo8hQ1dAI2qCrkDqJTOzr(dQZbZwjaazxfPu52(YdAhW6b15GXZK(dYCG1SzDWxNwtNMdYgdGoiwddd4YT9Lh0oG1dQZbxbd0bNDQjWb3b5as16bNMB9GmpagoykDqMPdAI(GHrrco36bNDQpiZPA7GXbTZkiATCBF5bRxRDW8qh0mR9qZFYt16bzovBhSEBzo4hj5ECXHYtSID25qX8HzHcYMbsXo7C2ZUZohk1XNtE3go0owKdfpiCoPA2SeaKVvhQXQHtcnaSif7SNDhAy0CAhkEq4Cs1SzjaiFRoudivcKHd9jaz85u5JijjWwBJW4p4Bhudalsl(eRrBOdw9bR0bF5bL9G1Dq2(GSm(Yky8GS9bFcqgFovqWK4pCvO5kBw4dAHtD2xNZohk1XNtE3go0WO50oums)5Z4fXIuBwXQd1asLaz4qFcqgFov(isscS12im(d(2b1aWI0IpXA0g6GvFWkDqzoOShSUdY2h8jaz85ubbtI)WvHMRSzHpOfo0owKdfJ0F(mErSi1MvS6uN9VYzNdL64ZjVBdhAy0CAhkT2TcOGlgGVJ2qoudivcKHd9jaz85u5JijjWwBJW4p4Bhu2dQbGfPfFI1On0bR(Gv6GwCqzoi71DqzoOShSUdY2h8jaz85ubbtI)WvHMRSzHpOfo0owKdLw7wbuWfdW3rBiN6uhQTDHcYMbSZoN9S7SZHsD85K3THdTJf5qXzlHWfS4HpdDaybT(CA5qdJMt7qXzlHWfS4HpdDaybT(CA5uN915SZHsD85K3THdTJf5qXzlHWfbEpbrRybT(CA5qdJMt7qXzlHWfbEpbrRybT(CA5uN6qnZd1rRI4N8uT6SZzp7o7COuhFo5DB4qnGujqgouzpiEq4)S9fPK4EXij(8bJNfUqD85K)Gvv1bbinjnawuXtMWA2Se4bHlWHASr8c1XNt(dAXbRDWDslEAnDAeQvq0AjmA(qo0WO50ou8GWfGrDQZ(6C25qPo(CY72WHAaPsGmCO4bH)Z2xybMhsK9tYAaHMtxOo(CYFWAh0sheG0K0ayrfpzcRzZsGheUahQXgXluhFo5pyTdk7bFcqgFovAIrvOwbrRcJ)GVDW6Q8bRQQd(eGm(CQ0eJQqTcIwfg)b38GVQYh0chAy0CAhkEq4cWOo1z)RC25qPo(CY72WHAaPsGmCO4bH)Z2xyo5EHnKwfAy00GluhFo5pyTdAPdcqAsAaSOINmH1SzjWdcxGd1yJ4fQJpN8hS2bT0b3jT4P10PrOwbrRLWO5dDWAh8jaz85uPjgvHAfeTkm(dU5bz)9COHrZPDO4bHlaJ6uN9VWzNdL64ZjVBdhAy0CAhQNm5k0Szj(dxDOgqQeidhQLo4taY4ZPccMe)HRcnxzZcFWAhepi8F2(cNcV4BvqmgRDovOo(CYFWAhu2dUtAXtRPtJqTcIwlHrZh6G1oiEq4cSTa4p4BhSUdwvvh0shCN0INwtNgHAfeTwcJMp0bRDWNaKXNtLMyufQvq0QW4p4Mh8fv(Gw4qnwnCsObGfPyN9S7uN9vYzNdL64ZjVBdhAy0CAhQNm5k0Szj(dxDOgqQeidhQLo4taY4ZPccMe)HRcnxzZcFWAhepi8F2(cd0t2yXm17iE2SkuhFo5pyTdk7b3jT4P10PrOwbrRLWO5dDWQQ6Gw6G7Kw80A60iuRGO1sy08HoyTd(eGm(CQ0eJQqTcIwfg)b38GVOYh0chQXQHtcnaSif7SNDN6SVEC25qPo(CY72WHggnN2H6jtUcnBwI)WvhQbKkbYWHAPd(eGm(CQGGjXF4QqZv2SWhS2bL9G4bH)Z2xKgal6pGMea6HajHluhFo5pyvvDqzpiEq4)S9LNHhAYjbE4puRfQJpN8hS2bT0bXdc)NTVWa9Knwmt9oINnRc1XNt(dAXbT4G1oOLo4oPfpTMonc1kiATegnFihQXQHtcnaSif7SNDN6S3Y4SZHsD85K3THdnmAoTd1tMCfA2Se)HRoudivcKHd9jaz85ubbtI)WvHMRSzHpyTdk7bT0b1GtTw2hMjGaN72MUqD85K)Gvv1bnZW9dZDzFyMacCUBB6cGwr24d(2bdJMtx8KjxHMnlXF4AHyKmikj0Crh0Idw7Gw6GMz4(H5UGrwRPfEAnDAeQvq0Abz)G1oOShCN0INwtNgHAfeTwa0kYgFW3o47DWQQ6GMz4(H5UGrwRPfEAnDAeQvq0AbqRiBSGyCNmk5p4Bh8vv(Gw4qnwnCsObGfPyN9S7uN9VNZohk1XNtE3go0WO50oujoHTzaHK6qnGujqgou8GW)z7lpdp0Ktc8WFOwluhFo5pyTd(rKKkpdp0Ktc8WFOwl(H52HMTsaaYUksjh6hrsQ8m8qtojWd)HATGS7uN9wENDouQJpN8UnCOgqQeidhkEq4)S9fZS(HkwKp1qZPluhFo5pyTdUtAXtRPtJqTcIwlHrZhYHggnN2HIndciBwcnvBKtD2ZELD25qPo(CY72WHAaPsGmCOw6G4bH)Z2xmZ6hQyr(udnNUqD85K3HggnN2HIndciBwcnvBKtD2Zo7o7COuhFo5DB4qnGujqgo0DslEAnDAeQvq0AjmA(qhS2bXdcxGTfa)bLFWk7qdJMt7qZ1o1(SzjmHgyfm72iN6uhQAfeTkWKIS7SZzp7o7COuhFo5DB4qnGujqgo0NaKXNtLMyufQvq0QW4p4BhK9k5qdJMt7qBsTraX(a0G7uN915SZHsD85K3THd1asLaz4qFcqgFovAIrvOwbrRcJ)GVDq2Tmh8Lhu2dggnNUGrwRPfEAnDAeQvq0AHyKmikj0CrhuMdggnNUGTf(HzXF4AHyKmikj0Crh0Idw7GYEqZmC)WCxmbNl8ak8yn4mqaCbqRiB8bF7GSBzo4lpOShmmAoDbJSwtl80A60iuRGO1cXizqusO5IoOmhmmAoDbJSwtlEsojLu7leJKbrjHMl6GYCWWO50fSTWpml(dxleJKbrjHMl6GwCWQQ6G7Kw8ak8yn4mqGcGwr24dU5bFcqgFovAIrvOwbrRcJ)GYCWWO50fmYAnTWtRPtJqTcIwleJKbrjHMl6Gw4qdJMt7qzbY1KasirCwibW7uN9VYzNdL64ZjVBdhQbKkbYWHk7bFcqgFovAIrvOwbrRcJ)GVDq2R0bF5bL9GHrZPlyK1AAHNwtNgHAfeTwigjdIscnx0bT4G1oOSh0md3pm3ftW5cpGcpwdodeaxa0kYgFW3oi7v6GV8GYEWWO50fmYAnTWtRPtJqTcIwleJKbrjHMl6GYCWWO50fmYAnT4j5KusTVqmsgeLeAUOdAXbRQQdUtAXdOWJ1GZabkaAfzJp4Mh8jaz85uPjgvHAfeTkm(dkZbdJMtxWiR10cpTMonc1kiATqmsgeLeAUOdAXbT4Gvv1bL9Gw6GaKMKgalQWCYLaKhlWjRKlgjbgzNa5aeyK1A6SzvOo(CYFWAh8jaz85uPjgvHAfeTkm(dU5bFrLpOfo0WO50oumYAnT4j5KusT3Po7FHZohk1XNtE3goudivcKHd9jaz85uPjgvHAfeTkm(d(2bzVUd(Ydk7bdJMtxWiR10cpTMonc1kiATqmsgeLeAUOdkZbdJMtxW2c)WS4pCTqmsgeLeAUOdAHdnmAoTd1eCUWdOWJ1GZabWo1zFLC25qPo(CY72WHAaPsGmCOAUOdU5bLsawfQvq0QqZfDWAhu2dUtAXdOWJ1GZabkHrZh6G1o4oPfpGcpwdodeOaOvKn(GBEWWO50fmYAnTWtRPtJqTcIwleJKbrjHMl6GwCWAhu2dAPdQbNATGrwRPfpjNKsQ9fQJpN8hSQQo4oPLNKtsj1(sy08HoOfhS2bL9G4bHlW2cG)GYpyLpyvvDqzp4oPfpGcpwdodeOegnFOdw7G7Kw8ak8yn4mqGcGwr24d(2bdJMtxWiR10cpTMonc1kiATqmsgeLeAUOdkZbdJMtxW2c)WS4pCTqmsgeLeAUOdAXbRQQdk7b3jT8KCskP2xcJMp0bRDWDslpjNKsQ9faTISXh8TdggnNUGrwRPfEAnDAeQvq0AHyKmikj0CrhuMdggnNUGTf(HzXF4AHyKmikj0Crh0Idwvvhu2d(rKKkSa5AsajKiolKa4li7hS2b)issfwGCnjGeseNfsa8faTISXh8TdggnNUGrwRPfEAnDAeQvq0AHyKmikj0CrhuMdggnNUGTf(HzXF4AHyKmikj0Crh0IdAHdnmAoTdfJSwtl80A60iuRGOvN6uhQNKceU6SZzp7o7COuhFo5DB4q9e2aYDnN2HA5WizquYFq6HawpOMl6GQn6GHrhWbt8bJNi5XNtfhAy0CAhkEN4CbFmm4uN915SZHggnN2HAcoxirCBiTsahk1XNtE3go1z)RC25qdJMt7qdgjHoySdL64ZjVBdN6S)fo7COHrZPDOE6zqaIvWknouQJpN8UnCQZ(k5SZHsD85K3THdD2DOysDOHrZPDOpbiJpNCOpbhHCOMz4(H5UGrwRPfEAnDAeQvq0AbqRiBSGyCNmk5DOgqQeidhQLoiEq4)S9fPK4EXij(8bJNfUqD85K)Gvv1bnZW9dZDbJSwtl80A60iuRGO1cGwr2ybX4ozuYFWnpOzgUFyUl4bHlaJwa0kYglig3jJsEh6taeDSihAtmQc1kiAvy8o1zF94SZHsD85K3THdD2DOysDOHrZPDOpbiJpNCOpbhHCOMz4(H5UGheUamAbqRiBSGyCNmk5DOgqQeidhkEq4)S9fPK4EXij(8bJNfUqD85K)G1oOzgUFyUlyK1AAHNwtNgHAfeTwa0kYglig3jJs(d(2bnZW9dZDbpiCby0cGwr2ybX4ozuY7qFcGOJf5qBIrvOwbrRcJ3Po7Tmo7COuhFo5DB4qNDhkMuhAy0CAh6taY4Zjh6tWrih6taY4ZPstmQc1kiAvy8oudivcKHd1sh8jaz85ubbtI)WvHMRSzHpyTdAPdMTy2PMao0Nai6yro0pIKKaBTncJ3Po7FpNDouQJpN8UnCOZUdftQdnmAoTd9jaz85Kd9j4iKdL96COgqQeidhQLo4taY4ZPccMe)HRcnxzZcFWAhmBXStnboyTdAPdUtAXdOWJ1GZabkHrZhYH(earhlYH(rKKeyRTry8o1zVL3zNdL64ZjVBdh6S7qXK6qdJMt7qFcqgFo5qFcoc5qRSd1asLaz4qT0bFcqgFovqWK4pCvO5kBw4dw7GzlMDQjWbRDWDslEafESgCgiqjmA(qhS2b)issfMtUxKRDCbRHHHdU5bR8bRDqlDqn4uRLNKtsj1(c1XNtEh6taeDSih6hrssGT2gHX7uN9SxzNDouQJpN8UnCOZUdftQdnmAoTd9jaz85Kd9j4iKdTYoudivcKHd1sh8jaz85ubbtI)WvHMRSzHpyTdMTy2PMahS2b3jT4bu4XAWzGaLWO5dDWAhChqpcwgFH9ITO9IrsWcH7J(G1oOgCQ1YtYjPKAFH64ZjVd9jaIowKd9JijjWwBJW4DQZE2z3zNdL64ZjVBdh6S7qXK6qdJMt7qFcqgFo5qFcoc5qnZW9dZDXtMCfA2Se)HRfaTISXcIXDYOK3HAaPsGmCOpbiJpNkiys8hUk0CLnlSd9jaIowKd9JijjWwBJW4DQZE2RZzNdL64ZjVBdhAy0CAhQj4Cry0CAbpXQdLNyv0XICOkiBgif7uN9S)kNDouQJpN8UnCOgqQeidhQSh0sh8jaz85ubbtI)WvHMRSzHpyTdUtAXtRPtJqTcIwlHrZh6GwCWQQ6GYEWNaKXNtfemj(dxfAUYMf(G1o4hrsQGTfaVyKer3PTKhAoDbz)G1oOSh0shudo1AzFyMacCUBB6c1XNt(dwvvh8Jijv2hMjGaN72MUGSFqloOfo0WO50outW5IWO50cEIvhkpXQOJf5qhwgVtD2Z(lC25qPo(CY72WHAaPsGmCO)bJpyTdkLSSPcaTISXh8Tdw3bz7dYY4DOHrZPDO5ANp4CAN6SN9k5SZHsD85K3THd1asLaz4q1HflovmZW9dZn(G1oOMl6GVDqPeGvHAfeTk0CrouScsJ6SNDhAy0CAhQj4Cry0CAbpXQdLNyv0XICOZo1eWPo7zVEC25qPo(CY72WHAaPsGmCO4bH)Z2xybMhsK9tYAaHMtxOo(CYFWQQ6G4bH)Z2xKsI7fJK4ZhmEw4c1XNt(dwvvhepi8F2(Izw)qflYNAO50fQJpN8hSQQoOzEOoAT0Kbm8b4DOyfKg1zp7o0WO50outW5IWO50cEIvhkpXQOJf5qnZd1rRI4N8uT6uN9SBzC25qPo(CY72WHAaPsGmCOYEqlDWNaKXNtfemj(dxfAUYMf(G1o4taY4ZPstmQc1kiAvy8h8TdYY4lRGXdw7GAUOdU5bLsawfQvq0QqZfDWQQ6G4bH)Z2xaKu2KxSh8qPc1XNt(dw7GpbiJpNknXOkuRGOvHXFW3o4REVdAXbRQQdk7bFcqgFovqWK4pCvO5kBw4dw7GFejPc2wa8IrseDN2sEO50fK9dAHdnmAoTdDF0CAN6SN93ZzNdL64ZjVBdhAy0CAhQj4Cry0CAbpXQdLNyv0XICOQvq0QatkYUtD2ZUL3zNdL64ZjVBdhQbKkbYWHk7bT0bbinjnawuH5KlbipwGtwjxmscmYobYbiWiR10zZQqD85K)G1o4taY4ZPstmQc1kiAvy8hCZdA5pOfhSQQoOShCN0INwtNgHAfeTwcJMp0bRDWDslEAnDAeQvq0AbqRiB8bF7G1Zbz7dYY4lRGXdAHdnmAoTd1tRPtJaRaQzP2CQZ(6QSZohk1XNtE3goudivcKHd9jaz85ubbtI)WvHMRSzHpyTdAMH7hM7cgzTMw4P10PrOwbrRfaTISXcIXDYOK)GBEW6QZHggnN2HAcox4bu4XAWzGayN6SVo2D25qPo(CY72WHAaPsGmCOw6GpbiJpNkiys8hUk0CLnl8bRDqzp4taY4ZPstmQc1kiAvy8hCZdwxLp4lpyLoiBFqlDqastsdGfvyo5saYJf4KvYfJKaJStGCacmYAnD2SkuhFo5pOfo0WO50outW5cpGcpwdodea7uN91vNZohk1XNtE3goudivcKHd9JijvuRGO1IFyUpyTd(eGm(CQ0eJQqTcIwfg)b38GvYHggnN2H(toHndcGfj(Z6taStD2x3RC25qPo(CY72WHAaPsGmCOHrZhsqnTscFWnpi7huMdk7bz)GS9b1GtTwWHbKsPH8c8GWXfQJpN8h0Idw7GFejPcZj3lY1oUG1WWWb3u(bRNdw7GFejPIAfeTw8dZ9bRDWNaKXNtLMyufQvq0QW4p4MhSshS2bL9GFejPsU25doFiX(OuRzWl(H5(Gvv1b)issfMtUxKRDCbRHHHdY2hu2dY(bL5GV4GS9bL9G4DIZfAayrkUKRD(GZPp4MhSUdAXbT4GBk)GFejPsU25doFiX(OuRzWlpSFqlCOHrZPDO5ANp4CAN6SVUx4SZHsD85K3THd1asLaz4qdJMpKGAALe(GBEW6oyTd(rKKkmNCVix74cwdddhCt5hSEoyTd(rKKkQvq0AXpm3hS2bFcqgFovAIrvOwbrRcJ)GBEWkDWAh0sheG0K0ayrLCTZhC(qI9rPwZGxOo(CYFWAhu2dAPdQbNATibMLqTrcSTWpmJluhFo5pyvvDqp9rKKksGzjuBKaBl8dZ4cY(bTWHggnN2HMRD(GZPDQZ(6QKZohk1XNtE3goudivcKHdnmA(qcQPvs4dU5bz)GYCqzpi7hKTpOgCQ1comGuknKxGheoUqD85K)GwCWAh8Jijvyo5ErU2XfSgggo4MYpy9CqzoOSh8vhKTpOgCQ1cEq4cZ0EKuluhFo5pOfhS2b)issf1kiAT4hM7dw7GpbiJpNknXOkuRGOvHXFWnpyLoyTdk7b)issLCTZhC(qI9rPwZGx8dZ9bRQQd(rKKkmNCVix74cwdddhKTpOShK9dkZbFXbz7dk7bX7eNl0aWIuCjx78bNtFWnpyDh0IdAXb3u(b)issLCTZhC(qI9rPwZGxEy)Gw4qdJMt7qZ1oFW50o1zFD1JZohk1XNtE3goudivcKHdnmA(qcQPvs4dU5bR7G1o4hrsQWCY9ICTJlynmmCWnLFW65GYCqzp4RoiBFqn4uRf8GWfMP9iPwOo(CYFqloyTd(rKKkQvq0AXpm3hS2bFcqgFovAIrvOwbrRcJ)GBEWkDWAh0sheG0K0ayrLCTZhC(qI9rPwZGxOo(CYFWAhu2dAPdQbNATibMLqTrcSTWpmJluhFo5pyvvDqp9rKKksGzjuBKaBl8dZ4cY(bTWHggnN2HMRD(GZPDQZ(6Smo7COuhFo5DB4qnGujqgo0)GXhS2b1CrcDe(Ko4Bh8vv2HggnN2HYcKRjbKqI4SqcG3Po7R79C25qPo(CY72WHAaPsGmCO)bJpyTdQ5Ie6i8jDW3oyDVNdnmAoTdfJSwtlEsojLu7DQZ(6S8o7COuhFo5DB4qnGujqgo0)GXhS2b1CrcDe(Ko4BhK9k5qdJMt7qXiR10cpTMonc1kiA1Po7FvLD25qPo(CY72WHAaPsGmCO4bHlW2cG)GYpyLCOHrZPDO2I2lgjbleUpAN6S)vS7SZHsD85K3THd1asLaz4qXdcxGTfa)bF7Gv6G1oiaPjPbWIk)Gt490taS4Ja6SzjmdGkuhFo5pyTd(rKKk)Gt490taS4Ja6SzjmdGkaAfzJp4BhSso0WO50ouSTWpml(dxDQZ(xvNZohk1XNtE3goudivcKHdfqsacBl(CYHggnN2H6Nz5uN9V6vo7COuhFo5DB4qdJMt7qTfTxmscwiCF0oupHnGCxZPDO1lPd(6ak8yn4mqa8bdaDWGdOWB9GHrZhIPd2ZbBI8huNdIJh6GyBbWJDOgqQeidhkEq4cSTa4p4MYp4RoyTdk7b3jT4bu4XAWzGaLWO5dDWQQ6G7Kw80A60iuRGO1sy08HoOfo1z)REHZohk1XNtE3goudivcKHdfpiCb2wa8hCt5hK9dw7GFejPstQnci2hGg8cY(bRDqZmC)WCxmbNl8ak8yn4mqaCbqRiB8b38G1Dq2(GSm(Yky0HggnN2HAlAVyKeSq4(ODQZ(xvjNDouQJpN8UnCOgqQeidhkEq4cSTa4p4MYpi7hS2b)issfMtUxKRDCbRHHHdU5bR7G1o4oPfpGcpwdodeOaOvKn(GBEWkxQ0bL5GMaRcnx0bL5GHrZPlyK1AAHNwtNgHAfeTwmbwfAUOdw7G7Kw8ak8yn4mqGcGwr24d(2bRCPshuMdAcSk0CrhuMdggnNUGrwRPfEAnDAeQvq0AXeyvO5IoOmhu2dw5dUz9ghu2d(Qd(YdIheUaBla(dAXbT4GS9bdJMtxW2c)WS4pCTycSk0CrhS2bFcqgFovAIrvOwbrRcJ)GVDqwgFzfmEWAhuZfDWnpOucWQqTcIwfAUOd(YdYY4lRGrhAy0CAhQTO9IrsWcH7J2Po7Fv94SZHsD85K3THd1asLaz4qT0bnZd1rRLhQvBwbouScsJ6SNDhAy0CAhQj4Cry0CAbpXQdLNyv0XICOM5H6Ovr8tEQwDQZ(xzzC25qPo(CY72WHggnN2HIheUaRGKbYH6jSbK7AoTd99NQTbrpiAyaPuAi)brheoMPdIoi8dIQGKb6Gj(GyfmnlcCq1w0h81P10)HRmDq8CWupOTaFW4G2sw2iWb3b5as1Qd1asLaz4qT0b1GtTwWHbKsPH8c8GWXfQJpN8o1z)REpNDouQJpN8UnCOgqQeidhQLo4taY4ZPccMe)HRcnxzZcFWAh8Jijvyo5ErU2XfSgggo4MhK9dw7GFejPINwtNgHzaubRHHHd(2bFLdnmAoTdDFyMacCUBBAN6S)vwENDouQJpN8UnCOgqQeidh6taY4ZPccMe)HRcnxzZcFWAh8JijvW2cGxmsIO70wYdnNUGSFWAh8JijvW2cGxmsIO70wYdnNUG1WWWbF7GVYHggnN2HUpmtabo3TnTtD2)Ik7SZHsD85K3THdnmAoTd1tRP)dxDOEcBa5UMt7qr3P2FWxNwtNMdYgdGWhuAaheDq4he1wa84dI0AYpODwbrRh0md3pm3hmXh0WhmDqDoiGcVvhQbKkbYWH(rKKkEAnDAeMbqfafg9G1oiEq4cSTa4p4Bh8fhS2bFcqgFovAIrvOwbrRcJ)GBEW6QStD2)c2D25qPo(CY72WHggnN2H6P10)HRoupHnGCxZPDOVociBwh0oRGO1dIjfzNPdI3P2FWxNwtNMdYgdGWhuAaheDq4he1wa8yhQbKkbYWH(rKKkEAnDAeMbqfafg9G1oiEq4cSTa4p4Bh8fhS2bFcqgFovAIrvOwbrRcJ)GVDq2RZPo7FrDo7COuhFo5DB4qnGujqgo0pIKuXtRPtJWmaQaOWOhS2bXdcxGTfa)bF7GV4G1oOSh8Jijv80A60imdGkynmmCWnpyDhSQQoOgCQ1comGuknKxGheoUqD85K)Gw4qdJMt7q90A6)WvN6S)fVYzNdL64ZjVBdhQbKkbYWH(eGm(CQGGjXF4QqZv2SWhS2b)issfSTa4fJKi6oTL8qZPli7o0WO50o09HzciW5UTPDQZ(x8cNDouQJpN8UnCOgqQeidhkMuXFAeCrtcu37jQB3CWAhepiCb2wa8h8Td(Idw7GYEqzpy9CWxEq8GWfyBbWFqloiBFWWO50fSTWpml(dxleJKbrjHMl6GBEWDslEafESgCgiqbqRiB8bF5bdJMtxSfTxmscwiCF0fIrYGOKqZfDWxEWWO50fpTM(pCTqmsgeLeAUOdAXbRDWpIKuXtRPtJWmaQG1WWWb3u(bz3HggnN2H6P10)HRo1z)lQKZohk1XNtE3goudivcKHd9Jijv80A60imdGkakm6bRDq8GWfyBbWFW3o4loyTdggnFib10kj8b38GS7qdJMt7q90A6)WvN6S)f1JZohAy0CAhkEq4cScsgihk1XNtE3go1z)lSmo7COuhFo5DB4qdJMt7qnbNlcJMtl4jwDO8eRIowKd1mpuhTkIFYt1QtD2)I3ZzNdL64ZjVBdhAy0CAhQTO9IrsWcH7J2H6jSbK7AoTdTEjDqRdYbnrFqwKEWFyy4G6CWkDq0bHFquBbWJp4NKgaDWxhqHhRbNbcGpOzgUFyUpyIpiGcVvMoyQvGp4Wqy9G6Cq8o1(dQ2O1b7HzhQbKkbYWHIheUaBla(dUP8d(Qdw7GpbiJpNknXOkuRGOvHXFWnpyDv6G1oOShudo1AXtRPtJWeCE2SkuhFo5pyvvDqZmC)WCxmbNl8ak8yn4mqaCbqRiB8b38GYEqzpyLo4lpiEq4cSTa4pOfhKTpyy0C6c2w4hMf)HRfIrYGOKqZfDqloOmhmmAoDXw0EXijyHW9rxigjdIscnx0bTWPo7FHL3zNdL64ZjVBdhAy0CAhQFMLd1asLaz4qbKeGW2IpNoyTdQ5Io4MhukbyvOwbrRcnxKd1y1WjHgawKID2ZUtD2xPk7SZHsD85K3THdnmAoTd1tRP)dxDOEcBa5UMt7qTSgth81P10)HRhmLoO1bPcaDqwt2SoOohKpy6GVoTMonhKngaDqSgggWmDq6H6dMshm1k8hK5aR0bJdIhe(bX2cGV4qnGujqgo0pIKuXtRPtJWmaQaOWOhS2b)issfpTMoncZaOcGwr24d(2bz)GYCqwgFzfmEq2(GFejPINwtNgHzaubRHHbN6SVsS7SZHggnN2HITf(HzXF4QdL64ZjVBdN6uh6oGmZ6hQZoN9S7SZHsD85K3THdnmAoTdvI4c)SYo0CAhQNWgqUR50oulhgjdIs(d(jPbqh0mRFOh8tSYgxo4RXyODfFWE6xAlalje(bdJMtJp40CRfhQbKkbYWHQ5Io4MhSYhS2bT0b3jTe88HCQZ(6C25qdJMt7qXiR10cjIZcjaEhk1XNtE3go1z)RC25qPo(CY72WH2XICO6SiXijwtJvWGGfMPXkaXO50yhAy0CAhQolsmsI10yfmiyHzAScqmAon2Po7FHZohk1XNtE3go0owKdfpCkSHfyYaivOKXwNVpeYHggnN2HIhof2WcmzaKkuYyRZ3hc5uN9vYzNdnmAoTdvItyBgqiPouQJpN8UnCQZ(6XzNdL64ZjVBdhQbKkbYWH(rKKkmNCVix74cwdddhCZdY(bRDWpIKuXtRPtJWmaQG1WWWbFt(bRZHggnN2HUpmtabo3TnTtD2BzC25qPo(CY72WH2XICOyBHFyM8Ib8fJKqhWIA1HggnN2HITf(HzYlgWxmscDalQvN6S)9C25qPo(CY72WHAaPsGmCO4bHlW2cGhFW3oyLoyTdk7b)dgFWQQ6GHrZPlEAn9F4AXey9GYpyLpOfo0WO50oupTM(pC1Po7T8o7COuhFo5DB4qnGujqgou8GWfyBbWJp4BhSshS2bT0bL9G)bJpyvvDWWO50fpTM(pCTycSEq5hSYh0chAy0CAhk2w4hMf)HRo1zp7v2zNdL64ZjVBdh6S7qXK6qdJMt7qFcqgFo5qFcoc5qbinjnawu5hCcVNEcGfFeqNnlHzauH64Zj)bRDqastsdGfvW2cGxmsIO70wYdnNUqD85K3H(earhlYHIGjXF4QqZv2SWo1Po0zNAc4SZzp7o7COuhFo5DB4qnGujqgou8GW)z7lSaZdjY(jznGqZPluhFo5DOHrZPDO4bHlaJ6uN915SZHggnN2H2KAJaI9bOb3HsD85K3THtD2)kNDo0WO50ouwGCnjGeseNfsa8ouQJpN8UnCQZ(x4SZHggnN2HIrwRPfpjNKsQ9ouQJpN8UnCQZ(k5SZHsD85K3THd1asLaz4qXdcxGTfa)bF7Gv6G1oOzgUFyUlMGZfEafESgCgiaUGS7qdJMt7qX2c)WS4pC1Po7RhNDouQJpN8UnCOgqQeidh6taY4ZPccMe)HRcnxzZcFWAhepiCb2wa8h8TdwPdw7GFejPYp4eEp9eal(iGoBwcZaOcwdddh8Td(chAy0CAhk2w4hMf)HRo1zVLXzNdnmAoTd1eCUWdOWJ1GZabWouQJpN8UnCQtDOkiBgif7SZzp7o7COuhFo5DB4qNDhkMuhAy0CAh6taY4Zjh6tWrihQSh0sh8jaz85ubbtI)WvHMRSzHpyTdUtAXtRPtJqTcIwlHrZh6GwCWQQ6GYEWNaKXNtfemj(dxfAUYMf(G1o4hrsQGTfaVyKer3PTKhAoDbz)Gw4qFcGOJf5qrWK4Jijjuq2mqk2Po7RZzNdL64ZjVBdhAy0CAhk2eaSyKesGqjqhCbwbPe5qnGujqgoulDWpIKubBcawmscjqOeOdUaRGuIeVOGS7q7yrouSjayXijKaHsGo4cScsjYPo7FLZohk1XNtE3go0WO50ouSjayXijKaHsGo4cScsjYHAaPsGmCOFejPc2eaSyKesGqjqhCbwbPejErbz)G1o4oPfpTMonc1kiATegnFihAhlYHInbalgjHeiuc0bxGvqkro1z)lC25qPo(CY72WHggnN2HITf(HzYlgWxmscDalQvhQbKkbYWH(eGm(CQ8rKKeyRTry8h8TdwxDo0owKdfBl8dZKxmGVyKe6awuRo1zFLC25qPo(CY72WHggnN2HUMP5Pk2bjE5qnGujqgo0NaKXNtfemj(dxfAUYMf(G1o4oPfpTMonc1kiATegnFihAhlYHUMP5Pk2bjE5uN91JZohk1XNtE3go0WO50ouwGCjidp3XKd1asLaz4qFcqgFov(isscS12im(d(2bTmo0owKdLfixcYWZDm5uN9wgNDouQJpN8UnCOgqQeidhQgCQ1INwtNgHzAmYAxZPluhFo5pyTd(eGm(CQ0eJQqTcIwfg)bF7G1vzhAy0CAhQj4Cry0CAbpXQdLNyv0XICO22fkiBgWo1z)75SZHsD85K3THd1tydi31CAhQLJKezu8bvBHEqfepe)Gy(Wm36bLaZ6GQn6GAayr6bb07djb0bdVp1C6GZ0bX0EacLoOTO98Sz5qdJMt7qnbNlcJMtl4jwDO8eRIowKdfZhMfkiBgif7uN9wENDouQJpN8UnCOHrZPDOZdbK4dZzZseDUcHjyroudivcKHd9jaz85ubbtIpIKKqbzZaPyhAhlYHopeqIpmNnlr05keMGf5uN9SxzNDouQJpN8UnCOHrZPDOkiBgiLDhQbKkbYWHQGSzG0IYEXwGfiys8rKKoyTd(eGm(CQGGjXhrssOGSzGuSdfZh1HQGSzGu2DQZE2z3zNdL64ZjVBdhAy0CAhQcYMbsRZHAaPsGmCOkiBgiTO1vSfybcMeFejPdw7GpbiJpNkiys8rKKekiBgif7qX8rDOkiBgiToN6SN96C25qPo(CY72WHAaPsGmCOAUOdU5bLsawfQvq0QqZfDWAh8jaz85u5JijjWwBJW4p4MhSUk7qdJMt7qnbNlcJMtl4jwDO8eRIowKdDhbqcFScwKqbzZa2Po1HUJaiHpwblsOGSza7SZzp7o7COuhFo5DB4q7yroupGcVuciXdHXe3HggnN2H6bu4LsajEimM4o1zFDo7COuhFo5DB4q7yrouaHNoAvaimbEMe4qdJMt7qbeE6OvbGWe4zsGtD2)kNDouQJpN8UnCODSihAam2sLmkwKnlQrs1QWmaYHggnN2HgaJTujJIfzZIAKuTkmdGCQZ(x4SZHsD85K3THdTJf5qndELgblE4Zqhawai80HoahAy0CAhQzWR0iyXdFg6aWcaHNo0b4uN9vYzNdL64ZjVBdhAhlYH6bu4LsajEimM4o0WO50oupGcVuciXdHXe3Po7RhNDouQJpN8UnCODSihkEq4IKvNkbCOHrZPDO4bHlswDQeWPo7Tmo7COuhFo5DB4qdJMt7qzXTUBtmsIaJZvYdnN2HAaPsGmCOHrZhsqnTscFq5hKDhAhlYHYIBD3MyKebgNRKhAoTtD2)Eo7COuhFo5DB4q7yrouFayyntl8KHbXoIciSHAd5qdJMt7q9bGH1mTWtgge7ikGWgQnKtD2B5D25qPo(CY72WH2XICO0FA8GWfpjMCOHrZPDO0FA8GWfpjMCQZE2RSZohk1XNtE3go0owKdfPn2ISjVGfp8zOdalW2cddCc7qdJMt7qrAJTiBYlyXdFg6aWcSTWWaNWo1Po0HLX7SZzp7o7COHrZPDOFcGjadzZYHsD85K3THtD2xNZohAy0CAh6NpJxiHaS6qPo(CY72WPo7FLZohAy0CAhQucOpFgVdL64ZjVBdN6S)fo7COHrZPDOiysKkTWouQJpN8UnCQtDQd9Ha4CAN91v56QRYVG96XHYCa6SzHDOV)xJLT91l7TCF3bpOD2OdMR9bOhuAahScmFywOGSzGuCfheqVpKeq(dINfDWarNvOK)GgBrZIWLBlBMnDq2F3bzJPFiGs(dIMl24GyRTgmEWxRdQZbztK4G(8jX50hC2jqOd4GYwTfhuw2z0IYTLnZMoyDV7GSX0peqj)brZfBCqS1wdgp4R1b15GSjsCqF(K4C6do7ei0bCqzR2Idkl7mAr52YMzth8vV7GSX0peqj)brZfBCqS1wdgp4R1b15GSjsCqF(K4C6do7ei0bCqzR2Idkl7mAr52EBF)VglB7Rx2B5(UdEq7Srhmx7dqpO0aoyfM5H6Ovr8tEQwR4Ga69HKaYFq8SOdgi6ScL8h0ylAweUCBzZSPdY(7oiBm9dbuYFWkainjnawuP(vCqDoyfaKMKgalQu)c1XNt(koOSSZOfLBlBMnDq2F3bzJPFiGs(dwbEq4)S9L6xXb15GvGhe(pBFP(fQJpN8vCqzzNrlk3w2mB6G19UdYgt)qaL8hScastsdGfvQFfhuNdwbaPjPbWIk1VqD85KVIdkl7mAr52YMzthSU3Dq2y6hcOK)GvGhe(pBFP(vCqDoyf4bH)Z2xQFH64ZjFfhuw2z0IYTLnZMo4RE3bzJPFiGs(dwbaPjPbWIk1VIdQZbRaG0K0ayrL6xOo(CYxXbLLDgTOCBzZSPd(Q3Dq2y6hcOK)GvGhe(pBFP(vCqDoyf4bH)Z2xQFH64ZjFfhuw2z0IYTLnZMo4lE3bTSP18q(dUY(D1)GgBKHHdkBp6bJNi5XNthm7dsleEO50wCqzzNrlk3w2mB6GV4DhKnM(Hak5pyf4bH)Z2xQFfhuNdwbEq4)S9L6xOo(CYxXbLLDgTOCBzZSPdwP3DqlBAnpK)GRSFx9pOXgzy4GY2JEW4jsE850bZ(G0cHhAoTfhuw2z0IYTLnZMoyLE3bzJPFiGs(dwbEq4)S9L6xXb15GvGhe(pBFP(fQJpN8vCqzzNrlk3w2mB6G1Z7oiBm9dbuYFWkWdc)NTVu)koOohSc8GW)z7l1VqD85KVIdk7Ry0IYTLnZMoOL5DhKnM(Hak5pyfAWPwl1VIdQZbRqdo1AP(fQJpN8vCqzzNrlk3w2mB6GV37oiBm9dbuYFWkWdc)NTVu)koOohSc8GW)z7l1VqD85KVIdkl7mAr52YMzth0Y)UdYgt)qaL8hSc8GW)z7l1VIdQZbRapi8F2(s9luhFo5R4GYYoJwuUTSz20bzVYV7GSX0peqj)bRapi8F2(s9R4G6CWkWdc)NTVu)c1XNt(koyOh0YXYcBEqzzNrlk32B77)1yzBF9YEl33DWdANn6G5AFa6bLgWbRqTcIwfysr2R4Ga69HKaYFq8SOdgi6ScL8h0ylAweUCBzZSPd(Q3Dq2y6hcOK)GvaqAsAaSOs9R4G6CWkainjnawuP(fQJpN8vCqzzNrlk32B77)1yzBF9YEl33DWdANn6G5AFa6bLgWbRWtsbcxR4Ga69HKaYFq8SOdgi6ScL8h0ylAweUCBzZSPdwP3Dq2y6hcOK)GvGhe(pBFP(vCqDoyf4bH)Z2xQFH64ZjFfhuw2z0IYTLnZMoy98UdYgt)qaL8hSc8GW)z7l1VIdQZbRapi8F2(s9luhFo5R4GYYoJwuUTSz20bzVEE3bzJPFiGs(dwbEq4)S9L6xXb15GvGhe(pBFP(fQJpN8vCqzFfJwuUTSz20bz3Y8UdYgt)qaL8hSc8GW)z7l1VIdQZbRapi8F2(s9luhFo5R4GYYoJwuUTSz20bz3Y)UdYgt)qaL8hScastsdGfvQFfhuNdwbaPjPbWIk1VqD85KVIdkl7mAr52YMzthSo2F3bzJPFiGs(dwbaPjPbWIk1VIdQZbRaG0K0ayrL6xOo(CYxXbLLDgTOCBzZSPdw3lE3bzJPFiGs(dwbaPjPbWIk1VIdQZbRaG0K0ayrL6xOo(CYxXbLLDgTOCBzZSPdwx98UdYgt)qaL8hScastsdGfvQFfhuNdwbaPjPbWIk1VqD85KVIdkl7mAr52YMzth8vS)UdYgt)qaL8hScastsdGfvQFfhuNdwbaPjPbWIk1VqD85KVIdkl7mAr52EBF)VglB7Rx2B5(UdEq7Srhmx7dqpO0aoyf7aYmRFOvCqa9(qsa5piEw0bdeDwHs(dASfnlcxUTSz20bzVYV7GSX0peqj)bRaG0K0ayrL6xXb15GvaqAsAaSOs9luhFo5R4GHEqlhllS5bLLDgTOCBzZSPdYELF3bzJPFiGs(dwbaPjPbWIk1VIdQZbRaG0K0ayrL6xOo(CYxXbLLDgTOCBVTV)xJLT91l7TCF3bpOD2OdMR9bOhuAahScfKndKIR4Ga69HKaYFq8SOdgi6ScL8h0ylAweUCBzZSPdYELF3bzJPFiGs(dwHcYMbslSxQFfhuNdwHcYMbslk7L6xXbLLDgTOCBzZSPdYo7V7GSX0peqj)bRqbzZaPL6k1VIdQZbRqbzZaPfTUs9R4GYYoJwuUT323)RXY2(6L9wUV7Gh0oB0bZ1(a0dknGdwXStnbQ4Ga69HKaYFq8SOdgi6ScL8h0ylAweUCBzZSPdY(7oiBm9dbuYFWkWdc)NTVu)koOohSc8GW)z7l1VqD85KVIdg6bTCSSWMhuw2z0IYT92wVw7dqj)bzVYhmmAo9b5jwXLBRdDhmsjNCOSfBDWxNwtp8HL1d((daFmmCBzl26G2uDh)UQRMvQ2q(fZSQgNleEO50gqiPvJZLP6BlBXwh81Sds(bR79y6G1v56Q72EBzl26GSHTOzr43DBzl26GV8GO7eNFq2CmmuUTSfBDWxEqlln36bbKzwlQ9h81P10)HRhChqV0mRFOhmLoyQhmXhmBSgTEqzhWbTfaVjW6bLgWb)dgtylQ38G(PRqp48qatSFqSTa4XhmLoO1bPcaDWqpyLoy2huTrhC2PMaLBlBXwh8Lh81EyMahen3Tn9bdoFyM8hChqV0mRFOhuNdUdgZbZgRrRh81P10)HRLBlBXwh8Lh81(51(GAWPwpy2kbai7A52YwS1bF5bFnpt6pi6gVCZ6Tgl3dI3J1bz2g1h06GubGoyp6bJ)GOhuNdIrwRPpyCq7ScIwl3w2ITo4lpOLvCcBZacjT669dp0KtheD4puRh0eTH4Iu6GgBrZI8huNdMTsaaYUksPYTLTyRd(YdAhW6b15GXZK(dYCG1SzDWxNwtNMdYgdGoiwddd4YTLTyRd(YdAhW6b15GRGb6GZo1e4G7GCaPA9GtZTEqMhadhmLoiZ0bnrFWWOibNB9GZo1hK5uTDW4G2zfeTwUTSfBDWxEW61Ahmp0bnZAp08N8uTEqMt12bR3wMd(rsUhxUT3w26GwomsgeL8h8tsdGoOzw)qp4NyLnUCWxJXq7k(G90V0wawsi8dggnNgFWP5wl32WO504YoGmZ6hQmYRwI4c)SYo0CAMsj5AUOnRCnlTtAj45dDBdJMtJl7aYmRFOYiVAmYAnTyN0BBy0CACzhqMz9dvg5vJGjrQ0IPowKCDwKyKeRPXkyqWcZ0yfGy0CA8TnmAonUSdiZS(HkJ8QrWKivAXuhlsoE4uydlWKbqQqjJToFFi0TnmAonUSdiZS(HkJ8QL4e2Mbes6TnmAonUSdiZS(HkJ8Q3hMjGaN72MMPus(hrsQWCY9ICTJlynmmSj71(issfpTMoncZaOcwdddVjVUBBy0CACzhqMz9dvg5vJGjrQ0IPowKCSTWpmtEXa(IrsOdyrTEBdJMtJl7aYmRFOYiVApTM(pCLPusoEq4cSTa4XVvPAY(hmUQQcJMtx80A6)W1IjWQ8kBXTnmAonUSdiZS(HkJ8QX2c)WS4pCLPusoEq4cSTa4XVvPAws2)GXvvvy0C6INwt)hUwmbwLxzlUTSfBDWWO504YoGmZ6hQmYR(jaz85etDSi5sjaRc1kiAvO5IyA2LJjLPNGJqYzVY3w2IToyy0CACzhqMz9dvg5v)eGm(CIPowK8SfZo1eGPzxoMuMEcocjN9BBy0CACzhqMz9dvg5v)eGm(CIPowKCemj(dxfAUYMfMPzxoMuMEcocjhG0K0ayrLFWj8E6jaw8raD2SeMbq1ainjnawubBlaEXijIUtBjp0C6B7T92Ywh0YHrYGOK)G0dbSEqnx0bvB0bdJoGdM4dgprYJpNk32WO50y54DIZf8XWWTnmAonwg5vBcoxirCBiTsGBBy0CASmYRoyKe6GX32WO50yzKxTNEgeGyfSsZTnmAonw(taY4ZjM6yrYBIrvOwbrRcJNPzxoMuMEcocj3md3pm3fmYAnTWtRPtJqTcIwlaAfzJfeJ7KrjptPKClHhe(pBFrkjUxmsIpFW4zHRQkZmC)WCxWiR10cpTMonc1kiATaOvKnwqmUtgL8BAMH7hM7cEq4cWOfaTISXcIXDYOK)2ggnNglJ8QFcqgFoXuhlsEtmQc1kiAvy8mn7YXKY0tWri5Mz4(H5UGheUamAbqRiBSGyCNmk5zkLKJhe(pBFrkjUxmsIpFW4zHRzMH7hM7cgzTMw4P10PrOwbrRfaTISXcIXDYOK)nZmC)WCxWdcxagTaOvKnwqmUtgL83w2IToyy0CASmYR(jaz85etDSi5zlMDQjatZUCmPm9eCesELzkLKVtAXtRPtJqTcIwlHrZh62ggnNglJ8QFcqgFoXuhls(hrssGT2gHXZ0SlhtktpbhHK)eGm(CQ0eJQqTcIwfgptPKCl9eGm(CQGGjXF4QqZv2SW1Su2IzNAcCBdJMtJLrE1pbiJpNyQJfj)JijjWwBJW4zA2LJjLPNGJqYzVoMsj5w6jaz85ubbtI)WvHMRSzHRLTy2PMa1S0oPfpGcpwdodeOegnFOBBy0CASmYR(jaz85etDSi5Fejjb2ABegptZUCmPm9eCesELzkLKBPNaKXNtfemj(dxfAUYMfUw2IzNAcuBN0IhqHhRbNbcucJMpuTpIKuH5K7f5AhxWAyyyZkxZsAWPwlpjNKsQ9fQJpN832WO50yzKx9taY4ZjM6yrY)isscS12imEMMD5ysz6j4iK8kZukj3spbiJpNkiys8hUk0CLnlCTSfZo1eO2oPfpGcpwdodeOegnFOA7a6rWY4lSxSfTxmscwiCF010GtTwEsojLu7luhFo5VTHrZPXYiV6NaKXNtm1XIK)rKKeyRTry8mn7YXKY0tWri5Mz4(H5U4jtUcnBwI)W1cGwr2ybX4ozuYZukj)jaz85ubbtI)WvHMRSzHVTHrZPXYiVAtW5IWO50cEIvM6yrYvq2mqk(2ggnNglJ8QnbNlcJMtl4jwzQJfjFyz8mLsYL1spbiJpNkiys8hUk0CLnlCTDslEAnDAeQvq0AjmA(qwuvvY(eGm(CQGGjXF4QqZv2SW1(issfSTa4fJKi6oTL8qZPli71K1sAWPwl7dZeqGZDBtxOo(CYxvvFejPY(Wmbe4C320fKDlS42ggnNglJ8QZ1oFW50mLsY)dgxtkzztfaAfzJFRo2MLXFBdJMtJLrE1MGZfHrZPf8eRm1XIKp7utaMWkinQC2zkLKRdlwCQyMH7hMBCnnx0BsjaRc1kiAvO5IUTHrZPXYiVAtW5IWO50cEIvM6yrYnZd1rRI4N8uTYewbPrLZotPKC8GW)z7lSaZdjY(jznGqZPRQk8GW)z7lsjX9Irs85dgplCvvHhe(pBFXmRFOIf5tn0C6QQYmpuhTwAYag(a832WO50yzKx9(O50mLsYL1spbiJpNkiys8hUk0CLnlCTNaKXNtLMyufQvq0QW4FJLXxwbJ10CrBkLaSkuRGOvHMlQQQWdc)NTVaiPSjVyp4Hs1EcqgFovAIrvOwbrRcJ)Tx9EwuvvY(eGm(CQGGjXF4QqZv2SW1(issfSTa4fJKi6oTL8qZPli7wCBdJMtJLrE1MGZfHrZPf8eRm1XIKRwbrRcmPi732WO50yzKxTNwtNgbwbuZsTXukjxwlbqAsAaSOcZjxcqESaNSsUyKeyKDcKdqGrwRPZMvTNaKXNtLMyufQvq0QW430YBrvvj7oPfpTMonc1kiATegnFOA7Kw80A60iuRGO1cGwr243Qh2MLXxwbJwCBdJMtJLrE1MGZfEafESgCgiaMPus(taY4ZPccMe)HRcnxzZcxZmd3pm3fmYAnTWtRPtJqTcIwlaAfzJfeJ7Krj)M1v3TnmAonwg5vBcox4bu4XAWzGayMsj5w6jaz85ubbtI)WvHMRSzHRj7taY4ZPstmQc1kiAvy8BwxLFzLyBlbqAsAaSOcZjxcqESaNSsUyKeyKDcKdqGrwRPZMLf32WO50yzKx9p5e2miawK4pRpbWmLsY)issf1kiAT4hM7ApbiJpNknXOkuRGOvHXVzLUTHrZPXYiV6CTZhContPK8WO5djOMwjH3KDzKLD2wdo1AbhgqkLgYlWdchxOo(CYBrTpIKuH5K7f5AhxWAyyyt51tTpIKurTcIwl(H5U2taY4ZPstmQc1kiAvy8BwPAY(rKKk5ANp48He7JsTMbV4hM7QQ6Jijvyo5ErU2XfSgggyBzzxMxW2YI3joxObGfP4sU25doNEZ6SWInL)rKKk5ANp48He7JsTMbV8WUf32WO50yzKxDU25doNMPusEy08HeutRKWBwxTpIKuH5K7f5AhxWAyyyt51tTpIKurTcIwl(H5U2taY4ZPstmQc1kiAvy8BwPAwcG0K0ayrLCTZhC(qI9rPwZGxtwlPbNATibMLqTrcSTWpmJluhFo5RQkp9rKKksGzjuBKaBl8dZ4cYUf32WO50yzKxDU25doNMPusEy08HeutRKWBYUmYYoBRbNATGddiLsd5f4bHJluhFo5TO2hrsQWCY9ICTJlynmmSP86rgzFfBRbNATGheUWmThj1c1XNtElQ9rKKkQvq0AXpm31EcqgFovAIrvOwbrRcJFZkvt2pIKujx78bNpKyFuQ1m4f)WCxvvFejPcZj3lY1oUG1WWaBll7Y8c2ww8oX5cnaSifxY1oFW50BwNfwSP8pIKujx78bNpKyFuQ1m4Lh2T42ggnNglJ8QZ1oFW50mLsYdJMpKGAALeEZ6Q9rKKkmNCVix74cwdddBkVEKr2xX2AWPwl4bHlmt7rsTqD85K3IAFejPIAfeTw8dZDTNaKXNtLMyufQvq0QW43Ss1SeaPjPbWIk5ANp48He7JsTMbVMSwsdo1ArcmlHAJeyBHFygxOo(CYxvvE6JijvKaZsO2ib2w4hMXfKDlUTHrZPXYiVAwGCnjGeseNfsa8mLsY)dgxtZfj0r4t6Txv5BBy0CASmYRgJSwtlEsojLu7zkLK)hmUMMlsOJWN0B19E32WO50yzKxngzTMw4P10PrOwbrRmLsY)dgxtZfj0r4t6n2R0TnmAonwg5vBlAVyKeSq4(OzkLKJheUaBlaE5v62ggnNglJ8QX2c)WS4pCLPusoEq4cSTa4FRs1ainjnawu5hCcVNEcGfFeqNnlHzauTpIKu5hCcVNEcGfFeqNnlHzaubqRiB8Bv62ggnNglJ8Q9ZSykLKdijaHTfFoDBzRdwVKo4RdOWJ1GZabWhma0bdoGcV1dggnFiMoyphSjYFqDoioEOdITfap(2ggnNglJ8QTfTxmscwiCF0mLsYXdcxGTfa)MYFvnz3jT4bu4XAWzGaLWO5dvvv7Kw80A60iuRGO1sy08HS42ggnNglJ8QTfTxmscwiCF0mLsYXdcxGTfa)MYzV2hrsQ0KAJaI9bObVGSxZmd3pm3ftW5cpGcpwdodeaxa0kYgVzDSnlJVScgVTHrZPXYiVABr7fJKGfc3hntPKC8GWfyBbWVPC2R9rKKkmNCVix74cwdddBwxTDslEafESgCgiqbqRiB8MvUujzmbwfAUizcJMtxWiR10cpTMonc1kiATycSk0Cr12jT4bu4XAWzGafaTISXVv5sLKXeyvO5IKjmAoDbJSwtl80A60iuRGO1IjWQqZfjJSvEZ6nK9vVepiCb2wa8wybBhgnNUGTf(HzXF4AXeyvO5IQ9eGm(CQ0eJQqTcIwfg)BSm(YkySMMlAtPeGvHAfeTk0CrVKLXxwbJ32WO50yzKxTj4Cry0CAbpXktDSi5M5H6Ovr8tEQwzcRG0OYzNPusULmZd1rRLhQvBwb3w26GV)uTni6brddiLsd5pi6GWXmDq0bHFqufKmqhmXheRGPzrGdQ2I(GVoTM(pCLPdINdM6bTf4dgh0wYYgbo4oihqQwVTHrZPXYiVA8GWfyfKmqmLsYTKgCQ1comGuknKxGheoUqD85K)2ggnNglJ8Q3hMjGaN72MMPusULEcqgFovqWK4pCvO5kBw4AFejPcZj3lY1oUG1WWWMSx7Jijv80A60imdGkynmm82RUTHrZPXYiV69HzciW5UTPzkLK)eGm(CQGGjXF4QqZv2SW1(issfSTa4fJKi6oTL8qZPli71(issfSTa4fJKi6oTL8qZPlynmm82RUTS1br3P2FWxNwtNMdYgdGWhuAaheDq4he1wa84dI0AYpODwbrRh0md3pm3hmXh0WhmDqDoiGcV1BBy0CASmYR2tRP)dxzkLK)rKKkEAnDAeMbqfafgTgEq4cSTa4F7f1EcqgFovAIrvOwbrRcJFZ6Q8TLTo4RJaYM1bTZkiA9Gysr2z6G4DQ9h81P10P5GSXai8bLgWbrhe(brTfap(2ggnNglJ8Q90A6)WvMsj5FejPINwtNgHzaubqHrRHheUaBla(3ErTNaKXNtLMyufQvq0QW4FJ96UTHrZPXYiVApTM(pCLPus(hrsQ4P10Prygavauy0A4bHlW2cG)Txut2pIKuXtRPtJWmaQG1WWWM1vvvAWPwl4WasP0qEbEq44c1XNtElUTHrZPXYiV69HzciW5UTPzkLK)eGm(CQGGjXF4QqZv2SW1(issfSTa4fJKi6oTL8qZPli732WO50yzKxTNwt)hUYukjhtQ4pncUOjbQ79e1TBQHheUaBla(3ErnzLTEEjEq4cSTa4TGTdJMtxW2c)WS4pCTqmsgeLeAUOn3jT4bu4XAWzGafaTISXVmmAoDXw0EXijyHW9rxigjdIscnx0ldJMtx80A6)W1cXizqusO5ISO2hrsQ4P10PrygavWAyyyt5SFBdJMtJLrE1EAn9F4ktPK8pIKuXtRPtJWmaQaOWO1WdcxGTfa)BVOwy08HeutRKWBY(TnmAonwg5vJheUaRGKb62ggnNglJ8QnbNlcJMtl4jwzQJfj3mpuhTkIFYt16TLToy9s6GwhKdAI(GSi9G)WWWb15Gv6GOdc)GO2cGhFWpjna6GVoGcpwdodeaFqZmC)WCFWeFqafERmDWuRaFWHHW6b15G4DQ9huTrRd2dZ32WO50yzKxTTO9IrsWcH7JMPusoEq4cSTa43u(RQ9eGm(CQ0eJQqTcIwfg)M1vPAYQbNAT4P10PrycopBwfQJpN8vvLzgUFyUlMGZfEafESgCgiaUaOvKnEtzLTsVepiCb2wa8wW2HrZPlyBHFyw8hUwigjdIscnxKfYegnNUylAVyKeSq4(OleJKbrjHMlYIBBy0CASmYR2pZIjJvdNeAayrkwo7mLsYbKeGW2IpNQP5I2ukbyvOwbrRcnx0TLToOL1y6GVoTM(pC9GP0bToivaOdYAYM1b15G8bth81P10P5GSXaOdI1WWaMPdspuFWu6GPwH)GmhyLoyCq8GWpi2wa8LBBy0CASmYR2tRP)dxzkLK)rKKkEAnDAeMbqfafgT2hrsQ4P10Prygava0kYg)g7YWY4lRGr2(Jijv80A60imdGkynmmCBdJMtJLrE1yBHFyw8hUEBVTHrZPXfmFywOGSzGuSCemjsLwm1XIKJheoNunBwcaY3ktgRgoj0aWIuSC2zkLK)eGm(CQ8rKKeyRTry8VPbGfPfFI1On0RvLEPS1X2Sm(YkyKTFcqgFovqWK4pCvO5kBwylUTHrZPXfmFywOGSzGuSmYRgbtIuPftDSi5yK(ZNXlIfP2SIvMsj5pbiJpNkFejjb2ABeg)BAayrAXNynAd9AvjzKTo2(jaz85ubbtI)WvHMRSzHT42ggnNgxW8HzHcYMbsXYiVAemjsLwm1XIKtRDRak4Ib47OnetPK8NaKXNtLpIKKaBTncJ)nz1aWI0IpXA0g61Qswid71jJS1X2pbiJpNkiys8hUk0CLnlSf32BBy0CACXmpuhTkIFYt1QC8GWfGrzkLKllEq4)S9fPK4EXij(8bJNfUQQainjnawuXtMWA2Se4bHlWHASrClQTtAXtRPtJqTcIwlHrZh62ggnNgxmZd1rRI4N8uTkJ8QXdcxagLPusoEq4)S9fwG5Hez)KSgqO501SeaPjPbWIkEYewZMLapiCbouJnIxt2NaKXNtLMyufQvq0QW4FRUkxvvpbiJpNknXOkuRGOvHXV5RQSf32WO504IzEOoAve)KNQvzKxnEq4cWOmLsYXdc)NTVWCY9cBiTk0WOPbxZsaKMKgalQ4jtynBwc8GWf4qn2iEnlTtAXtRPtJqTcIwlHrZhQ2taY4ZPstmQc1kiAvy8BY(7DBdJMtJlM5H6Ovr8tEQwLrE1EYKRqZML4pCLjJvdNeAayrkwo7mLsYxz)onaSiTyJcUARSBuMsj5w6jaz85ubbtI)WvHMRSzHRHhe(pBFHtHx8TkigJ1oNQj7oPfpTMonc1kiATegnFOA4bHlW2cG)T6QQklTtAXtRPtJqTcIwlHrZhQ2taY4ZPstmQc1kiAvy8B(IkBXTnmAonUyMhQJwfXp5PAvg5v7jtUcnBwI)WvMmwnCsObGfPy5SZukjFL970aWI0Ink4QTYUrzkLKBPNaKXNtfemj(dxfAUYMfUgEq4)S9fgONSXIzQ3r8Szvt2DslEAnDAeQvq0AjmA(qvvLL2jT4P10PrOwbrRLWO5dv7jaz85uPjgvHAfeTkm(nFrLT42ggnNgxmZd1rRI4N8uTkJ8Q9KjxHMnlXF4ktgRgoj0aWIuSC2zkLKBPNaKXNtfemj(dxfAUYMfUMS4bH)Z2xKgal6pGMea6HajHRQkzXdc)NTV8m8qtojWd)HATMLWdc)NTVWa9Knwmt9oINnllSOML2jT4P10PrOwbrRLWO5dDBdJMtJlM5H6Ovr8tEQwLrE1EYKRqZML4pCLjJvdNeAayrkwo7mLsYFcqgFovqWK4pCvO5kBw4AYAjn4uRL9HzciW5UTPRQkZmC)WCx2hMjGaN72MUaOvKn(TWO50fpzYvOzZs8hUwigjdIscnxKf1SKzgUFyUlyK1AAHNwtNgHAfeTwq2Rj7oPfpTMonc1kiATaOvKn(T3RQQmZW9dZDbJSwtl80A60iuRGO1cGwr2ybX4ozuY)2RQSf32WO504IzEOoAve)KNQvzKxTeNW2mGqszkLKJhe(pBF5z4HMCsGh(d1ATpIKu5z4HMCsGh(d1AXpm3mLTsaaYUksj5FejPYZWdn5Kap8hQ1cY(TnmAonUyMhQJwfXp5PAvg5vJndciBwcnvBetPKC8GW)z7lMz9dvSiFQHMtxBN0INwtNgHAfeTwcJMp0TnmAonUyMhQJwfXp5PAvg5vJndciBwcnvBetPKClHhe(pBFXmRFOIf5tn0C6BBy0CACXmpuhTkIFYt1QmYRox7u7ZMLWeAGvWSBJykLKVtAXtRPtJqTcIwlHrZhQgEq4cSTa4Lx5B7TnmAonUyBxOGSzalhbtIuPftDSi54SLq4cw8WNHoaSGwFoTUTHrZPXfB7cfKndyzKxncMePslM6yrYXzlHWfbEpbrRybT(CADBVTHrZPXLHLXl)tambyiBw32WO504YWY4LrE1F(mEHecW6TnmAonUmSmEzKxTucOpFg)TnmAonUmSmEzKxncMePsl8T92ggnNgxMDQjGC8GWfGrzkLKJhe(pBFHfyEir2pjRbeAo9TnmAonUm7utazKxDtQnci2hGg8BBy0CACz2PMaYiVAwGCnjGeseNfsa832WO504YStnbKrE1yK1AAXtYjPKA)TnmAonUm7utazKxn2w4hMf)HRmLsYXdcxGTfa)BvQMzgUFyUlMGZfEafESgCgiaUGSFBdJMtJlZo1eqg5vJTf(HzXF4ktPK8NaKXNtfemj(dxfAUYMfUgEq4cSTa4FRs1(issLFWj8E6jaw8raD2SeMbqfSgggE7f32WO504YStnbKrE1MGZfEafESgCgia(2EBdJMtJl7ias4JvWIekiBgWYrWKivAXuhlsUhqHxkbK4HWyIFBdJMtJl7ias4JvWIekiBgWYiVAemjsLwm1XIKdi80rRcaHjWZKGBBy0CACzhbqcFScwKqbzZawg5vJGjrQ0IPowK8aySLkzuSiBwuJKQvHza0TnmAonUSJaiHpwblsOGSzalJ8QrWKivAXuhlsUzWR0iyXdFg6aWcaHNo0bCBdJMtJl7ias4JvWIekiBgWYiVAemjsLwm1XIK7bu4LsajEimM432WO504YocGe(yfSiHcYMbSmYRgbtIuPftDSi54bHlswDQe42ggnNgx2raKWhRGfjuq2mGLrE1iysKkTyQJfjNf36UnXijcmoxjp0CAMsj5HrZhsqnTsclN9BBy0CACzhbqcFScwKqbzZawg5vJGjrQ0IPowKCFayyntl8KHbXoIciSHAdDBdJMtJl7ias4JvWIekiBgWYiVAemjsLwm1XIKt)PXdcx8Ky62ggnNgx2raKWhRGfjuq2mGLrE1iysKkTyQJfjhPn2ISjVGfp8zOdalW2cddCcFBVTHrZPXffKndKIL)eGm(CIPowKCemj(isscfKndKIz6j4iKCzT0taY4ZPccMe)HRcnxzZcxBN0INwtNgHAfeTwcJMpKfvvLSpbiJpNkiys8hUk0CLnlCTpIKubBlaEXijIUtBjp0C6cYUf32WO504IcYMbsXYiVAemjsLwm1XIKJnbalgjHeiuc0bxGvqkrmLsYT0hrsQGnbalgjHeiuc0bxGvqkrIxuq2VTHrZPXffKndKILrE1iysKkTyQJfjhBcawmscjqOeOdUaRGuIykLK)rKKkytaWIrsibcLaDWfyfKsK4ffK9A7Kw80A60iuRGO1sy08HUTHrZPXffKndKILrE1iysKkTyQJfjhBl8dZKxmGVyKe6awuRmLsYFcqgFov(isscS12im(3QRUBBy0CACrbzZaPyzKxncMePslM6yrYxZ08uf7GeVykLK)eGm(CQGGjXF4QqZv2SW12jT4P10PrOwbrRLWO5dDBdJMtJlkiBgiflJ8QrWKivAXuhlsolqUeKHN7yIPus(taY4ZPYhrssGT2gHX)ML52ggnNgxuq2mqkwg5vBcoxegnNwWtSYuhlsUTDHcYMbmtPKCn4uRfpTMoncZ0yK1UMtxOo(CYx7jaz85uPjgvHAfeTkm(3QRY3w26GwossKrXhuTf6bvq8q8dI5dZCRhucmRdQ2OdQbGfPheqVpKeqhm8(uZPdothet7biu6G2I2ZZM1TnmAonUOGSzGuSmYR2eCUimAoTGNyLPowKCmFywOGSzGu8TnmAonUOGSzGuSmYRgbtIuPftDSi5ZdbK4dZzZseDUcHjyrmLsYFcqgFovqWK4Jijjuq2mqk(2ggnNgxuq2mqkwg5vJGjrQ0IjmFu5kiBgiLDMsj5kiBgiTWEXwGfiys8rKKQ9eGm(CQGGjXhrssOGSzGu8TnmAonUOGSzGuSmYRgbtIuPfty(OYvq2mqADmLsYvq2mqAPUITalqWK4Jijv7jaz85ubbtIpIKKqbzZaP4BBy0CACrbzZaPyzKxTj4Cry0CAbpXktDSi57ias4JvWIekiBgWmLsY1CrBkLaSkuRGOvHMlQ2taY4ZPYhrssGT2gHXVzDv(2EBdJMtJlQvq0QatkYU8MuBeqSpan4mLsYFcqgFovAIrvOwbrRcJ)n2R0TnmAonUOwbrRcmPi7YiVAwGCnjGeseNfsa8mLsYFcqgFovAIrvOwbrRcJ)n2TmVu2WO50fmYAnTWtRPtJqTcIwleJKbrjHMlsMWO50fSTWpml(dxleJKbrjHMlYIAYAMH7hM7Ij4CHhqHhRbNbcGlaAfzJFJDlZlLnmAoDbJSwtl80A60iuRGO1cXizqusO5IKjmAoDbJSwtlEsojLu7leJKbrjHMlsMWO50fSTWpml(dxleJKbrjHMlYIQQAN0IhqHhRbNbcua0kYgV5taY4ZPstmQc1kiAvy8YegnNUGrwRPfEAnDAeQvq0AHyKmikj0CrwCBdJMtJlQvq0QatkYUmYRgJSwtlEsojLu7zkLKl7taY4ZPstmQc1kiAvy8VXELEPSHrZPlyK1AAHNwtNgHAfeTwigjdIscnxKf1K1md3pm3ftW5cpGcpwdodeaxa0kYg)g7v6LYggnNUGrwRPfEAnDAeQvq0AHyKmikj0CrYegnNUGrwRPfpjNKsQ9fIrYGOKqZfzrvvTtAXdOWJ1GZabkaAfzJ38jaz85uPjgvHAfeTkmEzcJMtxWiR10cpTMonc1kiATqmsgeLeAUilSOQQK1saKMKgalQWCYLaKhlWjRKlgjbgzNa5aeyK1A6Szv7jaz85uPjgvHAfeTkm(nFrLT42ggnNgxuRGOvbMuKDzKxTj4CHhqHhRbNbcGzkLK)eGm(CQ0eJQqTcIwfg)BSx3lLnmAoDbJSwtl80A60iuRGO1cXizqusO5IKjmAoDbBl8dZI)W1cXizqusO5IS42ggnNgxuRGOvbMuKDzKxngzTMw4P10PrOwbrRmLsY1CrBkLaSkuRGOvHMlQMS7Kw8ak8yn4mqGsy08HQTtAXdOWJ1GZabkaAfzJ3mmAoDbJSwtl80A60iuRGO1cXizqusO5ISOMSwsdo1AbJSwtlEsojLu7luhFo5RQQDslpjNKsQ9LWO5dzrnzXdcxGTfaV8kxvvYUtAXdOWJ1GZabkHrZhQ2oPfpGcpwdodeOaOvKn(TWO50fmYAnTWtRPtJqTcIwleJKbrjHMlsMWO50fSTWpml(dxleJKbrjHMlYIQQs2DslpjNKsQ9LWO5dvBN0YtYjPKAFbqRiB8BHrZPlyK1AAHNwtNgHAfeTwigjdIscnxKmHrZPlyBHFyw8hUwigjdIscnxKfvvLSFejPclqUMeqcjIZcja(cYETpIKuHfixtciHeXzHeaFbqRiB8BHrZPlyK1AAHNwtNgHAfeTwigjdIscnxKmHrZPlyBHFyw8hUwigjdIscnxKfw4qde12aCOo1Poha]] )


end
