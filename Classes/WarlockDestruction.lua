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

            generate = function( ah )
                if active_enemies > 1 then
                    if pvptalent.bane_of_havoc.enabled and debuff.bane_of_havoc.up and query_time - last_havoc < 10 then
                        ah.count = 1
                        ah.applied = last_havoc
                        ah.expires = last_havoc + 10
                        ah.caster = "player"
                        return
                    elseif not pvptalent.bane_of_havoc.enabled and active_dot.havoc > 0 and query_time - last_havoc < 10 then
                        ah.count = 1
                        ah.applied = last_havoc
                        ah.expires = last_havoc + 10
                        ah.caster = "player"
                        return
                    end
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

        -- Going to need to keep an eye on this.  active_dot.bane_of_havoc won't work due to no SPELL_AURA_APPLIED event.
        bane_of_havoc = {
            id = 200548,
            duration = 10,
            max_stack = 1,
            generate = function( boh )
                boh.applied = action.bane_of_havoc.lastCast
                boh.expires = boh.applied > 0 and ( boh.applied + 10 ) or 0
            end,
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
        return pvptalent.bane_of_havoc.enabled and action.bane_of_havoc.lastCast or action.havoc.lastCast
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

        if pvptalent.bane_of_havoc.enabled then
            class.abilities.havoc = class.abilities.bane_of_havoc
        else
            class.abilities.havoc = class.abilities.real_havoc
        end
    end )


    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end

        -- For Havoc, we want to cast it on a different target.
        if this_action == "havoc" and class.abilities.havoc.key == "havoc" then return "cycle" end

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
                if talent.eradication.enabled then
                    applyDebuff( "target", "eradication" )
                    active_dot.eradication = max( active_dot.eradication, active_dot.bane_of_havoc )
                end
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
                if talent.roaring_blaze.enabled then
                    applyDebuff( "target", "conflagrate" )
                    active_dot.conflagrate = max( active_dot.conflagrate, active_dot.bane_of_havoc )
                end
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

            bind = "bane_of_havoc",

            usable = function () return not pvptalent.bane_of_havoc.enabled and active_enemies > 1 end,
            handler = function ()
                if class.abilities.havoc.indicator == "cycle" then
                    active_dot.havoc = active_dot.havoc + 1
                else
                    applyDebuff( "target", "havoc" )
                end
                applyBuff( "active_havoc" )
            end,

            copy = "real_havoc"
        },


        bane_of_havoc = {
            id = 200546,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1380866,
            cycle = "DoNotCycle",

            bind = "havoc",

            pvptalent = "bane_of_havoc",
            usable = function () return active_enemies > 1 end,
            
            handler = function ()
                applyDebuff( "target", "bane_of_havoc" )
                active_dot.bane_of_havoc = active_enemies
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
                active_dot.immolate = max( active_dot.immolate, active_dot.bane_of_havoc )
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
                active_dot.mortal_coil = max( active_dot.mortal_coil, active_dot.bane_of_havoc )
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
                active_dot.shadowburn = max( active_dot.shadowburn, active_dot.bane_of_havoc )
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


    spec:RegisterPack( "Destruction", 20190804.1510, [[dOeqxbqiuKEevbBcLYNOkknkQcDkQISkuIYROsAwGu3cLOAxk1VOcggkQJrvQLPkXZqjmnQq6AuHABQscFtvsX4uLeDoQII1HIOmpQsUhkSpvrDqvjvwikPhsfIjIIixKQOYgvLu6JufvLgPQKQojkcRuvQDsL4NufvvnuQIQklvvsQEkOMkkvxLQOQ4RufvzVO6VkzWQCyslMOEmHjlXLr2SQ6ZuvnAqCAkRgfr1Rvfz2qDBjTBr)wQHtL64Qssz5aphY0fUor2UQW3bjJxvsY5PQSEuImFQO9RyU3C25WfniUlVWS3EgMFLm7OBVDS3mZIxjho85M4WUvXtQFIdNAL4WmjcfajryDYHDR(WTw4SZHrTeqqCyir4gXK5Gd(TaIK8w0vhqwvcRH1PaO)WbKvfoWHLLmCWejxMdx0G4U8cZE7zy(vYSJU92XEZmlCuoSkfqAahg2QochgIvkuYL5Wfcj4WEyoMeHcGKiSoNZZtb4w8082dZbjc3iMmhCWVfqKK3IU6aYQsynSofa9hoGSQWH5ThM71j5xcfZ5Oqp3lm7TNzow(CE7yMmMzMdJnuG4SZHHOpAbNDUlEZzNdtPkJPcNvoSaybbmLdll9)Bzv8ubO)yxAOY5yBoulHxiikOm3ZmMZ75yBoulHxiikOmNxmMZr5WQiSo5WIo)y1pqdIhCxEHZohMsvgtfoRCybWccykhoumLX2YGaPIxIUklHcRZnLQmMkZX2CaQQwIMZR5ksanSoNJLnhZBhpNtNZX05cftzSTmiqQ4LORYsOW6CtPkJPYCSnhG(acbrLXehwfH1jh2Q1gRbXdUlSGZohMsvgtfoRCybWccykhwOOyfwLMZR5GOpAXcqv1sehwfH1jhwarB0sUXbp4U4OC25WQiSo5WOwcV(gG4WuQYyQWzLhCxCmNDomLQmMkCw5WcGfeWuoSkc7bTOKQgHMZR5yXCoDohtNlumLX(BaAPzzjdSkk6K2uQYyQWHvryDYHrq0sdLSei5b3LxbNDomLQmMkCw5WcGfeWuoSqrXkSknNxZbrF0IfGQQLioSkcRtoSLcljGgep4bh2nGeDvwdo7Cx8MZohwfH1jhgjvRDUSQBomLQmMkCw5b3Lx4SZHPuLXuHZkhwaSGaMYHdftzS9dSABaA1)fsfa7BcAtPkJPchwfH1jh2pWQTbOv)xivaSVjiEWDHfC25WQiSo5WU7W6KdtPkJPcNvEWDXr5SZHvryDYHrTeE9naXHPuLXuHZkp4U4yo7Cykvzmv4SYHfaliGPCyMoxOykJnQLWRVbOnLQmMkCyvewNCylfwsaniEWdoS2eNDUlEZzNdtPkJPcNvoSaybbmLd7MITLFcKkERIWEqZX2CECozP)FlakcIL(xciAJ2LgQCoNoNJPZfkMYy7hy12a0Q)lKKBavvHVnLQmMkZ5P5yBopohtNt0nU0qLBi6JwSbKw8nNtNZPIWEqlkPQrO5EEowmNN4WQiSo5Wa1Yv)xFdq8G7YlC25WuQYyQWzLdlawqat5WLo2wT2ynOnGQQLO5EEoHIIvyvIdRIW6KdlGOzs4vHQD(naXdUlSGZohMsvgtfoRCyvewNCyRwBSgehwaSGaMYHbuvTenNxZ545yBopohtNlumLXwOHkW(q1nLQmMkZ505CIUXLgQCl0qfyFO6gqv1s0CpphGQQLO58ehw4tGPvOa)uG4U4np4U4OC25WuQYyQWzLdRIW6KdlumEPIW6CHnuWHXgkwPwjoSOG4b3fhZzNdtPkJPcNvoSkcRtoSSM0Q)li6JwWHfaliGPCyve2dArjvncnNxZ5OCyHpbMwHc8tbI7I38G7YRGZohMsvgtfoRCybWccykhoumLX2pWQTbOv)xij3aQQcFBkvzmvMJT5CtX2YpbsfVvrypO5yBopohe9rlwQiSh0CoDoxOykJTqdvG9HQBkvzmvMZPZ5cftzST8tGS3uQYyQmhBZPIWEqlkPQrO58AohDopXHvryDYHfq0gTKBCWdUlVgo7CyvewNCyGA5Q)RVbiomLQmMkCw5b3LxjNDoSkcRto8VfsiQSuwIawqlzsRCykvzmv4SYdUlEgo7CyvewNCy3sa77Zs)lzSIcomLQmMkCw5b3fVzMZohMsvgtfoRCyvewNCyznPv)xq0hTGdlawqat5WECoMoxOykJTFGvBdqR(VqsUbuvf(2uQYyQmNtNZX05cftzST8tGS3uQYyQmNtNZfkMYy7hy12a0Q)lKKBavvHVnLQmMkZX2CUPyB5NaPI3aQQwIMZlgZ5nZZ5joSWNatRqb(PaXDXBEWDXBV5SZHPuLXuHZkhwaSGaMYHdftzS)gGwAwwYaRIIoPnLQmMkZX2CYs))wwfpva6p2sUNJT5qTeEHGOGYCEnNJNJLphZ7xMJLnNkc7bTOKQgH4WQiSo5WwkSKaAq8G7I3VWzNdRIW6KdJAj86BaIdtPkJPcNvEWDXBwWzNdtPkJPcNvoSaybbmLdll9)Bzv8ubO)yxAOsoSkcRtoSOZpw9d0G4b3fVDuo7Cykvzmv4SYHfaliGPCyMoxOykJ93a0sZYsgyvu0jTPuLXuHdRIW6KdJGOLgkzjqYdUlE7yo7Cykvzmv4SYHfaliGPCyMoxPJTOtbLbqdQS(yTslzjqUbuvTenhBZX05uryDUfDkOmaAqL1hRvAB56Jn)qI5yBove2dArjvncnNxZ5yoSkcRtoSOtbLbqdQS(yTs8G7I3Vco7CyvewNCylfwsaniomLQmMkCw5bp4WIcIZo3fV5SZHPuLXuHZkhwfH1jhwzjeefOO1VZy1)L7gkcWHfaliGPCyr34sdvUrs1ANll)eiv8wY9CoDoNOBCPHk3iPATZLLFcKkEdOQAjAoVMZXC4uRehwzjeefOO1VZy1)L7gkcWdUlVWzNdtPkJPcNvoSaybbmLdl6gxAOYDrbpTqTeEzjkuzdBHVnG0IV5C6Cor34sdvURuTb(w9FHLewzvaKwrBaPfFZ505CECoMoxOykJDrbpTqTeEzjkuzdBHVnLQmMkZX2CmDocHOuq7kvBGVv)xyjHvwfaPv0UQm5nyopnNtNZj6gxAOYDrbpTqTeEzjkuzdBHVnGQQLO58IXCEZ8CoDoNOBCPHk3vQ2aFR(VWscRSkasROnGQQLO58IXCEZmhwfH1jhgjvRDUS8tGuX8G7cl4SZHPuLXuHZkhwaSGaMYHDtX2YpbsfVvrypioSkcRtoSFjfumnx9FPSeb6acp4U4OC25WuQYyQWzLdlawqat5WUPyB5NaPI3QiSh0CSnNBk2w(jqQ4nGQQLO58IXCVWmhwfH1jhUOGNwOwcVSefQSHTWhp4U4yo7Cykvzmv4SYHfaliGPCy3uST8tGuXBve2dAo2MZnfBl)eiv8gqv1s0CEXyUxyMdRIW6KdxPAd8T6)cljSYQaiTI4b3LxbNDomLQmMkCw5WcGfeWuoCyvAf9Qy0CppNOBCPHk3iPATZLLFcKkExKaAyDoNRZXcM5WQiSo5WiPATZLLFcKkMhCxEnC25WuQYyQWzLdlawqat5WHvP5EEowW8CSnxyvAf9Qy0CppNOBCPHk3(LuqX0C1)LYseOdi7IeqdRZ5CDowWmhwfH1jh2VKckMMR(VuwIaDaHhCxELC25WuQYyQWzLdlawqat5WHIPm2ff80c1s4LLOqLnSf(2uQYyQmhBZj6gxAOYDrbpTqTeEzjkuzdBHVnGQQLO5EEUWQ0k6vXioSkcRtomsQw7Cz5NaPI5b3fpdNDomLQmMkCw5WcGfeWuoSOBCPHk3iPATZLLFcKkEdOQAjAUNNlSkTIEvmIdRIW6Kd7xsbftZv)xklrGoGWdUlEZmNDomLQmMkCw5WcGfeWuoSOBCPHk3iPATZLLFcKkEdOQAjAUNNlSkTIEvmIdRIW6KdxuWtlulHxwIcv2Ww4JhCx82Bo7Cykvzmv4SYHfaliGPCyr34sdvUrs1ANll)eiv8gqv1s0CppxyvAf9QyehwfH1jhUs1g4B1)fwsyLvbqAfXdUlE)cNDomLQmMkCw5WcGfeWuoSOBCPHk3iPATZLLFcKkEdOQAjAUNNlSkTIEvmAo2MZnfBl)eiv8gqv1s0CEXyUxyMdRIW6KdxuWtlulHxwIcv2Ww4JhCx8MfC25WuQYyQWzLdlawqat5WIUXLgQCJKQ1oxw(jqQ4nGQQLO5EEUWQ0k6vXO5yBo3uST8tGuXBavvlrZ5fJ5EHzoSkcRtoCLQnW3Q)lSKWkRcG0kIhCx82r5SZHPuLXuHZkhwaSGaMYHdRsROxfJMZR5ybZCyvewNCyKuT25YYpbsfZdUlE7yo7Cykvzmv4SYHfaliGPC4WQ0k6vXO58AowWmhwfH1jh2VKckMMR(VuwIaDaHhCx8(vWzNdtPkJPcNvoSaybbmLdhwLwrVkgnNxZ9cZCyvewNC4IcEAHAj8YsuOYg2cF8G7I3Vgo7Cykvzmv4SYHfaliGPC4WQ0k6vXO58AUxyMdRIW6KdxPAd8T6)cljSYQaiTI4b3fVFLC25WQiSo5WY4UlR(Vci0IsQ6JdtPkJPcNvEWDXBpdNDoSkcRtomunaxEqwUaeQtnfehMsvgtfoR8G7YlmZzNdRIW6Kddm3UX0YYfYTkiomLQmMkCw5b3Lx8MZohMsvgtfoRCybWccykh2nfBl)eiv8wfH9GMZPZ5cRsROxfJMZR5ybZCyvewNCy3DyDYdUlV8cNDomLQmMkCw5WcGfeWuoSBk2w(jqQ4Tkc7bnNtNZjl9)7kvBGVv)xyjHvwfaPv0gqv1s0CoDoNS0)Vlk4PfQLWllrHkByl8TbuvTenNtNZfwLwrVkgnNxZXcM5WQiSo5WYearGNS0pp4U8cl4SZHPuLXuHZkhwaSGaMYHDtX2YpbsfVvrypO5C6CozP)FxPAd8T6)cljSYQaiTI2aQQwIMZPZ5KL()DrbpTqTeEzjkuzdBHVnGQQLO5C6CUWQ0k6vXO58AowWmhwfH1jhwg3Dz9La(4b3LxCuo7Cykvzmv4SYHfaliGPCy3uST8tGuXBve2dAoNoNtw6)3vQ2aFR(VWscRSkasROnGQQLO5C6CozP)FxuWtlulHxwIcv2Ww4BdOQAjAoNoNlSkTIEvmAoVMJfmZHvryDYH)gGKXDx4b3LxCmNDomLQmMkCw5WcGfeWuoSBk2w(jqQ4Tkc7bnNtNZjl9)7kvBGVv)xyjHvwfaPv0gqv1s0CoDoNS0)Vlk4PfQLWllrHkByl8TbuvTenNtNZfwLwrVkgnNxZXcM5WQiSo5WsiAzbvr8G7YlVco7Cykvzmv4SYHvryDYHD3INOazSevwIU6wk0W6CvOhMG4WcGfeWuoCPJTvRnwdAdOQAjAUNzmNJ5WPwjoS7w8efiJLOYs0v3sHgwNRc9Weep4U8YRHZohMsvgtfoRCyvewNCyqhcGekOY6r3LUxLgJ5WcGfeWuoCPJTvRnwdAdOQAjAUNzmNJNJT584CIUXLgQCJKQ1oxw(jqQ4nGQQLO5EMXCVW8CoDoxyvAf9Qy0CEnhlyEopXHtTsCyqhcGekOY6r3LUxLgJ5b3LxELC25WuQYyQWzLdRIW6KdJGypiW6bLDDbiSj4WcGfeWuoCPJTvRnwdAdOQAjAUNzmNJNJT584CIUXLgQCJKQ1oxw(jqQ4nGQQLO5EMXCVW8CoDoxyvAf9Qy0CEnhlyEopXHtTsCyee7bbwpOSRlaHnbp4U8INHZohMsvgtfoRCyvewNCy9vtYC3bLXkvPWWsioSaybbmLdx6yB1AJ1G2aQQwIM7zgZ545yBopoNOBCPHk3iPATZLLFcKkEdOQAjAUNzm3lmpNtNZfwLwrVkgnNxZXcMNZtC4uRehwF1Km3DqzSsvkmSeIhCxybZC25WuQYyQWzLdRIW6KdhwHqrdQlrxOxfhwaSGaMYHlDSTATXAqBavvlrZ9mJ5C8CSnNhNt0nU0qLBKuT25YYpbsfVbuvTen3ZmM7fMNZPZ5cRsROxfJMZR5ybZZ5joCQvIdhwHqrdQlrxOxfp4UWcV5SZHPuLXuHZkhwfH1jh(HP4v)xOObvehwaSGaMYHlDSTATXAqBavvlrZ9mJ5C8CSnNhNt0nU0qLBKuT25YYpbsfVbuvTen3ZmM7fMNZPZ5cRsROxfJMZR5ybZZ5joCQvId)Wu8Q)lu0GkIh8GdxOVkHdo7Cx8MZohwfH1jhg5MW4fUfpXHPuLXuHZkp4U8cNDoSkcRtomYs)0QQ(nbhMsvgtfoR8G7cl4SZHPuLXuHZkhwaSGaMYHHOpAXsfH9GMJT5urypOfLu1i0CEnNJNJLpxOykJTLFcK9MsvgtL5CDopoxOykJTLFcK9MsvgtL5yBUqXugBldcKkEj6QSekSo3uQYyQmNN4WQiSo5WcfJxQiSoxydfCySHIvQvIddrF0cEWDXr5SZHvryDYHfAOcSpuLdtPkJPcNvEWDXXC25WuQYyQWzLdlawqat5WQiSh0IsQAeAUNN7foSkcRtoSqX4LkcRZf2qbhgBOyLAL4WAt8G7YRGZohMsvgtfoRCyvewNCyRwBSgehwaSGaMYHb0hqiiQmMMJT584CmDUqXugBHgQa7dv3uQYyQmNtNZj6gxAOYTqdvG9HQBavvlrZ98CaQQwIMZtCyHpbMwHc8tbI7I38G7YRHZohMsvgtfoRCybWccykhoumLX2YGaPIxIUklHcRZnLQmMkZX2CQiSo3ciAJwYno2wU(yZpKyo2Mdqv1s0CEnxrcOH15CSS5yE7yoSkcRtoSvRnwdIhCxELC25WuQYyQWzLdRIW6KdlumEPIW6CHnuWHXgkwPwjoSOG4b3fpdNDomLQmMkCw5WcGfeWuomtNZnfBl)eiv8wfH9GMZPZ5y6CHIPm2(bwTnaT6)cj5gqvv4BtPkJPchwfH1jh(3cjevwklralOLmPvEWDXBM5SZHPuLXuHZkhwaSGaMYHLL()nGepHjeA9BGG2asfbhwfH1jhoGqlPuULYY63abXdUlE7nNDoSkcRtoSBjG99zP)LmwrbhMsvgtfoR8G7I3VWzNdtPkJPcNvoSaybbmLdZ05kDSfDkOmaAqL1hRvAjlbYnGQQLO5yBoMoNkcRZTOtbLbqdQS(yTsBlxFS5hsWHvryDYHfDkOmaAqL1hRvIhCx8MfC25WQiSo5WciAMeEvOANFdqCykvzmv4SYdUlE7OC25WuQYyQWzLdRIW6KdlRjT6)cI(OfCybWccykh2JZv6yB1AJ1G2aQQwIM755kDSTATXAq7IeqdRZ5yzZX82XZ505CmDUqXugBldcKkEj6QSekSo3uQYyQmNNMJT584CmDor34sdvUrs1ANll)eiv8gqAX3CoDohtNlumLX2pWQTbOv)xij3aQQcFBkvzmvMZPZ5cftzS9dSABaA1)fsYnGQQW3MsvgtL5yBo3uST8tGuXBavvlrZ5fJ58M558ehw4tGPvOa)uG4U4np4U4TJ5SZHvryDYHrTeE9naXHPuLXuHZkp4U49RGZohMsvgtfoRCybWccykhww6)3YQ4Pcq)XU0qLZX2COwcVqquqzUNzmN3BhphlFoM3Syow2CHIPm2FSIG0piWMsvgtL5yBoMo3dfyQmM2U7gVqTeEHGOGcIdRIW6Kdl68Jv)aniEWDX7xdNDomLQmMkCw5WcGfeWuomQLWleefuMZR5Ezo2MZJZX05EOatLX02D34fQLWleefuqZ505CcikWpHM7558EopXHvryDYHrq0sdLSei5b3fVFLC25WuQYyQWzLd3U5Wik4WQiSo5WpuGPYyId)qXsehwfH9GwusvJqZ98CEphBZj6gxAOYne9rl2aQQwIMZlgZ5nZZ505CIUXLgQCJKQ1oxw(jqQ4nGQQLO58IXCVW8CSnNhNlumLX2pWQTbOv)xij3aQQcFBkvzmvMZPZ5cftzSlk4PfQLWllrHkByl8TPuLXuzo2Mt0nU0qL7IcEAHAj8YsuOYg2cFBavvlrZ5fJ5EH5580CoDoxOykJDrbpTqTeEzjkuzdBHVnLQmMkZX2CIUXLgQCxuWtlulHxwIcv2Ww4BdOQAjAoVym3lmphBZ5X5eDJlnu5gjvRDUS8tGuXBavvlrZ98CHvPv0RIrZ505CIUXLgQCJKQ1oxw(jqQ4nGQQLO5CDor34sdvUrs1ANll)eiv8Uib0W6CUNNlSkTIEvmAopXHFOGvQvId7UB8c1s4fcIckiEWDXBpdNDomLQmMkCw5WcGfeWuoShNlumLX2pWQTbOv)xij3aQQcFBkvzmvMZPZ5uwIawqBbqrqS0)sarB0MsvgtL580CSnNBk2w(jqQ4Tkc7bnNtNZjl9)7IcEAHAj8YsuOYg2cFBj3Z505CYs))gqINWecT(nqqBaPIyo2Mtw6)3as8eMqO1VbcAdOQAjAUNNtOOyfwL4WQiSo5WciAJwYno4b3LxyMZohMsvgtfoRCybWccykhMPZ9qbMkJPT7UXlulHxiikOGMJT5y6CHIPm2eqlMqdRZnLQmMkCyvewNCybeTrl5gh8G7YlEZzNdtPkJPcNvoSaybbmLdZ05EOatLX02D34fQLWleefuqZX2CHIPm2eqlMqdRZnLQmMkZX2CECUcjl9)BcOftOH15gqv1s0CEnNqrXkSknNtNZjl9)Bzv8ubO)yl5EopXHvryDYHfq0gTKBCWdUlV8cNDomLQmMkCw5WcGfeWuoShNd1s4fcIckZ9mJ5C0TJNJLphZ7xMJLnNkc7bTOKQgHMZtCyvewNCybeTrl5gh8G7YlSGZohMsvgtfoRCybWccykhwarb(j0CppN3CyvewNCyrNFS6hObXdUlV4OC25WQiSo5WwkSKaAqCykvzmv4SYdEWdo8dcGSo5U8cZE7zy(18YlCyOuqAPFehMjQUBqqL5C8CQiSoNdBOaTN3Cy3G(ById7H5ysekasIW6CoppfGBXtZBpmhKiCJyYCWb)warsEl6QdiRkH1W6ua0F4aYQchM3EyUxNKFjumNJc9CVWS3EM5y5Z5TJzYyM55982dZ55EvKqkOYCY0Vb0CIUkRXCYKFlr75EDcb5oqZLDYYHOG6xcpNkcRt0CDI9TN3EyovewNOTBaj6QSgm(yf9082dZPIW6eTDdirxL1Wvgo87UmV9WCQiSorB3as0vznCLHdQK)kLHgwNZBvewNOTBaj6QSgUYWbKuT25YnfZBvewNOTBaj6QSgUYWb)aR2gGw9FHubW(MGG2(mcftzS9dSABaA1)fsfa7BcAtPkJPY82dZPIW6eTDdirxL1WvgoGs1ncshluObAERIW6eTDdirxL1Wvgo4UdRZ5TkcRt02nGeDvwdxz4aQLWRVbO5TkcRt02nGeDvwdxz4GLcljGge02NbtdftzSrTeE9naTPuLXuzEpV9WCEUxfjKcQmh9Ga(MlSknxaHMtfrdMZqZPpudRYyApVvryDIyGCty8c3INM3QiSorUYWbKL(Pvv9BI5982dZ961hTyojeHMtNd5MeMINZnWAGf(MdBOyUoNR2OyUQeoSqb(PyoKGsfync65KLI5ci0CHc8tXCbeaHG04YCcnN7Hc8nxHCtzXs)Z15CHIPmqZBvewNigcfJxQiSoxydfqNALyarF0cOTpdi6JwSurypi2urypOfLu1iKxoMLhkMYyB5NazVPuLXuXvpgkMYyB5NazVPuLXuHTqXugBldcKkEj6QSekSo3uQYyQ4P5ThMZr0qfyFO6CiiTeUmNmnNeIkZ15CIUXLgQCofnhQ7CofnN7gHmzmnVvryDICLHdcnub2hQoV9WCSdvpxOa)umhsqPcSgnNcO5GOzbtL5W2t0Cil9JP5cf4NI5GYciZ961hTyoOi9bvMZY9CWHccl9phuwazUacGO5cf4Nce0ZPZHCtctXglrL5EDTNBo3aRbw4BodnhGE1KmavM3QiSorUYWbHIXlvewNlSHcOtTsm0MG2(murypOfLu1i0ZVmV9WCmrT2ynO5qqAjCzUKEqG5(kgpx))ZfqO5CdSQc8nxOa)uSNJj(Z5iAOcSpuDoOmmEoa9becYCmrT2ynO5KPFdO5Syo6v52aec65cieG8SO5YEoaPOoNl65GsrbnxyvAoHIcl9pNfZBvewNixz4GvRnwdcAHpbMwHc8tbIH3qBFga6dieevgtS5rMgkMYyl0qfyFO6MsvgtfNofDJlnu5wOHkW(q1nGQQLONbuvTe5P5ThMZdEEwazoMidcKkEohPRYsOW6CUqXugub65SWZIMZDJqMmMMJjQ1gRbnhuggpxsuzUONtMMdqFaHGqL5qDNeyUaIMZfqO5auvT0s)ZvKaAyDohs9HGEo7pxaHaKNfnNIbKw8nNoNJarB0CS24yUoNlGqZbL6BUONlGqZfkWpf75TkcRtKRmCWQ1gRbbT9zekMYyBzqGuXlrxLLqH15Msvgtf2uryDUfq0gTKBCSTC9XMFibBaQQwI8Qib0W6KLX82XZBpmh7qO58tjbu8Cajmnx)NlGivLN73G5cftzGMZqZf9Cv9vzvJLO5ci0CPuvMaZ1)5KqeAU(phPciZBvewNixz4GqX4LkcRZf2qb0PwjgIcAERIW6e5kdh(TqcrLLYseWcAjtAfA7ZGPUPyB5NaPI3QiShKtNmnumLX2pWQTbOv)xij3aQQcFBkvzmvM3QiSorUYWHacTKs5wklRFdee02NHS0)VbK4jmHqRFde0gqQiM3QiSorUYWb3sa77Zs)lzSII5TkcRtKRmCq0PGYaObvwFSwjOTpdMw6yl6uqza0GkRpwR0swcKBavvlrSXuvewNBrNckdGguz9XAL2wU(yZpKyERIW6e5kdheq0mj8Qq1o)gGM3Eyo2HqZz)5eDwSW6CoieGMtXqP(qZPUDJncn3RxF0I5IEouxPaIL(NRdieyUaIMZfqO5CdSQc8nxOa)umVvryDICLHdq0hTaAHpbMwHc8tbIH3qBFgES0X2Q1gRbTbuvTe9CPJTvRnwdAxKaAyDYYyE7yNozAOykJTLbbsfVeDvwcfwNBkvzmv8eBEKPIUXLgQCJKQ1oxw(jqQ4nG0IpNozAOykJTFGvBdqR(VqsUbuvf(2uQYyQ40zOykJTFGvBdqR(VqsUbuvf(2uQYyQWMBk2w(jqQ4nGQQLiVy4nZEAE7H5GBj8CVwdqZHG0s4YCY0CsiQmxNZj6gxAOsONZI5knHMl7yo1TBsbZbvdciZH0hw6FUFdMZpLeqdl9phClHNdgIckO5ksal9pNOBCPHkrZBvewNixz4aQLWRVbO5ThMZr68Jv)anO5qqAjCzUoX(MtMMtcrL5IEoefZj5EohbI2O5yTXbAp3RfRii9dcmhMc0CosNFS6hObnNmnNeIkZrkaBeyUONdrXCsUNtZ5yIuyjb0GMtM(nGMZryDpht8NtNRQm5nyor34sdvoNHMt0vl9pNKBONdPpO5equGFcn3VbZzX8wfH1jYvgoi68Jv)aniOTpdzP)FlRINka9h7sdvYgQLWleefuEMH3BhZYzEZcwwOykJ9hRii9dcSPuLXuHnM(qbMkJPT7UXlulHxiikOGM3EyoyiAPHswcKZzO5KquzofnNoxXqIwkJ5CKo)y1pqdAUONZpLeqdAoeefuqZz)581sZv60ZgZbrFqZrzl5hYC)gmNoNJarB0CS24yph7qO5qALMdiHj0CQClfZH0hw6FolM73G5QktEdMt0nU0qLO5u3UXgHM3QiSorUYWbeeT0qjlbsOTpdulHxiikO41lS5rM(qbMkJPT7UXlulHxiikOGC6uarb(j0ZE7P5ThMJjcplAoOAqazou0INS0)CsUNRZ5GBj8CWquqbnNm9BanNoxvzYBWCIUXLgQCojK6NM3QiSorUYWHhkWuzmbDQvIH7UXlulHxiikOGG(HILigQiSh0IsQAe6zVzt0nU0qLBi6JwSbuvTe5fdVz2Ptr34sdvUrs1ANll)eiv8gqv1sKxmEHz28yOykJTFGvBdqR(VqsUbuvf(2uQYyQ40zOykJDrbpTqTeEzjkuzdBHVnLQmMkSj6gxAOYDrbpTqTeEzjkuzdBHVnGQQLiVy8cZEYPZqXug7IcEAHAj8YsuOYg2cFBkvzmvyt0nU0qL7IcEAHAj8YsuOYg2cFBavvlrEX4fMzZJIUXLgQCJKQ1oxw(jqQ4nGQQLONdRsROxfJC6u0nU0qLBKuT25YYpbsfVbuvTe5QOBCPHk3iPATZLLFcKkExKaAyD(CyvAf9QyKNM3EyohbI2O5yTXXCqu0Ci6bbu8CUBeYKX0CsiAorNflSor75CeGIGyP)5CeiAJGEopFbwTnanx)NdwYnGQQWh0ZPzzoMKcEAo4wcZKnhtKOqLnSf(MtX45(6JgmNqrHL(NtrZv103CocRO5u0CUBeYKX0CqbHY5003C9FUacvNtb0CQiSh08wfH1jYvgoiGOnAj34aA7ZWJHIPm2(bwTnaT6)cj5gqvv4BtPkJPItNklralOTaOiiw6FjGOnAtPkJPINyZnfBl)eiv8wfH9GC6uw6)3ff80c1s4LLOqLnSf(2sUD6uw6)3as8eMqO1VbcAdiveSjl9)BajEcti063abTbuvTe9SqrXkSknV9WCmXFo4wcphmefuqZPaAUSJ5Kjl9pN7UXuzonlZ55aAXeAyDoNHMl7yUqXugub65yYLqXCi3uwMZryfnNIMlGq(MtMeDLMtFOgwLX08wfH1jYvgoiGOnAj34aA7ZGPpuGPYyA7UB8c1s4fcIcki2yAOykJnb0Ij0W6CtPkJPY82dZ55zbK58CaTycnSoHEol8SO5KPK(MWu8CrpxvFvw1yjAUacnNK7WQ0CDoxaHMRqYs))EUxFdf9GaqpNfEw0COWW45KPiiWCrpNeIMZrGOnAowBCmNvRuX0GW(MZ(ZXQkEQa0FmNHMtY98wfH1jYvgoiGOnAj34aA7ZGPpuGPYyA7UB8c1s4fcIcki2cftzSjGwmHgwNBkvzmvyZJfsw6)3eqlMqdRZnGQQLiVekkwHvjNoLL()TSkEQa0FSLC7P5ThMZZ9GY5GccLZH0hw6h65k9CzhZ1piGqDpxNZb3s45GHOGcAERIW6e5kdheq0gTKBCaT9z4rulHxiikO8mdhD7ywoZ7xyzQiSh0IsQAeYtZBpmhtQtpBmx)Gac19CDoNaIc8tO56)CosNFS6hObnVvryDICLHdIo)y1pqdcA7Zqarb(j0ZEpVvryDICLHdwkSKaAqZ75ThM7vxTCU(p3R1a0CgAUWNBtOySV5ci0Cqm)qiumNBG1al8nNkcRtONtwkMtqGqTCoKfsAyDIM7RpAWCsil9pNJarB0CS24yolrbPL5TkcRt0wBIbqTC1)13ae02NHBk2w(jqQ4Tkc7bXMhLL()TaOiiw6FjGOnAxAOsNozAOykJTFGvBdqR(VqsUbuvf(2uQYyQ4j28itfDJlnu5gI(OfBaPfFoDQIWEqlkPQrONzHNM3EyohbIMjHNJjr1o)gGMRtSV5sIkO56KMJjQ1gRbnNkc7bnxrcyP)5SanNqrXC)gm3RR9C7588dyvf4BUqb(PyodnNeIkZbHa0C)gmhYQUXMWcFZBvewNOT2KRmCqarZKWRcv78BacA7ZO0X2Q1gRbTbuvTe9SqrXkSknV9WCWw1WkyUONdzPFmnxOa)ua9CbecqZzO5YEUKOYCrphG(acbzoMOwBSgeAo7pNJOHkW(q15eAoxPNZI5SefKwM3QiSorBTjxz4GvRnwdcAHpbMwHc8tbIH3qBFgaQQwI8YXS5rMgkMYyl0qfyFO6MsvgtfNofDJlnu5wOHkW(q1nGQQLONbuvTe5P5ThM7vxctO5(nyor34sdvIMR0ZLDmNaIM(P5(nyUxx75GEoupNqX45ci0CiTsZHnumNIMRZ5qw6htZfkWpfZBvewNOT2KRmCqOy8sfH15cBOa6uRedrbnV9WCSdbq0CHc8tbAodnNMZzjlxMcOikNtOiAUaIgZ53EqO505qyZpKyozkPVfZf9Cqm)qiWCUbwdSW3CVE9rlM3QiSorBTjxz4ae9rlGw4tGPvOa)uGy4n02NHkc7bTOKQgH8YrN3EyUxD1Y56)CVwdqZbLHXZHcfeZf9CLUAPg0CDohesF4BUxx75GEozPyouxP5qM)0(MqZyohbI2O5yTXXCYs)pAoOmmEouyy8C(Th0Cqm)qiWCfTQ(P5APWTumxNZ1cHISoN3QiSorBTjxz4GaI2OLCJdOTpJqXugB)aR2gGw9FHKCdOQk8TPuLXuHn3uST8tGuXBve2dInpcrF0ILkc7b50zOykJTqdvG9HQBkvzmvC6mumLX2YpbYEtPkJPcBQiSh0IsQAeYlh1tZBpmhRkayP)5003C0RsqUdRte0Z9QRwox)N71AaAoOmmEozAojevMtrZvLeqMtrZ5UritgtqphYsbnxvchMBmnNODBeAU(pNfZj0CouOINM3QiSorBTjxz4aqTC1)13a08wfH1jARn5kdh(TqcrLLYseWcAjtADERIW6eT1MCLHdULa23NL(xYyffZBpmNN7bLZz)5ci0CVE9rlMZnWAGf(MdBOyoO60ZgZjtZjHOc0Z961hTyodnNBafHV5QsciZ9benxrRQFAonlZbiulbeeAonlZHG0s4YCY0CsiQmNIRnkMRZ5eDJlnu58wfH1jARn5kdhGOpAb0cFcmTcf4NcedVH2(m8itdftzS9dSABaA1)fsYnGQQW3MsvgtfNozAOykJTLFcK9MsvgtfNodftzS9dSABaA1)fsYnGQQW3Msvgtf2CtX2YpbsfVbuvTe5fdVz2tZBpmNNpiAUxRbO50SmhRaRIIoP5S)CSQINka9hZzO5urypiONtrZH70)CkAolMdkdJNl7yU(bbeQ756Co4wcphmefuqZBvewNOT2KRmCWsHLeqdcA7ZiumLX(BaAPzzjdSkk6K2uQYyQWMS0)VLvXtfG(JTKB2qTeEHGOGIxoMLZ8(fwMkc7bTOKQgHM3Eyop)dieyo4wcphmefuMZpLeqdl9pNkBylmcnNcO583DzUVHXeyo7px2XCsil9p3R1a0CAwMJvGvrrN08wfH1jARn5kdhqTeE9nanVvryDI2AtUYWbrNFS6hObbT9zil9)Bzv8ubO)yxAOY5TkcRt0wBYvgoGGOLgkzjqcT9zW0qXug7VbOLMLLmWQOOtAtPkJPY8wfH1jARn5kdheDkOmaAqL1hRvcA7ZGPLo2IofuganOY6J1kTKLa5gqv1seBmvfH15w0PGYaObvwFSwPTLRp28djytfH9GwusvJqE545ThMZZZciZ9AnanNML5yfyvu0jb9CmrkSKaAqZbLHXZjtZPZHcqN(N7Bymb2ZXeHNfnNBSkOYCqian3VbZPy8CHIPmqZf9CUb0dkJ5uHWkugkg7BojKL(NlGqZHS0pMMluGFkMd0HgwNZHnumVvryDI2AtUYWblfwsanO598wfH1jAlkigsiAzbvHo1kXqzjeefOO1VZy1)L7gkcaT9zi6gxAOYnsQw7Cz5NaPI3sUD6u0nU0qLBKuT25YYpbsfVbuvTe5LJN3EyoM4pNChqMt0nU0qLO5uanhG0IpONdjvRDoxaHMJjYpbsfpxaHY5uryp0GMJjbZe75yI)CzhZjHS0)CmjyMa65Kq0CbednxNZ5imP5TkcRt0wuqUYWbKuT25YYpbsfdT9zi6gxAOYDrbpTqTeEzjkuzdBHVnG0IpNofDJlnu5Us1g4B1)fwsyLvbqAfTbKw850PhzAOykJDrbpTqTeEzjkuzdBHVnLQmMkSXucHOuq7kvBGVv)xyjHvwfaPv0UQm5nWtoDk6gxAOYDrbpTqTeEzjkuzdBHVnGQQLiVy4nZoDk6gxAOYDLQnW3Q)lSKWkRcG0kAdOQAjYlgEZ88wfH1jAlkixz4GFjfumnx9FPSeb6ac02NHBk2w(jqQ4Tkc7bnVvryDI2IcYvgouuWtlulHxwIcv2Ww4dA7ZWnfBl)eiv8wfH9GyZnfBl)eiv8gqv1sKxmEH55TkcRt0wuqUYWHkvBGVv)xyjHvwfaPve02NHBk2w(jqQ4Tkc7bXMBk2w(jqQ4nGQQLiVy8cZZBpmht8NJjbZeZzO5YoMdqAX3CYsXC(AP5eAoNFkMR2aAUaIMZ1jnNLFcKkEolNtM(nGMlGqZrzzU(pxaHM7B(HeqphsQw7CUacnhtKFcKkEUSHAERIW6eTffKRmCajvRDUS8tGuXqBFgHvPv0RIrpl6gxAOYnsQw7Cz5NaPI3fjGgwNUYcMN3QiSorBrb5kdh8lPGIP5Q)lLLiqhqG2(mcRspZcMzlSkTIEvm6zr34sdvU9lPGIP5Q)lLLiqhq2fjGgwNUYcMN3EyoM4pxaHM7B(HeZbLHXZrzzoz63aAoMemtmNHMtwfpnNKBONdjvRDoxaHMJjYpbsfpVvryDI2IcYvgoGKQ1oxw(jqQyOTpJqXug7IcEAHAj8YsuOYg2cFBkvzmvyt0nU0qL7IcEAHAj8YsuOYg2cFBavvlrphwLwrVkgnVvryDI2IcYvgo4xsbftZv)xklrGoGaT9zi6gxAOYnsQw7Cz5NaPI3aQQwIEoSkTIEvmAE7H5yI)CbeAUV5hsmhuggphLL5KPFdO5S8tGuXZzO5KvXtZj5g65Kq0CmjyMyERIW6eTffKRmCOOGNwOwcVSefQSHTWh02NHOBCPHk3iPATZLLFcKkEdOQAj65WQ0k6vXO5TkcRt0wuqUYWHkvBGVv)xyjHvwfaPve02NHOBCPHk3iPATZLLFcKkEdOQAj65WQ0k6vXO5TkcRt0wuqUYWHIcEAHAj8YsuOYg2cFqBFgIUXLgQCJKQ1oxw(jqQ4nGQQLONdRsROxfJyZnfBl)eiv8gqv1sKxmEH55TkcRt0wuqUYWHkvBGVv)xyjHvwfaPve02NHOBCPHk3iPATZLLFcKkEdOQAj65WQ0k6vXi2CtX2YpbsfVbuvTe5fJxyEE7H5yI)CbeAUV5hsmNHMtLBPyUONJYc0ZjHO5CeMeAoKKaYCbenMlGq(MZpfZPO5QsciZfwLMtY9CkAo3nczYyAERIW6eTffKRmCajvRDUS8tGuXqBFgHvPv0RIrEXcMN3QiSorBrb5kdh8lPGIP5Q)lLLiqhqG2(mcRsROxfJ8IfmpVvryDI2IcYvgouuWtlulHxwIcv2Ww4dA7ZiSkTIEvmYRxyEERIW6eTffKRmCOs1g4B1)fwsyLvbqAfbT9zewLwrVkg51lmpVvryDI2IcYvgoiJ7US6)kGqlkPQV5TkcRt0wuqUYWbOAaU8GSCbiuNAkO5TkcRt0wuqUYWbG52nMwwUqUvbnVvryDI2IcYvgo4UdRtOTpd3uST8tGuXBve2dYPZWQ0k6vXiVybZZBvewNOTOGCLHdYearGNS0p02NHBk2w(jqQ4Tkc7b50PS0)VRuTb(w9FHLewzvaKwrBavvlroDkl9)7IcEAHAj8YsuOYg2cFBavvlroDgwLwrVkg5flyEERIW6eTffKRmCqg3Dz9La(G2(mCtX2YpbsfVvrypiNoLL()DLQnW3Q)lSKWkRcG0kAdOQAjYPtzP)FxuWtlulHxwIcv2Ww4BdOQAjYPZWQ0k6vXiVybZZBvewNOTOGCLHdFdqY4UlqBFgUPyB5NaPI3QiShKtNYs))Us1g4B1)fwsyLvbqAfTbuvTe50PS0)Vlk4PfQLWllrHkByl8TbuvTe50zyvAf9QyKxSG55TkcRt0wuqUYWbjeTSGQiOTpd3uST8tGuXBve2dYPtzP)FxPAd8T6)cljSYQaiTI2aQQwIC6uw6)3ff80c1s4LLOqLnSf(2aQQwIC6mSkTIEvmYlwW88wfH1jAlkixz4GeIwwqvOtTsmC3INOazSevwIU6wk0W6CvOhMGG2(mkDSTATXAqBavvlrpZWXZBvewNOTOGCLHdsiAzbvHo1kXa0HaiHcQSE0DP7vPXyOTpJshBRwBSg0gqv1s0ZmCmBEu0nU0qLBKuT25YYpbsfVbuvTe9mJxy2PZWQ0k6vXiVybZEAERIW6eTffKRmCqcrllOk0Pwjgii2dcSEqzxxacBcOTpJshBRwBSg0gqv1s0ZmCmBEu0nU0qLBKuT25YYpbsfVbuvTe9mJxy2PZWQ0k6vXiVybZEAERIW6eTffKRmCqcrllOk0Pwjg6RMK5UdkJvQsHHLqqBFgLo2wT2ynOnGQQLONz4y28OOBCPHk3iPATZLLFcKkEdOQAj6zgVWStNHvPv0RIrEXcM908wfH1jAlkixz4GeIwwqvOtTsmcRqOOb1LOl0RcA7ZO0X2Q1gRbTbuvTe9mdhZMhfDJlnu5gjvRDUS8tGuXBavvlrpZ4fMD6mSkTIEvmYlwWSNM3QiSorBrb5kdhKq0YcQcDQvIXdtXR(VqrdQiOTpJshBRwBSg0gqv1s0ZmCmBEu0nU0qLBKuT25YYpbsfVbuvTe9mJxy2PZWQ0k6vXiVybZEAEpVvryDI2q0hTGHOZpw9d0GG2(mKL()TSkEQa0FSlnujBOwcVqquq5zgEZgQLWleefu8IHJoVvryDI2q0hTWvgoy1AJ1GG2(mcftzSTmiqQ4LORYsOW6CtPkJPcBaQQwI8Qib0W6KLX82XoDY0qXugBldcKkEj6QSekSo3uQYyQWgG(acbrLX08wfH1jAdrF0cxz4GaI2OLCJdOTpdHIIvyvYli6JwSauvTenVvryDI2q0hTWvgoGAj86BaAERIW6eTHOpAHRmCabrlnuYsGeA7ZqfH9GwusvJqEXcNozAOykJ93a0sZYsgyvu0jTPuLXuzERIW6eTHOpAHRmCWsHLeqdcA7ZqOOyfwL8cI(OflavvlrCyKBsWD5LxXRHh8GZb]] )


end
