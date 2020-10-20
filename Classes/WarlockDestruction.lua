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


    spec:RegisterPack( "Destruction", 20201020, [[dee1RaqiOIEKukytqLgLuQCkPuAveL0RusnlOk3skfTlr9lLQggrXXuswgrvpJOetJOuxdGABsPQ(guHACqfY5GkO1jLcL5js19uk7JOYbHkqTqa8qPuOAIsPqUOuQcNukvjRuKStPWpLsvQNsvtvk5RsPkAVs(Runyv6WOwmuESQMSkUmYMjYNvQmAaDAkVgGmBi3gODl8BfdxeTCcph00jDDLy7IW3fPmEOcKZdv16HkG5lfTFQCTQAv(dRu1qEzKxMvYiVm5v4qzlB5LD5v8tsLpj)aI3rLpyqQ8TreuflVAtu(Km(OHpvRYdNfXtLhOQjHTX2VFNPaxWY)aUhAGliwTjEblP7Hg4VV8ylgsBVIcR8hwPQH8YiVmRKrEzYRWHYw2YxEErboIY7nW24LhODouuyL)qWV8Tb3TnIGQy5vBc3T9KfO5bKlvBWDBVFDWiH7kVm45UYlJ8YuEKbvy1Q8eesXtWQv1yv1Q88R2eLpTrGojil6ccobhpvEkymeDkakTAiF1Q88R2eLhKahb(9rQJwE70pcIbHLNcgdrNcGsRgYs1Q88R2eLhdnZPpsDfi1PGaXV8uWyi6uauA1q2vRYZVAtu(DlS4yC0hPoJdqIrbwEkymeDkakTAa4Qv55xTjkVWsMerDl6WK8tLNcgdrNcGsRgTF1Q88R2eLxA(fiD6moajmL6yedwEkymeDkakTAGJRwLNF1MO8jxeMe(wSRJHyOwEkymeDkakTAGJQwLNcgdrNcGY)ctjHXLxzXosZajgPa7jF1DLZDXrY4UnB6Ukl2rAgiXifyp5RUB6UR8Y4UnB6Us2oGAxqGSfq3nD3vEzC3MnDxLf7inRgi11PN81U8Y4UY5UYwMYZVAtuEbXjTyxxcXGeS0QboSAvE(vBIY)t8uOcwPtxcXGu5PGXq0PaO0QXkzQwLNcgdrNcGY)ctjHXLhBrsklOhqicc7sJ4PSGazlGLNF1MO8kqQVeyZsC6sJ4PslT8a5eZxTQgRQwLNcgdrNcGY)ctjHXLhBrskJXpGocwsZNjTWDX1DHZcQdbYIJ7k3M7UYDX1DHZcQdbYIJ7M(M7k7YZVAtu(FcjeVtWkvA1q(Qv55xTjkpCwqDjtqLNcgdrNcGsRgYs1Q8uWyi6uau(xykjmU8pd1UAGK7MU7cKtmFxqGSfWYZVAtuE4plcl21vtbsLwnKD1Q8uWyi6uau(xykjmU8kJOqZwOKiyu)hqSfOAtKPGXq0XDX1DfeiBb0Dt3DplcwTjCxz1DLjdy3Tzt3fNURYik0Sfkjcg1)beBbQ2ezkymeDCxCDxbjjiiqgdrLNF1MO8gi4GyLkTAa4Qv5PGXq0PaO8VWusyC5FgQD1aj3nD3fiNy(UGazlGLNF1MO8pqEGDSbPLwnA)Qv55xTjkpeiFM0Wwer5PGXq0PaO0QboUAvEkymeDkak)lmLegx(NHAxnqYDt3DbYjMVliq2cy55xTjkVfVfKGvQ0slFsb9digRvRQXQQv5PGXq0PaO8VWusyC5vdKCx5CxzCxCDxC6UjjnZilbvE(vBIYlrO(zaTGvBIsRgYxTkp)Qnr5HlGGt0nWKLNcgdrNcGsRgYs1Q8uWyi6uau(xykjmU8kJOqZ7eg4ycQpsDi)ctYEktbJHOt55xTjk)oHboMG6JuhYVWKSNkTAi7Qv55xTjkpCwqDjtqLNcgdrNcGsRgaUAvEkymeDkak)lmLegxEC6UkJOqZWzb1LmbLPGXq0P88R2eL3I3csWkvAPLNhQAvnwvTkpfmgIofaL)fMscJlFssZwirIGrz(vlb5U46UTZDXP7(ZGotArgiNy(SG4d(UBZMUl)QLG6uqGgbDx5CxzXDBB55xTjkVGTOpsDjtqLwnKVAvEkymeDkak)lmLegx(ZOzdeCqSszbbYwaDx5C3NHAxnqQ88R2eL)bYrqO(HaNqYeuPvdzPAvEkymeDkakp)Qnr5nqWbXkv(xykjmU8ccKTa6UP7Ua2DX1DBN7It3vzefA(zLFe(qWmfmgIoUBZMU7pd6mPf5Nv(r4dbZccKTa6UY5UccKTa6UTT8p(pI6kl2rkSASQ0QHSRwLNcgdrNcGYZVAtu(NrOo)QnrhzqT8idQ9GbPY)hyPvdaxTkpfmgIofaLNF1MO8pJqD(vBIoYGA5rgu7bdsLNGqkEcwA1O9RwLNcgdrNcGYZVAtuEGCI5l)J)JOUYIDKcRgRkTAGJRwLNF1MO8c2I(i1LmbvEkymeDkakTAGJQwLNcgdrNcGYZVAtuEGCI5l)J)JOUYIDKcRgRkTAGdRwLNcgdrNcGY)ctjHXLxzefAwYeuNJthtyGqDcktbJHOJ7IR7ITijLX4hqhblP5LKUlUUlCwqDiqwCC30Dxa7UTP7ktwE3vwDx(vlb1PGancwE(vBIYBXBbjyLkTASsMQv55xTjkpCwqDjtqLNcgdrNcGsRgRwvTkpfmgIofaL)fMscJlp2IKugJFaDeSKMptAr55xTjk)pHeI3jyLkTASs(Qv5PGXq0PaO8VWusyC5vwSJ0mqIrkWCYxD30Dx5LP88R2eLhcKptAylIO0QXkzPAvE(vBIYBXBbjyLkpfmgIofaLwA5)dSAvnwvTkp)Qnr5HlGGt0TqIebJkpfmgIofaLwnKVAvE(vBIYFybG6Wzb1TaQmMHmf)YtbJHOtbqPvdzPAvEkymeDkak)lmLegx(KKMTqIebJY8RwcQ88R2eLp5O2eLwnKD1Q8uWyi6uau(xykjmU8jjnBHejcgL5xTeu55xTjkpgjGKaqwSR0QbGRwLNcgdrNcGY)ctjHXLpjPzlKirWOm)QLGkp)Qnr5XqZC6slc8lTA0(vRYtbJHOtbq5FHPKW4YNK0SfsKiyuMF1sqLNF1MO8sMGWqZCkTAGJRwLNcgdrNcGY)ctjHXLpjPzlKirWOm)QLGC3MnDxLf7inRgi11PFmYDt3DLxMYZVAtu(fi1nLaHLwnWrvRYZVAtu(d9giRwSRJniT8uWyi6uauA1ahwTkpfmgIofaL)fMscJlp)QLG6uqGgbDx5C3vUBZMUl2aHLNF1MO8gyskowSR)SYqvmjbsLwnwjt1Q8uWyi6uau(xykjmU88RwcQtbbAe0DLZDx5UnB6UydewE(vBIYdNfuxmAPvJvRQwLNcgdrNcGY)ctjHXLNF1sqDkiqJGU7M7UYDB20D)zqNjTidKtmFwqGSfq3vo3fWLNF1MO8WFwewSRRMcKkT0YFijEbPvRQXQQv55xTjkpmjHqD08aQ8uWyi6uauA1q(Qv55xTjkp0IDuhK3zF5PGXq0PaO0QHSuTkpfmgIofaL)fMscJlpqoX8D(vlb5U46U8RwcQtbbAe0Dt3DbS72MURYik0SfsKiMmfmgIoU7A3TDURYik0SfsKiMmfmgIoUlUURYik0Sfkjcg1)beBbQ2ezkymeDC32wE(vBIY)mc15xTj6idQLhzqThmivEGCI5lTAi7Qv5PGXq0PaO8VWusyC5XP72o3njPzlKirWOm)QLGCxCD3ZOzdeCqSszbbYwaD31U7k3vo3njPzlKirWOSGazlGUBBD3MnDxyscH6kl2rkm)SYpcFiO7kN7UQ88R2eL)zLFe(qWsRgaUAvEkymeDkak)lmLegxE(vlb1PGanc6UY5UYxE(vBIY)mc15xTj6idQLhzqThmivEEOsRgTF1Q8uWyi6uauE(vBIYdNfuxYeu5FHPKW4YlijbbbYyiYDX1DHZcQdbYIJ7M(M7kB3fx3TDUloDxLruO5Nv(r4dbZuWyi64UnB6U)mOZKwKFw5hHpemliq2cO7kN7kiq2cO722Y)4)iQRSyhPWQXQsRg44Qv5PGXq0PaO88R2eL3abheRu5FHPKW4YlijbbbYyiYDX1DBN7It3vzefA(zLFe(qWmfmgIoUBZMU7pd6mPf5Nv(r4dbZccKTa6UY5UccKTa6UTT8p(pI6kl2rkSASQ0QboQAvEkymeDkak)lmLegxELruOzlusemQ)di2cuTjYuWyi64U46U8R2e5hipWo2G0SfDjKTdO6U46UccKTa6UP7UNfbR2eURS6UYKbC55xTjkVbcoiwPsRg4WQv5PGXq0PaO88R2eL)zeQZVAt0rgulpYGApyqQ8)bwA1yLmvRYtbJHOtbq55xTjk)ZiuNF1MOJmOwEKb1EWGu5jiKINGLwnwTQAvE(vBIY)a5iiu)qGtizcQ8uWyi6uauA1yL8vRYtbJHOtbq55xTjkpqoX8L)fMscJl)z0SbcoiwPSGazlGURCU7z0SbcoiwP8zrWQnH7kRURmza7UnB6U40DvgrHMTqjrWO(pGylq1MitbJHOt5F8Fe1vwSJuy1yvPvJvYs1Q8uWyi6uau(jz5HKwE(vBIYNGfgJHOYNGrlu55xTeuNcc0iO7kN7UYDX1D)zqNjTidKtmFwqGSfq3n9n3DLmUBZMU7pd6mPfz4ci4eDlKirWOSGazlGUB6BU7ka7U46UkJOqZhwaOoCwqDlGkJzitXptbJHOJ7IR7(ZGotAr(Wca1HZcQBbuzmdzk(zbbYwaD303C3va2DB20DvgrHMpSaqD4SG6wavgZqMIFMcgdrh3fx39NbDM0I8HfaQdNfu3cOYygYu8ZccKTa6UPV5URaS7IR72o39NbDM0ImCbeCIUfsKiyuwqGSfq3vo3vzXosZQbsDD6hJC3MnD3Fg0zslYWfqWj6wirIGrzbbYwaD31U7pd6mPfz4ci4eDlKirWO8zrWQnH7kN7QSyhPz1aPUo9JrUBBlFcw0dgKkFYzqD4SG6qGS4alTASs2vRYtbJHOtbq5FHPKW4YJTijLX4hqhblP5ZKw4U46UWzb1HazXXDLBZDxLbS72MURmzzXDLv3vzefAwcXqGtcsKPGXq0XDX1DXP7MGfgJHOCYzqD4SG6qGS4alp)Qnr5)jKq8obRuPvJvaUAvEkymeDkak)lmLegxESfjP8HfaQdNfu3cOYygYu8Zljlp)Qnr5FG8a7ydslTASQ9RwLNcgdrNcGY)ctjHXLhBrskJXpGocwsZljDxCDxC6UjyHXyikNCguholOoeiloq3fx3fNURYik0mj4J9SAtKPGXq0P88R2eL)bYdSJniT0QXkCC1Q8uWyi6uau(xykjmU840DtWcJXquo5mOoCwqDiqwCGUlUURYik0mj4J9SAtKPGXq0XDX1DBN7EiSfjPmj4J9SAtKfeiBb0Dt3DFgQD1aj3Tzt3fBrskJXpGocwsZljD32wE(vBIY)a5b2XgKwA1yfoQAvEkymeDkak)lmLegxEC6UjyHXyikNCguholOoeiloq3Tzt3folOoeiloURCBURSZaU88R2eLhcKptAylIO0QXkCy1Q8uWyi6uau(xykjmU8TZDHZcQdbYIJ7k3M7k7mGD320DLjlV7kRUl)QLG6uqGgbD32wE(vBIY)a5b2XgKwA1qEzQwLNcgdrNcGY)ctjHXL)bYIDe0DLZDxvE(vBIY)tiH4DcwPsRgYVQAvE(vBIYBXBbjyLkpfmgIofaLwAPLpbjG2evd5LrEzwjZkzP8PXIWIDWY3EbMCekDC323D5xTjCxKbvy2LQ8WK0xnKV9XXLpPyKmev(2G72grqvS8QnH72EYc08aYLQn4UT3VoyKWDLxg8Cx5LrEzCPCPAdUB7boi6xu64UyK0ii39hqmwDxmANfWS7Id(FkPcD3yI2eilaLwqUl)Qnb0DNaHF2LIF1MaMtkOFaXyDtIq9ZaAbR2e4zsBQbsYjdU4mjPzgzjixk(vBcyoPG(beJ11B7HlGGt0tsQlf)QnbmNuq)aIX66T97eg4ycQpsDi)ctYEcptAtzefAENWahtq9rQd5xys2tzkymeDCP4xTjG5Kc6hqmwxVTholOUKjixk(vBcyoPG(beJ11B7T4TGeSs4zsB4uzefAgolOUKjOmfmgIoUuUuTb3T9ahe9lkDCxkbjW3DvdKCxfi5U8RJWDnO7YjydXyik7sXVAta3GjjeQJMhqUu8R2eW1B7HwSJ6G8o7DPCP4xTjGR32)mc15xTj6idQ4fmiTbKtmpEM0gqoX8D(vlbHl)QLG6uqGgbthWTPYik0SfsKiMmfmgIoRBNYik0SfsKiMmfmgIo4QmIcnBHsIGr9FaXwGQnrMcgdrN26sXVAtaxVT)zLFe(qq8mPnC2UKKMTqIebJY8Rwcc3ZOzdeCqSszbbYwaxVsUKKMTqIebJYccKTa22MnHjjeQRSyhPW8Zk)i8HGYTYLIF1MaUEB)ZiuNF1MOJmOIxWG0gpeEM0g)QLG6uqGgbLtExk(vBc46T9Wzb1LmbH3J)JOUYIDKc3wHNjTjijbbbYyicx4SG6qGS4K(MSXTD4uzefA(zLFe(qWmfmgIonB(ZGotAr(zLFe(qWSGazlGYjiq2cyBDP4xTjGR32BGGdIvcVh)hrDLf7ifUTcptAtqscccKXqeUTdNkJOqZpR8JWhcMPGXq0PzZFg0zslYpR8JWhcMfeiBbuobbYwaBRlf)QnbC92EdeCqSs4zsBkJOqZwOKiyu)hqSfOAtKPGXq0bx(vBI8dKhyhBqA2IUeY2buXvqGSfW0plcwTjKvzYa2LIF1MaUEB)ZiuNF1MOJmOIxWG02FGUu8R2eW1B7FgH68R2eDKbv8cgK2iiKINGUu8R2eW1B7FGCeeQFiWjKmb5sXVAtaxVThiNyE8E8Fe1vwSJu42k8mPTZOzdeCqSszbbYwaL7mA2abheRu(Siy1MqwLjd4MnXPYik0Sfkjcg1)beBbQ2ezkymeDCP4xTjGR32NGfgJHi8cgK2sodQdNfuhcKfhiEjy0cTXVAjOofeOrq5wH7pd6mPfzGCI5ZccKTaM(2kzA28NbDM0ImCbeCIUfsKiyuwqGSfW03wbyCvgrHMpSaqD4SG6wavgZqMIFMcgdrhC)zqNjTiFybG6Wzb1TaQmMHmf)SGazlGPVTcWnBQmIcnFybG6Wzb1TaQmMHmf)mfmgIo4(ZGotAr(Wca1HZcQBbuzmdzk(zbbYwatFBfGXTD)mOZKwKHlGGt0TqIebJYccKTakNYIDKMvdK660pg1S5pd6mPfz4ci4eDlKirWOSGazlGR)zqNjTidxabNOBHejcgLplcwTjKtzXosZQbsDD6hJARlf)QnbC92(FcjeVtWkHNjTHTijLX4hqhblP5ZKwGlCwqDiqwCKBBvgWTPmzzrwvgrHMLqme4KGezkymeDWfNjyHXyikNCguholOoeiloqxk(vBc46T9pqEGDSbP4zsBylss5dlauholOUfqLXmKP4Nxs6sXVAtaxVT)bYdSJnifptAdBrskJXpGocwsZljXfNjyHXyikNCguholOoeiloqCXPYik0mj4J9SAtKPGXq0XLIF1MaUEB)dKhyhBqkEM0gotWcJXquo5mOoCwqDiqwCG4QmIcntc(ypR2ezkymeDWTDhcBrsktc(ypR2ezbbYwat)zO2vdKA2eBrskJXpGocwsZljBRlf)QnbC92Eiq(mPHTic8mPnCMGfgJHOCYzqD4SG6qGS4aB2eolOoeiloYTj7mGDP4xTjGR32)a5b2XgKINjT1o4SG6qGS4i3MSZaUnLjlVSYVAjOofeOrW26sXVAtaxVT)NqcX7eSs4zsBpqwSJGYTYLIF1MaUEBVfVfKGvYLYLIF1MaM5HwVTxWw0hPUKji8mPTKKMTqIebJY8Rwcc32HZFg0zslYa5eZNfeFWVzt(vlb1PGanckNS0wxk(vBcyMhA92(hihbH6hcCcjtq4zsBNrZgi4GyLYccKTak3ZqTRgi5sXVAtaZ8qR32BGGdIvcVh)hrDLf7ifUTcptAtqGSfW0bmUTdNkJOqZpR8JWhcMPGXq0PzZFg0zslYpR8JWhcMfeiBbuobbYwaBRlf)QnbmZdTEB)ZiuNF1MOJmOIxWG02FGUu8R2eWmp06T9pJqD(vBIoYGkEbdsBeesXtqxk(vBcyMhA92EGCI5X7X)ruxzXosHBRWZK4xTeuNcc0iy6Y2LIF1MaM5HwVTxWw0hPUKjixk(vBcyMhA92EGCI5X7X)ruxzXosHBRCP4xTjGzEO1B7T4TGeSs4zsBkJOqZsMG6CC6ycdeQtqzkymeDWfBrskJXpGocwsZljXfolOoeiloPd42uMS8Yk)QLG6uqGgbDP4xTjGzEO1B7HZcQlzcYLIF1MaM5HwVT)NqcX7eSs4zsBylsszm(b0rWsA(mPfUu8R2eWmp06T9qG8zsdBre4zsBkl2rAgiXifyo5RPlVmUu8R2eWmp06T9w8wqcwjxkxk(vBcy(pW1B7HlGGt0TqIebJCP4xTjG5)axVT)Wca1HZcQBbuzmdzk(Uu8R2eW8FGR32NCuBc8mPTKKMTqIebJY8RwcYLIF1MaM)dC92EmsajbGSyhEM0wssZwirIGrz(vlb5sXVAtaZ)bUEBpgAMtxArGpEM0wssZwirIGrz(vlb5sXVAtaZ)bUEBVKjim0mh8mPTKKMTqIebJY8RwcYLIF1MaM)dC92(fi1nLaH4zsBjjnBHejcgL5xTeuZMkl2rAwnqQRt)yu6YlJlf)Qnbm)h46T9h6nqwTyxhBqQlf)Qnbm)h46T9gyskowSR)SYqvmjbs4zsB8RwcQtbbAeuUvnBInqOlf)Qnbm)h46T9Wzb1fJINjTXVAjOofeOrq5w1Sj2aHUu8R2eW8FGR32d)zryXUUAkqcptAJF1sqDkiqJGBRA28NbDM0ImqoX8zbbYwaLdWUuUu8R2eWmqoX8R32)tiH4Dcwj8mPnSfjPmg)a6iyjnFM0cCHZcQdbYIJCBRWfolOoeiloPVjBxk(vBcygiNy(1B7HZcQlzcYLIF1MaMbYjMF92E4plcl21vtbs4zsBpd1UAGu6a5eZ3feiBb0LIF1MaMbYjMF92EdeCqSs4zsBkJOqZwOKiyu)hqSfOAtKPGXq0bxbbYwat)Siy1MqwLjd4MnXPYik0Sfkjcg1)beBbQ2ezkymeDWvqscccKXqKlf)QnbmdKtm)6T9pqEGDSbP4zsBpd1UAGu6a5eZ3feiBb0LIF1MaMbYjMF92Eiq(mPHTicxk(vBcygiNy(1B7T4TGeSs4zsBpd1UAGu6a5eZ3feiBb0LYLIF1MaMjiKINGR32N2iqNeKfDbbNGJNCP4xTjGzccP4j46T9Ge4iWVpsD0YBN(rqmi0LIF1MaMjiKINGR32JHM50hPUcK6uqG47sXVAtaZeesXtW1B73TWIJXrFK6moajgfOlf)QnbmtqifpbxVTxyjtIOUfDys(jxk(vBcyMGqkEcUEBV08lq60zCasyk1Xig0LIF1MaMjiKINGR32NCrys4BXUogIHQlf)QnbmtqifpbxVTxqCsl21LqmibXZK2uwSJ0mqIrkWEYxLdhjtZMkl2rAgiXifyp5RPlVmnBkz7aQDbbYwatxEzA2uzXosZQbsDD6jFTlVmYjBzCP4xTjGzccP4j46T9)epfQGv60Lqmi5sXVAtaZeesXtW1B7vGuFjWML40LgXt4zsBylsszb9acrqyxAepLfeiBbS0sRca]] )


end
