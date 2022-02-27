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


    spec:RegisterPack( "Destruction", 20220227, [[dOuVVaqiIkEKOuSjqLpbQQgLOKoLOeRsuk9kvLMLQQUfLQQDPKFPs1WafDmvvwgrvptuQMgLOUgOkBJsv8nkvPXbQkDoIkX6avfZJsL7Ps2NkfhKOsYcvv8qkrYejQu6IuIOnQsPYhvPuOtsuPyLusZKsKANIIFQsPKLQsPGNkYuLQSvvkf9vIkPglLiSxj)vkdwPomQfRkpgyYQ4YqBMiFwQQrlvonvRwLsPETkLmBe3gKDl8BfdNs54evQwospNW0jDDr12jkFhuy8uQkNNsy9QuQA(Gs7NIRFvVkDyfRmYdt5LhMYlV9UGjmTSC5NLRKAHnSs2yWT4(yLcgcRKClkuAoq9jQKn2cYWNQxLetofGvQtvBc4Z979DTl)Tad0DHdLty1Naqzj9UWHa3R0l3jQCtuVkDyfRmYdt5LhMYlV9UGjmTSC5xL4CTBOvk5qwQk15Ndg1RshuaQKClkuAoq9jmB5AMsgWTmwVD4JMZulmB5TN)MT8WuE5nwnwTuDC0hfWhJv73SVDeu0bOSKE)2CiS6e0StdrggQzd4aGKMlz2Goo6JhZwhZ2dfP0CBAZLwvI4cvu9QuhlBavVkZVQxLWGFe8uFQeG6ksDUsVCjP1Jb36qzjDDgyeMnCMTyYjnrhtpM9nxM9pZgoZwm5KMOJPhZ2UlZ2YvIbQprLatir4(uwXsRmYx9Qeg8JGN6tLauxrQZvcWcTPoeA22z2DSSb0Oie7HOsmq9jQKyYjnjNILwzYE1RsyWpcEQpvcqDfPoxjal0M6qOzBNz3XYgqJIqShcZgoZwm5KNhNfb5t7zrdTpgYgbxyWpcEQeduFIkDqGdXQh9BVHOLwzSC1RsyWpcEQpvcqDfPoxjal0M6qOzBNz3XYgqJIqShIkXa1NOscWKt9OFtDTdlTYaVQxLWGFe8uFQeG6ksDUsktWqxEOinysdmqVCH6tSWGFe8y2Wz2ueI9qy22z2NCkR(eMD2A2WCbpZgwynB5y2ktWqxEOinysdmqVCH6tSWGFe8y2Wz2uuIIIo(rWkXa1NOsoe0qyflTYypvVkHb)i4P(uja1vK6CLaSqBQdHMTDMDhlBankcXEiQeduFIkb64r0EdrlTYyVvVkXa1NOsIo(mW4LtJkHb)i4P(uALb(w9Qeg8JGN6tLauxrQZvcWcTPoeA22z2DSSb0Oie7HOsmq9jQKhapqkRyPLwjBuemqpwREvMFvVkHb)i4P(ujgO(evscjTZa5bR(ev6Gca1TP(evYsAFiixXJz)qPHIMnyGESA2pSVhILzlxbaOnvy2Xe2FhtHKYjMnduFcHzpbXIvLauxrQZvsDi0SVXSHPzdNzlhZ2gQlM4YWsRmYx9QeduFIkjYHGMO5q2Qeg8JGN6tPvMSx9Qeg8JGN6tLcgcRKoqyBKAqtiu6KlAGjeknhO(eIkXa1NOs6aHTrQbnHqPtUObMqO0CG6tikTYy5QxLWGFe8uFQuWqyLedb5ortGakQnfbDHl3ZXkXa1NOsIHGCNOjqaf1MIGUWL75yPvg4v9QeduFIkjrqrhGYsALWGFe8uFkTYypvVkHb)i4P(uja1vK6CLuMGHU6tDOXPyBKAcgqDjhGlm4hbpvIbQprL6tDOXPyBKAcgqDjhGLwzS3QxLWGFe8uFQuWqyLeD8zGbEAd91gPMouim0kXa1NOsIo(mWapTH(AJuthkegAPvg4B1Rsmq9jQKyYjnjNIvcd(rWt9P0kJCP6vjgO(evYdGhiLvSsyWpcEQpLwAL4bREvMFvVkHb)i4P(uja1vK6CLSH6YdjKgmzXa1LHMnCMDwnB5y2GziNbgXQJLnGff5JfMnSWA2mqDzyddeYrHzFJzNDZolvIbQprLOShTrQj5uS0kJ8vVkXa1NOsIjN0OJwjm4hbp1NsRmzV6vjm4hbp1NkbOUIuNR0z0LdbnewXffHypeM9nMnGfAtDiSsmq9jQeOJJajTdcnHKtXsRmwU6vjm4hbp1NkXa1NOsoe0qyfReG6ksDUsueI9qy22z2WZSHZSZQzlhZwzcg6cWkdiwiGwyWpcEmByH1SbZqodmIfGvgqSqaTOie7HWSVXSPie7HWSZsLawaiytzAFufvMFLwzGx1RsyWpcEQpvIbQprLamH0yG6t0iUqReXfAlyiSsGJO0kJ9u9Qeg8JGN6tLyG6tujatingO(enIl0krCH2cgcRekeyaqrPvg7T6vjm4hbp1NkXa1NOsDSSbuja1vK6CLyG6YWggiKJcZ2oZ2YvcybGGnLP9rvuz(vALb(w9QeduFIkrzpAJutYPyLWGFe8uFkTYixQEvcd(rWt9Psmq9jQuhlBavcybGGnLP9rvuz(vAL5hmREvcd(rWt9PsaQRi15kLvZwm5KNhNfb5t7zrdTpgYgbxyWpcEmByH1SLJzRmbdDj5uSXXP9OoKqNaxyWpcEm7SujgO(ev6GahIvp63EdrlTY87x1RsyWpcEQpvcqDfPoxjLjyOljNInooTh1He6e4cd(rWJzdNz)YLKwpgCRdLL0vUnZgoZwm5KMOJPhZ2oZgEMT9B2WCjVzNTMnduxg2WaHCuujgO(evYdGhiLvS0kZp5REvIbQprLetoPj5uSsyWpcEQpLwz(L9QxLWGFe8uFQeG6ksDUsVCjP1Jb36qzjDDgyevIbQprLatir4(uwXsRm)SC1RsyWpcEQpvcqDfPoxjLP9rD1Hmr7w2aQzBNzlpmReduFIkj64ZaJxonkTY8dEvVkHb)i4P(uja1vK6CLKJzNvZwzcg6sYPyJJt7rDiHobUWGFe8y2WcRzRmbdD5HesJzHb)i4XSZsLyG6tujbyYPE0VPU2HLwz(zpvVkHb)i4P(uja1vK6CLKJzNvZwzcg6sYPyJJt7rDiHobUWGFe8y2WcRzRmbdD5HesJzHb)i4XSZsLyG6tujhYgghp63aSYcLo26WsRm)S3QxLyG6tujpaEGuwXkHb)i4P(uAPvcCevVkZVQxLWGFe8uFQeduFIkj64Zad80g6RnsnDOqyOvcqDfPoxjWmKZaJyjYHGMO5HesdMSOie7HWSTZSZUzdlSM9BecZgoZwY73PnkcXEimB7mBllFLcgcRKOJpdmWtBOV2i10HcHHwALr(QxLyG6tujroe0enpKqAWKkHb)i4P(uALj7vVkXa1NOshMERMyYjnpek)CIRwujm4hbp1NsRmwU6vjm4hbp1NkbOUIuNRKnuxEiH0GjlgOUmSsmq9jQKTr9jkTYaVQxLWGFe8uFQeG6ksDUs2qD5HesdMSyG6YWkXa1NOspKkq6T8OFPvg7P6vjm4hbp1NkbOUIuNRKnuxEiH0GjlgOUmSsmq9jQ0JmZPjLtTO0kJ9w9Qeg8JGN6tLauxrQZvYgQlpKqAWKfduxgwjgO(evsYP4JmZP0kd8T6vjm4hbp1NkbOUIuNRKnuxEiH0GjlgOUm0SHfwZ(ncHzdNzl5970gfHypeMTDMT8)QeduFIkLlWMRiKO0sR0bL4CIw9Qm)QEvcd(rWt9PshuaOUn1NOsws7db5kEmBugsTWSvhcnBTdnBgOd1SDHzZYyNWpcUQeduFIkjSHesJmGBvALr(QxLWGFe8uFQeG6ksDUsDSSb0yG6YqZgoZMbQldByGqokm7Bm7FMnCMnduxg2WaHCuy22z2WZSTFZwzcg6YdjKgZcd(rWJz)1SZQzRmbdD5HesJzHb)i4XSHZSvMGHU8qrAWKgyGE5c1NyHb)i4XSZsLek1bAL5xLyG6tujatingO(enIl0krCH2cgcRuhlBaLwzYE1RsyWpcEQpvIbQprLKiOOdqzjTsaQRi15kjMCYZJZs2qy1jytmezyOlm4hbpvYdfP0CBAZLQ0lxsAjBiS6eSjgImm0vUTsRmwU6vjm4hbp1NkbOUIuNRKYem0fDyQh9BpcF7Xfg8JGhZgoZ(GVCjPfDyQh9BpcF7XffHypeMTDM9Vf8QeduFIkbMqIW9PSILwzGx1Rsmq9jQeGvgqSqavjm4hbp1NsRm2t1RsyWpcEQpvcqDfPoxjgOUmSHbc5OWSVXSLVscL6aTY8Rsmq9jQeGjKgduFIgXfALiUqBbdHvIhS0kJ9w9Qeg8JGN6tLyG6tujXKtAsofReG6ksDUsuuIIIo(rqZgoZwm5KMOJPhZ2UlZ2YMnCMDwnB5y2ktWqxawzaXcb0cd(rWJzdlSMnygYzGrSaSYaIfcOffHypeM9nMnfHypeMDwQeWcabBkt7JQOY8R0kd8T6vjm4hbp1NkXa1NOsoe0qyfReG6ksDUsueI9qy22z2z3SHZSZQzlhZwzcg6cWkdiwiGwyWpcEmByH1SbZqodmIfGvgqSqaTOie7HWSVXSPie7HWSZsLawaiytzAFufvMFLwzKlvVkHb)i4P(uja1vK6CLuMGHU8qrAWKgyGE5c1NyHb)i4XSHZSzG6tSaD8iAVHOlpAseVFNA2Wz2ueI9qy22z2NCkR(eMD2A2WCbVkXa1NOsoe0qyflTY8dMvVkHb)i4P(uja1vK6CLYQzBd1LhsinyYIbQldnByH1STH66ryHToeYIfduxgA2zXSHZSftoPj6y6XSV5YSTCLyG6tujqhpI2BiAPvMF)QEvcd(rWt9Psmq9jQeGjKgduFIgXfALiUqBbdHvcCeLwz(jF1Rsmq9jQeOJJajTdcnHKtXkHb)i4P(uAL5x2REvIbQprLeGjN6r)M6Ahwjm4hbp1NsRm)SC1Rsmq9jQ0bboeRE0V9gIwjm4hbp1NsRm)Gx1RsyWpcEQpvIbQprL6yzdOsaQRi15kDgD5qqdHvCrri2dHzFJzFgD5qqdHvCDYPS6ty2zRzdZf8mByH1SLJzRmbdD5HI0GjnWa9YfQpXcd(rWtLawaiytzAFufvMFLwz(zpvVkXa1NOsoKnmoE0VbyLfkDS1Hvcd(rWt9P0kZp7T6vjgO(evsm5KgD0kHb)i4P(uAL5h8T6vjm4hbp1NkbOUIuNRenpqPH2hxZH2eDmmiTrQPDyZciNEBZ0fk3ZDB2WtLyG6tuPow2akTY8tUu9Qeg8JGN6tLgBvsGALyG6tujzm15hbRKmMKJvIbQldByGqokm7Bm7FMnCMnygYzGrS6yzdyrri2dHzB3Lz)dMMnSWA2VCjPf11CM0gPgn3JvUnZgoZwzcg6IYE0gPgOJhXcd(rWtLKX0wWqyLSndPjMCst0X0JO0kJ8WS6vjm4hbp1NkbOUIuNR0lxsA9yWTouwsxNbgHzdNzlMCst0X0JzFZLz)BbpZ2(nByUYUzNTMTYem0LeHfDJmKUWGFe8y2Wz2YXSLXuNFeCzBgstm5KMOJPhrLyG6tujWeseUpLvS0kJ8)QEvcd(rWt9PsaQRi15kzd1LhsinyYIbQldnByH1SF5sslk7rBKAGoEelkcXEim7BmBal0M6qyLyG6tujqhpI2BiAPvg5LV6vjm4hbp1NkbOUIuNR0lxsA9yWTouwsx52mB4mB5y2YyQZpcUSndPjMCst0X0JOsmq9jQeOJhr7neT0kJ8zV6vjm4hbp1NkbOUIuNRKYem0fs5Jdy1NyHb)i4XSHZSLJzlJPo)i4Y2mKMyYjnrhtpcZgoZ(GVCjPfs5Jdy1Nyrri2dHzBNzdyH2uhcReduFIkb64r0EdrlTYiVLREvcd(rWt9PsaQRi15kjhZwgtD(rWLTzinXKtAIoMEeMnSWA2IjN0eDm9y23Cz2wEbVkXa1NOsIo(mW4LtJsRmYdVQxLWGFe8uFQeG6ksDUsIjN0eDm9y23y2zFbVkXa1NOsGoEeT3q0sRmYBpvVkHb)i4P(uja1vK6CLEJqy2Wz2sE)oTrri2dHzBNzdpZgoZwzAFuxQdHnDAhhn7BmBal0M6qOz)1Svkldjn1HWkXa1NOsGoEeT3q0sRmYBVvVkHb)i4P(uja1vK6CLaDmTpkm7Bm7FMnSWA2kt7J6sDiSPt74OzBNz3hCQeduFIkbMqIW9PSILwzKh(w9QeduFIk5bWdKYkwjm4hbp1NslT0kjdPcFIkJ8WuE5HP8Y)RsWGPHh9fvsUwU62qg5Mm3gHpMTz3RdnBhY2qvZwAOMn8FqjoNOWVztr5EUtXJzlgi0S5CDGyfpMnOJJ(OyzSAP9an7SdFmBl1eYqQIhZg(fto55XzzjGFZwhZg(fto55XzzjwyWpcEGFZMvZ2sEBzPn7S(Z(YYYy1s7bA2)KlWhZ2snHmKQ4XSHFLjyOllb8B26y2WVYem0LLyHb)i4b(nBwnBl5TLL2SZ6p7lllJvlThOzlF2HpMTLAczivXJzd)ktWqxwc43S1XSHFLjyOllXcd(rWd8B2z9N9LLLXQXQCdKTHQ4XSHNzZa1NWSjUqflJ1kzJosobRu2KnMTClkuAoq9jmB5AMsgWTmwZMSXSVD4JMZulmB5TN)MT8WuE5nwnwZMSXSTuDC0hfWhJ1SjBmB73SVDeu0bOSKE)2CiS6e0StdrggQzd4aGKMlz2Goo6JhZwhZ2dfP0CBAZLwgRgRzJzBjTpeKR4XSFO0qrZgmqpwn7h23dXYSLRaa0Mkm7yc7VJPqs5eZMbQpHWSNGyXYyLbQpHyzJIGb6X6LesANbYdw9j(7sxQdH3at4KJnuxmXLHgRmq9jelBuemqpw)EDxKdbnrZgQgRmq9jelBuemqpw)EDpxGnxrO)bdHx6aHTrQbnHqPtUObMqO0CG6timwzG6tiw2OiyGES(96EUaBUIq)dgcVedb5ortGakQnfbDHl3ZrJvgO(eILnkcgOhRFVUlrqrhGYsQXkduFcXYgfbd0J1Vx37tDOXPyBKAcgqDjhG)DPlLjyOR(uhACk2gPMGbuxYb4cd(rWJXkduFcXYgfbd0J1Vx3ZfyZve6FWq4LOJpdmWtBOV2i10HcHHASYa1NqSSrrWa9y971DXKtAsofnwzG6tiw2OiyGES(96UhapqkROXQXA2y2ws7db5kEmBugsTWSvhcnBTdnBgOd1SDHzZYyNWpcUmwzG6tiUe2qcPrgWTmwzG6tiUamH0yG6t0iUq)hmeE1XYgWFHsDGE97VlD1XYgqJbQldHJbQldByGqokU5hCmqDzyddeYrHDWZ(vMGHU8qcPXSWGFe88nRktWqxEiH0ywyWpcEGtzcg6YdfPbtAGb6LluFIfg8JGNSySYa1Nq896UebfDaklP)DPlXKtEECwYgcRobBIHidd9VhksP520MlD9YLKwYgcRobBIHiddDLBZyLbQpH471DWeseUpLv8VlDPmbdDrhM6r)2JW3ECHb)i4bUd(YLKw0HPE0V9i8ThxueI9qy3Vf8mwzG6ti(EDhWkdiwiGmwzG6ti(EDhWesJbQprJ4c9FWq4fp4FHsDGE97VlDXa1LHnmqihf3iVXkduFcX3R7IjN0KCk(hybGGnLP9rvC97VlDrrjkk64hbHtm5KMOJPh7USmCzvoktWqxawzaXcb0cd(rWdSWcMHCgyelaRmGyHaArri2dXnueI9qKfJvgO(eIVx3DiOHWk(hybGGnLP9rvC97VlDrri2dHDzhUSkhLjyOlaRmGyHaAHb)i4bwybZqodmIfGvgqSqaTOie7H4gkcXEiYIXkduFcX3R7oe0qyf)7sxktWqxEOinysdmqVCH6tSWGFe8ahduFIfOJhr7neD5rtI497u4Oie7HWUtoLvFISfMl4zSYa1Nq896oOJhr7ne9VlDLvBOU8qcPbtwmqDziSWAd11JWcBDiKflgOUmmlWjMCst0X0Znxw2yLbQpH471DatingO(enIl0)bdHxGJWyLbQpH471DqhhbsAheAcjNIgRmq9jeFVUlato1J(n11o0yLbQpH4719dcCiw9OF7ne1yLbQpH4719ow2a(dSaqWMY0(OkU(93LUoJUCiOHWkUOie7H4MZOlhcAiSIRtoLvFISfMl4blSYrzcg6YdfPbtAGb6LluFIfg8JGhJvgO(eIVx3DiByC8OFdWklu6yRdnwzG6ti(EDxm5KgDuJvgO(eIVx37yzd4VlDrZduAO9X1COnrhddsBKAAh2SaYP32mDHY9C3Mn8ySYa1Nq896UmM68JG)dgcVSndPjMCst0X0J4VmMKJxmqDzyddeYrXn)Gdmd5mWiwDSSbSOie7HWURFWewyF5sslQR5mPnsnAUhRCBWPmbdDrzpAJud0XJWyLbQpH471DWeseUpLv8VlD9YLKwpgCRdLL01zGraNyYjnrhtp3C9Bbp7hMRSNTktWqxsew0nYq6cd(rWdCYrgtD(rWLTzinXKtAIoMEegRmq9jeFVUd64r0Edr)7sx2qD5HesdMSyG6YqyH9LljTOShTrQb64rSOie7H4gal0M6qOXkduFcX3R7GoEeT3q0)U01lxsA9yWTouwsx52GtoYyQZpcUSndPjMCst0X0JWyLbQpH471DqhpI2Bi6Fx6szcg6cP8XbS6taNCKXuNFeCzBgstm5KMOJPhbCh8LljTqkFCaR(elkcXEiSdWcTPoeASYa1Nq896UOJpdmE504VlDjhzm15hbx2MH0etoPj6y6ralSIjN0eDm9CZLLxWZyLbQpH471DqhpI2Bi6Fx6sm5KMOJPNBY(cEgRmq9jeFVUd64r0Edr)7sxVriGtY73PnkcXEiSdEWPmTpQl1HWMoTJJ3ayH2uhc)QuwgsAQdHgRmq9jeFVUdMqIW9PSI)DPlqht7JIB(blSkt7J6sDiSPt74OD9bhJvgO(eIVx39a4bszfnwnwzG6tiw8Gxu2J2i1KCk(3LUSH6YdjKgmzXa1LHWLv5aMHCgyeRow2awuKpwalSmqDzyddeYrXnzplgRmq9jelEWVx3ftoPrh1yLbQpHyXd(96oOJJajTdcnHKtX)U01z0LdbnewXffHype3ayH2uhcnwzG6tiw8GFVU7qqdHv8pWcabBkt7JQ463Fx6IIqShc7GhCzvoktWqxawzaXcb0cd(rWdSWcMHCgyelaRmGyHaArri2dXnueI9qKfJvgO(eIfp43R7aMqAmq9jAexO)dgcVahHXkduFcXIh871DatingO(enIl0)bdHxOqGbafgRmq9jelEWVx37yzd4pWcabBkt7JQ463Fx6IbQldByGqokSZYgRmq9jelEWVx3PShTrQj5u0yLbQpHyXd(96EhlBa)bwaiytzAFufx)mwzG6tiw8GFVUFqGdXQh9BVHO)DPRSkMCYZJZIG8P9SOH2hdzJGlm4hbpWcRCuMGHUKCk2440EuhsOtGlm4hbpzXyLbQpHyXd(96UhapqkR4Fx6szcg6sYPyJJt7rDiHobUWGFe8a3lxsA9yWTouwsx52Gtm5KMOJPh7GN9dZL8zlduxg2WaHCuySYa1NqS4b)EDxm5KMKtrJvgO(eIfp43R7GjKiCFkR4Fx66LljTEm4whklPRZaJWyLbQpHyXd(96UOJpdmE504VlDPmTpQRoKjA3YgqTtEyASYa1NqS4b)EDxaMCQh9BQRD4Fx6sozvzcg6sYPyJJt7rDiHobUWGFe8alSktWqxEiH0ywyWpcEYIXkduFcXIh871DhYgghp63aSYcLo26W)U0LCYQYem0LKtXghN2J6qcDcCHb)i4bwyvMGHU8qcPXSWGFe8KfJvgO(eIfp43R7Ea8aPSIgRgRmq9jelWrCLlWMRi0)GHWlrhFgyGN2qFTrQPdfcd9VlDbMHCgyelroe0enpKqAWKffHype2LDyH9ncbCsE)oTrri2dHDwwEJvgO(eIf4i(EDxKdbnrZdjKgmXyLbQpHyboIVx3pm9wnXKtAEiu(5exTWyLbQpHyboIVx3TnQpXFx6YgQlpKqAWKfduxgASYa1NqSahX3R7pKkq6T8O)Fx6YgQlpKqAWKfduxgASYa1NqSahX3R7pYmNMuo1I)U0LnuxEiH0GjlgOUm0yLbQpHyboIVx3LCk(iZC(7sx2qD5HesdMSyG6YqJvgO(eIf4i(EDpxGnxriXFx6YgQlpKqAWKfduxgclSVriGtY73PnkcXEiSt(FgRgRmq9jeRow2aUatir4(uwX)U01lxsA9yWTouwsxNbgbCIjN0eDm9CZ1p4etoPj6y6XUllBSYa1NqS6yzd471DXKtAsof)7sxawOn1Hq76yzdOrri2dHXkduFcXQJLnGVx3piWHy1J(T3q0)U0fGfAtDi0Uow2aAueI9qaNyYjppolcYN2ZIgAFmKncUWGFe8ySYa1NqS6yzd471DbyYPE0VPU2H)DPlal0M6qODDSSb0Oie7HWyLbQpHy1XYgW3R7oe0qyf)7sxktWqxEOinysdmqVCH6tSWGFe8ahfHype2DYPS6tKTWCbpyHvoktWqxEOinysdmqVCH6tSWGFe8ahfLOOOJFe0yLbQpHy1XYgW3R7GoEeT3q0)U0fGfAtDi0Uow2aAueI9qySYa1NqS6yzd471DrhFgy8YPHXkduFcXQJLnGVx39a4bszf)7sxawOn1Hq76yzdOrri2drLe2qqLrE7XElT0Qa]] )


end
