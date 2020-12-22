-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
        gateway_mastery = 3506, -- 248855
        master_summoner = 1213, -- 212628
        nether_ward = 3624, -- 212295
        pleasure_through_pain = 158, -- 212618
        singe_magic = 154, -- 212623
    } )


    -- Demon Handling
    local dreadstalkers = {}
    local dreadstalkers_v = {}

    local vilefiend = {}
    local vilefiend_v = {}

    local wild_imps = {}
    local wild_imps_v = {}

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


    -- tyrant_ready needs to be handled internally, as the priority interpreter can't keep variable state in the same way that simc does.
    local tyrant_ready_actual = false

    spec:RegisterStateExpr( "tyrant_ready", function ()
        return tyrant_ready_actual
    end )

    spec:RegisterStateFunction( "update_tyrant_readiness", function( hog_shards )
        if not IsSpellKnown( 265187 ) then return end

        hog_shards = hog_shards or 1

        -- The last part of a Tyrant Prep phase should be a HoG cast.
        if cooldown.summon_demonic_tyrant.remains < 4 then
            if  ( talent.doom.enabled and not debuff.doom.up ) or
                ( talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.remains < 4 ) or
                ( talent.nether_portal.enabled and cooldown.nether_portal.remains < 4 ) or
                ( talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < 4 ) or
                ( talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.remains < 4 ) or
                ( cooldown.call_dreadstalkers.remains < 4 ) or
                ( buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) ) then
                    if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false due to missed APL conditions." ) end
                    tyrant_ready = false
                    return
            end

            if ( soul_shard + hog_shards >= ( buff.nether_portal.up and 1 or 5 ) ) then
                if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as true as all conditions were met." ) end
                tyrant_ready = true
            end

            if Hekili.ActiveDebug then Hekili:Debug( "Leaving 'tyrant_ready' as " .. tostring( tyrant_ready ) .. "." ) end
            return
        end

        if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false based on cooldown." ) end
        tyrant_ready = false
    end )


    local hog_time = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        local now = GetTime()

        if source == state.GUID then
            if subtype == "SPELL_SUMMON" then
                -- Dreadstalkers: 104316, 12 seconds uptime.
                -- if spellID == 193332 or spellID == 193331 then table.insert( dreadstalkers, now + 12 )

                -- Vilefiend: 264119, 15 seconds uptime.
                -- elseif spellID == 264119 then table.insert( vilefiend, now + 15 )

                -- Wild Imp: 104317 and 279910, 20 seconds uptime.
                -- else
                if spellID == 104317 or spellID == 279910 then
                    table.insert( wild_imps, now + 20 )

                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + 20 ),
                        max = math.ceil( now + 20 )
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
                    hog_time = GetTime()

                    if shards_for_guldan >= 1 then table.insert( guldan, now + 0.6 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, now + 0.8 ) end
                    if shards_for_guldan >= 3 then table.insert( guldan, now + 1 ) end

                    -- Per SimC APL, we go into Tyrant with 5 shards -OR- with Nether Portal up.
                    if IsSpellKnown( 265187 ) then
                        local start, duration = GetSpellCooldown( 265187 )

                        if start and duration and start + duration - now < 4 then
                            state.reset()

                            local np = state.talent.nether_portal.enabled and FindUnitBuffByID( "player", 267218 )

                            if ( not state.talent.doom.enabled or state.action.doom.lastCast - now < 30 ) and 
                            ( state.cooldown.demonic_strength.remains > 4 or not state.talent.demonic_strength.enabled or state.talent.demonic_consumption.enabled ) and 
                            ( state.cooldown.nether_portal.remains > 4 or not state.talent.nether_portal.enabled ) and
                            ( state.cooldown.grimoire_felguard.remains > 4 or not state.talent.grimoire_felguard.enabled ) and 
                            ( state.cooldown.summon_vilefiend.remains > 4 or not state.talent.summon_vilefiend.enabled ) and
                            ( state.cooldown.call_dreadstalkers.remains > 4 ) and
                            ( state.buff.demonic_core.down or shards_for_guldan > 3 or ( not state.talent.demonic_consumption.enabled or np ) ) and
                            ( shards_for_guldan == 5 or np ) then
                                tyrant_ready_actual = true
                            end
                        else
                            tyrant_ready_actual = false
                        end
                    end

                -- Summon Demonic Tyrant.
                elseif spellID == 265187 then
                    tyrant_ready_actual = false

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
        for n, t in pairs( imps ) do table.insert( wild_imps_v, t.expires ) end
        table.sort( wild_imps_v )

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


        if #dreadstalkers_v > 0 then wipe( dreadstalkers_v ) end
        if #vilefiend_v > 0     then wipe( vilefiend_v )     end
        if #grim_felguard_v > 0 then wipe( grim_felguard_v ) end

        -- Pull major demons from Totem API.
        for i = 1, 5 do
            local exists, name, summoned, duration, texture = GetTotemInfo( i )

            if exists then
                local demon

                -- Grimoire Felguard
                if texture == 136216 then demon = grim_felguard_v
                elseif texture == 1616211 then demon = vilefiend_v
                elseif texture == 1378282 then demon = dreadstalkers_v end

                if demon then
                    insert( demon, summoned + duration )
                end
            end

            if #grim_felguard_v > 1 then table.sort( grim_felguard_v ) end
            if #vilefiend_v > 1 then table.sort( vilefiend_v ) end
            if #dreadstalkers_v > 1 then table.sort( dreadstalkers_v ) end
        end

        last_summon.name = nil
        last_summon.at = nil
        last_summon.count = nil

        if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > query_time then
            summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - query_time )
        end

        tyrant_ready = nil

        if cooldown.summon_demonic_tyrant.remains > 5 then
            tyrant_ready = false
        end

        if buff.demonic_power.up then
            summonPet( "demonic_tyrant", buff.demonic_power.remains )
        end

        if Hekili.ActiveDebug then
            Hekili:Debug(   "Is Tyrant Ready?: %s\n" ..
                            " - Dreadstalkers: %d, %.2f\n" ..
                            " - Vilefiend    : %d, %.2f\n" ..
                            " - Grim Felguard: %d, %.2f\n" ..
                            " - Wild Imps    : %d, %.2f\n" ..
                            "Next Demon Exp. : %.2f",
                            tyrant_ready and "Yes" or "No",
                            buff.dreadstalkers.stack, buff.dreadstalkers.remains,
                            buff.vilefiend.stack, buff.vilefiend.remains,
                            buff.grimoire_felguard.stack, buff.grimoire_felguard.remains,
                            buff.wild_imps.stack, buff.wild_imps.remains,
                            major_demon_expires )
        end
    end )


    spec:RegisterHook( "advance_end", function ()
        for i = #guldan_v, 1, -1 do
            local imp = guldan_v[i]

            if imp <= query_time then
                if ( imp + 20 ) > query_time then
                    insert( wild_imps_v, imp + 20 )
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

        for k, v in pairs( dreadstalkers_v ) do dreadstalkers_v[ k ] = v + duration end
        for k, v in pairs( vilefiend_v     ) do vilefiend_v    [ k ] = v + duration end
        for k, v in pairs( wild_imps_v     ) do wild_imps_v    [ k ] = v + duration end
        for k, v in pairs( grim_felguard_v ) do grim_felguard_v[ k ] = v + duration end
        for k, v in pairs( other_demon_v   ) do other_demon_v  [ k ] = v + duration end
    end )


    spec:RegisterStateFunction( "consume_demons", function( name, count )
        local db = other_demon_v

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
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
            duration = 30,
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
                down = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and exp < query_time or true end,
                applied = function () local exp = dreadstalkers_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
                remains = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( dreadstalkers_v ) do
                        if exp >= query_time then c = c + 2 end
                    end
                    return c
                end,
            }
        },

        grimoire_felguard = {
            duration = 17,

            meta = {
                up = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and exp >= query_time or false end,
                down = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and exp < query_time or true end,
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
                down = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and exp < query_time or true end,
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
            duration = 25,

            meta = {
                up = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and exp >= query_time or false end,
                down = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and exp < query_time or true end,
                applied = function () local exp = wild_imps_v[ 1 ]; return exp and ( exp - 20 ) or 0 end,
                remains = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function ()
                    local c = 0
                    for i, exp in ipairs( wild_imps_v ) do
                        if exp > query_time then c = c + 1 end
                    end

                    -- Count queued HoG imps.
                    for i, spawn in ipairs( guldan_v ) do
                        if spawn <= query_time and ( spawn + 20 ) >= query_time then c = c + 1 end
                    end
                    return c
                end,
            }
        },

        other_demon = {
            duration = 20,

            meta = {
                up = function () local exp = other_demon_v[ 1 ]; return exp and exp >= query_time or false end,
                down = function () local exp = other_demon_v[ 1 ]; return exp and exp < query_time or true end,
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
    
    
    --[[ Demonic Tyrant
    spec:RegisterPet( "demonic_tyrant",
        135002,
        "summon_demonic_tyrant",
        15 ) ]]
    
    spec:RegisterTotem( "demonic_tyrant", 135002 )


    spec:RegisterStateExpr( "extra_shards", function () return 0 end )

    --[[ spec:RegisterVariable( "tyrant_ready", function ()
        if cooldown.summon_demonic_tyrant.remains > 5 then return false end
        if talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.ready then return false end
        if talent.nether_portal.enabled and cooldown.nether_portal.ready then return false end
        if talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.ready then return false end
        if talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.ready then return false end
        if cooldown.call_dreadstalkers.ready then return false end
        if buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) then return false end
        if soul_shard < ( buff.nether_portal.up and 1 or 5 ) then return false end
        return true
    end ) ]]


    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 89766,
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
                summon_demon( "dreadstalkers", 12, 2 )
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

            startsCombat = true,
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

            startsCombat = true,

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
                update_tyrant_readiness( 1 + extra_shards )
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
            end,
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
            end,
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
            cast = 2.828,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 136154,

            usable = function () return target.is_demon and target.level < level + 2, "requires demon enemy" end,
            handler = function ()
                summonPet( "controlled_demon" )
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

                tyrant_ready = false

                --[[ if talent.demonic_consumption.enabled then
                    consume_demons( "wild_imps", "all" )
                end ]]

                extend_demons()

                if azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
                if level > 57 then gain( 5, "soul_shards" ) end
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

            usable = function () return not pet.exists end,
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


    spec:RegisterSetting( "implosion_imps", 4, {
        name = "Wild Imps for |T2065588:0|t Implosion",
        desc = "When using |T2065588:0|t Implosion, the default priority will require you to have at least this many Wild Imps.\n\n" ..
            "Current sims reflect that a minimum of 3 imps are needed for optimal DPS in Hectic Add Cleave (but will result in a lot of repetitive Hand of Guldan -> Implosion casts), while using " ..
            "Implosion with 4+ imps is more optimal in 5+ target sustained scenarios.",
        type = "range",
        min = 3,
        max = 10,
        step = 1,
        width = "full"
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

    spec:RegisterPack( "Demonology", 20201222, [[dCehXaqiLk9iLe2ea9jisnkLuoLsQwLsfv9kiQzHu1TGiAxI8lammifhdPYYOK8mLkmniLUMsvTnis6BqeQXPur5CkjQwNsfzEus19GW(us6GkjswiKQhsjfnricUieH4Jkvu5KusjRujmtLeLDci)ujrQHQKiwkej8uvmva1xHirJLsk1Ev1Ff1Gf6WsTyK8yunzkUmXMvPpdjJgPCAfVwPkZgQBly3K(TKHtPooeH0Yb9CuMovxhOTRu67kfJNskCELO5tj2pIF6EG)JPD5bYk0yfAOZkRSkrhAPBh7yN9hFPT8h7MVxJs(J2b5pibjuAHlul)JDVexT5b(pSceYL)qZDB2obaaOgNgivIxbaytae3(ukh2xha2e4a8hkWb7wl9P(JPD5bYk0yfAOZkRSkrhAPBhwTJ)WSf(dKvivK6FOngJOp1FmcJ)NvqIibjuAHluljrKYgIl(EKfRGeP5UnBNaaauJtdKkXRaaSjaIBFkLd7RdaBcCailwbjIeeUeOeijALv0tIwHgRqdzbzXkirRjTwrjSDISyfKissIhBbJjXvwX3lrwScsejjXvAfVKeHcVcbrnKisqcLsvyNeTHcsYRav7K4CjXXjXHrIJY8wDsCTcsI0AOH3mNeVfKePkgtyRNilwbjIKK4kP2iqs8m20kLeBmU2igs0gkijVcuTtIErI2WItIJY8wDsejiHsPkSNilwbjIKKisHSDycjATc24InLsI3csIybLOMgUmrwScsejjXvY2vcj6nwuNeh1fie02t)Xgw3bl)zfKisqcLw4c1ssePSH4IVhzXkirAUBZ2jaaa140aPs8kaaBcG42Ns5W(6aWMahaYIvqIibHlbkbsIwzf9KOvOXk0qwqwScs0AsRvucBNilwbjIKK4XwWysCLv89sKfRGerssCLwXljrOWRqqudjIeKqPuf2jrBOGK8kq1ojoxsCCsCyK4OmVvNexRGKiTgA4nZjXBbjrQIXe26jYIvqIijjUsQncKepJnTsjXgJRnIHeTHcsYRav7KOxKOnS4K4OmVvNercsOuQc7jYIvqIijjIuiBhMqIwRGnUytPK4TGKiwqjQPHltKfRGerssCLSDLqIEJf1jXrDbcbT9ezbzXkirKiwdHd6IHePKBbfsKxbQ2jrkb1OSejUsX5ITZirTuKKwddxqmj2CFkLrILIxMilAUpLYs2qHxbQ2rgbaxbNnvy02NsPFUi8jiRIga31w8uJNTczrZ9PuwYgk8kq1oYiaGbgcLMTfNSO5(uklzdfEfOAhzeayxBeyMn20kL(5IGc8EtBgSjpbBwI5nFVvPdqkW7nzKqPdpZlOKyEZ3Z6iSISO5(uklzdfEfOAhzeayKqPuf2PFUiwJQymlwAUpLMmsOuQc7jEZCeOzDazfioZO1qdZ6OLSyfKyZ9PuwYgk8kq1oYiayBdNMcl0RDqq4lHT6zO0ML0VTXGccEvytTrtmWqO0SrcLo8SVe2QNGsOhLz99bCTD9glQNmvfsI2uyXyXIrOaV3KPQqc0EDaxJc8Etgju6WZmhkkkNwc02ILD9glQNmsO0HNzouuuoTKOnfwmwS4nwupzKqPdpZlLbgS9P0KOnfwmRd4A76nwupPIttGz7c6nojAtHfJfluG3BsfNMaZ2f0BCc02IfEvytTrtQ40ey2UGEJtqj0JYwLU9xhW121BSOEcfCc1aL8vWOaBOjjAtHfJfl8QWMAJMqbNqnqjFfmkWgAsqj0JYwLU9xhW121BSOEIbgcLM3oy5oIAsI2uyXyXcVkSP2OjgyiuAE7GL7iQjbLqpkBv62FDaxBxVXI6jJekD4zEPmWGTpLMeTPWIXIfkW7nTzWM8eSzjqBlwyfioZO1qdI9TyHc8EtQ40ey2UGEJtG2aYkqCMrRHMvrZ6KfKfRGerIyneoOlgsu2kWLKOpbHeDAcj2CVGK4WiXEBp4McljYIM7tPmemBbJZ4IVhzrZ9PugYiaG3yC(kyAGQlqYIM7tPmKraqBnKSxmgzrZ9PugYiaWiBlqyo0OgozrZ9PugYiaG3yCU5(uAgpmNETdcI6EZO4gYIM7tPmKraaeuZn3NsZ4H50RDqq4lHT6zBOytpZHd3rqh9ZfbVkSP2OjgyiuA2iHshE2xcB1tqj0JYSoAbCxFjSvpdL2SKSO5(ukdzeaab1CZ9P0mEyo9AheemWqO0SVe2QtpZHd3rqh9ZfHVe2QNHsBwsw0CFkLHmcayGHqP5TdwUJOg6NlcEvytTrtmWqO0SrcLo8SVe2QNGsOhLTkArJfl3bfnpdLqpkZ68QWMAJMyGHqPzJekD4zFjSvpbLqpkdzR2NSO5(ukdzeaWBmoBGsByEJ3tGmYIM7tPmKraGPQa9ZfbuUqHrRPWczrZ9PugYiaWiHshEM5qrr50ilAUpLYqgbaudwy8ceIsYuvGsGmYIM7tPmKraWeSXfBkL(5IO5(SvYIkHryRshG76nwupXAoCUdxmzwbIzjrBkSyaKc8EtBgSjpbBwI5nFVvrWe3hfflnbBCXMsZtWMbif49M8LWw9KP2OaYRcBQnAIbgcLMnsO0HN9LWw9euc9OSv3hW1OaV30eSXfB2kz7Yf1NgNm1g1ILDHGQClikjnbBCXMTs2UCr9PXjrBkSywNSO5(ukdzeambBCXMsPFUiAUpBLSOsye2Qwbif49M2mytEc2SeZB(ERIGjUpkkwAc24InLMNGndqkW7n5lHT6jtTrbCnkW7nnbBCXMTs2UCr9PXjtTrTyzxiOk3cIsstWgxSzRKTlxuFACs0MclM1jlAUpLYqgba0A1KRBgfi20k9ZfbRaXzgTgAqSVfluG3BsfNMaZ2f0BCc0MSO5(ukdzeaqRvtUUzuGytR0pxeSceNz0AOzve7aqEvytTrtmWqO0SrcLo8SVe2QNGsOhLTQvObW14vHn1gnXadHsZBhSChrnjOe6rzRUVfl76nwupXadHsZBhSChrnjrBkSywhqEvytTrt8gJZgO0gM349eilbLqpkBvRilAUpLYqgba8gJZn3NsZ4H50RDqqWRTI2QtpZHd3rqh9ZfXA8AROT6jv4WcxqJfl8AROT6jDqrZZ3wwhWD9glQNuXPjWSDb9gNeTPWIHSO5(ukdzeayKqPuf2PFUiOaV3KrcLo8mVGsckn3bKvG4mJwdnwhTKfn3NsziJaauWjuduYxbJcSHg6NlcEvytTrtmWqO0SrcLo8SVe2QNGsOhLHmVkSP2OjgyiuA2iHshE2xcB1tgqy7tPREhu08muc9OmlwUdkAEgkHEuM15vHn1gnXadHsZgju6WZ(syREckHEugY0TpzrZ9PugYiaaKj5XLaJSO5(ukdzeayxBeyMn20kL(5IGc8EtBgSjpbBwI5nFVvPdqkW7nzKqPdpZlOKyEZ3Z67GSO5(ukdzeaWkqCM5WzpHSO5(ukdzeaWBmo3CFknJhMtV2bbbV2kARozrZ9PugYiaGrRn1MmvHDYcYIM7tPSeV2kARoIjylQzuuzE7nZHLnnH(5IyxVXI6jwZHZD4IjZkqmljAtHfJfln3NTswujmcBv6ilAUpLYs8AROT6iJaagVaHJIk7JttOFUi8glQNynho3HlMmRaXSKOnfwma2CF2kzrLWime0rw0CFkLL41wrB1rgbamEbchfv2hNMq)CrSR3yr9eR5W5oCXKzfiMLeTPWIbWM7ZwjlQegHzD0sw0CFkLL41wrB1rgbaSceNHLtw0CFkLL41wrB1rgbagHpH2hfvMQWozbzrZ9PuwQU3mkUbbLazcCVrrr)CrylEYiHshE2xcB1tn3NTczrZ9PuwQU3mkUbzeayx(uk9Zfbf49MOeitG7nkQeOTfl2INmsO0HN9LWw9uZ9zRa4UWMljhwymzrZ9PuwQU3mkUbzeaqHRYKVGWL0pxe2INmsO0HN9LWw9uZ9zRqw0CFkLLQ7nJIBqgba3bku4Qm0pxe2INmsO0HN9LWw9uZ9zRqwqw0CFkLLyGHqPzFjSvhbTwn56MrbInTs)CrWkqCMrRHge7tw0CFkLLyGHqPzFjSvhzeayKqPuf2PFUiOaV3KrcLo8mVGsc0gW18glQNmsO0HN5LYad2(uAs0MclglwOaV3KkonbMTlO34KP2ORtpEujZniScnKfn3NszjgyiuA2xcB1rgbamATP2KPkSt)CrqbEVPnd2KNGnlX8MVhYJYRWOOYtWMzD0c4AEJf1tgju6WZ8szGbBFknjAtHfJfluG3BsfNMaZ2f0BCYuB01PhpQK5gewHgYIM7tPSedmekn7lHT6iJaauWjuduYxbJcSHgYIM7tPSedmekn7lHT6iJaagyiuAE7GL7iQHSO5(uklXadHsZ(syRoYiaG3yC2aL2W8gVNazKfn3NszjgyiuA2xcB1rgba0A1KRBgfi20kzrZ9PuwIbgcLM9LWwDKraGrcLsvyN(5IGc8Etgju6WZ8ckjqBaPaV3KkonbMTlO34eOnGRTgf49M2oy5oIAsqj0JYwDFlw21BSOEIbgcLM3oy5oIAsI2uyXSoGRrbEVjuWjuduYxbJcSHMeuc9OSv33IfkW7nHcoHAGs(kyuGn0Km1gD91jlAUpLYsmWqO0SVe2QJmcay0AtTjtvyN(5IGc8EtQ40ey2UGEJtG2aU2AuG3BA7GL7iQjbLqpkB19TyzxVXI6jgyiuAE7GL7iQjjAtHfZ6aUgf49MqbNqnqjFfmkWgAsqj0JYwDFlwOaV3ek4eQbk5RGrb2qtYuB01xNSyfKyZ9PuwIbgcLM9LWwDKraW2gonfwOx7GGWxcB1ZqPnlPFBJbfe7YRcBQnAIbgcLMnsO0HN9LWw9euAZsYIM7tPSedmekn7lHT6iJaagyiuA2iHshE2xcB1PFUi21BSOEYiHshEMxkdmy7tPwSqbEVPnd2KNGnlX8MVhYtWMLz29gvmzdiCuujgyiuA2iHshE2xcB1xDhKfn3NszjgyiuA2xcB1rgbamATP2KPkStwqw0CFkLL8LWw9SnuSryQkqpEujZni2bAilAUpLYs(syRE2gk2iJaaJekD4zMdffLtJ(5IyxVXI6jJekD4zEPmWGTpLMeTPWIHSO5(ukl5lHT6zBOyJmcauXPjWSDb9gtw0CFkLL8LWw9SnuSrgbaOGtOgOKVcgfydn0pxeSceNz0AObX(Kfn3NszjFjSvpBdfBKraadmeknVDWYDe1q)CrWkqCMrRHgeOfW121BSOEcfCc1aL8vWOaBOXIfEvytTrtOGtOgOKVcgfydnjOe6rzRtw0CFkLL8LWw9SnuSrgba8gJZgO0gM349eiJ(5IyxVXI6juWjuduYxbJcSHglw4vHn1gnHcoHAGs(kyuGn0KGsOhLrw0CFkLL8LWw9SnuSrgbagjukvHD6NlckW7nzKqPdpZlOKaTbKvG4mJwdnwhTaUM3yr9KrcLo8mVugyW2NstI2uyXyXcf49MuXPjWSDb9gNm1gDDYIM7tPSKVe2QNTHInYiaGrRn1MmvHD6NlcwbIZmAn0y99rs0UZtbEVjvCAcmBxqVXjqBYIvqIn3NszjFjSvpBdfBKraW2gonfwOx7GGWxcB1ZqPnlPFBJbfe0rw0CFkLL8LWw9SnuSrgba0A1KRBgfi206F2kq2u6dKvOXk0qNvOzLNS6pBAOokk2FqkxPqkaYAb0o3orIKiW0esCc2f0jXBbjrKMbgcLM9LWwDKMeHcsuWbkgsKvbHeBqVcTlgsKtRvuclrwSYgvir6qZorIwZs3kqxmKis7nwupzTrAs0lseP9glQNS2jrBkSyqAsCn6SgRNililqkxPqkaYAb0o3orIKiW0esCc2f0jXBbjrK2xcB1Z2qXgPjrOGefCGIHezvqiXg0Rq7IHe50AfLWsKfRSrfsC)DIeTMLUvGUyirK2BSOEYAJ0KOxKis7nwupzTtI2uyXG0K4A0znwprwSYgvirK6orIwZs3kqxmKis7nwupzTrAs0lseP9glQNS2jrBkSyqAsCn6SgRNililSwb7c6IHerQKyZ9PusepmNLil(dEyo7b(p8AROT6pWpq09a)hrBkSyE0)dhoUaN(p7sIEJf1tSMdN7WftMvGyws0Mclgs0IfsS5(SvYIkHryK4QKiD)P5(u6FMGTOMrrL5T3mhw20K3FGS6b(pI2uyX8O)hoCCbo9F8glQNynho3HlMmRaXSKOnfwmKiGKyZ9zRKfvcJWireKiD)P5(u6Fy8ceokQSpon59hOD8a)hrBkSyE0)dhoUaN(p7sIEJf1tSMdN7WftMvGyws0MclgseqsS5(SvYIkHryKO1jr0(NM7tP)HXlq4OOY(40K3FGq7d8FAUpL(hwbIZWY)JOnfwmp6V)aT)d8FAUpL(hJWNq7JIktvy)pI2uyX8O)(7)Xi3ge7pWpq09a)NM7tP)HzlyCgx89(JOnfwmp6V)az1d8FAUpL(hEJX5RGPbQUa)JOnfwmp6V)aTJh4)0CFk9pT1qYEXy)r0MclMh93FGq7d8FAUpL(hJSTaH5qJA4)r0MclMh93FG2)b(pI2uyX8O)NM7tP)H3yCU5(uAgpm)p4H5zTdYFQ7nJIBE)bcP(a)hrBkSyE0)dhoUaN(p8QWMAJMyGHqPzJekD4zFjSvpbLqpkJeTojIwseqsCxs0xcB1ZqPnl)dZHd3FGO7pn3Ns)deuZn3NsZ4H5)bpmpRDq(JVe2QNTHI97pqiXpW)r0MclMh9)WHJlWP)JVe2QNHsBw(hMdhU)ar3FAUpL(hiOMBUpLMXdZ)dEyEw7G8hgyiuA2xcB1F)bAN9a)hrBkSyE0)dhoUaN(p8QWMAJMyGHqPzJekD4zFjSvpbLqpkJexLerlAirlwiX7GIMNHsOhLrIwNe5vHn1gnXadHsZgju6WZ(syREckHEugjImjA1()P5(u6FyGHqP5TdwUJOM3FGw5pW)P5(u6F4ngNnqPnmVX7jq2FeTPWI5r)9hi6qZd8FeTPWI5r)pC44cC6)aLluy0AkS8NM7tP)Xuv49hi6O7b(pn3Ns)JrcLo8mZHIIYP9hrBkSyE0F)bIoREG)tZ9P0)qnyHXlqikjtvbkbY(JOnfwmp6V)ar3oEG)JOnfwmp6)HdhxGt)NM7ZwjlQegHrIRsI0rIasI7sIEJf1tSMdN7WftMvGyws0MclgseqsKc8EtBgSjpbBwI5nFpsCveKitCFuuS0eSXfBknpbBgjcijsbEVjFjSvpzQnkjcijYRcBQnAIbgcLMnsO0HN9LWw9euc9OmsCvsCFseqsCnsKc8EttWgxSzRKTlxuFACYuBus0IfsCxsecQYTGOK0eSXfB2kz7Yf1NgNeTPWIHex)pn3Ns)ZeSXfBk99hi6q7d8FeTPWI5r)pC44cC6)0CF2kzrLWimsCvs0kseqsKc8EtBgSjpbBwI5nFpsCveKitCFuuS0eSXfBknpbBgjcijsbEVjFjSvpzQnkjcijUgjsbEVPjyJl2SvY2LlQpnozQnkjAXcjUljcbv5wqusAc24InBLSD5I6tJtI2uyXqIR)NM7tP)zc24InL((deD7)a)hrBkSyE0)dhoUaN(pSceNz0AOHerqI7tIwSqIuG3BsfNMaZ2f0BCc0(pn3Ns)dTwn56MrbInT((deDi1h4)iAtHfZJ(F4WXf40)HvG4mJwdnK4QiiXDqIasI8QWMAJMyGHqPzJekD4zFjSvpbLqpkJexLeTcnKiGK4AKiVkSP2OjgyiuAE7GL7iQjbLqpkJexLe3NeTyHe3Le9glQNyGHqP5TdwUJOMKOnfwmK46KiGKiVkSP2OjEJXzduAdZB8EcKLGsOhLrIRsIw9NM7tP)HwRMCDZOaXMwF)bIoK4h4)iAtHfZJ(F4WXf40)znsKxBfTvpPchw4cAirlwirETv0w9KoOO55BlK46KiGK4UKO3yr9KkonbMTlO34KOnfwm)H5WH7pq09NM7tP)H3yCU5(uAgpm)p4H5zTdYF41wrB1F)bIUD2d8FeTPWI5r)pC44cC6)qbEVjJekD4zEbLeuAUtIasISceNz0AOHeTojI2)0CFk9pgjukvH93FGOBL)a)hrBkSyE0)dhoUaN(p8QWMAJMyGHqPzJekD4zFjSvpbLqpkJerMe5vHn1gnXadHsZgju6WZ(syREYacBFkLexLeVdkAEgkHEugjAXcjEhu08muc9Oms06KiVkSP2OjgyiuA2iHshE2xcB1tqj0JYirKjr62)pn3Ns)dk4eQbk5RGrb2qZ7pqwHMh4)0CFk9pGmjpUey)r0MclMh93FGSIUh4)iAtHfZJ(F4WXf40)Hc8EtBgSjpbBwI5nFpsCvsKoseqsKc8Etgju6WZ8ckjM389irRtI74pn3Ns)JDTrGz2ytR03FGSYQh4)0CFk9pSceNzoC2t(JOnfwmp6V)az1oEG)JOnfwmp6)P5(u6F4ngNBUpLMXdZ)dEyEw7G8hETv0w93FGScTpW)P5(u6Fy0AtTjtvy)pI2uyX8O)(7)Xgk8kq1(d8deDpW)r0MclMh9)WHJlWP)JpbHexLerdjcijUljAlEQXZw5pn3Ns)ZvWztfgT9P03FGS6b(pn3Ns)ddmeknpb7)iAtHfZJ(7pq74b(pI2uyX8O)hoCCbo9FOaV30MbBYtWMLyEZ3JexLePJebKePaV3KrcLo8mVGsI5nFps06iirR(tZ9P0)yxBeyMn20k99hi0(a)hrBkSyE0)dhoUaN(pRrIufJrIwSqIn3NstgjukvH9eVzojIGerdjUojcijYkqCMrRHggjADseT)P5(u6FmsOuQc7V)(FyGHqPzFjSv)b(bIUh4)iAtHfZJ(F4WXf40)HvG4mJwdnKicsC))0CFk9p0A1KRBgfi2067pqw9a)hrBkSyE0)dhoUaN(puG3BYiHshEMxqjbAtIasIRrIEJf1tgju6WZ8szGbBFknjAtHfdjAXcjsbEVjvCAcmBxqVXjtTrjX1)tZ9P0)yKqPuf2)dEujZn)Xk08(d0oEG)JOnfwmp6)HdhxGt)hkW7nTzWM8eSzjM389irKjXr5vyuu5jyZirRtIOLebKexJe9glQNmsO0HN5LYad2(uAs0Mclgs0IfsKc8EtQ40ey2UGEJtMAJsIR)NM7tP)HrRn1MmvH9)GhvYCZFScnV)aH2h4)0CFk9pOGtOgOKVcgfydn)r0MclMh93FG2)b(pn3Ns)ddmeknVDWYDe18hrBkSyE0F)bcP(a)NM7tP)H3yC2aL2W8gVNaz)r0MclMh93FGqIFG)tZ9P0)qRvtUUzuGytR)r0MclMh93FG2zpW)r0MclMh9)WHJlWP)df49MmsO0HN5fusG2KiGKif49MuXPjWSDb9gNaTjrajX1iX1irkW7nTDWYDe1KGsOhLrIRsI7tIwSqI7sIEJf1tmWqO082bl3ruts0MclgsCDseqsCnsKc8EtOGtOgOKVcgfydnjOe6rzK4QK4(KOflKif49MqbNqnqjFfmkWgAsMAJsIRtIR)NM7tP)XiHsPkS)(d0k)b(pI2uyX8O)hoCCbo9FOaV3KkonbMTlO34eOnjcijUgjUgjsbEVPTdwUJOMeuc9OmsCvsCFs0IfsCxs0BSOEIbgcLM3oy5oIAsI2uyXqIRtIasIRrIuG3BcfCc1aL8vWOaBOjbLqpkJexLe3NeTyHePaV3ek4eQbk5RGrb2qtYuBusCDsC9)0CFk9pmATP2KPkS)(deDO5b(pI2uyX8O)hoCCbo9F2Le9glQNmsO0HN5LYad2(uAs0Mclgs0IfsKc8EtBgSjpbBwI5nFpsezsCc2SmZU3OIjBaHJIkXadHsZgju6WZ(syRojUkjUJ)0CFk9pmWqO0SrcLo8SVe2Q)(deD09a)NM7tP)HrRn1MmvH9)iAtHfZJ(7V)N6EZO4Mh4hi6EG)JOnfwmp6)HdhxGt)hBXtgju6WZ(syREQ5(Sv(tZ9P0)qjqMa3BuuV)az1d8FeTPWI5r)pC44cC6)qbEVjkbYe4EJIkbAtIwSqI2INmsO0HN9LWw9uZ9zRqIasI7sIWMljhwy8FAUpL(h7YNsF)bAhpW)r0MclMh9)WHJlWP)JT4jJekD4zFjSvp1CF2k)P5(u6FOWvzYxq4Y3FGq7d8FeTPWI5r)pC44cC6)ylEYiHshE2xcB1tn3NTYFAUpL(N7afkCvM3F)p(syRE2gk2pWpq09a)hrBkSyE0)tZ9P0)yQk8h8OsMB(ZoqZ7pqw9a)hrBkSyE0)dhoUaN(p7sIEJf1tgju6WZ8szGbBFknjAtHfZFAUpL(hJekD4zMdffLt79hOD8a)NM7tP)rfNMaZ2f0B8FeTPWI5r)9hi0(a)hrBkSyE0)dhoUaN(pSceNz0AOHerqI7)NM7tP)bfCc1aL8vWOaBO59hO9FG)JOnfwmp6)HdhxGt)hwbIZmAn0qIiir0sIasIRrI7sIEJf1tOGtOgOKVcgfydnjrBkSyirlwirEvytTrtOGtOgOKVcgfydnjOe6rzK46)P5(u6FyGHqP5TdwUJOM3FGqQpW)r0MclMh9)WHJlWP)ZUKO3yr9ek4eQbk5RGrb2qts0Mclgs0IfsKxf2uB0ek4eQbk5RGrb2qtckHEu2FAUpL(hEJXzduAdZB8EcK9(des8d8FeTPWI5r)pC44cC6)qbEVjJekD4zEbLeOnjcijYkqCMrRHgs06KiAjrajX1irVXI6jJekD4zEPmWGTpLMeTPWIHeTyHePaV3KkonbMTlO34KP2OK46)P5(u6FmsOuQc7V)aTZEG)JOnfwmp6)HdhxGt)hwbIZmAn0qIwNe3NersseTK4opjsbEVjvCAcmBxqVXjq7)0CFk9pmATP2KPkS)(d0k)b(pn3Ns)dTwn56MrbInT(hrBkSyE0F)93)td60k4FotWA((7)d]] )


end
