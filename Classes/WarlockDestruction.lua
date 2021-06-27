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


    spec:RegisterPack( "Destruction", 20201207, [[diKqWaqieHhjIs2eI0OiQ4uevAvef5vQqZcr1TaizxI6xQOggrvhdalJO0Zik00er11aO2grr9nrumoaIohaPADIOuzEIi3trTpPQCqrukTqvKhkIsvteGGlcqOojaHSsrQDkv8uHMQuPVcqkTxj)vkdwLomQfd0Jv1Kv4YqBMiFwQYOb0PPSArukEnIOzd62iSBQ(TsdxeooaPy5eEostN01vKTls(UuvnEIc68ikRNOaZxfSFbxauDR4GvS6iR8YkpaYkFYKbqEzLzzSIkzjWkMGFsY9Wk6mbwrabKQIPxT1RycMm4YJQBfP7K4Xkcu1e0KDNp3ZuGtG5FjotnIjiR26VGL0ZuJ4pxrWjdQaI8cSIdwXQJSYlR8aiR8jtga5LvMLfqwrEsbUIkgnIK9veOngOxGvCG0VIjRWfqaPQy6vB9WfqllG7tYq6Kv4ciGpsaIIWnzipCLvEzLVIqJQ0QBfrkf9hPv3Qdav3kYVARxX(xbCKcnVjq66S)yfrNbH4OovA1r2QBf5xT1RibsScYARudo92OneitqRi6mieh1PsRoYy1TI8R26veeU7OTsnfi2qhjiRIOZGqCuNkT6K8QBf5xT1RyVjwmm2BRuJLbOyvGveDgeIJ6uPvhaxDRi)QTEffwIeqSzEJMGFSIOZGqCuNkT6iZv3kYVARxrP9NO4OXYauyk2arMOIOZGqCuNkT6Kmv3kYVARxXetctImZ71aHmvRi6mieh1PsRoaYQBfrNbH4OovXxykkmUIkl6HAgiYqfylXRHBFHlGu(W9WHWvzrpuZargQaBjEnCtkCLv(W9WHWvY6buBcKGnNgUjfUYkF4E4q4QSOhQz1iWMUTeV2Kv(WTVWn5Yxr(vB9kkqoH59AsqMaPLwDa0RUvKF1wVI)6p6QGvC0KGmbwr0zqioQtLwDaq(QBfrNbH4OovXxykkmUIGtsszb(KeIuAtAfpMfibBoTI8R26vubITjhCN8rtAfpwAPveiNA)QB1bGQBfrNbH4OovXxykkmUIGtsszq(j5qWsAES97HlPHlDNGnkqwmc3(Mdxacxsdx6obBuGSyeUjnhUjVI8R26v8xxcY9eSILwDKT6wr0zqioQtv8fMIcJR4ZuTPgbgUjfUa5u73eibBoTI8R26vKUtWMKjWsRoYy1TIOZGqCuNQ4lmffgxXNPAtncmCtkCbYP2Vjqc2CA4sA4s3jiO5Jme5rdKSgkdzIeqmJodcXrf5xT1R4aFJGvZ71axOwA1j5v3kIodcXrDQIVWuuyCfFMQn1iWWnPWfiNA)MajyZPvKF1wVI0FNeM3RPMcelT6a4QBfrNbH4OovXxykkmUIkdrxZMROWzy7xcWjQARNrNbH4iCjnCfibBonCtkChtcwT1dxzkCLpd4W9WHWLeHRYq01S5kkCg2(LaCIQ26z0zqiocxsdxbkjqkqgeIvKF1wVIgbXczflT6iZv3kIodcXrDQIVWuuyCfFMQn1iWWnPWfiNA)MajyZPvKF1wVIpqEPnWfQLwDsMQBf5xT1Rifip2(bNeEfrNbH4OovA1bqwDRi6mieh1Pk(ctrHXv8zQ2uJad3KcxGCQ9BcKGnNwr(vB9kA(BokyflT0kMqG)saYA1T6aq1TIOZGqCuNQ4lmffgxr1iWWTVWv(WL0WLeHBcuZm0sHvKF1wVIsiSnwcZz1wV0QJSv3kYVARxr6ebX6nJirfrNbH4OovA1rgRUveDgeIJ6ufFHPOW4kQmeDn3tyeRjW2k1O8lmj7Xm6miehvKF1wVI9egXAcSTsnk)ctYES0QtYRUvKF1wVI0Dc2Kmbwr0zqioQtLwDaC1TIOZGqCuNQ4lmffgxrseUkdrxZ0Dc2KmbMrNbH4OI8R26v083CuWkwAPvKxS6wDaO6wr0zqioQtv8fMIcJRycuZMlHcNHz(vlfgUKgUYjCjr4(7chB)EgiNA)Sa5bzH7HdHl)QLcBOJegsd3(cxzmCLBf5xT1ROGnVTsnjtGLwDKT6wr(vB9ks3jytSAfrNbH4OovA1rgRUveDgeIJ6ufFHPOW4kownBeelKvmlqc2CA42x4(mvBQrGvKF1wVIpq2De2giX6sMalT6K8QBfrNbH4Oovr(vB9kAeelKvSIVWuuyCffibBonCtkCbC4sA4kNWLeHRYq018Zk)qYOez0zqioc3dhc3Fx4y73ZpR8djJsKfibBonC7lCfibBonCLBfFYEi2uw0dvA1bGsRoaU6wr0zqioQtvKF1wVIpdHn(vB9g0OAfHgvBotGv8h0sRoYC1TIOZGqCuNQi)QTEfFgcB8R26nOr1kcnQ2CMaRisPO)iT0QtYuDRi6mieh1PkYVARxrGCQ9R4lmffgxr(vlf2qhjmKgUjfUjVIpzpeBkl6HkT6aqPvhaz1TI8R26vuWM3wPMKjWkIodcXrDQ0QdGE1TIOZGqCuNQi)QTEfbYP2VIpzpeBkl6HkT6aqPvhaKV6wr0zqioQtv8fMIcJROCcx6obbnFKHipAGK1qzitKaIz0zqioc3dhcxseUkdrxZsMaBSpAGcJGQRJz0zqiocx5wr(vB9koW3iy18EnWfQLwDaaGQBfrNbH4OovXxykkmUIkdrxZsMaBSpAGcJGQRJz0zqiocxsdxWjjPmi)KCiyjnpLiCjnCP7eSrbYIr4Mu4c4WfqfUYNLnCLPWLF1sHn0rcdPvKF1wVIM)MJcwXsRoaiB1TI8R26vKUtWMKjWkIodcXrDQ0QdaYy1TIOZGqCuNQ4lmffgxrWjjPmi)KCiyjnp2(9kYVARxXFDji3tWkwA1bGKxDRi6mieh1Pk(ctrHXvuzrpuZargQaZjEnCtkCLv(kYVARxrkqES9doj8sRoaa4QBfrNbH4OovXxykkmUIKiCLt4QmeDnlzcSX(ObkmcQUoMrNbH4iCpCiCvgIUMnxcf(MrNbH4iCLBf5xT1Ri93jH59AQPaXsRoaiZv3kIodcXrDQIVWuuyCfjr4kNWvzi6AwYeyJ9rduyeuDDmJodcXr4E4q4QmeDnBUek8nJodcXr4k3kYVARxrJib6dZ71EwzQk2eaXsRoaKmv3kYVARxrZFZrbRyfrNbH4OovAPv8h0QB1bGQBf5xT1RiDIGy9M5sOWzyfrNbH4OovA1r2QBf5xT1R4GfKSr3jyZCQYGg0uYQi6mieh1PsRoYy1TIOZGqCuNQ4lmffgxXeOMnxcfodZ8RwkSI8R26vmXQ26LwDsE1TIOZGqCuNQ4lmffgxXeOMnxcfodZ8RwkSI8R26veefuuqsZ7vA1bWv3kIodcXrDQIVWuuyCftGA2Cju4mmZVAPWkYVARxrq4UJM0KGSsRoYC1TIOZGqCuNQ4lmffgxXeOMnxcfodZ8RwkSI8R26vuYeiiC3rPvNKP6wr0zqioQtv8fMIcJRycuZMlHcNHz(vlfgUhoeUkl6HAwncSPBByy4Mu4kR8vKF1wVItuSzksqlT0koqjEcQv3Qdav3kYVARxrAcecBW9jzfrNbH4OovA1r2QBfrNbH4OovXxykkmUIa5u734xTuy4sA4YVAPWg6iHH0WTVWfGWL0WLF1sHn0rcdPHBsHlGdxav4QmeDnBUek8nJodcXr4EmCLt4QmeDnBUek8nJodcXr4sA4QmeDnBUIcNHTFjaNOQTEgDgeIJWvUvKF1wVIpdHn(vB9g0OAfHgvBotGveiNA)sRoYy1TIOZGqCuNQ4lmffgxrLHORzXYcZ71aHSmaZOZGqCeUKgUdeCssklwwyEVgiKLbywGeS50WnPWfGmGRi)QTEf)1LGCpbRyPvNKxDRi6mieh1Pk(ctrHXvKeHRCc3eOMnxcfodZ8RwkmCjnChRMncIfYkMfibBonCpgUaeU9fUjqnBUekCgMfibBonCLB4E4q4stGqytzrpuP5Nv(HKrjc3(cxaQi)QTEfFw5hsgLO0QdGRUveDgeIJ6ufFHPOW4kYVAPWg6iHH0WTVWv2kYVARxXNHWg)QTEdAuTIqJQnNjWkYlwA1rMRUveDgeIJ6uf5xT1RiDNGnjtGv8fMIcJROaLeifidcXWL0WLUtWgfilgHBsZHBYdxsdx5eUKiCvgIUMFw5hsgLiJodcXr4E4q4(7chB)E(zLFizuISajyZPHBFHRajyZPHRCR4t2dXMYIEOsRoauA1jzQUveDgeIJ6uf5xT1ROrqSqwXk(ctrHXvuGscKcKbHy4sA4kNWLeHRYq018Zk)qYOez0zqioc3dhc3Fx4y73ZpR8djJsKfibBonC7lCfibBonCLBfFYEi2uw0dvA1bGsRoaYQBfrNbH4OovXxykkmUIkdrxZMROWzy7xcWjQARNrNbH4iCjnC5xT1ZpqEPnWfQzZBsqRhqnCjnCfibBonCtkChtcwT1dxzkCLpd4kYVARxrJGyHSILwDa0RUveDgeIJ6uf5xT1R4ZqyJF1wVbnQwrOr1MZeyf)bT0QdaYxDRi6mieh1PkYVARxXNHWg)QTEdAuTIqJQnNjWkIuk6pslT6aaav3kYVARxXhi7ocBdKyDjtGveDgeIJ6uPvhaKT6wr(vB9ks)DsyEVMAkqSIOZGqCuNkT6aGmwDRi)QTEfh4BeSAEVg4c1kIodcXrDQ0QdajV6wr0zqioQtvKF1wVIa5u7xXxykkmUIJvZgbXczfZcKGnNgU9fUJvZgbXczfZJjbR26HRmfUYNbC4E4q4sIWvzi6A2CffodB)saorvB9m6miehv8j7HytzrpuPvhakT6aaGRUvKF1wVIgrc0hM3R9SYuvSjaIveDgeIJ6uPvhaK5QBf5xT1RiDNGnXQveDgeIJ6uPvhasMQBfrNbH4OovXxykkmUIIjhLwrpmVdrJcK7h2wPMceBKryIKnSiJaAMSejWrf5xT1Riqo1(LwDaaqwDRi6mieh1PkUjQif1kYVARxXuSWyqiwXumCcRi)QLcBOJegsd3(cxacxsd3Fx4y73Za5u7NfibBonCtAoCbq(W9WHW93fo2(9mDIGy9M5sOWzywGeS50WnP5WfaahUKgUkdrxZdwqYgDNGnZPkdAqtjlJodcXr4sA4(7chB)EEWcs2O7eSzovzqdAkzzbsWMtd3KMdxaaC4E4q4QmeDnpybjB0Dc2mNQmObnLSm6miehHlPH7VlCS975blizJUtWM5uLbnOPKLfibBonCtAoCbaWHlPHRCc3Fx4y73Z0jcI1BMlHcNHzbsWMtd3(cxLf9qnRgb20TnmmCpCiC)DHJTFptNiiwVzUekCgMfibBonCpgU)UWX2VNPteeR3mxcfodZJjbR26HBFHRYIEOMvJaB62gggUYTIPyrZzcSIj2f2O7eSrbYIbT0Qdaa6v3kIodcXrDQIVWuuyCfbNKKYG8tYHGL08y73dxsdx6obBuGSyeU9nhUaKbC4cOcx5ZYy4ktHRYq01SeKPa3uOiJodcXr4sA4sIWnflmgeI5e7cB0Dc2OazXGwr(vB9k(Rlb5EcwXsRoYkF1TIOZGqCuNQ4lmffgxrWjjP8GfKSr3jyZCQYGg0uYYtjQi)QTEfFG8sBGlulT6ilav3kIodcXrDQIVWuuyCfbNKKYG8tYHGL08uIWL0WLeHBkwymieZj2f2O7eSrbYIbnCjnCjr4QmeDnJcEypR26z0zqioQi)QTEfFG8sBGlulT6iRSv3kIodcXrDQIVWuuyCfjr4MIfgdcXCIDHn6obBuGSyqdxsdxLHORzuWd7z1wpJodcXr4sA4kNWDGGtsszuWd7z1wplqc2CA4Mu4(mvBQrGH7HdHl4KKugKFsoeSKMNseUYTI8R26v8bYlTbUqT0QJSYy1TIOZGqCuNQ4lmffgxrseUPyHXGqmNyxyJUtWgfilg0W9WHWLUtWgfilgHBFZHBYZaUI8R26vKcKhB)GtcV0QJSjV6wr0zqioQtv8fMIcJROCcx6obBuGSyeU9nhUjpd4WfqfUYNLnCLPWLF1sHn0rcdPHRCRi)QTEfFG8sBGlulT6ilGRUveDgeIJ6ufFHPOW4k(azrpKgU9fUaur(vB9k(Rlb5EcwXsRoYkZv3kYVARxrZFZrbRyfrNbH4OovAPLwXuOGARxDKvEzLhaaKfqwX(zHBEpAfberKyfkocxzoC5xT1dxOrvAoKUIjeRKbXkMScxabKQIPxT1dxaTSaUpjdPtwHlGa(ibikc3KH8Wvw5Lv(q6q6Kv4ciwgI)KIJWfeLwbgU)saYA4cI9mNMd3KT)JjuA46RdOaYccPjy4YVARtd31HKLdP5xT1P5ec8xcqwNLqyBSeMZQTo5M0SAeyFYtkjsGAMHwkmKMF1wNMtiWFjaz948z6ebX6TeOgsZVARtZje4VeGSEC(CpHrSMaBRuJYVWKShj3KMvgIUM7jmI1eyBLAu(fMK9ygDgeIJqA(vBDAoHa)LaK1JZNP7eSjzcmKMF1wNMtiWFjaz948zZFZrbRi5M0mjugIUMP7eSjzcmJodcXriDiDYkCbeldXFsXr4IPqbzHRAey4QaXWLFDfHRrdxofBqgeI5qA(vBD6mnbcHn4(KmKMF1wNo)me24xT1BqJQK7mbodKtTp5M0mqo1(n(vlfsk)QLcBOJegs7das5xTuydDKWqAsagqPmeDnBUek8nJodcXXr5OmeDnBUek8nJodcXbPkdrxZMROWzy7xcWjQARNrNbH4qUH08R260JZN)1LGCpbRi5M0SYq01SyzH59AGqwgGz0zqioiDGGtsszXYcZ71aHSmaZcKGnNMeazahsZVARtpoF(zLFizucYnPzsiNeOMnxcfodZ8RwkK0XQzJGyHSIzbsWMtpcqFjqnBUekCgMfibBovUhoqtGqytzrpuP5Nv(HKrj6dGqA(vBD6X5ZpdHn(vB9g0Ok5otGZ8IKBsZ8RwkSHosyiTpzdP5xT1PhNpt3jytYei5pzpeBkl6HkDgaYnPzbkjqkqgeIKs3jyJcKfJKMtoPYHekdrxZpR8djJsKrNbH44WHFx4y73ZpR8djJsKfibBoTpbsWMtLBin)QTo948zJGyHSIK)K9qSPSOhQ0zai3KMfOKaPazqisQCiHYq018Zk)qYOez0zqiooC43fo2(98Zk)qYOezbsWMt7tGeS5u5gsZVARtpoF2iiwiRi5M0SYq01S5kkCg2(LaCIQ26z0zqioiLF1wp)a5L2axOMnVjbTEavsfibBonPXKGvBDzs(mGdP5xT1PhNp)me24xT1BqJQK7mbo)dAin)QTo9485NHWg)QTEdAuLCNjWzKsr)rAin)QTo9485hi7ocBdKyDjtGH08R260JZNP)ojmVxtnfigsZVARtpoFEGVrWQ59AGludP5xT1PhNpdKtTp5pzpeBkl6HkDgaYnP5XQzJGyHSIzbsWMt7BSA2iiwiRyEmjy1wxMKpd4dhiHYq01S5kkCg2(LaCIQ26z0zqiocP5xT1PhNpBejqFyEV2ZktvXMaigsZVARtpoFMUtWMy1qA(vBD6X5Za5u7tUjnlMCuAf9W8oenkqUFyBLAkqSrgHjs2WImcOzYsKahH08R260JZNtXcJbHi5otGZj2f2O7eSrbYIbL8umCcN5xTuydDKWqAFaq6VlCS97zGCQ9ZcKGnNM0maYF4WVlCS97z6ebX6nZLqHZWSajyZPjndaGjvzi6AEWcs2O7eSzovzqdAkzz0zqioi93fo2(98GfKSr3jyZCQYGg0uYYcKGnNM0maa(WbLHOR5blizJUtWM5uLbnOPKLrNbH4G0Fx4y73ZdwqYgDNGnZPkdAqtjllqc2CAsZaaysLZVlCS97z6ebX6nZLqHZWSajyZP9PSOhQz1iWMUTHHho87chB)EMorqSEZCju4mmlqc2C6XFx4y73Z0jcI1BMlHcNH5XKGvB9(uw0d1SAeyt32Wq5gsZVARtpoF(xxcY9eSIKBsZGtsszq(j5qWsAES97Ks3jyJcKfJ(MbidyaL8zzuMugIUMLGmf4Mcfz0zqioiLePyHXGqmNyxyJUtWgfilg0qA(vBD6X5ZpqEPnWfQKBsZGtss5blizJUtWM5uLbnOPKLNsesZVARtpoF(bYlTbUqLCtAgCsskdYpjhcwsZtjiLePyHXGqmNyxyJUtWgfilgusjHYq01mk4H9SARNrNbH4iKMF1wNEC(8dKxAdCHk5M0mjsXcJbHyoXUWgDNGnkqwmOKQmeDnJcEypR26z0zqioivodeCsskJcEypR26zbsWMtt6zQ2uJapCaCsskdYpjhcwsZtjKBin)QTo948zkqES9dojCYnPzsKIfgdcXCIDHn6obBuGSyqpCGUtWgfilg9nN8mGdP5xT1PhNp)a5L2axOsUjnlh6obBuGSy03CYZagqjFwwzIF1sHn0rcdPYnKMF1wNEC(8VUeK7jyfj3KMFGSOhs7dGqA(vBD6X5ZM)MJcwXq6qA(vBDAMxCwWM3wPMKjqYnP5eOMnxcfodZ8RwkKu5qIFx4y73Za5u7Nfipi7Wb(vlf2qhjmK2Nmk3qA(vBDAMx848z6obBIvdP5xT1PzEXJZNFGS7iSnqI1LmbsUjnpwnBeelKvmlqc2CAFpt1MAeyin)QTonZlEC(SrqSqwrYFYEi2uw0dv6maKBsZcKGnNMeGjvoKqzi6A(zLFizuIm6miehho87chB)E(zLFizuISajyZP9jqc2CQCdP5xT1PzEXJZNFgcB8R26nOrvYDMaN)bnKMF1wNM5fpoF(ziSXVAR3Ggvj3zcCgPu0FKgsZVARtZ8IhNpdKtTp5pzpeBkl6HkDgaYnPz(vlf2qhjmKMuYdP5xT1PzEXJZNfS5TvQjzcmKMF1wNM5fpoFgiNAFYFYEi2uw0dv6maH08R260mV4X5Zd8ncwnVxdCHk5M0SCO7ee08rgI8ObswdLHmrciMrNbH44WbsOmeDnlzcSX(ObkmcQUoMrNbH4qUH08R260mV4X5ZM)MJcwrYnPzLHORzjtGn2hnqHrq11Xm6miehKcojjLb5NKdblP5PeKs3jyJcKfJKamGs(SSYe)QLcBOJegsdP5xT1PzEXJZNP7eSjzcmKMF1wNM5fpoF(xxcY9eSIKBsZGtsszq(j5qWsAES97H08R260mV4X5ZuG8y7hCs4KBsZkl6HAgiYqfyoXRjjR8H08R260mV4X5Z0FNeM3RPMcej3KMjHCugIUMLmb2yF0afgbvxhZOZGqCC4GYq01S5sOW3m6miehYnKMF1wNM5fpoF2isG(W8ETNvMQInbqKCtAMeYrzi6AwYeyJ9rduyeuDDmJodcXXHdkdrxZMlHcFZOZGqCi3qA(vBDAMx848zZFZrbRyiDin)QTon)d6mDIGy9M5sOWzyin)QTon)d6X5ZdwqYgDNGnZPkdAqtjlKMF1wNM)b9485eRARtUjnNa1S5sOWzyMF1sHH08R2608pOhNpdIckkiP59i3KMtGA2Cju4mmZVAPWqA(vBDA(h0JZNbH7oAstcYi3KMtGA2Cju4mmZVAPWqA(vBDA(h0JZNLmbcc3DqUjnNa1S5sOWzyMF1sHH08R2608pOhNpprXMPibLCtAobQzZLqHZWm)QLcpCqzrpuZQrGnDBddtsw5dPdP5xT1PzGCQ9N)1LGCpbRi5M0m4KKugKFsoeSKMhB)oP0Dc2OazXOVzaiLUtWgfilgjnN8qA(vBDAgiNA)JZNP7eSjzcKCtA(zQ2uJatciNA)MajyZPH08R260mqo1(hNppW3iy18EnWfQKBsZpt1MAeysa5u73eibBoLu6obbnFKHipAGK1qzitKaIz0zqiocP5xT1PzGCQ9poFM(7KW8En1uGi5M08ZuTPgbMeqo1(nbsWMtdP5xT1PzGCQ9poF2iiwiRi5M0SYq01S5kkCg2(LaCIQ26z0zqioivGeS50KgtcwT1Lj5Za(WbsOmeDnBUIcNHTFjaNOQTEgDgeIdsfOKaPazqigsZVARtZa5u7FC(8dKxAdCHk5M08ZuTPgbMeqo1(nbsWMtdP5xT1PzGCQ9poFMcKhB)GtcpKMF1wNMbYP2)48zZFZrbRi5M08ZuTPgbMeqo1(nbsWMtdPdP5xT1PzKsr)r6X5Z9Vc4ifAEtG01z)XqA(vBDAgPu0FKEC(mbsScYARudo92OneitqdP5xT1PzKsr)r6X5ZGWDhTvQPaXg6ibzH08R260msPO)i9485EtSyyS3wPgldqXQadP5xT1PzKsr)r6X5Zclrci2mVrtWpgsZVARtZiLI(J0JZNL2FIIJgldqHPydezIqA(vBDAgPu0FKEC(CIjHjrM59AGqMQH08R260msPO)i948zbYjmVxtcYeiLCtAwzrpuZargQaBjETpaP8hoOSOhQzGidvGTeVMKSYF4GK1dO2eibBonjzL)WbLf9qnRgb20TL41MSY3xYLpKMF1wNMrkf9hPhNp)R)ORcwXrtcYeyin)QTonJuk6pspoFwbITjhCN8rtAfpsUjndojjLf4tsisPnPv8ywGeS50kstGF1rwzozkT0Qa]] )


end
