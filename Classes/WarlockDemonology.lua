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


    spec:RegisterPack( "Demonology", 20190221.1420, [[dOKqzbqiLqTiLsv9iOuSjLuFIuLWOuk6ukfwLQu0RusmlLKUfukTlQ6xqjdtvQoMsLLPQQNPuY0ukLRrQITPeIVrQs14ukvCoOu16ukvAEQsUNQyFeQoiPkfluj4HqPstuvkCrOurBKuLs9rLsvQtQesALkvntsvkzNKQ6NkLQKHsQsAPqPcpfQMkHYvvkvXxjvjAVK8xunyehwYIjYJrAYOCzkBMO(mHmAvLtl1RHcZg0TPYUf9BHHtkhxjKy5qEoW0vCDc2ou03vIgVQu68QQSELqQ5tQSFvwTtjMcNvJP0))77W(3))FNF32()()frHp)0mfUwrXOezk8SCMc)nmxKbme9tHRv)GrXuIPWbHaIAk8Vz0aBxSWsupFcsEA4Wc0obynDKuujpybAhfljyiHLKCHTmdtS0qHCdnaw6vKHDundGLEf7GRxwiyqXG)gMlYagI(5bTJQWLeA4SOMkjfoRgtP))33H9V)))o)UT9)9)6rHd0mQs))lYIOW)AgZsLKcNzaQchBoYByUidyi63r0llemOyC7XMJ8nJgy7IfwI65tqYtdhwG2jaRPJKIk5blq7OyjbdjSKKlSLzyILgkKBObWsVImSJQzaS0RyhC9Ycbdkg83WCrgWq0ppOD0Bp2Ce92MesOq)oY)DREK)VVd7pc2EKDBB7()9B)ThBoc29Rsrgy7E7XMJGThbxZGWJO3kOy4V9yZrW2JS9aSJijil7tB(mexlqtb9cAhPtWyf7iH8rqMR6Strhb7(ghzANDe5aDe9T5ZqhrVgOPGhPOtJPDeTVcy(Bp2CeS9iBVs4VJGmA4CwYoYByUiLc4CenKHT0WjvZrA5J0ZrAWr6emvohztWxiazhrdfsLe83ratdHh5RqmAbMn83ES5iy7r0RXsdDe8w7lYJuqyS0yhrdzylnCs1CKjoIgkOhPtWu5CK3WCrkfWXF7XMJGThrVHXosOzPHoc(xXILhzHaohjegqZSJeYhrkaGJi3I(gWrM4i1CeOvG5iIS5irAhXfi7iGVcX83ES5iy7reBPvyCeSBKabN20rIf25B1GbOX0osOzPHoYehrYoIlq2rMaAOkNJeYhH1YYgYY5iYTOV5iGPqZra9iuthjWF7XMJGThrmdmhPDAqZz5uth5rc5JGDJei40MosSWo1Rhrsq0r2Kw5rwuDAWa0rEK3SDoJ11yWFV5rk5XqhrSFOkNJ0GJaeCUin2g(Bp2CeS9i6nygn7iI9dv5CKLyfhPDAGJS8ZYJ8gMlYMEeSBKabN20rEKgCKPGwogZF7XMJGThz7byhz7pTZ4tWzTT9pYM2B1m6ySJyjneYXqhXs2ghbvZNHoY8v5r2(tHezJFANXNGZAB7FKnT3Qz0XyhHkGqwohzkKiB0lahHz18TXrM4ifMrZoI9wQbanM2rKeqzNIosiFeur7cEeS7Ba8kCnui3qtHJnh5nmxKbme97i6LfcgumU9yZr(MrdSDXclr98ji5PHdlq7eG10rsrL8GfODuSKGHewsYf2YmmXsdfYn0ayPxrg2r1maw6vSdUEzHGbfd(ByUidyi6Nh0o6ThBoIEBtcjuOFh5)UvpY)33H9hbBpYUTTD))(T)2Jnhb7(vPidSDV9yZrW2JGRzq4r0Bfum83ES5iy7r2Ea2rKeKL9PnFgIRfOPGEbTJ0jySIDKq(iiZvD2POJGDFJJmTZoICGoI(28zOJOxd0uWJu0PX0oI2xbm)ThBoc2EKTxj83rqgnColzh5nmxKsbCoIgYWwA4KQ5iT8r65in4iDcMkNJSj4leGSJOHcPsc(7iGPHWJ8vigTaZg(Bp2CeS9i61yPHocER9f5rkimwASJOHmSLgoPAoYehrdf0J0jyQCoYByUiLc44V9yZrW2JO3Wyhj0S0qhb)RyXYJSqaNJecdOz2rc5JifaWrKBrFd4itCKAoc0kWCer2CKiTJ4cKDeWxHy(Bp2CeS9iIT0kmoc2nsGGtB6iXc78TAWa0yAhj0S0qhzIJizhXfi7itanuLZrc5JWAzzdz5Ce5w03CeWuO5iGEeQPJe4V9yZrW2JiMbMJ0onO5SCQPJ8iH8rWUrceCAthjwyN61Jiji6iBsR8ilQonya6ipYB2oNX6Am4V38iL8yOJi2puLZrAWracoxKgBd)ThBoc2Ee9gmJMDeX(HQCoYsSIJ0onWrw(z5rEdZfztpc2nsGGtB6ipsdoYuqlhJ5V9yZrW2JS9aSJS9N2z8j4S22(hzt7TAgDm2rSKgc5yOJyjBJJGQ5Zqhz(Q8iB)PqISXpTZ4tWzTT9pYM2B1m6ySJqfqilNJmfsKn6fGJWSA(24itCKcZOzhXEl1aGgt7iscOStrhjKpcQODbpc29na(B)T)2Jnhb78Tgvym2rKm5azhHgoPAoIKjQtG)i6nuQPnGJKrITFfYjlapsrNosWrIe(ZF7l60rc8AiJgoPAEKHfaJBFrNosGxdz0WjvZkpyjhb72x0PJe41qgnCs1SYdwLGiNLtnDK3(IoDKaVgYOHtQMvEWci4CrY1S52x0PJe41qgnCs1SYdwywOUKG2Qz5SN5hQYH3onWQywqb7zkOLJNzUiBkNgjqWPnDKElljOXwVLoDVF7l60rc8AiJgoPAw5bRotdXzMlsWQT8ZuqlhFNPH4mZfjWBzjbn2TVOthjWRHmA4KQzLhS0ILgIdATVixTLFwSuaaRLeKL9lBiJ3onGhmffdX3D7l60rc8AiJgoPAw5blqwAGVy4GPgWTVOthjWRHmA4KQzLhS0IPJ82x0PJe41qgnCs1SYdwmZfPuaNvB5hPaa0PROthPNzUiLc44Pfy4t7SN3V9fD6ibEnKrdNunR8Gf4RyXsUuaNvB5NflfaGoDfD6i9mZfPuahpTadFANj(73(Bp2CeSZ3AuHXyhXW0q)oY0o7iZNDKIob6in4ifMvdljO5V9fD6ibpTtdgGoYvB5NArBOEmV9wnyaAmnUwmwoDb9wwsqJTEkOLJNzUiBkNgjqWPnDKElljOXwRHmm5IOm)opqW5IKZmxKnLp)qvo3(IoDKGvEWcOzqihgumU9fD6ibR8GLwmDKR2YpA24zMlYMYNFOkhFrNgtB9MlEkOLJpT5ZqCTanf0BzjbnMoDscYY(0MpdX1c0uqVG2g60nTZ4tWzT9AR3V9fD6ibR8GLaW49yoWQT8JMnEM5ISP85hQYXx0PX00PBANXNGZA71Zo9C7l60rcw5bljdbmegDkA1w(rZgpZCr2u(8dv54l60yA60nTZ4tWzT96zNEU9fD6ibR8GLemcgxwa9B1w(rZgpZCr2u(8dv54l60yA60nTZ4tWzT96zNEU9fD6ibR8GLCJmjyeSvB5hnB8mZfzt5ZpuLJVOtJPPt30oJpbN12RND652x0PJeSYdw0cc5fD6i5WgmRMLZEy0i5Mgp0S0qR2Yp1I2q9yE7TAWa0yACTySC6c6rvIX6PGwoEM5ISPCAKabN20r6TSKGgB90o71wVVEX0iGSyz6bcoxKCM5ISP85hQYXJmx1j42x0PJeSYdwFvY4HmxKaKv5QT8tTOnupM3ERgmanMgxlglNUGEuLySEAN9spRbHaKd(ket8)RLeKL92B1GbOX04AXy50f0ZIL5Ajbzz)YgY4Ttd4btrX41wRxSgYWKlIY878FvY4HmxKaKv56fRHmm5IOm)F)xLmEiZfjazvE7l60rcw5blM5IukGZQT8dieGCWxHyVE2ATKGSSNzUiBkNgiZlOTwsqw2ZmxKnLtdK5btrX4zB3(IoDKGvEWQDAWa0rUAl)ulAd1J5T3QbdqJPX1IXYPlOhvjgRLeKL9lBiJ3onGhmffdX)Vwsqw2BVvdgGgtJRfJLtxqpYCvNGxfD6i9GVIfl5sbC82BnQWy8PD26nx8uqlhpZCr2uonsGGtB6i9wwsqJPthncilwMEGGZfjNzUiBkF(HQC8iZvDceF3)nU9fD6ibR8Gflc3QT8ZINMIrNIwpTZ4tWzTj(wVVgOzqiFkKiBa(2Pbdqh5R)3(IoDKGvEWsQHgGgcirgxkCsgcSAl)ulAd1J5T3QbdqJPX1IXYPlOhvjgI)(6PD2RDVVgOzqiFkKiBa(2Pbdqh5R)RLeKL9mKvmWuqmmeWJmx1jy9uqlhFAZNH4AbAkO3YscASBFrNosWkpyXmxKnLdgKLIMVvB5NnLeKL9lBiJ3onGhmffJxlIoDscYYEM5ISPCTyPH8cABOthqZGq(uir2a8TtdgGoYx)V9fD6ibR8GfTGqErNosoSbZQz5SN0MpdX1c0uWvB5NPGwo(0MpdX1c0uqVLLe0yRbAgeYNcjYgGVDAWa0r(65)TVOthjyLhSOfeYl60rYHnywnlN90onya6ixTLFaAgeYNcjYgGVDAWa0rk(UBFrNosWkpyjc1UOrgx2GIekeB1w(HgbKfltpqW5IKZmxKnLp)qvoEK5QobV2T1TVOthjyLhSacoxKCmBOj3wYwTLFOrazXY0deCUi5mZfzt5ZpuLJhzUQtG4B7DD6OrazXY0deCUi5mZfzt5ZpuLJhzUQtWRD)V9fD6ibR8GfTGqodzfdmfeddbwTLF2KgbKfltpqW5IKZmxKnLp)qvoEK5QobVW(1scYYEM5ISPCAbHDkYJmx1jydD62KgbKfltpqW5IKZmxKnLp)qvoEK5QobV2TB9ILeKL9mZfzt50cc7uKhzUQtWg60rJaYILPhi4CrYzMlYMYNFOkhpYCvNaX3TTBFrNosWkpyj1qdqdbKiJlfojdbU9fD6ibR8GfqW5IKZmxKnLp)qvoR2YpGqaYbFfI9AR1scYY(LnKXBNgWdMIIH4ywOUKGMF(HQC4TtdC7l60rcw5blTyPH4Gw7lYvB5hjbzz)YgY4Ttd4btrXq8N)RLeKL9mZfzt50azEWuumE98FTKGSSNzUiBkxlwAiplwMRbAgeYNcjYgGVDAWa0r(6)TVOthjyLhSyr4wTLFMcA54zr48wwsqJTgzYid8vsqB90oJpbN1M4BYIXZIW5rMR6eSYwVVXTVOthjyLhS(QKXdzUibiRYvB5hqia5GVcXe)rp60TjieGCWxHyI)S1AAeqwSm90cc5mKvmWuqmmeWJmx1jq8TTEtAeqwSm9abNlsoZCr2u(8dv54rMR6ei()31PBtAeqwSm9abNlsoZCr2u(8dv54rMR6e8seL9M)xpf0YXZmxKnLtJei40MosVLLe0y60rJaYILPhi4CrYzMlYMYNFOkhpYCvNGxIOS3CBRx8uqlhpZCr2uonsGGtB6i9wwsqJTXgR3CXtbTC8abNlsoMn0KBlzElljOX0PJgbKfltpqW5IKJzdn52sMhzUQtG4BTXg3(IoDKGvEWcecqoyqng2QT8dieGCWxHyV0ZAjbzzpZCr2uonqMhmffJxp)V9fD6ibR8GfZCrkfWz1w(becqo4RqSxpBTwsqw2ZmxKnLtdK5f0wV5M0iGSyz6bcoxKCM5ISP85hQYXJmx1j41IOthncilwMEGGZfjNzUiBkF(HQC8iZvDce)))n0Ptsqw2ZmxKnLtdK5btrXq8NT0Ptsqw2ZmxKnLtdK5rMR6e8sp60nTZ4tWzT96VE242x0PJeSYdw0cc5fD6i5WgmRMLZEKeAiJxCWxHy3(BFrNosGxsOHmEXbFfI9acbihmOgd72x0PJe4LeAiJxCWxHyR8Gf4RyXsUuaNB)TVOthjWZOrYnnEOzPHE(QKXdzUibiRYvB5hqia5GVcXe))QWonoL9S173(IoDKapJgj304HMLgALhSANgmaDKR2YpscYY(LnKXBNgWdMIIH4)xljil7T3QbdqJPX1IXYPlONflZBFrNosGNrJKBA8qZsdTYdwSiCRc704u2ZwVF7l60rc8mAKCtJhAwAOvEWIzUiBkhmilfnF3(IoDKapJgj304HMLgALhSKAObOHasKXLcNKHa3(IoDKapJgj304HMLgALhSacoxKCmBOj3wYU9fD6ibEgnsUPXdnln0kpyjc1UOrgx2GIeke72x0PJe4z0i5Mgp0S0qR8G1xLmEiZfjazvUAl)acbih8vi2JE0Pdecqo4RqSNTTwsqw2ZmxKnLtliStrEK5Qob3(IoDKapJgj304HMLgALhSOfeYziRyGPGyyiWQT8JgYWKlIY878FvY4HmxKaKvPoDBQHmm5IOm)F)xLmEiZfjazvUwdzyYfrz(D(2Pbdqh5g3(IoDKapJgj304HMLgALhSacoxKCM5ISP85hQYz1w(rdzyYfrz(DEAbHCgYkgykiggcOthncilwMEAbHCgYkgykiggc4rMR6ei(73(IoDKapJgj304HMLgALhSaHaKdguJHTAl)SjieGCWxHyV2sNoqia5GVcXE22AjbzzpZCr2uonqMhmffJxpBTHoDscYYEM5ISPCAGmplwMRbHaKd(ke7LEU9fD6ibEgnsUPXdnln0kpyXmxKsbCwTLFaHaKd(ke71ZwRLeKL9mZfzt50azEK5Qob3(IoDKapJgj304HMLgALhSOfeYl60rYHnywnlN9ij0qgV4GVcXU93(IoDKaF70GbOJ8PDAWa0rUAl)SPKGSSFzdz82Pb8GPOyi(ZISEtqia5GVcXETLoDAidtUikZVZtliKZqwXatbXWqaD6KeKL9lBiJ3onGhmffdXFWED60qgMCruMFNxQHgGgcirgxkCsgcOt3MlwdzyYfrz(D(Vkz8qMlsaYQC9I1qgMCruM)V)RsgpK5IeGSk3yJ1lwdzyYfrz(D(Vkz8qMlsaYQC9I1qgMCruM)V)RsgpK5IeGSkxljil7zMlYMY1ILgYZIL5g60T50oJpbN12RTwljil7x2qgVDAapykkgI)(g60TPgYWKlIY8)90cc5mKvmWuqmmeyTKGSSFzdz82Pb8GPOyi()1lEkOLJNzUiBkNwqyNI8wwsqJTXTVOthjW3onya6ix5blrO2fnY4YguKqHyR2Yp0iGSyz6bcoxKCM5ISP85hQYXJmx1j41UT0PBX2IIqRPzm)UT(V1IG93(IoDKaF70GbOJCLhSOfeYziRyGPGyyiWQT8ZM0iGSyz6bcoxKCM5ISP85hQYXJmx1j4f2Vwsqw2ZmxKnLtliStrEK5QobBOt3M0iGSyz6bcoxKCM5ISP85hQYXJmx1j41UDRxSKGSSNzUiBkNwqyNI8iZvDc2qNoAeqwSm9abNlsoZCr2u(8dv54rMR6ei(UTD7l60rc8TtdgGoYvEWci4CrYzMlYMYNFOkNvB5hjbzz)YgY4Ttd4btrXqCmluxsqZp)qvo82PbU9fD6ib(2Pbdqh5kpy9vjJhYCrcqwLR2YpGqaYbFfIj(JEU9fD6ib(2Pbdqh5kpy9vjJhYCrcqwLR2YpGqaYbFfIj(ZwR3CZn1qgMCruM)V)RsgpK5IeGSk1Ptsqw2VSHmE70aEWuume)zRnwljil7x2qgVDAapykkgVW(n0PJgbKfltpqW5IKZmxKnLp)qvoEK5QobVEerzV5FD6KeKL9mZfzt5AXsd5rMR6eiUik7n)VXTVOthjW3onya6ix5blM5IukGZQT8JgYWKlIY878FvY4HmxKaKv5Aqia5GVcXe)z36nLeKL9lBiJ3onGhmffJxpBPtNgYWKlIY8B5)QKXdzUibiRYnwdcbih8vi2RTTwsqw2ZmxKnLtdK5f0U9fD6ib(2Pbdqh5kpybeCUi5y2qtUTKTAl)SjncilwMEGGZfjNzUiBkF(HQC8iZvDceFBVVgOzqiFkKiBa(2Pbdqh5RN)BOthncilwMEGGZfjNzUiBkF(HQC8iZvDcET7)TVOthjW3onya6ix5blPgAaAiGezCPWjziWQT8dncilwMEGGZfjNzUiBkF(HQC8iZvDceh7V9fD6ib(2Pbdqh5kpybcbihmOgdB1w(becqo4RqSx6zTKGSSNzUiBkNgiZdMIIXRN)3(IoDKaF70GbOJCLhSyMlsPaoR2YpGqaYbFfI96zR1scYYEM5ISPCAGmVG26nLeKL9mZfzt50azEWuume)zlD6KeKL9mZfzt50azEK5QobVEerzVPE869nU9fD6ib(2Pbdqh5kpyXIWTk9hfA8PqISb8SBvx9wo9hfA8PqISb8O3xTLFqMmYaFLe0U9fD6ib(2Pbdqh5kpyrliKx0PJKdBWSAwo7rsOHmEXbFfID7V9fD6ib(0MpdX1c0uWhAbH8IoDKCydMvZYzpPnFgIRfOPGCjHgY6u0QT8dncilwM(0MpdX1c0uqpYCvNGx)F)2x0PJe4tB(mexlqtbx5blAbH8IoDKCydMvZYzpPnFgIRfOPG8IonM2QT8JKGSSpT5ZqCTanf0lOD7V9fD6ib(0MpdX1c0uqErNgt7rQHgGgcirgxkCsgcC7l60rc8PnFgIRfOPG8IonM2kpyjc1UOrgx2GIekeB1w(HgbKfltpqW5IKZmxKnLp)qvoEK5QobV2TLoDl2wueAnnJ53T1)TweS)2x0PJe4tB(mexlqtb5fDAmTvEWci4CrYXSHMCBjB1w(HgbKfltpqW5IKZmxKnLp)qvoEK5QobIVT31PJgbKfltpqW5IKZmxKnLp)qvoEK5QobV29)2x0PJe4tB(mexlqtb5fDAmTvEWIwqiNHSIbMcIHHaR2YpBsJaYILPhi4CrYzMlYMYNFOkhpYCvNGxy)AjbzzpZCr2uoTGWof5rMR6eSHoDBsJaYILPhi4CrYzMlYMYNFOkhpYCvNGx72TEXscYYEM5ISPCAbHDkYJmx1jydD6OrazXY0deCUi5mZfzt5ZpuLJhzUQtG4722TVOthjWN28ziUwGMcYl60yAR8GfTGqErNosoSbZQz5ShjHgY4fh8vi2QT8dieGCWxHyp7wVjncilwMEAbHCgYkgykiggc4rMR6e8QOthPh8vSyjxkGJNwGHpTZ0PBZPGwoEPgAaAiGezCPWjziG3YscAS10iGSyz6LAObOHasKXLcNKHaEK5QobVk60r6bFflwYLc44Pfy4t7Sn242x0PJe4tB(mexlqtb5fDAmTvEW6RsgpK5IeGSkxTLF2CtAeqwSm90cc5mKvmWuqmmeWJmx1jq8IoDKEM5IukGJNwGHpTZ2y9M0iGSyz6PfeYziRyGPGyyiGhzUQtG4fD6i9GVIfl5sbC80cm8PD2gBSMgbKfltFAZNH4AbAkOhzUQtG4BUBr0ZkfD6i9FvY4HmxKaKvPNwGHpTZ242x0PJe4tB(mexlqtb5fDAmTvEWci4CrYzMlYMYNFOkNvB5hjbzzFAZNH4AbAkOhzUQtWl9Sgecqo4RqSN3V9fD6ib(0MpdX1c0uqErNgtBLhSacoxKCM5ISP85hQYz1w(rsqw2N28ziUwGMc6rMR6e8QOthPhi4CrYzMlYMYNFOkhpTadFANTY7E9C7l60rc8PnFgIRfOPG8IonM2kpyXmxKsbCwTLFKeKL9mZfzt50azEbT1GqaYbFfI96zRBFrNosGpT5ZqCTanfKx0PX0w5blAbH8IoDKCydMvZYzpscnKXlo4RqSB)TVOthjWN28ziUwGMcYLeAiRtrpPnFgIRfOPGR2YpGqaYbFfIj(JEwV5INcA541ILgIdATVi9wwsqJPtNKGSSNzUiBkNgiZlOTXTVOthjWN28ziUwGMcYLeAiRtrR8GfTGqodzfdmfeddbU9fD6ib(0MpdX1c0uqUKqdzDkALhS(QKXdzUibiRYvB5hAeqwSm90cc5mKvmWuqmmeWJmx1jq8DBN1GqaYbFfIj(Zw3(IoDKaFAZNH4AbAkixsOHSofTYdwAXsdXbT2xKR2YpscYY(LnKXBNgWdMIIH4p)xljil7zMlYMYPbY8GPOy865)AjbzzpZCr2uUwS0qEwSmxdcbih8viM4pBD7l60rc8PnFgIRfOPGCjHgY6u0kpy9vjJhYCrcqwLR2YpGqaYbFfIj(JEU9fD6ib(0MpdX1c0uqUKqdzDkALhSOfeYl60rYHnywnlN9ij0qgV4GVcXu4yAiqhPs))VVd7F)))D(DB7D9OWxwOStrafUEPEd2H(lQ6V9E7EKJi2NDK2PfO5iYb6i6fAiJgoPA0locYwueAKXociC2rkHjC1ySJq)QuKb83E9wDAhzr2Uhz7jbcAAbAm2rk60rEe9IotdXzMlsGEH)2F7xuDAbAm2r2ohPOth5rGnya(BVcVeMVaPWXBh2vHdBWauIPWz0i5Mgp0S0qkXu6VtjMc3YscAm1ckCkQhd1Lchecqo4RqSJi(r(RWl60rQW)QKXdzUibiRsfoStJtzk8TExnk9)RetHBzjbnMAbfof1JH6sHljil7x2qgVDAapykkghr8J8)iRpIKGSS3ERgmanMgxlglNUGEwSmv4fD6iv4TtdgGos1O0FlLykClljOXulOWl60rQWzr4u4WonoLPW36D1O0FBkXu4fD6iv4mZfzt5GbzPO5tHBzjbnMAb1O0xpkXu4fD6iv4sn0a0qajY4sHtYqafULLe0yQfuJs)frjMcVOthPchi4CrYXSHMCBjtHBzjbnMAb1O0xVRetHx0PJuHlc1UOrgx2GIeketHBzjbnMAb1O0F7OetHBzjbnMAbfof1JH6sHdcbih8vi2rEoIEoIoDhbecqo4RqSJ8CKTDK1hrsqw2ZmxKnLtliStrEK5Qobk8IoDKk8Vkz8qMlsaYQunk9XELykClljOXulOWPOEmuxkCnKHjxeL535)QKXdzUibiRYJOt3r28iAidtUikZ)3)vjJhYCrcqwLhz9r0qgMCruMFNVDAWa0rEKnu4fD6iv40cc5mKvmWuqmmeqnk939UsmfULLe0yQfu4uupgQlfUgYWKlIY8780cc5mKvmWuqmme4i60DeAeqwSm90cc5mKvmWuqmmeWJmx1j4iIFK3v4fD6iv4abNlsoZCr2u(8dv5OgL(72PetHBzjbnMAbfof1JH6sHV5raHaKd(ke7iVoYwhrNUJacbih8vi2rEoY2oY6Jijil7zMlYMYPbY8GPOyCKxphzRJSXr0P7iscYYEM5ISPCAGmplwMhz9raHaKd(ke7iVoIEu4fD6iv4GqaYbdQXWuJs)D)vIPWTSKGgtTGcNI6XqDPWbHaKd(ke7iVEoYwhz9rKeKL9mZfzt50azEK5Qobk8IoDKkCM5IukGJAu6VBlLykClljOXulOWl60rQWPfeYl60rYHnyu4Wgm8SCMcxsOHmEXbFfIPg1OWtB(mexlqtb5fDAmnLyk93PetHx0PJuHl1qdqdbKiJlfojdbu4wwsqJPwqnk9)RetHBzjbnMAbfof1JH6sHtJaYILPhi4CrYzMlYMYNFOkhpYCvNGJ86i726i60DKfFeBrrO10mMFzdLrgdWbTOgYdzoqqZqDG4abNlYofPWl60rQWfHAx0iJlBqrcfIPgL(BPetHBzjbnMAbfof1JH6sHtJaYILPhi4CrYzMlYMYNFOkhpYCvNGJi(r227hrNUJqJaYILPhi4CrYzMlYMYNFOkhpYCvNGJ86i7(RWl60rQWbcoxKCmBOj3wYuJs)TPetHBzjbnMAbfof1JH6sHV5rOrazXY0deCUi5mZfzt5ZpuLJhzUQtWrEDeS)iRpIKGSSNzUiBkNwqyNI8iZvDcoYghrNUJS5rOrazXY0deCUi5mZfzt5ZpuLJhzUQtWrEDKD7oY6JS4Jijil7zMlYMYPfe2PipYCvNGJSXr0P7i0iGSyz6bcoxKCM5ISP85hQYXJmx1j4iIFKDBtHx0PJuHtliKZqwXatbXWqa1O0xpkXu4wwsqJPwqHtr9yOUu4GqaYbFfIDKNJS7iRpYMhHgbKfltpTGqodzfdmfeddb8iZvDcoYRJu0PJ0d(kwSKlfWXtlWWN2zhrNUJS5rMcA54LAObOHasKXLcNKHaElljOXoY6JqJaYILPxQHgGgcirgxkCsgc4rMR6eCKxhPOthPh8vSyjxkGJNwGHpTZoYghzdfErNosfoTGqErNosoSbJch2GHNLZu4scnKXlo4Rqm1O0FruIPWTSKGgtTGcNI6XqDPW38iBEeAeqwSm90cc5mKvmWuqmmeWJmx1j4iIFKIoDKEM5IukGJNwGHpTZoYghz9r28i0iGSyz6PfeYziRyGPGyyiGhzUQtWre)ifD6i9GVIfl5sbC80cm8PD2r24iBCK1hHgbKfltFAZNH4AbAkOhzUQtWre)iBEKDlIEoYkhPOthP)RsgpK5IeGSk90cm8PD2r2qHx0PJuH)vjJhYCrcqwLQrPVExjMc3YscAm1ckCkQhd1Lcxsqw2N28ziUwGMc6rMR6eCKxhrphz9raHaKd(ke7iph5DfErNosfoqW5IKZmxKnLp)qvoQrP)2rjMc3YscAm1ckCkQhd1Lcxsqw2N28ziUwGMc6rMR6eCKxhPOthPhi4CrYzMlYMYNFOkhpTadFANDKvoY7E9OWl60rQWbcoxKCM5ISP85hQYrnk9XELykClljOXulOWPOEmuxkCjbzzpZCr2uonqMxq7iRpcieGCWxHyh51Zr2sHx0PJuHZmxKsbCuJs)DVRetHBzjbnMAbfErNosfoTGqErNosoSbJch2GHNLZu4scnKXlo4Rqm1OgfoZKlb4OetP)oLykClljOXulOWPOEmuxk8ArBOEmV9wnyaAmnUwmwoDb9wwsqJDK1hzkOLJNzUiBkNgjqWPnDKElljOXoY6JOHmm5IOm)opqW5IKZmxKnLp)qvok8IoDKk82PbdqhPAu6)xjMcVOthPchOzqihgumu4wwsqJPwqnk93sjMc3YscAm1ckCkQhd1LcxZgpZCr2u(8dv54l60yAhz9r28il(itbTC8PnFgIRfOPGElljOXoIoDhrsqw2N28ziUwGMc6f0oYghrNUJmTZ4tWzTDKxhzR3v4fD6iv4AX0rQgL(BtjMc3YscAm1ckCkQhd1LcxZgpZCr2u(8dv54l60yAhrNUJmTZ4tWzTDKxphzNEu4fD6iv4caJ3J5aQrPVEuIPWTSKGgtTGcNI6XqDPW1SXZmxKnLp)qvo(IonM2r0P7it7m(eCwBh51Zr2PhfErNosfUKHagcJofPgL(lIsmfULLe0yQfu4uupgQlfUMnEM5ISP85hQYXx0PX0oIoDhzANXNGZA7iVEoYo9OWl60rQWLGrW4YcOFQrPVExjMc3YscAm1ckCkQhd1LcxZgpZCr2u(8dv54l60yAhrNUJmTZ4tWzTDKxphzNEu4fD6iv4YnYKGrWuJs)TJsmfULLe0yQfu4uupgQlfETOnupM3ERgmanMgxlglNUGEuLyCK1hzkOLJNzUiBkNgjqWPnDKElljOXoY6JmTZoYRJS17hz9rw8rOrazXY0deCUi5mZfzt5ZpuLJhzUQtGcVOthPcNwqiVOthjh2GrHdBWWZYzkCgnsUPXdnlnKAu6J9kXu4wwsqJPwqHtr9yOUu41I2q9yE7TAWa0yACTySC6c6rvIXrwFKPD2rEDe9CK1hbecqo4RqSJi(r(FK1hrsqw2BVvdgGgtJRfJLtxqplwMhz9rKeKL9lBiJ3onGhmffJJ86iBDK1hzXhrdzyYfrz(D(Vkz8qMlsaYQ8iRpYIpIgYWKlIY8)9FvY4HmxKaKvPcVOthPc)RsgpK5IeGSkvJs)DVRetHBzjbnMAbfof1JH6sHdcbih8vi2rE9CKToY6Jijil7zMlYMYPbY8cAhz9rKeKL9mZfzt50azEWuumoYZr2McVOthPcNzUiLc4OgL(72PetHBzjbnMAbfof1JH6sHxlAd1J5T3QbdqJPX1IXYPlOhvjghz9rKeKL9lBiJ3onGhmffJJi(r(FK1hrsqw2BVvdgGgtJRfJLtxqpYCvNGJ86ifD6i9GVIfl5sbC82BnQWy8PD2rwFKnpYIpYuqlhpZCr2uonsGGtB6i9wwsqJDeD6ocncilwMEGGZfjNzUiBkF(HQC8iZvDcoI4hz3)JSHcVOthPcVDAWa0rQgL(7(RetHBzjbnMAbfof1JH6sHV4JmnfJofDK1hzANXNGZA7iIFKTE)iRpcqZGq(uir2a8TtdgGoYJ86i)v4fD6iv4SiCQrP)UTuIPWTSKGgtTGcNI6XqDPWRfTH6X82B1GbOX04AXy50f0JQeJJi(rE)iRpY0o7iVoYU3pY6Ja0miKpfsKnaF70GbOJ8iVoY)JS(iscYYEgYkgykiggc4rMR6eCK1hzkOLJpT5ZqCTanf0BzjbnMcVOthPcxQHgGgcirgxkCsgcOgL(72MsmfULLe0yQfu4uupgQlf(Mhrsqw2VSHmE70aEWuumoYRJSihrNUJijil7zMlYMY1ILgYlODKnoIoDhbOzqiFkKiBa(2Pbdqh5rEDK)k8IoDKkCM5ISPCWGSu08PgL(70JsmfULLe0yQfu4uupgQlf(uqlhFAZNH4AbAkO3YscASJS(iandc5tHezdW3onya6ipYRNJ8xHx0PJuHtliKx0PJKdBWOWHny4z5mfEAZNH4AbAkOAu6VBruIPWTSKGgtTGcNI6XqDPWbAgeYNcjYgGVDAWa0rEeXpYofErNosfoTGqErNosoSbJch2GHNLZu4TtdgGos1O0FNExjMc3YscAm1ckCkQhd1LcNgbKfltpqW5IKZmxKnLp)qvoEK5Qobh51r2TLcVOthPcxeQDrJmUSbfjuiMAu6VB7OetHBzjbnMAbfof1JH6sHtJaYILPhi4CrYzMlYMYNFOkhpYCvNGJi(r227hrNUJqJaYILPhi4CrYzMlYMYNFOkhpYCvNGJ86i7(RWl60rQWbcoxKCmBOj3wYuJs)DyVsmfULLe0yQfu4uupgQlf(MhHgbKfltpqW5IKZmxKnLp)qvoEK5Qobh51rW(JS(iscYYEM5ISPCAbHDkYJmx1j4iBCeD6oYMhHgbKfltpqW5IKZmxKnLp)qvoEK5Qobh51r2T7iRpYIpIKGSSNzUiBkNwqyNI8iZvDcoYghrNUJqJaYILPhi4CrYzMlYMYNFOkhpYCvNGJi(r2TnfErNosfoTGqodzfdmfeddbuJs))VRetHx0PJuHl1qdqdbKiJlfojdbu4wwsqJPwqnk9)VtjMc3YscAm1ckCkQhd1Lchecqo4RqSJ86iBDK1hrsqw2VSHmE70aEWuumoI4hbZc1Le08ZpuLdVDAafErNosfoqW5IKZmxKnLp)qvoQrP)))kXu4wwsqJPwqHtr9yOUu4scYY(LnKXBNgWdMIIXre)5i)pY6Jijil7zMlYMYPbY8GPOyCKxph5)rwFejbzzpZCr2uUwS0qEwSmpY6Ja0miKpfsKnaF70GbOJ8iVoYFfErNosfUwS0qCqR9fPAu6)FlLykClljOXulOWPOEmuxk8PGwoEweoVLLe0yhz9rqMmYaFLe0oY6JmTZ4tWzTDeXpYMhHfJNfHZJmx1j4iRCKTE)iBOWl60rQWzr4uJs))BtjMc3YscAm1ckCkQhd1Lchecqo4RqSJi(Zr0Zr0P7iBEeqia5GVcXoI4phzRJS(i0iGSyz6PfeYziRyGPGyyiGhzUQtWre)iB7iRpYMhHgbKfltpqW5IKZmxKnLp)qvoEK5Qobhr8J8)9JOt3r28i0iGSyz6bcoxKCM5ISP85hQYXJmx1j4iVoIik7iV5r(FK1hzkOLJNzUiBkNgjqWPnDKElljOXoIoDhHgbKfltpqW5IKZmxKnLp)qvoEK5Qobh51rerzh5npY2oY6JS4Jmf0YXZmxKnLtJei40MosVLLe0yhzJJSXrwFKnpYIpYuqlhpqW5IKJzdn52sM3YscASJOt3rOrazXY0deCUi5y2qtUTK5rMR6eCeXpYwhzJJSHcVOthPc)RsgpK5IeGSkvJs))6rjMc3YscAm1ckCkQhd1Lchecqo4RqSJ86i65iRpIKGSSNzUiBkNgiZdMIIXrE9CK)k8IoDKkCqia5Gb1yyQrP))frjMc3YscAm1ckCkQhd1Lchecqo4RqSJ865iBDK1hrsqw2ZmxKnLtdK5f0oY6JS5r28i0iGSyz6bcoxKCM5ISP85hQYXJmx1j4iVoYICeD6ocncilwMEGGZfjNzUiBkF(HQC8iZvDcoI4h5))JSXr0P7iscYYEM5ISPCAGmpykkghr8NJS1r0P7iscYYEM5ISPCAGmpYCvNGJ86i65i60DKPDgFcoRTJ86i)1Zr2qHx0PJuHZmxKsbCuJs))6DLykClljOXulOWl60rQWPfeYl60rYHnyu4Wgm8SCMcxsOHmEXbFfIPg1OW1qgnCs1OetP)oLykClljOXulOgL()vIPWTSKGgtTGAu6VLsmfULLe0yQfuJs)TPetHx0PJuHdeCUi5YguKqHykClljOXulOgL(6rjMc3YscAm1ckCmlOGPWNcA54zMlYMYPrceCAthP3YscASJS(iBDeD6oY7k8IoDKkCmluxsqtHJzH4z5mf(8dv5WBNgqnk9xeLykClljOXulOWPOEmuxk8PGwo(otdXzMlsG3YscAmfErNosfENPH4mZfjqnk917kXu4wwsqJPwqHtr9yOUu4l(isbaCK1hrsqw2VSHmE70aEWuumoI4hzNcVOthPcxlwAioO1(Iunk93okXu4wwsqJPwqnk9XELyk8IoDKkCTy6iv4wwsqJPwqnk939UsmfULLe0yQfu4uupgQlfUuaahrNUJu0PJ0ZmxKsbC80cm8PD2rEoY7k8IoDKkCM5IukGJAu6VBNsmfULLe0yQfu4uupgQlf(IpIuaahrNUJu0PJ0ZmxKsbC80cm8PD2re)iVRWl60rQWbFflwYLc4Og1OWBNgmaDKkXu6VtjMc3YscAm1ckCkQhd1LcFZJijil7x2qgVDAapykkghr8NJSihz9r28iGqaYbFfIDKxhzRJOt3r0qgMCruMFNNwqiNHSIbMcIHHahrNUJijil7x2qgVDAapykkghr8NJG9hrNUJOHmm5IOm)oVudnaneqImUu4Kme4i60DKnpYIpIgYWKlIY878FvY4HmxKaKv5rwFKfFenKHjxeL5)7)QKXdzUibiRYJSXr24iRpYIpIgYWKlIY878FvY4HmxKaKv5rwFKfFenKHjxeL5)7)QKXdzUibiRYJS(iscYYEM5ISPCTyPH8SyzEKnoIoDhzZJmTZ4tWzTDKxhzRJS(iscYY(LnKXBNgWdMIIXre)iVFKnoIoDhzZJOHmm5IOm)FpTGqodzfdmfeddboY6Jijil7x2qgVDAapykkghr8J8)iRpYIpYuqlhpZCr2uoTGWof5TSKGg7iBOWl60rQWBNgmaDKQrP)FLykClljOXulOWPOEmuxkCAeqwSm9abNlsoZCr2u(8dv54rMR6eCKxhz3whrNUJS4JylkcTMMX8lBOmYyaoOf1qEiZbcAgQdehi4Cr2PifErNosfUiu7IgzCzdksOqm1O0FlLykClljOXulOWPOEmuxk8npcncilwMEGGZfjNzUiBkF(HQC8iZvDcoYRJG9hz9rKeKL9mZfzt50cc7uKhzUQtWr24i60DKnpcncilwMEGGZfjNzUiBkF(HQC8iZvDcoYRJSB3rwFKfFejbzzpZCr2uoTGWof5rMR6eCKnoIoDhHgbKfltpqW5IKZmxKnLp)qvoEK5Qobhr8JSBBk8IoDKkCAbHCgYkgykiggcOgL(BtjMc3YscAm1ckCkQhd1Lcxsqw2VSHmE70aEWuumoI4hbZc1Le08ZpuLdVDAafErNosfoqW5IKZmxKnLp)qvoQrPVEuIPWTSKGgtTGcNI6XqDPWbHaKd(ke7iI)Ce9OWl60rQW)QKXdzUibiRs1O0FruIPWTSKGgtTGcNI6XqDPWbHaKd(ke7iI)CKToY6JS5r28iBEenKHjxeL5)7)QKXdzUibiRYJOt3rKeKL9lBiJ3onGhmffJJi(Zr26iBCK1hrsqw2VSHmE70aEWuumoYRJG9hzJJOt3rOrazXY0deCUi5mZfzt5ZpuLJhzUQtWrE9Ceru2rEZJ8)i60DejbzzpZCr2uUwS0qEK5Qobhr8JiIYoYBEK)hzdfErNosf(xLmEiZfjazvQgL(6DLykClljOXulOWPOEmuxkCnKHjxeL535)QKXdzUibiRYJS(iGqaYbFfIDeXFoYUJS(iBEejbzz)YgY4Ttd4btrX4iVEoYwhrNUJOHmm5IOm)w(Vkz8qMlsaYQ8iBCK1hbecqo4RqSJ86iB7iRpIKGSSNzUiBkNgiZlOPWl60rQWzMlsPaoQrP)2rjMc3YscAm1ckCkQhd1LcFZJqJaYILPhi4CrYzMlYMYNFOkhpYCvNGJi(r227hz9raAgeYNcjYgGVDAWa0rEKxph5)r24i60DeAeqwSm9abNlsoZCr2u(8dv54rMR6eCKxhz3FfErNosfoqW5IKJzdn52sMAu6J9kXu4wwsqJPwqHtr9yOUu40iGSyz6bcoxKCM5ISP85hQYXJmx1j4iIFeSxHx0PJuHl1qdqdbKiJlfojdbuJs)DVRetHBzjbnMAbfof1JH6sHdcbih8vi2rEDe9CK1hrsqw2ZmxKnLtdK5btrX4iVEoYFfErNosfoieGCWGAmm1O0F3oLykClljOXulOWPOEmuxkCqia5GVcXoYRNJS1rwFejbzzpZCr2uonqMxq7iRpYMhrsqw2ZmxKnLtdK5btrX4iI)CKToIoDhrsqw2ZmxKnLtdK5rMR6eCKxphreLDK38i6XR3pYgk8IoDKkCM5IukGJAu6V7VsmfULLe0yQfu4fD6iv4SiCkC6pk04tHezdqP)ofURElN(Jcn(uir2au46Dfof1JH6sHJmzKb(kjOPgL(72sjMc3YscAm1ck8IoDKkCAbH8IoDKCydgfoSbdplNPWLeAiJxCWxHyQrnk80MpdX1c0uqUKqdzDksjMs)DkXu4wwsqJPwqHtr9yOUu4GqaYbFfIDeXFoIEoY6JS5rw8rMcA541ILgIdATVi9wwsqJDeD6oIKGSSNzUiBkNgiZlODKnu4fD6iv4PnFgIRfOPGQrP)FLyk8IoDKkCAbHCgYkgykiggcOWTSKGgtTGAu6VLsmfULLe0yQfu4uupgQlfoncilwMEAbHCgYkgykiggc4rMR6eCeXpYUTZrwFeqia5GVcXoI4phzlfErNosf(xLmEiZfjazvQgL(BtjMc3YscAm1ckCkQhd1Lcxsqw2VSHmE70aEWuumoI4ph5)rwFejbzzpZCr2uonqMhmffJJ865i)pY6Jijil7zMlYMY1ILgYZIL5rwFeqia5GVcXoI4phzlfErNosfUwS0qCqR9fPAu6RhLykClljOXulOWPOEmuxkCqia5GVcXoI4phrpk8IoDKk8Vkz8qMlsaYQunk9xeLykClljOXulOWl60rQWPfeYl60rYHnyu4Wgm8SCMcxsOHmEXbFfIPg1OWLeAiJxCWxHykXu6VtjMcVOthPchecqoyqngMc3YscAm1cQrP)FLyk8IoDKkCWxXILCPaokClljOXulOg1OWtB(mexlqtbvIP0FNsmfULLe0yQfu4uupgQlfoncilwM(0MpdX1c0uqpYCvNGJ86i)FxHx0PJuHtliKx0PJKdBWOWHny4z5mfEAZNH4AbAkixsOHSofPgL()vIPWTSKGgtTGcNI6XqDPWLeKL9PnFgIRfOPGEbnfErNosfoTGqErNosoSbJch2GHNLZu4PnFgIRfOPG8IonMMAuJAuJAuk]] )


end
