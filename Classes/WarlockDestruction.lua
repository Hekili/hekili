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


    spec:RegisterPack( "Destruction", 20201128, [[diKkWaqiiHhjucBcsAueLCkIsTkII8kfLzbP6wQIODjQFPcnmHIJPOAzevEgrbttOuxtvuBJOO(MQimoHs6CefI1juIY8iQ6EQO9jvLdkuIQfQk8qIcPMOqjYfvfj1jvfjALsf7uO6PImvPsFLOqYEL8xPmyv6WOwSQ6XatwHlJSzI8zPkJwv60uwTQijVgs0SbDBi2nv)wPHlehxvKWYj8COMoPRRiBxi9DPQA8efQZdPSEvrQ5Rc2VGR5v3knyLQ4YfJCXmFUCXAEUmp)jITmujfTiuLIWauY9Ok5mcvPyjcRIjGARxPimAWLhv3kH3jbGQ0RQrWXYoESNPVt)myroInKjiR26ablPhXgc4yL(tguFk96xPbRufxUyKlM5ZLlwZZL55prSNxjEsFxrLsgIm6k9AJb51VsdcdQuSiCJLiSkMaQTE4kJIfWfGYqNyr4gFJsiFseUYfROhUYfJCXujOHvC1TsegtoGWv3k(8QBLyGARxP(xbCeLmVji86SdOkro)H0OEuAfxUQBLyGARxjeczfO1wPgCcyJ2qqmcUsKZFinQhLwXLHQBLyGARxPpC3rBLA6l1iNqqRsKZFinQhLwXJD1TsmqT1RuVjwmm2BRuJFAsS6BLiN)qAupkTI)C1TsmqT1RKWIebsnZB4imGQe58hsJ6rPvCzU6wjgO26vsAbtyA04NMeMsTpXivIC(dPr9O0k(tuDReduB9kfzsysOzEV2hYyTsKZFinQhLwXJ1QBLiN)qAupQeqykjmUskl6rA(LyO(2Ia0WTVWnwJjCpCiCvw0J08lXq9TfbOHR8HRCXeUhoeUswVxTjie2CC4kF4kxmH7HdHRYIEKMvdHA62Ia0MCXeU9fUXoMkXa1wVscIJyEVMeKriCPvCzKQBLyGARxjW6aYvbR0OjbzeQsKZFinQhLwXNht1TsKZFinQhvcimLegxP)KKuwqaucjmUjTcaLfecBoUsmqT1RK(sTj)Vt(OjTcavAPv6LJUGQBfFE1TsKZFinQhvcimLegxP)KKu(ZauoeSKMhB)E4IA4I3jyd)YIr423z4opCrnCX7eSHFzXiCL)mCJDLyGARxjW6sqUNGvQ0kUCv3kro)H0OEujGWusyCLamwBQHqHR8H7lhDbnbHWMJReduB9kH3jytYeuPvCzO6wjY5pKg1JkbeMscJReGXAtnekCLpCF5OlOjie2CC4IA4I3j438rgs8O9rRrYygjcKYKZFinQeduB9kniGHWQ59A)fQLwXJD1TsKZFinQhvcimLegxjaJ1MAiu4kF4(YrxqtqiS54kXa1wVsyWojmVxtn9LkTI)C1TsKZFinQhvcimLegxjLHKRzZvs4mSbwK)ewT1ZKZFincxudxbHWMJdx5d3XKGvB9WvMc3yYphUhoeUOiCvgsUMnxjHZWgyr(ty1wpto)H0iCrnCfKKGWV8hsvIbQTELmeKfYkvAfxMRUvIC(dPr9OsaHPKW4kbyS2udHcx5d3xo6cAccHnhxjgO26vc8YlU9xOwAf)jQUvIbQTELWV8y7)pj8kro)H0OEuAfpwRUvIC(dPr9OsaHPKW4kbyS2udHcx5d3xo6cAccHnhxjgO26vYCG5KGvQ0sRuebbwKpRv3k(8QBLiN)qAupQeqykjmUsQHqHBFHBmHlQHlkc3iKMzOfLQeduB9kjrW2yrmNvB9sR4YvDReduB9kHNqqwVzirQe58hsJ6rPvCzO6wjY5pKg1JkbeMscJRKYqY1CpHHSMGARudZaHjzakto)H0OsmqT1RupHHSMGARudZaHjzaQ0kESRUvIbQTELW7eSjzcQsKZFinQhLwXFU6wjY5pKg1JkbeMscJRekcxLHKRz8obBsMGYKZFinQeduB9kzoWCsWkvAPvIxQ6wXNxDRe58hsJ6rLactjHXvkcPzZLiHZWmdulkfUOgUYkCrr4c2fo2(98lhDbzbXd0c3dhcxgOwuQroHyeoC7lCLHWv2vIbQTELeS5TvQjzcQ0kUCv3kXa1wVs4Dc2eRwjY5pKg1JsR4Yq1TsKZFinQhvcimLegxPXQzdbzHSszbHWMJd3(cxaJ1MAiuLyGARxjWl7obBdczDjtqLwXJD1TsKZFinQhvIbQTELmeKfYkvjGWusyCLeecBooCLpCFoCrnCLv4IIWvzi5AgWkdGOHrYKZFinc3dhcxWUWX2VNbSYaiAyKSGqyZXHBFHRGqyZXHRSReanaKAkl6rkUIpV0k(Zv3kro)H0OEujgO26vcWqyJbQTEdAyTsqdRnNrOkbg4sR4YC1TsKZFinQhvIbQTELame2yGAR3GgwRe0WAZzeQsegtoGWLwXFIQBLiN)qAupQeduB9k9YrxqLaObGutzrpsXv85LwXJ1QBLyGARxjbBEBLAsMGQe58hsJ6rPvCzKQBLiN)qAupQeduB9k9YrxqLaObGutzrpsXv85LwXNht1TsKZFinQhvcimLegxjzfU4Dc(nFKHepAF0AKmMrIaPm58hsJW9WHWffHRYqY1SKjOg7J2xyiyDDkto)H0iCLDLyGARxPbbmewnVx7VqT0k(85v3kro)H0OEujGWusyCLugsUMLmb1yF0(cdbRRtzY5pKgHlQH7Fssk)zakhcwsZtrcxudx8obB4xwmcx5d3Nd3NmCJjlx4ktHldulk1iNqmcxjgO26vYCG5KGvQ0k(C5QUvIbQTELW7eSjzcQsKZFinQhLwXNldv3kro)H0OEujGWusyCL(tss5pdq5qWsAES97vIbQTELaRlb5EcwPsR4ZJD1TsKZFinQhvcimLegxjLf9in)smuFZraA4kF4kxmvIbQTELWV8y7)pj8sR4ZFU6wjY5pKg1JkbeMscJRekcxzfUkdjxZsMGASpAFHHG11Pm58hsJW9WHWvzi5A2Cjs4BMC(dPr4k7kXa1wVsyWojmVxtn9LkTIpxMRUvIC(dPr9OsaHPKW4kHIWvwHRYqY1SKjOg7J2xyiyDDkto)H0iCpCiCvgsUMnxIe(MjN)qAeUYUsmqT1RKHeH8H59AawzSk2iVuPv85pr1TsmqT1RK5aZjbRuLiN)qAupkT0kbg4QBfFE1TsmqT1ReEcbz9M5sKWzyLiN)qAupkTIlx1TsmqT1R0GfOSH3jyZCSYFdAkAvIC(dPr9O0kUmuDRe58hsJ6rLactjHXvkcPzZLiHZWmdulkvjgO26vkYQ26LwXJD1TsKZFinQhvcimLegxPiKMnxIeodZmqTOuLyGARxPpjWKaLM3R0k(Zv3kro)H0OEujGWusyCLIqA2Cjs4mmZa1IsvIbQTEL(WDhnPjbALwXL5QBLiN)qAupQeqykjmUsrinBUejCgMzGArPkXa1wVssMG(WDhLwXFIQBLiN)qAupQeqykjmUsrinBUejCgMzGArPW9WHWvzrpsZQHqnDBdJcx5dx5IPsmqT1R0eMAMsi4slTsdsINGA1TIpV6wjgO26vchHGWgCbOSsKZFinQhLwXLR6wjY5pKg1JkbeMscJR0lhDbngOwukCrnCzGArPg5eIr4WTVWDE4IA4Ya1IsnYjeJWHR8H7ZH7tgUkdjxZMlrcFZKZFinc3zHRScxLHKRzZLiHVzY5pKgHlQHRYqY1S5kjCg2alYFcR26zY5pKgHRSReduB9kbyiSXa1wVbnSwjOH1MZiuLE5OlO0kUmuDRe58hsJ6rLactjHXvszi5AwSSW8ETpKFAkto)H0iCrnCh0FssklwwyEV2hYpnLfecBooCLpCNNFUsmqT1ReyDji3tWkvAfp2v3kro)H0OEujGWusyCLqr4kRWncPzZLiHZWmdulkfUOgUJvZgcYczLYccHnhhUZc35HBFHBesZMlrcNHzbHWMJdxzhUhoeU4iee2uw0JuCgWkdGOHrc3(c35vIbQTELaSYaiAyKsR4pxDRe58hsJ6rLactjHXvIbQfLAKtigHd3(cx5QeduB9kbyiSXa1wVbnSwjOH1MZiuL4LkTIlZv3kro)H0OEujgO26vcVtWMKjOkbeMscJRKGKee(L)qkCrnCX7eSHFzXiCL)mCJD4IA4kRWffHRYqY1mGvgardJKjN)qAeUhoeUGDHJTFpdyLbq0WizbHWMJd3(cxbHWMJdxzxjaAai1uw0JuCfFEPv8NO6wjY5pKg1JkXa1wVsgcYczLQeqykjmUscssq4x(dPWf1WvwHlkcxLHKRzaRmaIggjto)H0iCpCiCb7chB)EgWkdGOHrYccHnhhU9fUccHnhhUYUsa0aqQPSOhP4k(8sR4XA1TsKZFinQhvcimLegxjLHKRzZvs4mSbwK)ewT1ZKZFincxudxgO26zWlV42FHA28Me069QHlQHRGqyZXHR8H7ysWQTE4ktHBm5NReduB9kziilKvQ0kUms1TsKZFinQhvIbQTELame2yGAR3GgwRe0WAZzeQsGbU0k(8yQUvIC(dPr9OsmqT1ReGHWgduB9g0WALGgwBoJqvIWyYbeU0k(85v3kXa1wVsGx2Dc2geY6sMGQe58hsJ6rPv85YvDReduB9kHb7KW8En10xQsKZFinQhLwXNldv3kXa1wVsdcyiSAEV2FHALiN)qAupkTIpp2v3kro)H0OEujgO26v6LJUGkbeMscJR0y1SHGSqwPSGqyZXHBFH7y1SHGSqwP8ysWQTE4ktHBm5Nd3dhcxueUkdjxZMRKWzydSi)jSARNjN)qAujaAai1uw0JuCfFEPv85pxDReduB9kziriFyEVgGvgRInYlvjY5pKg1JsR4ZL5QBLyGARxj8obBIvRe58hsJ6rPv85pr1TsKZFinQhvcimLegxjXKtsROhL3HOHF5(HTvQPVudnet8uXIm9umzrIqJkXa1wVsVC0fuAfFESwDRe58hsJ6rL2ivctALyGARxPOSW4pKQuugorvIbQfLAKtigHd3(c35HlQHlyx4y73ZVC0fKfecBooCL)mCNht4E4q4c2fo2(9mEcbz9M5sKWzywqiS54Wv(ZWD(ZHlQHRYqY18GfOSH3jyZCSYFdAkAzY5pKgHlQHlyx4y73ZdwGYgENGnZXk)nOPOLfecBooCL)mCN)C4E4q4QmKCnpybkB4Dc2mhR83GMIwMC(dPr4IA4c2fo2(98GfOSH3jyZCSYFdAkAzbHWMJdx5pd35phUOgUYkCb7chB)EgpHGSEZCjs4mmlie2CC42x4QSOhPz1qOMUTHrH7HdHlyx4y73Z4jeK1BMlrcNHzbHWMJd3zHlyx4y73Z4jeK1BMlrcNH5XKGvB9WTVWvzrpsZQHqnDBdJcxzxPOSO5mcvPi7cB4Dc2WVSyGlTIpxgP6wjY5pKg1JkbeMscJR0Fssk)zakhcwsZJTFpCrnCX7eSHFzXiC77mCNNFoCFYWnMSmeUYu4QmKCnlbz87gLezY5pKgHlQHlkc3OSW4pKYr2f2W7eSHFzXaxjgO26vcSUeK7jyLkTIlxmv3kro)H0OEujGWusyCL(tss5blqzdVtWM5yL)g0u0YtrQeduB9kbE5f3(lulTIl38QBLiN)qAupQeqykjmUs)jjP8NbOCiyjnpfjCrnCrr4gLfg)HuoYUWgENGn8llg4Wf1WffHRYqY1mj4Hby1wpto)H0OsmqT1Re4LxC7VqT0kUCYvDRe58hsJ6rLactjHXvcfHBuwy8hs5i7cB4Dc2WVSyGdxudxLHKRzsWddWQTEMC(dPr4IA4kRWDq)jjPmj4Hby1wplie2CC4kF4cyS2udHc3dhc3)KKu(ZauoeSKMNIeUYUsmqT1Re4LxC7VqT0kUCYq1TsKZFinQhvcimLegxjueUrzHXFiLJSlSH3jyd)YIboCpCiCX7eSHFzXiC77mCJD(5kXa1wVs4xES9)NeEPvC5ID1TsKZFinQhvcimLegxjzfU4Dc2WVSyeU9DgUXo)C4(KHBmz5cxzkCzGArPg5eIr4Wv2vIbQTELaV8IB)fQLwXL75QBLiN)qAupQeqykjmUsGxw0JWHBFH78kXa1wVsG1LGCpbRuPvC5K5QBLyGARxjZbMtcwPkro)H0OEuAPLwPOKaBRxXLlg5Iz(C5IPs9Zc38E4k9uIezfkncxzoCzGARhUqdR4COtLIiwjdsvkweUXsewfta1wpCLrXc4cqzOtSiCJVrjKpjcx5Iv0dx5IrUycDcDIfH7tTmMatknc3pjTckCblYN1W9t9mhNd3y5aafrXHRV(t(YcePjy4Ya1whhURdrlh6Wa1whNJiiWI8z9uIGTXIyoR26OBsNQHq9fdQOicPzgArPqhgO264CebbwKpRZopINqqwVfH0qhgO264CebbwKpRZop2tyiRjO2k1WmqysgGq3KovgsUM7jmK1euBLAygimjdqzY5pKgHomqT1X5iccSiFwNDEeVtWMKjOqhgO264CebbwKpRZopAoWCsWkHUjDIcLHKRz8obBsMGYKZFincDcDIfH7tTmMatkncxkkjqlCvdHcx9LcxgORiCnC4YrzdYFiLdDyGARJpXriiSbxakdDyGARJpbme2yGAR3Ggwr3ze68LJUa0nPZxo6cAmqTOeQmqTOuJCcXiCFZrLbQfLAKtigHL)5Nuzi5A2Cjs4BMC(dPXmzPmKCnBUej8nto)H0avLHKRzZvs4mSbwK)ewT1ZKZFinKDOdduBD8SZJG1LGCpbRe6M0PYqY1SyzH59AFi)0uMC(dPbQd6pjjLfllmVx7d5NMYccHnhl)88ZHomqT1XZopcyLbq0WiOBsNOqwrinBUejCgMzGArjuhRMneKfYkLfecBoE28(IqA2Cjs4mmlie2CSSpCahHGWMYIEKIZawzaenmsFZdDyGARJNDEeWqyJbQTEdAyfDNrOtEj0nPtgOwuQroHyeUp5cDyGARJNDEeVtWMKji0bObGutzrpsXNZr3KofKKGWV8hsOI3jyd)YIH8NXgvzHcLHKRzaRmaIggjto)H04WbWUWX2VNbSYaiAyKSGqyZX9jie2CSSdDyGARJNDE0qqwiRe6a0aqQPSOhP4Z5OBsNcssq4x(djuLfkugsUMbSYaiAyKm58hsJdha7chB)EgWkdGOHrYccHnh3NGqyZXYo0HbQToE25rdbzHSsOBsNkdjxZMRKWzydSi)jSARNjN)qAGkduB9m4LxC7VqnBEtcA9EvufecBow(XKGvBDzkM8ZHomqT1XZopcyiSXa1wVbnSIUZi0jyGdDyGARJNDEeWqyJbQTEdAyfDNrOtcJjhq4qhgO264zNhbVS7eSniK1Lmbf6Wa1whp78igStcZ71utFPqhgO264zNhheWqy18ET)c1qhgO264zNhF5OlaDaAai1uw0Ju85C0nPZXQzdbzHSszbHWMJ7BSA2qqwiRuEmjy1wxMIj)8HdOqzi5A2CLeodBGf5pHvB9m58hsJqhgO264zNhnKiKpmVxdWkJvXg5LcDyGARJNDEeVtWMy1qhgO264zNhF5OlaDt6um5K0k6r5DiA4xUFyBLA6l1qdXepvSitpftwKi0i0HbQToE25XOSW4pKq3ze6mYUWgENGn8llgy0JYWj6KbQfLAKtigH7BoQGDHJTFp)YrxqwqiS5y5pNhZHdGDHJTFpJNqqwVzUejCgMfecBow(Z5pJQYqY18GfOSH3jyZCSYFdAkAzY5pKgOc2fo2(98GfOSH3jyZCSYFdAkAzbHWMJL)C(ZhoOmKCnpybkB4Dc2mhR83GMIwMC(dPbQGDHJTFppybkB4Dc2mhR83GMIwwqiS5y5pN)mQYcSlCS97z8ecY6nZLiHZWSGqyZX9PSOhPz1qOMUTHrhoa2fo2(9mEcbz9M5sKWzywqiS54zGDHJTFpJNqqwVzUejCgMhtcwT17tzrpsZQHqnDBdJKDOdduBD8SZJG1LGCpbRe6M05Fssk)zakhcwsZJTFhv8obB4xwm67CE(5NmMSmitkdjxZsqg)UrjrMC(dPbQOiklm(dPCKDHn8obB4xwmWHomqT1XZopcE5f3(lur3Ko)tss5blqzdVtWM5yL)g0u0YtrcDyGARJNDEe8YlU9xOIUjD(NKKYFgGYHGL08ueurruwy8hs5i7cB4Dc2WVSyGrffkdjxZKGhgGvB9m58hsJqhgO264zNhbV8IB)fQOBsNOiklm(dPCKDHn8obB4xwmWOQmKCntcEyawT1ZKZFinqvwd6pjjLjbpmaR26zbHWMJLhWyTPgcD4WFssk)zakhcwsZtrKDOdduBD8SZJ4xES9)Neo6M0jkIYcJ)qkhzxydVtWg(Lfd8Hd4Dc2WVSy03zSZph6Wa1whp78i4LxC7VqfDt6uw4Dc2WVSy03zSZp)KXKLtMyGArPg5eIryzh6Wa1whp78iyDji3tWkHUjDcEzrpc338qhgO264zNhnhyojyLcDcDyGARJZ8sZopkyZBRutYee6M0zesZMlrcNHzgOwucvzHcWUWX2VNF5OliliEG2HdmqTOuJCcXiCFYGSdDyGARJZ8sZopI3jytSAOdduBDCMxA25rWl7obBdczDjtqOBsNJvZgcYczLYccHnh3hGXAtnek0HbQTooZln78OHGSqwj0bObGutzrpsXNZr3KofecBow(NrvwOqzi5AgWkdGOHrYKZFinoCaSlCS97zaRmaIggjlie2CCFccHnhl7qhgO264mV0SZJagcBmqT1BqdRO7mcDcg4qhgO264mV0SZJagcBmqT1BqdRO7mcDsym5ach6Wa1whN5LMDE8LJUa0bObGutzrpsXNZr3KyGArPg5eIry5JDOdduBDCMxA25rbBEBLAsMGcDyGARJZ8sZop(Yrxa6a0aqQPSOhP4Z5HomqT1XzEPzNhheWqy18ET)cv0nPtzH3j438rgs8O9rRrYygjcKYKZFinoCafkdjxZsMGASpAFHHG11Pm58hsdzh6Wa1whN5LMDE0CG5KGvcDt6uzi5AwYeuJ9r7lmeSUoLjN)qAG6Fssk)zakhcwsZtrqfVtWg(Lfd5F(jJjlNmXa1IsnYjeJWHomqT1XzEPzNhX7eSjzck0HbQTooZln78iyDji3tWkHUjD(NKKYFgGYHGL08y73dDyGARJZ8sZopIF5X2)Fs4OBsNkl6rA(LyO(MJau5LlMqhgO264mV0SZJyWojmVxtn9Lq3KorHSugsUMLmb1yF0(cdbRRtzY5pKghoOmKCnBUej8nto)H0q2HomqT1XzEPzNhnKiKpmVxdWkJvXg5Lq3KorHSugsUMLmb1yF0(cdbRRtzY5pKghoOmKCnBUej8nto)H0q2HomqT1XzEPzNhnhyojyLcDcDyGARJZGbE25r8ecY6nZLiHZWqhgO264myGNDECWcu2W7eSzow5VbnfTqhgO264myGNDEmYQ26OBsNrinBUejCgMzGArPqhgO264myGNDE8tcmjqP59q3KoJqA2Cjs4mmZa1IsHomqT1XzWap784hU7OjnjqdDt6mcPzZLiHZWmdulkf6Wa1whNbd8SZJsMG(WDhOBsNrinBUejCgMzGArPqhgO264myGNDECctntjem6M0zesZMlrcNHzgOwu6WbLf9inRgc10TnmsE5Ij0j0HbQToo)YrxWSZJG1LGCpbRe6M05Fssk)zakhcwsZJTFhv8obB4xwm67CoQ4Dc2WVSyi)zSdDyGARJZVC0fm78iENGnjtqOBsNagRn1qi5F5OlOjie2CCOdduBDC(LJUGzNhheWqy18ET)cv0nPtaJ1MAiK8VC0f0eecBogv8ob)MpYqIhTpAnsgZirGuMC(dPrOdduBDC(LJUGzNhXGDsyEVMA6lHUjDcyS2udHK)LJUGMGqyZXHomqT1X5xo6cMDE0qqwiRe6M0PYqY1S5kjCg2alYFcR26zY5pKgOkie2CS8JjbR26Yum5NpCafkdjxZMRKWzydSi)jSARNjN)qAGQGKee(L)qk0HbQToo)YrxWSZJGxEXT)cv0nPtaJ1MAiK8VC0f0eecBoo0HbQToo)YrxWSZJ4xES9)NeEOdduBDC(LJUGzNhnhyojyLq3KobmwBQHqY)YrxqtqiS54qNqhgO264mHXKdi8SZJ9Vc4ikzEtq41zhqHomqT1XzcJjhq4zNhriKvGwBLAWjGnAdbXi4qhgO264mHXKdi8SZJF4UJ2k10xQroHGwOdduBDCMWyYbeE25XEtSyyS3wPg)0Ky13qhgO264mHXKdi8SZJclsei1mVHJWak0HbQTootym5acp78O0cMW0OXpnjmLAFIrcDyGARJZegtoGWZopgzsysOzEV2hYyn0HbQTootym5acp78OG4iM3RjbzecJUjDQSOhP5xIH6Blcq7lwJ5WbLf9in)smuFBraQ8YfZHdswVxTjie2CS8YfZHdkl6rAwneQPBlcqBYftFXoMqhgO264mHXKdi8SZJG1bKRcwPrtcYiuOdduBDCMWyYbeE25r9LAt(FN8rtAfacDt68pjjLfeaLqcJBsRaqzbHWMJReocbQ4YjZprPLwfa]] )


end
