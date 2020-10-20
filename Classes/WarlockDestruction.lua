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
        casting_circle = 3510, -- 221703
        cremation = 159, -- 212282
        demon_armor = 3741, -- 285933
        essence_drain = 3509, -- 221711
        fel_fissure = 157, -- 200586
        focused_chaos = 155, -- 233577
        gateway_mastery = 5382, -- 248855
        nether_ward = 3508, -- 212295
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
            duration = 30,
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
            duration = function () return 5 * haste end,
            tick_time = function () return haste end,
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

        if debuff.havoc.up or FindUnitDebuffByID( "target", 80240, "PLAYER" ) then
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
            cast = function () return ( buff.backdraft.up and 0.7 or 1 ) * ( buff.madness_of_the_azjaqir.up and 0.8 or 1 ) * 3 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 2,
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
                removeStack( "backdraft" )
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
            cast = 5,
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

            indicator = function () return ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
            cycle = "havoc",

            bind = "bane_of_havoc",

            usable = function () return not pvptalent.bane_of_havoc.enabled and active_enemies > 1, "requires multiple targets and no bane_of_havoc" end,
            handler = function ()
                if class.abilities.havoc.indicator == "cycle" then
                    active_dot.havoc = active_dot.havoc + 1
                    active_dot.odr_shawl_of_the_ymirjar = 1
                else
                    applyDebuff( "target", "havoc" )
                    applyDebuff( "target", "odr_shawl_of_the_ymirjar" )
                end
                applyBuff( "active_havoc" )
            end,

            copy = "real_havoc",

            auras = {
                odr_shawl_of_the_ymirjar = {
                    id = 337160,
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

            spend = 3,
            spendType = "soul_shards",

            startsCombat = true,

            handler = function ()
                -- establish that RoF is ticking?
                -- need a CLEU handler?
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

            spend = 1,
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

            spend = 1,
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
            
            spend = 1,
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

        potion = "unbridled_fury",

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
        get = function () return "#showtooltip\n/use [@mouseover,harm][] " .. class.abilities.havoc.name end,
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
        get = function () return "#showtooltip\n/use [@mouseover,harm][] " .. class.abilities.immolate.name end,
        set = function () end,
    } )


    spec:RegisterPack( "Destruction", 20201013, [[de0sRaqiIsEerPytqLgLuQCkPuAvqf1RuqZcQQBbvGDjQFPinmIIJPalte1ZKsvttkfxda2guH8nOI04GkIZruQwhuHQMNiY9uu7teCqIsPAHa0djkLYejkLCrOckNeQGQvksTtPOFcvq8uQAQsjFfQG0EL8xPAWQ0HrTyO8yvnzvCzKntKpRignGonLxdGMnKBd0Uf(TsdxKSCcph00jDDfA7evFxeA8qfQCEOkRhQqz(sH9tLRbvRYFyLQMjltYYmqMbTplJS3EzVnaO8kEPOYNIFaYtOYhmivEzlcQIXxTnkFkgp0YNQv5H7O4PYdu1uqC8tNoXuGJy5FbNcnWreR2gVGL0Pqd8NwESrdP4WJcR8hwPQzYYKSmdKzq7ZYi7Tx2BtYLNhvGRO8Edu2w5bANdffw5pe8lVSXDLTiOkgF12WDXHYc0(a0Lw24U4qEDXiH7oO947UjltYYuEKbvy1Q8eesXtWQv1Cq1Q88R2gLpXvGoYjl6ccUbhpvEkymeDkalTAMC1Q88R2gLhKaxbE9vQJgF70pcIbHLNcgdrNcWsRMTVAvE(vBJYJH290xPUcK6uqG4vEkymeDkalTA2MQv55xTnk)KrwCmo6RuNXXiXQalpfmgIofGLwnbq1Q88R2gLxyPsHOUfDyk(PYtbJHOtbyPvtCu1Q88R2gLxA)riD6mogjmL6yedwEkymeDkalTAItRwLNF12O8PgfMeEwmPJHyOwEkymeDkalTAItQwLNcgdrNcWY)ctjHXLxzXesZajgPa7PE1DtWDXjY4UnA4UklMqAgiXifyp1RUBsUBYY4UnA4Us2eGAxqGSfq3nj3nzzC3gnCxLftinRgi11TN61EYY4Uj4UTrMYZVABuEbXPSysxcXGeS0QPSxTkp)QTr5)nEkubR0PlHyqQ8uWyi6uawA1CGmvRYtbJHOtby5FHPKW4YJnkjLf0dqebHDPv8uwqGSfWYZVABuEfi1hdSDmoDPv8uPLwEGS89RwvZbvRYtbJHOtby5FHPKW4YJnkjLX4hGhblP5ZMy4U46UWDe1HazXXDty2Dh4U46UWDe1HazXXDtA2DBt55xTnk)VHeINiyLkTAMC1Q88R2gLhUJOUKjOYtbJHOtbyPvZ2xTkpfmgIofGL)fMscJl)ZqTRgi5Uj5Uaz573feiBbS88R2gLh(7OWIjD1uGuPvZ2uTkpfmgIofGL)fMscJlVYik0Sfkjcg1)feBeQ2gzkymeDCxCDxbbYwaD3KC3ZOGvBd3fNDxzYaWDB0WDLL7QmIcnBHsIGr9FbXgHQTrMcgdrh3fx3vqscccKXqu55xTnkVbcUiwPsRMaOAvEkymeDkal)lmLegx(NHAxnqYDtYDbYY3Vliq2cy55xTnk)dKxyhBrAPvtCu1Q88R2gLhcKpBIyJIO8uWyi6uawA1eNwTkpfmgIofGL)fMscJl)ZqTRgi5Uj5Uaz573feiBbS88R2gL3I3csWkvAPLpLG(feJ1Qv1Cq1Q88R2gLhoccUr3atvEkymeDkalTAMC1Q8uWyi6uaw(xykjmU8kJOqZteg4AcQVsDi)ctYEktbJHOt55xTnk)eHbUMG6RuhYVWKSNkTA2(Qv55xTnkpChrDjtqLNcgdrNcWsRMTPAvEkymeDkal)lmLegxEz5UkJOqZWDe1LmbLPGXq0P88R2gL3I3csWkvAPLNxQAvnhuTkpfmgIofGL)fMscJlFksZwirIGrz(vto5U46UTZDLL7(7IoBIrgilF)SG4dEUBJgUl)QjN6uqGgbD3eC327UTT88R2gLxWw0xPUKjOsRMjxTkpfmgIofGL)fMscJl)z1SbcUiwPSGazlGUBcU7ZqTRgivE(vBJY)a5iiu)qGBizcQ0Qz7RwLNcgdrNcWYZVABuEdeCrSsL)fMscJlVGazlGUBsUlaCxCD325UYYDvgrHMFw5hHhemtbJHOJ72OH7(7IoBIr(zLFeEqWSGazlGUBcURGazlGUBBl)J3JOUYIjKcRMdkTA2MQv5PGXq0PaS88R2gL)zeQZVAB0rgulpYGApyqQ8)bwA1eavRYtbJHOtby55xTnk)ZiuNF12OJmOwEKb1EWGu5jiKINGLwnXrvRYtbJHOtby55xTnkpqw((L)X7ruxzXesHvZbLwnXPvRYZVABuEbBrFL6sMGkpfmgIofGLwnXjvRYtbJHOtby55xTnkpqw((L)X7ruxzXesHvZbLwnL9Qv5PGXq0PaS8VWusyC5vgrHMLmb1540Xegiu3GYuWyi64U46UyJsszm(b4rWsAEmL7IR7c3ruhcKfh3nj3faUloWDLjNS7IZUl)QjN6uqGgblp)QTr5T4TGeSsLwnhit1Q88R2gLhUJOUKjOYtbJHOtbyPvZbdQwLNcgdrNcWY)ctjHXLhBuskJXpapcwsZNnXO88R2gL)3qcXteSsLwnhKC1Q8uWyi6uaw(xykjmU8klMqAgiXifyo1RUBsUBYYuE(vBJYdbYNnrSrruA1Cq7RwLNF12O8w8wqcwPYtbJHOtbyPLw()aRwvZbvRYZVABuE4ii4gDlKirWOYtbJHOtbyPvZKRwLNF12O8hwaWoChrDlGkJzitXR8uWyi6uawA1S9vRYtbJHOtby5FHPKW4YNI0SfsKiyuMF1KtLNF12O8Pw12O0QzBQwLNcgdrNcWY)ctjHXLpfPzlKirWOm)QjNkp)QTr5XibKea0IjLwnbq1Q8uWyi6uaw(xykjmU8PinBHejcgL5xn5u55xTnkpgA3txAuGxPvtCu1Q8uWyi6uaw(xykjmU8PinBHejcgL5xn5u55xTnkVKjim0UNsRM40Qv5PGXq0PaS8VWusyC5trA2cjsemkZVAYj3Trd3vzXesZQbsDD7hJC3KC3KLP88R2gLFesDtjqyPvtCs1Q88R2gL)qVbYQft6ylslpfmgIofGLwnL9Qv5PGXq0PaS8VWusyC55xn5uNcc0iO7MG7oWDB0WDXwiS88R2gL3atrXXIj9NvgQInfqQ0Q5azQwLNcgdrNcWY)ctjHXLNF1KtDkiqJGUBcU7a3Trd3fBHWYZVABuE4oI6IvlTAoyq1Q8uWyi6uaw(xykjmU88RMCQtbbAe0DND3bUBJgU7Vl6SjgzGS89ZccKTa6Uj4UaO88R2gLh(7OWIjD1uGuPLw(djXJiTAvnhuTkp)QTr5HPieQJ2hGLNcgdrNcWsRMjxTkp)QTr5HwmH6G8e7lpfmgIofGLwnBF1Q8uWyi6uaw(xykjmU8az5735xn5K7IR7YVAYPofeOrq3nj3faUloWDvgrHMTqIeXMPGXq0XDh6UTZDvgrHMTqIeXMPGXq0XDX1DvgrHMTqjrWO(VGyJq12itbJHOJ722YZVABu(NrOo)QTrhzqT8idQ9GbPYdKLVFPvZ2uTkpfmgIofGL)fMscJlVSC325UPinBHejcgL5xn5K7IR7EwnBGGlIvkliq2cO7o0Dh4Uj4UPinBHejcgLfeiBb0DBR72OH7ctriuxzXesH5Nv(r4bbD3eC3bLNF12O8pR8JWdcwA1eavRYtbJHOtby5FHPKW4YZVAYPofeOrq3nb3n5YZVABu(NrOo)QTrhzqT8idQ9GbPYZlvA1ehvTkpfmgIofGLNF12O8WDe1Lmbv(xykjmU8cssqqGmgICxCDx4oI6qGS44Ujn7UTXDX1DBN7kl3vzefA(zLFeEqWmfmgIoUBJgU7Vl6Sjg5Nv(r4bbZccKTa6Uj4UccKTa6UTT8pEpI6klMqkSAoO0QjoTAvEkymeDkalp)QTr5nqWfXkv(xykjmU8cssqqGmgICxCD325UYYDvgrHMFw5hHhemtbJHOJ72OH7(7IoBIr(zLFeEqWSGazlGUBcURGazlGUBBl)J3JOUYIjKcRMdkTAItQwLNcgdrNcWY)ctjHXLxzefA2cLebJ6)cIncvBJmfmgIoUlUUl)QTr(bYlSJTinBrxcztaQUlUURGazlGUBsU7zuWQTH7IZURmzauE(vBJYBGGlIvQ0QPSxTkpfmgIofGLNF12O8pJqD(vBJoYGA5rgu7bdsL)pWsRMdKPAvEkymeDkalp)QTr5FgH68R2gDKb1YJmO2dgKkpbHu8eS0Q5GbvRYZVABu(hihbH6hcCdjtqLNcgdrNcWsRMdsUAvEkymeDkalp)QTr5bYY3V8VWusyC5pRMnqWfXkLfeiBb0DtWDpRMnqWfXkLpJcwTnCxC2DLjda3Trd3vwURYik0Sfkjcg1)feBeQ2gzkymeDk)J3JOUYIjKcRMdkTAoO9vRYtbJHOtby53uLhsA55xTnkVCwymgIkVCgnsLNF1KtDkiqJGUBcU7a3fx393fD2eJmqw((zbbYwaD3KMD3bY4UnA4U)UOZMyKHJGGB0TqIebJYccKTa6Ujn7UdaG7IR7QmIcnFyba7WDe1TaQmMHmfVmfmgIoUlUU7Vl6Sjg5dlayhUJOUfqLXmKP4LfeiBb0DtA2Dhaa3Trd3vzefA(Wca2H7iQBbuzmdzkEzkymeDCxCD3Fx0ztmYhwaWoChrDlGkJzitXlliq2cO7M0S7oaaUlUUB7C3Fx0ztmYWrqWn6wirIGrzbbYwaD3eCxLftinRgi11TFmYDB0WD)DrNnXidhbb3OBHejcgLfeiBb0Dh6U)UOZMyKHJGGB0TqIebJYNrbR2gUBcURYIjKMvdK662pg5UTT8YzrpyqQ8P2f1H7iQdbYIdS0Q5G2uTkpfmgIofGL)fMscJlp2OKugJFaEeSKMpBIH7IR7c3ruhcKfh3nHz3DqgaUloWDLj3E3fNDxLruOzjedbUYjrMcgdrh3fx3vwURCwymgIYP2f1H7iQdbYIdS88R2gL)3qcXteSsLwnhaGQv5PGXq0PaS8VWusyC5XgLKYhwaWoChrDlGkJzitXlpMQ88R2gL)bYlSJTiT0Q5aCu1Q8uWyi6uaw(xykjmU8yJsszm(b4rWsAEmL7IR7kl3volmgdr5u7I6WDe1HazXb6U46UYYDvgrHMjbFSNvBJmfmgIoLNF12O8pqEHDSfPLwnhGtRwLNcgdrNcWY)ctjHXLxwURCwymgIYP2f1H7iQdbYId0DX1DvgrHMjbFSNvBJmfmgIoUlUUB7C3dHnkjLjbFSNvBJSGazlGUBsU7ZqTRgi5UnA4UyJsszm(b4rWsAEmL722YZVABu(hiVWo2I0sRMdWjvRYtbJHOtby5FHPKW4Yll3volmgdr5u7I6WDe1HazXb6UnA4UWDe1HazXXDty2DBtgaLNF12O8qG8zteBueLwnhi7vRYtbJHOtby5FHPKW4Y3o3fUJOoeiloUBcZUBBYaWDXbURm5KDxC2D5xn5uNcc0iO722YZVABu(hiVWo2I0sRMjlt1Q8uWyi6uaw(xykjmU8pqwmHGUBcU7GYZVABu(FdjeprWkvA1m5bvRYZVABuElElibRu5PGXq0PaS0slT8Yjb02OAMSmjlZazgKC5tKfHftGLhhoyQvO0XDXrUl)QTH7ImOcZU0LpLyLmevEzJ7kBrqvm(QTH7IdLfO9bOlTSXDXH86Irc3Dq7X3DtwMKLXL2Lw24U4WWXr)Osh3fJKwb5U)cIXQ7IrtSaMDxz7)tPuO7gBGdaYcqPrK7YVABaD3nq4LDP5xTnG5uc6xqmwNHJGGB0trQln)QTbmNsq)cIX6W5Pteg4AcQVsDi)ctYEcFtAwzefAEIWaxtq9vQd5xys2tzkymeDCP5xTnG5uc6xqmwhopfUJOUKjixA(vBdyoLG(feJ1HZtT4TGeSs4BsZYszefAgUJOUKjOmfmgIoU0U0Yg3fhgoo6hv64UKCsGN7Qgi5UkqYD5xxH7Aq3LLZgIXqu2LMF12aodtriuhTpaDP5xTnGdNNcTyc1b5j27s7sZVABahop9zeQZVAB0rguXpyqAgilFF8nPzGS8978RMCcx(vto1PGancMeaWbkJOqZwirIyZuWyi6mSDkJOqZwirIyZuWyi6GRYik0Sfkjcg1)feBeQ2gzkymeDARln)QTbC480Nv(r4bbX3KMLv7srA2cjsemkZVAYjCpRMnqWfXkLfeiBbC4GesrA2cjsemkliq2cyBB0aMIqOUYIjKcZpR8JWdcMWaxA(vBd4W5PpJqD(vBJoYGk(bdsZ8s4BsZ8RMCQtbbAemHKDP5xTnGdNNc3ruxYee(pEpI6klMqkCEa(M0SGKeeeiJHiCH7iQdbYItsZTb32jlLruO5Nv(r4bbZuWyi60OXVl6Sjg5Nv(r4bbZccKTaMGGazlGT1LMF12aoCEQbcUiwj8F8Ee1vwmHu48a8nPzbjjiiqgdr42ozPmIcn)SYpcpiyMcgdrNgn(DrNnXi)SYpcpiywqGSfWeeeiBbSTU08R2gWHZtnqWfXkHVjnRmIcnBHsIGr9FbXgHQTrMcgdrhC5xTnYpqEHDSfPzl6siBcqfxbbYwat6mky12aNLjdaxA(vBd4W5PpJqD(vBJoYGk(bdsZ)b6sZVABahop9zeQZVAB0rguXpyqAMGqkEc6sZVABahop9bYrqO(Ha3qYeKln)QTbC48uGS89X)X7ruxzXesHZdW3KMpRMnqWfXkLfeiBbmHZQzdeCrSs5ZOGvBdCwMmaA0qwkJOqZwOKiyu)xqSrOABKPGXq0XLMF12aoCEQCwymgIWpyqAo1UOoChrDiqwCG4lNrJ0m)QjN6uqGgbtyaU)UOZMyKbYY3pliq2cysZdKPrJFx0ztmYWrqWn6wirIGrzbbYwatAEaaWvzefA(Wca2H7iQBbuzmdzkEzkymeDW93fD2eJ8HfaSd3ru3cOYygYu8YccKTaM08aa0OHYik08HfaSd3ru3cOYygYu8YuWyi6G7Vl6Sjg5dlayhUJOUfqLXmKP4LfeiBbmP5baa3297IoBIrgoccUr3cjsemkliq2cycklMqAwnqQRB)yuJg)UOZMyKHJGGB0TqIebJYccKTao83fD2eJmCeeCJUfsKiyu(mky12ibLftinRgi11TFmQTU08R2gWHZt)nKq8ebRe(M0m2OKugJFaEeSKMpBIbUWDe1HazXjH5bzaGdKj3ECwzefAwcXqGRCsKPGXq0bxzjNfgJHOCQDrD4oI6qGS4aDP5xTnGdNN(a5f2XwKIVjnJnkjLpSaGD4oI6wavgZqMIxEmLln)QTbC480hiVWo2Iu8nPzSrjPmg)a8iyjnpMcxzjNfgJHOCQDrD4oI6qGS4aXvwkJOqZKGp2ZQTrMcgdrhxA(vBd4W5PpqEHDSfP4BsZYsolmgdr5u7I6WDe1HazXbIRYik0mj4J9SABKPGXq0b32DiSrjPmj4J9SABKfeiBbmPNHAxnqQrdSrjPmg)a8iyjnpMQTU08R2gWHZtHa5ZMi2OiW3KMLLCwymgIYP2f1H7iQdbYIdSrd4oI6qGS4KWCBYaWLMF12aoCE6dKxyhBrk(M0C7G7iQdbYItcZTjdaCGm5KXz(vto1PGanc2wxA(vBd4W5P)gsiEIGvcFtA(bYIjemHbU08R2gWHZtT4TGeSsU0U08R2gWmV0W5Pc2I(k1LmbHVjnNI0SfsKiyuMF1Kt42oz97IoBIrgilF)SG4dEnAWVAYPofeOrWeAFBDP5xTnGzEPHZtFGCeeQFiWnKmbHVjnFwnBGGlIvkliq2cycpd1UAGKln)QTbmZlnCEQbcUiwj8F8Ee1vwmHu48a8nPzbbYwatca42ozPmIcn)SYpcpiyMcgdrNgn(DrNnXi)SYpcpiywqGSfWeeeiBbSTU08R2gWmV0W5PpJqD(vBJoYGk(bdsZ)b6sZVABaZ8sdNN(mc15xTn6idQ4hmintqifpbDP5xTnGzEPHZtbYY3h)hVhrDLftifopaFtIF1KtDkiqJGj1gxA(vBdyMxA48ubBrFL6sMGCP5xTnGzEPHZtbYY3h)hVhrDLftifopWLMF12aM5Lgop1I3csWkHVjnRmIcnlzcQZXPJjmqOUbLPGXq0bxSrjPmg)a8iyjnpMcx4oI6qGS4KeaWbYKtgN5xn5uNcc0iOln)QTbmZlnCEkChrDjtqU08R2gWmV0W5P)gsiEIGvcFtAgBuskJXpapcwsZNnXWLMF12aM5LgopfcKpBIyJIaFtAwzXesZajgPaZPEnPKLXLMF12aM5Lgop1I3csWk5s7sZVABaZ)boCEkCeeCJUfsKiyKln)QTbm)h4W5PhwaWoChrDlGkJzitXZLMF12aM)dC480uRABGVjnNI0SfsKiyuMF1KtU08R2gW8FGdNNIrcijaOftW3KMtrA2cjsemkZVAYjxA(vBdy(pWHZtXq7E6sJc8W3KMtrA2cjsemkZVAYjxA(vBdy(pWHZtLmbHH29GVjnNI0SfsKiyuMF1KtU08R2gW8FGdNNocPUPeieFtAofPzlKirWOm)QjNA0qzXesZQbsDD7hJskzzCP5xTnG5)ahop9qVbYQft6ylsDP5xTnG5)ahop1atrXXIj9NvgQInfqcFtAMF1KtDkiqJGjmOrdSfcDP5xTnG5)ahopfUJOUyv8nPz(vto1PGancMWGgnWwi0LMF12aM)dC48u4VJclM0vtbs4BsZ8RMCQtbbAeCEqJg)UOZMyKbYY3pliq2cycaWL2LMF12aMbYY3F480FdjeprWkHVjnJnkjLX4hGhblP5ZMyGlChrDiqwCsyEaUWDe1HazXjP524sZVABaZaz57pCEkChrDjtqU08R2gWmqw((dNNc)DuyXKUAkqcFtA(zO2vdKscilF)UGazlGU08R2gWmqw((dNNAGGlIvcFtAwzefA2cLebJ6)cIncvBJmfmgIo4kiq2cysNrbR2g4Smza0OHSugrHMTqjrWO(VGyJq12itbJHOdUcssqqGmgICP5xTnGzGS89hop9bYlSJTifFtA(zO2vdKscilF)UGazlGU08R2gWmqw((dNNcbYNnrSrr4sZVABaZaz57pCEQfVfKGvcFtA(zO2vdKscilF)UGazlGU0U08R2gWmbHu8eC480exb6iNSOli4gC8Kln)QTbmtqifpbhopfKaxbE9vQJgF70pcIbHU08R2gWmbHu8eC48um0UN(k1vGuNccepxA(vBdyMGqkEcoCE6KrwCmo6RuNXXiXQaDP5xTnGzccP4j4W5Pclvke1TOdtXp5sZVABaZeesXtWHZtL2FesNoJJrctPogXGU08R2gWmbHu8eC480uJctcplM0XqmuDP5xTnGzccP4j4W5PcItzXKUeIbji(M0SYIjKMbsmsb2t9Ac4ezA0qzXesZajgPa7PEnPKLPrdjBcqTliq2cysjltJgklMqAwnqQRBp1R9KLjH2iJln)QTbmtqifpbhop934PqfSsNUeIbjxA(vBdyMGqkEcoCEQcK6Jb2ogNU0kEcFtAgBusklOhGicc7sR4PSGazlGLhMI(QzY4iCAPLwf]] )


end
