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


    spec:RegisterPack( "Demonology", 20190203.1644, [[dKe9bbqisv5rePYMKk(ePQkgLusNsk0QujqVskywsjUfrQAxu8lvQgMkrhtQYYGKEgPsttQKUMuj2MkH(grkACKQkDoPs16ivvmpvk3tf2hr4GePGwiPkpKifAIQe0fjsPYgjsPQpsQQsDsIuGvkv1mLkLyNKk(jPQkzOePKLsQQQNcXujIUQuPK(QuPu7fL)IQbtYHfTye9yKMmHlt1MjQpdPgTk60kETkPzRQBtPDl53cdNuoorkLLd8CqtxPRJW2js(Uu04LkfNhsSEvcy(sP2puZ6XKKHiY1z6G6L96(LOEPUMExSRDTRxKHSOO5meTKEnr7mKkTod5cDBuXhOrHHOLO8rkysYqGbbG6mKZD1G6N73rp7jbPHg27WXs85orrbP8Ehow6DYpiVtkNsVWL6UgiKN3H3Lwax)NJaExAP)5D7e8b9k)cDBuXhOrXahlLHqsm)knOyKmerUothuVSx3Ve1l1107I6EXU0vgcuZPmDq9IxKHCocHxmsgIWHugI0HvxOBJk(ankyv3obFqVI7lDy15UAq9Z97ON9KG0qd7D4yj(CNOOGuEVdhl9o5hK3jLtPx4sDxdeYZ7W7slGR)ZraVlT0)8UDc(GELFHUnQ4d0OyGJLI7lDyL0ENeqKauWkDBbRq9YEDhRKESQ3f1p6QlUpUV0HvsJNzH2H6hCFPdRKEScrZ)hR6wc6vdUV0Hvspw1TcDSIKqw2u(E6aUwa28neAy1uW1tbwfYyfWT5utHgRKgVqSAhRJvYbaR0X3thGvsRaS5JvjDhPCSs7mHUb3x6WkPhR0FvpkyfWPH16LaRUq3gfz8lwPbCPNgwYCXQrgRMfRgiwnfCZAXQwHNbXlWknqqMKpkyfCN)XQZeiOjCB0G7lDyL0JvsROPdWkKr7mkSk)pA6cSsd4spnSK5IvBGvAGGIvtb3SwS6cDBuKXVggIgiKN3zishwDHUnQ4d0OGvD7e8b9kUV0HvN7Qb1p3VJE2tcsdnS3HJL4ZDIIcs59oCS07KFqENuoLEHl1DnqipVdVlTaU(phb8U0s)Z72j4d6v(f62OIpqJIbowkUV0Hvs7DsarcqbR0TfSc1l71DSs6XQExu)ORU4(4(shwjnEMfAhQFW9LoSs6Xken)FSQBjOxn4(shwj9yv3k0Xksczzt57Pd4AbyZ3qOHvtbxpfyviJva3MtnfASsA8cXQDSowjhaSshFpDawjTcWMpwL0DKYXkTZe6gCFPdRKESs)v9OGvaNgwRxcS6cDBuKXVyLgWLEAyjZfRgzSAwSAGy1uWnRfRAfEgeVaR0abzs(OGvWD(hRotGGMWTrdUV0HvspwjTIMoaRqgTZOWQ8)OPlWknGl90WsMlwTbwPbckwnfCZAXQl0Trrg)AW9X9LoSsAx34uI1fyfPlhahROHLmxSI0rpf0GvsdPuxBHyvfL0FMaRmXJvjDNOGyvupkgC)KUtuqJgWPHLm3d5pHxX9t6orbnAaNgwYCB44UCecC)KUtuqJgWPHLm3goUNeOTET5orH7N0DIcA0aonSK52WXDiH1gfxZxC)KUtuqJgWPHLm3goUpv5aUWTrbBzKp289AntvoGlCBuqJxj57cC)KUtuqJgWPHLm3goURfnDahoANr1YiFqsilBAoVGpwnObUj9Qe9W9t6orbnAaNgwYCB44UwStu4(jDNOGgnGtdlzUnCCx42OiJFBzKpidiSD7KUtugHBJIm(1qt4Y3X6hxI7J7lDyL0UUXPeRlWkxkhGcwTJ1XQ90XQKUbaRgiwLsLZNKVBW9t6orbpGA()8pOxX9t6orbB44UwStuTmYhA(AeUnQHYxuazTMKUJuENw13MVxRP890bCTaS5B8kjFx0UnjHSSP890bCTaS5Bi0Ae3pP7efSHJ7eqNpRBHTmYhA(AeUnQHYxuazTMKUJuoUFs3jkydh3jDa0bxNcDlJ8HMVgHBJAO8ffqwRjP7iLJ7N0DIc2WXDYpcbxMaGslJ8HMVgHBJAO8ffqwRjP7iLJ7N0DIc2WXD5b4KFeIwg5dnFnc3g1q5lkGSwts3rkh3pP7efSHJ7Nzj4HmhnXlYQLr(iVaoyw34DJ2hWrkNRfRx7KVbK11o7y9BDPdmiEo8mbcjqTdjHSSX7gTpGJuoxlwV2jFJiAwDijKLnnNxWhRg0a3KE9MUD0NgWLIJMkm9mNzj4HmhnXlYQJ(0aUuC0uHbvZzwcEiZrt8ISW9t6orbB44(y1(aor1YiFKxahmRB8Ur7d4iLZ1I1RDY3aY6AhsczztZ5f8XQbnWnPxLa1oKeYYgVB0(aos5CTy9AN8nIOzH7N0DIc2WXDre2wg5d9Td96uO7SjaTVMDSoFdUyCj09Yoqn)F(Ma0(cnJv7d4e1nuX9t6orbB44o58oKgea0oNmSKoa2YiFKxahmRB8Ur7d4iLZ1I1RDY3aY6Qex2zhRFR3LDGA()8nbO9fAgR2hWjQBO2HKqw2iaEkGB(xDa0aCBofSZMVxRP890bCTaS5B8kjFxG7N0DIc2WXDHBJAOC4c8c9E2YiF0kjHSSP58c(y1Gg4M0R3Uy72KeYYgHBJAOCTOPdmeAn2UnuZ)NVjaTVqZy1(aorDdvC)KUtuWgoUtZ)5jDNO4)a3wQ06hLVNoGRfGn)wg5JnFVwt57Pd4AbyZ34vs(UOduZ)NVjaTVqZy1(aorD7avC)KUtuWgoUtZ)5jDNO4)a3wQ06hJv7d4evlJ8buZ)NVjaTVqZy1(aorjrpC)KUtuWgoUJgm2yaox2F0ejq0YiFqJ4frZYajS2O4c3g1q5lkGSwdWT5uWB90f3pP7efSHJ7qcRnkUuZ7YJxIwg5dAeViAwgiH1gfx42OgkFrbK1AaUnNckrxVSDBAeViAwgiH1gfx42OgkFrbK1AaUnNcERhQ4(jDNOGnCCNM)ZfapfWn)Roa2YiF0knIxenldKWAJIlCBudLVOaYAna3MtbV19oKeYYgHBJAOCA()uOna3MtbBSD7wPr8IOzzGewBuCHBJAO8ffqwRb42Ck4TE96OpsczzJWTrnuon)Fk0gGBZPGn2UnnIxenldKWAJIlCBudLVOaYAna3MtbLOxxX9t6orbB44o58oKgea0oNmSKoaI7N0DIc2WXDiH1gfx42OgkFrbK12YiFadINdptG4MUDAvFB(ETgHBJAOCAuqcR2orz8kjFx0UnjHSSP58c(y1Gg4M0RsCzJ4(jDNOGnCCxlA6aoC0oJQLr(GKqw20CEbFSAqdCt6vjoqTdjHSSr42OgkNga3a3KE92bQDijKLnc3g1q5ArthyerZQduZ)NVjaTVqZy1(aorDdvC)KUtuWgoUlIW2YiFS571AerynELKVl6aCzGdptY37SjaTVMDSoFdUyCjAveRreH1aCBofSbDVSrC)KUtuWgoUFMLGhYC0eViRwg5dyq8C4zcesC0L2TBfgephEMaHeh62HgXlIMLHM)ZfapfWn)RoaAaUnNckrx70Q(289AnqcRnkUuZ7YJxcJxj57I2TPr8IOzzGewBuCPM3LhVegGBZPGsOBJnI7N0DIc2WXDyq8C4cMRElJ8bmiEo8mbIBDPdjHSSr42OgkNga3a3KE92bQ4(jDNOGnCCx42OiJFBzKpGbXZHNjqC7q3oKeYYgHBJAOCAaCdHgUFs3jkydh3P5)8KUtu8FGBlvA9dsI5f8KdptGa3h3pP7ef0qsmVGNC4zcehWG45WfmxDC)KUtuqdjX8cEYHNjq0WXD4zkIMCY4xCFC)KUtuqZy1(aorDmwTpGtuTmYhTssilBAoVGpwnObUj9QehxStRWG45WZeiUPB72AaxkoAQW0ZqZ)5cGNc4M)vhaB3MKqw20CEbFSAqdCt6vjo6E72AaxkoAQW0ZqoVdPbbaTZjdlPdGTB3Q(0aUuC0uHPN5mlbpK5OjErwD0NgWLIJMkmOAoZsWdzoAIxKvJn2rFAaxkoAQW0ZCMLGhYC0eViRo6td4sXrtfgunNzj4HmhnXlYQdjHSSr42OgkxlA6aJiAwn2UDR7yD(gCX430TdjHSSP58c(y1Gg4M0RsCzJTB3QgWLIJMkmOAO5)CbWtbCZ)QdGDijKLnnNxWhRg0a3KEvcu7OVnFVwJWTrnuon)Fk0gVsY3fnI7N0DIcAgR2hWjQgoUJgm2yaox2F0ejq0YiFqJ4frZYajS2O4c3g1q5lkGSwdWT5uWB90TDB95sBeJMMlm90fvDVy3X9t6orbnJv7d4evdh3P5)CbWtbCZ)QdGTmYhTsJ4frZYajS2O4c3g1q5lkGSwdWT5uWBDVdjHSSr42OgkNM)pfAdWT5uWgB3UvAeViAwgiH1gfx42OgkFrbK1AaUnNcERxVo6JKqw2iCBudLtZ)NcTb42CkyJTBtJ4frZYajS2O4c3g1q5lkGSwdWT5uqj61vC)KUtuqZy1(aor1WXDiH1gfx42OgkFrbK1I7N0DIcAgR2hWjQgoUFMLGhYC0eViRwg5dyq8C4zcesC0fC)KUtuqZy1(aor1WX9ZSe8qMJM4fz1YiFadINdptGqIdD70ARTQbCP4OPcdQMZSe8qMJM4fz1UnjHSSP58c(y1Gg4M0RsCOBJDijKLnnNxWhRg0a3KE9w3BSDBAeViAwgiH1gfx42OgkFrbK1AaUnNcE7anvCbrTDBsczzJWTrnuUw00bgGBZPGsGMkUGO2iUFs3jkOzSAFaNOA44UWTrrg)2YiFObCP4OPctpZzwcEiZrt8IS6adINdptGqIJEDALKqw20CEbFSAqdCt61Bh62UTgWLIJMkm6AoZsWdzoAIxKvJDGbXZHNjqCRRDijKLnc3g1q50a4gcnC)KUtuqZy1(aor1WXDiH1gfxQ5D5XlrlJ8rR0iEr0SmqcRnkUWTrnu(IciR1aCBofuIUEzhOM)pFtaAFHMXQ9bCI62bQn2UnnIxenldKWAJIlCBudLVOaYAna3MtbV1dvC)KUtuqZy1(aor1WXDY5DiniaODozyjDaSLr(GgXlIMLbsyTrXfUnQHYxuazTgGBZPGs0DC)KUtuqZy1(aor1WXDyq8C4cMRElJ8bmiEo8mbIBDPdjHSSr42OgkNga3a3KE92bQ4(jDNOGMXQ9bCIQHJ7c3gfz8BlJ8bmiEo8mbIBh62HKqw2iCBudLtdGBi060kjHSSr42OgkNga3a3KEvIdDB3MKqw2iCBudLtdGBaUnNcE7anvCb7IrA2iUFs3jkOzSAFaNOA44UicBluuOVZ3eG2x4rVwSz3WPOqFNVjaTVWdPzlJ8bWLbo8mjFh3pP7ef0mwTpGtunCCNM)Zt6orX)bUTuP1pijMxWto8mbcCFC)KUtuqt57Pd4AbyZ)GM)Zt6orX)bUTuP1pkFpDaxlaB(CsI5ftHULr(GgXlIMLP890bCTaS5BaUnNcEd1lX9t6orbnLVNoGRfGn)goUtZ)5jDNO4)a3wQ06hLVNoGRfGnFEs3rkVLr(GKqw2u(E6aUwa28neA4(4(jDNOGMY3thW1cWMppP7iLFqoVdPbbaTZjdlPdG4(jDNOGMY3thW1cWMppP7iL3WXD0GXgdW5Y(JMibIwg5dAeViAwgiH1gfx42OgkFrbK1AaUnNcERNUTBRpxAJy00CHPNUOQ7f7oUFs3jkOP890bCTaS5Zt6os5nCChsyTrXLAExE8s0YiFqJ4frZYajS2O4c3g1q5lkGSwdWT5uqj66LTBtJ4frZYajS2O4c3g1q5lkGSwdWT5uWB9qf3pP7ef0u(E6aUwa285jDhP8goUtZ)5cGNc4M)vhaBzKpALgXlIMLbsyTrXfUnQHYxuazTgGBZPG36EhsczzJWTrnuon)Fk0gGBZPGn2UDR0iEr0SmqcRnkUWTrnu(IciR1aCBof8wVED0hjHSSr42OgkNM)pfAdWT5uWgB3MgXlIMLbsyTrXfUnQHYxuazTgGBZPGs0RR4(jDNOGMY3thW1cWMppP7iL3WXDY5DiniaODozyjDae3pP7ef0u(E6aUwa285jDhP8goUtZ)5jDNO4)a3wQ06hKeZl4jhEMarlJ8bmiEo8mbIJEDALgXlIMLHM)ZfapfWn)RoaAaUnNcElP7eLbEMIOjNm(1qt4Y3X6TB36MVxRHCEhsdcaANtgwshanELKVl6qJ4frZYqoVdPbbaTZjdlPdGgGBZPG3s6orzGNPiAYjJFn0eU8DSEJnI7N0DIcAkFpDaxlaB(8KUJuEdh3pZsWdzoAIxKvlJ8rRTsJ4frZYqZ)5cGNc4M)vhana3MtbLiP7eLr42OiJFn0eU8DSEJDALgXlIMLHM)ZfapfWn)RoaAaUnNckrs3jkd8mfrtoz8RHMWLVJ1BSXo0iEr0SmLVNoGRfGnFdWT5uqjAT3f7sdjDNOmNzj4HmhnXlYYqt4Y3X6nI7N0DIcAkFpDaxlaB(8KUJuEdh3HewBuCHBJAO8ffqwBlJ8bjHSSP890bCTaS5BaUnNcERlDGbXZHNjqCCjUFs3jkOP890bCTaS5Zt6os5nCChsyTrXfUnQHYxuazTTmYhKeYYMY3thW1cWMVb42Ck4TKUtugiH1gfx42OgkFrbK1AOjC57y9gU00fC)KUtuqt57Pd4AbyZNN0DKYB44UWTrrg)2YiFqsilBeUnQHYPbWneADGbXZHNjqC7qxC)KUtuqt57Pd4AbyZNN0DKYB44on)NN0DII)dCBPsRFqsmVGNC4zce4(4(jDNOGMY3thW1cWMpNKyEXuOpkFpDaxlaB(TmYhWG45WZeiK4OlDAvFB(ETgTOPd4Wr7mkJxj57I2TjjKLnc3g1q50a4gcTgX9t6orbnLVNoGRfGnFojX8IPq3WXDA(pxa8ua38V6aiUFs3jkOP890bCTaS5ZjjMxmf6goUFMLGhYC0eViRwg5dAeViAwgA(pxa8ua38V6aOb42CkOe90VDGbXZHNjqiXHU4(jDNOGMY3thW1cWMpNKyEXuOB44Uw00bC4ODgvlJ8bjHSSP58c(y1Gg4M0RsCGAhsczzJWTrnuonaUbUj96Tdu7qsilBeUnQHY1IMoWiIMvhyq8C4zcesCOlUFs3jkOP890bCTaS5ZjjMxmf6goUFMLGhYC0eViRwg5dyq8C4zcesC0fC)KUtuqt57Pd4AbyZNtsmVyk0nCCNM)Zt6orX)bUTuP1pijMxWto8mbcgIuoaorX0b1l719lr9sDn96Ax1VmKMjOMcnKH0TLgQ)1rAGo6V1pyfwj5PJvJvlalwjhaSs)rd40WsMR(dwbCPnIb4cScgwhRsInS56cSIEMfAhAW97wMYXQUOFWQU1csOPfG1fyvs3jkSs)zQYbCHBJcQ)yW9X9Lgy1cW6cSsAIvjDNOWQFGl0G7ZqsI9mameKXknYq(bUqMKmKXQ9bCIIjjtNEmjziELKVly6XqOGzDWKmKwXksczztZ5f8XQbnWnPxXkjoWQlIvDWQwXkyq8C4zcey1nSsxSQDBSsd4sXrtfMEgA(pxa8ua38V6aiw1UnwrsilBAoVGpwnObUj9kwjXbw1DSQDBSsd4sXrtfMEgY5DiniaODozyjDaeRA3gRAfR0hwPbCP4OPctpZzwcEiZrt8ISWQoyL(WknGlfhnvyq1CMLGhYC0eVilSQrSQrSQdwPpSsd4sXrtfMEMZSe8qMJM4fzHvDWk9HvAaxkoAQWGQ5mlbpK5OjErwyvhSIKqw2iCBudLRfnDGrenlSQrSQDBSQvSAhRZ3GlghRUHv6IvDWksczztZ5f8XQbnWnPxXkjWQlXQgXQ2TXQwXknGlfhnvyq1qZ)5cGNc4M)vhaXQoyfjHSSP58c(y1Gg4M0RyLeyfQyvhSsFy1MVxRr42OgkNM)pfAJxj57cSQrgss3jkgYy1(aorXwMoOYKKH4vs(UGPhdHcM1btYqOr8IOzzGewBuCHBJAO8ffqwRb42CkiwDdR6Plw1UnwPpSYL2ignnxy6PlQ6EXUZqs6orXqqdgBmaNl7pAIeiylthDzsYq8kjFxW0JHqbZ6GjziTIv0iEr0SmqcRnkUWTrnu(IciR1aCBofeRUHvDhR6GvKeYYgHBJAOCA()uOna3MtbXQgXQ2TXQwXkAeViAwgiH1gfx42OgkFrbK1AaUnNcIv3WQE9WQoyL(WksczzJWTrnuon)Fk0gGBZPGyvJyv72yfnIxenldKWAJIlCBudLVOaYAna3MtbXkjWQEDLHK0DIIHqZ)5cGNc4M)vhazltNUYKKHK0DIIHajS2O4c3g1q5lkGSwgIxj57cMESLPtxysYq8kjFxW0JHqbZ6GjziWG45WZeiWkjoWQUWqs6orXqoZsWdzoAIxKfBz6CrMKmeVsY3fm9yiuWSoysgcmiEo8mbcSsIdSsxSQdw1kw1kw1kwPbCP4OPcdQMZSe8qMJM4fzHvTBJvKeYYMMZl4JvdAGBsVIvsCGv6IvnIvDWksczztZ5f8XQbnWnPxXQByv3XQgXQ2TXkAeViAwgiH1gfx42OgkFrbK1AaUnNcIv3oWk0ubwDbXkuXQ2TXksczzJWTrnuUw00bgGBZPGyLeyfAQaRUGyfQyvJmKKUtumKZSe8qMJM4fzXwMostMKmeVsY3fm9yiuWSoysgIgWLIJMkm9mNzj4HmhnXlYcR6GvWG45WZeiWkjoWQEyvhSQvSIKqw20CEbFSAqdCt6vS62bwPlw1UnwPbCP4OPcJUMZSe8qMJM4fzHvnIvDWkyq8C4zcey1nSQRyvhSIKqw2iCBudLtdGBi0yijDNOyic3gfz8lBz6OFzsYq8kjFxW0JHqbZ6GjziTIv0iEr0SmqcRnkUWTrnu(IciR1aCBofeRKaR66LyvhScQ5)Z3eG2xOzSAFaNOWQBhyfQyvJyv72yfnIxenldKWAJIlCBudLVOaYAna3MtbXQByvpuzijDNOyiqcRnkUuZ7YJxc2Y0P7mjziELKVly6XqOGzDWKmeAeViAwgiH1gfx42OgkFrbK1AaUnNcIvsGvDNHK0DIIHqoVdPbbaTZjdlPdGSLPtVlzsYq8kjFxW0JHqbZ6GjziWG45WZeiWQByvxWQoyfjHSSr42OgkNga3a3KEfRUDGvOYqs6orXqGbXZHlyU6SLPtVEmjziELKVly6XqOGzDWKmeyq8C4zcey1TdSsxSQdwrsilBeUnQHYPbWneAyvhSQvSIKqw2iCBudLtdGBGBsVIvsCGv6IvTBJvKeYYgHBJAOCAaCdWT5uqS62bwHMkWQliw1fJ0eRAKHK0DIIHiCBuKXVSLPtpuzsYq8kjFxW0JHK0DIIHiIWYqOOqFNVjaTVqMo9yi2SB4uuOVZ3eG2xidrAYqOGzDWKmeGldC4zs(oBz60txMKmeVsY3fm9yijDNOyi08FEs3jk(pWLH8dC5vADgcjX8cEYHNjqWw2YqeUCs8ltsMo9ysYqs6orXqGA()8pOxziELKVly6XwMoOYKKH4vs(UGPhdHcM1btYq081iCBudLVOaYAnjDhPCSQdw1kwPpSAZ3R1u(E6aUwa28nELKVlWQ2TXksczzt57Pd4AbyZ3qOHvnYqs6orXq0IDIITmD0LjjdXRK8DbtpgcfmRdMKHO5Rr42OgkFrbK1As6os5mKKUtumecOZN1Tq2Y0PRmjziELKVly6XqOGzDWKmenFnc3g1q5lkGSwts3rkNHK0DIIHq6aOdUofA2Y0PlmjziELKVly6XqOGzDWKmenFnc3g1q5lkGSwts3rkNHK0DIIHq(ri4YeauyltNlYKKH4vs(UGPhdHcM1btYq081iCBudLVOaYAnjDhPCgss3jkgI8aCYpcbBz6inzsYq8kjFxW0JHqbZ6Gjzi5fWbZ6gVB0(aos5CTy9AN8nGSUIvDWQDSowDdR6cw1bRGbXZHNjqGvsGvOIvDWksczzJ3nAFahPCUwSETt(gr0SWQoyfjHSSP58c(y1Gg4M0Ry1nSsxSQdwPpSsd4sXrtfMEMZSe8qMJM4fzHvDWk9HvAaxkoAQWGQ5mlbpK5OjErwmKKUtumKZSe8qMJM4fzXwMo6xMKmeVsY3fm9yiuWSoysgsEbCWSUX7gTpGJuoxlwV2jFdiRRyvhSIKqw20CEbFSAqdCt6vSscScvSQdwrsilB8Ur7d4iLZ1I1RDY3iIMfdjP7efdzSAFaNOyltNUZKKH4vs(UGPhdHcM1btYq0hwTd96uOXQoy1Ma0(A2X68n4IXXkjWkDVeR6Gvqn)F(Ma0(cnJv7d4efwDdRqLHK0DIIHiIWYwMo9UKjjdXRK8DbtpgcfmRdMKHKxahmRB8Ur7d4iLZ1I1RDY3aY6kwjbwDjw1bR2X6y1nSQ3LyvhScQ5)Z3eG2xOzSAFaNOWQByfQyvhSIKqw2iaEkGB(xDa0aCBofeR6GvB(ETMY3thW1cWMVXRK8DbdjP7efdHCEhsdcaANtgwshazltNE9ysYq8kjFxW0JHqbZ6GjziTIvKeYYMMZl4JvdAGBsVIv3WQlIvTBJvKeYYgHBJAOCTOPdmeAyvJyv72yfuZ)NVjaTVqZy1(aorHv3WkuzijDNOyic3g1q5Wf4f69KTmD6HktsgIxj57cMEmekywhmjdzZ3R1u(E6aUwa28nELKVlWQoyfuZ)NVjaTVqZy1(aorHv3oWkuzijDNOyi08FEs3jk(pWLH8dC5vADgs57Pd4AbyZNTmD6PltsgIxj57cMEmekywhmjdbQ5)Z3eG2xOzSAFaNOWkjWQEmKKUtumeA(ppP7ef)h4Yq(bU8kTodzSAFaNOyltNEDLjjdXRK8DbtpgcfmRdMKHqJ4frZYajS2O4c3g1q5lkGSwdWT5uqS6gw1txgss3jkgcAWyJb4Cz)rtKabBz60RlmjziELKVly6XqOGzDWKmeAeViAwgiH1gfx42OgkFrbK1AaUnNcIvsGvD9sSQDBSIgXlIMLbsyTrXfUnQHYxuazTgGBZPGy1nSQhQmKKUtumeiH1gfxQ5D5XlbBz607ImjziELKVly6XqOGzDWKmKwXkAeViAwgiH1gfx42OgkFrbK1AaUnNcIv3WQUJvDWksczzJWTrnuon)Fk0gGBZPGyvJyv72yvRyfnIxenldKWAJIlCBudLVOaYAna3MtbXQByvVEyvhSsFyfjHSSr42OgkNM)pfAdWT5uqSQrSQDBSIgXlIMLbsyTrXfUnQHYxuazTgGBZPGyLeyvVUYqs6orXqO5)CbWtbCZ)QdGSLPtpPjtsgss3jkgc58oKgea0oNmSKoaYq8kjFxW0JTmD6PFzsYq8kjFxW0JHqbZ6GjziWG45WZeiWQByLUyvhSQvSsFy1MVxRr42OgkNgfKWQTtugVsY3fyv72yfjHSSP58c(y1Gg4M0RyLey1LyvJmKKUtumeiH1gfx42OgkFrbK1YwMo96otsgIxj57cMEmekywhmjdHKqw20CEbFSAqdCt6vSsIdScvSQdwrsilBeUnQHYPbWnWnPxXQBhyfQyvhSIKqw2iCBudLRfnDGrenlSQdwb18)5Bcq7l0mwTpGtuy1nScvgss3jkgIw00bC4ODgfBz6G6LmjziELKVly6XqOGzDWKmKnFVwJicRXRK8Dbw1bRaUmWHNj57yvhSAtaAFn7yD(gCX4yLeyvRyLiwJicRb42Ckiw1awP7LyvJmKKUtumerew2Y0b1EmjziELKVly6XqOGzDWKmeyq8C4zceyLehyvxWQ2TXQwXkyq8C4zceyLehyLUyvhSIgXlIMLHM)ZfapfWn)RoaAaUnNcIvsGvDfR6GvTIv6dR289AnqcRnkUuZ7YJxcJxj57cSQDBSIgXlIMLbsyTrXLAExE8syaUnNcIvsGv6IvnIvnYqs6orXqoZsWdzoAIxKfBz6GkQmjziELKVly6XqOGzDWKmeyq8C4zcey1nSQlyvhSIKqw2iCBudLtdGBGBsVIv3oWkuzijDNOyiWG45WfmxD2Y0bvDzsYq8kjFxW0JHqbZ6GjziWG45WZeiWQBhyLUyvhSIKqw2iCBudLtdGBi0yijDNOyic3gfz8lBz6GAxzsYq8kjFxW0JHK0DIIHqZ)5jDNO4)axgYpWLxP1ziKeZl4jhEMabBzldrd40WsMltsMo9ysYq8kjFxW0JTmDqLjjdXRK8Dbtp2Y0rxMKmeVsY3fm9yltNUYKKHK0DIIHajS2O4Y(JMibcgIxj57cMESLPtxysYq8kjFxW0JHqbZ6GjziB(ETMPkhWfUnkOXRK8DbdjP7efdzQYbCHBJcYwMoxKjjdXRK8DbtpgcfmRdMKHqsilBAoVGpwnObUj9kwjbw1JHK0DIIHOfnDahoANrXwMostMKmKKUtumeTyNOyiELKVly6XwMo6xMKmeVsY3fm9yiuWSoysgczaHyv72yvs3jkJWTrrg)AOjC57yDS6aRUKHK0DIIHiCBuKXVSLTmKY3thW1cWMppP7iLZKKPtpMKmKKUtumeY5DiniaODozyjDaKH4vs(UGPhBz6GktsgIxj57cMEmekywhmjdHgXlIMLbsyTrXfUnQHYxuazTgGBZPGy1nSQNUyv72yL(WkxAJy00CHPNUOQ7f7odjP7efdbnySXaCUS)OjsGGTmD0LjjdXRK8DbtpgcfmRdMKHqJ4frZYajS2O4c3g1q5lkGSwdWT5uqSscSQRxIvTBJv0iEr0SmqcRnkUWTrnu(IciR1aCBofeRUHv9qLHK0DIIHajS2O4snVlpEjyltNUYKKH4vs(UGPhdHcM1btYqAfROr8IOzzGewBuCHBJAO8ffqwRb42CkiwDdR6ow1bRijKLnc3g1q508)PqBaUnNcIvnIvTBJvTIv0iEr0SmqcRnkUWTrnu(IciR1aCBofeRUHv96HvDWk9HvKeYYgHBJAOCA()uOna3MtbXQgXQ2TXkAeViAwgiH1gfx42OgkFrbK1AaUnNcIvsGv96kdjP7efdHM)ZfapfWn)RoaYwMoDHjjdjP7efdHCEhsdcaANtgwshaziELKVly6XwMoxKjjdXRK8DbtpgcfmRdMKHadINdptGaRoWQEyvhSQvSIgXlIMLHM)ZfapfWn)RoaAaUnNcIv3WQKUtug4zkIMCY4xdnHlFhRJvTBJvTIvB(ETgY5DiniaODozyjDa04vs(UaR6Gv0iEr0SmKZ7qAqaq7CYWs6aOb42CkiwDdRs6orzGNPiAYjJFn0eU8DSow1iw1idjP7efdHM)Zt6orX)bUmKFGlVsRZqijMxWto8mbc2Y0rAYKKH4vs(UGPhdHcM1btYqAfRAfROr8IOzzO5)CbWtbCZ)QdGgGBZPGyLeyvs3jkJWTrrg)AOjC57yDSQrSQdw1kwrJ4frZYqZ)5cGNc4M)vhana3MtbXkjWQKUtug4zkIMCY4xdnHlFhRJvnIvnIvDWkAeViAwMY3thW1cWMVb42Ckiwjbw1kw17IDbRAaRs6orzoZsWdzoAIxKLHMWLVJ1XQgzijDNOyiNzj4HmhnXlYITmD0VmjziELKVly6XqOGzDWKmesczzt57Pd4AbyZ3aCBofeRUHvDbR6GvWG45WZeiWQdS6sgss3jkgcKWAJIlCBudLVOaYAzltNUZKKH4vs(UGPhdHcM1btYqijKLnLVNoGRfGnFdWT5uqS6gwL0DIYajS2O4c3g1q5lkGSwdnHlFhRJvnGvxA6cdjP7efdbsyTrXfUnQHYxuazTSLPtVlzsYq8kjFxW0JHqbZ6GjziKeYYgHBJAOCAaCdHgw1bRGbXZHNjqGv3oWkDzijDNOyic3gfz8lBz60RhtsgIxj57cMEmKKUtumeA(ppP7ef)h4Yq(bU8kTodHKyEbp5WZeiylBziLVNoGRfGnFojX8IPqZKKPtpMKmeVsY3fm9yiuWSoysgcmiEo8mbcSsIdSQlyvhSQvSsFy1MVxRrlA6aoC0oJY4vs(UaRA3gRijKLnc3g1q50a4gcnSQrgss3jkgs57Pd4AbyZNTmDqLjjdjP7efdHM)ZfapfWn)RoaYq8kjFxW0JTmD0LjjdXRK8DbtpgcfmRdMKHqJ4frZYqZ)5cGNc4M)vhana3MtbXkjWQE6xSQdwbdINdptGaRK4aR0LHK0DIIHCMLGhYC0eVil2Y0PRmjziELKVly6XqOGzDWKmesczztZ5f8XQbnWnPxXkjoWkuXQoyfjHSSr42OgkNga3a3KEfRUDGvOIvDWksczzJWTrnuUw00bgr0SWQoyfmiEo8mbcSsIdSsxgss3jkgIw00bC4ODgfBz60fMKmeVsY3fm9yiuWSoysgcmiEo8mbcSsIdSQlmKKUtumKZSe8qMJM4fzXwMoxKjjdXRK8Dbtpgss3jkgcn)NN0DII)dCzi)axELwNHqsmVGNC4zceSLTmesI5f8KdptGGjjtNEmjzijDNOyiWG45WfmxDgIxj57cMESLPdQmjzijDNOyiWZuen5KXVmeVsY3fm9ylBziLVNoGRfGnFMKmD6XKKH4vs(UGPhdHcM1btYqOr8IOzzkFpDaxlaB(gGBZPGy1nSc1lzijDNOyi08FEs3jk(pWLH8dC5vADgs57Pd4AbyZNtsmVyk0SLPdQmjziELKVly6XqOGzDWKmesczzt57Pd4AbyZ3qOXqs6orXqO5)8KUtu8FGld5h4YR06mKY3thW1cWMppP7iLZw2Yw2Ywgda]] )

    
end
