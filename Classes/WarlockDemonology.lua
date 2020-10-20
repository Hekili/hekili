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

    spec:RegisterPack( "Demonology", 20201020, [[dmunUaqiOOEeqHnbvAuQICkvrTkGIuVcGMfPOBrkHDPWVufgguXXifwMe4zsqMgPKUMeLTjbLVjbvnoGI6Cqr06KGkZdO09aY(iL6GqrOwiq1djLOmrOi5IqriNeOizLsKzcue2ja(juemusjQEQIMQQKVcueTxv(RGblPdlAXG6XiMmjxMyZQQpdLgnGoTsVwIQzJYTfA3u(TudNuTCiphPPt11bz7qHVRk14HIuNxcTEsjY8HQ2pQ(04EDtv6Ybqb4uaoAGtb4m0atQ1cPby(MErD5M6jP8eRCtlJYnXusSTM1ylEt9SiRt196M0gcrKBc0DDAH7XdSRdecEq64d6gHyPVTrq53Fq3i5XnHHwMdMYo4BQsxoakaNcWrdCkaNHgysTwinkSBs1fYbqbfwHDtGRsj2bFtLqj3em4vmLeBRzn2I8kyYeXAs58sGbVc0DDAH7XdSRdecEq64d6gHyPVTrq53Fq3i5bVeyWRyceVHfeVwaoAYRfGtb4WlXlbg8QwgW0Wk0chVeyWRAbVo1fgJxbt0KYh8sGbVQf8kMGXkYRiH0XOykEftjX2GBMZR6irliDeoDED)86686s511OEAoV(uJ4vGjsrsQZR)gXRWnLk0Nh8sGbVQf8QwE)wq86C1b2gVMmw)wu8Qos0cshHtNx9Mx1rnHxxJ6P58kMsITb3mFCtDu)xMCtWGxXusSTM1ylYRGjteRjLZlbg8kq31PfUhpWUoqi4bPJpOBeIL(2gbLF)bDJKh8sGbVIjq8gwq8Ab4OjVwaofGdVeVeyWRAzatdRqlC8sGbVQf86uxymEfmrtkFWlbg8QwWRycgRiVIeshJIP4vmLeBdUzoVQJeTG0r40519ZRRZRlLxxJ6P586tnIxbMifjPoV(BeVc3uQqFEWlbg8QwWRA59BbXRZvhyB8AYy9BrXR6irliDeoDE1BEvh1eEDnQNMZRykj2gCZ8bVeVeyWRyIW0cbYffVcl)gj8kPJWPZRWc21OdEftmHi6oLxT20cGjk(Hy8As8TnkV2gR4Gxkj(2gDOJeshHthqqp(clO64APVTP5(b5Bu0ghCXSU4JKTyi8sjX32OdDKq6iC6ac6bfkgBlOloVus8Tn6qhjKocNoGGEO3VfuGU6aBtZ9dcg6)hVxMkSrD6G6jPCT1axyO)FOKyBljqAKmOEskhSGkGxkj(2gDOJeshHthqqpusSn4M5AUFqWnLIhFs8TTHsITb3mFqsQdchEPK4BB0HosiDeoDab9Gcmv97aCZCEPK4BB0HosiDeoDab9aJeTjmt00YOaYlIsZdijvf1eJKbjGiDZu9BBqHIX2ckj22scEruA(ajXCnkyld3NWSNmX8HQ74qSeMjk84vcm0)puDhhq6pJ7tWq))qjX2wsG6iXW6ahq64XJzpzI5dLeBBjbQJedRdCiwcZefE8EYeZhkj22scK2OqrDFBBiwcZe1Z4(eM9KjMpmXbkOGEJ8KnelHzIcpEyO)FyIduqb9g5jBaPJhpPBMQFBdtCGckO3ipzdKeZ1OARrzpJ7ty2tMy(alAJ9IKWxyyHsKAiwcZefE8KUzQ(TnWI2yVij8fgwOePgijMRr1wJYEg3NWSNmX8bfkgBlGXYK)kMAiwcZefE8KUzQ(TnOqXyBbmwM8xXudKeZ1OARrzpJ7ty2tMy(qjX2wsG0gfkQ7BBdXsyMOWJhg6)hVxMkSrD6ashpEAdXcuGjsbQm84HH()Hjoqbf0BKNSbKoU0gIfOatKsBCEMxIxcm4vmryAHa5IIxfmeurE13OWRoqHxtI3iEDP8AIrUSeMjdEPK4BBuquDHXcSMuoVus8TnkGGEOemAiuiMyxcVus8TnkGGEqsglKeFBlWwQRPLrbu))bSefVus8TnkGGEqsglKeFBlWwQRPLrbKqPIrekVus8TnkGGEGGSqs8TTaBPUMwgfqEruAEqhj6AsD0sCqAO5(br6MP632GcfJTfusSTLe8IO08bsI5AuWwgUygJeTjmtgEruAEajPQiVus8TnkGGEGGSqs8TTaBPUMwgfquOySTGxeLMRj1rlXbPHM7hegjAtyMm8IO08assvrEPK4BBuab9GsAi0Ayd(6afEPK4BBuab9yJ6IPwdBGKEsDuRdu4LsIVTrbe0dAdXcO21C)GsIVyibXK4kuT1Gxkj(2gfqqpuczJPVg2aCZCn3pON8eHv8bqjzoWGoXbBz4Gh)FXc0dijMRr1UmCEMxkj(2gfqqpOqXyBbmwM8xXuAUFqKUzQ(TnOqXyBbLeBBjbViknFGKyUgvBTIdE8)flqpGKyUgfSKUzQ(TnOqXyBbLeBBjbViknFGKyUgfWckJxkj(2gfqqpijJfuijvupzLlikVus8TnkGGEO6oQ5(bHKpsOatyMWlLeFBJciOhkj22scuhjgwhiVus8TnkGGEaVmHsAiewja3rybr5LsIVTrbe0dGPPc9pGfIPstZ9dI2qSafyIuGkdpEyO)FyIduqb9g5jBaPZlLeFBJciOhattf6FaletLMM7heTHybkWeP0guHWL0nt1VTbfkgBlOKyBlj4frP5dKeZ1OAxao4(ePBMQFBdkum2waJLj)vm1ajXCnQ2LHhpM9KjMpOqXyBbmwM8xXudXsyMOEgxs3mv)2gKKXckKKkQNSYfeDGKyUgv7c4LsIVTrbe0dLeBdUzUM7hem0)pusSTLeinsgijjoU0gIfOatKcSALxkj(2gfqqpWI2yVij8fgwOeP0C)GiDZu9BBqHIX2ckj22scEruA(ajXCnkGKUzQ(TnOqXyBbLeBBjbViknFOGqPVTP9FXc0dijMRrXJ)Vyb6bKeZ1OGL0nt1VTbfkgBlOKyBlj4frP5dKeZ1OaQrz8sjX32Oac6bevcRlrkVus8TnkGGEO3VfuGU6aBtZ9dcg6)hVxMkSrD6G6jPCT1axyO)FOKyBljqAKmOEskhSfIxkj(2gfqqp2OoRPBBAUFqPwsqRldbtRZA6IHe0BxmFt2aLw5ARbUWq))qW06SMUyib92fZ3KnqsmxJc2cHlm0)pEVmvyJ60b1ts5AdQq8sjX32Oac6bTHybQJ2YfEPK4BBuab9Gcmv97aCZCEjEPK4BB0HqPIrekO3nIPWqwlGeABPreEPK4BB0HqPIrekGGEeLyJkg6FGbrwvqHKms5LsIVTrhcLkgrOac6bmRBvO)bhOeetIf5LsIVTrhcLkgrOac6bwOeP20c9pKAjb1oqEPK4BB0HqPIrekGGEGwDDMewlq1tIWlLeFBJoekvmIqbe0JFtGOIkKAjbTUeGLmYlLeFBJoekvmIqbe0dDi0(lUg2amlPoVus8Tn6qOuXicfqqpqsQVg2WNLrHQ5(b5jcR4dGsYCGbDIRnygh849eHv8bqjzoWGoXbBb4Gh)FXc0dijMRrbBHWbpEpryfF4BucEh0jEOaC0wR4WlLeFBJoekvmIqbe0dsBeXCu6Ik8zzu4LsIVTrhcLkgrOac6HducqgCdzQWVrerZ9dcg6)hiHuotO0WVrezGKyUgLxIxkj(2gD0)Falrbcwqubv(Ay1C)G0fFOKyBlj4frP5JK4lgcVus8Tn6O))awIcqqp0BFBtZ9dcg6)hWcIkOYxd7ashpEDXhkj22scEruA(ij(IHGlMrjrgoQzmEPK4BB0r))bSefGGEaZ6wf(qOIAUFq6IpusSTLe8IO08rs8fdHxkj(2gD0)FalrbiOh)fjWSUvAUFq6IpusSTLe8IO08rs8fdHxIxkj(2gDqHIX2cEruAoiGPPc9pGfIPstZ9dI2qSafyIuGktt2AsGOavao8sjX32Odkum2wWlIsZbe0dLeBdUzUM7hem0)pusSTLeinsgq64(KNmX8HsITTKaPnkuu332gILWmrHhpm0)pmXbkOGEJ8Knu9B7znzRjbIcub4WlLeFBJoOqXyBbViknhqqpOatv)oa3mxZ9dcg6)hVxMkSrD6G6jPCaxJ0X1Wg2OofSAf3N8KjMpusSTLeiTrHI6(22qSeMjk84HH()Hjoqbf0BKNSHQFBpRjBnjquGkahEPK4BB0bfkgBl4frP5ac6bjzSGcjPI6jRCbr5LsIVTrhuOySTGxeLMdiOhattf6FaletLgVus8Tn6GcfJTf8IO0Cab9qjX2GBMR5(bbd9)dLeBBjbsJKbKoUWq))WehOGc6nYt2ash3NEcg6)hySm5VIPgijMRr1Um84XSNmX8bfkgBlGXYK)kMAiwcZe1Z4(em0)pWI2yVij8fgwOePgijMRr1Um84HH()bw0g7fjHVWWcLi1q1VTNFMxkj(2gDqHIX2cEruAoGGEqbMQ(DaUzUM7hem0)pmXbkOGEJ8KnG0X9PNGH()bglt(RyQbsI5AuTldpEm7jtmFqHIX2cySm5VIPgILWmr9mUpbd9)dSOn2lscFHHfkrQbsI5AuTldpEyO)FGfTXErs4lmSqjsnu9B75N5LadEnj(2gDqHIX2cEruAoGGEGrI2eMjAAzua5frP5bKKQIAIrYGeqyM0nt1VTbfkgBlOKyBlj4frP5dKKQI8sjX32Odkum2wWlIsZbe0dkum2wqjX2wsWlIsZ1C)GOnelqbMiffeo8sjX32Odkum2wWlIsZbe0dkWu1VdWnZ5L4LsIVTrhEruAEqhj6GuDh1KTMeikqfchEPK4BB0HxeLMh0rIoGGEOKyBljqDKyyDGAUFqy2tMy(qjX2wsG0gfkQ7BBdXsyMO4LsIVTrhEruAEqhj6ac6Hjoqbf0BKNmEPK4BB0HxeLMh0rIoGGEGfTXErs4lmSqjsXlLeFBJo8IO08Gos0be0dkum2waJLj)vmfVus8Tn6WlIsZd6irhqqpijJfuijvupzLlikVus8Tn6WlIsZd6irhqqpusSn4M5AUFqWq))qjX2wsG0izaPJlTHybkWePaRwX9jpzI5dLeBBjbsBuOOUVTnelHzIcpEyO)FyIduqb9g5jBO632Z8sjX32OdViknpOJeDab9Gcmv97aCZCn3piAdXcuGjsb2Y0cTcMgg6)hM4afuqVrEYgq68sGbVMeFBJo8IO08Gos0be0dms0MWmrtlJciViknpGKuvutmsgKasdEPK4BB0HxeLMh0rIoGGEamnvO)bSqmvA3edbr32oakaNcWrdC0OWU57ezRHLEtWur9g5IIxlmEnj(2gVYwQth8s3KTuNEVUPqPIre696aqJ71ntIVTDZ3nIPWqwlGeABPrKBkwcZe1b(5hafCVUzs8TTBgLyJkg6FGbrwvqHKmsVPyjmtuh4NFauO71ntIVTDtyw3Qq)doqjiMelEtXsyMOoWp)aqR3RBMeFB7MyHsKAtl0)qQLeu7aVPyjmtuh4NFau296MjX32UjA11zsyTavpjYnflHzI6a)8dGc7EDZK4BB383eiQOcPwsqRlbyjJ3uSeMjQd8Zpak83RBMeFB7M6qO9xCnSbyws9BkwcZe1b(5haG571nflHzI6a)Me06cAZB6jcR4dGsYCGbDIZRAZRGzC4v845vpryfFausMdmOtCEfS8Ab4WR4XZR)flqpGKyUgLxblVwiC4v845vpryfF4BucEh0jEOaC4vT5vTIZntIVTDtKK6RHn8zzuONFaGjVx3mj(22njTreZrPlQWNLr5MILWmrDGF(bGg4CVUPyjmtuh43KGwxqBEtyO)FGes5mHsd)grKbsI5A0BMeFB7MoqjazWnKPc)grKZp)Mk5Nqm)EDaOX96MjX32UjvxySaRjLFtXsyMOoWp)aOG71ntIVTDtLGrdHcXe7sUPyjmtuh4NFauO71nflHzI6a)MjX32UjjzSqs8TTaBP(nzl1dwgLB2)FalrD(bGwVx3uSeMjQd8BMeFB7MKKXcjX32cSL63KTupyzuUPqPIre65haLDVUPyjmtuh43KGwxqBEts3mv)2guOySTGsITTKGxeLMpqsmxJYRGLxlJxXLxXmVIrI2eMjdViknpGKuv8MuhTe)aqJBMeFB7MiilKeFBlWwQFt2s9GLr5MEruAEqhj6NFauy3RBkwcZe1b(njO1f0M3eJeTjmtgEruAEajPQ4nPoAj(bGg3mj(22nrqwij(2wGTu)MSL6blJYnPqXyBbVikn)8dGc)96MjX32UjL0qO1Wg81bk3uSeMjQd8ZpaaZ3RBMeFB7MBuxm1AydK0tQJADGYnflHzI6a)8dam596MILWmrDGFtcADbT5ntIVyibXK4kuEvBEvJBMeFB7M0gIfqTF(bGg4CVUPyjmtuh43KGwxqBEZN4vpryfFausMdmOtCEfS8Az4WR4XZR)flqpGKyUgLx1MxldhE95BMeFB7MkHSX0xdBaUz(5haAOX96MILWmrDGFtcADbT5njDZu9BBqHIX2ckj22scEruA(ajXCnkVQnVQvC4v8451)IfOhqsmxJYRGLxjDZu9BBqHIX2ckj22scEruA(ajXCnkVciVwqz3mj(22nPqXyBbmwM8xXuNFaOrb3RBMeFB7MKKXckKKkQNSYfe9MILWmrDGF(bGgf6EDtXsyMOoWVjbTUG28Mi5JekWeMj3mj(22nvDhp)aqdTEVUzs8TTBQKyBljqDKyyDG3uSeMjQd8Zpa0OS71ntIVTDt4LjusdHWkb4ocli6nflHzI6a)8dankS71nflHzI6a)Me06cAZBsBiwGcmrkEfeVwgVIhpVcd9)dtCGckO3ipzdi9BMeFB7Mattf6FaletL25haAu4Vx3uSeMjQd8BsqRlOnVjTHybkWeP4vTbXRfIxXLxjDZu9BBqHIX2ckj22scEruA(ajXCnkVQnVwao8kU86t8kPBMQFBdkum2waJLj)vm1ajXCnkVQnVwgVIhpVIzE1tMy(GcfJTfWyzYFftnelHzIIxFMxXLxjDZu9BBqsglOqsQOEYkxq0bsI5AuEvBETGBMeFB7Mattf6FaletL25haAaMVx3uSeMjQd8BsqRlOnVjm0)pusSTLeinsgijjoVIlVsBiwGcmrkEfS8QwVzs8TTBQKyBWnZp)aqdm596MILWmrDGFtcADbT5njDZu9BBqHIX2ckj22scEruA(ajXCnkVciVs6MP632GcfJTfusSTLe8IO08HccL(2gVQnV(xSa9asI5AuEfpEE9Vyb6bKeZ1O8ky5vs3mv)2guOySTGsITTKGxeLMpqsmxJYRaYRAu2ntIVTDtSOn2lscFHHfkrQZpakaN71ntIVTDtiQewxI0BkwcZe1b(5hafOX96MILWmrDGFtcADbT5nHH()X7LPcBuNoOEskNx1Mx1GxXLxHH()HsITTKaPrYG6jPCEfS8AHUzs8TTBQ3VfuGU6aB78dGck4EDtXsyMOoWVjbTUG28MPwsqRldbtRZA6IHe0BxmFt2aLw58Q28Qg8kU8km0)pemToRPlgsqVDX8nzdKeZ1O8ky51cXR4YRWq))49YuHnQthupjLZRAdIxl0ntIVTDZnQZA6225hafuO71ntIVTDtAdXcuhTLl3uSeMjQd8ZpakqR3RBMeFB7MuGPQFhGBMFtXsyMOoWp)8BQJeshHt)EDaOX96MILWmrDGFtcADbT5n9nk8Q28ko8kU8kM5vDXhjBXqUzs8TTB(fwq1X1sFB78dGcUx3mj(22nPqXyBHVWWcLi1nflHzI6a)8dGcDVUPyjmtuh43KGwxqBEtyO)F8EzQWg1PdQNKY5vT5vn4vC5vyO)FOKyBljqAKmOEskNxbliETGBMeFB7M69BbfORoW2o)aqR3RBkwcZe1b(njO1f0M3eUPuEfpEEnj(22qjX2GBMpij15vq8ko3mj(22nvsSn4M5NFau296MjX32UjfyQ63b4M53uSeMjQd8ZpakS71nflHzI6a)MT(nPIFZK4BB3eJeTjmtUjgjdsUjPBMQFBdkum2wqjX2wsWlIsZhijMRr5vWYRLXR4YRpXRyMx9KjMpuDhhILWmrXR4XZRkbg6)hQUJdiDE9zEfxE9jEfg6)hkj22scuhjgwh4asNxXJNxXmV6jtmFOKyBljqDKyyDGdXsyMO4v845vpzI5dLeBBjbsBuOOUVTnelHzIIxFMxXLxFIxXmV6jtmFyIduqb9g5jBiwcZefVIhpVcd9)dtCGckO3ipzdiDEfpEEL0nt1VTHjoqbf0BKNSbsI5AuEvBEvJY41N5vC51N4vmZREYeZhyrBSxKe(cdluIudXsyMO4v845vs3mv)2gyrBSxKe(cdluIudKeZ1O8Q28QgLXRpZR4YRpXRyMx9KjMpOqXyBbmwM8xXudXsyMO4v845vs3mv)2guOySTaglt(RyQbsI5AuEvBEvJY41N5vC51N4vmZREYeZhkj22scK2OqrDFBBiwcZefVIhpVcd9)J3ltf2OoDaPZR4XZR0gIfOatKIxbXRLXR4XZRWq))WehOGc6nYt2asNxXLxPnelqbMifVQnVIdV(8nXirblJYn9IO08assvXZp)MuOySTGxeLMFVoa04EDtXsyMOoWVjbTUG28M0gIfOatKIxbXRLDZK4BB3eyAQq)dyHyQ0UjBnjqu3SaCo)aOG71nflHzI6a)Me06cAZBcd9)dLeBBjbsJKbKoVIlV(eV6jtmFOKyBljqAJcf19TTHyjmtu8kE88km0)pmXbkOGEJ8Knu9BJxF(MjX32UPsITb3m)MS1KarDZcW58dGcDVUPyjmtuh43KGwxqBEtyO)F8EzQWg1PdQNKY5va511iDCnSHnQt5vWYRALxXLxFIx9KjMpusSTLeiTrHI6(22qSeMjkEfpEEfg6)hM4afuqVrEYgQ(TXRpFZK4BB3Kcmv97aCZ8BYwtce1nlaNZpa0696MjX32UjjzSGcjPI6jRCbrVPyjmtuh4NFau296MjX32UjW0uH(hWcXuPDtXsyMOoWp)aOWUx3uSeMjQd8BsqRlOnVjm0)pusSTLeinsgq68kU8km0)pmXbkOGEJ8KnG05vC51N41N4vyO)FGXYK)kMAGKyUgLx1MxlJxXJNxXmV6jtmFqHIX2cySm5VIPgILWmrXRpZR4YRpXRWq))alAJ9IKWxyyHsKAGKyUgLx1MxlJxXJNxHH()bw0g7fjHVWWcLi1q1VnE9zE95BMeFB7Mkj2gCZ8Zpak83RBkwcZe1b(njO1f0M3eg6)hM4afuqVrEYgq68kU86t86t8km0)pWyzYFftnqsmxJYRAZRLXR4XZRyMx9KjMpOqXyBbmwM8xXudXsyMO41N5vC51N4vyO)FGfTXErs4lmSqjsnqsmxJYRAZRLXR4XZRWq))alAJ9IKWxyyHsKAO63gV(mV(8ntIVTDtkWu1VdWnZp)aamFVUPyjmtuh43KGwxqBEtAdXcuGjsr5vq8ko3mj(22nPqXyBbLeBBjbVikn)8dam596MjX32UjfyQ63b4M53uSeMjQd8Zp)M9)hWsu3RdanUx3uSeMjQd8BsqRlOnVPU4dLeBBjbViknFKeFXqUzs8TTBcliQGkFnSNFauW96MILWmrDGFtcADbT5nHH()bSGOcQ81WoG05v845vDXhkj22scEruA(ij(IHWR4YRyMxrjrgoQzSBMeFB7M6TVTD(bqHUx3uSeMjQd8BsqRlOnVPU4dLeBBjbViknFKeFXqUzs8TTBcZ6wf(qOINFaO171nflHzI6a)Me06cAZBQl(qjX2wsWlIsZhjXxmKBMeFB7M)fjWSUvNF(n9IO08Gos0VxhaACVUPyjmtuh43mj(22nvDhVjBnjqu3Sq4C(bqb3RBkwcZe1b(njO1f0M3eZ8QNmX8HsITTKaPnkuu332gILWmrDZK4BB3ujX2wsG6iXW6ap)aOq3RBMeFB7MM4afuqVrEYUPyjmtuh4NFaO171ntIVTDtSOn2lscFHHfkrQBkwcZe1b(5haLDVUzs8TTBsHIX2cySm5VIPUPyjmtuh4NFauy3RBMeFB7MKKXckKKkQNSYfe9MILWmrDGF(bqH)EDtXsyMOoWVjbTUG28MWq))qjX2wsG0izaPZR4YR0gIfOatKIxblVQvEfxE9jE1tMy(qjX2wsG0gfkQ7BBdXsyMO4v845vyO)FyIduqb9g5jBO63gV(8ntIVTDtLeBdUz(5haG571nflHzI6a)Me06cAZBsBiwGcmrkEfS8Az8QwWRALxbtZRWq))WehOGc6nYt2as)MjX32UjfyQ63b4M5NFaGjVx3mj(22nbMMk0)awiMkTBkwcZe1b(5NF(ntihyJU5CJAzNF(Da]] )


end
