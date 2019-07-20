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

    spec:RegisterPack( "Demonology", 20190720.1730, [[dG0)JbqivuweQufpcvQCjLOKAtkHpPIuHrPu0PukSkLOuVIuYSusClvK0UOYVifnmvehtP0YqL8mLKMgQuCnvuTnLOY3urIXPIuCouP06uIsmpvI7PuTpsHdQeLKfQe5HOsvAIOsvDrvKk6KQiLyLQKMPksjTtsP(PksPAOQiv6Pq1ujsUQksv9vvKszVK8xGbt4Wswmr9yitg0LPSzu1NvPgTkCAfVMi1Sr52u1Uf9BHHtQoUksvwoINJ00L66qz7OI(UsQXRefNhvy9krvZNi2VQwTvjLchwTP0MRt2YTNCkCDIB7PS6QBxvH3COBkC9cjDDBk8S8McN7B(idwCZHcxV4GffujLcNgyeKPWp6wNUSOPM3tFGj7qHxt64XyvprIifFRjD8inv4YydRpTKkzfoSAtPnxNSLBp5u46e32tHRZ5IBv4uDdP0MRLB5u4hdeAPswHdnksHZDVG7B(idwCZXloTvewGK(VYDV4OBD6YIMAEp9bMSdfEnPJhJv9ejIu8TM0XJ08VYDV4kgJJxWTR8cUozl3(It9fBpLLLto5V(x5UxW9Eu5Trxw(RC3lo1xGRBm2loTgiPD)vU7fN6lo9P2lKX45DP1hgbOhKUyom9xmjTTc(IG)feZxto59l4E5(VOhV9c(G8cTT(WiV40niDXErH6Ht7f6hf1C)vU7fN6loTNmoEbXqH3Bj8fCFZhPCW6xOtStffE5QFXW)IPFXqFXK0UY(fBgKxCueiQO9l4dYlKdk1OB4(RC3lo1xC6gRnYlWh9JiFrXyXAd(cDIDQOWlx9l64f6Ka9IjPDL9l4(Mps5G1U)k39It9flRGWxe6wAKxGFuWy9lwky9lcSMoq7fb)lKdk9f8Z9rtFrhVO6xWSI2V426xeP9cFqSxqpkc09x5UxCQV40NAVG7PhVb6aahJ75fBAlJUHAd(clrbw2g5fwc34fKQpmYl6JkFb3txKBRD94nqha4yCpVytBz0nuBWxGWiel7x0f526th0xaTQp24fD8IIZyGVWwgKrPdN2lKXi5K3Vi4FbPqtXEb3l3N6u46KGFyMcN7Eb338rgS4MJxCARiSaj9FL7EXr360Lfn18E6dmzhk8AshpgR6jseP4BnPJhP5FL7EXvmghVGBx5fCDYwU9fN6l2EkllNCYF9VYDVG79OYBJUS8x5UxCQVax3ySxCAnqs7(RC3lo1xC6tTxiJXZ7sRpmcqpiDXCy6VysABf8fb)liMVMCY7xW9Y9FrpE7f8b5fAB9HrEXPBq6I9Ic1dN2l0pkQ5(RC3lo1xCApzC8cIHcV3s4l4(Mps5G1VqNyNkk8Yv)IH)ft)IH(IjPDL9l2miV4Oiqur7xWhKxihuQr3W9x5UxCQV40nwBKxGp6hr(IIXI1g8f6e7urHxU6x0Xl0jb6fts7k7xW9nFKYbRD)vU7fN6lwwbHVi0T0iVa)OGX6xSuW6xeynDG2lc(xihu6l4N7JM(IoEr1VGzfTFXT1Vis7f(GyVGEueO7VYDV4uFXPp1Eb3tpEd0baog3Zl20wgDd1g8fwIcSSnYlSeUXlivFyKx0hv(cUNUi3w76XBGoaWX4EEXM2YOBO2GVaHriw2VOlYT1NoOVaAvFSXl64ffNXaFHTmiJshoTxiJrYjVFrW)csHMI9cUxUp19x)RC3loDUmgcRn4lKn(GyVafE5QFHSDpj19ILviKP30xKrEQhfXZJXErH6js6lIKXH7VYDVOq9ej1Ptmu4LRENNvuP)RC3lkuprsD6edfE5Q1Axt(iG)vU7ffQNiPoDIHcVC1ATRzHD7TSREI8VwOEIK60jgk8YvR1UMumVpsGU1)vU7ffQNiPoDIHcVC1ATR5KPraqZhjDLHFVlMLTBY0iaO5JK6SSKzg8VYDVOq9ej1Ptmu4LRwRDnPzPtpIgq7QP)1c1tKuNoXqHxUAT21up6jY)AH6jsQtNyOWlxTw7AQhRncGo6hrUYWVlJXZ7wpmiy86uhTlK0ASDHmgpVdA(iheafeZbJ15FTq9ej1Ptmu4LRwRDnHMps5G1Rm87YbLkrsH6jsh08rkhS2HkAVFYFTq9ej1Ptmu4LRwRDnPhfmwdKdwVYWVFMCqPsKuOEI0bnFKYbRDOI2ACYF9VYDV405YyiS2GVW40iC8IE82l6d7ffQdYlg6lkoRHvYmZ9xluprs3P6gJbybs6)AH6jsQw7AQh9e5kd)UU1oO5JCqGMdsLTRq9WPTyZZ6Izz7sRpmcqpiDXCwwYmdkrImgpVlT(Wia9G0fZHPVHej94nqha4yxw9K)AH6jsQw7AIrnW0MNUYWVRBTdA(iheO5Guz7kupCAsK0J3aDaGJDzF75)1c1tKuT21u2iuJi9K3Rm876w7GMpYbbAoiv2Uc1dNMej94nqha4yx23E(FTq9ejvRDnLzrab8yeowz431T2bnFKdc0CqQSDfQhonjs6XBGoaWXUSV98)AH6jsQw7AYpetMfbCLHFx3Ah08roiqZbPY2vOE40KiPhVb6aah7Y(2Z)RfQNiPATR56GWGCAtcignYkr2kd)UU1oO5JCqGMdsLTRq9WPjrspEd0bao2L9TN)xluprs1AxtYORZmWKaQEHSvg(DDRDqZh5GanhKkBxH6HttIKE8gOdaCSl7Bp)VwOEIKQ1UMOIXafQNibSH2RKL32HOibHULgzLHFVlMLTdA(iheafjfZR3tKollzMbx0J3US6jlodfbdgRthfZ7JeanFKdc0CqQSDeZxts)RfQNiPATR5rLqqWdUXyWkxz43RL3itBoBz0zbD40a6rBzpfZrQu6f94TlNVGgyma9Oiqn4AHmgpVZwgDwqhonGE0w2tXCWyDUqgJN3TEyqW41PoAxiPVS6IZ0jgNGBe0T1Dujee8GBmgSYfNPtmob3iOJl3rLqqWdUXyWk)RfQNiPATRj08rkhSELHFNgyma9OiWl7RUqgJN3bnFKdcGcI5W0xiJXZ7GMpYbbqbXC0UqsVZn)1c1tKuT21C86SGorUYWVxlVrM2C2YOZc6WPb0J2YEkMJuP0lKX45DRhgemEDQJ2fsAn4AHmgpVZwgDwqhonGE0w2tXCeZxtsVuOEI0rpkySgihS2zlJHWAd0J3wS5zDXSSDqZh5GaOiPyE9EI0zzjZmOejOiyWyD6OyEFKaO5JCqGMdsLTJy(AsQgB5AJ)AH6jsQw7AcJWVYWVFwpiPN8ErpEd0baoMgREYcQUXyGUi3wtDJxNf0jYlC9xluprs1Axt5HzuuGrUnGC4LncDLHFVwEJmT5SLrNf0HtdOhTL9umhPsP14Kf94TlBpzbv3ymqxKBRPUXRZc6e5fUwiJXZ7GeRG0UysBeQJy(As6IUyw2U06dJa0dsxmNLLmZG)1c1tKuT21eA(iheG2elV7Jvg(9nLX45DRhgemEDQJ2fs6llNejYy88oO5JCqa9yTrCy6Bircv3ymqxKBRPUXRZc6e5fU(RfQNiPATRjQymqH6jsaBO9kz5T906dJa0dsxSvg(9Uyw2U06dJa0dsxmNLLmZGlO6gJb6ICBn1nEDwqNiVSZ1FTq9ejvRDnrfJbkuprcydTxjlVTpEDwqNixz43P6gJb6ICBn1nEDwqNi1y7FTq9ejvRDnVXkcCQee8GA5ns0hRm876w7GMpYbbAoiv2Uc1dNMej94nqha4yx2x9K)AH6jsQw7AEtgFmedWBSBSIaxz433ShVb6aahtJTCDIej94nqha4yxqrWGX60rX8(ibqZh5GanhKkBhX81KuT2EUejOiyWyD6OyEFKaO5JCqGMdsLTJy(As6LTRUXFTq9ejvRDnPyEFKaohMXpwcxz43rrWGX60rX8(ibqZh5GanhKkBhX81Kun4MtKibfbdgRthfZ7JeanFKdc0CqQSDeZxtsVSLR)AH6jsQw7AIkgdajwbPDXK2i0vg(9nrrWGX60rX8(ibqZh5GanhKkBhX81K0lC7czmEEh08roiaQySjVDeZxts3qIKnrrWGX60rX8(ibqZh5GanhKkBhX81K0lB3U4mzmEEh08roiaQySjVDeZxts3qIeuemySoDumVpsa08roiqZbPY2rmFnjvJTCZFTq9ejvRDn7ddGLYbwcb8bbzRm87Yy88oIHKMzukGpiiZrSc1)1c1tKuT21uEygffyKBdihEzJq)RfQNiPATR5rLqqWdUXyWkxz433SwEJmT5KlMXJXatYzGQEI0zzjZmOejDXSSDqZh5GaOiPyE9EI0zzjZm4gl0jgNGBe0T1Dujee8GBmgSYfOiyWyD6OyEFKaO5JCqGMdsLTJy(As6fU(RC3l46Ktozznv3ymWrrB7fd9f0JG0hvcFbFqErFyVav0(f94Txe8VG7B(ih0lKIdsLT7fsDyVyY2Y(fd9fD8IizC8cz7EYxGkAp59lg(xuVazKUM8fjMx2iVi4FX41PVy9WyVq2ErG1VqMJx0h2lSe(IG)f9H9curB3FTq9ejvRDnPyEFKaO5JCqGMdsL9kd)onWya6rrGxwDXMN1fZY2bnFKdcGIKI517jsNLLmZGsKiJXZ7wpmiy86uhTlK0AnEDkGQxRtdcGyKjVDumVpsa08roiqZbPYwJ9LBrpEd0by86uxXyoI5RjPxqfTb94TnKiPhVb6aah7cxN8xluprs1Axt9yTra0r)iYvg(DzmEE36HbbJxN6ODHKwJDUwiJXZ7GMpYbbqbXC0UqsFzNRfYy88oO5JCqa9yTrCWyDUGQBmgOlYT1u341zbDI8cx)1c1tKuT21egHFLHFVlMLTdgH3zzjZm4cIXtm6rjZSf94nqha4yASjmAhmcVJy(AsQwREYg)1c1tKuT218Osii4b3ymyLRm870aJbOhfbQX(5sKSjnWya6rrGASV6cuemySoDOIXaqIvqAxmPnc1rmFnjvdUzXMOiyWyD6OyEFKaO5JCqGMdsLTJy(AsQgCDIejBIIGbJ1PJI59rcGMpYbbAoiv2oI5RjPxUrWLnxl6Izz7GMpYbbqrsX869ePZYsMzqjsqrWGX60rX8(ibqZh5GanhKkBhX81K0l3i4YMBwCwxmlBh08roiakskMxVNiDwwYmdUXgl28SUyw2okM3hjGZHz8JLqNLLmZGsKGIGbJ1PJI59rc4Cyg)yj0rmFnjvJv3yJ)AH6jsQw7AsdmgG2KrABLHFNgyma9OiWlNVqgJN3bnFKdcGcI5ODHK(Yox)1c1tKuT21eA(iLdwVYWVtdmgGEue4L9vxiJXZ7GMpYbbqbXCy6l2CtuemySoDumVpsa08roiqZbPY2rmFnj9YYjrckcgmwNokM3hjaA(iheO5Guz7iMVMKQbxCT4SA5nY0MJEuWynfipT5SSKzgCdjsKX45DqZh5GaOGyoAxiP1yFvjsKX45DqZh5GaOGyoI5RjPxoxIKE8gOdaCSlCDUejYy88o6rbJ1uG80MJy(As6g)1c1tKuT21KpqyudcQL3itBazR8Rm87NPBTdA(iheO5Guz7kupCA)1c1tKuT21uhJm8Cm5nqMv0(VwOEIKQ1UMYSiGGGh0hgWsZZXFTq9ejvRDnrrISSjvBqapR82kd)(zWODOirw2KQniGNvEdiJrshX81K0fNvOEI0HIezztQ2GaEw5n3KaE2CF0lot3Ah08roiqZbPY2vOE40(RfQNiPATRjQymqH6jsaBO9kz5TDzSHbbfGEue4F9VwOEIK6KXggeua6rrG7EZheoabpGHHgiasSYtxz43Pbgdqpkc8cx)1c1tKuNm2WGGcqpkcuRDnPbgdqBYiTTYWVFwxmlBh08roiakskMxVNiDwwYmdkrspEtJTNlrIoX4eCJGUTUJkHGGhCJXGvU4mzmEENmlcidJ2oI5RjP)1c1tKuNm2WGGcqpkcuRDnPhfmwdKdw)x)RfQNiPoiksqOBPr2pQeccEWngdw5kSjnacUV6jRm871YBKPnNTm6SGoCAa9OTSNI5SSKzg8VwOEIK6GOibHULgrRDnhVolOtKRm871YBKPnNTm6SGoCAa9OTSNI5SSKzgCHmgpVB9WGGXRtD0UqsRbxlKX45D2YOZc6WPb0J2YEkMdgRZ)AH6jsQdIIee6wAeT21egHFf2Kgab3x9K)AH6jsQdIIee6wAeT218Osii4b3ymyLRm876eJtWnc626oQeccEWngdw5cAGXa0JIa14Kf6eJtWnc64YrdmgG2KrA7VwOEIK6GOibHULgrRDnHMpYbbOnXY7(yLHFxNyCcUrq3w3rLqqWdUXyWkxCMoX4eCJGoUChvcbbp4gJbRCXMYy88U1ddcgVo1r7cjTgBxuOEI0Dujee8GBmgSs3KaE2CF0B8xluprsDquKGq3sJO1UMYdZOOaJCBa5WlBe6FTq9ej1brrccDlnIw7AsdmgG2KrABf2Kgab3x9Kvg(9ZKX45DYSiGmmA7iMVMKkrspEtJZxOtmob3iOBR7Osii4b3ymyL)1c1tKuhefji0T0iATRjfZ7JeW5Wm(Xs4kd)onWya6rrG7N)xluprsDquKGq3sJO1UM3KXhdXa8g7gRiWvg(DAGXa0JIa3p)VwOEIK6GOibHULgrRDnrfJbGeRG0UysBe6kd)onWya6rrG7N)xluprsDquKGq3sJO1UMhvcbbp4gJbRCLHFNgyma9OiW9Z)RfQNiPoiksqOBPr0AxZJkHGGhCJXGvUYWVtdmgGEueOg7RUqNyCcUrqhxUJkHGGhCJXGvUOhVPX5l2uNyCcUrq3whnWyaAtgPnjsoRlMLTJgymaTjJ0MZYsMzWf6eJtWnc626OhfmwdKdwVXFL7EbxNCYjlRP6gJbokABVyOVGEeK(Os4l4dYl6d7fOI2VOhV9IG)fCFZh5GEHuCqQSDVqQd7ft2w2VyOVOJxejJJxiB3t(cur7jVFXW)I6fiJ01KViX8Yg5fb)lgVo9fRhg7fY2lcS(fYC8I(WEHLWxe8VOpSxGkA7(RfQNiPoiksqOBPr0AxtkM3hjaA(iheO5GuzVYWVRtmob3iOBRdA(iheG2elV7djs0jgNGBe0T1Dujee8GBmgSYf6eJtWnc64YDujee8GBmgSsjsoRlMLTdA(iheG2elV7dNLLmZGlKX45DRhgemEDQJ2fsATgVofq1R1PbbqmYK3okM3hjaA(iheO5GuzRX(Y9xluprsDquKGq3sJO1UMqZhPCW6vg(DAGXa0JIaVSV6czmEEh08roiakiMJy(As6FTq9ej1brrccDlnIw7AIkgduOEIeWgAVswEBxgByqqbOhfb(x)RfQNiPUXRZc6e5(41zbDICLHFFtzmEE36HbbJxN6ODHKwJ9LBXM0aJbOhfbEzvjs0jgNGBe0T1HkgdajwbPDXK2iujsKX45DRhgemEDQJ2fsAn25wjs0jgNGBe0T1jpmJIcmYTbKdVSrOsKS5z6eJtWnc626oQeccEWngdw5IZ0jgNGBe0XL7Osii4b3ymyLBSXIZ0jgNGBe0T1Dujee8GBmgSYfNPtmob3iOJl3rLqqWdUXyWkxiJXZ7GMpYbb0J1gXbJ15gsKSzpEd0bao2LvxiJXZ7wpmiy86uhTlK0ACYgsKSPoX4eCJGoUCOIXaqIvqAxmPncDHmgpVB9WGGXRtD0UqsRbxloRlMLTdA(iheavm2K3ollzMb34VwOEIK6gVolOtKATR5nz8XqmaVXUXkcCLHFhfbdgRthfZ7JeanFKdc0CqQSDeZxtsVSDvjsoZo9WgDDd62UkxRUCC7FTq9ej1nEDwqNi1AxtuXyaiXkiTlM0gHUYWVVjkcgmwNokM3hjaA(iheO5Guz7iMVMKEHBxiJXZ7GMpYbbqfJn5TJy(As6gsKSjkcgmwNokM3hjaA(iheO5Guz7iMVMKEz72fNjJXZ7GMpYbbqfJn5TJy(As6gsKGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPASLB(RfQNiPUXRZc6ePw7AsX8(ibqZh5GanhKk7)AH6jsQB86SGorQ1UMhvcbbp4gJbRCLHFNgyma9Oiqn2p)VwOEIK6gVolOtKATR5rLqqWdUXyWkxz43PbgdqpkcuJ9vxS5MBQtmob3iOJl3rLqqWdUXyWkLirgJN3TEyqW41PoAxiP1yF1nwiJXZ7wpmiy86uhTlK0x42nKibfbdgRthfZ7JeanFKdc0CqQSDeZxtsVSFJGlBUKirgJN3bnFKdcOhRnIJy(AsQg3i4YMRn(RfQNiPUXRZc6ePw7AcnFKYbRxz431jgNGBe0T1Dujee8GBmgSYf0aJbOhfbQX(2fBkJXZ7wpmiy86uhTlK0x2xvIeDIXj4gbDR6oQeccEWngdw5glObgdqpkc8c3SqgJN3bnFKdcGcI5W0)RfQNiPUXRZc6ePw7AsX8(ibComJFSeUYWVVjkcgmwNokM3hjaA(iheO5Guz7iMVMKQb3CYcQUXyGUi3wtDJxNf0jYl7CTHejOiyWyD6OyEFKaO5JCqGMdsLTJy(As6LTC9xluprsDJxNf0jsT21uEygffyKBdihEzJqxz43rrWGX60rX8(ibqZh5GanhKkBhX81Kun42)AH6jsQB86SGorQ1UM8bcJAqqT8gzAdiBL)VwOEIK6gVolOtKATRPogz45yYBGmRO9FTq9ej1nEDwqNi1AxtzweqqWd6ddyP554VwOEIK6gVolOtKATRjksKLnPAdc4zL3wz43pdgTdfjYYMuTbb8SYBazms6iMVMKU4Sc1tKouKilBs1geWZkV5MeWZM7JEbv3ymqxKBRPUXRZc6e5LZ)RfQNiPUXRZc6ePw7AsdmgG2KrABLHFNgyma9OiWlNVqgJN3bnFKdcGcI5ODHK(Yox)1c1tKu341zbDIuRDnHMps5G1Rm870aJbOhfbEzF1fYy88oO5JCqauqmhM(InLX45DqZh5GaOGyoAxiP1yFvjsKX45DqZh5GaOGyoI5RjPx2VrWL95UtzJ)AH6jsQB86SGorQ1UMWi8RG4aXmqxKBRP7BxXxldaXbIzGUi3wt3pLvg(DIXtm6rjZS)AH6jsQB86SGorQ1UMOIXafQNibSH2RKL32LXggeua6rrG)1)AH6jsQlT(Wia9G0fBhvmgOq9ejGn0ELS82EA9Hra6bPlgqgByWjVxz43rrWGX60LwFyeGEq6I5iMVMKEHRt(RfQNiPU06dJa0dsxmT21evmgOq9ejGn0ELS82EA9Hra6bPlgOq9WPTYWVlJXZ7sRpmcqpiDXCy6)1)AH6jsQlT(Wia9G0fduOE402LhMrrbg52aYHx2i0)AH6jsQlT(Wia9G0fduOE400AxZBY4JHyaEJDJve4kd)okcgmwNokM3hjaA(iheO5Guz7iMVMKEz7QsKCMD6Hn66g0TDvUwD542)AH6jsQlT(Wia9G0fduOE400AxtkM3hjGZHz8JLWvg(DuemySoDumVpsa08roiqZbPY2rmFnjvdU5ejsqrWGX60rX8(ibqZh5GanhKkBhX81K0lB56VwOEIK6sRpmcqpiDXafQhonT21evmgasScs7IjTrORm87BIIGbJ1PJI59rcGMpYbbAoiv2oI5RjPx42fYy88oO5JCqauXytE7iMVMKUHejBIIGbJ1PJI59rcGMpYbbAoiv2oI5RjPx2UDXzYy88oO5JCqauXytE7iMVMKUHejOiyWyD6OyEFKaO5JCqGMdsLTJy(AsQgB5M)AH6jsQlT(Wia9G0fduOE400AxtuXyGc1tKa2q7vYYB7Yyddcka9OiWvg(DAGXa0JIa33UytuemySoDOIXaqIvqAxmPnc1rmFnj9sH6jsh9OGXAGCWAhQOnOhVjrYMDXSSDYdZOOaJCBa5WlBeQZYsMzWfOiyWyD6KhMrrbg52aYHx2iuhX81K0lfQNiD0JcgRbYbRDOI2GE82gB8xluprsDP1hgbOhKUyGc1dNMw7AEujee8GBmgSYvg(9n3efbdgRthQymaKyfK2ftAJqDeZxts1Oq9ePdA(iLdw7qfTb94TnwSjkcgmwNouXyaiXkiTlM0gH6iMVMKQrH6jsh9OGXAGCWAhQOnOhVTXglKX45DP1hgbOhKUyoI5RjPAGkAd6XB)1c1tKuxA9Hra6bPlgOq9WPP1UMumVpsa08roiqZbPYELHFxgJN3LwFyeGEq6I5iMVMKE58f0aJbOhfbUFYFTq9ej1LwFyeGEq6IbkupCAATRjfZ7JeanFKdc0CqQSxz43LX45DP1hgbOhKUyoI5RjPxkupr6OyEFKaO5JCqGMdsLTdv0g0J306e35)1c1tKuxA9Hra6bPlgOq9WPP1UMqZhPCW6vg(DzmEEh08roiakiMdtFbnWya6rrGx2x9VwOEIK6sRpmcqpiDXafQhonT21evmgOq9ejGn0ELS82Um2WGGcqpkc8V(xluprsDP1hgbOhKUyazSHbN8EpT(Wia9G0fBLHFNgyma9Oiqn2pFXMN1fZY2PhRncGo6hr6SSKzguIezmEEh08roiakiMdtFJ)AH6jsQlT(Wia9G0fdiJnm4K3ATRjQymaKyfK2ftAJq)RfQNiPU06dJa0dsxmGm2WGtER1UMhvcbbp4gJbRCLHFhfbdgRthQymaKyfK2ftAJqDeZxts1y7PzbnWya6rrGASV6FTq9ej1LwFyeGEq6IbKXggCYBT21upwBeaD0pICLHFxgJN3TEyqW41PoAxiP1yNRfYy88oO5JCqauqmhTlK0x25AHmgpVdA(iheqpwBehmwNlObgdqpkcuJ9v)RfQNiPU06dJa0dsxmGm2WGtER1UMhvcbbp4gJbRCLHFNgyma9Oiqn2p)VwOEIK6sRpmcqpiDXaYyddo5Tw7AIkgduOEIeWgAVswEBxgByqqbOhfbQW50i0jsL2CDYwU9Kt5eU1T9uu4Rlso5nvHFAXRhK2GV408Ic1tKVGn0M6(RkC2qBQskfEA9Hra6bPlMskL2BvsPWTSKzguTKcVq9ePchvmgOq9ejGn0wHJitBKPu4OiyWyD6sRpmcqpiDXCeZxtsFXLxW1jkC2qBqwEtHNwFyeGEq6IbKXggCYBvR0MlLukCllzMbvlPWluprQWrfJbkuprcydTv4iY0gzkfUmgpVlT(Wia9G0fZHPRWzdTbz5nfEA9Hra6bPlgOq9WPPAvRWtRpmcqpiDXaYyddo5TskL2BvsPWTSKzguTKchrM2itPWPbgdqpkc8fAS)IZFXIxS5lo7fDXSSD6XAJaOJ(rKollzMbFHejVqgJN3bnFKdcGcI5W0FXgk8c1tKk806dJa0dsxmvR0MlLuk8c1tKkCuXyaiXkiTlM0gHQWTSKzguTKQvAVQskfULLmZGQLu4iY0gzkfokcgmwNouXyaiXkiTlM0gH6iMVMK(cnEX2tZlw8cAGXa0JIaFHg7VyvfEH6jsf(rLqqWdUXyWkvTsBUrjLc3YsMzq1skCezAJmLcxgJN3TEyqW41PoAxiPFHg7VGRxS4fYy88oO5JCqauqmhTlK0V4Y(l46flEHmgpVdA(iheqpwBehmwNVyXlObgdqpkc8fAS)Ivv4fQNiv46XAJaOJ(rKQwP95kPu4wwYmdQwsHJitBKPu40aJbOhfb(cn2FX5k8c1tKk8JkHGGhCJXGvQAL2lNskfULLmZGQLu4fQNiv4OIXafQNibSH2kC2qBqwEtHlJnmiOa0JIavTQv4qJVWyTskL2BvsPWluprQWP6gJbybsAfULLmZGQLuTsBUusPWTSKzguTKchrM2itPW1T2bnFKdc0CqQSDfQhoTxS4fB(IZErxmlBxA9Hra6bPlMZYsMzWxirYlKX45DP1hgbOhKUyom9xSXlKi5f94nqha4yV4Ylw9efEH6jsfUE0tKQwP9QkPu4wwYmdQwsHJitBKPu46w7GMpYbbAoiv2Uc1dN2lKi5f94nqha4yV4Y(l2EUcVq9ePchJAGPnpv1kT5gLukCllzMbvlPWrKPnYukCDRDqZh5GanhKkBxH6Ht7fsK8IE8gOdaCSxCz)fBpxHxOEIuHlBeQrKEYBvR0(CLukCllzMbvlPWrKPnYukCDRDqZh5GanhKkBxH6Ht7fsK8IE8gOdaCSxCz)fBpxHxOEIuHlZIac4XiCOAL2lNskfULLmZGQLu4iY0gzkfUU1oO5JCqGMdsLTRq9WP9cjsErpEd0bao2lUS)ITNRWluprQW5hIjZIaQAL2NIskfULLmZGQLu4iY0gzkfUU1oO5JCqGMdsLTRq9WP9cjsErpEd0bao2lUS)ITNRWluprQWxhegKtBsaXOrwjYuTs7tJskfULLmZGQLu4iY0gzkfUU1oO5JCqGMdsLTRq9WP9cjsErpEd0bao2lUS)ITNRWluprQWjJUoZatcO6fYuTsBUvjLc3YsMzq1sk8c1tKkCuXyGc1tKa2qBfoImTrMsH3fZY2bnFKdcGIKI517jsNLLmZGVyXl6XBV4Ylw9KxS4fN9cuemySoDumVpsa08roiqZbPY2rmFnjvHZgAdYYBkCiksqOBPruTs7TNOKsHBzjZmOAjfoImTrMsHxlVrM2C2YOZc6WPb0J2YEkMJuP0VyXl6XBV4Ylo)flEbnWya6rrGVqJxW1lw8czmEENTm6SGoCAa9OTSNI5GX68flEHmgpVB9WGGXRtD0Uqs)IlVy1xS4fN9cDIXj4gbDBDhvcbbp4gJbR8flEXzVqNyCcUrqhxUJkHGGhCJXGvQWluprQWpQeccEWngdwPQvAVDRskfULLmZGQLu4iY0gzkfonWya6rrGV4Y(lw9flEHmgpVdA(iheafeZHP)IfVqgJN3bnFKdcGcI5ODHK(f7VGBu4fQNiv4qZhPCWAvR0ElxkPu4wwYmdQwsHJitBKPu41YBKPnNTm6SGoCAa9OTSNI5ivk9lw8czmEE36HbbJxN6ODHK(fA8cUEXIxiJXZ7SLrNf0HtdOhTL9umhX81K0xC5ffQNiD0JcgRbYbRD2YyiS2a94TxS4fB(IZErxmlBh08roiakskMxVNiDwwYmd(cjsEbkcgmwNokM3hjaA(iheO5Guz7iMVMK(cnEXwUEXgk8c1tKk8XRZc6ePQvAVDvLukCllzMbvlPWrKPnYuk8ZErpiPN8(flErpEd0bao2l04fREYlw8cQUXyGUi3wtDJxNf0jYxC5fCPWluprQWHr4vTs7TCJskfULLmZGQLu4iY0gzkfET8gzAZzlJolOdNgqpAl7PyosLs)cnEXjVyXl6XBV4Yl2EYlw8cQUXyGUi3wtDJxNf0jYxC5fC9IfVqgJN3bjwbPDXK2iuhX81K0xS4fDXSSDP1hgbOhKUyollzMbv4fQNiv4YdZOOaJCBa5WlBeQQvAV9CLukCllzMbvlPWrKPnYuk8nFHmgpVB9WGGXRtD0Uqs)IlVy5EHejVqgJN3bnFKdcOhRnIdt)fB8cjsEbv3ymqxKBRPUXRZc6e5lU8cUu4fQNiv4qZh5Ga0My5DFOAL2BxoLukCllzMbvlPWluprQWrfJbkuprcydTv4iY0gzkfExmlBxA9Hra6bPlMZYsMzWxS4fuDJXaDrUTM6gVolOtKV4Y(l4sHZgAdYYBk806dJa0dsxmvR0E7POKsHBzjZmOAjfEH6jsfoQymqH6jsaBOTchrM2itPWP6gJb6ICBn1nEDwqNiFHgVyRcNn0gKL3u4JxNf0jsvR0E7PrjLc3YsMzq1skCezAJmLcx3Ah08roiqZbPY2vOE40EHejVOhVb6aah7fx2FXQNOWluprQWVXkcCQee8GA5ns0hQwP9wUvjLc3YsMzq1skCezAJmLcFZx0J3aDaGJ9cnEXwUo5fsK8IE8gOdaCSxC5fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6l06fBp)fsK8cuemySoDumVpsa08roiqZbPY2rmFnj9fxEX2vFXgk8c1tKk8BY4JHyaEJDJveOQvAZ1jkPu4wwYmdQwsHJitBKPu4OiyWyD6OyEFKaO5JCqGMdsLTJy(As6l04fCZjVqIKxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4Yl2YLcVq9ePcNI59rc4Cyg)yju1kT5ARskfULLmZGQLu4iY0gzkf(MVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxWTVyXlKX45DqZh5GaOIXM82rmFnj9fB8cjsEXMVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxSD7lw8IZEHmgpVdA(iheavm2K3oI5RjPVyJxirYlqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl2Ynk8c1tKkCuXyaiXkiTlM0gHQAL2CXLskfULLmZGQLu4iY0gzkfUmgpVJyiPzgLc4dcYCeRqTcVq9ePcVpmawkhyjeWheKPAL2CTQskfEH6jsfU8WmkkWi3gqo8YgHQWTSKzguTKQvAZf3OKsHBzjZmOAjfoImTrMsHV5lQL3itBo5Iz8ymWKCgOQNiDwwYmd(cjsErxmlBh08roiakskMxVNiDwwYmd(InEXIxOtmob3iOBR7Osii4b3ymyLVyXlqrWGX60rX8(ibqZh5GanhKkBhX81K0xC5fCPWluprQWpQeccEWngdwPQvAZ15kPu4wwYmdQwsHJitBKPu40aJbOhfb(IlVy1xS4fB(IZErxmlBh08roiakskMxVNiDwwYmd(cjsEHmgpVB9WGGXRtD0Uqs)cTEX41PaQEToniaIrM82rX8(ibqZh5GanhKk7xOX(lwUxS4f94nqhGXRtDfJ5iMVMK(IlVav0g0J3EXgVqIKx0J3aDaGJ9IlVGRtu4fQNiv4umVpsa08roiqZbPYw1kT5A5usPWTSKzguTKchrM2itPWLX45DRhgemEDQJ2fs6xOX(l46flEHmgpVdA(iheafeZr7cj9lUS)cUEXIxiJXZ7GMpYbb0J1gXbJ15lw8cQUXyGUi3wtDJxNf0jYxC5fCPWluprQW1J1gbqh9JivTsBUofLukCllzMbvlPWrKPnYuk8Uyw2oyeENLLmZGVyXligpXOhLmZEXIx0J3aDaGJ9cnEXMVagTdgH3rmFnj9fA9Ivp5fBOWluprQWHr4vTsBUonkPu4wwYmdQwsHJitBKPu40aJbOhfb(cn2FX5VqIKxS5lObgdqpkc8fAS)IvFXIxGIGbJ1PdvmgasScs7IjTrOoI5RjPVqJxWnVyXl28fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6l04fCDYlKi5fB(cuemySoDumVpsa08roiqZbPY2rmFnj9fxEXnc(IL9l46flErxmlBh08roiakskMxVNiDwwYmd(cjsEbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlV4gbFXY(fCZlw8IZErxmlBh08roiakskMxVNiDwwYmd(InEXgVyXl28fN9IUyw2okM3hjGZHz8JLqNLLmZGVqIKxGIGbJ1PJI59rc4Cyg)yj0rmFnj9fA8IvFXgVydfEH6jsf(rLqqWdUXyWkvTsBU4wLukCllzMbvlPWrKPnYukCAGXa0JIaFXLxC(lw8czmEEh08roiakiMJ2fs6xCz)fCPWluprQWPbgdqBYiTPAL2REIskfULLmZGQLu4iY0gzkfonWya6rrGV4Y(lw9flEHmgpVdA(iheafeZHP)IfVyZxS5lqrWGX60rX8(ibqZh5GanhKkBhX81K0xC5fl3lKi5fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6l04fCX1lw8IZErT8gzAZrpkySMcKN2CwwYmd(InEHejVqgJN3bnFKdcGcI5ODHK(fAS)IvFHejVqgJN3bnFKdcGcI5iMVMK(IlV48xirYl6XBGoaWXEXLxW15VqIKxiJXZ7OhfmwtbYtBoI5RjPVydfEH6jsfo08rkhSw1kTxDRskfULLmZGQLu4iY0gzkf(zVq3Ah08roiqZbPY2vOE40u4fQNiv48bcJAqqT8gzAdiBLx1kTxLlLuk8c1tKkCDmYWZXK3azwrBfULLmZGQLuTs7vxvjLcVq9ePcxMfbee8G(WawAEou4wwYmdQws1kTxLBusPWTSKzguTKchrM2itPWp7fWODOirw2KQniGNvEdiJrshX81K0xS4fN9Ic1tKouKilBs1geWZkV5MeWZM7J(flEXzVq3Ah08roiqZbPY2vOE40u4fQNiv4Oirw2KQniGNvEt1kTx9CLukCllzMbvlPWluprQWrfJbkuprcydTv4SH2GS8McxgByqqbOhfbQAvRW1jgk8YvRKsP9wLuk8c1tKkCkM3hjG3y3yfbQWTSKzguTKQvAZLskfEH6jsfUE0tKkCllzMbvlPAL2RQKsHBzjZmOAjfoImTrMsHlJXZ7wpmiy86uhTlK0VqJxS9flEHmgpVdA(iheafeZbJ1PcVq9ePcxpwBeaD0pIu1kT5gLukCllzMbvlPWrKPnYukC5GsFHejVOq9ePdA(iLdw7qfTFX(lorHxOEIuHdnFKYbRvTs7ZvsPWTSKzguTKchrM2itPWp7fYbL(cjsErH6jsh08rkhS2HkA)cnEXjk8c1tKkC6rbJ1a5G1Qw1k8XRZc6ePskL2BvsPWTSKzguTKchrM2itPW38fYy88U1ddcgVo1r7cj9l0y)fl3lw8InFbnWya6rrGV4Ylw9fsK8cDIXj4gbDBDOIXaqIvqAxmPnc9fsK8czmEE36HbbJxN6ODHK(fAS)cU9fsK8cDIXj4gbDBDYdZOOaJCBa5WlBe6lKi5fB(IZEHoX4eCJGUTUJkHGGhCJXGv(IfV4SxOtmob3iOJl3rLqqWdUXyWkFXgVyJxS4fN9cDIXj4gbDBDhvcbbp4gJbR8flEXzVqNyCcUrqhxUJkHGGhCJXGv(IfVqgJN3bnFKdcOhRnIdgRZxSXlKi5fB(IE8gOdaCSxC5fR(IfVqgJN3TEyqW41PoAxiPFHgV4KxSXlKi5fB(cDIXj4gbDC5qfJbGeRG0UysBe6lw8czmEE36HbbJxN6ODHK(fA8cUEXIxC2l6Izz7GMpYbbqfJn5TZYsMzWxSHcVq9ePcF86SGorQAL2CPKsHBzjZmOAjfoImTrMsHJIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4Yl2U6lKi5fN9c70dB01nOB9W4jgKcOZ9WabpGIPBKjiakM3h5K3k8c1tKk8BY4JHyaEJDJveOQvAVQskfULLmZGQLu4iY0gzkf(MVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxWTVyXlKX45DqZh5GaOIXM82rmFnj9fB8cjsEXMVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxSD7lw8IZEHmgpVdA(iheavm2K3oI5RjPVyJxirYlqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl2Ynk8c1tKkCuXyaiXkiTlM0gHQAL2CJskfEH6jsfofZ7JeanFKdc0CqQSv4wwYmdQws1kTpxjLc3YsMzq1skCezAJmLcNgyma9OiWxOX(loxHxOEIuHFujee8GBmgSsvR0E5usPWTSKzguTKchrM2itPWPbgdqpkc8fAS)IvFXIxS5l28fB(cDIXj4gbDC5oQeccEWngdw5lKi5fYy88U1ddcgVo1r7cj9l0y)fR(InEXIxiJXZ7wpmiy86uhTlK0V4Yl42xSXlKi5fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6lUS)IBe8fl7xW1lKi5fYy88oO5JCqa9yTrCeZxtsFHgV4gbFXY(fC9Inu4fQNiv4hvcbbp4gJbRu1kTpfLukCllzMbvlPWrKPnYukCDIXj4gbDBDhvcbbp4gJbR8flEbnWya6rrGVqJ9xS9flEXMVqgJN3TEyqW41PoAxiPFXL9xS6lKi5f6eJtWnc6w1Dujee8GBmgSYxSXlw8cAGXa0JIaFXLxWnVyXlKX45DqZh5GaOGyomDfEH6jsfo08rkhSw1kTpnkPu4wwYmdQwsHJitBKPu4B(cuemySoDumVpsa08roiqZbPY2rmFnj9fA8cU5KxS4fuDJXaDrUTM6gVolOtKV4Y(l46fB8cjsEbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVylxk8c1tKkCkM3hjGZHz8JLqvR0MBvsPWTSKzguTKchrM2itPWrrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl4wfEH6jsfU8WmkkWi3gqo8YgHQAL2BprjLcVq9ePcNpqyudcQL3itBazR8kCllzMbvlPAL2B3QKsHxOEIuHRJrgEoM8giZkARWTSKzguTKQvAVLlLuk8c1tKkCzweqqWd6ddyP55qHBzjZmOAjvR0E7QkPu4wwYmdQwsHJitBKPu4N9cy0ouKilBs1geWZkVbKXiPJy(As6lw8IZErH6jshksKLnPAdc4zL3Ctc4zZ9r)IfVGQBmgOlYT1u341zbDI8fxEX5k8c1tKkCuKilBs1geWZkVPAL2B5gLukCllzMbvlPWrKPnYukCAGXa0JIaFXLxC(lw8czmEEh08roiakiMJ2fs6xCz)fCPWluprQWPbgdqBYiTPAL2BpxjLc3YsMzq1skCezAJmLcNgyma9OiWxCz)fR(IfVqgJN3bnFKdcGcI5W0FXIxS5lKX45DqZh5GaOGyoAxiPFHg7Vy1xirYlKX45DqZh5GaOGyoI5RjPV4Y(lUrWxSSFX5Ut5fBOWluprQWHMps5G1QwP92LtjLc3YsMzq1sk8c1tKkCyeEfoIdeZaDrUTMQ0ERc3xldaXbIzGUi3wtv4NIchrM2itPWjgpXOhLmZuTs7TNIskfULLmZGQLu4fQNiv4OIXafQNibSH2kC2qBqwEtHlJnmiOa0JIavTQv4quKGq3sJOKsP9wLukCllzMbvlPWrKPnYuk8A5nY0MZwgDwqhonGE0w2tXCwwYmdQWluprQWpQeccEWngdwPcNnPbqqf(QNOAL2CPKsHBzjZmOAjfoImTrMsHxlVrM2C2YOZc6WPb0J2YEkMZYsMzWxS4fYy88U1ddcgVo1r7cj9l04fC9IfVqgJN3zlJolOdNgqpAl7PyoySov4fQNiv4JxNf0jsvR0EvLukCllzMbvlPWluprQWHr4v4SjnacQWx9evR0MBusPWTSKzguTKchrM2itPW1jgNGBe0T1Dujee8GBmgSYxS4f0aJbOhfb(cnEXjVyXl0jgNGBe0XLJgymaTjJ0McVq9ePc)Osii4b3ymyLQwP95kPu4wwYmdQwsHJitBKPu46eJtWnc626oQeccEWngdw5lw8IZEHoX4eCJGoUChvcbbp4gJbR8flEXMVqgJN3TEyqW41PoAxiPFHgVy7lw8Ic1tKUJkHGGhCJXGv6MeWZM7J(fBOWluprQWHMpYbbOnXY7(q1kTxoLuk8c1tKkC5HzuuGrUnGC4LncvHBzjZmOAjvR0(uusPWTSKzguTKchrM2itPWp7fYy88ozweqggTDeZxtsFHejVOhV9cnEX5VyXl0jgNGBe0T1Dujee8GBmgSsfEH6jsfonWyaAtgPnfoBsdGGk8vpr1kTpnkPu4wwYmdQwsHJitBKPu40aJbOhfb(I9xCUcVq9ePcNI59rc4Cyg)yju1kT5wLukCllzMbvlPWrKPnYukCAGXa0JIaFX(loxHxOEIuHFtgFmedWBSBSIavTs7TNOKsHBzjZmOAjfoImTrMsHtdmgGEue4l2FX5k8c1tKkCuXyaiXkiTlM0gHQAL2B3QKsHBzjZmOAjfoImTrMsHtdmgGEue4l2FX5k8c1tKk8JkHGGhCJXGvQAL2B5sjLc3YsMzq1skCezAJmLcNgyma9OiWxOX(lw9flEHoX4eCJGoUChvcbbp4gJbR8flErpE7fA8IZFXIxS5l0jgNGBe0T1rdmgG2KrA7fsK8IZErxmlBhnWyaAtgPnNLLmZGVyXl0jgNGBe0T1rpkySgihS(fBOWluprQWpQeccEWngdwPQvAVDvLukCllzMbvlPWrKPnYukCDIXj4gbDBDqZh5Ga0My5DF8cjsEHoX4eCJGUTUJkHGGhCJXGv(IfVqNyCcUrqhxUJkHGGhCJXGv(cjsEXzVOlMLTdA(iheG2elV7dNLLmZGVyXlKX45DRhgemEDQJ2fs6xO1lgVofq1R1PbbqmYK3okM3hjaA(iheO5Guz)cn2FXYPWluprQWPyEFKaO5JCqGMdsLTQvAVLBusPWTSKzguTKchrM2itPWPbgdqpkc8fx2FXQVyXlKX45DqZh5GaOGyoI5RjPk8c1tKkCO5JuoyTQvAV9CLukCllzMbvlPWluprQWrfJbkuprcydTv4SH2GS8McxgByqqbOhfbQAvRWLXggeua6rrGkPuAVvjLc3YsMzq1skCezAJmLcNgyma9OiWxC5fCPWluprQW9MpiCacEaddnqaKyLNQAL2CPKsHBzjZmOAjfoImTrMsHF2l6Izz7GMpYbbqrsX869ePZYsMzWxirYl6XBVqJxS98xirYl0jgNGBe0T1Dujee8GBmgSYxS4fN9czmEENmlcidJ2oI5RjPk8c1tKkCAGXa0MmsBQwP9QkPu4fQNiv40JcgRbYbRv4wwYmdQws1QwHNwFyeGEq6IbkupCAkPuAVvjLcVq9ePcxEygffyKBdihEzJqv4wwYmdQws1kT5sjLc3YsMzq1skCezAJmLchfbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxSD1xirYlo7f2Ph2ORBq36HXtmifqN7HbcEaft3itqaumVpYjVv4fQNiv43KXhdXa8g7gRiqvR0EvLukCllzMbvlPWrKPnYukCuemySoDumVpsa08roiqZbPY2rmFnj9fA8cU5KxirYlqrWGX60rX8(ibqZh5GanhKkBhX81K0xC5fB5sHxOEIuHtX8(ibComJFSeQAL2CJskfULLmZGQLu4iY0gzkf(MVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxWTVyXlKX45DqZh5GaOIXM82rmFnj9fB8cjsEXMVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxSD7lw8IZEHmgpVdA(iheavm2K3oI5RjPVyJxirYlqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl2Ynk8c1tKkCuXyaiXkiTlM0gHQAL2NRKsHBzjZmOAjfEH6jsfoQymqH6jsaBOTchrM2itPWPbgdqpkc8f7Vy7lw8InFbkcgmwNouXyaiXkiTlM0gH6iMVMK(IlVOq9ePJEuWynqoyTdv0g0J3EHejVyZx0fZY2jpmJIcmYTbKdVSrOollzMbFXIxGIGbJ1PtEygffyKBdihEzJqDeZxtsFXLxuOEI0rpkySgihS2HkAd6XBVyJxSHcNn0gKL3u4Yyddcka9OiqvR0E5usPWTSKzguTKchrM2itPW38fB(cuemySoDOIXaqIvqAxmPnc1rmFnj9fA8Ic1tKoO5JuoyTdv0g0J3EXgVyXl28fOiyWyD6qfJbGeRG0UysBeQJy(As6l04ffQNiD0JcgRbYbRDOI2GE82l24fB8IfVqgJN3LwFyeGEq6I5iMVMK(cnEbQOnOhVPWluprQWpQeccEWngdwPQvAFkkPu4wwYmdQwsHJitBKPu4Yy88U06dJa0dsxmhX81K0xC5fN)IfVGgyma9OiWxS)Itu4fQNiv4umVpsa08roiqZbPYw1kTpnkPu4wwYmdQwsHJitBKPu4Yy88U06dJa0dsxmhX81K0xC5ffQNiDumVpsa08roiqZbPY2HkAd6XBVqRxCI7CfEH6jsfofZ7JeanFKdc0CqQSvTsBUvjLc3YsMzq1skCezAJmLcxgJN3bnFKdcGcI5W0FXIxqdmgGEue4lUS)Ivv4fQNiv4qZhPCWAvR0E7jkPu4wwYmdQwsHxOEIuHJkgduOEIeWgARWzdTbz5nfUm2WGGcqpkcu1Qw1k8cRpcIchF8CVQw1kf]] )


end
