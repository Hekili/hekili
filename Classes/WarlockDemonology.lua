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

            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( 'felguard', 3600 )
            end,
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
    
        package = "Demonology",
    } )


    spec:RegisterPack( "Demonology", 20180807.0035, [[dGKy)aqikL6rebfBsr6tukjgfLItrjAveb5vkeZsHYTuHKAxu8lkvgMkuhtrSmG4zePMMcvDnIqBJiW3OuIXPqfNtfI1rPKY8ub3trTpvQoiLsslKsvpufsLMOkKKlsPKkFufsvgPkKkoPkKIvsentviv1oPegQkKOLsPKQEkctLi5QebL(QkKWEj8xOgmPoSKftupgLjd5YuTze9zvYObQtl1RvPmBKUnj7w0VfgUcoUcvA5Q65GMUsxhW2vi9DkPXteuDEG06vHuA(QO9JQftesjiq16cla54jJZXJZX2I54JLE8sBlcIf0bxqmuSB1LliYs5cIJkxfzqJlqfedfO0OqcPeeWa4zUGa8UdqBn7S7QxWaYgwOSd2kaATDKSVix7GTIzNmnKTtMSoQr(O2n8bztDODs1(dYe7KcKj4JI6Pb7g(OYvrg04cudSvmbHmqt3JMuiliq16cla54jJZXJZX2I54JLE8sdIGao4mHfGibsGGa5qMGqkWnKRBixVGDUg5KfaD56HIDRUCUMmEU(OYvrg04cuU(OOEAWUb56o5A7RDPoxtgpxBRE06FSGnCj5sEugW9OUvdXVCndCLxo0wJl5edxZ1syHoxldqsAsFb7pEi(TOgGbUUt46fIRdsUMfbffwtUgb812rY1KXZ1PVG9hpe)wuCX2EuNRl22rY10gUgUKGy4AU2wfHCexxC9W7SqjxlxFugw9NRj6bWrY1njxdAaW1GRrDUgeUUvdqUEdUMfjeq5CTnKUtbL9f5APrqm8bztDbHegU2wNeUZawhX1Yoz8oxZcLCTCTSF1j0W12QmMpSqUoJ8OgC9ksakxxSTJeY1rsb1WLSyBhj0m8oluY1otsl4nUKfB7iHMH3zHsU2rMTJmcexYITDKqZW7Sqjx7iZ2vaxkp3A7i5swSTJeAgENfk5Ahz2oiGsfjEWxUKfB7iHMH3zHsU2rMTRZ0FmYvrchRjN3I65A6m9hJCvKqJNLm1rCjl22rcndVZcLCTJmB3qy1FmShah5yn5SmajPXAtr4wnanWTy3UpHlzX2osOz4DwOKRDKz7GznabhlgU1c5swSTJeAgENfk5Ahz2UHy7i5swSTJeAgENfk5Ahz2oKRIuoOlxsUKsy4ABDs4odyDex7J6pOC92kNRxWoxxSnEUUHCDnA10sM6gUKfB7iHZdX2rowtop4Rb5QiBgEb9RCnfB7r9ZZT(lFnBRC8gyu7hK(yUKfB7iHJmBha0X96k4yn58GVgKRISz4f0VY1uSTh1pp36V81STYXBGrTFyEIe5swSTJeoYSDY(d9)wNxJ1KZd(AqUkYMHxq)kxtX2Eu)8CR)YxZ2khVbg1(H5jsKlzX2os4iZ2jtJaHjbEqhRjNh81GCvKndVG(vUMIT9O(55w)LVMTvoEdmQ9dZtKixYITDKWrMTJSFxMgbASMCEWxdYvr2m8c6x5Ak22J6NNB9x(A2w54nWO2pmprICjl22rchz2oueQXAYzBVn7wNxt3w54nWO2Vl9XtHdoLI36V8fAA1anGDKhaHlzX2os4iZ2HCvKndd33ZRf8yn5SnYaKKgRnfHB1a0a3ID7GeCEkdqsAqUkYMHhcR(BagS88eo4ukER)YxOPvd0a2rEaeUKfB7iHJmBhROuCX2osmTH7yzP850xW(JhIFl6yn58wupxt6ly)XdXVf14zjtD0u4GtP4T(lFHMwnqdyh5Hzq4swSTJeoYSDSIsXfB7iX0gUJLLYNB1anGDKJ1KZWbNsXB9x(cnTAGgWoY7t4swSTJeoYSDxFRI(DmPtVaQhnwtoZIGIcRPbcOurIrUkYMHxq)kxZ7QQt4HjsFEABFCb6HbhzMinislbhHlzX2os4iZ2bbuQiXJ2uNS9enwto7Jlqpm4iZePbrAj4iNNSiOOWAAGakvKyKRISz4f0VY18UQ6eEF8hFEYIGIcRPbcOurIrUkYMHxq)kxZ7QQt4HjGWLSyBhjCKz7yfLIrVxi4w0B(dhRjN9XfOhgCKzI0GiTeCKZtByrqrH10abuQiXixfzZWlOFLR5Dv1j8WrMkdqsAqUkYMHzfL25L5Dv1j0YZtByrqrH10abuQiXixfzZWlOFLR5Dv1j8WKjtTTmajPb5QiBgMvuANxM3vvNqlppzrqrH10abuQiXixfzZWlOFLR5Dv1j8(KXZLSyBhjCKz7GakvKyKRISz4f0VYDSMC2hxGEyWrMjsdI0sWropTrgGK0GEVqWTO38hAExvDcVZk4I3w5tTrgGK0yTPiCRgGg4wSB3NL(8C49rXxmKzIbCLiCqIVaOOkTCQnWaGIHGRhDq6Ztzassd69cb3IEZFO5Dv1j8WfdjHaXylNNYaKKMRVvr)oM0Pxa1JmVRQoHhUyijeigBXsl5swSTJeoYSDdHv)XWEaCKJ1KZYaKKgRnfHB1a0a3ID7(mitLbijnixfzZWS4DdCl2TdZGmvgGK0GCvKndpew93GcR5u4GtP4T(lFHMwnqdyh5bq4swSTJeoYSDOiuJ1KZBr9CnOiugplzQJM(o57qWLm1NUTYXBGrTF3guSguekZ7QQt4isFSLCjl22rchz2oWvIWbj(cGIQCSMCggaumeC9O7Zs880gyaqXqW1JUpl9uweuuynnSIsXO3leCl6n)HM3vvNW7JFQn2ElQNRbcOurIhTPoz7jY4zjtD05jlckkSMgiGsfjE0M6KTNiZ7QQt4DPT0sUKfB7iHJmBhmaOy4(9nFSMCggaumeC9OdsCQmajPb5QiBgMfVBGBXUDygeUKfB7iHJmBhYvrkh0DSMCggaumeC9OdZspvgGK0GCvKndZI3nadtTXgweuuynnqaLksmYvr2m8c6x5AExvDcpm54ZtweuuynnqaLksmYvr2m8c6x5AExvDcVdciwEEkdqsAqUkYMHzX7g4wSB3NL(8ugGK0GCvKndZI3nVRQoHhK4552khVbg1(bqKOLCjl22rchz2owrP4ITDKyAd3XYs5ZYanfHlmeC9iUKCjl22rcnYanfHlmeC9OzKRIuoO7yn5CD06FVUHmE5gH8eFldRuhD5MVYB3NbzQmajPHmE5gH8eFldRuhD5M3l2o12YaKKgKRISzyw8U59ITtzrqrH10abuQiXixfzZWlOFLR5Dv1j8oihZLSyBhj0id0ueUWqW1Jgz2oyaqXW97BoxYITDKqJmqtr4cdbxpAKz7GGluyflh0LljxYITDKqtRgObSJCUvd0a2rowtoBJmajPXAtr4wnanWTy3UplbtTbgaumeC9OdsFEo8(O4lgYmXWkkfJEVqWTO38hEEkdqsAS2ueUvdqdCl2T7Zh58C49rXxmKzIrUPoKfa)LJLdLS)WZtBS9W7JIVyiZed4kr4GeFbqrvo12dVpk(IHmGyaxjchK4lakQslTCQThEFu8fdzMyaxjchK4lakQYP2E49rXxmKbed4kr4GeFbqrvovgGK0GCvKndpew93GcRPLNN2STYXBGrTFq6PYaKKgRnfHB1a0a3ID7(XwEEAZW7JIVyidigwrPy07fcUf9M)WPYaKKgRnfHB1a0a3ID7oitT9wupxdYvr2mmRO0oVmEwYuhzjxYITDKqtRgObSJCKz7U(wf97ysNEbupASMCMfbffwtdeqPIeJCvKndVG(vUM3vvNWdtK(802(4c0ddoYmrAqKwcocxYITDKqtRgObSJCKz7yfLIrVxi4w0B(dhRjNTHfbffwtdeqPIeJCvKndVG(vUM3vvNWdhzQmajPb5QiBgMvuANxM3vvNqlppTHfbffwtdeqPIeJCvKndVG(vUM3vvNWdtMm12YaKKgKRISzywrPDEzExvDcT88KfbffwtdeqPIeJCvKndVG(vUM3vvNW7tgpxYITDKqtRgObSJCKz7GakvKyKRISz4f0VYLlzX2osOPvd0a2roYSDGReHds8fafv5yn5mmaOyi46r3NLixYITDKqtRgObSJCKz7axjchK4lakQYXAYzyaqXqW1JUpl9uBSXMH3hfFXqgqmGReHds8fafv55PmajPXAtr4wnanWTy3UplTLtLbijnwBkc3QbObUf72HJy55jlckkSMgiGsfjg5QiBgEb9RCnVRQoHhMVyijeiNNYaKKgKRISz4HWQ)M3vvNW7xmKecel5swSTJeAA1anGDKJmBhYvrkh0DSMCE49rXxmKzIbCLiCqIVaOOkNcdakgcUE095jtTrgGK0yTPiCRgGg4wSBhML(8C49rXxmKrAd4kr4GeFbqrvA5uyaqXqW1Jom(PYaKKgKRISzyw8UbyGlzX2osOPvd0a2roYSDqaLks8On1jBprJ1KZ2WIGIcRPbcOurIrUkYMHxq)kxZ7QQt49XF8u4GtP4T(lFHMwnqdyh5HzqS88KfbffwtdeqPIeJCvKndVG(vUM3vvNWdtaHlzX2osOPvd0a2roYSDYn1HSa4VCSCOK9howtoZIGIcRPbcOurIrUkYMHxq)kxZ7QQt49JWLSyBhj00QbAa7ihz2oyaqXW97B(yn5mmaOyi46rhK4uzassdYvr2mmlE3a3ID7WmiCjl22rcnTAGgWoYrMTd5QiLd6owtoddakgcUE0HzPNkdqsAqUkYMHzX7gGHP2idqsAqUkYMHzX7g4wSB3NL(8ugGK0GCvKndZI3nVRQoHhMVyijKen2ILCjl22rcnTAGgWoYrMTdfHAmgOmQJ36V8fopzmvjHJzGYOoER)Yx4STmwto)o57qWLm15swSTJeAA1anGDKJmBhROuCX2osmTH7yzP8zzGMIWfgcUEexsUKfB7iHM0xW(JhIFl6mROuCX2osmTH7yzP850xW(JhIFlkwgOPOoVgRjNzrqrH10K(c2F8q8BrnVRQoHha5yUKfB7iHM0xW(JhIFl6iZ2XkkfxSTJetB4owwkFo9fS)4H43IIl22J6J1KZYaKKM0xW(JhIFlQbyGljxYITDKqt6ly)XdXVffxSTh1NV(wf97ysNEbupASMCMfbffwtdeqPIeJCvKndVG(vUM3vvNWdtK(802(4c0ddoYmrAqKwcocxYITDKqt6ly)XdXVffxSTh1hz2oiGsfjE0M6KTNOXAYzweuuynnqaLksmYvr2m8c6x5AExvDcVp(JppzrqrH10abuQiXixfzZWlOFLR5Dv1j8Weq4swSTJeAsFb7pEi(TO4IT9O(iZ2XkkfJEVqWTO38howtoBdlckkSMgiGsfjg5QiBgEb9RCnVRQoHhoYuzassdYvr2mmRO0oVmVRQoHwEEAdlckkSMgiGsfjg5QiBgEb9RCnVRQoHhMmzQTLbijnixfzZWSIs78Y8UQ6eA55jlckkSMgiGsfjg5QiBgEb9RCnVRQoH3NmEUKfB7iHM0xW(JhIFlkUyBpQpYSDSIsXfB7iX0gUJLLYNLbAkcxyi46rJ1KZWaGIHGRhnpzQnSiOOWAAyfLIrVxi4w0B(dnVRQoHhk22rAGGluyflh01Wk4I3w5NN2Sf1Z1i3uhYcG)YXYHs2FOXZsM6OPSiOOWAAKBQdzbWF5y5qj7p08UQ6eEOyBhPbcUqHvSCqxdRGlEBLBPLCjl22rcnPVG9hpe)wuCX2EuFKz7axjchK4lakQYXAYzBSHfbffwtdROum69cb3IEZFO5Dv1j8EX2osdYvrkh01Wk4I3w5wo1gweuuynnSIsXO3leCl6n)HM3vvNW7fB7inqWfkSILd6AyfCXBRClTCklckkSMM0xW(JhIFlQ5Dv1j8UntKGJhPyBhPbCLiCqIVaOOknScU4TvULCjl22rcnPVG9hpe)wuCX2EuFKz7GakvKyKRISz4f0VYDSMCwgGK0K(c2F8q8BrnVRQoHhMC8uyaqXqW1JMpMlzX2osOj9fS)4H43IIl22J6JmBheqPIeJCvKndVG(vUJ1KZYaKKM0xW(JhIFlQ5Dv1j8qX2osdeqPIeJCvKndVG(vUgwbx82kFejAKixYITDKqt6ly)XdXVffxSTh1hz2oKRIuoO7yn5SmajPb5QiBgMfVBag4swSTJeAsFb7pEi(TO4IT9O(iZ2XkkfxSTJetB4owwkFwgOPiCHHGRhXLKlzX2osOj9fS)4H43IILbAkQZR50xW(JhIFl6yn5mmaOyi46r3NL4uBS9wupxZqy1FmShahPXZsM6OZtzassdYvr2mmlE3amyjxYITDKqt6ly)XdXVffld0uuNxJmBhROum69cb3IEZFixYITDKqt6ly)XdXVffld0uuNxJmBh4kr4GeFbqrvowtoZIGIcRPHvukg9EHGBrV5p08UQ6eEFY4mfgaumeC9O7ZsZLSyBhj0K(c2F8q8BrXYanf151iZ2new9hd7bWrowtoldqsAS2ueUvdqdCl2T7ZGmvgGK0GCvKndZI3nWTy3omdYuzassdYvr2m8qy1FdkSMtHbafdbxp6(S0Cjl22rcnPVG9hpe)wuSmqtrDEnYSDGReHds8fafv5yn5mmaOyi46r3NLixYITDKqt6ly)XdXVffld0uuNxJmBhROuCX2osmTH7yzP8zzGMIWfgcUEKGyu)HDKcla54jJZX2YKXXC8KjsuqyT(SZlOG4OWw1wVfhnwC0ZwJR5APa7CDRgIF5AY45ABLH3zHsUwBfU(9XfOFhX1Wq5CDbSHQwhX1mWvE5qdxYJ(D6CTeT14AjSjeyyi(1rCDX2osU2wPZ0FmYvrcTvmCj5sE0OgIFDexBlCDX2osUM2WfA4skikGfC8cIJovIGHY5AIwD0LRpk9yG6ccAdxOqkbr6ly)XdXVffxSTh1fsjSyIqkbHNLm1rc7feSVx)7sqWIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFGRNinxFEY12MR9XfOhgCKXAtjFhbXW(QP4Gedbg8VJhdbuQi78squSTJuqC9Tk63XKo9cOEKyfwaIqkbHNLm1rc7feSVx)7sqWIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFNRh)XC95jxZIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFGRNaIGOyBhPGacOurIhTPoz7jsSclKwiLGWZsM6iH9cc23R)DjiSHRzrqrH10abuQiXixfzZWlOFLR5Dv1jKRpW1hHRNY1YaKKgKRISzywrPDEzExvDc5Al56ZtU2gUMfbffwtdeqPIeJCvKndVG(vUM3vvNqU(axpzcxpLRTnxldqsAqUkYMHzfL25L5Dv1jKRTKRpp5AweuuynnqaLksmYvr2m8c6x5AExvDc567C9KXlik22rkiyfLIrVxi4w0B(dfRWIXlKsq4zjtDKWEbb771)UeeWaGIHGRhX1ZC9eUEkxBdxZIGIcRPHvukg9EHGBrV5p08UQ6eY1h46ITDKgi4cfwXYbDnScU4TvoxFEY12W1Br9CnYn1HSa4VCSCOK9hA8SKPoIRNY1SiOOWAAKBQdzbWF5y5qj7p08UQ6eY1h46ITDKgi4cfwXYbDnScU4TvoxBjxBPGOyBhPGGvukUyBhjM2WvqqB4IZs5cczGMIWfgcUEKyfwirHuccplzQJe2liyFV(3LGWgU2gUMfbffwtdROum69cb3IEZFO5Dv1jKRVZ1fB7inixfPCqxdRGlEBLZ1wY1t5AB4AweuuynnSIsXO3leCl6n)HM3vvNqU(oxxSTJ0abxOWkwoORHvWfVTY5Al5Al56PCnlckkSMM0xW(JhIFlQ5Dv1jKRVZ12W1tKGJ56r46ITDKgWvIWbj(cGIQ0Wk4I3w5CTLcIITDKccWvIWbj(cGIQuSclKaHuccplzQJe2liyFV(3LGqgGK0K(c2F8q8BrnVRQoHC9bUEYXC9uUggaumeC9iUEMRpwquSTJuqabuQiXixfzZWlOFLRyfwylcPeeEwYuhjSxqW(E9VlbHmajPj9fS)4H43IAExvDc56dCDX2osdeqPIeJCvKndVG(vUgwbx82kNRhHRLOrIcIITDKcciGsfjg5QiBgEb9RCfRWIXriLGWZsM6iH9cc23R)DjiKbijnixfzZWS4DdWGGOyBhPGa5QiLd6kwHfhriLGWZsM6iH9cIITDKccwrP4ITDKyAdxbbTHlolLliKbAkcxyi46rIvSccKtwa0viLWIjcPeeEwYuhjSxqW(E9VlbXGVgKRISz4f0VY1uSTh156ZtUER)YxZ2khVbg1oxFGRL(ybrX2osbXqSDKIvybicPeeEwYuhjSxqW(E9VlbXGVgKRISz4f0VY1uSTh156ZtUER)YxZ2khVbg1oxFyMRNirbrX2osbba0X96kOyfwiTqkbHNLm1rc7feSVx)7sqm4Rb5QiBgEb9RCnfB7rDU(8KR36V81STYXBGrTZ1hM56jsuquSTJuqi7p0)BDEjwHfJxiLGWZsM6iH9cc23R)Djig81GCvKndVG(vUMIT9OoxFEY1B9x(A2w54nWO256dZC9ejkik22rkiKPrGWKapOIvyHefsji8SKPosyVGG996FxcIbFnixfzZWlOFLRPyBpQZ1NNC9w)LVMTvoEdmQDU(WmxprIcIITDKccY(DzAeiXkSqcesji8SKPosyVGG996FxccBZ1BZU15fxpLR3w54nWO2567CT0hZ1t5A4GtP4T(lFHMwnqdyhjxFGRbrquSTJuqGIqjwHf2IqkbHNLm1rc7feSVx)7sqydxldqsAS2ueUvdqdCl2nU(axlbC95jxldqsAqUkYMHhcR(Bag4Al56ZtUgo4ukER)YxOPvd0a2rY1h4AqeefB7ifeixfzZWW998AblwHfJJqkbHNLm1rc7feSVx)7sqSf1Z1K(c2F8q8BrnEwYuhX1t5A4GtP4T(lFHMwnqdyhjxFyMRbrquSTJuqWkkfxSTJetB4kiOnCXzPCbr6ly)XdXVfvScloIqkbHNLm1rc7feSVx)7sqahCkfV1F5l00QbAa7i567C9ebrX2osbbROuCX2osmTHRGG2WfNLYfeTAGgWosXkSyYXcPeeEwYuhjSxqW(E9VlbblckkSMgiGsfjg5QiBgEb9RCnVRQoHC9bUEI0C95jxBBU2hxGEyWrgRnL8Deed7RMIdsmeyW)oEmeqPISZlbrX2osbX13QOFht60lG6rIvyXKjcPeeEwYuhjSxqW(E9VlbHpUa9WGJmwBk57iig2xnfhKyiWG)D8yiGsfzNxC95jxZIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFNRh)XC95jxZIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFGRNaIGOyBhPGacOurIhTPoz7jsSclMaIqkbHNLm1rc7feSVx)7sq4Jlqpm4iJ1Ms(ocIH9vtXbjgcm4FhpgcOur25fxFEY12W1SiOOWAAGakvKyKRISz4f0VY18UQ6eY1h46JW1t5AzassdYvr2mmRO0oVmVRQoHCTLC95jxBdxZIGIcRPbcOurIrUkYMHxq)kxZ7QQtixFGRNmHRNY12MRLbijnixfzZWSIs78Y8UQ6eY1wY1NNCnlckkSMgiGsfjg5QiBgEb9RCnVRQoHC9DUEY4fefB7ifeSIsXO3leCl6n)HIvyXePfsji8SKPosyVGG996FxccFCb6HbhzS2uY3rqmSVAkoiXqGb)74XqaLkYoV46ZtU2gUwgGK0GEVqWTO38hAExvDc567CnRGlEBLZ1t5AB4AzassJ1MIWTAaAGBXUX13N5AP56ZtUE49rXxmKzIbCLiCqIVaOOk5Al56PCTnCnmaOyi46rC9bUwAU(8KRLbijnO3leCl6n)HM3vvNqU(axFXqCTeIRbXylC95jxldqsAU(wf97ysNEbupY8UQ6eY1h46lgIRLqCnigBHRTKRTuquSTJuqabuQiXixfzZWlOFLRyfwmz8cPeeEwYuhjSxqW(E9VlbHmajPXAtr4wnanWTy3467ZCniC9uUwgGK0GCvKndZI3nWTy346dZCniC9uUwgGK0GCvKndpew93GcRjxpLRHdoLI36V8fAA1anGDKC9bUgebrX2osbXqy1FmShahPyfwmrIcPeeEwYuhjSxqW(E9VlbXwupxdkcLXZsM6iUEkx)o57qWLm156PC92khVbg1oxFNRTHRrXAqrOmVRQoHC9iCT0hZ1wkik22rkiqrOeRWIjsGqkbHNLm1rc7feSVx)7sqadakgcUEexFFMRLixFEY12W1WaGIHGRhX13N5AP56PCnlckkSMgwrPy07fcUf9M)qZ7QQtixFNRhpxpLRTHRTnxVf1Z1abuQiXJ2uNS9ez8SKPoIRpp5AweuuynnqaLks8On1jBprM3vvNqU(oxlnxBjxBPGOyBhPGaCLiCqIVaOOkfRWIj2IqkbHNLm1rc7feSVx)7sqadakgcUEexFGRLixpLRLbijnixfzZWS4DdCl2nU(WmxdIGOyBhPGagaumC)(MlwHftghHuccplzQJe2liyFV(3LGagaumeC9iU(WmxlnxpLRLbijnixfzZWS4DdWaxpLRTHRTHRzrqrH10abuQiXixfzZWlOFLR5Dv1jKRpW1toMRpp5AweuuynnqaLksmYvr2m8c6x5AExvDc567CniGW1wY1NNCTmajPb5QiBgMfVBGBXUX13N5AP56ZtUwgGK0GCvKndZI3nVRQoHC9bUwIC95jxVTYXBGrTZ1h4AqKixBPGOyBhPGa5QiLd6kwHftoIqkbHNLm1rc7fefB7ifeSIsXfB7iX0gUccAdxCwkxqid0ueUWqW1JeRyfedVZcLCTcPewmriLGWZsM6iH9IvybicPeeEwYuhjSxSclKwiLGWZsM6iH9IvyX4fsjik22rkiGakvK4bFfeEwYuhjSxSclKOqkbHNLm1rc7feSVx)7sqSf1Z10z6pg5QiHgplzQJeefB7ifeDM(JrUksOyfwibcPeeEwYuhjSxqW(E9VlbHmajPXAtr4wnanWTy3467C9ebrX2osbXqy1FmShahPyfwylcPeeEwYuhjSxSclghHucIITDKcIHy7ifeEwYuhjSxScloIqkbrX2osbbYvrkh0vq4zjtDKWEXkwbr6ly)XdXVfviLWIjcPeeEwYuhjSxqW(E9VlbblckkSMM0xW(JhIFlQ5Dv1jKRpW1GCSGOyBhPGGvukUyBhjM2WvqqB4IZs5cI0xW(JhIFlkwgOPOoVeRWcqesji8SKPosyVGG996Fxcczasst6ly)XdXVf1amiik22rkiyfLIl22rIPnCfe0gU4SuUGi9fS)4H43IIl22J6IvScI0xW(JhIFlkwgOPOoVesjSyIqkbHNLm1rc7feSVx)7sqadakgcUEexFFMRLixpLRTHRTnxVf1Z1mew9hd7bWrA8SKPoIRpp5AzassdYvr2mmlE3amW1wkik22rkisFb7pEi(TOIvybicPeefB7ifeSIsXO3leCl6n)HccplzQJe2lwHfslKsq4zjtDKWEbb771)UeeSiOOWAAyfLIrVxi4w0B(dnVRQoHC9DUEY4W1t5AyaqXqW1J467ZCT0cIITDKccWvIWbj(cGIQuSclgVqkbHNLm1rc7feSVx)7sqidqsAS2ueUvdqdCl2nU((mxdcxpLRLbijnixfzZWS4DdCl2nU(WmxdcxpLRLbijnixfzZWdHv)nOWAY1t5AyaqXqW1J467ZCT0cIITDKcIHWQ)yypaosXkSqIcPeeEwYuhjSxqW(E9VlbbmaOyi46rC99zUwIcIITDKccWvIWbj(cGIQuSclKaHuccplzQJe2lik22rkiyfLIl22rIPnCfe0gU4SuUGqgOPiCHHGRhjwXkiKbAkcxyi46rcPewmriLGWZsM6iH9cc23R)DjiQJw)71nKXl3iKN4BzyL6Ol38vEJRVpZ1GW1t5Azassdz8Ync5j(wgwPo6YnVxSLRNY12MRLbijnixfzZWS4DZ7fB56PCnlckkSMgiGsfjg5QiBgEb9RCnVRQoHC9DUgKJfefB7ifeixfPCqxXkSaeHucIITDKccyaqXW97BUGWZsM6iH9IvyH0cPeefB7ifeqWfkSILd6ki8SKPosyVyfRGOvd0a2rkKsyXeHuccplzQJe2liyFV(3LGWgUwgGK0yTPiCRgGg4wSBC99zUwc46PCTnCnmaOyi46rC9bUwAU(8KRhEFu8fdzMyyfLIrVxi4w0B(d56ZtUwgGK0yTPiCRgGg4wSBC99zU(iC95jxp8(O4lgYmXi3uhYcG)YXYHs2FixFEY12W12MRhEFu8fdzMyaxjchK4lakQsUEkxBBUE49rXxmKbed4kr4GeFbqrvY1wY1wY1t5ABZ1dVpk(IHmtmGReHds8fafvjxpLRTnxp8(O4lgYaIbCLiCqIVaOOk56PCTmajPb5QiBgEiS6VbfwtU2sU(8KRTHR3w54nWO256dCT0C9uUwgGK0yTPiCRgGg4wSBC9DU(yU2sU(8KRTHRhEFu8fdzaXWkkfJEVqWTO38hY1t5AzassJ1MIWTAaAGBXUX135Aq46PCTT56TOEUgKRISzywrPDEz8SKPoIRTuquSTJuq0QbAa7ifRWcqesji8SKPosyVGG996FxccweuuynnqaLksmYvr2m8c6x5AExvDc56dC9eP56ZtU22CTpUa9WGJmwBk57iig2xnfhKyiWG)D8yiGsfzNxcIITDKcIRVvr)oM0Pxa1JeRWcPfsji8SKPosyVGG996FxccB4AweuuynnqaLksmYvr2m8c6x5AExvDc56dC9r46PCTmajPb5QiBgMvuANxM3vvNqU2sU(8KRTHRzrqrH10abuQiXixfzZWlOFLR5Dv1jKRpW1tMW1t5ABZ1YaKKgKRISzywrPDEzExvDc5Al56ZtUMfbffwtdeqPIeJCvKndVG(vUM3vvNqU(oxpz8cIITDKccwrPy07fcUf9M)qXkSy8cPeefB7ifeqaLksmYvr2m8c6x5ki8SKPosyVyfwirHuccplzQJe2liyFV(3LGagaumeC9iU((mxlrbrX2osbb4kr4GeFbqrvkwHfsGqkbHNLm1rc7feSVx)7sqadakgcUEexFFMRLMRNY12W12W12W1dVpk(IHmGyaxjchK4lakQsU(8KRLbijnwBkc3QbObUf7gxFFMRLMRTKRNY1YaKKgRnfHB1a0a3IDJRpW1hHRTKRpp5AweuuynnqaLksmYvr2m8c6x5AExvDc56dZC9fdX1siUgeU(8KRLbijnixfzZWdHv)nVRQoHC9DU(IH4AjexdcxBPGOyBhPGaCLiCqIVaOOkfRWcBriLGWZsM6iH9cc23R)DjigEFu8fdzMyaxjchK4lakQsUEkxddakgcUEexFFMRNW1t5AB4AzassJ1MIWTAaAGBXUX1hM5AP56ZtUE49rXxmKrAd4kr4GeFbqrvY1wY1t5AyaqXqW1J46dC9456PCTmajPb5QiBgMfVBageefB7ifeixfPCqxXkSyCesji8SKPosyVGG996FxccB4AweuuynnqaLksmYvr2m8c6x5AExvDc567C94pMRNY1WbNsXB9x(cnTAGgWosU(WmxdcxBjxFEY1SiOOWAAGakvKyKRISz4f0VY18UQ6eY1h46jGiik22rkiGakvK4rBQt2EIeRWIJiKsq4zjtDKWEbb771)UeeSiOOWAAGakvKyKRISz4f0VY18UQ6eY1356Jiik22rkiKBQdzbWF5y5qj7puSclMCSqkbHNLm1rc7feSVx)7sqadakgcUEexFGRLixpLRLbijnixfzZWS4DdCl2nU(WmxdIGOyBhPGagaumC)(MlwHftMiKsq4zjtDKWEbb771)UeeWaGIHGRhX1hM5AP56PCTmajPb5QiBgMfVBag46PCTnCTmajPb5QiBgMfVBGBXUX13N5AP56ZtUwgGK0GCvKndZI3nVRQoHC9HzU(IH4AjexlrJTW1wkik22rkiqUks5GUIvyXeqesji8SKPosyVGOyBhPGafHsqWaLrD8w)LVqHfteeQschZaLrD8w)LVqbHTiiyFV(3LG4DY3HGlzQlwHftKwiLGWZsM6iH9cIITDKccwrP4ITDKyAdxbbTHlolLliKbAkcxyi46rIvSIvSIvia]] )
end
