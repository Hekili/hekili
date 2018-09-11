-- WarlockDestruction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 267 )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        {
            aura = "infernal",
            
            last = function ()
                local app = state.buff.infernal.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 0.1
        }
    }, setmetatable( {
        actual = nil,
        max = nil,
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
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards, true ) / 10
                return t.actual

            elseif k == 'max' then
                t.max = UnitPowerMax( "player", Enum.PowerType.SoulShards, true ) / 10
                return t.max

            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.Mana )
    

    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shards" and amt > 0 then
            if talent.soul_fire.enabled and cooldown.soul_fire.remains > 0 then
                setCooldown( "soul_fire", max( 0, cooldown.soul_fire.remains - ( 2 * amt ) ) )
            end

            if talent.grimoire_of_supremacy.enabled and pet.infernal.up then
                addStack( "grimoire_of_supremacy", nil, amt )
            end
        end
    end )


    -- Talents
    spec:RegisterTalents( {
        flashover = 22038, -- 267115
        eradication = 22090, -- 196412
        soul_fire = 22040, -- 6353

        reverse_entropy = 23148, -- 205148
        internal_combustion = 21695, -- 266134
        shadowburn = 23157, -- 17877

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        inferno = 22480, -- 270545
        fire_and_brimstone = 22043, -- 196408
        cataclysm = 23143, -- 152108

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        demonic_circle = 19288, -- 268358

        roaring_blaze = 23155, -- 205184
        grimoire_of_supremacy = 23156, -- 266086
        grimoire_of_sacrifice = 19295, -- 108503

        soul_conduit = 19284, -- 215941
        channel_demonfire = 23144, -- 196447
        dark_soul_instability = 23092, -- 113858
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3493, -- 196029
        adaptation = 3494, -- 214027
        gladiators_medallion = 3495, -- 208683

        bane_of_havoc = 164, -- 200546
        entrenched_in_flame = 161, -- 233581
        cremation = 159, -- 212282
        fel_fissure = 157, -- 200586
        focused_chaos = 155, -- 233577
        casting_circle = 3510, -- 221703
        essence_drain = 3509, -- 221711
        nether_ward = 3508, -- 212295
        curse_of_weakness = 3504, -- 199892
        curse_of_tongues = 3503, -- 199890
        curse_of_fragility = 3502, -- 199954
    } )

    -- Auras
    spec:RegisterAuras( {
        active_havoc = {
            duration = 10,
            max_stack = 1,

            generate = function ()
                local ah = buff.active_havoc

                if active_enemies > 1 and  active_dot.havoc > 0 and query_time - last_havoc < 10 then
                    ah.count = 1
                    ah.applied = last_havoc
                    ah.expires = last_havoc + 10
                    ah.caster = "player"
                    return
                end

                ah.count = 0
                ah.applied = 0
                ah.expires = 0
                ah.caster = "nobody"
            end
        },
        backdraft = {
            id = 196406,
            duration = 10,
            type = "Magic",
            max_stack = function () return talent.flashover.enabled and 2 or 1 end,
        },
        blood_pact = {
            id = 6307,
            duration = 3600,
            max_stack = 1,
        },
        burning_rush = {
            id = 111400,
            duration = 3600,
            max_stack = 1,
        },
        channel_demonfire = {
            id = 196447,
        },
        conflagrate = {
            id = 265931,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        dark_pact = {
            id = 108416,
            duration = 20,
            max_stack = 1,
        },
        dark_soul_instability = {
            id = 113858,
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
            duration = 4.95,
            max_stack = 1,
        },
        eradication = {
            id = 196414,
            duration = 7,
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
        grimoire_of_sacrifice = {
            id = 196099,
            duration = 3600,
            max_stack = 1,
        },
        grimoire_of_supremacy = {
            id = 266091,
            duration = 3600,
            max_stack = 8,
        },
        havoc = {
            id = 80240,
            duration = 10,
            type = "Curse",
            max_stack = 1,

            generate = function ( t, type )
                if type == "buff" then
                    t.count = 0
                    t.applied = 0
                    t.expires = 0
                    t.caster = "nobody"
                    return
                end
                
                local h = debuff.havoc
                --[[ local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 80240, "PLAYER" )

                if active_enemies > 1 and name then
                    h.count = 1
                    h.applied = expires - duration
                    h.expires = expires
                    h.caster = "player"
                    return
                end ]]

                h.count = 0
                h.applied = 0
                h.expires = 0
                h.caster = "nobody"
            end
        },
        immolate = {
            id = 157736,
            duration = 18,
            type = "Magic",
            max_stack = 1,
        },
        infernal = {
            duration = 30,
            generate = function ()
                local inf = buff.infernal

                if pet.infernal.alive then
                    inf.count = 1
                    inf.applied = pet.infernal.expires - 30
                    inf.expires = pet.infernal.expires
                    inf.caster = "player"
                    return
                end

                inf.count = 0
                inf.applied = 0
                inf.expires = 0
                inf.caster = "nobody"
            end,
        },
        infernal_awakening = {
            id = 22703,
            duration = 2,
            max_stack = 1,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mortal_coil = {
            id = 6789,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        rain_of_fire = {
            id = 5740,
        },
        reverse_entropy = {
            id = 266030,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        ritual_of_summoning = {
            id = 698,
        },
        shadowburn = {
            id = 17877,
            duration = 5,
            max_stack = 1,
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
        soul_shards = {
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
    } )


    spec:RegisterStateExpr( "last_havoc", function ()
        return action.havoc.lastCast
    end )

    spec:RegisterHook( "TimeToReady", function( wait, action )
        local ability = action and class.abilities[ action ]
    
        if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
            wait = 3600
        end

        return wait
    end )

    spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )

    
    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and destGUID ~= nil and destGUID ~= "" then
            lastTarget = destGUID
        end
    end )
    
    
    spec:RegisterHook( "reset_precast", function ()
        last_havoc = nil
        soul_shards.actual = nil

        for i = 1, 5 do
            local up, _, start, duration, id = GetTotemInfo( i )

            if up and id == 136219 then
                summonPet( "infernal", start + duration - now )
                break
            end
        end
    end )

    
    spec:RegisterCycle( function ()
        if cycle or active_enemies == 1 then return end

        local name = FindUnitDebuffByID( "target", 80240, "PLAYER" )
        return name and "cycle" or nil
    end )


    -- Abilities
    spec:RegisterAbilities( {
        banish = {
            id = 710,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            
            handler = function ()
                if debuff.banish.up then removeDebuff( "target", "banish" )
                else applyDebuff( "target", "banish") end
            end,
        },
        

        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
                if buff.burning_rush.up then removeBuff( "burning_rush" )
                else applyBuff( "burning_rush" ) end
            end,
        },
        

        cataclysm = {
            id = 152108,
            cast = 2,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,

            talent = "cataclysm",
            
            handler = function ()
                applyDebuff( "target", "immolate" )
                active_dot.immolate = max( active_dot.immolate, true_active_enemies )
            end,
        },
        

        channel_demonfire = {
            id = 196447,
            cast = 3,
            channeled = true,
            cooldown = 25,
            hasteCD = true,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "channel_demonfire",
            
            usable = function () return active_dot.immolate > 0 end,
            handler = function ()
                -- applies channel_demonfire (196447)
            end,
        },
        

        chaos_bolt = {
            id = 116858,
            cast = 3,
            cooldown = 0,
            gcd = "spell",
            
            spend = 2,
            spendType = "soul_shards",
            
            startsCombat = true,

            cycle = function () return talent.eradication.enabled and "eradication" or nil end,
            
            handler = function ()
                if talent.eradication.enabled then applyDebuff( "target", "eradication" ) end
                if talent.internal_combustion.enabled and debuff.immolate.up then
                    if debuff.immolate.remains <= 5 then removeDebuff( "target", "immolate" )
                    else debuff.immolate.expires = debuff.immolate.expires - 5 end
                end
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
        

        conflagrate = {
            id = 17962,
            cast = 0,
            charges = 2,
            cooldown = 13,
            recharge = 13,
            hasteCD = true,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,

            cycle = function () return talent.roaring_blaze.enabled and "conflagrate" or nil end,
            
            handler = function ()
                gain( 0.5, "soul_shards" )
                addStack( "backdraft", nil, talent.flashover.enabled and 2 or 1 )
                if talent.roaring_blaze.enabled then applyDebuff( "target", "conflagrate" ) end
            end,
        },
        

        --[[ create_healthstone = {
            id = 6201,
            cast = 2.97,
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
            cast = 2.97,
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
            gcd = "off",
            
            defensive = true,

            startsCombat = true,
            
            talent = "dark_pact",

            usable = function () return health.pct > 20 end,
            handler = function ()
                applyBuff( "dark_pact" )
                spend( 0.2 * health.max, "health" )
            end,
        },
        

        dark_soul_instability = {
            id = 113858,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,

            talent = "dark_soul_instability",
            
            handler = function ()
                applyBuff( "drain_soul_instability" )
            end,
        },
        

        --[[ demonic_circle = {
            id = 48018,
            cast = 0.49995,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                -- applies demonic_circle (48018)
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
                -- applies demonic_circle_teleport (48020)
            end,
        },
        

        demonic_gateway = {
            id = 111771,
            cast = 1.98,
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
                applyDebuff( "target", "drain_life" )
            end,
        },
        

        --[[ enslave_demon = {
            id = 1098,
            cast = 2.97,
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
            cast = 1.98,
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
            cast = 1.69983,
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
            
            talent = "grimoire_of_sacrifice",
            nobuff = "grimoire_of_sacrifice",

            essential = true,
            
            usable = function () return pet.active end,
            handler = function ()
                if pet.felhunter.alive then dismissPet( "felhunter" )
                elseif pet.imp.alive then dismissPet( "imp" )
                elseif pet.succubus.alive then dismissPet( "succubus" )
                elseif pet.voidawalker.alive then dismissPet( "voidwalker" ) end

                applyBuff( "grimoire_of_sacrifice" )
            end,
        },
        

        havoc = {
            id = 80240,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
                        
            startsCombat = true,
            indicator = function () return ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
            cycle = "havoc",
            
            usable = function () return active_enemies > 1 end,
            handler = function ()
                if class.abilities.havoc.indicator == "cycle" then
                    active_dot.havoc = active_dot.havoc + 1
                else
                    applyDebuff( "target", "havoc" )
                end
                applyBuff( "active_havoc" )
            end,
        },
        

        health_funnel = {
            id = 755,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            
            usable = function () return pet.active end,
            handler = function ()
                applyBuff( "health_funnel" )
            end,
        },
        

        immolate = {
            id = 348,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            cycle = function () return not debuff.immolate.refreshable and "immolate" or nil end,
            
            handler = function ()
                applyDebuff( "target", "immolate" )
            end,
        },
        

        incinerate = {
            id = 29722,
            cast = 1.98,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                -- Using true_active_enemies for resource predictions' sake.
                gain( 0.2 + ( talent.fire_and_brimstone.enabled and ( ( true_active_enemies - 1 ) * 0.1 ) or 0 ), "soul_shards" )
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
        

        rain_of_fire = {
            id = 5740,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 3,
            spendType = "soul_shards",
            
            startsCombat = true,
            
            handler = function ()
                -- establish that RoF is ticking?
                -- need a CLEU handler?
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
        

        shadowburn = {
            id = 17877,
            cast = 0,
            charges = 2,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,

            talent = "shadowburn",
            
            handler = function ()
                gain( 0.3, "soul_shards" )
                applyDebuff( "target", "shadowburn" )
            end,
        },
        

        shadowfury = {
            id = 30283,
            cast = 1.5,
            cooldown = function () return talent.darkfury.enabled and 45 or 60 end,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },
        

        singe_magic = {
            id = 132411,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            
            usable = function ()
                return pet.exists or buff.grimoire_of_sacrifice.up
            end,
            handler = function ()
                -- generic dispel effect?
            end,
        },
        

        soul_fire = {
            id = 6353,
            cast = 1.5,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "soul_fire",
            
            handler = function ()
                gain( 0.4, "soul_shards" )
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

            startsCombat = true,
            -- texture = ?

            toggle = "interrupts",
            interrupt = true,

            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        summon_infernal = {
            id = 1122,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
                summonPet( "infernal", 30 )
            end,
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
            
            defensive = true,            
            toggle = "defensives",

            startsCombat = false,
            
            handler = function ()
                applyBuff( "unending_resolve" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Destruction",
    } )


    spec:RegisterPack( "Destruction", 20180813.1611, [[dCKdnbqiKQEKGQcxsrQSjkvFsqLrrP4uusTkfcVcrmlKIBPiL2ff)IsPHjOCmkXYuu6zcOMMIIRHujBtqv(MIu14ui6CivQwhsfmpkj3ts2NIKdIuP0cfGhQifMisfQUOGQI(OGQsJePcLojsfYkvuntfPODQqTubvv9uqMkI0xrQuSxO(RedMOdJAXi8yGjJKlRAZc9zfmAe1Pf9AfsZMk3gu7wQFty4c0Xfuvz5k9CQA6KUUKA7cY3rQOXlGCEfX6rQqX8rkTFiJTGjfdrX6XJNnmlJmSrAjWglHNflZmsmKoj4XqbzWO8WXqndFmeD871TgOPOXqb5jobtHjfd5f1l4yiYQg0thS12HujxtyacyB9jCTJ1u0GLJQT(egylHtqylrKNwQhY2GRiMU7TL087SwSL0zTuOB41jaJwOJFVU1anfTXNWamerD6u6OgtGHOy94XZgMLrg2iTeyJLWZILzOlmexRKflgckHNgyiQ7byisjNEKm9ijJKbzWO8WrsrejzGMIgjDPx9izuSijDSF00LgmKl9QhtkgI6rU2PysXJTGjfdXanfngYh8oxXjaJIHEZeUtHdaR4XZIjfd9MjCNchagcSP(nzmKp4DUIY7WvVj743MDfMo5rFN9asovfsgyK0osQS7TAaSYa3epS5nt4ofgIbAkAm0w3fgOPOlU0Ryix61sZWhdbyLXkECGXKIHEZeUtHdadb2u)MmgYh8oxr5D4Q3KD8BZUctN8OVZEajNQcjdmsAhjv29wnXCFHBQcXMWEv038MjCNcdXanfngAR7cd0u0fx6vmKl9APz4JHInbwXJNbtkg6nt4ofoameyt9BYyiFW7CfL3HREt2XVn7kmDYJ(o7bKCQkKmWiPDKuz3B1KD8BlmVzc3PWqmqtrJH26UWanfDXLEfd5sVwAg(yOSJyfpMUWKIHEZeUtHdadXanfngkHHfowpgcSP(nzme9ij1jQJrdzoKay2dZz7rs7iPni5(4EpzMWDKKwArsLDVvt263MDfGaMO2RPOnVzc3Pqs7ijd0u0gazw4lecNAYUeD5azfjTJK7H5S9i50IKmqtrBaKzHVqiCQrxo0DfnHpsoTijDHKwHKu1lRPOrYrGKHzcmsAngcmb4Er5D4Qhp2cwXJdpmPyO3mH7u4aWqmqtrJHaSZvyGMIU4sVIHCPxlndFmeGYJv84Phtkg6nt4ofoamed0u0yiYCibadb2u)MmgIEK0gKu5D4QPUtfjRqsFcBuEhUAQ7ursRrs7iPY7WvJMWVOIcvEKCkK0syyiWeG7fL3HRE8ylyfpEKysXqVzc3PWbGHaBQFtgdXand9Y7dN3JKtHKwWqmqtrJHiZHeaSIht3XKIHyGMIgdbiZDFxH6WIoM7XqVzc3PWbGv8ylHHjfdXanfngcWkdCt8WyO3mH7u4aWkESflysXqVzc3PWbGHyGMIgd5f1Usm3JHaBQFtgdrpssDI6y0qMdjaM9WC2EmeycW9IY7WvpESfSIhBzwmPyO3mH7u4aWqmqtrJHaKzHVqiCkgcSP(nzme9ij1jQJrdzoKay2dZz7rs7i5d0b16lAcFKKeKuxo0DfnHpsAfsQ8oC1Oj8lQOqLhjTJK2GKk7ERMS1Vn7kabmrTxtrBEZeUtHK0slsspsQS7TAYw)2SRaeWe1EnfT5nt4ofsAhj9IAxXtMxkKCQkKCgKKwArsBqsLDVvZxMkbSMI28MjCNcjTJKuNOognFzQeWAkAZEyoBpsAvfscyVw0e(iP1ijT0IKe1XOHI3rlErTRKTxzI0L6eZEyoBpsofscyVw0e(ijT0IKbVAYo(TzNHbAg6iPDKuz3B1mSjSi3xeXIVo4EygmX8MjCNcjTgdbMaCVO8oC1JhBbR4XwcmMum0BMWDkCayigOPOXqarhD8WY6XqGn1VjJHOhjPorDmAiZHeaZEyoBpsAhjTbjTbjv29wnrh7jlc918MjCNcjTJKe1XOHGbJsTCunELbJIKwvHKZIKwJK0slsAdsspsQS7TAIo2twe6R5nt4ofsAhjjQJrdbdgLA5OA8kdgfjTcjNfjTgjTgdbMaCVO8oC1JhBbR4XwMbtkg6nt4ofoamed0u0yipzMsqNe1BJHaBQFtgdrpssDI6y0qMdjaM9WC2EK0osAdsAdsciZ7W9izfsolsslTij9ijrDmAiyWOulhvZEyoBpsslTijrDmAiyWOulhvZEyoBpsofssuhJgcgmk1Yr14vgmksocKKbAkAt2GS)Y6npqhuRVOj8rsRrsRXqGja3lkVdx94XwWkESf6ctkg6nt4ofoamed0u0yOSbz)L1JHaBQFtgdrpssDI6y0qMdjaM9WC2EmeycW9IY7WvpESfSIvmuW9abmbRysXJTGjfd9MjCNchawXJNftkg6nt4ofoaSIhhymPyO3mH7u4aWkE8mysXqmqtrJH81WWIUeVJCDRFXqVzc3PWbGv8y6ctkg6nt4ofoameyt9BYyiLDVvZWMWICFrelEgSzmb38MjCNcdXanfngAytyrUViIfpd2mMGJv84Wdtkg6nt4ofoaSIhp9ysXqmqtrJHck0u0yO3mH7u4aWkE8iXKIHyGMIgd5f1Usm3JHEZeUtHdaR4X0DmPyO3mH7u4aWqGn1VjJHOhjv29wnErTReZ9M3mH7uyigOPOXqzdY(lRhRyfdbO8ysXJTGjfd9MjCNchagcSP(nzmKY7WvJMWVOIcvEKCQkKCwlHHK0slsspscechLGoBdfVJw8IAxjBVYePl1jM9WC2EKKwArsL3HRgnHFrffQ8iPvvizGddjjbjhauijT0IK0JKk7ERgkEhT4f1Us2ELjsxQtmVzc3PWqmqtrJH81WWIUKD8BZoSIhplMum0BMWDkCayiWM63KXqkVdxnAc)Ikku5rYPQqslZegsslTizWRMSJFB2zyGMHosslTiPY7WvJMWVOIcvEK0QkKC2WqssqYbafgIbAkAmefVJw8IAxjBVYePl1jyfpoWysXqVzc3PWbGHaBQFtgdf8Qj743MDggOzOJK0slsQ8oC1Oj8lQOqLhjTcjdp6cdXanfngkOqtrJv84zWKIHyGMIgdr81)D0ShWqVzc3PWbGv8y6ctkgIbAkAmeHtiOkX6Dcg6nt4ofoaSIhhEysXqmqtrJHI5EcNqqHHEZeUtHdaR4XtpMumed0u0yOA)lPEypg6nt4ofoaSIvmu2rmP4XwWKIHEZeUtHdadXanfngcWoxHbAk6Il9kgYLET0m8XqakpwXJNftkg6nt4ofoameyt9BYyiVO2v8K5LcjNQcjNXqxyigOPOXqlNDrelXCpwXJdmMumed0u0yiaRmWnXdJHEZeUtHdaR4XZGjfd9MjCNchagcSP(nzmKYU3QbqM7(Uc1HfDm3BEZeUtHK2rs6rY9WC2EK0oscechLGoBdGm39DfQdl6yU3ShMZ2JKwvHKmqtrBaKzHVqiCQ5b6GA9fnHpgIbAkAmucdlCSESIhtxysXqmqtrJHaK5UVRqDyrhZ9yO3mH7u4aWkEC4Hjfd9MjCNchagIbAkAmezoKaGHaBQFtgdrpsAdsQ8oC1u3PIKviPpHnkVdxn1DQiP1iPDKu5D4Qrt4xurHkpsofsAjmK0os6dENRO8oC1Bwo7IiwI5EK0QkKCgKKeKuz3B1KT(TzxbiGjQ9AkAZBMWDkK0osQS7TAg2ewK7lIyXxhCpmdMyEZeUtHK2rYGxnzh)2SZWandDK0osg8Qj743MDM9WC2EK0QkK0syyiWeG7fL3HRE8ylyfpE6XKIHEZeUtHdadb2u)MmgYh8oxr5D4Q3SC2frSeZ9iPvvi5mijjiPYU3QjB9BZUcqatu71u0M3mH7uiPDKuz3B1mSjSi3xeXIVo4EygmX8MjCNcjTJKbVAYo(TzNHbAg6iPDKm4vt2XVn7m7H5S9iPvviPLWWqmqtrJHiZHeaSIhpsmPyO3mH7u4aWqmqtrJHaKzHVqiCkgcSP(nzme9ij1jQJrdzoKay2dZz7rs7iPYU3QzytyrUViIfFDW9WmyI5nt4ofsAhjdE1KD8BZoZEyoBpsofs(aDqT(IMWhjTJK(G35kkVdx9MLZUiILyUhjTQcjNbjjbjv29wnzRFB2vacyIAVMI28MjCNcjTJK2GK2GKwcBKi5iqsFW7CfL3HREZYzxeXsm3JKthsAdsgyKCArYWmwcpKCeiPp4DUIY7WvVz5SlIyjM7rsRrsRrsRqsBqYzNjmKCeiPniPfKKeKmmtyJejhbssuhJMHnHf5(Iiw81b3dZGjgVYGrrsRrYPdjNfjhbsAdsAbjjbjjQJrdd0m0lK5qcGzpmNThjNcjFGoOwFrt4JKwJKwJKwJHataUxuEhU6XJTGv8y6oMum0BMWDkCayigOPOXqK5qcagcSP(nzme9iPniPY7WvtDNkswHK(e2O8oC1u3PIKwJK2rsL3HRgnHFrffQ8i5uiPLWqs7iPp4DUIY7WvVz5SlIyjM7rsRQqYaJK2rsBqsLDVvZxMkbSMI28MjCNcjPLwKuz3B1KT(TzxbiGjQ9AkAZBMWDkK0AmeycW9IY7WvpESfSIhBjmmPyO3mH7u4aWqGn1VjJH8bVZvuEhU6nlNDrelXCpsAvfsgyK0osAdsQS7TA(YujG1u0M3mH7uijT0IKk7ERMS1Vn7kabmrTxtrBEZeUtHKwJHyGMIgdrMdjayfp2IfmPyO3mH7u4aWqmqtrJHaKzHVqiCkgcSP(nzme9ij1jQJrdzoKay2dZz7rs7ijrDmAyGMHEHmhsam7H5S9i5ui5d0b16lAcFK0os6dENRO8oC1Bwo7IiwI5EK0QkKmWiPDK0gKuz3B18LPsaRPOnVzc3PqsAPfjv29wnzRFB2vacyIAVMI28MjCNcjTgdbMaCVO8oC1JhBbR4XwMftkg6nt4ofoamed0u0yOegw4y9yiWM63KXq0JKuNOognK5qcGzpmNThjTJK7J79Kzc3XqGja3lkVdx94XwWkESLaJjfdXanfngA5SlIyjM7XqVzc3PWbGv8ylZGjfd9MjCNchagIbAkAmKxu7kXCpgcSP(nzme9ij1jQJrdzoKay2dZz7XqGja3lkVdx94XwWkESf6ctkg6nt4ofoamed0u0yiGOJoEyz9yiWM63KXq0JKuNOognK5qcGzpmNThdbMaCVO8oC1JhBbR4XwcpmPyO3mH7u4aWqmqtrJH8KzkbDsuVngcSP(nzme9ij1jQJrdzoKay2dZz7rs7iPniPnijGmVd3JKvi5SijT0IK0JKe1XOHGbJsTCun7H5S9ijT0IKe1XOHGbJsTCun7H5S9i5uijrDmAiyWOulhvJxzWOi5iqsgOPOnzdY(lR38aDqT(IMWhjTgjTgdbMaCVO8oC1JhBbR4XwMEmPyO3mH7u4aWqmqtrJHYgK9xwpgcSP(nzme9ij1jQJrdzoKay2dZz7XqGja3lkVdx94XwWkwXqXMatkESfmPyO3mH7u4aWqmqtrJHaSZvyGMIU4sVIHCPxlndFmeGYJv84zXKIHEZeUtHdadb2u)MmgYlQDfpzEPqYPQqYzm0fgIbAkAm0YzxeXsm3Jv84aJjfd9MjCNchagcSP(nzmKYU3QbqM7(Uc1HfDm3BEZeUtHK2rs6rY9WC2EK0oscechLGoBdGm39DfQdl6yU3ShMZ2JKwvHKmqtrBaKzHVqiCQ5b6GA9fnHpgIbAkAmucdlCSESIhpdMumed0u0yiazU77kuhw0XCpg6nt4ofoaSIhtxysXqVzc3PWbGHyGMIgdrMdjayiWM63KXq0JK2GKkVdxn1DQizfs6tyJY7WvtDNksAnsAhjvEhUA0e(fvuOYJKtHKwcdjTJK(G35kkVdx9MLZUiILyUhjTQcjNbjTJKk7ERMHnHf5(Iiw81b3dZGjM3mH7uiPDKm4vt2XVn7mmqZqhjTJKbVAYo(TzNzpmNThjTQcjTeggcmb4Er5D4Qhp2cwXJdpmPyO3mH7u4aWqGn1VjJH8bVZvuEhU6nlNDrelXCpsAvfsodsAhjv29wndBclY9frS4RdUhMbtmVzc3Pqs7izWRMSJFB2zyGMHosAhjdE1KD8BZoZEyoBpsAvfsAjmmed0u0yiYCibaR4XtpMum0BMWDkCayigOPOXqaYSWxieofdb2u)MmgIEKK6e1XOHmhsam7H5S9iPDKuz3B1mSjSi3xeXIVo4EygmX8MjCNcjTJKbVAYo(TzNzpmNThjNcjFGoOwFrt4JK2rsgOzOxEF48EK0QkKCgK0osAdsAdsAjSrIKJaj9bVZvuEhU6nlNDrelXCpsoDizGrsRrsRqsBqYzNjmKCeiPniPfKKeKmmtyJejhbssuhJMHnHf5(Iiw81b3dZGjgVYGrrsRrYPdjNfjhbsAdsAbjjbjjQJrdd0m0lK5qcGzpmNThjNcjFGoOwFrt4JKwJKwJKwJHataUxuEhU6XJTGv84rIjfd9MjCNchagIbAkAmezoKaGHaBQFtgdrpsAdsQ8oC1u3PIKviPpHnkVdxn1DQiP1iPDKu5D4Qrt4xurHkpsofsAjmK0os6dENRO8oC1Bwo7IiwI5EK0QkKCgmeycW9IY7WvpESfSIht3XKIHEZeUtHdadb2u)MmgYh8oxr5D4Q3SC2frSeZ9iPvvi5myigOPOXqK5qcawXJTegMum0BMWDkCayigOPOXqaYSWxieofdb2u)MmgIEKK6e1XOHmhsam7H5S9iPDKKOognmqZqVqMdjaM9WC2EKCkK8b6GA9fnHpsAhj9bVZvuEhU6nlNDrelXCpsAvfsodgcmb4Er5D4Qhp2cwXJTybtkg6nt4ofoamed0u0yOegw4y9yiWM63KXq0JKuNOognK5qcGzpmNThjTJK7J79Kzc3rs7iPp4DUIY7WvVjBq2Fz9iPvvi5iXqGja3lkVdx94XwWkESLzXKIHyGMIgdTC2frSeZ9yO3mH7u4aWkESLaJjfd9MjCNchagIbAkAmKxu7kXCpgcSP(nzme9ij1jQJrdzoKay2dZz7rs7iPp4DUIY7WvVjBq2Fz9izfsgymeycW9IY7WvpESfSIhBzgmPyO3mH7u4aWqmqtrJHaIo64HL1JHaBQFtgdrpssDI6y0qMdjaM9WC2EK0osAdsQS7TAIo2twe6R5nt4ofsAhjjQJrdbdgLA5OA8kdgfjTQcjNfjPLwK0h8oxr5D4Q3Kni7VSEK0QkKC6rsAPfjv29wnRG3ShkeoMoMBEZeUtHK2rsFW7CfL3HREt2GS)Y6rsRQqs6osAngcmb4Er5D4Qhp2cwXJTqxysXqVzc3PWbGHyGMIgdLni7VSEmeyt9BYyi6rsQtuhJgYCibWShMZ2JHataUxuEhU6XJTGvSIHaSYysXJTGjfd9MjCNchagIbAkAmeGDUcd0u0fx6vmKl9APz4JHauESIhplMum0BMWDkCayiWM63KXqErTR4jZlfsovfsoJHUWqmqtrJHwo7IiwI5ESIhhymPyigOPOXqawzGBIhgd9MjCNchawXJNbtkg6nt4ofoameyt9BYyiLDVvdGm39DfQdl6yU38MjCNcjTJK0JK7H5S9iPDKeieokbD2gazU77kuhw0XCVzpmNThjTQcjzGMI2aiZcFHq4uZd0b16lAcFmed0u0yOegw4y9yfpMUWKIHyGMIgdbiZDFxH6WIoM7XqVzc3PWbGv84Wdtkg6nt4ofoamed0u0yiYCibadb2u)MmgIEK0gKu5D4QPUtfjRqsFcBuEhUAQ7ursRrs7iPY7WvJMWVOIcvEKCkK0syiPDK0h8oxr5D4Q3SC2frSeZ9iPvvi5irs7iPYU3QzytyrUViIfFDW9WmyI5nt4ofsAhjdE1KD8BZodd0m0rs7izWRMSJFB2z2dZz7rsRQqslHHHataUxuEhU6XJTGv84Phtkg6nt4ofoameyt9BYyiFW7CfL3HREZYzxeXsm3JKwvHKJejTJKk7ERMHnHf5(Iiw81b3dZGjM3mH7uiPDKm4vt2XVn7mmqZqhjTJKbVAYo(TzNzpmNThjTQcjTeggIbAkAmezoKaGv84rIjfd9MjCNchagIbAkAmeGml8fcHtXqGn1VjJHOhjPorDmAiZHeaZEyoBpsAhjv29wndBclY9frS4RdUhMbtmVzc3Pqs7izWRMSJFB2z2dZz7rYPqYhOdQ1x0e(iPDKKbAg6L3hoVhjTQcjhjsAhjTbjTbjTe2irYrGK(G35kkVdx9MLZUiILyUhjNoKmWiP1iPviPni5SZegsocK0gK0csscsgMjSrIKJajjQJrZWMWICFrel(6G7HzWeJxzWOiP1i50HKZIKJajTbjTGKKGKe1XOHbAg6fYCibWShMZ2JKtHKpqhuRVOj8rsRrsRrsRXqGja3lkVdx94XwWkEmDhtkg6nt4ofoamed0u0yiYCibadb2u)MmgIEK0gKu5D4QPUtfjRqsFcBuEhUAQ7ursRrs7iPY7WvJMWVOIcvEKCkK0syiPDK0h8oxr5D4Q3SC2frSeZ9iPvvi5myiWeG7fL3HRE8ylyfp2syysXqVzc3PWbGHaBQFtgd5dENRO8oC1Bwo7IiwI5EK0QkKCgmed0u0yiYCibaR4XwSGjfd9MjCNchagIbAkAmeGml8fcHtXqGn1VjJHOhjPorDmAiZHeaZEyoBpsAhjjQJrdd0m0lK5qcGzpmNThjNcjFGoOwFrt4JK2rsFW7CfL3HREZYzxeXsm3JKwvHKZGHataUxuEhU6XJTGv8ylZIjfd9MjCNchagIbAkAmucdlCSEmeyt9BYyi6rsQtuhJgYCibWShMZ2JK2rY9X9EYmH7iPDKCpmNThjTQcjbcHJsqNTbWkdCt8WM9WC2EmeycW9IY7WvpESfSIhBjWysXqmqtrJHwo7IiwI5Em0BMWDkCayfp2YmysXqVzc3PWbGHyGMIgd5f1Usm3JHaBQFtgdrpssDI6y0qMdjaM9WC2EmeycW9IY7WvpESfSIhBHUWKIHEZeUtHdadXanfngci6OJhwwpgcSP(nzme9ij1jQJrdzoKay2dZz7XqGja3lkVdx94XwWkESLWdtkg6nt4ofoamed0u0yipzMsqNe1BJHaBQFtgdrpssDI6y0qMdjaM9WC2EK0osAdsAdsciZ7W9izfsolsslTij9ijrDmAiyWOulhvZEyoBpsslTijrDmAiyWOulhvZEyoBpsofssuhJgcgmk1Yr14vgmksocKKbAkAt2GS)Y6npqhuRVOj8rsRrsRXqGja3lkVdx94XwWkESLPhtkg6nt4ofoamed0u0yOSbz)L1JHaBQFtgdrpssDI6y0qMdjaM9WC2EmeycW9IY7WvpESfSIvSIHc91NIgpE2WSmYWgzy0LXILzTGHOtE7Sh8yi6g62W)X0rJdFPdijssk5JKjCqXQizuSiz4OEKRDA4qY9HF15EkK0lGpsY1QaM1tHKaYCpCVbnFAM9rYPNoGKtdrh6REkKSf906dEqgtasgoL3HRHdjvbsgoL3HRM6o1WHK2mBGS2GMJMt3q3g(pMoAC4lDajrssjFKmHdkwfjJIfjdx2XWHK7d)QZ9uiPxaFKKRvbmRNcjbK5E4EdA(0m7JKHhDajNgIo0x9uizl6P1h8GmMaKmCkVdxdhsQcKmCkVdxn1DQHdjTz2azTbnFAM9rs6oDajNgIo0x9uizl6P1h8GmMaKmCkVdxdhsQcKmCkVdxn1DQHdjTz2azTbnhnNUHUn8FmD04Wx6asIKKs(izchuSksgflsgoaRC4qY9HF15EkK0lGpsY1QaM1tHKaYCpCVbnFAM9rYWJoGKtdrh6REkKSf906dEqgtasgoL3HRHdjvbsgoL3HRM6o1WHK2mBGS2GMpnZ(ijDNoGKtdrh6REkKSf906dEqgtasgoL3HRHdjvbsgoL3HRM6o1WHK2mBGS2GMJMt3q3g(pMoAC4lDajrssjFKmHdkwfjJIfjdxSjchsUp8Ro3tHKEb8rsUwfWSEkKeqM7H7nO5tZSpssx0bKCAi6qF1tHKTONwFWdYycqYWP8oCnCiPkqYWP8oC1u3PgoK0MzdK1g08Pz2hjhjDajNgIo0x9uizl6P1h8GmMaKmCkVdxdhsQcKmCkVdxn1DQHdjTz2azTbnhnNocoOy1tHKHhsYanfns6sV6nO5yOGRiMUJHcFGKHpd0b16PqsIhf7rsGaMGvKK4dz7nijDla8GQhjBrpTK5fow7qsgOPO9iPODtmO5mqtr7nb3deWeSwfDSFu0CgOPO9MG7bcycwjPY2OqqHMZanfT3eCpqatWkjv2Y1dWVvwtrJMZanfT3eCpqatWkjv26RHHfDj4v0CgOPO9MG7bcycwjPY2HnHf5(Iiw8myZyconzSsz3B1mSjSi3xeXINbBgtWnVzc3PqZzGMI2BcUhiGjyLKkB9nh0twOfVYQhnNbAkAVj4EGaMGvsQSnOqtrJMZanfT3eCpqatWkjv26f1Usm3JMZanfT3eCpqatWkjv2Mni7VSEAYyf9k7ERgVO2vI5EZBMWDk0C08Whiz4ZaDqTEkK8H(obj1e(iPs(ijduXIKPhj5qC6yc3nO5mqtr7R8bVZvCcWOO5mqtr7jPY2TUlmqtrxCPxPPz4xbyLPjJv(G35kkVdx9MSJFB2vy6Kh9D2dtvfy7k7ERgaRmWnXdBEZeUtHMZanfTNKkB36UWanfDXLELMMHFvSjOjJv(G35kkVdx9MSJFB2vy6Kh9D2dtvfy7k7ERMyUVWnvHytyVk6BEZeUtHMZanfTNKkB36UWanfDXLELMMHFv2rAYyLp4DUIY7WvVj743MDfMo5rFN9Wuvb2UYU3Qj743wyEZeUtHMZanfTNKkBtyyHJ1tdycW9IY7WvFLfAYyf9uNOognK5qcGzpmNT3Un7J79Kzc3PLwLDVvt263MDfGaMO2RPOnVzc3PSZanfTbqMf(cHWPMSlrxoqwTVhMZ2pTmqtrBaKzHVqiCQrxo0DfnH)0sxwrvVSMIEeHzcS1O5mqtr7jPYwa7CfgOPOlU0R00m8RauE0CgOPO9KuzlzoKaqdycW9IY7WvFLfAYyf92O8oCTYNWgL3HRwBx5D4Qrt4xurHk)uwcdnNbAkApjv2sMdja0KXkgOzOxEF48(PSGMZanfTNKkBbK5UVRqDyrhZ9O5mqtr7jPYwaRmWnXdJMZanfTNKkB9IAxjM7Pbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2JMZanfTNKkBbKzHVqiCknGja3lkVdx9vwOjJv0tDI6y0qMdjaM9WC2E7pqhuRVOj8jrxo0DfnHVvkVdxnAc)Ikku5TBJYU3QjB9BZUcqatu71u0M3mH7u0sl9k7ERMS1Vn7kabmrTxtrBEZeUtz3lQDfpzEPMQAgAP1gLDVvZxMkbSMI28MjCNYo1jQJrZxMkbSMI2ShMZ2BvfG9Art4BnT0suhJgkEhT4f1Us2ELjsxQtm7H5S9tbyVw0e(0sBWRMSJFB2zyGMHUDLDVvZWMWICFrel(6G7HzWeZBMWDkRrZzGMI2tsLTarhD8WY6Pbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2B3gBu29wnrh7jlc918MjCNYorDmAiyWOulhvJxzWOwvnR10sRn0RS7TAIo2twe6R5nt4oLDI6y0qWGrPwoQgVYGrTAwRTgnNbAkApjv26jZuc6KOEBAataUxuEhU6RSqtgRON6e1XOHmhsam7H5S92TXgazEhUVAwAPLEI6y0qWGrPwoQM9WC2EAPLOognemyuQLJQzpmNTFkI6y0qWGrPwoQgVYGrhbd0u0MSbz)L1BEGoOwFrt4BT1O5mqtr7jPY2Sbz)L1tdycW9IY7WvFLfAYyf9uNOognK5qcGzpmNThnhnNbAkAVbWkxbyNRWanfDXLELMMHFfGYJMZanfT3ayLjPY2LZUiILyUNMmw5f1UINmVutvnJHUqZzGMI2BaSYKuzlGvg4M4HrZzGMI2BaSYKuzBcdlCSEAYyLYU3QbqM7(Uc1HfDm3BEZeUtzN(9WC2E7aHWrjOZ2aiZDFxH6WIoM7n7H5S9wvXanfTbqMf(cHWPMhOdQ1x0e(O5mqtr7nawzsQSfqM7(Uc1HfDm3JMZanfT3ayLjPYwYCibGgWeG7fL3HR(kl0KXk6Tr5D4ALpHnkVdxT2UY7WvJMWVOIcv(PSeMDFW7CfL3HREZYzxeXsm3Bv1iTRS7TAg2ewK7lIyXxhCpmdMyEZeUtzp4vt2XVn7mmqZq3EWRMSJFB2z2dZz7TQYsyO5mqtr7nawzsQSLmhsaOjJv(G35kkVdx9MLZUiILyU3QQrAxz3B1mSjSi3xeXIVo4EygmX8MjCNYEWRMSJFB2zyGMHU9Gxnzh)2SZShMZ2BvLLWqZzGMI2BaSYKuzlGml8fcHtPbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2Bxz3B1mSjSi3xeXIVo4EygmX8MjCNYEWRMSJFB2z2dZz7N6b6GA9fnHVDgOzOxEF48ERQgPDBSXsyJCe(G35kkVdx9MLZUiILyUF6cS1wzZSZe2iSXcjHzcBKJGOogndBclY9frS4RdUhMbtmELbJA90n7iSXcje1XOHbAg6fYCibWShMZ2p1d0b16lAcFRT2A0CgOPO9gaRmjv2sMdja0aMaCVO8oC1xzHMmwrVnkVdxR8jSr5D4Q12vEhUA0e(fvuOYpLLWS7dENRO8oC1Bwo7IiwI5ERQMbnNbAkAVbWktsLTK5qcanzSYh8oxr5D4Q3SC2frSeZ9wvndAod0u0EdGvMKkBbKzHVqiCknGja3lkVdx9vwOjJv0tDI6y0qMdjaM9WC2E7e1XOHbAg6fYCibWShMZ2p1d0b16lAcF7(G35kkVdx9MLZUiILyU3QQzqZzGMI2BaSYKuzBcdlCSEAataUxuEhU6RSqtgRON6e1XOHmhsam7H5S923h37jZeUBFpmNT3QkGq4Oe0zBaSYa3epSzpmNThnNbAkAVbWktsLTlNDrelXCpAod0u0EdGvMKkB9IAxjM7Pbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2JMZanfT3ayLjPYwGOJoEyz90aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7rZzGMI2BaSYKuzRNmtjOtI6TPbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2B3gBaK5D4(QzPLw6jQJrdbdgLA5OA2dZz7PLwI6y0qWGrPwoQM9WC2(PiQJrdbdgLA5OA8kdgDemqtrBYgK9xwV5b6GA9fnHV1wJMZanfT3ayLjPY2Sbz)L1tdycW9IY7WvFLfAYyf9uNOognK5qcGzpmNThnhnNbAkAVbq5R81WWIUKD8BZoAYyLY7WvJMWVOIcv(PQM1sy0sl9aHWrjOZ2qX7OfVO2vY2Rmr6sDIzpmNTNwAvEhUA0e(fvuOYBvvGdJKbafT0sVYU3QHI3rlErTRKTxzI0L6eZBMWDk0CgOPO9gaLNKkBP4D0Ixu7kz7vMiDPoHMmwP8oC1Oj8lQOqLFQklZegT0g8Qj743MDggOzOtlTkVdxnAc)Ikku5TQA2WizaqHMZanfT3aO8KuzBqHMIMMmwf8Qj743MDggOzOtlTkVdxnAc)Ikku5Tk8Ol0CgOPO9gaLNKkBj(6)oA2dO5mqtr7nakpjv2s4ecQsSENGMZanfT3aO8KuzBm3t4eck0CgOPO9gaLNKkBR9VK6H9O5O5mqtr7nXMOcWoxHbAk6Il9knnd)kaLhnNbAkAVj2eKuz7YzxeXsm3ttgR8IAxXtMxQPQMXqxO5mqtr7nXMGKkBtyyHJ1ttgRu29wnaYC33vOoSOJ5EZBMWDk70VhMZ2BhieokbD2gazU77kuhw0XCVzpmNT3QkgOPOnaYSWxieo18aDqT(IMWhnNbAkAVj2eKuzlGm39DfQdl6yUhnNbAkAVj2eKuzlzoKaqdycW9IY7WvFLfAYyf92O8oCTYNWgL3HRwBx5D4Qrt4xurHk)uwcZUp4DUIY7WvVz5SlIyjM7TQAg7k7ERMHnHf5(Iiw81b3dZGjM3mH7u2dE1KD8BZodd0m0Th8Qj743MDM9WC2ERQSegAod0u0EtSjiPYwYCibGMmw5dENRO8oC1Bwo7IiwI5ERQMXUYU3QzytyrUViIfFDW9WmyI5nt4oL9Gxnzh)2SZWandD7bVAYo(TzNzpmNT3QklHHMZanfT3eBcsQSfqMf(cHWP0aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7TRS7TAg2ewK7lIyXxhCpmdMyEZeUtzp4vt2XVn7m7H5S9t9aDqT(IMW3od0m0lVpCEVvvZy3gBSe2ihHp4DUIY7WvVz5SlIyjM7NUaBTv2m7mHncBSqsyMWg5iiQJrZWMWICFrel(6G7HzWeJxzWOwpDZocBSqcrDmAyGMHEHmhsam7H5S9t9aDqT(IMW3ARTgnNbAkAVj2eKuzlzoKaqdycW9IY7WvFLfAYyf92O8oCTYNWgL3HRwBx5D4Qrt4xurHk)uwcZUp4DUIY7WvVz5SlIyjM7TQAg0CgOPO9MytqsLTK5qcanzSYh8oxr5D4Q3SC2frSeZ9wvndAod0u0EtSjiPYwazw4lecNsdycW9IY7WvFLfAYyf9uNOognK5qcGzpmNT3orDmAyGMHEHmhsam7H5S9t9aDqT(IMW3Up4DUIY7WvVz5SlIyjM7TQAg0CgOPO9MytqsLTjmSWX6Pbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2BFFCVNmt4UDFW7CfL3HREt2GS)Y6TQAKO5mqtr7nXMGKkBxo7IiwI5E0CgOPO9MytqsLTErTReZ90aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7T7dENRO8oC1BYgK9xwFvGrZzGMI2BInbjv2ceD0XdlRNgWeG7fL3HR(kl0KXk6PorDmAiZHeaZEyoBVDBu29wnrh7jlc918MjCNYorDmAiyWOulhvJxzWOwvnlT06dENRO8oC1BYgK9xwVvvtpT0QS7TAwbVzpuiCmDm38MjCNYUp4DUIY7WvVjBq2Fz9wvr3TgnNbAkAVj2eKuzB2GS)Y6Pbmb4Er5D4QVYcnzSIEQtuhJgYCibWShMZ2JMJMZanfT3KDScWoxHbAk6Il9knnd)kaLhnNbAkAVj7ijv2UC2frSeZ90KXkVO2v8K5LAQQzm0fAod0u0Et2rsQSfWkdCt8WO5mqtr7nzhjPY2egw4y90KXkLDVvdGm39DfQdl6yU38MjCNYo97H5S92bcHJsqNTbqM7(Uc1HfDm3B2dZz7TQIbAkAdGml8fcHtnpqhuRVOj8rZzGMI2BYossLTaYC33vOoSOJ5E0CgOPO9MSJKuzlzoKaqdycW9IY7WvFLfAYyf92O8oCTYNWgL3HRwBx5D4Qrt4xurHk)uwcZUp4DUIY7WvVz5SlIyjM7TQAgsu29wnzRFB2vacyIAVMI28MjCNYUYU3QzytyrUViIfFDW9WmyI5nt4oL9Gxnzh)2SZWandD7bVAYo(TzNzpmNT3QklHHMZanfT3KDKKkBjZHeaAYyLp4DUIY7WvVz5SlIyjM7TQAgsu29wnzRFB2vacyIAVMI28MjCNYUYU3QzytyrUViIfFDW9WmyI5nt4oL9Gxnzh)2SZWandD7bVAYo(TzNzpmNT3QklHHMZanfT3KDKKkBbKzHVqiCknGja3lkVdx9vwOjJv0tDI6y0qMdjaM9WC2E7k7ERMHnHf5(Iiw81b3dZGjM3mH7u2dE1KD8BZoZEyoB)upqhuRVOj8T7dENRO8oC1Bwo7IiwI5ERQMHeLDVvt263MDfGaMO2RPOnVzc3PSBJnwcBKJWh8oxr5D4Q3SC2frSeZ9tNnbEAdZyj8gHp4DUIY7WvVz5SlIyjM7T2ARSz2zcBe2yHKWmHnYrquhJMHnHf5(Iiw81b3dZGjgVYGrTE6MDe2yHeI6y0Wand9czoKay2dZz7N6b6GA9fnHV1wBnAod0u0Et2rsQSLmhsaObmb4Er5D4QVYcnzSIEBuEhUw5tyJY7WvRTR8oC1Oj8lQOqLFklHz3h8oxr5D4Q3SC2frSeZ9wvfy72OS7TA(YujG1u0M3mH7u0sRYU3QjB9BZUcqatu71u0M3mH7uwJMZanfT3KDKKkBjZHeaAYyLp4DUIY7WvVz5SlIyjM7TQkW2Trz3B18LPsaRPOnVzc3POLwLDVvt263MDfGaMO2RPOnVzc3PSgnNbAkAVj7ijv2ciZcFHq4uAataUxuEhU6RSqtgRON6e1XOHmhsam7H5S92jQJrdd0m0lK5qcGzpmNTFQhOdQ1x0e(29bVZvuEhU6nlNDrelXCVvvb2Unk7ERMVmvcynfT5nt4ofT0QS7TAYw)2SRaeWe1EnfT5nt4oL1O5mqtr7nzhjPY2egw4y90aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7TVpU3tMjChnNbAkAVj7ijv2UC2frSeZ9O5mqtr7nzhjPYwVO2vI5EAataUxuEhU6RSqtgRON6e1XOHmhsam7H5S9O5mqtr7nzhjPYwGOJoEyz90aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7rZzGMI2BYossLTEYmLGojQ3MgWeG7fL3HR(kl0KXk6PorDmAiZHeaZEyoBVDBSbqM3H7RMLwAPNOognemyuQLJQzpmNTNwAjQJrdbdgLA5OA2dZz7NIOognemyuQLJQXRmy0rWanfTjBq2Fz9MhOdQ1x0e(wBnAod0u0Et2rsQSnBq2Fz90aMaCVO8oC1xzHMmwrp1jQJrdzoKay2dZz7Xq(GhGhpB4n9yfRyma]] )

end
