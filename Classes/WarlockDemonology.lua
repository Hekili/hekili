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
                gain( 5, "soul_shards" )
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

    spec:RegisterPack( "Demonology", 20201012, [[dqe3TaqiefpskrBcr1NuLuAuQsCkvHwLucIxPQ0SifUfqu7sHFjLAyiKJrkAzKkEMQGMMQaxJuPTPkj(MuczCsjW5aIyDsjuZdrP7bu7tkPdkLG0cbspukb1ebI0fvLKQtQkjXkjvntvjjTtvP(PQKkdvvskpvrtvv0xvLu0Ev5VcgSuDyrlgIhd1Kj5YeBgWNrWOvvDALEnqy2OCBH2nLFlz4sXYb9CunDQUoK2oc13vvmEvjfopP06vLu18rK9J0NM3ZBQsxU36qKoePjrAQZqtIicKORU3012i3SjXGiji30YOCtqQelRyfbT3Sj1YQuDpVjVqHy5M)U3WBXTBty9FuKbUIT5BeLL(wggMaEB(gXTVjc6Y8xf7qUPkD5ERdr6qKMePPodIaj6(qnF4n5nc(ERZR8k38FvkXoKBQeo(MTK2bPsSSIve0s7VMjKvyqq13sA)39gElUDBcR)JImWvSnFJOS03YWWeWBZ3iUnvFlP9xh2lebs7AQJg0UoePdru9u9TK2BH)tJGWBXu9TK2bzAF2imgT)QwyqmO6BjTdY0(RZyAPDOGRyumfTdsLyzifZP9gOaY4kIKoTVa0(60(YP914EAoT)sbP9)eQWj3PDGcs7ifNl8hhu9TK2bzA)vR(iqAFUn)Lr7jJvFefT3afqgxrK0PDVO9gyHP914EAoTdsLyzifZhu9TK2bzA)PeBkyc1s7BSHjrX803YO9cG2FTUwyAEakPs7RL2joHBIWKXnBGfWYKB2sAhKkXYkwrqlT)AMqwHbbvFlP9F3B4T42TjS(pkYaxX28nIYsFlddtaVnFJ42u9TK2FDyVqeiTRPoAq76qKoer1t13sAVf(pnccVft13sAhKP9zJWy0(RAHbXGQVL0oit7VoJPL2HcUIrXu0oivILHumN2BGciJRis60(cq7Rt7lN2xJ7P50(lfK2)tOcNCN2bkiTJuCUWFCq13sAhKP9xT6JaP9528xgTNmw9ru0EduazCfrsN29I2BGfM2xJ7P50oivILHumFq13sAhKP9NsSPGjulTVXgMefZtFlJ2laA)16AHP5bOKkTVwAN4eUjctgu9u9TK2F1FnemQlkAhrakOq74kIKoTJiewJpO9wOyS04CA3kdK)tyeaLr7j23Y40EzmTdQ(e7Bz8rduWvej9VGBdiSGQIRL(wMglayFJsRerozAeFKSLyHQpX(wgF0afCfrs)l42C0ySSqJ4u9j23Y4JgOGRis6Fb3UP(iWaFB(ltJfamckaW4ZYuHn2WhCpXGOvnjhbfayOKyzloGlOm4EIbbzbRdvFI9Tm(Obk4kIK(xWTBkFlJQpX(wgF0afCfrs)l42kjwgsXCnwaWifNtIuI9TSHsILHumFGtUdMiQ(e7Bz8rduWvej9VGBZ)tv9jGumNQpX(wgF0afCfrs)l42eNWnryIgwgfWUwyAEakPsRgeNmubmUkMQ(ydoAmwwqjXYwCW1ctZhqjMRXjRUK)cz8KjMpuvfhILimrrIKsqqbagQQId0Mhj)feuaGHsILT4a3HIrW)hOnKirgpzI5dLelBXbUdfJG)pelryIIejpzI5dLelBXbCzC0yJVLnelryI6rYFHmEYeZhM4)cm0uqpzdXseMOircbfayyI)lWqtb9KnqBircxftvFSHj(Vadnf0t2akXCnERAQ7JK)cz8KjMpia3yTqjaimcOjunelryIIejCvmv9XgeGBSwOeaegb0eQgqjMRXBvtDFK8xiJNmX8bhngllq8YeGvm1qSeHjksKWvXu1hBWrJXYceVmbyftnGsmxJ3QM6(i5VqgpzI5dLelBXbCzC0yJVLnelryIIejeuaGXNLPcBSHpqBirIxOSa)pHkW6sIeckaWWe)xGHMc6jBG2qoVqzb(FcvTs0Ju9u9TK2F1FnemQlkAxiwGAPDFJcT7)cTNyVG0(YP9K4Czjctgu9j23Y4G5ncJfyfgeu9j23Y4Fb3wjexOWqmjSyQ(e7Bz8VGBJtglKyFllWwURHLrbCbaeiGvu9j23Y4Fb3gNmwiX(wwGTCxdlJcyHZfdlCQ(e7Bz8VGBdrTqI9TSaB5UgwgfWUwyAEObknAWD4IDWAQXcagxftvFSbhngllOKyzlo4AHP5dOeZ14KvxYjdXjCteMmCTW08ausLwQ(e7Bz8VGBdrTqI9TSaB5UgwgfWC0ySSGRfMMRb3Hl2bRPglayIt4Mimz4AHP5bOKkTu9j23Y4Fb3MJlu4Aec(6)cvFI9Tm(xWT3yJyQ1ieWPNChwn)cvFI9Tm(xWT5fklalxJfaCI9LyjiMexH3QMu9j23Y4Fb3wj4nM(AecifZ1yba)INqcIp(LK5)HgStwDjIejGLWVhGsmxJ3QUe9ivFI9Tm(xWT5OXyzbIxMaSIP0ybaJRIPQp2GJgJLfusSSfhCTW08buI5A8wFarKibSe(9auI5ACYIRIPQp2GJgJLfusSSfhCTW08buI5A8V6OlvFI9Tm(xWTXjJfuqjvCpzGqGCQ(e7Bz8VGBRQkQXcagkaqH)NimHQpX(wg)l42kjw2IdChkgb)NQpX(wg)l42ilt44cfsqciverGCQ(e7Bz8VGB)NMkuabcOmvAASaG5fklW)tOcSUKiHGcammX)fyOPGEYgOnu9j23Y4Fb3(pnvOaceqzQ00ybaZluwG)NqvRGFi54QyQ6Jn4OXyzbLelBXbxlmnFaLyUgVvDiI8xWvXu1hBWrJXYceVmbyftnGsmxJ3QUKirgpzI5doAmwwG4LjaRyQHyjctupsoUkMQ(ydCYybfusf3tgieiFaLyUgVvDO6tSVLX)cUTsILHumxJfamckaWqjXYwCaxqzaLe7KZluwG)NqfzFavFI9Tm(xWTja3yTqjaimcOjuPXcagxftvFSbhngllOKyzlo4AHP5dOeZ14FXvXu1hBWrJXYckjw2IdUwyA(qHctFlRvGLWVhGsmxJtIeWs43dqjMRXjlUkMQ(ydoAmwwqjXYwCW1ctZhqjMRX)QPUu9j23Y4Fb3gLlH1LiNQpX(wg)l42n1hbg4BZFzASaGrqbagFwMkSXg(G7jgeTQj5iOaadLelBXbCbLb3tmii7dP6tSVLX)cUnVqzbUdxqiu9j23Y4Fb3M)NQ6taPyovpvFI9Tm(q4CXWch8NcYuelRfGcVS0WcvFI9Tm(q4CXWc)l42rjwqTHciWqXRkOGsg5u9j23Y4dHZfdl8VGBJWQsfkGG)lbXKOwQ(e7Bz8HW5IHf(xWTjGMq1MwOac5RxGL)t1NyFlJpeoxmSW)cUnCBAysyTaVjXcvFI9Tm(q4CXWc)l42afgLlQq(6f46sarYivFI9Tm(q4CXWc)l42nOWfq7AeciSK7u9j23Y4dHZfdl8VGBdLSzncbawgfUglaypHeeF8ljZ)dnyV1warKi5jKG4JFjz(FOb7KvhIircyj87bOeZ14K9HerIKNqcIp8nkbVcnypOdrT(aIO6tSVLXhcNlgw4Fb3gxgwmhMUOcaSmku9j23Y4dHZfdl8VGB7)sa1qkutfakiw0ybaJGcamGcgemHZdafeldOeZ14u9u9j23Y4JcaiqaRaJiqUabXAe0yba3i(qjXYwCW1ctZhj2xIfQ(e7Bz8rbaeiGvFb3UP8TmnwaWiOaadebYfiiwJWaTHePgXhkjw2IdUwyA(iX(sSqozGjwgoSymQ(e7Bz8rbaeiGvFb3gHvLkaGc1QXcaUr8HsILT4GRfMMpsSVelu9j23Y4JcaiqaR(cUnWcfewvknwaWnIpusSSfhCTW08rI9LyHQNQpX(wgFWrJXYcUwyAo4)0uHciqaLPstJfamVqzb(FcvG1vd2AsaRaRdru9j23Y4doAmwwW1ctZ)cUTsILHumxJfamckaWqjXYwCaxqzG2q(lEYeZhkjw2Id4Y4OXgFlBiwIWefjsiOaadt8FbgAkONSHQ(ypQbBnjGvG1HiQ(e7Bz8bhngll4AHP5Fb3M)NQ6taPyUglayeuaGXNLPcBSHp4EIbX31WvCncHn2Wj7di)fpzI5dLelBXbCzC0yJVLnelryIIejeuaGHj(Vadnf0t2qvFSh1GTMeWkW6qevFI9Tm(GJgJLfCTW08VGBJtglOGsQ4EYaHa5u9j23Y4doAmwwW1ctZ)cU9FAQqbeiGYuPr1NyFlJp4OXyzbxlmn)l42kjwgsXCnwaWiOaadLelBXbCbLbAd5iOaadt8FbgAkONSbAd5V8cckaWG4LjaRyQbuI5A8w1LejY4jtmFWrJXYceVmbyftnelryI6rYFbbfayqaUXAHsaqyeqtOAaLyUgVvDjrcbfayqaUXAHsaqyeqtOAOQp2Jps1NyFlJp4OXyzbxlmn)l428)uvFcifZ1ybaJGcammX)fyOPGEYgOnK)YliOaadIxMaSIPgqjMRXBvxsKiJNmX8bhngllq8YeGvm1qSeHjQhj)feuaGbb4gRfkbaHranHQbuI5A8w1LejeuaGbb4gRfkbaHranHQHQ(yp(ivFlP9e7Bz8bhngll4AHP5Fb3M4eUjct0WYOa21ctZdqjvA1G4KHkGjdUkMQ(ydoAmwwqjXYwCW1ctZhqjvAP6tSVLXhC0ySSGRfMM)fCBoAmwwqjXYwCW1ctZ1ybaZluwG)Nqfhmru9j23Y4doAmwwW1ctZ)cUn)pv1NasXCQEQ(e7Bz8HRfMMhAGsdyvvrnyRjbSc8djIQpX(wgF4AHP5HgO08fCBLelBXbUdfJG)RXcaMmEYeZhkjw2Id4Y4OXgFlBiwIWefvFI9Tm(W1ctZdnqP5l42M4)cm0uqpzu9j23Y4dxlmnp0aLMVGBtaUXAHsaqyeqtOIQpX(wgF4AHP5HgO08fCBoAmwwG4LjaRykQ(e7Bz8HRfMMhAGsZxWTXjJfuqjvCpzGqGCQ(e7Bz8HRfMMhAGsZxWTvsSmKI5ASaGrqbagkjw2Id4ckd0gY5fklW)tOISpG8x8KjMpusSSfhWLXrJn(w2qSeHjksKqqbagM4)cm0uqpzdv9XEKQpX(wgF4AHP5HgO08fCB(FQQpbKI5ASaG5fklW)tOIS6cYpOfcckaWWe)xGHMc6jBG2q13sApX(wgF4AHP5HgO08fCBIt4MimrdlJcyxlmnpaLuPvdItgQawtQ(e7Bz8HRfMMhAGsZxWT)ttfkGabuMkTBsSa5Bz3BDishIicKqKUdDU5NeARrGFZxLytbDrr7VcTNyFlJ2zl35dQ(BMO(FbV5CJTW3KTCNFpVPW5IHf(98ER598Mj23YU5NcYuelRfGcVS0WYnflryI6a987To3ZBMyFl7MrjwqTHciWqXRkOGsg53uSeHjQd0ZV3p8EEZe7Bz3eHvLkuab)xcIjrT3uSeHjQd0ZV3p4EEZe7Bz3KaAcvBAHciKVEbw()nflryI6a987TU3ZBMyFl7MWTPHjH1c8Mel3uSeHjQd0ZV3VY98Mj23YUjqHr5IkKVEbUUeqKmEtXseMOoqp)E3IUN3mX(w2nBqHlG21ieqyj3VPyjctuhONFVBb3ZBkwIWe1b6nXW1f4M30tibXh)sY8)qd2P9wP9war0ojs0UNqcIp(LK5)HgSt7KL21HiANejAhyj87bOeZ140ozP9hseTtIeT7jKG4dFJsWRqd2d6qeT3kT)aIUzI9TSBcLSzncbawgf(53BqY98Mj23YUjUmSyomDrfayzuUPyjctuhONFV1KO75nflryI6a9My46cCZBIGcamGcgemHZdafeldOeZ143mX(w2n9FjGAifQPcafelNF(nvcqIY8759wZ75ntSVLDtEJWybwHbXnflryI6a987To3ZBMyFl7MkH4cfgIjHfFtXseMOoqp)E)W75nflryI6a9Mj23YUjozSqI9TSaB5(nzl3dwgLBwaabcy1537hCpVPyjctuhO3mX(w2nXjJfsSVLfyl3VjB5EWYOCtHZfdl8ZV36EpVPyjctuhO3edxxGBEtCvmv9XgC0ySSGsILT4GRfMMpGsmxJt7KL21L2jN2jdTtCc3eHjdxlmnpaLuP9MChUy)ER5ntSVLDtiQfsSVLfyl3VjB5EWYOCtxlmnp0aLMZV3VY98MILimrDGEtmCDbU5njoHBIWKHRfMMhGsQ0EtUdxSFV18Mj23YUje1cj23YcSL73KTCpyzuUjhngll4AHP5NFVBr3ZBMyFl7MCCHcxJqWx)xUPyjctuhONFVBb3ZBMyFl7MBSrm1Aec40tUdRMF5MILimrDGE(9gKCpVPyjctuhO3edxxGBEZe7lXsqmjUcN2BL218Mj23YUjVqzby5NFV1KO75nflryI6a9My46cCZB(cT7jKG4JFjz(FOb70ozPDDjI2jrI2bwc)EakXCnoT3kTRlr0(J3mX(w2nvcEJPVgHasX8ZV3AQ598MILimrDGEtmCDbU5nXvXu1hBWrJXYckjw2IdUwyA(akXCnoT3kT)aIODsKODGLWVhGsmxJt7KL2XvXu1hBWrJXYckjw2IdUwyA(akXCnoT)L21r3BMyFl7MC0ySSaXltawXuNFV1uN75ntSVLDtCYybfusf3tgiei)MILimrDGE(9wZhEpVPyjctuhO3edxxGBEtOaaf(FIWKBMyFl7MQQINFV18b3ZBMyFl7Mkjw2IdChkgb))MILimrDGE(9wtDVN3mX(w2nrwMWXfkKGeqQiIa53uSeHjQd0ZV3A(k3ZBkwIWe1b6nXW1f4M3KxOSa)pHkAhmTRlTtIeTJGcammX)fyOPGEYgOn3mX(w2n)ttfkGabuMkTZV3A2IUN3uSeHjQd0BIHRlWnVjVqzb(Fcv0ERGP9hs7Kt74QyQ6Jn4OXyzbLelBXbxlmnFaLyUgN2BL21HiANCA)fAhxftvFSbhngllq8YeGvm1akXCnoT3kTRlTtIeTtgA3tMy(GJgJLfiEzcWkMAiwIWefT)iTtoTJRIPQp2aNmwqbLuX9KbcbYhqjMRXP9wPDDUzI9TSB(NMkuabcOmvANFV1SfCpVPyjctuhO3edxxGBEteuaGHsILT4aUGYakj2PDYPDEHYc8)eQODYs7p4Mj23YUPsILHum)87TMGK75nflryI6a9My46cCZBIRIPQp2GJgJLfusSSfhCTW08buI5ACA)lTJRIPQp2GJgJLfusSSfhCTW08HcfM(wgT3kTdSe(9auI5ACANejAhyj87bOeZ140ozPDCvmv9XgC0ySSGsILT4GRfMMpGsmxJt7FPDn19Mj23YUjb4gRfkbaHranHQZV36q098Mj23YUjkxcRlr(nflryI6a987ToAEpVPyjctuhO3edxxGBEteuaGXNLPcBSHp4EIbbT3kTRjTtoTJGcamusSSfhWfugCpXGG2jlT)WBMyFl7Mn1hbg4BZFzNFV1rN75ntSVLDtEHYcChUGqUPyjctuhONFV15H3ZBMyFl7M8)uvFcifZVPyjctuhONF(nBGcUIiPFpV3AEpVPyjctuhO3edxxGBEtFJcT3kTteTtoTtgAVr8rYwILBMyFl7MaclOQ4APVLD(9wN75ntSVLDtoAmwwaqyeqtO6MILimrDGE(9(H3ZBkwIWe1b6nXW1f4M3ebfay8zzQWgB4dUNyqq7Ts7As7Kt7iOaadLelBXbCbLb3tmiODYcM215Mj23YUzt9rGb(28x2537hCpVzI9TSB2u(w2nflryI6a987TU3ZBkwIWe1b6nXW1f4M3eP4CANejApX(w2qjXYqkMpWj3PDW0or3mX(w2nvsSmKI5NFVFL75ntSVLDt(FQQpbKI53uSeHjQd0ZV3TO75nflryI6a9MvZn5IFZe7Bz3K4eUjctUjXjdvUjUkMQ(ydoAmwwqjXYwCW1ctZhqjMRXPDYs76s7Kt7Vq7KH29KjMpuvfhILimrr7Kir7kbbfayOQkoqBO9hPDYP9xODeuaGHsILT4a3HIrW)hOn0ojs0ozODpzI5dLelBXbUdfJG)pelryII2jrI29KjMpusSSfhWLXrJn(w2qSeHjkA)rANCA)fANm0UNmX8Hj(Vadnf0t2qSeHjkANejAhbfayyI)lWqtb9KnqBODsKODCvmv9XgM4)cm0uqpzdOeZ140ER0UM6s7ps7Kt7Vq7KH29KjMpia3yTqjaimcOjunelryII2jrI2XvXu1hBqaUXAHsaqyeqtOAaLyUgN2BL21uxA)rANCA)fANm0UNmX8bhngllq8YeGvm1qSeHjkANejAhxftvFSbhngllq8YeGvm1akXCnoT3kTRPU0(J0o50(l0ozODpzI5dLelBXbCzC0yJVLnelryII2jrI2rqbagFwMkSXg(aTH2jrI25fklW)tOI2bt76s7Kir7iOaadt8FbgAkONSbAdTtoTZluwG)NqfT3kTteT)4njoHblJYnDTW08ausL2Zp)MC0ySSGRfMMFpV3AEpVPyjctuhO3edxxGBEtEHYc8)eQODW0UU3mX(w2n)ttfkGabuMkTBYwtcy1n1HOZV36CpVPyjctuhO3edxxGBEteuaGHsILT4aUGYaTH2jN2FH29KjMpusSSfhWLXrJn(w2qSeHjkANejAhbfayyI)lWqtb9Knu1hJ2F8Mj23YUPsILHum)MS1KawDtDi6879dVN3uSeHjQd0BIHRlWnVjckaW4ZYuHn2WhCpXGG2)s7RHR4AecBSHt7KL2FaTtoT)cT7jtmFOKyzloGlJJgB8TSHyjctu0ojs0ockaWWe)xGHMc6jBOQpgT)4ntSVLDt(FQQpbKI53KTMeWQBQdrNFVFW98Mj23YUjozSGckPI7jdecKFtXseMOoqp)ER798Mj23YU5FAQqbeiGYuPDtXseMOoqp)E)k3ZBkwIWe1b6nXW1f4M3ebfayOKyzloGlOmqBODYPDeuaGHj(Vadnf0t2aTH2jN2FH2FH2rqbageVmbyftnGsmxJt7Ts76s7Kir7KH29KjMp4OXyzbIxMaSIPgILimrr7ps7Kt7Vq7iOaadcWnwlucacJaAcvdOeZ140ER0UU0ojs0ockaWGaCJ1cLaGWiGMq1qvFmA)rA)XBMyFl7MkjwgsX8ZV3TO75nflryI6a9My46cCZBIGcammX)fyOPGEYgOn0o50(l0(l0ockaWG4LjaRyQbuI5ACAVvAxxANejANm0UNmX8bhngllq8YeGvm1qSeHjkA)rANCA)fAhbfayqaUXAHsaqyeqtOAaLyUgN2BL21L2jrI2rqbageGBSwOeaegb0eQgQ6Jr7ps7pEZe7Bz3K)NQ6taPy(537wW98MILimrDGEtmCDbU5n5fklW)tOIt7GPDIUzI9TSBYrJXYckjw2IdUwyA(53BqY98Mj23YUj)pv1NasX8BkwIWe1b65NFZcaiqaRUN3BnVN3uSeHjQd0BIHRlWnVzJ4dLelBXbxlmnFKyFjwUzI9TSBIiqUabXAeo)ERZ98MILimrDGEtmCDbU5nrqbagicKlqqSgHbAdTtIeT3i(qjXYwCW1ctZhj2xIfANCANm0omXYWHfJDZe7Bz3SP8TSZV3p8EEtXseMOoqVjgUUa38MnIpusSSfhCTW08rI9Ly5Mj23YUjcRkvaafQ9879dUN3uSeHjQd0BIHRlWnVzJ4dLelBXbxlmnFKyFjwUzI9TSBcSqbHvL68ZVPRfMMhAGsZ98ER598MILimrDGEZe7Bz3uvv8MS1KawDZhs053BDUN3uSeHjQd0BIHRlWnVjzODpzI5dLelBXbCzC0yJVLnelryI6Mj23YUPsILT4a3HIrW)p)E)W75ntSVLDtt8FbgAkONSBkwIWe1b6537hCpVzI9TSBsaUXAHsaqyeqtO6MILimrDGE(9w375ntSVLDtoAmwwG4LjaRyQBkwIWe1b6537x5EEZe7Bz3eNmwqbLuX9KbcbYVPyjctuhONFVBr3ZBkwIWe1b6nXW1f4M3ebfayOKyzloGlOmqBODYPDEHYc8)eQODYs7pG2jN2FH29KjMpusSSfhWLXrJn(w2qSeHjkANejAhbfayyI)lWqtb9Knu1hJ2F8Mj23YUPsILHum)87Dl4EEtXseMOoqVjgUUa38M8cLf4)jur7KL21L2bzA)b0EleAhbfayyI)lWqtb9KnqBUzI9TSBY)tv9jGum)87ni5EEZe7Bz38pnvOaceqzQ0UPyjctuhONF(5NF(Da]] )


end
