-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 265 )

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
            duration = function () return talent.absolute_corruption.enabled and 3600 or ( 14 * ( talent.creeping_death.enabled and 0.85 or 1 ) ) end,
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
            duration = 5.001,
            max_stack = 1,
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
            duration = function () return 8 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
            copy = "unstable_affliction_1"
        },
        unstable_affliction_2 = {
            id = 233496,
            duration = function () return 8 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_3 = {
            id = 233497,
            duration = function () return 8 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_4 = {
            id = 233498,
            duration = function () return 8 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_5 = {
            id = 233499,
            duration = function () return 8 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
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

            usable = function () return not pet.alive and not buff.grimoire_of_sacrifice.up end,
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


    spec:RegisterPack( "Affliction", 20181108.0002, [[dy0IHbqiLKEKsHCjeLAteLrru5uiQwfLcVcqMfrv3crr7cPFjjzykfDmLWYuk1ZOu00ukORbOABikPVbOOXHOW5ukqwhIs08qKUNs1(Ou1bbuyHkL8qLcOlQuOsNuPqvwjLkZerjOBIOeyNssnueLqlvPa8ukzQkjUQsHQ6RkfO2Re)LIbt4WKwmrESGjJYLH2SK6Zcz0aCAPwTsHkEnLsZwv3gODR43IgUqTCvEoQMovxhHTRe9DLuJhqPZJiwVsHY8Le7h0LfLvkwm1Xs1BV5cYyXInjd6MBUPnT5guXYjjglwXAWwnclwJcIflGrD93bVZPyfRK8PYkRuS4jXfWIfa3J5KLvvvu7aiKOHeSkEds8Q35eoT2RI3GHQK(uQkPALmz4YQIVSUFKx1knEBVOQv2EHzdwVpd2Aag11Fh8ohkVbdfljI(9nEtrQyXuhlvV9MliJfl2KmOBU5MBBtGzXIhJHs1BtwbEXcqZy4uKkwmKhkwBeuamQR)o4DoqXgSEFgSfA3gbfaCpMtwwvvrTdGqIgsWQ4niXRENt40AVkEdgQs6tPQKQvYKHlRk(Y6(rEvKfpCdqBgVkYIBaMny9(myRbyux)DW7CO8gmaTBJGIQZLiOeEqbzipuS9MlidOGmHIfBtwU52qbWGSaODq72iOydeGoriNSeA3gbfKjuamymKbfwX4)qbzHzWwk0UnckitOydabZLidkC9Iq301ukfA3gbfKjuamyBCi4oueRmwprqXs9Av6rO4ZOoqH2TrqbzcfadgdzqXgyoUg15afbayWwOWtOyJ)WDv6rOayux)DW7CKhk0pNiOyD7aGcVbrY0tYK1iueaGbBHcT2XdkcjOK6qH3Giu0COWEOybWHcogYHXPfR4lR7hlwBeuamQR)o4DoqXgSEFgSfA3gbfaCpMtwwvvrTdGqIgsWQ4niXRENt40AVkEdgQs6tPQKQvYKHlRk(Y6(rEvKfpCdqBgVkYIBaMny9(myRbyux)DW7CO8gmaTBJGIQZLiOeEqbzipuS9MlidOGmHIfBtwU52qbWGSaODq72iOydeGoriNSeA3gbfKjuamymKbfwX4)qbzHzWwk0UnckitOydabZLidkC9Iq301ukfA3gbfKjuamyBCi4oueRmwprqXs9Av6rO4ZOoqH2TrqbzcfadgdzqXgyoUg15afbayWwOWtOyJ)WDv6rOayux)DW7CKhk0pNiOyD7aGcVbrY0tYK1iueaGbBHcT2XdkcjOK6qH3Giu0COWEOybWHcogYHXPq7G2TrqXgxGfdeoYGcjSopekcjOK6qHeg1dNcfaJqaJDoum5qMa0dSM4Hcn4DoCOiNNek0on4DoCA8HHeus996x52cTtdENdNgFyibLuhO9QQZKbTtdENdNgFyibLuhO9QuIiqCC17CG2PbVZHtJpmKGsQd0EvCcqWCmXOdTtdENdNgFyibLuhO9QIUgm7dnzTHRHRR7akFxV76JJtJUgm7dnzTHRHRR7asXrLEKbTtdENdNgFyibLuhO9Q4JgZbKUH7QZH2PbVZHtJpmKGsQd0EvXP35aTtdENdNgFyibLuhO9Q4iYmzTjK3re7DoY3178y8FJRxe6CkhrMjRnH8oIyVZXOjA)UnH2PbVZHtJpmKGsQd0EvauIXH2PbVZHtJpmKGsQd0EvCaklxBKY3LVR3x11hhNcqjgNIJk9itgpg)346fHoNYrKzYAtiVJi27CmAIKAtODq72iOyJlWIbchzqbUepsGcVbrOWbGqHg88GIMdf6sTFv6rk0on4Do8DEm(V5ZGTq70G35WbAVQL61Q0JYpkiUtWrdhrM8l1Na3D9XXP8CTXbGgoImofhv6rMmEm(VX1lcDoLJiZK1MqEhrS35y0eTF3MaDAZm4sCCAplj(bpv6rkrCLkU(44uEhdihZ31ifhv6rMmEm(VX1lcDoLJiZK1MqEhrS35y)oWb60MzWL440Ews8dEQ0JuI4kv4X4)gxVi05uoImtwBc5DeXENJ97KbqN2mdUehN2ZsIFWtLEKsedTtdENdhO9QwQxRspk)OG4ESYy9ejFgVZrx(L6tG7YjNUXWRDKguEqz9ezc6RGTtcfhv6rMm5C9XXPSt7XWtINIJk9iRsfxFCCkdvhGu(ofhv6rMSqMplxpugQoaP8D6HGApCs3JcmYjxwuGvPICAW7COCaklxBKY3PiWIbchnEdI2q3y41osdkpOSEImb9vW2jHIJk9iJCYH2TrqHg8ohoq7vTuVwLEu(rbX9yLX6js(mENJU8l1Na3Jcm576DDJHx7inO8GY6jYe0xbBNekoQ0JmzY56JJtzN2JHNepfhv6rwLkU(44ugQoaP8DkoQ0JmzHmFwUEOmuDas570db1E4KUhfyKdTtdENdhO9QwQxRspk)OG4oO2JR9y4O8l1Na35X4)gxVi05uoImtwBc5DeXENJrtK09fa56JJtxFTdan9y0OCiHIJk9idixFCCQkXZNWrtiVJi27CO4OspYSX2ajNRpooD91oa00JrJYHekoQ0JmzU(44uEU24aqdhrgNIJk9itgpg)346fHoNYrKzYAtiVJi27CmAI2Vn5ajNRpooL3XaYX8DnsXrLEKjBvxFCCA4qmUNiddvhafhv6rMSvD9XXPSt7XWtINIJk9iJCGoTzgCjooTNLe)GNk9iLigANg8ohoq7vTuVwLEu(rbX9Oxp0KNrkFx(L6tG7S0PAuoKq9oyBprYyPtd5DeXENd17GT9ejtojI6AQg8EjAiuoL7AW2DGxPcpjEdhGES9njxMCR66JJtJbOJNGgEpreVETtcfhv6rwLkHmFwUEOXa0XtqdVNiIxV2jHEiO2dNCzYTQRpooLHQdqkFNIJk9iRsLqMplxpugQoaP8D6HGApCs3JcSkvwnK5ZY1dLHQdqkFNEiO2dVsfEm(VX1lcDoLJiZK1MqEhrS35y0eTFbqN2mdUehN2ZsIFWtLEKseto0on4DoCG2RkO)B0G35y(M7YpkiUhY8z56HdTtdENdhO9QyN2JHNeV8944DeXUj6tj93xiFaG2Z(c5dKeE046fHoFFH8D9URxe6uVbrJNgwJKUhfyY4jXB4a0JrkWH2PbVZHd0EvauIXLVR35X4)gxVi05uoImtwBc5DeXENJrtK09Tb60MzWL440Ews8dEQ0JuIyODAW7C4aTxfNaemhdtpBJE9q5769L61Q0J0Oxp0KNrkFhANg8ohoq7vXq1biLVlFxVhY8z56HYjabZXW0Z2OxpKEiO2dx2s9Av6rA0RhAYZiLVlJhJ)BC9IqNt5iYmzTjK3re7DognX9faDAZm4sCCAplj(bpv6rkrm0on4DoCG2RsJYHe5769db1E4KUhfyaPbVZHYbOSCTrkFNIalgiC04nikZ1lcDQ3GOXtdRr7jdODAW7C4aTxfXWDv6rJwx)DW7CKVR3xnKJRrDoYC9IqN6niA80WAK0DYqM3GO9lao0on4DoCG2RIDApgEs8Yh0jGVPR39oyl3CiO2dPax(UE31hhNYbOSCTbbLonGuCuPhzYwQxRspsb1ECThdhLXqjI6AkhGYY1geu60aspeu7HlJHse11uoaLLRniO0PbKEiO2dN09OaZgBdTtdENdhO9Q4auwU2iLVlFGKWJgxVi057lKVR3D9XXPCaklxBqqPtdifhv6rMSL61Q0JuqThx7XWrzmuIOUMYbOSCTbbLonG0db1E4YyOerDnLdqz5AdckDAaPhcQ9WjDhbwmq4OXBq0gBdKF6s8nEdIYwvdENdLdqz5AJu(oTht93raCODAW7C4aTxvmaD8e0W7jI41RDsKVR39geT3MaxMCHmFwUEOCcqWCmm9Sn61dPhcQ9WTFFdbELkHmFwUEOCcqWCmm9Sn61dPhcQ9WjLmixMRxe6uVbrJNgwJ2VGSAdEm(VbGYDeANg8ohoq7vTSF04ApU8Y317EdI2Va4YC9IqN6niA80WA0(9fBcTtdENdhO9QigURspA066VdENJ8D9(Ql1RvPhPeC0WrKjJNeVHdqp2oWH2PbVZHd0EvCezMS2eY7iI9oh5769L61Q0JucoA4iYKXtI3WbOhBh4q70G35WbAVQG(VrdENJ5BUl)OG4olDo0on4DoCG2RkgGoEcA49er861ojY317EdIKUBtGdTtdENdhO9Qw2pACThx(UE3BqK0fahANg8ohoq7vX0ZwdpjE5769qMplxpuobiyogME2g96H0db1E4KUytzS0PXa0XtqdVNiIxV2jHEiO2dVsfxVi0PEdIgpnSgjD7nbkkWQuHhJ)BC9IqNt5iYmzTjK3re7Dognr7xa0PnZGlXXP9SK4h8uPhPeXq70G35WbAVkj844zBprq70G35WbAVQG(VrdENJ5BUl)OG4opghgECODAW7C4aTxvq)3ObVZX8n3LFuqCVU)hpo0oODAW7C40qMplxp89407CKVR3LZ1hhNY0ZwdpjEdyZXJekoQ0JmzHmFwUEOCcqWCmm9Sn61dPeXYcz(SC9qz6zRHNepLiM8kvcz(SC9q5eGG5yy6zB0RhsjIRuX1lcDQ3GOXtdRrsT5Mq70G35WPHmFwUE4aTxfbhnTJGC5769vdz(SC9q5eGG5yy6zB0RhsjILVR3dz(SC9q5eGG5yy6zB0Rhspeu7HBpWCZkv8genEAyns62BwPICYjruxt1G3lrdHYPCxd2Ud8kv4jXB4a0JTVj5YKBvxFCCAmaD8e0W7jI41RDsO4OspYQujK5ZY1dngGoEcA49er861oj0db1E4KltUvD9XXPmuDas57uCuPhzvQeY8z56HYq1biLVtpeu7Ht6EuGvPYQHmFwUEOmuDas570db1E4KlB1qMplxpuobiyogME2g96H0db1E4KdTtdENdNgY8z56Hd0Ev19HsFMm5769vdz(SC9q5eGG5yy6zB0RhsjIH2PbVZHtdz(SC9WbAVkPptMPM4ir(UEF1qMplxpuobiyogME2g96HuIyODq70G35WPmjZH1hYbSZ7ya5y(UgL)7bnb2(cGlFxVlhlDkVJbKJ57AKEiO2dNSzPt5DmGCmFxJugXPENd5KUlhlDQgLdj0db1E4KnlDQgLdjugXPENd5YKJLoL3XaYX8Dnspeu7Ht2S0P8ogqoMVRrkJ4uVZHCs3LJLonK3re7Do0db1E4KnlDAiVJi27COmIt9ohYLXsNY7ya5y(UgPhcQ9WjLLoL3XaYX8DnszeN6Do2yb1Mq70G35WPmjZH1hYba0EvAuoKi)3dAcS9fax(UExow6unkhsOhcQ9WjBw6unkhsOmIt9ohYjDxow60qEhrS35qpeu7Ht2S0PH8oIyVZHYio17CixMCS0PAuoKqpeu7Ht2S0PAuoKqzeN6DoKt6UCS0P8ogqoMVRr6HGApCYMLoL3XaYX8DnszeN6DoKlJLovJYHe6HGApCszPt1OCiHYio17CSXcQnH2PbVZHtzsMdRpKdaO9Qc5DeXENJ8FpOjW2xaC576D5yPtd5DeXENd9qqThozZsNgY7iI9ohkJ4uVZHCs3LJLovJYHe6HGApCYMLovJYHekJ4uVZHCzYXsNgY7iI9oh6HGApCYMLonK3re7DougXPENd5KUlhlDkVJbKJ57AKEiO2dNSzPt5DmGCmFxJugXPENd5YyPtd5DeXENd9qqThoPS0PH8oIyVZHYio17CSXcQnH2bTtdENdNYsNVZrKzYAtiVJi27CKVR3zPtd5DeXENd9qqThoP7AW7COCezMS2eY7iI9ohAq5UXBqeiVbrJNgoa9yaTH0TTHClitxFCCA4qmUNiddvhafhv6rMn2KUa4KlJhJ)BC9IqNt5iYmzTjK3re7Dognr73TjqN2mdUehN2ZsIFWtLEKsedKRpooD91oa00JrJYHekoQ0JmzRYsNYrKzYAtiVJi27COhcQ9WLTQg8ohkhrMjRnH8oIyVZH2JP(7iao0on4DoCklDoq7vPr5qI8bscpAC9IqNVVq(UE31hhNgoeJ7jYWq1bqXrLEKjtdEVenS0PAuoKqkzvMRxe6uVbrJNgwJ2VytzYDiO2dN09OaRsLqMplxpuobiyogME2g96H0db1E42VytzhwFihGk9i5q70G35WPS05aTxLgLdjYhij8OX1lcD((c5769vD9XXPHdX4EImmuDauCuPhzY0G3lrdlDQgLdjKsgYC9IqN6niA80WA0(fBktUdb1E4KUhfyvQeY8z56HYjabZXW0Z2OxpKEiO2d3(fBk7W6d5auPhjhANg8ohoLLohO9Q4DmGCmFxJYhij8OX1lcD((c576D50G3lrdlDkVJbKJ57AKuYGmD9XXPHdX4EImmuDauCuPhzKjpg)346fHoNYZ1ghaA4iY4gnrYL56fHo1Bq04PH1O9l2u2H1hYbOspktUvpeu7HlJhJ)BC9IqNt5iYmzTjK3re7DognX9fvQeY8z56HYjabZXW0Z2OxpKEiO2d3EEs8goa9y2qdENdLy4Uk9OrRR)o4DoueyXaHJgVbrYH2PbVZHtzPZbAVQqEhrS35iFGKWJgxVi057lKVR35X4)gxVi05uoImtwBc5DeXENJrtKuBc0PnZGlXXP9SK4h8uPhPeXa56JJtxFTdan9y0OCiHIJk9itMChcQ9WjDpkWQujK5ZY1dLtacMJHPNTrVEi9qqThU9l2u2H1hYbOspsUmxVi0PEdIgpnSgTFXMq7G2PbVZHtR7)XJVtmCxLE0O11Fh8oh5)EqtGTVa4Y317HmFwUEOmuDas570db1E4KUhfy2yBz8y8FJRxe6CkhrMjRnH8oIyVZXOjUVaOtBMbxIJt7zjXp4PspsjILfY8z56HYjabZXW0Z2OxpKEiO2d3(T3eANg8ohoTU)hpoq7vf0)nAW7CmFZD5hfe3zsMdRpKdq(UENhJ)BC9IqNt5iYmzTjK3re7DognX9faDAZm4sCCAplj(bpv6rkrSm5yPt1OCiHEiO2dNuw6unkhsOmIt9ohBSjfyc8kvyPtd5DeXENd9qqThoPS0PH8oIyVZHYio17CSXMuGjWRuHLoL3XaYX8Dnspeu7HtklDkVJbKJ57AKYio17CSXMuGjWjxwiZNLRhkdvhGu(o9qqThoP7AW7COAuoKqJcmBSHYcz(SC9q5eGG5yy6zB0Rhspeu7HB)2BcTtdENdNw3)JhhO9Qc6)gn4DoMV5U8JcI7mjZH1hYbiFxVZJX)nUErOZPCezMS2eY7iI9ohJM4(cGoTzgCjooTNLe)GNk9iLiwwiZNLRhkNaemhdtpBJE9q6HGApCs35jXB4a0Jzdn4DounkhsOrbgqAW7COAuoKqJcmBytzYXsNQr5qc9qqThoPS0PAuoKqzeN6Do2yrLkS0PH8oIyVZHEiO2dNuw60qEhrS35qzeN6Do2yrLkS0P8ogqoMVRr6HGApCszPt5DmGCmFxJugXPENJnwqo0on4DoCAD)pECG2RIHQdqkFx(UEpK5ZY1dLtacMJHPNTrVEi9qqThU972CtGIcSkvcz(SC9q5eGG5yy6zB0Rhspeu7HB)InCtODAW7C406(F84aTxfhGYY1gP8D576DjI6AkyUebXXPeXYKiQRPthbWR1)PhcQ9WH2PbVZHtR7)XJd0EvAuoKiFxVlruxtbZLiiooLiw2QY56JJt5DmGCmFxJuCuPhzYKl(WLMOaJUGQr5qIS4dxAIcm62unkhsKfF4stuGrTjvJYHeYRuj(WLMOaJUGQr5qc5q70G35WP19)4XbAVkEhdihZ31O8D9UerDnfmxIG44uIyzRkx8HlnrbgDbL3XaYX8Dnkl(WLMOaJUnL3XaYX8Dnkl(WLMOaJAtkVJbKJ57AKCODAW7C406(F84aTxviVJi27CKVR3LiQRPG5seehNselB14dxAIcm6cAiVJi27CKTQRpoovL45t4OjK3re7DouCuPhzq70G35WP19)4XbAVk2P9y(UgLVR3LtIOUM2dUSDv6rddbBos5UgS1(DYa4KPC8y8FJRxe6CkhrMjRnH8oIyVZXOjsMN2mdUehN2ZsIFWtLEKseB)2KBJT3uMCHmFwUEOmuDas570db1E42JalgiC04niwPYQU(44ugQoaP8DkoQ0JmYLjxiZNLRhAmaD8e0W7jI41RDsOhcQ9WThbwmq4OXBqSsLvD9XXPXa0XtqdVNiIxV2jHIJk9iJCzYfY8z56HY0ZwdpjE6HGApC7rGfdeoA8geRuzvxFCCktpBn8K4nGnhpsO4OspYixMCHmFwUEOl7hnU2Jtpeu7HBpcSyGWrJ3GyLkR66JJtx2pACThNIJk9iJCzHmFwUEOCcqWCmm9Sn61dPhcQ9WThbwmq4OXBqeOfBwPIerDnThCz7Q0Jggc2CKYDnyR92CtzUErOt9genEAyns6(InjhANg8ohoTU)hpoq7vbqjghANg8ohoTU)hpoq7vXoThdpjE57XX7iIDt0Ns6VVq(aaTN9fY3JJ3re77lKpqs4rJRxe689fY317UErOt9genEAyns6EuGbTtdENdNw3)JhhO9QyN2JHNeV8baAp7lKVhhVJi2nD9U3bB5Mdb1Eif4Y3JJ3re7MOpL0FFH8D9URpooLdqz5AdckDAaP4OspYKTuVwLEKcQ94ApgokBvgkruxt5auwU2GGsNgq6HGApCODAW7C406(F84aTxf70Em8K4Lpaq7zFH8944DeXUPR39oyl3CiO2dPax(EC8oIy3e9PK(7lKVR3D9XXPCaklxBqqPtdifhv6rMSL61Q0JuqThx7XWrODAW7C406(F84aTxf70Em8K4LVhhVJi2nrFkP)(c5da0E2xiFpoEhrSVVaANg8ohoTU)hpoq7vXbOSCTrkFx(ajHhnUErOZ3xiFxV76JJt5auwU2GGsNgqkoQ0Jmzl1RvPhPGApU2JHJYwLHse11uoaLLRniO0PbKEiO2dx2QAW7COCaklxBKY3P9yQ)ocGdTtdENdNw3)JhhO9Q4auwU2iLVlFxV76JJt5auwU2GGsNgqkoQ0Jmzl1RvPhPGApU2JHJq70G35WP19)4XbAVkoaLLRns57q7G2PbVZHt5X4WWJVtmCxLE0O11Fh8oh5769qMplxpuobiyogME2g96H0db1E4KUZtI3WbOhZgiWIbchnEdIYKBvxFCCkdvhGu(ofhv6rwLkHmFwUEOmuDas570db1E4KUZtI3WbOhZgiWIbchnEdIKdTtdENdNYJXHHhhO9Qc6)gn4DoMV5U8JcI719)4XLVR3LlK5ZY1dLtacMJHPNTrVEi9qqThoPEdIgpnCa6XSHCKvYKNeVHdqpg5vQeY8z56HYjabZXW0Z2OxpKsetUmVbrJNgwJ2hY8z56HYjabZXW0Z2OxpKEiO2dhANg8ohoLhJddpoq7vXrKzYAtiVJi27CKVR3xQxRspsj4OHJidANg8ohoLhJddpoq7vrmCxLE0O11Fh8oh5769vxQxRspsj4OHJit2QXhU0efy0fuobiyogME2g96HYKZ1hhNYq1biLVtXrLEKjlK5ZY1dLHQdqkFNEiO2dN0DeyXaHJgVbrzRQBm8AhPbLhuwprMG(ky7KqXrLEKvPIC8K4nCa6XSFh4Y4X4)gxVi05uoImtwBc5DeXENJrtK0TRuHNeVHdqpM97BlJhJ)BC9IqNt5iYmzTjK3re7Dognr733MCzUErOt9genEAynA)gcecSyGWrJ3GOmEm(VX1lcDoLJiZK1MqEhrS35y0e3xuPIRxe6uVbrJNgwJKUtgaHalgiC04niAdEs8goa9yKdTtdENdNYJXHHhhO9QigURspA066VdENJ8D9(Ql1RvPhPeC0WrKjlKJRrDoKUhuUB8gebAPETk9inwzSEIG2PbVZHt5X4WWJd0Eved3vPhnAD93bVZr(ajHhnUErOZ3xiFxVV6s9Av6rkbhnCezYKBvxFCCkdvhGu(ofhv6rwLkHmFwUEOmuDas570db1E427niA80WbOhRsfEs8goa9y2VGCzYTQRpooDz)OX1ECkoQ0JSkv4jXB4a0Jz)cYLfYX1Oohs3dk3nEdIaTuVwLEKgRmwprYKBvDJHx7inO8GY6jYe0xbBNekoQ0JSkvKiQRPbLhuwprMG(ky7Kqpeu7HBV3GOXtdhGEmYlwlXJ35uQE7nxqgl2CBYGUTn3qGzXATEtpr8I1gpW48CKbfatOqdENdu8n35uODfRV5oVSsXIjzoS(qoGYkLQxuwPyHJk9iRSvXsdENtXI3XaYX8DnwScx741AXsoOGLoL3XaYX8Dnspeu7HdfKnuWsNY7ya5y(UgPmIt9ohOGCOG0DOqoOGLovJYHe6HGApCOGSHcw6unkhsOmIt9ohOGCOqguihuWsNY7ya5y(UgPhcQ9WHcYgkyPt5DmGCmFxJugXPENduqouq6ouihuWsNgY7iI9oh6HGApCOGSHcw60qEhrS35qzeN6Doqb5qHmOGLoL3XaYX8Dnspeu7HdfKcfS0P8ogqoMVRrkJ4uVZbkSbuSGAZI13dAcSI1cGx8s1BxwPyHJk9iRSvXsdENtXsJYHKIv4AhVwlwYbfS0PAuoKqpeu7HdfKnuWsNQr5qcLrCQ35afKdfKUdfYbfS0PH8oIyVZHEiO2dhkiBOGLonK3re7DougXPENduqouidkKdkyPt1OCiHEiO2dhkiBOGLovJYHekJ4uVZbkihkiDhkKdkyPt5DmGCmFxJ0db1E4qbzdfS0P8ogqoMVRrkJ4uVZbkihkKbfS0PAuoKqpeu7HdfKcfS0PAuoKqzeN6DoqHnGIfuBwS(EqtGvSwa8IxQ2MLvkw4OspYkBvS0G35uSc5DeXENtXkCTJxRfl5Gcw60qEhrS35qpeu7HdfKnuWsNgY7iI9ohkJ4uVZbkihkiDhkKdkyPt1OCiHEiO2dhkiBOGLovJYHekJ4uVZbkihkKbfYbfS0PH8oIyVZHEiO2dhkiBOGLonK3re7DougXPENduqouq6ouihuWsNY7ya5y(UgPhcQ9WHcYgkyPt5DmGCmFxJugXPENduqouidkyPtd5DeXENd9qqThouqkuWsNgY7iI9ohkJ4uVZbkSbuSGAZI13dAcSI1cGx8IxSyyTs8EzLs1lkRuS0G35uS4X4)Mpd2wSWrLEKv2Q4LQ3USsXchv6rwzRI1s9jWILRpooLNRnoa0WrKXP4OspYGczqbpg)346fHoNYrKzYAtiVJi27CmAIqH97qHnHcGGItBMbxIJt7zjXp4PspsjIHIkvGcxFCCkVJbKJ57AKIJk9idkKbf8y8FJRxe6CkhrMjRnH8oIyVZbkSFhkaouaeuCAZm4sCCAplj(bpv6rkrmuuPcuWJX)nUErOZPCezMS2eY7iI9ohOW(DOGmGcGGItBMbxIJt7zjXp4PspsjIlwAW7Ckwl1RvPhlwl1ZmkiwSi4OHJiR4LQTzzLIfoQ0JSYwfRmUyXrVyPbVZPyTuVwLESyTuFcSyjhuihuOBm8AhPbLhuwprMG(ky7KqXrLEKbfYGc5GcxFCCk70Em8K4P4OspYGIkvGcxFCCkdvhGu(ofhv6rguidkcz(SC9qzO6aKY3PhcQ9WHcs3HIOadkihkihkKbfrbguuPcuihuObVZHYbOSCTrkFNIalgiC04nicf2ak0ngETJ0GYdkRNitqFfSDsO4OspYGcYHcYlwl1ZmkiwSIvgRNOIxQEdlRuSWrLEKv2QyTuFcSyXJX)nUErOZPCezMS2eY7iI9ohJMiuq6ouSakackC9XXPRV2bGMEmAuoKqXrLEKbfabfU(44uvINpHJMqEhrS35qXrLEKbf2ak2gkackKdkC9XXPRV2bGMEmAuoKqXrLEKbfYGcxFCCkpxBCaOHJiJtXrLEKbfYGcEm(VX1lcDoLJiZK1MqEhrS35y0eHc7HITHcYHcGGc5GcxFCCkVJbKJ57AKIJk9idkKbfRcfU(440WHyCprggQoakoQ0JmOqguSku46JJtzN2JHNepfhv6rguqouaeuCAZm4sCCAplj(bpv6rkrCXsdENtXAPETk9yXAPEMrbXIfO2JR9y4yXlvd8YkflCuPhzLTkwl1NalwS0PAuoKq9oyBprqHmOGLonK3re7DouVd22teuidkKdkKiQRPAW7LOHq5uURbBHIDOa4qrLkqbpjEdhGEmOyhk2ekihkKbfYbfRcfU(440ya64jOH3teXRx7KqXrLEKbfvQafHmFwUEOXa0XtqdVNiIxV2jHEiO2dhkihkKbfYbfRcfU(44ugQoaP8DkoQ0JmOOsfOiK5ZY1dLHQdqkFNEiO2dhkiDhkIcmOOsfOyvOiK5ZY1dLHQdqkFNEiO2dhkQubk4X4)gxVi05uoImtwBc5DeXENJrtekShkwafabfN2mdUehN2ZsIFWtLEKsedfKxS0G35uSwQxRspwSwQNzuqSyf96HM8ms57fVunzTSsXchv6rwzRILg8oNIvq)3ObVZX8n3lwFZDZOGyXkK5ZY1dV4LQbMLvkw4OspYkBvS0G35uSyN2JHNeFXkqs4rJRxe68s1lkwHRD8ATy56fHo1Bq04PH1iuq6ouefyqHmOGNeVHdqpguqkua8IvaG2tXArXQhhVJi2nrFkPFXArXlvtgLvkw4OspYkBvScx741AXIhJ)BC9IqNt5iYmzTjK3re7DognrOG0DOyBOaiO40MzWL440Ews8dEQ0JuI4ILg8oNIfaLy8IxQEdQSsXchv6rwzRIv4AhVwlwl1RvPhPrVEOjpJu(EXsdENtXItacMJHPNTrVEyXlvVyZYkflCuPhzLTkwHRD8ATyfY8z56HYjabZXW0Z2OxpKEiO2dhkKbfl1RvPhPrVEOjpJu(ouidk4X4)gxVi05uoImtwBc5DeXENJrtek2HIfqbqqXPnZGlXXP9SK4h8uPhPeXfln4DoflgQoaP89IxQEXIYkflCuPhzLTkwHRD8ATyDiO2dhkiDhkIcmOaiOqdENdLdqz5AJu(ofbwmq4OXBqekKbfUErOt9genEAyncf2dfKrXsdENtXsJYHKIxQEX2Lvkw4OspYkBvScx741AXAvOiKJRrDoqHmOW1lcDQ3GOXtdRrOG0DOGmGczqH3GiuypuSa4fln4DoflIH7Q0JgTU(7G35u8s1lSzzLIfoQ0JSYwfln4Dofl2P9y4jXxScx741AXY1hhNYbOSCTbbLonGuCuPhzqHmOyPETk9ifu7X1EmCekKbfmuIOUMYbOSCTbbLonG0db1E4qHmOGHse11uoaLLRniO0PbKEiO2dhkiDhkIcmOWgqX2fRGob8nDDXY7GTCZHGApKc8IxQEXgwwPyHJk9iRSvXsdENtXIdqz5AJu(EXkCTJxRflxFCCkhGYY1geu60asXrLEKbfYGIL61Q0JuqThx7XWrOqguWqjI6AkhGYY1geu60aspeu7HdfYGcgkruxt5auwU2GGsNgq6HGApCOG0DOabwmq4OXBqekSbuSnuaeu4NUeFJ3Giuidkwfk0G35q5auwU2iLVt7Xu)DeaVyfij8OX1lcDEP6ffVu9cGxwPyHJk9iRSvXkCTJxRflVbrOWEOWMahkKbfYbfHmFwUEOCcqWCmm9Sn61dPhcQ9WHc73HIne4qrLkqriZNLRhkNaemhdtpBJE9q6HGApCOGuOGmGcYHczqHRxe6uVbrJNgwJqH9qXcYkuydOGhJ)BaOChlwAW7CkwXa0XtqdVNiIxV2jP4LQxqwlRuSWrLEKv2QyfU2XR1IL3GiuypuSa4qHmOW1lcDQ3GOXtdRrOW(DOyXMfln4DofRL9Jgx7XlEP6faZYkflCuPhzLTkwHRD8ATyTkuSuVwLEKsWrdhrguidk4jXB4a0Jbf7qbWlwAW7Ckwed3vPhnAD93bVZP4LQxqgLvkw4OspYkBvScx741AXAPETk9iLGJgoImOqguWtI3WbOhdk2HcGxS0G35uS4iYmzTjK3re7DofVu9InOYkflCuPhzLTkwAW7Ckwb9FJg8ohZ3CVy9n3nJcIflw68IxQE7nlRuSWrLEKv2QyfU2XR1IL3Giuq6ouytGxS0G35uSIbOJNGgEpreVETtsXlvV9IYkflCuPhzLTkwHRD8ATy5nicfKcflaEXsdENtXAz)OX1E8IxQE7TlRuSWrLEKv2QyfU2XR1IviZNLRhkNaemhdtpBJE9q6HGApCOGuOyXMqHmOGLongGoEcA49er861oj0db1E4qrLkqHRxe6uVbrJNgwJqbPqX2BcfabfrbguuPcuWJX)nUErOZPCezMS2eY7iI9ohJMiuypuSakackoTzgCjooTNLe)GNk9iLiUyPbVZPyX0Zwdpj(IxQEBBwwPyPbVZPyjHhhpB7jQyHJk9iRSvXlvV9gwwPyHJk9iRSvXsdENtXkO)B0G35y(M7fRV5UzuqSyXJXHHhV4LQ3g4Lvkw4OspYkBvS0G35uSc6)gn4DoMV5EX6BUBgfelw19)4XlEXlwXhgsqj1lRuQErzLIfoQ0JSYwfVu92Lvkw4OspYkBv8s12SSsXchv6rwzRIxQEdlRuS0G35uS4eGG5yQXhaX44vSWrLEKv2Q4LQbEzLIfoQ0JSYwfRW1oETwSC9XXPrxdM9HMS2W1W11DaP4OspYkwAW7CkwrxdM9HMS2W1W11DalEPAYAzLIfoQ0JSYwfVunWSSsXsdENtXko9oNIfoQ0JSYwfVunzuwPyHJk9iRSvXkCTJxRflEm(VX1lcDoLJiZK1MqEhrS35y0eHc73HcBwS0G35uS4iYmzTjK3re7DofVu9guzLILg8oNIfaLy8IfoQ0JSYwfVu9InlRuSWrLEKv2QyfU2XR1I1QqHRpoofGsmofhv6rguidk4X4)gxVi05uoImtwBc5DeXENJrtekifkSzXsdENtXIdqz5AJu(EXlEXkK5ZY1dVSsP6fLvkw4OspYkBvScx741AXsoOW1hhNY0ZwdpjEdyZXJekoQ0JmOqgueY8z56HYjabZXW0Z2OxpKsedfYGIqMplxpuME2A4jXtjIHcYHIkvGIqMplxpuobiyogME2g96HuIyOOsfOW1lcDQ3GOXtdRrOGuOWMBwS0G35uSItVZP4LQ3USsXchv6rwzRIv4AhVwlwHmFwUEOCcqWCmm9Sn61dPhcQ9WHc7HcG5MqrLkqH3GOXtdRrOGuOy7nHIkvGc5Gc5GcjI6AQg8EjAiuoL7AWwOyhkaouuPcuWtI3WbOhdk2HInHcYHczqHCqXQqHRpoongGoEcA49er861ojuCuPhzqrLkqriZNLRhAmaD8e0W7jI41RDsOhcQ9WHcYHczqHCqXQqHRpooLHQdqkFNIJk9idkQubkcz(SC9qzO6aKY3PhcQ9WHcs3HIOadkQubkwfkcz(SC9qzO6aKY3PhcQ9WHcYHczqXQqriZNLRhkNaemhdtpBJE9q6HGApCOG8ILg8oNIfbhnTJG8IxQ2MLvkw4OspYkBvScx741AXAvOiK5ZY1dLtacMJHPNTrVEiLiUyPbVZPyv3hk9zYkEP6nSSsXchv6rwzRIv4AhVwlwRcfHmFwUEOCcqWCmm9Sn61dPeXfln4DoflPptMPM4iP4fVyXJXHHhVSsP6fLvkw4OspYkBvScx741AXkK5ZY1dLtacMJHPNTrVEi9qqThouq6ouWtI3WbOhdkSbuGalgiC04nicfYGc5GIvHcxFCCkdvhGu(ofhv6rguuPcueY8z56HYq1biLVtpeu7HdfKUdf8K4nCa6XGcBafiWIbchnEdIqb5fln4DoflIH7Q0JgTU(7G35u8s1BxwPyHJk9iRSvXkCTJxRfl5GIqMplxpuobiyogME2g96H0db1E4qbPqH3GOXtdhGEmOWgqHCqbzfkitOGNeVHdqpguqouuPcueY8z56HYjabZXW0Z2OxpKsedfKdfYGcVbrJNgwJqH9qriZNLRhkNaemhdtpBJE9q6HGAp8ILg8oNIvq)3ObVZX8n3lwFZDZOGyXQU)hpEXlvBZYkflCuPhzLTkwHRD8ATyTuVwLEKsWrdhrwXsdENtXIJiZK1MqEhrS35u8s1ByzLIfoQ0JSYwfRW1oETwSwfkwQxRspsj4OHJidkKbfRcfXhU0efy0fuobiyogME2g96HqHmOqoOW1hhNYq1biLVtXrLEKbfYGIqMplxpugQoaP8D6HGApCOG0DOabwmq4OXBqekKbfRcf6gdV2rAq5bL1tKjOVc2ojuCuPhzqrLkqHCqbpjEdhGEmOW(DOa4qHmOGhJ)BC9IqNt5iYmzTjK3re7DognrOGuOyBOOsfOGNeVHdqpguy)ouSnuidk4X4)gxVi05uoImtwBc5DeXENJrtekSFhk2gkihkKbfUErOt9genEAyncf2dfBiuaeuGalgiC04nicfYGcEm(VX1lcDoLJiZK1MqEhrS35y0eHIDOybuuPcu46fHo1Bq04PH1iuq6ouqgqbqqbcSyGWrJ3GiuydOGNeVHdqpguqEXsdENtXIy4Uk9OrRR)o4DofVunWlRuSWrLEKv2QyfU2XR1I1QqXs9Av6rkbhnCezqHmOiKJRrDoqbP7qrq5UXBqekackwQxRspsJvgRNOILg8oNIfXWDv6rJwx)DW7CkEPAYAzLIfoQ0JSYwfln4DoflIH7Q0JgTU(7G35uScx741AXAvOyPETk9iLGJgoImOqguihuSku46JJtzO6aKY3P4OspYGIkvGIqMplxpugQoaP8D6HGApCOWEOWBq04PHdqpguuPcuWtI3WbOhdkShkwafKdfYGc5GIvHcxFCC6Y(rJR94uCuPhzqrLkqbpjEdhGEmOWEOybuqouidkc54AuNduq6oueuUB8geHcGGIL61Q0J0yLX6jckKbfYbfRcf6gdV2rAq5bL1tKjOVc2ojuCuPhzqrLkqHerDnnO8GY6jYe0xbBNe6HGApCOWEOWBq04PHdqpguqEXkqs4rJRxe68s1lkEXlw19)4XlRuQErzLIfoQ0JSYwfln4DoflIH7Q0JgTU(7G35uScx741AXkK5ZY1dLHQdqkFNEiO2dhkiDhkIcmOWgqX2qHmOGhJ)BC9IqNt5iYmzTjK3re7DognrOyhkwafabfN2mdUehN2ZsIFWtLEKsedfYGIqMplxpuobiyogME2g96H0db1E4qH9qX2BwS(EqtGvSwa8IxQE7YkflCuPhzLTkwHRD8ATyXJX)nUErOZPCezMS2eY7iI9ohJMiuSdflGcGGItBMbxIJt7zjXp4PspsjIHczqHCqblDQgLdj0db1E4qbPqblDQgLdjugXPENduydOytkWe4qrLkqblDAiVJi27COhcQ9WHcsHcw60qEhrS35qzeN6DoqHnGInPatGdfvQafS0P8ogqoMVRr6HGApCOGuOGLoL3XaYX8DnszeN6DoqHnGInPatGdfKdfYGIqMplxpugQoaP8D6HGApCOG0DOqdENdvJYHeAuGbf2ak2qOqgueY8z56HYjabZXW0Z2OxpKEiO2dhkShk2EZILg8oNIvq)3ObVZX8n3lwFZDZOGyXIjzoS(qoGIxQ2MLvkw4OspYkBvScx741AXIhJ)BC9IqNt5iYmzTjK3re7DognrOyhkwafabfN2mdUehN2ZsIFWtLEKsedfYGIqMplxpuobiyogME2g96H0db1E4qbP7qbpjEdhGEmOWgqHg8ohQgLdj0Oadkack0G35q1OCiHgfyqHnGcBcfYGc5Gcw6unkhsOhcQ9WHcsHcw6unkhsOmIt9ohOWgqXcOOsfOGLonK3re7Do0db1E4qbPqblDAiVJi27COmIt9ohOWgqXcOOsfOGLoL3XaYX8Dnspeu7HdfKcfS0P8ogqoMVRrkJ4uVZbkSbuSakiVyPbVZPyf0)nAW7CmFZ9I13C3mkiwSysMdRpKdO4LQ3WYkflCuPhzLTkwHRD8ATyfY8z56HYjabZXW0Z2OxpKEiO2dhkSFhkS5MqbqqruGbfvQafHmFwUEOCcqWCmm9Sn61dPhcQ9WHc7HIfB4Mfln4DoflgQoaP89IxQg4Lvkw4OspYkBvScx741AXsIOUMcMlrqCCkrmuidkKiQRPthbWR1)PhcQ9WlwAW7CkwCaklxBKY3lEPAYAzLIfoQ0JSYwfRW1oETwSKiQRPG5seehNsedfYGIvHc5GcxFCCkVJbKJ57AKIJk9idkKbfYbfXhU0efy0funkhsGczqr8HlnrbgDBQgLdjqHmOi(WLMOaJAtQgLdjqb5qrLkqr8HlnrbgDbvJYHeOG8ILg8oNILgLdjfVunWSSsXchv6rwzRIv4AhVwlwse11uWCjcIJtjIHczqXQqHCqr8HlnrbgDbL3XaYX8DncfYGI4dxAIcm62uEhdihZ31iuidkIpCPjkWO2KY7ya5y(UgHcYlwAW7Ckw8ogqoMVRXIxQMmkRuSWrLEKv2QyfU2XR1ILerDnfmxIG44uIyOqguSkueF4stuGrxqd5DeXENduidkwfkC9XXPQepFchnH8oIyVZHIJk9iRyPbVZPyfY7iI9oNIxQEdQSsXchv6rwzRIv4AhVwlwYbfse110EWLTRspAyiyZrk31GTqH97qbzaCOGmHc5GcEm(VX1lcDoLJiZK1MqEhrS35y0eHcYekoTzgCjooTNLe)GNk9iLigkShk2gkihkSbuS9MqHmOqoOiK5ZY1dLHQdqkFNEiO2dhkShkqGfdeoA8geHIkvGIvHcxFCCkdvhGu(ofhv6rguqouidkKdkcz(SC9qJbOJNGgEpreVETtc9qqThouypuGalgiC04nicfvQafRcfU(440ya64jOH3teXRx7KqXrLEKbfKdfYGc5GIqMplxpuME2A4jXtpeu7Hdf2dfiWIbchnEdIqrLkqXQqHRpooLPNTgEs8gWMJhjuCuPhzqb5qHmOqoOiK5ZY1dDz)OX1EC6HGApCOWEOabwmq4OXBqekQubkwfkC9XXPl7hnU2JtXrLEKbfKdfYGIqMplxpuobiyogME2g96H0db1E4qH9qbcSyGWrJ3GiuaeuSytOOsfOqIOUM2dUSDv6rddbBos5UgSfkShkS5MqHmOW1lcDQ3GOXtdRrOG0DOyXMqb5fln4Dofl2P9y(UglEP6fBwwPyPbVZPybqjgVyHJk9iRSvXlvVyrzLIfoQ0JSYwfln4Dofl2P9y4jXxScKeE046fHoVu9IIvpoEhrSxSwuScx741AXY1lcDQ3GOXtdRrOG0DOikWkwbaApfRffREC8oIy3e9PK(fRffVu9ITlRuSWrLEKv2QyfaO9uSwuS6XX7iIDtxxS8oyl3CiO2dPaVyfU2XR1ILRpooLdqz5AdckDAaP4OspYGczqXs9Av6rkO2JR9y4iuidkwfkyOerDnLdqz5AdckDAaPhcQ9WlwAW7CkwSt7XWtIVy1JJ3re7MOpL0VyTO4LQxyZYkflCuPhzLTkwbaApfRffREC8oIy301flVd2YnhcQ9qkWlwHRD8ATy56JJt5auwU2GGsNgqkoQ0JmOqguSuVwLEKcQ94ApgowS0G35uSyN2JHNeFXQhhVJi2nrFkPFXArXlvVydlRuSWrLEKv2QyPbVZPyXoThdpj(IvpoEhrSxSwuSca0Ekwlkw944DeXUj6tj9lwlkEP6faVSsXchv6rwzRILg8oNIfhGYY1gP89Iv4AhVwlwU(44uoaLLRniO0PbKIJk9idkKbfl1RvPhPGApU2JHJqHmOyvOGHse11uoaLLRniO0PbKEiO2dhkKbfRcfAW7COCaklxBKY3P9yQ)ocGxScKeE046fHoVu9IIxQEbzTSsXchv6rwzRIv4AhVwlwU(44uoaLLRniO0PbKIJk9idkKbfl1RvPhPGApU2JHJfln4DofloaLLRns57fVu9cGzzLILg8oNIfhGYY1gP89IfoQ0JSYwfV4flw68YkLQxuwPyHJk9iRSvXkCTJxRflw60qEhrS35qpeu7HdfKUdfAW7COCezMS2eY7iI9ohAq5UXBqekack8genEA4a0JbfabfBiDBOWgqHCqXcOGmHcxFCCA4qmUNiddvhafhv6rguydOyt6cGdfKdfYGcEm(VX1lcDoLJiZK1MqEhrS35y0eHc73HcBcfabfN2mdUehN2ZsIFWtLEKsedfabfU(4401x7aqtpgnkhsO4OspYGczqXQqblDkhrMjRnH8oIyVZHEiO2dhkKbfRcfAW7COCezMS2eY7iI9ohApM6VJa4fln4DofloImtwBc5DeXENtXlvVDzLIfoQ0JSYwfln4DoflnkhskwHRD8ATy56JJtdhIX9ezyO6aO4OspYGczqHg8EjAyPt1OCibkifkiRqHmOW1lcDQ3GOXtdRrOWEOyXMqHmOqoO4qqThouq6ouefyqrLkqriZNLRhkNaemhdtpBJE9q6HGApCOWEOyXMqHmO4W6d5auPhHcYlwbscpAC9IqNxQErXlvBZYkflCuPhzLTkwAW7CkwAuoKuScx741AXAvOW1hhNgoeJ7jYWq1bqXrLEKbfYGcn49s0WsNQr5qcuqkuqgqHmOW1lcDQ3GOXtdRrOWEOyXMqHmOqoO4qqThouq6ouefyqrLkqriZNLRhkNaemhdtpBJE9q6HGApCOWEOyXMqHmO4W6d5auPhHcYlwbscpAC9IqNxQErXlvVHLvkw4OspYkBvS0G35uS4DmGCmFxJfRW1oETwSKdk0G3lrdlDkVJbKJ57AekifkidOGmHcxFCCA4qmUNiddvhafhv6rguqMqbpg)346fHoNYZ1ghaA4iY4gnrOGCOqgu46fHo1Bq04PH1iuypuSytOqguCy9HCaQ0JqHmOqoOyvO4qqThouidk4X4)gxVi05uoImtwBc5DeXENJrtek2HIfqrLkqriZNLRhkNaemhdtpBJE9q6HGApCOWEOGNeVHdqpguydOqdENdLy4Uk9OrRR)o4DoueyXaHJgVbrOG8IvGKWJgxVi05LQxu8s1aVSsXchv6rwzRILg8oNIviVJi27CkwHRD8ATyXJX)nUErOZPCezMS2eY7iI9ohJMiuqkuytOaiO40MzWL440Ews8dEQ0JuIyOaiOW1hhNU(AhaA6XOr5qcfhv6rguidkKdkoeu7HdfKUdfrbguuPcueY8z56HYjabZXW0Z2OxpKEiO2dhkShkwSjuidkoS(qoav6rOGCOqgu46fHo1Bq04PH1iuypuSyZIvGKWJgxVi05LQxu8Ix8ILs4aYRyz1GBGfV4Lc]] )
    

end