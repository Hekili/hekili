-- WarlockDestruction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


-- Conduits
-- [-] ashen_remains
-- [x] combusting_engine
-- [-] duplicitous_havoc
-- [-] infernal_brand


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 267, true )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        infernal = {
            aura = "infernal",

            last = function ()
                local app = state.buff.infernal.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = 0.1
        },

        chaos_shards = {
            aura = "chaos_shards",

            last = function ()
                local app = state.buff.chaos_shards.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = 0.2,
        },

        immolate = {
            aura = "immolate",
            debuff = true,

            last = function ()
                local app = state.debuff.immolate.applied
                local t = state.query_time
                local tick = state.debuff.immolate.tick_time

                return app + floor( ( t - app ) / tick ) * tick
            end,

            interval = function () return state.debuff.immolate.tick_time end,
            value = 0.1
        },

        blasphemy = {
            aura = "blasphemy",

            last = function ()
                local app = state.buff.blasphemy.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
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

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.Mana )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shards" and amt > 0 then
            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_infernal", amt * 1.5 )
            end

            if set_bonus.tier28_2pc > 0 then
                addStack( "impending_ruin", nil, amt )

                if buff.impending_ruin.stack > 9 then
                    applyBuff( "ritual_of_ruin" )
                    removeBuff( "impending_ruin" )
                end
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
        howl_of_terror = 23465, -- 5484

        roaring_blaze = 23155, -- 205184
        rain_of_chaos = 23156, -- 266086
        grimoire_of_sacrifice = 19295, -- 108503

        soul_conduit = 19284, -- 215941
        channel_demonfire = 23144, -- 196447
        dark_soul_instability = 23092, -- 113858
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        amplify_curse = 3504, -- 328774
        bane_of_fragility = 3502, -- 199954
        bane_of_havoc = 164, -- 200546
        bonds_of_fel = 5401, -- 353753
        casting_circle = 3510, -- 221703
        cremation = 159, -- 212282
        demon_armor = 3741, -- 285933
        essence_drain = 3509, -- 221711
        fel_fissure = 157, -- 200586
        gateway_mastery = 5382, -- 248855
        nether_ward = 3508, -- 212295
        shadow_rift = 5393, -- 353294
    } )


    -- Auras
    spec:RegisterAuras( {
        active_havoc = {
            duration = function () return level > 53 and 12 or 10 end,
            max_stack = 1,

            generate = function( ah )
                if pvptalent.bane_of_havoc.enabled and debuff.bane_of_havoc.up and query_time - last_havoc < ah.duration then
                    ah.count = 1
                    ah.applied = last_havoc
                    ah.expires = last_havoc + ah.duration
                    ah.caster = "player"
                    return
                elseif not pvptalent.bane_of_havoc.enabled and active_dot.havoc > 0 and query_time - last_havoc < ah.duration then
                    ah.count = 1
                    ah.applied = last_havoc
                    ah.expires = last_havoc + ah.duration
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
            max_stack = 2,
        },
        -- Going to need to keep an eye on this.  active_dot.bane_of_havoc won't work due to no SPELL_AURA_APPLIED event.
        bane_of_havoc = {
            id = 200548,
            duration = function () return level > 53 and 12 or 10 end,
            max_stack = 1,
            generate = function( boh )
                boh.applied = action.bane_of_havoc.lastCast
                boh.expires = boh.applied > 0 and ( boh.applied + boh.duration ) or 0
            end,
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
            duration = 8,
            type = "Magic",
            max_stack = 1,
            copy = "roaring_blaze"
        },
        corruption = {
            id = 146739,
            duration = 14,
            type = "Magic",
            max_stack = 1,
        },
        curse_of_exhaustion = {
            id = 334275,
            duration = 8,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_tongues = {
            id = 1714,
            duration = 60,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_weakness = {
            id = 702,
            duration = 120,
            type = "Curse",
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
            type = "Magic",
            max_stack = 1,
            copy = "dark_soul"
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
            duration = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            tick_time = function () return haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
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
        fel_domination = {
            id = 333889,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        grimoire_of_sacrifice = {
            id = 196099,
            duration = 3600,
            max_stack = 1,
        },
        havoc = {
            id = 80240,
            duration = function () return level > 53 and 12 or 10 end,
            type = "Curse",
            max_stack = 1,
        },
        howl_of_terror = {
            id = 5484,
            duration = 20,
            type = "Magic",
            max_stack = 1,
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
        rain_of_chaos = {
            id = 266087,
            duration = 30,
            max_stack = 1
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
        soulstone = {
            id = 20707,
            duration = 900,
            max_stack = 1,
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364433, "tier28_4pc", 363950 )
    -- 2-Set - Ritual of Ruin - Every 10 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have no cast time.
    -- 4-Set - Avatar of Destruction - When Chaos Bolt or Rain of Fire consumes a charge of Ritual of Ruin, you summon a Blasphemy for 8 sec.

    spec:RegisterAuras( {
        impending_ruin = {
            id = 364348,
            duration = 3600,
            max_stack = 10
        },
        ritual_of_ruin = {
            id = 364349,
            duration = 3600,
            max_stack = 1,
        },
        blasphemy = {
            id = 367680,
            duration = 8,
            max_stack = 1,
        },
    })


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


    local lastTarget

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and destGUID ~= nil and destGUID ~= "" then
            lastTarget = destGUID
        end
    end, false )


    local SUMMON_DEMON_TEXT

    spec:RegisterHook( "reset_precast", function ()
        last_havoc = nil
        soul_shards.actual = nil

        class.abilities.summon_pet = class.abilities[ settings.default_pet ]

        if not SUMMON_DEMON_TEXT then
            SUMMON_DEMON_TEXT = GetSpellInfo( 180284 )
            class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. ( SUMMON_DEMON_TEXT or "Summon Demon" ) .. "]|r"
        end

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

        if ( debuff.havoc.up or FindUnitDebuffByID( "target", 80240, "PLAYER" ) ) and not legendary.odr_shawl_of_the_ymirjar.enabled then
            return "cycle"
        end
    end )


    local Glyphed = IsSpellKnownOrOverridesKnown

    -- Fel Imp          58959
    spec:RegisterPet( "imp",
        function() return Glyphed( 112866 ) and 58959 or 416 end,
        "summon_imp",
        3600 )

    -- Voidlord         58960
    spec:RegisterPet( "voidwalker",
        function() return Glyphed( 112867 ) and 58960 or 1860 end,
        "summon_voidwalker",
        3600 )

    -- Observer         58964
    spec:RegisterPet( "felhunter",
        function() return Glyphed( 112869 ) and 58964 or 417 end,
        "summon_felhunter",
        3600 )

    -- Fel Succubus     120526
    -- Shadow Succubus  120527
    -- Shivarra         58963
    spec:RegisterPet( "sayaad",
        function()
            if Glyphed( 240263 ) then return 120526
            elseif Glyphed( 240266 ) then return 120527
            elseif Glyphed( 112868 ) then return 58963
            elseif Glyphed( 365349 ) then return 184600
            end
            return 1863
        end,
        "summon_sayaad",
        3600,
        "incubus", "succubus" )

    -- Wrathguard       58965
    spec:RegisterPet( "felguard",
        function() return Glyphed( 112870 ) and 58965 or 17252 end,
        "summon_felguard",
        3600 )


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

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,

            talent = "cataclysm",

            handler = function ()
                applyDebuff( "target", "immolate" )
                active_dot.immolate = max( active_dot.immolate, true_active_enemies )
                removeDebuff( "target", "combusting_engine" )
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
        },


        chaos_bolt = {
            id = 116858,
            cast = function () return buff.ritual_of_ruin.up and 0 or ( buff.backdraft.up and 0.7 or 1 ) * ( buff.madness_of_the_azjaqir.up and 0.8 or 1 ) * 3 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.ritual_of_ruin.up and 0 or 2 end,
            spendType = "soul_shards",

            startsCombat = true,

            cycle = function () return talent.eradication.enabled and "eradication" or nil end,

            velocity = 16,

            handler = function ()
                if talent.eradication.enabled then
                    applyDebuff( "target", "eradication" )
                    active_dot.eradication = max( active_dot.eradication, active_dot.bane_of_havoc )
                end
                if talent.internal_combustion.enabled and debuff.immolate.up then
                    if debuff.immolate.remains <= 5 then removeDebuff( "target", "immolate" )
                    else debuff.immolate.expires = debuff.immolate.expires - 5 end
                end
                if legendary.madness_of_the_azjaqir.enabled then
                    applyBuff( "madness_of_the_azjaqir" )
                end
                if buff.ritual_of_ruin.up then
                    removeBuff( "ritual_of_ruin" )
                    if set_bonus.tier28_4pc > 0 then applyBuff( "blasphemy" ) end
                else
                    removeStack( "backdraft" )
                end
                removeStack( "crashing_chaos" )
            end,

            auras = {
                madness_of_the_azjaqir = {
                    id = 337170,
                    duration = 3,
                    max_stack = 1
                }
            }
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
            charges = function () return legendary.cinders_of_the_azjaqir.enabled and 3 or 2 end,
            cooldown = function () return ( legendary.cinders_of_the_azjaqir.enabled and 10 or 13 ) * haste end,
            recharge = function () return ( legendary.cinders_of_the_azjaqir.enabled and 10 or 13 ) * haste end,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,

            cycle = function () return talent.roaring_blaze.enabled and "conflagrate" or nil end,

            handler = function ()
                gain( 0.5, "soul_shards" )
                applyBuff( "backdraft", nil, talent.flashover.enabled and 2 or 1 )

                if talent.roaring_blaze.enabled then
                    applyDebuff( "target", "conflagrate" )
                    active_dot.conflagrate = max( active_dot.conflagrate, active_dot.bane_of_havoc )
                end

                if conduit.combusting_engine.enabled then
                    applyDebuff( "target", "combusting_engine" )
                end
            end,

            auras = {
                -- Conduit
                combusting_engine = {
                    id = 339986,
                    duration = 30,
                    max_stack = 1
                }
            }
        },


        corruption = {
            id = 172,
            cast = 1.885,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136118,

            handler = function ()
                applyDebuff( "target", "corruption" )
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


        curse_of_exhaustion = {
            id = 334275,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136162,

            handler = function ()
                applyDebuff( "target", "curse_of_exhaustion" )
                removeDebuff( "target", "curse_of_tongues" )
                removeDebuff( "target", "curse_of_weakness" )
            end,
        },


        curse_of_tongues = {
            id = 1714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136140,

            handler = function ()
                removeDebuff( "target", "curse_of_exhaustion" )
                applyDebuff( "target", "curse_of_tongues" )
                removeDebuff( "target", "curse_of_weakness" )
            end,
        },


        curse_of_weakness = {
            id = 702,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136138,

            handler = function ()
                removeDebuff( "target", "curse_of_exhaustion" )
                removeDebuff( "target", "curse_of_tongues" )
                applyDebuff( "target", "curse_of_weakness" )
            end,
        },




        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            defensive = true,

            startsCombat = true,

            talent = "dark_pact",

            usable = function () return health.pct > 20, "insufficient health" end,
            handler = function ()
                applyBuff( "dark_pact" )
                spend( 0.2 * health.max, "health" )
            end,
        },


        dark_soul_instability = {
            id = 113858,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,

            talent = "dark_soul_instability",

            handler = function ()
                applyBuff( "dark_soul_instability" )
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
            cast = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return debuff.soul_rot.up and 0 or 0.03 end,
            spendType = "mana",

            startsCombat = true,

            start = function ()
                applyDebuff( "target", "drain_life" )
            end,

            finish = function ()
                if conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
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
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
                applyDebuff( "target", "fear" )
            end,
        },


        fel_domination = {
            id = 333889,
            cast = 0,
            cooldown = function () return 180 + conduit.fel_celerity.mod * 0.001 end,
            gcd = "spell",

            startsCombat = true,
            texture = 237564,

            essential = true,
            nomounted = true,
            nobuff = "grimoire_of_sacrifice",

            handler = function ()
                applyBuff( "fel_domination" )
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
            texture = 460695,

            indicator = function () return active_enemies > 1 and ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
            cycle = "havoc",

            bind = "bane_of_havoc",

            usable = function () return not pvptalent.bane_of_havoc.enabled and active_enemies > 1, "requires multiple targets and no bane_of_havoc" end,
            handler = function ()
                if class.abilities.havoc.indicator == "cycle" then
                    active_dot.havoc = active_dot.havoc + 1
                    if legendary.odr_shawl_of_the_ymirjar.enabled then active_dot.odr_shawl_of_the_ymirjar = 1 end
                else
                    applyDebuff( "target", "havoc" )
                    if legendary.odr_shawl_of_the_ymirjar.enabled then applyDebuff( "target", "odr_shawl_of_the_ymirjar" ) end
                end
                applyBuff( "active_havoc" )
            end,

            copy = "real_havoc",

            auras = {
                odr_shawl_of_the_ymirjar = {
                    id = 337164,
                    duration = function () return class.auras.havoc.duration end,
                    max_stack = 1
                }
            }
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
            usable = function () return active_enemies > 1, "requires multiple targets" end,

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
            texture = 136168,

            usable = function () return pet.active and pet.alive and pet.health_pct < 100, "requires pet" end,
            start = function ()
                applyBuff( "health_funnel" )
            end,
        },


        howl_of_terror = {
            id = 5484,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            startsCombat = true,
            texture = 607852,

            talent = "howl_of_terror",

            handler = function ()
                applyDebuff( "target", "howl_of_terror" )
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
                removeDebuff( "target", "combusting_engine" )
            end,
        },


        incinerate = {
            id = 29722,
            cast = function ()
                if buff.chaotic_inferno.up then return 0 end
                return ( buff.backdraft.up and 0.7 or 1 ) * 2 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            velocity = 25,

            handler = function ()
                removeBuff( "chaotic_inferno" )
                removeStack( "backdraft" )
                removeStack( "decimating_bolt" )

                -- Using true_active_enemies for resource predictions' sake.
                gain( ( 0.2 + ( talent.fire_and_brimstone.enabled and ( ( true_active_enemies - 1 ) * 0.1 ) or 0 ) ) * ( legendary.embers_of_the_diabolic_raiment.enabled and 2 or 1 ), "soul_shards" )
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
            texture = 607853,

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

            spend = function () return buff.ritual_of_ruin.up and 0 or 3 end,
            spendType = "soul_shards",

            startsCombat = true,

            handler = function ()
                if buff.ritual_of_ruin.up then
                    removeBuff( "ritual_of_ruin" )
                    if set_bonus.tier28_4pc > 0 then applyBuff( "blasphemy" ) end
                end
            end,
        },


        --[[ ritual_of_doom = {
            id = 342601,
            cast = 0,
            cooldown = 3600,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 538538,

            handler = function ()
            end,
        },


        ritual_of_summoning = {
            id = 698,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136223,

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

            spend = 1,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 136191,

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

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 607865,

            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },


        singe_magic = {
            id = 132411,
            known = function () return IsSpellKnownOrOverridesKnown( 132411 ) or IsSpellKnownOrOverridesKnown( 119905 ) end,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,

            buff = "dispellable_magic",
            usable = function ()
                return pet.imp.alive or buff.grimoire_of_sacrifice.up, "requires imp or grimoire_of_sacrifice"
            end,
            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },


        soul_fire = {
            id = 6353,
            cast = function () return 4 * haste end,
            cooldown = 20,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            talent = "soul_fire",

            handler = function ()
                gain( 0.4, "soul_shards" )
                applyDebuff( "target", "immolate" )
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


        subjugate_demon = {
            id = 1098,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136154,

            usable = function () return target.is_demon and target.level < level + 2, "requires demon target" end,
            handler = function ()
                summonPet( "controlled_demon" )
            end,
        },


        summon_pet = {
            name = "|T136082:0|t |cff00ccff[Summon Demon]|r",
            bind = function () return settings.default_pet end
        },


        summon_felhunter = {
            id = 691,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            essential = true,

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function ()
                summonPet( "felhunter" )
                removeBuff( "fel_domination" )
            end,

            copy = 112869,

            bind = function ()
                if settings.default_pet == "summon_felhunter" then return "summon_pet" end
            end,
        },


        summon_imp = {
            id = 688,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            essential = true,
            nomounted = true,

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function ()
                summonPet( "imp" )
                removeBuff( "fel_domination" )
            end,

            bind = function ()
                if settings.default_pet == "summon_imp" then return "summon_pet" end
            end,
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
                if talent.rain_of_chaos.enabled then applyBuff( "rain_of_chaos" ) end
                if azerite.crashing_chaos.enabled then applyBuff( "crashing_chaos", 3600, 8 ) end
            end,
        },


        summon_sayaad = {
            id = 366222,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "sayaad" ) end,

            copy = { 365349, "summon_incubus", "summon_succubus" },

            bind = function()
                if settings.default_pet == "summon_sayaad" then return { 365349, "summon_incubus", "summon_succubus", "summon_pet" } end
                return { 365349, "summon_incubus", "summon_succubus" }
            end,
        },


        summon_voidwalker = {
            id = 697,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 136221,

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function ()
                summonPet( "voidwalker" )
                removeBuff( "fel_domination" )
            end,

            bind = function ()
                if settings.default_pet == "summon_voidwalker" then return "summon_pet" end
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

        potion = "spectral_intellect",

        package = "Destruction",
    } )


    spec:RegisterSetting( "default_pet", "summon_sayaad", {
        name = "Preferred Demon",
        desc = "Specify which demon should be summoned if you have no active pet.",
        type = "select",
        values = function()
            return {
                summon_sayaad = class.abilityList.summon_sayaad,
                summon_imp = class.abilityList.summon_imp,
                summon_felhunter = class.abilityList.summon_felhunter,
                summon_voidwalker = class.abilityList.summon_voidwalker,

            }
        end
    } )


    spec:RegisterSetting( "havoc_macro_text", nil, {
        name = "When |T460695:0|t Havoc is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast Havoc on a different target (without swapping).  A mouseover macro is useful for this and an example is included below.",
        type = "description",
        width = "full",
        fontSize = "medium"
    } )

    spec:RegisterSetting( "havoc_macro", nil, {
        name = "|T460695:0|t Havoc Macro",
        type = "input",
        width = "full",
        multiline = 2,
        get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.havoc.name end,
        set = function () end,
    } )

    spec:RegisterSetting( "immolate_macro_text", nil, {
        name = function () return "When |T" .. GetSpellTexture( 348 ) .. ":0|t Immolate is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast Immolate on a different target (without swapping).  A mouseover macro is useful for this and an example is included below." end,
        type = "description",
        width = "full",
        fontSize = "medium"
    } )

    spec:RegisterSetting( "immolate_macro", nil, {
        name = function () return "|T" .. GetSpellTexture( 348 ) .. ":0|t Immolate Macro" end,
        type = "input",
        width = "full",
        multiline = 2,
        get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.immolate.name end,
        set = function () end,
    } )


    spec:RegisterPack( "Destruction", 20220513, [[dS0gZaqikj9ikvPnPu6tusyueqDkciRskL6vaQzrGUfbvTlL8laAyeehdalJq1ZOuvtJG01uHSnvOY3uHQghbLohbvADeuX8OK6EQO9jLQdkLsAHaYdPufnrkjIlkLc2ibf0hjOaDsPuOvsPmtPuIBsqrStPKFsqHSuckGNkyQkfBLGc1xPKinwkjQ9k5VcnyP6WOwmOESQMSkDzKnd0NvbJwP60uTAcksVwfkZMOBdYUf9BfdNsCCkvHLd55qnDsxxk2oH8DcW4LsrNNsL1tqrnFcL9tXfa1MkCzLQwIleXfxihbWrlHieXb4iHwb1olufSW)X4dufsgIQGvcHvuZR(KvWcBNC4BTPc4Pb9uf2v1cw4aiGhCDVbE9deGyhQrYQp5JyqfqSd9awb4gxQTXSGRWLvQAjUqexCHCeahTeIqehGJSFf4gDFqvi4q2ZkS73lLfCfUe(RGvcHvuZR(KMUvkJKZFmJnHjSDMoa2xqtxCHiU4gBgB2ZDopqyHJXMWB6cdLeE)rmOcOW4rYQljtpmsruQM(Z5tYOdA6)oNhORPRJP7PsiuJfn6GlJnH30BRIg)A6ylmeKNhm92ie0izLwvq6yfxBQWolA(At1cGAtfOKHL0TaQcpYvc5CfGBabxW8FSlIb11DeqA6BnD80iJ4DgDn92pnDam9TMoEAKr8oJUMU1NMUqRa)Qpzf(jbL8beRuPvlXRnvGsgws3cOk8ixjKZv4zSgvhImDRn9Dw08rebXEIRa)QpzfWtJmc6iQ0QL9RnvGsgws3cOk8ixjKZv4zSgvhImDRn9Dw08rebXEIn9TMoEAKWEExsIVry7IuBYqwK0Isgws3kWV6twHl9oeREEicpsT0QLqRnvGsgws3cOk8ixjKZv4zSgvhImDRn9Dw08rebXEIRa)QpzfW)0G88quDDNkTADuTPcuYWs6wavHh5kHCUcklPuxEQekzz8hi4gS6tUOKHL0103A6icI9eB6wB63geR(KMEBB6czDKPlMyMUvnDLLuQlpvcLSm(deCdw9jxuYWs6A6BnDebIi8odlPkWV6twbhcAKSsLwToUAtfOKHL0TaQcpYvc5CfEgRr1Hit3AtFNfnFerqSNytFRPBvtxGnDmPr4jBWl1jK4cBuOwEtFRPZV6IOiLeKtytVDthatFRPRSKsD5jiHYzrjdlPRPlqvGF1NSc)op4i8i1sRwhFTPcuYWs6wavHh5kHCUcysJWt2GxQtiXf2OqT8M(wtNF1frrkjiNWME7MoaM(wtxzjL6YtqcLZIsgws3kWV6twbe7zCaJGoIkTAjS1MkWV6twb8oFhba3GYkqjdlPBbuPvlHBTPcuYWs6wavHh5kHCUcpJ1O6qKPBTPVZIMpIii2tCf4x9jRGNVNeIvQ0sRGfe9demR1MQfa1MkqjdlPBbuf4x9jRaijJ3bYtw9jRWLWpYTO(KvOn0M03O010HjWbrM(pqWSA6W0bpXltVT(pzrXMEoPWVZiiWgPPZV6tIn9jL2TQWJCLqoxb1HitVDtxiM(wt3QMUfsxS0frLwTeV2ub(vFYkGBGGMmAH0kqjdlPBbuPvl7xBQaLmSKUfqviziQc6arXbmcnjwrtdo(tIvuZR(K4kWV6twbDGO4agHMeROPbh)jXkQ5vFsCPvlHwBQaLmSKUfqviziQc4rs8ooIPhrAuPFpD7rdvb(vFYkGhjX74iMEePrL(90ThnuPvRJQnvGF1NScGscV)iguRaLmSKUfqLwToUAtfOKHL0TaQcpYvc5CfuwsPUoGCOXruCaJy(roO)0Isgws3kWV6twHdihACefhWiMFKd6pvA164RnvGsgws3cOkKmevb8oFhbq34GGJdyuheeLAf4x9jRaENVJaOBCqWXbmQdcIsT0QLWwBQa)QpzfWtJmc6iQcuYWs6wavA1s4wBQa)Qpzf889KqSsvGsgws3cOslTc8q1MQfa1MkqjdlPBbufEKReY5kyH0LNGekz5IF1frM(wtxGnDRA6)mY7iGCTZIMFHi(ANPlMyMo)QlIIusqoHn92nD7B6cuf4x9jRaI9moGrqhrLwTeV2ubkzyjDlGQWJCLqoxbmPr4jBWl1jK4cBuOw(kWV6twbe7zCaJGoIkTAz)Atf4x9jRaEAKr0OvGsgws3cOsRwcT2ub(vFYk4qwO865H4ZkJv0yzNQaLmSKUfqLwToQ2ubkzyjDlGQWJCLqoxH7OlhcAKSslebXEIn92n9NXAuDiQc8R(Kv435mjz8sqtc6iQ0Q1XvBQaLmSKUfqvGF1NScoe0izLQWJCLqoxb(vxefPKGCcB6wB6hz6BnDebXEInDRn9Jm9TMUaB6w10vwsPUEw5xAhgArjdlPRPlMyM(pJ8ocixpR8lTddTqee7j20B30ree7j20fOk829skQm6aP4QfaLwTo(AtfOKHL0TaQc8R(Kv4zPmYV6tgLowRG0XAmziQc)fxA1syRnvGsgws3cOkWV6twHDw08v4rUsiNRa)QlIIusqoHnDRnDHwH3UxsrLrhifxTaO0QLWT2ub(vFYkGypJdye0rufOKHL0TaQ0QfacP2ubkzyjDlGQa)Qpzf2zrZxH3UxsrLrhifxTaO0QfaauBQa)QpzfU07qS65Hi8i1kqjdlPBbuPvlaeV2ubkzyjDlGQWJCLqoxbLLuQlqhrroVryKdH1jPfLmSKUM(wthUbeCbZ)XUiguxnwm9TMoEAKr8oJUMU1M(rMUWB6czjUP32Mo)QlIIusqoHRa)Qpzf889KqSsLwTaW(1MkWV6twb80iJGoIQaLmSKUfqLwTaqO1MkqjdlPBbufEKReY5ka3acUG5)yxedQR7iGSc8R(Kv4NeuYhqSsLwTa4OAtfOKHL0TaQcpYvc5CfugDG01oXsDFz5vt3AtxCHub(vFYkG357ia4guwA1cGJR2ubkzyjDlGQa)QpzfCiOrYkvHh5kHCUcicer4Dgwsv4T7Luuz0bsXvlakTAbWXxBQa)QpzfW)0G88quDDNQaLmSKUfqLwTaqyRnvGF1NScE(EsiwPkqjdlPBbuPLwH)IRnvlaQnvGsgws3cOkWV6twb8oFhbq34GGJdyuheeLAfEKReY5k8ZiVJaYfUbcAYONGekz5crqSNyt3At3(MUyIz6WdgB6BnD1HOOoXRtMU1MUqfVcjdrvaVZ3ra0noi44ag1bbrPwA1s8Atf4x9jRaUbcAYONGekzzfOKHL0TaQ0QL9RnvGsgws3cOk8ixjKZvWcPlpbjuYYf)QlImDXeZ0Hhm203A6)mY7iGCHBGGMm6jiHswUqee7josTPf6v6A6TB6QdrrDIxNQa)QpzfUm6yr80iJEIvg2LUAxPvlHwBQaLmSKUfqv4rUsiNRGfsxEcsOKLl(vxevb(vFYkyzuFYsRwhvBQaLmSKUfqv4rUsiNRGfsxEcsOKLl(vxevb(vFYkatimHoMNhkTADC1MkqjdlPBbufEKReY5kyH0LNGekz5IF1frvGF1NScWYzUrWgKDLwTo(AtfOKHL0TaQcpYvc5CfSq6YtqcLSCXV6IOkWV6twbqhrWYzULwTe2AtfOKHL0TaQc8R(Kva)mchhWiiIvcLSmIvKdsv4rUsiNRGvnD4gqWf(zeooGrqeRekzzeRihKIcD1yPcjdrva)mchhWiiIvcLSmIvKdsLwTeU1MkqjdlPBbuf4x9jRa(zeooGrqeRekzzeRihKQWJCLqoxb4gqWf(zeooGrqeRekzzeRihKIcD1yX03A6wiD5jiHswU4xDrufsgIQa(zeooGrqeRekzzeRihKkTAbGqQnvGsgws3cOk8ixjKZvWcPlpbjuYYf)QlImDXeZ0Hhm203A6QdrrDIxNmDRnDXbOc8R(KvObtrxjiCPLwHlbYnsT2uTaO2ubkzyjDlGQWLWpYTO(KvOn0M03O010jreYotxDiY01DY05xhKP7ytNfXUKHL0Qc8R(KvaBHKYOC(JvA1s8AtfOKHL0TaQcpYvc5Cf2zrZh5xDrKPV105xDruKscYjSP3UPdGPV105xDruKscYjSPBTPFKPl8MUYsk1LNGekNfLmSKUMoWMUaB6klPuxEcsOCwuYWs6A6BnDLLuQlpvcLSm(deCdw9jxuYWs6A6cufWkYFTAbqf4x9jRWZszKF1NmkDSwbPJ1yYquf2zrZxA1Y(1MkqjdlPBbuf4x9jRaOKW7pIb1k8ixjKZvapnsypVlrJKvxsr8ifrPUOKHL0TcEQec1yrJoyfGBabxIgjRUKI4rkIsD1yP0QLqRnvGsgws3cOk8ixjKZvqzjL6cnmYZdryjlmtlkzyjDn9TM(LGBabxOHrEEiclzHzAHii2tSPBTPdW6OkWV6twHFsqjFaXkvA16OAtf4x9jRWZk)s7WqvGsgws3cOsRwhxTPcuYWs6wavHh5kHCUc8RUiksjb5e20B30f30fEthtAeEYg8sDcjUWgfQLVc8R(Kv4zPmYV6tgLowRG0XAmziQc8qLwTo(AtfOKHL0TaQc8R(KvapnYiOJOk8ixjKZvarGicVZWsY03A64PrgX7m6A6wFA6c103A6cSPBvtxzjL66zLFPDyOfLmSKUMUyIz6)mY7iGC9SYV0om0crqSNytVDthrqSNytxGQWB3lPOYOdKIRwauA1syRnvGsgws3cOkWV6twbhcAKSsv4rUsiNRaIGypXMU1MU9n9TMUaB6w10vwsPUEw5xAhgArjdlPRPlMyM(pJ8ocixpR8lTddTqee7j20B30ree7j20fOk829skQm6aP4QfaLwTeU1MkqjdlPBbufEKReY5kOSKsD5PsOKLXFGGBWQp5IsgwsxtFRPZV6tU(DEWr4rQlpJGs)WUA6BnDebXEInDRn9BdIvFstVTnDHSoQc8R(KvWHGgjRuPvlaesTPcuYWs6wavHh5kHCUccSPBH0LNGekz5IF1frMUyIz6wiDblzSLDcYUf)QlImDbY03A64PrgX7m6A6TFA6cTc8R(Kv435bhHhPwA1caaQnvGsgws3cOkWV6twHNLYi)Qpzu6yTcshRXKHOk8xCPvlaeV2ub(vFYk87CMKmEjOjbDevbkzyjDlGkTAbG9RnvGF1NSc4FAqEEiQUUtvGsgws3cOsRwai0Atf4x9jRWLEhIvppeHhPwbkzyjDlGkTAbWr1MkqjdlPBbuf4x9jRWolA(k8ixjKZv4o6YHGgjR0crqSNytVDt)o6YHGgjR062Gy1N00BBtxiRJmDXeZ0TQPRSKsD5PsOKLXFGGBWQp5Isgws3k829skQm6aP4QfaLwTa44QnvGF1NScoKfkVEEi(SYyfnw2PkqjdlPBbuPvlao(Atf4x9jRaEAKr0OvGsgws3cOsRwaiS1MkqjdlPBbufEKReY5kGAscCqhO1Crr8olazCaJ6ofTdYrctz0IShnUfl0Tc8R(KvyNfnFPvlaeU1MkqjdlPBbufglvatAf4x9jRGig5mSKQGiw2qvGF1frrkjiNWME7MoaM(wt)NrEhbKRDw08lebXEInDRpnDaeIPlMyMoCdi4c5AdlJdye145QXIPV10vwsPUqSNXbm(78GxuYWs6wbrmkMmevblZiJ4PrgX7m6IlTAjUqQnvGsgws3cOk8ixjKZvaUbeCbZ)XUigux3raPPV10XtJmI3z010B)00byDKPl8MUqw230BBtxzjL6cuY49reHwuYWs6A6BnDRA6IyKZWsAzzgzepnYiENrxCf4x9jRWpjOKpGyLkTAjoa1MkqjdlPBbufEKReY5kyH0LNGekz5IF1frMUyIz6WnGGle7zCaJ)op4fIGypXME7M(ZynQoevb(vFYk878GJWJulTAjU41MkqjdlPBbufEKReY5ka3acUG5)yxedQRglM(wt3QMUig5mSKwwMrgXtJmI3z0fxb(vFYk878GJWJulTAjU9RnvGsgws3cOk8ixjKZvqzjL6Iq81Fw9jxuYWs6A6BnDRA6IyKZWsAzzgzepnYiENrxSPV10VeCdi4Iq81Fw9jxicI9eB6wB6pJ1O6quf4x9jRWVZdocpsT0QL4cT2ubkzyjDlGQWJCLqoxbRA6IyKZWsAzzgzepnYiENrxSPlMyMoEAKr8oJUME7NMUqxhvb(vFYkG357ia4guwA1s8JQnvGsgws3cOk8ixjKZvapnYiENrxtVDt3(RJQa)Qpzf(DEWr4rQLwTe)4QnvGsgws3cOk8ixjKZvaEWytFRPd6h21iIGypXMU1M(rM(wtxz0bsxQdrrDIxNm92n9NXAuDiY0b20velIKr1HOkWV6twHFNhCeEKAPvlXp(AtfOKHL0TaQcpYvc5Cf(DgDGWME7MoaMUyIz6kJoq6sDikQt86KPBTPF4VvGF1NSc)KGs(aIvQ0QL4cBTPc8R(KvWZ3tcXkvbkzyjDlGkT0sRGicH9jRwIleXfxihjeaQGayu65bCfSsBRcd0Qn2syqHJPB6B2jt3HSmi10bhKPBfxcKBKQvy6iYE04i6A64bImDUrhiwPRP)7CEGWlJT2INKPBFHJPBpNueHu6A6wbEAKWEExwzRW01X0Tc80iH98USYlkzyjDTctNvtVnimQTy6cmaTPaTm2AlEsMoacxHJPBpNueHu6A6wHYsk1Lv2kmDDmDRqzjL6YkVOKHL01kmDwn92GWO2IPlWa0Mc0YyRT4jz6IBFHJPBpNueHu6A6wHYsk1Lv2kmDDmDRqzjL6YkVOKHL01kmDbgG2uGwgBgBTrildsPRPFKPZV6tA6shR4LXwfSGgqxsvWETxt3kHWkQ5vFst3kLrY5pMXM9AVMUWe2otha7lOPlUqexCJnJn71EnD75oNhiSWXyZETxtx4nDHHscV)igubuy8iz1LKPhgPikvt)58jz0bn9FNZd0101X09ujeQXIgDWLXM9AVMUWB6TvrJFnDSfgcYZdMEBecAKSslJnJn710BdTj9nkDnDycCqKP)demRMomDWt8Y0BR)twuSPNtk87mccSrA68R(KytFsPDlJn(vFs8YcI(bcM1tqsgVdKNS6tkOdEQoe1Uq2AvlKUyPlIm24x9jXlli6hiywb(eqCde0KrlKASXV6tIxwq0pqWSc8jGnyk6kbjyYq0PoquCaJqtIv00GJ)Kyf18Qpj2yJF1NeVSGOFGGzf4taBWu0vcsWKHOt8ijEhhX0JinQ0VNU9OHm24x9jXlli6hiywb(eqqjH3FedQgB8R(K4Lfe9demRaFc4bKdnoIIdyeZpYb9Ne0bpvwsPUoGCOXruCaJy(roO)0IsgwsxJn(vFs8YcI(bcMvGpbSbtrxjibtgIoX78DeaDJdcooGrDqquQgB8R(K4Lfe9demRaFciEAKrqhrgB8R(K4Lfe9demRaFcONVNeIvYyZyZEn92qBsFJsxtNeri7mD1Hitx3jtNFDqMUJnDwe7sgwslJn(vFs8j2cjLr58hZyJF1NeF(Sug5x9jJshRcMmeDUZIMxqSI8xpbqqh8CNfnFKF1frB5xDruKscYjC7aSLF1frrkjiNWwFKWRSKsD5jiHYzrjdlPlWcSYsk1LNGekNfLmSKUBvwsPU8ujuYY4pqWny1NCrjdlPRazSXV6tIb(eqqjH3FedQc6GN4Prc75DjAKS6skIhPikvb9ujeQXIgDWt4gqWLOrYQlPiEKIOuxnwm24x9jXaFc4pjOKpGyLe0bpvwsPUqdJ88qewYcZ0Isgws3TxcUbeCHgg55HiSKfMPfIGypXwdW6iJn(vFsmWNa(SYV0omKXg)Qpjg4taFwkJ8R(KrPJvbtgIo5He0bp5xDruKscYjC7Il8ysJWt2GxQtiXf2OqT8gB8R(KyGpbepnYiOJibF7EjfvgDGu8jac6GNicer4DgwsBXtJmI3z016tHUvGTQYsk11Zk)s7WqlkzyjDftSFg5DeqUEw5xAhgAHii2tC7icI9elqgB8R(KyGpb0HGgjRKGVDVKIkJoqk(eabDWtebXEIT2(BfyRQSKsD9SYV0om0IsgwsxXe7NrEhbKRNv(L2HHwicI9e3oIGypXcKXg)Qpjg4taDiOrYkjOdEQSKsD5PsOKLXFGGBWQp5Isgws3T8R(KRFNhCeEK6YZiO0pSRBree7j26BdIvFY2wiRJm24x9jXaFc4VZdocpsvqh8uGTq6YtqcLSCXV6IiXeZcPlyjJTStq2T4xDrKaTfpnYiENr32pfQXg)Qpjg4taFwkJ8R(KrPJvbtgIo)l2yJF1Ned8jG)oNjjJxcAsqhrgB8R(KyGpbe)tdYZdr11DYyJF1Ned8jGx6Diw98qeEKQXg)Qpjg4ta3zrZl4B3lPOYOdKIpbqqh88o6YHGgjR0crqSN42VJUCiOrYkTUniw9jBBHSosmXSQYsk1LNkHswg)bcUbR(KlkzyjDn24x9jXaFcOdzHYRNhIpRmwrJLDYyJF1Ned8jG4PrgrJASXV6tIb(eWDw08c6GNOMKah0bAnxueVZcqghWOUtr7GCKWugTi7rJBXcDn24x9jXaFcOig5mSKemzi60YmYiEAKr8oJUybfXYg6KF1frrkjiNWTdW2Fg5DeqU2zrZVqee7j26taeIyIb3acUqU2WY4agrnEUASSvzjL6cXEghW4VZd2yJF1Ned8jG)KGs(aIvsqh8eUbeCbZ)XUigux3ra5w80iJ4DgDB)eG1rcVqw2VTvwsPUaLmEFerOfLmSKUBTQig5mSKwwMrgXtJmI3z0fBSXV6tIb(eWFNhCeEKQGo4PfsxEcsOKLl(vxejMyWnGGle7zCaJ)op4fIGypXT)mwJQdrgB8R(KyGpb835bhHhPkOdEc3acUG5)yxedQRglBTQig5mSKwwMrgXtJmI3z0fBSXV6tIb(eWFNhCeEKQGo4PYsk1fH4R)S6tU1QIyKZWsAzzgzepnYiENrx82lb3acUieF9NvFYfIGypXw)mwJQdrgB8R(KyGpbeVZ3raWnOuqh80QIyKZWsAzzgzepnYiENrxSyIHNgzeVZOB7NcDDKXg)Qpjg4ta)DEWr4rQc6GN4PrgX7m62U9xhzSXV6tIb(eWFNhCeEKQGo4j8GXBb9d7AerqSNyRpARYOdKUuhII6eVo1(ZynQoebSIyrKmQoezSXV6tIb(eWFsqjFaXkjOdE(7m6aHBhaXetz0bsxQdrrDIxNS(WFn24x9jXaFcONVNeIvYyZyJF1NeV4HorSNXbmc6isqh80cPlpbjuYYf)QlI2kWw9NrEhbKRDw08leXx7etm(vxefPKGCc3U9fiJn(vFs8Ihc4tarSNXbmc6isqh8etAeEYg8sDcjUWgfQL3yJF1NeV4Ha(eq80iJOrn24x9jXlEiGpb0HSq51ZdXNvgROXYozSXV6tIx8qaFc4VZzsY4LGMe0rKGo45D0LdbnswPfIGypXT)mwJQdrgB8R(K4fpeWNa6qqJKvsW3UxsrLrhifFcGGo4j)QlIIusqoHT(OTicI9eB9rBfyRQSKsD9SYV0om0IsgwsxXe7NrEhbKRNv(L2HHwicI9e3oIGypXcKXg)QpjEXdb8jGplLr(vFYO0XQGjdrN)fBSXV6tIx8qaFc4olAEbF7EjfvgDGu8jac6GN8RUiksjb5e2AHASXV6tIx8qaFciI9moGrqhrgB8R(K4fpeWNaUZIMxW3UxsrLrhifFcGXg)QpjEXdb8jGx6Diw98qeEKQXg)QpjEXdb8jGE(EsiwjbDWtLLuQlqhrroVryKdH1jPfLmSKUBHBabxW8FSlIb1vJLT4PrgX7m6A9rcVqwI328RUiksjb5e2yJF1NeV4Ha(eq80iJGoIm24x9jXlEiGpb8NeuYhqSsc6GNWnGGly(p2fXG66ocin24x9jXlEiGpbeVZ3raWnOuqh8uz0bsx7el19LLxTwCHySXV6tIx8qaFcOdbnswjbF7EjfvgDGu8jac6GNicer4DgwsgB8R(K4fpeWNaI)Pb55HO66ozSXV6tIx8qaFcONVNeIvYyZyJF1NeV(l(SbtrxjibtgIoX78DeaDJdcooGrDqquQc6GN)mY7iGCHBGGMm6jiHswUqee7j2A7lMyWdgVvDikQt86K1cvCJn(vFs86VyGpbe3abnz0tqcLS0yJF1NeV(lg4taVm6yr80iJEIvg2LUANGo4PfsxEcsOKLl(vxejMyWdgV9NrEhbKlCde0KrpbjuYYfIGypXrQnTqVs32vhII6eVozSXV6tIx)fd8jGwg1Nuqh80cPlpbjuYYf)QlIm24x9jXR)Ib(eqycHj0X88GGo4PfsxEcsOKLl(vxezSXV6tIx)fd8jGWYzUrWgKDc6GNwiD5jiHswU4xDrKXg)QpjE9xmWNac6icwoZvqh80cPlpbjuYYf)QlIm24x9jXR)Ib(eWgmfDLGemzi6e)mchhWiiIvcLSmIvKdsc6GNwfUbeCHFgHJdyeeXkHswgXkYbPOqxnwm24x9jXR)Ib(eWgmfDLGemzi6e)mchhWiiIvcLSmIvKdsc6GNWnGGl8ZiCCaJGiwjuYYiwroiff6QXYwlKU8eKqjlx8RUiYyJF1NeV(lg4taBWu0vcclOdEAH0LNGekz5IF1frIjg8GXBvhII6eVozT4aySzSXV6tIx7SO5p)jbL8beRKGo4jCdi4cM)JDrmOUUJaYT4PrgX7m62(jaBXtJmI3z016tHASXV6tIx7SO5b(eq80iJGoIe0bpFgRr1HiR3zrZhree7j2yJF1NeV2zrZd8jGx6Diw98qeEKQGo45ZynQoez9olA(iIGypXBXtJe2Z7ss8ncBxKAtgYIKwuYWs6ASXV6tIx7SO5b(eq8pnippevx3jbDWZNXAuDiY6Dw08rebXEIn24x9jXRDw08aFcOdbnswjbDWtLLuQlpvcLSm(deCdw9jxuYWs6UfrqSNyRVniw9jBBHSosmXSQYsk1LNkHswg)bcUbR(KlkzyjD3IiqeH3zyjzSXV6tIx7SO5b(eWFNhCeEKQGo45ZynQoez9olA(iIGypXBTQaJjncpzdEPoHexyJc1YVLF1frrkjiNWTdWwLLuQlpbjuolkzyjDfiJn(vFs8ANfnpWNaIypJdye0rKGo4jM0i8Kn4L6esCHnkul)w(vxefPKGCc3oaBvwsPU8eKq5SOKHL01yJF1NeV2zrZd8jG4D(ocaUbLgB8R(K41olAEGpb0Z3tcXkjOdE(mwJQdrwVZIMpIii2tCfWwOVAj(XD8LwAva]] )


end
