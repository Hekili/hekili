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
            cooldown = 90,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            toggle = 'cooldowns',

            startsCombat = true,
            texture = 136216,
            
            handler = function ()
                summon_demon( "grimoire_felguard", 15 )
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


    spec:RegisterPack( "Demonology", 20180717.0101, [[dmKaIaqiuvvpcvvInbjgfqLtbu1QqvLQxbPmlPuUfGiTlj9lGyyuv1XasltkvpdvftdskxdvL2gKu9naHghGGZbikRdvvH5bj5EaSpuLoiQQsleO8quvrAIOQcxevvrJevveNevvsRujANaQHciINQutvk5QaIQ(kQQO2Rk)fXGLQdtAXq8yKMmkxMyZuLptvz0sXPv8AufZwv3wIDl8BrdxjTCqphQPt56OY2Hu9DLW4rvLY5PQY6bevMpG0(PYhOxRBZutoGB3Fqbc(debfiw9hu)bT9BB(Tk3EvP8O(KBhArUn)qkzKF6ZVBVQ(9PYUw3gNCqQC7gZwX8hGaIVXA4qQ0SacEkCVAtguO6zGGNcfeKprabXtbszc6GSctV5fmiTgb2oOG0QDqj8Zk8tkpe(HuYi)0NFv8uO3gHBEJFnoKBZutoGB3Fqbc(debfiw93F(I68HV3gVk0d42rDu)2mbtVDRMb76d21TgX1zINY9MRVQuEuFIR7LqxNFiLmYp95NRZpRWpP8GD9jCDWuZEX19sORZFbYjW0AQULULajj2asNYAcnxN2OHpbZF4wcA11DD(7)5cxNFiLmgQR3YpOgMRBPRJiUoMRuYqyU(IgjCD)soxVrrxC9DY9U(UrHmC1TS9QR76a5XIRJW55vdXAeiznHM(vUvxFcSjkZ1tpxNM5ZYfHRZ4GQnz46Ej01dXAeiznHM(eLAd6IRRuBYW1)bBv3s(uDDxN)YycZ1vxFfk0SGOMRdKKleORVN1MmC9XZ19l5C9gfDX15xJqGUo)qkzGD9e66P1iqxFkRyxNBTE7vy6nVCB(fxN)KFtOCMWCDeXlHIRtZcIAUoI4BcC115VuQSAyxpYaiTrHfpU31vQnzGD9mE)QULk1MmW1vOqZcIAa8EfZJBPsTjdCDfk0SGOgAaaXltMBPsTjdCDfk0SGOgAaar58vKWuBYWTuP2KbUUcfAwqudnaGG5kLmiRI5wQuBYaxxHcnliQHgaqMieiHjLmWTnEam9LWQtecKWKsg4QekYlm3sLAtg46kuOzbrn0aaco0vCtAeSPg2TuP2KbUUcfAwqudnaGWKsgi5BULk1MmW1vOqZcIAObaK10MmClDl5xCD(t(nHYzcZ1f0fOFUUnfX1TgX1vQLqxFWUUIUoVI8s1TuP2Kbgatkzmuc2Gs4ZAClvQnzGrdaiu9FIsTjdYpyRTqlcGqSgbswtOPFBJhatFjSAiwJajRj00VkHI8cZTuP2KbgnaGG5kLmiOpV4nsWAB8aqZ8z5IOI5kLmimPKXqjMFqnSkuk6eyE5J)afOGJM5ZYfrfZvkzqysjJHsm)GAyvOu0jWOcu)rHM5ZYfrLQ)tyqrzytFEeiUcLIobgvG6p4DlvQnzGrdai(GtjhOq8K3hNczULk1MmWObaKgnyK0J4J7zA024baNCpb3OqgVa4RBPsTjdmAaaPrdgj9i(4EMgTnEaWj3tWnkKXla(GcnZNLlIkv)NWGIYWM(8iqCfkfDcmVOgkGJ)n9LWQyUsjdc6ZlEJeSQekYlmGcuAMplxevmxPKbb95fVrcwfkfDcmVOg4DlvQnzGrdaiu9FcdkkdB6ZJaXULk1MmWObaeK5fmn5G(ecswqei2TuP2KbgnaGG5kLmimPKXqjMFqnS2gpaM(syvmxPKbb95fVrcwvcf5fgkiCEEvguug20NhbIRqPOtG5vP2KrfZvkzqysjJHsm)GAyvQInInfbfeopVk6ZlEJeSkuk6eyEvQnzuXCLsgeMuYyOeZpOgwLQyJytrClvQnzGrdaiyUsjdctkzmuI5hudRTXda)B6lHvXCLsge0Nx8gjyvjuKxyOGW55vzqrzytFEeiUcLIobMxLAtgvmxPKbHjLmgkX8dQHvPk2i2ueuWj3tWnkKbWF3sLAtgy0aaYAUqGe8S2KrBJhaeopV6I5zKPSIRytP8WlG2rbHZZRYKsgdLqtOuXMs5bvaAhfeopVktkzmuYAUqGvwUiClvQnzGrdaimPKbs(wBJhaCY9eCJczOcaFqbHZZRYKsgdLqtOu5wDlvQnzGrdaiSmlTr9J(cXuOpXWaaTTXda4m9LWQSmlvjuKxyOyk0NyvBkcXscBeEzCq1MmqbC8VnuEMWhqbkuk6eyuX4GQnzWV7FLpGh8ULk1MmWObaeQ(prP2Kb5hS1wOfbac38mIsWnkK5w6wQuBYaxr4MNrucUrHma4K7jydo8iULk1MmWveU5zeLGBuidnaGGBuwUGGKV5w6wQuBYaxdXAeiznHM(aO6)eLAtgKFWwBHweaHyncKSMqtFcc38Sj8124bGM5ZYfrneRrGK1eA6xHsrNaJQ293TuP2KbUgI1iqYAcn9rdaiu9FIsTjdYpyRTqlcGqSgbswtOPprP2GU024baHZZRgI1iqYAcn9RCRULULk1MmW1qSgbswtOPprP2GUaGQ)tyqrzytFEei2TuP2KbUgI1iqYAcn9jk1g0f0aasJgms6r8X9mnAB8aScf0j(OSkOvFWPKduiEY7JtHmGc0vOGoXhLvbTI5kLmiOpV4nsWClvQnzGRHyncKSMqtFIsTbDbnaG4doLCGcXtEFCkK5wQuBYaxdXAeiznHM(eLAd6cAaabZvkzqqFEXBKG5wQuBYaxdXAeiznHM(eLAd6cAaabzEbttoOpHGKfebIDlvQnzGRHyncKSMqtFIsTbDbnaGq1)jk1Mmi)GT2cTiaq4MNrucUrHS2gpa4K7j4gfYaakkGJM5ZYfrLQ)tyqrzytFEeiUcLIobgvk1MmQ4gLLlii5BvQInInfbOafCM(syvK5fmn5G(ecswqeiUkHI8cdfAMplxevK5fmn5G(ecswqeiUcLIobgvk1MmQ4gLLlii5BvQInInfb8G3TuP2KbUgI1iqYAcn9jk1g0f0aasJgms6r8X9mnAB8aaoWrZ8z5IOs1)jmOOmSPppcexHsrNaZRsTjJktkzGKVvPk2i2ueWJc4Oz(SCruP6)eguug20NhbIRqPOtG5vP2Krf3OSCbbjFRsvSrSPiGh8OqZ8z5IOgI1iqYAcn9RqPOtG5fCGI6(JMsTjJAJgms6r8X9mnQufBeBkc4DlvQnzGRHyncKSMqtFIsTbDbnaGG5kLmimPKXqjMFqnS2gpaiCEE1qSgbswtOPFfkfDcmQa1FuWj3tWnkKbWF3sLAtg4AiwJajRj00NOuBqxqdaiyUsjdctkzmuI5hudRTXdacNNxneRrGK1eA6xHsrNaJkLAtgvmxPKbHjLmgkX8dQHvPk2i2ue04BLVULk1MmW1qSgbswtOPprP2GUGgaqysjdK8T2gpaiCEEvMuYyOeAcLk3QBPsTjdCneRrGK1eA6tuQnOlObaeQ(prP2Kb5hS1wOfbac38mIsWnkK5w6wQuBYaxdXAeiznHM(eeU5zt4dqiwJajRj00VTXdao5EcUrHmEbWxuah)B6lHvxZfcKGN1MmQsOiVWakqr488QmPKXqj0ekvUvW7wQuBYaxdXAeiznHM(eeU5zt4dnaGq1)jmOOmSPppce7wQuBYaxdXAeiznHM(eeU5zt4dnaG0ObJKEeFCptJ2gpa0mFwUiQu9FcdkkdB6ZJaXvOu0jW8ckqafCY9eCJcz8cGpULk1MmW1qSgbswtOPpbHBE2e(qdaiR5cbsWZAtgTnEaq488QlMNrMYkUInLYdVaAhfeopVktkzmucnHsfBkLhubODuq488QmPKXqjR5cbwz5IafCY9eCJcz8cGpULk1MmW1qSgbswtOPpbHBE2e(qdainAWiPhXh3Z0OTXdao5EcUrHmEbWx3sLAtg4AiwJajRj00NGWnpBcFObaeQ(prP2Kb5hS1wOfbac38mIsWnkKDB0fiEY4aUD)bfi4pQ3oQvbf14lFV9cfgt4dF7BRCwtcVn)eny4SiU(Ek8tDDGejxF52)Gn8162mXt5E7ADad6162k1MmUntkzmuc2Gs4ZAUTekYlSdSZoGB)ADBjuKxyhy3MchtGJEBtFjSAiwJajRj00VkHI8c72k1MmUnv)NOuBYG8d2U9pyJeArUDiwJajRj00)Sdy(CTUTekYlSdSBtHJjWrVnnZNLlIkMRuYGWKsgdLy(b1WQqPOtGDDEDD(4VRduG66GZ1Pz(SCruXCLsgeMuYyOeZpOgwfkfDcSRJkxhu)DDuCDAMplxevQ(pHbfLHn95rG4kuk6eyxhvUoO(76G)2k1MmUnMRuYGG(8I3ib7Sdyu7ADBLAtg32hCk5afIN8(4ui72sOiVWoWo7aMVxRBlHI8c7a72u4ycC0BJtUNGBuiZ15fGRZ3BRuBY42nAWiPhXh3Z04Sdyu)ADBjuKxyhy3MchtGJEBCY9eCJczUoVaCD(46O460mFwUiQu9FcdkkdB6ZJaXvOu0jWUoVUoQ56O46GZ15Fx30xcRI5kLmiOpV4nsWQsOiVWCDGcuxNM5ZYfrfZvkzqqFEXBKGvHsrNa76866OMRd(BRuBY42nAWiPhXh3Z04SdyG4162k1MmUnv)NWGIYWM(8iq8TLqrEHDGD2bmq4ADBLAtg3gzEbttoOpHGKfebIVTekYlSdSZoGbYUw3wcf5f2b2TPWXe4O320xcRI5kLmiOpV4nsWQsOiVWCDuCDeopVkdkkdB6ZJaXvOu0jWUoVUUsTjJkMRuYGWKsgdLy(b1WQufBeBkIRJIRJW55vrFEXBKGvHsrNa76866k1MmQyUsjdctkzmuI5hudRsvSrSPi3wP2KXTXCLsgeMuYyOeZpOg2zhWG6)162sOiVWoWUnfoMah928VRB6lHvXCLsge0Nx8gjyvjuKxyUokUocNNxLbfLHn95rG4kuk6eyxNxxxP2KrfZvkzqysjJHsm)GAyvQInInfX1rX1Xj3tWnkK56aCD)VTsTjJBJ5kLmimPKXqjMFqnSZoGbf0R1TLqrEHDGDBkCmbo6Tr488QlMNrMYkUInLYJRZlaxVDxhfxhHZZRYKsgdLqtOuXMs5X1rfaxVDxhfxhHZZRYKsgdLSMleyLLlIBRuBY42R5cbsWZAtgNDadA7xRBlHI8c7a72u4ycC0BJtUNGBuiZ1rfaxNpUokUocNNxLjLmgkHMqPYTEBLAtg3MjLmqY3o7agu(CTUTekYlSdSBRuBY42Sml3MchtGJEBW56M(syvwMLQekYlmxhfx3uOpXQ2ueILe2iUoVUoJdQ2KHRJIRdoxN)DDBO8mHpxhOa11HsrNa76OY1zCq1MmCD(Dx3)kFCDW76G)2u)OVqmf6tm8bmONDadkQDTUTekYlSdSBRuBY42u9FIsTjdYpy72)GnsOf52iCZZikb3Oq2zND7vOqZcIAxRdyqVw3wcf5f2b2zhWTFTUTekYlSdSZoG5Z162sOiVWoWo7ag1Uw3wP2KXTXCLsgKvXUTekYlSdSZoG57162sOiVWoWUnfoMah92M(sy1jcbsysjdCvcf5f2TvQnzC7jcbsysjd8zhWO(162sOiVWoWo7agiETUTsTjJBZKsgi5B3wcf5f2b2zhWaHR1TvQnzC710MmUTekYlSdSZoGbYUwhWGETo72sOiVWoWUTsTjJBVMleibpRnzCBkCmbo6Tr488QlMNrMYkUInLYJRZlaxV9Zo72HyncKSMqt)R1bmOxRBlHI8c7a72u4ycC0BtZ8z5IOgI1iqYAcn9RqPOtGDDu56T7)TvQnzCBQ(prP2Kb5hSD7FWgj0IC7qSgbswtOPpbHBE2e(o7aU9R1TLqrEHDGDBkCmbo6Tr488QHyncKSMqt)k36TvQnzCBQ(prP2Kb5hSD7FWgj0IC7qSgbswtOPprP2GUC2z3oeRrGK1eA6tq4MNnHVR1bmOxRBlHI8c7a72u4ycC0BJtUNGBuiZ15fGRZxxhfxhCUo)76M(sy11CHaj4zTjJQekYlmxhOa11r488QmPKXqj0ekvUvxh83wP2KXTdXAeiznHM(NDa3(162k1MmUnv)NWGIYWM(8iq8TLqrEHDGD2bmFUw3wcf5f2b2TPWXe4O3MM5ZYfrLQ)tyqrzytFEeiUcLIob21511bfi46O464K7j4gfYCDEb46852k1MmUDJgms6r8X9mno7ag1Uw3wcf5f2b2TPWXe4O3gHZZRUyEgzkR4k2ukpUoVaC92DDuCDeopVktkzmucnHsfBkLhxhvaC92DDuCDeopVktkzmuYAUqGvwUiCDuCDCY9eCJczUoVaCD(CBLAtg3EnxiqcEwBY4Sdy(ETUTekYlSdSBtHJjWrVno5EcUrHmxNxaUoFVTsTjJB3ObJKEeFCptJZoGr9R1TLqrEHDGDBLAtg3MQ)tuQnzq(bB3(hSrcTi3gHBEgrj4gfYo7SBJWnpJOeCJczxRdyqVw3wP2KXTXj3tWgC4rUTekYlSdSZoGB)ADBLAtg3g3OSCbbjF72sOiVWoWo7SBhI1iqYAcn9jk1g0LR1bmOxRBRuBY42u9FcdkkdB6ZJaX3wcf5f2b2zhWTFTUTekYlSdSBtHJjWrV9kuqN4JYQGw9bNsoqH4jVpofYCDGcuxFfkOt8rzvqRyUsjdc6ZlEJeSBRuBY42nAWiPhXh3Z04Sdy(CTUTsTjJB7doLCGcXtEFCkKDBjuKxyhyNDaJAxRBRuBY42yUsjdc6ZlEJeSBlHI8c7a7Sdy(ETUTsTjJBJmVGPjh0NqqYcIaX3wcf5f2b2zhWO(162sOiVWoWUnfoMah924K7j4gfYCDaUoOUokUo4CDAMplxevQ(pHbfLHn95rG4kuk6eyxhvUUsTjJkUrz5ccs(wLQyJytrCDGcuxhCUUPVewfzEbttoOpHGKfebIRsOiVWCDuCDAMplxevK5fmn5G(ecswqeiUcLIob21rLRRuBYOIBuwUGGKVvPk2i2uexh8Uo4VTsTjJBt1)jk1Mmi)GTB)d2iHwKBJWnpJOeCJczNDadeVw3wcf5f2b2TPWXe4O3gCUo4CDAMplxevQ(pHbfLHn95rG4kuk6eyxNxxxP2KrLjLmqY3QufBeBkIRdExhfxhCUonZNLlIkv)NWGIYWM(8iqCfkfDcSRZRRRuBYOIBuwUGGKVvPk2i2uexh8Uo4DDuCDAMplxe1qSgbswtOPFfkfDcSRZRRdoxhuu3FxhnxxP2KrTrdgj9i(4EMgvQInInfX1b)TvQnzC7gnyK0J4J7zAC2bmq4ADBjuKxyhy3MchtGJEBeopVAiwJajRj00VcLIob21rLRdQ)UokUoo5EcUrHmxhGR7)TvQnzCBmxPKbHjLmgkX8dQHD2bmq2162sOiVWoWUnfoMah92iCEE1qSgbswtOPFfkfDcSRJkxxP2KrfZvkzqysjJHsm)GAyvQInInfX1rZ15BLV3wP2KXTXCLsgeMuYyOeZpOg2zhWG6)162sOiVWoWUnfoMah92iCEEvMuYyOeAcLk36TvQnzCBMuYajF7Sdyqb9ADBjuKxyhy3wP2KXTP6)eLAtgKFW2T)bBKqlYTr4MNrucUrHSZo7SZo7oa]] )
end
