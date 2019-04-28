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
            
            cycleMinTime = function () return 1 + debuff.doom.duration end,

            readyTime = function () return isCyclingTargets() and 0 or debuff.doom.remains end,
            usable = function () return isCyclingTargets() or ( target.time_to_die < 3600 and target.time_to_die > debuff.doom.duration ) end,
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

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_intellect",

        package = "Demonology",
    } )

    spec:RegisterPack( "Demonology", 20190417.2215, [[dOKsDbqiIGfPkO6rKQOlPkO0MucFIuLOrPKQtPuyvQcWRuIAwkPClvbAxu5xKQAyQcDmLsldP4zkfnnvrCnvrTnsvQVPksgNQG05ivH1PkiMNQk3tvAFerhKuLWcvI8qIqXejcvxuvavFKuLK6KKQKyLQQAMeHs2jPs)uvaLHQkOyPKQKKNsWujvCvsvs9vIqP2lj)fYGrCyjlMOEmQMmWLPSzc9zvLrRuDAPEnrYSH62u1Uf9BHHtkhxvaz5O8CqtxX1rY2rk9DLKXteY5jsTEvrQ5JuTFvwTvPJsauJP0LMh3Qhp(KTpLJgA2(8JBQegP1mLGwXLQ(mLqwEtjiXnFKbo(KwjOvsJJcO0rjadkg3uc7ZObFi6R)xp7uYoE41h2EkCnDKCwjo6dBpxFLGmvJh9kPswjaQXu6sZJB1JhFY2NYrdnBF(rAucqnJR0Lg9wVvc7nayPswjamixjONhrIB(idC8j9rKyxmCWL6(RNhzFgn4drF9)6zNs2XdV(W2tHRPJKZkXrFy756F)1ZJOxOXA8r2(uRDeAECRECKh8i0qZd5XT3)7VEEejM9k)m4d5(RNh5bpIGMHXhrIvWLYD)1ZJ8GhrVgAhrMsu0L2SBmKwWMc7O0osNWXkWrcXJWmF1zNFhrIrIFKP92red2r01MDJDKhMGnf(ifFAATJOTxqZD)1ZJ8Gh5bwIL(imJhEVLGJiXnFKYbEoIgZEqE4LR5iT4r65in8iDcNkNJSEWoYEXa8cohrmyhroGqdUH7(RNh5bpYdtSYyhrO12J8ifghRmWr0y2dYdVCnhzIJOXc(r6eovohrIB(iLd84U)65rEWJOxaahj0S0yhryVaXQJSuGNJeudSb2rcXJihq4re7V9bEKjosnhbBfCoYNnhjs7i(GzhbUxmG7(RNh5bpIEn0oYdFAVHMabA7HFK1njsZ4JboIL8GkhJDelbBCewn7g7iZELh5Hpf7Zg30Ednbc02d)iRBsKMXhdCeofJz5CKPyF2OxcpcWQzFJJmXrkAJgCetI4ge20AhrMILD(DKq8iSI3f(ismsCOtjOXcXgBkb98isCZhzGJpPpIe7IHdUu3F98i7ZObFi6R)xp7uYoE41h2EkCnDKCwjo6dBpx)7VEEe9cnwJpY2NATJqZJB1JJ8GhHgAEipU9(F)1ZJiXSx5NbFi3F98ip4re0mm(isScUuU7VEEKh8i61q7iYuIIU0MDJH0c2uyhL2r6eowbosiEeM5Ro787isms8JmT3oIyWoIU2SBSJ8WeSPWhP4ttRDeT9cAU7VEEKh8ipWsS0hHz8W7TeCejU5JuoWZr0y2dYdVCnhPfpsphPHhPt4u5CK1d2r2lgGxW5iIb7iYbeAWnC3F98ip4rEyIvg7icT2EKhPW4yLboIgZEqE4LR5itCenwWpsNWPY5isCZhPCGh39xppYdEe9ca4iHMLg7ic7fiwDKLc8CKGAGnWosiEe5acpIy)TpWJmXrQ5iyRGZr(S5irAhXhm7iW9IbC3F98ip4r0RH2rE4t7n0eiqBp8JSUjrAgFmWrSKhu5ySJyjyJJWQz3yhz2R8ip8PyF24M2BOjqG2E4hzDtI0m(yGJWPymlNJmf7Zg9s4rawn7BCKjosrB0GJyse3GWMw7iYuSSZVJeIhHv8UWhrIrIdD3)7VEEKh4sKXPgdCeztmy2r4HxUMJiBFDcDhrVGZnTbEKmYhCVyErk8rk(0rcpsKyPD3)IpDKqNgZ4HxUMxrCbL6(x8PJe60ygp8Y1S8R(IraU)fF6iHonMXdVCnl)QFr95TCQPJ8(x8PJe60ygp8Y1S8R(qkVpsKMn3)IpDKqNgZ4HxUMLF1VZ0yiG5JeUwl(of2YX1zAmeW8rcDwwYydC)l(0rcDAmJhE5Aw(vFywAW9yqWPg49V4thj0PXmE4LRz5x91IPJ8(x8PJe60ygp8Y1S8R(AXkJHGT2EKR1IVYuIIUvngGAVg0bNIlLKBxitjk6aMpYMJ4bZCGyvE)l(0rcDAmJhE5Aw(vFG5JuoWZAT4RCaH0Px8PJ0bmFKYbEC8coVpE)l(0rcDAmJhE5Aw(vF4EbIvi5apR1IVsqoGq60l(0r6aMps5apoEbhjF8(F)1ZJ8axImo1yGJy0AmPpY0E7iZUDKIpb7in8ifTvJlzS5U)fF6iHVqndJr4Gl19V4thjC5x91IPJCTw8vZghW8r2C0inRYXv8PP1wSUeMcB54sB2ngslytHDwwYydqNUmLOOlTz3yiTGnf2rPTbD6t7n0eiqB)28X7FXNos4YV6tbnupMhUwl(QzJdy(iBoAKMv54k(00A0PpT3qtGaT97D7Z3)IpDKWLF1x2yqJjvNFR1IVA24aMpYMJgPzvoUIpnTgD6t7n0eiqB)E3(89V4thjC5x9LXraqIumPxRfF1SXbmFKnhnsZQCCfFAAn60N2BOjqG2(9U957FXNos4YV6l2mtghbyTw8vZghW8r2C0inRYXv8PP1OtFAVHMabA7372NV)fF6iHl)QpVWyuXNoseUHZAz5TxapsuOzPXwRfFNcB54aMpYMJ4rcP8AthPZYsgBGft7TFB(4cjWJadIvPds59rIaMpYMJgPzvooM5RoH3)IpDKWLF1FVsakerFuyqLR1IV1tBSEmNjrA4a20AiTySC6c7yvk1IP92VNxadkmcUxmGK0SqMsu0zsKgoGnTgslglNUWoqSkxitjk6w1yaQ9AqhCkUu)2CHe0ygTOpoWT1TxjafIOpkmOYfsqJz0I(4ahnU9kbOqe9rHbvE)l(0rcx(vFG5JuoWZAT4lmOWi4EXa)E3CHmLOOdy(iBoIhmZrPTqMsu0bmFKnhXdM5GtXL69j3)IpDKWLF1V9A4a2rUwl(wpTX6XCMePHdytRH0IXYPlSJvPulKPefDRAma1EnOdofxkjPzHmLOOZKinCaBAnKwmwoDHDmZxDc)v8PJ0b3lqScjh4XzsKXPgdnT3wSUeMcB54aMpYMJ4rcP8AthPZYsgBa605rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNqj3sZg3)IpDKWLF1heHFTw8vctZLQZVft7n0eiqBsU5JlGAggJMI9zd01EnCa7i)rZ9V4thjC5x9LBSb5bf7ZqYHx2yW1AX36PnwpMZKinCaBAnKwmwoDHDSkLsYhxmT3(T9XfqndJrtX(Sb6AVgoGDK)OzHmLOOdWScaNclLXGoM5RoHlMcB54sB2ngslytHDwwYydC)l(0rcx(vFG5JS5i4WS8B2xRfFxxMsu0TQXau71Go4uCP(P30Pltjk6aMpYMJ0IvgZrPTbD6qndJrtX(Sb6AVgoGDK)O5(x8PJeU8R(8cJrfF6ir4goRLL3EtB2ngslytHxRfFNcB54sB2ngslytHDwwYydSaQzymAk2Nnqx71WbSJ83ln3)IpDKWLF1NxymQ4thjc3WzTS82B71WbSJCTw8fQzymAk2Nnqx71WbSJuYT3)IpDKWLF1)J1(Ozgs0WFufdSwl(U(0Ednbc0MKBP5r60N2BOjqG2(XJadIvPds59rIaMpYMJgPzvooM5RoHlV9z605rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWFB3CJ7FXNos4YV6dP8(ir02ytSTeSwl(YJadIvPds59rIaMpYMJgPzvooM5RoHs(KhPtNhbgeRshKY7JebmFKnhnsZQCCmZxDc)TLM7FXNos4YV6ZlmgbywbGtHLYyW1AX315rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWF6XczkrrhW8r2CeVW4o)CmZxDc3Go915rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWFB3UqcYuIIoG5JS5iEHXD(5yMV6eUbD68iWGyv6GuEFKiG5JS5OrAwLJJz(QtOKBFY9V4thjC5x9LBSb5bf7ZqYHx2yW7FXNos4YV6VxjafIOpkmOY1AX31RN2y9yo5cBIuyuN0g8A6iDwwYydqN(uylhhW8r2CepsiLxB6iDwwYydSXcnMrl6JdCBD7vcqHi6JcdQCbpcmiwLoiL3hjcy(iBoAKMv54yMV6e(JM7VEEeAE8XhFyHAggJ2l4yhPHhbUhSzVsWred2rMD7i8cohzAVDKq8isCZhzZpIosZQCChrND7iDowohPHhzIJejw6JiBFDEeEbNo)oslEK6iCJnvNhjP8Yg7iH4rAVg8iRAm(iY2rcQ5iYsFKz3oILGJeIhz2TJWl44U)fF6iHl)QpKY7JebmFKnhnsZQCwRfFHbfgb3lg43MlwxctHTCCaZhzZr8iHuETPJ0zzjJnaD6YuIIUvngGAVg0bNIl1YTxdIGA1Q0aiafRZphKY7JebmFKnhnsZQCK8vVxmT3qtGAVg0vySJz(Qt4pEbh00EBd60N2BOjqG2(rZJ3)IpDKWLF1xlwzmeS12JCTw8vMsu0TQXau71Go4uCPK8LMfYuIIoG5JS5iEWmhCkUu)EPzHmLOOdy(iBoslwzmhiwLlGAggJMI9zd01EnCa7i)rZ9V4thjC5x9br4xRfFNcB54ar4DwwYydSGzImdUxYyBX0Ednbc0MKRdIXbIW7yMV6eU8MpUX9V4thjC5x93ReGcr0hfgu5AT4lmOWi4EXas((mD6RddkmcUxmGKVBUGhbgeRshVWyeGzfaofwkJbDmZxDcL8jlwNhbgeRshKY7JebmFKnhnsZQCCmZxDcLKMhPtFDEeyqSkDqkVpseW8r2C0inRYXXmF1j83hh8aOzXuylhhW8r2CepsiLxB6iDwwYydqNopcmiwLoiL3hjcy(iBoAKMv54yMV6e(7JdEapzHeMcB54aMpYMJ4rcP8AthPZYsgBGn2yX6sykSLJds59rIOTXMyBjWzzjJnaD68iWGyv6GuEFKiABSj2wcCmZxDcLCZn24(x8PJeU8R(WGcJGdRLYwRfFHbfgb3lg43ZlKPefDaZhzZr8Gzo4uCP(9sZ9V4thjC5x9bMps5apR1IVWGcJG7fd87DZfYuIIoG5JS5iEWmhL2I1xNhbgeRshKY7JebmFKnhnsZQCCmZxDc)P30PZJadIvPds59rIaMpYMJgPzvooM5RoHssdnlKq90gRhZb3lqScIK7XCwwYydSbD6YuIIoG5JS5iEWmhCkUus(UjD6YuIIoG5JS5iEWmhZ8vNWFptN(0Ednbc02pAEMoDzkrrhCVaXkisUhZXmF1jCJ7FXNos4YV6Zlmgv8PJeHB4SwwE7vMQXauHG7fdC)V)fF6iHozQgdqfcUxmWlmOWi4WAPS1AXxjmf2YXbmFKnhXJes51MosNLLm2a0PpT3KC7Z0PRXmArFCGBRBVsakerFuyqLlKGmLOOtghbatbhhZ8vNW7FXNosOtMQXauHG7fdS8R(W9ceRqYbEU)3)IpDKqhGhjk0S0yV7vcqHi6JcdQCnCNgIdE38X1AX36PnwpMZKinCaBAnKwmwoDHDwwYydC)l(0rcDaEKOqZsJT8R(TxdhWoY1AX36PnwpMZKinCaBAnKwmwoDHDwwYydSqMsu0TQXau71Go4uCPKKMfYuIIotI0WbSP1qAXy50f2bIv59V4thj0b4rIcnln2YV6dIWVgUtdXbVB(49V4thj0b4rIcnln2YV6VxjafIOpkmOY1AXxnMrl6JdCBD7vcqHi6JcdQCbmOWi4EXas(4cnMrl6JdC04GbfgbhwlLD)l(0rcDaEKOqZsJT8R(aZhzZrWHz53SVwl(QXmArFCGBRBVsakerFuyqLlKGgZOf9XboAC7vcqHi6JcdQCX6YuIIUvngGAVg0bNIlLKBxu8PJ0TxjafIOpkmOsxNirC)TpBC)l(0rcDaEKOqZsJT8R(Yn2G8GI9zi5WlBm49V4thj0b4rIcnln2YV6ddkmcoSwkBnCNgIdE38X1AXxjitjk6KXraWuWXXmF1jKo9P9MKpVqJz0I(4a3w3ELauiI(OWGkV)fF6iHoapsuOzPXw(vFiL3hjI2gBITLG1AXxyqHrW9IbEF((x8PJe6a8irHMLgB5x9)yTpAMHen8hvXaR1IVWGcJG7fd8(89V4thj0b4rIcnln2YV6ZlmgbywbGtHLYyW1AXxyqHrW9IbEF((x8PJe6a8irHMLgB5x93ReGcr0hfgu5AT4lmOWi4EXaVpF)l(0rcDaEKOqZsJT8R(7vcqHi6JcdQCTw8fguyeCVyajF3CHgZOf9XboAC7vcqHi6JcdQCX0EtYNxSUgZOf9XbUToyqHrWH1sz0PlHPWwooyqHrWH1szollzSbwOXmArFCGBRdUxGyfsoWZg3F98i084Jp(Wc1mmgTxWXosdpcCpyZELGJigSJm72r4fCoY0E7iH4rK4MpYMFeDKMv54oIo72r6CSCosdpYehjsS0hr2(68i8coD(DKw8i1r4gBQopss5Ln2rcXJ0En4rw1y8rKTJeuZrKL(iZUDelbhjepYSBhHxWXD)l(0rcDaEKOqZsJT8R(qkVpseW8r2C0inRYzTw8vJz0I(4a3whW8r2CeCyw(n70PRXmArFCGBRBVsakerFuyqLl0ygTOpoWrJBVsakerFuyqL0PlHPWwooG5JS5i4WS8B2DwwYydSqMsu0TQXau71Go4uCPwU9AqeuRwLgabOyD(5GuEFKiG5JS5OrAwLZdluZWy0EbhtYx9((x8PJe6a8irHMLgB5x9bMps5apR1IVWGcJG7fd87DZfYuIIoG5JS5iEWmhZ8vNW7FXNosOdWJefAwASLF1NxymQ4thjc3WzTS82RmvJbOcb3lg4(F)l(0rcDTxdhWoY32RHdyh5AT476YuIIUvngGAVg0bNIlLKV69I1Hbfgb3lg43M0PRXmArFCGBRJxymcWScaNclLXG0Pltjk6w1yaQ9AqhCkUus(Qh0PRXmArFCGBRtUXgKhuSpdjhEzJbPtFDjOXmArFCGBRBVsakerFuyqLlKGgZOf9XboAC7vcqHi6JcdQCJnwibnMrl6JdCBD7vcqHi6JcdQCHe0ygTOpoWrJBVsakerFuyqLlKPefDaZhzZrAXkJ5aXQCd60xFAVHMabA73MlKPefDRAma1EnOdofxkjFCd60xxJz0I(4ahnoEHXiaZkaCkSugdUqMsu0TQXau71Go4uCPKKMfsykSLJdy(iBoIxyCNFollzSb24(x8PJe6AVgoGDKl)Q)hR9rZmKOH)OkgyTw8LhbgeRshKY7JebmFKnhnsZQCCmZxDc)TDt60LG9ar1AAgWTDtA2uV1J7FXNosOR9A4a2rU8R(8cJraMva4uyPmgCTw8DDEeyqSkDqkVpseW8r2C0inRYXXmF1j8NESqMsu0bmFKnhXlmUZphZ8vNWnOtFDEeyqSkDqkVpseW8r2C0inRYXXmF1j832TlKGmLOOdy(iBoIxyCNFoM5RoHBqNopcmiwLoiL3hjcy(iBoAKMv54yMV6ek52NC)l(0rcDTxdhWoYLF1hs59rIaMpYMJgPzvo3)IpDKqx71WbSJC5x93ReGcr0hfgu5AT4lmOWi4EXas((89V4thj01EnCa7ix(v)9kbOqe9rHbvUwl(cdkmcUxmGKVBUy91xxJz0I(4ahnU9kbOqe9rHbvsNUmLOOBvJbO2RbDWP4sj57MBSqMsu0TQXau71Go4uCP(PhBqNopcmiwLoiL3hjcy(iBoAKMv54yMV6e(79JdEa0qNUmLOOdy(iBoslwzmhZ8vNqj)4GhanBC)l(0rcDTxdhWoYLF1hy(iLd8Swl(QXmArFCGBRBVsakerFuyqLlGbfgb3lgqY3TlwxMsu0TQXau71Go4uCP(9UjD6AmJw0hh420TxjafIOpkmOYnwadkmcUxmWVNSqMsu0bmFKnhXdM5O0U)fF6iHU2RHdyh5YV6dP8(ir02ytSTeSwl(UopcmiwLoiL3hjcy(iBoAKMv54yMV6ek5tECbuZWy0uSpBGU2RHdyh5VxA2GoDEeyqSkDqkVpseW8r2C0inRYXXmF1j83wAU)fF6iHU2RHdyh5YV6l3ydYdk2NHKdVSXGR1IV8iWGyv6GuEFKiG5JS5OrAwLJJz(QtOK6X9V4thj01EnCa7ix(vFyqHrWH1szR1IVWGcJG7fd875fYuIIoG5JS5iEWmhCkUu)EP5(x8PJe6AVgoGDKl)QpW8rkh4zTw8fguyeCVyGFVBUqMsu0bmFKnhXdM5O0wSUmLOOdy(iBoIhmZbNIlLKVBsNUmLOOdy(iBoIhmZXmF1j837hh8aE29uBC)l(0rcDTxdhWoYLF1heHFnU0CSHMI9zd8D7A(sIqCP5ydnf7Zg47tTwl(YmrMb3lzSD)l(0rcDTxdhWoYLF1NxymQ4thjc3WzTS82RmvJbOcb3lg4(F)l(0rcDPn7gdPfSPWV8cJrfF6ir4goRLL3EtB2ngslytHrYung053AT4lpcmiwLU0MDJH0c2uyhZ8vNWF0849V4thj0L2SBmKwWMcV8R(8cJrfF6ir4goRLL3EtB2ngslytHrfFAAT1AXxzkrrxAZUXqAbBkSJs7(F)l(0rcDPn7gdPfSPWOIpnT2RCJnipOyFgso8YgdE)l(0rcDPn7gdPfSPWOIpnT2YV6)XAF0mdjA4pQIbwRfF5rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWFB3KoDjypquTMMbCB3KMn1B94(x8PJe6sB2ngslytHrfFAATLF1hs59rIOTXMyBjyTw8LhbgeRshKY7JebmFKnhnsZQCCmZxDcL8jpsNopcmiwLoiL3hjcy(iBoAKMv54yMV6e(Bln3)IpDKqxAZUXqAbBkmQ4ttRT8R(8cJraMva4uyPmgCTw8DDEeyqSkDqkVpseW8r2C0inRYXXmF1j8NESqMsu0bmFKnhXlmUZphZ8vNWnOtFDEeyqSkDqkVpseW8r2C0inRYXXmF1j832TlKGmLOOdy(iBoIxyCNFoM5RoHBqNopcmiwLoiL3hjcy(iBoAKMv54yMV6ek52NC)l(0rcDPn7gdPfSPWOIpnT2YV6Zlmgv8PJeHB4SwwE7vMQXauHG7fdSwl(cdkmcUxmW72fRZJadIvPJxymcWScaNclLXGoM5RoH)k(0r6G7fiwHKd844fCqt7n60xFkSLJtUXgKhuSpdjhEzJbDwwYydSGhbgeRsNCJnipOyFgso8Ygd6yMV6e(R4thPdUxGyfsoWJJxWbnT32yJ7FXNosOlTz3yiTGnfgv8PP1w(v)9kbOqe9rHbvUwl(U(68iWGyv64fgJamRaWPWszmOJz(QtOKfF6iDaZhPCGhhVGdAAVTXI15rGbXQ0XlmgbywbGtHLYyqhZ8vNqjl(0r6G7fiwHKd844fCqt7Tn2yHmLOOlTz3yiTGnf2XmF1jusEbh00E7(x8PJe6sB2ngslytHrfFAATLF1hs59rIaMpYMJgPzvoR1IVYuIIU0MDJH0c2uyhZ8vNWFpVaguyeCVyG3hV)fF6iHU0MDJH0c2uyuXNMwB5x9HuEFKiG5JS5OrAwLZAT4RmLOOlTz3yiTGnf2XmF1j8xXNoshKY7JebmFKnhnsZQCC8coOP92Yp6E((x8PJe6sB2ngslytHrfFAATLF1hy(iLd8Swl(ktjk6aMpYMJ4bZCuAlGbfgb3lg437M3)IpDKqxAZUXqAbBkmQ4ttRT8R(8cJrfF6ir4goRLL3ELPAmavi4EXa3)7FXNosOlTz3yiTGnfgjt1yqNFVPn7gdPfSPWR1IVWGcJG7fdi57ZlwxctHTCCAXkJHGT2EKollzSbOtxMsu0bmFKnhXdM5O024(x8PJe6sB2ngslytHrYung053YV6ZlmgbywbGtHLYyW7FXNosOlTz3yiTGnfgjt1yqNFl)Q)ELauiI(OWGkxRfF5rGbXQ0XlmgbywbGtHLYyqhZ8vNqj3(qxadkmcUxmGKVBE)l(0rcDPn7gdPfSPWizQgd68B5x91IvgdbBT9ixRfFLPefDRAma1EnOdofxkjFPzHmLOOdy(iBoIhmZbNIl1VxAwitjk6aMpYMJ0IvgZbIv5cyqHrW9IbK8DZ7FXNosOlTz3yiTGnfgjt1yqNFl)Q)ELauiI(OWGkxRfFHbfgb3lgqY3NV)fF6iHU0MDJH0c2uyKmvJbD(T8R(8cJrfF6ir4goRLL3ELPAmavi4EXakbAngSJuPlnpUvpE8jpU1T9jp)eLWQILD(bvcsS1l0Rsx9k6Qx9d5ihrND7iTxlyZred2r0l1ygp8Y1OxEeM9ar1mdCey4TJuut4RXahHVx5NbD3FjwDAh55hYr0RtiLMwWgdCKIpDKhrVSZ0yiG5JeQx6U)3F9kETGng4ip0Ju8PJ8i4goq39xjGB4av6OesB2ngslytHv6O0DRshLGLLm2aQLucCwpgRlLapcmiwLU0MDJH0c2uyhZ8vNWJ87i08OsO4thPsGxymQ4thjc3WrjGB4GYYBkH0MDJH0c2uyKmvJbD(PgLU0O0rjyzjJnGAjLaN1JX6sjitjk6sB2ngslytHDuAkHIpDKkbEHXOIpDKiCdhLaUHdklVPesB2ngslytHrfFAAn1OgLqAZUXqAbBkmsMQXGo)u6O0DRshLGLLm2aQLucCwpgRlLamOWi4EXahrY3J88rwCK1pIeoYuylhNwSYyiyRThPZYsgBGJqN(rKPefDaZhzZr8GzokTJSHsO4thPsiTz3yiTGnfwnkDPrPJsO4thPsGxymcWScaNclLXGkbllzSbulPgLUBQ0rjyzjJnGAjLaN1JX6sjWJadIvPJxymcWScaNclLXGoM5RoHhrYJS9HEKfhbguyeCVyGJi57r2uju8PJujSxjafIOpkmOs1O09jkDucwwYydOwsjWz9ySUucYuIIUvngGAVg0bNIl1rK89i0CKfhrMsu0bmFKnhXdM5GtXL6i)EpcnhzXrKPefDaZhzZrAXkJ5aXQ8ilocmOWi4EXahrY3JSPsO4thPsqlwzmeS12JunkDFwPJsWYsgBa1skboRhJ1LsaguyeCVyGJi57rEwju8PJujSxjafIOpkmOs1O0vVv6OeSSKXgqTKsO4thPsGxymQ4thjc3WrjGB4GYYBkbzQgdqfcUxmGAuJsayIffEu6O0DRshLqXNosLauZWyeo4sPeSSKXgqTKAu6sJshLGLLm2aQLucCwpgRlLGMnoG5JS5OrAwLJR4ttRDKfhz9JiHJmf2YXL2SBmKwWMc7SSKXg4i0PFezkrrxAZUXqAbBkSJs7iBCe60pY0Ednbc02r(DKnFuju8PJujOfthPAu6UPshLGLLm2aQLucCwpgRlLGMnoG5JS5OrAwLJR4ttRDe60pY0Ednbc02r(9EKTpRek(0rQeOGgQhZdvJs3NO0rjyzjJnGAjLaN1JX6sjOzJdy(iBoAKMv54k(00AhHo9JmT3qtGaTDKFVhz7ZkHIpDKkbzJbnMuD(PgLUpR0rjyzjJnGAjLaN1JX6sjOzJdy(iBoAKMv54k(00AhHo9JmT3qtGaTDKFVhz7ZkHIpDKkbzCeaKiftA1O0vVv6OeSSKXgqTKsGZ6XyDPe0SXbmFKnhnsZQCCfFAATJqN(rM2BOjqG2oYV3JS9zLqXNosLGyZmzCea1O09Pu6OeSSKXgqTKsGZ6XyDPeMcB54aMpYMJ4rcP8AthPZYsgBGJS4it7TJ87iB(4rwCejCeEeyqSkDqkVpseW8r2C0inRYXXmF1juju8PJujWlmgv8PJeHB4OeWnCqz5nLaGhjk0S0yQrP7dvPJsWYsgBa1skboRhJ1LsOEAJ1J5mjsdhWMwdPfJLtxyhRsPoYIJmT3oYVJ88rwCeyqHrW9IboIKhHMJS4iYuIIotI0WbSP1qAXy50f2bIv5rwCezkrr3QgdqTxd6GtXL6i)oYMhzXrKWr0ygTOpoWT1TxjafIOpkmOYJS4is4iAmJw0hh4OXTxjafIOpkmOsLqXNosLWELauiI(OWGkvJsx9qPJsWYsgBa1skboRhJ1LsaguyeCVyGJ879iBEKfhrMsu0bmFKnhXdM5O0oYIJitjk6aMpYMJ4bZCWP4sDK3J8eLqXNosLaW8rkh4rnkD3(OshLGLLm2aQLucCwpgRlLq90gRhZzsKgoGnTgslglNUWowLsDKfhrMsu0TQXau71Go4uCPoIKhHMJS4iYuIIotI0WbSP1qAXy50f2XmF1j8i)osXNoshCVaXkKCGhNjrgNAm00E7iloY6hrchzkSLJdy(iBoIhjKYRnDKollzSbocD6hHhbgeRshKY7JebmFKnhnsZQCCmZxDcpIKhzlnhzdLqXNosLq71WbSJunkD3UvPJsWYsgBa1skboRhJ1LsqchzAUuD(DKfhzAVHMabA7isEKnF8ilocuZWy0uSpBGU2RHdyh5r(DeAucfF6ivcGi8QrP7wAu6OeSSKXgqTKsGZ6XyDPeQN2y9yotI0WbSP1qAXy50f2XQuQJi5rE8iloY0E7i)oY2hpYIJa1mmgnf7ZgOR9A4a2rEKFhHMJS4iYuIIoaZkaCkSugd6yMV6eEKfhzkSLJlTz3yiTGnf2zzjJnGsO4thPsqUXgKhuSpdjhEzJbvJs3TBQ0rjyzjJnGAjLaN1JX6sjS(rKPefDRAma1EnOdofxQJ87i69rOt)iYuIIoG5JS5iTyLXCuAhzJJqN(rGAggJMI9zd01EnCa7ipYVJqJsO4thPsay(iBocoml)MD1O0D7tu6OeSSKXgqTKsGZ6XyDPeMcB54sB2ngslytHDwwYydCKfhbQzymAk2Nnqx71WbSJ8i)EpcnkHIpDKkbEHXOIpDKiCdhLaUHdklVPesB2ngslytHvJs3TpR0rjyzjJnGAjLaN1JX6sja1mmgnf7ZgOR9A4a2rEejpYwLqXNosLaVWyuXNoseUHJsa3WbLL3ucTxdhWos1O0DRER0rjyzjJnGAjLaN1JX6sjS(rM2BOjqG2oIKhzlnpEe60pY0Ednbc02r(DeEeyqSkDqkVpseW8r2C0inRYXXmF1j8ilFKTpFe60pcpcmiwLoiL3hjcy(iBoAKMv54yMV6eEKFhz7MhzdLqXNosLWhR9rZmKOH)OkgqnkD3(ukDucwwYydOwsjWz9ySUuc8iWGyv6GuEFKiG5JS5OrAwLJJz(Qt4rK8ip5XJqN(r4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJ87iBPrju8PJujaP8(ir02ytSTeOgLUBFOkDucwwYydOwsjWz9ySUucRFeEeyqSkDqkVpseW8r2C0inRYXXmF1j8i)oIECKfhrMsu0bmFKnhXlmUZphZ8vNWJSXrOt)iRFeEeyqSkDqkVpseW8r2C0inRYXXmF1j8i)oY2ThzXrKWrKPefDaZhzZr8cJ78ZXmF1j8iBCe60pcpcmiwLoiL3hjcy(iBoAKMv54yMV6eEejpY2NOek(0rQe4fgJamRaWPWszmOAu6Uvpu6Oek(0rQeKBSb5bf7ZqYHx2yqLGLLm2aQLuJsxAEuPJsWYsgBa1skboRhJ1Lsy9JupTX6XCYf2ePWOoPn410r6SSKXg4i0PFKPWwooG5JS5iEKqkV20r6SSKXg4iBCKfhrJz0I(4a3w3ELauiI(OWGkpYIJWJadIvPds59rIaMpYMJgPzvooM5RoHh53rOrju8PJujSxjafIOpkmOs1O0LMTkDucwwYydOwsjWz9ySUucWGcJG7fdCKFhzZJS4iRFejCKPWwooG5JS5iEKqkV20r6SSKXg4i0PFezkrr3QgdqTxd6GtXL6ilFK2RbrqTAvAaeGI15Nds59rIaMpYMJgPzvohrY3JO3hzXrM2BOjqTxd6km2XmF1j8i)ocVGdAAVDKnocD6hzAVHMabA7i)ocnpQek(0rQeGuEFKiG5JS5OrAwLJAu6sdnkDucwwYydOwsjWz9ySUucYuIIUvngGAVg0bNIl1rK89i0CKfhrMsu0bmFKnhXdM5GtXL6i)EpcnhzXrKPefDaZhzZrAXkJ5aXQ8ilocuZWy0uSpBGU2RHdyh5r(DeAucfF6ivcAXkJHGT2EKQrPlnBQ0rjyzjJnGAjLaN1JX6sjmf2YXbIW7SSKXg4ilocZezgCVKX2rwCKP9gAceOTJi5rw)iGyCGi8oM5RoHhz5JS5JhzdLqXNosLaicVAu6sZtu6OeSSKXgqTKsGZ6XyDPeGbfgb3lg4is(EKNpcD6hz9JadkmcUxmWrK89iBEKfhHhbgeRshVWyeGzfaofwkJbDmZxDcpIKh5jhzXrw)i8iWGyv6GuEFKiG5JS5OrAwLJJz(Qt4rK8i084rOt)iRFeEeyqSkDqkVpseW8r2C0inRYXXmF1j8i)oYhhCKhWrO5iloYuylhhW8r2CepsiLxB6iDwwYydCe60pcpcmiwLoiL3hjcy(iBoAKMv54yMV6eEKFh5JdoYd4ip5iloIeoYuylhhW8r2CepsiLxB6iDwwYydCKnoYghzXrw)is4itHTCCqkVpseTn2eBlbollzSbocD6hHhbgeRshKY7JerBJnX2sGJz(Qt4rK8iBEKnoYgkHIpDKkH9kbOqe9rHbvQgLU08SshLGLLm2aQLucCwpgRlLamOWi4EXah53rE(iloImLOOdy(iBoIhmZbNIl1r(9EeAucfF6ivcWGcJGdRLYuJsxA0BLokbllzSbulPe4SEmwxkbyqHrW9IboYV3JS5rwCezkrrhW8r2CepyMJs7iloY6hz9JWJadIvPds59rIaMpYMJgPzvooM5RoHh53r07JqN(r4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJi5rOHMJS4is4i1tBSEmhCVaXkisUhZzzjJnWr24i0PFezkrrhW8r2CepyMdofxQJi57r28i0PFezkrrhW8r2CepyMJz(Qt4r(DKNpcD6hzAVHMabA7i)ocnpFe60pImLOOdUxGyfej3J5yMV6eEKnucfF6ivcaZhPCGh1O0LMNsPJsWYsgBa1skHIpDKkbEHXOIpDKiCdhLaUHdklVPeKPAmavi4EXaQrnkbnMXdVCnkDu6UvPJsWYsgBa1sQrPlnkDucwwYydOwsnkD3uPJsWYsgBa1sQrP7tu6Oek(0rQeGuEFKird)rvmGsWYsgBa1sQrP7ZkDucwwYydOwsjWz9ySUuctHTCCDMgdbmFKqNLLm2akHIpDKkHotJHaMpsOAu6Q3kDucwwYydOwsnkDFkLokHIpDKkbTy6ivcwwYydOwsnkDFOkDucwwYydOwsjWz9ySUucYuIIUvngGAVg0bNIl1rK8iBpYIJitjk6aMpYMJ4bZCGyvQek(0rQe0IvgdbBT9ivJsx9qPJsWYsgBa1skboRhJ1LsqoGWJqN(rk(0r6aMps5apoEbNJ8EKhvcfF6ivcaZhPCGh1O0D7JkDucwwYydOwsjWz9ySUucs4iYbeEe60psXNoshW8rkh4XXl4CejpYJkHIpDKkb4EbIvi5apQrnkH2RHdyhPshLUBv6OeSSKXgqTKsGZ6XyDPew)iYuIIUvngGAVg0bNIl1rK89i69rwCK1pcmOWi4EXah53r28i0PFenMrl6JdCBD8cJraMva4uyPmg8i0PFezkrr3QgdqTxd6GtXL6is(Ee94i0PFenMrl6JdCBDYn2G8GI9zi5WlBm4rOt)iRFejCenMrl6JdCBD7vcqHi6JcdQ8iloIeoIgZOf9XboAC7vcqHi6JcdQ8iBCKnoYIJiHJOXmArFCGBRBVsakerFuyqLhzXrKWr0ygTOpoWrJBVsakerFuyqLhzXrKPefDaZhzZrAXkJ5aXQ8iBCe60pY6hzAVHMabA7i)oYMhzXrKPefDRAma1EnOdofxQJi5rE8iBCe60pY6hrJz0I(4ahnoEHXiaZkaCkSugdEKfhrMsu0TQXau71Go4uCPoIKhHMJS4is4itHTCCaZhzZr8cJ78ZzzjJnWr2qju8PJuj0EnCa7ivJsxAu6OeSSKXgqTKsGZ6XyDPe4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJ87iB38i0PFejCe7bIQ10mGBvJfzgaIG9xJrHicsPzSoyiiL3hzNFkHIpDKkHpw7JMzird)rvmGAu6UPshLGLLm2aQLucCwpgRlLW6hHhbgeRshKY7JebmFKnhnsZQCCmZxDcpYVJOhhzXrKPefDaZhzZr8cJ78ZXmF1j8iBCe60pY6hHhbgeRshKY7JebmFKnhnsZQCCmZxDcpYVJSD7rwCejCezkrrhW8r2CeVW4o)CmZxDcpYghHo9JWJadIvPds59rIaMpYMJgPzvooM5RoHhrYJS9jkHIpDKkbEHXiaZkaCkSugdQgLUprPJsO4thPsas59rIaMpYMJgPzvokbllzSbulPgLUpR0rjyzjJnGAjLaN1JX6sjadkmcUxmWrK89ipRek(0rQe2ReGcr0hfguPAu6Q3kDucwwYydOwsjWz9ySUucWGcJG7fdCejFpYMhzXrw)iRFK1pIgZOf9XboAC7vcqHi6JcdQ8i0PFezkrr3QgdqTxd6GtXL6is(EKnpYghzXrKPefDRAma1EnOdofxQJ87i6Xr24i0PFeEeyqSkDqkVpseW8r2C0inRYXXmF1j8i)EpYhhCKhWrO5i0PFezkrrhW8r2CKwSYyoM5RoHhrYJ8Xbh5bCeAoYgkHIpDKkH9kbOqe9rHbvQgLUpLshLGLLm2aQLucCwpgRlLGgZOf9XbUTU9kbOqe9rHbvEKfhbguyeCVyGJi57r2EKfhz9Jitjk6w1yaQ9AqhCkUuh537r28i0PFenMrl6JdCB62ReGcr0hfgu5r24ilocmOWi4EXah53rEYrwCezkrrhW8r2CepyMJstju8PJujamFKYbEuJs3hQshLGLLm2aQLucCwpgRlLW6hHhbgeRshKY7JebmFKnhnsZQCCmZxDcpIKh5jpEKfhbQzymAk2Nnqx71WbSJ8i)EpcnhzJJqN(r4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJ87iBPrju8PJujaP8(ir02ytSTeOgLU6HshLGLLm2aQLucCwpgRlLapcmiwLoiL3hjcy(iBoAKMv54yMV6eEejpIEOek(0rQeKBSb5bf7ZqYHx2yq1O0D7JkDucwwYydOwsjWz9ySUucWGcJG7fdCKFh55JS4iYuIIoG5JS5iEWmhCkUuh537rOrju8PJujadkmcoSwktnkD3UvPJsWYsgBa1skboRhJ1LsaguyeCVyGJ879iBEKfhrMsu0bmFKnhXdM5O0oYIJS(rKPefDaZhzZr8Gzo4uCPoIKVhzZJqN(rKPefDaZhzZr8GzoM5RoHh537r(4GJ8aoYZUN6iBOek(0rQeaMps5apQrP7wAu6OeSSKXgqTKsO4thPsaeHxjWLMJn0uSpBGkD3Qe8LeH4sZXgAk2NnqLWtPe4SEmwxkbMjYm4EjJn1O0D7MkDucwwYydOwsju8PJujWlmgv8PJeHB4OeWnCqz5nLGmvJbOcb3lgqnQrja4rIcnlnMshLUBv6OeSSKXgqTKsO4thPsyVsakerFuyqLkboRhJ1LsOEAJ1J5mjsdhWMwdPfJLtxyNLLm2akbCNgIducB(OAu6sJshLGLLm2aQLucCwpgRlLq90gRhZzsKgoGnTgslglNUWollzSboYIJitjk6w1yaQ9AqhCkUuhrYJqZrwCezkrrNjrA4a20AiTySC6c7aXQuju8PJuj0EnCa7ivJs3nv6OeSSKXgqTKsO4thPsaeHxjG70qCGsyZhvJs3NO0rjyzjJnGAjLaN1JX6sjOXmArFCGBRBVsakerFuyqLhzXrGbfgb3lg4isEKhpYIJOXmArFCGJghmOWi4WAPmLqXNosLWELauiI(OWGkvJs3Nv6OeSSKXgqTKsGZ6XyDPe0ygTOpoWT1TxjafIOpkmOYJS4is4iAmJw0hh4OXTxjafIOpkmOYJS4iRFezkrr3QgdqTxd6GtXL6isEKThzXrk(0r62ReGcr0hfguPRtKiU)2NJSHsO4thPsay(iBocoml)MD1O0vVv6Oek(0rQeKBSb5bf7ZqYHx2yqLGLLm2aQLuJs3NsPJsWYsgBa1skHIpDKkbyqHrWH1szkboRhJ1LsqchrMsu0jJJaGPGJJz(Qt4rOt)it7TJi5rE(iloIgZOf9XbUTU9kbOqe9rHbvQeWDAioqjS5JQrP7dvPJsWYsgBa1skboRhJ1LsaguyeCVyGJ8EKNvcfF6ivcqkVpseTn2eBlbQrPREO0rjyzjJnGAjLaN1JX6sjadkmcUxmWrEpYZkHIpDKkHpw7JMzird)rvmGAu6U9rLokbllzSbulPe4SEmwxkbyqHrW9IboY7rEwju8PJujWlmgbywbGtHLYyq1O0D7wLokbllzSbulPe4SEmwxkbyqHrW9IboY7rEwju8PJujSxjafIOpkmOs1O0DlnkDucwwYydOwsjWz9ySUucWGcJG7fdCejFpYMhzXr0ygTOpoWrJBVsakerFuyqLhzXrM2BhrYJ88rwCK1pIgZOf9XbUToyqHrWH1szhHo9JiHJmf2YXbdkmcoSwkZzzjJnWrwCenMrl6JdCBDW9ceRqYbEoYgkHIpDKkH9kbOqe9rHbvQgLUB3uPJsWYsgBa1skboRhJ1LsqJz0I(4a3whW8r2CeCyw(n7hHo9JOXmArFCGBRBVsakerFuyqLhzXr0ygTOpoWrJBVsakerFuyqLhHo9JiHJmf2YXbmFKnhbhMLFZUZYsgBGJS4iYuIIUvngGAVg0bNIl1rw(iTxdIGA1Q0aiafRZphKY7JebmFKnhnsZQCoYd7rGAggJ2l4yhrY3JO3kHIpDKkbiL3hjcy(iBoAKMv5OgLUBFIshLGLLm2aQLucCwpgRlLamOWi4EXah537r28iloImLOOdy(iBoIhmZXmF1juju8PJujamFKYbEuJs3TpR0rjyzjJnGAjLqXNosLaVWyuXNoseUHJsa3WbLL3ucYungGkeCVya1OgLGmvJbOcb3lgqPJs3TkDucwwYydOwsjWz9ySUucs4itHTCCaZhzZr8iHuETPJ0zzjJnWrOt)it7TJi5r2(8rOt)iAmJw0hh4262ReGcr0hfgu5rwCejCezkrrNmocaMcooM5RoHkHIpDKkbyqHrWH1szQrPlnkDucfF6ivcW9ceRqYbEucwwYydOwsnQrjK2SBmKwWMcJk(00AkDu6UvPJsO4thPsqUXgKhuSpdjhEzJbvcwwYydOwsnkDPrPJsWYsgBa1skboRhJ1LsGhbgeRshKY7JebmFKnhnsZQCCmZxDcpYVJSDZJqN(rKWrShiQwtZaUvnwKzaic2FngfIiiLMX6GHGuEFKD(Pek(0rQe(yTpAMHen8hvXaQrP7MkDucwwYydOwsjWz9ySUuc8iWGyv6GuEFKiG5JS5OrAwLJJz(Qt4rK8ip5XJqN(r4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJ87iBPrju8PJujaP8(ir02ytSTeOgLUprPJsWYsgBa1skboRhJ1Lsy9JWJadIvPds59rIaMpYMJgPzvooM5RoHh53r0JJS4iYuIIoG5JS5iEHXD(5yMV6eEKnocD6hz9JWJadIvPds59rIaMpYMJgPzvooM5RoHh53r2U9iloIeoImLOOdy(iBoIxyCNFoM5RoHhzJJqN(r4rGbXQ0bP8(iraZhzZrJ0SkhhZ8vNWJi5r2(eLqXNosLaVWyeGzfaofwkJbvJs3Nv6OeSSKXgqTKsGZ6XyDPeGbfgb3lg4iVhz7rwCK1pcpcmiwLoEHXiaZkaCkSugd6yMV6eEKFhP4thPdUxGyfsoWJJxWbnT3ocD6hz9Jmf2YXj3ydYdk2NHKdVSXGollzSboYIJWJadIvPtUXgKhuSpdjhEzJbDmZxDcpYVJu8PJ0b3lqScjh4XXl4GM2BhzJJSHsO4thPsGxymQ4thjc3WrjGB4GYYBkbzQgdqfcUxmGAu6Q3kDucwwYydOwsjWz9ySUucRFK1pcpcmiwLoEHXiaZkaCkSugd6yMV6eEejpsXNoshW8rkh4XXl4GM2BhzJJS4iRFeEeyqSkD8cJraMva4uyPmg0XmF1j8isEKIpDKo4EbIvi5apoEbh00E7iBCKnoYIJitjk6sB2ngslytHDmZxDcpIKhHxWbnT3ucfF6ivc7vcqHi6JcdQunkDFkLokbllzSbulPe4SEmwxkbzkrrxAZUXqAbBkSJz(Qt4r(DKNpYIJadkmcUxmWrEpYJkHIpDKkbiL3hjcy(iBoAKMv5OgLUpuLokbllzSbulPe4SEmwxkbzkrrxAZUXqAbBkSJz(Qt4r(DKIpDKoiL3hjcy(iBoAKMv544fCqt7TJS8rE09SsO4thPsas59rIaMpYMJgPzvoQrPREO0rjyzjJnGAjLaN1JX6sjitjk6aMpYMJ4bZCuAhzXrGbfgb3lg4i)EpYMkHIpDKkbG5JuoWJAu6U9rLokbllzSbulPek(0rQe4fgJk(0rIWnCuc4goOS8MsqMQXauHG7fdOg1OgLqrn7btji0Ejg1OgLc]] )


end
