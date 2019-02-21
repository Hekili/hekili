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
    local guldan = {}
    local guldan_v = {}

    local dcon_imps = 0
    local dcon_imps_v = 0

    local shards_for_guldan = 0

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
                    table.insert( wild_imps, now + 22 )
                    
                    imps[ destGUID ] = {
                        t = now,
                        casts = 0,
                        expires = math.ceil( now + 22 ),
                        max = math.ceil( now + 22 )
                    }

                    if guldan[ 1 ] then
                        -- If this imp is impacting within 0.1s of the expected queued imp, remove that imp from the queue.
                        if abs( now - guldan[ 1 ] ) < 0.1 then
                            table.remove( guldan, 1 )
                        end
                    end

                    -- Expire missed/lost Gul'dan predictions.
                    while( guldan[ 1 ] ) do
                        if guldan[ 1 ] < now then
                            table.remove( guldan, 1 )
                        else
                            break
                        end
                    end

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

            elseif subtype == "SPELL_CAST_START" and spellID == 105174 then
                shards_for_guldan = UnitPower( "player", Enum.PowerType.SoulShards )

            elseif subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 196277 then
                    table.wipe( wild_imps )
                    table.wipe( imps )
                
                elseif spellID == 264130 then
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                    if wild_imps[1] then table.remove( wild_imps, 1 ) end
                
                elseif spellID == 105174 then
                    -- Hand of Guldan; queue imps.
                    if shards_for_guldan >= 3 then table.insert( guldan, 1, now + 1.91 ) end
                    if shards_for_guldan >= 2 then table.insert( guldan, 1, now + 1.51 ) end
                    if shards_for_guldan >= 1 then table.insert( guldan, 1, now + 1.11 ) end

                elseif spellID == 265187 and state.talent.demonic_consumption.enabled then
                    dcon_imps = #guldan + #wild_imps + #imps

                    table.wipe( guldan ) -- wipe incoming imps, too.
                    table.wipe( wild_imps )
                    table.wipe( imps )

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


        --[[ i = 1
        while( guldan[i] ) do
            if guldan[i] < now then
                print( "reset removing imp" )
                table.remove( guldan, i )
            else
                i = i + 1
            end
        end ]]

        wipe( guldan_v )
        for n, t in ipairs( guldan ) do guldan_v[ n ] = t end
        
        dcon_imps_v = dcon_imps


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


    spec:RegisterHook( "advance_end", function ()
        for i = #guldan_v, 1, -1 do
            local imp = guldan_v[i]

            if imp <= query_time then
                if ( imp + 22 ) > query_time then
                    insert( wild_imps_v, imp + 22 )
                end
                remove( guldan_v, i )
            end
        end
    end )


    -- Provide a way to confirm if all Hand of Gul'dan imps have landed.
    spec:RegisterStateExpr( "spawn_remains", function ()
        if #guldan_v > 0 then
            return max( 0, guldan_v[ #guldan_v ] - query_time )
        end
        return 0
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

                    -- Count queued HoG imps.
                    for i, spawn in ipairs( guldan_v ) do
                        if spawn <= query_time and ( spawn + 22 ) >= query_time then c = c + 1 end
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

                if extra_shards >= 3 then insert( guldan_v, 1, query_time + 1.90 ) end
                if extra_shards >= 2 then insert( guldan_v, 1, query_time + 1.50 ) end
                insert( guldan_v, 1, query_time + 1.05 )
                
                -- Don't immediately summon; queue them up.
                -- summon_demon( "wild_imps", 25, 1 + extra_shards, 1.5 )
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

            usable = function ()
                if buff.wild_imps.stack > 0 then return true end
                if prev_gcd[1].summon_demonic_tyrant then
                    if dcon_imps_v > 2 and query_time - action.summon_demonic_tyrant.lastCast < 0.1 then return true end
                    return false, format( "post-tyrant window is 0.1s with 3+ imps; you had %d imps and tyrant cast was %.2f seconds ago", dcon_imps_v, query_time - action.summon_demonic_tyrant.lastCast )
                end 
                return false, "no imps available"
            end,

            handler = function ()
                if azerite.explosive_potential.enabled and ( buff.wild_imps.stack + dcon_imps_v ) >= 3 then applyBuff( "explosive_potential" ) end
                dcon_imps_v = 0
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
            
            spend = 1,
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
            
            readyTime = function ()
                if buff.wild_imps.stack >= 2 then return 0 end

                local imp_deficit = 2 - buff.wild_imps.stack
                
                for i, imp in ipairs( guldan_v ) do
                    if imp > query_time then
                        imp_deficit = imp_deficit - 1
                        if imp_deficit == 0 then return imp - query_time end
                    end
                end

                return 3600
            end,

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
                summonPet( "demonic_tyrant", 15 )
                summon_demon( "demonic_tyrant", 15 )
                applyBuff( "demonic_power", 15 )
                if talent.demonic_consumption.enabled then
                    dcon_imps_v = buff.wild_imps.stack
                    consume_demons( "wild_imps", "all" )
                end
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


    spec:RegisterPack( "Demonology", 20190221.1405, [[dKekybqiLu8isfSjLKpPukPrPu0PukzvQsfVsj0Sus1TuLQ2fv9luHHPkLJPuzzOIEMsHPPKsxJuv2gPQQVPuQACkLsDosfADkLkMNQK7Pk2hPshKurQfQe8qsvLMOQuPlsQiAJKkc8rsfbDsLsjwPsvZKurODsQYpvkf0qjvvSuLsLEkuMkQuxvPuGVsQizVK8xugmHdlzXe5XiMmsxMYMjQpJQmAvLtl1Rvv1SbUnv2TOFlmCs54kLcTCiph00vCDOA7Os(Us04jvuNxvL1RukA(OQ2VkR2P4wHrRXu6X5B70X34KZD(DR9TTFJTxHn)0mfMwr(x8mfwwotH9UMlYae8(PW0QFGOOkUvyWahrmf23mAWTdhCWRNpCjpjCCaBhoOMoscQKhoGTJWHeiK4qsUEp14Idnui3adYH(bzB3QPqo0pBxMovHab5p7DnxKbi49ZdBhrHjH3GzBjvskmAnMspoFBNo(gNCUZVBTVT9BSwfguZik94u)1Ff2xtPwQKuyudsuy6WjExZfzacE)oHovHab5)TxhoX3mAWTdhCWRNpCjpjCCaBhoOMoscQKhoGTJWHeiK4qsUEp14Idnui3adYH(bzB3QPqo0pBxMovHab5p7DnxKbi49ZdBh52RdNqNatcHxOFNGZDRFcoFBNoEI3FIDRD782AV93(BVoCc97xL8m4252RdN49NatZaGtOtmi)93ED4eV)eBdG2jKWLL9PnFgIPfOPaECTt0jCSIEIq(eiZvD2jVtOFF3tmTZoHCGoHE28zOtOFc0uGtuKP5YoH2xbn)TxhoX7pX2We87eiJeoNL0t8UMlsPamNqdzVNeoPAorlFIEordprNWPY5eBc)cCa9eAOqQKa)obCAa4eFfIsk4SL)2RdN49Nq)eln0jWATViprbaXsJEcnK9Es4KQ5etCcnuqorNWPY5eVR5IukaJ)2RdN49NqNMsprOzPHob2xrJLNyHamNiWhytTteYNqkGWti38(g4jM4e1CcGvW5e8S5erANWfi7eWVcr93ED4eV)eCV0Q)Nq)gje3PnDKCOtQZAGa2CzNi0S0qNyItizNWfi7etamuLZjc5tqBzzdz5Cc5M33Cc4uO5eWEWRPJe6V96WjE)j42GZjANgWCwo10rEIq(e63iH4oTPJKdDs9ZjKW5DInjvEITfNgiGDKN4DANZODng437CIsEm0j4(hQY5en8eqCNlsJUL)2RdN49NqNMROPNG7FOkNtSKJ4eTtdEILFwEI31Cr2KtOFJeI70MoYt0WtmfWYXOEfMgkKBGPW0Ht8UMlYae8(DcDQcbcY)BVoCIVz0GBho4GxpF4sEs44a2oCqnDKeujpCaBhHdjqiXHKC9EQXfhAOqUbgKd9dY2UvtHCOF2UmDQcbcYF27AUidqW7Nh2oYTxhoHobMecVq)obNVT(j48TD64jE)j4CJTZo9D7V96Wj0VFvYZGBNBVoCI3FcmndaoHoXG83F71Ht8(tSnaANqcxw2N28ziMwGMc4X1orNWXk6jc5tGmx1zN8oH(9DpX0o7eYb6e6zZNHoH(jqtborrMMl7eAFf083ED4eV)eBdtWVtGms4CwspX7AUiLcWCcnK9Es4KQ5eT8j65en8eDcNkNtSj8lWb0tOHcPsc87eWPbGt8vikPGZw(BVoCI3Fc9tS0qNaR1(I8efaeln6j0q27jHtQMtmXj0qb5eDcNkNt8UMlsPam(BVoCI3FcDAk9eHMLg6eyFfnwEIfcWCIaFGn1oriFcPacpHCZ7BGNyItuZjawbNtWZMtePDcxGSta)ke1F71Ht8(tW9sR(Fc9BKqCN20rYHoPoRbcyZLDIqZsdDIjoHKDcxGStmbWqvoNiKpbTLLnKLZjKBEFZjGtHMta7bVMosO)2RdN49NGBdoNODAaZz5uth5jc5tOFJeI70Moso0j1pNqcN3j2Ku5j2wCAGa2rEI3PDoJ21yGFVZjk5XqNG7FOkNt0WtaXDUin6w(BVoCI3FcDAUIMEcU)HQCoXsoIt0on4jw(z5jExZfztoH(nsiUtB6iprdpXualhJ6V93(BVoCcDsD2i4JrpHKjhi7eKWjvZjKmEDc9NqNMqmTbEImY3)viNmo4efz6iHNisWp)TVithj0RHms4KQ5rguW)3(ImDKqVgYiHtQMfF4qoc6TVithj0RHms4KQzXhokCEolNA6iV9fz6iHEnKrcNunl(Wbe35IKPzZTVithj0RHms4KQzXho4QqDjbS1ZYzpZpuLdRDAW15Qa42Zualhp1Cr2egjsiUtB6i9wwsaJUAd(8F72xKPJe61qgjCs1S4dhDMgIrnxKW1B5NPawo(otdXOMlsO3Yscy0BFrMosOxdzKWjvZIpCOflned2AFrUEl)SgPacxjHll7x2akRDAqpCkYFD3D7lY0rc9AiJeoPAw8HdywAWVyyWPg4TVithj0RHms4KQzXho0IPJ82xKPJe61qgjCs1S4dhuZfPuaM1B5hPac5ZVithPNAUiLcW4jfCyt7SN3U9fz6iHEnKrcNunl(Wb8ROXsMuaM1B5N1ifqiF(fz6i9uZfPuagpPGdBANP7B3(BVoCcDsD2i4JrpHXLH(DIPD2jMp7efzc0jA4jkUQgusaZF7lY0rcFANgiGDKR3Yp120q9yEtN1abS5YyAXy50fWBzjbm6QPawoEQ5ISjmsKqCN20r6TSKagDLgY4IXJq978qCNlsg1Cr2e28dv5C7lY0rcx8HdOMbamqq(F7lY0rcx8HdTy6ixVLF0SXtnxKnHn)qvo(Imnx2QnxZualhFAZNHyAbAkG3Yscyu(8LWLL9PnFgIPfOPaECTT4ZFkepB8t7m2emABV24TBFrMos4IpCGdnwpMdUEl)OzJNAUiBcB(HQC8fzAUm(8NcXZg)0oJnbJ22RND672xKPJeU4dhsgcAO)DYB9w(rZgp1Cr2e28dv54lY0Cz85pfINn(PDgBcgTTxp703TVithjCXhoKarqzY4OFR3YpA24PMlYMWMFOkhFrMMlJp)Pq8SXpTZytWOT96zN(U9fz6iHl(WHCJmjqe01B5hnB8uZfztyZpuLJVitZLXN)uiE24N2zSjy02E9StF3(ImDKWfF4GuaaRithjd0Wz9SC2dLejZ0yHMLgA9w(P2MgQhZB6SgiGnxgtlglNUaEuL)xnfWYXtnxKnHrIeI70MosVLLeWORM2zV24TvRHebGgltpe35IKrnxKnHn)qvoEK5QoH3(ImDKWfF44RsklKz8Wb0kxVLFQTPH6X8MoRbcyZLX0IXYPlGhv5)vt7Sx6BfmWbm4xHO6Y5kjCzzVPZAGa2CzmTySC6c4PXYCLeUSSFzdOS2Pb9WPi)FTXQ1OHmUy8iu)o)xLuwiZ4HdOvUAnAiJlgpc1ZP)RsklKz8Wb0kV9fz6iHl(Wb1CrkfGz9w(bg4ag8Rq0xpBSscxw2tnxKnHrcK5X1wjHll7PMlYMWibY8WPi)Fw7TVithjCXhoANgiGDKR3Yp120q9yEtN1abS5YyAXy50fWJQ8)kjCzz)YgqzTtd6Htr(RlNRKWLL9MoRbcyZLX0IXYPlGhzUQt4RImDKE4xrJLmPamEtNnc(ySPD2QnxZualhp1Cr2egjsiUtB6i9wwsaJYNpjcanwMEiUZfjJAUiBcB(HQC8iZvDc1DhNBD7lY0rcx8HdAeU1B5N1mn5FN8wnTZytWOTP7gVTcQzaaBkepBG(2Pbcyh5loV9fz6iHl(WHudmijWr8mMu4KmeC9w(P2MgQhZB6SgiGnxgtlglNUaEuL)19Tvt7Sx7EBfuZaa2uiE2a9TtdeWoYxCUscxw2trwrHtb(BiOhzUQt4QPawo(0MpdX0c0uaVLLeWO3(ImDKWfF4GAUiBcdoil5nFR3YpBkHll7x2akRDAqpCkY)x6pF(s4YYEQ5ISjmTyPH84ABXNpuZaa2uiE2a9TtdeWoYxCE7lY0rcx8HdsbaSImDKmqdN1ZYzpPnFgIPfOPaR3YptbSC8PnFgIPfOPaElljGrxb1maGnfINnqF70abSJ81dN3(ImDKWfF4GuaaRithjd0Wz9SC2t70abSJC9w(bQzaaBkepBG(2PbcyhPU7U9fz6iHl(Wbpu7IgzmzdWdVq01B5hseaASm9qCNlsg1Cr2e28dv54rMR6e(A3g3(ImDKWfF4aI7CrY4QbMCBjD9w(HebGgltpe35IKrnxKnHn)qvoEK5QoH6U234ZNebGgltpe35IKrnxKnHn)qvoEK5QoHV2X5TVithjCXhoifaWOiROWPa)neC9w(ztseaASm9qCNlsg1Cr2e28dv54rMR6e(shxjHll7PMlYMWifa0jppYCvNWT4ZFtseaASm9qCNlsg1Cr2e28dv54rMR6e(A3UvRrcxw2tnxKnHrkaOtEEK5QoHBXNpjcanwMEiUZfjJAUiBcB(HQC8iZvDc1D3AV9fz6iHl(WHudmijWr8mMu4Kme82xKPJeU4dhqCNlsg1Cr2e28dv5SEl)adCad(vi6RnwjHll7x2akRDAqpCkYFD5QqDjbm)8dv5WANg82xKPJeU4dhAXsdXGT2xKR3Yps4YY(LnGYANg0dNI8x3hoxjHll7PMlYMWibY8WPi)F9W5kjCzzp1Cr2eMwS0qEASmxb1maGnfINnqF70abSJ8fN3(ImDKWfF4GgHB9w(zkGLJNgHZBzjbm6kKjJm4xjbSvt7m2emAB6UjngpncNhzUQt4IB82w3(ImDKWfF44RsklKz8Wb0kxVLFGboGb)kev3h9XN)MWahWGFfIQ7ZgRiraOXY0tkaGrrwrHtb(BiOhzUQtOURD1MKia0yz6H4oxKmQ5ISjS5hQYXJmx1juxoFJp)njraOXY0dXDUizuZfztyZpuLJhzUQt4lEe67W5QPawoEQ5ISjmsKqCN20r6TSKagLpFseaASm9qCNlsg1Cr2e28dv54rMR6e(IhH(oRD1AMcy54PMlYMWircXDAthP3Yscy0T2A1MRzkGLJhI7CrY4QbMCBj1BzjbmkF(Kia0yz6H4oxKmUAGj3ws9iZvDc1DJT262xKPJeU4dhWahWGdQ)BR3YpWahWGFfI(sFRKWLL9uZfztyKazE4uK)VE482xKPJeU4dhuZfPuaM1B5hyGdyWVcrF9SXkjCzzp1Cr2egjqMhxB1MBsIaqJLPhI7CrYOMlYMWMFOkhpYCvNWx6pF(Kia0yz6H4oxKmQ5ISjS5hQYXJmx1juxo5Cl(8LWLL9uZfztyKazE4uK)6(SbF(s4YYEQ5ISjmsGmpYCvNWx6Jp)PDgBcgTTxCQVTU9fz6iHl(WbPaawrMosgOHZ6z5Shj8gqzfd(vi6T)2xKPJe6LWBaLvm4xHOpWahWGdQ)B3(ImDKqVeEdOSIb)keDXhoGFfnwYKcWC7V9fz6iHEkjsMPXcnln0ZxLuwiZ4HdOvUEl)adCad(viQUCUoOtJrOpB82TVithj0tjrYmnwOzPHw8HJ2Pbcyh56T8JeUSSFzdOS2Pb9WPi)1LZvs4YYEtN1abS5YyAXy50fWtJL5TVithj0tjrYmnwOzPHw8HdAeU1bDAmc9zJ3U9fz6iHEkjsMPXcnln0IpCqnxKnHbhKL8MVBFrMosONsIKzASqZsdT4dhsnWGKahXZysHtYqWBFrMosONsIKzASqZsdT4dhqCNlsgxnWKBlP3(ImDKqpLejZ0yHMLgAXho4HAx0iJjBaE4fIE7lY0rc9usKmtJfAwAOfF44RsklKz8Wb0kxVLFGboGb)ke9rF85ddCad(vi6ZAxjHll7PMlYMWifa0jppYCvNWBFrMosONsIKzASqZsdT4dhKcayuKvu4uG)gcUEl)OHmUy8iu)o)xLuwiZ4HdOvYN)MAiJlgpc1ZP)RsklKz8Wb0kxPHmUy8iu)oF70abSJCRBFrMosONsIKzASqZsdT4dhqCNlsg1Cr2e28dv5SEl)OHmUy8iu)opPaagfzffof4VHG85tIaqJLPNuaaJISIcNc83qqpYCvNqDF72xKPJe6PKizMgl0S0ql(WbmWbm4G6)26T8ZMWahWGFfI(Ad(8HboGb)ke9zTRKWLL9uZfztyKazE4uK)VE2yl(8LWLL9uZfztyKazEASmxbdCad(vi6l9D7lY0rc9usKmtJfAwAOfF4GAUiLcWSEl)adCad(vi6RNnwjHll7PMlYMWibY8iZvDcV9fz6iHEkjsMPXcnln0IpCqkaGvKPJKbA4SEwo7rcVbuwXGFfIE7V9fz6iH(2Pbcyh5t70abSJC9w(ztjCzz)YgqzTtd6Htr(R7J(VAtyGdyWVcrFTbF(AiJlgpc1VZtkaGrrwrHtb(BiiF(s4YY(LnGYANg0dNI8x3hDKpFnKXfJhH635LAGbjboINXKcNKHG85V5A0qgxmEeQFN)RsklKz8Wb0kxTgnKXfJhH650)vjLfYmE4aALBT1Q1OHmUy8iu)o)xLuwiZ4HdOvUAnAiJlgpc1ZP)RsklKz8Wb0kxjHll7PMlYMW0ILgYtJL5w85V50oJnbJ22RnwjHll7x2akRDAqpCkYFDFBl(83udzCX4rOEo9KcayuKvu4uG)gcUscxw2VSbuw70GE4uK)6Y5Q1mfWYXtnxKnHrkaOtEElljGr362xKPJe6BNgiGDKl(Wbpu7IgzmzdWdVq01B5hseaASm9qCNlsg1Cr2e28dv54rMR6e(A3g85VgBBeV10mQF3gCUH(RJ3(ImDKqF70abSJCXhoifaWOiROWPa)neC9w(ztseaASm9qCNlsg1Cr2e28dv54rMR6e(shxjHll7PMlYMWifa0jppYCvNWT4ZFtseaASm9qCNlsg1Cr2e28dv54rMR6e(A3UvRrcxw2tnxKnHrkaOtEEK5QoHBXNpjcanwMEiUZfjJAUiBcB(HQC8iZvDc1D3AV9fz6iH(2Pbcyh5IpCaXDUizuZfztyZpuLZ6T8JeUSSFzdOS2Pb9WPi)1LRc1LeW8ZpuLdRDAWBFrMosOVDAGa2rU4dhFvszHmJhoGw56T8dmWbm4xHO6(OVBFrMosOVDAGa2rU4dhFvszHmJhoGw56T8dmWbm4xHO6(SXQn3CtnKXfJhH650)vjLfYmE4aAL85lHll7x2akRDAqpCkYFDF2yRvs4YY(LnGYANg0dNI8)LoUfF(Kia0yz6H4oxKmQ5ISjS5hQYXJmx1j81dpc9D4KpFjCzzp1Cr2eMwS0qEK5QoH6YJqFho362xKPJe6BNgiGDKl(Wb1CrkfGz9w(rdzCX4rO(D(VkPSqMXdhqRCfmWbm4xHO6(SB1Ms4YY(LnGYANg0dNI8)1Zg85RHmUy8iu)g(VkPSqMXdhqRCRvWahWGFfI(ATRKWLL9uZfztyKazECTBFrMosOVDAGa2rU4dhqCNlsgxnWKBlPR3YpBsIaqJLPhI7CrYOMlYMWMFOkhpYCvNqDx7BRGAgaWMcXZgOVDAGa2r(6HZT4ZNebGgltpe35IKrnxKnHn)qvoEK5QoHV2X5TVithj03onqa7ix8HdPgyqsGJ4zmPWjzi46T8djcanwMEiUZfjJAUiBcB(HQC8iZvDc1vhV9fz6iH(2Pbcyh5IpCadCadoO(VTEl)adCad(vi6l9Tscxw2tnxKnHrcK5Htr()6HZBFrMosOVDAGa2rU4dhuZfPuaM1B5hyGdyWVcrF9SXkjCzzp1Cr2egjqMhxB1Ms4YYEQ5ISjmsGmpCkYFDF2GpFjCzzp1Cr2egjqMhzUQt4RhEe67Op)2V1TVithj03onqa7ix8HdAeU1j)iaJnfINnWNDR7kDMr(ragBkepBGpB)6T8dYKrg8RKa2TVithj03onqa7ix8HdsbaSImDKmqdN1ZYzps4nGYkg8Rq0B)TVithj0N28ziMwGMc8qkaGvKPJKbA4SEwo7jT5ZqmTanfGjH3aAN8wVLFiraOXY0N28ziMwGMc4rMR6e(IZ3U9fz6iH(0MpdX0c0uGfF4GuaaRithjd0Wz9SC2tAZNHyAbAkaRitZLTEl)iHll7tB(metlqtb84A3(BFrMosOpT5ZqmTanfGvKP5YEKAGbjboINXKcNKHG3(ImDKqFAZNHyAbAkaRitZLT4dh8qTlAKXKnap8crxVLFiraOXY0dXDUizuZfztyZpuLJhzUQt4RDBWN)ASTr8wtZO(DBW5g6VoE7lY0rc9PnFgIPfOPaSImnx2IpCaXDUizC1atUTKUEl)qIaqJLPhI7CrYOMlYMWMFOkhpYCvNqDx7B85tIaqJLPhI7CrYOMlYMWMFOkhpYCvNWx7482xKPJe6tB(metlqtbyfzAUSfF4GuaaJISIcNc83qW1B5NnjraOXY0dXDUizuZfztyZpuLJhzUQt4lDCLeUSSNAUiBcJuaqN88iZvDc3Ip)njraOXY0dXDUizuZfztyZpuLJhzUQt4RD7wTgjCzzp1Cr2egPaGo55rMR6eUfF(Kia0yz6H4oxKmQ5ISjS5hQYXJmx1ju3DR92xKPJe6tB(metlqtbyfzAUSfF4GuaaRithjd0Wz9SC2JeEdOSIb)keD9w(bg4ag8Rq0NDR2KebGgltpPaagfzffof4VHGEK5QoHVkY0r6HFfnwYKcW4jfCyt7m(83CkGLJxQbgKe4iEgtkCsgc6TSKagDfjcanwMEPgyqsGJ4zmPWjziOhzUQt4RImDKE4xrJLmPamEsbh20oBRTU9fz6iH(0MpdX0c0uawrMMlBXho(QKYczgpCaTY1B5Nn3KebGgltpPaagfzffof4VHGEK5QoH6wKPJ0tnxKsby8KcoSPD2wR2KebGgltpPaagfzffof4VHGEK5QoH6wKPJ0d)kASKjfGXtk4WM2zBT1kseaASm9PnFgIPfOPaEK5QoH6U5o9xFlwKPJ0)vjLfYmE4aALEsbh20oBRBFrMosOpT5ZqmTanfGvKP5Yw8HdiUZfjJAUiBcB(HQCwVLFKWLL9PnFgIPfOPaEK5QoHV03kyGdyWVcrFE72xKPJe6tB(metlqtbyfzAUSfF4aI7CrYOMlYMWMFOkN1B5hjCzzFAZNHyAbAkGhzUQt4RImDKEiUZfjJAUiBcB(HQC8KcoSPD2IV513TVithj0N28ziMwGMcWkY0Czl(Wb1CrkfGz9w(rcxw2tnxKnHrcK5X1wbdCad(vi6RNnU9fz6iH(0MpdX0c0uawrMMlBXhoifaWkY0rYanCwplN9iH3akRyWVcrV93(ImDKqFAZNHyAbAkatcVb0o59K28ziMwGMcSEl)adCad(viQUp6B1MRzkGLJxlwAigS1(I0BzjbmkF(s4YYEQ5ISjmsGmpU2w3(ImDKqFAZNHyAbAkatcVb0o5T4dhKcayuKvu4uG)gcE7lY0rc9PnFgIPfOPamj8gq7K3IpC8vjLfYmE4aALR3YpKia0yz6jfaWOiROWPa)ne0Jmx1ju3DB7vWahWGFfIQ7Zg3(ImDKqFAZNHyAbAkatcVb0o5T4dhAXsdXGT2xKR3Yps4YY(LnGYANg0dNI8x3hoxjHll7PMlYMWibY8WPi)F9W5kjCzzp1Cr2eMwS0qEASmxbdCad(viQUpBC7lY0rc9PnFgIPfOPamj8gq7K3IpC8vjLfYmE4aALR3YpWahWGFfIQ7J(U9fz6iH(0MpdX0c0uaMeEdODYBXhoifaWkY0rYanCwplN9iH3akRyWVcrvyCziyhPspoFBNo(gNCUZVBTVTwf2YcLDYdQW0P0P3U6TTONoHBNtCcU)St0oTanNqoqNyBvdzKWjvZ26jq22iEJm6jGHZorHpHRgJEcYxL8mO)2RtSt7e6)25eBdsiUMwGgJEIImDKNyBTZ0qmQ5IeUT6V93(TfNwGgJEIT9jkY0rEcqdhO)2RWk85lqkmS2PFvyGgoqf3kmkjsMPXcnlnKIBLE7uCRWSSKagvTGcJG6XqDPWGboGb)ke9e6Ecovyfz6ivyFvszHmJhoGwPcd0PXiuf2gVPgLECQ4wHzzjbmQAbfgb1JH6sHjHll7x2akRDAqpCkY)tO7j48eRoHeUSS30znqaBUmMwmwoDb80yzQWkY0rQWANgiGDKQrP3gkUvywwsaJQwqHvKPJuHrJWPWaDAmcvHTXBQrP3AvCRWkY0rQWOMlYMWGdYsEZNcZYscyu1cQrPN(uCRWkY0rQWKAGbjboINXKcNKHGkmlljGrvlOgLE6VIBfwrMosfge35IKXvdm52sQcZYscyu1cQrP32R4wHvKPJuHXd1UOrgt2a8WlevHzzjbmQAb1O0BBR4wHzzjbmQAbfgb1JH6sHbdCad(vi6jEoH(obF(Nag4ag8Rq0t8CI1EIvNqcxw2tnxKnHrkaOtEEK5QoHkSImDKkSVkPSqMXdhqRunk90rf3kmlljGrvlOWiOEmuxkmnKXfJhH635)QKYczgpCaTYtWN)j28eAiJlgpc1ZP)RsklKz8Wb0kpXQtOHmUy8iu)oF70abSJ8eBPWkY0rQWifaWOiROWPa)neunk929MIBfMLLeWOQfuyeupgQlfMgY4IXJq978KcayuKvu4uG)gcEc(8pbjcanwMEsbamkYkkCkWFdb9iZvDcpHUN4nfwrMosfge35IKrnxKnHn)qvoQrP3UDkUvywwsaJQwqHrq9yOUuyBEcyGdyWVcrpXRtSXj4Z)eWahWGFfIEINtS2tS6es4YYEQ5ISjmsGmpCkY)t865eBCITobF(Nqcxw2tnxKnHrcK5PXY8eRobmWbm4xHON41j0NcRithPcdg4agCq9Ftnk92XPIBfMLLeWOQfuyeupgQlfgmWbm4xHON41Zj24eRoHeUSSNAUiBcJeiZJmx1juHvKPJuHrnxKsbyuJsVDBO4wHzzjbmQAbfwrMosfgPaawrMosgOHJcd0WHLLZuys4nGYkg8Rqu1OgfwAZNHyAbAkGIBLE7uCRWSSKagvTGcJG6XqDPWiraOXY0N28ziMwGMc4rMR6eEIxNGZ3uyfz6ivyKcayfz6izGgokmqdhwwotHL28ziMwGMcWKWBaTtEQrPhNkUvywwsaJQwqHrq9yOUuys4YY(0MpdX0c0uapUMcRithPcJuaaRithjd0WrHbA4WYYzkS0MpdX0c0uawrMMltnQrHrn5chmkUv6TtXTcZYscyu1ckmcQhd1LcR2MgQhZB6SgiGnxgtlglNUaElljGrpXQtmfWYXtnxKnHrIeI70MosVLLeWONy1j0qgxmEeQFNhI7CrYOMlYMWMFOkhfwrMosfw70abSJunk94uXTcRithPcdQzaadeK)kmlljGrvlOgLEBO4wHzzjbmQAbfgb1JH6sHPzJNAUiBcB(HQC8fzAUStS6eBEI1CIPawo(0MpdX0c0uaVLLeWONGp)tiHll7tB(metlqtb84ANyRtWN)jMcXZg)0oJnbJ22jEDInEtHvKPJuHPfthPAu6Twf3kmlljGrvlOWiOEmuxkmnB8uZfztyZpuLJVitZLDc(8pXuiE24N2zSjy02oXRNtStFkSImDKkmCOX6XCq1O0tFkUvywwsaJQwqHrq9yOUuyA24PMlYMWMFOkhFrMMl7e85FIPq8SXpTZytWOTDIxpNyN(uyfz6ivysgcAO)DYtnk90Ff3kmlljGrvlOWiOEmuxkmnB8uZfztyZpuLJVitZLDc(8pXuiE24N2zSjy02oXRNtStFkSImDKkmjqeuMmo6NAu6T9kUvywwsaJQwqHrq9yOUuyA24PMlYMWMFOkhFrMMl7e85FIPq8SXpTZytWOTDIxpNyN(uyfz6ivyYnYKarqvJsVTTIBfMLLeWOQfuyeupgQlfwTnnupM30znqaBUmMwmwoDb8Ok)FIvNykGLJNAUiBcJeje3PnDKElljGrpXQtmTZoXRtSXBNy1jwZjiraOXY0dXDUizuZfztyZpuLJhzUQtOcRithPcJuaaRithjd0WrHbA4WYYzkmkjsMPXcnlnKAu6PJkUvywwsaJQwqHrq9yOUuy120q9yEtN1abS5YyAXy50fWJQ8)jwDIPD2jEDc9DIvNag4ag8Rq0tO7j48eRoHeUSS30znqaBUmMwmwoDb80yzEIvNqcxw2VSbuw70GE4uK)N41j24eRoXAoHgY4IXJq978FvszHmJhoGw5jwDI1CcnKXfJhH650)vjLfYmE4aALkSImDKkSVkPSqMXdhqRunk929MIBfMLLeWOQfuyeupgQlfgmWbm4xHON41Zj24eRoHeUSSNAUiBcJeiZJRDIvNqcxw2tnxKnHrcK5Htr(FINtSwfwrMosfg1CrkfGrnk92TtXTcZYscyu1ckmcQhd1LcR2MgQhZB6SgiGnxgtlglNUaEuL)pXQtiHll7x2akRDAqpCkY)tO7j48eRoHeUSS30znqaBUmMwmwoDb8iZvDcpXRtuKPJ0d)kASKjfGXB6SrWhJnTZoXQtS5jwZjMcy54PMlYMWircXDAthP3Yscy0tWN)jiraOXY0dXDUizuZfztyZpuLJhzUQt4j09e748eBPWkY0rQWANgiGDKQrP3oovCRWSSKagvTGcJG6XqDPWwZjMM8VtENy1jM2zSjy02oHUNyJ3oXQta1maGnfINnqF70abSJ8eVobNkSImDKkmAeo1O0B3gkUvywwsaJQwqHrq9yOUuy120q9yEtN1abS5YyAXy50fWJQ8)j09eVDIvNyANDIxNy3BNy1jGAgaWMcXZgOVDAGa2rEIxNGZtS6es4YYEkYkkCkWFdb9iZvDcpXQtmfWYXN28ziMwGMc4TSKagvHvKPJuHj1adscCepJjfojdbvJsVDRvXTcZYscyu1ckmcQhd1LcBZtiHll7x2akRDAqpCkY)t86e6)j4Z)es4YYEQ5ISjmTyPH84ANyRtWN)jGAgaWMcXZgOVDAGa2rEIxNGtfwrMosfg1Cr2egCqwYB(uJsVD6tXTcZYscyu1ckmcQhd1LcBkGLJpT5ZqmTanfWBzjbm6jwDcOMbaSPq8Sb6BNgiGDKN41Zj4uHvKPJuHrkaGvKPJKbA4OWanCyz5mfwAZNHyAbAkGAu6Tt)vCRWSSKagvTGcJG6XqDPWGAgaWMcXZgOVDAGa2rEcDpXofwrMosfgPaawrMosgOHJcd0WHLLZuyTtdeWos1O0B32R4wHzzjbmQAbfgb1JH6sHrIaqJLPhI7CrYOMlYMWMFOkhpYCvNWt86e72qHvKPJuHXd1UOrgt2a8Wlevnk92TTvCRWSSKagvTGcJG6XqDPWiraOXY0dXDUizuZfztyZpuLJhzUQt4j09eR9TtWN)jiraOXY0dXDUizuZfztyZpuLJhzUQt4jEDIDCQWkY0rQWG4oxKmUAGj3wsvJsVD6OIBfMLLeWOQfuyeupgQlf2MNGebGgltpe35IKrnxKnHn)qvoEK5QoHN41j0XtS6es4YYEQ5ISjmsbaDYZJmx1j8eBDc(8pXMNGebGgltpe35IKrnxKnHn)qvoEK5QoHN41j2T7eRoXAoHeUSSNAUiBcJuaqN88iZvDcpXwNGp)tqIaqJLPhI7CrYOMlYMWMFOkhpYCvNWtO7j2TwfwrMosfgPaagfzffof4VHGQrPhNVP4wHvKPJuHj1adscCepJjfojdbvywwsaJQwqnk94CNIBfMLLeWOQfuyeupgQlfgmWbm4xHON41j24eRoHeUSSFzdOS2Pb9WPi)pHUNGRc1LeW8ZpuLdRDAqfwrMosfge35IKrnxKnHn)qvoQrPhNCQ4wHzzjbmQAbfgb1JH6sHjHll7x2akRDAqpCkY)tO7Zj48eRoHeUSSNAUiBcJeiZdNI8)eVEobNNy1jKWLL9uZfztyAXsd5PXY8eRobuZaa2uiE2a9TtdeWoYt86eCQWkY0rQW0ILgIbBTVivJspo3qXTcZYscyu1ckmcQhd1LcBkGLJNgHZBzjbm6jwDcKjJm4xjbStS6et7m2emABNq3tS5jOX4Pr48iZvDcpXINyJ3oXwkSImDKkmAeo1O0JZ1Q4wHzzjbmQAbfgb1JH6sHbdCad(vi6j095e67e85FInpbmWbm4xHONq3NtSXjwDcseaASm9KcayuKvu4uG)gc6rMR6eEcDpXApXQtS5jiraOXY0dXDUizuZfztyZpuLJhzUQt4j09eC(2j4Z)eBEcseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNGhHEI35eCEIvNykGLJNAUiBcJeje3PnDKElljGrpbF(NGebGgltpe35IKrnxKnHn)qvoEK5QoHN41j4rON4DoXApXQtSMtmfWYXtnxKnHrIeI70MosVLLeWONyRtS1jwDInpXAoXualhpe35IKXvdm52sQ3Yscy0tWN)jiraOXY0dXDUizC1atUTK6rMR6eEcDpXgNyRtSLcRithPc7RsklKz8Wb0kvJspo1NIBfMLLeWOQfuyeupgQlfgmWbm4xHON41j03jwDcjCzzp1Cr2egjqMhof5)jE9Ccovyfz6ivyWahWGdQ)BQrPhN6VIBfMLLeWOQfuyeupgQlfgmWbm4xHON41Zj24eRoHeUSSNAUiBcJeiZJRDIvNyZtS5jiraOXY0dXDUizuZfztyZpuLJhzUQt4jEDc9)e85FcseaASm9qCNlsg1Cr2e28dv54rMR6eEcDpbNCEITobF(Nqcxw2tnxKnHrcK5Htr(FcDFoXgNGp)tiHll7PMlYMWibY8iZvDcpXRtOVtWN)jM2zSjy02oXRtWP(oXwkSImDKkmQ5IukaJAu6X52R4wHzzjbmQAbfwrMosfgPaawrMosgOHJcd0WHLLZuys4nGYkg8Rqu1OgfMgYiHtQgf3k92P4wHzzjbmQAb1O0Jtf3kmlljGrvlOgLEBO4wHzzjbmQAb1O0BTkUvyfz6ivyqCNlsMSb4HxiQcZYscyu1cQrPN(uCRWSSKagvTGcJRcGBkSPawoEQ5ISjmsKqCN20r6TSKag9eRoXgNGp)t8McRithPcJRc1LeWuyCviwwotHn)qvoS2PbvJsp9xXTcZYscyu1ckmcQhd1LcBkGLJVZ0qmQ5Ie6TSKagvHvKPJuH1zAig1CrcvJsVTxXTcZYscyu1ckmcQhd1LcBnNqkGWtS6es4YY(LnGYANg0dNI8)e6EIDkSImDKkmTyPHyWw7ls1O0BBR4wHzzjbmQAb1O0thvCRWkY0rQW0IPJuHzzjbmQAb1O0B3BkUvywwsaJQwqHrq9yOUuysbeEc(8prrMosp1CrkfGXtk4WM2zN45eVPWkY0rQWOMlsPamQrP3UDkUvywwsaJQwqHrq9yOUuyR5esbeEc(8prrMosp1CrkfGXtk4WM2zNq3t8McRithPcd(v0yjtkaJAuJclT5ZqmTanfGvKP5YuCR0BNIBfwrMosfMudmijWr8mMu4KmeuHzzjbmQAb1O0Jtf3kmlljGrvlOWiOEmuxkmseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNy3gNGp)tSMtyBJ4TMMr9lBGmYOqgS51awiZG4AgQdedI7Cr2jpfwrMosfgpu7IgzmzdWdVqu1O0Bdf3kmlljGrvlOWiOEmuxkmseaASm9qCNlsg1Cr2e28dv54rMR6eEcDpXAF7e85FcseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNyhNkSImDKkmiUZfjJRgyYTLu1O0BTkUvywwsaJQwqHrq9yOUuyBEcseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNqhpXQtiHll7PMlYMWifa0jppYCvNWtS1j4Z)eBEcseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNy3UtS6eR5es4YYEQ5ISjmsbaDYZJmx1j8eBDc(8pbjcanwMEiUZfjJAUiBcB(HQC8iZvDcpHUNy3Avyfz6ivyKcayuKvu4uG)gcQgLE6tXTcZYscyu1ckmcQhd1Lcdg4ag8Rq0t8CIDNy1j28eKia0yz6jfaWOiROWPa)ne0Jmx1j8eVorrMosp8ROXsMuagpPGdBANDc(8pXMNykGLJxQbgKe4iEgtkCsgc6TSKag9eRobjcanwMEPgyqsGJ4zmPWjziOhzUQt4jEDIImDKE4xrJLmPamEsbh20o7eBDITuyfz6ivyKcayfz6izGgokmqdhwwotHjH3akRyWVcrvJsp9xXTcZYscyu1ckmcQhd1LcBZtS5jiraOXY0tkaGrrwrHtb(BiOhzUQt4j09efz6i9uZfPuagpPGdBANDIToXQtS5jiraOXY0tkaGrrwrHtb(BiOhzUQt4j09efz6i9WVIglzsby8KcoSPD2j26eBDIvNGebGgltFAZNHyAbAkGhzUQt4j09eBEID6V(oXINOithP)RsklKz8Wb0k9KcoSPD2j2sHvKPJuH9vjLfYmE4aALQrP32R4wHzzjbmQAbfgb1JH6sHjHll7tB(metlqtb8iZvDcpXRtOVtS6eWahWGFfIEINt8McRithPcdI7CrYOMlYMWMFOkh1O0BBR4wHzzjbmQAbfgb1JH6sHjHll7tB(metlqtb8iZvDcpXRtuKPJ0dXDUizuZfztyZpuLJNuWHnTZoXIN4nV(uyfz6ivyqCNlsg1Cr2e28dv5OgLE6OIBfMLLeWOQfuyeupgQlfMeUSSNAUiBcJeiZJRDIvNag4ag8Rq0t865eBOWkY0rQWOMlsPamQrP3U3uCRWSSKagvTGcRithPcJuaaRithjd0WrHbA4WYYzkmj8gqzfd(viQAuJclT5ZqmTanfGjH3aAN8uCR0BNIBfMLLeWOQfuyeupgQlfgmWbm4xHONq3NtOVtS6eBEI1CIPawoETyPHyWw7lsVLLeWONGp)tiHll7PMlYMWibY84ANylfwrMosfwAZNHyAbAkGAu6XPIBfwrMosfgPaagfzffof4VHGkmlljGrvlOgLEBO4wHzzjbmQAbfgb1JH6sHrIaqJLPNuaaJISIcNc83qqpYCvNWtO7j2TTpXQtadCad(vi6j095eBOWkY0rQW(QKYczgpCaTs1O0BTkUvywwsaJQwqHrq9yOUuys4YY(LnGYANg0dNI8)e6(CcopXQtiHll7PMlYMWibY8WPi)pXRNtW5jwDcjCzzp1Cr2eMwS0qEASmpXQtadCad(vi6j095eBOWkY0rQW0ILgIbBTVivJsp9P4wHzzjbmQAbfgb1JH6sHbdCad(vi6j095e6tHvKPJuH9vjLfYmE4aALQrPN(R4wHzzjbmQAbfwrMosfgPaawrMosgOHJcd0WHLLZuys4nGYkg8Rqu1OgfMeEdOSIb)kevXTsVDkUvyfz6ivyWahWGdQ)BkmlljGrvlOgLECQ4wHvKPJuHb)kASKjfGrHzzjbmQAb1Ogfw70abSJuXTsVDkUvywwsaJQwqHrq9yOUuyBEcjCzz)YgqzTtd6Htr(FcDFoH(FIvNyZtadCad(vi6jEDInobF(NqdzCX4rO(DEsbamkYkkCkWFdbpbF(Nqcxw2VSbuw70GE4uK)Nq3NtOJNGp)tOHmUy8iu)oVudmijWr8mMu4Kme8e85FInpXAoHgY4IXJq978FvszHmJhoGw5jwDI1CcnKXfJhH650)vjLfYmE4aALNyRtS1jwDI1CcnKXfJhH635)QKYczgpCaTYtS6eR5eAiJlgpc1ZP)RsklKz8Wb0kpXQtiHll7PMlYMW0ILgYtJL5j26e85FInpX0oJnbJ22jEDInoXQtiHll7x2akRDAqpCkY)tO7jE7eBDc(8pXMNqdzCX4rOEo9KcayuKvu4uG)gcEIvNqcxw2VSbuw70GE4uK)Nq3tW5jwDI1CIPawoEQ5ISjmsbaDYZBzjbm6j2sHvKPJuH1onqa7ivJspovCRWSSKagvTGcJG6XqDPWiraOXY0dXDUizuZfztyZpuLJhzUQt4jEDIDBCc(8pXAoHTnI3AAg1VSbYiJczWMxdyHmdIRzOoqmiUZfzN8uyfz6ivy8qTlAKXKnap8crvJsVnuCRWSSKagvTGcJG6XqDPW28eKia0yz6H4oxKmQ5ISjS5hQYXJmx1j8eVoHoEIvNqcxw2tnxKnHrkaOtEEK5QoHNyRtWN)j28eKia0yz6H4oxKmQ5ISjS5hQYXJmx1j8eVoXUDNy1jwZjKWLL9uZfztyKca6KNhzUQt4j26e85FcseaASm9qCNlsg1Cr2e28dv54rMR6eEcDpXU1QWkY0rQWifaWOiROWPa)neunk9wRIBfMLLeWOQfuyeupgQlfMeUSSFzdOS2Pb9WPi)pHUNGRc1LeW8ZpuLdRDAqfwrMosfge35IKrnxKnHn)qvoQrPN(uCRWSSKagvTGcJG6XqDPWGboGb)ke9e6(Cc9PWkY0rQW(QKYczgpCaTs1O0t)vCRWSSKagvTGcJG6XqDPWGboGb)ke9e6(CInoXQtS5j28eBEcnKXfJhH650)vjLfYmE4aALNGp)tiHll7x2akRDAqpCkY)tO7Zj24eBDIvNqcxw2VSbuw70GE4uK)N41j0XtS1j4Z)eKia0yz6H4oxKmQ5ISjS5hQYXJmx1j8eVEobpc9eVZj48e85FcjCzzp1Cr2eMwS0qEK5QoHNq3tWJqpX7CcopXwkSImDKkSVkPSqMXdhqRunk92Ef3kmlljGrvlOWiOEmuxkmnKXfJhH635)QKYczgpCaTYtS6eWahWGFfIEcDFoXUtS6eBEcjCzz)YgqzTtd6Htr(FIxpNyJtWN)j0qgxmEeQFd)xLuwiZ4HdOvEIToXQtadCad(vi6jEDI1EIvNqcxw2tnxKnHrcK5X1uyfz6ivyuZfPuag1O0BBR4wHzzjbmQAbfgb1JH6sHT5jiraOXY0dXDUizuZfztyZpuLJhzUQt4j09eR9TtS6eqndaytH4zd03onqa7ipXRNtW5j26e85FcseaASm9qCNlsg1Cr2e28dv54rMR6eEIxNyhNkSImDKkmiUZfjJRgyYTLu1O0thvCRWSSKagvTGcJG6XqDPWiraOXY0dXDUizuZfztyZpuLJhzUQt4j09e6OcRithPctQbgKe4iEgtkCsgcQgLE7EtXTcZYscyu1ckmcQhd1Lcdg4ag8Rq0t86e67eRoHeUSSNAUiBcJeiZdNI8)eVEobNkSImDKkmyGdyWb1)n1O0B3of3kmlljGrvlOWiOEmuxkmyGdyWVcrpXRNtSXjwDcjCzzp1Cr2egjqMhx7eRoXMNqcxw2tnxKnHrcK5Htr(FcDFoXgNGp)tiHll7PMlYMWibY8iZvDcpXRNtWJqpX7Cc953(tSLcRithPcJAUiLcWOgLE74uXTcZYscyu1ckSImDKkmAeofg5hbySPq8SbQ0BNcZv6mJ8Jam2uiE2avyBVcJG6XqDPWqMmYGFLeWuJsVDBO4wHzzjbmQAbfwrMosfgPaawrMosgOHJcd0WHLLZuys4nGYkg8Rqu1Og1Og1Oua]] )

    
end
