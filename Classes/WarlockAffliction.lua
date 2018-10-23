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


    spec:RegisterPack( "Affliction", 20181022.2153, [[dquBfbqirQEKiLAtqLrPu4ukfTkIcEfIYSuP6wIuyxc9leXWuk5yevltuXZikAAIuY1GQ02ukv9nIcX4GQW5ePOwNsPI5ru6EkX(ejDqIc1cfv6HqvKCrrkcNuKIOvcv1mfPi5MqvKANiQ(PifPgQsPslfQI4PqzQIeFLOqAVO6VKAWcomLfJWJjmzsUmyZIYNfXOvjNwYRrKMTQUTk2TIFl1WvslhYZrA6uDDISDLkFxu14vkLZRsz9qvuZxPQ9JYC58u4ykZbo55SLC8q(w5KtmNC2sMBjJWX8BRahB1eKAjahBSdWXKXzzFj8Qho2QD7BtXtHJrBjKa4yxUVs3oKqss5xserrFiHwhP38QhbYYCsO1rqcX3eKqKzPHc2rYkQZQhOKKsbOCKtsk5ixlJAOVfKQLXzzFj8QNiTocogHu9EAYHtWXuMdCYZzl54H8TYjNyo5SLm3A75y0vqWjpNThVCSRsPGHtWXuavWXsBwqgNL9LWREybzud9TGug(PnlC5(kD7qcjjLFjref9HeADKEZREeilZjHwhbjeFtqcrMLgkyhjROoREGsY2fb4jwPOKSDXt0YOg6BbPAzCw2xcV6jsRJGHFAZcPPfEtaiwiNCUZc5SLC8GfsdwinVDWBoSW2fpndFg(PnlGN6YMeGUDy4N2SqAWcYyLcuSa2k8plKMQfKgz4N2SqAWc4jWP3bkwWnuc46klgJCSvuNvpWXsBwqgNL9LWREybzud9TGug(PnlC5(kD7qcjjLFjref9HeADKEZREeilZjHwhbjeFtqcrMLgkyhjROoREGsY2fb4jwPOKSDXt0YOg6BbPAzCw2xcV6jsRJGHFAZcPPfEtaiwiNCUZc5SLC8GfsdwinVDWBoSW2fpndFg(PnlGN6YMeGUDy4N2SqAWcYyLcuSa2k8plKMQfKgz4N2SqAWc4jWP3bkwWnuc46klgJm8z4N2SqAITbcjhuSabK1iGfe9HWCwGasQHgzbzSqaRoLfMEsJldDYKEwWeE1dLf65Vfz4BcV6HgxrGOpeMVK9gLug(MWREOXvei6dH5KTqsw3kg(MWREOXvei6dH5KTqIjLCGXnV6HHVj8QhACfbI(qyozlKqLoNE0RGZW3eE1dnUIarFimNSfssq1PleO7mn1eOkReW9kBXThgpMGQtxiq3zAQjqvwjGimgXdkg(MWREOXvei6dH5KTqcDSv6v7AQBoLHVj8QhACfbI(qyozlKS2E1ddFt4vp04kce9HWCYwiHcGs3zArJqsRE1Z9kBHUc)RDdLaonsbqP7mTOriPvV6rBnK6Imz4BcV6HgxrGOpeMt2cjxM04m8nHx9qJRiq0hcZjBHe6LP68AI(97v2s6U9W4XltA8imgXdkC0v4FTBOeWPrkakDNPfncjT6vpARbzLjdFg(PnlKMyBGqYbfla7a0nwWRdWc(fWcMWBeluuwW2z1Bepez4BcV6HUqxH)1FliLHVj8QhkzlKSZqLr8W9XoWIef0uau33zVeS42dJhPDETFbAkakAegJ4bfo6k8V2nuc40ifaLUZ0IgHKw9QhT1qQlYC)E3Ey8iTwV6r)vgeHXiEqHJUc)RDdLaonsbqP7mTOriPvV6j1f8UFpDf(x7gkbCAKcGs3zArJqsRE1tQl4bdFt4vpuYwizNHkJ4H7JDGLvtPQj5EVUqb)(o7LGLn2WWZaQCikmQWu1KOf2BNYVfHXiEqHBd3Ey8Ocz1OPT0hHXiEqTFVBpmEubMFr0VhHXiEqHt09R68tubMFr0VhrWXQHk7sIqT5M4seQ973WeE1tKEzQoVMOFpcBdesoO96aYGHNbu5quyuHPQjrlS3oLFlcJr8GAZnz4N2SGj8QhkzlKSZqLr8W9XoWYQPu1KCVxxOGFFN9sWsIqDVYwm8mGkhIcJkmvnjAH92P8BrymIhu42WThgpQqwnAAl9rymIhu7372dJhvG5xe97rymIhu4eD)Qo)evG5xe97reCSAOYUKiuBYW3eE1dLSfse2)At4vp6VO(9XoWIO7x15hkdFt4vpuYwirHSA00w6VxJdiK0QRt(MW(f53fxwnlYVlUjEq7gkbC6I87v2IBOeWJEDaT3AvbYUKiu4OT0RPxgsjlEz4BcV6Hs2cjxM043RSf6k8V2nuc40ifaLUZ0IgHKw9QhT1GSl5WW3eE1dLSfsOsNtpALHin5neCVYwuThTKEUf9sqAnj4uThfncjT6vprVeKwtcUniKYYIMWRDGwYOrQBcsxW7(90w610ldPw2AtCBKUBpmEC9YgVpAAnjsVHk)wegJ4b1(9IUFvNFIRx249rtRjr6nu53Ii4y1q3KHVj8QhkzlKyj9C7U4M4bTBOeWPlYVxzli4y1qLDjrOiZeE1tKEzQoVMOFpcBdesoO96a4CdLaE0RdO9wRkiv8GHVj8QhkzlKinu3iEqBzzFj8QN7v2s6IEClP6bNBOeWJEDaT3AvbYUGhm8nHx9qjBHefYQrtBP)U4M4bTBOeWPlYVxJdiK0QRRZbuL5WI8714acjT66kBXlbPuncownYI37v2IBpmEKEzQoVgoeitarymIhu4mHx7anmWPaQSl5Gtbeszzr6LP68A4qGmberWXQHItbeszzr6LP68A4qGmberWXQHk7sIqjd5WW3eE1dLSfsOxMQZRj63VlUjEq7gkbC6I87v2IBpmEKEzQoVgoeitarymIhu4C7HXJgbTFjh0IgHKw9QNimgXdkCMWRDGgg4uav2LCWPacPSSi9YuDEnCiqMaIi4y1qXPacPSSi9YuDEnCiqMaIi4y1qLDb2giKCq71bKHCiZr2o41EDaCPBcV6jsVmvNxt0VhRrN9vYLZW3eE1dLSfswVSX7JMwtI0BOYVDVYw86aPkt8IBdr3VQZprQ050JwzistEdbreCSAOPUKw4D)Er3VQZprQ050JwzistEdbreCSAOYIhBIZnuc4rVoG2BTQGuLV9YaDf(xFzuhy4BcV6Hs2cj7Qh0UvJFVYw86aPkhV4CdLaE0RdO9wRki1f5BXW3eE1dLSfsKgQBepOTSSVeE1Z9kBj9DgQmIhIsuqtbqHJ2sVMEzi1cEz4BcV6Hs2cjuau6otlAesA1REUxzl7muzepeLOGMcGchTLEn9YqQf8YW3eE1dLSfse2)At4vp6VO(9XoWIQDkdFt4vpuYwiz9YgVpAAnjsVHk)29kBXRdi7ImXldFt4vpuYwizx9G2TA87v2Ixhqw54LHVj8QhkzlKOmePAAl9m8nHx9qjBHecarbeP1KWW3eE1dLSfse2)At4vp6VO(9XoWcDfgfGOm8nHx9qjBHeH9V2eE1J(lQFFSdSKv)dikdFg(MWREOrr3VQZp0L12REUxzlB42dJhvgIunTLE9POa6wegJ4bfor3VQZprQ050JwzistEdbrPvCIUFvNFIkdrQM2sFuADZ97fD)Qo)ePsNtpALHin5neeLw3V3nuc4rVoG2BTQazL5wm8nHx9qJIUFvNFOKTqIef0Ldh69kBjDr3VQZprQ050JwzistEdbrPvg(MWREOrr3VQZpuYwijRqaX3T6ELTKUO7x15Niv6C6rRmePjVHGO0kdFt4vp0OO7x15hkzlKq8DR0zsOB3RSL0fD)Qo)ePsNtpALHin5neeLwz4ZW3eE1dnQANUqbqP7mTOriPvV65ELTOApkAesA1REIi4y1qLDXeE1tKcGs3zArJqsRE1tuyux71biZRdO9wtVmKIS0kMJmSH80WThgpkqaSwtIwbMFfHXiEqjdBfLJ3nXrxH)1UHsaNgPaO0DMw0iK0Qx9OTgsDrMK52dJhZJk)c01OTKEUfHXiEqHlDv7rkakDNPfncjT6vpreCSAO4s3eE1tKcGs3zArJqsRE1tSgD2xjxodFt4vp0OQDkzlKyj9C7U4M4bTBOeWPlYVxzlU9W4rbcG1As0kW8RimgXdkCMWRDGw1E0s65MSBpo3qjGh96aAV1Qcsv(w42abhRgQSljc1(9IUFvNFIuPZPhTYqKM8gcIi4y1qtv(w4qqgcOxgXdBYW3eE1dnQANs2cjwsp3UlUjEq7gkbC6I87v2s6U9W4rbcG1As0kW8RimgXdkCMWRDGw1E0s65MS4bo3qjGh96aAV1Qcsv(w42abhRgQSljc1(9IUFvNFIuPZPhTYqKM8gcIi4y1qtv(w4qqgcOxgXdBYW3eE1dnQANs2cj0A9Qh9xzWDXnXdA3qjGtxKFVYw2WeETd0Q2J0A9Qh9xzGS4rA42dJhfiawRjrRaZVIWyepOsd6k8V2nuc40iTZR9lqtbqr1wdBIZnuc4rVoG2BTQGuLVfoeKHa6Lr8aU03q09R68tKkDo9OvgI0K3qqebhRgQSl0w610ldPKbt4vprPH6gXdAll7lHx9eHTbcjh0EDGnz4BcV6HgvTtjBHerJqsRE1ZDXnXdA3qjGtxKFVYwmHx7anmWPaQSYKm3Ey8yEu5xGUgTL0ZTimgXdkCBGGJvdv2LeHA)Er3VQZprQ050JwzistEdbreCSAOPkFlCiidb0lJ4HnX5gkb8Oxhq7TwvqQY3IHpdFt4vp0yw9pGOlwsp3UxzlU9W4rfy(fr)EegJ4bfor3VQZprQ050JwzistEdbreCSAOPUiZTilrOWj6(vD(jQaZVi63Ji4y1qLDjrOWL(kc2PteQO8iv6C6rRmePjVHaCPVIGD6eHkkpAj9CdNBpmEmpQ8lqxJ2s65wegJ4bfodpdOYHivsPGr3df8imgXdkCi4y1qLvjHmV6rg2kIxg(MWREOXS6FarjBHefy(fr)(9kBr09R68tKkDo9OvgI0K3qqebhRgAQlYClYseQ97fD)Qo)ePsNtpALHin5neerWXQHMQ80Alg(MWREOXS6FarjBHe6LP68AI(97v2cHuww807GdmEuAfhHuwwCQKlpZ(pIGJvdLHVj8QhAmR(hquYwiXs6529kBHqkllE6DWbgpkTIl9nC7HXJ0A9Qh9xzqegJ4bfUnwrWoDIqfLhTKEUHBfb70jcvmNOL0ZnCRiyNorOIYmAj9CBZ97xrWoDIqfLhTKEUTjdFt4vp0yw9pGOKTqcTwV6r)vgCVYwiKYYINEhCGXJsR4sFJveStNiur5rATE1J(Rma3kc2PteQyorATE1J(Rma3kc2PteQOmJ0A9Qh9xzWMm8nHx9qJz1)aIs2cjIgHKw9QN7v2cHuww807GdmEuAfx6RiyNorOIYJIgHKw9QhCP72dJhncA)soOfncjT6vprymIhum8nHx9qJz1)aIs2cjkKvJ(Rm4ELTSbHuwwSgyx5gXdAfCkkePUjin1L08w42q09R68tubMFr0VhrWXQHMkSnqi5G2RdSFF6U9W4rfy(fr)EegJ4b1M42q09R68tC9YgVpAAnjsVHk)webhRgAQW2aHKdAVoW(9P72dJhxVSX7JMwtI0BOYVfHXiEqTjUneD)Qo)evgIunTL(icown0uHTbcjh0EDG97t3ThgpQmePAAl96trb0TimgXdQnXTHO7x15N4U6bTB14reCSAOPcBdesoO96a73NUBpmECx9G2TA8imgXdQnXj6(vD(jsLoNE0kdrAYBiiIGJvdnvyBGqYbTxhGm5BTFpHuwwSgyx5gXdAfCkkePUjinvzUfo3qjGh96aAV1QcKDr(wBYW3eE1dnMv)dikzlKCzsJZW3eE1dnMv)dikzlKOqwnAAl93RXbesA11jFty)I87IlRMf53RXbesA1xKFxCt8G2nuc40f53RSf3qjGh96aAV1QcKDjrOy4BcV6HgZQ)beLSfsuiRgnTL(7IBIh0UHsaNUi)U4YQzr(9ACaHKwDDLT4LGuQgbhRgzX79ACaHKwDDY3e2Vi)ELT42dJhPxMQZRHdbYeqegJ4bfot41oqddCkGUKdU0vaHuwwKEzQoVgoeitareCSAOm8nHx9qJz1)aIs2cjkKvJM2s)DXnXdA3qjGtxKFxCz1Si)EnoGqsRUUYw8sqkvJGJvJS49EnoGqsRUo5Bc7xKFVYwC7HXJ0lt151WHazcicJr8GcNj8AhOHbofqxYHHVj8QhAmR(hquYwirHSA00w6VxJdiK0QRt(MW(f53fxwnlYVxJdiK0QViNHVj8QhAmR(hquYwiHEzQoVMOF)U4M4bTBOeWPlYVxzlU9W4r6LP68A4qGmbeHXiEqHZThgpAe0(LCqlAesA1REIWyepOWzcV2bAyGtb0LCWLUciKYYI0lt151WHazciIGJvdfx6MWREI0lt151e97XA0zFLC5m8nHx9qJz1)aIs2cj0lt151e973f3epODdLaoDr(9kBXThgpsVmvNxdhcKjGimgXdkCU9W4rJG2VKdArJqsRE1tegJ4bfot41oqddCkGUKddFt4vp0yw9pGOKTqc9YuDEnr)odFg(MWREOr6kmkarxKgQBepOTSSVeE1Z9kBr09R68tKkDo9OvgI0K3qqebhRgQSl0w610ldPKbyBGqYbTxhGHVj8QhAKUcJcquYwiry)RnHx9O)I63h7alz1)aIEVYw2q09R68tKkDo9OvgI0K3qqebhRgQSEDaT3A6LHuYWg4nnOT0RPxgsT5(9IUFvNFIuPZPhTYqKM8gcIsRBIZRdO9wRkivr3VQZprQ050JwzistEdbreCSAOm8nHx9qJ0vyuaIs2cjuau6otlAesA1REUxzl7muzepeLOGMcGIHVj8QhAKUcJcquYwirAOUr8G2YY(s4vp3RSL03zOYiEikrbnfafU0xrWoDIqfLhPsNtpALHin5neGBd3Ey8Ocm)IOFpcJr8GcNO7x15NOcm)IOFpIGJvdv2fyBGqYbTxhax6gEgqLdrHrfMQMeTWE7u(TimgXdQ97PT0RPxgsL6so4CdLaE0RdO9wRki10ImyBGqYbTxhaNj8AhOHbofqxKVFVBOeWJEDaT3AvbYUGhKbBdesoO96aYaTLEn9YqQnz4BcV6HgPRWOaeLSfsKgQBepOTSSVeE1Z9kBj9DgQmIhIsuqtbqHt0JBjvpYUimQR96aKTZqLr8qC1uQAsy4BcV6HgPRWOaeLSfsKgQBepOTSSVeE1ZDXnXdA3qjGtxKFVYwsFNHkJ4HOef0uau42iD3Ey8Ocm)IOFpcJr8GA)Er3VQZprfy(fr)EebhRgAQEDaT3A6LHu73tBPxtVmKkv5BIt0JBjvpYUimQR96aKTZqLr8qC1uQAsWTr6gEgqLdrHrfMQMeTWE7u(TimgXdQ97jKYYIcJkmvnjAH92P8BreCSAOP61b0ERPxgsTjhBhGOvpCYZzl54H8TYjNyoYXRm5y5n0utcLJLM8S2ihuSW2ZcMWREyHVOonYWNJzs(vJ4yy1bpfh7lQt5PWXuqMj9opfo5Y5PWXmHx9WXORW)6VfKYXGXiEqXZL7CYZHNchdgJ4bfpxo2o7LaoMBpmEK251(fOPaOOrymIhuSaowGUc)RDdLaonsbqP7mTOriPvV6rBnWcPUWcYKf2VNfC7HXJ0A9Qh9xzqegJ4bflGJfORW)A3qjGtJuau6otlAesA1REyHuxyb8Yc73Zc0v4FTBOeWPrkakDNPfncjT6vpSqQlSaEWXmHx9WX2zOYiEGJTZq6XoahtIcAkakUZjxM8u4yWyepO45YX6vogfCoMj8Qho2odvgXdCSD2lbCSnyHnybdpdOYHOWOctvtIwyVDk)wegJ4bflGJf2GfC7HXJkKvJM2sFegJ4bflSFpl42dJhvG5xe97rymIhuSaowq09R68tubMFr0VhrWXQHYcYUWcjcflSjlSjlGJfsekwy)EwydwWeE1tKEzQoVMOFpcBdesoO96aSGmWcgEgqLdrHrfMQMeTWE7u(TimgXdkwytwyto2odPh7aCSvtPQjH7CYtlEkCmymIhu8C5yMWRE4yc7FTj8Qh9xuNJ9f11JDaoMO7x15hk35KJxEkCmymIhu8C5yMWRE4ykKvJM2sphtCt8G2nuc4uo5Y5ycu5aQmoMBOeWJEDaT3AvbSGSlSqIqXc4ybAl9A6LHuSGSSaE5yIlRgoMCownoGqsRUo5Bc75yY5oN8TNNchdgJ4bfpxoMavoGkJJrxH)1UHsaNgPaO0DMw0iK0Qx9OTgybzxyHC4yMWRE4yxM04CNtUmcpfogmgXdkEUCmbQCavght1E0s65w0lbP1KWc4ybv7rrJqsRE1t0lbP1KWc4yHnybcPSSOj8AhOLmAK6MGuwyHfWllSFplqBPxtVmKIfwyHTyHnzbCSWgSq6SGBpmEC9YgVpAAnjsVHk)wegJ4bflSFpli6(vD(jUEzJ3hnTMeP3qLFlIGJvdLf2KJzcV6HJrLoNE0kdrAYBiG7CYXdEkCmymIhu8C5yMWRE4ywsp34ycu5aQmogcownuwq2fwirOybYybt4vpr6LP68AI(9iSnqi5G2RdWc4yb3qjGh96aAV1QcyHuzb8GJjUjEq7gkbCkNC5CNtEAMNchdgJ4bfpxoMavoGkJJLoli6XTKQhwahl4gkb8Oxhq7Twvali7clGhCmt4vpCmPH6gXdAll7lHx9WDo5Y3INchdgJ4bfpxoMj8QhoMcz1OPT0ZXe3epODdLaoLtUCownoGqsRUUY4yEjiLQrWXQrw8YXQXbesA1115aQYCGJjNJjqLdOY4yU9W4r6LP68A4qGmbeHXiEqXc4ybt41oqddCkGYcYUWc5Wc4ybfqiLLfPxMQZRHdbYeqebhRgklGJfuaHuwwKEzQoVgoeitareCSAOSGSlSqIqXcYalKd35KlxopfogmgXdkEUCmt4vpCm6LP68AI(DoMavoGkJJ52dJhPxMQZRHdbYeqegJ4bflGJfC7HXJgbTFjh0IgHKw9QNimgXdkwahlycV2bAyGtbuwq2fwihwahlOacPSSi9YuDEnCiqMaIi4y1qzbCSGciKYYI0lt151WHazciIGJvdLfKDHfGTbcjh0EDawqgyHCybYybhz7Gx71bybCSq6SGj8QNi9YuDEnr)ESgD2xjxohtCt8G2nuc4uo5Y5oNC55WtHJbJr8GINlhtGkhqLXX86aSqQSGmXllGJf2GfeD)Qo)ePsNtpALHin5neerWXQHYcPUWcPfEzH97zbr3VQZprQ050JwzistEdbreCSAOSGSSaEWcBYc4yb3qjGh96aAV1QcyHuzb5BplidSaDf(xFzuh4yMWRE4yRx249rtRjr6nu534oNC5YKNchdgJ4bfpxoMavoGkJJ51byHuzb54LfWXcUHsap61b0ERvfWcPUWcY3IJzcV6HJTREq7wno35KlpT4PWXGXiEqXZLJjqLdOY4yPZc7muzepeLOGMcGIfWXc0w610ldPyHfwaVCmt4vpCmPH6gXdAll7lHx9WDo5YXlpfogmgXdkEUCmbQCavghBNHkJ4HOef0uauSaowG2sVMEziflSWc4LJzcV6HJrbqP7mTOriPvV6H7CYLV98u4yWyepO45YXmHx9WXe2)At4vp6VOoh7lQRh7aCmv7uUZjxUmcpfogmgXdkEUCmbQCavghZRdWcYUWcYeVCmt4vpCS1lB8(OP1Ki9gQ8BCNtUC8GNchdgJ4bfpxoMavoGkJJ51bybzzb54LJzcV6HJTREq7wno35KlpnZtHJzcV6HJPmePAAl9CmymIhu8C5oN8C2INchZeE1dhJaquarAnjCmymIhu8C5oN8CKZtHJbJr8GINlhZeE1dhty)RnHx9O)I6CSVOUESdWXORWOaeL7CYZjhEkCmymIhu8C5yMWRE4yc7FTj8Qh9xuNJ9f11JDaoww9pGOCN7CSvei6dH58u4KlNNchdgJ4bfpxUZjphEkCmymIhu8C5oNCzYtHJbJr8GINl35KNw8u4yMWRE4yuPZPhDg8xsJdiogmgXdkEUCNtoE5PWXGXiEqXZLJjqLdOY4yU9W4XeuD6cb6ottnbQYkbeHXiEqXXmHx9WXsq1PleO7mn1eOkRea35KV98u4yWyepO45YDo5Yi8u4yMWRE4yRTx9WXGXiEqXZL7CYXdEkCmymIhu8C5ycu5aQmogDf(x7gkbCAKcGs3zArJqsRE1J2AGfsDHfKjhZeE1dhJcGs3zArJqsRE1d35KNM5PWXmHx9WXUmPX5yWyepO45YDo5Y3INchdgJ4bfpxoMavoGkJJLol42dJhVmPXJWyepOybCSaDf(x7gkbCAKcGs3zArJqsRE1J2AGfKLfKjhZeE1dhJEzQoVMOFN7CNJPANYtHtUCEkCmymIhu8C5ycu5aQmoMQ9OOriPvV6jIGJvdLfKDHfmHx9ePaO0DMw0iK0Qx9efg11EDawGmwWRdO9wtVmKIfiJfsRyoSGmWcBWcYzH0GfC7HXJceaR1KOvG5xrymIhuSGmWcBfLJxwytwahlqxH)1UHsaNgPaO0DMw0iK0Qx9OTgyHuxybzYcKXcU9W4X8OYVaDnAlPNBrymIhuSaowiDwq1EKcGs3zArJqsRE1tebhRgklGJfsNfmHx9ePaO0DMw0iK0Qx9eRrN9vYLZXmHx9WXOaO0DMw0iK0Qx9WDo55WtHJbJr8GINlhZeE1dhZs65ghtGkhqLXXC7HXJceaR1KOvG5xrymIhuSaowWeETd0Q2Jwsp3ybzzHTNfWXcUHsap61b0ERvfWcPYcY3IfWXcBWci4y1qzbzxyHeHIf2VNfeD)Qo)ePsNtpALHin5neerWXQHYcPYcY3IfWXciidb0lJ4bwytoM4M4bTBOeWPCYLZDo5YKNchdgJ4bfpxoMj8QhoML0ZnoMavoGkJJLol42dJhfiawRjrRaZVIWyepOybCSGj8AhOvThTKEUXcYYc4blGJfCdLaE0RdO9wRkGfsLfKVflGJf2GfqWXQHYcYUWcjcflSFpli6(vD(jsLoNE0kdrAYBiiIGJvdLfsLfKVflGJfqqgcOxgXdSWMCmXnXdA3qjGt5KlN7CYtlEkCmymIhu8C5yMWRE4y0A9Qh9xzahtGkhqLXX2GfmHx7aTQ9iTwV6r)vgWcYYc4blKgSGBpmEuGayTMeTcm)kcJr8GIfsdwGUc)RDdLaons78A)c0uauuT1alSjlGJfCdLaE0RdO9wRkGfsLfKVflGJfqqgcOxgXdSaowiDwydwq09R68tKkDo9OvgI0K3qqebhRgkli7clqBPxtVmKIfKbwWeE1tuAOUr8G2YY(s4vpryBGqYbTxhGf2KJjUjEq7gkbCkNC5CNtoE5PWXGXiEqXZLJzcV6HJjAesA1RE4ycu5aQmoMj8AhOHbofqzbzzbzYcKXcU9W4X8OYVaDnAlPNBrymIhuSaowydwabhRgkli7clKiuSW(9SGO7x15Niv6C6rRmePjVHGicownuwivwq(wSaowabziGEzepWcBYc4yb3qjGh96aAV1QcyHuzb5BXXe3epODdLaoLtUCUZDoMO7x15hkpfo5Y5PWXGXiEqXZLJjqLdOY4yBWcU9W4rLHivtBPxFkkGUfHXiEqXc4ybr3VQZprQ050JwzistEdbrPvwahli6(vD(jQmePAAl9rPvwytwy)Ewq09R68tKkDo9OvgI0K3qquALf2VNfCdLaE0RdO9wRkGfKLfK5wCmt4vpCS12RE4oN8C4PWXGXiEqXZLJjqLdOY4yPZcIUFvNFIuPZPhTYqKM8gcIsRCmt4vpCmjkOlhouUZjxM8u4yWyepO45YXeOYbuzCS0zbr3VQZprQ050JwzistEdbrPvoMj8QhowwHaIVBf35KNw8u4yWyepO45YXeOYbuzCS0zbr3VQZprQ050JwzistEdbrPvoMj8QhogX3TsNjHUXDUZXYQ)beLNcNC58u4yWyepO45YXeOYbuzCm3Ey8Ocm)IOFpcJr8GIfWXcIUFvNFIuPZPhTYqKM8gcIi4y1qzHuxybzUflqglKiuSaowq09R68tubMFr0VhrWXQHYcYUWcjcflGJfsNfwrWoDIqfLhPsNtpALHin5neWc4yH0zHveStNiur5rlPNBSaowWThgpMhv(fORrBj9ClcJr8GIfWXcgEgqLdrQKsbJUhk4rymIhuSaowabhRgklillOKqMx9WcYalSveVCmt4vpCmlPNBCNtEo8u4yWyepO45YXeOYbuzCmr3VQZprQ050JwzistEdbreCSAOSqQlSGm3IfiJfsekwy)Ewq09R68tKkDo9OvgI0K3qqebhRgklKklipT2IJzcV6HJPaZVi635oNCzYtHJbJr8GINlhtGkhqLXXiKYYINEhCGXJsRSaowGqkllovYLNz)hrWXQHYXmHx9WXOxMQZRj635oN80INchdgJ4bfpxoMavoGkJJriLLfp9o4aJhLwzbCSq6SWgSGBpmEKwRx9O)kdIWyepOybCSWgSWkc2PteQO8OL0ZnwahlSIGD6eHkMt0s65glGJfwrWoDIqfLz0s65glSjlSFplSIGD6eHkkpAj9CJf2KJzcV6HJzj9CJ7CYXlpfogmgXdkEUCmbQCavghJqkllE6DWbgpkTYc4yH0zHnyHveStNiur5rATE1J(RmGfWXcRiyNorOI5eP16vp6VYawahlSIGD6eHkkZiTwV6r)vgWcBYXmHx9WXO16vp6VYaUZjF75PWXGXiEqXZLJjqLdOY4yeszzXtVdoW4rPvwahlKolSIGD6eHkkpkAesA1REybCSq6SGBpmE0iO9l5Gw0iK0Qx9eHXiEqXXmHx9WXencjT6vpCNtUmcpfogmgXdkEUCmbQCavghBdwGqkllwdSRCJ4bTcoffIu3eKYcPUWcP5TybCSWgSGO7x15NOcm)IOFpIGJvdLfsLfGTbcjh0EDawy)EwiDwWThgpQaZVi63JWyepOyHnzbCSWgSGO7x15N46LnEF00AsKEdv(Ticownuwivwa2giKCq71byH97zH0zb3Ey846LnEF00AsKEdv(TimgXdkwytwahlSbli6(vD(jQmePAAl9reCSAOSqQSaSnqi5G2RdWc73ZcPZcU9W4rLHivtBPxFkkGUfHXiEqXcBYc4yHnybr3VQZpXD1dA3QXJi4y1qzHuzbyBGqYbTxhGf2VNfsNfC7HXJ7Qh0UvJhHXiEqXcBYc4ybr3VQZprQ050JwzistEdbreCSAOSqQSaSnqi5G2RdWcKXcY3If2VNfiKYYI1a7k3iEqRGtrHi1nbPSqQSGm3IfWXcUHsap61b0ERvfWcYUWcY3If2KJzcV6HJPqwn6VYaUZjhp4PWXmHx9WXUmPX5yWyepO45YDo5PzEkCmymIhu8C5yMWRE4ykKvJM2sphtCt8G2nuc4uo5Y5y14acjT6Cm5CmbQCavghZnuc4rVoG2BTQawq2fwirO4yIlRgoMCownoGqsRUo5Bc75yY5oNC5BXtHJbJr8GINlhZeE1dhtHSA00w65yIBIh0UHsaNYjxohRghqiPvxxzCmVeKs1i4y1ilE5ycu5aQmoMBpmEKEzQoVgoeitarymIhuSaowWeETd0WaNcOSWclKdlGJfsNfuaHuwwKEzQoVgoeitareCSAOCmXLvdhtohRghqiPvxN8nH9Cm5CNtUC58u4yWyepO45YXmHx9WXuiRgnTLEoM4M4bTBOeWPCYLZXQXbesA11vghZlbPuncownYIxoMavoGkJJ52dJhPxMQZRHdbYeqegJ4bflGJfmHx7anmWPaklSWc5WXexwnCm5CSACaHKwDDY3e2ZXKZDo5YZHNchdgJ4bfpxoMj8QhoMcz1OPT0ZXQXbesA15yY5yIlRgoMCownoGqsRUo5Bc75yY5oNC5YKNchdgJ4bfpxoMj8Qhog9YuDEnr)ohtGkhqLXXC7HXJ0lt151WHazcicJr8GIfWXcU9W4rJG2VKdArJqsRE1tegJ4bflGJfmHx7anmWPaklSWc5Wc4yH0zbfqiLLfPxMQZRHdbYeqebhRgklGJfsNfmHx9ePxMQZRj63J1OZ(k5Y5yIBIh0UHsaNYjxo35KlpT4PWXGXiEqXZLJzcV6HJrVmvNxt0VZXeOYbuzCm3Ey8i9YuDEnCiqMaIWyepOybCSGBpmE0iO9l5Gw0iK0Qx9eHXiEqXc4ybt41oqddCkGYclSqoCmXnXdA3qjGt5KlN7CYLJxEkCmt4vpCm6LP68AI(DogmgXdkEUCN7Cm6kmkar5PWjxopfogmgXdkEUCmbQCavght09R68tKkDo9OvgI0K3qqebhRgkli7clqBPxtVmKIfKbwa2giKCq71b4yMWRE4ysd1nIh0ww2xcV6H7CYZHNchdgJ4bfpxoMavoGkJJTbli6(vD(jsLoNE0kdrAYBiiIGJvdLfKLf86aAV10ldPybzGf2GfWllKgSaTLEn9Yqkwytwy)Ewq09R68tKkDo9OvgI0K3qquALf2KfWXcEDaT3AvbSqQSGO7x15Niv6C6rRmePjVHGicownuoMj8QhoMW(xBcV6r)f15yFrD9yhGJLv)dik35KltEkCmymIhu8C5ycu5aQmo2odvgXdrjkOPaO4yMWRE4yuau6otlAesA1RE4oN80INchdgJ4bfpxoMavoGkJJLolSZqLr8quIcAkakwahlKolSIGD6eHkkpsLoNE0kdrAYBiGfWXcBWcU9W4rfy(fr)EegJ4bflGJfeD)Qo)evG5xe97reCSAOSGSlSaSnqi5G2RdWc4yH0zbdpdOYHOWOctvtIwyVDk)wegJ4bflSFplqBPxtVmKIfsDHfYHfWXcUHsap61b0ERvfWcPYcPflqglaBdesoO96aSaowWeETd0WaNcOSWcliNf2VNfCdLaE0RdO9wRkGfKDHfWdwGmwa2giKCq71bybzGfOT0RPxgsXcBYXmHx9WXKgQBepOTSSVeE1d35KJxEkCmymIhu8C5ycu5aQmow6SWodvgXdrjkOPaOybCSGOh3sQEybzxybHrDTxhGfiJf2zOYiEiUAkvnjCmt4vpCmPH6gXdAll7lHx9WDo5BppfogmgXdkEUCmt4vpCmPH6gXdAll7lHx9WXeOYbuzCS0zHDgQmIhIsuqtbqXc4yHnyH0zb3Ey8Ocm)IOFpcJr8GIf2VNfeD)Qo)evG5xe97reCSAOSqQSGxhq7TMEziflSFplqBPxtVmKIfsLfKZcBYc4ybrpULu9WcYUWccJ6AVoalqglSZqLr8qC1uQAsybCSWgSq6SGHNbu5quyuHPQjrlS3oLFlcJr8GIf2VNfiKYYIcJkmvnjAH92P8BreCSAOSqQSGxhq7TMEziflSjhtCt8G2nuc4uo5Y5o35o35oNd]] )

end