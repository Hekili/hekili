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

            indicator = function () return active_enemies > 1 and ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
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


    spec:RegisterPack( "Destruction", 20210831, [[dOKf2aqiqjpcuO2eOQprvfAuuL0POkXQOQs9kvjZcu5wuvj7ss)sPQHPuXXuLAzuv1ZKi10Ki5AGI2grP6BGczCuvrNduQSoqbzEuL6EQK9PuPdckOwOQOhsukmrIsPUiOaTrqPeFKOuuNeuawjvLzckL0ovk(jOaQLckG8urMQsPTsukYxjkLmwqPu2Ru)vudwfhg1Ib5XatwjxgzZe5ZsuJwL60cRgukvVMOKzd52QQDt53kgor1XPQcwoHNd10jDDjSDQIVlrmEqP48efRhuQA(Qc7Nk3V7TDAXk1B8Fh)FVJFw631DGDVLD)lvNuzKtDsodKfxM6KXFQtY2ewffangRtYzzqdV6TDcpfca1PBvLJHH2VVCO3fqvW83JJFbI1ymGGL0944d23jOIaPWaSgQtlwPEJ)74)7D8Zs)UUdS7TS)g21jUqVhrNsXx2Ot3XArwd1PfHbDs2MWQOaOXyUJSflqdqwoFWWfLlWQ7u63W5o(VJ)VD(C(KnUzRmHHHC(8l3b2cIW3ablP7Lnniwde5oPb5Hm1DaSbiuoKChWnBLPL7OJ7eMscrHCnhs1oHcSI7TDIWyYaeU32BE3B7ed0ySovYiqlpuyzbHhJna1jYyieT6NT2B8V32jgOXyD6t)ritEKYOcqSYlbXFCNiJHq0QF2AVP092oXangRtqOzw5rkR3uMm6ltNiJHq0QF2AVPu92oXangRtLlyXkylpszg2tIrV7ezmeIw9Zw7nWS32jgOXyDseYLJOCyzSCgqDImgcrR(zR9gzV32jgOXyDsAafyALzypjcLYqe)7ezmeIw9Zw7nWOEBNyGgJ1j5fIqsMWkNHqmw7ezmeIw9Zw7n(zVTtKXqiA1p7eqekjcUtklktA9MyKENLdu3zx3Xp3XDE8WDuwuM06nXi9olhOUJ3UJ)74opE4osr5BnlOphg2D82D8Fh35Xd3rzrzsRA8PSoz5an7)oUZUUtP2PtmqJX6KGy5HvolH4pHBT3a76TDIbAmwNaJbitfSsRSeI)uNiJHq0QF2AV59o92orgdHOv)StarOKi4obvijvfeqwicJZsJaqvb95WWDIbAmwN0BkxyqtHTYsJaqT2ANUzpdO32BE3B7ezmeIw9ZobeHsIG7euHKufIbYAjyjTUMsm3bE3bpfOm(Mfl3z3l35T7aV7GNcugFZIL749L7uQoXangRtGXKqCzbRuR9g)7TDImgcrR(zNaIqjrWDcWynRXNChVDNB2ZaYc6ZHH7ed0ySoHNcuwkeuR9Ms3B7ezmeIw9ZobeHsIG7eGXAwJp5oE7o3SNbKf0Ndd7oW7o4Pabf2QIiELHKjtWg(lhrvYyieT6ed0ySoTiq8znSYzObPT2BkvVTtKXqiA1p7eqekjcUtagRzn(K74T7CZEgqwqFomCNyGgJ1jmykeHvoRHEtT2BGzVTtKXqiA1p7eqekjcUtkJitRHPKWyugmFOcSgJvjJHq0YDG3De0Ndd7oE7oRcbRXyUJF7o7uHP784H7al3rzezAnmLegJYG5dvG1ySkzmeIwUd8UJGKee(MHquNyGgJ1P4)heRuR9gzV32jYyieT6NDcicLeb3jaJ1SgFYD82DUzpdilOphgUtmqJX6e4MhCgAqAR9gyuVTtmqJX6e(MxtjqfcRtKXqiA1pBT34N92orgdHOv)StarOKi4obySM14tUJ3UZn7zazb95WWDIbAmwNcdegjyLAT1ojxqG5dXAVT38U32jYyieT6NDIbAmwNKiuEn)WyngRtlcdeHCngRtWGWgcuO0YDGiPrqUdy(qS6oqu5WWv3bggai5k2DSX8RBw8LkqUdd0ymS7mgsMANaIqjrWDsJp5o76o74oW7oWYDKtALrHhQ1EJ)92oXangRt4I)FSC8L3jYyieT6NT2BkDVTtKXqiA1p7KXFQt68P8iL)JHvXuGZGXWQOaOXy4oXangRt68P8iL)JHvXuGZGXWQOaOXy4w7nLQ32jYyieT6NDY4p1j8Gi(gNXeqqAwjWTf(HcQtmqJX6eEqeFJZyciinRe42c)qb1AVbM92oXangRtsicFdeSK2jYyieT6NT2BK9EBNiJHq0QF2jGiuseCNugrMwllI)eckpszmdeHuaOkzmeIwDIbAmwNklI)eckpszmdeHuaOw7nWOEBNyGgJ1j8uGYsHG6ezmeIw9Zw7n(zVTtKXqiA1p7eqekjcUtWYDugrMwXtbklfcQsgdHOvNyGgJ1PWaHrcwPw7nWUEBNiJHq0QF2jJ)uNW38AkHw5raLhPSoIpzANyGgJ1j8nVMsOvEeq5rkRJ4tM2ARDIhQ32BE3B7ezmeIw9ZobeHsIG7KCsRHjrcJrvgOHhYDG3D8Q7al3bmdAnLy1B2ZaQcIxY4opE4omqdpuMm6he2D21DkT74LoXangRtcoS8iLLcb1AVX)EBNyGgJ1j8uGYIr7ezmeIw9Zw7nLU32jYyieT6NDcicLeb3P1O14)heRuvqFomS7SR7aySM14tDIbAmwNa3SzekVO)ysHGAT3uQEBNiJHq0QF2jgOXyDk()bXk1jGiuseCNe0Ndd7oE7oW0DG3D8Q7al3rzezAfWkdqYG)vYyieTCNhpChWmO1uIvbSYaKm4FvqFomS7SR7iOphg2D8sNaYaquwzrzsX9M3T2BGzVTtKXqiA1p7ed0ySobyekZanglJcS2juG1SXFQtGfU1EJS3B7ezmeIw9ZoXangRtagHYmqJXYOaRDcfynB8N6eHXKbiCR9gyuVTtKXqiA1p7ed0ySoDZEgqNaIqjrWDIbA4HYKr)GWUJ3UtP6eqgaIYklktkU38U1EJF2B7ed0ySoj4WYJuwkeuNiJHq0QF2AVb21B7ezmeIw9ZoXangRt3SNb0jGmaeLvwuMuCV5DR9M370B7ezmeIw9ZobeHsIG7KxDh8uGGcBvreVYqYKjyd)LJOkzmeIwUZJhUdSChLrKPvPqqz2wzir8X6yuLmgcrl3XlDIbAmwNwei(Sgw5m0G0w7nVF3B7ezmeIw9ZobeHsIG7KYiY0QuiOmBRmKi(yDmQsgdHOL7aV7avijvHyGSwcwsRfYDh4Dh8uGY4BwSChVDhy6o(L7St1F3XVDhgOHhktg9dc3jgOXyDkmqyKGvQ1EZB)7TDIbAmwNWtbklfcQtKXqiA1pBT38U092orgdHOv)StarOKi4obvijvHyGSwcwsRRPeRtmqJX6eymjexwWk1AV5DP6TDImgcrR(zNaIqjrWDszrzsR3eJ07QCG6oE7o(VtNyGgJ1j8nVMsGkewR9M3WS32jYyieT6NDcicLeb3jy5oE1DugrMwLcbLzBLHeXhRJrvYyieTCNhpChLrKP1WKiHnvYyieTChV0jgOXyDcdMcryLZAO3uR9M3YEVTtKXqiA1p7eqekjcUtWYD8Q7OmImTkfckZ2kdjIpwhJQKXqiA5opE4okJitRHjrcBQKXqiA5oEPtmqJX6u8Lt2kSYzaRmwfJ8BQ1EZByuVTtmqJX6uyGWibRuNiJHq0QF2ARDcSW92EZ7EBNyGgJ1jCX)pwomjsymQtKXqiA1pBT34FVTtmqJX60IfYkJNcuomSYqbkuz6ezmeIw9Zw7nLU32jYyieT6NDcicLeb3j5KwdtIegJQmqdpuNyGgJ1j5JgJ1AVPu92orgdHOv)StarOKi4ojN0AysKWyuLbA4H6ed0ySobrcmjKvyLBT3aZEBNiJHq0QF2jGiuseCNKtAnmjsymQYan8qDIbAmwNGqZSYsfczAT3i792orgdHOv)StarOKi4ojN0AysKWyuLbA4H6ed0ySojfcccnZQ1EdmQ32jYyieT6NDIbAmwNW38AkHw5raLhPSoIpzANaIqjrWDcmdAnLyvCX)pwomjsymQkOphg2D82DkT784H7anyS7aV7ifLV1SG(Cyy3XB3Pu(3jJ)uNW38AkHw5raLhPSoIpzAR9g)S32jYyieT6NDcicLeb3j5KwdtIegJQmqdpK784H7OSOmPvn(uwN8ki3XB3X)D6ed0ySovGPCO0h3ARDArsCbs7T9M392orgdHOv)StlcdeHCngRtWGWgcuO0YDipKqg3rJp5o6n5omqhH7ey3H9WbIHquTtmqJX6ewoHqz0aKvR9g)7TDImgcrR(zNaIqjrWD6M9mGmd0Wd5oW7omqdpuMm6he2D21DE7oW7omqdpuMm6he2D82DGP74xUJYiY0AysKWMkzmeIwUZl3XRUJYiY0AysKWMkzmeIwUd8UJYiY0AykjmgLbZhQaRXyvYyieTChV0jgOXyDcWiuMbAmwgfyTtOaRzJ)uNUzpdO1EtP7TDImgcrR(zNyGgJ1jjeHVbcws7eqekjcUt4Pabf2Q6zqSgikJhKhY0kzmeIwDkmLeIc5AoK6euHKu1ZGynqugpipKP1c5T2BkvVTtKXqiA1p7eqekjcUtkJitRIHfHvodHyypvjJHq0YDG3DweuHKuvmSiSYzied7PQG(Cyy3XB35DfMDIbAmwNaJjH4YcwPw7nWS32jYyieT6NDcicLeb3jy5oE1DKtAnmjsymQYan8qUd8UZA0A8)dIvQkOphg2DE5oVDNDDh5KwdtIegJQc6ZHHDhV4opE4oy5ecLvwuMuCfWkdqYG)UZUUZ7oXangRtawzasg8V1EJS3B7ezmeIw9ZobeHsIG7ed0WdLjJ(bHDNDDh)7ed0ySobyekZanglJcS2juG1SXFQt8qT2BGr92orgdHOv)StmqJX6eEkqzPqqDcicLeb3jbjji8ndHi3bE3bpfOm(Mfl3X7l3PuUd8UJxDhy5okJitRawzasg8VsgdHOL784H7aMbTMsSkGvgGKb)Rc6ZHHDNDDhb95WWUJx6eqgaIYklktkU38U1EJF2B7ezmeIw9ZoXangRtX)piwPobeHsIG7KGKee(MHqK7aV74v3bwUJYiY0kGvgGKb)RKXqiA5opE4oGzqRPeRcyLbizW)QG(Cyy3zx3rqFomS74LobKbGOSYIYKI7nVBT3a76TDImgcrR(zNaIqjrWDszezAnmLegJYG5dvG1ySkzmeIwUd8Udd0ySk4MhCgAqAnSSekkFRUd8UJG(Cyy3XB3zviyngZD8B3zNkm7ed0ySof))GyLAT38ENEBNiJHq0QF2jgOXyDcWiuMbAmwgfyTtOaRzJ)uNalCR9M3V7TDImgcrR(zNyGgJ1jaJqzgOXyzuG1oHcSMn(tDIWyYaeU1EZB)7TDIbAmwNa3SzekVO)ysHG6ezmeIw9Zw7nVlDVTtmqJX6egmfIWkN1qVPorgdHOv)S1EZ7s1B7ed0ySoTiq8znSYzObPDImgcrR(zR9M3WS32jYyieT6NDIbAmwNUzpdOtarOKi4oTgTg))GyLQc6ZHHDNDDN1O14)heRuDviyngZD8B3zNkmDNhpChy5okJitRHPKWyugmFOcSgJvjJHq0QtazaikRSOmP4EZ7w7nVL9EBNyGgJ1P4lNSvyLZawzSkg53uNiJHq0QF2AV5nmQ32jgOXyDcpfOSy0orgdHOv)S1EZB)S32jYyieT6NDcicLeb3jrHrsJOmvNLiJV5sq5rkR3uwMFiGTZIk5hkc5YPvNyGgJ1PB2ZaAT38g21B7ezmeIw9ZonY7eM0oXangRtEyrWqiQtEyub1jgOHhktg9dc7o76oVDh4DhWmO1uIvVzpdOkOphg2D8(YDEVJ784H7aMbTMsSkU4)hlhMejmgvf0Ndd7oEF5oVHP7aV7OmImTUyHSY4PaLddRmuGcvMkzmeIwUd8Udyg0AkXQlwiRmEkq5WWkdfOqLPkOphg2D8(YDEdt35Xd3rzezADXczLXtbkhgwzOafQmvYyieTCh4DhWmO1uIvxSqwz8uGYHHvgkqHktvqFomS749L78gMUd8UJxDhWmO1uIvXf))y5WKiHXOQG(Cyy3zx3rzrzsRA8PSo5vqUZJhUdyg0AkXQ4I)FSCysKWyuvqFomS78YDaZGwtjwfx8)JLdtIegJQRcbRXyUZUUJYIYKw14tzDYRGChV0jpSiB8N6K8zqz8uGY4BwSWT2B8FNEBNiJHq0QF2jGiuseCNGkKKQqmqwlblP11uI5oW7o4PaLX3Sy5o7E5oVRW0D8l3zNAPDh)2DugrMwLqm(E8qIkzmeIwUd8UdSChpSiyievLpdkJNcugFZIfUtmqJX6eymjexwWk1AVX)392orgdHOv)StarOKi4obvijvxSqwz8uGYHHvgkqHktTqENyGgJ1jWnp4m0G0w7n(7FVTtKXqiA1p7eqekjcUtqfssvigiRLGL0AHC3bE3bwUJhwemeIQYNbLXtbkJVzXc7oW7oWYDugrMwjbVcaRXyvYyieT6ed0ySobU5bNHgK2AVX)s3B7ezmeIw9ZobeHsIG7eSChpSiyievLpdkJNcugFZIf2DG3DugrMwjbVcaRXyvYyieTCh4DhV6olcQqsQscEfawJXQc6ZHHDhVDhaJ1SgFYDE8WDGkKKQqmqwlblP1c5UJx6ed0ySobU5bNHgK2AVX)s1B7ezmeIw9ZobeHsIG7eSChpSiyievLpdkJNcugFZIf2DE8WDWtbkJVzXYD29YDkvfMDIbAmwNW38AkbQqyT2B8hM92orgdHOv)StarOKi4o5v3bpfOm(Mfl3z3l3Puvy6o(L7St1F3XVDhgOHhktg9dc7oEPtmqJX6e4MhCgAqAR9g)L9EBNiJHq0QF2jGiuseCNa3SOmHDNDDN3DIbAmwNaJjH4YcwPw7n(dJ6TDIbAmwNcdegjyL6ezmeIw9ZwBT1o5He4ySEJ)74)7D8t)lDNkHfwyLXDs2cgggOnWa2iBggYDCNT3K7eF5JqDhPr4o(XfjXfi1p6ocYpuecA5o45tUdxOZNvA5oGB2kt4QZhS1Wi3P0WqUJSXyEiHsl3XpINceuyRkSn)O7OJ74hXtbckSvf2wLmgcrl)O7WQ7adcdmSv3XRVHnEP6858bd4lFekTChz3DyGgJ5oOaR4QZxNKlgParDcgdJDhzBcRIcGgJ5oYwSanaz58bJHXUdmCr5cS6oL(nCUJ)74)BNpNpymm2DKnUzRmHHHC(GXWy3XVChylicFdeSKUx20GynqK7KgKhYu3bWgGq5qYDa3SvMwUJoUtykjefY1CivD(C(GXUdmiSHafkTChisAeK7aMpeRUdevomC1DGHbasUIDhBm)6MfFPcK7Wangd7oJHKP68XangdxLliW8Hy9sIq518dJ1ym4cPln(0U7apSKtALrHhY5JbAmgUkxqG5dX6RR94I)FSSCsD(yGgJHRYfey(qS(6AFbMYHsF4m(tx68P8iL)JHvXuGZGXWQOaOXyyNpgOXy4QCbbMpeRVU2xGPCO0hoJ)0fEqeFJZyciinRe42c)qb58XangdxLliW8Hy911EjeHVbcwsD(yGgJHRYfey(qS(6AFzr8Nqq5rkJzGiKcabxiDPmImTwwe)jeuEKYygicPaqvYyieTC(yGgJHRYfey(qS(6ApEkqzPqqoFmqJXWv5ccmFiwFDTpmqyKGvcUq6cwkJitR4PaLLcbvjJHq0Y5JbAmgUkxqG5dX6RR9fykhk9HZ4pDHV51ucTYJakpszDeFYuNpNpyS7adcBiqHsl3H8qczChn(K7O3K7WaDeUtGDh2dhigcrvNpgOXy4lSCcHYObilNpgOXy4laJqzgOXyzuGv4m(tx3SNbaxiDDZEgqMbA4HGNbA4HYKr)GW7(gEgOHhktg9dc7nm9lLrKP1WKiHnvYyieTE5vLrKP1WKiHnvYyieTGxzezAnmLegJYG5dvG1ySkzmeIwEX5JbAmg(11EjeHVbcwsHlKUWtbckSv1ZGynqugpipKPWfMscrHCnhsxqfssvpdI1arz8G8qMwlK78Xangd)6ApymjexwWkbxiDPmImTkgwew5meIH9uLmgcrl4xeuHKuvmSiSYzied7PQG(CyyVFxHPZhd0ym8RR9awzasg8hUq6cwEvoP1WKiHXOkd0Wdb)A0A8)dIvQkOphg(17DLtAnmjsymQkOphg2lpEGLtiuwzrzsXvaRmajd(V7BNpgOXy4xx7bmcLzGgJLrbwHZ4pDXdbxiDXan8qzYOFq4D935JbAmg(11E8uGYsHGGdidarzLfLjfF9gUq6sqsccFZqicE8uGY4BwS8(QuW7vyPmImTcyLbizW)kzmeIwpEaMbTMsSkGvgGKb)Rc6ZHH3vqFomSxC(yGgJHFDTp()bXkbhqgaIYklktk(6nCH0LGKee(MHqe8EfwkJitRawzasg8VsgdHO1JhGzqRPeRcyLbizW)QG(Cy4Df0Ndd7fNpgOXy4xx7J)FqSsWfsxkJitRHPKWyugmFOcSgJvjJHq0cEgOXyvWnp4m0G0Ayzjuu(wHxqFomS3RcbRXy(9ovy68Xangd)6ApGrOmd0ySmkWkCg)PlWc78Xangd)6ApGrOmd0ySmkWkCg)PlcJjdqyNpgOXy4xx7b3SzekVO)ysHGC(yGgJHFDThdMcryLZAO3KZhd0ym8RR9lceFwdRCgAqQZhd0ym8RR93SNbahqgaIYklktk(6nCH01A0A8)dIvQkOphgE31O14)heRuDviyngZV3PcZhpGLYiY0AykjmgLbZhQaRXyvYyieTC(yGgJHFDTp(YjBfw5mGvgRIr(n58Xangd)6ApEkqzXOoFmqJXWVU2FZEgaCH0LOWiPruMQZsKX3CjO8iL1BklZpeW2zrL8dfHC50Y5JbAmg(11EpSiyiebNXF6s(mOmEkqz8nlwy48WOc6IbA4HYKr)GW7(gEWmO1uIvVzpdOkOphg27R3784byg0AkXQ4I)FSCysKWyuvqFomS3xVHj8kJitRlwiRmEkq5WWkdfOqLPsgdHOf8GzqRPeRUyHSY4PaLddRmuGcvMQG(CyyVVEdZhpugrMwxSqwz8uGYHHvgkqHktLmgcrl4bZGwtjwDXczLXtbkhgwzOafQmvb95WWEF9gMW7vWmO1uIvXf))y5WKiHXOQG(Cy4DvwuM0QgFkRtEf0JhGzqRPeRIl()XYHjrcJrvb95WWVaZGwtjwfx8)JLdtIegJQRcbRXy7QSOmPvn(uwN8kiV48Xangd)6ApymjexwWkbxiDbvijvHyGSwcwsRRPedE8uGY4BwS296DfM(1o1s73kJitRsigFpEirLmgcrl4HLhwemeIQYNbLXtbkJVzXc78Xangd)6Ap4MhCgAqkCH0fuHKuDXczLXtbkhgwzOafQm1c5oFmqJXWVU2dU5bNHgKcxiDbvijvHyGSwcwsRfYHhwEyrWqiQkFgugpfOm(Mflm8WszezALe8kaSgJvjJHq0Y5JbAmg(11EWnp4m0Gu4cPly5HfbdHOQ8zqz8uGY4BwSWWRmImTscEfawJXQKXqiAbVxxeuHKuLe8kaSgJvf0Ndd7nGXAwJp94buHKufIbYAjyjTwi3loFmqJXWVU2JV51ucuHWGlKUGLhwemeIQYNbLXtbkJVzXc)4bEkqz8nlw7EvQkmD(yGgJHFDThCZdodnifUq6YR4PaLX3SyT7vPQW0V2P6VFZan8qzYOFqyV48Xangd)6ApymjexwWkbxiDbUzrzcV7BNpgOXy4xx7ddegjyLC(C(yGgJHR8qxcoS8iLLcbbxiDjN0AysKWyuLbA4HG3RWcmdAnLy1B2ZaQcIxY84bd0WdLjJ(bH3T0EX5JbAmgUYd96ApEkqzXOoFmqJXWvEOxx7b3SzekVO)ysHGGlKUwJwJ)FqSsvb95WW7cySM14toFmqJXWvEOxx7J)FqSsWbKbGOSYIYKIVEdxiDjOphg2BycVxHLYiY0kGvgGKb)RKXqiA94byg0AkXQawzasg8VkOphgExb95WWEX5JbAmgUYd96ApGrOmd0ySmkWkCg)PlWc78Xangdx5HEDThWiuMbAmwgfyfoJ)0fHXKbiSZhd0ymCLh611(B2ZaGdidarzLfLjfF9gUq6IbA4HYKr)GWExkNpgOXy4kp0RR9coS8iLLcb58Xangdx5HEDT)M9ma4aYaquwzrzsXxVD(yGgJHR8qVU2Viq8znSYzObPWfsxEfpfiOWwveXRmKmzc2WF5iQsgdHO1JhWszezAvkeuMTvgseFSogvjJHq0YloFmqJXWvEOxx7ddegjyLGlKUugrMwLcbLzBLHeXhRJrvYyieTGhQqsQcXazTeSKwlKdpEkqz8nlwEdt)ANQ)(nd0WdLjJ(bHD(yGgJHR8qVU2JNcuwkeKZhd0ymCLh611EWysiUSGvcUq6cQqsQcXazTeSKwxtjMZhd0ymCLh611E8nVMsGkegCH0LYIYKwVjgP3v5a1B)3X5JbAmgUYd96ApgmfIWkN1qVj4cPly5vLrKPvPqqz2wzir8X6yuLmgcrRhpugrMwdtIe2ujJHq0YloFmqJXWvEOxx7JVCYwHvodyLXQyKFtWfsxWYRkJitRsHGYSTYqI4J1XOkzmeIwpEOmImTgMejSPsgdHOLxC(yGgJHR8qVU2hgimsWk5858Xangdxbl8fU4)hlhMejmg58Xangdxbl8RR9lwiRmEkq5WWkdfOqLX5JbAmgUcw4xx7LpAmgCH0LCsRHjrcJrvgOHhY5JbAmgUcw4xx7HibMeYkSYWfsxYjTgMejmgvzGgEiNpgOXy4kyHFDThcnZklviKbUq6soP1WKiHXOkd0Wd58Xangdxbl8RR9sHGGqZSGlKUKtAnmjsymQYan8qoFmqJXWvWc)6AFbMYHsF4m(tx4BEnLqR8iGYJuwhXNmfUq6cmdAnLyvCX)pwomjsymQkOphg27s)4b0GXWlfLV1SG(CyyVlL)oFmqJXWvWc)6AFbMYHsFmCH0LCsRHjrcJrvgOHh6XdLfLjTQXNY6Kxb5T)74858XangdxVzpd4cmMeIllyLGlKUGkKKQqmqwlblP11uIbpEkqz8nlw7E9gE8uGY4BwS8(QuoFmqJXW1B2ZaEDThpfOSuii4cPlaJ1SgFY7B2ZaYc6ZHHD(yGgJHR3SNb86A)IaXN1WkNHgKcxiDbySM14tEFZEgqwqFomm84Pabf2QIiELHKjtWg(lhrvYyieTC(yGgJHR3SNb86ApgmfIWkN1qVj4cPlaJ1SgFY7B2ZaYc6ZHHD(yGgJHR3SNb86AF8)dIvcUq6szezAnmLegJYG5dvG1ySkzmeIwWlOphg27vHG1ym)ENkmF8awkJitRHPKWyugmFOcSgJvjJHq0cEbjji8ndHiNpgOXy46n7zaVU2dU5bNHgKcxiDbySM14tEFZEgqwqFomSZhd0ymC9M9mGxx7X38AkbQqyoFmqJXW1B2ZaEDTpmqyKGvcUq6cWynRXN8(M9mGSG(CyyNpNpgOXy4kHXKbi8RR9Lmc0Ydfwwq4XydqoFmqJXWvcJjdq4xx7)0FeYKhPmQaeR8sq8h78XangdxjmMmaHFDThcnZkpsz9MYKrFzC(yGgJHRegtgGWVU2xUGfRGT8iLzypjg925JbAmgUsymzac)6AViKlhr5WYy5mGC(yGgJHRegtgGWVU2lnGcmTYmSNeHsziI)oFmqJXWvcJjdq4xx7LxicjzcRCgcXy15JbAmgUsymzac)6AVGy5HvolH4pHHlKUuwuM06nXi9olhO76N784HYIYKwVjgP3z5a1B)35XdPO8TMf0Ndd7T)784HYIYKw14tzDYYbA2)D2Tu748XangdxjmMmaHFDThmgGmvWkTYsi(toFmqJXWvcJjdq4xx71BkxyqtHTYsJaqWfsxqfssvbbKfIW4S0iauvqFomCNWYjqVXFzhg1ARDd]] )


end
