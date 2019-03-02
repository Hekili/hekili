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

    spec:RegisterStateExpr( "active_havoc", function ()
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


    spec:RegisterPack( "Destruction", 20190302.0100, [[dW03(aqiiPEKkjBIuLpbjrJsiQtjuYQusLELqywqIBrQQSlv8lsHHPKYXifTmvk9mvkmnHiUMsQABKsfFJuQQXPKk6CqsY6iLQmpvsDpbzFKs5GQuuwiKYdfk1efI0fHKWgjvv5JQuKYijvv1jjvLvkuntijvDtsPs2jPKFcjPIHQsrYsvPO6PqmvivxvLIu9vvkI9IQ)QQgSKdtSyu8ysMSsDzKnJsFMuz0kXPfTAsPs9AHIzd62QYUL63kgUG64qsQ0YH65atNQRlW2vs(UkvJxjv48cP1djPmFvI9tzUMC05iBXjUw3UMMOQ1UXA3EwBT1JQw7gCepAyIJewuXi6ioslpIJePeWXbkpNMJewIchzZrNJaMaSI4ilUhgO90qdDPVeWCuZtdq(cGINtRWcRRbiFknyGdJgmSI(TPvAegpSjKaAGEs4B1ud0VvZ)nrWWrfZpsjGJduEo9bKpfhHjiHU(AodhzloX16210evT2nwtZZT3E7n0u7ZrKaFzWCeK8fBoYsU3uZz4iBcO4ixzvKsahhO8CARUjcgoQyS4xz1I7HbApn0qx6lbmh180aKVaO450kSW6AaYNsdl(vwPDjy1IvAIIv3UMMOkR0pR0CnTNMAhRUP0US4w8RSk2lsRJaApl(vwPFwHeMGqRq1pQyoCeycCahDoYISAuC05APjhDoc1cdK2C04ikC6eofoctal7HruXSXcRF2Z92k9ScmbWpyrWBR0wiR00k9ScmbWpyrWBRUoKvrchruEonhrnnlu0HfN4oxRB5OZrOwyG0MJghrHtNWPWrCbsTFY2jClWVAEmbapN(qTWaPTv6zfMEs2aRU2QDaw8CARwxRw7SERUCXkuBLlqQ9t2oHBb(vZJja450hQfgiTTspRWelMalcdK4iIYZP5i57nqXjUZ16gC05iulmqAZrJJOWPt4u4ikb4FpFKvxB1ISAuFm9KSbCer550Ce1ImGpZaDUZ1ks4OZreLNtZrata8ZMyIJqTWaPnhnUZ1A9C05iulmqAZrJJOWPt4u4iIYZv0NA6LeWQRT6gwD5IvO2kxGu7h2etFP3FgC(a(00HAHbsBoIO8CAocyr2ZDMaCZDUwAho6CeQfgiT5OXru40jCkCeLa8VNpYQRTArwnQpMEs2aoIO8CAos2QSjS4e35ohjmMuZJrCo6CT0KJohHAHbsBoACNR1TC05iulmqAZrJ7CTUbhDoc1cdK2C04oxRiHJohruEonhbe8Et)Zxyoc1cdK2C04oxR1ZrNJqTWaPnhnoIcNoHtHJ4cKA)OdNVjX0Fy)arHt2urhQfgiT5iIYZP5i6W5Bsm9h2pqu4Knve35APD4OZrOwyG0MJg35AP95OZreLNtZrcpEonhHAHbsBoACNR16KJohruEonhbmbWpBIjoc1cdK2C04oxlufhDoc1cdK2C04ikC6eofocQTYfi1(bmbWpBIPd1cdK2Cer550CKSvztyXjUZDoImehDUwAYrNJqTWaPnhnoIcNoHtHJeM8t2SeUf4ruEUISspRISvmbSShfwalzR7RwKbC2Z92QlxSc1w5cKA)OdNVjX0Fy)GGWy6jQOhQfgiTTkwwPNvr2kuBLAg4EU3Nfz1Ooys2rT6YfReLNROp10ljGvAZQByvS4iIYZP5iyj7)W(ztmXDUw3YrNJqTWaPnhnoIcNoHtHJSh)KV3afNoy6jzdSsBwPeG)98rCer550Ce1I0nb)B6nnBIjUZ16gC05iulmqAZrJJikpNMJKV3afN4ikC6eofocMEs2aRU2Q1BLEwfzRqTvUaP2pkXffmk4DOwyG02QlxSsndCp37JsCrbJcEhm9KSbwPnRW0tYgyvS4iQOki9DbRJCaxln5oxRiHJohHAHbsBoACer550CeLaHFr550FycCocmb(VLhXruBa35ATEo6CeQfgiT5OXreLNtZrwKvJIJOWPt4u4iIYZv0NA6LeWQRTks4iQOki9DbRJCaxln5oxlTdhDoc1cdK2C04ikC6eofoIlqQ9JoC(Met)H9dccJPNOIEOwyG02k9Skm5NSzjClWJO8CfzLEwfzRwKvJ6lkpxrwD5IvUaP2pkXffmk4DOwyG02QlxSYfi1(jBwc3ZHAHbsBR0Zkr55k6tn9scy11wfjwfloIO8CAoIArgWNzGo35AP95OZreLNtZrWs2)H9ZMyIJqTWaPnhnUZ1ADYrNJqTWaPnhnoIO8CAoYISAuCefoDcNchjYwHARCbsTF0HZ3Ky6pSFqqym9ev0d1cdK2wD5IvO2kxGu7NSzjCphQfgiTT6YfRCbsTF0HZ3Ky6pSFqqym9ev0d1cdK2wPNvHj)KnlHBbEW0tYgy11HSsZ1SkwCevufK(UG1roGRLMCNRfQIJohHAHbsBoACefoDcNchXfi1(HnX0x69NbNpGpnDOwyG02k9SIjGL9WiQy2yH1pbHTspRata8dwe82QRTA9wPFwT25wRwxReLNROp10ljahruEonhjBv2ewCI7CT0Cno6Cer550CeWea)SjM4iulmqAZrJ7CT0uto6CeQfgiT5OXru40jCkCeMaw2dJOIzJfw)SN7nhruEonhrnnlu0HfN4oxlnVLJohHAHbsBoACefoDcNchb1w5cKA)WMy6l9(ZGZhWNMoulmqAZreLNtZralYEUZeGBUZ1sZBWrNJikpNMJKTkBcloXrOwyG0MJg35ohrTbC05APjhDoc1cdK2C04ikC6eofoIAg4EU3NTGJ5dMa4pBGlmjm9Ohmj7OwD5IvO2kxGu7NTGJ5dMa4pBGlmjm9OhQfgiT5iIYZP5iGG3B6F2SeUfi35ADlhDoc1cdK2C04ikC6eofosyYpzZs4wGhr55kIJikpNMJSfCmFWea)zdCHjHPhL7CTUbhDoc1cdK2C04ikC6eofoINp67ZFNKvAZk1mW9CVpGG3B6F2SeUf4zhGfpNMJikpNMJacEVP)zZs4wGCNRvKWrNJqTWaPnhnoIcNoHtHJ45J((83jzL2SsndCp37ZwWX8bta8NnWfMeME0ZoalEoTvry1TRXreLNtZr2coMpycG)SbUWKW0JYDUwRNJohHAHbsBoACefoDcNchXfi1(zl4y(Gja(Zg4ctctp6HAHbsBR0Zk1mW9CVpBbhZhmbWF2axysy6rpy6jzdSsBw55J((83jXreLNtZrabV30)SzjClqUZ1s7WrNJqTWaPnhnoIcNoHtHJOMbUN79be8Et)ZMLWTapy6jzdSsBw55J((83jXreLNtZr2coMpycG)SbUWKW0JYDUwAFo6CeQfgiT5OXru40jCkCepF03N)ojRU2QBSghruEonhbe8Et)ZMLWTa5oxR1jhDoc1cdK2C04ikC6eofoINp67ZFNKvxB1TRXreLNtZr2coMpycG)SbUWKW0JYDUwOko6CeQfgiT5OXru40jCkCKWKFYMLWTapIYZvKvxUyLNp67ZFNKvxB1nwJJikpNMJeE8CAUZ1sZ14OZreLNtZryimGWXKTooc1cdK2C04oxln1KJohruEonhHboZ(ZgGJYrOwyG0MJg35AP5TC05iIYZP5iSjMyGZS5iulmqAZrJ7CT08gC05iIYZP5iba6No9aCeQfgiT5OXDUZr2eReaDo6CT0KJohruEonhbeMGWpCuXWrOwyG0MJg35ADlhDoIO8CAociBD0)j6sfhHAHbsBoACNR1n4OZrOwyG0MJghrHtNWPWrwKvJ6lkpxrwPNvIYZv0NA6LeWQRTA9wPFw5cKA)KnlH75qTWaPTvryvKTYfi1(jBwc3ZHAHbsBR0ZkxGu7NSDc3c8RMhtaWZPpulmqABvS4iIYZP5ikbc)IYZP)We4Ceyc8FlpIJSiRgf35AfjC05iIYZP5ikXffmk4XrOwyG0MJg35ATEo6CeQfgiT5OXru40jCkCer55k6tn9scyL2S6woIO8CAoIsGWVO8C6pmbohbMa)3YJ4iYqCNRL2HJohHAHbsBoACer550CK89gO4ehrHtNWPWrWelMalcdKSspRISvO2kxGu7hL4Icgf8oulmqAB1LlwPMbUN79rjUOGrbVdMEs2aR0Mvy6jzdSkwCevufK(UG1roGRLMCNRL2NJohHAHbsBoACefoDcNchXfi1(jBNWTa)Q5Xea8C6d1cdK2wPNvIYZPpQfzaFMb6NS)SWu3IBLEwHPNKnWQRTAhGfpN2Q11Q1oRNJikpNMJKV3afN4oxR1jhDoc1cdK2C04iIYZP5ikbc)IYZP)We4Ceyc8FlpIJO2aUZ1cvXrNJikpNMJOwKUj4FtVPztmXrOwyG0MJg35AP5AC05iulmqAZrJJikpNMJSiRgfhrHtNWPWrISv7Xp57nqXPdMEs2aR0Mv7Xp57nqXPZoalEoTvRRvRDwVvxUyfQTYfi1(jBNWTa)Q5Xea8C6d1cdK2wflR0ZQiBfQTsndCp37di49M(NnlHBbEWKSJA1LlwHARCbsTF0HZ3Ky6pSFqqym9ev0d1cdK2wD5IvUaP2p6W5Bsm9h2piimMEIk6HAHbsBR0ZQWKFYMLWTapy6jzdS66qwP5AwfloIkQcsFxW6ihW1stUZ1stn5OZreLNtZrata8ZMyIJqTWaPnhnUZ1sZB5OZrOwyG0MJghrHtNWPWrycyzpmIkMnwy9ZEU3wPNvGja(blcEBL2czLMN1BL(z1ANBy16ALlqQ9dlualZkcFOwyG02k9Sc1wTsWPWaPt4zGFWea)GfbVbCer550Ce10SqrhwCI7CT08gC05iulmqAZrJJOWPt4u4iGja(blcEB11wDRv6zvKTc1wTsWPWaPt4zGFWea)GfbVbwD5IvQfbRJawPnR00QyXreLNtZralYEUZeGBUZ1sZiHJohHAHbsBoACKvcmG4iIYZv0NA6LeWkTzLMwPNvQzG75EFwKvJ6GPNKnWQRdzLMRz1LlwPMbUN79be8Et)ZMLWTapy6jzdS66qwD7AwPNvr2kxGu7hD48njM(d7heegtprf9qTWaPTvxUyLlqQ9ZwWX8bta8NnWfMeME0d1cdK2wPNvQzG75EF2coMpycG)SbUWKW0JEW0tYgy11HS621SkwwD5IvUaP2pBbhZhmbWF2axysy6rpulmqABLEwPMbUN79zl4y(Gja(Zg4ctctp6btpjBGvxhYQBxZk9SkYwPMbUN79be8Et)ZMLWTapy6jzdSsBw55J((83jz1LlwPMbUN79be8Et)ZMLWTapy6jzdSkcRuZa3Z9(acEVP)zZs4wGNDaw8CAR0MvE(OVp)DswfloIO8CAoYkbNcdK4iRe8VLhXrcpd8dMa4hSi4nG7CT0C9C05iulmqAZrJJOWPt4u4ir2kxGu7hD48njM(d7heegtprf9qTWaPTvxUyLGQr40PJclGLS19vlYaoulmqABvSSspRct(jBwc3c8ikpxrwD5IvmbSSNTGJ5dMa4pBGlmjm9ONGWCer550Ce1ImGpZaDUZ1stTdhDoc1cdK2C04ikC6eofocQTALGtHbsNWZa)Gja(blcEdSspRqTvUaP2pew2Ps8C6d1cdK2Cer550Ce1ImGpZaDUZ1stTphDoc1cdK2C04ikC6eofocQTALGtHbsNWZa)Gja(blcEdSspRCbsTFiSStL450hQfgiTTspRISvBIjGL9qyzNkXZPpy6jzdS6ARucW)E(iRUCXkMaw2dJOIzJfw)ee2QyXreLNtZrulYa(md05oxlnxNC05iulmqAZrJJOWPt4u4ir2kWea)GfbVTsBHSksoR3k9ZQ1o3A16ALO8Cf9PMEjbSkwCer550Ce1ImGpZaDUZ1stufhDoc1cdK2C04ikC6eofoIArW6iGvAZkn5iIYZP5iQPzHIoS4e35AD7AC05iIYZP5izRYMWItCeQfgiT5OXDUZDoYkcdYP5AD7AAUo1CTBV9CRMrI2NJCxWD26aCe99cpyN2wTEReLNtBfmbo4yX5iHXdBcjoYvwfPeWXbkpN2QBIGHJkgl(vwT4EyG2tdn0L(saZrnpna5lakEoTclSUgG8P0WIFLvAxcwTyLMOy1TRPjQYk9Zknxt7PP2XQBkTllUf)kRI9I06iG2ZIFLv6NviHji0ku9JkMJf)kR0pRU50BwrwbY3XfSoYTsTqQyowCl(vwHkwhKkWPTvme7GjRuZJrCRyiDzdowDZukkSdSQNw)we8JnaALO8CAGvtdJES4IYZPbNWysnpgXdXcfqmwCr550GtymPMhJ4resd2z2wCr550GtymPMhJ4resdjq3JAx8CAlUO8CAWjmMuZJr8icPbi49M(hMClUO8CAWjmMuZJr8icPHoC(Met)H9defoztfHsYgYfi1(rhoFtIP)W(bIcNSPIoulmqABXfLNtdoHXKAEmIhrinaTegSm(h4IdS4IYZPbNWysnpgXJiKgHhpN2IlkpNgCcJj18yepIqAaMa4NnXKfxuEon4egtQ5XiEeH0iBv2ewCcLKneQDbsTFata8ZMy6qTWaPTf3IFLvOI1bPcCABfTIWrTYZhzLVqwjkFWwLaRKvscfgiDS4IYZPbHaHji8dhvmwCr550GicPbiBD0)j6sLf3IFLv6Fz1OSkaqaReRaHjvkqRcJZbNEuRGjWTAAREdWT6fa90fSoYTcOOwW5aqXkMa3kFHSYfSoYTYxWeyzGBRusB1kbh1QnfM6D26SAARCbsTdS4IYZPbHuce(fLNt)HjWrPLhfArwnkus2qlYQr9fLNRi9eLNROp10ljW1Rx)CbsTFYMLW9COwyG0oIi7cKA)KnlH75qTWaPTEUaP2pz7eUf4xnpMaGNtFOwyG0oww8RSk2IlkyuWZkWYea3wXqwfaOTvtBLAg4EU3wjaRaZ0wjaRcpaqYajlUO8CAqeH0qjUOGrbpl(vwH(9XkxW6i3kGIAbNdWkbtwTi9gsBRGzmKvGS1bjRCbRJCRUN(Iv6Fz1OS6ojROTvzFScXfSNToRUN(Iv(cMiRCbRJCakwjwbctQuGjQgTT6MnOcRcJZbNEuRsGvycv3GetBlUO8CAqeH0qjq4xuEo9hMahLwEuizius2qIYZv0NA6LeqB3AXVYk99EduCYkWYea3w10kcBfRaHwnSSw5lKvHX5tWrTYfSoYpwPpwRIT4Icgf8S6EcHwHjwmbwSsFV3afNSIHyhmzv6wrRJWjMaOyLVqycvcSQhRWKaM2kFS6UaCYkpFKvkb4zRZQ0T4IYZPbresJ89gO4ekQOki9DbRJCqinrjzdHjwmbwegiPxKrTlqQ9JsCrbJcEhQfgiTVCrndCp37JsCrbJcEhm9KSbAdtpjBqSS4xz1v3K0xSsFTt4wGwf75Xea8CARCbsTtBuSkDujWQWdaKmqYk99EduCYQ7jeAvt02kFSIHSctSycSqBRaZ0e2kFrAR8fYkm9KSZwNv7aS450wbKOauSkzTYximHkbwjqmj7Owjwf7fzawH2aDRM2kFHS6Ue1kFSYxiRCbRJ8JfxuEoniIqAKV3afNqjzd5cKA)KTt4wGF18ycaEo9HAHbsB9eLNtFulYa(md0pz)zHPUfxpm9KSbxVdWINtVURDwVf)kRqFHSsh1ewGwHdGKvdRv(sWJXk2bBLlqQDGvjWkFS6jRJ8LOAKv(czvh8yiSvdRvbacy1WAfjQflUO8CAqeH0qjq4xuEo9hMahLwEui1gyXfLNtdIiKgQfPBc(30BA2etw8RSc9fYQK1k1070ZPTAHWKvc8UefyLeommjGv6Fz1OSYhRaZJ8LS1z14le2kFrAR8fYQW48j4Ow5cwh5wCr550GicPXISAuOOIQG03fSoYbH0eLKnuK3JFY3BGIthm9KSbABp(jFVbkoD2byXZPx31oR)Yfu7cKA)KTt4wGF18ycaEo9HAHbs7yPxKrTAg4EU3hqW7n9pBwc3c8Gjzh9Yfu7cKA)OdNVjX0Fy)GGWy6jQOhQfgiTVCXfi1(rhoFtIP)W(bbHX0turpulmqARxyYpzZs4wGhm9KSbxhsZ1ILf)kRqMaOv6VetwbwMa42kgYQaaTTAARuZa3Z9gfRs3Q9qaR6XTschMeSv3hSVyfqwLToRyhSv6OMWINToRqMaOvilcEdSAhGZwNvQzG75EdS4IYZPbresdWea)SjMS4xzvSNMfk6WItwbwMa42QPHrTIHSkaqBR8Xka5wfe2QyVidWk0gOdowP)GcyzwryRGKdSk2tZcfDyXjRyiRca02ksWWKWw5JvaYTkiSvsBL(Av2ewCYkgIDWKvXgTJv6J1kXQNODpyRuZa3Z92QeyLAEzRZQGWOyfqwrwPweSocyf7GTkDlUO8CAqeH0qnnlu0HfNqjzdXeWYEyevmBSW6N9CV1dmbWpyrWBTfsZZ61V1o3yDDbsTFyHcyzwr4d1cdK26H6vcofgiDcpd8dMa4hSi4nWIFLvilYEUZeGBRsGvbaABLaSsSANa1e0UvXEAwOOdlozLpwPJAclozfyrWBGvjRvrNaR2tJkDRwKvKvupb6wSIDWwjwf7fzawH2a9JvOVqwbKhzfoasaReMjWTciRYwNvPBf7GT6jA3d2k1mW9CVbwjHddtcyXfLNtdIiKgGfzp3zcWnkjBiWea)GfbVV(w9ImQxj4uyG0j8mWpycGFWIG3Glxulcwhb0MMXYIFLv6ZrLaRUpyFXkGpQyYwNvbHTAARqMaOvilcEdSIHyhmzLy1t0UhSvQzG75EBvaq0rwCr550GicPXkbNcdKqPLhfk8mWpycGFWIG3auwjWakKO8Cf9PMEjb0MM6PMbUN79zrwnQdMEs2GRdP5AxUOMbUN79be8Et)ZMLWTapy6jzdUo0TRPxKDbsTF0HZ3Ky6pSFqqym9ev0d1cdK2xU4cKA)SfCmFWea)zdCHjHPh9qTWaPTEQzG75EF2coMpycG)SbUWKW0JEW0tYgCDOBxlwxU4cKA)SfCmFWea)zdCHjHPh9qTWaPTEQzG75EF2coMpycG)SbUWKW0JEW0tYgCDOBxtViRMbUN79be8Et)ZMLWTapy6jzd0MNp67ZFN0LlQzG75EFabV30)SzjClWdMEs2GiuZa3Z9(acEVP)zZs4wGNDaw8CAT55J((83jfll(vwf7fzawH2aDRweGvaAfHfOvHhaizGKvbaYk1070ZPbhRInwalzRZQyVidafRUPHZ3KyYQH1kKGWy6jQOOyL0BRIubhJvitau7zL(AGlmjm9OwjqOvSYQbBLsaE26Ssaw9KoQvXgnGvcWQWdaKmqYQ7luBL0rTAyTYxONvcMSsuEUIS4IYZPbresd1ImGpZaDus2qr2fi1(rhoFtIP)W(bbHX0turpulmqAF5IGQr40PJclGLS19vlYaoulmqAhl9ct(jBwc3c8ikpxrxUWeWYE2coMpycG)SbUWKW0JEccBXVYk9XAfYeaTczrWBGvcMSQh3kgkBDwfEgiTTs6TvOcSStL450wLaR6XTYfi1oTrXkT7aGBfim1BRInAaReGv(cf1kgsnpYkzLKqHbswCr550GicPHArgWNzGokjBiuVsWPWaPt4zGFWea)GfbVb6HAxGu7hcl7ujEo9HAHbsBl(vwDtsFXkubw2Ps8CAuSkDujWkgQj2uLc0kFS6jRJ8LOAKv(czvqypFKvtBLVqwTjMaw2Jv6)5oTIWOyv6OsGvapHqRyi3jSv(yvaGSk2lYaScTb6wLVhTtXjyuRswRqtuXSXcRBvcSkiSfxuEoniIqAOwKb8zgOJsYgc1ReCkmq6eEg4hmbWpyrWBGEUaP2pew2Ps8C6d1cdK26f5nXeWYEiSStL450hm9KSbxReG)98rxUWeWYEyevmBSW6NGWXYIFLvOIvuB19fQTciRYwhkwThR6XTAwryLe2QPTczcGwHSi4nWIlkpNgerinulYa(md0rjzdfzWea)GfbV1wOi5SE9BTZTRRO8Cf9PMEjbILf)kRI0PrLUvZkcRKWwnTvQfbRJawnSwf7PzHIoS4KfxuEoniIqAOMMfk6WItOKSHulcwhb0MMwCr550GicPr2QSjS4Kf3IFLv3CjBRgwR0FjMSkbw5rdNkbcJALVqwTK6wiGBvyCo40JALO8CAuSIjWTsryxY2kq6bINtdSIvwnyRcazRZQyVidWk0gOBv2aNKTfxuEon4idfclz)h2pBIjus2qHj)KnlHBbEeLNRi9Imtal7rHfWs26(QfzaN9CVVCb1UaP2p6W5Bsm9h2piimMEIk6HAHbs7yPxKrTAg4EU3Nfz1Ooys2rVCruEUI(utVKaA7gXYIFLvXEr6MGwfP0BA2etwnnmQvnrBGvttwPV3BGItwjkpxrwTdWzRZQ0bwPeGBf7GT6MnOIJv3u48j4Ow5cwh5wLaRca02QfctwXoyRa5lmmvPh1IlkpNgCKHIiKgQfPBc(30BA2etOKSH2JFY3BGIthm9KSbAtja)75JS4xzfs(sOGTYhRazRdsw5cwh5OyLVqyYQeyvpw1eTTYhRWelMalwPV3BGItaRswRIT4Icgf8SsjTv7XQ0TkBGtY2IlkpNgCKHIiKg57nqXjuurvq67cwh5GqAIsYgctpjBW1RxViJAxGu7hL4Icgf8oulmqAF5IAg4EU3hL4Icgf8oy6jzd0gMEs2GyzXVYQBEaKawXoyRuZa3Z9gy1ESQh3k1I06iRyhSv3SbvGIvGXkLaHw5lKva5rwbtGBLaSAARazRdsw5cwh5wCr550GJmueH0qjq4xuEo9hMahLwEui1gyXVYk0xWezLlyDKdSkbwjTvzRFmKFNO2kLaiR8fXTsxUIawjwbGPUf3kgQj20TYhRwsDle2QW4CWPh1k9VSAuwCr550GJmueH0yrwnkuurvq67cwh5GqAIsYgsuEUI(utVKaxhjw8RS6MlzB1WAL(lXKv3ti0kGly3kFSApVSfNSAARwizvuRUzdQafRycCRaZJScK66Knvs7wf7fzawH2aDRycyzbwDpHqRaEcHwPlxrwTK6wiSvB5j6iRMapCGB10wnkLaYPT4IYZPbhzOicPHArgWNzGokjBixGu7hD48njM(d7heegtprf9qTWaPTEHj)KnlHBbEeLNRi9I8ISAuFr55k6YfxGu7hL4Icgf8oulmqAF5IlqQ9t2SeUNd1cdK26jkpxrFQPxsGRJKyzXVYk0emoBDwjDuRO1HIc750auS6MlzB1WAL(lXKv3ti0kgYQaaTTsaw9culwjaRcpaqYajuScKTIS6fa9mmKSsnHtcy1WAv6wPK2kGlQyS4IYZPbhzOicPbwY(pSF2etw8RScvSIARswR8fYk9VSAuwfgNdo9OwbtGB19PrLUvmKvbaAJIv6Fz1OSkbwfgtUh1QxGAXkwmrwTLNOJSs6TvycmbyfbSs6TvGLjaUTIHSkaqBRe4BaUvtBLAg4EU3wCr550GJmueH0yrwnkuurvq67cwh5GqAIsYgkYO2fi1(rhoFtIP)W(bbHX0turpulmqAF5cQDbsTFYMLW9COwyG0(YfxGu7hD48njM(d7heegtprf9qTWaPTEHj)KnlHBbEW0tYgCDinxlww8RS6MoGSs)LyYkP3wHgoFaFAYQK1k0evmBSW6wLaReLNRiuSsawbNwNvcWQ0T6EcHw1JB1SIWkjSvtBfYeaTczrWBGfxuEon4idfrinYwLnHfNqjzd5cKA)WMy6l9(ZGZhWNMoulmqARhtal7HruXSXcRFccRhycGFWIG3xVE9BTZTRRO8Cf9PMEjbS4xzfQo(cHTczcGwHSi4Tv6OMWINToReMeMEsaRemzLUz2wXMqiHTkzTQh3Qaq26Ss)LyYkP3wHgoFaFAYIlkpNgCKHIiKgGja(ztmzXfLNtdoYqresd10SqrhwCcLKnetal7HruXSXcRF2Z92IlkpNgCKHIiKgGfzp3zcWnkjBiu7cKA)WMy6l9(ZGZhWNMoulmqABXVYQBs6lwP)smzL0BRqdNpGpnHIv6RvztyXjRUNqOvmKvIvahpToRytiKWhR0NJkbwfgkkAB1cHjRyhSvceALlqQDGv(yvymTIA3krPYn1UaHrTkaKToR8fYkq26GKvUG1rUv4XfpN2kycClUO8CAWrgkIqAKTkBclozXT4xzL(yTIz8fRuZa3Z9gyLGjRWKSJIIvGG3BAR8fYk91SeUfOv(c1wjkpxjozvKIOVJv6J1QECRcazRZQifrFOyvaGSYxsGvtBvSJulUO8CAWrTbHabV30)SzjClqus2qQzG75EF2coMpycG)SbUWKW0JEWKSJE5cQDbsTF2coMpycG)SbUWKW0JEOwyG02IlkpNgCuBqeH0yl4y(Gja(Zg4ctctpkkjBOWKFYMLWTapIYZvKf)kR0hRvrkI(Skbw1JBfMKDuRycCRIobwPK2kDKB1BWKv(I0wnnzv2SeUfOvzBfdXoyYkFHSI6TvdRv(czfBQBXrXkqW7nTv(czL(Awc3c0QEUBXfLNtdoQniIqAacEVP)zZs4wGOKSH88rFF(7K0MAg4EU3hqW7n9pBwc3c8SdWINtBXVYk9XAv0jWkL0wPJCRY2Q3GjR8fPTAAYQ3GjRIue9zfdXoyYkFHSI6TvdRv(czfBQBXrXQaazLViUv9C3IlkpNgCuBqeH0yl4y(Gja(Zg4ctctpkkjBipF03N)ojTPMbUN79zl4y(Gja(Zg4ctctp6zhGfpNoIBxZIFLv6J1kFHSIn1T4wDpHqROEBfdXoyYQifrFwLaRyevmwfegfRabV30w5lKv6RzjClqlUO8CAWrTbresdqW7n9pBwc3ceLKnKlqQ9ZwWX8bta8NnWfMeME0d1cdK26PMbUN79zl4y(Gja(Zg4ctctp6btpjBG288rFF(7KS4xzL(yTYxiRytDlUv3ti0kQ3wXqSdMSkBwc3c0QeyfJOIXQGWOyvaGSksr0NfxuEon4O2GicPXwWX8bta8NnWfMeMEuus2qQzG75EFabV30)SzjClWdMEs2aT55J((83jzXVYk9XALVqwXM6wCRsGvcZe4w5JvuVrXQaazvSJuGvGa1Iv(I4w5luuR0rUvcWQxGAXkpFKvbHTsawfEaGKbswCr550GJAdIiKgGG3B6F2SeUfikjBipF03N)oPRVXAwCr550GJAdIiKgBbhZhmbWF2axysy6rrjzd55J((83jD9TRzXfLNtdoQniIqAeE8CAus2qHj)KnlHBbEeLNROlx88rFF(7KU(gRzXfLNtdoQniIqAWqyaHJjBDwCr550GJAdIiKgmWz2F2aCulUO8CAWrTbresd2etmWz2wCr550GJAdIiKgba6No9awClUO8CAWzrwnQqQPzHIoS4ekjBiMaw2dJOIzJfw)SN7TEGja(blcERTqAQhycGFWIG3xhksS4IYZPbNfz1OIiKg57nqXjus2qUaP2pz7eUf4xnpMaGNtFOwyG0wpm9KSbxVdWINtVURDw)LlO2fi1(jBNWTa)Q5Xea8C6d1cdK26HjwmbwegizXfLNtdolYQrfrinulYa(md0rjzdPeG)98rxViRg1htpjBGfxuEon4SiRgveH0ambWpBIjlUO8CAWzrwnQicPbyr2ZDMaCJsYgsuEUI(utVKaxFJlxqTlqQ9dBIPV07pdoFaFA6qTWaPTfxuEon4SiRgveH0iBv2ewCcLKnKsa(3ZhD9ISAuFm9KSbCeqysX16wTJ2N7CNZba]] )


end
