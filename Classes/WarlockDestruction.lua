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

        potion = "unbridled_fury",

        package = "Destruction",
    } )


    spec:RegisterPack( "Destruction", 20190722, [[dO0lvbqiuKEervTjIkFIkvXOOsQtrLkRcLqEfvkZcK6wOeQDPu)cLQHHI6yuLAzQI8muIMgvQQRrLKTHsqFtvcmouc05iQsToIQeZJQK7Hc7tvshKOkPfIs6HevXerrOlsLQ0grrGpQkbLgjkc6KQs0kvLANuj(PQeu1qvLGILQkHYtb1urPCvvjOYxvLGSxc)vjdwLdtAXuXJr1KL4YiBwv9zQQgnionLvJsaVwvuZgQBlPDl63snCQIJRkHQLd8Citx46ez7QcFhKmEvjKZtvz9OiA(eL9RyH3c2eWfniHlpXS3YBMFbp90MzMDFwO3SqbC4ZdjG9O8Nv)Kao1kjGzIekas8W6ua7r9HBTiytaJAjaNeWqIWdsEHD29BbejNnVRSJSQewdRtoq)b7iRYzxa7iz44LPWrax0GeU8eZElVz(f80tBMz29D1tSqbSkfqAGag2QYJagIvkukCeWfcXfWYFoMiHcGepSoN7fsb4M)88w(Zbjcpi5f2z3VfqKC28UYoYQsynSo5a9hSJSkN95T8N7Te23Cp5n0Z9eZElVNJfp3tmlVWsMfWydfibBcyi6JMlyt4I3c2eWuQoyQiyvaZbwqatfWos))2r5pxa6p2LgQCo5Md1s4fcIckZ9kJ58Eo5Md1s4fcIckZ5fJ5CFbSYdRtbmVZpw9d0GeHWLNeSjGPuDWurWQaMdSGaMkGdftzSTmiqQ4fVRosOW6CtP6GPYCYnhGQQLO58AUIeqdRZ5yrZX82vZjt2CmDUqXugBldcKkEX7QJekSo3uQoyQmNCZbOpGqquhmjGvEyDkGTATXAqIq4clfSjGPuDWurWQaMdSGaMkG5kkwHvP58Aoi6JMVauvTejGvEyDkG5q0gTCACicHlUVGnbSYdRtbmQLWRVbibmLQdMkcwfHWfxjytatP6GPIGvbmhybbmvaR8WEqlkPQrO58AowoNmzZX05cftzS)gGwAwwoaRIIoPnLQdMkcyLhwNcyeeT0q5ibsriCHfkytatP6GPIGvbmhybbmvaZvuScRsZ51Cq0hnFbOQAjsaR8W6uaBj3scObjcriG9aiExD0qWMWfVfSjGvEyDkGrs1ANlR6ratP6GPIGvriC5jbBcykvhmveSkG5aliGPc4qXugB)aR2gGw9FHuoW(gN2uQoyQiGvEyDkG9dSABaA1)fs5a7BCsecxyPGnbSYdRtbSNoSofWuQoyQiyvecxCFbBcyLhwNcyulHxFdqcykvhmveSkcHlUsWMaMs1btfbRcyoWccyQaMPZfkMYyJAj86BaAtP6GPIaw5H1Pa2sULeqdseIqaRnjyt4I3c2eWuQoyQiyvaZbwqatfWEOyB5NaPI3kpSh0CYnNRNZr6)3CGIGyP)fhI2ODPHkNtMS5y6CHIPm2(bwTnaT6)cj5bqvL7BtP6GPYCUBo5MZ1ZX054DJlnu5gI(O5BaPfFZjt2CkpSh0IsQAeAUxNJLZ5obSYdRtbmqTC1)13aKieU8KGnbmLQdMkcwfWCGfeWubCPJTvRnwdAdOQAjAUxNJROyfwLeWkpSofWCiAMeEvOANFdqIq4clfSjGPuDWurWQaw5H1Pa2Q1gRbjG5aliGPcyavvlrZ51CUAo5MZ1ZX05cftzS5AOCSpuDtP6GPYCYKnhVBCPHk3Cnuo2hQUbuvTen3RZbOQAjAo3jG5(4yAfkWpfiHlElcHlUVGnbmLQdMkcwfWkpSofWCfJxkpSoxydfcySHIvQvsaZliriCXvc2eWuQoyQiyvaR8W6uadrF0CbmhybbmvaR8WEqlkPQrO58Ao3xaZ9XX0kuGFkqcx8wecxyHc2eWuQoyQiyvaZbwqatfWHIPm2(bwTnaT6)cj5bqvL7BtP6GPYCYnNhk2w(jqQ4TYd7bnNCZ565GOpA(s5H9GMtMS5cftzS5AOCSpuDtP6GPYCYKnxOykJTLFcK9Ms1btL5KBoLh2dArjvncnNxZ5(Z5obSYdRtbmhI2OLtJdriC5fiytaR8W6uadulx9F9najGPuDWurWQieUWckytaR8W6ua)BUeIklLjjGf0YH0QaMs1btfbRIq4I8wWMaw5H1Pa2JeW((S0)YbROqatP6GPIGvriCXBMfSjGPuDWurWQaw5H1PagI(O5cyoWccyQa21ZX05cftzS9dSABaA1)fsYdGQk33Ms1btL5KjBoMoxOykJTLFcK9Ms1btL5KjBUqXugB)aR2gGw9FHK8aOQY9TPuDWuzo5MZdfBl)eiv8gqv1s0CEXyoVzEo3jG5(4yAfkWpfiHlElcHlE7TGnbmLQdMkcwfWCGfeWubCOykJ93a0sZYYbyvu0jTPuDWuzo5MZr6)3ok)5cq)XwYZCYnhQLWleefuMZR5C1CS45yE)0CSO5uEypOfLu1iKaw5H1Pa2sULeqdsecx8(jbBcyLhwNcyulHxFdqcykvhmveSkcHlEZsbBcykvhmveSkG5aliGPcyhP)F7O8Nla9h7sdvkGvEyDkG5D(XQFGgKieU4T7lytatP6GPIGvbmhybbmvaZ05cftzS)gGwAwwoaRIIoPnLQdMkcyLhwNcyeeT0q5ibsriCXBxjytatP6GPIGvbmhybbmvaZ05kDS5DYPmaAqL1hRvA5ibYnGQQLO5KBoMoNYdRZnVtoLbqdQS(yTsBlxFS5hsmNCZP8WEqlkPQrO58AoxjGvEyDkG5DYPmaAqL1hRvsecx8MfkytaR8W6uaBj3scObjGPuDWurWQieHaMxqc2eU4TGnbmLQdMkcwfWkpSofWktIGOafT(DgR(V80qrabmhybbmvaZ7gxAOYnsQw7Cz5NaPI3sEMtMS54DJlnu5gjvRDUS8tGuXBavvlrZ51CUsaNALeWktIGOafT(DgR(V80qrariC5jbBcykvhmveSkG5aliGPcyE34sdvUlk45fQLWllrH6yyl8TbKw8nNmzZX7gxAOYDLQnW3Q)lSe3kRcG0kAdiT4BozYMZ1ZX05cftzSlk45fQLWllrH6yyl8TPuDWuzo5MJPZrieLCAxPAd8T6)clXTYQaiTI2vLfObZ5U5KjBoE34sdvUlk45fQLWllrH6yyl8TbuvTenNxmMZBMNtMS54DJlnu5Us1g4B1)fwIBLvbqAfTbuvTenNxmMZBMfWkpSofWiPATZLLFcKkwecxyPGnbmLQdMkcwfWCGfeWubShk2w(jqQ4TYd7bjGvEyDkG9lPGIP5Q)lLjjqhqeHWf3xWMaMs1btfbRcyoWccyQa2dfBl)eiv8w5H9GMtU58qX2YpbsfVbuvTenNxmM7jMfWkpSofWff88c1s4LLOqDmSf(eHWfxjytatP6GPIGvbmhybbmva7HITLFcKkER8WEqZj3CEOyB5NaPI3aQQwIMZlgZ9eZcyLhwNc4kvBGVv)xyjUvwfaPvKieUWcfSjGPuDWurWQaMdSGaMkGdRsROxfJM7154DJlnu5gjvRDUS8tGuX7IeqdRZ5CBowYSaw5H1PagjvRDUS8tGuXIq4YlqWMaMs1btfbRcyoWccyQaoSkn3RZXsMNtU5cRsROxfJM7154DJlnu52VKckMMR(VuMKaDazxKaAyDoNBZXsMfWkpSofW(LuqX0C1)LYKeOdiIq4clOGnbmLQdMkcwfWCGfeWubCOykJDrbpVqTeEzjkuhdBHVnLQdMkZj3C8UXLgQCxuWZlulHxwIc1XWw4BdOQAjAUxNlSkTIEvmsaR8W6uaJKQ1oxw(jqQyriCrElytatP6GPIGvbmhybbmvaZ7gxAOYnsQw7Cz5NaPI3aQQwIM715cRsROxfJeWkpSofW(LuqX0C1)LYKeOdiIq4I3mlytatP6GPIGvbmhybbmvaZ7gxAOYnsQw7Cz5NaPI3aQQwIM715cRsROxfJeWkpSofWff88c1s4LLOqDmSf(eHWfV9wWMaMs1btfbRcyoWccyQaM3nU0qLBKuT25YYpbsfVbuvTen3RZfwLwrVkgjGvEyDkGRuTb(w9FHL4wzvaKwrIq4I3pjytatP6GPIGvbmhybbmvahwLwrVkgnNxZXsMfWkpSofWiPATZLLFcKkwecx8MLc2eWuQoyQiyvaZbwqatfWHvPv0RIrZ51CSKzbSYdRtbSFjfumnx9FPmjb6aIieU4T7lytatP6GPIGvbmhybbmvahwLwrVkgnNxZ9eZcyLhwNc4IcEEHAj8YsuOog2cFIq4I3UsWMaMs1btfbRcyoWccyQaoSkTIEvmAoVM7jMfWkpSofWvQ2aFR(VWsCRSkasRiriCXBwOGnbSYdRtbSdU7YQ)RacTOKQ(eWuQoyQiyvecx8(fiytaR8W6uadvdWLhKLlaH6utojGPuDWurWQieU4nlOGnbSYdRtbmW84btllxipkNeWuQoyQiyvecx8wElytatP6GPIGvbmhybbmva7HITLFcKkER8WEqZjt2CHvPv0RIrZ51CSKzbSYdRtbSNoSofHWLNywWMaMs1btfbRcyoWccyQa2dfBl)eiv8w5H9GMtMS5CK()DLQnW3Q)lSe3kRcG0kAdOQAjAozYMZr6)3ff88c1s4LLOqDmSf(2aQQwIMtMS5cRsROxfJMZR5yjZcyLhwNcyhcGiWZw6xecxEYBbBcykvhmveSkG5aliGPcypuST8tGuXBLh2dAozYMZr6)3vQ2aFR(VWsCRSkasROnGQQLO5KjBohP)FxuWZlulHxwIc1XWw4BdOQAjAozYMlSkTIEvmAoVMJLmlGvEyDkGDWDxwFjGpriC5PNeSjGPuDWurWQaMdSGaMkG9qX2YpbsfVvEypO5KjBohP)FxPAd8T6)clXTYQaiTI2aQQwIMtMS5CK()DrbpVqTeEzjkuhdBHVnGQQLO5KjBUWQ0k6vXO58AowYSaw5H1Pa(BaYb3DrecxEILc2eWuQoyQiyvaZbwqatfWEOyB5NaPI3kpSh0CYKnNJ0)VRuTb(w9FHL4wzvaKwrBavvlrZjt2Cos))UOGNxOwcVSefQJHTW3gqv1s0CYKnxyvAf9Qy0CEnhlzwaR8W6ualHOLfufjcHlp5(c2eWuQoyQiyvaR8W6ua7P5ptbYysQS4D1JuOH15QqpmojG5aliGPc4shBRwBSg0gqv1s0CVYyoxjGtTscypn)zkqgtsLfVREKcnSoxf6HXjriC5jxjytatP6GPIGvbSYdRtbmOdoqcfuz9O7s3RsJXcyoWccyQaU0X2Q1gRbTbuvTen3RmMZvZj3CUEoE34sdvUrs1ANll)eiv8gqv1s0CVYyUNyEozYMlSkTIEvmAoVMJLmpN7eWPwjbmOdoqcfuz9O7s3RsJXIq4YtSqbBcykvhmveSkGvEyDkGrqShey9GYUUae24cyoWccyQaU0X2Q1gRbTbuvTen3RmMZvZj3CUEoE34sdvUrs1ANll)eiv8gqv1s0CVYyUNyEozYMlSkTIEvmAoVMJLmpN7eWPwjbmcI9GaRhu21fGWgxecxE6fiytatP6GPIGvbSYdRtbS(IlzE6GYyLQuyyjKaMdSGaMkGlDSTATXAqBavvlrZ9kJ5C1CYnNRNJ3nU0qLBKuT25YYpbsfVbuvTen3RmM7jMNtMS5cRsROxfJMZR5yjZZ5obCQvsaRV4sMNoOmwPkfgwcjcHlpXckytatP6GPIGvbSYdRtbCyfcfnOU4DHErcyoWccyQaU0X2Q1gRbTbuvTen3RmMZvZj3CUEoE34sdvUrs1ANll)eiv8gqv1s0CVYyUNyEozYMlSkTIEvmAoVMJLmpN7eWPwjbCyfcfnOU4DHErIq4YtYBbBcykvhmveSkGvEyDkGFykE1)fkAqfjG5aliGPc4shBRwBSg0gqv1s0CVYyoxnNCZ5654DJlnu5gjvRDUS8tGuXBavvlrZ9kJ5EI55KjBUWQ0k6vXO58AowY8CUtaNALeWpmfV6)cfnOIeHieWf6Rs4qWMWfVfSjGvEyDkGrEimEHB(ZcykvhmveSkcHlpjytaR8W6uaJS0pTQQFJlGPuDWurWQieUWsbBcykvhmveSkG5aliGPcyi6JMVuEypO5KBoLh2dArjvncnNxZ5Q5yXZfkMYyB5NazVPuDWuzo3MZ1ZfkMYyB5NazVPuDWuzo5MlumLX2YGaPIx8U6iHcRZnLQdMkZ5obSYdRtbmxX4LYdRZf2qHagBOyLALeWq0hnxecxCFbBcyLhwNcyUgkh7dvfWuQoyQiyvecxCLGnbmLQdMkcwfWCGfeWubSYd7bTOKQgHM715EsaR8W6uaZvmEP8W6CHnuiGXgkwPwjbS2KieUWcfSjGPuDWurWQaw5H1Pa2Q1gRbjG5aliGPcya9becI6GP5KBoxphtNlumLXMRHYX(q1nLQdMkZjt2C8UXLgQCZ1q5yFO6gqv1s0CVohGQQLO5CNaM7JJPvOa)uGeU4TieU8ceSjGPuDWurWQaMdSGaMkGdftzSTmiqQ4fVRosOW6CtP6GPYCYnNYdRZnhI2OLtJJTLRp28djMtU5auvTenNxZvKaAyDohlAoM3UsaR8W6uaB1AJ1GeHWfwqbBcykvhmveSkGvEyDkG5kgVuEyDUWgkeWydfRuRKaMxqIq4I8wWMaMs1btfbRcyoWccyQaMPZ5HITLFcKkER8WEqZjt2CmDUqXugB)aR2gGw9FHK8aOQY9TPuDWuraR8W6ua)BUeIklLjjGf0YH0QieU4nZc2eWuQoyQiyvaZbwqatfWos))gq8NXecT(nGtBaP8qaR8W6uahqOLu60szz9BaNeHWfV9wWMaw5H1Pa2JeW((S0)YbROqatP6GPIGvriCX7NeSjGPuDWurWQaMdSGaMkGz6CLo28o5uganOY6J1kTCKa5gqv1s0CYnhtNt5H15M3jNYaObvwFSwPTLRp28djeWkpSofW8o5uganOY6J1kjcHlEZsbBcyLhwNcyoentcVkuTZVbibmLQdMkcwfHWfVDFbBcykvhmveSkGvEyDkGHOpAUaMdSGaMkGD9CLo2wT2ynOnGQQLO5EDUshBRwBSg0Uib0W6Cow0CmVD1CYKnhtNlumLX2YGaPIx8U6iHcRZnLQdMkZ5U5KBoxphtNJ3nU0qLBKuT25YYpbsfVbKw8nNmzZX05cftzS9dSABaA1)fsYdGQk33Ms1btL5KjBUqXugB)aR2gGw9FHK8aOQY9TPuDWuzo5MZdfBl)eiv8gqv1s0CEXyoVzEo3jG5(4yAfkWpfiHlElcHlE7kbBcyLhwNcyulHxFdqcykvhmveSkcHlEZcfSjGPuDWurWQaMdSGaMkGDK()TJYFUa0FSlnu5CYnhQLWleefuM7vgZ592vZXINJ5nlNJfnxOykJ9hRii9dcSPuDWuzo5MJPZ9qbM6GPTNUXlulHxiikOGeWkpSofW8o)y1pqdsecx8(fiytatP6GPIGvbmhybbmvaJAj8cbrbL58AUNMtU5C9CmDUhkWuhmT90nEHAj8cbrbf0CYKnhhIc8tO5EDoVNZDcyLhwNcyeeT0q5ibsriCXBwqbBcykvhmveSkGBpcyefcyLhwNc4hkWuhmjGFOyjsaR8WEqlkPQrO5EDoVNtU54DJlnu5gI(O5BavvlrZ5fJ58M55KjBoE34sdvUrs1ANll)eiv8gqv1s0CEXyUNyEo5MZ1ZfkMYy7hy12a0Q)lKKhavvUVnLQdMkZjt2CHIPm2ff88c1s4LLOqDmSf(2uQoyQmNCZX7gxAOYDrbpVqTeEzjkuhdBHVnGQQLO58IXCpX8CUBozYMlumLXUOGNxOwcVSefQJHTW3Ms1btL5KBoE34sdvUlk45fQLWllrH6yyl8TbuvTenNxmM7jMNtU5C9C8UXLgQCJKQ1oxw(jqQ4nGQQLO5EDUWQ0k6vXO5KjBoE34sdvUrs1ANll)eiv8gqv1s0CUnhVBCPHk3iPATZLLFcKkExKaAyDo3RZfwLwrVkgnN7eWpuWk1kjG90nEHAj8cbrbfKieU4T8wWMaMs1btfbRcyoWccyQa21ZfkMYy7hy12a0Q)lKKhavvUVnLQdMkZjt2CktsalOnhOiiw6FXHOnAtP6GPYCUBo5MZdfBl)eiv8w5H9GMtMS5CK()DrbpVqTeEzjkuhdBHVTKN5KjBohP)Fdi(ZycHw)gWPnGuEmNCZ5i9)BaXFgti063aoTbuvTen3RZXvuScRscyLhwNcyoeTrlNghIq4YtmlytatP6GPIGvbmhybbmvaZ05EOatDW02t34fQLWleefuqZj3CmDUqXugBcOfJRH15Ms1btfbSYdRtbmhI2OLtJdriC5jVfSjGPuDWurWQaMdSGaMkGz6CpuGPoyA7PB8c1s4fcIckO5KBUqXugBcOfJRH15Ms1btL5KBoxpxHCK()nb0IX1W6CdOQAjAoVMJROyfwLMtMS5CK()TJYFUa0FSL8mN7eWkpSofWCiAJwonoeHWLNEsWMaMs1btfbRcyoWccyQa21ZHAj8cbrbL5ELXCU)2vZXINJ59tZXIMt5H9GwusvJqZ5obSYdRtbmhI2OLtJdriC5jwkytatP6GPIGvbmhybbmvaZHOa)eAUxNZBbSYdRtbmVZpw9d0GeHWLNCFbBcyLhwNcyl5wsanibmLQdMkcwfHieHa(bbqwNcxEIzVL3m)c8(PnZmZSReWqPG0s)ib8lREAqqL5C1CkpSoNdBOaTN3cypG(Bysal)5yIekas8W6CUxifGB(ZZB5phKi8GKxyND)warYzZ7k7iRkH1W6Kd0FWoYQC2N3YFU3syFZ9K3qp3tm7T8Eow8CpXS8clzEEpVL)CU3xeXLcQmNd9BanhVRoAmNd53s0Eo5voN8eO5YozXquq9lHNt5H1jAUoX(2ZB5pNYdRt02dG4D1rdgFSIEEEl)5uEyDI2EaeVRoA4gd2)DxM3YFoLhwNOThaX7QJgUXGDvYFLYqdRZ5TYdRt02dG4D1rd3yWosQw7C5HI5TYdRt02dG4D1rd3yWUFGvBdqR(VqkhyFJtqBFgHIPm2(bwTnaT6)cPCG9noTPuDWuzEl)5uEyDI2EaeVRoA4gd2rP6bbPJfk0anVvEyDI2EaeVRoA4gd290H158w5H1jA7bq8U6OHBmyh1s413a08w5H1jA7bq8U6OHBmy3sULeqdcA7ZGPHIPm2OwcV(gG2uQoyQmVN3YFo37lI4sbvMJEqaFZfwLMlGqZP8ObZzO50hQHvhmTN3kpSormqEimEHB(ZZBLhwNi3yWoYs)0QQ(n(8EEl)5yc1hnFojeHMtNd5H4MINZdWAGf(MdBOyUoNR2OyUQeoSqb(PyoeNsfync65CKI5ci0CHc8tXCbeaHG04YCCnN7Hc8nxH8qzXs)Z15CHIPmqZBLhwNigCfJxkpSoxydfqNALyarF0COTpdi6JMVuEypi5uEypOfLu1iKxUIfhkMYyB5NazVPuDWuXnxhkMYyB5NazVPuDWurUqXugBldcKkEX7QJekSo3uQoyQ4U5T8NtE0q5yFO6CiiTeUmNdnNeIkZ15C8UXLgQCofnhQ7CofnNNgHmhmnVvEyDICJb7Cnuo2hQoVL)CSbvpxOa)umhItPcSgnNcO5GOzbtL5W2Z0Cil9JP5cf4NI5GYciZXeQpA(Cqr6dQmNL75Gdfew6FoOSaYCbearZfkWpfiONtNd5H4MInMKkZjV2U358aSgyHV5m0Ca6fxYauzER8W6e5gd25kgVuEyDUWgkGo1kXqBcA7Zq5H9GwusvJqV(08w(Z9YATXAqZHG0s4YCj9GaZ9vmEU()NlGqZ5byvf4BUqb(Pyp3l)ZjpAOCSpuDoOmmEoa9becYCVSwBSg0Co0Vb0Cwmh9I8yacb9CbecqUh0CzphGuuNZf9CqPOGMlSknhxrHL(NZI5TYdRtKBmy3Q1gRbbn3hhtRqb(PaXWBOTpda9becI6Gj5CntdftzS5AOCSpuDtP6GPImz8UXLgQCZ1q5yFO6gqv1s0RaQQwIC38w(Zj)xilGm3lZGaPINtE6QJekSoNlumLbvGEolCpO580iK5GP5EzT2ynO5GYW45sIkZf9Co0Ca6dieeQmhQ7KaZfq0CUacnhGQQLw6FUIeqdRZ5qQpe0Zz)5cieGCpO5umG0IV505KhiAJMJ1ghZ15CbeAoOuFZf9CbeAUqb(PypVvEyDICJb7wT2yniOTpJqXugBldcKkEX7QJekSo3uQoyQiNYdRZnhI2OLtJJTLRp28djKdqv1sKxfjGgwNSiM3UAEl)5ydcnNFkjGINdiHP56)CbePQZC)gmxOykd0CgAUONRQViRAmjnxaHMlLQoeyU(pNeIqZ1)5iLdzER8W6e5gd25kgVuEyDUWgkGo1kXGxqZBLhwNi3yW(V5siQSuMKawqlhsRqBFgm1dfBl)eiv8w5H9GKjJPHIPm2(bwTnaT6)cj5bqvL7BtP6GPY8w5H1jYngShqOLu60szz9BaNG2(mCK()nG4pJjeA9BaN2as5X8w5H1jYngS7rcyFFw6F5GvumVvEyDICJb78o5uganOY6J1kbT9zW0shBENCkdGguz9XALwosGCdOQAjsoMQ8W6CZ7Ktza0GkRpwR02Y1hB(HeZBLhwNi3yWohIMjHxfQ253a08w(ZXgeAo7phVZIfwNZbHa0Ckgk1hAo1JhSrO5yc1hnFUONd1vkGyP)56acbMlGO5CbeAopaRQaFZfkWpfZBLhwNi3yWoe9rZHM7JJPvOa)uGy4n02NHRlDSTATXAqBavvlrVw6yB1AJ1G2fjGgwNSiM3UsMmMgkMYyBzqGuXlExDKqH15Ms1btf3jNRzkVBCPHk3iPATZLLFcKkEdiT4tMmMgkMYy7hy12a0Q)lKKhavvUVnLQdMkYKfkMYy7hy12a0Q)lKKhavvUVnLQdMkY5HITLFcKkEdOQAjYlgEZS7M3YFo4wcphtGbO5qqAjCzohAojevMRZ54DJlnuj0ZzXCLMqZLDmN6XdPG5GQbbK5q6dl9p3VbZ5NscOHL(NdULWZbdrbf0CfjGL(NJ3nU0qLO5TYdRtKBmyh1s413a08w(ZjpD(XQFGg0CiiTeUmxNyFZ5qZjHOYCrphII5K8mN8arB0CS24aTNJjaRii9dcmhMc0CYtNFS6hObnNdnNeIkZrkaBeyUONdrXCsEMtZ5EzYTKaAqZ5q)gqZjpSUN7L)505QklqdMJ3nU0qLZzO54D1s)Zj5b65q6dAooef4NqZ9BWCwmVvEyDICJb78o)y1pqdcA7ZWr6)3ok)5cq)XU0qLYHAj8cbrbLxz492vSyM3SKffkMYy)Xkcs)GaBkvhmvKJPpuGPoyA7PB8c1s4fcIckO5T8NdgIwAOCKa5CgAojevMtrZPZvmeVLYyo5PZpw9d0GMl658tjb0GMdbrbf0C2FoFT0CLoDpXCq0h0Cu2s(Hm3VbZPZjpq0gnhRno2ZXgeAoKwP5asycnN60sXCi9HL(NZI5(nyUQYc0G54DJlnujAo1JhSrO5TYdRtKBmyhbrlnuosGeA7Za1s4fcIckE9KCUMPpuGPoyA7PB8c1s4fcIckizY4quGFc9Q3UBEl)5Ez4EqZbvdciZHIM)SL(NtYZCDohClHNdgIckO5COFdO505QklqdMJ3nU0qLZjHu)08w5H1jYngS)qbM6GjOtTsm80nEHAj8cbrbfe0puSeXq5H9GwusvJqV6TC8UXLgQCdrF08nGQQLiVy4nZYKX7gxAOYnsQw7Cz5NaPI3aQQwI8IXtmlNRdftzS9dSABaA1)fsYdGQk33Ms1btfzYcftzSlk45fQLWllrH6yyl8TPuDWuroE34sdvUlk45fQLWllrH6yyl8TbuvTe5fJNy2DYKfkMYyxuWZlulHxwIc1XWw4BtP6GPIC8UXLgQCxuWZlulHxwIc1XWw4BdOQAjYlgpXSCUM3nU0qLBKuT25YYpbsfVbuvTe9AyvAf9QyKmz8UXLgQCJKQ1oxw(jqQ4nGQQLi34DJlnu5gjvRDUS8tGuX7IeqdRZxdRsROxfJC38w(Zjpq0gnhRnoMdIIMdrpiGINZtJqMdMMtcrZX7SyH1jApN8aueel9pN8arBe0Z9clWQTbO56)CWsEauv5(GEonlZXevWZZb3sy5L5EzIc1XWw4BofJN7RpAWCCffw6FofnxvtFZjpSIMtrZ5PriZbtZbfekNttFZ1)5ciuDofqZP8WEqZBLhwNi3yWohI2OLtJdOTpdxhkMYy7hy12a0Q)lKKhavvUVnLQdMkYKPmjbSG2CGIGyP)fhI2OnLQdMkUtopuST8tGuXBLh2dsMmhP)FxuWZlulHxwIc1XWw4Bl5rMmhP)Fdi(ZycHw)gWPnGuEiNJ0)Vbe)zmHqRFd40gqv1s0RCffRWQ08w(Z9Y)CWTeEoyikOGMtb0CzhZ5qw6FopDJPYCAwMZ9c0IX1W6Codnx2XCHIPmOc0ZXciHI5qEOSmN8WkAofnxaH8nNdX7knN(qnS6GP5TYdRtKBmyNdrB0YPXb02NbtFOatDW02t34fQLWleefuqYX0qXugBcOfJRH15Ms1btL5T8N7fYciZ5EbAX4AyDc9Cw4EqZ5qj9nUP45IEUQ(ISQXK0CbeAojpHvP56CUacnxHCK()9CmHnu0dca9Cw4EqZHcdJNZHIGaZf9CsiAo5bI2O5yTXXCwTsftdc7Bo7phRk)5cq)XCgAojpZBLhwNi3yWohI2OLtJdOTpdM(qbM6GPTNUXlulHxiikOGKlumLXMaAX4AyDUPuDWuroxxihP)FtaTyCnSo3aQQwI8IROyfwLKjZr6)3ok)5cq)XwYJ7M3YFo37dkNdkiuohsFyPFONR0ZLDmx)GaC1ZCDohClHNdgIckO5TYdRtKBmyNdrB0YPXb02NHRrTeEHGOGYRmC)TRyXmVFIfP8WEqlkPQri3nVL)CmXoDpXC9dcWvpZ15CCikWpHMR)ZjpD(XQFGg08w5H1jYngSZ78Jv)aniOTpdoef4NqV698w5H1jYngSBj3scObnVN3YFUxm1Y56)CmbgGMZqZf(8yCfJ9nxaHMdI5hcHI58aSgyHV5uEyDc9CosXCCceQLZHSqsdRt0CF9rdMtczP)5KhiAJMJ1ghZzjkiTmVvEyDI2AtmaQLR(V(gGG2(m8qX2YpbsfVvEypi5CTJ0)V5afbXs)loeTr7sdvktgtdftzS9dSABaA1)fsYdGQk33Ms1btf3jNRzkVBCPHk3q0hnFdiT4tMmLh2dArjvnc9klD38w(Zjpq0mj8CmrQ253a0CDI9nxsubnxN0CVSwBSg0CkpSh0CfjGL(NZc0CCffZ9BWCYRT7Dp3lmaRQaFZfkWpfZzO5KquzoieGM73G5qw1d24w4BER8W6eT1MCJb7CiAMeEvOANFdqqBFgLo2wT2ynOnGQQLOx5kkwHvP5T8Nd2QgwbZf9Cil9JP5cf4NcONlGqaAodnx2ZLevMl65a0hqiiZ9YATXAqO5S)CYJgkh7dvNJR5CLEolMZsuqAzER8W6eT1MCJb7wT2yniO5(4yAfkWpfigEdT9zaOQAjYlxjNRzAOykJnxdLJ9HQBkvhmvKjJ3nU0qLBUgkh7dv3aQQwIEfqv1sK7M3YFUxmjmHM73G54DJlnujAUspx2XCCiA6NM73G5KxB3l0ZH654kgpxaHMdPvAoSHI5u0CDohYs)yAUqb(PyER8W6eT1MCJb7CfJxkpSoxydfqNALyWlO5T8NJniaIMluGFkqZzO50ColzXouafr5CCfrZfq0yo)2dcnNohcB(HeZ5qj9TyUONdI5hcbMZdWAGf(MJjuF085TYdRt0wBYngSdrF0CO5(4yAfkWpfigEdT9zO8WEqlkPQriVC)5T8N7ftTCU(phtGbO5GYW45qHcI5IEUsxTudAUoNdcPp8nN8A7EHEohPyouxP5qM)0(gxZyo5bI2O5yTXXCos)pAoOmmEouyy8C(Th0Cqm)qiWCfTQ(P5APWJumxNZ1CUISoN3kpSorBTj3yWohI2OLtJdOTpJqXugB)aR2gGw9FHK8aOQY9TPuDWuropuST8tGuXBLh2dsoxdrF08LYd7bjtwOykJnxdLJ9HQBkvhmvKjlumLX2YpbYEtP6GPICkpSh0IsQAeYl33DZB5phRkayP)5003C0lItEcRte0Z9IPwox)NJjWa0Cqzy8Co0CsiQmNIMRkXHmNIMZtJqMdMGEoKLCAUQeompyAoE7Xi0C9FolMJR5COq5ppVvEyDI2AtUXGDGA5Q)RVbO5TYdRt0wBYngS)BUeIklLjjGf0YH068w5H1jARn5gd29ibSVpl9VCWkkM3YFo37dkNZ(ZfqO5yc1hnFopaRbw4BoSHI5GQt3tmNdnNeIkqphtO(O5ZzO58aOi8nxvIdzUpGO5kAv9tZPzzoaHAjaNqZPzzoeKwcxMZHMtcrL5uCTrXCDohVBCPHkN3kpSorBTj3yWoe9rZHM7JJPvOa)uGy4n02NHRzAOykJTFGvBdqR(VqsEauv5(2uQoyQitgtdftzST8tGS3uQoyQitwOykJTFGvBdqR(VqsEauv5(2uQoyQiNhk2w(jqQ4nGQQLiVy4nZUBEl)5EHdrZXeyaAonlZXkWQOOtAo7phRk)5cq)XCgAoLh2dc65u0C4o9pNIMZI5GYW45YoMRFqaU6zUoNdULWZbdrbf08w5H1jARn5gd2TKBjb0GG2(mcftzS)gGwAwwoaRIIoPnLQdMkY5i9)BhL)CbO)yl5roulHxiikO4LRyXmVFIfP8WEqlkPQrO5T8N7f(acbMdULWZbdrbL58tjb0Ws)ZPog2cJqZPaAo)DxM7BymbMZ(ZLDmNeYs)ZXeyaAonlZXkWQOOtAER8W6eT1MCJb7OwcV(gGM3kpSorBTj3yWoVZpw9d0GG2(mCK()TJYFUa0FSlnu58w5H1jARn5gd2rq0sdLJeiH2(myAOykJ93a0sZYYbyvu0jTPuDWuzER8W6eT1MCJb78o5uganOY6J1kbT9zW0shBENCkdGguz9XALwosGCdOQAjsoMQ8W6CZ7Ktza0GkRpwR02Y1hB(HeYP8WEqlkPQriVC18w(Z9czbK5ycmanNML5yfyvu0jb9CVm5wsanO5GYW45CO505qbOt)Z9nmMa75Ez4EqZ5bRCQmhecqZ9BWCkgpxOykd0CrpNha9GYyoLZTcLHIX(MtczP)5ci0Cil9JP5cf4NI5aDOH15CydfZBLhwNOT2KBmy3sULeqdAEpVvEyDI28cIHeIwwqvOtTsmuMebrbkA97mw9F5PHIaqBFg8UXLgQCJKQ1oxw(jqQ4TKhzY4DJlnu5gjvRDUS8tGuXBavvlrE5Q5T8N7L)5C6aYC8UXLgQenNcO5aKw8b9CiPATZ5ci0CVm)eiv8CbekNt5H9qdAoMi8l3Z9Y)CzhZjHS0)Cmr4xc9CsiAUaIHMRZ5KhM48w5H1jAZli3yWosQw7Cz5NaPIH2(m4DJlnu5UOGNxOwcVSefQJHTW3gqAXNmz8UXLgQCxPAd8T6)clXTYQaiTI2asl(KjZ1mnumLXUOGNxOwcVSefQJHTW3Ms1btf5ykHquYPDLQnW3Q)lSe3kRcG0kAxvwGg4ozY4DJlnu5UOGNxOwcVSefQJHTW3gqv1sKxm8MzzY4DJlnu5Us1g4B1)fwIBLvbqAfTbuvTe5fdVzEER8W6eT5fKBmy3VKckMMR(VuMKaDabA7ZWdfBl)eiv8w5H9GM3kpSorBEb5gd2lk45fQLWllrH6yyl8bT9z4HITLFcKkER8WEqY5HITLFcKkEdOQAjYlgpX88w5H1jAZli3yWELQnW3Q)lSe3kRcG0kcA7ZWdfBl)eiv8w5H9GKZdfBl)eiv8gqv1sKxmEI55T8N7L)5yIWVCodnx2XCasl(MZrkMZxlnhxZ58tXC1gqZfq0CUoP5S8tGuXZz5Co0Vb0CbeAoklZ1)5ci0CFZpKa65qs1ANZfqO5Ez(jqQ45YgQ5TYdRt0MxqUXGDKuT25YYpbsfdT9zewLwrVkg9kVBCPHk3iPATZLLFcKkExKaAyD6glzEER8W6eT5fKBmy3VKckMMR(VuMKaDabA7ZiSk9klzwUWQ0k6vXOx5DJlnu52VKckMMR(VuMKaDazxKaAyD6glzEEl)5E5FUacn338djMdkdJNJYYCo0Vb0Cmr4xoNHMZr5ppNKhONdjvRDoxaHM7L5NaPIN3kpSorBEb5gd2rs1ANll)eivm02NrOykJDrbpVqTeEzjkuhdBHVnLQdMkYX7gxAOYDrbpVqTeEzjkuhdBHVnGQQLOxdRsROxfJM3kpSorBEb5gd29lPGIP5Q)lLjjqhqG2(m4DJlnu5gjvRDUS8tGuXBavvlrVgwLwrVkgnVL)CV8pxaHM7B(HeZbLHXZrzzoh63aAol)eiv8CgAohL)8CsEGEojenhte(LZBLhwNOnVGCJb7ff88c1s4LLOqDmSf(G2(m4DJlnu5gjvRDUS8tGuXBavvlrVgwLwrVkgnVvEyDI28cYngSxPAd8T6)clXTYQaiTIG2(m4DJlnu5gjvRDUS8tGuXBavvlrVgwLwrVkgnVL)CV8pxaHM7B(HeZzO5uNwkMl65OSa9CsiAo5HjIMdjXHmxarJ5ciKV58tXCkAUQehYCHvP5K8mNIMZtJqMdMM3kpSorBEb5gd2rs1ANll)eivm02NryvAf9QyKxSK55TYdRt0MxqUXGD)skOyAU6)szsc0beOTpJWQ0k6vXiVyjZZBLhwNOnVGCJb7ff88c1s4LLOqDmSf(G2(mcRsROxfJ86jMN3kpSorBEb5gd2RuTb(w9FHL4wzvaKwrqBFgHvPv0RIrE9eZZBLhwNOnVGCJb7o4UlR(Vci0IsQ6BER8W6eT5fKBmyhQgGlpilxac1PMCAER8W6eT5fKBmyhyE8GPLLlKhLtZBLhwNOnVGCJb7E6W6eA7ZWdfBl)eiv8w5H9GKjlSkTIEvmYlwY88w5H1jAZli3yWUdbqe4zl9dT9z4HITLFcKkER8WEqYK5i9)7kvBGVv)xyjUvwfaPv0gqv1sKmzos))UOGNxOwcVSefQJHTW3gqv1sKmzHvPv0RIrEXsMN3kpSorBEb5gd2DWDxwFjGpOTpdpuST8tGuXBLh2dsMmhP)FxPAd8T6)clXTYQaiTI2aQQwIKjZr6)3ff88c1s4LLOqDmSf(2aQQwIKjlSkTIEvmYlwY88w5H1jAZli3yW(3aKdU7c02NHhk2w(jqQ4TYd7bjtMJ0)VRuTb(w9FHL4wzvaKwrBavvlrYK5i9)7IcEEHAj8YsuOog2cFBavvlrYKfwLwrVkg5flzEER8W6eT5fKBmyxcrllOkcA7ZWdfBl)eiv8w5H9GKjZr6)3vQ2aFR(VWsCRSkasROnGQQLizYCK()DrbpVqTeEzjkuhdBHVnGQQLizYcRsROxfJ8ILmpVvEyDI28cYngSlHOLfuf6uRedpn)zkqgtsLfVREKcnSoxf6HXjOTpJshBRwBSg0gqv1s0RmC18w5H1jAZli3yWUeIwwqvOtTsmaDWbsOGkRhDx6EvAmgA7ZO0X2Q1gRbTbuvTe9kdxjNR5DJlnu5gjvRDUS8tGuXBavvlrVY4jMLjlSkTIEvmYlwYS7M3kpSorBEb5gd2Lq0YcQcDQvIbcI9GaRhu21fGWghA7ZO0X2Q1gRbTbuvTe9kdxjNR5DJlnu5gjvRDUS8tGuXBavvlrVY4jMLjlSkTIEvmYlwYS7M3kpSorBEb5gd2Lq0YcQcDQvIH(IlzE6GYyLQuyyje02NrPJTvRnwdAdOQAj6vgUsoxZ7gxAOYnsQw7Cz5NaPI3aQQwIELXtmltwyvAf9QyKxSKz3nVvEyDI28cYngSlHOLfuf6uReJWkekAqDX7c9IG2(mkDSTATXAqBavvlrVYWvY5AE34sdvUrs1ANll)eiv8gqv1s0RmEIzzYcRsROxfJ8ILm7U5TYdRt0MxqUXGDjeTSGQqNALy8Wu8Q)lu0GkcA7ZO0X2Q1gRbTbuvTe9kdxjNR5DJlnu5gjvRDUS8tGuXBavvlrVY4jMLjlSkTIEvmYlwYS7M3ZBLhwNOne9rZzW78Jv)aniOTpdhP)F7O8Nla9h7sdvkhQLWleefuELH3YHAj8cbrbfVy4(ZBLhwNOne9rZDJb7wT2yniOTpJqXugBldcKkEX7QJekSo3uQoyQihGQQLiVksanSozrmVDLmzmnumLX2YGaPIx8U6iHcRZnLQdMkYbOpGqquhmnVvEyDI2q0hn3ngSZHOnA504aA7ZGROyfwL8cI(O5lavvlrZBLhwNOne9rZDJb7OwcV(gGM3kpSorBi6JM7gd2rq0sdLJeiH2(muEypOfLu1iKxSuMmMgkMYy)naT0SSCawffDsBkvhmvM3kpSorBi6JM7gd2TKBjb0GG2(m4kkwHvjVGOpA(cqv1sKag5H4cxEIf(ceHieca]] )


end
