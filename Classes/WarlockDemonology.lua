-- WarlockDemonology.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
                if azerite.baleful_invocation.enabled then gain( 5, "soul_shards" ) end
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


    spec:RegisterPack( "Demonology", 20181210.2242, [[dC09dbqifHEKceBsr6tkqkJIcCkcQvPaLxPqmlfQUffuTlk9lcYWuPQJPOSmfvpJczAkI6Akc2gfK(gfugNIioNkvADkqY8urUNkSpc0bvPcXcvO8qkiYevePlsbr1hvPcPtQsfPvQIAMQuHANkGFsbrzOuqyPQubpfrtLc1vvPI4RQurTxs(lQgmrhwYIj0JrAYOCzQ2mcFwLmAi1PL61QuMnu3Mu7w0VfgofDCfOA5aph00v66qSDfsFxbnEfivNNaMpKSFvTAMYyfjRwxnW87NnjZMp7E785tE(SjRixbmDfPzrVvxUImlTRiNuxhzGJlbuKMLa4OykJvKWabqDfj6DnHdkHe6Qx0iIwAOfc2AeCTDKuqrScbBnvirCikKirz4mFuHmbbrJDOqgcGFhQMbfYqCh435cGd6n(K66idCCjGf2AQIuePX7DAQevKSAD1aZVF2KmB(S7TZNp553pjksOPtvdm3qnufj6MX8ujQizoKQihKxoPUoYahxc8Y7CbWb92FEqEj6DnHdkHe6Qx0iIwAOfc2AeCTDKuqrScbBnvirCikKirz4mFuHmbbrJDOqgcGFhQMbfYqCh435cGd6n(K66idCCjGf2A6FEqE5K6uxl6Gxo7(XF587NnjV0WF585dkJM8F(ppiV0qcDLxoCq9NhKxA4VK00X4xEhh0B2)8G8sd)L3jq)LIiee20x0oGBgGTWweZx2jC9I9YG4LaxxD251lnKM0xUT2FjraE5a(I2bV0qeGTWVSOBpQ)st0f0T)5b5Lg(lnKLybEjWPHw7j7LtQRJumW7lnbUHtdTyTVSjEzVVSHVSt4w5(sdGOdem7LMGqSeXc8s42y8lrxagTGRW2)8G8sd)LgIyOdEjzBIoYxwyCm0zV0e4gon0I1(YnEPjiOVSt4w5(Yj11rkg41QinbbrJDf5G8Yj11rg44sGxENlaoO3(ZdYlrVRjCqjKqx9Igr0sdTqWwJGRTJKckIviyRPcjIdrHejkdN5JkKjiiASdfYqa87q1mOqgI7a)oxaCqVXNuxhzGJlbSWwt)ZdYlNuN6Arh8Yz3p(lNF)Sj5Lg(lNpFqz0K)Z)5b5LgsOR8YHdQ)8G8sd)LKMog)Y74GEZ(NhKxA4V8ob6VueHGWM(I2bCZaSf2Iy(YoHRxSxgeVe46QZoVEPH0K(YT1(ljcWlhWx0o4LgIaSf(LfD7r9xAIUGU9ppiV0WFPHSelWlbon0ApzVCsDDKIbEFPjWnCAOfR9LnXl79Ln8LDc3k3xAaeDGGzV0eeILiwGxc3gJFj6cWOfCf2(NhKxA4V0qedDWljBt0r(YcJJHo7LMa3WPHwS2xUXlnbb9LDc3k3xoPUosXaV2)8FEqEPH8bDNISo7LIora8xsdTyTVu0V6eAF5Dek1nx4lZinC0fqtGGFzr3os4lJelG9px0TJeAnbon0I1EqGl4T)Cr3osO1e40qlw7ihcreb7px0TJeAnbon0I1oYHqfYL2ZT2oY)Cr3osO1e40qlw7ihcbr06i5M((Nl62rcTMaNgAXAh5qOothWzUos44nXXwypxBNPd4mxhj06zjID2FUOBhj0AcCAOfRDKdHmJHoGdBt0roEtCiIqqyh2ygV1MqlCl6nbN9Nl62rcTMaNgAXAh5qiZy7i)ZfD7iHwtGtdTyTJCieZ1rkg4D8M4OOBhPL56ifd8APfC5BR9J7)Z)5b5LgYh0DkY6Sx6J6abE52A)LlA)LfDdWlB4lRrRgxIy3(Nl62rcpGMogZXb92FUOBhjCKdHmJTJC8M4W0xlZ1r2u(kaOY1w0Th1)ZfD7iHJCiec0596A44nXHPVwMRJSP8vaqLRTOBpQ)Nl62rch5qirhaDWToVgVjom91YCDKnLVcaQCTfD7r9)Cr3os4ihcjIJGXjqacmEtCy6RL56iBkFfau5Al62J6)5IUDKWroeIObUioc24nXHPVwMRJSP8vaqLRTOBpQ)Nl62rch5qiwe6XBIJjUn9wNxt3cC5RDBTZ3GZAxqJUFk00Xy(wGlFH2wBIdyh5P5)5IUDKWroeI56iBkhUapVw0J3ehgiIqqyh2ygV1MqlCl6TtgkkuIieewMRJSPCZyOdSiMcJcf00Xy(wGlFH2wBIdyh5P5)5IUDKWroeIwymVOBhjh3WD8S0(r6lAhWndWw4XBIJTWEU20x0oGBgGTWwplrSZMcnDmMVf4YxOT1M4a2rE6y(FUOBhjCKdHOfgZl62rYXnChplTF0AtCa7ihVjoGMogZ3cC5l02AtCa7ifC2FUOBhjCKdHUaToAGZjC8fsbyJ3eh0iWSyyAHiADKCMRJSP8vaqLRf46Qt4PzgHc1e9bhPnnDMDMrZnYqV7FUOBhjCKdHGiADK8rBSt0EYgVjo8bhPnnDMDMrZnYqVlku0iWSyyAHiADKCMRJSP8vaqLRf46QtOGt(EuOOrGzXW0cr06i5mxhzt5RaGkxlW1vNWtZM)Nl62rch5qiAHXCgWlgCl8nhahVjo8bhPnnDMDMrZnYqVlkugqJaZIHPfIO1rYzUoYMYxbavUwGRRoHNU7urecclZ1r2uoTW4oVSaxxDcfgfkdOrGzXW0cr06i5mxhzt5RaGkxlW1vNWtZMnDIIieewMRJSPCAHXDEzbUU6ekmku0iWSyyAHiADKCMRJSP8vaqLRf46QtOGZM8FUOBhjCKdHGiADKCMRJSP8vaqL74nXH5coUFQb(GJ0MMoZoZO5gzO3ffkderiiSmGxm4w4BoaAbUU6ekiTGlFBTp1arecc7WgZ4T2eAHBrVj4HrOqzc8r5xuMDMfDLmEqWVqWSkfEQbWabZHOla7KrOqjIqqyzaVyWTW3Ca0cCD1j80fLnyZTggkuIiee2lqRJg4CchFHuaMf46Qt4PlkBWMBnmHfw4)Cr3os4ihcbr06i5mxhzt5RaGk3XBIdZfCmBQb(GJ0MMoZoZO5gzO3ffkderiiSmGxm4w4BoaAbUU6ekiTGlFBTp1arecc7WgZ4T2eAHBrVj4HrJSf2Z12z6aoZ1rcTEwIyNnYwypxlZ1r2uonsiI2C7iTEwIyNnygHcLjWhLFrz2zw0vY4bb)cbZQCQbtClSNRL56iBkNgjerBUDKwplrSZqHseHGWoSXmERnHw4w0BcEy0iBH9CTDMoGZCDKqRNLi2zcl8udGbcMdrxa2jJqHseHGWYaEXGBHV5aOf46Qt4PlkBWMBnmuOeriiSxGwhnW5eo(cPamlW1vNWtxu2Gn3AyclSW)5IUDKWroeYmg6aoSnrh54nXHicbHDyJz8wBcTWTO3e8y(urecclZ1r2uonaUfUf92PJ5tfriiSmxhzt5MXqhyzXWCk00Xy(wGlFH2wBIdyh5P5)5IUDKWroeIfHE8M4ylSNRLfH26zjID2uGtaCi6se7t3cC5RDBTZ3GZAxqdyXAzrOTaxxDchXO7f(px0TJeoYHqORKXdc(fcMv54nXbmqWCi6cWe8ycOqzamqWCi6cWe8WOP0iWSyyAPfgZzaVyWTW3Ca0cCD1juWjp1GjUf2Z1cr06i5J2yNO9Kz9SeXodfkAeywmmTqeTos(On2jApzwGRRoHcAKWc)Nl62rch5qiyGG5Wf038XBIdyGG5q0fGDActfriiSmxhzt50a4w4w0BNoM)Nl62rch5qiMRJumW74nXbmqWCi6cWoDy0urecclZ1r2uonaUfXCQbgqJaZIHPfIO1rYzUoYMYxbavUwGRRoHNMDpku0iWSyyAHiADKCMRJSP8vaqLRf46QtOGZNlmkuIieewMRJSPCAaClCl6nbpmcfkrecclZ1r2uonaUf46Qt4PjGc12ANVbN1(P5tq4)Cr3os4ihcj2yhsdeWLZfdTOdGJ3ehMl4y2FUOBhjCKdHOfgZl62rYXnChplTFiI0ygV4q0fG9N)ZfD7iHwrKgZ4fhIUaSdyGG5Wf038)Cr3osOvePXmEXHOlaBKdHGOlwmKlg49p)Nl62rcTT2ehWoYJwBIdyh54nXHbIiee2HnMXBTj0c3IEtWddDQbWabZHOla7KrOqzc8r5xuMDMLwymNb8Ib3cFZbquOeriiSdBmJ3AtOfUf9MGh3ffktGpk)IYSZSIn2H0abC5CXql6aikugmrtGpk)IYSZSORKXdc(fcMv50jAc8r5xuMDUfDLmEqWVqWSkfw4Pt0e4JYVOm7ml6kz8GGFHGzvoDIMaFu(fLzNBrxjJhe8lemRYPIieewMRJSPCZyOdSSyykmkugST25BWzTFYOPIiee2HnMXBTj0c3IEtW7fgfkdmb(O8lkZo3slmMZaEXGBHV5a4urecc7WgZ4T2eAHBrVj48PtClSNRL56iBkNwyCNxwplrSZe(px0TJeABTjoGDKJCi0fO1rdCoHJVqkaB8M4GgbMfdtlerRJKZCDKnLVcaQCTaxxDcpnZiuOMOp4iTPPZSZmAUrg6D)ZfD7iH2wBIdyh5ihcrlmMZaEXGBHV5a44nXHb0iWSyyAHiADKCMRJSP8vaqLRf46Qt4P7oveHGWYCDKnLtlmUZllW1vNqHrHYaAeywmmTqeTosoZ1r2u(kaOY1cCD1j80SztNOicbHL56iBkNwyCNxwGRRoHcJcfncmlgMwiIwhjN56iBkFfau5AbUU6ek4Sj)Nl62rcTT2ehWoYroecIO1rYzUoYMYxbavU)5IUDKqBRnXbSJCKdHqxjJhe8lemRYXBIdyGG5q0fGj4Xe(ZfD7iH2wBIdyh5ihcHUsgpi4xiywLJ3ehWabZHOlatWdJMAGbgyc8r5xuMDUfDLmEqWVqWSkrHseHGWoSXmERnHw4w0BcEyKWtfriiSdBmJ3AtOfUf92P7kmku0iWSyyAHiADKCMRJSP8vaqLRf46Qt4PJlkBWMJcLicbHL56iBk3mg6alW1vNqbVOSbBUW)5IUDKqBRnXbSJCKdHyUosXaVJ3ehMaFu(fLzNzrxjJhe8lemRYPWabZHOlatWJztnqeHGWoSXmERnHw4w0BNomcfktGpk)IYSgzrxjJhe8lemRsHNcdemhIUaSttEQicbHL56iBkNga3Iy(Nl62rcTT2ehWoYroecIO1rYhTXor7jB8M4WaAeywmmTqeTosoZ1r2u(kaOY1cCD1juWjF)uOPJX8Tax(cTT2ehWoYthZfgfkAeywmmTqeTosoZ1r2u(kaOY1cCD1j80S5)5IUDKqBRnXbSJCKdHeBSdPbc4Y5IHw0bWXBIdAeywmmTqeTosoZ1r2u(kaOY1cCD1juW7(Nl62rcTT2ehWoYroecgiyoCb9nF8M4agiyoeDbyNMWurecclZ1r2uonaUfUf92PJ5)5IUDKqBRnXbSJCKdHyUosXaVJ3ehWabZHOla70HrtfriiSmxhzt50a4weZPgiIqqyzUoYMYPbWTWTO3e8WiuOeriiSmxhzt50a4wGRRoHNoUOSbBcwdt4)Cr3osOT1M4a2roYHqSi0JtfGID(wGlFHhZgxxd6CQauSZ3cC5l8WWgVjoaobWHOlrS)Nl62rcTT2ehWoYroeIwymVOBhjh3WD8S0(HisJz8Idrxa2F(px0TJeAtFr7aUza2cFqlmMx0TJKJB4oEwA)i9fTd4MbylmxePXSoVgVjoOrGzXW0M(I2bCZaSf2cCD1j8087)ZfD7iH20x0oGBgGTWJCieTWyEr3osoUH74zP9J0x0oGBgGTW8IU9O(4nXHicbHn9fTd4MbylSfX8p)Nl62rcTPVODa3maBH5fD7r9JlqRJg4CchFHua24nXbncmlgMwiIwhjN56iBkFfau5AbUU6eEAMrOqnrFWrAttNzNz0CJm07(Nl62rcTPVODa3maBH5fD7r9roecIO1rYhTXor7jB8M4GgbMfdtlerRJKZCDKnLVcaQCTaxxDcfCY3JcfncmlgMwiIwhjN56iBkFfau5AbUU6eEA28)Cr3osOn9fTd4MbylmVOBpQpYHq0cJ5mGxm4w4BoaoEtCyancmlgMwiIwhjN56iBkFfau5AbUU6eE6UtfriiSmxhzt50cJ78YcCD1juyuOmGgbMfdtlerRJKZCDKnLVcaQCTaxxDcpnB20jkIqqyzUoYMYPfg35Lf46QtOWOqrJaZIHPfIO1rYzUoYMYxbavUwGRRoHcoBY)5IUDKqB6lAhWndWwyEr3EuFKdHOfgZl62rYXnChplTFiI0ygV4q0fGnEtCademhIUaSJztnGgbMfdtlTWyod4fdUf(MdGwGRRoHNk62rAHOlwmKlg41sl4Y3w7OqzWwypxRyJDinqaxoxm0IoaA9SeXoBkncmlgMwXg7qAGaUCUyOfDa0cCD1j8ur3osleDXIHCXaVwAbx(2AxyH)ZfD7iH20x0oGBgGTW8IU9O(ihcHUsgpi4xiywLJ3ehgyancmlgMwAHXCgWlgCl8nhaTaxxDcfSOBhPL56ifd8APfC5BRDHNAancmlgMwAHXCgWlgCl8nhaTaxxDcfSOBhPfIUyXqUyGxlTGlFBTlSWtfriiSPVODa3maBHTaxxDcfSOBhPfDLmEqWVqWSkT0cU8T1(FUOBhj0M(I2bCZaSfMx0Th1h5qiiIwhjN56iBkFfau5oEtCiIqqytFr7aUza2cBbUU6eEA29tHbcMdrxa2X9)5IUDKqB6lAhWndWwyEr3EuFKdHGiADKCMRJSP8vaqL74nXHicbHn9fTd4MbylSf46Qt4PIUDKwiIwhjN56iBkFfau5APfC5BR9rMGDc)5IUDKqB6lAhWndWwyEr3EuFKdHyUosXaVJ3ehIieewMRJSPCAaClI5FUOBhj0M(I2bCZaSfMx0Th1h5qiAHX8IUDKCCd3XZs7hIinMXloeDby)5)Cr3osOn9fTd4MbylmxePXSoVosFr7aUza2cpEtCademhIUambpMWudM4wypxRzm0bCyBIosRNLi2zOqjIqqyzUoYMYPbWTiMc)Nl62rcTPVODa3maBH5IinM151ihcrlmMZaEXGBHV5a4FUOBhj0M(I2bCZaSfMlI0ywNxJCie6kz8GGFHGzvoEtCqJaZIHPLwymNb8Ib3cFZbqlW1vNqbNnjtHbcMdrxaMGhg9Nl62rcTPVODa3maBH5IinM151ihczgdDah2MOJC8M4qeHGWoSXmERnHw4w0BcEmFQicbHL56iBkNga3c3IE70X8PIieewMRJSPCZyOdSSyyofgiyoeDbycEy0FUOBhj0M(I2bCZaSfMlI0ywNxJCie6kz8GGFHGzvoEtCademhIUambpMWFUOBhj0M(I2bCZaSfMlI0ywNxJCieTWyEr3osoUH74zP9drKgZ4fhIUamf5Ooa2rQgy(9ZMK7VRr3BNpFctIICybYoVGkY78DK7Wa3PdChDq9YxAmA)LT2ma7ljcWlh0mbon0I1oO9sGp4inWzVegA)LfYg6AD2lPOR8YH2)8DCN(lNWG6L3jjeX0maRZEzr3oYxoO1z6aoZ1rch0S)5)8DQ2maRZEPH9YIUDKVe3WfA)ZksCdxOYyfzRnXbSJuzSAGzkJvKEwIyNPgtrsb96GUuKg8srecc7WgZ4T2eAHBrV9sbpEPH(YPV0GxcdemhIUaSxE6Lg9suOEPjWhLFrz2zwAHXCgWlgCl8nhaFjkuVueHGWoSXmERnHw4w0BVuWJxE3xIc1lnb(O8lkZoZk2yhsdeWLZfdTOdGVefQxAWlN4lnb(O8lkZoZIUsgpi4xiywLVC6lN4lnb(O8lkZo3IUsgpi4xiywLVu4xk8lN(Yj(stGpk)IYSZSORKXdc(fcMv5lN(Yj(stGpk)IYSZTORKXdc(fcMv5lN(srecclZ1r2uUzm0bwwmmFPWVefQxAWl3w78n4S2F5PxA0lN(srecc7WgZ4T2eAHBrV9sbF59Vu4xIc1ln4LMaFu(fLzNBPfgZzaVyWTW3Ca8LtFPicbHDyJz8wBcTWTO3EPGVC(lN(Yj(YTWEUwMRJSPCAHXDEz9SeXo7LcRil62rQiBTjoGDKQvnWCLXksplrSZuJPiPGEDqxksAeywmmTqeTosoZ1r2u(kaOY1cCD1j8LNE5mJEjkuVCIV0hCK200z2HnMa4mih2xnMheCiIPd6aWHiADKDEPil62rQiVaToAGZjC8fsbyQvnGrkJvKEwIyNPgtrsb96GUuKg8sAeywmmTqeTosoZ1r2u(kaOY1cCD1j8LNE5DF50xkIqqyzUoYMYPfg35Lf46Qt4lf(LOq9sdEjncmlgMwiIwhjN56iBkFfau5AbUU6e(YtVC2Sxo9Lt8LIieewMRJSPCAHXDEzbUU6e(sHFjkuVKgbMfdtlerRJKZCDKnLVcaQCTaxxDcFPGVC2KvKfD7ivK0cJ5mGxm4w4BoaQw1atwzSISOBhPIeIO1rYzUoYMYxbavUksplrSZuJPw1atqzSI0Zse7m1ykskOxh0LIegiyoeDbyVuWJxobfzr3osfj6kz8GGFHGzvQw1agQYyfPNLi2zQXuKuqVoOlfjmqWCi6cWEPGhV0Oxo9Lg8sdEPbV0e4JYVOm7Cl6kz8GGFHGzv(suOEPicbHDyJz8wBcTWTO3EPGhV0Oxk8lN(srecc7WgZ4T2eAHBrV9YtV8UVu4xIc1lPrGzXW0cr06i5mxhzt5RaGkxlW1vNWxE64Lxu2lhSxo)LOq9srecclZ1r2uUzm0bwGRRoHVuWxErzVCWE58xkSISOBhPIeDLmEqWVqWSkvRAadtzSI0Zse7m1ykskOxh0LI0e4JYVOm7ml6kz8GGFHGzv(YPVegiyoeDbyVuWJxo7LtFPbVueHGWoSXmERnHw4w0BV80Xln6LOq9stGpk)IYSgzrxjJhe8lemRYxk8lN(syGG5q0fG9YtVCYVC6lfriiSmxhzt50a4wetfzr3osfjZ1rkg4vTQbMeLXksplrSZuJPiPGEDqxksdEjncmlgMwiIwhjN56iBkFfau5AbUU6e(sbF5KV)LtFj00Xy(wGlFH2wBIdyh5lpD8Y5Vu4xIc1lPrGzXW0cr06i5mxhzt5RaGkxlW1vNWxE6LZMRil62rQiHiADK8rBSt0EYuRAG7Qmwr6zjIDMAmfjf0Rd6srsJaZIHPfIO1rYzUoYMYxbavUwGRRoHVuWxExfzr3osfPyJDinqaxoxm0IoaQw1aZUxzSI0Zse7m1ykskOxh0LIegiyoeDbyV80lNWlN(srecclZ1r2uonaUfUf92lpD8Y5kYIUDKksyGG5Wf03C1Qgy2mLXksplrSZuJPiPGEDqxksyGG5q0fG9YthV0Oxo9LIieewMRJSPCAaClI5lN(sdEPicbHL56iBkNga3c3IE7LcE8sJEjkuVueHGWYCDKnLtdGBbUU6e(YthV8IYE5G9YjynSxkSISOBhPIK56ifd8Qw1aZMRmwr6zjIDMAmfzr3osfjlcTIKkaf78Tax(cvdmtrQRbDovak25BbU8fQinmfjf0Rd6srcCcGdrxIyxTQbMzKYyfPNLi2zQXuKfD7ivK0cJ5fD7i54gUksCdxEwAxrkI0ygV4q0fGPw1QizorHGxLXQbMPmwrw0TJurcnDmMJd6nfPNLi2zQXuRAG5kJvKEwIyNPgtrsb96GUuKM(AzUoYMYxbavU2IU9OUISOBhPI0m2os1QgWiLXksplrSZuJPiPGEDqxkstFTmxhzt5RaGkxBr3Euxrw0TJurIaDEVUgQw1atwzSI0Zse7m1ykskOxh0LI00xlZ1r2u(kaOY1w0Th1vKfD7ivKIoa6GBDEPw1atqzSI0Zse7m1ykskOxh0LI00xlZ1r2u(kaOY1w0Th1vKfD7ivKI4iyCceGaQvnGHQmwr6zjIDMAmfjf0Rd6srA6RL56iBkFfau5Al62J6kYIUDKksIg4I4iyQvnGHPmwr6zjIDMAmfjf0Rd6sroXxUn9wNxVC6l3cC5RDBTZ3GZA)Lc(sJU)LtFj00Xy(wGlFH2wBIdyh5lp9Y5kYIUDKksweA1QgysugRi9SeXotnMIKc61bDPin4LIiee2HnMXBTj0c3IE7LNEPH(suOEPicbHL56iBk3mg6alI5lf(LOq9sOPJX8Tax(cTT2ehWoYxE6LZvKfD7ivKmxhzt5Wf451IwTQbURYyfPNLi2zQXuKuqVoOlf5wypxB6lAhWndWwyRNLi2zVC6lHMogZ3cC5l02AtCa7iF5PJxoxrw0TJurslmMx0TJKJB4QiXnC5zPDfz6lAhWndWwy1Qgy29kJvKEwIyNPgtrsb96GUuKqthJ5BbU8fABTjoGDKVuWxotrw0TJurslmMx0TJKJB4QiXnC5zPDfzRnXbSJuTQbMntzSI0Zse7m1ykskOxh0LIKgbMfdtlerRJKZCDKnLVcaQCTaxxDcF5PxoZOxIc1lN4l9bhPnnDMDyJjaodYH9vJ5bbhIy6GoaCiIwhzNxkYIUDKkYlqRJg4CchFHuaMAvdmBUYyfPNLi2zQXuKuqVoOlfPp4iTPPZSdBmbWzqoSVAmpi4qeth0bGdr06i786LOq9sAeywmmTqeTosoZ1r2u(kaOY1cCD1j8Lc(YjF)lrH6L0iWSyyAHiADKCMRJSP8vaqLRf46Qt4lp9YzZvKfD7ivKqeTos(On2jApzQvnWmJugRi9SeXotnMIKc61bDPi9bhPnnDMDyJjaodYH9vJ5bbhIy6GoaCiIwhzNxVefQxAWlPrGzXW0cr06i5mxhzt5RaGkxlW1vNWxE6L39LtFPicbHL56iBkNwyCNxwGRRoHVu4xIc1ln4L0iWSyyAHiADKCMRJSP8vaqLRf46Qt4lp9YzZE50xoXxkIqqyzUoYMYPfg35Lf46Qt4lf(LOq9sAeywmmTqeTosoZ1r2u(kaOY1cCD1j8Lc(Yztwrw0TJurslmMZaEXGBHV5aOAvdmBYkJvKEwIyNPgtrsb96GUuKMl4LhV8(xo9Lg8sFWrAttNzh2ycGZGCyF1yEqWHiMoOdahIO1r251lrH6Lg8sreccld4fdUf(MdGwGRRoHVuWxsl4Y3w7VC6ln4LIiee2HnMXBTj0c3IE7LcE8sJEjkuV0e4JYVOm7ml6kz8GGFHGzv(sHF50xAWlHbcMdrxa2lp9sJEjkuVueHGWYaEXGBHV5aOf46Qt4lp9Ylk7Ld2lNBnSxIc1lfriiSxGwhnW5eo(cPamlW1vNWxE6Lxu2lhSxo3AyVu4xk8lfwrw0TJurcr06i5mxhzt5RaGkx1Qgy2eugRi9SeXotnMIKc61bDPinxWlpE5Sxo9Lg8sFWrAttNzh2ycGZGCyF1yEqWHiMoOdahIO1r251lrH6Lg8sreccld4fdUf(MdGwGRRoHVuWxsl4Y3w7VC6ln4LIiee2HnMXBTj0c3IE7LcE8sJE5iVClSNRTZ0bCMRJeA9SeXo7LJ8YTWEUwMRJSPCAKqeT52rA9SeXo7Ld2ln6LOq9stGpk)IYSZSORKXdc(fcMv5lN(sdE5eF5wypxlZ1r2uonsiI2C7iTEwIyN9suOEPicbHDyJz8wBcTWTO3EPGhV0OxoYl3c75A7mDaN56iHwplrSZEPWVu4xo9Lg8syGG5q0fG9YtV0OxIc1lfriiSmGxm4w4BoaAbUU6e(YtV8IYE5G9Y5wd7LOq9srecc7fO1rdCoHJVqkaZcCD1j8LNE5fL9Yb7LZTg2lf(Lc)sHvKfD7ivKqeTosoZ1r2u(kaOYvTQbMzOkJvKEwIyNPgtrsb96GUuKIiee2HnMXBTj0c3IE7LcE8Y5VC6lfriiSmxhzt50a4w4w0BV80XlN)YPVueHGWYCDKnLBgdDGLfdZxo9LqthJ5BbU8fABTjoGDKV80lNRil62rQinJHoGdBt0rQw1aZmmLXksplrSZuJPiPGEDqxkYTWEUwweARNLi2zVC6lbobWHOlrS)YPVClWLV2T1oFdoR9xk4ln4LSyTSi0wGRRoHVCKxA09Vuyfzr3osfjlcTAvdmBsugRi9SeXotnMIKc61bDPiHbcMdrxa2lf84Lt4LOq9sdEjmqWCi6cWEPGhV0Oxo9L0iWSyyAPfgZzaVyWTW3Ca0cCD1j8Lc(Yj)YPV0GxoXxUf2Z1cr06i5J2yNO9Kz9SeXo7LOq9sAeywmmTqeTos(On2jApzwGRRoHVuWxA0lf(LcRil62rQirxjJhe8lemRs1Qgy2DvgRi9SeXotnMIKc61bDPiHbcMdrxa2lp9Yj8YPVueHGWYCDKnLtdGBHBrV9YthVCUISOBhPIegiyoCb9nxTQbMFVYyfPNLi2zQXuKuqVoOlfjmqWCi6cWE5PJxA0lN(srecclZ1r2uonaUfX8LtFPbV0GxsJaZIHPfIO1rYzUoYMYxbavUwGRRoHV80lND)lrH6L0iWSyyAHiADKCMRJSP8vaqLRf46Qt4lf8LZN)sHFjkuVueHGWYCDKnLtdGBHBrV9sbpEPrVefQxkIqqyzUoYMYPbWTaxxDcF5PxoHxIc1l3w78n4S2F5PxoFcVuyfzr3osfjZ1rkg4vTQbMptzSI0Zse7m1ykskOxh0LI0CbV84LZuKfD7ivKIn2H0abC5CXql6aOAvdmFUYyfPNLi2zQXuKfD7ivK0cJ5fD7i54gUksCdxEwAxrkI0ygV4q0fGPw1Qinbon0I1QmwnWmLXksplrSZuJPw1aZvgRi9SeXotnMAvdyKYyfPNLi2zQXuRAGjRmwrw0TJurcr06i5eognsUoqr6zjIDMAm1QgyckJvKEwIyNPgtrsb96GUuKBH9CTDMoGZCDKqRNLi2zkYIUDKkYothWzUosOAvdyOkJvKEwIyNPgtrsb96GUuKIiee2HnMXBTj0c3IE7Lc(YzkYIUDKksZyOd4W2eDKQvnGHPmwrw0TJurAgBhPI0Zse7m1yQvnWKOmwr6zjIDMAmfjf0Rd6srw0TJ0YCDKIbET0cU8T1(lpE59kYIUDKksMRJumWRAvRIm9fTd4MbylmVOBpQRmwnWmLXksplrSZuJPiPGEDqxksAeywmmTqeTosoZ1r2u(kaOY1cCD1j8LNE5mJEjkuVCIV0hCK200z2HnMa4mih2xnMheCiIPd6aWHiADKDEPil62rQiVaToAGZjC8fsbyQvnWCLXksplrSZuJPiPGEDqxksAeywmmTqeTosoZ1r2u(kaOY1cCD1j8Lc(YjF)lrH6L0iWSyyAHiADKCMRJSP8vaqLRf46Qt4lp9YzZvKfD7ivKqeTos(On2jApzQvnGrkJvKEwIyNPgtrsb96GUuKg8sAeywmmTqeTosoZ1r2u(kaOY1cCD1j8LNE5DF50xkIqqyzUoYMYPfg35Lf46Qt4lf(LOq9sdEjncmlgMwiIwhjN56iBkFfau5AbUU6e(YtVC2Sxo9Lt8LIieewMRJSPCAHXDEzbUU6e(sHFjkuVKgbMfdtlerRJKZCDKnLVcaQCTaxxDcFPGVC2KvKfD7ivK0cJ5mGxm4w4BoaQw1atwzSI0Zse7m1ykskOxh0LIegiyoeDbyV84LZE50xAWlPrGzXW0slmMZaEXGBHV5aOf46Qt4lp9YIUDKwi6Ifd5IbET0cU8T1(lrH6Lg8YTWEUwXg7qAGaUCUyOfDa06zjID2lN(sAeywmmTIn2H0abC5CXql6aOf46Qt4lp9YIUDKwi6Ifd5IbET0cU8T1(lf(LcRil62rQiPfgZl62rYXnCvK4gU8S0UIuePXmEXHOlatTQbMGYyfPNLi2zQXuKuqVoOlfPbV0GxsJaZIHPLwymNb8Ib3cFZbqlW1vNWxk4ll62rAzUosXaVwAbx(2A)Lc)YPV0GxsJaZIHPLwymNb8Ib3cFZbqlW1vNWxk4ll62rAHOlwmKlg41sl4Y3w7Vu4xk8lN(sreccB6lAhWndWwylW1vNWxk4ll62rArxjJhe8lemRslTGlFBTRil62rQirxjJhe8lemRs1QgWqvgRi9SeXotnMIKc61bDPifriiSPVODa3maBHTaxxDcF5Pxo7(xo9LWabZHOla7LhV8Efzr3osfjerRJKZCDKnLVcaQCvRAadtzSI0Zse7m1ykskOxh0LIueHGWM(I2bCZaSf2cCD1j8LNEzr3oslerRJKZCDKnLVcaQCT0cU8T1(lh5LtWobfzr3osfjerRJKZCDKnLVcaQCvRAGjrzSI0Zse7m1ykskOxh0LIueHGWYCDKnLtdGBrmvKfD7ivKmxhPyGx1Qg4UkJvKEwIyNPgtrw0TJurslmMx0TJKJB4QiXnC5zPDfPisJz8IdrxaMAvRIm9fTd4MbylmxePXSoVugRgyMYyfPNLi2zQXuKuqVoOlfjmqWCi6cWEPGhVCcVC6ln4Lt8LBH9CTMXqhWHTj6iTEwIyN9suOEPicbHL56iBkNga3Iy(sHvKfD7ivKPVODa3maBHvRAG5kJvKfD7ivK0cJ5mGxm4w4BoaQi9SeXotnMAvdyKYyfPNLi2zQXuKuqVoOlfjncmlgMwAHXCgWlgCl8nhaTaxxDcFPGVC2K8YPVegiyoeDbyVuWJxAKISOBhPIeDLmEqWVqWSkvRAGjRmwr6zjIDMAmfjf0Rd6srkIqqyh2ygV1MqlCl6Txk4XlN)YPVueHGWYCDKnLtdGBHBrV9YthVC(lN(srecclZ1r2uUzm0bwwmmF50xcdemhIUaSxk4Xlnsrw0TJurAgdDah2MOJuTQbMGYyfPNLi2zQXuKuqVoOlfjmqWCi6cWEPGhVCckYIUDKks0vY4bb)cbZQuTQbmuLXksplrSZuJPil62rQiPfgZl62rYXnCvK4gU8S0UIuePXmEXHOlatTQvrkI0ygV4q0fGPmwnWmLXkYIUDKksyGG5Wf03CfPNLi2zQXuRAG5kJvKfD7ivKq0flgYfd8Qi9SeXotnMAvRIm9fTd4MbylSYy1aZugRi9SeXotnMIKc61bDPiPrGzXW0M(I2bCZaSf2cCD1j8LNE587vKfD7ivK0cJ5fD7i54gUksCdxEwAxrM(I2bCZaSfMlI0ywNxQvnWCLXksplrSZuJPiPGEDqxksreccB6lAhWndWwylIPISOBhPIKwymVOBhjh3WvrIB4YZs7kY0x0oGBgGTW8IU9OUAvRAvKfYIoaksYwBiPw1Qu]] )

    
end
