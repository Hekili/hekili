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
            tick_time = function () return 3 * haste end,
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

    spec:RegisterStateExpr( "havoc_remains", function ()
        return buff.active_havoc.remains
    end )

    spec:RegisterStateExpr( "havoc_active", function ()
        return buff.active_havoc.up
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
        if active_enemies == 1 then return end

        -- For Havoc, we want to cast it on a different target.
        if this_action == "havoc" then return "cycle" end

        if debuff.havoc.up or FindUnitDebuffByID( "target", 80240, "PLAYER" ) then
            return "cycle"
        end
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
                removeStack( "crashing_chaos" )
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
            cast = function ()
                if buff.chaotic_inferno.up then return 0 end
                return 2 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                removeBuff( "chaotic_inferno" )
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 - ( azerite.crashing_chaos.enabled and 15 or 0 ) end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,

            handler = function ()
                summonPet( "infernal", 30 )
                if azerite.crashing_chaos.enabled then applyBuff( "crashing_chaos", 3600, 8 ) end
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


    spec:RegisterPack( "Destruction", 20190709.1715, [[dS06obqivv6rOi2ef0NOaPrPkjNsvcRcfj9kksZcfClvjLDPIFreggLshJIyzQs1ZOuyAuG6AQs02OuK(MQk04uLs6CQsQwhLIQ5rPQ7rK2hfWbPaHfIc9qvv0evvbxKsrSrkfLpQkLqgPQukNuvkwPQWmvLsKDse9tvPeyOQsjQLIIe9uGMkkQRQkLG(kfiAVe(RIgSshM0IrPhJQjRWLr2mGptjgTQYPPA1QsP61uQmBOUTkTBj)wQHtrDCvPeQLd65qMUW1jQTRk67QQA8OiHZtjTEuKA(uO9lAHjcMfGdniHKVBRjVUT)OTV(XKF893n43QamSAMeGMvUDQfsaw6LeG)aHcOmp8UeGMvR4whcMfGOwgYjb4xeMr2CjKWIhFYShEFLa5xzSgExCOcesG8lxcbiRSJJ3ucwb4qdsi572AYRB7pA7RFm5hF)Dd(Lcqvo(AOae0V)ua(5Jbvcwb4GqCbitY9hiuaL5H3vUgKke3C7Yhmj3VimJS5siHfp(Kzp8(kbYVYyn8U4qfiKa5xUe5dMK7dzS1CFDgY9DBn51Z91Y1KF0MBYlZh5dMK7p)0YcHS55dMK7RLlOzcJZ9TuZT7KpysUVwUmL0TFs5IimWjuOfkYL)rC7ocqSJcKGzb4N(S5cMfsAIGzbivklMgcgfGCOhe0vbiRmaWHv52nGkqCg9)kxdZf1Y4j6tHJCnG0CnjxdZf1Y4j6tHJCTxAUgSau5H3LaK3fawTa1GeHqY3fmlaPszX0qWOaKd9GGUkadftvC8kiyP4jVVSYOW76qLYIPrUgMlKUQxOCTp3HmudVRCzQ5A75L5A0yU)MBOyQIJxbblfp59LvgfExhQuwmnY1WCHeaKqFklMeGkp8UeG(92yniriK0gcMfGuPSyAiyuaYHEqqxfGCffZWVuU2N7N(S5tiDvVqcqLhExcq(N2OjBJdriK0GfmlavE4DjarTmEc4qsasLYIPHGrriK8LcMfGuPSyAiyuaYHEqqxfGkp8N0Kk66ekx7Z1g5A0yU)MBOyQIdGdPPwJjl0VOOl6qLYIPHau5H3Lae9PJ(pRmSeHqsBQGzbivklMgcgfGCOhe0vbixrXm8lLR95(PpB(esx1lKau5H3La0lUxeudseIqaAgs8(YQHGzHKMiywasLYIPHGrriK8DbZcqQuwmnemkcHK2qWSaKkLftdbJIqiPblywaQ8W7saIKV3UM(1SaKkLftdbJIqi5lfmlaPszX0qWOaKd9GGUkadftvCSa9B7qA2atKYHoGZPdvklMgcqLhExcqlq)2oKMnWePCOd4CsecjTPcMfGuPSyAiyuecj)rbZcqLhExcqZD4DjaPszX0qWOies(wfmlavE4DjarTmEc4qsasLYIPHGrriK81fmlaPszX0qWOaKd9GGUka)n3qXufhulJNaoKouPSyAiavE4Dja9I7fb1GeHieGAtcMfsAIGzbivklMgcgfGCOhe0vbOzkoEbqWsXhLh(tkxdZ9v5YkdaC4qf95LLj)tB0z0)RCnAm3FZnumvXXc0VTdPzdmrYMH0v5wpuPSyAK7lY1WCFvU)MlVB8O)xNp9zZpqshwZ1OXCvE4pPjv01juUgixBK7leGkp8UeGq1RzdmbCijcHKVlywasLYIPHGrbih6bbDvao6443BJ1Goq6QEHY1a5Yvumd)scqLhExcq(NwfHNd62fGdjriK0gcMfGuPSyAiyuaQ8W7sa63BJ1GeGCOhe0vbiKUQxOCTp3xMRH5(QC)n3qXufhUgkhBfDpuPSyAKRrJ5Y7gp6)1HRHYXwr3dKUQxOCnqUq6QEHY9fcqUvoMMHcTqbsiPjIqiPblywasLYIPHGrbOYdVlbixX4PYdVRj2rHae7Oyw6LeG8bsecjFPGzbivklMgcgfGkp8UeGF6ZMla5qpiORcqLh(tAsfDDcLR95AWcqUvoMMHcTqbsiPjIqiPnvWSaKkLftdbJcqo0dc6QamumvXXc0VTdPzdmrYMH0v5wpuPSyAKRH5AMIJxaeSu8r5H)KY1WCFvUF6ZMpvE4pPCnAm3qXufhUgkhBfDpuPSyAKRrJ5gkMQ44fabR(qLYIPrUgMRYd)jnPIUoHY1(Cn4CFHau5H3LaK)PnAY24qecj)rbZcqLhExcqO61SbMaoKeGuPSyAiyuecjFRcMfGkp8UeGanxgrJPY0e0dAYs6vasLYIPHGrriK81fmlavE4DjanldDaREzzYIvuiaPszX0qWOiesAITcMfGuPSyAiyuaQ8W7sa(PpBUaKd9GGUkaFvU)MBOyQIJfOFBhsZgyIKndPRYTEOszX0ixJgZ93CdftvC8cGGvFOszX0ixJgZnumvXXc0VTdPzdmrYMH0v5wpuPSyAKRH5AMIJxaeSu8bsx1luU2lnxtSn3xia5w5yAgk0cfiHKMicHKMyIGzbivklMgcgfGCOhe0vbyOyQIdGdPPwJjl0VOOl6qLYIPrUgMlRmaWHv52nGkqCKnNRH5IAz8e9PWrU2N7lZ91Y12Z75YuZv5H)KMurxNqcqLhExcqV4ErqniriK0K3fmlavE4DjarTmEc4qsasLYIPHGrriK0eBiywasLYIPHGrbih6bbDvaYkdaCyvUDdOceNr)VeGkp8UeG8UaWQfOgKiesAIblywasLYIPHGrbih6bbDva(BUHIPkoaoKMAnMSq)IIUOdvklMgcqLhExcq0No6)SYWsecjn5LcMfGuPSyAiyuaYHEqqxfG)M7OJdVlovbudAmbW6LMSYW6aPR6fkxdZ93CvE4DD4DXPkGAqJjawV0XRja2T8f5AyUkp8N0Kk66ekx7Z9LcqLhExcqExCQcOg0ycG1ljcHKMytfmlavE4Dja9I7fb1GeGuPSyAiyueIqaYhibZcjnrWSaKkLftdbJcqLhExcqzen9GUcqo0dc6QaK3nE0)Rds(E7A6fablfFKnNRrJ5Y7gp6)1bjFVDn9cGGLIpq6QEHY1(CFPaS0ljavMg9Pqfnb6kMnW0C)NGIqi57cMfGuPSyAiyuaYHEqqxfG8UXJ(FDgk0UjQLXtVqHY6ypSEGKoSMRrJ5Y7gp6)15s3gAD2atSm3hZbK0l6ajDynxJgZ9v5(BUHIPkodfA3e1Y4PxOqzDShwpuPSyAKRH5(BUecrfNox62qRZgyIL5(yoGKErNR(2ByUVixJgZL3nE0)RZqH2nrTmE6fkuwh7H1dKUQxOCTxAUMyBUgnMlVB8O)xNlDBO1zdmXYCFmhqsVOdKUQxOCTxAUMyRau5H3LaejFVDn9cGGLIfHqsBiywasLYIPHGrbih6bbDvaAMIJxaeSu8r5H)KeGkp8UeGwKv4W1A2atLPjyhFIqiPblywasLYIPHGrbih6bbDvaAMIJxaeSu8r5H)KY1WCntXXlacwk(aPR6fkx7LM772kavE4Djahk0UjQLXtVqHY6ypSkcHKVuWSaKkLftdbJcqo0dc6Qa0mfhVaiyP4JYd)jLRH5AMIJxaeSu8bsx1luU2ln33TvaQ8W7saEPBdToBGjwM7J5as6fjcHK2ubZcqQuwmnemka5qpiORcWWV0m65WPCnqU8UXJ(FDqY3BxtVaiyP4ZqgQH3vUMMRnSvaQ8W7saIKV3UMEbqWsXIqi5pkywasLYIPHGrbih6bbDvag(LY1a5AdBZ1WCd)sZONdNY1a5Y7gp6)1XISchUwZgyQmnb747mKHA4DLRP5AdBfGkp8UeGwKv4W1A2atLPjyhFIqi5BvWSaKkLftdbJcqo0dc6QamumvXzOq7MOwgp9cfkRJ9W6HkLftJCnmxE34r)VodfA3e1Y4PxOqzDShwpq6QEHY1a5g(LMrphojavE4DjarY3BxtVaiyPyriK81fmlaPszX0qWOaKd9GGUka5DJh9)6GKV3UMEbqWsXhiDvVq5AGCd)sZONdNeGkp8UeGwKv4W1A2atLPjyhFIqiPj2kywasLYIPHGrbih6bbDvaY7gp6)1bjFVDn9cGGLIpq6QEHY1a5g(LMrphojavE4Djahk0UjQLXtVqHY6ypSkcHKMyIGzbivklMgcgfGCOhe0vbiVB8O)xhK89210lacwk(aPR6fkxdKB4xAg9C4Kau5H3La8s3gAD2atSm3hZbK0lsecjn5DbZcqQuwmnemka5qpiORcWWV0m65WPCTpxByRau5H3LaejFVDn9cGGLIfHqstSHGzbivklMgcgfGCOhe0vby4xAg9C4uU2NRnSvaQ8W7saArwHdxRzdmvMMGD8jcHKMyWcMfGuPSyAiyuaYHEqqxfGHFPz0ZHt5AFUVBRau5H3LaCOq7MOwgp9cfkRJ9WQiesAYlfmlaPszX0qWOaKd9GGUkad)sZONdNY1(CF3wbOYdVlb4LUn06SbMyzUpMdiPxKiesAInvWSau5H3LaKf39y2aZ4JMurxRcqQuwmnemkcHKM8JcMfGkp8UeG)BiE8K8AcjuxAXjbivklMgcgfHqstERcMfGkp8UeGq3Szmn9AImRCsasLYIPHGrriK0KxxWSaKkLftdbJcqo0dc6Qa0mfhVaiyP4JYd)jLRrJ5gk0cfNWV0m65WPCTpxByRau5H3La0ChExIqi572kywasLYIPHGrbih6bbDvaAMIJxaeSu8r5H)KY1OXCzLbaox62qRZgyIL5(yoGKErhiDvVq5A0yUSYaaNHcTBIAz80luOSo2dRhiDvVq5A0yUHFPz0ZHt5AFU2WwbOYdVlbilbre0oVSicHKVBIGzbivklMgcgfGCOhe0vbOzkoEbqWsXhLh(tkxJgZLvga4CPBdToBGjwM7J5as6fDG0v9cLRrJ5YkdaCgk0UjQLXtVqHY6ypSEG0v9cLRrJ5g(LMrphoLR95AdBfGkp8UeGS4UhtazOvriK893fmlaPszX0qWOaKd9GGUkantXXlacwk(O8WFs5A0yUSYaaNlDBO1zdmXYCFmhqsVOdKUQxOCnAmxwzaGZqH2nrTmE6fkuwh7H1dKUQxOCnAm3WV0m65WPCTpxByRau5H3LaeWHelU7Hies(UnemlaPszX0qWOaKd9GGUkantXXlacwk(O8WFs5A0yUSYaaNlDBO1zdmXYCFmhqsVOdKUQxOCnAmxwzaGZqH2nrTmE6fkuwh7H1dKUQxOCnAm3WV0m65WPCTpxByRau5H3LaugrtpOlseIqaoiavghcMfsAIGzbOYdVlbiYmHXtCZTtasLYIPHGrriK8DbZcqLhExcqKxwO5vT4CbivklMgcgfHqsBiywasLYIPHGrbih6bbDva(PpB(u5H)KY1WCvE4pPjv01juU2N7lZ91YnumvXXlacw9HkLftJCnn3xLBOyQIJxaeS6dvklMg5AyUHIPkoEfeSu8K3xwzu4DDOszX0i3xiavE4Dja5kgpvE4DnXokeGyhfZsVKa8tF2CriK0GfmlavE4Dja5AOCSv0vasLYIPHGrriK8LcMfGuPSyAiyuaYHEqqxfGkp8N0Kk66ekxdK77cqLhExcqUIXtLhExtSJcbi2rXS0lja1MeHqsBQGzbivklMgcgfGkp8UeG(92ynibih6bbDvacjaiH(uwmLRH5(QC)n3qXufhUgkhBfDpuPSyAKRrJ5Y7gp6)1HRHYXwr3dKUQxOCnqUq6QEHY9fcqUvoMMHcTqbsiPjIqi5pkywasLYIPHGrbih6bbDvagkMQ44vqWsXtEFzLrH31HkLftJCnmxLhExh(N2OjBJJJxtaSB5lY1WCH0v9cLR95oKHA4DLltnxBpVuaQ8W7sa63BJ1GeHqY3QGzbivklMgcgfGkp8UeGCfJNkp8UMyhfcqSJIzPxsaYhiriK81fmlaPszX0qWOaKd9GGUka)nxZuC8cGGLIpkp8NuUgnM7V5gkMQ4yb632H0SbMizZq6QCRhQuwmneGkp8UeGanxgrJPY0e0dAYs6vecjnXwbZcqQuwmnemka5qpiORcqwzaGdK42HjeAc0qoDGKYdbOYdVlby8rt5ITLRXeOHCsecjnXebZcqLhExcqZYqhWQxwMSyffcqQuwmnemkcHKM8UGzbivklMgcgfGCOhe0vb4V5o64W7Itva1GgtaSEPjRmSoq6QEHY1WC)nxLhExhExCQcOg0ycG1lD8AcGDlFHau5H3LaK3fNQaQbnMay9sIqiPj2qWSau5H3LaK)Pvr45GUDb4qsasLYIPHGrriK0edwWSaKkLftdbJcqLhExcWp9zZfGCOhe0vb4RYD0XXV3gRbDG0v9cLRbYD0XXV3gRbDgYqn8UYLPMRTNxMRrJ5(BUHIPkoEfeSu8K3xwzu4DDOszX0i3xKRH5(QC)nxE34r)Voi57TRPxaeSu8bs6WAUgnM7V5gkMQ4yb632H0SbMizZq6QCRhQuwmnY1OXCdftvCSa9B7qA2atKSziDvU1dvklMg5AyUMP44fablfFG0v9cLR9sZ1eBZ9fcqUvoMMHcTqbsiPjIqiPjVuWSau5H3Lae1Y4jGdjbivklMgcgfHqstSPcMfGuPSyAiyuaYHEqqxfGSYaahwLB3aQaXz0)RCnmxulJNOpfoY1asZ1KZlZ91Y12JnYLPMBOyQIdawrF9tcEOszX0ixdZ93CFQqxzX0XC34jQLXt0NchibOYdVlbiVlaSAbQbjcHKM8JcMfGuPSyAiyuaYHEqqxfGOwgprFkCKR95(EUgM7RY93CFQqxzX0XC34jQLXt0NchOCnAmx(NcTqOCnqUMK7leGkp8UeGOpD0)zLHLiesAYBvWSaKkLftdbJcW2SaerHau5H3La8PcDLftcWNkwMeGkp8N0Kk66ekxdKRj5AyU8UXJ(FD(0Nn)aPR6fkx7LMRj2MRrJ5Y7gp6)1bjFVDn9cGGLIpq6QEHY1EP5(UT5AyUVk3qXufhlq)2oKMnWejBgsxLB9qLYIPrUgnMBOyQIZqH2nrTmE6fkuwh7H1dvklMg5AyU8UXJ(FDgk0UjQLXtVqHY6ypSEG0v9cLR9sZ9DBZ9f5A0yUHIPkodfA3e1Y4PxOqzDShwpuPSyAKRH5Y7gp6)1zOq7MOwgp9cfkRJ9W6bsx1luU2ln33TnxdZ9v5Y7gp6)1bjFVDn9cGGLIpq6QEHY1a5g(LMrphoLRrJ5Y7gp6)1bjFVDn9cGGLIpq6QEHY10C5DJh9)6GKV3UMEbqWsXNHmudVRCnqUHFPz0ZHt5(cb4tfol9scqZDJNOwgprFkCGeHqstEDbZcqQuwmnemka5qpiORcWxLBOyQIJfOFBhsZgyIKndPRYTEOszX0ixJgZvzAc6bD4qf95LLj)tB0HkLftJCFrUgMRzkoEbqWsXhLh(tkxJgZLvga4muODtulJNEHcL1XEy9iBoxJgZLvga4ajUDycHManKthiP8ixdZLvga4ajUDycHManKthiDvVq5AGC5kkMHFjbOYdVlbi)tB0KTXHies(UTcMfGuPSyAiyuaYHEqqxfG)M7tf6klMoM7gprTmEI(u4aLRH5(BUHIPkoeuhoxdVRdvklMgcqLhExcq(N2OjBJdriK8DtemlaPszX0qWOaKd9GGUka)n3Nk0vwmDm3nEIAz8e9PWbkxdZnumvXHG6W5A4DDOszX0ixdZ9v5oiwzaGdb1HZ1W76aPR6fkx7ZLROyg(LY1OXCzLbaoSk3UbubIJS5CFHau5H3LaK)PnAY24qecjF)DbZcqQuwmnemka5qpiORcWxLlQLXt0Nch5AaP5AWNxM7RLRTN3ZLPMRYd)jnPIUoHY9fcqLhExcq(N2OjBJdriK8DBiywasLYIPHGrbih6bbDvaY)uOfcLRbY1ebOYdVlbiVlaSAbQbjcHKVBWcMfGkp8UeGEX9IGAqcqQuwmnemkcricb4tcI8Ues(UTM862AdBF)yY7gSjcW)kS8Ycsa(MR5gg0i3xMRYdVRCXokqN8Ha0mSbCmjazsU)aHcOmp8UY1GuH4MBx(Gj5(fHzKnxcjS4XNm7H3xjq(vgRH3fhQaHei)YLiFWKCFiJTM7RZqUVBRjVEUVwUM8J2CtEz(iFWKC)5NwwiKnpFWKCFTCbntyCUVLAUDN8btY91YLPKU9tkxeHboHcTqrU8pIB3jFKpysU2eMcIlh0ixwcOHuU8(YQrUSKfVqNCni4CYCGYT661(u4fqgNRYdVluUDHTEYhkp8UqhZqI3xwnKcGvKD5dLhExOJziX7lRgMkvcGUh5dLhExOJziX7lRgMkvcv2YLQqdVR8HYdVl0XmK49LvdtLkbs(E7AAMI8HYdVl0XmK49LvdtLkHfOFBhsZgyIuo0bCoXGdinumvXXc0VTdPzdmrkh6aoNouPSyAKpuE4DHoMHeVVSAyQujqLAg91XefAGYhkp8UqhZqI3xwnmvQeM7W7kFO8W7cDmdjEFz1WuPsGAz8eWHu(q5H3f6ygs8(YQHPsLWlUxeudIbhq6VHIPkoOwgpbCiDOszX0iFKpysU2eMcIlh0ix6jbTMB4xk34JYv5rdZ1r5QpvhRSy6KpuE4DHKImty8e3C7Yhkp8UqMkvcKxwO5vT488r(Gj5(20NnpxzeHYvZfzM4UIZ1m0BOhwZf7Oi3UY92Oi3Rmo8qHwOixeNkf6nIHCzLJCJpk3qHwOi34dsOVgpYLRvUpvO1ChKzQgEzj3UYnumvbkFO8W7cjLRy8u5H31e7OGHsVK0p9zZzWbK(PpB(u5H)Kmu5H)KMurxNq2)YxlumvXXlacw9HkLftdtFvOyQIJxaeS6dvklMgggkMQ44vqWsXtEFzLrH31HkLftJxKpysU)udLJTIU5I(Az8ixwkxzenYTRC5DJh9)kxfLlQ7kxfLR5gHCwmLpuE4DHmvQeCnuo2k6MpysUm)VZnuOfkYfXPsHEJYvHuUFAnW0ixSBhLlYllyk3qHwOi3)E8L7BtF28C)t6tAKRxNCbdfgEzj3)E8LB8bjk3qHwOaXqUAUiZe3vSZ00ixdI2MKRzO3qpSMRJYfsVfl7qAKpuE4DHmvQeCfJNkp8UMyhfmu6LKQnXGdiv5H)KMurxNqg498btY9n3BJ1GYf91Y4rUf9KG5cOyCUnaqUXhLRzOFvO1CdfAHItUVbi3FQHYXwr3C)7yCUqcasOVCFZ92ynOCzjGgs56rUetHzhsigYn(iizqr5wDUqsrDLB05(xrbLB4xkxUIcVSKRh5dLhExitLkHFVnwdIbUvoMMHcTqbsQjm4asHeaKqFklMm8v)gkMQ4W1q5yRO7HkLftdJg5DJh9)6W1q5yRO7bsx1lKbG0v9c9I8btYLjgKE8L7BQGGLIZ9N9LvgfEx5gkMQGgmKRhguuUMBeYzXuUV5EBSguU)Dmo3IOrUrNllLlKaGe6Jg5I6UiyUXNw5gFuUq6QE5LLChYqn8UYfPwrmKRdKB8rqYGIYvXqshwZvZ9NFAJYLXgh52vUXhL7F1AUrNB8r5gk0cfN8HYdVlKPsLWV3gRbXGdinumvXXRGGLIN8(YkJcVRdvklMggQ8W76W)0gnzBCC8AcGDlFHHq6QEHSFid1W7IPA75L5dMKlZFuUwOIGkoxOmMYTbYn(KVS5c0WCdftvGY1r5gDUxLPWVott5gFuUL8LLG52a5kJiuUnqUKY)Yhkp8UqMkvcUIXtLhExtSJcgk9ss5du(q5H3fYuPsa0CzenMkttqpOjlPxgCaP)AMIJxaeSu8r5H)KmA83qXufhlq)2oKMnWejBgsxLB9qLYIPr(q5H3fYuPseF0uUyB5AmbAiNyWbKYkdaCGe3omHqtGgYPdKuEKpuE4DHmvQeMLHoGvVSmzXkkYhkp8UqMkvcExCQcOg0ycG1lXGdi93rhhExCQcOg0ycG1lnzLH1bsx1lKH)Q8W76W7Itva1GgtaSEPJxtaSB5lYhkp8UqMkvc(NwfHNd62fGdP8btYL5pkxhixExdp8UY9JGuUk(VAfLRA2m2juUVn9zZZn6Cr9LIpVSKBhFem34tRCJpkxZq)QqR5gk0cf5dLhExitLkXN(S5mWTYX0muOfkqsnHbhq6RgDC87TXAqhiDvVqgy0XXV3gRbDgYqn8UyQ2EEPrJ)gkMQ44vqWsXtEFzLrH31HkLftJxy4R(L3nE0)Rds(E7A6fablfFGKoSA04VHIPkowG(TDinBGjs2mKUk36HkLftdJgdftvCSa9B7qA2atKSziDvU1dvklMggAMIJxaeSu8bsx1lK9snX2xKpysUGTmoxBMdPCrFTmEKllLRmIg52vU8UXJ(FXqUEK7OjuUvh5QMntkm3)nm(YfPp9YsUanmxlurqn8YsUGTmoxWpfoq5oKHEzjxE34r)Vq5dLhExitLkbQLXtahs5dMK7p7caRwGAq5I(Az8i3UWwZLLYvgrJCJoxef5kBo3F(PnkxgBCGo5AZWk6RFsWCXuGY9NDbGvlqnOCzPCLr0ixsHyNG5gDUikYv2CUAL7BkUxeudkxwcOHuU)KXtUVbixn3R(2ByU8UXJ(FLRJYL3xVSKRSzgYfPpPC5Fk0cHYfOH56r(q5H3fYuPsW7caRwGAqm4aszLbaoSk3UbubIZO)xgIAz8e9PWHbKAY5LVMThBWudftvCaWk6RFsWdvklMgg(7tf6klMoM7gprTmEI(u4aLpysUGF6O)ZkdRCDuUYiAKRIYvZD4iElxrU)SlaSAbQbLB05AHkcQbLl6tHduUoqUwB5ChDzqJC)0NuUu1Yw(YfOH5Q5(ZpTr5YyJJtUm)r5I0lLlugtOCv2woYfPp9YsUEKlqdZ9QV9gMlVB8O)xOCvZMXoHYhkp8UqMkvc0No6)SYWIbhqkQLXt0Nch2)UHV63Nk0vwmDm3nEIAz8e9PWbYOr(NcTqidyYlYhmj33eguuU)By8LlkAUDEzjxzZ52vUGTmoxWpfoq5YsanKYvZ9QV9gMlVB8O)x5kJulu(q5H3fYuPs8uHUYIjgk9ssn3nEIAz8e9PWbIHNkwMKQ8WFstQORtidyIH8UXJ(FD(0Nn)aPR6fYEPMyRrJ8UXJ(FDqY3BxtVaiyP4dKUQxi7L(UTg(QqXufhlq)2oKMnWejBgsxLB9qLYIPHrJHIPkodfA3e1Y4PxOqzDShwpuPSyAyiVB8O)xNHcTBIAz80luOSo2dRhiDvVq2l9DBFHrJHIPkodfA3e1Y4PxOqzDShwpuPSyAyiVB8O)xNHcTBIAz80luOSo2dRhiDvVq2l9DBn8v8UXJ(FDqY3BxtVaiyP4dKUQxide(LMrphoz0iVB8O)xhK89210lacwk(aPR6fYuE34r)Voi57TRPxaeSu8zid1W7YaHFPz0ZHtViFWKC)5N2OCzSXrUFkkxe9KGkoxZnc5SykxzeLlVRHhExOtU)eQOpVSK7p)0gXqUVfb9B7qk3gixqzZq6QCRmKRwJC)bfAxUGTm2MN7BkuOSo2dR5QyCUa6ZgMlxrHxwYvr5E1YAU)KruUkkxZnc5Syk3)FuLRwwZTbYn(OBUkKYv5H)KYhkp8UqMkvc(N2OjBJdgCaPVkumvXXc0VTdPzdmrYMH0v5wpuPSyAy0OY0e0d6WHk6Zllt(N2OdvklMgVWqZuC8cGGLIpkp8NKrJSYaaNHcTBIAz80luOSo2dRhzZgnYkdaCGe3omHqtGgYPdKuEyiRmaWbsC7WecnbAiNoq6QEHmaxrXm8lLpysUVbixWwgNl4NchOCviLB1rUSKxwY1C3yAKRwJCTjqD4Cn8UY1r5wDKBOyQcAWqUVDzuKlYmvJC)jJOCvuUXhznxwI3xkx9P6yLft5dLhExitLkb)tB0KTXbdoG0FFQqxzX0XC34jQLXt0Nchid)numvXHG6W5A4DDOszX0iFWKCni94lxBcuhoxdVlgY1ddkkxwQiaN7ko3OZ9Qmf(1zAk34JYv2C4xk3UYn(OCheRmaWj33w)NEsqgY1ddkkxu4yCUSueem3OZvgr5(ZpTr5YyJJC97LgUge2AUoqUmQC7gqfiY1r5kBoFO8W7czQuj4FAJMSnoyWbK(7tf6klMoM7gprTmEI(u4azyOyQIdb1HZ1W76qLYIPHHVAqSYaahcQdNRH31bsx1lK9CffZWVKrJSYaahwLB3aQaXr28lYhmjxBYtQY9)hv5I0NEzHHChDUvh52pjixnNBx5c2Y4Cb)u4aLpuE4DHmvQe8pTrt2ghm4asFfQLXt0NchgqQbFE5Rz75DMQYd)jnPIUoHEr(Gj5(dDzqJC7NeKRMZTRC5Fk0cHYTbY9NDbGvlqnO8HYdVlKPsLG3fawTa1GyWbKY)uOfczatYhkp8UqMkvcV4ErqnO8r(Gj5YuQELBdKRnZHuUok3WQzNRyS1CJpk3p3YhHICnd9g6H1CvE4DXqUSYrUCcgQx5I8qwdVluUa6ZgMRmYll5(ZpTr5YyJJC9cfKoYhkp8UqhTjPq1RzdmbCiXGdi1mfhVaiyP4JYd)jz4RyLbaoCOI(8YYK)Pn6m6)LrJ)gkMQ4yb632H0SbMizZq6QCRhQuwmnEHHV6xE34r)VoF6ZMFGKoSA0OYd)jnPIUoHmGnEr(Gj5(ZpTkcN7pq3UaCiLBxyR5wenq52fL7BU3gRbLRYd)jL7qg6LLC9aLlxrrUanmxdI2MCY9Tm0Vk0AUHcTqrUokxzenY9JGuUanmxKFnJDUhwZhkp8UqhTjtLkb)tRIWZbD7cWHedoG0rhh)EBSg0bsx1lKb4kkMHFP8btYf0VowH5gDUiVSGPCdfAHcgYn(iiLRJYT6ClIg5gDUqcasOVCFZ92yniuUoqU)udLJTIU5Y1k3rNRh56fkiDKpuE4DHoAtMkvc)EBSgedCRCmndfAHcKutyWbKcPR6fY(xA4R(numvXHRHYXwr3dvklMggnY7gp6)1HRHYXwr3dKUQxidaPR6f6f5dMKltPmMq5c0WC5DJh9)cL7OZT6ix(NwwOCbAyUgeTnHHCrDUCfJZn(OCr6LYf7OixfLBx5I8YcMYnuOfkYhkp8UqhTjtLkbxX4PYdVRj2rbdLEjP8bkFWKCz(dsuUHcTqbkxhLRw561RXsXFIQC5kIYn(0ixl(tcLRMlc7w(ICzPIa8i3OZ9ZT8rWCnd9g6H1CFB6ZMNpuE4DHoAtMkvIp9zZzGBLJPzOqluGKAcdoGuLh(tAsfDDczVbNpysUmLQx52a5AZCiL7FhJZffkmYn6Ch91lnOC7k3psFAnxdI2MWqUSYrUO(s5IClLd4CTIC)5N2OCzSXrUSYaaOC)7yCUOWX4CT4pPC)ClFem3HEvluUTCywoYTRCBoxrEx5dLhExOJ2KPsLG)PnAY24GbhqAOyQIJfOFBhsZgyIKndPRYTEOszX0WqZuC8cGGLIpkp8NKHV6tF28PYd)jz0yOyQIdxdLJTIUhQuwmnmAmumvXXlacw9HkLftddvE4pPjv01jK9g8lYhmjxgvi0ll5QL1CjMcozo8UqmKltP6vUnqU2mhs5(3X4CzPCLr0ixfL7vM)LRIY1CJqolMyixKxCk3RmoCZykxEB2juUnqUEKlxRCrHYTlFO8W7cD0MmvQeq1RzdmbCiLpuE4DHoAtMkvcGMlJOXuzAc6bnzj9MpuE4DHoAtMkvcZYqhWQxwMSyff5dMKRn5jv56a5gFuUVn9zZZ1m0BOhwZf7Oi3)DzqJCzPCLr0GHCFB6ZMNRJY1mKIWAUxz(xUaqIYDOx1cLRwJCHeQLHCcLRwJCrFTmEKllLRmIg5Q4BJIC7kxE34r)VYhkp8UqhTjtLkXN(S5mWTYX0muOfkqsnHbhq6R(numvXXc0VTdPzdmrYMH0v5wpuPSyAy04VHIPkoEbqWQpuPSyAy0yOyQIJfOFBhsZgyIKndPRYTEOszX0WqZuC8cGGLIpq6QEHSxQj2(I8btY9TqeLRnZHuUAnYLrOFrrxuUoqUmQC7gqfiY1r5Q8WFsmKRIYf3LLCvuUEK7FhJZT6i3(jb5Q5C7kxWwgNl4NchO8HYdVl0rBYuPs4f3lcQbXGdinumvXbWH0uRXKf6xu0fDOszX0WqwzaGdRYTBavG4iB2qulJNOpfoS)LVMTN3zQkp8N0Kk66ekFWKCFli(iyUGTmoxWpfoY1cveudVSKRY6ypCcLRcPCT09ixahJjyUoqUvh5kJ8YsU2mhs5Q1ixgH(ffDr5dLhExOJ2KPsLa1Y4jGdP8HYdVl0rBYuPsW7caRwGAqm4aszLbaoSk3UbubIZO)x5dLhExOJ2KPsLa9PJ(pRmSyWbK(BOyQIdGdPPwJjl0VOOl6qLYIPr(q5H3f6OnzQuj4DXPkGAqJjawVedoG0FhDC4DXPkGAqJjawV0KvgwhiDvVqg(RYdVRdVlovbudAmbW6LoEnbWULVWqLh(tAsfDDcz)lZhmjxdsp(Y1M5qkxTg5Yi0VOOlIHCFtX9IGAq5(3X4CzPC1CrbSll5c4ymbp5(MWGIY1mw50i3pcs5c0WCvmo3qXufOCJoxZq6jvrUkN7dQcfJTMRmYll5gFuUiVSGPCdfAHICHDOH3vUyhf5dLhExOJ2KPsLWlUxeudkFKpuE4DHo8bsQmIMEqxgk9ssvMg9Pqfnb6kMnW0C)NGm4as5DJh9)6GKV3UMEbqWsXhzZgnY7gp6)1bjFVDn9cGGLIpq6QEHS)L5dMK7BaYLTJVC5DJh9)cLRcPCHKoSYqUi57TRCJpk33uaeSuCUXhv5Q8WFQbL7pa(MtUVbi3QJCLrEzj3Fa8nmKRmIYn(CuUDL7p)H8HYdVl0HpqMkvcK89210lacwkMbhqkVB8O)xNHcTBIAz80luOSo2dRhiPdRgnY7gp6)15s3gAD2atSm3hZbK0l6ajDy1OXx9BOyQIZqH2nrTmE6fkuwh7H1dvklMgg(lHquXPZLUn06SbMyzUpMdiPx05QV9g(cJg5DJh9)6muODtulJNEHcL1XEy9aPR6fYEPMyRrJ8UXJ(FDU0THwNnWelZ9XCaj9Ioq6QEHSxQj2MpuE4DHo8bYuPsyrwHdxRzdmvMMGD8XGdi1mfhVaiyP4JYd)jLpuE4DHo8bYuPsmuODtulJNEHcL1XEyLbhqQzkoEbqWsXhLh(tYqZuC8cGGLIpq6QEHSx672MpuE4DHo8bYuPsCPBdToBGjwM7J5as6fXGdi1mfhVaiyP4JYd)jzOzkoEbqWsXhiDvVq2l9DBZhmj33aK7pa(MCDuUvh5cjDynxw5ixRTCUCTY1cf5EBiLB8PvUDr56fablfNRx5YsanKYn(OCPAKBdKB8r5c4w(cgYfjFVDLB8r5(McGGLIZT6)5dLhExOdFGmvQei57TRPxaeSumdoG0WV0m65WjdW7gp6)1bjFVDn9cGGLIpdzOgExMAdBZhkp8Uqh(azQujSiRWHR1SbMkttWo(yWbKg(LmGnS1WWV0m65WjdW7gp6)1XISchUwZgyQmnb747mKHA4DzQnSnFWKCFdqUXhLlGB5lY9VJX5s1ixwcOHuU)a4BY1r5YQC7Yv2md5IKV3UYn(OCFtbqWsX5dLhExOdFGmvQei57TRPxaeSumdoG0qXufNHcTBIAz80luOSo2dRhQuwmnmK3nE0)RZqH2nrTmE6fkuwh7H1dKUQxide(LMrphoLpuE4DHo8bYuPsyrwHdxRzdmvMMGD8XGdiL3nE0)Rds(E7A6fablfFG0v9czGWV0m65WP8btY9na5gFuUaULVi3)ogNlvJCzjGgs56fablfNRJYLv52LRSzgYvgr5(dGVjFO8W7cD4dKPsLyOq7MOwgp9cfkRJ9WkdoGuE34r)Voi57TRPxaeSu8bsx1lKbc)sZONdNYhkp8Uqh(azQujU0THwNnWelZ9XCaj9IyWbKY7gp6)1bjFVDn9cGGLIpq6QEHmq4xAg9C4u(Gj5(gGCJpkxa3YxKRJYvzB5i3OZLQbd5kJOC)5pGYfjZ)Yn(0i34JSMRfkYvr5EL5F5g(LYv2CUkkxZnc5SykFO8W7cD4dKPsLajFVDn9cGGLIzWbKg(LMrphozVnSnFO8W7cD4dKPsLWISchUwZgyQmnb74JbhqA4xAg9C4K92W28HYdVl0HpqMkvIHcTBIAz80luOSo2dRm4asd)sZONdNS)DBZhkp8Uqh(azQujU0THwNnWelZ9XCaj9IyWbKg(LMrphoz)72MpuE4DHo8bYuPsWI7EmBGz8rtQOR18HYdVl0HpqMkvI)nepEsEnHeQlT4u(q5H3f6WhitLkb0nBgttVMiZkNYhkp8Uqh(azQujm3H3fdoGuZuC8cGGLIpkp8NKrJHcTqXj8lnJEoCYEByB(q5H3f6WhitLkblbre0oVSWGdi1mfhVaiyP4JYd)jz0iRmaW5s3gAD2atSm3hZbK0l6aPR6fYOrwzaGZqH2nrTmE6fkuwh7H1dKUQxiJgd)sZONdNS3g2MpuE4DHo8bYuPsWI7EmbKHwzWbKAMIJxaeSu8r5H)KmAKvga4CPBdToBGjwM7J5as6fDG0v9cz0iRmaWzOq7MOwgp9cfkRJ9W6bsx1lKrJHFPz0ZHt2BdBZhkp8Uqh(azQujaCiXI7EWGdi1mfhVaiyP4JYd)jz0iRmaW5s3gAD2atSm3hZbK0l6aPR6fYOrwzaGZqH2nrTmE6fkuwh7H1dKUQxiJgd)sZONdNS3g2MpuE4DHo8bYuPsiJOPh0fXGdi1mfhVaiyP4JYd)jz0iRmaW5s3gAD2atSm3hZbK0l6aPR6fYOrwzaGZqH2nrTmE6fkuwh7H1dKUQxiJgd)sZONdNS3g2MpYhkp8UqNp9zZLY7caRwGAqm4aszLbaoSk3UbubIZO)xgIAz8e9PWHbKAIHOwgprFkCyVudoFO8W7cD(0Nn3uPs43BJ1GyWbKgkMQ44vqWsXtEFzLrH31HkLftddH0v9cz)qgQH3ft12ZlnA83qXufhVccwkEY7lRmk8UouPSyAyiKaGe6tzXu(q5H3f68PpBUPsLG)PnAY24GbhqkxrXm8lz)N(S5tiDvVq5dLhExOZN(S5MkvculJNaoKYhkp8UqNp9zZnvQeOpD0)zLHfdoGuLh(tAsfDDczVnmA83qXufhahstTgtwOFrrx0HkLftJ8HYdVl05tF2CtLkHxCViOgedoGuUIIz4xY(p9zZNq6QEHeGiZexi5720FueIqiaa]] )


end
