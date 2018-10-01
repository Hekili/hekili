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


    spec:RegisterPack( "Affliction", 20180930.2247, [[diK7)aqibXJevuBcPmksQofjLvPssVcQQzHu5wIkYUe5xqLgMOshtqTmrv9mOIMMukUMukTnOc5BQKGXbvW5evG1jQqnpPuDpPyFKKoOOcAHIQ8qOcfxuuHOtkQqyLKeZeQqPDIu1qfviTuvsONcLPki9vOcv7LWFjAWK6WuwmsEmktwOld2SO8zbgTk1PL8AOkZwv3wf7wPFRy4svlhYZr10P66Ky7sjFxLy8QK68sLwVkjA(sf7hXIWIqfyrZbb95NByCi3CaoZnLF(Tbh1wbM3They9gdplaeyRDabwoml7lMxZkW6TU)yrrOcm(OGyGa729EEogxCdk)wHkXMdU86O8MxZYqwMJlVomCP(HcxQmlNIqlC7rtw9ah3qlaLFyCdn)WsCCd9ddpzoml7lMxZM41HjWOuQ3ZrSckbw0CqqF(5gghYnhGZCt5NFBYVnTvGX7bMG(8XrTvGDxXiSckbwe4mbwot05WSSVyEnlrJJBOFy4rujNj6B3755yCXnO8BfQeBo4YRJYBEnldzzoU86WWL6hkCPYSCkcTWThnz1dCCZrrWv0Qih3C0ROeh3q)WWtMdZY(I51SjEDyevYzIgd6D4qbiIgN5shrNFUHXbIoNi68Zph3MWeviQKZenoMBBdaEoMOsot05erNdJris0y9W)eno2HHxIOsot05erFfHZ0cIeTBOaWLvwkLey9OjREqGLZeDoml7lMxZs044g6hgEevYzI(29EEogxCdk)wHkXMdU86O8MxZYqwMJlVomCP(HcxQmlNIqlC7rtw9ah3CueCfTkYXnh9kkXXn0pm8K5WSSVyEnBIxhgrLCMOXGEhouaIOXzU0r05NByCGOZjIo)8ZXTjmrfIk5mrJJ522aGNJjQKZeDor05WyeIenwp8prJJDy4LiQKZeDor0xr4mTGir7gkaCzLLsjIkevYzIoh51atXHirtbzdciA2COmNOPGGA5jIohYyqVZj6D2C62qNmLNOnMxZYj6z)UjIkgZRz5PEeWMdL5nzVXXJOIX8AwEQhbS5qzo(n4MntKOIX8AwEQhbS5qzo(n4AkbhyDZRzjQymVMLN6raBouMJFdUCLZzwzp4evmMxZYt9iGnhkZXVb3auDMcbYjtYngQYkgqxL142dRNcq1zkeiNmj3yOkRyqcwJ6HirfJ51S8upcyZHYC8BWLVwp)ECj3nNtuXyEnlp1Ja2COmh)gC7hVMLOIX8AwEQhbS5qzo(n4YbikNmjBqiLEVMLUkRH3d)lDdfaopXbikNmjBqiLEVMvAdOAdojQymVMLN6raBouMJFdU3MY6evmMxZYt9iGnhkZXVbx(TfNlsQ5D6QSMqC7H1t3MY6jynQhI049W)s3qbGZtCaIYjtYgesP3RzL2aTJtIkevYzIoh51atXHirdTauxI2Rdq0(nq0gZherxCI2Az1BupKiQymVML3W7H)L)WWJOIX8Awo(n42YqLr9aDRDGgEVDog1dsoar6AzVc042dRN4ZfPFdsoarEcwJ6HinEp8V0nua48ehGOCYKSbHu69AwPnGQn4Sth3Ey9eV6VNv(vgKG1OEisJ3d)lDdfaopXbikNmjBqiLEVMv1M22PdVh(x6gkaCEIdquozs2Gqk9EnRQn4arfJ51SC8BWTLHkJ6b6w7an9wmwBaDtFdhC6AzVc0ymVMnXVT4CrsnVNGRbMIdsVoWvTReqLdjMXzwS2ajZE7uE3eSg1drIkgZRz543GBldvg1d0T2bA6TyS2a6M(geWbNUw2RanbSiDvwJDLaQCiXmoZI1giz2BNY7MG1OEistD3Ey9uez1k5JYNG1OEi2PJBpSEkcMFtnVNG1OEisJnZhNlBkcMFtnVNqWXQL3EtalQgrfJ51SC8BWTF8Aw6QSg1D7H1trdHNKpkV8uCa1nbRr9qKgBMpox2ex5CMvgneEbVHGKspn2mFCUSPOHWtYhLpP0RwNoSz(4CztCLZzwz0q4f8gcsk9D64gka8Kxhq6Jmwq74mxIkgZRz543GRchKLdhoDvwtiSz(4CztCLZzwz0q4f8gcsk9evmMxZYXVb3Scbu)mr6QSMqyZ8X5YM4kNZSYOHWl4neKu6jQymVMLJFdUu)mrzMcQlDvwtiSz(4CztCLZzwz0q4f8gcsk9evmMxZYXVb3iYQvYhLNUADaHu6DzWpu23eMo2TvBty6yDzpiDdfaoVjmDvwJBOaWtEDaPpYybT3eWI04JYl53gk2EBjQymVMLJFdU3MY6evmMxZYXVbxUY5mRmAi8cEdb0vznXXtwWSDtEXWR2aAXXtSbHu69A2Kxm8QnGM6ukzzjJ5vlqQy8e3ngEnTTth(O8s(THIn5Qgn1dXThwp1FBRphjV2aL3qL3nbRr9qSth2mFCUSP(BB95i51gO8gQ8UjeCSA5QruXyEnlh)gCTGz7shRl7bPBOaW5nHPRYAqWXQL3EtalsuXyEnlh)gC53wCUiPM3PJ1L9G0nua48MW0vznU9W6j(TfNls4qHmgKG1OEisZThwpzu85vCqYgesP3RztWAupePzmVAbsyHtb8M8PfbkLSSe)2IZfjCOqgdsi4y1YPfbkLSSe)2IZfjCOqgdsi4y1YBVbUgykoi96axnF8DK1cEPxhGwigZRzt8BloxKuZ7PALzFfC7evmMxZYXVb3(BB95i51gO8gQ8U0vznEDavBtU0uNnZhNlBIRCoZkJgcVG3qqcbhRwUQnTPTD6WM5JZLnXvoNzLrdHxWBiiHGJvlVDCqnIkgZRz543GBR6bPB160vznEDavZpxIkgZRz543GlhGOCYKSbHu69Aw6QSM44j2Gqk9EnBcbhRwE7ngZRztCaIYjtYgesP3RztmJ7sVoa(EDaPps(THI43Mu(xv9W5KBpSEIHaOV2azem)obRr9q8Q5Mc3w1OX7H)LUHcaNN4aeLtMKniKsVxZkTbuTbN472dRNUGk)gK1kTGz7MG1OEislK44joar5KjzdcP071SjeCSA50cXyEnBIdquozs2Gqk9EnBQwz2xb3orfJ51SC8BW1cMTlDSUShKUHcaN3eMUJDTK1L9G0nua48gCeDvwJBpSEIHaOV2azem)obRr9qKMBOaWtEDaPpYybQgoxAiidb8BJ6bIkgZRz543GRfmBx6yDzpiDdfaoVjmDh7AjRl7bPBOaW5n4aDvwJ6H42dRNyia6RnqgbZVtWAupevJMBOaWtEDaPpYybQgoxAiidb8BJ6bIkgZRz543GlV6VNv(vgqhRl7bPBOaW5nHP7yxlzDzpiDdfaoVjmDvwdcYqa)2OEGMBOaWtEDaPpYybQgoxAQREiQZM5JZLnXvoNzLrdHxWBiiHGJvlV9g(O8s(THIx1yEnBsz5Ur9G0YY(I51Sj4AGP4G0RdOgnJ5vlqclCkGRAdoOwNogZRwGew4uaVjSAevmMxZYXVbxE1FpR8RmGowx2ds3qbGZBct3XUwY6YEq6gkaCEt(0vzniidb8BJ6bAUHcap51bK(iJfOA4CPPU6HOoBMpox2ex5CMvgneEbVHGecowT82B4JYl53gkEvJ51SjLL7g1dsll7lMxZMGRbMIdsVoGA0mMxTajSWPaEZvqToDmMxTajSWPaEt(QruXyEnlh)gC5v)9SYVYa6yDzpiDdfaoVjmDh7AjRl7bPBOaW5n4KUkRbbziGFBupqZnua4jVoG0hzSavdNln1vpe1zZ8X5YM4kNZSYOHWl4neKqWXQL3EdFuEj)2qXRAmVMnPSC3OEqAzzFX8A2eCnWuCq61buJMX8QfiHfofWBWrQ1PJX8QfiHfofWBWPAevmMxZYXVbxE1FpR8RmGowx2ds3qbGZBct3XUwY6YEq6gkaCEtBORYAqqgc43g1d0CdfaEYRdi9rglq1W5stD1drD2mFCUSjUY5mRmAi8cEdbjeCSA5T3WhLxYVnu8QgZRztkl3nQhKww2xmVMnbxdmfhKEDa1OzmVAbsyHtb8M2QwNogZRwGew4uaVPnQruXyEnlh)gCzdcP071S0X6YEq6gkaCEty6QSgJ5vlqclCkG3ooX3ThwpDbv(niRvAbZ2nbRr9qKgcYqa)2OEGMBOaWtEDaPpYybQgoxIkgZRz543GB)TT(CK8AduEdvEx6QSgVoq7nTjxIkgZRz543GBR6bPB16evmMxZYXVb3OHWtYhLNOIX8Awo(n4sbioGWR2aIkgZRz543GRYYDJ6bPLL9fZRzPRYA4JYl53gkQAtBjQymVMLJFdUkl3nQhKww2xmVMLUkRHnZhNlBIRCoZkJgcVG3qqcbhRwE7n8r5L8BdfVkCnWuCq61biQymVMLJFdUm7FPX8Aw5xCNU1oqtw9pG40vznQZM5JZLnXvoNzLrdHxWBiiHGJvlVDVoG0hj)2qXRQEBZj(O8s(THIQ1PdBMpox2ex5CMvgneEbVHGKsVA086asFKXcuLnZhNlBIRCoZkJgcVG3qqcbhRworfJ51SC8BWLdquozs2Gqk9EnlDvwtldvg1djEVDog1dsoarIkgZRz543GRYYDJ6bPLL9fZRzPRYAcPhbTKbSykCIRCoZkJgcVG3qaTqAzOYOEiX7TZXOEqYbistD3Ey9uem)MAEpbRr9qKgBMpox2uem)MAEpHGJvlV9g4AGP4G0Rdqle7kbu5qIzCMfRnqYS3oL3nbRr9qSth(O8s(THIQ2Kpn3qbGN86asFKXcuTn4dxdmfhKEDaAgZRwGew4uaVjCNoUHcap51bK(iJf0EdoGpCnWuCq61bUkFuEj)2qr1iQymVMLJFdUkl3nQhKww2xmVMLUkRjKwgQmQhs8E7CmQhKCaI0yZ6wqnB7nmJ7sVoa(TmuzupK6TyS2aIkgZRz543GRYYDJ6bPLL9fZRzPJ1L9G0nua48MW0vznH0YqLr9qI3BNJr9GKdqKM6H42dRNIG53uZ7jynQhID6WM5JZLnfbZVPM3ti4y1Yv1Rdi9rYVnuSth(O8s(THIQgwnASzDlOMT9gMXDPxha)wgQmQhs9wmwBan1dXUsavoKygNzXAdKm7Tt5DtWAupe70HsjllXmoZI1giz2BNY7MqWXQLRQxhq6JKFBOOAevmMxZYXVbxM9V0yEnR8lUt3AhOjR(hqCIkevmMxZYtz1)aI3ybZ2LUkRbbhRwE7HXbASz(4CztCLZzwz0q4f8gcsi4y1YvTbN5IFalsJnZhNlBkcMFtnVNqWXQL3EtalslKEe0sgWIPWjUY5mRmAi8cEdb0cPhbTKbSykCYcMTln1TReqLdjUsmcRCwo4jKT4PA4oDSReqLdjUsmcRCwo4jKT41eMwiU9W6jE1FpR8RmibRr9qunIkgZRz5PS6FaXXVb3iy(n18oDvwdBMpox2ex5CMvgneEbVHGecowTCvBWzU4hWID6WM5JZLnXvoNzLrdHxWBiiHGJvlx1WTjxIkgZRz5PS6FaXXVbx(TfNlsQ5D6QSgkLSS0zAbhy9KspnkLSS0wb3EM9FcbhRworfJ51S8uw9pG443GRfmBx6QSgkLSS0zAbhy9KspTqu3ThwpXR(7zLFLbjynQhI0uVhbTKbSykCYcMTlTEe0sgWIP8twWSDP1JGwYawmHZKfmBx160PhbTKbSykCYcMTRAevmMxZYtz1)aIJFdU8Q)Ew5xzaDvwdLsww6mTGdSEsPNwiQ3JGwYawmfoXR(7zLFLb06rqlzalMYpXR(7zLFLb06rqlzalMWzIx93Zk)kduJOIX8AwEkR(hqC8BWLniKsVxZsxL1qPKLLotl4aRNu6PfspcAjdyXu4eBqiLEVMLwiU9W6jJIpVIds2Gqk9EnBcwJ6HirfJ51S8uw9pG443GBez1k)kdORYAuNsjllvl0QCJ6bzeofhsC3y4PAtoixAQZM5JZLnfbZVPM3ti4y1YvfUgykoi96aD6eIBpSEkcMFtnVNG1OEiQgn1zZ8X5YM6VT1NJKxBGYBOY7MqWXQLRkCnWuCq61b60je3Ey9u)TT(CK8AduEdvE3eSg1dr1OPoBMpox2u0q4j5JYNqWXQLRkCnWuCq61b60je3Ey9u0q4j5JYlpfhqDtWAupevJM6Sz(4CztTQhKUvRNqWXQLRkCnWuCq61b60je3Ey9uR6bPB16jynQhIQrJnZhNlBIRCoZkJgcVG3qqcbhRwUQW1atXbPxha)W52PdLswwQwOv5g1dYiCkoK4UXWtvCMln3qbGN86asFKXcAVjCUQruXyEnlpLv)dio(n4grwTs(O80vRdiKsVld(HY(MW0XUTABcthRl7bPBOaW5nHPRYACdfaEYRdi9rglO9MawKOIX8AwEkR(hqC8BWnISAL8r5PRwhqiLExg8dL9nHPJDB12eMOIX8AwEkR(hqC8BWLFBX5IKAENowx2ds3qbGZBctxL142dRN43wCUiHdfYyqcwJ6Hin3Ey9KrXNxXbjBqiLEVMnbRr9qKMX8QfiHfofWBYNwirGsjllXVT4CrchkKXGecowTCAHymVMnXVT4CrsnVNQvM9vWTtuXyEnlpLv)dio(n4YVT4CrsnVthRl7bPBOaW5nHPRYAC7H1t8BloxKWHczmibRr9qKMBpSEYO4ZR4GKniKsVxZMG1OEisZyE1cKWcNc4n5tuXyEnlpLv)dio(n4YVT4CrsnVlWAbiEnRG(8ZnmoKBoiCBsHZnCBfyxm0wBaxGLJ40pihIenojAJ51Se9xCNNiQiW(I7CrOcSS6FaXfHkOpSiubgSg1drrEcmgQCavMadbhRwor3orhghiAAenBMpox2ex5CMvgneEbVHGecowTCIw1gIgN5s04t0bSirtJOzZ8X5YMIG53uZ7jeCSA5eD7neDals00i6qi6Ee0sgWIPWjUY5mRmAi8cEdbennIoeIUhbTKbSykCYcMTlrtJOvNOTReqLdjUsmcRCwo4jKT4r0Qs0Hj6oDiA7kbu5qIReJWkNLdEczlEeDdrhMOPr0Hq0U9W6jE1FpR8RmibRr9qKOvtGzmVMvGzbZ2v4c6ZxeQadwJ6HOipbgdvoGktGXM5JZLnXvoNzLrdHxWBiiHGJvlNOvTHOXzUen(eDals0D6q0Sz(4CztCLZzwz0q4f8gcsi4y1YjAvj6WTjxbMX8Awbwem)MAEx4c6XPiubgSg1drrEcmgQCavMaJsjllDMwWbwpP0t00iAkLSS0wb3EM9FcbhRwUaZyEnRaJFBX5IKAEx4c6BJiubgSg1drrEcmgQCavMaJsjllDMwWbwpP0t00i6qiA1jA3Ey9eV6VNv(vgKG1OEis00iA1j6Ee0sgWIPWjly2UennIUhbTKbSyk)KfmBxIMgr3JGwYawmHZKfmBxIwnIUthIUhbTKbSykCYcMTlrRMaZyEnRaZcMTRWf03wrOcmynQhII8eymu5aQmbgLsww6mTGdSEsPNOPr0Hq0Qt09iOLmGftHt8Q)Ew5xzartJO7rqlzalMYpXR(7zLFLbennIUhbTKbSycNjE1FpR8RmGOvtGzmVMvGXR(7zLFLbcxqposeQadwJ6HOipbgdvoGktGrPKLLotl4aRNu6jAAeDieDpcAjdyXu4eBqiLEVMLOPr0Hq0U9W6jJIpVIds2Gqk9EnBcwJ6HOaZyEnRaJniKsVxZkCb9xbrOcmynQhII8eymu5aQmbM6enLswwQwOv5g1dYiCkoK4UXWJOvTHOZb5s00iA1jA2mFCUSPiy(n18EcbhRworRkrdxdmfhKEDaIUthIoeI2ThwpfbZVPM3tWAupejA1iAAeT6enBMpox2u)TT(CK8AduEdvE3ecowTCIwvIgUgykoi96aeDNoeDieTBpSEQ)2wFosETbkVHkVBcwJ6HirRgrtJOvNOzZ8X5YMIgcpjFu(ecowTCIwvIgUgykoi96aeDNoeDieTBpSEkAi8K8r5LNIdOUjynQhIeTAennIwDIMnZhNlBQv9G0TA9ecowTCIwvIgUgykoi96aeDNoeDieTBpSEQv9G0TA9eSg1drIwnIMgrZM5JZLnXvoNzLrdHxWBiiHGJvlNOvLOHRbMIdsVoarJprhoxIUthIMsjllvl0QCJ6bzeofhsC3y4r0Qs04mxIMgr7gka8Kxhq6Jmwar3EdrhoxIwnbMX8Awbwez1k)kdeUGECqeQadwJ6HOipbMX8Awbwez1k5JYlWyDzpiDdfaoxqFybgdvoGktG5gka8Kxhq6Jmwar3EdrhWIcm2TvRalSaRwhqiLExg8dL9cSWcxqFoqeQadwJ6HOipbMX8Awbwez1k5JYlWy3wTcSWcSADaHu6DzWpu2lWclCb9HZveQadwJ6HOipbMX8Awbg)2IZfj18UaJHkhqLjWC7H1t8BloxKWHczmibRr9qKOPr0U9W6jJIpVIds2Gqk9EnBcwJ6HirtJOnMxTajSWPaor3q05t00i6qi6iqPKLL43wCUiHdfYyqcbhRwortJOdHOnMxZM43wCUiPM3t1kZ(k42fySUShKUHcaNlOpSWf0hoSiubgSg1drrEcmJ51Scm(TfNlsQ5DbgdvoGktG52dRN43wCUiHdfYyqcwJ6HirtJOD7H1tgfFEfhKSbHu69A2eSg1drIMgrBmVAbsyHtbCIUHOZxGX6YEq6gkaCUG(WcxqF48fHkWmMxZkW43wCUiPM3fyWAupef5jCHlWIqMP8Uiub9HfHkWmMxZkW49W)YFy4jWG1OEikYt4c6ZxeQadwJ6HOipbwl7vabMBpSEIpxK(ni5ae5jynQhIennIM3d)lDdfaopXbikNmjBqiLEVMvAdq0Q2q04KO70HOD7H1t8Q)Ew5xzqcwJ6HirtJO59W)s3qbGZtCaIYjtYgesP3RzjAvBi62s0D6q08E4FPBOaW5joar5KjzdcP071SeTQnenoiWmMxZkWAzOYOEqG1YqY1oGaJ3BNJr9GKdqu4c6XPiubgSg1drrEcSPxGXbxGzmVMvG1YqLr9GaRL9kGaZyEnBIFBX5IKAEpbxdmfhKEDaI(QeTDLaQCiXmoZI1giz2BNY7MG1OEikWAzi5AhqG1BXyTbcxqFBeHkWG1OEikYtGn9cmeWbxGzmVMvG1YqLr9GaRL9kGalGffymu5aQmbMDLaQCiXmoZI1giz2BNY7MG1OEis00iA1jA3Ey9uez1k5JYNG1OEis0D6q0U9W6Piy(n18EcwJ6HirtJOzZ8X5YMIG53uZ7jeCSA5eD7neDals0QjWAzi5AhqG1BXyTbcxqFBfHkWG1OEikYtGXqLdOYeyQt0U9W6POHWtYhLxEkoG6MG1OEis00iA2mFCUSjUY5mRmAi8cEdbjLEIMgrZM5JZLnfneEs(O8jLEIwnIUthIMnZhNlBIRCoZkJgcVG3qqsPNO70HODdfaEYRdi9rglGOBNOXzUcmJ51ScS(XRzfUGECKiubgSg1drrEcmgQCavMaleIMnZhNlBIRCoZkJgcVG3qqsPxGzmVMvGPWbz5WHlCb9xbrOcmynQhII8eymu5aQmbwienBMpox2ex5CMvgneEbVHGKsVaZyEnRalRqa1ptu4c6XbrOcmynQhII8eymu5aQmbwienBMpox2ex5CMvgneEbVHGKsVaZyEnRaJ6NjkZuqDfUG(CGiubgSg1drrEcmJ51ScSiYQvYhLxGX6YEq6gkaCUG(WcmgQCavMaZnua4jVoG0hzSaIU9gIoGfjAAenFuEj)2qrIUDIUTcm2TvRalSaRwhqiLExg8dL9cSWcxqF4CfHkWmMxZkWUnL1fyWAupef5jCb9HdlcvGbRr9quKNaJHkhqLjWIJNSGz7M8IHxTbennIooEIniKsVxZM8IHxTbennIwDIMsjllzmVAbsfJN4UXWJOBi62s0D6q08r5L8Bdfj6gIoxIwnIMgrRorhcr72dRN6VT1NJKxBGYBOY7MG1OEis0D6q0Sz(4Czt9326ZrYRnq5nu5Dti4y1YjA1eygZRzfyCLZzwz0q4f8gceUG(W5lcvGbRr9quKNaZyEnRaZcMTRaJHkhqLjWqWXQLt0T3q0bSOaJ1L9G0nua4Cb9HfUG(W4ueQadwJ6HOipbMX8Awbg)2IZfj18UaJHkhqLjWC7H1t8BloxKWHczmibRr9qKOPr0U9W6jJIpVIds2Gqk9EnBcwJ6HirtJOnMxTajSWPaor3q05t00i6iqPKLL43wCUiHdfYyqcbhRwortJOJaLswwIFBX5IeouiJbjeCSA5eD7nenCnWuCq61bi6Rs05t04t0oYAbV0Rdq00i6qiAJ51Sj(TfNlsQ59uTYSVcUDbgRl7bPBOaW5c6dlCb9HBJiubgSg1drrEcmgQCavMaZRdq0Qs0TjxIMgrRorZM5JZLnXvoNzLrdHxWBiiHGJvlNOvTHOBtBj6oDiA2mFCUSjUY5mRmAi8cEdbjeCSA5eD7enoq0QjWmMxZkW6VT1NJKxBGYBOY7kCb9HBRiubgSg1drrEcmgQCavMaZRdq0Qs05NRaZyEnRaRv9G0TADHlOpmoseQadwJ6HOipbgdvoGktGfhpXgesP3Rzti4y1Yj62BiAJ51Sjoar5KjzdcP071SjMXDPxhGOXNO96asFK8BdfjA8j62KYNOVkrRorhMOZjI2ThwpXqa0xBGmcMFNG1OEis0xLOZnfUTeTAennIM3d)lDdfaopXbikNmjBqiLEVMvAdq0Q2q04KOXNOD7H1txqLFdYALwWSDtWAupejAAeDieDC8ehGOCYKSbHu69A2ecowTCIMgrhcrBmVMnXbikNmjBqiLEVMnvRm7RGBxGzmVMvGXbikNmjBqiLEVMv4c6dFfeHkWG1OEikYtGzmVMvGzbZ2vGX6YEq6gkaCUG(WcSJDTK1L9G0nua4CbgosGXqLdOYeyU9W6jgcG(AdKrW87eSg1drIMgr7gka8Kxhq6JmwarRkrhoxIMgrJGmeWVnQheUG(W4GiubgSg1drrEcmJ51Scmly2Ucmwx2ds3qbGZf0hwGDSRLSUShKUHcaNlWWbbgdvoGktGPorhcr72dRNyia6RnqgbZVtWAupejA1iAAeTBOaWtEDaPpYybeTQeD4CjAAencYqa)2OEq4c6dNdeHkWG1OEikYtGzmVMvGXR(7zLFLbcmwx2ds3qbGZf0hwGDSRLSUShKUHcaNlWclWyOYbuzcmeKHa(Tr9artJODdfaEYRdi9rglGOvLOdNlrtJOvNOvNOdHOvNOzZ8X5YM4kNZSYOHWl4neKqWXQLt0T3q08r5L8Bdfj6Rs0gZRztkl3nQhKww2xmVMnbxdmfhKEDaIwnIMgrBmVAbsyHtbCIw1gIghiA1i6oDiAJ5vlqclCkGt0neDyIwnHlOp)CfHkWG1OEikYtGzmVMvGXR(7zLFLbcmwx2ds3qbGZf0hwGDSRLSUShKUHcaNlWYxGXqLdOYeyiidb8BJ6bIMgr7gka8Kxhq6JmwarRkrhoxIMgrRorRorhcrRorZM5JZLnXvoNzLrdHxWBiiHGJvlNOBVHO5JYl53gks0xLOnMxZMuwUBupiTSSVyEnBcUgykoi96aeTAennI2yE1cKWcNc4eDdrFfiA1i6oDiAJ5vlqclCkGt0neD(eTAcxqF(HfHkWG1OEikYtGzmVMvGXR(7zLFLbcmwx2ds3qbGZf0hwGDSRLSUShKUHcaNlWWPaJHkhqLjWqqgc43g1dennI2nua4jVoG0hzSaIwvIoCUennIwDIwDIoeIwDIMnZhNlBIRCoZkJgcVG3qqcbhRwor3EdrZhLxYVnuKOVkrBmVMnPSC3OEqAzzFX8A2eCnWuCq61biA1iAAeTX8QfiHfofWj6gIghr0Qr0D6q0gZRwGew4uaNOBiACs0QjCb95NViubgSg1drrEcmJ51ScmE1FpR8RmqGX6YEq6gkaCUG(WcSJDTK1L9G0nua4CbwBeymu5aQmbgcYqa)2OEGOPr0UHcap51bK(iJfq0Qs0HZLOPr0Qt0Qt0Hq0Qt0Sz(4CztCLZzwz0q4f8gcsi4y1Yj62BiA(O8s(THIe9vjAJ51SjLL7g1dsll7lMxZMGRbMIdsVoarRgrtJOnMxTajSWPaor3q0TLOvJO70HOnMxTajSWPaor3q0THOvt4c6ZhNIqfyWAupef5jWmMxZkWydcP071ScmgQCavMaZyE1cKWcNc4eD7enojA8jA3Ey90fu53GSwPfmB3eSg1drIMgrJGmeWVnQhiAAeTBOaWtEDaPpYybeTQeD4CfySUShKUHcaNlOpSWf0NFBeHkWG1OEikYtGXqLdOYeyEDaIU9gIUn5kWmMxZkW6VT1NJKxBGYBOY7kCb953wrOcmJ51ScSw1ds3Q1fyWAupef5jCb95JJeHkWmMxZkWIgcpjFuEbgSg1drrEcxqF(xbrOcmJ51ScmkaXbeE1giWG1OEikYt4c6ZhheHkWG1OEikYtGXqLdOYey8r5L8BdfjAvBi62kWmMxZkWuwUBupiTSSVyEnRWf0NFoqeQadwJ6HOipbgdvoGktGXM5JZLnXvoNzLrdHxWBiiHGJvlNOBVHO5JYl53gks0xLOHRbMIdsVoGaZyEnRatz5Ur9G0YY(I51ScxqpoZveQadwJ6HOipbgdvoGktGPorZM5JZLnXvoNzLrdHxWBiiHGJvlNOBNO96asFK8Bdfj6Rs0Qt0TLOZjIMpkVKFBOirRgr3PdrZM5JZLnXvoNzLrdHxWBiiP0t0Qr00iAVoG0hzSaIwvIMnZhNlBIRCoZkJgcVG3qqcbhRwUaZyEnRaJz)lnMxZk)I7cSV4UCTdiWYQ)bex4c6XzyrOcmynQhII8eymu5aQmbwldvg1djEVDog1dsoarbMX8AwbghGOCYKSbHu69AwHlOhN5lcvGbRr9quKNaJHkhqLjWcHO7rqlzalMcN4kNZSYOHWl4neq00i6qi6wgQmQhs8E7CmQhKCaIennIwDI2ThwpfbZVPM3tWAupejAAenBMpox2uem)MAEpHGJvlNOBVHOHRbMIdsVoartJOdHOTReqLdjMXzwS2ajZE7uE3eSg1drIUthIMpkVKFBOirRAdrNprtJODdfaEYRdi9rglGOvLOBdrJprdxdmfhKEDaIMgrBmVAbsyHtbCIUHOdt0D6q0UHcap51bK(iJfq0T3q04arJprdxdmfhKEDaI(QenFuEj)2qrIwnbMX8AwbMYYDJ6bPLL9fZRzfUGECItrOcmynQhII8eymu5aQmbwieDldvg1djEVDog1dsoarIMgrZM1TGAwIU9gIMzCx61biA8j6wgQmQhs9wmwBGaZyEnRatz5Ur9G0YY(I51ScxqpoBJiubgSg1drrEcmJ51ScmLL7g1dsll7lMxZkWyOYbuzcSqi6wgQmQhs8E7CmQhKCaIennIwDIoeI2ThwpfbZVPM3tWAupej6oDiA2mFCUSPiy(n18EcbhRworRkr71bK(i53gks0D6q08r5L8BdfjAvj6WeTAennIMnRBb1SeD7nenZ4U0Rdq04t0TmuzupK6TyS2aIMgrRorhcrBxjGkhsmJZSyTbsM92P8UjynQhIeDNoenLswwIzCMfRnqYS3oL3nHGJvlNOvLO96asFK8BdfjA1eySUShKUHcaNlOpSWf0JZ2kcvGbRr9quKNaZyEnRaJz)lnMxZk)I7cSV4UCTdiWYQ)bex4cxG1Ja2COmxeQG(WIqfyWAupef5jCb95lcvGbRr9quKNWf0JtrOcmynQhII8eUG(2icvGzmVMvGXvoNzLzWFRSoGeyWAupef5jCb9TveQadwJ6HOipbgdvoGktG52dRNcq1zkeiNmj3yOkRyqcwJ6HOaZyEnRalavNPqGCYKCJHQSIbcxqposeQadwJ6HOipHlO)kicvGzmVMvG1pEnRadwJ6HOipHlOhheHkWG1OEikYtGXqLdOYey8E4FPBOaW5joar5KjzdcP071SsBaIw1gIgNcmJ51Scmoar5KjzdcP071ScxqFoqeQaZyEnRa72uwxGbRr9quKNWf0hoxrOcmynQhII8eymu5aQmbwieTBpSE62uwpbRr9qKOPr08E4FPBOaW5joar5KjzdcP071SsBaIUDIgNcmJ51Scm(TfNlsQ5DHlCHlWmf)EqcmS6GJr4cxiaa]] )

end