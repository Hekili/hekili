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
                    print( "Wiping " .. dcon_imps .. " imps for dcon." )
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
                if azerite.explosive_potential.enabled and buff.wild_imps.stack >= 3 then applyBuff( "explosive_potential" ) end
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


    spec:RegisterPack( "Demonology", 20190207.2015, [[dKujubqifQ8isfAtkKpPivyuksoLIOvPakVsbAwkuUfPISlH(LkvdtLIJPISmuHNPimnfPCnfGTrQO(Mcv14uOkDovk16uOkMNk09uu7JO0bvKkAHKk9qfPktKubDrfPs2Oci0hvKkvNubeSsvWmjvaTtIk)urQugQcOAPksv9uOmvIIRsQa8vsfO9s4VOmysoSKfJQEmIjJ0LPSzI8zuPrRsoTuVwf1Sv1TfSBr)MQHtkhxbeTCiphy6kDDOA7ev9Df04vPKZJkA9kG08jvTFqlojKrGrR1eYXXnNU9nCCZ4h54MtJ)agFb2YPMjW0kY5IRjWYkycmDOf80FNlNcmTIZ3lQqgbgWXretGDTRgy8C)o3EVW5JepCh0b8V22tcQK27GoqUZ)o)DEPsNOM831qUu)g4(ahzt)QPG7d8PpthSqVtoZ0HwWt)DUCgbDGiW4X7FhiKcEbgTwtihh3C623WXnJFKJBon(NeyanJiKJdDwNfyxnLAPGxGrnarGPJqLo0cE6VZLtOshSqVtodpOJq11UAGXZ97C79cNps8WDqhW)ABpjOsAVd6a5o)7835LkDIAYFxd5s9BG7dCKn9RMcUpWN(mDWc9o5mthAbp935Yze0bc8GocvdenEeEH4eQg)XGkoU50THkDcQ44MXZPbapapOJq107QsUgy8apOJqLobvyA2)qLoqNCocpOJqLobv6aaguXJljftBVmetZrB9rCnOQtWAffQCjOczHQZo5cvtpDiuTDWGkjhbvYz7LHGQbUJ26HQIST8guPDvalcpOJqLobvt3YNtOczepeSKcv6ql4jV)luPHmDI4b(AHQwcQ6fQAau1jyRCHQPaxo(tHknKZx8pNqfy7)HQRcrjfyNmcpOJqLobvdCFOHGkSw7YtOQ(3hAuOsdz6eXd81cvRdvAiNavDc2kxOshAbp59FJWd6iuPtq10jLcvUMLgcQWUkQpeQ01)fQC8f0udQCjOI3baOsQ5ETaOADOQwO6TcSqfxBHkpnOk4idQaxfIgHh0rOsNGkzgA1zOA65japOTTN3NUUL27GwEdQCnlneuTouXBqvWrguT(BOkxOYLGkAljzilxOsQ5ETqfyl0cvGEXRT9eefyAixQFtGPJqLo0cE6VZLtOshSqVtodpOJq11UAGXZ97C79cNps8WDqhW)ABpjOsAVd6a5o)7835LkDIAYFxd5s9BG7dCKn9RMcUpWN(mDWc9o5mthAbp935Yze0bc8GocvdenEeEH4eQg)XGkoU50THkDcQ44MXZPbapapOJq107QsUgy8apOJqLobvyA2)qLoqNCocpOJqLobv6aaguXJljftBVmetZrB9rCnOQtWAffQCjOczHQZo5cvtpDiuTDWGkjhbvYz7LHGQbUJ26HQIST8guPDvalcpOJqLobvt3YNtOczepeSKcv6ql4jV)luPHmDI4b(AHQwcQ6fQAau1jyRCHQPaxo(tHknKZx8pNqfy7)HQRcrjfyNmcpOJqLobvdCFOHGkSw7YtOQ(3hAuOsdz6eXd81cvRdvAiNavDc2kxOshAbp59FJWd6iuPtq10jLcvUMLgcQWUkQpeQ01)fQC8f0udQCjOI3baOsQ5ETaOADOQwO6TcSqfxBHkpnOk4idQaxfIgHh0rOsNGkzgA1zOA65japOTTN3NUUL27GwEdQCnlneuTouXBqvWrguT(BOkxOYLGkAljzilxOsQ5ETqfyl0cvGEXRT9eeHhGh0rOA66wgbFnkuXBsoYGkIh4RfQ4nUDcIq10jHyAlaQsp1PRcfKWFOQiB7jaQ885mcpuKT9ee1qgXd81ol9f4m8qr22tqudzepWx7GZ3LCNcpuKT9ee1qgXd81o489cNBWYT22t4HISTNGOgYiEGV2bNVdWdbpzA2cpuKT9ee1qgXd81o489otdXOwWtWyT08wVLBSZ0qmQf8eeTS4FJcpuKT9ee1qgXd81o48DnFOHyGw7YZXAPzECjP4W(PSoObIGTiNL9e8qr22tqudzepWx7GZ318T9eEOiB7jiQHmIh4RDW57ul4jV)7yT0mVda61xKT9msTGN8(Vrsbw22bB(g4HISTNGOgYiEGV2bNVdUkQpKX7)owlnpoEha0RViB7zKAbp59FJKcSSTdMS3apapOJq101Tmc(AuOYK3qCcvBhmOAVmOQiRJGQgavL8v)f)Br4HISTNGzGM9p7DYz4HISTNGbNVR5B75yT0SMTrQf8SjSLtuLBSiBlVnAQXT1B5gtBVmetZrB9rll(3O61ZJljftBVmetZrB9rCTjHhkY2EcgC(ooWy9AbWyT0SMTrQf8SjSLtuLBSiBlVbpuKT9em48DEdbm05o5owlnRzBKAbpBcB5ev5glY2YBWdfzBpbdoFN)DNYKWrCowlnRzBKAbpBcB5ev5glY2YBWdfzBpbdoFxQrg)7oDSwAwZ2i1cE2e2YjQYnwKTL3GhkY2EcgC(oP(NvKT9K9nyhlRGntjEYmnMRzPHgRLMRbQH61I2T0Eh0YBmnFTC76JOkppAR3YnsTGNnHr8eGh022ZOLf)B0rBhSJtCZOXrC)P(WmcWdbpzul4ztylNOk3iYcvNa4HISTNGbNVFvjL5smU4pTYXAP5AGAOETODlT3bT8gtZxl3U(iQYZJ2oyhhWiGJ)mWvHOYYXiECjPODlT3bT8gtZxl3U(i1hMJ4XLKId7NY6Ggic2IC(4eJgNgYKNXLqJNIxvszUeJl(tRC040qM8mUeAKJ4vLuMlX4I)0kHhkY2EcgC(o1cEY7)owlndC8NbUke948eJ4XLKIul4ztyehzrCTr84ssrQf8SjmIJSiylY55PbpuKT9em489oO9oO9CSwAUgOgQxlA3s7DqlVX081YTRpIQ88iECjP4W(PSoObIGTiNLLJr84ssr7wAVdA5nMMVwUD9rKfQobhlY2Egbxf1hY49FJ2Tmc(ASTdg8qr22tWGZ37G27G2ZXAP5AGAOETODlT3bT8gtZxl3U(iQYZJ4XLKId7NY6Ggic2ICwwogXJljfTBP9oOL3yA(A521hrwO6eCK4(t9HzeGhcEYOwWZMWworvUrKfQobJiU)uFygb4HGNmQf8SjSLtuLBezHQtWXtNgT1B5gPwWZMWiEcWdAB7z0YI)nk8qr22tWGZ3PUhgRLMh32KZDYD0wiU2g3oyS1z02KDIBgb0S)zBH4Ali2bT3bTNh5aEOiB7jyW5789BaIJJ4AmEpWBiWyT0CnqnuVw0UL27GwEJP5RLBxFev5zzVz02b74PBgb0S)zBH4Ali2bT3bTNh5yepUKuKISIc26pBiqezHQtWOTEl3yA7LHyAoARpAzX)gfEOiB7jyW57ul4ztyGfzj39ASwAEkECjP4W(PSoObIGTiNpQZ61ZJljfPwWZMW08HgkIRnPE9an7F2wiU2cIDq7Dq75roGhkY2EcgC(oP(NvKT9K9nyhlRGnN2EziMMJ26hRLM36TCJPTxgIP5OT(OLf)B0ran7F2wiU2cIDq7Dq75XzoGhkY2EcgC(oP(NvKT9K9nyhlRGn3bT3bTNJ1sZan7F2wiU2cIDq7Dq7PSNGhkY2EcgC(oxuh8gzmj75Ixi6yT0mX9N6dZiape8KrTGNnHTCIQCJiluDcoEAc4HISTNGbNVdWdbpzY3Vj1wshRLMjU)uFygb4HGNmQf8SjSLtuLBezHQtGSt7g96jU)uFygb4HGNmQf8SjSLtuLBezHQtWXtCapuKT9em48Ds9pJISIc26pBiWyT08ue3FQpmJa8qWtg1cE2e2YjQYnISq1j44ThXJljfPwWZMWi1)DYnISq1jys96NI4(t9HzeGhcEYOwWZMWworvUrKfQobhpDA044XLKIul4ztyK6)o5grwO6emPE9e3FQpmJa8qWtg1cE2e2YjQYnISq1jq2ttdEOiB7jyW5789BaIJJ4AmEpWBia8qr22tWGZ3b4HGNmQf8SjSLtuL7yT0mWXFg4Qq0JtmAQXT1B5gPwWZMWiEcWdAB7z0YI)nQE984ssXH9tzDqdebBrol7ntcpuKT9em48DnFOHyGw7YZXAPzECjP4W(PSoObIGTiNLDMJr84ssrQf8SjmIJSiylY5JZCmIhxsksTGNnHP5dnuK6dZran7F2wiU2cIDq7Dq75roGhkY2EcgC(o19WyT08wVLBK6EiAzX)gDeYKqg4Q4FB0wiU2g3oyS1z02KDkQVrQ7HiYcvNGbN4MjHhkY2EcgC((vLuMlX4I)0khRLMbo(ZaxfIk78a0RFkGJ)mWvHOYopXiI7p1hMrs9pJISIc26pBiqezHQtGStB0ue3FQpmJa8qWtg1cE2e2YjQYnISq1jqwoUrV(PiU)uFygb4HGNmQf8SjSLtuLBezHQtWrUe6aJJrB9wUrQf8SjmINa8G22EgTS4FJQxpX9N6dZiape8KrTGNnHTCIQCJiluDcoYLqhytB0426TCJul4ztyepb4bTT9mAzX)gDYjhn1426TCJa8qWtM89BsTL0OLf)Bu96jU)uFygb4HGNm573KAlPrKfQobYoXKtcpuKT9em48DGJ)mWI6Z2yT0mWXFg4Qq0JdyepUKuKAbpBcJ4ilc2IC(4mhWdfzBpbdoFNAbp59FhRLMbo(ZaxfIECEIr84ssrQf8SjmIJSiU2OPMI4(t9HzeGhcEYOwWZMWworvUrKfQobh1z96jU)uFygb4HGNmQf8SjSLtuLBezHQtGSCWXK61ZJljfPwWZMWioYIGTiNLDEc965XLKIul4ztyehzrKfQobhhGE9Bhm26mABh5yatcpuKT9em48Ds9pRiB7j7BWowwbBMhVFkRyGRcrHhGhkY2EcI849tzfdCvi6mWXFgyr9zdEOiB7jiYJ3pLvmWvHOdoFhCvuFiJ3)fEaEOiB7ji2bT3bTNZDq7Dq75yT08u84ssXH9tzDqdebBrol7SopAkGJ)mWvHOhNqVEnKjpJlHgpfj1)mkYkkyR)SHa61ZJljfh2pL1bnqeSf5SSZ3wVEnKjpJlHgpf573aehhX1y8EG3qa96NACAitEgxcnEkEvjL5smU4pTYrJtdzYZ4sOroIxvszUeJl(tRCYjhnonKjpJlHgpfVQKYCjgx8Nw5OXPHm5zCj0ihXRkPmxIXf)PvoIhxsksTGNnHP5dnuK6dZj1RFQTdgBDgTTJtmIhxskoSFkRdAGiylYzzVzs96NsdzYZ4sOroIK6FgfzffS1F2qGr84ssXH9tzDqdebBrollhJg3wVLBKAbpBcJu)3j3OLf)B0jHhkY2EcIDq7Dq75GZ35I6G3iJjzpx8crhRLMjU)uFygb4HGNmQf8SjSLtuLBezHQtWXttOx)4Sbs8wtZOXttWXe68THhkY2EcIDq7Dq75GZ3j1)mkYkkyR)SHaJ1sZtrC)P(WmcWdbpzul4ztylNOk3iYcvNGJ3EepUKuKAbpBcJu)3j3iYcvNGj1RFkI7p1hMraEi4jJAbpBcB5ev5grwO6eC80PrJJhxsksTGNnHrQ)7KBezHQtWK61tC)P(WmcWdbpzul4ztylNOk3iYcvNazpnn4HISTNGyh0Eh0Eo48DaEi4jJAbpBcB5ev5cpuKT9ee7G27G2ZbNVFvjL5smU4pTYXAPzGJ)mWvHOYopa4HISTNGyh0Eh0Eo489RkPmxIXf)PvowlndC8NbUkev25jgn1utPHm5zCj0ihXRkPmxIXf)PvQxppUKuCy)uwh0arWwKZYopXKJ4XLKId7NY6Ggic2IC(4TNuVEI7p1hMraEi4jJAbpBcB5ev5grwO6eCCMlHoW4qVEECjPi1cE2eMMp0qrKfQobYYLqhyCmj8qr22tqSdAVdAphC(o1cEY7)owlnRHm5zCj04P4vLuMlX4I)0khbC8NbUkev25tJMIhxskoSFkRdAGiylY5JZtOxVgYKNXLqJteVQKYCjgx8Nw5KJao(ZaxfIECAJ4XLKIul4ztyehzrCn4HISTNGyh0Eh0Eo48DaEi4jt((nP2s6yT08ue3FQpmJa8qWtg1cE2e2YjQYnISq1jq2PDZiGM9pBlexBbXoO9oO984mhtQxpX9N6dZiape8KrTGNnHTCIQCJiluDcoEId4HISTNGyh0Eh0Eo48D((naXXrCngVh4neySwAM4(t9HzeGhcEYOwWZMWworvUrKfQobYEB4HISTNGyh0Eh0Eo48DGJ)mWI6Z2yT0mWXFg4Qq0JdyepUKuKAbpBcJ4ilc2IC(4mhWdfzBpbXoO9oO9CW57ul4jV)7yT0mWXFg4Qq0JZtmIhxsksTGNnHrCKfX1gnfpUKuKAbpBcJ4ilc2ICw25j0RNhxsksTGNnHrCKfrwO6eCCMlHoWgqC8NeEOiB7ji2bT3bTNdoFN6EymcNK3yBH4Aly(0yH6wmcNK3yBH4AlyE8hRLMrMeYaxf)BWdfzBpbXoO9oO9CW57K6Fwr22t23GDSSc2mpE)uwXaxfIcpapuKT9eetBVmetZrB9ZK6Fwr22t23GDSSc2CA7LHyAoARNXJ3pTtUJ1sZe3FQpmJPTxgIP5OT(iYcvNGJCCd8qr22tqmT9YqmnhT1p48Ds9pRiB7j7BWowwbBoT9YqmnhT1ZkY2YBJ1sZ84ssX02ldX0C0wFexdEaEOiB7jiM2EziMMJ26zfzB5Tz((naXXrCngVh4neaEOiB7jiM2EziMMJ26zfzB5TbNVZf1bVrgtYEU4fIowlntC)P(WmcWdbpzul4ztylNOk3iYcvNGJNMqV(XzdK4TMMrJNMGJj05BdpuKT9eetBVmetZrB9SIST82GZ3b4HGNm573KAlPJ1sZe3FQpmJa8qWtg1cE2e2YjQYnISq1jq2PDJE9e3FQpmJa8qWtg1cE2e2YjQYnISq1j44joGhkY2EcIPTxgIP5OTEwr2wEBW57K6FgfzffS1F2qGXAP5PiU)uFygb4HGNmQf8SjSLtuLBezHQtWXBpIhxsksTGNnHrQ)7KBezHQtWK61pfX9N6dZiape8KrTGNnHTCIQCJiluDcoE60OXXJljfPwWZMWi1)DYnISq1jys96jU)uFygb4HGNmQf8SjSLtuLBezHQtGSNMg8qr22tqmT9YqmnhT1ZkY2YBdoFNVFdqCCexJX7bEdbGhkY2EcIPTxgIP5OTEwr2wEBW57K6Fwr22t23GDSSc2mpE)uwXaxfIowlndC8NbUkeD(0OPiU)uFygj1)mkYkkyR)SHarKfQobhlY2Egbxf1hY49FJKcSSTdME9tT1B5g573aehhX1y8EG3qGOLf)B0re3FQpmJ89BaIJJ4AmEpWBiqezHQtWXISTNrWvr9HmE)3iPalB7Gn5KWdfzBpbX02ldX0C0wpRiBlVn489RkPmxIXf)Pvowlnp1ue3FQpmJK6FgfzffS1F2qGiYcvNazlY2EgPwWtE)3iPalB7Gn5OPiU)uFygj1)mkYkkyR)SHarKfQobYwKT9mcUkQpKX7)gjfyzBhSjNCeX9N6dZyA7LHyAoARpISq1jq2PoPZdyWISTNXRkPmxIXf)PvgjfyzBhSjHhkY2EcIPTxgIP5OTEwr2wEBW57a8qWtg1cE2e2YjQYDSwAMhxskM2EziMMJ26JiluDcooGrah)zGRcrNVbEOiB7jiM2EziMMJ26zfzB5TbNVdWdbpzul4ztylNOk3XAPzECjPyA7LHyAoARpISq1j4yr22Ziape8KrTGNnHTCIQCJKcSSTd2G3eha8qr22tqmT9YqmnhT1ZkY2YBdoFNAbp59FhRLM5XLKIul4ztyehzrCTrah)zGRcrpopb8qr22tqmT9YqmnhT1ZkY2YBdoFNu)ZkY2EY(gSJLvWM5X7NYkg4Qqu4b4HISTNGyA7LHyAoARNXJ3pTtUZPTxgIP5OT(XAPzGJ)mWvHOYopGrtnUTEl3OMp0qmqRD5z0YI)nQE984ssrQf8SjmIJSiU2KWdfzBpbX02ldX0C0wpJhVFANChC(oP(NrrwrbB9NneaEOiB7jiM2EziMMJ26z849t7K7GZ3VQKYCjgx8Nw5yT0mX9N6dZiP(NrrwrbB9NneiISq1jq2tJ3rah)zGRcrLDEc4HISTNGyA7LHyAoARNXJ3pTtUdoFxZhAigO1U8CSwAMhxskoSFkRdAGiylYzzN5yepUKuKAbpBcJ4ilc2IC(4mhJ4XLKIul4ztyA(qdfP(WCeWXFg4QquzNNaEOiB7jiM2EziMMJ26z849t7K7GZ3VQKYCjgx8Nw5yT0mWXFg4QquzNha8qr22tqmT9YqmnhT1Z4X7N2j3bNVtQ)zfzBpzFd2XYkyZ849tzfdCvik8a8qr22tqKs8KzAmxZsdnFvjL5smU4pTYX(ongHopXnJ1sZah)zGRcrLDEc4HISTNGiL4jZ0yUMLgAW57Dq7Dq75yT0mpUKuCy)uwh0arWwKZYYXiECjPODlT3bT8gtZxl3U(i1hMWdfzBpbrkXtMPXCnln0GZ3PUhg770ye68e3apuKT9eePepzMgZ1S0qdoFNAbpBcdSil5UxWdfzBpbrkXtMPXCnln0GZ3573aehhX1y8EG3qa4HISTNGiL4jZ0yUMLgAW57a8qWtM89BsTLu4HISTNGiL4jZ0yUMLgAW57CrDWBKXKSNlEHOWdfzBpbrkXtMPXCnln0GZ3VQKYCjgx8Nw5yT0mWXFg4Qq05bOxpWXFg4Qq05PnIhxsksTGNnHrQ)7KBezHQta8qr22tqKs8KzAmxZsdn48Ds9pJISIc26pBiWyT0SgYKNXLqJNIxvszUeJl(tReEOiB7jisjEYmnMRzPHgC(oape8KrTGNnHTCIQChRLM1qM8mUeA8uKu)ZOiROGT(ZgcapuKT9eePepzMgZ1S0qdoFh44pdSO(SnwlnpfWXFg4Qq0JtOxpWXFg4Qq05PnIhxsksTGNnHrCKfbBroFCEIj1RNhxsksTGNnHrCKfP(WCeWXFg4Qq0JdaEOiB7jisjEYmnMRzPHgC(o1cEY7)owlndC8NbUke948eJ4XLKIul4ztyehzrKfQobWdfzBpbrkXtMPXCnln0GZ3j1)SISTNSVb7yzfSzE8(PSIbUkevGjVHaTNc544Mt3(goUzI4jDEAttGnSqzNCbcmDWPZPVCdeKB6(4bQGkzUmOQdAoAHkjhbvthAiJ4b(ANoGkKnqI3iJcvapyqvHVEOwJcvKRk5AGi8GoWonOAaJhOshqcW10C0AuOQiB7junD0zAig1cEcMoIWdWddecAoAnkunEHQISTNq13GfeHheyf(E5ibgwhMEcSVblqiJaJs8KzAmxZsdjKri3jHmcmll(3OcDfyfzBpfyxvszUeJl(tRuGrq9AOUeyah)zGRcrHkzNHQjeyFNgJqfytCJyfYXHqgbMLf)BuHUcmcQxd1LaJhxskoSFkRdAGiylYzOswOIdOAeuXJljfTBP9oOL3yA(A521hP(WuGvKT9uG1bT3bTNIvi3eczeyww8Vrf6kWkY2EkWOUheyFNgJqfytCJyfYnnHmcSISTNcmQf8SjmWISK7EjWSS4FJk0vSc5gGqgbwr22tbgF)gG44iUgJ3d8gciWSS4FJk0vSc50zHmcSISTNcmaEi4jt((nP2sQaZYI)nQqxXkKB8fYiWkY2EkW4I6G3iJjzpx8crfyww8Vrf6kwHCJxHmcmll(3OcDfyeuVgQlbgWXFg4QquOAgQgauPxpubC8NbUkefQMHQPbvJGkECjPi1cE2egP(VtUrKfQobcSISTNcSRkPmxIXf)PvkwHC3wiJaZYI)nQqxbgb1RH6sGPHm5zCj04P4vLuMlX4I)0kfyfzBpfyK6FgfzffS1F2qaXkK70nczeyww8Vrf6kWiOEnuxcmnKjpJlHgpfj1)mkYkkyR)SHacSISTNcmaEi4jJAbpBcB5ev5kwHCNojKrGzzX)gvORaJG61qDjWMcQao(ZaxfIcvhHQjGk96HkGJ)mWvHOq1munnOAeuXJljfPwWZMWioYIGTiNHQJZq1eq1KqLE9qfpUKuKAbpBcJ4ils9HjuncQao(ZaxfIcvhHQbiWkY2EkWao(ZalQpBIvi3joeYiWSS4FJk0vGrq9AOUeyah)zGRcrHQJZq1eq1iOIhxsksTGNnHrCKfrwO6eiWkY2EkWOwWtE)xXkK70eczeyww8Vrf6kWkY2EkWi1)SISTNSVbRa7BWYYkycmE8(PSIbUkevSIvGL2EziMMJ26fYiK7KqgbMLf)BuHUcmcQxd1LaJ4(t9HzmT9YqmnhT1hrwO6eavhHkoUrGvKT9uGrQ)zfzBpzFdwb23GLLvWeyPTxgIP5OTEgpE)0o5kwHCCiKrGzzX)gvORaJG61qDjW4XLKIPTxgIP5OT(iUMaRiB7PaJu)ZkY2EY(gScSVbllRGjWsBVmetZrB9SIST8MyfRaJAsf(VczeYDsiJaRiB7PadOz)ZENCwGzzX)gvORyfYXHqgbMLf)BuHUcmcQxd1LatZ2i1cE2e2YjQYnwKTL3GQrq1uq14GQTEl3yA7LHyAoARpAzX)gfQ0RhQ4XLKIPTxgIP5OT(iUgunPaRiB7PatZ32tXkKBcHmcmll(3OcDfyeuVgQlbMMTrQf8SjSLtuLBSiBlVjWkY2EkWWbgRxlaeRqUPjKrGzzX)gvORaJG61qDjW0SnsTGNnHTCIQCJfzB5nbwr22tbgVHag6CNCfRqUbiKrGzzX)gvORaJG61qDjW0SnsTGNnHTCIQCJfzB5nbwr22tbg)7oLjHJ4uSc50zHmcmll(3OcDfyeuVgQlbMMTrQf8SjSLtuLBSiBlVjWkY2EkWKAKX)UtfRqUXxiJaZYI)nQqxbgb1RH6sGvdud1RfTBP9oOL3yA(A521hrvEgQgbvB9wUrQf8SjmINa8G22EgTS4FJcvJGQTdguDeQM4gOAeunoOI4(t9HzeGhcEYOwWZMWworvUrKfQobcSISTNcms9pRiB7j7BWkW(gSSScMaJs8KzAmxZsdjwHCJxHmcmll(3OcDfyeuVgQlbwnqnuVw0UL27GwEJP5RLBxFev5zOAeuTDWGQJq1aGQrqfWXFg4QquOswOIdOAeuXJljfTBP9oOL3yA(A521hP(WeQgbv84ssXH9tzDqdebBrodvhHQjGQrq14GknKjpJlHgpfVQKYCjgx8NwjuncQghuPHm5zCj0ihXRkPmxIXf)PvkWkY2EkWUQKYCjgx8NwPyfYDBHmcmll(3OcDfyeuVgQlbgWXFg4QquO64munbuncQ4XLKIul4ztyehzrCnOAeuXJljfPwWZMWioYIGTiNHQzOAAcSISTNcmQf8K3)vSc5oDJqgbMLf)BuHUcmcQxd1LaRgOgQxlA3s7DqlVX081YTRpIQ8muncQ4XLKId7NY6Ggic2ICgQKfQ4aQgbv84ssr7wAVdA5nMMVwUD9rKfQobq1rOQiB7zeCvuFiJ3)nA3Yi4RX2oycSISTNcSoO9oO9uSc5oDsiJaZYI)nQqxbgb1RH6sGvdud1RfTBP9oOL3yA(A521hrvEgQgbv84ssXH9tzDqdebBrodvYcvCavJGkECjPODlT3bT8gtZxl3U(iYcvNaO6iurC)P(WmcWdbpzul4ztylNOk3iYcvNaOAeurC)P(WmcWdbpzul4ztylNOk3iYcvNaO6iuD6euncQ26TCJul4ztyepb4bTT9mAzX)gvGvKT9uG1bT3bTNIvi3joeYiWSS4FJk0vGrq9AOUeyJdQ2MCUtUq1iOAlexBJBhm26mABqLSq1e3avJGkGM9pBlexBbXoO9oO9eQocvCiWkY2EkWOUheRqUttiKrGzzX)gvORaJG61qDjWQbQH61I2T0Eh0YBmnFTC76JOkpdvYcv3avJGQTdguDeQoDduncQaA2)STqCTfe7G27G2tO6iuXbuncQ4XLKIuKvuWw)zdbIiluDcGQrq1wVLBmT9YqmnhT1hTS4FJkWkY2EkW473aehhX1y8EG3qaXkK700eYiWSS4FJk0vGrq9AOUeytbv84ssXH9tzDqdebBrodvhHkDgQ0RhQ4XLKIul4ztyA(qdfX1GQjHk96HkGM9pBlexBbXoO9oO9eQocvCiWkY2EkWOwWZMWalYsU7LyfYDAaczeyww8Vrf6kWiOEnuxcSTEl3yA7LHyAoARpAzX)gfQgbvan7F2wiU2cIDq7Dq7juDCgQ4qGvKT9uGrQ)zfzBpzFdwb23GLLvWeyPTxgIP5OTEXkK7KolKrGzzX)gvORaJG61qDjWaA2)STqCTfe7G27G2tOswO6KaRiB7PaJu)ZkY2EY(gScSVbllRGjW6G27G2tXkK704lKrGzzX)gvORaJG61qDjWiU)uFygb4HGNmQf8SjSLtuLBezHQtauDeQonHaRiB7PaJlQdEJmMK9CXlevSc5onEfYiWSS4FJk0vGrq9AOUeye3FQpmJa8qWtg1cE2e2YjQYnISq1jaQKfQM2nqLE9qfX9N6dZiape8KrTGNnHTCIQCJiluDcGQJq1joeyfzBpfya8qWtM89BsTLuXkK70TfYiWSS4FJk0vGrq9AOUeytbve3FQpmJa8qWtg1cE2e2YjQYnISq1jaQocv3gQgbv84ssrQf8Sjms9FNCJiluDcGQjHk96HQPGkI7p1hMraEi4jJAbpBcB5ev5grwO6eavhHQtNGQrq14GkECjPi1cE2egP(VtUrKfQobq1KqLE9qfX9N6dZiape8KrTGNnHTCIQCJiluDcGkzHQtttGvKT9uGrQ)zuKvuWw)zdbeRqooUriJaRiB7PaJVFdqCCexJX7bEdbeyww8Vrf6kwHCCCsiJaZYI)nQqxbgb1RH6sGbC8NbUkefQocvtavJGQPGQXbvB9wUrQf8SjmINa8G22EgTS4FJcv61dv84ssXH9tzDqdebBrodvYcv3avtkWkY2EkWa4HGNmQf8SjSLtuLRyfYXbhczeyww8Vrf6kWiOEnuxcmECjP4W(PSoObIGTiNHkzNHkoGQrqfpUKuKAbpBcJ4ilc2ICgQoodvCavJGkECjPi1cE2eMMp0qrQpmHQrqfqZ(NTfIRTGyh0Eh0EcvhHkoeyfzBpfyA(qdXaT2LNIvihhtiKrGzzX)gvORaJG61qDjW26TCJu3drll(3Oq1iOczsidCv8VbvJGQTqCTnUDWyRZOTbvYcvtbvuFJu3drKfQobq1Gq1e3avtkWkY2EkWOUheRqooMMqgbMLf)BuHUcmcQxd1Lad44pdCvikuj7munaOsVEOAkOc44pdCvikuj7munbuncQiU)uFygj1)mkYkkyR)SHarKfQobqLSq10GQrq1uqfX9N6dZiape8KrTGNnHTCIQCJiluDcGkzHkoUbQ0RhQMcQiU)uFygb4HGNmQf8SjSLtuLBezHQtauDeQ4sOq1adQ4aQgbvB9wUrQf8SjmINa8G22EgTS4FJcv61dve3FQpmJa8qWtg1cE2e2YjQYnISq1jaQocvCjuOAGbvtdQgbvJdQ26TCJul4ztyepb4bTT9mAzX)gfQMeQMeQgbvtbvJdQ26TCJa8qWtM89BsTL0OLf)BuOsVEOI4(t9HzeGhcEYKVFtQTKgrwO6eavYcvtavtcvtkWkY2EkWUQKYCjgx8NwPyfYXXaeYiWSS4FJk0vGrq9AOUeyah)zGRcrHQJq1aGQrqfpUKuKAbpBcJ4ilc2ICgQoodvCiWkY2EkWao(ZalQpBIvihh6SqgbMLf)BuHUcmcQxd1Lad44pdCvikuDCgQMaQgbv84ssrQf8SjmIJSiUguncQMcQMcQiU)uFygb4HGNmQf8SjSLtuLBezHQtauDeQ0zOsVEOI4(t9HzeGhcEYOwWZMWworvUrKfQobqLSqfhCavtcv61dv84ssrQf8SjmIJSiylYzOs2zOAcOsVEOIhxsksTGNnHrCKfrwO6eavhHQbav61dvBhm26mABq1rOIJbavtkWkY2EkWOwWtE)xXkKJJXxiJaZYI)nQqxbwr22tbgP(NvKT9K9nyfyFdwwwbtGXJ3pLvmWvHOIvScmnKr8aFTczeYDsiJaZYI)nQqxXkKJdHmcmll(3OcDfRqUjeYiWSS4FJk0vSc5MMqgbwr22tbgape8Kjzpx8crfyww8Vrf6kwHCdqiJaZYI)nQqxbgb1RH6sGT1B5g7mneJAbpbrll(3OcSISTNcSotdXOwWtGyfYPZczeyww8Vrf6kWiOEnuxcmECjP4W(PSoObIGTiNHkzHQtcSISTNcmnFOHyGw7YtXkKB8fYiWkY2EkW08T9uGzzX)gvORyfYnEfYiWSS4FJk0vGrq9AOUey8oaav61dvfzBpJul4jV)BKuGLTDWGQzO6gbwr22tbg1cEY7)kwHC3wiJaZYI)nQqxbgb1RH6sGnoOI3baOsVEOQiB7zKAbp59FJKcSSTdgujluDJaRiB7PadCvuFiJ3)vSIvGL2EziMMJ26zfzB5nHmc5ojKrGvKT9uGX3VbiooIRX49aVHacmll(3OcDfRqooeYiWSS4FJk0vGrq9AOUeye3FQpmJa8qWtg1cE2e2YjQYnISq1jaQocvNMaQ0RhQghuzdK4TMMrJd7xczuad0C7N5smaUMHAhXa4HGNDYvGvKT9uGXf1bVrgtYEU4fIkwHCtiKrGzzX)gvORaJG61qDjWiU)uFygb4HGNmQf8SjSLtuLBezHQtaujlunTBGk96HkI7p1hMraEi4jJAbpBcB5ev5grwO6eavhHQtCiWkY2EkWa4HGNm573KAlPIvi30eYiWSS4FJk0vGrq9AOUeytbve3FQpmJa8qWtg1cE2e2YjQYnISq1jaQocv3gQgbv84ssrQf8Sjms9FNCJiluDcGQjHk96HQPGkI7p1hMraEi4jJAbpBcB5ev5grwO6eavhHQtNGQrq14GkECjPi1cE2egP(VtUrKfQobq1KqLE9qfX9N6dZiape8KrTGNnHTCIQCJiluDcGkzHQtttGvKT9uGrQ)zuKvuWw)zdbeRqUbiKrGvKT9uGX3VbiooIRX49aVHacmll(3OcDfRqoDwiJaZYI)nQqxbgb1RH6sGbC8NbUkefQMHQtq1iOAkOI4(t9HzKu)ZOiROGT(ZgcerwO6eavhHQISTNrWvr9HmE)3iPalB7Gbv61dvtbvB9wUr((naXXrCngVh4neiAzX)gfQgbve3FQpmJ89BaIJJ4AmEpWBiqezHQtauDeQkY2Egbxf1hY49FJKcSSTdgunjunPaRiB7PaJu)ZkY2EY(gScSVbllRGjW4X7NYkg4QquXkKB8fYiWSS4FJk0vGrq9AOUeytbvtbve3FQpmJK6FgfzffS1F2qGiYcvNaOswOQiB7zKAbp59FJKcSSTdgunjuncQMcQiU)uFygj1)mkYkkyR)SHarKfQobqLSqvr22Zi4QO(qgV)BKuGLTDWGQjHQjHQrqfX9N6dZyA7LHyAoARpISq1jaQKfQMcQoPZdaQgeQkY2EgVQKYCjgx8NwzKuGLTDWGQjfyfzBpfyxvszUeJl(tRuSc5gVczeyww8Vrf6kWiOEnuxcmECjPyA7LHyAoARpISq1jaQocvdaQgbvah)zGRcrHQzO6gbwr22tbgape8KrTGNnHTCIQCfRqUBlKrGzzX)gvORaJG61qDjW4XLKIPTxgIP5OT(iYcvNaO6iuvKT9mcWdbpzul4ztylNOk3iPalB7Gbvdcv3ehGaRiB7PadGhcEYOwWZMWworvUIvi3PBeYiWSS4FJk0vGrq9AOUey84ssrQf8SjmIJSiUguncQao(ZaxfIcvhNHQjeyfzBpfyul4jV)RyfYD6KqgbMLf)BuHUcSISTNcms9pRiB7j7BWkW(gSSScMaJhVFkRyGRcrfRyfyPTxgIP5OTEgpE)0o5kKri3jHmcmll(3OcDfyeuVgQlbgWXFg4QquOs2zOAaq1iOAkOACq1wVLBuZhAigO1U8mAzX)gfQ0RhQ4XLKIul4ztyehzrCnOAsbwr22tbwA7LHyAoARxSc54qiJaRiB7PaJu)ZOiROGT(ZgciWSS4FJk0vSc5MqiJaZYI)nQqxbgb1RH6sGrC)P(WmsQ)zuKvuWw)zdbIiluDcGkzHQtJxOAeubC8NbUkefQKDgQMqGvKT9uGDvjL5smU4pTsXkKBAczeyww8Vrf6kWiOEnuxcmECjP4W(PSoObIGTiNHkzNHkoGQrqfpUKuKAbpBcJ4ilc2ICgQoodvCavJGkECjPi1cE2eMMp0qrQpmHQrqfWXFg4QquOs2zOAcbwr22tbMMp0qmqRD5PyfYnaHmcmll(3OcDfyeuVgQlbgWXFg4QquOs2zOAacSISTNcSRkPmxIXf)PvkwHC6SqgbMLf)BuHUcSISTNcms9pRiB7j7BWkW(gSSScMaJhVFkRyGRcrfRyfy849tzfdCviQqgHCNeYiWkY2EkWao(ZalQpBcmll(3OcDfRqooeYiWkY2EkWaxf1hY49Ffyww8Vrf6kwXkW6G27G2tHmc5ojKrGzzX)gvORaJG61qDjWMcQ4XLKId7NY6Ggic2ICgQKDgQ0zOAeunfubC8NbUkefQocvtav61dvAitEgxcnEksQ)zuKvuWw)zdbGk96HkECjP4W(PSoObIGTiNHkzNHQBdv61dvAitEgxcnEkY3VbiooIRX49aVHaqLE9q1uq14GknKjpJlHgpfVQKYCjgx8NwjuncQghuPHm5zCj0ihXRkPmxIXf)PvcvtcvtcvJGQXbvAitEgxcnEkEvjL5smU4pTsOAeunoOsdzYZ4sOroIxvszUeJl(tReQgbv84ssrQf8SjmnFOHIuFycvtcv61dvtbvBhm26mABq1rOAcOAeuXJljfh2pL1bnqeSf5mujluDdunjuPxpunfuPHm5zCj0ihrs9pJISIc26pBiauncQ4XLKId7NY6Ggic2ICgQKfQ4aQgbvJdQ26TCJul4ztyK6)o5gTS4FJcvtkWkY2EkW6G27G2tXkKJdHmcmll(3OcDfyeuVgQlbgX9N6dZiape8KrTGNnHTCIQCJiluDcGQJq1PjGk96HQXbv2ajERPz04W(LqgfWan3(zUedGRzO2rmaEi4zNCfyfzBpfyCrDWBKXKSNlEHOIvi3eczeyww8Vrf6kWiOEnuxcSPGkI7p1hMraEi4jJAbpBcB5ev5grwO6eavhHQBdvJGkECjPi1cE2egP(VtUrKfQobq1KqLE9q1uqfX9N6dZiape8KrTGNnHTCIQCJiluDcGQJq1Ptq1iOACqfpUKuKAbpBcJu)3j3iYcvNaOAsOsVEOI4(t9HzeGhcEYOwWZMWworvUrKfQobqLSq1PPjWkY2EkWi1)mkYkkyR)SHaIvi30eYiWkY2EkWa4HGNmQf8SjSLtuLRaZYI)nQqxXkKBaczeyww8Vrf6kWiOEnuxcmGJ)mWvHOqLSZq1aeyfzBpfyxvszUeJl(tRuSc50zHmcmll(3OcDfyeuVgQlbgWXFg4QquOs2zOAcOAeunfunfunfuPHm5zCj0ihXRkPmxIXf)Pvcv61dv84ssXH9tzDqdebBrodvYodvtavtcvJGkECjP4W(PSoObIGTiNHQJq1THQjHk96HkI7p1hMraEi4jJAbpBcB5ev5grwO6eavhNHkUekunWGkoGk96HkECjPi1cE2eMMp0qrKfQobqLSqfxcfQgyqfhq1KcSISTNcSRkPmxIXf)PvkwHCJVqgbMLf)BuHUcmcQxd1LatdzYZ4sOXtXRkPmxIXf)PvcvJGkGJ)mWvHOqLSZq1jOAeunfuXJljfh2pL1bnqeSf5muDCgQMaQ0RhQ0qM8mUeACI4vLuMlX4I)0kHQjHQrqfWXFg4QquO6iunnOAeuXJljfPwWZMWioYI4AcSISTNcmQf8K3)vSc5gVczeyww8Vrf6kWiOEnuxcSPGkI7p1hMraEi4jJAbpBcB5ev5grwO6eavYcvt7gOAeub0S)zBH4Ali2bT3bTNq1XzOIdOAsOsVEOI4(t9HzeGhcEYOwWZMWworvUrKfQobq1rO6ehcSISTNcmaEi4jt((nP2sQyfYDBHmcmll(3OcDfyeuVgQlbgX9N6dZiape8KrTGNnHTCIQCJiluDcGkzHQBlWkY2EkW473aehhX1y8EG3qaXkK70nczeyww8Vrf6kWiOEnuxcmGJ)mWvHOq1rOAaq1iOIhxsksTGNnHrCKfbBrodvhNHkoeyfzBpfyah)zGf1NnXkK70jHmcmll(3OcDfyeuVgQlbgWXFg4QquO64munbuncQ4XLKIul4ztyehzrCnOAeunfuXJljfPwWZMWioYIGTiNHkzNHQjGk96HkECjPi1cE2egXrwezHQtauDCgQ4sOq1adQgqC8HQjfyfzBpfyul4jV)RyfYDIdHmcmll(3OcDfyfzBpfyu3dcmcNK3yBH4Alqi3jbwOUfJWj5n2wiU2ceyJVaJG61qDjWqMeYaxf)BIvi3PjeYiWSS4FJk0vGvKT9uGrQ)zfzBpzFdwb23GLLvWey849tzfdCviQyfRyfRyfc]] )

    
end
