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

                if buff.impending_ruin.stack > 10 then
                    buff.impending_ruin.count = buff.impending_ruin.count - 10
                    applyBuff( "ritual_of_ruin" )
                elseif buff.impending_ruin.stack == 10 then
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
                if active_enemies > 1 then
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
    spec:RegisterPet( "succubus",
        function()
            if Glyphed( 240263 ) then return 120526
            elseif Glyphed( 240266 ) then return 120527
            elseif Glyphed( 112868 ) then return 58963 end
            return 1863
        end,
        3600 )

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

            copy = { 112869 }
        },


        summon_imp = {
            id = 688,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            essential = true,
            bind = "summon_pet",
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
                if talent.rain_of_chaos.enabled then applyBuff( "rain_of_chaos" ) end
                if azerite.crashing_chaos.enabled then applyBuff( "crashing_chaos", 3600, 8 ) end
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


    spec:RegisterPack( "Destruction", 20220403, [[dO0JVaqiHepIOkTja1NiQWOavYPav0QesQxbiZcuClkvyxk1VurggOuhdGwgLQEgrLMgrvDnqjBtfL8nkvY4avW5avQwhrfzEusUNkSpHuheuPSqa8qIQWebvOUiLkYgvrPYhPurvNuijTskLzkKe7ui(PkkvTukvu5PcMQIyRQOu8vkvuglrv0Ef9xfgSsomQfdYJv1KvPlJSzI8zfPrROonvRwfLsVwffZgQBd0UL8BPgoL44evulNWZHmDsxxO2or57QOA8uQuNNsQ1dQqMpOQ9tXjG5KmCzLYi2dB7Th2Yh2YDdiCh2Yv(2vguRTqzWc)NHNszOyqkdWXesfXV6DLblS14MV5KmG6yXtzywvli50PttDDogA)n4jKdgJz176fSKEc5G)Pmaf7ynQwjugUSsze7HT92dB5dB5UbeUdB5kFaZahRZTidbhuEKHz)EPkHYWLqFgGJjKkIF17YSSZybU)ZySb3SiCSzjxyml7HT92BSzSjpM5AkHKtgB2HzD2Hj08lyj90ztJz1XKzfASmQuZ656j8WLmRFMRP01S02S8sjHi2IoCPTXMDywWnzTFnlKfge0RPMvufeSXSs7mGDKIYjzyML1FojJayojduXqy6MaKHx4kjCodqXssBi(pZvWs6(2NxMfWMfQJXd0mlUMv0hMfGMfWMfQJXd0mlUMLvhML8Za)Q3vg(UKW8ubRuQze7ZjzGkgct3eGm8cxjHZz4zKouhKmlRmRzww)dbbYEHYa)Q3vgqDmEi5ck1mICZjzGkgct3eGm8cxjHZz4zKouhKmlRmRzww)dbbYEHmlGnluhJH86UXeFhqwpi7MbTGPnvmeMUzGF17kdx6Dqw9A6aQXAQze5NtYavmeMUjaz4fUscNZWZiDOoizwwzwZSS(hccK9cLb(vVRmG(ow410H66mLAgbw5KmqfdHPBcqgEHRKW5mOmMkD7LsIIXJVbHIrQ31MkgctxZcyZsqGSxiZYkZ6gly17YSIAZc2ByzwWdVzffZszmv62lLefJhFdcfJuVRnvmeMUMfWMLGKeeAMHWug4x9UYGdc2ywPuZiNvojduXqy6MaKHx4kjCodpJ0H6GKzzLznZY6Fiiq2lug4x9UYWpZnAa1yn1mIDLtYa)Q3vgqZ8TphkwuzGkgct3eGuZiWHCsgOIHW0nbidVWvs4CgEgPd1bjZYkZAML1)qqGSxOmWV6DLbVEVibRuQPMblc6BqiwZjzeaZjzGkgct3eGmWV6DLbjcpUnOxS6DLHlHEHBr9UYGDYUPpwPRzbrsTGmRVbHy1SGOPEH2MfC7FYIImRQl7yMfGsXyZIF17czwDHTENHx4kjCodQdsMv0MfSnlGnROywwiDZyxgLAgX(Csg4x9UYakgeSRHdAjduXqy6MaKAgrU5KmqfdHPBcqgkgKYG2G0OLgGDHurhJgFxive)Q3fkd8RExzqBqA0sdWUqQOJrJVlKkIF17cLAgr(5KmqfdHPBcqgkgKYaQXepJgi6fKou6NlxohtzGF17kdOgt8mAGOxq6qPFUC5CmLAgbw5KmWV6DLbjmHMFblPzGkgct3eGuZiNvojduXqy6MaKHx4kjCodkJPs3tfoy7cA0sde)cxYFAtfdHPBg4x9UYWuHd2UGgT0aXVWL8NsnJyx5KmqfdHPBcqgkgKYaAMV950D0cOrln0wasLMb(vVRmGM5BFoDhTaA0sdTfGuPPMrGd5KmWV6DLbuhJhsUGYavmeMUjaPMrG75KmWV6DLbVEVibRugOIHW0nbi1uZa3uojJayojduXqy6MaKHx4kjCodwiD7LejkgV5xDzKzbSzbxMvumRVB8TpV2ZSS(3cIVwBwWdVzXV6YObveOtiZkAZsUMfCMb(vVRmiyVgT0qYfuQze7ZjzGF17kdOogpeTMbQyimDtasnJi3Csg4x9UYGdAHQRxthpRmsfTLzkduXqy6MaKAgr(5KmqfdHPBcqgEHRKW5mCBD7GGnMvAliq2lKzfTz9mshQdszGF17kd)mxfHhxcSljxqPMrGvojduXqy6MaKb(vVRm4GGnMvkdVWvs4Cg4xDz0Gkc0jKzzLzblZcyZsqGSxiZYkZcwMfWMfCzwrXSugtLUFw5hBncCtfdHPRzbp8M13n(2Nx7Nv(XwJa3ccK9czwrBwccK9czwWzgERFmnuwmLuugbWuZiNvojduXqy6MaKb(vVRm8mgp4x9UgyhPza7iDumiLH)IsnJyx5KmqfdHPBcqg4x9UYWZy8GF17AGDKMbSJ0rXGugieIQNqPMrGd5KmqfdHPBcqg4x9UYWmlR)m8cxjHZzGF1LrdQiqNqMLvML8ZWB9JPHYIPKIYiaMAgbUNtYa)Q3vgeSxJwAi5ckduXqy6MaKAgbqyNtYavmeMUjazGF17kdZSS(ZWB9JPHYIPKIYiaMAgbqaZjzGF17kdx6Dqw9A6aQXAgOIHW0nbi1mcG2NtYavmeMUjaz4fUscNZGYyQ0TKlObx3bKWbrAx0MkgctxZcyZckwsAdX)zUcws3XwmlGnluhJhOzwCnlRmlyzw2Hzb7T9MvuBw8RUmAqfb6ekd8RExzWR3lsWkLAgbq5MtYa)Q3vgqDmEi5ckduXqy6MaKAgbq5NtYavmeMUjaz4fUscNZauSK0gI)ZCfSKUV95vg4x9UYW3LeMNkyLsnJaiSYjzGkgct3eGm8cxjHZzqzXus3ZeJ15TLxnlRml7HDg4x9UYaAMV95qXIk1mcGNvojduXqy6MaKb(vVRm4GGnMvkdVWvs4CgeKKGqZmeMYWB9JPHYIPKIYiaMAgbq7kNKb(vVRmG(ow410H66mLbQyimDtasnJaiCiNKb(vVRm417fjyLYavmeMUjaPMAg(lkNKramNKbQyimDtaYa)Q3vgqZ8TpNUJwanAPH2cqQ0m8cxjHZz47gF7ZRnkgeSRHxsKOy8wqGSxiZYkZsUMf8WBwqnczwaBwQdsdThxNmlRml5BFgkgKYaAMV950D0cOrln0wasLMAgX(Csg4x9UYakgeSRHxsKOyCgOIHW0nbi1mICZjzGkgct3eGm8cxjHZzWcPBVKirX4n)QlJml4H3SGAeYSa2S(UX3(8AJIbb7A4LejkgVfei7fAq2Tf6v6AwrBwQdsdThxNYa)Q3vgUS4mduhJhEHugYXUADQze5NtYavmeMUjaz4fUscNZGfs3EjrIIXB(vxgLb(vVRmyPvVRuZiWkNKbQyimDtaYWlCLeoNblKU9sIefJ38RUmkd8RExzaIeisCgVMMAg5SYjzGkgct3eGm8cxjHZzWcPBVKirX4n)QlJYa)Q3vgGWDFhsXcRtnJyx5KmqfdHPBcqgEHRKW5myH0TxsKOy8MF1LrzGF17kdsUGGWDFtnJahYjzGkgct3eGm8cxjHZzWcPBVKirX4n)QlJml4H3SGAeYSa2SuhKgApUozwwzw2dyg4x9UYqmIgUsGOutndxsIJXAojJayojduXqy6MaKHlHEHBr9UYGDYUPpwPRzrYiH1ML6GKzPZKzXV2cZYrMflJDmdHPDg4x9UYaYcHXdC)Nj1mI95KmqfdHPBcqgEHRKW5mmZY6FWV6YiZcyZIF1LrdQiqNqMv0MfGMfWMf)QlJgurGoHmlRmlyzw2HzPmMkD7LejQEtfdHPRzbKzbxMLYyQ0TxsKO6nvmeMUMfWMLYyQ0Txkjkgp(gekgPExBQyimDnl4mdiv4VMramd8RExz4zmEWV6DnWosZa2r6OyqkdZSS(tnJi3CsgOIHW0nbid8RExzqctO5xWsAgEHRKW5mG6ymKx3TSgZQJPbQXYOs3uXqy6MbVusiITOdxkdqXssBznMvhtduJLrLUJTKAgr(5KmqfdHPBcqgEHRKW5mOmMkDlAw410beMHJOnvmeMUMfWM1LGILK2IMfEnDaHz4iAliq2lKzzLzb4gwzGF17kdFxsyEQGvk1mcSYjzGF17kdpR8JTgbMbQyimDtasnJCw5KmqfdHPBcqgEHRKW5mWV6YObveOtiZkAZY(mGuH)AgbWmWV6DLHNX4b)Q31a7indyhPJIbPmWnLAgXUYjzGkgct3eGmWV6DLbuhJhsUGYWlCLeoNbbjji0mdHjZcyZc1X4bAMfxZYQdZs(MfWMfCzwrXSugtLUFw5hBncCtfdHPRzbp8M13n(2Nx7Nv(XwJa3ccK9czwrBwccK9czwWzgERFmnuwmLuugbWuZiWHCsgOIHW0nbid8RExzWbbBmRugEHRKW5miiq2lKzzLzjxZcyZcUmROywkJPs3pR8JTgbUPIHW01SGhEZ67gF7ZR9Zk)yRrGBbbYEHmROnlbbYEHml4mdV1pMgklMskkJayQze4EojduXqy6MaKHx4kjCodkJPs3EPKOy84BqOyK6DTPIHW01Sa2S4x9U2)m3ObuJ1TxdjSpDwnlGnlbbYEHmlRmRBSGvVlZkQnlyVHvg4x9UYGdc2ywPuZiac7CsgOIHW0nbidVWvs4CgGlZYcPBVKirX4n)QlJml4H3SSq6gcZilZeO1B(vxgzwWPzbSzH6y8anZIRzf9Hzj)mWV6DLHFMB0aQXAQzeabmNKbQyimDtaYa)Q3vgEgJh8RExdSJ0mGDKokgKYWFrPMra0(Csg4x9UYWpZvr4XLa7sYfugOIHW0nbi1mcGYnNKb(vVRmG(ow410H66mLbQyimDtasnJaO8ZjzGF17kdx6Dqw9A6aQXAgOIHW0nbi1mcGWkNKbQyimDtaYa)Q3vgMzz9NHx4kjCod3w3oiyJzL2ccK9czwrBw3w3oiyJzL23ybRExMvuBwWEdlZcE4nROywkJPs3EPKOy84BqOyK6DTPIHW0ndV1pMgklMskkJayQzeapRCsg4x9UYGdAHQRxthpRmsfTLzkduXqy6MaKAgbq7kNKb(vVRmG6y8q0AgOIHW0nbi1mcGWHCsgOIHW0nbidVWvs4CgeXfj1IP0UVIbAMphpAPHotdRbDXzll2KCo2TyHUzGF17kdZSS(tnJaiCpNKbQyimDtaYqBjdisZa)Q3vgKXcNHWugKX4ykd8RUmAqfb6eYSI2Sa0Sa2S(UX3(8ApZY6Fliq2lKzz1HzbiSnl4H3SGILK2cxJz8OLgIyV2XwmlGnlLXuPBb71OLg)m3OnvmeMUzqglgfdszWs34bQJXd0mlUOuZi2d7CsgOIHW0nbidVWvs4CgGILK2q8FMRGL09TpVmlGnluhJhOzwCnROpmla3WYSSdZc2B5AwrTzPmMkDlHz0ClJeBQyimDnlGnROywYyHZqyABPB8a1X4bAMfxug4x9UYW3LeMNkyLsnJypG5KmqfdHPBcqgEHRKW5myH0TxsKOy8MF1LrMf8WBwqXssBb71OLg)m3OTGazVqMv0M1ZiDOoiLb(vVRm8ZCJgqnwtnJyV95KmqfdHPBcqgEHRKW5mafljTH4)mxblP7ylMfWMvumlzSWzimTT0nEG6y8anZIlkd8RExz4N5gnGASMAgXE5MtYavmeMUjaz4fUscNZGYyQ0nj4R)S6DTPIHW01Sa2SIIzjJfodHPTLUXduhJhOzwCrMfWM1LGILK2KGV(ZQ31wqGSxiZYkZ6zKouhKYa)Q3vg(zUrdOgRPMrSx(5KmqfdHPBcqgEHRKW5mefZsglCgctBlDJhOogpqZS4Iml4H3SqDmEGMzX1SI(WSK)gwzGF17kdOz(2NdflQuZi2dRCsgOIHW0nbidVWvs4CgqDmEGMzX1SI2SK7gwzGF17kd)m3ObuJ1uZi2Fw5KmqfdHPBcqgEHRKW5ma1iKzbSzj5tN1HGazVqMLvMfSmlGnlLftjDRoin0ECDYSI2SEgPd1bjZciZsfSmcpuhKYa)Q3vg(zUrdOgRPMrS3UYjzGkgct3eGm8cxjHZz4NzXuczwrBwaAwWdVzPSykPB1bPH2JRtMLvM10)Mb(vVRm8DjH5PcwPuZi2dhYjzGF17kdE9ErcwPmqfdHPBcqQPMAgKrcK3vgXEyBV9WwU2Bxz4CwuEnfLb7m4MDUir1i25LtMLznzMmlh0sluZsQfMLCCjjogRYHzji5CSlORzHAqYS4yTbzLUM1pZ1ucTn2IkErMLCLtML8OlzKqPRzjhOogd51DlpLdZsBZsoqDmgYR7wEUPIHW0vomlwnl70zFuXSGlaTB4CBSfv8ImlaH7YjZsE0LmsO01SKdLXuPB5PCywABwYHYyQ0T8CtfdHPRCywSAw2PZ(OIzbxaA3W52ylQ4fzw2lx5Kzjp6sgju6AwYHYyQ0T8uomlTnl5qzmv6wEUPIHW0voml4cq7go3gBgBrvqlTqPRzblZIF17YSWosrBJTmyr0soMYG8kVMfCmHur8RExMLDglW9FgJn5vEnl4MfHJnl5cJzzpST3EJnJn5vEnl5XmxtjKCYytELxZYomRZomHMFblPNoBAmRoMmRqJLrLAwpxpHhUKz9ZCnLUML2MLxkjeXw0HlTn2Kx51SSdZcUjR9RzHSWGGEn1SIQGGnMvABSzSjVMLDYUPpwPRzbrsTGmRVbHy1SGOPEH2MfC7FYIImRQl7yMfGsXyZIF17czwDHTEBSXV6DH2we03GqSEir4XTb9IvVlyCPd1bPOHnWrXcPBg7YiJn(vVl02IG(geIvGooHIbb7AyHuJn(vVl02IG(geIvGoofJOHReimfdshAdsJwAa2fsfDmA8DHur8RExiJn(vVl02IG(geIvGoofJOHReimfdshOgt8mAGOxq6qPFUC5CmzSXV6DH2we03GqSc0XjjmHMFblPgB8RExOTfb9nieRaDCAQWbBxqJwAG4x4s(tW4shkJPs3tfoy7cA0sde)cxYFAtfdHPRXg)Q3fABrqFdcXkqhNIr0WvceMIbPd0mF7ZP7OfqJwAOTaKk1yJF17cTTiOVbHyfOJtOogpKCbzSXV6DH2we03GqSc0XjVEVibRKXMXM8Aw2j7M(yLUMfjJewBwQdsMLotMf)AlmlhzwSm2XmeM2gB8RExOdKfcJh4(pJXg)Q3f64zmEWV6DnWosHPyq6yML1pmiv4VEaimU0XmlR)b)QlJaMF1LrdQiqNqrdiW8RUmAqfb6eYkyzhkJPs3EjrIQ3uXqy6ceCPmMkD7LejQEtfdHPlWkJPs3EPKOy84BqOyK6DTPIHW0fon24x9UqaDCsctO5xWskmU0bQJXqED3YAmRoMgOglJkfgVusiITOdx6akwsAlRXS6yAGASmQ0DSfJn(vVleqhN(UKW8ubRemU0HYyQ0TOzHxthqygoI2uXqy6c8LGILK2IMfEnDaHz4iAliq2lKvaUHLXg)Q3fcOJtpR8JTgbASXV6DHa640Zy8GF17AGDKctXG0b3emiv4VEaimU0b)QlJgurGoHI2EJn(vVleqhNqDmEi5ccM36htdLftjfDaimU0HGKeeAMHWeWOogpqZS4A1H8bgUIIYyQ09Zk)yRrGBQyimDHh(VB8TpV2pR8JTgbUfei7fkAbbYEHGtJn(vVleqhNCqWgZkbZB9JPHYIPKIoaegx6qqGSxiRKlWWvuugtLUFw5hBncCtfdHPl8W)DJV951(zLFS1iWTGazVqrliq2leCASXV6DHa64Kdc2ywjyCPdLXuPBVusumE8niums9U2uXqy6cm)Q31(N5gnGASU9AiH9PZkWccK9cz1nwWQ3vud7nSm24x9UqaDC6N5gnGAScJlDaxwiD7LejkgV5xDze8WBH0neMrwMjqR38RUmcobg1X4bAMf3OpKVXg)Q3fcOJtpJXd(vVRb2rkmfdsh)fzSXV6DHa640pZvr4XLa7sYfKXg)Q3fcOJtOVJfEnDOUotgB8RExiGooDP3bz1RPdOgRgB8RExiGoonZY6hM36htdLftjfDaimU0XT1Tdc2ywPTGazVqrFBD7GGnMvAFJfS6Df1WEdl4HpkkJPs3EPKOy84BqOyK6DTPIHW01yJF17cb0Xjh0cvxVMoEwzKkAlZKXg)Q3fcOJtOogpeTASXV6DHa640mlRFyCPdrCrsTykT7RyGM5ZXJwAOZ0WAqxC2YInjNJDlwORXg)Q3fcOJtYyHZqycMIbPdlDJhOogpqZS4IGrgJJPd(vxgnOIaDcfnGa)DJV951EML1)wqGSxiRoae2WdpuSK0w4AmJhT0qe71o2cWkJPs3c2Rrln(zUrgB8RExiGoo9DjH5PcwjyCPdOyjPne)N5kyjDF7ZlGrDmEGMzXn6da3WYoG9wUrTYyQ0TeMrZTmsSPIHW0f4OiJfodHPTLUXduhJhOzwCrgB8RExiGoo9ZCJgqnwHXLoSq62ljsumEZV6Yi4HhkwsAlyVgT04N5gTfei7fk6Nr6qDqYyJF17cb0XPFMB0aQXkmU0buSK0gI)ZCfSKUJTaCuKXcNHW02s34bQJXd0mlUiJn(vVleqhN(zUrdOgRW4shkJPs3KGV(ZQ3fWrrglCgctBlDJhOogpqZS4Ia(sqXssBsWx)z17Aliq2lKvpJ0H6GKXg)Q3fcOJtOz(2NdflkyCPJOiJfodHPTLUXduhJhOzwCrWdpQJXd0mlUrFi)nSm24x9UqaDC6N5gnGAScJlDG6y8anZIB0YDdlJn(vVleqhN(zUrdOgRW4shqncbSKpDwhccK9czfSawzXus3QdsdThxNI(zKouhKasfSmcpuhKm24x9UqaDC67scZtfSsW4sh)mlMsOObeE4vwmL0T6G0q7X1jRM(xJn(vVleqhN869IeSsgBgB8RExOn30HG9A0sdjxqW4shwiD7LejkgV5xDzeWWvu(UX3(8ApZY6Fli(An8WZV6YObveOtOOLlCASXV6DH2CtaDCc1X4HOvJn(vVl0MBcOJtoOfQUEnD8SYiv0wMjJn(vVl0MBcOJt)mxfHhxcSljxqW4sh3w3oiyJzL2ccK9cf9ZiDOoizSXV6DH2CtaDCYbbBmRemV1pMgklMsk6aqyCPd(vxgnOIaDczfSawqGSxiRGfWWvuugtLUFw5hBncCtfdHPl8W)DJV951(zLFS1iWTGazVqrliq2leCASXV6DH2CtaDC6zmEWV6DnWosHPyq64ViJn(vVl0MBcOJtpJXd(vVRb2rkmfdshecr1tiJn(vVl0MBcOJtZSS(H5T(X0qzXusrhacJlDWV6YObveOtiRKVXg)Q3fAZnb0Xjb71OLgsUGm24x9UqBUjGoonZY6hM36htdLftjfDaOXg)Q3fAZnb0XPl9oiREnDa1y1yJF17cT5Ma64KxVxKGvcgx6qzmv6wYf0GR7as4GiTlAtfdHPlWqXssBi(pZvWs6o2cWOogpqZS4AfSSdyVTpQ5xDz0Gkc0jKXg)Q3fAZnb0XjuhJhsUGm24x9UqBUjGoo9DjH5PcwjyCPdOyjPne)N5kyjDF7ZlJn(vVl0MBcOJtOz(2NdflkyCPdLftjDptmwN3wE1k7HTXg)Q3fAZnb0XjheSXSsW8w)yAOSykPOdaHXLoeKKGqZmeMm24x9UqBUjGooH(ow410H66mzSXV6DH2CtaDCYR3lsWkzSzSXV6DH2)fDeJOHReimfdshOz(2Nt3rlGgT0qBbivkmU0X3n(2NxBumiyxdVKirX4TGazVqwjx4HhQriGvhKgApUozL8T3yJF17cT)lcOJtOyqWUgEjrIIXgB8RExO9FraDC6YIZmqDmE4fszih7Q1W4shwiD7LejkgV5xDze8Wd1ieWF34BFETrXGGDn8sIefJ3ccK9cni72c9kDJwDqAO946KXg)Q3fA)xeqhNS0Q3fmU0Hfs3EjrIIXB(vxgzSXV6DH2)fb0XjisGiXz8AkmU0Hfs3EjrIIXB(vxgzSXV6DH2)fb0XjiC33HuSWAyCPdlKU9sIefJ38RUmYyJF17cT)lcOJtsUGGWDFHXLoSq62ljsumEZV6YiJn(vVl0(ViGoofJOHReicgx6WcPBVKirX4n)QlJGhEOgHawDqAO946Kv2dOXMXg)Q3fApZY6)47scZtfSsW4shqXssBi(pZvWs6(2NxaJ6y8anZIB0hacmQJXd0mlUwDiFJn(vVl0EML1pqhNqDmEi5ccgx64zKouhKSAML1)qqGSxiJn(vVl0EML1pqhNU07GS610buJvyCPJNr6qDqYQzww)dbbYEHag1XyiVUBmX3bK1dYUzqlyAtfdHPRXg)Q3fApZY6hOJtOVJfEnDOUotW4shpJ0H6GKvZSS(hccK9czSXV6DH2ZSS(b64Kdc2ywjyCPdLXuPBVusumE8niums9U2uXqy6cSGazVqwDJfS6Df1WEdl4HpkkJPs3EPKOy84BqOyK6DTPIHW0fybjji0mdHjJn(vVl0EML1pqhN(zUrdOgRW4shpJ0H6GKvZSS(hccK9czSXV6DH2ZSS(b64eAMV95qXIYyJF17cTNzz9d0XjVEVibRemU0XZiDOoiz1mlR)HGazVqzazH(mI9NLDLAQzca]] )


end
