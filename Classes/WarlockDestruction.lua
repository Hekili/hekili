-- WarlockDestruction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 267, true )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        infernal = {
            aura = "infernal",
            
            last = function ()
                local app = state.buff.infernal.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 0.1
        },

        chaos_shards = {
            aura = "chaos_shards",

            last = function ()
                local app = state.buff.chaos_shards.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.5,
            value = 0.2,
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

                if active_enemies > 1 and active_dot.havoc > 0 and query_time - last_havoc < 10 then
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
            max_stack = function () return talent.flashover.enabled and 4 or 2 end,
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


        -- Azerite Powers
        chaos_shards = {
            id = 287660,
            duration = 2,
            max_stack = 1
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
            cast = function () return ( buff.backdraft.up and 2.1 or 3 ) * haste end,
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
                removeStack( "backdraft" )
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
                addStack( "backdraft", nil, talent.flashover.enabled and 4 or 2 )
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

            copy = { 112869 }
        },
        
        
        summon_imp = {
            id = 688,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            essential = true,
            bind = "summon_pet",

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function () summonPet( "imp" ) end,

            copy = "summon_pet"
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


    spec:RegisterPack( "Destruction", 20181022.2147, [[dyejDbqirPEeLK4suskBsumkPOoLsWQukQxjfMfI0Tuks7cYVOegMsOJjQSmerptPGPrjX1KIW2ukIVHiKXHi4CsrK1Hiunprj3tjTprvoiIqPwOOQEiLKQmrkjPUOuevojIqHvsjAMicfDtPiQANGOFIiuYqPKuzPussEkctLsQVkfrzVe9xrgmvDyulgupgyYq1LvTzP6ZG0OruNw41kLMns3gk7wYVPy4kvlxXZPY0jDDk12LsFxPqJxksNxjA9usQQ5dc7NWYCsRLe4SEjKKCXCKqUfjjjrKmNvir5irscD5(Le7myld9sIIXUKWQ(oDSbAykjXoVKAyCP1scNXEaxsqw1DhjUfwanuY2WiGbZcxGztznmfy4UAHlWawatnWwa35nf)TwSpMEqVZcRJpKmNfwtYCPMmEOgW2Kv9D6yd0WuixGbKeW2bvjXOKWscCwVessUyosi3IKKKisMZkKOCBIKGTvYMrsqeyw9KeKdC8xsyjb(DajHvr4TQVthBGgMs4BY4HAaBfwAveEYQU7iXTWcOHs2ggbmyw4cmBkRHPad3vlCbgWcyQb2c4oVP4V1I9X0d6Dwy1n3QIdCNfwDwvPMmEOgW2Kv9D6yd0WuixGbewAveEsSaQb(JWtsssQWtYfZrcc)Mk8njsCRSjcVvxtEHLclTkcVvpYCb9osCHLwfHFtfEI9tPcpjMgWwKWsRIWVPcVv1XmTx4Dbgs5b6vHhq(GTijbnCQtATKa)D2MQsRLqMtATKGbAykjHB)uAIAaBLeVyy6XL5lvjKKuATK4fdtpUmFjbyc9tWsc3(P0KYd0Rouu9pftt8g5TVIcQWN3QWVbHVHWpCGNE7lffvRnT(WW0JS3f(mcVY0xkcWkdOlDyOxmm94scgOHPKeJDLyGgMkrdNkjOHttfJDjbGvwQsi3G0AjXlgMECz(scWe6NGLeU9tPjLhOxDOO6FkMM4nYBFffuHpVvHFdcFdHF4ap92xkkQwBA9HHPhzVl8zeELPVuupMN4cpbpbMtn1rVyy6XLemqdtjjg7kXanmvIgovsqdNMkg7sIEblvjKwrATK4fdtpUmFjbyc9tWsc3(P0KYd0Rouu9pftt8g5TVIcQWN3QWVbHVHWpCGNE7lffvRnT(WW0JS3f(mcVY0xkkQ(NYGEXW0JljyGgMssm2vIbAyQenCQKGgonvm2Ler1LQeYMqATKGbAykjbGvgqx6WKeVyy6XL5lvjKBI0AjXlgMECz(scgOHPKebgMHY6LeGj0pbljYw4XpSDVJiZTgaAoghLt4Zi8nl8Z7ZDKzy6fEiGq4vM(srrPFkMMagmyBNgMc9IHPhx4Zi8mqdtHaKzJlbBOkkQuNgqjRcFgHFoghLt43uHNbAykeGmBCjydvr6WTNM0a7c)Mk8nHWNLWJBpSgMs43SWViAdc)cscWsa9jLhOxDsiZjvjKKiP1sIxmm94Y8LemqdtjjamLMyGgMkrdNkjOHttfJDjba3jvjKKG0AjXlgMECz(scWe6NGLezl8W29oIbA0(ezU1aqZX4OCscgOHPKeaYCvNMWpMP6XCPkHSjjTws8IHPhxMVKGbAykjbzU1aKeGj0pbljuEGEfPb2tQjHhx4Zt4ZTOWNr4zGgTp96yXDcFEcFoHVHWpCGNE7lffvRnT(WW0JS3LeGLa6tkpqV6KqMtQsiZTO0AjXlgMECz(scWe6NGLemqJ2NEDS4oHppHpNW3q4hoWtV9LIIQ1MwFyy6r27scgOHPKeK5wdqQsiZLtATK4fdtpUmFjbd0WuscNXMM6XCjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsiZrsP1sIxmm94Y8LemqdtjjaKzJlbBOQKamH(jyjr2cp(HT7DezU1aqZX4OCcFgH)n9aB9jnWUW3q41HBpnPb2f(SeELhOxrAG9KAs4Xf(mcFZcVorT9kAFmauu6P0du0CgOcFgHxNO2EfTpgakk9u6bkAoghLt4Zt4bSttAGDHhcieEDIA7v0(yaim2PFwIMZav4Zi86e12RO9XaqySt)SenhJJYj85j8a2PjnWUWdbecVorT9kAFmau7hhRbn0LO5mqf(mcVorT9kAFmau7hhRbn0LO5yCuoHppHhWonPb2fEiGq41jQTxr7JbGatOO5mqf(mcVorT9kAFmaeycfnhJJYj85j8a2PjnWUWdbecVorT9kAFmaKB)uAA3SXpO5mqf(mcVorT9kAFmaKB)uAA3SXpO5yCuoHppHhWonPb2f(fKeGLa6tkpqV6KqMtQsiZTbP1sIxmm94Y8LemqdtjjaKzJlbBOQKamH(jyjr2cp(HT7DezU1aqZX4OCcFgH)n9aB9jnWUW3q41HBpnPb2f(SeELhOxrAG9KAs4Xf(mcFZcVorT9kYPmyBuqt7JbGIspLEGIMZav4Zi86e12RiNYGTrbnTpgakk9u6bkAoghLt4Zt4bSttAGDHhcieEDIA7vKtzW2OGM2hdaHXo9Zs0CgOcFgHxNO2Ef5ugSnkOP9XaqySt)SenhJJYj85j8a2PjnWUWdbecVorT9kYPmyBuqt7JbGA)4ynOHUenNbQWNr41jQTxroLbBJcAAFmau7hhRbn0LO5yCuoHppHhWonPb2fEiGq41jQTxroLbBJcAAFmaeycfnNbQWNr41jQTxroLbBJcAAFmaeycfnhJJYj85j8a2PjnWUWdbecVorT9kYPmyBuqt7JbGC7Nst7Mn(bnNbQWNr41jQTxroLbBJcAAFmaKB)uAA3SXpO5yCuoHppHhWonPb2f(fKeGLa6tkpqV6KqMtQsiZzfP1sIxmm94Y8LemqdtjjaKzJlbBOQKamH(jyjr2cp(HT7DezU1aqZX4OCcFgH)n9aB9jnWUW3q41HBpnPb2f(SeELhOxrAG9KAs4Xf(mcFZcpWyO4MnwiNngMPsr1)umfnhJJYj85Tk8KCrHhcie(SfELPVue0jWmX8KPNC27ZXyWs0lgMECHFbHpJW3SWdmgkUzJfcNNTjNXMMIYPmCqdDjAoghLt4ZBv4j5Icpeqi8zl8ktFPiCE2MCgBAkkNYWbn0LOxmm94c)ccFgHVzHxz6lf9HXdaRHPqVyy6Xf(mcp(HT7D0hgpaSgMcnhJJYj8zTk8a2PjnWUWdbecpSDVJGzWw8H7kAoghLt4HacHxz6lffL(PyAcyWGTDAyk0lgMECHFbjbyjG(KYd0RojK5KQeYCnH0AjXlgMECz(scgOHPKeaYSXLGnuvsaMq)eSKiBHh)W29oIm3AaO5yCuoHpJW)MEGT(Kgyx4Bi86WTNM0a7cFwcVYd0RinWEsnj84cFgHVzH3zSPjhzEWf(8wfERi8qaHWdB37iCE2MCgBAkkNYWbn0LO5yCuoHppHhWonPb2fEiGq43VIIQ)PykIbA0EHhcieEy7EhXanAFIm3AaO5yCuoHppHhWonPb2f(fKeGLa6tkpqV6KqMtQsiZTjsRLeVyy6XL5ljyGgMssamvNYqhwVKamH(jyjr2cp(HT7DezU1aqZX4OCcFgHVzHVzHxz6lf1PSJSP9d6fdtpUWNr4HT7Demd2IpCxroLbBf(SwfEsk8li8qaHW3SWNTWRm9LI6u2r20(b9IHPhx4Zi8W29ocMbBXhURiNYGTcFwcpjf(fe(fKeGLa6tkpqV6KqMtQsiZrIKwljEXW0JlZxsWanmLKWrMXnBe2Ekjbyc9tWsISfE8dB37iYCRbGMJXr5e(mcFZcFZcpGmpqVt4xfEsk8qaHWNTWdB37iygSfF4UIMJXr5eEiGq4HT7Demd2IpCxrZX4OCcFEcpSDVJGzWw8H7kYPmyRWVzHNbAykuuGO(W6rVPhyRpPb2f(fe(fKeGLa6tkpqV6KqMtQsiZrcsRLeVyy6XL5ljyGgMssefiQpSEjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsvsSphyWGzvATeYCsRLeVyy6XL5lvjKKuATK4fdtpUmFPkHCdsRLeVyy6XL5lvjKwrATKGbAykjHZgdZuP(PKTl9JK4fdtpUmFPkHSjKwljEXW0JlZxsaMq)eSKqz6lfbDcmtmpz6jhdMOhGJEXW0JljyGgMssaDcmtmpz6jhdMOhGlvjKBI0AjXlgMECz(svcjjsATKGbAykjXUrdtjjEXW0JlZxQsijbP1scgOHPKeoJnn1J5sIxmm94Y8LQeYMK0AjXlgMECz(scWe6NGLezl8ktFPiNXMM6XC0lgMECjbd0WusIOar9H1lvPkjaSYsRLqMtATK4fdtpUmFjbd0WuscatPjgOHPs0WPscA40uXyxsaWDsvcjjLwljEXW0JlZxsaMq)eSKWzSPjhzEWf(8wfERGAcjbd0WusIHJkz6PEmxQsi3G0Ajbd0WuscaRmGU0HjjEXW0JlZxQsiTI0AjXlgMECz(scWe6NGLektFPiazUQtt4hZu9yo6fdtpUWNr4Zw4NJXr5e(mcpWyO4MnwiazUQtt4hZu9yoAoghLt4ZAv4zGgMcbiZgxc2qv0B6b26tAGDjbd0WusIadZqz9svcztiTws8IHPhxMVKamH(jyjr2cpSDVJyGgTprMBna0CmokNKGbAykjbGmx1Pj8JzQEmxQsi3eP1sIxmm94Y8LemqdtjjiZTgGKamH(jyjHYd0RinWEsnj84cFEcFUff(mcVB)uAs5b6vhA4OsMEQhZf(SwfEsq4Bi8dh4P3(srr1AtRpmm9i7DHpJWRm9LIGobMjMNm9KZEFogdwIEXW0Jl8ze(9ROO6FkMIyGgTx4Zi87xrr1)umfnhJJYj8zTk85wusawcOpP8a9QtczoPkHKejTws8IHPhxMVKamH(jyjHB)uAs5b6vhA4OsMEQhZf(SwfEsq4Bi8dh4P3(srr1AtRpmm9i7DHpJWRm9LIGobMjMNm9KZEFogdwIEXW0Jl8ze(9ROO6FkMIyGgTx4Zi87xrr1)umfnhJJYj8zTk85wusWanmLKGm3AasvcjjiTws8IHPhxMVKGbAykjbGmBCjydvLeGj0pbljYw4XpSDVJiZTgaAoghLt4Zi8ktFPiOtGzI5jtp5S3NJXGLOxmm94cFgHF)kkQ(NIPO5yCuoHppH)n9aB9jnWUWNr4zGgTp96yXDcFwRcpji8ne(Hd80BFPOOATP1hgMEK9UWNr4Bw4Bw4ZTiji8Bw4Bw4D7NstkpqV6qdhvY0t9yUW3q4hoWtV9LIIQ1MwFyy6r27c)ccVvt43GWVGWNLW3SWtsRSOWVzHVzHpNW3q4xeTiji8Bw4HT7De0jWmX8KPNC27ZXyWsKtzWwHFbH3Qj8Ku43SW3SWNt4Bi8W29oIbA0(ezU1aqZX4OCcFEc)B6b26tAGDHFbHFbHFbjbyjG(KYd0RojK5KQeYMK0AjXlgMECz(scgOHPKeK5wdqsaMq)eSKq5b6vKgypPMeECHppHp3IcFgH3TFknP8a9QdnCujtp1J5cFwRcVve(gc)WbE6TVuuuT206ddtpYExsawcOpP8a9QtczoPkHm3IsRLeVyy6XL5ljatOFcws42pLMuEGE1HgoQKPN6XCHpRvH3kcFdHF4ap92xkkQwBA9HHPhzVljyGgMssqMBnaPkHmxoP1sIxmm94Y8LemqdtjjaKzJlbBOQKamH(jyjr2cp(HT7DezU1aqZX4OCcFgHh2U3rmqJ2NiZTgaAoghLt4Zt4FtpWwFsdSl8zeE3(P0KYd0Ro0WrLm9upMl8zTk8wr4Bi8dh4P3(srr1AtRpmm9i7DjbyjG(KYd0RojK5KQeYCKuATK4fdtpUmFjbd0WusIadZqz9scWe6NGLezl84h2U3rK5wdanhJJYj8ze(595oYmm9cFgHFoghLt4ZAv4bgdf3SXcbyLb0Lom0CmokNKaSeqFs5b6vNeYCsvczUniTwsWanmLKy4OsMEQhZLeVyy6XL5lvjK5SI0AjXlgMECz(scgOHPKeoJnn1J5scWe6NGLezl84h2U3rK5wdanhJJYjjalb0NuEGE1jHmNuLqMRjKwljEXW0JlZxsWanmLKayQoLHoSEjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsiZTjsRLeVyy6XL5ljyGgMss4iZ4MncBpLKamH(jyjr2cp(HT7DezU1aqZX4OCcFgHVzHVzHhqMhO3j8RcpjfEiGq4Zw4HT7Demd2IpCxrZX4OCcpeqi8W29ocMbBXhURO5yCuoHppHh2U3rWmyl(WDf5ugSv43SWZanmfkkquFy9O30dS1N0a7c)cc)cscWsa9jLhOxDsiZjvjK5irsRLeVyy6XL5ljyGgMssefiQpSEjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsvsaWDsRLqMtATK4fdtpUmFjbyc9tWscLhOxrAG9KAs4Xf(8wfEsMBrHhcie(SfEGXqXnBSq48Sn5m20uuoLHdAOlrZX4OCcpeqi8kpqVI0a7j1KWJl8zTk8ByrHVHWdfGl8qaHWNTWRm9LIW5zBYzSPPOCkdh0qxIEXW0JljyGgMss4SXWmvkQ(NIPsvcjjLwljEXW0JlZxsaMq)eSKq5b6vKgypPMeECHpVvHpNvwu4HacHF)kkQ(NIPigOr7fEiGq4vEGEfPb2tQjHhx4ZAv4j5IcFdHhkaxsWanmLKaNNTjNXMMIYPmCqdDPuLqUbP1sIxmm94Y8LeGj0pblj2VIIQ)PykIbA0EHhcieELhOxrAG9KAs4Xf(Se(nPjKemqdtjj2nAykPkH0ksRLemqdtjjG)4(SnkOsIxmm94Y8LQeYMqATKGbAykjbm1yWtD7zPK4fdtpUmFPkHCtKwljyGgMss0J5WuJbxs8IHPhxMVuLqsIKwljyGgMssy7Ek0J5KeVyy6XL5lvPkj6fS0AjK5KwljEXW0JlZxsWanmLKaWuAIbAyQenCQKGgonvm2LeaCNuLqssP1sIxmm94Y8LeGj0pbljCgBAYrMhCHpVvH3kOMqsWanmLKy4OsMEQhZLQeYniTws8IHPhxMVKamH(jyjHY0xkcqMR60e(XmvpMJEXW0Jl8ze(Sf(5yCuoHpJWdmgkUzJfcqMR60e(XmvpMJMJXr5e(SwfEgOHPqaYSXLGnuf9MEGT(KgyxsWanmLKiWWmuwVuLqAfP1sIxmm94Y8LeGj0pbljYw4HT7Ded0O9jYCRbGMJXr5KemqdtjjaK5QonHFmt1J5svcztiTws8IHPhxMVKGbAykjbzU1aKeGj0pbljuEGEfPb2tQjHhx4Zt4ZTOWNr4D7NstkpqV6qdhvY0t9yUWN1QWBfHVHWpCGNE7lffvRnT(WW0JS3f(mcVY0xkc6eyMyEY0to795ymyj6fdtpUWNr43VIIQ)PykIbA0EHpJWVFffv)tXu0CmokNWN1QWNBrjbyjG(KYd0RojK5KQeYnrATK4fdtpUmFjbyc9tWsc3(P0KYd0Ro0WrLm9upMl8zTk8wr4Bi8dh4P3(srr1AtRpmm9i7DHpJWRm9LIGobMjMNm9KZEFogdwIEXW0Jl8ze(9ROO6FkMIyGgTx4Zi87xrr1)umfnhJJYj8zTk85wusWanmLKGm3AasvcjjsATK4fdtpUmFjbd0Wuscaz24sWgQkjatOFcwsKTWJFy7EhrMBna0CmokNWNr4vM(srqNaZeZtMEYzVphJblrVyy6Xf(mc)(vuu9pftrZX4OCcFEc)B6b26tAGDHpJWZanAF61XI7e(SwfERi8ne(Hd80BFPOOATP1hgMEK9UWNr4Bw4Bw4ZTiji8Bw4Bw4D7NstkpqV6qdhvY0t9yUW3q4hoWtV9LIIQ1MwFyy6r27c)ccVvt43GWVGWNLW3SWtsRSOWVzHVzHpNW3q4xeTiji8Bw4HT7De0jWmX8KPNC27ZXyWsKtzWwHFbH3Qj8Ku43SW3SWNt4Bi8W29oIbA0(ezU1aqZX4OCcFEc)B6b26tAGDHFbHFbHFbjbyjG(KYd0RojK5KQessqATK4fdtpUmFjbd0WuscYCRbijatOFcwsO8a9ksdSNutcpUWNNWNBrHpJW72pLMuEGE1HgoQKPN6XCHpRvH3kcFdHF4ap92xkkQwBA9HHPhzVljalb0NuEGE1jHmNuLq2KKwljEXW0JlZxsaMq)eSKWTFknP8a9QdnCujtp1J5cFwRcVve(gc)WbE6TVuuuT206ddtpYExsWanmLKGm3AasvczUfLwljEXW0JlZxsWanmLKaqMnUeSHQscWe6NGLezl84h2U3rK5wdanhJJYj8zeEy7EhXanAFIm3AaO5yCuoHppH)n9aB9jnWUWNr4D7NstkpqV6qdhvY0t9yUWN1QWBfHVHWpCGNE7lffvRnT(WW0JS3LeGLa6tkpqV6KqMtQsiZLtATK4fdtpUmFjbd0WusIadZqz9scWe6NGLezl84h2U3rK5wdanhJJYj8ze(595oYmm9cFgH3TFknP8a9QdffiQpSEHpRvHNee(gc)WbE6TVuuuT206ddtpYExsawcOpP8a9QtczoPkHmhjLwljyGgMssmCujtp1J5sIxmm94Y8LQeYCBqATK4fdtpUmFjbd0WuscNXMM6XCjbyc9tWsISfE8dB37iYCRbGMJXr5e(mcVB)uAs5b6vhkkquFy9cFwRc)ge(gc)WbE6TVuuuT206ddtpYExsawcOpP8a9QtczoPkHmNvKwljEXW0JlZxsWanmLKayQoLHoSEjbyc9tWsISfE8dB37iYCRbGMJXr5e(mcFZcVY0xkQtzhzt7h0lgMECHpJWdB37iygSfF4UICkd2k8zTk8Ku4HacH3TFknP8a9QdffiQpSEHpRvHNej8ne(Hd80BFPOOATP1hgMEK9UWdbecVY0xkAm8ef0emLT6F0lgMECHpJW72pLMuEGE1HIce1hwVWN1QW3Ke(gc)WbE6TVuuuT206ddtpYEx4xqsawcOpP8a9QtczoPkHmxtiTws8IHPhxMVKGbAykjruGO(W6LeGj0pbljYw4XpSDVJiZTgaAoghLtsawcOpP8a9QtczoPkvjruDP1siZjTws8IHPhxMVKGbAykjbGP0ed0WujA4ujbnCAQySlja4oPkHKKsRLeVyy6XL5ljatOFcws4m20KJmp4cFERcVvqnHKGbAykjXWrLm9upMlvjKBqATKGbAykjbGvgqx6WKeVyy6XL5lvjKwrATK4fdtpUmFjbyc9tWscLPVueGmx1Pj8JzQEmh9IHPhx4Zi8zl8ZX4OCcFgHhymuCZgleGmx1Pj8JzQEmhnhJJYj8zTk8mqdtHaKzJlbBOk6n9aB9jnWUKGbAykjrGHzOSEPkHSjKwljEXW0JlZxsaMq)eSKiBHh2U3rmqJ2NiZTgaAoghLtsWanmLKaqMR60e(XmvpMlvjKBI0AjXlgMECz(scgOHPKeK5wdqsaMq)eSKq5b6vKgypPMeECHppHp3IcFgH3TFknP8a9QdnCujtp1J5cFwRcVve(gc)WbE6TVuuuT206ddtpYEx4Bi8ktFPOO0pfttadgSTtdtHEXW0Jl8zeELPVue0jWmX8KPNC27ZXyWs0lgMECHpJWVFffv)tXued0O9cFgHF)kkQ(NIPO5yCuoHpRvHp3IscWsa9jLhOxDsiZjvjKKiP1sIxmm94Y8LeGj0pbljC7NstkpqV6qdhvY0t9yUWN1QWBfHVHWpCGNE7lffvRnT(WW0JS3f(gcVY0xkkk9tX0eWGbB70WuOxmm94cFgHxz6lfbDcmtmpz6jN9(CmgSe9IHPhx4Zi87xrr1)umfXanAVWNr43VIIQ)PykAoghLt4ZAv4ZTOKGbAykjbzU1aKQessqATK4fdtpUmFjbd0Wuscaz24sWgQkjatOFcwsKTWJFy7EhrMBna0CmokNWNr4vM(srqNaZeZtMEYzVphJblrVyy6Xf(mc)(vuu9pftrZX4OCcFEc)B6b26tAGDHpJW72pLMuEGE1HgoQKPN6XCHpRvH3kcFdHF4ap92xkkQwBA9HHPhzVl8neELPVuuu6NIPjGbd22PHPqVyy6Xf(mcFZcFZcFUfjbHFZcFZcVB)uAs5b6vhA4OsMEQhZf(gc)WbE6TVuuuT206ddtpYEx4xq4TAcFZc)ge(nv4xeLBte(nl8nl8U9tPjLhOxDOHJkz6PEmx4Bi8dh4P3(srr1AtRpmm9i7DHFbHFbHFbHplHVzHNKwzrHFZcFZcFoHVHWViArsq43SWdB37iOtGzI5jtp5S3NJXGLiNYGTc)ccVvt4jPWVzHVzHpNW3q4HT7Ded0O9jYCRbGMJXr5e(8e(30dS1N0a7c)cc)cc)cscWsa9jLhOxDsiZjvjKnjP1sIxmm94Y8LemqdtjjiZTgGKamH(jyjHYd0RinWEsnj84cFEcFUff(mcVB)uAs5b6vhA4OsMEQhZf(Swf(ni8ne(Hd80BFPOOATP1hgMEK9UWNr4Bw4vM(srFy8aWAyk0lgMECHhcieELPVuuu6NIPjGbd22PHPqVyy6Xf(fKeGLa6tkpqV6KqMtQsiZTO0AjXlgMECz(scWe6NGLeU9tPjLhOxDOHJkz6PEmx4ZAv43GW3q4hoWtV9LIIQ1MwFyy6r27cFgHVzHxz6lf9HXdaRHPqVyy6XfEiGq4vM(srrPFkMMagmyBNgMc9IHPhx4xqsWanmLKGm3AasvczUCsRLeVyy6XL5ljyGgMssaiZgxc2qvjbyc9tWsISfE8dB37iYCRbGMJXr5e(mcpSDVJyGgTprMBna0CmokNWNNW)MEGT(Kgyx4Zi8U9tPjLhOxDOHJkz6PEmx4ZAv43GW3q4hoWtV9LIIQ1MwFyy6r27cFgHVzHxz6lf9HXdaRHPqVyy6XfEiGq4vM(srrPFkMMagmyBNgMc9IHPhx4xqsawcOpP8a9QtczoPkHmhjLwljEXW0JlZxsWanmLKiWWmuwVKamH(jyjr2cp(HT7DezU1aqZX4OCcFgHFEFUJmdtVKaSeqFs5b6vNeYCsvczUniTwsWanmLKy4OsMEQhZLeVyy6XL5lvjK5SI0AjXlgMECz(scgOHPKeoJnn1J5scWe6NGLezl84h2U3rK5wdanhJJYjjalb0NuEGE1jHmNuLqMRjKwljEXW0JlZxsWanmLKayQoLHoSEjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsiZTjsRLeVyy6XL5ljyGgMss4iZ4MncBpLKamH(jyjr2cp(HT7DezU1aqZX4OCcFgHVzHVzHhqMhO3j8RcpjfEiGq4Zw4HT7Demd2IpCxrZX4OCcpeqi8W29ocMbBXhURO5yCuoHppHh2U3rWmyl(WDf5ugSv43SWZanmfkkquFy9O30dS1N0a7c)cc)cscWsa9jLhOxDsiZjvjK5irsRLeVyy6XL5ljyGgMssefiQpSEjbyc9tWsISfE8dB37iYCRbGMJXr5KeGLa6tkpqV6KqMtQsvQsI2pUWusij5I5iHfBsByruUfBIMKKyJ8urb1jjiXaB3m6Xf(nr4zGgMs4PHtDiHLsI9X0d6LewfH3Q(oDSbAykHVjJhQbSvyPvr4jR6UJe3clGgkzByeWGzHlWSPSgMcmCxTWfyalGPgylG78MI)wl2htpO3zHv3CRkoWDwy1zvLAY4HAaBtw13PJnqdtHCbgqyPvr4jXcOg4pcpjjjPcpjxmhji8BQW3KiXTYMi8wDn5fwkS0Qi8w9iZf07iXfwAve(nv4j2pLk8KyAaBrclTkc)Mk8wvhZ0EH3fyiLhOxfEa5d2IewkS0Qi8n5A6b26XfE43nZfEGbdMvHh(qJYHeEsSbGVRoHVm1MsMhSUnv4zGgMYj8MIUejSKbAykhAFoWGbZ6ANYUTclzGgMYH2NdmyWS2y1IUXGlSKbAykhAFoWGbZAJvlyBOyVuwdtjSKbAykhAFoWGbZAJvlC2yyMkTFvyjd0Wuo0(CGbdM1gRwaDcmtmpz6jhdMOhGtA0xvM(srqNaZeZtMEYXGj6b4Oxmm94clzGgMYH2NdmyWS2y1cxX7oYgn5uwDclzGgMYH2NdmyWS2y1IDJgMsyjd0Wuo0(CGbdM1gRw4m20upMlSKbAykhAFoWGbZAJvlIce1hwpPrFnBLPVuKZytt9yo6fdtpUWsHLwfHVjxtpWwpUW)2plfEnWUWRKVWZa1mcF4eEULdkdtpsyjd0WuUv3(P0e1a2kSKbAykxJvlg7kXanmvIgoL0IX(kGvM0OV62pLMuEGE1HIQ)PyAI3iV9vuqZBDdngoWtV9LIIQ1MwFyy6r27zuM(srawzaDPdd9IHPhxyjd0WuUgRwm2vIbAyQenCkPfJ91EbtA0xD7NstkpqV6qr1)umnXBK3(kkO5TUHgdh4P3(srr1AtRpmm9i79mktFPOEmpXfEcEcmNAQJEXW0JlSKbAykxJvlg7kXanmvIgoL0IX(AuDsJ(QB)uAs5b6vhkQ(NIPjEJ82xrbnV1n0y4ap92xkkQwBA9HHPhzVNrz6lffv)tzqVyy6XfwYanmLRXQfawzaDPdtyjd0WuUgRweyygkRNuWsa9jLhOxDR5in6RzJFy7EhrMBna0CmokxMMN3N7iZW0dbektFPOO0pfttadgSTtdtHEXW0JNHbAykeGmBCjydvrrL60akznZCmok3MYanmfcqMnUeSHQiD42ttAG9nTjYc3Eynm1MxeTHfewYanmLRXQfaMstmqdtLOHtjTySVcWDclzGgMY1y1cazUQtt4hZu9yoPrFnBy7EhXanAFIm3AaO5yCuoHLmqdt5ASAbzU1aifSeqFs5b6v3AosJ(QYd0RinWEsnj845LBXmmqJ2NEDS4U8Y1y4ap92xkkQwBA9HHPhzVlSKbAykxJvliZTgaPrFLbA0(0RJf3LxUgdh4P3(srr1AtRpmm9i7DHLmqdt5ASAHZytt9yoPGLa6tkpqV6wZrA0xZg)W29oIm3AaO5yCuoHLmqdt5ASAbGmBCjydvjfSeqFs5b6v3AosJ(A24h2U3rK5wdanhJJYL5n9aB9jnWEdD42ttAG9SuEGEfPb2tQjHhptZ6e12RO9XaqrPNspqrZzGMrNO2EfTpgakk9u6bkAoghLlpa70Kgyhci0jQTxr7JbGWyN(zjAod0m6e12RO9XaqySt)SenhJJYLhGDAsdSdbe6e12RO9XaqTFCSg0qxIMZanJorT9kAFmau7hhRbn0LO5yCuU8aSttAGDiGqNO2EfTpgacmHIMZanJorT9kAFmaeycfnhJJYLhGDAsdSdbe6e12RO9XaqU9tPPDZg)GMZanJorT9kAFmaKB)uAA3SXpO5yCuU8aSttAG9fewYanmLRXQfaYSXLGnuLuWsa9jLhOxDR5in6RzJFy7EhrMBna0CmokxM30dS1N0a7n0HBpnPb2Zs5b6vKgypPMeE8mnRtuBVICkd2gf00(yaOO0tPhOO5mqZOtuBVICkd2gf00(yaOO0tPhOO5yCuU8aSttAGDiGqNO2Ef5ugSnkOP9XaqySt)SenNbAgDIA7vKtzW2OGM2hdaHXo9Zs0CmokxEa2PjnWoeqOtuBVICkd2gf00(yaO2powdAOlrZzGMrNO2Ef5ugSnkOP9XaqTFCSg0qxIMJXr5YdWonPb2HacDIA7vKtzW2OGM2hdabMqrZzGMrNO2Ef5ugSnkOP9XaqGju0CmokxEa2PjnWoeqOtuBVICkd2gf00(yai3(P00UzJFqZzGMrNO2Ef5ugSnkOP9XaqU9tPPDZg)GMJXr5YdWonPb2xqyjd0WuUgRwaiZgxc2qvsblb0NuEGE1TMJ0OVMn(HT7DezU1aqZX4OCzEtpWwFsdS3qhU90KgyplLhOxrAG9KAs4XZ0mWyO4MnwiNngMPsr1)umfnhJJYL3kjxeciYwz6lfbDcmtmpz6jN9(CmgSe9IHPhFHmndmgkUzJfcNNTjNXMMIYPmCqdDjAoghLlVvsUieqKTY0xkcNNTjNXMMIYPmCqdDj6fdtp(czAwz6lf9HXdaRHPqVyy6XZGFy7Eh9HXdaRHPqZX4OCzTcyNM0a7qabSDVJGzWw8H7kAoghLdciuM(srrPFkMMagmyBNgMc9IHPhFbHLmqdt5ASAbGmBCjydvjfSeqFs5b6v3AosJ(A24h2U3rK5wdanhJJYL5n9aB9jnWEdD42ttAG9SuEGEfPb2tQjHhptZoJnn5iZdEERwbciGT7DeopBtoJnnfLtz4Gg6s0CmokxEa2PjnWoeqSFffv)tXued0O9qabSDVJyGgTprMBna0CmokxEa2PjnW(cclzGgMY1y1cGP6ug6W6jfSeqFs5b6v3AosJ(A24h2U3rK5wdanhJJYLP5MvM(srDk7iBA)GEXW0JNb2U3rWmyl(WDf5ugSnRvsUaeq0C2ktFPOoLDKnTFqVyy6XZaB37iygSfF4UICkd2MfjxybHLmqdt5ASAHJmJB2iS9uKcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5Y0CZaY8a9UvscbezdB37iygSfF4UIMJXr5Gacy7EhbZGT4d3v0CmokxEW29ocMbBXhURiNYGTBMbAykuuGO(W6rVPhyRpPb2xybHLmqdt5ASAruGO(W6jfSeqFs5b6v3AosJ(A24h2U3rK5wdanhJJYjSuyjd0WuoeGvEfWuAIbAyQenCkPfJ9vaUtyjd0WuoeGvUXQfdhvY0t9yoPrF1zSPjhzEWZB1kOMqyjd0WuoeGvUXQfawzaDPdtyjd0WuoeGvUXQfbgMHY6jn6RktFPiazUQtt4hZu9yo6fdtpEMSNJXr5YamgkUzJfcqMR60e(XmvpMJMJXr5YALbAykeGmBCjydvrVPhyRpPb2fwYanmLdbyLBSAbGmx1Pj8JzQEmN0OVMnSDVJyGgTprMBna0CmokNWsgOHPCiaRCJvliZTgaPGLa6tkpqV6wZrA0xvEGEfPb2tQjHhpVClMXTFknP8a9QdnCujtp1J5zTscngoWtV9LIIQ1MwFyy6r27zuM(srqNaZeZtMEYzVphJblrVyy6XZSFffv)tXued0O9z2VIIQ)PykAoghLlR1ClkSKbAykhcWk3y1cYCRbqA0xD7NstkpqV6qdhvY0t9yEwRKqJHd80BFPOOATP1hgMEK9EgLPVue0jWmX8KPNC27ZXyWs0lgME8m7xrr1)umfXanAFM9ROO6FkMIMJXr5YAn3IclzGgMYHaSYnwTaqMnUeSHQKcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5YOm9LIGobMjMNm9KZEFogdwIEXW0JNz)kkQ(NIPO5yCuU8EtpWwFsdSNHbA0(0RJf3L1kj0y4ap92xkkQwBA9HHPhzVNP5MZTijS5MD7NstkpqV6qdhvY0t9yEJHd80BFPOOATP1hgMEK9(cwTnSqwntsRS4MBoxJfrlscBg2U3rqNaZeZtMEYzVphJblroLbBxWQrYn3CUgW29oIbA0(ezU1aqZX4OC59MEGT(KgyFHfwqyjd0WuoeGvUXQfK5wdGuWsa9jLhOxDR5in6RkpqVI0a7j1KWJNxUfZ42pLMuEGE1HgoQKPN6X8SwTsJHd80BFPOOATP1hgMEK9UWsgOHPCiaRCJvliZTgaPrF1TFknP8a9QdnCujtp1J5zTALgdh4P3(srr1AtRpmm9i7DHLmqdt5qaw5gRwaiZgxc2qvsblb0NuEGE1TMJ0OVMn(HT7DezU1aqZX4OCzGT7Ded0O9jYCRbGMJXr5Y7n9aB9jnWEg3(P0KYd0Ro0WrLm9upMN1QvAmCGNE7lffvRnT(WW0JS3fwYanmLdbyLBSArGHzOSEsblb0NuEGE1TMJ0OVMn(HT7DezU1aqZX4OCzM3N7iZW0NzoghLlRvGXqXnBSqawzaDPddnhJJYjSKbAykhcWk3y1IHJkz6PEmxyjd0WuoeGvUXQfoJnn1J5KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5ewYanmLdbyLBSAbWuDkdDy9KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5ewYanmLdbyLBSAHJmJB2iS9uKcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5Y0CZaY8a9UvscbezdB37iygSfF4UIMJXr5Gacy7EhbZGT4d3v0CmokxEW29ocMbBXhURiNYGTBMbAykuuGO(W6rVPhyRpPb2xybHLmqdt5qaw5gRwefiQpSEsblb0NuEGE1TMJ0OVMn(HT7DezU1aqZX4OCclfwYanmLdbWDRoBmmtLIQ)PykPrFv5b6vKgypPMeE88wjzUfHaISbgdf3SXcHZZ2KZyttr5ugoOHUenhJJYbbekpqVI0a7j1KWJN16gwSbuaoeqKTY0xkcNNTjNXMMIYPmCqdDj6fdtpUWsgOHPCiaURXQf48Sn5m20uuoLHdAOljn6RkpqVI0a7j1KWJN3AoRSieqSFffv)tXued0O9qaHYd0RinWEsnj84zTsYfBafGlSKbAykhcG7ASAXUrdtrA0x3VIIQ)PykIbA0EiGq5b6vKgypPMeE8S2KMqyjd0Wuoea31y1c4pUpBJcQWsgOHPCiaURXQfWuJbp1TNLclzGgMYHa4UgRw0J5WuJbxyjd0Wuoea31y1cB3tHEmNWsHLmqdt5q9cEfWuAIbAyQenCkPfJ9vaUtyjd0WuouVGBSAXWrLm9upMtA0xDgBAYrMh88wTcQjewYanmLd1l4gRweyygkRN0OVQm9LIaK5QonHFmt1J5Oxmm94zYEoghLldWyO4MnwiazUQtt4hZu9yoAoghLlRvgOHPqaYSXLGnuf9MEGT(Kgyxyjd0WuouVGBSAbGmx1Pj8JzQEmN0OVMnSDVJyGgTprMBna0CmokNWsgOHPCOEb3y1cYCRbqkyjG(KYd0RU1CKg9vLhOxrAG9KAs4XZl3IzC7NstkpqV6qdhvY0t9yEwRwPXWbE6TVuuuT206ddtpYEpJY0xkc6eyMyEY0to795ymyj6fdtpEM9ROO6FkMIyGgTpZ(vuu9pftrZX4OCzTMBrHLmqdt5q9cUXQfK5wdG0OV62pLMuEGE1HgoQKPN6X8SwTsJHd80BFPOOATP1hgMEK9EgLPVue0jWmX8KPNC27ZXyWs0lgME8m7xrr1)umfXanAFM9ROO6FkMIMJXr5YAn3IclzGgMYH6fCJvlaKzJlbBOkPGLa6tkpqV6wZrA0xZg)W29oIm3AaO5yCuUmktFPiOtGzI5jtp5S3NJXGLOxmm94z2VIIQ)PykAoghLlV30dS1N0a7zyGgTp96yXDzTALgdh4P3(srr1AtRpmm9i79mn3CUfjHn3SB)uAs5b6vhA4OsMEQhZBmCGNE7lffvRnT(WW0JS3xWQTHfYQzsALf3CZ5ASiArsyZW29oc6eyMyEY0to795ymyjYPmy7cwnsU5MZ1a2U3rmqJ2NiZTgaAoghLlV30dS1N0a7lSWcclzGgMYH6fCJvliZTgaPGLa6tkpqV6wZrA0xvEGEfPb2tQjHhpVClMXTFknP8a9QdnCujtp1J5zTALgdh4P3(srr1AtRpmm9i7DHLmqdt5q9cUXQfK5wdG0OV62pLMuEGE1HgoQKPN6X8SwTsJHd80BFPOOATP1hgMEK9UWsgOHPCOEb3y1caz24sWgQskyjG(KYd0RU1CKg91SXpSDVJiZTgaAoghLldSDVJyGgTprMBna0CmokxEVPhyRpPb2Z42pLMuEGE1HgoQKPN6X8SwTsJHd80BFPOOATP1hgMEK9UWsgOHPCOEb3y1IadZqz9KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5YmVp3rMHPpJB)uAs5b6vhkkquFy9zTscngoWtV9LIIQ1MwFyy6r27clzGgMYH6fCJvlgoQKPN6XCHLmqdt5q9cUXQfoJnn1J5KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5Y42pLMuEGE1HIce1hwFwRBOXWbE6TVuuuT206ddtpYExyjd0WuouVGBSAbWuDkdDy9KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5Y0SY0xkQtzhzt7h0lgME8mW29ocMbBXhURiNYGTzTssiGWTFknP8a9QdffiQpS(SwjrngoWtV9LIIQ1MwFyy6r27qaHY0xkAm8ef0emLT6F0lgME8mU9tPjLhOxDOOar9H1N1AtQXWbE6TVuuuT206ddtpYEFbHLmqdt5q9cUXQfrbI6dRNuWsa9jLhOxDR5in6RzJFy7EhrMBna0CmokNWsHLmqdt5qr1xbmLMyGgMkrdNsAXyFfG7ewYanmLdfvVXQfdhvY0t9yoPrF1zSPjhzEWZB1kOMqyjd0Wuouu9gRwayLb0LomHLmqdt5qr1BSArGHzOSEsJ(QY0xkcqMR60e(XmvpMJEXW0JNj75yCuUmaJHIB2yHaK5QonHFmt1J5O5yCuUSwzGgMcbiZgxc2qv0B6b26tAGDHLmqdt5qr1BSAbGmx1Pj8JzQEmN0OVMnSDVJyGgTprMBna0CmokNWsgOHPCOO6nwTGm3AaKcwcOpP8a9QBnhPrFv5b6vKgypPMeE88YTyg3(P0KYd0Ro0WrLm9upMN1QvAmCGNE7lffvRnT(WW0JS3BOm9LIIs)umnbmyW2onmf6fdtpEgLPVue0jWmX8KPNC27ZXyWs0lgME8m7xrr1)umfXanAFM9ROO6FkMIMJXr5YAn3IclzGgMYHIQ3y1cYCRbqA0xD7NstkpqV6qdhvY0t9yEwRwPXWbE6TVuuuT206ddtpYEVHY0xkkk9tX0eWGbB70WuOxmm94zuM(srqNaZeZtMEYzVphJblrVyy6XZSFffv)tXued0O9z2VIIQ)PykAoghLlR1ClkSKbAykhkQEJvlaKzJlbBOkPGLa6tkpqV6wZrA0xZg)W29oIm3AaO5yCuUmktFPiOtGzI5jtp5S3NJXGLOxmm94z2VIIQ)PykAoghLlV30dS1N0a7zC7NstkpqV6qdhvY0t9yEwRwPXWbE6TVuuuT206ddtpYEVHY0xkkk9tX0eWGbB70WuOxmm94zAU5ClscBUz3(P0KYd0Ro0WrLm9upM3y4ap92xkkQwBA9HHPhzVVGvR5nSPlIYTjBUz3(P0KYd0Ro0WrLm9upM3y4ap92xkkQwBA9HHPhzVVWclKvZK0klU5MZ1yr0IKWMHT7De0jWmX8KPNC27ZXyWsKtzW2fSAKCZnNRbSDVJyGgTprMBna0CmokxEVPhyRpPb2xyHfewYanmLdfvVXQfK5wdGuWsa9jLhOxDR5in6RkpqVI0a7j1KWJNxUfZ42pLMuEGE1HgoQKPN6X8Sw3qJHd80BFPOOATP1hgMEK9EMMvM(srFy8aWAyk0lgMECiGqz6lffL(PyAcyWGTDAyk0lgME8fewYanmLdfvVXQfK5wdG0OV62pLMuEGE1HgoQKPN6X8Sw3qJHd80BFPOOATP1hgMEK9EMMvM(srFy8aWAyk0lgMECiGqz6lffL(PyAcyWGTDAyk0lgME8fewYanmLdfvVXQfaYSXLGnuLuWsa9jLhOxDR5in6RzJFy7EhrMBna0Cmokxgy7EhXanAFIm3AaO5yCuU8EtpWwFsdSNXTFknP8a9QdnCujtp1J5zTUHgdh4P3(srr1AtRpmm9i79mnRm9LI(W4bG1WuOxmm94qaHY0xkkk9tX0eWGbB70WuOxmm94liSKbAykhkQEJvlcmmdL1tkyjG(KYd0RU1CKg91SXpSDVJiZTgaAoghLlZ8(ChzgMEHLmqdt5qr1BSAXWrLm9upMlSKbAykhkQEJvlCgBAQhZjfSeqFs5b6v3AosJ(A24h2U3rK5wdanhJJYjSKbAykhkQEJvlaMQtzOdRNuWsa9jLhOxDR5in6RzJFy7EhrMBna0CmokNWsgOHPCOO6nwTWrMXnBe2Eksblb0NuEGE1TMJ0OVMn(HT7DezU1aqZX4OCzAUzazEGE3kjHaISHT7Demd2IpCxrZX4OCqabSDVJGzWw8H7kAoghLlpy7EhbZGT4d3vKtzW2nZanmfkkquFy9O30dS1N0a7lSGWsgOHPCOO6nwTikquFy9KcwcOpP8a9QBnhPrFnB8dB37iYCRbGMJXr5KeU9dKqsYnHejvPkL]] )
    

end
