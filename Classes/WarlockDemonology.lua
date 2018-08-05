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
            texture = 236316,
            
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
            texture = 136135,
            
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
            texture = 132182,
            
            handler = function ()
            end,
        },
        

        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538043,
            
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
            texture = 1378282,
            
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
            texture = 236292,
            
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
            texture = 538745,
            
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
            texture = 136194,
            
            handler = function ()
            end,
        },
        

        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538538,

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
            texture = 2032588,
            
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
            texture = 237559,

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
            texture = 237560,

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
            texture = 607512,
            
            handler = function ()
            end,
        },
        

        demonic_strength = {
            id = 267171,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236292,
            
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
            texture = 136122,

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
            texture = 136169,
            
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
            texture = 136154,
            
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
            texture = 136155,
            
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
            texture = 136183,
            
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
            texture = 136216,
            
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
            texture = 535592,
            
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
            texture = 136168,
            
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
            texture = 2065588,
            
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
            texture = 607853,
            
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
            texture = 2065615,
            
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
            texture = 236290,
            
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
            texture = 136223,
            
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
            texture = 136197,
            
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
            texture = 607865,
            
            handler = function ()
            end,
        },
        

        soul_strike = {
            id = 264057,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1452864,
            
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
            texture = 136210,
            
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
            texture = 2065628,
            
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
            texture = 136216,

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
            texture = 1616211,
            
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
            texture = 136148,
            
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
            texture = 136150,
            
            handler = function ()
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
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


    spec:RegisterPack( "Demonology", 20180718.0115, [[dm0nIaqiQQKhHQsPnbjgLQkDkvvSkuvQ6vqkZIQQULIsLDjPFPQ0WuuCmvjltvkpdvftdskxtrjBdvL8nQQuJdsQohvvK1rvf08GKCpvX(qv6GuvrTqvv9qfLQAIuvHUiQkvgjQkfoPIsvwPIQDQQyOkkLEQsnvfQRIQsrFLQkWEv5VinyLCyslgIhJyYOCzIntv(mvLrRGtl1RHunBGBlXUf(TOHRilh0ZHA6uUoQSDufFxHmEfLcNhvvRxrPO5Rkv7NkFVUX3MPMCFEBMxO(m(9luVoZRxO2l(62g)tYTNuc6Qp52HwKB7hLsgji9X)TNu(bPYUX3gNCqIC7bZMW(HF)6RTboKkjlFXDHdOwNbbQE2xCxiFrajYxepD2XeE(obtVgi4VJBb(2RVJF7f1pqHGKGo1pkLmsq6J)kUlKBJW1aB2loKBZutUpVnZluFg)(fQxN51Rx8XpDB8KqUpVXx81TzcMC7Xdn2TASBzdIBXepLdyU1Ksqx9jULxcDl)OuYibPp(Dl)afcsc6y3Qd36VAgqClVe6w(5ztbM2q1n3nF2MyB21LPeAUfzqdFc2p0n)v1TCl)maKJCl)OuYOjU1y(HAyULLUfI4wyUsjdH5wJgKWT4p5CRbLhXT2jhWT2dkKHRU5VvDl3IVjwCleopVAi2GaPtj0uqLBYT6aBIYCR0ZTizcy5OWTyCq16mClVe6wHydcKoLqtbuLynpIBPeRZWTan2QU58P6wULFMXeMBPU1euizbrn3A2MJeOBT7PHmCR2ZT4p5CRbLhXTEZT6Ye2TS0TizG5kIB9RNia(jq1Z(PE7jy61a528TUfF3SHq4mH5wiIxcf3IKfe1CleXxh4QB5NjezYWUvKXSBqHfpoGBPeRZa7wza4V6MReRZaxNGcjliQ94bum6U5kX6mW1jOqYcIAO981ltMBUsSodCDckKSGOgApFvoFfjm16mCZvI1zGRtqHKfe1q75lMRuYGojMBUsSodCDckKSGOgApF7ieiLjLmW(3EpMcKWQDecKYKsg4QekcqyU5kX6mW1jOqYcIAO98fh6eEink2ud7MReRZaxNGcjliQH2Z3PCKaP4EAid)BVheopV6OgWODzcxXMsqN3xU5kX6mW1jOqYcIAO98LjLmqsG5MReRZaxNGcjliQH2Z3P06mCZDZ5BDl(UzdHWzcZTeEei)UL1fXTSbXTuILq3QXULYJ2afbiv3CLyDg4hMuYOjuSbLWNn4MReRZaJ2ZxIcauLyDguqJn)dTipHydcKoLqtb(3EpMcKWQHydcKoLqtbvjueGWCZvI1zGr75lMRuYGYtdeVwcM)T3djtalhfvmxPKbLjLmAc14hQHvHsr7aZlFM593)LKjGLJIkMRuYGYKsgnHA8d1WQqPODGr1RzqHKjGLJIkrbakdkkdBkaDbIRqPODGr1Rz(XnxjwNbgTNV(GDjBOq9eGpofYCZvI1zGr757GgmA6r9XbyA4F79GtoafpOqgVpZYnxjwNbgTNVdAWOPh1hhGPH)T3do5au8Gcz8(Whuizcy5OOsuaGYGIYWMcqxG4kukAhyErnu(1VmfiHvXCLsguEAG41sWQsOiaH9(7KmbSCuuXCLsguEAG41sWQqPODG5f1(XnxjwNbgTNVefaOmOOmSPa0fi2nxjwNbgTNVinqWKKd6tOizbrGy3CLyDgy0E(I5kLmOmPKrtOg)qnm)BVhtbsyvmxPKbLNgiETeSQekcqyOGW55vzqrzytbOlqCfkfTdmVkX6mQyUsjdktkz0eQXpudRsuSrTUiOGW55v5PbIxlbRcLI2bMxLyDgvmxPKbLjLmAc14hQHvjk2Owxe3CLyDgy0E(I5kLmOmPKrtOg)qnm)BVh)YuGewfZvkzq5PbIxlbRkHIaegkiCEEvguug2ua6cexHsr7aZRsSoJkMRuYGYKsgnHA8d1WQefBuRlck4KdqXdkK9mJBUsSodmApFNYrcKI7PHm8V9Eq488QJAaJ2LjCfBkbDEFEdfeopVktkz0ekjHsfBkbDu98gkiCEEvMuYOj0PCKaRSCu4MReRZaJ2ZxMuYajbM)T3do5au8GczO6HpOGW55vzsjJMqjjuQCtU5kX6mWO98LLzXFc)eGqnf6tm8Zl)BVNFnfiHvzzwQsOiaHHIPqFIvTUiulPSw4LXbvRZaLF9lRjO3HV3FhkfTdmQyCq16m47NPYNF(XnxjwNbgTNVefaOkX6mOGgB(hArEq4AaJQu8GczU5U5kX6mWveUgWOkfpOq2do5auSbB0f3CLyDg4kcxdyuLIhuidTNV4bLLJOijWCZDZvI1zGRHydcKoLqtbpefaOkX6mOGgB(hArEcXgeiDkHMcOiCnG1Hp)BVhsMawokQHydcKoLqtbvOu0oWO6TzCZvI1zGRHydcKoLqtbO98LOaavjwNbf0yZ)qlYti2GaPtj0uavjwZJ4F79GW55vdXgeiDkHMcQCtU5U5kX6mW1qSbbsNsOPaQsSMh5HOaaLbfLHnfGUaXU5kX6mW1qSbbsNsOPaQsSMhbTNVdAWOPh1hhGPH)T3Zeu4H6JWQVQ(GDjBOq9eGpofYE)9jOWd1hHvFvXCLsguEAG41sWCZvI1zGRHydcKoLqtbuLynpcApF9b7s2qH6jaFCkK5MReRZaxdXgeiDkHMcOkXAEe0E(I5kLmO80aXRLG5MReRZaxdXgeiDkHMcOkXAEe0E(I0abtsoOpHIKfebIDZvI1zGRHydcKoLqtbuLynpcApFjkaqvI1zqbn28p0I8GW1agvP4bfY8V9EWjhGIhui75fk)sYeWYrrLOaaLbfLHnfGUaXvOu0oWOsjwNrfpOSCefjbwLOyJADrE)9FnfiHvrAGGjjh0NqrYcIaXvjueGWqHKjGLJIksdemj5G(ekswqeiUcLI2bgvkX6mQ4bLLJOijWQefBuRlYp)4MReRZaxdXgeiDkHMcOkXAEe0E(oObJMEuFCaMg(3Ep)(ljtalhfvIcauguug2ua6cexHsr7aZRsSoJktkzGKaRsuSrTUi)GYVKmbSCuujkaqzqrzytbOlqCfkfTdmVkX6mQ4bLLJOijWQefBuRlYp)Gcjtalhf1qSbbsNsOPGkukAhyE)9fFndAkX6mQdAWOPh1hhGPrLOyJADr(XnxjwNbUgIniq6ucnfqvI18iO98fZvkzqzsjJMqn(HAy(3EpiCEE1qSbbsNsOPGkukAhyu9AguWjhGIhui7zg3CLyDg4Ai2GaPtj0uavjwZJG2ZxmxPKbLjLmAc14hQH5F79GW55vdXgeiDkHMcQqPODGrLsSoJkMRuYGYKsgnHA8d1WQefBuRlcAZQol3CLyDg4Ai2GaPtj0uavjwZJG2ZxMuYajbM)T3dcNNxLjLmAcLKqPYn5MReRZaxdXgeiDkHMcOkXAEe0E(suaGQeRZGcAS5FOf5bHRbmQsXdkK5M7MReRZaxdXgeiDkHMcOiCnG1HVNqSbbsNsOPa)BVhCYbO4bfY49zwO8RFzkqcRoLJeif3tdzuLqrac793r488QmPKrtOKekvUPFCZvI1zGRHydcKoLqtbueUgW6WhApFjkaqzqrzytbOlqSBUsSodCneBqG0PeAkGIW1awh(q757GgmA6r9XbyA4F79qYeWYrrLOaaLbfLHnfGUaXvOu0oW8(c1rbNCakEqHmEF4JBUsSodCneBqG0PeAkGIW1awh(q757uosGuCpnKH)T3dcNNxDudy0UmHRytjOZ7ZBOGW55vzsjJMqjjuQytjOJQN3qbHZZRYKsgnHoLJeyLLJcuWjhGIhuiJ3h(4MReRZaxdXgeiDkHMcOiCnG1Hp0E(oObJMEuFCaMg(3Ep4KdqXdkKX7ZSCZvI1zGRHydcKoLqtbueUgW6WhApFjkaqvI1zqbn28p0I8GW1agvP4bfYUnpce3zCFEBMxO(m(9l)UoZRzED7rkm6Wh(23g0ydFJVnt8uoGDJVpVUX3wjwNXTzsjJMqXgucF2WTLqrac7(F295TB8TLqrac7(FBLyDg3MOaavjwNbf0y72eyBcS1BBkqcRgIniq6ucnfuLqrac72GgB0qlYTdXgeiDkHMco7(WNB8TLqrac7(FBcSnb26Tjzcy5OOI5kLmOmPKrtOg)qnSkukAhy3Ix3IpZ4wV)UB9RBrYeWYrrfZvkzqzsjJMqn(HAyvOu0oWUfQCRxZ4wO4wKmbSCuujkaqzqrzytbOlqCfkfTdSBHk361mU1p3wjwNXTXCLsguEAG41sWo7(GA34BReRZ42(GDjBOq9eGpofYUTekcqy3)ZUpZ6gFBjueGWU)3MaBtGTEBCYbO4bfYClEFCRzDBLyDg3Eqdgn9O(4amno7(Wx34BlHIae29)2eyBcS1BJtoafpOqMBX7JBXh3cf3IKjGLJIkrbakdkkdBkaDbIRqPODGDlEDluZTqXT(1T8l3YuGewfZvkzq5PbIxlbRkHIaeMB9(7UfjtalhfvmxPKbLNgiETeSkukAhy3Ix3c1CRFUTsSoJBpObJMEuFCaMgNDF87B8TvI1zCBIcauguug2ua6ceFBjueGWU)NDFq9B8TvI1zCBKgiysYb9juKSGiq8TLqrac7(F29XpDJVTekcqy3)BtGTjWwVTPajSkMRuYGYtdeVwcwvcfbim3cf3cHZZRYGIYWMcqxG4kukAhy3Ix3sjwNrfZvkzqzsjJMqn(HAyvIInQ1fXTqXTq488Q80aXRLGvHsr7a7w86wkX6mQyUsjdktkz0eQXpudRsuSrTUi3wjwNXTXCLsguMuYOjuJFOg2z3NxZCJVTekcqy3)BtGTjWwVTF5wMcKWQyUsjdkpnq8AjyvjueGWCluCleopVkdkkdBkaDbIRqPODGDlEDlLyDgvmxPKbLjLmAc14hQHvjk2Owxe3cf3cNCakEqHm36XTM52kX6mUnMRuYGYKsgnHA8d1Wo7(861n(2sOiaHD)Vnb2MaB92iCEE1rnGr7YeUInLGUBX7JB9MBHIBHW55vzsjJMqjjuQytjO7wO6XTEZTqXTq488QmPKrtOt5ibwz5O42kX6mU9uosGuCpnKXz3NxVDJVTekcqy3)BtGTjWwVno5au8GczUfQECl(4wO4wiCEEvMuYOjuscLk30TvI1zCBMuYajb2z3Nx85gFBjueGWU)3MaBtGTE7FDltbsyvwMLQekcqyUfkULPqFIvTUiulPSwClEDlghuTod3cf36x3YVClRjO3Hp3693DlOu0oWUfQClghuTod3IV3TMPYh36h36NBReRZ42Sml3MWpbiutH(edFFED295fQDJVTekcqy3)BReRZ42efaOkX6mOGgB3g0yJgArUncxdyuLIhui7SZU9euizbrTB8951n(2sOiaHD)p7(82n(2sOiaHD)p7(WNB8TLqrac7(F29b1UX3wjwNXTXCLsg0jXUTekcqy3)ZUpZ6gFBjueGWU)3MaBtGTEBtbsy1ocbszsjdCvcfbiSBReRZ42DecKYKsg4ZUp81n(2sOiaHD)p7(4334BlHIae29)2eyBcS1BJW55vh1agTlt4k2uc6UfVU1RBReRZ42t5ibsX90qgNDFq9B8TvI1zCBMuYajb2TLqrac7(F29XpDJVTsSoJBpLwNXTLqrac7(F2z3oeBqG0PeAk4gFFEDJVTekcqy3)BReRZ42efaOkX6mOGgB3MaBtGTEBsMawokQHydcKoLqtbvOu0oWUfQCR3M52GgB0qlYTdXgeiDkHMcOiCnG1HVZUpVDJVTekcqy3)BReRZ42efaOkX6mOGgB3MaBtGTEBeopVAi2GaPtj0uqLB62GgB0qlYTdXgeiDkHMcOkXAEKZo72HydcKoLqtbueUgW6W3n((86gFBjueGWU)3MaBtGTEBCYbO4bfYClEFCRz5wO4w)6w(LBzkqcRoLJeif3tdzuLqracZTE)D3cHZZRYKsgnHssOu5MCRFUTsSoJBhIniq6ucnfC295TB8TvI1zCBIcauguug2ua6ceFBjueGWU)NDF4Zn(2sOiaHD)Vnb2MaB92KmbSCuujkaqzqrzytbOlqCfkfTdSBXRB9c1DluClCYbO4bfYClEFCl(CBLyDg3Eqdgn9O(4amno7(GA34BlHIae29)2eyBcS1BJW55vh1agTlt4k2uc6UfVpU1BUfkUfcNNxLjLmAcLKqPInLGUBHQh36n3cf3cHZZRYKsgnHoLJeyLLJc3cf3cNCakEqHm3I3h3Ip3wjwNXTNYrcKI7PHmo7(mRB8TLqrac7(FBcSnb26TXjhGIhuiZT49XTM1TvI1zC7bny00J6JdW04S7dFDJVTekcqy3)BReRZ42efaOkX6mOGgB3g0yJgArUncxdyuLIhui7SZUncxdyuLIhui7gFFEDJVTsSoJBJtoafBWgD52sOiaHD)p7(82n(2kX6mUnEqz5ikscSBlHIae29)SZUDi2GaPtj0uavjwZJCJVpVUX3wjwNXTjkaqzqrzytbOlq8TLqrac7(F295TB8TLqrac7(FBcSnb26TNGcpuFew9v1hSlzdfQNa8XPqMB9(7U1eu4H6JWQVQyUsjdkpnq8Ajy3wjwNXTh0GrtpQpoatJZUp85gFBLyDg32hSlzdfQNa8XPq2TLqrac7(F29b1UX3wjwNXTXCLsguEAG41sWUTekcqy3)ZUpZ6gFBLyDg3gPbcMKCqFcfjliceFBjueGWU)NDF4RB8TLqrac7(FBLyDg3MOaavjwNbf0y72eyBcS1BJtoafpOqMB94wVCluCRFDlsMawokQefaOmOOmSPa0fiUcLI2b2TqLBPeRZOIhuwoIIKaRsuSrTUiU17V7w)6wMcKWQinqWKKd6tOizbrG4QekcqyUfkUfjtalhfvKgiysYb9juKSGiqCfkfTdSBHk3sjwNrfpOSCefjbwLOyJADrCRFCRFUnOXgn0ICBeUgWOkfpOq2z3h)(gFBjueGWU)3MaBtGTE7FDRFDlsMawokQefaOmOOmSPa0fiUcLI2b2T41TuI1zuzsjdKeyvIInQ1fXT(XTqXT(1Tizcy5OOsuaGYGIYWMcqxG4kukAhy3Ix3sjwNrfpOSCefjbwLOyJADrCRFCRFCluClsMawokQHydcKoLqtbvOu0oWUfVU1VU1l(Ag3cn3sjwNrDqdgn9O(4amnQefBuRlIB9ZTvI1zC7bny00J6JdW04S7dQFJVTekcqy3)BtGTjWwVncNNxneBqG0PeAkOcLI2b2TqLB9Ag3cf3cNCakEqHm36XTM52kX6mUnMRuYGYKsgnHA8d1Wo7(4NUX3wcfbiS7)TjW2eyR3gHZZRgIniq6ucnfuHsr7a7wOYTuI1zuXCLsguMuYOjuJFOgwLOyJADrCl0CRzvN1TvI1zCBmxPKbLjLmAc14hQHD2951m34BlHIae29)2eyBcS1BJW55vzsjJMqjjuQCt3wjwNXTzsjdKeyNDFE96gFBjueGWU)3wjwNXTjkaqvI1zqbn2UnOXgn0ICBeUgWOkfpOq2zND2TvoBiH3MVHgmCwe3A3LzF3A2k5eqo7S7a]] )
end
