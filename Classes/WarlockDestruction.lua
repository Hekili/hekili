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


    spec:RegisterPack( "Destruction", 20220221, [[dO0HUaqiIsEKOkztiQ(eIsnkkv6uuQyvIQOxbiZcqDlrvQDjLFPszyikogawgrXZevvtJsuxdr02evfFtuvACikX5evbRdrjnpkvDpvY(qeoirPWcvP6HuIOjsuk1fPeHncqQ(iaj0jjkLSskLzkQcTtrLFcqswkaj4PImvLKTcqs9vIsrJLOuzVs(RunyvCyulgOhRQjRuxgAZe5ZkPgTsCAQwnaj61aeZg0Try3c)wXWPKoorPQLJ0ZjmDsxxu2or13bOgpLiDEkH1dqkZhrA)uCbqTQsBwXkNmKrgziJmYaqtgaiPmwMSuj1cRyLSYpGWRXkfmbwjzBuO0Sx9jQKv2c4W7AvLetg9XkTOQvbz92T1UUKb2(H4MWjYGS6t8uwsVjCI)wLaZCOkBffyL2SIvoziJmYqgzKbGMmaqszSC(ujotxgALsoHLSsl(EJrbwPnk(kjBJcLM9QpH5iBYu48aIXgGocsZyQfMJmaaS5idzKrgJnJnl5chRrbz1ylVnhaDikwEklP3aupqwDiAoPbkhd1CEoEe2DjZ5x4ynUnhDmhpuKsZSQDxQvjOlurTQslS85RvvoaQvvcdgeI76ELEQRi15kbMjj1a5hq2uwsB7bWH5qU5iMmyxSW0T5qIlZbaZHCZrmzWUyHPBZX(lZXYvIF1NOs)esqEnLvS0kNm1QkHbdcXDDVsp1vK6CLEwOD1jqZXEZzHLpFNIeShIkXV6tujXKb7soflTYL)AvLWGbH4UUxPN6ksDUspl0U6eO5yV5SWYNVtrc2dH5qU5iMmiOh7ge5Dh0IoAPmHvi2WGbH4Us8R(evAJVtWQhR7GdulTYz5AvLWGbH4UUxPN6ksDUspl0U6eO5yV5SWYNVtrc2drL4x9jQK4NmQhR7QRlyPvoswRQegmie319k9uxrQZvszigAZdfPbd7)qaMjuFIggmie3Md5MdfjypeMJ9MZoJYQpH5KNMdzAK0CiLuZrwMJYqm0Mhksdg2)HamtO(enmyqiUnhYnhkkrrXcdcXkXV6tujNGyGSILw5YNAvLWGbH4UUxPN6ksDUspl0U6eO5yV5SWYNVtrc2drL4x9jQ0VWJOdoqT0kx(wRQe)QprLel8EamygnQegmie319sRCKLAvLWGbH4UUxPN6ksDUspl0U6eO5yV5SWYNVtrc2drL4x9jQKhVhiLvS0sRKvk(dbiR1Qkha1QkHbdcXDDVs8R(evscH99q4bR(evAJIN6wvFIkzjSu8ZuCBoGO0qrZ5hcqwnhqCThIM5iB8pAvfMtmrEVWucPmO5WV6timNjGw0Q0tDfPoxj1jqZHeMdzmhYnhzzowrTXqxowALtMAvL4x9jQKiJGyIUecxYcfPvcdgeI76EPvU8xRQegmie319kfmbwjDiW(i1jMqO0jt0)jekn7vFcrL4x9jQKoeyFK6etiu6Kj6)ecLM9QpHO0kNLRvvcdgeI76ELcMaRKyGiVi6c8PO2v8xcx2NHvIF1NOsIbI8IOlWNIAxXFjCzFgwALJK1QkXV6tujjikwEklPvcdgeI76EPvU8PwvjmyqiUR7v6PUIuNRKYqm02AQtmof7JuxWp1L8hByWGqCxj(vFIkTM6eJtX(i1f8tDj)XsRC5BTQsyWGqCx3RuWeyLel8EamU7dfSpsDDOeyOvIF1NOsIfEpag39Hc2hPUoucm0sRCKLAvL4x9jQKyYGDjNIvcdgeI76EPvU8qTQs8R(evYJ3dKYkwjmyqiUR7LwAL4bRvvoaQvvcdgeI76ELEQRi15kzf1MhsinyyJF1LJMd5MJDnhzzo)mW9a4OTWYNVrrEBH5qkPMd)Qlh7yGeokmhsyo53CStL4x9jQeL9OpsDjNILw5KPwvj(vFIkjMmyNoALWGbH4UUxALl)1QkHbdcXDDVsp1vK6CL2J2CcIbYk2Oib7HWCiH58Sq7QtGvIF1NOs)chbc7BKycjNILw5SCTQsyWGqCx3Re)QprLCcIbYkwPN6ksDUsuKG9qyo2BoK0Ci3CSR5ilZrzigA7zLFOfcIggmie3MdPKAo)mW9a4O9SYp0cbrJIeShcZHeMdfjypeMJDQ0BXdXUY01OkQCauALJK1QkHbdcXDDVs8R(ev6ziSZV6t0HUqRe0fApycSs)wuALlFQvvcdgeI76EL4x9jQ0ZqyNF1NOdDHwjOl0EWeyLqHaJhfLw5Y3AvLWGbH4UUxj(vFIkTWYNVsp1vK6CL4xD5yhdKWrH5yV5y5k9w8qSRmDnQIkhaLw5il1QkXV6tujk7rFK6sofRegmie319sRC5HAvLWGbH4UUxj(vFIkTWYNVsVfpe7ktxJQOYbqPvoaitTQsyWGqCx3R0tDfPoxj7AoIjdc6XUbrE3bTOJwktyfInmyqiUnhsj1CKL5OmedTj5uSZXUdsDcHob2WGbH42CStL4x9jQ0gFNGvpw3bhOwALdaaQvvcdgeI76ELEQRi15kPmedTj5uSZXUdsDcHob2WGbH42Ci3CaZKKAG8diBklPTmRMd5MJyYGDXct3MJ9MdjnN82CittgZjpnh(vxo2XajCuuj(vFIk5X7bszflTYbGm1QkXV6tujXKb7sofRegmie319sRCaK)AvLWGbH4UUxPN6ksDUsGzssnq(bKnLL02EaCuj(vFIk9tib51uwXsRCay5AvLWGbH4UUxPN6ksDUsktxJABbzOU0S(Q5yV5idzQe)QprLel8EamygnkTYbajRvvcdgeI76ELEQRi15kjlZXUMJYqm0MKtXoh7oi1je6eyddgeIBZHusnhLHyOnpKqAmnmyqiUnh7uj(vFIkj(jJ6X6U66cwALdG8PwvjmyqiUR7v6PUIuNRKSmh7AokdXqBsof7CS7GuNqOtGnmyqiUnhsj1CugIH28qcPX0WGbH42CStL4x9jQKtyfJThR7pRSqPJ1fS0kha5BTQs8R(evYJ3dKYkwjmyqiUR7LwAL(TOwv5aOwvjmyqiUR7vIF1NOsIfEpag39Hc2hPUoucm0k9uxrQZv6NbUhahnrgbXeDpKqAWWgfjypeMJ9Mt(nhsj1CuMUg1M6eyxN(2rZXEZXYYuPGjWkjw49ayC3hkyFK66qjWqlTYjtTQs8R(evsKrqmr3djKgmSsyWGqCx3lTYL)AvL4x9jQ0MPasxmzWUhcLbDORwujmyqiUR7Lw5SCTQsyWGqCx3R0tDfPoxjRO28qcPbdB8RUCSs8R(evY6O(eLw5izTQsyWGqCx3R0tDfPoxjRO28qcPbdB8RUCSs8R(evcePcKciESU0kx(uRQegmie319k9uxrQZvYkQnpKqAWWg)QlhRe)QprLaHZS7szulkTYLV1QkHbdcXDDVsp1vK6CLSIAZdjKgmSXV6YXkXV6tujjNIGWz2Lw5il1QkHbdcXDDVsp1vK6CLSIAZdjKgmSXV6YrZHusnhLPRrTPob21PVD0CS3CKHmvIF1NOszcS7ksikT0kTrjodQ1Qkha1QkHbdcXDDVsBu8u3Q6tujlHLIFMIBZbLJulmh1jqZrxqZHFDOMJlmhwo7qgeITkXV6tujHvec7W5bKsRCYuRQegmie319k9uxrQZvAHLpFNF1LJMd5Md)Qlh7yGeokmhsyoayoKBo8RUCSJbs4OWCS3CiP5K3MJYqm0MhsinMggmie3MdqMJDnhLHyOnpKqAmnmyqiUnhYnhLHyOnpuKgmS)dbyMq9jAyWGqCBo2PscL6Vw5aOs8R(ev6ziSZV6t0HUqRe0fApycSslS85lTYL)AvLWGbH4UUxj(vFIkjbrXYtzjTsp1vK6CLetge0JDt(az1Hyxmq5yOnmyqiURKhksPzw1UlvjWmjPM8bYQdXUyGYXqBzwlTYz5AvLWGbH4UUxPN6ksDUskdXqB0HPESUdczanSHbdcXT5qU5SrWmjPgDyQhR7GqgqdBuKG9qyo2Boa0izL4x9jQ0pHeKxtzflTYrYAvL4x9jQ0Zk)qleevcdgeI76EPvU8PwvjmyqiUR7v6PUIuNRe)Qlh7yGeokmhsyoYujHs9xRCauj(vFIk9me25x9j6qxOvc6cThmbwjEWsRC5BTQsyWGqCx3Re)QprLetgSl5uSsp1vK6CLOOefflmienhYnhXKb7IfMUnh7VmhlBoKBo21CKL5OmedT9SYp0cbrddgeIBZHusnNFg4EaC0Ew5hAHGOrrc2dH5qcZHIeShcZXov6T4Hyxz6AufvoakTYrwQvvcdgeI76EL4x9jQKtqmqwXk9uxrQZvIIeShcZXEZj)Md5MJDnhzzokdXqBpR8dTqq0WGbH42CiLuZ5NbUhahTNv(HwiiAuKG9qyoKWCOib7HWCStLElEi2vMUgvrLdGsRC5HAvLWGbH4UUxPN6ksDUskdXqBEOinyy)hcWmH6t0WGbH42Ci3C4x9jA)cpIo4a1MhDjOVErnhYnhksWEimh7nNDgLvFcZjpnhY0izL4x9jQKtqmqwXsRCaqMAvLWGbH4UUxPN6ksDUs21CSIAZdjKgmSXV6YrZHusnhRO2aHSW6csyrJF1LJMJDmhYnhXKb7IfMUnhsCzowUs8R(ev6x4r0bhOwALdaaQvvcdgeI76EL4x9jQ0ZqyNF1NOdDHwjOl0EWeyL(TO0khaYuRQe)QprL(foce23iXesofRegmie319sRCaK)AvL4x9jQK4NmQhR7QRlyLWGbH4UUxALdalxRQe)QprL247eS6X6o4a1kHbdcXDDV0khaKSwvjmyqiUR7vIF1NOslS85R0tDfPoxP9OnNGyGSInksWEimhsyo7rBobXazfB7mkR(eMtEAoKPrsZHusnhzzokdXqBEOinyy)hcWmH6t0WGbH4UsVfpe7ktxJQOYbqPvoaYNAvL4x9jQKtyfJThR7pRSqPJ1fSsyWGqCx3lTYbq(wRQe)QprLetgSthTsyWGqCx3lTYbazPwvjmyqiUR7v6PUIuNRenlqPHUgBZM2flmGH9rQRly3ccNcOKPnu2N5wTI7kXV6tuPfw(8Lw5aipuRQegmie319knwRKa1kXV6tuj5m1zqiwj5mmdRe)Qlh7yGeokmhsyoayoKBo)mW9a4OTWYNVrrc2dH5y)L5aazmhsj1CaZKKAuxZyyFK60mpAzwnhYnhLHyOnk7rFK6)cpIggmie3vsot7btGvY6mWUyYGDXct3IsRCYqMAvLWGbH4UUxPN6ksDUsGzssnq(bKnLL02EaCyoKBoIjd2flmDBoK4YCaOrsZjVnhY0YV5KNMJYqm0MeKflJCK2WGbH42Ci3CKL5iNPodcXM1zGDXKb7IfMUfvIF1NOs)esqEnLvS0kNmauRQegmie319k9uxrQZvYkQnpKqAWWg)Qlhnhsj1CaZKKAu2J(i1)fEeTmRvIF1NOs)cpIo4a1sRCYitTQsyWGqCx3R0tDfPoxjWmjPgi)aYMYsAlZQ5qU5ilZrotDgeInRZa7Ijd2flmDlQe)QprL(fEeDWbQLw5Kj)1QkHbdcXDDVsp1vK6CLugIH2qkV9NvFIggmie3Md5MJSmh5m1zqi2SodSlMmyxSW0TWCi3C2iyMKudP82Fw9jAuKG9qyo2Bopl0U6eyL4x9jQ0VWJOdoqT0kNmwUwvjmyqiUR7v6PUIuNRKSmh5m1zqi2SodSlMmyxSW0TWCiLuZrmzWUyHPBZHexMJLBKSs8R(evsSW7bWGz0O0kNmKSwvjmyqiUR7v6PUIuNRKyYGDXct3MdjmN83izL4x9jQ0VWJOdoqT0kNm5tTQsyWGqCx3R0tDfPoxPFHPRrH5qcZbGkXV6tuPFcjiVMYkwALtM8Twvj(vFIk5X7bszfRegmie319slT0kjhPcFIkNmKrgaaqgYKVvcWmn8yTOsYMYgakKt2khGIKvZXCwTGMJtyDOQ5inuZHS3OeNbvY2COOSpZP42CedbAoCMoeSIBZ5x4ynkAgB5rpqZj)KvZXsoHCKQ42CiBXKbb9y3KDKT5OJ5q2Ijdc6XUj7AyWGqCt2MdRMJLaqvE0CSlawQDAgB5rpqZbG8az1CSKtihPkUnhYwzigAt2r2MJoMdzRmedTj7AyWGqCt2MdRMJLaqvE0CSlawQDAgB5rpqZrM8twnhl5eYrQIBZHSvgIH2KDKT5OJ5q2kdXqBYUggmie3KT5yxaSu70m2m2KTiSouf3Mdjnh(vFcZb6cv0m2QKWk(vozYN8TswPJKdXkLx5L5iBJcLM9QpH5iBYu48aIXwELxMdGocsZyQfMJmaaS5idzKrgJnJT8kVmhl5chRrbz1ylVYlZjVnhaDikwEklP3aupqwDiAoPbkhd1CEoEe2DjZ5x4ynUnhDmhpuKsZSQDxQzSzSLxMJLWsXptXT5aIsdfnNFiaz1CaX1EiAMJSX)OvvyoXe59ctjKYGMd)QpHWCMaArZyJF1Nq0SsXFiaz9scH99q4bR(ea7sxQtGKGmKllRO2yOlhn24x9jenRu8hcqwb66MiJGyIUvun24x9jenRu8hcqwb66wMa7UIeahmbEPdb2hPoXecLozI(pHqPzV6tim24x9jenRu8hcqwb66wMa7UIeahmbEjgiYlIUaFkQDf)LWL9zOXg)QpHOzLI)qaYkqx3KGOy5PSKASXV6tiAwP4peGSc01T1uNyCk2hPUGFQl5pcSlDPmedTTM6eJtX(i1f8tDj)Xggmie3gB8R(eIMvk(dbiRaDDltGDxrcGdMaVel8EamU7dfSpsDDOeyOgB8R(eIMvk(dbiRaDDtmzWUKtrJn(vFcrZkf)HaKvGUU5X7bszfn2m2YlZXsyP4NP42Cq5i1cZrDc0C0f0C4xhQ54cZHLZoKbHyZyJF1NqCjSIqyhopGySXV6tiUEgc78R(eDOluGdMaVwy5ZdSqP(RxaaSlDTWYNVZV6YrY5xD5yhdKWrbjaGC(vxo2XajCuypjZBLHyOnpKqAmnmyqiUbYUkdXqBEiH0yAyWGqCtUYqm0Mhksdg2)HamtO(enmyqiUTJXg)QpHaORBsquS8uwsb2LUetge0JDt(az1Hyxmq5yOa7HIuAMvT7sxGzssn5dKvhIDXaLJH2YSASXV6tia662pHeKxtzfb2LUugIH2Odt9yDheYaAyddgeIBY3iyMKuJom1J1DqidOHnksWEiShGgjn24x9jeaDD7zLFOfccJn(vFcbqx3Egc78R(eDOluGdMaV4bbwOu)1laa2LU4xD5yhdKWrbjKXyJF1Nqa01nXKb7sofb(T4Hyxz6AufxaaSlDrrjkkwyqisUyYGDXct32FzzYTRSugIH2Ew5hAHGOHbdcXnPK(Za3dGJ2Zk)qleenksWEiibfjype2XyJF1Nqa01nNGyGSIa)w8qSRmDnQIlaa2LUOib7HW(8tUDLLYqm02Zk)qleenmyqiUjL0Fg4EaC0Ew5hAHGOrrc2dbjOib7HWogB8R(ecGUU5eedKveyx6szigAZdfPbd7)qaMjuFIggmie3KZV6t0(fEeDWbQnp6sqF9Isofjype2VZOS6tKNKPrsJn(vFcbqx3(fEeDWbQa7sx21kQnpKqAWWg)QlhjLuRO2aHSW6csyrJF1LJ2HCXKb7IfMUjXLLn24x9jeaDD7ziSZV6t0HUqboyc863cJn(vFcbqx3(foce23iXesofn24x9jeaDDt8tg1J1D11f0yJF1Nqa01Tn(obRESUdoq1yJF1Nqa01Tfw(8a)w8qSRmDnQIlaa2LU2J2CcIbYk2Oib7HGe7rBobXazfB7mkR(e5jzAKKusLLYqm0Mhksdg2)HamtO(enmyqiUn24x9jeaDDZjSIX2J19NvwO0X6cASXV6tia66MyYGD6OgB8R(ecGUUTWYNhyx6IMfO0qxJTzt7IfgWW(i11fSBbHtbuY0gk7ZCRwXTXg)QpHaORBYzQZGqe4GjWlRZa7Ijd2flmDlawodZWl(vxo2XajCuqcai)NbUhahTfw(8nksWEiS)caYqkPGzssnQRzmSpsDAMhTmRKRmedTrzp6Ju)x4rySXV6tia662pHeKxtzfb2LUaZKKAG8diBklPT9a4GCXKb7IfMUjXfansM3KPL)8uzigAtcYILrosByWGqCtUSKZuNbHyZ6mWUyYGDXct3cJn(vFcbqx3(fEeDWbQa7sxwrT5Hesdg24xD5iPKcMjj1OSh9rQ)l8iAzwn24x9jeaDD7x4r0bhOcSlDbMjj1a5hq2uwsBzwjxwYzQZGqSzDgyxmzWUyHPBHXg)QpHaORB)cpIo4avGDPlLHyOnKYB)z1NGCzjNPodcXM1zGDXKb7IfMUfKVrWmjPgs5T)S6t0Oib7HW(NfAxDc0yJF1Nqa01nXcVhadMrdGDPlzjNPodcXM1zGDXKb7IfMUfKsQyYGDXct3K4YYnsASXV6tia662VWJOdoqfyx6smzWUyHPBsK)gjn24x9jeaDD7NqcYRPSIa7sx)ctxJcsaGXg)QpHaORBE8EGuwrJnJn(vFcrJh8IYE0hPUKtrGDPlRO28qcPbdB8RUCKC7kRFg4EaC0wy5Z3OiVTGus5xD5yhdKWrbjYVDm24x9jenEqGUUjMmyNoQXg)QpHOXdc01TFHJaH9nsmHKtrGDPR9OnNGyGSInksWEiiXZcTRobASXV6tiA8GaDDZjigiRiWVfpe7ktxJQ4caGDPlksWEiSNKKBxzPmedT9SYp0cbrddgeIBsj9NbUhahTNv(HwiiAuKG9qqcksWEiSJXg)QpHOXdc01TNHWo)Qprh6cf4GjWRFlm24x9jenEqGUU9me25x9j6qxOahmbEHcbgpkm24x9jenEqGUUTWYNh43IhIDLPRrvCbaWU0f)Qlh7yGeokS3YgB8R(eIgpiqx3OSh9rQl5u0yJF1Nq04bb662clFEGFlEi2vMUgvXfagB8R(eIgpiqx3247eS6X6o4avGDPl7kMmiOh7ge5Dh0IoAPmHvi2WGbH4MusLLYqm0MKtXoh7oi1je6eyddgeIB7ySXV6tiA8GaDDZJ3dKYkcSlDPmedTj5uSZXUdsDcHob2WGbH4MCWmjPgi)aYMYsAlZk5Ijd2flmDBpjZBY0Kjp5xD5yhdKWrHXg)QpHOXdc01nXKb7sofn24x9jenEqGUU9tib51uwrGDPlWmjPgi)aYMYsABpaom24x9jenEqGUUjw49ayWmAaSlDPmDnQTfKH6sZ6R2ldzm24x9jenEqGUUj(jJ6X6U66ccSlDjl7QmedTj5uSZXUdsDcHob2WGbH4MusvgIH28qcPX0WGbH42ogB8R(eIgpiqx3CcRyS9yD)zLfkDSUGa7sxYYUkdXqBsof7CS7GuNqOtGnmyqiUjLuLHyOnpKqAmnmyqiUTJXg)QpHOXdc01npEpqkROXMXg)QpHO9BXvMa7UIeahmbEjw49ayC3hkyFK66qjWqb2LU(zG7bWrtKrqmr3djKgmSrrc2dH95NusvMUg1M6eyxN(2r7TSmgB8R(eI2VfaDDtKrqmr3djKgm0yJF1Nq0(TaORBBMciDXKb7Eiug0HUAHXg)QpHO9Bbqx3SoQpbWU0LvuBEiH0GHn(vxoASXV6tiA)wa01nqKkqkG4XAGDPlRO28qcPbdB8RUC0yJF1Nq0(TaORBGWz2DPmQfa7sxwrT5Hesdg24xD5OXg)QpHO9Bbqx3KCkccNzdSlDzf1MhsinyyJF1LJgB8R(eI2VfaDDltGDxrcbWU0LvuBEiH0GHn(vxoskPktxJAtDcSRtF7O9YqgJnJn(vFcrBHLp)1pHeKxtzfb2LUaZKKAG8diBklPT9a4GCXKb7IfMUjXfaKlMmyxSW0T9xw2yJF1Nq0wy5Zd01nXKb7sofb2LUEwOD1jq7xy5Z3Pib7HWyJF1Nq0wy5Zd01Tn(obRESUdoqfyx66zH2vNaTFHLpFNIeShcYftge0JDdI8UdArhTuMWkeByWGqCBSXV6tiAlS85b66M4NmQhR7QRliWU01ZcTRobA)clF(ofjypegB8R(eI2clFEGUU5eedKveyx6szigAZdfPbd7)qaMjuFIggmie3Ktrc2dH97mkR(e5jzAKKusLLYqm0Mhksdg2)HamtO(enmyqiUjNIsuuSWGq0yJF1Nq0wy5Zd01TFHhrhCGkWU01ZcTRobA)clF(ofjypegB8R(eI2clFEGUUjw49ayWmAySXV6tiAlS85b66MhVhiLveyx66zH2vNaTFHLpFNIeShIslTka]] )


end
