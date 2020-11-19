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


    spec:RegisterPack( "Destruction", 20201117, [[diKMVaqiaQhruiBcsAuefDkIQSkIQYRuunliv3cGODjQFPcggrPJbGLru5zaKMMuv6AqI2Muv4BaegNuv05iQQADevvQ5jsCpv0(ejDqIQkzHQqpKOGQjsuvXfjkGojrbQvksTtPINk0uLk9vIck7vYFLYGvPdJAXa9yvnzfUmYMjYNLQmAaDAkRMOa51qcZg0THy3u9BLgUiCCIcWYj8COMoPRRiBxe9DPQA8efQZdPSEIcY8vu2VGlaQUvCWkvDKtw5KfaaaOpZYjlGkhGk)ROIwcQIj4hfCpQIoJqvu(HWQy6vB9kMGrdU8O6wr8ojEQIavnbw(9Hd9mf4ey(xKdydzcYQT(lyj9a2q(dveCYGQmyVaR4GvQ6iNSYjlaaaqFMLtwavoaTpRipPaxrfJgIm8kc0gdYlWkoi8xrzu4k)qyvm9QTE4kdJfW9rriTmkC7SjjeqseUaaiqpCLtw5KTIqdR4QBfjmM8NWv3Qdav3kYVARxX(xbCKKmVji86S)ufjNbH0OowA1rUQBf5xT1RicHSc0ARudo92OneeJGRi5miKg1XsRoaA1TI8R26veeU7OTsnfi1iNqqRIKZGqAuhlT603QBf5xT1RyVjwmm2BRuJLHiXQaRi5miKg1XsRoOS6wr(vB9kkSejGuZ8gob)ufjNbH0OowA1PpQUvKF1wVIs7pHPrJLHiHPudKyKksodcPrDS0QdGO6wr(vB9kMysysOzEVgiKXAfjNbH0OowA1PpRUvKCgesJ6yfFHPKW4kQSOhPzGedvGTeVgUPgU9PSH7SzHRYIEKMbsmub2s8A4Ms4kNSH7SzHRK1dO2eecBooCtjCLt2WD2SWvzrpsZQHqnDBjETjNSHBQHBFLTI8R26vuqCcZ71KGmcHlT6i)RUvKF1wVI)6p5QGvA0KGmcvrYzqinQJLwDaq2QBfjNbH0OowXxykjmUIGtsszb9OasyCtAfpLfecBoUI8R26vubsTjhCN8rtAfpvAPveiNC)QB1bGQBfjNbH0OowXxykjmUIGtsszq(rXqWsAES97HlQHlENGnmqwmc3updxacxudx8obByGSyeUPCgU9TI8R26v8xxcY9eSsLwDKR6wrYzqinQJv8fMscJR4ZyTPgcfUPeUa5K73eecBoUI8R26veVtWMKjOsRoaA1TIKZGqAuhR4lmLegxXNXAtnekCtjCbYj3Vjie2CC4IA4I3jiO5JmK4rdeTgjJzKeqktodcPrf5xT1R4GEdHvZ71axOwA1PVv3ksodcPrDSIVWusyCfFgRn1qOWnLWfiNC)MGqyZXvKF1wVI4FNeM3RPMcKkT6GYQBfjNbH0OowXxykjmUIkdjxZMRKWzy7xeWjSARNjNbH0iCrnCfecBooCtjChtcwT1dx5lCLnJYWD2SWfWHRYqY1S5kjCg2(fbCcR26zYzqincxudxbjjimqgesvKF1wVIgcYczLkT60hv3ksodcPrDSIVWusyCfFgRn1qOWnLWfiNC)MGqyZXvKF1wVIpqEXnWfQLwDaev3kYVARxrmqES9doj8ksodcPrDS0QtFwDRi5miKg1Xk(ctjHXv8zS2udHc3ucxGCY9BccHnhxr(vB9kA(BojyLkT0kMqq)IaYA1T6aq1TIKZGqAuhR4lmLegxr1qOWn1Wv2Wf1WfWHBcsZm0ssvKF1wVIseSnweZz1wV0QJCv3kYVARxr8ecY6ndjrfjNbH0OowA1bqRUvKCgesJ6yfFHPKW4kQmKCn3tyiRjO2k1W8lmj7Pm5miKgvKF1wVI9egYAcQTsnm)ctYEQ0QtFRUvKF1wVI4Dc2KmbvrYzqinQJLwDqz1TIKZGqAuhR4lmLegxrahUkdjxZ4Dc2KmbLjNbH0OI8R26v083CsWkvAPvKxQ6wDaO6wrYzqinQJv8fMscJRycsZMlrcNHz(vljfUOgUYmCbC4(7chB)EgiNC)SG4bAH7SzHl)QLKAKtigHd3udxanCLxf5xT1ROGnVTsnjtqLwDKR6wr(vB9kI3jytSAfjNbH0OowA1bqRUvKCgesJ6yfFHPKW4kownBiilKvklie2CC4MA4(mwBQHqvKF1wVIpq2Dc2geY6sMGkT603QBfjNbH0Oowr(vB9kAiilKvQIVWusyCffecBooCtjCrz4IA4kZWfWHRYqY18Zk)q0WizYzqinc3zZc3Fx4y73ZpR8drdJKfecBooCtnCfecBooCLxfF0Ei1uw0JuC1bGsRoOS6wrYzqinQJvKF1wVIpdHn(vB9g0WAfHgwBoJqv8h4sRo9r1TIKZGqAuhRi)QTEfFgcB8R26nOH1kcnS2CgHQiHXK)eU0QdGO6wrYzqinQJvKF1wVIa5K7xXhThsnLf9ifxDaO0QtFwDRi)QTEffS5TvQjzcQIKZGqAuhlT6i)RUvKCgesJ6yf5xT1Riqo5(v8r7HutzrpsXvhakT6aGSv3ksodcPrDSIVWusyCfLz4I3jiO5JmK4rdeTgjJzKeqktodcPr4oBw4c4Wvzi5AwYeuJ9rduyiyDDktodcPr4kVkYVARxXb9gcRM3RbUqT0QdaauDRi5miKg1Xk(ctjHXvuzi5AwYeuJ9rduyiyDDktodcPr4IA4cojjLb5hfdblP5PeHlQHlENGnmqwmc3ucxugUaYWv2SCHR8fU8RwsQroHyeUI8R26v083CsWkvA1ba5QUvKF1wVI4Dc2KmbvrYzqinQJLwDaaqRUvKCgesJ6yfFHPKW4kcojjLb5hfdblP5X2Vxr(vB9k(Rlb5EcwPsRoa03QBfjNbH0OowXxykjmUIkl6rAgiXqfyoXRHBkHRCYwr(vB9kIbYJTFWjHxA1bauwDRi5miKg1Xk(ctjHXveWHRmdxLHKRzjtqn2hnqHHG11Pm5miKgH7SzHRYqY1S5sKW3m5miKgHR8Qi)QTEfX)ojmVxtnfivA1bG(O6wrYzqinQJv8fMscJRiGdxzgUkdjxZsMGASpAGcdbRRtzYzqinc3zZcxLHKRzZLiHVzYzqincx5vr(vB9kAijiFyEV2ZkJvXMaivA1baar1TI8R26v083CsWkvrYzqinQJLwAf)bU6wDaO6wr(vB9kINqqwVzUejCgwrYzqinQJLwDKR6wr(vB9koybkA4Dc2mhRmObnfTksodcPrDS0QdGwDRi5miKg1Xk(ctjHXvmbPzZLiHZWm)QLKQi)QTEftSQTEPvN(wDRi5miKg1Xk(ctjHXvmbPzZLiHZWm)QLKQi)QTEfbjbMeOW8ELwDqz1TIKZGqAuhR4lmLegxXeKMnxIeodZ8RwsQI8R26veeU7OjnjqR0QtFuDRi5miKg1Xk(ctjHXvmbPzZLiHZWm)QLKQi)QTEfLmbbc3DuA1bquDRi5miKg1Xk(ctjHXvmbPzZLiHZWm)QLKc3zZcxLf9inRgc10TnmkCtjCLt2kYVARxXjm1mLqWLwAfhKepb1QB1bGQBf5xT1RiobbHn4(OOIKZGqAuhlT6ix1TI8R26veBEpQHW9SVIKZGqAuhlT6aOv3ksodcPrDSIVWusyCfbYj3VXVAjPWf1WLF1ssnYjeJWHBQHlaHlQHl)QLKAKtigHd3ucxugUaYWvzi5A2Cjs4BMCgesJWDE4kZWvzi5A2Cjs4BMCgesJWf1Wvzi5A2CLeodB)IaoHvB9m5miKgHR8Qi)QTEfFgcB8R26nOH1kcnS2CgHQiqo5(LwD6B1TIKZGqAuhR4lmLegxrahUYmCtqA2Cjs4mmZVAjPWf1WDSA2qqwiRuwqiS54WDE4cq4MA4MG0S5sKWzywqiS54WvEH7SzHlobbHnLf9ifNFw5hIggjCtnCbOI8R26v8zLFiAyKsRoOS6wrYzqinQJv8fMscJRi)QLKAKtigHd3udx5Qi)QTEfFgcB8R26nOH1kcnS2CgHQiVuPvN(O6wrYzqinQJvKF1wVI4Dc2KmbvXxykjmUIcssqyGmiKcxudx8obByGSyeUPCgU9nCrnCLz4c4Wvzi5A(zLFiAyKm5miKgH7SzH7VlCS975Nv(HOHrYccHnhhUPgUccHnhhUYRIpApKAkl6rkU6aqPvhar1TIKZGqAuhRi)QTEfneKfYkvXxykjmUIcssqyGmiKcxudxzgUaoCvgsUMFw5hIggjtodcPr4oBw4(7chB)E(zLFiAyKSGqyZXHBQHRGqyZXHR8Q4J2dPMYIEKIRoauA1PpRUvKCgesJ6yfFHPKW4kQmKCnBUscNHTFraNWQTEMCgesJWf1WLF1wp)a5f3axOMnVjbTEa1Wf1WvqiS54WnLWDmjy1wpCLVWv2mkRi)QTEfneKfYkvA1r(xDRi5miKg1XkYVARxXNHWg)QTEdAyTIqdRnNrOk(dCPvhaKT6wrYzqinQJvKF1wVIpdHn(vB9g0WAfHgwBoJqvKWyYFcxA1baaQUvKF1wVIpq2Dc2geY6sMGQi5miKg1XsRoaix1TI8R26ve)7KW8En1uGufjNbH0OowA1baaT6wr(vB9koO3qy18EnWfQvKCgesJ6yPvha6B1TIKZGqAuhRi)QTEfbYj3VIVWusyCfhRMneKfYkLfecBooCtnChRMneKfYkLhtcwT1dx5lCLnJYWD2SWfWHRYqY1S5kjCg2(fbCcR26zYzqinQ4J2dPMYIEKIRoauA1bauwDRi)QTEfnKeKpmVx7zLXQytaKQi5miKg1XsRoa0hv3kYVARxr8obBIvRi5miKg1XsRoaaiQUvKCgesJ6yfFHPKW4kkMCsAf9O8oenmqUFyBLAkqQHgIjKbXImjdyYsKGgvKF1wVIa5K7xA1bG(S6wrYzqinQJvCturmPvKF1wVIjzHXGqQIjz4evr(vlj1iNqmchUPgUaeUOgU)UWX2VNbYj3plie2CC4MYz4cGSH7SzH7VlCS97z8ecY6nZLiHZWSGqyZXHBkNHlaOmCrnCvgsUMhSafn8obBMJvg0GMIwMCgesJWf1W93fo2(98GfOOH3jyZCSYGg0u0YccHnhhUPCgUaGYWD2SWvzi5AEWcu0W7eSzowzqdAkAzYzqincxud3Fx4y73ZdwGIgENGnZXkdAqtrllie2CC4MYz4cakdxudxzgU)UWX2VNXtiiR3mxIeodZccHnhhUPgUkl6rAwneQPBByu4oBw4(7chB)EgpHGSEZCjs4mmlie2CC4opC)DHJTFpJNqqwVzUejCgMhtcwT1d3udxLf9inRgc10TnmkCLxftYIMZiuftSlSH3jyddKfdCPvhaK)v3ksodcPrDSIVWusyCfbNKKYG8JIHGL08y73dxudx8obByGSyeUPEgUaKrz4cidxzZaA4kFHRYqY1SeKXa3KKitodcPr4IA4c4Wnjlmges5e7cB4Dc2WazXaxr(vB9k(Rlb5EcwPsRoYjB1TIKZGqAuhR4lmLegxrWjjP8GfOOH3jyZCSYGg0u0YtjQi)QTEfFG8IBGlulT6ihav3ksodcPrDSIVWusyCfbNKKYG8JIHGL08uIWf1WfWHBswymiKYj2f2W7eSHbYIboCrnCbC4QmKCntcEypR26zYzqinQi)QTEfFG8IBGlulT6iNCv3ksodcPrDSIVWusyCfbC4MKfgdcPCIDHn8obByGSyGdxudxLHKRzsWd7z1wptodcPr4IA4kZWDqGtsszsWd7z1wplie2CC4Ms4(mwBQHqH7SzHl4KKugKFumeSKMNseUYRI8R26v8bYlUbUqT0QJCaA1TIKZGqAuhR4lmLegxrahUjzHXGqkNyxydVtWggilg4WD2SWfVtWggilgHBQNHBFZOSI8R26vedKhB)GtcV0QJC9T6wrYzqinQJv8fMscJROmdx8obByGSyeUPEgU9nJYWfqgUYMLlCLVWLF1ssnYjeJWHR8Qi)QTEfFG8IBGlulT6ihkRUvKCgesJ6yfFHPKW4k(azrpchUPgUaur(vB9k(Rlb5EcwPsRoY1hv3kYVARxrZFZjbRufjNbH0OowAPLwXKKaBRxDKtw5KfazLt2k2plCZ7HROmyKeRqPr42hHl)QTE4cnSIZH0veNG(QJC9bGOIjeRKbPkkJcx5hcRIPxT1dxzySaUpkcPLrHBNnjHasIWfaab6HRCYkNSH0H0YOWvgOmM(jLgHlijTckC)fbK1WfK6zoohUYV(NsO4W1xhqcKfistWWLF1whhURdrlhsZVARJZje0ViGSEkrW2yrmNvBD0nPt1qOuLfvaNG0mdTKuin)QTooNqq)IaY68Zd4jeK1BjinKMF1whNtiOFrazD(5HEcdznb1wPgMFHjzpHUjDQmKCn3tyiRjO2k1W8lmj7Pm5miKgH08R264Ccb9lciRZppG3jytYeuin)QTooNqq)IaY68ZdM)Mtcwj0nPtaRmKCnJ3jytYeuMCgesJq6qAzu4kdugt)KsJWLssc0cx1qOWvbsHl)6kcxdhUCs2GmiKYH08R264tCcccBW9rrin)QToE(5bS59Ogc3Z(q6qA(vBD85ZqyJF1wVbnSIUZi0jqo5(OBsNa5K734xTKeQ8RwsQroHyeovaqLF1ssnYjeJWPGsaPYqY1S5sKW3m5miKgZLPYqY1S5sKW3m5miKgOQmKCnBUscNHTFraNWQTEMCgesd5fsZVARJNFE4zLFiAye0nPtalZeKMnxIeodZ8Rwsc1XQzdbzHSszbHWMJNdqQjinBUejCgMfecBowEZMHtqqytzrpsX5Nv(HOHrsfGqA(vBD88ZdpdHn(vB9g0Wk6oJqN8sOBsN8RwsQroHyeov5cP5xT1XZppG3jytYee6pApKAkl6rk(ea0nPtbjjimqgesOI3jyddKfJuo7lQYeWkdjxZpR8drdJKjNbH0y2SFx4y73ZpR8drdJKfecBoovbHWMJLxin)QToE(5bdbzHSsO)O9qQPSOhP4taq3KofKKGWazqiHQmbSYqY18Zk)q0WizYzqinMn73fo2(98Zk)q0WizbHWMJtvqiS5y5fsZVARJNFEWqqwiRe6M0PYqY1S5kjCg2(fbCcR26zYzqinqLF1wp)a5f3axOMnVjbTEavufecBooLXKGvBD5t2mkdP5xT1XZpp8me24xT1BqdRO7mcD(dCin)QToE(5HNHWg)QTEdAyfDNrOtcJj)jCin)QToE(5Hhi7obBdczDjtqH08R2645NhW)ojmVxtnfifsZVARJNFEyqVHWQ59AGludP5xT1XZppaKtUp6pApKAkl6rk(ea0nPZXQzdbzHSszbHWMJtDSA2qqwiRuEmjy1wx(KnJYzZaSYqY1S5kjCg2(fbCcR26zYzqincP5xT1XZppyijiFyEV2ZkJvXMaifsZVARJNFEaVtWMy1qA(vBD88Zda5K7JUjDkMCsAf9O8oenmqUFyBLAkqQHgIjKbXImjdyYsKGgH08R2645NhsYcJbHe6oJqNj2f2W7eSHbYIbg9KmCIo5xTKuJCcXiCQaG6VlCS97zGCY9ZccHnhNYjaYoB2VlCS97z8ecY6nZLiHZWSGqyZXPCcakrvzi5AEWcu0W7eSzowzqdAkAzYzqinq93fo2(98GfOOH3jyZCSYGg0u0YccHnhNYjaOC2mLHKR5blqrdVtWM5yLbnOPOLjNbH0a1Fx4y73ZdwGIgENGnZXkdAqtrllie2CCkNaGsuL5VlCS97z8ecY6nZLiHZWSGqyZXPQSOhPz1qOMUTHrZM97chB)EgpHGSEZCjs4mmlie2C88Fx4y73Z4jeK1BMlrcNH5XKGvB9uvw0J0SAiut32Wi5fsZVARJNFE4xxcY9eSsOBsNGtsszq(rXqWsAES97OI3jyddKfJupbiJsaPSzav(ugsUMLGmg4MKezYzqinqfWjzHXGqkNyxydVtWggilg4qA(vBD88ZdpqEXnWfQOBsNGtss5blqrdVtWM5yLbnOPOLNsesZVARJNFE4bYlUbUqfDt6eCsskdYpkgcwsZtjqfWjzHXGqkNyxydVtWggilgyubSYqY1mj4H9SARNjNbH0iKMF1whp)8WdKxCdCHk6M0jGtYcJbHuoXUWgENGnmqwmWOQmKCntcEypR26zYzqinqvMdcCssktcEypR26zbHWMJt5zS2udHMndCsskdYpkgcwsZtjKxin)QToE(5bmqES9dojC0nPtaNKfgdcPCIDHn8obByGSyGNndVtWggilgPE23mkdP5xT1XZpp8a5f3axOIUjDkt8obByGSyK6zFZOeqkBwo5JF1ssnYjeJWYlKMF1whp)8WVUeK7jyLq3KoFGSOhHtfGqA(vBD88ZdM)MtcwPq6qA(vBDCMxA(5bbBEBLAsMGq3KotqA2Cjs4mmZVAjjuLjG)DHJTFpdKtUFwq8aTzZ4xTKuJCcXiCQaQ8cP5xT1XzEP5NhW7eSjwnKMF1whN5LMFE4bYUtW2GqwxYee6M05y1SHGSqwPSGqyZXP(mwBQHqH08R264mV08ZdgcYczLq)r7HutzrpsXNaGUjDkie2CCkOevzcyLHKR5Nv(HOHrYKZGqAmB2VlCS975Nv(HOHrYccHnhNQGqyZXYlKMF1whN5LMFE4ziSXVAR3Ggwr3ze68h4qA(vBDCMxA(5HNHWg)QTEdAyfDNrOtcJj)jCin)QTooZln)8aqo5(O)O9qQPSOhP4taq3K4xTKuJCcXiCk9nKMF1whN5LMFEqWM3wPMKjOqA(vBDCMxA(5bGCY9r)r7HutzrpsXNaesZVARJZ8sZppmO3qy18EnWfQOBsNYeVtqqZhziXJgiAnsgZijGuMCgesJzZaSYqY1SKjOg7JgOWqW66uMCgesd5fsZVARJZ8sZppy(BojyLq3KovgsUMLmb1yF0afgcwxNYKZGqAGk4KKugKFumeSKMNsGkENGnmqwmsbLaszZYjF8RwsQroHyeoKMF1whN5LMFEaVtWMKjOqA(vBDCMxA(5HFDji3tWkHUjDcojjLb5hfdblP5X2VhsZVARJZ8sZppGbYJTFWjHJUjDQSOhPzGedvG5eVMICYgsZVARJZ8sZppG)DsyEVMAkqcDt6eWYuzi5AwYeuJ9rduyiyDDktodcPXSzkdjxZMlrcFZKZGqAiVqA(vBDCMxA(5bdjb5dZ71EwzSk2eaj0nPtaltLHKRzjtqn2hnqHHG11Pm5miKgZMPmKCnBUej8ntodcPH8cP5xT1XzEP5Nhm)nNeSsH0H08R2648pWZppGNqqwVzUejCggsZVARJZ)ap)8WGfOOH3jyZCSYGg0u0cP5xT1X5FGNFEiXQ26OBsNjinBUejCgM5xTKuin)QToo)d88ZdGKatcuyEp0nPZeKMnxIeodZ8RwskKMF1whN)bE(5bq4UJM0Kan0nPZeKMnxIeodZ8RwskKMF1whN)bE(5bjtqGWDhOBsNjinBUejCgM5xTKuin)QToo)d88ZdtyQzkHGr3KotqA2Cjs4mmZVAjPzZuw0J0SAiut32WOuKt2q6qA(vBDCgiNC)5Nh(1LGCpbRe6M0j4KKugKFumeSKMhB)oQ4Dc2WazXi1taqfVtWggilgPC23qA(vBDCgiNC)5NhW7eSjzccDt68zS2udHsbiNC)MGqyZXH08R264mqo5(ZppmO3qy18EnWfQOBsNpJ1MAiuka5K73eecBogv8obbnFKHepAGO1izmJKaszYzqincP5xT1XzGCY9NFEa)7KW8En1uGe6M05ZyTPgcLcqo5(nbHWMJdP5xT1XzGCY9NFEWqqwiRe6M0PYqY1S5kjCg2(fbCcR26zYzqinqvqiS54ugtcwT1LpzZOC2maRmKCnBUscNHTFraNWQTEMCgesdufKKGWazqifsZVARJZa5K7p)8WdKxCdCHk6M05ZyTPgcLcqo5(nbHWMJdP5xT1XzGCY9NFEadKhB)GtcpKMF1whNbYj3F(5bZFZjbRe6M05ZyTPgcLcqo5(nbHWMJdPdP5xT1XzcJj)j88Zd9Vc4ijzEtq41z)PqA(vBDCMWyYFcp)8acHSc0ARudo92OneeJGdP5xT1XzcJj)j88ZdGWDhTvQPaPg5ecAH08R264mHXK)eE(5HEtSyyS3wPgldrIvbgsZVARJZegt(t45NhewIeqQzEdNGFkKMF1whNjmM8NWZppiT)eMgnwgIeMsnqIrcP5xT1XzcJj)j88ZdjMeMeAM3RbczSgsZVARJZegt(t45NheeNW8EnjiJqy0nPtLf9indKyOcSL41u7tzNntzrpsZajgQaBjEnf5KD2mjRhqTjie2CCkYj7Szkl6rAwneQPBlXRn5Kn1(kBin)QTootym5pHNFE4x)jxfSsJMeKrOqA(vBDCMWyYFcp)8GcKAto4o5JM0kEcDt6eCssklOhfqcJBsR4PSGqyZXLwAva]] )


end
