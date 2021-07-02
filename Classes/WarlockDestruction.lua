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


    spec:RegisterPack( "Destruction", 20210701, [[diKrYaqiqHhruaBcuzuIeofrPwfrjELk0SavDlaI2Lu(fagMiPJPcwMi4zefAAIeDnaQTruuFJOKghaHZbqQwhrrkZte6Ekv7tPKdcqkTqvupKOivtKOi5IefOtcqswPi1oLQ8uHMQuvFfGKAVs(ROgSkDyulgOhRQjRKlJSzI8zLIrdOtt1QbifVgu0SHCBq2nLFRy4evhhGelNWZHA6KUUuz7IOVRuQXtuqNhuA9efX8vr2VGRdv)kUyLQEjKAchsvwt9qlbz8aGibzUIkSYPkkNFyYBOkAmevrzkcRIUx9XQOCgw0WRQFfXtN4Pkcuv5yzAaaWgxb2b2(bcaSd1Hy1h7fSKca2HEaQiyNJuavwbwXfRu1lHut4qQYAQhAjiJhaehsOICNcCevm6qY0RiqFTiRaR4IWFfLPiSk6E1hlCbuZc08WmKoDhc2W9a8HBcPMWHkICSIR(vKWyYEcx9REhQ(vKF1hRIBpc0kj5wwq4Xy7PksgdIOvDU0Qxcv)kYV6JvricAeWMhPmQ79vEjigcxrYyqeTQZLw9KXQFf5x9XQiiAMvEKYkqktgbbBfjJbr0QoxA1lLv)kYV6JvXnDSy5SLhPmltiXOaRizmiIw15sREaU6xr(vFSkkC5Yru2Tmwo)ufjJbr0QoxA1tMR(vKF1hRIsZ3HPvMLjKWvkdsmufjJbr0QoxA1twR(vKF1hRIY7eUeSUTjdIySwrYyqeTQZLw9aev)ksgdIOvDUIVWvs4CfvwSH0gqIrkWS8xd3TcxarQH7PtHRYInK2asmsbML)A4My4MqQH7PtHRKVbOMfee7goCtmCti1W90PWvzXgsBQdrzDYYFnNqQH7wHBktTI8R(yvuqSC32KLqmeHlT6bOx9Ri)Qpwf)XEYubR0klHyiQIKXGiAvNlT6Di1QFfjJbr0QoxXx4kjCUIGDssnb9WeryCwAep1eee7gUI8R(yvubs5odC6SvwAepvAPveiNC(QF17q1VIKXGiAvNR4lCLeoxrWojPgi)WCjyjTTMTTWfUWfpDOmgilwH7w7H7HWfUWfpDOmgilwHBI7HBkRi)Qpwf)XKq8gbRuPvVeQ(vKmgerR6CfFHRKW5k(mwZQdrHBIHlqo58zbbXUHRi)QpwfXthkl5cQ0QNmw9RizmiIw15k(cxjHZv8zSMvhIc3edxGCY5ZccIDdhUWfU4Pdb62QHiELbHntYqgsoIAKXGiAvr(vFSkUO3Hy1TnzWbPLw9sz1VIKXGiAvNR4lCLeoxXNXAwDikCtmCbYjNplii2nCf5x9XQi(NoHBBYQRaPsREaU6xrYyqeTQZv8fUscNROYiY0MBkjmgL)bcSdR(ynYyqeTcx4cxbbXUHd3ed3vNGvFSWvwc3uBaoCpDkCHr4QmImT5MscJr5FGa7WQpwJmgerRWfUWvqsccdKbruf5x9XQOdbniwPsREYC1VIKXGiAvNR4lCLeoxXNXAwDikCtmCbYjNplii2nCf5x9XQ4dKhCgCqAPvpzT6xr(vFSkIbYRzBWoHvrYyqeTQZLw9aev)ksgdIOvDUIVWvs4CfFgRz1HOWnXWfiNC(SGGy3WvKF1hRIU9UrcwPslTIYf0pqGSw9REhQ(vKmgerR6Cf5x9XQOeHYRbYnw9XQ4IWVWLR(yvugugsFNsRWfKKgbfU)abYA4csBCd3cxaT)tYvC4AJbibYciPou4YV6JHd3XqW2Q4lCLeoxr1HOWDRWn1WfUWfgHRCsBmYtsLw9sO6xr(vFSkI7GGgl7qYRizmiIw15sREYy1VIKXGiAvNROXquf1bIYJugAmSkMoC(hdRIUx9XWvKF1hRI6ar5rkdngwftho)JHvr3R(y4sREPS6xrYyqeTQZv0yiQI4brmqCgtVG0SspqZbu6OkYV6Jvr8GigioJPxqAwPhO5akDuPvpax9Ri)QpwfLqeg4lyjTIKXGiAvNlT6jZv)ksgdIOvDUIVWvs4CfvgrM22iCOXfuEKYy(fUK)uJmgerRkYV6JvXnchACbLhPmMFHl5pvA1twR(vKF1hRI4PdLLCbvrYyqeTQZLw9aev)ksgdIOvDUIVWvs4CfHr4QmImTHNouwYfuJmgerRkYV6Jvr3E3ibRuPLwrEOQF17q1VIKXGiAvNR4lCLeoxr5K2CtIegJA8REskCHlCtr4cJW9NbTMTTgqo58nbXlyd3tNcx(vpjLjJGCchUBfUYy4k7kYV6Jvrb7wEKYsUGkT6Lq1VI8R(yvepDOSy0ksgdIOvDU0QNmw9RizmiIw15k(cxjHZvCnAZHGgeRutqqSB4WDRW9zSMvhIQi)QpwfFGSzekViOXKCbvA1lLv)ksgdIOvDUI8R(yv0HGgeRufFHRKW5kkii2nC4My4c4WfUWnfHlmcxLrKPTNv(rWIHAKXGiAfUNofU)mO1ST1Ew5hblgQjii2nC4Uv4kii2nC4k7k(W(ikRSydP4Q3HsREaU6xrYyqeTQZvKF1hRIpJqz(vFSmYXAfrowZgdrv8x4sREYC1VIKXGiAvNRi)QpwfFgHY8R(yzKJ1kICSMngIQiHXK9eU0QNSw9RizmiIw15kYV6JvrGCY5R4lCLeoxr(vpjLjJGCchUjgUPSIpSpIYkl2qkU6DO0QhGO6xr(vFSkky3YJuwYfufjJbr0QoxA1dqV6xrYyqeTQZvKF1hRIa5KZxXh2hrzLfBifx9ouA17qQv)ksgdIOvDUIVWvs4Cftr4INoeOBRgI4vge2mjdzi5iQrgdIOv4E6u4cJWvzezAtYfuMTvgu4qyDmQrgdIOv4k7kYV6JvXf9oeRUTjdoiT0Q3Hdv)ksgdIOvDUIVWvs4CfvgrM2KCbLzBLbfoewhJAKXGiAfUWfUGDssnq(H5sWsARtE4cx4INougdKfRWnXWfWHlGmCtTLq4klHl)QNKYKrqoHRi)QpwfD7DJeSsLw9oKq1VI8R(yvepDOSKlOksgdIOvDU0Q3bzS6xrYyqeTQZv8fUscNRiyNKudKFyUeSK2wZ2wf5x9XQ4pMeI3iyLkT6DiLv)ksgdIOvDUIVWvs4CfvwSH0gqIrkWM8xd3ed3esTI8R(yvedKxZ2GDcR0Q3bax9RizmiIw15k(cxjHZvegHBkcxLrKPnjxqz2wzqHdH1XOgzmiIwH7PtHRYiY0MBsKWMgzmiIwHRSRi)QpwfX)0jCBtwDfivA17Gmx9RizmiIw15k(cxjHZvegHBkcxLrKPnjxqz2wzqHdH1XOgzmiIwH7PtHRYiY0MBsKWMgzmiIwHRSRi)QpwfDi5KTCBt(zLXQyKdKkT6DqwR(vKF1hRIU9UrcwPksgdIOvDU0sR4VWv)Q3HQFf5x9XQiUdcASSBsKWyufjJbr0QoxA1lHQFf5x9XQ4IfWmJNou2nSYGoYvyRizmiIw15sREYy1VIKXGiAvNR4lCLeoxr5K2CtIegJA8REsQI8R(yvu(O(yLw9sz1VIKXGiAvNR4lCLeoxr5K2CtIegJA8REsQI8R(yveKeysat32uA1dWv)ksgdIOvDUIVWvs4CfLtAZnjsymQXV6jPkYV6Jvrq0mRSuNa2sREYC1VIKXGiAvNR4lCLeoxr5K2CtIegJA8REsQI8R(yvuYfeiAMvPvpzT6xrYyqeTQZv8fUscNROCsBUjrcJrn(vpjfUNofUkl2qAtDikRtE5u4My4MqQvKF1hRIDyk7kbHlT0kUijUdPv)Q3HQFfjJbr0QoxXfHFHlx9XQOmOmK(oLwHlLKeWgUQdrHRcKcx(1reUooC5KSJyqe1Qi)QpwfXYjekJMhMLw9sO6xrYyqeTQZv8fUscNRiqo58z(vpjfUWfU8REsktgb5eoC3kCpeUWfU8REsktgb5eoCtmCbC4cidxLrKPn3KiHnnYyqeTc3JHBkcxLrKPn3KiHnnYyqeTcx4cxLrKPn3usymk)deyhw9XAKXGiAfUYUI8R(yv8zekZV6JLrowRiYXA2yiQIa5KZxA1tgR(vKmgerR6CfFHRKW5kQmImTjgw42MmiILjuJmgerRWfUWDrGDssnXWc32KbrSmHAccIDdhUjgUhAaUI8R(yv8htcXBeSsLw9sz1VIKXGiAvNR4lCLeoxryeUPiCLtAZnjsymQXV6jPWfUWDnAZHGgeRutqqSB4W9y4EiC3kCLtAZnjsymQjii2nC4k7W90PWflNqOSYInKIBpR8JGfdfUBfUhQi)QpwfFw5hblgQ0QhGR(vKmgerR6CfFHRKW5kYV6jPmzeKt4WDRWnHkYV6JvXNrOm)Qpwg5yTIihRzJHOkYdvA1tMR(vKmgerR6Cf5x9XQiE6qzjxqv8fUscNROGKeegidIOWfUWfpDOmgilwHBI7HBkdx4c3ueUWiCvgrM2Ew5hblgQrgdIOv4E6u4(ZGwZ2w7zLFeSyOMGGy3WH7wHRGGy3WHRSR4d7JOSYInKIREhkT6jRv)ksgdIOvDUI8R(yv0HGgeRufFHRKW5kkijbHbYGikCHlCtr4cJWvzezA7zLFeSyOgzmiIwH7PtH7pdAnBBTNv(rWIHAccIDdhUBfUccIDdhUYUIpSpIYkl2qkU6DO0QhGO6xrYyqeTQZv8fUscNROYiY0MBkjmgL)bcSdR(ynYyqeTcx4cx(vFS2dKhCgCqAZTSeY3audx4cxbbXUHd3ed3vNGvFSWvwc3uBaUI8R(yv0HGgeRuPvpa9QFfjJbr0Qoxr(vFSk(mcL5x9XYihRve5ynBmevXFHlT6Di1QFfjJbr0Qoxr(vFSk(mcL5x9XYihRve5ynBmevrcJj7jCPvVdhQ(vKF1hRIpq2mcLxe0ysUGQizmiIw15sREhsO6xr(vFSkI)Pt42MS6kqQIKXGiAvNlT6DqgR(vKF1hRIl6DiwDBtgCqAfjJbr0QoxA17qkR(vKmgerR6Cf5x9XQiqo58v8fUscNR4A0MdbniwPMGGy3WH7wH7A0MdbniwP2QtWQpw4klHBQnahUNofUWiCvgrM2CtjHXO8pqGDy1hRrgdIOvfFyFeLvwSHuC17qPvVdaU6xr(vFSk6qYjB52M8ZkJvXihivrYyqeTQZLw9oiZv)kYV6Jvr80HYIrRizmiIw15sREhK1QFfjJbr0QoxXx4kjCUIIoJKgXgQnlrgdK3gLhPScKYWc5canSOrakDUC50QI8R(yveiNC(sREhaev)ksgdIOvDUIJ8kIjTI8R(yvmjlCgervmjJ6OkYV6jPmzeKt4WDRW9q4cx4(ZGwZ2wdiNC(MGGy3WHBI7H7Hud3tNc3Fg0A22A4oiOXYUjrcJrnbbXUHd3e3d3daoCHlCvgrM2wSaMz80HYUHvg0rUcBJmgerRWfUW9NbTMTT2IfWmJNou2nSYGoYvyBccIDdhUjUhUhaC4E6u4QmImTTybmZ4PdLDdRmOJCf2gzmiIwHlCH7pdAnBBTflGzgpDOSByLbDKRW2eee7goCtCpCpa4WfUWnfH7pdAnBBnChe0yz3KiHXOMGGy3WH7wHRYInK2uhIY6KxofUNofU)mO1ST1WDqqJLDtIegJAccIDdhUhd3Fg0A22A4oiOXYUjrcJrTvNGvFSWDRWvzXgsBQdrzDYlNcxzxXKSiBmevr5ZGY4PdLXazXcxA17aGE1VIKXGiAvNR4lCLeoxrWojPgi)WCjyjTTMTTWfUWfpDOmgilwH7w7H7HgGdxaz4MAtgdxzjCvgrM2Kqmg4KKenYyqeTcx4cxyeUjzHZGiQjFgugpDOmgilw4kYV6JvXFmjeVrWkvA1lHuR(vKmgerR6CfFHRKW5kc2jj1wSaMz80HYUHvg0rUcBRtEf5x9XQ4dKhCgCqAPvVeou9RizmiIw15k(cxjHZveStsQbYpmxcwsBDYdx4cxyeUjzHZGiQjFgugpDOmgilw4WfUWfgHRYiY0gj4L)S6J1iJbr0QI8R(yv8bYdodoiT0Qxcju9RizmiIw15k(cxjHZvegHBsw4miIAYNbLXthkJbYIfoCHlCvgrM2ibV8NvFSgzmiIwHlCHBkc3fb2jj1ibV8NvFSMGGy3WHBIH7ZynRoefUNofUGDssnq(H5sWsARtE4k7kYV6JvXhip4m4G0sREjiJv)ksgdIOvDUIVWvs4CfHr4MKfodIOM8zqz80HYyGSyHd3tNcx80HYyGSyfUBThUPSb4kYV6JvrmqEnBd2jSsREjKYQFfjJbr0QoxXx4kjCUIPiCXthkJbYIv4U1E4MYgGdxaz4MAlHWvwcx(vpjLjJGCchUYUI8R(yv8bYdodoiT0QxcaU6xrYyqeTQZv8fUscNR4dKfBiC4Uv4EOI8R(yv8htcXBeSsLw9sqMR(vKF1hRIU9UrcwPksgdIOvDU0slTIjjb2hR6LqQjK6HesvwR42SWCBdUIaQGKpcLwHRmhU8R(yHlYXkUfsxr5IrYrufLbcxzkcRIUx9Xcxa1SanpmdPLbc30Diyd3dWhUjKAchcPdPLbcxzqzi9DkTcxqsAeu4(deiRHliTXnClCb0(pjxXHRngGeilGK6qHl)QpgoChdbBlKMF1hd3KlOFGazDxIq51a5gR(yW7s7QdrBLkCWqoPng5jPqA(vFmCtUG(bcK1J7aG7GGgllN0qA(vFmCtUG(bcK1J7a0HPSRee8gdr76ar5rkdngwftho)JHvr3R(y4qA(vFmCtUG(bcK1J7a0HPSRee8gdr74brmqCgtVG0SspqZbu6OqA(vFmCtUG(bcK1J7aiHimWxWsAin)QpgUjxq)abY6XDa2iCOXfuEKYy(fUK)e8U0UYiY02gHdnUGYJugZVWL8NAKXGiAfsZV6JHBYf0pqGSECha80HYsUGcP5x9XWn5c6hiqwpUdGBVBKGvcExAhgkJitB4PdLLCb1iJbr0kKoKwgiCLbLH03P0kCPKKa2WvDikCvGu4YVoIW1XHlNKDedIOwin)QpgEhlNqOmAEygsZV6JH3FgHY8R(yzKJv4ngI2bYjNhExAhiNC(m)QNKGJF1tszYiiNWBDao(vpjLjJGCcNiGbKkJitBUjrcBAKXGiADmfkJitBUjrcBAKXGiAbNYiY0MBkjmgL)bcSdR(ynYyqeTKDin)Qpg(4oa)ysiEJGvcExAxzezAtmSWTnzqeltOgzmiIwWTiWojPMyyHBBYGiwMqnbbXUHt8qdWH08R(y4J7a8SYpcwme8U0omsHCsBUjrcJrn(vpjb3A0MdbniwPMGGy3WhpSLCsBUjrcJrnbbXUHL9Pty5ecLvwSHuC7zLFeSyOToesZV6JHpUdWZiuMF1hlJCScVXq0ope8U0o)QNKYKrqoH3kHqA(vFm8XDaWthkl5cc(h2hrzLfBifVFaExAxqsccdKbreC4PdLXazXkX9ucxkGHYiY02Zk)iyXqnYyqeToD6NbTMTT2Zk)iyXqnbbXUH3sqqSByzhsZV6JHpUdGdbniwj4FyFeLvwSHu8(b4DPDbjjimqgerWLcyOmImT9SYpcwmuJmgerRtN(zqRzBR9SYpcwmutqqSB4Teee7gw2H08R(y4J7a4qqdIvcExAxzezAZnLegJY)ab2HvFSgzmiIwWXV6J1EG8GZGdsBULLq(gGkCccIDdN4QtWQpMSKAdWH08R(y4J7a8mcL5x9XYihRWBmeT)lCin)Qpg(4oapJqz(vFSmYXk8gdr7egt2t4qA(vFm8XDaEGSzekViOXKCbfsZV6JHpUda(NoHBBYQRaPqA(vFm8XDaw07qS62Mm4G0qA(vFm8XDaaYjNh(h2hrzLfBifVFaExAFnAZHGgeRutqqSB4TwJ2CiObXk1wDcw9XKLuBa(0jyOmImT5MscJr5FGa7WQpwJmgerRqA(vFm8XDaCi5KTCBt(zLXQyKdKcP5x9XWh3bapDOSy0qA(vFm8XDaaYjNhExAx0zK0i2qTzjYyG82O8iLvGugwixaOHfncqPZLlNwH08R(y4J7aKKfodIi4ngI2LpdkJNougdKflm8jzuhTZV6jPmzeKt4Toa3pdAnBBnGCY5BccIDdN4(HupD6NbTMTTgUdcASSBsKWyutqqSB4e3pay4ugrM2wSaMz80HYUHvg0rUcBJmgerl4(zqRzBRTybmZ4PdLDdRmOJCf2MGGy3WjUFaWNoPmImTTybmZ4PdLDdRmOJCf2gzmiIwW9ZGwZ2wBXcyMXthk7gwzqh5kSnbbXUHtC)aGHlf)mO1ST1WDqqJLDtIegJAccIDdVLYInK2uhIY6KxoD60pdAnBBnChe0yz3KiHXOMGGy3Wh)zqRzBRH7GGgl7Mejmg1wDcw9X2szXgsBQdrzDYlNKDin)Qpg(4oa)ysiEJGvcExAhStsQbYpmxcwsBRzBdo80HYyGSyT1(HgGbKP2KrzrzezAtcXyGtss0iJbr0coyKKfodIOM8zqz80HYyGSyHdP5x9XWh3b4bYdodoifExAhStsQTybmZ4PdLDdRmOJCf2wN8qA(vFm8XDaEG8GZGdsH3L2b7KKAG8dZLGL0wNC4Grsw4miIAYNbLXthkJbYIfgoyOmImTrcE5pR(ynYyqeTcP5x9XWh3b4bYdodoifExAhgjzHZGiQjFgugpDOmgilwy4ugrM2ibV8NvFSgzmiIwWLIfb2jj1ibV8NvFSMGGy3Wj(mwZQdrNob2jj1a5hMlblPTo5YoKMF1hdFChamqEnBd2jm4DPDyKKfodIOM8zqz80HYyGSyHpDcpDOmgilwBTNYgGdP5x9XWh3b4bYdodoifExApf4PdLXazXAR9u2amGm1wcYc)QNKYKrqoHLDin)Qpg(4oa)ysiEJGvcExA)bYIneERdH08R(y4J7a427gjyLcPdP5x9XWnEODb7wEKYsUGG3L2LtAZnjsymQXV6jj4sbm(zqRzBRbKtoFtq8c2tN4x9KuMmcYj8wYOSdP5x9XWnEOJ7aGNouwmAin)QpgUXdDChGhiBgHYlcAmjxqW7s7RrBoe0GyLAccIDdV1ZynRoefsZV6JHB8qh3bWHGgeRe8pSpIYkl2qkE)a8U0UGGy3Wjcy4sbmugrM2Ew5hblgQrgdIO1Pt)mO1ST1Ew5hblgQjii2n8wccIDdl7qA(vFmCJh64oapJqz(vFSmYXk8gdr7)chsZV6JHB8qh3b4zekZV6JLrowH3yiANWyYEchsZV6JHB8qh3baiNCE4FyFeLvwSHu8(b4DPD(vpjLjJGCcNykdP5x9XWnEOJ7aiy3YJuwYfuin)QpgUXdDChaGCY5H)H9ruwzXgsX7hcP5x9XWnEOJ7aSO3Hy1TnzWbPW7s7PapDiq3wneXRmiSzsgYqYruJmgerRtNGHYiY0MKlOmBRmOWHW6yuJmgerlzhsZV6JHB8qh3bWT3nsWkbVlTRmImTj5ckZ2kdkCiSog1iJbr0coWojPgi)WCjyjT1jho80HYyGSyLiGbKP2sqw4x9KuMmcYjCin)QpgUXdDCha80HYsUGcP5x9XWnEOJ7a8JjH4ncwj4DPDWojPgi)WCjyjTTMTTqA(vFmCJh64oayG8A2gStyW7s7kl2qAdiXifyt(RjMqQH08R(y4gp0XDaW)0jCBtwDfibVlTdJuOmImTj5ckZ2kdkCiSog1iJbr060jLrKPn3KiHnnYyqeTKDin)QpgUXdDChahsozl32KFwzSkg5aj4DPDyKcLrKPnjxqz2wzqHdH1XOgzmiIwNoPmImT5MejSPrgdIOLSdP5x9XWnEOJ7a427gjyLcPdP5x9XWTFH3XDqqJLDtIegJcP5x9XWTFHpUdWIfWmJNou2nSYGoYvydP5x9XWTFHpUdG8r9XG3L2LtAZnjsymQXV6jPqA(vFmC7x4J7aascmjGPBBG3L2LtAZnjsymQXV6jPqA(vFmC7x4J7aaIMzLL6eWcVlTlN0MBsKWyuJF1tsH08R(y42VWh3bqYfeiAMf8U0UCsBUjrcJrn(vpjfsZV6JHB)cFChGomLDLGWW7s7YjT5Mejmg14x9K0Ptkl2qAtDikRtE5uIjKAiDin)QpgUbKto)(pMeI3iyLG3L2b7KKAG8dZLGL02A22GdpDOmgilwBTFao80HYyGSyL4EkdP5x9XWnGCY5pUdaE6qzjxqW7s7pJ1S6quIa5KZNfee7goKMF1hd3aYjN)4oal6DiwDBtgCqk8U0(ZynRoeLiqo58zbbXUHHdpDiq3wneXRmiSzsgYqYruJmgerRqA(vFmCdiNC(J7aG)Pt42MS6kqcExA)zSMvhIseiNC(SGGy3WH08R(y4gqo58h3bWHGgeRe8U0UYiY0MBkjmgL)bcSdR(ynYyqeTGtqqSB4exDcw9XKLuBa(0jyOmImT5MscJr5FGa7WQpwJmgerl4eKKGWazqefsZV6JHBa5KZFChGhip4m4Gu4DP9NXAwDikrGCY5ZccIDdhsZV6JHBa5KZFChamqEnBd2jSqA(vFmCdiNC(J7a427gjyLG3L2FgRz1HOebYjNplii2nCiDin)QpgUrymzpHpUdW2JaTssULfeEm2EkKMF1hd3imMSNWh3baIGgbS5rkJ6EFLxcIHWH08R(y4gHXK9e(4oaGOzw5rkRaPmzeeSH08R(y4gHXK9e(4oaB6yXYzlpszwMqIrbgsZV6JHBegt2t4J7aiC5Yru2Tmwo)uin)QpgUrymzpHpUdG08DyALzzcjCLYGedfsZV6JHBegt2t4J7aiVt4sW62MmiIXAin)QpgUrymzpHpUdGGy5UTjlHyicdVlTRSydPnGeJuGz5VUfGi1tNuwSH0gqIrkWS8xtmHupDsY3auZccIDdNycPE6KYInK2uhIY6KL)AoHu3kLPgsZV6JHBegt2t4J7a8J9KPcwPvwcXquin)QpgUrymzpHpUdGcKYDg40zRS0iEcExAhStsQjOhMicJZsJ4PMGGy3WvelN(QxcYSSwAPvb]] )


end
