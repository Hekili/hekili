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

    local dcon_imps = 0
    local dcon_imps_v = 0

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
                    dcon_imps = #guldan + #wild_imps + #imps

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


        --[[ i = 1
        while( guldan[i] ) do
            if guldan[i] < now then
                print( "reset removing imp" )
                table.remove( guldan, i )
            else
                i = i + 1
            end
        end ]]

        wipe( guldan_v )
        for n, t in ipairs( guldan ) do guldan_v[ n ] = t end

        dcon_imps_v = dcon_imps


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
            return
        end

        count = count or 0
        for i = 1, count do
            table.remove( db, 1 )
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
                if buff.wild_imps.stack > 0 then return true end
                if prev_gcd[1].summon_demonic_tyrant then
                    if dcon_imps_v > 2 and query_time - action.summon_demonic_tyrant.lastCast < 0.1 then return true end
                    return false, format( "post-tyrant window is 0.1s with 3+ imps; you had %d imps and tyrant cast was %.2f seconds ago", dcon_imps_v, query_time - action.summon_demonic_tyrant.lastCast )
                end 
                return false, "no imps available"
            end,

            handler = function ()
                if azerite.explosive_potential.enabled and ( buff.wild_imps.stack + dcon_imps_v ) >= 3 then applyBuff( "explosive_potential" ) end
                dcon_imps_v = 0
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
                    dcon_imps_v = buff.wild_imps.stack
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


    spec:RegisterPack( "Demonology", 20190305.1225, [[dSuWDbqicflsvfQhrQIUKQkeTjLWNivjzukP6ukfwLQa6vkrnlLuULQaTlQ6xKQAyQcDmLsldr8mLIMMQGUMQkTnsvQVrQcnovb4Cek16uvbnpvr3tvAFeQoOQkKwOsKhsOenrcL0fvvbQpQQcKojPkGvQQQzsOe6Mekb7KuPFQQcHHsQcAPQQaXtjyQKkUQQkGVsQc0Ej5VadgPdlzXe1Jr1KbDzkBMiFwvz0kvNwQxJOA2qUnv2TOFlmCs54KQKA5O8COMUIRJW2rK(UsY4vvrNhrz9KQeZNq2VkR2Q0rjaRXu6sYJBf7h38Xh63scjpKeLWqMMPe0ko51NPeYYzkbXQ5ImqXhzkbTImuuqLokbCqW4MsyFgn8puF9)6zNq2ZdN(42rGQPJKZkPrFC746ReKjA0OhivYkbynMsxsECRy)4Mp(q)ws2Qh3Q3kbSMXv6sIER3kH9gcTujReGgMRe0ZJkwnxKbk(i7O6blgk4KF)1ZJUpJg(hQV(F9Sti75HtFC7iq10rYzL0OpUDC9V)65rflum((rF4AhLKh3k2h9bp6ws(Hp(7r1dflC)V)65rfl3R8ZW)W7VEE0h8OcAgcDuXIbNC)9xpp6dE0FaSDuzcjjFAZUXaAbBkKNq7ODIhRGhnKokZCvND(DuXsX6rN2zhvkyhvxB2n2r1dd2uOJw8Pj1oQ2EHn)9xpp6dE0FejISJYmE4CwcpQy1CrkhO5OAm7b5HtUMJ2shTNJ24J2jEQCo6649GabpQglKlzezhfpncD09Ib5fE2WF)1ZJ(GhvpmwzSJk0A7rE0cHIvg8OAm7b5HtUMJoXr1yb)ODINkNJkwnxKYbA83F98Op4r)rHWJgAwASJkSxWy1rxkqZrdIb3q7OH0rLdm(Os93(Gp6ehTMJIScph9ZMJgPDuxWSJI3lg0F)1ZJ(Gh9haBh9hpTZataGT9Jp662p1m(yWJAjpiYXyh1s4ghLvZUXo6Sx5r)XtX(SXpTZataGT9Jp662p1m(yWJYjymlNJof7Zg9k8rHwn7BC0joArA0WJA)KByCtQDuzcw253rdPJYkExOJkwkwXELGglKAKPe0ZJkwnxKbk(i7O6blgk4KF)1ZJUpJg(hQV(F9Sti75HtFC7iq10rYzL0OpUDC9V)65rflum((rF4AhLKh3k2h9bp6ws(Hp(7r1dflC)V)65rfl3R8ZW)W7VEE0h8OcAgcDuXIbNC)9xpp6dE0FaSDuzcjjFAZUXaAbBkKNq7ODIhRGhnKokZCvND(DuXsX6rN2zhvkyhvxB2n2r1dd2uOJw8Pj1oQ2EHn)9xpp6dE0FejISJYmE4CwcpQy1CrkhO5OAm7b5HtUMJ2shTNJ24J2jEQCo6649GabpQglKlzezhfpncD09Ib5fE2WF)1ZJ(GhvpmwzSJk0A7rE0cHIvg8OAm7b5HtUMJoXr1yb)ODINkNJkwnxKYbA83F98Op4r)rHWJgAwASJkSxWy1rxkqZrdIb3q7OH0rLdm(Os93(Gp6ehTMJIScph9ZMJgPDuxWSJI3lg0F)1ZJ(Gh9haBh9hpTZataGT9Jp662p1m(yWJAjpiYXyh1s4ghLvZUXo6Sx5r)XtX(SXpTZataGT9Jp662p1m(yWJYjymlNJof7Zg9k8rHwn7BC0joArA0WJA)KByCtQDuzcw253rdPJYkExOJkwkwX(7)9xpp6p4FACIXGhv2KcMDuE4KR5OY2xNy)r)r5CtBWhnJ8b3lMtIaD0IpDK4JgjIm)9V4thj2RXmE4KR5vcvyYV)fF6iXEnMXdNCnl)QVueW7FXNosSxJz8WjxZYV6xeFolNA6iV)fF6iXEnMXdNCnl)QpMW5IeOzZ9V4thj2RXmE4KRz5x97mngaAUiXR1sVtHSC8DMgdanxKyVLLmYG3)IpDKyVgZ4HtUMLF1hNLgEpgaEQbF)l(0rI9AmJho5Aw(vFTy6iV)fF6iXEnMXdNCnl)QVwSYyaCRTh5AT0RmHKKFvJGG2PH94P4Kl(2fYessEO5IS5aEWmpmwL3)IpDKyVgZ4HtUMLF1hAUiLd0Swl9khySirfF6i9qZfPCGgpVWZ7J3)IpDKyVgZ4HtUMLF1hVxWyfqoqZAT0RyKdmwKOIpDKEO5IuoqJNx4r8hV)3F98O)G)PXjgdEuJuJr2rN2zhD2TJw8jyhTXhTiTAujJm)9V4thj(fRzieafCYV)fF6iXl)QF70qbUJCTw6T0lgRhZB)udf4MudOfJLtxiVLLmYGlMcz54HMlYMd4rIjCAthP3YsgzWfAmJuWhh636XeoxKaO5IS5GHmwLZ9V4thjE5x91IPJCTw6vZgp0Cr2CWqgRYXx8Pj1wSUyMcz54tB2ngqlytH8wwYidksKmHKKpTz3yaTGnfYtOTHirt7mWeayBp38X7FXNos8YV6tGnqpMdVwl9QzJhAUiBoyiJv54l(0KAIenTZataGT98D7V3)IpDK4LF1x2yyJrENFR1sVA24HMlYMdgYyvo(IpnPMirt7mWeayBpF3(79V4thjE5x9LrrabsemYwRLE1SXdnxKnhmKXQC8fFAsnrIM2zGjaW2E(U937FXNos8YV6l1mtgfbCTw6vZgp0Cr2CWqgRYXx8Pj1ejAANbMaaB7572FV)fF6iXl)QpVqiqXNosaQXZAz5SxipsGPbcnln2AT0BPxmwpM3(PgkWnPgqlglNUqEwLKVykKLJhAUiBoGhjMWPnDKEllzKbxmTZEU5JledpcemwLEmHZfjaAUiBoyiJv54zMR6eF)l(0rIx(v)9kHGqc8rGGvUwl9w6fJ1J5TFQHcCtQb0IXYPlKNvj5lM2zp)Dboiqa8EXGItYczcjjV9tnuGBsnGwmwoDH8WyvUqMqsYVQrqq70WE8uCYFU5cXOXmsbFCOFRFVsiiKaFeiyLleJgZif8XHEs87vcbHe4JabR8(x8PJeV8R(qZfPCGM1APxCqGa49IbF(U5czcjjp0Cr2CapyMNqBHmHKKhAUiBoGhmZJNIt(7dV)fF6iXl)QF70qbUJCTw6T0lgRhZB)udf4MudOfJLtxipRsYxitij5x1iiODAypEko5ItYczcjjV9tnuGBsnGwmwoDH8mZvDIFw8PJ0J3lyScihOXB)04eJbM2zlwxmtHSC8qZfzZb8iXeoTPJ0BzjJmOir8iqWyv6XeoxKaO5IS5GHmwLJNzUQtS4BjzJ7FXNos8YV6dJWTwl9kMP5K353IPDgycaSnX38XfyndHatX(Sb7BNgkWDKpj5(x8PJeV8R(YnYW8GG9za5WjBm8AT0BPxmwpM3(PgkWnPgqlglNUqEwLKl(JlM2zp3(4cSMHqGPyF2G9Ttdf4oYNKSqMqsYdzwbXtHi3yypZCvN4ftHSC8Pn7gdOfSPqEllzKbV)fF6iXl)Qp0Cr2CaEyw(n7R1sVRltij5x1iiODAypEko5p1BrIKjKK8qZfzZbAXkJ5j02qKiSMHqGPyF2G9Ttdf4oYNKC)l(0rIx(vFEHqGIpDKauJN1YYzVPn7gdOfSPqR1sVtHSC8Pn7gdOfSPqEllzKbxG1mecmf7ZgSVDAOa3r(8LK7FXNos8YV6Zlecu8PJeGA8Swwo7TDAOa3rUwl9I1mecmf7ZgSVDAOa3rk(27FXNos8YV6)XAx0mdizOpIIbxRLExFANbMaaBt8TK8Oirt7mWeayBp5rGGXQ0JjCUibqZfzZbdzSkhpZCvN4L3(Rir8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8ZTBUX9V4thjE5x9XeoxKasBKj1wcxRLE5rGGXQ0JjCUibqZfzZbdzSkhpZCvNyXF4JIeXJabJvPht4CrcGMlYMdgYyvoEM5QoXp3sY9V4thjE5x95fcbGmRG4PqKBm8AT0768iqWyv6XeoxKaO5IS5GHmwLJNzUQt8tXEHmHKKhAUiBoGxiuNFEM5QoXBis068iqWyv6XeoxKaO5IS5GHmwLJNzUQt8ZTBxigzcjjp0Cr2CaVqOo)8mZvDI3qKiEeiySk9ycNlsa0Cr2CWqgRYXZmx1jw8Tp8(x8PJeV8R(YnYW8GG9za5WjBm89V4thjE5x93ReccjWhbcw5AT076LEXy9yE5czseiqNKg8A6i9wwYidks0uilhp0Cr2CapsmHtB6i9wwYidUXcnMrk4Jd9B97vcbHe4JabRCbpcemwLEmHZfjaAUiBoyiJv54zMR6e)KK7VEEusE8Xh)rI1mecSx4XoAJpkEpyZELWJkfSJo72r5fEo60o7OH0rfRMlYMFuDiJv54pQo72r7CSCoAJp6ehnsezhv2(68O8cpD(D0w6O1r5gBQopAs4Kn2rdPJ2on8rx1i0rLTJgeZrLj7OZUDulHhnKo6SBhLx4XF)l(0rIx(vFmHZfjaAUiBoyiJv5Swl9IdceaVxm4ZnxSUyMcz54HMlYMd4rIjCAthP3YsgzqrIKjKK8RAee0onShpfN8LBNggG1QvPbbqcwNFEmHZfjaAUiBoyiJv5i(REVyANbMa0onSVqipZCvN4N8cpGPD2gIenTZataGT9KKhV)fF6iXl)QVwSYyaCRTh5AT0RmHKKFvJGG2PH94P4Kl(ljlKjKK8qZfzZb8GzE8uCYF(sYczcjjp0Cr2CGwSYyEySkxG1mecmf7ZgSVDAOa3r(KK7FXNos8YV6dJWTwl9ofYYXdJW5TSKrgCbZKygEVKr2IPDgycaSnXxhgJhgHZZmx1jE5nFCJ7FXNos8YV6VxjeesGpceSY1APxCqGa49Ibf)9xrIwhheiaEVyqXF3CbpcemwLEEHqaiZkiEke5gd7zMR6el(dxSopcemwLEmHZfjaAUiBoyiJv54zMR6elojpks068iqWyv6XeoxKaO5IS5GHmwLJNzUQt8Zpo8bsYIPqwoEO5IS5aEKycN20r6TSKrguKiEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(5hh(aF4cXmfYYXdnxKnhWJet40MosVLLmYGBSXI1fZuilhpMW5IeqAJmP2sO3YsgzqrI4rGGXQ0JjCUibK2itQTe6zMR6el(MBSX9V4thjE5x9XbbcGhwtUTwl9IdceaVxm4ZFxitij5HMlYMd4bZ84P4K)8LK7FXNos8YV6dnxKYbAwRLEXbbcG3lg857MlKjKK8qZfzZb8GzEcTfRVopcemwLEmHZfjaAUiBoyiJv54zMR6e)uVfjIhbcgRspMW5IeanxKnhmKXQC8mZvDIfNes2qKizcjjp0Cr2CapyMhpfNCXF3uKizcjjp0Cr2CapyMNzUQt8ZFfjAANbMaaB7jj)UX9V4thjE5x95fcbk(0rcqnEwllN9kt0iiOa49IbV)3)IpDKyVmrJGGcG3lg8fheiaEyn52AT0RyMcz54HMlYMd4rIjCAthP3YsgzqrIM2zIV9xrI0ygPGpo0V1VxjeesGpceSYfIrMqsYlJIaIiWJNzUQt89V4thj2lt0iiOa49Ibx(vF8EbJva5an3)7FXNosShYJeyAGqZsJ9UxjeesGpceSY1qDAao8DZhV)fF6iXEipsGPbcnln2YV63onuG7ixRLELjKK8RAee0onShpfNCXjzHmHKK3(PgkWnPgqlglNUqEySkV)fF6iXEipsGPbcnln2YV6dJWTgQtdWHVB(49V4thj2d5rcmnqOzPXw(v)9kHGqc8rGGvUwl9QXmsbFCOFRFVsiiKaFeiyLlWbbcG3lgu8hxOXmsbFCONepoiqa8WAYT7FXNosShYJeyAGqZsJT8R(qZfzZb4Hz53SVwl9QXmsbFCOFRFVsiiKaFeiyLleJgZif8XHEs87vcbHe4JabRCX6Yess(vnccANg2JNItU4Bxu8PJ0VxjeesGpceSsFNaju)TpBC)l(0rI9qEKatdeAwASLF1xUrgMheSpdihozJHV)fF6iXEipsGPbcnln2YV6JdceapSMCBnuNgGdF38X1APxXitij5Lrrare4XZmx1jwKOPDM4)UqJzKc(4q)w)ELqqib(iqWkV)fF6iXEipsGPbcnln2YV6JjCUibK2itQTeUwl9IdceaVxm47V3)IpDKypKhjW0aHMLgB5x9)yTlAMbKm0hrXGR1sV4GabW7fd((79V4thj2d5rcmnqOzPXw(vFEHqaiZkiEke5gdVwl9IdceaVxm47V3)IpDKypKhjW0aHMLgB5x93ReccjWhbcw5AT0loiqa8EXGV)E)l(0rI9qEKatdeAwASLF1FVsiiKaFeiyLR1sV4GabW7fdk(7Ml0ygPGpo0tIFVsiiKaFeiyLlM2zI)7I11ygPGpo0V1JdceapSMCtKiXmfYYXJdceapSMCZBzjJm4cnMrk4Jd9B949cgRaYbA24(RNhLKhF8XFKyndHa7fESJ24JI3d2Sxj8Osb7OZUDuEHNJoTZoAiDuXQ5IS5hvhYyvo(JQZUD0ohlNJ24JoXrJer2rLTVopkVWtNFhTLoADuUXMQZJMeozJD0q6OTtdF0vncDuz7ObXCuzYo6SBh1s4rdPJo72r5fE83)IpDKypKhjW0aHMLgB5x9XeoxKaO5IS5GHmwLZAT0RgZif8XH(TEO5IS5a8WS8B2fjsJzKc(4q)w)ELqqib(iqWkxOXmsbFCONe)ELqqib(iqWkfjsmtHSC8qZfzZb4Hz53S7TSKrgCHmHKKFvJGG2PH94P4KVC70WaSwTkniasW68ZJjCUibqZfzZbdzSkhXF177FXNosShYJeyAGqZsJT8R(qZfPCGM1APxCqGa49IbF(U5czcjjp0Cr2CapyMNzUQt89V4thj2d5rcmnqOzPXw(vFEHqGIpDKauJN1YYzVYencckaEVyW7)9V4thj23onuG7iFBNgkWDKR1sVRltij5x1iiODAypEko5I)Q3lwhheiaEVyWNBksKgZif8XH(TEEHqaiZkiEke5gdlsKmHKKFvJGG2PH94P4Kl(RylsKgZif8XH(TE5gzyEqW(mGC4KngwKO1fJgZif8XH(T(9kHGqc8rGGvUqmAmJuWhh6jXVxjeesGpceSYn2yHy0ygPGpo0V1VxjeesGpceSYfIrJzKc(4qpj(9kHGqc8rGGvUqMqsYdnxKnhOfRmMhgRYnejA9PDgycaSTNBUqMqsYVQrqq70WE8uCYf)XnejADnMrk4Jd9K45fcbGmRG4PqKBm8czcjj)QgbbTtd7XtXjxCswiMPqwoEO5IS5aEHqD(5TSKrgCJ7FXNosSVDAOa3rU8R(FS2fnZasg6JOyW1APxEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(52nfjsmMEnrRPzq)2njzt9wSV)fF6iX(2PHcCh5YV6ZlecazwbXtHi3y41AP315rGGXQ0JjCUibqZfzZbdzSkhpZCvN4NI9czcjjp0Cr2CaVqOo)8mZvDI3qKO15rGGXQ0JjCUibqZfzZbdzSkhpZCvN4NB3UqmYessEO5IS5aEHqD(5zMR6eVHir8iqWyv6XeoxKaO5IS5GHmwLJNzUQtS4BF49V4thj23onuG7ix(vFmHZfjaAUiBoyiJv5C)l(0rI9Ttdf4oYLF1FVsiiKaFeiyLR1sV4GabW7fdk(7V3)IpDKyF70qbUJC5x93ReccjWhbcw5AT0loiqa8EXGI)U5I1xFDnMrk4Jd9K43ReccjWhbcwPirYess(vnccANg2JNItU4VBUXczcjj)QgbbTtd7XtXj)PyVHir8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8Z3po8bsIirYessEO5IS5aTyLX8mZvDIf)JdFGKSX9V4thj23onuG7ix(vFO5IuoqZAT0RgZif8XH(T(9kHGqc8rGGvUaheiaEVyqXF3UyDzcjj)QgbbTtd7XtXj)57MIePXmsbFCOFt)ELqqib(iqWk3yboiqa8EXGpF4czcjjp0Cr2CapyMNq7(x8PJe7BNgkWDKl)QpMW5IeqAJmP2s4AT0768iqWyv6XeoxKaO5IS5GHmwLJNzUQtS4p8XfyndHatX(Sb7BNgkWDKpFjzdrI4rGGXQ0JjCUibqZfzZbdzSkhpZCvN4NBj5(x8PJe7BNgkWDKl)QVCJmmpiyFgqoCYgdVwl9YJabJvPht4CrcGMlYMdgYyvoEM5QoXIl23)IpDKyF70qbUJC5x9XbbcGhwtUTwl9IdceaVxm4ZFxitij5HMlYMd4bZ84P4K)8LK7FXNosSVDAOa3rU8R(qZfPCGM1APxCqGa49IbF(U5czcjjp0Cr2CapyMNqBX6YessEO5IS5aEWmpEko5I)UPirYessEO5IS5aEWmpZCvN4NVFC4d8xVECJ7FXNosSVDAOa3rU8R(WiCRXjJJmWuSpBWVBxZv)eWjJJmWuSpBWV6X1APxMjXm8EjJS7FXNosSVDAOa3rU8R(8cHafF6ibOgpRLLZELjAeeua8EXG3)7FXNosSpTz3yaTGnf6LxieO4thja14zTSC2BAZUXaAbBkeqMOrWo)wRLE5rGGXQ0N2SBmGwWMc5zMR6e)KKhV)fF6iX(0MDJb0c2uOLF1NxieO4thja14zTSC2BAZUXaAbBkeO4ttQTwl9ktij5tB2ngqlytH8eA3)7FXNosSpTz3yaTGnfcu8Pj1ELBKH5bb7ZaYHt2y47FXNosSpTz3yaTGnfcu8Pj1w(v)pw7IMzajd9rum4AT0lpcemwLEmHZfjaAUiBoyiJv54zMR6e)C7MIejgtVMO10mOF7MKSPEl23)IpDKyFAZUXaAbBkeO4ttQT8R(ycNlsaPnYKAlHR1sV8iqWyv6XeoxKaO5IS5GHmwLJNzUQtS4p8rrI4rGGXQ0JjCUibqZfzZbdzSkhpZCvN4NBj5(x8PJe7tB2ngqlytHafFAsTLF1NxieaYScINcrUXWR1sVRZJabJvPht4CrcGMlYMdgYyvoEM5QoXpf7fYessEO5IS5aEHqD(5zMR6eVHirRZJabJvPht4CrcGMlYMdgYyvoEM5QoXp3UDHyKjKK8qZfzZb8cH68ZZmx1jEdrI4rGGXQ0JjCUibqZfzZbdzSkhpZCvNyX3(W7FXNosSpTz3yaTGnfcu8Pj1w(vFEHqGIpDKauJN1YYzVYencckaEVyW1APxCqGa49IbF3UyDEeiySk98cHaqMvq8uiYng2Zmx1j(zXNospEVGXkGCGgpVWdyANjs06tHSC8YnYW8GG9za5WjBmS3YsgzWf8iqWyv6LBKH5bb7ZaYHt2yypZCvN4NfF6i949cgRaYbA88cpGPD2gBC)l(0rI9Pn7gdOfSPqGIpnP2YV6VxjeesGpceSY1AP31xNhbcgRspVqiaKzfepfICJH9mZvDIfV4thPhAUiLd045fEat7SnwSopcemwLEEHqaiZkiEke5gd7zMR6elEXNospEVGXkGCGgpVWdyANTXglKjKK8Pn7gdOfSPqEM5QoXIZl8aM2z3)IpDKyFAZUXaAbBkeO4ttQT8R(ycNlsa0Cr2CWqgRYzTw6vMqsYN2SBmGwWMc5zMR6e)83f4GabW7fd((49V4thj2N2SBmGwWMcbk(0KAl)QpMW5IeanxKnhmKXQCwRLELjKK8Pn7gdOfSPqEM5QoXpl(0r6XeoxKaO5IS5GHmwLJNx4bmTZw(r)V3)IpDKyFAZUXaAbBkeO4ttQT8R(qZfPCGM1APxzcjjp0Cr2CapyMNqBboiqa8EXGpF38(x8PJe7tB2ngqlytHafFAsTLF1NxieO4thja14zTSC2RmrJGGcG3lg8(F)l(0rI9Pn7gdOfSPqazIgb787nTz3yaTGnfATw6fheiaEVyqXF)DX6IzkKLJxlwzmaU12J0BzjJmOirYessEO5IS5aEWmpH2g3)IpDKyFAZUXaAbBkeqMOrWo)w(vFEHqaiZkiEke5gdF)l(0rI9Pn7gdOfSPqazIgb78B5x93ReccjWhbcw5AT0lpcemwLEEHqaiZkiEke5gd7zMR6el(2hWcCqGa49Ibf)DZ7FXNosSpTz3yaTGnfcit0iyNFl)QVwSYyaCRTh5AT0RmHKKFvJGG2PH94P4Kl(ljlKjKK8qZfzZb8GzE8uCYF(sYczcjjp0Cr2CGwSYyEySkxGdceaVxmO4VBE)l(0rI9Pn7gdOfSPqazIgb78B5x93ReccjWhbcw5AT0loiqa8EXGI)(79V4thj2N2SBmGwWMcbKjAeSZVLF1NxieO4thja14zTSC2RmrJGGcG3lgujqQXWDKkDj5XTI9JKqYw)2hsIsyvXYo)Wkb9G)O)GOREaD)b9hE0JQZUD02PfS5Osb7O6vAmJho5A0RokZ0RjAMbpkoC2rlIjC1yWJY3R8ZW(7VyXoTJ(7p8O)ajMqtlyJbpAXNoYJQx1zAma0CrI1R83)7VEaNwWgdE0hWrl(0rEuuJhS)(ReqnEWkDucqEKatdeAwAmLokD3Q0rjyzjJmOAjLqXNosLWELqqib(iqWkvcOonahQe28r1O0LeLokbllzKbvlPe4SEmwxkbzcjj)QgbbTtd7XtXj)OIFuso6IJktij5TFQHcCtQb0IXYPlKhgRsLqXNosLq70qbUJunkD3uPJsWYsgzq1skHIpDKkbyeoLaQtdWHkHnFunkDFOshLGLLmYGQLucCwpgRlLGgZif8XH(T(9kHGqc8rGGvE0fhfheiaEVyWJk(rF8OloQgZif8XHEs84GabWdRj3ucfF6ivc7vcbHe4JabRunkD)vPJsWYsgzq1skboRhJ1LsqJzKc(4q)w)ELqqib(iqWkp6IJkMJQXmsbFCONe)ELqqib(iqWkp6IJU(rLjKK8RAee0onShpfN8Jk(r3E0fhT4thPFVsiiKaFeiyL(obsO(BFo6gkHIpDKkbO5IS5a8WS8B2vJsx9wPJsO4thPsqUrgMheSpdihozJHvcwwYidQwsnkD1JkDucwwYidQwsjWz9ySUucI5OYessEzueqebE8mZvDIpQirhDANDuXp6VhDXr1ygPGpo0V1VxjeesGpceSsLqXNosLaoiqa8WAYnLaQtdWHkHnFunkDFakDucwwYidQwsjWz9ySUuc4GabW7fdE03J(RsO4thPsat4CrciTrMuBjunkDfBLokbllzKbvlPe4SEmwxkbCqGa49Ibp67r)vju8PJuj8XAx0mdizOpIIbvJs3TpQ0rjyzjJmOAjLaN1JX6sjGdceaVxm4rFp6VkHIpDKkbEHqaiZkiEke5gdRgLUB3Q0rjyzjJmOAjLaN1JX6sjGdceaVxm4rFp6VkHIpDKkH9kHGqc8rGGvQgLUBjrPJsWYsgzq1skboRhJ1LsaheiaEVyWJk(7r38OloQgZif8XHEs87vcbHe4JabR8Olo60o7OIF0Fp6IJU(r1ygPGpo0V1JdceapSMC7OIeDuXC0PqwoECqGa4H1KBEllzKbp6IJQXmsbFCOFRhVxWyfqoqZr3qju8PJujSxjeesGpceSs1O0D7MkDucwwYidQwsjWz9ySUucAmJuWhh636HMlYMdWdZYVz)OIeDunMrk4Jd9B97vcbHe4JabR8OloQgZif8XHEs87vcbHe4JabR8OIeDuXC0PqwoEO5IS5a8WS8B29wwYidE0fhvMqsYVQrqq70WE8uCYp6YhTDAyawRwLgeajyD(5XeoxKaO5IS5GHmwLZrf)9O6TsO4thPsat4CrcGMlYMdgYyvoQrP72hQ0rjyzjJmOAjLaN1JX6sjGdceaVxm4rF(E0np6IJktij5HMlYMd4bZ8mZvDIvcfF6ivcqZfPCGg1O0D7VkDucwwYidQwsju8PJujWlecu8PJeGA8OeqnEaz5mLGmrJGGcG3lgunQrj0onuG7iv6O0DRshLGLLmYGQLucCwpgRlLW6hvMqsYVQrqq70WE8uCYpQ4VhvVp6IJU(rXbbcG3lg8Opp6MhvKOJQXmsbFCOFRNxieaYScINcrUXWhvKOJktij5x1iiODAypEko5hv83Jk2hvKOJQXmsbFCOFRxUrgMheSpdihozJHpQirhD9JkMJQXmsbFCOFRFVsiiKaFeiyLhDXrfZr1ygPGpo0tIFVsiiKaFeiyLhDJJUXrxCuXCunMrk4Jd9B97vcbHe4JabR8OloQyoQgZif8XHEs87vcbHe4JabR8OloQmHKKhAUiBoqlwzmpmwLhDJJks0rx)Ot7mWeayBh95r38OloQmHKKFvJGG2PH94P4KFuXp6JhDJJks0rx)OAmJuWhh6jXZlecazwbXtHi3y4JU4OYess(vnccANg2JNIt(rf)OKC0fhvmhDkKLJhAUiBoGxiuNFEllzKbp6gkHIpDKkH2PHcChPAu6sIshLGLLmYGQLucCwpgRlLapcemwLEmHZfjaAUiBoyiJv54zMR6eF0NhD7MhvKOJkMJA61eTMMb9RAKeZGyaU)AeiKaycnJ1bdGjCUi78tju8PJuj8XAx0mdizOpIIbvJs3nv6OeSSKrguTKsGZ6XyDPew)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFEuX(OloQmHKKhAUiBoGxiuNFEM5QoXhDJJks0rx)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFE0TBp6IJkMJktij5HMlYMd4fc15NNzUQt8r34OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(OIF0Tpuju8PJujWlecazwbXtHi3yy1O09HkDucfF6ivcycNlsa0Cr2CWqgRYrjyzjJmOAj1O09xLokbllzKbvlPe4SEmwxkbCqGa49IbpQ4Vh9xLqXNosLWELqqib(iqWkvJsx9wPJsWYsgzq1skboRhJ1LsaheiaEVyWJk(7r38Olo66hD9JU(r1ygPGpo0tIFVsiiKaFeiyLhvKOJktij5x1iiODAypEko5hv83JU5r34OloQmHKKFvJGG2PH94P4KF0NhvSp6ghvKOJYJabJvPht4CrcGMlYMdgYyvoEM5QoXh957r)4WJ(apkjhvKOJktij5HMlYMd0IvgZZmx1j(OIF0po8OpWJsYr3qju8PJujSxjeesGpceSs1O0vpQ0rjyzjJmOAjLaN1JX6sjOXmsbFCOFRFVsiiKaFeiyLhDXrXbbcG3lg8OI)E0ThDXrx)OYess(vnccANg2JNIt(rF(E0npQirhvJzKc(4q)M(9kHGqc8rGGvE0no6IJIdceaVxm4rFE0hE0fhvMqsYdnxKnhWdM5j0ucfF6ivcqZfPCGg1O09bO0rjyzjJmOAjLaN1JX6sjS(r5rGGXQ0JjCUibqZfzZbdzSkhpZCvN4Jk(rF4JhDXrXAgcbMI9zd23onuG7ip6Z3JsYr34OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(Opp6wsucfF6ivcycNlsaPnYKAlHQrPRyR0rjyzjJmOAjLaN1JX6sjWJabJvPht4CrcGMlYMdgYyvoEM5QoXhv8Jk2kHIpDKkb5gzyEqW(mGC4KngwnkD3(OshLGLLmYGQLucCwpgRlLaoiqa8EXGh95r)9OloQmHKKhAUiBoGhmZJNIt(rF(EusucfF6ivc4GabWdRj3uJs3TBv6OeSSKrguTKsGZ6XyDPeWbbcG3lg8OpFp6MhDXrLjKK8qZfzZb8GzEcTJU4ORFuzcjjp0Cr2CapyMhpfN8Jk(7r38OIeDuzcjjp0Cr2CapyMNzUQt8rF(E0po8OpWJ(RxpE0nucfF6ivcqZfPCGg1O0DljkDucwwYidQwsju8PJujaJWPe4KXrgyk2NnyLUBvcU6NaozCKbMI9zdwjOhvcCwpgRlLaZKygEVKrMAu6UDtLokbllzKbvlPek(0rQe4fcbk(0rcqnEucOgpGSCMsqMOrqqbW7fdQg1OeGMurGgLokD3Q0rju8PJujG1mecGco5kbllzKbvlPgLUKO0rjyzjJmOAjLaN1JX6sju6fJ1J5TFQHcCtQb0IXYPlK3YsgzWJU4OtHSC8qZfzZb8iXeoTPJ0BzjJm4rxCunMrk4Jd9B9ycNlsa0Cr2CWqgRYrju8PJuj0onuG7ivJs3nv6OeSSKrguTKsGZ6XyDPe0SXdnxKnhmKXQC8fFAsTJU4ORFuXC0Pqwo(0MDJb0c2uiVLLmYGhvKOJktij5tB2ngqlytH8eAhDJJks0rN2zGjaW2o6ZJU5JkHIpDKkbTy6ivJs3hQ0rjyzjJmOAjLaN1JX6sjOzJhAUiBoyiJv54l(0KAhvKOJoTZataGTD0NVhD7VkHIpDKkbcSb6XCy1O09xLokbllzKbvlPe4SEmwxkbnB8qZfzZbdzSkhFXNMu7OIeD0PDgycaSTJ(89OB)vju8PJujiBmSXiVZp1O0vVv6OeSSKrguTKsGZ6XyDPe0SXdnxKnhmKXQC8fFAsTJks0rN2zGjaW2o6Z3JU9xLqXNosLGmkciqIGrMAu6Qhv6OeSSKrguTKsGZ6XyDPe0SXdnxKnhmKXQC8fFAsTJks0rN2zGjaW2o6Z3JU9xLqXNosLGuZmzueq1O09bO0rjyzjJmOAjLqXNosLaVqiqXNosaQXJsGZ6XyDPek9IX6X82p1qbUj1aAXy50fYZQK8JU4OtHSC8qZfzZb8iXeoTPJ0BzjJm4rxC0PD2rFE0nF8OloQyokpcemwLEmHZfjaAUiBoyiJv54zMR6eReqnEaz5mLaKhjW0aHMLgtnkDfBLokbllzKbvlPe4SEmwxkHsVySEmV9tnuGBsnGwmwoDH8Skj)Olo60o7Opp6VhDXrXbbcG3lg8OIFuso6IJktij5TFQHcCtQb0IXYPlKhgRYJU4OYess(vnccANg2JNIt(rFE0np6IJkMJQXmsbFCOFRFVsiiKaFeiyLhDXrfZr1ygPGpo0tIFVsiiKaFeiyLkHIpDKkH9kHGqc8rGGvQgLUBFuPJsWYsgzq1skboRhJ1LsaheiaEVyWJ(89OBE0fhvMqsYdnxKnhWdM5j0o6IJktij5HMlYMd4bZ84P4KF03J(qLqXNosLa0CrkhOrnkD3UvPJsWYsgzq1skboRhJ1LsO0lgRhZB)udf4MudOfJLtxipRsYp6IJktij5x1iiODAypEko5hv8JsYrxCuzcjjV9tnuGBsnGwmwoDH8mZvDIp6ZJw8PJ0J3lyScihOXB)04eJbM2zhDXrx)OI5OtHSC8qZfzZb8iXeoTPJ0BzjJm4rfj6O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rf)OBj5OBOek(0rQeANgkWDKQrP7wsu6OeSSKrguTKsGZ6XyDPeeZrNMtENFhDXrN2zGjaW2oQ4hDZhp6IJI1mecmf7ZgSVDAOa3rE0NhLeLqXNosLamcNAu6UDtLokbllzKbvlPe4SEmwxkHsVySEmV9tnuGBsnGwmwoDH8Skj)OIF0hp6IJoTZo6ZJU9XJU4OyndHatX(Sb7BNgkWDKh95rj5OloQmHKKhYScINcrUXWEM5QoXhDXrNcz54tB2ngqlytH8wwYidQek(0rQeKBKH5bb7ZaYHt2yy1O0D7dv6OeSSKrguTKsGZ6XyDPew)OYess(vnccANg2JNIt(rFEu9(OIeDuzcjjp0Cr2CGwSYyEcTJUXrfj6OyndHatX(Sb7BNgkWDKh95rjrju8PJujanxKnhGhMLFZUAu6U9xLokbllzKbvlPek(0rQe4fcbk(0rcqnEucCwpgRlLWuilhFAZUXaAbBkK3YsgzWJU4OyndHatX(Sb7BNgkWDKh957rjrjGA8aYYzkH0MDJb0c2ui1O0DRER0rjyzjJmOAjLqXNosLaVqiqXNosaQXJsGZ6XyDPeWAgcbMI9zd23onuG7ipQ4hDRsa14bKLZucTtdf4os1O0DREuPJsWYsgzq1skboRhJ1Lsy9JoTZataGTDuXp6wsE8OIeD0PDgycaSTJ(8O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rx(OB)9OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(Opp62np6gkHIpDKkHpw7IMzajd9rumOAu6U9bO0rjyzjJmOAjLaN1JX6sjWJabJvPht4CrcGMlYMdgYyvoEM5QoXhv8J(WhpQirhLhbcgRspMW5IeanxKnhmKXQC8mZvDIp6ZJULeLqXNosLaMW5IeqAJmP2sOAu6UvSv6OeSSKrguTKsGZ6XyDPew)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFEuX(OloQmHKKhAUiBoGxiuNFEM5QoXhDJJks0rx)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFE0TBp6IJkMJktij5HMlYMd4fc15NNzUQt8r34OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(OIF0Tpuju8PJujWlecazwbXtHi3yy1O0LKhv6Oek(0rQeKBKH5bb7ZaYHt2yyLGLLmYGQLuJsxs2Q0rjyzjJmOAjLaN1JX6sjS(rl9IX6X8YfYKiqGojn410r6TSKrg8OIeD0PqwoEO5IS5aEKycN20r6TSKrg8OBC0fhvJzKc(4q)w)ELqqib(iqWkp6IJYJabJvPht4CrcGMlYMdgYyvoEM5QoXh95rjrju8PJujSxjeesGpceSs1O0Lesu6OeSSKrguTKsGZ6XyDPeWbbcG3lg8Opp6MhDXrx)OI5OtHSC8qZfzZb8iXeoTPJ0BzjJm4rfj6OYess(vnccANg2JNIt(rx(OTtddWA1Q0GaibRZppMW5IeanxKnhmKXQCoQ4VhvVp6IJoTZataANg2xiKNzUQt8rFEuEHhW0o7OBCurIo60odmba22rFEusEuju8PJujGjCUibqZfzZbdzSkh1O0LKnv6OeSSKrguTKsGZ6XyDPeKjKK8RAee0onShpfN8Jk(7rj5OloQmHKKhAUiBoGhmZJNIt(rF(Euso6IJktij5HMlYMd0IvgZdJv5rxCuSMHqGPyF2G9Ttdf4oYJ(8OKOek(0rQe0IvgdGBT9ivJsxsEOshLGLLmYGQLucCwpgRlLWuilhpmcN3YsgzWJU4OmtIz49sgzhDXrN2zGjaW2oQ4hD9JcJXdJW5zMR6eF0Lp6MpE0nucfF6ivcWiCQrPlj)Q0rjyzjJmOAjLaN1JX6sjGdceaVxm4rf)9O)EurIo66hfheiaEVyWJk(7r38OlokpcemwLEEHqaiZkiEke5gd7zMR6eFuXp6dp6IJU(r5rGGXQ0JjCUibqZfzZbdzSkhpZCvN4Jk(rj5XJks0rx)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFE0po8OpWJsYrxC0PqwoEO5IS5aEKycN20r6TSKrg8OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(Opp6hhE0h4rF4rxCuXC0PqwoEO5IS5aEKycN20r6TSKrg8OBC0no6IJU(rfZrNcz54XeoxKasBKj1wc9wwYidEurIokpcemwLEmHZfjG0gzsTLqpZCvN4Jk(r38OBC0nucfF6ivc7vcbHe4JabRunkDjrVv6OeSSKrguTKsGZ6XyDPeWbbcG3lg8Opp6VhDXrLjKK8qZfzZb8GzE8uCYp6Z3JsIsO4thPsaheiaEyn5MAu6sIEuPJsWYsgzq1skboRhJ1LsaheiaEVyWJ(89OBE0fhvMqsYdnxKnhWdM5j0o6IJU(rx)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFEu9(OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(OIFusi5OBCurIoQmHKKhAUiBoGhmZJNIt(rf)9OBEurIoQmHKKhAUiBoGhmZZmx1j(Opp6VhvKOJoTZataGTD0NhLKFp6gkHIpDKkbO5IuoqJAu6sYdqPJsWYsgzq1skHIpDKkbEHqGIpDKauJhLaQXdilNPeKjAeeua8EXGQrnkbnMXdNCnkDu6UvPJsWYsgzq1sQrPljkDucwwYidQwsnkD3uPJsWYsgzq1sQrP7dv6Oek(0rQeWeoxKajd9rumOsWYsgzq1sQrP7VkDucwwYidQwsjWz9ySUuctHSC8DMgdanxKyVLLmYGkHIpDKkHotJbGMlsSAu6Q3kDucwwYidQwsnkD1JkDucfF6ivcAX0rQeSSKrguTKAu6(au6OeSSKrguTKsGZ6XyDPeKjKK8RAee0onShpfN8Jk(r3E0fhvMqsYdnxKnhWdM5HXQuju8PJujOfRmga3A7rQgLUITshLGLLmYGQLucCwpgRlLGCGXhvKOJw8PJ0dnxKYbA88cph99OpQek(0rQeGMls5anQrP72hv6OeSSKrguTKsGZ6XyDPeeZrLdm(OIeD0IpDKEO5IuoqJNx45OIF0hvcfF6ivc49cgRaYbAuJAucPn7gdOfSPqkDu6UvPJsWYsgzq1skHIpDKkbEHqGIpDKauJhLaN1JX6sjWJabJvPpTz3yaTGnfYZmx1j(OppkjpQeqnEaz5mLqAZUXaAbBkeqMOrWo)uJsxsu6OeSSKrguTKsO4thPsGxieO4thja14rjWz9ySUucYess(0MDJb0c2uipHMsa14bKLZucPn7gdOfSPqGIpnPMAuJsiTz3yaTGnfcit0iyNFkDu6UvPJsWYsgzq1skboRhJ1LsaheiaEVyWJk(7r)9Olo66hvmhDkKLJxlwzmaU12J0BzjJm4rfj6OYessEO5IS5aEWmpH2r3qju8PJujK2SBmGwWMcPgLUKO0rju8PJujWlecazwbXtHi3yyLGLLmYGQLuJs3nv6OeSSKrguTKsGZ6XyDPe4rGGXQ0ZlecazwbXtHi3yypZCvN4Jk(r3(ao6IJIdceaVxm4rf)9OBQek(0rQe2ReccjWhbcwPAu6(qLokbllzKbvlPe4SEmwxkbzcjj)QgbbTtd7XtXj)OI)Euso6IJktij5HMlYMd4bZ84P4KF0NVhLKJU4OYessEO5IS5aTyLX8WyvE0fhfheiaEVyWJk(7r3uju8PJujOfRmga3A7rQgLU)Q0rjyzjJmOAjLaN1JX6sjGdceaVxm4rf)9O)Qek(0rQe2ReccjWhbcwPAu6Q3kDucwwYidQwsju8PJujWlecu8PJeGA8OeqnEaz5mLGmrJGGcG3lgunQrjit0iiOa49Ibv6O0DRshLGLLmYGQLucCwpgRlLGyo6uilhp0Cr2CapsmHtB6i9wwYidEurIo60o7OIF0T)EurIoQgZif8XH(T(9kHGqc8rGGvE0fhvmhvMqsYlJIaIiWJNzUQtSsO4thPsaheiaEyn5MAu6sIshLqXNosLaEVGXkGCGgLGLLmYGQLuJAucPn7gdOfSPqGIpnPMshLUBv6Oek(0rQeKBKH5bb7ZaYHt2yyLGLLmYGQLuJsxsu6OeSSKrguTKsGZ6XyDPe4rGGXQ0JjCUibqZfzZbdzSkhpZCvN4J(8OB38OIeDuXCutVMO10mOFvJKygedW9xJaHeatOzSoyamHZfzNFkHIpDKkHpw7IMzajd9rumOAu6UPshLGLLmYGQLucCwpgRlLapcemwLEmHZfjaAUiBoyiJv54zMR6eFuXp6dF8OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(Opp6wsucfF6ivcycNlsaPnYKAlHQrP7dv6OeSSKrguTKsGZ6XyDPew)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFEuX(OloQmHKKhAUiBoGxiuNFEM5QoXhDJJks0rx)O8iqWyv6XeoxKaO5IS5GHmwLJNzUQt8rFE0TBp6IJkMJktij5HMlYMd4fc15NNzUQt8r34OIeDuEeiySk9ycNlsa0Cr2CWqgRYXZmx1j(OIF0Tpuju8PJujWlecazwbXtHi3yy1O09xLokbllzKbvlPek(0rQe4fcbk(0rcqnEucCwpgRlLaoiqa8EXGh99OBp6IJU(r5rGGXQ0ZlecazwbXtHi3yypZCvN4J(8OfF6i949cgRaYbA88cpGPD2rfj6ORF0PqwoE5gzyEqW(mGC4Kng2BzjJm4rxCuEeiySk9YnYW8GG9za5WjBmSNzUQt8rFE0IpDKE8EbJva5anEEHhW0o7OBC0nucOgpGSCMsqMOrqqbW7fdQgLU6TshLGLLmYGQLucCwpgRlLW6hD9JYJabJvPNxieaYScINcrUXWEM5QoXhv8Jw8PJ0dnxKYbA88cpGPD2r34Olo66hLhbcgRspVqiaKzfepfICJH9mZvDIpQ4hT4thPhVxWyfqoqJNx4bmTZo6ghDJJU4OYess(0MDJb0c2uipZCvN4Jk(r5fEat7mLqXNosLWELqqib(iqWkvJsx9OshLGLLmYGQLucCwpgRlLGmHKKpTz3yaTGnfYZmx1j(Opp6VhDXrXbbcG3lg8OVh9rLqXNosLaMW5IeanxKnhmKXQCuJs3hGshLGLLmYGQLucCwpgRlLGmHKKpTz3yaTGnfYZmx1j(OppAXNospMW5IeanxKnhmKXQC88cpGPD2rx(Op6)vju8PJujGjCUibqZfzZbdzSkh1O0vSv6OeSSKrguTKsGZ6XyDPeKjKK8qZfzZb8GzEcTJU4O4GabW7fdE0NVhDtLqXNosLa0CrkhOrnkD3(OshLGLLmYGQLucfF6ivc8cHafF6ibOgpkbuJhqwotjit0iiOa49IbvJAuJsOiM9GPeeANyPAuJsb]] )


end
