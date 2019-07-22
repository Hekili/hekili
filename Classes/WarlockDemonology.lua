-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 266, true )

    spec:RegisterResource( Enum.PowerType.SoulShards )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        dreadlash = 19290, -- 264078
        demonic_strength = 22048, -- 267171
        bilescourge_bombers = 23138, -- 267211

        demonic_calling = 22045, -- 205145
        power_siphon = 21694, -- 264130
        doom = 23158, -- 265412

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        from_the_shadows = 22477, -- 267170
        soul_strike = 22042, -- 264057
        summon_vilefiend = 23160, -- 264119

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        demonic_circle = 19288, -- 268358

        soul_conduit = 23147, -- 215941
        inner_demons = 23146, -- 267216
        grimoire_felguard = 21717, -- 111898

        sacrificed_souls = 23161, -- 267214
        demonic_consumption = 22479, -- 267215
        nether_portal = 23091, -- 267217
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3501, -- 196029
        adaptation = 3500, -- 214027
        gladiators_medallion = 3499, -- 208683

        master_summoner = 1213, -- 212628
        singe_magic = 154, -- 212623
        call_felhunter = 156, -- 212619
        curse_of_weakness = 3507, -- 199892
        curse_of_tongues = 3506, -- 199890
        casting_circle = 3626, -- 221703
        curse_of_fragility = 3505, -- 199954
        pleasure_through_pain = 158, -- 212618
        essence_drain = 3625, -- 221711
        call_fel_lord = 162, -- 212459
        nether_ward = 3624, -- 212295
        call_observer = 165, -- 201996
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

    local other_demon = {}
    local other_demon_v = {}

    local imps = {}
    local guldan = {}
    local guldan_v = {}

    local shards_for_guldan = 0

    local last_summon = {}


    local FindUnitBuffByID = ns.FindUnitBuffByID


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        local now = GetTime()

        if source == state.GUID then
            if subtype == "SPELL_SUMMON" then
                -- Dreadstalkers: 104316, 12 seconds uptime.
                if spellID == 193332 or spellID == 193331 then table.insert( dreadstalkers, now + 12 )

                -- Vilefiend: 264119, 15 seconds uptime.
                elseif spellID == 264119 then table.insert( vilefiend, now + 15 )

                -- Wild Imp: 104317 and 279910, 20 seconds uptime.
                elseif spellID == 104317 or spellID == 279910 then
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

                -- Demonic Tyrant: 265187, 15 seconds uptime.
                elseif spellID == 265187 then table.insert( demonic_tyrant, now + 15 )

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
                shards_for_guldan = UnitPower( "player", Enum.PowerType.SoulShards )

            elseif subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 196277 then
                    table.wipe( wild_imps )
                    table.wipe( imps )

                elseif spellID == 264130 then
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end

                elseif spellID == 105174 then
                    -- Hand of Guldan; queue imps.
                    if shards_for_guldan >= 1 then table.insert( guldan, now + 1.11 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, now + 1.51 ) end
                    if shards_for_guldan >= 3 then table.insert( guldan, now + 1.91 ) end

                elseif spellID == 265187 and state.talent.demonic_consumption.enabled then
                    table.wipe( guldan ) -- wipe incoming imps, too.
                    table.wipe( wild_imps )
                    table.wipe( imps )

                end

            end

        elseif imps[ source ] and subtype == "SPELL_CAST_START" then
            local demonic_power = FindUnitBuffByID( "player", 265273 )

            if not demonic_power then
                local imp = imps[ source ]

                imp.start = now
                imp.casts = imp.casts + 1

                imp.expires = min( imp.max, now + ( ( 6 - imp.casts ) * 2 * state.haste ) )
            end
        end
    end )


    local wipe = table.wipe

    spec:RegisterHook( "reset_precast", function()
        local i = 1
        while dreadstalkers[ i ] do
            if dreadstalkers[ i ] < now then
                table.remove( dreadstalkers, i )
            else
                i = i + 1
            end
        end

        wipe( dreadstalkers_v )
        for n, t in ipairs( dreadstalkers ) do dreadstalkers_v[ n ] = t end


        i = 1
        while( vilefiend[ i ] ) do
            if vilefiend[ i ] < now then
                table.remove( vilefiend, i )
            else
                i = i + 1
            end
        end

        wipe( vilefiend_v )
        for n, t in ipairs( vilefiend ) do vilefiend_v[ n ] = t end


        for id, imp in pairs( imps ) do
            if imp.expires < now then
                imps[ id ] = nil
            end
        end

        wipe( wild_imps_v )
        for n, t in pairs( imps ) do table.insert( wild_imps_v, t.expires ) end
        table.sort( wild_imps_v )


        wipe( guldan_v )
        for n, t in ipairs( guldan ) do guldan_v[ n ] = t end


        i = 1
        while( demonic_tyrant[ i ] ) do
            if demonic_tyrant[ i ] < now then
                table.remove( demonic_tyrant, i )
            else
                i = i + 1
            end
        end

        wipe( demonic_tyrant_v )
        for n, t in ipairs( demonic_tyrant ) do demonic_tyrant_v[ n ] = t end


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

        last_summon.name = nil
        last_summon.at = nil
        last_summon.count = nil

        if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > query_time then
            summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - query_time )
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
        if resource == "soul_shards" and buff.nether_portal.up then
            summon_demon( "other", 15, amt )
        end
    end )


    spec:RegisterStateFunction( "summon_demon", function( name, duration, count )
        local db = other_demon_v
        delay = delay or 0

        if name == 'dreadstalkers' then db = dreadstalkers_v
        elseif name == 'vilefiend' then db = vilefiend_v
        elseif name == 'wild_imps' then db = wild_imps_v
        elseif name == 'demonic_tyrant' then db = demonic_tyrant_v end

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
        for k, v in pairs( other_demon_v   ) do other_demon_v  [ k ] = v + duration end
    end )

    spec:RegisterStateFunction( "consume_demons", function( name, count )
        local db = other_demon_v

        if name == 'dreadstalkers' then db = dreadstalkers_v
        elseif name == 'vilefiend' then db = vilefiend_v
        elseif name == 'wild_imps' then db = wild_imps_v
        elseif name == 'demonic_tyrant' then db = demonic_tyrant_v end

        if type( count ) == 'string' and count == 'all' then
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
            if k ~= 'remains' then return 0 end

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


    spec:RegisterStateTable( "imps_spawned_during", setmetatable( {}, {
        __index = function( t, k, v )
            local cap = query_time
            
            if type(k) == 'number' then cap = cap + ( k / 1000 )
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
        },

        doom = {
            id = 265412,
            duration = function () return 30 * haste end,
            tick_time = function () return 30 * haste end,
            max_stack = 1,
        },

        drain_life = {
            id = 234153,
            duration = 5,
            max_stack = 1,
        },

        eye_of_guldan = {
            id = 272131,
            duration = 15,
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

        grimoire_felguard = {
            -- fake buff when grimoire_felguard is up.
            duration = 15,
            generate = function ()
                local cast = rawget( class.abilities.grimoire_felguard, "lastCast" ) or 0
                local up = cast + 15 > query_time

                local gf = buff.grimoire_felguard
                gf.name = class.abilities.grimoire_felguard.name

                if up then
                    gf.count = 1
                    gf.expires = cast + 15
                    gf.applied = cast
                    gf.caster = "player"
                    return
                end
                gf.count = 0
                gf.expires = 0
                gf.applied = 0
                gf.caster = "nobody"                
            end,
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
            duration = 15,
            max_stack = 1,

            generate = function ()
                local applied = class.abilities.nether_portal.lastCast or 0
                local up = applied + 15 > query_time

                local np = buff.nether_portal
                np.name = "Nether Portal"

                if up then
                    np.count = 1
                    np.expires = applied + 15
                    np.applied = applied
                    np.caster = "player"
                    return
                end

                np.count = 0
                np.expires = 0
                np.applied = 0
                np.caster = "nobody"
            end,    
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

        soul_shard = {
            id = 246985,
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
                up = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and exp >= query_time or false end,
                down = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and exp < query_time or true end,
                applied = function () local exp = dreadstalkers_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
                remains = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function () 
                    local c = 0
                    for i, exp in ipairs( dreadstalkers_v ) do
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

        vilefiend = {
            duration = 12,

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


    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 89766,
            known = function () return IsSpellKnownOrOverridesKnown( 119914 ) end,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,

            usable = function () return pet.exists end,
            handler = function ()
                applyDebuff( 'target', 'axe_toss', 4 )
            end,
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
                applyDebuff( 'target', 'banish', 30 )
            end,
        },


        bilescourge_bombers = {
            id = 267211,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 2,
            spendType = "soul_shards",

            talent = 'bilescourge_bombers',

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

            talent = 'burning_rush',

            handler = function ()
                if buff.burning_rush.up then removeBuff( 'burning_rush' )
                else applyBuff( 'burning_rush', 3600 ) end
            end,
        },


        -- PvP:master_summoner.
        call_dreadstalkers = {
            id = 104316,
            cast = function () if pvptalent.master_summoner.enabled then return 0 end
                return buff.demonic_calling.up and 0 or ( 2 * haste )
            end,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 2 - ( buff.demonic_calling.up and 1 or 0 ) end,
            spendType = "soul_shards",

            startsCombat = true,

            handler = function ()
                summon_demon( "dreadstalkers", 12, 2 )
                removeStack( 'demonic_calling' )

                if talent.from_the_shadows.enabled then applyDebuff( 'target', 'from_the_shadows' ) end
            end,
        },


        --[[ command_demon = {
            id = 119898,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
                if pet.felguard.up then runHandler( 'axe_toss' )
                elseif pet.felhunter.up then runHandler( 'spell_lock' )
                elseif pet.voidwalker.up then runHandler( 'shadow_bulwark' )
                elseif pet.succubus.up then runHandler( 'seduction' )
                elseif pet.imp.up then runHandler( 'singe_magic' ) end
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

            talent = 'dark_pact',

            handler = function ()
                applyBuff( 'dark_pact', 20 )
            end,
        },


        demonbolt = {
            id = 264178,
            cast = function () return buff.demonic_core.up and 0 or ( 4.5 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                if buff.forbidden_knowledge.up and buff.demonic_core.down then
                    removeBuff( "forbidden_knowledge" )
                end

                removeStack( 'demonic_core' )
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

            talent = 'demonic_circle',

            handler = function ()
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

            talent = 'demonic_circle',

            handler = function ()
            end,
        },


        demonic_gateway = {
            id = 111771,
            cast = function () return 2 * haste end,
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
                applyBuff( 'demonic_strength' )
            end,
        },


        doom = {
            id = 265412,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,

            talent = 'doom',
            
            cycle = "doom",
            min_ttd = function () return 3 + debuff.doom.duration end,

            -- readyTime = function () return IsCycling() and 0 or debuff.doom.remains end,
            -- usable = function () return IsCycling() or ( target.time_to_die < 3600 and target.time_to_die > debuff.doom.duration ) end,
            handler = function ()
                applyDebuff( 'target', 'doom' )
            end,
        },


        drain_life = {
            id = 234153,
            cast = function () return 5 * haste end,
            cooldown = 0,
            channeled = true,
            gcd = "spell",

            spend = 0,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                applyDebuff( 'drain_life' )
            end,
        },


        enslave_demon = {
            id = 1098,
            cast = function () return 3 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
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
                applyDebuff( 'target', 'fear' )
            end,
        },


        grimoire_felguard = {
            id = 111898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            toggle = 'cooldowns',

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
                local extra_shards = min( 2, soul_shards.current )
                spend( extra_shards, "soul_shards" )

                insert( guldan_v, query_time + 1.05 )
                if extra_shards > 0 then insert( guldan_v, query_time + 1.50 ) end
                if extra_shards > 1 then insert( guldan_v, query_time + 1.90 ) end

                -- Don't immediately summon; queue them up.
                -- summon_demon( "wild_imps", 25, 1 + extra_shards, 1.5 )
            end,
        },


        health_funnel = {
            id = 755,
            cast = function () return 5 * haste end,
            cooldown = 0,
            gcd = "spell",

            channeled = true,            
            startsCombat = false,

            handler = function ()
                applyBuff( 'health_funnel' )
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
            velocity = 30,

            usable = function ()
                if buff.wild_imps.stack < 3 and azerite.explosive_potential.enabled then return false, "too few imps for explosive_potential"
                elseif buff.wild_imps.stack < 1 then return false, "no imps available" end
                return true
            end,

            handler = function ()
                if azerite.explosive_potential.enabled and buff.wild_imps.stack >= 3 then applyBuff( "explosive_potential" ) end
                consume_demons( "wild_imps", "all" )
            end,
        },


        mortal_coil = {
            id = 6789,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                applyDebuff( 'target', 'mortal_coil' )
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

            handler = function ()
            end,
        },


        soul_strike = {
            id = 264057,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = true,
            nobuff = "felstorm",

            usable = function () return pet.exists end,
            handler = function ()
                gain( 1, "soul_shards" )
            end,
        },


        soulstone = {
            id = 20707,
            cast = 3,
            cooldown = 600,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
            end,
        },


        summon_demonic_tyrant = {
            id = 265187,
            cast = function () return 2 * haste end,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            texture = 2065628,
            toggle = "cooldowns",

            startsCombat = true,

            handler = function ()
                summonPet( "demonic_tyrant", 15 )
                summon_demon( "demonic_tyrant", 15 )
                applyBuff( "demonic_power", 15 )
                if talent.demonic_consumption.enabled then
                    consume_demons( "wild_imps", "all" )
                end
                if azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
                extend_demons()
            end,
        },


        summon_felguard = {
            id = 30146,
            cast = function () return 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = false,
            essential = true,

            bind = "summon_pet",

            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( 'felguard', 3600 )
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

            toggle = "cooldowns",

            startsCombat = true,

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

    spec:RegisterPack( "Demonology", 20190722, [[dKKR7bqiLswKqsPhPujUKqIK2KsYNusrKrPe5ukrTkLuIxPemlLuDlHe2Li)su0WuQ4yQOwgIYZesnnLk11ukABkvsFtirnoHeX5usPwNskkZtf5EQW(qKoOskIAHkL6HkPinrLusxuiPGtkKiXkruntHKcTtLc)uirkdviPONsWuffUQskcFvirQ2RG)QQbJYHvSyH6XqnzixM0Mj0NfIrRsDAPwTqs1RvcnBuDBI2nv)MYWfvhxjfvlh0ZrA6sUocBhr8DrPXRKcNxPQ1lKK5Rs2pWHZHmccOP0WgKTZ51ENOmzKL2zNDF(CqO2NRbH8bV4erdc(i1GWAvLMBClY(Gq(SNBdkKrqGAeqSgeURkNUMLzMr66MioHnzM0wsWNQnhdhXktAlXzgeIjAEfLIhIdcOP0WgKTZ51ENOmzKL2zNDFEN1oiqZvCydY21DniC3iK6H4GasP4GWUayRvvAUXTi7bSO0hi3WlciFxaS7QYPRzzMzKUUjItytMjTLe8PAZXWrSYK2sCMaY3faJCc(EaJSZRdyKTZ51gWIcaJSDwZIEha5aY3faBn9E8ikDndq(UayrbGjKRCoGf1OHxmbiFxaSOaWwtqvalMqum5ADRWp3G1Wte5aw70sheGzIaguLt7ThbWwtxRaw1sfWeniGTHw3keWIAAWA4a2GRMefWYVhQMaKVlawuayrP589aguXMuQocWwRQ08yJxawouJcSjJNcWAraRlaRPaw70A8cWwYGa29ar4HwaMObbSyJsv6Yja57cGffawutlRcbmHo)2CaB4ClRIaSCOgfytgpfGvgGLdnmG1oTgVaS1Qknp24vcq(UayrbGTMGQawuB1s9l7rTg1cylPRrUIlfbyQJncVuiGPoAzado1TcbS6ECalQTgyeTsvl1VSh1AulGTKUg5kUueGHjGq1laRgyeTwtIcyiDQ7LbSYaSHeRraMUgyLsBsualMa6ThbWmrado4E4a2A6ALMcc5qtS5AqyxaS1Qkn34wK9awu6dKB4fbKVla2Dv501SmZmsx3eXjSjZK2sc(uT5y4iwzsBjota57cGrobFpGr251bmY258AdyrbGr2oRzrVdGCa57cGTMEpEeLUMbiFxaSOaWeYvohWIA0WlMaKVlawuayRjOkGftikMCTUv4NBWA4jICaRDAPdcWmradQYP92JayRPRvaRAPcyIgeW2qRBfcyrnnynCaBWvtIcy53dvtaY3falkaSO0C(EadQytkvhbyRvvAESXlalhQrb2KXtbyTiG1fG1uaRDAnEbylzqa7EGi8qlat0GawSrPkD5eG8DbWIcalQPLvHaMqNFBoGnCULvrawouJcSjJNcWkdWYHggWANwJxa2AvLMhB8kbiFxaSOaWwtqvalQTAP(L9OwJAbSL01ixXLIam1XgHxkeWuhTmGbN6wHawDpoGf1wdmIwPQL6x2JAnQfWwsxJCfxkcWWeqO6fGvdmIwRjrbmKo19Yawza2qI1iatxdSsPnjkGfta92JayMiGbhCpCaBnDTstaYbKVlawudRHIjkfbyXQObvadBY4PaSyns70eGTMmgR5ffWCZJI7bkfj4a2GR2CkGzoFFcq(UaydUAZPPCOInz8uhI8HUiG8DbWgC1Mtt5qfBY4Pw4itrZqaY3faBWvBonLdvSjJNAHJmhIis1RPAZbKp4QnNMYHk2KXtTWrMucP08pxla57cGn4QnNMYHk2KXtTWrMT7k8rQ0C66T4rnC1Ru7UcFKknNMuFI5kcq(UaydUAZPPCOInz8ulCKj1NC6TvpTMIciFWvBonLdvSjJNAHJmZTSk8PD(T5R3IhXeIIPSnh9TmNMO1GxK0ZRIjeftivAEJFSb1eTg8INoidq(GR2CAkhQytgp1chzMBvBoG8bxT50uouXMmEQfoYePsZJnETElEeBu611GR28esLMhB8kHhADSdG8bxT50uouXMmEQfoYKEpil7hB8cqoG8DbWIAynumrPiatjrH7bSQLkGv3kGn4YGawtbSHKP5tmxtaYhC1MtpO5kN)CdViG8bxT50foYm3Q281BXJCTsivAEJ)ApC8kn4QjrxT0wkLQowtK00283e)CfkQ4QnpjNOUbVU2QgU6vcPsZB8JnNsiZR28K6tmxrxxyZ4ilRNOesP5psLM34V2dhVsqvoTtj9aBghzz9eLqkn)rQ08g)1E44vcraNQnpk2C5vlTvnC1RKR1Tc)CdwdpP(eZv01vmHOyY16wHFUbRHNiYx(6QAP(L9Owpf9oaYhC1Mtx4itcQ(DPY19rQhturVh4qFrZR3e)ClRcxVfpWMXrwwprjKsZFKknVXFThoELGQCANE6GSDwTvnC1RKR1Tc)CdwdpP(eZveG8bxT50foYKGQFxQKUElEKRvcPsZB8x7HJxPbxnj6QL2sPu1XAIKM2M)M4NRqrfxT5j5e1n411w1WvVsivAEJFS5uczE1MNuFI5k66cBghzz9eLqkn)rQ08g)1E44vcQYPDkPhyZ4ilRNOesP5psLM34V2dhVsic4uT5rXMlFDvTu)YEuRNooVjG8bxT50foYmwHufUy7rwVfpY1kHuP5n(R9WXR0GRMeD1sBPuQ6ynrstBZFt8ZvOOIR28KCI6g86ARA4QxjKknVXp2CkHmVAZtQpXCfDDHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0dSzCKL1tucP08hPsZB8x7HJxjebCQ28OyZLVUQwQFzpQ1thN3eq(GR2C6chzgZnd9IeW9R3Ih5ALqQ08g)1E44vAWvtIUAPTukvDSMiPPT5Vj(5kuuXvBEsorDdEDTvnC1ResLM34hBoLqMxT5j1NyUIUUWMXrwwprjKsZFKknVXFThoELGQCANs6b2moYY6jkHuA(JuP5n(R9WXReIaovBEuS5Yxxvl1VSh16PJZBciFWvBoDHJmfBOgZndTElEKRvcPsZB8x7HJxPbxnj6QL2sPu1XAIKM2M)M4NRqrfxT5j5e1n411w1WvVsivAEJFS5uczE1MNuFI5k66cBghzz9eLqkn)rQ08g)1E44vcQYPDkPhyZ4ilRNOesP5psLM34V2dhVsic4uT5rXMlFDvTu)YEuRNooVjG8bxT50foYmMBg6nXVU1xDvUF9w8ixResLM34V2dhVsdUAs0v5ALqQ08g)1E44vcQYPD6PJZBgfrWO1s0RwAlLsvhRjsAAB(BIFUcfvC1MNKtu3GxxBvdx9kHuP5n(XMtjK5vBEs9jMRORlSzCKL1tucP08hPsZB8x7HJxjOkN2PKEGnJJSSEIsiLM)ivAEJ)ApC8kHiGt1MhfBUmG8bxT50foYmRb5is02FOsnFCSUElEetikM4TOgZndLO1Gx8u0RwkxResLM34V2dhVsdUAs0vlTLsPQJ1ejnTn)nXpxHIkUAZtYjQBWRRTQHRELqQ08g)yZPeY8QnpP(eZv01f2moYY6jkHuA(JuP5n(R9WXReuLt7uspWMXrwwprjKsZFKknVXFThoELqeWPAZJInx(6QAP(L9OwpDCEZLbKp4QnNUWrMWopNRF7pnFW66T4rUwjKknVXFThoELgC1KORwAlLsvhRjsAAB(BIFUcfvC1MNKtu3GxxBvdx9kHuP5n(XMtjK5vBEs9jMRORlSzCKL1tucP08hPsZB8x7HJxjOkN2PKEGnJJSSEIsiLM)ivAEJ)ApC8kHiGt1MhfBU81v1s9l7rTE648MaYhC1Mtx4itcQ(DPY19rQh5gErTODuPOhBYCIAQ28hPK0yD9w8aBghzz9eLqkn)rQ08g)1E44vcQYPDkPhKTZkSzCKL1tucP08hPsZB8x7HJxjOkN2PNoWMXrwwprjKsZFKknVXFThoELqeWPAZJIZBEDvTu)YEuRNoIEha5dUAZPlCKjbv)Uu56(i1dOvyibTu0tIziZEKX5R3IhlHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0dY286QAP(L9OwpDe9oldiFWvBoDHJmjO63Lkx3hPEqVBsu4tI6M8HkVXR3IhlHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0dY286QAP(L9OwpDe9oldiFWvBoDHJmjO63Lkx3hPEmR5eDUvQxVpevZjOR3IhlHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0dY286QAP(L9OwpDe9oldiFWvBoDHJmjO63Lkx3hPEunsPLbLp2q6ASElESe2moYY6jkHuA(JuP5n(R9WXReuLt7uspiBZRRQL6x2JA90r07SmG8bxT50foYKGQFxQCDFK6bj9WFt8PLbL01BXJLWMXrwwprjKsZFKknVXFThoELGQCANs6bzBEDvTu)YEuRNoIENLbKp4QnNUWrM4HZ)bxT5pVP16(i1dlxDfUElESvnC1RKR1Tc)CdwdpP(eZv0QQL6PO3z1wyZ4ilRNOesP5psLM34V2dhVsqvoTtbKp4QnNUWrMeu97sLR7JupMOIEpWH(IMxVj(5wwfUElESu1sL0O356ARA4QxjxRBf(5gSgEs9jMROLxvdx9kfb2sRH6lQ8iedeLuFI5kA1svl1VSh1kPNjBNRRQL6x2JA9e2moYY6jkHuA(JuP5n(R9WXReuLt70foV5Yxxvl1VSh16PJO3eq(GR2C6chzEpo6nXpcbhn(6T4XevkSlnPRro3Onj6NBL6vp8eC8fxvTupT5kQrWF69arKs2QycrXKUg5CJ2KOFUvQx9WtilRVkMqumLT5OVL50eTg8INIE1w5qLKpcgLoNUhh9M4hHGJgF1QTYHkjFemkrw6EC0BIFecoACa5dUAZPlCKjsLMhB8A9w8GAe8NEpq0PJOxftikMqQ08g)ydQjI8vXeIIjKknVXp2GAIwdEXJDdiFWvBoDHJmBzo3OT5R3IhtuPWU0KUg5CJ2KOFUvQx9WtWXxCvmHOykBZrFlZPjAn4fjLSvXeIIjDnY5gTjr)CRuV6HNGQCANEAWvBEIEpil7hB8kPRHIjk9RwQRwARA4QxjKknVXp2CkHmVAZtQpXCfDDHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0ZKTmG8bxT50foYezMC9w8yRQXl2EKvvl1VSh1kPrVZkAUY5FnWiArtTmNB028tKTARycrXKR1Tc)Cdwdpbv50ofq(GR2C6chzg3CLIncye9JnzScPR3IhtuPWU0KUg5CJ2KOFUvQx9WtWXxK0DwvTupDENv0CLZ)AGr0IMAzo3OT5NiBvmHOycb1brRHVOcPjOkN2PRQHRELCTUv4NBWA4j1NyUIaKp4QnNUWrMivAEJFAbvpsDVElESumHOykBZrFlZPjAn4fpTRxxXeIIjKknVXFULvHjI8LVUO5kN)1aJOfn1YCUrBZprgG8bxT50foYepC(p4Qn)5nTw3hPE4ADRWp3G1WxVfpQHRELCTUv4NBWA4j1NyUIwrZvo)RbgrlAQL5CJ2MF6Gma5dUAZPlCKjE48FWvB(ZBATUps9OL5CJ2MVElEqZvo)RbgrlAQL5CJ2Mt6za5dUAZPlCKzeIbI6XFt8NOsHwDVElEGnJJSSEIsiLM)ivAEJ)ApC8kbv50o90X5nVUQwQFzpQ1thrVdG8bxT50foYmcSLwd1xu5rigiA9w8yPQL6x2JAL0ZKTZ1v1s9l7rTEcBghzz9eLqkn)rQ08g)1E44vcQYPD6cN386cBghzz9eLqkn)rQ08g)1E44vcQYPD6PZrVmG8bxT50foYKsiLM)K0CvSvhTElEGnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0DVZ1f2moYY6jkHuA(JuP5n(R9WXReuLt70tNjdq(GR2C6chzIho)rqDq0A4lQq66T4XsyZ4ilRNOesP5psLM34V2dhVsqvoTtpT2RIjeftivAEJF8W5Thjbv50oD5RRLWMXrwwprjKsZFKknVXFThoELGQCANE685vBftikMqQ08g)4HZBpscQYPD6YxxyZ4ilRNOesP5psLM34V2dhVsqvoTtj98UbKp4QnNUWrM1T(eESr4Ox0GyD9w8iMqumbv8ICLsFrdI1euhCbiFWvBoDHJmJBUsXgbmI(XMmwHua5dUAZPlCK594O3e)ieC04R3IhlnrLc7stXdxfj4F7Ky4PAZtQpXCfDDvdx9kHuP5n(XMtjK5vBEs9jMROLxLdvs(iyu6C6EC0BIFecoA8vyZ4ilRNOesP5psLM34V2dhVsqvoTtprgG8DbWiBND2jkvAUY5)9qlfWAkGrVnyDpocWeniGv3kGHhAbyvlvaZebS1QknVXawg7HJxjalJBfWAVuVaSMcyLbyMZ3dyXAK2bm8qR2JayTiGnagwH10oG5eYyfcyMiG1YCkGLT5CalwbmJOaS49awDRaM6iaZebS6wbm8qReG8bxT50foYKsiLM)ivAEJ)ApC8A9w8GAe8NEpq0POxT0w1WvVsivAEJFS5uczE1MNuFI5k66kMqumLT5OVL50eTg8Il0YC6tZNSUIEebS9ijkHuA(JuP5n(R9WXlsp21vvl1VSVL500W5jOkN2PNWdT(QL6Yxxvl1VSh16jY2bq(GR2C6chzMBzv4t78BZxVfpIjeftzBo6BzonrRbViPhKTkMqumHuP5n(Xgut0AWlE6GSvXeIIjKknVXFULvHjKL1xrZvo)RbgrlAQL5CJ2MFIma5dUAZPlCKjYm56T4rnC1ReYmzs9jMROvqveQ07jMRRQwQFzpQvsxczvczMmbv50oDHO3zza5dUAZPlCK594O3e)ieC04R3IhuJG)07bIi9yZRRLOgb)P3der6r0RWMXrwwpHho)rqDq0A4lQqAcQYPDkP7E1syZ4ilRNOesP5psLM34V2dhVsqvoTtjLSDUUwcBghzz9eLqkn)rQ08g)1E44vcQYPD6Piy0AHSv1WvVsivAEJFS5uczE1MNuFI5k66cBghzz9eLqkn)rQ08g)1E44vcQYPD6Piy0Az3R2QgU6vcPsZB8JnNsiZR28K6tmxrlV8QL2QgU6vIsiLM)K0CvSvhLuFI5k66cBghzz9eLqkn)jP5QyRokbv50oL0OxEza5dUAZPlCKj1i4pTG9I66T4b1i4p9EGOtBUkMqumHuP5n(Xgut0AWlE6Gma5dUAZPlCKjsLMhB8A9w8GAe8NEpq0PJOxftikMqQ08g)ydQjI8vlTe2moYY6jkHuA(JuP5n(R9WXReuLt70t761f2moYY6jkHuA(JuP5n(R9WXReuLt7usjJSvBnrLc7st07bzzPFCxAs9jMROLVUIjeftivAEJFSb1eTg8IKEe91vmHOycPsZB8JnOMGQCANEAZRRQL6x2JA9ezBEDftikMO3dYYs)4U0euLt70LbKp4QnNUWrMIgMGQOFIkf2L(X6ixVfp2kxResLM34V2dhVsdUAsua5dUAZPlCKzobSf33EKpMp0cq(GR2C6chzgZnd9M4x36RUk3diFWvBoDHJmXMJvVGtPOxKpsD9w8ylKvjS5y1l4uk6f5Ju)ycONGQCANUARbxT5jS5y1l4uk6f5JutT)I8oYDTARCTsivAEJ)ApC8kn4QjrbKp4QnNUWrM4HZ)bxT5pVP16(i1JyIMJ(5P3debihq(GR2CAkMO5OFE69arhsvAW9Vj(CcCJEeuhjD9w8GAe8NEpq0jYaKp4QnNMIjAo6NNEpq0chzsnc(tlyVOUElESvnC1ResLM34hBoLqMxT5j1NyUIUUQwQKEEZRRCOsYhbJsNt3JJEt8JqWrJVARycrXum3meNGwjOkN2PaYhC1MttXenh9ZtVhiAHJmP3dYY(XgVaKdiFWvBon1YCUrBZpAzo3OT5R3IhlftikMY2C03YCAIwdErsp21vlrnc(tVhi6u0xx5qLKpcgLoNWdN)iOoiAn8fvi96kMqumLT5OVL50eTg8IKES2xx5qLKpcgLoNIBUsXgbmI(XMmwH0RRL2khQK8rWO05094O3e)ieC04R2khQK8rWOezP7XrVj(ri4OXxE5vBLdvs(iyu6C6EC0BIFecoA8vBLdvs(iyuIS094O3e)ieC04RIjeftivAEJ)ClRctilRV811svl1VSh16POxftikMY2C03YCAIwdErs3z5RRLYHkjFemkrwcpC(JG6GO1WxuH0vXeIIPSnh9TmNMO1GxKuYwTvnC1ResLM34hpCE7rsQpXCfTmG8bxT50ulZ5gTnFHJmJaBP1q9fvEeIbIwVfpWMXrwwprjKsZFKknVXFThoELGQCANE6C0xxBPR5eDEUIsNJMSO311gq(GR2CAQL5CJ2MVWrM4HZFeuheTg(IkKUElESe2moYY6jkHuA(JuP5n(R9WXReuLt70tR9QycrXesLM34hpCE7rsqvoTtx(6AjSzCKL1tucP08hPsZB8x7HJxjOkN2PNoFE1wXeIIjKknVXpE482JKGQCANU81f2moYY6jkHuA(JuP5n(R9WXReuLt7uspVBa5dUAZPPwMZnAB(chzsjKsZFKknVXFThoEbiFWvBon1YCUrBZx4iZ7XrVj(ri4OXxVfpOgb)P3der6XMaYhC1MttTmNB028foY8EC0BIFecoA81BXdQrWF69arKEe9QLwAPCOsYhbJsKLUhh9M4hHGJg)6kMqumLT5OVL50eTg8IKEe9YRIjeftzBo6BzonrRbV4P1E5RlSzCKL1tucP08hPsZB8x7HJxjOkN2PNoIGrRfYUUIjeftivAEJ)ClRctqvoTtjncgTwiBza5dUAZPPwMZnAB(chzIuP5XgVwVfpYHkjFemkDoDpo6nXpcbhn(kQrWF69arKECE1sXeIIPSnh9TmNMO1Gx80r0xx5qLKpcgLIoDpo6nXpcbhn(YROgb)P3deDA3RIjeftivAEJFSb1eroG8bxT50ulZ5gTnFHJmPesP5pjnxfB1rR3IhlHnJJSSEIsiLM)ivAEJ)ApC8kbv50oL0DVZkAUY5FnWiArtTmNB028thKT81f2moYY6jkHuA(JuP5n(R9WXReuLt70tNjdq(GR2CAQL5CJ2MVWrMXnxPyJagr)ytgRq66T4b2moYY6jkHuA(JuP5n(R9WXReuLt7usxBa5dUAZPPwMZnAB(chzkAycQI(jQuyx6hRJeq(GR2CAQL5CJ2MVWrM5eWwCF7r(y(qla5dUAZPPwMZnAB(chzgZnd9M4x36RUk3diFWvBon1YCUrBZx4itS5y1l4uk6f5JuxVfp2czvcBow9coLIEr(i1pMa6jOkN2PR2AWvBEcBow9coLIEr(i1u7ViVJCxRO5kN)1aJOfn1YCUrBZpTjG8bxT50ulZ5gTnFHJmPgb)PfSxuxVfpOgb)P3deDAZvXeIIjKknVXp2GAIwdEXthKbiFWvBon1YCUrBZx4itKknp2416T4b1i4p9EGOthrVkMqumHuP5n(Xgute5RwkMqumHuP5n(Xgut0AWls6r0xxXeIIjKknVXp2GAcQYPD6PJiy0AzZuuEza5dUAZPPwMZnAB(chzImtUoEpMRFnWiArpoVUCwJhVhZ1VgyeTOhr51BXdOkcv69eZva5dUAZPPwMZnAB(chzIho)hC1M)8MwR7JupIjAo6NNEpqeGCa5dUAZPjxRBf(5gSg(bE48FWvB(ZBATUps9W16wHFUbRH)Xenh1EK1BXdSzCKL1tUw3k8Znyn8euLt70tKTdG8bxT50KR1Tc)CdwdFHJmXdN)dUAZFEtR19rQhUw3k8Znyn8FWvtIUElEetikMCTUv4NBWA4jICa5aYhC1MttUw3k8Znyn8FWvtIEe3CLIncye9JnzScPaYhC1MttUw3k8Znyn8FWvtIUWrMrGT0AO(IkpcXarR3IhyZ4ilRNOesP5psLM34V2dhVsqvoTtpDo6RRT01CIopxrPZrtw076AdiFWvBon5ADRWp3G1W)bxnj6chzsjKsZFsAUk2QJwVfpWMXrwwprjKsZFKknVXFThoELGQCANs6U356cBghzz9eLqkn)rQ08g)1E44vcQYPD6PZKbiFWvBon5ADRWp3G1W)bxnj6chzIho)rqDq0A4lQq66T4XsyZ4ilRNOesP5psLM34V2dhVsqvoTtpT2RIjeftivAEJF8W5Thjbv50oD5RRLWMXrwwprjKsZFKknVXFThoELGQCANE685vBftikMqQ08g)4HZBpscQYPD6YxxyZ4ilRNOesP5psLM34V2dhVsqvoTtj98UbKp4QnNMCTUv4NBWA4)GRMeDHJmXdN)dUAZFEtR19rQhXenh9ZtVhiA9w8GAe8NEpq0X5vlHnJJSSEcpC(JG6GO1WxuH0euLt70tdUAZt07bzz)yJxj8qRVAPEDTunC1RuCZvk2iGr0p2KXkKMuFI5kAf2moYY6P4MRuSraJOFSjJvinbv50o90GR28e9Eqw2p24vcp06RwQlVmG8bxT50KR1Tc)Cdwd)hC1KOlCK594O3e)ieC04R3IhlTe2moYY6j8W5pcQdIwdFrfstqvoTtjDWvBEcPsZJnELWdT(QL6YRwcBghzz9eE48hb1brRHVOcPjOkN2PKo4QnprVhKL9JnELWdT(QL6YlVcBghzz9KR1Tc)Cdwdpbv50oL0LoVRBUWGR28094O3e)ieC04j8qRVAPUmG8bxT50KR1Tc)Cdwd)hC1KOlCKjLqkn)rQ08g)1E4416T4rmHOyY16wHFUbRHNGQCANEAZvuJG)07bIo2bq(GR2CAY16wHFUbRH)dUAs0foYKsiLM)ivAEJ)ApC8A9w8iMqum5ADRWp3G1WtqvoTtpn4QnprjKsZFKknVXFThoELWdT(QL6c7K2eq(GR2CAY16wHFUbRH)dUAs0foYePsZJnETElEetikMqQ08g)ydQjI8vuJG)07bIoDenG8bxT50KR1Tc)Cdwd)hC1KOlCKjE48FWvB(ZBATUps9iMO5OFE69araYbKp4QnNMCTUv4NBWA4FmrZrTh5GGQFxQCDFK6Xev07bo0x086nXp3YQW1BXdSzCKL1tUw3k8Znyn8euLt70thBUwO5kN)3dTua5dUAZPjxRBf(5gSg(ht0Cu7rw4iZiede1J)M4prLcT6E9w8ylSzCKL1tUw3k8Znyn8euLt70vuJG)07bIi9yta5dUAZPjxRBf(5gSg(ht0Cu7rw4itxRBf(5gSg(6T4b1i4p9EGisp2eq(GR2CAY16wHFUbRH)Xenh1EKfoYepC(JG6GO1WxuH01BXJQLkPhrVdG8bxT50KR1Tc)Cdwd)JjAoQ9ilCK594O3e)ieC04R3IhvlvspIENvyZ4ilRNWdN)iOoiAn8fvinbv50oL0ZrjROgb)P3der6r0aYhC1MttUw3k8Znyn8pMO5O2JSWrM5wwf(0o)281BXJQLkPhrVZQycrXu2MJ(wMtt0AWls6bzRIjeftivAEJFSb1eTg8INoiBvmHOycPsZB8NBzvyczz9vuJG)07bIi9iAa5dUAZPjxRBf(5gSg(ht0Cu7rw4iZ7XrVj(ri4OXxVfpQwQKEe9oROgb)P3der6XMaYhC1MttUw3k8Znyn8pMO5O2JSWrM4HZ)bxT5pVP16(i1JyIMJ(5P3debihq(GR2CAYYvxHh3JJEt8JqWrJVoVD9XOJO3z9w8yIkf2LM01iNB0Me9ZTs9QhEs9jMRia5dUAZPjlxDfUWrMTmNB0281BXJjQuyxAsxJCUrBs0p3k1RE4j1NyUIwftikMY2C03YCAIwdErsjBvmHOysxJCUrBs0p3k1RE4jKL1bKp4QnNMSC1v4chzImtUoVD9XOJO3bq(GR2CAYYvxHlCKzeIbI6XFt8NOsHwDdiFWvBonz5QRWfoY8EC0BIFecoA81BXJCOsYhbJsNt3JJEt8JqWrJVIAe8NEpqeP7SkhQK8rWOezjQrWFAb7fva5dUAZPjlxDfUWrMivAEJFAbvpsDVElEKdvs(iyu6C6EC0BIFecoA8vBLdvs(iyuIS094O3e)ieC04RwkMqumLT5OVL50eTg8IKEE1GR28094O3e)ieC04P2FrEh5Uwgq(GR2CAYYvxHlCKzCZvk2iGr0p2KXkKciFWvBonz5QRWfoYKAe8NwWErDDE76JrhrVZ6T4XwXeIIPyUziobTsqvoTtVUQwQKU5QCOsYhbJsNt3JJEt8JqWrJdiFWvBonz5QRWfoYKsiLM)K0CvSvhTElEqnc(tVhi6yta5dUAZPjlxDfUWrMrGT0AO(IkpcXarR3IhuJG)07bIo2eq(GR2CAYYvxHlCKjE48hb1brRHVOcPR3IhuJG)07bIo2eq(GR2CAYYvxHlCK594O3e)ieC04R3IhuJG)07bIo2eq(GR2CAYYvxHlCK594O3e)ieC04R3IhuJG)07bIi9i6v5qLKpcgLilDpo6nXpcbhn(QQLkPBUAPCOsYhbJsNtuJG)0c2lQxxBvdx9krnc(tlyVOMuFI5kAvouj5JGrPZj69GSSFSXRLbKVlagz7SZorPsZvo)VhAPawtbm6TbR7XraMObbS6wbm8qlaRAPcyMiGTwvP5ngWYypC8kbyzCRaw7L6fG1uaRmaZC(EalwJ0oGHhA1EeaRfbSbWWkSM2bmNqgRqaZebSwMtbSSnNdyXkGzefGfVhWQBfWuhbyMiGv3kGHhALaKp4QnNMSC1v4chzsjKsZFKknVXFThoETElEKdvs(iyu6CcPsZB8tlO6rQ7RRCOsYhbJsNt3JJEt8JqWrJVkhQK8rWOezP7XrVj(ri4OXVU2QgU6vcPsZB8tlO6rQ7K6tmxrRIjeftzBo6BzonrRbV4cTmN(08jRROhraBpsIsiLM)ivAEJ)ApC8I0JDfq(GR2CAYYvxHlCKjsLMhB8A9w8GAe8NEpq0PJOxftikMqQ08g)ydQjOkN2PaYhC1MttwU6kCHJmXdN)dUAZFEtR19rQhXenh9ZtVhikiqIcPT5HniBNZR9orzY2jDokhDqi7a92JqdcrPiZnyPialkbWgC1Mdy8Mw0eG8GaVPfnKrqWYvxHHmcBCoKrqq9jMROW2bHbxT5bH7XrVj(ri4OXdcyyxkSNGWevkSlnPRro3Onj6NBL6vp8K6tmxrbbE76JrbHO3juHnilKrqq9jMROW2bbmSlf2tqyIkf2LM01iNB0Me9ZTs9QhEs9jMRiaBfGftikMY2C03YCAIwdEraJuaJmaBfGftikM01iNB0Me9ZTs9QhEczz9GWGR28GqlZ5gTnpuHnIoKrqq9jMROW2bHbxT5bbKzYGaVD9XOGq07eQWg7oKrqyWvBEqicXar94Vj(tuPqRUdcQpXCff2ouHn2mKrqq9jMROW2bbmSlf2tqihQK8rWO05094O3e)ieC04a2kaJAe8NEpqeGrkGTdGTcWYHkjFemkrwIAe8NwWErnim4QnpiCpo6nXpcbhnEOcBSRHmccQpXCff2oiGHDPWEcc5qLKpcgLoNUhh9M4hHGJghWwbyBby5qLKpcgLilDpo6nXpcbhnoGTcWwcWIjeftzBo6BzonrRbViGrkGDgWwbydUAZt3JJEt8JqWrJNA)f5DK7cWwoim4QnpiGuP5n(Pfu9i1DOcBeLdzeegC1MheIBUsXgbmI(XMmwH0GG6tmxrHTdvyJOKqgbb1NyUIcBhegC1MheOgb)PfSxudcyyxkSNGWwawmHOykMBgItqReuLt7ua76cWQwQagPa2Ma2kalhQK8rWO05094O3e)ieC04bbE76JrbHO3juHnw7qgbb1NyUIcBheWWUuypbbQrWF69ara2bGTzqyWvBEqGsiLM)K0CvSvhfQWgN3jKrqq9jMROW2bbmSlf2tqGAe8NEpqeGDayBgegC1MheIaBP1q9fvEeIbIcvyJZNdzeeuFI5kkSDqad7sH9eeOgb)P3debyha2MbHbxT5bb8W5pcQdIwdFrfsdvyJZKfYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWoaSndcdUAZdc3JJEt8JqWrJhQWgNJoKrqq9jMROW2bbmSlf2tqGAe8NEpqeGr6bGfnGTcWYHkjFemkrw6EC0BIFecoACaBfGvTubmsbSnbSva2sawouj5JGrPZjQrWFAb7fva76cW2cWQHRELOgb)PfSxutQpXCfbyRaSCOsYhbJsNt07bzz)yJxa2YbHbxT5bH7XrVj(ri4OXdvyJZ7oKrqq9jMROW2bbmSlf2tqihQK8rWO05esLM34Nwq1Ju3a21fGLdvs(iyu6C6EC0BIFecoACaBfGLdvs(iyuIS094O3e)ieC04a21fGTfGvdx9kHuP5n(Pfu9i1Ds9jMRiaBfGftikMY2C03YCAIwdEraBbaRL50NMpzDf9icy7rsucP08hPsZB8x7HJxagPha2UgegC1MheOesP5psLM34V2dhVcvyJZBgYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWoDayrdyRaSycrXesLM34hBqnbv50onim4QnpiGuP5XgVcvyJZ7AiJGG6tmxrHTdcdUAZdc4HZ)bxT5pVPvqG3069rQbHyIMJ(5P3defQqfeCTUv4NBWA4)GRMenKryJZHmccdUAZdcXnxPyJagr)ytgRqAqq9jMROW2HkSbzHmccQpXCff2oiGHDPWEccyZ4ilRNOesP5psLM34V2dhVsqvoTtbSta25ObSRlaBlatxZj68CfLY2CrOIOpTJ083eFkrUcBd(ucP082JeegC1MheIaBP1q9fvEeIbIcvyJOdzeeuFI5kkSDqad7sH9eeWMXrwwprjKsZFKknVXFThoELGQCANcyKcy7Eha76cWWMXrwwprjKsZFKknVXFThoELGQCANcyNaSZKfegC1MheOesP5pjnxfB1rHkSXUdzeeuFI5kkSDqad7sH9eewcWWMXrwwprjKsZFKknVXFThoELGQCANcyNaS1gWwbyXeIIjKknVXpE482JKGQCANcyldyxxa2sag2moYY6jkHuA(JuP5n(R9WXReuLt7ua7eGD(mGTcW2cWIjeftivAEJF8W5Thjbv50ofWwgWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPa25DhegC1MheWdN)iOoiAn8fvinuHn2mKrqq9jMROW2bbmSlf2tqGAe8NEpqeGDayNbSva2sag2moYY6j8W5pcQdIwdFrfstqvoTtbSta2GR28e9Eqw2p24vcp06RwQa21fGTeGvdx9kf3CLIncye9JnzScPj1NyUIaSvag2moYY6P4MRuSraJOFSjJvinbv50ofWobydUAZt07bzz)yJxj8qRVAPcyldylhegC1MheWdN)dUAZFEtRGaVP17JudcXenh9ZtVhikuHn21qgbb1NyUIcBheWWUuypbHLaSLamSzCKL1t4HZFeuheTg(IkKMGQCANcyKcydUAZtivAESXReEO1xTubSLbSva2sag2moYY6j8W5pcQdIwdFrfstqvoTtbmsbSbxT5j69GSSFSXReEO1xTubSLbSLbSvag2moYY6jxRBf(5gSgEcQYPDkGrkGTeGDEx3eWwaWgC1MNUhh9M4hHGJgpHhA9vlvaB5GWGR28GW94O3e)ieC04HkSruoKrqq9jMROW2bbmSlf2tqiMqum5ADRWp3G1WtqvoTtbSta2Ma2kaJAe8NEpqeGDay7eegC1MheOesP5psLM34V2dhVcvyJOKqgbb1NyUIcBheWWUuypbHycrXKR1Tc)Cdwdpbv50ofWobydUAZtucP08hPsZB8x7HJxj8qRVAPcylay7K2mim4QnpiqjKsZFKknVXFThoEfQWgRDiJGG6tmxrHTdcyyxkSNGqmHOycPsZB8JnOMiYbSvag1i4p9EGia70bGfDqyWvBEqaPsZJnEfQWgN3jKrqq9jMROW2bHbxT5bb8W5)GR28N30kiWBA9(i1GqmrZr)807bIcvOccivCi4viJWgNdzeegC1MheO5kN)CdVyqq9jMROW2HkSbzHmccQpXCff2oiGHDPWEcc5ALqQ08g)1E44vAWvtIcyRaSLaSTamLsvhRjsAAB(BIFUcfvC1MNKtu3Ga21fGTfGvdx9kHuP5n(XMtjK5vBEs9jMRia76cWWMXrwwprjKsZFKknVXFThoELGQCANcyKEayyZ4ilRNOesP5psLM34V2dhVsic4uT5awuayBcyldyRaSLaSTaSA4QxjxRBf(5gSgEs9jMRia76cWIjeftUw3k8Znyn8eroGTmGDDbyvl1VSh1kGDcWIENGWGR28GqUvT5HkSr0HmccQpXCff2oim4Qnpimrf9EGd9fnVEt8ZTSkmiGHDPWEccyZ4ilRNOesP5psLM34V2dhVsqvoTtbSthagz7ayRaSTaSA4QxjxRBf(5gSgEs9jMROGGpsnimrf9EGd9fnVEt8ZTSkmuHn2DiJGG6tmxrHTdcyyxkSNGqUwjKknVXFThoELgC1KOa2kaBjaBlatPu1XAIKM2M)M4NRqrfxT5j5e1niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPhag2moYY6jkHuA(JuP5n(R9WXReIaovBoGffa2Ma2Ya21fGvTu)YEuRa2Pda78MbHbxT5bbcQ(DPsAOcBSziJGG6tmxrHTdcyyxkSNGqUwjKknVXFThoELgC1KOa2kaBjaBlatPu1XAIKM2M)M4NRqrfxT5j5e1niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPhag2moYY6jkHuA(JuP5n(R9WXReIaovBoGffa2Ma2Ya21fGvTu)YEuRa2Pda78MbHbxT5bHyfsv4IThjuHn21qgbb1NyUIcBheWWUuypbHCTsivAEJ)ApC8kn4QjrbSva2sa2waMsPQJ1ejnTn)nXpxHIkUAZtYjQBqa76cW2cWQHRELqQ08g)yZPeY8QnpP(eZveGDDbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbmspamSzCKL1tucP08hPsZB8x7HJxjebCQ2CalkaSnbSLbSRlaRAP(L9OwbStha25ndcdUAZdcXCZqVibCFOcBeLdzeeuFI5kkSDqad7sH9eeY1kHuP5n(R9WXR0GRMefWwbylbyBbykLQowtK00283e)CfkQ4QnpjNOUbbSRlaBlaRgU6vcPsZB8JnNsiZR28K6tmxra21fGHnJJSSEIsiLM)ivAEJ)ApC8kbv50ofWi9aWWMXrwwprjKsZFKknVXFThoELqeWPAZbSOaW2eWwgWUUaSQL6x2JAfWoDayN3mim4Qnpii2qnMBgkuHnIsczeeuFI5kkSDqad7sH9eeY1kHuP5n(R9WXR0GRMefWwby5ALqQ08g)1E44vcQYPDkGD6aWoVjGffawemcWwlaw0a2kaBjaBlatPu1XAIKM2M)M4NRqrfxT5j5e1niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPhag2moYY6jkHuA(JuP5n(R9WXReIaovBoGffa2Ma2YbHbxT5bHyUzO3e)6wF1v5(qf2yTdzeeuFI5kkSDqad7sH9eeIjeft8wuJ5MHs0AWlcyNaSObSva2sawUwjKknVXFThoELgC1KOa2kaBjaBlatPu1XAIKM2M)M4NRqrfxT5j5e1niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPhag2moYY6jkHuA(JuP5n(R9WXReIaovBoGffa2Ma2Ya21fGvTu)YEuRa2Pda78Ma2YbHbxT5bHSgKJirB)Hk18XXAOcBCENqgbb1NyUIcBheWWUuypbHCTsivAEJ)ApC8kn4QjrbSva2sa2waMsPQJ1ejnTn)nXpxHIkUAZtYjQBqa76cW2cWQHRELqQ08g)yZPeY8QnpP(eZveGDDbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbmspamSzCKL1tucP08hPsZB8x7HJxjebCQ2CalkaSnbSLbSRlaRAP(L9OwbStha25ndcdUAZdcWopNRF7pnFWAOcBC(CiJGG6tmxrHTdcdUAZdc5gErTODuPOhBYCIAQ28hPK0yniGHDPWEccyZ4ilRNOesP5psLM34V2dhVsqvoTtbmspamY2bWwbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbSthag2moYY6jkHuA(JuP5n(R9WXReIaovBoGffa25nbSRlaRAP(L9OwbSthaw07ee8rQbHCdVOw0oQu0JnzornvB(JusASgQWgNjlKrqq9jMROW2bHbxT5bbOvyibTu0tIziZEKX5bbmSlf2tqyjadBghzz9eLqkn)rQ08g)1E44vcQYPDkGr6bGr2Ma21fGvTu)YEuRa2Pdal6DaSLdc(i1Ga0kmKGwk6jXmKzpY48qf24C0HmccQpXCff2oim4QnpiqVBsu4tI6M8HkVXbbmSlf2tqyjadBghzz9eLqkn)rQ08g)1E44vcQYPDkGr6bGr2Ma21fGvTu)YEuRa2Pdal6DaSLdc(i1Ga9UjrHpjQBYhQ8ghQWgN3DiJGG6tmxrHTdcdUAZdcZAorNBL617dr1CcAqad7sH9eewcWWMXrwwprjKsZFKknVXFThoELGQCANcyKEayKTjGDDbyvl1VSh1kGD6aWIEhaB5GGpsnimR5eDUvQxVpevZjOHkSX5ndzeeuFI5kkSDqyWvBEqOAKsldkFSH01iiGHDPWEcclbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbmspamY2eWUUaSQL6x2JAfWoDayrVdGTCqWhPgeQgP0YGYhBiDncvyJZ7AiJGG6tmxrHTdcdUAZdcK0d)nXNwgusdcyyxkSNGWsag2moYY6jkHuA(JuP5n(R9WXReuLt7uaJ0daJSnbSRlaRAP(L9OwbSthaw07aylhe8rQbbs6H)M4tldkPHkSX5OCiJGG6tmxrHTdcyyxkSNGWwawnC1RKR1Tc)CdwdpP(eZveGTcWQwQa2jal6DaSva2wag2moYY6jkHuA(JuP5n(R9WXReuLt70GWGR28GaE48FWvB(ZBAfe4nTEFKAqWYvxHHkSX5OKqgbb1NyUIcBhegC1MheMOIEpWH(IMxVj(5wwfgeWWUuypbHLaSQLkGrkGf9oa21fGTfGvdx9k5ADRWp3G1WtQpXCfbyldyRaSA4QxPiWwAnuFrLhHyGOK6tmxra2kaBjaRAP(L9OwbmsbSZKTdGDDbyvl1VSh1kGDcWWMXrwwprjKsZFKknVXFThoELGQCANcylayN3eWwgWUUaSQL6x2JAfWoDayrVzqWhPgeMOIEpWH(IMxVj(5wwfgQWgNx7qgbb1NyUIcBheWWUuypbHjQuyxAsxJCUrBs0p3k1RE4j44lcyRaSQLkGDcW2eWwbyuJG)07bIamsbmYaSvawmHOysxJCUrBs0p3k1RE4jKL1bSvawmHOykBZrFlZPjAn4fbStaw0a2kaBlalhQK8rWO05094O3e)ieC04a2kaBfGTfGLdvs(iyuIS094O3e)ieC04bHbxT5bH7XrVj(ri4OXdvydY2jKrqq9jMROW2bbmSlf2tqGAe8NEpqeGD6aWIgWwbyXeIIjKknVXp2GAIihWwbyXeIIjKknVXp2GAIwdEra7aW2DqyWvBEqaPsZJnEfQWgKDoKrqq9jMROW2bbmSlf2tqyIkf2LM01iNB0Me9ZTs9QhEco(Ia2kalMqumLT5OVL50eTg8IagPagza2kalMqumPRro3Onj6NBL6vp8euLt7ua7eGn4QnprVhKL9JnEL01qXeL(vlvaBfGTeGTfGvdx9kHuP5n(XMtjK5vBEs9jMRia76cWWMXrwwprjKsZFKknVXFThoELGQCANcyKcyNjdWwoim4Qnpi0YCUrBZdvydYilKrqq9jMROW2bbmSlf2tqylaRA8IThbWwbyvl1VSh1kGrkGf9oa2kaJMRC(xdmIw0ulZ5gTnhWobyKbyRaSTaSycrXKR1Tc)Cdwdpbv50onim4QnpiGmtgQWgKfDiJGG6tmxrHTdcyyxkSNGWevkSlnPRro3Onj6NBL6vp8eC8fbmsbSDaSvaw1sfWobyN3bWwby0CLZ)AGr0IMAzo3OT5a2jaJmaBfGftikMqqDq0A4lQqAcQYPDkGTcWQHRELCTUv4NBWA4j1NyUIccdUAZdcXnxPyJagr)ytgRqAOcBq2UdzeeuFI5kkSDqad7sH9eewcWIjeftzBo6BzonrRbViGDcW2va76cWIjeftivAEJ)ClRcte5a2Ya21fGrZvo)RbgrlAQL5CJ2MdyNamYccdUAZdcivAEJFAbvpsDhQWgKTziJGG6tmxrHTdcyyxkSNGqnC1RKR1Tc)CdwdpP(eZveGTcWO5kN)1aJOfn1YCUrBZbSthagzbHbxT5bb8W5)GR28N30kiWBA9(i1GGR1Tc)CdwdpuHniBxdzeeuFI5kkSDqad7sH9eeO5kN)1aJOfn1YCUrBZbmsbSZbHbxT5bb8W5)GR28N30kiWBA9(i1GqlZ5gTnpuHnilkhYiiO(eZvuy7Gag2Lc7jiGnJJSSEIsiLM)ivAEJ)ApC8kbv50ofWoDayN3eWUUaSQL6x2JAfWoDayrVtqyWvBEqicXar94Vj(tuPqRUdvydYIsczeeuFI5kkSDqad7sH9eewcWQwQFzpQvaJua7mz7ayxxaw1s9l7rTcyNamSzCKL1tucP08hPsZB8x7HJxjOkN2Pa2ca25nbSRladBghzz9eLqkn)rQ08g)1E44vcQYPDkGDcWohnGTCqyWvBEqicSLwd1xu5rigikuHniBTdzeeuFI5kkSDqad7sH9eeWMXrwwprjKsZFKknVXFThoELGQCANcyKcy7Eha76cWWMXrwwprjKsZFKknVXFThoELGQCANcyNaSZKfegC1MheOesP5pjnxfB1rHkSr07eYiiO(eZvuy7Gag2Lc7jiSeGHnJJSSEIsiLM)ivAEJ)ApC8kbv50ofWobyRnGTcWIjeftivAEJF8W5Thjbv50ofWwgWUUaSLamSzCKL1tucP08hPsZB8x7HJxjOkN2Pa2ja78zaBfGTfGftikMqQ08g)4HZBpscQYPDkGTmGDDbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbmsbSZ7oim4QnpiGho)rqDq0A4lQqAOcBe95qgbb1NyUIcBheWWUuypbHycrXeuXlYvk9fniwtqDWvqyWvBEqOU1NWJnch9IgeRHkSr0KfYiim4Qnpie3CLIncye9JnzScPbb1NyUIcBhQWgrhDiJGG6tmxrHTdcyyxkSNGWsa2evkSlnfpCvKG)TtIHNQnpP(eZveGDDby1WvVsivAEJFS5uczE1MNuFI5kcWwgWwby5qLKpcgLoNUhh9M4hHGJghWwbyyZ4ilRNOesP5psLM34V2dhVsqvoTtbStagzbHbxT5bH7XrVj(ri4OXdvyJO3DiJGG6tmxrHTdcyyxkSNGa1i4p9EGia7eGfnGTcWwcW2cWQHRELqQ08g)yZPeY8QnpP(eZveGDDbyXeIIPSnh9TmNMO1GxeWwaWAzo9P5twxrpIa2EKeLqkn)rQ08g)1E44fGr6bGTRa2kaRAP(L9TmNMgopbv50ofWoby4HwF1sfWwgWUUaSQL6x2JAfWobyKTtqyWvBEqGsiLM)ivAEJ)ApC8kuHnIEZqgbb1NyUIcBheWWUuypbHycrXu2MJ(wMtt0AWlcyKEayKbyRaSycrXesLM34hBqnrRbViGD6aWidWwbyXeIIjKknVXFULvHjKL1bSvagnx58VgyeTOPwMZnABoGDcWilim4QnpiKBzv4t78BZdvyJO31qgbb1NyUIcBheWWUuypbHA4QxjKzYK6tmxra2kadQIqLEpXCfWwbyvl1VSh1kGrkGTeGHSkHmtMGQCANcylayrVdGTCqyWvBEqazMmuHnIokhYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWi9aW2eWUUaSLamQrWF69aragPhaw0a2kadBghzz9eE48hb1brRHVOcPjOkN2PagPa2UbSva2sag2moYY6jkHuA(JuP5n(R9WXReuLt7uaJuaJSDaSRlaBjadBghzz9eLqkn)rQ08g)1E44vcQYPDkGDcWIGra2AbWidWwby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2Pa2jalcgbyRfaB3a2kaBlaRgU6vcPsZB8JnNsiZR28K6tmxra2Ya2Ya2kaBjaBlaRgU6vIsiLM)K0CvSvhLuFI5kcWUUamSzCKL1tucP08NKMRIT6OeuLt7uaJualAaBzaB5GWGR28GW94O3e)ieC04HkSr0rjHmccQpXCff2oiGHDPWEccuJG)07bIaSta2Ma2kalMqumHuP5n(Xgut0AWlcyNoamYccdUAZdcuJG)0c2lQHkSr0RDiJGG6tmxrHTdcyyxkSNGa1i4p9EGia70bGfnGTcWIjeftivAEJFSb1eroGTcWwcWwcWWMXrwwprjKsZFKknVXFThoELGQCANcyNaSDfWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPagzKbyRaSTaSjQuyxAIEpill9J7stQpXCfbyldyxxawmHOycPsZB8JnOMO1GxeWi9aWIgWUUaSycrXesLM34hBqnbv50ofWobyBcyxxaw1s9l7rTcyNamY2eWUUaSycrXe9Eqww6h3LMGQCANcylhegC1MheqQ08yJxHkSXU3jKrqq9jMROW2bbmSlf2tqylalxResLM34V2dhVsdUAs0GWGR28GGOHjOk6NOsHDPFSoYqf2y3NdzeegC1MheYjGT4(2J8X8Hwbb1NyUIcBhQWg7MSqgbHbxT5bHyUzO3e)6wF1v5(GG6tmxrHTdvyJDhDiJGG6tmxrHTdcyyxkSNGWwagYQe2CS6fCkf9I8rQFmb0tqvoTtbSva2wa2GR28e2CS6fCkf9I8rQP2FrEh5UaSva2wawUwjKknVXFThoELgC1KObHbxT5bbS5y1l4uk6f5JudvyJDV7qgbb1NyUIcBhegC1MheWdN)dUAZFEtRGaVP17JudcXenh9ZtVhikuHkiKdvSjJNkKryJZHmccdUAZdcucP08xu5rigikiO(eZvuy7qf2GSqgbb1NyUIcBheWWUuypbHycrXu2MJ(wMtt0AWlcyKcyNbSvawmHOycPsZB8JnOMO1GxeWoDayKfegC1MheYTSk8PD(T5HkSr0HmccdUAZdc5w1MheuFI5kkSDOcBS7qgbb1NyUIcBheWWUuypbHyJsbSRlaBWvBEcPsZJnELWdTaSdaBNGWGR28GasLMhB8kuHn2mKrqyWvBEqGEpil7hB8kiO(eZvuy7qfQGqlZ5gTnpKryJZHmccQpXCff2oiGHDPWEcclbyXeIIPSnh9TmNMO1GxeWi9aW2vaBfGTeGrnc(tVhicWobyrdyxxawouj5JGrPZj8W5pcQdIwdFrfsbSRlalMqumLT5OVL50eTg8IagPha2Adyxxawouj5JGrPZP4MRuSraJOFSjJvifWUUaSLaSTaSCOsYhbJsNt3JJEt8JqWrJdyRaSTaSCOsYhbJsKLUhh9M4hHGJghWwgWwgWwbyBby5qLKpcgLoNUhh9M4hHGJghWwbyBby5qLKpcgLilDpo6nXpcbhnoGTcWIjeftivAEJ)ClRctilRdyldyxxa2saw1s9l7rTcyNaSObSvawmHOykBZrFlZPjAn4fbmsbSDaSLbSRlaBjalhQK8rWOezj8W5pcQdIwdFrfsbSvawmHOykBZrFlZPjAn4fbmsbmYaSva2wawnC1ResLM34hpCE7rsQpXCfbylhegC1MheAzo3OT5HkSbzHmccQpXCff2oiGHDPWEccyZ4ilRNOesP5psLM34V2dhVsqvoTtbSta25ObSRlaBlatxZj68CfLY2CrOIOpTJ083eFkrUcBd(ucP082JeegC1MheIaBP1q9fvEeIbIcvyJOdzeeuFI5kkSDqad7sH9eewcWWMXrwwprjKsZFKknVXFThoELGQCANcyNaS1gWwbyXeIIjKknVXpE482JKGQCANcyldyxxa2sag2moYY6jkHuA(JuP5n(R9WXReuLt7ua7eGD(mGTcW2cWIjeftivAEJF8W5Thjbv50ofWwgWUUamSzCKL1tucP08hPsZB8x7HJxjOkN2PagPa25DhegC1MheWdN)iOoiAn8fvinuHn2DiJGWGR28GaLqkn)rQ08g)1E44vqq9jMROW2HkSXMHmccQpXCff2oiGHDPWEccuJG)07bIamspaSndcdUAZdc3JJEt8JqWrJhQWg7AiJGG6tmxrHTdcyyxkSNGa1i4p9EGiaJ0dalAaBfGTeGTeGTeGLdvs(iyuIS094O3e)ieC04a21fGftikMY2C03YCAIwdEraJ0dalAaBzaBfGftikMY2C03YCAIwdEra7eGT2a2Ya21fGHnJJSSEIsiLM)ivAEJ)ApC8kbv50ofWoDayrWiaBTayKbyxxawmHOycPsZB8NBzvycQYPDkGrkGfbJaS1cGrgGTCqyWvBEq4EC0BIFecoA8qf2ikhYiiO(eZvuy7Gag2Lc7jiKdvs(iyu6C6EC0BIFecoACaBfGrnc(tVhicWi9aWodyRaSLaSycrXu2MJ(wMtt0AWlcyNoaSObSRlalhQK8rWOu0P7XrVj(ri4OXbSLbSvag1i4p9EGia7eGTBaBfGftikMqQ08g)ydQjI8GWGR28GasLMhB8kuHnIsczeeuFI5kkSDqad7sH9eewcWWMXrwwprjKsZFKknVXFThoELGQCANcyKcy7EhaBfGrZvo)RbgrlAQL5CJ2MdyNoamYaSLbSRladBghzz9eLqkn)rQ08g)1E44vcQYPDkGDcWotwqyWvBEqGsiLM)K0CvSvhfQWgRDiJGG6tmxrHTdcyyxkSNGa2moYY6jkHuA(JuP5n(R9WXReuLt7uaJuaBTdcdUAZdcXnxPyJagr)ytgRqAOcBCENqgbHbxT5bbrdtqv0prLc7s)yDKbb1NyUIcBhQWgNphYiim4QnpiKtaBX9Th5J5dTccQpXCff2ouHnotwiJGWGR28Gqm3m0BIFDRV6QCFqq9jMROW2HkSX5OdzeeuFI5kkSDqad7sH9ee2cWqwLWMJvVGtPOxKps9JjGEcQYPDkGTcW2cWgC1MNWMJvVGtPOxKpsn1(lY7i3fGTcWO5kN)1aJOfn1YCUrBZbSta2MbHbxT5bbS5y1l4uk6f5JudvyJZ7oKrqq9jMROW2bbmSlf2tqGAe8NEpqeGDcW2eWwbyXeIIjKknVXp2GAIwdEra70bGrwqyWvBEqGAe8NwWErnuHnoVziJGG6tmxrHTdcyyxkSNGa1i4p9EGia70bGfnGTcWIjeftivAEJFSb1eroGTcWwcWIjeftivAEJFSb1eTg8IagPhaw0a21fGftikMqQ08g)ydQjOkN2Pa2PdalcgbyRfaBZuugWwoim4QnpiGuP5XgVcvyJZ7AiJGG6tmxrHTdcdUAZdciZKbb8Emx)AGr0Ig24CqqoRXJ3J56xdmIw0GquoiGHDPWEccqveQ07jMRHkSX5OCiJGG6tmxrHTdcdUAZdc4HZ)bxT5pVPvqG3069rQbHyIMJ(5P3defQqfeCTUv4NBWA4FmrZrThjKryJZHmccQpXCff2oim4Qnpimrf9EGd9fnVEt8ZTSkmiGHDPWEccyZ4ilRNCTUv4NBWA4jOkN2Pa2PdaBtaBTay0CLZ)7HwAqWhPgeMOIEpWH(IMxVj(5wwfgQWgKfYiiO(eZvuy7Gag2Lc7jiSfGHnJJSSEY16wHFUbRHNGQCANcyRamQrWF69aragPha2MbHbxT5bHiede1J)M4prLcT6ouHnIoKrqq9jMROW2bbmSlf2tqGAe8NEpqeGr6bGTzqyWvBEqW16wHFUbRHhQWg7oKrqq9jMROW2bbmSlf2tqOAPcyKEayrVtqyWvBEqapC(JG6GO1WxuH0qf2yZqgbb1NyUIcBheWWUuypbHQLkGr6bGf9oa2kadBghzz9eE48hb1brRHVOcPjOkN2PagPa25OeaBfGrnc(tVhicWi9aWIoim4QnpiCpo6nXpcbhnEOcBSRHmccQpXCff2oiGHDPWEccvlvaJ0dal6DaSvawmHOykBZrFlZPjAn4fbmspamYaSvawmHOycPsZB8JnOMO1GxeWoDayKbyRaSycrXesLM34p3YQWeYY6a2kaJAe8NEpqeGr6bGfDqyWvBEqi3YQWN253MhQWgr5qgbb1NyUIcBheWWUuypbHQLkGr6bGf9oa2kaJAe8NEpqeGr6bGTzqyWvBEq4EC0BIFecoA8qf2ikjKrqq9jMROW2bHbxT5bb8W5)GR28N30kiWBA9(i1GqmrZr)807bIcvOccXenh9ZtVhikKryJZHmccQpXCff2oiGHDPWEccuJG)07bIaStagzbHbxT5bbPkn4(3eFobUrpcQJKgQWgKfYiiO(eZvuy7Gag2Lc7jiSfGvdx9kHuP5n(XMtjK5vBEs9jMRia76cWQwQagPa25nbSRlalhQK8rWO05094O3e)ieC04a2kaBlalMqumfZndXjOvcQYPDAqyWvBEqGAe8NwWErnuHnIoKrqyWvBEqGEpil7hB8kiO(eZvuy7qfQGGR1Tc)CdwdpKryJZHmccQpXCff2oiGHDPWEccyZ4ilRNCTUv4NBWA4jOkN2Pa2jaJSDccdUAZdc4HZ)bxT5pVPvqG3069rQbbxRBf(5gSg(ht0Cu7rcvydYczeeuFI5kkSDqad7sH9eeIjeftUw3k8Znyn8erEqyWvBEqapC(p4Qn)5nTcc8MwVpsni4ADRWp3G1W)bxnjAOcvOccdrDBWGGqlxtdvOcba]] )


end
