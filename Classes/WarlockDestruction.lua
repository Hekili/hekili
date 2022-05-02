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
    end )


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


    spec:RegisterPack( "Destruction", 20220501, [[dOKfXaqikv8ikrAteHprjWOis0PisyvkfQxbiZcqDlkr1UuYVurnmIOoMkYYOK8mLcMgLqxdGABuIY3aizCejvNJijTokbzEusDpvyFkfDqIKYcbWdPertKsLKlsjcBeGu5JuQKQtQuiTskLzQui2PuYpbivTukvs5PcMQuQTcqk(krs0yPeu7v0FfAWs1HrTyq9yvnzv6YiBgKpRuA0kvNMQvdqk9AaIzt42aTBj)wXWjQooLkXYH8COMoPRlfBNO8DIiJNsL68uQA9ejH5tKA)uCEkBNHlRu2YkjBLvsgWs(0YkRoDYINYGAVCkdY5hq4TugkgKYGDfHvuZR(uzqoBVy4B2od4Pb9ug2vvo2cD(8wx3BGx)aEg7Gncw9PEedPNXo4FodWnUq3OvcNHlRu2YkjBLvsgWs(0YkRoDAds1mWn6(GYqWbTKzy3VxQs4mCj8Nb7kcROMx9PmDPsgjMhqm2KAYrUW0TmGnDRKSvwzSzSzj35AlHTqgBwUPdOtq49hXq6zanJGvxqMEyeYOsn9NRNerhY0)DU2sxtxht3lLqOg5A0HwgBwUPl1Kn(10XYzqqV2A6BuqWrWkTYGWXkoBNHDw28z7S1PSDgOIHf0nbidpYvc5CgGBGGwW8dixedPR7iPY0LW0XtJiI3z01038W0pz6sy64PreX7m6A6wFy6wmd8R(uz4NcsWBrSsPMTSkBNbQyybDtaYWJCLqoNHNXAuDqY0T203zzZhrei7fod8R(uzapnIiKJOuZwBiBNbQyybDtaYWJCLqoNHNXAuDqY0T203zzZhrei7f20LW0XtJa2R7sq8ncBFKSBguUGwuXWc6Mb(vFQmCP3bz1RTr4rOPMTSy2oduXWc6MaKHh5kHCodpJ1O6GKPBTPVZYMpIiq2lCg4x9PYa(NgKxBJQR7uQzlaNTZavmSGUjaz4rUsiNZGYcQ0LxkHkwe)beUbR(ulQyybDnDjmDebYEHnDRn9BdIvFktFJnDjVaSPlT0MUDmDLfuPlVucvSi(diCdw9PwuXWc6A6sy6iccr4DgwqzGF1Nkdoi4iyLsnBzzz7mqfdlOBcqgEKReY5m8mwJQdsMU1M(olB(iIazVWzGF1Nkd)op4i8i0uZwaQSDg4x9PYaENVJKGBqvgOIHf0nbi1SLupBNbQyybDtaYWJCLqoNHNXAuDqY0T203zzZhrei7fod8R(uzWR3lcXkLAQzqoI(beM1SD26u2oduXWc6MaKb(vFQmarI4Da9IvFQmCj8JC5QpvgSe2n9nkDnDycAqKP)dimRMomT1l8Y0LA)tYvSPxtz57mceQry68R(uytFkH9Rm8ixjKZzqDqY0300LSPlHPBhtxoPlw4YOuZwwLTZa)QpvgWnGGtfLtAgOIHf0nbi1S1gY2zGkgwq3eGmumiLbDaP4afbNcROPbh)PWkQ5vFkCg4x9PYGoGuCGIGtHv00GJ)uyf18Qpfo1SLfZ2zGkgwq3eGmumiLb8iiEhhX0JinQ0VxUDPHYa)QpvgWJG4DCetpI0Os)E52Lgk1SfGZ2zGF1NkdqccV)igsZavmSGUjaPMTSSSDgOIHf0nbidpYvc5CguwqLU2ICWXruCGIy(roK)0Ikgwq3mWV6tLHTihCCefhOiMFKd5pLA2cqLTZavmSGUjazOyqkd4D(osIUXbbhhOOoiqQ0mWV6tLb8oFhjr34GGJduuheivAQzlPE2od8R(uzapnIiKJOmqfdlOBcqQzlPA2od8R(uzWR3lcXkLbQyybDtasn1mWdLTZwNY2zGkgwq3eGm8ixjKZzqoPlVGiuXIf)QlJmDjmDP00TJP)ZiUJKQ1olB(fI4R9MU0sB68RUmksfb6e203003GPlfzGF1Nkdi2R4afHCeLA2YQSDg4x9PYaEAer0OzGkgwq3eGuZwBiBNb(vFQm4GYP66124ZkJv0iFNYavmSGUjaPMTSy2oduXWc6MaKHh5kHCod3rxoi4iyLwicK9cB6BA6pJ1O6Gug4x9PYWVZvrI4LaNcYruQzlaNTZavmSGUjazGF1Nkdoi4iyLYWJCLqoNb(vxgfPIaDcB6wB6a20LW0rei7f20T20bSPlHPlLMUDmDLfuPRNv(f2JbxuXWc6A6slTP)ZiUJKQ1Zk)c7XGlebYEHn9nnDebYEHnDPidV9VGIkJ2skoBDk1SLLLTZavmSGUjazGF1Nkdpler(vFQOWXAgeowJfdsz4V4uZwaQSDgOIHf0nbid8R(uzyNLnFgEKReY5mWV6YOiveOtyt3At3Iz4T)fuuz0wsXzRtPMTK6z7mWV6tLbe7vCGIqoIYavmSGUjaPMTKQz7mqfdlOBcqg4x9PYWolB(m82)ckQmAlP4S1PuZwNKC2od8R(uz4sVdYQxBJWJqZavmSGUjaPMToDkBNbQyybDtaYWJCLqoNbLfuPlihrrUUryKdI1POfvmSGUMUeMoCde0cMFa5IyiD1i30LW0XtJiI3z010T20bSPB5MUKxwz6BSPZV6YOiveOt4mWV6tLbVEVieRuQzRtwLTZa)QpvgWtJic5ikduXWc6MaKA260gY2zGkgwq3eGm8ixjKZzaUbcAbZpGCrmKUUJKQmWV6tLHFkibVfXkLA26KfZ2zGkgwq3eGm8ixjKZzqz0wsx7el09L8xnDRnDRKCg4x9PYaENVJKGBqvQzRtaoBNbQyybDtaYa)QpvgCqWrWkLHh5kHCodiccr4Dgwqz4T)fuuz0wsXzRtPMTozzz7mWV6tLb8pniV2gvx3PmqfdlOBcqQzRtaQSDg4x9PYGxVxeIvkduXWc6MaKAQz4V4SD26u2oduXWc6MaKb(vFQmG357ij6gheCCGI6GaPsZWJCLqoNHFgXDKuTWnGGtf9cIqflwicK9cB6wB6BW0LwAthEWytxctxDqkQt86KPBTPBrRYqXGugW78DKeDJdcooqrDqGuPPMTSkBNb(vFQmGBabNk6feHkwKbQyybDtasnBTHSDgOIHf0nbidpYvc5CgKt6YlicvSyXV6YitxAPnD4bJnDjm9FgXDKuTWnGGtf9cIqflwicK9chj7wo9kDn9nnD1bPOoXRtzGF1Nkdxgbir80iIEHvg2fUAFQzllMTZavmSGUjaz4rUsiNZGCsxEbrOIfl(vxgLb(vFQmiFuFQuZwaoBNbQyybDtaYWJCLqoNb5KU8cIqflw8RUmkd8R(uzaMqycbiETn1SLLLTZavmSGUjaz4rUsiNZGCsxEbrOIfl(vxgLb(vFQmalM5gHAq2NA2cqLTZavmSGUjaz4rUsiNZGCsxEbrOIfl(vxgLb(vFQma5icwmZn1SLupBNbQyybDtaYa)QpvgWpJWXbkcHyLqflIyf5qugEKReY5myhthUbcAHFgHJduecXkHkweXkYHOOfxnYZqXGugWpJWXbkcHyLqflIyf5quQzlPA2oduXWc6MaKb(vFQmGFgHJduecXkHkweXkYHOm8ixjKZzaUbcAHFgHJduecXkHkweXkYHOOfxnYnDjmD5KU8cIqflw8RUmkdfdsza)mchhOieIvcvSiIvKdrPMToj5SDgOIHf0nbidpYvc5CgKt6YlicvSyXV6YitxAPnD4bJnDjmD1bPOoXRtMU1MUvNYa)QpvgAWu0vceNAQz4sqCJqZ2zRtz7mqfdlOBcqgUe(rUC1Nkdwc7M(gLUMojJq2B6QdsMUUtMo)6GmDhB6Sm2fmSGwzGF1Nkdy5KqefZdiPMTSkBNbQyybDtaYWJCLqoNHDw28r(vxgz6sy68RUmksfb6e20300pz6sy68RUmksfb6e20T20bSPB5MUYcQ0LxqeQMfvmSGUMoqMUuA6klOsxEbrOAwuXWc6A6sy6klOsxEPeQyr8hq4gS6tTOIHf010LImGvK)A26ug4x9PYWZcrKF1NkkCSMbHJ1yXGug2zzZNA2Adz7mqfdlOBcqg4x9PYaKGW7pIH0m8ixjKZzapncyVUlzJGvxqr8iKrLUOIHf0ndEPec1ixJougGBGGwYgbRUGI4riJkD1ip1SLfZ2zGkgwq3eGm8ixjKZzqzbv6cnmYRTryblvqlQyybDnDjm9lb3abTqdJ8ABewWsf0crGSxyt3At)0cWzGF1Nkd)uqcElIvk1SfGZ2zGF1NkdpR8lShdMbQyybDtasnBzzz7mqfdlOBcqgEKReY5mWV6YOiveOtytFtt3QmGvK)A26ug4x9PYWZcrKF1NkkCSMbHJ1yXGug4HsnBbOY2zGkgwq3eGmWV6tLb80iIqoIYWJCLqoNbebHi8odlitxcthpnIiENrxt36dt3IMUeMUuA62X0vwqLUEw5xypgCrfdlORPlT0M(pJ4osQwpR8lShdUqei7f20300rei7f20LIm82)ckQmAlP4S1PuZws9SDgOIHf0nbid8R(uzWbbhbRugEKReY5mGiq2lSPBTPVbtxctxknD7y6klOsxpR8lShdUOIHf010LwAt)NrChjvRNv(f2JbxicK9cB6BA6icK9cB6srgE7FbfvgTLuC26uQzlPA2oduXWc6MaKHh5kHCodklOsxEPeQyr8hq4gS6tTOIHf010LW05x9Pw)op4i8i0LxriHVDxnDjmDebYEHnDRn9BdIvFktFJnDjVaCg4x9PYGdcocwPuZwNKC2oduXWc6MaKHh5kHCodsPPlN0LxqeQyXIF1LrMU0sB6YjDblyS8Dc0(f)QlJmDPW0LW0XtJiI3z01038W0Tyg4x9PYWVZdocpcn1S1Ptz7mqfdlOBcqg4x9PYWZcrKF1NkkCSMbHJ1yXGug(lo1S1jRY2zGF1Nkd)oxfjIxcCkihrzGkgwq3eGuZwN2q2od8R(uza)tdYRTr11DkduXWc6MaKA26KfZ2zGF1Nkdx6Dqw9ABeEeAgOIHf0nbi1S1jaNTZavmSGUjazGF1Nkd7SS5ZWJCLqoNH7OlheCeSslebYEHn9nn97OlheCeSsRBdIvFktFJnDjVaSPlT0MUDmDLfuPlVucvSi(diCdw9PwuXWc6MH3(xqrLrBjfNToLA26KLLTZa)QpvgCq5uD9AB8zLXkAKVtzGkgwq3eGuZwNauz7mWV6tLb80iIOrZavmSGUjaPMToj1Z2zGkgwq3eGm8ixjKZza1ue0G2sR5II4DwsI4af1DkApOJa0YOfzxAC5YPBg4x9PYWolB(uZwNKQz7mqfdlOBcqgg5zatAg4x9PYGmg5mSGYGmw0qzGF1LrrQiqNWM(MM(jtxct)NrChjvRDw28lebYEHnDRpm9ts20LwAthUbcAHCTHfXbkIA8A1i30LW0vwqLUqSxXbk(78GxuXWc6MbzmkwmiLb5ZiI4PreX7m6ItnBzLKZ2zGkgwq3eGm8ixjKZzaUbcAbZpGCrmKUUJKktxcthpnIiENrxtFZdt)0cWMULB6sETbtFJnDLfuPlibJ3hzeArfdlORPlHPBhtxgJCgwql5ZiI4PreX7m6IZa)Qpvg(PGe8weRuQzlRoLTZavmSGUjaz4rUsiNZGCsxEbrOIfl(vxgz6slTPd3abTqSxXbk(78GxicK9cB6BA6pJ1O6Gug4x9PYWVZdocpcn1SLvwLTZavmSGUjaz4rUsiNZaCde0cMFa5IyiD1i30LW0TJPlJrodlOL8zer80iI4DgDXzGF1Nkd)op4i8i0uZwwTHSDgOIHf0nbidpYvc5CguwqLUieF9NvFQfvmSGUMUeMUDmDzmYzybTKpJiINgreVZOl20LW0VeCde0Iq81Fw9PwicK9cB6wB6pJ1O6Gug4x9PYWVZdocpcn1SLvwmBNbQyybDtaYWJCLqoNb7y6YyKZWcAjFgrepnIiENrxSPlT0MoEAer8oJUM(MhMUfxaod8R(uzaVZ3rsWnOk1SLvaoBNbQyybDtaYWJCLqoNb80iI4DgDn9nn9nSaCg4x9PYWVZdocpcn1SLvww2oduXWc6MaKHh5kHCodWdgB6sy6q(2DnIiq2lSPBTPdytxctxz0wsxQdsrDIxNm9nn9NXAuDqY0bY0velJer1bPmWV6tLHFNhCeEeAQzlRauz7mqfdlOBcqgEKReY5m87mAlHn9nn9tMU0sB6kJ2s6sDqkQt86KPBTPV9VzGF1Nkd)uqcElIvk1SLvs9SDg4x9PYGxVxeIvkduXWc6MaKAQPMbzec7tLTSsYwzLKTOKTSmijgvETfNbPsPMDTwB0w21TqMUP3ENmDhu(GuthAqMUfCjiUrOwGPJi7sJJORPJhqY05gDazLUM(VZ1wcVm22iErM(gSqMULCkzesPRPBb4Pra71DzHTatxht3cWtJa2R7YcVOIHf01cmDwnDlbG(nIPlLNSBPyzSTr8Im9tsvlKPBjNsgHu6A6wGYcQ0Lf2cmDDmDlqzbv6YcVOIHf01cmDwnDlbG(nIPlLNSBPyzSTr8ImDR2GfY0TKtjJqkDnDlqzbv6YcBbMUoMUfOSGkDzHxuXWc6AbMUuEYULILXMX2gfu(Gu6A6a205x9PmDHJv8YyldYrdKlOmyPwQPBxryf18QpLPlvYiX8aIXMLAPMUutoYfMULbSPBLKTYkJnJnl1snDl5oxBjSfYyZsTut3YnDaDccV)igspdOzeS6cY0dJqgvQP)C9Ki6qM(VZ1w6A66y6EPec1ixJo0YyZsTut3YnDPMSXVMowodc61wtFJccocwPLXMXMLA6wc7M(gLUMombniY0)beMvthM26fEz6sT)j5k20RPS8Dgbc1imD(vFkSPpLW(LXg)QpfEjhr)acZ6bejI3b0lw9Pa2HouhK2uYsyh5KUyHlJm24x9PWl5i6hqywb64mUbeCQOCsn24x9PWl5i6hqywb64CdMIUsGaxmiDOdifhOi4uyfnn44pfwrnV6tHn24x9PWl5i6hqywb64CdMIUsGaxmiDGhbX74iMEePrL(9YTlnKXg)QpfEjhr)acZkqhNHeeE)rmKASXV6tHxYr0pGWSc0X5TihCCefhOiMFKd5pbSdDOSGkDTf5GJJO4afX8JCi)PfvmSGUgB8R(u4LCe9dimRaDCUbtrxjqGlgKoW78DKeDJdcooqrDqGuPgB8R(u4LCe9dimRaDCgpnIiKJiJn(vFk8soI(beMvGoo717fHyLm2m2Sut3sy303O010jzeYEtxDqY01DY05xhKP7ytNLXUGHf0YyJF1NcFGLtcrumpGySXV6tHpEwiI8R(urHJvGlgKo2zzZdmwr(RhNa2Ho2zzZh5xDzKe8RUmksfb6eEZtsWV6YOiveOtyRbSLRSGkD5feHQzrfdlOlqsPYcQ0LxqeQMfvmSGUsOSGkD5LsOIfXFaHBWQp1IkgwqxPWyJF1Ncd0XzibH3FedPa7qh4Pra71DjBeS6ckIhHmQuG9sjeQrUgDOd4giOLSrWQlOiEeYOsxnYn24x9PWaDC(NcsWBrSsa7qhklOsxOHrETnclyPcArfdlORexcUbcAHgg512iSGLkOfIazVWwFAbyJn(vFkmqhNFw5xypg0yJF1Ncd0X5NfIi)Qpvu4yf4IbPdEiGXkYF94eWo0b)QlJIurGoH30kJn(vFkmqhNXtJic5ic43(xqrLrBjfFCcyh6arqicVZWcsc80iI4DgDT(WIsiL2rzbv66zLFH9yWfvmSGUsl9pJ4osQwpR8lShdUqei7fEtebYEHLcJn(vFkmqhNDqWrWkb8B)lOOYOTKIpobSdDGiq2lS1BqcP0oklOsxpR8lShdUOIHf0vAP)ze3rs16zLFH9yWfIazVWBIiq2lSuySXV6tHb64SdcocwjGDOdLfuPlVucvSi(diCdw9PwuXWc6kb)Qp1635bhHhHU8kcj8T7QeicK9cB9TbXQp1gl5fGn24x9PWaDC(35bhHhHcSdDiLYjD5feHkwS4xDzK0slN0fSGXY3jq7x8RUmskKapnIiENr3npSOXg)QpfgOJZpler(vFQOWXkWfdsh)fBSXV6tHb648VZvrI4LaNcYrKXg)QpfgOJZ4FAqETnQUUtgB8R(uyGooFP3bz1RTr4rOgB8R(uyGooVZYMh43(xqrLrBjfFCcyh64o6YbbhbR0crGSx4nVJUCqWrWkTUniw9P2yjVaS0sBhLfuPlVucvSi(diCdw9PwuXWc6ASXV6tHb64SdkNQRxBJpRmwrJ8DYyJF1Ncd0Xz80iIOrn24x9PWaDCENLnpWo0bQPiObTLwZffX7SKeXbkQ7u0EqhbOLrlYU04YLtxJn(vFkmqhNLXiNHfeWfdshYNreXtJiI3z0fdSmw0qh8RUmksfb6eEZts8ZiUJKQ1olB(fIazVWwFCsYslnCde0c5AdlIdue141QrUeklOsxi2R4af)DEWgB8R(uyGoo)tbj4TiwjGDOd4giOfm)aYfXq66osQKapnIiENr3npoTaSLl51g2yLfuPlibJ3hzeArfdlORe2rgJCgwql5ZiI4PreX7m6In24x9PWaDC(35bhHhHcSdDiN0LxqeQyXIF1LrslnCde0cXEfhO4VZdEHiq2l8MpJ1O6GKXg)QpfgOJZ)op4i8iuGDOd4giOfm)aYfXq6QrUe2rgJCgwql5ZiI4PreX7m6In24x9PWaDC(35bhHhHcSdDOSGkDri(6pR(usyhzmYzybTKpJiINgreVZOlwIlb3abTieF9NvFQfIazVWw)mwJQdsgB8R(uyGooJ357ij4gubSdDyhzmYzybTKpJiINgreVZOlwAPXtJiI3z0DZdlUaSXg)QpfgOJZ)op4i8iuGDOd80iI4DgD3CdlaBSXV6tHb648VZdocpcfyh6aEWyjG8T7AerGSxyRbSekJ2s6sDqkQt860MpJ1O6GeqkILrIO6GKXg)QpfgOJZ)uqcElIvcyh643z0wcV5jPLwz0wsxQdsrDIxNSE7Fn24x9PWaDC2R3lcXkzSzSXV6tHx8qhi2R4afHCebSdDiN0LxqeQyXIF1LrsiL25NrChjvRDw28leXx7LwA(vxgfPIaDcV5gKcJn(vFk8IhcOJZ4PrerJASXV6tHx8qaDC2bLt11RTXNvgROr(ozSXV6tHx8qaDC(35Qir8sGtb5icyh64o6YbbhbR0crGSx4nFgRr1bjJn(vFk8IhcOJZoi4iyLa(T)fuuz0wsXhNa2Ho4xDzuKkc0jS1awcebYEHTgWsiL2rzbv66zLFH9yWfvmSGUsl9pJ4osQwpR8lShdUqei7fEtebYEHLcJn(vFk8IhcOJZpler(vFQOWXkWfdsh)fBSXV6tHx8qaDCENLnpWV9VGIkJ2sk(4eWo0b)QlJIurGoHT2IgB8R(u4fpeqhNrSxXbkc5iYyJF1NcV4Ha648olBEGF7FbfvgTLu8XjJn(vFk8IhcOJZx6Dqw9ABeEeQXg)QpfEXdb0XzVEVieReWo0HYcQ0fKJOix3imYbX6u0IkgwqxjGBGGwW8dixedPRg5sGNgreVZOR1a2YL8YQnMF1LrrQiqNWgB8R(u4fpeqhNXtJic5iYyJF1NcV4Ha648pfKG3IyLa2HoGBGGwW8dixedPR7iPYyJF1NcV4Ha64mENVJKGBqfWo0HYOTKU2jwO7l5VATvs2yJF1NcV4Ha64SdcocwjGF7FbfvgTLu8XjGDOdebHi8odliJn(vFk8IhcOJZ4FAqETnQUUtgB8R(u4fpeqhN969IqSsgBgB8R(u41FXhnyk6kbcCXG0bENVJKOBCqWXbkQdcKkfyh64NrChjvlCdi4urVGiuXIfIazVWwVbPLgEWyjuhKI6eVozTfTYyJF1NcV(lgOJZ4gqWPIEbrOIfgB8R(u41FXaDC(YiajINgr0lSYWUWv7b2HoKt6YlicvSyXV6YiPLgEWyj(ze3rs1c3acov0licvSyHiq2lCKSB50R0Dt1bPOoXRtgB8R(u41FXaDCw(O(ua7qhYjD5feHkwS4xDzKXg)QpfE9xmqhNHjeMqaIxBb2HoKt6YlicvSyXV6YiJn(vFk86VyGoodlM5gHAq2dSdDiN0LxqeQyXIF1LrgB8R(u41FXaDCgYreSyMlWo0HCsxEbrOIfl(vxgzSXV6tHx)fd0X5gmfDLabUyq6a)mchhOieIvcvSiIvKdra7qh2bUbcAHFgHJduecXkHkweXkYHOOfxnYn24x9PWR)Ib64CdMIUsGaxmiDGFgHJduecXkHkweXkYHiGDOd4giOf(zeooqrieReQyreRihIIwC1ixc5KU8cIqflw8RUmYyJF1NcV(lgOJZnyk6kbIb2HoKt6YlicvSyXV6YiPLgEWyjuhKI6eVozTvNm2m24x9PWRDw28h)uqcElIvcyh6aUbcAbZpGCrmKUUJKkjWtJiI3z0DZJtsGNgreVZOR1hw0yJF1NcV2zzZd0Xz80iIqoIa2HoEgRr1bjR3zzZhrei7f2yJF1NcV2zzZd0X5l9oiRETncpcfyh64zSgvhKSENLnFerGSxyjWtJa2R7sq8ncBFKSBguUGwuXWc6ASXV6tHx7SS5b64m(NgKxBJQR7eWo0XZynQoiz9olB(iIazVWgB8R(u41olBEGoo7GGJGvcyh6qzbv6YlLqflI)ac3GvFQfvmSGUsGiq2lS13geR(uBSKxawAPTJYcQ0LxkHkwe)beUbR(ulQyybDLarqicVZWcYyJF1NcV2zzZd0X5FNhCeEekWo0XZynQoiz9olB(iIazVWgB8R(u41olBEGooJ357ij4guzSXV6tHx7SS5b64SxVxeIvcyh64zSgvhKSENLnFerGSx4mGLtF2YkldqLAQzc]] )


end
