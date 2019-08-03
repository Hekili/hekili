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

    spec:RegisterPack( "Demonology", 20190803, [[dKuQ7bqiLswKseXJuIuxsfusBsj1NubvYOuI6ukjwLsK4vkbZsjPBHOODjYVefnmvGJPIAzcjpti10qu4AkfTnvq8neLY4ubfNtfKwNseL5PICpLQ9HiDqvqjwOsPEOsePjQejDrvqfoPkOsTsevZufur7uPWpvbLYqvbv5PemvrHRQcQQVQckv7vWFv1Gr5WkwSq9yOMmKltAZe6ZcXOvPoTuRgrP61kHMnQUnr7MQFtz4IQJRer1Yb9CKMUKRJW2reFxuA8kr48QqRhrjZxLSFGdNdzeeqtPHnI6GZh6bhMdIoD(GnphfzeeQJ5AqiFWlor0GGpsniSuvP5g3ICmiKph52GczeeOgbeRbH7QYPlzzMzKUUjItytMjTLe8PAZXWrSYK2sCMbHyIMxhU9qCqanLg2iQdoFOhCyoi605d28CurfeO5koSruhYHeeUBes9qCqaPuCqyPbSLQkn34wKJa2H9bYn8IaYxAa7UQC6swMzgPRBI4e2KzsBjbFQ2CmCeRmPTeNjG8LgWoSqeHGwaw0RcyrDW5dfWita78blzrt2aKdiFPbSL07XJO0Lma5lnGrMaMqUY5a2HtdVycq(sdyKjGD4tvalMqum5ADRWp3G1Wte5aw70sheGzIaguLt7ThbWwsxQaw1sfWeniGTHw3keWo8mynCaBWvtIcy53dvtaYxAaJmbSdBo)iGbvSjLQJaSLQknp24fGLdvYeBY4PaSweW6cWAkG1oTgVaSLniGDpqeEOfGjAqal2OuLUscq(sdyKjGD4zzviGj053MdydNBzveGLdvYeBY4PaSYaSCOHbS2P14fGTuvP5XgVsaYxAaJmbSdFQcyljvl1VSh16scGTSUe5kUueGPo2i8sHaM6Ovam4u3keWQ7XbSLKAGr0kvTu)YEuRlja2Y6sKR4sragMacvVaSAGr06WffWq6u3RayLbydjwJamDjWkL2KOawmb0BpcGzIagCW9WbSL0LknfeYHMyZ1GWsdylvvAUXTihbSd7dKB4fbKV0a2Dv50LSmZmsx3eXjSjZK2sc(uT5y4iwzsBjota5lnGDyHicbTaSOxfWI6GZhkGrMa25dwYIMSbihq(sdylP3JhrPlzaYxAaJmbmHCLZbSdNgEXeG8LgWita7WNQawmHOyY16wHFUbRHNiYbS2PLoiaZebmOkN2BpcGTKUubSQLkGjAqaBdTUviGD4zWA4a2GRMefWYVhQMaKV0agzcyh2C(radQytkvhbylvvAESXlalhQKj2KXtbyTiG1fG1uaRDAnEbylBqa7EGi8qlat0GawSrPkDLeG8LgWita7WZYQqatOZVnhWgo3YQialhQKj2KXtbyLby5qddyTtRXlaBPQsZJnELaKV0agzcyh(ufWwsQwQFzpQ1LeaBzDjYvCPiatDSr4Lcbm1rRayWPUviGv3Jdylj1aJOvQAP(L9OwxsaSL1LixXLIammbeQEby1aJO1HlkGH0PUxbWkdWgsSgby6sGvkTjrbSycO3EeaZebm4G7HdylPlvAcqoG8LgWoCSekMOueGfRIgubmSjJNcWI1iTtta2HfmwZlkG5MtM3duksWbSbxT5uaZC(XeG8LgWgC1Mtt5qfBY4P2f5dDra5lnGn4QnNMYHk2KXtTWEMIMHaKV0a2GR2CAkhQytgp1c7zoerKQxt1MdiFWvBonLdvSjJNAH9mPesP5FUwaYxAaBWvBonLdvSjJNAH9mB3v4JuP50vBX9A4QxP2Df(ivAonP(eZveG8LgWgC1Mtt5qfBY4PwyptQp50BREAnffq(GR2CAkhQytgp1c7zMBzv4t78BZxTf3JjeftzBo6BzonrRbViPNxhtikMqQ08g)ydQjAn4fpThfG8bxT50uouXMmEQf2Zm3Q2Ca5dUAZPPCOInz8ulSNjsLMhB8A1wCp2O0RRbxT5jKknp24vcp0A)aa5dUAZPPCOInz8ulSNj9Eqw2p24fGCa5lnGD4yjumrPiatjrHhbSQLkGv3kGn4YGawtbSHKP5tmxtaYhC1Mt3P5kN)CdViG8bxT50f2Zm3Q28vBX9CTsivAEJ)6iC8kn4QjrxV8wkLQowtK00283e)CfkQ4QnpjhYUbVU2QgU6vcPsZB8JnNsiZR28K6tmxrxxyZ4ilRNOesP5psLM34VochVsqvoTtjDhBghzz9eLqkn)rQ08g)1r44vcraNQnNm3CL1lVvnC1RKR1Tc)CdwdpP(eZv01vmHOyY16wHFUbRHNiYx56QAP(L9Owpf9baYhC1MtxyptcQ(DPYv9rQ7dzrVh4qFrZR3e)ClRcxTf3XMXrwwprjKsZFKknVXFDeoELGQCANEApQdwVvnC1RKR1Tc)CdwdpP(eZveG8bxT50f2ZKGQFxQKUAlUNRvcPsZB8xhHJxPbxnj66L3sPu1XAIKM2M)M4NRqrfxT5j5q2n411w1WvVsivAEJFS5uczE1MNuFI5k66cBghzz9eLqkn)rQ08g)1r44vcQYPDkP7yZ4ilRNOesP5psLM34VochVsic4uT5K5MRCDvTu)YEuRN2pVjG8bxT50f2ZmwHufUy7rwTf3Z1kHuP5n(RJWXR0GRMeD9YBPuQ6ynrstBZFt8ZvOOIR28KCi7g86ARA4QxjKknVXp2CkHmVAZtQpXCfDDHnJJSSEIsiLM)ivAEJ)6iC8kbv50oL0DSzCKL1tucP08hPsZB8xhHJxjebCQ2CYCZvUUQwQFzpQ1t7N3eq(GR2C6c7zgZnd9IeWJR2I75ALqQ08g)1r44vAWvtIUE5TukvDSMiPPT5Vj(5kuuXvBEsoKDdEDTvnC1ResLM34hBoLqMxT5j1NyUIUUWMXrwwprjKsZFKknVXFDeoELGQCANs6o2moYY6jkHuA(JuP5n(RJWXReIaovBozU5kxxvl1VSh16P9ZBciFWvBoDH9mfBOgZndTAlUNRvcPsZB8xhHJxPbxnj66L3sPu1XAIKM2M)M4NRqrfxT5j5q2n411w1WvVsivAEJFS5uczE1MNuFI5k66cBghzz9eLqkn)rQ08g)1r44vcQYPDkP7yZ4ilRNOesP5psLM34VochVsic4uT5K5MRCDvTu)YEuRN2pVjG8bxT50f2ZmMBg6nXVU1xDvEC1wCpxResLM34VochVsdUAs015ALqQ08g)1r44vcQYPD6P9ZBsMrWOLs0RxElLsvhRjsAAB(BIFUcfvC1MNKdz3GxxBvdx9kHuP5n(XMtjK5vBEs9jMRORlSzCKL1tucP08hPsZB8xhHJxjOkN2PKUJnJJSSEIsiLM)ivAEJ)6iC8kHiGt1MtMBUcG8bxT50f2ZmRb5is02FOsnFCSUAlUhtikM4TOgZndLO1Gx8u0RxoxResLM34VochVsdUAs01lVLsPQJ1ejnTn)nXpxHIkUAZtYHSBWRRTQHRELqQ08g)yZPeY8QnpP(eZv01f2moYY6jkHuA(JuP5n(RJWXReuLt7us3XMXrwwprjKsZFKknVXFDeoELqeWPAZjZnx56QAP(L9OwpTFEZvaKp4QnNUWEMWopNRF7pnFW6QT4EUwjKknVXFDeoELgC1KORxElLsvhRjsAAB(BIFUcfvC1MNKdz3GxxBvdx9kHuP5n(XMtjK5vBEs9jMRORlSzCKL1tucP08hPsZB8xhHJxjOkN2PKUJnJJSSEIsiLM)ivAEJ)6iC8kHiGt1MtMBUY1v1s9l7rTEA)8MaYhC1MtxyptcQ(DPYv9rQ75gErTOnzPOhBYCIAQ28hPK0yD1wChBghzz9eLqkn)rQ08g)1r44vcQYPDkP7rDWASzCKL1tucP08hPsZB8xhHJxjOkN2PN2XMXrwwprjKsZFKknVXFDeoELqeWPAZjZZBEDvTu)YEuRN2J(aa5dUAZPlSNjbv)Uu5Q(i1DOvyibTu0tIziZEKX5R2I7lJnJJSSEIsiLM)ivAEJ)6iC8kbv50oL09O286QAP(L9OwpTh9bRaiFWvBoDH9mjO63Lkx1hPUtVBsu4tI6M8HkVXR2I7lJnJJSSEIsiLM)ivAEJ)6iC8kbv50oL09O286QAP(L9OwpTh9bRaiFWvBoDH9mjO63Lkx1hPUpl5eDUvQxVpevZjOR2I7lJnJJSSEIsiLM)ivAEJ)6iC8kbv50oL09O286QAP(L9OwpTh9bRaiFWvBoDH9mjO63Lkx1hPUxnsPLbLp2q6sSAlUVm2moYY6jkHuA(JuP5n(RJWXReuLt7us3JAZRRQL6x2JA90E0hScG8bxT50f2ZKGQFxQCvFK6oj9WFt8PLbL0vBX9LXMXrwwprjKsZFKknVXFDeoELGQCANs6EuBEDvTu)YEuRN2J(GvaKp4QnNUWEM4HZ)bxT5pVP1Q(i1DlxDfUAlUVvnC1RKR1Tc)CdwdpP(eZv06QL6POpy9wyZ4ilRNOesP5psLM34VochVsqvoTtbKp4QnNUWEMeu97sLR6Ju3hYIEpWH(IMxVj(5wwfUAlUVC1sL0Op46ARA4QxjxRBf(5gSgEs9jMROvwxdx9kfb2sRH6lQ8iedeLuFI5kA9Yvl1VSh1kPNJ6GRRQL6x2JA9e2moYY6jkHuA(JuP5n(RJWXReuLt70foV5kxxvl1VSh16P9O3eq(GR2C6c7zEpo6nXpcbhn(QT4(qwkSlnPlro3Onj6NBL6vp8eC8fxxTupT5AQrWF69arKg16ycrXKUe5CJ2KOFUvQx9WtilRVoMqumLT5OVL50eTg8INIE9w5qLKpcgLoNUhh9M4hHGJgF9w5qLKpcgLIkDpo6nXpcbhnoG8bxT50f2ZePsZJnETAlUtnc(tVhi60E0RJjeftivAEJFSb1er(6ycrXesLM34hBqnrRbV4ozaiFWvBoDH9mBzo3OT5R2I7dzPWU0KUe5CJ2KOFUvQx9WtWXxCDmHOykBZrFlZPjAn4fjnQ1XeIIjDjY5gTjr)CRuV6HNGQCANEAWvBEIEpil7hB8kPlHIjk9RwQRxERA4QxjKknVXp2CkHmVAZtQpXCfDDHnJJSSEIsiLM)ivAEJ)6iC8kbv50oL0ZrTcG8bxT50f2ZezMC1wCFRQXl2EK1vl1VSh1kPrFWAAUY5FnWiArtTmNB028trTERycrXKR1Tc)Cdwdpbv50ofq(GR2C6c7zg3CLIncye9JnzScPR2I7dzPWU0KUe5CJ2KOFUvQx9WtWXxK0dwxTupD(G10CLZ)AGr0IMAzo3OT5NIADmHOycb1brRHVOcPjOkN2PRRHRELCTUv4NBWA4j1NyUIaKp4QnNUWEMivAEJFAbvpsDVAlUVCmHOykBZrFlZPjAn4fpDixxXeIIjKknVXFULvHjI8vUUO5kN)1aJOfn1YCUrBZpffG8bxT50f2ZepC(p4Qn)5nTw1hPU7ADRWp3G1WxTf3RHRELCTUv4NBWA4j1NyUIwtZvo)RbgrlAQL5CJ2MFApka5dUAZPlSNjE48FWvB(ZBATQpsDVL5CJ2MVAlUtZvo)RbgrlAQL5CJ2Mt6za5dUAZPlSNzeIbI6XFt8hYsHwDVAlUJnJJSSEIsiLM)ivAEJ)6iC8kbv50o90(5nVUQwQFzpQ1t7rFaG8bxT50f2ZmcSLwd1xu5rigiA1wCF5QL6x2JAL0ZrDW1v1s9l7rTEcBghzz9eLqkn)rQ08g)1r44vcQYPD6cN386cBghzz9eLqkn)rQ08g)1r44vcQYPD6PZrVcG8bxT50f2ZKsiLM)K0CvSvhTAlUJnJJSSEIsiLM)ivAEJ)6iC8kbv50oLuY4GRlSzCKL1tucP08hPsZB8xhHJxjOkN2PNohfG8bxT50f2ZepC(JG6GO1WxuH0vBX9LXMXrwwprjKsZFKknVXFDeoELGQCANE6qxhtikMqQ08g)4HZBpscQYPD6kxxlJnJJSSEIsiLM)ivAEJ)6iC8kbv50o905ZR3kMqumHuP5n(XdN3EKeuLt70vUUWMXrwwprjKsZFKknVXFDeoELGQCANs6zYaq(GR2C6c7zw36t4XgHJErdI1vBX9ycrXeuXlYvk9fniwtqDWfG8bxT50f2ZmU5kfBeWi6hBYyfsbKp4QnNUWEM3JJEt8JqWrJVAlUV8qwkSlnfpCvKG)TtIHNQnpP(eZv01vnC1ResLM34hBoLqMxT5j1NyUIwzDouj5JGrPZP7XrVj(ri4OXxJnJJSSEIsiLM)ivAEJ)6iC8kbv50o9uuaYxAalQdo4GdR0CLZ)7HwkG1uaJEBW6ECeGjAqaRUvadp0cWQwQaMjcylvvAEJbSmochVsawg3kG1EPEbynfWkdWmNFeWI1iTdy4HwThbWAraBamScRPDaZjKXkeWmraRL5ualBZ5awScygrbyXhbS6wbm1raMjcy1Tcy4Hwja5dUAZPlSNjLqkn)rQ08g)1r441QT4o1i4p9EGOtrVE5TQHRELqQ08g)yZPeY8QnpP(eZv01vmHOykBZrFlZPjAn4fxOL50NMpzDf9icy7rsucP08hPsZB8xhHJxKUFiRRwQFzFlZPPHZtqvoTtpHhA9vl1vUUQwQFzpQ1trDaG8bxT50f2Zm3YQWN253MVAlUhtikMY2C03YCAIwdErs3JADmHOycPsZB8JnOMO1Gx80EuRJjeftivAEJ)ClRctilRVMMRC(xdmIw0ulZ5gTn)uuaYhC1MtxyptKzYvBX9A4QxjKzYK6tmxrRHQiuP3tmxxxTu)YEuRKUmYQeYmzcQYPD6crFWkaYhC1MtxypZ7XrVj(ri4OXxTf3Pgb)P3der6(Mxxltnc(tVhiI09OxJnJJSSEcpC(JG6GO1WxuH0euLt7usjJ1lJnJJSSEIsiLM)ivAEJ)6iC8kbv50oL0Oo46AzSzCKL1tucP08hPsZB8xhHJxjOkN2PNIGrlLOwxdx9kHuP5n(XMtjK5vBEs9jMRORlSzCKL1tucP08hPsZB8xhHJxjOkN2PNIGrlfYy9w1WvVsivAEJFS5uczE1MNuFI5kALvwV8w1WvVsucP08NKMRIT6OK6tmxrxxyZ4ilRNOesP5pjnxfB1rjOkN2PKg9kRaiFWvBoDH9mPgb)PfSxuxTf3Pgb)P3deDAZ1XeIIjKknVXp2GAIwdEXt7rbiFWvBoDH9mrQ08yJxR2I7uJG)07bIoTh96ycrXesLM34hBqnrKVE5LXMXrwwprjKsZFKknVXFDeoELGQCANE6qUUWMXrwwprjKsZFKknVXFDeoELGQCANsAurTERHSuyxAIEpill9J7stQpXCfTY1vmHOycPsZB8JnOMO1GxK09OVUIjeftivAEJFSb1euLt70tBEDvTu)YEuRNIAZRRycrXe9Eqww6h3LMGQCANUcG8bxT50f2Zu0Weuf9dzPWU0pwh5QT4(w5ALqQ08g)1r44vAWvtIciFWvBoDH9mZjGT4X2J8X8HwaYhC1MtxypZyUzO3e)6wF1v5ra5dUAZPlSNj2CS6fCkf9I8rQR2I7BHSkHnhREbNsrViFK6hta9euLt701Bn4QnpHnhREbNsrViFKAQ9xK3rUR1BLRvcPsZB8xhHJxPbxnjkG8bxT50f2ZepC(p4Qn)5nTw1hPUht0C0pp9EGia5aYhC1MttXenh9ZtVhiAxQsdE8nXNtGB0JG6iPR2I7uJG)07bIoffG8bxT50umrZr)807bIwyptQrWFAb7f1vBX9TQHRELqQ08g)yZPeY8QnpP(eZv01v1sL0ZBEDLdvs(iyu6C6EC0BIFecoA81BftikMI5MH4e0kbv50ofq(GR2CAkMO5OFE69arlSNj9Eqw2p24fGCa5dUAZPPwMZnAB(ElZ5gTnF1wCF5ycrXu2MJ(wMtt0AWls6(HSEzQrWF69arNI(6khQK8rWO05eE48hb1brRHVOcPxxXeIIPSnh9TmNMO1GxK09d96khQK8rWO05uCZvk2iGr0p2KXkKEDT8w5qLKpcgLoNUhh9M4hHGJgF9w5qLKpcgLIkDpo6nXpcbhn(kRSERCOsYhbJsNt3JJEt8JqWrJVERCOsYhbJsrLUhh9M4hHGJgFDmHOycPsZB8NBzvyczz9vUUwUAP(L9Owpf96ycrXu2MJ(wMtt0AWls6bRCDTCouj5JGrPOs4HZFeuheTg(IkKUoMqumLT5OVL50eTg8IKg16TQHRELqQ08g)4HZBpss9jMROvaKp4QnNMAzo3OT5lSNzeylTgQVOYJqmq0QT4o2moYY6jkHuA(JuP5n(RJWXReuLt70tNJ(6AlDjNOZZvu6C0rf9HCOaYhC1MttTmNB028f2ZepC(JG6GO1WxuH0vBX9LXMXrwwprjKsZFKknVXFDeoELGQCANE6qxhtikMqQ08g)4HZBpscQYPD6kxxlJnJJSSEIsiLM)ivAEJ)6iC8kbv50o905ZR3kMqumHuP5n(XdN3EKeuLt70vUUWMXrwwprjKsZFKknVXFDeoELGQCANs6zYaq(GR2CAQL5CJ2MVWEMucP08hPsZB8xhHJxaYhC1MttTmNB028f2Z8EC0BIFecoA8vBXDQrWF69arKUVjG8bxT50ulZ5gTnFH9mVhh9M4hHGJgF1wCNAe8NEpqeP7rVE5LxohQK8rWOuuP7XrVj(ri4OXVUIjeftzBo6BzonrRbViP7rVY6ycrXu2MJ(wMtt0AWlE6qx56cBghzz9eLqkn)rQ08g)1r44vcQYPD6P9iy0sjQRRycrXesLM34p3YQWeuLt7usJGrlLOwbq(GR2CAQL5CJ2MVWEMivAESXRvBX9COsYhbJsNt3JJEt8JqWrJVMAe8NEpqeP7NxVCmHOykBZrFlZPjAn4fpTh91vouj5JGrPOt3JJEt8JqWrJVYAQrWF69arNiJ1XeIIjKknVXp2GAIihq(GR2CAQL5CJ2MVWEMucP08NKMRIT6OvBX9LXMXrwwprjKsZFKknVXFDeoELGQCANskzCWAAUY5FnWiArtTmNB028t7rTY1f2moYY6jkHuA(JuP5n(RJWXReuLt70tNJcq(GR2CAQL5CJ2MVWEMXnxPyJagr)ytgRq6QT4o2moYY6jkHuA(JuP5n(RJWXReuLt7uspua5dUAZPPwMZnAB(c7zkAycQI(HSuyx6hRJeq(GR2CAQL5CJ2MVWEM5eWw8y7r(y(qla5dUAZPPwMZnAB(c7zgZnd9M4x36RUkpciFWvBon1YCUrBZxyptS5y1l4uk6f5JuxTf33czvcBow9coLIEr(i1pMa6jOkN2PR3AWvBEcBow9coLIEr(i1u7ViVJCxRP5kN)1aJOfn1YCUrBZpTjG8bxT50ulZ5gTnFH9mPgb)PfSxuxTf3Pgb)P3deDAZ1XeIIjKknVXp2GAIwdEXt7rbiFWvBon1YCUrBZxyptKknp241QT4o1i4p9EGOt7rVoMqumHuP5n(Xgute5RxoMqumHuP5n(Xgut0AWls6E0xxXeIIjKknVXp2GAcQYPD6P9iy0szZezBfa5dUAZPPwMZnAB(c7zImtUk(iMRFnWiAr3pVQCwIhFeZ1VgyeTO7KTvBXDOkcv69eZva5dUAZPPwMZnAB(c7zIho)hC1M)8MwR6Ju3JjAo6NNEpqeGCa5dUAZPjxRBf(5gSg(oE48FWvB(ZBATQpsD316wHFUbRH)Xenh1EKvBXDSzCKL1tUw3k8Znyn8euLt70trDaG8bxT50KR1Tc)CdwdFH9mXdN)dUAZFEtRv9rQ7Uw3k8Znyn8FWvtIUAlUhtikMCTUv4NBWA4jICa5aYhC1MttUw3k8Znyn8FWvtIUh3CLIncye9JnzScPaYhC1MttUw3k8Znyn8FWvtIUWEMrGT0AO(IkpcXarR2I7yZ4ilRNOesP5psLM34VochVsqvoTtpDo6RRT0LCIopxrPZrhv0hYHciFWvBon5ADRWp3G1W)bxnj6c7zsjKsZFsAUk2QJwTf3XMXrwwprjKsZFKknVXFDeoELGQCANskzCW1f2moYY6jkHuA(JuP5n(RJWXReuLt70tNJcq(GR2CAY16wHFUbRH)dUAs0f2ZepC(JG6GO1WxuH0vBX9LXMXrwwprjKsZFKknVXFDeoELGQCANE6qxhtikMqQ08g)4HZBpscQYPD6kxxlJnJJSSEIsiLM)ivAEJ)6iC8kbv50o905ZR3kMqumHuP5n(XdN3EKeuLt70vUUWMXrwwprjKsZFKknVXFDeoELGQCANs6zYaq(GR2CAY16wHFUbRH)dUAs0f2ZepC(p4Qn)5nTw1hPUht0C0pp9EGOvBXDQrWF69ar7NxVm2moYY6j8W5pcQdIwdFrfstqvoTtpn4QnprVhKL9JnELWdT(QL611Y1WvVsXnxPyJagr)ytgRqAs9jMRO1yZ4ilRNIBUsXgbmI(XMmwH0euLt70tdUAZt07bzz)yJxj8qRVAPUYkaYhC1MttUw3k8Znyn8FWvtIUWEM3JJEt8JqWrJVAlUV8YyZ4ilRNWdN)iOoiAn8fvinbv50oL0bxT5jKknp24vcp06RwQRSEzSzCKL1t4HZFeuheTg(IkKMGQCANs6GR28e9Eqw2p24vcp06RwQRSYASzCKL1tUw3k8Znyn8euLt7usx(8HS5cdUAZt3JJEt8JqWrJNWdT(QL6kaYhC1MttUw3k8Znyn8FWvtIUWEMucP08hPsZB8xhHJxR2I7XeIIjxRBf(5gSgEcQYPD6Pnxtnc(tVhiA)aa5dUAZPjxRBf(5gSg(p4QjrxyptkHuA(JuP5n(RJWXRvBX9ycrXKR1Tc)Cdwdpbv50o90GR28eLqkn)rQ08g)1r44vcp06RwQlCqAta5dUAZPjxRBf(5gSg(p4QjrxyptKknp241QT4EmHOycPsZB8JnOMiYxtnc(tVhi60E0aYhC1MttUw3k8Znyn8FWvtIUWEM4HZ)bxT5pVP1Q(i19yIMJ(5P3debihq(GR2CAY16wHFUbRH)Xenh1EKDcQ(DPYv9rQ7dzrVh4qFrZR3e)ClRcxTf3XMXrwwp5ADRWp3G1WtqvoTtpTV5sHMRC(Fp0sbKp4QnNMCTUv4NBWA4FmrZrThzH9mJqmqup(BI)qwk0Q7vBX9TWMXrwwp5ADRWp3G1WtqvoTtxtnc(tVhiI09nbKp4QnNMCTUv4NBWA4FmrZrThzH9mDTUv4NBWA4R2I7uJG)07bIiDFta5dUAZPjxRBf(5gSg(ht0Cu7rwypt8W5pcQdIwdFrfsxTf3RwQKUh9baYhC1MttUw3k8Znyn8pMO5O2JSWEM3JJEt8JqWrJVAlUxTujDp6dwJnJJSSEcpC(JG6GO1WxuH0euLt7uspFywtnc(tVhiI09ObKp4QnNMCTUv4NBWA4FmrZrThzH9mZTSk8PD(T5R2I7vlvs3J(G1XeIIPSnh9TmNMO1GxK09OwhtikMqQ08g)ydQjAn4fpTh16ycrXesLM34p3YQWeYY6RPgb)P3der6E0aYhC1MttUw3k8Znyn8pMO5O2JSWEM3JJEt8JqWrJVAlUxTujDp6dwtnc(tVhiI09nbKp4QnNMCTUv4NBWA4FmrZrThzH9mXdN)dUAZFEtRv9rQ7Xenh9ZtVhicqoG8bxT50KLRUc3Vhh9M4hHGJgFvE76Jr7rFWQT4(qwkSlnPlro3Onj6NBL6vp8K6tmxraYhC1MttwU6kCH9mBzo3OT5R2I7dzPWU0KUe5CJ2KOFUvQx9WtQpXCfToMqumLT5OVL50eTg8IKg16ycrXKUe5CJ2KOFUvQx9WtilRdiFWvBonz5QRWf2ZezMCvE76Jr7rFaG8bxT50KLRUcxypZiede1J)M4pKLcT6gq(GR2CAYYvxHlSN594O3e)ieC04R2I75qLKpcgLoNUhh9M4hHGJgFn1i4p9EGispyDouj5JGrPOsuJG)0c2lQaYhC1MttwU6kCH9mrQ08g)0cQEK6E1wCphQK8rWO05094O3e)ieC04R3khQK8rWOuuP7XrVj(ri4OXxVCmHOykBZrFlZPjAn4fj986bxT5P7XrVj(ri4OXtT)I8oYDTcG8bxT50KLRUcxypZ4MRuSraJOFSjJvifq(GR2CAYYvxHlSNj1i4pTG9I6Q821hJ2J(GvBX9TIjeftXCZqCcALGQCANEDvTujDZ15qLKpcgLoNUhh9M4hHGJghq(GR2CAYYvxHlSNjLqkn)jP5QyRoA1wCNAe8NEpq0(MaYhC1MttwU6kCH9mJaBP1q9fvEeIbIwTf3Pgb)P3deTVjG8bxT50KLRUcxypt8W5pcQdIwdFrfsxTf3Pgb)P3deTVjG8bxT50KLRUcxypZ7XrVj(ri4OXxTf3Pgb)P3deTVjG8bxT50KLRUcxypZ7XrVj(ri4OXxTf3Pgb)P3der6E0RZHkjFemkfv6EC0BIFecoA81vlvs3C9Y5qLKpcgLoNOgb)PfSxuVU2QgU6vIAe8NwWErnP(eZv06COsYhbJsNt07bzz)yJxRaiFPbSOo4GdoSsZvo)VhAPawtbm6TbR7XraMObbS6wbm8qlaRAPcyMiGTuvP5ngWY4iC8kbyzCRaw7L6fG1uaRmaZC(ralwJ0oGHhA1EeaRfbSbWWkSM2bmNqgRqaZebSwMtbSSnNdyXkGzefGfFeWQBfWuhbyMiGv3kGHhALaKp4QnNMSC1v4c7zsjKsZFKknVXFDeoETAlUNdvs(iyu6CcPsZB8tlO6rQ7RRCOsYhbJsNt3JJEt8JqWrJVohQK8rWOuuP7XrVj(ri4OXVU2QgU6vcPsZB8tlO6rQ7K6tmxrRJjeftzBo6BzonrRbV4cTmN(08jRROhraBpsIsiLM)ivAEJ)6iC8I09dbq(GR2CAYYvxHlSNjsLMhB8A1wCNAe8NEpq0P9OxhtikMqQ08g)ydQjOkN2PaYhC1MttwU6kCH9mXdN)dUAZFEtRv9rQ7Xenh9ZtVhikiqIcPT5HnI6GZh6bKTOIkiKDGE7rObHd3YCdwkcWoma2GR2CaJ30IMaKhe4nTOHmccwU6kmKryJZHmccQpXCff2oim4QnpiCpo6nXpcbhnEqad7sH9eegYsHDPjDjY5gTjr)CRuV6HNuFI5kkiWBxFmkie9bHkSruHmccQpXCff2oiGHDPWEccdzPWU0KUe5CJ2KOFUvQx9WtQpXCfbyRbSycrXu2MJ(wMtt0AWlcyKcyrbyRbSycrXKUe5CJ2KOFUvQx9WtilRhegC1MheAzo3OT5HkSr0HmccQpXCff2oim4QnpiGmtge4TRpgfeI(Gqf2GmczeegC1MheIqmqup(BI)qwk0Q7GG6tmxrHTdvyJndzeeuFI5kkSDqad7sH9eeYHkjFemkDoDpo6nXpcbhnoGTgWOgb)P3debyKcyhayRbSCOsYhbJsrLOgb)PfSxudcdUAZdc3JJEt8JqWrJhQWghsiJGG6tmxrHTdcyyxkSNGqouj5JGrPZP7XrVj(ri4OXbS1a2wawouj5JGrPOs3JJEt8JqWrJdyRbSLbSycrXu2MJ(wMtt0AWlcyKcyNbS1a2GR28094O3e)ieC04P2FrEh5UaSvccdUAZdcivAEJFAbvpsDhQWgKTqgbHbxT5bH4MRuSraJOFSjJviniO(eZvuy7qf24WeYiiO(eZvuy7GWGR28Ga1i4pTG9IAqad7sH9ee2cWIjeftXCZqCcALGQCANcyxxaw1sfWifW2eWwdy5qLKpcgLoNUhh9M4hHGJgpiWBxFmkie9bHkSXHgYiiO(eZvuy7Gag2Lc7jiqnc(tVhicW2bSndcdUAZdcucP08NKMRIT6Oqf248bHmccQpXCff2oiGHDPWEccuJG)07bIaSDaBZGWGR28GqeylTgQVOYJqmquOcBC(CiJGG6tmxrHTdcyyxkSNGa1i4p9EGiaBhW2mim4QnpiGho)rqDq0A4lQqAOcBCoQqgbb1NyUIcBheWWUuypbbQrWF69ara2oGTzqyWvBEq4EC0BIFecoA8qf24C0HmccQpXCff2oiGHDPWEccuJG)07bIams3bSObS1awouj5JGrPOs3JJEt8JqWrJdyRbSQLkGrkGTjGTgWwgWYHkjFemkDornc(tlyVOcyxxa2wawnC1Re1i4pTG9IAs9jMRiaBnGLdvs(iyu6CIEpil7hB8cWwjim4QnpiCpo6nXpcbhnEOcBCMmczeeuFI5kkSDqad7sH9eeYHkjFemkDoHuP5n(Pfu9i1nGDDby5qLKpcgLoNUhh9M4hHGJghWwdy5qLKpcgLIkDpo6nXpcbhnoGDDbyBby1WvVsivAEJFAbvpsDNuFI5kcWwdyXeIIPSnh9TmNMO1GxeWwaWAzo9P5twxrpIa2EKeLqkn)rQ08g)1r44fGr6oGDibHbxT5bbkHuA(JuP5n(RJWXRqf248MHmccQpXCff2oiGHDPWEccuJG)07bIaSt7aw0a2AalMqumHuP5n(XgutqvoTtdcdUAZdcivAESXRqf248HeYiiO(eZvuy7GWGR28GaE48FWvB(ZBAfe4nTEFKAqiMO5OFE69arHkubbxRBf(5gSgEiJWgNdzeeuFI5kkSDqad7sH9eeWMXrwwp5ADRWp3G1WtqvoTtbStawuheegC1MheWdN)dUAZFEtRGaVP17JudcUw3k8Znyn8pMO5O2JeQWgrfYiiO(eZvuy7Gag2Lc7jietikMCTUv4NBWA4jI8GWGR28GaE48FWvB(ZBAfe4nTEFKAqW16wHFUbRH)dUAs0qfQGasfhcEfYiSX5qgbHbxT5bbAUY5p3WlgeuFI5kkSDOcBeviJGG6tmxrHTdcyyxkSNGqUwjKknVXFDeoELgC1KOa2AaBzaBlatPu1XAIKM2M)M4NRqrfxT5j5q2niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8xhHJxjOkN2PagP7ag2moYY6jkHuA(JuP5n(RJWXReIaovBoGrMa2Ma2ka2AaBzaBlaRgU6vY16wHFUbRHNuFI5kcWUUaSycrXKR1Tc)CdwdprKdyRayxxaw1s9l7rTcyNaSOpiim4QnpiKBvBEOcBeDiJGG6tmxrHTdcdUAZdcdzrVh4qFrZR3e)ClRcdcyyxkSNGa2moYY6jkHuA(JuP5n(RJWXReuLt7ua70oGf1ba2AaBlaRgU6vY16wHFUbRHNuFI5kki4JudcdzrVh4qFrZR3e)ClRcdvydYiKrqq9jMROW2bbmSlf2tqixResLM34VochVsdUAsuaBnGTmGTfGPuQ6ynrstBZFt8ZvOOIR28KCi7geWUUaSTaSA4QxjKknVXp2CkHmVAZtQpXCfbyxxag2moYY6jkHuA(JuP5n(RJWXReuLt7uaJ0DadBghzz9eLqkn)rQ08g)1r44vcraNQnhWitaBtaBfa76cWQwQFzpQva70oGDEZGWGR28Gabv)UujnuHn2mKrqq9jMROW2bbmSlf2tqixResLM34VochVsdUAsuaBnGTmGTfGPuQ6ynrstBZFt8ZvOOIR28KCi7geWUUaSTaSA4QxjKknVXp2CkHmVAZtQpXCfbyxxag2moYY6jkHuA(JuP5n(RJWXReuLt7uaJ0DadBghzz9eLqkn)rQ08g)1r44vcraNQnhWitaBtaBfa76cWQwQFzpQva70oGDEZGWGR28GqScPkCX2JeQWghsiJGG6tmxrHTdcyyxkSNGqUwjKknVXFDeoELgC1KOa2AaBzaBlatPu1XAIKM2M)M4NRqrfxT5j5q2niGDDbyBby1WvVsivAEJFS5uczE1MNuFI5kcWUUamSzCKL1tucP08hPsZB8xhHJxjOkN2PagP7ag2moYY6jkHuA(JuP5n(RJWXReIaovBoGrMa2Ma2ka21fGvTu)YEuRa2PDa78MbHbxT5bHyUzOxKaEmuHniBHmccQpXCff2oiGHDPWEcc5ALqQ08g)1r44vAWvtIcyRbSLbSTamLsvhRjsAAB(BIFUcfvC1MNKdz3Ga21fGTfGvdx9kHuP5n(XMtjK5vBEs9jMRia76cWWMXrwwprjKsZFKknVXFDeoELGQCANcyKUdyyZ4ilRNOesP5psLM34VochVsic4uT5agzcyBcyRayxxaw1s9l7rTcyN2bSZBgegC1MheeBOgZndfQWghMqgbb1NyUIcBheWWUuypbHCTsivAEJ)6iC8kn4QjrbS1awUwjKknVXFDeoELGQCANcyN2bSZBcyKjGfbJaSLcGfnGTgWwgW2cWukvDSMiPPT5Vj(5kuuXvBEsoKDdcyxxa2wawnC1ResLM34hBoLqMxT5j1NyUIaSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGr6oGHnJJSSEIsiLM)ivAEJ)6iC8kHiGt1MdyKjGTjGTsqyWvBEqiMBg6nXVU1xDvEmuHno0qgbb1NyUIcBheWWUuypbHycrXeVf1yUzOeTg8Ia2jalAaBnGTmGLRvcPsZB8xhHJxPbxnjkGTgWwgW2cWukvDSMiPPT5Vj(5kuuXvBEsoKDdcyxxa2wawnC1ResLM34hBoLqMxT5j1NyUIaSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGr6oGHnJJSSEIsiLM)ivAEJ)6iC8kHiGt1MdyKjGTjGTcGDDbyvl1VSh1kGDAhWoVjGTsqyWvBEqiRb5is02FOsnFCSgQWgNpiKrqq9jMROW2bbmSlf2tqixResLM34VochVsdUAsuaBnGTmGTfGPuQ6ynrstBZFt8ZvOOIR28KCi7geWUUaSTaSA4QxjKknVXp2CkHmVAZtQpXCfbyxxag2moYY6jkHuA(JuP5n(RJWXReuLt7uaJ0DadBghzz9eLqkn)rQ08g)1r44vcraNQnhWitaBtaBfa76cWQwQFzpQva70oGDEZGWGR28GaSZZ563(tZhSgQWgNphYiiO(eZvuy7GWGR28GqUHxulAtwk6XMmNOMQn)rkjnwdcyyxkSNGa2moYY6jkHuA(JuP5n(RJWXReuLt7uaJ0DalQdaS1ag2moYY6jkHuA(JuP5n(RJWXReuLt7ua70oGHnJJSSEIsiLM)ivAEJ)6iC8kHiGt1MdyKjGDEta76cWQwQFzpQva70oGf9bbbFKAqi3WlQfTjlf9ytMtut1M)iLKgRHkSX5OczeeuFI5kkSDqyWvBEqaAfgsqlf9KygYShzCEqad7sH9eewgWWMXrwwprjKsZFKknVXFDeoELGQCANcyKUdyrTjGDDbyvl1VSh1kGDAhWI(aaBLGGpsniaTcdjOLIEsmdz2JmopuHnohDiJGG6tmxrHTdcdUAZdc07Mef(KOUjFOYBCqad7sH9eewgWWMXrwwprjKsZFKknVXFDeoELGQCANcyKUdyrTjGDDbyvl1VSh1kGDAhWI(aaBLGGpsniqVBsu4tI6M8HkVXHkSXzYiKrqq9jMROW2bHbxT5bHzjNOZTs969HOAobniGHDPWEccldyyZ4ilRNOesP5psLM34VochVsqvoTtbms3bSO2eWUUaSQL6x2JAfWoTdyrFaGTsqWhPgeMLCIo3k1R3hIQ5e0qf248MHmccQpXCff2oim4QnpiunsPLbLp2q6seeWWUuypbHLbmSzCKL1tucP08hPsZB8xhHJxjOkN2PagP7awuBcyxxaw1s9l7rTcyN2bSOpaWwji4JudcvJuAzq5JnKUeHkSX5djKrqq9jMROW2bHbxT5bbs6H)M4tldkPbbmSlf2tqyzadBghzz9eLqkn)rQ08g)1r44vcQYPDkGr6oGf1Ma21fGvTu)YEuRa2PDal6daSvcc(i1Gaj9WFt8PLbL0qf24mzlKrqq9jMROW2bbmSlf2tqylaRgU6vY16wHFUbRHNuFI5kcWwdyvlva7eGf9ba2AaBladBghzz9eLqkn)rQ08g)1r44vcQYPDAqyWvBEqapC(p4Qn)5nTcc8MwVpsniy5QRWqf248HjKrqq9jMROW2bHbxT5bHHSO3dCOVO51BIFULvHbbmSlf2tqyzaRAPcyKcyrFaGDDbyBby1WvVsUw3k8Znyn8K6tmxra2ka2AaRgU6vkcSLwd1xu5rigikP(eZveGTgWwgWQwQFzpQvaJua7Cuhayxxaw1s9l7rTcyNamSzCKL1tucP08hPsZB8xhHJxjOkN2Pa2ca25nbSvaSRlaRAP(L9OwbSt7aw0Bge8rQbHHSO3dCOVO51BIFULvHHkSX5dnKrqq9jMROW2bbmSlf2tqyilf2LM0LiNB0Me9ZTs9QhEco(Ia2AaRAPcyNaSnbS1ag1i4p9EGiaJualkaBnGftikM0LiNB0Me9ZTs9QhEczzDaBnGftikMY2C03YCAIwdEra7eGfnGTgW2cWYHkjFemkDoDpo6nXpcbhnoGTgW2cWYHkjFemkfv6EC0BIFecoA8GWGR28GW94O3e)ieC04HkSruheYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWoTdyrdyRbSycrXesLM34hBqnrKdyRbSycrXesLM34hBqnrRbViGTdyKrqyWvBEqaPsZJnEfQWgrDoKrqq9jMROW2bbmSlf2tqyilf2LM0LiNB0Me9ZTs9QhEco(Ia2AalMqumLT5OVL50eTg8IagPawua2AalMqumPlro3Onj6NBL6vp8euLt7ua7eGn4QnprVhKL9JnEL0LqXeL(vlvaBnGTmGTfGvdx9kHuP5n(XMtjK5vBEs9jMRia76cWWMXrwwprjKsZFKknVXFDeoELGQCANcyKcyNJcWwjim4Qnpi0YCUrBZdvyJOIkKrqq9jMROW2bbmSlf2tqylaRA8IThbWwdyvl1VSh1kGrkGf9ba2AaJMRC(xdmIw0ulZ5gTnhWobyrbyRbSTaSycrXKR1Tc)Cdwdpbv50onim4QnpiGmtgQWgrfDiJGG6tmxrHTdcyyxkSNGWqwkSlnPlro3Onj6NBL6vp8eC8fbmsbSdaS1aw1sfWobyNpaWwdy0CLZ)AGr0IMAzo3OT5a2jalkaBnGftikMqqDq0A4lQqAcQYPDkGTgWQHRELCTUv4NBWA4j1NyUIccdUAZdcXnxPyJagr)ytgRqAOcBefzeYiiO(eZvuy7Gag2Lc7jiSmGftikMY2C03YCAIwdEra7eGDia21fGftikMqQ08g)5wwfMiYbSvaSRlaJMRC(xdmIw0ulZ5gTnhWobyrfegC1MheqQ08g)0cQEK6ouHnIAZqgbb1NyUIcBheWWUuypbHA4QxjxRBf(5gSgEs9jMRiaBnGrZvo)RbgrlAQL5CJ2MdyN2bSOccdUAZdc4HZ)bxT5pVPvqG3069rQbbxRBf(5gSgEOcBe1HeYiiO(eZvuy7Gag2Lc7jiqZvo)RbgrlAQL5CJ2MdyKcyNdcdUAZdc4HZ)bxT5pVPvqG3069rQbHwMZnABEOcBefzlKrqq9jMROW2bbmSlf2tqaBghzz9eLqkn)rQ08g)1r44vcQYPDkGDAhWoVjGDDbyvl1VSh1kGDAhWI(GGWGR28GqeIbI6XFt8hYsHwDhQWgrDyczeeuFI5kkSDqad7sH9eewgWQwQFzpQvaJua7Cuhayxxaw1s9l7rTcyNamSzCKL1tucP08hPsZB8xhHJxjOkN2Pa2ca25nbSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGDcWohnGTsqyWvBEqicSLwd1xu5rigikuHnI6qdzeeuFI5kkSDqad7sH9eeWMXrwwprjKsZFKknVXFDeoELGQCANcyKcyKXba21fGHnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyNJkim4QnpiqjKsZFsAUk2QJcvyJOpiKrqq9jMROW2bbmSlf2tqyzadBghzz9eLqkn)rQ08g)1r44vcQYPDkGDcWouaBnGftikMqQ08g)4HZBpscQYPDkGTcGDDbyldyyZ4ilRNOesP5psLM34VochVsqvoTtbSta25Za2AaBlalMqumHuP5n(XdN3EKeuLt7uaBfa76cWWMXrwwprjKsZFKknVXFDeoELGQCANcyKcyNjJGWGR28GaE48hb1brRHVOcPHkSr0NdzeeuFI5kkSDqad7sH9eeIjeftqfVixP0x0Gynb1bxbHbxT5bH6wFcp2iC0lAqSgQWgrhviJGWGR28GqCZvk2iGr0p2KXkKgeuFI5kkSDOcBeD0HmccQpXCff2oiGHDPWEccldydzPWU0u8Wvrc(3ojgEQ28K6tmxra21fGvdx9kHuP5n(XMtjK5vBEs9jMRiaBfaBnGLdvs(iyu6C6EC0BIFecoACaBnGHnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyrfegC1MheUhh9M4hHGJgpuHnIMmczeeuFI5kkSDqad7sH9eeOgb)P3debyNaSObS1a2Ya2wawnC1ResLM34hBoLqMxT5j1NyUIaSRlalMqumLT5OVL50eTg8Ia2cawlZPpnFY6k6reW2JKOesP5psLM34VochVams3bSdbWwdyvl1VSVL500W5jOkN2Pa2jadp06RwQa2ka21fGvTu)YEuRa2jalQdccdUAZdcucP08hPsZB8xhHJxHkSr0BgYiiO(eZvuy7Gag2Lc7jietikMY2C03YCAIwdEraJ0DalkaBnGftikMqQ08g)ydQjAn4fbSt7awua2AalMqumHuP5n(ZTSkmHSSoGTgWO5kN)1aJOfn1YCUrBZbStawubHbxT5bHClRcFANFBEOcBe9HeYiiO(eZvuy7Gag2Lc7jiudx9kHmtMuFI5kcWwdyqveQ07jMRa2AaRAP(L9OwbmsbSLbmKvjKzYeuLt7uaBbal6daSvccdUAZdciZKHkSr0KTqgbb1NyUIcBheWWUuypbbQrWF69aragP7a2Ma21fGTmGrnc(tVhicWiDhWIgWwdyyZ4ilRNWdN)iOoiAn8fvinbv50ofWifWidaBnGTmGHnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWifWI6aa76cWwgWWMXrwwprjKsZFKknVXFDeoELGQCANcyNaSiyeGTuaSOaS1awnC1ResLM34hBoLqMxT5j1NyUIaSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGDcWIGra2sbWidaBnGTfGvdx9kHuP5n(XMtjK5vBEs9jMRiaBfaBfaBnGTmGTfGvdx9krjKsZFsAUk2QJsQpXCfbyxxag2moYY6jkHuA(tsZvXwDucQYPDkGrkGfnGTcGTsqyWvBEq4EC0BIFecoA8qf2i6dtiJGG6tmxrHTdcyyxkSNGa1i4p9EGia7eGTjGTgWIjeftivAEJFSb1eTg8Ia2PDalQGWGR28Ga1i4pTG9IAOcBe9HgYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWoTdyrdyRbSycrXesLM34hBqnrKdyRbSLbSLbmSzCKL1tucP08hPsZB8xhHJxjOkN2Pa2ja7qaSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGrkGfvua2AaBlaBilf2LMO3dYYs)4U0K6tmxra2ka21fGftikMqQ08g)ydQjAn4fbms3bSObSRlalMqumHuP5n(XgutqvoTtbSta2Ma21fGvTu)YEuRa2jalQnbSRlalMqumrVhKLL(XDPjOkN2Pa2kbHbxT5bbKknp24vOcBqgheYiiO(eZvuy7Gag2Lc7jiSfGLRvcPsZB8xhHJxPbxnjAqyWvBEqq0Weuf9dzPWU0pwhzOcBqgNdzeegC1MheYjGT4X2J8X8Hwbb1NyUIcBhQWgKruHmccdUAZdcXCZqVj(1T(QRYJbb1NyUIcBhQWgKr0HmccQpXCff2oiGHDPWEccBbyiRsyZXQxWPu0lYhP(Xeqpbv50ofWwdyBbydUAZtyZXQxWPu0lYhPMA)f5DK7cWwdyBby5ALqQ08g)1r44vAWvtIgegC1MheWMJvVGtPOxKpsnuHnidYiKrqq9jMROW2bHbxT5bb8W5)GR28N30kiWBA9(i1GqmrZr)807bIcvOcc5qfBY4Pcze24CiJGWGR28GaLqkn)fvEeIbIccQpXCff2ouHnIkKrqq9jMROW2bbmSlf2tqiMqumLT5OVL50eTg8IagPa2zaBnGftikMqQ08g)ydQjAn4fbSt7awubHbxT5bHClRcFANFBEOcBeDiJGWGR28GqUvT5bb1NyUIcBhQWgKriJGG6tmxrHTdcyyxkSNGqSrPa21fGn4QnpHuP5XgVs4Hwa2oGDqqyWvBEqaPsZJnEfQWgBgYiim4QnpiqVhKL9JnEfeuFI5kkSDOcvqW16wHFUbRH)dUAs0qgHnohYiim4Qnpie3CLIncye9JnzScPbb1NyUIcBhQWgrfYiiO(eZvuy7Gag2Lc7jiGnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyNJgWUUaSTamDjNOZZvukBZfHkI(0osZFt8Pe5kSn4tjKsZBpsqyWvBEqicSLwd1xu5rigikuHnIoKrqq9jMROW2bbmSlf2tqaBghzz9eLqkn)rQ08g)1r44vcQYPDkGrkGrghayxxag2moYY6jkHuA(JuP5n(RJWXReuLt7ua7eGDoQGWGR28GaLqkn)jP5QyRokuHniJqgbb1NyUIcBheWWUuypbHLbmSzCKL1tucP08hPsZB8xhHJxjOkN2Pa2ja7qbS1awmHOycPsZB8JhoV9ijOkN2Pa2ka21fGTmGHnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyNpdyRbSTaSycrXesLM34hpCE7rsqvoTtbSvaSRladBghzz9eLqkn)rQ08g)1r44vcQYPDkGrkGDMmccdUAZdc4HZFeuheTg(IkKgQWgBgYiiO(eZvuy7Gag2Lc7jiqnc(tVhicW2bSZa2AaBzadBghzz9eE48hb1brRHVOcPjOkN2Pa2jaBWvBEIEpil7hB8kHhA9vlva76cWwgWQHRELIBUsXgbmI(XMmwH0K6tmxra2AadBghzz9uCZvk2iGr0p2KXkKMGQCANcyNaSbxT5j69GSSFSXReEO1xTubSvaSvccdUAZdc4HZ)bxT5pVPvqG3069rQbHyIMJ(5P3defQWghsiJGG6tmxrHTdcyyxkSNGWYa2Yag2moYY6j8W5pcQdIwdFrfstqvoTtbmsbSbxT5jKknp24vcp06RwQa2ka2AaBzadBghzz9eE48hb1brRHVOcPjOkN2PagPa2GR28e9Eqw2p24vcp06RwQa2ka2ka2AadBghzz9KR1Tc)Cdwdpbv50ofWifWwgWoFiBcylaydUAZt3JJEt8JqWrJNWdT(QLkGTsqyWvBEq4EC0BIFecoA8qf2GSfYiiO(eZvuy7Gag2Lc7jietikMCTUv4NBWA4jOkN2Pa2jaBtaBnGrnc(tVhicW2bSdccdUAZdcucP08hPsZB8xhHJxHkSXHjKrqq9jMROW2bbmSlf2tqiMqum5ADRWp3G1WtqvoTtbSta2GR28eLqkn)rQ08g)1r44vcp06RwQa2ca2bPndcdUAZdcucP08hPsZB8xhHJxHkSXHgYiiO(eZvuy7Gag2Lc7jietikMqQ08g)ydQjICaBnGrnc(tVhicWoTdyrhegC1MheqQ08yJxHkSX5dczeeuFI5kkSDqyWvBEqapC(p4Qn)5nTcc8MwVpsniet0C0pp9EGOqfQGGR1Tc)Cdwd)JjAoQ9iHmcBCoKrqq9jMROW2bHbxT5bHHSO3dCOVO51BIFULvHbbmSlf2tqaBghzz9KR1Tc)Cdwdpbv50ofWoTdyBcylfaJMRC(Fp0sdc(i1GWqw07bo0x086nXp3YQWqf2iQqgbb1NyUIcBheWWUuypbHTamSzCKL1tUw3k8Znyn8euLt7uaBnGrnc(tVhicWiDhW2mim4QnpieHyGOE83e)HSuOv3HkSr0HmccQpXCff2oiGHDPWEccuJG)07bIams3bSndcdUAZdcUw3k8Znyn8qf2GmczeeuFI5kkSDqad7sH9eeQwQagP7aw0heegC1MheWdN)iOoiAn8fvinuHn2mKrqq9jMROW2bbmSlf2tqOAPcyKUdyrFaGTgWWMXrwwpHho)rqDq0A4lQqAcQYPDkGrkGD(WayRbmQrWF69aragP7aw0bHbxT5bH7XrVj(ri4OXdvyJdjKrqq9jMROW2bbmSlf2tqOAPcyKUdyrFaGTgWIjeftzBo6BzonrRbViGr6oGffGTgWIjeftivAEJFSb1eTg8Ia2PDalkaBnGftikMqQ08g)5wwfMqwwhWwdyuJG)07bIams3bSOdcdUAZdc5wwf(0o)28qf2GSfYiiO(eZvuy7Gag2Lc7jiuTubms3bSOpaWwdyuJG)07bIams3bSndcdUAZdc3JJEt8JqWrJhQWghMqgbb1NyUIcBhegC1MheWdN)dUAZFEtRGaVP17JudcXenh9ZtVhikuHkiet0C0pp9EGOqgHnohYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWobyrfegC1MheKQ0GhFt85e4g9iOosAOcBeviJGG6tmxrHTdcyyxkSNGWwawnC1ResLM34hBoLqMxT5j1NyUIaSRlaRAPcyKcyN3eWUUaSCOsYhbJsNt3JJEt8JqWrJdyRbSTaSycrXum3meNGwjOkN2PbHbxT5bbQrWFAb7f1qf2i6qgbHbxT5bb69GSSFSXRGG6tmxrHTdvOccTmNB028qgHnohYiiO(eZvuy7Gag2Lc7jiSmGftikMY2C03YCAIwdEraJ0Da7qaS1a2Yag1i4p9EGia7eGfnGDDby5qLKpcgLoNWdN)iOoiAn8fvifWUUaSycrXu2MJ(wMtt0AWlcyKUdyhkGDDby5qLKpcgLoNIBUsXgbmI(XMmwHua76cWwgW2cWYHkjFemkDoDpo6nXpcbhnoGTgW2cWYHkjFemkfv6EC0BIFecoACaBfaBfaBnGTfGLdvs(iyu6C6EC0BIFecoACaBnGTfGLdvs(iyukQ094O3e)ieC04a2AalMqumHuP5n(ZTSkmHSSoGTcGDDbyldyvl1VSh1kGDcWIgWwdyXeIIPSnh9TmNMO1GxeWifWoaWwbWUUaSLbSCOsYhbJsrLWdN)iOoiAn8fvifWwdyXeIIPSnh9TmNMO1GxeWifWIcWwdyBby1WvVsivAEJF8W5ThjP(eZveGTsqyWvBEqOL5CJ2MhQWgrfYiiO(eZvuy7Gag2Lc7jiGnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyNJgWUUaSTamDjNOZZvukBZfHkI(0osZFt8Pe5kSn4tjKsZBpsqyWvBEqicSLwd1xu5rigikuHnIoKrqq9jMROW2bbmSlf2tqyzadBghzz9eLqkn)rQ08g)1r44vcQYPDkGDcWouaBnGftikMqQ08g)4HZBpscQYPDkGTcGDDbyldyyZ4ilRNOesP5psLM34VochVsqvoTtbSta25Za2AaBlalMqumHuP5n(XdN3EKeuLt7uaBfa76cWWMXrwwprjKsZFKknVXFDeoELGQCANcyKcyNjJGWGR28GaE48hb1brRHVOcPHkSbzeYiim4QnpiqjKsZFKknVXFDeoEfeuFI5kkSDOcBSziJGG6tmxrHTdcyyxkSNGa1i4p9EGiaJ0DaBZGWGR28GW94O3e)ieC04HkSXHeYiiO(eZvuy7Gag2Lc7jiqnc(tVhicWiDhWIgWwdyldyldyldy5qLKpcgLIkDpo6nXpcbhnoGDDbyXeIIPSnh9TmNMO1GxeWiDhWIgWwbWwdyXeIIPSnh9TmNMO1GxeWobyhkGTcGDDbyyZ4ilRNOesP5psLM34VochVsqvoTtbSt7awemcWwkawua21fGftikMqQ08g)5wwfMGQCANcyKcyrWiaBPayrbyReegC1MheUhh9M4hHGJgpuHniBHmccQpXCff2oiGHDPWEcc5qLKpcgLoNUhh9M4hHGJghWwdyuJG)07bIams3bSZa2AaBzalMqumLT5OVL50eTg8Ia2PDalAa76cWYHkjFemkfD6EC0BIFecoACaBfaBnGrnc(tVhicWobyKbGTgWIjeftivAEJFSb1erEqyWvBEqaPsZJnEfQWghMqgbb1NyUIcBheWWUuypbHLbmSzCKL1tucP08hPsZB8xhHJxjOkN2PagPagzCaGTgWO5kN)1aJOfn1YCUrBZbSt7awua2ka21fGHnJJSSEIsiLM)ivAEJ)6iC8kbv50ofWobyNJkim4QnpiqjKsZFsAUk2QJcvyJdnKrqq9jMROW2bbmSlf2tqaBghzz9eLqkn)rQ08g)1r44vcQYPDkGrkGDObHbxT5bH4MRuSraJOFSjJvinuHnoFqiJGWGR28GGOHjOk6hYsHDPFSoYGG6tmxrHTdvyJZNdzeegC1MheYjGT4X2J8X8Hwbb1NyUIcBhQWgNJkKrqyWvBEqiMBg6nXVU1xDvEmiO(eZvuy7qf24C0HmccQpXCff2oiGHDPWEccBbyiRsyZXQxWPu0lYhP(Xeqpbv50ofWwdyBbydUAZtyZXQxWPu0lYhPMA)f5DK7cWwdy0CLZ)AGr0IMAzo3OT5a2jaBZGWGR28Ga2CS6fCkf9I8rQHkSXzYiKrqq9jMROW2bbmSlf2tqGAe8NEpqeGDcW2eWwdyXeIIjKknVXp2GAIwdEra70oGfvqyWvBEqGAe8NwWErnuHnoVziJGG6tmxrHTdcyyxkSNGa1i4p9EGia70oGfnGTgWIjeftivAEJFSb1eroGTgWwgWIjeftivAEJFSb1eTg8IagP7aw0a21fGftikMqQ08g)ydQjOkN2Pa2PDalcgbylfaBZezdWwjim4QnpiGuP5XgVcvyJZhsiJGG6tmxrHTdcdUAZdciZKbb8rmx)AGr0Ig24CqqolXJpI56xdmIw0GazliGHDPWEccqveQ07jMRHkSXzYwiJGG6tmxrHTdcdUAZdc4HZ)bxT5pVPvqG3069rQbHyIMJ(5P3defQqfQGWqu3gmii0YL0qfQqa]] )


end
