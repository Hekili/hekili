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
        if not IsKnown( 265187 ) then return end

        hog_shards = hog_shards or 0

        -- The last part of a Tyrant Prep phase should be a HoG cast.
        if not tyrant_ready and cooldown.summon_demonic_tyrant.remains < 5 then
            if talent.doom.enabled and not debuff.doom.up then return end
            if talent.demonic_strength.enabled and not talent.demonic_consumption.enabled and cooldown.demonic_strength.remains < 5 then return end
            if talent.nether_portal.enabled and cooldown.nether_portal.remains < 5 then return end
            if talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < 5 then return end
            if talent.summon_vilefiend.enabled and cooldown.summon_vilefiend.remains < 5 then return end
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
                    if IsSpellKnown( 265187 ) then
                        local start, duration = GetSpellCooldown( 265187 )

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

    spec:RegisterPack( "Demonology", 20201129, [[dq0uSaqivbEesP2ePKrbK6uajRsvjkVsvQzHu5wQkPDPKFjLAyKsDmKQwgsQNPQuMgssxJuvBtvq9nvbX4qsOZPQewNQG08qk5EQQ2hPkhejr0cbIhIKinrKeCrvLiDsvLQALKIzQQeXovL8tvLOAOijQLIKi8uPAQQI(QQsf7vL)kyWk1HfTyi9yOMmjxg1Mb8zKy0a1Pv8AvHMnHBl0UP8BjdxkwoONJy6uDDi2osX3vvmEvLkDEPK1RQuL5tQSFI(O)EEDv689IATPwB6PN6VyrV(6)n6P)6ERg(6nj(XKcFDlJ81PcCSSsuuAD9MSLOs1986KcbI5Rd29gYdTDBkJdgbDHRyBYerePpLHHjG3MmrC7RJImc)7Bh61vPZ3lQ1MATPNEQ)If9utvQQT(xN0W47f1p8dFDWJsX2HEDftWxN2YnvGJLvIIsl5(7KqrHFuQH2Yny3Bip02TPmoye0fUITjterK(uggMaEBYeXTLAOTC)QOHJOmuUP(lOtUPwBQ1wQrQH2Ynvk40OWKhQudTL7Vk39gwiK7VKc)4sQH2Y9xL7VCt0sUHmUIr2uYnvGJLHwcxUBG8xXvenD5EaK7XL7Hi3Jr80C5g0fuUbNqfojUCduq5gTieMaQLudTL7Vk3u56ddL7(0aUm5ofI6dRK7gi)vCfrtxU9sUBGfwUhJ4P5YnvGJLHwcFj1qB5(RYnvcMMHWY93p2ikYuMCJMewj3Lj3FN6dyovYnfKrXlPgAl3FvUPY0qLLBpfS5Y9yodHin(66nWcye81PTCtf4yzLOO0sU)ojuu4hLAOTCd29gYdTDBkJdgbDHRyBYerePpLHHjG3MmrCBPgAl3VkA4ikdLBQ)c6KBQ1MATLAKAOTCtLconkm5Hk1qB5(RYDVHfc5(lPWpUKAOTC)v5(l3eTKBiJRyKnLCtf4yzOLWL7gi)vCfrtxUha5EC5EiY9yepnxUbDbLBWjuHtIl3afuUrlcHjGAj1qB5(RYnvU(Wq5UpnGltUtHO(Wk5UbYFfxr00LBVK7gyHL7XiEAUCtf4yzOLWxsn0wU)QCtLGPziSC)9JnIImLj3OjHvYDzY93P(aMtLCtbzu8sQH2Y9xLBQmnuz52tbBUCpMZqisJVKAKAOTC)L(DzmIZk5gLbkil34kIMUCJYugJSKBQKym34e52k7RGtyeari3j2NYiYDzIwlPMe7tzKvdKXven93)TbyrqvXXsFkJUb43NiRN2A9Gg2xPyOHLAsSpLrwnqgxr00F)3MGeJLfAyxQjX(ugz1azCfrt)9F7M6dddKPbCz0na)OiaaRpJqfMydzr8e)OE0RfkcaWsXXYgCaxqEr8e)iT(PwQjX(ugz1azCfrt)9FBfhldTeoDdWpAri60LyFkBP4yzOLWx4K4)Al1KyFkJSAGmUIOP)(VnbCQQpb0s4sn0wUtSpLrwnqgxr00F)3MMeojQGPZYi)7TGP5biNQw0rtkq4FCvcv9XweKySSGIJLn4G3cMMVGCmhJql91c0pWtbB(svvCXwIkyLoDkgfbayPQkUqAaLwGgfbayP4yzdoqCiBuCWlKgD6EGNc28LIJLn4aXHSrXbVylrfSsNopfS5lfhlBWbCzeKyJpLTylrfScuAb6h4PGnFzSdMHHMc6PyXwIkyLoDOiaalJDWmm0uqpflKgD6Wvju1hBzSdMHHMc6Pyb5yogrp61huAb6h4PGnFrboXAGCaGfuqsOAXwIkyLoD4QeQ6JTOaNynqoaWckijuTGCmhJOh96dkTa9d8uWMViiXyzbAgbdmSPwSLOcwPthUkHQ(ylcsmwwGMrWadBQfKJ5ye9OxFqPfOFGNc28LIJLn4aUmcsSXNYwSLOcwPthkcaW6ZiuHj2qwin60rkerGaoHQF91PdfbayzSdMHHMc6PyH0OfPqebc4eQ0tBqj1i1qB5(l97YyeNvYntddBj3(ez52bZYDI9ck3drUtAYrKOcEj1KyFkJ8tAyHiik8Jsnj2NYiV)BJtHiaWcWiMZqPMe7tzK3)TZVlh8IqKAsSpLrE)3wX0uiWqmPmyPMe7tzK3)TXPqesSpLfedXPZYi)xaabkyLutI9PmY7)24uicj2NYcIH40zzK)zcHnmtKAsSpLrE)3gIyHe7tzbXqC6SmY)ElyAEObYn0rC4G9F6PBa(Xvju1hBrqIXYckow2GdElyA(cYXCmcT0xRh4TGP5biNQwsnj2NYiV)BdrSqI9PSGyioDwg5FcsmwwWBbtZPJ4Wb7)0t3a87TGP5biNQwsnj2NYiV)BtWfcCmkbFCWSutI9PmY7)2tSHn1yuc40tIdRgWSutI9PmY7)2KcreGLt3a8NyFOHdSXXHj6rVutI9PmY7)2kgpX0hJsaTeoDdWpO9esH9fyofo4qd2PL(ARthWqbShGCmhJON(AdkPMe7tzK3)TjiXyzbAgbdmSPOBa(Xvju1hBrqIXYckow2GdElyA(cYXCmIEuvBD6agkG9aKJ5yeAHRsOQp2IGeJLfuCSSbh8wW08fKJ5yK3uRVutI9PmY7)24uickiNkINIhzirQjX(ug59FBvvr6gGFidazc4evWsnj2NYiV)BR4yzdoqCiBuCWsnj2NYiV)BJocMGleifoGwrugsKAsSpLrE)3gCAQqbeOGiuPr3a8tkerGaoHQF91PdfbayzSdMHHMc6PyH0i1KyFkJ8(Vn40uHciqbrOsJUb4NuiIabCcv69)nTWvju1hBrqIXYckow2GdElyA(cYXCmIEuRTwGgxLqvFSfbjgllqZiyGHn1cYXCmIE6Rt3d8uWMViiXyzbAgbdmSPwSLOcwbkTWvju1hBHtHiOGCQiEkEKHKfKJ5ye9OwQjX(ug59FBfhldTeoDdWpkcaWsXXYgCaxqEb5e7ArkerGaoHkArvPMe7tzK3)TPaNynqoaWckijur3a8JRsOQp2IGeJLfuCSSbh8wW08fKJ5yK34QeQ6JTiiXyzbfhlBWbVfmnFPqGPpLPhWqbShGCmhJOthWqbShGCmhJqlCvcv9XweKySSGIJLn4G3cMMVGCmhJ8ME9LAsSpLrE)3gHWHX5irQjX(ug59F7M6dddKPbCz0na)OiaaRpJqfMydzr8e)OE0RfkcaWsXXYgCaxqEr8e)iT(MutI9PmY7)2KcreioCEKLAsSpLrE)3EInIImLr3a8JIaaS(mcvyInKfXt8J6rTwKgwicEcPWoznXgrrMY07NAPMe7tzK3)TjGtv9jGwcxQrQjX(ugzXecByM8)PGcfn8ybitklnmt3a8JRsOQp2IGeJLfuCSSbh8wW08fKJ5ye9OQ(snj2NYilMqydZK3)TJCSGTcfqqGGhvqb5msKAsSpLrwmHWgMjV)BJkQsfkGGdMdSXXwsnj2NYilMqydZK3)TPGKq1KwOac53JHLdwQjX(ugzXecByM8(VnCAAeCySaPjXSutI9PmYIje2Wm59FBGcJqyvi)EmCCoGYzuQjX(ugzXecByM8(VDdcCaAngLaQijUutI9PmYIje2Wm59FBiNnJrjaiYitOBa(9esH9fyofo4qd21JkQToDEcPW(cmNchCOb70IAT1PdyOa2dqoMJrO130wNopHuyF5tKdEfAWEGAT1JQAl1KyFkJSycHnmtE)3gxgMnhMoRcaImYsnj2NYilMqydZK3)TDWCaXqletfakiMPBa(rraawqg)OGjKaqbX8cYXCmIuJutI9PmYQaacuWQFugsy4JJrHUb4VH9LIJLn4G3cMMVsSp0Wsnj2NYiRcaiqbRE)3UP8Pm6gGFueaGfkdjm8XXOSqA0PRH9LIJLn4G3cMMVsSp0WA9ayI5LdlHqQjX(ugzvaabky17)2OIQubaeyl6gG)g2xkow2GdElyA(kX(qdl1KyFkJSkaGafS69FBGbYOIQu0na)nSVuCSSbh8wW08vI9HgwQrQjX(ugzrqIXYcElyA(p40uHciqbrOsJUb4NuiIabCcv)6l1KyFkJSiiXyzbVfmn)9FBfhldTeoDdWpkcaWsXXYgCaxqEH0OfO9uWMVuCSSbhWLrqIn(u2ITevWkD6qraawg7GzyOPGEkwQ6Jbk6eJXbS6NATLAsSpLrweKySSG3cMM)(VnbCQQpb0s40na)OiaaRpJqfMydzr8e)47XWvCmkHj2qOfv1c0EkyZxkow2Gd4YiiXgFkBXwIkyLoDOiaalJDWmm0uqpflv9XafDIX4aw9tT2snj2NYilcsmwwWBbtZF)3gNcrqb5ur8u8idjsnj2NYilcsmwwWBbtZF)3gCAQqbeOGiuPj1KyFkJSiiXyzbVfmn)9FBfhldTeoDdWpkcaWsXXYgCaxqEH0OfkcaWYyhmddnf0tXcPrlqdAueaGfnJGbg2ulihZXi6PVoDpWtbB(IGeJLfOzemWWMAXwIkyfO0c0OiaalkWjwdKdaSGcscvlihZXi6PVoDOiaalkWjwdKdaSGcscvlv9XafOKAsSpLrweKySSG3cMM)(VnbCQQpb0s40na)OiaalJDWmm0uqpflKgTanOrraaw0mcgyytTGCmhJON(609apfS5lcsmwwGMrWadBQfBjQGvGslqJIaaSOaNynqoaWckijuTGCmhJON(60HIaaSOaNynqoaWckijuTu1hduGsQH2YDI9PmYIGeJLf8wW083)TPjHtIky6SmY)ElyAEaYPQfD0Kce()b4QeQ6JTiiXyzbfhlBWbVfmnFb5u1sQjX(ugzrqIXYcElyA(7)2eKySSGIJLn4G3cMMt3a8tkerGaoHkYV2snj2NYilcsmwwWBbtZF)3Maov1NaAjCPgPMe7tzKL3cMMhAGCZVQQiDIX4aw9)nTLAsSpLrwElyAEObYnV)BR4yzdoqCiBuCW0na)pWtbB(sXXYgCaxgbj24tzl2subRKAsSpLrwElyAEObYnV)BBSdMHHMc6PqQjX(ugz5TGP5Hgi38(Vnf4eRbYbawqbjHkPMe7tzKL3cMMhAGCZ7)2eKySSanJGbg2usnj2NYilVfmnp0a5M3)TXPqeuqovepfpYqIutI9PmYYBbtZdnqU59FBfhldTeoDdWpkcaWsXXYgCaxqEH0OfPqebc4eQOfv1c0EkyZxkow2Gd4YiiXgFkBXwIkyLoDOiaalJDWmm0uqpflv9XaLutI9PmYYBbtZdnqU59FBc4uvFcOLWPBa(jfIiqaNqfT0)Ru9ldfbayzSdMHHMc6PyH0i1qB5oX(ugz5TGP5Hgi38(VnnjCsubtNLr(3BbtZdqovTOJMuGW)0l1KyFkJS8wW08qdKBE)3gCAQqbeOGiuPDDAyizk7ErT2uRn90tpvV(NeAJrHC9VFSPGoRK7hwUtSpLj3IH4KLuZ1fdXj3ZRZecByMCpVx0FpVoBjQGvhixhdhNHtEDCvcv9XweKySSGIJLn4G3cMMVGCmhJi36j3uv)RNyFk76FkOqrdpwaYKYsdZNFVO(EE9e7tzxpYXc2kuabbcEubfKZi56SLOcwDGC(96B3ZRNyFk76OIQuHci4G5aBCS11zlrfS6a587fvVNxpX(u21PGKq1KwOac53JHLd(6SLOcwDGC(9s)751tSpLDD400i4WybstI5RZwIky1bY53Rh(EE9e7tzxhOWiewfYVhdhNdOCgVoBjQGvhiNFVEi3ZRNyFk76niWbO1yucOIK4xNTevWQdKZVxuX751zlrfS6a56y44mCYR7jKc7lWCkCWHgSl36j3urTLBD6KBpHuyFbMtHdo0GD5MwYn1Al360j3adfWEaYXCmICtl5(BAl360j3EcPW(YNih8k0G9a1Al36j3uv7RNyFk76qoBgJsaqKrMC(96lUNxpX(u21XLHzZHPZQaGiJ81zlrfS6a587f9AFpVoBjQGvhixhdhNHtEDueaGfKXpkycjauqmVGCmhJC9e7tzx3bZbedTqmvaOGy(8ZVUIbseHFpVx0FpVEI9PSRtAyHiik8JxNTevWQdKZVxuFpVEI9PSRJtHiaWcWiMZWRZwIky1bY53RVDpVEI9PSRNFxo4fHCD2subRoqo)Er1751tSpLDDfttHadXKYGVoBjQGvhiNFV0)EED2subRoqUEI9PSRJtHiKyFkligIFDXq8GLr(6faqGcwD(96HVNxNTevWQdKRNyFk764uicj2NYcIH4xxmepyzKVotiSHzY53RhY986SLOcwDGCDmCCgo51Xvju1hBrqIXYckow2GdElyA(cYXCmICtl5wF5wl5(bYT3cMMhGCQADDIdhSFVO)6j2NYUoeXcj2NYcIH4xxmepyzKVU3cMMhAGCZ53lQ4986SLOcwDGCDmCCgo519wW08aKtvRRtC4G97f9xpX(u21HiwiX(uwqme)6IH4blJ81jiXyzbVfmn)871xCpVEI9PSRtWfcCmkbFCW81zlrfS6a587f9AFpVEI9PSRpXg2uJrjGtpjoSAaZxNTevWQdKZVx0t)986SLOcwDGCDmCCgo51tSp0Wb244We5wp5M(RNyFk76KcreGLF(9IEQVNxNTevWQdKRJHJZWjVoOLBpHuyFbMtHdo0GD5MwYT(Al360j3adfWEaYXCmICRNCRV2YnOUEI9PSRRy8etFmkb0s4NFVO)B3ZRZwIky1bY1XWXz4KxhxLqvFSfbjgllO4yzdo4TGP5lihZXiYTEYnv1wU1PtUbgkG9aKJ5ye5MwYnUkHQ(ylcsmwwqXXYgCWBbtZxqoMJrK73Yn16F9e7tzxNGeJLfOzemWWM687f9u9EE9e7tzxhNcrqb5ur8u8idjxNTevWQdKZVx0R)986SLOcwDGCDmCCgo51HmaKjGtubF9e7tzxxvv887f9p8986j2NYUUIJLn4aXHSrXbFD2subRoqo)Er)d5EE9e7tzxhDembxiqkCaTIOmKCD2subRoqo)Erpv8EED2subRoqUogoodN86KcreiGtOsU)LB9LBD6KBueaGLXoyggAkONIfsZ1tSpLDDWPPcfqGcIqL253l6)I751zlrfS6a56y44mCYRtkerGaoHk5wVF5(BYTwYnUkHQ(ylcsmwwqXXYgCWBbtZxqoMJrKB9KBQ1wU1sUbTCJRsOQp2IGeJLfOzemWWMAb5yogrU1tU1xU1PtUFGC7PGnFrqIXYc0mcgyytTylrfSsUbLCRLCJRsOQp2cNcrqb5ur8u8idjlihZXiYTEYn1xpX(u21bNMkuabkicvANFVOw7751zlrfS6a56y44mCYRJIaaSuCSSbhWfKxqoXUCRLCtkerGaoHk5MwYnvVEI9PSRR4yzOLWp)Ern93ZRZwIky1bY1XWXz4KxhxLqvFSfbjgllO4yzdo4TGP5lihZXiY9B5gxLqvFSfbjgllO4yzdo4TGP5lfcm9Pm5wp5gyOa2dqoMJrKBD6KBGHcypa5yogrUPLCJRsOQp2IGeJLfuCSSbh8wW08fKJ5ye5(TCtV(xpX(u21PaNynqoaWckijuD(9IAQVNxpX(u21riCyCosUoBjQGvhiNFVO(B3ZRZwIky1bY1XWXz4Kxhfbay9zeQWeBilIN4hLB9KB6LBTKBueaGLIJLn4aUG8I4j(r5MwY93UEI9PSR3uFyyGmnGl787f1u9EE9e7tzxNuiIaXHZJ81zlrfS6a587f16FpVoBjQGvhixhdhNHtEDueaG1NrOctSHSiEIFuU1tUPwU1sUjnSqe8esHDYAInIImLj369l3uF9e7tzxFInIImLD(9I6h(EE9e7tzxNaov1NaAj8RZwIky1bY5NF9giJRiA63Z7f93ZRZwIky1bY1XWXz4Kx3Nil36j3Al3Aj3pqUByFLIHg(6j2NYUoalcQkow6tzNFVO(EE9e7tzxNGeJLfaybfKeQUoBjQGvhiNFV(2986SLOcwDGCDmCCgo51rraawFgHkmXgYI4j(r5wp5ME5wl5gfbayP4yzdoGliViEIFuUP1VCt91tSpLD9M6dddKPbCzNFVO6986SLOcwDGCDmCCgo51rlcrU1PtUtSpLTuCSm0s4lCsC5(xU1(6j2NYUUIJLHwc)87L(3ZRNyFk76eWPQ(eqlHFD2subRoqo)8RtqIXYcElyA(98Er)986SLOcwDGCDmCCgo51jfIiqaNqLC)l36F9e7tzxhCAQqbeOGiuPD(9I6751zlrfS6a56j2NYUUIJLHwc)6y44mCYRJIaaSuCSSbhWfKxinYTwYnOLBpfS5lfhlBWbCzeKyJpLTylrfSsU1PtUrraawg7GzyOPGEkwQ6Jj3G66IX4awDDQ1(8713UNxNTevWQdKRNyFk76eWPQ(eqlHFDmCCgo51rraawFgHkmXgYI4j(r5(TCpgUIJrjmXgICtl5MQYTwYnOLBpfS5lfhlBWbCzeKyJpLTylrfSsU1PtUrraawg7GzyOPGEkwQ6Jj3G66IX4awDDQ1(87fvVNxpX(u21XPqeuqovepfpYqY1zlrfS6a587L(3ZRNyFk76GttfkGafeHkTRZwIky1bY53Rh(EED2subRoqUogoodN86OiaalfhlBWbCb5fsJCRLCJIaaSm2bZWqtb9uSqAKBTKBql3GwUrraaw0mcgyytTGCmhJi36j36l360j3pqU9uWMViiXyzbAgbdmSPwSLOcwj3GsU1sUbTCJIaaSOaNynqoaWckijuTGCmhJi36j36l360j3OiaalkWjwdKdaSGcscvlv9XKBqj3G66j2NYUUIJLHwc)871d5EED2subRoqUogoodN86OiaalJDWmm0uqpflKg5wl5g0YnOLBueaGfnJGbg2ulihZXiYTEYT(YToDY9dKBpfS5lcsmwwGMrWadBQfBjQGvYnOKBTKBql3OiaalkWjwdKdaSGcscvlihZXiYTEYT(YToDYnkcaWIcCI1a5aalOGKq1svFm5guYnOUEI9PSRtaNQ6taTe(53lQ4986SLOcwDGCDmCCgo51jfIiqaNqfrU)LBTVEI9PSRtqIXYckow2GdElyA(53RV4EE9e7tzxNaov1NaAj8RZwIky1bY5NF9caiqbRUN3l6VNxNTevWQdKRJHJZWjVEd7lfhlBWbVfmnFLyFOHVEI9PSRJYqcdFCmkNFVO(EED2subRoqUogoodN86Oiaalugsy4JJrzH0i360j3nSVuCSSbh8wW08vI9HgwU1sUFGCdtmVCyjexpX(u21BkFk78713UNxNTevWQdKRJHJZWjVEd7lfhlBWbVfmnFLyFOHVEI9PSRJkQsfaqGTo)Er1751zlrfS6a56y44mCYR3W(sXXYgCWBbtZxj2hA4RNyFk76adKrfvPo)8R7TGP5Hgi3CpVx0FpVoBjQGvhixpX(u21vvfVUymoGvx)BAF(9I6751zlrfS6a56y44mCYR)a52tbB(sXXYgCaxgbj24tzl2subRUEI9PSRR4yzdoqCiBuCWNFV(2986j2NYUUXoyggAkONIRZwIky1bY53lQEpVEI9PSRtboXAGCaGfuqsO66SLOcwDGC(9s)751tSpLDDcsmwwGMrWadBQRZwIky1bY53Rh(EE9e7tzxhNcrqb5ur8u8idjxNTevWQdKZVxpK751zlrfS6a56y44mCYRJIaaSuCSSbhWfKxinYTwYnPqebc4eQKBAj3uvU1sUbTC7PGnFP4yzdoGlJGeB8PSfBjQGvYToDYnkcaWYyhmddnf0tXsvFm5guxpX(u21vCSm0s4NFVOI3ZRZwIky1bY1XWXz4KxNuiIabCcvYnTKB9L7Vk3uvU)YKBueaGLXoyggAkONIfsZ1tSpLDDc4uvFcOLWp)E9f3ZRNyFk76GttfkGafeHkTRZwIky1bY5NF(1tehCbVEFIuPNF(Da]] )


end
