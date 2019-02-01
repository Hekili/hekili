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


    spec:RegisterPack( "Demonology", 20190131.0959, [[dK0bfbqiPu8icQAtsfFskOYOKICkPOwLkf5vsHMLuj3ski7Is)cQQHrq5ysvwMkvpJuQPPsjxtkW2uPuFtQumoPsPoNukTocQ08urDpvyFeKdkfu1cLs1dvPOAIQuOlkvQcFuQufDsPsvALsvntPsv5Msbf2jPKFkfu0qjOILkvk5PimvsHRkvQQ(QkfL9s0Fr1Gj5WswmHEmstgLlt1Mr0NvjJgQCAfVwfz2Q62uSBr)wy4KQJlvQSCiphy6kDDOSDsrFxkz8QuW5HQSEPGsZNa7h0YEsnKeSADPw3fwV2kSEA3Z2tycRBe2TKelE6UKqVONQlxsKLXLe3OBIm(4cpjHEH3hftQHKaeyiQljWTRoq4Ip(xZIdt0sdd(GXG91orsrf5Ipymu8f)qeFrYQHyUM4RJcY5Da(chK3TQHbWx40T43Sc9b9e)gDtKXhx4zbJHkjeXMF7EtPOKGvRl16UW61wH1t7E2Ecty3Ub3LeaDNk16(TVTKa3WyEkfLemhqLecpuDJUjY4Jl8GQBwH(GEc2x4HkC7QdeU4J)1S4WeT0WGpymyFTtKuurU4dgdfFXpeXxKSAiMRj(6OGCEhGVWb5DRAya8foDl(nRqFqpXVr3ez8XfEwWyOW(cpu1VsScHhuPDVUGQ7cRxBHQgcQARWTbTfQA4Bya7d7l8q1nhxLxoq4c7l8qvdbve6()qv3xqpzH9fEOQHGQUFGdvIyKK20xCoIRhOTElMounjy9IbvbjuHCtn5Kxq1n)gHQDmourgiOslFX5iOs4eOTEOQO7OPdv64kGBH9fEOQHGQgM5JhuHCAymEYGQB0nrkg)cv6iVHOHrSwOAiHQzHQbavtc2kxOQjaUa7zqLokelXhpOcSZ)qfUcXOfyB2c7l8qvdbvcNOLJGkIrhxKqv9F0YzqLoYBiAyeRfQ2aQ0rbfQMeSvUq1n6MifJFTscDuqoVljeEO6gDtKXhx4bv3Sc9b9eSVWdv42vhiCXh)RzXHjAPHbFWyW(ANiPOICXhmgk(IFiIViz1qmxt81rb58oaFHdY7w1Wa4lC6w8BwH(GEIFJUjY4Jl8SGXqH9fEOQFLyfcpOs7EDbv3fwV2cvneu1wHBdAlu1W3Wa2h2x4HQBoUkVCGWf2x4HQgcQi09)HQUVGEYc7l8qvdbvD)ahQeXijTPV4CexpqB9wmDOAsW6fdQcsOc5MAYjVGQB(ncv7yCOImqqLw(IZrqLWjqB9qvr3rthQ0Xva3c7l8qvdbvnmZhpOc50Wy8Kbv3OBIum(fQ0rEdrdJyTq1qcvZcvdaQMeSvUqvtaCb2ZGkDuiwIpEqfyN)HkCfIrlW2Sf2x4HQgcQeorlhbveJoUiHQ6)OLZGkDK3q0WiwluTbuPJckunjyRCHQB0nrkg)AH9H9fEOQ7Xn4uS1zqLOtgihQOHrSwOs0VMeyHQgEk11xauLr2q4kKHe7HQIUtKaOkYhplSFr3jsGvh50Wiw7b5xGtW(fDNibwDKtdJyTnEGpzemy)IUtKaRoYPHrS2gpWVWUmEU1orc7x0DIey1ronmI124b(amJjsUUVW(fDNibwDKtdJyTnEG)KPJ4m3ejORH8yR3Z1oz6ioZnrcSEwIVZG9l6orcS6iNggXAB8aF9OLJ4GrhxKDnKhIyKK2wZZ4JrhybBrpjupy)IUtKaRoYPHrS2gpWxp2jsy)IUtKaRoYPHrS2gpWN5MifJF7AipedaqGGIUtKwMBIum(1slWY3X4hcd2h2x4HQUh3GtXwNbvUMocpOAhJdvlohQk6giOAaqvPznFj(Uf2VO7ej4aO7)Z)GEc2VO7ejOXd81JDISRH8q3xlZnrou(IhQY1w0D00H9l6orcA8aFmGZN1nGUgYdDFTm3e5q5lEOkxBr3rth2VO7ejOXd8fDeWrNM8QRH8q3xlZnrou(IhQY1w0D00H9l6orcA8aFXpcgNedHxxd5HUVwMBICO8fpuLRTO7OPd7x0DIe04b(KdYf)iyDnKh6(AzUjYHYx8qvU2IUJMoSFr3jsqJh4JRsgpi5xypRYUgYJQH1rZ6w)g0)amA6C9y9CN6TOkp1zhJFUbDab2Zb4ketO7DeXijT(nO)by0056X65o1BzrRSJigjPT18m(y0bwWw0tN1UtB0rUM8lkZ2ZIRsgpi5xypRYoDAJoY1KFrz27wCvY4bj)c7zvc7x0DIe04b(Jr)dWezxd5r1W6OzDRFd6FagnDUESEUt9wuLN6iIrsABnpJpgDGfSf9Kq37iIrsA9Bq)dWOPZ1J1ZDQ3YIwjSFr3jsqJh4ZIW01qE0MDONM8QZwOlFT7yC(gC24cPTW6a09)5BHU8fyhJ(hGjYZ3H9l6orcA8aFMBICOCWI88AX11qE0KigjPT18m(y0bwWw0tNVTabIyKKwMBICOC9OLJSy6nlqaq3)NVf6YxGDm6FaMipFh2VO7ejOXd8P1)8IUtK8FaBxzz8J0xCoIRhOT(UgYJTEpxB6lohX1d0wV1Zs8DwhGU)pFl0LVa7y0)amrE(4oSFr3jsqJh4tR)5fDNi5)a2UYY4hJr)dWezxd5bq3)NVf6YxGDm6FaMifQhSFr3jsqJh4FHgtmiNt6)fwHyDnKh0iEw0kTamJjsoZnrou(IhQY1ICtnj4CpTfiOnE3Hn66oZ2t77AF72c7x0DIe04b(amJjsUMZ7KJNSUgYdV7WgDDNz7P9DTVDBfiGgXZIwPfGzmrYzUjYHYx8qvUwKBQjbcDlHjqanINfTslaZyIKZCtKdLV4HQCTi3utco37oSFr3jsqJh4tR)5mKxmWw)jhb6Aip8UdB01DMTN231(2TvGGMOr8SOvAbygtKCMBICO8fpuLRf5MAsW522reJK0YCtKdLtR)N8YICtnjOzbcAIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbN71RtBeXijTm3e5q506)jVSi3utcAwGaAeplALwaMXejN5MihkFXdv5ArUPMeiuVBb7x0DIe04b(amJjsoZnrou(IhQYTRH8W7oSrx3z2EAFx7B3wbcAseJK0YqEXaB9NCeWICtnjqiAbw(ogVttIyKK2wZZ4JrhybBrpj0H2nU175ANmDeN5MibwplX3znU175AzUjYHYPrcWm67eP1Zs8D2nPTab6ixt(fLz7zXvjJhK8lSNvzNMAZwVNRL5MihkNgjaZOVtKwplX3zceiIrsABnpJpgDGfSf9KqhA34wVNRDY0rCMBIey9SeFN1CZDAceyphGRqSZAlqGigjPLH8Ib26p5iGf5MAsW5lk7MUB7gbceXijTxOXedY5K(FHviMf5MAsW5lk7MUB7MMBg2VO7ejOXd81JwoIdgDCr21qEiIrsABnpJpgDGfSf9Kqh37iIrsAzUjYHYPbYTGTONoFCVJigjPL5MihkxpA5illALDa6()8Tqx(cSJr)dWe557W(fDNibnEGplctxd5XwVNRLfHX6zj(oRdYjroaxj(ENTqx(A3X48n4SXfQjwSwweglYn1KGg1wynd7x0DIe04b(4QKXds(f2ZQSRH8aeyphGRqmHoAGabnbcSNdWviMqhA3HgXZIwPLw)ZziVyGT(tocyrUPMei0T60uB269CTamJjsUMZ7KJNmRNL47mbcOr8SOvAbygtKCnN3jhpzwKBQjbcPDZnd7x0DIe04b(Ga75GfnN8UgYdqG9CaUcXo3GoIyKKwMBICOCAGClyl6PZh3H9l6orcA8aFMBIum(TRH8aeyphGRqSZhA3reJK0YCtKdLtdKBX070ut0iEw0kTamJjsoZnrou(IhQY1ICtnj4CpHjqanINfTslaZyIKZCtKdLV4HQCTi3utce6(9MfiqeJK0YCtKdLtdKBbBrpj0H2ceiIrsAzUjYHYPbYTi3utco3abc2X48n4SXpFVbnd7x0DIe04b(IZ7aAGHUCUyyeDea2VO7ejOXd8P1)8IUtK8FaBxzz8drS5z8IdWvigSpSFr3jsGveBEgV4aCfIDacSNdw0CYH9l6orcSIyZZ4fhGRqSgpWhGRyrlUy8lSpSFr3jsGDm6FaMipgJ(hGjYUgYJMeXijTTMNXhJoWc2IEsOJB3PjqG9CaUcXoRTab6ixt(fLz7zP1)CgYlgyR)KJaceiIrsABnpJpgDGfSf9KqhTvGaDKRj)IYS9SIZ7aAGHUCUyyeDeqGGMAJoY1KFrz2EwCvY4bj)c7zv2Pn6ixt(fLzVBXvjJhK8lSNvzZn3Pn6ixt(fLz7zXvjJhK8lSNvzN2OJCn5xuM9UfxLmEqYVWEwLDeXijTm3e5q56rlhzzrRSzbcAAhJZ3GZg)S2DeXijTTMNXhJoWc2IEsiH1SabnPJCn5xuM9ULw)ZziVyGT(toc0reJK02AEgFm6alyl6jHU3PnB9EUwMBICOCA9)KxwplX3znd7x0DIeyhJ(hGjYgpW)cnMyqoN0)lScX6AipOr8SOvAbygtKCMBICO8fpuLRf5MAsW5EAlqqB8UdB01DMTN231(2Tf2VO7ejWog9patKnEGpT(NZqEXaB9NCeORH8OjAeplALwaMXejN5MihkFXdv5ArUPMeCUTDeXijTm3e5q506)jVSi3utcAwGGMOr8SOvAbygtKCMBICO8fpuLRf5MAsW5E960grmsslZnrouoT(FYllYn1KGMfiGgXZIwPfGzmrYzUjYHYx8qvUwKBQjbc17wW(fDNib2XO)byISXd8bygtKCMBICO8fpuLlSFr3jsGDm6FaMiB8aFCvY4bj)c7zv21qEacSNdWviMqhna2VO7ejWog9patKnEGpUkz8GKFH9Sk7Aipab2Zb4ketOdT70utnPJCn5xuM9UfxLmEqYVWEwLceiIrsABnpJpgDGfSf9KqhA3ChrmssBR5z8XOdSGTONo32MfiGgXZIwPfGzmrYzUjYHYx8qvUwKBQjbNpUOSB6UabIyKKwMBICOC9OLJSi3utce6IYUP7nd7x0DIeyhJ(hGjYgpWN5MifJF7Aip0rUM8lkZ2ZIRsgpi5xypRYoGa75aCfIj0rVonjIrsABnpJpgDGfSf905dTfiqh5AYVOmR2wCvY4bj)c7zv2ChqG9CaUcXoFRoIyKKwMBICOCAGClMoSFr3jsGDm6FaMiB8aFaMXejxZ5DYXtwxd5rt0iEw0kTamJjsoZnrou(IhQY1ICtnjqOBjSoaD)F(wOlFb2XO)byI88X9MfiGgXZIwPfGzmrYzUjYHYx8qvUwKBQjbN7Dh2VO7ejWog9patKnEGV48oGgyOlNlggrhb6AipOr8SOvAbygtKCMBICO8fpuLRf5MAsGqTf2VO7ejWog9patKnEGpiWEoyrZjVRH8aeyphGRqSZnOJigjPL5MihkNgi3c2IE68XDy)IUtKa7y0)amr24b(m3ePy8Bxd5biWEoaxHyNp0UJigjPL5MihkNgi3IP3PjrmsslZnrouonqUfSf9KqhAlqGigjPL5MihkNgi3ICtnj48XfLDtnW2nnd7x0DIeyhJ(hGjYgpWNfHPlkE035BHU8fC0RltDdCkE035BHU8fC0nDnKhiNe5aCL47W(fDNib2XO)byISXd8P1)8IUtK8FaBxzz8drS5z8IdWvigSpSFr3jsGn9fNJ46bAR)Gw)Zl6orY)bSDLLXpsFX5iUEG265IyZZM8QRH8GgXZIwPn9fNJ46bAR3ICtnj48DHb7x0DIeytFX5iUEG26B8aFA9pVO7ej)hW2vwg)i9fNJ46bARNx0D007AipeXijTPV4CexpqB9wmDyFy)IUtKaB6lohX1d0wpVO7OPFioVdObg6Y5IHr0ray)IUtKaB6lohX1d0wpVO7OP34b(xOXedY5K(FHviwxd5bnINfTslaZyIKZCtKdLV4HQCTi3utco3tBbcAJ3DyJUUZS90(U23UTW(fDNib20xCoIRhOTEEr3rtVXd8bygtKCnN3jhpzDnKh0iEw0kTamJjsoZnrou(IhQY1ICtnjqOBjmbcOr8SOvAbygtKCMBICO8fpuLRf5MAsW5E3H9l6orcSPV4CexpqB98IUJMEJh4tR)5mKxmWw)jhb6AipAIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbNBBhrmsslZnrouoT(FYllYn1KGMfiOjAeplALwaMXejN5MihkFXdv5ArUPMeCUxVoTreJK0YCtKdLtR)N8YICtnjOzbcOr8SOvAbygtKCMBICO8fpuLRf5MAsGq9UfSFr3jsGn9fNJ46bARNx0D00B8aFX5DanWqxoxmmIoca7x0DIeytFX5iUEG265fDhn9gpWNw)Zl6orY)bSDLLXpeXMNXloaxHyDnKhGa75aCfID0Rtt0iEw0kT06Fod5fdS1FYralYn1KGZfDNiTaCflAXfJFT0cS8DmUabnT175AfN3b0adD5CXWi6iG1Zs8DwhAeplALwX5DanWqxoxmmIocyrUPMeCUO7ePfGRyrlUy8RLwGLVJXBUzy)IUtKaB6lohX1d0wpVO7OP34b(4QKXds(f2ZQSRH8OPMOr8SOvAP1)CgYlgyR)KJawKBQjbcv0DI0YCtKIXVwAbw(ogV5onrJ4zrR0sR)5mKxmWw)jhbSi3utceQO7ePfGRyrlUy8RLwGLVJXBU5o0iEw0kTPV4CexpqB9wKBQjbc1uVB3Ggl6orAXvjJhK8lSNvPLwGLVJXBg2VO7ejWM(IZrC9aT1Zl6oA6nEGpaZyIKZCtKdLV4HQC7AipeXijTPV4CexpqB9wKBQjbNBqhqG9CaUcXoegSFr3jsGn9fNJ46bARNx0D00B8aFaMXejN5MihkFXdv521qEiIrsAtFX5iUEG26Ti3utcox0DI0cWmMi5m3e5q5lEOkxlTalFhJ3OWSna2VO7ejWM(IZrC9aT1Zl6oA6nEGpZnrkg)21qEiIrsAzUjYHYPbYTy6W(fDNib20xCoIRhOTEEr3rtVXd8P1)8IUtK8FaBxzz8drS5z8IdWvigSpSFr3jsGn9fNJ46bARNlInpBYRJ0xCoIRhOT(UgYdqG9CaUcXe6ObDAQnB9EUw9OLJ4GrhxKwplX3zceiIrsAzUjYHYPbYTy6nd7x0DIeytFX5iUEG265IyZZM8QXd8P1)CgYlgyR)KJaW(fDNib20xCoIRhOTEUi28SjVA8aFCvY4bj)c7zv21qEqJ4zrR0sR)5mKxmWw)jhbSi3utceQx3UdiWEoaxHycDOnSFr3jsGn9fNJ46bARNlInpBYRgpWxpA5ioy0Xfzxd5HigjPT18m(y0bwWw0tcDCVJigjPL5MihkNgi3c2IE68X9oIyKKwMBICOC9OLJSSOv2beyphGRqmHo0g2VO7ejWM(IZrC9aT1ZfXMNn5vJh4JRsgpi5xypRYUgYdqG9CaUcXe6ObW(fDNib20xCoIRhOTEUi28SjVA8aFA9pVO7ej)hW2vwg)qeBEgV4aCfIjj00rGjsPw3fwV2kSEcRNvyTTxpjrRcLtEbKe3Sg(ULwDVA19u4cvqLg4COAm6bAHkYabvnC6iNggXAB4GkK3DydYzqfimouvyByQ1zqffxLxoWc739nPdvnq4cvD)jatxpqRZGQIUtKqvd3KPJ4m3ejOHZc7d739A0d06mOQBGQIUtKq1pGfyH9Le)awGudjr6lohX1d0wVudPw9KAij8SeFNjBxsqrZ6OPKe0iEw0kTPV4CexpqB9wKBQjbq1zO6UWKefDNiLe06FEr3js(pGvs8dy5zzCjr6lohX1d0wpxeBE2KxYvQ1DPgscplX3zY2Leu0SoAkjHigjPn9fNJ46bAR3IPljk6orkjO1)8IUtK8FaRK4hWYZY4sI0xCoIRhOTEEr3rtxUYvsWCYc7xPgsT6j1qsu0DIusa09)5Fqpjj8SeFNjBxUsTUl1qs4zj(ot2UKGIM1rtjj091YCtKdLV4HQCTfDhnDjrr3jsjHEStKYvQL2snKeEwIVZKTljOOzD0uscDFTm3e5q5lEOkxBr3rtxsu0DIusGbC(SUbixPw3sQHKWZs8DMSDjbfnRJMssO7RL5MihkFXdv5Al6oA6sIIUtKscrhbC0PjVKRuRgi1qs4zj(ot2UKGIM1rtjj091YCtKdLV4HQCTfDhnDjrr3jsjH4hbJtIHWtUsTUTudjHNL47mz7sckAwhnLKq3xlZnrou(IhQY1w0D00LefDNiLeKdYf)iyYvQv3i1qs4zj(ot2UKGIM1rtjjQgwhnRB9Bq)dWOPZ1J1ZDQ3IQ8eu1bQ2X4q1zOQbqvhOceyphGRqmOsiO6ou1bQeXijT(nO)by0056X65o1BzrReQ6avIyKK2wZZ4JrhybBrpbvNHkTHQoqvBGkDKRj)IYS9S4QKXds(f2ZQeQ6avDGQ2av6ixt(fLzVBXvjJhK8lSNvPKOO7ePKaxLmEqYVWEwLYvQv3wQHKWZs8DMSDjbfnRJMssunSoAw363G(hGrtNRhRN7uVfv5jOQdujIrsABnpJpgDGfSf9eujeuDhQ6avIyKKw)g0)amA6C9y9CN6TSOvkjk6orkjgJ(hGjs5k1QTsnKeEwIVZKTljOOzD0usI2av7qpn5fu1bQ2cD5RDhJZ3GZghQecQ0wyqvhOcO7)Z3cD5lWog9patKq1zO6UKOO7ePKGfHrUsT6jmPgscplX3zY2Leu0SoAkjrtqLigjPT18m(y0bwWw0tq1zO62qLabqLigjPL5MihkxpA5ilMou1mujqaub09)5BHU8fyhJ(hGjsO6muDxsu0DIusWCtKdLdwKNxlo5k1QxpPgscplX3zY2Leu0SoAkjXwVNRn9fNJ46bAR36zj(odQ6avaD)F(wOlFb2XO)byIeQoFav3LefDNiLe06FEr3js(pGvs8dy5zzCjr6lohX1d0wVCLA17UudjHNL47mz7sckAwhnLKaO7)Z3cD5lWog9patKqLqqvpjrr3jsjbT(Nx0DIK)dyLe)awEwgxsmg9patKYvQvpTLAij8SeFNjBxsqrZ6OPKe0iEw0kTamJjsoZnrou(IhQY1ICtnjaQodv90gQeiaQAdu5Dh2OR7mBR5jrodWbZ188GKdW0D0eioaZyICYljrr3jsjXfAmXGCoP)xyfIjxPw9ULudjHNL47mz7sckAwhnLKW7oSrx3z2wZtICgGdMR55bjhGP7OjqCaMXe5KxqLabqfnINfTslaZyIKZCtKdLV4HQCTi3utcGkHGQBjmOsGaOIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbq1zOQ3Djrr3jsjbaZyIKR58o54jtUsT61aPgscplX3zY2Leu0SoAkjH3DyJUUZSTMNe5mahmxZZdsoat3rtG4amJjYjVGkbcGQMGkAeplALwaMXejN5MihkFXdv5ArUPMeavNHQ2cvDGkrmsslZnrouoT(FYllYn1KaOQzOsGaOQjOIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbq1zOQxpOQdu1gOseJK0YCtKdLtR)N8YICtnjaQAgQeiaQOr8SOvAbygtKCMBICO8fpuLRf5MAsaujeu17wsIIUtKscA9pNH8Ib26p5iGCLA172snKeEwIVZKTljOOzD0uscV7WgDDNzBnpjYzaoyUMNhKCaMUJMaXbygtKtEbvceavnbvIyKKwgYlgyR)KJawKBQjbqLqqfTalFhJdvDGQMGkrmssBR5z8XOdSGTONGkHoGkTHQgHQTEpx7KPJ4m3ejW6zj(odQAeQ269CTm3e5q50ibyg9DI06zj(odQUjOsBOsGaOsh5AYVOmBplUkz8GKFH9SkHQoqvtqvBGQTEpxlZnrouonsaMrFNiTEwIVZGkbcGkrmssBR5z8XOdSGTONGkHoGkTHQgHQTEpx7KPJ4m3ejW6zj(odQAgQAgQ6avnbvGa75aCfIbvNHkTHkbcGkrmssld5fdS1FYralYn1KaO6muDrzq1nbv3TDdujqaujIrsAVqJjgKZj9)cRqmlYn1KaO6muDrzq1nbv3TDdu1mu1SKOO7ePKaGzmrYzUjYHYx8qvUYvQvVUrQHKWZs8DMSDjbfnRJMssiIrsABnpJpgDGfSf9euj0buDhQ6avIyKKwMBICOCAGClyl6jO68buDhQ6avIyKKwMBICOC9OLJSSOvcvDGkGU)pFl0LVa7y0)amrcvNHQ7sIIUtKsc9OLJ4GrhxKYvQvVUTudjHNL47mz7sckAwhnLKyR3Z1YIWy9SeFNbvDGkKtICaUs8DOQduTf6Yx7ogNVbNnoujeu1euXI1YIWyrUPMeavncvAlmOQzjrr3jsjblcJCLA1RTsnKeEwIVZKTljOOzD0uscqG9CaUcXGkHoGQgavceavnbvGa75aCfIbvcDavAdvDGkAeplALwA9pNH8Ib26p5iGf5MAsaujeuDlOQdu1eu1gOAR3Z1cWmMi5AoVtoEYSEwIVZGkbcGkAeplALwaMXejxZ5DYXtMf5MAsaujeuPnu1mu1SKOO7ePKaxLmEqYVWEwLYvQ1DHj1qs4zj(ot2UKGIM1rtjjab2Zb4kedQodvnaQ6avIyKKwMBICOCAGClyl6jO68buDxsu0DIusacSNdw0CYLRuR79KAij8SeFNjBxsqrZ6OPKeGa75aCfIbvNpGkTHQoqLigjPL5MihkNgi3IPdvDGQMGQMGkAeplALwaMXejN5MihkFXdv5ArUPMeavNHQEcdQeiaQOr8SOvAbygtKCMBICO8fpuLRf5MAsaujeuD)ou1mujqaujIrsAzUjYHYPbYTGTONGkHoGkTHkbcGkrmsslZnrouonqUf5MAsauDgQAaujqauTJX5BWzJdvNHQ7naQAwsu0DIusWCtKIXVYvQ197snKefDNiLeIZ7aAGHUCUyyeDeqs4zj(ot2UCLADxBPgscplX3zY2LefDNiLe06FEr3js(pGvs8dy5zzCjHi28mEXb4ketUYvsOJCAyeRvQHuREsnKeEwIVZKTlxPw3LAij8SeFNjBxUsT0wQHKWZs8DMSD5k16wsnKefDNiLeamJjsoP)xyfIjj8SeFNjBxUsTAGudjHNL47mz7sckAwhnLKyR3Z1oz6ioZnrcSEwIVZKefDNiLetMoIZCtKa5k162snKeEwIVZKTljOOzD0uscrmssBR5z8XOdSGTONGkHGQEsIIUtKsc9OLJ4GrhxKYvQv3i1qsu0DIusOh7ePKWZs8DMSD5k1QBl1qs4zj(ot2UKGIM1rtjjedaaQeiaQk6orAzUjsX4xlTalFhJdvhqLWKefDNiLem3ePy8RCLRKym6FaMiLAi1QNudjHNL47mz7sckAwhnLKOjOseJK02AEgFm6alyl6jOsOdO62qvhOQjOceyphGRqmO6muPnujqauPJCn5xuMTNLw)ZziVyGT(tocavceavIyKK2wZZ4JrhybBrpbvcDavTfQeiaQ0rUM8lkZ2ZkoVdObg6Y5IHr0raOsGaOQjOQnqLoY1KFrz2EwCvY4bj)c7zvcvDGQ2av6ixt(fLzVBXvjJhK8lSNvju1mu1mu1bQAduPJCn5xuMTNfxLmEqYVWEwLqvhOQnqLoY1KFrz27wCvY4bj)c7zvcvDGkrmsslZnrouUE0Yrww0kHQMHkbcGQMGQDmoFdoBCO6muPnu1bQeXijTTMNXhJoWc2IEcQecQegu1mujqau1euPJCn5xuM9ULw)ZziVyGT(tocavDGkrmssBR5z8XOdSGTONGkHGQ7qvhOQnq1wVNRL5MihkNw)p5L1Zs8Dgu1SKOO7ePKym6FaMiLRuR7snKeEwIVZKTljOOzD0uscAeplALwaMXejN5MihkFXdv5ArUPMeavNHQEAdvceavTbQ8UdB01DMT18KiNb4G5AEEqYby6oAcehGzmro5LKOO7ePK4cnMyqoN0)lScXKRulTLAij8SeFNjBxsqrZ6OPKenbv0iEw0kTamJjsoZnrou(IhQY1ICtnjaQodvTfQ6avIyKKwMBICOCA9)KxwKBQjbqvZqLabqvtqfnINfTslaZyIKZCtKdLV4HQCTi3utcGQZqvVEqvhOQnqLigjPL5MihkNw)p5Lf5MAsau1mujqaurJ4zrR0cWmMi5m3e5q5lEOkxlYn1KaOsiOQ3TKefDNiLe06Fod5fdS1FYra5k16wsnKefDNiLeamJjsoZnrou(IhQYvs4zj(ot2UCLA1aPgscplX3zY2Leu0SoAkjbiWEoaxHyqLqhqvdKefDNiLe4QKXds(f2ZQuUsTUTudjHNL47mz7sckAwhnLKaeyphGRqmOsOdOsBOQdu1eu1eu1euPJCn5xuM9UfxLmEqYVWEwLqLabqLigjPT18m(y0bwWw0tqLqhqL2qvZqvhOseJK02AEgFm6alyl6jO6mu1wOQzOsGaOIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbq15dO6IYGQBcQUdvceavIyKKwMBICOC9OLJSi3utcGkHGQlkdQUjO6ou1SKOO7ePKaxLmEqYVWEwLYvQv3i1qs4zj(ot2UKGIM1rtjj0rUM8lkZ2ZIRsgpi5xypRsOQdubcSNdWviguj0bu1dQ6avnbvIyKK2wZZ4JrhybBrpbvNpGkTHkbcGkDKRj)IYSABXvjJhK8lSNvju1mu1bQab2Zb4kedQodv3cQ6avIyKKwMBICOCAGClMUKOO7ePKG5MifJFLRuRUTudjHNL47mz7sckAwhnLKOjOIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbqLqq1Tegu1bQa6()8Tqx(cSJr)dWejuD(aQUdvndvceav0iEw0kTamJjsoZnrou(IhQY1ICtnjaQodv9Uljk6orkjaygtKCnN3jhpzYvQvBLAij8SeFNjBxsqrZ6OPKe0iEw0kTamJjsoZnrou(IhQY1ICtnjaQecQARKOO7ePKqCEhqdm0LZfdJOJaYvQvpHj1qs4zj(ot2UKGIM1rtjjab2Zb4kedQodvnaQ6avIyKKwMBICOCAGClyl6jO68buDxsu0DIusacSNdw0CYLRuRE9KAij8SeFNjBxsqrZ6OPKeGa75aCfIbvNpGkTHQoqLigjPL5MihkNgi3IPdvDGQMGkrmsslZnrouonqUfSf9euj0buPnujqaujIrsAzUjYHYPbYTi3utcGQZhq1fLbv3eu1aB3avnljk6orkjyUjsX4x5k1Q3DPgscplX3zY2LefDNiLeSimsckE035BHU8fi1QNKWu3aNIh9D(wOlFbsIUrsqrZ6OPKeiNe5aCL47YvQvpTLAij8SeFNjBxsu0DIusqR)5fDNi5)awjXpGLNLXLeIyZZ4fhGRqm5kxjr6lohX1d0wpxeBE2KxsnKA1tQHKWZs8DMSDjbfnRJMssacSNdWviguj0bu1aOQdu1eu1gOAR3Z1QhTCehm64I06zj(odQeiaQeXijTm3e5q50a5wmDOQzjrr3jsjr6lohX1d0wVCLADxQHKOO7ePKGw)ZziVyGT(tocij8SeFNjBxUsT0wQHKWZs8DMSDjbfnRJMssqJ4zrR0sR)5mKxmWw)jhbSi3utcGkHGQEDBOQdubcSNdWviguj0buPTKOO7ePKaxLmEqYVWEwLYvQ1TKAij8SeFNjBxsqrZ6OPKeIyKK2wZZ4JrhybBrpbvcDav3HQoqLigjPL5MihkNgi3c2IEcQoFav3HQoqLigjPL5MihkxpA5illALqvhOceyphGRqmOsOdOsBjrr3jsjHE0YrCWOJls5k1QbsnKeEwIVZKTljOOzD0uscqG9CaUcXGkHoGQgijk6orkjWvjJhK8lSNvPCLADBPgscplX3zY2LefDNiLe06FEr3js(pGvs8dy5zzCjHi28mEXb4ketUYvsiInpJxCaUcXKAi1QNudjrr3jsjbiWEoyrZjxs4zj(ot2UCLADxQHKOO7ePKaGRyrlUy8RKWZs8DMSD5kxjr6lohX1d0wpVO7OPl1qQvpPgsIIUtKscX5DanWqxoxmmIocij8SeFNjBxUsTUl1qs4zj(ot2UKGIM1rtjjOr8SOvAbygtKCMBICO8fpuLRf5MAsauDgQ6Pnujqau1gOY7oSrx3z2wZtICgGdMR55bjhGP7OjqCaMXe5KxsIIUtKsIl0yIb5Cs)VWketUsT0wQHKWZs8DMSDjbfnRJMssqJ4zrR0cWmMi5m3e5q5lEOkxlYn1KaOsiO6wcdQeiaQOr8SOvAbygtKCMBICO8fpuLRf5MAsauDgQ6Dxsu0DIusaWmMi5AoVtoEYKRuRBj1qs4zj(ot2UKGIM1rtjjAcQOr8SOvAbygtKCMBICO8fpuLRf5MAsauDgQAlu1bQeXijTm3e5q506)jVSi3utcGQMHkbcGQMGkAeplALwaMXejN5MihkFXdv5ArUPMeavNHQE9GQoqvBGkrmsslZnrouoT(FYllYn1KaOQzOsGaOIgXZIwPfGzmrYzUjYHYx8qvUwKBQjbqLqqvVBjjk6orkjO1)CgYlgyR)KJaYvQvdKAijk6orkjeN3b0adD5CXWi6iGKWZs8DMSD5k162snKeEwIVZKTljOOzD0uscqG9CaUcXGQdOQhu1bQAcQOr8SOvAP1)CgYlgyR)KJawKBQjbq1zOQO7ePfGRyrlUy8RLwGLVJXHkbcGQMGQTEpxR48oGgyOlNlggrhbSEwIVZGQoqfnINfTsR48oGgyOlNlggrhbSi3utcGQZqvr3jslaxXIwCX4xlTalFhJdvndvnljk6orkjO1)8IUtK8FaRK4hWYZY4scrS5z8IdWviMCLA1nsnKeEwIVZKTljOOzD0usIMGQMGkAeplALwA9pNH8Ib26p5iGf5MAsaujeuv0DI0YCtKIXVwAbw(oghQAgQ6avnbv0iEw0kT06Fod5fdS1FYralYn1KaOsiOQO7ePfGRyrlUy8RLwGLVJXHQMHQMHQoqfnINfTsB6lohX1d0wVf5MAsaujeu1eu172naQAeQk6orAXvjJhK8lSNvPLwGLVJXHQMLefDNiLe4QKXds(f2ZQuUsT62snKeEwIVZKTljOOzD0uscrmssB6lohX1d0wVf5MAsauDgQAau1bQab2Zb4kedQoGkHjjk6orkjaygtKCMBICO8fpuLRCLA1wPgscplX3zY2Leu0SoAkjHigjPn9fNJ46bAR3ICtnjaQodvfDNiTamJjsoZnrou(IhQY1slWY3X4qvJqLWSnqsu0DIusaWmMi5m3e5q5lEOkx5k1QNWKAij8SeFNjBxsqrZ6OPKeIyKKwMBICOCAGClMUKOO7ePKG5MifJFLRuRE9KAij8SeFNjBxsu0DIusqR)5fDNi5)awjXpGLNLXLeIyZZ4fhGRqm5kx5kjkSfxGKeeJ5Mlx5kL]] )

    
end
