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

                imp.expires = min( imp.max, now + ( ( ( state.level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
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

    spec:RegisterPack( "Demonology", 20201016, [[dmKZVaqiePEeqWMqugLQKoLQeRciu1Ruvmlb0TqK0Uu4xQIgMaCmevltG6zsPyAcKUMG02ei8nPukJdiKZjLs16KsjnpGO7bu7tqCqejulei9qPucterIUiIeYjbcLwPuYmbcf7uvPFIibdfiu5PkAQQs9vPuI2Rk)LudwQoSOfdPhd1Kj5YeBgWNrWOvvDALETuQMnk3wODt53sgUuSCqphPPt11Hy7iIVRkmEbI68cQ1lqK5Jq7hvFKFVVPkD5(gCabha5bqEqmipObdIcoO30d3i3SjXTNeKBAzuUjPuILvSIq4B2KHzvQU33KwiqSCZF3BOT1NpjS(pc6axXN0nIWsFlddta)jDJ4N3efzzoiw7qVPkD5(gCabha5bqEqmipObdIco4BsBe89n4GiiU5)QuIDO3uju8nbbENukXYkwrimV3wMqwHBN3ce49F3BOT1NpjS(pc6axXN0nIWsFlddta)jDJ4N8wGaVtkG9cvG8o5brG8EWbeCa8w8wGaV3w8NgbH2w5TabENu59zJWy8oiMc3(G3ce4DsL3jfmwyEhk4kgftX7KsjwgAXCEVbkKkUIOPZ7laVVoVVuEFnQNMZ7VwqE)pHkCsDEhOG8oArPc9LbVfiW7KkVdIREiqEFUn)LX7jJvpefV3afsfxr005DV49gyH591OEAoVtkLyzOfZh3SbwaltUjiW7KsjwwXkcH592YeYkC78wGaV)7EdTT(8jH1)rqh4k(KUrew6Bzyyc4pPBe)K3ce4DsbSxOcK3jpicK3doGGdG3I3ce492I)0ii02kVfiW7KkVpBegJ3bXu42h8wGaVtQ8oPGXcZ7qbxXOykENukXYqlMZ7nqHuXvenDEFb49159LY7Rr90CE)1cY7)juHtQZ7afK3rlkvOVm4TabENu5DqC1dbY7ZT5VmEpzS6HO49gOqQ4kIMoV7fV3almVVg1tZ5DsPeldTy(G3I3ce4DsrbzbJ4II3rfGck8oUIOPZ7OcH1OdENumglnoL3TYi1)egbqy8EI9TmkVxgl8G3kX(wgD0afCfrt)d4NactRQ4APVLf4ca23OesaKr6gXhjBjr4TsSVLrhnqbxr00)a(jfjglt3ioVvI9Tm6Obk4kIM(hWpBQhcut3M)YcCbaJIaamESmLEJn0b1tC7HqozOiaadLelBXACbLb1tC7GeCW8wj23YOJgOGRiA6Fa)ujXYqlMh4cagTOuIetSVLnusSm0I5dCsDWbWBLyFlJoAGcUIOP)b8t6FQQhA0I58wj23YOJgOGRiA6Fa)KKeUjktc0YOa2ddtZ1qjvHdKKKHiGXvXu1dBqrIXY0kjw2I1EyyA(akXCnkidLSxjTNmX8HQQ4qSeLjkIevckcaWqvvCG08czVIIaamusSSfRPoumc()aPHirs7jtmFOKyzlwtDOye8)Hyjktuej6jtmFOKyzlwJlJIeB8TSHyjktuVq2RK2tMy(We)xG6Mc6jBiwIYefrIOiaadt8FbQBkONSbsdrI4QyQ6HnmX)fOUPGEYgqjMRrdH8qFHSxjTNmX8bb4gRfkAaHrajHQHyjktuejIRIPQh2GaCJ1cfnGWiGKq1akXCnAiKh6lK9kP9KjMpOiXyzAswMaSIPgILOmrrKiUkMQEydksmwMMKLjaRyQbuI5A0qip0xi7vs7jtmFOKyzlwJlJIeB8TSHyjktuejIIaamESmLEJn0bsdrI0cHPP)jubouIerraagM4)cu3uqpzdKgYOfctt)tOkKaEH3I3ce4DsrbzbJ4II3fseyyE33OW7(VW7j2liVVuEpjjxwIYKbVvI9TmkyAJWyAwHBN3kX(wg9d4NkHKcbQJjHfZBLyFlJ(b8tCYy6e7BzA2s9aTmkGlaanbSI3kX(wg9d4N4KX0j23Y0SL6bAzualuQyyHYBLyFlJ(b8tiIPtSVLPzl1d0YOa2ddtZ1nqPjqQdxSdM8axaW4QyQ6HnOiXyzALelBXApmmnFaLyUgfKHsgPjjHBIYKHhgMMRHsQcZBLyFlJ(b8tiIPtSVLPzl1d0YOaMIeJLP9WW08aPoCXoyYdCbatsc3eLjdpmmnxdLufM3kX(wg9d4NuCHaxJG2x)x4TsSVLr)a(5gBetTgbno9K6WQ5x4TsSVLr)a(jTqyAy5bUaGtSVKiAXK4k0qiN3kX(wg9d4NkbVX0xJGgTyEGla4x9esq8XVKm)x3GDqgAaejcSe(DnuI5A0qcnGx4TsSVLr)a(jfjglttYYeGvmvGlayCvmv9WguKySmTsILTyThgMMpGsmxJgsqdGirGLWVRHsmxJcsCvmv9WguKySmTsILTyThgMMpGsmxJ(j4q5TsSVLr)a(jozmTckPI6jRDbs5TsSVLr)a(PQQyGlayOaaf6FIYeERe7Bz0pGFQKyzlwtDOye8FERe7Bz0pGFIUmHIleibrJwrubs5TsSVLr)a(5FAkDbOjGWuPf4caMwimn9pHkWHsKikcaWWe)xG6Mc6jBG0WBLyFlJ(b8Z)0u6cqtaHPslWfamTqyA6FcvHaUnKHRIPQh2GIeJLPvsSSfR9WW08buI5A0qcoaYEfxftvpSbfjglttYYeGvm1akXCnAiHsKiP9KjMpOiXyzAswMaSIPgILOmr9cz4QyQ6HnWjJPvqjvupzTlq6akXCnAibZBLyFlJ(b8tLeldTyEGlayueaGHsILTynUGYakj2jJwimn9pHkqguERe7Bz0pGFsaUXAHIgqyeqsOkWfamUkMQEydksmwMwjXYwS2ddtZhqjMRr)GRIPQh2GIeJLPvsSSfR9WW08HcbM(wwialHFxdLyUgLirGLWVRHsmxJcsCvmv9WguKySmTsILTyThgMMpGsmxJ(H8q5TsSVLr)a(jb4gRfkAaHrajHQaxaW4QyQ6HnOiXyzALelBXApmmnFaLyUg9dUkMQEydksmwMwjXYwS2ddtZhkey6BzHaSe(DnuI5AuIebwc)UgkXCnkiXvXu1dBqrIXY0kjw2I1EyyA(akXCn6hYdL3kX(wg9d4NiurVUeP8wj23YOFa)SPEiqnDB(llWfamkcaW4XYu6n2qhupXThc5KHIaamusSSfRXfugupXTdY2WBLyFlJ(b8Zn2Wk6wwGla4mijW1LHeKByfDjr0nLlMVjBatR9qiNmueaGHeKByfDjr0nLlMVjBaLyUgfKTHmueaGXJLP0BSHoOEIBpeWTH3kX(wg9d4N0cHPPoCBx4TsSVLr)a(j9pv1dnAXCElERe7Bz0HqPIHfk4hfKPirwtdfAzPHfERe7Bz0HqPIHf6hWpJsSGH1fGMHGxLwbLms5TsSVLrhcLkgwOFa)eLvLsxaA)x0IjXW8wj23YOdHsfdl0pGFsajHQnnDbOZGKal)N3kX(wgDiuQyyH(b8t420We9AAAtIfERe7Bz0HqPIHf6hWpbkmcvu6mijW1fnQKrERe7Bz0HqPIHf6hWpBqGlq41iOrzj15TsSVLrhcLkgwOFa)ekzZAe0aSmk0axaWEcji(4xsM)RBWEiGOais0tibXh)sY8FDd2bzWbqKiWs431qjMRrbzBcGirpHeeF4Bu0EPBWUo4acjObWBLyFlJoekvmSq)a(jUmSyomDrPbyzu4TsSVLrhcLkgwOFa)0)fnIHwiMsduqSe4cagfbayafC7mHs1afeldOeZ1O8w8wj23YOJcaqtaRaJkqQaBFncbUaGBeFOKyzlw7HHP5Je7ljcVvI9Tm6Oaa0eWQpGF2u(wwGlayueaGbQaPcS91imqAisSr8HsILTyThgMMpsSVKiKrAyILHdlgJ3kX(wgDuaaAcy1hWprzvP0aiWWbUaGBeFOKyzlw7HHP5Je7ljcVvI9Tm6Oaa0eWQpGFcSqbLvLkWfaCJ4dLelBXApmmnFKyFjr4T4TsSVLrhuKySmThgMMd(pnLUa0eqyQ0cCbatleMM(Nqf4qdKTMOXkWbhaVvI9Tm6GIeJLP9WW08pGFQKyzOfZdCbaJIaamusSSfRXfuginK9QNmX8HsILTynUmksSX3YgILOmrrKikcaWWe)xG6Mc6jBOQh2lbYwt0yf4GdG3kX(wgDqrIXY0EyyA(hWpP)PQEOrlMh4cagfbay8yzk9gBOdQN42)SgUIRrqVXgkidkzV6jtmFOKyzlwJlJIeB8TSHyjktuejIIaammX)fOUPGEYgQ6H9sGS1enwbo4a4TsSVLrhuKySmThgMM)b8tCYyAfusf1tw7cKYBLyFlJoOiXyzApmmn)d4N)PP0fGMactLgVvI9Tm6GIeJLP9WW08pGFQKyzOfZdCbaJIaamusSSfRXfuginKHIaammX)fOUPGEYginK96ROiaadswMaSIPgqjMRrdjuIejTNmX8bfjglttYYeGvm1qSeLjQxi7vueaGbb4gRfkAaHrajHQbuI5A0qcLirueaGbb4gRfkAaHrajHQHQEyV8cVvI9Tm6GIeJLP9WW08pGFs)tv9qJwmpWfamkcaWWe)xG6Mc6jBG0q2RVIIaamizzcWkMAaLyUgnKqjsK0EYeZhuKySmnjltawXudXsuMOEHSxrraageGBSwOObegbKeQgqjMRrdjuIerraageGBSwOObegbKeQgQ6H9Yl8wGaVNyFlJoOiXyzApmmn)d4NKKWnrzsGwgfWEyyAUgkPkCGKKmebmPXvXu1dBqrIXY0kjw2I1EyyA(akPkmVvI9Tm6GIeJLP9WW08pGFsrIXY0kjw2I1EyyAEGlayAHW00)eQOGdG3kX(wgDqrIXY0EyyA(hWpP)PQEOrlMZBXBLyFlJo8WW0CDduAaRQkgiBnrJvGBta8wj23YOdpmmnx3aLMpGFQKyzlwtDOye8)axaWK2tMy(qjXYwSgxgfj24BzdXsuMO4TsSVLrhEyyAUUbknFa)0e)xG6Mc6jJ3kX(wgD4HHP56gO08b8tcWnwlu0acJascv8wj23YOdpmmnx3aLMpGFsrIXY0KSmbyftXBLyFlJo8WW0CDduA(a(jozmTckPI6jRDbs5TsSVLrhEyyAUUbknFa)ujXYqlMh4cagfbayOKyzlwJlOmqAiJwimn9pHkqguYE1tMy(qjXYwSgxgfj24BzdXsuMOisefbayyI)lqDtb9Knu1d7fERe7Bz0HhgMMRBGsZhWpP)PQEOrlMh4caMwimn9pHkqgkPguq8Oiaadt8FbQBkONSbsdVfiW7j23YOdpmmnx3aLMpGFssc3eLjbAzua7HHP5AOKQWbssYqeWKZBLyFlJo8WW0CDduA(a(5FAkDbOjGWuPDtseiDl7(gCabha5bqEBU5JeARrGEtqSXMc6II3dcEpX(wgVZwQth8w3mr8)cEZ5gBlUjBPo9EFtHsfdl0799L879ntSVLDZhfKPirwtdfAzPHLBkwIYe1b6533GV33mX(w2nJsSGH1fGMHGxLwbLmsVPyjktuhONFFBZ9(Mj23YUjkRkLUa0(VOftIHVPyjktuhONFFd69(Mj23YUjbKeQ200fGodscS8)BkwIYe1b6533qV33mX(w2nHBtdt0RPPnjwUPyjktuhONFFdI79ntSVLDtGcJqfLodscCDrJkz8MILOmrDGE(9TTDVVzI9TSB2GaxGWRrqJYsQFtXsuMOoqp)(cIU33uSeLjQd0BIHRlWnVPNqcIp(LK5)6gSZ7HW7GOa4DIe5DpHeeF8ljZ)1nyN3bjVhCa8orI8oWs431qjMRr5DqY7TjaENirE3tibXh(gfTx6gSRdoaEpeEpObCZe7Bz3ekzZAe0aSmk0ZVVT979ntSVLDtCzyXCy6IsdWYOCtXsuMOoqp)(sEa37BkwIYe1b6nXW1f4M3efbayafC7mHs1afeldOeZ1O3mX(w2n9FrJyOfIP0afelNF(nvcqIW8799L879ntSVLDtAJWyAwHB)MILOmrDGE(9n479ntSVLDtLqsHa1XKWIVPyjktuhONFFBZ9(MILOmrDGEZe7Bz3eNmMoX(wMMTu)MSL6AlJYnlaanbS687BqV33uSeLjQd0BMyFl7M4KX0j23Y0SL63KTuxBzuUPqPIHf6533qV33uSeLjQd0BIHRlWnVjUkMQEydksmwMwjXYwS2ddtZhqjMRr5DqY7HY7KX7KM3jjHBIYKHhgMMRHsQcFtQdxSFFj)Mj23YUjeX0j23Y0SL63KTuxBzuUPhgMMRBGsZ533G4EFtXsuMOoqVjgUUa38MKKWnrzYWddtZ1qjvHVj1Hl2VVKFZe7Bz3eIy6e7BzA2s9BYwQRTmk3KIeJLP9WW08ZVVTT79ntSVLDtkUqGRrq7R)l3uSeLjQd0ZVVGO79ntSVLDZn2iMAncAC6j1HvZVCtXsuMOoqp)(22V33uSeLjQd0BIHRlWnVzI9LerlMexHY7HW7KFZe7Bz3KwimnS8ZVVKhW9(MILOmrDGEtmCDbU5nFL39esq8XVKm)x3GDEhK8EObW7ejY7alHFxdLyUgL3dH3dnaE)LBMyFl7MkbVX0xJGgTy(53xYj)EFtXsuMOoqVjgUUa38M4QyQ6HnOiXyzALelBXApmmnFaLyUgL3dH3dAa8orI8oWs431qjMRr5DqY74QyQ6HnOiXyzALelBXApmmnFaLyUgL3)W7bh6ntSVLDtksmwMMKLjaRyQZVVKh89(Mj23YUjozmTckPI6jRDbsVPyjktuhONFFjVn37BkwIYe1b6nXW1f4M3ekaqH(NOm5Mj23YUPQQ453xYd69(Mj23YUPsILTyn1HIrW)VPyjktuhONFFjp079ntSVLDt0LjuCHajiA0kIkq6nflrzI6a987l5bX9(MILOmrDGEtmCDbU5nPfctt)tOI3bZ7HY7ejY7Oiaadt8FbQBkONSbsZntSVLDZ)0u6cqtaHPs787l5TT79nflrzI6a9My46cCZBsleMM(NqfVhcyEVn8oz8oUkMQEydksmwMwjXYwS2ddtZhqjMRr59q49GdG3jJ3FL3XvXu1dBqrIXY0KSmbyftnGsmxJY7HW7HY7ejY7KM39KjMpOiXyzAswMaSIPgILOmrX7VW7KX74QyQ6HnWjJPvqjvupzTlq6akXCnkVhcVh8ntSVLDZ)0u6cqtaHPs787l5GO79nflrzI6a9My46cCZBIIaamusSSfRXfugqjXoVtgVtleMM(NqfVdsEpO3mX(w2nvsSm0I5NFFjVTFVVPyjktuhO3edxxGBEtCvmv9WguKySmTsILTyThgMMpGsmxJY7F4DCvmv9WguKySmTsILTyThgMMpuiW03Y49q4DGLWVRHsmxJY7ejY7alHFxdLyUgL3bjVJRIPQh2GIeJLPvsSSfR9WW08buI5AuE)dVtEO3mX(w2nja3yTqrdimcijuD(9n4aU33uSeLjQd0BIHRlWnVjUkMQEydksmwMwjXYwS2ddtZhqjMRr59p8oUkMQEydksmwMwjXYwS2ddtZhkey6Bz8Ei8oWs431qjMRr5DIe5DGLWVRHsmxJY7GK3XvXu1dBqrIXY0kjw2I1EyyA(akXCnkV)H3jp0BMyFl7MeGBSwOObegbKeQo)(gm537BMyFl7MiurVUeP3uSeLjQd0ZVVbh89(MILOmrDGEtmCDbU5nrraagpwMsVXg6G6jUDEpeENCENmEhfbayOKyzlwJlOmOEIBN3bjV3MBMyFl7Mn1dbQPBZFzNFFdUn37BkwIYe1b6nXW1f4M3mdscCDzib5gwrxseDt5I5BYgW0AN3dH3jN3jJ3rraagsqUHv0Ler3uUy(MSbuI5AuEhK8EB4DY4DueaGXJLP0BSHoOEIBN3dbmV3MBMyFl7MBSHv0TSZVVbh079ntSVLDtAHW0uhUTl3uSeLjQd0ZVVbh69(Mj23YUj9pv1dnAX8BkwIYe1b65NFZgOGRiA6377l537BkwIYe1b6nXW1f4M303OW7HW7bW7KX7KM3BeFKSLe5Mj23YUjGW0QkUw6BzNFFd(EFZe7Bz3KIeJLPbegbKeQUPyjktuhONFFBZ9(MILOmrDGEtmCDbU5nrraagpwMsVXg6G6jUDEpeENCENmEhfbayOKyzlwJlOmOEIBN3bjyEp4BMyFl7Mn1dbQPBZFzNFFd69(MILOmrDGEtmCDbU5nrlkL3jsK3tSVLnusSm0I5dCsDEhmVhWntSVLDtLeldTy(533qV33mX(w2nP)PQEOrlMFtXsuMOoqp)(ge37BkwIYe1b6nRMBsf)Mj23YUjjjCtuMCtssgICtCvmv9WguKySmTsILTyThgMMpGsmxJY7GK3dL3jJ3FL3jnV7jtmFOQkoelrzII3jsK3vckcaWqvvCG0W7VW7KX7VY7OiaadLelBXAQdfJG)pqA4DIe5DsZ7EYeZhkjw2I1uhkgb)FiwIYefVtKiV7jtmFOKyzlwJlJIeB8TSHyjktu8(l8oz8(R8oP5DpzI5dt8FbQBkONSHyjktu8orI8okcaWWe)xG6Mc6jBG0W7ejY74QyQ6HnmX)fOUPGEYgqjMRr59q4DYdL3FH3jJ3FL3jnV7jtmFqaUXAHIgqyeqsOAiwIYefVtKiVJRIPQh2GaCJ1cfnGWiGKq1akXCnkVhcVtEO8(l8oz8(R8oP5DpzI5dksmwMMKLjaRyQHyjktu8orI8oUkMQEydksmwMMKLjaRyQbuI5AuEpeEN8q59x4DY49x5DsZ7EYeZhkjw2I14YOiXgFlBiwIYefVtKiVJIaamESmLEJn0bsdVtKiVtleMM(NqfVdM3dL3jsK3rraagM4)cu3uqpzdKgENmENwimn9pHkEpeEpaE)LBssc1wgLB6HHP5AOKQWNF(nPiXyzApmmn)EFFj)EFtXsuMOoqVjgUUa38M0cHPP)juX7G59qVzI9TSB(NMsxaAcimvA3KTMOXQBgCaNFFd(EFtXsuMOoqVjgUUa38MOiaadLelBXACbLbsdVtgV)kV7jtmFOKyzlwJlJIeB8TSHyjktu8orI8okcaWWe)xG6Mc6jBOQhgV)YntSVLDtLeldTy(nzRjAS6MbhW5332CVVPyjktuhO3edxxGBEtueaGXJLP0BSHoOEIBN3)W7RHR4Ae0BSHY7GK3dkVtgV)kV7jtmFOKyzlwJlJIeB8TSHyjktu8orI8okcaWWe)xG6Mc6jBOQhgV)YntSVLDt6FQQhA0I53KTMOXQBgCaNFFd69(Mj23YUjozmTckPI6jRDbsVPyjktuhONFFd9EFZe7Bz38pnLUa0eqyQ0UPyjktuhONFFdI79nflrzI6a9My46cCZBIIaamusSSfRXfugin8oz8okcaWWe)xG6Mc6jBG0W7KX7VY7VY7OiaadswMaSIPgqjMRr59q49q5DIe5DsZ7EYeZhuKySmnjltawXudXsuMO49x4DY49x5DueaGbb4gRfkAaHrajHQbuI5AuEpeEpuENirEhfbayqaUXAHIgqyeqsOAOQhgV)cV)YntSVLDtLeldTy(533229(MILOmrDGEtmCDbU5nrraagM4)cu3uqpzdKgENmE)vE)vEhfbayqYYeGvm1akXCnkVhcVhkVtKiVtAE3tMy(GIeJLPjzzcWkMAiwIYefV)cVtgV)kVJIaamia3yTqrdimcijunGsmxJY7HW7HY7ejY7OiaadcWnwlu0acJascvdv9W49x49xUzI9TSBs)tv9qJwm)87li6EFtXsuMOoqVjgUUa38M0cHPP)jur5DW8Ea3mX(w2nPiXyzALelBXApmmn)87BB)EFZe7Bz3K(NQ6HgTy(nflrzI6a98ZVzbaOjGv377l537BkwIYe1b6nXW1f4M3Sr8HsILTyThgMMpsSVKi3mX(w2nrfivGTVgHZVVbFVVPyjktuhO3edxxGBEtueaGbQaPcS91imqA4DIe59gXhkjw2I1EyyA(iX(sIW7KX7KM3HjwgoSySBMyFl7MnLVLD(9Tn37BkwIYe1b6nXW1f4M3Sr8HsILTyThgMMpsSVKi3mX(w2nrzvP0aiWWNFFd69(MILOmrDGEtmCDbU5nBeFOKyzlw7HHP5Je7ljYntSVLDtGfkOSQuNF(n9WW0CDduAU33xYV33uSeLjQd0BMyFl7MQQI3KTMOXQB2Mao)(g89(MILOmrDGEtmCDbU5njnV7jtmFOKyzlwJlJIeB8TSHyjktu3mX(w2nvsSSfRPoumc()5332CVVzI9TSBAI)lqDtb9KDtXsuMOoqp)(g079ntSVLDtcWnwlu0acJascv3uSeLjQd0ZVVHEVVzI9TSBsrIXY0KSmbyftDtXsuMOoqp)(ge37BMyFl7M4KX0kOKkQNS2fi9MILOmrDGE(9TTDVVPyjktuhO3edxxGBEtueaGHsILTynUGYaPH3jJ3Pfctt)tOI3bjVhuENmE)vE3tMy(qjXYwSgxgfj24BzdXsuMO4DIe5DueaGHj(Va1nf0t2qvpmE)LBMyFl7MkjwgAX8ZVVGO79nflrzI6a9My46cCZBsleMM(NqfVdsEpuENu59GY7G45DueaGHj(Va1nf0t2aP5Mj23YUj9pv1dnAX8ZVVT979ntSVLDZ)0u6cqtaHPs7MILOmrDGE(5NF(53b]] )


end
