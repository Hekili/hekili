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


    spec:RegisterPack( "Affliction", 20181212.2336, [[duKqHbqiLepsjfDjkf1MquJIO0PikwfrvEfGAwevUfLISlK(fLQggG0XefltjvpJOQMMsk5AiI2gLc6BiczCuk05usPY6OuaZdr6EkL9Pe6GkPGfciEOsketujLsDrLuk5KkPqALukntLukANkbdvjLQwkLc0tPKPQK0xvsHAVI8xkgmHdtAXe5XcMmQUm0MfvFwiJgGtRy1kPu41uQmBvDBe2Tu)wYWfQLRYZrz6uDDG2Us03vQmEebNxPQ1JiuZxuA)GoLjTAYIRoMwyDGMXgZSEM1PRlF5tIwRKLVpgtwXAWonctwTsGjR1qE(pbFQozfR7)s5PvtwSc8cyYcG7XmBa7TpACaGs0qrypBiaF1NQdNM72ZgIG9sFjzVuUAtCCP9XxLppYSF1bV1Zy)QRNXSgR3xb7mRH88Fc(unLneHKLe48(A0ojLS4QJPfwhOzSXmRNzD66Yx(Ki5BJjlwmgslSUnKKjladNJDskzXrwizTMqXAip)NGpvdfRX69vWoOTRjuaW9yMnG92hnoaqjAOiSNneGV6t1HtZD7zdrWEPVKSxkxTjoU0(4RYNhz2V2FOnOoCM9R92GM1y9(kyNznKN)tWNQPSHiaTDnHI12yajKWdkYSUCqX6anJncf2euSU8TbKpjH2cTDnHI1ia0ocz2aqBxtOWMGI1aNJCOWkg)hkwBwb7OqBxtOWMGcBqKOwICOW1lcDZKtPuOTRjuytqXAGV2aK5qrSY5thbfl1BuPhHIVIManzfFv(8yYAnHI1qE(pbFQgkwJ17RGDqBxtOaG7XmBa7TpACaGs0qrypBiaF1NQdNM72ZgIG9sFjzVuUAtCCP9XxLppYSFT)qBqD4m7x7TbnRX69vWoZAip)NGpvtzdraA7AcfRTXasiHhuKzD5GI1bAgBekSjOyD5BdiFscTfA7AcfRraODeYSbG2UMqHnbfRboh5qHvm(puS2Sc2rH2UMqHnbf2GirTe5qHRxe6MjNsPqBxtOWMGI1aFTbiZHIyLZNockwQ3OspcfFfnbk0wOTRjuS2IeWaOJCOqcZRdHIqriPouiHrtZOqXAieWyNbfD12ea9iYbFOqd(undkQ(3tH2QbFQMrJpmuesQVL)kZoOTAWNQz04ddfHK6aVzFEvCOTAWNQz04ddfHK6aVzVcgrGTR(un0wn4t1mA8HHIqsDG3SNbsquTjgDOTAWNQz04ddfHK6aVzF0ne1COPYnmnCt(eq5M8nxFSDA0ne1COPYnmnCt(eqk2Q0JCOTAWNQz04ddfHK6aVzpR1ygGYnmxDg0wn4t1mA8HHIqsDG3SpU8PAOTAWNQz04ddfHK6aVzpdrUPYnH6oWyFQwUjFJfJ)BC9IqNrziYnvUju3bg7t1gTWf3Kp0wn4t1mA8HHIqsDG3ShGc2o0wn4t1mA8HHIqsDG3SNbq51oJu9UCt(2kU(y7uaky7uSvPh5KzX4)gxVi0zugICtLBc1DGX(uTrlKu5dTfA7AcfRTibma6ihkWL4Thk8HaHchacfAWRdkgguOl15vPhPqB1GpvZ2yX4)MVc2bTvd(und4n7xQ3OspkxRe4gidnme5YTuFqCZ1hBNYQDghaAyiYzuSvPh5KzX4)gxVi0zugICtLBc1DGX(uTrlCXn5d8Pd3GlX2PtVe8B8uPhPGXzZ66JTtztmGQn)KJuSvPh5KzX4)gxVi0zugICtLBc1DGX(u9IBKe4thUbxITtNEj434PspsbJZMLfJ)BC9IqNrziYnvUju3bg7t1lUzJaF6Wn4sSD60lb)gpv6rkym021ek0GpvZaEZ(L6nQ0JY1kbUfRC(0rYvXBm0LBP(G4Mg8PAkdGYRDgP6Dkscya0rJpeO8usmEJJ0GYckF6itqFLy89uSvPh5qBxtOqd(und4n7xQ3OspkxRe4wSY5thjxfVDidD5wQpiUff4Yn5BkjgVXrAqzbLpDKjOVsm(Ek2Q0JCYY66JTt5NoTHvGpfBv6rE2SU(y7uoQoaP6Dk2Q0JCYHQEETRPCuDas170dj0PzKUff4YaTvd(und4n7xQ3OspkxRe4wSY5thjxfVXqxUL6dIBYkRsIXBCKguwq5thzc6ReJVNITk9iNSSU(y7u(PtByf4tXwLEKNnRRp2oLJQdqQENITk9iNCOQNx7AkhvhGu9o9qcDAgPBrbUmYqokWZMvwn4t1ugaLx7ms17uKeWaOJgFiq5PKy8ghPbLfu(0rMG(kX47PyRspYLrgOTAWNQzaVz)s9gv6r5ALa3i0PDDAddLBP(G4glg)346fHoJYqKBQCtOUdm2NQnAHKULbyxFSD6UBCaOzAJgv9Ek2Q0JCGD9X2PQeREqhnH6oWyFQMITk9ixERdSSU(y70D34aqZ0gnQ69uSvPh5KD9X2PSANXbGggICgfBv6rozwm(VX1lcDgLHi3u5MqDhySpvB0cxCDzawwxFSDkBIbuT5NCKITk9iN8kU(y70WHy80rgoQoak2Q0JCYR46JTt5NoTHvGpfBv6rUmaF6Wn4sSD60lb)gpv6rkym0wn4t1mG3SpO)B0GpvB(H5Y1kbUfQ651UMbTvd(und4n75NoTHvGVCt74DGXUj6lj93YixaGo9wg5c7dpAC9IqNTLrUjFZ1lcDQpeOXldFqs3IcCYSc8nma6XjLKqB1GpvZaEZEaky7Yn5BSy8FJRxe6mkdrUPYnH6oWyFQ2Ofs626aF6Wn4sSD60lb)gpv6rkym0wn4t1mG3SNbsquTHRNDrVEOCt(gVCQgv9EQpb7MoImVCAOUdm2NQP(eSB6iYYkbMNt1GplrdOYOmxd2TrYSzzf4Bya0JVbuzil7kU(y70yaA7fHHnDe4R347PyRspYZMLxongG2Eryythb(6n(E6He60mzil7kU(y7uoQoaP6Dk2Q0J8Szdv98Axt5O6aKQ3PhsOtZiDlkWZMDLqvpV21uoQoaP6D6He60SSzzX4)gxVi0zugICtLBc1DGX(uTrlCXmaF6Wn4sSD60lb)gpv6rkySmqB1GpvZaEZEoQoaP6D5M8TqvpV21ugibr1gUE2f96H0dj0PzKzX4)gxVi0zugICtLBc1DGX(uTrlCldWNoCdUeBNo9sWVXtLEKcgdTvd(und4n71OQ3lxyF4rJRxe6STmYn5BhsOtZiDlkWbwd(unLbq51oJu9ofjbma6OXhcKSRxe6uFiqJxg(GlAJqB1GpvZaEZEWM5Q0Jgnp)NGpvl3KVTsOAxJMQj76fHo1hc04LHpiPB2i0wn4t1mG3SNF60gwb(Yf2hE046fHoBlJCbTd4BM8nFc2XmhsOttkjLBY3C9X2PmakV2zqcPtdifBv6ro5L6nQ0JucDAxN2WqYCucmpNYaO8ANbjKonG0dj0PzK5OeyEoLbq51odsiDAaPhsOtZiDlkWL36qB1GpvZaEZEgaLx7ms17Yf2hE046fHoBlJCt(MRp2oLbq51odsiDAaPyRspYjVuVrLEKsOt760ggsMJsG55ugaLx7miH0PbKEiHonJmhLaZZPmakV2zqcPtdi9qcDAgPBijGbqhn(qGYBDG9txIVXhcK8kAWNQPmakV2zKQ3PtBY)jcGdTvd(und4n7JbOTxeg20rGVEJVxUjFZhcCr5tsYUErOt9HanEz4dUygBO8yX4)gakZrOTAWNQzaVz)Y5rJRt7Yn5B(qGlMHKKD9IqN6dbA8YWhCXTmafARg8PAgWB2d2mxLE0O55)e8PA5M8TvwQ3OspsbzOHHiNmRaFddGE8nscTvd(und4n7ziYnvUju3bg7t1Yn5Bl1BuPhPGm0WqKtMvGVHbqp(gjH2QbFQMb8M9b9FJg8PAZpmxUwjWnE5mOTAWNQzaVzFmaT9IWWMoc81B89Yn5B(qGKUjFscTvd(und4n7xopACDAxUjFZhcK0mKeARg8PAgWB2Z1ZodRaF5M8TqvpV21ugibr1gUE2f96H0dj0PzKMbOK5LtJbOTxeg20rGVEJVNEiHonlBwxVi0P(qGgVm8bjDDGcCuGNnllg)346fHoJYqKBQCtOUdm2NQnAHlMb4thUbxITtNEj434PspsbJH2QbFQMb8M9s4XWZUPJG2QbFQMb8M9b9FJg8PAZpmxUwjWnwm2C8yqB1GpvZaEZ(G(Vrd(uT5hMlxRe4w(8pEmOTqB1GpvZOHQEETRzBXLpvl3KVjRRp2oLRNDgwb(gIHH3Ek2Q0JCYHQEETRPmqcIQnC9Sl61dPGXKdv98Axt56zNHvGpfmwMSzdv98AxtzGeevB46zx0RhsbJZM11lcDQpeOXldFqsLpqH2QbFQMrdv98AxZaEZEqgAghjyYn5BReQ651UMYajiQ2W1ZUOxpKcgl3KVfQ651UMYajiQ2W1ZUOxpKEiHonBrseqZM1hc04LHpiPRd0SzLvwjW8CQg8zjAavgL5AWUnsMnlRaFddGE8nGkdzzxX1hBNgdqBVimSPJaF9gFpfBv6rE2SHQEETRPXa02lcdB6iWxVX3tpKqNMjdzzxX1hBNYr1bivVtXwLEKNnBOQNx7AkhvhGu9o9qcDAgPBrbE2SReQ651UMYr1bivVtpKqNMjd5vcv98AxtzGeevB46zx0RhspKqNMjd0wn4t1mAOQNx7AgWB2Nphk9vXLBY3wju1ZRDnLbsquTHRNDrVEifmgARg8PAgnu1ZRDnd4n7L(Q4MCWBVCt(2kHQEETRPmqcIQnC9Sl61dPGXqBH2QbFQMr5sMdZpKbyJnXaQ28tok3pnAc8TmKuUjFtwE5u2edOAZp5i9qcDAMnZlNYMyavB(jhPCWt9PAziDtwE5unQ690dj0Pz2mVCQgv9Ekh8uFQwgYYYlNYMyavB(jhPhsOtZSzE5u2edOAZp5iLdEQpvldPBYYlNgQ7aJ9PA6He60mBMxonu3bg7t1uo4P(uTmK5LtztmGQn)KJ0dj0PzKYlNYMyavB(jhPCWt9PA5LHkFOTAWNQzuUK5W8dzaaEZEnQ69Y9tJMaFldjLBY3KLxovJQEp9qcDAMnZlNQrvVNYbp1NQLH0nz5Ltd1DGX(un9qcDAMnZlNgQ7aJ9PAkh8uFQwgYYYlNQrvVNEiHonZM5Lt1OQ3t5GN6t1Yq6MS8YPSjgq1MFYr6He60mBMxoLnXaQ28tos5GN6t1YqMxovJQEp9qcDAgP8YPAu17PCWt9PA5LHkFOTAWNQzuUK5W8dzaaEZ(qDhySpvl3pnAc8TmKuUjFtwE50qDhySpvtpKqNMzZ8YPH6oWyFQMYbp1NQLH0nz5Lt1OQ3tpKqNMzZ8YPAu17PCWt9PAzillVCAOUdm2NQPhsOtZSzE50qDhySpvt5GN6t1Yq6MS8YPSjgq1MFYr6He60mBMxoLnXaQ28tos5GN6t1YqMxonu3bg7t10dj0PzKYlNgQ7aJ9PAkh8uFQwEzOYhAl0wn4t1mkVC2gdrUPYnH6oWyFQwUjFJxonu3bg7t10dj0PzKUPbFQMYqKBQCtOUdm2NQPbL5gFiqG9HanEzya0Jd8ArxxEYMXMC9X2PHdX4PJmCuDauSvPh5YdO0mKugYSy8FJRxe6mkdrUPYnH6oWyFQ2OfU4M8b(0HBWLy70Pxc(nEQ0JuWyGD9X2P7UXbGMPnAu17PyRspYjVcVCkdrUPYnH6oWyFQMEiHonJ8kAWNQPme5Mk3eQ7aJ9PA60M8FIa4qB1GpvZO8YzaVzVgv9E5c7dpAC9IqNTLrUjFZ1hBNgoeJNoYWr1bqXwLEKtwd(Sen8YPAu17j1gs21lcDQpeOXldFWfZauYYEiHonJ0TOapB2qvpV21ugibr1gUE2f96H0dj0PzlMbOKL9qcDAgPKmB2vusmEJJ0yT5iXemtVScQpvtpTTJ8H5hYaOspkJmqB1GpvZO8YzaVzVgv9E5c7dpAC9IqNTLrUjFBfxFSDA4qmE6idhvhafBv6rozn4Zs0WlNQrvVNuBKSRxe6uFiqJxg(GlMbOKL9qcDAgPBrbE2SHQEETRPmqcIQnC9Sl61dPhsOtZwmdqjl7He60msjz2SROKy8ghPXAZrIjyMEzfuFQMEABh5dZpKbqLEugzG2QbFQMr5LZaEZE2edOAZp5OCH9HhnUErOZ2Yi3KVjRg8zjA4LtztmGQn)KJKAJ2KRp2onCigpDKHJQdGITk9i3MyX4)gxVi0zuwTZ4aqddroZOfkdzxVi0P(qGgVm8bxmdqjFy(HmaQ0JKLDLdj0PzKzX4)gxVi0zugICtLBc1DGX(uTrlClt2SHQEETRPmqcIQnC9Sl61dPhsOtZwKvGVHbqpU80GpvtbBMRspA088Fc(unfjbma6OXhcugOTAWNQzuE5mG3Spu3bg7t1Yf2hE046fHoBlJCt(glg)346fHoJYqKBQCtOUdm2NQnAHKkFGpD4gCj2oD6LGFJNk9ifmgyxFSD6UBCaOzAJgv9Ek2Q0JCYYEiHonJ0TOapB2qvpV21ugibr1gUE2f96H0dj0PzlMbOKpm)qgav6rzi76fHo1hc04LHp4Izak0wOTAWNQz085F8yBGnZvPhnAE(pbFQwUFA0e4BziPCt(wOQNx7AkhvhGu9o9qcDAgPBrbU8wNmlg)346fHoJYqKBQCtOUdm2NQnAHBza(0HBWLy70Pxc(nEQ0JuWyYHQEETRPmqcIQnC9Sl61dPhsOtZwCDGcTvd(unJMp)Jhd4n7d6)gn4t1MFyUCTsGBCjZH5hYai3KV56JTt5O6aKQ3PyRspYjZIX)nUErOZOme5Mk3eQ7aJ9PAJw4wgGpD4gCj2oD6LGFJNk9ifmMSS8YPAu17PhsOtZiLxovJQEpLdEQpvlpGsjrKmBwE50qDhySpvtpKqNMrkVCAOUdm2NQPCWt9PA5bukjIKzZYlNYMyavB(jhPhsOtZiLxoLnXaQ28tos5GN6t1YdOusejLHCOQNx7AkhvhGu9o9qcDAgPBAWNQPAu17PrbU8wlYHQEETRPmqcIQnC9Sl61dPhsOtZwCDGcTvd(unJMp)Jhd4n7d6)gn4t1MFyUCTsGBCjZH5hYai3KV56JTt5O6aKQ3PyRspYjZIX)nUErOZOme5Mk3eQ7aJ9PAJw4wgGpD4gCj2oD6LGFJNk9ifmMCOQNx7AkdKGOAdxp7IE9q6He60ms3yf4Bya0Jlpn4t1unQ690Oahyn4t1unQ690OaxEYNSS8YPAu17PhsOtZiLxovJQEpLdEQpvlVmzZYlNgQ7aJ9PA6He60ms5Ltd1DGX(unLdEQpvlVmzZYlNYMyavB(jhPhsOtZiLxoLnXaQ28tos5GN6t1YlJmqB1GpvZO5Z)4XaEZEoQoaP6D5M8TqvpV21ugibr1gUE2f96H0dj0PzlUjFGcCuGNnBOQNx7AkdKGOAdxp7IE9q6He60SfZSwafARg8PAgnF(hpgWB2ZaO8ANrQExUjFtcmpNsulrcSDkymzjW8CApra8C9F6He60mOTAWNQz085F8yaVzVgv9E5M8njW8CkrTejW2PGXKxrwxFSDkBIbuT5NCKITk9iNSSXhU0ef40munQ69KJpCPjkWPRt1OQ3to(WLMOaNkFQgv9EzYMn(WLMOaNMHQrvVxgOTAWNQz085F8yaVzpBIbuT5NCuUjFtcmpNsulrcSDkym5vKn(WLMOaNMHYMyavB(jhjhF4stuGtxNYMyavB(jhjhF4stuGtLpLnXaQ28tokd0wn4t1mA(8pEmG3Spu3bg7t1Yn5BsG55uIAjsGTtbJjVs8Hlnrbondnu3bg7t1KxX1hBNQsS6bD0eQ7aJ9PAk2Q0JCOTAWNQz085F8yaVzp)0Pn)KJYn5BYkbMNtNgxoUk9OHJeddPmxd2T4MnssBswwm(VX1lcDgLHi3u5MqDhySpvB0cTPthUbxITtNEj434PspsbJxCDzK36aLSSHQEETRPCuDas170dj0PzlIKagaD04dbMn7kU(y7uoQoaP6Dk2Q0JCzilBOQNx7AAmaT9IWWMoc81B890dj0PzlIKagaD04dbMn7kU(y70yaA7fHHnDe4R347PyRspYLHSSHQEETRPC9SZWkWNEiHonBrKeWaOJgFiWSzxX1hBNY1ZodRaFdXWWBpfBv6rUmKLnu1ZRDnD58OX1PD6He60SfrsadGoA8HaZMDfxFSD6Y5rJRt7uSvPh5Yqou1ZRDnLbsquTHRNDrVEi9qcDA2IijGbqhn(qGaNbOzZkbMNtNgxoUk9OHJeddPmxd2TO8bkzxVi0P(qGgVm8bjDldqLbARg8PAgnF(hpgWB2dqbBhARg8PAgnF(hpgWB2ZpDAdRaF5M2X7aJDt0xs6VLrUaaD6TmYnTJ3bg7BzKlSp8OX1lcD2wg5M8nxVi0P(qGgVm8bjDlkWH2QbFQMrZN)XJb8M98tN2WkWxUW(WJgxVi0zBzKlaqNElJCt74DGXUzY38jyhZCiHonPKuUPD8oWy3e9LK(BzKBY3C9X2PmakV2zqcPtdifBv6ro5L6nQ0JucDAxN2WqYRWrjW8CkdGYRDgKq60aspKqNMbTvd(unJMp)Jhd4n75NoTHvGVCH9HhnUErOZ2YixaGo9wg5M2X7aJDZKV5tWoM5qcDAsjPCt74DGXUj6lj93Yi3KV56JTtzauETZGesNgqk2Q0JCYl1BuPhPe60UoTHHqB1GpvZO5Z)4XaEZE(PtByf4l30oEhySBI(ss)TmYfaOtVLrUPD8oWyFld0wn4t1mA(8pEmG3SNbq51oJu9UCH9HhnUErOZ2Yi3KV56JTtzauETZGesNgqk2Q0JCYl1BuPhPe60UoTHHKxHJsG55ugaLx7miH0PbKEiHonJ8kAWNQPmakV2zKQ3PtBY)jcGdTvd(unJMp)Jhd4n7zauETZivVlxyF4rJRxe6STmYn5BU(y7ugaLx7miH0PbKITk9iN8s9gv6rkHoTRtByi0wn4t1mA(8pEmG3SNbq51oJu9o0wOTAWNQzuwm2C8yBGnZvPhnAE(pbFQwUjFlu1ZRDnLbsquTHRNDrVEi9qcDAgPBSc8nma6XLhscya0rJpeizzxX1hBNYr1bivVtXwLEKNnBOQNx7AkhvhGu9o9qcDAgPBSc8nma6XLhscya0rJpeOmqB1GpvZOSyS54XaEZ(G(Vrd(uT5hMlxRe4w(8pEm5M8nzdv98AxtzGeevB46zx0RhspKqNMrQpeOXlddGEC5jRn0Myf4Bya0Jlt2SHQEETRPmqcIQnC9Sl61dPGXYq2hc04LHp4IHQEETRPmqcIQnC9Sl61dPhsOtZG2QbFQMrzXyZXJb8M9me5Mk3eQ7aJ9PA5M8TL6nQ0JuqgAyiYH2QbFQMrzXyZXJb8M9GnZvPhnAE(pbFQwUjFBLL6nQ0JuqgAyiYjVs8HlnrbondLbsquTHRNDrVEizzD9X2PCuDas17uSvPh5Kdv98Axt5O6aKQ3PhsOtZiDdjbma6OXhcK8kkjgVXrAqzbLpDKjOVsm(Ek2Q0J8SzLLvGVHbqp(IBKKmlg)346fHoJYqKBQCtOUdm2NQnAHKUE2SSc8nma6XxCBDYSy8FJRxe6mkdrUPYnH6oWyFQ2OfU426Yq21lcDQpeOXldFWfxlGrsadGoA8HajZIX)nUErOZOme5Mk3eQ7aJ9PAJw4wMSzD9IqN6dbA8YWhK0nBeyKeWaOJgFiq5XkW3WaOhxgOTAWNQzuwm2C8yaVzpyZCv6rJMN)tWNQLBY3wzPEJk9ifKHggICYHQDnAQM0TGYCJpeiWl1BuPhPXkNpDe0wn4t1mklgBoEmG3ShSzUk9OrZZ)j4t1Yf2hE046fHoBlJCt(2kl1BuPhPGm0WqKtw2vC9X2PCuDas17uSvPh5zZgQ651UMYr1bivVtpKqNMTOpeOXlddGE8Szzf4Bya0JVygzil7kU(y70LZJgxN2PyRspYZMLvGVHbqp(IzKHCOAxJMQjDlOm34dbc8s9gv6rASY5thrw2vusmEJJ0GYckF6itqFLy89uSvPh5zZkbMNtdklO8PJmb9vIX3tpKqNMTOpeOXlddGECzswlXJnvNwyDGMXgZSEM1PRlF5tYK1o96PJyjR1OeX15ihkirqHg8PAO4hMZOqBtwkOdOUKL1qSgjz9dZzPvtwCjZH5hYaKwnTqM0QjlSvPh5jGKS0GpvNSytmGQn)KJjRWnoEJMSKfk4LtztmGQn)KJ0dj0PzqHndf8YPSjgq1MFYrkh8uFQgkKbkiDdkKfk4Lt1OQ3tpKqNMbf2muWlNQrvVNYbp1NQHczGcYqHSqbVCkBIbuT5NCKEiHondkSzOGxoLnXaQ28tos5GN6t1qHmqbPBqHSqbVCAOUdm2NQPhsOtZGcBgk4Ltd1DGX(unLdEQpvdfYafKHcE5u2edOAZp5i9qcDAguqkuWlNYMyavB(jhPCWt9PAOqEqrgQ8tw)0OjWtwzizYtlSEA1Kf2Q0J8eqswAWNQtwAu17twHBC8gnzjluWlNQrvVNEiHondkSzOGxovJQEpLdEQpvdfYafKUbfYcf8YPH6oWyFQMEiHondkSzOGxonu3bg7t1uo4P(unuiduqgkKfk4Lt1OQ3tpKqNMbf2muWlNQrvVNYbp1NQHczGcs3GczHcE5u2edOAZp5i9qcDAguyZqbVCkBIbuT5NCKYbp1NQHczGcYqbVCQgv9E6He60mOGuOGxovJQEpLdEQpvdfYdkYqLFY6NgnbEYkdjtEAb5NwnzHTk9ipbKKLg8P6KvOUdm2NQtwHBC8gnzjluWlNgQ7aJ9PA6He60mOWMHcE50qDhySpvt5GN6t1qHmqbPBqHSqbVCQgv9E6He60mOWMHcE5unQ69uo4P(unuiduqgkKfk4Ltd1DGX(un9qcDAguyZqbVCAOUdm2NQPCWt9PAOqgOG0nOqwOGxoLnXaQ28tospKqNMbf2muWlNYMyavB(jhPCWt9PAOqgOGmuWlNgQ7aJ9PA6He60mOGuOGxonu3bg7t1uo4P(unuipOidv(jRFA0e4jRmKm5jpzXXCf890QPfYKwnzPbFQozXIX)nFfSlzHTk9ipbKKNwy90QjlSvPh5jGKSwQpiMSC9X2PSANXbGggICgfBv6rouqgkyX4)gxVi0zugICtLBc1DGX(uTrlekwCdkKpuamuC6Wn4sSD60lb)gpv6rkymuKnlu46JTtztmGQn)KJuSvPh5qbzOGfJ)BC9IqNrziYnvUju3bg7t1qXIBqbjHcGHIthUbxITtNEj434PspsbJHISzHcwm(VX1lcDgLHi3u5MqDhySpvdflUbf2iuamuC6Wn4sSD60lb)gpv6rkyCYsd(uDYAPEJk9yYAPEMwjWKfidnme5jpTG8tRMSWwLEKNasYQItwm0twAWNQtwl1BuPhtwl1hetwYcfYcfkjgVXrAqzbLpDKjOVsm(Ek2Q0JCOGmuilu46JTt5NoTHvGpfBv6rouKnlu46JTt5O6aKQ3PyRspYHcYqrOQNx7AkhvhGu9o9qcDAguq6guef4qHmqHmqbzOikWHISzHczHcn4t1ugaLx7ms17uKeWaOJgFiqOqEqHsIXBCKguwq5thzc6ReJVNITk9ihkKbkKjzTuptReyYkw58PJsEAH1kTAYcBv6rEcijRL6dIjlwm(VX1lcDgLHi3u5MqDhySpvB0cHcs3GImqbWqHRp2oD3noa0mTrJQEpfBv6rouamu46JTtvjw9GoAc1DGX(unfBv6rouipOyDOayOqwOW1hBNU7ghaAM2OrvVNITk9ihkidfU(y7uwTZ4aqddroJITk9ihkidfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcflcfRdfYafadfYcfU(y7u2edOAZp5ifBv6rouqgkwbkC9X2PHdX4PJmCuDauSvPh5qbzOyfOW1hBNYpDAdRaFk2Q0JCOqgOayO40HBWLy70Pxc(nEQ0JuW4KLg8P6K1s9gv6XK1s9mTsGjlcDAxN2WWKNwGKPvtwyRspYtajzPbFQozf0)nAWNQn)W8K1pm30kbMScv98AxZsEAbByA1Kf2Q0J8eqswAWNQtw8tN2WkWpzf2hE046fHolTqMKv4ghVrtwUErOt9HanEz4dcfKUbfrbouqgkyf4Bya0JdfKcfKmzfaOtNSYKSM2X7aJDt0xs6NSYK80cKO0QjlSvPh5jGKSc344nAYIfJ)BC9IqNrziYnvUju3bg7t1gTqOG0nOyDOayO40HBWLy70Pxc(nEQ0JuW4KLg8P6KfafS9KNwWgtRMSWwLEKNasYkCJJ3OjlE5unQ69uFc2nDeuqgk4Ltd1DGX(un1NGDthbfKHczHcjW8CQg8zjAavgL5AWoOydkijuKnluWkW3WaOhhk2GcGcfYafKHczHIvGcxFSDAmaT9IWWMoc81B89uSvPh5qr2SqbVCAmaT9IWWMoc81B890dj0PzqHmqbzOqwOyfOW1hBNYr1bivVtXwLEKdfzZcfHQEETRPCuDas170dj0PzqbPBqruGdfzZcfRafHQEETRPCuDas170dj0Pzqr2Sqblg)346fHoJYqKBQCtOUdm2NQnAHqXIqrgOayO40HBWLy70Pxc(nEQ0JuWyOqMKLg8P6KfdKGOAdxp7IE9WKNwyTlTAYcBv6rEcijRWnoEJMScv98AxtzGeevB46zx0RhspKqNMbfKHcwm(VX1lcDgLHi3u5MqDhySpvB0cHInOiduamuC6Wn4sSD60lb)gpv6rkyCYsd(uDYIJQdqQEp5PfYa00QjlSvPh5jGKS0GpvNS0OQ3NSc344nAY6qcDAguq6guef4qbWqHg8PAkdGYRDgP6Dkscya0rJpeiuqgkC9IqN6dbA8YWhekwekSXKvyF4rJRxe6S0czsEAHmzsRMSWwLEKNasYkCJJ3OjRvGIq1UgnvdfKHcxVi0P(qGgVm8bHcs3GcBmzPbFQozb2mxLE0O55)e8P6KNwiZ6PvtwyRspYtajzPbFQozXpDAdRa)KvyF4rJRxe6S0czswbTd4BM8KLpb7yMdj0PjLKjRWnoEJMSC9X2PmakV2zqcPtdifBv6rouqgkwQ3Ospsj0PDDAddHcYqbhLaZZPmakV2zqcPtdi9qcDAguqgk4OeyEoLbq51odsiDAaPhsOtZGcs3GIOahkKhuSEYtlKr(PvtwyRspYtajzPbFQozXaO8ANrQEpzfUXXB0KLRp2oLbq51odsiDAaPyRspYHcYqXs9gv6rkHoTRtByiuqgk4OeyEoLbq51odsiDAaPhsOtZGcYqbhLaZZPmakV2zqcPtdi9qcDAguq6guGKagaD04dbcfYdkwhkagk8txIVXhcekidfRafAWNQPmakV2zKQ3PtBY)jcGNSc7dpAC9IqNLwitYtlKzTsRMSWwLEKNasYkCJJ3OjlFiqOyrOq(KekidfUErOt9HanEz4dcflcfzSHqH8Gcwm(VbGYCmzPbFQozfdqBVimSPJaF9gFFYtlKHKPvtwyRspYtajzfUXXB0KLpeiuSiuKHKqbzOW1lcDQpeOXldFqOyXnOidqtwAWNQtwlNhnUoTN80czSHPvtwyRspYtajzfUXXB0K1kqXs9gv6rkidnme5qbzOGvGVHbqpouSbfKmzPbFQozb2mxLE0O55)e8P6KNwidjkTAYcBv6rEcijRWnoEJMSwQ3OspsbzOHHihkidfSc8nma6XHInOGKjln4t1jlgICtLBc1DGX(uDYtlKXgtRMSWwLEKNasYsd(uDYkO)B0GpvB(H5jRFyUPvcmzXlNL80czw7sRMSWwLEKNasYkCJJ3OjlFiqOG0nOq(KmzPbFQozfdqBVimSPJaF9gFFYtlSoqtRMSWwLEKNasYkCJJ3OjlFiqOGuOidjtwAWNQtwlNhnUoTN80cRNjTAYcBv6rEcijRWnoEJMScv98AxtzGeevB46zx0RhspKqNMbfKcfzakuqgk4LtJbOTxeg20rGVEJVNEiHondkYMfkC9IqN6dbA8YWhekifkwhOqbWqruGdfzZcfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcflcfzGcGHIthUbxITtNEj434PspsbJtwAWNQtwC9SZWkWp5PfwF90Qjln4t1jlj8y4z30rjlSvPh5jGK80cRl)0QjlSvPh5jGKS0GpvNSc6)gn4t1MFyEY6hMBALatwSyS54XsEAH1xR0QjlSvPh5jGKS0GpvNSc6)gn4t1MFyEY6hMBALatw5Z)4XsEYtwXhgkcj1tRMwitA1Kf2Q0J8eqsEAH1tRMSWwLEKNasYtli)0QjlSvPh5jGK80cRvA1KLg8P6KfdKGOAto(aaBhVKf2Q0J8eqsEAbsMwnzHTk9ipbKKv4ghVrtwU(y70OBiQ5qtLByA4M8jGuSvPh5jln4t1jROBiQ5qtLByA4M8jGjpTGnmTAYcBv6rEcijpTajkTAYsd(uDYkU8P6Kf2Q0J8eqsEAbBmTAYcBv6rEcijRWnoEJMSyX4)gxVi0zugICtLBc1DGX(uTrlekwCdkKFYsd(uDYIHi3u5MqDhySpvN80cRDPvtwAWNQtwauW2twyRspYtaj5PfYa00QjlSvPh5jGKSc344nAYAfOW1hBNcqbBNITk9ihkidfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcfKcfYpzPbFQozXaO8ANrQEp5jpzfQ651UMLwnTqM0QjlSvPh5jGKSc344nAYswOW1hBNY1ZodRaFdXWWBpfBv6rouqgkcv98AxtzGeevB46zx0RhsbJHcYqrOQNx7Akxp7mSc8PGXqHmqr2SqrOQNx7AkdKGOAdxp7IE9qkymuKnlu46fHo1hc04LHpiuqkuiFGMS0GpvNSIlFQo5PfwpTAYcBv6rEcijRWnoEJMScv98AxtzGeevB46zx0RhspKqNMbflcfKiGcfzZcf(qGgVm8bHcsHI1bkuKnluiluiluibMNt1GplrdOYOmxd2bfBqbjHISzHcwb(gga94qXguauOqgOGmuiluScu46JTtJbOTxeg20rGVEJVNITk9ihkYMfkcv98AxtJbOTxeg20rGVEJVNEiHondkKbkidfYcfRafU(y7uoQoaP6Dk2Q0JCOiBwOiu1ZRDnLJQdqQENEiHondkiDdkIcCOiBwOyfOiu1ZRDnLJQdqQENEiHondkKbkidfRafHQEETRPmqcIQnC9Sl61dPhsOtZGczswAWNQtwGm0mosWsEAb5NwnzHTk9ipbKKv4ghVrtwRafHQEETRPmqcIQnC9Sl61dPGXjln4t1jR85qPVkEYtlSwPvtwyRspYtajzfUXXB0K1kqrOQNx7AkdKGOAdxp7IE9qkyCYsd(uDYs6RIBYbV9jp5jlE5S0QPfYKwnzHTk9ipbKKv4ghVrtw8YPH6oWyFQMEiHondkiDdk0GpvtziYnvUju3bg7t10GYCJpeiuamu4dbA8YWaOhhkagkwl66qH8GczHImqHnbfU(y70WHy80rgoQoak2Q0JCOqEqbqPzijuiduqgkyX4)gxVi0zugICtLBc1DGX(uTrlekwCdkKpuamuC6Wn4sSD60lb)gpv6rkymuamu46JTt3DJdantB0OQ3tXwLEKdfKHIvGcE5ugICtLBc1DGX(un9qcDAguqgkwbk0GpvtziYnvUju3bg7t10Pn5)ebWtwAWNQtwme5Mk3eQ7aJ9P6KNwy90QjlSvPh5jGKS0GpvNS0OQ3NSc344nAYY1hBNgoeJNoYWr1bqXwLEKdfKHcn4Zs0WlNQrvVhkifkSHqbzOW1lcDQpeOXldFqOyrOidqHcYqHSqXHe60mOG0nOikWHISzHIqvpV21ugibr1gUE2f96H0dj0PzqXIqrgGcfKHczHIdj0PzqbPqbjHISzHIvGcLeJ34inwBosmbZ0lRG6t10tB7GcYqXH5hYaOspcfYafYKSc7dpAC9IqNLwitYtli)0QjlSvPh5jGKS0GpvNS0OQ3NSc344nAYAfOW1hBNgoeJNoYWr1bqXwLEKdfKHcn4Zs0WlNQrvVhkifkSrOGmu46fHo1hc04LHpiuSiuKbOqbzOqwO4qcDAguq6guef4qr2SqrOQNx7AkdKGOAdxp7IE9q6He60mOyrOidqHcYqHSqXHe60mOGuOGKqr2SqXkqHsIXBCKgRnhjMGz6Lvq9PA6PTDqbzO4W8dzauPhHczGczswH9HhnUErOZslKj5PfwR0QjlSvPh5jGKS0GpvNSytmGQn)KJjRWnoEJMSKfk0GplrdVCkBIbuT5NCekifkSrOWMGcxFSDA4qmE6idhvhafBv6rouytqblg)346fHoJYQDghaAyiYzgTqOqgOGmu46fHo1hc04LHpiuSiuKbOqbzO4W8dzauPhHcYqHSqXkqXHe60mOGmuWIX)nUErOZOme5Mk3eQ7aJ9PAJwiuSbfzGISzHIqvpV21ugibr1gUE2f96H0dj0PzqXIqbRaFddGECOqEqHg8PAkyZCv6rJMN)tWNQPijGbqhn(qGqHmjRW(WJgxVi0zPfYK80cKmTAYcBv6rEcijln4t1jRqDhySpvNSc344nAYIfJ)BC9IqNrziYnvUju3bg7t1gTqOGuOq(qbWqXPd3GlX2PtVe8B8uPhPGXqbWqHRp2oD3noa0mTrJQEpfBv6rouqgkKfkoKqNMbfKUbfrbouKnlueQ651UMYajiQ2W1ZUOxpKEiHondkwekYauOGmuCy(HmaQ0JqHmqbzOW1lcDQpeOXldFqOyrOidqtwH9HhnUErOZslKj5jpzLp)JhlTAAHmPvtwyRspYtajzPbFQozb2mxLE0O55)e8P6Kv4ghVrtwHQEETRPCuDas170dj0PzqbPBqruGdfYdkwhkidfSy8FJRxe6mkdrUPYnH6oWyFQ2OfcfBqrgOayO40HBWLy70Pxc(nEQ0JuWyOGmueQ651UMYajiQ2W1ZUOxpKEiHondkwekwhOjRFA0e4jRmKm5PfwpTAYcBv6rEcijRWnoEJMSC9X2PCuDas17uSvPh5qbzOGfJ)BC9IqNrziYnvUju3bg7t1gTqOydkYafadfNoCdUeBNo9sWVXtLEKcgdfKHczHcE5unQ690dj0PzqbPqbVCQgv9Ekh8uFQgkKhuaukjIKqr2SqbVCAOUdm2NQPhsOtZGcsHcE50qDhySpvt5GN6t1qH8GcGsjrKekYMfk4LtztmGQn)KJ0dj0PzqbPqbVCkBIbuT5NCKYbp1NQHc5bfaLsIijuiduqgkcv98Axt5O6aKQ3PhsOtZGcs3Gcn4t1unQ690OahkKhuSwqbzOiu1ZRDnLbsquTHRNDrVEi9qcDAguSiuSoqtwAWNQtwb9FJg8PAZpmpz9dZnTsGjlUK5W8dzasEAb5NwnzHTk9ipbKKv4ghVrtwU(y7uoQoaP6Dk2Q0JCOGmuWIX)nUErOZOme5Mk3eQ7aJ9PAJwiuSbfzGcGHIthUbxITtNEj434PspsbJHcYqrOQNx7AkdKGOAdxp7IE9q6He60mOG0nOGvGVHbqpouipOqd(unvJQEpnkWHcGHcn4t1unQ690OahkKhuiFOGmuiluWlNQrvVNEiHondkifk4Lt1OQ3t5GN6t1qH8GImqr2SqbVCAOUdm2NQPhsOtZGcsHcE50qDhySpvt5GN6t1qH8GImqr2SqbVCkBIbuT5NCKEiHondkifk4LtztmGQn)KJuo4P(unuipOiduitYsd(uDYkO)B0GpvB(H5jRFyUPvcmzXLmhMFidqYtlSwPvtwyRspYtajzfUXXB0KvOQNx7AkdKGOAdxp7IE9q6He60mOyXnOq(afkagkIcCOiBwOiu1ZRDnLbsquTHRNDrVEi9qcDAguSiuKzTaAYsd(uDYIJQdqQEp5PfizA1Kf2Q0J8eqswHBC8gnzjbMNtjQLib2ofmgkidfsG550EIa456)0dj0Pzjln4t1jlgaLx7ms17jpTGnmTAYcBv6rEcijRWnoEJMSKaZZPe1sKaBNcgdfKHIvGczHcxFSDkBIbuT5NCKITk9ihkidfYcfXhU0ef40munQ69qbzOi(WLMOaNUovJQEpuqgkIpCPjkWPYNQrvVhkKbkYMfkIpCPjkWPzOAu17HczswAWNQtwAu17tEAbsuA1Kf2Q0J8eqswHBC8gnzjbMNtjQLib2ofmgkidfRafYcfXhU0ef40mu2edOAZp5iuqgkIpCPjkWPRtztmGQn)KJqbzOi(WLMOaNkFkBIbuT5NCekKjzPbFQozXMyavB(jhtEAbBmTAYcBv6rEcijRWnoEJMSKaZZPe1sKaBNcgdfKHIvGI4dxAIcCAgAOUdm2NQHcYqXkqHRp2ovLy1d6Oju3bg7t1uSvPh5jln4t1jRqDhySpvN80cRDPvtwyRspYtajzfUXXB0KLSqHeyEoDAC54Q0JgosmmKYCnyhuS4guyJKekSjOqwOGfJ)BC9IqNrziYnvUju3bg7t1gTqOWMGIthUbxITtNEj434PspsbJHIfHI1HczGc5bfRduOGmuilueQ651UMYr1bivVtpKqNMbflcfijGbqhn(qGqr2SqXkqHRp2oLJQdqQENITk9ihkKbkidfYcfHQEETRPXa02lcdB6iWxVX3tpKqNMbflcfijGbqhn(qGqr2SqXkqHRp2ongG2Eryythb(6n(Ek2Q0JCOqgOGmuilueQ651UMY1ZodRaF6He60mOyrOajbma6OXhcekYMfkwbkC9X2PC9SZWkW3qmm82tXwLEKdfYafKHczHIqvpV210LZJgxN2PhsOtZGIfHcKeWaOJgFiqOiBwOyfOW1hBNUCE0460ofBv6rouiduqgkcv98AxtzGeevB46zx0RhspKqNMbflcfijGbqhn(qGqbWqrgGcfzZcfsG550PXLJRspA4iXWqkZ1GDqXIqH8bkuqgkC9IqN6dbA8YWhekiDdkYauOqMKLg8P6Kf)0Pn)KJjpTqgGMwnzPbFQozbqbBpzHTk9ipbKKNwitM0QjlSvPh5jGKS0GpvNS4NoTHvGFYkSp8OX1lcDwAHmjRPD8oWypzLjzfUXXB0KLRxe6uFiqJxg(GqbPBqruGNSca0Ptwzswt74DGXUj6lj9twzsEAHmRNwnzHTk9ipbKKLg8P6Kf)0PnSc8twH9HhnUErOZslKjznTJ3bg7Mjpz5tWoM5qcDAsjzYkCJJ3OjlxFSDkdGYRDgKq60asXwLEKdfKHIL6nQ0JucDAxN2WqOGmuScuWrjW8CkdGYRDgKq60aspKqNMLSca0Ptwzswt74DGXUj6lj9twzsEAHmYpTAYcBv6rEcijln4t1jl(PtByf4NSc7dpAC9IqNLwitYAAhVdm2ntEYYNGDmZHe60KsYKv4ghVrtwU(y7ugaLx7miH0PbKITk9ihkidfl1BuPhPe60UoTHHjRaaD6KvMK10oEhySBI(ss)KvMKNwiZALwnzHTk9ipbKKLg8P6Kf)0PnSc8twt74DGXEYktYkaqNozLjznTJ3bg7MOVK0pzLj5PfYqY0QjlSvPh5jGKS0GpvNSyauETZivVNSc344nAYY1hBNYaO8ANbjKonGuSvPh5qbzOyPEJk9iLqN21PnmekidfRafCucmpNYaO8ANbjKonG0dj0PzqbzOyfOqd(unLbq51oJu9oDAt(pra8KvyF4rJRxe6S0czsEAHm2W0QjlSvPh5jGKS0GpvNSyauETZivVNSc344nAYY1hBNYaO8ANbjKonGuSvPh5qbzOyPEJk9iLqN21Pnmmzf2hE046fHolTqMKNwidjkTAYsd(uDYIbq51oJu9EYcBv6rEcijp5jlwm2C8yPvtlKjTAYcBv6rEcijRWnoEJMScv98AxtzGeevB46zx0RhspKqNMbfKUbfSc8nma6XHc5bfijGbqhn(qGqbzOqwOyfOW1hBNYr1bivVtXwLEKdfzZcfHQEETRPCuDas170dj0PzqbPBqbRaFddGECOqEqbscya0rJpeiuitYsd(uDYcSzUk9OrZZ)j4t1jpTW6PvtwyRspYtajzfUXXB0KLSqrOQNx7AkdKGOAdxp7IE9q6He60mOGuOWhc04LHbqpouipOqwOWgcf2euWkW3WaOhhkKbkYMfkcv98AxtzGeevB46zx0RhsbJHczGcYqHpeOXldFqOyrOiu1ZRDnLbsquTHRNDrVEi9qcDAwYsd(uDYkO)B0GpvB(H5jRFyUPvcmzLp)Jhl5PfKFA1Kf2Q0J8eqswHBC8gnzTuVrLEKcYqddrEYsd(uDYIHi3u5MqDhySpvN80cRvA1Kf2Q0J8eqswHBC8gnzTcuSuVrLEKcYqddrouqgkwbkIpCPjkWPzOmqcIQnC9Sl61dHcYqHSqHRp2oLJQdqQENITk9ihkidfHQEETRPCuDas170dj0PzqbPBqbscya0rJpeiuqgkwbkusmEJJ0GYckF6itqFLy89uSvPh5qr2SqHSqbRaFddGECOyXnOGKqbzOGfJ)BC9IqNrziYnvUju3bg7t1gTqOGuOyDOiBwOGvGVHbqpouS4guSouqgkyX4)gxVi0zugICtLBc1DGX(uTrlekwCdkwhkKbkidfUErOt9HanEz4dcflcfRfuamuGKagaD04dbcfKHcwm(VX1lcDgLHi3u5MqDhySpvB0cHInOiduKnlu46fHo1hc04LHpiuq6guyJqbWqbscya0rJpeiuipOGvGVHbqpouitYsd(uDYcSzUk9OrZZ)j4t1jpTajtRMSWwLEKNasYkCJJ3OjRvGIL6nQ0JuqgAyiYHcYqrOAxJMQHcs3GIGYCJpeiuamuSuVrLEKgRC(0rjln4t1jlWM5Q0Jgnp)NGpvN80c2W0QjlSvPh5jGKS0GpvNSaBMRspA088Fc(uDYkCJJ3OjRvGIL6nQ0JuqgAyiYHcYqHSqXkqHRp2oLJQdqQENITk9ihkYMfkcv98Axt5O6aKQ3PhsOtZGIfHcFiqJxgga94qr2SqbRaFddGECOyrOiduiduqgkKfkwbkC9X2PlNhnUoTtXwLEKdfzZcfSc8nma6XHIfHImqHmqbzOiuTRrt1qbPBqrqzUXhcekagkwQ3OspsJvoF6iOGmuiluScuOKy8ghPbLfu(0rMG(kX47PyRspYHISzHcjW8CAqzbLpDKjOVsm(E6He60mOyrOWhc04LHbqpouitYkSp8OX1lcDwAHmjp5jp5jpLa]] )


end