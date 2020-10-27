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
        if resource == "soul_shards" and amt > 0 then
            if buff.nether_portal.up then
                summon_demon( "other", 15, amt )
            end

            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end
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
            cast = function () return ( buff.demonic_core.up and 0 or 4.5 ) * haste end,
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
            cast = function () return legendary.pillars_of_the_dark_portal.eanbled and 0 or 2 end,
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
                if legendary.implosive_potential.enabled and active_enemies > 2 then
                    if buff.implosive_potential.down then stat.haste = stat.haste + 0.05 * buff.wild_imps.stack end
                    applyBuff( "implosive_potential" )
                end
                consume_demons( "wild_imps", "all" )
            end,

            auras = {
                implosive_potential = {
                    id = 337139,
                    duration = 8,
                    max_stack = 1
                }
            }
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

    spec:RegisterPack( "Demonology", 20201026, [[dm00UaqieupcOInHOmkvrDkvrwfqLuVsvPzrkClsjSlf(LQWWquDmsLwgPINjLIPrkPRrkABKs03KsPACavLZbuvToPukZdb5EQQ2hPuheOkQfcuEOukjteOkDrGQiNeOsYkLsMjqLWovv8tGQWqLsj1tv0uvL6RavI2Rk)vWGLQdlAXG6XqnzsUmXMb8zeA0a50k9APunBuUTq7MYVLmCPy5qEostNQRdY2rGVRkz8avQZtQA9sPeZhr2pQ(09EFtv6Y9rhY1HCDjxhTCOl4xtnBJU3013i3SjXTNeLBAzuUj4vILvSIO(B2K6zvQU33KwqiSCtqU3qBBpEqCDqqWdCfFq3iel9Tmmkb8h0nIFCtyOL5GRSd(MQ0L7JoKRd56sUoA5qxWVMA2MBsBe89rhTulVjOvPe7GVPsO4Bco8o4vILvSIOEEhCzIyfUDElWH3b5EdTT94bX1bbbpWv8bDJqS03YWOeWFq3i(bVf4W7GhyVGfeVRJwQbVRd56qoVfVf4W7TvGsJOqBB8wGdVRf8(SrymEhCrHBFWBbo8UwW7GhgtpVJeCfJIP4DWReldUyoV3GeTaxr4059fG3xN3xkVVg1tZ59NleVdkrkCsDEhOq8oCrPc9PbVf4W7AbV3wxVeeVp3gqLX7jJvVefV3GeTaxr405DV49guH591OEAoVdELyzWfZh3SbvaltUj4W7GxjwwXkI65DWLjIv425TahEhK7n022Jhexhee8axXh0ncXsFldJsa)bDJ4h8wGdVdEG9cwq8UoAPg8UoKRd58w8wGdV3wbknIcTTXBbo8UwW7ZgHX4DWffU9bVf4W7AbVdEym98osWvmkMI3bVsSm4I58Eds0cCfHtN3xaEFDEFP8(AupnN3FUq8oOePWj15DGcX7WfLk0Ng8wGdVRf8EBD9sq8(CBavgVNmw9su8Eds0cCfHtN39I3BqfM3xJ6P58o4vILbxmFWBXBbo8o4jWTGHCrX7WcqHeEhxr405DyH4A0bVdEgJLgNY7wzAbOefbGy8EI9TmkVxgt)G3kX(wgD0GeCfHt)7)daHfuvCT03Y0yb(9nkAtozeUr8rYwceERe7Bz0rdsWveo9V)pOqXyzHgX5TsSVLrhnibxr40)()OPEjOaDBavMglWpmeaW41YuHn2qhupXTRTUKbdbamusSSfhWfsgupXTtOFD4TsSVLrhnibxr40)()qjXYGlMRXc8dxukjsj23YgkjwgCX8boP(p58wj23YOJgKGRiC6F)FqbLQ6vaUyoVvI9Tm6Obj4kcN(3)heKOnHzIgwgLFxpknpGKuPxdcsgK8JRIPQx2GcfJLfusSSfhC9O08bsI5AucPjzptypzI5dvvXHyjmtuKiPeyiaGHQQ4aQ5jYEggcayOKyzloqDKyeDqdOgsKiSNmX8HsILT4a1rIr0bnelHzIIejpzI5dLelBXbCzuOyJVLnelHzI6jYEMWEYeZhM4GeuOPqEYgILWmrrIemeaWWehKGcnfYt2aQHejCvmv9YgM4GeuOPqEYgijMRr1wxnFISNjSNmX8br0gRfjbaHrekrQHyjmtuKiHRIPQx2GiAJ1IKaGWicLi1ajXCnQ26Q5tK9mH9KjMpOqXyzbcwMaSIPgILWmrrIeUkMQEzdkumwwGGLjaRyQbsI5AuT1vZNi7zc7jtmFOKyzloGlJcfB8TSHyjmtuKibdbamETmvyJn0budjs0cIfOGsK6xtsKGHaagM4GeuOPqEYgqnKrliwGckrkTj)jElElWH3bpbUfmKlkExiqq65DFJcV7GeEpXEH49LY7jb5YsyMm4TsSVLr)PncJfyfUDERe7Bz0V)psWTe8Is5TsSVLr)()qjeuqOqmjUyERe7Bz0V)pWjJfsSVLfyl11WYO8xaabIyfVvI9Tm63)h4KXcj23YcSL6Ayzu(fkvmSq5TsSVLr)()abzHe7Bzb2sDnSmk)UEuAEObjnAqD0I9FD1yb(XvXu1lBqHIXYckjw2IdUEuA(ajXCnkH0KmctqI2eMjdxpknpGKuPN3kX(wg97)deKfsSVLfyl11WYO8tHIXYcUEuAUguhTy)xxnwGFcs0MWmz46rP5bKKk98wj23YOF)FqXfeAnIbFDqcVvI9Tm63)hBSrm1Aed40tQJQgqcVvI9Tm63)h0cIfqLRXc8NyFjqcIjXvOARlVvI9Tm63)hkbVX0xJyaUyUglW)ZEIik(aKKmhuOb7estYjrcyjcYdijMRr1wtYFI3kX(wg97)dkumwwGGLjaRyknwGFCvmv9YguOySSGsILT4GRhLMpqsmxJQTwjNejGLiipGKyUgLq4QyQ6LnOqXyzbLelBXbxpknFGKyUg9RoAYBLyFlJ(9)bozSGcjPI6jRDbr5TsSVLr)()qvvuJf4hjaiHckHzcVvI9Tm63)hkjw2IduhjgrheVvI9Tm63)hWltO4ccrucWvewquERe7Bz0V)paLMkuabIqmvAASa)0cIfOGsK6xtsKGHaagM4GeuOPqEYgqn8wj23YOF)FaknvOaceHyQ00yb(PfelqbLiL2)THmCvmv9YguOySSGsILT4GRhLMpqsmxJQToKt2Z4QyQ6LnOqXyzbcwMaSIPgijMRr1wtsKiSNmX8bfkgllqWYeGvm1qSeMjQNidxftvVSbozSGcjPI6jRDbrhijMRr1whERe7Bz0V)pusSm4I5ASa)WqaadLelBXbCHKbssStgTGybkOePiKw5TsSVLr)()GiAJ1IKaGWicLiLglWpUkMQEzdkumwwqjXYwCW1JsZhijMRr)IRIPQx2GcfJLfusSSfhC9O08HccL(wM2alrqEajXCnkjsalrqEajXCnkHWvXu1lBqHIXYckjw2IdUEuA(ajXCn6xD1K3kX(wg97)diQewxIuERe7Bz0V)pAQxckq3gqLPXc8ddbamETmvyJn0b1tC7ARlzWqaadLelBXbCHKb1tC7eQn8wj23YOF)FSXgwr3Y0yb(Z2IGwxgc4UHv0Laj0uUy(MSbkT21wxYGHaagc4UHv0Laj0uUy(MSbsI5Auc1gYGHaagVwMkSXg6G6jUDT)BdVvI9Tm63)h0cIfOoABx4TsSVLr)()Gckv1RaCXCElERe7Bz0HqPIHf6)RcXueiRfqcTS0WIglWpUkMQEzdkumwwqjXYwCW1JsZhijMRr1wRAYBLyFlJoekvmSq)()ikXcPpuabgeEvbfsYiL3kX(wgDiuQyyH(9)bmRkvOacoijiMe1ZBLyFlJoekvmSq)()GiuIuBAHciKTfbvoiERe7Bz0HqPIHf63)hOTPHjH1c0Mel8wj23YOdHsfdl0V)pakmevuHSTiO1LaSKrERe7Bz0HqPIHf63)hnqOfq)AedWSK68wj23YOdHsfdl0V)pqs2SgXaalJcvJf43terXhGKK5GcnyxBWh5Ki5jIO4dqsYCqHgStiDiNejGLiipGKyUgLqTHCsK8eru8HVrj4vOb7bDixBTsoVvI9Tm6qOuXWc97)dCzyXCu6IkaWYOWBLyFlJoekvmSq)()WbjbidUGmvaOqyrJf4hgcayGeC7mHsdafcldKeZ1O8w8wj23YOJcaiqeR(HfevqTVgrnwG)gXhkjw2IdUEuA(iX(sGWBLyFlJokaGarS67)JMY3Y0yb(HHaagWcIkO2xJ4aQHePgXhkjw2IdUEuA(iX(sGqgHrjwgoQymERe7Bz0rbaeiIvF)FaZQsfaGq61yb(BeFOKyzlo46rP5Je7lbcVvI9Tm6OaaceXQV)pawKaZQsPXc83i(qjXYwCW1JsZhj2xceElERe7Bz0bfkgll46rP5)GstfkGariMknnwGFAbXcuqjs9RPgS1Kaw9Rd58wj23YOdkumwwW1JsZ)()qjXYGlMRXc8ddbamusSSfhWfsgqnK9SNmX8HsILT4aUmkuSX3YgILWmrrIemeaWWehKGcnfYt2qvVSN0GTMeWQFDiN3kX(wgDqHIXYcUEuA(3)huqPQEfGlMRXc8ddbamETmvyJn0b1tC7FxdxX1ig2ydLqALSN9KjMpusSSfhWLrHIn(w2qSeMjksKGHaagM4GeuOPqEYgQ6L9KgS1Kaw9Rd58wj23YOdkumwwW1JsZ)()aNmwqHKur9K1UGO8wj23YOdkumwwW1JsZ)()auAQqbeicXuPXBLyFlJoOqXyzbxpkn)7)dLeldUyUglWpmeaWqjXYwCaxiza1qgmeaWWehKGcnfYt2aQHSNFggcayqWYeGvm1ajXCnQ2AsIeH9KjMpOqXyzbcwMaSIPgILWmr9ezpddbamiI2yTijaimIqjsnqsmxJQTMKibdbamiI2yTijaimIqjsnu1l7PN4TsSVLrhuOySSGRhLM)9)bfuQQxb4I5ASa)WqaadtCqck0uipzdOgYE(zyiaGbbltawXudKeZ1OARjjse2tMy(GcfJLfiyzcWkMAiwcZe1tK9mmeaWGiAJ1IKaGWicLi1ajXCnQ2AsIemeaWGiAJ1IKaGWicLi1qvVSNEI3cC49e7Bz0bfkgll46rP5F)FqqI2eMjAyzu(D9O08assLEniizqYpHXvXu1lBqHIXYckjw2IdUEuA(ajPspVvI9Tm6GcfJLfC9O08V)pOqXyzbLelBXbxpknxJf4NwqSafuIu0FY5TsSVLrhuOySSGRhLM)9)bfuQQxb4I58w8wj23YOdxpknp0GKMFvvrnyRjbS6VnKZBLyFlJoC9O08qdsA(()qjXYwCG6iXi6G0yb(jSNmX8HsILT4aUmkuSX3YgILWmrXBLyFlJoC9O08qdsA(()WehKGcnfYtgVvI9Tm6W1JsZdniP57)dIOnwlscacJiuIu8wj23YOdxpknp0GKMV)pOqXyzbcwMaSIP4TsSVLrhUEuAEObjnF)FGtglOqsQOEYAxquERe7Bz0HRhLMhAqsZ3)hkjwgCXCnwGFyiaGHsILT4aUqYaQHmAbXcuqjsriTs2ZEYeZhkjw2Id4YOqXgFlBiwcZefjsWqaadtCqck0uipzdv9YEI3kX(wgD46rP5HgK089)bfuQQxb4I5ASa)0cIfOGsKIqAQfAfCnmeaWWehKGcnfYt2aQH3cC49e7Bz0HRhLMhAqsZ3)heKOnHzIgwgLFxpknpGKuPxdcsgK8RlVvI9Tm6W1JsZdniP57)dqPPcfqGietL2njqq0TS7JoKRd56sUoKFZxjYwJi9MGRInfYffVRL8EI9TmENTuNo4TUjBPo9EFtHsfdl0799r379nflHzI6a7My06cAZBIRIPQx2GcfJLfusSSfhC9O08bsI5AuExBExRAEZe7Bz38vHykcK1ciHwwAy587Jo37BMyFl7Mrjwi9HciWGWRkOqsgP3uSeMjQdSZVpT5EFZe7Bz3eMvLkuabhKeetI6VPyjmtuhyNFF069(Mj23YUjrOeP20cfqiBlcQCq3uSeMjQdSZVpAEVVzI9TSBI2MgMewlqBsSCtXsyMOoWo)(OL37BMyFl7MafgIkQq2we06sawY4nflHzI6a787tB)EFZe7Bz3SbcTa6xJyaMLu)MILWmrDGD(9b8DVVPyjmtuhy3eJwxqBEtprefFassMdk0GDExBEh8roVtIeV7jIO4dqsYCqHgSZ7eI31HCENejEhyjcYdijMRr5DcX7THCENejE3terXh(gLGxHgSh0HCExBExRKFZe7Bz3ejzZAedaSmk0ZVpG)79ntSVLDtCzyXCu6IkaWYOCtXsyMOoWo)(Ol537BkwcZe1b2nXO1f0M3egcayGeC7mHsdafcldKeZ1O3mX(w2nDqsaYGlitfakewo)8BQeGeI5377JU37BMyFl7M0gHXcSc3(nflHzI6a787Jo37BMyFl7Mj4wcErP3uSeMjQdSZVpT5EFZe7Bz3ujeuqOqmjU4BkwcZe1b253hTEVVPyjmtuhy3mX(w2nXjJfsSVLfyl1VjBPEWYOCZcaiqeRo)(O59(MILWmrDGDZe7Bz3eNmwiX(wwGTu)MSL6blJYnfkvmSqp)(OL37BkwcZe1b2nXO1f0M3exftvVSbfkgllOKyzlo46rP5dKeZ1O8oH4Dn5DY4DcZ7eKOnHzYW1JsZdijv6Vj1rl2Vp6EZe7Bz3ebzHe7Bzb2s9BYwQhSmk301JsZdniP587tB)EFtXsyMOoWUjgTUG28MeKOnHzYW1JsZdijv6Vj1rl2Vp6EZe7Bz3ebzHe7Bzb2s9BYwQhSmk3KcfJLfC9O08ZVpGV79ntSVLDtkUGqRrm4RdsUPyjmtuhyNFFa)37BMyFl7MBSrm1Aed40tQJQgqYnflHzI6a787JUKFVVPyjmtuhy3eJwxqBEZe7lbsqmjUcL31M319Mj23YUjTGybu5NFF0v379nflHzI6a7My06cAZB(mV7jIO4dqsYCqHgSZ7eI31KCENejEhyjcYdijMRr5DT5DnjN3F6Mj23YUPsWBm91igGlMF(9rxDU33uSeMjQdSBIrRlOnVjUkMQEzdkumwwqjXYwCW1JsZhijMRr5DT5DTsoVtIeVdSeb5bKeZ1O8oH4DCvmv9YguOySSGsILT4GRhLMpqsmxJY7F5DD08Mj23YUjfkgllqWYeGvm153hDBZ9(Mj23YUjozSGcjPI6jRDbrVPyjmtuhyNFF0vR37BkwcZe1b2nXO1f0M3ejaiHckHzYntSVLDtvvXZVp6Q59(Mj23YUPsILT4a1rIr0bDtXsyMOoWo)(ORwEVVzI9TSBcVmHIlierjaxrybrVPyjmtuhyNFF0TTFVVPyjmtuhy3eJwxqBEtAbXcuqjsX7)8UM8ojs8omeaWWehKGcnfYt2aQ5Mj23YUjO0uHciqeIPs787JUGV79nflHzI6a7My06cAZBsliwGckrkEx7FEVn8oz8oUkMQEzdkumwwqjXYwCW1JsZhijMRr5DT5DDiN3jJ3FM3XvXu1lBqHIXYceSmbyftnqsmxJY7AZ7AY7KiX7eM39KjMpOqXyzbcwMaSIPgILWmrX7pX7KX74QyQ6LnWjJfuijvupzTli6ajXCnkVRnVRZntSVLDtqPPcfqGietL253hDb)37BkwcZe1b2nXO1f0M3egcayOKyzloGlKmqsIDENmENwqSafuIu8oH4DTEZe7Bz3ujXYGlMF(9rhYV33uSeMjQdSBIrRlOnVjUkMQEzdkumwwqjXYwCW1JsZhijMRr59V8oUkMQEzdkumwwqjXYwCW1JsZhkiu6Bz8U28oWseKhqsmxJY7KiX7alrqEajXCnkVtiEhxftvVSbfkgllOKyzlo46rP5dKeZ1O8(xExxnVzI9TSBseTXArsaqyeHsK687Jo6EVVzI9TSBcrLW6sKEtXsyMOoWo)(OJo37BkwcZe1b2nXO1f0M3egcay8AzQWgBOdQN425DT5DD5DY4DyiaGHsILT4aUqYG6jUDENq8EBUzI9TSB2uVeuGUnGk787JoT5EFtXsyMOoWUjgTUG28MzBrqRldbC3Wk6sGeAkxmFt2aLw78U28UU8oz8omeaWqa3nSIUeiHMYfZ3KnqsmxJY7eI3BdVtgVddbamETmvyJn0b1tC78U2)8EBUzI9TSBUXgwr3Yo)(OJwV33mX(w2nPfelqD02UCtXsyMOoWo)(OJM37BMyFl7MuqPQEfGlMFtXsyMOoWo)8B2GeCfHt)EFF09EFtXsyMOoWUjgTUG28M(gfExBENCENmENW8EJ4JKTei3mX(w2nbewqvX1sFl787Jo37BMyFl7MuOySSaGWicLi1nflHzI6a787tBU33uSeMjQdSBIrRlOnVjmeaW41YuHn2qhupXTZ7AZ76Y7KX7WqaadLelBXbCHKb1tC78oH(5DDUzI9TSB2uVeuGUnGk787JwV33uSeMjQdSBIrRlOnVjCrP8ojs8EI9TSHsILbxmFGtQZ7)8o53mX(w2nvsSm4I5NFF08EFZe7Bz3Kckv1RaCX8BkwcZe1b253hT8EFtXsyMOoWUz1CtQ43mX(w2njirBcZKBsqYGKBIRIPQx2GcfJLfusSSfhC9O08bsI5AuENq8UM8oz8(Z8oH5DpzI5dvvXHyjmtu8ojs8UsGHaagQQIdOgE)jENmE)zEhgcayOKyzloqDKyeDqdOgENejENW8UNmX8HsILT4a1rIr0bnelHzII3jrI39KjMpusSSfhWLrHIn(w2qSeMjkE)jENmE)zENW8UNmX8HjoibfAkKNSHyjmtu8ojs8omeaWWehKGcnfYt2aQH3jrI3XvXu1lByIdsqHMc5jBGKyUgL31M31vtE)jENmE)zENW8UNmX8br0gRfjbaHrekrQHyjmtu8ojs8oUkMQEzdIOnwlscacJiuIudKeZ1O8U28UUAY7pX7KX7pZ7eM39KjMpOqXyzbcwMaSIPgILWmrX7KiX74QyQ6LnOqXyzbcwMaSIPgijMRr5DT5DD1K3FI3jJ3FM3jmV7jtmFOKyzloGlJcfB8TSHyjmtu8ojs8omeaW41YuHn2qhqn8ojs8oTGybkOeP49FExtENejEhgcayyIdsqHMc5jBa1W7KX70cIfOGsKI31M3jN3F6MeKOGLr5MUEuAEajPs)5NFtkumwwW1JsZV33hDV33uSeMjQdSBIrRlOnVjTGybkOeP49FExZBMyFl7MGstfkGariMkTBYwtcy1n1H8ZVp6CVVPyjmtuhy3eJwxqBEtyiaGHsILT4aUqYaQH3jJ3FM39KjMpusSSfhWLrHIn(w2qSeMjkENejEhgcayyIdsqHMc5jBOQxgV)0ntSVLDtLeldUy(nzRjbS6M6q(53N2CVVPyjmtuhy3eJwxqBEtyiaGXRLPcBSHoOEIBN3)Y7RHR4AedBSHY7eI31kVtgV)mV7jtmFOKyzloGlJcfB8TSHyjmtu8ojs8omeaWWehKGcnfYt2qvVmE)PBMyFl7MuqPQEfGlMFt2AsaRUPoKF(9rR37BMyFl7M4KXckKKkQNS2fe9MILWmrDGD(9rZ79ntSVLDtqPPcfqGietL2nflHzI6a787JwEVVPyjmtuhy3eJwxqBEtyiaGHsILT4aUqYaQH3jJ3HHaagM4GeuOPqEYgqn8oz8(Z8(Z8omeaWGGLjaRyQbsI5AuExBExtENejENW8UNmX8bfkgllqWYeGvm1qSeMjkE)jENmE)zEhgcayqeTXArsaqyeHsKAGKyUgL31M31K3jrI3HHaagerBSwKeaegrOePgQ6LX7pX7pDZe7Bz3ujXYGlMF(9PTFVVPyjmtuhy3eJwxqBEtyiaGHjoibfAkKNSbudVtgV)mV)mVddbamiyzcWkMAGKyUgL31M31K3jrI3jmV7jtmFqHIXYceSmbyftnelHzII3FI3jJ3FM3HHaagerBSwKeaegrOePgijMRr5DT5Dn5DsK4DyiaGbr0gRfjbaHrekrQHQEz8(t8(t3mX(w2nPGsv9kaxm)87d47EFtXsyMOoWUjgTUG28M0cIfOGsKIY7)8o53mX(w2nPqXyzbLelBXbxpkn)87d4)EFZe7Bz3Kckv1RaCX8BkwcZe1b25NFZcaiqeRU33hDV33uSeMjQdSBIrRlOnVzJ4dLelBXbxpknFKyFjqUzI9TSBcliQGAFnINFF05EFtXsyMOoWUjgTUG28MWqaadybrfu7RrCa1W7KiX7nIpusSSfhC9O08rI9LaH3jJ3jmVJsSmCuXy3mX(w2nBkFl787tBU33uSeMjQdSBIrRlOnVzJ4dLelBXbxpknFKyFjqUzI9TSBcZQsfaGq6p)(O179nflHzI6a7My06cAZB2i(qjXYwCW1JsZhj2xcKBMyFl7MalsGzvPo)8B66rP5HgK0CVVp6EVVPyjmtuhy3mX(w2nvvfVjBnjGv3SnKF(9rN79nflHzI6a7My06cAZBsyE3tMy(qjXYwCaxgfk24BzdXsyMOUzI9TSBQKyzloqDKyeDqNFFAZ9(Mj23YUPjoibfAkKNSBkwcZe1b253hTEVVzI9TSBseTXArsaqyeHsK6MILWmrDGD(9rZ79ntSVLDtkumwwGGLjaRyQBkwcZe1b253hT8EFZe7Bz3eNmwqHKur9K1UGO3uSeMjQdSZVpT979nflHzI6a7My06cAZBcdbamusSSfhWfsgqn8oz8oTGybkOeP4DcX7AL3jJ3FM39KjMpusSSfhWLrHIn(w2qSeMjkENejEhgcayyIdsqHMc5jBOQxgV)0ntSVLDtLeldUy(53hW39(MILWmrDGDtmADbT5nPfelqbLifVtiExtExl4DTY7GR5DyiaGHjoibfAkKNSbuZntSVLDtkOuvVcWfZp)(a(V33mX(w2nbLMkuabIqmvA3uSeMjQdSZp)8BMqoOcDZ5gBRo)87a]] )


end
