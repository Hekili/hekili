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
                    table.insert( wild_imps, now + 22 )
                    
                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + 22 ),
                        max = math.ceil( now + 22 )
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
                if ( imp + 22 ) > query_time then
                    insert( wild_imps_v, imp + 22 )
                end
                remove( guldan_v, i )
            end
        end
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
                applied = function () local exp = wild_imps_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
                remains = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and max( 0, exp - query_time ) or 0 end,
                count = function () 
                    local c = 0
                    for i, exp in ipairs( wild_imps_v ) do
                        if exp > query_time then c = c + 1 end
                    end

                    -- Count queued HoG imps.
                    for i, spawn in ipairs( guldan_v ) do
                        if spawn <= query_time and ( spawn + 22 ) >= query_time then c = c + 1 end
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
                applied = function () local exp = vilefiend_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
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
                applied = function () local exp = other_demon_v[ 1 ]; return exp and ( exp - 12 ) or 0 end,
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
            
            readyTime = function () return debuff.doom.remains end,
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
            
            -- usable = function () return soul_shards.current >= 3 end,
            handler = function ()
                local extra_shards = min( 2, soul_shards.current )
                spend( extra_shards, "soul_shards" )

                insert( guldan_v, query_time + 1.05 )
                insert( guldan_v, query_time + 1.50 )
                insert( guldan_v, query_time + 1.90 )
                
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

            toggle = "cooldowns",
            
            startsCombat = true,
            
            handler = function ()
                summon_demon( "demonic_tyrant", 15 )
                applyBuff( "demonic_power", 15 )
                if talent.demonic_consumption.enabled then consume_demons( "wild_imps", "all" ) end
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


    spec:RegisterPack( "Demonology", 20190203.1448, [[dKusebqiPe9iPeSjPsFsQiXOKI6usrwLuvPxjfAwsfUfPeTlk(fIyyKs6ysvwMk4zqHPjvuxtkW2KQIVjveJtkH6CsbTosj08ujDpv0(qKoOucHfkL0dLQQQjkvvCrPIKSrPeI(OursDsPQQyLQqZuQkL2jPu)uQQknusjyPsfPEkctLu4QsvP4RsvPAVe9xcdMKdlzXOQhJ0Kr5YuTzu5ZqPrRsDAfVwLy2Q62uA3I(TWWjvhxQkz5GEoKPR01HQTtk67sPgVuvLZdfTEPesZhrTFGL9KAijy16sTpO1EnuRh0kgMEDUZTymoijwm1DjHErVuyDjrwwxs0pUnY4dSykj0lm)OysnKeOahsDjX9U6iTijKGD2BCEdnSKGgl(x7ejfwCljOXsjH)dEs45kTK5AsIom4M3rKOfGENUggIeTqNw03l4h0lI(XTrgFGftdASujbp(8B)tk5LeSADP2h0AVgQ1dAfdtVo35En4GKaP7uP2h6tFKe3dJ5PKxsWCevs0cav)42iJpWIjq13l4h0lGJTaqDVRoslscjyN9gN3qdljOXI)1orsHf3scASus4)GNeEUslzUMKOddU5DejAbO3PRHHirl0Pf99c(b9IOFCBKXhyX0GglfCSfaQwKopeVGycuy0bqDqR9AiqPLavVoRfXOtahbhBbGQ)FxjwhPfbhBbGslbkcD)FGQVnOxmGJTaqPLavFdYbkECoot67Tdf6bCR3GRdutIwVyavWbuq3wtojwGQ)3pa1owhO4ciqPTV3oeO0cbCRhOk6oA6aL(DHCd4ylauAjq1)MpMaf0PH16jdO6h3gjF8lqPdDTKgw(AbQHdOMfOgeqnjARCbQMr3b(ZakDyWx8pMafAN)bQ7cYOfABYao2caLwcuAHOTdbkIr)osGQ(pA7mGsh6AjnS81cuBau6WGcutI2kxGQFCBK8XVgjHom4M3LeTaq1pUnY4dSycu99c(b9c4ylau37QJ0IKqc2zVX5n0WscAS4FTtKuyXTKGglLe(p4jHNR0sMRjj6WGBEhrIwa6D6Ayis0cDArFVGFqVi6h3gz8bwmnOXsbhBbGQfPZdXliMafgDauh0AVgcuAjq1RZArm6eWrWXwaO6)3vI1rArWXwaO0sGIq3)hO6Bd6fd4ylauAjq13GCGIhNJZK(E7qHEa36n46a1KO1lgqfCaf0T1KtIfO6)9dqTJ1bkUacuA77TdbkTqa36bQIUJMoqPFxi3ao2caLwcu9V5JjqbDAyTEYaQ(XTrYh)cu6qxlPHLVwGA4aQzbQbbutI2kxGQz0DG)mGshg8f)JjqH25FG6UGmAH2MmGJTaqPLaLwiA7qGIy0VJeOQ)J2odO0HUwsdlFTa1gaLomOa1KOTYfO6h3gjF8RbCeCSfaQov9NtXxNbu8oxaDGIgw(AbkEh7Kidq1IGsD9fbuzKA5DbTC4pqv0DIebur(yAahl6orIm6qNgw(Ap5(cDbCSO7ejYOdDAy5RTXts4IGbow0DIez0HonS8124jjfowRNBTtKGJfDNirgDOtdlFTnEscc3AJuO7l4yr3jsKrh60WYxBJNKmz6qbZTrI6y4o369CntMouWCBKiJNf)7mWXIUtKiJo0PHLV2gpjrpA7qbA0VJSJH7KhNJZ0EEMyS6idAl6fs7bow0DIez0HonS8124jj6Xorcow0DIez0HonS8124jjm3gjF8Bhd3jFGqKjx0DI0WCBK8XVgAHwXow)uRGJGJTaq1PQ)Ck(6mGY10Hycu7yDGAVDGQOBabQbbuLM18f)7gWXIUtKOtKU)V4d6fWXIUtKOgpjrp2jYogUtDFnm3g5qflMWkxtr3rthCSO7ejQXtsWrUyw3I6y4o191WCBKdvSycRCnfDhnDWXIUtKOgpjH3HihEzsSDmCN6(AyUnYHkwmHvUMIUJMo4yr3jsuJNKW)rWeC4qm7y4o191WCBKdvSycRCnfDhnDWXIUtKOgpjHBGo)hbRJH7u3xdZTrouXIjSY1u0D00bhl6orIA8KK7kzIGtGf)zv2XWDwTOoCw349N(hOrtxOhRN7uVbw5LU7y9RnOlkWFb6UGmsp0LhNJZ49N(hOrtxOhRN7uVHfTZU84CCM2ZZeJvhzqBrVCfJUTuh6AkWszMEM7kzIGtGf)zv2TL6qxtbwkZCWCxjteCcS4pRsWXIUtKOgpjzS6FGMi7y4oRwuhoRB8(t)d0OPl0J1ZDQ3aR8sxECoot75zIXQJmOTOxi9qxECooJ3F6FGgnDHESEUt9gw0obhl6orIA8Kewe2ogUZwUd9YKy7UfeRVMDSUydbBCsXqRDr6()ITGy9fzgR(hOjYRhahl6orIA8KeMBJCOc0c9e7E3XWD2mpohNP98mXy1rg0w0lx7dzY84CCgMBJCOc9OTdn46nrMms3)xSfeRViZy1)anrE9a4yr3jsuJNKqR)ffDNif)G2oYY6NPV3ouOhWT(ogUZTEpxt67Tdf6bCR34zX)oRls3)xSfeRViZy1)anrE98a4yr3jsuJNKqR)ffDNif)G2oYY6NJv)d0ezhd3js3)xSfeRViZy1)anrsApWXIUtKOgpjblCSXaDbN)yXliRJH7KgXZI2PbHBTrkyUnYHkwmHvUgOBRjrx7HbzYT07l8rx3zMEyCaJ(0qWXIUtKOgpjbHBTrk0CENB8K1XWD69f(OR7mtpmoGrFAizY0iEw0oniCRnsbZTrouXIjSY1aDBnjI0oRvYKPr8SODAq4wBKcMBJCOIftyLRb62As01Ehahl6orIA8KeA9VGb9IH26V4quhd3P3x4JUUZm9W4ag9PHKj3mnINfTtdc3AJuWCBKdvSycRCnq3wtIU2WU84CCgMBJCOcA9)Kynq3wtIAIm5MPr8SODAq4wBKcMBJCOIftyLRb62As01E962sECoodZTroubT(FsSgOBRjrnrMmnINfTtdc3AJuWCBKdvSycRCnq3wtIiTxNbhl6orIA8KeeU1gPG52ihQyXew52XWD69f(OR7mtpmoGrFAizYnZJZXzyqVyOT(loezGUTMerkTqRyhR3TzECoot75zIXQJmOTOxi9eJg369CntMouWCBKiJNf)7Sg369Cnm3g5qf0ir4w9DI04zX)oRFXGmzDORPalLz6zURKjcobw8Nvz3MB5wVNRH52ihQGgjc3QVtKgpl(3zKjZJZXzApptmwDKbTf9cPNy04wVNRzY0HcMBJez8S4FN1utDBgf4VaDxq2vmitMhNJZWGEXqB9xCiYaDBnj6kwkRFpy6eYK5X54myHJngOl48hlEbzgOBRjrxXsz97btN0utGJfDNirnEsIE02Hc0OFhzhd3jpohNP98mXy1rg0w0lKEEOlpohNH52ihQGgq3G2IE565HU84CCgMBJCOc9OTdnSOD2fP7)l2cI1xKzS6FGMiVEaCSO7ejQXtsyry7y4o369CnSiSgpl(3zDHoh0r3f)7D3cI1xZowxSHGnoPnZI1WIWAGUTMe1igATjWXIUtKOgpj5UsMi4eyXFwLDmCNOa)fO7cYi9SbKj3mkWFb6UGmspXOlnINfTtdT(xWGEXqB9xCiYaDBnjI0o3T5wU175Aq4wBKcnN35gpzgpl(3zKjtJ4zr70GWT2ifAoVZnEYmq3wtIifJMAcCSO7ejQXtsqb(lqlCU4DmCNOa)fO7cYU2GU84CCgMBJCOcAaDdAl6LRNhahl6orIA8KeMBJKp(TJH7ef4VaDxq21tm6YJZXzyUnYHkOb0n46DBUzAeplANgeU1gPG52ihQyXew5AGUTMeDTNwjtMgXZI2PbHBTrkyUnYHkwmHvUgOBRjrKE4qtKjZJZXzyUnYHkOb0nOTOxi9edYK5X54mm3g5qf0a6gOBRjrxBazY7yDXgc24xp0GMahl6orIA8Ke(5DenWHyDbFy5DicCSO7ejQXtsO1)IIUtKIFqBhzz9tE85zIsGUlidCeCSO7ejYWJpptuc0DbzNOa)fOfoxCWXIUtKidp(8mrjq3fK14jjO7IfTf8XVGJGJfDNirMXQ)bAI8CS6FGMi7y4oBMhNJZ0EEMyS6idAl6fsp7t3Mrb(lq3fKDfdYK1HUMcSuMPNHw)lyqVyOT(loerMmpohNP98mXy1rg0w0lKE2qYK1HUMcSuMPNHFEhrdCiwxWhwEhIitU5wQdDnfyPmtpZDLmrWjWI)Sk72sDORPalLzoyURKjcobw8Nvztn1TL6qxtbwkZ0ZCxjteCcS4pRYUTuh6AkWszMdM7kzIGtGf)zv2LhNJZWCBKdvOhTDOHfTZMitU5DSUydbB8Ry0LhNJZ0EEMyS6idAl6fs1AtKj3So01uGLYmhm06Fbd6fdT1FXHOU84CCM2ZZeJvhzqBrVq6HUTCR3Z1WCBKdvqR)NeRXZI)DwtGJfDNirMXQ)bAISXtsWchBmqxW5pw8cY6y4oPr8SODAq4wBKcMBJCOIftyLRb62As01EyqMCl9(cF01DMPhghWOpneCSO7ejYmw9pqtKnEscT(xWGEXqB9xCiQJH7SzAeplANgeU1gPG52ihQyXew5AGUTMeDTHD5X54mm3g5qf06)jXAGUTMe1ezYntJ4zr70GWT2ifm3g5qflMWkxd0T1KOR961TL84CCgMBJCOcA9)Kynq3wtIAImzAeplANgeU1gPG52ihQyXew5AGUTMerAVodow0DIezgR(hOjYgpjbHBTrkyUnYHkwmHvUGJfDNirMXQ)bAISXtsURKjcobw8Nvzhd3jkWFb6UGmspBa4yr3jsKzS6FGMiB8KK7kzIGtGf)zv2XWDIc8xGUliJ0tm62CZnRdDnfyPmZbZDLmrWjWI)SkjtMhNJZ0EEMyS6idAl6fspXOPU84CCM2ZZeJvhzqBrVCTHnrMmnINfTtdc3AJuWCBKdvSycRCnq3wtIUEILY63dKjZJZXzyUnYHk0J2o0aDBnjIuSuw)EOjWXIUtKiZy1)anr24jjm3gjF8Bhd3Po01uGLYm9m3vYebNal(ZQSlkWFb6UGmsp71TzECoot75zIXQJmOTOxUEIbzY6qxtbwkZGH5UsMi4eyXFwLn1ff4VaDxq21o3LhNJZWCBKdvqdOBW1bhl6orImJv)d0ezJNKGWT2ifAoVZnEY6y4oBMgXZI2PbHBTrkyUnYHkwmHvUgOBRjrK2zT2fP7)l2cI1xKzS6FGMiVEEOjYKPr8SODAq4wBKcMBJCOIftyLRb62As01Ehahl6orImJv)d0ezJNKWpVJOboeRl4dlVdrDmCN0iEw0oniCRnsbZTrouXIjSY1aDBnjI0gcow0DIezgR(hOjYgpjbf4VaTW5I3XWDIc8xGUli7Ad6YJZXzyUnYHkOb0nOTOxUEEaCSO7ejYmw9pqtKnEscZTrYh)2XWDIc8xGUli76jgD5X54mm3g5qf0a6gC9UnZJZXzyUnYHkOb0nOTOxi9edYK5X54mm3g5qf0a6gOBRjrxpXsz9BdmDstGJfDNirMXQ)bAISXtsyry7GIj9DXwqS(Io71HT6pbft67ITGy9fD2jDmCNqNd6O7I)DWXIUtKiZy1)anr24jj06Frr3jsXpOTJSS(jp(8mrjq3fKbocow0DIezsFVDOqpGB9N06Frr3jsXpOTJSS(z67Tdf6bCRxWJppBsSDmCN0iEw0onPV3ouOhWTEd0T1KORh0k4yr3jsKj992Hc9aU134jj06Frr3jsXpOTJSS(z67Tdf6bCRxu0D007y4o5X54mPV3ouOhWTEdUo4i4yr3jsKj992Hc9aU1lk6oA6N8Z7iAGdX6c(WY7qe4yr3jsKj992Hc9aU1lk6oA6nEscw4yJb6co)XIxqwhd3jnINfTtdc3AJuWCBKdvSycRCnq3wtIU2ddYKBP3x4JUUZm9W4ag9PHGJfDNirM03Bhk0d4wVOO7OP34jjiCRnsHMZ7CJNSogUtAeplANgeU1gPG52ihQyXew5AGUTMerAN1kzY0iEw0oniCRnsbZTrouXIjSY1aDBnj6AVdGJfDNirM03Bhk0d4wVOO7OP34jj06Fbd6fdT1FXHOogUZMPr8SODAq4wBKcMBJCOIftyLRb62As01g2LhNJZWCBKdvqR)NeRb62AsutKj3mnINfTtdc3AJuWCBKdvSycRCnq3wtIU2Rx3wYJZXzyUnYHkO1)tI1aDBnjQjYKPr8SODAq4wBKcMBJCOIftyLRb62AseP96m4yr3jsKj992Hc9aU1lk6oA6nEsc)8oIg4qSUGpS8oebow0DIezsFVDOqpGB9IIUJMEJNKqR)ffDNif)G2oYY6N84ZZeLaDxqwhd3jkWFb6UGSZEDBMgXZI2PHw)lyqVyOT(loezGUTMeDTO7ePbDxSOTGp(1ql0k2X6Kj38wVNRHFEhrdCiwxWhwEhImEw8VZ6sJ4zr70WpVJOboeRl4dlVdrgOBRjrxl6orAq3flAl4JFn0cTIDSEtnbow0DIezsFVDOqpGB9IIUJMEJNKCxjteCcS4pRYogUZMBMgXZI2PHw)lyqVyOT(loezGUTMerAr3jsdZTrYh)AOfAf7y9M62mnINfTtdT(xWGEXqB9xCiYaDBnjI0IUtKg0DXI2c(4xdTqRyhR3utDPr8SODAsFVDOqpGB9gOBRjrK2CV(0Ggl6orAURKjcobw8NvPHwOvSJ1BcCSO7ejYK(E7qHEa36ffDhn9gpjbHBTrkyUnYHkwmHvUDmCN84CCM03Bhk0d4wVb62As01g0ff4VaDxq2Pwbhl6orImPV3ouOhWTErr3rtVXtsq4wBKcMBJCOIftyLBhd3jpohNj992Hc9aU1BGUTMeDTO7ePbHBTrkyUnYHkwmHvUgAHwXowVrTAAa4yr3jsKj992Hc9aU1lk6oA6nEscZTrYh)2XWDYJZXzyUnYHkOb0n46GJfDNirM03Bhk0d4wVOO7OP34jj06Frr3jsXpOTJSS(jp(8mrjq3fKbocow0DIezsFVDOqpGB9cE85ztI9m992Hc9aU13XWDIc8xGUliJ0Zg0T5wU175A0J2ouGg97inEw8VZitMhNJZWCBKdvqdOBW1BcCSO7ejYK(E7qHEa36f84ZZMeBJNKqR)fmOxm0w)fhIahl6orImPV3ouOhWTEbp(8SjX24jj3vYebNal(ZQSJH7KgXZI2PHw)lyqVyOT(loezGUTMerAVwCxuG)c0DbzKEIb4yr3jsKj992Hc9aU1l4XNNnj2gpjrpA7qbA0VJSJH7KhNJZ0EEMyS6idAl6fspp0LhNJZWCBKdvqdOBqBrVC98qxECoodZTrouHE02Hgw0o7Ic8xGUliJ0tmahl6orImPV3ouOhWTEbp(8SjX24jj3vYebNal(ZQSJH7ef4VaDxqgPNnaCSO7ejYK(E7qHEa36f84ZZMeBJNKqR)ffDNif)G2oYY6N84ZZeLaDxqMKqthIMiLAFqR9AOw7HrpJwBydAOKODbZjXIKe99weDAT7F0UtTweOaknUDGAS6bCbkUacuDk6qNgw(A7uakO3x4d0zafkSoqv4ByR1zaf9UsSoYao23oPdunqlcu9njcxxpGRZaQIUtKavNYKPdfm3gjQtXaoco2)y1d46mGQtaQIUtKa1pOfzahLe)GwKudjr67Tdf6bCRxu0D00LAi1UNudjrr3jsjb)8oIg4qSUGpS8oejj8S4FNjBvUsTpi1qs4zX)ot2QKGcN1HtjjOr8SODAq4wBKcMBJCOIftyLRb62AseqDfO6HbqrMmq1sGY7l8rx3zMEyCaJ(0qjrr3jsjbw4yJb6co)XIxqMCLAJHudjHNf)7mzRsckCwhoLKGgXZI2PbHBTrkyUnYHkwmHvUgOBRjrafPavN1kqrMmqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq17GKOO7ePKaHBTrk0CENB8KjxP2DwQHKWZI)DMSvjbfoRdNss0mqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq1qGQlqXJZXzyUnYHkO1)tI1aDBnjcOAcOitgOAgOOr8SODAq4wBKcMBJCOIftyLRb62AseqDfO61dO6cuTeO4X54mm3g5qf06)jXAGUTMebunbuKjdu0iEw0oniCRnsbZTrouXIjSY1aDBnjcOifO61zjrr3jsjbT(xWGEXqB9xCisUsTBGudjrr3jsjb)8oIg4qSUGpS8oejj8S4FNjBvUsT7JudjHNf)7mzRsIIUtKscA9VOO7eP4h0kjOWzD4uscuG)c0Dbza1jq1dO6cundu0iEw0on06Fbd6fdT1FXHid0T1KiG6kqv0DI0GUlw0wWh)AOfAf7yDGImzGQzGAR3Z1WpVJOboeRl4dlVdrgpl(3zavxGIgXZI2PHFEhrdCiwxWhwEhImq3wtIaQRavr3jsd6UyrBbF8RHwOvSJ1bQMaQMKe)GwrwwxsWJpptuc0DbzYvQDNi1qs4zX)ot2QKGcN1HtjjAgOAgOOr8SODAO1)cg0lgAR)IdrgOBRjrafPavr3jsdZTrYh)AOfAf7yDGQjGQlq1mqrJ4zr70qR)fmOxm0w)fhImq3wtIaksbQIUtKg0DXI2c(4xdTqRyhRdunbunbuDbkAeplANM03Bhk0d4wVb62Aseqrkq1mq1RpnaOAeOk6orAURKjcobw8NvPHwOvSJ1bQMKefDNiLe3vYebNal(ZQuUsTBXsnKeEw8VZKTkjOWzD4uscECoot67Tdf6bCR3aDBnjcOUcunaO6cuOa)fO7cYaQtGsRsIIUtKsceU1gPG52ihQyXew5kxP2nuQHKWZI)DMSvjbfoRdNssWJZXzsFVDOqpGB9gOBRjra1vGQO7ePbHBTrkyUnYHkwmHvUgAHwXowhOAeO0QPbsIIUtKsceU1gPG52ihQyXew5kxP290QudjHNf)7mzRsckCwhoLKGhNJZWCBKdvqdOBW1LefDNiLem3gjF8RCLA3RNudjHNf)7mzRsIIUtKscA9VOO7eP4h0kj(bTISSUKGhFEMOeO7cYKRCLemNRW)vQHu7EsnKefDNiLeiD)FXh0lscpl(3zYwLRu7dsnKeEw8VZKTkjOWzD4uscDFnm3g5qflMWkxtr3rtxsu0DIusOh7ePCLAJHudjHNf)7mzRsckCwhoLKq3xdZTrouXIjSY1u0D00LefDNiLe4ixmRBrYvQDNLAij8S4FNjBvsqHZ6WPKe6(AyUnYHkwmHvUMIUJMUKOO7ePKG3HihEzsSYvQDdKAij8S4FNjBvsqHZ6WPKe6(AyUnYHkwmHvUMIUJMUKOO7ePKG)JGj4WHykxP29rQHKWZI)DMSvjbfoRdNssO7RH52ihQyXew5Ak6oA6sIIUtKscUb68Fem5k1UtKAij8S4FNjBvsqHZ6WPKevlQdN1nE)P)bA00f6X65o1BGvEbO6cu7yDG6kq1aGQlqHc8xGUlidOifOoauDbkECooJ3F6FGgnDHESEUt9gw0obQUafpohNP98mXy1rg0w0la1vGcdGQlq1sGsh6AkWszMEM7kzIGtGf)zvcuDbQwcu6qxtbwkZCWCxjteCcS4pRsjrr3jsjXDLmrWjWI)SkLRu7wSudjHNf)7mzRsckCwhoLKOArD4SUX7p9pqJMUqpwp3PEdSYlavxGIhNJZ0EEMyS6idAl6fGIuG6aq1fO4X54mE)P)bA00f6X65o1Byr7usu0DIusmw9pqtKYvQDdLAij8S4FNjBvsqHZ6WPKeTeO2HEzsSavxGAliwFn7yDXgc24afPafgAfO6cuiD)FXwqS(ImJv)d0ejqDfOoijk6orkjyryLRu7EAvQHKWZI)DMSvjbfoRdNss0mqXJZXzApptmwDKbTf9cqDfO6dqrMmqXJZXzyUnYHk0J2o0GRdunbuKjduiD)FXwqS(ImJv)d0ejqDfOoijk6orkjyUnYHkql0tS7TCLA3RNudjHNf)7mzRsIIUtKscA9VOO7eP4h0kjOWzD4usITEpxt67Tdf6bCR34zX)odO6cuiD)FXwqS(ImJv)d0ejqD9eOoij(bTISSUKi992Hc9aU1lxP29oi1qs4zX)ot2QKOO7ePKGw)lk6ork(bTsckCwhoLKaP7)l2cI1xKzS6FGMibksbQEsIFqRilRljgR(hOjs5k1UhgsnKeEw8VZKTkjOWzD4uscAeplANgeU1gPG52ihQyXew5AGUTMebuxbQEyauKjduTeO8(cF01DMPhghWOpnusu0DIusGfo2yGUGZFS4fKjxP296SudjHNf)7mzRsckCwhoLKW7l8rx3zMEyCaJ(0qGImzGIgXZI2PbHBTrkyUnYHkwmHvUgOBRjrafPavN1kqrMmqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq17GKOO7ePKaHBTrk0CENB8KjxP29AGudjHNf)7mzRsckCwhoLKW7l8rx3zMEyCaJ(0qGImzGQzGIgXZI2PbHBTrkyUnYHkwmHvUgOBRjra1vGQHavxGIhNJZWCBKdvqR)NeRb62Aseq1eqrMmq1mqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq1Rhq1fOAjqXJZXzyUnYHkO1)tI1aDBnjcOAcOitgOOr8SODAq4wBKcMBJCOIftyLRb62Aseqrkq1RZsIIUtKscA9VGb9IH26V4qKCLA3RpsnKeEw8VZKTkjOWzD4uscVVWhDDNz6HXbm6tdbkYKbQMbkECoodd6fdT1FXHid0T1KiGIuGIwOvSJ1bQUavZafpohNP98mXy1rg0w0lafPNafgavJa1wVNRzY0HcMBJez8S4FNbuncuB9EUgMBJCOcAKiCR(orA8S4FNbu9lqHbqrMmqPdDnfyPmtpZDLmrWjWI)SkbQUavZavlbQTEpxdZTroubnseUvFNinEw8VZakYKbkECoot75zIXQJmOTOxakspbkmaQgbQTEpxZKPdfm3gjY4zX)odOAcOAcO6cunduOa)fO7cYaQRafgafzYafpohNHb9IH26V4qKb62AseqDfOWszav)cuhmDcqrMmqXJZXzWchBmqxW5pw8cYmq3wtIaQRafwkdO6xG6GPtaQMaQMKefDNiLeiCRnsbZTrouXIjSYvUsT71jsnKeEw8VZKTkjOWzD4uscECoot75zIXQJmOTOxakspbQdavxGIhNJZWCBKdvqdOBqBrVauxpbQdavxGIhNJZWCBKdvOhTDOHfTtGQlqH09)fBbX6lYmw9pqtKa1vG6GKOO7ePKqpA7qbA0VJuUsT71ILAij8S4FNjBvsqHZ6WPKeB9EUgwewJNf)7mGQlqbDoOJUl(3bQUa1wqS(A2X6IneSXbksbQMbkwSgwewd0T1KiGQrGcdTcunjjk6orkjyryLRu7EnuQHKWZI)DMSvjbfoRdNssGc8xGUlidOi9eOAaqrMmq1mqHc8xGUlidOi9eOWaO6cu0iEw0on06Fbd6fdT1FXHid0T1KiGIuGQZavxGQzGQLa1wVNRbHBTrk0CENB8Kz8S4FNbuKjdu0iEw0oniCRnsHMZ7CJNmd0T1KiGIuGcdGQjGQjjrr3jsjXDLmrWjWI)SkLRu7dAvQHKWZI)DMSvjbfoRdNssGc8xGUlidOUcunaO6cu84CCgMBJCOcAaDdAl6fG66jqDqsu0DIusGc8xGw4CXLRu7d9KAij8S4FNjBvsqHZ6WPKeOa)fO7cYaQRNafgavxGIhNJZWCBKdvqdOBW1bQUavZavZafnINfTtdc3AJuWCBKdvSycRCnq3wtIaQRavpTcuKjdu0iEw0oniCRnsbZTrouXIjSY1aDBnjcOifOoCaOAcOitgO4X54mm3g5qf0a6g0w0lafPNafgafzYafpohNH52ihQGgq3aDBnjcOUcunaOitgO2X6IneSXbQRa1Hgaunjjk6orkjyUns(4x5k1(WbPgsIIUtKsc(5DenWHyDbFy5Diss4zX)ot2QCLAFadPgscpl(3zYwLefDNiLe06Frr3jsXpOvs8dAfzzDjbp(8mrjq3fKjx5kj0HonS81k1qQDpPgscpl(3zYwLRu7dsnKeEw8VZKTkxP2yi1qs4zX)ot2QCLA3zPgsIIUtKsceU1gPGZFS4fKjj8S4FNjBvUsTBGudjHNf)7mzRsckCwhoLKyR3Z1mz6qbZTrImEw8VZKefDNiLetMouWCBKi5k1UpsnKeEw8VZKTkjOWzD4uscECoot75zIXQJmOTOxaksbQEsIIUtKsc9OTdfOr)os5k1UtKAijk6orkj0JDIus4zX)ot2QCLA3ILAij8S4FNjBvsqHZ6WPKe8bcbuKjdufDNinm3gjF8RHwOvSJ1bQtGsRsIIUtKscMBJKp(vUYvsK(E7qHEa36LAi1UNudjHNf)7mzRsIIUtKscA9VOO7eP4h0kjOWzD4uscAeplANM03Bhk0d4wVb62AseqDfOoOvjXpOvKL1LePV3ouOhWTEbp(8SjXkxP2hKAij8S4FNjBvsu0DIusqR)ffDNif)GwjbfoRdNssWJZXzsFVDOqpGB9gCDjXpOvKL1LePV3ouOhWTErr3rtxUYvsK(E7qHEa36f84ZZMeRudP29KAij8S4FNjBvsqHZ6WPKeOa)fO7cYakspbQgauDbQMbQwcuB9EUg9OTdfOr)osJNf)7mGImzGIhNJZWCBKdvqdOBW1bQMKefDNiLePV3ouOhWTE5k1(Gudjrr3jsjbT(xWGEXqB9xCiss4zX)ot2QCLAJHudjHNf)7mzRsckCwhoLKGgXZI2PHw)lyqVyOT(loezGUTMebuKcu9AXavxGcf4VaDxqgqr6jqHHKOO7ePK4UsMi4eyXFwLYvQDNLAij8S4FNjBvsqHZ6WPKe84CCM2ZZeJvhzqBrVauKEcuhaQUafpohNH52ihQGgq3G2IEbOUEcuhaQUafpohNH52ihQqpA7qdlANavxGcf4VaDxqgqr6jqHHKOO7ePKqpA7qbA0VJuUsTBGudjHNf)7mzRsckCwhoLKaf4VaDxqgqr6jq1ajrr3jsjXDLmrWjWI)SkLRu7(i1qs4zX)ot2QKOO7ePKGw)lk6ork(bTsIFqRilRlj4XNNjkb6UGm5kxjbp(8mrjq3fKj1qQDpPgsIIUtKscuG)c0cNlUKWZI)DMSv5k1(Gudjrr3jsjb6UyrBbF8RKWZI)DMSv5kxjXy1)anrk1qQDpPgscpl(3zYwLeu4SoCkjrZafpohNP98mXy1rg0w0lafPNavFaQUavZafkWFb6UGmG6kqHbqrMmqPdDnfyPmtpdT(xWGEXqB9xCicOitgO4X54mTNNjgRoYG2IEbOi9eOAiqrMmqPdDnfyPmtpd)8oIg4qSUGpS8oebuKjdunduTeO0HUMcSuMPN5UsMi4eyXFwLavxGQLaLo01uGLYmhm3vYebNal(ZQeOAcOAcO6cuTeO0HUMcSuMPN5UsMi4eyXFwLavxGQLaLo01uGLYmhm3vYebNal(ZQeO6cu84CCgMBJCOc9OTdnSODcunbuKjdundu7yDXgc24a1vGcdGQlqXJZXzApptmwDKbTf9cqrkqPvGQjGImzGQzGsh6AkWszMdgA9VGb9IH26V4qeq1fO4X54mTNNjgRoYG2IEbOifOoauDbQwcuB9EUgMBJCOcA9)KynEw8VZaQMKefDNiLeJv)d0ePCLAFqQHKWZI)DMSvjbfoRdNssqJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq1ddGImzGQLaL3x4JUUZm9W4ag9PHsIIUtKscSWXgd0fC(JfVGm5k1gdPgscpl(3zYwLeu4SoCkjrZafnINfTtdc3AJuWCBKdvSycRCnq3wtIaQRavdbQUafpohNH52ihQGw)pjwd0T1KiGQjGImzGQzGIgXZI2PbHBTrkyUnYHkwmHvUgOBRjra1vGQxpGQlq1sGIhNJZWCBKdvqR)NeRb62Aseq1eqrMmqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiGIuGQxNLefDNiLe06Fbd6fdT1FXHi5k1UZsnKefDNiLeiCRnsbZTrouXIjSYvs4zX)ot2QCLA3aPgscpl(3zYwLeu4SoCkjbkWFb6UGmGI0tGQbsIIUtKsI7kzIGtGf)zvkxP29rQHKWZI)DMSvjbfoRdNssGc8xGUlidOi9eOWaO6cundundundu6qxtbwkZCWCxjteCcS4pRsGImzGIhNJZ0EEMyS6idAl6fGI0tGcdGQjGQlqXJZXzApptmwDKbTf9cqDfOAiq1eqrMmqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG66jqHLYaQ(fOoauKjdu84CCgMBJCOc9OTdnq3wtIaksbkSugq1Va1bGQjjrr3jsjXDLmrWjWI)SkLRu7orQHKWZI)DMSvjbfoRdNssOdDnfyPmtpZDLmrWjWI)SkbQUafkWFb6UGmGI0tGQhq1fOAgO4X54mTNNjgRoYG2IEbOUEcuyauKjdu6qxtbwkZGH5UsMi4eyXFwLavtavxGcf4VaDxqgqDfO6mq1fO4X54mm3g5qf0a6gCDjrr3jsjbZTrYh)kxP2TyPgscpl(3zYwLeu4SoCkjrZafnINfTtdc3AJuWCBKdvSycRCnq3wtIaksbQoRvGQlqH09)fBbX6lYmw9pqtKa11tG6aq1eqrMmqrJ4zr70GWT2ifm3g5qflMWkxd0T1KiG6kq17GKOO7ePKaHBTrk0CENB8KjxP2nuQHKWZI)DMSvjbfoRdNssqJ4zr70GWT2ifm3g5qflMWkxd0T1KiGIuGQHsIIUtKsc(5DenWHyDbFy5DisUsT7PvPgscpl(3zYwLeu4SoCkjbkWFb6UGmG6kq1aGQlqXJZXzyUnYHkOb0nOTOxaQRNa1bjrr3jsjbkWFbAHZfxUsT71tQHKWZI)DMSvjbfoRdNssGc8xGUlidOUEcuyauDbkECoodZTroubnGUbxhO6cundu84CCgMBJCOcAaDdAl6fGI0tGcdGImzGIhNJZWCBKdvqdOBGUTMebuxpbkSugq1VavdmDcq1KKOO7ePKG52i5JFLRu7EhKAij8S4FNjBvsu0DIusWIWkjOysFxSfeRViP29Ke2Q)eumPVl2cI1xKKOtKeu4SoCkjb05Go6U4FxUsT7HHudjHNf)7mzRsIIUtKscA9VOO7eP4h0kj(bTISSUKGhFEMOeO7cYKRCLRKOW37akjigB)xUYvkb]] )

    
end
