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


    spec:RegisterPack( "Demonology", 20190220.2359, [[dK0xwbqisv1JqvQ2Ks0NukvyukfDkLcRsPu1RucnlLsUfPQyxu1VqfgMQuoMQKLPQQNPK00ukLRPkvBtjr(MscmoLe05qvI1PKOAEkvUNQyFKkDqLsfTqLGhQKOmrsvjxevjPnIQKGpIQKqNujH0kvQAMOkjANKQ8tsvPQHIQKAPkLk9uOmvufxLuvQ8vsvPSxs(lkdMWHLSyI8yetgPltzZe1NrLgTQYPL61QQmBGBtLDl63cdNuoUscXYH8CqtxX1HQTtQ47kPgpQs58OIwVsc18rvTFvw9sXJcJwJP07)BV4L3())n))vFFf((2uydNAMctRi)kUMcllNPW0xMlYaeC5uHPvCcIIQ4rHbdCeXuyFZObx5CWb3E(WL8KWXbSD4GA6ijOsE4a2ochsGqIdj5sFOMoCOHc5gyqo41iB7wnfYbVE7Y03keii)y6lZfzacUC6HTJOWKWBWSIMkjfgTgtP3)3EXlV9))B()R((k89xkmOMru69FLwjf2xtPwQKuyudsuy8(j0xMlYaeC58e6BfceKF3EE)eFZObx5CWb3E(WL8KWXbSD4GA6ijOsE4a2ochsGqIdj5sFOMoCOHc5gyqo41iB7wnfYbVE7Y03keii)y6lZfzacUC6HTJC759tWRGjHWleNN4)BBDI)V9IxoH(CI)RUYF9(T)2Z7NyL9vjxdUYV98(j0NtGPzaWj4vgKF(BpVFc95e67G2jKWLL9PnFgIPfOPaECTt0jCSIEIq(eiZvD2j3tSY0xNyANDc5aDc9S5ZqNGxhOPaNOitRJDcTVcA(BpVFc95e67taNNazKW5SKEc9L5IukaZj0qM(qcNunNOLprpNOHNOt4u5CInHFboGEcnuivsaopbCAa4eFfIsk4SH)2Z7NqFobVowBOtG1AFrEIcaI1g9eAitFiHtQMtmXj0qb5eDcNkNtOVmxKsby83EE)e6Zj2oP0teAwAOtG9v0y9jwiaZjc8b2u7eH8jKci8eYn3VbEIjornNayfCobxBorK2jCbYob8Rqu)TN3pH(CcEwB1VtSYIeI70Moso4v5nnqaBDSteAwAOtmXjKSt4cKDIjagQY5eH8jOTSSHSCoHCZ9BobCk0Ccyp410rc93EE)e6Zj4XGZjANgWCwo10rEIq(eRSiH4oTPJKdEvE9jKW5EInjvEIvuNgiGDKNy7BNZODngGZT)eL8yOtWdNOkNt0WtaXDUin6gEfMgkKBGPW49tOVmxKbi4Y5j03keii)U98(j(MrdUY5GdU98Hl5jHJdy7Wb10rsqL8WbSDeoKaHehsYL(qnD4qdfYnWGCWRr22TAkKdE92LPVviqq(X0xMlYaeC50dBh52Z7NGxbtcHxiopX)326e)F7fVCc95e)xDL)69B)TN3pXk7RsUgCLF759tOpNatZaGtWRmi)83EE)e6Zj03bTtiHll7tB(metlqtb84ANOt4yf9eH8jqMR6StUNyLPVoX0o7eYb6e6zZNHobVoqtborrMwh7eAFf083EE)e6Zj03NaopbYiHZzj9e6lZfPuaMtOHm9HeoPAorlFIEordprNWPY5eBc)cCa9eAOqQKaCEc40aWj(keLuWzd)TN3pH(CcEDS2qNaR1(I8efaeRn6j0qM(qcNunNyItOHcYj6eovoNqFzUiLcW4V98(j0NtSDsPNi0S0qNa7ROX6tSqaMte4dSP2jc5tifq4jKBUFd8etCIAobWk4CcU2CIiTt4cKDc4xHO(BpVFc95e8S2QFNyLfje3PnDKCWRYBAGa26yNi0S0qNyItizNWfi7etamuLZjc5tqBzzdz5Cc5M73Cc4uO5eWEWRPJe6V98(j0NtWJbNt0onG5SCQPJ8eH8jwzrcXDAthjh8Q86tiHZ9eBsQ8eROonqa7ipX23oNr7AmaNB)jk5XqNGhorvoNOHNaI7CrA0n83(B)TN3pbVkVze8XONqYKdKDcs4KQ5esg3oH(tSDsiM2aprgP(8viNmo4efz6iHNisaN(BFrMosOxdzKWjvZJmOG)U9fz6iHEnKrcNunl(WHCe0BFrMosOxdzKWjvZIpCu4CDwo10rE7lY0rc9AiJeoPAw8HdiUZfjtZMBFrMosOxdzKWjvZIpC0zAig1Crc3QLFMcy547mneJAUiHElljGrV9fz6iHEnKrcNunl(WHwS2qmyR9f5wT8J(LciCPeUSSFDdOS2Pb9WPi)091TVithj0RHms4KQzXhoGzPb)IHbNAG3(ImDKqVgYiHtQMfF4qlMoYBFrMosOxdzKWjvZIpCqnxKsby2QLFKciKp)ImDKEQ5IukaJNuWHnTZEE72xKPJe61qgjCs1S4dhWVIgRzsby2QLF0VuaH85xKPJ0tnxKsby8KcoSPDMUVD7V98(j4v5nJGpg9eMogIZtmTZoX8zNOitGordprPt1Gscy(BFrMos4t70abSJCRw(PwXgQhZB8MgiGTogtlglNUaElljGrxofWYXtnxKnHrIeI70MosVLLeWOl1qMomUeQ)LhI7CrYOMlYMWgorvo3(ImDKWfF4aQzaadeKF3(ImDKWfF4qlMoYTA5hnB8uZfztydNOkhFrMwhB5M6FkGLJpT5ZqmTanfWBzjbmkF(s4YY(0MpdX0c0uapU2g85pfIRn(PDgBcgTTDR(2TVithjCXhoWHgRhZb3QLF0SXtnxKnHnCIQC8fzADm(8NcX1g)0oJnbJ22UNxVF7lY0rcx8Hdjdbn0Vo5Uvl)OzJNAUiBcB4ev54lY06y85pfIRn(PDgBcgTTDpVE)2xKPJeU4dhsGiOmzCeNB1YpA24PMlYMWgorvo(ImTogF(tH4AJFANXMGrBB3ZR3V9fz6iHl(WHCJmjqe0TA5hnB8uZfztydNOkhFrMwhJp)PqCTXpTZytWOTT75173(ImDKWfF4GuaaRithjd0WzRSC2dLejZ0yHMLgARw(PwXgQhZB8MgiGTogtlglNUaEuL)wofWYXtnxKnHrIeI70MosVLLeWOlN2z7w9TL6NebGgRtpe35IKrnxKnHnCIQC8iZvDcV9fz6iHl(WXxLuwiZ4IdOvUvl)uRyd1J5nEtdeWwhJPfJLtxapQYFlN2z7EFjmWbm4xHO6(FPeUSS34nnqaBDmMwmwoDb80yDUucxw2VUbuw70GE4uKF7wDP(1qMomUeQ)L)RsklKzCXb0kxQFnKPdJlH6)7)QKYczgxCaTYBFrMos4IpCqnxKsby2QLFGboGb)keD3ZQlLWLL9uZfztyKazECTLs4YYEQ5ISjmsGmpCkYVNTD7lY0rcx8HJ2Pbcyh5wT8tTInupM34nnqaBDmMwmwoDb8Ok)Tucxw2VUbuw70GE4uKF6(FPeUSS34nnqaBDmMwmwoDb8iZvDc3vKPJ0d)kASMjfGXB8MrWhJnTZwUP(Ncy54PMlYMWircXDAthP3Yscyu(8jraOX60dXDUizuZfztydNOkhpYCvNqDF9FJBFrMos4IpCqJWTvl)O)Pj)6K7YPDgBcgTnDx9TLqndaytH4Ad03onqa7i39)2xKPJeU4dhsnWGKahX1ysHtYqWTA5NAfBOEmVXBAGa26ymTySC6c4rv(t33woTZ296TLqndaytH4Ad03onqa7i39FPeUSSNISIcNc8ZqqpYCvNWLtbSC8PnFgIPfOPaElljGrV9fz6iHl(Wb1Cr2egCqwYD(2QLF2ucxw2VUbuw70GE4uKF7wj(8LWLL9uZfztyAXAd5X12GpFOMbaSPqCTb6BNgiGDK7(F7lY0rcx8HdsbaSImDKmqdNTYYzpPnFgIPfOPaB1YptbSC8PnFgIPfOPaElljGrxc1maGnfIRnqF70abSJC3Z)BFrMos4IpCqkaGvKPJKbA4Svwo7PDAGa2rUvl)a1maGnfIRnqF70abSJu3x3(ImDKWfF4GlQDrJmMSb4Ixi6wT8djcanwNEiUZfjJAUiBcB4ev54rMR6eU71Q3(ImDKWfF4aI7CrY0PbMCBjDRw(HebGgRtpe35IKrnxKnHnCIQC8iZvDc1DBVXNpjcanwNEiUZfjJAUiBcB4ev54rMR6eU71)BFrMos4IpCqkaGrrwrHtb(zi4wT8ZMKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4oEzPeUSSNAUiBcJuaqNC9iZvDc3Gp)njraOX60dXDUizuZfztydNOkhpYCvNWDVETu)s4YYEQ5ISjmsbaDY1Jmx1jCd(8jraOX60dXDUizuZfztydNOkhpYCvNqDFTTBFrMos4IpCi1adscCexJjfojdbV9fz6iHl(Wbe35IKrnxKnHnCIQC2QLFGboGb)keD3Ql3u)tbSC8uZfztyKiH4oTPJ0BzjbmkF(s4YY(1nGYANg0dNI8t33242xKPJeU4dhAXAdXGT2xKB1Yps4YY(1nGYANg0dNI8t3N)lLWLL9uZfztyKazE4uKF7E(Vucxw2tnxKnHPfRnKNgRZLqndaytH4Ad03onqa7i39)2xKPJeU4dh0iCB1YptbSC80iCElljGrxImzKb)kjGTCANXMGrBt3nPX4Pr48iZvDcxC13242xKPJeU4dhFvszHmJloGw5wT8dmWbm4xHO6(8oF(BcdCad(viQUpRUKebGgRtpPaagfzffof4NHGEK5QoH6UTLBsIaqJ1PhI7CrYOMlYMWgorvoEK5QoH6()n(83KebGgRtpe35IKrnxKnHnCIQC8iZvDc3XLq3()lNcy54PMlYMWircXDAthP3Yscyu(8jraOX60dXDUizuZfztydNOkhpYCvNWDCj0TFBl1)ualhp1Cr2egjsiUtB6i9wwsaJUXgl3u)tbSC8qCNlsMonWKBlPElljGr5ZNebGgRtpe35IKPtdm52sQhzUQtOURUXg3(ImDKWfF4ag4agCq9pBRw(bg4ag8Rq0DVVucxw2tnxKnHrcK5Htr(T75)TVithjCXhoOMlsPamB1YpWahWGFfIU7z1Ls4YYEQ5ISjmsGmpU2Yn3KebGgRtpe35IKrnxKnHnCIQC8iZvDc3Ts85tIaqJ1PhI7CrYOMlYMWgorvoEK5QoH6())g85lHll7PMlYMWibY8WPi)09zv(8LWLL9uZfztyKazEK5QoH7ENp)PDgBcgTTD)FFJBFrMos4IpCqkaGvKPJKbA4Svwo7rcVbuwXGFfIE7V9fz6iHEj8gqzfd(vi6dmWbm4G6F2TVithj0lH3akRyWVcrx8Hd4xrJ1mPam3(BFrMosONsIKzASqZsd98vjLfYmU4aALBb60ye6ZQVD7lY0rc9usKmtJfAwAOfF4ODAGa2rUvl)iHll7x3akRDAqpCkYpD)Vucxw2B8MgiGTogtlglNUaEASoV9fz6iHEkjsMPXcnln0IpCqJWTfOtJrOpR(2TVithj0tjrYmnwOzPHw8HdQ5ISjm4GSK78D7lY0rc9usKmtJfAwAOfF4qQbgKe4iUgtkCsgcE7lY0rc9usKmtJfAwAOfF4aI7CrY0PbMCBj92xKPJe6PKizMgl0S0ql(Wbxu7IgzmzdWfVq0BFrMosONsIKzASqZsdT4dhFvszHmJloGw5wT8dmWbm4xHOpVZNpmWbm4xHOpBBPeUSSNAUiBcJuaqNC9iZvDcV9fz6iHEkjsMPXcnln0IpCqkaGrrwrHtb(zi4wT8JgY0HXLq9V8FvszHmJloGwjF(BQHmDyCju)F)xLuwiZ4IdOvUudz6W4sO(x(2Pbcyh5g3(ImDKqpLejZ0yHMLgAXhoG4oxKmQ5ISjSHtuLZwT8JgY0HXLq9V8KcayuKvu4uGFgcYNpjcanwNEsbamkYkkCkWpdb9iZvDc19TBFrMosONsIKzASqZsdT4dhWahWGdQ)zB1YpBcdCad(vi6Uv5Zhg4ag8Rq0NTTucxw2tnxKnHrcK5Htr(T7z1n4Zxcxw2tnxKnHrcK5PX6CjmWbm4xHO7E)2xKPJe6PKizMgl0S0ql(Wb1CrkfGzRw(bg4ag8Rq0DpRUucxw2tnxKnHrcK5rMR6eE7lY0rc9usKmtJfAwAOfF4GuaaRithjd0WzRSC2JeEdOSIb)ke92F7lY0rc9TtdeWoYN2Pbcyh5wT8ZMs4YY(1nGYANg0dNI8t3NvA5MWahWGFfIUBv(81qMomUeQ)LNuaaJISIcNc8Zqq(8LWLL9RBaL1onOhof5NUp8cF(Aithgxc1)Yl1adscCexJjfojdb5ZFt9RHmDyCju)l)xLuwiZ4IdOvUu)Aithgxc1)3)vjLfYmU4aALBSXs9RHmDyCju)l)xLuwiZ4IdOvUu)Aithgxc1)3)vjLfYmU4aALlLWLL9uZfztyAXAd5PX6Cd(83CANXMGrBB3QlLWLL9RBaL1onOhof5NUVTbF(BQHmDyCju)FpPaagfzffof4NHGlLWLL9RBaL1onOhof5NU)xQ)PawoEQ5ISjmsbaDY1Bzjbm6g3(ImDKqF70abSJCXho4IAx0iJjBaU4fIUvl)qIaqJ1PhI7CrYOMlYMWgorvoEK5QoH7ETkF(63wrWBnnJ6FT6)vxjE52xKPJe6BNgiGDKl(WbPaagfzffof4NHGB1YpBsIaqJ1PhI7CrYOMlYMWgorvoEK5QoH74LLs4YYEQ5ISjmsbaDY1Jmx1jCd(83KebGgRtpe35IKrnxKnHnCIQC8iZvDc3961s9lHll7PMlYMWifa0jxpYCvNWn4ZNebGgRtpe35IKrnxKnHnCIQC8iZvDc1912U9fz6iH(2Pbcyh5IpCaXDUizuZfztydNOkNBFrMosOVDAGa2rU4dhFvszHmJloGw5wT8dmWbm4xHO6(8(TVithj03onqa7ix8HJVkPSqMXfhqRCRw(bg4ag8RquDFwD5MBUPgY0HXLq9)9FvszHmJloGwjF(s4YY(1nGYANg0dNI8t3Nv3yPeUSSFDdOS2Pb9WPi)2XlBWNpjcanwNEiUZfjJAUiBcB4ev54rMR6eU7HlHU9)5Zxcxw2tnxKnHPfRnKhzUQtOUCj0T))g3(ImDKqF70abSJCXhoOMlsPamB1YpAithgxc1)Y)vjLfYmU4aALlHboGb)kev3Nxl3ucxw2VUbuw70GE4uKF7EwLpFnKPdJlH6x1)vjLfYmU4aALBSeg4ag8Rq0DBBPeUSSNAUiBcJeiZJRD7lY0rc9TtdeWoYfF4aI7CrY0PbMCBjDRw(ztseaASo9qCNlsg1Cr2e2WjQYXJmx1ju3T92sOMbaSPqCTb6BNgiGDK7E(VbF(Kia0yD6H4oxKmQ5ISjSHtuLJhzUQt4Ux)V9fz6iH(2Pbcyh5IpCi1adscCexJjfojdb3QLFiraOX60dXDUizuZfztydNOkhpYCvNqD5LBFrMosOVDAGa2rU4dhWahWGdQ)zB1YpWahWGFfIU79Ls4YYEQ5ISjmsGmpCkYVDp)V9fz6iH(2Pbcyh5IpCqnxKsby2QLFGboGb)keD3ZQlLWLL9uZfztyKazECTLBkHll7PMlYMWibY8WPi)09zv(8LWLL9uZfztyKazEK5QoH7E4sOB)7(vWg3(ImDKqF70abSJCXhoOr42IWjbySPqCTb(8AlxXBmcNeGXMcX1g4ZkyRw(bzYid(vsa72xKPJe6BNgiGDKl(WbPaawrMosgOHZwz5Shj8gqzfd(vi6T)2xKPJe6tB(metlqtbEifaWkY0rYanC2klN9K28ziMwGMcWKWBaTtUB1YpKia0yD6tB(metlqtb8iZvDc39)TBFrMosOpT5ZqmTanfyXhoifaWkY0rYanC2klN9K28ziMwGMcWkY06yB1Yps4YY(0MpdX0c0uapU2T)2xKPJe6tB(metlqtbyfzADShPgyqsGJ4AmPWjzi4TVithj0N28ziMwGMcWkY06yl(Wbxu7IgzmzdWfVq0TA5hseaASo9qCNlsg1Cr2e2WjQYXJmx1jC3Rv5Zx)2kcERPzu)Rv)V6kXl3(ImDKqFAZNHyAbAkaRitRJT4dhqCNlsMonWKBlPB1YpKia0yD6H4oxKmQ5ISjSHtuLJhzUQtOUB7n(8jraOX60dXDUizuZfztydNOkhpYCvNWDV(F7lY0rc9PnFgIPfOPaSImTo2IpCqkaGrrwrHtb(zi4wT8ZMKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4oEzPeUSSNAUiBcJuaqNC9iZvDc3Gp)njraOX60dXDUizuZfztydNOkhpYCvNWDVETu)s4YYEQ5ISjmsbaDY1Jmx1jCd(8jraOX60dXDUizuZfztydNOkhpYCvNqDFTTBFrMosOpT5ZqmTanfGvKP1Xw8HdsbaSImDKmqdNTYYzps4nGYkg8Rq0TA5hyGdyWVcrFETCtseaASo9KcayuKvu4uGFgc6rMR6eURithPh(v0yntkaJNuWHnTZ4ZFZPawoEPgyqsGJ4AmPWjziO3Yscy0LKia0yD6LAGbjboIRXKcNKHGEK5QoH7kY0r6HFfnwZKcW4jfCyt7Sn242xKPJe6tB(metlqtbyfzADSfF44RsklKzCXb0k3QLF2CtseaASo9KcayuKvu4uGFgc6rMR6eQBrMosp1CrkfGXtk4WM2zBSCtseaASo9KcayuKvu4uGFgc6rMR6eQBrMosp8ROXAMuagpPGdBANTXgljraOX60N28ziMwGMc4rMR6eQ7MVwP3xSithP)RsklKzCXb0k9KcoSPD2g3(ImDKqFAZNHyAbAkaRitRJT4dhqCNlsg1Cr2e2WjQYzRw(rcxw2N28ziMwGMc4rMR6eU79LWahWGFfI(82TVithj0N28ziMwGMcWkY06yl(Wbe35IKrnxKnHnCIQC2QLFKWLL9PnFgIPfOPaEK5QoH7kY0r6H4oxKmQ5ISjSHtuLJNuWHnTZw8n)73(ImDKqFAZNHyAbAkaRitRJT4dhuZfPuaMTA5hjCzzp1Cr2egjqMhxBjmWbm4xHO7Ew92xKPJe6tB(metlqtbyfzADSfF4GuaaRithjd0WzRSC2JeEdOSIb)ke92F7lY0rc9PnFgIPfOPamj8gq7K7tAZNHyAbAkWwT8dmWbm4xHO6(8(Yn1)ualhVwS2qmyR9fP3Yscyu(8LWLL9uZfztyKazECTnU9fz6iH(0MpdX0c0uaMeEdODYDXhoifaWOiROWPa)me82xKPJe6tB(metlqtbys4nG2j3fF44RsklKzCXb0k3QLFiraOX60tkaGrrwrHtb(ziOhzUQtOUVwHlHboGb)kev3NvV9fz6iH(0MpdX0c0uaMeEdODYDXho0I1gIbBTVi3QLFKWLL9RBaL1onOhof5NUp)xkHll7PMlYMWibY8WPi)298FPeUSSNAUiBctlwBipnwNlHboGb)kev3NvV9fz6iH(0MpdX0c0uaMeEdODYDXho(QKYczgxCaTYTA5hyGdyWVcr1959BFrMosOpT5ZqmTanfGjH3aANCx8HdsbaSImDKmqdNTYYzps4nGYkg8RqufMogc2rQ07)BV4L3())n))vF)Df26cLDYfQW032o3U6TIQhVIR8tCcE(St0oTanNqoqNy7qdzKWjvZ2Xjq2kcEJm6jGHZorHpHRgJEcYxLCnO)2ZRSt7eVVYpH(UeIRPfOXONOith5j2o6mneJAUiHBh(B)TFf1PfOXONyfEIImDKNa0Wb6V9kmqdhOIhfgLejZ0yHMLgsXJsVxkEuywwsaJQwqHvKPJuH9vjLfYmU4aALkmqNgJqvyR(MAu69xXJcZYscyu1ckmcQhd1Lctcxw2VUbuw70GE4uKFNq3t8)elpHeUSS34nnqaBDmMwmwoDb80yDQWkY0rQWANgiGDKQrP3QkEuywwsaJQwqHvKPJuHrJWPWaDAmcvHT6BQrP32u8OWkY0rQWOMlYMWGdYsUZNcZYscyu1cQrP37kEuyfz6ivysnWGKahX1ysHtYqqfMLLeWOQfuJsVvsXJcRithPcdI7CrY0PbMCBjvHzzjbmQAb1O0BfO4rHvKPJuHXf1UOrgt2aCXlevHzzjbmQAb1O0BfQ4rHzzjbmQAbfgb1JH6sHbdCad(vi6jEoX7NGp)tadCad(vi6jEoX2oXYtiHll7PMlYMWifa0jxpYCvNqfwrMosf2xLuwiZ4IdOvQgLE8IIhfMLLeWOQfuyeupgQlfMgY0HXLq9V8FvszHmJloGw5j4Z)eBEcnKPdJlH6)7)QKYczgxCaTYtS8eAithgxc1)Y3onqa7ipXgkSImDKkmsbamkYkkCkWpdbvJsVxVP4rHzzjbmQAbfgb1JH6sHPHmDyCju)lpPaagfzffof4NHGNGp)tqIaqJ1PNuaaJISIcNc8ZqqpYCvNWtO7jEtHvKPJuHbXDUizuZfztydNOkh1O071lfpkmlljGrvlOWiOEmuxkSnpbmWbm4xHONy3jw9e85FcyGdyWVcrpXZj22jwEcjCzzp1Cr2egjqMhof53j29CIvpXgNGp)tiHll7PMlYMWibY80yDEILNag4ag8Rq0tS7eVRWkY0rQWGboGbhu)ZuJsVx)v8OWSSKagvTGcJG6XqDPWGboGb)ke9e7EoXQNy5jKWLL9uZfztyKazEK5QoHkSImDKkmQ5IukaJAu69AvfpkmlljGrvlOWkY0rQWifaWkY0rYanCuyGgoSSCMctcVbuwXGFfIQg1OWANgiGDKkEu69sXJcZYscyu1ckmcQhd1LcBZtiHll7x3akRDAqpCkYVtO7ZjwPtS8eBEcyGdyWVcrpXUtS6j4Z)eAithgxc1)YtkaGrrwrHtb(zi4j4Z)es4YY(1nGYANg0dNI87e6(CcE5e85FcnKPdJlH6F5LAGbjboIRXKcNKHGNGp)tS5j0)j0qMomUeQ)L)RsklKzCXb0kpXYtO)tOHmDyCju)F)xLuwiZ4IdOvEInoXgNy5j0)j0qMomUeQ)L)RsklKzCXb0kpXYtO)tOHmDyCju)F)xLuwiZ4IdOvEILNqcxw2tnxKnHPfRnKNgRZtSXj4Z)eBEIPDgBcgTTtS7eREILNqcxw2VUbuw70GE4uKFNq3t82j24e85FInpHgY0HXLq9)9KcayuKvu4uGFgcEILNqcxw2VUbuw70GE4uKFNq3t8)elpH(pXualhp1Cr2egPaGo56TSKag9eBOWkY0rQWANgiGDKQrP3FfpkmlljGrvlOWiOEmuxkmseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e7oXRvpbF(Nq)NWwrWBnnJ6x3azKrHmyZTbSqMbX1muhige35IStUkSImDKkmUO2fnYyYgGlEHOQrP3QkEuywwsaJQwqHrq9yOUuyBEcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e7obVCILNqcxw2tnxKnHrkaOtUEK5QoHNyJtWN)j28eKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4j2DIxVoXYtO)tiHll7PMlYMWifa0jxpYCvNWtSXj4Z)eKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4j09eV2McRithPcJuaaJISIcNc8Zqq1O0BBkEuyfz6ivyqCNlsg1Cr2e2WjQYrHzzjbmQAb1O07DfpkmlljGrvlOWiOEmuxkmyGdyWVcrpHUpN4DfwrMosf2xLuwiZ4IdOvQgLERKIhfMLLeWOQfuyeupgQlfgmWbm4xHONq3NtS6jwEInpXMNyZtOHmDyCju)F)xLuwiZ4IdOvEc(8pHeUSSFDdOS2Pb9WPi)oHUpNy1tSXjwEcjCzz)6gqzTtd6Htr(DIDNGxoXgNGp)tqIaqJ1PhI7CrYOMlYMWgorvoEK5QoHNy3Zj4sONy7pX)tWN)jKWLL9uZfztyAXAd5rMR6eEcDpbxc9eB)j(FInuyfz6ivyFvszHmJloGwPAu6Tcu8OWSSKagvTGcJG6XqDPW0qMomUeQ)L)RsklKzCXb0kpXYtadCad(vi6j095eVoXYtS5jKWLL9RBaL1onOhof53j29CIvpbF(Nqdz6W4sO(v9FvszHmJloGw5j24elpbmWbm4xHONy3j22jwEcjCzzp1Cr2egjqMhxtHvKPJuHrnxKsbyuJsVvOIhfMLLeWOQfuyeupgQlf2MNGebGgRtpe35IKrnxKnHnCIQC8iZvDcpHUNyBVDILNaQzaaBkexBG(2Pbcyh5j29CI)NyJtWN)jiraOX60dXDUizuZfztydNOkhpYCvNWtS7eV(RWkY0rQWG4oxKmDAGj3wsvJspErXJcZYscyu1ckmcQhd1LcJebGgRtpe35IKrnxKnHnCIQC8iZvDcpHUNGxuyfz6ivysnWGKahX1ysHtYqq1O071BkEuywwsaJQwqHrq9yOUuyWahWGFfIEIDN49tS8es4YYEQ5ISjmsGmpCkYVtS75e)vyfz6ivyWahWGdQ)zQrP3RxkEuywwsaJQwqHrq9yOUuyWahWGFfIEIDpNy1tS8es4YYEQ5ISjmsGmpU2jwEInpHeUSSNAUiBcJeiZdNI87e6(CIvpbF(Nqcxw2tnxKnHrcK5rMR6eEIDpNGlHEIT)eV7xbNydfwrMosfg1CrkfGrnk9E9xXJcZYscyu1ckSImDKkmAeofgHtcWytH4AduP3lfMR4ngHtcWytH4AduHTcuyeupgQlfgYKrg8RKaMAu69AvfpkmlljGrvlOWkY0rQWifaWkY0rYanCuyGgoSSCMctcVbuwXGFfIQg1OWOMCHdgfpk9EP4rHzzjbmQAbfgb1JH6sHvRyd1J5nEtdeWwhJPfJLtxaVLLeWONy5jMcy54PMlYMWircXDAthP3Yscy0tS8eAithgxc1)YdXDUizuZfztydNOkhfwrMosfw70abSJunk9(R4rHvKPJuHb1maGbcYpfMLLeWOQfuJsVvv8OWSSKagvTGcJG6XqDPW0SXtnxKnHnCIQC8fzADStS8eBEc9FIPawo(0MpdX0c0uaVLLeWONGp)tiHll7tB(metlqtb84ANyJtWN)jMcX1g)0oJnbJ22j2DIvFtHvKPJuHPfthPAu6TnfpkmlljGrvlOWiOEmuxkmnB8uZfztydNOkhFrMwh7e85FIPqCTXpTZytWOTDIDpN417kSImDKkmCOX6XCq1O07DfpkmlljGrvlOWiOEmuxkmnB8uZfztydNOkhFrMwh7e85FIPqCTXpTZytWOTDIDpN417kSImDKkmjdbn0Vo5QgLERKIhfMLLeWOQfuyeupgQlfMMnEQ5ISjSHtuLJVitRJDc(8pXuiU24N2zSjy02oXUNt86DfwrMosfMeicktghXPAu6Tcu8OWSSKagvTGcJG6XqDPW0SXtnxKnHnCIQC8fzADStWN)jMcX1g)0oJnbJ22j29CIxVRWkY0rQWKBKjbIGQgLERqfpkmlljGrvlOWiOEmuxkSAfBOEmVXBAGa26ymTySC6c4rv(7elpXualhp1Cr2egjsiUtB6i9wwsaJEILNyANDIDNy13oXYtO)tqIaqJ1PhI7CrYOMlYMWgorvoEK5QoHkSImDKkmsbaSImDKmqdhfgOHdllNPWOKizMgl0S0qQrPhVO4rHzzjbmQAbfgb1JH6sHvRyd1J5nEtdeWwhJPfJLtxapQYFNy5jM2zNy3jE)elpbmWbm4xHONq3t8)elpHeUSS34nnqaBDmMwmwoDb80yDEILNqcxw2VUbuw70GE4uKFNy3jw9elpH(pHgY0HXLq9V8FvszHmJloGw5jwEc9FcnKPdJlH6)7)QKYczgxCaTsfwrMosf2xLuwiZ4IdOvQgLEVEtXJcZYscyu1ckmcQhd1Lcdg4ag8Rq0tS75eREILNqcxw2tnxKnHrcK5X1oXYtiHll7PMlYMWibY8WPi)oXZj2McRithPcJAUiLcWOgLEVEP4rHzzjbmQAbfgb1JH6sHvRyd1J5nEtdeWwhJPfJLtxapQYFNy5jKWLL9RBaL1onOhof53j09e)pXYtiHll7nEtdeWwhJPfJLtxapYCvNWtS7efz6i9WVIgRzsby8gVze8Xyt7StS8eBEc9FIPawoEQ5ISjmsKqCN20r6TSKag9e85FcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e6EIx)pXgkSImDKkS2PbcyhPAu696VIhfMLLeWOQfuyeupgQlfM(pX0KFDY9elpX0oJnbJ22j09eR(2jwEcOMbaSPqCTb6BNgiGDKNy3j(RWkY0rQWOr4uJsVxRQ4rHzzjbmQAbfgb1JH6sHvRyd1J5nEtdeWwhJPfJLtxapQYFNq3t82jwEIPD2j2DIxVDILNaQzaaBkexBG(2Pbcyh5j2DI)Ny5jKWLL9uKvu4uGFgc6rMR6eEILNykGLJpT5ZqmTanfWBzjbmQcRithPctQbgKe4iUgtkCsgcQgLEV2MIhfMLLeWOQfuyeupgQlf2MNqcxw2VUbuw70GE4uKFNy3jwPtWN)jKWLL9uZfztyAXAd5X1oXgNGp)ta1maGnfIRnqF70abSJ8e7oXFfwrMosfg1Cr2egCqwYD(uJsVxVR4rHzzjbmQAbfgb1JH6sHnfWYXN28ziMwGMc4TSKag9elpbuZaa2uiU2a9TtdeWoYtS75e)vyfz6ivyKcayfz6izGgokmqdhwwotHL28ziMwGMcOgLEVwjfpkmlljGrvlOWiOEmuxkmOMbaSPqCTb6BNgiGDKNq3t8sHvKPJuHrkaGvKPJKbA4OWanCyz5mfw70abSJunk9ETcu8OWSSKagvTGcJG6XqDPWiraOX60dXDUizuZfztydNOkhpYCvNWtS7eVwvHvKPJuHXf1UOrgt2aCXlevnk9ETcv8OWSSKagvTGcJG6XqDPWiraOX60dXDUizuZfztydNOkhpYCvNWtO7j22BNGp)tqIaqJ1PhI7CrYOMlYMWgorvoEK5QoHNy3jE9xHvKPJuHbXDUiz60atUTKQgLEV4ffpkmlljGrvlOWiOEmuxkSnpbjcanwNEiUZfjJAUiBcB4ev54rMR6eEIDNGxoXYtiHll7PMlYMWifa0jxpYCvNWtSXj4Z)eBEcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e7oXRxNy5j0)jKWLL9uZfztyKca6KRhzUQt4j24e85FcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e6EIxBtHvKPJuHrkaGrrwrHtb(ziOAu69)nfpkSImDKkmPgyqsGJ4AmPWjziOcZYscyu1cQrP3)xkEuywwsaJQwqHrq9yOUuyWahWGFfIEIDNy1tS8eBEc9FIPawoEQ5ISjmsKqCN20r6TSKag9e85FcjCzz)6gqzTtd6Htr(DcDpXBNydfwrMosfge35IKrnxKnHnCIQCuJsV))v8OWSSKagvTGcJG6XqDPWKWLL9RBaL1onOhof53j095e)pXYtiHll7PMlYMWibY8WPi)oXUNt8)elpHeUSSNAUiBctlwBipnwNNy5jGAgaWMcX1gOVDAGa2rEIDN4VcRithPctlwBigS1(Iunk9(VQIhfMLLeWOQfuyeupgQlf2ualhpncN3Yscy0tS8eitgzWVscyNy5jM2zSjy02oHUNyZtqJXtJW5rMR6eEIfpXQVDInuyfz6ivy0iCQrP3)TP4rHzzjbmQAbfgb1JH6sHbdCad(vi6j095eVFc(8pXMNag4ag8Rq0tO7Zjw9elpbjcanwNEsbamkYkkCkWpdb9iZvDcpHUNyBNy5j28eKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4j09e)F7e85FInpbjcanwNEiUZfjJAUiBcB4ev54rMR6eEIDNGlHEIT)e)pXYtmfWYXtnxKnHrIeI70MosVLLeWONGp)tqIaqJ1PhI7CrYOMlYMWgorvoEK5QoHNy3j4sONy7pX2oXYtO)tmfWYXtnxKnHrIeI70MosVLLeWONyJtSXjwEInpH(pXualhpe35IKPtdm52sQ3Yscy0tWN)jiraOX60dXDUiz60atUTK6rMR6eEcDpXQNyJtSHcRithPc7RsklKzCXb0kvJsV)VR4rHzzjbmQAbfgb1JH6sHbdCad(vi6j2DI3pXYtiHll7PMlYMWibY8WPi)oXUNt8xHvKPJuHbdCadoO(NPgLE)xjfpkmlljGrvlOWiOEmuxkmyGdyWVcrpXUNtS6jwEcjCzzp1Cr2egjqMhx7elpXMNyZtqIaqJ1PhI7CrYOMlYMWgorvoEK5QoHNy3jwPtWN)jiraOX60dXDUizuZfztydNOkhpYCvNWtO7j())eBCc(8pHeUSSNAUiBcJeiZdNI87e6(CIvpbF(Nqcxw2tnxKnHrcK5rMR6eEIDN49tWN)jM2zSjy02oXUt8)9tSHcRithPcJAUiLcWOgLE)xbkEuywwsaJQwqHvKPJuHrkaGvKPJKbA4OWanCyz5mfMeEdOSIb)kevnQrHPHms4KQrXJsVxkEuywwsaJQwqnk9(R4rHzzjbmQAb1O0BvfpkmlljGrvlOgLEBtXJcRithPcdI7CrYKnax8crvywwsaJQwqnk9ExXJcZYscyu1ckmcQhd1LcBkGLJVZ0qmQ5Ie6TSKagvHvKPJuH1zAig1CrcvJsVvsXJcZYscyu1ckmcQhd1Lct)NqkGWtS8es4YY(1nGYANg0dNI87e6EIxkSImDKkmTyTHyWw7ls1O0BfO4rHzzjbmQAb1O0BfQ4rHvKPJuHPfthPcZYscyu1cQrPhVO4rHzzjbmQAbfgb1JH6sHjfq4j4Z)efz6i9uZfPuagpPGdBANDINt8McRithPcJAUiLcWOgLEVEtXJcZYscyu1ckmcQhd1Lct)NqkGWtWN)jkY0r6PMlsPamEsbh20o7e6EI3uyfz6ivyWVIgRzsbyuJAuyPnFgIPfOPakEu69sXJcZYscyu1ckmcQhd1LcJebGgRtFAZNHyAbAkGhzUQt4j2DI)VPWkY0rQWifaWkY0rYanCuyGgoSSCMclT5ZqmTanfGjH3aANCvJsV)kEuywwsaJQwqHrq9yOUuys4YY(0MpdX0c0uapUMcRithPcJuaaRithjd0WrHbA4WYYzkS0MpdX0c0uawrMwhtnQrHL28ziMwGMcWKWBaTtUkEu69sXJcZYscyu1ckmcQhd1Lcdg4ag8Rq0tO7ZjE)elpXMNq)NykGLJxlwBigS1(I0Bzjbm6j4Z)es4YYEQ5ISjmsGmpU2j2qHvKPJuHL28ziMwGMcOgLE)v8OWkY0rQWifaWOiROWPa)meuHzzjbmQAb1O0BvfpkmlljGrvlOWiOEmuxkmseaASo9KcayuKvu4uGFgc6rMR6eEcDpXRv4jwEcyGdyWVcrpHUpNyvfwrMosf2xLuwiZ4IdOvQgLEBtXJcZYscyu1ckmcQhd1Lctcxw2VUbuw70GE4uKFNq3Nt8)elpHeUSSNAUiBcJeiZdNI87e7EoX)tS8es4YYEQ5ISjmTyTH80yDEILNag4ag8Rq0tO7ZjwvHvKPJuHPfRned2AFrQgLEVR4rHzzjbmQAbfgb1JH6sHbdCad(vi6j095eVRWkY0rQW(QKYczgxCaTs1O0BLu8OWSSKagvTGcRithPcJuaaRithjd0WrHbA4WYYzkmj8gqzfd(viQAuJctcVbuwXGFfIQ4rP3lfpkSImDKkmyGdyWb1)mfMLLeWOQfuJsV)kEuyfz6ivyWVIgRzsbyuywwsaJQwqnQrHL28ziMwGMcWkY06ykEu69sXJcRithPctQbgKe4iUgtkCsgcQWSSKagvTGAu69xXJcZYscyu1ckmcQhd1LcJebGgRtpe35IKrnxKnHnCIQC8iZvDcpXUt8A1tWN)j0)jSve8wtZO(1nqgzuid2CBalKzqCnd1bIbXDUi7KRcRithPcJlQDrJmMSb4IxiQAu6TQIhfMLLeWOQfuyeupgQlfgjcanwNEiUZfjJAUiBcB4ev54rMR6eEcDpX2E7e85FcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e7oXR)kSImDKkmiUZfjtNgyYTLu1O0BBkEuywwsaJQwqHrq9yOUuyBEcseaASo9qCNlsg1Cr2e2WjQYXJmx1j8e7obVCILNqcxw2tnxKnHrkaOtUEK5QoHNyJtWN)j28eKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4j2DIxVoXYtO)tiHll7PMlYMWifa0jxpYCvNWtSXj4Z)eKia0yD6H4oxKmQ5ISjSHtuLJhzUQt4j09eV2McRithPcJuaaJISIcNc8Zqq1O07DfpkmlljGrvlOWiOEmuxkmyGdyWVcrpXZjEDILNyZtqIaqJ1PNuaaJISIcNc8ZqqpYCvNWtS7efz6i9WVIgRzsby8KcoSPD2j4Z)eBEIPawoEPgyqsGJ4AmPWjziO3Yscy0tS8eKia0yD6LAGbjboIRXKcNKHGEK5QoHNy3jkY0r6HFfnwZKcW4jfCyt7StSXj2qHvKPJuHrkaGvKPJKbA4OWanCyz5mfMeEdOSIb)kevnk9wjfpkmlljGrvlOWiOEmuxkSnpXMNGebGgRtpPaagfzffof4NHGEK5QoHNq3tuKPJ0tnxKsby8KcoSPD2j24elpXMNGebGgRtpPaagfzffof4NHGEK5QoHNq3tuKPJ0d)kASMjfGXtk4WM2zNyJtSXjwEcseaASo9PnFgIPfOPaEK5QoHNq3tS5jETsVFIfprrMos)xLuwiZ4IdOv6jfCyt7StSHcRithPc7RsklKzCXb0kvJsVvGIhfMLLeWOQfuyeupgQlfMeUSSpT5ZqmTanfWJmx1j8e7oX7Ny5jGboGb)ke9epN4nfwrMosfge35IKrnxKnHnCIQCuJsVvOIhfMLLeWOQfuyeupgQlfMeUSSpT5ZqmTanfWJmx1j8e7orrMospe35IKrnxKnHnCIQC8KcoSPD2jw8eV5FxHvKPJuHbXDUizuZfztydNOkh1O0Jxu8OWSSKagvTGcJG6XqDPWKWLL9uZfztyKazECTtS8eWahWGFfIEIDpNyvfwrMosfg1CrkfGrnk9E9MIhfMLLeWOQfuyfz6ivyKcayfz6izGgokmqdhwwotHjH3akRyWVcrvJAuJcRWNVaPWWA3ktnQrPa]] )

    
end
