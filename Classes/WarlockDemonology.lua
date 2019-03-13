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


    spec:RegisterPack( "Demonology", 20190313.1713, [[dS0NCbqicvwKQGQhrQkDjvbfTjLWNiuv1Ouk6ukPAvQcWRuImlLuULQaTlQ6xKQmmvHoMsPLraptPW0uvvUMQQSnsvLVPQQY4ufeNJuvSovbP5Pk6EQs7Jq5GQckTqLOEOQQQmrcvLlQkGQpQkGsNKqvfRuvLzQQQQ6MeQQ0ojv6NQckmusvvSuvbu8uKAQKkUQQaYxvvvv2lj)fyWioSKftupgvtg0LPSzI8zvLrRuDAPEnHy2qDBQSBr)wy4KYXjvvPLJYZHmDfxhjBNa9DLKXtOkNNqA9KQQA(e0(vz1wLokAynMsxbECR(84gB3WV9)2UHa)trpIQzkATIls9zk6SCMIw8zUidC8jQIwRefhfuPJIgfumUPO3Nrd9q1tVVE2PK98WPhQDu4A6i5SsA0d1oUEkAzQgpIFsLSIgwJP0vGh3QppUX2n8B)VTBiGakAKMXv6kG(PFk69gcTujROHgIRO13Ji(mxKbo(e9i)FfdhCrUF67r2Nrd9q1tVVE2PK98WPhQDu4A6i5SsA0d1oUE3p99iIFlgF)iB3yTJiWJB1NJ8Ghz7)9q3kW97(PVh5)Tx5NHEO3p99ip4rO1mm(i))bxe)9tFpYdEKhiKDezkjjFAZUXaAbBkSNs7iDIgRGhjKocZCvND(DK)N47it7SJifSJORn7g7i6pbBk8rk(0cAhrBVqM)(PVh5bpYdJel6rygpColHhr8zUiLd8CenM9G8WjxZrAPJ0ZrA0r6envohzt0EqHHhrJfYLmw0JGMgJpYEXG8cnR7VF67rEWJO)eRm2rOBT9ipsHXXkdEenM9G8WjxZrM4iASGFKortLZreFMls5ap(7N(EKh8ipSq4rcnln2rO3lyS6ilh45ib1GAODKq6iYbcDeP(BFqhzIJuZrWwHMJ8zZrI0oIly2rq7fd6VF67rEWJ8aHSJ8WN2zGjaW2E4hztt80m(yWJyjpOYXyhXs46hHvZUXoYSx5rE4tX(SXpTZataGT9WpYMM4Pz8XGhHtXywohzk2NnI)OJaTA2x)itCKsWOHhXepUHqTG2rKPyzNFhjKocR4DHpY)t8H8kAnwi1ytrRVhr8zUidC8j6r()kgo4IC)03JSpJg6HQNEF9Stj75Htpu7OW10rYzL0OhQDC9UF67re)wm((r(3AhrGh3Qph5bpYwbEOp(3r0Fe)E)UF67r(F7v(zOh69tFpYdEeAndJpY)FWfXF)03J8Gh5bczhrMssYN2SBmGwWMc7P0osNOXk4rcPJWmx1zNFh5)j(oY0o7isb7i6AZUXoI(tWMcFKIpTG2r02lK5VF67rEWJ8WiXIEeMXdNZs4reFMls5aphrJzpipCY1CKw6i9CKgDKortLZr2eThuy4r0yHCjJf9iOPX4JSxmiVqZ6(7N(EKh8i6pXkJDe6wBpYJuyCSYGhrJzpipCY1CKjoIgl4hPt0u5CeXN5IuoWJ)(PVh5bpYdleEKqZsJDe69cgRoYYbEosqnOgAhjKoICGqhrQ)2h0rM4i1CeSvO5iF2CKiTJ4cMDe0EXG(7N(EKh8ipqi7ip8PDgycaSTh(r20epnJpg8iwYdQCm2rSeU(ry1SBSJm7vEKh(uSpB8t7mWeayBp8JSPjEAgFm4r4umMLZrMI9zJ4p6iqRM91pYehPemA4rmXJBiulODezkw253rcPJWkEx4J8)eFi)97(PVh5bU4zCQXGhr2KcMDeE4KR5iY2xNi)rEy5CtBqhjJ8b3lMtIcFKIpDKOJejwu)9R4thjYRXmE4KR5vcxirUFfF6irEnMXdNCnl9QNueW7xXNosKxJz8WjxZsV6vuFolNA6iVFfF6irEnMXdNCnl9QhIY5IeOzZ9R4thjYRXmE4KRzPx96mngaAUirR1sVtHTC8DMgdanxKiVLLm2G3VIpDKiVgZ4HtUMLE1dLLgApgaAQbD)k(0rI8AmJho5Aw6vpTy6iVFfF6irEnMXdNCnl9QNwSYyauRTh5AT0RmLKKFvJHG2PH8OP4Ii22fYussEO5IS5aEWmpmwL3VIpDKiVgZ4HtUMLE1dAUiLd8Swl9khiKqHfF6i9qZfPCGhpVqZ7J3VIpDKiVgZ4HtUMLE1dTxWyfqoWZAT0R4KdesOWIpDKEO5IuoWJNxOrShVF3p99ipWfpJtng8iMGgt0JmTZoYSBhP4tWosJosjy14sgB(7xXNos0lsZWyao4IC)k(0rIw6vpTy6ixRLE1SXdnxKnhmIYQC8fFAbTfBkUPWwo(0MDJb0c2uyVLLm2Gcfktjj5tB2ngqlytH9uARlu40odmba22ZnE8(v8PJeT0REuid0J5qR1sVA24HMlYMdgrzvo(IpTGMqHt7mWeayBpF3(39R4thjAPx9KngYyI053AT0RMnEO5IS5GruwLJV4tlOju40odmba22Z3T)D)k(0rIw6vpzCeqGeft01APxnB8qZfzZbJOSkhFXNwqtOWPDgycaSTNVB)7(v8PJeT0REsnZKXraxRLE1SXdnxKnhmIYQC8fFAbnHcN2zGjaW2E(U9V7xXNos0sV6Xlmgu8PJeGB0Swwo7fYJeyAGqZsJTwl9w6FJ1J5nXtdhOwqdOfJLtxypRsrwmf2YXdnxKnhWJer50MosVLLm2GlM2zp34XfIJhbggRspIY5IeanxKnhmIYQC8mZvDIUFfF6irl9Q3ELqqib(OWWkxRLEl9VX6X8M4PHdulOb0IXYPlSNvPilM2zp)BbkOWa0EXGIjWczkjjVjEA4a1cAaTySC6c7HXQCHmLKKFvJHG2PH8OP4I8CJfItJzcc(4q)w)ELqqib(OWWkxionMji4Jd9c43ReccjWhfgw59R4thjAPx9GMls5apR1sVOGcdq7fd(8DJfYussEO5IS5aEWmpL2czkjjp0Cr2CapyMhnfxK3)D)k(0rIw6vV2PHduh5AT0BP)nwpM3epnCGAbnGwmwoDH9SkfzHmLKKFvJHG2PH8OP4IiMalKPKK8M4PHdulOb0IXYPlSNzUQt0ZIpDKE0EbJva5apEt8mo1yGPD2Inf3uylhp0Cr2CapseLtB6i9wwYydkuipcmmwLEeLZfjaAUiBoyeLv54zMR6ej2wbw)(v8PJeT0REWiCR1sVIBAUiD(TyANbMaaBtSnECbsZWyWuSpBq(2PHduh5tbUFfF6irl9QNCJnepOyFgqoCYgdTwl9w6FJ1J5nXtdhOwqdOfJLtxypRsre7Xft7SNBFCbsZWyWuSpBq(2PHduh5tbwitjj5HmRGOPWIymKNzUQt0IPWwo(0MDJb0c2uyVLLm2G3VIpDKOLE1dAUiBoanml)M91AP3nLPKK8RAme0onKhnfxKN6NqHYussEO5IS5aTyLX8uARluisZWyWuSpBq(2PHduh5tbUFfF6irl9QhVWyqXNosaUrZAz5S30MDJb0c2u41AP3PWwo(0MDJb0c2uyVLLm2GlqAggdMI9zdY3onCG6iF(kW9R4thjAPx94fgdk(0rcWnAwllN92onCG6ixRLErAggdMI9zdY3onCG6ifB79R4thjAPx9(yTlAMbKm8hvXGR1sVBoTZataGTj2wbEuOWPDgycaSTN8iWWyv6ruoxKaO5IS5GruwLJNzUQt0sB)tOqEeyySk9ikNlsa0Cr2CWikRYXZmx1j652nw)(v8PJeT0REikNlsGGn2KAlHR1sV8iWWyv6ruoxKaO5IS5GruwLJNzUQtKy)7rHc5rGHXQ0JOCUibqZfzZbJOSkhpZCvNONBf4(v8PJeT0RE8cJbqMvq0uyrmgATw6DtEeyySk9ikNlsa0Cr2CWikRYXZmx1j6P(SqMssYdnxKnhWlmUZppZCvNO1fkCtEeyySk9ikNlsa0Cr2CWikRYXZmx1j652TleNmLKKhAUiBoGxyCNFEM5QorRluipcmmwLEeLZfjaAUiBoyeLv54zMR6ej22)D)k(0rIw6vp5gBiEqX(mGC4Kng6(v8PJeT0RE7vcbHe4JcdRCTw6DZs)BSEmVCHnjkmOtbdEnDKEllzSbfkCkSLJhAUiBoGhjIYPnDKEllzSbxFHgZee8XH(T(9kHGqc8rHHvUGhbggRspIY5IeanxKnhmIYQC8mZvDIEkW9tFpIap(4JpmrAggd2l0yhPrhbThSzVs4rKc2rMD7i8cnhzANDKq6iIpZfzZpIoIYQC8hrND7iDowohPrhzIJejw0JiBFDEeEHMo)oslDK6iCJnvNhjPCYg7iH0rANg6iRAm(iY2rcQ5iYIEKz3oILWJeshz2TJWl04VFfF6irl9QhIY5IeanxKnhmIYQCwRLErbfgG2lg85gl2uCtHTC8qZfzZb8iruoTPJ0BzjJnOqHYuss(vngcANgYJMIlYsTtdbqA1Q0GaifRZppIY5IeanxKnhmIYQCe7v)wmTZataANgYxySNzUQt0tEHgW0oBDHcN2zGjaW2EkWJ3VIpDKOLE1tlwzmaQ12JCTw6vMssYVQXqq70qE0uCre7vGfYussEO5IS5aEWmpAkUipFfyHmLKKhAUiBoqlwzmpmwLlqAggdMI9zdY3onCG6iFkW9R4thjAPx9Gr4wRLENcB54Hr48wwYydUGzsmdTxYyBX0odmba2MyBcJXdJW5zMR6eT0gpU(9R4thjAPx92ReccjWhfgw5AT0lkOWa0EXGI9(NqHBIckmaTxmOyVBSGhbggRspVWyaKzfenfweJH8mZvDIe7Fl2KhbggRspIY5IeanxKnhmIYQC8mZvDIetGhfkCtEeyySk9ikNlsa0Cr2CWikRYXZmx1j65hh(aeyXuylhp0Cr2CapseLtB6i9wwYydkuipcmmwLEeLZfjaAUiBoyeLv54zMR6e98JdFa)BH4McB54HMlYMd4rIOCAthP3YsgBW1xFXMIBkSLJhr5CrceSXMuBj0BzjJnOqH8iWWyv6ruoxKabBSj1wc9mZvDIeBJ1x)(v8PJeT0REOGcdqdRfXwRLErbfgG2lg85FlKPKK8qZfzZb8GzE0uCrE(kW9R4thjAPx9GMls5apR1sVOGcdq7fd(8DJfYussEO5IS5aEWmpL2In3KhbggRspIY5IeanxKnhmIYQC8mZvDIEQFcfYJadJvPhr5CrcGMlYMdgrzvoEM5QorIjGaRluOmLKKhAUiBoGhmZJMIlIyVBiuOmLKKhAUiBoGhmZZmx1j65FcfoTZataGT9uG)w)(v8PJeT0RE8cJbfF6ib4gnRLLZELPAmeua0EXG3V7xXNosKxMQXqqbq7fd(IckmanSweBTw6vCtHTC8qZfzZb8iruoTPJ0BzjJnOqHt7mX2(NqHAmtqWhh6363ReccjWhfgw5cXjtjj5LXraXuOXZmx1j6(v8PJe5LPAmeua0EXGl9QhAVGXkGCGN739R4thjYd5rcmnqOzPXE3ReccjWhfgw5A4onah(UXJ3VIpDKipKhjW0aHMLgBPx9ANgoqDKR1sVYuss(vngcANgYJMIlIycSqMssYBINgoqTGgqlglNUWEySkVFfF6irEipsGPbcnln2sV6bJWTgUtdWHVB849R4thjYd5rcmnqOzPXw6vV9kHGqc8rHHvUwl9QXmbbFCOFRFVsiiKaFuyyLlqbfgG2lguShxOXmbbFCOxapkOWa0WArS7xXNosKhYJeyAGqZsJT0REqZfzZbOHz53SVwl9QXmbbFCOFRFVsiiKaFuyyLleNgZee8XHEb87vcbHe4JcdRCXMYuss(vngcANgYJMIlIyBxu8PJ0VxjeesGpkmSsFNajC)TpRF)k(0rI8qEKatdeAwASLE1tUXgIhuSpdihozJHUFfF6irEipsGPbcnln2sV6HckmanSweBnCNgGdF34X1APxXjtjj5LXraXuOXZmx1jsOWPDMy)TqJzcc(4q)w)ELqqib(OWWkVFfF6irEipsGPbcnln2sV6HOCUibc2ytQTeUwl9IckmaTxm47F3VIpDKipKhjW0aHMLgBPx9(yTlAMbKm8hvXGR1sVOGcdq7fd((39R4thjYd5rcmnqOzPXw6vpEHXaiZkiAkSigdTwl9IckmaTxm47F3VIpDKipKhjW0aHMLgBPx92ReccjWhfgw5AT0lkOWa0EXGV)D)k(0rI8qEKatdeAwASLE1BVsiiKaFuyyLR1sVOGcdq7fdk27gl0yMGGpo0lGFVsiiKaFuyyLlM2zI93In1yMGGpo0V1JckmanSwetOqXnf2YXJckmanSweZBzjJn4cnMji4Jd9B9O9cgRaYbEw)(PVhrGhF8XhMindJb7fASJ0OJG2d2Sxj8isb7iZUDeEHMJmTZosiDeXN5IS5hrhrzvo(JOZUDKohlNJ0OJmXrIel6rKTVopcVqtNFhPLosDeUXMQZJKuozJDKq6iTtdDKvngFez7ib1CezrpYSBhXs4rcPJm72r4fA83VIpDKipKhjW0aHMLgBPx9quoxKaO5IS5GruwLZAT0RgZee8XH(TEO5IS5a0WS8B2fkuJzcc(4q)w)ELqqib(OWWkxOXmbbFCOxa)ELqqib(OWWkfkuCtHTC8qZfzZbOHz53S7TSKXgCHmLKKFvJHG2PH8OP4ISu70qaKwTkniasX68ZJOCUibqZfzZbJOSkhXE1V7xXNosKhYJeyAGqZsJT0REqZfPCGN1APxuqHbO9IbF(UXczkjjp0Cr2CapyMNzUQt09R4thjYd5rcmnqOzPXw6vpEHXGIpDKaCJM1YYzVYungckaAVyW739R4thjY3onCG6iFBNgoqDKR1sVBktjj5x1yiODAipAkUiI9QFl2efuyaAVyWNBiuOgZee8XH(TEEHXaiZkiAkSigdjuOmLKKFvJHG2PH8OP4Ii2R(iuOgZee8XH(TE5gBiEqX(mGC4KngsOWnfNgZee8XH(T(9kHGqc8rHHvUqCAmtqWhh6fWVxjeesGpkmSY1xFH40yMGGpo0V1VxjeesGpkmSYfItJzcc(4qVa(9kHGqc8rHHvUqMssYdnxKnhOfRmMhgRY1fkCZPDgycaSTNBSqMssYVQXqq70qE0uCre7X1fkCtnMji4Jd9c45fgdGmRGOPWIym0czkjj)QgdbTtd5rtXfrmbwiUPWwoEO5IS5aEHXD(5TSKXgC97xXNosKVDA4a1rU0REFS2fnZasg(JQyW1APxEeyySk9ikNlsa0Cr2CWikRYXZmx1j652nekuCM(lvRPzq)2neyd9tFUFfF6ir(2PHduh5sV6XlmgazwbrtHfXyO1AP3n5rGHXQ0JOCUibqZfzZbJOSkhpZCvNON6Zczkjjp0Cr2CaVW4o)8mZvDIwxOWn5rGHXQ0JOCUibqZfzZbJOSkhpZCvNONB3UqCYussEO5IS5aEHXD(5zMR6eTUqH8iWWyv6ruoxKaO5IS5GruwLJNzUQtKyB)39R4thjY3onCG6ix6vpeLZfjaAUiBoyeLv5C)k(0rI8TtdhOoYLE1BVsiiKaFuyyLR1sVOGcdq7fdk27F3VIpDKiF70WbQJCPx92ReccjWhfgw5AT0lkOWa0EXGI9UXIn3CtnMji4Jd9c43ReccjWhfgwPqHYuss(vngcANgYJMIlIyVBS(czkjj)QgdbTtd5rtXf5P(SUqH8iWWyv6ruoxKaO5IS5GruwLJNzUQt0Z3po8biGqHYussEO5IS5aTyLX8mZvDIe7JdFacS(9R4thjY3onCG6ix6vpO5IuoWZAT0RgZee8XH(T(9kHGqc8rHHvUafuyaAVyqXE3Uytzkjj)QgdbTtd5rtXf557gcfQXmbbFCOFd)ELqqib(OWWkxFbkOWa0EXGp)3czkjjp0Cr2CapyMNs7(v8PJe5BNgoqDKl9QhIY5IeiyJnP2s4AT07M8iWWyv6ruoxKaO5IS5GruwLJNzUQtKy)7XfindJbtX(Sb5BNgoqDKpFfyDHc5rGHXQ0JOCUibqZfzZbJOSkhpZCvNONBf4(v8PJe5BNgoqDKl9QNCJnepOyFgqoCYgdTwl9YJadJvPhr5CrcGMlYMdgrzvoEM5QorIPp3VIpDKiF70WbQJCPx9qbfgGgwlITwl9IckmaTxm4Z)witjj5HMlYMd4bZ8OP4I88vG7xXNosKVDA4a1rU0REqZfPCGN1APxuqHbO9IbF(UXczkjjp0Cr2CapyMNsBXMYussEO5IS5aEWmpAkUiI9UHqHYussEO5IS5aEWmpZCvNONVFC4d4p))T(9R4thjY3onCG6ix6vpyeU14IYXgyk2NnO3TR5kXdWfLJnWuSpBqV)3AT0lZKygAVKX29R4thjY3onCG6ix6vpEHXGIpDKaCJM1YYzVYungckaAVyW739R4thjYN2SBmGwWMc)Ylmgu8PJeGB0Swwo7nTz3yaTGnfgit1yyNFR1sV8iWWyv6tB2ngqlytH9mZvDIEkWJ3VIpDKiFAZUXaAbBk8sV6Xlmgu8PJeGB0Swwo7nTz3yaTGnfgu8Pf0wRLELPKK8Pn7gdOfSPWEkT739R4thjYN2SBmGwWMcdk(0cAVYn2q8GI9za5WjBm09R4thjYN2SBmGwWMcdk(0cAl9Q3hRDrZmGKH)OkgCTw6LhbggRspIY5IeanxKnhmIYQC8mZvDIEUDdHcfNP)s1AAg0VDdb2q)0N7xXNosKpTz3yaTGnfgu8Pf0w6vpeLZfjqWgBsTLW1APxEeyySk9ikNlsa0Cr2CWikRYXZmx1jsS)9OqH8iWWyv6ruoxKaO5IS5GruwLJNzUQt0ZTcC)k(0rI8Pn7gdOfSPWGIpTG2sV6XlmgazwbrtHfXyO1AP3n5rGHXQ0JOCUibqZfzZbJOSkhpZCvNON6Zczkjjp0Cr2CaVW4o)8mZvDIwxOWn5rGHXQ0JOCUibqZfzZbJOSkhpZCvNONB3UqCYussEO5IS5aEHXD(5zMR6eTUqH8iWWyv6ruoxKaO5IS5GruwLJNzUQtKyB)39R4thjYN2SBmGwWMcdk(0cAl9QhVWyqXNosaUrZAz5SxzQgdbfaTxm4AT0lkOWa0EXGVBxSjpcmmwLEEHXaiZkiAkSigd5zMR6e9S4thPhTxWyfqoWJNxObmTZekCZPWwoE5gBiEqX(mGC4KngYBzjJn4cEeyySk9Yn2q8GI9za5WjBmKNzUQt0ZIpDKE0EbJva5apEEHgW0oB91VFfF6ir(0MDJb0c2uyqXNwqBPx92ReccjWhfgw5AT07MBYJadJvPNxymaYScIMclIXqEM5QorIv8PJ0dnxKYbE88cnGPD26l2KhbggRspVWyaKzfenfweJH8mZvDIeR4thPhTxWyfqoWJNxObmTZwF9fYuss(0MDJb0c2uypZCvNiX4fAat7S7xXNosKpTz3yaTGnfgu8Pf0w6vpeLZfjaAUiBoyeLv5Swl9ktjj5tB2ngqlytH9mZvDIE(3cuqHbO9IbFF8(v8PJe5tB2ngqlytHbfFAbTLE1dr5CrcGMlYMdgrzvoR1sVYuss(0MDJb0c2uypZCvNONfF6i9ikNlsa0Cr2CWikRYXZl0aM2zl9O)V7xXNosKpTz3yaTGnfgu8Pf0w6vpO5IuoWZAT0RmLKKhAUiBoGhmZtPTafuyaAVyWNVBC)k(0rI8Pn7gdOfSPWGIpTG2sV6Xlmgu8PJeGB0Swwo7vMQXqqbq7fdE)UFfF6ir(0MDJb0c2uyGmvJHD(9M2SBmGwWMcVwl9IckmaTxmOyV)TytXnf2YXRfRmga1A7r6TSKXguOqzkjjp0Cr2CapyMNsB97xXNosKpTz3yaTGnfgit1yyNFl9QhVWyaKzfenfweJHUFfF6ir(0MDJb0c2uyGmvJHD(T0RE7vcbHe4JcdRCTw6LhbggRspVWyaKzfenfweJH8mZvDIeB7dzbkOWa0EXGI9UX9R4thjYN2SBmGwWMcdKPAmSZVLE1tlwzmaQ12JCTw6vMssYVQXqq70qE0uCre7vGfYussEO5IS5aEWmpAkUipFfyHmLKKhAUiBoqlwzmpmwLlqbfgG2lguS3nUFfF6ir(0MDJb0c2uyGmvJHD(T0RE7vcbHe4JcdRCTw6ffuyaAVyqXE)7(v8PJe5tB2ngqlytHbYung253sV6Xlmgu8PJeGB0Swwo7vMQXqqbq7fdQOf0yOosLUc84w95XnE8p)wbe4pf9QILD(Hu0)FpSpWOR4hDFG9HEKJOZUDK2PfS5isb7iI)AmJho5Ae)pcZ0FPAMbpckC2rkQjC1yWJW3R8Zq(73)FN2r(7HEKhOerPPfSXGhP4th5re)7mngaAUirI)(739t8JtlyJbpYd5ifF6ipcUrdYF)u0f1ShmfnD7(FkACJgKshfnKhjW0aHMLgtPJs3TkDu0wwYydQwwrx8PJurVxjeesGpkmSsfnUtdWHk6nEunkDfqPJI2YsgBq1YkAoRhJ1LIwMssYVQXqq70qE0uCroIyhrGJS4iYussEt80WbQf0aAXy50f2dJvPIU4thPIUDA4a1rQgLUBO0rrBzjJnOAzfDXNosfnmcNIg3Pb4qf9gpQgLU)tPJI2YsgBq1YkAoRhJ1LIwJzcc(4q)w)ELqqib(OWWkpYIJGckmaTxm4re7ipEKfhrJzcc(4qVaEuqHbOH1Iyk6IpDKk69kHGqc8rHHvQgLU)P0rrBzjJnOAzfnN1JX6srRXmbbFCOFRFVsiiKaFuyyLhzXre3r0yMGGpo0lGFVsiiKaFuyyLhzXr28iYuss(vngcANgYJMIlYre7iBpYIJu8PJ0VxjeesGpkmSsFNajC)TphzDfDXNosfn0Cr2CaAyw(n7QrPR(P0rrx8PJurl3ydXdk2NbKdNSXqkAllzSbvlRgLU)NshfTLLm2GQLv0fF6iv0OGcdqdRfXu0CwpgRlfT4oImLKKxghbetHgpZCvNOJiu4rM2zhrSJ83rwCenMji4Jd9B97vcbHe4JcdRurJ70aCOIEJhvJs3hIshfTLLm2GQLv0CwpgRlfnkOWa0EXGh59i)POl(0rQOruoxKabBSj1wcvJsx9rPJI2YsgBq1YkAoRhJ1LIgfuyaAVyWJ8EK)u0fF6iv0FS2fnZasg(JQyq1O0D7JkDu0wwYydQwwrZz9ySUu0OGcdq7fdEK3J8NIU4thPIMxymaYScIMclIXqQrP72TkDu0wwYydQwwrZz9ySUu0OGcdq7fdEK3J8NIU4thPIEVsiiKaFuyyLQrP7wbu6OOTSKXguTSIMZ6XyDPOrbfgG2lg8iI9EKnoYIJOXmbbFCOxa)ELqqib(OWWkpYIJmTZoIyh5VJS4iBEenMji4Jd9B9OGcdqdRfXoIqHhrChzkSLJhfuyaAyTiM3YsgBWJS4iAmtqWhh636r7fmwbKd8CK1v0fF6iv07vcbHe4JcdRunkD3UHshfTLLm2GQLv0CwpgRlfTgZee8XH(TEO5IS5a0WS8B2pIqHhrJzcc(4q)w)ELqqib(OWWkpYIJOXmbbFCOxa)ELqqib(OWWkpIqHhrChzkSLJhAUiBoanml)MDVLLm2GhzXrKPKK8RAme0onKhnfxKJS0rANgcG0QvPbbqkwNFEeLZfjaAUiBoyeLv5CeXEpI(POl(0rQOruoxKaO5IS5GruwLJAu6U9FkDu0wwYydQwwrZz9ySUu0OGcdq7fdEKNVhzJJS4iYussEO5IS5aEWmpZCvNifDXNosfn0Crkh4rnkD3(NshfTLLm2GQLv0fF6iv08cJbfF6ib4gnkACJgqwotrlt1yiOaO9IbvJAu0TtdhOosLokD3Q0rrBzjJnOAzfnN1JX6srV5rKPKK8RAme0onKhnfxKJi27r0VJS4iBEeuqHbO9IbpYZJSXrek8iAmtqWhh6365fgdGmRGOPWIym0rek8iYuss(vngcANgYJMIlYre79i6Zrek8iAmtqWhh636LBSH4bf7ZaYHt2yOJiu4r28iI7iAmtqWhh6363ReccjWhfgw5rwCeXDenMji4Jd9c43ReccjWhfgw5rw)iRFKfhrChrJzcc(4q)w)ELqqib(OWWkpYIJiUJOXmbbFCOxa)ELqqib(OWWkpYIJitjj5HMlYMd0IvgZdJv5rw)icfEKnpY0odmba22rEEKnoYIJitjj5x1yiODAipAkUihrSJ84rw)icfEKnpIgZee8XHEb88cJbqMvq0uyrmg6iloImLKKFvJHG2PH8OP4ICeXoIahzXre3rMcB54HMlYMd4fg35N3YsgBWJSUIU4thPIUDA4a1rQgLUcO0rrBzjJnOAzfnN1JX6srZJadJvPhr5CrcGMlYMdgrzvoEM5Qorh55r2UXrek8iI7iM(lvRPzq)QglXmicG6VgdcjaIsZyDWaikNlYo)u0fF6iv0FS2fnZasg(JQyq1O0DdLokAllzSbvlRO5SEmwxk6npcpcmmwLEeLZfjaAUiBoyeLv54zMR6eDKNhrFoYIJitjj5HMlYMd4fg35NNzUQt0rw)icfEKnpcpcmmwLEeLZfjaAUiBoyeLv54zMR6eDKNhz72JS4iI7iYussEO5IS5aEHXD(5zMR6eDK1pIqHhHhbggRspIY5IeanxKnhmIYQC8mZvDIoIyhz7)u0fF6iv08cJbqMvq0uyrmgsnkD)NshfDXNosfnIY5IeanxKnhmIYQCu0wwYydQwwnkD)tPJI2YsgBq1YkAoRhJ1LIgfuyaAVyWJi27r(trx8PJurVxjeesGpkmSs1O0v)u6OOTSKXguTSIMZ6XyDPOrbfgG2lg8iI9EKnoYIJS5r28iBEenMji4Jd9c43ReccjWhfgw5rek8iYuss(vngcANgYJMIlYre79iBCK1pYIJitjj5x1yiODAipAkUih55r0NJS(rek8i8iWWyv6ruoxKaO5IS5GruwLJNzUQt0rE(EKpo8ipGJiWrek8iYussEO5IS5aTyLX8mZvDIoIyh5JdpYd4icCK1v0fF6iv07vcbHe4JcdRunkD)pLokAllzSbvlRO5SEmwxkAnMji4Jd9B97vcbHe4JcdR8ilockOWa0EXGhrS3JS9iloYMhrMssYVQXqq70qE0uCroYZ3JSXrek8iAmtqWhh63WVxjeesGpkmSYJS(rwCeuqHbO9IbpYZJ8VJS4iYussEO5IS5aEWmpLMIU4thPIgAUiLd8OgLUpeLokAllzSbvlRO5SEmwxk6npcpcmmwLEeLZfjaAUiBoyeLv54zMR6eDeXoY)E8ilocsZWyWuSpBq(2PHduh5rE(EeboY6hrOWJWJadJvPhr5CrcGMlYMdgrzvoEM5Qorh55r2kGIU4thPIgr5CrceSXMuBjunkD1hLokAllzSbvlRO5SEmwxkAEeyySk9ikNlsa0Cr2CWikRYXZmx1j6iIDe9rrx8PJurl3ydXdk2NbKdNSXqQrP72hv6OOTSKXguTSIMZ6XyDPOrbfgG2lg8ippYFhzXrKPKK8qZfzZb8GzE0uCroYZ3JiGIU4thPIgfuyaAyTiMAu6UDRshfTLLm2GQLv0CwpgRlfnkOWa0EXGh557r24iloImLKKhAUiBoGhmZtPDKfhzZJitjj5HMlYMd4bZ8OP4ICeXEpYghrOWJitjj5HMlYMd4bZ8mZvDIoYZ3J8XHh5bCK)8)3rwxrx8PJurdnxKYbEuJs3TcO0rrBzjJnOAzfDXNosfnmcNIMlkhBGPyF2Gu6Uvr7kXdWfLJnWuSpBqk6)trZz9ySUu0mtIzO9sgBQrP72nu6OOTSKXguTSIU4thPIMxymO4thja3OrrJB0aYYzkAzQgdbfaTxmOAuJIgAsffEu6O0DRshfDXNosfnsZWyao4IOOTSKXguTSAu6kGshfTLLm2GQLv0CwpgRlfTMnEO5IS5GruwLJV4tlODKfhzZJiUJmf2YXN2SBmGwWMc7TSKXg8icfEezkjjFAZUXaAbBkSNs7iRFeHcpY0odmba22rEEKnEurx8PJurRfthPAu6UHshfTLLm2GQLv0CwpgRlfTMnEO5IS5GruwLJV4tlODeHcpY0odmba22rE(EKT)POl(0rQOPqgOhZHuJs3)P0rrBzjJnOAzfnN1JX6srRzJhAUiBoyeLv54l(0cAhrOWJmTZataGTDKNVhz7Fk6IpDKkAzJHmMiD(PgLU)P0rrBzjJnOAzfnN1JX6srRzJhAUiBoyeLv54l(0cAhrOWJmTZataGTDKNVhz7Fk6IpDKkAzCeqGeftu1O0v)u6OOTSKXguTSIMZ6XyDPO1SXdnxKnhmIYQC8fFAbTJiu4rM2zGjaW2oYZ3JS9pfDXNosfTuZmzCeq1O09)u6OOTSKXguTSIMZ6XyDPOl9VX6X8M4PHdulOb0IXYPlSNvPihzXrMcB54HMlYMd4rIOCAthP3YsgBWJS4it7SJ88iB84rwCeXDeEeyySk9ikNlsa0Cr2CWikRYXZmx1jsrx8PJurZlmgu8PJeGB0OOXnAaz5mfnKhjW0aHMLgtnkDFikDu0wwYydQwwrZz9ySUu0L(3y9yEt80WbQf0aAXy50f2ZQuKJS4it7SJ88i)DKfhbfuyaAVyWJi2re4iloImLKK3epnCGAbnGwmwoDH9WyvEKfhrMssYVQXqq70qE0uCroYZJSXrwCeXDenMji4Jd9B97vcbHe4JcdR8iloI4oIgZee8XHEb87vcbHe4JcdRurx8PJurVxjeesGpkmSs1O0vFu6OOTSKXguTSIMZ6XyDPOrbfgG2lg8ipFpYghzXrKPKK8qZfzZb8GzEkTJS4iYussEO5IS5aEWmpAkUih59i)trx8PJurdnxKYbEuJs3TpQ0rrBzjJnOAzfnN1JX6srx6FJ1J5nXtdhOwqdOfJLtxypRsroYIJitjj5x1yiODAipAkUihrSJiWrwCezkjjVjEA4a1cAaTySC6c7zMR6eDKNhP4thPhTxWyfqoWJ3epJtngyANDKfhzZJiUJmf2YXdnxKnhWJer50MosVLLm2GhrOWJWJadJvPhr5CrcGMlYMdgrzvoEM5QorhrSJSvGJSUIU4thPIUDA4a1rQgLUB3Q0rrBzjJnOAzfnN1JX6srlUJmnxKo)oYIJmTZataGTDeXoYgpEKfhbPzymyk2NniF70WbQJ8ippIak6IpDKkAyeo1O0DRakDu0wwYydQwwrZz9ySUu0L(3y9yEt80WbQf0aAXy50f2ZQuKJi2rE8iloY0o7ippY2hpYIJG0mmgmf7ZgKVDA4a1rEKNhrGJS4iYussEiZkiAkSigd5zMR6eDKfhzkSLJpTz3yaTGnf2BzjJnOIU4thPIwUXgIhuSpdihozJHuJs3TBO0rrBzjJnOAzfnN1JX6srV5rKPKK8RAme0onKhnfxKJ88i63rek8iYussEO5IS5aTyLX8uAhz9Jiu4rqAggdMI9zdY3onCG6ipYZJiGIU4thPIgAUiBoanml)MD1O0D7)u6OOTSKXguTSIMZ6XyDPONcB54tB2ngqlytH9wwYydEKfhbPzymyk2NniF70WbQJ8ipFpIak6IpDKkAEHXGIpDKaCJgfnUrdilNPOtB2ngqlytHvJs3T)P0rrBzjJnOAzfnN1JX6srJ0mmgmf7ZgKVDA4a1rEeXoYwfDXNosfnVWyqXNosaUrJIg3ObKLZu0TtdhOos1O0DR(P0rrBzjJnOAzfnN1JX6srV5rM2zGjaW2oIyhzRapEeHcpY0odmba22rEEeEeyySk9ikNlsa0Cr2CWikRYXZmx1j6ilDKT)DeHcpcpcmmwLEeLZfjaAUiBoyeLv54zMR6eDKNhz7ghzDfDXNosf9hRDrZmGKH)OkgunkD3(FkDu0wwYydQwwrZz9ySUu08iWWyv6ruoxKaO5IS5GruwLJNzUQt0re7i)7XJiu4r4rGHXQ0JOCUibqZfzZbJOSkhpZCvNOJ88iBfqrx8PJurJOCUibc2ytQTeQgLUBFikDu0wwYydQwwrZz9ySUu0BEeEeyySk9ikNlsa0Cr2CWikRYXZmx1j6ippI(CKfhrMssYdnxKnhWlmUZppZCvNOJS(rek8iBEeEeyySk9ikNlsa0Cr2CWikRYXZmx1j6ippY2ThzXre3rKPKK8qZfzZb8cJ78ZZmx1j6iRFeHcpcpcmmwLEeLZfjaAUiBoyeLv54zMR6eDeXoY2)POl(0rQO5fgdGmRGOPWIymKAu6UvFu6OOl(0rQOLBSH4bf7ZaYHt2yifTLLm2GQLvJsxbEuPJI2YsgBq1YkAoRhJ1LIEZJu6FJ1J5LlSjrHbDkyWRPJ0BzjJn4rek8itHTC8qZfzZb8iruoTPJ0BzjJn4rw)iloIgZee8XH(T(9kHGqc8rHHvEKfhHhbggRspIY5IeanxKnhmIYQC8mZvDIoYZJiGIU4thPIEVsiiKaFuyyLQrPRaBv6OOTSKXguTSIMZ6XyDPOrbfgG2lg8ippYghzXr28iI7itHTC8qZfzZb8iruoTPJ0BzjJn4rek8iYuss(vngcANgYJMIlYrw6iTtdbqA1Q0GaifRZppIY5IeanxKnhmIYQCoIyVhr)oYIJmTZataANgYxySNzUQt0rEEeEHgW0o7iRFeHcpY0odmba22rEEebEurx8PJurJOCUibqZfzZbJOSkh1O0vabu6OOTSKXguTSIMZ6XyDPOLPKK8RAme0onKhnfxKJi27re4iloImLKKhAUiBoGhmZJMIlYrE(EeboYIJitjj5HMlYMd0IvgZdJv5rwCeKMHXGPyF2G8TtdhOoYJ88icOOl(0rQO1IvgdGAT9ivJsxb2qPJI2YsgBq1YkAoRhJ1LIEkSLJhgHZBzjJn4rwCeMjXm0EjJTJS4it7mWeayBhrSJS5rGX4Hr48mZvDIoYshzJhpY6k6IpDKkAyeo1O0vG)P0rrBzjJnOAzfnN1JX6srJckmaTxm4re79i)DeHcpYMhbfuyaAVyWJi27r24ilocpcmmwLEEHXaiZkiAkSigd5zMR6eDeXoY)oYIJS5r4rGHXQ0JOCUibqZfzZbJOSkhpZCvNOJi2re4XJiu4r28i8iWWyv6ruoxKaO5IS5GruwLJNzUQt0rEEKpo8ipGJiWrwCKPWwoEO5IS5aEKikN20r6TSKXg8icfEeEeyySk9ikNlsa0Cr2CWikRYXZmx1j6ippYhhEKhWr(3rwCeXDKPWwoEO5IS5aEKikN20r6TSKXg8iRFK1pYIJS5re3rMcB54ruoxKabBSj1wc9wwYydEeHcpcpcmmwLEeLZfjqWgBsTLqpZCvNOJi2r24iRFK1v0fF6iv07vcbHe4JcdRunkDf4pLokAllzSbvlRO5SEmwxkAuqHbO9IbpYZJ83rwCezkjjp0Cr2CapyMhnfxKJ889icOOl(0rQOrbfgGgwlIPgLUcOFkDu0wwYydQwwrZz9ySUu0OGcdq7fdEKNVhzJJS4iYussEO5IS5aEWmpL2rwCKnpYMhHhbggRspIY5IeanxKnhmIYQC8mZvDIoYZJOFhrOWJWJadJvPhr5CrcGMlYMdgrzvoEM5QorhrSJiGahz9Jiu4rKPKK8qZfzZb8GzE0uCroIyVhzJJiu4rKPKK8qZfzZb8GzEM5Qorh55r(7icfEKPDgycaSTJ88ic83rwxrx8PJurdnxKYbEuJsxb(pLokAllzSbvlROl(0rQO5fgdk(0rcWnAu04gnGSCMIwMQXqqbq7fdQg1OO1ygpCY1O0rP7wLokAllzSbvlRgLUcO0rrBzjJnOAz1O0DdLokAllzSbvlRgLU)tPJIU4thPIgr5CrcKm8hvXGkAllzSbvlRgLU)P0rrBzjJnOAzfnN1JX6srpf2YX3zAma0CrI8wwYydQOl(0rQO7mngaAUirQrPR(P0rrBzjJnOAz1O09)u6OOl(0rQO1IPJurBzjJnOAz1O09HO0rrBzjJnOAzfnN1JX6srltjj5x1yiODAipAkUihrSJS9iloImLKKhAUiBoGhmZdJvPIU4thPIwlwzmaQ12JunkD1hLokAllzSbvlRO5SEmwxkA5aHoIqHhP4thPhAUiLd845fAoY7rEurx8PJurdnxKYbEuJs3TpQ0rrBzjJnOAzfnN1JX6srlUJihi0rek8ifF6i9qZfPCGhpVqZre7ipQOl(0rQOr7fmwbKd8Og1OOtB2ngqlytHv6O0DRshfTLLm2GQLv0CwpgRlfnpcmmwL(0MDJb0c2uypZCvNOJ88ic8OIU4thPIMxymO4thja3OrrJB0aYYzk60MDJb0c2uyGmvJHD(PgLUcO0rrBzjJnOAzfnN1JX6srltjj5tB2ngqlytH9uAk6IpDKkAEHXGIpDKaCJgfnUrdilNPOtB2ngqlytHbfFAbn1OgfDAZUXaAbBkmqMQXWo)u6O0DRshfTLLm2GQLv0CwpgRlfnkOWa0EXGhrS3J83rwCKnpI4oYuylhVwSYyauRThP3YsgBWJiu4rKPKK8qZfzZb8GzEkTJSUIU4thPIoTz3yaTGnfwnkDfqPJIU4thPIMxymaYScIMclIXqkAllzSbvlRgLUBO0rrBzjJnOAzfnN1JX6srZJadJvPNxymaYScIMclIXqEM5QorhrSJS9HCKfhbfuyaAVyWJi27r2qrx8PJurVxjeesGpkmSs1O09FkDu0wwYydQwwrZz9ySUu0Yuss(vngcANgYJMIlYre79icCKfhrMssYdnxKnhWdM5rtXf5ipFpIahzXrKPKK8qZfzZbAXkJ5HXQ8ilockOWa0EXGhrS3JSHIU4thPIwlwzmaQ12JunkD)tPJI2YsgBq1YkAoRhJ1LIgfuyaAVyWJi27r(trx8PJurVxjeesGpkmSs1O0v)u6OOTSKXguTSIU4thPIMxymO4thja3OrrJB0aYYzkAzQgdbfaTxmOAuJIwMQXqqbq7fdQ0rP7wLokAllzSbvlRO5SEmwxkAXDKPWwoEO5IS5aEKikN20r6TSKXg8icfEKPD2re7iB)7icfEenMji4Jd9B97vcbHe4JcdR8iloI4oImLKKxghbetHgpZCvNifDXNosfnkOWa0WArm1O0vaLok6IpDKkA0EbJva5apkAllzSbvlRg1OOtB2ngqlytHbfFAbnLokD3Q0rrx8PJurl3ydXdk2NbKdNSXqkAllzSbvlRgLUcO0rrBzjJnOAzfnN1JX6srZJadJvPhr5CrcGMlYMdgrzvoEM5Qorh55r2UXrek8iI7iM(lvRPzq)QglXmicG6VgdcjaIsZyDWaikNlYo)u0fF6iv0FS2fnZasg(JQyq1O0DdLokAllzSbvlRO5SEmwxkAEeyySk9ikNlsa0Cr2CWikRYXZmx1j6iIDK)94rek8i8iWWyv6ruoxKaO5IS5GruwLJNzUQt0rEEKTcOOl(0rQOruoxKabBSj1wcvJs3)P0rrBzjJnOAzfnN1JX6srV5r4rGHXQ0JOCUibqZfzZbJOSkhpZCvNOJ88i6ZrwCezkjjp0Cr2CaVW4o)8mZvDIoY6hrOWJS5r4rGHXQ0JOCUibqZfzZbJOSkhpZCvNOJ88iB3EKfhrChrMssYdnxKnhWlmUZppZCvNOJS(rek8i8iWWyv6ruoxKaO5IS5GruwLJNzUQt0re7iB)NIU4thPIMxymaYScIMclIXqQrP7FkDu0wwYydQwwrZz9ySUu0OGcdq7fdEK3JS9iloYMhHhbggRspVWyaKzfenfweJH8mZvDIoYZJu8PJ0J2lyScih4XZl0aM2zhrOWJS5rMcB54LBSH4bf7ZaYHt2yiVLLm2GhzXr4rGHXQ0l3ydXdk2NbKdNSXqEM5Qorh55rk(0r6r7fmwbKd845fAat7SJS(rwxrx8PJurZlmgu8PJeGB0OOXnAaz5mfTmvJHGcG2lgunkD1pLokAllzSbvlRO5SEmwxk6npYMhHhbggRspVWyaKzfenfweJH8mZvDIoIyhP4thPhAUiLd845fAat7SJS(rwCKnpcpcmmwLEEHXaiZkiAkSigd5zMR6eDeXosXNospAVGXkGCGhpVqdyANDK1pY6hzXrKPKK8Pn7gdOfSPWEM5QorhrSJWl0aM2zk6IpDKk69kHGqc8rHHvQgLU)NshfTLLm2GQLv0CwpgRlfTmLKKpTz3yaTGnf2Zmx1j6ippYFhzXrqbfgG2lg8iVh5rfDXNosfnIY5IeanxKnhmIYQCuJs3hIshfTLLm2GQLv0CwpgRlfTmLKKpTz3yaTGnf2Zmx1j6ippsXNospIY5IeanxKnhmIYQC88cnGPD2rw6ip6)trx8PJurJOCUibqZfzZbJOSkh1O0vFu6OOTSKXguTSIMZ6XyDPOLPKK8qZfzZb8GzEkTJS4iOGcdq7fdEKNVhzdfDXNosfn0Crkh4rnkD3(OshfTLLm2GQLv0fF6iv08cJbfF6ib4gnkACJgqwotrlt1yiOaO9IbvJAuJAuJsba]] )


end
