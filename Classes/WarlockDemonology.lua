-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] borne_of_blood
-- [-] carnivorous_stalkers
-- [-] fel_commando
-- [x] tyrants_soul


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
                    --[[ table.wipe( guldan ) -- wipe incoming imps, too.
                    table.wipe( wild_imps )
                    table.wipe( imps ) ]]

                end

            end

        elseif imps[ source ] and subtype == "SPELL_CAST_START" then
            local demonic_power = FindUnitBuffByID( "player", 265273 )

            if not demonic_power then
                local imp = imps[ source ]

                imp.start = now
                imp.casts = imp.casts + 1

                imp.expires = min( imp.max, now + ( ( ( level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
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
                return buff.demonic_calling.up and 0 or ( ( level > 53 and 1.5 or 2 ) * haste )
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
                removeStack( "decimating_bolt" )
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
                if conduit.demonic_momentum.enabled then applyBuff( "demonic_momentum" ) end
            end,

            auras = {
                -- Conduit
                demonic_momentum = {
                    id = 339412,
                    duration = 5,
                    max_stack = 1
                }
            }
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

            finish = function ()
                if conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
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
            cooldown = function () return 180 + conduit.fel_celerity.mod * 0.001 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237564,

            essential = true,
            
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
                if level > 57 then gain( 5, "soul_shards" ) end
            end,

            auras = {
                -- Conduit
                -- Note:  Should set up a queued event for this to start when Tyrant finishes.
                tyrants_soul = {
                    id = 339766,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        summon_felguard = {
            id = 30146,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
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
                removeBuff( "fel_domination" )
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

    spec:RegisterPack( "Demonology", 20201013, [[dq0wTaqiOsEKukTjOQ(KQKKgLQeNskvRsvsrVsvPzjGUfqu7sHFPkmmOIJjaltq1ZKsX0eu6AsjTnvjX3euKXbePZPkPADckQ5bvQ7bu7tkXbbIOwiq6HckKjkOGlceroPQKuTsbzMQsszNQk(PQKsdvqH6PkAQQI(QQKe7vL)sQblvhw0Ib1JrmzsUmXMb8zOy0QQoTsVgimBuUTq7MYVLmCPy5qEoQMovxhKTdv57QsnEvjfoVaTEGimFO0(r6lG75nvPl3NWXjCCcaNaAZaNxpS4e(n9GnYnBscismYnTmk3mmiXYkwHj4nBYGSkv3ZBYlierU5V7n8W8Jhyw)hcEqQ4d(gHyPVLrqjG)GVrYJBcdTm)v3o4BQsxUpHJt44eaob0MboVEyXjGx)M8gHCFc)vELB(VkLyh8nvcNCZ2s7HbjwwXkmbP9xLeXkciOHAlT)7Edpm)4bM1)HGhKk(GVriw6Bzeuc4p4BK8GgQT0(RL4fSGO9aAtG0E44eoo0q0qTL2dJ(tdJWdZ0qTL2bzAF2imgT)QveqmOHAlTdY0(R1ybPDKqQyumfThgKyzWfZP9gKaYKkcNoTVa0(60(YP914EAoT)sHO9)ePij3PDGcr7WfNl82h0qTL2bzApmUEliAFUn)Lr7jJvVffT3GeqMur40PDVO9gurO914EAoThgKyzWfZh0qTL2bzA)PeBkuIcs7BSHjrX803YO9cG2Fv9GO0CnssvWxvAhVeTjmtg3SbvaltUzBP9WGelRyfMG0(RsIyfbe0qTL2)DVHhMF8aZ6)qWdsfFW3iel9Tmckb8h8nsEqd1wA)1s8cwq0EaTjqApCCchhAiAO2s7Hr)PHr4HzAO2s7GmTpBegJ2F1kcig0qTL2bzA)1ASG0osivmkMI2ddsSm4I50EdsazsfHtN2xaAFDAF50(ACpnN2FPq0(FIuKK70oqHOD4IZfE7dAO2s7GmThgxVfeTp3M)YO9KXQ3II2BqcitQiC60Ux0EdQi0(ACpnN2ddsSm4I5dAiAO2s7GKEnecKlkAhwakKq7KkcNoTdlywJpODqYeI04CA3kdK)tueaIr7jX3Y40EzSGdAOK4Bz8rdsiveo9VGFaimTQIRL(wwGlayFJsl4GpUAeFKSfpHgkj(wgF0GesfHt)l4hCOySmDJ40qjX3Y4JgKqQiC6Fb)OPElinFB(llWfammeaW49Yu6n2WhCpjGOLaWhgcayOKyzlrtkKm4EsabUbhonus8Tm(ObjKkcN(xWpusSm4I5bUaGHlohl2K4BzdLeldUy(GKChmo0qjX3Y4JgKqQiC6Fb)G)NQ6TgUyonus8Tm(ObjKkcN(xWpWlrBcZKaTmkG9GO0CnssvWaXlzqcysvmv92gCOySmTsILTeTheLMpqsmxJJ7wX)fC5jtmFOQkoelHzIclwLadbamuvfhqnTJ)lWqaadLelBjAUJedJ)pGAWIfxEYeZhkjw2s0Chjgg)FiwcZefwSEYeZhkjw2s0KY4qXgFlBiwcZev74)cU8KjMpmX)fKUPqEYgILWmrHflmeaWWe)xq6Mc5jBa1GflPkMQEBdt8FbPBkKNSbsI5A8wcO12X)fC5jtmFGbTXArIgqyyGsKAiwcZefwSKQyQ6TnWG2yTirdimmqjsnqsmxJ3saT2o(VGlpzI5doumwMgVLjaRyQHyjmtuyXsQIPQ32GdfJLPXBzcWkMAGKyUgVLaATD8FbxEYeZhkjw2s0KY4qXgFlBiwcZefwSWqaaJ3ltP3ydFa1GflVGyA(FIuGBflwyiaGHj(VG0nfYt2aQbFEbX08)ePAbN2PHOHAlTds61qiqUOODbpbfK29nk0U)l0Es8cr7lN2t8YLLWmzqdLeFlJdM3imMMveqqdLeFlJ)f8dLGxbH0XeZsOHsIVLX)c(bjzmDs8TmnB5EGwgfWfaGgdrrdLeFlJ)f8dsYy6K4BzA2Y9aTmkGfoxmIWPHsIVLX)c(bcY0jX3Y0SL7bAzua7brP56gK0ei3rlXbhqGlaysvmv92gCOySmTsILTeTheLMpqsmxJJ7wXhx4LOnHzYWdIsZ1ijvbPHsIVLX)c(bcY0jX3Y0SL7bAzuaZHIXY0EquAEGChTehCabUaGXlrBcZKHheLMRrsQcsdLeFlJ)f8doPGqRHr7R)l0qjX3Y4Fb)yJnIPwdJMKEYDu18l0qjX3Y4Fb)GxqmnQ8axaWjXx8eTysCfElbqdLeFlJ)f8dLq2y6RHrdxmpWfa8lEIWi(4xsM)RBioUBfhSybwm)UgjXCnElTIt70qjX3Y4Fb)GdfJLPXBzcWkMkWfamPkMQEBdoumwMwjXYwI2dIsZhijMRXBjS4GflWI531ijMRXXnPkMQEBdoumwMwjXYwI2dIsZhijMRX)gER0qjX3Y4Fb)GKmMwHKuX9KbcbXPHsIVLX)c(HQQyGlayKaGe(FcZeAOK4Bz8VGFOKyzlrZDKyy8FAOK4Bz8VGFaVmHtkiegrdxrybXPHsIVLX)c(XFAkDbOXaXuPf4caMxqmn)prkWTIflmeaWWe)xq6Mc5jBa1qdLeFlJ)f8J)0u6cqJbIPslWfamVGyA(FIuTaUn4tQIPQ32GdfJLPvsSSLO9GO08bsI5A8wchh8FHuftvVTbhkgltJ3YeGvm1ajXCnElTIflU8KjMp4qXyzA8wMaSIPgILWmr1o(KQyQ6TnijJPvijvCpzGqq8bsI5A8wcNgkj(wg)l4hkjwgCX8axaWWqaadLelBjAsHKbssIJpVGyA(FIu4oS0qjX3Y4Fb)adAJ1IenGWWaLivGlaysvmv92gCOySmTsILTeTheLMpqsmxJ)LuftvVTbhkgltRKyzlr7brP5dfek9TSwawm)UgjXCnowSalMFxJKyUgh3KQyQ6Tn4qXyzALelBjApiknFGKyUg)BaTsdLeFlJ)f8diUOxxICAOK4Bz8VGF0uVfKMVn)Lf4caggcay8Ezk9gB4dUNeq0sa4ddbamusSSLOjfsgCpjGa3THgkj(wg)l4h8cIP5oAbHqdLeFlJ)f8d(FQQ3A4I50q0qjX3Y4dHZfJiCWVletHNSMgj8YsJi0qjX3Y4dHZfJi8VGFeLyHcQlandISkTcjzKtdLeFlJpeoxmIW)c(bmRkLUa0(VOftIbPHsIVLXhcNlgr4Fb)aduIuBA6cqNGecQ8FAOK4Bz8HW5Ire(xWpqBtdt0RP5njrOHsIVLXhcNlgr4Fb)aOiqCrPtqcbTUOHLmsdLeFlJpeoxmIW)c(rdeAbcUggnml5onus8Tm(q4CXic)l4hijBwdJgGLrHh4ca2tegXh)sY8FDdXBbKIdwSEIWi(4xsM)RBioUdhhSybwm)UgjXCnoUBdoyX6jcJ4dFJI2lDdX1HJtlHfhAOK4Bz8HW5Ire(xWpiLreZrPlknalJcnus8Tm(q4CXic)l4h(VOHm4cYuAGcrKaxaWWqaadKqabt4CnqHiYajXCnonenus8Tm(Oaa0yikWWcIliqSgMaxaWnIpusSSLO9GO08rs8fpHgkj(wgFuaaAme1xWpAkFllWfammeaWawqCbbI1WmGAWITr8HsILTeTheLMpsIV4j4JlusKHJkgJgkj(wgFuaaAme1xWpGzvP0aqOGbUaGBeFOKyzlr7brP5JK4lEcnus8Tm(Oaa0yiQVGFaSibMvLkWfaCJ4dLelBjApiknFKeFXtOHOHsIVLXhCOySmTheLMd(pnLUa0yGyQ0cCbaZliMM)Nif4wdKTMOjkWHJdnus8Tm(GdfJLP9GO08VGFOKyzWfZdCbaddbamusSSLOjfsgqn4)INmX8HsILTenPmouSX3YgILWmrHflmeaWWe)xq6Mc5jBOQ3w7bYwt0ef4WXHgkj(wgFWHIXY0EquA(xWp4)PQERHlMh4caggcay8Ezk9gB4dUNeq8DnsfxdJEJnCChw8FXtMy(qjXYwIMughk24BzdXsyMOWIfgcayyI)liDtH8Knu1BR9azRjAIcC44qdLeFlJp4qXyzApikn)l4hKKX0kKKkUNmqiionus8Tm(GdfJLP9GO08VGF8NMsxaAmqmvA0qjX3Y4doumwM2dIsZ)c(HsILbxmpWfammeaWqjXYwIMuiza1GpmeaWWe)xq6Mc5jBa1G)lVadbamWBzcWkMAGKyUgVLwXIfxEYeZhCOySmnEltawXudXsyMOAh)xGHaagyqBSwKObeggOePgijMRXBPvSyHHaagyqBSwKObeggOePgQ6T1E70qjX3Y4doumwM2dIsZ)c(b)pv1BnCX8axaWWqaadt8FbPBkKNSbud(V8cmeaWaVLjaRyQbsI5A8wAflwC5jtmFWHIXY04TmbyftnelHzIQD8FbgcayGbTXArIgqyyGsKAGKyUgVLwXIfgcayGbTXArIgqyyGsKAOQ3w7Ttd1wApj(wgFWHIXY0EquA(xWpWlrBcZKaTmkG9GO0CnssvWaXlzqcyCrQIPQ32GdfJLPvsSSLO9GO08bssvqAOK4Bz8bhkglt7brP5Fb)GdfJLPvsSSLO9GO08axaW8cIP5)jsXbJdnus8Tm(GdfJLP9GO08VGFW)tv9wdxmNgIgkj(wgF4brP56gK0awvvmq2AIMOa3gCOHsIVLXhEquAUUbjnFb)qjXYwIM7iXW4)bUaGXLNmX8HsILTenPmouSX3YgILWmrrdLeFlJp8GO0CDdsA(c(Hj(VG0nfYtgnus8Tm(WdIsZ1niP5l4hyqBSwKObeggOePOHsIVLXhEquAUUbjnFb)GdfJLPXBzcWkMIgkj(wgF4brP56gK08f8dsYyAfssf3tgieeNgkj(wgF4brP56gK08f8dLeldUyEGlayyiaGHsILTenPqYaQbFEbX08)ePWDyX)fpzI5dLelBjAszCOyJVLnelHzIclwyiaGHj(VG0nfYt2qvVT2PHsIVLXhEquAUUbjnFb)G)NQ6TgUyEGlayEbX08)ePWDRGCyFnHHaagM4)cs3uipzdOgAO2s7jX3Y4dpiknx3GKMVGFGxI2eMjbAzua7brP5AKKQGbIxYGeWbqdLeFlJp8GO0CDdsA(c(XFAkDbOXaXuPDt8eeFl7(eooHJta4eq438DIS1WWV5RESPqUOO9xH2tIVLr7SL78bn0nzl353ZBkCUyeHFpVpbCpVzs8TSB(UqmfEYAAKWllnICtXsyMOoqp)(e(98MjX3YUzuIfkOUa0miYQ0kKKr(nflHzI6a987tBUN3mj(w2nHzvP0fG2)fTysm4nflHzI6a987tyVN3mj(w2nXaLi1MMUa0jiHGk))MILWmrDGE(9P175ntIVLDt020We9AAEtsKBkwcZe1b653Nx5EEZK4Bz3eOiqCrPtqcbTUOHLmEtXsyMOoqp)(eMUN3mj(w2nBGqlqW1WOHzj3VPyjmtuhONFFaP3ZBkwcZe1b6njO1f0M30tegXh)sY8FDdXP9wODqko0owS0UNimIp(LK5)6gIt74M2dhhAhlwAhyX87AKeZ140oUP92GdTJflT7jcJ4dFJI2lDdX1HJdT3cThwCUzs8TSBIKSznmAawgf(53Nx)EEZK4Bz3KugrmhLUO0aSmk3uSeMjQd0ZVpbGZ98MILWmrDGEtcADbT5nHHaagiHacMW5AGcrKbsI5A8BMeFl7M(VOHm4cYuAGcrKZp)MkbiHy(98(eW98MjX3YUjVrymnRiG4MILWmrDGE(9j875ntIVLDtLGxbH0XeZsUPyjmtuhONFFAZ98MILWmrDGEZK4Bz3KKmMoj(wMMTC)MSL7AlJYnlaangI687tyVN3uSeMjQd0BMeFl7MKKX0jX3Y0SL73KTCxBzuUPW5Ire(53NwVN3uSeMjQd0BsqRlOnVjPkMQEBdoumwMwjXYwI2dIsZhijMRXPDCt7Ts74t74I2XlrBcZKHheLMRrsQcEtUJwIFFc4MjX3YUjcY0jX3Y0SL73KTCxBzuUPheLMRBqsZ53Nx5EEtXsyMOoqVjbTUG28M4LOnHzYWdIsZ1ijvbVj3rlXVpbCZK4Bz3ebz6K4BzA2Y9BYwURTmk3KdfJLP9GO08ZVpHP75ntIVLDtoPGqRHr7R)l3uSeMjQd0ZVpG075ntIVLDZn2iMAnmAs6j3rvZVCtXsyMOoqp)(863ZBkwcZe1b6njO1f0M3mj(INOftIRWP9wO9aUzs8TSBYliMgv(53NaW5EEtXsyMOoqVjbTUG28MVq7EIWi(4xsM)RBioTJBAVvCODSyPDGfZVRrsmxJt7Tq7TIdT3(ntIVLDtLq2y6RHrdxm)87tabCpVPyjmtuhO3KGwxqBEtsvmv92gCOySmTsILTeTheLMpqsmxJt7Tq7HfhAhlwAhyX87AKeZ140oUPDsvmv92gCOySmTsILTeTheLMpqsmxJt7FP9WB9MjX3YUjhkgltJ3YeGvm153Nac)EEZK4Bz3KKmMwHKuX9KbcbXVPyjmtuhONFFcOn3ZBkwcZe1b6njO1f0M3ejaiH)NWm5MjX3YUPQQ453Nac798MjX3YUPsILTen3rIHX)VPyjmtuhONFFcO175ntIVLDt4LjCsbHWiA4kcli(nflHzI6a987taVY98MILWmrDGEtcADbT5n5fetZ)tKI2bt7Ts7yXs7Wqaadt8FbPBkKNSbuZntIVLDZ)0u6cqJbIPs787taHP75nflHzI6a9Me06cAZBYliMM)NifT3cyAVn0o(0oPkMQEBdoumwMwjXYwI2dIsZhijMRXP9wO9WXH2XN2FH2jvXu1BBWHIXY04TmbyftnqsmxJt7Tq7Ts7yXs74I29KjMp4qXyzA8wMaSIPgILWmrr7Tt74t7KQyQ6TnijJPvijvCpzGqq8bsI5ACAVfAp8BMeFl7M)PP0fGgdetL253NaaP3ZBkwcZe1b6njO1f0M3egcayOKyzlrtkKmqssCAhFANxqmn)prkAh30EyVzs8TSBQKyzWfZp)(eWRFpVPyjmtuhO3KGwxqBEtsvmv92gCOySmTsILTeTheLMpqsmxJt7FPDsvmv92gCOySmTsILTeTheLMpuqO03YO9wODGfZVRrsmxJt7yXs7alMFxJKyUgN2XnTtQIPQ32GdfJLPvsSSLO9GO08bsI5ACA)lThqR3mj(w2nXG2yTirdimmqjsD(9jCCUN3mj(w2nH4IEDjYVPyjmtuhONFFcpG75nflHzI6a9Me06cAZBcdbamEVmLEJn8b3tciO9wO9aOD8PDyiaGHsILTenPqYG7jbe0oUP92CZK4Bz3SPElinFB(l787t4HFpVzs8TSBYliMM7OfeYnflHzI6a987t4T5EEZK4Bz3K)NQ6TgUy(nflHzI6a98ZVzdsiveo9759jG75nflHzI6a9Me06cAZB6BuO9wODCOD8PDCr7nIps2INCZK4Bz3eqyAvfxl9TSZVpHFpVzs8TSBYHIXY0acdduIu3uSeMjQd0ZVpT5EEtXsyMOoqVjbTUG28MWqaaJ3ltP3ydFW9KacAVfApaAhFAhgcayOKyzlrtkKm4EsabTJBW0E43mj(w2nBQ3csZ3M)Yo)(e275nflHzI6a9Me06cAZBcxCoTJflTNeFlBOKyzWfZhKK70oyAhNBMeFl7MkjwgCX8ZVpTEpVzs8TSBY)tv9wdxm)MILWmrDGE(95vUN3uSeMjQd0Bwn3Kl(ntIVLDt8s0MWm5M4Lmi5MKQyQ6Tn4qXyzALelBjApiknFGKyUgN2XnT3kTJpT)cTJlA3tMy(qvvCiwcZefTJflTReyiaGHQQ4aQH2BN2XN2FH2HHaagkjw2s0Chjgg)Fa1q7yXs74I29KjMpusSSLO5osmm()qSeMjkAhlwA3tMy(qjXYwIMughk24BzdXsyMOO92PD8P9xODCr7EYeZhM4)cs3uipzdXsyMOODSyPDyiaGHj(VG0nfYt2aQH2XIL2jvXu1BByI)liDtH8KnqsmxJt7Tq7b0kT3oTJpT)cTJlA3tMy(adAJ1IenGWWaLi1qSeMjkAhlwANuftvVTbg0gRfjAaHHbkrQbsI5ACAVfApGwP92PD8P9xODCr7EYeZhCOySmnEltawXudXsyMOODSyPDsvmv92gCOySmnEltawXudKeZ140El0EaTs7Tt74t7Vq74I29KjMpusSSLOjLXHIn(w2qSeMjkAhlwAhgcay8Ezk9gB4dOgAhlwANxqmn)prkAhmT3kTJflTddbammX)fKUPqEYgqn0o(0oVGyA(FIu0El0oo0E73eVePTmk30dIsZ1ijvbp)8BYHIXY0EquA(98(eW98MILWmrDGEtcADbT5n5fetZ)tKI2bt7TEZK4Bz38pnLUa0yGyQ0UjBnrtu3mCCo)(e(98MILWmrDGEtcADbT5nHHaagkjw2s0KcjdOgAhFA)fA3tMy(qjXYwIMughk24BzdXsyMOODSyPDyiaGHj(VG0nfYt2qvVnAV9BMeFl7MkjwgCX8BYwt0e1ndhNZVpT5EEtXsyMOoqVjbTUG28MWqaaJ3ltP3ydFW9KacA)lTVgPIRHrVXgoTJBApS0o(0(l0UNmX8HsILTenPmouSX3YgILWmrr7yXs7Wqaadt8FbPBkKNSHQEB0E73mj(w2n5)PQERHlMFt2AIMOUz44C(9jS3ZBMeFl7MKKX0kKKkUNmqii(nflHzI6a987tR3ZBMeFl7M)PP0fGgdetL2nflHzI6a987ZRCpVPyjmtuhO3KGwxqBEtyiaGHsILTenPqYaQH2XN2HHaagM4)cs3uipzdOgAhFA)fA)fAhgcayG3YeGvm1ajXCnoT3cT3kTJflTJlA3tMy(GdfJLPXBzcWkMAiwcZefT3oTJpT)cTddbamWG2yTirdimmqjsnqsmxJt7Tq7Ts7yXs7WqaadmOnwls0acdduIudv92O92P92Vzs8TSBQKyzWfZp)(eMUN3uSeMjQd0BsqRlOnVjmeaWWe)xq6Mc5jBa1q74t7Vq7Vq7Wqaad8wMaSIPgijMRXP9wO9wPDSyPDCr7EYeZhCOySmnEltawXudXsyMOO92PD8P9xODyiaGbg0gRfjAaHHbkrQbsI5ACAVfAVvAhlwAhgcayGbTXArIgqyyGsKAOQ3gT3oT3(ntIVLDt(FQQ3A4I5NFFaP3ZBkwcZe1b6njO1f0M3Kxqmn)prkoTdM2X5MjX3YUjhkgltRKyzlr7brP5NFFE975ntIVLDt(FQQ3A4I53uSeMjQd0Zp)MfaGgdrDpVpbCpVPyjmtuhO3KGwxqBEZgXhkjw2s0EquA(ij(INCZK4Bz3ewqCbbI1WC(9j875nflHzI6a9Me06cAZBcdbamGfexqGynmdOgAhlwAVr8HsILTeTheLMpsIV4j0o(0oUODusKHJkg7MjX3YUzt5BzNFFAZ98MILWmrDGEtcADbT5nBeFOKyzlr7brP5JK4lEYntIVLDtywvknaek453NWEpVPyjmtuhO3KGwxqBEZgXhkjw2s0EquA(ij(INCZK4Bz3eyrcmRk15NFtpiknx3GKM759jG75nflHzI6a9MjX3YUPQQ4nzRjAI6MTbNZVpHFpVPyjmtuhO3KGwxqBEtCr7EYeZhkjw2s0KY4qXgFlBiwcZe1ntIVLDtLelBjAUJedJ)F(9Pn3ZBMeFl7MM4)cs3uipz3uSeMjQd0ZVpH9EEZK4Bz3edAJ1IenGWWaLi1nflHzI6a987tR3ZBMeFl7MCOySmnEltawXu3uSeMjQd0ZVpVY98MjX3YUjjzmTcjPI7jdecIFtXsyMOoqp)(eMUN3uSeMjQd0BsqRlOnVjmeaWqjXYwIMuiza1q74t78cIP5)jsr74M2dlTJpT)cT7jtmFOKyzlrtkJdfB8TSHyjmtu0owS0omeaWWe)xq6Mc5jBOQ3gT3(ntIVLDtLeldUy(53hq698MILWmrDGEtcADbT5n5fetZ)tKI2XnT3kTdY0EyP9xtAhgcayyI)liDtH8KnGAUzs8TSBY)tv9wdxm)87ZRFpVzs8TSB(NMsxaAmqmvA3uSeMjQd0Zp)8BMq(FHU5CJHrNF(D]] )


end
