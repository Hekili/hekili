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

            last = function ()
                local app = state.debuff.immolate.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return state.debuff.immolate.tick_time end,
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


    spec:RegisterPack( "Destruction", 20201120, [[di0AWaqiiHhjss2eK0OiQ0PiQyvIK4vkkZcs1TaO0Ue1VuunmIshdalJOQNruW0ik6AaKTjsQ(MiPmoakohrHyDefsnprI7PI2NuvoOijvwOk0dfjPQjkss5IaujNeGkSsPIDks9uHMQuLVcqfTxj)vkdwLomQfd0Jv1Kv4YiBMiFwQ0Ob0PPSAaQuVgs0SbDBi2nv)wPHlchNOqYYj8COMoPRRiBxe9DPQA8efQZdPSEaQA(QG9l4cGQxfhSsvA5LvEzbaa5LnllGrMYuwzwrfTeuftWpk5UufDgHQyQgHvX0R26vmbJgC5r1RI4Ds8ufbQAcSm65Z7AkWjW8ViZXgYeKvB9xWs6CSH8ZRi4KbvahEbwXbRuLwEzLxwaaqEzZYcyKPmLvgQipPaxrfJgsQ(kc0gdYlWkoi8xXuv4MQryvm9QTE4c4KfW9rzOtQkCtVjjeqseUYll6HR8YkVSveAyfx9QiHXK)eU6vPbO6vr(vB9k2)kGJKK5nbHxN9NQi5miKg1XsR0Yx9Qi)QTEfriKvGwBLAWP3gTHGyeCfjNbH0OowALwgQEvKF1wVIGWDhTvQPaPg5ecAvKCgesJ6yPvAzw9Qi)QTEf7oXIHXEBLAmGNeRcSIKZGqAuhlTsdOQxf5xT1ROWsKasnZB4e8tvKCgesJ6yPv6uV6vr(vB9kkT)eMgngWtctPgiXivKCgesJ6yPv6uR6vr(vB9kMysysOzE3giKXAfjNbH0OowALgWu9Qi5miKg1Xk(ctjHXvuzrxsZajgQaBjEnC7lCbmYgUhoeUkl6sAgiXqfylXRHBkHR8YgUhoeUswxGAtqiS54WnLWvEzd3dhcxLfDjnRgc10TL41M8YgU9fUYu2kYVARxrbXjmVBtcYieU0kTms1RI8R26v8x)jxfSsJMeKrOksodcPrDS0knaYw9Qi5miKg1Xk(ctjHXveCssklOhLqcJBsR4PSGqyZXvKF1wVIkqQn5G7KpAsR4PslTIa5K7x9Q0au9Qi5miKg1Xk(ctjHXveCsskdYpkhcwsZJTFpCrnCX7eSHbYIr423z4cq4IA4I3jyddKfJWnLZWvMvKF1wVI)6sqURGvQ0kT8vVksodcPrDSIVWusyCfFgRn1qOWnLWfiNC)MGqyZXvKF1wVI4Dc2KmbvALwgQEvKCgesJ6yfFHPKW4k(mwBQHqHBkHlqo5(nbHWMJdxudx8obbnFKHepAGO1izmJKaszYzqinQi)QTEfh0BiSAE3g4c1sR0YS6vrYzqinQJv8fMscJR4ZyTPgcfUPeUa5K73eecBoUI8R26ve)7KW8Un1uGuPvAav9Qi5miKg1Xk(ctjHXvuzi5A2CLeodB)IaoHvB9m5miKgHlQHRGqyZXHBkH7ysWQTE4MkHRSzafUhoeUOiCvgsUMnxjHZW2ViGty1wptodcPr4IA4kijbHbYGqQI8R26v0qqwiRuPv6uV6vrYzqinQJv8fMscJR4ZyTPgcfUPeUa5K73eecBoUI8R26v8bYlUbUqT0kDQv9Qi)QTEfXa5X2p4KWRi5miKg1XsR0aMQxfjNbH0OowXxykjmUIpJ1MAiu4Ms4cKtUFtqiS54kYVARxrZFZjbRuPLwXec6xeqwREvAaQEvKCgesJ6yfFHPKW4kQgcfU9fUYgUOgUOiCtqAMHwsQI8R26vuIGTXIyoR26LwPLV6vr(vB9kINqqwVzijQi5miKg1XsR0Yq1RIKZGqAuhR4lmLegxrLHKR5Ucdznb1wPgMFHjzpLjNbH0OI8R26vSRWqwtqTvQH5xys2tLwPLz1RI8R26veVtWMKjOksodcPrDS0knGQEvKCgesJ6yfFHPKW4kIIWvzi5AgVtWMKjOm5miKgvKF1wVIM)MtcwPslTI8svVknavVksodcPrDSIVWusyCftqA2Cjs4mmZVAjPWf1WvUHlkc3Fx4y73Za5K7NfepqlCpCiC5xTKuJCcXiC42x4kdHRCQi)QTEffS5TvQjzcQ0kT8vVkYVARxr8obBIvRi5miKg1XsR0Yq1RIKZGqAuhR4lmLegxXXQzdbzHSszbHWMJd3(c3NXAtneQI8R26v8bYUtW2GqwxYeuPvAzw9Qi5miKg1XkYVARxrdbzHSsv8fMscJROGqyZXHBkHlGcxudx5gUOiCvgsUMFw5hIggjtodcPr4E4q4(7chB)E(zLFiAyKSGqyZXHBFHRGqyZXHRCQ4J2dPMYIUKIR0auALgqvVksodcPrDSI8R26v8ziSXVAR3GgwRi0WAZzeQI)axALo1REvKCgesJ6yf5xT1R4ZqyJF1wVbnSwrOH1MZiufjmM8NWLwPtTQxfjNbH0Oowr(vB9kcKtUFfF0Ei1uw0LuCLgGsR0aMQxf5xT1ROGnVTsnjtqvKCgesJ6yPvAzKQxfjNbH0Oowr(vB9kcKtUFfF0Ei1uw0LuCLgGsR0aiB1RIKZGqAuhR4lmLegxr5gU4DccA(idjE0arRrYygjbKYKZGqAeUhoeUOiCvgsUMLmb1yF0afgcwxNYKZGqAeUYPI8R26vCqVHWQ5DBGlulTsdaavVksodcPrDSIVWusyCfvgsUMLmb1yF0afgcwxNYKZGqAeUOgUGtsszq(r5qWsAEkr4IA4I3jyddKfJWnLWfqHlGnCLnlF4MkHl)QLKAKtigHRi)QTEfn)nNeSsLwPbq(Qxf5xT1RiENGnjtqvKCgesJ6yPvAaKHQxfjNbH0OowXxykjmUIGtsszq(r5qWsAES97vKF1wVI)6sqURGvQ0knaYS6vrYzqinQJv8fMscJROYIUKMbsmubMt8A4Ms4kVSvKF1wVIyG8y7hCs4LwPbaqvVksodcPrDSIVWusyCfrr4k3Wvzi5AwYeuJ9rduyiyDDktodcPr4E4q4QmKCnBUej8ntodcPr4kNkYVARxr8VtcZ72utbsLwPbi1REvKCgesJ6yfFHPKW4kIIWvUHRYqY1SKjOg7JgOWqW66uMCgesJW9WHWvzi5A2Cjs4BMCgesJWvovKF1wVIgscYhM3T9SYyvSjasLwPbi1QEvKF1wVIM)MtcwPksodcPrDS0sR4pWvVknavVkYVARxr8ecY6nZLiHZWksodcPrDS0kT8vVkYVARxXblqzdVtWM5yLbnOPOvrYzqinQJLwPLHQxfjNbH0OowXxykjmUIjinBUejCgM5xTKuf5xT1RyIvT1lTslZQxfjNbH0OowXxykjmUIjinBUejCgM5xTKuf5xT1RiijWKaLM3T0knGQEvKCgesJ6yfFHPKW4kMG0S5sKWzyMF1ssvKF1wVIGWDhnPjbALwPt9QxfjNbH0OowXxykjmUIjinBUejCgM5xTKuf5xT1ROKjiq4UJsR0Pw1RIKZGqAuhR4lmLegxXeKMnxIeodZ8RwskCpCiCvw0L0SAiut32WOWnLWvEzRi)QTEfNWuZucbxAPvCqs8euREvAaQEvKF1wVI4eee2G7JYksodcPrDS0kT8vVkYVARxrS5DPgc31(ksodcPrDS0kTmu9Qi5miKg1Xk(ctjHXveiNC)g)QLKcxudx(vlj1iNqmchU9fUaeUOgU8RwsQroHyeoCtjCbu4cydxLHKRzZLiHVzYzqinc3zHRCdxLHKRzZLiHVzYzqincxudxLHKRzZvs4mS9lc4ewT1ZKZGqAeUYPI8R26v8ziSXVAR3GgwRi0WAZzeQIa5K7xALwMvVksodcPrDSIVWusyCfvgsUMfllmVBdeYaEktodcPr4IA4oiWjjPSyzH5DBGqgWtzbHWMJd3ucxaYaQI8R26v8xxcYDfSsLwPbu1RIKZGqAuhR4lmLegxrueUYnCtqA2Cjs4mmZVAjPWf1WDSA2qqwiRuwqiS54WDw4cq42x4MG0S5sKWzywqiS54WvoH7HdHlobbHnLfDjfNFw5hIggjC7lCbOI8R26v8zLFiAyKsR0PE1RIKZGqAuhR4lmLegxr(vlj1iNqmchU9fUYxr(vB9k(me24xT1BqdRveAyT5mcvrEPsR0Pw1RIKZGqAuhRi)QTEfX7eSjzcQIVWusyCffKKGWazqifUOgU4Dc2WazXiCt5mCLz4IA4k3WffHRYqY18Zk)q0WizYzqinc3dhc3Fx4y73ZpR8drdJKfecBooC7lCfecBooCLtfF0Ei1uw0LuCLgGsR0aMQxfjNbH0Oowr(vB9kAiilKvQIVWusyCffKKGWazqifUOgUYnCrr4QmKCn)SYpenmsMCgesJW9WHW93fo2(98Zk)q0WizbHWMJd3(cxbHWMJdx5uXhThsnLfDjfxPbO0kTms1RIKZGqAuhR4lmLegxrLHKRzZvs4mS9lc4ewT1ZKZGqAeUOgU8R265hiV4g4c1S5njO1fOgUOgUccHnhhUPeUJjbR26HBQeUYMbuf5xT1ROHGSqwPsR0aiB1RIKZGqAuhRi)QTEfFgcB8R26nOH1kcnS2CgHQ4pWLwPbaGQxfjNbH0Oowr(vB9k(me24xT1BqdRveAyT5mcvrcJj)jCPvAaKV6vr(vB9k(az3jyBqiRlzcQIKZGqAuhlTsdGmu9Qi)QTEfX)ojmVBtnfivrYzqinQJLwPbqMvVkYVARxXb9gcRM3TbUqTIKZGqAuhlTsdaGQEvKCgesJ6yf5xT1Riqo5(v8fMscJR4y1SHGSqwPSGqyZXHBFH7y1SHGSqwP8ysWQTE4MkHRSzafUhoeUOiCvgsUMnxjHZW2ViGty1wptodcPrfF0Ei1uw0LuCLgGsR0aK6vVkYVARxrdjb5dZ72EwzSk2eaPksodcPrDS0knaPw1RI8R26veVtWMy1ksodcPrDS0knaaMQxfjNbH0OowXxykjmUIIjNKwrxkVdrddK7h2wPMcKAOHyca3SitYOMSejOrf5xT1Riqo5(LwPbqgP6vrYzqinQJvCturmPvKF1wVIjzHXGqQIjz4evr(vlj1iNqmchU9fUaeUOgU)UWX2VNbYj3plie2CC4MYz4cGSH7HdH7VlCS97z8ecY6nZLiHZWSGqyZXHBkNHlaakCrnCvgsUMhSaLn8obBMJvg0GMIwMCgesJWf1W93fo2(98GfOSH3jyZCSYGg0u0YccHnhhUPCgUaaOW9WHWvzi5AEWcu2W7eSzowzqdAkAzYzqincxud3Fx4y73ZdwGYgENGnZXkdAqtrllie2CC4MYz4caGcxudx5gU)UWX2VNXtiiR3mxIeodZccHnhhU9fUkl6sAwneQPBByu4E4q4(7chB)EgpHGSEZCjs4mmlie2CC4olC)DHJTFpJNqqwVzUejCgMhtcwT1d3(cxLfDjnRgc10TnmkCLtftYIMZiuftSlSH3jyddKfdCPvA5LT6vrYzqinQJv8fMscJRi4KKugKFuoeSKMhB)E4IA4I3jyddKfJWTVZWfGmGcxaB4kBwgc3ujCvgsUMLGmg4MKezYzqincxudxueUjzHXGqkNyxydVtWggilg4kYVARxXFDji3vWkvALwEaQEvKCgesJ6yfFHPKW4kcojjLhSaLn8obBMJvg0GMIwEkrf5xT1R4dKxCdCHAPvA5LV6vrYzqinQJv8fMscJRi4KKugKFuoeSKMNseUOgUOiCtYcJbHuoXUWgENGnmqwmWHlQHlkcxLHKRzsWd7z1wptodcPrf5xT1R4dKxCdCHAPvA5LHQxfjNbH0OowXxykjmUIOiCtYcJbHuoXUWgENGnmqwmWHlQHRYqY1mj4H9SARNjNbH0iCrnCLB4oiWjjPmj4H9SARNfecBooCtjCFgRn1qOW9WHWfCsskdYpkhcwsZtjcx5ur(vB9k(a5f3axOwALwEzw9Qi5miKg1Xk(ctjHXvefHBswymiKYj2f2W7eSHbYIboCpCiCX7eSHbYIr423z4kZmGQi)QTEfXa5X2p4KWlTslpGQEvKCgesJ6yfFHPKW4kk3WfVtWggilgHBFNHRmZakCbSHRSz5d3ujC5xTKuJCcXiC4kNkYVARxXhiV4g4c1sR0YN6vVksodcPrDSIVWusyCfFGSOlHd3(cxaQi)QTEf)1LGCxbRuPvA5tTQxf5xT1RO5V5KGvQIKZGqAuhlT0sRyssGT1R0YlR8YcaaaKAvSFw4M3fxrahijwHsJWn1dx(vB9WfAyfNdDQycXkzqQIPQWnvJWQy6vB9WfWjlG7JYqNuv4MEtsiGKiCLxw0dx5LvEzdDcDsvHlGlzm9tkncxqsAfu4(lciRHli11CCoCt19pLqXHRVoGfilqKMGHl)QTooCxhIwo0HF1whNtiOFraz9uIGTXIyoR26OBsNQHq9jlQOibPzgAjPqh(vBDCoHG(fbK1zNZXtiiR3sqAOd)QTooNqq)IaY6SZ5DfgYAcQTsnm)ctYEcDt6uzi5AURWqwtqTvQH5xys2tzYzqincD4xT1X5ec6xeqwNDohVtWMKjOqh(vBDCoHG(fbK1zNZn)nNeSsOBsNOqzi5AgVtWMKjOm5miKgHoHoPQWfWLmM(jLgHlLKeOfUQHqHRcKcx(1veUgoC5KSbzqiLdD4xT1XN4eee2G7JYqh(vBD8SZ5yZ7sneUR9HoHo8R264ZNHWg)QTEdAyfDNrOtGCY9r3KobYj3VXVAjju5xTKuJCcXiCFaGk)QLKAKtigHtbqawLHKRzZLiHVzYzqinMjxLHKRzZLiHVzYzqinqvzi5A2CLeodB)IaoHvB9m5miKgYj0HF1whp7C(VUeK7kyLq3KovgsUMfllmVBdeYaEktodcPbQdcCssklwwyE3giKb8uwqiS54uaidOqh(vBD8SZ5pR8drdJGUjDIc5MG0S5sKWzyMF1ssOownBiilKvklie2C8ma6lbPzZLiHZWSGqyZXY5WbCcccBkl6sko)SYpenmsFae6WVARJNDo)ziSXVAR3Ggwr3ze6KxcDt6KF1ssnYjeJW9jFOd)QToE25C8obBsMGq)r7HutzrxsXNaGUjDkijbHbYGqcv8obByGSyKYPmrvUOqzi5A(zLFiAyKm5miKgho87chB)E(zLFiAyKSGqyZX9jie2CSCcD4xT1XZoNBiilKvc9hThsnLfDjfFca6M0PGKeegidcjuLlkugsUMFw5hIggjtodcPXHd)UWX2VNFw5hIggjlie2CCFccHnhlNqh(vBD8SZ5gcYczLq3KovgsUMnxjHZW2ViGty1wptodcPbQ8R265hiV4g4c1S5njO1fOIQGqyZXPmMeSARNkYMbuOd)QToE258NHWg)QTEdAyfDNrOZFGdD4xT1XZoN)me24xT1BqdRO7mcDsym5pHdD4xT1XZoN)az3jyBqiRlzck0HF1whp7Co(3jH5DBQPaPqh(vBD8SZ5d6newnVBdCHAOd)QToE25CGCY9r)r7HutzrxsXNaGUjDownBiilKvklie2CCFJvZgcYczLYJjbR26PISzaD4akugsUMnxjHZW2ViGty1wptodcPrOd)QToE25Cdjb5dZ72EwzSk2eaPqh(vBD8SZ54Dc2eRg6WVARJNDohiNCF0nPtXKtsROlL3HOHbY9dBRutbsn0qmbGBwKjzutwIe0i0HF1whp7CEswymiKq3ze6mXUWgENGnmqwmWONKHt0j)QLKAKtigH7dau)DHJTFpdKtUFwqiS54uobq2dh(DHJTFpJNqqwVzUejCgMfecBooLtaaeQkdjxZdwGYgENGnZXkdAqtrltodcPbQ)UWX2VNhSaLn8obBMJvg0GMIwwqiS54uobaqhoOmKCnpybkB4Dc2mhRmObnfTm5miKgO(7chB)EEWcu2W7eSzowzqdAkAzbHWMJt5eaaHQC)DHJTFpJNqqwVzUejCgMfecBoUpLfDjnRgc10Tnm6WHFx4y73Z4jeK1BMlrcNHzbHWMJN97chB)EgpHGSEZCjs4mmpMeSAR3NYIUKMvdHA62ggjNqh(vBD8SZ5)6sqURGvcDt6eCsskdYpkhcwsZJTFhv8obByGSy03jazabyLnldPIYqY1SeKXa3KKitodcPbQOijlmges5e7cB4Dc2WazXah6WVARJNDo)bYlUbUqfDt6eCsskpybkB4Dc2mhRmObnfT8uIqh(vBD8SZ5pqEXnWfQOBsNGtsszq(r5qWsAEkbQOijlmges5e7cB4Dc2WazXaJkkugsUMjbpSNvB9m5miKgHo8R264zNZFG8IBGlur3KorrswymiKYj2f2W7eSHbYIbgvLHKRzsWd7z1wptodcPbQYDqGtsszsWd7z1wplie2CCkpJ1MAi0HdGtsszq(r5qWsAEkHCcD4xT1XZoNJbYJTFWjHJUjDIIKSWyqiLtSlSH3jyddKfd8Hd4Dc2WazXOVtzMbuOd)QToE258hiV4g4cv0nPt5I3jyddKfJ(oLzgqawzZYNk8RwsQroHyewoHo8R264zNZ)1LGCxbRe6M05dKfDjCFae6WVARJNDo383CsWkf6e6WVARJZ8sZoNlyZBRutYee6M0zcsZMlrcNHz(vljHQCrXVlCS97zGCY9ZcIhOD4a)QLKAKtigH7tgKtOd)QTooZln7CoENGnXQHo8R264mV0SZ5pq2Dc2geY6sMGq3KohRMneKfYkLfecBoUVNXAtnek0HF1whN5LMDo3qqwiRe6pApKAkl6sk(ea0nPtbHWMJtbqOkxuOmKCn)SYpenmsMCgesJdh(DHJTFp)SYpenmswqiS54(eecBowoHo8R264mV0SZ5pdHn(vB9g0Wk6oJqN)ah6WVARJZ8sZoN)me24xT1BqdRO7mcDsym5pHdD4xT1XzEPzNZbYj3h9hThsnLfDjfFca6Me)QLKAKtigHtrMHo8R264mV0SZ5c282k1Kmbf6WVARJZ8sZoNdKtUp6pApKAkl6sk(eGqh(vBDCMxA258b9gcRM3TbUqfDt6uU4DccA(idjE0arRrYygjbKYKZGqAC4akugsUMLmb1yF0afgcwxNYKZGqAiNqh(vBDCMxA25CZFZjbRe6M0PYqY1SKjOg7JgOWqW66uMCgesdubNKKYG8JYHGL08ucuX7eSHbYIrkacWkBw(uHF1ssnYjeJWHo8R264mV0SZ54Dc2Kmbf6WVARJZ8sZoN)Rlb5Ucwj0nPtWjjPmi)OCiyjnp2(9qh(vBDCMxA25CmqES9dojC0nPtLfDjndKyOcmN41uKx2qh(vBDCMxA25C8VtcZ72utbsOBsNOqUkdjxZsMGASpAGcdbRRtzYzqinoCqzi5A2Cjs4BMCgesd5e6WVARJZ8sZoNBijiFyE32ZkJvXMaiHUjDIc5QmKCnlzcQX(ObkmeSUoLjNbH04WbLHKRzZLiHVzYzqinKtOd)QTooZln7CU5V5KGvk0j0HF1whN)bE25C8ecY6nZLiHZWqh(vBDC(h4zNZhSaLn8obBMJvg0GMIwOd)QToo)d8SZ5jw1whDt6mbPzZLiHZWm)QLKcD4xT1X5FGNDohKeysGsZ7IUjDMG0S5sKWzyMF1ssHo8R2648pWZoNdc3D0KMeOHUjDMG0S5sKWzyMF1ssHo8R2648pWZoNlzcceU7aDt6mbPzZLiHZWm)QLKcD4xT1X5FGNDoFctntjem6M0zcsZMlrcNHz(vljD4GYIUKMvdHA62ggLI8Yg6e6WVARJZa5K7p7C(VUeK7kyLq3KobNKKYG8JYHGL08y73rfVtWggilg9DcaQ4Dc2WazXiLtzg6WVARJZa5K7p7CoENGnjtqOBsNpJ1MAiuka5K73eecBoo0HF1whNbYj3F258b9gcRM3TbUqfDt68zS2udHsbiNC)MGqyZXOI3jiO5JmK4rdeTgjJzKeqktodcPrOd)QToodKtU)SZ54FNeM3TPMcKq3KoFgRn1qOuaYj3Vjie2CCOd)QToodKtU)SZ5gcYczLq3KovgsUMnxjHZW2ViGty1wptodcPbQccHnhNYysWQTEQiBgqhoGcLHKRzZvs4mS9lc4ewT1ZKZGqAGQGKeegidcPqh(vBDCgiNC)zNZFG8IBGlur3KoFgRn1qOuaYj3Vjie2CCOd)QToodKtU)SZ5yG8y7hCs4Ho8R264mqo5(ZoNB(BojyLq3KoFgRn1qOuaYj3Vjie2CCOtOd)QTootym5pHNDoV)vahjjZBccVo7pf6WVARJZegt(t4zNZriKvGwBLAWP3gTHGyeCOd)QTootym5pHNDoheU7OTsnfi1iNqql0HF1whNjmM8NWZoN3DIfdJ92k1yapjwfyOd)QTootym5pHNDoxyjsaPM5nCc(Pqh(vBDCMWyYFcp7CU0(tyA0yapjmLAGeJe6WVARJZegt(t4zNZtmjmj0mVBdeYyn0HF1whNjmM8NWZoNlioH5DBsqgHWOBsNkl6sAgiXqfylXR9byK9WbLfDjndKyOcSL41uKx2dhKSUa1MGqyZXPiVShoOSOlPz1qOMUTeV2Kx2(KPSHo8R264mHXK)eE258F9NCvWknAsqgHcD4xT1XzcJj)j8SZ5kqQn5G7KpAsR4j0nPtWjjPSGEucjmUjTINYccHnhxrCc6R0YN6PwPLwf]] )


end
