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


    spec:RegisterPack( "Destruction", 20220406, [[dOKHXaqikv8iIQYMicFIivgfrsofruTkLc1RaOzbOUfrv1Uu0VurggrIJbilJsYZukyAePCnIiBJiv9naiJJikDoIOyDevH5rj19uH9Pu0bjsQwOkQhsuLAIuQKCrIQKncav(iLkP6KkfsRKszMkfIDQa)eaQAPuQKYtfmvf0wbGIVsKuASevr7v0FfAWk5WOwmOESQMSkDzKndYNvknALQtt1QbGsVgamBc3gODl53snCkXXPujwouphY0jDDfA7eLVdGgpLk15Pu16jskMprL9tXjq5WmCzLYbwjfRSskstks)eijJvsZkPpdQ9wOmyHFaG3szOyqkd2vesXJV6DLblS9IMV5WmG6r8tzyxvli5XPtBDDFeE(n4jKdoky176XmKEc5G)Pmap6cDJwjCgUSs5aRKIvwjfPjfPFcKKXkPz1gYapQ7nodbhuENHD)EPkHZWLqFgSRiKIhF17YSKAzSOFaWytQBb7cZs6b2SSskwzLXMXM8ENRTesEySj)MfaobH2FmdPNaW0cwDbzwHwiJk1SEUEseDiZ635AlDnlTnlVucJhTOrhAASj)MLuxw7xZczHbb9ARzTrbbBbR0mdchPOCyg2zz9NdZbaLdZavmSGU55m8yxjSZzaEecAcZpaCXmKoVnalZscZc1JIiANXxZAZdZciZscZc1JIiANXxZY6dZsAzGF17kdFxqcElMvk1CGv5WmqfdlOBEodp2vc7CgEgPr1bjZYAZANL1FetGSxOmWV6DLbupkIqoMsnhSHCygOIHf0npNHh7kHDodpJ0O6GKzzTzTZY6pIjq2lKzjHzH6rbSx3PG4Be2(iz3mOfbnPIHf0nd8RExz4sVdYQxBJWTqtnhiTCygOIHf0npNHh7kHDodpJ0O6GKzzTzTZY6pIjq2lug4x9UYa67rSxBJQR7uQ5ajLdZavmSGU55m8yxjSZzqzbv60lLWflIFdcpIuVRjvmSGUMLeMfMazVqML1M1DeZQ3LzTXMLuMsYSKtoZYoMLYcQ0PxkHlwe)geEePExtQyybDnljmlmbHj0odlOmWV6DLbheSfSsPMdK(CygOIHf0npNHh7kHDodpJ0O6GKzzTzTZY6pIjq2lug4x9UYWVZnkc3cn1CaakhMb(vVRmG25Bdq4rCLbQyybDZZPMdKS5WmqfdlOBEodp2vc7CgEgPr1bjZYAZANL1FetGSxOmWV6DLbVEVimRuQPMbly6BqywZH5aGYHzGkgwq38Cg4x9UYaejI3g0lw9UYWLqp2TOExzqEz30pQ01SGjOgtM13GWSAwW0wVqtZsQ)pzrrMv1L8VZyqOrHzXV6DHmRUe2pZWJDLWoNb1bjZAtZskMLeMLDmllKozHlJsnhyvomd8RExzancc2v0bTKbQyybDZZPMd2qomduXWc6MNZqXGug0gKInueSlKI7ru87cP4Xx9UqzGF17kdAdsXgkc2fsX9ik(DHu84RExOuZbslhMbQyybDZZzOyqkdOwq8okIOhtAuPFVC7YiLb(vVRmGAbX7OiIEmPrL(9YTlJuQ5ajLdZa)Q3vgGeeA)XmKMbQyybDZZPMdK(CygOIHf0npNHh7kHDodklOsNBXoy7yk2qre)yhYFAsfdlOBg4x9UYWwSd2oMInueXp2H8NsnhaGYHzGkgwq38CgkgKYaANVnaPBSXWXgkQngKknd8RExzaTZ3gG0n2y4ydf1gdsLMAoqYMdZa)Q3vgq9Oic5ykduXWc6MNtnhizYHzGF17kdE9ErywPmqfdlOBEo1uZa3uomhauomduXWc6MNZWJDLWoNblKo9cIWflM8RUmYSKWSKkZYoM13T42aSM7SS(NyIV2BwYjNzXV6YOiveOtiZAtZAdMLKNb(vVRmGzVInueYXuQ5aRYHzGF17kdOEueXTMbQyybDZZPMd2qomd8RExzWbTq11RTXNvgP42YoLbQyybDZZPMdKwomduXWc6MNZWJDLWoNHBRtheSfSstmbYEHmRnnRNrAuDqkd8RExz435Qir8sGDb5yk1CGKYHzGkgwq38Cg4x9UYGdc2cwPm8yxjSZzGF1LrrQiqNqML1MLKmljmlmbYEHmlRnljzwsywsLzzhZszbv68zLFH9iWjvmSGUMLCYzwF3IBdWA(SYVWEe4etGSxiZAtZctGSxiZsYZWB)lOOY4TKIYbaLAoq6ZHzGkgwq38Cg4x9UYWZcrKF17kkCKMbHJ0yXGug(lk1CaakhMbQyybDZZzGF17kdpler(vVROWrAgeosJfdszGqiQEcLAoqYMdZavmSGU55mWV6DLHDww)z4XUsyNZa)QlJIurGoHmlRnlPLH3(xqrLXBjfLdak1CGKjhMb(vVRmGzVInueYXugOIHf0npNAoaiPKdZavmSGU55mWV6DLHDww)z4T)fuuz8wsr5aGsnhaeq5WmWV6DLHl9oiRETnc3cnduXWc6MNtnhaKv5WmqfdlOBEodp2vc7CguwqLoHCmf56gHXois7IMuXWc6AwsywWJqqty(bGlMH05OfZscZc1JIiANXxZYAZssML8BwszALzTXMf)QlJIurGoHYa)Q3vg869IWSsPMdaAd5WmWV6DLbupkIqoMYavmSGU55uZbajTCygOIHf0npNHh7kHDodWJqqty(bGlMH05TbyLb(vVRm8Dbj4TywPuZbajPCygOIHf0npNHh7kHDodkJ3s6CNyHUpT8QzzTzzLuYa)Q3vgq78Tbi8iUsnhaK0NdZavmSGU55mWV6DLbheSfSsz4XUsyNZaMGWeANHfugE7FbfvgVLuuoaOuZbabGYHzGF17kdOVhXETnQUUtzGkgwq38CQ5aGKS5WmWV6DLbVEVimRugOIHf0npNAQz4VOCyoaOCygOIHf0npNb(vVRmG25Bdq6gBmCSHIAJbPsZWJDLWoNHVBXTbynrJGGDf9cIWflMycK9czwwBwBWSKtoZcUriZscZsDqkQD86KzzTzjnRYqXGugq78TbiDJngo2qrTXGuPPMdSkhMb(vVRmGgbb7k6feHlwKbQyybDZZPMd2qomduXWc6MNZWJDLWoNblKo9cIWflM8RUmYSKtoZcUriZscZ67wCBawt0iiyxrVGiCXIjMazVqrYUTqVsxZAtZsDqkQD86ug4x9UYWLXaqe1JIOxiLHDHR2NAoqA5WmqfdlOBEodp2vc7CgSq60licxSyYV6YOmWV6DLblT6DLAoqs5WmqfdlOBEodp2vc7CgSq60licxSyYV6YOmWV6DLbycJima412uZbsFomduXWc6MNZWJDLWoNblKo9cIWflM8RUmkd8RExzaw09ncnITp1CaakhMbQyybDZZz4XUsyNZGfsNEbr4Ift(vxgLb(vVRma5ycw09n1CGKnhMbQyybDZZzGF17kdONXOydfHWSs4IfrKIDikdp2vc7CgSJzbpcbnrpJrXgkcHzLWflIif7quuAZrlzOyqkdONXOydfHWSs4IfrKIDik1CGKjhMbQyybDZZzGF17kdONXOydfHWSs4IfrKIDikdp2vc7CgGhHGMONXOydfHWSs4IfrKIDikkT5OfZscZYcPtVGiCXIj)QlJYqXGugqpJrXgkcHzLWflIif7quQ5aGKsomduXWc6MNZWJDLWoNblKo9cIWflM8RUmYSKtoZcUriZscZsDqkQD86KzzTzzfqzGF17kdJik6kbIsn1mCjiEuO5WCaq5WmqfdlOBEodxc9y3I6DLb5LDt)OsxZIKry7nl1bjZs3jZIFTXMLJmlwg7cgwqZmWV6DLbKfsiII(bGuZbwLdZavmSGU55m8yxjSZzyNL1FKF1LrMLeMf)QlJIurGoHmRnnlGmljml(vxgfPIaDczwwBwsYSKFZszbv60licx9KkgwqxZcqZsQmlLfuPtVGiC1tQyybDnljmlLfuPtVucxSi(ni8is9UMuXWc6AwsEgqk2Fnhaug4x9UYWZcrKF17kkCKMbHJ0yXGug2zz9NAoyd5WmqfdlOBEod8RExzasqO9hZqAgESRe25mG6rbSx3PSwWQlOiQfYOsNuXWc6MbVucJhTOrhkdWJqqtzTGvxqrulKrLohTKAoqA5WmqfdlOBEodp2vc7CguwqLoXnJ9ABewWsn0KkgwqxZscZ6sWJqqtCZyV2gHfSudnXei7fYSS2SaAkPmWV6DLHVlibVfZkLAoqs5WmWV6DLHNv(f2JaZavmSGU55uZbsFomduXWc6MNZWJDLWoNb(vxgfPIaDczwBAwwLbKI9xZbaLb(vVRm8Sqe5x9UIchPzq4inwmiLbUPuZbaOCygOIHf0npNb(vVRmG6rreYXugESRe25mGjimH2zybzwsywOEuer7m(AwwFywsZSKWSKkZYoMLYcQ05Zk)c7rGtQyybDnl5KZS(Uf3gG18zLFH9iWjMazVqM1MMfMazVqMLKNH3(xqrLXBjfLdak1CGKnhMbQyybDZZzGF17kdoiylyLYWJDLWoNbmbYEHmlRnRnywsywsLzzhZszbv68zLFH9iWjvmSGUMLCYzwF3IBdWA(SYVWEe4etGSxiZAtZctGSxiZsYZWB)lOOY4TKIYbaLAoqYKdZavmSGU55m8yxjSZzqzbv60lLWflIFdcpIuVRjvmSGUMLeMf)Q31835gfHBHo9kcj8T7QzjHzHjq2lKzzTzDhXS6DzwBSzjLPKYa)Q3vgCqWwWkLAoaiPKdZavmSGU55m8yxjSZzqQmllKo9cIWflM8RUmYSKtoZYcPtybJSStG2p5xDzKzj5MLeMfQhfr0oJVM1MhML0Ya)Q3vg(DUrr4wOPMdacOCygOIHf0npNb(vVRm8Sqe5x9UIchPzq4inwmiLH)IsnhaKv5WmWV6DLHFNRIeXlb2fKJPmqfdlOBEo1CaqBihMb(vVRmG(Ee712O66oLbQyybDZZPMdasA5WmWV6DLHl9oiRETnc3cnduXWc6MNtnhaKKYHzGkgwq38Cg4x9UYWolR)m8yxjSZz4260bbBbR0etGSxiZAtZ6260bbBbR08oIz17YS2yZsktjzwYjNzzhZszbv60lLWflIFdcpIuVRjvmSGUz4T)fuuz8wsr5aGsnhaK0NdZa)Q3vgCqluD9AB8zLrkUTStzGkgwq38CQ5aGaq5WmWV6DLbupkI4wZavmSGU55uZbajzZHzGkgwq38CgESRe25mGhlcQXBPzFXr0odqrSHI6ofTh0Xayz8KSlJUfl0nd8RExzyNL1FQ5aGKm5WmqfdlOBEodTLmGind8RExzqgJDgwqzqglgPmWV6YOiveOtiZAtZciZscZ67wCBawZDww)tmbYEHmlRpmlGKIzjNCMf8ie0e76ilInuep61C0IzjHzPSGkDIzVInu835gnPIHf0ndYyCSyqkdw6wer9OiI2z8fLAoWkPKdZavmSGU55m8yxjSZzaEecAcZpaCXmKoVnalZscZc1JIiANXxZAZdZcOPKml53SKYCdM1gBwklOsNqcgT3Yi8KkgwqxZscZYoMLmg7mSGMw6wer9OiI2z8fLb(vVRm8Dbj4TywPuZbwbuomduXWc6MNZWJDLWoNblKo9cIWflM8RUmYSKtoZcEecAIzVInu835gnXei7fYS20SEgPr1bPmWV6DLHFNBueUfAQ5aRSkhMbQyybDZZz4XUsyNZa8ie0eMFa4IziDoAXSKWSSJzjJXodlOPLUfrupkIODgFrzGF17kd)o3OiCl0uZbwTHCygOIHf0npNHh7kHDodklOsNeMV(ZQ31KkgwqxZscZYoMLmg7mSGMw6wer9OiI2z8fzwsywxcEecAsy(6pRExtmbYEHmlRnRNrAuDqkd8RExz435gfHBHMAoWkPLdZavmSGU55m8yxjSZzWoMLmg7mSGMw6wer9OiI2z8fzwYjNzH6rreTZ4RzT5HzjTPKYa)Q3vgq78Tbi8iUsnhyLKYHzGkgwq38CgESRe25mG6rreTZ4RzTPzTHPKYa)Q3vg(DUrr4wOPMdSs6ZHzGkgwq38CgESRe25ma3iKzjHzb5B31iMazVqML1MLKmljmlLXBjDQoif1oEDYS20SEgPr1bjZcqZsXSmsevhKYa)Q3vg(DUrr4wOPMdScaLdZavmSGU55m8yxjSZz43z8wczwBAwazwYjNzPmElPt1bPO2XRtML1M12)Mb(vVRm8Dbj4TywPuZbwjzZHzGF17kdE9ErywPmqfdlOBEo1utndYimY7khyLuSYkPinPSHmaqgxETfLbPwPUDTbB0b21LhMLznCNmlh0sJvZcQXML0DjiEuOsNzHj7YOJPRzHAqYS4rTbzLUM1VZ1wcnn22iErM1gKhML8UlzewPRzjDOEua71DkpLoZsBZs6q9Oa2R7uEoPIHf0v6mlwnl5fa(nIzjvaz3s(0yBJ4fzwajzKhML8UlzewPRzjDklOsNYtPZS02SKoLfuPt55KkgwqxPZSy1SKxa43iMLubKDl5tJTnIxKzz1gKhML8UlzewPRzjDklOsNYtPZS02SKoLfuPt55KkgwqxPZSKkGSBjFASzSTrbT0yLUMLKml(vVlZs4ifnn2YGfCd5ckdYN8zw2vesXJV6DzwsTmw0paySjFYNzj1TGDHzj9aBwwjfRSYyZyt(KpZsEVZ1wcjpm2Kp5ZSKFZcaNGq7pMH0tayAbRUGmRqlKrLAwpxpjIoKz97CTLUML2MLxkHXJw0Odnn2Kp5ZSKFZsQlR9RzHSWGGET1S2OGGTGvAASzSjFML8YUPFuPRzbtqnMmRVbHz1SGPTEHMMLu)FYIImRQl5FNXGqJcZIF17czwDjSFASXV6DHMwW03GWSEarI4Tb9IvVlGDOd1bPnLIe2XcPtw4YiJn(vVl00cM(geMvapoHgbb7kAHuJn(vVl00cM(geMvaponIOOReiWfdshAdsXgkc2fsX9ik(DHu84RExiJn(vVl00cM(geMvaponIOOReiWfdshOwq8okIOhtAuPFVC7YizSXV6DHMwW03GWSc4XjibH2FmdPgB8RExOPfm9nimRaECAl2bBhtXgkI4h7q(ta7qhklOsNBXoy7yk2qre)yhYFAsfdlORXg)Q3fAAbtFdcZkGhNgru0vce4IbPd0oFBas3yJHJnuuBmivQXg)Q3fAAbtFdcZkGhNq9Oic5yYyJF17cnTGPVbHzfWJtE9ErywjJnJn5ZSKx2n9JkDnlsgHT3SuhKmlDNml(1gBwoYSyzSlyybnn24x9UqhilKqef9dagB8RExOJNfIi)Q3vu4if4IbPJDww)aJuS)6bqa7qh7SS(J8RUmsc(vxgfPIaDcTjqsWV6YOiveOtiRLK8RSGkD6feHREsfdlOlGsLYcQ0PxqeU6jvmSGUsOSGkD6Ls4IfXVbHhrQ31Kkgwqxj3yJF17cb4XjibH2FmdPa7qhOEua71DkRfS6ckIAHmQuG9sjmE0IgDOd4riOPSwWQlOiQfYOsNJwm24x9UqaEC67csWBXSsa7qhklOsN4MXETnclyPgAsfdlORexcEecAIBg712iSGLAOjMazVqwd0usgB8RExiapo9SYVWEeOXg)Q3fcWJtpler(vVROWrkWfdshCtaJuS)6bqa7qh8RUmksfb6eAtRm24x9UqaECc1JIiKJjGF7FbfvgVLu0bqa7qhycctODgwqsG6rreTZ4R1hstcPYoklOsNpR8lShboPIHf0vo5(Uf3gG18zLFH9iWjMazVqBIjq2lKKBSXV6DHa84Kdc2cwjGF7FbfvgVLu0bqa7qhycK9cz9gKqQSJYcQ05Zk)c7rGtQyybDLtUVBXTbynFw5xypcCIjq2l0MycK9cj5gB8RExiapo5GGTGvcyh6qzbv60lLWflIFdcpIuVRjvmSGUsWV6Dn)DUrr4wOtVIqcF7UkbMazVqwFhXS6DTXszkjJn(vVleGhN(DUrr4wOa7qhsLfsNEbr4Ift(vxgjNCwiDclyKLDc0(j)QlJKCjq9OiI2z8DZdPzSXV6DHa840ZcrKF17kkCKcCXG0XFrgB8RExiapo97CvKiEjWUGCmzSXV6DHa84e67rSxBJQR7KXg)Q3fcWJtx6Dqw9ABeUfQXg)Q3fcWJt7SS(b(T)fuuz8wsrhabSdDCBD6GGTGvAIjq2l0M3wNoiylyLM3rmRExBSuMsso5SJYcQ0PxkHlwe)geEePExtQyybDn24x9UqaECYbTq11RTXNvgP42YozSXV6DHa84eQhfrCRgB8RExiapoTZY6hyh6apweuJ3sZ(IJODgGIydf1DkApOJbWY4jzxgDlwORXg)Q3fcWJtYySZWcc4IbPdlDlIOEuer7m(IawglgPd(vxgfPIaDcTjqs8DlUnaR5olR)jMazVqwFaKuKto4riOj21rweBOiE0R5OfjuwqLoXSxXgk(7CJm24x9UqaEC67csWBXSsa7qhWJqqty(bGlMH05TbyjbQhfr0oJVBEa0usYVuMByJvwqLoHemAVLr4jvmSGUsyhzm2zybnT0TiI6rreTZ4lYyJF17cb4XPFNBueUfkWo0HfsNEbr4Ift(vxgjNCWJqqtm7vSHI)o3OjMazVqB(msJQdsgB8RExiapo97CJIWTqb2HoGhHGMW8daxmdPZrlsyhzm2zybnT0TiI6rreTZ4lYyJF17cb4XPFNBueUfkWo0HYcQ0jH5R)S6DjHDKXyNHf00s3IiQhfr0oJVijUe8ie0KW81Fw9UMycK9cz9ZinQoizSXV6DHa84eANVnaHhXfWo0HDKXyNHf00s3IiQhfr0oJVi5Kd1JIiANX3npK2usgB8RExiapo97CJIWTqb2Hoq9OiI2z8DZnmLKXg)Q3fcWJt)o3OiCluGDOd4gHKaY3URrmbYEHSwssOmElPt1bPO2XRtB(msJQdsaQywgjIQdsgB8RExiapo9Dbj4TywjGDOJFNXBj0MajNCkJ3s6uDqkQD86K1B)RXg)Q3fcWJtE9ErywjJnJn(vVl0KB6aZEfBOiKJjGDOdlKo9cIWflM8RUmscPYoF3IBdWAUZY6FIj(AVCYXV6YOiveOtOn3GKBSXV6DHMCtaECc1JIiUvJn(vVl0KBcWJtoOfQUETn(SYif3w2jJn(vVl0KBcWJt)oxfjIxcSlihta7qh3wNoiylyLMycK9cT5ZinQoizSXV6DHMCtaECYbbBbReWV9VGIkJ3sk6aiGDOd(vxgfPIaDczTKKatGSxiRLKesLDuwqLoFw5xypcCsfdlORCY9DlUnaR5Zk)c7rGtmbYEH2etGSxij3yJF17cn5Ma840ZcrKF17kkCKcCXG0XFrgB8RExOj3eGhNEwiI8RExrHJuGlgKoieIQNqgB8RExOj3eGhN2zz9d8B)lOOY4TKIoacyh6GF1LrrQiqNqwlnJn(vVl0KBcWJty2RydfHCmzSXV6DHMCtaECANL1pWV9VGIkJ3sk6aiJn(vVl0KBcWJtx6Dqw9ABeUfQXg)Q3fAYnb4XjVEVimReWo0HYcQ0jKJPix3im2brAx0KkgwqxjGhHGMW8daxmdPZrlsG6rreTZ4R1ss(LY0QnMF1LrrQiqNqgB8RExOj3eGhNq9Oic5yYyJF17cn5Ma8403fKG3IzLa2HoGhHGMW8daxmdPZBdWYyJF17cn5Ma84eANVnaHhXfWo0HY4TKo3jwO7tlVATvsXyJF17cn5Ma84Kdc2cwjGF7FbfvgVLu0bqa7qhycctODgwqgB8RExOj3eGhNqFpI9ABuDDNm24x9UqtUjapo517fHzLm2m24x9UqZ)Iogru0vce4IbPd0oFBas3yJHJnuuBmivkWo0X3T42aSMOrqWUIEbr4IftmbYEHSEdYjhCJqsOoif1oEDYAPzLXg)Q3fA(xeGhNqJGGDf9cIWflm24x9UqZ)Ia840LXaqe1JIOxiLHDHR2dSdDyH0PxqeUyXKF1LrYjhCJqs8DlUnaRjAeeSROxqeUyXetGSxOiz3wOxP7MQdsrTJxNm24x9UqZ)Ia84KLw9Ua2HoSq60licxSyYV6YiJn(vVl08ViapobtyeHbaV2cSdDyH0PxqeUyXKF1LrgB8RExO5FraECcw09ncnIThyh6WcPtVGiCXIj)QlJm24x9UqZ)Ia84eKJjyr3xGDOdlKo9cIWflM8RUmYyJF17cn)lcWJtJik6kbcCXG0b6zmk2qrimReUyrePyhIa2HoSd8ie0e9mgfBOieMvcxSiIuSdrrPnhTySXV6DHM)fb4XPrefDLabUyq6a9mgfBOieMvcxSiIuSdra7qhWJqqt0ZyuSHIqywjCXIisXoefL2C0IewiD6feHlwm5xDzKXg)Q3fA(xeGhNgru0vcebSdDyH0PxqeUyXKF1LrYjhCJqsOoif1oEDYARaYyZyJF17cn3zz9F8Dbj4TywjGDOd4riOjm)aWfZq682aSKa1JIiANX3npascupkIODgFT(qAgB8RExO5olRFapoH6rreYXeWo0XZinQoiz9olR)iMazVqgB8RExO5olRFapoDP3bz1RTr4wOa7qhpJ0O6GK17SS(JycK9cjbQhfWEDNcIVry7JKDZGwe0KkgwqxJn(vVl0CNL1pGhNqFpI9ABuDDNa2HoEgPr1bjR3zz9hXei7fYyJF17cn3zz9d4XjheSfSsa7qhklOsNEPeUyr8Bq4rK6DnPIHf0vcmbYEHS(oIz17AJLYusYjNDuwqLo9sjCXI43GWJi17AsfdlOReycctODgwqgB8RExO5olRFapo97CJIWTqb2HoEgPr1bjR3zz9hXei7fYyJF17cn3zz9d4Xj0oFBacpIlJn(vVl0CNL1pGhN869IWSsa7qhpJ0O6GK17SS(JycK9cLbKf6Zbwj9aOutnt]] )


end
