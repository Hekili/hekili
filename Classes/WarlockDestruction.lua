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
            id = 117828,
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
        cycle = true,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Destruction",
    } )


    spec:RegisterPack( "Destruction", 20180930.1059, [[dquTjbqiQu9iOs4sqLKnrLmkjPoLcyvsI6vqfZcQYTKKKDrQFPOAyurogvyzkuEgvkMMcvxdQuTnjj13GkPgNKeNJkLY6GkrMhc19eQ9PaDqQuQQfsf1dPsjYeHkrDrQuI6KuPuLvQOmtQus1ovqdLkLklLkLWtvLPIq(kvkj7fYFLyWu1HrTyv1JvAYi6YGnl4ZkYOrWPf9AjHzt0THYUL63inCHy5Q8CsMoLRlP2Uq67qLY4Le58kK1tLskZhQQ9tyKderOhjBaA4yo5Oko52CJt6XCJtUb3X1ONnkcGEr4TcEcqVMXa0dxgu2vVwsB0lcpsszserONIwFlGEemlIcxA(8P0iu)1lfBUkXQLSL0EpoyZvj2o)lP)5)axvKq05roAiLGAorjCJ5yorJ5O4wXNKUvuWLbLD1RL0wRsSf9(1P0C71Op6rYgGgoMtoQItUn34KEm34KBgd3rpU2iqp07LyULqpsqTOhUq4XLbLD1RL0w4DR4ts3keZWfcpbZIOWLMpFknc1F9sXMRsSAjBjT3Jd2CvITZ)s6F(pWvfjeDEKJgsjOM72DGBbNKQ5UDUff3k(K0TIcUmOSRETK2AvITIz4cH)brma7dNW7gNWt4hZjhvr4RkHFSXWLgVkIzIz4cH3TebUNafUKygUq4RkH)fbKsH3ToDRqlMHle(Qs4DlamAuq4vjM24BcmHFjaBfA0tMktHic9iHaxlnerOHoqeHE8AjTrpveqkls6wb6bn)LajYzKHgogIi0dA(lbsKZO3EPbxYONkciLfJVjWu6SdW1SSW4gxb0zpj8dgl8Ur4Dj8glH20lB8khPW0qZFjqIE8AjTrVRUl8AjTlYuzONmvwPzma9w2yKHg6gerOh08xcKiNrV9sdUKrpveqklgFtGP0zhGRzzHXnUcOZEs4hmw4DJW7s4nwcTPd5bfUjl)lXugTbn08xcKOhVwsB07Q7cVws7Imvg6jtLvAgdqVq)rgA44iIqpO5VeiroJE7LgCjJEQiGuwm(MatPZoaxZYcJBCfqN9KWpySW7gH3LWBSeAtNDaUMQHM)sGe941sAJExDx41sAxKPYqpzQSsZya6LDazOH4oIi0JxlPn6TSXRCKcd9GM)sGe5mYqdRAerOh08xcKiNrpETK2OxIHrLSbO3EPbxYON7cpj8RdbnbokD1hGXzReExcF1c)bHdue4VeeE8Xx4nwcTPZ2GRzzzPy)ALL0wdn)LaPW7s451sARxcmvv(uPPZUeK5ebt4Dj8hGXzRe(Qs451sARxcmvv(uPPTJJcYILyGWxvcpUl8el8K1hBjTf(kl8oPDJWpa6TJwjum(MatHg6azOH4AerOh08xcKiNrpETK2O3YszHxlPDrMkd9KPYknJbO3sQqgAyvqeHE8AjTrVLa3nilKagTd5bOh08xcKiNrgAOBdre6bn)LajYz0JxlPn6rGJsx0BV0Glz0Z4BcmTLyqXOfYee(bfEhoHE7OvcfJVjWuOHoqgAOdNqeHEqZFjqICg92ln4sg941YOqbAalbLWpOW7a941sAJEe4O0fzOHoCGic9GM)sGe5m6XRL0g9u0AzjKhGE7LgCjJEUl8KWVoe0e4O0vFagNTc92rRekgFtGPqdDGm0qhJHic9GM)sGe5m6XRL0g9wcmvv(uPHE7LgCjJEUl8KWVoe0e4O0vFagNTs4Dj8qLGT2GILyGWJJWBhhfKflXaHNyH34BcmTLyqXOfYeeExcF1cVXsOnD2gCnlllf7xRSK2AO5VeifE8Xx4Dx4nwcTPZ2GRzzzPy)ALL0wdn)LaPW7s4v0AzrrGpsHFWyHFCHhF8f(QfEJLqBA4yYCzlPTgA(lbsH3LWtc)6qqdhtMlBjT1hGXzReEIJf(LvwXsmq4hq4XhFH)xhcAs(QOOO1Ys2kJ)PmTr6dW4Svc)Gc)YkRyjgi84JVWhbmD2b4AwQ51YOGW7s4nwcTPNUeJMhuOHIQoYby8osdn)LaPWpa6TJwjum(MatHg6azOHoCdIi0dA(lbsKZOhVwsB0BPDqYthBa6TxAWLm65UWtc)6qqtGJsx9byC2kH3LWxTWxTWBSeAthKSIankCAO5VeifExc)Voe0FERG84GPvgVvi8ehl8Jj8di84JVWxTW7UWBSeAthKSIankCAO5VeifExc)Voe0FERG84GPvgVvi8el8Jj8di8dGE7OvcfJVjWuOHoqgAOJXreHEqZFjqICg941sAJEkcmjf3(1xJE7LgCjJEUl8KWVoe0e4O0vFagNTs4Dj8vl8vl8lb(MaLWhl8Jj84JVW7UW)Rdb9N3kipoy6dW4Svcp(4l8)6qq)5TcYJdM(amoBLWpOW)Rdb9N3kipoyALXBfcFLfEETK26S3SHJnqdvc2AdkwIbc)ac)aO3oALqX4BcmfAOdKHg6a3reHEqZFjqICg941sAJEzVzdhBa6TxAWLm65UWtc)6qqtGJsx9byC2k0BhTsOy8nbMcn0bYqg6f5GLI9zdreAOderOh08xcKiNrgA4yiIqpO5VeiroJm0q3Gic9GM)sGe5mYqdhhre6XRL0g9u1yy0UeajH62Gd9GM)sGe5mYqdXDerOh08xcKiNrV9sdUKrpJLqB6PlXO5bfAOO49YqUGgA(lbs0JxlPn6nDjgnpOqdffVxgYfqgAyvJic9GM)sGe5mYqdX1iIqpETK2OxeQL0g9GM)sGe5mYqdRcIi0JxlPn6PO1Ysipa9GM)sGe5mYqdDBiIqpO5VeiroJE7LgCjJEUl8glH20kATSeYd0qZFjqIE8AjTrVS3SHJnazid9YoGicn0bIi0dA(lbsKZOhVwsB0BzPSWRL0UitLHEYuzLMXa0BjvidnCmerOh08xcKiNrV9sdUKrpfTwwue4Ju4hmw4hxJ7OhVwsB074Sl0qjKhGm0q3Gic941sAJElB8khPWqpO5VeiroJm0WXreHEqZFjqICg92ln4sg9mwcTPxcC3GSqcy0oKhOHM)sGu4Dj8Ul8hGXzReExc)sPsskU16La3nilKagTd5b6dW4SvcpXXcpVwsB9sGPQYNknnujyRnOyjgGE8AjTrVedJkzdqgAiUJic941sAJElbUBqwibmAhYdqpO5VeiroJm0WQgre6bn)LajYz0JxlPn6rGJsx0BV0Glz0Z4BcmTLyqXOfYee(bfEhoj8UeEveqklgFtGP0hNDHgkH8aHN4yHFCHhhH3yj0MoBdUMLLLI9RvwsBn08xcKcVlH3yj0ME6smAEqHgkQ6ihGX7in08xcKcVlHpcy6SdW1SuZRLrbH3LWhbmD2b4AwQpaJZwj8ehl8oCc92rRekgFtGPqdDGm0qCnIi0dA(lbsKZO3EPbxYONkciLfJVjWu6JZUqdLqEGWtCSWpUWJJWBSeAtNTbxZYYsX(1klPTgA(lbsH3LWBSeAtpDjgnpOqdfvDKdW4DKgA(lbsH3LWhbmD2b4AwQ51YOGW7s4JaMo7aCnl1hGXzReEIJfEhoHE8AjTrpcCu6Im0WQGic9GM)sGe5m6XRL0g9wcmvv(uPHE7LgCjJEUl8KWVoe0e4O0vFagNTs4Dj8glH20txIrZdk0qrvh5amEhPHM)sGu4Dj8ratNDaUML6dW4Svc)GcpujyRnOyjgi8UeEveqklgFtGP0hNDHgkH8aHN4yHFCHhhH3yj0MoBdUMLLLI9RvwsBn08xcKcVlHVAHVAH3Htvr4RSWRIaszX4BcmL(4Sl0qjKhi84kHVAH3ncFvj8oPDu1cFLfEveqklgFtGP0hNDHgkH8aHFaHFaHNyHVAHFSXDs4RSWxTW7q4Xr4Ds7uve(kl8)6qqpDjgnpOqdfvDKdW4DKwz8wHWpGWJRe(Xe(kl8vl8oeECe(FDiO51YOqHahLU6dW4Svc)GcpujyRnOyjgi8di8di8dGE7OvcfJVjWuOHoqgAOBdre6bn)LajYz0JxlPn6rGJsx0BV0Glz0Z4BcmTLyqXOfYee(bfEhoj8UeEveqklgFtGP0hNDHgkH8aHN4yH3ncVlHVAH3yj0MgoMmx2sARHM)sGu4XhFH3yj0MoBdUMLLLI9RvwsBn08xcKc)aO3oALqX4BcmfAOdKHg6WjerOh08xcKiNrV9sdUKrpveqklgFtGP0hNDHgkH8aHN4yH3ncVlHVAH3yj0MgoMmx2sARHM)sGu4XhFH3yj0MoBdUMLLLI9RvwsBn08xcKc)aOhVwsB0JahLUidn0HderOh08xcKiNrpETK2O3sGPQYNkn0BV0Glz0ZDHNe(1HGMahLU6dW4SvcVlH)xhcAETmkuiWrPR(amoBLWpOWdvc2AdkwIbcVlHxfbKYIX3eyk9XzxOHsipq4jow4DJW7s4Rw4nwcTPHJjZLTK2AO5VeifE8Xx4nwcTPZ2GRzzzPy)ALL0wdn)LaPWpa6TJwjum(MatHg6azOHogdre6bn)LajYz0JxlPn6LyyujBa6TxAWLm65UWtc)6qqtGJsx9byC2kH3LWFq4afb(lb0BhTsOy8nbMcn0bYqdD4gerOhVwsB074Sl0qjKhGEqZFjqICgzOHoghre6bn)LajYz0JxlPn6PO1Ysipa92ln4sg9Cx4jHFDiOjWrPR(amoBf6TJwjum(MatHg6azOHoWDerOh08xcKiNrpETK2O3s7GKNo2a0BV0Glz0ZDHNe(1HGMahLU6dW4SvO3oALqX4BcmfAOdKHg6OQreHEqZFjqICg941sAJEkcmjf3(1xJE7LgCjJEUl8KWVoe0e4O0vFagNTs4Dj8vl8vl8lb(MaLWhl8Jj84JVW7UW)Rdb9N3kipoy6dW4Svcp(4l8)6qq)5TcYJdM(amoBLWpOW)Rdb9N3kipoyALXBfcFLfEETK26S3SHJnqdvc2AdkwIbc)ac)aO3oALqX4BcmfAOdKHg6axJic9GM)sGe5m6XRL0g9YEZgo2a0BV0Glz0ZDHNe(1HGMahLU6dW4SvO3oALqX4BcmfAOdKHm0BzJreHg6are6bn)LajYz0JxlPn6TSuw41sAxKPYqpzQSsZya6TKkKHgogIi0dA(lbsKZO3EPbxYONIwllkc8rk8dgl8JRXD0JxlPn6DC2fAOeYdqgAOBqeHE8AjTrVLnELJuyOh08xcKiNrgA44iIqpO5VeiroJE7LgCjJEglH20lbUBqwibmAhYd0qZFjqk8UeE3f(dW4SvcVlHFPujjf3A9sG7gKfsaJ2H8a9byC2kHN4yHNxlPTEjWuv5tLMgQeS1guSedqpETK2OxIHrLSbidne3reHE8AjTrVLa3nilKagTd5bOh08xcKiNrgAyvJic9GM)sGe5m6XRL0g9iWrPl6TxAWLm6z8nbM2smOy0czcc)GcVdNeExcVkciLfJVjWu6JZUqdLqEGWtCSWxfH3LWBSeAtpDjgnpOqdfvDKdW4DKgA(lbsH3LWhbmD2b4AwQ51YOGW7s4JaMo7aCnl1hGXzReEIJfEhoHE7OvcfJVjWuOHoqgAiUgre6bn)LajYz0BV0Glz0tfbKYIX3eyk9XzxOHsipq4jow4RIW7s4nwcTPNUeJMhuOHIQoYby8osdn)LaPW7s4JaMo7aCnl18Azuq4Dj8ratNDaUML6dW4SvcpXXcVdNqpETK2OhbokDrgAyvqeHEqZFjqICg941sAJElbMQkFQ0qV9sdUKrp3fEs4xhcAcCu6QpaJZwj8UeEJLqB6PlXO5bfAOOQJCagVJ0qZFjqk8Ue(iGPZoaxZs9byC2kHFqHhQeS1guSedeExcpVwgfkqdyjOeEIJf(Qi8Ue(Qf(QfEhovfHVYcVkciLfJVjWu6JZUqdLqEGWJReE3i8di8el8vl8JnUtcFLf(QfEhcpocVtANQIWxzH)xhc6PlXO5bfAOOQJCagVJ0kJ3ke(beECLWpMWxzHVAH3HWJJW)RdbnVwgfke4O0vFagNTs4hu4HkbBTbflXaHFaHFaHFa0BhTsOy8nbMcn0bYqdDBiIqpO5VeiroJE8AjTrpcCu6IE7LgCjJEgFtGPTedkgTqMGWpOW7WjH3LWRIaszX4BcmL(4Sl0qjKhi8ehl8JJE7OvcfJVjWuOHoqgAOdNqeHEqZFjqICg92ln4sg9uraPSy8nbMsFC2fAOeYdeEIJf(XrpETK2OhbokDrgAOdhiIqpO5VeiroJE8AjTrVLatvLpvAO3EPbxYON7cpj8RdbnbokD1hGXzReExc)Voe08AzuOqGJsx9byC2kHFqHhQeS1guSedeExcVkciLfJVjWu6JZUqdLqEGWtCSWpo6TJwjum(MatHg6azOHogdre6bn)LajYz0JxlPn6LyyujBa6TxAWLm65UWtc)6qqtGJsx9byC2kH3LWFq4afb(lbH3LWFagNTs4jow4xkvssXTwVSXRCKctFagNTc92rRekgFtGPqdDGm0qhUbre6XRL0g9oo7cnuc5bOh08xcKiNrgAOJXreHEqZFjqICg941sAJEkATSeYdqV9sdUKrp3fEs4xhcAcCu6QpaJZwHE7OvcfJVjWuOHoqgAOdChre6bn)LajYz0JxlPn6T0oi5PJna92ln4sg9Cx4jHFDiOjWrPR(amoBf6TJwjum(MatHg6azOHoQAerOh08xcKiNrpETK2ONIatsXTF91O3EPbxYON7cpj8RdbnbokD1hGXzReExcF1cF1c)sGVjqj8Xc)ycp(4l8Ul8)6qq)5TcYJdM(amoBLWJp(c)Voe0FERG84GPpaJZwj8dk8)6qq)5TcYJdMwz8wHWxzHNxlPTo7nB4yd0qLGT2GILyGWpGWpa6TJwjum(MatHg6azOHoW1iIqpO5VeiroJE8AjTrVS3SHJna92ln4sg9Cx4jHFDiOjWrPR(amoBf6TJwjum(MatHg6azid9c9hreAOderOh08xcKiNrpETK2O3YszHxlPDrMkd9KPYknJbO3sQqgA4yiIqpO5VeiroJE7LgCjJEkATSOiWhPWpySWpUg3rpETK2O3XzxOHsipazOHUbre6bn)LajYz0BV0Glz0Zyj0MEjWDdYcjGr7qEGgA(lbsH3LW7UWFagNTs4Dj8lLkjP4wRxcC3GSqcy0oKhOpaJZwj8ehl88AjT1lbMQkFQ00qLGT2GILya6XRL0g9smmQKnazOHJJic941sAJElbUBqwibmAhYdqpO5VeiroJm0qChre6bn)LajYz0JxlPn6rGJsx0BV0Glz0Z4BcmTLyqXOfYee(bfEhoj8UeEveqklgFtGP0hNDHgkH8aHN4yHFCH3LWBSeAtpDjgnpOqdfvDKdW4DKgA(lbsH3LWhbmD2b4AwQ51YOGW7s4JaMo7aCnl1hGXzReEIJfEhoHE7OvcfJVjWuOHoqgAyvJic9GM)sGe5m6TxAWLm6PIaszX4BcmL(4Sl0qjKhi8ehl8Jl8UeEJLqB6PlXO5bfAOOQJCagVJ0qZFjqk8Ue(iGPZoaxZsnVwgfeExcFeW0zhGRzP(amoBLWtCSW7Wj0JxlPn6rGJsxKHgIRreHEqZFjqICg941sAJElbMQkFQ0qV9sdUKrp3fEs4xhcAcCu6QpaJZwj8UeEJLqB6PlXO5bfAOOQJCagVJ0qZFjqk8Ue(iGPZoaxZs9byC2kHFqHhQeS1guSedeExcpVwgfkqdyjOeEIJf(XfExcF1cF1cVdNQIWxzHxfbKYIX3eyk9XzxOHsipq4XvcVBe(beEIf(Qf(Xg3jHVYcF1cVdHhhH3jTtvr4RSW)Rdb90Ly08Gcnuu1roaJ3rALXBfc)acpUs4ht4RSWxTW7q4Xr4)1HGMxlJcfcCu6QpaJZwj8dk8qLGT2GILyGWpGWpGWpa6TJwjum(MatHg6azOHvbre6bn)LajYz0JxlPn6rGJsx0BV0Glz0Z4BcmTLyqXOfYee(bfEhoj8UeEveqklgFtGP0hNDHgkH8aHN4yHFC0BhTsOy8nbMcn0bYqdDBiIqpO5VeiroJE7LgCjJEQiGuwm(MatPpo7cnuc5bcpXXc)4OhVwsB0JahLUidn0HtiIqpO5VeiroJE8AjTrVLatvLpvAO3EPbxYON7cpj8RdbnbokD1hGXzReExc)Voe08AzuOqGJsx9byC2kHFqHhQeS1guSedeExcVkciLfJVjWu6JZUqdLqEGWtCSWpo6TJwjum(MatHg6azOHoCGic9GM)sGe5m6XRL0g9smmQKna92ln4sg9Cx4jHFDiOjWrPR(amoBLW7s4piCGIa)LGW7s4vraPSy8nbMsN9MnCSbcpXXcFvqVD0kHIX3eyk0qhidn0XyiIqpETK2O3XzxOHsipa9GM)sGe5mYqdD4gerOh08xcKiNrpETK2ONIwllH8a0BV0Glz0ZDHNe(1HGMahLU6dW4SvcVlHxfbKYIX3eykD2B2WXgi8XcVBqVD0kHIX3eyk0qhidn0X4iIqpO5VeiroJE8AjTrVL2bjpDSbO3EPbxYON7cpj8RdbnbokD1hGXzReExcF1cVXsOnDqYkc0OWPHM)sGu4Dj8)6qq)5TcYJdMwz8wHWtCSWpMWJp(cVkciLfJVjWu6S3SHJnq4jow4X1cp(4l8glH20hLVSNkFj7wd0qZFjqk8UeEveqklgFtGP0zVzdhBGWtCSW72e(bqVD0kHIX3eyk0qhidn0bUJic9GM)sGe5m6XRL0g9YEZgo2a0BV0Glz0ZDHNe(1HGMahLU6dW4SvO3oALqX4BcmfAOdKHm0BjviIqdDGic9GM)sGe5m6TxAWLm6z8nbM2smOy0czcc)GXc)yoCs4XhFH3DHFPujjf3AnjFvuu0AzjBLX)uM2i9byC2kHhF8fEJVjW0wIbfJwitq4jow4DJtcpoc)0sk84JVW7UWBSeAttYxfffTwwYwz8pLPnsdn)Laj6XRL0g9u1yy0UKDaUMLidnCmerOh08xcKiNrV9sdUKrpJVjW0wIbfJwitq4hmw4DmUtcp(4l8ratNDaUMLAETmki84JVWB8nbM2smOy0czccpXXc)yoj84i8tlj6XRL0g9i5RIIIwllzRm(NY0gHm0q3Gic9GM)sGe5m6TxAWLm6fbmD2b4AwQ51YOGWJp(cVX3eyAlXGIrlKji8el8vnUJE8AjTrViulPnYqdhhre6XRL0g9(WPGRISNqpO5VeiroJm0qChre6XRL0g9(skLSeQVrOh08xcKiNrgAyvJic941sAJEH8GVKsjrpO5VeiroJm0qCnIi0JxlPn6vRGsAaMc9GM)sGe5mYqgYqVOWPsAJgoMtoQItvXHB0oQAhoqpCJVo7jf652dlc9mGu4RAHNxlPTWltLP0IzOxKJgsjGE4cHhxgu2vVwsBH3TIpjDRqmdxi8emlIcxA(8P0iu)1lfBUkXQLSL0EpoyZvj2o)lP)5)axvKq05roAiLGAUB3bUfCsQM725wuCR4ts3kk4YGYU61sARvj2kMHle(heXaSpCcVBCcpHFmNCufHVQe(XgdxA8QiMjMHleE3se4Ecu4sIz4cHVQe(xeqkfE360TcTygUq4RkH3TaWOrbHxLyAJVjWe(LaSvOfZeZWfcVB5kbBTbKc)hc0de(LI9zt4)Wu2kTW72FxiIPe(M2vfb(Wc1sHNxlPTs4PTCKwmJxlPTsh5GLI9zloizvfIz8AjTv6ihSuSpB4eppqPKIz8AjTv6ihSuSpB4epNRNWG2ylPTygVwsBLoYblf7ZgoXZv1yy0UebmXmETK2kDKdwk2NnCINpDjgnpOqdffVxgYfWldXglH20txIrZdk0qrX7LHCbn08xcKIz8AjTv6ihSuSpB4epx1CefbQvugBkXmETK2kDKdwk2NnCINhHAjTfZ41sAR0royPyF2WjEUIwllH8aXmETK2kDKdwk2NnCINN9MnCSb4LHy3nwcTPv0AzjKhOHM)sGumtmdxi8ULReS1gqk8qu4gj8wIbcVraeEEn6j8Ps45OCk5Ve0Iz8AjTvXQiGuwK0TcXmETK2kCINF1DHxlPDrMkdVMXG4LngVmeRIaszX4BcmLo7aCnllmUXvaD2tdg7gxglH20lB8khPW0qZFjqkMXRL0wHt88RUl8AjTlYuz41mgeh6pEziwfbKYIX3eykD2b4AwwyCJRa6SNgm2nUmwcTPd5bfUjl)lXugTbn08xcKIz8AjTv4ep)Q7cVws7ImvgEnJbXzhWldXQiGuwm(MatPZoaxZYcJBCfqN90GXUXLXsOnD2b4AQgA(lbsXmETK2kCINVSXRCKctmJxlPTcN45jggvYgG3oALqX4BcmvSd8YqS7KWVoe0e4O0vFagNTYv1heoqrG)saF8nwcTPZ2GRzzzPy)ALL0wdn)LaPlETK26LatvLpvA6SlbzorWCDagNTQQ41sARxcmvv(uPPTJJcYILyqvH7etwFSL0UYoPDZaIz8AjTv4epFzPSWRL0UitLHxZyq8sQeZ41sARWjE(sG7gKfsaJ2H8aXmETK2kCINtGJsx82rRekgFtGPIDGxgIn(MatBjgumAHmHbD4KygVwsBfoXZjWrPlEziMxlJcfObSeud6qmJxlPTcN45kATSeYdWBhTsOy8nbMk2bEzi2Ds4xhcAcCu6QpaJZwjMXRL0wHt88LatvLpvA4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRCbvc2AdkwIb4yhhfKflXaIn(MatBjgumAHmbxvBSeAtNTbxZYYsX(1klPTgA(lbs8X3DJLqB6Sn4Awwwk2VwzjT1qZFjq6srRLffb(ihmEC8XVAJLqBA4yYCzlPTgA(lbsxKWVoe0WXK5YwsB9byC2kIJxwzflXGbWh)FDiOj5RIIIwllzRm(NY0gPpaJZwn4YkRyjgGp(ratNDaUMLAETmk4Yyj0ME6smAEqHgkQ6ihGX7in08xcKdiMXRL0wHt88L2bjpDSb4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRCvD1glH20bjRiqJcNgA(lbsx)6qq)5TcYJdMwz8wbXXJna(4xT7glH20bjRiqJcNgA(lbsx)6qq)5TcYJdMwz8wbXJnWaIz8AjTv4epxrGjP42V(A82rRekgFtGPIDGxgIDNe(1HGMahLU6dW4SvUQU6LaFtGkEm8X39FDiO)8wb5XbtFagNTcF8)1HG(ZBfKhhm9byC2Qb)1HG(ZBfKhhmTY4TIkZRL0wN9MnCSbAOsWwBqXsmyGbeZ41sARWjEE2B2WXgG3oALqX4BcmvSd8YqS7KWVoe0e4O0vFagNTsmtmJxlPTsVSXXllLfETK2fzQm8AgdIxsLygVwsBLEzJXjE(XzxOHsipaVmeRO1YIIaFKdgpUg3fZ41sAR0lBmoXZx24vosHjMXRL0wPx2yCINNyyujBaEzi2yj0MEjWDdYcjGr7qEGgA(lbsxUFagNTY1sPsskU16La3nilKagTd5b6dW4SvehZRL0wVeyQQ8Pstdvc2AdkwIbIz8AjTv6LngN45lbUBqwibmAhYdeZ41sAR0lBmoXZjWrPlE7OvcfJVjWuXoWldXgFtGPTedkgTqMWGoCYLkciLfJVjWu6JZUqdLqEaXXvXLXsOn90Ly08Gcnuu1roaJ3rAO5VeiDfbmD2b4AwQ51YOGRiGPZoaxZs9byC2kIJD4KygVwsBLEzJXjEobokDXldXQiGuwm(MatPpo7cnuc5behxfxglH20txIrZdk0qrvh5amEhPHM)sG0veW0zhGRzPMxlJcUIaMo7aCnl1hGXzRio2HtIz8AjTv6LngN45lbMQkFQ0WBhTsOy8nbMk2bEzi2Ds4xhcAcCu6QpaJZw5Yyj0ME6smAEqHgkQ6ihGX7in08xcKUIaMo7aCnl1hGXzRgeQeS1guSedCXRLrHc0awckIJRIRQR2HtvPYQiGuwm(MatPpo7cnuc5b4k3maXvp24ov5QDGJtANQsL)1HGE6smAEqHgkQ6ihGX7iTY4TIbWvJv5QDGZVoe08AzuOqGJsx9byC2QbHkbBTbflXGbgyaXmETK2k9YgJt8CcCu6I3oALqX4BcmvSd8YqSX3eyAlXGIrlKjmOdNCPIaszX4BcmL(4Sl0qjKhqC84Iz8AjTv6LngN45e4O0fVmeRIaszX4BcmL(4Sl0qjKhqC84Iz8AjTv6LngN45lbMQkFQ0WBhTsOy8nbMk2bEzi2Ds4xhcAcCu6QpaJZw56xhcAETmkuiWrPR(amoB1GqLGT2GILyGlveqklgFtGP0hNDHgkH8aIJhxmJxlPTsVSX4eppXWOs2a82rRekgFtGPIDGxgIDNe(1HGMahLU6dW4SvUoiCGIa)LGRdW4SvehVuQKKIBTEzJx5ifM(amoBLygVwsBLEzJXjE(XzxOHsipqmJxlPTsVSX4epxrRLLqEaE7OvcfJVjWuXoWldXUtc)6qqtGJsx9byC2kXmETK2k9YgJt88L2bjpDSb4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzReZ41sAR0lBmoXZveyskU9RVgVD0kHIX3eyQyh4LHy3jHFDiOjWrPR(amoBLRQREjW3eOIhdF8D)xhc6pVvqECW0hGXzRWh)FDiO)8wb5XbtFagNTAWFDiO)8wb5XbtRmEROY8AjT1zVzdhBGgQeS1guSedgyaXmETK2k9YgJt88S3SHJnaVD0kHIX3eyQyh4LHy3jHFDiOjWrPR(amoBLyMygVwsBLEjvXQAmmAxYoaxZs8YqSX3eyAlXGIrlKjmy8yoCcF8DFPujjf3AnjFvuu0AzjBLX)uM2i9byC2k8X34BcmTLyqXOfYeio2noHZ0sIp(UBSeAttYxfffTwwYwz8pLPnsdn)LaPygVwsBLEjv4epNKVkkkATSKTY4FktBeEzi24BcmTLyqXOfYegm2X4oHp(ratNDaUMLAETmkGp(gFtGPTedkgTqMaXXJ5eotlPygVwsBLEjv4eppc1sAJxgIJaMo7aCnl18AzuaF8n(MatBjgumAHmbIRACxmJxlPTsVKkCIN)HtbxfzpjMXRL0wPxsfoXZ)skLSeQVrIz8AjTv6LuHt88qEWxsPKIz8AjTv6LuHt88AfusdWuIzIz8AjTv6q)Jxwkl8AjTlYuz41mgeVKkXmETK2kDO)4ep)4Sl0qjKhGxgIv0AzrrGpYbJhxJ7Iz8AjTv6q)XjEEIHrLSb4LHyJLqB6La3nilKagTd5bAO5VeiD5(byC2kxlLkjP4wRxcC3GSqcy0oKhOpaJZwrCmVwsB9sGPQYNknnujyRnOyjgiMXRL0wPd9hN45lbUBqwibmAhYdeZ41sAR0H(Jt8CcCu6I3oALqX4BcmvSd8YqSX3eyAlXGIrlKjmOdNCPIaszX4BcmL(4Sl0qjKhqC84UmwcTPNUeJMhuOHIQoYby8osdn)LaPRiGPZoaxZsnVwgfCfbmD2b4AwQpaJZwrCSdNeZ41sAR0H(Jt8CcCu6IxgIvraPSy8nbMsFC2fAOeYdioECxglH20txIrZdk0qrvh5amEhPHM)sG0veW0zhGRzPMxlJcUIaMo7aCnl1hGXzRio2HtIz8AjTv6q)XjE(sGPQYNkn82rRekgFtGPIDGxgIDNe(1HGMahLU6dW4SvUmwcTPNUeJMhuOHIQoYby8osdn)LaPRiGPZoaxZs9byC2QbHkbBTbflXax8AzuOanGLGI44XDvD1oCQkvwfbKYIX3eyk9XzxOHsipax5MbiU6Xg3PkxTdCCs7uvQ8Voe0txIrZdk0qrvh5amEhPvgVvmaUASkxTdC(1HGMxlJcfcCu6QpaJZwniujyRnOyjgmWadiMXRL0wPd9hN45e4O0fVD0kHIX3eyQyh4LHyJVjW0wIbfJwityqho5sfbKYIX3eyk9XzxOHsipG44XfZ41sAR0H(Jt8CcCu6IxgIvraPSy8nbMsFC2fAOeYdioECXmETK2kDO)4epFjWuv5tLgE7OvcfJVjWuXoWldXUtc)6qqtGJsx9byC2kx)6qqZRLrHcbokD1hGXzRgeQeS1guSedCPIaszX4BcmL(4Sl0qjKhqC84Iz8AjTv6q)XjEEIHrLSb4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRCDq4afb(lbxQiGuwm(MatPZEZgo2aIJRIygVwsBLo0FCINFC2fAOeYdeZ41sAR0H(Jt8CfTwwc5b4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRCPIaszX4BcmLo7nB4ydIDJygVwsBLo0FCINV0oi5PJnaVD0kHIX3eyQyh4LHy3jHFDiOjWrPR(amoBLRQnwcTPdswrGgfon08xcKU(1HG(ZBfKhhmTY4TcIJhdF8vraPSy8nbMsN9MnCSbehJRXhFJLqB6JYx2tLVKDRbAO5VeiDPIaszX4BcmLo7nB4ydio2TnGygVwsBLo0FCINN9MnCSb4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzReZeZ41sAR0zhIxwkl8AjTlYuz41mgeVKkXmETK2kD2bCINFC2fAOeYdWldXkATSOiWh5GXJRXDXmETK2kD2bCINVSXRCKctmJxlPTsNDaN45jggvYgGxgInwcTPxcC3GSqcy0oKhOHM)sG0L7hGXzRCTuQKKIBTEjWDdYcjGr7qEG(amoBfXX8AjT1lbMQkFQ00qLGT2GILyGygVwsBLo7aoXZxcC3GSqcy0oKhiMXRL0wPZoGt8CcCu6I3oALqX4BcmvSd8YqSX3eyAlXGIrlKjmOdNCPIaszX4BcmL(4Sl0qjKhqC844ySeAtNTbxZYYsX(1klPTgA(lbsxglH20txIrZdk0qrvh5amEhPHM)sG0veW0zhGRzPMxlJcUIaMo7aCnl1hGXzRio2HtIz8AjTv6Sd4epNahLU4LHyveqklgFtGP0hNDHgkH8aIJhhhJLqB6Sn4Awwwk2VwzjT1qZFjq6Yyj0ME6smAEqHgkQ6ihGX7in08xcKUIaMo7aCnl18AzuWveW0zhGRzP(amoBfXXoCsmJxlPTsNDaN45lbMQkFQ0WBhTsOy8nbMk2bEzi2Ds4xhcAcCu6QpaJZw5Yyj0ME6smAEqHgkQ6ihGX7in08xcKUIaMo7aCnl1hGXzRgeQeS1guSedCPIaszX4BcmL(4Sl0qjKhqC844ySeAtNTbxZYYsX(1klPTgA(lbsxvxTdNQsLvraPSy8nbMsFC2fAOeYdWvv7MQYjTJQUYQiGuwm(MatPpo7cnuc5bdmaXvp24ov5QDGJtANQsL)1HGE6smAEqHgkQ6ihGX7iTY4TIbWvJv5QDGZVoe08AzuOqGJsx9byC2QbHkbBTbflXGbgyaXmETK2kD2bCINtGJsx82rRekgFtGPIDGxgIn(MatBjgumAHmHbD4KlveqklgFtGP0hNDHgkH8aIJDJRQnwcTPHJjZLTK2AO5VeiXhFJLqB6Sn4Awwwk2VwzjT1qZFjqoGygVwsBLo7aoXZjWrPlEziwfbKYIX3eyk9XzxOHsipG4y34QAJLqBA4yYCzlPTgA(lbs8X3yj0MoBdUMLLLI9RvwsBn08xcKdiMXRL0wPZoGt88LatvLpvA4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRC9RdbnVwgfke4O0vFagNTAqOsWwBqXsmWLkciLfJVjWu6JZUqdLqEaXXUXv1glH20WXK5YwsBn08xcK4JVXsOnD2gCnlllf7xRSK2AO5VeihqmJxlPTsNDaN45jggvYgG3oALqX4BcmvSd8YqS7KWVoe0e4O0vFagNTY1bHdue4VeeZ41sAR0zhWjE(XzxOHsipqmJxlPTsNDaN45kATSeYdWBhTsOy8nbMk2bEzi2Ds4xhcAcCu6QpaJZwjMXRL0wPZoGt88L2bjpDSb4TJwjum(Matf7aVme7oj8RdbnbokD1hGXzReZ41sAR0zhWjEUIatsXTF914TJwjum(Matf7aVme7oj8RdbnbokD1hGXzRCvD1lb(Mav8y4JV7)6qq)5TcYJdM(amoBf(4)Rdb9N3kipoy6dW4Svd(Rdb9N3kipoyALXBfvMxlPTo7nB4yd0qLGT2GILyWadiMXRL0wPZoGt88S3SHJnaVD0kHIX3eyQyh4LHy3jHFDiOjWrPR(amoBf6PIalA4yvnUgzidHa]] )
    

end
