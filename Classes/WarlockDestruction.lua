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


    spec:RegisterPack( "Destruction", 20190712.0005, [[dSu2pbqiaQhHcAtuqFIcunkaKtbaTkuG6vusMfk0Taqzxk5xeHHrr5yuuTmaPNrPIPrPsUgayBuG03ai14aeLZbqY6OuPmpkvDpI0(OaoifiSquKhcimrarUifOSrkvQ(iaQOgjaQ6KaeRuvyMaOs2jr0pbqfmuaurwkkq6PanvuuxfavOVsbI2lH)QObRYHjTyu6XOAYkCzKnRQ(mLy0QsNMQvJceVMsQzd1TvQDl53snCk0XbqLA5GEoKPlCDIA7QI(oGA8aIQZtPSEuaZNISFrlmxWSaCObjKeOMzoGYmaT5aDzMzMbOnZCbyyZijanQCRvlKaS0njabsekGY8W7saAuTHBDiywaIAziNeGVryez3KqclE8kZU49wcKVLXA4DXH6pKa5BUecqwzhhasjyfGdniHKa1mZbuMbOnhOlZmZmdQDSJauLJ3gkab9nqiaF9XGkbRaCqiUaKH5bKiuaL5H3vEgKke3CRZhmmV3imISBsiHfpELzx8ElbY3Yyn8U4q9hsG8nxI8bdZ7Hm2wEakgZdOMzoGkpawEMdOTBMda5J8bdZdiE1YcHSB5dgMhalpqJegNhaxn36v(GH5bWYJbL29tkpeH)RqHwOip(lXTEjaXokqcMfGV6ZMlywiP5cMfGuPSyAiysaYHEqqxfGSY))Iv5wpG6pwJg4kpdZd1Y4j6vHJ8mG08mppdZd1Y4j6vHJ8SxAE2Lau5H3LaK31hRwGAqIqijqfmlaPszX0qWKaKd9GGUkadftvS8kiyP4jV3SYOW7ArLYIPrEgMhK2QxO8SpVHmudVR8yW5z2caYZKP8aCEHIPkwEfeSu8K3Bwzu4DTOszX0ipdZdsFiHEvwmjavE4Dja99UXAqIqiPDemlaPszX0qWKaKd9GGUka5kkMHVP8SpVx9zZNqAREHeGkp8UeG8xTrt2ghIqiPDjywaQ8W7saIAz887qsasLYIPHGjriKeaemlaPszX0qWKaKd9GGUkavE4pPjv02juE2NNDYZKP8aCEHIPkwFhstTgtwOVrrx0IkLftdbOYdVlbi6vhnWSYWsecjnOcMfGuPSyAiysaYHEqqxfGCffZW3uE2N3R(S5tiTvVqcqLhExcqV4ErqniricbOriX7nRgcMfsAUGzbivklMgcMeHqsGkywasLYIPHGjriK0ocMfGuPSyAiysecjTlbZcqLhExcqK8E3103gfGuPSyAiysecjbabZcqQuwmnemja5qpiORcWqXufllqF3oKM9FIuo0)oNwuPSyAiavE4DjaTa9D7qA2)js5q)7CsecjnOcMfGuPSyAiysecjb0cMfGkp8UeGg7W7sasLYIPHGjriKeitWSau5H3Lae1Y453HKaKkLftdbtIqijGsWSaKkLftdbtcqo0dc6QaeW5fkMQyHAz887qArLYIPHau5H3La0lUxeudseIqaQnjywiP5cMfGuPSyAiysaYHEqqxfGgPy51NGLIxkp8NuEgMhaLhR8)V4qf96LLj)vB0A0ax5zYuEaoVqXufllqF3oKM9FIKncPTYTTOszX0ipampdZdGYdW5X7gpAGR1R(S5liPdB5zYuEkp8N0KkA7ekpdKNDYdafGkp8UeGq1Rz)NFhsIqijqfmlaPszX0qWKaKd9GGUkahDS89UXAqliTvVq5zG84kkMHVjbOYdVlbi)vRIWZbT767qsecjTJGzbivklMgcMeGkp8UeG(E3ynibih6bbDvacPT6fkp7ZdaYZW8aO8aCEHIPkwCnuo2gAVOszX0iptMYJ3nE0axlUgkhBdTxqAREHYZa5bPT6fkpauaYTXX0muOfkqcjnxecjTlbZcqQuwmnemjavE4Dja5kgpvE4DnXokeGyhfZs3KaKpqIqijaiywasLYIPHGjbOYdVlb4R(S5cqo0dc6Qau5H)KMurBNq5zFE2LaKBJJPzOqluGesAUiesAqfmlaPszX0qWKaKd9GGUkadftvSSa9D7qA2)js2iK2k32IkLftJ8mmpJuS86tWsXlLh(tkpdZdGY7vF28PYd)jLNjt5fkMQyX1q5yBO9IkLftJ8mzkVqXuflV(eS6fvklMg5zyEkp8N0KkA7ekp7ZZUYdafGkp8UeG8xTrt2ghIqijGwWSau5H3LaeQEn7)87qsasLYIPHGjriKeitWSau5H3La83CzenMkdqqpOjlPBbivklMgcMeHqsaLGzbOYdVlbOrzO)T5LLjlwrHaKkLftdbtIqiP5MjywasLYIPHGjbOYdVlb4R(S5cqo0dc6QaeGYdW5fkMQyzb672H0S)tKSriTvUTfvklMg5zYuEaoVqXuflV(eS6fvklMg5zYuEHIPkwwG(UDin7)ejBesBLBBrLYIPrEgMNrkwE9jyP4fK2QxO8SxAEMBwEaOaKBJJPzOqluGesAUiesAU5cMfGuPSyAiysaYHEqqxfGHIPkwFhstTgtwOVrrx0IkLftJ8mmpw5)FXQCRhq9hlzJ5zyEOwgprVkCKN95ba5bWYZSfqZJbNNYd)jnPI2oHeGkp8UeGEX9IGAqIqiP5avWSau5H3Lae1Y453HKaKkLftdbtIqiP52rWSaKkLftdbtcqo0dc6QaKv()xSk36bu)XA0axcqLhExcqExFSAbQbjcHKMBxcMfGuPSyAiysaYHEqqxfGaoVqXufRVdPPwJjl03OOlArLYIPHau5H3Lae9QJgywzyjcHKMdacMfGuPSyAiysaYHEqqxfGaoVrhlExCQcOg0y(X6MMSYWAbPT6fkpdZdW5P8W7AX7Itva1GgZpw30YR5h7wEJ8mmpLh(tAsfTDcLN95bacqLhExcqExCQcOg0y(X6MeHqsZnOcMfGkp8UeGEX9IGAqcqQuwmnemjcria5dKGzHKMlywasLYIPHGjbOYdVlbOYaOxfQO5VRy2)PXgycka5qpiORcqE34rdCTqY7DxtV(eSu8s2yEMmLhVB8ObUwi59URPxFcwkEbPT6fkp7ZdaeGLUjbOYaOxfQO5VRy2)PXgyckcHKavWSaKkLftdbtcqo0dc6QaK3nE0axRHcTEIAz80luOSo2dBliPdB5zYuE8UXJg4ATPDdTn7)elZ9XCajDJwqsh2YZKP8aO8aCEHIPkwdfA9e1Y4PxOqzDSh2wuPSyAKNH5b48ieIkoT20UH2M9FIL5(yoGKUrRTYG0W8aW8mzkpE34rdCTgk06jQLXtVqHY6ypSTG0w9cLN9sZZCZYZKP84DJhnW1At7gAB2)jwM7J5as6gTG0w9cLN9sZZCZeGkp8UeGi59URPxFcwkwecjTJGzbivklMgcMeGCOhe0vbOrkwE9jyP4LYd)jjavE4DjaTiRWHR1S)tLbiyhVIqiPDjywasLYIPHGjbih6bbDvaAKILxFcwkEP8WFs5zyEgPy51NGLIxqAREHYZEP5buZeGkp8UeGdfA9e1Y4PxOqzDSh2eHqsaqWSaKkLftdbtcqo0dc6Qa0iflV(eSu8s5H)KYZW8msXYRpblfVG0w9cLN9sZdOMjavE4Dja30UH2M9FIL5(yoGKUrIqiPbvWSaKkLftdbtcqo0dc6Qam8nnJEoCkpdKhVB8ObUwi59URPxFcwkEnKHA4DLNv5zhZeGkp8UeGi59URPxFcwkwecjb0cMfGuPSyAiysaYHEqqxfGHVP8mqE2XS8mmVW30m65WP8mqE8UXJg4AzrwHdxRz)NkdqWoExdzOgEx5zvE2XmbOYdVlbOfzfoCTM9FQmab74vecjbYemlaPszX0qWKaKd9GGUkadftvSgk06jQLXtVqHY6ypSTOszX0ipdZJ3nE0axRHcTEIAz80luOSo2dBliTvVq5zG8cFtZONdNeGkp8UeGi59URPxFcwkwecjbucMfGuPSyAiysaYHEqqxfG8UXJg4AHK37UME9jyP4fK2QxO8mqEHVPz0ZHtcqLhExcqlYkC4An7)uzac2XRiesAUzcMfGuPSyAiysaYHEqqxfG8UXJg4AHK37UME9jyP4fK2QxO8mqEHVPz0ZHtcqLhExcWHcTEIAz80luOSo2dBIqiP5MlywasLYIPHGjbih6bbDvaY7gpAGRfsEV7A61NGLIxqAREHYZa5f(MMrphojavE4Dja30UH2M9FIL5(yoGKUrIqiP5avWSaKkLftdbtcqo0dc6Qam8nnJEoCkp7ZZoMjavE4DjarY7DxtV(eSuSiesAUDemlaPszX0qWKaKd9GGUkadFtZONdNYZ(8SJzcqLhExcqlYkC4An7)uzac2XRiesAUDjywasLYIPHGjbih6bbDvag(MMrphoLN95buZeGkp8UeGdfA9e1Y4PxOqzDSh2eHqsZbabZcqQuwmnemja5qpiORcWW30m65WP8SppGAMau5H3LaCt7gAB2)jwM7J5as6gjcHKMBqfmlavE4DjazXDpM9FgV0KkABtasLYIPHGjriK0CaTGzbOYdVlbiWnepEsEnHeQlT4KaKkLftdbtIqiP5azcMfGkp8UeGq3Ormn9AImQCsasLYIPHGjriK0CaLGzbivklMgcMeGCOhe0vbOrkwE9jyP4LYd)jLNjt5fk0cfRW30m65WP8Spp7yMau5H3La0yhExIqijqntWSaKkLftdbtcqo0dc6Qa0iflV(eSu8s5H)KYZKP8yL))1M2n02S)tSm3hZbK0nAbPT6fkptMYJv()xdfA9e1Y4PxOqzDSh2wqAREHYZKP8cFtZONdNYZ(8SJzcqLhExcqwcIiO1EzrecjbQ5cMfGuPSyAiysaYHEqqxfGgPy51NGLIxkp8NuEMmLhR8)V20UH2M9FIL5(yoGKUrliTvVq5zYuESY))AOqRNOwgp9cfkRJ9W2csB1luEMmLx4BAg9C4uE2NNDmtaQ8W7saYI7Em)YqBIqijqbQGzbivklMgcMeGCOhe0vbOrkwE9jyP4LYd)jLNjt5Xk))RnTBOTz)NyzUpMdiPB0csB1luEMmLhR8)Vgk06jQLXtVqHY6ypSTG0w9cLNjt5f(MMrphoLN95zhZeGkp8UeGFhsS4UhIqijqTJGzbivklMgcMeGCOhe0vbOrkwE9jyP4LYd)jLNjt5Xk))RnTBOTz)NyzUpMdiPB0csB1luEMmLhR8)Vgk06jQLXtVqHY6ypSTG0w9cLNjt5f(MMrphoLN95zhZeGkp8UeGYiA6bTrIqijqTlbZcqQuwmnemjavE4Djan2CRPa5manM8EBuo0W7AoONoNeGCOhe0vb4OJLV3nwdAbPT6fkpdinpaqaw6MeGgBU1uGCgGgtEVnkhA4Dnh0tNtIqecWb9vzCiywiP5cMfGkp8UeGiJegpXn3AbivklMgcMeHqsGkywaQ8W7saI8Ycn3QfNlaPszX0qWKiesAhbZcqQuwmnemja5qpiORcWx9zZNkp8NuEgMNYd)jnPI2oHYZ(8aG8ay5fkMQy51NGvVOszX0ipRYdGYlumvXYRpbRErLYIPrEgMxOyQILxbblfp59MvgfExlQuwmnYdafGkp8UeGCfJNkp8UMyhfcqSJIzPBsa(QpBUiesAxcMfGkp8UeGCnuo2gAlaPszX0qWKiescacMfGuPSyAiysaYHEqqxfGkp8N0KkA7ekpdKhqfGkp8UeGCfJNkp8UMyhfcqSJIzPBsaQnjcHKgubZcqQuwmnemjavE4Dja99UXAqcqo0dc6QaesFiHEvwmLNH5bq5b48cftvS4AOCSn0ErLYIPrEMmLhVB8ObUwCnuo2gAVG0w9cLNbYdsB1luEaOaKBJJPzOqluGesAUiescOfmlaPszX0qWKaKd9GGUkadftvS8kiyP4jV3SYOW7ArLYIPrEgMNYdVRf)vB0KTXXYR5h7wEJ8mmpiTvVq5zFEdzOgEx5XGZZSfaiavE4Dja99UXAqIqijqMGzbivklMgcMeGkp8UeGCfJNkp8UMyhfcqSJIzPBsaYhiriKeqjywasLYIPHGjbih6bbDvac48msXYRpblfVuE4pP8mzkpaNxOyQILfOVBhsZ(prYgH0w52wuPSyAiavE4Dja)nxgrJPYae0dAYs6wecjn3mbZcqQuwmnemja5qpiORcqw5)FbjU1ycHM)gYPfKuEiavE4DjaJxAkxSTCnM)gYjriK0CZfmlavE4Djankd9VnVSmzXkkeGuPSyAiysecjnhOcMfGuPSyAiysaYHEqqxfGaoVrhlExCQcOg0y(X6MMSYWAbPT6fkpdZdW5P8W7AX7Itva1GgZpw30YR5h7wEdbOYdVlbiVlovbudAm)yDtIqiP52rWSau5H3LaK)Qvr45G2D9DijaPszX0qWKiesAUDjywasLYIPHGjbOYdVlb4R(S5cqo0dc6QaeGYB0XY37gRbTG0w9cLNbYB0XY37gRbTgYqn8UYJbNNzlaiptMYdW5fkMQy5vqWsXtEVzLrH31IkLftJ8aW8mmpakpaNhVB8ObUwi59URPxFcwkEbjDylptMYdW5fkMQyzb672H0S)tKSriTvUTfvklMg5zYuEHIPkwwG(UDin7)ejBesBLBBrLYIPrEgMNrkwE9jyP4fK2QxO8SxAEMBwEaOaKBJJPzOqluGesAUiesAoaiywaQ8W7saIAz887qsasLYIPHGjriK0CdQGzbivklMgcMeGCOhe0vbiR8)VyvU1dO(J1ObUYZW8qTmEIEv4ipdinpZxaqEaS8mBzN8yW5fkMQy9Xk6TFsWfvklMg5zyEaoVNk0vwmTm2nEIAz8e9QWbsaQ8W7saY76JvlqniriK0CaTGzbivklMgcMeGCOhe0vbiQLXt0Rch5zFEanpdZdGYdW59uHUYIPLXUXtulJNOxfoq5zYuE8xfAHq5zG8mppauaQ8W7saIE1rdmRmSeHqsZbYemlaPszX0qWKaSnkaruiavE4DjaFQqxzXKa8PILjbOYd)jnPI2oHYZa5zEEgMhVB8ObUwV6ZMVG0w9cLN9sZZCZYZKP84DJhnW1cjV3Dn96tWsXliTvVq5zV08aQz5zyEauEHIPkwwG(UDin7)ejBesBLBBrLYIPrEMmLxOyQI1qHwprTmE6fkuwh7HTfvklMg5zyE8UXJg4AnuO1tulJNEHcL1XEyBbPT6fkp7LMhqnlpamptMYlumvXAOqRNOwgp9cfkRJ9W2IkLftJ8mmpE34rdCTgk06jQLXtVqHY6ypSTG0w9cLN9sZdOMLNH5bq5X7gpAGRfsEV7A61NGLIxqAREHYZa5f(MMrphoLNjt5X7gpAGRfsEV7A61NGLIxqAREHYZQ84DJhnW1cjV3Dn96tWsXRHmudVR8mqEHVPz0ZHt5bGcWNkCw6MeGg7gprTmEIEv4ajcHKMdOemlaPszX0qWKaKd9GGUkabO8cftvSSa9D7qA2)js2iK2k32IkLftJ8mzkpLbiOh0Idv0RxwM8xTrlQuwmnYdaZZW8msXYRpblfVuE4pP8mzkpw5)FnuO1tulJNEHcL1XEyBjBmptMYJv()xqIBnMqO5VHCAbjLh5zyESY))csCRXecn)nKtliTvVq5zG84kkMHVjbOYdVlbi)vB0KTXHiescuZemlaPszX0qWKaKd9GGUkabCEpvORSyAzSB8e1Y4j6vHduEgMhGZlumvXIG6W5A4DTOszX0qaQ8W7saYF1gnzBCicHKa1CbZcqQuwmnemja5qpiORcqaN3tf6klMwg7gprTmEIEv4aLNH5fkMQyrqD4Cn8UwuPSyAKNH5bq5niw5)FrqD4Cn8UwqAREHYZ(84kkMHVP8mzkpw5)FXQCRhq9hlzJ5bGcqLhExcq(R2OjBJdriKeOavWSaKkLftdbtcqo0dc6QaeGYd1Y4j6vHJ8mG08SRfaKhalpZwanpgCEkp8N0KkA7ekpauaQ8W7saYF1gnzBCicHKa1ocMfGuPSyAiysaYHEqqxfG8xfAHq5zG8mxaQ8W7saY76JvlqniriKeO2LGzbOYdVlbOxCViOgKaKkLftdbtIqeIqa(KGiVlHKa1mZbuMbOndqTmhqBoaiabwHLxwqcqazBSHbnYdaYt5H3vEyhfOv(qaImsCHKa1GcOfGgH93XKaKH5bKiuaL5H3vEgKke3CRZhmmV3imISBsiHfpELzx8ElbY3Yyn8U4q9hsG8nxI8bdZ7Hm2wEMdugZdOMzoGkpawEMzMDZmZYh5dgMhq8QLfcz3YhmmpawEGgjmopaUAU1R8bdZdGLhdkT7NuEic)xHcTqrE8xIB9kFKpyyEgmGCIlh0ipw63qkpEVz1ipwYIxOvEgeCozmq5vDbWEv4(lJZt5H3fkVUW2w5dLhExOLriX7nRgs)yfzD(q5H3fAzes8EZQHvsL439iFO8W7cTmcjEVz1WkPsOYw2ufA4DLpuE4DHwgHeV3SAyLujqY7DxtJuKpuE4DHwgHeV3SAyLujSa9D7qA2)js5q)7CIr)lnumvXYc03TdPz)NiLd9VZPfvklMg5dLhExOLriX7nRgwjvcuPgrVDmrHgO8HYdVl0YiK49MvdRKkHXo8UYhkp8UqlJqI3BwnSsQeOwgp)oKYhkp8UqlJqI3BwnSsQeEX9IGAqm6FPaoumvXc1Y453H0IkLftJ8r(GH5zWaYjUCqJ8ONe0wEHVP8IxkpLhnmphLN(uDSYIPv(q5H3fskYiHXtCZToFO8W7czLujqEzHMB1IZZh5dgMhaV(S55jJiuEAEiJe3vCEgHEd9WwEyhf51vE7gf5TLXHhk0cf5H4uPqVrmMhRCKx8s5fk0cf5fVqc924rECTY7PcTL3Gms1Wll51vEHIPkq5dLhExiPCfJNkp8UMyhfmw6MK(QpBoJ(x6R(S5tLh(tYqLh(tAsfTDczpaaWcftvS86tWQxuPSyAyfafkMQy51NGvVOszX0WWqXuflVccwkEY7nRmk8UwuPSyAaG5dgMhqOHYX2q78qVTmEKhlLNmIg51vE8UXJg4kpfLhQ7kpfLNXgHCwmLpuE4DHSsQeCnuo2gANpyyEmdCNxOqluKhItLc9gLNcP8E1AGPrEy3AkpKxwWuEHcTqrEa7XBEa86ZMNhWK(Kg551kpWqHHxwYdypEZlEHeLxOqluGympnpKrI7k2zaAKNbrBWYZi0BOh2YZr5bjaULDinYhkp8UqwjvcUIXtLhExtSJcglDts1My0)svE4pPjv02jKbaA(GH5bi7DJ1GYd92Y4rEf9KG59vmoV()ZlEP8mc9TcTLxOqluSYdq(5beAOCSn0opGDmopi9He6npazVBSguES0VHuEEKhbKB0HeIX8IxcsgCuEvNhKuux5fDEaROGYl8nLhxrHxwYZJ8HYdVlKvsLW37gRbXi3ghtZqHwOaj1Cg9Vui9He6vzXKHaeGdftvS4AOCSn0ErLYIPHjt8UXJg4AX1q5yBO9csB1lKbG0w9cbG5dgMhdni94npaPccwkopGO3SYOW7kVqXuf0GX88WGJYZyJqolMYdq27gRbLhWogNxr0iVOZJLYdsFiHEPrEOUlcMx8QvEXlLhK2QxEzjVHmudVR8qQneJ55)8IxcsgCuEkgs6WwEAEaXR2O8yQXrEDLx8s5bSAlVOZlEP8cfAHIv(q5H3fYkPs47DJ1Gy0)sdftvS8kiyP4jV3SYOW7ArLYIPHHkp8Uw8xTrt2ghlVMFSB5nmesB1lK9dzOgExmyZwaq(GH5X8lLNfQiOIZdkJP86FEXR8MnVFdZlumvbkphLx05TvGCF7maLx8s5vYBwcMx)ZtgrO86FEKYFZhkp8UqwjvcUIXtLhExtSJcglDts5du(q5H3fYkPs8BUmIgtLbiOh0KL0nJ(xkGnsXYRpblfVuE4pjtMaCOyQILfOVBhsZ(prYgH0w52wuPSyAKpuE4DHSsQeXlnLl2wUgZFd5eJ(xkR8)VGe3AmHqZFd50cskpYhkp8UqwjvcJYq)BZlltwSII8HYdVlKvsLG3fNQaQbnMFSUjg9Vuap6yX7Itva1GgZpw30KvgwliTvVqgcyLhExlExCQcOg0y(X6MwEn)y3YBKpuE4DHSsQe8xTkcph0URVdP8bdZJ5xkp)NhVRHhEx59sqkpfdSAdLNA0i2juEa86ZMNx05H6nfVEzjVoEjyEXRw5fVuEgH(wH2YluOfkYhkp8UqwjvIx9zZzKBJJPzOqluGKAoJ(xkan6y57DJ1GwqAREHmWOJLV3nwdAnKHA4DXGnBbaMmb4qXuflVccwkEY7nRmk8UwuPSyAaGgcqaM3nE0axlK8E310RpblfVGKoSzYeGdftvSSa9D7qA2)js2iK2k32IkLftdtMcftvSSa9D7qA2)js2iK2k32IkLftddnsXYRpblfVG0w9czVuZndaZhmmpWwgNND3HuEO3wgpYJLYtgrJ86kpE34rdCXyEEK3OjuEvh5PgnskmpGBy8MhsF6LL8(nmplurqn8YsEGTmopWxfoq5nKHEzjpE34rdCHYhkp8UqwjvculJNFhs5dgMhq01hRwGAq5HEBz8iVUW2YJLYtgrJ8Iopef5jBmpG4vBuEm14aTYZUJv0B)KG5HPaLhq01hRwGAq5Xs5jJOrEKcXobZl68quKNSX80kpaP4ErqnO8yPFdP8acMw5bi)8082kdsdZJ3nE0ax55O8492ll5jBKX8q6tkp(RcTqO8(nmppYhkp8UqwjvcExFSAbQbXO)LYk))lwLB9aQ)ynAGldrTmEIEv4WasnFbaamZw2HbhkMQy9Xk6TFsWfvklMggc4Nk0vwmTm2nEIAz8e9QWbkFWW8aF1rdmRmSYZr5jJOrEkkpnVHJ4TCf5beD9XQfOguErNNfQiOguEOxfoq55)8S1Y5n6YGh59QpP8OQLT8M3VH5P5beVAJYJPghR8y(LYdPBkpOmMq5PSTCKhsF6LL88iVFdZBRminmpE34rdCHYtnAe7ekFO8W7czLujqV6ObMvgwm6FPOwgprVkCypqneGa8tf6klMwg7gprTmEIEv4azYe)vHwiKbmhaZhmmpajm4O8aUHXBEOO5w7LL8KnMxx5b2Y48aFv4aLhl9BiLNM3wzqAyE8UXJg4kpzKAHYhkp8UqwjvINk0vwmXyPBsQXUXtulJNOxfoqm(uXYKuLh(tAsfTDczaZnK3nE0axRx9zZxqAREHSxQ5MzYeVB8ObUwi59URPxFcwkEbPT6fYEPa1mdbOqXufllqF3oKM9FIKncPTYTTOszX0WKPqXufRHcTEIAz80luOSo2dBlQuwmnmK3nE0axRHcTEIAz80luOSo2dBliTvVq2lfOMbGMmfkMQynuO1tulJNEHcL1XEyBrLYIPHH8UXJg4AnuO1tulJNEHcL1XEyBbPT6fYEPa1mdbiE34rdCTqY7DxtV(eSu8csB1lKbcFtZONdNmzI3nE0axlK8E310RpblfVG0w9czfVB8ObUwi59URPxFcwkEnKHA4DzGW30m65WjamFWW8aIxTr5XuJJ8EvuEi6jbvCEgBeYzXuEYikpExdp8UqR8acOIE9YsEaXR2igZdGZqF3oKYR)5bkBesBLBJX80AKhqsHwNhylJTB5bifkuwh7HT8umoVV(SH5Xvu4LL8uuEBTSLhqWekpfLNXgHCwmLhWVuLNw2YR)5fV0opfs5P8WFs5dLhExiRKkb)vB0KTXbJ(xkafkMQyzb672H0S)tKSriTvUTfvklMgMmPmab9GwCOIE9YYK)QnArLYIPbaAOrkwE9jyP4LYd)jzYeR8)Vgk06jQLXtVqHY6ypSTKnAYeR8)VGe3AmHqZFd50cskpmKv()xqIBnMqO5VHCAbPT6fYaCffZW3u(GH5bi)8aBzCEGVkCGYtHuEvh5XsEzjpJDJPrEAnYZGb1HZ1W7kphLx1rEHIPkObJ5XGiJI8qgPAKhqWekpfLx8s2YJL49MYtFQowzXu(q5H3fYkPsWF1gnzBCWO)Lc4Nk0vwmTm2nEIAz8e9QWbYqahkMQyrqD4Cn8UwuPSyAKpyyEgKE8MNbdQdNRH3fJ55HbhLhlv035UIZl682kqUVDgGYlEP8Kng(MYRR8IxkVbXk))R8a4BGPNeKX88WGJYdfogNhlfbbZl68KruEaXR2O8yQXrE(EtdxdcBlp)Nhtk36bu)rEokpzJ5dLhExiRKkb)vB0KTXbJ(xkGFQqxzX0Yy34jQLXt0RchiddftvSiOoCUgExlQuwmnmeGgeR8)ViOoCUgExliTvVq2ZvumdFtMmXk))lwLB9aQ)yjBeaZhmmpd2tQYd4xQYdPp9YcJ5n68QoYRFsqUAmVUYdSLX5b(QWbkFO8W7czLuj4VAJMSnoy0)sbiulJNOxfomGu7AbaamZwaLbR8WFstQOTtiamFWW8asDzWJ86NeKRgZRR84Vk0cHYR)5beD9XQfOgu(q5H3fYkPsW76Jvlqnig9Vu(RcTqidyE(q5H3fYkPs4f3lcQbLpYhmmpgu1R86FE2Dhs55O8cBgDUIX2YlEP8EDlVekYZi0BOh2Yt5H3fJ5Xkh5XjyOELhYdzn8Uq591NnmpzKxwYdiE1gLhtnoYZluq6iFO8W7cT0MKcvVM9F(DiXO)LAKILxFcwkEP8WFsgcqSY))Idv0RxwM8xTrRrdCzYeGdftvSSa9D7qA2)js2iK2k32IkLftda0qacW8UXJg4A9QpB(cs6WMjtkp8N0KkA7eYa2baZhmmpG4vRIW5bKODxFhs51f2wEfrduEDr5bi7DJ1GYt5H)KYBid9YsEEGYJROiVFdZZGOnyR8a4e03k0wEHcTqrEokpzenY7LGuE)gMhY3gXo3dB5dLhExOL2KvsLG)Qvr45G2D9DiXO)Lo6y57DJ1GwqAREHmaxrXm8nLpyyEG(2XkmVOZd5LfmLxOqluWyEXlbP8CuEvNxr0iVOZdsFiHEZdq27gRbHYZ)5beAOCSn0opUw5n688ipVqbPJ8HYdVl0sBYkPs47DJ1GyKBJJPzOqluGKAoJ(xkK2Qxi7badbiahkMQyX1q5yBO9IkLftdtM4DJhnW1IRHYX2q7fK2QxidaPT6fcaZhmmpguzmHY73W84DJhnWfkVrNx1rE8xTSq59ByEgeTbJX8qDECfJZlEP8q6MYd7OipfLxx5H8YcMYluOfkYhkp8UqlTjRKkbxX4PYdVRj2rbJLUjP8bkFWW8y(fsuEHcTqbkphLNw55faJLcGjQYJRikV4vJ8S4pjuEAEiSB5nYJLk67rErN3RB5LG5ze6n0dB5bWRpBE(q5H3fAPnzLujE1NnNrUnoMMHcTqbsQ5m6FPkp8N0KkA7eYE7kFWW8yqvVYR)5z3DiLhWogNhkuyKx05n6TxAq51vEVK(0wEgeTbJX8yLJ8q9MYd5wk)7CTI8aIxTr5XuJJ8yL)FuEa7yCEOWX48S4pP8EDlVemVHUvluETCyuoYRR8AoxrEx5dLhExOL2KvsLG)QnAY24Gr)lnumvXYc03TdPz)NizJqARCBlQuwmnm0iflV(eSu8s5H)KmeGE1NnFQ8WFsMmfkMQyX1q5yBO9IkLftdtMcftvS86tWQxuPSyAyOYd)jnPI2oHS3UaW8bdZJjfc9YsEAzlpciNtgdVleJ5XGQELx)ZZU7qkpGDmopwkpzenYtr5TL5V5PO8m2iKZIjgZd5fNYBlJd3iMYJ3gDcLx)ZZJ84ALhkuU15dLhExOL2KvsLaQEn7)87qkFO8W7cT0MSsQe)MlJOXuzac6bnzjDNpuE4DHwAtwjvcJYq)BZlltwSII8bdZZG9KQ88FEXlLhaV(S55ze6n0dB5HDuKhWDzWJ8yP8Kr0GX8a41NnpphLNrifHT82Y838(qIYBOB1cLNwJ8GeQLHCcLNwJ8qVTmEKhlLNmIg5P4DJI86kpE34rdCLpuE4DHwAtwjvIx9zZzKBJJPzOqluGKAoJ(xkab4qXufllqF3oKM9FIKncPTYTTOszX0WKjahkMQy51NGvVOszX0WKPqXufllqF3oKM9FIKncPTYTTOszX0WqJuS86tWsXliTvVq2l1CZaW8bdZdGJikp7UdP80AKhtqFJIUO88FEmPCRhq9h55O8uE4pjgZtr5H7YsEkkppYdyhJZR6iV(jb5QX86kpWwgNh4RchO8HYdVl0sBYkPs4f3lcQbXO)LgkMQy9Din1AmzH(gfDrlQuwmnmKv()xSk36bu)Xs2OHOwgprVkCypaaWmBbugSYd)jnPI2oHYhmmpaoeVempWwgNh4Rch5zHkcQHxwYtzDShoHYtHuEw6EK33XycMN)ZR6ipzKxwYZU7qkpTg5Xe03OOlkFO8W7cT0MSsQeOwgp)oKYhkp8UqlTjRKkbVRpwTa1Gy0)szL))fRYTEa1FSgnWv(q5H3fAPnzLujqV6ObMvgwm6FPaoumvX67qAQ1yYc9nk6IwuPSyAKpuE4DHwAtwjvcExCQcOg0y(X6My0)sb8OJfVlovbudAm)yDttwzyTG0w9cziGvE4DT4DXPkGAqJ5hRBA518JDlVHHkp8N0KkA7eYEaiFWW8mi94np7UdP80AKhtqFJIUigZdqkUxeudkpGDmopwkpnpua7YsEFhJj4kpajm4O8mIvonY7LGuE)gMNIX5fkMQaLx05zespPkYt5CFqvOyST8KrEzjV4LYd5LfmLxOqluKhSdn8UYd7OiFO8W7cT0MSsQeEX9IGAq5J8HYdVl0IpqsLr00dAZyPBsQYaOxfQO5VRy2)PXgycYO)LY7gpAGRfsEV7A61NGLIxYgnzI3nE0axlK8E310RpblfVG0w9czpaKpyyEaYpp2oEZJ3nE0axO8uiLhK0HngZdjV3DLx8s5bi1NGLIZlEPkpLh(tnO8asGaYkpa5Nx1rEYiVSKhqceqympzeLx86O86kpGaiLpuE4DHw8bYkPsGK37UME9jyPyg9VuE34rdCTgk06jQLXtVqHY6ypSTGKoSzYeVB8ObUwBA3qBZ(pXYCFmhqs3OfK0HntMaiahkMQynuO1tulJNEHcL1XEyBrLYIPHHaMqiQ40At7gAB2)jwM7J5as6gT2kdsdbqtM4DJhnW1AOqRNOwgp9cfkRJ9W2csB1lK9sn3mtM4DJhnW1At7gAB2)jwM7J5as6gTG0w9czVuZnlFO8W7cT4dKvsLWISchUwZ(pvgGGD8YO)LAKILxFcwkEP8WFs5dLhExOfFGSsQedfA9e1Y4PxOqzDSh2y0)snsXYRpblfVuE4pjdnsXYRpblfVG0w9czVuGAw(q5H3fAXhiRKkXM2n02S)tSm3hZbK0nIr)l1iflV(eSu8s5H)Km0iflV(eSu8csB1lK9sbQz5dgMhG8Zdibci55O8QoYds6WwESYrE2A584ALNfkYB3qkV4vR86IYZRpblfNNx5Xs)gs5fVuEunYR)5fVuEF3YBWyEi59UR8IxkpaP(eSuCEvdC(q5H3fAXhiRKkbsEV7A61NGLIz0)sdFtZONdNmaVB8ObUwi59URPxFcwkEnKHA4DzLDmlFO8W7cT4dKvsLWISchUwZ(pvgGGD8YO)Lg(MmGDmZWW30m65WjdW7gpAGRLfzfoCTM9FQmab74DnKHA4DzLDmlFWW8aKFEXlL33T8g5bSJX5r1ipw63qkpGeiGKNJYJv5wNNSrgZdjV3DLx8s5bi1NGLIZhkp8Uql(azLujqY7DxtV(eSumJ(xAOyQI1qHwprTmE6fkuwh7HTfvklMggY7gpAGR1qHwprTmE6fkuwh7HTfK2Qxide(MMrphoLpuE4DHw8bYkPsyrwHdxRz)NkdqWoEz0)s5DJhnW1cjV3Dn96tWsXliTvVqgi8nnJEoCkFWW8aKFEXlL33T8g5bSJX5r1ipw63qkpV(eSuCEokpwLBDEYgzmpzeLhqceqYhkp8Uql(azLujgk06jQLXtVqHY6ypSXO)LY7gpAGRfsEV7A61NGLIxqAREHmq4BAg9C4u(q5H3fAXhiRKkXM2n02S)tSm3hZbK0nIr)lL3nE0axlK8E310RpblfVG0w9czGW30m65WP8bdZdq(5fVuEF3YBKNJYtzB5iVOZJQbJ5jJO8acGekpKm)nV4vJ8IxYwEwOipfL3wM)Mx4BkpzJ5PO8m2iKZIP8HYdVl0IpqwjvcK8E310RpblfZO)Lg(MMrphozVDmlFO8W7cT4dKvsLWISchUwZ(pvgGGD8YO)Lg(MMrphozVDmlFO8W7cT4dKvsLyOqRNOwgp9cfkRJ9WgJ(xA4BAg9C4K9a1S8HYdVl0IpqwjvInTBOTz)NyzUpMdiPBeJ(xA4BAg9C4K9a1S8HYdVl0IpqwjvcwC3Jz)NXlnPI22Yhkp8Uql(azLujaUH4XtYRjKqDPfNYhkp8Uql(azLujGUrJyA61ezu5u(q5H3fAXhiRKkHXo8Uy0)snsXYRpblfVuE4pjtMcfAHIv4BAg9C4K92XS8HYdVl0IpqwjvcwcIiO1EzHr)l1iflV(eSu8s5H)KmzIv()xBA3qBZ(pXYCFmhqs3OfK2QxitMyL))1qHwprTmE6fkuwh7HTfK2QxitMcFtZONdNS3oMLpuE4DHw8bYkPsWI7Em)YqBm6FPgPy51NGLIxkp8NKjtSY))At7gAB2)jwM7J5as6gTG0w9czYeR8)Vgk06jQLXtVqHY6ypSTG0w9czYu4BAg9C4K92XS8HYdVl0IpqwjvIVdjwC3dg9VuJuS86tWsXlLh(tYKjw5)FTPDdTn7)elZ9XCajDJwqAREHmzIv()xdfA9e1Y4PxOqzDSh2wqAREHmzk8nnJEoCYE7yw(q5H3fAXhiRKkHmIMEqBeJ(xQrkwE9jyP4LYd)jzYeR8)V20UH2M9FIL5(yoGKUrliTvVqMmXk))RHcTEIAz80luOSo2dBliTvVqMmf(MMrphozVDmlFO8W7cT4dKvsLqgrtpOnJLUjPgBU1uGCgGgtEVnkhA4Dnh0tNtm6FPJow(E3ynOfK2QxidifaYh5dLhExO1R(S5s5D9XQfOgeJ(xkR8)VyvU1dO(J1ObUme1Y4j6vHddi1CdrTmEIEv4WEP2v(q5H3fA9QpBUvsLW37gRbXO)LgkMQy5vqWsXtEVzLrH31IkLftddH0w9cz)qgQH3fd2SfayYeGdftvS8kiyP4jV3SYOW7ArLYIPHHq6dj0RYIP8HYdVl06vF2CRKkb)vB0KTXbJ(xkxrXm8nz)R(S5tiTvVq5dLhExO1R(S5wjvculJNFhs5dLhExO1R(S5wjvc0RoAGzLHfJ(xQYd)jnPI2oHS3oMmb4qXufRVdPPwJjl03OOlArLYIPr(q5H3fA9QpBUvsLWlUxeudIr)lLROyg(MS)vF28jK2QxiricHa]] )


end
