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


    spec:RegisterPack( "Destruction", 20220315, [[dS0zWaqiqv9iPO0Mav(eOknkPiofLQAvsrLxPk1SaLULuuSlP6xQcdJOIJPkzzus9mkvzAev11uQQTjfv9nPi14uPsoNuK06avrZJsY9uj7tPkhKOsPfQk6HevPMirLkxKOkAJQuP0hvPsrNKOsXkPuMPuK4MGQa7uk8tvQuzPQuPWtfzQkv2QkvQ6RevQASevj7vYFf1GvYHrTyv1JbMSkUm0MjYNvPmALYPPA1GQGETkvmBe3gKDl8BfdNsCCIQWYj8CKMoPRlL2or57Qu14jQKZtPY6bvHMpOy)uC9Q2vPdRy1WA5yT1YXEV2V)6UK)(VQKANfSswyWD4ByLcgcRKChsvrlq9jQKf2oYWNAxLOtRaGvAtvlu45Jh3CDR93bd0dQd1sy1Naiyj9b1HapQ0V1jQCtu)kDyfRgwlhRTwo271(9x3L83VsCRUnIkLCi5DL28ZbJ6xPdsbvsUdPQOfO(eMLCplid4ogBWdybyZSETpSML1YXARn2m2K3BCCdPWtJTMXSUBjiDdiyj9XD)qy1jOzLgImmuZcWbajzxYSaBCCdpMLoMLhkkeTw0Sl1ReXPkT2vPnw2aQDvJx1UkHb)j4PEwjGWvu4CL(Tss9pdUZrWsA)m3hMfCMfDAjz6gloM1ExM1lZcoZIoTKmDJfhZYQlZs(vIbQprLatir4BcwXsRgwx7Qeg8NGN6zLacxrHZvcWunRoeAwwzwBSSbKfie7bTsmq9jQeDAjzjxGLwnSxTRsyWFcEQNvciCffoxjat1S6qOzzLzTXYgqwGqShuZcoZIoTKVhNob5t(BxgLlgYcb7yWFcEQeduFIkDqGdXQh3Y)HOLwnKFTRsyWFcEQNvciCffoxjat1S6qOzzLzTXYgqwGqSh0kXa1NOsuW0k84wwDDdlTASFTRsyWFcEQNvciCffoxjLjyODpuuemjdgOFlv9j6yWFcEml4mlbcXEqnlRmRtRGvFcZQ5ml5033SGbgZc(MLYem0UhkkcMKbd0VLQ(eDm4pbpMfCMLaLeiDJ)eSsmq9jQKdbnewXsRgnFTRsyWFcEQNvciCffoxjat1S6qOzzLzTXYgqwGqSh0kXa1NOsGnEO5)q0sRgnDTRsmq9jQeDJpZ9)wrujm4pbp1ZsRg3vTRsyWFcEQNvciCffoxjat1S6qOzzLzTXYgqwGqSh0kXa1NOsEa8afSILwALSiqWa9zT2vnEv7Qeg8NGN6zLyG6tujjKKpdKhS6tuPdsbc3I6tuj5PCHGwfpM1hLgbAwGb6ZQz9XBEq7MLClaGwuQzft0mBSasQLywmq9jOM1ee76vciCffoxj1HqZApZsoMfCMf8nllO2zIldlTAyDTRsmq9jQeTfcAISdzPsyWFcEQNLwnSxTRsyWFcEQNvkyiSs6aH5rkdnbvftlndMGQIwG6tqReduFIkPdeMhPm0euvmT0mycQkAbQpbT0QH8RDvcd(tWt9SsbdHvIoeK3OzkceOMveSfU8OfReduFIkrhcYB0mfbcuZkc2cxE0ILwn2V2vjgO(evsIG0nGGL0kHb)j4PEwA1O5RDvcd(tWt9SsaHROW5kPmbdTFt4qJlW8iLPmq4soa7yWFcEQeduFIkDt4qJlW8iLPmq4soalTA001UkHb)j4PEwPGHWkr34ZCpEYJ4NhPSocim0kXa1NOs0n(m3JN8i(5rkRJacdT0QXDv7QeduFIkrNwswYfyLWG)e8uplTA0uRDvIbQprL8a4bkyfReg8NGN6zPLwjEWAx14vTRsyWFcEQNvciCffoxjlO29qcfbt6mqDzOzbNz1eZc(MfygYzUp6BSSb0fiFSZSGbgZIbQldZyGqosnR9ml7zw2Vsmq9jQKG9ipszjxGLwnSU2vjgO(evIoTKSy0kHb)j4PEwA1WE1UkHb)j4PEwjGWvu4CLoJ2DiOHWk2fie7b1S2ZSamvZQdHvIbQprLaBCeijFqOjKCbwA1q(1UkHb)j4PEwjgO(evYHGgcRyLacxrHZvsGqShuZYkZAFZcoZQjMf8nlLjyODaRmGyhfQJb)j4XSGbgZcmd5m3hDaRmGyhfQlqi2dQzTNzjqi2dQzz)kbSdqWSYIBOsRgVkTASFTRsyWFcEQNvIbQprLamHKzG6tKjovReXPAoyiSsGdT0QrZx7Qeg8NGN6zLyG6tujatizgO(ezIt1krCQMdgcResPyaqAPvJMU2vjm4pbp1ZkXa1NOsBSSbujGWvu4CLyG6YWmgiKJuZYkZs(vcyhGGzLf3qLwnEvA14UQDvIbQprLeSh5rkl5cSsyWFcEQNLwnAQ1UkHb)j4PEwjgO(evAJLnGkbSdqWSYIBOsRgVkTA8so1UkHb)j4PEwjGWvu4CLAIzrNwY3JtNG8j)TlJYfdzHGDm4pbpMfmWywW3SuMGH2LCbM54K)chIQtGDm4pbpML9ReduFIkDqGdXQh3Y)HOLwnE9Q2vjm4pbp1ZkbeUIcNRKYem0UKlWmhN8x4quDcSJb)j4XSGZS(Tss9pdUZrWsAV1IzbNzrNwsMUXIJzzLzTVz1mMLC6wBwnNzXa1LHzmqihPvIbQprL8a4bkyflTA8Y6AxLyG6tuj60sYsUaReg8NGN6zPvJx2R2vjm4pbp1ZkbeUIcNR0VvsQ)zWDocws7N5(Osmq9jQeycjcFtWkwA14L8RDvcd(tWt9SsaHROW5kPS4gQ9nKj6w3cqnlRmlRLtLyG6tuj6gFM7)TIO0QXR9RDvcd(tWt9SsaHROW5kbFZQjMLYem0UKlWmhN8x4quDcSJb)j4XSGbgZszcgA3djuethd(tWJzz)kXa1NOsuW0k84wwDDdlTA8Q5RDvcd(tWt9SsaHROW5kbFZQjMLYem0UKlWmhN8x4quDcSJb)j4XSGbgZszcgA3djuethd(tWJzz)kXa1NOsoKfmoECldyLPQySSHLwnE101UkXa1NOsEa8afSIvcd(tWt9S0sRe4qRDvJx1UkHb)j4PEwjgO(evIUXN5E8KhXppszDeqyOvciCffoxjWmKZCF0PTqqtK9qcfbt6ceI9GAwwzw2ZSGbgZ6puQzbNzPoeM1jFC0SSYSKV1vkyiSs0n(m3JN8i(5rkRJacdT0QH11UkXa1NOs0wiOjYEiHIGjvcd(tWt9S0QH9QDvcd(tWt9SsaHROW5kzb1UhsOiysNbQldnlyGXS(dLAwWzwGziN5(OtBHGMi7HekcM0fie7bnJYLfeO4XS2ZSuhcZ6KpowjgO(ev6WI7KPtlj7bv5VtC1UsRgYV2vjm4pbp1ZkbeUIcNRKfu7EiHIGjDgOUmSsmq9jQKLr9jkTASFTRsyWFcEQNvciCffoxjlO29qcfbt6mqDzyLyG6tuPpkOO4oECR0QrZx7Qeg8NGN6zLacxrHZvYcQDpKqrWKoduxgwjgO(ev6tM5KLAf2vA1OPRDvcd(tWt9SsaHROW5kzb1UhsOiysNbQldReduFIkj5c8tM5uA14UQDvcd(tWt9SsaHROW5kzb1UhsOiysNbQldnlyGXS(dLAwWzwQdHzDYhhnlRmlRFvjgO(evQLIzxriAPLwPdkXTeT2vnEv7Qeg8NGN6zLoifiClQprLKNYfcAv8ywOmuyNzPoeAw6gAwmqhHz5uZILXoH)eSxjgO(evIAbjKmza3P0QH11UkHb)j4PEwjGWvu4CL2yzdiZa1LHMfCMfduxgMXaHCKAw7zwVml4mlgOUmmJbc5i1SSYS23SAgZszcgA3djuethd(tWJz92SAIzPmbdT7HekIPJb)j4XSGZSuMGH29qrrWKmyG(Tu1NOJb)j4XSSFLOQWbA14vLyG6tujatizgO(ezIt1krCQMdgcR0glBaLwnSxTRsyWFcEQNvIbQprLKiiDdiyjTsaHROW5krNwY3Jtx2qy1jyMoezyODm4pbpvYdffIwlA2LQ0VvsQlBiS6emthImm0ERLsRgYV2vjm4pbp1ZkbeUIcNRKYem0UyyHh3YFcdpIDm4pbpMfCM1b)TssDXWcpUL)egEe7ceI9GAwwzwV67xjgO(evcmHeHVjyflTASFTRsmq9jQeGvgqSJcvjm4pbp1ZsRgnFTRsyWFcEQNvciCffoxjgOUmmJbc5i1S2ZSSUsuv4aTA8Qsmq9jQeGjKmduFImXPALiovZbdHvIhS0Qrtx7Qeg8NGN6zLyG6tuj60sYsUaReq4kkCUscusG0n(tqZcoZIoTKmDJfhZYQlZs(MfCMvtml4BwktWq7awzaXokuhd(tWJzbdmMfygYzUp6awzaXokuxGqShuZApZsGqShuZY(vcyhGGzLf3qLwnEvA14UQDvcd(tWt9Ssmq9jQKdbnewXkbeUIcNRKaHypOMLvML9ml4mRMywW3SuMGH2bSYaIDuOog8NGhZcgymlWmKZCF0bSYaIDuOUaHypOM1EMLaHypOML9ReWoabZklUHkTA8Q0QrtT2vjm4pbp1ZkbeUIcNRKYem0UhkkcMKbd0VLQ(eDm4pbpMfCMfduFIoyJhA(peT7rwI432uZcoZsGqShuZYkZ60ky1NWSAoZso99ReduFIk5qqdHvS0QXl5u7Qeg8NGN6zLacxrHZvQjMLfu7EiHIGjDgOUm0SGbgZYcQ9pHPw2qi76mqDzOzzFZcoZIoTKmDJfhZAVlZs(vIbQprLaB8qZ)HOLwnE9Q2vjm4pbp1ZkXa1NOsaMqYmq9jYeNQvI4unhmewjWHwA14L11UkXa1NOsGnocKKpi0esUaReg8NGN6zPvJx2R2vjgO(evIcMwHh3YQRByLWG)e8uplTA8s(1UkXa1NOshe4qS6XT8FiALWG)e8uplTA8A)AxLWG)e8upReduFIkTXYgqLacxrHZv6mA3HGgcRyxGqShuZApZ6mA3HGgcRy)0ky1NWSAoZso99nlyGXSGVzPmbdT7HIIGjzWa9BPQprhd(tWtLa2biywzXnuPvJxLwnE181UkXa1NOsoKfmoECldyLPQySSHvcd(tWt9S0QXRMU2vjgO(evIoTKSy0kHb)j4PEwA141Dv7Qeg8NGN6zLacxrHZvs0gO0iUH95iY0n(EsEKY6gMTdYfWdzrhLhTUfl4Psmq9jQ0glBaLwnE1uRDvcd(tWt9SsJLkrrTsmq9jQKmw48NGvsgtAXkXa1LHzmqihPM1EM1lZcoZcmd5m3h9nw2a6ceI9GAwwDzwVKJzbdmM1VvsQlCTLj5rklA9O3AXSGZSuMGH2fSh5rkd24H2XG)e8ujzSihmewjlZqY0PLKPBS4qlTAyTCQDvcd(tWt9SsaHROW5k9BLK6FgCNJGL0(zUpml4ml60sY0nwCmR9UmRx99nRMXSKt3EMvZzwktWq7seMUnYqrhd(tWJzbNzbFZsglC(tWULziz60sY0nwCOvIbQprLatir4BcwXsRgw)Q2vjm4pbp1ZkbeUIcNRKfu7EiHIGjDgOUm0SGbgZ63kj1fSh5rkd24H2fie7b1S2ZSamvZQdHvIbQprLaB8qZ)HOLwnS26AxLWG)e8upReq4kkCUs)wjP(Nb35iyjT3AXSGZSGVzjJfo)jy3YmKmDAjz6glo0kXa1NOsGnEO5)q0sRgwBVAxLWG)e8upReq4kkCUsktWq7OGpoGvFIog8NGhZcoZc(MLmw48NGDlZqY0PLKPBS4qnl4mRd(BLK6OGpoGvFIUaHypOMLvMfGPAwDiSsmq9jQeyJhA(peT0QH1YV2vjm4pbp1ZkbeUIcNRe8nlzSW5pb7wMHKPtljt3yXHAwWaJzrNwsMUXIJzT3Lzj)((vIbQprLOB8zU)3kIsRgwVFTRsyWFcEQNvciCffoxj60sY0nwCmR9ml713Vsmq9jQeyJhA(peT0QH1nFTRsyWFcEQNvciCffoxP)qPMfCMLKFBtZceI9GAwwzw7BwWzwklUHAxDimRt(4OzTNzbyQMvhcnR3MLkyzijRoewjgO(evcSXdn)hIwA1W6MU2vjm4pbp1ZkbeUIcNReyJf3qQzTNz9YSGbgZszXnu7QdHzDYhhnlRmRBGtLyG6tujWese(MGvS0QH13vTRsmq9jQKhapqbRyLWG)e8uplT0sRKmuq9jQgwlhRTwowBDtxP7zr4XnALK7LBVB0qUPXDt4Pzzw72qZYHSmc1SKgHzbVhuIBjk8AwcuE06c8yw0bcnlUvhiwXJzb244gs7gBnfpqZYEWtZsEpHmuO4XSGx60s(EC6Yl41S0XSGx60s(EC6YRog8NGh41Sy1SKN3DnfZQjVKl73n2AkEGM1RMk80SK3tidfkEml4vzcgAxEbVMLoMf8QmbdTlV6yWFcEGxZIvZsEE31umRM8sUSF3yRP4bAwwBp4PzjVNqgku8ywWRYem0U8cEnlDml4vzcgAxE1XG)e8aVMvtEjx2VBSzSj3azzekEmR9nlgO(eMfXPkTBSvjQfeunSU5B6kzrmsobRuZ2SMLChsvrlq9jml5EwqgWDm2A2M1SGhWcWMz9AFynlRLJ1wBSzS1SnRzjV344gsHNgBnBZAwnJzD3sq6gqWs6J7(HWQtqZknezyOMfGdasYUKzb244gEmlDmlpuuiATOzxQBSzS1SML8uUqqRIhZ6JsJanlWa9z1S(4npODZsUfaqlk1SIjAMnwaj1smlgO(euZAcIDDJngO(e0UfbcgOpRxsijFgipy1Nawx6sDiCp5ah8TGANjUm0yJbQpbTBrGGb6Z67Rh0wiOjYwq1yJbQpbTBrGGb6Z67RhTum7kcbBWq4LoqyEKYqtqvX0sZGjOQOfO(euJngO(e0UfbcgOpRVVE0sXSRieSbdHx0HG8gntrGa1SIGTWLhTOXgduFcA3Iabd0N13xpKiiDdiyj1yJbQpbTBrGGb6Z67Rh3eo04cmpszkdeUKdqyDPlLjyO9BchACbMhPmLbcxYbyhd(tWJXgduFcA3Iabd0N13xpAPy2vec2GHWl6gFM7XtEe)8iL1raHHASXa1NG2TiqWa9z991d60sYsUan2yG6tq7weiyG(S((6HhapqbROXMXwZAwYt5cbTkEmlugkSZSuhcnlDdnlgOJWSCQzXYyNWFc2n2yG6tqVOwqcjtgWDm2yG6tqVamHKzG6tKjovHnyi8AJLnayPQWb61lyDPRnw2aYmqDziCmqDzygdeYr6EVGJbQldZyGqosTA)MrzcgA3djuethd(tWZ7MOmbdT7HekIPJb)j4boLjyODpuuemjdgOFlv9j6yWFcESVXgduFc67RhseKUbeSKcRlDrNwY3Jtx2qy1jyMoezyOW6HIcrRfn7sx)wjPUSHWQtWmDiYWq7Twm2yG6tqFF9amHeHVjyfH1LUuMGH2fdl84w(ty4rSJb)j4bUd(BLK6IHfECl)jm8i2fie7b1Qx99n2yG6tqFF9aWkdi2rHm2yG6tqFF9aWesMbQprM4uf2GHWlEqyPQWb61lyDPlgOUmmJbc5iDpRn2yG6tqFF9GoTKSKlqyb2biywzXnuPxVG1LUeOKaPB8NGWrNwsMUXIJvxYhUMaFLjyODaRmGyhfQJb)j4bgyaZqoZ9rhWkdi2rH6ceI9GUNaHypO23yJbQpb991dhcAiSIWcSdqWSYIBOsVEbRlDjqi2dQv2dUMaFLjyODaRmGyhfQJb)j4bgyaZqoZ9rhWkdi2rH6ceI9GUNaHypO23yJbQpb991dhcAiSIW6sxktWq7EOOiysgmq)wQ6t0XG)e8ahduFIoyJhA(peT7rwI432u4eie7b1QtRGvFIMto99n2yG6tqFF9aSXdn)hIcRlD1elO29qcfbt6mqDzimWyb1(NWulBiKDDgOUm0(WrNwsMUXIZExY3yJbQpb991datizgO(ezItvydgcVahQXgduFc67RhGnocKKpi0esUan2yG6tqFF9GcMwHh3YQRBOXgduFc67Rhhe4qS6XT8FiQXgduFc67RhBSSbalWoabZklUHk96fSU01z0UdbnewXUaHypO7DgT7qqdHvSFAfS6t0CYPVpmWaFLjyODpuuemjdgOFlv9j6yWFcEm2yG6tqFF9WHSGXXJBzaRmvfJLn0yJbQpb991d60sYIrn2yG6tqFF9yJLnayDPlrBGsJ4g2NJit347j5rkRBy2oixapKfDuE06wSGhJngO(e03xpKXcN)ee2GHWllZqY0PLKPBS4qHvgtAXlgOUmmJbc5iDVxWbMHCM7J(glBaDbcXEqT66LCGbMFRKux4AltYJuw06rV1cCktWq7c2J8iLbB8qn2yG6tqFF9amHeHVjyfH1LU(Tss9pdUZrWsA)m3hWrNwsMUXIZExV673mYPBVMtzcgAxIW0Trgk6yWFcEGd(YyHZFc2TmdjtNwsMUXId1yJbQpb991dWgp08FikSU0Lfu7EiHIGjDgOUmegy(TssDb7rEKYGnEODbcXEq3dWunRoeASXa1NG((6byJhA(pefwx663kj1)m4ohblP9wlWbFzSW5pb7wMHKPtljt3yXHASXa1NG((6byJhA(pefwx6szcgAhf8XbS6tah8LXcN)eSBzgsMoTKmDJfhkCh83kj1rbFCaR(eDbcXEqTcWunRoeASXa1NG((6bDJpZ9)wraRlDbFzSW5pb7wMHKPtljt3yXHcdm0PLKPBS4S3L877BSXa1NG((6byJhA(pefwx6IoTKmDJfN9SxFFJngO(e03xpaB8qZ)HOW6sx)HsHtYVTPzbcXEqTAF4uwCd1U6qywN8XX9amvZQdHVvbldjz1HqJngO(e03xpatir4BcwryDPlWglUH09EbdmklUHAxDimRt(4Ov3ahJngO(e03xp8a4bkyfn2m2yG6tq78Gxc2J8iLLCbcRlDzb1UhsOiysNbQldHRjWhmd5m3h9nw2a6cKp2bdmmqDzygdeYr6E2Z(gBmq9jODEW3xpOtljlg1yJbQpbTZd((6byJJaj5dcnHKlqyDPRZODhcAiSIDbcXEq3dWunRoeASXa1NG25bFF9WHGgcRiSa7aemRS4gQ0RxW6sxceI9GA1(W1e4RmbdTdyLbe7OqDm4pbpWadygYzUp6awzaXokuxGqSh09eie7b1(gBmq9jODEW3xpamHKzG6tKjovHnyi8cCOgBmq9jODEW3xpamHKzG6tKjovHnyi8cPumai1yJbQpbTZd((6XglBaWcSdqWSYIBOsVEbRlDXa1LHzmqihPwjFJngO(e0op47Rhc2J8iLLCbASXa1NG25bFF9yJLnayb2biywzXnuPxVm2yG6tq78GVVECqGdXQh3Y)HOW6sxnHoTKVhNob5t(BxgLlgYcb7yWFcEGbg4RmbdTl5cmZXj)foevNa7yWFcESVXgduFcANh891dpaEGcwryDPlLjyODjxGzoo5VWHO6eyhd(tWdC)wjP(Nb35iyjT3Abo60sY0nwCSA)MroDRBogOUmmJbc5i1yJbQpbTZd((6bDAjzjxGgBmq9jODEW3xpatir4BcwryDPRFRKu)ZG7CeSK2pZ9HXgduFcANh891d6gFM7)TIawx6szXnu7Bit0TUfGAL1YXyJbQpbTZd((6bfmTcpULvx3qyDPl43eLjyODjxGzoo5VWHO6eyhd(tWdmWOmbdT7HekIPJb)j4X(gBmq9jODEW3xpCilyC84wgWktvXyzdH1LUGFtuMGH2LCbM54K)chIQtGDm4pbpWaJYem0UhsOiMog8NGh7BSXa1NG25bFF9WdGhOGv0yZyJbQpbTdo0RwkMDfHGnyi8IUXN5E8KhXppszDeqyOW6sxGziN5(OtBHGMi7HekcM0fie7b1k7bdm)HsHtDimRt(4OvY3AJngO(e0o4qFF9G2cbnr2djuemXyJbQpbTdo03xpoS4oz60sYEqv(7exTdwx6YcQDpKqrWKoduxgcdm)HsHdmd5m3hDAle0ezpKqrWKUaHypOzuUSGafp7PoeM1jFC0yJbQpbTdo03xpSmQpbSU0Lfu7EiHIGjDgOUm0yJbQpbTdo03xp(OGII74XnyDPllO29qcfbt6mqDzOXgduFcAhCOVVE8jZCYsTc7G1LUSGA3djuemPZa1LHgBmq9jODWH((6HKlWpzMdSU0Lfu7EiHIGjDgOUm0yJbQpbTdo03xpAPy2veIcRlDzb1UhsOiysNbQldHbM)qPWPoeM1jFC0kRFzSzSXa1NG23yzd4cmHeHVjyfH1LU(Tss9pdUZrWsA)m3hWrNwsMUXIZExVGJoTKmDJfhRUKVXgduFcAFJLnG3xpOtljl5cewx6cWunRoeA1glBazbcXEqn2yG6tq7BSSb8(6XbboeRECl)hIcRlDbyQMvhcTAJLnGSaHypOWrNwY3JtNG8j)TlJYfdzHGDm4pbpgBmq9jO9nw2aEF9GcMwHh3YQRBiSU0fGPAwDi0Qnw2aYceI9GASXa1NG23yzd491dhcAiSIW6sxktWq7EOOiysgmq)wQ6t0XG)e8aNaHypOwDAfS6t0CYPVpmWaFLjyODpuuemjdgOFlv9j6yWFcEGtGscKUXFcASXa1NG23yzd491dWgp08FikSU0fGPAwDi0Qnw2aYceI9GASXa1NG23yzd491d6gFM7)TIWyJbQpbTVXYgW7RhEa8afSIW6sxaMQz1HqR2yzdilqi2dAPLwfa]] )


end
