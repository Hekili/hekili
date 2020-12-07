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

        hog_shards = hog_shards or 0

        -- The last part of a Tyrant Prep phase should be a HoG cast.
        if cooldown.summon_demonic_tyrant.remains < 4 then
            if talent.doom.enabled and not debuff.doom.up then return end
            if talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.remains < 4 then return end
            if talent.nether_portal.enabled and cooldown.nether_portal.remains < 4 then return end
            if talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < 4 then return end
            if talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.remains < 4 then return end
            if cooldown.call_dreadstalkers.remains < 4 then return end
            if buff.demonic_core.up and soul_shard < 4 and ( talent.demonic_consumption.enabled or buff.nether_portal.down ) then return end
            if soul_shard + hog_shards < ( buff.nether_portal.up and 1 or 5 ) then return end

            if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as true as all conditions were met." ) end
            tyrant_ready = true
        else
            if Hekili.ActiveDebug then Hekili:Debug( "Flagging 'tyrant_ready' as false based on cooldown." ) end
            tyrant_ready = false
        end
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


    spec:RegisterSetting( "implosion_imps", 3, {
        name = "Wild Imps for |T2065588:0|t Implosion",
        desc = "When using |T2065588:0|t Implosion, the default priority will require you to have at least this many Wild Imps.\n\n" ..
            "Current sims reflect that a minimum of 3 imps are needed for optimal DPS in Hectic Add Cleave, while using " ..
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

    spec:RegisterPack( "Demonology", 20201207, [[dC0NVaqiLQ6rciBcO8jifgLsQoLsPwLsvkEfq1SquDlvQYUKYVujgMkvogIYYeuEgKsMMa4AkPSnif5BQuvnovQkoNsvQwNsvyEcOUhq2NGQdkavwiKQhkaLjQuLCrbOQpQufvNuasRuGMPsvKDQs6NkvrzOcqSuvQk9uvmvvkFfsPASqkL9QQ)kvdwOdlAXi8yuMmfxMyZa(mKmAe50kETsjZgPBtPDt63sgUsCCLQuA5GEoQMovxhITRu57kfJhsrDELK5li7hQFY(B)XKU8xd7UWUJSWU7(BKDxyRf2A)XxTi)zjzBLOK)OPv(ZEj2slAHA1FwYv0kn)T)Wleit(dj3x47XLlOgNecrJv2l8XIqtFkLbta)cFSSl)HazOEavFI)ysx(RHDxy3rwy3D)nYUlS1clS)Wxe2Fnm0eA6pKgJr0N4pgHZ(tGWX9sSLw0c1kCeTNqAX2chmq4ij3x47XLlOgNecrJv2l8XIqtFkLbta)cFSSl4Gbch3lHjwcbIJ3p54yy3f2D4G4GbchdyKsfLW3dCWaHJ3dhplcLIJ7PITvdhmq449WX9mLUchHcRSwrn44Ej2sjkQJJlq5ESYsKoooa44444WXXr5EQooUEbXrsj0WsUJJafehjkox4B3WbdeoEpCmGuBeioEMfsLIJjLwBedoUaL7Xklr64Ox44cSy44OCpvhh3lXwkrr9goyGWX7HJ3xz3WfCmGAxOfFkfhjsUyWXsXr0ETHKKgCefYyKgoyGWX7HJbKDbeC0tQOoooQlqiYI3(ZcSagQ8NaHJ7LylTOfQv4iApH0ITfoyGWrsUVW3JlxqnojeIgRSx4JfHM(ukdMa(f(yzxWbdeoUxctSecehVFYXXWUlS7WbXbdeogWiLkkHVh4GbchVhoEwekfh3tfBRgoyGWX7HJ7zkDfocfwzTIAWX9sSLsuuhhxGY9yLLiDCCaWXXXXHJJJY9uDCC9cIJKsOHLChhbkiosuCUW3UHdgiC8E4yaP2iqC8mlKkfhtkT2igCCbk3JvwI0XrVWXfyXWXr5EQooUxITuII6nCWaHJ3dhVVYUHl4ya1Uql(ukosKCXGJLIJO9Adjjn4ikKXinCWaHJ3dhdi7ci4ONurDCCuxGqKfVHdIdgiCmGhnlmexm4iHauqbhzLLiDCKqqnkVHJbCmMS4CCul9EKsOfaHIJjZNs54yP0vnCWK5tP82cuyLLiDWbDbqODtzhn9PuYhaq(yLWVdS9xeVL0zNGdMmFkL3wGcRSePdoOlCeRT0(I44GjZNs5TfOWklr6Gd6YsTrGD(SqQuYhaqeiaaTnd10h7cVX9KTv4KbgbcaqZi2shwNvqPX9KTvGbfgoyY8PuEBbkSYsKo4GUyeBPef1jFaaTorX5HcLmFkTzeBPef1BSK7GUBBW4fcTZjLqdpWbahmq4yY8PuEBbkSYsKo4GUSlHtsqfY10kG8vWu9ousZkY3LuebeRkQP2OnoI1wA3i2shw3xbt1BqXMJYd8AGT((Esf1BMQSnrtcQycfYieiaantv2gYY2GTobcaqZi2shwN7qrr5KAilHcTVNur9MrSLoSo3HIIYj1enjOIjuipPI6nJylDyDwPCe7IpL2enjOIzBWwFFpPI6nvCscSVuqpPnrtcQycfIabaOPItsG9Lc6jTHSekeRkQP2OnvCscSVuqpPnOyZr5Ht2ABd2677jvuVHco2AGshqOOqsOPjAsqftOqSQOMAJ2qbhBnqPdiuuij00GInhLhozRTnyRVVNur9ghXAlTVBOcWiQPjAsqftOqSQOMAJ24iwBP9DdvagrnnOyZr5Ht2ABd2677jvuVzeBPdRZkLJyx8P0MOjbvmHcrGaa02mutFSl8gYsOq8cH25KsOb0AHcrGaa0uXjjW(sb9K2qwaJxi0oNucnHF324G4Gbchd4rZcdXfdok7e4kC0hRGJojbhtMxqCC44yUlhAsqLgoyY8Puoi(IqPDAX2chmz(ukhCqxyjL2bekje1fioyY8Puo4GUKOzP7fNJdMmFkLdoOlgzxHa72e1WWbtMpLYbh0fwsP9K5tPD6WDY10kGkaGokMbhmz(ukhCqxGiApz(uANoCNCnTciFfmvVVaLfY5oCyoiYiFaaXQIAQnAJJyTL2nIT0H19vWu9guS5O8ahaW23xbt17qjnRWbtMpLYbh0fiI2tMpL2Pd3jxtRaIJyTL29vWuDY5oCyoiYiFaa5RGP6DOKMv4GjZNs5Gd6chXAlTVBOcWiQH8baeRkQP2OnoI1wA3i2shw3xbt1BqXMJYdpa3fkeWGIK3HInhLhywvutTrBCeRT0UrSLoSUVcMQ3GInhLdEyRHdMmFkLdoOlSKs7gOKgUN0Teihhmz(ukhCqxmvzjFaabfaOWjLeubhmz(ukhCqxmIT0H15ouuuojCWK5tPCWbDHyOcNviqusNOSecKJdMmFkLdoOlJDHw8PuYhaqjZNDsxuXocpCYaBFpPI6nEYGdWWetNxiuEt0KGkgWiqaaABgQPp2fEJ7jBRWbXf3hffVn2fAXNs7JDHdgbcaqZxbt1BMAJcgRkQP2OnoI1wA3i2shw3xbt1BqXMJYdFnCWK5tPCWbDzSl0IpLs(aakz(St6Ik2r4HhgyeiaaTnd10h7cVX9KTv4G4I7JII3g7cT4tP9XUWbJabaO5RGP6ntTrXbtMpLYbh0fsPA6fqhfc1Kk5daiEHq7Csj0aATqHiqaaAQ4KeyFPGEsBil4GjZNs5Gd6cPun9cOJcHAsL8baeVqODoPeAcheAbgRkQP2OnoI1wA3i2shw3xbt1BqXMJYdpS7aBDwvutTrBCeRT0(UHkaJOMguS5O8WxluO99KkQ34iwBP9DdvagrnnrtcQy2gmwvutTrBSKs7gOKgUN0TeiVbfBokp8WWbtMpLYbh0fwsP9K5tPD6WDY10kGy1ort1jN7WH5GiJ8ba06SANOP6nvyWIwqtOqSANOP6nDqrY7aPSny77jvuVPItsG9Lc6jTjAsqfdoyY8Puo4GUyeBPef1jFaarGaa0mIT0H1zfuAqjzoy8cH25KsOjWbahmz(ukhCqxqbhBnqPdiuuij0q(aaIvf1uB0ghXAlTBeBPdR7RGP6nOyZr5GZQIAQnAJJyTL2nIT0H19vWu9MbbM(uA4adksEhk2CuEOqadksEhk2CuEGzvrn1gTXrS2s7gXw6W6(kyQEdk2Cuo4KTgoyY8Puo4GUGWL(4ILJdMmFkLdoOll1gb25ZcPsjFaarGaa02mutFSl8g3t2wHtgyeiaanJylDyDwbLg3t2wbgTWbtMpLYbh0fEHq7ChoBj4GjZNs5Gd6clP0EY8P0oD4o5AAfqSANOP64GjZNs5Gd6cNuAQnDII64G4GjZNs5nwTt0uDqJDruZOO6S0tUdRfsc5daO99KkQ34jdoadtmDEHq5nrtcQycfkz(St6Ik2r4HtgoyY8PuEJv7envhCqx4ScbokQUpojH8baKNur9gpzWbyyIPZlekVjAsqfdyjZNDsxuXochez4GjZNs5nwTt0uDWbDHZke4OO6(4KeYhaq77jvuVXtgCagMy68cHYBIMeuXawY8zN0fvSJWdCaWbtMpLYBSANOP6Gd6cVqODy54GjZNs5nwTt0uDWbDXiSXM(OO6ef1XbXbtMpLYBfaqhfZaIqGCbU1OOiFaaTiEZi2shw3xbt1BjZNDcoyY8PuERaa6OygWbDzP8PuYhaqeiaancbYf4wJIQHSek0I4nJylDyDFfmvVLmF2jGTpmzsZHfLIdMmFkL3kaGokMbCqxiOvz6aiWvKpaGweVzeBPdR7RGP6TK5Zobhmz(ukVvaaDumd4GUamqHGwLH8ba0I4nJylDyDFfmvVLmF2j4G4GjZNs5noI1wA3xbt1brkvtVa6OqOMujFaaXleANtkHgqRHdMmFkL34iwBPDFfmvhCqxmITuII6KpaGiqaaAgXw6W6ScknKfWw3tQOEZi2shwNvkhXU4tPnrtcQycfIabaOPItsG9Lc6jTzQn62Kthv6mdOWUdhmz(ukVXrS2s7(kyQo4GUWjLMAtNOOo5daiceaG2MHA6JDH34EY2c8rzLDuu9XUWdCaaBDpPI6nJylDyDwPCe7IpL2enjOIjuiceaGMkojb2xkON0MP2OBtoDuPZmGc7oCWK5tP8ghXAlT7RGP6Gd6ck4yRbkDaHIcjHgCWK5tP8ghXAlT7RGP6Gd6chXAlTVBOcWiQbhmz(ukVXrS2s7(kyQo4GUWskTBGsA4Es3sGCCWK5tP8ghXAlT7RGP6Gd6cPun9cOJcHAsfhmz(ukVXrS2s7(kyQo4GUyeBPef1jFaarGaa0mIT0H1zfuAilGrGaa0uXjjW(sb9K2qwaB91jqaaA7gQamIAAqXMJYdFTqH23tQOEJJyTL23nubye10enjOIzBWwNabaOHco2AGshqOOqsOPbfBokp81cfIabaOHco2AGshqOOqsOPzQn62BJdMmFkL34iwBPDFfmvhCqx4KstTPtuuN8baebcaqtfNKa7lf0tAdzbS1xNabaOTBOcWiQPbfBokp81cfAFpPI6noI1wAF3qfGrutt0KGkMTbBDceaGgk4yRbkDaHIcjHMguS5O8WxluiceaGgk4yRbkDaHIcjHMMP2OBVnoyGWXK5tP8ghXAlT7RGP6Gd6YUeojbvixtRaYxbt17qjnRiFxsreq7ZQIAQnAJJyTL2nIT0H19vWu9gusZkCWK5tP8ghXAlT7RGP6Gd6chXAlTBeBPdR7RGP6KpaG23tQOEZi2shwNvkhXU4tPHcrGaa02mutFSl8g3t2wHVgoyY8PuEJJyTL29vWuDWbDHtkn1MorrDCqCWK5tP8MVcMQ3xGYcitvwYPJkDMbeADhoyY8PuEZxbt17lqzbCqxmIT0H15ouuuojYhaq77jvuVzeBPdRZkLJyx8P0MOjbvm4GjZNs5nFfmvVVaLfWbDrfNKa7lf0tkoyY8PuEZxbt17lqzbCqxqbhBnqPdiuuij0q(aaIxi0oNucnGwdhmz(ukV5RGP69fOSaoOlCeRT0(UHkaJOgYhaq8cH25KsObuaaB999KkQ3qbhBnqPdiuuij0ekeRkQP2OnuWXwdu6acffscnnOyZr5BJdMmFkL38vWu9(cuwah0fwsPDdusd3t6wcKt(aaAFpPI6nuWXwdu6acffscnHcXQIAQnAdfCS1aLoGqrHKqtdk2CuooyY8PuEZxbt17lqzbCqxmITuII6KpaGiqaaAgXw6W6ScknKfW4fcTZjLqtGdayR7jvuVzeBPdRZkLJyx8P0MOjbvmHcrGaa0uXjjW(sb9K2m1gDBCWK5tP8MVcMQ3xGYc4GUWjLMAtNOOo5daiEHq7Csj0e41Uxa2BiqaaAQ4KeyFPGEsBil4GbchtMpLYB(kyQEFbklGd6YUeojbvixtRaYxbt17qjnRiFxsreqKHdMmFkL38vWu9(cuwah0fsPA6fqhfc1K6F2jq(u6FnS7c7oYidTU7pBsOokk(Fq7bC33Rb0R757boIJ3ij44yxkOJJafehrdoI1wA3xbt1rdCek7Tidum4iVScoMiEztxm4iJuQOeEdhCpnQGJKD3EGJbSs3jqxm4iA4jvuVH2qdC0lCen8KkQ3qBnrtcQyqdCCDYqZB3WbXbr7bC33Rb0R757boIJ3ij44yxkOJJafehrdFfmvVVaLf0ahHYElYafdoYlRGJjIx20fdoYiLkkH3Wb3tJk44A7bogWkDNaDXGJOHNur9gAdnWrVWr0WtQOEdT1enjOIbnWX1jdnVDdhCpnQGJOP9ahdyLUtGUyWr0WtQOEdTHg4Ox4iA4jvuVH2AIMeuXGg446KHM3UHdIdgqTlf0fdoIMWXK5tP4iD4oVHd(h6WD(F7pSANOP6)T)kz)T)iAsqfZJ(FyWXf4K)zFC0tQOEJNm4ammX05fcL3enjOIbhdfchtMp7KUOIDeoogoos2FsMpL(NXUiQzuuDw6j3H1cj59)Ay)T)iAsqfZJ(FyWXf4K)XtQOEJNm4ammX05fcL3enjOIbhbdhtMp7KUOIDeoocchj7pjZNs)dNviWrr19XjjV)xrR)2FenjOI5r)pm44cCY)Spo6jvuVXtgCagMy68cHYBIMeuXGJGHJjZNDsxuXochhdmogG)KmFk9pCwHahfv3hNK8(Fna)T)KmFk9p8cH2HL)hrtcQyE0F)VU2F7pjZNs)JryJn9rr1jkQ)hrtcQyE0F)9)yeGeH6)T)kz)T)KmFk9p8fHs70IT1FenjOI5r)9)Ay)T)KmFk9pSKs7acLeI6c8pIMeuX8O)(FfT(B)jz(u6Fs0S09IZ)JOjbvmp6V)xdWF7pjZNs)Jr2viWUnrnS)iAsqfZJ(7)11(B)r0KGkMh9)KmFk9pSKs7jZNs70H7)HoCVRPv(tba0rXmV)xrt)T)iAsqfZJ(FyWXf4K)Hvf1uB0ghXAlTBeBPdR7RGP6nOyZr54yGXXaGJGHJ7JJ(kyQEhkPz1F4oCy(FLS)KmFk9pqeTNmFkTthU)h6W9UMw5p(kyQEFbklV)xV))2FenjOI5r)pm44cCY)4RGP6DOKMv)H7WH5)vY(tY8P0)ar0EY8P0oD4(FOd37AAL)WrS2s7(kyQ(7)17ZF7pIMeuX8O)hgCCbo5Fyvrn1gTXrS2s7gXw6W6(kyQEdk2CuoogoogG7WXqHWrGbfjVdfBokhhdmoYQIAQnAJJyTL2nIT0H19vWu9guS5OCCeCCmS1(tY8P0)WrS2s77gQamIAE)VU3)B)jz(u6FyjL2nqjnCpPBjq(FenjOI5r)9)kz393(JOjbvmp6)HbhxGt(hOaafoPKGk)jz(u6FmvzF)Vsgz)T)KmFk9pgXw6W6ChkkkN0FenjOI5r)9)kzH93(tY8P0)qmuHZkeikPtuwcbY)JOjbvmp6V)xjdT(B)r0KGkMh9)WGJlWj)tY8zN0fvSJWXXWXrYWrWWX9XrpPI6nEYGdWWetNxiuEt0KGkgCemCKabaOTzOM(yx4nUNSTWXWbHJCX9rrXBJDHw8P0(yx44iy4ibcaqZxbt1BMAJIJGHJSQOMAJ24iwBPDJylDyDFfmvVbfBokhhdhhx7pjZNs)ZyxOfFk99)kzb4V9hrtcQyE0)ddoUaN8pjZNDsxuXochhdhhddhbdhjqaaABgQPp2fEJ7jBlCmCq4ixCFuu82yxOfFkTp2foocgosGaa08vWu9MP2O)jz(u6Fg7cT4tPV)xjBT)2FenjOI5r)pm44cCY)WleANtkHgCeeoUgogkeosGaa0uXjjW(sb9K2qw(tY8P0)qkvtVa6OqOMuF)VsgA6V9hrtcQyE0)ddoUaN8p8cH25KsObhdheoIw4iy4iRkQP2OnoI1wA3i2shw3xbt1BqXMJYXXWXXWUdhbdhxhhzvrn1gTXrS2s77gQamIAAqXMJYXXWXX1WXqHWX9XrpPI6noI1wAF3qfGrutt0KGkgCCBCemCKvf1uB0glP0UbkPH7jDlbYBqXMJYXXWXXW(tY8P0)qkvtVa6OqOMuF)Vs29)3(JOjbvmp6)HbhxGt(N1XrwTt0u9MkmyrlObhdfchz1ort1B6GIK3bsbh3ghbdh3hh9KkQ3uXjjW(sb9K2enjOI5pChom)Vs2FsMpL(hwsP9K5tPD6W9)qhU310k)Hv7env)9)kz3N)2FenjOI5r)pm44cCY)qGaa0mIT0H1zfuAqjzoocgoYleANtkHgCmW4ya(tY8P0)yeBPef1F)Vs2E)V9hrtcQyE0)ddoUaN8pSQOMAJ24iwBPDJylDyDFfmvVbfBokhhbhhzvrn1gTXrS2s7gXw6W6(kyQEZGatFkfhdhhbguK8ouS5OCCmuiCeyqrY7qXMJYXXaJJSQOMAJ24iwBPDJylDyDFfmvVbfBokhhbhhjBT)KmFk9pOGJTgO0bekkKeAE)Vg2D)T)KmFk9piCPpUy5)r0KGkMh93)RHr2F7pIMeuX8O)hgCCbo5FiqaaABgQPp2fEJ7jBlCmCCKmCemCKabaOzeBPdRZkO04EY2chdmoIw)jz(u6FwQncSZNfsL((FnSW(B)jz(u6F4fcTZD4SL8hrtcQyE0F)VggA93(JOjbvmp6)jz(u6FyjL2tMpL2Pd3)dD4ExtR8hwTt0u93)RHfG)2FsMpL(hoP0uB6ef1)JOjbvmp6V)(FwGcRSeP)3(RK93(JOjbvmp6)HbhxGt(hFScogooEhocgoUpoUiElPZo5pjZNs)dGq7MYoA6tPV)xd7V9NK5tP)HJyTL2bekkKeA(JOjbvmp6V)xrR)2FenjOI5r)pm44cCY)qGaa02mutFSl8g3t2w4y44iz4iy4ibcaqZi2shwNvqPX9KTfogyq4yy)jz(u6FwQncSZNfsL((Fna)T)iAsqfZJ(FyWXf4K)zDCKO4CCmuiCmz(uAZi2sjkQ3yj3Xrq44D4424iy4iVqODoPeA44yGXXa8NK5tP)Xi2sjkQ)(7)HJyTL29vWu9)2FLS)2FenjOI5r)pm44cCY)WleANtkHgCeeoU2FsMpL(hsPA6fqhfc1K67)1W(B)r0KGkMh9)WGJlWj)dbcaqZi2shwNvqPHSGJGHJRJJEsf1BgXw6W6Ss5i2fFkTjAsqfdogkeosGaa0uXjjW(sb9K2m1gfh3(pjZNs)JrSLsuu)p0rLoZ8NWU79)kA93(JOjbvmp6)HbhxGt(hceaG2MHA6JDH34EY2chbhhhLv2rr1h7chhdmogaCemCCDC0tQOEZi2shwNvkhXU4tPnrtcQyWXqHWrceaGMkojb2xkON0MP2O442)jz(u6F4KstTPtuu)p0rLoZ8NWU79)Aa(B)jz(u6FqbhBnqPdiuuij08hrtcQyE0F)VU2F7pjZNs)dhXAlTVBOcWiQ5pIMeuX8O)(Ffn93(tY8P0)WskTBGsA4Es3sG8)iAsqfZJ(7)17)V9NK5tP)HuQMEb0rHqnP(hrtcQyE0F)VEF(B)r0KGkMh9)WGJlWj)dbcaqZi2shwNvqPHSGJGHJeiaanvCscSVuqpPnKfCemCCDCCDCKabaOTBOcWiQPbfBokhhdhhxdhdfch3hh9KkQ34iwBP9DdvagrnnrtcQyWXTXrWWX1XrceaGgk4yRbkDaHIcjHMguS5OCCmCCCnCmuiCKabaOHco2AGshqOOqsOPzQnkoUnoU9FsMpL(hJylLOO(7)19(F7pIMeuX8O)hgCCbo5FiqaaAQ4KeyFPGEsBil4iy4464464ibcaqB3qfGrutdk2CuoogooUgogkeoUpo6jvuVXrS2s77gQamIAAIMeuXGJBJJGHJRJJeiaanuWXwdu6acffscnnOyZr54y444A4yOq4ibcaqdfCS1aLoGqrHKqtZuBuCCBCC7)KmFk9pCsPP20jkQ)(FLS7(B)r0KGkMh9)WGJlWj)Z(4ONur9MrSLoSoRuoIDXNsBIMeuXGJHcHJeiaaTnd10h7cVX9KTfogooU2FsMpL(hoI1wA3i2shw3xbt1F)Vsgz)T)KmFk9pCsPP20jkQ)hrtcQyE0F)9)uaaDumZF7Vs2F7pIMeuX8O)hgCCbo5FweVzeBPdR7RGP6TK5Zo5pjZNs)dHa5cCRrr9(FnS)2FenjOI5r)pm44cCY)qGaa0ieixGBnkQgYcogkeoUiEZi2shw3xbt1BjZNDcocgoUpoctM0CyrP)jz(u6FwkFk99)kA93(JOjbvmp6)HbhxGt(NfXBgXw6W6(kyQElz(St(tY8P0)qqRY0bqGRE)VgG)2FenjOI5r)pm44cCY)SiEZi2shw3xbt1BjZNDYFsMpL(hGbke0QmV)(F8vWu9(cuw(B)vY(B)r0KGkMh9)KmFk9pMQS)HoQ0zM)Gw39(FnS)2FenjOI5r)pm44cCY)Spo6jvuVzeBPdRZkLJyx8P0MOjbvm)jz(u6FmIT0H15ouuuoP3)RO1F7pjZNs)Jkojb2xkON0)iAsqfZJ(7)1a83(JOjbvmp6)HbhxGt(hEHq7Csj0GJGWX1(tY8P0)Gco2AGshqOOqsO59)6A)T)iAsqfZJ(FyWXf4K)Hxi0oNucn4iiCma4iy44644(4ONur9gk4yRbkDaHIcjHMMOjbvm4yOq4iRkQP2OnuWXwdu6acffscnnOyZr5442)jz(u6F4iwBP9DdvagrnV)xrt)T)iAsqfZJ(FyWXf4K)zFC0tQOEdfCS1aLoGqrHKqtt0KGkgCmuiCKvf1uB0gk4yRbkDaHIcjHMguS5O8)KmFk9pSKs7gOKgUN0Tei)9)69)3(JOjbvmp6)HbhxGt(hceaGMrSLoSoRGsdzbhbdh5fcTZjLqdogyCma4iy4464ONur9MrSLoSoRuoIDXNsBIMeuXGJHcHJeiaanvCscSVuqpPntTrXXT)tY8P0)yeBPef1F)VEF(B)r0KGkMh9)WGJlWj)dVqODoPeAWXaJJRHJ3dhdaoU3GJeiaanvCscSVuqpPnKL)KmFk9pCsPP20jkQ)(FDV)3(tY8P0)qkvtVa6OqOMu)JOjbvmp6V)(7)jrCsf8pNXgWE)9)b]] )


end
