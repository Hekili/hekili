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
            if dreadstalkers[ i ] < state.now then
                table.remove( dreadstalkers, i )
            else
                i = i + 1
            end
        end
        
        wipe( dreadstalkers_v )
        for n, t in ipairs( dreadstalkers ) do dreadstalkers_v[ n ] = t end


        i = 1
        while( vilefiend[ i ] ) do
            if vilefiend[ i ] < state.now then
                table.remove( vilefiend, i )
            else
                i = i + 1
            end
        end
        
        wipe( vilefiend_v )
        for n, t in ipairs( vilefiend ) do vilefiend_v[ n ] = t end


        --[[ i = 1
        while( wild_imps[ i ] ) do
            if wild_imps[ i ] < state.now then
                table.remove( wild_imps, i )
            else
                i = i + 1
            end
        end

        for n, t in ipairs( wild_imps ) do wild_imps_v[ n ] = t end ]]

        for id, imp in pairs( imps ) do
            if imp.expires < state.now then
                imps[ id ] = nil
            end
        end

        wipe( wild_imps_v )
        for n, t in pairs( imps ) do table.insert( wild_imps_v, t.expires ) end
        table.sort( wild_imps_v )


        i = 1
        while( demonic_tyrant[ i ] ) do
            if demonic_tyrant[ i ] < state.now then
                table.remove( demonic_tyrant, i )
            else
                i = i + 1
            end
        end

        wipe( demonic_tyrant_v )
        for n, t in ipairs( demonic_tyrant ) do demonic_tyrant_v[ n ] = t end


        i = 1
        while( other_demon[ i ] ) do
            if other_demon[ i ] < state.now then
                table.remove( other_demon, i )
            else
                i = i + 1
            end
        end

        wipe( other_demon_v )
        for n, t in ipairs( other_demon ) do other_demon_v[ n ] = t end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shard" and state.buff.nether_portal.up then
            state.summon_demon( "other", 15, amt )
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
            spendType = "soul_shard",

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
            spendType = "soul_shard",
            
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
                gain( 2, 'soul_shard' )
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
            spendType = "soul_shard",
            
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
            spendType = "soul_shard",
            
            startsCombat = true,
            texture = 535592,
            
            -- usable = function () return soul_shard.current >= 3 end,
            handler = function ()
                local extra_shards = min( 2, soul_shard.current )
                spend( extra_shards, "soul_shard" )
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
            spendType = "soul_shard",
            
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
                gain( 1, 'soul_shard' )
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
                gain( 1, "soul_shard" )
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
            end,
        },

        
        summon_pet = {
            id = 30146,
            cast = function () return 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shard",

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
            spendType = "soul_shard",

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


    spec:RegisterPack( "Demonology", 20180624.1455, [[dO04UaqivPspsvssBsO0NuvAucfoLqkRsvOQELQGzPkLBrOkXUuYViKggHkhtiAzeIEMqQMgHGRPkKTPkP(gHQyCQsvohHQuRtOO5je6EKs7tvIdQkjwOqYdvLkyIQsfDrvPc9rcvvJKqvsNuvQQvkuntcH2jcmuvjPAPQcfpLitvv0vvLKYxjuvwRQqvAVK8xbdwLdt1Ij4XinzOUmQntQ(mPy0i60kwTQKeVwvXSbDBLA3I(nLHRQ64QcvwoWZHmDjxNO2oc67i04vfkDEcL1RkufZxiy)sTks1tLe2lwrGifxKVN4ETifHvKIWJeHhfDLuj2pRK(D6hxdRKsFZkP3jVT0GMgXus)UyqZXQNkjKjdOSsISQFumfv0FhvSWKlQTff4efLfIsw4XlMOssqEG17NQOusyVyfbIuCr(EI71IuewrkcpkYhjEusOFMQiqKV(1kjmJOkPNKdQVb1xrY9HzDxgw9970pUgUpDd037K3wAqtJy9j(Ca0OFq9nzFr5vb5(0nqFVYJhgyf5QJ3XFfuFMEFXLtUprkcV13u95))Sdq9vKE1xrY950ASSp4GkuFoG7dZOrtY4(CGjN4(EhCiSV3jVTCO99umGNvF8JT4epPM(ksUpSmWRXsuFw2h)yhunPM(W82Y((5c9wFejhkzFt13pGrCwqX6dBmQV0Q(W2QV(EsY99umGNvFuzaGZckwFVkYOQVpm)J6793)O(0b2UpbzqoPM(ksEJyiHmQptU6thy7(OoQMutFOFgcrV1NGC1NvKmG4G4(yczGyf5KA67vrgv9Xp2)bWO(sVKboek2QJ3XLS36Riza3Nd4(GZhgkwFusp1WO(sMXmE1X74D8xDdvIxM9VbQ(OKEQHrXSJh5QV(Efi0i237K3wo0(EkgWZQVY6tG7djV3wY4(isYzFIzY9r6eY9jzYW(KiDagT64IC1xFVAiUpbzD9vYfjdc)gOC4s(VVjrf74(m9(OMbXgXSpSmWRXY(0nqFjxKmi8BGYHbNwdHCFoTgl7doOAPK(bM(azL0RAFVJpwMkxmUpbw3aCFuBl4vFcSMjrR(EfkL)luFPLIxiDWwxg2NtRXsuFwcfB1XDAnwIw)aMABbV0QdD0NoUtRXs06hWuBl41dAfv3mCh3P1yjA9dyQTf86bTI6YA2CwEnw2XDAnwIw)aMABbVEqROi592YWpxDCNwJLO1pGP2wWRh0k6KjdcyEBj6TrxB5qoR1KjdcyEBjAXPlazCh3P1yjA9dyQTf86bTIIs)hrAvavEH64oTglrRFatTTGxpOvumVTuWGvh3P1yjA9dyQTf86bTI(B1yzhVJ)Q2374JLPYfJ7JjKbI1xnBUVIK7ZPLb6Bq95e6d0fG8QJ70ASePfZBlhAavao1uKDCNwJLOh0kk1HWGtRXYaCq1BPVzTjxKmi8BGYHVn6AlhYzTsUizq43aLdxC6cqg3XDAnwIEqROi592YaHdK1hoXVn6APMbXgXCHK3BldyEB5qdLyapRfG3(KOxIU4IqeIb1mi2iMlK8EBzaZBlhAOed4zTa82NefXifxSuZGyJyUOoegWa2XOYHFyaAb4TpjkIrkUO1XDAnwIEqROAaZ2gah0zOgzhG74oTglrpOvuspXbtpOrgI98TrxlYKHbePdWVO9rDCNwJLOh0kkPN4GPh0idXE(2ORfzYWaI0b4x0g9yPMbXgXCrDimGbSJrLd)Wa0cWBFs0lIqSX4DlhYzTqY7TLbchiRpCIxC6cqghHiqndInI5cjV3wgiCGS(WjEb4Tpj6friADCNwJLOh0kk1HWagWogvo8ddqDCNwJLOh0kQWaze1KbA4GGTfyaQJ70ASe9GwrrY7TLbmVTCOHsmGN1BJU2YHCwlK8EBzGWbY6dN4fNUaKXXkiRRVWa2XOYHFyaAb4Tpj6fNwJLlK8EBzaZBlhAOed4zTOoQc1S5yfK11xeoqwF4eVa82Ne9ItRXYfsEVTmG5TLdnuIb8SwuhvHA2Ch3P1yj6bTIIK3BldyEB5qdLyapR3gDTVB5qoRfsEVTmq4az9Ht8ItxaY4yfK11xya7yu5WpmaTa82Ne9ItRXYfsEVTmG5TLdnuIb8SwuhvHA2CSitggqKoaRvCDCNwJLOh0k6VrKbb08tA5BJUwbzD9fXbIdZ(hTqLt)8IwrgRGSU(cZBlhAGAaEHkN(jIAfzScY66lmVTCOHFJidwyJy2XDAnwIEqROyEBPGbR3gDTitggqKoahrTrpwbzD9fM3wo0a1a8s(VJ70ASe9GwrXMTFJkgfYHYbA4cPnY3gDTXOCiN1cB2EXPlazCSLd0W1QMnhklGh(fSmWRXYyJX7wd9ZKAIqea82NefrSmWRXYhFXTIE0Iwh3P1yj6bTIsDim40ASmahu9w6BwRG8aXbpGiDaUJ3XDAnwIwcYdeh8aI0byTitggqfy(WDCNwJLOLG8aXbpGiDa(bTIIiDSrmiyWQJ3XDAnwIwjxKmi8BGYHAPoegCAnwgGdQEl9nRn5IKbHFduomiipq8KAEB01sndInI5k5IKbHFduoCb4TpjkIIuCDCNwJLOvYfjdc)gOC4dAfL6qyWP1yzaoO6T03S2Klsge(nq5WGtRHq(Trxl1mi2iMRKlsge(nq5WfG3(KOxI81IRJ3XDAnwIwjxKmi8BGYHbNwdHSwQdHbmGDmQC4hgG64oTglrRKlsge(nq5WGtRHq(bTIs6joy6bnYqSNVn6A)bmHbnu8kYLgWSTbWbDgQr2b4ieHFatyqdfVICHK3BldeoqwF4e3XDAnwIwjxKmi8BGYHbNwdH8dAfvdy22a4God1i7aCh3P1yjALCrYGWVbkhgCAneYpOvuK8EBzGWbY6dN4oUtRXs0k5IKbHFduom40AiKFqROcdKrutgOHdc2wGbOoUtRXs0k5IKbHFduom40AiKFqROuhcdoTgldWbvVL(M1kipqCWdishGFB01Imzyar6aS2iJnguZGyJyUOoegWa2XOYHFyaAb4TpjkIoTglxishBedcgSwuhvHA2CeIqmkhYzTegiJOMmqdheSTadqloDbiJJLAgeBeZLWaze1KbA4GGTfyaAb4TpjkIoTglxishBedcgSwuhvHA2C0Iwh3P1yjALCrYGWVbkhgCAneYpOvuspXbtpOrgI98TrxBmIb1mi2iMlQdHbmGDmQC4hgGwaE7tIEXP1y5cZBlfmyTOoQc1S5OfBmOMbXgXCrDimGbSJrLd)Wa0cWBFs0loTglxishBedcgSwuhvHA2C0IwSuZGyJyUsUizq43aLdxaE7tIEjgr(AX9GtRXYfPN4GPh0idXEUOoQc1S5O1XDAnwIwjxKmi8BGYHbNwdH8dAffjV3wgW82YHgkXaEwVn6AfK11xjxKmi8BGYHlaV9jrrmsXflYKHbePdWAfxh3P1yjALCrYGWVbkhgCAneYpOvuK8EBzaZBlhAOed4z92ORvqwxFLCrYGWVbkhUa82NefrNwJLlK8EBzaZBlhAOed4zTOoQc1S5hE06rDCNwJLOvYfjdc)gOCyWP1qi)GwrX82sbdwVn6AfK11xyEB5qdudWl5)oUtRXs0k5IKbHFduom40AiKFqROuhcdoTgldWbvVL(M1kipqCWdishG74DCNwJLOvYfjdc)gOCyqqEG4j1On5IKbHFduo8TrxlYKHbePdWVO9rXgJ3TCiN163iYGaA(jTCXPlazCeIGGSU(cZBlhAGAaEj)hToUtRXs0k5IKbHFduomiipq8KAEqROuhcdya7yu5Wpma1XDAnwIwjxKmi8BGYHbb5bINuZdAfL0tCW0dAKHypFB01sndInI5I6qyadyhJkh(HbOfG3(KOxI89IfzYWaI0b4x0g9oUtRXs0k5IKbHFduomiipq8KAEqRO)grgeqZpPLVn6AfK11xehiom7F0cvo9ZlAfzScY66lmVTCObQb4fQC6NiQvKXkiRRVW82YHg(nImyHnIzSitggqKoa)I2O3XDAnwIwjxKmi8BGYHbb5bINuZdAfL0tCW0dAKHypFB01Imzyar6a8lAFuh3P1yjALCrYGWVbkhgeKhiEsnpOvuQdHbNwJLb4GQ3sFZAfKhio4bePdWkjczaASurGifxKVN4ETiJCf5JIu8wjr0b5KAqkjX3R8yi49jq8hZ(67jj33S)nq1NUb67lM1Dzy9Tpa)4KhaJ7dzBUpxUSTxmUpkPNAy0QJlItY9f9y23tYb1hNfqS(OKm9dQVIK7JAgeBeZ(0nqFFPMbXgXCHK3BldyEB5qdLyapRfG3(KOV9rKCOK9r9SpbUpaJKHvFt2NHX9jWKoHJb6B077l1mi2iMlK8EBzaZBlhAOed4zTa82Ne9TVb1xzA0azCFMUUO4b5cqgV64I4KCFrpM99KCq9XzbeRpkjt)G6Ri5(OMbXgXSpDd03xQzqSrmxi592YaM3wo0qjgWZAb4Tpj6BFejhkzFup7tG7dWizy13K9zyCFcmPt4yG(g9((sndInI5cjV3wgW82YHgkXaEwlaV9jrF7Bq9vMgnqg3NPRlkEqUaKXRoUioj3x0JzFpjhuFCwaX6JsY0pO(ksUpQzqSrm7t3a99LAgeBeZf1HWagWogvo8ddqlaV9jrF7Ji5qj7J6zFcCFagjdR(MSpdJ7tGjDchd03O33xQzqSrmxuhcdya7yu5WpmaTa82Ne9TVb1xzA0azCFMUUO4b5cqgV64I4KCFVoM99KCq9XzbeRpkjt)G6Ri5(OMbXgXSpDd03xQzqSrmxuhcdya7yu5WpmaTa82Ne9TpIKdLSpQN9jW9byKmS6BY(mmUpbM0jCmqFJEFFPMbXgXCrDimGbSJrLd)Wa0cWBFs03(guFLPrdKX9z66IIhKlaz8QJlItY996y23tYb1hNfqS(OKm9dQVIK7JAgeBeZ(0nqFFPMbXgXCHK3BldeoqwF4eVa82Ne9TpIKdLSpQN9jW9byKmS6BY(mmUpbM0jCmqFJEFFPMbXgXCHK3BldeoqwF4eVa82Ne9TVb1xzA0azCFMUUO4b5cqgV64DCX3R8yi49jq8hZ(67jj33S)nq1NUb677pGP2wWRV9b4hN8ayCFiBZ95YLT9IX9rj9udJwDCrCsUVhfZ(E1sK8)Vbkg3NtRXY((ozYGaM3wI(U64DCX3R8yi49jq8hZ(67jj33S)nq1NUb67BYfjdc)gOC43(a8JtEamUpKT5(C5Y2EX4(OKEQHrRoUioj3xKXSVNKdQpolGy9rjz6huFfj3h1mi2iM9PBG((sndInI5k5IKbHFduoCb4Tpj6BFejhkzFup7tG7dWizy13K9zyCFcmPt4yG(g9((sndInI5k5IKbHFduoCb4Tpj6BFdQVY0ObY4(mDDrXdYfGmE1XfXj5(ezm77j5G6JZciwFusM(b1xrY9rndInIzF6gOVVuZGyJyUsUizq43aLdxaE7tI(2hrYHs2h1Z(e4(amsgw9nzFgg3Nat6eogOVrVVVuZGyJyUsUizq43aLdxaE7tI(23G6RmnAGmUptxxu8GCbiJxD8oU47vEme8(ei(JzF99KK7B2)gO6t3a99n5IKbHFduomiipq8KA(2hGFCYdGX9HSn3Nlx22lg3hL0tnmA1XfXj5(IEm77j5G6JZciwFusM(b1xrY9rndInIzF6gOVVuZGyJyUOoegWa2XOYHFyaAb4Tpj6BFejhkzFup7tG7dWizy13K9zyCFcmPt4yG(g9((sndInI5I6qyadyhJkh(HbOfG3(KOV9nO(ktJgiJ7Z01ffpixaY4vhVJl(ELhdbVpbI)y2xFpj5(M9VbQ(0nqFFtUizq43aLddoTgc5V9b4hN8ayCFiBZ95YLT9IX9rj9udJwDCrCsUVxhZ(EsoO(4SaI1hLKPFq9vKCFuZGyJy2NUb67l1mi2iMlQdHbmGDmQC4hgGwaE7tI(2hrYHs2h1Z(e4(amsgw9nzFgg3Nat6eogOVrVVVuZGyJyUOoegWa2XOYHFyaAb4Tpj6BFdQVY0ObY4(mDDrXdYfGmE1XfXj5(EDm77j5G6JZciwFusM(b1xrY9rndInIzF6gOVVuZGyJyUegiJOMmqdheSTadqlaV9jrF7Ji5qj7J6zFcCFagjdR(MSpdJ7tGjDchd03O33xQzqSrmxcdKrutgOHdc2wGbOfG3(KOV9nO(ktJgiJ7Z01ffpixaY4vhxeNK7t8eZ(EsoO(4SaI1hLKPFq9vKCFuZGyJy2NUb67l1mi2iMlQdHbmGDmQC4hgGwaE7tI(2hrYHs2h1Z(e4(amsgw9nzFgg3Nat6eogOVrVVVuZGyJyUOoegWa2XOYHFyaAb4Tpj6BFdQVY0ObY4(mDDrXdYfGmE1XfXj5(epXSVNKdQpolGy9rjz6huFfj3h1mi2iM9PBG((sndInI5I6qyadyhJkh(HbOfG3(KOV9rKCOK9r9SpbUpaJKHvFt2NHX9jWKoHJb6B077l1mi2iMlQdHbmGDmQC4hgGwaE7tI(23G6RmnAGmUptxxu8GCbiJxDCrCsUpXtm77j5G6JZciwFusM(b1xrY9rndInIzF6gOVVuZGyJyUsUizq43aLdxaE7tI(2hrYHs2h1Z(e4(amsgw9nzFgg3Nat6eogOVrVVVuZGyJyUsUizq43aLdxaE7tI(23G6RmnAGmUptxxu8GCbiJxD8o(7V)nqX4(EDFoTgl7doOcT64kj4GkK6PscZ6UmSupveeP6PsYP1yPscZBlhAavao1uKkjoDbiJvrPkfbIu9ujXPlazSkkLefmfdgxjvoKZALCrYGWVbkhU40fGmwj50ASujrDim40ASmahuPKGdQcPVzLuYfjdc)gOCOQueeD1tLeNUaKXQOusuWumyCLe1mi2iMlK8EBzaZBlhAOed4zTa82Ne13l9fDX1xeIqFXOpQzqSrmxi592YaM3wo0qjgWZAb4TpjQVi2xKIRVy7JAgeBeZf1HWagWogvo8ddqlaV9jr9fX(IuC9fnLKtRXsLesEVTmq4az9HtSQueicQNkjNwJLkjnGzBdGd6muJSdWkjoDbiJvrPkfbps9ujXPlazSkkLefmfdgxjHmzyar6aCFVOTVhPKCAnwQKi9ehm9Ggzi2tvPi41QNkjoDbiJvrPKOGPyW4kjKjddishG77fT9f9(ITpQzqSrmxuhcdya7yu5WpmaTa82Ne13l9jc9fBFXOV3TVYHCwlK8EBzGWbY6dN4fNUaKX9fHi0h1mi2iMlK8EBzGWbY6dN4fG3(KO(EPprOVOPKCAnwQKi9ehm9Ggzi2tvPiq8OEQKCAnwQKOoegWa2XOYHFyasjXPlazSkkvPi49upvsoTglvscdKrutgOHdc2wGbiLeNUaKXQOuLIaXB1tLeNUaKXQOusuWumyCLu5qoRfsEVTmq4az9Ht8ItxaY4(ITpbzD9fgWogvo8ddqlaV9jr99sFoTglxi592YaM3wo0qjgWZArDufQzZ9fBFcY66lchiRpCIxaE7tI67L(CAnwUqY7TLbmVTCOHsmGN1I6OkuZMvsoTglvsi592YaM3wo0qjgWZsvkcIuCQNkjoDbiJvrPKOGPyW4kP3TVYHCwlK8EBzGWbY6dN4fNUaKX9fBFcY66lmGDmQC4hgGwaE7tI67L(CAnwUqY7TLbmVTCOHsmGN1I6OkuZMvsoTglvsi592YaM3wo0qjgWZsvkcIms1tLeNUaKXQOusuWumyCLKGSU(I4aXHz)JwOYPF67fT9jY(ITpbzD9fM3wo0a1a8cvo9tFruBFISVy7tqwxFH5TLdn8BezWcBetLKtRXsL0VrKbb08tAPQueePivpvsC6cqgRIsjrbtXGXvsitggqKoa3xe12x07l2(eK11xyEB5qdudWl5FLKtRXsLeM3wkyWsvkcIm6QNkjoDbiJvrPKCAnwQKWMTvsuWumyCLum6RCiN1cB2EXPlazCFX2x5anCTQzZHYc4H77L(WYaVgl7l2(IrFVBF1q)mPM(Iqe6dWBFsuFrSpSmWRXY(E87tCRO3x06lAkjQyuihkhOHlKsksvPiisrq9ujXPlazSkkLKtRXsLe1HWGtRXYaCqLscoOkK(MvscYdeh8aI0byvPkL0pGP2wWl1tfbrQEQK40fGmwfLQueis1tLeNUaKXQOuLIGOREQK40fGmwfLQueicQNkjNwJLkjK8EBz4NlLeNUaKXQOuLIGhPEQK40fGmwfLsIcMIbJRKkhYzTMmzqaZBlrloDbiJvsoTglvstMmiG5TLivPi41QNkjoDbiJvrPkfbIh1tLKtRXsLeM3wkyWsjXPlazSkkvPi49upvsoTglvs)wnwQK40fGmwfLQuLsk5IKbHFduou9urqKQNkjoDbiJvrPKOGPyW4kjQzqSrmxjxKmi8BGYHlaV9jr9fX(eP4usoTglvsuhcdoTgldWbvkj4GQq6BwjLCrYGWVbkhgeKhiEsnQsrGivpvsC6cqgRIsjrbtXGXvscY66RKlsge(nq5WL8VsYP1yPsI6qyWP1yzaoOsjbhufsFZkPKlsge(nq5WGtRHqwvQsjLCrYGWVbkhgeKhiEsnQNkcIu9ujXPlazSkkLefmfdgxjHmzyar6aCFVOTVh1xS9fJ(E3(khYzT(nImiGMFslxC6cqg3xeIqFcY66lmVTCObQb4L8FFrtj50ASujLCrYGWVbkhQkfbIu9uj50ASujrDimGbSJrLd)WaKsItxaYyvuQsrq0vpvsC6cqgRIsjrbtXGXvsuZGyJyUOoegWa2XOYHFyaAb4TpjQVx6lY3RVy7dzYWaI0b4(ErBFrxj50ASujr6joy6bnYqSNQsrGiOEQK40fGmwfLsIcMIbJRKeK11xehiom7F0cvo9tFVOTpr2xS9jiRRVW82YHgOgGxOYPF6lIA7tK9fBFcY66lmVTCOHFJidwyJy2xS9Hmzyar6aCFVOTVORKCAnwQK(nImiGMFslvLIGhPEQK40fGmwfLsIcMIbJRKqMmmGiDaUVx023JusoTglvsKEIdMEqJme7PQue8A1tLeNUaKXQOusoTglvsuhcdoTgldWbvkj4GQq6BwjjipqCWdishGvLQuscYdeh8aI0by1tfbrQEQKCAnwQKqMmmGkW8HvsC6cqgRIsvkceP6PsYP1yPscr6yJyqWGLsItxaYyvuQsvkPKlsge(nq5WGtRHqw9urqKQNkjNwJLkjQdHbmGDmQC4hgGusC6cqgRIsvkceP6PsItxaYyvukjkykgmUs6hWeg0qXRixAaZ2gah0zOgzhG7lcrOVFatyqdfVICHK3BldeoqwF4eRKCAnwQKi9ehm9Ggzi2tvPii6QNkjNwJLkjnGzBdGd6muJSdWkjoDbiJvrPkfbIG6PsYP1yPscjV3wgiCGS(WjwjXPlazSkkvPi4rQNkjNwJLkjHbYiQjd0WbbBlWaKsItxaYyvuQsrWRvpvsC6cqgRIsjrbtXGXvsitggqKoa3N2(ISVy7lg9rndInI5I6qyadyhJkh(HbOfG3(KO(IyFoTglxishBedcgSwuhvHA2CFric9fJ(khYzTegiJOMmqdheSTadqloDbiJ7l2(OMbXgXCjmqgrnzGgoiyBbgGwaE7tI6lI950ASCHiDSrmiyWArDufQzZ9fT(IMsYP1yPsI6qyWP1yzaoOsjbhufsFZkjb5bIdEar6aSQueiEupvsC6cqgRIsjrbtXGXvsXOVy0h1mi2iMlQdHbmGDmQC4hgGwaE7tI67L(CAnwUW82sbdwlQJQqnBUVO1xS9fJ(OMbXgXCrDimGbSJrLd)Wa0cWBFsuFV0NtRXYfI0XgXGGbRf1rvOMn3x06lA9fBFuZGyJyUsUizq43aLdxaE7tI67L(IrFr(AX13d950ASCr6joy6bnYqSNlQJQqnBUVOPKCAnwQKi9ehm9Ggzi2tvPi49upvsC6cqgRIsjrbtXGXvscY66RKlsge(nq5WfG3(KO(IyFrkU(ITpKjddishG7tBFItj50ASujHK3BldyEB5qdLyaplvPiq8w9ujXPlazSkkLefmfdgxjjiRRVsUizq43aLdxaE7tI6lI950ASCHK3BldyEB5qdLyapRf1rvOMn33d99O1JusoTglvsi592YaM3wo0qjgWZsvkcIuCQNkjoDbiJvrPKOGPyW4kjbzD9fM3wo0a1a8s(xj50ASujH5TLcgSuLIGiJu9ujXPlazSkkLKtRXsLe1HWGtRXYaCqLscoOkK(MvscYdeh8aI0byvPkvPKC5I0akjXREIr2M7tA2Vd99QZ2pKvLQuk]] )
end
