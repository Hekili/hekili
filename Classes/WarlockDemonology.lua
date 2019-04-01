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
            if not class.abilities[ k ] then k = "summon_demonic_tyrant" end

            -- In SimC, k would be a numeric value to be interpreted but I don't see the point.
            -- We're only using it for SDT now, and I don't know what else we'd really use it for.
            
            -- So imps_spawned_during.summon_demonic_tyrant would be the syntax I'll use here.

            local cap = query_time + action[ k ].cast
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

            readyTime = function () return isCyclingTargets() and 0 or debuff.doom.remains end,
            usable = function () return isCyclingTargets() or target.time_to_die > debuff.doom.duration end,
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
            cooldown = 90,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

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

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_intellect",

        package = "Demonology",
    } )


    spec:RegisterPack( "Demonology", 20190401.1454, [[dOepDbqicKfPQsYJivrxsvLOSjLWNivHAukP6ukfwLsj4vkrnlLuULsjAxu5xKQAykL6yQclJq8mLIMMsjDnvvSnsvQVrQsmovvcNJavRtPeAEQIUNQ0(iuDqsvilujYdjqjtKufCrvvIQpQQseojbkvRuvvZKaLYojv6NQQePHQQsklvvLi6Pi1ujvCvsvs(QQkPAVK8xOgmIdlzXe1Jr1KbUmLntKpRQmALQtl1RjuMnKBtv7w0VfgoPCCsvsTCuEoOPR46iz7eW3vsgVQk15jKwpbkMpbTFvw9qPJIguJP0vKTFi4BV1TF4ES1F26Jnv0JOAMIwR4IvFMIolVPO1dMpYafFIQO1krrrbu6OOHbfJBk69z0GBr91)RNDkzhp86dBpfQMosoRKg9HTNRVIwMQrJG9ujROb1ykDfz7hc(2BD7hUhB9NTU9wv0qnJR0ve9wVv07nayPswrdmixrRNhrpy(idu8j6r(1lgk4ID)1ZJSpJgClQV(F9Stj74HxFy7Pq10rYzL0OpS9C9V)65r0J0yn6ipw7iIS9db)iB5r2wW3IB)Z9)(RNhrWAVYpdUfV)65r2YJqRzi0reSfCXC3F98iB5r0RG2rKPKKCPn7gdRfSPqokTJ0jCScCKq6imZxD253reS0dhzAVDePGDeDTz3yh5xlytHosXNwa7iA7f0C3F98iB5r(LMirpcZ4H3Bj4i6bZhPCGMJOXSTKhE5AoslDKEosdpsNWPY5iRd3dke4iASqUKrIEe40i0r2lgGxWzd39xppYwEKFTyLXocDRTh5rkekwzGJOXSTKhE5AoYehrJf8J0jCQCoIEW8rkhOXD)1ZJSLhrpcaosOzPXoc9EbIvhzPanhjOgydSJeshroGWJi1F7d8itCKAocYk4CKpBosK2r8bZocCVya39xppYwEe9kODKF10Edpbg02V6iRB)wZ4JboIL8GkhJDelbBCewn7g7iZELh5xnf7Zg30Edpbg02V6iRB)wZ4JbocNIXSCoYuSpB0JHhby1SVXrM4iLardoI9BUbHTa2rKPyzNFhjKocR4DHoIGLEa6u0ASqQrMIwppIEW8rgO4t0J8RxmuWf7(RNhzFgn4wuF9)6zNs2XdV(W2tHQPJKZkPrFy756F)1ZJOhPXA0rES2rez7hc(r2YJSTGVf3(N7)9xppIG1ELFgClE)1ZJSLhHwZqOJiyl4I5U)65r2YJOxbTJitjj5sB2ngwlytHCuAhPt4yf4iH0ryMV6SZVJiyPhoY0E7isb7i6AZUXoYVwWMcDKIpTa2r02lO5U)65r2YJ8lnrIEeMXdV3sWr0dMps5anhrJzBjp8Y1CKw6i9CKgEKoHtLZrwhUhuiWr0yHCjJe9iWPrOJSxmaVGZgU7VEEKT8i)AXkJDe6wBpYJuiuSYahrJzBjp8Y1CKjoIgl4hPt4u5Ce9G5JuoqJ7(RNhzlpIEeaCKqZsJDe69ceRoYsbAosqnWgyhjKoICaHhrQ)2h4rM4i1CeKvW5iF2CKiTJ4dMDe4EXaU7VEEKT8i6vq7i)QP9gEcmOTF1rw3(TMXhdCel5bvog7iwc24iSA2n2rM9kpYVAk2NnUP9gEcmOTF1rw3(TMXhdCeofJz5CKPyF2OhdpcWQzFJJmXrkbIgCe73CdcBbSJitXYo)osiDewX7cDebl9a0D)V)65r(L)BJtng4iYMuWSJWdVCnhr2(6e6oIEeNBAd8izKB5EX8suOJu8PJeEKirI6U)fF6iHonMXdVCnVsOck29V4thj0PXmE4LRz5x9LIaC)l(0rcDAmJhE5Aw(v)I6ZB5uth59V4thj0PXmE4LRz5x9HuEFKynBU)fF6iHonMXdVCnl)QFNPXWaZhjCTw6DkKLJRZ0yyG5Je6SSKrg4(x8PJe60ygp8Y1S8R(WS0G7XGHtnW7FXNosOtJz8WlxZYV6Rfth59V4thj0PXmE4LRz5x91IvgddBT9ixRLELPKKCRAea3EnOdofxmXFSqMssYbmFKnhZdM5aXQ8(x8PJe60ygp8Y1S8R(aZhPCGM1APx5acfkS4thPdy(iLd044fCE3((x8PJe60ygp8Y1S8R(W9ceRWYbAwRLEfKCaHcfw8PJ0bmFKYbAC8coIV99)(RNh5x(Vno1yGJycymrpY0E7iZUDKIpb7in8iLavJkzK5U)fF6iHVqndHWOGl29V4thjC5x91IPJCTw6vZghW8r2C8ikRYXv8PfWwSUGMcz54sB2ngwlytHCwwYidiuOmLKKlTz3yyTGnfYrPTHqHt7n8eyqBp3C77FXNos4YV6tbnCpMhUwl9QzJdy(iBoEeLv54k(0cycfoT3WtGbT989Xp3)IpDKWLF1x2yqJjwNFR1sVA24aMpYMJhrzvoUIpTaMqHt7n8eyqBpFF8Z9V4thjC5x9LrraWsumrxRLE1SXbmFKnhpIYQCCfFAbmHcN2B4jWG2E((4N7FXNos4YV6l1mtgfbyTw6vZghW8r2C8ikRYXv8PfWekCAVHNadA757JFU)fF6iHl)QpVqiCXNosmQHZAz5TxapsCOzPXwRLENcz54aMpYMJ5rcP8AthPZYsgzGft7TNBU9cbXJabIvPds59rIbMpYMJhrzvooM5RoH3)IpDKWLF1FVsaoKWFuiqLR1sVLGXy9yo73AOa2cyyTySC6c5yvk2IP92ZFwadkegUxmG4ISqMssYz)wdfWwadRfJLtxihiwLlKPKKCRAea3EnOdofxSNBUqqAmta8hh4E42ReGdj8hfcu5cbPXmbWFCGte3ELaCiH)OqGkV)fF6iHl)QpW8rkhOzTw6fguimCVyGNVBUqMssYbmFKnhZdM5O0witjj5aMpYMJ5bZCWP4I9U17FXNos4YV63Enua7ixRLElbJX6XC2V1qbSfWWAXy50fYXQuSfYussUvncGBVg0bNIlM4ISqMssYz)wdfWwadRfJLtxihZ8vNWNfF6iDW9ceRWYbAC2Vno1y4P92I1f0uilhhW8r2CmpsiLxB6iDwwYidiuipceiwLoiL3hjgy(iBoEeLv54yMV6ek(dr24(x8PJeU8R(Gi8R1sVcAAUyD(TyAVHNadAt8n3EbuZqi8uSpBGU2RHcyh5trU)fF6iHl)QVCJmipOyFgwo8YgdUwl9wcgJ1J5SFRHcylGH1IXYPlKJvPyIV9IP92ZhBVaQzieEk2Nnqx71qbSJ8PilKPKKCaMva4uiXmg0XmF1jCXuilhxAZUXWAbBkKZYsgzG7FXNos4YV6dmFKnhdhMLFZ(AT076YussUvncGBVg0bNIl2t9wOqzkjjhW8r2CSwSYyokTnekeQzieEk2Nnqx71qbSJ8Pi3)IpDKWLF1NxieU4thjg1WzTS82BAZUXWAbBk0AT07uilhxAZUXWAbBkKZYsgzGfqndHWtX(Sb6AVgkGDKpFf5(x8PJeU8R(8cHWfF6iXOgoRLL3EBVgkGDKR1sVqndHWtX(Sb6AVgkGDKI)4(x8PJeU8R(FS2hnZWsg6JQyG1AP31N2B4jWG2e)HiBlu40Edpbg02tEeiqSkDqkVpsmW8r2C8ikRYXXmF1jC5h)iuipceiwLoiL3hjgy(iBoEeLv54yMV6e(8XMBC)l(0rcx(vFiL3hjwGgzsTLG1APxEeiqSkDqkVpsmW8r2C8ikRYXXmF1ju8TUTqH8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4ZhIC)l(0rcx(vFEHqyaZkaCkKygdUwl9UopceiwLoiL3hjgy(iBoEeLv54yMV6e(uWxitjj5aMpYMJ5fc15NJz(Qt4gcfUopceiwLoiL3hjgy(iBoEeLv54yMV6e(8XJfcsMssYbmFKnhZleQZphZ8vNWnekKhbceRshKY7JedmFKnhpIYQCCmZxDcf)XwV)fF6iHl)QVCJmipOyFgwo8YgdE)l(0rcx(v)9kb4qc)rHavUwl9UEjymwpMtUqMefc3PabVMosNLLmYacfofYYXbmFKnhZJes51MosNLLmYaBSqJzcG)4a3d3ELaCiH)OqGkxWJabIvPds59rIbMpYMJhrzvooM5RoHpf5(RNhrKT3E7FzqndHW7fCSJ0WJa3d2Sxj4isb7iZUDeEbNJmT3osiDe9G5JS5hrhrzvoUJOZUDKohlNJ0WJmXrIej6rKTVopcVGtNFhPLosDeUXMQZJKuEzJDKq6iTxdEKvncDez7ib1CezrpYSBhXsWrcPJm72r4fCC3)IpDKWLF1hs59rIbMpYMJhrzvoR1sVWGcHH7fd8CZfRlOPqwooG5JS5yEKqkV20r6SSKrgqOqzkjj3QgbWTxd6GtXfB52RbXqTAvAamGI15Nds59rIbMpYMJhrzvoI)Q3lM2B4jWTxd6keYXmF1j8jVGdEAVTHqHt7n8eyqBpfz77FXNos4YV6RfRmgg2A7rUwl9ktjj5w1iaU9AqhCkUyI)kYczkjjhW8r2CmpyMdofxSNVISqMssYbmFKnhRfRmMdeRYfqndHWtX(Sb6AVgkGDKpf5(x8PJeU8R(Gi8R1sVtHSCCGi8ollzKbwWmjMb3lzKTyAVHNadAt81bX4ar4DmZxDcxEZT34(x8PJeU8R(7vcWHe(JcbQCTw6fguimCVyaXF)rOW1Hbfcd3lgq83nxWJabIvPJxiegWScaNcjMXGoM5RoHIV1fRZJabIvPds59rIbMpYMJhrzvooM5RoHIlY2cfUopceiwLoiL3hjgy(iBoEeLv54yMV6e(8Jd2cISykKLJdy(iBoMhjKYRnDKollzKbekKhbceRshKY7JedmFKnhpIYQCCmZxDcF(XbBHTUqqtHSCCaZhzZX8iHuETPJ0zzjJmWgBSyDbnfYYXbP8(iXc0itQTe4SSKrgqOqEeiqSkDqkVpsSanYKAlboM5RoHIV5gBC)l(0rcx(vFyqHWWH1IzR1sVWGcHH7fd88NfYussoG5JS5yEWmhCkUypFf5(x8PJeU8R(aZhPCGM1APxyqHWW9IbE(U5czkjjhW8r2CmpyMJsBX6RZJabIvPds59rIbMpYMJhrzvooM5RoHp1BHc5rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNqXfrKfcQemgRhZb3lqScIL7XCwwYidSHqHYussoG5JS5yEWmhCkUyI)UPqHYussoG5JS5yEWmhZ8vNWN)iu40Edpbg02tr(rOqzkjjhCVaXkiwUhZXmF1jCJ7FXNos4YV6Zlecx8PJeJA4SwwE7vMQraCHH7fdC)V)fF6iHozQgbWfgUxmWlmOqy4WAXS1APxbnfYYXbmFKnhZJes51MosNLLmYacfoT3e)XpcfQXmbWFCG7HBVsaoKWFuiqLleKmLKKtgfbarbhhZ8vNW7FXNosOtMQraCHH7fdS8R(W9ceRWYbAU)3)IpDKqhGhjo0S0yV7vcWHe(JcbQCnuNgMdE3C71AP3sWySEmN9BnuaBbmSwmwoDHCwwYidC)l(0rcDaEK4qZsJT8R(TxdfWoY1AP3sWySEmN9BnuaBbmSwmwoDHCwwYidSqMssYTQraC71Go4uCXexKfYusso73AOa2cyyTySC6c5aXQ8(x8PJe6a8iXHMLgB5x9br4xd1PH5G3n3((x8PJe6a8iXHMLgB5x93ReGdj8hfcu5AT0RgZea)XbUhU9kb4qc)rHavUaguimCVyaX3EHgZea)XborCWGcHHdRfZU)fF6iHoapsCOzPXw(vFG5JS5y4WS8B2xRLE1yMa4poW9WTxjahs4pkeOYfcsJzcG)4aNiU9kb4qc)rHavUyDzkjj3QgbWTxd6GtXft8hlk(0r62ReGdj8hfcuPRtSeQ)2NnU)fF6iHoapsCOzPXw(vF5gzqEqX(mSC4Lng8(x8PJe6a8iXHMLgB5x9HbfcdhwlMTgQtdZbVBU9AT0RGKPKKCYOiaik44yMV6eku40Et8FwOXmbWFCG7HBVsaoKWFuiqL3)IpDKqhGhjo0S0yl)QpKY7JelqJmP2sWAT0lmOqy4EXaV)C)l(0rcDaEK4qZsJT8R(FS2hnZWsg6JQyG1APxyqHWW9IbE)5(x8PJe6a8iXHMLgB5x95fcHbmRaWPqIzm4AT0lmOqy4EXaV)C)l(0rcDaEK4qZsJT8R(7vcWHe(JcbQCTw6fguimCVyG3FU)fF6iHoapsCOzPXw(v)9kb4qc)rHavUwl9cdkegUxmG4VBUqJzcG)4aNiU9kb4qc)rHavUyAVj(plwxJzcG)4a3dhmOqy4WAXmHcf0uilhhmOqy4WAXmNLLmYal0yMa4poW9Wb3lqSclhOzJ7VEEer2E7T)Lb1mecVxWXosdpcCpyZELGJifSJm72r4fCoY0E7iH0r0dMpYMFeDeLv54oIo72r6CSCosdpYehjsKOhr2(68i8coD(DKw6i1r4gBQopss5Ln2rcPJ0En4rw1i0rKTJeuZrKf9iZUDelbhjKoYSBhHxWXD)l(0rcDaEK4qZsJT8R(qkVpsmW8r2C8ikRYzTw6vJzcG)4a3dhW8r2CmCyw(n7cfQXmbWFCG7HBVsaoKWFuiqLl0yMa4poWjIBVsaoKWFuiqLcfkOPqwooG5JS5y4WS8B2DwwYidSqMssYTQraC71Go4uCXwU9AqmuRwLgadOyD(5GuEFKyG5JS54ruwLJ4V699V4thj0b4rIdnln2YV6dmFKYbAwRLEHbfcd3lg457MlKPKKCaZhzZX8GzoM5RoH3)IpDKqhGhjo0S0yl)QpVqiCXNosmQHZAz5TxzQgbWfgUxmW9)(x8PJe6AVgkGDKVTxdfWoY1AP31LPKKCRAea3EnOdofxmXF17fRddkegUxmWZnfkuJzcG)4a3dhVqimGzfaofsmJbfkuMssYTQraC71Go4uCXe)vWfkuJzcG)4a3dNCJmipOyFgwo8Ygdku46csJzcG)4a3d3ELaCiH)OqGkxiinMja(JdCI42ReGdj8hfcu5gBSqqAmta8hh4E42ReGdj8hfcu5cbPXmbWFCGte3ELaCiH)OqGkxitjj5aMpYMJ1IvgZbIv5gcfU(0Edpbg02Znxitjj5w1iaU9AqhCkUyIV9gcfUUgZea)XborC8cHWaMva4uiXmgCHmLKKBvJa42RbDWP4IjUile0uilhhW8r2CmVqOo)CwwYidSX9V4thj01Enua7ix(v)pw7JMzyjd9rvmWAT0lpceiwLoiL3hjgy(iBoEeLv54yMV6e(8XMcfkitVMQ10mG7XMISPEl43)IpDKqx71qbSJC5x95fcHbmRaWPqIzm4AT0768iqGyv6GuEFKyG5JS54ruwLJJz(Qt4tbFHmLKKdy(iBoMxiuNFoM5RoHBiu468iqGyv6GuEFKyG5JS54ruwLJJz(Qt4ZhpwiizkjjhW8r2CmVqOo)CmZxDc3qOqEeiqSkDqkVpsmW8r2C8ikRYXXmF1ju8hB9(x8PJe6AVgkGDKl)QpKY7JedmFKnhpIYQCU)fF6iHU2RHcyh5YV6Vxjahs4pkeOY1APxyqHWW9Ibe)9N7FXNosOR9AOa2rU8R(7vcWHe(JcbQCTw6fguimCVyaXF3CX6RVUgZea)XborC7vcWHe(JcbQuOqzkjj3QgbWTxd6GtXft83n3yHmLKKBvJa42RbDWP4I9uW3qOqEeiqSkDqkVpsmW8r2C8ikRYXXmF1j857hhSferOqzkjjhW8r2CSwSYyoM5RoHI)XbBbr24(x8PJe6AVgkGDKl)QpW8rkhOzTw6vJzcG)4a3d3ELaCiH)OqGkxadkegUxmG4VpwSUmLKKBvJa42RbDWP4I98DtHc1yMa4poWTPBVsaoKWFuiqLBSaguimCVyGNBDHmLKKdy(iBoMhmZrPD)l(0rcDTxdfWoYLF1hs59rIfOrMuBjyTw6DDEeiqSkDqkVpsmW8r2C8ikRYXXmF1ju8TU9cOMHq4PyF2aDTxdfWoYNVISHqH8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4ZhIC)l(0rcDTxdfWoYLF1xUrgKhuSpdlhEzJbxRLE5rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNqXf87FXNosOR9AOa2rU8R(WGcHHdRfZwRLEHbfcd3lg45plKPKKCaZhzZX8Gzo4uCXE(kY9V4thj01Enua7ix(vFG5JuoqZAT0lmOqy4EXapF3CHmLKKdy(iBoMhmZrPTyDzkjjhW8r2CmpyMdofxmXF3uOqzkjjhW8r2CmpyMJz(Qt4Z3poyl8JtVSX9V4thj01Enua7ix(vFqe(14IYrgEk2NnW3hR5RFJ5IYrgEk2NnWx9YAT0lZKygCVKr29V4thj01Enua7ix(vFEHq4IpDKyudN1YYBVYuncGlmCVyG7)9V4thj0L2SBmSwWMc9Ylecx8PJeJA4SwwE7nTz3yyTGnfclt1iqNFR1sV8iqGyv6sB2ngwlytHCmZxDcFkY23)IpDKqxAZUXWAbBk0YV6Zlecx8PJeJA4SwwE7nTz3yyTGnfcx8PfWwRLELPKKCPn7gdRfSPqokT7)9V4thj0L2SBmSwWMcHl(0cyVYnYG8GI9zy5WlBm49V4thj0L2SBmSwWMcHl(0cyl)Q)hR9rZmSKH(OkgyTw6LhbceRshKY7JedmFKnhpIYQCCmZxDcF(ytHcfKPxt1AAgW9ytr2uVf87FXNosOlTz3yyTGnfcx8PfWw(vFiL3hjwGgzsTLG1APxEeiqSkDqkVpsmW8r2C8ikRYXXmF1ju8TUTqH8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4ZhIC)l(0rcDPn7gdRfSPq4IpTa2YV6ZlecdywbGtHeZyW1AP315rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWNc(czkjjhW8r2CmVqOo)CmZxDc3qOW15rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWNpESqqYussoG5JS5yEHqD(5yMV6eUHqH8iqGyv6GuEFKyG5JS54ruwLJJz(QtO4p269V4thj0L2SBmSwWMcHl(0cyl)QpVqiCXNosmQHZAz5TxzQgbWfgUxmWAT0lmOqy4EXaVpwSopceiwLoEHqyaZkaCkKygd6yMV6e(S4thPdUxGyfwoqJJxWbpT3ekC9Pqwoo5gzqEqX(mSC4Lng0zzjJmWcEeiqSkDYnYG8GI9zy5WlBmOJz(Qt4ZIpDKo4EbIvy5anoEbh80EBJnU)fF6iHU0MDJH1c2uiCXNwaB5x93ReGdj8hfcu5AT076RZJabIvPJxiegWScaNcjMXGoM5RoHIx8PJ0bmFKYbAC8co4P92glwNhbceRshVqimGzfaofsmJbDmZxDcfV4thPdUxGyfwoqJJxWbpT32yJfYussU0MDJH1c2uihZ8vNqX5fCWt7T7FXNosOlTz3yyTGnfcx8PfWw(vFiL3hjgy(iBoEeLv5Swl9ktjj5sB2ngwlytHCmZxDcF(ZcyqHWW9IbE3((x8PJe6sB2ngwlytHWfFAbSLF1hs59rIbMpYMJhrzvoR1sVYussU0MDJH1c2uihZ8vNWNfF6iDqkVpsmW8r2C8ikRYXXl4GN2BlVT7N7FXNosOlTz3yyTGnfcx8PfWw(vFG5JuoqZAT0RmLKKdy(iBoMhmZrPTaguimCVyGNVBE)l(0rcDPn7gdRfSPq4IpTa2YV6Zlecx8PJeJA4SwwE7vMQraCHH7fdC)V)fF6iHU0MDJH1c2uiSmvJaD(9M2SBmSwWMcTwl9cdkegUxmG4V)SyDbnfYYXPfRmgg2A7r6SSKrgqOqzkjjhW8r2CmpyMJsBJ7FXNosOlTz3yyTGnfclt1iqNFl)QpVqimGzfaofsmJbV)fF6iHU0MDJH1c2uiSmvJaD(T8R(7vcWHe(JcbQCTw6LhbceRshVqimGzfaofsmJbDmZxDcf)XVybmOqy4EXaI)U59V4thj0L2SBmSwWMcHLPAeOZVLF1xlwzmmS12JCTw6vMssYTQraC71Go4uCXe)vKfYussoG5JS5yEWmhCkUypFfzHmLKKdy(iBowlwzmhiwLlGbfcd3lgq83nV)fF6iHU0MDJH1c2uiSmvJaD(T8R(7vcWHe(JcbQCTw6fguimCVyaXF)5(x8PJe6sB2ngwlytHWYunc053YV6Zlecx8PJeJA4SwwE7vMQraCHH7fdOOfWyWosLUIS9dbF7nFSP7HE5XMk6vfl78dQO)11J(Luxb76(lXw8ihrND7iTxlyZrKc2r0J1ygp8Y1OhFeMPxt1mdCey4TJuut4RXahHVx5NbD3FbBDAh5NT4r0RsiLMwWgdCKIpDKhrpUZ0yyG5JeQh7U)3Fb7ETGng4i)IJu8PJ8iOgoq39xrxuZEWu00TxWsrJA4av6OOtB2ngwlytHu6O09HshfTLLmYaQLu0CwpgRlfnpceiwLU0MDJH1c2uihZ8vNWJ88iISTIU4thPIMxieU4thjg1WrrJA4GZYBk60MDJH1c2uiSmvJaD(PgLUIO0rrBzjJmGAjfnN1JX6srltjj5sB2ngwlytHCuAk6IpDKkAEHq4IpDKyudhfnQHdolVPOtB2ngwlytHWfFAbm1OgfnGhjo0S0ykDu6(qPJI2Ysgza1sk6IpDKk69kb4qc)rHavQO5SEmwxk6sWySEmN9BnuaBbmSwmwoDHCwwYidOOrDAyoqrV52QrPRikDu0wwYidOwsrZz9ySUu0LGXy9yo73AOa2cyyTySC6c5SSKrg4iloImLKKBvJa42RbDWP4IDeXpIihzXrKPKKC2V1qbSfWWAXy50fYbIvPIU4thPIU9AOa2rQgLUBQ0rrBzjJmGAjfDXNosfnicVIg1PH5af9MBRgLUBvPJI2Ysgza1skAoRhJ1LIwJzcG)4a3d3ELaCiH)OqGkpYIJadkegUxmWre)iBFKfhrJzcG)4aNioyqHWWH1Izk6IpDKk69kb4qc)rHavQgLU)O0rrBzjJmGAjfnN1JX6srRXmbWFCG7HBVsaoKWFuiqLhzXre0r0yMa4poWjIBVsaoKWFuiqLhzXrw)iYussUvncGBVg0bNIl2re)ipoYIJu8PJ0Txjahs4pkeOsxNyju)TphzdfDXNosfnW8r2CmCyw(n7QrPRER0rrx8PJurl3idYdk2NHLdVSXGkAllzKbulPgLU6fLokAllzKbulPOl(0rQOHbfcdhwlMPO5SEmwxkAbDezkjjNmkcaIcooM5RoHhrOWJmT3oI4h5NJS4iAmta8hh4E42ReGdj8hfcuPIg1PH5af9MBRgLU)cLokAllzKbulPO5SEmwxkAyqHWW9IboY7r(rrx8PJurdP8(iXc0itQTeOgLUcUshfTLLmYaQLu0CwpgRlfnmOqy4EXah59i)OOl(0rQO)yTpAMHLm0hvXaQrP7JTv6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4iVh5hfDXNosfnVqimGzfaofsmJbvJs3hpu6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4iVh5hfDXNosf9ELaCiH)OqGkvJs3hIO0rrBzjJmGAjfnN1JX6srddkegUxmWre)9iBEKfhrJzcG)4aNiU9kb4qc)rHavEKfhzAVDeXpYphzXrw)iAmta8hh4E4GbfcdhwlMDeHcpIGoYuilhhmOqy4WAXmNLLmYahzXr0yMa4poW9Wb3lqSclhO5iBOOl(0rQO3ReGdj8hfcuPAu6(ytLokAllzKbulPO5SEmwxkAnMja(JdCpCaZhzZXWHz53SFeHcpIgZea)XbUhU9kb4qc)rHavEKfhrJzcG)4aNiU9kb4qc)rHavEeHcpIGoYuilhhW8r2CmCyw(n7ollzKboYIJitjj5w1iaU9AqhCkUyhz5J0EnigQvRsdGbuSo)CqkVpsmW8r2C8ikRY5iI)Ee9wrx8PJurdP8(iXaZhzZXJOSkh1O09Xwv6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4ipFpYMhzXrKPKKCaZhzZX8GzoM5RoHk6IpDKkAG5JuoqJAu6(4hLokAllzKbulPOl(0rQO5fcHl(0rIrnCu0Ogo4S8MIwMQraCHH7fdOg1OObMurHgLokDFO0rrx8PJurd1mecJcUykAllzKbulPgLUIO0rrBzjJmGAjfnN1JX6srRzJdy(iBoEeLv54k(0cyhzXrw)ic6itHSCCPn7gdRfSPqollzKboIqHhrMssYL2SBmSwWMc5O0oYghrOWJmT3WtGbTDKNhzZTv0fF6iv0AX0rQgLUBQ0rrBzjJmGAjfnN1JX6srRzJdy(iBoEeLv54k(0cyhrOWJmT3WtGbTDKNVh5Xpk6IpDKkAkOH7X8q1O0DRkDu0wwYidOwsrZz9ySUu0A24aMpYMJhrzvoUIpTa2rek8it7n8eyqBh557rE8JIU4thPIw2yqJjwNFQrP7pkDu0wwYidOwsrZz9ySUu0A24aMpYMJhrzvoUIpTa2rek8it7n8eyqBh557rE8JIU4thPIwgfbalrXevnkD1BLokAllzKbulPO5SEmwxkAnBCaZhzZXJOSkhxXNwa7icfEKP9gEcmOTJ889ip(rrx8PJurl1mtgfbqnkD1lkDu0wwYidOwsrZz9ySUu0tHSCCaZhzZX8iHuETPJ0zzjJmWrwCKP92rEEKn3(iloIGocpceiwLoiL3hjgy(iBoEeLv54yMV6eQOl(0rQO5fcHl(0rIrnCu0Ogo4S8MIgWJehAwAm1O09xO0rrBzjJmGAjfnN1JX6srxcgJ1J5SFRHcylGH1IXYPlKJvPyhzXrM2Bh55r(5ilocmOqy4EXahr8JiYrwCezkjjN9BnuaBbmSwmwoDHCGyvEKfhrMssYTQraC71Go4uCXoYZJS5rwCebDenMja(JdCpC7vcWHe(JcbQ8iloIGoIgZea)XborC7vcWHe(JcbQurx8PJurVxjahs4pkeOs1O0vWv6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4ipFpYMhzXrKPKKCaZhzZX8GzokTJS4iYussoG5JS5yEWmhCkUyh59iBvrx8PJurdmFKYbAuJs3hBR0rrBzjJmGAjfnN1JX6srxcgJ1J5SFRHcylGH1IXYPlKJvPyhzXrKPKKCRAea3EnOdofxSJi(re5iloImLKKZ(TgkGTagwlglNUqoM5RoHh55rk(0r6G7fiwHLd04SFBCQXWt7TJS4iRFebDKPqwooG5JS5yEKqkV20r6SSKrg4icfEeEeiqSkDqkVpsmW8r2C8ikRYXXmF1j8iIFKhICKnu0fF6iv0TxdfWos1O09XdLokAllzKbulPO5SEmwxkAbDKP5I153rwCKP9gEcmOTJi(r2C7JS4iqndHWtX(Sb6AVgkGDKh55rerrx8PJurdIWRgLUperPJI2Ysgza1skAoRhJ1LIUemgRhZz)wdfWwadRfJLtxihRsXoI4hz7JS4it7TJ88ip2(ilocuZqi8uSpBGU2RHcyh5rEEeroYIJitjj5amRaWPqIzmOJz(Qt4rwCKPqwoU0MDJH1c2uiNLLmYak6IpDKkA5gzqEqX(mSC4LngunkDFSPshfTLLmYaQLu0CwpgRlf96hrMssYTQraC71Go4uCXoYZJO3hrOWJitjj5aMpYMJ1IvgZrPDKnoIqHhbQzieEk2Nnqx71qbSJ8ippIik6IpDKkAG5JS5y4WS8B2vJs3hBvPJI2Ysgza1skAoRhJ1LIEkKLJlTz3yyTGnfYzzjJmWrwCeOMHq4PyF2aDTxdfWoYJ889iIOOl(0rQO5fcHl(0rIrnCu0Ogo4S8MIoTz3yyTGnfsnkDF8JshfTLLmYaQLu0CwpgRlfnuZqi8uSpBGU2RHcyh5re)ipu0fF6iv08cHWfF6iXOgokAudhCwEtr3Enua7ivJs3h6TshfTLLmYaQLu0CwpgRlf96hzAVHNadA7iIFKhIS9rek8it7n8eyqBh55r4rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWJS8rE8Zrek8i8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4rEEKhBEKnu0fF6iv0FS2hnZWsg6JQya1O09HErPJI2Ysgza1skAoRhJ1LIMhbceRshKY7JedmFKnhpIYQCCmZxDcpI4hzRBFeHcpcpceiwLoiL3hjgy(iBoEeLv54yMV6eEKNh5Hik6IpDKkAiL3hjwGgzsTLa1O09XVqPJI2Ysgza1skAoRhJ1LIE9JWJabIvPds59rIbMpYMJhrzvooM5RoHh55re8JS4iYussoG5JS5yEHqD(5yMV6eEKnoIqHhz9JWJabIvPds59rIbMpYMJhrzvooM5RoHh55rE84iloIGoImLKKdy(iBoMxiuNFoM5RoHhzJJiu4r4rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWJi(rESvfDXNosfnVqimGzfaofsmJbvJs3hcUshfDXNosfTCJmipOyFgwo8YgdQOTSKrgqTKAu6kY2kDu0wwYidOwsrZz9ySUu0RFKsWySEmNCHmjkeUtbcEnDKollzKboIqHhzkKLJdy(iBoMhjKYRnDKollzKboYghzXr0yMa4poW9WTxjahs4pkeOYJS4i8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4rEEeru0fF6iv07vcWHe(JcbQunkDf5HshfTLLmYaQLu0CwpgRlfnmOqy4EXah55r28iloY6hrqhzkKLJdy(iBoMhjKYRnDKollzKboIqHhrMssYTQraC71Go4uCXoYYhP9AqmuRwLgadOyD(5GuEFKyG5JS54ruwLZre)9i69rwCKP9gEcC71GUcHCmZxDcpYZJWl4GN2BhzJJiu4rM2B4jWG2oYZJiY2k6IpDKkAiL3hjgy(iBoEeLv5OgLUIiIshfTLLmYaQLu0CwpgRlfTmLKKBvJa42RbDWP4IDeXFpIihzXrKPKKCaZhzZX8Gzo4uCXoYZ3JiYrwCezkjjhW8r2CSwSYyoqSkpYIJa1mecpf7ZgOR9AOa2rEKNhrefDXNosfTwSYyyyRThPAu6kYMkDu0wwYidOwsrZz9ySUu0tHSCCGi8ollzKboYIJWmjMb3lzKDKfhzAVHNadA7iIFK1pcighicVJz(Qt4rw(iBU9r2qrx8PJurdIWRgLUISvLokAllzKbulPO5SEmwxkAyqHWW9IboI4Vh5NJiu4rw)iWGcHH7fdCeXFpYMhzXr4rGaXQ0XlecdywbGtHeZyqhZ8vNWJi(r26rwCK1pcpceiwLoiL3hjgy(iBoEeLv54yMV6eEeXpIiBFeHcpY6hHhbceRshKY7JedmFKnhpIYQCCmZxDcpYZJ8XbhzlCeroYIJmfYYXbmFKnhZJes51MosNLLmYahrOWJWJabIvPds59rIbMpYMJhrzvooM5RoHh55r(4GJSfoYwpYIJiOJmfYYXbmFKnhZJes51MosNLLmYahzJJSXrwCK1pIGoYuilhhKY7JelqJmP2sGZYsgzGJiu4r4rGaXQ0bP8(iXc0itQTe4yMV6eEeXpYMhzJJSHIU4thPIEVsaoKWFuiqLQrPRi)O0rrBzjJmGAjfnN1JX6srddkegUxmWrEEKFoYIJitjj5aMpYMJ5bZCWP4IDKNVhrefDXNosfnmOqy4WAXm1O0ve9wPJI2Ysgza1skAoRhJ1LIgguimCVyGJ889iBEKfhrMssYbmFKnhZdM5O0oYIJS(rw)i8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4rEEe9(icfEeEeiqSkDqkVpsmW8r2C8ikRYXXmF1j8iIFere5iloIGosjymwpMdUxGyfel3J5SSKrg4iBCeHcpImLKKdy(iBoMhmZbNIl2re)9iBEeHcpImLKKdy(iBoMhmZXmF1j8ippYphrOWJmT3WtGbTDKNhrKFoIqHhrMssYb3lqScIL7XCmZxDcpYgk6IpDKkAG5JuoqJAu6kIErPJI2Ysgza1sk6IpDKkAEHq4IpDKyudhfnQHdolVPOLPAeaxy4EXaQrnkAnMXdVCnkDu6(qPJI2Ysgza1sQrPRikDu0wwYidOwsnkD3uPJI2Ysgza1sQrP7wv6OOl(0rQOHuEFKyjd9rvmGI2Ysgza1sQrP7pkDu0wwYidOwsrZz9ySUu0tHSCCDMgddmFKqNLLmYak6IpDKk6otJHbMpsOAu6Q3kDu0wwYidOwsnkD1lkDu0fF6iv0AX0rQOTSKrgqTKAu6(lu6OOTSKrgqTKIMZ6XyDPOLPKKCRAea3EnOdofxSJi(rECKfhrMssYbmFKnhZdM5aXQurx8PJurRfRmgg2A7rQgLUcUshfTLLmYaQLu0CwpgRlfTCaHhrOWJu8PJ0bmFKYbAC8coh59iBROl(0rQObMps5anQrP7JTv6OOTSKrgqTKIMZ6XyDPOf0rKdi8icfEKIpDKoG5JuoqJJxW5iIFKTv0fF6iv0W9ceRWYbAuJAu0TxdfWosLokDFO0rrBzjJmGAjfnN1JX6srV(rKPKKCRAea3EnOdofxSJi(7r07JS4iRFeyqHWW9IboYZJS5rek8iAmta8hh4E44fcHbmRaWPqIzm4rek8iYussUvncGBVg0bNIl2re)9ic(rek8iAmta8hh4E4KBKb5bf7ZWYHx2yWJiu4rw)ic6iAmta8hh4E42ReGdj8hfcu5rwCebDenMja(JdCI42ReGdj8hfcu5r24iBCKfhrqhrJzcG)4a3d3ELaCiH)OqGkpYIJiOJOXmbWFCGte3ELaCiH)OqGkpYIJitjj5aMpYMJ1IvgZbIv5r24icfEK1pY0Edpbg02rEEKnpYIJitjj5w1iaU9AqhCkUyhr8JS9r24icfEK1pIgZea)XborC8cHWaMva4uiXmg8iloImLKKBvJa42RbDWP4IDeXpIihzXre0rMcz54aMpYMJ5fc15NZYsgzGJSHIU4thPIU9AOa2rQgLUIO0rrBzjJmGAjfnN1JX6srZJabIvPds59rIbMpYMJhrzvooM5RoHh55rES5rek8ic6iMEnvRPza3QgjXmaed7VgHdjmKsZyDWWqkVpYo)u0fF6iv0FS2hnZWsg6JQya1O0DtLokAllzKbulPO5SEmwxk61pcpceiwLoiL3hjgy(iBoEeLv54yMV6eEKNhrWpYIJitjj5aMpYMJ5fc15NJz(Qt4r24icfEK1pcpceiwLoiL3hjgy(iBoEeLv54yMV6eEKNh5XJJS4ic6iYussoG5JS5yEHqD(5yMV6eEKnoIqHhHhbceRshKY7JedmFKnhpIYQCCmZxDcpI4h5Xwv0fF6iv08cHWaMva4uiXmgunkD3QshfDXNosfnKY7JedmFKnhpIYQCu0wwYidOwsnkD)rPJI2Ysgza1skAoRhJ1LIgguimCVyGJi(7r(rrx8PJurVxjahs4pkeOs1O0vVv6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4iI)EKnpYIJS(rw)iRFenMja(JdCI42ReGdj8hfcu5rek8iYussUvncGBVg0bNIl2re)9iBEKnoYIJitjj5w1iaU9AqhCkUyh55re8JSXrek8i8iqGyv6GuEFKyG5JS54ruwLJJz(Qt4rE(EKpo4iBHJiYrek8iYussoG5JS5yTyLXCmZxDcpI4h5JdoYw4iICKnu0fF6iv07vcWHe(JcbQunkD1lkDu0wwYidOwsrZz9ySUu0Amta8hh4E42ReGdj8hfcu5rwCeyqHWW9IboI4Vh5XrwCK1pImLKKBvJa42RbDWP4IDKNVhzZJiu4r0yMa4poWTPBVsaoKWFuiqLhzJJS4iWGcHH7fdCKNhzRhzXrKPKKCaZhzZX8GzoknfDXNosfnW8rkhOrnkD)fkDu0wwYidOwsrZz9ySUu0RFeEeiqSkDqkVpsmW8r2C8ikRYXXmF1j8iIFKTU9rwCeOMHq4PyF2aDTxdfWoYJ889iICKnoIqHhHhbceRshKY7JedmFKnhpIYQCCmZxDcpYZJ8qefDXNosfnKY7JelqJmP2sGAu6k4kDu0wwYidOwsrZz9ySUu08iqGyv6GuEFKyG5JS54ruwLJJz(Qt4re)icUIU4thPIwUrgKhuSpdlhEzJbvJs3hBR0rrBzjJmGAjfnN1JX6srddkegUxmWrEEKFoYIJitjj5aMpYMJ5bZCWP4IDKNVhrefDXNosfnmOqy4WAXm1O09XdLokAllzKbulPO5SEmwxkAyqHWW9IboYZ3JS5rwCezkjjhW8r2CmpyMJs7iloY6hrMssYbmFKnhZdM5GtXf7iI)EKnpIqHhrMssYbmFKnhZdM5yMV6eEKNVh5JdoYw4i)40lhzdfDXNosfnW8rkhOrnkDFiIshfTLLmYaQLu0fF6iv0Gi8kAUOCKHNI9zduP7dfTV(nMlkhz4PyF2av06ffnN1JX6srZmjMb3lzKPgLUp2uPJI2Ysgza1sk6IpDKkAEHq4IpDKyudhfnQHdolVPOLPAeaxy4EXaQrnk60MDJH1c2uiSmvJaD(P0rP7dLokAllzKbulPO5SEmwxkAyqHWW9IboI4Vh5NJS4iRFebDKPqwooTyLXWWwBpsNLLmYahrOWJitjj5aMpYMJ5bZCuAhzdfDXNosfDAZUXWAbBkKAu6kIshfDXNosfnVqimGzfaofsmJbv0wwYidOwsnkD3uPJI2Ysgza1skAoRhJ1LIMhbceRshVqimGzfaofsmJbDmZxDcpI4h5XV4ilocmOqy4EXahr83JSPIU4thPIEVsaoKWFuiqLQrP7wv6OOTSKrgqTKIMZ6XyDPOLPKKCRAea3EnOdofxSJi(7re5iloImLKKdy(iBoMhmZbNIl2rE(EeroYIJitjj5aMpYMJ1IvgZbIv5rwCeyqHWW9IboI4VhztfDXNosfTwSYyyyRThPAu6(JshfTLLmYaQLu0CwpgRlfnmOqy4EXahr83J8JIU4thPIEVsaoKWFuiqLQrPRER0rrBzjJmGAjfDXNosfnVqiCXNosmQHJIg1WbNL3u0YuncGlmCVya1OgfTmvJa4cd3lgqPJs3hkDu0wwYidOwsrZz9ySUu0c6itHSCCaZhzZX8iHuETPJ0zzjJmWrek8it7TJi(rE8Zrek8iAmta8hh4E42ReGdj8hfcu5rwCebDezkjjNmkcaIcooM5RoHk6IpDKkAyqHWWH1IzQrPRikDu0fF6iv0W9ceRWYbAu0wwYidOwsnQrrN2SBmSwWMcHl(0cykDu6(qPJIU4thPIwUrgKhuSpdlhEzJbv0wwYidOwsnkDfrPJI2Ysgza1skAoRhJ1LIMhbceRshKY7JedmFKnhpIYQCCmZxDcpYZJ8yZJiu4re0rm9AQwtZaUvnsIzaig2FnchsyiLMX6GHHuEFKD(POl(0rQO)yTpAMHLm0hvXaQrP7MkDu0wwYidOwsrZz9ySUu08iqGyv6GuEFKyG5JS54ruwLJJz(Qt4re)iBD7Jiu4r4rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWJ88iperrx8PJurdP8(iXc0itQTeOgLUBvPJI2Ysgza1skAoRhJ1LIE9JWJabIvPds59rIbMpYMJhrzvooM5RoHh55re8JS4iYussoG5JS5yEHqD(5yMV6eEKnoIqHhz9JWJabIvPds59rIbMpYMJhrzvooM5RoHh55rE84iloIGoImLKKdy(iBoMxiuNFoM5RoHhzJJiu4r4rGaXQ0bP8(iXaZhzZXJOSkhhZ8vNWJi(rESvfDXNosfnVqimGzfaofsmJbvJs3Fu6OOTSKrgqTKIMZ6XyDPOHbfcd3lg4iVh5XrwCK1pcpceiwLoEHqyaZkaCkKygd6yMV6eEKNhP4thPdUxGyfwoqJJxWbpT3oIqHhz9JmfYYXj3idYdk2NHLdVSXGollzKboYIJWJabIvPtUrgKhuSpdlhEzJbDmZxDcpYZJu8PJ0b3lqSclhOXXl4GN2BhzJJSHIU4thPIMxieU4thjg1WrrJA4GZYBkAzQgbWfgUxmGAu6Q3kDu0wwYidOwsrZz9ySUu0RFK1pcpceiwLoEHqyaZkaCkKygd6yMV6eEeXpsXNoshW8rkhOXXl4GN2BhzJJS4iRFeEeiqSkD8cHWaMva4uiXmg0XmF1j8iIFKIpDKo4EbIvy5anoEbh80E7iBCKnoYIJitjj5sB2ngwlytHCmZxDcpI4hHxWbpT3u0fF6iv07vcWHe(JcbQunkD1lkDu0wwYidOwsrZz9ySUu0YussU0MDJH1c2uihZ8vNWJ88i)CKfhbguimCVyGJ8EKTv0fF6iv0qkVpsmW8r2C8ikRYrnkD)fkDu0wwYidOwsrZz9ySUu0YussU0MDJH1c2uihZ8vNWJ88ifF6iDqkVpsmW8r2C8ikRYXXl4GN2Bhz5JST7hfDXNosfnKY7JedmFKnhpIYQCuJsxbxPJI2Ysgza1skAoRhJ1LIwMssYbmFKnhZdM5O0oYIJadkegUxmWrE(EKnv0fF6iv0aZhPCGg1O09X2kDu0wwYidOwsrx8PJurZlecx8PJeJA4OOrnCWz5nfTmvJa4cd3lgqnQrnQrnkfa]] )


end
