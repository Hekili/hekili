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


    spec:RegisterStateExpr( "extra_shards", function () return 0 end )

    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 89766,
            known = function () return IsSpellKnownOrOverridesKnown( 119914 ) end,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,

            toggle = "interrupts",
            interrupt = true,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            usable = function () return pet.exists end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "axe_toss", 4 )
            end,

            copy = 119914
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


        call_felhunter = {
            id = 212619,
            cast = 0,
            cooldown = 24,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136174,

            toggle = "interrupts",
            interrupt = true,

            pvptalent = "call_felhunter",

            debuff = "casting",
            readyTime = state.timeToInterrupt,
            
            handler = function ()
                interrupt()
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
                extra_shards = min( 2, soul_shards.current )
                if Hekili.ActiveDebug then Hekili:Debug( "Extra Shards: %d", extra_shards ) end
                spend( extra_shards, "soul_shards" )
            end,

            impact = function ()
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

    spec:RegisterPack( "Demonology", 20201102, [[dmuPVaqiOOEKKkTjOIrPkYPKu1QGIe9kvLMfPIBbfXUu4xQcddQ0XiLAzKcptvuMgPOUgPsBtsf(MKkQXbfPohPiADQIkMNQkDpGSpsjheksQfcfEOKkIjskcxuvuPojuKWkjvntjvK2PQu)uvujdLuK8ufnvvjFfksYEv5VcgSehw0Ib1JrAYKCzInd4ZqvJgOoTsVwvfZgLBl0UP8BPgUKSCiphvtNQRdY2vv13vvmEvrvNxsz9KIuZhkTFeFAFVUPkD5ERbUAGR2AJRgdTXvBnPM18n9AvYnRs6pjE5MwgLBQjKyBnRXx7MvznwNQ71n5neIk3eS7v8NZJh4xhme8G2Xh8ncXsFBJIsa)bFJ0h3egAzoMc7GVPkD5ERbUAGR2AJRgdTXvBnPgA(M8kHEV1OoQJBcEvkXo4BQeo9M1Lu0esSTM14RrkyQseRP)q0xxsbS7v8NZJh4xhme8G2Xh8ncXsFBJIsa)bFJ0he91LuE3)LiSGifn0Hu0axnWLONOVUKsDc40Wl8NdrFDjfmHuMvcJrk1Pn9NbrFDjfmHuEUmwnsbj0ogftrkAcj2gCZCsPcjycTJWPtklaPSoPSCsznUNMtkp1isbCIu0K7KcqJif4MZfE9dI(6skycPOP6pcIuMBf42iLKX6pIIuQqcMq7iC6KI3KsfQPKYACpnNu0esSn4M5dI(6skycPOP(RPifpzI5KYAUGqqv(4MvOgyzYnRlPOjKyBnRXxJuWuLiwt)HOVUKcy3R4pNhpWVoyi4bTJp4BeIL(2gfLa(d(gPpi6RlP8U)lrybrkAOdPObUAGlrprFDjL6eWPHx4phI(6skycPmRegJuQtB6pdI(6skycP8CzSAKcsODmkMIu0esSn4M5KsfsWeAhHtNuwaszDsz5KYACpnNuEQrKc4ePOj3jfGgrkWnNl86he91LuWesrt1FeePm3kWTrkjJ1FefPuHemH2r40jfVjLkutjL14EAoPOjKyBWnZhe91LuWesrt9xtrkEYeZjL1CbHGQ8brprFDjLN7NxOqUOifybOrcPq7iC6KcSGFn(GuWutPsLZjfRnmbCIIaqmsjP(2gNuAJvBq0NuFBJpQqcTJWP)f0daHfuDCT0320zba5Bu0cxCWCL4JKT)fI(K6BB8rfsODeo9VGEWHIX2cvIt0NuFBJpQqcTJWP)f0JQ(JGc8TcCB6SaGGHaagFwMkSXk(G7j9hT0ghyiaGHsITT0aTrYG7j9NFbPbrFs9Tn(Ocj0ocN(xqpusSn4M56SaGGBohl2K6BBdLeBdUz(GMCheUe9j1324JkKq7iC6Fb9Gdov9NaCZCI(K6BB8rfsODeo9VGE8prBcZeDSmkG8AO08assvnD(NmibeTBMQ)ydoum2wqjX2wAWRHsZhijMRX)vxCEcZEYeZhQUJdXsyMOWIvjWqaadv3Xbuv948emeaWqjX2wAG7iXW7GhqvyXIzpzI5dLeBBPbUJedVdEiwcZefwSEYeZhkj22sd024qXkFBBiwcZev948eM9KjMpmXblOqvJ8KnelHzIclwyiaGHjoybfQAKNSbufwS0UzQ(JnmXblOqvJ8KnqsmxJRL26wpopHzpzI5d8On2lscacdpuIudXsyMOWIL2nt1FSbE0g7fjbaHHhkrQbsI5ACT0w36X5jm7jtmFWHIX2c)xMaSIPgILWmrHflTBMQ)ydoum2w4)YeGvm1ajXCnUwARB948eM9KjMpusSTLgOTXHIv(22qSeMjkSyHHaagFwMkSXk(aQclwEdXcCWjsbsxSyHHaagM4GfuOQrEYgqv4WBiwGdorkTWTEIEI(6skp3pVqHCrrkYFbvJu8nkKIdwiLK6nIuwoPK)ZLLWmzq0NuFBJdIxjmwG10Fi6tQVTX)c6bnzSaGWadzUGi6tQVTX)c6r(8sWBoNOpP(2g)lOhk5FdHcXe)sj6tQVTX)c6bnzSqs9TTaB5Uowgfqnaqapvr0NuFBJ)f0dAYyHK6BBb2YDDSmkGeoxmQWj6tQVTX)c6bcYcj132cSL76yzua51qP5HkKuPd3rl1bPTolaiA3mv)XgCOySTGsITT0GxdLMpqsmxJ)RU4G5)jAtyMm8AO08assvnI(K6BB8VGEGGSqs9TTaB5UowgfqCOySTGxdLMRd3rl1bPTolaO)jAtyMm8AO08assvnI(K6BB8VGEWPneAn8bFDWcrFs9Tn(xqp2yLyQ1WhOPNCh1vGfI(K6BB8VGEWBiwa1UolaOK67FjiMexHRL2e9j1324Fb9qj0nM(A4dWnZ1zba9KNi8IpaljZbhQO(V6IlwSalEWEajXCnUw6IB9e9j1324Fb9GdfJTf(VmbyftPZcaI2nt1FSbhkgBlOKyBln41qP5dKeZ14APzCXIfyXd2dijMRX)L2nt1FSbhkgBlOKyBln41qP5dKeZ14F1qxI(K6BB8VGEqtglOqsQ4EY(rqCI(K6BB8VGEO6oQZcacjaiHdoHzcrFs9Tn(xqpusSTLg4osm8oyI(K6BB8VGEaVmHtBieEja3rybXj6tQVTX)c6b40uHgiGhIPstNfaeVHybo4ePaPlwSWqaadtCWcku1ipzdOkI(K6BB8VGEaonvObc4HyQ00zbaXBiwGdorkTa9mCODZu9hBWHIX2ckj22sdEnuA(ajXCnUwAGlopr7MP6p2GdfJTf(VmbyftnqsmxJRLUyXIzpzI5doum2w4)YeGvm1qSeMjQ6XH2nt1FSbnzSGcjPI7j7hbXhijMRX1sdI(K6BB8VGEOKyBWnZ1zbabdbamusSTLgOnsgijPoo8gIf4GtK6xnt0NuFBJ)f0d8On2lscacdpuIu6SaGODZu9hBWHIX2ckj22sdEnuA(ajXCn(xA3mv)XgCOySTGsITT0GxdLMpuqO0320cyXd2dijMRXXIfyXd2dijMRX)L2nt1FSbhkgBlOKyBln41qP5dKeZ14F1wxI(K6BB8VGEaXLW6sKt0NuFBJ)f0JQ(JGc8TcCB6SaGGHaagFwMkSXk(G7j9hT0ghyiaGHsITT0aTrYG7j9NFFgrFs9Tn(xqp2yfR5BB6SaGEIj)f2V6Iloj13)sqmjUcxlnWIn10cADzipFfR57Fju1Uy(MSbkTF0sBCGHaagYZxXA((xcvTlMVjBGKyUg)3NvpoWqaaJpltf2yfFW9K(JwGEgrFs9Tn(xqp4nelWD0(Jq0NuFBJ)f0do4u1FcWnZj6j6tQVTXhcNlgv4G(0iM6VSwaj82sJk6SaGODZu9hBWHIX2ckj22sdEnuA(ajXCnUwAwxI(K6BB8HW5Irf(xqpIsSr1cnqGbrxvqHKmYj6tQVTXhcNlgv4Fb9aM1Tk0abhSeetI1i6tQVTXhcNlgv4Fb9apuIuBAHgiKAAb1oyI(K6BB8HW5Irf(xqpqBvftcRf4vjvi6tQVTXhcNlgv4Fb9aOPqCrfsnTGwxcWsgj6tQVTXhcNlgv4Fb9OccTa1wdFaMLCNOpP(2gFiCUyuH)f0dKKvRHpaWYOW1zba5jcV4dWsYCWHkQRfMgxSy9eHx8byjzo4qf1)vdCXIfyXd2dijMRX)9z4IfRNi8Ip8nkbVdvupObUAPzCj6tQVTXhcNlgv4Fb9G2gvmhLUOcaSmke9j1324dHZfJk8VGE4GLaKb3qMka0iQOZcacgcayGe6pmHZdanIkdKeZ14e9e9j1324JgaiGNQabliUG(zn86SaGQeFOKyBln41qP5JK67FHOpP(2gF0aab8u1xqpQAFBtNfaemeaWawqCb9ZA4hqvyXwj(qjX2wAWRHsZhj13)coygLuz4OMXi6tQVTXhnaqapv9f0dyw3QaaeQMolaOkXhkj22sdEnuA(iP((xi6tQVTXhnaqapv9f0dGfjWSUv6SaGQeFOKyBln41qP5JK67FHONOpP(2gFWHIX2cEnuAoiWPPcnqapetLMolaiEdXcCWjsbsxDyRjbQcKg4s0NuFBJp4qXyBbVgkn)lOhkj2gCZCDwaqWqaadLeBBPbAJKbufop5jtmFOKyBlnqBJdfR8TTHyjmtuyXcdbammXblOqvJ8Knu9hREDyRjbQcKg4s0NuFBJp4qXyBbVgkn)lOhCWPQ)eGBMRZcacgcay8zzQWgR4dUN0F(UgTJRHpSXk(VAgNN8KjMpusSTLgOTXHIv(22qSeMjkSyHHaagM4GfuOQrEYgQ(JvVoS1KavbsdCj6tQVTXhCOySTGxdLM)f0dAYybfssf3t2pcIt0NuFBJp4qXyBbVgkn)lOhGttfAGaEiMknI(K6BB8bhkgBl41qP5Fb9qjX2GBMRZcacgcayOKyBlnqBKmGQWbgcayyIdwqHQg5jBavHZtpbdbam(VmbyftnqsmxJRLUyXIzpzI5doum2w4)YeGvm1qSeMjQ6X5jyiaGbE0g7fjbaHHhkrQbsI5ACT0flwyiaGbE0g7fjbaHHhkrQHQ)y1xprFs9Tn(GdfJTf8AO08VGEWbNQ(taUzUolaiyiaGHjoybfQAKNSbufop9emeaW4)YeGvm1ajXCnUw6IflM9KjMp4qXyBH)ltawXudXsyMOQhNNGHaag4rBSxKeaegEOePgijMRX1sxSyHHaag4rBSxKeaegEOePgQ(JvF9e91LusQVTXhCOySTGxdLM)f0J)jAtyMOJLrbKxdLMhqsQQPZ)KbjGWmTBMQ)ydoum2wqjX2wAWRHsZhijv1i6tQVTXhCOySTGxdLM)f0doum2wqjX2wAWRHsZ1zbaXBiwGdorkoiCj6tQVTXhCOySTGxdLM)f0do4u1FcWnZj6j6tQVTXhEnuAEOcjvGuDh1HTMeOkqpdxI(K6BB8HxdLMhQqs1xqpusSTLg4osm8oyDwaqy2tMy(qjX2wAG2ghkw5BBdXsyMOi6tQVTXhEnuAEOcjvFb9WehSGcvnYtgrFs9Tn(WRHsZdviP6lOh4rBSxKeaegEOePi6tQVTXhEnuAEOcjvFb9GdfJTf(Vmbyftr0NuFBJp8AO08qfsQ(c6bnzSGcjPI7j7hbXj6tQVTXhEnuAEOcjvFb9qjX2GBMRZcacgcayOKyBlnqBKmGQWH3qSahCIu)QzCEYtMy(qjX2wAG2ghkw5BBdXsyMOWIfgcayyIdwqHQg5jBO6pw9e9j1324dVgknpuHKQVGEWbNQ(taUzUolaiEdXcCWjs9RUyIMXucdbammXblOqvJ8KnGQi6RlPKuFBJp8AO08qfsQ(c6X)eTjmt0XYOaYRHsZdijv105FYGeqAt0NuFBJp8AO08qfsQ(c6b40uHgiGhIPs7M)feFB7ERbUAGR24QrDCZpjYwdp)MykIvnYffPuhKss9TnsHTCNpi6VjB5o)EDtHZfJk8719w771nflHzI6W4Mu06cAZBs7MP6p2GdfJTfusSTLg8AO08bsI5ACsrlsrZ6EZK6BB38tJyQ)YAbKWBlnQC(9wJ71ntQVTDZOeBuTqdeyq0vfuijJ8BkwcZe1HX537NDVUzs9TTBcZ6wfAGGdwcIjXA3uSeMjQdJZV3A(EDZK6BB3epuIuBAHgiKAAb1o4BkwcZe1HX53BDVx3mP(22nrBvftcRf4vjvUPyjmtuhgNFVRJ71ntQVTDtGMcXfvi10cADjalz8MILWmrDyC(9UoFVUzs9TTBwbHwGARHpaZsUFtXsyMOomo)EJPVx3uSeMjQdJBsrRlOnVPNi8IpaljZbhQOoPOfPGPXLuWILu8eHx8byjzo4qf1jLFjfnWLuWILuaw8G9asI5ACs5xs5z4skyXskEIWl(W3Oe8our9Gg4skArkAg3BMuFB7MijRwdFaGLrHF(9wtEVUzs9TTBsBJkMJsxubawgLBkwcZe1HX53BTX9EDtXsyMOomUjfTUG28MWqaadKq)HjCEaOruzGKyUg)Mj132UPdwcqgCdzQaqJOY5NFtLaKqm)EDV1(EDZK6BB3KxjmwG10FUPyjmtuhgNFV14EDZK6BB3KMmwaqyGHmxq3uSeMjQdJZV3p7EDZK6BB3mFEj4nNFtXsyMOomo)ER571ntQVTDtL8VHqHyIFP3uSeMjQdJZV36EVUPyjmtuhg3mP(22nPjJfsQVTfyl3VjB5EWYOCZgaiGNQo)Exh3RBkwcZe1HXntQVTDtAYyHK6BBb2Y9BYwUhSmk3u4CXOc)87DD(EDtXsyMOomUjfTUG28M0UzQ(Jn4qXyBbLeBBPbVgknFGKyUgNu(Lu0LuWHuWmP8prBcZKHxdLMhqsQQDtUJwQFV1(Mj132UjcYcj132cSL73KTCpyzuUPxdLMhQqs153Bm996MILWmrDyCtkADbT5n)NOnHzYWRHsZdijv1Uj3rl1V3AFZK6BB3ebzHK6BBb2Y9BYwUhSmk3KdfJTf8AO08ZV3AY71ntQVTDtoTHqRHp4RdwUPyjmtuhgNFV1g371ntQVTDZnwjMAn8bA6j3rDfy5MILWmrDyC(9wBTVx3uSeMjQdJBsrRlOnVzs99VeetIRWjfTifTVzs9TTBYBiwa1(53BT14EDtXsyMOomUjfTUG28MprkEIWl(aSKmhCOI6KYVKIU4skyXskalEWEajXCnoPOfPOlUKs93mP(22nvcDJPVg(aCZ8ZV3A)S71nflHzI6W4Mu06cAZBs7MP6p2GdfJTfusSTLg8AO08bsI5ACsrlsrZ4skyXskalEWEajXCnoP8lPq7MP6p2GdfJTfusSTLg8AO08bsI5ACs5lPOHU3mP(22n5qXyBH)ltawXuNFV1wZ3RBMuFB7M0KXckKKkUNSFee)MILWmrDyC(9wBDVx3uSeMjQdJBsrRlOnVjsaqchCcZKBMuFB7MQUJNFV1UoUx3mP(22nvsSTLg4osm8o4BkwcZe1HX53BTRZ3RBMuFB7MWlt40gcHxcWDewq8BkwcZe1HX53BTX03RBkwcZe1HXnPO1f0M3K3qSahCIuKcisrxsblwsbgcayyIdwqHQg5jBavDZK6BB3eCAQqdeWdXuPD(9wBn596MILWmrDyCtkADbT5n5nelWbNifPOfis5zKcoKcTBMQ)ydoum2wqjX2wAWRHsZhijMRXjfTifnWLuWHuEIuODZu9hBWHIX2c)xMaSIPgijMRXjfTifDjfSyjfmtkEYeZhCOySTW)LjaRyQHyjmtuKs9KcoKcTBMQ)ydAYybfssf3t2pcIpqsmxJtkArkACZK6BB3eCAQqdeWdXuPD(9wdCVx3uSeMjQdJBsrRlOnVjmeaWqjX2wAG2izGKK6KcoKcVHybo4ePiLFjfnFZK6BB3ujX2GBMF(9wdTVx3uSeMjQdJBsrRlOnVjTBMQ)ydoum2wqjX2wAWRHsZhijMRXjLVKcTBMQ)ydoum2wqjX2wAWRHsZhkiu6BBKIwKcWIhShqsmxJtkyXskalEWEajXCnoP8lPq7MP6p2GdfJTfusSTLg8AO08bsI5ACs5lPOTU3mP(22nXJ2yVijaim8qjsD(9wdnUx3mP(22nH4syDjYVPyjmtuhgNFV14z3RBkwcZe1HXnPO1f0M3egcay8zzQWgR4dUN0FifTifTjfCifyiaGHsITT0aTrYG7j9hs5xs5z3mP(22nR6pckW3kWTD(9wdnFVUPyjmtuhg3KIwxqBEZNifM8xyKYVKIU4sk4qkj13)sqmjUcNu0Iu0GuWILusnTGwxgYZxXA((xcvTlMVjBGs7hsrlsrBsbhsbgcayipFfR57Fju1Uy(MSbsI5ACs5xs5zKs9KcoKcmeaW4ZYuHnwXhCpP)qkAbIuE2ntQVTDZnwXA(2253Bn09EDZK6BB3K3qSa3r7pYnflHzI6W487Tg1X96Mj132UjhCQ6pb4M53uSeMjQdJZp)MviH2r40Vx3BTVx3uSeMjQdJBsrRlOnVPVrHu0IuWLuWHuWmPuj(iz7F5Mj132UjGWcQoUw6BBNFV14EDZK6BB3KdfJTfaegEOePUPyjmtuhgNFVF296MILWmrDyCtkADbT5nHHaagFwMkSXk(G7j9hsrlsrBsbhsbgcayOKyBlnqBKm4Es)Hu(fePOXntQVTDZQ(JGc8TcCBNFV1896MILWmrDyCtkADbT5nHBoNuWILusQVTnusSn4M5dAYDsbePG7ntQVTDtLeBdUz(53BDVx3mP(22n5Gtv)ja3m)MILWmrDyC(9UoUx3uSeMjQdJB2v3Kl(ntQVTDZ)jAtyMCZ)jdsUjTBMQ)ydoum2wqjX2wAWRHsZhijMRXjLFjfDjfCiLNifmtkEYeZhQUJdXsyMOifSyjfLadbamuDhhqvKs9KcoKYtKcmeaWqjX2wAG7iXW7GhqvKcwSKcMjfpzI5dLeBBPbUJedVdEiwcZefPGflP4jtmFOKyBlnqBJdfR8TTHyjmtuKs9KcoKYtKcMjfpzI5dtCWcku1ipzdXsyMOifSyjfyiaGHjoybfQAKNSbufPGflPq7MP6p2WehSGcvnYt2ajXCnoPOfPOTUKs9KcoKYtKcMjfpzI5d8On2lscacdpuIudXsyMOifSyjfA3mv)Xg4rBSxKeaegEOePgijMRXjfTifT1LuQNuWHuEIuWmP4jtmFWHIX2c)xMaSIPgILWmrrkyXsk0UzQ(Jn4qXyBH)ltawXudKeZ14KIwKI26sk1tk4qkprkyMu8KjMpusSTLgOTXHIv(22qSeMjksblwsbgcay8zzQWgR4dOksblwsH3qSahCIuKcisrxsblwsbgcayyIdwqHQg5jBavrk4qk8gIf4GtKIu0IuWLuQ)M)tuWYOCtVgknpGKuv78ZVjhkgBl41qP53R7T23RBkwcZe1HXnPO1f0M3K3qSahCIuKcisr3BMuFB7MGttfAGaEiMkTBYwtcu1n1a3ZV3ACVUPyjmtuhg3KIwxqBEtyiaGHsITT0aTrYaQIuWHuEIu8KjMpusSTLgOTXHIv(22qSeMjksblwsbgcayyIdwqHQg5jBO6pgPu)ntQVTDtLeBdUz(nzRjbQ6MAG7537NDVUPyjmtuhg3KIwxqBEtyiaGXNLPcBSIp4Es)Hu(skRr74A4dBSItk)skAMuWHuEIu8KjMpusSTLgOTXHIv(22qSeMjksblwsbgcayyIdwqHQg5jBO6pgPu)ntQVTDto4u1FcWnZVjBnjqv3udCp)ER571ntQVTDtAYybfssf3t2pcIFtXsyMOomo)ER796Mj132Uj40uHgiGhIPs7MILWmrDyC(9UoUx3uSeMjQdJBsrRlOnVjmeaWqjX2wAG2izavrk4qkWqaadtCWcku1ipzdOksbhs5js5jsbgcay8FzcWkMAGKyUgNu0Iu0LuWILuWmP4jtmFWHIX2c)xMaSIPgILWmrrk1tk4qkprkWqaad8On2lscacdpuIudKeZ14KIwKIUKcwSKcmeaWapAJ9IKaGWWdLi1q1FmsPEsP(BMuFB7Mkj2gCZ8ZV31571nflHzI6W4Mu06cAZBcdbammXblOqvJ8KnGQifCiLNiLNifyiaGX)LjaRyQbsI5ACsrlsrxsblwsbZKINmX8bhkgBl8FzcWkMAiwcZefPupPGdP8ePadbamWJ2yVijaim8qjsnqsmxJtkArk6skyXskWqaad8On2lscacdpuIudv)XiL6jL6Vzs9TTBYbNQ(taUz(53Bm996MILWmrDyCtkADbT5n5nelWbNifNuark4EZK6BB3KdfJTfusSTLg8AO08ZV3AY71ntQVTDto4u1FcWnZVPyjmtuhgNF(nBaGaEQ6EDV1(EDtXsyMOomUjfTUG28MvIpusSTLg8AO08rs99VCZK6BB3ewqCb9ZA4p)ERX96MILWmrDyCtkADbT5nHHaagWcIlOFwd)aQIuWILuQeFOKyBln41qP5JK67FHuWHuWmPGsQmCuZy3mP(22nRAFB7879ZUx3uSeMjQdJBsrRlOnVzL4dLeBBPbVgknFKuF)l3mP(22nHzDRcaqOANFV1896MILWmrDyCtkADbT5nReFOKyBln41qP5JK67F5Mj132UjWIeyw3QZp)MEnuAEOcjv3R7T23RBkwcZe1HXntQVTDtv3XBYwtcu1nFgUNFV14EDtXsyMOomUjfTUG28MyMu8KjMpusSTLgOTXHIv(22qSeMjQBMuFB7Mkj22sdChjgEh8537NDVUzs9TTBAIdwqHQg5j7MILWmrDyC(9wZ3RBMuFB7M4rBSxKeaegEOePUPyjmtuhgNFV19EDZK6BB3KdfJTf(VmbyftDtXsyMOomo)Exh3RBMuFB7M0KXckKKkUNSFee)MILWmrDyC(9UoFVUPyjmtuhg3KIwxqBEtyiaGHsITT0aTrYaQIuWHu4nelWbNifP8lPOzsbhs5jsXtMy(qjX2wAG2ghkw5BBdXsyMOifSyjfyiaGHjoybfQAKNSHQ)yKs93mP(22nvsSn4M5NFVX03RBkwcZe1HXnPO1f0M3K3qSahCIuKYVKIUKcMqkAMuWuskWqaadtCWcku1ipzdOQBMuFB7MCWPQ)eGBMF(9wtEVUzs9TTBconvObc4HyQ0UPyjmtuhgNF(53mHCWn6MZnwNC(53b]] )


end
