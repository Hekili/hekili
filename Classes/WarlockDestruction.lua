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


    spec:RegisterPack( "Destruction", 20190810, [[dWeINbqivipIsP2KkYNurvmkqWPaHwfLs4vusMfQu3Isa7sKFrjAyQahdKAzQO8mujnnujCnvqBtfv13OuIghLaDokHyDucPMhfP7Hk2hLIdIkr1cPGEiLsAIQOcxufvQnIkr6JucjgjQeLtsjOvcsMjLqsDtujcANus9tujcmukHKSuvur9uOmvkIRIkrOVQIkYEj1Ff1Gv1HjwmQ6XKmzP6YiBwL(mfA0GYPPA1QOsETkuZgLBlLDl53knCq1XrLiA5aphY0fUouTDq03PaJxfvPZtPA9uc18PO2VI1qRnrJ1LG0wF2bqBroWcc9bPZG(Wdo0wQXc7WjngCrDSyK0yL0in25Gqbaxf(wAm4ID2kDTjAm0IduKgdweWrw0wAPrpGHZNuBZsK3Wzs4BPaYnSe5nLLAmECNfwyP51yDjiT1NDa0wKdSGqFq6mOp8aUGRAmbpGTangM3SvngmV3PsZRX6esPXS98NdcfaCv4Bn)5KayR64bkBppSiGJSOT0sJEadNpP2MLiVHZKW3sbKByjYBklhOS98C54gXrX8qFa3ZF2bqBrM3cm)zhyrF4bAmMJcK2enMXfHdp71LaLW0MOTgATjAmQeEg11gQXuapiGlAm0IZYiycOppN5pC(tZF08843BIxuh3bYns4WN)08843BQrTfypV3mdx59ChqsdLWHp)P55XV3KrG3whq59Mr4Wbutu2tOquhpVPCMh6d0yIk8T0yaXR8EZxhq6qB9zAt0yuj8mQRnuJPaEqax0y843BIxuh3bYns4W1yIk8T0ykyYIY8ll0H2AUQnrJrLWZOU2qnMc4bbCrJHwCwgbta95THZ8Cr6S5TaZZJFVPg1wG98EZmCL3ZDajnuchUgtuHVLgtbtwuMFzHo0wZfAt0yuj8mQRnuJPaEqax0yhnVAxwFnOsQTUmXiqckHdxJjQW3sJPGjlkZVSqhARpuBIgJkHNrDTHAmfWdc4IgtjOihEJM305HtrYRlbkHLaut8cn)P5HtrYRlbkHLaut8cnVPZReuKdVrZB18gvDnMOcFlnMcMSOm)YcDOT(81MOXOs4zuxBOgtb8GaUOX4XV3eVOoUdKBK6Rb18NMNh)EtnQTa759Mz4kVN7asAOeo85pnpAXzzemb0N3goZdDIRAmrf(wAm1wxMyeibPdT12sTjAmQeEg11gQXuapiGlAmE87nXlQJ7a5gP(Aqn)P5pAEE87n1O2cSN3BMHR8EUdiPHs4WN)08qyE0IZYiycOpVnCM)SKfCEZMNxbtagju(cev4BjS5TzEOtwK5pnpAXzzemb0N3goZdDIRZdrnMOcFlnMARltmcKG0H2AlO2engvcpJ6Ad1ykGheWfngCksEDjqjSeGAIxO5nD(d1yIk8T0yQTUmXiqcshARTiAt0yuj8mQRnuJPaEqax0ykycWiHM3M5HwJjQW3sJP26YeJajiDOTg6d0MOXev4BPXqlolFDaPXOs4zuxBOo0wdn0At0yIk8T0yiysFnGhhuAmQeEg11gQdT1qFM2enMOcFlnMxkViGeKgJkHNrDTH6qhAmycKRsBI2AO1MOXOs4zuxBOgtb8GaUOX4XV3eVOoUdKBK6Rb18NMhT4SmcMa6ZBdN5HE(tZJwCwgbta95nLZ8CHgtuHVLgtT1Ljgbsq6qB9zAt0yuj8mQRnuJPaEqax0yHWOksEfeOewwTnECu4BLOs4zuF(tZdOM4fAEtNVJdKW3AEBX8hKoCEZMN)O5dHrvK8kiqjSSAB84OW3krLWZO(8NMhqxaHGj8msJjQW3sJ5T2YKG0H2AUQnrJrLWZOU2qnMc4bbCrJPeuKdVrZB68WeixvgqnXlKgtuHVLgtbtwuMFzHo0wZfAt0yIk8T0yOfNLVoG0yuj8mQRnuhARpuBIgJkHNrDTHAmfWdc4IgtuHdjLPIAoHM305568Mnp)rZhcJQiDDaLLQN5bEdfBrjQeEg11yIk8T0yiysFnGhhu6qB95RnrJrLWZOU2qnMc4bbCrJPeuKdVrZB68WeixvgqnXlKgtuHVLgZlLxeqcsh6qJbhqQTXlH2eT1qRnrJjQW3sJHWBTTYEdUgJkHNrDTH6qB9zAt0yuj8mQRnuJPaEqax0yHWOksgbEBDaL3BgjkGFDfLOs4zuxJjQW3sJze4T1buEVzKOa(1vKo0wZvTjAmrf(wAm4B4BPXOs4zuxBOo0wZfAt0yIk8T0yOfNLVoG0yuj8mQRnuhARpuBIgJkHNrDTHAmfWdc4Ig7O5dHrvKqlolFDaLOs4zuxJjQW3sJ5LYlcibPdDOXKL0MOTgATjAmQeEg11gQXuapiGlAm4uK86sGsyjrfoK08NMhcZZJFVjfqqW8YywbtwuQVguZB288hnFimQIKrG3whq59Mr4Wbutu2tuj8mQppeN)08qy(JMxTlRVgujycKRkbiPBFEZMNxuHdjLPIAoHM3M5568quJjQW3sJbeVY7nFDaPdT1NPnrJrLWZOU2qnMc4bbCrJ13i5T2YKGsaQjEHM3M5vckYH3inMOcFlnMcMufXYDQT11bKo0wZvTjAmQeEg11gQXev4BPX8wBzsqAmfWdc4IgdqnXl08Mo)HZFAEim)rZhcJQiPKqum7OwIkHNr95nBEE1US(AqLusikMDulbOM4fAEBMhqnXl08quJPSRyuoeGrkqARHwhAR5cTjAmQeEg11gQXev4BPXucJLfv4BLzok0ymhf5sAKgt1r6qB9HAt0yuj8mQRnuJjQW3sJXlfL3BgMa5Q0ykGheWfnMOchsktf1CcnVPZZfAmLDfJYHamsbsBn06qB95RnrJrLWZOU2qnMc4bbCrJfcJQize4T1buEVzeoCa1eL9evcpJ6ZFAE4uK86sGsyjrfoK08NMhcZdtGCvzrfoK08MnpFimQIKscrXSJAjQeEg1N3S55dHrvK86sGAtuj8mQp)P5fv4qszQOMtO5nDEUyEiQXev4BPXuWKfL5xwOdT12sTjAmrf(wAmG4vEV5RdingvcpJ6Ad1H2AlO2enMOcFln2Dv4iQNflMaEqzEsAAmQeEg11gQdT1weTjAmrf(wAm44a)A3lJzEMGcngvcpJ6Ad1H2AOpqBIgJkHNrDTHAmrf(wAmEPO8EZWeixLgtb8GaUOXGW8hnFimQIKrG3whq59Mr4Wbutu2tuj8mQpVzZZF08HWOksEDjqTjQeEg1N3S55dHrvKmc826akV3mchoGAIYEIkHNr95pnpCksEDjqjSeGAIxO5nLZ8qFW8quJPSRyuoeGrkqARHwhARHgATjAmQeEg11gQXuapiGlASqyufPRdOSu9mpWBOylkrLWZO(8NMNh)Et8I64oqUrch(8NMhT4SmcMa6ZB68hoVfy(dsNnVTyErfoKuMkQ5esJjQW3sJ5LYlcibPdT1qFM2enMOcFlngAXz5RdingvcpJ6Ad1H2AO5Q2engvcpJ6Ad1ykGheWfngp(9M4f1XDGCJuFnO0yIk8T0yQTUmXiqcshARHMl0MOXOs4zuxBOgtb8GaUOXoA(qyufPRdOSu9mpWBOylkrLWZOUgtuHVLgdbt6Rb84GshARH(qTjAmQeEg11gQXuapiGlASJMVVrsTLIQaib1ZxM0OmpoOsaQjEHM)08hnVOcFRKAlfvbqcQNVmPrjVYxMBewm)P5fv4qszQOMtO5nD(d1yIk8T0yQTuufajOE(YKgPdT1qF(At0yIk8T0yEP8IasqAmQeEg11gQdDOXuDK2eT1qRnrJrLWZOU2qnMc4bbCrJfcJQize4T1buEVzeoCa1eL9evcpJ6ZFAEa1eVqZB68wW5pnVAxwFnOsi8wBRSxxcuclbOM4fAEtNNlshQXev4BPX8wBzsq6qB9zAt0yuj8mQRnuJPaEqax0yHWOksgbEBDaL3BgHdhqnrzprLWZO(8NMxTlRVgujeERTv2RlbkHLaut8cnVPZZfPdN)08hnpp(9M4f1XDGCJeo85pnpAXzzemb0N3055Iex1yIk8T0yQTUmXiqcshAR5Q2engvcpJ6Ad1yIk8T0yIfJGjabLVBf59MHVgqanMc4bbCrJP2L1xdQecV12k71LaLWs4WN3S55v7Y6RbvcH3ABL96sGsyja1eVqZBkN55cnwjnsJjwmcMaeu(UvK3Bg(Aab0H2AUqBIgtuHVLgdH3ABL96sGsyAmQeEg11gQdT1hQnrJrLWZOU2qnMc4bbCrJbNIKxxcucljQWHK0yIk8T0ygXfq3LkV3SyXeydy6qB95RnrJrLWZOU2qnMc4bbCrJbNIKxxcucljQWHKM)08qyE4uK86sGsyja1eVqZB68NDq6W5nBEE4uK86sGsyja1eVqZB68ND28NMhT4SmcMa6ZBdN55A68N3S55pA(qyufjJaVToGY7nJWHdOMOSNOs4zuFEiQXev4BPX6c44mAXzzVqHW7mpSRdT12sTjAmQeEg11gQXuapiGlAm4uK86sGsyjrfoK08NMhcZdNIKxxcuclbOM4fAEtNh6dthoVzZZJwCwgbta95nDEUMoC(tZdH55XV3uxahNrlol7fkeEN5H9eo85nBE(JMpegvrYiWBRdO8EZiC4aQjk7jQeEg1N)089nsERTmjOeGAIxO5TzEOpBEiope1yIk8T0ynQTa759Mz4kVN7asAiDOT2cQnrJrLWZOU2qnMc4bbCrJfEJYXM7onVnZR2L1xdQecV12k71LaLWsDCGe(wZB18C9anMOcFlngcV12k71LaLW0H2AlI2engvcpJ6Ad1ykGheWfnw4nAEBMNRhm)P5dVr5yZDNM3M5v7Y6RbvYiUa6Uu59MflMaBal1Xbs4BnVvZZ1d0yIk8T0ygXfq3LkV3SyXeydy6qBn0hOnrJrLWZOU2qnMc4bbCrJP2L1xdQecV12k71LaLWsaQjEHM3M5dVr5yZDNM)08WPi51LaLWsaQjEHM305p7G0HAmrf(wASUaooJwCw2lui8oZd76qBn0qRnrJrLWZOU2qnMc4bbCrJP2L1xdQecV12k71LaLWsaQjEHM3M5dVr5yZDNM)08qyE4uK86sGsyja1eVqZB68qFy6W5nBEEE87n1fWXz0IZYEHcH3zEypHdF(tZJwCwgbta95nDEUope1yIk8T0ynQTa759Mz4kVN7asAiDOTg6Z0MOXOs4zuxBOgtb8GaUOXu7Y6RbvcH3ABL96sGsyja1eVqZBZ8Hamsrk8gLJn3DA(tZdNIKxxcuclbOM4fAEtN)SdshQXev4BPX6c44mAXzzVqHW7mpSRdT1qZvTjAmQeEg11gQXuapiGlAm1US(AqLq4T2wzVUeOewcqnXl082mFiaJuKcVr5yZDNM)08qyE4uK86sGsyja1eVqZB68qFy6W5nBEEE87n1fWXz0IZYEHcH3zEypHdF(tZJwCwgbta95nDEUope1yIk8T0ynQTa759Mz4kVN7asAiDOTgAUqBIgJkHNrDTHAmfWdc4Igl8gLJn3DAEtNNRhOXev4BPXq4T2wzVUeOeMo0wd9HAt0yuj8mQRnuJPaEqax0yH3OCS5UtZB68C9anMOcFlnMrCb0DPY7nlwmb2aMo0wd95RnrJrLWZOU2qnMc4bbCrJfEJYXM7onVPZFg0ZFA(WBuo2C3P5TzEUqJjQW3sJ1fWXz0IZYEHcH3zEyxhARH2wQnrJrLWZOU2qnMc4bbCrJfEJYXM7onVPZd95p)P5dVr5yZDNM3M5pFnMOcFlnwJAlWEEVzgUY75oGKgshARH2cQnrJjQW3sJXZ2TN3BoGrzQOMDngvcpJ6Ad1H2AOTiAt0yIk8T0ygSawhsYRmGqBjLI0yuj8mQRnuhARp7aTjAmrf(wAmGdhoJYELrWffPXOs4zuxBOo0wFg0At0yuj8mQRnuJPaEqax0yWPi51LaLWsIkCiP5nBE(WBuo2C3P5nDEUEGgtuHVLgd(g(w6qB9zNPnrJrLWZOU2qnMc4bbCrJbNIKxxcucljQWHKM)08qy(JMpegvrYiWBRdO8EZiC4aQjk7jQeEg1N3S55HW8hnpHquPOuJAlWEEVzgUY75oGKgk1KZ1cM3S555XV3uJAlWEEVzgUY75oGKgkbOM4fAEio)P5HW8hnFimQIuxahNrlol7fkeEN5H9evcpJ6ZB288843BQlGJZOfNL9cfcVZ8WEcqnXl08qCEioVzZZhEJYXM7onVPCMh6d1yIk8T0y8earGJ9YOo0wFgx1MOXOs4zuxBOgtb8GaUOXGtrYRlbkHLev4qsZFAEim)rZhcJQize4T1buEVzeoCa1eL9evcpJ6ZB288qy(JMNqiQuuQrTfypV3mdx59ChqsdLAY5AbZB288843BQrTfypV3mdx59ChqsdLaut8cnpeN)08qy(JMpegvrQlGJZOfNL9cfcVZ8WEIkHNr95nBEEE87n1fWXz0IZYEHcH3zEypbOM4fAEiopeN3S55dVr5yZDNM3uoZd9HAmrf(wAmE2U98fhyxhARpJl0MOXOs4zuxBOgtb8GaUOXGtrYRlbkHLev4qsZFAEim)rZhcJQize4T1buEVzeoCa1eL9evcpJ6ZB288qy(JMNqiQuuQrTfypV3mdx59ChqsdLAY5AbZB288843BQrTfypV3mdx59ChqsdLaut8cnpeN)08qy(JMpegvrQlGJZOfNL9cfcVZ8WEIkHNr95nBEEE87n1fWXz0IZYEHcH3zEypbOM4fAEiopeN3S55dVr5yZDNM3uoZd9HAmrf(wASRdiE2UDDOT(Sd1MOXOs4zuxBOgtb8GaUOXGtrYRlbkHLev4qsZFAEim)rZhcJQize4T1buEVzeoCa1eL9evcpJ6ZB288WPi51LaLWsaQjEHM3uoZF2bZdX5nBE(WBuo2C3P5nLZ8NDGgtuHVLgdhrzpOgshARp781MOXOs4zuxBOgtuHVLgd(QoMcKBXupR2gC8qcFRCNG0vKgtb8GaUOX6BK8wBzsqja1eVqZBdN5puJvsJ0yWx1XuGClM6z12GJhs4BL7eKUI0H26ZSLAt0yuj8mQRnuJjQW3sJb2qbWrb1ZqUBF3CFzmnMc4bbCrJ13i5T2YKGsaQjEHM3goZF48NMhcZR2L1xdQecV12k71LaLWsaQjEHM3goZF2bZB288H3OCS5UtZB68C9G5HOgRKgPXaBOa4OG6zi3TVBUVmMo0wFMfuBIgJkHNrDTHAmrf(wAmemhscKHKQTLbeZvAmfWdc4IgRVrYBTLjbLaut8cnVnCM)W5pnpeMxTlRVgujeERTv2RlbkHLaut8cnVnCM)SdM3S55dVr5yZDNM30556bZdrnwjnsJHG5qsGmKuTTmGyUshARpZIOnrJrLWZOU2qnMOcFlnMWLe3HVbvrUe8Wz4inMc4bbCrJ13i5T2YKGsaQjEHM3goZF48NMhcZR2L1xdQecV12k71LaLWsaQjEHM3goZF2bZB288H3OCS5UtZB68C9G5HOgRKgPXeUK4o8nOkYLGhodhPdT1C9aTjAmQeEg11gQXev4BPXcVtOybTSA705vJPaEqax0y9nsERTmjOeGAIxO5THZ8ho)P5HW8QDz91GkHWBTTYEDjqjSeGAIxO5THZ8NDW8MnpF4nkhBU708MopxpyEiQXkPrASW7ekwqlR2oDE1H2AUcT2engvcpJ6Ad1yIk8T0yq6clV3mkwqdPXuapiGlAS(gjV1wMeucqnXl082Wz(dN)08qyE1US(AqLq4T2wzVUeOewcqnXl082Wz(ZoyEZMNp8gLJn3DAEtNNRhmpe1yL0ingKUWY7nJIf0q6qhASoDfCwOnrBn0At0yIk8T0yi4eJLzR6yngvcpJ6Ad1H26Z0MOXev4BPXqEzKYnXOR0yuj8mQRnuhAR5Q2engvcpJ6Ad1ykGheWfngmbYvLfv4qsZFAErfoKuMkQ5eAEtN)W5TaZhcJQi51La1MOs4zuFERMhcZhcJQi51La1MOs4zuF(tZhcJQi5vqGsyz124XrHVvIkHNr95HOgtuHVLgtjmwwuHVvM5OqJXCuKlPrAmycKRshAR5cTjAmQeEg11gQXuapiGlASJMhcZdNIKxxcucljQWHKM)089nsERTmjOeGAIxO5TAEON3M5HtrYRlbkHLaut8cnpeN3S55rWjglhcWifOKscrXSJAZBZ8qpVzZZF08HWOksgbEBDaL3BgHdhqnrzprLWZOUgtuHVLgtjHOy2rnDOT(qTjAmQeEg11gQXuapiGlAmrfoKuMkQ5eAEBM)mnMOcFlnMsySSOcFRmZrHgJ5OixsJ0yYs6qB95RnrJrLWZOU2qnMOcFlnM3AltcsJPaEqax0ya6ciemHNrZFAEim)rZhcJQiPKqum7OwIkHNr95nBEE1US(AqLusikMDulbOM4fAEBMhqnXl08quJPSRyuoeGrkqARHwhARTLAt0yuj8mQRnuJPaEqax0yHWOksEfeOewwTnECu4BLOs4zuF(tZlQW3kPGjlkZVSi5v(YCJWI5pnpGAIxO5nD(ooqcFR5TfZFq6qnMOcFlnM3AltcshARTGAt0yuj8mQRnuJjQW3sJPegllQW3kZCuOXyokYL0inMQJ0H2AlI2engvcpJ6Ad1ykGheWfn2rZdNIKxxcucljQWHKM3S55pA(qyufjJaVToGY7nJWHdOMOSNOs4zuxJjQW3sJDxfoI6zXIjGhuMNKMo0wd9bAt0yuj8mQRnuJPaEqax0y843BcqQJzecLVlqrjajQqJjQW3sJfWOmEXV4vpFxGI0H2AOHwBIgtuHVLgdooWV29YyMNjOqJrLWZOU2qDOTg6Z0MOXOs4zuxBOgtb8GaUOXoA((gj1wkQcGeupFzsJY84GkbOM4fA(tZF08Ik8TsQTuufajOE(YKgL8kFzUryHgtuHVLgtTLIQaib1ZxM0iDOTgAUQnrJjQW3sJPGjvrSCNABDDaPXOs4zuxBOo0wdnxOnrJrLWZOU2qnMOcFlngVuuEVzycKRsJPaEqax0yqy((gjV1wMeucqnXl082mFFJK3Altck1Xbs4BnVTy(dshoVzZZF08HWOksEfeOewwTnECu4BLOs4zuFEio)P5HW8hnVAxwFnOsi8wBRSxxcuclbiPBFEZMN)O5dHrvKmc826akV3mchoGAIYEIkHNr95nBE(qyufjJaVToGY7nJWHdOMOSNOs4zuF(tZdNIKxxcuclbOM4fAEt5mp0hmpe1yk7kgLdbyKcK2AO1H2AOpuBIgJkHNrDTHAmfWdc4IglegvrYiWBRdO8EZiC4aQjk7jQeEg1N)08WPi51LaLWsIkCijnMOcFlnMsySSOcFRmZrHgJ5OixsJ0ygxeo8SxxcucthARH(81MOXev4BPXqlolFDaPXOs4zuxBOo0wdTTuBIgJkHNrDTHASfUgdrHgtuHVLgdsb4cpJ0yqkmCsJjQWHKYurnNqZBZ8qp)P5v7Y6RbvcMa5QsaQjEHM3uoZd9bZB288QDz91GkHWBTTYEDjqjSeGAIxO5nLZ8qF48NMhcZhcJQize4T1buEVzeoCa1eL9evcpJ6ZB288HWOksDbCCgT4SSxOq4DMh2tuj8mQp)P5v7Y6RbvQlGJZOfNL9cfcVZ8WEcqnXl08MYzEOpCEioVzZZhcJQi1fWXz0IZYEHcH3zEyprLWZO(8NMxTlRVguPUaooJwCw2lui8oZd7ja1eVqZBkN5H(W5pnpeMxTlRVgujeERTv2RlbkHLaut8cnVnZhEJYXM7onVzZZR2L1xdQecV12k71LaLWsaQjEHM3Q5v7Y6RbvcH3ABL96sGsyPooqcFR5Tz(WBuo2C3P5HOgdsbKlPrAm47YYOfNLrWeqhPdT1qBb1MOXOs4zuxBOgtb8GaUOX4XV3eVOoUdKBK6Rb18NMhT4SmcMa6ZBdN5HoD48wG5piX15TfZhcJQiDzcc2cjbsuj8mQp)P5pAEifGl8mkbFxwgT4SmcMa6inMOcFlnMARltmcKG0H2AOTiAt0yuj8mQRnuJPaEqax0yOfNLrWeqFEtN)S5pnpeM)O5HuaUWZOe8Dzz0IZYiycOJM3S55vWeGrcnVnZd98quJjQW3sJHGj91aECqPdT1NDG2engvcpJ6Ad1ykGheWfngeMpegvrYiWBRdO8EZiC4aQjk7jQeEg1N3S55flMaEqjfqqW8YywbtwuIkHNr95H48NMhofjVUeOewsuHdjnVzZZZJFVPUaooJwCw2lui8oZd7jC4ZB288843BcqQJzecLVlqrjajQy(tZZJFVjaPoMriu(UafLaut8cnVnZReuKdVrAmrf(wAmfmzrz(Lf6qB9zqRnrJrLWZOU2qnMc4bbCrJXJFVjErDChi3iHdF(tZF08qkax4zuc(USmAXzzemb0rZFA(JMpegvrIas3vs4BLOs4zuxJjQW3sJPGjlkZVSqhARp7mTjAmQeEg11gQXuapiGlASJMhsb4cpJsW3LLrlolJGjGoA(tZhcJQiraP7kj8Tsuj8mQp)P5HW8DIh)Eteq6UscFReGAIxO5nDELGIC4nAEZMNNh)Et8I64oqUrch(8quJjQW3sJPGjlkZVSqhARpJRAt0yuj8mQRnuJPaEqax0yqyE0IZYiycOpVnCMNlshoVfy(dsNnVTyErfoKuMkQ5eAEio)P5HW8hnFimQIKrG3whq59Mr4Wbutu2tuj8mQpVzZZR2L1xdQecV12k71LaLWsaQjEHM3M5TLZdrnMOcFlnMcMSOm)YcDOT(mUqBIgJkHNrDTHAmfWdc4Igtbtagj082mp0Amrf(wAm1wxMyeibPdT1NDO2enMOcFlnMxkViGeKgJkHNrDTH6qh6qJbjbq(wARp7aOTihybpGlsqFi0Amdeq5LrKgZcBWxqq95p)5fv4BnpZrbknqPXGd2RZinMTN)CqOaGRcFR5pNeaBvhpqz75HfbCKfTLwA0dy48j12Se5nCMe(wkGCdlrEtz5aLTNNlh3iokMh6d4E(ZoaAlY8wG5p7al6dpyGAGY2ZFUpVKcpO(880Db08QTXlX88KrVqP55YvkcEGMV2YcataTloBErf(wO53Izpnqz75fv4BHsWbKAB8sW5Ye0Xdu2EErf(wOeCaP2gVewXXY7U9bkBpVOcFlucoGuBJxcR4yPGBSrviHV1aLOcFlucoGuBJxcR4yjcV12kdNIbkrf(wOeCaP2gVewXXsJaVToGY7nJefWVUI42VCcHrvKmc826akV3msua)6kkrLWZO(aLTNxuHVfkbhqQTXlHvCSevcCeSnYOqc0aLOcFlucoGuBJxcR4yj8n8TgOev4BHsWbKAB8syfhlrlolFDanqjQW3cLGdi124LWkow6LYlcibXTF5CuimQIeAXz5RdOevcpJ6dudu2E(Z95Lu4b1NNGKa2Np8gnFaJMxuXcM3rZlqkot4zuAGsuHVfIdcoXyz2QoEGsuHVfYkowI8YiLBIrxnqnqz755Yeix184icnVmpcoPCHnpCGVapSppZrX8BnFBrX8nCw4HamsX8ifvcWxe3ZZJhZhWO5dbyKI5dyacbBz95vsnpKcW(8DcovDVmo)wZhcJQanqjQW3cXrjmwwuHVvM5OG7sAehycKRIB)YbMa5QYIkCiPtIkCiPmvuZjKPhAbcHrvK86sGAtuj8mQBfecHrvK86sGAtuj8mQFkegvrYRGaLWYQTXJJcFRevcpJ6qCGsuHVfYkowQKqum7Og3(LZrqaofjVUeOewsuHdjDQVrYBTLjbLaut8czf02aNIKxxcuclbOM4fcIMnJGtmwoeGrkqjLeIIzh1SbAZMpkegvrYiWBRdO8EZiC4aQjk7jQeEg1hOS98MyWoFiaJumpsrLa8fnVaO5HjvNr95z(X08iVmYO5dbyKI5nWdyZZLjqUQ5nGeiP(8ELMhleq4LX5nWdyZhWaenFiaJuG4EEzEeCs5cZTyQppx(EUNhoWxGh2N3rZdiUK4oG6duIk8TqwXXsLWyzrf(wzMJcUlPrCKL42VCev4qszQOMtiBoBGY2ZBHT2YKGMhbBXz95lcscm)vyS537D(agnpCG3eG95dbyKI08w4DEBvcrXSJAZBGZyZdOlGqWM3cBTLjbnppDxanVhZtNx4oGqCpFaJa05bnFTZdibT18XoVbckO5dVrZReu4LX59yGsuHVfYkow6T2YKG4wzxXOCiaJuG4an3(LdGUacbt4z0jiCuimQIKscrXSJAjQeEg1nBwTlRVgujLeIIzh1saQjEHSbqnXleehOS982(CYdyZBHvqGsyZBRBJhhf(wZhcJQG6CpVhNh08WxeY5z08wyRTmjO5nWzS5lI6Zh78808a6ciemQppA3IaZhWKA(agnpGAIxEzC(ooqcFR5rIDe3Z735dyeGopO5fgGKU95L5TvyYIM3WLfZV18bmAEde7Zh78bmA(qagPinqjQW3czfhl9wBzsqC7xoHWOksEfeOewwTnECu4BLOs4zu)KOcFRKcMSOm)YIKx5lZnclobOM4fY0ooqcFlBXbPdhOS98MaJM3iveqyZdWz087D(agEJF(7cMpegvbAEhnFSZ3KZR3ClMMpGrZx4nEcm)ENhhrO5378KOGnqjQW3czfhlvcJLfv4BLzok4UKgXr1rduIk8TqwXXY7QWruplwmb8GY8K042VCocofjVUeOewsuHdjz28rHWOksgbEBDaL3BgHdhqnrzprLWZO(aLOcFlKvCSmGrz8IFXRE(UafXTF5WJFVjaPoMriu(UafLaKOIbkrf(wiR4yjCCGFT7LXmptqXaLOcFlKvCSuTLIQaib1ZxM0iU9lNJ6BKuBPOkasq98LjnkZJdQeGAIxOthjQW3kP2srvaKG65ltAuYR8L5gHfduIk8TqwXXsfmPkIL7uBRRdObkBpVjWO5978QT6E4BnpmcqZlmde7O5f4WzoHMNltGCvZh78OTrbmVmo)gWiW8bmPMpGrZdh4nbyF(qagPyGsuHVfYkowctGCvCRSRyuoeGrkqCGMB)Ybc9nsERTmjOeGAIxiB6BK8wBzsqPooqcFlBXbPdnB(OqyufjVccuclR2gpok8Tsuj8mQdXtq4i1US(AqLq4T2wzVUeOewcqs3UzZhfcJQize4T1buEVzeoCa1eL9evcpJ6MnhcJQize4T1buEVzeoCa1eL9evcpJ6NGtrYRlbkHLaut8czkhOpaIduIk8TqwXXsLWyzrf(wzMJcUlPrCmUiC4zVUeOeg3(LtimQIKrG3whq59Mr4Wbutu2tuj8mQFcofjVUeOewsuHdjnqz75XwC28CPoGMhbBXz955P5XruF(TMxTlRVguCpVhZ3xcnFTX8cC4KaM3GfeWMhjq6LX5VlyEJuraj8Y48yloBEmycOJMVJd8Y48QDz91GcnqjQW3czfhlrlolFDanqjQW3czfhlHuaUWZiUlPrCGVllJwCwgbtaDe3qkmCIJOchsktf1Cczd0Nu7Y6RbvcMa5QsaQjEHmLd0hy2SAxwFnOsi8wBRSxxcuclbOM4fYuoqF4jiecJQize4T1buEVzeoCa1eL9evcpJ6MnhcJQi1fWXz0IZYEHcH3zEyprLWZO(j1US(AqL6c44mAXzzVqHW7mpSNaut8czkhOpeIMnhcJQi1fWXz0IZYEHcH3zEyprLWZO(j1US(AqL6c44mAXzzVqHW7mpSNaut8czkhOp8eeu7Y6RbvcH3ABL96sGsyja1eVq2eEJYXM7oz2SAxwFnOsi8wBRSxxcuclbOM4fYk1US(AqLq4T2wzVUeOewQJdKW3YMWBuo2C3jioqz75T1TUmXiqcAEeSfN1NFlM955P5XruF(yNhrX84WN3wHjlAEdxwGsZZLYeeSfscmpJc0826wxMyeibnppnpoI6ZtcG5ey(yNhrX84WNxQ5TWs5fbKGMNNUlGM3wnmnVfENxMVjNRfmVAxwFnOM3rZR2MxgNhho3ZJeiP5vWeGrcn)DbZ7XaLOcFlKvCSuT1LjgbsqC7xo843BIxuh3bYns91G6eAXzzemb0THd0PdTahK4QTiegvr6YeeSfscKOs4zu)0rqkax4zuc(USmAXzzemb0rdu2EEmysFnGhhuZ7O5XruFEbnVmF3rQfVI5T1TUmXiqcA(yN3iveqcAEemb0rZ735TV4Z3368eZdtGKMNQf3iS5VlyEzEBfMSO5nCzrAEtGrZJKgnpaNrO5f(fpMhjq6LX59y(7cMVjNRfmVAxwFnOqZlWHZCcnqjQW3czfhlrWK(AapoO42VCqlolJGjGUPNDcchbPaCHNrj47YYOfNLrWeqhz2ScMamsiBGgIdu2EEBfMSO5nCzX8We08icsciS5HViKZZO5Xr08QT6E4BHsZBRabbZlJZBRWKfX98wuaEBDan)ENhdhoGAIYo3ZlvF(ZHaoEESfNzrpVfwOq4DMh2NxyS5VcKlyELGcVmoVGMVjL95TvdrZlO5HViKZZO5nagvZlL95378bmQnVaO5fv4qsduIk8TqwXXsfmzrz(LfC7xoqiegvrYiWBRdO8EZiC4aQjk7jQeEg1nBwSyc4bLuabbZlJzfmzrjQeEg1H4j4uK86sGsyjrfoKKzZ843BQlGJZOfNL9cfcVZ8WEchUzZ843BcqQJzecLVlqrjajQ4ep(9MaK6ygHq57cuucqnXlKnkbf5WB0aLTN3cVZJT4S5XGjGoAEbqZxBmpp5LX5HVlJ6ZlvF(Znq6UscFR5D081gZhcJQG6Cp)5chfZJGtvFEB1q08cA(agzFEEsTnAEbsXzcpJgOev4BHSIJLkyYIY8ll42VC4XV3eVOoUdKBKWHF6iifGl8mkbFxwgT4SmcMa6OthfcJQiraP7kj8Tsuj8mQpqz75pN8a28NBG0DLe(wCpVhNh088urxx5cB(yNVjNxV5wmnFaJMhhE4nA(TMpGrZ3jE87nnpx2Aabjb4EEpopO5rHZyZZtrqG5JDECenVTctw08gUSyEV1OUlbXSpVFN3qrDChi3yEhnpo8bkrf(wiR4yPcMSOm)YcU9lNJGuaUWZOe8Dzz0IZYiycOJofcJQiraP7kj8Tsuj8mQFccDIh)Eteq6UscFReGAIxitvckYH3iZM5XV3eVOoUdKBKWHdXbkBp)5gsQM3ayunpsG0lJCpFFNV2y(fscOe4ZV18yloBEmycOJgOev4BHSIJLkyYIY8ll42VCGaAXzzemb0THdxKo0cCq6mBHOchsktf1CcbXtq4OqyufjJaVToGY7nJWHdOMOSNOs4zu3Sz1US(AqLq4T2wzVUeOewcqnXlKn2sioqz75phBDEI5xijGsGp)wZRGjaJeA(9oVTU1LjgbsqduIk8TqwXXs1wxMyeibXTF5OGjaJeYgOhOev4BHSIJLEP8Iasqdudu2E(ZzXR5378CPoGM3rZh2H7kHXSpFaJMhMBegHI5Hd8f4H95fv4BX9884X8kceIxZJ8axcFl08xbYfmpoYlJZBRWKfnVHllM3luqsFGsuHVfkjlXbiEL3B(6aIB)YbofjVUeOewsuHdjDcc843BsbeemVmMvWKfL6RbLzZhfcJQize4T1buEVzeoCa1eL9evcpJ6q8eeosTlRVgujycKRkbiPB3SzrfoKuMkQ5eYgUcXbkBpVTctQIyZFoO2wxhqZVfZ(8frD08BrZBHT2YKGMxuHdjnFhh4LX59anVsqX83fmpx(EUtZBrfWBcW(8HamsX8oAECe1NhgbO5VlyEK3GZCLh2hOev4BHsYswXXsfmPkIL7uBRRdiU9lN(gjV1wMeucqnXlKnkbf5WB0aLTNhZBotaZh78iVmYO5dbyKcUNpGraAEhnFTZxe1Np25b0fqiyZBHT2YKGqZ735TvjefZoQnVsQ5778EmVxOGK(aLOcFluswYkow6T2YKG4wzxXOCiaJuG4an3(LdGAIxitp8eeokegvrsjHOy2rTevcpJ6MnR2L1xdQKscrXSJAja1eVq2aOM4fcIdu2E(ZzCgHM)UG5v7Y6RbfA((oFTX8kyszKM)UG55Y3Zn3ZJ25vcJnFaJMhjnAEMJI5f08BnpYlJmA(qagPyGsuHVfkjlzfhlvcJLfv4BLzok4UKgXr1rdu2EEtGbiA(qagPanVJMxQ59YcWtHbevZReenFatI5n6qsO5L5rm3iSyEEQORhZh78WCJWiW8Wb(c8W(8CzcKRAGsuHVfkjlzfhlHjqUkUv2vmkhcWifioqZTF5iQWHKYurnNqMYfdu2E(ZzXR5378CPoGM3aNXMhfciMp257BZljO53AEyKaP955Y3Zn3ZZJhZJ2gnpYnw(1vsfZBRWKfnVHllMNh)ErZBGZyZJcNXM3Odjnpm3imcmFxAIrA(fpGJhZV18RsjiFRbkrf(wOKSKvCSubtwuMFzb3(LtimQIKrG3whq59Mr4Wbutu2tuj8mQFcofjVUeOewsuHdjDccWeixvwuHdjz2CimQIKscrXSJAjQeEg1nBoegvrYRlbQnrLWZO(jrfoKuMkQ5eYuUaIdu2EEdfaWlJZlL95PZRIGh(wiUN)Cw8A(9opxQdO5nWzS55P5XruFEbnFdxbBEbnp8fHCEgX98iVu08nCw4Wz08QfUtO5378EmVsQ5rHOoEGsuHVfkjlzfhlbIx59MVoGgOev4BHsYswXXY7QWruplwmb8GY8K0gOev4BHsYswXXs44a)A3lJzEMGIbkBp)5gsQM3VZhWO55Yeix18Wb(c8W(8mhfZBWwNNyEEAECe15EEUmbYvnVJMhoGIW(8nCfS5VaIMVlnXinVu95beAXbkcnVu95rWwCwFEEAECe1NxyTffZV18QDz91GAGsuHVfkjlzfhlHjqUkUv2vmkhcWifioqZTF5aHJcHrvKmc826akV3mchoGAIYEIkHNrDZMpkegvrYRlbQnrLWZOUzZHWOksgbEBDaL3BgHdhqnrzprLWZO(j4uK86sGsyja1eVqMYb6dG4aLTNNlrenpxQdO5LQpVHaVHITO5978gkQJ7a5gZ7O5fv4qsCpVGMNTLX5f08EmVboJnFTX8lKeqjWNFR5XwC28yWeqhnqjQW3cLKLSIJLEP8IasqC7xoHWOksxhqzP6zEG3qXwuIkHNr9t843BIxuh3bYns4WpHwCwgbtaDtp0cCq6mBHOchsktf1Ccnqz755sqaJaZJT4S5XGjG(8gPIas4LX5fEN5HtO5fanVXD7ZFDgJaZ735RnMhh5LX55sDanVu95ne4nuSfnqjQW3cLKLSIJLOfNLVoGgOev4BHsYswXXs1wxMyeibXTF5WJFVjErDChi3i1xdQbkrf(wOKSKvCSebt6Rb84GIB)Y5OqyufPRdOSu9mpWBOylkrLWZO(aLOcFluswYkowQ2srvaKG65ltAe3(LZr9nsQTuufajOE(YKgL5XbvcqnXl0PJev4BLuBPOkasq98Ljnk5v(YCJWItIkCiPmvuZjKPhoqz75pN8a28CPoGMxQ(8gc8gk2I4EElSuErajO5nWzS55P5L5rbylJZFDgJaP5TW48GMhotuuFEyeGM)UG5fgB(qyufO5JDE4acsQI5fLY7ufcJzFECKxgNpGrZJ8YiJMpeGrkMhSHe(wZZCumqjQW3cLKLSIJLEP8Iasqdudu2E(Zz6cieS59wBzsqZZt3fqZtvqaVmoVmVfLfdh(8wyDjqjS5JD(fE4n3IP5nQ6O0aLOcFlus1rC8wBzsqC7xoHWOksgbEBDaL3BgHdhqnrzprLWZO(ja1eVqMAbpP2L1xdQecV12k71LaLWsaQjEHmLlshoqz755serZR26YeJajO5px4OyEE6UaAElklgo85TW6sGsyZh78l8WBUftZBu1rPbkrf(wOKQJSIJLQTUmXiqcIB)YjegvrYiWBRdO8EZiC4aQjk7jQeEg1pP2L1xdQecV12k71LaLWsaQjEHmLlshE6iE87nXlQJ7a5gjC4NqlolJGjGUPCrIRduIk8TqjvhzfhlXru2dQXDjnIJyXiycqq57wrEVz4RbeGB)YrTlRVgujeERTv2RlbkHLWHB2SAxwFnOsi8wBRSxxcuclbOM4fYuoCXaLOcFlus1rwXXseERTv2RlbkHnqjQW3cLuDKvCS0iUa6Uu59MflMaBaJB)YbofjVUeOewsuHdjnqjQW3cLuDKvCSSlGJZOfNL9cfcVZ8Wo3(LdCksEDjqjSKOchs6eeGtrYRlbkHLaut8cz6zhKo0Sz4uK86sGsyja1eVqME2zNqlolJGjGUnC4A68nB(OqyufjJaVToGY7nJWHdOMOSNOs4zuhIduIk8TqjvhzfhlBuBb2Z7nZWvEp3bK0qC7xoWPi51LaLWsIkCiPtqaofjVUeOewcqnXlKPqFy6qZMrlolJGjGUPCnD4jiWJFVPUaooJwCw2lui8oZd7jC4MnFuimQIKrG3whq59Mr4Wbutu2tuj8mQFQVrYBTLjbLaut8czd0Nbrioqz75TW78NdmlCEhnFTX8as62NNhpM3(IpVsQ5nsX8TfqZhWKA(TO596sGsyZ71880Db08bmAEQ6ZV35dy08x3iSG75r4T2wZhWO5TW6sGsyZxRbduIk8Tqjvhzfhlr4T2wzVUeOeg3(Lt4nkhBU7KnQDz91GkHWBTTYEDjqjSuhhiHVLvC9Gbkrf(wOKQJSIJLgXfq3LkV3SyXeydyC7xoH3iB46bNcVr5yZDNSrTlRVgujJ4cO7sL3BwSycSbSuhhiHVLvC9GbkBpVfENpGrZFDJWI5nWzS5PQpppDxan)5aZcN3rZZlQJNhho3ZJWBTTMpGrZBH1LaLWgOev4BHsQoYkow2fWXz0IZYEHcH3zEyNB)YrTlRVgujeERTv2RlbkHLaut8czt4nkhBU70j4uK86sGsyja1eVqME2bPdhOev4BHsQoYkow2O2cSN3BMHR8EUdiPH42VCu7Y6RbvcH3ABL96sGsyja1eVq2eEJYXM7oDccWPi51LaLWsaQjEHmf6dthA2mp(9M6c44mAXzzVqHW7mpSNWHFcT4SmcMa6MYvioqz75TW78bmA(RBewmVboJnpv955P7cO596sGsyZ7O55f1XZJdN75Xr08NdmlCGsuHVfkP6iR4yzxahNrlol7fkeEN5HDU9lh1US(AqLq4T2wzVUeOewcqnXlKnHamsrk8gLJn3D6eCksEDjqjSeGAIxitp7G0HduIk8TqjvhzfhlBuBb2Z7nZWvEp3bK0qC7xoQDz91GkHWBTTYEDjqjSeGAIxiBcbyKIu4nkhBU70jiaNIKxxcuclbOM4fYuOpmDOzZ843BQlGJZOfNL9cfcVZ8WEch(j0IZYiycOBkxH4aLTN3cVZhWO5VUryX8oAEHFXJ5JDEQ6CppoIM3wphO5r4kyZhWKy(agzFEJumVGMVHRGnF4nAEC4ZlO5HViKZZObkrf(wOKQJSIJLi8wBRSxxcucJB)Yj8gLJn3DYuUEWaLOcFlus1rwXXsJ4cO7sL3BwSycSbmU9lNWBuo2C3jt56bduIk8Tqjvhzfhl7c44mAXzzVqHW7mpSZTF5eEJYXM7oz6zqFk8gLJn3DYgUyGsuHVfkP6iR4yzJAlWEEVzgUY75oGKgIB)Yj8gLJn3DYuOp)tH3OCS5Ut2C(duIk8Tqjvhzfhl5z72Z7nhWOmvuZ(aLOcFlus1rwXXsdwaRdj5vgqOTKsrduIk8TqjvhzfhlboC4mk7vgbxu0aLOcFlus1rwXXs4B4BXTF5aNIKxxcucljQWHKmBo8gLJn3DYuUEWaLOcFlus1rwXXsEcGiWXEzKB)YbofjVUeOewsuHdjDcchfcJQize4T1buEVzeoCa1eL9evcpJ6MndHJieIkfLAuBb2Z7nZWvEp3bK0qPMCUwGzZ843BQrTfypV3mdx59ChqsdLaut8cbXtq4OqyufPUaooJwCw2lui8oZd7jQeEg1nBMh)EtDbCCgT4SSxOq4DMh2taQjEHGienBo8gLJn3DYuoqF4aLOcFlus1rwXXsE2U98fhyNB)YbofjVUeOewsuHdjDcchfcJQize4T1buEVzeoCa1eL9evcpJ6MndHJieIkfLAuBb2Z7nZWvEp3bK0qPMCUwGzZ843BQrTfypV3mdx59ChqsdLaut8cbXtq4OqyufPUaooJwCw2lui8oZd7jQeEg1nBMh)EtDbCCgT4SSxOq4DMh2taQjEHGienBo8gLJn3DYuoqF4aLOcFlus1rwXXYRdiE2UDU9lh4uK86sGsyjrfoK0jiCuimQIKrG3whq59Mr4Wbutu2tuj8mQB2meoIqiQuuQrTfypV3mdx59ChqsdLAY5AbMnZJFVPg1wG98EZmCL3ZDajnucqnXleepbHJcHrvK6c44mAXzzVqHW7mpSNOs4zu3SzE87n1fWXz0IZYEHcH3zEypbOM4fcIq0S5WBuo2C3jt5a9HduIk8TqjvhzfhlXru2dQH42VCGtrYRlbkHLev4qsNGWrHWOksgbEBDaL3BgHdhqnrzprLWZOUzZWPi51LaLWsaQjEHmLZzharZMdVr5yZDNmLZzhmqjQW3cLuDKvCSehrzpOg3L0ioWx1XuGClM6z12GJhs4BL7eKUI42VC6BK8wBzsqja1eVq2W5Wbkrf(wOKQJSIJL4ik7b14UKgXbSHcGJcQNHC3(U5(YyC7xo9nsERTmjOeGAIxiB4C4jiO2L1xdQecV12k71LaLWsaQjEHSHZzhy2C4nkhBU7KPC9aioqjQW3cLuDKvCSehrzpOg3L0ioiyoKeidjvBldiMR42VC6BK8wBzsqja1eVq2W5WtqqTlRVgujeERTv2RlbkHLaut8czdNZoWS5WBuo2C3jt56bqCGsuHVfkP6iR4yjoIYEqnUlPrCeUK4o8nOkYLGhodhXTF503i5T2YKGsaQjEHSHZHNGGAxwFnOsi8wBRSxxcuclbOM4fYgoNDGzZH3OCS5UtMY1dG4aLOcFlus1rwXXsCeL9GACxsJ4eENqXcAz12PZl3(LtFJK3AltckbOM4fYgohEccQDz91GkHWBTTYEDjqjSeGAIxiB4C2bMnhEJYXM7ozkxpaIduIk8TqjvhzfhlXru2dQXDjnIdKUWY7nJIf0qC7xo9nsERTmjOeGAIxiB4C4jiO2L1xdQecV12k71LaLWsaQjEHSHZzhy2C4nkhBU7KPC9aioqnqz75XW5f4S57eYnwuF(yNFHhEZTyA(agnposmsZV355f1XDGCJ574aVmoVfLfdh(8wyDjqjme3ZlvFE4acsQI5vcC4EzCEd8a28CjCTO(CKgOev4BHsgxeo8SxxcucJdq8kV381be3(LdAXzzemb05C4PJ4XV3eVOoUdKBKWHFIh)EtnQTa759Mz4kVN7asAOeo8t843BYiWBRdO8EZiC4aQjk7juiQJnLd0hmqjQW3cLmUiC4zVUeOeMvCSubtwuMFzb3(Ldp(9M4f1XDGCJeo8bkrf(wOKXfHdp71LaLWSIJLkyYIY8ll42VCqlolJGjGUnC4I0zwaE87n1O2cSN3BMHR8EUdiPHs4WhOev4BHsgxeo8SxxcucZkowQGjlkZVSGB)Y5i1US(AqLuBDzIrGeuch(aLOcFluY4IWHN96sGsywXXsfmzrz(LfC7xokbf5WBKPWPi51LaLWsaQjEHobNIKxxcuclbOM4fYuLGIC4nYkJQ(aLOcFluY4IWHN96sGsywXXs1wxMyeibXTF5WJFVjErDChi3i1xdQt843BQrTfypV3mdx59ChqsdLWHFcT4SmcMa62Wb6exhOev4BHsgxeo8SxxcucZkowQ26YeJajiU9lhE87nXlQJ7a5gP(AqD6iE87n1O2cSN3BMHR8EUdiPHs4Wpbb0IZYiycOBdNZswqZMvWeGrcLVarf(wcZgOtwKtOfNLrWeq3goqN4kehOev4BHsgxeo8SxxcucZkowQ26YeJajiU9lh4uK86sGsyja1eVqME4aLOcFluY4IWHN96sGsywXXs1wxMyeibXTF5OGjaJeYgOhOev4BHsgxeo8SxxcucZkowIwCw(6aAGsuHVfkzCr4WZEDjqjmR4yjcM0xd4Xb1aLOcFluY4IWHN96sGsywXXsVuErajObQbkrf(wOembYvXrT1LjgbsqC7xo843BIxuh3bYns91G6eAXzzemb0THd0NqlolJGjGUPC4Ibkrf(wOembYvzfhl9wBzsqC7xoHWOksEfeOewwTnECu4BLOs4zu)eGAIxit74aj8TSfhKo0S5JcHrvK8kiqjSSAB84OW3krLWZO(jaDbecMWZObkrf(wOembYvzfhlvWKfL5xwWTF5OeuKdVrMctGCvza1eVqduIk8TqjycKRYkowIwCw(6aAGsuHVfkbtGCvwXXsemPVgWJdkU9lhrfoKuMkQ5eYuUA28rHWOksxhqzP6zEG3qXwuIkHNr9bkrf(wOembYvzfhl9s5fbKG42VCuckYH3itHjqUQmGAIxingcoP0wF25Bl1Ho0A]] )


end
