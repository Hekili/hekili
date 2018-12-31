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

        if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > query_time then
            summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - query_time )
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

            copy = { "summon_pet", 112870, "summon_wrathguard" }
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


    spec:RegisterPack( "Demonology", 20181230.2126, [[dCKpcbqifjEefqBsr5tkejJII4uuOwLIu1ROinlfQUffGDrPFbv1WOaDmfXYurEgf00uPsxtHW2uPkFtHOgNIu5CQuX6uiI5PI6EQW(qQCqvQQQfQq5HQuvzIksYfvKuXhvKuPtQiLyLkQMPIKQ2jfYpvPQkdvLQYsvKuEksMksvxvrkPVQiLAVe9xunysoSKftWJrmzuUmvBMqFwLmAOYPL61QuMnOBtQDl63cdxbhxrkwoWZv10v66qz7kK(of14visDEOkZhPSFilNiPxsXQ1LgDYGtMUjNm0G2ttonIjtKulEdUKAOi3QlxsLL2LutLRJmGXfEsQHcpyumj9sQpWaexsHB3HFKGp(x9IdtWscn(FRXG12rsaL4I)3Ac(cWqaFbXYay(O4pacXg6p(3hWNAvZE8VVPgFAxayqUXNkxhzaJl8SFRjskbSgUtlPuqsXQ1LgDYGtMUjNm0G2ttoncdoYsQFWjsJoDV7jPW1mMNsbjfZFIKYarQPY1rgW4cpKAAxayqUHMBGifUDh(rc(4F1lomblj04)TgdwBhjbuIl(FRj4ladb8feldG5JI)aieBO)4FFaFQvn7X)(MA8PDbGb5gFQCDKbmUWZ(TMGMBGi1u5exl4aKYqdoosDYGtMoKYaqQttgjNmenhn3arQ7hUkV8FKGMBGiLbGuudoeIut9b5Mfn3arkdaPMwFhPeWefTPV4CaFiaBbTydivN)6fdPcrKc46QZoVqQ73uHuBRDKsmaiLr(IZbi19fGTGivr2EuhPgWvVBrZnqKYaqQ7VeIhsbCsO1EYqQPY1rkeWfPgaUbqcTqTivlIu9Iu9JuD(BLlszYJlWGmKAaecLaepK63gcrkCfGrQFn2IMBGiLbGu3xy2bifvpGlsKQGWWSZqQbGBaKqlulsTbsnaccs15VvUi1u56ifc4ALudGqSHUKYarQPY1rgW4cpKAAxayqUHMBGifUDh(rc(4F1lomblj04)TgdwBhjbuIl(FRj4ladb8feldG5JI)aieBO)4FFaFQvn7X)(MA8PDbGb5gFQCDKbmUWZ(TMGMBGi1u5exl4aKYqdoosDYGtMoKYaqQttgjNmenhn3arQ7hUkV8FKGMBGiLbGuudoeIut9b5Mfn3arkdaPMwFhPeWefTPV4CaFiaBbTydivN)6fdPcrKc46QZoVqQ73uHuBRDKsmaiLr(IZbi19fGTGivr2EuhPgWvVBrZnqKYaqQ7VeIhsbCsO1EYqQPY1rkeWfPgaUbqcTqTivlIu9Iu9JuD(BLlszYJlWGmKAaecLaepK63gcrkCfGrQFn2IMBGiLbGu3xy2bifvpGlsKQGWWSZqQbGBaKqlulsTbsnaccs15VvUi1u56ifc4ArZrZnqKAQZiTtWwNHucUyaCKIeAHArkb)QZ3Iu3)eIpSpsLrAa4kGwedIufz7iFKksiEw08ISDKVDa4Kqlu7HiS(BO5fz7iF7aWjHwOwtpWxmcgAEr2oY3oaCsOfQ10d8lSlTNBTDKO5fz7iF7aWjHwOwtpW)X06i5d(IMxKTJ8TdaNeAHAn9a)othWzUoYF8w8ylONRTZ0bCMRJ8TEwcqNHMxKTJ8TdaNeAHAn9a)HWSd4FpGlYXBXdbmrrR5gY4TE4T)wKB0nbnViBh5Bhaoj0c1A6b(dX2rIMxKTJ8TdaNeAHAn9aFMRJuiG74T4Hq8pnAfz7iTmxhPqaxlP(LVT2pmiAoAUbIutDgPDc26mKYh1b4HuBRDKAX5ivr2aGu9Ju1OvdlbOBrZlY2r(h)GdHCyqUHMxKTJ8n9a)Hy7ihVfpg81YCDKnHV4bQCTfz7rD08ISDKVPh4J9oVxx)J3Ihd(AzUoYMWx8avU2IS9OoAEr2oY30d8fCW7GBDEnElEm4RL56iBcFXdu5AlY2J6O5fz7iFtpWxagbJlIbWB8w8yWxlZ1r2e(IhOY1wKTh1rZlY2r(MEGVydCbyeSXBXJbFTmxhzt4lEGkxBr2EuhnViBh5B6b(Si0J3IhtzBYToVMTf4Yx72ANVbN1oDgAWz)GdH8Tax((2wpaJVJ88j08ISDKVPh4ZCDKnH)lWZRf34T4HjcyIIwZnKXB9WB)Ti3oFpA0eWefTmxhzt4dHzhyXgmMgTFWHq(wGlFFBRhGX3rE(eAEr2oY30d8jfeYlY2rYH9VJNL2psFX5a(qa2coElESf0Z1M(IZb8HaSf06zjaD2SFWHq(wGlFFBRhGX3rE(4eAEr2oY30d8jfeYlY2rYH9VJNL2pA9am(oYXBXJFWHq(wGlFFBRhGX3rs3e08ISDKVPh4FbAD0aNl6WlScWgVfpirazH50(yADKCMRJSj8fpqLRf46QZ)8edPrBk(0G1ddoZoXWtgEV7GMxKTJ8n9a)htRJKpAdDX2t24T4Hpny9WGZStm8KH37o0OrIaYcZP9X06i5mxhzt4lEGkxlW1vNpD31G0OrIaYcZP9X06i5mxhzt4lEGkxlW1vN)5jNqZlY2r(MEGpPGqod4f73cEZb)4T4Hpny9WGZStm8KH37o0OzcjcilmN2htRJKZCDKnHV4bQCTaxxD(NVZmbmrrlZ1r2eoPGWoVSaxxD(gtJMjKiGSWCAFmTosoZ1r2e(IhOY1cCD15FEYKztratu0YCDKnHtkiSZllW1vNVX0OrIaYcZP9X06i5mxhzt4lEGkxlW1vNpDtUlAEr2oY30d8FmTosoZ1r2e(IhOYD8w8WNgSEyWz2jgEYW7DhA0mratu0YaEX(TG3CWBbUU68PJu)Y3w7Zmratu0AUHmERhE7Vf5gDhgA6wqpxBNPd4mxh5B9SeGoZ0TGEUwMRJSjCsKpMEy7iTEwcqNn9gsJ2aWhLFry2jwCvY4Hi)cdYQCMjtzlONRL56iBcNe5JPh2osRNLa0z0OjGjkAn3qgV1dV93ICJUddnDlONRTZ0bCMRJ8TEwcqNzSXZm5dmi)Xva2zdPrtatu0YaEX(TG3CWBbUU68pFryt)j7itJMaMOO9c06Obox0HxyfGzbUU68pFryt)j7iBSXO5fz7iFtpWFim7a(3d4IC8w8qatu0AUHmERhE7Vf5gDhNMjGjkAzUoYMWjbWT)wKBNpontatu0YCDKnHpeMDGLfMZz)GdH8Tax((2wpaJVJ88j08ISDKVPh4ZIqpElESf0Z1YIqB9SeGoBgWfb(JReG(STax(A3w78n4S2PZewSwweAlW1vNVPgAqJrZlY2r(MEGpUkz8qKFHbzvoElE8bgK)4kaJUJrqJMjFGb5pUcWO7WWzKiGSWCAjfeYzaVy)wWBo4TaxxD(0D3zMmLTGEU2htRJKpAdDX2tM1Zsa6mA0irazH50(yADK8rBOl2EYSaxxD(0zOXgJMxKTJ8n9a)pWG8Fb9nF8w84dmi)Xva25rmtatu0YCDKnHtcGB)Ti3oFCcnViBh5B6b(mxhPqa3XBXJpWG8hxbyNpmCMaMOOL56iBcNea3InmZetirazH50(yADKCMRJSj8fpqLRf46QZ)8edsJgjcilmN2htRJKZCDKnHV4bQCTaxxD(0D6KX0OjGjkAzUoYMWjbWT)wKB0DyinAcyIIwMRJSjCsaClW1vN)5rqJ22ANVbN1(5tJWy08ISDKVPh4l0q)jbg4Y5cHwWbpAEr2oY30d8jfeYlY2rYH9VJNL2peWAiJx8hxbyO5O5fz7iFRawdz8I)4ka74dmi)xqFZrZlY2r(wbSgY4f)XvaMPh4)4kwyMleWfnhnViBh5BB9am(oYJwpaJVJC8w8WebmrrR5gY4TE4T)wKB0DCVzM8bgK)4ka7SH0Ona8r5xeMDILuqiNb8I9BbV5GNgnbmrrR5gY4TE4T)wKB0DChA0ga(O8lcZoXk0q)jbg4Y5cHwWbpnAMmLbGpk)IWStS4QKXdr(fgKv5SPma8r5xeM9KfxLmEiYVWGSkn24ztza4JYVim7elUkz8qKFHbzvoBkdaFu(fHzpzXvjJhI8lmiRYzcyIIwMRJSj8HWSdSSWCAmnAMST25BWzTF2WzcyIIwZnKXB9WB)Ti3OZGgtJMjdaFu(fHzpzjfeYzaVy)wWBo4NjGjkAn3qgV1dV93ICJUtZMYwqpxlZ1r2eoPGWoVSEwcqNzmAEr2oY326by8DKMEG)fO1rdCUOdVWkaB8w8GebKfMt7JP1rYzUoYMWx8avUwGRRo)ZtmKgTP4tdwpm4m7edpz49UdAEr2oY326by8DKMEGpPGqod4f73cEZb)4T4HjKiGSWCAFmTosoZ1r2e(IhOY1cCD15F(oZeWefTmxhzt4Kcc78YcCD15BmnAMqIaYcZP9X06i5mxhzt4lEGkxlW1vN)5jtMnfbmrrlZ1r2eoPGWoVSaxxD(gtJgjcilmN2htRJKZCDKnHV4bQCTaxxD(0n5UO5fz7iFBRhGX3rA6b(pMwhjN56iBcFXdu5IMxKTJ8TTEagFhPPh4JRsgpe5xyqwLJ3IhFGb5pUcWO7yeO5fz7iFBRhGX3rA6b(4QKXdr(fgKv54T4Xhyq(JRam6omCMjMyYaWhLFry2twCvY4Hi)cdYQKgnbmrrR5gY4TE4T)wKB0DyOXZeWefTMBiJ36H3(BrUD(ogtJgjcilmN2htRJKZCDKnHV4bQCTaxxD(NpUiSP)enAcyIIwMRJSj8HWSdSaxxD(0Dryt)jJrZlY2r(2wpaJVJ00d8zUosHaUJ3IhdaFu(fHzNyXvjJhI8lmiRYzFGb5pUcWO7yYmteWefTMBiJ36H3(BrUD(WqA0ga(O8lcZAOfxLmEiYVWGSknE2hyq(JRaSZ3DMaMOOL56iBcNea3InGMxKTJ8TTEagFhPPh4)yADK8rBOl2EYgVfpmHebKfMt7JP1rYzUoYMWx8avUwGRRoF6URbN9doeY3cC57BB9am(oYZhNmMgnseqwyoTpMwhjN56iBcFXdu5AbUU68pp5eAEr2oY326by8DKMEGVqd9NeyGlNleAbh8J3IhKiGSWCAFmTosoZ1r2e(IhOY1cCD15t3DqZlY2r(2wpaJVJ00d8)adY)f038XBXJpWG8hxbyNhXmbmrrlZ1r2eojaU93IC78Xj08ISDKVT1dW47in9aFMRJuiG74T4Xhyq(JRaSZhgotatu0YCDKnHtcGBXgMzIaMOOL56iBcNea3(BrUr3HH0OjGjkAzUoYMWjbWTaxxD(NpUiSPFe2r2y08ISDKVT1dW47in9aFwe6Xj4rGoFlWLV)XKX11inNGhb68Tax((hJ84T4bWfb(JReGoAEr2oY326by8DKMEGpPGqEr2osoS)D8S0(Hawdz8I)4kadnhnViBh5BtFX5a(qa2cEqkiKxKTJKd7FhplTFK(IZb8HaSfKlG1qwNxJ3IhKiGSWCAtFX5a(qa2cAbUU68pFYGO5fz7iFB6lohWhcWwqtpWNuqiViBhjh2)oEwA)i9fNd4dbyliViBpQpElEiGjkAtFX5a(qa2cAXgqZrZlY2r(20xCoGpeGTG8IS9O(Hqd9NeyGlNleAbh8O5fz7iFB6lohWhcWwqEr2Eu30d8VaToAGZfD4fwbyJ3IhKiGSWCAFmTosoZ1r2e(IhOY1cCD15FEIH0OnfFAW6HbNzNy4jdV3DqZlY2r(20xCoGpeGTG8IS9OUPh4)yADK8rBOl2EYgVfpirazH50(yADKCMRJSj8fpqLRf46QZNU7AqA0irazH50(yADKCMRJSj8fpqLRf46QZ)8KtO5fz7iFB6lohWhcWwqEr2Eu30d8jfeYzaVy)wWBo4hVfpmHebKfMt7JP1rYzUoYMWx8avUwGRRo)Z3zMaMOOL56iBcNuqyNxwGRRoFJPrZeseqwyoTpMwhjN56iBcFXdu5AbUU68ppzYSPiGjkAzUoYMWjfe25Lf46QZ3yA0irazH50(yADKCMRJSj8fpqLRf46QZNUj3fnViBh5BtFX5a(qa2cYlY2J6MEGVqd9NeyGlNleAbh8O5fz7iFB6lohWhcWwqEr2Eu30d8jfeYlY2rYH9VJNL2peWAiJx8hxbyJ3IhFGb5pUcWoMmZeseqwyoTKcc5mGxSFl4nh8wGRRo)Zfz7iTpUIfM5cbCTK6x(2ANgnt2c65AfAO)KadC5CHql4G36zjaD2mseqwyoTcn0FsGbUCUqOfCWBbUU68pxKTJ0(4kwyMleW1sQF5BRDJngnViBh5BtFX5a(qa2cYlY2J6MEGpUkz8qKFHbzvoElEyIjKiGSWCAjfeYzaVy)wWBo4TaxxD(0vKTJ0YCDKcbCTK6x(2A34zMqIaYcZPLuqiNb8I9BbV5G3cCD15txr2os7JRyHzUqaxlP(LVT2n24zKiGSWCAtFX5a(qa2cAbUU68PZKj3BeMwKTJ0IRsgpe5xyqwLws9lFBTBmAEr2oY3M(IZb8HaSfKxKTh1n9a)htRJKZCDKnHV4bQChVfpeWefTPV4CaFiaBbTaxxD(NhXSpWG8hxbyhgenViBh5BtFX5a(qa2cYlY2J6MEG)JP1rYzUoYMWx8avUJ3IhcyII20xCoGpeGTGwGRRo)Zfz7iTpMwhjN56iBcFXdu5Aj1V8T1UPg0oc08ISDKVn9fNd4dbyliViBpQB6b(mxhPqa3XBXdbmrrlZ1r2eojaUfBanViBh5BtFX5a(qa2cYlY2J6MEGpPGqEr2osoS)D8S0(Hawdz8I)4kadnhnViBh5BtFX5a(qa2cYfWAiRZRJ0xCoGpeGTGJ3IhFGb5pUcWO7yeZmzkBb9CTdHzhW)EaxKwplbOZOrtatu0YCDKnHtcGBXgmgnViBh5BtFX5a(qa2cYfWAiRZltpWNuqiNb8I9BbV5GhnViBh5BtFX5a(qa2cYfWAiRZltpWhxLmEiYVWGSkhVfpirazH50skiKZaEX(TG3CWBbUU68PBY0n7dmi)XvagDhgIMxKTJ8TPV4CaFiaBb5cynK15LPh4peMDa)7bCroElEiGjkAn3qgV1dV93ICJUJtZeWefTmxhzt4Ka42FlYTZhNMjGjkAzUoYMWhcZoWYcZ5SpWG8hxby0DyiAEr2oY3M(IZb8HaSfKlG1qwNxMEGpUkz8qKFHbzvoElE8bgK)4kaJUJrGMxKTJ8TPV4CaFiaBb5cynK15LPh4tkiKxKTJKd7FhplTFiG1qgV4pUcWKuJ6GVJuA0jdoz6MCAY9SNm80ejL5cKDE9sQP99)uZOPfJM6osqkKIECos16HaSiLyaqQrQbGtcTqTJuifWNgSg4mK6dTJuf2g6ADgsrWv5L)w08P(oDKAeJeKAAnFSHHaSodPkY2rIuJuDMoGZCDK)iLfnhnFArpeG1zi1iJufz7irky)7BrZLuW(3xsVKk9fNd4dbylOKEPrtK0lP8SeGotoMKIa61bDjPirazH50M(IZb8HaSf0cCD15JuNrQtgusvKTJusrkiKxKTJKd7FLuW(xEwAxsL(IZb8HaSfKlG1qwNxYvA0jj9skplbOZKJjPiGEDqxskbmrrB6lohWhcWwql2GKQiBhPKIuqiViBhjh2)kPG9V8S0UKk9fNd4dbyliViBpQlx5kPyUyHbxj9sJMiPxsvKTJus9doeYHb5MKYZsa6m5yYvA0jj9skplbOZKJjPiGEDqxsQbFTmxhzt4lEGkxBr2EuxsvKTJusneBhPCLgzOKEjLNLa0zYXKueqVoOlj1GVwMRJSj8fpqLRTiBpQlPkY2rkPWEN3RRF5kn6Us6LuEwcqNjhtsra96GUKud(AzUoYMWx8avU2IS9OUKQiBhPKsWbVdU15LCLgncj9skplbOZKJjPiGEDqxsQbFTmxhzt4lEGkxBr2EuxsvKTJusjaJGXfXa4jxPr3tsVKYZsa6m5yskcOxh0LKAWxlZ1r2e(IhOY1wKTh1Lufz7iLuInWfGrWKR0OrwsVKYZsa6m5yskcOxh0LKAki12KBDEHuZqQTax(A3w78n4S2rk6qkdnisndP(bhc5BbU89TTEagFhjsDgPojPkY2rkPyrOLR0OPtsVKYZsa6m5yskcOxh0LKYeKsatu0AUHmERhE7Vf5gsDgPUhsrJgsjGjkAzUoYMWhcZoWInGugJu0OHu)GdH8Tax((2wpaJVJePoJuNKufz7iLumxhzt4)c88AXjxPr3rsVKYZsa6m5yskcOxh0LKAlONRn9fNd4dbylO1Zsa6mKAgs9doeY3cC57BB9am(osK68bsDssvKTJusrkiKxKTJKd7FLuW(xEwAxsL(IZb8HaSfuUsJMyqj9skplbOZKJjPiGEDqxsQFWHq(wGlFFBRhGX3rIu0HutKufz7iLuKcc5fz7i5W(xjfS)LNL2LuTEagFhPCLgnzIKEjLNLa0zYXKueqVoOljfjcilmN2htRJKZCDKnHV4bQCTaxxD(i1zKAIHifnAi1uqkFAW6HbNzn3qrGZE(3xnKhI8hBWbDa4pMwhzNxsQISDKsQlqRJg4CrhEHvaMCLgn5KKEjLNLa0zYXKueqVoOljLpny9WGZSMBOiWzp)7RgYdr(Jn4Goa8htRJSZlKIgnKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoK6UgePOrdPirazH50(yADKCMRJSj8fpqLRf46QZhPoJutojPkY2rkPEmTos(On0fBpzYvA0edL0lP8SeGotoMKIa61bDjP8PbRhgCM1Cdfbo75FF1qEiYFSbh0bG)yADKDEHu0OHuMGuKiGSWCAFmTosoZ1r2e(IhOY1cCD15JuNrQ7GuZqkbmrrlZ1r2eoPGWoVSaxxD(iLXifnAiLjifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1zKAYeKAgsnfKsatu0YCDKnHtkiSZllW1vNpszmsrJgsrIaYcZP9X06i5mxhzt4lEGkxlW1vNpsrhsn5UsQISDKsksbHCgWl2Vf8MdE5knAYDL0lP8SeGotoMKIa61bDjP8PbRhgCM1Cdfbo75FF1qEiYFSbh0bG)yADKDEHu0OHuMGucyIIwgWl2Vf8MdElW1vNpsrhsrQF5BRDKAgszcsjGjkAn3qgV1dV93ICdPO7aPmePmfP2c65A7mDaN56iFRNLa0ziLPi1wqpxlZ1r2eojYhtpSDKwplbOZqQPhPmePOrdPga(O8lcZoXIRsgpe5xyqwLi1mKYeKAki1wqpxlZ1r2eojYhtpSDKwplbOZqkA0qkbmrrR5gY4TE4T)wKBifDhiLHiLPi1wqpxBNPd4mxh5B9SeGodPmgPmgPMHuMGuFGb5pUcWqQZiLHifnAiLaMOOLb8I9BbV5G3cCD15JuNrQlcdPMEK6KDKrkA0qkbmrr7fO1rdCUOdVWkaZcCD15JuNrQlcdPMEK6KDKrkJrkJLufz7iLupMwhjN56iBcFXdu5kxPrtgHKEjLNLa0zYXKueqVoOljLaMOO1Cdz8wp82FlYnKIUdK6esndPeWefTmxhzt4Ka42FlYnK68bsDcPMHucyIIwMRJSj8HWSdSSWCIuZqQFWHq(wGlFFBRhGX3rIuNrQtsQISDKsQHWSd4FpGls5knAY9K0lP8SeGotoMKIa61bDjP2c65AzrOTEwcqNHuZqkGlc8hxjaDKAgsTf4Yx72ANVbN1osrhszcsXI1YIqBbUU68rktrkdniszSKQiBhPKIfHwUsJMmYs6LuEwcqNjhtsra96GUKuFGb5pUcWqk6oqQrGu0OHuMGuFGb5pUcWqk6oqkdrQzifjcilmNwsbHCgWl2Vf8MdElW1vNpsrhsDxKAgszcsnfKAlONR9X06i5J2qxS9Kz9SeGodPOrdPirazH50(yADK8rBOl2EYSaxxD(ifDiLHiLXiLXsQISDKskCvY4Hi)cdYQuUsJMmDs6LuEwcqNjhtsra96GUKuFGb5pUcWqQZi1iqQziLaMOOL56iBcNea3(BrUHuNpqQtsQISDKsQpWG8Fb9nxUsJMChj9skplbOZKJjPiGEDqxsQpWG8hxbyi15dKYqKAgsjGjkAzUoYMWjbWTydi1mKYeKYeKIebKfMt7JP1rYzUoYMWx8avUwGRRoFK6msnXGifnAifjcilmN2htRJKZCDKnHV4bQCTaxxD(ifDi1PtiLXifnAiLaMOOL56iBcNea3(BrUHu0DGugIu0OHucyIIwMRJSjCsaClW1vNpsDgPgbsrJgsTT25BWzTJuNrQtJaPmwsvKTJusXCDKcbCLR0OtgusVKQiBhPKsOH(tcmWLZfcTGdEjLNLa0zYXKR0OttK0lP8SeGotoMKQiBhPKIuqiViBhjh2)kPG9V8S0UKsaRHmEXFCfGjx5kPgaoj0c1kPxA0ej9skplbOZKJjxPrNK0lP8SeGotoMCLgzOKEjLNLa0zYXKR0O7kPxsvKTJus9yADK8wpiP8SeGotoMCLgncj9skplbOZKJjPiGEDqxsQTGEU2othWzUoY36zjaDMKQiBhPKQZ0bCMRJ8LR0O7jPxs5zjaDMCmjfb0Rd6ssjGjkAn3qgV1dV93ICdPOdPMiPkY2rkPgcZoG)9aUiLR0OrwsVKQiBhPKAi2osjLNLa0zYXKR0OPtsVKYZsa6m5yskcOxh0LKsi(hPOrdPkY2rAzUosHaUws9lFBTJuhiLbLufz7iLumxhPqax5kxjvRhGX3rkPxA0ej9skplbOZKJjPiGEDqxsktqkbmrrR5gY4TE4T)wKBifDhi19qQziLji1hyq(JRamK6mszisrJgsna8r5xeMDILuqiNb8I9BbV5GhPOrdPeWefTMBiJ36H3(BrUHu0DGu3bPOrdPga(O8lcZoXk0q)jbg4Y5cHwWbpsrJgszcsnfKAa4JYVim7elUkz8qKFHbzvIuZqQPGudaFu(fHzpzXvjJhI8lmiRsKYyKYyKAgsnfKAa4JYVim7elUkz8qKFHbzvIuZqQPGudaFu(fHzpzXvjJhI8lmiRsKAgsjGjkAzUoYMWhcZoWYcZjszmsrJgszcsTT25BWzTJuNrkdrQziLaMOO1Cdz8wp82FlYnKIoKYGiLXifnAiLji1aWhLFry2twsbHCgWl2Vf8MdEKAgsjGjkAn3qgV1dV93ICdPOdPoHuZqQPGuBb9CTmxhzt4Kcc78Y6zjaDgszSKQiBhPKQ1dW47iLR0Ots6LuEwcqNjhtsra96GUKuKiGSWCAFmTosoZ1r2e(IhOY1cCD15JuNrQjgIu0OHutbP8PbRhgCM1Cdfbo75FF1qEiYFSbh0bG)yADKDEjPkY2rkPUaToAGZfD4fwbyYvAKHs6LuEwcqNjhtsra96GUKuMGuKiGSWCAFmTosoZ1r2e(IhOY1cCD15JuNrQ7GuZqkbmrrlZ1r2eoPGWoVSaxxD(iLXifnAiLjifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1zKAYeKAgsnfKsatu0YCDKnHtkiSZllW1vNpszmsrJgsrIaYcZP9X06i5mxhzt4lEGkxlW1vNpsrhsn5UsQISDKsksbHCgWl2Vf8MdE5kn6Us6Lufz7iLupMwhjN56iBcFXdu5kP8SeGotoMCLgncj9skplbOZKJjPiGEDqxsQpWG8hxbyifDhi1iKufz7iLu4QKXdr(fgKvPCLgDpj9skplbOZKJjPiGEDqxsQpWG8hxbyifDhiLHi1mKYeKYeKYeKAa4JYVim7jlUkz8qKFHbzvIu0OHucyIIwZnKXB9WB)Ti3qk6oqkdrkJrQziLaMOO1Cdz8wp82FlYnK6msDhKYyKIgnKIebKfMt7JP1rYzUoYMWx8avUwGRRoFK68bsDryi10JuNqkA0qkbmrrlZ1r2e(qy2bwGRRoFKIoK6IWqQPhPoHuglPkY2rkPWvjJhI8lmiRs5knAKL0lP8SeGotoMKIa61bDjPga(O8lcZoXIRsgpe5xyqwLi1mK6dmi)Xvagsr3bsnbPMHuMGucyIIwZnKXB9WB)Ti3qQZhiLHifnAi1aWhLFrywdT4QKXdr(fgKvjszmsndP(adYFCfGHuNrQ7IuZqkbmrrlZ1r2eojaUfBqsvKTJusXCDKcbCLR0OPtsVKYZsa6m5yskcOxh0LKYeKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoK6UgePMHu)GdH8Tax((2wpaJVJePoFGuNqkJrkA0qkseqwyoTpMwhjN56iBcFXdu5AbUU68rQZi1KtsQISDKsQhtRJKpAdDX2tMCLgDhj9skplbOZKJjPiGEDqxskseqwyoTpMwhjN56iBcFXdu5AbUU68rk6qQ7iPkY2rkPeAO)KadC5CHql4GxUsJMyqj9skplbOZKJjPiGEDqxsQpWG8hxbyi1zKAei1mKsatu0YCDKnHtcGB)Ti3qQZhi1jjvr2osj1hyq(VG(MlxPrtMiPxs5zjaDMCmjfb0Rd6ss9bgK)4kadPoFGugIuZqkbmrrlZ1r2eojaUfBaPMHuMGucyIIwMRJSjCsaC7Vf5gsr3bszisrJgsjGjkAzUoYMWjbWTaxxD(i15dK6IWqQPhPgHDKrkJLufz7iLumxhPqax5knAYjj9skplbOZKJjPkY2rkPyrOLue8iqNVf4Y3xA0ejLUgP5e8iqNVf4Y3xsnYskcOxh0LKc4Ia)XvcqxUsJMyOKEjLNLa0zYXKufz7iLuKcc5fz7i5W(xjfS)LNL2LucynKXl(JRam5kxjv6lohWhcWwqUawdzDEjPxA0ej9skplbOZKJjPiGEDqxsQpWG8hxbyifDhi1iqQziLji1uqQTGEU2HWSd4FpGlsRNLa0zifnAiLaMOOL56iBcNea3InGuglPkY2rkPsFX5a(qa2ckxPrNK0lPkY2rkPifeYzaVy)wWBo4LuEwcqNjhtUsJmusVKYZsa6m5yskcOxh0LKIebKfMtlPGqod4f73cEZbVf46QZhPOdPMmDi1mK6dmi)Xvagsr3bszOKQiBhPKcxLmEiYVWGSkLR0O7kPxs5zjaDMCmjfb0Rd6ssjGjkAn3qgV1dV93ICdPO7aPoHuZqkbmrrlZ1r2eojaU93ICdPoFGuNqQziLaMOOL56iBcFim7allmNi1mK6dmi)Xvagsr3bszOKQiBhPKAim7a(3d4IuUsJgHKEjLNLa0zYXKueqVoOlj1hyq(JRamKIUdKAesQISDKskCvY4Hi)cdYQuUsJUNKEjLNLa0zYXKufz7iLuKcc5fz7i5W(xjfS)LNL2LucynKXl(JRam5kxjLawdz8I)4katsV0Ojs6Lufz7iLuFGb5)c6BUKYZsa6m5yYvA0jj9sQISDKsQhxXcZCHaUskplbOZKJjx5kPsFX5a(qa2cYlY2J6s6LgnrsVKQiBhPKsOH(tcmWLZfcTGdEjLNLa0zYXKR0Ots6LuEwcqNjhtsra96GUKuKiGSWCAFmTosoZ1r2e(IhOY1cCD15JuNrQjgIu0OHutbP8PbRhgCM1Cdfbo75FF1qEiYFSbh0bG)yADKDEjPkY2rkPUaToAGZfD4fwbyYvAKHs6LuEwcqNjhtsra96GUKuKiGSWCAFmTosoZ1r2e(IhOY1cCD15Ju0Hu31GifnAifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1zKAYjjvr2osj1JP1rYhTHUy7jtUsJURKEjLNLa0zYXKueqVoOljLjifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1zK6oi1mKsatu0YCDKnHtkiSZllW1vNpszmsrJgszcsrIaYcZP9X06i5mxhzt4lEGkxlW1vNpsDgPMmbPMHutbPeWefTmxhzt4Kcc78YcCD15JugJu0OHuKiGSWCAFmTosoZ1r2e(IhOY1cCD15Ju0HutURKQiBhPKIuqiNb8I9BbV5GxUsJgHKEjvr2osjLqd9NeyGlNleAbh8skplbOZKJjxPr3tsVKYZsa6m5yskcOxh0LK6dmi)XvagsDGutqQziLjifjcilmNwsbHCgWl2Vf8MdElW1vNpsDgPkY2rAFCflmZfc4Aj1V8T1osrJgszcsTf0Z1k0q)jbg4Y5cHwWbV1Zsa6mKAgsrIaYcZPvOH(tcmWLZfcTGdElW1vNpsDgPkY2rAFCflmZfc4Aj1V8T1oszmszSKQiBhPKIuqiViBhjh2)kPG9V8S0UKsaRHmEXFCfGjxPrJSKEjLNLa0zYXKueqVoOljLjiLjifjcilmNwsbHCgWl2Vf8MdElW1vNpsrhsvKTJ0YCDKcbCTK6x(2AhPmgPMHuMGuKiGSWCAjfeYzaVy)wWBo4TaxxD(ifDivr2os7JRyHzUqaxlP(LVT2rkJrkJrQzifjcilmN20xCoGpeGTGwGRRoFKIoKYeKAY9gbszksvKTJ0IRsgpe5xyqwLws9lFBTJuglPkY2rkPWvjJhI8lmiRs5knA6K0lP8SeGotoMKIa61bDjPeWefTPV4CaFiaBbTaxxD(i1zKAei1mK6dmi)XvagsDGugusvKTJus9yADKCMRJSj8fpqLRCLgDhj9skplbOZKJjPiGEDqxskbmrrB6lohWhcWwqlW1vNpsDgPkY2rAFmTosoZ1r2e(IhOY1sQF5BRDKYuKYG2riPkY2rkPEmTosoZ1r2e(IhOYvUsJMyqj9skplbOZKJjPiGEDqxskbmrrlZ1r2eojaUfBqsvKTJusXCDKcbCLR0OjtK0lP8SeGotoMKQiBhPKIuqiViBhjh2)kPG9V8S0UKsaRHmEXFCfGjx5kxjvHT4cGKIQ13p5kxPe]] )

    
end
