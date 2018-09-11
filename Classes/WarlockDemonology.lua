-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 266 )

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

            elseif subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 196277 then
                    table.wipe( wild_imps )
                    table.wipe( imps )
                
                elseif spellID == 264130 then
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                
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
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shards" and buff.nether_portal.up then
            summon_demon( "other", 15, amt )
        end
    end )


    spec:RegisterStateFunction( "summon_demon", function( name, duration, count )
        local db = other_demon_v

        if name == 'dreadstalkers' then db = dreadstalkers_v
        elseif name == 'vilefiend' then db = vilefiend_v
        elseif name == 'wild_imps' then db = wild_imps_v
        elseif name == 'demonic_tyrant' then db = demonic_tyrant_v end

        count = count or 1
        local expires = query_time + duration

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
            duration = 30,            
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
            duration = 20,
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

    } )


    -- Abilities
    spec:RegisterAbilities( {
        axe_toss = {
            id = 119914,
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
        

        command_demon = {
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
        },
        

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
                summon_demon( "wild_imps", 25, 1 + extra_shards )
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
            
            spend = 3,
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
            
            usable = function () return buff.wild_imps.count > 0 end,
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
                extend_demons()
            end,
        },

        
        summon_pet = {
            id = 30146,
            cast = function () return 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = false,
            essential = true,

            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( 'felguard', 3600 )
            end,

            copy = "summon_felguard"
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


    spec:RegisterPack( "Demonology", 20180813.1603, [[dGuP)aqifIEesKInPi9jfcyuukofLOvHejVIsvZsr4wQqsTlk(fLsdtfQJPqTmIWZisnnKiUgsuBtfIVPqOXPiIZPiQ1PqqMNk4EkQ9Ps1bviqlKsLhQcPstufsYfviO8rvivzKQqQ4KQqkwjr0mvHuv7KsyOQqIwQcbvpfOPsKCvKiL(QkKWEj8xedMuhwYIjQhJYKH6YuTzK6ZQKrJKoTuVwLYSHCBs2TOFlmCfCCfrA5Q65GMUsxhW2vi9DkPXJeP68iH1RcP08vr7hvlglKsaIR1fwiXXJNKJNKXsBgFKJL(4XcWLIbxaouSB1LlaZs5cWJkxfzGIlkeGdffOOWcPeGWa4zUaK6UdWriBT9QxQaYgwOSf2kauTDKSVOxBHTIzRmkKTvMUoQX(O2o8bDJCOTs1(lXyBLsIXKJI6rb7g5OYvrgO4IcdSvmbOmqJ2JMuilaX16clK44XtYXtYyPnJPmLNKJLwachCMWcjoYreGyhYeGsrTHCDd56LQZ1yNUaqlxpuSB1LZ10XZ1hvUkYafxuW1hf1Jc2nix3jxBxTlY5A6456rWJw)JLQHljxYJYaUh1TAi(LRzuR8YHJqCjhB4AUMsl05AzaAAt6lv)jdXVfYamW1DcxVWCDqZ1Siq4WAY1yGV2osUMoEUo9LQ)KH43crk22J6CDX2osUg1W1WLucdxZ1JGySJ56IRhENfk5A56JYWQ)CnypqnsUUP5AkcaUMAnQZ1sW1TAaY1BW1SiHakNRTH2DefSVOxlncWHpOBKlaP0W1JWO0DgW6yUw2PJ35AwOKRLRL9RoHgUEeKX8HfY1zKh1uRxrdG46ITDKqUosefgUKfB7iHMH3zHsU2zAubVXLSyBhj0m8oluY1A)ST0rG5swSTJeAgENfk5ATF22c4s55wBhjxYITDKqZW7SqjxR9Z2cbuQijd(YLSyBhj0m8oluY1A)STDM(tWUks4en98wipxtNP)eSRIeA8SKroMlzX2osOz4DwOKR1(zBhcR(tG9a1iNOPNLbOPnwBeM0QbObUf729zj4swSTJeAgENfk5ATF2wywdqQXsGBTqUKfB7iHMH3zHsUw7NTDi2osUKfB7iHMH3zHsUw7NTf7QiLd0YLKljLgUEegLUZawhZ1(O(tbxVTY56LQZ1fBJNRBixxJwnQKrUHlzX2os4mCWricky34swSTJeA)STdX2rortpp4Rb7QiBgzP4RCnfB7r9ZZT(lFnBRCYgeC7hK(yUKfB7iH2pBla0j96k4en98GVgSRISzKLIVY1uSTh1pp36V81STYjBqWTFyEmL5swSTJeA)STY(d9)wNxt00Zd(AWUkYMrwk(kxtX2Eu)8CR)YxZ2kNSbb3(H5XuMlzX2osO9Z2kJIatObEkMOPNh81GDvKnJSu8vUMIT9O(55w)LVMTvozdcU9dZJPmxYITDKq7NTLUFxgfbEIMEEWxd2vr2mYsXx5Ak22J6NNB9x(A2w5Kni42pmpMYCjl22rcTF2wCeQjA65rUn7wNxt3w5Kni42Vl9XtHdocr26V8fAA1akGDKhKGlzX2osO9Z2IDvKnJa33ZRL6en9SnYa00gRnctA1a0a3ID7WropLbOPnyxfzZidHv)nadwEEchCeIS1F5l00Qbua7ipibxYITDKq7NTLviePyBhjb1WDISu(C6lv)jdXVfAIMEElKNRj9LQ)KH43cz8SKroEkCWriYw)LVqtRgqbSJ8WSeCjl22rcTF2wwHqKITDKeud3jYs5ZTAafWoYjA6z4GJqKT(lFHMwnGcyh59XCjl22rcTF22RVvr)oH2rxa1JNOPNzrGWH10abuQijyxfzZilfFLR5Dv1j8WyPpphPpPa9WGJnJLwcPpYK5swSTJeA)STqaLksYOnYPBpXt00Z(Kc0ddo2mwAjK(it(8KfbchwtdeqPIKGDvKnJSu8vUM3vvNW7uYXNNSiq4WAAGakvKeSRISzKLIVY18UQ6eEySeCjl22rcTF2wwHqe87fgUf6M)WjA6zFsb6HbhBglTesFKjFEAdlceoSMgiGsfjb7QiBgzP4RCnVRQoHhM8uzaAAd2vr2mcRqOoVmVRQoHwEEAdlceoSMgiGsfjb7QiBgzP4RCnVRQoHhgpE6iLbOPnyxfzZiScH68Y8UQ6eA55jlceoSMgiGsfjb7QiBgzP4RCnVRQoH3htjCjl22rcTF2wiGsfjb7QiBgzP4RCNOPN9jfOhgCSzS0si9rM85PnYa00g87fgUf6M)qZ7QQt4DwbxY2kFQnYa00gRnctA1a0a3ID7(S0NNdVpk5IHnJnuRetcAYfacxPLtTbgaicKA94dsFEkdqtBWVxy4wOB(dnVRQoHhUyykLeMr88ugGM2C9Tk63j0o6cOES5Dv1j8WfdtPKWmIwAjxYITDKq7NTDiS6pb2duJCIMEwgGM2yTrysRgGg4wSB3NLyQmanTb7QiBgHfVBGBXUDywIPYa00gSRISzKHWQ)gCynNchCeIS1F5l00Qbua7ipibxYITDKq7NTfhHAIMEElKNRbhHY4zjJC803PFhsTKr(0TvozdcU972GJ1GJqzExvDcTx6JTKlzX2osO9Z2sTsmjOjxaiCLt00ZWaarGuRhFFMYNN2adaebsTE89zPNYIaHdRPHvieb)EHHBHU5p08UQ6eENsMAZi3c55AGakvKKrBKt3EInEwYihFEYIaHdRPbcOursgTroD7j28UQ6eExAlTKlzX2osO9Z2cdaebUFFZNOPNHbaIaPwp(aLNkdqtBWUkYMryX7g4wSBhMLGlzX2osO9Z2IDvKYbANOPNHbaIaPwp(WS0tLbOPnyxfzZiS4DdWWuBSHfbchwtdeqPIKGDvKnJSu8vUM3vvNWdJp(8KfbchwtdeqPIKGDvKnJSu8vUM3vvNW7siHLNNYa00gSRISzew8UbUf729zPppLbOPnyxfzZiS4DZ7QQt4bkFEUTYjBqWTFqckBjxYITDKq7NTLviePyBhjb1WDISu(SmqJWKIaPwpMljxYITDKqJmqJWKIaPwpEg7QiLd0ortpxhT(3RBOJxUXypj3YWkYXxUXZsg54PYa00g64LBm2tYTmSIC8LBEVy70rkdqtBWUkYMryX7M3l2oLfbchwtdeqPIKGDvKnJSu8vUM3vvNW7sCmxYITDKqJmqJWKIaPwp2(zBHbaIa3VV5Cjl22rcnYanctkcKA9y7NTfsTWHvICGwUKCjl22rcnTAafWoY5wnGcyh5en9SnYa00gRnctA1a0a3ID7(8rMAdmaqei16XhK(8C49rjxmSzSHvieb)EHHBHU5p88ugGM2yTrysRgGg4wSB3NN855W7JsUyyZyJCJCila(lNihkz)HNN2mYH3hLCXWMXgQvIjbn5caHRC6ihEFuYfdBKWqTsmjOjxaiCLwA50ro8(OKlg2m2qTsmjOjxaiCLth5W7JsUyyJegQvIjbn5caHRCQmanTb7QiBgziS6VbhwtlppTzBLt2GGB)G0tLbOPnwBeM0QbObUf729JT880MH3hLCXWgjmScHi43lmCl0n)HtLbOPnwBeM0QbObUf72DjMoYTqEUgSRISzewHqDEz8SKro2sUKfB7iHMwnGcyhP9Z2E9Tk63j0o6cOE8en9mlceoSMgiGsfjb7QiBgzP4RCnVRQoHhgl955i9jfOhgCSzS0si9rMmxYITDKqtRgqbSJ0(zBzfcrWVxy4wOB(dNOPNTHfbchwtdeqPIKGDvKnJSu8vUM3vvNWdtEQmanTb7QiBgHviuNxM3vvNqlppTHfbchwtdeqPIKGDvKnJSu8vUM3vvNWdJhpDKYa00gSRISzewHqDEzExvDcT88KfbchwtdeqPIKGDvKnJSu8vUM3vvNW7JPeUKfB7iHMwnGcyhP9Z2cbuQijyxfzZilfFLlxYITDKqtRgqbSJ0(zBPwjMe0KlaeUYjA6zyaGiqQ1JVptzUKfB7iHMwnGcyhP9Z2sTsmjOjxaiCLt00ZWaarGuRhFFw6P2yJndVpk5IHnsyOwjMe0KlaeUYZtzaAAJ1gHjTAaAGBXUDFwAlNkdqtBS2imPvdqdCl2Tdt2YZtweiCynnqaLksc2vr2mYsXx5AExvDcpmFXWukjopLbOPnyxfzZidHv)nVRQoH3VyykLewYLSyBhj00Qbua7iTF2wSRIuoq7en98W7JsUyyZyd1kXKGMCbGWvofgaicKA947ZJNAJmanTXAJWKwnanWTy3oml955W7JsUyyJ0gQvIjbn5caHR0YPWaarGuRhFGsMkdqtBWUkYMryX7gGbUKfB7iHMwnGcyhP9Z2cbuQijJ2iNU9eprtpBdlceoSMgiGsfjb7QiBgzP4RCnVRQoH3PKJNchCeIS1F5l00Qbua7ipmlHLNNSiq4WAAGakvKeSRISzKLIVY18UQ6eEySeCjl22rcnTAafWos7NTvUroKfa)LtKdLS)WjA6zweiCynnqaLksc2vr2mYsXx5AExvDcVpzUKfB7iHMwnGcyhP9Z2cdaebUFFZNOPNHbaIaPwp(aLNkdqtBWUkYMryX7g4wSBhMLGlzX2osOPvdOa2rA)STyxfPCG2jA6zyaGiqQ1Jpml9uzaAAd2vr2mclE3amm1gzaAAd2vr2mclE3a3ID7(S0NNYa00gSRISzew8U5Dv1j8W8fdtPOSzeTKlzX2osOPvdOa2rA)ST4iutWOGHCYw)LVW5XtOkkDcJcgYjB9x(cNhXjA653PFhsTKroxYITDKqtRgqbSJ0(zBzfcrk22rsqnCNilLpld0imPiqQ1J5sYLSyBhj0K(s1FYq8BHMzfcrk22rsqnCNilLpN(s1FYq8BHiYanc351en9SmanTj9LQ)KH43czag4swSTJeAsFP6pzi(Tq2pBlRqisX2oscQH7ezP850xQ(tgIFlePyBpQprtpZIaHdRPj9LQ)KH43czExvDcVp(ihZLKlzX2osOj9LQ)KH43crk22J6ZxFRI(DcTJUaQhprtpZIaHdRPbcOursWUkYMrwk(kxZ7QQt4HXsFEosFsb6HbhBglTesFKjZLSyBhj0K(s1FYq8BHifB7rD7NTfcOursgTroD7jEIMEMfbchwtdeqPIKGDvKnJSu8vUM3vvNW7uYXNNSiq4WAAGakvKeSRISzKLIVY18UQ6eEySeCjl22rcnPVu9Nme)wisX2Eu3(zBzfcrWVxy4wOB(dNOPNTHfbchwtdeqPIKGDvKnJSu8vUM3vvNWdtEQmanTb7QiBgHviuNxM3vvNqlppTHfbchwtdeqPIKGDvKnJSu8vUM3vvNWdJhpDKYa00gSRISzewHqDEzExvDcT88KfbchwtdeqPIKGDvKnJSu8vUM3vvNW7JPeUKfB7iHM0xQ(tgIFlePyBpQB)STScHifB7ijOgUtKLYNLbAeMuei16Xt00ZWaarGuRhppEQnSiq4WAAyfcrWVxy4wOB(dnVRQoHhk22rAGulCyLihO1Wk4s2w5NN2SfYZ1i3ihYcG)YjYHs2FOXZsg54PSiq4WAAKBKdzbWF5e5qj7p08UQ6eEOyBhPbsTWHvICGwdRGlzBLBPLCjl22rcnPVu9Nme)wisX2Eu3(zBPwjMe0KlaeUYjA6zBSHfbchwtdRqic(9cd3cDZFO5Dv1j8EX2osd2vrkhO1Wk4s2w5wo1gweiCynnScHi43lmCl0n)HM3vvNW7fB7inqQfoSsKd0AyfCjBRClTCklceoSMM0xQ(tgIFlK5Dv1j8UnJpYX2xSTJ0qTsmjOjxaiCLgwbxY2k3sUKfB7iHM0xQ(tgIFlePyBpQB)STqaLksc2vr2mYsXx5ortpldqtBsFP6pzi(TqM3vvNWdJpEkmaqei16XZhZLSyBhj0K(s1FYq8BHifB7rD7NTfcOursWUkYMrwk(k3jA6zzaAAt6lv)jdXVfY8UQ6eEOyBhPbcOursWUkYMrwk(kxdRGlzBLBpLnuMlzX2osOj9LQ)KH43crk22J62pBl2vrkhODIMEwgGM2GDvKnJWI3nadCjl22rcnPVu9Nme)wisX2Eu3(zBzfcrk22rsqnCNilLpld0imPiqQ1J5sYLSyBhj0K(s1FYq8BHiYanc351C6lv)jdXVfAIMEggaicKA947ZuEQnJClKNRziS6pb2duJ04zjJC85PmanTb7QiBgHfVBagSKlzX2osOj9LQ)KH43crKbAeUZl7NTLvieb)EHHBHU5pKlzX2osOj9LQ)KH43crKbAeUZl7NTLALysqtUaq4kNOPNzrGWH10WkeIGFVWWTq38hAExvDcVpEsMcdaebsTE89zP5swSTJeAsFP6pzi(TqezGgH78Y(zBhcR(tG9a1iNOPNLbOPnwBeM0QbObUf729zjMkdqtBWUkYMryX7g4wSBhMLyQmanTb7QiBgziS6VbhwZPWaarGuRhFFwAUKfB7iHM0xQ(tgIFlergOr4oVSF2wQvIjbn5caHRCIMEggaicKA947ZuMlzX2osOj9LQ)KH43crKbAeUZl7NTLviePyBhjb1WDISu(SmqJWKIaPwpwaoQ)WosHfsC84j54j54r0C8XstzbO16ZoVGcWJIrWr4wC0yXrVriUMRLIQZ1TAi(LRPJNRhbgENfk5Ahb463NuG(DmxddLZ1fWgQADmxZOw5LdnCjp63PZ1uEeIRP0MqGHH4xhZ1fB7i56rGot)jyxfjCeWWLKl5rJAi(1XC9iY1fB7i5AudxOHlPae1WfkKsaM(s1FYq8BHesjSySqkbONLmYXc7eGSVx)7sakdqtBsFP6pzi(TqgGbbyX2osbiRqisX2oscQHRae1WLKLYfGPVu9Nme)wiImqJWDEjwHfsiKsa6zjJCSWobi771)UeGSiq4WAAsFP6pzi(TqM3vvNqU(oxp(ihlal22rkazfcrk22rsqnCfGOgUKSuUam9LQ)KH43crk22J6IvScqStxaOviLWIXcPeGfB7ifGWbhHiOGDta6zjJCSWoXkSqcHucqplzKJf2jazFV(3LaCWxd2vr2mYsXx5Ak22J6C95jxV1F5RzBLt2GGBNRpW1sFSaSyBhPaCi2osXkSqAHucqplzKJf2jazFV(3LaCWxd2vr2mYsXx5Ak22J6C95jxV1F5RzBLt2GGBNRpmZ1JPSaSyBhPaea6KEDfuSclOeHucqplzKJf2jazFV(3LaCWxd2vr2mYsXx5Ak22J6C95jxV1F5RzBLt2GGBNRpmZ1JPSaSyBhPau2FO)368sSclOSqkbONLmYXc7eGSVx)7sao4Rb7QiBgzP4RCnfB7rDU(8KR36V81STYjBqWTZ1hM56XuwawSTJuakJIatObEkeRWIJiKsa6zjJCSWobi771)UeGd(AWUkYMrwk(kxtX2EuNRpp56T(lFnBRCYgeC7C9HzUEmLfGfB7ifG097YOiWIvyXikKsa6zjJCSWobi771)UeGJKR3MDRZlUEkxVTYjBqWTZ135APpMRNY1WbhHiB9x(cnTAafWosU(axlHaSyBhPaehHsSclMeHucqplzKJf2jazFV(3La0gUwgGM2yTrysRgGg4wSBC9bU(iC95jxldqtBWUkYMrgcR(Bag4Al56ZtUgo4iezR)YxOPvdOa2rY1h4AjeGfB7ifGyxfzZiW998APkwHftwiLa0Zsg5yHDcq23R)Dja3c55AsFP6pzi(TqgplzKJ56PCnCWriYw)LVqtRgqbSJKRpmZ1sial22rkazfcrk22rsqnCfGOgUKSuUam9LQ)KH43cjwHfJpwiLa0Zsg5yHDcq23R)DjaHdocr26V8fAA1akGDKC9DUESaSyBhPaKviePyBhjb1WvaIA4sYs5cWwnGcyhPyfwmESqkbONLmYXc7eGSVx)7saYIaHdRPbcOursWUkYMrwk(kxZ7QQtixFGRhlnxFEY1JKR9jfOhgCSXAJOFhdjW(QrKGMabg8VJNabuQi78sawSTJuaE9Tk63j0o6cOESyfwmwcHucqplzKJf2jazFV(3La0NuGEyWXgRnI(DmKa7RgrcAceyW)oEceqPISZlU(8KRzrGWH10abuQijyxfzZilfFLR5Dv1jKRVZ1uYXC95jxZIaHdRPbcOursWUkYMrwk(kxZ7QQtixFGRhlHaSyBhPaecOursgTroD7jwSclglTqkbONLmYXc7eGSVx)7sa6tkqpm4yJ1gr)ogsG9vJibnbcm4FhpbcOur25fxFEY12W1Siq4WAAGakvKeSRISzKLIVY18UQ6eY1h46jZ1t5AzaAAd2vr2mcRqOoVmVRQoHCTLC95jxBdxZIaHdRPbcOursWUkYMrwk(kxZ7QQtixFGRhpMRNY1JKRLbOPnyxfzZiScH68Y8UQ6eY1wY1NNCnlceoSMgiGsfjb7QiBgzP4RCnVRQoHC9DUEmLial22rkazfcrWVxy4wOB(dfRWIXuIqkbONLmYXc7eGSVx)7sa6tkqpm4yJ1gr)ogsG9vJibnbcm4FhpbcOur25fxFEY12W1Ya00g87fgUf6M)qZ7QQtixFNRzfCjBRCUEkxBdxldqtBS2imPvdqdCl2nU((mxlnxFEY1dVpk5IHnJnuRetcAYfacxjxBjxpLRTHRHbaIaPwpMRpW1sZ1NNCTmanTb)EHHBHU5p08UQ6eY1h46lgMRPuCTeMrKRpp5AzaAAZ13QOFNq7OlG6XM3vvNqU(axFXWCnLIRLWmICTLCTLcWITDKcqiGsfjb7QiBgzP4RCfRWIXuwiLa0Zsg5yHDcq23R)DjaLbOPnwBeM0QbObUf7gxFFMRLGRNY1Ya00gSRISzew8UbUf7gxFyMRLGRNY1Ya00gSRISzKHWQ)gCyn56PCnCWriYw)LVqtRgqbSJKRpW1sial22rkahcR(tG9a1ifRWIXhriLa0Zsg5yHDcq23R)Dja3c55AWrOmEwYihZ1t563PFhsTKroxpLR3w5Kni42567CTnCnowdocL5Dv1jKRTNRL(yU2sbyX2osbiocLyfwmEefsja9SKrowyNaK996FxcqyaGiqQ1J567ZCnL56ZtU2gUggaicKA9yU((mxlnxpLRzrGWH10WkeIGFVWWTq38hAExvDc567CnLW1t5AB46rY1BH8CnqaLksYOnYPBpXgplzKJ56ZtUMfbchwtdeqPIKmAJC62tS5Dv1jKRVZ1sZ1wY1wkal22rkaPwjMe0KlaeUsXkSy8KiKsa6zjJCSWobi771)UeGWaarGuRhZ1h4AkZ1t5AzaAAd2vr2mclE3a3IDJRpmZ1sial22rkaHbaIa3VV5IvyX4jlKsa6zjJCSWobi771)UeGWaarGuRhZ1hM5AP56PCTmanTb7QiBgHfVBag46PCTnCTnCnlceoSMgiGsfjb7QiBgzP4RCnVRQoHC9bUE8XC95jxZIaHdRPbcOursWUkYMrwk(kxZ7QQtixFNRLqcU2sU(8KRLbOPnyxfzZiS4DdCl2nU((mxlnxFEY1Ya00gSRISzew8U5Dv1jKRpW1uMRpp56TvozdcUDU(axlbL5AlfGfB7ifGyxfPCGwXkSqIJfsja9SKrowyNaSyBhPaKviePyBhjb1WvaIA4sYs5cqzGgHjfbsTESyfRaC4DwOKRviLWIXcPeGEwYihlStSclKqiLa0Zsg5yHDIvyH0cPeGEwYihlStSclOeHucWITDKcqiGsfjH2rubY1FbONLmYXc7eRWcklKsa6zjJCSWobi771)UeGBH8CnDM(tWUksOXZsg5ybyX2osbyNP)eSRIekwHfhriLa0Zsg5yHDcq23R)DjaLbOPnwBeM0QbObUf7gxFFMRLqawSTJuaoew9Na7bQrkwHfJOqkbONLmYXc7eRWIjriLaSyBhPaCi2osbONLmYXc7eRWIjlKsawSTJuaIDvKYbAfGEwYihlStSIva2Qbua7ifsjSySqkbONLmYXc7eGSVx)7saAdxldqtBS2imPvdqdCl2nU((mxFeUEkxBdxddaebsTEmxFGRLMRpp56H3hLCXWMXgwHqe87fgUf6M)qU(8KRLbOPnwBeM0QbObUf7gxFFMRNmxFEY1dVpk5IHnJnYnYHSa4VCICOK9hY1NNCTnC9i56H3hLCXWMXgQvIjbn5caHRKRNY1JKRhEFuYfdBKWqTsmjOjxaiCLCTLCTLC9uUEKC9W7JsUyyZyd1kXKGMCbGWvY1t56rY1dVpk5IHnsyOwjMe0KlaeUsUEkxldqtBWUkYMrgcR(BWH1KRTKRpp5AB46TvozdcUDU(axlnxpLRLbOPnwBeM0QbObUf7gxFNRpMRTKRpp5AB46H3hLCXWgjmScHi43lmCl0n)HC9uUwgGM2yTrysRgGg4wSBC9DUwcUEkxpsUElKNRb7QiBgHviuNxgplzKJ5AlfGfB7ifGTAafWosXkSqcHucqplzKJf2jazFV(3LaKfbchwtdeqPIKGDvKnJSu8vUM3vvNqU(axpwAU(8KRhjx7tkqpm4yJ1gr)ogsG9vJibnbcm4FhpbcOur25LaSyBhPa86Bv0VtOD0fq9yXkSqAHucqplzKJf2jazFV(3La0gUMfbchwtdeqPIKGDvKnJSu8vUM3vvNqU(axpzUEkxldqtBWUkYMryfc15L5Dv1jKRTKRpp5AB4AweiCynnqaLksc2vr2mYsXx5AExvDc56dC94XC9uUEKCTmanTb7QiBgHviuNxM3vvNqU2sU(8KRzrGWH10abuQijyxfzZilfFLR5Dv1jKRVZ1JPebyX2osbiRqic(9cd3cDZFOyfwqjcPeGfB7ifGqaLksc2vr2mYsXx5ka9SKrowyNyfwqzHucqplzKJf2jazFV(3LaegaicKA9yU((mxtzbyX2osbi1kXKGMCbGWvkwHfhriLa0Zsg5yHDcq23R)DjaHbaIaPwpMRVpZ1sZ1t5AB4AB4AB46H3hLCXWgjmuRetcAYfacxjxFEY1Ya00gRnctA1a0a3IDJRVpZ1sZ1wY1t5AzaAAJ1gHjTAaAGBXUX1h46jZ1wY1NNCnlceoSMgiGsfjb7QiBgzP4RCnVRQoHC9HzU(IH5AkfxlbxFEY1Ya00gSRISzKHWQ)M3vvNqU(oxFXWCnLIRLGRTuawSTJuasTsmjOjxaiCLIvyXikKsa6zjJCSWobi771)UeGdVpk5IHnJnuRetcAYfacxjxpLRHbaIaPwpMRVpZ1J56PCTnCTmanTXAJWKwnanWTy346dZCT0C95jxp8(OKlg2iTHALysqtUaq4k5Al56PCnmaqei16XC9bUMs46PCTmanTb7QiBgHfVBageGfB7ifGyxfPCGwXkSysesja9SKrowyNaK996FxcqB4AweiCynnqaLksc2vr2mYsXx5AExvDc567CnLCmxpLRHdocr26V8fAA1akGDKC9HzUwcU2sU(8KRzrGWH10abuQijyxfzZilfFLR5Dv1jKRpW1JLqawSTJuacbuQijJ2iNU9elwHftwiLa0Zsg5yHDcq23R)DjazrGWH10abuQijyxfzZilfFLR5Dv1jKRVZ1twawSTJuak3ihYcG)YjYHs2FOyfwm(yHucqplzKJf2jazFV(3LaegaicKA9yU(axtzUEkxldqtBWUkYMryX7g4wSBC9HzUwcbyX2osbimaqe4(9nxSclgpwiLa0Zsg5yHDcq23R)DjaHbaIaPwpMRpmZ1sZ1t5AzaAAd2vr2mclE3amW1t5AB4AzaAAd2vr2mclE3a3IDJRVpZ1sZ1NNCTmanTb7QiBgHfVBExvDc56dZC9fdZ1ukUMYMrKRTuawSTJuaIDvKYbAfRWIXsiKsa6zjJCSWobyX2osbiocLaKrbd5KT(lFHclglavfLoHrbd5KT(lFHcWruaY(E9Vlb470VdPwYixSclglTqkbONLmYXc7eGfB7ifGScHifB7ijOgUcqudxswkxakd0imPiqQ1JfRyfGPVu9Nme)wiImqJWDEjKsyXyHucqplzKJf2jazFV(3LaegaicKA9yU((mxtzUEkxBdxpsUElKNRziS6pb2duJ04zjJCmxFEY1Ya00gSRISzew8UbyGRTuawSTJuaM(s1FYq8BHeRWcjesjal22rkazfcrWVxy4wOB(dfGEwYihlStSclKwiLa0Zsg5yHDcq23R)DjazrGWH10WkeIGFVWWTq38hAExvDc567C94jHRNY1WaarGuRhZ13N5APfGfB7ifGuRetcAYfacxPyfwqjcPeGEwYihlStaY(E9VlbOmanTXAJWKwnanWTy3467ZCTeC9uUwgGM2GDvKnJWI3nWTy346dZCTeC9uUwgGM2GDvKnJmew93GdRjxpLRHbaIaPwpMRVpZ1slal22rkahcR(tG9a1ifRWcklKsa6zjJCSWobi771)UeGWaarGuRhZ13N5Aklal22rkaPwjMe0KlaeUsXkS4icPeGEwYihlStawSTJuaYkeIuSTJKGA4karnCjzPCbOmqJWKIaPwpwSIvakd0imPiqQ1JfsjSySqkbONLmYXc7eGSVx)7sawhT(3RBOJxUXypj3YWkYXxUXZsg5yUEkxldqtBOJxUXypj3YWkYXxU59ITC9uUEKCTmanTb7QiBgHfVBEVylxpLRzrGWH10abuQijyxfzZilfFLR5Dv1jKRVZ1sCSaSyBhPae7QiLd0kwHfsiKsawSTJuacdaebUFFZfGEwYihlStSclKwiLaSyBhPaesTWHvICGwbONLmYXc7eRyfGPVu9Nme)wisX2EuxiLWIXcPeGEwYihlStaY(E9VlbilceoSMgiGsfjb7QiBgzP4RCnVRQoHC9bUES0C95jxpsU2NuGEyWXgRnI(DmKa7RgrcAceyW)oEceqPISZlbyX2osb413QOFNq7OlG6XIvyHecPeGEwYihlStaY(E9VlbilceoSMgiGsfjb7QiBgzP4RCnVRQoHC9DUMsoMRpp5AweiCynnqaLksc2vr2mYsXx5AExvDc56dC9yjeGfB7ifGqaLksYOnYPBpXIvyH0cPeGEwYihlStaY(E9VlbOnCnlceoSMgiGsfjb7QiBgzP4RCnVRQoHC9bUEYC9uUwgGM2GDvKnJWkeQZlZ7QQtixBjxFEY12W1Siq4WAAGakvKeSRISzKLIVY18UQ6eY1h46XJ56PC9i5AzaAAd2vr2mcRqOoVmVRQoHCTLC95jxZIaHdRPbcOursWUkYMrwk(kxZ7QQtixFNRhtjcWITDKcqwHqe87fgUf6M)qXkSGsesja9SKrowyNaK996FxcqyaGiqQ1J56zUEmxpLRTHRzrGWH10WkeIGFVWWTq38hAExvDc56dCDX2osdKAHdRe5aTgwbxY2kNRpp5AB46TqEUg5g5qwa8xorouY(dnEwYihZ1t5AweiCynnYnYHSa4VCICOK9hAExvDc56dCDX2osdKAHdRe5aTgwbxY2kNRTKRTuawSTJuaYkeIuSTJKGA4karnCjzPCbOmqJWKIaPwpwSclOSqkbONLmYXc7eGSVx)7saAdxBdxZIaHdRPHvieb)EHHBHU5p08UQ6eY1356ITDKgSRIuoqRHvWLSTY5Al56PCTnCnlceoSMgwHqe87fgUf6M)qZ7QQtixFNRl22rAGulCyLihO1Wk4s2w5CTLCTLC9uUMfbchwtt6lv)jdXVfY8UQ6eY135AB46Xh5yU2EUUyBhPHALysqtUaq4knScUKTvoxBPaSyBhPaKALysqtUaq4kfRWIJiKsa6zjJCSWobi771)UeGYa00M0xQ(tgIFlK5Dv1jKRpW1JpMRNY1WaarGuRhZ1ZC9XcWITDKcqiGsfjb7QiBgzP4RCfRWIruiLa0Zsg5yHDcq23R)DjaLbOPnPVu9Nme)wiZ7QQtixFGRl22rAGakvKeSRISzKLIVY1Wk4s2w5CT9CnLnuwawSTJuacbuQijyxfzZilfFLRyfwmjcPeGEwYihlStaY(E9VlbOmanTb7QiBgHfVBageGfB7ifGyxfPCGwXkSyYcPeGEwYihlStawSTJuaYkeIuSTJKGA4karnCjzPCbOmqJWKIaPwpwSIvScWcyPgVa8OtLyyOCUgSvhD56JspgqUyfRqaa]] )
end
