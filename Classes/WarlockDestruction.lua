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

            generate = function ()
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
            
            startsCombat = true,
            
            talent = "grimoire_of_sacrifice",
            nobuff = "grimoire_of_sacrifice",
            
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
            indicator = function () return target.unit == lastTarget and "cycle" or nil end,
            cycle = "havoc",
            
            usable = function () return active_enemies > 1 end,
            handler = function ()
                applyDebuff( "target", "havoc" )
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
            cycle = "immolate",
            
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
    
        package = "Destruction",
    } )


    spec:RegisterPack( "Destruction", 20180805.1121, [[dCe5jbqiKQEKGQcxsrvSjQKpPazuuHofvWQeu5viIzHO6wksXUO4xurgMGYXOsTmfvEMaQPHuX1uKQTjOkFdPsmofOohsLQ1HujnpQOUNe2NIKdIuP0cfGhQiLmrfvP6IcQk6JcQknsfvP0jvKsTsfLzQOkzNkOLkOQQNcYurK(ksLI9c5VsAWeDyulgHhdmzKCzvBwOpRqJgPCArVwbmBkDBqTBP(nHHlqhxqvLLR0ZPQPt66s02fKVROQgVaY5veRxrvkMpIY(HAKBePiikwpA4CH5EWHn4WMUXTB309PhEiiDsWJGcYGb4XJGAg(iO5971TeOPOrqb5jwbtHifb5fLl4iiAQg0txDYPXuPvsyacyN8jCPL1u0GLJQt(eg4eHvq4erKNgQhYPGRiM27DI087CUDI05CxPB41kaduN3Vx3sGMI24tyacIOmT60UreiikwpA4CH5EWHn4WOJzUap9PtheexQ0elcckHNwiiQ7biisPLESm9yjJLbzWa84XsrelzGMIglTPx9yzuSy582pqAtdcYME1Jifbr9ixAvePOHUrKIGyGMIgb5dERTAfGbqqVzc7PqbGu0W5qKIGEZe2tHcabb2u)MmcYh8wBv5D8Q3KD8BZ2kpFEG3zpILtvGLbglDHLkBFRgaRmWoXdBEZe2tHGyGMIgbTLDLbAk6Qn9kcYMET2m8rqawzKIggyePiO3mH9uOaqqGn1VjJG8bV1wvEhV6nzh)2STYZNh4D2Jy5ufyzGXsxyPY23QjM7RCtvj2e2RI(M3mH9uiigOPOrqBzxzGMIUAtVIGSPxRndFeuSjqkAiDqKIGEZe2tHcabb2u)MmcYh8wBv5D8Q3KD8BZ2kpFEG3zpILtvGLbglDHLkBFRMSJFBH5ntypfcIbAkAe0w2vgOPOR20RiiB61AZWhbLDePOHthrkc6ntypfkaeed0u0iOegwyz9iiWM63Krq0JLuNOmgn04qcGzpmNThlDHLoIL7J790yc7XsYidlv2(wnzRFB2wbcyIsVMI28MjSNclDHLmqtrBa0yHVsiSQj7A0MJ0uS0fwUhMZ2JLtdwYanfTbqJf(kHWQgD5q3w1e(y50GLthlDglPkxwtrJLHdldZeyS0beeycW(QY74vpAOBKIggEisrqVzc7PqbGGyGMIgbbyRTYanfD1MEfbztVwBg(iiaLhPOH0fePiO3mH9uOaqqmqtrJGOXHeaeeyt9BYii6XshXsL3XRMYovSSal9jSr5D8QPStflDalDHLkVJxnAc)QkQu5XYPWs3HHGata2xvEhV6rdDJu0WbJifb9MjSNcfaccSP(nzeed0m0RVpCEpwofw6gbXanfncIghsaqkAiDhrkcIbAkAeeGg39TvQdl6yUhb9MjSNcfasrdDhgIueed0u0iiaRmWoXdJGEZe2tHcaPOHUDJifb9MjSNcfacIbAkAeKxuARXCpccSP(nzee9yj1jkJrdnoKay2dZz7rqGja7RkVJx9OHUrkAO75qKIGEZe2tHcabXanfnccqJf(kHWQiiWM63Krq0JLuNOmgn04qcGzpmNThlDHLpqhuQVQj8XssWsD5q3w1e(yPZyPY74vJMWVQIkvES0fw6iwQS9TAYw)2STceWeLEnfT5ntypfwsgzyj9yPY23QjB9BZ2kqatu61u0M3mH9uyPlS0lkTvpnEPWYPkWs6GLKrgw6iwQS9TA(YujG1u0M3mH9uyPlSK6eLXO5ltLawtrB2dZz7XsNlWsa71QMWhlDaljJmSKOmgnu8oq1lkT1S9ktK2uNy2dZz7XYPWsa71QMWhljJmSm4vt2XVnBnmqZqhlDHLkBFRMXnHf5(Qiw9Lb3dZGjM3mH9uyPdiiWeG9vL3XRE0q3ifn0DGrKIGEZe2tHcabXanfncci6OLhxwpccSP(nzee9yj1jkJrdnoKay2dZz7XsxyPJyPJyPY23QjAzpnrOVM3mH9uyPlSKOmgnemyaQLJQXRmyaS05cSCoS0bSKmYWshXs6XsLTVvt0YEAIqFnVzc7PWsxyjrzmAiyWaulhvJxzWayPZy5CyPdyPdiiWeG9vL3XRE0q3ifn0nDqKIGEZe2tHcabXanfncYtJPeZNOCBeeyt9BYii6XsQtugJgACibWShMZ2JLUWshXshXsanEhVhllWY5WsYidlPhljkJrdbdgGA5OA2dZz7XsYidljkJrdbdgGA5OA2dZz7XYPWsIYy0qWGbOwoQgVYGbWYWHLmqtrBYgK9xwV5b6Gs9vnHpw6aw6accmbyFv5D8Qhn0nsrdDpDePiO3mH9uOaqqmqtrJGYgK9xwpccSP(nzee9yj1jkJrdnoKay2dZz7rqGja7RkVJx9OHUrksrqb3deWeSIifn0nIue0BMWEkuaifnCoePiO3mH9uOaqkAyGrKIGEZe2tHcaPOH0brkcIbAkAeKVegw014T0kB9lc6ntypfkaKIgoDePiO3mH9uOaqqGn1VjJGu2(wnJBclY9vrS6zWMXeCZBMWEkeed0u0iOXnHf5(Qiw9myZycosrddpePiO3mH9uOaqkAiDbrkcIbAkAeuqHMIgb9MjSNcfasrdhmIueed0u0iiVO0wJ5Ee0BMWEkuaifnKUJifb9MjSNcfaccSP(nzee9yPY23QXlkT1yU38MjSNcbXanfnckBq2Fz9ifPiiaLhrkAOBePiO3mH9uOaqqGn1VjJGuEhVA0e(vvuPYJLtvGLZ5omSKmYWs6XsGqyPeZVnu8oq1lkT1S9ktK2uNy2dZz7XsYidlvEhVA0e(vvuPYJLoxGLbomSKeSCeqHLKrgwspwQS9TAO4DGQxuARz7vMiTPoX8MjSNcbXanfncYxcdl6A2XVnBrkA4CisrqVzc7PqbGGaBQFtgbP8oE1Oj8RQOsLhlNQalDtNWWsYidldE1KD8BZwdd0m0XsYidlvEhVA0e(vvuPYJLoxGLZfgwscwocOqqmqtrJGO4DGQxuARz7vMiTPobPOHbgrkc6ntypfkaeeyt9BYiOGxnzh)2S1WandDSKmYWsL3XRgnHFvfvQ8yPZyz4nDeed0u0iOGcnfnsrdPdIueed0u0iiIV(VdK9ic6ntypfkaKIgoDePiigOPOrqewHGQgl3jiO3mH9uOaqkAy4HifbXanfnckM7jScbfc6ntypfkaKIgsxqKIGyGMIgbv6Fn1d7rqVzc7PqbGuKIGYoIifn0nIue0BMWEkuaiigOPOrqa2ARmqtrxTPxrq20R1MHpccq5rkA4CisrqVzc7PqbGGaBQFtgb5fL2QNgVuy5ufyjDmthbXanfncA5SRIynM7rkAyGrKIGyGMIgbbyLb2jEye0BMWEkuaifnKoisrqVzc7PqbGGaBQFtgbPS9TAa04UVTsDyrhZ9M3mH9uyPlSKESCpmNThlDHLaHWsjMFBa04UVTsDyrhZ9M9WC2ES05cSKbAkAdGgl8vcHvnpqhuQVQj8rqmqtrJGsyyHL1Ju0WPJifbXanfnccqJ7(2k1HfDm3JGEZe2tHcaPOHHhIue0BMWEkuaiigOPOrq04qcaccSP(nzee9yPJyPY74vtzNkwwGL(e2O8oE1u2PILoGLUWsL3XRgnHFvfvQ8y5uyP7WWsxyPp4T2QY74vVz5SRIynM7XsNlWs6GLKGLkBFRMS1VnBRabmrPxtrBEZe2tHLUWsLTVvZ4MWICFveR(YG7HzWeZBMWEkS0fwg8Qj743MTggOzOJLUWYGxnzh)2S1ShMZ2JLoxGLUddbbMaSVQ8oE1Jg6gPOH0fePiO3mH9uOaqqGn1VjJG8bV1wvEhV6nlNDveRXCpw6CbwshSKeSuz7B1KT(TzBfiGjk9AkAZBMWEkS0fwQS9TAg3ewK7RIy1xgCpmdMyEZe2tHLUWYGxnzh)2S1WandDS0fwg8Qj743MTM9WC2ES05cS0DyiigOPOrq04qcasrdhmIue0BMWEkuaiigOPOrqaASWxjewfbb2u)MmcIESK6eLXOHghsam7H5S9yPlSuz7B1mUjSi3xfXQVm4EygmX8MjSNclDHLbVAYo(TzRzpmNThlNclFGoOuFvt4JLUWsFWBTvL3XREZYzxfXAm3JLoxGL0bljblv2(wnzRFB2wbcyIsVMI28MjSNclDHLoILoILUdBWyz4WsFWBTvL3XREZYzxfXAm3JLZdw6iwgySCAWYWmUdpSmCyPp4T2QY74vVz5SRIynM7XshWshWsNXshXY5Otyyz4WshXs3yjjyzyMWgmwgoSKOmgnJBclY9vrS6ldUhMbtmELbdGLoGLZdwohwgoS0rS0nwscwsugJggOzOxPXHeaZEyoBpwofw(aDqP(QMWhlDalDalDabbMaSVQ8oE1Jg6gPOH0DePiO3mH9uOaqqmqtrJGOXHeaeeyt9BYii6XshXsL3XRMYovSSal9jSr5D8QPStflDalDHLkVJxnAc)QkQu5XYPWs3HHLUWsFWBTvL3XREZYzxfXAm3JLoxGLbglDHLoILkBFRMVmvcynfT5ntypfwsgzyPY23QjB9BZ2kqatu61u0M3mH9uyPdiiWeG9vL3XRE0q3ifn0DyisrqVzc7PqbGGaBQFtgb5dERTQ8oE1Bwo7QiwJ5ES05cSmWyPlS0rSuz7B18LPsaRPOnVzc7PWsYidlv2(wnzRFB2wbcyIsVMI28MjSNclDabXanfncIghsaqkAOB3isrqVzc7PqbGGyGMIgbbOXcFLqyveeyt9BYii6XsQtugJgACibWShMZ2JLUWsIYy0Wand9knoKay2dZz7XYPWYhOdk1x1e(yPlS0h8wBv5D8Q3SC2vrSgZ9yPZfyzGXsxyPJyPY23Q5ltLawtrBEZe2tHLKrgwQS9TAYw)2STceWeLEnfT5ntypfw6accmbyFv5D8Qhn0nsrdDphIue0BMWEkuaiigOPOrqjmSWY6rqGn1VjJGOhlPorzmAOXHeaZEyoBpw6cl3h37PXe2JGata2xvEhV6rdDJu0q3bgrkcIbAkAe0YzxfXAm3JGEZe2tHcaPOHUPdIue0BMWEkuaiigOPOrqErPTgZ9iiWM63Krq0JLuNOmgn04qcGzpmNThbbMaSVQ8oE1Jg6gPOHUNoIue0BMWEkuaiigOPOrqarhT84Y6rqGn1VjJGOhlPorzmAOXHeaZEyoBpccmbyFv5D8Qhn0nsrdDhEisrqVzc7PqbGGyGMIgb5PXuI5tuUnccSP(nzee9yj1jkJrdnoKay2dZz7XsxyPJyPJyjGgVJ3JLfy5CyjzKHL0JLeLXOHGbdqTCun7H5S9yjzKHLeLXOHGbdqTCun7H5S9y5uyjrzmAiyWaulhvJxzWayz4WsgOPOnzdY(lR38aDqP(QMWhlDalDabbMaSVQ8oE1Jg6gPOHUPlisrqVzc7PqbGGyGMIgbLni7VSEeeyt9BYii6XsQtugJgACibWShMZ2JGata2xvEhV6rdDJuKIGInbIu0q3isrqVzc7PqbGGyGMIgbbyRTYanfD1MEfbztVwBg(iiaLhPOHZHifb9MjSNcfaccSP(nzeKxuAREA8sHLtvGL0XmDeed0u0iOLZUkI1yUhPOHbgrkc6ntypfkaeeyt9BYiiLTVvdGg39TvQdl6yU38MjSNclDHL0JL7H5S9yPlSeiewkX8BdGg39TvQdl6yU3ShMZ2JLoxGLmqtrBa0yHVsiSQ5b6Gs9vnHpcIbAkAeucdlSSEKIgshePiigOPOrqaAC33wPoSOJ5Ee0BMWEkuaifnC6isrqVzc7PqbGGyGMIgbrJdjaiiWM63Krq0JLoILkVJxnLDQyzbw6tyJY74vtzNkw6aw6clvEhVA0e(vvuPYJLtHLUddlDHL(G3ARkVJx9MLZUkI1yUhlDUalPdw6clv2(wnJBclY9vrS6ldUhMbtmVzc7PWsxyzWRMSJFB2AyGMHow6cldE1KD8BZwZEyoBpw6Cbw6omeeycW(QY74vpAOBKIggEisrqVzc7PqbGGaBQFtgb5dERTQ8oE1Bwo7QiwJ5ES05cSKoyPlSuz7B1mUjSi3xfXQVm4EygmX8MjSNclDHLbVAYo(TzRHbAg6yPlSm4vt2XVnBn7H5S9yPZfyP7WqqmqtrJGOXHeaKIgsxqKIGEZe2tHcabXanfnccqJf(kHWQiiWM63Krq0JLuNOmgn04qcGzpmNThlDHLkBFRMXnHf5(Qiw9Lb3dZGjM3mH9uyPlSm4vt2XVnBn7H5S9y5uy5d0bL6RAcFS0fwYand967dN3JLoxGL0blDHLoILoILUdBWyz4WsFWBTvL3XREZYzxfXAm3JLZdwgyS0bS0zS0rSCo6egwgoS0rS0nwscwgMjSbJLHdljkJrZ4MWICFveR(YG7HzWeJxzWayPdy58GLZHLHdlDelDJLKGLeLXOHbAg6vACibWShMZ2JLtHLpqhuQVQj8XshWshWshqqGja7RkVJx9OHUrkA4GrKIGEZe2tHcabXanfnckHHfwwpccSP(nzee9yj1jkJrdnoKay2dZz7Xsxy5(4EpnMWES0fw6dERTQ8oE1BYgK9xwpw6CbwoyeeycW(QY74vpAOBKIgs3rKIGyGMIgbTC2vrSgZ9iO3mH9uOaqkAO7WqKIGEZe2tHcabXanfncYlkT1yUhbb2u)MmcIESK6eLXOHghsam7H5S9yPlS0h8wBv5D8Q3Kni7VSESSaldmccmbyFv5D8Qhn0nsrdD7grkc6ntypfkaeed0u0iiGOJwECz9iiWM63Krq0JLuNOmgn04qcGzpmNThlDHLoILkBFRMOL90eH(AEZe2tHLUWsIYy0qWGbOwoQgVYGbWsNlWY5WsYidl9bV1wvEhV6nzdY(lRhlDUalPlyjzKHLkBFRMvWB2JvclpV5M3mH9uyPlS0h8wBv5D8Q3Kni7VSES05cSKUJLoGGata2xvEhV6rdDJu0q3ZHifb9MjSNcfacIbAkAeu2GS)Y6rqGn1VjJGOhlPorzmAOXHeaZEyoBpccmbyFv5D8Qhn0nsrkccWkJifn0nIue0BMWEkuaiigOPOrqa2ARmqtrxTPxrq20R1MHpccq5rkA4CisrqVzc7PqbGGaBQFtgb5fL2QNgVuy5ufyjDmthbXanfncA5SRIynM7rkAyGrKIGyGMIgbbyLb2jEye0BMWEkuaifnKoisrqVzc7PqbGGaBQFtgbPS9TAa04UVTsDyrhZ9M3mH9uyPlSKESCpmNThlDHLaHWsjMFBa04UVTsDyrhZ9M9WC2ES05cSKbAkAdGgl8vcHvnpqhuQVQj8rqmqtrJGsyyHL1Ju0WPJifbXanfnccqJ7(2k1HfDm3JGEZe2tHcaPOHHhIue0BMWEkuaiigOPOrq04qcaccSP(nzee9yPJyPY74vtzNkwwGL(e2O8oE1u2PILoGLUWsL3XRgnHFvfvQ8y5uyP7WWsxyPp4T2QY74vVz5SRIynM7XsNlWYbJLUWsLTVvZ4MWICFveR(YG7HzWeZBMWEkS0fwg8Qj743MTggOzOJLUWYGxnzh)2S1ShMZ2JLoxGLUddbbMaSVQ8oE1Jg6gPOH0fePiO3mH9uOaqqGn1VjJG8bV1wvEhV6nlNDveRXCpw6CbwoyS0fwQS9TAg3ewK7RIy1xgCpmdMyEZe2tHLUWYGxnzh)2S1WandDS0fwg8Qj743MTM9WC2ES05cS0DyiigOPOrq04qcasrdhmIue0BMWEkuaiigOPOrqaASWxjewfbb2u)MmcIESK6eLXOHghsam7H5S9yPlSuz7B1mUjSi3xfXQVm4EygmX8MjSNclDHLbVAYo(TzRzpmNThlNclFGoOuFvt4JLUWsgOzOxFF48ES05cSCWyPlS0rS0rS0Dydgldhw6dERTQ8oE1Bwo7QiwJ5ESCEWYaJLoGLoJLoILZrNWWYWHLoILUXssWYWmHnySmCyjrzmAg3ewK7RIy1xgCpmdMy8kdgalDalNhSCoSmCyPJyPBSKeSKOmgnmqZqVsJdjaM9WC2ESCkS8b6Gs9vnHpw6aw6aw6accmbyFv5D8Qhn0nsrdP7isrqVzc7PqbGGyGMIgbrJdjaiiWM63Krq0JLoILkVJxnLDQyzbw6tyJY74vtzNkw6aw6clvEhVA0e(vvuPYJLtHLUddlDHL(G3ARkVJx9MLZUkI1yUhlDUalPdccmbyFv5D8Qhn0nsrdDhgIue0BMWEkuaiiWM63Krq(G3ARkVJx9MLZUkI1yUhlDUalPdcIbAkAeenoKaGu0q3UrKIGEZe2tHcabXanfnccqJf(kHWQiiWM63Krq0JLuNOmgn04qcGzpmNThlDHLeLXOHbAg6vACibWShMZ2JLtHLpqhuQVQj8XsxyPp4T2QY74vVz5SRIynM7XsNlWs6GGata2xvEhV6rdDJu0q3ZHifb9MjSNcfacIbAkAeucdlSSEeeyt9BYii6XsQtugJgACibWShMZ2JLUWY9X9EAmH9yPlSCpmNThlDUalbcHLsm)2ayLb2jEyZEyoBpccmbyFv5D8Qhn0nsrdDhyePiigOPOrqlNDveRXCpc6ntypfkaKIg6MoisrqVzc7PqbGGyGMIgb5fL2Am3JGaBQFtgbrpwsDIYy0qJdjaM9WC2EeeycW(QY74vpAOBKIg6E6isrqVzc7PqbGGyGMIgbbeD0YJlRhbb2u)MmcIESK6eLXOHghsam7H5S9iiWeG9vL3XRE0q3ifn0D4Hifb9MjSNcfacIbAkAeKNgtjMpr52iiWM63Krq0JLuNOmgn04qcGzpmNThlDHLoILoILaA8oEpwwGLZHLKrgwspwsugJgcgma1Yr1ShMZ2JLKrgwsugJgcgma1Yr1ShMZ2JLtHLeLXOHGbdqTCunELbdGLHdlzGMI2Kni7VSEZd0bL6RAcFS0bS0beeycW(QY74vpAOBKIg6MUGifb9MjSNcfacIbAkAeu2GS)Y6rqGn1VjJGOhlPorzmAOXHeaZEyoBpccmbyFv5D8Qhn0nsrksrqZN3o7rpcIUHUn8F40Ey4lDflXssPDSmHdkwflJIflhe1JCPvhewUp8Rm3tHLEb8XsUufWSEkSeqJ7X7n4zZRSpwoy6kwoTeDOV6PWYw0tJp4bzmby5GuEhVoiSufy5GuEhVAk7uhew64CbYbdEgEgDdDB4)WP9WWx6kwILKs7yzchuSkwgflwoOSJdcl3h(vM7PWsVa(yjxQcywpfwcOX949g8S5v2hldp6kwoTeDOV6PWYw0tJp4bzmby5GuEhVoiSufy5GuEhVAk7uhew64CbYbdE28k7JL0D6kwoTeDOV6PWYw0tJp4bzmby5GuEhVoiSufy5GuEhVAk7uhew64CbYbdEgEgDdDB4)WP9WWx6kwILKs7yzchuSkwgflwoiaR8GWY9HFL5EkS0lGpwYLQaM1tHLaACpEVbpBEL9XYWJUILtlrh6REkSSf904dEqgtawoiL3XRdclvbwoiL3XRMYo1bHLooxGCWGNnVY(yjDNUILtlrh6REkSSf904dEqgtawoiL3XRdclvbwoiL3XRMYo1bHLooxGCWGNHNr3q3g(pCApm8LUILyjP0owMWbfRILrXILdk2edcl3h(vM7PWsVa(yjxQcywpfwcOX949g8S5v2hlNoDflNwIo0x9uyzl6PXh8GmMaSCqkVJxhewQcSCqkVJxnLDQdclDCUa5GbpdpBAdhuS6PWYWdlzGMIglTPx9g8meKp4bOHZfE0feuWvet7rqHpWYWNb6Gs9uyjXJI9yjqatWkws8XS9gSKUfaEq1JLTONgA8chlTyjd0u0ESu02jg8mgOPO9MG7bcycwlIw2paEgd0u0EtW9abmbRKu4uuiOWZyGMI2BcUhiGjyLKcN4Yr43kRPOXZyGMI2BcUhiGjyLKcN8LWWIUg8kEgd0u0EtW9abmbRKu404MWICFveREgSzmbN8mwOS9TAg3ewK7RIy1ZGnJj4M3mH9u4zmqtr7nb3deWeSssHt(Md6Pj0Qxz1JNXanfT3eCpqatWkjfofuOPOXZyGMI2BcUhiGjyLKcN8IsBnM7XZyGMI2BcUhiGjyLKcNYgK9xwp5zSGELTVvJxuARXCV5ntypfEgEw4dSm8zGoOupfw(qFNGLAcFSuPDSKbQyXY0JLCioTmH9g8mgOPO9f(G3ARwbya8mgOPO9Ku4enoKaGNXanfTNKcN2YUYanfD1MEL8MHFbGvM8mw4dERTQ8oE1BYo(TzBLNppW7ShNQiWUu2(wnawzGDIh28MjSNcpJbAkApjfoTLDLbAk6Qn9k5nd)IytqEgl8bV1wvEhV6nzh)2STYZNh4D2JtveyxkBFRMyUVYnvLytyVk6BEZe2tHNXanfTNKcN2YUYanfD1MEL8MHFr2rYZyHp4T2QY74vVj743MTvE(8aVZECQIa7sz7B1KD8BlmVzc7PWZyGMI2tsHtjmSWY6jhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ27YX9X9EAmH9KrMY23QjB9BZ2kqatu61u0M3mH9uUyGMI2aOXcFLqyvt21OnhPPU2dZz7NggOPOnaASWxjew1Olh62QMWFAMUZuLlRPOdxyMa7aEgd0u0EskCcWwBLbAk6Qn9k5nd)caLhpJbAkApjforJdjaKdMaSVQ8oE1x4M8mwqVJkVJxl8jSr5D8QdUuEhVA0e(vvuPYpL7WWZyGMI2tsHt04qca5zSGbAg613hoVFk34zmqtr7jPWjanU7BRuhw0XCpEgd0u0EskCcWkdSt8W4zmqtr7jPWjVO0wJ5EYbta2xvEhV6lCtEglON6eLXOHghsam7H5S94zmqtr7jPWjanw4RecRsoycW(QY74vFHBYZyb9uNOmgn04qcGzpmNT31d0bL6RAcFs0LdDBvt47SY74vJMWVQIkvExoQS9TAYw)2STceWeLEnfT5ntypfzKrVY23QjB9BZ2kqatu61u0M3mH9uU8IsB1tJxQPkOdzK5OY23Q5ltLawtrBEZe2t5I6eLXO5ltLawtrB2dZz7DUaWETQj8DGmYikJrdfVdu9IsBnBVYePn1jM9WC2(PaSxRAcFYil4vt2XVnBnmqZq3LY23QzCtyrUVkIvFzW9WmyI5ntypLd4zmqtr7jPWjGOJwECz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7D5OJkBFRMOL90eH(AEZe2t5IOmgnemyaQLJQXRmyaNlMZbYiZr6v2(wnrl7Pjc918MjSNYfrzmAiyWaulhvJxzWaopNdoGNXanfTNKcN80ykX8jk3MCWeG9vL3XR(c3KNXc6PorzmAOXHeaZEyoBVlhDeqJ3X7lMJmYONOmgnemyaQLJQzpmNTNmYikJrdbdgGA5OA2dZz7NIOmgnemyaQLJQXRmyGWXanfTjBq2Fz9MhOdk1x1e(o4aEgd0u0EskCkBq2Fz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7XZWZyGMI2BaSYfa2ARmqtrxTPxjVz4xaO84zmqtr7nawzskCA5SRIynM7jpJfErPT6PXl1uf0XmD8mgOPO9gaRmjfobyLb2jEy8mgOPO9gaRmjfoLWWclRN8mwOS9TAa04UVTsDyrhZ9M3mH9uUOFpmNT3fqiSuI53ganU7BRuhw0XCVzpmNT35cgOPOnaASWxjew18aDqP(QMWhpJbAkAVbWktsHtaAC33wPoSOJ5E8mgOPO9gaRmjforJdjaKdMaSVQ8oE1x4M8mwqVJkVJxl8jSr5D8QdUuEhVA0e(vvuPYpL7WC5dERTQ8oE1Bwo7QiwJ5ENlgSlLTVvZ4MWICFveR(YG7HzWeZBMWEkxbVAYo(TzRHbAg6UcE1KD8BZwZEyoBVZfUddpJbAkAVbWktsHt04qca5zSWh8wBv5D8Q3SC2vrSgZ9oxmyxkBFRMXnHf5(Qiw9Lb3dZGjM3mH9uUcE1KD8BZwdd0m0Df8Qj743MTM9WC2ENlChgEgd0u0EdGvMKcNa0yHVsiSk5Gja7RkVJx9fUjpJf0tDIYy0qJdjaM9WC2ExkBFRMXnHf5(Qiw9Lb3dZGjM3mH9uUcE1KD8BZwZEyoB)upqhuQVQj8DXand967dN37CXGD5OJUdBWHZh8wBv5D8Q3SC2vrSgZ9ZtGDWzhNJoHfohDtsyMWgC4ikJrZ4MWICFveR(YG7HzWeJxzWaompZfohDtcrzmAyGMHELghsam7H5S9t9aDqP(QMW3bhCapJbAkAVbWktsHt04qca5Gja7RkVJx9fUjpJf07OY741cFcBuEhV6GlL3XRgnHFvfvQ8t5omx(G3ARkVJx9MLZUkI1yU35c6GNXanfT3ayLjPWjACibG8mw4dERTQ8oE1Bwo7QiwJ5ENlOdEgd0u0EdGvMKcNa0yHVsiSk5Gja7RkVJx9fUjpJf0tDIYy0qJdjaM9WC2ExeLXOHbAg6vACibWShMZ2p1d0bL6RAcFx(G3ARkVJx9MLZUkI1yU35c6GNXanfT3ayLjPWPegwyz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7DTpU3tJjS31EyoBVZfaHWsjMFBaSYa7epSzpmNThpJbAkAVbWktsHtlNDveRXCpEgd0u0EdGvMKcN8IsBnM7jhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ2JNXanfT3ayLjPWjGOJwECz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7XZyGMI2BaSYKu4KNgtjMpr52KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7D5OJaA8oEFXCKrg9eLXOHGbdqTCun7H5S9KrgrzmAiyWaulhvZEyoB)ueLXOHGbdqTCunELbdeogOPOnzdY(lR38aDqP(QMW3bhWZyGMI2BaSYKu4u2GS)Y6jhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ2JNHNXanfT3aO8f(syyrxZo(Tzl5zSq5D8Qrt4xvrLk)ufZ5omYiJEGqyPeZVnu8oq1lkT1S9ktK2uNy2dZz7jJmL3XRgnHFvfvQ8oxe4Wizeqrgz0RS9TAO4DGQxuARz7vMiTPoX8MjSNcpJbAkAVbq5jPWjkEhO6fL2A2ELjsBQtipJfkVJxnAc)QkQu5NQWnDcJmYcE1KD8BZwdd0m0jJmL3XRgnHFvfvQ8oxmxyKmcOWZyGMI2BauEskCkOqtrtEglcE1KD8BZwdd0m0jJmL3XRgnHFvfvQ8ohEthpJbAkAVbq5jPWjIV(VdK9iEgd0u0EdGYtsHtewHGQgl3j4zmqtr7nakpjfofZ9ewHGcpJbAkAVbq5jPWPs)RPEypEgEgd0u0EtSjkaS1wzGMIUAtVsEZWVaq5XZyGMI2BInbjfoTC2vrSgZ9KNXcVO0w904LAQc6yMoEgd0u0EtSjiPWPegwyz9KNXcLTVvdGg39TvQdl6yU38MjSNYf97H5S9UacHLsm)2aOXDFBL6WIoM7n7H5S9oxWanfTbqJf(kHWQMhOdk1x1e(4zmqtr7nXMGKcNa04UVTsDyrhZ94zmqtr7nXMGKcNOXHeaYbta2xvEhV6lCtEglO3rL3XRf(e2O8oE1bxkVJxnAc)QkQu5NYDyU8bV1wvEhV6nlNDveRXCVZf0XLY23QzCtyrUVkIvFzW9WmyI5ntypLRGxnzh)2S1WandDxbVAYo(TzRzpmNT35c3HHNXanfT3eBcskCIghsaipJf(G3ARkVJx9MLZUkI1yU35c64sz7B1mUjSi3xfXQVm4EygmX8MjSNYvWRMSJFB2AyGMHURGxnzh)2S1ShMZ27CH7WWZyGMI2BInbjfobOXcFLqyvYbta2xvEhV6lCtEglON6eLXOHghsam7H5S9Uu2(wnJBclY9vrS6ldUhMbtmVzc7PCf8Qj743MTM9WC2(PEGoOuFvt47IbAg613hoV35c64YrhDh2GdNp4T2QY74vVz5SRIynM7NNa7GZoohDclCo6MKWmHn4WrugJMXnHf5(Qiw9Lb3dZGjgVYGbCyEMlCo6MeIYy0Wand9knoKay2dZz7N6b6Gs9vnHVdo4aEgd0u0EtSjiPWPegwyz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7DTpU3tJjS3Lp4T2QY74vVjBq2Fz9oxmy8mgOPO9MytqsHtlNDveRXCpEgd0u0EtSjiPWjVO0wJ5EYbta2xvEhV6lCtEglON6eLXOHghsam7H5S9U8bV1wvEhV6nzdY(lRViW4zmqtr7nXMGKcNaIoA5XL1toycW(QY74vFHBYZyb9uNOmgn04qcGzpmNT3LJkBFRMOL90eH(AEZe2t5IOmgnemyaQLJQXRmyaNlMJmY8bV1wvEhV6nzdY(lR35c6czKPS9TAwbVzpwjS88MBEZe2t5Yh8wBv5D8Q3Kni7VSENlO7oGNXanfT3eBcskCkBq2Fz9KdMaSVQ8oE1x4M8mwqp1jkJrdnoKay2dZz7XZWZyGMI2BYowayRTYanfD1MEL8MHFbGYJNXanfT3KDKKcNwo7QiwJ5EYZyHxuAREA8snvbDmthpJbAkAVj7ijfobyLb2jEy8mgOPO9MSJKu4ucdlSSEYZyHY23QbqJ7(2k1HfDm3BEZe2t5I(9WC2ExaHWsjMFBa04UVTsDyrhZ9M9WC2ENlyGMI2aOXcFLqyvZd0bL6RAcF8mgOPO9MSJKu4eGg39TvQdl6yUhpJbAkAVj7ijforJdjaKdMaSVQ8oE1x4M8mwqVJkVJxl8jSr5D8QdUuEhVA0e(vvuPYpL7WC5dERTQ8oE1Bwo7QiwJ5ENlOdjkBFRMS1VnBRabmrPxtrBEZe2t5sz7B1mUjSi3xfXQVm4EygmX8MjSNYvWRMSJFB2AyGMHURGxnzh)2S1ShMZ27CH7WWZyGMI2BYossHt04qca5zSWh8wBv5D8Q3SC2vrSgZ9oxqhsu2(wnzRFB2wbcyIsVMI28MjSNYLY23QzCtyrUVkIvFzW9WmyI5ntypLRGxnzh)2S1WandDxbVAYo(TzRzpmNT35c3HHNXanfT3KDKKcNa0yHVsiSk5Gja7RkVJx9fUjpJf0tDIYy0qJdjaM9WC2ExkBFRMXnHf5(Qiw9Lb3dZGjM3mH9uUcE1KD8BZwZEyoB)upqhuQVQj8D5dERTQ8oE1Bwo7QiwJ5ENlOdjkBFRMS1VnBRabmrPxtrBEZe2t5YrhDh2GdNp4T2QY74vVz5SRIynM7Nhhd80eMXD4foFWBTvL3XREZYzxfXAm37Gdo74C0jSW5OBscZe2GdhrzmAg3ewK7RIy1xgCpmdMy8kdgWH5zUW5OBsikJrdd0m0R04qcGzpmNTFQhOdk1x1e(o4Gd4zmqtr7nzhjPWjACibGCWeG9vL3XR(c3KNXc6Du5D8AHpHnkVJxDWLY74vJMWVQIkv(PChMlFWBTvL3XREZYzxfXAm37CrGD5OY23Q5ltLawtrBEZe2trgzkBFRMS1VnBRabmrPxtrBEZe2t5aEgd0u0Et2rskCIghsaipJf(G3ARkVJx9MLZUkI1yU35Ia7YrLTVvZxMkbSMI28MjSNImYu2(wnzRFB2wbcyIsVMI28MjSNYb8mgOPO9MSJKu4eGgl8vcHvjhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ27IOmgnmqZqVsJdjaM9WC2(PEGoOuFvt47Yh8wBv5D8Q3SC2vrSgZ9oxeyxoQS9TA(YujG1u0M3mH9uKrMY23QjB9BZ2kqatu61u0M3mH9uoGNXanfT3KDKKcNsyyHL1toycW(QY74vFHBYZyb9uNOmgn04qcGzpmNT31(4EpnMWE8mgOPO9MSJKu40YzxfXAm3JNXanfT3KDKKcN8IsBnM7jhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ2JNXanfT3KDKKcNaIoA5XL1toycW(QY74vFHBYZyb9uNOmgn04qcGzpmNThpJbAkAVj7ijfo5PXuI5tuUn5Gja7RkVJx9fUjpJf0tDIYy0qJdjaM9WC2Exo6iGgVJ3xmhzKrprzmAiyWaulhvZEyoBpzKrugJgcgma1Yr1ShMZ2pfrzmAiyWaulhvJxzWaHJbAkAt2GS)Y6npqhuQVQj8DWb8mgOPO9MSJKu4u2GS)Y6jhmbyFv5D8QVWn5zSGEQtugJgACibWShMZ2JuKIq]] )

end
