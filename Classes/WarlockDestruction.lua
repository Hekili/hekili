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
            cooldown = 180,
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


    spec:RegisterPack( "Destruction", 20190302.1241, [[dWeP(aqiiPEKsQ2KG4tqsYOeI6ucrwLkj8kHWSGe3sqQ2Lk(fPWWus5yKsTmvs9mvsAAKsY1uPKTjiL(Mqv04uPu6CqsyDKsQMNkf3Ju1(iL4Gqskles5Hcv1efQsxesI2OGu8rvsuzKcvHtkizLcLzcjPQBskPyNKI(PkjQAOQKOSuvkvEketfs1vHKuXxvPu1Er1FvvdwYHjwmkEmjtwPUmYMrPptQmAL40IwnPKsVwOYSbUTQSBP(TIHlOooKKkTCOEoOPt11fy7kjFxLQXRsICEH06vPumFvI9tzU2C05iBXjUMxVM2OI1U6AxF0(ATs7Rgp5iE0WehjSOIt0rCKwEehjEjOJduEonhjSefmYMJohbobyfXrwCpmuRRHg6sFjG5OMNgW8faepNwHfwxdy(uAWrycsGhQMZWr2ItCnVEnTrfRD11U(O91x96R1MJib(YG5ii5l(CKLCVPMZWr2euXrw3Q4LGooq550wD7fmyuXzXw3Qf3dd16AOHU0xcyoQ5PbmFbaXZPvyH11aMpLgwS1TsRrWQfRUgfRUEnTrfwf6wP91ADTsBRUY0ASywS1Tk(lsRJGADl26wf6wHeMaaRq1pQ4oCeqcDihDoYISAuC05AQnhDoc1cdG2C04ikC6eofoctal7HruXTXcRF2Z92QqScobGpCrWBR0IER02QqScobGpCrWBRUrVvAfhruEonhrnnlq0HfN4oxZR5OZrOwya0MJghrHtNWPWrCbqTFY2jClGVAEmbqpN(qTWaOTvHyfMEs2qRUXQDaw8CARUcRw7ClRUCXkuBLlaQ9t2oHBb8vZJja650hQfgaTTkeRWelMGlcdG4iIYZP5i57naXjUZ18QC05iulmaAZrJJOWPt4u4ikb6FpFKv3y1ISAuFm9KSHCer550Ce1ImWpZaCUZ1uR4OZreLNtZrGta4ZMyIJqTWaOnhnUZ18wC05iulmaAZrJJOWPt4u4iIYZv0NA6Le0QBS6QwD5IvO2kxau7h2etFP3FgC(G(00HAHbqBoIO8CAocCr2ZDMaCZDUMHwo6CeQfgaT5OXru40jCkCeLa9VNpYQBSArwnQpMEs2qoIO8CAos2QSjS4e35ohjmMuZJrCo6Cn1MJohHAHbqBoACNR51C05iulmaAZrJ7CnVkhDoc1cdG2C04oxtTIJohruEonhbg8Et)Zxyoc1cdG2C04oxZBXrNJqTWaOnhnoIcNoHtHJ4cGA)OdNVjX0Fy)qrHt2urhQfgaT5iIYZP5i6W5Bsm9h2puu4Knve35AgA5OZrOwya0MJg35Agp5OZreLNtZrcpEonhHAHbqBoACNR5TLJohruEonhbobGpBIjoc1cdG2C04oxtubhDoc1cdG2C04ikC6eofocQTYfa1(bobGpBIPd1cdG2Cer550CKSvztyXjUZDoImehDUMAZrNJqTWaOnhnoIcNoHtHJeM8t2SeUfWruEUISkeRISvmbSShfwGlzR7RwKbE2Z92QlxSc1w5cGA)OdNVjX0Fy)WGWy6jQOhQfgaTTkswfIvr2kuBLAgWEU3Nfz1Ooys2rT6YfReLNROp10ljOvAXQRAvK4iIYZP5iyj7)W(ztmXDUMxZrNJqTWaOnhnoIcNoHtHJSh)KV3aeNoy6jzdTslwPeO)98rCer550Ce1I0nb(B6nnBIjUZ18QC05iulmaAZrJJOWPt4u4iyIftWfHbqwfIvr2kuBLlaQ9JsCrbIcFhQfgaTT6YfRuZa2Z9(OexuGOW3btpjBOvAXkm9KSHwfjoIO8CAos(EdqCIJOIQa03fSoYHCn1M7Cn1ko6CeQfgaT5OXreLNtZruca8fLNt)bj05iGe6)wEehrTHCNR5T4OZrOwya0MJghrHtNWPWreLNROp10ljOv3yLwXreLNtZrwKvJIJOIQa03fSoYHCn1M7CndTC05iulmaAZrJJOWPt4u4iUaO2p6W5Bsm9h2pmimMEIk6HAHbqBRcXQWKFYMLWTaoIYZvKvHyvKTArwnQVO8Cfz1Llw5cGA)OexuGOW3HAHbqBRUCXkxau7NSzjCphQfgaTTkeReLNROp10ljOv3yLwzvK4iIYZP5iQfzGFMb4CNRz8KJohruEonhblz)h2pBIjoc1cdG2C04oxZBlhDoc1cdG2C04ikC6eofosKTc1w5cGA)OdNVjX0Fy)WGWy6jQOhQfgaTT6YfRqTvUaO2pzZs4EoulmaAB1Llw5cGA)OdNVjX0Fy)WGWy6jQOhQfgaTTkeRct(jBwc3c4GPNKn0QB0BL2RzvK4iIYZP5ilYQrXrurva67cwh5qUMAZDUMOco6CeQfgaT5OXru40jCkCexau7h2etFP3FgC(G(00HAHbqBRcXkMaw2dJOIBJfw)ee2QqScobGpCrWBRUXQBzvOB1ANRT6kSsuEUI(utVKGCer550CKSvztyXjUZ1u714OZreLNtZrGta4ZMyIJqTWaOnhnUZ1uBT5OZrOwya0MJghrHtNWPWrycyzpmIkUnwy9ZEU3Cer550Ce10SarhwCI7Cn1(Ao6CeQfgaT5OXru40jCkCeuBLlaQ9dBIPV07pdoFqFA6qTWaOnhruEonhbUi75otaU5oxtTVkhDoIO8CAos2QSjS4ehHAHbqBoACN7Ce1gYrNRP2C05iulmaAZrJJOWPt4u4iQza75EF2coUpCca)SHUWKG0JEWKSJA1LlwHARCbqTF2coUpCca)SHUWKG0JEOwya0MJikpNMJadEVP)zZs4waCNR51C05iulmaAZrJJOWPt4u4iHj)KnlHBbCeLNRioIO8CAoYwWX9Hta4Nn0fMeKEuUZ18QC05iulmaAZrJJOWPt4u4iE(OVp)DswPfRuZa2Z9(adEVP)zZs4waNDaw8CAoIO8CAocm49M(NnlHBbWDUMAfhDoc1cdG2C04ikC6eofoINp67ZFNKvAXk1mG9CVpBbh3hobGF2qxysq6rp7aS450wfHvxVghruEonhzl44(Wja8Zg6ctcspk35AElo6CeQfgaT5OXru40jCkCexau7NTGJ7dNaWpBOlmji9OhQfgaTTkeRuZa2Z9(SfCCF4ea(zdDHjbPh9GPNKn0kTyLNp67ZFNehruEonhbg8Et)ZMLWTa4oxZqlhDoc1cdG2C04ikC6eofoIAgWEU3hyW7n9pBwc3c4GPNKn0kTyLNp67ZFNehruEonhzl44(Wja8Zg6ctcspk35Agp5OZrOwya0MJghrHtNWPWr88rFF(7KS6gRU6ACer550CeyW7n9pBwc3cG7CnVTC05iulmaAZrJJOWPt4u4iE(OVp)DswDJvxVghruEonhzl44(Wja8Zg6ctcspk35AIk4OZrOwya0MJghrHtNWPWrct(jBwc3c4ikpxrwD5IvE(OVp)DswDJvxDnoIO8CAos4XZP5oxtTxJJohruEonhHHWqchx264iulmaAZrJ7Cn1wBo6Cer550CegWm7pBaokhHAHbqBoACNRP2xZrNJikpNMJWMyIbmZMJqTWaOnhnUZ1u7RYrNJikpNMJeaPF60dYrOwya0MJg35ohztSsaW5OZ1uBo6Cer550Ceyyca(GrfhhHAHbqBoACNR51C05iIYZP5iWS1r)NOlvCeQfgaT5OXDUMxLJohHAHbqBoACer550CeLaaFr550FqcDoIcNoHtHJSiRg1xuEUISkeReLNROp10ljOv3y1TSk0TYfa1(jBwc3ZHAHbqBRIWQiBLlaQ9t2SeUNd1cdG2wfIvUaO2pz7eUfWxnpMaONtFOwya02QiXraj0)T8ioYISAuCNRPwXrNJikpNMJOexuGOWhhHAHbqBoACNR5T4OZrOwya0MJghruEonhrjaWxuEo9hKqNJOWPt4u4iIYZv0NA6Le0kTy11Ceqc9FlpIJidXDUMHwo6CeQfgaT5OXru40jCkCemXIj4IWaiRcXQiBfQTYfa1(rjUOarHVd1cdG2wD5IvQza75EFuIlkqu47GPNKn0kTyfMEs2qRIehruEonhjFVbioXrurva67cwh5qUMAZDUMXto6CeQfgaT5OXru40jCkCexau7NSDc3c4RMhta0ZPpulmaABviwjkpN(OwKb(zgGFY(ZcsDlUvHyfMEs2qRUXQDaw8CARUcRw7CloIO8CAos(EdqCI7CnVTC05iulmaAZrJJikpNMJOea4lkpN(dsOZraj0)T8ioIAd5oxtubhDoIO8CAoIAr6Ma)n9MMnXehHAHbqBoACNRP2RXrNJqTWaOnhnoIcNoHtHJezR2JFY3BaIthm9KSHwPfR2JFY3BaItNDaw8CARUcRw7ClRUCXkuBLlaQ9t2oHBb8vZJja650hQfgaTTkswfIvr2kuBLAgWEU3hyW7n9pBwc3c4Gjzh1QlxSc1w5cGA)OdNVjX0Fy)WGWy6jQOhQfgaTT6YfRCbqTF0HZ3Ky6pSFyqym9ev0d1cdG2wfIvHj)KnlHBbCW0tYgA1n6Ts71SksCer550CKfz1O4iQOka9DbRJCixtT5oxtT1MJohruEonhbobGpBIjoc1cdG2C04oxtTVMJohHAHbqBoACefoDcNchHjGL9WiQ42yH1p75EBviwbNaWhUi4TvArVvAFULvHUvRDUQvxHvUaO2pSabUmRi8HAHbqBRcXkuB1kbNcdGoHNb8Hta4dxe8gYreLNtZrutZceDyXjUZ1u7RYrNJqTWaOnhnoIcNoHtHJaNaWhUi4Tv3y11wfIvr2kuB1kbNcdGoHNb8Hta4dxe8gA1LlwPweSocALwSsBRIehruEonhbUi75otaU5oxtT1ko6CKvciG4iIYZv0NA6Le0kTyL2wfIvQza75EFwKvJ6GPNKn0QB0BL2Rz1LlwPMbSN79bg8Et)ZMLWTaoy6jzdT6g9wD9AwfIvr2kxau7hD48njM(d7hgegtprf9qTWaOTvxUyLlaQ9ZwWX9Hta4Nn0fMeKE0d1cdG2wfIvQza75EF2coUpCca)SHUWKG0JEW0tYgA1n6T661SkswD5IvUaO2pBbh3hobGF2qxysq6rpulmaABviwPMbSN79zl44(Wja8Zg6ctcsp6btpjBOv3O3QRxZQqSkYwPMbSN79bg8Et)ZMLWTaoy6jzdTslw55J((83jz1LlwPMbSN79bg8Et)ZMLWTaoy6jzdTkcRuZa2Z9(adEVP)zZs4waNDaw8CAR0IvE(OVp)Dswfjoc1cdG2C04iIYZP5iReCkmaIJSsW)wEehj8mGpCcaF4IG3qUZ1u7BXrNJqTWaOnhnoIcNoHtHJezRCbqTF0HZ3Ky6pSFyqym9ev0d1cdG2wD5IvYTHWPthfwGlzR7RwKbEOwya02QizviwfM8t2SeUfWruEUIS6YfRycyzpBbh3hobGF2qxysq6rpbH5iIYZP5iQfzGFMb4CNRP2Hwo6CeQfgaT5OXru40jCkCeuB1kbNcdGoHNb8Hta4dxe8gAviwHARCbqTFiSStL450hQfgaT5iIYZP5iQfzGFMb4CNRP2Xto6CeQfgaT5OXru40jCkCeuB1kbNcdGoHNb8Hta4dxe8gAviw5cGA)qyzNkXZPpulmaABviwfzR2etal7HWYovINtFW0tYgA1nwPeO)98rwD5IvmbSShgrf3glS(jiSvrIJikpNMJOwKb(zgGZDUMAFB5OZrOwya0MJghrHtNWPWrISvWja8HlcEBLw0BLwDULvHUvRDU2QRWkr55k6tn9scAvK4iIYZP5iQfzGFMb4CNRP2Oco6CeQfgaT5OXru40jCkCe1IG1rqR0IvAZreLNtZrutZceDyXjUZ18614OZreLNtZrYwLnHfN4iulmaAZrJ7CN7CKvegMtZ18610gvS2vx76ZAAZrUl4oBDqosOEHhStBRULvIYZPTcKqhESyCeyysX186qB8KJegpSjG4iRBv8sqhhO8CARU9cgmQ4SyRB1I7HHADn0qx6lbmh180aMVaG450kSW6AaZNsdl26wP1iy1IvxJIvxVM2OcRcDR0(ATUwPTvxzAnwml26wf)fP1rqTUfBDRcDRqctaGvO6hvChl26wf6wD7O3SIScMVJlyDKBLAHuXDSywS1TcvELivGtBRyi2btwPMhJ4wXq6YgEScvtPOWo0QE6qFrWp2aGvIYZPHwnni6XIjkpNgEcJj18yexplqGXzXeLNtdpHXKAEmIhHEnyNzBXeLNtdpHXKAEmIhHEnKaDpQDXZPTyIYZPHNWysnpgXJqVgWG3B6FyYTyIYZPHNWysnpgXJqVg6W5Bsm9h2puu4KnvekjRExau7hD48njM(d7hkkCYMk6qTWaOTftuEon8egtQ5XiEe61a2sy4Y4FOlo0IjkpNgEcJj18yepc9AeE8CAlMO8CA4jmMuZJr8i0RbCcaF2etwmr550WtymPMhJ4rOxJSvztyXjusw9O2fa1(bobGpBIPd1cdG2wml26wHkVsKkWPTv0kch1kpFKv(czLO8bBvcTswjjqya0XIjkpNgQhgMaGpyuXzXeLNtdJqVgWS1r)NOlvwml26wfpKvJYQaibTsScgMuPaSkmohC6rTcKq3QPT6nq3QxaWtxW6i3kOIAbNdefRycCR8fYkxW6i3kFbtWLbSTsjTvReCuR2uyQ3zRZQPTYfa1o0IjkpNgQxjaWxuEo9hKqhLwEK(fz1Oqjz1ViRg1xuEUIcruEUI(utVKG3CRq3fa1(jBwc3ZHAHbq7iISlaQ9t2SeUNd1cdG2H4cGA)KTt4waF18ycGEo9HAHbq7izXw3Q4lUOarHpRGltayBfdzvaK2wnTvQza75EBLaTcotBLaTk8aHjdGSyIYZPHrOxdL4Icef(SyRBf63hRCbRJCRGkQfCoqRemz1I0BaTTcKXrwbZwhGSYfSoYT6E6lwfpKvJYQ7KSI2wL9XkexWE26S6E6lw5lyISYfSoYHOyLyfmmPsbK3gABfQ2GkTkmohC6rTkHwHjuDdsmTTyIYZPHrOxdLaaFr550FqcDuA5r6LHqjz1lkpxrFQPxsqTCTfBDRc17naXjRGltayBvtRiSvScay1WYALVqwfgNpbh1kxW6i)yvOyTk(Ilkqu4ZQ7jayfMyXeCXQq9EdqCYkgIDWKvPBfDLcNycIIv(cHjuf0QESctcCAR8XQ7c0jR88rwPeONToRs3IjkpNggHEnY3BaItOOIQa03fSoYH61gLKvpMyXeCryauirg1UaO2pkXffik8DOwya0(Yf1mG9CVpkXffik8DW0tYgQfm9KSHrYITUvRF7tFXQq1oHBbyv8Nhta0ZPTYfa1oTrXQ0rvqRcpqyYaiRc17naXjRUNaGvnrBR8XkgYkmXIj4cTTcottyR8fPTYxiRW0tYoBDwTdWINtBfuIcrXQK1kFHWeQcALaWKSJALyv8xKbAfAdWTAAR8fYQ7suR8XkFHSYfSoYpwmr550Wi0Rr(EdqCcLKvVlaQ9t2oHBb8vZJja650hQfgaTdruEo9rTid8Zma)K9NfK6w8qW0tYgEZoalEo9vS25wwS1Tc9fYkDutybyfoaqwnSw5lbpgRyhSvUaO2HwLqR8XQNCLYxEBiR8fYQo4XqyRgwRcGe0QH1ksulwmr550Wi0RHsaGVO8C6piHokT8i9Qn0IjkpNggHEnuls3e4VP30SjMSyRBf6lKvjRvQP3PNtB1cHjReWDjk0kjCyqsqRIhYQrzLpwbNh5lzRZQXxiSv(I0w5lKvHX5tWrTYfSoYTyIYZPHrOxJfz1OqrfvbOVlyDKd1RnkjR(iVh)KV3aeNoy6jzd1YE8t(EdqC6SdWINtFfRDU1LlO2fa1(jBNWTa(Q5Xea9C6d1cdG2rkKiJA1mG9CVpWG3B6F2SeUfWbtYo6LlO2fa1(rhoFtIP)W(HbHX0turpulmaAF5IlaQ9JoC(Met)H9ddcJPNOIEOwya0oKWKFYMLWTaoy6jzdVrV2Rfjl26wHmbaRcnjMScUmbGTvmKvbqAB10wPMbSN7nkwLUv7HGw1JBLeomjyRUpyFXkOSkBDwXoyR0rnHfpBDwHmbaRqwe8gA1oaNToRuZa2Z9gAXeLNtdJqVgWja8ztmzXw3Q4pnlq0HfNScUmbGTvtdIAfdzvaK2w5JvqYTkiSvXFrgOvOnahESk0ae4YSIWwbihAv8NMfi6WItwXqwfaPTvKGbjHTYhRGKBvqyRK2Qq1QSjS4Kvme7GjRIpAhRcfRvIvprRDWwPMbSN7Tvj0k18YwNvbHrXkOSISsTiyDe0k2bBv6wmr550Wi0RHAAwGOdloHsYQNjGL9WiQ42yH1p75EhcCcaF4IG3ArV2NBf6RDU6v4cGA)Wce4YSIWhQfgaTdb1ReCkma6eEgWhobGpCrWBOfBDRqwK9CNja3wLqRcG02kbALy1oHQjODRI)0SarhwCYkFSsh1ewCYk4IG3qRswRIobwTNgv5wTiRiROEc0Tyf7GTsSk(lYaTcTb4hRqFHSckpYkCaGGwjmtGBfuwLToRs3k2bB1t0AhSvQza75EdTschgKe0IjkpNggHEnGlYEUZeGBusw9Wja8HlcEFZ1HezuVsWPWaOt4zaF4ea(WfbVHxUOweSocQfTJKfBDRcLJQGwDFW(IvqFuXLToRccB10wHmbaRqwe8gAfdXoyYkXQNO1oyRuZa2Z92QaOOJSyIYZPHrOxJvcofgaHslpsF4zaF4ea(WfbVHOSsabKEr55k6tn9scQfTdrndyp37ZISAuhm9KSH3Ox71UCrndyp37dm49M(NnlHBbCW0tYgEJ(RxlKi7cGA)OdNVjX0Fy)WGWy6jQOhQfgaTVCXfa1(zl44(Wja8Zg6ctcsp6HAHbq7quZa2Z9(SfCCF4ea(zdDHjbPh9GPNKn8g9xVwKUCXfa1(zl44(Wja8Zg6ctcsp6HAHbq7quZa2Z9(SfCCF4ea(zdDHjbPh9GPNKn8g9xVwirwndyp37dm49M(NnlHBbCW0tYgQfpF03N)oPlxuZa2Z9(adEVP)zZs4wahm9KSHrOMbSN79bg8Et)ZMLWTao7aS450AXZh995VtkswS1Tk(lYaTcTb4wTiqRG0kclaRcpqyYaiRcGKvQP3PNtdpwfFSaxYwNvXFrgikwDLdNVjXKvdRvibHX0turrXkP3wfVcooRqMaGw3Qq1qxysq6rTsaaRyLvd2kLa9S1zLaT6jDuRIpAqReOvHhimzaKv3xO2kPJA1WALVqpRemzLO8CfzXeLNtdJqVgQfzGFMb4OKS6JSlaQ9JoC(Met)H9ddcJPNOIEOwya0(Yf52q40PJclWLS19vlYapulmaAhPqct(jBwc3c4ikpxrxUWeWYE2coUpCca)SHUWKG0JEccBXw3QqXAfYeaSczrWBOvcMSQh3kgkBDwfEgaTTs6TvOsSStL450wLqR6XTYfa1oTrXkT2aOBfmm1BRIpAqReOv(cf1kgsnpYkzLKaHbqwmr550Wi0RHArg4NzaokjREuVsWPWaOt4zaF4ea(WfbVHHGAxau7hcl7ujEo9HAHbqBl26wD7tFXkujw2Ps8CAuSkDuf0kgQj2uLcWkFS6jxP8L3gYkFHSkiSNpYQPTYxiR2etal7XQ4XCNwryuSkDuf0kONaGvmK7e2kFSkaswf)fzGwH2aCRY3J2P4eiQvjRvOjQ42yH1TkHwfe2IjkpNggHEnulYa)mdWrjz1J6vcofgaDcpd4dNaWhUi4nmexau7hcl7ujEo9HAHbq7qI8Mycyzpew2Ps8C6dMEs2WBuc0)E(OlxycyzpmIkUnwy9tq4izXw3ku5kQT6(c1wbLvzRdfR2Jv94wnRiSscB10wHmbaRqwe8gAXeLNtdJqVgQfzGFMb4OKS6JmCcaF4IG3ArVwDUvOV256RquEUI(utVKGrYITUvX70Ok3QzfHvsyRM2k1IG1rqRgwRI)0SarhwCYIjkpNggHEnutZceDyXjusw9QfbRJGArBlMO8CAye61iBv2ewCYIzXw3QBNKTvdRvHMetwLqR8OHtLaarTYxiRwsDle0TkmohC6rTsuEonkwXe4wPiSlzBfm9aXZPHwXkRgSvbWS1zv8xKbAfAdWTkBOtY2IjkpNgEKH0JLS)d7NnXekjR(WKFYMLWTaoIYZvuirMjGL9OWcCjBDF1ImWZEU3xUGAxau7hD48njM(d7hgegtprf9qTWaODKcjYOwndyp37ZISAuhmj7OxUikpxrFQPxsqTC1izXw3Q4ViDtaRIx6nnBIjRMge1QMOn0QPjRc17naXjReLNRiR2b4S1zv6qRuc0TIDWwHQnOYJvxz48j4Ow5cwh5wLqRcG02QfctwXoyRG5lmivPh1IjkpNgEKHIqVgQfPBc830BA2etOKS63JFY3BaIthm9KSHArjq)75JSyRBfs(sGGTYhRGzRdqw5cwh5OyLVqyYQeAvpw1eTTYhRWelMGlwfQ3BaItqRswRIV4Icef(SsjTv7XQ0TkBOtY2IjkpNgEKHIqVg57naXjuurva67cwh5q9AJsYQhtSycUimakKiJAxau7hL4Icef(oulmaAF5IAgWEU3hL4Icef(oy6jzd1cMEs2WizXw3QBxaGGwXoyRuZa2Z9gA1ESQh3k1I06iRyhSvOAdQefRGJvkbaSYxiRGYJScKq3kbA10wbZwhGSYfSoYTyIYZPHhzOi0RHsaGVO8C6piHokT8i9Qn0ITUvOVGjYkxW6ihAvcTsARYo0zi)orTvkbsw5lIBLUCfbTsSccsDlUvmutSPBLpwTK6wiSvHX5GtpQvXdz1OSyIYZPHhzOi0RXISAuOOIQa03fSoYH61gLKvVO8Cf9PMEjbVrRSyRB1TtY2QH1QqtIjRUNaGvqxWUv(y1EEzloz10wTqYQOwHQnOsuSIjWTcopYkyQRt2ujTBv8xKbAfAdWTIjGLfA19eaSc6jayLUCfz1sQBHWwTLNOJSAc8WbUvtB1OucmN2IjkpNgEKHIqVgQfzGFMb4OKS6DbqTF0HZ3Ky6pSFyqym9ev0d1cdG2HeM8t2SeUfWruEUIcjYlYQr9fLNROlxCbqTFuIlkqu47qTWaO9LlUaO2pzZs4EoulmaAhIO8Cf9PMEjbVrRIKfBDRqtW4S1zL0rTIUskkSNtdrXQBNKTvdRvHMetwDpbaRyiRcG02kbA1lqTyLaTk8aHjdGqXky2kYQxaWZWaYk1eojOvdRvPBLsARGUOIZIjkpNgEKHIqVgyj7)W(ztmzXw3ku5kQTkzTYxiRIhYQrzvyCo40JAfiHUv3Ngv5wXqwfaPnkwfpKvJYQeAvym5EuREbQfRyXez1wEIoYkP3wHj4eGve0kP3wbxMaW2kgYQaiTTsaVb6wnTvQza75EBXeLNtdpYqrOxJfz1OqrfvbOVlyDKd1RnkjR(iJAxau7hD48njM(d7hgegtprf9qTWaO9LlO2fa1(jBwc3ZHAHbq7lxCbqTF0HZ3Ky6pSFyqym9ev0d1cdG2HeM8t2SeUfWbtpjB4n61ETizXw3kuDGKvHMetwj92k0W5d6ttwLSwHMOIBJfw3QeALO8CfHIvc0kW06SsGwLUv3taWQECRMvewjHTAARqMaGvilcEdTyIYZPHhzOi0Rr2QSjS4ekjRExau7h2etFP3FgC(G(00HAHbq7qycyzpmIkUnwy9tq4qGta4dxe8(MBf6RDU(keLNROp10ljOfBDRUY7le2kKjayfYIG3wPJAclE26Ssysq6jbTsWKv6MzBfBcae2QK1QECRcGzRZQqtIjRKEBfA48b9PjlMO8CA4rgkc9AaNaWNnXKftuEon8idfHEnutZceDyXjusw9mbSShgrf3glS(zp3BlMO8CA4rgkc9AaxK9CNja3OKS6rTlaQ9dBIPV07pdoFqFA6qTWaOTfBDRU9PVyvOjXKvsVTcnC(G(0ekwfQwLnHfNS6EcawXqwjwbD806SInbacFSkuoQcAvyGOOTvleMSIDWwjaGvUaO2Hw5JvHX0kQDReLk3u7cae1Qay26SYxiRGzRdqw5cwh5wHhx8CARaj0TyIYZPHhzOi0Rr2QSjS4KfZITUvHI1kMXxSsndyp3BOvcMSctYokkwbdEVPTYxiRcvZs4waw5luBLO8CL4KvXlsOowfkwR6XTkaMToRIxKqHIvbqYkFjHwnTvXpETyIYZPHh1gQhg8Et)ZMLWTaqjz1RMbSN79zl44(Wja8Zg6ctcsp6btYo6LlO2fa1(zl44(Wja8Zg6ctcsp6HAHbqBlMO8CA4rTHrOxJTGJ7dNaWpBOlmji9OOKS6dt(jBwc3c4ikpxrwS1TkuSwfViHYQeAvpUvys2rTIjWTk6eyLsAR0rUvVbtw5lsB10KvzZs4wawLTvme7GjR8fYkQ3wnSw5lKvSPUfhfRGbV30w5lKvHQzjClaR65UftuEon8O2Wi0Rbm49M(NnlHBbGsYQ3Zh995VtslQza75EFGbV30)SzjClGZoalEoTfBDRcfRvrNaRusBLoYTkBREdMSYxK2QPjREdMSkErcLvme7GjR8fYkQ3wnSw5lKvSPUfhfRcGKv(I4w1ZDlMO8CA4rTHrOxJTGJ7dNaWpBOlmji9OOKS698rFF(7K0IAgWEU3NTGJ7dNaWpBOlmji9ONDaw8C6iUEnl26wfkwR8fYk2u3IB19eaSI6Tvme7GjRIxKqzvcTIruXzvqyuScg8EtBLVqwfQMLWTaSyIYZPHh1ggHEnGbV30)SzjClausw9UaO2pBbh3hobGF2qxysq6rpulmaAhIAgWEU3NTGJ7dNaWpBOlmji9Ohm9KSHAXZh995VtYITUvHI1kFHSIn1T4wDpbaROEBfdXoyYQSzjClaRsOvmIkoRccJIvbqYQ4fjuwmr550WJAdJqVgBbh3hobGF2qxysq6rrjz1RMbSN79bg8Et)ZMLWTaoy6jzd1INp67ZFNKfBDRcfRv(czfBQBXTkHwjmtGBLpwr9gfRcGKvXpEHwbdulw5lIBLVqrTsh5wjqREbQfR88rwfe2kbAv4bctgazXeLNtdpQnmc9AadEVP)zZs4waOKS698rFF(7KU5QRzXeLNtdpQnmc9ASfCCF4ea(zdDHjbPhfLKvVNp67ZFN0nxVMftuEon8O2Wi0Rr4XZPrjz1hM8t2SeUfWruEUIUCXZh995Vt6MRUMftuEon8O2Wi0RbdHHeoUS1zXeLNtdpQnmc9AWaMz)zdWrTyIYZPHh1ggHEnytmXaMzBXeLNtdpQnmc9AeaPF60dAXSyIYZPHNfz1O0RMMfi6WItOKS6zcyzpmIkUnwy9ZEU3HaNaWhUi4Tw0RDiWja8HlcEFJETYIjkpNgEwKvJkc9AKV3aeNqjz17cGA)KTt4waF18ycGEo9HAHbq7qW0tYgEZoalEo9vS25wxUGAxau7NSDc3c4RMhta0ZPpulmaAhcMyXeCryaKftuEon8SiRgve61qTid8ZmahLKvVsG(3ZhDZISAuFm9KSHwmr550WZISAurOxd4ea(SjMSyIYZPHNfz1OIqVgWfzp3zcWnkjREr55k6tn9scEZvVCb1UaO2pSjM(sV)m48b9PPd1cdG2wmr550WZISAurOxJSvztyXjusw9kb6FpF0nlYQr9X0tYgYDUZ5a]] )


end
