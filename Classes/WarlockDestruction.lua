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

                return app + floor( t - app )
            end,

            interval = 0.5,
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
        },

        immolate = {
            aura = "immolate",
            debuff = true,

            last = function ()
                local app = state.debuff.immolate.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return state.debuff.immolate.tick_time end,
            value = 0.1
        },

        blasphemy = {
            aura = "blasphemy",

            last = function ()
                local app = state.buff.blasphemy.applied
                local t = state.query_time

                return app + floor( t - app )
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


    spec:RegisterPack( "Destruction", 20211207, [[dOK(1aqiIsEKev1Mik(eLsPrrjvNIsjRsIk9kvjZcu6wsuXUK0VuPAykvCmvklJsYZafmnkPCnqrBJsP6BeLY4avW5avuRtIQ08OuCpvY(uQ0bjkvzHQs9qqfQjsuQ0fbfIncQq6Jsuf5KsufwjLQzckKANsKFkrvulLOurpvKPQuARGkeFLOuvJLOuH9k1Ff1GvXHrTyqEmWKvYLH2mr(SsXOvfNwy1GcjVguPzJ42QQDt1VvmCIQJtPuSCcphPPt66sy7uIVlrz8Gc15bvTEqfz(kvTFkUV1B70IvSlz1owD7Mv7iBvRGbRGZwt26KcVCStYzaC5nyNC(JDs2fPQOaOX4Dsodpz4vVTt0PqaWo9OQCA59(9nH(uavbZ)on(fewJXbcwsVtJp4ENGkcIwE4nuNwSIDjR2XQB3SAhzRAfmyfC2Aw1jUqFgrNsXhoUtpXAHEd1PfsbDs2fPQOaOX4MJSplidaUg7Lgl4hcfMZnyawZXQDS6MXUXoC8d7BqA51yVCmh4OeK(aeSKEhoYqyniO5KgIf0vZbWoaj5qYCapSVbxMJoMt4kkefY1Civ7ejOkT32jKsrhG0EBx6wVTtmqJX7uzJGSSGHNfiDC2byNqNHi4QF3AxYQEBNyGgJ3Pp(hb85rktkaXkVei)PDcDgIGR(DRDjyO32jgOX4DcImZkpsz9bZOJF47e6mebx97w7swR32jgOX4DAtblwb75rkZWjum6tNqNHi4QF3AxcM92oXangVtIqUCcMdptLZaStOZqeC1VBTlz792oXangVtsdOGIRmdNqrOygc5FNqNHi4QF3Axs26TDIbAmENKxicj4dFtgIWuTtOZqeC1VBTlbh6TDcDgIGR(DNaIqrrWDszXguRpit0NSCGAo7AoWHDmN97nhLfBqT(GmrFYYbQ5yJ5y1oMZ(9MJuS5rZc8ZHtnhBmhR2XC2V3CuwSb1QgFmRtwoqZwTJ5SR5yTD6ed0y8ojqwE4BYse(J0w7sW5EBNyGgJ3jW4a0vbR4klr4p2j0zicU63T2LUTtVTtOZqeC1V7eqekkcUtqfssvbcGlbP0S0iayvGFoCANyGgJ3j9bZfo0u4RS0iayRT2Ph2Ya6TDPB92oHodrWv)UtarOOi4obvijvHyaCxcwsRRPm3CKXCOtbjtFyXYC29YCUzoYyo0PGKPpSyzo2CzowRtmqJX7eyCjcVrWk2AxYQEBNqNHi4QF3jGiuueCNamvZA8rZXgZ5HTmGSa)C40oXangVt0PGKLcb2Axcg6TDcDgIGR(DNaIqrrWDcWunRXhnhBmNh2YaYc8ZHtnhzmh6uqGcFvjiVYqWNrym)LtWk6mebxDIbAmENwii(Sg(Mm0q0w7swR32j0zicU63Dcicffb3jat1SgF0CSXCEyldilWphoTtmqJX7efmfIW3K1qFWw7sWS32j0zicU63Dcicffb3jLjOR1Wvu4mjdMpubvJXROZqeCzoYyoc8ZHtnhBmNvHG1yCZPCnNDQW0C2V3CKL5OmbDTgUIcNjzW8HkOAmEfDgIGlZrgZrGscK(WqeStmqJX7u8)dHvS1UKT3B7e6mebx97obeHIIG7eGPAwJpAo2yopSLbKf4NdN2jgOX4Dc8WdndneT1UKS1B7ed0y8orF41uguHW7e6mebx97w7sWHEBNqNHi4QF3jGiuueCNamvZA8rZXgZ5HTmGSa)C40oXangVtHdchfSIT2ANKlqW8HyT32LU1B7e6mebx97oXangVtsijVMF4SgJ3PfsbIqUgJ3jyeymckuCzoqO0iqZbmFiwnhiCt40Q5i7baOCLAo(4LZdl(sfeZHbAmo1CgNaFTtarOOi4oPXhnNDnNDmhzmhzzoYrTYKWc2AxYQEBNyGgJ3jAX)pEo(Y7e6mebx97w7sWqVTtOZqeC1V7KZFSt68X8iL)JtvXuqZGXPQOaOX40oXangVt68X8iL)JtvXuqZGXPQOaOX40w7swR32j0zicU63DY5p2j6qq(HMPiqGAwrWJh2McStmqJX7eDii)qZueiqnRi4XdBtb2AxcM92oXangVtseK(aeSK2j0zicU63T2LS9EBNqNHi4QF3jGiuueCNuMGUw3iI)ecmpszkdeHuaWk6mebxDIbAmEN2iI)ecmpszkdeHuaWw7sYwVTtOZqeC1V7KZFSt0hEnLHR8iGYJuwhXhDTtmqJX7e9Hxtz4kpcO8iL1r8rxBTlbh6TDIbAmENOtbjlfcStOZqeC1VBTlbN7TDIbAmENcheokyf7e6mebx97wBTt8G92U0TEBNqNHi4QF3jGiuueCNKJAnCju4mPYanSGMJmMJ1nhzzoGziRPmV(WwgqvG8cEZz)EZHbAybZOJ)aPMZUMdmyo2QtmqJX7KGdppszPqGT2LSQ32jgOX4DIofKSy0oHodrWv)U1Uem0B7e6mebx97obeHIIG70A0A8)dHvSkWpho1C21CamvZA8XoXangVtGh2DKKx4FCPqGT2LSwVTtOZqeC1V7ed0y8of))qyf7eqekkcUtc8ZHtnhBmhyAoYyow3CKL5OmbDTcyLbe4P)k6mebxMZ(9MdygYAkZRawzabE6VkWpho1C21Ce4NdNAo2Qta4bemRSydQ0U0Tw7sWS32j0zicU63DIbAmENamHKzGgJNjbv7ejOA25p2jWI2AxY27TDcDgIGR(DNyGgJ3jatizgOX4zsq1orcQMD(JDcPu0biT1UKS1B7e6mebx97oXangVtpSLb0jGiuueCNyGgwWm64pqQ5yJ5yTobGhqWSYInOs7s3ATlbh6TDIbAmENeC45rklfcStOZqeC1VBTlbN7TDcDgIGR(DNyGgJ3Ph2Ya6eaEabZkl2GkTlDR1U0TD6TDcDgIGR(DNaIqrrWDY6MdDkiqHVQeKxzi4ZimM)YjyfDgIGlZz)EZrwMJYe01QuiWm7RmKi(uDCSIodrWL5yRoXangVtleeFwdFtgAiARDPB36TDcDgIGR(DNaIqrrWDszc6AvkeyM9vgseFQoowrNHi4YCKXCGkKKQqmaUlblP1c5MJmMdDkiz6dlwMJnMdmnNYXC2PAL5uUMdd0WcMrh)bs7ed0y8ofoiCuWk2Ax6Mv92oXangVt0PGKLcb2j0zicU63T2LUbd92oHodrWv)UtarOOi4obvijvHyaCxcwsRRPmVtmqJX7eyCjcVrWk2Ax6M16TDcDgIGR(DNaIqrrWDszXguRpit0NQCGAo2yowTtNyGgJ3j6dVMYGkeERDPBWS32j0zicU63Dcicffb3jzzow3CuMGUwLcbMzFLHeXNQJJv0zicUmN97nhLjOR1WLqHpv0zicUmhB1jgOX4DIcMcr4BYAOpyRDPB2EVTtOZqeC1V7eqekkcUtYYCSU5OmbDTkfcmZ(kdjIpvhhROZqeCzo73BoktqxRHlHcFQOZqeCzo2QtmqJX7u8LJ(k8nzaRmvfJ8hS1U0nzR32jgOX4DkCq4OGvStOZqeC1VBT1obw0EBx6wVTtOZqeC1V7ed0y8orF41ugUYJakpszDeF01obeHIIG7eygYAkZR0I)F8C4sOWzsvGFoCQ5yJ5adMZ(9MJYInOw14JzDYRanhBmhRzvNC(JDI(WRPmCLhbuEKY6i(ORT2LSQ32jgOX4DIw8)JNdxcfot6e6mebx97w7sWqVTtmqJX70IfWntNcsoCQYqbju47e6mebx97w7swR32j0zicU63Dcicffb3j5OwdxcfotQmqdlyNyGgJ3j5JgJ3AxcM92oHodrWv)UtarOOi4ojh1A4sOWzsLbAyb7ed0y8obHckkGB4BATlz792oHodrWv)UtarOOi4ojh1A4sOWzsLbAyb7ed0y8obrMzLLkeW3Axs26TDcDgIGR(DNaIqrrWDsoQ1WLqHZKkd0Wc2jgOX4DskeiezMvRDj4qVTtOZqeC1V7eqekkcUtYrTgUekCMuzGgwqZz)EZrzXguRA8XSo5vGMJnMJv70jgOX4DQGI5qXpT1w70cL4cI2B7s36TDcDgIGR(DNwific5AmENGrGXiOqXL5Gwqb8MJgF0C0h0CyGocZjOMdBHdcdrWANyGgJ3jQCKqYKba3w7sw1B7e6mebx97obeHIIG70dBzazgOHf0CKXCyGgwWm64pqQ5SR5CZCKXCyGgwWm64pqQ5yJ5atZPCmhLjOR1WLqHpv0zicUmNxMJ1nhLjOR1WLqHpv0zicUmhzmhLjOR1Wvu4mjdMpubvJXROZqeCzo2QtuveaTlDRtmqJX7eGjKmd0y8mjOANibvZo)Xo9WwgqRDjyO32j0zicU63DIbAmENKii9biyjTtarOOi4orNccu4RQLHWAqWmDiwqxROZqeC1PWvuikKR5qQtqfssvldH1GGz6qSGUwlK3AxYA92oHodrWv)UtarOOi4oPmbDTkgwe(MmeHHtyfDgIGlZrgZzHqfssvXWIW3KHimCcRc8ZHtnhBmNBvy2jgOX4DcmUeH3iyfBTlbZEBNqNHi4QF3jGiuueCNKL5yDZroQ1WLqHZKkd0WcAoYyoRrRX)pewXQa)C4uZ5L5CZC21CKJAnCju4mPkWpho1CSL5SFV5qLJeswzXguPvaRmGap9Bo7Ao36ed0y8obyLbe4P)w7s2EVTtOZqeC1V7eqekkcUtmqdlygD8hi1C21CSQtuveaTlDRtmqJX7eGjKmd0y8mjOANibvZo)XoXd2Axs26TDcDgIGR(DNyGgJ3j6uqYsHa7eqekkcUtcusG0hgIGMJmMdDkiz6dlwMJnxMJ1mhzmhRBoYYCuMGUwbSYac80FfDgIGlZz)EZbmdznL5vaRmGap9xf4NdNAo7Aoc8ZHtnhB1ja8acMvwSbvAx6wRDj4qVTtOZqeC1V7ed0y8of))qyf7eqekkcUtcusG0hgIGMJmMJ1nhzzoktqxRawzabE6VIodrWL5SFV5aMHSMY8kGvgqGN(Rc8ZHtnNDnhb(5WPMJT6eaEabZkl2GkTlDR1UeCU32j0zicU63Dcicffb3jLjOR1Wvu4mjdMpubvJXROZqeCzoYyomqJXRGhEOzOHO1WZsKyZJAoYyoc8ZHtnhBmNvHG1yCZPCnNDQWStmqJX7u8)dHvS1U0TD6TDcDgIGR(DNyGgJ3jatizgOX4zsq1orcQMD(JDcSOT2LUDR32j0zicU63DIbAmENamHKzGgJNjbv7ejOA25p2jKsrhG0w7s3SQ32jgOX4Dc8WUJK8c)JlfcStOZqeC1VBTlDdg6TDIbAmENOGPqe(MSg6d2j0zicU63T2LUzTEBNyGgJ3PfcIpRHVjdneTtOZqeC1VBTlDdM92oHodrWv)UtmqJX70dBzaDcicffb3P1O14)hcRyvGFoCQ5SR5SgTg))qyfRRcbRX4Mt5Ao7uHP5SFV5ilZrzc6AnCffotYG5dvq1y8k6mebxDcapGGzLfBqL2LU1Ax6MT3B7ed0y8ofF5OVcFtgWktvXi)b7e6mebx97w7s3KTEBNyGgJ3j6uqYIr7e6mebx97w7s3Gd92oHodrWv)UtarOOi4ojkCuAeBW6Sez6dxgjpsz9bZW)dbmkwurBtrixoU6ed0y8o9WwgqRDPBW5EBNqNHi4QF3PrENOO2jgOX4DYclcgIGDYctkWoXanSGz0XFGuZzxZ5M5iJ5aMHSMY86dBzavb(5WPMJnxMZTDmN97nhWmK1uMxPf))45WLqHZKQa)C4uZXMlZ5gmnhzmhLjOR1flGBMofKC4uLHcsOWxrNHi4YCKXCaZqwtzEDXc4MPtbjhovzOGek8vb(5WPMJnxMZnyAo73BoktqxRlwa3mDki5WPkdfKqHVIodrWL5iJ5aMHSMY86IfWntNcsoCQYqbju4Rc8ZHtnhBUmNBW0CKXCSU5aMHSMY8kT4)hphUekCMuf4NdNAo7Aokl2GAvJpM1jVc0C2V3CaZqwtzELw8)JNdxcfotQc8ZHtnNxMdygYAkZR0I)F8C4sOWzsDviyng3C21CuwSb1QgFmRtEfO5yRozHfzN)yNKpdjtNcsM(WIfT1UKv70B7e6mebx97obeHIIG7euHKufIbWDjyjTUMYCZrgZHofKm9HflZz3lZ5wfMMt5yo7uHbZPCnhLjORvjctFglOOIodrWL5iJ5ilZXclcgIGv5ZqY0PGKPpSyr7ed0y8obgxIWBeSIT2LS6wVTtOZqeC1V7eqekkcUtqfss1flGBMofKC4uLHcsOWxlK3jgOX4Dc8WdndneT1UKvw1B7e6mebx97obeHIIG7euHKufIbWDjyjTwi3CKXCKL5yHfbdrWQ8ziz6uqY0hwSOMJmMJSmhLjORvuWRaWAmEfDgIGRoXangVtGhEOzOHOT2LScg6TDcDgIGR(DNaIqrrWDswMJfwemebRYNHKPtbjtFyXIAoYyoktqxROGxbG1y8k6mebxMJmMJ1nNfcvijvrbVcaRX4vb(5WPMJnMdGPAwJpAo73Boqfssviga3LGL0AHCZXwDIbAmENap8qZqdrBTlzL16TDcDgIGR(DNaIqrrWDswMJfwemebRYNHKPtbjtFyXIAo73Bo0PGKPpSyzo7EzowRcZoXangVt0hEnLbvi8w7swbZEBNqNHi4QF3jGiuueCNSU5qNcsM(WIL5S7L5yTkmnNYXC2PAL5uUMdd0WcMrh)bsnhB1jgOX4Dc8WdndneT1UKv2EVTtOZqeC1V7eqekkcUtGhwSbPMZUMZToXangVtGXLi8gbRyRDjRKTEBNyGgJ3PWbHJcwXoHodrWv)U1wBTtwqbngVlz1owDBh48nBVtLXcp8n0oj7l7j7Su5rPYtLxZXC2(GMt8Lpc1CKgH5yBxOexquBR5iqBtriWL5qNpAoCHoFwXL5aEyFdsRg7WOdhnhyO8AoWXJBbfkUmhBlDkiqHVQYoSTMJoMJTLofeOWxvzhv0zicUSTMdRMdms5zy0MJ1VbJTv1y3yV84lFekUmhB3CyGgJBoKGQ0QXENKlgPGGDQ8lFZr2fPQOaOX4MJSplidaUg7LF5BoLgl4hcfMZnyawZXQDS6MXUXE5x(MdC8d7BqA51yV8lFZPCmh4OeK(aeSKEhoYqyniO5KgIf0vZbWoaj5qYCapSVbxMJoMt4kkefY1Civn2n2lFZbgbgJGcfxMdeknc0CaZhIvZbc3eoTAoYEaakxPMJpE58WIVubXCyGgJtnNXjWxn2zGgJtRYfiy(qSEjHK8A(HZAmoSH0LgFC3DKrwYrTYKWcASZangNwLlqW8Hy911DAX)pEwoQg7mqJXPv5cemFiwFDDVGI5qXpSo)XlD(yEKY)XPQykOzW4uvua0yCQXod0yCAvUabZhI1xx3lOyou8dRZF8IoeKFOzkceOMve84HTPan2zGgJtRYfiy(qS(66UebPpablPg7mqJXPv5cemFiwFDDFJi(tiW8iLPmqesbaHnKUuMGUw3iI)ecmpszkdeHuaWk6mebxg7mqJXPv5cemFiwFDDVGI5qXpSo)Xl6dVMYWvEeq5rkRJ4JUASZangNwLlqW8Hy911D6uqYsHan2zGgJtRYfiy(qS(66E4GWrbROXUXE5BoWiWyeuO4YCqlOaEZrJpAo6dAomqhH5euZHTWbHHiy1yNbAmo9IkhjKmzaW1yNbAmo9cWesMbAmEMeufwN)41dBzaWsvra0RBWgsxpSLbKzGgwqzyGgwWm64pq6U3KHbAybZOJ)aP2aZYrzc6AnCju4tfDgIGRxwxzc6AnCju4tfDgIGlzuMGUwdxrHZKmy(qfungVIodrWLTm2zGgJtFDDxIG0hGGLuydPl6uqGcFvTmewdcMPdXc6kSHROquixZH0fuHKu1YqyniyMoelOR1c5g7mqJXPVUUdgxIWBeSIWgsxktqxRIHfHVjdry4ewrNHi4sMfcvijvfdlcFtgIWWjSkWpho1MBvyASZangN(66oGvgqGN(HnKUKL1LJAnCju4mPYanSGYSgTg))qyfRc8ZHtFDBx5OwdxcfotQc8ZHtT1(9u5iHKvwSbvAfWkdiWt)7EZyNbAmo911DatizgOX4zsqvyD(Jx8GWsvra0RBWgsxmqdlygD8hiDxRm2zGgJtFDDNofKSuiqybWdiywzXguPx3GnKUeOKaPpmebLHofKm9HflBUSMmwxwktqxRawzabE6VIodrW1(9GziRPmVcyLbe4P)Qa)C40Df4NdNAlJDgOX40xx3J)FiSIWcGhqWSYInOsVUbBiDjqjbsFyickJ1LLYe01kGvgqGN(ROZqeCTFpygYAkZRawzabE6VkWphoDxb(5WP2YyNbAmo91194)hcRiSH0LYe01A4kkCMKbZhQGQX4v0zicUKHbAmEf8WdndneTgEwIeBEuze4NdNAZQqWAmE5UtfMg7mqJXPVUUdycjZangptcQcRZF8cSOg7mqJXPVUUdycjZangptcQcRZF8cPu0bi1yNbAmo911DWd7osYl8pUuiqJDgOX40xx3PGPqe(MSg6dASZangN(66(cbXN1W3KHgIASZangN(66(dBzaWcGhqWSYInOsVUbBiDTgTg))qyfRc8ZHt3DnAn()HWkwxfcwJXl3DQWC)EzPmbDTgUIcNjzW8HkOAmEfDgIGlJDgOX40xx3JVC0xHVjdyLPQyK)Gg7mqJXPVUUtNcswmQXod0yC6RR7pSLbaBiDjkCuAeBW6Sez6dxgjpsz9bZW)dbmkwurBtrixoUm2zGgJtFDD3clcgIGW68hVKpdjtNcsM(WIffwlmPaVyGgwWm64pq6U3KbmdznL51h2YaQc8ZHtT562o73dMHSMY8kT4)hphUekCMuf4NdNAZ1nykJYe016IfWntNcsoCQYqbju4ROZqeCjdygYAkZRlwa3mDki5WPkdfKqHVkWpho1MRBWC)ELjOR1flGBMofKC4uLHcsOWxrNHi4sgWmK1uMxxSaUz6uqYHtvgkiHcFvGFoCQnx3GPmwhmdznL5vAX)pEoCju4mPkWphoDxLfBqTQXhZ6KxbUFpygYAkZR0I)F8C4sOWzsvGFoC6lWmK1uMxPf))45WLqHZK6QqWAm(Ukl2GAvJpM1jVc0wg7mqJXPVUUdgxIWBeSIWgsxqfssviga3LGL06AkZLHofKm9HfRDVUvHz5StfgkxLjORvjctFglOOIodrWLmYYclcgIGv5ZqY0PGKPpSyrn2zGgJtFDDh8Wdndnef2q6cQqsQUybCZ0PGKdNQmuqcf(AHCJDgOX40xx3bp8qZqdrHnKUGkKKQqmaUlblP1c5YillSiyicwLpdjtNcsM(WIfvgzPmbDTIcEfawJXROZqeCzSZangN(66o4HhAgAikSH0LSSWIGHiyv(mKmDkiz6dlwuzuMGUwrbVcaRX4v0zicUKX6leQqsQIcEfawJXRc8ZHtTbWunRXh3VhQqsQcXa4UeSKwlKBlJDgOX40xx3Pp8AkdQq4WgsxYYclcgIGv5ZqY0PGKPpSyr3VNofKm9HfRDVSwfMg7mqJXPVUUdE4HMHgIcBiDzD6uqY0hwS29YAvywo7uTQCzGgwWm64pqQTm2zGgJtFDDhmUeH3iyfHnKUapSyds39MXod0yC6RR7HdchfSIg7g7mqJXPvEWlbhEEKYsHaHnKUKJAnCju4mPYanSGYyDzbMHSMY86dBzavbYl43VNbAybZOJ)aP7cd2YyNbAmoTYd(66oDkizXOg7mqJXPvEWxx3bpS7ijVW)4sHaHnKUwJwJ)FiSIvb(5WP7cyQM14Jg7mqJXPvEWxx3J)FiSIWcGhqWSYInOsVUbBiDjWpho1gykJ1LLYe01kGvgqGN(ROZqeCTFpygYAkZRawzabE6VkWphoDxb(5WP2YyNbAmoTYd(66oGjKmd0y8mjOkSo)XlWIASZangNw5bFDDhWesMbAmEMeufwN)4fsPOdqQXod0yCALh8119h2YaGfapGGzLfBqLEDd2q6IbAybZOJ)aP2ynJDgOX40kp4RR7co88iLLcbASZangNw5bFDD)HTmaybWdiywzXguPx3m2zGgJtR8GVUUVqq8zn8nzOHOWgsxwNofeOWxvcYRme8zegZF5eSIodrW1(9Yszc6AvkeyM9vgseFQoowrNHi4Ywg7mqJXPvEWxx3dheokyfHnKUuMGUwLcbMzFLHeXNQJJv0zicUKbQqsQcXa4UeSKwlKldDkiz6dlw2aZYzNQvLld0WcMrh)bsn2zGgJtR8GVUUtNcswkeOXod0yCALh811DW4seEJGve2q6cQqsQcXa4UeSKwxtzUXod0yCALh811D6dVMYGkeoSH0LYInOwFqMOpv5a1gR2XyNbAmoTYd(66ofmfIW3K1qFqydPlzzDLjORvPqGz2xzir8P64yfDgIGR97vMGUwdxcf(urNHi4Ywg7mqJXPvEWxx3JVC0xHVjdyLPQyK)GWgsxYY6ktqxRsHaZSVYqI4t1XXk6mebx73RmbDTgUek8PIodrWLTm2zGgJtR8GVUUhoiCuWkASBSZangNwbl6vbfZHIFyD(Jx0hEnLHR8iGYJuwhXhDf2q6cmdznL5vAX)pEoCju4mPkWpho1gyy)ELfBqTQXhZ6KxbAJ1SYyNbAmoTcw0xx3Pf))45WLqHZeJDgOX40kyrFDDFXc4MPtbjhovzOGek8g7mqJXPvWI(66U8rJXHnKUKJAnCju4mPYanSGg7mqJXPvWI(66oekOOaUHVb2q6soQ1WLqHZKkd0WcASZangNwbl6RR7qKzwzPcb8WgsxYrTgUekCMuzGgwqJDgOX40kyrFDDxkeiezMfSH0LCuRHlHcNjvgOHf0yNbAmoTcw0xx3lOyou8tHnKUKJAnCju4mPYanSG73RSydQvn(ywN8kqBSAhJDJDgOX406dBzaxGXLi8gbRiSH0fuHKufIbWDjyjTUMYCzOtbjtFyXA3RBYqNcsM(WILnxwZyNbAmoT(WwgWRR70PGKLcbcBiDbyQM14J28WwgqwGFoCQXod0yCA9HTmGxx3xii(Sg(Mm0quydPlat1SgF0Mh2YaYc8ZHtLHofeOWxvcYRme8zegZF5eSIodrWLXod0yCA9HTmGxx3PGPqe(MSg6dcBiDbyQM14J28WwgqwGFoCQXod0yCA9HTmGxx3J)FiSIWgsxktqxRHROWzsgmFOcQgJxrNHi4sgb(5WP2SkeSgJxU7uH5(9Yszc6AnCffotYG5dvq1y8k6mebxYiqjbsFyicASZangNwFyld411DWdp0m0quydPlat1SgF0Mh2YaYc8ZHtn2zGgJtRpSLb866o9Hxtzqfc3yNbAmoT(WwgWRR7HdchfSIWgsxaMQzn(OnpSLbKf4NdNASBSZangNwrkfDasFDDVSrqwwWWZcKoo7a0yNbAmoTIuk6aK(66(h)Ja(8iLjfGyLxcK)uJDgOX40ksPOdq6RR7qKzw5rkRpygD8dVXod0yCAfPu0bi9119nfSyfSNhPmdNqXOpg7mqJXPvKsrhG0xx3fHC5emhEMkNbOXod0yCAfPu0bi911DPbuqXvMHtOiumdH83yNbAmoTIuk6aK(66U8cribF4BYqeMQg7mqJXPvKsrhG0xx3filp8nzjc)rkSH0LYInOwFqMOpz5aDx4Wo73RSydQ1hKj6twoqTXQD2Vxk28Ozb(5WP2y1o73RSydQvn(ywNSCGMTANDT2og7mqJXPvKsrhG0xx3bJdqxfSIRSeH)OXod0yCAfPu0bi911D9bZfo0u4RS0iaiSH0fuHKuvGa4sqknlncawf4NdN2jQCe0LSY2LTwBTBa]] )


end
