-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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

                elseif spellID == 105174 then
                    -- Hand of Guldan; queue imps.
                    if shards_for_guldan >= 1 then table.insert( guldan, now + 0.11 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, now + 0.12 ) end
                    if shards_for_guldan >= 3 then table.insert( guldan, now + 0.13 ) end

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

        i = 1
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

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
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
        for k, v in pairs( other_demon_v   ) do other_demon_v  [ k ] = v + duration end
    end )

    spec:RegisterStateFunction( "consume_demons", function( name, count )
        local db = other_demon_v

        if name == "dreadstalkers" then db = dreadstalkers_v
        elseif name == "vilefiend" then db = vilefiend_v
        elseif name == "wild_imps" then db = wild_imps_v
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
            duration = function () return 5 * haste end,
            tick_time = function () return haste end,
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


    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 89766,
            known = function () return IsSpellKnownOrOverridesKnown( 119914 ) end,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,

            debuff = "casting",

            usable = function () return pet.exists end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "axe_toss", 4 )
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


        -- PvP:master_summoner.
        call_dreadstalkers = {
            id = 104316,
            cast = function () if pvptalent.master_summoner.enabled then return 0 end
                return buff.demonic_calling.up and 0 or ( 2 * haste )
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
            cast = function () return buff.demonbolt.up and 0 or 4.5 end,
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
            end,
        },


        demonic_gateway = {
            id = 111771,
            cast = 2,
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
            cast = function () return 5 * haste end,
            cooldown = 0,
            channeled = true,
            gcd = "spell",

            spend = function () return debuff.soul_rot.up and 0 or 0.03 end,
            spendType = "mana",

            startsCombat = true,

            start = function ()
                applyDebuff( "drain_life" )
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
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237564,
            
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
                local extra_shards = min( 2, soul_shards.current )
                spend( extra_shards, "soul_shards" )

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
                removeStack( "decimating_bolt" )
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
                
                --[[ if talent.demonic_consumption.enabled then
                    consume_demons( "wild_imps", "all" )
                end ]]

                extend_demons()

                if azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
                gain( 5, "soul_shards" )
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
            nomounted = true,

            usable = function () return not pet.exists end,
            handler = function ()
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

            toggle = "cooldowns",

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

    spec:RegisterPack( "Demonology", 20200905.2, [[dK0O9bqiLsTiQss9ivq6suLeYMus9jQsIyukjDkLOwLse1RefMLsHBrvI2Li)sPOHPcCmuHLHk1ZefnnvqDnLeBtjs(MsKY4uIqNtfeRJQKGMNkX9uQ2hQOdsvsGwOsjpujIyIkrQUivjr6KuLevRevYmPkjk7uj4NuLeWqPkjXtrQPsvQRsvssFLQKqTxQ8xvnyuoSIftv9yitgQltAZOQptvmAvQtl1QvIGxReA2eUnr7w43ugUO64krKwoONJy6sUos2UkPVlknEQsQZRcTEQsy(QO9dSJdN3oA8uQBbUpG7do4qoyL0blXdNj3lrhDDmxD05dAXXJ6OJrQo6LUkTWeMNJo685OWgSZBhnXOGi1rFxvoXRWn30tx3u(jKj3K0skXuTfi4WxBsAjAthTpvlkVYdNVJgpL6wG7d4(GdoKdwjDWs8WzY9s5Oj5kYTa3l1s5OVBmwdNVJgReKJ(qbSLUkTWeMNJaMxXduyOfbCDOagTMxQ0xHa2kBayCFa3ha4cW1Hcylj3t4rjEfc46qbmVeWOZvHaW8kZqlMaCDOaMxcyEvjkG5tXZNcTUv4NBWAejQCaRdsPdgWmEadQYPJo8ayljlDaRAPcy8geWwqRBfcyEvmyncaBqvFvbS87HOjaxhkG5LaMxbcXradQitk1adylDvAHVjkalhQEjYK(tbynpG1fG1eaRdsnrbyRAqa7EGy0qkaJ3GaMVrikz5eGRdfW8saZRILvHagDNFBbGncHLvXawou9sKj9NcWkdWYHgcW6Gutua2sxLw4BIkb46qbmVeW8QsuaZRUAP(L94w9QbSvvVoxrLIbmnqgvukeW0aVmGbN6wHawDpbG5vxd0JwPQL6x2JB1RgWwv96CfvkgWquqOgfGvd0JwELqamSo19Yawza2C1AmGPEnsjK(Qcy(uWOdpaMXdyWb1JaWwsw6KKJohA8TqD0hkGT0vPfMW8CeW8kEGcdTiGRdfWO18sL(keWwzdaJ7d4(aaxaUouaBj5EcpkXRqaxhkG5LagDUkeaMxzgAXeGRdfW8saZRkrbmFkE(uO1Tc)CdwJirLdyDqkDWaMXdyqvoD0HhaBjzPdyvlvaJ3Ga2cADRqaZRIbRraydQ6RkGLFpenb46qbmVeW8kqiocyqfzsPgyaBPRsl8nrby5q1lrM0FkaR5bSUaSMayDqQjkaBvdcy3deJgsby8geW8ncrjlNaCDOaMxcyEvSSkeWO78BlaSriSSkgWYHQxImP)uawzawo0qawhKAIcWw6Q0cFtujaxhkG5LaMxvIcyE1vl1VSh3QxnGTQ615kQumGPbYOIsHaMg4Lbm4u3keWQ7jamV6AGE0kvTu)YECRE1a2QQxNROsXagIcc1OaSAGE0YRecGH1PUxgWkdWMRwJbm1RrkH0xvaZNcgD4bWmEadoOEea2sYsNKaCb46qbmVs9AfrvkgW8vEdQagYK(tby(QNoijaZRGiKMxealSWlVhOKNsaydQAliaMfIJjaxhkGnOQTGKYHkYK(tTZlgYIaUouaBqvBbjLdvKj9NkJ9n5ndd46qbSbvTfKuourM0FQm23CO8i1OMQTaW1GQ2cskhQit6pvg7BsOKsl(CTaCDOa2GQ2cskhQit6pvg7B2rOWhRsliB0871i0OsDek8XQ0cssJXxOyaxhkGnOQTGKYHkYK(tLX(MKyYj3w9KAkcGRbvTfKuourM0FQm23m3YQWN053wSrZV7tXZNY2c83YCsIudAro5yTpfpFcRslA0JmOMi1Gw8Yo3aUgu1wqs5qfzs)PYyFZCRAlaCnOQTGKYHkYK(tLX(MyvAHVjQnA(DFJqophu1wKWQ0cFtuj0qQ9daCnOQTGKYHkYK(tLX(MK7bBzFFtuaUaCDOaMxPETIOkfdy6vfEeWQwQawDRa2GkdcynbWMRtlgFHMaCnOQTGStYvH4fgAraxdQAlizSV5416xgHa4AqvBbjJ9nZTQTyJMFpxRewLw0OVocNOsdQ6R66v3wjenqA6AtAlEJ)ZviVIQ2IKCwcg88C7AeAujSkTOrpYccLmVAlsAm(cfFEImtGTSrIqjLw8yvArJ(6iCIkbv50bHZDKzcSLnsekP0IhRslA0xhHtujmfCQ2cVCLLxV621i0OsHw3k8ZnynIKgJVqXNN(u88PqRBf(5gSgrIkF5ZZQL6x2JB9sMha4AqvBbjJ9nPi63Lk3igPUpEb5EGd55TOEJ)ZTSkCJMFhzMaBzJeHskT4XQ0Ig91r4evcQYPdYLDUpy921i0OsHw3k8ZnynIKgJVqXaUgu1wqYyFtkI(DPsYgn)EUwjSkTOrFDeorLgu1x11RUTsiAG001M0w8g)NRqEfvTfj5Sem45521i0OsyvArJEKfekzE1wK0y8fk(8ezMaBzJeHskT4XQ0Ig91r4evcQYPdcN7iZeylBKiusPfpwLw0OVocNOsyk4uTfE5klFEwTu)YECRx25yfaxdQAlizSVPVcjkCXo8SrZVNRvcRslA0xhHtuPbv9vD9QBReIginDTjTfVX)5kKxrvBrsolbdEEUDncnQewLw0OhzbHsMxTfjngFHIpprMjWw2irOKslESkTOrFDeorLGQC6GW5oYmb2YgjcLuAXJvPfn6RJWjQeMcovBHxUYYNNvl1VSh36LDowbW1GQ2csg7B6lmd)8uWJB0875ALWQ0Ig91r4evAqvFvxV62kHObstxBsBXB8FUc5vu1wKKZsWGNNBxJqJkHvPfn6rwqOK5vBrsJXxO4ZtKzcSLnsekP0IhRslA0xhHtujOkNoiCUJmtGTSrIqjLw8yvArJ(6iCIkHPGt1w4LRS85z1s9l7XTEzNJvaCnOQTGKX(M8nu9fMH3O53Z1kHvPfn6RJWjQ0GQ(QUE1TvcrdKMU2K2I34)CfYROQTijNLGbpp3UgHgvcRslA0JSGqjZR2IKgJVqXNNiZeylBKiusPfpwLw0OVocNOsqvoDq4ChzMaBzJeHskT4XQ0Ig91r4evctbNQTWlxz5ZZQL6x2JB9YohRa4AqvBbjJ9n9fMHFJ)RB91qLh3O53Z1kHvPfn6RJWjQ0GQ(QUoxRewLw0OVocNOsqvoDqUSZXkEPheEjN56v3wjenqA6AtAlEJ)ZviVIQ2IKCwcg88C7AeAujSkTOrpYccLmVAlsAm(cfFEImtGTSrIqjLw8yvArJ(6iCIkbv50bHZDKzcSLnsekP0IhRslA0xhHtujmfCQ2cVCLLbCnOQTGKX(MznOaFv74HkXIjq6gn)UpfpFs08QVWmCIudAXlzUE1CTsyvArJ(6iCIknOQVQRxDBLq0aPPRnPT4n(pxH8kQAlsYzjyWZZTRrOrLWQ0Ig9iliuY8QTiPX4lu85jYmb2YgjcLuAXJvPfn6RJWjQeuLtheo3rMjWw2irOKslESkTOrFDeorLWuWPAl8Yvw(8SAP(L94wVSZXkld4AqvBbjJ9nHDEUq)oEs(G0nA(9CTsyvArJ(6iCIknOQVQRxDBLq0aPPRnPT4n(pxH8kQAlsYzjyWZZTRrOrLWQ0Ig9iliuY8QTiPX4lu85jYmb2YgjcLuAXJvPfn6RJWjQeuLtheo3rMjWw2irOKslESkTOrFDeorLWuWPAl8Yvw(8SAP(L94wVSZXkaUgu1wqYyFtkI(DPYnIrQ75gArTiTxO4hzYCQAQ2IhRxBKUrZVJmtGTSrIqjLw8yvArJ(6iCIkbv50bHZDUpynYmb2YgjcLuAXJvPfn6RJWjQeuLthKl7iZeylBKiusPfpwLw0OVocNOsyk4uTfEjhRCEwTu)YECRx2Z8aaxdQAlizSVjfr)Uu5gXi1DOviifPu8F1mSzp2eInA(9vrMjWw2irOKslESkTOrFDeorLGQC6GW5o3RCEwTu)YECRx2Z8GLbCnOQTGKX(Mue97sLBeJu3j39vf(x1WKpufnAJMFFvKzcSLnsekP0IhRslA0xhHtujOkNoiCUZ9kNNvl1VSh36L9mpyzaxdQAlizSVjfr)Uu5gXi19zjLQZTsJ6JHQAbfzJMFFvKzcSLnsekP0IhRslA0xhHtujOkNoiCUZ9kNNvl1VSh36L9mpyzaxdQAlizSVjfr)Uu5gXi19QXkPmO8rgw96nA(9vrMjWw2irOKslESkTOrFDeorLGQC6GW5o3RCEwTu)YECRx2Z8GLbCnOQTGKX(Mue97sLBeJu3V2J4n(Nugus2O53xfzMaBzJeHskT4XQ0Ig91r4evcQYPdcN7CVY5z1s9l7XTEzpZdwgW1GQ2csg7BIgH4hu1w8IMuBeJu3TCnu4gn)(21i0OsHw3k8ZnynIKgJVqXRRwQxY8G1BJmtGTSrIqjLw8yvArJ(6iCIkbv50bbW1GQ2csg7Bsr0VlvUrmsDF8cY9ahYZBr9g)NBzv4gn)(QvlvoZ8GZZTRrOrLcTUv4NBWAejngFHIxEDncnQKhylTgQpVk8qnqCsJXxO41RwTu)YECRCYb3hCEwTu)YECRxqMjWw2irOKslESkTOrFDeorLGQC6GKbhRS85z1s9l7XTEzpZvaCnOQTGKX(M3tGFJ)9qjWtSrZVpEHc7stQxNlmsFv)CR0O6rKGtS46QL6LvwtmkXtUhiMtUx7tXZNuVoxyK(Q(5wPr1JiHTSXAFkE(u2wG)wMtsKAqlEjZ1BNd1RVheoXr6Ec8B8VhkbEI1BNd1RVheoXD6Ec8B8VhkbEcaxdQAlizSVjwLw4BIAJMFNyuINCpq8L9mx7tXZNWQ0Ig9idQjQ81(u88jSkTOrpYGAIudAX9dd4AqvBbjJ9nBzUWiTfB087JxOWU0K615cJ0x1p3knQEej4elU2NINpLTf4VL5KePg0ICY9AFkE(K615cJ0x1p3knQEejOkNoixgu1wKi3d2Y((MOsQxRiQs)QL66v3UgHgvcRslA0JSGqjZR2IKgJVqXNNiZeylBKiusPfpwLw0OVocNOsqvoDq4KdUxgW1GQ2csg7BIntUrZVVD1Of7WZ6QL6x2JBLZmpynjxfIVgOhTiPwMlmsBXfUxVTpfpFk06wHFUbRrKGQC6Ga4AqvBbjJ9njiJc2HNV66wbCnOQTGKX(Myf1YP6WZ7BIcW1GQ2csg7BsmkXdTAJMFFqvFvFnuzReoZeW1GQ2csg7B2YCnWD45rtnKcA53kGRbvTfKm230Vfkbzuqp67BsFfs2O53hVqHDPj1RZfgPVQFUvAu9isWjwKZdwxTuVWXbRj5Qq81a9Ofj1YCHrAlUW9AFkE(egQdMuJyrfssqvoDqwxJqJkfADRWp3G1isAm(cfd4AqvBbjJ9nXQ0Ig9KcQHN6EJMFFvFkE(u2wG)wMtsKAqlEzPop9P45tyvArJ(ClRctu5lFEsYvH4Rb6rlsQL5cJ0wCHBaxdQAlizSVjAeIFqvBXlAsTrmsDp06wHFUbRrSrZVxJqJkfADRWp3G1isAm(cfVMKRcXxd0JwKulZfgPT4Yo3aUgu1wqYyFt0ie)GQ2Ix0KAJyK6ElZfgPTyJMFNKRcXxd0JwKulZfgPTGtowJmtGTSrIqjLw8yvArJ(6iCIkbv50bbW1GQ2csg7B6HAG4EI34)XluOv3B087iZeylBKiusPfpwLw0OVocNOsqvoDqUSZXkNNvl1VSh36L9mpaW1GQ2csg7B6b2sRH6ZRcpudeVrZVVA1s9l7XTYjhCFW5z1s9l7XTEbzMaBzJeHskT4XQ0Ig91r4evcQYPdsgCSY5jYmb2YgjcLuAXJvPfn6RJWjQeuLthKlCK5YaUgu1wqYyFtcLuAXFTfkFRbEJMFhzMaBzJeHskT4XQ0Ig91r4evcQYPdcNh(GZtKzcSLnsekP0IhRslA0xhHtujOkNoix4GBaxdQAlizSVjAeIhd1btQrSOcjB087RImtGTSrIqjLw8yvArJ(6iCIkbv50b5YHS2NINpHvPfn6rJq0HNeuLthKLppxfzMaBzJeHskT4XQ0Ig91r4evcQYPdYfo4y92(u88jSkTOrpAeIo8KGQC6GS85jYmb2YgjcLuAXJvPfn6RJWjQeuLtheo54WaUgu1wqYyFZ6wFQW3Oc8ZBqKUrZV7tXZNGkArHsipVbrAcQdQaCnOQTGKX(M(TqjiJc6rFFt6RqcGRbvTfKm238Ec8B8VhkbEInA(9vhVqHDPj)rO8uIVJRgAQ2IKgJVqXNN1i0OsyvArJEKfekzE1wK0y8fkE515q967bHtCKUNa)g)7HsGNynYmb2YgjcLuAXJvPfn6RJWjQeuLthKlCd46qbmUp4Gd8kIKRcXFpKsbSMayKBdw3tGbmEdcy1TcyOHuaw1sfWmEaBPRslAeG59r4evcW8(wbSoknkaRjawzaMfIJaMV6PdadnKQdpawZdydGHuynDaybL0xHaMXdyTmNayzBHaW8vaZOkaZ)iGv3kGPbgWmEaRUvadnKkb4AqvBbjJ9njusPfpwLw0OVocNO2O53jgL4j3deFjZ1RUDncnQewLw0OhzbHsMxTfjngFHIpp9P45tzBb(BzojrQbTygTmN8K8jBO4htb7WtIqjLw8yvArJ(6iCIIZ9LAD1s9l7BzojncrcQYPdYf0qQVAPU85z1s9l7XTEH7daCnOQTGKX(M5wwf(Ko)2InA(DFkE(u2wG)wMtsKAqlY5o3R9P45tyvArJEKb1ePg0Ix25ETpfpFcRslA0NBzvycBzJ1KCvi(AGE0IKAzUWiTfx4gW1GQ2csg7BIntUrZVxJqJkHntM0y8fkEnu5Hk5E8f66QL6x2JBLZvXwLWMjtqvoDqYiZdwgW1GQ2csg7BEpb(n(3dLapXgn)oXOep5EGyo3x58CvIrjEY9aXCUN5AKzcSLnsOriEmuhmPgXIkKKGQC6GW5HxVkYmb2YgjcLuAXJvPfn6RJWjQeuLtheo5(GZZvrMjWw2irOKslESkTOrFDeorLGQC6GCXdcVK5EDncnQewLw0OhzbHsMxTfjngFHIpprMjWw2irOKslESkTOrFDeorLGQC6GCXdcVKp86TRrOrLWQ0Ig9iliuY8QTiPX4lu8YlVE1TRrOrLiusPf)1wO8Tg4KgJVqXNNiZeylBKiusPf)1wO8Tg4euLtheoZC5LbCnOQTGKX(MeJs8Kc2lQB087eJs8K7bIVSYAFkE(ewLw0OhzqnrQbT4LDUbCnOQTGKX(MyvAHVjQnA(DIrjEY9aXx2ZCTpfpFcRslA0JmOMOYxV6QiZeylBKiusPfpwLw0OVocNOsqvoDqUSuNNiZeylBKiusPfpwLw0OVocNOsqvoDq4KBUxV94fkSlnrUhSLL8(DPjngFHIx(80NINpHvPfn6rgutKAqlY5EMNN(u88jSkTOrpYGAcQYPdYLvopRwQFzpU1lCVY5PpfpFICpyll597stqvoDqwgW1GQ2csg7BYBikII)Xluyx67RJCJMFF7CTsyvArJ(6iCIknOQVQaUgu1wqYyFZCkyZFSdpVVyifGRbvTfKm230xyg(n(VU1xdvEeW1GQ2csg7BISaPrbNsXpVyK6gn)(2yRsilqAuWPu8ZlgP((uWibv50bz92dQAlsilqAuWPu8ZlgPM645fTN7A925ALWQ0Ig91r4evAqvFvbCnOQTGKX(MqDY7WZZlgPs2O533oxRewLw0OVocNOsdQ6RkGRbvTfKm23encXpOQT4fnP2igPU7t1c8pp5EGyaxaUgu1wqs(uTa)ZtUhiExQsdE8n(xqHA8JH6ijB087eJs8K7bIVWnGRbvTfKKpvlW)8K7bIZyFtIrjEsb7f1nA(9TRrOrLWQ0Ig9iliuY8QTiPX4lu85z1sLtow58mhQxFpiCIJ09e434Fpuc8eR32NINp5lmdlOivcQYPdcGRbvTfKKpvlW)8K7bIZyFtY9GTSVVjkaxaUgu1wqsTmxyK2I9wMlmsBXgn)(Q(u88PSTa)TmNKi1GwKZ9LA9QeJs8K7bIVK55zouV(Eq4ehj0iepgQdMuJyrfsop9P45tzBb(BzojrQbTiN7hY5zouV(Eq4ehj)wOeKrb9OVVj9vi58C1TZH613dcN4iDpb(n(3dLapX6TZH613dcN4oDpb(n(3dLapXYlVE7COE99GWjos3tGFJ)9qjWtSE7COE99GWjUt3tGFJ)9qjWtS2NINpHvPfn6ZTSkmHTSXYNNRwTu)YECRxYCTpfpFkBlWFlZjjsnOf58GLppxnhQxFpiCI7eAeIhd1btQrSOcjR9P45tzBb(BzojrQbTiNCVE7AeAujSkTOrpAeIo8K0y8fkEzaxdQAliPwMlmsBrg7B6b2sRH6ZRcpudeVrZVJmtGTSrIqjLw8yvArJ(6iCIkbv50b5chzEEUTUKs155koXrMCN5sDiaUgu1wqsTmxyK2Im23encXJH6Gj1iwuHKnA(9vrMjWw2irOKslESkTOrFDeorLGQC6GC5qw7tXZNWQ0Ig9Ori6WtcQYPdYYNNRImtGTSrIqjLw8yvArJ(6iCIkbv50b5chCSEBFkE(ewLw0OhncrhEsqvoDqw(8ezMaBzJeHskT4XQ0Ig91r4evcQYPdcNCCyaxdQAliPwMlmsBrg7BsOKslESkTOrFDeorb4AqvBbj1YCHrAlYyFZ7jWVX)EOe4j2O53jgL4j3deZ5(kaUgu1wqsTmxyK2Im238Ec8B8VhkbEInA(DIrjEY9aXCUN56vxD1COE99GWjUt3tGFJ)9qjWtCE6tXZNY2c83YCsIudAro3ZC51(u88PSTa)TmNKi1Gw8YHS85jYmb2YgjcLuAXJvPfn6RJWjQeuLthKl7Eq4Lm3NN(u88jSkTOrFULvHjOkNoiC6bHxYCVmGRbvTfKulZfgPTiJ9nXQ0cFtuB0875q967bHtCKUNa)g)7HsGNynXOep5EGyo35y9Q(u88PSTa)TmNKi1Gw8YEMNN5q967bHtzMUNa)g)7HsGNy51eJs8K7bIVC41(u88jSkTOrpYGAIkhW1GQ2csQL5cJ0wKX(MekP0I)Alu(wd8gn)(QiZeylBKiusPfpwLw0OVocNOsqvoDq48WhSMKRcXxd0JwKulZfgPT4Yo3lFEImtGTSrIqjLw8yvArJ(6iCIkbv50b5chCd4AqvBbj1YCHrAlYyFt)wOeKrb9OVVj9vizJMFhzMaBzJeHskT4XQ0Ig91r4evcQYPdcNhcGRbvTfKulZfgPTiJ9n5nefrX)4fkSl991rc4AqvBbj1YCHrAlYyFZCkyZFSdpVVyifGRbvTfKulZfgPTiJ9n9fMHFJ)RB91qLhbCnOQTGKAzUWiTfzSVjYcKgfCkf)8IrQB087BJTkHSaPrbNsXpVyK67tbJeuLthK1BpOQTiHSaPrbNsXpVyKAQJNx0EUR1KCvi(AGE0IKAzUWiTfxwbW1GQ2csQL5cJ0wKX(MeJs8Kc2lQB087eJs8K7bIVSYAFkE(ewLw0OhzqnrQbT4LDUbCnOQTGKAzUWiTfzSVjwLw4BIAJMFNyuINCpq8L9mx7tXZNWQ0Ig9idQjQ81R6tXZNWQ0Ig9idQjsnOf5CpZZtFkE(ewLw0Ohzqnbv50b5YUheEjVsAPTmGRbvTfKulZfgPTiJ9nXMj3aDej0VgOhTi7CSHC86hDej0VgOhTi7lTnA(DOYdvY94luaxdQAliPwMlmsBrg7BIgH4hu1w8IMuBeJu39PAb(NNCpqmGlaxdQAliPqRBf(5gSgXoAeIFqvBXlAsTrmsDp06wHFUbRr8(uTa3HNnA(DKzcSLnsHw3k8ZnynIeuLthKlCFaGRbvTfKuO1Tc)CdwJiJ9nrJq8dQAlErtQnIrQ7Hw3k8ZnynIFqvFv3O539P45tHw3k8ZnynIevoGlaxdQAliPqRBf(5gSgXpOQVQ7(TqjiJc6rFFt6RqcGRbvTfKuO1Tc)CdwJ4hu1x1m230dSLwd1NxfEOgiEJMFhzMaBzJeHskT4XQ0Ig91r4evcQYPdYfoY88CBDjLQZZvCIJm5oZL6qaCnOQTGKcTUv4NBWAe)GQ(QMX(MekP0I)Alu(wd8gn)oYmb2YgjcLuAXJvPfn6RJWjQeuLtheop8bNNiZeylBKiusPfpwLw0OVocNOsqvoDqUWb3aUgu1wqsHw3k8ZnynIFqvFvZyFt0iepgQdMuJyrfs2O53xfzMaBzJeHskT4XQ0Ig91r4evcQYPdYLdzTpfpFcRslA0JgHOdpjOkNoilFEUkYmb2YgjcLuAXJvPfn6RJWjQeuLthKlCWX6T9P45tyvArJE0ieD4jbv50bz5ZtKzcSLnsekP0IhRslA0xhHtujOkNoiCYXHbCnOQTGKcTUv4NBWAe)GQ(QMX(MOri(bvTfVOj1gXi1DFQwG)5j3deVrZVtmkXtUhiENJ1RImtGTSrcncXJH6Gj1iwuHKeuLthKldQAlsK7bBzFFtuj0qQVAPEEUAncnQKFlucYOGE033K(kKK0y8fkEnYmb2Ygj)wOeKrb9OVVj9vijbv50b5YGQ2Ie5EWw233evcnK6RwQlVmGRbvTfKuO1Tc)CdwJ4hu1x1m238Ec8B8VhkbEInA(9vxfzMaBzJeAeIhd1btQrSOcjjOkNoiCoOQTiHvPf(MOsOHuF1sD51RImtGTSrcncXJH6Gj1iwuHKeuLtheohu1wKi3d2Y((MOsOHuF1sD5LxJmtGTSrk06wHFUbRrKGQC6GW5QCSuRKXGQ2I09e434Fpuc8ej0qQVAPUmGRbvTfKuO1Tc)CdwJ4hu1x1m23KqjLw8yvArJ(6iCIAJMF3NINpfADRWp3G1isqvoDqUSYAIrjEY9aX7ha4AqvBbjfADRWp3G1i(bv9vnJ9njusPfpwLw0OVocNO2O539P45tHw3k8ZnynIeuLthKldQAlsekP0IhRslA0xhHtuj0qQVAPMXbPvaCnOQTGKcTUv4NBWAe)GQ(QMX(MyvAHVjQnA(DFkE(ewLw0OhzqnrLVMyuINCpq8L9mbCnOQTGKcTUv4NBWAe)GQ(QMX(MOri(bvTfVOj1gXi1DFQwG)5j3ded4cW1GQ2csk06wHFUbRr8(uTa3HNDkI(DPYnIrQ7JxqUh4qEElQ34)ClRc3O53rMjWw2ifADRWp3G1isqvoDqUSVYsMKRcXFpKsbCnOQTGKcTUv4NBWAeVpvlWD4jJ9n9qnqCpXB8)4fk0Q7nA(9TrMjWw2ifADRWp3G1isqvoDqwtmkXtUhiMZ9vaCnOQTGKcTUv4NBWAeVpvlWD4jJ9ndTUv4NBWAeB087eJs8K7bI5CFfaxdQAliPqRBf(5gSgX7t1cChEYyFt0iepgQdMuJyrfs2O53RwQCUN5baUgu1wqsHw3k8ZnynI3NQf4o8KX(M3tGFJ)9qjWtSrZVxTu5CpZdwJmtGTSrcncXJH6Gj1iwuHKeuLtheo5yjUMyuINCpqmN7zc4AqvBbjfADRWp3G1iEFQwG7Wtg7BMBzv4t68Bl2O53RwQCUN5bR9P45tzBb(BzojrQbTiN7CV2NINpHvPfn6rgutKAqlEzN71(u88jSkTOrFULvHjSLnwtmkXtUhiMZ9mbCnOQTGKcTUv4NBWAeVpvlWD4jJ9nVNa)g)7HsGNyJMFVAPY5EMhSMyuINCpqmN7Ra4AqvBbjfADRWp3G1iEFQwG7Wtg7BIgH4hu1w8IMuBeJu39PAb(NNCpqmGlaxdQAlijlxdfUFpb(n(3dLapXgIo0hH3Z8GnA(9XluyxAs96CHr6R6NBLgvpIKgJVqXaUgu1wqswUgkmJ9nBzUWiTfB087JxOWU0K615cJ0x1p3knQEejngFHIx7tXZNY2c83YCsIudAro5ETpfpFs96CHr6R6NBLgvpIe2YgaUgu1wqswUgkmJ9nXMj3q0H(i8EMha4AqvBbjz5AOWm230d1aX9eVX)JxOqRUbCnOQTGKSCnuyg7BEpb(n(3dLapXgn)EouV(Eq4ehP7jWVX)EOe4jwtmkXtUhiMZdwNd1RVheoXDIyuINuWErfW1GQ2csYY1qHzSVjwLw0ONuqn8u3B0875q967bHtCKUNa)g)7HsGNy925q967bHtCNUNa)g)7HsGNy9Q(u88PSTa)TmNKi1GwKtowpOQTiDpb(n(3dLaprQJNx0EURLbCnOQTGKSCnuyg7B63cLGmkOh99nPVcjaUgu1wqswUgkmJ9njgL4jfSxu3q0H(i8EMhSrZVVTpfpFYxygwqrQeuLthKZZQLkNRSohQxFpiCIJ09e434Fpuc8eaUgu1wqswUgkmJ9njusPf)1wO8Tg4nA(DIrjEY9aX7Ra4AqvBbjz5AOWm230dSLwd1NxfEOgiEJMFNyuINCpq8(kaUgu1wqswUgkmJ9nrJq8yOoysnIfvizJMFNyuINCpq8(kaUgu1wqswUgkmJ9nVNa)g)7HsGNyJMFNyuINCpq8(kaUgu1wqswUgkmJ9nVNa)g)7HsGNyJMFNyuINCpqmN7zUohQxFpiCI709e434Fpuc8eRRwQCUY6vZH613dcN4irmkXtkyVOEEUDncnQeXOepPG9IAsJXxO415q967bHtCKi3d2Y((MOwgW1HcyCFWbh4vejxfI)EiLcynbWi3gSUNady8geWQBfWqdPaSQLkGz8a2sxLw0iaZ7JWjQeG59TcyDuAuawtaSYamlehbmF1thagAivhEaSMhWgadPWA6aWckPVcbmJhWAzobWY2cbG5RaMrvaM)raRUvatdmGz8awDRagAivcW1GQ2csYY1qHzSVjHskT4XQ0Ig91r4e1gn)EouV(Eq4ehjSkTOrpPGA4PUppZH613dcN4iDpb(n(3dLapX6COE99GWjUt3tGFJ)9qjWtCEUDncnQewLw0ONuqn8u3jngFHIx7tXZNY2c83YCsIudAXmAzo5j5t2qXpMc2HNeHskT4XQ0Ig91r4efN7lfGRbvTfKKLRHcZyFtSkTW3e1gn)oXOep5EG4l7zU2NINpHvPfn6rgutqvoDqaCnOQTGKSCnuyg7BIgH4hu1w8IMuBeJu39PAb(NNCpqSJ(QcjTfUf4(aUp4Gd5GvC0zhy0HhIJ2RCzUblfdylraBqvBbGjAsrsaUC0dvDBqhnDlxsC0IMueN3oAlxdf682TahoVD0Am(cf72YrpOQTWrFpb(n(3dLapHJgb7sH94OhVqHDPj1RZfgPVQFUvAu9isAm(cf7OfDOpc7OZ8ax5wGBN3oAngFHIDB5OrWUuypo6XluyxAs96CHr6R6NBLgvpIKgJVqXa2AaZNINpLTf4VL5KePg0IagNag3a2AaZNINpPEDUWi9v9ZTsJQhrcBzdh9GQ2chDlZfgPTWvUfY05TJwJXxOy3wo6bvTfoASzshTOd9ryhDMh4k3ch25TJEqvBHJ2d1aX9eVX)JxOqRUD0Am(cf72YvUfwX5TJwJXxOy3woAeSlf2JJohQxFpiCIJ09e434Fpuc8ea2AaJyuINCpqmGXjGDaGTgWYH613dcN4ormkXtkyVO6Ohu1w4OVNa)g)7HsGNWvUfwkN3oAngFHIDB5OrWUuypo6COE99GWjos3tGFJ)9qjWtayRbSTbSCOE99GWjUt3tGFJ)9qjWtayRbSvbmFkE(u2wG)wMtsKAqlcyCcyCayRbSbvTfP7jWVX)EOe4jsD88I2ZDbyl7Ohu1w4OXQ0Ig9KcQHN62vUfwAoVD0dQAlC0(TqjiJc6rFFt6RqIJwJXxOy3wUYTWs05TJwJXxOy3wo6bvTfoAIrjEsb7fvhnc2Lc7XrVnG5tXZN8fMHfuKkbv50bbWopbSQLkGXjGTcGTgWYH613dcN4iDpb(n(3dLapHJw0H(iSJoZdCLBHdX5TJwJXxOy3woAeSlf2JJMyuINCpqmGTdyR4Ohu1w4OjusPf)1wO8Tgyx5wGJdCE7O1y8fk2TLJgb7sH94OjgL4j3dedy7a2ko6bvTfoApWwAnuFEv4HAGyx5wGdoCE7O1y8fk2TLJgb7sH94OjgL4j3dedy7a2ko6bvTfoA0iepgQdMuJyrfsCLBbo425TJwJXxOy3woAeSlf2JJMyuINCpqmGTdyR4Ohu1w4OVNa)g)7HsGNWvUf4itN3oAngFHIDB5OrWUuypoAIrjEY9aXagN7awMa2AalhQxFpiCI709e434Fpuc8ea2AaRAPcyCcyRayRbSvbSCOE99GWjoseJs8Kc2lQa25jGTnGvJqJkrmkXtkyVOM0y8fkgWwdy5q967bHtCKi3d2Y((MOaSLD0dQAlC03tGFJ)9qjWt4k3cCCyN3oAngFHIDB5OrWUuypo6COE99GWjosyvArJEsb1WtDdyNNawouV(Eq4ehP7jWVX)EOe4jaS1awouV(Eq4e3P7jWVX)EOe4jaSZtaBBaRgHgvcRslA0tkOgEQ7KgJVqXa2AaZNINpLTf4VL5KePg0IawgawlZjpjFYgk(XuWo8KiusPfpwLw0OVocNOamo3bSLYrpOQTWrtOKslESkTOrFDeor5k3cCSIZBhTgJVqXUTC0iyxkShhnXOep5EGya7YoGLjGTgW8P45tyvArJEKb1euLtheh9GQ2chnwLw4BIYvUf4yPCE7O1y8fk2TLJEqvBHJgncXpOQT4fnPC0IMuFms1r7t1c8pp5EGyx5khDlZfgPTW5TBboCE7O1y8fk2TLJgb7sH94OxfW8P45tzBb(BzojrQbTiGX5oGTua2AaBvaJyuINCpqmGDbWYeWopbSCOE99GWjosOriEmuhmPgXIkKayNNaMpfpFkBlWFlZjjsnOfbmo3bSdbWopbSCOE99GWjos(TqjiJc6rFFt6RqcGDEcyRcyBdy5q967bHtCKUNa)g)7HsGNaWwdyBdy5q967bHtCNUNa)g)7HsGNaWwgWwgWwdyBdy5q967bHtCKUNa)g)7HsGNaWwdyBdy5q967bHtCNUNa)g)7HsGNaWwdy(u88jSkTOrFULvHjSLnaSLbSZtaBvaRAP(L94wbSlawMa2AaZNINpLTf4VL5KePg0IagNa2ba2Ya25jGTkGLd1RVheoXDcncXJH6Gj1iwuHeaBnG5tXZNY2c83YCsIudAraJtaJBaBnGTnGvJqJkHvPfn6rJq0HNKgJVqXa2Yo6bvTfo6wMlmsBHRClWTZBhTgJVqXUTC0iyxkShhnYmb2YgjcLuAXJvPfn6RJWjQeuLthea7cGXrMa25jGTnGPlPuDEUItzBbpuXKN0EAXB8pHkxHTbFcLuArhEC0dQAlC0EGT0AO(8QWd1aXUYTqMoVD0Am(cf72YrJGDPWEC0RcyiZeylBKiusPfpwLw0OVocNOsqvoDqaSla2HayRbmFkE(ewLw0OhncrhEsqvoDqaSLbSZtaBvadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGDbW4GdaBnGTnG5tXZNWQ0Ig9Ori6WtcQYPdcGTmGDEcyiZeylBKiusPfpwLw0OVocNOsqvoDqamobmooSJEqvBHJgncXJH6Gj1iwuHex5w4WoVD0dQAlC0ekP0IhRslA0xhHtuoAngFHIDB5k3cR482rRX4luSBlhnc2Lc7XrtmkXtUhigW4ChWwXrpOQTWrFpb(n(3dLapHRClSuoVD0Am(cf72YrJGDPWEC0eJs8K7bIbmo3bSmbS1a2Qa2Qa2QawouV(Eq4e3P7jWVX)EOe4jaSZtaZNINpLTf4VL5KePg0IagN7awMa2Ya2AaZNINpLTf4VL5KePg0Ia2fa7qaSLbSZtadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGDzhW8GWa2sgW4gWopbmFkE(ewLw0Op3YQWeuLtheaJtaZdcdylzaJBaBzh9GQ2ch99e434Fpuc8eUYTWsZ5TJwJXxOy3woAeSlf2JJohQxFpiCIJ09e434Fpuc8ea2AaJyuINCpqmGX5oGXbGTgWwfW8P45tzBb(BzojrQbTiGDzhWYeWopbSCOE99GWPmt3tGFJ)9qjWtayldyRbmIrjEY9aXa2fa7Wa2AaZNINpHvPfn6rgutu5o6bvTfoASkTW3eLRClSeDE7O1y8fk2TLJgb7sH94OxfWqMjWw2irOKslESkTOrFDeorLGQC6GayCcyh(aaBnGrYvH4Rb6rlsQL5cJ0wayx2bmUbSLbSZtadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGDbW4GBh9GQ2chnHskT4V2cLV1a7k3chIZBhTgJVqXUTC0iyxkShhnYmb2YgjcLuAXJvPfn6RJWjQeuLtheaJta7qC0dQAlC0(TqjiJc6rFFt6RqIRClWXboVD0dQAlC08gIIO4F8cf2L((6iD0Am(cf72YvUf4GdN3o6bvTfo6CkyZFSdpVVyiLJwJXxOy3wUYTahC782rpOQTWr7lmd)g)x36RHkp6O1y8fk2TLRClWrMoVD0Am(cf72YrJGDPWEC0BdyyRsilqAuWPu8ZlgP((uWibv50bbWwdyBdydQAlsilqAuWPu8ZlgPM645fTN7cWwdyKCvi(AGE0IKAzUWiTfa2faBfh9GQ2chnYcKgfCkf)8IrQUYTahh25TJwJXxOy3woAeSlf2JJMyuINCpqmGDbWwbWwdy(u88jSkTOrpYGAIudAra7YoGXTJEqvBHJMyuINuWEr1vUf4yfN3oAngFHIDB5OrWUuypoAIrjEY9aXa2LDaltaBnG5tXZNWQ0Ig9idQjQCaBnGTkG5tXZNWQ0Ig9idQjsnOfbmo3bSmbSZtaZNINpHvPfn6rgutqvoDqaSl7aMhegWwYa2kPLgGTSJEqvBHJgRsl8nr5k3cCSuoVD0Am(cf72YrpOQTWrJnt6Orhrc9Rb6rlIBboC0YXRF0rKq)AGE0I4OxAoAeSlf2JJgQ8qLCp(c1vUf4yP582rRX4luSBlh9GQ2chnAeIFqvBXlAs5OfnP(yKQJ2NQf4FEY9aXUYvoASYpuIY5TBboCE7Ohu1w4Oj5Qq8cdTOJwJXxOy3wUYTa3oVD0dQAlC0JxRFzeIJwJXxOy3wUYTqMoVD0Am(cf72YrJGDPWEC05ALWQ0Ig91r4evAqvFvbS1a2Qa22aMsiAG001M0w8g)NRqEfvTfj5SemiGDEcyBdy1i0OsyvArJEKfekzE1wK0y8fkgWopbmKzcSLnsekP0IhRslA0xhHtujOkNoiagN7agYmb2YgjcLuAXJvPfn6RJWjQeMcovBbG5La2ka2Ya2AaBvaBBaRgHgvk06wHFUbRrK0y8fkgWopbmFkE(uO1Tc)CdwJirLdyldyNNaw1s9l7XTcyxaSmpWrpOQTWrNBvBHRClCyN3oAngFHIDB5Ohu1w4OhVGCpWH88wuVX)5wwf6OrWUuypoAKzcSLnsekP0IhRslA0xhHtujOkNoia2LDaJ7daS1a22awncnQuO1Tc)CdwJiPX4luSJogP6OhVGCpWH88wuVX)5wwf6k3cR482rRX4luSBlhnc2Lc7XrNRvcRslA0xhHtuPbv9vfWwdyRcyBdykHObstxBsBXB8FUc5vu1wKKZsWGa25jGTnGvJqJkHvPfn6rwqOK5vBrsJXxOya78eWqMjWw2irOKslESkTOrFDeorLGQC6GayCUdyiZeylBKiusPfpwLw0OVocNOsyk4uTfaMxcyRayldyNNaw1s9l7XTcyx2bmowXrpOQTWrtr0VlvsCLBHLY5TJwJXxOy3woAeSlf2JJoxRewLw0OVocNOsdQ6RkGTgWwfW2gWucrdKMU2K2I34)CfYROQTijNLGbbSZtaBBaRgHgvcRslA0JSGqjZR2IKgJVqXa25jGHmtGTSrIqjLw8yvArJ(6iCIkbv50bbW4ChWqMjWw2irOKslESkTOrFDeorLWuWPAlamVeWwbWwgWopbSQL6x2JBfWUSdyCSIJEqvBHJ2xHefUyhECLBHLMZBhTgJVqXUTC0iyxkShhDUwjSkTOrFDeorLgu1xvaBnGTkGTnGPeIginDTjTfVX)5kKxrvBrsolbdcyNNa22awncnQewLw0OhzbHsMxTfjngFHIbSZtadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGX5oGHmtGTSrIqjLw8yvArJ(6iCIkHPGt1wayEjGTcGTmGDEcyvl1VSh3kGDzhW4yfh9GQ2chTVWm8Ztbp6k3clrN3oAngFHIDB5OrWUuypo6CTsyvArJ(6iCIknOQVQa2AaBvaBBatjenqA6AtAlEJ)ZviVIQ2IKCwcgeWopbSTbSAeAujSkTOrpYccLmVAlsAm(cfdyNNagYmb2YgjcLuAXJvPfn6RJWjQeuLtheaJZDadzMaBzJeHskT4XQ0Ig91r4evctbNQTaW8saBfaBza78eWQwQFzpUva7YoGXXko6bvTfoA(gQ(cZWUYTWH482rRX4luSBlhnc2Lc7XrNRvcRslA0xhHtuPbv9vfWwdy5ALWQ0Ig91r4evcQYPdcGDzhW4yfaZlbmpimGTKbSmbS1a2Qa22aMsiAG001M0w8g)NRqEfvTfj5SemiGDEcyBdy1i0OsyvArJEKfekzE1wK0y8fkgWopbmKzcSLnsekP0IhRslA0xhHtujOkNoiagN7agYmb2YgjcLuAXJvPfn6RJWjQeMcovBbG5La2ka2Yo6bvTfoAFHz434)6wFnu5rx5wGJdCE7O1y8fk2TLJgb7sH94O9P45tIMx9fMHtKAqlcyxaSmbS1a2QawUwjSkTOrFDeorLgu1xvaBnGTkGTnGPeIginDTjTfVX)5kKxrvBrsolbdcyNNa22awncnQewLw0OhzbHsMxTfjngFHIbSZtadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGX5oGHmtGTSrIqjLw8yvArJ(6iCIkHPGt1wayEjGTcGTmGDEcyvl1VSh3kGDzhW4yfaBzh9GQ2chDwdkWx1oEOsSycK6k3cCWHZBhTgJVqXUTC0iyxkShhDUwjSkTOrFDeorLgu1xvaBnGTkGTnGPeIginDTjTfVX)5kKxrvBrsolbdcyNNa22awncnQewLw0OhzbHsMxTfjngFHIbSZtadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGX5oGHmtGTSrIqjLw8yvArJ(6iCIkHPGt1wayEjGTcGTmGDEcyvl1VSh3kGDzhW4yfh9GQ2chnSZZf63XtYhK6k3cCWTZBhTgJVqXUTC0dQAlC05gArTiTxO4hzYCQAQ2IhRxBK6OrWUuypoAKzcSLnsekP0IhRslA0xhHtujOkNoiagN7ag3hayRbmKzcSLnsekP0IhRslA0xhHtujOkNoia2LDadzMaBzJeHskT4XQ0Ig91r4evctbNQTaW8saJJvaSZtaRAP(L94wbSl7awMh4OJrQo6CdTOwK2lu8JmzovnvBXJ1RnsDLBboY05TJwJXxOy3wo6bvTfoAOviifPu8F1mSzp2echnc2Lc7XrVkGHmtGTSrIqjLw8yvArJ(6iCIkbv50bbW4ChW4Efa78eWQwQFzpUva7YoGL5ba2Yo6yKQJgAfcsrkf)xndB2JnHWvUf44WoVD0Am(cf72YrpOQTWrtU7Rk8VQHjFOkAKJgb7sH94OxfWqMjWw2irOKslESkTOrFDeorLGQC6GayCUdyCVcGDEcyvl1VSh3kGDzhWY8aaBzhDms1rtU7Rk8VQHjFOkAKRClWXkoVD0Am(cf72YrpOQTWrplPuDUvAuFmuvlOioAeSlf2JJEvadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGX5oGX9ka25jGvTu)YECRa2LDalZdaSLD0Xivh9SKs15wPr9XqvTGI4k3cCSuoVD0Am(cf72YrpOQTWrxnwjLbLpYWQx7OrWUuypo6vbmKzcSLnsekP0IhRslA0xhHtujOkNoiagN7ag3RayNNaw1s9l7XTcyx2bSmpaWw2rhJuD0vJvszq5JmS61UYTahlnN3oAngFHIDB5Ohu1w4OV2J4n(NugusC0iyxkShh9QagYmb2YgjcLuAXJvPfn6RJWjQeuLtheaJZDaJ7vaSZtaRAP(L94wbSl7awMhayl7OJrQo6R9iEJ)jLbLex5wGJLOZBhTgJVqXUTC0iyxkShh92awncnQuO1Tc)CdwJiPX4lumGTgWQwQa2falZdaS1a22agYmb2YgjcLuAXJvPfn6RJWjQeuLtheh9GQ2chnAeIFqvBXlAs5OfnP(yKQJ2Y1qHUYTahhIZBhTgJVqXUTC0dQAlC0JxqUh4qEElQ34)ClRcD0iyxkShh9Qaw1sfW4eWY8aa78eW2gWQrOrLcTUv4NBWAejngFHIbSLbS1awncnQKhylTgQpVk8qnqCsJXxOyaBnGTkGvTu)YECRagNaghCFaGDEcyvl1VSh3kGDbWqMjWw2irOKslESkTOrFDeorLGQC6GayzayCScGTmGDEcyvl1VSh3kGDzhWYCfhDms1rpEb5EGd55TOEJ)ZTSk0vUf4(aN3oAngFHIDB5OrWUuypo6XluyxAs96CHr6R6NBLgvpIeCIfbS1aw1sfWUayRayRbmIrjEY9aXagNag3a2AaZNINpPEDUWi9v9ZTsJQhrcBzdaBnG5tXZNY2c83YCsIudAra7cGLjGTgW2gWYH613dcN4iDpb(n(3dLapbGTgW2gWYH613dcN4oDpb(n(3dLapHJEqvBHJ(Ec8B8VhkbEcx5wGBoCE7O1y8fk2TLJgb7sH94OjgL4j3dedyx2bSmbS1aMpfpFcRslA0JmOMOYbS1aMpfpFcRslA0JmOMi1GweW2bSd7Ohu1w4OXQ0cFtuUYTa3C782rRX4luSBlhnc2Lc7XrpEHc7stQxNlmsFv)CR0O6rKGtSiGTgW8P45tzBb(BzojrQbTiGXjGXnGTgW8P45tQxNlmsFv)CR0O6rKGQC6GayxaSbvTfjY9GTSVVjQK61kIQ0VAPcyRbSvbSTbSAeAujSkTOrpYccLmVAlsAm(cfdyNNagYmb2YgjcLuAXJvPfn6RJWjQeuLtheaJtaJdUbSLD0dQAlC0TmxyK2cx5wG7mDE7O1y8fk2TLJgb7sH94O3gWQgTyhEaS1aw1s9l7XTcyCcyzEaGTgWi5Qq81a9Ofj1YCHrAlaSlag3a2AaBBaZNINpfADRWp3G1isqvoDqC0dQAlC0yZKUYTa3h25TJEqvBHJMGmkyhE(QRB1rRX4luSBlx5wG7vCE7Ohu1w4OXkQLt1HN33eLJwJXxOy3wUYTa3lLZBhTgJVqXUTC0iyxkShh9GQ(Q(AOYwjagNawMo6bvTfoAIrjEOvUYTa3lnN3o6bvTfo6wMRbUdppAQHuql)wD0Am(cf72YvUf4Ej682rRX4luSBlhnc2Lc7XrpEHc7stQxNlmsFv)CR0O6rKGtSiGXjGDaGTgWQwQa2faJJdaS1agjxfIVgOhTiPwMlmsBbGDbW4gWwdy(u88jmuhmPgXIkKKGQC6GayRbSAeAuPqRBf(5gSgrsJXxOyh9GQ2chTFlucYOGE033K(kK4k3cCFioVD0Am(cf72YrJGDPWEC0Rcy(u88PSTa)TmNKi1GweWUaylfGDEcy(u88jSkTOrFULvHjQCaBza78eWi5Qq81a9Ofj1YCHrAlaSlag3o6bvTfoASkTOrpPGA4PUDLBHmpW5TJwJXxOy3woAeSlf2JJUgHgvk06wHFUbRrK0y8fkgWwdyKCvi(AGE0IKAzUWiTfa2LDaJBh9GQ2chnAeIFqvBXlAs5OfnP(yKQJo06wHFUbRr4k3czYHZBhTgJVqXUTC0iyxkShhnjxfIVgOhTiPwMlmsBbGXjGXbGTgWqMjWw2irOKslESkTOrFDeorLGQC6G4Ohu1w4OrJq8dQAlErtkhTOj1hJuD0TmxyK2cx5witUDE7O1y8fk2TLJgb7sH94OrMjWw2irOKslESkTOrFDeorLGQC6Gayx2bmowbWopbSQL6x2JBfWUSdyzEGJEqvBHJ2d1aX9eVX)JxOqRUDLBHmZ05TJwJXxOy3woAeSlf2JJEvaRAP(L94wbmobmo4(aa78eWQwQFzpUva7cGHmtGTSrIqjLw8yvArJ(6iCIkbv50bbWYaW4yfa78eWqMjWw2irOKslESkTOrFDeorLGQC6GayxamoYeWw2rpOQTWr7b2sRH6ZRcpude7k3czEyN3oAngFHIDB5OrWUuypoAKzcSLnsekP0IhRslA0xhHtujOkNoiagNa2HpaWopbmKzcSLnsekP0IhRslA0xhHtujOkNoia2faJdUD0dQAlC0ekP0I)Alu(wdSRClK5koVD0Am(cf72YrJGDPWEC0RcyiZeylBKiusPfpwLw0OVocNOsqvoDqaSla2HayRbmFkE(ewLw0OhncrhEsqvoDqaSLbSZtaBvadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGDbW4GdaBnGTnG5tXZNWQ0Ig9Ori6WtcQYPdcGTmGDEcyiZeylBKiusPfpwLw0OVocNOsqvoDqamobmooSJEqvBHJgncXJH6Gj1iwuHex5wiZLY5TJwJXxOy3woAeSlf2JJ2NINpbv0IcLqEEdI0euhu5Ohu1w4ORB9PcFJkWpVbrQRClK5sZ5TJEqvBHJ2Vfkbzuqp67BsFfsC0Am(cf72YvUfYCj682rRX4luSBlhnc2Lc7XrVkGnEHc7st(Jq5PeFhxn0uTfjngFHIbSZtaRgHgvcRslA0JSGqjZR2IKgJVqXa2Ya2AalhQxFpiCIJ09e434Fpuc8ea2AadzMaBzJeHskT4XQ0Ig91r4evcQYPdcGDbW42rpOQTWrFpb(n(3dLapHRClK5H482rRX4luSBlhnc2Lc7XrtmkXtUhigWUayzcyRbSvbSTbSAeAujSkTOrpYccLmVAlsAm(cfdyNNaMpfpFkBlWFlZjjsnOfbSmaSwMtEs(Knu8JPGD4jrOKslESkTOrFDeorbyCUdylfGTgWQwQFzFlZjPrisqvoDqaSlagAi1xTubSLbSZtaRAP(L94wbSlag3h4Ohu1w4OjusPfpwLw0OVocNOCLBHdFGZBhTgJVqXUTC0iyxkShhTpfpFkBlWFlZjjsnOfbmo3bmUbS1aMpfpFcRslA0JmOMi1GweWUSdyCdyRbmFkE(ewLw0Op3YQWe2Yga2AaJKRcXxd0JwKulZfgPTaWUayC7Ohu1w4OZTSk8jD(TfUYTWH5W5TJwJXxOy3woAeSlf2JJUgHgvcBMmPX4lumGTgWGkpuj3JVqbS1aw1s9l7XTcyCcyRcyyRsyZKjOkNoiawgawMhayl7Ohu1w4OXMjDLBHdZTZBhTgJVqXUTC0iyxkShhnXOep5EGyaJZDaBfa78eWwfWigL4j3dedyCUdyzcyRbmKzcSLnsOriEmuhmPgXIkKKGQC6GayCcyhgWwdyRcyiZeylBKiusPfpwLw0OVocNOsqvoDqamobmUpaWopbSvbmKzcSLnsekP0IhRslA0xhHtujOkNoia2faZdcdylzaJBaBnGvJqJkHvPfn6rwqOK5vBrsJXxOya78eWqMjWw2irOKslESkTOrFDeorLGQC6GayxampimGTKbSddyRbSTbSAeAujSkTOrpYccLmVAlsAm(cfdyldyldyRbSvbSTbSAeAujcLuAXFTfkFRboPX4lumGDEcyiZeylBKiusPf)1wO8Tg4euLtheaJtaltaBzaBzh9GQ2ch99e434Fpuc8eUYTWHZ05TJwJXxOy3woAeSlf2JJMyuINCpqmGDbWwbWwdy(u88jSkTOrpYGAIudAra7YoGXTJEqvBHJMyuINuWEr1vUfo8HDE7O1y8fk2TLJgb7sH94OjgL4j3dedyx2bSmbS1aMpfpFcRslA0JmOMOYbS1a2Qa2QagYmb2YgjcLuAXJvPfn6RJWjQeuLthea7cGTua25jGHmtGTSrIqjLw8yvArJ(6iCIkbv50bbW4eW4MBaBnGTnGnEHc7stK7bBzjVFxAsJXxOyaBza78eW8P45tyvArJEKb1ePg0IagN7awMa25jG5tXZNWQ0Ig9idQjOkNoia2faBfa78eWQwQFzpUva7cGX9ka25jG5tXZNi3d2YsE)U0euLtheaBzh9GQ2chnwLw4BIYvUfo8koVD0Am(cf72YrJGDPWEC0Bdy5ALWQ0Ig91r4evAqvFvD0dQAlC08gIIO4F8cf2L((6iDLBHdVuoVD0dQAlC05uWM)yhEEFXqkhTgJVqXUTCLBHdV0CE7Ohu1w4O9fMHFJ)RB91qLhD0Am(cf72YvUfo8s05TJwJXxOy3woAeSlf2JJEBadBvczbsJcoLIFEXi13NcgjOkNoia2AaBBaBqvBrczbsJcoLIFEXi1uhpVO9Cxa2AaBBalxRewLw0OVocNOsdQ6RQJEqvBHJgzbsJcoLIFEXivx5w4WhIZBhTgJVqXUTC0iyxkShh92awUwjSkTOrFDeorLgu1xvh9GQ2chnuN8o888IrQex5wyLdCE7O1y8fk2TLJEqvBHJgncXpOQT4fnPC0IMuFms1r7t1c8pp5EGyx5khDourM0FkN3Uf4W5TJEqvBHJMqjLw88QWd1aXoAngFHIDB5k3cC782rRX4luSBlhnc2Lc7Xr7tXZNY2c83YCsIudAraJtaJdaBnG5tXZNWQ0Ig9idQjsnOfbSl7ag3o6bvTfo6ClRcFsNFBHRClKPZBh9GQ2chDUvTfoAngFHIDB5k3ch25TJwJXxOy3woAeSlf2JJ23iea78eWgu1wKWQ0cFtuj0qkaBhWoWrpOQTWrJvPf(MOCLBHvCE7Ohu1w4Oj3d2Y((MOC0Am(cf72YvUYrhADRWp3G1iCE7wGdN3oAngFHIDB5OrWUuypoAKzcSLnsHw3k8ZnynIeuLthea7cGX9bo6bvTfoA0ie)GQ2Ix0KYrlAs9XivhDO1Tc)CdwJ49PAbUdpUYTa3oVD0Am(cf72YrJGDPWEC0(u88PqRBf(5gSgrIk3rpOQTWrJgH4hu1w8IMuoArtQpgP6OdTUv4NBWAe)GQ(Q6kx5OdTUv4NBWAeVpvlWD4X5TBboCE7O1y8fk2TLJEqvBHJE8cY9ahYZBr9g)NBzvOJgb7sH94OrMjWw2ifADRWp3G1isqvoDqaSl7a2ka2sgWi5Qq83dPuhDms1rpEb5EGd55TOEJ)ZTSk0vUf425TJwJXxOy3woAeSlf2JJEBadzMaBzJuO1Tc)CdwJibv50bbWwdyeJs8K7bIbmo3bSvC0dQAlC0EOgiUN4n(F8cfA1TRClKPZBhTgJVqXUTC0iyxkShhnXOep5EGyaJZDaBfh9GQ2chDO1Tc)CdwJWvUfoSZBhTgJVqXUTC0iyxkShhD1sfW4ChWY8ah9GQ2chnAeIhd1btQrSOcjUYTWkoVD0Am(cf72YrJGDPWEC0vlvaJZDalZdaS1agYmb2Ygj0iepgQdMuJyrfssqvoDqamobmowIa2AaJyuINCpqmGX5oGLPJEqvBHJ(Ec8B8VhkbEcx5wyPCE7O1y8fk2TLJgb7sH94ORwQagN7awMhayRbmFkE(u2wG)wMtsKAqlcyCUdyCdyRbmFkE(ewLw0OhzqnrQbTiGDzhW4gWwdy(u88jSkTOrFULvHjSLnaS1agXOep5EGyaJZDalth9GQ2chDULvHpPZVTWvUfwAoVD0Am(cf72YrJGDPWEC0vlvaJZDalZdaS1agXOep5EGyaJZDaBfh9GQ2ch99e434Fpuc8eUYTWs05TJwJXxOy3wo6bvTfoA0ie)GQ2Ix0KYrlAs9XivhTpvlW)8K7bIDLRC0(uTa)ZtUhi25TBboCE7O1y8fk2TLJgb7sH94OjgL4j3dedyxamUD0dQAlC0svAWJVX)ckuJFmuhjXvUf425TJwJXxOy3woAeSlf2JJEBaRgHgvcRslA0JSGqjZR2IKgJVqXa25jGvTubmobmowbWopbSCOE99GWjos3tGFJ)9qjWtayRbSTbmFkE(KVWmSGIujOkNoio6bvTfoAIrjEsb7fvx5witN3o6bvTfoAY9GTSVVjkhTgJVqXUTCLRC0Hw3k8ZnynIFqvFvDE7wGdN3o6bvTfoA)wOeKrb9OVVj9viXrRX4luSBlx5wGBN3oAngFHIDB5OrWUuypoAKzcSLnsekP0IhRslA0xhHtujOkNoia2faJJmbSZtaBBatxsP68CfNY2cEOIjpP90I34FcvUcBd(ekP0Io84Ohu1w4O9aBP1q95vHhQbIDLBHmDE7O1y8fk2TLJgb7sH94OrMjWw2irOKslESkTOrFDeorLGQC6GayCcyh(aa78eWqMjWw2irOKslESkTOrFDeorLGQC6Gayxamo42rpOQTWrtOKsl(RTq5BnWUYTWHDE7O1y8fk2TLJgb7sH94OxfWqMjWw2irOKslESkTOrFDeorLGQC6GayxaSdbWwdy(u88jSkTOrpAeIo8KGQC6GayldyNNa2QagYmb2YgjcLuAXJvPfn6RJWjQeuLthea7cGXbha2AaBBaZNINpHvPfn6rJq0HNeuLtheaBza78eWqMjWw2irOKslESkTOrFDeorLGQC6GayCcyCCyh9GQ2chnAeIhd1btQrSOcjUYTWkoVD0Am(cf72YrJGDPWEC0eJs8K7bIbSDaJdaBnGTkGHmtGTSrcncXJH6Gj1iwuHKeuLthea7cGnOQTirUhSL99nrLqdP(QLkGDEcyRcy1i0Os(TqjiJc6rFFt6RqssJXxOyaBnGHmtGTSrYVfkbzuqp67BsFfssqvoDqaSla2GQ2Ie5EWw233evcnK6RwQa2Ya2Yo6bvTfoA0ie)GQ2Ix0KYrlAs9XivhTpvlW)8K7bIDLBHLY5TJwJXxOy3woAeSlf2JJEvaBvadzMaBzJeAeIhd1btQrSOcjjOkNoiagNa2GQ2IewLw4BIkHgs9vlvaBzaBnGTkGHmtGTSrcncXJH6Gj1iwuHKeuLtheaJtaBqvBrICpyl77BIkHgs9vlvaBzaBzaBnGHmtGTSrk06wHFUbRrKGQC6GayCcyRcyCSuRayzaydQAls3tGFJ)9qjWtKqdP(QLkGTSJEqvBHJ(Ec8B8VhkbEcx5wyP582rRX4luSBlhnc2Lc7Xr7tXZNcTUv4NBWAejOkNoia2faBfaBnGrmkXtUhigW2bSdC0dQAlC0ekP0IhRslA0xhHtuUYTWs05TJwJXxOy3woAeSlf2JJ2NINpfADRWp3G1isqvoDqaSla2GQ2IeHskT4XQ0Ig91r4evcnK6RwQawga2bPvC0dQAlC0ekP0IhRslA0xhHtuUYTWH482rRX4luSBlhnc2Lc7Xr7tXZNWQ0Ig9idQjQCaBnGrmkXtUhigWUSdyz6Ohu1w4OXQ0cFtuUYTahh482rRX4luSBlh9GQ2chnAeIFqvBXlAs5OfnP(yKQJ2NQf4FEY9aXUYvUYvUY5a]] )


end
