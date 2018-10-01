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


    spec:RegisterPack( "Demonology", 20180930.2258, [[dGuucbqifbpIcHnPO8jkKuJII4uuKwfcj9kfkZsHQBrHODrPFHGgMkQoMI0YarpJc10urX1qi2gcP(gfsnofHCofrwhfsmpfv3tf2hc1bPqsSqfspufLQjQIsUOIqjFurOuNufLIvQImtfrf7Kc6NuijnuesSufHQNIOPsbUQIOsFvru1Ej6VOAWKCyPwmHEmstgLlt1Mj4ZQuJgKoTKxdcZgYTj1Uf9BHHRGJRiklxvphQPR01b12vi(of14vekopcSEvuknFvY(bwovAGKK1RlneYZNorNpjJp3cjKezIohsj5sWGljhAke9TljZw7sYZY1rgO4Maj5qtakAM0ajjoGFQljHU7a2OqiH31cfw0sdnH4sdJ6TIK(TWsiU0ucfrHiHIcTrY8riC4dHc5ycjkVpX7IHjKOmX5t((rbfc(z56iduCtGfxAQKueUq7ztkfLKSEDPHqE(0j68jz85wiHKignriIKep4uPHqs0eTKeAXyEkfLKmhtLKgbqDwUoYaf3eaut((rbfcWjJaOGU7a2OqiH31cfw0sdnH4sdJ6TIK(TWsiU0ucfrHiHIcTrY8riC4dHc5ycjkVpX7IHjKOmX5t((rbfc(z56iduCtGfxAk4KrauK(W6Ar)bkJpFCGcYZNoraLrcuqcPr5mte4e4KrauNDODE7yJc4Kraugjqro4ieqn5euiSGtgbqzKa1Kl2bkrybbB6lu)5dXVnYcpauvIxVzaviauVR7kR8gOo7NfqTL2bkH4bkd9fQ)afrj(Travt3AehOgG2y3cozeaLrcugvteba170qR9KbuNLRJumqlqn8UrsdTyVavjau1cufgOQeVDUaLjyObmIbudFi2Iicak8wieqbTFgTXRPwWjJaOmsGIOeM9hOiRbOrcuncfMDgqn8UrsdTyVa1ga1WhuGQs825cuNLRJumqRvso8HqHCjPrauNLRJmqXnba1KVFuqHaCYiakO7oGnkes4DTqHfT0qtiU0WOERiPFlSeIlnLqruisOOqBKmFech(qOqoMqIY7t8UyycjktC(KVFuqHGFwUoYaf3eyXLMcozeafPpSUw0FGY4ZhhOG88PteqzKafKqAuoZebobozea1zhAN3o2OaozeaLrcuKdocbutobfcl4Kraugjqn5IDGsewqWM(c1F(q8BJSWdavL41Bgqfca176UYkVbQZ(zbuBPDGsiEGYqFH6pqruIFBeq10TgXbQbOn2TGtgbqzKaLr1eraq9on0Apza1z56ifd0cudVBK0ql2lqvcavTavHbQkXBNlqzcgAaJya1WhITiIaGcVfcbuq7NrB8AQfCYiakJeOikHz)bkYAaAKavJqHzNbudVBK0ql2lqTbqn8bfOQeVDUa1z56ifd0AbNaNmcGAI1eJtHxNbuIUq8oqrdTyVaLOFxj2cugvOuFyXavgPrcTFTamcOA6wrIbQireybNA6wrITdVtdTyVhcOgdb4ut3ksSD4DAOf7DSdcfIGbo10TIeBhENgAXEh7GWg(w752Bfj4ut3ksSD4DAOf7DSdcXWADK8bFbNA6wrITdVtdTyVJDqyLP)CMRJepEjCSnYZ1wz6pN56iXwpBrKZaNA6wrITdVtdTyVJDqio7bm0y54Txm4ut3ksSD4DAOf7DSdchITIeCQPBfj2o8on0I9o2bHdHz)54AaAKJxchIWccwZfIXl9a2I3McbXtbNA6wrITdVtdTyVJDqiZ1rkgOD8s4qewqWYCDKfLtJ3TWdGtGtgbqnXAIXPWRZakFe)jaO2s7a1c1bQMUXdufgO6r6c1Ii3co10TIeFGhCeIJckeGtnDRiXJDq4qSvKJxchd(AzUoYIYxc(oxBt3Ae)6A7)2x7wANVbNv(CJphCQPBfjESdcHXoVwxJhVeog81YCDKfLVe8DU2MU1i(112)TV2T0oFdoR85htjc4ut3ks8yhek6p2FiQ8E8s4yWxlZ1rwu(sW35AB6wJ4xxB)3(A3s78n4SYNFmLiGtnDRiXJDqOikcgxa(jy8s4yWxlZ1rwu(sW35AB6wJ4xxB)3(A3s78n4SYNFmLiGtnDRiXJDqOq9Uikc24LWXGVwMRJSO8LGVZ120TgXVU2(V91UL25BWzLp)ykraNA6wrIh7Gqwe6XlHJjSffIkVNTL25BWzLtSXNpdp4ieF7)2xST0dOaxrohsWPMUvK4XoiK56ilkhVVN3l0XlHdteHfeSMleJx6bSfVnfI5e91LiSGGL56ilkFim7VfEW0Rl8GJq8T)BFX2spGcCf5CibNA6wrIh7GqAJq8MUvKCuH3XZw7hPVq9Npe)2OXlHJTrEU20xO(ZhIFBK1Zwe5Sz4bhH4B)3(ITLEaf4kY5hqco10TIep2bH0gH4nDRi5OcVJNT2pk9akWvKJxch4bhH4B)3(ITLEaf4ksINco10TIep2bH3FPJ6DUGJUH7NnEjCqJaXcZPfdR1rYzUoYIYxc(ox776Us88PgFDnbFYGRHbNzNAmKgt0tcCQPBfjESdcXWADK8rkKluEYgVeo8jdUggCMDQXqAmrpPRlAeiwyoTyyTosoZ1rwu(sW35AFx3vIj(mNFDrJaXcZPfdR1rYzUoYIYxc(ox776Us88Pqco10TIep2bH0gH4S3BgEBee(JhVeo8jdUggCMDQXqAmrpPRltOrGyH50IH16i5mxhzr5lbFNR9DDxjE(KMjcliyzUoYIYPncv5T9DDxj20RltOrGyH50IH16i5mxhzr5lbFNR9DDxjE(0PZMGiSGGL56ilkN2iuL3231DLytVUOrGyH50IH16i5mxhzr5lbFNR9DDxjM4PNbCQPBfjESdcXWADKCMRJSO8LGVZD8s4WNm4AyWz2PgdPXe9KUUmrewqWYEVz4Trq4p2(UURetmTXlFlTpZerybbR5cX4LEaBXBtHG4dJVUgEFe(nLzNAH2jJhc8ByeRttNzcoGrCm0(zZn(6sewqWYEVz4Trq4p2(UURep)MYiQqAn6Rlrybb79x6OENl4OB4(z231DL453ugrfsRrBQPGtnDRiXJDq4qy2FoUgGg54LWHiSGG1CHy8spGT4TPqq8bKZeHfeSmxhzr504DlEBkeZpGCMiSGGL56ilkFim7VLfMZz4bhH4B)3(ITLEaf4kY5qco10TIep2bHSi0JxchBJ8CTSi0wpBrKZM9UW7yOTiYNTL25BWzLtSjSyTSi0231DL4Xm(CtbNA6wrIh7GqODY4Ha)ggX6C8s4ahWiogA)mIpiY1Lj4agXXq7Nr8HXZOrGyH50sBeIZEVz4Trq4p2(UURet8zMzYe2g55AXWADK8rkKluEYSE2IiNDDrJaXcZPfdR1rYhPqUq5jZ(UURetSXMAk4ut3ks8yheIdyehVFbHpEjCGdyehdTF2CImtewqWYCDKfLtJ3T4TPqm)asWPMUvK4XoiK56ifd0oEjCGdyehdTF28dJNjcliyzUoYIYPX7w4HzMycncelmNwmSwhjN56ilkFj47CTVR7kXZNE(1fncelmNwmSwhjN56ilkFj47CTVR7kXedjKMEDjcliyzUoYIYPX7w82uii(W4RlrybblZ1rwuonE3(UURepNixxBPD(gCw5ZHKiMco10TIep2bH0gH4nDRi5OcVJNT2peHleJ3Cm0(zGtGtnDRiXwr4cX4nhdTF2bZ1rkgOD8s4OpB9Vw3keVyXyEYHidZiND7wpBrKZMjcliyfIxSymp5qKHzKZUD77nDNnbrybblZ1rwuonE3(Et3z0iqSWCAXWADKCMRJSO8LGVZ1(UURetmKNdo10TIeBfHleJ3Cm0(zJDqioGrC8(feo4ut3ksSveUqmEZXq7Nn2bHyOnlmZfd0cobo10TIeBl9akWvKhLEaf4kYXlHdteHfeSMleJx6bSfVnfcIpi6zMGdyehdTF2CJVUgEFe(nLzNAPncXzV3m82ii8hFDjcliynxigV0dylEBkeeFmPRRH3hHFtz2PwXc5yAa)3oxm0I(JVUmzcdVpc)MYStTq7KXdb(nmI15Sjm8(i8BkZcPfANmEiWVHrSon10zty49r43uMDQfANmEiWVHrSoNnHH3hHFtzwiTq7KXdb(nmI15mrybblZ1rwu(qy2FllmNMEDzYwANVbNv(CJNjcliynxigV0dylEBkeeFUPxxMm8(i8BkZcPL2ieN9EZWBJGWF8mrybbR5cX4LEaBXBtHGyiNnHTrEUwMRJSOCAJqvEB9SfroZuWPMUvKyBPhqbUICSdcV)sh17CbhDd3pB8s4GgbIfMtlgwRJKZCDKfLVe8DU231DL45tn(6Ac(KbxddoZo1yinMONe4ut3ksST0dOaxro2bH0gH4S3BgEBee(JhVeomHgbIfMtlgwRJKZCDKfLVe8DU231DL45tAMiSGGL56ilkN2iuL3231DLytVUmHgbIfMtlgwRJKZCDKfLVe8DU231DL45tNoBcIWccwMRJSOCAJqvEBFx3vIn96IgbIfMtlgwRJKZCDKfLVe8DU231DLyINEgWPMUvKyBPhqbUICSdcXWADKCMRJSO8LGVZfCQPBfj2w6buGRih7GqODY4Ha)ggX6C8s4ahWiogA)mIpic4ut3ksST0dOaxro2bHq7KXdb(nmI154LWboGrCm0(zeFy8mtmXKH3hHFtzwiTq7KXdb(nmI151LiSGG1CHy8spGT4TPqq8HXMotewqWAUqmEPhWw82uiMpjtVUOrGyH50IH16i5mxhzr5lbFNR9DDxjE(XnLruH86sewqWYCDKfLpeM93(UURet8nLruH0uWPMUvKyBPhqbUICSdczUosXaTJxchdVpc)MYStTq7KXdb(nmI15mCaJ4yO9Zi(y6mteHfeSMleJx6bSfVnfI5hgFDn8(i8BkZASfANmEiWVHrSonDgoGrCm0(zZpZmrybblZ1rwuonE3cpao10TIeBl9akWvKJDqigwRJKpsHCHYt24LWHj0iqSWCAXWADKCMRJSO8LGVZ1(UURet8zoFgEWri(2)TVyBPhqbUIC(bKMEDrJaXcZPfdR1rYzUoYIYxc(ox776Us88Pqco10TIeBl9akWvKJDqOyHCmnG)BNlgAr)XJxch0iqSWCAXWADKCMRJSO8LGVZ1(UURet8KaNA6wrITLEaf4kYXoiehWioE)ccF8s4ahWiogA)S5ezMiSGGL56ilkNgVBXBtHy(bKGtnDRiX2spGcCf5yheYCDKIbAhVeoWbmIJH2pB(HXZeHfeSmxhzr504Dl8WmteHfeSmxhzr504DlEBkeeFy81LiSGGL56ilkNgVBFx3vINFCtzevIynAtbNA6wrITLEaf4kYXoiKfHECkbuKZ3(V9fFmDCDpXWPeqroF7)2x8HrpEjC8UW7yOTiYbNA6wrITLEaf4kYXoiK2ieVPBfjhv4D8S1(HiCHy8MJH2pdCcCQPBfj2M(c1F(q8BJoOncXB6wrYrfEhpBTFK(c1F(q8BJ4IWfIv594LWbncelmN20xO(ZhIFBK9DDxjEoKNdo10TIeBtFH6pFi(TrJDqiTriEt3ksoQW74zR9J0xO(ZhIFBeVPBnIpEjCicliytFH6pFi(Trw4bWjWPMUvKyB6lu)5dXVnI30TgXpU)sh17CbhDd3pB8s4GgbIfMtlgwRJKZCDKfLVe8DU231DL45tn(6Ac(KbxddoZo1yinMONe4ut3ksSn9fQ)8H43gXB6wJ4JDqigwRJKpsHCHYt24LWbncelmNwmSwhjN56ilkFj47CTVR7kXeFMZVUOrGyH50IH16i5mxhzr5lbFNR9DDxjE(uibNA6wrITPVq9Npe)2iEt3AeFSdcPncXzV3m82ii8hpEjCycncelmNwmSwhjN56ilkFj47CTVR7kXZN0mrybblZ1rwuoTrOkVTVR7kXMEDzcncelmNwmSwhjN56ilkFj47CTVR7kXZNoD2eeHfeSmxhzr50gHQ82(UUReB61fncelmNwmSwhjN56ilkFj47CTVR7kXep9mGtnDRiX20xO(ZhIFBeVPBnIp2bH0gH4nDRi5OcVJNT2peHleJ3Cm0(zJxch4agXXq7NDmDMj0iqSWCAPncXzV3m82ii8hBFx3vIN30TI0IH2SWmxmqRL24LVL2VUmzBKNRvSqoMgW)TZfdTO)yRNTiYzZOrGyH50kwihtd4)25IHw0FS9DDxjEEt3kslgAZcZCXaTwAJx(wA3utbNA6wrITPVq9Npe)2iEt3AeFSdcH2jJhc8ByeRZXlHdtmHgbIfMtlTrio79MH3gbH)y776UsmXnDRiTmxhPyGwlTXlFlTB6mtOrGyH50sBeIZEVz4Trq4p2(UURetCt3kslgAZcZCXaTwAJx(wA3utNrJaXcZPn9fQ)8H43gzFx3vIj2KPe95J10TI0cTtgpe43WiwNwAJx(wA3uWPMUvKyB6lu)5dXVnI30TgXh7GqmSwhjN56ilkFj47ChVeoeHfeSPVq9Npe)2i776Us88PNpdhWiogA)SJZbNA6wrITPVq9Npe)2iEt3AeFSdcXWADKCMRJSO8LGVZD8s4qewqWM(c1F(q8BJSVR7kXZB6wrAXWADKCMRJSO8LGVZ1sB8Y3s7JrelraNA6wrITPVq9Npe)2iEt3AeFSdczUosXaTJxchIWccwMRJSOCA8UfEaCQPBfj2M(c1F(q8BJ4nDRr8XoiK2ieVPBfjhv4D8S1(HiCHy8MJH2pdCcCQPBfj2M(c1F(q8BJ4IWfIv59r6lu)5dXVnA8s4ahWiogA)mIpiYmtMW2ipx7qy2FoUgGgP1Zwe5SRlrybblZ1rwuonE3cpyk4ut3ksSn9fQ)8H43gXfHleRY7XoiK2ieN9EZWBJGWFm4ut3ksSn9fQ)8H43gXfHleRY7XoieANmEiWVHrSohVeoOrGyH50sBeIZEVz4Trq4p2(UURet80jAgoGrCm0(zeFym4ut3ksSn9fQ)8H43gXfHleRY7XoiCim7phxdqJC8s4qewqWAUqmEPhWw82uii(aYzIWccwMRJSOCA8UfVnfI5hqotewqWYCDKfLpeM93YcZ5mCaJ4yO9Zi(WyWPMUvKyB6lu)5dXVnIlcxiwL3JDqi0oz8qGFdJyDoEjCGdyehdTFgXhebCQPBfj2M(c1F(q8BJ4IWfIv59yhesBeI30TIKJk8oE2A)qeUqmEZXq7NjjhXFCfP0qipF6eD(KMEg70PNB0ssZ9NvEJLKtEJktCdpBmCITrbOakdG6avPhIFbkH4bkJ6H3PHwSxJAG69jdUENbu4q7avdVHUxNbuuODE7yl40KtLoqreJcqn5My4HH4xNbunDRibkJ6kt)5mxhj2O2coboD2OhIFDgqz0avt3ksGcv4fBbNKKn8cnEjjzPp7ssuHxS0ajz6lu)5dXVnsAG0WPsdKKE2IiNjhvss)A9VAjjncelmN20xO(ZhIFBK9DDxjgOMduqEUKSPBfPKK2ieVPBfjhv4vsIk8YZw7sY0xO(ZhIFBexeUqSkVLR0qiLgij9SfrotoQKK(16F1ssrybbB6lu)5dXVnYcpijB6wrkjPncXB6wrYrfELKOcV8S1UKm9fQ)8H43gXB6wJ4YvUssMl0WOvAG0WPsdKKnDRiLK4bhH4OGcHK0Zwe5m5OYvAiKsdKKE2IiNjhvss)A9VAj5GVwMRJSO8LGVZ120TgXbQRlGA7)2x7wANVbNvoqnhOm(Cjzt3ksj5qSvKYvAOXsdKKE2IiNjhvss)A9VAj5GVwMRJSO8LGVZ120TgXbQRlGA7)2x7wANVbNvoqn)aOMsejzt3ksjjm2516ASCLgEgPbsspBrKZKJkjPFT(xTKCWxlZ1rwu(sW35AB6wJ4a11fqT9F7RDlTZ3GZkhOMFautjIKSPBfPKu0FS)qu5TCLgsePbsspBrKZKJkjPFT(xTKCWxlZ1rwu(sW35AB6wJ4a11fqT9F7RDlTZ3GZkhOMFautjIKSPBfPKuefbJla)eixPHeT0ajPNTiYzYrLK0Vw)Rwso4RL56ilkFj47CTnDRrCG66cO2(V91UL25BWzLduZpaQPers20TIuskuVlIIGjxPHgT0ajPNTiYzYrLK0Vw)RwsobGAlkevEduZaQT0oFdoRCGIyGY4ZbQzafEWri(2)TVyBPhqbUIeOMduqkjB6wrkjzrOLR0WjsAGK0Zwe5m5Oss6xR)vljnbOeHfeSMleJx6bSfVnfcGAoqr0a11fqjcliyzUoYIYhcZ(BHhaktbQRlGcp4ieF7)2xST0dOaxrcuZbkiLKnDRiLKmxhzr54998EHkxPHtsAGK0Zwe5m5Oss6xR)vlj3g55AtFH6pFi(TrwpBrKZaQzafEWri(2)TVyBPhqbUIeOMFauqkjB6wrkjPncXB6wrYrfELKOcV8S1UKm9fQ)8H43gjxPHtpxAGK0Zwe5m5Oss6xR)vljXdocX3(V9fBl9akWvKafXa1ujzt3ksjjTriEt3ksoQWRKev4LNT2LKLEaf4ks5knC6uPbsspBrKZKJkjPFT(xTKKgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqn1yG66cOMaq5tgCnm4mR5cj8odZX1DH4Hahdp4FfphdR1rw5TKSPBfPK8(lDuVZfC0nC)m5knCkKsdKKE2IiNjhvss)A9VAjPpzW1WGZSMlKW7mmhx3fIhcCm8G)v8CmSwhzL3a11fqrJaXcZPfdR1rYzUoYIYxc(ox776UsmqrmqDMZbQRlGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqnfsjzt3ksjjgwRJKpsHCHYtMCLgo1yPbsspBrKZKJkjPFT(xTK0Nm4AyWzwZfs4DgMJR7cXdbogEW)kEogwRJSYBG66cOmbOOrGyH50IH16i5mxhzr5lbFNR9DDxjgOMdutcOMbuIWccwMRJSOCAJqvEBFx3vIbktbQRlGYeGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqnDkqndOMaqjcliyzUoYIYPncv5T9DDxjgOmfOUUakAeiwyoTyyTosoZ1rwu(sW35AFx3vIbkIbQPNrs20TIussBeIZEVz4Trq4pwUsdNEgPbsspBrKZKJkjPFT(xTK0Nm4AyWzwZfs4DgMJR7cXdbogEW)kEogwRJSYBG66cOmbOeHfeSS3BgEBee(JTVR7kXafXafTXlFlTduZaktakrybbR5cX4LEaBXBtHaOi(aOmgOUUaQH3hHFtz2PwODY4Ha)ggX6eOmfOMbuMau4agXXq7NbuZbkJbQRlGsewqWYEVz4Trq4p2(UUReduZbQBkdOiQafKwJgOUUakrybb79x6OENl4OB4(z231DLyGAoqDtzafrfOG0A0aLPaLPsYMUvKssmSwhjN56ilkFj47CLR0WPerAGK0Zwe5m5Oss6xR)vljfHfeSMleJx6bSfVnfcGI4dGcsGAgqjcliyzUoYIYPX7w82uiaQ5hafKa1mGsewqWYCDKfLpeM93YcZjqndOWdocX3(V9fBl9akWvKa1CGcsjzt3ksj5qy2FoUgGgPCLgoLOLgij9SfrotoQKK(16F1sYTrEUwweARNTiYza1mG6DH3XqBrKduZaQT0oFdoRCGIyGYeGIfRLfH2(UUReduJbugFoqzQKSPBfPKKfHwUsdNA0sdKKE2IiNjhvss)A9VAjjoGrCm0(zafXhafraQRlGYeGchWiogA)mGI4dGYyGAgqrJaXcZPL2ieN9EZWBJGWFS9DDxjgOigOodqndOmbOMaqTnYZ1IH16i5JuixO8Kz9SfrodOUUakAeiwyoTyyTos(ifYfkpz231DLyGIyGYyGYuGYujzt3ksjj0oz8qGFdJyDkxPHtNiPbsspBrKZKJkjPFT(xTKehWiogA)mGAoqreGAgqjcliyzUoYIYPX7w82uiaQ5hafKsYMUvKssCaJ449liC5knC6KKgij9SfrotoQKK(16F1ssCaJ4yO9ZaQ5haLXa1mGsewqWYCDKfLtJ3TWda1mGYeGYeGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqn9CG66cOOrGyH50IH16i5mxhzr5lbFNR9DDxjgOigOGesGYuG66cOeHfeSmxhzr504DlEBkeafXhaLXa11fqjcliyzUoYIYPX7231DLyGAoqreG66cO2s78n4SYbQ5afKebOmvs20TIusYCDKIbALR0qipxAGK0Zwe5m5OsYMUvKssAJq8MUvKCuHxjjQWlpBTljfHleJ3Cm0(zYvUsYH3PHwSxPbsdNknqs6zlICMCu5knesPbsspBrKZKJkxPHglnqs6zlICMCu5kn8msdKKnDRiLKyyTos(GVsspBrKZKJkxPHerAGK0Zwe5m5Oss6xR)vlj3g55ARm9NZCDKyRNTiYzsYMUvKsYkt)5mxhjwUsdjAPbsspBrKZKJkxPHgT0ajzt3ksj5qSvKsspBrKZKJkxPHtK0ajPNTiYzYrLK0Vw)RwskcliynxigV0dylEBkeafXa1ujzt3ksj5qy2FoUgGgPCLgojPbsspBrKZKJkjPFT(xTKuewqWYCDKfLtJ3TWdsYMUvKssMRJumqRCLRKS0dOaxrknqA4uPbsspBrKZKJkjPFT(xTK0eGsewqWAUqmEPhWw82uiakIpakIgOMbuMau4agXXq7NbuZbkJbQRlGA49r43uMDQL2ieN9EZWBJGWFmqDDbuIWccwZfIXl9a2I3Mcbqr8bqnjG66cOgEFe(nLzNAflKJPb8F7CXql6pgOUUaktaQjaudVpc)MYStTq7KXdb(nmI1jqndOMaqn8(i8BkZcPfANmEiWVHrSobktbktbQza1eaQH3hHFtz2PwODY4Ha)ggX6eOMbutaOgEFe(nLzH0cTtgpe43WiwNa1mGsewqWYCDKfLpeM93YcZjqzkqDDbuMauBPD(gCw5a1CGYyGAgqjcliynxigV0dylEBkeafXa15aLPa11fqzcqn8(i8BkZcPL2ieN9EZWBJGWFmqndOeHfeSMleJx6bSfVnfcGIyGcsGAgqnbGABKNRL56ilkN2iuL3wpBrKZaktLKnDRiLKLEaf4ks5knesPbsspBrKZKJkjPFT(xTKKgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqn1yG66cOMaq5tgCnm4mR5cj8odZX1DH4Hahdp4FfphdR1rw5TKSPBfPK8(lDuVZfC0nC)m5kn0yPbsspBrKZKJkjPFT(xTK0eGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqnjGAgqjcliyzUoYIYPncv5T9DDxjgOmfOUUaktakAeiwyoTyyTosoZ1rwu(sW35AFx3vIbQ5a10Pa1mGAcaLiSGGL56ilkN2iuL3231DLyGYuG66cOOrGyH50IH16i5mxhzr5lbFNR9DDxjgOigOMEgjzt3ksjjTrio79MH3gbH)y5kn8msdKKnDRiLKyyTosoZ1rwu(sW35kj9SfrotoQCLgsePbsspBrKZKJkjPFT(xTKehWiogA)mGI4dGIisYMUvKssODY4Ha)ggX6uUsdjAPbsspBrKZKJkjPFT(xTKehWiogA)mGI4dGYyGAgqzcqzcqzcqn8(i8BkZcPfANmEiWVHrSobQRlGsewqWAUqmEPhWw82uiakIpakJbktbQzaLiSGG1CHy8spGT4TPqauZbQjbuMcuxxafncelmNwmSwhjN56ilkFj47CTVR7kXa18dG6MYakIkqbjqDDbuIWccwMRJSO8HWS)231DLyGIyG6MYakIkqbjqzQKSPBfPKeANmEiWVHrSoLR0qJwAGK0Zwe5m5Oss6xR)vljhEFe(nLzNAH2jJhc8ByeRtGAgqHdyehdTFgqr8bqnfOMbuMauIWccwZfIXl9a2I3Mcbqn)aOmgOUUaQH3hHFtzwJTq7KXdb(nmI1jqzkqndOWbmIJH2pdOMduNbOMbuIWccwMRJSOCA8UfEqs20TIusYCDKIbALR0WjsAGK0Zwe5m5Oss6xR)vljnbOOrGyH50IH16i5mxhzr5lbFNR9DDxjgOigOoZ5a1mGcp4ieF7)2xST0dOaxrcuZpakibktbQRlGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqnfsjzt3ksjjgwRJKpsHCHYtMCLgojPbsspBrKZKJkjPFT(xTKKgbIfMtlgwRJKZCDKfLVe8DU231DLyGIyGAssYMUvKssXc5yAa)3oxm0I(JLR0WPNlnqs6zlICMCujj9R1)QLK4agXXq7NbuZbkIauZakrybblZ1rwuonE3I3Mcbqn)aOGus20TIusIdyehVFbHlxPHtNknqs6zlICMCujj9R1)QLK4agXXq7NbuZpakJbQzaLiSGGL56ilkNgVBHhaQzaLjaLiSGGL56ilkNgVBXBtHaOi(aOmgOUUakrybblZ1rwuonE3(UUReduZpaQBkdOiQafrSgnqzQKSPBfPKK56ifd0kxPHtHuAGK0Zwe5m5OsYMUvKssweAjjLakY5B)3(ILgovsQ7jgoLakY5B)3(ILKgTKK(16F1sY3fEhdTfrUCLgo1yPbsspBrKZKJkjB6wrkjPncXB6wrYrfELKOcV8S1UKueUqmEZXq7Njx5kjtFH6pFi(TrCr4cXQ8wAG0WPsdKKE2IiNjhvss)A9VAjjoGrCm0(zafXhafraQzaLja1eaQTrEU2HWS)CCnansRNTiYza11fqjcliyzUoYIYPX7w4bGYujzt3ksjz6lu)5dXVnsUsdHuAGKSPBfPKK2ieN9EZWBJGWFSK0Zwe5m5OYvAOXsdKKE2IiNjhvss)A9VAjjncelmNwAJqC27ndVncc)X231DLyGIyGA6ebuZakCaJ4yO9ZakIpakJLKnDRiLKq7KXdb(nmI1PCLgEgPbsspBrKZKJkjPFT(xTKuewqWAUqmEPhWw82uiakIpakibQzaLiSGGL56ilkNgVBXBtHaOMFauqcuZakrybblZ1rwu(qy2FllmNa1mGchWiogA)mGI4dGYyjzt3ksj5qy2FoUgGgPCLgsePbsspBrKZKJkjPFT(xTKehWiogA)mGI4dGIisYMUvKssODY4Ha)ggX6uUsdjAPbsspBrKZKJkjB6wrkjPncXB6wrYrfELKOcV8S1UKueUqmEZXq7Njx5kjfHleJ3Cm0(zsdKgovAGK0Zwe5m5Oss6xR)vlj7Zw)R1TcXlwmMNCiYWmYz3U1Zwe5mGAgqjcliyfIxSymp5qKHzKZUD77nDbQza1eakrybblZ1rwuonE3(EtxGAgqrJaXcZPfdR1rYzUoYIYxc(ox776Usmqrmqb55sYMUvKssMRJumqRCLgcP0ajzt3ksjjoGrC8(feUK0Zwe5m5OYvAOXsdKKnDRiLKyOnlmZfd0kj9SfrotoQCLRKm9fQ)8H43gXB6wJ4sdKgovAGK0Zwe5m5Oss6xR)vljPrGyH50IH16i5mxhzr5lbFNR9DDxjgOMdutngOUUaQjau(KbxddoZAUqcVZWCCDxiEiWXWd(xXZXWADKvEljB6wrkjV)sh17CbhDd3ptUsdHuAGK0Zwe5m5Oss6xR)vljPrGyH50IH16i5mxhzr5lbFNR9DDxjgOigOoZ5a11fqrJaXcZPfdR1rYzUoYIYxc(ox776UsmqnhOMcPKSPBfPKedR1rYhPqUq5jtUsdnwAGK0Zwe5m5Oss6xR)vljnbOOrGyH50IH16i5mxhzr5lbFNR9DDxjgOMdutcOMbuIWccwMRJSOCAJqvEBFx3vIbktbQRlGYeGIgbIfMtlgwRJKZCDKfLVe8DU231DLyGAoqnDkqndOMaqjcliyzUoYIYPncv5T9DDxjgOmfOUUakAeiwyoTyyTosoZ1rwu(sW35AFx3vIbkIbQPNrs20TIussBeIZEVz4Trq4pwUsdpJ0ajPNTiYzYrLK0Vw)RwsIdyehdTFgqDautbQzaLjafncelmNwAJqC27ndVncc)X231DLyGAoq10TI0IH2SWmxmqRL24LVL2bQRlGYeGABKNRvSqoMgW)TZfdTO)yRNTiYza1mGIgbIfMtRyHCmnG)BNlgAr)X231DLyGAoq10TI0IH2SWmxmqRL24LVL2bktbktLKnDRiLK0gH4nDRi5OcVssuHxE2AxskcxigV5yO9ZKR0qIinqs6zlICMCujj9R1)QLKMauMau0iqSWCAPncXzV3m82ii8hBFx3vIbkIbQMUvKwMRJumqRL24LVL2bktbQzaLjafncelmNwAJqC27ndVncc)X231DLyGIyGQPBfPfdTzHzUyGwlTXlFlTduMcuMcuZakAeiwyoTPVq9Npe)2i776UsmqrmqzcqnLOphOgdOA6wrAH2jJhc8ByeRtlTXlFlTduMkjB6wrkjH2jJhc8ByeRt5knKOLgij9SfrotoQKK(16F1ssrybbB6lu)5dXVnY(UUReduZbQPNduZakCaJ4yO9ZaQdG6Cjzt3ksjjgwRJKZCDKfLVe8DUYvAOrlnqs6zlICMCujj9R1)QLKIWcc20xO(ZhIFBK9DDxjgOMdunDRiTyyTosoZ1rwu(sW35APnE5BPDGAmGIiwIijB6wrkjXWADKCMRJSO8LGVZvUsdNiPbsspBrKZKJkjPFT(xTKuewqWYCDKfLtJ3TWdsYMUvKssMRJumqRCLgojPbsspBrKZKJkjB6wrkjPncXB6wrYrfELKOcV8S1UKueUqmEZXq7Njx5kx5kxPea]] )
end
