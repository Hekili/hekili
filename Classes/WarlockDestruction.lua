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


    spec:RegisterPack( "Destruction", 20220327, [[dS0bVaqikv5rkk0MauFcujJcuHtbkQvPOiVcqMfO0TuuWUuQFPImmIkogaTmIQEgLitJsvDnqHTPOO(gOIghOiohOszDGI08OeUNkSpfLoirLWcvr9qIkvtKOs0fPefBeaI(iae6KGkvTskLzsjkDtaOyNcXpbGKLcabpvWufsBfas9vqLkJLOsAVI(Rcdwjhg1Ib5XQAYQ0LH2mr(SIQrRiNMQvdaLEnay2iDBG2TKFl1WPKoorLYYj8CetN01fQTtu(oaA8uIQZtPY6bGQ5dQA)uCcygndxwXmI8YrE5LJLKho3acNac3K3(zqTZkMbR8da8CmdfdIzqUejQi(vVRmyLTJ28nJMbshlEmdtQALatpDAURtXq7VbprCWykRExVGL0teh8pLbOyNQW9vcLHlRygrE5iV8YXsYdNBaHtaHBYdyg4yDQfzi4GY9mm53lwjugUi5ZGCjsur8RExMfChlO9dagBayyXpzwYdNWAwYlh5L3yZytUpX1CKatn2MbZcajfjtVGL0taOBkRofnRqtLHLAwpxpshUKz9tCnhVML2MLxkkeXw1HlTZa1jkjJMHjww)z0mcGz0mGfdrXBEodVWvu4CgGILK2q8daxblP7BdWYSa2SiDmDqMyX1SM9WSa0Sa2SiDmDqMyX1SS4WSSFg4x9UYW3LeLNlyftnJiFgndyXqu8MNZWlCffoNHNj6qDq0SSWSMyz9peii7fjd8RExzG0X0HKlWuZiwkJMbSyikEZZz4fUIcNZWZeDOoiAwwywtSS(hceK9IywaBwKoMc51Dtr(oGSBGwodALIBSyikEZa)Q3vgU47GS618but1uZi2pJMbSyikEZZz4fUIcNZWZeDOoiAwwywtSS(hceK9IKb(vVRmq(ow418H66eMAgbgz0mGfdrXBEodVWvu4CguMILU9srrX0X3GqXe17AJfdrXRzbSzjqq2lIzzHzDJfS6DzwZKzjNnmml4H3SSNzPmflD7LIIIPJVbHIjQ31glgIIxZcyZsGscKmXqumd8RExzWbbBkRyQzKzoJMbSyikEZZz4fUIcNZWZeDOoiAwwywtSS(hceK9IKb(vVRm8tCtgqnvtnJaNz0mWV6DLbYeFBacflQmGfdrXBEo1mcmjJMbSyikEZZz4fUIcNZWZeDOoiAwwywtSS(hceK9IKb(vVRm417fkyftn1myvGFdcXAgnJaygndyXqu8MNZa)Q3vgKq642GEXQ3vgUi5fUv17kdwglh)yfVMfek1c0S(geIvZccN7fzBwYf)JwvIzvDndtSaukMAw8RExeZQlQD7m8cxrHZzqDq0SM1SKJzbSzzpZYkQBM6YWuZiYNrZa)Q3vgiXGGDnCqRzalgII38CQzelLrZawmefV55mumiMbTbXrlna7IOIoMm(UiQi(vVlsg4x9UYG2G4OLgGDrurhtgFxeve)Q3fj1mI9ZOzalgII38CgkgeZaPPiprge8fOou8NkxUfJzGF17kdKMI8ezqWxG6qXFQC5wmMAgbgz0mWV6DLbjksMEblPzalgII38CQzKzoJMbSyikEZZz4fUIcNZGYuS09CHd2UahT0GWVWL8h3yXqu8Mb(vVRmmx4GTlWrlni8lCj)XuZiWzgndyXqu8MNZqXGygit8TbiEhTaA0sdTfGyPzGF17kdKj(2aeVJwanAPH2cqS0uZiWKmAg4x9UYaPJPdjxGzalgII38CQze4wgnd8RExzWR3luWkMbSyikEZZPMAg4gZOzeaZOzalgII38CgEHROW5myf1TxsOOy6MF1LHMfWMfCyw2ZS(UP3gG1EIL1)wG81oZcE4nl(vxgoWcbDKywZAwwYSG5mWV6DLbb71OLgsUatnJiFgnd8RExzG0X0HO1mGfdrXBEo1mILYOzGF17kdoOvSUEnF8SYev0wNWmGfdrXBEo1mI9ZOzalgII38CgEHROW5mCBD7GGnLvClqq2lIznRz9mrhQdIzGF17kd)exfshxeSljxGPMrGrgndyXqu8MNZa)Q3vgCqWMYkMHx4kkCod8RUmCGfc6iXSSWSGHzbSzjqq2lIzzHzbdZcyZcoml7zwktXs3pR8tTJaUXIHO41SGhEZ67MEBaw7Nv(P2ra3ceK9IywZAwceK9IywWCgE7EkouwmhvsgbWuZiZCgndyXqu8MNZa)Q3vgEMsh8RExdQt0mqDIokgeZWFjPMrGZmAgWIHO4npNb(vVRm8mLo4x9UguNOzG6eDumiMbKqW6rsQzeysgndyXqu8MNZa)Q3vgMyz9NHx4kkCod8RUmCGfc6iXSSWSSFgE7EkouwmhvsgbWuZiWTmAg4x9UYGG9A0sdjxGzalgII38CQzeaLtgndyXqu8MNZa)Q3vgMyz9NH3UNIdLfZrLKram1mcGaMrZa)Q3vgU47GS618but1mGfdrXBEo1mcGYNrZawmefV55m8cxrHZzqzkw6wYf4GR7as4GeTlCJfdrXRzbSzbfljTH4haUcws3XwnlGnlshthKjwCnllmlyywZGzjNT8M1mzw8RUmCGfc6ijd8RExzWR3luWkMAgbqlLrZa)Q3vgiDmDi5cmdyXqu8MNtnJaO9ZOzalgII38CgEHROW5mafljTH4haUcws33gGvg4x9UYW3LeLNlyftnJaimYOzalgII38CgEHROW5mOSyoQ7jKP6026RMLfML8Yjd8RExzGmX3gGqXIk1mcGZCgnd8RExzWbbBkRygWIHO4npNAgbq4mJMb(vVRmq(ow418H66eMbSyikEZZPMraeMKrZa)Q3vg869cfSIzalgII38CQPMH)sYOzeaZOzalgII38Cg4x9UYazIVnaX7OfqJwAOTaelndVWvu4Cg(UP3gG1Medc21WljuumDlqq2lIzzHzzjZcE4nlOMqmlGnl1bXH2JRJMLfML9LpdfdIzGmX3gG4D0cOrln0waILMAgr(mAg4x9UYajgeSRHxsOOyAgWIHO4npNAgXsz0mGfdrXBEodVWvu4CgSI62ljuumDZV6YqZcE4nlOMqmlGnRVB6TbyTjXGGDn8scfft3ceK9Imql3k(kEnRznl1bXH2JRJzGF17kdxwaadshthErugYPUAxQze7NrZawmefV55m8cxrHZzWkQBVKqrX0n)QldZa)Q3vgS2Q3vQzeyKrZawmefV55m8cxrHZzWkQBVKqrX0n)QldZa)Q3vgGqbbfaGxZtnJmZz0mGfdrXBEodVWvu4CgSI62ljuumDZV6YWmWV6DLbiA33HuSWUuZiWzgndyXqu8MNZWlCffoNbROU9scfft38RUmmd8RExzqYfieT7BQzeysgndyXqu8MNZWlCffoNbROU9scfft38RUm0SGhEZcQjeZcyZsDqCO946OzzHzjpGzGF17kdXeC4kcssn1mCrjoMQz0mcGz0mGfdrXBEodxK8c3Q6DLblJLJFSIxZcLHc7ml1brZsNqZIFTfMLtmlwg7ugII7mWV6DLbIvKsh0(bGuZiYNrZawmefV55m8cxrHZzyIL1)GF1LHMfWMf)QldhyHGosmRznlanlGnl(vxgoWcbDKywwywWWSMbZszkw62ljuu9glgIIxZciZcomlLPyPBVKqr1BSyikEnlGnlLPyPBVuuumD8niumr9U2yXqu8AwWCgiQWFnJayg4x9UYWZu6GF17AqDIMbQt0rXGygMyz9NAgXsz0mGfdrXBEod8RExzqIIKPxWsAgEHROW5mq6ykKx3TSMYQtXbPPYWs3yXqu8MbVuuiITQdxkdqXssBznLvNIdstLHLUJTMAgX(z0mGfdrXBEodVWvu4CguMILUfnl8A(aIYa44glgIIxZcyZ6IqXssBrZcVMpGOmaoUfii7fXSSWSaCdJmWV6DLHVljkpxWkMAgbgz0mWV6DLHNv(P2raZawmefV55uZiZCgndyXqu8MNZWlCffoNb(vxgoWcbDKywZAwYNbIk8xZiaMb(vVRm8mLo4x9UguNOzG6eDumiMbUXuZiWzgndyXqu8MNZa)Q3vgiDmDi5cmdVWvu4CgeOKajtmefnlGnlshthKjwCnlloml7BwaBwWHzzpZszkw6(zLFQDeWnwmefVMf8WBwF30BdWA)SYp1oc4wGGSxeZAwZsGGSxeZcMZWB3tXHYI5OsYiaMAgbMKrZawmefV55mWV6DLbheSPSIz4fUIcNZGabzViMLfMLLmlGnl4WSSNzPmflD)SYp1oc4glgIIxZcE4nRVB6TbyTFw5NAhbClqq2lIznRzjqq2lIzbZz4T7P4qzXCujzeatnJa3YOzalgII38CgEHROW5mOmflD7LIIIPJVbHIjQ31glgIIxZcyZIF17A)tCtgqnv3EnKO(8j1Sa2Seii7fXSSWSUXcw9UmRzYSKZggzGF17kdoiytzftnJaOCYOzalgII38CgEHROW5mahMLvu3EjHIIPB(vxgAwWdVzzf1neLjwNqq728RUm0SGzZcyZI0X0bzIfxZA2dZY(zGF17kd)e3Kbut1uZiacygndyXqu8MNZa)Q3vgEMsh8RExdQt0mqDIokgeZWFjPMrau(mAg4x9UYWpXvH0Xfb7sYfygWIHO4npNAgbqlLrZa)Q3vgiFhl8A(qDDcZawmefV55uZiaA)mAg4x9UYWfFhKvVMpGAQMbSyikEZZPMraegz0mGfdrXBEod8RExzyIL1FgEHROW5mCBD7GGnLvClqq2lIznRzDBD7GGnLvCFJfS6DzwZKzjNnmml4H3SSNzPmflD7LIIIPJVbHIjQ31glgII3m829uCOSyoQKmcGPMraCMZOzGF17kdoOvSUEnF8SYev0wNWmGfdrXBEo1mcGWzgnd8RExzG0X0HO1mGfdrXBEo1mcGWKmAgWIHO4npNHx4kkCodI4cLAXCC3xXGmXaKoAPHoHd7aDbawwSr5wSB1kEZa)Q3vgMyz9NAgbq4wgndyXqu8MNZqBndeuZa)Q3vgKXcNHOygKX0ymd8RUmCGfc6iXSM1Sa0Sa2S(UP3gG1EIL1)wGGSxeZYIdZcq5ywWdVzbfljTfUgZ0rlneXETJTAwaBwktXs3c2Rrln(jUjBSyikEZGmwmkgeZG1UPdshthKjwCjPMrKxoz0mGfdrXBEodVWvu4CgGILK2q8daxblP7BdWYSa2SiDmDqMyX1SM9WSaCddZAgml5STKzntMLYuS0TeLjtTmuSXIHO41Sa2SSNzjJfodrXT1UPdshthKjwCjzGF17kdFxsuEUGvm1mI8aMrZawmefV55m8cxrHZzWkQBVKqrX0n)Qldnl4H3SGILK2c2Rrln(jUjBbcYErmRznRNj6qDqmd8RExz4N4MmGAQMAgrE5ZOzalgII38CgEHROW5mafljTH4haUcws3XwnlGnl7zwYyHZquCBTB6G0X0bzIfxsg4x9UYWpXnza1un1mI8wkJMbSyikEZZz4fUIcNZGYuS0nk4R)S6DTXIHO41Sa2SSNzjJfodrXT1UPdshthKjwCjMfWM1fHILK2OGV(ZQ31wGGSxeZYcZ6zIouheZa)Q3vg(jUjdOMQPMrK3(z0mGfdrXBEodVWvu4CgSNzjJfodrXT1UPdshthKjwCjMf8WBwKoMoitS4AwZEyw2FdJmWV6DLbYeFBacflQuZiYdJmAgWIHO4npNHx4kkCodKoMoitS4AwZAwwAdJmWV6DLHFIBYaQPAQze5N5mAgWIHO4npNHx4kkCodqnHywaBws(8jDiqq2lIzzHzbdZcyZszXCu3QdIdThxhnRznRNj6qDq0SaYSubldPd1bXmWV6DLHFIBYaQPAQze5HZmAgWIHO4npNHx4kkCod)elMJeZAwZcqZcE4nlLfZrDRoio0ECD0SSWSM)3mWV6DLHVljkpxWkMAgrEysgnd8RExzWR3luWkMbSyikEZZPMAQzqgkiExze5LJ8YlhlbimYaazr51CsgG7KlaqicCFeaeHPMLzfDcnlh0AluZsQfMfCDrjoMQWLzjq5wSlWRzrAq0S4yTbzfVM1pX1CKSn2SSEHMLLGPMLCVlzOqXRzbxKoMc51DlxHlZsBZcUiDmfYR7wUUXIHO4fUmlwnlldaklRzbhaA5W82yZY6fAwac3GPMLCVlzOqXRzbxktXs3Yv4YS02SGlLPyPB56glgIIx4YSy1SSmaOSSMfCaOLdZBJnlRxOzjVLGPMLCVlzOqXRzbxktXs3Yv4YS02SGlLPyPB56glgIIx4YSGdaTCyEBSzSb3dATfkEnlyyw8RExMf1jkzBSLbRIwYPygMXz0SKlrIkIF17YSG7ybTFaWyBgNrZcadl(jZsE4ewZsE5iV8gBgBZ4mAwY9jUMJeyQX2moJM1mywaiPiz6fSKEcaDtz1POzfAQmSuZ656r6WLmRFIR541S02S8srHi2QoCPTXMX2mAwwglh)yfVMfek1c0S(geIvZccN7fzBwYf)JwvIzvDndtSaukMAw8RExeZQlQDBJn(vVlY2Qa)geI1djKoUnOxS6DbRlDOoioRCa2EwrDZuxgASXV6Dr2wf43GqSc0XjsmiyxdROASXV6Dr2wf43GqSc0XPycoCfbHTyq8qBqC0sdWUiQOJjJVlIkIF17IySXV6Dr2wf43GqSc0XPycoCfbHTyq8G0uKNidc(cuhk(tLl3IrJn(vVlY2Qa)geIvGoojrrY0lyj1yJF17ISTkWVbHyfOJtZfoy7cC0sdc)cxYFewx6qzkw6EUWbBxGJwAq4x4s(JBSyikEn24x9UiBRc8Bqiwb64umbhUIGWwmiEqM4Bdq8oAb0OLgAlaXsn24x9UiBRc8Bqiwb64ePJPdjxGgB8RExKTvb(nieRaDCYR3luWkASzSnJMLLXYXpwXRzHYqHDML6GOzPtOzXV2cZYjMflJDkdrXTXg)Q3f5GyfP0bTFaWyJF17IC8mLo4x9UguNOWwmiEmXY6hwIk8xpaewx6yIL1)GF1LHaZV6YWbwiOJKzbey(vxgoWcbDKybmMbLPyPBVKqr1BSyikEbcouMILU9scfvVXIHO4fyLPyPBVuuumD8niumr9U2yXqu8cZgB8RExeGoojrrY0lyjfwx6G0XuiVUBznLvNIdstLHLcRxkkeXw1HlDafljTL1uwDkoinvgw6o2QXg)Q3fbOJtFxsuEUGvewx6qzkw6w0SWR5dikdGJBSyikEb(IqXssBrZcVMpGOmaoUfii7fXca3WWyJF17Ia0XPNv(P2ran24x9UiaDC6zkDWV6DnOorHTyq8GBewIk8xpaewx6GF1LHdSqqhjZkVXg)Q3fbOJtKoMoKCbc7B3tXHYI5Osoaewx6qGscKmXqueyshthKjwCT4W(adh2tzkw6(zLFQDeWnwmefVWd)3n92aS2pR8tTJaUfii7fzwbcYErGzJn(vVlcqhNCqWMYkc7B3tXHYI5Osoaewx6qGGSxelSeWWH9uMILUFw5NAhbCJfdrXl8W)DtVnaR9Zk)u7iGBbcYErMvGGSxey2yJF17Ia0XjheSPSIW6shktXs3EPOOy64BqOyI6DTXIHO4fy(vVR9pXnza1uD71qI6ZNuGfii7fXIBSGvVRzsoByySXV6Dra640pXnza1ufwx6aoSI62ljuumDZV6Yq4H3kQBiktSoHG2T5xDzimdmPJPdYelUZEyFJn(vVlcqhNEMsh8RExdQtuylgep(lXyJF17Ia0XPFIRcPJlc2LKlqJn(vVlcqhNiFhl8A(qDDcn24x9UiaDC6IVdYQxZhqnvn24x9UiaDCAIL1pSVDpfhklMJk5aqyDPJBRBheSPSIBbcYErM9262bbBkR4(gly17AMKZggWdV9uMILU9srrX0X3GqXe17AJfdrXRXg)Q3fbOJtoOvSUEnF8SYev0wNqJn(vVlcqhNiDmDiA1yJF17Ia0XPjww)W6shI4cLAXCC3xXGmXaKoAPHoHd7aDbawwSr5wSB1kEn24x9UiaDCsglCgIIWwmiEyTB6G0X0bzIfxcSYyAmEWV6YWbwiOJKzbe4VB6TbyTNyz9Vfii7fXIdaLd8WdfljTfUgZ0rlneXETJTcSYuS0TG9A0sJFIBIXg)Q3fbOJtFxsuEUGvewx6akwsAdXpaCfSKUVnalGjDmDqMyXD2da3WygKZ2sZKYuS0TeLjtTmuSXIHO4fy7jJfodrXT1UPdshthKjwCjgB8RExeGoo9tCtgqnvH1LoSI62ljuumDZV6Yq4HhkwsAlyVgT04N4MSfii7fz2Nj6qDq0yJF17Ia0XPFIBYaQPkSU0buSK0gIFa4kyjDhBfy7jJfodrXT1UPdshthKjwCjgB8RExeGoo9tCtgqnvH1LouMILUrbF9NvVlGTNmw4mef3w7MoiDmDqMyXLa8fHILK2OGV(ZQ31wGGSxelEMOd1brJn(vVlcqhNit8TbiuSOG1LoSNmw4mef3w7MoiDmDqMyXLap8KoMoitS4o7H93WWyJF17Ia0XPFIBYaQPkSU0bPJPdYelUZAPnmm24x9UiaDC6N4MmGAQcRlDa1ecWs(8jDiqq2lIfWayLfZrDRoio0ECDC2Nj6qDqeivWYq6qDq0yJF17Ia0XPVljkpxWkcRlD8tSyosMfq4HxzXCu3QdIdThxhTy(Fn24x9UiaDCYR3luWkASzSXV6Dr2CJhc2RrlnKCbcRlDyf1TxsOOy6MF1LHadh277MEBaw7jww)BbYx7GhE(vxgoWcbDKmRLGzJn(vVlYMBeOJtKoMoeTASXV6Dr2CJaDCYbTI11R5JNvMOI26eASXV6Dr2CJaDC6N4Qq64IGDj5cewx64262bbBkR4wGGSxKzFMOd1brJn(vVlYMBeOJtoiytzfH9T7P4qzXCujhacRlDWV6YWbwiOJelGbWceK9IybmagoSNYuS09Zk)u7iGBSyikEHh(VB6TbyTFw5NAhbClqq2lYSceK9IaZgB8RExKn3iqhNEMsh8RExdQtuylgep(lXyJF17IS5gb640Zu6GF17AqDIcBXG4bsiy9iXyJF17IS5gb640elRFyF7EkouwmhvYbGW6sh8RUmCGfc6iXc7BSXV6Dr2CJaDCsWEnAPHKlqJn(vVlYMBeOJttSS(H9T7P4qzXCujhaASXV6Dr2CJaDC6IVdYQxZhqnvn24x9UiBUrGoo517fkyfH1LouMILULCbo46oGeoir7c3yXqu8cmuSK0gIFa4kyjDhBfyshthKjwCTagZGC2Ypt8RUmCGfc6iXyJF17IS5gb64ePJPdjxGgB8RExKn3iqhN(UKO8CbRiSU0buSK0gIFa4kyjDFBawgB8RExKn3iqhNit8TbiuSOG1Louwmh19eYuDAB9vlKxogB8RExKn3iqhNCqWMYkASXV6Dr2CJaDCI8DSWR5d11j0yJF17IS5gb64KxVxOGv0yZyJF17IS)l5iMGdxrqylgepit8TbiEhTaA0sdTfGyPW6shF30BdWAtIbb7A4LekkMUfii7fXclbp8qnHaS6G4q7X1rlSV8gB8RExK9FjaDCIedc21Wljuum1yJF17IS)lbOJtxwaadshthErugYPUAhSU0Hvu3EjHIIPB(vxgcp8qnHa83n92aS2KyqWUgEjHIIPBbcYErgOLBfFfVZQoio0ECD0yJF17IS)lbOJtwB17cwx6WkQBVKqrX0n)Qldn24x9Ui7)sa64eekiOaa8AoSU0Hvu3EjHIIPB(vxgASXV6Dr2)La0XjiA33HuSWoyDPdROU9scfft38RUm0yJF17IS)lbOJtsUaHODFH1LoSI62ljuumDZV6YqJn(vVlY(VeGooftWHRiibwx6WkQBVKqrX0n)QldHhEOMqawDqCO946OfYdOXMXg)Q3fzpXY6)47sIYZfSIW6shqXssBi(bGRGL09TbybmPJPdYelUZEaiWKoMoitS4AXH9n24x9Ui7jww)aDCI0X0HKlqyDPJNj6qDq0Ijww)dbcYErm24x9Ui7jww)aDC6IVdYQxZhqnvH1LoEMOd1brlMyz9peii7fbyshtH86UPiFhq2nqlNbTsXnwmefVgB8RExK9elRFGoor(ow418H66ecRlD8mrhQdIwmXY6Fiqq2lIXg)Q3fzpXY6hOJtoiytzfH1LouMILU9srrX0X3GqXe17AJfdrXlWceK9IyXnwWQ31mjNnmGhE7PmflD7LIIIPJVbHIjQ31glgIIxGfOKajtmefn24x9Ui7jww)aDC6N4MmGAQcRlD8mrhQdIwmXY6Fiqq2lIXg)Q3fzpXY6hOJtKj(2aekwugB8RExK9elRFGoo517fkyfH1LoEMOd1brlMyz9peii7fjdeR4NrKFMHZutnta]] )


end
