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


    spec:RegisterPack( "Destruction", 20210707, [[dOKA0aqiejpcreBIO4tuQeJIsrNIsHvrPcVsLYSquDlkv0UK4xkvnmkLoMQKLPu4zeLyAkv4AicBJsL6BeL04uQOohIOQ1PurAEuQ6EQK9Pu0bjkLAHQu9qerLjsuQ4IkveBeru4JeLs6KeLkTskPzIikzNIk)KsLuTukvs5PImvLsBfru0xPujzSiIsTxP(RKgSkomQfRQEmWKvYLH2mr(SOQrRkoTWQjkL41isnBq3gHDt1VvmCIQJtuQA5eEostN01fLTtj(UsLgpIiDEeL1tukMVQu7NI7x92oTyf7CBy7gVSvwTvwl2UZK4LSilDsjto2j5mG0CEStotGDs2bPQidOX4DsotgC4vVTt0jtaWo9OQC6oD)(8H(K9lGHypniYGSgJdeSKUNgeG9D6Nfqv217FNwSIDUnSDJx2kR2kRfB3zs8Ads0jotFgrNsbbjxNEI1c9(3PfsbDs2bPQidOX4MJDflGdG0gRwZGKzoVi3C2W2nEzSASsY9WEEKUtnwTtZHKbePpablP7jzoqwdiAoPbAbD1CaSdqynKmhWd75XL5OJ5eUIcrMCTgsLobdQs7TDcPu0biT325E1B7ed0y8oT7iGlly4vbshNDa2j05pex99w7CB0B7ed0y8orGeJGS6ivHzGyvxcKjODcD(dXvFV1oNS0B7ed0y8o9HZSQJuvFWk6ibzDcD(dXvFV1o3o6TDIbAmENYNXIvWEDKQSSbfJ(0j05pex99w7CKO32jgOX4DseYLdXA4vQCgGDcD(dXvFV1oND3B7ed0y8ojnGmkUQSSbfHI1pYeDcD(dXvFV1oNS2B7ed0y8ojptesKfE(6hYuTtOZFiU67T2525EBNqN)qC137eqekkcUtklYJA5bzO(uLduZztZzNT1CE)2CuwKh1YdYq9PkhOMJ9MZg2AoVFBosr(hTkqcoCQ5yV5SHTMZ73MJYI8Ow0GaR6uLd06g2AoBAo7W2oXangVtcKLhE(QeKjqARDos(EBNyGgJ3jW4a0vbR4QkbzcStOZFiU67T25EzBVTtOZFiU67Dcicffb3PFMKurGasdrkTkncaweibhoTtmqJX7K(G1m)pz(Qknca2ARD6HTmGEBN7vVTtOZFiU67Dcicffb3PFMKu5ZasVeSKwwZUU5iJ5qNmyL(WIL5S5L58YCKXCOtgSsFyXYCS)YC2rNyGgJ3jW4sqoVGvS1o3g92oHo)H4QV3jGiuueCNamvRAqGMJ9MZdBzavbsWHt7ed0y8orNmyvkeyRDozP32j05pex99obeHIIG7eGPAvdc0CS3CEyldOkqcoCQ5iJ5qNm4p8vbI8Q(jRIKuMqoelOZFiU6ed0y8oTqqqWA45R)bQT252rVTtOZFiU67Dcicffb3jat1QgeO5yV58WwgqvGeC40oXangVtuWKjcpFvd9bBTZrIEBNqN)qC137eqekkcUtkdrxlHROWzyfme)mQgJxqN)qCzoYyocKGdNAo2BoRmbRX4MJDyo2wiH58(T5qkZrzi6AjCffodRGH4Nr1y8c68hIlZrgZrGscK(WFi2jgOX4DkiigiRyRDo7U32j05pex99obeHIIG7eGPAvdc0CS3CEyldOkqcoCANyGgJ3jWdp06FGARDozT32jgOX4DI(WRz3FMW7e68hIR(ERDUDU32j05pex99obeHIIG7eGPAvdc0CS3CEyldOkqcoCANyGgJ3PWbHJcwXwBTtYfiyi(S2B7CV6TDcD(dXvFVtmqJX7KecRRHiCwJX70cParixJX70oHKIGmfxMZhLgbAoGH4ZQ58X8HtlMJSnaGYvQ54JBNpSGqkdAomqJXPMZ4qYkDcicffb3jniqZztZXwZrgZHuMJCulmmSGT252O32jgOX4DIMrqmEniK3j05pex99w7CYsVTtOZFiU67DYzcSt6qG1rQsmovftgTcgNQImGgJt7ed0y8oPdbwhPkX4uvmz0kyCQkYaAmoT1o3o6TDcD(dXvFVtotGDIoqKFOvkceOwve84HSpd7ed0y8orhiYp0kfbcuRkcE8q2NHT25irVTtmqJX7KeePpablPDcD(dXvFV1oND3B7e68hIR(ENaIqrrWDszi6AjViiMqG1rQszGiKcawqN)qC1jgOX4DkViiMqG1rQszGiKca2ANtw7TDIbAmENOtgSkfcStOZFiU67T2525EBNqN)qC137eqekkcUtKYCugIUwOtgSkfcSGo)H4QtmqJX7u4GWrbRyRT2jEWEBN7vVTtOZFiU67Dcicffb3j5OwcxcfodlmqdlO5iJ5ytZHuMdyg4A21lpSLbueiViZCE)2CyGgwWk6irGuZztZrwmhB0jgOX4DsWHxhPQuiWw7CB0B7ed0y8orNmyvmANqN)qC13BTZjl92oHo)H4QV3jGiuueCNwJwccIbYkweibho1C20CamvRAqGDIbAmENapS7iSUqIXLcb2ANBh92oHo)H4QV3jgOX4DkiigiRyNaIqrrWDsGeC4uZXEZHeMJmMJnnhszokdrxlawzaKmkrbD(dXL58(T5aMbUMD9cGvgajJsueibho1C20Ceibho1CSrNaKbGyvzrEuPDUxT25irVTtOZFiU67DIbAmENamewzGgJxHbv7emOA1zcStGfT1oND3B7e68hIR(ENyGgJ3jadHvgOX4vyq1obdQwDMa7esPOdqARDozT32j05pex99oXangVtpSLb0jGiuueCNyGgwWk6irGuZXEZzhDcqgaIvLf5rL25E1ANBN7TDIbAmENeC41rQkfcStOZFiU67T25i57TDcD(dXvFVtmqJX70dBzaDcqgaIvLf5rL25E1AN7LT92oHo)H4QV3jGiuueCNSP5qNm4p8vbI8Q(jRIKuMqoelOZFiUmN3VnhszokdrxlsHaRSVQFrqq1XXc68hIlZXgDIbAmENwiiiyn881)a1w7CVE1B7e68hIR(ENaIqrrWDszi6ArkeyL9v9lccQoowqN)qCzoYyo)mjPYNbKEjyjTKj3CKXCOtgSsFyXYCS3CiH5yNMJTLnmh7WCyGgwWk6irG0oXangVtHdchfSIT25ETrVTtmqJX7eDYGvPqGDcD(dXvFV1o3lzP32j05pex99obeHIIG70ptsQ8zaPxcwslRzxVtmqJX7eyCjiNxWk2AN71o6TDcD(dXvFVtarOOi4oPSipQLhKH6troqnh7nNnSTtmqJX7e9HxZU)mH3AN7fj6TDcD(dXvFVtarOOi4orkZXMMJYq01IuiWk7R6xeeuDCSGo)H4YCE)2CugIUwcxcf(uqN)qCzo2OtmqJX7efmzIWZx1qFWw7CVS7EBNqN)qC137eqekkcUtKYCSP5OmeDTifcSY(Q(fbbvhhlOZFiUmN3VnhLHORLWLqHpf05pexMJn6ed0y8ofeYrFfE(kGvMQIr(d2AN7LS2B7ed0y8ofoiCuWk2j05pex99wBTtGfT325E1B7ed0y8orZiigVgUekCg2j05pex99w7CB0B7ed0y8oTybPR0jdwdNQ8pGHswNqN)qC13BTZjl92oHo)H4QV3jGiuueCNKJAjCju4mSWanSGDIbAmENKpAmERDUD0B7e68hIR(ENaIqrrWDsoQLWLqHZWcd0Wc2jgOX4D6JckkiD45BTZrIEBNqN)qC137eqekkcUtYrTeUekCgwyGgwWoXangVtF4mRQuMGSw7C2DVTtOZFiU67Dcicffb3j5OwcxcfodlmqdlyNyGgJ3jPqGF4mRw7CYAVTtOZFiU67Dcicffb3j5OwcxcfodlmqdlO58(T5OSipQfniWQo1vGMJ9MZg22jgOX4DkJI1qrcART2PfkXzqT325E1B7e68hIR(ENwific5AmEN2jKueKP4YCqlOGmZrdc0C0h0CyGocZjOMdBHdi)HyPtmqJX7evocHv4aiDRDUn6TDcD(dXvFVtarOOi4o9WwgqLbAybnhzmhgOHfSIosei1C20CEzoYyomqdlyfDKiqQ5yV5qcZXonhLHORLWLqHpf05pexMZnZXMMJYq01s4sOWNc68hIlZrgZrzi6AjCffodRGH4Nr1y8c68hIlZXgDIbAmENamewzGgJxHbv7emOA1zcStpSLb0ANtw6TDcD(dXvFVtmqJX7KeePpablPDcicffb3j6Kb)HVkwgiRbeR0bAbDTGo)H4QtHROqKjxRHuN(zssfldK1aIv6aTGUwYK3ANBh92oHo)H4QV3jGiuueCNugIUwedlcpF9dzzdwqN)qCzoYyol8NjjvedlcpF9dzzdweibho1CS3CEvirNyGgJ3jW4sqoVGvS1ohj6TDcD(dXvFVtarOOi4orkZXMMJCulHlHcNHfgOHf0CKXCwJwccIbYkweibho1CUzoVmNnnh5OwcxcfodlcKGdNAo2WCE)2COYriSQSipQ0cGvgajJsyoBAoV6ed0y8obyLbqYOeT25S7EBNqN)qC137eqekkcUtmqdlyfDKiqQ5SP5SrNyGgJ3jadHvgOX4vyq1obdQwDMa7epyRDozT32j05pex99oXangVt0jdwLcb2jGiuueCNeOKaPp8hIMJmMdDYGv6dlwMJ9xMZomhzmhBAoKYCugIUwaSYaizuIc68hIlZ59BZbmdCn76faRmasgLOiqcoCQ5SP5iqcoCQ5yJobidaXQYI8Os7CVATZTZ92oHo)H4QV3jgOX4DkiigiRyNaIqrrWDsGscK(WFiAoYyo20CiL5OmeDTayLbqYOef05pexMZ73Mdyg4A21lawzaKmkrrGeC4uZztZrGeC4uZXgDcqgaIvLf5rL25E1ANJKV32j05pex99obeHIIG7KYq01s4kkCgwbdXpJQX4f05pexMJmMdd0y8c4HhA9pqTeEvcg5FuZrgZrGeC4uZXEZzLjyng3CSdZX2cj6ed0y8ofeedKvS1o3lB7TDcD(dXvFVtmqJX7eGHWkd0y8kmOANGbvRotGDcSOT25E9Q32j05pex99oXangVtagcRmqJXRWGQDcguT6mb2jKsrhG0w7CV2O32jgOX4Dc8WUJW6cjgxkeyNqN)qC13BTZ9sw6TDIbAmENOGjteE(Qg6d2j05pex99w7CV2rVTtmqJX70cbbbRHNV(hO2j05pex99w7CVirVTtOZFiU67DIbAmENEyldOtarOOi4oTgTeeedKvSiqcoCQ5SP5SgTeeedKvSSYeSgJBo2H5yBHeMZ73MdPmhLHORLWvu4mScgIFgvJXlOZFiU6eGmaeRklYJkTZ9Q1o3l7U32jgOX4DkiKJ(k88vaRmvfJ8hStOZFiU67T25EjR92oXangVt0jdwfJ2j05pex99w7CV25EBNqN)qC137eqekkcUtImhLgrESmlrL(W7cRJuvFWkzeHq2clkOSplKlhxDIbAmENEyldO1o3ls(EBNqN)qC1370iVtuu7ed0y8ozHfb)HyNSWWmStmqdlyfDKiqQ5SP58YCKXCaZaxZUE5HTmGIaj4WPMJ9xMZlBnN3VnhWmW1SRxOzeeJxdxcfodlcKGdNAo2FzoViH5iJ5OmeDTSybPR0jdwdNQ8pGHswbD(dXL5iJ5aMbUMD9YIfKUsNmynCQY)agkzfbsWHtnh7VmNxKWCE)2CugIUwwSG0v6KbRHtv(hWqjRGo)H4YCKXCaZaxZUEzXcsxPtgSgov5FadLSIaj4WPMJ9xMZlsyoYyo20CaZaxZUEHMrqmEnCju4mSiqcoCQ5SP5OSipQfniWQo1vGMZ73Mdyg4A21l0mcIXRHlHcNHfbsWHtnNBMdyg4A21l0mcIXRHlHcNHLvMG1yCZztZrzrEulAqGvDQRanhB0jlSO6mb2j5ZaR0jdwPpSyrBTZTHT92oHo)H4QV3jGiuueCN(zssLpdi9sWsAzn76MJmMdDYGv6dlwMZMxMZRcjmh70CSTilMJDyokdrxlsqM(mwqrbD(dXL5iJ5qkZXclc(dXI8zGv6KbR0hwSODIbAmENaJlb58cwXw7CB8Q32j05pex99obeHIIG70ptsQSybPR0jdwdNQ8pGHswjtENyGgJ3jWdp06FGARDUn2O32j05pex99obeHIIG70ptsQ8zaPxcwslzYnhzmhszowyrWFiwKpdSsNmyL(WIf1CKXCiL5OmeDTGcEfawJXlOZFiU6ed0y8obE4Hw)duBTZTHS0B7e68hIR(ENaIqrrWDIuMJfwe8hIf5ZaR0jdwPpSyrnhzmhLHORfuWRaWAmEbD(dXL5iJ5ytZzH)mjPck4vayngViqcoCQ5yV5ayQw1GanN3VnNFMKu5ZasVeSKwYKBo2OtmqJX7e4HhA9pqT1o3g7O32j05pex99obeHIIG7ePmhlSi4pelYNbwPtgSsFyXIAoVFBo0jdwPpSyzoBEzo7OqIoXangVt0hEn7(ZeERDUnirVTtOZFiU67Dcicffb3jBAo0jdwPpSyzoBEzo7OqcZXonhBlByo2H5WanSGv0rIaPMJn6ed0y8obE4Hw)duBTZTHD3B7e68hIR(ENaIqrrWDc8WI8i1C20CE1jgOX4DcmUeKZlyfBTZTHS2B7ed0y8ofoiCuWk2j05pex99wBT1ozbf0y8o3g2UXlBLvBF1PDzHhEEANSRKTTRLt2nNS1DQ5yoBFqZjiKpc1CKgH5yxwOeNbv7I5iqzFwiWL5qhc0C4mDiyfxMd4H98iTySsYkC0CKLDQ5qYnUfuO4YCSl0jd(dFvizBxmhDmh7cDYG)Wxfs2f05pex2fZHvZzNyxNKL5yZxKuBumwnwLDjKpcfxMJDBomqJXnhyqvAXyTtu5iOZTHDlRDsUyKci2jscjXCKDqQkYaAmU5yxXc4aiTXkjHKyowZGKzoVi3C2W2nEzSASssijMdj3d75r6o1yLKqsmh70Cizar6dqWs6EsMdK1aIMtAGwqxnha7aewdjZb8WEECzo6yoHROqKjxRHuXy1yLKyo7eskcYuCzoFuAeO5agIpRMZhZhoTyoY2aakxPMJpUD(WccPmO5WangNAoJdjRySYangNwKlqWq8z9scH11qeoRX4KhsxAqGBARmKsoQfggwqJvgOX40ICbcgIpR3U2tZiigVkhvJvgOX40ICbcgIpR3U2NrXAOib5otGx6qG1rQsmovftgTcgNQImGgJtnwzGgJtlYfiyi(SE7AFgfRHIeK7mbErhiYp0kfbcuRkcE8q2NHgRmqJXPf5cemeFwVDTxcI0hGGLuJvgOX40ICbcgIpR3U2NxeetiW6ivPmqesbajpKUugIUwYlcIjeyDKQugicPaGf05pexgRmqJXPf5cemeFwVDTNozWQuiqJvgOX40ICbcgIpR3U2hoiCuWksEiDrkLHORf6KbRsHalOZFiUmwnwjjMZoHKIGmfxMdAbfKzoAqGMJ(GMdd0ryob1CylCa5pelgRmqJXPxu5iewHdG0gRmqJXPxagcRmqJXRWGQK7mbE9Wwga5H01dBzavgOHfuggOHfSIoseiDZxYWanSGv0rIaP2tc7uzi6AjCju4tbD(dX1nBQmeDTeUek8PGo)H4sgLHORLWvu4mScgIFgvJXlOZFiUSHXkd0yC6TR9sqK(aeSKsEiDrNm4p8vXYaznGyLoqlORKhUIcrMCTgsx)mjPILbYAaXkDGwqxlzYnwzGgJtVDThmUeKZlyfjpKUugIUwedlcpF9dzzdwqN)qCjZc)zssfXWIWZx)qw2GfbsWHtT)vHegRmqJXP3U2dyLbqYOeKhsxKYMYrTeUekCgwyGgwqzwJwccIbYkweibho92RnLJAjCju4mSiqcoCQnE)MkhHWQYI8OslawzaKmkXMVmwzGgJtVDThWqyLbAmEfguLCNjWlEqYdPlgOHfSIoseiDZnmwzGgJtVDTNozWQuiqYbKbGyvzrEuPxVipKUeOKaPp8hIYqNmyL(WIL9x7qgBskLHORfaRmasgLOGo)H469BWmW1SRxaSYaizuIIaj4WPBkqcoCQnmwzGgJtVDTpiigiRi5aYaqSQSipQ0RxKhsxcusG0h(drzSjPugIUwaSYaizuIc68hIR3VbZaxZUEbWkdGKrjkcKGdNUPaj4WP2WyLbAmo921(GGyGSIKhsxkdrxlHROWzyfme)mQgJxqN)qCjdd0y8c4HhA9pqTeEvcg5Fuzeibho1(vMG1yC7W2cjmwzGgJtVDThWqyLbAmEfguLCNjWlWIASYangNE7ApGHWkd0y8kmOk5otGxiLIoaPgRmqJXP3U2dEy3ryDHeJlfc0yLbAmo921EkyYeHNVQH(GgRmqJXP3U2VqqqWA45R)bQgRmqJXP3U2)Wwga5aYaqSQSipQ0RxKhsxRrlbbXazflcKGdNU5A0sqqmqwXYktWAmUDyBHeVFtkLHORLWvu4mScgIFgvJXlOZFiUmwzGgJtVDTpiKJ(k88vaRmvfJ8h0yLbAmo921E6KbRIrnwzGgJtVDT)HTmaYdPlrMJsJipwMLOsF4DH1rQQpyLmIqiBHffu2NfYLJlJvgOX40Bx7TWIG)qKCNjWl5ZaR0jdwPpSyrj3cdZWlgOHfSIoseiDZxYaMbUMD9YdBzafbsWHtT)6LTVFdMbUMD9cnJGy8A4sOWzyrGeC4u7VErczugIUwwSG0v6KbRHtv(hWqjRGo)H4sgWmW1SRxwSG0v6KbRHtv(hWqjRiqcoCQ9xViX73kdrxllwq6kDYG1WPk)dyOKvqN)qCjdyg4A21llwq6kDYG1WPk)dyOKveibho1(RxKqgBcMbUMD9cnJGy8A4sOWzyrGeC40nvwKh1IgeyvN6kW3VbZaxZUEHMrqmEnCju4mSiqcoC6nWmW1SRxOzeeJxdxcfodlRmbRX4BQSipQfniWQo1vG2WyLbAmo921EW4sqoVGvK8q66Njjv(mG0lblPL1SRldDYGv6dlwBE9Qqc702ISyhkdrxlsqM(mwqrbD(dXLmKYclc(dXI8zGv6KbR0hwSOgRmqJXP3U2dE4Hw)dujpKU(zssLfliDLozWA4uL)bmuYkzYnwzGgJtVDTh8WdT(hOsEiD9ZKKkFgq6LGL0sMCziLfwe8hIf5ZaR0jdwPpSyrLHukdrxlOGxbG1y8c68hIlJvgOX40Bx7bp8qR)bQKhsxKYclc(dXI8zGv6KbR0hwSOYOmeDTGcEfawJXlOZFiUKXMl8NjjvqbVcaRX4fbsWHtThWuTQbb((9ptsQ8zaPxcwslzYTHXkd0yC6TR90hEn7(Zeo5H0fPSWIG)qSiFgyLozWk9Hfl6730jdwPpSyT51okKWyLbAmo921EWdp06FGk5H0LnPtgSsFyXAZRDuiHDABzd7GbAybROJebsTHXkd0yC6TR9GXLGCEbRi5H0f4Hf5r6MVmwzGgJtVDTpCq4OGv0y1yLbAmoTWdEj4WRJuvkei5H0LCulHlHcNHfgOHfugBskWmW1SRxEyldOiqEr273mqdlyfDKiq6MYInmwzGgJtl8G3U2tNmyvmQXkd0yCAHh821EWd7ocRlKyCPqGKhsxRrlbbXazflcKGdNUjGPAvdc0yLbAmoTWdE7AFqqmqwrYbKbGyvzrEuPxVipKUeibho1EsiJnjLYq01cGvgajJsuqN)qC9(nyg4A21lawzaKmkrrGeC40nfibho1ggRmqJXPfEWBx7bmewzGgJxHbvj3zc8cSOgRmqJXPfEWBx7bmewzGgJxHbvj3zc8cPu0bi1yLbAmoTWdE7A)dBzaKdidaXQYI8OsVErEiDXanSGv0rIaP2VdJvgOX40cp4TR9co86ivLcbASYangNw4bVDT)HTmaYbKbGyvzrEuPxVmwzGgJtl8G3U2VqqqWA45R)bQKhsx2KozWF4Rce5v9twfjPmHCiwqN)qC9(nPugIUwKcbwzFv)IGGQJJf05pex2WyLbAmoTWdE7AF4GWrbRi5H0LYq01IuiWk7R6xeeuDCSGo)H4sMFMKu5ZasVeSKwYKldDYGv6dlw2tc702Yg2bd0WcwrhjcKASYangNw4bVDTNozWQuiqJvgOX40cp4TR9GXLGCEbRi5H01ptsQ8zaPxcwslRzx3yLbAmoTWdE7Ap9HxZU)mHtEiDPSipQLhKH6troqTFdBnwzGgJtl8G3U2tbtMi88vn0hK8q6Iu2uzi6ArkeyL9v9lccQoowqN)qC9(TYq01s4sOWNc68hIlBySYangNw4bVDTpiKJ(k88vaRmvfJ8hK8q6Iu2uzi6ArkeyL9v9lccQoowqN)qC9(TYq01s4sOWNc68hIlBySYangNw4bVDTpCq4OGv0y1yLbAmoTaw0lAgbX41WLqHZqJvgOX40cyrVDTFXcsxPtgSgov5FadLmJvgOX40cyrVDTx(OX4KhsxYrTeUekCgwyGgwqJvgOX40cyrVDT)JckkiD45jpKUKJAjCju4mSWanSGgRmqJXPfWIE7A)hoZQkLjiJ8q6soQLWLqHZWcd0WcASYangNwal6TR9sHa)WzwKhsxYrTeUekCgwyGgwqJvgOX40cyrVDTpJI1qrck5H0LCulHlHcNHfgOHf89BLf5rTObbw1PUc0(nS1y1yLbAmoT8WwgWfyCjiNxWksEiD9ZKKkFgq6LGL0YA21LHozWk9HfRnVEjdDYGv6dlw2FTdJvgOX40YdBza3U2tNmyvkei5H0fGPAvdc0(h2YaQcKGdNASYangNwEyld421(fcccwdpF9pqL8q6cWuTQbbA)dBzavbsWHtLHozWF4Rce5v9twfjPmHCiwqN)qCzSYangNwEyld421EkyYeHNVQH(GKhsxaMQvniq7FyldOkqcoCQXkd0yCA5HTmGBx7dcIbYksEiDPmeDTeUIcNHvWq8ZOAmEbD(dXLmcKGdNA)ktWAmUDyBHeVFtkLHORLWvu4mScgIFgvJXlOZFiUKrGscK(WFiASYangNwEyld421EWdp06FGk5H0fGPAvdc0(h2YaQcKGdNASYangNwEyld421E6dVMD)zc3yLbAmoT8WwgWTR9HdchfSIKhsxaMQvniq7FyldOkqcoCQXQXkd0yCAbPu0bi921(DhbCzbdVkq64SdqJvgOX40csPOdq6TR9eiXiiRosvygiw1LazcQXkd0yCAbPu0bi921(pCMvDKQ6dwrhjiZyLbAmoTGuk6aKE7AF(mwSc2RJuLLnOy0hJvgOX40csPOdq6TR9IqUCiwdVsLZa0yLbAmoTGuk6aKE7AV0aYO4QYYguekw)itySYangNwqkfDasVDTxEMiKil881pKPQXkd0yCAbPu0bi921EbYYdpFvcYeiL8q6szrEulpid1NQCGU5oB773klYJA5bzO(uLdu73W23VLI8pAvGeC4u73W23VvwKh1IgeyvNQCGw3W2n3HTgRmqJXPfKsrhG0Bx7bJdqxfSIRQeKjqJvgOX40csPOdq6TR96dwZ8)K5RQ0iai5H01ptsQiqaPHiLwLgbalcKGdN2ARDd]] )


end
