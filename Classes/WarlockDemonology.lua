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


    spec:RegisterPack( "Demonology", 20180914.1107, [[dKKgcbqifjEefs2KIYNOqknkkuNIIYQiiQxPqzwkuDlkeTlk9lcyyQiDmfXYiOEgfvttrkxJG02ii8nfjzCksLZPIW6OqO5PO6EQW(iqhKcPYcvi9qkeyIQiYfvru1hPqQQtQiPQvQIAMQiQCtkKQStkOFsHGAOeezPkskpfjtLcCvfjv(QkIYEj5VOAWeDyjlMqpgXKr5YuTzK6ZQuJgKoTuVgenBOUnP2TOFlmCfCCfPQLRQNdz6kDDqTDfIVtrgpfsX5bH1tHGmFvY(bwnrzGIIvRRmu4tNmDNEIjtZozYPt1PttrTqm4kQHIazD7kQS0UI6KCDKboUHqrnuqGJIPmqrHc4N4kkO7oGmIciWDVqHfTKqlaQ1W4A7ijFrVcGAnrarCikGiDzKmFebg(GUXosaH07tTQzibestn(jRECqGKFsUoYah3qyrTMOOeHB8o1NkrffRwxzOWNoz6o9etMMDYKtfItNMIcn4eLHclecHII5iIIYOaYtY1rg44gcG8KvpoiqcoBuaj0Dhqgrbe4UxOWIwsOfa1AyCTDKKVOxbqTMiGioefqKUmsMpIadFq3yhjGq69Pw1mKacPPg)KvpoiqYpjxhzGJBiSOwtaNnkGKYhwxl6pqozAJdKcF6KPdinsGCYeJ4PNcKgDg9aNbNnkG0iaAL3oYicoBuaPrcKudogdKNCbbsl4SrbKgjqo1HCGueMM2M(c1F(q8BHTWdazNO1lgqg0a576QZoVbsJGtci3w7ajD8aPH(c1FGuif)wyGSiBpIdKdqlKBbNnkG0ibsJWjgcG8DsO1EYaYtY1rkg4fihE3ijHwSwGSPbYEbYgbKDI2kxG0ye0agZaYHpelrmeajABmgiHwpJuO1ml4SrbKgjqkKct(dKu9a0ibYcJdtodihE3ijHwSwGCdGC4dcq2jARCbYtY1rkg41QOg(GUXUIYOaYtY1rg44gcG8KvpoiqcoBuaj0Dhqgrbe4UxOWIwsOfa1AyCTDKKVOxbqTMiGioefqKUmsMpIadFq3yhjGq69Pw1mKacPPg)KvpoiqYpjxhzGJBiSOwtaNnkGKYhwxl6pqozAJdKcF6KPdinsGCYeJ4PNcKgDg9aNbNnkG0iaAL3oYicoBuaPrcKudogdKNCbbsl4SrbKgjqo1HCGueMM2M(c1F(q8BHTWdazNO1lgqg0a576QZoVbsJGtci3w7ajD8aPH(c1FGuif)wyGSiBpIdKdqlKBbNnkG0ibsJWjgcG8DsO1EYaYtY1rkg4fihE3ijHwSwGSPbYEbYgbKDI2kxG0ye0agZaYHpelrmeajABmgiHwpJuO1ml4SrbKgjqkKct(dKu9a0ibYcJdtodihE3ijHwSwGCdGC4dcq2jARCbYtY1rkg41codoBua5jVrJtGxNbKIoD8oqscTyTaPOF3jYcKgDeIpSiGmJ0iHwVMggdKfz7irazKyiSGZfz7ir2H3jHwS2dACHGeCUiBhjYo8oj0I1o2Ha0rWaNlY2rISdVtcTyTJDiqbFR9CRTJeCUiBhjYo8oj0I1o2HaiyTos(GVGZfz7ir2H3jHwS2XoeOZ0FoZ1rIgVPp2c75A7m9NZCDKiRNLi2zGZfz7ir2H3jHwS2XoeaL1acASC0wlcCUiBhjYo8oj0I1o2HadX2rcoxKTJezhENeAXAh7qGHWK)CupanYXB6dryAARPgZ4TEazrBrGuWjGZfz7ir2H3jHwS2XoeG56ifd8oEtFqk0Y3w7hNcodoBua5jVrJtGxNbK(i(dbqUT2bYfQdKfzJhiBeqwJunUeXUfCUiBhj6yi2oYXB6JbFTmxhzt4leFLRTiBpIFDT1F7RDBTZ3GZAFU5NcoxKEJen2HaObhJ54Gaj4Cr2os0yhcaJCEVUgnEtFm4RL56iBcFH4RCTfz7r8RRT(BFTBRD(gCw7ZpMiuW5ISDKOXoeq0FK)q2594n9XGVwMRJSj8fIVY1wKThXVU26V91UT25BWzTp)yIqbNlY2rIg7qarCemon8dX4n9XGVwMRJSj8fIVY1wKThXVU26V91UT25BWzTp)yIqbNlY2rIg7qa6(DrCeSXB6JbFTmxhzt4leFLRTiBpIFDT1F7RDBTZ3GZAF(XeHcoxKTJen2HaSi0J30htzBcKDEpBBTZ3GZAxqZpDgAWXy(w)TViBRhWbQJCUWGZfz7irJDiaZ1r2eoAFpVxOJ30hglcttBn1ygV1dilAlcKZfIRlryAAlZ1r2e(qyYFl8GzxxObhJ5B93(ISTEahOoY5cdoxKTJen2HaKcJ5fz7i54gTJNL2psFH6pFi(TWJ30hBH9CTPVq9Npe)wyRNLi2zZqdogZ36V9fzB9aoqDKZpegCUiBhjASdbifgZlY2rYXnAhplTF06bCG6ihVPpqdogZ36V9fzB9aoqDKcobCUiBhjASdbU)wh97CAhFdxpB8M(GebMfMslcwRJKZCDKnHVq8vU231vNO5tm)6Ak(0d3ddoZoXCHnxiob4Cr2os0yhcGG16i5J0yNU9KnEtF4tpCpm4m7eZf2CH4exxKiWSWuArWADKCMRJSj8fIVY1(UU6ej40o96IebMfMslcwRJKZCDKnHVq8vU231vNO5tegCUiBhjASdbifgZzVxm0wyi9hnEtF4tpCpm4m7eZf2CH4exxgtIaZctPfbR1rYzUoYMWxi(kx776Qt08tmteMM2YCDKnHtkmUZB776QtKzxxgtIaZctPfbR1rYzUoYMWxi(kx776Qt08jtMnfryAAlZ1r2eoPW4oVTVRRorMDDrIaZctPfbR1rYzUoYMWxi(kx776QtKGtMg4Cr2os0yhcGG16i5mxhzt4leFL74n9Hp9W9WGZStmxyZfItCDzSimnTL9EXqBHH0FK9DD1jsqsHw(2AFMXIW00wtnMXB9aYI2IaPGhMFDn8(i8BcZoXcTsgpO53WywLMnZyuaJ5iO1ZMB(1LimnTL9EXqBHH0FK9DD1jA(nHjKf2ovxxIW0027V1r)oN2X3W1ZSVRRorZVjmHSW2PYmZaNlY2rIg7qGHWK)CupanYXB6dryAARPgZ4TEazrBrGuWdHNjcttBzUoYMWjX7w0weiNFi8mryAAlZ1r2e(qyYFllmLZqdogZ36V9fzB9aoqDKZfgCUiBhjASdbyrOhVPp2c75AzrOTEwIyNn7D63rqlrSpBBTZ3GZAxqJzXAzrOTVRRorJz(PMboxKTJen2HaqRKXdA(nmMv54n9bkGXCe06zcEi0RlJrbmMJGwptWdZNrIaZctPLuymN9EXqBHH0FK9DD1jsWPnZ4PSf2Z1IG16i5J0yNU9Kz9SeXo76IebMfMslcwRJKpsJD62tM9DD1jsqZnZmW5ISDKOXoeafWyoA)gsF8M(afWyocA9S5cDMimnTL56iBcNeVBrBrGC(HWGZfz7irJDiaZ1rkg4D8M(afWyocA9S5hMpteMM2YCDKnHtI3TWdZm2yseywykTiyTosoZ1r2e(cXx5AFxxDIMp50RlseywykTiyTosoZ1r2e(cXx5AFxxDIeuyHn76seMM2YCDKnHtI3TOTiqk4H5xxIW00wMRJSjCs8U9DD1jAUqVU2w78n4S2NlSqndCUiBhjASdbifgZlY2rYXnAhplTFic3ygV4iO1ZaNbNlY2rISIWnMXlocA9SdMRJumW74n9rzeY)EDlD8InJ5jhYmmHD2TB9SeXoBMimnTLoEXMX8KdzgMWo72TVxKD2ueHPPTmxhzt4K4D77fzNrIaZctPfbR1rYzUoYMWxi(kx776QtKGcFk4Cr2osKveUXmEXrqRNn2HaOagZr73q6GZfz7irwr4gZ4fhbTE2yhcGGwSWexmWl4m4Cr2osKT1d4a1rE06bCG6ihVPpmweMM2AQXmERhqw0weif8qiMzmkGXCe06zZn)6A49r43eMDILuymN9EXqBHH0F01LimnT1uJz8wpGSOTiqk4XjUUgEFe(nHzNyfBSJib8F7CXql6p66Y4Pm8(i8BcZoXcTsgpO53WywLZMYW7JWVjmRWwOvY4bn)ggZQ0mZMnLH3hHFty2jwOvY4bn)ggZQC2ugEFe(nHzf2cTsgpO53WywLZeHPPTmxhzt4dHj)TSWuA21LXBRD(gCw7ZnFMimnT1uJz8wpGSOTiqk4PMDDz8W7JWVjmRWwsHXC27fdTfgs)rZeHPPTMAmJ36bKfTfbsbfE2u2c75AzUoYMWjfg35T1Zse7mZaNlY2rISTEahOoYXoe4(BD0VZPD8nC9SXB6dseywykTiyTosoZ1r2e(cXx5AFxxDIMpX8RRP4tpCpm4m7eZf2CH4eGZfz7ir2wpGduh5yhcqkmMZEVyOTWq6pA8M(WyseywykTiyTosoZ1r2e(cXx5AFxxDIMFIzIW00wMRJSjCsHXDEBFxxDIm76YyseywykTiyTosoZ1r2e(cXx5AFxxDIMpzYSPicttBzUoYMWjfg35T9DD1jYSRlseywykTiyTosoZ1r2e(cXx5AFxxDIeCY0aNlY2rISTEahOoYXoeabR1rYzUoYMWxi(kxW5ISDKiBRhWbQJCSdbGwjJh08BymRYXB6duaJ5iO1Ze8qOGZfz7ir2wpGduh5yhcaTsgpO53WywLJ30hOagZrqRNj4H5Zm2yJhEFe(nHzf2cTsgpO53WywLxxIW00wtnMXB9aYI2IaPGhMB2mryAARPgZ4TEazrBrGC(jm76IebMfMslcwRJKZCDKnHVq8vU231vNO5h3eMqw4RlryAAlZ1r2e(qyYF776QtKG3eMqwyZaNlY2rISTEahOoYXoeG56ifd8oEtFm8(i8BcZoXcTsgpO53WywLZqbmMJGwptWJjZmweMM2AQXmERhqw0weiNFy(11W7JWVjmR5wOvY4bn)ggZQ0SzOagZrqRNnFAZeHPPTmxhzt4K4Dl8a4Cr2osKT1d4a1ro2HaiyTos(in2PBpzJ30hgtIaZctPfbR1rYzUoYMWxi(kx776QtKGt70zObhJ5B93(ISTEahOoY5hcB21fjcmlmLweSwhjN56iBcFH4RCTVRRorZNim4Cr2osKT1d4a1ro2HaIn2rKa(VDUyOf9hnEtFqIaZctPfbR1rYzUoYMWxi(kx776QtKGNaCUiBhjY26bCG6ih7qauaJ5O9Bi9XB6duaJ5iO1ZMl0zIW00wMRJSjCs8UfTfbY5hcdoxKTJezB9aoqDKJDiaZ1rkg4D8M(afWyocA9S5hMpteMM2YCDKnHtI3TWdZmweMM2YCDKnHtI3TOTiqk4H5xxIW00wMRJSjCs8U9DD1jA(XnHjKfQDQmdCUiBhjY26bCG6ih7qawe6XjqqWoFR)2x0XKX1LrdNabb78T(BFrht14n9X70VJGwIyhCUiBhjY26bCG6ih7qasHX8ISDKCCJ2XZs7hIWnMXlocA9mWzW5ISDKiB6lu)5dXVf(GuymViBhjh3OD8S0(r6lu)5dXVfMlc3ywN3J30hKiWSWuAtFH6pFi(TW231vNO5cFk4Cr2osKn9fQ)8H43cp2HaKcJ5fz7i54gTJNL2psFH6pFi(TW8IS9i(4n9HimnTn9fQ)8H43cBHhaNbNlY2rISPVq9Npe)wyEr2Ee)4(BD0VZPD8nC9SXB6dseywykTiyTosoZ1r2e(cXx5AFxxDIMpX8RRP4tpCpm4m7eZf2CH4eGZfz7ir20xO(ZhIFlmViBpIp2HaiyTos(in2PBpzJ30hKiWSWuArWADKCMRJSj8fIVY1(UU6ej40o96IebMfMslcwRJKZCDKnHVq8vU231vNO5tegCUiBhjYM(c1F(q8BH5fz7r8XoeGuymN9EXqBHH0F04n9HXKiWSWuArWADKCMRJSj8fIVY1(UU6en)eZeHPPTmxhzt4KcJ782(UU6ez21LXKiWSWuArWADKCMRJSj8fIVY1(UU6enFYKztreMM2YCDKnHtkmUZB776QtKzxxKiWSWuArWADKCMRJSj8fIVY1(UU6ej4KPboxKTJeztFH6pFi(TW8IS9i(yhcqkmMxKTJKJB0oEwA)qeUXmEXrqRNnEtFGcymhbTE2XKzgtIaZctPLuymN9EXqBHH0FK9DD1jAEr2oslcAXctCXaVwsHw(2A)6Y4TWEUwXg7isa)3oxm0I(JSEwIyNnJebMfMsRyJDejG)BNlgAr)r231vNO5fz7iTiOflmXfd8AjfA5BRDZmdCUiBhjYM(c1F(q8BH5fz7r8XoeaALmEqZVHXSkhVPpm2yseywykTKcJ5S3lgAlmK(JSVRRorcwKTJ0YCDKIbETKcT8T1UzZmMebMfMslPWyo79IH2cdP)i776QtKGfz7iTiOflmXfd8AjfA5BRDZmBgjcmlmL20xO(ZhIFlS9DD1jsqJNieNowr2osl0kz8GMFdJzvAjfA5BRDZaNlY2rISPVq9Npe)wyEr2EeFSdbqWADKCMRJSj8fIVYD8M(qeMM2M(c1F(q8BHTVRRorZNC6muaJ5iO1ZoofCUiBhjYM(c1F(q8BH5fz7r8XoeabR1rYzUoYMWxi(k3XB6dryAAB6lu)5dXVf2(UU6enViBhPfbR1rYzUoYMWxi(kxlPqlFBTpMqTcfCUiBhjYM(c1F(q8BH5fz7r8XoeG56ifd8oEtFicttBzUoYMWjX7w4bW5ISDKiB6lu)5dXVfMxKThXh7qasHX8ISDKCCJ2XZs7hIWnMXlocA9mWzW5ISDKiB6lu)5dXVfMlc3ywN3hPVq9Npe)w4XB6duaJ5iO1Ze8qOZmEkBH9CTdHj)5OEaAKwplrSZUUeHPPTmxhzt4K4Dl8GzGZfz7ir20xO(ZhIFlmxeUXSoVh7qasHXC27fdTfgs)rGZfz7ir20xO(ZhIFlmxeUXSoVh7qaOvY4bn)ggZQC8M(GebMfMslPWyo79IH2cdP)i776QtKGtMUzOagZrqRNj4H5GZfz7ir20xO(ZhIFlmxeUXSoVh7qGHWK)CupanYXB6dryAARPgZ4TEazrBrGuWdHNjcttBzUoYMWjX7w0weiNFi8mryAAlZ1r2e(qyYFllmLZqbmMJGwptWdZbNlY2rISPVq9Npe)wyUiCJzDEp2HaqRKXdA(nmMv54n9bkGXCe06zcEiuW5ISDKiB6lu)5dXVfMlc3ywN3JDiaPWyEr2osoUr74zP9dr4gZ4fhbTEMIAe)rDKkdf(0jt3Pt3eZTteItnxrzQ(SZBKI6Kz0n1mCQ3qJ(grGeinaQdKTEi(fiPJhinAhENeAXAnAbY3NE4(DgqIcTdKf8g6ADgqsGw5TJSGZNCD6aPqnIa5uxIGhgIFDgqwKTJeinA7m9NZCDKiJwl4m48uVEi(1za5ubKfz7ibsCJwKfCwrHB0IugOOsFH6pFi(TWkdugorzGIYZse7m1OkkY3R)DPOirGzHP0M(c1F(q8BHTVRRora5CGu4tvufz7ivuKcJ5fz7i54gTkkCJwEwAxrL(c1F(q8BH5IWnM15TAvgkSYafLNLi2zQrvuKVx)7srjcttBtFH6pFi(TWw4bfvr2osffPWyEr2osoUrRIc3OLNL2vuPVq9Npe)wyEr2EexTQvrXC6cgVkdugorzGIYZse7m1OkkY3R)DPOg81YCDKnHVq8vU2IS9ioqEDbKB93(A3w78n4S2bY5aP5NQOkY2rQOgITJuTkdfwzGIYZse7m1OkkY3R)DPOg81YCDKnHVq8vU2IS9ioqEDbKB93(A3w78n4S2bY5ha5eHQOkY2rQOGroVxxJuRYqZvgOO8SeXotnQII896FxkQbFTmxhzt4leFLRTiBpIdKxxa5w)TV2T1oFdoRDGC(bqorOkQISDKkkr)r(dzN3Qvz40ugOO8SeXotnQII896FxkQbFTmxhzt4leFLRTiBpIdKxxa5w)TV2T1oFdoRDGC(bqorOkQISDKkkrCemon8dHAvgkuLbkkplrSZuJQOiFV(3LIAWxlZ1r2e(cXx5AlY2J4a51fqU1F7RDBTZ3GZAhiNFaKteQIQiBhPIIUFxehbtTkdfcLbkkplrSZuJQOiFV(3LIAka52ei78giNbKBRD(gCw7aPGaP5NcKZas0GJX8T(BFr2wpGduhjqohifwrvKTJurXIqRwLHtLYafLNLi2zQrvuKVx)7srzmqkcttBn1ygV1dilAlcKa5CGuiaYRlGueMM2YCDKnHpeM83cpaKMbKxxajAWXy(w)TViBRhWbQJeiNdKcROkY2rQOyUoYMWr7759cvTkdNoLbkkplrSZuJQOiFV(3LIAlSNRn9fQ)8H43cB9SeXodiNbKObhJ5B93(ISTEahOosGC(bqkSIQiBhPIIuymViBhjh3OvrHB0YZs7kQ0xO(ZhIFlSAvgEcLbkkplrSZuJQOiFV(3LIcn4ymFR)2xKT1d4a1rcKccKtuufz7ivuKcJ5fz7i54gTkkCJwEwAxr16bCG6ivRYWjNQmqr5zjIDMAuff571)UuuKiWSWuArWADKCMRJSj8fIVY1(UU6ebKZbYjMdKxxa5uasF6H7HbNzn1y63zioQVBmpO5i4b)745iyToYoVvufz7ivu3FRJ(DoTJVHRNPwLHtMOmqr5zjIDMAuff571)Uuu(0d3ddoZAQX0VZqCuF3yEqZrWd(3XZrWADKDEdKxxajjcmlmLweSwhjN56iBcFH4RCTVRRoraPGa50ofiVUasseywykTiyTosoZ1r2e(cXx5AFxxDIaY5a5eHvufz7ivuiyTos(in2PBpzQvz4eHvgOO8SeXotnQII896FxkkF6H7HbNzn1y63zioQVBmpO5i4b)745iyToYoVbYRlG0yGKebMfMslcwRJKZCDKnHVq8vU231vNiGCoqEcGCgqkcttBzUoYMWjfg35T9DD1jcindiVUasJbsseywykTiyTosoZ1r2e(cXx5AFxxDIaY5a5Kja5mGCkaPimnTL56iBcNuyCN3231vNiG0mG86cijrGzHP0IG16i5mxhzt4leFLR9DD1jcifeiNmnfvr2osffPWyo79IH2cdP)i1QmCI5kduuEwIyNPgvrr(E9VlfLp9W9WGZSMAm97meh13nMh0Ce8G)D8CeSwhzN3a51fqAmqkcttBzVxm0wyi9hzFxxDIasbbssHw(2AhiNbKgdKIW00wtnMXB9aYI2Iajqk4bqAoqEDbKdVpc)MWStSqRKXdA(nmMvjqAgqodingirbmMJGwpdiNdKMdKxxaPimnTL9EXqBHH0FK9DD1jciNdK3egqkKbsHTtfqEDbKIW0027V1r)oN2X3W1ZSVRRora5CG8MWasHmqkSDQasZasZuufz7ivuiyTosoZ1r2e(cXx5QwLHtMMYafLNLi2zQrvuKVx)7srjcttBn1ygV1dilAlcKaPGhaPWa5mGueMM2YCDKnHtI3TOTiqcKZpasHbYzaPimnTL56iBcFim5VLfMsGCgqIgCmMV1F7lY26bCG6ibY5aPWkQISDKkQHWK)Cupans1QmCIqvgOO8SeXotnQII896FxkQTWEUwweARNLi2za5mG8D63rqlrSdKZaYT1oFdoRDGuqG0yGKfRLfH2(UU6ebKJbKMFkqAMIQiBhPIIfHwTkdNiekduuEwIyNPgvrr(E9VlffkGXCe06zaPGhaPqbYRlG0yGefWyocA9mGuWdG0CGCgqsIaZctPLuymN9EXqBHH0FK9DD1jcifeiNgqodingiNcqUf2Z1IG16i5J0yNU9Kz9SeXodiVUasseywykTiyTos(in2PBpz231vNiGuqG0CG0mG0mfvr2osff0kz8GMFdJzvQwLHtMkLbkkplrSZuJQOiFV(3LIcfWyocA9mGCoqkuGCgqkcttBzUoYMWjX7w0weibY5haPWkQISDKkkuaJ5O9BiD1QmCY0Pmqr5zjIDMAuff571)UuuOagZrqRNbKZpasZbYzaPimnTL56iBcNeVBHhaYzaPXaPXajjcmlmLweSwhjN56iBcFH4RCTVRRora5CGCYPa51fqsIaZctPfbR1rYzUoYMWxi(kx776QteqkiqkSWaPza51fqkcttBzUoYMWjX7w0weibsbpasZbYRlGueMM2YCDKnHtI3TVRRora5CGuOa51fqUT25BWzTdKZbsHfkqAMIQiBhPII56ifd8QwLHtoHYafLNLi2zQrvufz7ivuKcJ5fz7i54gTkkCJwEwAxrjc3ygV4iO1ZuRAvudVtcTyTkdugorzGIYZse7m1OQvzOWkduuEwIyNPgvTkdnxzGIYZse7m1OQvz40ugOOkY2rQOqWADK8bFvuEwIyNPgvTkdfQYafLNLi2zQrvuKVx)7srTf2Z12z6pN56irwplrSZuufz7ivuDM(ZzUosKAvgkekduuEwIyNPgvTkdNkLbkQISDKkQHy7ivuEwIyNPgvTkdNoLbkkplrSZuJQOiFV(3LIseMM2AQXmERhqw0weibsbbYjkQISDKkQHWK)Cupans1Qm8ekduuEwIyNPgvrr(E9VlffPqlFBTdKha5PkQISDKkkMRJumWRAvRIQ1d4a1rQmqz4eLbkkplrSZuJQOiFV(3LIYyGueMM2AQXmERhqw0weibsbpasHaiNbKgdKOagZrqRNbKZbsZbYRlGC49r43eMDILuymN9EXqBHH0FeqEDbKIW00wtnMXB9aYI2Iajqk4bqEcG86cihEFe(nHzNyfBSJib8F7CXql6pciVUasJbYPaKdVpc)MWStSqRKXdA(nmMvjqodiNcqo8(i8BcZkSfALmEqZVHXSkbsZasZaYza5uaYH3hHFty2jwOvY4bn)ggZQeiNbKtbihEFe(nHzf2cTsgpO53WywLa5mGueMM2YCDKnHpeM83YctjqAgqEDbKgdKBRD(gCw7a5CG0CGCgqkcttBn1ygV1dilAlcKaPGa5PaPza51fqAmqo8(i8BcZkSLuymN9EXqBHH0FeqodifHPPTMAmJ36bKfTfbsGuqGuyGCgqofGClSNRL56iBcNuyCN3wplrSZasZuufz7ivuTEahOos1QmuyLbkkplrSZuJQOiFV(3LIIebMfMslcwRJKZCDKnHVq8vU231vNiGCoqoXCG86ciNcq6tpCpm4mRPgt)odXr9DJ5bnhbp4FhphbR1r25TIQiBhPI6(BD0VZPD8nC9m1Qm0CLbkkplrSZuJQOiFV(3LIYyGKebMfMslcwRJKZCDKnHVq8vU231vNiGCoqEcGCgqkcttBzUoYMWjfg35T9DD1jcindiVUasJbsseywykTiyTosoZ1r2e(cXx5AFxxDIaY5a5Kja5mGCkaPimnTL56iBcNuyCN3231vNiG0mG86cijrGzHP0IG16i5mxhzt4leFLR9DD1jcifeiNmnfvr2osffPWyo79IH2cdP)i1QmCAkduufz7ivuiyTosoZ1r2e(cXx5QO8SeXotnQAvgkuLbkkplrSZuJQOiFV(3LIcfWyocA9mGuWdGuOkQISDKkkOvY4bn)ggZQuTkdfcLbkkplrSZuJQOiFV(3LIcfWyocA9mGuWdG0CGCgqAmqAmqAmqo8(i8BcZkSfALmEqZVHXSkbYRlGueMM2AQXmERhqw0weibsbpasZbsZaYzaPimnT1uJz8wpGSOTiqcKZbYtaKMbKxxajjcmlmLweSwhjN56iBcFH4RCTVRRora58dG8MWasHmqkmqEDbKIW00wMRJSj8HWK)231vNiGuqG8MWasHmqkmqAMIQiBhPIcALmEqZVHXSkvRYWPszGIYZse7m1OkkY3R)DPOgEFe(nHzNyHwjJh08BymRsGCgqIcymhbTEgqk4bqobiNbKgdKIW00wtnMXB9aYI2Iajqo)ainhiVUaYH3hHFtywZTqRKXdA(nmMvjqAgqodirbmMJGwpdiNdKtdiNbKIW00wMRJSjCs8UfEqrvKTJurXCDKIbEvRYWPtzGIYZse7m1OkkY3R)DPOmgijrGzHP0IG16i5mxhzt4leFLR9DD1jcifeiN2Pa5mGen4ymFR)2xKT1d4a1rcKZpasHbsZaYRlGKebMfMslcwRJKZCDKnHVq8vU231vNiGCoqoryfvr2osffcwRJKpsJD62tMAvgEcLbkkplrSZuJQOiFV(3LIIebMfMslcwRJKZCDKnHVq8vU231vNiGuqG8ekQISDKkkXg7isa)3oxm0I(JuRYWjNQmqr5zjIDMAuff571)UuuOagZrqRNbKZbsHcKZasryAAlZ1r2eojE3I2Iajqo)aifwrvKTJurHcymhTFdPRwLHtMOmqr5zjIDMAuff571)UuuOagZrqRNbKZpasZbYzaPimnTL56iBcNeVBHhaYzaPXaPimnTL56iBcNeVBrBrGeif8ainhiVUasryAAlZ1r2eojE3(UU6ebKZpaYBcdifYaPqTtfqAMIQiBhPII56ifd8QwLHtewzGIYZse7m1OkQISDKkkweAffbcc25B93(IugorrPlJgobcc25B93(IuutLII896FxkQ3PFhbTeXUAvgoXCLbkkplrSZuJQOkY2rQOifgZlY2rYXnAvu4gT8S0UIseUXmEXrqRNPw1QOsFH6pFi(TWCr4gZ68wzGYWjkduuEwIyNPgvrr(E9VlffkGXCe06zaPGhaPqbYzaPXa5uaYTWEU2HWK)CupansRNLi2za51fqkcttBzUoYMWjX7w4bG0mfvr2osfv6lu)5dXVfwTkdfwzGIQiBhPIIuymN9EXqBHH0FKIYZse7m1OQvzO5kduuEwIyNPgvrr(E9VlffjcmlmLwsHXC27fdTfgs)r231vNiGuqGCY0bKZasuaJ5iO1ZasbpasZvufz7ivuqRKXdA(nmMvPAvgonLbkkplrSZuJQOiFV(3LIseMM2AQXmERhqw0weibsbpasHbYzaPimnTL56iBcNeVBrBrGeiNFaKcdKZasryAAlZ1r2e(qyYFllmLa5mGefWyocA9mGuWdG0Cfvr2osf1qyYFoQhGgPAvgkuLbkkplrSZuJQOiFV(3LIcfWyocA9mGuWdGuOkQISDKkkOvY4bn)ggZQuTkdfcLbkkplrSZuJQOkY2rQOifgZlY2rYXnAvu4gT8S0UIseUXmEXrqRNPw1QOeHBmJxCe06zkdugorzGIYZse7m1OkkY3R)DPOkJq(3RBPJxSzmp5qMHjSZUDRNLi2za5mGueMM2shVyZyEYHmdtyND723lYcKZaYPaKIW00wMRJSjCs8U99ISa5mGKebMfMslcwRJKZCDKnHVq8vU231vNiGuqGu4tvufz7ivumxhPyGx1QmuyLbkQISDKkkuaJ5O9BiDfLNLi2zQrvRYqZvgOOkY2rQOqqlwyIlg4vr5zjIDMAu1Qwfv6lu)5dXVfMxKThXvgOmCIYafLNLi2zQrvuKVx)7srrIaZctPfbR1rYzUoYMWxi(kx776QteqohiNyoqEDbKtbi9PhUhgCM1uJPFNH4O(UX8GMJGh8VJNJG16i78wrvKTJurD)To6350o(gUEMAvgkSYafLNLi2zQrvuKVx)7srrIaZctPfbR1rYzUoYMWxi(kx776QteqkiqoTtbYRlGKebMfMslcwRJKZCDKnHVq8vU231vNiGCoqoryfvr2osffcwRJKpsJD62tMAvgAUYafLNLi2zQrvuKVx)7srzmqsIaZctPfbR1rYzUoYMWxi(kx776QteqohipbqodifHPPTmxhzt4KcJ782(UU6ebKMbKxxaPXajjcmlmLweSwhjN56iBcFH4RCTVRRora5CGCYeGCgqofGueMM2YCDKnHtkmUZB776QteqAgqEDbKKiWSWuArWADKCMRJSj8fIVY1(UU6ebKccKtMMIQiBhPIIuymN9EXqBHH0FKAvgonLbkkplrSZuJQOiFV(3LIcfWyocA9mG8aiNaKZasJbsseywykTKcJ5S3lgAlmK(JSVRRora5CGSiBhPfbTyHjUyGxlPqlFBTdKxxaPXa5wypxRyJDejG)BNlgAr)rwplrSZaYzajjcmlmLwXg7isa)3oxm0I(JSVRRora5CGSiBhPfbTyHjUyGxlPqlFBTdKMbKMPOkY2rQOifgZlY2rYXnAvu4gT8S0UIseUXmEXrqRNPwLHcvzGIYZse7m1OkkY3R)DPOmgingijrGzHP0skmMZEVyOTWq6pY(UU6ebKccKfz7iTmxhPyGxlPqlFBTdKMbKZasJbsseywykTKcJ5S3lgAlmK(JSVRRoraPGazr2oslcAXctCXaVwsHw(2AhindindiNbKKiWSWuAtFH6pFi(TW231vNiGuqG0yGCIqCkqogqwKTJ0cTsgpO53WywLwsHw(2AhintrvKTJurbTsgpO53WywLQvzOqOmqr5zjIDMAuff571)UuuIW0020xO(ZhIFlS9DD1jciNdKtofiNbKOagZrqRNbKha5PkQISDKkkeSwhjN56iBcFH4RCvRYWPszGIYZse7m1OkkY3R)DPOeHPPTPVq9Npe)wy776QteqohilY2rArWADKCMRJSj8fIVY1sk0Y3w7a5yaPqTcvrvKTJurHG16i5mxhzt4leFLRAvgoDkduuEwIyNPgvrr(E9VlfLimnTL56iBcNeVBHhuufz7ivumxhPyGx1Qm8ekduuEwIyNPgvrvKTJurrkmMxKTJKJB0QOWnA5zPDfLiCJz8IJGwptTQvTkQcEHgVIIQ1gbQvTkfa]] )
end
