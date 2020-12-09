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

        potion = "unbridled_fury",

        package = "Demonology",
    } )

    spec:RegisterPack( "Demonology", 20201209.2, [[dCu(VaqivsEKaQnbr(eKIgLsPoLsjRsPGYRGOMfIQBPuvTlr9lvIHPsQJHOSmLeptPQmniLUMsv2MaGVbPGghKc5CkfQ1PuG5jGCpiSpLKoOauzHqQEOaetuPqUOau1hvkO6KcqzLc0mvki7uLYpHuadvaKLcPq9uvmvvQ(QaOgRaK2RQ(RidwOdlzXi8yuMmfxMyZa(mKmAe50kETsrZgPBtPDt63snCL44qkqlh0Zr10P66aTDLkFxj14fa68cQ5li7hQFY(7)XuU83w56vUMSvUEJZKTVvwbTR8hp8I8NLITzHs(Jww5pBKyBTPnQW)zPct7Y83)dVbHm5pKCFHVbxUGACsGezwBVWhliT8PvgSa8l8XYU8hcWH6bm9j(JPC5VTY1RCnzRC9gNjBFRC9EO9p8fH93wjaea(dPXye9j(Jr4S)eyCCJeBRnTrfghdWfK2SnXbdmosY9f(gC5cQXjbsKzT9cFSG0YNwzWcWVWhl7coyGXXnsyILqG44gtooUY1RCnoioyGXXacPsrj8nahmW44(XXZIqP44gQzBMXbdmoUFCenGsdJJqH1wROgCCJeBRen1XXfOSFwBjkhhhaCCCCC444OCVuhh3UH4iPcAyf3XrGgIJenNl8TY4Gbgh3pogG61cehpZcPwXXIs71IbhxGY(zTLOCC0BCCb2mCCuUxQJJBKyBLOPEghmW44(Xr0yz3WfCmGzxOnFAfhjkUyWXwXXaCVMKugCef4yKmoyGXX9JJbODbiC0lQOoooQlqi4IN)ZcSbgQ8NaJJBKyBTPnQW4yaUG0MTjoyGXrsUVW3GlxqnojqImRTx4JfKw(0kdwa(f(yzxWbdmoUrctSeceh3yYXXvUELRXbXbdmogqivkkHVb4Gbgh3poEwekfh3qnBZmoyGXX9JJObuAyCekS2Af1GJBKyBLOPooUaL9ZAlr544aGJJJJdhhhL7L6442nehjvqdR4ooc0qCKO5CHVvghmW44(XXauVwG44zwi1kowuAVwm44cu2pRTeLJJEJJlWMHJJY9sDCCJeBRen1Z4Gbgh3poIgl7gUGJbm7cT5tR4irXfdo2kogG71KKYGJOahJKXbdmoUFCmaTlaHJErf1XXrDbcbx8moioyGXXa(aOWaDXGJecqdfCK1wIYXrcb1O8mogWXyYIZXrT19tQGwaqkowmFALJJTsdNXblMpTYZlqH1wIYrgXfaHMmTD0YNwjFaq4Jvw9AKUAr8CrNDcoyX8PvEEbkS2suoYiUWbT2wtlIJdwmFALNxGcRTeLJmIll9AbM4ZcPwjFaqqacaKxputASl8m3l2MRsgseGaazJyBDyjwdLm3l2MbcXk4GfZNw55fOWAlr5iJ4IrSTs0uN8baX2enNhkuX8P1SrSTs0upZkUJ46TqI3G0eNubn8aHwCWaJJfZNw55fOWAlr5iJ4YUcofbvixlRGWddl1tqPmHjFxrbfeSUPMETM5GwBRjJyBDyjpmSupdfBnkpq7H02x5fvupB62MfTiOIjuiJqacaKnDBZGlBH02eGaazJyBDyjUdffLtkdUek0vErf1ZgX26WsChkkkNuw0IGkMqH8IkQNnIT1HLyTYbTl(0Aw0IGkMTqA7R8IkQNvXjjW0sd9IMfTiOIjuicqaGSkojbMwAOx0m4sOqSUPMETMvXjjW0sd9IMHITgLVkz7TfsBFLxur9mk4y7bkjaHIcSGMSOfbvmHcX6MA61AgfCS9aLeGqrbwqtgk2Au(QKT3wiT9vErf1ZCqRT10UHkaJOMSOfbvmHcX6MA61AMdATTM2nubye1KHITgLVkz7TfsBFLxur9SrSToSeRvoODXNwZIweuXekebiaqE9qnPXUWZGlHcXBqAItQGge7fkebiaqwfNKatln0lAgCbjEdstCsf0S61BHdIdgyCmGpakmqxm4OStGHXrFSco6KeCSyEdXXHJJ1UAOfbvY4GfZNw5i4lcLMOnBtCWI5tRCKrCHvuAcqOKavxG4GfZNw5iJ4sfaLK3CooyX8PvoYiUyKDnimzluddhSy(0khzexyfLMkMpTMOd3jxlRGObasOygCWI5tRCKrCbcQPI5tRj6WDY1Yki8WWs90cuwiN7WH5iiJ8babRBQPxRzoO12AYi2whwYddl1ZqXwJYdeAr6kpmSupbLYeghSy(0khzexGGAQy(0AIoCNCTSccoO12AYddl1jN7WH5iiJ8baHhgwQNGszcJdwmFALJmIlCqRT10UHkaJOgYhaeSUPMETM5GwBRjJyBDyjpmSupdfBnkFv0EDOqadksEck2AuEGyDtn9AnZbT2wtgX26WsEyyPEgk2AuoYRShoyX8PvoYiUWkknzGsz4Er3uGCCWI5tRCKrCX0TL8babuaGcNurqfCWI5tRCKrCXi2whwI7qrr5KWblMpTYrgXfIHkCwdcrjjI2siqooyX8PvoYiUm2fAZNwjFaqumF2jjrf7i8vjdPR8IkQN5fdoadtmjEds5zrlcQyqIaeaiVEOM0yx4zUxSnxfbxCFuu88yxOnFAnn2foseGaazpmSupB61ksSUPMETM5GwBRjJyBDyjpmSupdfBnkF19WblMpTYrgXLXUqB(0k5daII5ZojjQyhHV6kiracaKxputASl8m3l2MRIGlUpkkEESl0MpTMg7chjcqaGShgwQNn9AfhSy(0khzexivQj1ajuGutPKpai4ninXjvqdI9cfIaeaiRItsGPLg6fndUGdwmFALJmIlKk1KAGekqQPuYhae8gKM4KkOzve7djw3utVwZCqRT1KrSToSKhgwQNHITgLV6kxJ02SUPMETM5GwBRPDdvagrnzOyRr5RUxOqx5fvupZbT2wt7gQamIAYIweuXSfsSUPMETMzfLMmqPmCVOBkqEgk2Au(QRGdwmFALJmIlSIstfZNwt0H7KRLvqW6DIwQto3HdZrqg5daITz9orl1ZQWGnTHMqHy9orl1Z6GIKNakzlKUYlQOEwfNKatln0lAw0IGkgCWI5tRCKrCXi2wjAQt(aGGaeaiBeBRdlXAOKHsXCK4ninXjvqtGqloyX8PvoYiUGco2EGscqOOalOH8babRBQPxRzoO12AYi2whwYddl1ZqXwJYrM1n10R1mh0ABnzeBRdl5HHL6zdiS8P1vbguK8euS1O8qHaguK8euS1O8aX6MA61AMdATTMmIT1HL8WWs9muS1OCKjBpCWI5tRCKrCbKlPXflhhSy(0khzexw61cmXNfsTs(aGGaeaiVEOM0yx4zUxSnxLmKiabaYgX26WsSgkzUxSnd0(WblMpTYrgXfEdstChoBk4GfZNw5iJ4cRO0uX8P1eD4o5AzfeSENOL64GfZNw5iJ4cNuz61jIM64G4GfZNw5zwVt0sDeJDruZOOsSYlUd7fsc5daIR8IkQN5fdoadtmjEds5zrlcQycfQy(StsIk2r4RsgoyX8PvEM17eTuhzex4SgeokQKpojH8baHxur9mVyWbyyIjXBqkplArqfdsfZNDssuXochbz4GfZNw5zwVt0sDKrCHZAq4OOs(4KeYhaex5fvupZlgCagMys8gKYZIweuXGuX8zNKevSJWdeAXblMpTYZSENOL6iJ4cVbPjy74GfZNw5zwVt0sDKrCXiSXw(OOsen1XbXblMpTYZnaqcfZGGqGCbU5OOiFaqSiE2i2whwYddl1ZfZNDcoyX8PvEUbasOygKrCzP9PvYhaeeGaazcbYf4MJIkdUek0I4zJyBDyjpmSupxmF2jiDfSys2HnLIdwmFALNBaGekMbzexiODBsaGWWKpaiwepBeBRdl5HHL65I5ZobhSy(0kp3aajumdYiUamqHG2TH8baXI4zJyBDyjpmSupxmF2j4G4GfZNw5zoO12AYddl1rqQutQbsOaPMsjFaqWBqAItQGge7HdwmFALN5GwBRjpmSuhzexmITvIM6KpaiiabaYgX26WsSgkzWfK22lQOE2i2whwI1kh0U4tRzrlcQycfIaeaiRItsGPLg6fnB616wKthvsmdIvUghSy(0kpZbT2wtEyyPoYiUWjvMEDIOPo5daccqaG86HAsJDHN5EX2e5rzTDuuPXUWdeArABVOI6zJyBDyjwRCq7IpTMfTiOIjuicqaGSkojbMwAOx0SPxRBroDujXmiw5ACWI5tR8mh0ABn5HHL6iJ4ck4y7bkjaHIcSGgCWI5tR8mh0ABn5HHL6iJ4ch0ABnTBOcWiQbhSy(0kpZbT2wtEyyPoYiUWkknzGsz4Er3uGCCWI5tR8mh0ABn5HHL6iJ4cPsnPgiHcKAkfhSy(0kpZbT2wtEyyPoYiUyeBRen1jFaqqacaKnIT1HLynuYGliracaKvXjjW0sd9IMbxqA7TjabaY7gQamIAYqXwJYxDVqHUYlQOEMdATTM2nubye1KfTiOIzlK2MaeaiJco2EGscqOOalOjdfBnkF19cfIaeaiJco2EGscqOOalOjB616wBHdwmFALN5GwBRjpmSuhzex4KktVor0uN8babbiaqwfNKatln0lAgCbPT3MaeaiVBOcWiQjdfBnkF19cf6kVOI6zoO12AA3qfGrutw0IGkMTqABcqaGmk4y7bkjaHIcSGMmuS1O8v3luicqaGmk4y7bkjaHIcSGMSPxRBTfoyGXXI5tR8mh0ABn5HHL6iJ4YUcofbvixlRGWddl1tqPmHjFxrbfexX6MA61AMdATTMmIT1HL8WWs9muktyCWI5tR8mh0ABn5HHL6iJ4ch0ABnzeBRdl5HHL6KpaiUYlQOE2i2whwI1kh0U4tRHcracaKxputASl8m3l2Mip2fEIVuRvXKmGWrrL5GwBRjJyBDyjpmSuF19HdwmFALN5GwBRjpmSuhzex4KktVor0uhhehSy(0kp7HHL6PfOSGW0TLC6OsIzqSVRXblMpTYZEyyPEAbkliJ4IrSToSe3HIIYjr(aG4kVOI6zJyBDyjwRCq7IpTMfTiOIbhSy(0kp7HHL6PfOSGmIlQ4KeyAPHErXblMpTYZEyyPEAbkliJ4ck4y7bkjaHIcSGgYhae8gKM4KkObXE4GfZNw5zpmSupTaLfKrCHdATTM2nubye1q(aGG3G0eNubniqlsBFLxur9mk4y7bkjaHIcSGMqHyDtn9AnJco2EGscqOOalOjdfBnkFlCWI5tR8ShgwQNwGYcYiUWkknzGsz4Er3uGCYhaex5fvupJco2EGscqOOalOjuiw3utVwZOGJThOKaekkWcAYqXwJYXblMpTYZEyyPEAbkliJ4IrSTs0uN8babbiaq2i2whwI1qjdUGeVbPjoPcAceArABVOI6zJyBDyjwRCq7IpTMfTiOIjuicqaGSkojbMwAOx0SPxRBHdwmFALN9WWs90cuwqgXfoPY0Rten1jFaqWBqAItQGMaT3(r7ggbiaqwfNKatln0lAgCbhmW4yX8PvE2ddl1tlqzbzex2vWPiOc5AzfeEyyPEckLjm57kkOGGmCWI5tR8ShgwQNwGYcYiUqQutQbsOaPMs)ZobYNw)BRC9kxt2kxVXzY(Z6cQJII)NaCahA8Ta2Tn8nahXX7KeCCSln0XrGgIJOjh0ABn5HHL6Ojocf0GGdum4iVTcowGEBlxm4iJuPOeEghCdnQGJKD9gGJbKw3jqxm4iA6fvuphqrtC0BCen9IkQNdOzrlcQyqtCCBYcGBLXbXbdWbCOX3cy32W3aCehVtsWXXU0qhhbAioIMEyyPEAbklOjocf0GGdum4iVTcowGEBlxm4iJuPOeEghCdnQGJ7Tb4yaP1Dc0fdoIMErf1Zbu0eh9ghrtVOI65aAw0IGkg0eh3MSa4wzCWn0Ocoga2aCmG06ob6IbhrtVOI65akAIJEJJOPxur9CanlArqfdAIJBtwaCRmoioyaZU0qxm4yaahlMpTIJ0H78mo4FOd35)9)W6DIwQ)3)BK93)JOfbvmp6)HbhxGt9NRWrVOI6zEXGdWWetI3GuEw0IGkgCmuiCSy(StsIk2r444Q4iz)Py(06Fg7IOMrrLyLxCh2lKK3)BR83)JOfbvmp6)HbhxGt9hVOI6zEXGdWWetI3GuEw0IGkgCejCSy(StsIk2r44icCKS)umFA9pCwdchfvYhNK8(FBF)9)iArqfZJ(FyWXf4u)5kC0lQOEMxm4ammXK4niLNfTiOIbhrchlMp7KKOIDeoogiCeT)Py(06F4SgeokQKpoj59)gA)7)Py(06F4ninbB)pIweuX8O)(FBV)(FkMpT(hJWgB5JIkr0u)pIweuX8O)(7)Xiafi1)7)nY(7)Py(06F4lcLMOnBZ)iArqfZJ(7)Tv(7)Py(06FyfLMaekjq1f4FeTiOI5r)9)2((7)Py(06FQaOK8MZ)JOfbvmp6V)3q7F)pfZNw)Jr21GWKTqnS)iArqfZJ(7)T9(7)r0IGkMh9)umFA9pSIstfZNwt0H7)HoCpPLv(tdaKqXmV)3ca)9)iArqfZJ(FyWXf4u)H1n10R1mh0ABnzeBRdl5HHL6zOyRr54yGWr0IJiHJxHJEyyPEckLj8F4oCy(FJS)umFA9pqqnvmFAnrhU)h6W9Kww5pEyyPEAbklV)3qd)7)r0IGkMh9)WGJlWP(JhgwQNGszc)hUdhM)3i7pfZNw)deutfZNwt0H7)HoCpPLv(dh0ABn5HHL6V)3qJ(7)r0IGkMh9)WGJlWP(dRBQPxRzoO12AYi2whwYddl1ZqXwJYXXvXr0EnogkeocmOi5jOyRr54yGWrw3utVwZCqRT1KrSToSKhgwQNHITgLJJiJJRS3FkMpT(hoO12AA3qfGruZ7)Tn(V)NI5tR)HvuAYaLYW9IUPa5)r0IGkMh93)BKD9F)pIweuX8O)hgCCbo1FGcau4KkcQ8NI5tR)X0T99)gzK93)tX8P1)yeBRdlXDOOOCs)r0IGkMh93)BKTYF)pfZNw)dXqfoRbHOKerBjei)pIweuX8O)(FJS993)JOfbvmp6)HbhxGt9NI5ZojjQyhHJJRIJKHJiHJxHJErf1Z8IbhGHjMeVbP8SOfbvm4is4ibiaqE9qnPXUWZCVyBIJRIah5I7JIINh7cT5tRPXUWXrKWrcqaGShgwQNn9AfhrchzDtn9AnZbT2wtgX26WsEyyPEgk2AuooUkoU3FkMpT(NXUqB(067)nYq7F)pIweuX8O)hgCCbo1FkMp7KKOIDeooUkoUcoIeosacaKxputASl8m3l2M44QiWrU4(OO45XUqB(0AASlCCejCKaeai7HHL6ztVw)tX8P1)m2fAZNwF)Vr2E)9)iArqfZJ(FyWXf4u)H3G0eNubn4icCCpCmuiCKaeaiRItsGPLg6fndU8NI5tR)HuPMudKqbsnL((FJSaWF)pIweuX8O)hgCCbo1F4ninXjvqdoUkcCCF4is4iRBQPxRzoO12AYi2whwYddl1ZqXwJYXXvXXvUghrch3ghzDtn9AnZbT2wt7gQamIAYqXwJYXXvXX9WXqHWXRWrVOI6zoO12AA3qfGrutw0IGkgCClCejCK1n10R1mRO0KbkLH7fDtbYZqXwJYXXvXXv(tX8P1)qQutQbsOaPMsF)VrgA4F)pIweuX8O)hgCCbo1F2ghz9orl1ZQWGnTHgCmuiCK17eTupRdksEcOeCClCejC8kC0lQOEwfNKatln0lAw0IGkM)WD4W8)gz)Py(06FyfLMkMpTMOd3)dD4EslR8hwVt0s93)BKHg93)JOfbvmp6)HbhxGt9hcqaGSrSToSeRHsgkfZXrKWrEdstCsf0GJbchr7FkMpT(hJyBLOP(7)nY24)(FeTiOI5r)pm44cCQ)W6MA61AMdATTMmIT1HL8WWs9muS1OCCezCK1n10R1mh0ABnzeBRdl5HHL6zdiS8PvCCvCeyqrYtqXwJYXXqHWrGbfjpbfBnkhhdeoY6MA61AMdATTMmIT1HL8WWs9muS1OCCezCKS9(tX8P1)Gco2EGscqOOalO59)2kx)3)tX8P1)aYL04IL)hrlcQyE0F)VTcz)9)iArqfZJ(FyWXf4u)HaeaiVEOM0yx4zUxSnXXvXrYWrKWrcqaGSrSToSeRHsM7fBtCmq44((tX8P1)S0RfyIplKA99)2kR83)tX8P1)WBqAI7Wzt5pIweuX8O)(FBL993)JOfbvmp6)Py(06FyfLMkMpTMOd3)dD4EslR8hwVt0s93)BRG2)(FkMpT(hoPY0Rten1)JOfbvmp6V)(FwGcRTeL)3)BK93)JOfbvmp6)HbhxGt9hFScoUkoEnoIeoEfoUiEUOZo5pfZNw)dGqtM2oA5tRV)3w5V)NI5tR)HdATTMaekkWcA(JOfbvmp6V)323F)pIweuX8O)hgCCbo1FiabaYRhQjn2fEM7fBtCCvCKmCejCKaeaiBeBRdlXAOK5EX2ehdecCCL)umFA9pl9AbM4ZcPwF)VH2)(FeTiOI5r)pm44cCQ)Snos0CoogkeowmFAnBeBRen1ZSI74icC8ACClCejCK3G0eNubnCCmq4iA)tX8P1)yeBRen1F)9)WbT2wtEyyP(F)Vr2F)pIweuX8O)hgCCbo1F4ninXjvqdoIah37pfZNw)dPsnPgiHcKAk99)2k)9)iArqfZJ(FyWXf4u)HaeaiBeBRdlXAOKbxWrKWXTXrVOI6zJyBDyjwRCq7IpTMfTiOIbhdfchjabaYQ4KeyAPHErZMETIJB9NI5tR)Xi2wjAQ)h6OsIz(Zkx)(FBF)9)iArqfZJ(FyWXf4u)HaeaiVEOM0yx4zUxSnXrKXXrzTDuuPXUWXXaHJOfhrch3gh9IkQNnIT1HLyTYbTl(0Aw0IGkgCmuiCKaeaiRItsGPLg6fnB61koU1FkMpT(hoPY0Rten1)dDujXm)zLRF)VH2)(FkMpT(huWX2dusacffybn)r0IGkMh93)B793)tX8P1)WbT2wt7gQamIA(JOfbvmp6V)3ca)9)umFA9pSIstgOugUx0nfi)pIweuX8O)(Fdn8V)NI5tR)HuPMudKqbsnL(hrlcQyE0F)VHg93)JOfbvmp6)HbhxGt9hcqaGSrSToSeRHsgCbhrchjabaYQ4KeyAPHErZGl4is4424424ibiaqE3qfGrutgk2AuooUkoUhogkeoEfo6fvupZbT2wt7gQamIAYIweuXGJBHJiHJBJJeGaazuWX2dusacffybnzOyRr544Q44E4yOq4ibiaqgfCS9aLeGqrbwqt20RvCClCCR)umFA9pgX2krt93)BB8F)pIweuX8O)hgCCbo1FiabaYQ4KeyAPHErZGl4is4424424ibiaqE3qfGrutgk2AuooUkoUhogkeoEfo6fvupZbT2wt7gQamIAYIweuXGJBHJiHJBJJeGaazuWX2dusacffybnzOyRr544Q44E4yOq4ibiaqgfCS9aLeGqrbwqt20RvCClCCR)umFA9pCsLPxNiAQ)(FJSR)7)r0IGkMh9)WGJlWP(Zv4Oxur9SrSToSeRvoODXNwZIweuXGJHcHJeGaa51d1Kg7cpZ9ITjoImoo2fEIVuRvXKmGWrrL5GwBRjJyBDyjpmSuhhxfh33FkMpT(hoO12AYi2whwYddl1F)Vrgz)9)umFA9pCsLPxNiAQ)hrlcQyE0F)9)0aajumZF)Vr2F)pIweuX8O)hgCCbo1FwepBeBRdl5HHL65I5Zo5pfZNw)dHa5cCZrr9(FBL)(FeTiOI5r)pm44cCQ)qacaKjeixGBokQm4cogkeoUiE2i2whwYddl1ZfZNDcoIeoEfoclMKDytP)Py(06FwAFA99)2((7)r0IGkMh9)WGJlWP(ZI4zJyBDyjpmSupxmF2j)Py(06FiODBsaGWWV)3q7F)pIweuX8O)hgCCbo1FwepBeBRdl5HHL65I5Zo5pfZNw)dWafcA3M3F)pEyyPEAbkl)9)gz)9)iArqfZJ(FkMpT(ht32)qhvsmZF231V)3w5V)hrlcQyE0)ddoUaN6pxHJErf1ZgX26WsSw5G2fFAnlArqfZFkMpT(hJyBDyjUdffLt69)2((7)Py(06FuXjjW0sd9I(hrlcQyE0F)VH2)(FeTiOI5r)pm44cCQ)WBqAItQGgCeboU3FkMpT(huWX2dusacffybnV)327V)hrlcQyE0)ddoUaN6p8gKM4KkObhrGJOfhrch3ghVch9IkQNrbhBpqjbiuuGf0KfTiOIbhdfchzDtn9AnJco2EGscqOOalOjdfBnkhh36pfZNw)dh0ABnTBOcWiQ59)wa4V)hrlcQyE0)ddoUaN6pxHJErf1ZOGJThOKaekkWcAYIweuXGJHcHJSUPMETMrbhBpqjbiuuGf0KHITgL)NI5tR)HvuAYaLYW9IUPa5V)3qd)7)r0IGkMh9)WGJlWP(dbiaq2i2whwI1qjdUGJiHJ8gKM4KkObhdeoIwCejCCBC0lQOE2i2whwI1kh0U4tRzrlcQyWXqHWrcqaGSkojbMwAOx0SPxR44w)Py(06FmITvIM6V)3qJ(7)r0IGkMh9)WGJlWP(dVbPjoPcAWXaHJ7HJ7hhrloUHHJeGaazvCscmT0qVOzWL)umFA9pCsLPxNiAQ)(FBJ)7)Py(06FivQj1ajuGutP)r0IGkMh93F)9)uGoPg(NZydiV)()]] )


end
