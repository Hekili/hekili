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


    spec:RegisterPack( "Affliction", 20181028.2347, [[dy0dGbqiLcpsjP6suQWMquJIO4ueLwfrLEfGmlIQUfLkAxi9lkvnmLIoMK0Yuk1ZusY0OuPUgIOTHiW3iQGXrurNJOczDicQ5HiDpLQ9Pe5GuQKwOsjperq6IkjLYjvskvRKsXmvskXnree2Psu)erq0qPujSuIkupLsMQsIVsPs0Ef6VumychM0IjYJfmzuDzOnlP(SegnaNwXQvskPxtP0Sv1Try3s9BrdxIwUkphLPt11bA7kHVRKA8icDEa16vskMVKy)GownUs0IRogxE7nRkNv3CB5i6MBwDvBtYOLdCjgTk1GTAbgTALaJw2166Fc(KD0Qub(tLhxjAXsWlGrlaUxYiHT3(IXbakrdjH9SHa8vFYoCATBpBic2l9PK9s1QDYXf2xEz98iZ(vg82UQ9RSDvJDPEFgS1yxRR)j4t2u2qeIwsGZ7R27Ou0IRogxE7nRkNv3CB5i6MBU5MvjbrlwjgIlVnjGKrladNJDukAXrwiAT6qHDTU(NGpzdf2L69zWwOnRouaW9sgjS92xmoaqjAijSNneGV6t2HtRD7zdrWEPpLSxQwTtoUW(YlRNhz2BxCOCSoCM92fYXg7s9(myRXUwx)tWNSPSHiaTz1HcsidEkHhuSTCkpuS9MvLtOWoHIQvjHTBsauyxqcb0gOnRouqcfG2fiJegAZQdf2juyx5CKdfwL4)qXQLmylfAZQdf2juihJe5cKdfUEfOBMAkLcTz1Hc7ekSR8vRGmhkkvoF6cOyHEJk9iu8zXeOrRYlRNhJwRouyxRR)j4t2qHDPEFgSfAZQdfaCVKrcBV9fJdauIgsc7zdb4R(KD40A3E2qeSx6tj7LQv7KJlSV8Y65rM92fhkhRdNzVDHCSXUuVpd2ASR11)e8jBkBicqBwDOGeYGNs4bfBlNYdfBVzv5ekStOOAvsy7Meaf2fKqaTbAZQdfKqbODbYiHH2S6qHDcf2voh5qHvj(puSAjd2sH2S6qHDcfYXirUa5qHRxb6MPMsPqBwDOWoHc7kF1kiZHIsLZNUakwO3OspcfFwmbk0gOnRouSAJeXaOJCOqcRZdHIqsiPouiHftZOqHDneWsNbfD22ja9iQbFOqd(KndkY(bMcTrd(KnJwEyijKuFV(vMTqB0GpzZOLhgscj1bA3(6m5qB0GpzZOLhgscj1bA3EfSGaBx9jBOnAWNSz0YddjHK6aTBpdKGiBtj6qB0GpzZOLhgscj1bA3(IBiY5qtwByA4M6jGYp17U(y70IBiY5qtwByA4M6jGuSvPh5qB0GpzZOLhgscj1bA3EwRLmaPByU6mOnAWNSz0YddjHK6aTBFz6t2qB0GpzZOLhgscj1bA3EgICtwBc5DGL(KT8t9oRe)346vGoJYqKBYAtiVdS0NSnAIlTVkOnAWNSz0YddjHK6aTBpafSDOnAWNSz0YddjHK6aTBpdGYZ1gP8D5N69nC9X2PauW2PyRspYjZkX)nUEfOZOme5MS2eY7al9jBJMiPRcAd0MvhkwTrIya0rouGlWdyOWhcekCaiuObppOyyqHUqNxLEKcTrd(KnBNvI)B(myl0gn4t2mG2TFHEJk9O8TsG7Gm0WqKl)c9bXDxFSDklxBCaOHHiNrXwLEKtMvI)BC9kqNrziYnzTjK3bw6t2gnXL2xfqNoCdUaBNo9cWVXtLEKcwwPIRp2oLnLaY28tnsXwLEKtMvI)BC9kqNrziYnzTjK3bw6t2lTtsGoD4gCb2oD6fGFJNk9ifSSsfwj(VX1RaDgLHi3K1MqEhyPpzV0UCc0Pd3GlW2PtVa8B8uPhPGLqB0GpzZaA3(f6nQ0JY3kbUxQC(0fYNL7m0LFH(G4UmYORg8ghPbLfu(0fMG(kX4atXwLEKtwgxFSDk)0PnSe8PyRspYRuX1hBNYr1biLVtXwLEKtoK5ZZ1nLJQdqkFNEiHonJ09Iaxwzjxe4vQiJg8jBkdGYZ1gP8DksIya0rJpeOC1vdEJJ0GYckF6ctqFLyCGPyRspYLvwOnRouObFYMb0U9l0BuPhLVvcCVu58PlKpl3zOl)c9bX9Iax(PExxn4nosdklO8Plmb9vIXbMITk9iNSmU(y7u(PtByj4tXwLEKxPIRp2oLJQdqkFNITk9iNCiZNNRBkhvhGu(o9qcDAgP7fbUSqB0GpzZaA3(f6nQ0JY3kbUtOt760ggk)c9bXDwj(VX1RaDgLHi3K1MqEhyPpzB0ejDVkqU(y70134aqZ0gTiBGPyRspYbY1hBNQsS8bD0eY7al9jBk2Q0JC5UnqY46JTtxFJdantB0ISbMITk9iNSRp2oLLRnoa0WqKZOyRspYjZkX)nUEfOZOme5MS2eY7al9jBJM4sBllqY46JTtztjGSn)uJuSvPh5K3W1hBNgoelNUWWr1bqXwLEKtEdxFSDk)0PnSe8PyRspYLfOthUbxGTtNEb434PspsblH2ObFYMb0U9l0BuPhLVvcCV41dn5zKY3LFH(G4opDQwKnWuFc2oDbzE60qEhyPpzt9jy70fKLrcSUMQbFwGgqLrzUgSDNKvQWsW3WaOhFFtzjlZgU(y70saA7jHHnDb4R34atXwLEKxPsiZNNRBAjaT9KWWMUa81BCGPhsOtZKLSmB46JTt5O6aKY3PyRspYRujK5ZZ1nLJQdqkFNEiHonJ09IaVsLncz(8CDt5O6aKY3PhsOtZQuHvI)BC9kqNrziYnzTjK3bw6t2gnXLQc0Pd3GlW2PtVa8B8uPhPGLYcTrd(KndOD7d6)gn4t2MFyU8TsG7HmFEUUzqB0GpzZaA3E(PtByj4l)0oEhyPBk(us)9QYhaOtVxv(aWHhnUEfOZ2Rk)uV76vGo1hc04PHpiP7fbozwc(gga94KssOnAWNSzaTBpafSD5N6Dwj(VX1RaDgLHi3K1MqEhyPpzB0ejDFBGoD4gCb2oD6fGFJNk9ifSeAJg8jBgq72ZajiY2W1Z2Ixpu(PEFHEJk9iT41dn5zKY3H2ObFYMb0U9CuDas57Yp17HmFEUUPmqcISnC9ST41dPhsOtZiVqVrLEKw86HM8ms57KzL4)gxVc0zugICtwBc5DGL(KTrtCVkqNoCdUaBNo9cWVXtLEKcwcTrd(KndOD71ISbw(PE)qcDAgP7fboqAWNSPmakpxBKY3PijIbqhn(qGKD9kqN6dbA80WhCj5eAJg8jBgq72d2mxLE0O11)e8jBOnAWNSzaTBp)0PnSe8LpODaFZuV7tWwM5qcDAsjP8t9URp2oLbq55AdsiDAaPyRspYjVqVrLEKsOt760ggsMJsG11ugaLNRniH0PbKEiHonJmhLaRRPmakpxBqcPtdi9qcDAgP7fbUC3gAJg8jBgq72ZaO8CTrkFx(aWHhnUEfOZ2Rk)uV76JTtzauEU2GesNgqk2Q0JCYl0BuPhPe60UoTHHK5OeyDnLbq55AdsiDAaPhsOtZiZrjW6AkdGYZ1gKq60aspKqNMr6osIya0rJpeOC3gi)0f4B8HajVHg8jBkdGYZ1gP8D60M6Fka4qB0GpzZaA3(saA7jHHnDb4R34al)uV7dbU0Qijzzcz(8CDtzGeezB46zBXRhspKqNMT0UDtYkvcz(8CDtzGeezB46zBXRhspKqNMrQCklzxVc0P(qGgpn8bxQkjqUSs8FdaL5i0gn4t2mG2TFX8OX1PD5LFQ39HaxQkjj76vGo1hc04PHp4s7v3eAJg8jBgq72d2mxLE0O11)e8jB5N69nwO3OspsbzOHHiNmlbFddGE8DscTrd(KndOD7ziYnzTjK3bw6t2Yp17l0BuPhPGm0WqKtMLGVHbqp(ojH2ObFYMb0U9b9FJg8jBZpmx(wjWDE6mOnAWNSzaTBFjaT9KWWMUa81BCGLFQ39HajDFvKeAJg8jBgq72VyE0460U8t9UpeiPvjj0gn4t2mG2TNRNTgwc(Yp17HmFEUUPmqcISnC9ST41dPhsOtZiT6MK5PtlbOTNeg20fGVEJdm9qcDAwLkUEfOt9HanEA4ds62BcurGxPcRe)346vGoJYqKBYAtiVdS0NSnAIlvfOthUbxGTtNEb434PspsblH2ObFYMb0U9s4XWZ2PlG2ObFYMb0U9b9FJg8jBZpmx(wjWDwj2C8yqB0GpzZaA3(G(Vrd(KT5hMlFRe4E98pEmOnqB0GpzZOHmFEUUz7LPpzl)uVlJRp2oLRNTgwc(gIHHhWuSvPh5Kdz(8CDtzGeezB46zBXRhsbljhY8556MY1ZwdlbFkyPSvQeY8556MYajiY2W1Z2IxpKcwwPIRxb6uFiqJNg(GKUQnH2ObFYMrdz(8CDZaA3EqgAghjyYp17BeY8556MYajiY2W1Z2IxpKcwk)uVhY8556MYajiY2W1Z2IxpKEiHonBj5WMvQ4dbA80WhK0T3SsfzKrcSUMQbFwGgqLrzUgSDNKvQWsW3WaOhFFtzjlZgU(y70saA7jHHnDb4R34atXwLEKxPsiZNNRBAjaT9KWWMUa81BCGPhsOtZKLSmB46JTt5O6aKY3PyRspYRujK5ZZ1nLJQdqkFNEiHonJ09IaVsLncz(8CDt5O6aKY3PhsOtZKL8gHmFEUUPmqcISnC9ST41dPhsOtZKfAJg8jBgnK5ZZ1ndOD7RNdL(m5Yp17BeY8556MYajiY2W1Z2IxpKcwcTrd(KnJgY8556Mb0U9sFMCtn4bS8t9(gHmFEUUPmqcISnC9ST41dPGLqBG2ObFYMr5sMdRpKbyNnLaY28tnk)pnAc89QKu(PExgE6u2uciBZp1i9qcDAMDWtNYMsazB(PgPCWt9jBzjDxgE6uTiBGPhsOtZSdE6uTiBGPCWt9jBzjldpDkBkbKT5NAKEiHonZo4PtztjGSn)uJuo4P(KTSKUldpDAiVdS0NSPhsOtZSdE60qEhyPpzt5GN6t2YsMNoLnLaY28tnspKqNMrkpDkBkbKT5NAKYbp1NSLBv6QG2ObFYMr5sMdRpKbaOD71ISbw(FA0e47vjP8t9Um80PAr2atpKqNMzh80PAr2at5GN6t2Ys6Um80PH8oWsFYMEiHonZo4Ptd5DGL(KnLdEQpzllzz4Pt1ISbMEiHonZo4Pt1ISbMYbp1NSLL0Dz4PtztjGSn)uJ0dj0Pz2bpDkBkbKT5NAKYbp1NSLLmpDQwKnW0dj0PzKYtNQfzdmLdEQpzl3Q0vbTrd(KnJYLmhwFidaq72hY7al9jB5)PrtGVxLKYp17YWtNgY7al9jB6He60m7GNonK3bw6t2uo4P(KTSKUldpDQwKnW0dj0Pz2bpDQwKnWuo4P(KTSKLHNonK3bw6t20dj0Pz2bpDAiVdS0NSPCWt9jBzjDxgE6u2uciBZp1i9qcDAMDWtNYMsazB(PgPCWt9jBzjZtNgY7al9jB6He60ms5Ptd5DGL(KnLdEQpzl3Q0vbTbAJg8jBgLNoBNHi3K1MqEhyPpzl)uVZtNgY7al9jB6He60ms31GpztziYnzTjK3bw6t20GYCJpeiq(qGgpnma6XbYUPBlxzQANU(y70WHy50fgoQoak2Q0JC5UjTkjLLmRe)346vGoJYqKBYAtiVdS0NSnAIlTVkGoD4gCb2oD6fGFJNk9ifSeixFSD66BCaOzAJwKnWuSvPh5K3GNoLHi3K1MqEhyPpztpKqNMrEdn4t2ugICtwBc5DGL(KnDAt9pfaCOnAWNSzuE6mG2TxlYgy5dahE046vGoBVQ8t9URp2onCiwoDHHJQdGITk9iNSg8zbA4Pt1ISbMusazxVc0P(qGgpn8bxQ6MKL5qcDAgP7fbELkHmFEUUPmqcISnC9ST41dPhsOtZwQ6MKpS(qgav6rzH2ObFYMr5PZaA3ETiBGLpaC4rJRxb6S9QYp17B46JTtdhILtxy4O6aOyRspYjRbFwGgE6uTiBGjvoj76vGo1hc04PHp4sv3KSmhsOtZiDViWRujK5ZZ1nLbsqKTHRNTfVEi9qcDA2sv3K8H1hYaOspkl0gn4t2mkpDgq72ZMsazB(PgLpaC4rJRxb6S9QYp17YObFwGgE6u2uciBZp1iPYPD66JTtdhILtxy4O6aOyRspYTtwj(VX1RaDgLLRnoa0WqKZmAIYs21RaDQpeOXtdFWLQUj5dRpKbqLEKSmBCiHonJmRe)346vGoJYqKBYAtiVdS0NSnAI7vRujK5ZZ1nLbsqKTHRNTfVEi9qcDA2sSe8nma6XLRg8jBkyZCv6rJwx)tWNSPijIbqhn(qGYcTrd(KnJYtNb0U9H8oWsFYw(aWHhnUEfOZ2Rk)uVZkX)nUEfOZOme5MS2eY7al9jBJMiPRcOthUbxGTtNEb434PspsblbY1hBNU(ghaAM2OfzdmfBv6rozzoKqNMr6ErGxPsiZNNRBkdKGiBdxpBlE9q6He60SLQUj5dRpKbqLEuwYUEfOt9HanEA4dUu1nH2aTrd(KnJwp)JhBhSzUk9OrRR)j4t2Y)tJMaFVkjLFQ3dz(8CDt5O6aKY3PhsOtZiDViWL72KzL4)gxVc0zugICtwBc5DGL(KTrtCVkqNoCdUaBNo9cWVXtLEKcwsoK5ZZ1nLbsqKTHRNTfVEi9qcDA2sBVj0gn4t2mA98pEmG2TpO)B0GpzB(H5Y3kbUZLmhwFidG8t9oRe)346vGoJYqKBYAtiVdS0NSnAI7vb60HBWfy70Pxa(nEQ0JuWsYYWtNQfzdm9qcDAgP80PAr2at5GN6t2YDtQCGKvQWtNgY7al9jB6He60ms5Ptd5DGL(KnLdEQpzl3nPYbswPcpDkBkbKT5NAKEiHonJuE6u2uciBZp1iLdEQpzl3nPYbskl5qMppx3uoQoaP8D6He60ms31Gpzt1ISbMwe4Y1UjhY8556MYajiY2W1Z2IxpKEiHonBPT3eAJg8jBgTE(hpgq72h0)nAWNSn)WC5BLa35sMdRpKbq(PENvI)BC9kqNrziYnzTjK3bw6t2gnX9QaD6Wn4cSD60la)gpv6rkyj5qMppx3ugibr2gUE2w86H0dj0PzKUZsW3WaOhxUAWNSPAr2atlcCG0Gpzt1ISbMwe4YDvKLHNovlYgy6He60ms5Pt1ISbMYbp1NSLB1kv4Ptd5DGL(Kn9qcDAgP80PH8oWsFYMYbp1NSLB1kv4PtztjGSn)uJ0dj0PzKYtNYMsazB(PgPCWt9jB5wvwOnAWNSz065F8yaTBphvhGu(U8t9EiZNNRBkdKGiBdxpBlE9q6He60SL2x1Mave4vQeY8556MYajiY2W1Z2IxpKEiHonBPQ29MqB0GpzZO1Z)4XaA3EgaLNRns57Yp17sG11uICbsGTtbljlbwxt7PaGxR)tpKqNMbTrd(KnJwp)JhdOD71ISbw(PExcSUMsKlqcSDkyj5nKX1hBNYMsazB(PgPyRspYjlt5HlmfboTkvlYgyYLhUWue40TPAr2atU8WfMIaNUkQwKnWYwPs5HlmfboTkvlYgyzH2ObFYMrRN)XJb0U9SPeq2MFQr5N6DjW6AkrUajW2PGLK3qMYdxykcCAvkBkbKT5NAKC5HlmfboDBkBkbKT5NAKC5HlmfboDvu2uciBZp1OSqB0GpzZO1Z)4XaA3(qEhyPpzl)uVlbwxtjYfib2ofSK8gLhUWue40Q0qEhyPpztEdxFSDQkXYh0rtiVdS0NSPyRspYH2ObFYMrRN)XJb0U98tN28tnk)uVlJeyDnDACX4Q0JgosmmKYCny7s7YjjTtzyL4)gxVc0zugICtwBc5DGL(KTrt0opD4gCb2oD6fGFJNk9ifSCPTLvUBVjzzcz(8CDt5O6aKY3PhsOtZwcjrma6OXhcSsLnC9X2PCuDas57uSvPh5YswMqMppx30saA7jHHnDb4R34atpKqNMTesIya0rJpeyLkB46JTtlbOTNeg20fGVEJdmfBv6rUSKLjK5ZZ1nLRNTgwc(0dj0PzlHKigaD04dbwPYgU(y7uUE2Ayj4BiggEatXwLEKllzzcz(8CDtxmpACDANEiHonBjKeXaOJgFiWkv2W1hBNUyE0460ofBv6rUSKdz(8CDtzGeezB46zBXRhspKqNMTesIya0rJpeiqv3SsfjW6A604IXvPhnCKyyiL5AW2Lw1MKD9kqN6dbA80WhK09QBkl0gn4t2mA98pEmG2ThGc2o0gn4t2mA98pEmG2TNF60gwc(YpTJ3bw6MIpL0FVQ8ba607vLFAhVdS03RkFa4WJgxVc0z7vLFQ3D9kqN6dbA80WhK09IahAJg8jBgTE(hpgq72ZpDAdlbF5da0P3Rk)0oEhyPBM6DFc2YmhsOttkjLFAhVdS0nfFkP)Ev5N6DxFSDkdGYZ1gKq60asXwLEKtEHEJk9iLqN21PnmK8gCucSUMYaO8CTbjKonG0dj0PzqB0GpzZO1Z)4XaA3E(PtByj4lFaGo9Ev5N2X7alDZuV7tWwM5qcDAsjP8t74DGLUP4tj93Rk)uV76JTtzauEU2GesNgqk2Q0JCYl0BuPhPe60UoTHHqB0GpzZO1Z)4XaA3E(PtByj4l)0oEhyPBk(us)9QYhaOtVxv(PD8oWsFVk0gn4t2mA98pEmG2TNbq55AJu(U8bGdpAC9kqNTxv(PE31hBNYaO8CTbjKonGuSvPh5KxO3Ospsj0PDDAddjVbhLaRRPmakpxBqcPtdi9qcDAg5n0GpztzauEU2iLVtN2u)tbahAJg8jBgTE(hpgq72ZaO8CTrkFx(PE31hBNYaO8CTbjKonGuSvPh5KxO3Ospsj0PDDAddH2ObFYMrRN)XJb0U9makpxBKY3H2aTrd(KnJYkXMJhBhSzUk9OrRR)j4t2Yp17HmFEUUPmqcISnC9ST41dPhsOtZiDNLGVHbqpUCrsedGoA8HajlZgU(y7uoQoaP8Dk2Q0J8kvcz(8CDt5O6aKY3PhsOtZiDNLGVHbqpUCrsedGoA8HaLfAJg8jBgLvInhpgq72h0)nAWNSn)WC5BLa3RN)XJj)uVltiZNNRBkdKGiBdxpBlE9q6He60ms9HanEAya0Jlxzib2jlbFddGECzRujK5ZZ1nLbsqKTHRNTfVEifSuwY(qGgpn8bxkK5ZZ1nLbsqKTHRNTfVEi9qcDAg0gn4t2mkReBoEmG2TNHi3K1MqEhyPpzl)uVVqVrLEKcYqddro0gn4t2mkReBoEmG2ThSzUk9OrRR)j4t2Yp17BSqVrLEKcYqddro5nkpCHPiWPvPmqcISnC9ST41djlJRp2oLJQdqkFNITk9iNCiZNNRBkhvhGu(o9qcDAgP7ijIbqhn(qGK3qxn4nosdklO8Plmb9vIXbMITk9iVsfzyj4Bya0JV0ojjZkX)nUEfOZOme5MS2eY7al9jBJMiPBxPclbFddGE8L23MmRe)346vGoJYqKBYAtiVdS0NSnAIlTVTSKD9kqN6dbA80WhCj7giKeXaOJgFiqYSs8FJRxb6mkdrUjRnH8oWsFY2OjUxTsfxVc0P(qGgpn8bjDxobcjrma6OXhcuUSe8nma6XLfAJg8jBgLvInhpgq72d2mxLE0O11)e8jB5N69nwO3OspsbzOHHiNCiBxlMSjDpOm34dbc0c9gv6rAPY5txaTrd(KnJYkXMJhdOD7bBMRspA066Fc(KT8bGdpAC9kqNTxv(PEFJf6nQ0JuqgAyiYjlZgU(y7uoQoaP8Dk2Q0J8kvcz(8CDt5O6aKY3PhsOtZwYhc04PHbqpELkSe8nma6XxQQSKLzdxFSD6I5rJRt7uSvPh5vQWsW3WaOhFPQYsoKTRft2KUhuMB8HabAHEJk9iTu58PlilZg6QbVXrAqzbLpDHjOVsmoWuSvPh5vQibwxtdklO8Plmb9vIXbMEiHonBjFiqJNgga94YgTwGhBYoU82BwvoRU52YjD7vz3KGO1A96PlyrRv7eL55ihkKdqHg8jBO4hMZOqBIwkOdiVOL1qqcnA9dZzXvIwCjZH1hYaexjUC14krlSvPh5XTIwAWNSJwSPeq2MFQXOv4ghVrJwYaf80PSPeq2MFQr6He60mOWoGcE6u2uciBZp1iLdEQpzdfYcfKUdfYaf80PAr2atpKqNMbf2buWtNQfzdmLdEQpzdfYcfKHczGcE6u2uciBZp1i9qcDAguyhqbpDkBkbKT5NAKYbp1NSHczHcs3HczGcE60qEhyPpztpKqNMbf2buWtNgY7al9jBkh8uFYgkKfkidf80PSPeq2MFQr6He60mOGuOGNoLnLaY28tns5GN6t2qHCHIQ0vfT(PrtGhTQsYOhxE74krlSvPh5XTIwAWNSJwAr2ahTc344nA0sgOGNovlYgy6He60mOWoGcE6uTiBGPCWt9jBOqwOG0DOqgOGNonK3bw6t20dj0PzqHDaf80PH8oWsFYMYbp1NSHczHcYqHmqbpDQwKnW0dj0PzqHDaf80PAr2at5GN6t2qHSqbP7qHmqbpDkBkbKT5NAKEiHondkSdOGNoLnLaY28tns5GN6t2qHSqbzOGNovlYgy6He60mOGuOGNovlYgykh8uFYgkKluuLUQO1pnAc8Ovvsg94YRkUs0cBv6rECROLg8j7OviVdS0NSJwHBC8gnAjduWtNgY7al9jB6He60mOWoGcE60qEhyPpzt5GN6t2qHSqbP7qHmqbpDQwKnW0dj0PzqHDaf80PAr2at5GN6t2qHSqbzOqgOGNonK3bw6t20dj0PzqHDaf80PH8oWsFYMYbp1NSHczHcs3HczGcE6u2uciBZp1i9qcDAguyhqbpDkBkbKT5NAKYbp1NSHczHcYqbpDAiVdS0NSPhsOtZGcsHcE60qEhyPpzt5GN6t2qHCHIQ0vfT(PrtGhTQsYOh9OfhRvW3JRexUACLOLg8j7OfRe)38zW2Of2Q0J84wrpU82XvIwyRspYJBfTwOpigTC9X2PSCTXbGggICgfBv6rouqgkyL4)gxVc0zugICtwBc5DGL(KTrtekwAhkwfuaeuC6Wn4cSD60la)gpv6rkyjuuPcu46JTtztjGSn)uJuSvPh5qbzOGvI)BC9kqNrziYnzTjK3bw6t2qXs7qbjHcGGIthUbxGTtNEb434PspsblHIkvGcwj(VX1RaDgLHi3K1MqEhyPpzdflTdfYjuaeuC6Wn4cSD60la)gpv6rkyz0sd(KD0AHEJk9y0AHEMwjWOfidnme5rpU8QIReTWwLEKh3kALLrlg6rln4t2rRf6nQ0JrRf6dIrlzGczGcD1G34inOSGYNUWe0xjghyk2Q0JCOGmuidu46JTt5NoTHLGpfBv6rouuPcu46JTt5O6aKY3PyRspYHcYqriZNNRBkhvhGu(o9qcDAguq6ouue4qHSqHSqbzOOiWHIkvGczGcn4t2ugaLNRns57uKeXaOJgFiqOqUqHUAWBCKguwq5txyc6ReJdmfBv6rouiluiB0AHEMwjWOvPY5txe94Y2DCLOf2Q0J84wrRf6dIrlwj(VX1RaDgLHi3K1MqEhyPpzB0eHcs3HIQqbqqHRp2oD9noa0mTrlYgyk2Q0JCOaiOW1hBNQsS8bD0eY7al9jBk2Q0JCOqUqX2qbqqHmqHRp2oD9noa0mTrlYgyk2Q0JCOGmu46JTtz5AJdanme5mk2Q0JCOGmuWkX)nUEfOZOme5MS2eY7al9jBJMiuSeuSnuiluaeuidu46JTtztjGSn)uJuSvPh5qbzOydOW1hBNgoelNUWWr1bqXwLEKdfKHInGcxFSDk)0PnSe8PyRspYHczHcGGIthUbxGTtNEb434PspsblJwAWNSJwl0BuPhJwl0Z0kbgTi0PDDAddJECzsgxjAHTk9ipUv0AH(Gy0INovlYgyQpbBNUakidf80PH8oWsFYM6tW2PlGcYqHmqHeyDnvd(SanGkJYCnyluSdfKekQubkyj4Bya0Jdf7qXMqHSqbzOqgOydOW1hBNwcqBpjmSPlaF9ghyk2Q0JCOOsfOiK5ZZ1nTeG2Esyytxa(6noW0dj0PzqHSqbzOqgOydOW1hBNYr1biLVtXwLEKdfvQafHmFEUUPCuDas570dj0PzqbP7qrrGdfvQafBafHmFEUUPCuDas570dj0PzqrLkqbRe)346vGoJYqKBYAtiVdS0NSnAIqXsqrvOaiO40HBWfy70Pxa(nEQ0JuWsOq2OLg8j7O1c9gv6XO1c9mTsGrRIxp0KNrkFp6XLjbXvIwyRspYJBfT0GpzhTc6)gn4t2MFyE06hMBALaJwHmFEUUzrpUSCiUs0cBv6rECROLg8j7Of)0PnSe8JwbGdpAC9kqNfxUA0kCJJ3OrlxVc0P(qGgpn8bHcs3HIIahkidfSe8nma6XHcsHcsgTca0PJwvJwt74DGLUP4tj9JwvJECz5mUs0cBv6rECROv4ghVrJwSs8FJRxb6mkdrUjRnH8oWsFY2OjcfKUdfBdfabfNoCdUaBNo9cWVXtLEKcwgT0GpzhTaOGTh94YYrXvIwyRspYJBfTc344nA0AHEJk9iT41dn5zKY3JwAWNSJwmqcISnC9ST41dJEC5QBgxjAHTk9ipUv0kCJJ3OrRqMppx3ugibr2gUE2w86H0dj0PzqbzOyHEJk9iT41dn5zKY3HcYqbRe)346vGoJYqKBYAtiVdS0NSnAIqXouufkackoD4gCb2oD6fGFJNk9ifSmAPbFYoAXr1biLVh94YvRgxjAHTk9ipUv0kCJJ3OrRdj0PzqbP7qrrGdfabfAWNSPmakpxBKY3PijIbqhn(qGqbzOW1RaDQpeOXtdFqOyjOqoJwAWNSJwAr2ah94Yv3oUs0sd(KD0cSzUk9OrRR)j4t2rlSvPh5XTIEC5QRkUs0cBv6rECROLg8j7Of)0PnSe8JwHBC8gnA56JTtzauEU2GesNgqk2Q0JCOGmuSqVrLEKsOt760ggcfKHcokbwxtzauEU2GesNgq6He60mOGmuWrjW6AkdGYZ1gKq60aspKqNMbfKUdffbouixOy7Ovq7a(MPoA5tWwM5qcDAsjz0Jlx1UJReTWwLEKh3kAPbFYoAXaO8CTrkFpAfUXXB0OLRp2oLbq55AdsiDAaPyRspYHcYqXc9gv6rkHoTRtByiuqgk4OeyDnLbq55AdsiDAaPhsOtZGcYqbhLaRRPmakpxBqcPtdi9qcDAguq6ouGKigaD04dbcfYfk2gkack8txGVXhcekidfBafAWNSPmakpxBKY3PtBQ)PaGhTcahE046vGolUC1OhxUkjJReTWwLEKh3kAfUXXB0OLpeiuSeuSkscfKHczGIqMppx3ugibr2gUE2w86H0dj0PzqXs7qHDtsOOsfOiK5ZZ1nLbsqKTHRNTfVEi9qcDAguqkuiNqHSqbzOW1RaDQpeOXtdFqOyjOOkjakKluWkX)nauMJrln4t2rRsaA7jHHnDb4R34ah94YvjbXvIwyRspYJBfTc344nA0YhcekwckQssOGmu46vGo1hc04PHpiuS0ouuDZOLg8j7O1I5rJRt7rpUCv5qCLOf2Q0J84wrRWnoEJgT2akwO3OspsbzOHHihkidfSe8nma6XHIDOGKrln4t2rlWM5Q0JgTU(NGpzh94YvLZ4krlSvPh5XTIwHBC8gnATqVrLEKcYqddrouqgkyj4Bya0Jdf7qbjJwAWNSJwme5MS2eY7al9j7OhxUQCuCLOf2Q0J84wrln4t2rRG(Vrd(KT5hMhT(H5MwjWOfpDw0JlV9MXvIwyRspYJBfTc344nA0YhcekiDhkwfjJwAWNSJwLa02tcdB6cWxVXbo6XL3UACLOf2Q0J84wrRWnoEJgT8HaHcsHIQKmAPbFYoATyE0460E0JlV92XvIwyRspYJBfTc344nA0kK5ZZ1nLbsqKTHRNTfVEi9qcDAguqkuuDtOGmuWtNwcqBpjmSPlaF9ghy6He60mOOsfOW1RaDQpeOXtdFqOGuOy7nHcGGIIahkQubkyL4)gxVc0zugICtwBc5DGL(KTrtekwckQcfabfNoCdUaBNo9cWVXtLEKcwgT0GpzhT46zRHLGF0JlV9QIReT0GpzhTKWJHNTtxeTWwLEKh3k6XL32UJReTWwLEKh3kAPbFYoAf0)nAWNSn)W8O1pm30kbgTyLyZXJf94YBtY4krlSvPh5XTIwAWNSJwb9FJg8jBZpmpA9dZnTsGrR65F8yrp6rRYddjHK6XvIlxnUs0cBv6rECROhxE74krlSvPh5XTIEC5vfxjAHTk9ipUv0JlB3XvIwAWNSJwmqcISn14daSD8IwyRspYJBf94YKmUs0cBv6rECROv4ghVrJwU(y70IBiY5qtwByA4M6jGuSvPh5rln4t2rRIBiY5qtwByA4M6jGrpUmjiUs0cBv6rECROhxwoexjAPbFYoAvM(KD0cBv6rECROhxwoJReTWwLEKh3kAfUXXB0OfRe)346vGoJYqKBYAtiVdS0NSnAIqXs7qXQIwAWNSJwme5MS2eY7al9j7OhxwokUs0sd(KD0cGc2E0cBv6rECROhxU6MXvIwyRspYJBfTc344nA0AdOW1hBNcqbBNITk9ihkidfSs8FJRxb6mkdrUjRnH8oWsFY2OjcfKcfRkAPbFYoAXaO8CTrkFp6rpAfY8556MfxjUC14krlSvPh5XTIwHBC8gnAjdu46JTt56zRHLGVHyy4bmfBv6rouqgkcz(8CDtzGeezB46zBXRhsblHcYqriZNNRBkxpBnSe8PGLqHSqrLkqriZNNRBkdKGiBdxpBlE9qkyjuuPcu46vGo1hc04PHpiuqkuSQnJwAWNSJwLPpzh94YBhxjAHTk9ipUv0kCJJ3OrRqMppx3ugibr2gUE2w86H0dj0PzqXsqHCytOOsfOWhc04PHpiuqkuS9MqrLkqHmqHmqHeyDnvd(SanGkJYCnyluSdfKekQubkyj4Bya0Jdf7qXMqHSqbzOqgOydOW1hBNwcqBpjmSPlaF9ghyk2Q0JCOOsfOiK5ZZ1nTeG2Esyytxa(6noW0dj0PzqHSqbzOqgOydOW1hBNYr1biLVtXwLEKdfvQafHmFEUUPCuDas570dj0PzqbP7qrrGdfvQafBafHmFEUUPCuDas570dj0PzqHSqbzOydOiK5ZZ1nLbsqKTHRNTfVEi9qcDAguiB0sd(KD0cKHMXrcw0JlVQ4krlSvPh5XTIwHBC8gnATbueY8556MYajiY2W1Z2IxpKcwgT0GpzhTQNdL(m5rpUSDhxjAHTk9ipUv0kCJJ3OrRnGIqMppx3ugibr2gUE2w86HuWYOLg8j7OL0Nj3udEah9OhT4PZIRexUACLOf2Q0J84wrRWnoEJgT4Ptd5DGL(Kn9qcDAguq6ouObFYMYqKBYAtiVdS0NSPbL5gFiqOaiOWhc04PHbqpouaeuy30THc5cfYafvHc7ekC9X2PHdXYPlmCuDauSvPh5qHCHInPvjjuiluqgkyL4)gxVc0zugICtwBc5DGL(KTrtekwAhkwfuaeuC6Wn4cSD60la)gpv6rkyjuaeu46JTtxFJdantB0ISbMITk9ihkidfBaf80Pme5MS2eY7al9jB6He60mOGmuSbuObFYMYqKBYAtiVdS0NSPtBQ)PaGhT0GpzhTyiYnzTjK3bw6t2rpU82XvIwyRspYJBfT0GpzhT0ISboAfUXXB0OLRp2onCiwoDHHJQdGITk9ihkidfAWNfOHNovlYgyOGuOGeafKHcxVc0P(qGgpn8bHILGIQBcfKHczGIdj0PzqbP7qrrGdfvQafHmFEUUPmqcISnC9ST41dPhsOtZGILGIQBcfKHIdRpKbqLEekKnAfao8OX1RaDwC5QrpU8QIReTWwLEKh3kAPbFYoAPfzdC0kCJJ3OrRnGcxFSDA4qSC6cdhvhafBv6rouqgk0GplqdpDQwKnWqbPqHCcfKHcxVc0P(qGgpn8bHILGIQBcfKHczGIdj0PzqbP7qrrGdfvQafHmFEUUPmqcISnC9ST41dPhsOtZGILGIQBcfKHIdRpKbqLEekKnAfao8OX1RaDwC5QrpUSDhxjAHTk9ipUv0sd(KD0InLaY28tngTc344nA0sgOqd(San80PSPeq2MFQrOGuOqoHc7ekC9X2PHdXYPlmCuDauSvPh5qHDcfSs8FJRxb6mklxBCaOHHiNz0eHczHcYqHRxb6uFiqJNg(GqXsqr1nHcYqXH1hYaOspcfKHczGInGIdj0PzqbzOGvI)BC9kqNrziYnzTjK3bw6t2gnrOyhkQcfvQafHmFEUUPmqcISnC9ST41dPhsOtZGILGcwc(gga94qHCHcn4t2uWM5Q0JgTU(NGpztrsedGoA8HaHczJwbGdpAC9kqNfxUA0JltY4krlSvPh5XTIwAWNSJwH8oWsFYoAfUXXB0OfRe)346vGoJYqKBYAtiVdS0NSnAIqbPqXQGcGGIthUbxGTtNEb434PspsblHcGGcxFSD66BCaOzAJwKnWuSvPh5qbzOqgO4qcDAguq6ouue4qrLkqriZNNRBkdKGiBdxpBlE9q6He60mOyjOO6MqbzO4W6dzauPhHczHcYqHRxb6uFiqJNg(GqXsqr1nJwbGdpAC9kqNfxUA0JE0QE(hpwCL4YvJReTWwLEKh3kAPbFYoAb2mxLE0O11)e8j7Ov4ghVrJwHmFEUUPCuDas570dj0PzqbP7qrrGdfYfk2gkidfSs8FJRxb6mkdrUjRnH8oWsFY2Ojcf7qrvOaiO40HBWfy70Pxa(nEQ0JuWsOGmueY8556MYajiY2W1Z2IxpKEiHondkwck2EZO1pnAc8Ovvsg94YBhxjAHTk9ipUv0kCJJ3Orlwj(VX1RaDgLHi3K1MqEhyPpzB0eHIDOOkuaeuC6Wn4cSD60la)gpv6rkyjuqgkKbk4Pt1ISbMEiHondkifk4Pt1ISbMYbp1NSHc5cfBsLdKekQubk4Ptd5DGL(Kn9qcDAguqkuWtNgY7al9jBkh8uFYgkKluSjvoqsOOsfOGNoLnLaY28tnspKqNMbfKcf80PSPeq2MFQrkh8uFYgkKluSjvoqsOqwOGmueY8556MYr1biLVtpKqNMbfKUdfAWNSPAr2atlcCOqUqHDdfKHIqMppx3ugibr2gUE2w86H0dj0PzqXsqX2BgT0GpzhTc6)gn4t2MFyE06hMBALaJwCjZH1hYae94YRkUs0cBv6rECROv4ghVrJwSs8FJRxb6mkdrUjRnH8oWsFY2Ojcf7qrvOaiO40HBWfy70Pxa(nEQ0JuWsOGmueY8556MYajiY2W1Z2IxpKEiHondkiDhkyj4Bya0JdfYfk0Gpzt1ISbMwe4qbqqHg8jBQwKnW0IahkKluSkOGmuiduWtNQfzdm9qcDAguqkuWtNQfzdmLdEQpzdfYfkQcfvQaf80PH8oWsFYMEiHondkifk4Ptd5DGL(KnLdEQpzdfYfkQcfvQaf80PSPeq2MFQr6He60mOGuOGNoLnLaY28tns5GN6t2qHCHIQqHSrln4t2rRG(Vrd(KT5hMhT(H5MwjWOfxYCy9HmarpUSDhxjAHTk9ipUv0kCJJ3OrRqMppx3ugibr2gUE2w86H0dj0PzqXs7qXQ2ekackkcCOOsfOiK5ZZ1nLbsqKTHRNTfVEi9qcDAguSeuu1U3mAPbFYoAXr1biLVh94YKmUs0cBv6rECROv4ghVrJwsG11uICbsGTtblHcYqHeyDnTNcaET(p9qcDAw0sd(KD0Ibq55AJu(E0JltcIReTWwLEKh3kAfUXXB0OLeyDnLixGey7uWsOGmuSbuidu46JTtztjGSn)uJuSvPh5qbzOqgOO8WfMIaNwLQfzdmuqgkkpCHPiWPBt1ISbgkidfLhUWue40vr1ISbgkKfkQubkkpCHPiWPvPAr2adfYgT0GpzhT0ISbo6XLLdXvIwyRspYJBfTc344nA0scSUMsKlqcSDkyjuqgk2akKbkkpCHPiWPvPSPeq2MFQrOGmuuE4ctrGt3MYMsazB(PgHcYqr5HlmfboDvu2uciBZp1iuiB0sd(KD0InLaY28tng94YYzCLOf2Q0J84wrRWnoEJgTKaRRPe5cKaBNcwcfKHInGIYdxykcCAvAiVdS0NSHcYqXgqHRp2ovLy5d6OjK3bw6t2uSvPh5rln4t2rRqEhyPpzh94YYrXvIwyRspYJBfTc344nA0sgOqcSUMonUyCv6rdhjggszUgSfkwAhkKtscf2juiduWkX)nUEfOZOme5MS2eY7al9jBJMiuyNqXPd3GlW2PtVa8B8uPhPGLqXsqX2qHSqHCHIT3ekidfYafHmFEUUPCuDas570dj0PzqXsqbsIya0rJpeiuuPcuSbu46JTt5O6aKY3PyRspYHczHcYqHmqriZNNRBAjaT9KWWMUa81BCGPhsOtZGILGcKeXaOJgFiqOOsfOydOW1hBNwcqBpjmSPlaF9ghyk2Q0JCOqwOGmuidueY8556MY1ZwdlbF6He60mOyjOajrma6OXhcekQubk2akC9X2PC9S1WsW3qmm8aMITk9ihkKfkidfYafHmFEUUPlMhnUoTtpKqNMbflbfijIbqhn(qGqrLkqXgqHRp2oDX8OX1PDk2Q0JCOqwOGmueY8556MYajiY2W1Z2IxpKEiHondkwckqsedGoA8HaHcGGIQBcfvQafsG110PXfJRspA4iXWqkZ1GTqXsqXQ2ekidfUEfOt9HanEA4dcfKUdfv3ekKnAPbFYoAXpDAZp1y0JlxDZ4krln4t2rlaky7rlSvPh5XTIEC5QvJReTWwLEKh3kAPbFYoAXpDAdlb)Ova4WJgxVc0zXLRgTM2X7al9Ov1Ov4ghVrJwUEfOt9HanEA4dcfKUdffbE0kaqNoAvnAnTJ3bw6MIpL0pAvn6XLRUDCLOf2Q0J84wrRaaD6Ov1O10oEhyPBM6OLpbBzMdj0PjLKrRWnoEJgTC9X2PmakpxBqcPtdifBv6rouqgkwO3Ospsj0PDDAddHcYqXgqbhLaRRPmakpxBqcPtdi9qcDAw0sd(KD0IF60gwc(rRPD8oWs3u8PK(rRQrpUC1vfxjAHTk9ipUv0kaqNoAvnAnTJ3bw6MPoA5tWwM5qcDAsjz0kCJJ3OrlxFSDkdGYZ1gKq60asXwLEKdfKHIf6nQ0JucDAxN2WWOLg8j7Of)0PnSe8Jwt74DGLUP4tj9JwvJEC5Q2DCLOf2Q0J84wrln4t2rl(PtByj4hTM2X7al9Ov1OvaGoD0QA0AAhVdS0nfFkPF0QA0JlxLKXvIwyRspYJBfT0GpzhTyauEU2iLVhTc344nA0Y1hBNYaO8CTbjKonGuSvPh5qbzOyHEJk9iLqN21PnmekidfBafCucSUMYaO8CTbjKonG0dj0PzqbzOydOqd(KnLbq55AJu(oDAt9pfa8Ova4WJgxVc0zXLRg94YvjbXvIwyRspYJBfTc344nA0Y1hBNYaO8CTbjKonGuSvPh5qbzOyHEJk9iLqN21PnmmAPbFYoAXaO8CTrkFp6XLRkhIReT0GpzhTyauEU2iLVhTWwLEKh3k6rpAXkXMJhlUsC5QXvIwyRspYJBfTc344nA0kK5ZZ1nLbsqKTHRNTfVEi9qcDAguq6ouWsW3WaOhhkKluGKigaD04dbcfKHczGInGcxFSDkhvhGu(ofBv6rouuPcueY8556MYr1biLVtpKqNMbfKUdfSe8nma6XHc5cfijIbqhn(qGqHSrln4t2rlWM5Q0JgTU(NGpzh94YBhxjAHTk9ipUv0kCJJ3OrlzGIqMppx3ugibr2gUE2w86H0dj0PzqbPqHpeOXtddGECOqUqHmqbjakStOGLGVHbqpouiluuPcueY8556MYajiY2W1Z2IxpKcwcfYcfKHcFiqJNg(GqXsqriZNNRBkdKGiBdxpBlE9q6He60SOLg8j7Ovq)3ObFY28dZJw)WCtRey0QE(hpw0JlVQ4krlSvPh5XTIwHBC8gnATqVrLEKcYqddrE0sd(KD0IHi3K1MqEhyPpzh94Y2DCLOf2Q0J84wrRWnoEJgT2akwO3OspsbzOHHihkidfBafLhUWue40Qugibr2gUE2w86HqbzOqgOW1hBNYr1biLVtXwLEKdfKHIqMppx3uoQoaP8D6He60mOG0DOajrma6OXhcekidfBaf6QbVXrAqzbLpDHjOVsmoWuSvPh5qrLkqHmqblbFddGECOyPDOGKqbzOGvI)BC9kqNrziYnzTjK3bw6t2gnrOGuOyBOOsfOGLGVHbqpouS0ouSnuqgkyL4)gxVc0zugICtwBc5DGL(KTrtekwAhk2gkKfkidfUEfOt9HanEA4dcflbf2nuaeuGKigaD04dbcfKHcwj(VX1RaDgLHi3K1MqEhyPpzB0eHIDOOkuuPcu46vGo1hc04PHpiuq6ouiNqbqqbsIya0rJpeiuixOGLGVHbqpouiB0sd(KD0cSzUk9OrRR)j4t2rpUmjJReTWwLEKh3kAfUXXB0O1gqXc9gv6rkidnme5qbzOiKTRft2qbP7qrqzUXhcekackwO3OspslvoF6IOLg8j7OfyZCv6rJwx)tWNSJECzsqCLOf2Q0J84wrln4t2rlWM5Q0JgTU(NGpzhTc344nA0AdOyHEJk9ifKHggICOGmuiduSbu46JTt5O6aKY3PyRspYHIkvGIqMppx3uoQoaP8D6He60mOyjOWhc04PHbqpouuPcuWsW3WaOhhkwckQcfYcfKHczGInGcxFSD6I5rJRt7uSvPh5qrLkqblbFddGECOyjOOkuiluqgkcz7AXKnuq6oueuMB8HaHcGGIf6nQ0J0sLZNUakidfYafBaf6QbVXrAqzbLpDHjOVsmoWuSvPh5qrLkqHeyDnnOSGYNUWe0xjghy6He60mOyjOWhc04PHbqpouiB0kaC4rJRxb6S4YvJE0JE0JEmc]] )

end