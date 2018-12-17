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

        last_summon.name = nil
        last_summon.at = nil
        last_summon.count = nil
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
                summon_demon( "wild_imps", 25, 1 + extra_shards, 1.5 )
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
            
            spend = PTR and 1 or 3,
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
            
            ready = function ()
                if last_summon.name == "wild_imps" and buff.wild_imps.stack - last_summon.count < 2 then
                    return last_summon.at + 1.5 - query_time
                end
                
                return true
            end,
            usable = function () return buff.wild_imps.stack > 1 end,
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

            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( 'felguard', 3600 )
            end,

            copy = "summon_pet"
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


    spec:RegisterPack( "Demonology", 20181216.2321, [[dCuwcbqifk9iKQ0Muu(KcfXOOioffQvPIeVsHywkuDlKQyxu6xqvnmKQ6yksldQ4zuittfPUMIGTPIOVPiKXPisNtruRtHcMNkQ7Pc7dPYbvOqwifPhQIKAIkc1fvrs6JkuK6KQiqRur1mvra7Kc8tfksgQkcTufkQNIKPsbDvvKeFvfbTxs(lHbt0HLSyu1JrmzuUmvBgv(Sk1OvjNwQxdvA2qUnP2TOFlmCfCCfrSCGNdA6kDDOSDfsFNIA8kuOopuL5Ju2VQwnvzOIIvRRmah6pDsNIZ0tAXXiCMs)jvrT4n4kQHIGBD7kQS0UIAIDDKbkUXtrnu4HIIPmurbdmaXvux7oahd4J)DVxy8wsOXh2AmuTDKeqXT4dBnbFEuWJppxrpmFu8habxJCi(NiWhZvZG4FIJzXjSaOGGRyIDDKbkUXZcBnrrXJ1O9emv8kkwTUYaCO)0jDkotpPfhJO)KvuWbNOmaNtEsf1vZyEQ4vumhsuu07lNyxhzGIB8E5jSaOGG7pNEF51UdWXa(4F37fgVLeA8HTgdvBhjbuCl(WwtWNhf84ZZv0dZhf)bqW1ihI)jc8XC1mi(N4ywCclaki4kMyxhzGIB8SWwt(507lNyN4AEh8YPNC8xId9NoPVKEEjogngO)K)5)C69LN6RkVD4y4NtVVKEEj1GJqV8eii4A)507lPNxEQa9xYJXXztFVCGyiaBHSydVSt46f7Lb3lbUU6SZ7xEQN4xUT2FjxaEPb(E5GxEIbyl0llY2J6VC4QGU9NtVVKEE5yQeH3lboj0ApzVCIDDK8bAF5aWPhsO5R9Ln3l79Ln8LDc3k3xAc8kWqSxoac(IhH3lHBJqV8QamsbxJT)C69L0ZlpXWSdEjvpCf5llekm7SxoaC6HeA(AF5gVCaeKx2jCRCF5e76i5d0A)507lPNxogXyV00g5qsGbU9xAAO5Da8LB8Y9YFPb(E5GxEIbyl0llY2J6V0CNSWSvrnacUg5kk69LtSRJmqXnEV8ewauqW9NtVV8A3b4yaF8V79cJ3scn(WwJHQTJKakUfFyRj4ZJcE855k6H5JI)ai4AKdX)eb(yUAge)tCmloHfafeCftSRJmqXnEwyRj)C69LtStCnVdE50to(lXH(tN0xspVehJgd0FY)8Fo9(Yt9vL3oCm8ZP3xspVKAWrOxEceeCT)C69L0ZlpvG(l5X44SPVxoqmeGTqwSHx2jC9I9YG7LaxxD259lp1t8l3w7VKlaV0aFVCWlpXaSf6Lfz7r9xoCvq3(ZP3xspVCmvIW7LaNeATNSxoXUos(aTVCa40dj081(YM7L9(Yg(YoHBL7lnbEfyi2lhabFXJW7LWTrOxEvagPGRX2Fo9(s65LNyy2bVKQhUI8LfcfMD2lhao9qcnFTVCJxoacYl7eUvUVCIDDK8bAT)C69L0ZlhJySxAAJCijWa3(lnn08oa(YnE5E5V0aFVCWlpXaSf6Lfz7r9xAUtwy2(Z)507lpvhJDc26SxY7CbWFjj081(sE)UtO9LJreIpSWxMrspxfqZHHEzr2os4lJeHN9NxKTJeAhaoj081EWHkiU)8ISDKq7aWjHMV2roWNlc2pViBhj0oaCsO5RDKd8lSBTNBTDK)8ISDKq7aWjHMV2roWhIP1rkg89NxKTJeAhaoj081oYb(DMoqWCDKWXBUJTqEU2othiyUosO1ZIh5SFEr2osODa4KqZx7ih4peMDGa2dxroEZDWJXXzn3iMO1dqlClcU0n9NxKTJeAhaoj081oYb(dX2r(ZlY2rcTdaNeA(Ah5aFMRJKpq74n3bFaH0OvKTJ0YCDK8bATKcUIT1(b9)5)C69LNQJXobBD2l9rDaEVCBT)Y9YFzr2a8Yg(YA0QrfpYT)8ISDKWd4GJqcuqW9NxKTJeoYb(dX2roEZDm4RL56iBIyXdu5AlY2J6)8ISDKWroWhd6IEDnC8M7yWxlZ1r2eXIhOY1wKTh1)5fz7iHJCGpVdGoa3oVhV5og81YCDKnrS4bQCTfz7r9FEr2os4ih4ZJIGj4Wa4nEZDm4RL56iBIyXdu5AlY2J6)8ISDKWroWNRbopkc24n3XGVwMRJSjIfpqLRTiBpQ)ZlY2rch5aFwe6XBUJXUnb3oVNTf42x72AxSHG1oDgr)zWbhHeBbU9fAB9akGDKNX5NxKTJeoYb(mxhzteWf459EnEZDycpghN1CJyIwpaTWTi4E(K0OXJXXzzUoYMigcZoWInymnAWbhHeBbU9fAB9akGDKNX5NxKTJeoYb(KcHefz7ifOgUJNL2psFVCGyiaBHgV5o2c55AtFVCGyiaBHSEw8iNndo4iKylWTVqBRhqbSJ88bo)8ISDKWroWNuiKOiBhPa1WD8S0(rRhqbSJC8M7ao4iKylWTVqBRhqbSJKUP)8ISDKWroW)g06ObUGZr3yfGnEZDqIaXcZPfIP1rkyUoYMiw8avUwGRRoHNNAenAJ1NeSEyWz2PgHJrNCY)8ISDKWroWhIP1rkgTrox7jB8M7WNeSEyWz2PgHJrNCY0OrIaXcZPfIP1rkyUoYMiw8avUwGRRoH0DA6tJgjcelmNwiMwhPG56iBIyXdu5AbUU6eEEko)8ISDKWroWNuiKGb8Ib3cHRdGJ3Ch(KG1ddoZo1iCm6KtMgntirGyH50cX06ifmxhztelEGkxlW1vNWZtEgpghNL56iBIGuiuN3wGRRoHgtJMjKiqSWCAHyADKcMRJSjIfpqLRf46Qt45PtNnwEmoolZ1r2ebPqOoVTaxxDcnMgnseiwyoTqmTosbZ1r2eXIhOY1cCD1jKUPN(NxKTJeoYb(qmTosbZ1r2eXIhOYD8M7WNeSEyWz2PgHJrNCY0OzcpghNLb8Ib3cHRdGwGRRoH0rk4k2w7ZmHhJJZAUrmrRhGw4weCP7WOr2c55A7mDGG56iHwplEKZgzlKNRL56iBIGejetpSDKwplEKZofJOrBa4JkUjm7u7vLmrWjUXqSkNzYy3c55AzUoYMiircX0dBhP1ZIh5mA04X44SMBet06bOfUfbx6omAKTqEU2othiyUosO1ZIh5mJnEMjWadjGxfGD2iA04X44SmGxm4wiCDa0cCD1j88nHDk4yNiA04X44S3GwhnWfCo6gRamlW1vNWZ3e2PGJDIm24FEr2os4ih4peMDGa2dxroEZDWJXXzn3iMO1dqlClcU0DGZmEmoolZ1r2ebjaUfUfb3Zh4mJhJJZYCDKnrmeMDGLfMZzWbhHeBbU9fAB9akGDKNX5NxKTJeoYb(Si0J3ChBH8CTSi0wplEKZMbCoGdVkEKpBlWTV2T1UydbRD6mHfRLfH2cCD1jCeJOVX)8ISDKWroW)QsMi4e3yiwLJ3ChWadjGxfGr3XeOrZeyGHeWRcWO7WOzKiqSWCAjfcjyaVyWTq46aOf46QtiDNEMjJDlKNRfIP1rkgTrox7jZ6zXJCgnAKiqSWCAHyADKIrBKZ1EYSaxxDcPZiJn(NxKTJeoYb(WadjGlOX1hV5oGbgsaVka78eMXJXXzzUoYMiibWTWTi4E(aNFEr2os4ih4ZCDK8bAhV5oGbgsaVka78HrZ4X44SmxhzteKa4wSHzMycjcelmNwiMwhPG56iBIyXdu5AbUU6eEEk9PrJebIfMtletRJuWCDKnrS4bQCTaxxDcPdhCmMgnEmoolZ1r2ebjaUfUfbx6omIgnEmoolZ1r2ebjaUf46Qt45jqJ22AxSHG1(zCMGX)8ISDKWroWNVroKeyGBxWhAEha)5fz7iHJCGpPqirr2osbQH74zP9dESgXeLaEva2p)NxKTJeA5XAetuc4vbyhWadjGlOX1)5fz7iHwESgXeLaEva2ih4dVkwywWhO9N)ZlY2rcTTEafWoYJwpGcyh54n3Hj8yCCwZnIjA9a0c3IGlDhNCMjWadjGxfGD2iA0ga(OIBcZo1skesWaEXGBHW1bqA04X44SMBet06bOfUfbx6oMmnAdaFuXnHzNA5BKdjbg42f8HM3bqA0mzSdaFuXnHzNAVQKjcoXngIv5SXoa8rf3eMfh7vLmrWjUXqSkn24zJDa4JkUjm7u7vLmrWjUXqSkNn2bGpQ4MWS4yVQKjcoXngIv5mEmoolZ1r2eXqy2bwwyonMgnt2w7IneS2pB0mEmooR5gXeTEaAHBrWLo6BmnAMma8rf3eMfhlPqibd4fdUfcxhaNXJXXzn3iMO1dqlClcU0HZSXUfYZ1YCDKnrqkeQZBRNfpYzg)ZlY2rcTTEafWoYroW)g06ObUGZr3yfGnEZDqIaXcZPfIP1rkyUoYMiw8avUwGRRoHNNAenAJ1NeSEyWz2PgHJrNCY)8ISDKqBRhqbSJCKd8jfcjyaVyWTq46a44n3HjKiqSWCAHyADKcMRJSjIfpqLRf46Qt45jpJhJJZYCDKnrqkeQZBlW1vNqJPrZeseiwyoTqmTosbZ1r2eXIhOY1cCD1j880PZglpghNL56iBIGuiuN3wGRRoHgtJgjcelmNwiMwhPG56iBIyXdu5AbUU6es30t)ZlY2rcTTEafWoYroWhIP1rkyUoYMiw8avU)8ISDKqBRhqbSJCKd8VQKjcoXngIv54n3bmWqc4vby0DmHFEr2osOT1dOa2roYb(xvYebN4gdXQC8M7agyib8Qam6omAMjMyYaWhvCtywCSxvYebN4gdXQKgnEmooR5gXeTEaAHBrWLUdJmEgpghN1CJyIwpaTWTi4EEYgtJgjcelmNwiMwhPG56iBIyXdu5AbUU6eE(4MWofCOrJhJJZYCDKnrmeMDGf46QtiD3e2PGJX)8ISDKqBRhqbSJCKd8zUos(aTJ3ChdaFuXnHzNAVQKjcoXngIv5myGHeWRcWO7y6mt4X44SMBet06bOfUfb3ZhgrJ2aWhvCtywJSxvYebN4gdXQ04zWadjGxfGD(0Z4X44SmxhzteKa4wSHFEr2osOT1dOa2roYb(qmTosXOnY5ApzJ3ChMqIaXcZPfIP1rkyUoYMiw8avUwGRRoH0DA6pdo4iKylWTVqBRhqbSJ88bogtJgjcelmNwiMwhPG56iBIyXdu5AbUU6eEEko)8ISDKqBRhqbSJCKd85BKdjbg42f8HM3bWXBUdseiwyoTqmTosbZ1r2eXIhOY1cCD1jKUj)ZlY2rcTTEafWoYroWhgyibCbnU(4n3bmWqc4vbyNNWmEmoolZ1r2ebjaUfUfb3Zh48ZlY2rcTTEafWoYroWN56i5d0oEZDadmKaEva25dJMXJXXzzUoYMiibWTydZmHhJJZYCDKnrqcGBHBrWLUdJOrJhJJZYCDKnrqcGBbUU6eE(4MWoLjyNiJ)5fz7iH2wpGcyh5ih4ZIqpobpcYfBbU9fEmDCDngli4rqUylWTVWJjA8M7a4CahEv8i)NxKTJeAB9akGDKJCGpPqirr2osbQH74zP9dESgXeLaEva2p)NxKTJeAtFVCGyiaBHoifcjkY2rkqnChplTFK(E5aXqa2cj4XAeRZ7XBUdseiwyoTPVxoqmeGTqwGRRoHNXH()8ISDKqB67Ldedbyl0ih4tkesuKTJuGA4oEwA)i99YbIHaSfsuKTh1hV5o4X44SPVxoqmeGTqwSHF(pViBhj0M(E5aXqa2cjkY2J6h3GwhnWfCo6gRaSXBUdseiwyoTqmTosbZ1r2eXIhOY1cCD1j88uJOrBS(KG1ddoZo1iCm6Kt(NxKTJeAtFVCGyiaBHefz7r9roWhIP1rkgTrox7jB8M7GebIfMtletRJuWCDKnrS4bQCTaxxDcP700NgnseiwyoTqmTosbZ1r2eXIhOY1cCD1j88uC(5fz7iH203lhigcWwirr2EuFKd8jfcjyaVyWTq46a44n3HjKiqSWCAHyADKcMRJSjIfpqLRf46Qt45jpJhJJZYCDKnrqkeQZBlW1vNqJPrZeseiwyoTqmTosbZ1r2eXIhOY1cCD1j880PZglpghNL56iBIGuiuN3wGRRoHgtJgjcelmNwiMwhPG56iBIyXdu5AbUU6es30t)ZlY2rcTPVxoqmeGTqIIS9O(ih4Z3ihscmWTl4dnVdG)8ISDKqB67LdedbylKOiBpQpYb(KcHefz7ifOgUJNL2p4XAetuc4vbyJ3ChWadjGxfGDmDMjKiqSWCAjfcjyaVyWTq46aOf46Qt45ISDKw4vXcZc(aTwsbxX2ANgnt2c55A5BKdjbg42f8HM3bqRNfpYzZirGyH50Y3ihscmWTl4dnVdGwGRRoHNlY2rAHxflml4d0AjfCfBRDJn(NxKTJeAtFVCGyiaBHefz7r9roW)QsMi4e3yiwLJ3ChMycjcelmNwsHqcgWlgCleUoaAbUU6esxr2oslZ1rYhO1sk4k2w7gpZeseiwyoTKcHemGxm4wiCDa0cCD1jKUISDKw4vXcZc(aTwsbxX2A3yJNXJXXztFVCGyiaBHSaxxDcPRiBhP9QsMi4e3yiwLwsbxX2A)NxKTJeAtFVCGyiaBHefz7r9roWhIP1rkyUoYMiw8avUJ3Ch8yCC203lhigcWwilW1vNWZtP)myGHeWRcWoO)pViBhj0M(E5aXqa2cjkY2J6JCGpetRJuWCDKnrS4bQChV5o4X44SPVxoqmeGTqwGRRoHNlY2rAHyADKcMRJSjIfpqLRLuWvST2hzc2j8ZlY2rcTPVxoqmeGTqIIS9O(ih4ZCDK8bAhV5o4X44SmxhzteKa4wSHFEr2osOn99YbIHaSfsuKTh1h5aFsHqIISDKcud3XZs7h8ynIjkb8QaSF(pViBhj0M(E5aXqa2cj4XAeRZ7J03lhigcWwOXBUdyGHeWRcWO7ycZmzSBH8CTdHzhiG9WvKwplEKZOrJhJJZYCDKnrqcGBXgm(NxKTJeAtFVCGyiaBHe8ynI159ih4tkesWaEXGBHW1bWFEr2osOn99YbIHaSfsWJ1iwN3JCG)vLmrWjUXqSkhV5oirGyH50skesWaEXGBHW1bqlW1vNq6MoPZGbgsaVkaJUdJ(5fz7iH203lhigcWwibpwJyDEpYb(dHzhiG9WvKJ3Ch8yCCwZnIjA9a0c3IGlDh4mJhJJZYCDKnrqcGBHBrW98boZ4X44SmxhztedHzhyzH5CgmWqc4vby0Dy0pViBhj0M(E5aXqa2cj4XAeRZ7roW)QsMi4e3yiwLJ3ChWadjGxfGr3Xe(5fz7iH203lhigcWwibpwJyDEpYb(KcHefz7ifOgUJNL2p4XAetuc4vbykQrDaSJuzao0F6KofNPN0IJr0FYkkZfi78gQOoHJrJzdobnym9y4LV0Wl)LTEia7l5cWlhtgaoj081oM8sGpjynWzVegA)Lf2g6AD2ljxvE7q7p)eOt)Ltym8YtLeInmeG1zVSiBh5lht6mDGG56iHJj2F(p)eupeG1zVCIEzr2oYxIA4cT)CfvHTxbqrr16tTIc1WfQmurL(E5aXqa2cjkY2J6kdvgmvzOIYZIh5mLPkkcOxh0LIIebIfMtletRJuWCDKnrS4bQCTaxxDcF55xo1OxsJ2lh7l9jbRhgCM1CJ4aodkG9DJebNaIn4GoaciMwhzN3kQISDKkQBqRJg4cohDJvaMAvgGJYqfLNfpYzktvueqVoOlffjcelmNwiMwhPG56iBIyXdu5AbUU6e(s6E5PP)lPr7LKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lp)YP4OOkY2rQOGyADKIrBKZ1EYuRYaJugQO8S4rotzQIIa61bDPOm5LKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lp)Yj)YzVKhJJZYCDKnrqkeQZBlW1vNWxA8lPr7LM8sseiwyoTqmTosbZ1r2eXIhOY1cCD1j8LNF50PVC2lh7l5X44SmxhzteKcH682cCD1j8Lg)sA0EjjcelmNwiMwhPG56iBIyXdu5AbUU6e(s6E50tROkY2rQOifcjyaVyWTq46aOAvgCALHkQISDKkk(g5qsGbUDbFO5Daur5zXJCMYu1QmyckdvuEw8iNPmvrra96GUuuWadjGxfG9YJxo9LZEPjVKebIfMtlPqibd4fdUfcxhaTaxxDcF55xwKTJ0cVkwywWhO1sk4k2w7VKgTxAYl3c55A5BKdjbg42f8HM3bqRNfpYzVC2ljrGyH50Y3ihscmWTl4dnVdGwGRRoHV88llY2rAHxflml4d0AjfCfBR9xA8lnwrvKTJurrkesuKTJuGA4QOqnCfzPDffpwJyIsaVkatTkdoPYqfLNfpYzktvueqVoOlfLjV0KxsIaXcZPLuiKGb8Ib3cHRdGwGRRoHVKUxwKTJ0YCDK8bATKcUIT1(ln(LZEPjVKebIfMtlPqibd4fdUfcxhaTaxxDcFjDVSiBhPfEvSWSGpqRLuWvST2FPXV04xo7L8yCC203lhigcWwilW1vNWxs3llY2rAVQKjcoXngIvPLuWvST2vufz7ivuxvYebN4gdXQuTkdMiLHkkplEKZuMQOiGEDqxkkEmooB67LdedbylKf46Qt4lp)YP0)LZEjmWqc4vbyV84L0xrvKTJurbX06ifmxhztelEGkx1QmysvgQO8S4rotzQIIa61bDPO4X44SPVxoqmeGTqwGRRoHV88llY2rAHyADKcMRJSjIfpqLRLuWvST2F5iVCc2jOOkY2rQOGyADKcMRJSjIfpqLRAvgmzLHkkplEKZuMQOiGEDqxkkEmoolZ1r2ebjaUfBqrvKTJurXCDK8bAvRYGP0xzOIYZIh5mLPkQISDKkksHqIISDKcudxffQHRilTRO4XAetuc4vbyQvTkkMZvyOvzOYGPkdvufz7ivuWbhHeOGGRIYZIh5mLPQvzaokdvuEw8iNPmvrra96GUuud(AzUoYMiw8avU2IS9OUIQiBhPIAi2os1QmWiLHkkplEKZuMQOiGEDqxkQbFTmxhztelEGkxBr2EuxrvKTJurHbDrVUgQwLbNwzOIYZIh5mLPkkcOxh0LIAWxlZ1r2eXIhOY1wKTh1vufz7ivu8oa6aC78wTkdMGYqfLNfpYzktvueqVoOlf1GVwMRJSjIfpqLRTiBpQROkY2rQO4rrWeCya8uRYGtQmur5zXJCMYuffb0Rd6srn4RL56iBIyXdu5AlY2J6kQISDKkkUg48OiyQvzWePmur5zXJCMYuffb0Rd6srn2xUnb3oVF5SxUf42x72AxSHG1(lP7Lgr)xo7LWbhHeBbU9fAB9akGDKV88lXrrvKTJurXIqRwLbtQYqfLNfpYzktvueqVoOlfLjVKhJJZAUrmrRhGw4weCF55xEYxsJ2l5X44SmxhztedHzhyXgEPXVKgTxchCesSf42xOT1dOa2r(YZVehfvr2osffZ1r2ebCbEEVxQvzWKvgQO8S4rotzQIIa61bDPO2c55AtFVCGyiaBHSEw8iN9YzVeo4iKylWTVqBRhqbSJ8LNpEjokQISDKkksHqIISDKcudxffQHRilTROsFVCGyiaBHuRYGP0xzOIYZIh5mLPkkcOxh0LIco4iKylWTVqBRhqbSJ8L09YPkQISDKkksHqIISDKcudxffQHRilTROA9akGDKQvzW0PkdvuEw8iNPmvrra96GUuuKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lp)YPg9sA0E5yFPpjy9WGZSMBehWzqbSVBKi4eqSbh0bqaX06i78wrvKTJurDdAD0axW5OBScWuRYGP4Omur5zXJCMYuffb0Rd6sr5tcwpm4mR5gXbCgua77gjcobeBWbDaeqmToYoVFjnAVKebIfMtletRJuWCDKnrS4bQCTaxxDcFjDV800)L0O9sseiwyoTqmTosbZ1r2eXIhOY1cCD1j8LNF5uCuufz7ivuqmTosXOnY5ApzQvzWuJugQO8S4rotzQIIa61bDPO8jbRhgCM1CJ4aodkG9DJebNaIn4GoaciMwhzN3VKgTxAYljrGyH50cX06ifmxhztelEGkxlW1vNWxE(Lt(LZEjpghNL56iBIGuiuN3wGRRoHV04xsJ2ln5LKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lp)YPtF5Sxo2xYJXXzzUoYMiifc15Tf46Qt4ln(L0O9sseiwyoTqmTosbZ1r2eXIhOY1cCD1j8L09YPNwrvKTJurrkesWaEXGBHW1bq1Qmy6PvgQO8S4rotzQIIa61bDPO8jbRhgCM1CJ4aodkG9DJebNaIn4GoaciMwhzN3VKgTxAYl5X44SmGxm4wiCDa0cCD1j8L09ssbxX2A)LZEPjVKhJJZAUrmrRhGw4weCFjDhV0OxoYl3c55A7mDGG56iHwplEKZE5iVClKNRL56iBIGejetpSDKwplEKZE5P8sJEjnAVCa4JkUjm7u7vLmrWjUXqSkF5SxAYlh7l3c55AzUoYMiircX0dBhP1ZIh5SxsJ2l5X44SMBet06bOfUfb3xs3Xln6LJ8YTqEU2othiyUosO1ZIh5SxA8ln(LZEPjVegyib8QaSxE(Lg9sA0EjpghNLb8Ib3cHRdGwGRRoHV88lVjSxEkVeh7e9sA0EjpghN9g06ObUGZr3yfGzbUU6e(YZV8MWE5P8sCSt0ln(LgROkY2rQOGyADKcMRJSjIfpqLRAvgmDckdvuEw8iNPmvrra96GUuu8yCCwZnIjA9a0c3IG7lP74L48YzVKhJJZYCDKnrqcGBHBrW9LNpEjoVC2l5X44SmxhztedHzhyzH58LZEjCWriXwGBFH2wpGcyh5lp)sCuufz7ivudHzhiG9WvKQvzW0tQmur5zXJCMYuffb0Rd6srTfYZ1YIqB9S4ro7LZEjW5ao8Q4r(lN9YTa3(A3w7IneS2FjDV0KxYI1YIqBbUU6e(YrEPr0)LgROkY2rQOyrOvRYGPtKYqfLNfpYzktvueqVoOlffmWqc4vbyVKUJxoHxsJ2ln5LWadjGxfG9s6oEPrVC2ljrGyH50skesWaEXGBHW1bqlW1vNWxs3lp9lN9stE5yF5wipxletRJumAJCU2tM1ZIh5SxsJ2ljrGyH50cX06ifJ2iNR9KzbUU6e(s6EPrV04xASIQiBhPI6QsMi4e3yiwLQvzW0jvzOIYZIh5mLPkkcOxh0LIcgyib8QaSxE(Lt4LZEjpghNL56iBIGea3c3IG7lpF8sCuufz7ivuWadjGlOX1vRYGPtwzOIYZIh5mLPkkcOxh0LIcgyib8QaSxE(4Lg9YzVKhJJZYCDKnrqcGBXgE5SxAYln5LKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lp)YP0)L0O9sseiwyoTqmTosbZ1r2eXIhOY1cCD1j8L09sCW5Lg)sA0EjpghNL56iBIGea3c3IG7lP74Lg9sA0EjpghNL56iBIGea3cCD1j8LNF5eEjnAVCBTl2qWA)LNFjot4LgROkY2rQOyUos(aTQvzao0xzOIQiBhPIIVroKeyGBxWhAEhavuEw8iNPmvTkdWzQYqfLNfpYzktvufz7ivuKcHefz7ifOgUkkudxrwAxrXJ1iMOeWRcWuRAvudaNeA(AvgQmyQYqfLNfpYzktvRYaCugQO8S4rotzQAvgyKYqfLNfpYzktvRYGtRmurvKTJurbX06ifCo6gRamfLNfpYzktvRYGjOmur5zXJCMYuffb0Rd6srTfYZ12z6abZ1rcTEw8iNPOkY2rQO6mDGG56iHQvzWjvgQO8S4rotzQIIa61bDPO4X44SMBet06bOfUfb3xs3lNQOkY2rQOgcZoqa7HRivRYGjszOIQiBhPIAi2osfLNfpYzktvRYGjvzOIYZIh5mLPkkcOxh0LIIpGWxsJ2llY2rAzUos(aTwsbxX2A)LhVK(kQISDKkkMRJKpqRAvRIk99YbIHaSfszOYGPkdvuEw8iNPmvrra96GUuuKiqSWCAtFVCGyiaBHSaxxDcF55xId9vufz7ivuKcHefz7ifOgUkkudxrwAxrL(E5aXqa2cj4XAeRZB1QmahLHkkplEKZuMQOiGEDqxkkEmooB67LdedbylKfBqrvKTJurrkesuKTJuGA4QOqnCfzPDfv67LdedbylKOiBpQRw1QOsFVCGyiaBHe8ynI15TYqLbtvgQO8S4rotzQIIa61bDPOGbgsaVka7L0D8Yj8YzV0Kxo2xUfYZ1oeMDGa2dxrA9S4ro7L0O9sEmoolZ1r2ebjaUfB4LgROkY2rQOsFVCGyiaBHuRYaCugQOkY2rQOifcjyaVyWTq46aOIYZIh5mLPQvzGrkdvuEw8iNPmvrra96GUuuKiqSWCAjfcjyaVyWTq46aOf46Qt4lP7LtN0xo7LWadjGxfG9s6oEPrkQISDKkQRkzIGtCJHyvQwLbNwzOIYZIh5mLPkkcOxh0LIIhJJZAUrmrRhGw4weCFjDhVeNxo7L8yCCwMRJSjcsaClClcUV88XlX5LZEjpghNL56iBIyim7allmNVC2lHbgsaVka7L0D8sJuufz7ivudHzhiG9WvKQvzWeugQO8S4rotzQIIa61bDPOGbgsaVka7L0D8YjOOkY2rQOUQKjcoXngIvPAvgCsLHkkplEKZuMQOkY2rQOifcjkY2rkqnCvuOgUIS0UIIhRrmrjGxfGPw1QO4XAetuc4vbykdvgmvzOIQiBhPIcgyibCbnUUIYZIh5mLPQvzaokdvufz7ivuWRIfMf8bAvuEw8iNPmvTQvr16bua7ivgQmyQYqfLNfpYzktvueqVoOlfLjVKhJJZAUrmrRhGw4weCFjDhV8KVC2ln5LWadjGxfG9YZV0OxsJ2lha(OIBcZo1skesWaEXGBHW1bWxsJ2l5X44SMBet06bOfUfb3xs3XlN8lPr7LdaFuXnHzNA5BKdjbg42f8HM3bWxsJ2ln5LJ9LdaFuXnHzNAVQKjcoXngIv5lN9YX(YbGpQ4MWS4yVQKjcoXngIv5ln(Lg)YzVCSVCa4JkUjm7u7vLmrWjUXqSkF5Sxo2xoa8rf3eMfh7vLmrWjUXqSkF5SxYJXXzzUoYMigcZoWYcZ5ln(L0O9stE52AxSHG1(lp)sJE5SxYJXXzn3iMO1dqlClcUVKUxs)xA8lPr7LM8YbGpQ4MWS4yjfcjyaVyWTq46a4lN9sEmooR5gXeTEaAHBrW9L09sCE5Sxo2xUfYZ1YCDKnrqkeQZBRNfpYzV0yfvr2osfvRhqbSJuTkdWrzOIYZIh5mLPkkcOxh0LIIebIfMtletRJuWCDKnrS4bQCTaxxDcF55xo1OxsJ2lh7l9jbRhgCM1CJ4aodkG9DJebNaIn4GoaciMwhzN3kQISDKkQBqRJg4cohDJvaMAvgyKYqfLNfpYzktvueqVoOlfLjVKebIfMtletRJuWCDKnrS4bQCTaxxDcF55xo5xo7L8yCCwMRJSjcsHqDEBbUU6e(sJFjnAV0KxsIaXcZPfIP1rkyUoYMiw8avUwGRRoHV88lNo9LZE5yFjpghNL56iBIGuiuN3wGRRoHV04xsJ2ljrGyH50cX06ifmxhztelEGkxlW1vNWxs3lNEAfvr2osffPqibd4fdUfcxhavRYGtRmurvKTJurbX06ifmxhztelEGkxfLNfpYzktvRYGjOmur5zXJCMYuffb0Rd6srbdmKaEva2lP74LtqrvKTJurDvjteCIBmeRs1Qm4KkdvuEw8iNPmvrra96GUuuWadjGxfG9s6oEPrVC2ln5LM8stE5aWhvCtywCSxvYebN4gdXQ8L0O9sEmooR5gXeTEaAHBrW9L0D8sJEPXVC2l5X44SMBet06bOfUfb3xE(Lt(Lg)sA0EjjcelmNwiMwhPG56iBIyXdu5AbUU6e(YZhV8MWE5P8sCEjnAVKhJJZYCDKnrmeMDGf46Qt4lP7L3e2lpLxIZlnwrvKTJurDvjteCIBmeRs1QmyIugQO8S4rotzQIIa61bDPOga(OIBcZo1EvjteCIBmeRYxo7LWadjGxfG9s6oE50xo7LM8sEmooR5gXeTEaAHBrW9LNpEPrVKgTxoa8rf3eM1i7vLmrWjUXqSkFPXVC2lHbgsaVka7LNF5PF5SxYJXXzzUoYMiibWTydkQISDKkkMRJKpqRAvgmPkdvuEw8iNPmvrra96GUuuM8sseiwyoTqmTosbZ1r2eXIhOY1cCD1j8L09Ytt)xo7LWbhHeBbU9fAB9akGDKV88XlX5Lg)sA0EjjcelmNwiMwhPG56iBIyXdu5AbUU6e(YZVCkokQISDKkkiMwhPy0g5CTNm1QmyYkdvuEw8iNPmvrra96GUuuKiqSWCAHyADKcMRJSjIfpqLRf46Qt4lP7LtwrvKTJurX3ihscmWTl4dnVdGQvzWu6Rmur5zXJCMYuffb0Rd6srbdmKaEva2lp)Yj8YzVKhJJZYCDKnrqcGBHBrW9LNpEjokQISDKkkyGHeWf046QvzW0PkdvuEw8iNPmvrra96GUuuWadjGxfG9YZhV0Oxo7L8yCCwMRJSjcsaCl2WlN9stEjpghNL56iBIGea3c3IG7lP74Lg9sA0EjpghNL56iBIGea3cCD1j8LNpE5nH9Yt5LtWorV0yfvr2osffZ1rYhOvTkdMIJYqfLNfpYzktvufz7ivuSi0kkcEeKl2cC7luzWufLUgJfe8iixSf42xOIAIuueqVoOlffW5ao8Q4rUAvgm1iLHkkplEKZuMQOkY2rQOifcjkY2rkqnCvuOgUIS0UIIhRrmrjGxfGPw1Qw1QwLca]] )

    
end
