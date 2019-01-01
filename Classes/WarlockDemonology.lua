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


    spec:RegisterPack( "Demonology", 20190101.0911, [[dCepcbqifjEesv1Muu(KcfYOOioffQvPIcVII0SuO6wivLDrPFbv1WqQYXueltL4zuittfLUMcL2MkQ8nfjzCQOOZPivRtHcMNkY9uH9Hu5GQOQQfQq6HQOQmrfk6IQOQYhvKuPtQiL0kvuntfjvTtkOFQiPIHQIQSufjLNIKPsbUQIuIVQiLAVe9xunysoSKftWJrmzuUmvBMqFwLA0qLtl1RvjnBq3Mu7w0VfgUcoUIuSCGNRQPR01HY2vi(of14vOqDEOkZhPSFilNinqsXQ1LgEHEtMo9MqVjw6n9jtMCwj1I3GlPgkY162LuzPDj1y66idyCJNKAOWdgftAGK6dmaXLu42D4hd4J)DV4WeSKqJ)3AmyTDKeqjU4)TMGVameWxqSOpMpc(dGqSH(J)5b8Pw1Sh)ZBQXN2fagKR8X01rgW4gp73AIKsaRH70AkfKuSADPHxO3KZCYfJON9YKlNts9dorA4LZDojfUMX8ukiPy(tKu0psnMUoYag34Hut7cadYv0C6hPWT7WpgWh)7EXHjyjHg)V1yWA7ijGsCX)BnbFbyiGVGyrFmFe8haHyd9h)Zd4tTQzp(N3uJpTlamix5JPRJmGXnE2V1e0C6hPgtN4AbhGugrVXrQl0BYzIu0hsDzYy4IrO5O50psD(Wv5T)Jb0C6hPOpKIAWHqKAQpixTO50psrFi10Y7iLaMOOn9fNd4dbylOfBaP68xVyiviIuaxxD25nsD(gtKABTJuIbaPm0xCoaPoVaSfePkY2J4i1aU6DlAo9Ju0hsn1jH4HuaNeATNmKAmDDKcbCrQbGtFKqluls1IivViv)ivN)w5IuM84cmidPgaHqjaXdP(THqKcxbyK6xJTO50psrFi15fMDasr1d4IePkimm7mKAa40hj0c1IuBGudGGGuD(BLlsnMUosHaUwj1aieBOlPOFKAmDDKbmUXdPM2fagKRO50psHB3HFmGp(39IdtWscn(FRXG12rsaL4I)3Ac(cWqaFbXI(y(i4pacXg6p(NhWNAvZE8pVPgFAxayqUYhtxhzaJB8SFRjO50psnMoX1coaPmIEJJuxO3KZePOpK6YKXWfJqZrZPFK68HRYB)hdO50psrFif1GdHi1uFqUArZPFKI(qQPL3rkbmrrB6lohWhcWwql2as15VEXqQqePaUU6SZBK68nMi12AhPedaszOV4CasDEbylisvKThXrQbC17w0C6hPOpKAQtcXdPaoj0Apzi1y66ifc4IudaN(iHwOwKQfrQErQ(rQo)TYfPm5XfyqgsnacHsaIhs9BdHifUcWi1VgBrZPFKI(qQZlm7aKIQhWfjsvqyy2zi1aWPpsOfQfP2aPgabbP683kxKAmDDKcbCTO5O50psD(ng7eS1ziLGlgahPiHwOwKsWV78Ti15pH4d7JuzK0hUcOfXGivr2oYhPIeINfnViBh5Bhaoj0c1EicR)kAEr2oY3oaCsOfQ10d8fJGHMxKTJ8TdaNeAHAn9a)c7w75wBhjAEr2oY3oaCsOfQ10d8FmTos(GVO5fz7iF7aWjHwOwtpWVZ0bCMRJ8hVfp2c65A7mDaN56iFRNLa0zO5fz7iF7aWjHwOwtpWFim7a(3d4IC8w8qatu0AUHmERhE7Vf5kDtqZlY2r(2bGtcTqTMEG)qSDKO5fz7iF7aWjHwOwtpWN56ifc4oElEie)tJwr2oslZ1rkeW1sQF5BR9d6HMJMt)i153yStWwNHu(ioapKABTJulohPkYgaKQFKQgPAyjaDlAEr2oY)4hCiKddYv08ISDKVPh4peBh54T4XGVwMRJSj8fpqLRTiBpIJMxKTJ8n9aFS35966F8w8yWxlZ1r2e(IhOY1wKThXrZlY2r(MEGVGdEhCTZ7XBXJbFTmxhzt4lEGkxBr2EehnViBh5B6b(cWiyCrmaEJ3Ihd(AzUoYMWx8avU2IS9ioAEr2oY30d8fBGlaJGnElEm4RL56iBcFXdu5AlY2J4O5fz7iFtpWNfHE8w8ykBtU259STa3(A3w78n4S2PZi6n7hCiKVf423326by8DKNUGMxKTJ8n9aFMRJSj8FbEEV4gVfpmratu0AUHmERhE7Vf56PZrJMaMOOL56iBcFim7al2GX0O9doeY3cC77BB9am(oYtxqZlY2r(MEGpPGqEr2osoS)D8S0(r6lohWhcWwWXBXJTGEU20xCoGpeGTGwplbOZM9doeY3cC77BB9am(oYthxqZlY2r(MEGpPGqEr2osoS)D8S0(rRhGX3roElE8doeY3cC77BB9am(os6MGMxKTJ8n9a)BqRJg4CrhEJva24T4bjcilmN2htRJKZCDKnHV4bQCTaxxD(NMyenAtXNgSEyWz2jgDXOZnD08ISDKVPh4)yADK8rAOl2EYgVfp8PbRhgCMDIrxm6CtNgnseqwyoTpMwhjN56iBcFXdu5AbUU68P7S0JgnseqwyoTpMwhjN56iBcFXdu5AbUU68pn5cAEr2oY30d8jfeYzaVy)wWRo4hVfp8PbRhgCMDIrxm6CtNgntirazH50(yADKCMRJSj8fpqLRf46QZ)00NjGjkAzUoYMWjfe25Tf46QZ3yA0mHebKfMt7JP1rYzUoYMWx8avUwGRRo)ttMmBkcyIIwMRJSjCsbHDEBbUU68nMgnseqwyoTpMwhjN56iBcFXdu5AbUU68PBYzrZlY2r(MEG)JP1rYzUoYMWx8avUJ3Ih(0G1ddoZoXOlgDUPtJMjcyIIwgWl2Vf8QdElW1vNpDK6x(2AFMjcyIIwZnKXB9WB)TixP7Wit3c65A7mDaN56iFRNLa0zMUf0Z1YCDKnHtI8X0dBhP1Zsa6SZWiA0ga(i8BcZoXIRsgpe53yqwLZmzkBb9CTmxhzt4KiFm9W2rA9SeGoJgnbmrrR5gY4TE4T)wKR0DyKPBb9CTDMoGZCDKV1Zsa6mJnEMjFGb5pUcWozenAcyIIwgWl2Vf8QdElW1vN)PBc7mUyNkA0eWefT3GwhnW5Io8gRamlW1vN)PBc7mUyNkJngnViBh5B6b(dHzhW)EaxKJ3IhcyIIwZnKXB9WB)TixP74YmbmrrlZ1r2eojaU93IC90XLzcyIIwMRJSj8HWSdSSWCo7hCiKVf423326by8DKNUGMxKTJ8n9aFwe6XBXJTGEUwweARNLa0zZaUiWFCLa0NTf42x72ANVbN1oDMWI1YIqBbUU68n1i6zmAEr2oY30d8XvjJhI8BmiRYXBXJpWG8hxby0DmwA0m5dmi)XvagDhgnJebKfMtlPGqod4f73cE1bVf46QZNUZoZKPSf0Z1(yADK8rAOl2EYSEwcqNrJgjcilmN2htRJKpsdDX2tMf46QZNoJm2y08ISDKVPh4)bgK)lOV6J3IhFGb5pUcWon2zcyIIwMRJSjCsaC7Vf56PJlO5fz7iFtpWN56ifc4oElE8bgK)4ka70HrZeWefTmxhzt4Ka4wSHzMycjcilmN2htRJKZCDKnHV4bQCTaxxD(NMqpA0irazH50(yADKCMRJSj8fpqLRf46QZNUlxmMgnbmrrlZ1r2eojaU93ICLUdJOrtatu0YCDKnHtcGBbUU68pnwA02w78n4S2pDzSgJMxKTJ8n9aFHg6pjWa3oxi0co4rZlY2r(MEGpPGqEr2osoS)D8S0(Hawdz8I)4kadnhnViBh5BfWAiJx8hxbyhFGb5)c6RoAEr2oY3kG1qgV4pUcWm9a)hxXcZCHaUO5O5fz7iFBRhGX3rE06by8DKJ3IhMiGjkAn3qgV1dV93ICLUJZnZKpWG8hxbyNmIgTbGpc)MWStSKcc5mGxSFl4vh80OjGjkAn3qgV1dV93ICLUJPtJ2aWhHFty2jwHg6pjWa3oxi0co4PrZKPma8r43eMDIfxLmEiYVXGSkNnLbGpc)MWSxS4QKXdr(ngKvPXgpBkdaFe(nHzNyXvjJhI8BmiRYztza4JWVjm7flUkz8qKFJbzvotatu0YCDKnHpeMDGLfMtJPrZKT1oFdoR9tgntatu0AUHmERhE7Vf5kD0ZyA0mza4JWVjm7flPGqod4f73cE1b)mbmrrR5gY4TE4T)wKR0Dz2u2c65AzUoYMWjfe25T1Zsa6mJrZlY2r(2wpaJVJ00d8VbToAGZfD4nwbyJ3IhKiGSWCAFmTosoZ1r2e(IhOY1cCD15FAIr0OnfFAW6HbNzNy0fJo30rZlY2r(2wpaJVJ00d8jfeYzaVy)wWRo4hVfpmHebKfMt7JP1rYzUoYMWx8avUwGRRo)ttFMaMOOL56iBcNuqyN3wGRRoFJPrZeseqwyoTpMwhjN56iBcFXdu5AbUU68pnzYSPiGjkAzUoYMWjfe25Tf46QZ3yA0irazH50(yADKCMRJSj8fpqLRf46QZNUjNfnViBh5BB9am(ostpW)X06i5mxhzt4lEGkx08ISDKVT1dW47in9aFCvY4Hi)gdYQC8w84dmi)XvagDhJfnViBh5BB9am(ostpWhxLmEiYVXGSkhVfp(adYFCfGr3HrZmXetga(i8BcZEXIRsgpe53yqwL0OjGjkAn3qgV1dV93ICLUdJmEMaMOO1Cdz8wp82FlY1tt3yA0irazH50(yADKCMRJSj8fpqLRf46QZ)0XnHDgxOrtatu0YCDKnHpeMDGf46QZNUBc7mUymAEr2oY326by8DKMEGpZ1rkeWD8w8ya4JWVjm7elUkz8qKFJbzvo7dmi)XvagDhtMzIaMOO1Cdz8wp82FlY1thgrJ2aWhHFtywJS4QKXdr(ngKvPXZ(adYFCfGD6SZeWefTmxhzt4Ka4wSb08ISDKVT1dW47in9a)htRJKpsdDX2t24T4HjKiGSWCAFmTosoZ1r2e(IhOY1cCD15t3zP3SFWHq(wGBFFBRhGX3rE64IX0OrIaYcZP9X06i5mxhzt4lEGkxlW1vN)PjxqZlY2r(2wpaJVJ00d8fAO)KadC7CHql4GF8w8GebKfMt7JP1rYzUoYMWx8avUwGRRoF6MoAEr2oY326by8DKMEG)hyq(VG(QpElE8bgK)4ka70yNjGjkAzUoYMWjbWT)wKRNoUGMxKTJ8TTEagFhPPh4ZCDKcbChVfp(adYFCfGD6WOzcyIIwMRJSjCsaCl2WmteWefTmxhzt4Ka42FlYv6omIgnbmrrlZ1r2eojaUf46QZ)0XnHDgJ1ovgJMxKTJ8TTEagFhPPh4ZIqpobpc05BbU99pMmUUgJ5e8iqNVf423)yQgVfpaUiWFCLa0rZlY2r(2wpaJVJ00d8jfeYlY2rYH9VJNL2peWAiJx8hxbyO5O5fz7iFB6lohWhcWwWdsbH8ISDKCy)74zP9J0xCoGpeGTGCbSgY68E8w8GebKfMtB6lohWhcWwqlW1vN)Pl0dnViBh5BtFX5a(qa2cA6b(Kcc5fz7i5W(3XZs7hPV4CaFiaBb5fz7r8XBXdbmrrB6lohWhcWwql2aAoAEr2oY3M(IZb8HaSfKxKThXpeAO)KadC7CHql4GhnViBh5BtFX5a(qa2cYlY2J4MEG)nO1rdCUOdVXkaB8w8GebKfMt7JP1rYzUoYMWx8avUwGRRo)ttmIgTP4tdwpm4m7eJUy05MoAEr2oY3M(IZb8HaSfKxKThXn9a)htRJKpsdDX2t24T4bjcilmN2htRJKZCDKnHV4bQCTaxxD(0Dw6rJgjcilmN2htRJKZCDKnHV4bQCTaxxD(NMCbnViBh5BtFX5a(qa2cYlY2J4MEGpPGqod4f73cE1b)4T4HjKiGSWCAFmTosoZ1r2e(IhOY1cCD15FA6ZeWefTmxhzt4Kcc782cCD15BmnAMqIaYcZP9X06i5mxhzt4lEGkxlW1vN)PjtMnfbmrrlZ1r2eoPGWoVTaxxD(gtJgjcilmN2htRJKZCDKnHV4bQCTaxxD(0n5SO5fz7iFB6lohWhcWwqEr2Ee30d8fAO)KadC7CHql4GhnViBh5BtFX5a(qa2cYlY2J4MEGpPGqEr2osoS)D8S0(Hawdz8I)4kaB8w84dmi)Xva2XKzMqIaYcZPLuqiNb8I9BbV6G3cCD15FQiBhP9XvSWmxiGRLu)Y3w70OzYwqpxRqd9NeyGBNleAbh8wplbOZMrIaYcZPvOH(tcmWTZfcTGdElW1vN)PISDK2hxXcZCHaUws9lFBTBSXO5fz7iFB6lohWhcWwqEr2Ee30d8XvjJhI8BmiRYXBXdtmHebKfMtlPGqod4f73cE1bVf46QZNUISDKwMRJuiGRLu)Y3w7gpZeseqwyoTKcc5mGxSFl4vh8wGRRoF6kY2rAFCflmZfc4Aj1V8T1UXgpJebKfMtB6lohWhcWwqlW1vNpDMm5CJ10ISDKwCvY4Hi)gdYQ0sQF5BRDJrZlY2r(20xCoGpeGTG8IS9iUPh4)yADKCMRJSj8fpqL74T4HaMOOn9fNd4dbylOf46QZ)0yN9bgK)4ka7GEO5fz7iFB6lohWhcWwqEr2Ee30d8FmTosoZ1r2e(IhOYD8w8qatu0M(IZb8HaSf0cCD15FQiBhP9X06i5mxhzt4lEGkxlP(LVT2nLE2XIMxKTJ8TPV4CaFiaBb5fz7rCtpWN56ifc4oElEiGjkAzUoYMWjbWTydO5fz7iFB6lohWhcWwqEr2Ee30d8jfeYlY2rYH9VJNL2peWAiJx8hxbyO5O5fz7iFB6lohWhcWwqUawdzDEFK(IZb8HaSfC8w84dmi)XvagDhJDMjtzlONRDim7a(3d4I06zjaDgnAcyIIwMRJSjCsaCl2GXO5fz7iFB6lohWhcWwqUawdzDEB6b(Kcc5mGxSFl4vh8O5fz7iFB6lohWhcWwqUawdzDEB6b(4QKXdr(ngKv54T4bjcilmNwsbHCgWl2Vf8QdElW1vNpDtoZzFGb5pUcWO7Wi08ISDKVn9fNd4dbylixaRHSoVn9a)HWSd4FpGlYXBXdbmrrR5gY4TE4T)wKR0DCzMaMOOL56iBcNea3(BrUE64YmbmrrlZ1r2e(qy2bwwyoN9bgK)4kaJUdJqZlY2r(20xCoGpeGTGCbSgY6820d8XvjJhI8BmiRYXBXJpWG8hxby0Dmw08ISDKVn9fNd4dbylixaRHSoVn9aFsbH8ISDKCy)74zP9dbSgY4f)XvaMKAeh8DKsdVqVjN5Klgrp7LjxoNKYCbYoVFj10(8FQz40QHtDhdifszaohPA9qawKsmai1y0aWjHwO2XiKc4tdwdCgs9H2rQcBdDTodPi4Q82FlA(uFNosn2XasnTKp2WqawNHufz7irQXOothWzUoYFmYIMJMpTQhcW6mKAQqQISDKifS)9TO5sQcBXfajfvRpFsky)7lnqs16by8DKsdKgorAGKYZsa6m5OskcOxh0LKYeKsatu0AUHmERhE7Vf5ksr3bsDoKAgszcs9bgK)4kadPoHugHu0OHudaFe(nHzNyjfeYzaVy)wWRo4rkA0qkbmrrR5gY4TE4T)wKRifDhi10rkA0qQbGpc)MWStScn0FsGbUDUqOfCWJu0OHuMGutbPga(i8BcZoXIRsgpe53yqwLi1mKAki1aWhHFty2lwCvY4Hi)gdYQePmgPmgPMHutbPga(i8BcZoXIRsgpe53yqwLi1mKAki1aWhHFty2lwCvY4Hi)gdYQePMHucyIIwMRJSj8HWSdSSWCIugJu0OHuMGuBRD(gCw7i1jKYiKAgsjGjkAn3qgV1dV93ICfPOdPOhszmsrJgszcsna8r43eM9ILuqiNb8I9BbV6GhPMHucyIIwZnKXB9WB)Tixrk6qQli1mKAki1wqpxlZ1r2eoPGWoVTEwcqNHuglPkY2rkPA9am(os5kn8I0ajLNLa0zYrLueqVoOljfjcilmN2htRJKZCDKnHV4bQCTaxxD(i1jKAIrifnAi1uqkFAW6HbNzn3qrGZE(33nKhI8hBWbDa4pMwhzN3sQISDKsQBqRJg4CrhEJvaMCLgAK0ajLNLa0zYrLueqVoOljLjifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1jKA6i1mKsatu0YCDKnHtkiSZBlW1vNpszmsrJgszcsrIaYcZP9X06i5mxhzt4lEGkxlW1vNpsDcPMmbPMHutbPeWefTmxhzt4Kcc782cCD15JugJu0OHuKiGSWCAFmTosoZ1r2e(IhOY1cCD15Ju0HutoRKQiBhPKIuqiNb8I9BbV6GxUsdpR0ajvr2osj1JP1rYzUoYMWx8avUskplbOZKJkxPHJvAGKYZsa6m5OskcOxh0LK6dmi)Xvagsr3bsnwjvr2osjfUkz8qKFJbzvkxPHNtAGKYZsa6m5OskcOxh0LK6dmi)Xvagsr3bszesndPmbPmbPmbPga(i8BcZEXIRsgpe53yqwLifnAiLaMOO1Cdz8wp82FlYvKIUdKYiKYyKAgsjGjkAn3qgV1dV93ICfPoHuthPmgPOrdPirazH50(yADKCMRJSj8fpqLRf46QZhPoDGu3egsDgi1fKIgnKsatu0YCDKnHpeMDGf46QZhPOdPUjmK6mqQliLXsQISDKskCvY4Hi)gdYQuUsdNkPbskplbOZKJkPiGEDqxsQbGpc)MWStS4QKXdr(ngKvjsndP(adYFCfGHu0DGutqQziLjiLaMOO1Cdz8wp82FlYvK60bszesrJgsna8r43eM1ilUkz8qKFJbzvIugJuZqQpWG8hxbyi1jK6Si1mKsatu0YCDKnHtcGBXgKufz7iLumxhPqax5kn8mLgiP8SeGotoQKIa61bDjPmbPirazH50(yADKCMRJSj8fpqLRf46QZhPOdPol9qQzi1p4qiFlWTVVT1dW47irQthi1fKYyKIgnKIebKfMt7JP1rYzUoYMWx8avUwGRRoFK6esn5IKQiBhPK6X06i5J0qxS9KjxPHtxAGKYZsa6m5OskcOxh0LKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoKA6sQISDKskHg6pjWa3oxi0co4LR0Wj0tAGKYZsa6m5OskcOxh0LK6dmi)XvagsDcPglsndPeWefTmxhzt4Ka42FlYvK60bsDrsvKTJus9bgK)lOV6YvA4KjsdKuEwcqNjhvsra96GUKuFGb5pUcWqQthiLri1mKsatu0YCDKnHtcGBXgqQziLjiLaMOOL56iBcNea3(BrUIu0DGugHu0OHucyIIwMRJSjCsaClW1vNpsD6aPUjmK6mqQXANkKYyjvr2osjfZ1rkeWvUsdNCrAGKYZsa6m5OsQISDKskweAjfbpc05BbU99LgorsPRXyobpc05BbU99LutLKIa61bDjPaUiWFCLa0LR0Wjgjnqs5zjaDMCujvr2osjfPGqEr2osoS)vsb7F5zPDjLawdz8I)4katUYvsXCXcdUsdKgorAGKQiBhPK6hCiKddYvjLNLa0zYrLR0WlsdKuEwcqNjhvsra96GUKud(AzUoYMWx8avU2IS9iUKQiBhPKAi2os5kn0iPbskplbOZKJkPiGEDqxsQbFTmxhzt4lEGkxBr2EexsvKTJusH9oVxx)YvA4zLgiP8SeGotoQKIa61bDjPg81YCDKnHV4bQCTfz7rCjvr2osjLGdEhCTZB5knCSsdKuEwcqNjhvsra96GUKud(AzUoYMWx8avU2IS9iUKQiBhPKsagbJlIbWtUsdpN0ajLNLa0zYrLueqVoOlj1GVwMRJSj8fpqLRTiBpIlPkY2rkPeBGlaJGjxPHtL0ajLNLa0zYrLueqVoOlj1uqQTjx78gPMHuBbU91UT25BWzTJu0HugrpKAgs9doeY3cC77BB9am(osK6esDrsvKTJusXIqlxPHNP0ajLNLa0zYrLueqVoOljLjiLaMOO1Cdz8wp82FlYvK6esDoKIgnKsatu0YCDKnHpeMDGfBaPmgPOrdP(bhc5BbU99TTEagFhjsDcPUiPkY2rkPyUoYMW)f459ItUsdNU0ajLNLa0zYrLufz7iLuKcc5fz7i5W(xjfb0Rd6ssTf0Z1M(IZb8HaSf06zjaDgsndP(bhc5BbU99TTEagFhjsD6aPUiPG9V8S0UKk9fNd4dbylOCLgoHEsdKuEwcqNjhvsvKTJusrkiKxKTJKd7FLueqVoOlj1p4qiFlWTVVT1dW47irk6qQjsky)lplTlPA9am(os5knCYePbskplbOZKJkPiGEDqxskseqwyoTpMwhjN56iBcFXdu5AbUU68rQti1eJqkA0qQPGu(0G1ddoZAUHIaN98VVBipe5p2Gd6aWFmToYoVLufz7iLu3GwhnW5Io8gRam5knCYfPbskplbOZKJkPiGEDqxskFAW6HbNzn3qrGZE(33nKhI8hBWbDa4pMwhzN3ifnAifjcilmN2htRJKZCDKnHV4bQCTaxxD(ifDi1zPhsrJgsrIaYcZP9X06i5mxhzt4lEGkxlW1vNpsDcPMCrsvKTJus9yADK8rAOl2EYKR0Wjgjnqs5zjaDMCujfb0Rd6ss5tdwpm4mR5gkcC2Z)(UH8qK)ydoOda)X06i78gPOrdPmbPirazH50(yADKCMRJSj8fpqLRf46QZhPoHuthPMHucyIIwMRJSjCsbHDEBbUU68rkJrkA0qktqkseqwyoTpMwhjN56iBcFXdu5AbUU68rQti1Kji1mKAkiLaMOOL56iBcNuqyN3wGRRoFKYyKIgnKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoKAYzLufz7iLuKcc5mGxSFl4vh8YvA4KZknqs5zjaDMCujfb0Rd6ss5tdwpm4mR5gkcC2Z)(UH8qK)ydoOda)X06i78gPOrdPmbPeWefTmGxSFl4vh8wGRRoFKIoKIu)Y3w7i1mKYeKsatu0AUHmERhE7Vf5ksr3bszeszksTf0Z12z6aoZ1r(wplbOZqktrQTGEUwMRJSjCsKpMEy7iTEwcqNHuNbszesrJgsna8r43eMDIfxLmEiYVXGSkrQziLji1uqQTGEUwMRJSjCsKpMEy7iTEwcqNHu0OHucyIIwZnKXB9WB)Tixrk6oqkJqktrQTGEU2othWzUoY36zjaDgszmszmsndPmbP(adYFCfGHuNqkJqkA0qkbmrrld4f73cE1bVf46QZhPoHu3egsDgi1f7uHu0OHucyII2BqRJg4CrhEJvaMf46QZhPoHu3egsDgi1f7uHugJuglPkY2rkPEmTosoZ1r2e(IhOYvUsdNmwPbskplbOZKJkPiGEDqxskbmrrR5gY4TE4T)wKRifDhi1fKAgsjGjkAzUoYMWjbWT)wKRi1PdK6csndPeWefTmxhzt4dHzhyzH5ePMHu)GdH8Ta3((2wpaJVJePoHuxKufz7iLudHzhW)EaxKYvA4KZjnqs5zjaDMCujfb0Rd6ssTf0Z1YIqB9SeGodPMHuaxe4pUsa6i1mKAlWTV2T1oFdoRDKIoKYeKIfRLfH2cCD15JuMIugrpKYyjvr2osjflcTCLgozQKgiP8SeGotoQKIa61bDjP(adYFCfGHu0DGuJfPOrdPmbP(adYFCfGHu0DGugHuZqkseqwyoTKcc5mGxSFl4vh8wGRRoFKIoK6Si1mKYeKAki1wqpx7JP1rYhPHUy7jZ6zjaDgsrJgsrIaYcZP9X06i5J0qxS9KzbUU68rk6qkJqkJrkJLufz7iLu4QKXdr(ngKvPCLgo5mLgiP8SeGotoQKIa61bDjP(adYFCfGHuNqQXIuZqkbmrrlZ1r2eojaU93ICfPoDGuxKufz7iLuFGb5)c6RUCLgoz6sdKuEwcqNjhvsra96GUKuFGb5pUcWqQthiLri1mKsatu0YCDKnHtcGBXgqQziLjiLjifjcilmN2htRJKZCDKnHV4bQCTaxxD(i1jKAc9qkA0qkseqwyoTpMwhjN56iBcFXdu5AbUU68rk6qQlxqkJrkA0qkbmrrlZ1r2eojaU93ICfPO7aPmcPOrdPeWefTmxhzt4Ka4wGRRoFK6esnwKIgnKABTZ3GZAhPoHuxglszSKQiBhPKI56ifc4kxPHxON0ajvr2osjLqd9NeyGBNleAbh8skplbOZKJkxPHxMinqs5zjaDMCujvr2osjfPGqEr2osoS)vsb7F5zPDjLawdz8I)4katUYvsnaCsOfQvAG0WjsdKuEwcqNjhvUsdVinqs5zjaDMCu5kn0iPbskplbOZKJkxPHNvAGKQiBhPK6X06i5d(kP8SeGotoQCLgowPbskplbOZKJkPiGEDqxsQTGEU2othWzUoY36zjaDMKQiBhPKQZ0bCMRJ8LR0WZjnqs5zjaDMCujfb0Rd6ssjGjkAn3qgV1dV93ICfPOdPMiPkY2rkPgcZoG)9aUiLR0WPsAGKQiBhPKAi2osjLNLa0zYrLR0WZuAGKYZsa6m5OskcOxh0LKsi(hPOrdPkY2rAzUosHaUws9lFBTJuhif9Kufz7iLumxhPqax5kxjv6lohWhcWwqEr2EexAG0WjsdKufz7iLucn0FsGbUDUqOfCWlP8SeGotoQCLgErAGKYZsa6m5OskcOxh0LKIebKfMt7JP1rYzUoYMWx8avUwGRRoFK6esnXiKIgnKAkiLpny9WGZSMBOiWzp)77gYdr(Jn4Goa8htRJSZBjvr2osj1nO1rdCUOdVXkatUsdnsAGKYZsa6m5OskcOxh0LKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoK6S0dPOrdPirazH50(yADKCMRJSj8fpqLRf46QZhPoHutUiPkY2rkPEmTos(in0fBpzYvA4zLgiP8SeGotoQKIa61bDjPmbPirazH50(yADKCMRJSj8fpqLRf46QZhPoHuthPMHucyIIwMRJSjCsbHDEBbUU68rkJrkA0qktqkseqwyoTpMwhjN56iBcFXdu5AbUU68rQti1Kji1mKAkiLaMOOL56iBcNuqyN3wGRRoFKYyKIgnKIebKfMt7JP1rYzUoYMWx8avUwGRRoFKIoKAYzLufz7iLuKcc5mGxSFl4vh8YvA4yLgiPkY2rkPeAO)KadC7CHql4Gxs5zjaDMCu5kn8CsdKuEwcqNjhvsvKTJusrkiKxKTJKd7FLueqVoOlj1hyq(JRamK6aPMGuZqktqkseqwyoTKcc5mGxSFl4vh8wGRRoFK6esvKTJ0(4kwyMleW1sQF5BRDKIgnKYeKAlONRvOH(tcmWTZfcTGdERNLa0zi1mKIebKfMtRqd9NeyGBNleAbh8wGRRoFK6esvKTJ0(4kwyMleW1sQF5BRDKYyKYyjfS)LNL2LucynKXl(JRam5knCQKgiP8SeGotoQKIa61bDjPmbPmbPirazH50skiKZaEX(TGxDWBbUU68rk6qQISDKwMRJuiGRLu)Y3w7iLXi1mKYeKIebKfMtlPGqod4f73cE1bVf46QZhPOdPkY2rAFCflmZfc4Aj1V8T1oszmszmsndPirazH50M(IZb8HaSf0cCD15Ju0HuMGuto3yrktrQISDKwCvY4Hi)gdYQ0sQF5BRDKYyjvr2osjfUkz8qKFJbzvkxPHNP0ajLNLa0zYrLueqVoOljLaMOOn9fNd4dbylOf46QZhPoHuJfPMHuFGb5pUcWqQdKIEsQISDKsQhtRJKZCDKnHV4bQCLR0WPlnqs5zjaDMCujfb0Rd6ssjGjkAtFX5a(qa2cAbUU68rQtivr2os7JP1rYzUoYMWx8avUws9lFBTJuMIu0Zowjvr2osj1JP1rYzUoYMWx8avUYvA4e6jnqs5zjaDMCujfb0Rd6ssjGjkAzUoYMWjbWTydsQISDKskMRJuiGRCLgozI0ajLNLa0zYrLufz7iLuKcc5fz7i5W(xjfS)LNL2LucynKXl(JRam5kxjv6lohWhcWwqUawdzDElnqA4ePbskplbOZKJkPiGEDqxsQpWG8hxbyifDhi1yrQziLji1uqQTGEU2HWSd4FpGlsRNLa0zifnAiLaMOOL56iBcNea3InGuglPkY2rkPsFX5a(qa2ckxPHxKgiPkY2rkPifeYzaVy)wWRo4LuEwcqNjhvUsdnsAGKYZsa6m5OskcOxh0LKIebKfMtlPGqod4f73cE1bVf46QZhPOdPMCMi1mK6dmi)Xvagsr3bszKKQiBhPKcxLmEiYVXGSkLR0WZknqs5zjaDMCujfb0Rd6ssjGjkAn3qgV1dV93ICfPO7aPUGuZqkbmrrlZ1r2eojaU93ICfPoDGuxqQziLaMOOL56iBcFim7allmNi1mK6dmi)Xvagsr3bszKKQiBhPKAim7a(3d4IuUsdhR0ajLNLa0zYrLueqVoOlj1hyq(JRamKIUdKASsQISDKskCvY4Hi)gdYQuUsdpN0ajLNLa0zYrLufz7iLuKcc5fz7i5W(xjfS)LNL2LucynKXl(JRam5kxjLawdz8I)4katAG0WjsdKufz7iLuFGb5)c6RUKYZsa6m5OYvA4fPbsQISDKsQhxXcZCHaUskplbOZKJkx5kPsFX5a(qa2cknqA4ePbskplbOZKJkPkY2rkPifeYlY2rYH9VskcOxh0LKIebKfMtB6lohWhcWwqlW1vNpsDcPUqpjfS)LNL2LuPV4CaFiaBb5cynK15TCLgErAGKYZsa6m5OsQISDKsksbH8ISDKCy)RKIa61bDjPeWefTPV4CaFiaBbTydsky)lplTlPsFX5a(qa2cYlY2J4YvUYvUYvkba]] )

    
end
