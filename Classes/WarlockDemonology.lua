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

        if buff.dreadstalkers.up then
            state:QueueAuraExpiration( "dreadstalkers", ExpireDreadstalkers, ceil( buff.dreadstalkers.expires ) )
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

            usable = function ()
                if settings.dcon_imps > 0 and buff.wild_imps.stack < settings.dcon_imps then return false, "requires " .. settings.dcon_imps .. " wild imps" end
                return true
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


    spec:RegisterPack( "Demonology", 20220416, [[dafoedqiKqpskfDjPukTjPWNufzueLofrXQic6vQOMLuYTufv7su)IiAyuLQJru1Yur6zibnnKaxJQu2MQO4BevuJJOs5Ceb06iQK3rurG5Pk4EkP9jLQ)ruPQCqIazHeHEOukmrvrPlsurAJevQQ(OukvnsPukQtseGvkfntPuYnjQiODQk0pLsPWqjQuLLkLsLNsvnvvexLOIqBvkLI8vIkvglrf2Rs9xugmvomLfRQEmHjlYLH2ms9zK0OPkoTWRvLmBuDBPA3s(TIHRehNiqTCqphy6KUUkTDv47irJxvQZtKwprfrZNQK9J4T87t2(jtX9JN69tp17uG8pt27E)uk0Bu42xLUGB)ft8YOIB)Y642)zX(udFOkD7Vys5JL2NS9bZfkWTVF0BJT))gCvcO2)TFYuC)4PE)0t9ofi)ZK9U3pLc92PBFWck2pE6Z8mBFprkH1(V9tiqS9FwSp1WhQsjo5odYhXlstpQUaKljLKAOEU)Sy6scI(LBAmLaA0QKGOlKK0ucAbgCIt(NPfXDQ3p9ustsZ2WJvurGCrA(CIZFb5CIRTgXRmP5ZjU2gfxkXbrX07yLiUNf7t9hUsClq85IP)nL4cAIluIlaexua1kL4KDGeNhdMegqjo6bsC)baqGmYjG4st9KsCZbcf2cXb8yWeG4cAIt6CFcIeNPeN3iUOio1dsCZcwimtA(CItU3qjcjo)yXZueNX5dLyI4wG4Zft)BkXPdXTahbXffqTsjUNf7t9hUMjnFoXj37qUhXPghlL4Isri8UOzsZNtCsqhtKioFj(82BBEA7joWI1jok9GfXjDUpbrIRgL4S)CvIthIdC79PioJ4ork0kntA(CItUFoc8iGgTkzBtd30GJeN)WpWsjoHvcKZcAIt4XkQyI40H4Isri8UOSGotA(CI7eOuIthIZoMirCuAankQe3ZI9PcbX1gdejoGAIxGmP5ZjUtGsjoDiUU9cjUzblesClWyGHkL4MIlL4OCGViUGM4OejoHveNj0RX5sjUzblIJYq9qCgXDIuOvAM085eNeqFbohiXjM(IPXp4HkL4OmupeNCcptC)BWtGmPjPPC6BuCvmrCFKEGiXjM(3uI7JuJcKjojiHaxuaXvt9CpgStF5eNj0ykaXnfxAM00eAmfiVarX0)MEEvsAKZstpktJPAf0RA0X29EdkUGA24XbsAAcnMcKxGOy6FtpVkj427tXwqL00eAmfiVarX0)MEEvYlazHI9wL1XvD6iBOz9PakCUaMykGcVcnMcqAAcnMcKxGOy6FtpVk5fGSqXERY64ky4O5bWaOaIktrHNkKGViPPj0ykqEbIIP)n98QK0Ce4ranAL00eAmfiVarX0)MEEvYLHseYaXINPAf0R)lnDMYGNyrFbKbQjE1U8n(xA6Cc7tfcMyGygOM41dRNsAAcnMcKxGOy6FtpVk5fGSqXERY64kWJLgkXeBGF2qZ0b2XsjnnHgtbYlqum9VPNxLmH9P(dxBf0RG5YzapgmbEWBnK9paGxEzcnMkNW(u)HRzHb0vVldPPj0ykqEbIIP)n98QKapwAOK9hU2kOxbZLZaEmyc8G3Aqrz)da4LxMqJPYjSp1F4AwyaD17YqAAcnMcKxGOy6FtpVk5Hbd7ZXwL1Xv6acuMkfALY0OJTMLvaQTom(fxL37KMMqJPa5fikM(30ZRsEyWW(CSvzDCnk2SGfcBnlRauBDy8lUkpPPj0ykqEbIIP)n98QKhgmSphBvwhxVaK9hUY0OhfvqRzzfGARdJFXv4Tq6bsfZFJJGLiHqa7FHvuuzIbInG3cPhivmd8yWeBOzwvHNGBAmfPjPjPPC6BuCvmrC4bcLsCA0rIt9GeNj0bsCbG4Sdl42NJzsttOXuGvWcY5m(iErAAcnMcCEvsHX5mAK75wkcjnnHgtboVkP9gz6aaKMMqJPaNxLmHhZfY6g1qqAAcnMcSEyWW(CSvzDCTW3ktLcTszIuRzzfGARdJFXvXm80qzLb3EFkwc7tfcMkfALMHy3IcWW3lOqXuRGELIG5Y)rLY0bYtSHM95damDGxEjMHNgkRm427tXsyFQqWuPqR0me7wuag(EbfkMAxmdpnuwzWC5m4Ozi2TOam89ckumrAAcnMcCEvYddg2NJTkRJRf(wzQuOvktKAnlRauBDy8lUkMHNgkRmyUCgC0me7wuag(EbfkMAf0RG5Y)rLY0bYtSHM95damDqdXm80qzLb3EFkwc7tfcMkfALMHy3IcWW3lOqX0dIz4PHYkdMlNbhndXUffGHVxqHIjsttOXuGZRsEyWW(CSvzDCnk2SGfcBnlRauBDy8lU69wb96cQ5e2Nkemvk0knBcnoqsttOXuGZRsEyWW(CSvzDC9FPPzaPLGjsTMLvaQTom(fxpmyyFoMl8TYuPqRuMi1kOxP4Hbd7ZX8fGS)WvMg9OOcAqXOyZcwiK00eAmf48QKhgmSphBvwhx)xAAgqAjyIuRzzfGARdJFXv5pTvqVsXddg2NJ5laz)HRmn6rrf0ik2SGfcBqXfuZjiAjGA8ximBcnoqsttOXuGZRsEyWW(CSvzDC9FPPzaPLGjsTMLvaQTom(fx9ERGELIhgmSphZxaY(dxzA0JIkOruSzble2yb1CcIwcOg)fcZMqJdSX)stNPm4jw0xazGAIxT79guunowA(i4iDGvkJL95yI00eAmf48QKhgmSphBvwhx)xAAgqAjyIuRzzfGARdJFXvV3kOxP4Hbd7ZX8fGS)WvMg9OOcAefBwWcHnwqnNGOLaQXFHWSj04aBSaXdgvrklF2Jvj2qZOE5jRAOghlnFeCKoWkLXY(CmrAAcnMcCEvYddg2NJTkRJR)lnndiTemrQ1SScqT1HXV4QygEAOSYjueDtJIk7pCndXUffGHVxqHIPwb96Hbd7ZX8fGS)WvMg9OOcinnHgtboVkPW4CMj0ykgpaARY64QcJ6fQasttOXuGZRskmoNzcnMIXdG2QSoUoufPwb9QSu8WGH95y(cq2F4ktJEuubnwqnNW(uHGPsHwPztOXbkJxEj7Hbd7ZX8fGS)WvMg9OOcA8V00zGhdMydnZQk8eCtJPY3LgYsr14yP5LHseYaXINPYyzFoM8YR)LMoVmuIqgiw8mv(UiJmKMMqJPaNxLm6l8bet1kOx)da0GoO6rzqSBrbE4ujKQirAAcnMcCEvsHX5mtOXumEa0wL1X1zble2cOWqORY3kOx1HkvoMfZWtdLfOHgD8b6acuMkfALY0OJKMMqJPaNxLmntVvqVcrAic8yFosAAcnMcCEvsHX5mtOXumEa0wL1XvXCGLvkZ(bpuPTakme6Q8Tc6vWC5)OszQW5azrDeuhOPXuE5fyU8FuPmDG8eBOzF(aath4LxG5Y)rLYIP)nL1XuOMgt5LxI5alR0CHc4WhyI00eAmf48QKldLiKbIfpt1kOxpmyyFoMVaK9hUY0OhfvqJ)LMod8yWeBOzwvHNGBAmv(UqAAcnMcCEvYLrJPAf0RYsXddg2NJ5laz)HRmn6rrf04WGH95yUW3ktLcTszI0dufPC3E3qJo2oDabktLcTszA0rV8cmx(pQugI0rHj2IXnfBCyWW(Cmx4BLPsHwPmr6bkuUjJxEj7Hbd7ZX8fGS)WvMg9OOcA8V00zGhdMydnZQk8eCtJPY3fzinnHgtboVkPW4CMj0ykgpaARY64QkfALYaOExinnHgtboVkzc7tfcgqHyrv90kOxLLIWBH0dKkMPm40qmbyGGAWzdndCxqymqg427tff1ghgmSphZf(wzQuOvktKAxcugV8s2fuZjSpviyQuOvA2eACGnwqnNW(uHGPsHwPzi2TOap8msivrk3T3YqAAcnMcCEvsHX5SeeTeqn(lecAf0RhgmSphZxaY(dxzA0JIkOHygEAOSYGBVpflH9PcbtLcTsZqSBrby47fuOyQ9tpL00eAmf48QKcJZzjiAjGA8xie0kOxP4Hbd7ZX8fGS)WvMg9OOcAi7Hbd7ZXCHVvMkfALYeP2p17p3BsifH3cPhivmtzWPHycWab1GZgAg4UGWyGmWT3NkkQYqAAcnMcCEvYLHseYaXINPAf0Ru8WGH95y(cq2F4ktJEuubn(xA6mLbpXI(cidut8QD5B8V005e2NkemXaXmqnXRhOqsttOXuGZRs(doceZfsfz)P)riOvqV(V00zvk0knNgkRghgmSphZf(wzQuOvktKA3BKMMqJPaNxLm6l8bet1kOxnHghidlShiOD5plR8sOACS0mWeWGoeyIbMlhKXY(CmjtJ)LMotzWtSOVaYa1eVAF9zA8V00zvk0knNgkRghgmSphZf(wzQuOvktKA3BnK9FPPZrFHpG4azlJILggpNgklV8cSGCotnivub5OVWhqmLe6T2x)xA6C0x4dioq2YOyPHXZhYldPPj0ykW5vjJ(cFaXuTc6vtOXbYWc7bcA)0g)lnDMYGNyrFbKbQjE1(6Z04FPPZQuOvAonuwnomyyFoMl8TYuPqRuMi1U3Aqr4Tq6bsfZrFHpG4azlJILggVHSuunowAMgoDM6bzapwAOeKXY(Cm5Lxj8FPPZ0WPZupid4XsdLG8DrgsttOXuGZRsg9f(aIPAf0RMqJdKHf2de0U8NLvEjunowAgycyqhcmXaZLdYyzFoMKPX)stNPm4jw0xazGAIxTV(mNLLcLq14yPzWC5mXuPBOzSSphtY04FPPZQuOvAonuwnomyyFoMl8TYuPqRuMi1U3Ai7)stNJ(cFaXbYwgflnmEonuwE5fyb5CMAqQOcYrFHpGykj0BTV(V005OVWhqCGSLrXsdJNpKxgsttOXuGZRsg9f(aIPAf0RMqJdKHf2de0(Pn(xA6mLbpXI(cidut8Q91N5SSuOeQghlndMlNjMkDdnJL95ysMg)lnDwLcTsZPHYQXHbd7ZXCHVvMkfALYeP29wdkcVfspqQyo6l8behiBzuS0W4nKLIQXXsZ0WPZupid4XsdLGmw2NJjV8kH)lnDMgoDM6bzapwAOeKVlYqAAcnMcCEvsQWOpbez0iN61GPwb96FaGgA0rMoSuGpqHEN00eAmf48QKGBVpf7i4iDGvQvqV(haOHgDKPdlf4dNk3innHgtboVkj427tXsyFQqWuPqR0wb96FaGgA0rMoSuGpiV3innHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyA1BKMMqJPaNxLe4XsdLS)W1wb9kyUCgWJbtp4TgWBH0dKkM)ghblrcHa2)cROOYedeB8V005VXrWsKqiG9VWkkQmXaXme7wuGh8gPPeanX9Sq0sa14VqiG4misCghIwskXzcnoWwexnexHyI40H4a2bsCapgmbinnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9vkSHSlOMtq0sa14Vqy2eACGE51cQ5e2Nkemvk0knBcnoqzinnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9v5B8V005cvpiKTmq1457sdXm80qzLfgNZsq0sa14VqiidXUffO9tLqQIuUBVjnnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9v5B8V00zkdEIf9fqgOM4v7N2yb1CcIwcOg)fcZqSBrbA37zVDwyaLPrhpBcnMkdU9(uSe2Nkemvk0knlmGY0OJnwqnNGOLaQXFHWme7wuGh8E2BNfgqzA0XZMqJPYGBVpflH9PcbtLcTsZcdOmn64zz9E7Y9jlf(CWC5mGhdMKrgj0eAmvg4XsdLS)W1SWaktJo24WGH95yUW3ktLcTszI0dufPC3E3qJo2oDabktLcTszA0XNtvKYD7nPPj0ykW5vjfgNZmHgtX4bqBvwhxfZbwwPm7h8qL2cOWqORY3kOxPOyoWYknFGL6rkK0uUlupZvjoFtad6qGjIZFUCqlIZFUCIZxHXlK4caXbu4uuriXPESI4EwSp1F4AlIdmexOeNhdqCgX5jO6bHe3cmgyOsjnnHgtboVkjyUCgqHXlSvqVsr14yPzGjGbDiWedmxoiJL95yI00FbReX9SyFQqqCTXaraXrpqIZFUCIZ3JbtaI7wAWjUtKcTsjoXm80qzrCbG4e8bGeNoeheTKusttOXuGZRsMW(u)HRTc61)LMoNW(uHGjgiMHOj0gG5Yzapgm9af04WGH95yUW3ktLcTszIu7N6DsZN9cJIkXDIuOvkXbq9U0I4alyLiUNf7tfcIRngicio6bsC(ZLtC(EmycqAAcnMcCEvYe2N6pCTvqV(V005e2NkemXaXmenH2amxod4XGPhOGghgmSphZf(wzQuOvktKEq(tjnnHgtboVkzc7t9hU2kOx)xA6Cc7tfcMyGygIMqBaMlNb8yW0duqdz)xA6Cc7tfcMyGygOM4v7N6LxQXXsZatad6qGjgyUCqgl7ZXKmKMMqJPaNxLmH9P(dxBf0Rauz)PUGSgi8u5g70frdWC5mGhdMEGcAiRSpZZbZLZaEmysgj0eAmvg4XsdLS)W1m(gfxfzA0X2xqnNGOLaQXFHWme7wuGNBcnMk7XQeBOzuV8Kvz8nkUkY0OJp3eAmvoH9P(dxZ4BuCvKPrhLPX)stNtyFQqWedeZa1eVAFvEsttOXuGZRsMW(u)HRTc61)LMoNW(uHGjgiMHOj0gG5Yzapgm9af0WeACGmSWEGG2LN00eAmf48QKG5YzafgVqsttOXuGZRskmoNzcnMIXdG2QSoUkMdSSsz2p4HkL0ucGM4KoxItyfXrfvI7BIxeNoeN3io)5YjoFpgmbiUpspqK4EwiAjGA8xieqCIz4PHYI4caXbrljTfXf6taIBEzsjoDioWcwjIt9GDIRgkjnnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9vkSXHbd7ZXCHVvMkfALYeP2p1BnKvnowAoH9PcbtyCEuuZyzFoM8YlXm80qzLfgNZsq0sa14VqiidXUffODzL1Bphmxod4XGjzKqtOXuzGhlnuY(dxZ4BuCvKPrhL5Sj0yQShRsSHMr9YtwLX3O4QitJokdPPj0ykW5vjtZ0BjKk4itnivubRY3kOxHinebESphBOrhBNoGaLPsHwPmn6iPPCIaK4EwSp1F4kXf0eN05(eejoQtuujoDio(aqI7zX(uHG4AJbIehqnXlqlIdpWI4cAIl0NsehLgqrIZioWC5ehWJbtzsttOXuGZRsMW(u)HRTc61)LMoNW(uHGjgiMHOj0g)lnDoH9PcbtmqmdXUff4b5ptvKYD7Te(V005e2NkemXaXmqnXlsttOXuGZRsc8yPHs2F4kPjPPj0ykqgWhkzkmQxOcwVaKfk2BvwhxbZLZrvJIkdE)sBjKk4itnivubRY3kOxpmyyFoM)xAAgqAjyI0dQbPIAofa1kb226TNl7Psivrk3T3s4Hbd7ZX8fGS)WvMg9OOcKH00eAmfid4dLmfg1lubNxL8cqwOyVvzDCfCRpFMeZ6O6rkqBf0RhgmSphZ)lnndiTemr6b1GurnNcGALaBB92zzpvcpmyyFoMVaK9hUY0OhfvGmKMMqJPazaFOKPWOEHk48QKxaYcf7TkRJRyFrkenoBGPYkb2kOxpmyyFoM)xAAgqAjyI0dYQgKkQ5uauReyBR3K5S8NEw2tLWddg2NJ5laz)HRmn6rrfidPjPPj0ykqwmhyzLYSFWdv6kyUCgC0wb9QSG5Y)rLY0bYtSHM95damDGxEbVfspqQyoHctAuuzG5YzatfEqUmnwqnNW(uHGPsHwPztOXbsAAcnMcKfZbwwPm7h8qLEEvsWC5m4OTc6vWC5)OszQW5azrDeuhOPXunOi8wi9aPI5ekmPrrLbMlNbmv4b5nK9WGH95yUW3ktLcTszI0dN6DV86WGH95yUW3ktLcTszIu7uO3LH00eAmfilMdSSsz2p4Hk98QKG5YzWrBf0RG5Y)rLYug8eZZTuMAcneGgueElKEGuXCcfM0OOYaZLZaMk8G8guCb1Cc7tfcMkfALMnHghyJddg2NJ5cFRmvk0kLjsTlVCJ00eAmfilMdSSsz2p4Hk98QKjueDtJIk7pCTLqQGJm1GurfSkFRGEThLCPgKkQzpOXvp5fH2kOxP4Hbd7ZX8fGS)WvMg9OOcAaMl)hvkZrlX(sz4BRVWXgYUGAoH9PcbtLcTsZMqJdSbyUCgWJbtpCQxErXfuZjSpviyQuOvA2eACGnomyyFoMl8TYuPqRuMi1of4DzinnHgtbYI5alRuM9dEOspVkzcfr30OOY(dxBjKk4itnivubRY3kOx7rjxQbPIA2dAC1tErOTc6vkEyWW(CmFbi7pCLPrpkQGgG5Y)rLYVWJOaSzKtI8OO2q2fuZjSpviyQuOvA2eACGE5ffxqnNW(uHGPsHwPztOXb24WGH95yUW3ktLcTszIu7uG3LH00eAmfilMdSSsz2p4Hk98QKjueDtJIk7pCTLqQGJm1GurfSkFRGELIhgmSphZxaY(dxzA0JIkOHSG5Y)rLY0dKk(hyHmiEGWabE5LSG5Y)rLYhd30GJmWWpWsBqrWC5)Os5x4rua2mYjrEuuLrMguCb1Cc7tfcMkfALMnHghiPPj0ykqwmhyzLYSFWdv65vjtOi6Mgfv2F4AlHubhzQbPIkyv(wb96Hbd7ZX8fGS)WvMg9OOcAilfvJJLMxgkridelEMYlVeZWtdLvEzOeHmqS4zQme7wuGhmHgtLtOi6Mgfv2F4AgFJIRImn6OmnOOygEAOSYGBVpflH9PcbtLcTsZ3LgYUGAoH9PcbtLcTsZqSBrbEqU5LxIz4PHYkdU9(uSe2Nkemvk0kndXUffGHVxqHIPhOqVldPPj0ykqwmhyzLYSFWdv65vjP5iWJaA0ARGEfmx(pQu(y4MgCKbg(bwAJ)LMoFmCtdoYad)alnNgkRwrPieExuwqV(V005JHBAWrgy4hyP57cPPj0ykqwmhyzLYSFWdv65vjbI5cJIktd1d2kOxbZL)JkLft)BkRJPqnnMQXcQ5e2Nkemvk0knBcnoqsttOXuGSyoWYkLz)GhQ0ZRsceZfgfvMgQhSvqVsrWC5)OszX0)MY6ykutJPinnHgtbYI5alRuM9dEOspVkz0xWkffvMWudOWzXd2kOxxqnNW(uHGPsHwPztOXb2amxod4XGPvVtAsAAcnMcK9SWuyuVaRxaYcf7TkRJRGOOVCgvULcthiGH9ph7KMMqJPazplmfg1lW5vjVaKfk2BvwhxbrrF5mdSeqRuad7Fo2jnjnnHgtbYdvrA9JqacFffvsttOXuG8qvKoVk5NptIrFHsjnnHgtbYdvr68QK0be)8zsKMMqJPa5HQiDEvYlazHIDaPjPPj0ykqEwWcHRG5YzWrBf0RG5Y)rLYuHZbYI6iOoqtJPinnHgtbYZcwi88QKfQEqiBzGQXjnnHgtbYZcwi88QKuHrFciYOro1RbtKMMqJPa5zbleEEvsWT3NIDeCKoWkrAAcnMcKNfSq45vjbES0qj7pCTvqVcMlNb8yW0dERHygEAOSYcJZzjiAjGA8xieKVlKMMqJPa5zbleEEvsGhlnuY(dxBf0RhgmSphZxaY(dxzA0JIkObyUCgWJbtp4Tg)lnD(BCeSejecy)lSIIktmqmdut86bkG00eAmfiplyHWZRskmoNLGOLaQXFHqaPjPPj0ykqE5crwY6gvKPWOEbwVaKfk2Bvwhxtq0s0bezhiaGCsttOXuG8YfISK1nQitHr9cCEvYlazHI9wL1XvicMYkLbracpMasAAcnMcKxUqKLSUrfzkmQxGZRsEbiluS3QSoUAqHNqrHcyrrfRBOszIbIKMMqJPa5LlezjRBurMcJ6f48QKxaYcf7TkRJRIb0dbJk3sHPdeWGiykthiPPj0ykqE5crwY6gvKPWOEboVk5fGSqXERY64AcIwIoGi7abaKtAAcnMcKxUqKLSUrfzkmQxGZRsEbiluS3QSoUcMlNfuRqriPPj0ykqE5crwY6gvKPWOEboVk5fGSqXERY64kvU0fpSHMzaq0dUPXuTc6vtOXbYWc7bcwLN00eAmfiVCHilzDJkYuyuVaNxL8cqwOyVvzDCnzWx9zkwcfVylxfIabwcK00eAmfiVCHilzDJkYuyuVaNxL8cqwOyVvzDCf)tbMlNDeaK00eAmfiVCHilzDJkYuyuVaNxL8cqwOyVvzDC9wcpwuyIrLBPW0bcyapM4fhbKMKMMqJPazfg1lubRhgmSphBvwhxVaK9V00mfg1lubTom(fxLLIhgmSphZxaY(dxzA0JIkOXcQ5e2Nkemvk0knBcnoqz8YlzpmyyFoMVaK9hUY0OhfvqJ)LMod8yWeBOzwvHNGBAmv(UidPPj0ykqwHr9cvW5vjVaKfk2BvwhxbcdcydnJgAkclJZakmOXwb9kf)xA6mqyqaBOz0qtryzCgqHbnYOG8DH00eAmfiRWOEHk48QKxaYcf7TkRJRaHbbSHMrdnfHLXzafg0yRGE9FPPZaHbbSHMrdnfHLXzafg0iJcY3LglOMtyFQqWuPqR0Sj04ajnnHgtbYkmQxOcoVk5fGSqXERY64kWJLgkXeBGF2qZ0b2XsBf0RhgmSphZ)lnndiTemr6HtpL00eAmfiRWOEHk48QKxaYcf7TkRJRuHrNHcESaWwb96Hbd7ZX8)stZaslbtKEqotAAcnMcKvyuVqfCEvYlazHI9wL1XvQWOZqbpwayRGE9WGH95y(FPPzaPLGjspiNjnnHgtbYkmQxOcoVkPW4CMj0ykgpaARY64QNfMcJ6fOvqVQghlnNW(uHGjMcC7lAmvgl7ZXuJddg2NJ5cFRmvk0kLjspCQ3jnLtPPrHcio1JPeNcTdKtCa(qjxkXrdNoXPEqItnivujoikbFdisCwkfAmLXBrCaCXGMIeNhRs8OOsAAcnMcKvyuVqfCEvsHX5mtOXumEa0wL1XvaFOKPWOEHkG00eAmfiRWOEHk48QKxaYcf7TkRJRZbcP5dLrrLzv0nMWOITc61ddg2NJ5laz)lnntHr9cvaPPj0ykqwHr9cvW5vjVaKfk2Bb4JUQWOEHQ8Tc6vfg1luZYN9ya2fGS)LMUXHbd7ZX8fGS)LMMPWOEHkG00eAmfiRWOEHk48QKxaYcf7Ta8rxvyuVq90wb9QcJ6fQ5tZEma7cq2)st34WGH95y(cq2)stZuyuVqfqAAcnMcKvyuVqfCEvsHX5mtOXumEa0wL1X1LlezjRBurMcJ6fOvqVQrhBNoGaLPsHwPmn6yJddg2NJ5)LMMbKwcMi1(PEN0K00eAmfiRsHwPmaQ3L1cvpiKTmq14Tc61ddg2NJ5cFRmvk0kLjspiV3innHgtbYQuOvkdG6D58QKuHrFciYOro1RbtTc61ddg2NJ5cFRmvk0kLjspiVC(5YAcnMkdU9(uSe2Nkemvk0knJVrXvrMgD8Sj0yQmWJLgkz)HRz8nkUkY0OJY0qwXm80qzLfgNZsq0sa14VqiidXUff4b5LZpxwtOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLb3EFk2rWr6aRugFJIRImn64ztOXuzGhlnuY(dxZ4BuCvKPrhLXlVwqnNGOLaQXFHWme7wuG2pmyyFoMl8TYuPqRuMiD2eAmvgC79PyjSpviyQuOvAgFJIRImn6OmKMMqJPazvk0kLbq9UCEvsWT3NIDeCKoWk1kOxL9WGH95yUW3ktLcTszI0dY7TNlRj0yQm427tXsyFQqWuPqR0m(gfxfzA0rzAiRygEAOSYcJZzjiAjGA8xieKHy3Ic8G8E75YAcnMkdU9(uSe2Nkemvk0knJVrXvrMgD8Sj0yQm427tXocoshyLY4BuCvKPrhLXlVwqnNGOLaQXFHWme7wuG2pmyyFoMl8TYuPqRuMiD2eAmvgC79PyjSpviyQuOvAgFJIRImn6OmY4LxYsr4Tq6bsfZugCAiMamqqn4SHMbUlimgidC79PIIAJddg2NJ5cFRmvk0kLjsTtbExgsttOXuGSkfALYaOExoVkPW4CwcIwcOg)fcbTc61ddg2NJ5cFRmvk0kLjspi)PpxwtOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLbES0qj7pCnJVrXvrMgDugsttOXuGSkfALYaOExoVkj427tXsyFQqWuPqR0wb9QgDSD6acuMkfALY0OJnKDb1CcIwcOg)fcZMqJdSXcQ5eeTeqn(leMHy3Ic0Uj0yQm427tXsyFQqWuPqR0m(gfxfzA0rzAilfvJJLMb3EFk2rWr6aRugl7ZXKxETGA(i4iDGvkBcnoqzAilyUCgWJbtRE3lVKDb1CcIwcOg)fcZMqJdSXcQ5eeTeqn(leMHy3Ic8Gj0yQm427tXsyFQqWuPqR0m(gfxfzA0XZMqJPYapwAOK9hUMX3O4QitJokJxEj7cQ5JGJ0bwPSj04aBSGA(i4iDGvkdXUff4btOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLbES0qj7pCnJVrXvrMgDugV8s2)LMotfg9jGiJg5uVgmLVln(xA6mvy0NaImAKt9AWugIDlkWdMqJPYGBVpflH9PcbtLcTsZ4BuCvKPrhpBcnMkd8yPHs2F4AgFJIRImn6OmYS95bqb7t2(a(qjtHr9cvW(K9JYVpz7JL95yAlXTFzDC7dMlNJQgfvg8(LU9fsfCKPgKkQG9JYV9nHgtT9bZLZrvJIkdE)s3(cyOimST)Hbd7ZX8)stZaslbtKiUhio1GurnNcGALajojjoVrCpN4KL4oL4KqIJQiL72BItcjUddg2NJ5laz)HRmn6rrfqCYS19JNUpz7JL95yAlXTVj0yQTp4wF(mjM1r1JuGU9fWqryyB)ddg2NJ5)LMMbKwcMirCpqCQbPIAofa1kbsCssCEJ4otCYsCNsCsiXDyWW(CmFbi7pCLPrpkQaItMTFzDC7dU1NptIzDu9ifOBD)ifUpz7JL95yAlXTVj0yQTp2xKcrJZgyQSsGBFbmueg22)WGH95y(FPPzaPLGjse3deNSeNAqQOMtbqTsGeNKeN3ioziUZeN8NsCNjozjUtjojK4omyyFoMVaK9hUY0OhfvaXjZ2VSoU9X(IuiAC2atLvcCRBD77zHPWOEb2NSFu(9jBFSSphtBjU9lRJBFqu0xoJk3sHPdeWW(NJ9TVj0yQTpik6lNrLBPW0bcyy)ZX(w3pE6(KTpw2NJPTe3(L1XTpik6lNzGLaALcyy)ZX(23eAm12hef9LZmWsaTsbmS)5yFRBD7lMdSSsz2p4HkDFY(r53NS9XY(CmTL42xadfHHT9LL4aZL)JkLPdKNydn7Zhay6Gmw2NJjIZlVio4Tq6bsfZjuysJIkdmxodyQWdYZyzFoMioziUge3cQ5e2Nkemvk0knBcnoWTVj0yQTpyUCgC0TUF809jBFSSphtBjU9fWqryyBFWC5)OszQW5azrDeuhOPXuzSSphtexdIJIeh8wi9aPI5ekmPrrLbMlNbmv4b5zSSphtexdItwI7WGH95yUW3ktLcTszIeX9aXDQ3joV8I4omyyFoMl8TYuPqRuMirCTtCuO3joz2(MqJP2(G5YzWr36(rkCFY2hl7ZX0wIBFbmueg22hmx(pQuMYGNyEULYutOHaKXY(CmrCnioksCWBH0dKkMtOWKgfvgyUCgWuHhKNXY(CmrCnioksClOMtyFQqWuPqR0Sj04ajUge3Hbd7ZXCHVvMkfALYejIRDItE5223eAm12hmxodo6w3psb7t2(yzFoM2sC7BcnMA7Nqr0nnkQS)W1TVagkcdB7trI7WGH95y(cq2F4ktJEuubexdIdmx(pQuMJwI9LYW3wFHJzSSphtexdItwIBb1Cc7tfcMkfALMnHghiX1G4aZLZaEmyI4EG4oL48YlIJIe3cQ5e2Nkemvk0knBcnoqIRbXDyWW(Cmx4BLPsHwPmrI4AN4OaVtCYS9fsfCKPgKkQG9JYV19JEBFY2hl7ZX0wIBFtOXuB)ekIUPrrL9hUU9fWqryyBFksChgmSphZxaY(dxzA0JIkG4AqCG5Y)rLYVWJOaSzKtI8OOMXY(CmrCniozjUfuZjSpviyQuOvA2eACGeNxErCuK4wqnNW(uHGPsHwPztOXbsCniUddg2NJ5cFRmvk0kLjsex7ehf4DItMTVqQGJm1GurfSFu(TUF8z2NS9XY(CmTL423eAm12pHIOBAuuz)HRBFbmueg22NIe3Hbd7ZX8fGS)WvMg9OOciUgeNSehyU8FuPm9aPI)bwidIhimqqgl7ZXeX5LxeNSehyU8FuP8XWnn4idm8dS0mw2NJjIRbXrrIdmx(pQu(fEefGnJCsKhf1mw2NJjItgItgIRbXrrIBb1Cc7tfcMkfALMnHgh42xivWrMAqQOc2pk)w3pkN3NS9XY(CmTL423eAm12pHIOBAuuz)HRBFbmueg22)WGH95y(cq2F4ktJEuubexdItwIJIeNACS08YqjczGyXZuzSSphteNxErCIz4PHYkVmuIqgiw8mvgIDlkaX9aXzcnMkNqr0nnkQS)W1m(gfxfzA0rItgIRbXrrItmdpnuwzWT3NILW(uHGPsHwP57cX1G4KL4wqnNW(uHGPsHwPzi2TOae3deNCJ48YlItmdpnuwzWT3NILW(uHGPsHwPzi2TOam89ckumrCpqCuO3joz2(cPcoYudsfvW(r536(r52(KTpw2NJPTe3(MqJP2(0Ce4ranAD7lGHIWW2(G5Y)rLYhd30GJmWWpWsZyzFoMiUge3)stNpgUPbhzGHFGLMtdL12pkfHW7IYc6T))stNpgUPbhzGHFGLMVlBD)Oe4(KTpw2NJPTe3(cyOimSTpyU8FuPSy6FtzDmfQPXuzSSphtexdIBb1Cc7tfcMkfALMnHgh423eAm12hiMlmkQmnup4w3pkV33NS9XY(CmTL42xadfHHT9PiXbMl)hvklM(3uwhtHAAmvgl7ZX023eAm12hiMlmkQmnup4w3pkV87t2(yzFoM2sC7lGHIWW2(lOMtyFQqWuPqR0Sj04ajUgehyUCgWJbte3kX59TVj0yQTF0xWkffvMWudOWzXdU1TU9vPqRuga17Y(K9JYVpz7JL95yAlXTVagkcdB7FyWW(Cmx4BLPsHwPmrI4EG4K3BBFtOXuB)cvpiKTmq14BD)4P7t2(yzFoM2sC7lGHIWW2(hgmSphZf(wzQuOvktKiUhio5LZe3ZjozjotOXuzWT3NILW(uHGPsHwPz8nkUkY0OJe3zIZeAmvg4XsdLS)W1m(gfxfzA0rItgIRbXjlXjMHNgkRSW4CwcIwcOg)fcbzi2TOae3deN8YzI75eNSeNj0yQm427tXsyFQqWuPqR0m(gfxfzA0rI7mXzcnMkdU9(uSJGJ0bwPm(gfxfzA0rI7mXzcnMkd8yPHs2F4AgFJIRImn6iXjdX5Lxe3cQ5eeTeqn(leMHy3IcqCTtChgmSphZf(wzQuOvktKiUZeNj0yQm427tXsyFQqWuPqR0m(gfxfzA0rItMTVj0yQTpvy0NaImAKt9AW0w3psH7t2(yzFoM2sC7lGHIWW2(YsChgmSphZf(wzQuOvktKiUhio59gX9CItwIZeAmvgC79PyjSpviyQuOvAgFJIRImn6iXjdX1G4KL4eZWtdLvwyColbrlbuJ)cHGme7wuaI7bItEVrCpN4KL4mHgtLb3EFkwc7tfcMkfALMX3O4QitJosCNjotOXuzWT3NIDeCKoWkLX3O4QitJosCYqCE5fXTGAobrlbuJ)cHzi2TOaex7e3Hbd7ZXCHVvMkfALYejI7mXzcnMkdU9(uSe2Nkemvk0knJVrXvrMgDK4KH4KH48YlItwIJIeh8wi9aPIzkdonetagiOgC2qZa3fegdKbU9(urrnJL95yI4AqChgmSphZf(wzQuOvktKiU2jokW7eNmBFtOXuBFWT3NIDeCKoWkT19JuW(KTpw2NJPTe3(cyOimST)Hbd7ZXCHVvMkfALYejI7bIt(tjUNtCYsCMqJPYGBVpflH9PcbtLcTsZ4BuCvKPrhjUZeNj0yQmWJLgkz)HRz8nkUkY0OJeNmBFtOXuBFHX5SeeTeqn(lec26(rVTpz7JL95yAlXTVagkcdB7RrhjU2jo6acuMkfALY0OJexdItwIBb1CcIwcOg)fcZMqJdK4AqClOMtq0sa14VqygIDlkaX1oXzcnMkdU9(uSe2Nkemvk0knJVrXvrMgDK4KH4AqCYsCuK4uJJLMb3EFk2rWr6aRugl7ZXeX5Lxe3cQ5JGJ0bwPSj04ajoziUgeNSehyUCgWJbte3kX5DIZlViozjUfuZjiAjGA8ximBcnoqIRbXTGAobrlbuJ)cHzi2TOae3deNj0yQm427tXsyFQqWuPqR0m(gfxfzA0rI7mXzcnMkd8yPHs2F4AgFJIRImn6iXjdX5LxeNSe3cQ5JGJ0bwPSj04ajUge3cQ5JGJ0bwPme7wuaI7bIZeAmvgC79PyjSpviyQuOvAgFJIRImn6iXDM4mHgtLbES0qj7pCnJVrXvrMgDK4KH48YlItwI7FPPZuHrFciYOro1Rbt57cX1G4(xA6mvy0NaImAKt9AWugIDlkaX9aXzcnMkdU9(uSe2Nkemvk0knJVrXvrMgDK4otCMqJPYapwAOK9hUMX3O4QitJosCYqCYS9nHgtT9b3EFkwc7tfcMkfALU1TU9tiTD56(K9JYVpz7JL95yAlXTFcbcySOXuBF503O4QyI4WdekL40OJeN6bjotOdK4caXzhwWTphZBFtOXuBFWcY5m(iET19JNUpz7BcnMA7lmoNrJCp3sr42hl7ZX0wIBD)ifUpz7BcnMA7BVrMoaW2hl7ZX0wIBD)ifSpz7BcnMA7NWJ5czDJAi2(yzFoM2sCR7h92(KTpw2NJPTe3(ZY2hG623eAm12)WGH9542)W4xC7lMHNgkRm427tXsyFQqWuPqR0me7wuag(EbfkM2(cyOimSTpfjoWC5)Osz6a5j2qZ(8baMoiJL95yI48YlItmdpnuwzWT3NILW(uHGPsHwPzi2TOam89ckumrCTtCIz4PHYkdMlNbhndXUffGHVxqHIPT)HbzL1XTFHVvMkfALYePTUF8z2NS9XY(CmTL42Fw2(au3(MqJP2(hgmSph3(hg)IBFXm80qzLbZLZGJMHy3IcWW3lOqX02xadfHHT9bZL)JkLPdKNydn7Zhay6Gmw2NJjIRbXjMHNgkRm427tXsyFQqWuPqR0me7wuag(EbfkMiUhioXm80qzLbZLZGJMHy3IcWW3lOqX02)WGSY642VW3ktLcTszI0w3pkN3NS9XY(CmTL42Fw2(au3(MqJP2(hgmSph3(hg)IB)ddg2NJ5cFRmvk0kLjsBFbmueg22NIe3Hbd7ZX8fGS)WvMg9OOciUgehfjUOyZcwiC7FyqwzDC7)V00mG0sWePTUFuUTpz7JL95yAlXT)SS9bOU9nHgtT9pmyyFoU9pm(f3(YF62xadfHHT9PiXDyWW(CmFbi7pCLPrpkQaIRbXffBwWcHexdIJIe3cQ5eeTeqn(leMnHgh42)WGSY642)FPPzaPLGjsBD)Oe4(KTpw2NJPTe3(ZY2hG623eAm12)WGH9542)W4xC779TVagkcdB7trI7WGH95y(cq2F4ktJEuubexdIlk2SGfcjUge3cQ5eeTeqn(leMnHghiX1G4(xA6mLbpXI(cidut8I4AN48oX1G4OiXPghlnFeCKoWkLXY(CmT9pmiRSoU9)xAAgqAjyI0w3pkV33NS9XY(CmTL42Fw2(au3(MqJP2(hgmSph3(hg)IBFVV9fWqryyBFksChgmSphZxaY(dxzA0JIkG4AqCrXMfSqiX1G4wqnNGOLaQXFHWSj04ajUge3cepyufPS8zpwLydnJ6LNSI4AqCQXXsZhbhPdSszSSphtB)ddYkRJB))LMMbKwcMiT19JYl)(KTpw2NJPTe3(ZY2hG623eAm12)WGH9542)W4xC7lMHNgkRCcfr30OOY(dxZqSBrby47fuOyA7lGHIWW2(hgmSphZxaY(dxzA0JIky7FyqwzDC7)V00mG0sWePTUFu(t3NS9XY(CmTL423eAm12xyCoZeAmfJhaD7ZdGYkRJBFfg1lubBD)O8u4(KTpw2NJPTe3(cyOimSTVSehfjUddg2NJ5laz)HRmn6rrfqCniUfuZjSpviyQuOvA2eACGeNmeNxErCYsChgmSphZxaY(dxzA0JIkG4AqC)lnDg4XGj2qZSQcpb30yQ8DH4AqCYsCuK4uJJLMxgkridelEMkJL95yI48YlI7FPPZldLiKbIfptLVleNmeNmBFtOXuBFHX5mtOXumEa0TppakRSoU9hQI0w3pkpfSpz7JL95yAlXTVagkcdB7)haG4AqC0bvpkdIDlkaX9aXDkXjHehvrA7BcnMA7h9f(aIP26(r592(KTpw2NJPTe3(cyOimSTVouPYXSygEAOSaexdItJosCpqC0beOmvk0kLPrh3(afgcD)O8BFtOXuBFHX5mtOXumEa0TppakRSoU9NfSq4w3pk)ZSpz7JL95yAlXTVagkcdB7drAic8yFoU9nHgtT9tZ036(r5LZ7t2(yzFoM2sC7lGHIWW2(G5Y)rLYuHZbYI6iOoqtJPYyzFoMioV8I4aZL)JkLPdKNydn7Zhay6Gmw2NJjIZlVioWC5)OszX0)MY6ykutJPYyzFoMioV8I4eZbwwP5cfWHpW02hOWqO7hLF7BcnMA7lmoNzcnMIXdGU95bqzL1XTVyoWYkLz)GhQ0TUFuE52(KTpw2NJPTe3(cyOimST)Hbd7ZX8fGS)WvMg9OOciUge3)stNbEmyIn0mRQWtWnnMkFx2(MqJP2(ldLiKbIfptT19JYlbUpz7JL95yAlXTVagkcdB7llXrrI7WGH95y(cq2F4ktJEuubexdI7WGH95yUW3ktLcTszIeX9aXrvKYD7nX1G40OJex7ehDabktLcTszA0rIZlVioWC5)OszishfMylg3umJL95yI4AqChgmSphZf(wzQuOvktKiUhiokuUrCYqCE5fXjlXDyWW(CmFbi7pCLPrpkQaIRbX9V00zGhdMydnZQk8eCtJPY3fItMTVj0yQT)YOXuBD)4PEFFY2hl7ZX0wIBFtOXuBFHX5mtOXumEa0TppakRSoU9vPqRuga17Yw3pEQ87t2(yzFoM2sC7lGHIWW2(YsCuK4G3cPhivmtzWPHycWab1GZgAg4UGWyGmWT3NkkQzSSphtexdI7WGH95yUW3ktLcTszIeX1oXjbsCYqCE5fXjlXTGAoH9PcbtLcTsZMqJdK4AqClOMtyFQqWuPqR0me7wuaI7bI7ziojK4Oks5U9M4Kz7BcnMA7NW(uHGbuiwuvpBD)4PNUpz7JL95yAlXTVagkcdB7FyWW(CmFbi7pCLPrpkQaIRbXjMHNgkRm427tXsyFQqWuPqR0me7wuag(EbfkMiU2jUtpD7BcnMA7lmoNLGOLaQXFHqWw3pEkfUpz7JL95yAlXTVagkcdB7trI7WGH95y(cq2F4ktJEuubexdItwI7WGH95yUW3ktLcTszIeX1oXDQ3jUNtCEJ4KqIJIeh8wi9aPIzkdonetagiOgC2qZa3fegdKbU9(urrnJL95yI4Kz7BcnMA7lmoNLGOLaQXFHqWw3pEkfSpz7JL95yAlXTVagkcdB7trI7WGH95y(cq2F4ktJEuubexdI7FPPZug8el6lGmqnXlIRDItEIRbX9V005e2NkemXaXmqnXlI7bIJc3(MqJP2(ldLiKbIfptT19JN6T9jBFSSphtBjU9fWqryyB))LMoRsHwP50qzrCniUddg2NJ5cFRmvk0kLjsex7eN32(MqJP2()GJaXCHur2F6Fec26(XtFM9jBFSSphtBjU9fWqryyBFtOXbYWc7bciU2jo5jUZeNSeN8eNesCQXXsZatad6qGjgyUCqgl7ZXeXjdX1G4(xA6mLbpXI(cidut8I4AFL4EgIRbX9V00zvk0knNgklIRbXDyWW(Cmx4BLPsHwPmrI4AN48gX1G4KL4(xA6C0x4dioq2YOyPHXZPHYI48YlI7FPPZug8el6lGmqnXlItcjozjo5jUZehfqCsiXjlXbwqoNPgKkQGC0x4diMI4AN4oL4KH4KH4AFL4(xA6C0x4dioq2YOyPHXZhYtCYS9nHgtT9J(cFaXuBD)4PY59jBFSSphtBjU9fWqryyBFtOXbYWc7bciU2jUtjUge3)stNPm4jw0xazGAIxex7Re3ZqCniU)LMoRsHwP50qzrCniUddg2NJ5cFRmvk0kLjsex7eN3iUgehfjo4Tq6bsfZrFHpG4azlJILggpJL95yI4AqCYsCuK4uJJLMPHtNPEqgWJLgkbzSSphteNxErCj8FPPZ0WPZupid4XsdLG8DH4Kz7BcnMA7h9f(aIP26(XtLB7t2(yzFoM2sC7lGHIWW2(MqJdKHf2deqCTtCYtCNjozjo5jojK4uJJLMbMag0HatmWC5Gmw2NJjItgIRbX9V00zkdEIf9fqgOM4fX1(kX9me3zItwIJcjojK4uJJLMbZLZetLUHMXY(CmrCYqCniU)LMoRsHwP50qzrCniUddg2NJ5cFRmvk0kLjsex7eN3iUgeNSe3)stNJ(cFaXbYwgflnmEonuweNxErC)lnDMYGNyrFbKbQjErCsiXjlXjpXDM4OaItcjozjoWcY5m1GurfKJ(cFaXuex7e3PeNmeNmex7Re3)stNJ(cFaXbYwgflnmE(qEItMTVj0yQTF0x4diMAR7hpvcCFY2hl7ZX0wIBFbmueg223eACGmSWEGaIRDI7uIRbX9V00zkdEIf9fqgOM4fX1(kX9me3zItwIJcjojK4uJJLMbZLZetLUHMXY(CmrCYqCniU)LMoRsHwP50qzrCniUddg2NJ5cFRmvk0kLjsex7eN3iUgehfjo4Tq6bsfZrFHpG4azlJILggpJL95yI4AqCYsCuK4uJJLMPHtNPEqgWJLgkbzSSphteNxErCj8FPPZ0WPZupid4XsdLG8DH4Kz7BcnMA7h9f(aIP26(rk077t2(yzFoM2sC7lGHIWW2()baiUgeNgDKPdlfiX9aXrHEF7BcnMA7tfg9jGiJg5uVgmT19JuO87t2(yzFoM2sC7lGHIWW2()baiUgeNgDKPdlfiX9aXDQCB7BcnMA7dU9(uSJGJ0bwPTUFKcpDFY2hl7ZX0wIBFbmueg22)paaX1G40OJmDyPajUhio59223eAm12hC79PyjSpviyQuOv6w3psHu4(KTpw2NJPTe3(cyOimSTpyUCgWJbte3kX5TTVj0yQTVhRsSHMr9YtwT19JuifSpz7JL95yAlXTVagkcdB7dMlNb8yWeX9aX5nIRbXbVfspqQy(BCeSejecy)lSIIktmqmJL95yI4AqC)lnD(BCeSejecy)lSIIktmqmdXUffG4EG48223eAm12h4XsdLS)W1TUFKc92(KTpw2NJPTe3(MqJP2(ESkXgAg1lpz12pHabmw0yQTVeanX9Sq0sa14VqiG4misCghIwskXzcnoWwexnexHyI40H4a2bsCapgmb2(cyOimSTpyUCgWJbtex7RehfsCniozjUfuZjiAjGA8ximBcnoqIZlViUfuZjSpviyQuOvA2eACGeNmBD)if(m7t2(yzFoM2sC7lGHIWW2(G5YzapgmrCTVsCYtCniU)LMoxO6bHSLbQgpFxiUgeNygEAOSYcJZzjiAjGA8xieKHy3IcqCTtCNsCsiXrvKYD7923eAm123Jvj2qZOE5jR26(rkuoVpz7JL95yAlXTVagkcdB7dMlNb8yWeX1(kXjpX1G4(xA6mLbpXI(cidut8I4AN4oL4AqClOMtq0sa14VqygIDlkaX1oX59S3iUZeNWaktJosCNjotOXuzWT3NILW(uHGPsHwPzHbuMgDK4AqClOMtq0sa14VqygIDlkaX9aX59S3iUZeNWaktJosCNjotOXuzWT3NILW(uHGPsHwPzHbuMgDK4otCYsCEN4AxUpItwIJcjUNtCG5YzapgmrCYqCYqCsiXzcnMkd8yPHs2F4AwyaLPrhjUge3Hbd7ZXCHVvMkfALYejI7bIJQiL72BIRbXPrhjU2jo6acuMkfALY0OJe3ZjoQIuUBV3(MqJP2(ESkXgAg1lpz1w3psHYT9jBFSSphtBjU9fWqryyBFksCI5alR08bwQhPWTpqHHq3pk)23eAm12xyCoZeAmfJhaD7ZdGYkRJBFXCGLvkZ(bpuPBD)ifkbUpz7JL95yAlXTVj0yQTpyUCgqHXlC7NqGaglAm12xUlupZvjoFtad6qGjIZFUCqlIZFUCIZxHXlK4caXbu4uuriXPESI4EwSp1F4AlIdmexOeNhdqCgX5jO6bHe3cmgyOs3(cyOimSTpfjo14yPzGjGbDiWedmxoiJL95yAR7hPaVVpz7JL95yAlXTVj0yQTFc7t9hUU9tiqaJfnMA77VGvI4EwSpviiU2yGiG4OhiX5pxoX57XGjaXDln4e3jsHwPeNygEAOSiUaqCc(aqIthIdIws62xadfHHT9)xA6Cc7tfcMyGygIMqjUgehyUCgWJbte3dehfqCniUddg2NJ5cFRmvk0kLjsex7e3PEFR7hPa53NS9XY(CmTL423eAm12pH9P(dx3(jeiGXIgtT9F2lmkQe3jsHwPeha17slIdSGvI4EwSpviiU2yGiG4OhiX5pxoX57XGjW2xadfHHT9)xA6Cc7tfcMyGygIMqjUgehyUCgWJbte3dehfqCniUddg2NJ5cFRmvk0kLjse3deN8NU19JuWP7t2(yzFoM2sC7lGHIWW2()lnDoH9PcbtmqmdrtOexdIdmxod4XGjI7bIJciUgeNSe3)stNtyFQqWedeZa1eViU2jUtjoV8I4uJJLMbMag0HatmWC5Gmw2NJjItMTVj0yQTFc7t9hUU19JuafUpz7JL95yAlXTVagkcdB7dqL9N6cYAGWtLBStxeexdIdmxod4XGjI7bIJciUgeNSeNSe3ZqCpN4aZLZaEmyI4KH4KqIZeAmvg4XsdLS)W1m(gfxfzA0rIRDIBb1CcIwcOg)fcZqSBrbiUNtCMqJPYESkXgAg1lpzvgFJIRImn6iX9CIZeAmvoH9P(dxZ4BuCvKPrhjoziUge3)stNtyFQqWedeZa1eViU2xjo53(MqJP2(jSp1F46w3psbuW(KTpw2NJPTe3(cyOimST))stNtyFQqWedeZq0ekX1G4aZLZaEmyI4EG4OaIRbXzcnoqgwypqaX1oXj)23eAm12pH9P(dx36(rkWB7t2(MqJP2(G5YzafgVWTpw2NJPTe36(rk4z2NS9XY(CmTL423eAm12xyCoZeAmfJhaD7ZdGYkRJBFXCGLvkZ(bpuPBD)ifiN3NS9XY(CmTL423eAm123Jvj2qZOE5jR2(jeiGXIgtT9LaOjoPZL4ewrCurL4(M4fXPdX5nIZFUCIZ3JbtaI7J0dejUNfIwcOg)fcbeNygEAOSiUaqCq0ssBrCH(eG4MxMuIthIdSGvI4upyN4QHYTVagkcdB7dMlNb8yWeX1(kXrHexdI7WGH95yUW3ktLcTszIeX1oXDQ3iUgeNSeNACS0Cc7tfcMW48OOMXY(CmrCE5fXjMHNgkRSW4CwcIwcOg)fcbzi2TOaex7eNSeNSeN3iUNtCG5YzapgmrCYqCsiXzcnMkd8yPHs2F4AgFJIRImn6iXjdXDM4mHgtL9yvIn0mQxEYQm(gfxfzA0rItMTUFKcKB7t2(yzFoM2sC7BcnMA7NMPV9fWqryyBFisdrGh7ZrIRbXPrhjU2jo6acuMkfALY0OJBFHubhzQbPIky)O8BD)ifibUpz7JL95yAlXTVj0yQTFc7t9hUU9tiqaJfnMA7lNiajUNf7t9hUsCbnXjDUpbrIJ6efvIthIJpaK4EwSpviiU2yGiXbut8c0I4WdSiUGM4c9PeXrPbuK4mIdmxoXb8yWuE7lGHIWW2()lnDoH9PcbtmqmdrtOexdI7FPPZjSpviyIbIzi2TOae3deN8e3zIJQiL72BItcjU)LMoNW(uHGjgiMbQjET19JEZ77t2(MqJP2(apwAOK9hUU9XY(CmTL4w362FbIIP)nDFY(r53NS9XY(CmTL423eAm12Ng5S00JY0yQTFcbcySOXuBF503O4QyI4(i9arItm9VPe3hPgfitCsqcbUOaIRM65EmyN(YjotOXuaIBkU082xadfHHT91OJex7eN3jUgehfjUfuZgpoWTUF809jBFtOXuBFWT3NIrJCQxdM2(yzFoM2sCR7hPW9jBFSSphtBjU9lRJBFD6iBOz9PakCUaMykGcVcnMcS9nHgtT91PJSHM1NcOW5cyIPak8k0ykWw3psb7t2(yzFoM2sC7xwh3(GHJMhadGciQmffEQqc(IBFtOXuBFWWrZdGbqbevMIcpvibFXTUF0B7t2(MqJP2(0Ce4ranAD7JL95yAlXTUF8z2NS9XY(CmTL42xadfHHT9)xA6mLbpXI(cidut8I4AN4KN4AqC)lnDoH9Pcbtmqmdut8I4EyL4oD7BcnMA7VmuIqgiw8m1w3pkN3NS9XY(CmTL42VSoU9bES0qjMyd8ZgAMoWow623eAm12h4XsdLyInWpBOz6a7yPBD)OCBFY2hl7ZX0wIBFbmueg22hmxod4XGjaX9aX5nIRbXjlX9haG48YlIZeAmvoH9P(dxZcdOe3kX5DItMTVj0yQTFc7t9hUU19JsG7t2(yzFoM2sC7lGHIWW2(G5YzapgmbiUhioVrCnioksCYsC)baioV8I4mHgtLtyFQ)W1SWakXTsCEN4Kz7BcnMA7d8yPHs2F46w3pkV33NS9XY(CmTL42Fw2(au3(MqJP2(hgmSph3(hg)IBF4Tq6bsfZFJJGLiHqa7FHvuuzIbIzSSphtexdIdElKEGuXmWJbtSHMzvfEcUPXuzSSphtB)ddYkRJB)laz)HRmn6rrfS1TU9NfSq4(K9JYVpz7JL95yAlXTVagkcdB7dMl)hvktfohilQJG6annMkJL95yA7BcnMA7dMlNbhDR7hpDFY23eAm12Vq1dczldun(2hl7ZX0wIBD)ifUpz7BcnMA7tfg9jGiJg5uVgmT9XY(CmTL4w3psb7t2(MqJP2(GBVpf7i4iDGvA7JL95yAlXTUF0B7t2(yzFoM2sC7lGHIWW2(G5YzapgmrCpqCEJ4AqCIz4PHYklmoNLGOLaQXFHqq(US9nHgtT9bES0qj7pCDR7hFM9jBFSSphtBjU9fWqryyB)ddg2NJ5laz)HRmn6rrfqCnioWC5mGhdMiUhioVrCniU)LMo)nocwIecbS)fwrrLjgiMbQjErCpqCuW23eAm12h4XsdLS)W1TUFuoVpz7BcnMA7lmoNLGOLaQXFHqW2hl7ZX0wIBDRBFfg1lub7t2pk)(KTpw2NJPTe3(ZY2hG623eAm12)WGH9542)W4xC7llXrrI7WGH95y(cq2F4ktJEuubexdIBb1Cc7tfcMkfALMnHghiXjdX5LxeNSe3Hbd7ZX8fGS)WvMg9OOciUge3)stNbEmyIn0mRQWtWnnMkFxioz2(hgKvwh3(xaY(xAAMcJ6fQGTUF809jBFSSphtBjU9nHgtT9bcdcydnJgAkclJZakmOXTVagkcdB7trI7FPPZaHbbSHMrdnfHLXzafg0iJcY3LTFzDC7degeWgAgn0uewgNbuyqJBD)ifUpz7JL95yAlXTVj0yQTpqyqaBOz0qtryzCgqHbnU9fWqryyB))LModegeWgAgn0uewgNbuyqJmkiFxiUge3cQ5e2Nkemvk0knBcnoWTFzDC7degeWgAgn0uewgNbuyqJBD)ifSpz7JL95yAlXTVj0yQTpWJLgkXeBGF2qZ0b2Xs3(cyOimST)Hbd7ZX8)stZaslbtKiUhiUtpD7xwh3(apwAOetSb(zdnthyhlDR7h92(KTpw2NJPTe3(MqJP2(uHrNHcESaWTVagkcdB7FyWW(Cm)V00mG0sWejI7bItoV9lRJBFQWOZqbpwa4w3p(m7t2(yzFoM2sC7BcnMA7tfgDgk4Xca3(cyOimST)Hbd7ZX8)stZaslbtKiUhio582VSoU9PcJodf8ybGBD)OCEFY2hl7ZX0wIBFbmueg22xnowAoH9Pcbtmf42x0yQmw2NJjIRbXDyWW(Cmx4BLPsHwPmrI4EG4o17BFtOXuBFHX5mtOXumEa0TppakRSoU99SWuyuVaBD)OCBFY2hl7ZX0wIB)eceWyrJP2(YP00OqbeN6XuItH2bYjoaFOKlL4OHtN4upiXPgKkQeheLGVbejolLcnMY4TioaUyqtrIZJvjEuu3(MqJP2(cJZzMqJPy8aOBFEauwzDC7d4dLmfg1lubBD)Oe4(KTpw2NJPTe3(MqJP2(ZbcP5dLrrLzv0nMWOIBFbmueg22)WGH95y(cq2)stZuyuVqfS9lRJB)5aH08HYOOYSk6gtyuXTUFuEVVpz7JL95yAlXTVj0yQTVcJ6fQYV9fWqryyBFfg1luZQ8zpgGDbi7FPPjUge3Hbd7ZX8fGS)LMMPWOEHky7d4JU9vyuVqv(TUFuE53NS9XY(CmTL423eAm12xHr9c1t3(cyOimSTVcJ6fQz90ShdWUaK9V00exdI7WGH95y(cq2)stZuyuVqfS9b8r3(kmQxOE6w3pk)P7t2(yzFoM2sC7lGHIWW2(A0rIRDIJoGaLPsHwPmn6iX1G4omyyFoM)xAAgqAjyIeX1oXDQ33(MqJP2(cJZzMqJPy8aOBFEauwzDC7VCHilzDJkYuyuVaBDRB)LlezjRBurMcJ6fyFY(r53NS9XY(CmTL42VSoU9tq0s0bezhiaG8TVj0yQTFcIwIoGi7abaKV19JNUpz7JL95yAlXTFzDC7drWuwPmicq4XeWTVj0yQTpebtzLYGiaHhta36(rkCFY2hl7ZX0wIB)Y6423GcpHIcfWIIkw3qLYede3(MqJP2(gu4juuOawuuX6gQuMyG4w3psb7t2(yzFoM2sC7xwh3(Ib0dbJk3sHPdeWGiykth423eAm12xmGEiyu5wkmDGagebtz6a36(rVTpz7JL95yAlXTFzDC7NGOLOdiYoqaa5BFtOXuB)eeTeDar2bcaiFR7hFM9jBFSSphtBjU9lRJBFWC5SGAfkc3(MqJP2(G5Yzb1kueU19JY59jBFSSphtBjU9nHgtT9PYLU4Hn0mdaIEWnnMA7lGHIWW2(MqJdKHf2deqCReN8B)Y642Nkx6Ih2qZmai6b30yQTUFuUTpz7JL95yAlXTFzDC7Nm4R(mflHIxSLRcrGalbU9nHgtT9tg8vFMILqXl2YvHiqGLa36(rjW9jBFSSphtBjU9lRJBF8pfyUC2raWTVj0yQTp(Ncmxo7ia4w3pkV33NS9XY(CmTL42VSoU9VLWJffMyu5wkmDGagWJjEXrW23eAm12)wcpwuyIrLBPW0bcyapM4fhbBDRB)HQiTpz)O87t2(MqJP2(Fecq4ROOU9XY(CmTL4w3pE6(KTVj0yQT)NptIrFHs3(yzFoM2sCR7hPW9jBFtOXuBF6aIF(mPTpw2NJPTe36(rkyFY23eAm12)cqwOyhS9XY(CmTL4w36w3(hieetTF8uVF6PENcK3BBFknyffvW2xUtcQT7rjGhB7LlIJ4oXdsCrFzGkXrpqI7jaFOKPWOEHk4jIdIsW3aIjIdmDK4SRoDtXeXj8yfveKjnBROqItE5I4AJPoqOIjIZp6TbXbKwQ9M4ABjoDiU26AexkocqmfXnli00bsCYkPmeNSY)wMmPzBffsCNkxexBm1bcvmrC(rVnioG0sT3exBlXPdX1wxJ4sXraIPiUzbHMoqItwjLH4Kv(3YKjnBROqIJcLlIRnM6aHkMio)O3gehqAP2BIRTL40H4ARRrCP4iaXue3SGqthiXjRKYqCYk)BzYKMKMYDsqTDpkb8yBVCrCe3jEqIl6ldujo6bsCpjMdSSsz2p4Hk9jIdIsW3aIjIdmDK4SRoDtXeXj8yfveKjnBROqItE5I4AJPoqOIjI7j4Tq6bsfZYXteNoe3tWBH0dKkMLJmw2NJPNiozL)TmzsZ2kkK4KxUiU2yQdeQyI4Ecmx(pQuwoEI40H4Ecmx(pQuwoYyzFoMEI4Kv(3YKjnBROqI7u5I4AJPoqOIjI7j4Tq6bsfZYXteNoe3tWBH0dKkMLJmw2NJPNiozL)TmzsZ2kkK4ovUiU2yQdeQyI4Ecmx(pQuwoEI40H4Ecmx(pQuwoYyzFoMEI4Kv(3YKjnBROqIJcLlIRnM6aHkMiUNG3cPhivmlhprC6qCpbVfspqQywoYyzFoMEI4Kv(3YKjnBROqIJcLlIRnM6aHkMiUNaZL)JkLLJNioDiUNaZL)JkLLJmw2NJPNiozL)TmzsZ2kkK4Oa5I4A7W(CGjIRhLCjheNWdkErCYwJsC2HfC7ZrIlkId7xUPXuYqCYk)BzYKMTvuiXrbYfX1gtDGqfte3tG5Y)rLYYXteNoe3tG5Y)rLYYrgl7ZX0teNSY)wMmPzBffsCEtUiU2oSphyI46rjxYbXj8GIxeNS1OeNDyb3(CK4II4W(LBAmLmeNSY)wMmPzBffsCEtUiU2yQdeQyI4Ecmx(pQuwoEI40H4Ecmx(pQuwoYyzFoMEI4Kv(3YKjnBROqI7zKlIRnM6aHkMiUNaZL)JkLLJNioDiUNaZL)JkLLJmw2NJPNiozPW3YKjnBROqItolxexBm1bcvmrCpPghlnlhprC6qCpPghlnlhzSSphtprCYk)BzYKMTvuiXj3KlIRnM6aHkMiUNaZL)JkLLJNioDiUNaZL)JkLLJmw2NJPNiozL)TmzsZ2kkK4KaLlIRnM6aHkMiUNaZL)JkLLJNioDiUNaZL)JkLLJmw2NJPNiozL)TmzsZ2kkK4K37YfX1gtDGqfte3tG5Y)rLYYXteNoe3tG5Y)rLYYrgl7ZX0teNPeNCABJ2I4Kv(3YKjnjnL7KGA7Euc4X2E5I4iUt8Gex0xgOsC0dK4EsLcTszauVlprCquc(gqmrCGPJeND1PBkMioHhROIGmPzBffsCuOCrCTXuhiuXeX9e8wi9aPIz54jIthI7j4Tq6bsfZYrgl7ZX0teNSY)wMmPjPPCNeuB3Jsap22lxehXDIhK4I(YavIJEGe3tjK2UC9jIdIsW3aIjIdmDK4SRoDtXeXj8yfveKjnBROqIZBYfX1gtDGqfte3tG5Y)rLYYXteNoe3tG5Y)rLYYrgl7ZX0teNSY)wMmPzBffsCpJCrCTXuhiuXeX9eyU8FuPSC8eXPdX9eyU8FuPSCKXY(Cm9eXjR8VLjtA2wrHeN8Yz5I4AJPoqOIjI7jWC5)Osz54jIthI7jWC5)Osz5iJL95y6jItwk8TmzsZ2kkK4KxcuUiU2yQdeQyI4Ecmx(pQuwoEI40H4Ecmx(pQuwoYyzFoMEI4Kv(3YKjnBROqI7u5LlIRnM6aHkMiUNG3cPhivmlhprC6qCpbVfspqQywoYyzFoMEI4Kv(3YKjnBROqI7ukuUiU2yQdeQyI4EcElKEGuXSC8eXPdX9e8wi9aPIz5iJL95y6jItw5FltM0STIcjUtLZYfX1gtDGqfte3tWBH0dKkMLJNioDiUNG3cPhivmlhzSSphtprCYk)BzYKMTvuiXDQeOCrCTXuhiuXeX9e8wi9aPIz54jIthI7j4Tq6bsfZYrgl7ZX0teNSY)wMmPzBffsCuifixexBm1bcvmrCpbVfspqQywoEI40H4EcElKEGuXSCKXY(Cm9eXjR8VLjtAsAk3jb129OeWJT9YfXrCN4bjUOVmqL4OhiX90ceft)B6teheLGVbetehy6iXzxD6MIjIt4XkQiitA2wrHeN8ExUiU2yQdeQyI4EcElKEGuXSC8eXPdX9e8wi9aPIz5iJL95y6jIZuItoTTrBrCYk)BzYKMTvuiXjV3LlIRnM6aHkMiUNG3cPhivmlhprC6qCpbVfspqQywoYyzFoMEI4Kv(3YKjnjnL7KGA7Euc4X2E5I4iUt8Gex0xgOsC0dK4EsHr9cvWteheLGVbetehy6iXzxD6MIjIt4XkQiitA2wrHeN8ExUiU2yQdeQyI4EsHr9c1S8z54jIthI7jfg1luZQ8z54jItw5FltM0STIcjo5LxUiU2yQdeQyI4EsHr9c18Pz54jIthI7jfg1luZ6Pz54jItw5FltM0K0uUtcQT7rjGhB7LlIJ4oXdsCrFzGkXrpqI7Pzble(eXbrj4BaXeXbMosC2vNUPyI4eESIkcYKMTvuiXjVCrCTXuhiuXeX9eyU8FuPSC8eXPdX9eyU8FuPSCKXY(Cm9eXzkXjN22OTiozL)TmzststjG(YavmrCY7DIZeAmfXXdGcYKMBF7QEg42F7Vah6GJB)2SnjUNf7tn8HQuItUZG8r8I0SnBtIZJQla5ssjPgQN7plMUKGOF5MgtjGgTkji6cjjnBZ2K4KGwGbN4K)zArCN69tpL0K0SnBtIRn8yfveixKMTzBsCpN48xqoN4ARr8ktA2MTjX9CIRTrXLsCqum9owjI7zX(u)HRe3ceFUy6FtjUGM4cL4caXffqTsjozhiX5XGjHbuIJEGe3FaaeiJCciU0upPe3CGqHTqCapgmbiUGM4Ko3NGiXzkX5nIlkIt9Ge3SGfcZKMTzBsCpN4K7nuIqIZpw8mfXzC(qjMiUfi(CX0)MsC6qClWrqCrbuRuI7zX(u)HRzsZ2SnjUNtCY9oK7rCQXXsjUOuecVlAM0SnBtI75eNe0XejIZxIpV92MN2EIdSyDIJspyrCsN7tqK4Qrjo7pxL40H4a3EFkIZiUtKcTsZKMTzBsCpN4K7NJapcOrRs220Wnn4iX5p8dSuItyLa5SGM4eESIkMioDiUOuecVlklOZKMTzBsCpN4obkL40H4SJjsehLgqJIkX9SyFQqqCTXarIdOM4fitA2MTjX9CI7eOuIthIRBVqIBwWcHe3cmgyOsjUP4sjokh4lIlOjokrItyfXzc9ACUuIBwWI4OmupeNrCNifALMjnBZ2K4EoXjb0xGZbsCIPVyA8dEOsjokd1dXjNWZe3)g8eitAsA2MeNC6BuCvmrCFKEGiXjM(3uI7JuJcKjojiHaxuaXvt9CpgStF5eNj0ykaXnfxAM00eAmfiVarX0)MEEvsAKZstpktJPAf0RA0X29EdkUGA24XbsAAcnMcKxGOy6FtpVkj427tXwqL00eAmfiVarX0)MEEvYlazHI9wL1XvD6iBOz9PakCUaMykGcVcnMcqAAcnMcKxGOy6FtpVk5fGSqXERY64ky4O5bWaOaIktrHNkKGViPPj0ykqEbIIP)n98QK0Ce4ranAL00eAmfiVarX0)MEEvYLHseYaXINPAf0R)lnDMYGNyrFbKbQjE1U8n(xA6Cc7tfcMyGygOM41dRNsAAcnMcKxGOy6FtpVk5fGSqXERY64kWJLgkXeBGF2qZ0b2XsjnnHgtbYlqum9VPNxLmH9P(dxBf0RG5YzapgmbEWBnK9paGxEzcnMkNW(u)HRzHb0vVldPPj0ykqEbIIP)n98QKapwAOK9hU2kOxbZLZaEmyc8G3Aqrz)da4LxMqJPYjSp1F4AwyaD17YqA2MTjXzcnMcKxGOy6FtpVk5Hbd7ZXwL1Xv6acuMkfALY0OJTMLvaQTom(fxL37KMTzBsCMqJPa5fikM(30ZRsEyWW(CSvzDCnk2SGfcBnlRauBDy8lUkpPPj0ykqEbIIP)n98QKhgmSphBvwhxVaK9hUY0OhfvqRzzfGARdJFXv4Tq6bsfZFJJGLiHqa7FHvuuzIbInG3cPhivmd8yWeBOzwvHNGBAmfPjPjPzBsCYPVrXvXeXHhiukXPrhjo1dsCMqhiXfaIZoSGBFoMjnnHgtbwbliNZ4J4fPPj0ykW5vjfgNZOrUNBPiK00eAmf48QK2BKPdaqAAcnMcCEvYeEmxiRBudbPPj0ykW6Hbd7ZXwL1X1cFRmvk0kLjsTMLvaQTom(fxfZWtdLvgC79PyjSpviyQuOvAgIDlkadFVGcftTc6vkcMl)hvkthipXgA2NpaW0bE5LygEAOSYGBVpflH9PcbtLcTsZqSBrby47fuOyQDXm80qzLbZLZGJMHy3IcWW3lOqXePPj0ykW5vjpmyyFo2QSoUw4BLPsHwPmrQ1SScqT1HXV4QygEAOSYG5YzWrZqSBrby47fuOyQvqVcMl)hvkthipXgA2NpaW0bneZWtdLvgC79PyjSpviyQuOvAgIDlkadFVGcftpiMHNgkRmyUCgC0me7wuag(EbfkMinBZ2K4mHgtboVk5Hbd7ZXwL1X1OyZcwiS1SScqT1HXV4Q3Bf0RlOMtyFQqWuPqR0Sj04ajnnHgtboVk5Hbd7ZXwL1X1)LMMbKwcMi1AwwbO26W4xC9WGH95yUW3ktLcTszIuRGELIhgmSphZxaY(dxzA0JIkObfJInlyHqsttOXuGZRsEyWW(CSvzDC9FPPzaPLGjsTMLvaQTom(fxL)0wb9kfpmyyFoMVaK9hUY0OhfvqJOyZcwiSbfxqnNGOLaQXFHWSj04ajnnHgtboVk5Hbd7ZXwL1X1)LMMbKwcMi1AwwbO26W4xC17Tc6vkEyWW(CmFbi7pCLPrpkQGgrXMfSqyJfuZjiAjGA8ximBcnoWg)lnDMYGNyrFbKbQjE1U3Bqr14yP5JGJ0bwPmw2NJjsttOXuGZRsEyWW(CSvzDC9FPPzaPLGjsTMLvaQTom(fx9ERGELIhgmSphZxaY(dxzA0JIkOruSzble2yb1CcIwcOg)fcZMqJdSXcepyufPS8zpwLydnJ6LNSQHACS08rWr6aRugl7ZXePPj0ykW5vjpmyyFo2QSoU(V00mG0sWePwZYka1whg)IRIz4PHYkNqr0nnkQS)W1me7wuag(EbfkMAf0RhgmSphZxaY(dxzA0JIkG00eAmf48QKcJZzMqJPy8aOTkRJRkmQxOcinnHgtboVkPW4CMj0ykgpaARY646qvKAf0RYsXddg2NJ5laz)HRmn6rrf0yb1Cc7tfcMkfALMnHghOmE5LShgmSphZxaY(dxzA0JIkOX)stNbEmyIn0mRQWtWnnMkFxAilfvJJLMxgkridelEMkJL95yYlV(xA68YqjczGyXZu57ImYqAAcnMcCEvYOVWhqmvRGE9paqd6GQhLbXUff4HtLqQIePPj0ykW5vjfgNZmHgtX4bqBvwhxNfSqylGcdHUkFRGEvhQu5ywmdpnuwGgA0XhOdiqzQuOvktJosAAcnMcCEvY0m9wb9kePHiWJ95iPPj0ykW5vjfgNZmHgtX4bqBvwhxfZbwwPm7h8qL2cOWqORY3kOxbZL)JkLPcNdKf1rqDGMgt5LxG5Y)rLY0bYtSHM95damDGxEbMl)hvklM(3uwhtHAAmLxEjMdSSsZfkGdFGjsttOXuGZRsUmuIqgiw8mvRGE9WGH95y(cq2F4ktJEuubn(xA6mWJbtSHMzvfEcUPXu57cPPj0ykW5vjxgnMQvqVklfpmyyFoMVaK9hUY0OhfvqJddg2NJ5cFRmvk0kLjspqvKYD7Ddn6y70beOmvk0kLPrh9YlWC5)OszishfMylg3uSXHbd7ZXCHVvMkfALYePhOq5MmE5LShgmSphZxaY(dxzA0JIkOX)stNbEmyIn0mRQWtWnnMkFxKH00eAmf48QKcJZzMqJPy8aOTkRJRQuOvkdG6DH00eAmf48QKjSpviyafIfv1tRGEvwkcVfspqQyMYGtdXeGbcQbNn0mWDbHXazGBVpvuuBCyWW(Cmx4BLPsHwPmrQDjqz8YlzxqnNW(uHGPsHwPztOXb2yb1Cc7tfcMkfALMHy3Ic8WZiHufPC3EldPPj0ykW5vjfgNZsq0sa14VqiOvqVEyWW(CmFbi7pCLPrpkQGgIz4PHYkdU9(uSe2Nkemvk0kndXUffGHVxqHIP2p9usttOXuGZRskmoNLGOLaQXFHqqRGELIhgmSphZxaY(dxzA0JIkOHShgmSphZf(wzQuOvktKA)uV)CVjHueElKEGuXmLbNgIjadeudoBOzG7ccJbYa3EFQOOkdPPj0ykW5vjxgkridelEMQvqVsXddg2NJ5laz)HRmn6rrf04FPPZug8el6lGmqnXR2LVX)stNtyFQqWedeZa1eVEGcjnnHgtboVk5p4iqmxivK9N(hHGwb96)stNvPqR0CAOSACyWW(Cmx4BLPsHwPmrQDVrAAcnMcCEvYOVWhqmvRGE1eACGmSWEGG2L)SSYlHQXXsZatad6qGjgyUCqgl7ZXKmn(xA6mLbpXI(cidut8Q91NPX)stNvPqR0CAOSACyWW(Cmx4BLPsHwPmrQDV1q2)LMoh9f(aIdKTmkwAy8CAOS8YR)LMotzWtSOVaYa1eVKqzL)mfiHYcwqoNPgKkQGC0x4diMQ9tLrM2x)xA6C0x4dioq2YOyPHXZhYldPPj0ykW5vjJ(cFaXuTc6vtOXbYWc7bcA)0g)lnDMYGNyrFbKbQjE1(6Z04FPPZQuOvAonuwnomyyFoMl8TYuPqRuMi1U3Aqr4Tq6bsfZrFHpG4azlJILggVHSuunowAMgoDM6bzapwAOeKXY(Cm5Lxj8FPPZ0WPZupid4XsdLG8DrgsttOXuGZRsg9f(aIPAf0RMqJdKHf2de0U8NLvEjunowAgycyqhcmXaZLdYyzFoMKPX)stNPm4jw0xazGAIxTV(mNLLcLq14yPzWC5mXuPBOzSSphtY04FPPZQuOvAonuwnomyyFoMl8TYuPqRuMi1U3Ai7)stNJ(cFaXbYwgflnmEonuwE51)stNPm4jw0xazGAIxsOSYFMcKqzbliNZudsfvqo6l8bet1(PYit7R)lnDo6l8behiBzuS0W45d5LH00eAmf48QKrFHpGyQwb9Qj04azyH9abTFAJ)LMotzWtSOVaYa1eVAF9zollfkHQXXsZG5YzIPs3qZyzFoMKPX)stNvPqR0CAOSACyWW(Cmx4BLPsHwPmrQDV1GIWBH0dKkMJ(cFaXbYwgflnmEdzPOACS0mnC6m1dYaES0qjiJL95yYlVs4)stNPHtNPEqgWJLgkb57ImKMMqJPaNxLKkm6targnYPEnyQvqV(haOHgDKPdlf4duO3jnnHgtboVkj427tXocoshyLAf0R)baAOrhz6Wsb(WPYnsttOXuGZRscU9(uSe2Nkemvk0kTvqV(haOHgDKPdlf4dY7nsttOXuGZRs6XQeBOzuV8KvTc6vWC5mGhdMw9gPPj0ykW5vjbES0qj7pCTvqVcMlNb8yW0dERb8wi9aPI5VXrWsKqiG9VWkkQmXaXg)lnD(BCeSejecy)lSIIktmqmdXUff4bVrA2MeNeanX9Sq0sa14VqiG4misCghIwskXzcnoWwexnexHyI40H4a2bsCapgmbinnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9vkSHSlOMtq0sa14Vqy2eACGE51cQ5e2Nkemvk0knBcnoqzinnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9v5B8V005cvpiKTmq1457sdXm80qzLfgNZsq0sa14VqiidXUffO9tLqQIuUBVjnnHgtboVkPhRsSHMr9Ytw1kOxbZLZaEmyQ9v5B8V00zkdEIf9fqgOM4v7N2yb1CcIwcOg)fcZqSBrbA37zVDwyaLPrhpBcnMkdU9(uSe2Nkemvk0knlmGY0OJnwqnNGOLaQXFHWme7wuGh8E2BNfgqzA0XZMqJPYGBVpflH9PcbtLcTsZcdOmn64zz9E7Y9jlf(CWC5mGhdMKrgj0eAmvg4XsdLS)W1SWaktJo24WGH95yUW3ktLcTszI0dufPC3E3qJo2oDabktLcTszA0XNtvKYD7nPPj0ykW5vjfgNZmHgtX4bqBvwhxfZbwwPm7h8qL2cOWqORY3kOxPOyoWYknFGL6rkK0Snjo5Uq9mxL48nbmOdbMio)5YbTio)5YjoFfgVqIlaehqHtrfHeN6XkI7zX(u)HRTioWqCHsCEmaXzeNNGQhesClWyGHkL00eAmf48QKG5YzafgVWwb9kfvJJLMbMag0HatmWC5Gmw2NJjsZ2K48xWkrCpl2NkeexBmqeqC0dK48NlN489yWeG4ULgCI7ePqRuItmdpnuwexaiobFaiXPdXbrljL00eAmf48QKjSp1F4ARGE9FPPZjSpviyIbIziAcTbyUCgWJbtpqbnomyyFoMl8TYuPqRuMi1(PEN0SnjUN9cJIkXDIuOvkXbq9U0I4alyLiUNf7tfcIRngicio6bsC(ZLtC(EmycqAAcnMcCEvYe2N6pCTvqV(V005e2NkemXaXmenH2amxod4XGPhOGghgmSphZf(wzQuOvktKEq(tjnnHgtboVkzc7t9hU2kOx)xA6Cc7tfcMyGygIMqBaMlNb8yW0duqdz)xA6Cc7tfcMyGygOM4v7N6LxQXXsZatad6qGjgyUCqgl7ZXKmKMMqJPaNxLmH9P(dxBf0Rauz)PUGSgi8u5g70frdWC5mGhdMEGcAiRSpZZbZLZaEmysgj0eAmvg4XsdLS)W1m(gfxfzA0X2xqnNGOLaQXFHWme7wuGNBcnMk7XQeBOzuV8Kvz8nkUkY0OJp3eAmvoH9P(dxZ4BuCvKPrhLPX)stNtyFQqWedeZa1eVAFvEsttOXuGZRsMW(u)HRTc61)LMoNW(uHGjgiMHOj0gG5Yzapgm9af0WeACGmSWEGG2LN00eAmf48QKG5YzafgVqsttOXuGZRskmoNzcnMIXdG2QSoUkMdSSsz2p4HkL0SnjojaAIt6CjoHvehvujUVjErC6qCEJ48NlN489yWeG4(i9arI7zHOLaQXFHqaXjMHNgklIlaeheTK0wexOpbiU5LjL40H4alyLio1d2jUAOK00eAmf48QKESkXgAg1lpzvRGEfmxod4XGP2xPWghgmSphZf(wzQuOvktKA)uV1qw14yP5e2NkemHX5rrnJL95yYlVeZWtdLvwyColbrlbuJ)cHGme7wuG2LvwV9CWC5mGhdMKrcnHgtLbES0qj7pCnJVrXvrMgDuMZMqJPYESkXgAg1lpzvgFJIRImn6OmKMMqJPaNxLmntVLqQGJm1GurfSkFRGEfI0qe4X(CSHgDSD6acuMkfALY0OJKMTjXjNiajUNf7t9hUsCbnXjDUpbrIJ6efvIthIJpaK4EwSpviiU2yGiXbut8c0I4WdSiUGM4c9PeXrPbuK4mIdmxoXb8yWuM00eAmf48QKjSp1F4ARGE9FPPZjSpviyIbIziAcTX)stNtyFQqWedeZqSBrbEq(ZufPC3ElH)lnDoH9Pcbtmqmdut8I00eAmf48QKapwAOK9hUsAsAAcnMcKb8HsMcJ6fQG1lazHI9wL1XvWC5Cu1OOYG3V0wcPcoYudsfvWQ8Tc61ddg2NJ5)LMMbKwcMi9GAqQOMtbqTsGTTE75YEQesvKYD7TeEyWW(CmFbi7pCLPrpkQazinnHgtbYa(qjtHr9cvW5vjVaKfk2Bvwhxb36ZNjXSoQEKc0wb96Hbd7ZX8)stZaslbtKEqnivuZPaOwjW2wVDw2tLWddg2NJ5laz)HRmn6rrfidPPj0ykqgWhkzkmQxOcoVk5fGSqXERY64k2xKcrJZgyQSsGTc61ddg2NJ5)LMMbKwcMi9GSQbPIAofa1kb226nzol)PNL9uj8WGH95y(cq2F4ktJEuubYqAsAAcnMcKfZbwwPm7h8qLUcMlNbhTvqVklyU8FuPmDG8eBOzF(aath4LxWBH0dKkMtOWKgfvgyUCgWuHhKltJfuZjSpviyQuOvA2eACGKMMqJPazXCGLvkZ(bpuPNxLemxodoARGEfmx(pQuMkCoqwuhb1bAAmvdkcVfspqQyoHctAuuzG5YzatfEqEdzpmyyFoMl8TYuPqRuMi9WPE3lVomyyFoMl8TYuPqRuMi1of6DzinnHgtbYI5alRuM9dEOspVkjyUCgC0wb9kyU8FuPmLbpX8ClLPMqdbObfH3cPhivmNqHjnkQmWC5mGPcpiVbfxqnNW(uHGPsHwPztOXb24WGH95yUW3ktLcTszIu7Yl3innHgtbYI5alRuM9dEOspVkzcfr30OOY(dxBjKk4itnivubRY3kOx7rjxQbPIA2dAC1tErOTc6vkEyWW(CmFbi7pCLPrpkQGgG5Y)rLYC0sSVug(26lCSHSlOMtyFQqWuPqR0Sj04aBaMlNb8yW0dN6LxuCb1Cc7tfcMkfALMnHghyJddg2NJ5cFRmvk0kLjsTtbExgsttOXuGSyoWYkLz)GhQ0ZRsMqr0nnkQS)W1wcPcoYudsfvWQ8Tc61EuYLAqQOM9Ggx9KxeARGELIhgmSphZxaY(dxzA0JIkObyU8FuP8l8ikaBg5KipkQnKDb1Cc7tfcMkfALMnHghOxErXfuZjSpviyQuOvA2eACGnomyyFoMl8TYuPqRuMi1of4DzinnHgtbYI5alRuM9dEOspVkzcfr30OOY(dxBjKk4itnivubRY3kOxP4Hbd7ZX8fGS)WvMg9OOcAilyU8FuPm9aPI)bwidIhimqGxEjlyU8FuP8XWnn4idm8dS0guemx(pQu(fEefGnJCsKhfvzKPbfxqnNW(uHGPsHwPztOXbsAAcnMcKfZbwwPm7h8qLEEvYekIUPrrL9hU2sivWrMAqQOcwLVvqVEyWW(CmFbi7pCLPrpkQGgYsr14yP5LHseYaXINP8YlXm80qzLxgkridelEMkdXUff4btOXu5ekIUPrrL9hUMX3O4QitJoktdkkMHNgkRm427tXsyFQqWuPqR08DPHSlOMtyFQqWuPqR0me7wuGhKBE5LygEAOSYGBVpflH9PcbtLcTsZqSBrby47fuOy6bk07YqAAcnMcKfZbwwPm7h8qLEEvsAoc8iGgT2kOxbZL)JkLpgUPbhzGHFGL24FPPZhd30GJmWWpWsZPHYQvukcH3fLf0R)lnD(y4MgCKbg(bwA(UqAAcnMcKfZbwwPm7h8qLEEvsGyUWOOY0q9GTc6vWC5)OszX0)MY6ykutJPASGAoH9PcbtLcTsZMqJdK00eAmfilMdSSsz2p4Hk98QKaXCHrrLPH6bBf0Ruemx(pQuwm9VPSoMc10yksttOXuGSyoWYkLz)GhQ0ZRsg9fSsrrLjm1akCw8GTc61fuZjSpviyQuOvA2eACGnaZLZaEmyA17KMKMMqJPazplmfg1lW6fGSqXERY64kik6lNrLBPW0bcyy)ZXoPPj0ykq2ZctHr9cCEvYlazHI9wL1Xvqu0xoZalb0kfWW(NJDststtOXuG8qvKw)ieGWxrrL00eAmfipufPZRs(5ZKy0xOusttOXuG8qvKoVkjDaXpFMePPj0ykqEOksNxL8cqwOyhqAsAAcnMcKNfSq4kyUCgC0wb9kyU8FuPmv4CGSOocQd00yksttOXuG8SGfcpVkzHQheYwgOACsttOXuG8SGfcpVkjvy0NaImAKt9AWePPj0ykqEwWcHNxLeC79PyhbhPdSsKMMqJPa5zbleEEvsGhlnuY(dxBf0RG5Yzapgm9G3AiMHNgkRSW4CwcIwcOg)fcb57cPPj0ykqEwWcHNxLe4XsdLS)W1wb96Hbd7ZX8fGS)WvMg9OOcAaMlNb8yW0dERX)stN)ghblrcHa2)cROOYedeZa1eVEGcinnHgtbYZcwi88QKcJZzjiAjGA8xieqAsAAcnMcKxUqKLSUrfzkmQxG1lazHI9wL1X1eeTeDar2bcaiN00eAmfiVCHilzDJkYuyuVaNxL8cqwOyVvzDCfIGPSszqeGWJjGKMMqJPa5LlezjRBurMcJ6f48QKxaYcf7TkRJRgu4juuOawuuX6gQuMyGiPPj0ykqE5crwY6gvKPWOEboVk5fGSqXERY64Qya9qWOYTuy6abmicMY0bsAAcnMcKxUqKLSUrfzkmQxGZRsEbiluS3QSoUMGOLOdiYoqaa5KMMqJPa5LlezjRBurMcJ6f48QKxaYcf7TkRJRG5Yzb1kuesAAcnMcKxUqKLSUrfzkmQxGZRsEbiluS3QSoUsLlDXdBOzgae9GBAmvRGE1eACGmSWEGGv5jnnHgtbYlxiYsw3OImfg1lW5vjVaKfk2Bvwhxtg8vFMILqXl2YvHiqGLajnnHgtbYlxiYsw3OImfg1lW5vjVaKfk2BvwhxX)uG5YzhbajnnHgtbYlxiYsw3OImfg1lW5vjVaKfk2BvwhxVLWJffMyu5wkmDGagWJjEXraPjPPj0ykqwHr9cvW6Hbd7ZXwL1X1laz)lnntHr9cvqRdJFXvzP4Hbd7ZX8fGS)WvMg9OOcASGAoH9PcbtLcTsZMqJdugV8s2ddg2NJ5laz)HRmn6rrf04FPPZapgmXgAMvv4j4MgtLVlYqAAcnMcKvyuVqfCEvYlazHI9wL1XvGWGa2qZOHMIWY4mGcdASvqVsX)LModegeWgAgn0uewgNbuyqJmkiFxinnHgtbYkmQxOcoVk5fGSqXERY64kqyqaBOz0qtryzCgqHbn2kOx)xA6mqyqaBOz0qtryzCgqHbnYOG8DPXcQ5e2Nkemvk0knBcnoqsttOXuGScJ6fQGZRsEbiluS3QSoUc8yPHsmXg4Nn0mDGDS0wb96Hbd7ZX8)stZaslbtKE40tjnnHgtbYkmQxOcoVk5fGSqXERY64kvy0zOGhlaSvqVEyWW(Cm)V00mG0sWePhKZKMMqJPazfg1lubNxL8cqwOyVvzDCLkm6muWJfa2kOxpmyyFoM)xAAgqAjyI0dYzsttOXuGScJ6fQGZRskmoNzcnMIXdG2QSoU6zHPWOEbAf0RQXXsZjSpviyIPa3(IgtLXY(Cm14WGH95yUW3ktLcTszI0dN6DsZ2K4KtPPrHcio1JPeNcTdKtCa(qjxkXrdNoXPEqItnivujoikbFdisCwkfAmLXBrCaCXGMIeNhRs8OOsAAcnMcKvyuVqfCEvsHX5mtOXumEa0wL1XvaFOKPWOEHkG00eAmfiRWOEHk48QKxaYcf7TkRJRZbcP5dLrrLzv0nMWOITc61ddg2NJ5laz)lnntHr9cvaPPj0ykqwHr9cvW5vjVaKfk2Bb4JUQWOEHQ8Tc6vfg1luZYN9ya2fGS)LMUXHbd7ZX8fGS)LMMPWOEHkG00eAmfiRWOEHk48QKxaYcf7Ta8rxvyuVq90wb9QcJ6fQ5tZEma7cq2)st34WGH95y(cq2)stZuyuVqfqAAcnMcKvyuVqfCEvsHX5mtOXumEa0wL1X1LlezjRBurMcJ6fOvqVQrhBNoGaLPsHwPmn6yJddg2NJ5)LMMbKwcMi1(PEN0K00eAmfiRsHwPmaQ3L1cvpiKTmq14Tc61ddg2NJ5cFRmvk0kLjspiV3innHgtbYQuOvkdG6D58QKuHrFciYOro1RbtTc61ddg2NJ5cFRmvk0kLjspiVC(5YAcnMkdU9(uSe2Nkemvk0knJVrXvrMgD8Sj0yQmWJLgkz)HRz8nkUkY0OJY0qwXm80qzLfgNZsq0sa14VqiidXUff4b5LZpxwtOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLb3EFk2rWr6aRugFJIRImn64ztOXuzGhlnuY(dxZ4BuCvKPrhLXlVwqnNGOLaQXFHWme7wuG2pmyyFoMl8TYuPqRuMiD2eAmvgC79PyjSpviyQuOvAgFJIRImn6OmKMMqJPazvk0kLbq9UCEvsWT3NIDeCKoWk1kOxL9WGH95yUW3ktLcTszI0dY7TNlRj0yQm427tXsyFQqWuPqR0m(gfxfzA0rzAiRygEAOSYcJZzjiAjGA8xieKHy3Ic8G8E75YAcnMkdU9(uSe2Nkemvk0knJVrXvrMgD8Sj0yQm427tXocoshyLY4BuCvKPrhLXlVwqnNGOLaQXFHWme7wuG2pmyyFoMl8TYuPqRuMiD2eAmvgC79PyjSpviyQuOvAgFJIRImn6OmY4LxYsr4Tq6bsfZugCAiMamqqn4SHMbUlimgidC79PIIAJddg2NJ5cFRmvk0kLjsTtbExgsttOXuGSkfALYaOExoVkPW4CwcIwcOg)fcbTc61ddg2NJ5cFRmvk0kLjspi)PpxwtOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLbES0qj7pCnJVrXvrMgDugsttOXuGSkfALYaOExoVkj427tXsyFQqWuPqR0wb9QgDSD6acuMkfALY0OJnKDb1CcIwcOg)fcZMqJdSXcQ5eeTeqn(leMHy3Ic0Uj0yQm427tXsyFQqWuPqR0m(gfxfzA0rzAilfvJJLMb3EFk2rWr6aRugl7ZXKxETGA(i4iDGvkBcnoqzAilyUCgWJbtRE3lVKDb1CcIwcOg)fcZMqJdSXcQ5eeTeqn(leMHy3Ic8Gj0yQm427tXsyFQqWuPqR0m(gfxfzA0XZMqJPYapwAOK9hUMX3O4QitJokJxEj7cQ5JGJ0bwPSj04aBSGA(i4iDGvkdXUff4btOXuzWT3NILW(uHGPsHwPz8nkUkY0OJNnHgtLbES0qj7pCnJVrXvrMgDugV8s2)LMotfg9jGiJg5uVgmLVln(xA6mvy0NaImAKt9AWugIDlkWdMqJPYGBVpflH9PcbtLcTsZ4BuCvKPrhpBcnMkd8yPHs2F4AgFJIRImn6OmYS1TU3a]] )


end
