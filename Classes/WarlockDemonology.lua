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

        potion = "battle_potion_of_intellect",

        package = "Demonology",
    } )

    spec:RegisterPack( "Demonology", 20190709.1700, [[dGKaKbqivuweQKIhHkjxsjkP2Ks4tQivyukfDkLcRsfj5vKsMLsIBPIe7Ik)Iu0WurCmLsldvQNPK00qLW1ur12uIkFtfPmoLOuNdvIwNsuI5PsCpvyFKchujkjlujYdrLuAIOsQUOksfDsvKuSsvsZufjL2jPu)ufjvnuvKk9uOAQePUQksv9vvKuzVK8xGbt4Wswmr9yitg0LPSzu1NvPgTs1Pv8AIKzJYTPQDl63cdNuDCvKQSCephPPl11HY2rf9DLuJxjkopQW6vIQMprSFvTARsAfoSAtPn3NSLlp50oHlDBpTTlBUGlv4nh6McxVqsv3McplVPW56MpYGf3COW1loyrbvsRWPbgbzk89U1PllAQ5907yYou41KoEmw1tKisX3AshpstfUm2W6tnPswHdR2uAZ9jB5YtoTt4s32tB7YMlwvHt1nKsBUxULtHVpqOLkzfo0Oifox9cUU5JmyXnhV4uxrybsQ)kx9I9U1PllAQ5907yYou41KoEmw1tKisX3AshpsZ)kx9IRymoEbxUYl4(KTC5loLxS90wwo5K)6FLREbx7EL3gDz5VYvV4uEbUUXyV4uBGKY9x5QxCkV40NAVqgJN3LwVBeGEq6I5W0FXK02k4lc(xqmFn5K3VGRLR)IE82l4dYl026DJ8It3G0f7ffQhoTxOVxuZ9x5QxCkV4uFY44fedfEVLWxW1nFKYbRFHoXofu4LR(fd)lM(fd9fts7k7xSzqEXErGOI2VGpiVqoOuJUH7VYvV4uEXPBS2iVaF03J8ffJfRn4l0j2PGcVC1VOJxOtc0lMK2v2VGRB(iLdw7(RC1loLxSSccFrOBPrEb(EbJ1VyPG1ViWA6aTxe8VqoO0xWp37n9fD8IQFbZkA)IBRFrK2l8bXEbDViq3FLREXP8ItFQ9cUME8gOdaCmUMxSPTm6gQn4lSefyzBKxyjCJxqQE3iVO3R8fCnDrUT21J3aDaGJX18InTLr3qTbFbcJqSSFrxKBRpDqFb0QEFJx0XlkoJb(cBzqgLoCAVqgJKtE)IG)fKcnf7fCTCDQtHRtc(HzkCU6fCDZhzWIBoEXPUIWcKu)vU6f7DRtxw0uZ7P3XKDOWRjD8ySQNirKIV1KoEKM)vU6fxXyC8cUCLxW9jB5YxCkVy7PTSCYj)1)kx9cU29kVn6YYFLREXP8cCDJXEXP2ajL7VYvV4uEXPp1EHmgpVlTE3ia9G0fZHP)IjPTvWxe8VGy(AYjVFbxlx)f94TxWhKxOT17g5fNUbPl2lkupCAVqFVOM7VYvV4uEXP(KXXligk8ElHVGRB(iLdw)cDIDkOWlx9lg(xm9lg6lMK2v2VyZG8I9IarfTFbFqEHCqPgDd3FLREXP8It3yTrEb(OVh5lkglwBWxOtStbfE5QFrhVqNeOxmjTRSFbx38rkhS29x5QxCkVyzfe(Iq3sJ8c89cgRFXsbRFrG10bAVi4FHCqPVGFU3B6l64fv)cMv0(f3w)IiTx4dI9c6ErGU)kx9It5fN(u7fCn94nqha4yCnVytBz0nuBWxyjkWY2iVWs4gVGu9UrErVx5l4A6ICBTRhVb6aahJR5fBAlJUHAd(cegHyz)IUi3wF6G(cOv9(gVOJxuCgd8f2YGmkD40EHmgjN8(fb)lifAk2l4A56u3F9VYvV405YyiS2GVq24dI9cu4LR(fY29Ku3lwwHqMEtFrg5PSxeppg7ffQNiPVisghU)kx9Ic1tKuNoXqHxU6dEwrL6VYvVOq9ej1Ptmu4LRwRdn5Ja(x5QxuOEIK60jgk8YvR1HMf2T3YU6jY)AH6jsQtNyOWlxTwhAsX8(ib6w)x5QxuOEIK60jgk8YvR1HMtMgbanFK0vg(JUyw2UjtJaGMpsQZYsMzW)kx9Ic1tKuNoXqHxUATo0KMLoDpAaTRM(xluprsD6edfE5Q16qt9ONi)RfQNiPoDIHcVC1ADOPES2ia6OVh5kd)HmgpVB9WGGXRtD0UqsPX2fYy88oO5JCqauqmhmwN)1c1tKuNoXqHxUATo0eA(iLdwVYWFihuQejfQNiDqZhPCWAhQO9Xj)1c1tKuNoXqHxUATo0KUxWynqoy9kd)XzYbLkrsH6jsh08rkhS2HkARXj)1)kx9ItNlJHWAd(cJtJWXl6XBVO3TxuOoiVyOVO4SgwjZm3FTq9ej9GQBmgGfiP(RfQNiPADOPE0tKRm8h6w7GMpYbbAoiv2Uc1dN2InpRlMLTlTE3ia9G0fZzzjZmOejYy88U06DJa0dsxmhM(gsK0J3aDaGJDz1t(RfQNiPADOjg1atBE6kd)HU1oO5JCqGMdsLTRq9WPjrspEd0bao2LJTN)xluprs16qtzJqnIutEVYWFOBTdA(iheO5Guz7kupCAsK0J3aDaGJD5y75)1c1tKuTo0uMfbeWJr4yLH)q3Ah08roiqZbPY2vOE40KiPhVb6aah7YX2Z)RfQNiPADOj)qmzweWvg(dDRDqZh5GanhKkBxH6HttIKE8gOdaCSlhBp)VwOEIKQ1HMRdcdYPnjGy0iRezRm8h6w7GMpYbbAoiv2Uc1dNMej94nqha4yxo2E(FTq9ejvRdnjJUoZatcO6fYwz4p0T2bnFKdc0CqQSDfQhonjs6XBGoaWXUCS98)AH6jsQwhAIkgduOEIeWgAVswE7aIIee6wAKvg(JUyw2oO5JCqauKumVEpr6SSKzgCrpE7YQNS4muemySoDumVpsa08roiqZbPY2rmFnj9VwOEIKQ1HM7vcbbp4gJbRCLH)OwEJmT5SLrNf0HtdOhTL9umhPsPw0J3UC(cAGXa09Ia1G7fYy88oBz0zbD40a6rBzpfZbJ15czmEE36HbbJxN6ODHK6YQlotNyCcUrq3w3ELqqWdUXyWkxCMoX4eCJGoUD7vcbbp4gJbR8VwOEIKQ1HMqZhPCW6vg(dAGXa09IaVCS6czmEEh08roiakiMdtFHmgpVdA(iheafeZr7cj1bx8xluprs16qZXRZc6e5kd)rT8gzAZzlJolOdNgqpAl7PyosLsTqgJN3TEyqW41PoAxiP0G7fYy88oBz0zbD40a6rBzpfZrmFnj9sH6jshDVGXAGCWANTmgcRnqpEBXMN1fZY2bnFKdcGIKI517jsNLLmZGsKGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPASL7n(RfQNiPADOjmc)kd)Xz9GKAY7f94nqha4yAS6jlO6gJb6ICBn1nEDwqNiVW9FTq9ejvRdnLhMrrbg52aYHx2i0vg(JA5nY0MZwgDwqhonGE0w2tXCKkLsJtw0J3US9KfuDJXaDrUTM6gVolOtKx4EHmgpVdsScs7IjLrOoI5RjPl6Izz7sR3ncqpiDXCwwYmd(xluprs16qtO5JCqaAtS8U3xz4p2ugJN3TEyqW41PoAxiPUSCsKiJXZ7GMpYbb0J1gXHPVHejuDJXaDrUTM6gVolOtKx4(VwOEIKQ1HMOIXafQNibSH2RKL3osR3ncqpiDXwz4p6Izz7sR3ncqpiDXCwwYmdUGQBmgOlYT1u341zbDI8Yb3)1c1tKuTo0evmgOq9ejGn0ELS82X41zbDICLH)GQBmgOlYT1u341zbDIuJT)1c1tKuTo08gRiWPsqWdQL3irVVYWFOBTdA(iheO5Guz7kupCAsK0J3aDaGJD5y1t(RfQNiPADO5nz8XqmaVXUXkcCLH)yZE8gOdaCmn2Y9jsK0J3aDaGJDbfbdgRthfZ7JeanFKdc0CqQSDeZxts1A75sKGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPx2U6g)1c1tKuTo0KI59rc4Cyg)yjCLH)afbdgRthfZ7JeanFKdc0CqQSDeZxts1GlorIeuemySoDumVpsa08roiqZbPY2rmFnj9YwU)RfQNiPADOjQymaKyfK2ftkJqxz4p2efbdgRthfZ7JeanFKdc0CqQSDeZxtsVWLlKX45DqZh5GaOIXM82rmFnjDdjs2efbdgRthfZ7JeanFKdc0CqQSDeZxtsVSD7IZKX45DqZh5GaOIXM82rmFnjDdjsqrWGX60rX8(ibqZh5GanhKkBhX81Kun2Yf)1c1tKuTo0S3nawkhyjeWheKTYWFiJXZ7igskMrPa(GGmhXku)xluprs16qt5HzuuGrUnGC4Lnc9VwOEIKQ1HM7vcbbp4gJbRCLH)yZA5nY0MtUygpgdmjNbQ6jsNLLmZGsK0fZY2bnFKdcGIKI517jsNLLmZGBSqNyCcUrq3w3ELqqWdUXyWkxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPx4(VYvVG7to5KL1uDJXa7fTTxm0xq3dsVxj8f8b5f9U9cur7x0J3ErW)cUU5JCqVqAoiv2Uxi9U9IjBl7xm0x0XlIKXXlKT7jFbQO9K3Vy4Fr9cKr6AYxKyEzJ8IG)fJxN(I1dJ9cz7fbw)czoErVBVWs4lc(x072lqfTD)1c1tKuTo0KI59rcGMpYbbAoiv2Rm8h0aJbO7fbEz1fBEwxmlBh08roiakskMxVNiDwwYmdkrImgpVB9WGGXRtD0UqsP141PaQEToniaIrM82rX8(ibqZh5GanhKkBnowUf94nqhGXRtDfJ5iMVMKEbv0g0J32qIKE8gOdaCSlCFYFTq9ejvRdn1J1gbqh99ixz4pKX45DRhgemEDQJ2fskno4EHmgpVdA(iheafeZr7cj1LdUxiJXZ7GMpYbb0J1gXbJ15cQUXyGUi3wtDJxNf0jYlC)xluprs16qtye(vg(JUyw2oyeENLLmZGligpXO7LmZw0J3aDaGJPXMWODWi8oI5RjPAT6jB8xluprs16qZ9kHGGhCJXGvUYWFqdmgGUxeOghNlrYM0aJbO7fbQXXQlqrWGX60HkgdajwbPDXKYiuhX81Kun4IfBIIGbJ1PJI59rcGMpYbbAoiv2oI5RjPAW9jsKSjkcgmwNokM3hjaA(iheO5Guz7iMVMKE5gbpvCVOlMLTdA(iheafjfZR3tKollzMbLibfbdgRthfZ7JeanFKdc0CqQSDeZxtsVCJGNkUyXzDXSSDqZh5GaOiPyE9EI0zzjZm4gBSyZZ6Izz7OyEFKaohMXpwcDwwYmdkrckcgmwNokM3hjGZHz8JLqhX81KunwDJn(RfQNiPADOjnWyaAtgPSvg(dAGXa09IaVC(czmEEh08roiakiMJ2fsQlhC)xluprs16qtO5Juoy9kd)bnWya6ErGxowDHmgpVdA(iheafeZHPVyZnrrWGX60rX8(ibqZh5GanhKkBhX81K0llNejOiyWyD6OyEFKaO5JCqGMdsLTJy(AsQgCZ9IZQL3itBo6EbJ1uG80MZYsMzWnKirgJN3bnFKdcGcI5ODHKsJJvLirgJN3bnFKdcGcI5iMVMKE5Cjs6XBGoaWXUW95sKiJXZ7O7fmwtbYtBoI5RjPB8xluprs16qt(aHrniOwEJmTbKTYVYWFCMU1oO5JCqGMdsLTRq9WP9xluprs16qtDmYWZXK3azwr7)AH6jsQwhAkZIaccEqVBalnph)1c1tKuTo0efjYYMuTbb8SYBRm8hNbJ2HIezztQ2GaEw5nGmgjDeZxtsxCwH6jshksKLnPAdc4zL3Ctc4zZ9EV4mDRDqZh5GanhKkBxH6Ht7VwOEIKQ1HMOIXafQNibSH2RKL3oKXggeua6ErG)1)AH6jsQtgByqqbO7fbE4nFq4ae8aggAGaiXkpDLH)GgymaDViWlC)xluprsDYyddckaDViqTo0KgymaTjJu2kd)XzDXSSDqZh5GaOiPyE9EI0zzjZmOej94nn2EUej6eJtWnc6262ReccEWngdw5IZKX45DYSiGmmA7iMVMK(xluprsDYyddckaDViqTo0KUxWynqoy9F9VwOEIK6GOibHULg5yVsii4b3ymyLRWM0ai4XQNSYWFulVrM2C2YOZc6WPb0J2YEkMZYsMzW)AH6jsQdIIee6wAeTo0C86SGorUYWFulVrM2C2YOZc6WPb0J2YEkMZYsMzWfYy88U1ddcgVo1r7cjLgCVqgJN3zlJolOdNgqpAl7PyoySo)RfQNiPoiksqOBPr06qtye(vytAae8y1t(RfQNiPoiksqOBPr06qZ9kHGGhCJXGvUYWFOtmob3iOBRBVsii4b3ymyLlObgdq3lcuJtwOtmob3iOJBhnWyaAtgPS)AH6jsQdIIee6wAeTo0eA(iheG2elV79vg(dDIXj4gbDBD7vcbbp4gJbRCXz6eJtWnc642Txjee8GBmgSYfBkJXZ7wpmiy86uhTlKuASDrH6js3ELqqWdUXyWkDtc4zZ9EVXFTq9ej1brrccDlnIwhAkpmJIcmYTbKdVSrO)1c1tKuhefji0T0iADOjnWyaAtgPSvytAae8y1twz4potgJN3jZIaYWOTJy(AsQej94nnoFHoX4eCJGUTU9kHGGhCJXGv(xluprsDquKGq3sJO1HMumVpsaNdZ4hlHRm8h0aJbO7fbEC(FTq9ej1brrccDlnIwhAEtgFmedWBSBSIaxz4pObgdq3lc848)AH6jsQdIIee6wAeTo0evmgasScs7IjLrORm8h0aJbO7fbEC(FTq9ej1brrccDlnIwhAUxjee8GBmgSYvg(dAGXa09Iapo)VwOEIK6GOibHULgrRdn3ReccEWngdw5kd)bnWya6ErGACS6cDIXj4gbDC72ReccEWngdw5IE8MgNVytDIXj4gbDBD0aJbOnzKYKi5SUyw2oAGXa0MmszollzMbxOtmob3iOBRJUxWynqoy9g)vU6fCFYjNSSMQBmgyVOT9IH(c6Eq69kHVGpiVO3TxGkA)IE82lc(xW1nFKd6fsZbPY29cP3TxmzBz)IH(IoErKmoEHSDp5lqfTN8(fd)lQxGmsxt(IeZlBKxe8Vy860xSEySxiBViW6xiZXl6D7fwcFrW)IE3EbQOT7VwOEIK6GOibHULgrRdnPyEFKaO5JCqGMdsL9kd)HoX4eCJGUToO5JCqaAtS8U3LirNyCcUrq3w3ELqqWdUXyWkxOtmob3iOJB3ELqqWdUXyWkLi5SUyw2oO5JCqaAtS8U3DwwYmdUqgJN3TEyqW41PoAxiP0A86uavVwNgeaXitE7OyEFKaO5JCqGMdsLTghl3FTq9ej1brrccDlnIwhAcnFKYbRxz4pObgdq3lc8YXQlKX45DqZh5GaOGyoI5RjP)1c1tKuhefji0T0iADOjQymqH6jsaBO9kz5TdzSHbbfGUxe4F9VwOEIK6gVolOtKhJxNf0jYvg(JnLX45DRhgemEDQJ2fsknowUfBsdmgGUxe4LvLirNyCcUrq3whQymaKyfK2ftkJqLirgJN3TEyqW41PoAxiP04GlLirNyCcUrq3wN8WmkkWi3gqo8YgHkrYMNPtmob3iOBRBVsii4b3ymyLlotNyCcUrqh3U9kHGGhCJXGvUXglotNyCcUrq3w3ELqqWdUXyWkxCMoX4eCJGoUD7vcbbp4gJbRCHmgpVdA(iheqpwBehmwNBirYM94nqha4yxwDHmgpVB9WGGXRtD0UqsPXjBirYM6eJtWnc642HkgdajwbPDXKYi0fYy88U1ddcgVo1r7cjLgCV4SUyw2oO5JCqauXytE7SSKzgCJ)AH6jsQB86SGorQ1HM3KXhdXa8g7gRiWvg(duemySoDumVpsa08roiqZbPY2rmFnj9Y2vLi5m70dB01nOB7QCV6YXL)1c1tKu341zbDIuRdnrfJbGeRG0Uysze6kd)XMOiyWyD6OyEFKaO5JCqGMdsLTJy(As6fUCHmgpVdA(iheavm2K3oI5RjPBirYMOiyWyD6OyEFKaO5JCqGMdsLTJy(As6LTBxCMmgpVdA(iheavm2K3oI5RjPBirckcgmwNokM3hjaA(iheO5Guz7iMVMKQXwU4VwOEIK6gVolOtKADOjfZ7JeanFKdc0CqQS)RfQNiPUXRZc6ePwhAUxjee8GBmgSYvg(dAGXa09Ia1448)AH6jsQB86SGorQ1HM7vcbbp4gJbRCLH)GgymaDViqnowDXMBUPoX4eCJGoUD7vcbbp4gJbRuIezmEE36HbbJxN6ODHKsJJv3yHmgpVB9WGGXRtD0UqsDHl3qIeuemySoDumVpsa08roiqZbPY2rmFnj9YXncEQ4wIezmEEh08roiGES2ioI5RjPACJGNkU34VwOEIK6gVolOtKADOj08rkhSELH)qNyCcUrq3w3ELqqWdUXyWkxqdmgGUxeOghBxSPmgpVB9WGGXRtD0UqsD5yvjs0jgNGBe0TQBVsii4b3ymyLBSGgymaDViWlCXczmEEh08roiakiMdt)VwOEIK6gVolOtKADOjfZ7JeW5Wm(Xs4kd)XMOiyWyD6OyEFKaO5JCqGMdsLTJy(AsQgCXjlO6gJb6ICBn1nEDwqNiVCW9gsKGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPx2Y9FTq9ej1nEDwqNi16qt5HzuuGrUnGC4LncDLH)afbdgRthfZ7JeanFKdc0CqQSDeZxts1Gl)RfQNiPUXRZc6ePwhAYhimQbb1YBKPnGSv()AH6jsQB86SGorQ1HM6yKHNJjVbYSI2)1c1tKu341zbDIuRdnLzrabbpO3nGLMNJ)AH6jsQB86SGorQ1HMOirw2KQniGNvEBLH)4my0ouKilBs1geWZkVbKXiPJy(As6IZkupr6qrISSjvBqapR8MBsapBU37fuDJXaDrUTM6gVolOtKxo)VwOEIK6gVolOtKADOjnWyaAtgPSvg(dAGXa09IaVC(czmEEh08roiakiMJ2fsQlhC)xluprsDJxNf0jsTo0eA(iLdwVYWFqdmgGUxe4LJvxiJXZ7GMpYbbqbXCy6l2ugJN3bnFKdcGcI5ODHKsJJvLirgJN3bnFKdcGcI5iMVMKE54gbpvN7oTn(RfQNiPUXRZc6ePwhAcJWVcIdeZaDrUTMESDfFTmaehiMb6ICBn940wz4pigpXO7LmZ(RfQNiPUXRZc6ePwhAIkgduOEIeWgAVswE7qgByqqbO7fb(x)RfQNiPU06DJa0dsxSduXyGc1tKa2q7vYYBhP17gbOhKUyazSHbN8ELH)afbdgRtxA9Ura6bPlMJy(As6fUp5VwOEIK6sR3ncqpiDX06qtuXyGc1tKa2q7vYYBhP17gbOhKUyGc1dN2kd)HmgpVlTE3ia9G0fZHP)x)RfQNiPU06DJa0dsxmqH6Ht7qEygffyKBdihEzJq)RfQNiPU06DJa0dsxmqH6HttRdnVjJpgIb4n2nwrGRm8hOiyWyD6OyEFKaO5JCqGMdsLTJy(As6LTRkrYz2Ph2ORBq32v5E1LJl)RfQNiPU06DJa0dsxmqH6HttRdnPyEFKaohMXpwcxz4pqrWGX60rX8(ibqZh5GanhKkBhX81Kun4ItKibfbdgRthfZ7JeanFKdc0CqQSDeZxtsVSL7)AH6jsQlTE3ia9G0fduOE4006qtuXyaiXkiTlMugHUYWFSjkcgmwNokM3hjaA(iheO5Guz7iMVMKEHlxiJXZ7GMpYbbqfJn5TJy(As6gsKSjkcgmwNokM3hjaA(iheO5Guz7iMVMKEz72fNjJXZ7GMpYbbqfJn5TJy(As6gsKGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPASLl(RfQNiPU06DJa0dsxmqH6HttRdnrfJbkuprcydTxjlVDiJnmiOa09Iaxz4pObgdq3lc8y7InrrWGX60HkgdajwbPDXKYiuhX81K0lfQNiD09cgRbYbRDOI2GE8MejB2fZY2jpmJIcmYTbKdVSrOollzMbxGIGbJ1PtEygffyKBdihEzJqDeZxtsVuOEI0r3lySgihS2HkAd6XBBSXFTq9ej1LwVBeGEq6IbkupCAADO5ELqqWdUXyWkxz4p2CtuemySoDOIXaqIvqAxmPmc1rmFnjvJc1tKoO5JuoyTdv0g0J32yXMOiyWyD6qfJbGeRG0UyszeQJy(AsQgfQNiD09cgRbYbRDOI2GE82gBSqgJN3LwVBeGEq6I5iMVMKQbQOnOhV9xluprsDP17gbOhKUyGc1dNMwhAsX8(ibqZh5GanhKk7vg(dzmEExA9Ura6bPlMJy(As6LZxqdmgGUxe4Xj)1c1tKuxA9Ura6bPlgOq9WPP1HMumVpsa08roiqZbPYELH)qgJN3LwVBeGEq6I5iMVMKEPq9ePJI59rcGMpYbbAoiv2ourBqpEtRtCN)xluprsDP17gbOhKUyGc1dNMwhAcnFKYbRxz4pKX45DqZh5GaOGyom9f0aJbO7fbE5y1)AH6jsQlTE3ia9G0fduOE4006qtuXyGc1tKa2q7vYYBhYyddckaDViW)6FTq9ej1LwVBeGEq6IbKXggCY7J06DJa0dsxSvg(dAGXa09Ia1448fBEwxmlBNES2ia6OVhPZYsMzqjsKX45DqZh5GaOGyom9n(RfQNiPU06DJa0dsxmGm2WGtER1HMOIXaqIvqAxmPmc9VwOEIK6sR3ncqpiDXaYyddo5TwhAUxjee8GBmgSYvg(duemySoDOIXaqIvqAxmPmc1rmFnjvJTl7f0aJbO7fbQXXQ)1c1tKuxA9Ura6bPlgqgByWjV16qt9yTra0rFpYvg(dzmEE36HbbJxN6ODHKsJdUxiJXZ7GMpYbbqbXC0UqsD5G7fYy88oO5JCqa9yTrCWyDUGgymaDViqnow9VwOEIK6sR3ncqpiDXaYyddo5TwhAUxjee8GBmgSYvg(dAGXa09Ia1448)AH6jsQlTE3ia9G0fdiJnm4K3ADOjQymqH6jsaBO9kz5TdzSHbbfGUxeOcNtJqNivAZ9jB5Yt4ITNMJBU3EUcFDrYjVPk8tnE9G0g8fl7xuOEI8fSH2u3FvHZgAtvsRWhVolOtKkPvAVvjTc3YsMzq1skCezAJmLcFZxiJXZ7wpmiy86uhTlKuVqJJxSCVyXl28f0aJbO7fb(IlVy1xirYl0jgNGBe0T1HkgdajwbPDXKYi0xirYlKX45DRhgemEDQJ2fsQxOXXl4YxirYl0jgNGBe0T1jpmJIcmYTbKdVSrOVqIKxS5lo7f6eJtWnc6262ReccEWngdw5lw8IZEHoX4eCJGoUD7vcbbp4gJbR8fB8InEXIxC2l0jgNGBe0T1Txjee8GBmgSYxS4fN9cDIXj4gbDC72ReccEWngdw5lw8czmEEh08roiGES2ioySoFXgVqIKxS5l6XBGoaWXEXLxS6lw8czmEE36HbbJxN6ODHK6fA8ItEXgVqIKxS5l0jgNGBe0XTdvmgasScs7IjLrOVyXlKX45DRhgemEDQJ2fsQxOXl4(flEXzVOlMLTdA(iheavm2K3ollzMbFXgk8c1tKk8XRZc6ePQvAZTsAfULLmZGQLu4iY0gzkfokcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVy7QVqIKxC2lStpSrx3GU1dJNyqkGo3dde8akMUrMGaOyEFKtERWluprQWVjJpgIb4n2nwrGQwP9QkPv4wwYmdQwsHJitBKPu4B(cuemySoDumVpsa08roiqZbPY2rmFnj9fxEbx(IfVqgJN3bnFKdcGkgBYBhX81K0xSXlKi5fB(cuemySoDumVpsa08roiqZbPY2rmFnj9fxEX2TVyXlo7fYy88oO5JCqauXytE7iMVMK(InEHejVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFHgVylxOWluprQWrfJbGeRG0UyszeQQvAZfkPv4fQNiv4umVpsa08roiqZbPYwHBzjZmOAjvR0(CL0kCllzMbvlPWrKPnYukCAGXa09IaFHghV4CfEH6jsf(ELqqWdUXyWkvTs7LtjTc3YsMzq1skCezAJmLcNgymaDViWxOXXlw9flEXMVyZxS5l0jgNGBe0XTBVsii4b3ymyLVqIKxiJXZ7wpmiy86uhTlKuVqJJxS6l24flEHmgpVB9WGGXRtD0Uqs9IlVGlFXgVqIKxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4YXlUrWxCQEb3VqIKxiJXZ7GMpYbb0J1gXrmFnj9fA8IBe8fNQxW9l2qHxOEIuHVxjee8GBmgSsvR0(0usRWTSKzguTKchrM2itPW1jgNGBe0T1Txjee8GBmgSYxS4f0aJbO7fb(cnoEX2xS4fB(czmEE36HbbJxN6ODHK6fxoEXQVqIKxOtmob3iOBv3ELqqWdUXyWkFXgVyXlObgdq3lc8fxEbx8IfVqgJN3bnFKdcGcI5W0v4fQNiv4qZhPCWAvR0EzRKwHBzjZmOAjfoImTrMsHV5lqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl4ItEXIxq1ngd0f52AQB86SGor(IlhVG7xSXlKi5fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6lU8ITCRWluprQWPyEFKaohMXpwcvTsBUujTc3YsMzq1skCezAJmLchfbdgRthfZ7JeanFKdc0CqQSDeZxtsFHgVGlv4fQNiv4YdZOOaJCBa5WlBeQQvAV9eL0k8c1tKkC(aHrniOwEJmTbKTYRWTSKzguTKQvAVDRsAfEH6jsfUogz45yYBGmROTc3YsMzq1sQwP9wUvsRWluprQWLzrabbpO3nGLMNdfULLmZGQLuTs7TRQKwHBzjZmOAjfoImTrMsHF2lGr7qrISSjvBqapR8gqgJKoI5RjPVyXlo7ffQNiDOirw2KQniGNvEZnjGNn379lw8cQUXyGUi3wtDJxNf0jYxC5fNRWluprQWrrISSjvBqapR8MQvAVLlusRWTSKzguTKchrM2itPWPbgdq3lc8fxEX5VyXlKX45DqZh5GaOGyoAxiPEXLJxWTcVq9ePcNgymaTjJuMQvAV9CL0kCllzMbvlPWrKPnYukCAGXa09IaFXLJxS6lw8czmEEh08roiakiMdt)flEXMVqgJN3bnFKdcGcI5ODHK6fAC8IvFHejVqgJN3bnFKdcGcI5iMVMK(IlhV4gbFXP6fN7oTxSHcVq9ePchA(iLdwRAL2BxoL0kCllzMbvlPWluprQWHr4v4ioqmd0f52AQs7TkCFTmaehiMb6ICBnvHFAkCezAJmLcNy8eJUxYmt1kT3EAkPv4wwYmdQwsHxOEIuHJkgduOEIeWgARWzdTbz5nfUm2WGGcq3lcu1QwHNwVBeGEq6IbKXggCYBL0kT3QKwHBzjZmOAjfoImTrMsHtdmgGUxe4l044fN)IfVyZxC2l6Izz70J1gbqh99iDwwYmd(cjsEHmgpVdA(iheafeZHP)Inu4fQNiv4P17gbOhKUyQwPn3kPv4fQNiv4OIXaqIvqAxmPmcvHBzjZmOAjvR0EvL0kCllzMbvlPWrKPnYukCuemySoDOIXaqIvqAxmPmc1rmFnj9fA8ITl7xS4f0aJbO7fb(cnoEXQk8c1tKk89kHGGhCJXGvQAL2CHsAfULLmZGQLu4iY0gzkfUmgpVB9WGGXRtD0Uqs9cnoEb3VyXlKX45DqZh5GaOGyoAxiPEXLJxW9lw8czmEEh08roiGES2ioySoFXIxqdmgGUxe4l044fRQWluprQW1J1gbqh99ivTs7ZvsRWTSKzguTKchrM2itPWPbgdq3lc8fAC8IZv4fQNiv47vcbbp4gJbRu1kTxoL0kCllzMbvlPWluprQWrfJbkuprcydTv4SH2GS8McxgByqqbO7fbQAvRWHgFHXAL0kT3QKwHxOEIuHt1ngdWcKukCllzMbvlPAL2CRKwHBzjZmOAjfoImTrMsHRBTdA(iheO5Guz7kupCAVyXl28fN9IUyw2U06DJa0dsxmNLLmZGVqIKxiJXZ7sR3ncqpiDXCy6VyJxirYl6XBGoaWXEXLxS6jk8c1tKkC9ONivTs7vvsRWTSKzguTKchrM2itPW1T2bnFKdc0CqQSDfQhoTxirYl6XBGoaWXEXLJxS9CfEH6jsfog1atBEQQvAZfkPv4wwYmdQwsHJitBKPu46w7GMpYbbAoiv2Uc1dN2lKi5f94nqha4yV4YXl2EUcVq9ePcx2iuJi1K3QwP95kPv4wwYmdQwsHJitBKPu46w7GMpYbbAoiv2Uc1dN2lKi5f94nqha4yV4YXl2EUcVq9ePcxMfbeWJr4q1kTxoL0kCllzMbvlPWrKPnYukCDRDqZh5GanhKkBxH6Ht7fsK8IE8gOdaCSxC54fBpxHxOEIuHZpetMfbu1kTpnL0kCllzMbvlPWrKPnYukCDRDqZh5GanhKkBxH6Ht7fsK8IE8gOdaCSxC54fBpxHxOEIuHVoimiN2KaIrJSsKPAL2lBL0kCllzMbvlPWrKPnYukCDRDqZh5GanhKkBxH6Ht7fsK8IE8gOdaCSxC54fBpxHxOEIuHtgDDMbMeq1lKPAL2CPsAfULLmZGQLu4iY0gzkfExmlBh08roiakskMxVNiDwwYmd(IfVOhV9IlVy1tEXIxC2lqrWGX60rX8(ibqZh5GanhKkBhX81KufEH6jsfoQymqH6jsaBOTcNn0gKL3u4quKGq3sJOAL2BprjTc3YsMzq1skCezAJmLcVwEJmT5SLrNf0HtdOhTL9umhPsPEXIx0J3EXLxC(lw8cAGXa09IaFHgVG7xS4fYy88oBz0zbD40a6rBzpfZbJ15lw8czmEE36HbbJxN6ODHK6fxEXQVyXlo7f6eJtWnc6262ReccEWngdw5lw8IZEHoX4eCJGoUD7vcbbp4gJbRuHxOEIuHVxjee8GBmgSsvR0E7wL0kCllzMbvlPWrKPnYukCAGXa09IaFXLJxS6lw8czmEEh08roiakiMdt)flEHmgpVdA(iheafeZr7cj1loEbxOWluprQWHMps5G1QwP9wUvsRWTSKzguTKchrM2itPWRL3itBoBz0zbD40a6rBzpfZrQuQxS4fYy88U1ddcgVo1r7cj1l04fC)IfVqgJN3zlJolOdNgqpAl7PyoI5RjPV4Ylkupr6O7fmwdKdw7SLXqyTb6XBVyXl28fN9IUyw2oO5JCqauKumVEpr6SSKzg8fsK8cuemySoDumVpsa08roiqZbPY2rmFnj9fA8ITC)Inu4fQNiv4JxNf0jsvR0E7QkPv4wwYmdQwsHJitBKPu4N9IEqsn59lw8IE8gOdaCSxOXlw9KxS4fuDJXaDrUTM6gVolOtKV4Yl4wHxOEIuHdJWRAL2B5cL0kCllzMbvlPWrKPnYuk8A5nY0MZwgDwqhonGE0w2tXCKkL6fA8ItEXIx0J3EXLxS9KxS4fuDJXaDrUTM6gVolOtKV4Yl4(flEHmgpVdsScs7IjLrOoI5RjPVyXl6Izz7sR3ncqpiDXCwwYmdQWluprQWLhMrrbg52aYHx2iuvR0E75kPv4wwYmdQwsHJitBKPu4B(czmEE36HbbJxN6ODHK6fxEXY9cjsEHmgpVdA(iheqpwBehM(l24fsK8cQUXyGUi3wtDJxNf0jYxC5fCRWluprQWHMpYbbOnXY7Ex1kT3UCkPv4wwYmdQwsHJitBKPu4DXSSDP17gbOhKUyollzMbFXIxq1ngd0f52AQB86SGor(IlhVGBfEH6jsfoQymqH6jsaBOTcNn0gKL3u4P17gbOhKUyQwP92ttjTc3YsMzq1skCezAJmLcNQBmgOlYT1u341zbDI8fA8ITk8c1tKkCuXyGc1tKa2qBfoBOnilVPWhVolOtKQwP92LTsAfULLmZGQLu4iY0gzkfUU1oO5JCqGMdsLTRq9WP9cjsErpEd0bao2lUC8IvprHxOEIuHFJve4uji4b1YBKO3vTs7TCPsAfULLmZGQLu4iY0gzkf(MVOhVb6aah7fA8ITCFYlKi5f94nqha4yV4YlqrWGX60rX8(ibqZh5GanhKkBhX81K0xO1l2E(lKi5fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6lU8ITR(Inu4fQNiv43KXhdXa8g7gRiqvR0M7tusRWTSKzguTKchrM2itPWrrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl4ItEHejVafbdgRthfZ7JeanFKdc0CqQSDeZxtsFXLxSLBfEH6jsfofZ7JeW5Wm(XsOQvAZ9wL0kCllzMbvlPWrKPnYuk8nFbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVGlFXIxiJXZ7GMpYbbqfJn5TJy(As6l24fsK8InFbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVy72xS4fN9czmEEh08roiaQySjVDeZxtsFXgVqIKxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPVqJxSLlu4fQNiv4OIXaqIvqAxmPmcv1kT5MBL0kCllzMbvlPWrKPnYukCzmEEhXqsXmkfWheK5iwHAfEH6jsfEVBaSuoWsiGpiit1kT5EvL0k8c1tKkC5HzuuGrUnGC4LncvHBzjZmOAjvR0MBUqjTc3YsMzq1skCezAJmLcFZxulVrM2CYfZ4XyGj5mqvpr6SSKzg8fsK8IUyw2oO5JCqauKumVEpr6SSKzg8fB8IfVqNyCcUrq3w3ELqqWdUXyWkFXIxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4Yl4wHxOEIuHVxjee8GBmgSsvR0M7ZvsRWTSKzguTKchrM2itPWPbgdq3lc8fxEXQVyXl28fN9IUyw2oO5JCqauKumVEpr6SSKzg8fsK8czmEE36HbbJxN6ODHK6fA9IXRtbu9ADAqaeJm5TJI59rcGMpYbbAoiv2VqJJxSCVyXl6XBGoaJxN6kgZrmFnj9fxEbQOnOhV9InEHejVOhVb6aah7fxEb3NOWluprQWPyEFKaO5JCqGMdsLTQvAZ9YPKwHBzjZmOAjfoImTrMsHlJXZ7wpmiy86uhTlKuVqJJxW9lw8czmEEh08roiakiMJ2fsQxC54fC)IfVqgJN3bnFKdcOhRnIdgRZxS4fuDJXaDrUTM6gVolOtKV4Yl4wHxOEIuHRhRncGo67rQAL2CFAkPv4wwYmdQwsHJitBKPu4DXSSDWi8ollzMbFXIxqmEIr3lzM9IfVOhVb6aah7fA8InFbmAhmcVJy(As6l06fREYl2qHxOEIuHdJWRAL2CVSvsRWTSKzguTKchrM2itPWPbgdq3lc8fAC8IZFHejVyZxqdmgGUxe4l044fR(IfVafbdgRthQymaKyfK2ftkJqDeZxtsFHgVGlEXIxS5lqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl4(KxirYl28fOiyWyD6OyEFKaO5JCqGMdsLTJy(As6lU8IBe8fNQxW9lw8IUyw2oO5JCqauKumVEpr6SSKzg8fsK8cuemySoDumVpsa08roiqZbPY2rmFnj9fxEXnc(It1l4IxS4fN9IUyw2oO5JCqauKumVEpr6SSKzg8fB8InEXIxS5lo7fDXSSDumVpsaNdZ4hlHollzMbFHejVafbdgRthfZ7JeW5Wm(XsOJy(As6l04fR(InEXgk8c1tKk89kHGGhCJXGvQAL2CZLkPv4wwYmdQwsHJitBKPu40aJbO7fb(IlV48xS4fYy88oO5JCqauqmhTlKuV4YXl4wHxOEIuHtdmgG2Krkt1kTx9eL0kCllzMbvlPWrKPnYukCAGXa09IaFXLJxS6lw8czmEEh08roiakiMdt)flEXMVyZxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4YlwUxirYlqrWGX60rX8(ibqZh5GanhKkBhX81K0xOXl4M7xS4fN9IA5nY0MJUxWynfipT5SSKzg8fB8cjsEHmgpVdA(iheafeZr7cj1l044fR(cjsEHmgpVdA(iheafeZrmFnj9fxEX5VqIKx0J3aDaGJ9IlVG7ZFHejVqgJN3r3lySMcKN2CeZxtsFXgk8c1tKkCO5JuoyTQvAV6wL0kCllzMbvlPWrKPnYuk8ZEHU1oO5JCqGMdsLTRq9WPPWluprQW5deg1GGA5nY0gq2kVQvAVk3kPv4fQNiv46yKHNJjVbYSI2kCllzMbvlPAL2RUQsAfEH6jsfUmlcii4b9UbS08COWTSKzguTKQvAVkxOKwHBzjZmOAjfoImTrMsHF2lGr7qrISSjvBqapR8gqgJKoI5RjPVyXlo7ffQNiDOirw2KQniGNvEZnjGNn379lw8IZEHU1oO5JCqGMdsLTRq9WPPWluprQWrrISSjvBqapR8MQvAV65kPv4wwYmdQwsHxOEIuHJkgduOEIeWgARWzdTbz5nfUm2WGGcq3lcu1QwHRtmu4LRwjTs7TkPv4fQNiv4umVpsaVX2XY2ikCllzMbvlPAL2CRKwHxOEIuHRh9ePc3YsMzq1sQwP9QkPv4wwYmdQwsHJitBKPu4Yy88U1ddcgVo1r7cj1l04fBFXIxiJXZ7GMpYbbqbXCWyDQWluprQW1J1gbqh99ivTsBUqjTc3YsMzq1skCezAJmLcxoO0xirYlkupr6GMps5G1our7xC8Itu4fQNiv4qZhPCWAvR0(CL0kCllzMbvlPWrKPnYuk8ZEHCqPVqIKxuOEI0bnFKYbRDOI2VqJxCIcVq9ePcNUxWynqoyTQvTcpTE3ia9G0fduOE40usR0ERsAfEH6jsfU8WmkkWi3gqo8YgHQWTSKzguTKQvAZTsAfULLmZGQLu4iY0gzkfokcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVy7QVqIKxC2lStpSrx3GU1dJNyqkGo3dde8akMUrMGaOyEFKtERWluprQWVjJpgIb4n2nwrGQwP9QkPv4wwYmdQwsHJitBKPu4OiyWyD6OyEFKaO5JCqGMdsLTJy(As6l04fCXjVqIKxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPV4Yl2YTcVq9ePcNI59rc4Cyg)yju1kT5cL0kCllzMbvlPWrKPnYuk8nFbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVGlFXIxiJXZ7GMpYbbqfJn5TJy(As6l24fsK8InFbkcgmwNokM3hjaA(iheO5Guz7iMVMK(IlVy72xS4fN9czmEEh08roiaQySjVDeZxtsFXgVqIKxGIGbJ1PJI59rcGMpYbbAoiv2oI5RjPVqJxSLlu4fQNiv4OIXaqIvqAxmPmcv1kTpxjTc3YsMzq1skCezAJmLcNgymaDViWxC8ITVyXl28fOiyWyD6qfJbGeRG0UyszeQJy(As6lU8Ic1tKo6EbJ1a5G1ourBqpE7fsK8InFrxmlBN8WmkkWi3gqo8YgH6SSKzg8flEbkcgmwNo5HzuuGrUnGC4Lnc1rmFnj9fxErH6jshDVGXAGCWAhQOnOhV9InEXgk8c1tKkCuXyGc1tKa2qBfoBOnilVPWLXggeua6ErGQwP9YPKwHBzjZmOAjfoImTrMsHV5l28fOiyWyD6qfJbGeRG0UyszeQJy(As6l04ffQNiDqZhPCWAhQOnOhV9InEXIxS5lqrWGX60HkgdajwbPDXKYiuhX81K0xOXlkupr6O7fmwdKdw7qfTb94TxSXl24flEHmgpVlTE3ia9G0fZrmFnj9fA8curBqpEtHxOEIuHVxjee8GBmgSsvR0(0usRWTSKzguTKchrM2itPWLX45DP17gbOhKUyoI5RjPV4Ylo)flEbnWya6ErGV44fNOWluprQWPyEFKaO5JCqGMdsLTQvAVSvsRWTSKzguTKchrM2itPWLX45DP17gbOhKUyoI5RjPV4Ylkupr6OyEFKaO5JCqGMdsLTdv0g0J3EHwV4e35k8c1tKkCkM3hjaA(iheO5GuzRAL2CPsAfULLmZGQLu4iY0gzkfUmgpVdA(iheafeZHP)IfVGgymaDViWxC54fRQWluprQWHMps5G1QwP92tusRWTSKzguTKcVq9ePchvmgOq9ejGn0wHZgAdYYBkCzSHbbfGUxeOQvTchIIee6wAeL0kT3QKwHBzjZmOAjfEH6jsf(ELqqWdUXyWkv4iY0gzkfET8gzAZzlJolOdNgqpAl7PyollzMbv4SjnacQWx9evR0MBL0kCllzMbvlPWrKPnYuk8A5nY0MZwgDwqhonGE0w2tXCwwYmd(IfVqgJN3TEyqW41PoAxiPEHgVG7xS4fYy88oBz0zbD40a6rBzpfZbJ1PcVq9ePcF86SGorQAL2RQKwHBzjZmOAjfEH6jsfomcVcNnPbqqf(QNOAL2CHsAfULLmZGQLu4iY0gzkfUoX4eCJGUTU9kHGGhCJXGv(IfVGgymaDViWxOXlo5flEHoX4eCJGoUD0aJbOnzKYu4fQNiv47vcbbp4gJbRu1kTpxjTc3YsMzq1skCezAJmLcxNyCcUrq3w3ELqqWdUXyWkFXIxC2l0jgNGBe0XTBVsii4b3ymyLVyXl28fYy88U1ddcgVo1r7cj1l04fBFXIxuOEI0Txjee8GBmgSs3KaE2CV3VydfEH6jsfo08roiaTjwE37QwP9YPKwHxOEIuHlpmJIcmYTbKdVSrOkCllzMbvlPAL2NMsAfULLmZGQLu4fQNiv40aJbOnzKYu4iY0gzkf(zVqgJN3jZIaYWOTJy(As6lKi5f94TxOXlo)flEHoX4eCJGUTU9kHGGhCJXGvQWztAaeuHV6jQwP9YwjTc3YsMzq1skCezAJmLcNgymaDViWxC8IZv4fQNiv4umVpsaNdZ4hlHQwPnxQKwHBzjZmOAjfoImTrMsHtdmgGUxe4loEX5k8c1tKk8BY4JHyaEJDJveOQvAV9eL0kCllzMbvlPWrKPnYukCAGXa09IaFXXloxHxOEIuHJkgdajwbPDXKYiuvR0E7wL0kCllzMbvlPWrKPnYukCAGXa09IaFXXloxHxOEIuHVxjee8GBmgSsvR0El3kPv4wwYmdQwsHJitBKPu40aJbO7fb(cnoEXQVyXl0jgNGBe0XTBVsii4b3ymyLVyXl6XBVqJxC(lw8InFHoX4eCJGUToAGXa0MmszVqIKxC2l6Izz7ObgdqBYiL5SSKzg8flEHoX4eCJGUTo6EbJ1a5G1VydfEH6jsf(ELqqWdUXyWkvTs7TRQKwHBzjZmOAjfoImTrMsHRtmob3iOBRdA(iheG2elV79xirYl0jgNGBe0T1Txjee8GBmgSYxS4f6eJtWnc642Txjee8GBmgSYxirYlo7fDXSSDqZh5Ga0My5DV7SSKzg8flEHmgpVB9WGGXRtD0Uqs9cTEX41PaQEToniaIrM82rX8(ibqZh5GanhKk7xOXXlwofEH6jsfofZ7JeanFKdc0CqQSvTs7TCHsAfULLmZGQLu4iY0gzkfonWya6ErGV4YXlw9flEHmgpVdA(iheafeZrmFnjvHxOEIuHdnFKYbRvTs7TNRKwHBzjZmOAjfEH6jsfoQymqH6jsaBOTcNn0gKL3u4YyddckaDViqvRAfUm2WGGcq3lcujTs7TkPv4wwYmdQwsHJitBKPu40aJbO7fb(IlVGBfEH6jsfU38bHdqWdyyObcGeR8uvR0MBL0kCllzMbvlPWrKPnYuk8ZErxmlBh08roiakskMxVNiDwwYmd(cjsErpE7fA8ITN)cjsEHoX4eCJGUTU9kHGGhCJXGv(IfV4SxiJXZ7Kzrazy02rmFnjvHxOEIuHtdmgG2Krkt1kTxvjTcVq9ePcNUxWynqoyTc3YsMzq1sQw1k806DJa0dsxmL0kT3QKwHBzjZmOAjfoImTrMsHJIGbJ1PlTE3ia9G0fZrmFnj9fxEb3NOWluprQWrfJbkuprcydTv4SH2GS8McpTE3ia9G0fdiJnm4K3QwPn3kPv4wwYmdQwsHJitBKPu4Yy88U06DJa0dsxmhMUcVq9ePchvmgOq9ejGn0wHZgAdYYBk806DJa0dsxmqH6Htt1Qw1k8cR3dIchF8CTQw1kf]] )


end
