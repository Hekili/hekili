-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 265, true )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        -- regen effects.
    }, setmetatable( {
        actual = nil,
        max = 5,
        active_regen = 0,
        inactive_regen = 0,
        forecast = {},
        times = {},
        values = {},
        fcount = 0,
        regen = 0,
        regenerates = false,
    }, {
        __index = function( t, k )
            if k == 'count' or k == 'current' then return t.actual

            elseif k == 'actual' then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        nightfall = 22039, -- 108558
        drain_soul = 23140, -- 198590
        deathbolt = 23141, -- 264106

        writhe_in_agony = 22044, -- 196102
        absolute_corruption = 21180, -- 196103
        siphon_life = 22089, -- 63106

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        sow_the_seeds = 19279, -- 196226
        phantom_singularity = 19292, -- 205179
        vile_taint = 22046, -- 278350

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        demonic_circle = 19288, -- 268358

        shadow_embrace = 23139, -- 32388
        haunt = 23159, -- 48181
        grimoire_of_sacrifice = 19295, -- 108503

        soul_conduit = 19284, -- 215941
        creeping_death = 19281, -- 264000
        dark_soul_misery = 19293, -- 113860
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3498, -- 196029
        adaptation = 3497, -- 214027
        gladiators_medallion = 3496, -- 208683

        soulshatter = 13, -- 212356
        gateway_mastery = 15, -- 248855
        rot_and_decay = 16, -- 212371
        curse_of_shadows = 17, -- 234877
        nether_ward = 18, -- 212295
        essence_drain = 19, -- 221711
        endless_affliction = 12, -- 213400
        curse_of_fragility = 11, -- 199954
        curse_of_weakness = 10, -- 199892
        curse_of_tongues = 9, -- 199890
        casting_circle = 20, -- 221703
    } )

    -- Auras
    spec:RegisterAuras( {
        agony = {
            id = 980,
            duration = function () return 18 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Curse",
            max_stack = function () return ( talent.writhe_in_agony.enabled and 15 or 10 ) end,
        },
        burning_rush = {
            id = 111400,
            duration = 3600,
            max_stack = 1,
        },
        corruption = {
            id = 146739,
            duration = function () return ( talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        dark_pact = {
            id = 108416,
            duration = 20,
            max_stack = 1,
        },
        dark_soul_misery = {
            id = 113860,
            duration = 20,
            max_stack = 1,
        },
        demonic_circle = {
            id = 48018,
            duration = 900,
            max_stack = 1,
        },
        demonic_circle_teleport = {
            id = 48020,
        },
        drain_life = {
            id = 234153,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
        },
        drain_soul = {
            id = 198590,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
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
        grimoire_of_sacrifice = {
            id = 196099,
            duration = 3600,
            max_stack = 1,
        },
        haunt = {
            id = 48181,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        mortal_coil = {
            id = 6789,
            duration = 3.001,
            type = "Magic",
            max_stack = 1,
        },
        nightfall = {
            id = 264571,
            duration = 12,
            max_stack = 1,
        },
        phantom_singularity = {
            id = 205179,
            duration = 16,
            max_stack = 1,
        },
        ritual_of_summoning = {
            id = 698,
        },
        seed_of_corruption = {
            id = 27243,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadow_embrace = {
            id = 32390,
            duration = 10,
            type = "Magic",
            max_stack = 3,
        },
        shadowfury = {
            id = 30283,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        siphon_life = {
            id = 63106,
            duration = function () return 15 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 3 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        soul_leech = {
            id = 108366,
            duration = 15,
            max_stack = 1,
        },
        soul_shards = {
            id = 246985,
        },
        summon_darkglare = {
            id = 205180,
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
        unstable_affliction = {
            id = 233490,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
            copy = "unstable_affliction_1"
        },
        unstable_affliction_2 = {
            id = 233496,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_3 = {
            id = 233497,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_4 = {
            id = 233498,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_5 = {
            id = 233499,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        active_uas = {
            alias = { "unstable_affliction_1", "unstable_affliction_2", "unstable_affliction_3", "unstable_affliction_4", "unstable_affliction_5" },
            aliasMode = 'longest',
            aliasType = 'debuff',
            duration = 8
        },
        vile_taint = {
            id = 278350,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },


        -- PvP Talents
        casting_circle = {
            id = 221705,
            duration = 3600,
            max_stack = 1,
        },
        curse_of_fragility = {
            id = 199954,
            duration = 10,
            max_stack = 1,
        },
        curse_of_shadows = {
            id = 234877,
            duration = 10,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_tongues = {
            id = 199890,
            duration = 10,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_weakness = {
            id = 199892,
            duration = 10,
            type = "Curse",
            max_stack = 1,
        },
        demon_armor = {
            id = 285933,
            duration = 3600,
            max_stack = 1,
        },
        essence_drain = {
            id = 221715,
            duration = 6,
            type = "Magic",
            max_stack = 5,
        },
        nether_ward = {
            id = 212295,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        soulshatter = {
            id = 236471,
            duration = 8,
            max_stack = 5,
        },


        -- Azerite Powers
        inevitable_demise = {
            id = 273525,
            duration = 20,
            max_stack = 50,
        },
    } )


    spec:RegisterHook( "TimeToReady", function( wait, action )
        local ability = action and class.abilities[ action ]
    
        if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
            wait = 3600
        end

        return wait
    end )

    spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )


    state.sqrt = math.sqrt

    spec:RegisterStateExpr( "time_to_shard", function ()
        local num_agony = active_dot.agony
        if num_agony == 0 then return 3600 end

        return 1 / ( 0.16 / sqrt( num_agony ) * ( num_agony == 1 and 1.15 or 1 ) * num_agony / debuff.agony.tick_time )
    end )


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        if sourceGUID == GUID and spellName == "Seed of Corruption" then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        end
    end )


    spec:RegisterGear( 'tier21', 152174, 152177, 152172, 152176, 152173, 152175 )
    spec:RegisterGear( 'tier20', 147183, 147186, 147181, 147185, 147182, 147184 )
    spec:RegisterGear( 'tier19', 138314, 138323, 138373, 138320, 138311, 138317 )
    spec:RegisterGear( 'class', 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )
    
    spec:RegisterGear( 'amanthuls_vision', 154172 )
    spec:RegisterGear( 'hood_of_eternal_disdain', 132394 )
    spec:RegisterGear( 'norgannons_foresight', 132455 )
    spec:RegisterGear( 'pillars_of_the_dark_portal', 132357 )
    spec:RegisterGear( 'power_cord_of_lethtendris', 132457 )
    spec:RegisterGear( 'reap_and_sow', 144364 )
    spec:RegisterGear( 'sacrolashs_dark_strike', 132378 )
    spec:RegisterGear( 'sindorei_spite', 132379 )
    spec:RegisterGear( 'soul_of_the_netherlord', 151649 )
    spec:RegisterGear( 'stretens_sleepless_shackles', 132381 )
    spec:RegisterGear( 'the_master_harvester', 151821 )


    spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
        for i = 1, 5 do
            local aura = "unstable_affliction_" .. i

            if debuff[ aura ].down then
                applyDebuff( 'target', aura, duration or 8 )
                break
            end
        end
    end )


    local summons = {
        [18540] = true,
        [157757] = true,
        [1122] = true,
        [157898] = true
    }

    local last_sindorei_spite = 0

    spec:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
        if not UnitIsUnit( unit, "player" ) then return end

        local now = GetTime()

        if summons[ spellID ] then
            if now - last_sindorei_spite > 25 then
                last_sindorei_spite = now
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        soul_shards.actual = nil
    
        local icd = 25

        if now - last_sindorei_spite < icd then
            cooldown.sindorei_spite_icd.applied = last_sindorei_spite
            cooldown.sindorei_spite_icd.expires = last_sindorei_spite + icd
            cooldown.sindorei_spite_icd.duration = icd
        end

        if debuff.drain_soul.up then            
            local ticks = debuff.drain_soul.ticks_remain
            if pvptalent.rot_and_decay.enabled then
                for i = 1, 5 do
                    if debuff[ "unstable_affliction_" .. i ].up then debuff[ "unstable_affliction_" .. i ].expires = debuff[ "unstable_affliction_" .. i ].expires + ticks end
                end
                if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 1 end
                if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 1 end
            end
            if pvptalent.essence_drain.enabled and health.pct < 100 then
                addStack( "essence_drain", debuff.drain_soul.remains, debuff.essence_drain.stack + ticks )
            end
        end
        
        if buff.casting_circle.up then
            applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
        end
    end )


    spec:RegisterStateExpr( "target_uas", function ()
        return buff.active_uas.stack
    end )

    spec:RegisterStateExpr( "contagion", function ()
        return max( debuff.unstable_affliction.remains, debuff.unstable_affliction_2.remains, debuff.unstable_affliction_3.remains, debuff.unstable_affliction_4.remains, debuff.unstable_affliction_5.remains )
    end )

    
    

    -- Abilities
    spec:RegisterAbilities( {
        sindorei_spite_icd = {
            name = "Sindorei Spite ICD",
            cast = 0,
            cooldown = 25,
            gcd = "off",

            hidden = true,
            usable = function () return false end,
        },

        agony = {
            id = 980,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "agony" )
            end,
        },
        

        --[[ banish = {
            id = 710,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = function () return buff.burning_rush.up and "off" or "spell" end,
            
            startsCombat = true,

            talent = "burning_rush",
            
            handler = function ()
                if buff.burning_rush.down then applyBuff( "burning_rush" )
                else removeBuff( "burning_rush" ) end
            end,
        },
        

        casting_circle = {
            id = 221703,
            cast = 0.5,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            pvptalent = "casting_circle",

            startsCombat = false,
            texture = 1392953,
            
            handler = function ()
                applyBuff( "casting_circle", 8 )
            end,
        },
        

        --[[ command_demon = {
            id = 119898,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        corruption = {
            id = 172,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "corruption" )
            end,
        },
        

        --[[ create_healthstone = {
            id = 6201,
            cast = 3,
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
            cast = 3,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        curse_of_fragility = {
            id = 199954,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_fragility",            
            
            startsCombat = true,
            texture = 132097,
            
            usable = function () return target.is_player end,
            handler = function ()
                applyDebuff( "target", "curse_of_fragility" )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
            end,
        },
        

        curse_of_tongues = {
            id = 199890,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_tongues",
            
            startsCombat = true,
            texture = 136140,
            
            handler = function ()
                applyDebuff( "target", "curse_of_tongues" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
            end,
        },
        

        curse_of_weakness = {
            id = 199892,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_weakness",
            
            startsCombat = true,
            texture = 615101,
            
            handler = function ()
                applyDebuff( "target", "curse_of_weakness" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
            end,
        },
        

        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,

            talent = "dark_pact",
            
            handler = function ()
                spend( 0.2 * health.current, "health" )
                applyBuff( "dark_pact" )
            end,
        },
        

        dark_soul = {
            id = 113860,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,

            talent = "dark_soul_misery",
            
            handler = function ()
                applyBuff( "dark_soul_misery" )
                stat.haste = stat.haste + 0.3
            end,

            copy = "dark_soul_misery"
        },
        

        deathbolt = {
            id = 264106,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "deathbolt",
            
            handler = function ()
                -- applies shadow_embrace (32390)
            end,
        },
        

        demon_armor = {
            id = 285933,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "demon_armor",
            
            startsCombat = false,
            texture = 136185,
            
            handler = function ()
                applyBuff( "demon_armor" )
            end,
        },
        

        --[[ demonic_circle = {
            id = 48018,
            cast = 0.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
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
            
            handler = function ()
            end,
        },
        

        demonic_gateway = {
            id = 111771,
            cast = 2,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        drain_life = {
            id = 234153,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                removeBuff( "inevitable_demise" )
            end,
        },
        

        drain_soul = {
            id = 198590,
            cast = 5,
            cooldown = 0,
            gcd = "spell",

            channeled = true,
            prechannel = true,
            breakable = true,
            breakchannel = function () removeDebuff( "target", "drain_soul" ) end,

            spend = 0,
            spendType = "mana",
            
            startsCombat = true,

            talent = "drain_soul",
           
            handler = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "player_casting", 5 * haste )
                channelSpell( "drain_soul" )
            end,
        },
        

        --[[ enslave_demon = {
            id = 1098,
            cast = 3,
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
            cast = 2,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        fear = {
            id = 5782,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "fear" )
            end,
        },
        

        grimoire_of_sacrifice = {
            id = 108503,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            
            usable = function () return pet.exists and buff.grimoire_of_sacrifice.down end,
            handler = function ()
                applyBuff( "grimoire_of_sacrifice" )
            end,
        },
        

        haunt = {
            id = 48181,
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "haunt",
            
            handler = function ()
                applyDebuff( "target", "haunt" )
            end,
        },
        

        health_funnel = {
            id = 755,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            
            handler = function ()
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

            talent = "mortal_coil",
            
            handler = function ()
                applyDebuff( "target", "mortal_coil" )
                gain( 0.2 * health.max, "health" )
            end,
        },
        

        nether_ward = {
            id = 212295,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "nether_ward",
            
            startsCombat = false,
            texture = 135796,
            
            handler = function ()
                applyBuff( "nether_ward" )
            end,
        },
        

        phantom_singularity = {
            id = 205179,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,

            talent = "phantom_singularity",
            
            handler = function ()
                applyDebuff( "target", "phantom_singularity" )
            end,
        },
        

        --[[ ritual_of_summoning = {
            id = 698,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        seed_of_corruption = {
            id = 27243,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            velocity = 30,
            
            recheck = function ()
                return dot.corruption.remains - ( cast_time + travel_time ), dot.seed_of_corruption.remains
            end,
            usable = function () return dot.seed_of_corruption.down end,
            handler = function ()
                applyDebuff( "target", "seed_of_corruption" )
            end,
        },
        

        shadow_bolt = {
            id = 232670,
            cast = 2,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            velocity = 20,

            notalent = "drain_soul",
            cycle = function () return talent.shadow_embrace.enabled and "shadow_embrace" or nil end,
            
            handler = function ()
                if talent.shadow_embrace.enabled then
                    addStack( "shadow_embrace", 10, 1 )
                end
            end,
        },
        

        shadowfury = {
            id = 30283,
            cast = 1.5,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },
        

        siphon_life = {
            id = 63106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,

            talent = "siphon_life",
            
            handler = function ()
                applyDebuff( "target", "siphon_life" )
            end,
        },
        

        soulshatter = {
            id = 212356,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",
            pvptalent = "soulshatter",

            startsCombat = true,
            texture = 135728,
            
            usable = function () return buff.active_uas.stack > 0 or active_dot.agony > 0 or active_dot.corruption > 0 or active_dot.siphon_life > 0 end,
            handler = function ()
                local targets = min( 5, max( buff.active_uas.stack, active_dot.agony, active_dot.corruption, active_dot.siphon_life ) )

                applyBuff( "soulshatter", nil, targets )
                stat.haste = stat.haste + ( 0.1 * targets )

                gain( targets, "soul_shards" )

                active_dot.agony = max( 0, active_dot.agony - targets )
                if active_dot.agony == 0 then removeDebuff( "target", "agony" ) end

                active_dot.corruption = max( 0, active_dot.corruption - targets )
                if active_dot.corruption == 0 then removeDebuff( "target", "corruption" ) end

                active_dot.siphon_life = max( 0, active_dot.siphon_life - targets )
                if active_dot.siphon_life == 0 then removeDebuff( "target", "siphon_life" ) end
            end,
        },
        

        soulstone = {
            id = 20707,
            cast = 3,
            cooldown = 600,
            gcd = "spell",
            
            startsCombat = false,
            
            handler = function ()
                applyBuff( "soulstone" )
            end,
        },
        

        spell_lock = {
            id = 19647,
            known = function () return IsSpellKnownOrOverridesKnown( 119910 ) or IsSpellKnownOrOverridesKnown( 132409 ) end,
            cast = 0,
            cooldown = 24,
            gcd = "off",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        summon_darkglare = {
            id = 205180,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
                summonPet( "darkglare", 20 )
            end,
        },


        summon_imp = {
            id = 688,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },
        

        summon_voidwalker = {
            id = 697,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "voidwalker" ) end,
        },

        
        summon_felhunter = {
            id = 691,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            essential = true,

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function () summonPet( "felhunter" ) end,

            copy = { "summon_pet", 112869 }
        },
        

        summon_succubus = {
            id = 712,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "succubus" ) end,
        },
        

        unending_breath = {
            id = 5697,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            
            handler = function ()
                applyBuff( "unending_breath" )
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
                applyBuff( "unending_resolve" )
            end,
        },
        

        unstable_affliction = {
            id = 30108,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            
            recheck = function ()
                return dot.unstable_affliction.remains - cast_time, dot.unstable_affliction_2.remains - cast_time, dot.unstable_affliction_3.remains - cast_time, dot.unstable_affliction_4.remains - cast_time, dot.unstable_affliction_5.remains - cast_time
            end,
            handler = function ()
                applyUnstableAffliction()
                if azerite.dreadful_calling.enabled then
                    gainChargeTime( "summon_darkglare", 1 )
                end
            end,
        },
        

        vile_taint = {
            id = 278350,
            cast = 1.5,
            cooldown = 20,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "vile_taint" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20181210.2246, [[du0gHbqiLKEKsf5suQOnHOgfrLtruAvev5vaQzruClkvYUq6xuQAykv6yIILPuLNPuHPruvDnerBdrGVHiOXruvoNsffRJsfyEis3tPSpLGdsPcTqLQ6HuQuyIuQu0fvQOsNuPIkwjLIzQurP2PsOHQurvlLsf0tPKPQK4RuQuAVI8xkgmHdtAXe5XcMmQUm0MfvFwiJgGtRy1kvuYRPuA2Q62iSBP(TKHlulxLNJY0P66aTDLOVRKA8icDEaz9uQunFrP9d6uM0kjlU6yAX92nJ8LzVm7s3Bp5Nei)YFYYbkgtwXAWwnctwTsGjl7yE(pbFQozfRa9LYtRKSyf4fWKfa3Jz2b2BF04aaLOHIWE2qa(Qpvhon3TNneb7L(sYEPC1U44s7JVkFEKz)kdE7LX(v2lJXUvVVc2ASJ55)e8PAkBicjljW59DoDskzXvhtlU3UzKVm7Lzx6E7j)KGDSZKSyXyiT4EKasMSamCo2jPKfhzHK1obf2X88Fc(unuy3Q3xbBH2Stqba3Jz2b2BF04aaLOHIWE2qa(Qpvhon3TNneb7L(sYEPC1U44s7JVkFEKz)o)H2H6Wz2VZBhASB17RGTg7yE(pbFQMYgIa0MDckSBIbKqcpOiZUYaf7TBg5dkSlOyV9SdKFsa0gOn7euy3aG2riZoaAZobf2fuyh5CKdfwX4)qXo7kylfAZobf2fuyhIe1sKdfUErOBMCkLcTzNGc7ckSJ8DwGmhkIvoF6iOyPEJk9iu8v0eOjR4RYNhtw7euyhZZ)j4t1qHDREFfSfAZobfaCpMzhyV9rJdauIgkc7zdb4R(uD40C3E2qeSx6lj7LYv7IJlTp(Q85rM978hAhQdNz)oVDOXUvVVc2ASJ55)e8PAkBicqB2jOWUjgqcj8GIm7kduS3UzKpOWUGI92Zoq(jbqBG2StqHDdaAhHm7aOn7euyxqHDKZrouyfJ)df7SRGTuOn7euyxqHDisulrou46fHUzYPuk0MDckSlOWoY3zbYCOiw58PJGIL6nQ0JqXxrtGcTbAZobf7Cjrma6ihkKW86qOiuesQdfsy00mkuyhdbm2zqrxTDbqpICWhk0GpvZGIQFGOqB0GpvZOXhgkcj13YFLzl0gn4t1mA8HHIqsDG3SpVko0gn4t1mA8HHIqsDG3SxbJiW2vFQgAJg8PAgn(WqriPoWB2ZajiQ2eJo0gn4t1mA8HHIqsDG3Sp6gIAo0u5gMgUjFcOmt(MRp2on6gIAo0u5gMgUjFcifBv6ro0gn4t1mA8HHIqsDG3SN1Amdq5gMRodAJg8PAgn(WqriPoWB2hx(un0gn4t1mA8HHIqsDG3SNHi3u5MqDhySpvlZKVXIX)nUErOZOme5Mk3eQ7aJ9PAJw4cB7aAJg8PAgn(WqriPoWB2dqbBhAJg8PAgn(WqriPoWB2ZaO8ATrQExMjFBvxFSDkafSDk2Q0JCYSy8FJRxe6mkdrUPYnH6oWyFQ2Ofs6oG2aTzNGIDUKigaDKdf4s8ack8HaHchacfAWRdkgguOl15vPhPqB0GpvZ2yX4)MVc2cTrd(und4n7xQ3OspktRe4gidnme5YSuFqCZ1hBNYQ1ghaAyiYzuSvPh5KzX4)gxVi0zugICtLBc1DGX(uTrlCHTDa8Pd3GlX2PtVe8B8uPhPGXzZ66JTtztmGQn)KJuSvPh5KzX4)gxVi0zugICtLBc1DGX(u9cBKe4thUbxITtNEj434PspsbJZMLfJ)BC9IqNrziYnvUju3bg7t1lSjFaF6Wn4sSD60lb)gpv6rkym0MDck0GpvZaEZ(L6nQ0JY0kbUfRC(0rYuXBm0LzP(G4Mg8PAkdGYR1gP6DksIya0rJpeO8u7oEJJ0GYckF6itqFLyCGOyRspYH2StqHg8PAgWB2VuVrLEuMwjWTyLZNosMkE7qg6YSuFqClkWLzY3u7oEJJ0GYckF6itqFLyCGOyRspYjlNRp2oLF60gwb(uSvPh5zZ66JTt5O6aKQ3PyRspYjhQ6516MYr1bivVtpKqNMr6wuGll0gn4t1mG3SFPEJk9OmTsGBXkNpDKmv8gdDzwQpiUjNCQDhVXrAqzbLpDKjOVsmoquSvPh5KLZ1hBNYpDAdRaFk2Q0J8SzD9X2PCuDas17uSvPh5Kdv98ADt5O6aKQ3PhsOtZiDlkWLvwYrbE2SYPbFQMYaO8ATrQENIKigaD04dbkp1UJ34inOSGYNoYe0xjghik2Q0JCzLfAJg8PAgWB2VuVrLEuMwjWncDAxN2WqzwQpiUXIX)nUErOZOme5Mk3eQ7aJ9PAJwiPBza21hBNU(ghaAM2OrvdefBv6roWU(y7uvIvpOJMqDhySpvtXwLEKlV9awoxFSD66BCaOzAJgvnquSvPh5KD9X2PSATXbGggICgfBv6rozwm(VX1lcDgLHi3u5MqDhySpvB0cxypzbwoxFSDkBIbuT5NCKITk9iN8QU(y70WHy80rgoQoak2Q0JCYR66JTt5NoTHvGpfBv6rUSaF6Wn4sSD60lb)gpv6rkym0gn4t1mG3SpO)B0GpvB(H5Y0kbUfQ6516MbTrd(und4n75NoTHvGVmt74DGXUj6lj93YitaGo9wgzcafE046fHoBlJmt(MRxe6uFiqJxg(GKUff4Kzf4Bya0JtkjH2ObFQMb8M9auW2LzY3yX4)gxVi0zugICtLBc1DGX(uTrlK0T9a(0HBWLy70Pxc(nEQ0JuWyOnAWNQzaVzpdKGOAdxpBJE9qzM8nE5unQAGO(eSD6iY8YPH6oWyFQM6tW2PJilNeyEovd(SenGkJYCny7gjZMLvGVHbqp(2UYswUvD9X2PXa02lcdB6iWxVXbIITk9ipB2qvpVw30yaA7fHHnDe4R34arpKqNMjlz5w11hBNYr1bivVtXwLEKNnBOQNxRBkhvhGu9o9qcDAgPBrbE2SRgQ6516MYr1bivVtpKqNMLnllg)346fHoJYqKBQCtOUdm2NQnAHlKb4thUbxITtNEj434PspsbJLfAJg8PAgWB2Zr1bivVlZKVfQ6516MYajiQ2W1Z2OxpKEiHonJmlg)346fHoJYqKBQCtOUdm2NQnAHBza(0HBWLy70Pxc(nEQ0JuWyOnAWNQzaVzVgvnqYeak8OX1lcD2wgzM8Tdj0PzKUff4aRbFQMYaO8ATrQENIKigaD04dbs21lcDQpeOXldFWfKpOnAWNQzaVzpyZCv6rJMN)tWNQLzY3wnuTRrt1KD9IqN6dbA8YWhK0n5dAJg8PAgWB2ZpDAdRaFzcafE046fHoBlJmbTd4BM8nFc2YmhsOttkjLzY3C9X2PmakVwBqcPtdifBv6ro5L6nQ0JucDAxN2WqYCucmpNYaO8ATbjKonG0dj0PzK5OeyEoLbq51AdsiDAaPhsOtZiDlkWL3EqB0GpvZaEZEgaLxRns17Yeak8OX1lcD2wgzM8nxFSDkdGYR1gKq60asXwLEKtEPEJk9iLqN21PnmKmhLaZZPmakVwBqcPtdi9qcDAgzokbMNtzauET2GesNgq6He60ms3qsedGoA8HaL3Ea7NUeFJpei5v1GpvtzauET2ivVtN2K)teahAJg8PAgWB2hdqBVimSPJaF9ghizM8nFiWf2bjjlxOQNxRBkdKGOAdxpBJE9q6He60Sf2KFsMnBOQNxRBkdKGOAdxpBJE9q6He60msLpzj76fHo1hc04LHp4czibYJfJ)BaOmhH2ObFQMb8M9lNhnUoTlZKV5dbUqgss21lcDQpeOXldFWf2YSl0gn4t1mG3ShSzUk9OrZZ)j4t1Ym5BRUuVrLEKcYqddrozwb(gga94BKeAJg8PAgWB2ZqKBQCtOUdm2NQLzY3wQ3OspsbzOHHiNmRaFddGE8nscTrd(und4n7d6)gn4t1MFyUmTsGB8YzqB0GpvZaEZ(yaA7fHHnDe4R34ajZKV5dbs62oij0gn4t1mG3SF58OX1PDzM8nFiqsZqsOnAWNQzaVzpxpBnSc8LzY3cv98ADtzGeevB46zB0RhspKqNMrAMDjZlNgdqBVimSPJaF9ghi6He60SSzD9IqN6dbA8YWhK092f4OapBwwm(VX1lcDgLHi3u5MqDhySpvB0cxidWNoCdUeBNo9sWVXtLEKcgdTrd(und4n7LWJHNTthbTrd(und4n7d6)gn4t1MFyUmTsGBSyS54XG2ObFQMb8M9b9FJg8PAZpmxMwjWT85F8yqBG2ObFQMrdv98ADZ2IlFQwMjFtoxFSDkxpBnSc8neddpGOyRspYjhQ6516MYajiQ2W1Z2OxpKcgtou1ZR1nLRNTgwb(uWyzZMnu1ZR1nLbsquTHRNTrVEifmoBwxVi0P(qGgVm8bjDh7cTrd(unJgQ6516Mb8M9Gm0mosWKzY3wnu1ZR1nLbsquTHRNTrVEifmwMjFlu1ZR1nLbsquTHRNTrVEi9qcDA2cKWDZM1hc04LHpiP7TB2SYjNeyEovd(SenGkJYCny7gjZMLvGVHbqp(2UYswUvD9X2PXa02lcdB6iWxVXbIITk9ipB2qvpVw30yaA7fHHnDe4R34arpKqNMjlz5w11hBNYr1bivVtXwLEKNnBOQNxRBkhvhGu9o9qcDAgPBrbE2SRgQ6516MYr1bivVtpKqNMjl5vdv98ADtzGeevB46zB0RhspKqNMjl0gn4t1mAOQNxRBgWB2Nphk9vXLzY3wnu1ZR1nLbsquTHRNTrVEifmgAJg8PAgnu1ZR1nd4n7L(Q4MCWdizM8Tvdv98ADtzGeevB46zB0RhsbJH2aTrd(unJYLmhMFidWgBIbuT5NCuMFA0e4BziPmt(MC8YPSjgq1MFYr6He60m7KxoLnXaQ28tos5GN6t1Ys6MC8YPAu1arpKqNMzN8YPAu1ar5GN6t1YswoE5u2edOAZp5i9qcDAMDYlNYMyavB(jhPCWt9PAzjDtoE50qDhySpvtpKqNMzN8YPH6oWyFQMYbp1NQLLmVCkBIbuT5NCKEiHonJuE5u2edOAZp5iLdEQpvlVm0DaTrd(unJYLmhMFidaWB2RrvdKm)0OjW3YqszM8n54Lt1OQbIEiHonZo5Lt1OQbIYbp1NQLL0n54Ltd1DGX(un9qcDAMDYlNgQ7aJ9PAkh8uFQwwYYXlNQrvde9qcDAMDYlNQrvdeLdEQpvllPBYXlNYMyavB(jhPhsOtZStE5u2edOAZp5iLdEQpvllzE5unQAGOhsOtZiLxovJQgikh8uFQwEzO7aAJg8PAgLlzom)qgaG3Spu3bg7t1Y8tJMaFldjLzY3KJxonu3bg7t10dj0Pz2jVCAOUdm2NQPCWt9PAzjDtoE5unQAGOhsOtZStE5unQAGOCWt9PAzjlhVCAOUdm2NQPhsOtZStE50qDhySpvt5GN6t1Ys6MC8YPSjgq1MFYr6He60m7KxoLnXaQ28tos5GN6t1YsMxonu3bg7t10dj0PzKYlNgQ7aJ9PAkh8uFQwEzO7aAd0gn4t1mkVC2gdrUPYnH6oWyFQwMjFJxonu3bg7t10dj0PzKUPbFQMYqKBQCtOUdm2NQPbL5gFiqG9HanEzya0JdS8t3tEYLXUC9X2PHdX4PJmCuDauSvPh5YBxAgsklzwm(VX1lcDgLHi3u5MqDhySpvB0cxyBhaF6Wn4sSD60lb)gpv6rkymWU(y70134aqZ0gnQAGOyRspYjVkVCkdrUPYnH6oWyFQMEiHonJ8QAWNQPme5Mk3eQ7aJ9PA60M8FIa4qB0GpvZO8YzaVzVgvnqYeak8OX1lcD2wgzM8nxFSDA4qmE6idhvhafBv6rozn4Zs0WlNQrvdePKaYUErOt9HanEz4dUqMDjl3He60ms3Ic8Szdv98ADtzGeevB46zB0RhspKqNMTqMDjFy(HmaQ0JYcTrd(unJYlNb8M9Au1ajtaOWJgxVi0zBzKzY3w11hBNgoeJNoYWr1bqXwLEKtwd(Sen8YPAu1arQ8r21lcDQpeOXldFWfYSlz5oKqNMr6wuGNnBOQNxRBkdKGOAdxpBJE9q6He60SfYSl5dZpKbqLEuwOnAWNQzuE5mG3SNnXaQ28toktaOWJgxVi0zBzKzY3Ktd(Sen8YPSjgq1MFYrsLp7Y1hBNgoeJNoYWr1bqXwLEKBxSy8FJRxe6mkRwBCaOHHiNz0cLLSRxe6uFiqJxg(GlKzxYhMFidGk9iz5w9qcDAgzwm(VX1lcDgLHi3u5MqDhySpvB0c3YKnBOQNxRBkdKGOAdxpBJE9q6He60Sfyf4Bya0Jlpn4t1uWM5Q0Jgnp)NGpvtrsedGoA8HaLfAJg8PAgLxod4n7d1DGX(uTmbGcpAC9IqNTLrMjFJfJ)BC9IqNrziYnvUju3bg7t1gTqs3bWNoCdUeBNo9sWVXtLEKcgdSRp2oD9noa0mTrJQgik2Q0JCYYDiHonJ0TOapB2qvpVw3ugibr1gUE2g96H0dj0PzlKzxYhMFidGk9OSKD9IqN6dbA8YWhCHm7cTbAJg8PAgnF(hp2gyZCv6rJMN)tWNQL5Ngnb(wgskZKVfQ6516MYr1bivVtpKqNMr6wuGlV9iZIX)nUErOZOme5Mk3eQ7aJ9PAJw4wgGpD4gCj2oD6LGFJNk9ifmMCOQNxRBkdKGOAdxpBJE9q6He60Sf2BxOnAWNQz085F8yaVzFq)3ObFQ28dZLPvcCJlzom)qgazM8nxFSDkhvhGu9ofBv6rozwm(VX1lcDgLHi3u5MqDhySpvB0c3Ya8Pd3GlX2PtVe8B8uPhPGXKLJxovJQgi6He60ms5Lt1OQbIYbp1NQL3UusijZMLxonu3bg7t10dj0PzKYlNgQ7aJ9PAkh8uFQwE7sjHKmBwE5u2edOAZp5i9qcDAgP8YPSjgq1MFYrkh8uFQwE7sjHKuwYHQEETUPCuDas170dj0PzKUPbFQMQrvdenkWLN8tou1ZR1nLbsquTHRNTrVEi9qcDA2c7Tl0gn4t1mA(8pEmG3SpO)B0GpvB(H5Y0kbUXLmhMFidGmt(MRp2oLJQdqQENITk9iNmlg)346fHoJYqKBQCtOUdm2NQnAHBza(0HBWLy70Pxc(nEQ0JuWyYHQEETUPmqcIQnC9Sn61dPhsOtZiDJvGVHbqpU80Gpvt1OQbIgf4aRbFQMQrvdenkWL3oilhVCQgvnq0dj0PzKYlNQrvdeLdEQpvlVmzZYlNgQ7aJ9PA6He60ms5Ltd1DGX(unLdEQpvlVmzZYlNYMyavB(jhPhsOtZiLxoLnXaQ28tos5GN6t1YlJSqB0GpvZO5Z)4XaEZEoQoaP6DzM8TqvpVw3ugibr1gUE2g96H0dj0PzlSTJDbokWZMnu1ZR1nLbsquTHRNTrVEi9qcDA2czK)DH2ObFQMrZN)XJb8M9makVwBKQ3LzY3KaZZPe1sKaBNcgtwcmpN2teapx)NEiHondAJg8PAgnF(hpgWB2RrvdKmt(MeyEoLOwIey7uWyYRkNRp2oLnXaQ28tosXwLEKtwU4dxAIcCAgQgvnqKJpCPjkWP7r1OQbIC8HlnrboDhunQAGKnB24dxAIcCAgQgvnqYcTrd(unJMp)Jhd4n7ztmGQn)KJYm5BsG55uIAjsGTtbJjVQCXhU0ef40mu2edOAZp5i54dxAIcC6Eu2edOAZp5i54dxAIcC6oOSjgq1MFYrzH2ObFQMrZN)XJb8M9H6oWyFQwMjFtcmpNsulrcSDkym5vJpCPjkWPzOH6oWyFQM8QU(y7uvIvpOJMqDhySpvtXwLEKdTrd(unJMp)Jhd4n75NoT5NCuMjFtojW8C604YXvPhnCKyyiL5AW2f2KpsAxYXIX)nUErOZOme5Mk3eQ7aJ9PAJwODD6Wn4sSD60lb)gpv6rky8c7jR82BxYYfQ6516MYr1bivVtpKqNMTasIya0rJpey2SR66JTt5O6aKQ3PyRspYLLSCHQEETUPXa02lcdB6iWxVXbIEiHonBbKeXaOJgFiWSzx11hBNgdqBVimSPJaF9ghik2Q0JCzjlxOQNxRBkxpBnSc8PhsOtZwajrma6OXhcmB2vD9X2PC9S1WkW3qmm8aIITk9ixwYYfQ6516MUCE0460o9qcDA2cijIbqhn(qGzZUQRp2oD58OX1PDk2Q0JCzjhQ6516MYajiQ2W1Z2OxpKEiHonBbKeXaOJgFiqGZSB2SsG550PXLJRspA4iXWqkZ1GTlSJDj76fHo1hc04LHpiPBz2vwOnAWNQz085F8yaVzpafSDOnAWNQz085F8yaVzp)0PnSc8LzAhVdm2nrFjP)wgzca0P3YiZ0oEhySVLrMaqHhnUErOZ2YiZKV56fHo1hc04LHpiPBrbo0gn4t1mA(8pEmG3SNF60gwb(Yeak8OX1lcD2wgzca0P3YiZ0oEhySBM8nFc2YmhsOttkjLzAhVdm2nrFjP)wgzM8nxFSDkdGYR1gKq60asXwLEKtEPEJk9iLqN21PnmK8QCucmpNYaO8ATbjKonG0dj0PzqB0GpvZO5Z)4XaEZE(PtByf4ltaOWJgxVi0zBzKjaqNElJmt74DGXUzY38jylZCiHonPKuMPD8oWy3e9LK(BzKzY3C9X2PmakVwBqcPtdifBv6ro5L6nQ0JucDAxN2WqOnAWNQz085F8yaVzp)0PnSc8LzAhVdm2nrFjP)wgzca0P3YiZ0oEhySVLbAJg8PAgnF(hpgWB2ZaO8ATrQExMaqHhnUErOZ2YiZKV56JTtzauET2GesNgqk2Q0JCYl1BuPhPe60UoTHHKxLJsG55ugaLxRniH0PbKEiHonJ8QAWNQPmakVwBKQ3PtBY)jcGdTrd(unJMp)Jhd4n7zauET2ivVltaOWJgxVi0zBzKzY3C9X2PmakVwBqcPtdifBv6ro5L6nQ0JucDAxN2WqOnAWNQz085F8yaVzpdGYR1gP6DOnqB0GpvZOSyS54X2aBMRspA088Fc(uTmt(wOQNxRBkdKGOAdxpBJE9q6He60ms3yf4Bya0JlpKeXaOJgFiqYYTQRp2oLJQdqQENITk9ipB2qvpVw3uoQoaP6D6He60ms3yf4Bya0JlpKeXaOJgFiqzH2ObFQMrzXyZXJb8M9b9FJg8PAZpmxMwjWT85F8yYm5BYfQ6516MYajiQ2W1Z2OxpKEiHonJuFiqJxgga94YtosGDXkW3WaOhx2Szdv98ADtzGeevB46zB0RhsbJLLSpeOXldFWfcv98ADtzGeevB46zB0RhspKqNMbTrd(unJYIXMJhd4n7ziYnvUju3bg7t1Ym5Bl1BuPhPGm0WqKdTrd(unJYIXMJhd4n7bBMRspA088Fc(uTmt(2Ql1BuPhPGm0WqKtE14dxAIcCAgkdKGOAdxpBJE9qYY56JTt5O6aKQ3PyRspYjhQ6516MYr1bivVtpKqNMr6gsIya0rJpei5vv7oEJJ0GYckF6itqFLyCGOyRspYZMvowb(gga94lSrsYSy8FJRxe6mkdrUPYnH6oWyFQ2Ofs6EzZYkW3WaOhFHT9iZIX)nUErOZOme5Mk3eQ7aJ9PAJw4cB7jlzxVi0P(qGgVm8bxq(bgjrma6OXhcKmlg)346fHoJYqKBQCtOUdm2NQnAHBzYM11lcDQpeOXldFqs3KpGrsedGoA8HaLhRaFddGECzH2ObFQMrzXyZXJb8M9GnZvPhnAE(pbFQwMjFB1L6nQ0JuqgAyiYjhQ21OPAs3ckZn(qGaVuVrLEKgRC(0rqB0GpvZOSyS54XaEZEWM5Q0Jgnp)NGpvltaOWJgxVi0zBzKzY3wDPEJk9ifKHggICYYTQRp2oLJQdqQENITk9ipB2qvpVw3uoQoaP6D6He60Sf8HanEzya0JNnlRaFddGE8fYilz5w11hBNUCE0460ofBv6rE2SSc8nma6XxiJSKdv7A0unPBbL5gFiqGxQ3OspsJvoF6iYYTQA3XBCKguwq5thzc6ReJdefBv6rE2SsG550GYckF6itqFLyCGOhsOtZwWhc04LHbqpUSjRL4XMQtlU3UzKVmz2v(O7U7U7LSwRxpDelzTZHiUoh5qbjek0Gpvdf)WCgfAtY6hMZsRKS4sMdZpKbiTsAXmPvswyRspYt7NS0GpvNSytmGQn)KJjRWnoEJMSKdk4LtztmGQn)KJ0dj0PzqHDcf8YPSjgq1MFYrkh8uFQgkKfkiDdkKdk4Lt1OQbIEiHondkStOGxovJQgikh8uFQgkKfkidfYbf8YPSjgq1MFYr6He60mOWoHcE5u2edOAZp5iLdEQpvdfYcfKUbfYbf8YPH6oWyFQMEiHondkStOGxonu3bg7t1uo4P(unuiluqgk4LtztmGQn)KJ0dj0PzqbPqbVCkBIbuT5NCKYbp1NQHc5bfzO7iz9tJMapzLHKjpT4EPvswyRspYt7NS0GpvNS0OQbkzfUXXB0KLCqbVCQgvnq0dj0PzqHDcf8YPAu1ar5GN6t1qHSqbPBqHCqbVCAOUdm2NQPhsOtZGc7ek4Ltd1DGX(unLdEQpvdfYcfKHc5GcE5unQAGOhsOtZGc7ek4Lt1OQbIYbp1NQHczHcs3Gc5GcE5u2edOAZp5i9qcDAguyNqbVCkBIbuT5NCKYbp1NQHczHcYqbVCQgvnq0dj0PzqbPqbVCQgvnquo4P(unuipOidDhjRFA0e4jRmKm5Pf3rALKf2Q0J80(jln4t1jRqDhySpvNSc344nAYsoOGxonu3bg7t10dj0PzqHDcf8YPH6oWyFQMYbp1NQHczHcs3Gc5GcE5unQAGOhsOtZGc7ek4Lt1OQbIYbp1NQHczHcYqHCqbVCAOUdm2NQPhsOtZGc7ek4Ltd1DGX(unLdEQpvdfYcfKUbfYbf8YPSjgq1MFYr6He60mOWoHcE5u2edOAZp5iLdEQpvdfYcfKHcE50qDhySpvtpKqNMbfKcf8YPH6oWyFQMYbp1NQHc5bfzO7iz9tJMapzLHKjp5jloMRGVNwjTyM0kjln4t1jlwm(V5RGTjlSvPh5P9tEAX9sRKSWwLEKN2pzTuFqmz56JTtz1AJdanme5mk2Q0JCOGmuWIX)nUErOZOme5Mk3eQ7aJ9PAJwiuSWguSdOayO40HBWLy70Pxc(nEQ0JuWyOiBwOW1hBNYMyavB(jhPyRspYHcYqblg)346fHoJYqKBQCtOUdm2NQHIf2GcscfadfNoCdUeBNo9sWVXtLEKcgdfzZcfSy8FJRxe6mkdrUPYnH6oWyFQgkwydkKpOayO40HBWLy70Pxc(nEQ0JuW4KLg8P6K1s9gv6XK1s9mTsGjlqgAyiYtEAXDKwjzHTk9ipTFYQItwm0twAWNQtwl1BuPhtwl1hetwYbfYbfQDhVXrAqzbLpDKjOVsmoquSvPh5qbzOqoOW1hBNYpDAdRaFk2Q0JCOiBwOW1hBNYr1bivVtXwLEKdfKHIqvpVw3uoQoaP6D6He60mOG0nOikWHczHczHcYqruGdfzZcfYbfAWNQPmakVwBKQ3PijIbqhn(qGqH8Gc1UJ34inOSGYNoYe0xjghik2Q0JCOqwOq2K1s9mTsGjRyLZNok5PfL)0kjlSvPh5P9twl1hetwSy8FJRxe6mkdrUPYnH6oWyFQ2OfcfKUbfzGcGHcxFSD66BCaOzAJgvnquSvPh5qbWqHRp2ovLy1d6Oju3bg7t1uSvPh5qH8GI9GcGHc5GcxFSD66BCaOzAJgvnquSvPh5qbzOW1hBNYQ1ghaAyiYzuSvPh5qbzOGfJ)BC9IqNrziYnvUju3bg7t1gTqOybOypOqwOayOqoOW1hBNYMyavB(jhPyRspYHcYqXQqHRp2onCigpDKHJQdGITk9ihkidfRcfU(y7u(PtByf4tXwLEKdfYcfadfNoCdUeBNo9sWVXtLEKcgNS0GpvNSwQ3OspMSwQNPvcmzrOt760ggM80IKmTsYcBv6rEA)KLg8P6Kvq)3ObFQ28dZtw)WCtReyYku1ZR1nl5PfjbPvswyRspYt7NS0GpvNS4NoTHvGFYkau4rJRxe6S0IzswHBC8gnz56fHo1hc04LHpiuq6guef4qbzOGvGVHbqpouqkuqYKvaGoDYktYAAhVdm2nrFjPFYktYtlsctRKSWwLEKN2pzfUXXB0Kflg)346fHoJYqKBQCtOUdm2NQnAHqbPBqXEqbWqXPd3GlX2PtVe8B8uPhPGXjln4t1jlaky7jpTO8LwjzHTk9ipTFYkCJJ3OjlE5unQAGO(eSD6iOGmuWlNgQ7aJ9PAQpbBNockidfYbfsG55un4Zs0aQmkZ1GTqXguqsOiBwOGvGVHbqpouSbf7cfYcfKHc5GIvHcxFSDAmaT9IWWMoc81BCGOyRspYHISzHIqvpVw30yaA7fHHnDe4R34arpKqNMbfYcfKHc5GIvHcxFSDkhvhGu9ofBv6rouKnlueQ6516MYr1bivVtpKqNMbfKUbfrbouKnluSkueQ6516MYr1bivVtpKqNMbfzZcfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcflafzGcGHIthUbxITtNEj434PspsbJHcztwAWNQtwmqcIQnC9Sn61dtEAXDM0kjlSvPh5P9twHBC8gnzfQ6516MYajiQ2W1Z2OxpKEiHondkidfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcfBqrgOayO40HBWLy70Pxc(nEQ0JuW4KLg8P6KfhvhGu9EYtlMz30kjlSvPh5P9twAWNQtwAu1aLSc344nAY6qcDAguq6guef4qbWqHg8PAkdGYR1gP6DksIya0rJpeiuqgkC9IqN6dbA8YWhekwakKVKvaOWJgxVi0zPfZK80IzYKwjzHTk9ipTFYkCJJ3OjRvHIq1UgnvdfKHcxVi0P(qGgVm8bHcs3Gc5lzPbFQozb2mxLE0O55)e8P6KNwmZEPvswyRspYt7NS0GpvNS4NoTHvGFYkau4rJRxe6S0IzswbTd4BM8KLpbBzMdj0PjLKjRWnoEJMSC9X2PmakVwBqcPtdifBv6rouqgkwQ3Ospsj0PDDAddHcYqbhLaZZPmakVwBqcPtdi9qcDAguqgk4OeyEoLbq51AdsiDAaPhsOtZGcs3GIOahkKhuSxYtlMzhPvswyRspYt7NS0GpvNSyauET2ivVNSc344nAYY1hBNYaO8ATbjKonGuSvPh5qbzOyPEJk9iLqN21PnmekidfCucmpNYaO8ATbjKonG0dj0PzqbzOGJsG55ugaLxRniH0PbKEiHondkiDdkqsedGoA8HaHc5bf7bfadf(PlX34dbcfKHIvHcn4t1ugaLxRns170Pn5)ebWtwbGcpAC9IqNLwmtYtlMr(tRKSWwLEKN2pzfUXXB0KLpeiuSauSdscfKHc5GIqvpVw3ugibr1gUE2g96H0dj0PzqXcBqH8tsOiBwOiu1ZR1nLbsquTHRNTrVEi9qcDAguqkuiFqHSqbzOW1lcDQpeOXldFqOybOidjakKhuWIX)nauMJjln4t1jRyaA7fHHnDe4R34aL80IzizALKf2Q0J80(jRWnoEJMS8HaHIfGImKekidfUErOt9HanEz4dcflSbfz2nzPbFQozTCE0460EYtlMHeKwjzHTk9ipTFYkCJJ3OjRvHIL6nQ0JuqgAyiYHcYqbRaFddGECOydkizYsd(uDYcSzUk9OrZZ)j4t1jpTygsyALKf2Q0J80(jRWnoEJMSwQ3OspsbzOHHihkidfSc8nma6XHInOGKjln4t1jlgICtLBc1DGX(uDYtlMr(sRKSWwLEKN2pzPbFQozf0)nAWNQn)W8K1pm30kbMS4LZsEAXm7mPvswyRspYt7NSc344nAYYhcekiDdk2bjtwAWNQtwXa02lcdB6iWxVXbk5Pf3B30kjlSvPh5P9twHBC8gnz5dbcfKcfzizYsd(uDYA58OX1P9KNwCVmPvswyRspYt7NSc344nAYku1ZR1nLbsquTHRNTrVEi9qcDAguqkuKzxOGmuWlNgdqBVimSPJaF9ghi6He60mOiBwOW1lcDQpeOXldFqOGuOyVDHcGHIOahkYMfkyX4)gxVi0zugICtLBc1DGX(uTrlekwakYafadfNoCdUeBNo9sWVXtLEKcgNS0GpvNS46zRHvGFYtlU3EPvswAWNQtws4XWZ2PJswyRspYt7N80I7TJ0kjlSvPh5P9twAWNQtwb9FJg8PAZpmpz9dZnTsGjlwm2C8yjpT4EYFALKf2Q0J80(jln4t1jRG(Vrd(uT5hMNS(H5MwjWKv(8pESKN8Kv8HHIqs90kPfZKwjzHTk9ipTFYtlUxALKf2Q0J80(jpT4osRKSWwLEKN2p5PfL)0kjln4t1jlgibr1MC8ba2oEjlSvPh5P9tEArsMwjzHTk9ipTFYkCJJ3OjlxFSDA0ne1COPYnmnCt(eqk2Q0J8KLg8P6Kv0ne1COPYnmnCt(eWKNwKeKwjzHTk9ipTFYtlsctRKS0GpvNSIlFQozHTk9ipTFYtlkFPvswyRspYt7NSc344nAYIfJ)BC9IqNrziYnvUju3bg7t1gTqOyHnOyhjln4t1jlgICtLBc1DGX(uDYtlUZKwjzPbFQozbqbBpzHTk9ipTFYtlMz30kjlSvPh5P9twHBC8gnzTku46JTtbOGTtXwLEKdfKHcwm(VX1lcDgLHi3u5MqDhySpvB0cHcsHIDKS0GpvNSyauET2ivVN8KNScv98ADZsRKwmtALKf2Q0J80(jRWnoEJMSKdkC9X2PC9S1WkW3qmm8aIITk9ihkidfHQEETUPmqcIQnC9Sn61dPGXqbzOiu1ZR1nLRNTgwb(uWyOqwOiBwOiu1ZR1nLbsquTHRNTrVEifmgkYMfkC9IqN6dbA8YWhekifk2XUjln4t1jR4YNQtEAX9sRKSWwLEKN2pzfUXXB0KvOQNxRBkdKGOAdxpBJE9q6He60mOybOGeUluKnlu4dbA8YWhekifk2BxOiBwOqoOqoOqcmpNQbFwIgqLrzUgSfk2GcscfzZcfSc8nma6XHInOyxOqwOGmuihuSku46JTtJbOTxeg20rGVEJdefBv6rouKnlueQ6516MgdqBVimSPJaF9ghi6He60mOqwOGmuihuSku46JTt5O6aKQ3PyRspYHISzHIqvpVw3uoQoaP6D6He60mOG0nOikWHISzHIvHIqvpVw3uoQoaP6D6He60mOqwOGmuSkueQ6516MYajiQ2W1Z2OxpKEiHondkKnzPbFQozbYqZ4ibl5Pf3rALKf2Q0J80(jRWnoEJMSwfkcv98ADtzGeevB46zB0RhsbJtwAWNQtw5ZHsFv8KNwu(tRKSWwLEKN2pzfUXXB0K1QqrOQNxRBkdKGOAdxpBJE9qkyCYsd(uDYs6RIBYbpGsEYtwSyS54XsRKwmtALKf2Q0J80(jRWnoEJMScv98ADtzGeevB46zB0RhspKqNMbfKUbfSc8nma6XHc5bfijIbqhn(qGqbzOqoOyvOW1hBNYr1bivVtXwLEKdfzZcfHQEETUPCuDas170dj0PzqbPBqbRaFddGECOqEqbsIya0rJpeiuiBYsd(uDYcSzUk9OrZZ)j4t1jpT4EPvswyRspYt7NSc344nAYsoOiu1ZR1nLbsquTHRNTrVEi9qcDAguqku4dbA8YWaOhhkKhuihuqcGc7ckyf4Bya0JdfYcfzZcfHQEETUPmqcIQnC9Sn61dPGXqHSqbzOWhc04LHpiuSaueQ6516MYajiQ2W1Z2OxpKEiHonlzPbFQozf0)nAWNQn)W8K1pm30kbMSYN)XJL80I7iTsYcBv6rEA)Kv4ghVrtwl1BuPhPGm0WqKNS0GpvNSyiYnvUju3bg7t1jpTO8NwjzHTk9ipTFYkCJJ3OjRvHIL6nQ0JuqgAyiYHcYqXQqr8HlnrbondLbsquTHRNTrVEiuqgkKdkC9X2PCuDas17uSvPh5qbzOiu1ZR1nLJQdqQENEiHondkiDdkqsedGoA8HaHcYqXQqHA3XBCKguwq5thzc6ReJdefBv6rouKnluihuWkW3WaOhhkwydkijuqgkyX4)gxVi0zugICtLBc1DGX(uTrlekifk2dkYMfkyf4Bya0JdflSbf7bfKHcwm(VX1lcDgLHi3u5MqDhySpvB0cHIf2GI9GczHcYqHRxe6uFiqJxg(GqXcqH8dfadfijIbqhn(qGqbzOGfJ)BC9IqNrziYnvUju3bg7t1gTqOydkYafzZcfUErOt9HanEz4dcfKUbfYhuamuGKigaD04dbcfYdkyf4Bya0JdfYMS0GpvNSaBMRspA088Fc(uDYtlsY0kjlSvPh5P9twHBC8gnzTkuSuVrLEKcYqddrouqgkcv7A0unuq6gueuMB8HaHcGHIL6nQ0J0yLZNokzPbFQozb2mxLE0O55)e8P6KNwKeKwjzHTk9ipTFYsd(uDYcSzUk9OrZZ)j4t1jRWnoEJMSwfkwQ3OspsbzOHHihkidfYbfRcfU(y7uoQoaP6Dk2Q0JCOiBwOiu1ZR1nLJQdqQENEiHondkwak8HanEzya0JdfzZcfSc8nma6XHIfGImqHSqbzOqoOyvOW1hBNUCE0460ofBv6rouKnluWkW3WaOhhkwakYafYcfKHIq1UgnvdfKUbfbL5gFiqOayOyPEJk9inw58PJGcYqHCqXQqHA3XBCKguwq5thzc6ReJdefBv6rouKnluibMNtdklO8PJmb9vIXbIEiHondkwak8HanEzya0JdfYMScafE046fHolTyMKN8Kv(8pES0kPfZKwjzHTk9ipTFYsd(uDYcSzUk9OrZZ)j4t1jRWnoEJMScv98ADt5O6aKQ3PhsOtZGcs3GIOahkKhuShuqgkyX4)gxVi0zugICtLBc1DGX(uTrlek2GImqbWqXPd3GlX2PtVe8B8uPhPGXqbzOiu1ZR1nLbsquTHRNTrVEi9qcDAguSauS3UjRFA0e4jRmKm5Pf3lTsYcBv6rEA)Kv4ghVrtwU(y7uoQoaP6Dk2Q0JCOGmuWIX)nUErOZOme5Mk3eQ7aJ9PAJwiuSbfzGcGHIthUbxITtNEj434PspsbJHcYqHCqbVCQgvnq0dj0PzqbPqbVCQgvnquo4P(unuipOyxkjKKqr2SqbVCAOUdm2NQPhsOtZGcsHcE50qDhySpvt5GN6t1qH8GIDPKqscfzZcf8YPSjgq1MFYr6He60mOGuOGxoLnXaQ28tos5GN6t1qH8GIDPKqscfYcfKHIqvpVw3uoQoaP6D6He60mOG0nOqd(unvJQgiAuGdfYdkKFOGmueQ6516MYajiQ2W1Z2OxpKEiHondkwak2B3KLg8P6Kvq)3ObFQ28dZtw)WCtReyYIlzom)qgGKNwChPvswyRspYt7NSc344nAYY1hBNYr1bivVtXwLEKdfKHcwm(VX1lcDgLHi3u5MqDhySpvB0cHInOiduamuC6Wn4sSD60lb)gpv6rkymuqgkcv98ADtzGeevB46zB0RhspKqNMbfKUbfSc8nma6XHc5bfAWNQPAu1arJcCOayOqd(unvJQgiAuGdfYdk2buqgkKdk4Lt1OQbIEiHondkifk4Lt1OQbIYbp1NQHc5bfzGISzHcE50qDhySpvtpKqNMbfKcf8YPH6oWyFQMYbp1NQHc5bfzGISzHcE5u2edOAZp5i9qcDAguqkuWlNYMyavB(jhPCWt9PAOqEqrgOq2KLg8P6Kvq)3ObFQ28dZtw)WCtReyYIlzom)qgGKNwu(tRKSWwLEKN2pzfUXXB0KvOQNxRBkdKGOAdxpBJE9q6He60mOyHnOyh7cfadfrbouKnlueQ6516MYajiQ2W1Z2OxpKEiHondkwakYi)7MS0GpvNS4O6aKQ3tEArsMwjzHTk9ipTFYkCJJ3OjljW8CkrTejW2PGXqbzOqcmpN2teapx)NEiHonlzPbFQozXaO8ATrQEp5PfjbPvswyRspYt7NSc344nAYscmpNsulrcSDkymuqgkwfkKdkC9X2PSjgq1MFYrk2Q0JCOGmuihueF4stuGtZq1OQbckidfXhU0ef409OAu1abfKHI4dxAIcC6oOAu1abfYcfzZcfXhU0ef40munQAGGcztwAWNQtwAu1aL80IKW0kjlSvPh5P9twHBC8gnzjbMNtjQLib2ofmgkidfRcfYbfXhU0ef40mu2edOAZp5iuqgkIpCPjkWP7rztmGQn)KJqbzOi(WLMOaNUdkBIbuT5NCekKnzPbFQozXMyavB(jhtEAr5lTsYcBv6rEA)Kv4ghVrtwsG55uIAjsGTtbJHcYqXQqr8Hlnrbondnu3bg7t1qbzOyvOW1hBNQsS6bD0eQ7aJ9PAk2Q0J8KLg8P6KvOUdm2NQtEAXDM0kjlSvPh5P9twHBC8gnzjhuibMNtNgxoUk9OHJeddPmxd2cflSbfYhjHc7ckKdkyX4)gxVi0zugICtLBc1DGX(uTrlekSlO40HBWLy70Pxc(nEQ0JuWyOybOypOqwOqEqXE7cfKHc5GIqvpVw3uoQoaP6D6He60mOybOajrma6OXhcekYMfkwfkC9X2PCuDas17uSvPh5qHSqbzOqoOiu1ZR1nngG2Eryythb(6noq0dj0PzqXcqbsIya0rJpeiuKnluSku46JTtJbOTxeg20rGVEJdefBv6rouiluqgkKdkcv98ADt56zRHvGp9qcDAguSauGKigaD04dbcfzZcfRcfU(y7uUE2Ayf4BiggEarXwLEKdfYcfKHc5GIqvpVw30LZJgxN2PhsOtZGIfGcKeXaOJgFiqOiBwOyvOW1hBNUCE0460ofBv6rouiluqgkcv98ADtzGeevB46zB0RhspKqNMbflafijIbqhn(qGqbWqrMDHISzHcjW8C604YXvPhnCKyyiL5AWwOybOyh7cfKHcxVi0P(qGgVm8bHcs3GIm7cfYMS0GpvNS4NoT5NCm5PfZSBALKLg8P6KfafS9Kf2Q0J80(jpTyMmPvswyRspYt7NS0GpvNS4NoTHvGFYkau4rJRxe6S0Izswt74DGXEYktYkCJJ3OjlxVi0P(qGgVm8bHcs3GIOapzfaOtNSYKSM2X7aJDt0xs6NSYK80Iz2lTsYcBv6rEA)KLg8P6Kf)0PnSc8twbGcpAC9IqNLwmtYAAhVdm2ntEYYNGTmZHe60KsYKv4ghVrtwU(y7ugaLxRniH0PbKITk9ihkidfl1BuPhPe60UoTHHqbzOyvOGJsG55ugaLxRniH0PbKEiHonlzfaOtNSYKSM2X7aJDt0xs6NSYK80Iz2rALKf2Q0J80(jln4t1jl(PtByf4NScafE046fHolTyMK10oEhySBM8KLpbBzMdj0PjLKjRWnoEJMSC9X2PmakVwBqcPtdifBv6rouqgkwQ3Ospsj0PDDAddtwba60jRmjRPD8oWy3e9LK(jRmjpTyg5pTsYcBv6rEA)KLg8P6Kf)0PnSc8twt74DGXEYktYkaqNozLjznTJ3bg7MOVK0pzLj5PfZqY0kjlSvPh5P9twAWNQtwmakVwBKQ3twHBC8gnz56JTtzauET2GesNgqk2Q0JCOGmuSuVrLEKsOt760ggcfKHIvHcokbMNtzauET2GesNgq6He60mOGmuSkuObFQMYaO8ATrQENoTj)NiaEYkau4rJRxe6S0IzsEAXmKG0kjlSvPh5P9twAWNQtwmakVwBKQ3twHBC8gnz56JTtzauET2GesNgqk2Q0JCOGmuSuVrLEKsOt760ggMScafE046fHolTyMKNwmdjmTsYsd(uDYIbq51AJu9EYcBv6rEA)KN8KfVCwAL0IzsRKSWwLEKN2pzfUXXB0KfVCAOUdm2NQPhsOtZGcs3Gcn4t1ugICtLBc1DGX(unnOm34dbcfadf(qGgVmma6XHcGHc5NUhuipOqoOiduyxqHRp2onCigpDKHJQdGITk9ihkKhuSlndjHczHcYqblg)346fHoJYqKBQCtOUdm2NQnAHqXcBqXoGcGHIthUbxITtNEj434PspsbJHcGHcxFSD66BCaOzAJgvnquSvPh5qbzOyvOGxoLHi3u5MqDhySpvtpKqNMbfKHIvHcn4t1ugICtLBc1DGX(unDAt(pra8KLg8P6KfdrUPYnH6oWyFQo5Pf3lTsYcBv6rEA)KLg8P6KLgvnqjRWnoEJMSC9X2PHdX4PJmCuDauSvPh5qbzOqd(Sen8YPAu1abfKcfKaOGmu46fHo1hc04LHpiuSauKzxOGmuihuCiHondkiDdkIcCOiBwOiu1ZR1nLbsquTHRNTrVEi9qcDAguSauKzxOGmuCy(HmaQ0JqHSjRaqHhnUErOZslMj5Pf3rALKf2Q0J80(jln4t1jlnQAGswHBC8gnzTku46JTtdhIXthz4O6aOyRspYHcYqHg8zjA4Lt1OQbckifkKpOGmu46fHo1hc04LHpiuSauKzxOGmuihuCiHondkiDdkIcCOiBwOiu1ZR1nLbsquTHRNTrVEi9qcDAguSauKzxOGmuCy(HmaQ0JqHSjRaqHhnUErOZslMj5PfL)0kjlSvPh5P9twAWNQtwSjgq1MFYXKv4ghVrtwYbfAWNLOHxoLnXaQ28tocfKcfYhuyxqHRp2onCigpDKHJQdGITk9ihkSlOGfJ)BC9IqNrz1AJdanme5mJwiuiluqgkC9IqN6dbA8YWhekwakYSluqgkom)qgav6rOGmuihuSkuCiHondkidfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcfBqrgOiBwOiu1ZR1nLbsquTHRNTrVEi9qcDAguSauWkW3WaOhhkKhuObFQMc2mxLE0O55)e8PAksIya0rJpeiuiBYkau4rJRxe6S0IzsEArsMwjzHTk9ipTFYsd(uDYku3bg7t1jRWnoEJMSyX4)gxVi0zugICtLBc1DGX(uTrlekifk2buamuC6Wn4sSD60lb)gpv6rkymuamu46JTtxFJdantB0OQbIITk9ihkidfYbfhsOtZGcs3GIOahkYMfkcv98ADtzGeevB46zB0RhspKqNMbflafz2fkidfhMFidGk9iuiluqgkC9IqN6dbA8YWhekwakYSBYkau4rJRxe6S0IzsEYtEYsbDa1LSSgc7gjp5Pe]] )
    

end