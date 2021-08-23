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


    spec:RegisterPack( "Destruction", 20210823, [[dOuI1aqiijpsLIAtqQ(Kefzuus6uusSkjk8kvPMfKYTOus7ss)sLQHjr1XGelJsXZKO00OuQRPsPTPsbFJsjghrPCovkI1PsHAEusDpvY(uQ0bvPiTqvjpKOKYejkvCrvkKnsuI4JeLu1jjkvALuQMjrjk7uP4Nsuu1sLOOYtfzQkL2krjsFvIIYyjkr1EL6VIAWQ4WOwmepgyYk5YiBMiFwImAvXPfwnrjvEnKuZg0Tvv7MQFRy4evhNOu1Yj8COMoPRlHTtj(UsfJNOeoprX6jkjZxPQ9tXnk92oTyL6n2uUnOuUSztzRLlBL92BrPtQmYPojNbOMlrDY5p1jzhcRIcGgJ3j5SmWHx92oHNcbG60JQYX3473lf6tbsfm)744xaznghiyj9oo(G7DcPiGQSR3iDAXk1BSPCBqPCzZMYwlx2k7T2(M0jUqFgrNsXxwRtpXArEJ0PfHbDs2HWQOaOX4MtzglGda1g730Isfy1CSPSOzo2uUnOySBSlR9WEjcFJn2TvZrwcKWpablP3LLoqwdizoPbAHC1CaSdiyoKmhWd7LOL5OJ5eUscrHCnhs1obdSI7TDIWyYbeU32BqP32jgOX4DANraxwOWZccpo7aQtKZiqA1VAT3ytVTtmqJX70N(JqM8iLHfGyLxcI)4oroJaPv)Q1Etz7TDIbAmENqGZSYJuwFOm50xMoroJaPv)Q1EJT7TDIbAmENkvWIvWEEKYSSIeJ(0jYzeiT6xT2BUT32jgOX4DseYLdPC4zSCgqDICgbsR(vR9MBO32jgOX4DsAafyALzzfjcLYie)7e5mcKw9Rw7n2sVTtmqJX7K8crijt4LYiqgRDICgbsR(vR9gzR32jYzeiT6xDcicLeb3jLfLiT(qmuFYYbQ5SR5iBLBo73BoklkrA9HyO(KLduZXAZXMYnN97nhPO0JMf0NdhBowBo2uU5SFV5OSOePvn(uwNSCGMTPCZzxZX2L3jgOX4DsqS8WlLLG8NWT2BUj92oXangVtGXbKRcwPvwcYFQtKZiqA1VAT3Gs592oroJaPv)QtarOKi4oHuijvfea1qcJZsJaqvb95WXDIbAmEN0hkx4itHVYsJaqT2ANEyldO32BqP32jYzeiT6xDcicLeb3jKcjPkcdq9sWsADn74Md6MdEkGz8dlwMZUxMdkMd6MdEkGz8dlwMJ1xMJT7ed0y8obgxcYLeSsT2BSP32jYzeiT6xDcicLeb3jaJ1SgFYCS2CEyldilOphoUtmqJX7eEkGzPqqT2BkBVTtKZiqA1V6eqekjcUtagRzn(K5yT58WwgqwqFoCS5GU5GNcis4RkK4vgrMmjl4VCivjNrG0QtmqJX70IaXN1WlLrgO2AVX292oroJaPv)QtarOKi4obySM14tMJ1MZdBzazb95WXDIbAmENWGPqeEPSg6d1AV52EBNiNrG0QF1jGiuseCNugsUwdxjHZWmy(ifyngVsoJaPL5GU5iOpho2CS2CwfcwJXnNYWCkVER5SFV5GkZrzi5AnCLeodZG5JuG1y8k5mcKwMd6MJGKee(HrGuNyGgJ3P4)hiRuR9MBO32jYzeiT6xDcicLeb3jaJ1SgFYCS2CEyldilOphoUtmqJX7e4HhCgzGAR9gBP32jgOX4Dc)WRzhKcH3jYzeiT6xT2BKTEBNiNrG0QF1jGiuseCNamwZA8jZXAZ5HTmGSG(C44oXangVtHdcNeSsT2ANKliW8ryT32BqP32jYzeiT6xDIbAmENKiyEn)WzngVtlcdeHCngVt3izbbkuAzoiK0iiZbmFewnheQu44Q5CtbasUInhFCB9HfFPcO5WanghBoJdLP2jGiuseCN04tMZUMt5Md6MdQmh5KwzyyHAT3ytVTtmqJX7eU4)hphF5DICgbsR(vR9MY2B7e5mcKw9Ro58N6KoFkps5)4yvmf4myCSkkaAmoUtmqJX7KoFkps5)4yvmf4myCSkkaAmoU1EJT7TDICgbsR(vNC(tDcpqIFWzmbeKMvc84HSVG6ed0y8oHhiXp4mMacsZkbE8q2xqT2BUT32jgOX4Dscs4hGGL0oroJaPv)Q1EZn0B7e5mcKw9RobeHsIG7KYqY1Ajr8Nqq5rkJzGiKcavjNrG0QtmqJX7ujr8Nqq5rkJzGiKca1AVXw6TDIbAmENWtbmlfcQtKZiqA1VAT3iB92oroJaPv)QtarOKi4oHkZrzi5AfpfWSuiOk5mcKwDIbAmENcheojyLAT1oXd1B7nO0B7e5mcKw9RobeHsIG7KCsRHlrcNHvgOHfYCq3CSQ5GkZbmdCn741h2YaQcIxYyo73BomqdluMC6he2C21CkR5yLoXangVtco88iLLcb1AVXMEBNyGgJ3j8uaZIr7e5mcKw9Rw7nLT32jYzeiT6xDcicLeb3P1O14)hiRuvqFoCS5SR5aySM14tDIbAmENapS7emVO)4sHGAT3y7EBNiNrG0QF1jgOX4Dk()bYk1jGiuseCNe0NdhBowBo3AoOBow1CqL5OmKCTcyLbqzW)k5mcKwMZ(9Mdyg4A2XRawzaug8VkOpho2C21Ce0NdhBowPtazaqkRSOeP4EdkT2BUT32jYzeiT6xDIbAmENameMzGgJNHbw7emWA25p1jWc3AV5g6TDICgbsR(vNyGgJ3jadHzgOX4zyG1obdSMD(tDIWyYbeU1EJT0B7e5mcKw9RoXangVtpSLb0jGiuseCNyGgwOm50piS5yT5y7obKbaPSYIsKI7nO0AVr26TDIbAmENeC45rklfcQtKZiqA1VAT3Ct6TDICgbsR(vNyGgJ3Ph2Ya6eqgaKYklkrkU3GsR9gukV32jYzeiT6xDcicLeb3jRAo4PaIe(QcjELrKjtYc(lhsvYzeiTmN97nhuzokdjxRsHGYSVYiI4J1XPk5mcKwMJv6ed0y8oTiq8zn8szKbQT2BqbLEBNiNrG0QF1jGiuseCNugsUwLcbLzFLreXhRJtvYzeiTmh0nhKcjPkcdq9sWsATqU5GU5GNcyg)WIL5yT5CR5yRMt5vBmNYWCyGgwOm50piCNyGgJ3PWbHtcwPw7nOytVTtmqJX7eEkGzPqqDICgbsR(vR9gukBVTtKZiqA1V6eqekjcUtifssvegG6LGL06A2X7ed0y8obgxcYLeSsT2BqX292oroJaPv)QtarOKi4oPSOeP1hIH6tvoqnhRnhBkVtmqJX7e(HxZoifcV1Edk32B7e5mcKw9RobeHsIG7eQmhRAokdjxRsHGYSVYiI4J1XPk5mcKwMZ(9MJYqY1A4sKWNk5mcKwMJv6ed0y8oHbtHi8szn0hQ1Edk3qVTtKZiqA1V6eqekjcUtOYCSQ5OmKCTkfckZ(kJiIpwhNQKZiqAzo73BokdjxRHlrcFQKZiqAzowPtmqJX7u8Lt(k8szaRmwfJ8hQ1Edk2sVTtmqJX7u4GWjbRuNiNrG0QF1ARDcSW92Edk92oXangVt4I)F8C4sKWzyNiNrG0QF1AVXMEBNyGgJ3PflqDgpfWC4yLrcyOY0jYzeiT6xT2BkBVTtKZiqA1V6eqekjcUtYjTgUejCgwzGgwOoXangVtYhngV1EJT7TDICgbsR(vNaIqjrWDsoP1WLiHZWkd0Wc1jgOX4DcHeysG6Wl1AV52EBNiNrG0QF1jGiuseCNKtAnCjs4mSYanSqDIbAmENqGZSYsfczAT3Cd92oroJaPv)QtarOKi4ojN0A4sKWzyLbAyH6ed0y8ojfccboZQ1EJT0B7e5mcKw9RoXangVt4hEn7qR8iqYJuwhXNCTtarOKi4obMbUMD8kU4)hphUejCgwf0NdhBowBoL1C2V3Cqgm2Cq3CKIspAwqFoCS5yT5yBB6KZFQt4hEn7qR8iqYJuwhXNCT1EJS1B7e5mcKw9RobeHsIG7KCsRHlrcNHvgOHfYC2V3CuwuI0QgFkRtEfK5yT5yt5DIbAmENkWuou6JBT1oTijUaQ92Edk92oroJaPv)QtlcdeHCngVt3izbbkuAzoKfsiJ5OXNmh9HmhgOJWCcS5Ww4aYiqQ2jgOX4DclNGWmCaOU1EJn92oroJaPv)QtarOKi4o9WwgqMbAyHmh0nhgOHfkto9dcBo7AoOyoOBomqdluMC6he2CS2CU1CSvZrzi5AnCjs4tLCgbslZ5T5yvZrzi5AnCjs4tLCgbslZbDZrzi5AnCLeodZG5JuG1y8k5mcKwMJv6ed0y8obyimZangpddS2jyG1SZFQtpSLb0AVPS92oroJaPv)QtmqJX7KeKWpablPDcicLeb3j8uarcFvTmqwdiLXd0c5ALCgbsRofUscrHCnhsDcPqsQAzGSgqkJhOfY1AH8w7n2U32jYzeiT6xDcicLeb3jLHKRvXWIWlLrGSSIQKZiqAzoOBolcPqsQkgweEPmcKLvuvqFoCS5yT5Gs92oXangVtGXLGCjbRuR9MB7TDICgbsR(vNaIqjrWDcvMJvnh5KwdxIeodRmqdlK5GU5SgTg))azLQc6ZHJnN3MdkMZUMJCsRHlrcNHvb95WXMJvmN97nhSCccZklkrkUcyLbqzWFZzxZbLoXangVtawzaug8V1EZn0B7e5mcKw9RobeHsIG7ed0WcLjN(bHnNDnhB6ed0y8obyimZangpddS2jyG1SZFQt8qT2BSLEBNiNrG0QF1jgOX4DcpfWSuiOobeHsIG7KGKee(HrGK5GU5GNcyg)WIL5y9L5yBZbDZXQMdQmhLHKRvaRmakd(xjNrG0YC2V3CaZaxZoEfWkdGYG)vb95WXMZUMJG(C4yZXkDcidaszLfLif3BqP1EJS1B7e5mcKw9RoXangVtX)pqwPobeHsIG7KGKee(HrGK5GU5yvZbvMJYqY1kGvgaLb)RKZiqAzo73BoGzGRzhVcyLbqzW)QG(C4yZzxZrqFoCS5yLobKbaPSYIsKI7nO0AV5M0B7e5mcKw9RobeHsIG7KYqY1A4kjCgMbZhPaRX4vYzeiTmh0nhgOX4vWdp4mYa1A4zjyu6rnh0nhb95WXMJ1MZQqWAmU5ugMt51B7ed0y8of))azLAT3Gs592oroJaPv)QtmqJX7eGHWmd0y8mmWANGbwZo)Pobw4w7nOGsVTtKZiqA1V6ed0y8obyimZangpddS2jyG1SZFQtegtoGWT2BqXMEBNyGgJ3jWd7obZl6pUuiOoroJaPv)Q1EdkLT32jgOX4DcdMcr4LYAOpuNiNrG0QF1AVbfB3B7ed0y8oTiq8zn8szKbQDICgbsR(vR9guUT32jYzeiT6xDIbAmENEyldOtarOKi4oTgTg))azLQc6ZHJnNDnN1O14)hiRuDviyng3CkdZP86TMZ(9MdQmhLHKR1Wvs4mmdMpsbwJXRKZiqA1jGmaiLvwuIuCVbLw7nOCd92oXangVtXxo5RWlLbSYyvmYFOoroJaPv)Q1Edk2sVTtmqJX7eEkGzXODICgbsR(vR9guKTEBNiNrG0QF1jGiuseCNefojnIsuDwIm(H3bMhPS(qzz(HqwhlQKSViKlNwDIbAmENEyldO1Edk3KEBNiNrG0QF1PrENWK2jgOX4DYclcgbsDYcdlOoXanSqzYPFqyZzxZbfZbDZbmdCn741h2YaQc6ZHJnhRVmhuk3C2V3CaZaxZoEfx8)JNdxIeodRc6ZHJnhRVmhuU1Cq3CugsUwxSa1z8uaZHJvgjGHktLCgbslZbDZbmdCn741flqDgpfWC4yLrcyOYuf0NdhBowFzoOCR5SFV5OmKCTUybQZ4PaMdhRmsadvMk5mcKwMd6Mdyg4A2XRlwG6mEkG5WXkJeWqLPkOpho2CS(YCq5wZbDZXQMdyg4A2XR4I)F8C4sKWzyvqFoCS5SR5OSOePvn(uwN8kiZz)EZbmdCn74vCX)pEoCjs4mSkOpho2CEBoGzGRzhVIl()XZHlrcNH1vHG1yCZzxZrzrjsRA8PSo5vqMJv6KfwKD(tDs(mWmEkGz8dlw4w7n2uEVTtKZiqA1V6eqekjcUtifssvegG6LGL06A2Xnh0nh8uaZ4hwSmNDVmhuQ3Ao2Q5uETSMtzyokdjxRsqg)mwirLCgbslZbDZbvMJfwemcKQYNbMXtbmJFyXc3jgOX4DcmUeKljyLAT3ydk92oroJaPv)QtarOKi4oHuijvxSa1z8uaZHJvgjGHktTqENyGgJ3jWdp4mYa1w7n2ytVTtKZiqA1V6eqekjcUtifssvegG6LGL0AHCZbDZbvMJfwemcKQYNbMXtbmJFyXcBoOBoOYCugsUwjbVcaRX4vYzeiT6ed0y8obE4bNrgO2AVXMY2B7e5mcKw9RobeHsIG7eQmhlSiyeivLpdmJNcyg)WIf2Cq3CugsUwjbVcaRX4vYzeiTmh0nhRAolcPqsQscEfawJXRc6ZHJnhRnhaJ1SgFYC2V3CqkKKQima1lblP1c5MJv6ed0y8obE4bNrgO2AVXgB3B7e5mcKw9RobeHsIG7eQmhlSiyeivLpdmJNcyg)WIf2C2V3CWtbmJFyXYC29YCSD92oXangVt4hEn7Gui8w7n2CBVTtKZiqA1V6eqekjcUtw1CWtbmJFyXYC29YCSD9wZXwnNYR2yoLH5WanSqzYPFqyZXkDIbAmENap8GZiduBT3yZn0B7e5mcKw9RobeHsIG7e4HfLiS5SR5GsNyGgJ3jW4sqUKGvQ1EJn2sVTtmqJX7u4GWjbRuNiNrG0QF1ART2jlKahJ3BSPCBqPCBPCBPt7Wcp8s4ovMDtlZTr2DJS(BS5yoBFiZj(YhHAosJWCktlsIlGAzYCeKSVie0YCWZNmhUqNpR0YCapSxIWvJDzzHtMtzVXMJS24wiHslZPmHNcis4RQS8YK5OJ5uMWtbej8vvwELCgbsRYK5WQ5CJkZllZCSkkYcRun2n2LD)YhHslZ5gmhgOX4MdmWkUAS3j5IrkGuNU5B2CKDiSkkaAmU5uMXc4aqTX(nFZMZnTOubwnhBklAMJnLBdkg7g738nBoYApSxIW3yJ9B(MnhB1CKLaj8dqWs6DzPdK1asMtAGwixnha7acMdjZb8WEjAzo6yoHRKquixZHu1y3y)MnNBKSGafkTmhesAeK5aMpcRMdcvkCC1CUPaajxXMJpUT(WIVub0CyGgJJnNXHYun2zGgJJRYfey(iSEjrW8A(HZAmoAH0LgFA3YrhvYjTYWWczSZanghxLliW8ry991DCX)pEwoPg7mqJXXv5ccmFewFFDVat5qPpAo)PlD(uEKY)XXQykWzW4yvua0yCSXod0yCCvUGaZhH13x3lWuou6JMZF6cpqIFWzmbeKMvc84HSVGm2zGgJJRYfey(iS((6UeKWpablPg7mqJXXv5ccmFewFFDVKi(tiO8iLXmqesbGqlKUugsUwljI)eckpszmdeHuaOk5mcKwg7mqJXXv5ccmFewFFDhpfWSuiiJDgOX44QCbbMpcRVVUhoiCsWkHwiDHkLHKRv8uaZsHGQKZiqAzSBSFZMZnswqGcLwMdzHeYyoA8jZrFiZHb6imNaBoSfoGmcKQg7mqJXXxy5eeMHda1g7mqJXXxagcZmqJXZWaRO58NUEyldaTq66HTmGmd0WcHod0WcLjN(bH3ff0zGgwOm50piS13ARkdjxRHlrcFQKZiqA92QkdjxRHlrcFQKZiqAHUYqY1A4kjCgMbZhPaRX4vYzeiTSIXod0yC87R7sqc)aeSKIwiDHNcis4RQLbYAaPmEGwixrlCLeIc5AoKUqkKKQwgiRbKY4bAHCTwi3yNbAmo(91DW4sqUKGvcTq6szi5AvmSi8szeilROk5mcKwOViKcjPQyyr4LYiqwwrvb95WXwJs9wJDgOX443x3bSYaOm4pAH0fQSQCsRHlrcNHvgOHfc91O14)hiRuvqFoC8Bu2voP1WLiHZWQG(C4yRSFpwobHzLfLifxbSYaOm4)UOySZangh)(6oGHWmd0y8mmWkAo)PlEi0cPlgOHfkto9dcVRng7mqJXXVVUJNcywkeeAazaqkRSOeP4luqlKUeKKGWpmcKqhpfWm(HflRVSn6wfvkdjxRawzaug8VsoJaP1(9GzGRzhVcyLbqzW)QG(C44Df0NdhBfJDgOX443x3J)FGSsObKbaPSYIsKIVqbTq6sqscc)WiqcDRIkLHKRvaRmakd(xjNrG0A)EWmW1SJxbSYaOm4FvqFoC8Uc6ZHJTIXod0yC87R7X)pqwj0cPlLHKR1Wvs4mmdMpsbwJXRKZiqAHod0y8k4HhCgzGAn8Semk9OOlOpho26vHG1y8YO86Tg7mqJXXVVUdyimZangpddSIMZF6cSWg7mqJXXVVUdyimZangpddSIMZF6IWyYbe2yNbAmo(91DWd7obZl6pUuiiJDgOX443x3XGPqeEPSg6dzSZangh)(6(IaXN1WlLrgOASZangh)(6(dBzaObKbaPSYIsKIVqbTq6AnAn()bYkvf0NdhV7A0A8)dKvQUkeSgJxgLxVD)EuPmKCTgUscNHzW8rkWAmELCgbslJDgOX443x3JVCYxHxkdyLXQyK)qg7mqJXXVVUJNcywmQXod0yC87R7pSLbGwiDjkCsAeLO6Sez8dVdmpsz9HYY8dHSowujzFrixoTm2zGgJJFFD3clcgbsO58NUKpdmJNcyg)WIfgnlmSGUyGgwOm50pi8UOGoyg4A2XRpSLbuf0NdhB9fkLVFpyg4A2XR4I)F8C4sKWzyvqFoCS1xOCl6kdjxRlwG6mEkG5WXkJeWqLPsoJaPf6GzGRzhVUybQZ4PaMdhRmsadvMQG(C4yRVq5297vgsUwxSa1z8uaZHJvgjGHktLCgbsl0bZaxZoEDXcuNXtbmhowzKagQmvb95WXwFHYTOBvWmW1SJxXf))45WLiHZWQG(C44DvwuI0QgFkRtEf0(9GzGRzhVIl()XZHlrcNHvb95WXVbZaxZoEfx8)JNdxIeodRRcbRX47QSOePvn(uwN8kiRySZangh)(6oyCjixsWkHwiDHuijvryaQxcwsRRzhhD8uaZ4hwS29cL6T2A51YwgkdjxRsqg)mwirLCgbsl0rLfwemcKQYNbMXtbmJFyXcBSZangh)(6o4HhCgzGkAH0fsHKuDXcuNXtbmhowzKagQm1c5g7mqJXXVVUdE4bNrgOIwiDHuijvryaQxcwsRfYrhvwyrWiqQkFgygpfWm(Hflm6Oszi5ALe8kaSgJxjNrG0YyNbAmo(91DWdp4mYav0cPluzHfbJaPQ8zGz8uaZ4hwSWORmKCTscEfawJXRKZiqAHUvxesHKuLe8kaSgJxf0NdhBnGXAwJpTFpsHKufHbOEjyjTwi3kg7mqJXXVVUJF41SdsHWrlKUqLfwemcKQYNbMXtbmJFyXcVFpEkGz8dlw7Ez76Tg7mqJXXVVUdE4bNrgOIwiDzv8uaZ4hwS29Y21BT1YR2ugmqdluMC6he2kg7mqJXXVVUdgxcYLeSsOfsxGhwuIW7IIXod0yC87R7HdcNeSsg7g7mqJXXvEOlbhEEKYsHGqlKUKtAnCjs4mSYanSqOBvubMbUMD86dBzavbXlz2VNbAyHYKt)GW7wwRySZanghx5HEFDhpfWSyuJDgOX44kp07R7Gh2DcMx0FCPqqOfsxRrRX)pqwPQG(C44DbmwZA8jJDgOX44kp07R7X)pqwj0aYaGuwzrjsXxOGwiDjOpho26Br3QOszi5AfWkdGYG)vYzeiT2VhmdCn74vaRmakd(xf0NdhVRG(C4yRySZanghx5HEFDhWqyMbAmEggyfnN)0fyHn2zGgJJR8qVVUdyimZangpddSIMZF6IWyYbe2yNbAmoUYd9(6(dBzaObKbaPSYIsKIVqbTq6IbAyHYKt)GWwBBJDgOX44kp07R7co88iLLcbzSZanghx5HEFD)HTma0aYaGuwzrjsXxOySZanghx5HEFDFrG4ZA4LYidurlKUSkEkGiHVQqIxzezYKSG)YHuLCgbsR97rLYqY1QuiOm7RmIi(yDCQsoJaPLvm2zGgJJR8qVVUhoiCsWkHwiDPmKCTkfckZ(kJiIpwhNQKZiqAHosHKufHbOEjyjTwihD8uaZ4hwSS(wBT8QnLbd0WcLjN(bHn2zGgJJR8qVVUJNcywkeKXod0yCCLh691DW4sqUKGvcTq6cPqsQIWauVeSKwxZoUXod0yCCLh691D8dVMDqkeoAH0LYIsKwFigQpv5a1ABk3yNbAmoUYd9(6ogmfIWlL1qFi0cPluzvLHKRvPqqz2xzer8X64uLCgbsR97vgsUwdxIe(ujNrG0Ykg7mqJXXvEO3x3JVCYxHxkdyLXQyK)qOfsxOYQkdjxRsHGYSVYiI4J1XPk5mcKw73RmKCTgUej8PsoJaPLvm2zGgJJR8qVVUhoiCsWkzSBSZanghxbl8fU4)hphUejCgASZanghxbl87R7lwG6mEkG5WXkJeWqLXyNbAmoUcw43x3LpAmoAH0LCsRHlrcNHvgOHfYyNbAmoUcw43x3ribMeOo8sOfsxYjTgUejCgwzGgwiJDgOX44kyHFFDhboZklviKbTq6soP1WLiHZWkd0WczSZanghxbl87R7sHGqGZSqlKUKtAnCjs4mSYanSqg7mqJXXvWc)(6EbMYHsF0C(tx4hEn7qR8iqYJuwhXNCfTq6cmdCn74vCX)pEoCjs4mSkOpho26YUFpYGXOlfLE0SG(C4yRTTng7mqJXXvWc)(6EbMYHsFmAH0LCsRHlrcNHvgOHfA)ELfLiTQXNY6KxbzTnLBSBSZanghxFyld4cmUeKljyLqlKUqkKKQima1lblP11SJJoEkGz8dlw7EHc64PaMXpSyz9LTn2zGgJJRpSLb8(6oEkGzPqqOfsxagRzn(K1pSLbKf0NdhBSZanghxFyld4919fbIpRHxkJmqfTq6cWynRXNS(HTmGSG(C4y0Xtbej8vfs8kJitMKf8xoKQKZiqAzSZanghxFyld491DmykeHxkRH(qOfsxagRzn(K1pSLbKf0NdhBSZanghxFyld49194)hiReAH0LYqY1A4kjCgMbZhPaRX4vYzeiTqxqFoCS1RcbRX4Lr51B3VhvkdjxRHRKWzygmFKcSgJxjNrG0cDbjji8dJajJDgOX446dBzaVVUdE4bNrgOIwiDbySM14tw)WwgqwqFoCSXod0yCC9HTmG3x3Xp8A2bPq4g7mqJXX1h2YaEFDpCq4KGvcTq6cWynRXNS(HTmGSG(C4yJDJDgOX44kHXKdi87R77mc4YcfEwq4Xzhqg7mqJXXvcJjhq43x3)0FeYKhPmSaeR8sq8hBSZanghxjmMCaHFFDhboZkpsz9HYKtFzm2zGgJJRegtoGWVVUxQGfRG98iLzzfjg9XyNbAmoUsym5ac)(6UiKlhs5WZy5mGm2zGgJJRegtoGWVVUlnGcmTYSSIeHszeI)g7mqJXXvcJjhq43x3LxicjzcVugbYy1yNbAmoUsym5ac)(6UGy5Hxklb5pHrlKUuwuI06dXq9jlhO7kBLVFVYIsKwFigQpz5a1ABkF)EPO0JMf0NdhBTnLVFVYIsKw14tzDYYbA2MY312LBSZanghxjmMCaHFFDhmoGCvWkTYsq(tg7mqJXXvcJjhq43x31hkx4itHVYsJaqOfsxifssvbbqnKW4S0iauvqFoCCNWYjqVXMBWwAT1Ub]] )


end
