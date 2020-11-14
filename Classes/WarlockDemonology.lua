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
        hog_shards = hog_shards or 0

        -- The last part of a Tyrant Prep phase should be a HoG cast.
        if not tyrant_ready and cooldown.summon_demonic_tyrant.remains < 5 then
            if talent.doom.enabled and not debuff.doom.up then return end
            if talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.remains < 5 then return end
            if talent.nether_portal.enabled and cooldown.nether_portal.remains < 5 then return end
            if talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < 5 then return end
            if talent.summon_vilefiend.enabled and cooldown.summon_filefiend.remains < 5 then return end
            if cooldown.call_dreadstalkers.remains < 5 then return end
            if buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) then return end
            if soul_shard + hog_shards < ( buff.nether_portal.up and 1 or 5 ) then return end

            if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as true as all conditions were met." ) end
            tyrant_ready = true
        elseif tyrant_ready and cooldown.summon_demonic_tyrant.remains >= 5 then
            if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false based on cooldown." ) end
            tyrant_ready = false
        end
    end )


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
                        -- If this imp is impacting within 0.1s of the expected queued imp, remove that imp from the queue.
                        if abs( now - guldan[ 1 ] ) < 0.1 then
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
                    if shards_for_guldan >= 1 then table.insert( guldan, now + 0.11 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, now + 0.12 ) end
                    if shards_for_guldan >= 3 then table.insert( guldan, now + 0.13 ) end

                    -- Per SimC APL, we go into Tyrant with 5 shards -OR- with Nether Portal up.
                    local start, duration = GetSpellCooldown( 265817 )

                    if not tyrant_ready_actual and start and duration and start + duration - now < 5 then
                        state.reset()

                        local np = state.talent.nether_portal.enabled and FindUnitBuffByID( "player", 267218 )

                        if ( not state.talent.doom.enabled or state.action.doom.lastCast - now < 30 ) and 
                           ( state.cooldown.demonic_strength.remains > 0 or not state.talent.demonic_strength.enabled or state.talent.demonic_consumption.enabled ) and 
                           ( state.cooldown.nether_portal.remains > 0 or not state.talent.nether_portal.enabled ) and
                           ( state.cooldown.grimoire_felguard.remains > 0 or not state.talent.grimoire_felguard.enabled ) and 
                           ( state.cooldown.summon_vilefiend.remains > 0 or not state.talent.summon_vilefiend.enabled ) and
                           ( state.cooldown.call_dreadstalkers.remains > 0 ) and
                           ( state.buff.demonic_core.down or shards_for_guldan > 3 or ( not state.talent.demonic_consumption.enabled or np ) ) and
                           ( shards_for_guldan == 5 or np ) then

                            tyrant_ready_actual = true
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
            duration = function () return 5 * haste end,
            tick_time = function () return haste end,
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
            cast = function () return legendary.pillars_of_the_dark_portal.eanbled and 0 or 2 end,
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
            cast = function () return 5 * haste end,
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
            flightTime = 0.7,

            -- usable = function () return soul_shards.current >= 3 end,
            handler = function ()
                extra_shards = min( 2, soul_shards.current )
                if Hekili.ActiveDebug then Hekili:Debug( "Extra Shards: %d", extra_shards ) end
                spend( extra_shards, "soul_shards" )
                update_tyrant_readiness( 1 + extra_shards )
            end,

            impact = function ()
                insert( guldan_v, query_time + 0.05 )
                if extra_shards > 0 then insert( guldan_v, query_time + 0.06 ) end
                if extra_shards > 1 then insert( guldan_v, query_time + 0.07 ) end
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

            spend = 1,
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

    spec:RegisterPack( "Demonology", 20201114, [[dm0LSaqisv5rKQQnHKAuajNsvrRciL0RuLAwivUfqQ2Ls(LQWWifDmKKLrk8mKQAAiHUMukBtvH8nvfOXbKIZHufTovfK5HeCpvv7JuLdcKs1cbIhQQamrKQWfvvq1jbsjwjPYmvvaTtvj)uvbLHIuL6Ps1uvf9vGuk7vL)kyWk1HfTyi9yOMmjxg1Mb8zKYObQtR41sPA2eUTq7MQFlz4sXYb9CetNY1Hy7irFxvPXRQqDEPK1JuLmFsP9t0hv3ZRRsJVxAOPgAsfvurXfv0NknOIEEDRvdF9Me3EsJVUNr(60dowEjkATUEt2suP6EEDsHaX81bBwd5d94bTXaJGUWv8bzIiI0MYXWeWEqMi(X1rrgHbAXp0RRsJVxAOPgAsfvurXfv0NknOc0CDsdJVxA8rF01bpkf7h61vmbFD9l30dowEjkATKBqBjuu42L60VCd2SgYh6XdAJbgbDHR4dYerePnLJHjG9Gmr8dPo9l3Vkk5ikdLBQOiDYTgAQHMsDsD6xU)aaNonM8HK60VCd6YDVHfc5(dSWTVK60VCd6Y9hMlAj3qgxXi7k5MEWXYrlHj3nqg0Xvenn5EaK7XK7Hi3JtS0n5gufuUbNqfojMCduq5gTieM85sQt)YnOl3076ldL7(0aUC5ofI6lRK7gid64kIMMCBLC3alSCpoXs3KB6bhlhTe2sQt)YnOl30BkP3YTLc2n5ECJHqKgBD9gybmc(66xUPhCS8su0Aj3G2sOOWTl1PF5gSznKp0Jh0gdmc6cxXhKjIisBkhdta7bzI4hsD6xUFvuYrugk3urr6KBn0udnL6K60VC)baoDAm5dj1PF5g0L7EdleY9hyHBFj1PF5g0L7pmx0sUHmUIr2vYn9GJLJwctUBGmOJRiAAY9ai3Jj3drUhNyPBYnOkOCdoHkCsm5gOGYnArim5ZLuN(LBqxUP31xgk39PbC5YDke1xwj3nqg0Xvenn52k5Ubwy5ECILUj30dowoAjSLuN(LBqxUP3usVLBlfSBY94gdHin2sQtQt)Y9h(hZyeJvYnkduqwUXvenn5gLPnozj3G2XyUXiYTxoOdoHraeHCNyBkNi3LlATK6sSnLtwnqgxr00E))aGfbvfhpTPC6gGFBISEAsT(AyBLIHswQlX2uoz1azCfrt79)dcsmwEOHnPUeBt5KvdKXvenT3)pAQVmmqMgWLt3a8JIaaS(ocvyInKfXsC76rf1OiaalfhlFWbCb5fXsC7u4xdPUeBt5KvdKXvenT3)puCSC0sy0na)OfHOvBITP8LIJLJwcBHtI9RPuxITPCYQbY4kIM27)heWPQ(gqlHj1PF5oX2uoz1azCfrt79)dkt4KOcMopJ8V1cMUfGCQArhLPaH)Xvju1xFrqIXYdkow(Gdwly62cYXCCcfAJAqPplfSBlvvXf7jQGvA1QyueaGLQQ4cP5tQbfkcaWsXXYhCGyq2PzGxinA1QplfSBlfhlFWbIbzNMbEXEIkyLwTwky3wkow(Gd4YjiXgBkFXEIky1Nudk9zPGDB5SbMHHMcAPyXEIkyLwTOiaalNnWmm0uqlflKgTAXvju1xF5SbMHHMcAPyb5yoorpQA7tQbL(SuWUTObNynqoaWcAijuTyprfSsRwCvcv91x0GtSgihaybnKeQwqoMJt0JQ2(KAqPplfSBlcsmwEGYrWad7Qf7jQGvA1IRsOQV(IGeJLhOCemWWUAb5yoorpQA7tQbL(SuWUTuCS8bhWLtqIn2u(I9evWkTArraawFhHkmXgYcPrRwsHiceWju93MwTOiaalNnWmm0uqlflKgQjfIiqaNqLEA(PuNuN(L7p8pMXigRKBMsg2sUTjYYTbML7eBfuUhICNuMJirf8sQlX2uo5N0Wcrqu42L6sSnLtE))aNcraGfGrCJHsDj2MYjV)FKFmhSIqK6sSnLtE))qXuwiWqmPnyPUeBt5K3)pWPqesSnLhedXOZZi)xaabAyLuxITPCY7)h4uicj2MYdIHy05zK)zcHDmtK6sSnLtE))aI4HeBt5bXqm68mY)wly6wObYn0rm4GTFQOBa(Xvju1xFrqIXYdkow(Gdwly62cYXCCcfAJA9zTGPBbiNQwsDj2MYjV)Far8qITP8GyigDEg5FcsmwEWAbt3OJyWbB)ur3a8BTGPBbiNQwsDj2MYjV)FqWfcCCAbBmWSuxITPCY7)htSHD140c40sIbRgWSuxITPCY7)hKcreGLr3a8NyBOKdSZXHj6rLuxITPCY7)hkgpX0gNwaTegDdWpOSesJTfyofg4qd2OqBAQvlWqdSfGCmhNOxBA(PuxITPCY7)heKyS8aLJGbg2v0na)4QeQ6RViiXy5bfhlFWbRfmDBb5yoorpkQPwTadnWwaYXCCcfWvju1xFrqIXYdkow(Gdwly62cYXCCYBnAtQlX2uo59)dCkebfKtfXsr7mKi1LyBkN8()HQQiDdWpKbGmbCIkyPUeBt5K3)puCS8bhigKDAgyPUeBt5K3)pqhbtWfcKghqRikdjsDj2MYjV)FaoDvOac0qeQ0PBa(jfIiqaNq1FBA1IIaaSC2aZWqtbTuSqAK6sSnLtE))aC6QqbeOHiuPt3a8tkerGaoHk9(Pp14QeQ6RViiXy5bfhlFWbRfmDBb5yoorpn0KAqHRsOQV(IGeJLhOCemWWUAb5yoorV20QvFwky3weKyS8aLJGbg2vl2tubR(KACvcv91x4uickiNkILI2zizb5yoorpnK6sSnLtE))qXXYrlHr3a8JIaaSuCS8bhWfKxqoXg1KcreiGtOIcuuQlX2uo59)dAWjwdKdaSGgscv0na)4QeQ6RViiXy5bfhlFWbRfmDBb5yoo5nUkHQ(6lcsmwEqXXYhCWAbt3wkeyAt56bm0aBbihZXjA1cm0aBbihZXjuaxLqvF9fbjglpO4y5doyTGPBlihZXjVPQnPUeBt5K3)pqiCymosK6sSnLtE))OP(YWazAaxoDdWpkcaW67iuHj2qwelXTRhvuJIaaSuCS8bhWfKxelXTtb6l1LyBkN8()XeBefzkNUb4hucMswqH20K6eBdLCGDoomrpn0QnPxmCmEXFCJOidLCOPm2Tjfly6TRhvuJIaaS4pUruKHso0ug72KIfKJ54ekq)pPgfbay9DeQWeBilIL4217N(sDj2MYjV)FqkerGyWPDwQlX2uo59)dc4uvFdOLWK6K6sSnLtwmHWoMj)FlOqrjpEaYKYthZ0na)4QeQ6RViiXy5bfhlFWbRfmDBb5yoorpk2MuxITPCYIje2Xm59)JihlyRqbeei4rfuqoJePUeBt5KftiSJzY7)hOIQuHciyG5a7CSLuxITPCYIje2Xm59)dAijunPhkGqsVyyzGL6sSnLtwmHWoMjV)FaNMgbhgpqAsml1LyBkNSycHDmtE))aOWiewfs6fdhJdOCgL6sSnLtwmHWoMjV)F0GahGwJtlGksIj1LyBkNSycHDmtE))aYzZ40caImYe6gGFlH0yBbMtHbo0Gn9anAQvRLqASTaZPWahAWgf0qtTAbgAGTaKJ54ekqFn1Q1sin2w2e5GvHgSf0qt9OOMsDj2MYjlMqyhZK3)pWLJz3GPXQaGiJSuxITPCYIje2Xm59)ddmhqC0cXvbGcIz6gGFueaGfKXTlycjauqmVGCmhNi1j1LyBkNSkaGanS6hLHeg2(40OBa(ByBP4y5doyTGPBReBdLSuxITPCYQaac0WQ3)pAkBkNUb4hfbayHYqcdBFCAlKgTAByBP4y5doyTGPBReBdLm16dMyEzWsiK6sSnLtwfaqGgw9()bQOkvaab2IUb4VHTLIJLp4G1cMUTsSnuYsDj2MYjRcaiqdRE))ayGmQOkfDdWFdBlfhlFWbRfmDBLyBOKL6K6sSnLtweKyS8G1cMU9doDvOac0qeQ0PBa(jfIiqaNq1FBsDj2MYjlcsmwEWAbt3E))qXXYrlHr3a8JIaaSuCS8bhWfKxinudklfSBlfhlFWbC5eKyJnLVyprfSsRwueaGLZgyggAkOLILQ(6FsNyCoGv)AOPuxITPCYIGeJLhSwW0T3)piGtv9nGwcJUb4hfbay9DeQWeBilIL42FpoUIJtlmXgcfOi1GYsb72sXXYhCaxobj2yt5l2tubR0Qffbay5SbMHHMcAPyPQV(N0jgNdy1VgAk1LyBkNSiiXy5bRfmD79)dCkebfKtfXsr7mKi1LyBkNSiiXy5bRfmD79)dWPRcfqGgIqLUuxITPCYIGeJLhSwW0T3)puCSC0sy0na)OiaalfhlFWbCb5fsd1OiaalNnWmm0uqlflKgQbfOqraawuocgyyxTGCmhNOxBA1QplfSBlcsmwEGYrWad7Qf7jQGvFsnOqraaw0GtSgihaybnKeQwqoMJt0RnTArraaw0GtSgihaybnKeQwQ6R)5NsDj2MYjlcsmwEWAbt3E))Gaov13aAjm6gGFueaGLZgyggAkOLIfsd1GcuOiaalkhbdmSRwqoMJt0RnTA1NLc2Tfbjglpq5iyGHD1I9evWQpPguOiaalAWjwdKdaSGgscvlihZXj61MwTOiaalAWjwdKdaSGgscvlv91)8tPo9l3j2MYjlcsmwEWAbt3E))GYeojQGPZZi)BTGPBbiNQw0rzkq4F9HRsOQV(IGeJLhuCS8bhSwW0TfKtvlPUeBt5KfbjglpyTGPBV)FqqIXYdkow(Gdwly6gDdWpPqebc4eQi)Ak1LyBkNSiiXy5bRfmD79)dc4uvFdOLWK6K6sSnLtwwly6wObYn)QQI0jgNdy1p91uQlX2uozzTGPBHgi38()HIJLp4aXGStZat3a8RplfSBlfhlFWbC5eKyJnLVyprfSsQlX2uozzTGPBHgi38()HZgyggAkOLcPUeBt5KL1cMUfAGCZ7)h0GtSgihaybnKeQK6sSnLtwwly6wObYnV)FqqIXYduocgyyxj1LyBkNSSwW0TqdKBE))aNcrqb5urSu0odjsDj2MYjlRfmDl0a5M3)puCSC0sy0na)OiaalfhlFWbCb5fsd1KcreiGtOIcuKAqzPGDBP4y5doGlNGeBSP8f7jQGvA1IIaaSC2aZWqtbTuSu1x)tPUeBt5KL1cMUfAGCZ7)heWPQ(gqlHr3a8tkerGaoHkk0gOtrqROiaalNnWmm0uqlflKgPo9l3j2MYjlRfmDl0a5M3)pOmHtIky68mY)wly6waYPQfDuMce(NkPUeBt5KL1cMUfAGCZ7)hGtxfkGaneHk9Rtjdjt53ln0udnPIkn146FtOponY1bTeBkOXk5(JK7eBt5YTyigzj1D9eXaxWR3N4hW1fdXi3ZRZec7yMCpVxuDpVo7jQGvhixhdhJHtEDCvcv91xeKyS8GIJLp4G1cMUTGCmhNi36j3uSTRNyBk)6FlOqrjpEaYKYthZNDV04EE9eBt5xpYXc2kuabbcEubfKZi56SNOcwDGC29I(3ZRNyBk)6OIQuHciyG5a7CS11zprfS6a5S7ffVNxpX2u(1PHKq1KEOacj9IHLb(6SNOcwDGC29QT751tSnLFD400i4W4bstI5RZEIky1bYz3Rp6EE9eBt5xhOWiewfs6fdhJdOCgVo7jQGvhiNDV(G3ZRNyBk)6niWbO140cOIKyxN9evWQdKZUxGM751zprfS6a56y4ymCYRBjKgBlWCkmWHgSj36j3GgnLBTALBlH0yBbMtHbo0Gn5McYTgAk3A1k3adnWwaYXCCICtb5M(Ak3A1k3wcPX2YMihSk0GTGgAk36j3uuZRNyBk)6qoBgNwaqKrMC29IEEpVEITP8RJlhZUbtJvbarg5RZEIky1bYz3lQ08EED2tubRoqUogogdN86OiaaliJBxWesaOGyEb5yoo56j2MYVUbMdioAH4QaqbX8zNDDfdKic7EEVO6EE9eBt5xN0Wcrqu42Vo7jQGvhiNDV04EE9eBt5xhNcraGfGrCJHxN9evWQdKZUx0)EE9eBt5xp)yoyfHCD2tubRoqo7ErX751tSnLFDftzHadXK2GVo7jQGvhiNDVA7EED2tubRoqUEITP8RJtHiKyBkpigIDDXqSGNr(6faqGgwD296JUNxN9evWQdKRNyBk)64uicj2MYdIHyxxmel4zKVotiSJzYz3Rp4986SNOcwDGCDmCmgo51Xvju1xFrqIXYdkow(Gdwly62cYXCCICtb5Un5MA5wFYT1cMUfGCQADDIbhSDVO66j2MYVoeXdj2MYdIHyxxmel4zKVU1cMUfAGCZz3lqZ986SNOcwDGCDmCmgo51TwW0TaKtvRRtm4GT7fvxpX2u(1HiEiX2uEqme76IHybpJ81jiXy5bRfmD7S7f98EE9eBt5xNGle440c2yG5RZEIky1bYz3lQ08EE9eBt5xFInSRgNwaNwsmy1aMVo7jQGvhiNDVOIQ751zprfS6a56y4ymCYRNyBOKdSZXHjYTEYnvxpX2u(1jfIial7S7fvACpVo7jQGvhixhdhJHtEDqj3wcPX2cmNcdCObBYnfK720uU1QvUbgAGTaKJ54e5wp5UnnL7pVEITP8RRy8etBCAb0syNDVOI(3ZRZEIky1bY1XWXy4KxhxLqvF9fbjglpO4y5doyTGPBlihZXjYTEYnf1uU1QvUbgAGTaKJ54e5McYnUkHQ(6lcsmwEqXXYhCWAbt3wqoMJtK73YTgTD9eBt5xNGeJLhOCemWWU6S7fvu8EE9eBt5xhNcrqb5urSu0odjxN9evWQdKZUxu12986SNOcwDGCDmCmgo51HmaKjGtubF9eBt5xxvv8S7fvF0986j2MYVUIJLp4aXGStZaFD2tubRoqo7Er1h8EE9eBt5xhDembxiqACaTIOmKCD2tubRoqo7ErfO5EED2tubRoqUogogdN86KcreiGtOsU)L72KBTALBueaGLZgyggAkOLIfsZ1tSnLFDWPRcfqGgIqL(z3lQON3ZRZEIky1bY1XWXy4KxNuiIabCcvYTE)Yn9LBQLBCvcv91xeKyS8GIJLp4G1cMUTGCmhNi36j3AOPCtTCdk5gxLqvF9fbjglpq5iyGHD1cYXCCICRNC3MCRvRCRp52sb72IGeJLhOCemWWUAXEIkyLC)PCtTCJRsOQV(cNcrqb5urSu0odjlihZXjYTEYTgxpX2u(1bNUkuabAicv6NDV0qZ751zprfS6a56y4ymCYRJIaaSuCS8bhWfKxqoXMCtTCtkerGaoHk5McYnfVEITP8RR4y5OLWo7EPbv3ZRZEIky1bY1XWXy4KxhxLqvF9fbjglpO4y5doyTGPBlihZXjY9B5gxLqvF9fbjglpO4y5doyTGPBlfcmTPC5wp5gyOb2cqoMJtKBTALBGHgyla5yoorUPGCJRsOQV(IGeJLhuCS8bhSwW0TfKJ54e5(TCtvBxpX2u(1PbNynqoaWcAijuD29sdnUNxpX2u(1riCymosUo7jQGvhiNDV0G(3ZRZEIky1bY1XWXy4Kxhfbay9DeQWeBilIL42LB9KBQKBQLBueaGLIJLp4aUG8IyjUD5McYn9VEITP8R3uFzyGmnGl)S7Lgu8EED2tubRoqUogogdN86GsUfmLSqUPGC3MMYn1YDITHsoWohhMi36j3Ai3A1k3j9IHJXl(JBefzOKdnLXUnPybtVD5wp5Mk5MA5gfbayXFCJOidLCOPm2TjflihZXjYnfKB6l3Fk3ul3OiaaRVJqfMydzrSe3UCR3VCt)RNyBk)6tSruKP8ZUxA02986j2MYVoPqebIbN25RZEIky1bYz3ln(O751tSnLFDc4uvFdOLWUo7jQGvhiND21BGmUIOPDpVxuDpVo7jQGvhixhdhJHtEDBISCRNCRPCtTCRp5UHTvkgk5RNyBk)6aSiOQ44PnLF29sJ751tSnLFDcsmwEaGf0qsO66SNOcwDGC29I(3ZRZEIky1bY1XWXy4Kxhfbay9DeQWeBilIL42LB9KBQKBQLBueaGLIJLp4aUG8IyjUD5Mc)YTgxpX2u(1BQVmmqMgWLF29II3ZRZEIky1bY1XWXy4KxhTie5wRw5oX2u(sXXYrlHTWjXK7F5wZRNyBk)6kowoAjSZUxTDpVEITP8RtaNQ6BaTe21zprfS6a5SZUobjglpyTGPB3Z7fv3ZRZEIky1bY1XWXy4KxNuiIabCcvY9VC321tSnLFDWPRcfqGgIqL(z3lnUNxN9evWQdKRJHJXWjVokcaWsXXYhCaxqEH0i3ul3GsUTuWUTuCS8bhWLtqIn2u(I9evWk5wRw5gfbay5SbMHHMcAPyPQVUC)51tSnLFDfhlhTe21fJZbS66AO5z3l6FpVo7jQGvhixhdhJHtEDueaG13rOctSHSiwIBxUFl3JJR440ctSHi3uqUPOCtTCdk52sb72sXXYhCaxobj2yt5l2tubRKBTALBueaGLZgyggAkOLILQ(6Y9NxpX2u(1jGtv9nGwc76IX5awDDn08S7ffVNxpX2u(1XPqeuqovelfTZqY1zprfS6a5S7vB3ZRNyBk)6GtxfkGaneHk9RZEIky1bYz3Rp6EED2tubRoqUogogdN86OiaalfhlFWbCb5fsJCtTCJIaaSC2aZWqtbTuSqAKBQLBqj3GsUrraawuocgyyxTGCmhNi36j3Tj3A1k36tUTuWUTiiXy5bkhbdmSRwSNOcwj3Fk3ul3GsUrraaw0GtSgihaybnKeQwqoMJtKB9K72KBTALBueaGfn4eRbYbawqdjHQLQ(6Y9NY9NxpX2u(1vCSC0syNDV(G3ZRZEIky1bY1XWXy4Kxhfbay5SbMHHMcAPyH0i3ul3GsUbLCJIaaSOCemWWUAb5yoorU1tUBtU1QvU1NCBPGDBrqIXYduocgyyxTyprfSsU)uUPwUbLCJIaaSObNynqoaWcAijuTGCmhNi36j3Tj3A1k3OiaalAWjwdKdaSGgscvlv91L7pL7pVEITP8RtaNQ6BaTe2z3lqZ986SNOcwDGCDmCmgo51jfIiqaNqfrU)LBnVEITP8RtqIXYdkow(Gdwly62z3l65986j2MYVobCQQVb0syxN9evWQdKZo76faqGgwDpVxuDpVo7jQGvhixhdhJHtE9g2wkow(Gdwly62kX2qjF9eBt5xhLHeg2(40o7EPX986SNOcwDGCDmCmgo51rraawOmKWW2hN2cPrU1QvUByBP4y5doyTGPBReBdLSCtTCRp5gMyEzWsiUEITP8R3u2u(z3l6FpVo7jQGvhixhdhJHtE9g2wkow(Gdwly62kX2qjF9eBt5xhvuLkaGaBD29II3ZRZEIky1bY1XWXy4KxVHTLIJLp4G1cMUTsSnuYxpX2u(1bgiJkQsD2zx3Abt3cnqU5EEVO6EED2tubRoqUEITP8RRQkEDX4CaRUo918S7Lg3ZRZEIky1bY1XWXy4KxxFYTLc2TLIJLp4aUCcsSXMYxSNOcwD9eBt5xxXXYhCGyq2PzGp7Er)751tSnLFDNnWmm0uqlfxN9evWQdKZUxu8EE9eBt5xNgCI1a5aalOHKq11zprfS6a5S7vB3ZRNyBk)6eKyS8aLJGbg2vxN9evWQdKZUxF0986j2MYVoofIGcYPIyPODgsUo7jQGvhiNDV(G3ZRZEIky1bY1XWXy4KxhfbayP4y5doGliVqAKBQLBsHiceWjuj3uqUPOCtTCdk52sb72sXXYhCaxobj2yt5l2tubRKBTALBueaGLZgyggAkOLILQ(6Y9NxpX2u(1vCSC0syNDVan3ZRZEIky1bY1XWXy4KxNuiIabCcvYnfK72KBqxUPOCdAvUrraawoBGzyOPGwkwinxpX2u(1jGtv9nGwc7S7f98EE9eBt5xhC6QqbeOHiuPFD2tubRoqo7SZo7S7a]] )


end
