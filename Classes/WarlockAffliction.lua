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
    end)
    

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

            copy = "summon_pet"
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


    spec:RegisterPack( "Affliction", 20180914.1015, [[dm0dabqibPhjiQnHugLGYPeuTkvs1RqQmlOQULivzxI6xqvgMiPJrsTmvsEgurttKkxtQQSnrQQVjiOXPskNtqiRtqKMNuvUNuSpsshuQQQfks5Hcc0ffekDsbHkRePQzkiu1nfek2jjXqferlvqeEkuMQiXxfeWEj8xIgmPomLfJKhJYKf6YGnlIplWOvPoTKxdvA2Q62Qy3k9BfdxQSCiphvtNQRtITlL8DvIXdv48svwVuvL5lLA)iwOwKIalAoiu5QuvFTudrQtxwDQQt)0fcfyEVoqG1zmCTaqGT2bey9FsYxmVMvG1z9(XIIuey8rbXab2T7D8qkE4fu(TcvMnh841r5nVMLHSehpEDy4r9dfEujw6fHw41HMK6boEPua6k14LYvQLHag6hgUY(pj5lMxZM51HjWOuQ3dXTckbw0CqOYvPQ(APgIuNUS6uvRoDPVaJ3bmHkxL(9tGfbotGfYeD)NK8fZRzj6qad9ddxc9HmrF7EhpKIhEbLFRqLzZbpEDuEZRzzilXXJxhgEu)qHhvILErOfEDOjPEGJxijccjSkYXlKmKqgcyOFy4k7)KKVyEnBMxhgH(qMOXGohouaIOvNo8j6Rsv91i60JOvNAivDQeD)hIHqpH(qMOdbVTna4Huc9HmrNEeD)hJqKOX6G)j6q8dd3mH(qMOtpIoe822ais0UHcaxwjeTpenRh7bPBOaW5zbwhAsQheyHmr3)jjFX8AwIoeWq)WWLqFit03U3XdP4Hxq53kuz2CWJxhL38AwgYsC841HHh1pu4rLyPxeAHxhAsQh44fsIGqcRIC8cjdjKHag6hgUY(pj5lMxZM51HrOpKjAmOZHdfGiA1PdFI(QuvFnIo9iA1PgsvNkr3)Hyi0tOpKj6qWBBdaEiLqFit0Phr3)XiejASo4FIoe)WWntOpKj60JOdbVTnaIeTBOaWLvcr7drZ6XEq6gkaCEMqpH(qMOdXIdGP4qKOPGKbbenBouMt0uqqT8mr3)mg05CIENn9Un0jr5jAJ51SCIE2VxMqVX8AwEUdbS5qzEtYBCCj0BmVMLN7qaBouMtxdEjZej0BmVMLN7qaBouMtxdEMsWbw38Awc9gZRz55oeWMdL501Ghx5CMv2boHEJ51S8ChcyZHYC6AWlavNPqGCsKCJHQKIb4xjnU9W65auDMcbYjrYngQskgKH1OEisO3yEnlp3Ha2COmNUg84R1XVhxYDZ5e6nMxZYZDiGnhkZPRbVUXRzj0BmVMLN7qaBouMtxdECaIYjrYgesPZRzXVsA4DW)s3qbGZZCaIYjrYgesPZRzL2aQ2Gtc9gZRz55oeWMdL501G3TPSoHEJ51S8ChcyZHYC6AWJFBX5IKAEh)kPju3Ey98TPSEgwJ6HinEh8V0nua48mhGOCsKSbHu68AwPnqF4KqpH(qMOdXIdGP4qKOHwaQhr71biA)giAJ5dIOlorBTS6nQhYe6nMxZYBAzOYOEa)1oqdVZohJ6bjhGi(TSxbAC7H1Z85I0VbjhGipdRr9qKgVd(x6gkaCEMdquojs2GqkDEnR0gq1gC2UTBpSEMxD3Zk)kbYWAupePX7G)LUHcaNN5aeLtIKniKsNxZQAt)A3M3b)lDdfaopZbikNejBqiLoVMv1MRrO3yEnlNUg8AzOYOEa)1oqtNfJ1gG)01Wbh)w2RangZRzZ8BloxKuZ7zahatXbPxh46w)bOYHmZ4mlwBGKzVDkVxgwJ6HiHEJ51SC6AWRLHkJ6b8x7anDwmwBa(txdc4GJFl7vGMawe)kPX6pavoKzgNzXAdKm7Tt59YWAupePfMBpSEoISAL8r5ZWAupeB32ThwphbZVPM3ZWAupePXM5JZLnhbZVPM3Zi4y1Y7RjGfdNqVX8AwoDn4X7G)L)WWLqVX8AwoDn41nEnl(vstyU9W65OHWvYhLxEkoG6LH1OEisJnZhNlBMRCoZkJgc3G3qqwPJgBMpox2C0q4k5JYNv6cVDB2mFCUSzUY5mRmAiCdEdbzLU2TDdfaE2Rdi9rglOpCMkHEJ51SC6AWtHdYYHdh)kPju2mFCUSzUY5mRmAiCdEdbzLoc9gZRz501GxsHaQFMi(vstOSz(4CzZCLZzwz0q4g8gcYkDe6nMxZYPRbpQFMOmrb1d)kPju2mFCUSzUY5mRmAiCdEdbzLoc9gZRz501Gxez1k5JYJFToGqkDUm4hk7BuJp72QTrn(SEShKUHcaN3Og)kPXnua4zVoG0hzSG(AcyrA8r5L8Bdf7RFe6nMxZYPRbVBtzDc9gZRz501Ghx5CMvgneUbVHa8RKM44zly2EzVy4wBaT44z2GqkDEnB2lgU1gqlmkLKKSX8QfivmEM7gd3M(1UnFuEj)2qXMudNwyH62dRN7UT1NJKxBGYBOY7LH1OEi2UnBMpox2C3TT(CK8AduEdvEVmcowT8Wj0BmVMLtxdEwWS9WN1J9G0nua48g14xjni4y1Y7RjGfj0BmVMLtxdE8BloxKuZ74Z6XEq6gkaCEJA8RKg3Ey9m)2IZfjCOqgdYWAupeP52dRNnk(8koizdcP051SzynQhI0mMxTajSWPaEZv0IaLsssMFBX5IeouiJbzeCSA50IaLsssMFBX5IeouiJbzeCSA591a4aykoi96ax)k6CK1cEPxhGwOgZRzZ8BloxKuZ75ALjFfC7e6nMxZYPRbVUBB95i51gO8gQ8E4xjnEDavtxQ0cJnZhNlBMRCoZkJgc3G3qqgbhRwUQnPRFTBZM5JZLnZvoNzLrdHBWBiiJGJvlVVRfoHEJ51SC6AWRv9G0TAD8RKgVoGQxLkHEJ51SC6AWJdquojs2GqkDEnl(vstC8mBqiLoVMnJGJvlVVgJ51Szoar5KizdcP051SzMXDPxhGoVoG0hj)2qr6sx(QRhM60ZThwpZqa0vBGmcMFNH1OEiE9uZQ7x404DW)s3qbGZZCaIYjrYgesPZRzL2aQ2Gt6C7H1ZxqLFdYALwWS9YWAupePfAC8mhGOCsKSbHu68A2mcowTCAHAmVMnZbikNejBqiLoVMnxRm5RGBNqVX8AwoDn4zbZ2dFwp2ds3qbGZBuJ)XWHK1J9G0nua48M0h)kPXThwpZqa0vBGmcMFNH1OEisZnua4zVoG0hzSavvNkneKGa(Tr9aHEJ51SC6AWZcMTh(SEShKUHcaN3Og)JHdjRh7bPBOaW5nxd)kPjSqD7H1ZmeaD1giJG53zynQhIHtZnua4zVoG0hzSavvNkneKGa(Tr9aHEJ51SC6AWJxD3Zk)kbWN1J9G0nua48g14FmCiz9ypiDdfaoVrn(vsdcsqa)2OEGMBOaWZEDaPpYybQQovAHfwOHXM5JZLnZvoNzLrdHBWBiiJGJvlVVg(O8s(THIx3yEnBwz5Ur9G0ss(I51SzahatXbPxhiCAgZRwGew4uax1MRfE72gZRwGew4uaVrD4e6nMxZYPRbpE1DpR8ReaFwp2ds3qbGZBuJ)XWHK1J9G0nua48MRWVsAqqcc43g1d0CdfaE2Rdi9rglqv1PslSWcnm2mFCUSzUY5mRmAiCdEdbzeCSA591WhLxYVnu86gZRzZkl3nQhKwsYxmVMnd4aykoi96aHtZyE1cKWcNc4nHWWB32yE1cKWcNc4nxfoHEJ51SC6AWJxD3Zk)kbWN1J9G0nua48g14FmCiz9ypiDdfaoVbN4xjniibb8BJ6bAUHcap71bK(iJfOQ6uPfwyHggBMpox2mx5CMvgneUbVHGmcowT8(A4JYl53gkEDJ51SzLL7g1dslj5lMxZMbCamfhKEDGWPzmVAbsyHtb8M0p82TnMxTajSWPaEdodNqVX8AwoDn4XRU7zLFLa4Z6XEq6gkaCEJA8pgoKSEShKUHcaN3Ko8RKgeKGa(Tr9an3qbGN96asFKXcuvDQ0clSqdJnZhNlBMRCoZkJgc3G3qqgbhRwEFn8r5L8BdfVUX8A2SYYDJ6bPLK8fZRzZaoaMIdsVoq40mMxTajSWPaEt)cVDBJ5vlqclCkG3KUWj0BmVMLtxdESbHu68Aw8z9ypiDdfaoVrn(vsJX8QfiHfofW7dN052dRNVGk)gK1kTGz7LH1OEisdbjiGFBupqZnua4zVoG0hzSavvNkHEJ51SC6AWR72wFosETbkVHkVh(vsJxhOVM0LkHEJ51SC6AWRv9G0TADc9gZRz501Gx0q4k5JYtO3yEnlNUg8Oaehq4wBaHEJ51SC6AWtz5Ur9G0ss(I51S4xjn8r5L8BdfvTPFe6nMxZYPRbpLL7g1dslj5lMxZIFL0WM5JZLnZvoNzLrdHBWBiiJGJvlVVg(O8s(THIxhWbWuCq61bi0BmVMLtxdEm7FPX8Aw5xCh)1oqts9pG44xjnHXM5JZLnZvoNzLrdHBWBiiJGJvlVpVoG0hj)2qXRhw)sp(O8s(THIH3UnBMpox2mx5CMvgneUbVHGSsx4086asFKXcuLnZhNlBMRCoZkJgc3G3qqgbhRwoHEJ51SC6AWJdquojs2GqkDEnl(vstldvg1dzENDog1dsoarc9gZRz501GNYYDJ6bPLK8fZRzXVsAcTdbTKbSywDMRCoZkJgc3G3qaTqBzOYOEiZ7SZXOEqYbislm3Ey9Cem)MAEpdRr9qKgBMpox2Cem)MAEpJGJvlVVgahatXbPxhGwOw)bOYHmZ4mlwBGKzVDkVxgwJ6Hy728r5L8BdfvT5kAUHcap71bK(iJfOA6OdWbWuCq61bOzmVAbsyHtb8g1TB7gka8Sxhq6JmwqFnxJoahatXbPxh468r5L8BdfdNqVX8AwoDn4PSC3OEqAjjFX8Aw8RKMqBzOYOEiZ7SZXOEqYbisJnRBb1S91WmUl96a01YqLr9qUZIXAdi0BmVMLtxdEkl3nQhKwsYxmVMfFwp2ds3qbGZBuJFL0eAldvg1dzENDog1dsoarAHfQBpSEocMFtnVNH1OEi2UnBMpox2Cem)MAEpJGJvlxvVoG0hj)2qX2T5JYl53gkQQ6WPXM1TGA2(Ayg3LEDa6AzOYOEi3zXyTb0cluR)au5qMzCMfRnqYS3oL3ldRr9qSDBkLKKmZ4mlwBGKzVDkVxgbhRwUQEDaPps(THIHtO3yEnlNUg8y2)sJ51SYV4o(RDGMK6FaXj0tO3yEnlpNu)diEJfmBp8RKgeCSA59P(A0yZ8X5YM5kNZSYOHWn4neKrWXQLRAdotLUawKgBMpox2Cem)MAEpJGJvlVVMawKwODiOLmGfZQZCLZzwz0q4g8gcOfAhcAjdyXS6SfmBpAHz9hGkhYCLyew5SCWZiBXvv1TBB9hGkhYCLyew5SCWZiBXTrnTqD7H1Z8Q7Ew5xjqgwJ6Hy4e6nMxZYZj1)aItxdErW8BQ5D8RKg2mFCUSzUY5mRmAiCdEdbzeCSA5Q2GZuPlGfB3MnZhNlBMRCoZkJgc3G3qqgbhRwUQQtxQe6nMxZYZj1)aItxdE8BloxKuZ74xjnukjj5Z0coW6zLoAukjj5TcU9e7)mcowTCc9gZRz55K6FaXPRbply2E4xjnukjj5Z0coW6zLoAHgMBpSEMxD3Zk)kbYWAupePfwhcAjdyXS6SfmBpADiOLmGfZxLTGz7rRdbTKbSygNzly2EH3UDhcAjdyXS6SfmBVWj0BmVMLNtQ)beNUg84v39SYVsa8RKgkLKK8zAbhy9SshTqdRdbTKbSywDMxD3Zk)kbO1HGwYawmFvMxD3Zk)kbO1HGwYawmJZmV6UNv(vceoHEJ51S8Cs9pG401GhBqiLoVMf)kPHsjjjFMwWbwpR0rl0oe0sgWIz1z2GqkDEnlTqD7H1ZgfFEfhKSbHu68A2mSg1drc9gZRz55K6FaXPRbViYQv(vcGFL0egLsssUwOv5g1dYiCkoK5UXWv1MquQ0cJnZhNlBocMFtnVNrWXQLRkGdGP4G0Rd0UDOU9W65iy(n18EgwJ6Hy40cJnZhNlBU72wFosETbkVHkVxgbhRwUQaoaMIdsVoq72H62dRN7UT1NJKxBGYBOY7LH1OEigoTWyZ8X5YMJgcxjFu(mcowTCvbCamfhKEDG2Td1ThwphneUs(O8YtXbuVmSg1dXWPfgBMpox2CR6bPB16zeCSA5Qc4aykoi96aTBhQBpSEUv9G0TA9mSg1dXWPXM5JZLnZvoNzLrdHBWBiiJGJvlxvahatXbPxhGo1P2UnLsssUwOv5g1dYiCkoK5UXWvvCMkn3qbGN96asFKXc6RrDQHtO3yEnlpNu)dioDn4frwTs(O84xRdiKsNld(HY(g14ZUTABuJpRh7bPBOaW5nQXVsACdfaE2Rdi9rglOVMawKqVX8AwEoP(hqC6AWlISAL8r5XVwhqiLoxg8dL9nQXNDB12OMqVX8AwEoP(hqC6AWJFBX5IKAEhFwp2ds3qbGZBuJFL042dRN53wCUiHdfYyqgwJ6Hin3Ey9SrXNxXbjBqiLoVMndRr9qKMX8QfiHfofWBUIwOrGsjjjZVT4CrchkKXGmcowTCAHAmVMnZVT4CrsnVNRvM8vWTtO3yEnlpNu)dioDn4XVT4CrsnVJpRh7bPBOaW5nQXVsAC7H1Z8BloxKWHczmidRr9qKMBpSE2O4ZR4GKniKsNxZMH1OEisZyE1cKWcNc4nxrO3yEnlpNu)dioDn4XVT4CrsnVlWAbiEnRqLRsv91sneQoeMtvDQ9tGDXqBTbCbwiUt3GCis04KOnMxZs0FXDEMqVaZu87bjWWQtiOa7lUZfPiWsQ)bexKIqf1IueyWAupefPjWyOYbuzcmeCSA5eDFeT6Rr00iA2mFCUSzUY5mRmAiCdEdbzeCSA5eTQnenotLOPJOdyrIMgrZM5JZLnhbZVPM3Zi4y1Yj6(Ai6awKOPr0Hs0DiOLmGfZQZCLZzwz0q4g8gciAAeDOeDhcAjdyXS6SfmBpIMgrhgrB9hGkhYCLyew5SCWZiBXLOvLOvt0TBt0w)bOYHmxjgHvolh8mYwCj6gIwnrtJOdLOD7H1Z8Q7Ew5xjqgwJ6HirhUaZyEnRaZcMTNWfQCLifbgSg1drrAcmgQCavMaJnZhNlBMRCoZkJgc3G3qqgbhRworRAdrJZujA6i6awKOB3MOzZ8X5YM5kNZSYOHWn4neKrWXQLt0Qs0QtxQcmJ51ScSiy(n18UWfQGtrkcmynQhII0eymu5aQmbgLsss(mTGdSEwPJOPr0ukjj5TcU9e7)mcowTCbMX8Awbg)2IZfj18UWfQKorkcmynQhII0eymu5aQmbgLsss(mTGdSEwPJOPr0Hs0Hr0U9W6zE1DpR8ReidRr9qKOPr0Hr0DiOLmGfZQZwWS9iAAeDhcAjdyX8vzly2EennIUdbTKbSygNzly2EeD4eD72eDhcAjdyXS6SfmBpIoCbMX8AwbMfmBpHluPFIueyWAupefPjWyOYbuzcmkLKK8zAbhy9SshrtJOdLOdJO7qqlzalMvN5v39SYVsaIMgr3HGwYawmFvMxD3Zk)kbiAAeDhcAjdyXmoZ8Q7Ew5xjarhUaZyEnRaJxD3Zk)kbeUqL0xKIadwJ6HOinbgdvoGktGrPKKKptl4aRNv6iAAeDOeDhcAjdyXS6mBqiLoVMLOPr0Hs0U9W6zJIpVIds2GqkDEnBgwJ6HOaZyEnRaJniKsNxZkCHkHqrkcmynQhII0eymu5aQmbwyenLsssUwOv5g1dYiCkoK5UXWLOvTHOdrPs00i6WiA2mFCUS5iy(n18EgbhRworRkrd4aykoi96aeD72eDOeTBpSEocMFtnVNH1OEis0Ht00i6WiA2mFCUS5UBB95i51gO8gQ8EzeCSA5eTQenGdGP4G0Rdq0TBt0Hs0U9W65UBB95i51gO8gQ8EzynQhIeD4ennIomIMnZhNlBoAiCL8r5Zi4y1YjAvjAahatXbPxhGOB3MOdLOD7H1ZrdHRKpkV8uCa1ldRr9qKOdNOPr0Hr0Sz(4CzZTQhKUvRNrWXQLt0Qs0aoaMIdsVoar3Unrhkr72dRNBvpiDRwpdRr9qKOdNOPr0Sz(4CzZCLZzwz0q4g8gcYi4y1YjAvjAahatXbPxhGOPJOvNkr3UnrtPKKKRfAvUr9GmcNIdzUBmCjAvjACMkrtJODdfaE2Rdi9rglGO7RHOvNkrhUaZyEnRalISALFLacxOY1ePiWG1OEikstGzmVMvGfrwTs(O8cmwp2ds3qbGZfQOwGXqLdOYeyUHcap71bK(iJfq091q0bSOaJDB1kWulWQ1besPZLb)qzVatTWfQeIePiWG1OEikstGzmVMvGfrwTs(O8cm2TvRatTaRwhqiLoxg8dL9cm1cxOI6ufPiWG1OEikstGzmVMvGXVT4CrsnVlWyOYbuzcm3Ey9m)2IZfjCOqgdYWAupejAAeTBpSE2O4ZR4GKniKsNxZMH1OEis00iAJ5vlqclCkGt0ne9vennIouIocukjjz(TfNls4qHmgKrWXQLt00i6qjAJ51Sz(TfNlsQ59CTYKVcUDbgRh7bPBOaW5cvulCHkQvlsrGbRr9quKMaZyEnRaJFBX5IKAExGXqLdOYeyU9W6z(TfNls4qHmgKH1OEis00iA3Ey9SrXNxXbjBqiLoVMndRr9qKOPr0gZRwGew4uaNOBi6ReySEShKUHcaNlurTWfQO(krkcmJ51Scm(TfNlsQ5DbgSg1drrAcx4cSiKykVlsrOIArkcmynQhII0eyTSxbeyU9W6z(Cr63GKdqKNH1OEis00iAEh8V0nua48mhGOCsKSbHu68AwPnarRAdrJtIUDBI2ThwpZRU7zLFLazynQhIennIM3b)lDdfaopZbikNejBqiLoVMLOvTHO7hr3UnrZ7G)LUHcaNN5aeLtIKniKsNxZs0Q2q0xtGzmVMvG1YqLr9GaRLHKRDabgVZohJ6bjhGOWfQCLifbgSg1drrAcSPtGXbxGzmVMvG1YqLr9GaRL9kGaZyEnBMFBX5IKAEpd4aykoi96ae91jAR)au5qMzCMfRnqYS3oL3ldRr9quG1YqY1oGaRZIXAdeUqfCksrGbRr9quKMaB6eyiGdUaZyEnRaRLHkJ6bbwl7vabwalkWyOYbuzcmR)au5qMzCMfRnqYS3oL3ldRr9qKOPr0Hr0U9W65iYQvYhLpdRr9qKOB3MOD7H1ZrW8BQ59mSg1drIMgrZM5JZLnhbZVPM3Zi4y1Yj6(Ai6awKOdxG1YqY1oGaRZIXAdeUqL0jsrGzmVMvGX7G)L)WWvGbRr9quKMWfQ0prkcmynQhII0eymu5aQmbwyeTBpSEoAiCL8r5LNIdOEzynQhIennIMnZhNlBMRCoZkJgc3G3qqwPJOPr0Sz(4CzZrdHRKpkFwPJOdNOB3MOzZ8X5YM5kNZSYOHWn4neKv6i62TjA3qbGN96asFKXci6(iACMQaZyEnRaRB8AwHluj9fPiWG1OEikstGXqLdOYeyHs0Sz(4CzZCLZzwz0q4g8gcYkDcmJ51ScmfoilhoCHlujeksrGbRr9quKMaJHkhqLjWcLOzZ8X5YM5kNZSYOHWn4neKv6eygZRzfyjfcO(zIcxOY1ePiWG1OEikstGXqLdOYeyHs0Sz(4CzZCLZzwz0q4g8gcYkDcmJ51ScmQFMOmrb1t4cvcrIueyWAupefPjWmMxZkWIiRwjFuEbgRh7bPBOaW5cvulWyOYbuzcm3qbGN96asFKXci6(Ai6awKOPr08r5L8Bdfj6(i6(jWy3wTcm1cSADaHu6CzWpu2lWulCHkQtvKIaZyEnRa72uwxGbRr9quKMWfQOwTifbgSg1drrAcmgQCavMaloE2cMTx2lgU1gq00i644z2GqkDEnB2lgU1gq00i6WiAkLKKSX8QfivmEM7gdxIUHO7hr3UnrZhLxYVnuKOBi6uj6WjAAeDyeDOeTBpSEU72wFosETbkVHkVxgwJ6Hir3UnrZM5JZLn3DBRphjV2aL3qL3lJGJvlNOdxGzmVMvGXvoNzLrdHBWBiq4cvuFLifbgSg1drrAcmJ51Scmly2EcmgQCavMadbhRwor3xdrhWIcmwp2ds3qbGZfQOw4cvuJtrkcmynQhII0eygZRzfy8BloxKuZ7cmgQCavMaZThwpZVT4CrchkKXGmSg1drIMgr72dRNnk(8koizdcP051SzynQhIennI2yE1cKWcNc4eDdrFfrtJOJaLsssMFBX5IeouiJbzeCSA5ennIocukjjz(TfNls4qHmgKrWXQLt091q0aoaMIdsVoarFDI(kIMoI2rwl4LEDaIMgrhkrBmVMnZVT4CrsnVNRvM8vWTlWy9ypiDdfaoxOIAHlurD6ePiWG1OEikstGXqLdOYeyEDaIwvIoDPs00i6WiA2mFCUSzUY5mRmAiCdEdbzeCSA5eTQneD66hr3UnrZM5JZLnZvoNzLrdHBWBiiJGJvlNO7JOVgrhUaZyEnRaR72wFosETbkVHkVNWfQOUFIueyWAupefPjWyOYbuzcmVoarRkrFvQcmJ51ScSw1ds3Q1fUqf1PVifbgSg1drrAcmgQCavMaloEMniKsNxZMrWXQLt091q0gZRzZCaIYjrYgesPZRzZmJ7sVoarthr71bK(i53gks00r0PlFfrFDIomIwnrNEeTBpSEMHaOR2azem)odRr9qKOVorNAwD)i6WjAAenVd(x6gkaCEMdquojs2GqkDEnR0gGOvTHOXjrthr72dRNVGk)gK1kTGz7LH1OEis00i6qj644zoar5KizdcP051SzeCSA5ennIouI2yEnBMdquojs2GqkDEnBUwzYxb3UaZyEnRaJdquojs2GqkDEnRWfQOoeksrGbRr9quKMaZyEnRaZcMTNaJ1J9G0nua4CHkQfyhdhswp2ds3qbGZfyPVaJHkhqLjWC7H1ZmeaD1giJG53zynQhIennI2nua4zVoG0hzSaIwvIwDQennIgbjiGFBupiCHkQVMifbgSg1drrAcmJ51Scmly2Ecmwp2ds3qbGZfQOwGDmCiz9ypiDdfaoxGDnbgdvoGktGfgrhkr72dRNzia6QnqgbZVZWAupej6WjAAeTBOaWZEDaPpYybeTQeT6ujAAencsqa)2OEq4cvuhIePiWG1OEikstGzmVMvGXRU7zLFLacmwp2ds3qbGZfQOwGDmCiz9ypiDdfaoxGPwGXqLdOYeyiibb8BJ6bIMgr7gka8Sxhq6JmwarRkrRovIMgrhgrhgrhkrhgrZM5JZLnZvoNzLrdHBWBiiJGJvlNO7RHO5JYl53gks0xNOnMxZMvwUBupiTKKVyEnBgWbWuCq61bi6WjAAeTX8QfiHfofWjAvBi6Rr0Ht0TBt0gZRwGew4uaNOBiA1eD4cxOYvPksrGbRr9quKMaZyEnRaJxD3Zk)kbeySEShKUHcaNlurTa7y4qY6XEq6gkaCUa7kbgdvoGktGHGeeWVnQhiAAeTBOaWZEDaPpYybeTQeT6ujAAeDyeDyeDOeDyenBMpox2mx5CMvgneUbVHGmcowTCIUVgIMpkVKFBOirFDI2yEnBwz5Ur9G0ss(I51SzahatXbPxhGOdNOPr0gZRwGew4uaNOBi6qirhor3UnrBmVAbsyHtbCIUHOVIOdx4cvUsTifbgSg1drrAcmJ51ScmE1DpR8ReqGX6XEq6gkaCUqf1cSJHdjRh7bPBOaW5cmCkWyOYbuzcmeKGa(Tr9artJODdfaE2Rdi9rglGOvLOvNkrtJOdJOdJOdLOdJOzZ8X5YM5kNZSYOHWn4neKrWXQLt091q08r5L8Bdfj6Rt0gZRzZkl3nQhKwsYxmVMnd4aykoi96aeD4ennI2yE1cKWcNc4eDdrN(eD4eD72eTX8QfiHfofWj6gIgNeD4cxOYvxjsrGbRr9quKMaZyEnRaJxD3Zk)kbeySEShKUHcaNlurTa7y4qY6XEq6gkaCUalDcmgQCavMadbjiGFBupq00iA3qbGN96asFKXciAvjA1Ps00i6Wi6Wi6qj6WiA2mFCUSzUY5mRmAiCdEdbzeCSA5eDFnenFuEj)2qrI(6eTX8A2SYYDJ6bPLK8fZRzZaoaMIdsVoarhortJOnMxTajSWPaor3q09JOdNOB3MOnMxTajSWPaor3q0PJOdx4cvUcNIueyWAupefPjWmMxZkWydcP051ScmgQCavMaZyE1cKWcNc4eDFenojA6iA3Ey98fu53GSwPfmBVmSg1drIMgrJGeeWVnQhiAAeTBOaWZEDaPpYybeTQeT6ufySEShKUHcaNlurTWfQCv6ePiWG1OEikstGXqLdOYeyEDaIUVgIoDPkWmMxZkW6UT1NJKxBGYBOY7jCHkx1prkcmJ51ScSw1ds3Q1fyWAupefPjCHkxL(IueygZRzfyrdHRKpkVadwJ6HOinHlu5QqOifbMX8AwbgfG4ac3AdeyWAupefPjCHkxDnrkcmynQhII0eymu5aQmbgFuEj)2qrIw1gIUFcmJ51ScmLL7g1dslj5lMxZkCHkxfIePiWG1OEikstGXqLdOYeySz(4CzZCLZzwz0q4g8gcYi4y1Yj6(AiA(O8s(THIe91jAahatXbPxhqGzmVMvGPSC3OEqAjjFX8AwHlubNPksrGbRr9quKMaJHkhqLjWcJOzZ8X5YM5kNZSYOHWn4neKrWXQLt09r0EDaPps(THIe91j6Wi6(r0PhrZhLxYVnuKOdNOB3MOzZ8X5YM5kNZSYOHWn4neKv6i6WjAAeTxhq6JmwarRkrZM5JZLnZvoNzLrdHBWBiiJGJvlxGzmVMvGXS)LgZRzLFXDb2xCxU2beyj1)aIlCHk4uTifbgSg1drrAcmgQCavMaRLHkJ6HmVZohJ6bjhGOaZyEnRaJdquojs2GqkDEnRWfQGZRePiWG1OEikstGXqLdOYeyHs0DiOLmGfZQZCLZzwz0q4g8gciAAeDOeDldvg1dzENDog1dsoarIMgrhgr72dRNJG53uZ7zynQhIennIMnZhNlBocMFtnVNrWXQLt091q0aoaMIdsVoartJOdLOT(dqLdzMXzwS2ajZE7uEVmSg1drIUDBIMpkVKFBOirRAdrFfrtJODdfaE2Rdi9rglGOvLOthrthrd4aykoi96aennI2yE1cKWcNc4eDdrRMOB3MODdfaE2Rdi9rglGO7RHOVgrthrd4aykoi96ae91jA(O8s(THIeD4cmJ51ScmLL7g1dslj5lMxZkCHk4eNIueyWAupefPjWyOYbuzcSqj6wgQmQhY8o7CmQhKCaIennIMnRBb1SeDFnenZ4U0Rdq00r0TmuzupK7SyS2abMX8AwbMYYDJ6bPLK8fZRzfUqfCMorkcmynQhII0eygZRzfykl3nQhKwsYxmVMvGXqLdOYeyHs0TmuzupK5D25yupi5aejAAeDyeDOeTBpSEocMFtnVNH1OEis0TBt0Sz(4CzZrW8BQ59mcowTCIwvI2Rdi9rYVnuKOB3MO5JYl53gks0Qs0Qj6WjAAenBw3cQzj6(AiAMXDPxhGOPJOBzOYOEi3zXyTbennIomIouI26pavoKzgNzXAdKm7Tt59YWAupej62TjAkLKKmZ4mlwBGKzVDkVxgbhRworRkr71bK(i53gks0HlWy9ypiDdfaoxOIAHlubN9tKIadwJ6HOinbMX8AwbgZ(xAmVMv(f3fyFXD5AhqGLu)diUWfUaRdbS5qzUifHkQfPiWG1OEikst4cvUsKIadwJ6HOinHlubNIueyWAupefPjCHkPtKIaZyEnRaJRCoZktG)wzDajWG1OEikst4cv6NifbgSg1drrAcmgQCavMaZThwphGQZuiqojsUXqvsXGmSg1drbMX8AwbwaQotHa5Ki5gdvjfdeUqL0xKIadwJ6HOinHlujeksrGzmVMvG1nEnRadwJ6HOinHlu5AIueyWAupefPjWyOYbuzcmEh8V0nua48mhGOCsKSbHu68AwPnarRAdrJtbMX8AwbghGOCsKSbHu68AwHlujejsrGzmVMvGDBkRlWG1OEikst4cvuNQifbgSg1drrAcmgQCavMaluI2ThwpFBkRNH1OEis00iAEh8V0nua48mhGOCsKSbHu68AwPnar3hrJtbMX8Awbg)2IZfj18UWfUWfUWfca]] )

end