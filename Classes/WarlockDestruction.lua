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
                    if legendary.odr_shawl_of_the_ymirjar.enabled then active_dot.odr_shawl_of_the_ymirjar = 1 end
                else
                    applyDebuff( "target", "havoc" )
                    if legendary.odr_shawl_of_the_ymirjar.enabled then applyDebuff( "target", "odr_shawl_of_the_ymirjar" ) end
                end
                applyBuff( "active_havoc" )
            end,

            copy = "real_havoc",

            auras = {
                odr_shawl_of_the_ymirjar = {
                    id = 337164,
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


    spec:RegisterPack( "Destruction", 20210916, [[dOe11aqiIsEKsf1Mik(evvuJIQeNIQKwfvvQxPkzwGk3IQkzxs6xkvnmjIJPk1YKi9mqHMMsfUgOOTrukFduGXruQohOKADkvKMhvPUNkzFkv6GuvHSqvQEiOe1ePQc6IGcYgbLi9rLkICsLkcRKQYmbfuTtjQFQurulLQkqpvKPQuARGseFLQkuJLQkG9k1Ff1GvXHrTyqEmWKvYLH2mr(SsXOvfNwy1GckVguQzJ42QQDt53kgor1XPQISCcphPPt66sy7ufFNQQgpOeopOQ1dkjZxLY(PY97EBNwSID5slP03LaRFlB13YEjWyjW6oPWlh7KCgaBEd2jJ)yN8drQkkaAmwNKZWtgE1B7eDkeaStpQkNUt3VFtOpfqvW83tJFbH1ymGGL0904d23jOIGO7ewd1PfRyxU0sk9DjW63Yw9TSxcmwIS3jUqFgrNsXhwUtpXAHwd1PfsbDYpePQOaOXyUJFmlida2oFjuUIFiu4oVLn4CNslP03oFoFWYpSTbP7uNp)YDGLsq6dqWs6EyjdH1GGUtAiEqtDhaBaKKdj3b8W2gC5o64oHPOquixZHuTtKGQ0EBNqkfnas7TD5392oXangRt(pcYYdgwwG0XydGDcngIGR(ERD5s7TDIbAmwN(4FeWNhPmPaeR8sG8N2j0yicU67T2LHXEBNyGgJ1jiYmR8iL1hmJg(HVtOXqeC13BTlVJEBNyGgJ1PnfSyfSLhPmdRqXOpDcngIGR(ERDzy2B7ed0ySojc5YjyoSmvodWoHgdrWvFV1USS1B7ed0ySojnGckUYmScfHIziK)DcngIGR(ERDzyqVTtmqJX6K8cribFyBYqeMQDcngIGR(ERDzzV32j0yicU67Dcicffb3jLfBqT(GmrFYYbQ7SR7i7L4o3U5okl2GA9bzI(KLdu3XB3P0sCNB3ChPyZJMf4NdJ6oE7oLwI7C7M7OSydQvn(ywNSCGMlTe3zx3zhL0jgOXyDsGS8W2KLi8hPT2LH192oXangRtGXaOPcwXvwIWFStOXqeC13BTl)UKEBNqJHi4QV3jGiuueCNGkKKQceaBcsPzPraWQa)Cy0oXangRt6dMlmOPWwzPraWwBTtpSNb0B7YV7TDcngIGR(ENaIqrrWDcQqsQcXayVeSKwxJ)M7iJ7qNcsM(WIL7S7L782DKXDOtbjtFyXYD8(YD2rNyGgJ1jWyseEJGvS1UCP92oHgdrWvFVtarOOi4obyQM14JUJ3UZd7zazb(5WODIbAmwNOtbjlfcS1Umm2B7eAmebx99obeHIIG7eGPAwJp6oE7opSNbKf4NdJ6oY4o0PGaf2QsqELHGpJWc(lNGv0yicU6ed0ySoTqq8znSnzOHOT2L3rVTtOXqeC137eqekkcUtaMQzn(O74T78WEgqwGFomANyGgJ1jkykeHTjRH(GT2LHzVTtOXqeC137eqekkcUtktqtRHPOWysgmFOcQgJvrJHi4YDKXDe4NdJ6oE7oRcbRXyUJF7oLuHP7C7M7il3rzcAAnmffgtYG5dvq1ySkAmebxUJmUJaLei9HHiyNyGgJ1P4)hcRyRDzzR32j0yicU67Dcicffb3jat1SgF0D82DEypdilWphgTtmqJX6e4HhAgAiARDzyqVTtmqJX6e9HxJ)qfcRtOXqeC13BTll792oHgdrWvFVtarOOi4obyQM14JUJ3UZd7zazb(5WODIbAmwNcdegkyfBT1ojxGG5dXAVTl)U32j0yicU67DIbAmwNKqsEn)WyngRtlKceHCngRtWqWceuO4YDGqPrGUdy(qS6oq4MWOv3Xpcaq5k1DSX8Rhw8LkiUdd0ymQ7mgb(ANaIqrrWDsJp6o76oL4oY4oYYDKJALjHhS1UCP92oXangRt0I)FSC8L3j0yicU67T2LHXEBNqJHi4QV3jJ)yN05J5rk)hJQIPGMbJrvrbqJXODIbAmwN05J5rk)hJQIPGMbJrvrbqJXOT2L3rVTtOXqeC137KXFSt0HG8dntrGa1SIGhl8tfyNyGgJ1j6qq(HMPiqGAwrWJf(PcS1Umm7TDIbAmwNKii9biyjTtOXqeC13BTllB92oHgdrWvFVtarOOi4oPmbnTUre)jeyEKYugicPaGv0yicU6ed0ySoTre)jeyEKYugicPaGT2LHb92oHgdrWvFVtg)XorF414pUYJakpszDeF00oXangRt0hEn(JR8iGYJuwhXhnT1USS3B7ed0ySorNcswkeyNqJHi4QV3Axgw3B7ed0ySofgimuWk2j0yicU67T2AN4b7TD5392oHgdrWvFVtarOOi4ojh1AysOWysLbA4bDhzChV4oYYDaZqwJ)w9H9mGQa5f8UZTBUdd0WdMrd)bsDNDDhy0D8ANyGgJ1jbhwEKYsHaBTlxAVTtmqJX6eDkizXODcngIGR(ERDzyS32j0yicU67Dcicffb3P1O14)hcRyvGFomQ7SR7ayQM14JDIbAmwNapSzijVW)ysHaBTlVJEBNqJHi4QV3jgOXyDk()HWk2jGiuueCNe4NdJ6oE7oW0DKXD8I7il3rzcAAfWkdiWt)v0yicUCNB3ChWmK14VvbSYac80FvGFomQ7SR7iWphg1D8ANaWdiywzXguPD53T2LHzVTtOXqeC137ed0ySobycjZangltcQ2jsq1SXFStGfT1USS1B7eAmebx99oXangRtaMqYmqJXYKGQDIeunB8h7esPObqARDzyqVTtOXqeC137ed0ySo9WEgqNaIqrrWDIbA4bZOH)aPUJ3UZo6eaEabZkl2GkTl)U1USS3B7ed0ySoj4WYJuwkeyNqJHi4QV3Axgw3B7eAmebx99oXangRtpSNb0ja8acMvwSbvAx(DRD53L0B7eAmebx99obeHIIG7KxCh6uqGcBvjiVYqWNryb)LtWkAmebxUZTBUJSChLjOPvPqGz2wzir8P6yyfngIGl3XRDIbAmwNwii(Sg2Mm0q0w7YVF3B7eAmebx99obeHIIG7KYe00QuiWmBRmKi(uDmSIgdrWL7iJ7avijvHyaSxcwsRfYDhzCh6uqY0hwSChVDhy6o(L7usTu3XVDhgOHhmJg(dK2jgOXyDkmqyOGvS1U87s7TDIbAmwNOtbjlfcStOXqeC13BTl)gg7TDcngIGR(ENaIqrrWDcQqsQcXayVeSKwxJ)wNyGgJ1jWyseEJGvS1U87D0B7eAmebx99obeHIIG7KYInOwFqMOpv5a1D82DkTKoXangRt0hEn(dviSw7YVHzVTtOXqeC137eqekkcUtYYD8I7OmbnTkfcmZ2kdjIpvhdROXqeC5o3U5oktqtRHjHcBQOXqeC5oETtmqJX6efmfIW2K1qFWw7YVLTEBNqJHi4QV3jGiuueCNKL74f3rzcAAvkeyMTvgseFQogwrJHi4YDUDZDuMGMwdtcf2urJHi4YD8ANyGgJ1P4lhTvyBYawzQkg5pyRD53WGEBNyGgJ1PWaHHcwXoHgdrWvFV1w7eyr7TD5392oHgdrWvFVtmqJX6e9HxJ)4kpcO8iL1r8rt7eqekkcUtGziRXFRsl()XYHjHcJjvb(5WOUJ3Udm6o3U5okl2GAvJpM1jVc0D82D2rPDY4p2j6dVg)XvEeq5rkRJ4JM2AxU0EBNyGgJ1jAX)pwomjuymPtOXqeC13BTldJ92oXangRtlwa7mDki5WOkdfKqHVtOXqeC13BTlVJEBNqJHi4QV3jGiuueCNKJAnmjuymPYan8GDIbAmwNKpAmwRDzy2B7eAmebx99obeHIIG7KCuRHjHcJjvgOHhStmqJX6eekOOa2HTP1USS1B7eAmebx99obeHIIG7KCuRHjHcJjvgOHhStmqJX6eezMvwQqaFRDzyqVTtOXqeC137eqekkcUtYrTgMekmMuzGgEWoXangRtsHaHiZSATll792oHgdrWvFVtarOOi4ojh1AysOWysLbA4bDNB3ChLfBqTQXhZ6Kxb6oE7oLwsNyGgJ1PckMdf)0wBTtluIliAVTl)U32j0yicU67DAHuGiKRXyDcgcwGGcfxUd6bfW7oA8r3rFq3Hb6iCNG6oShoimebRDIbAmwNOYrcjtgaSBTlxAVTtOXqeC137eqekkcUtpSNbKzGgEq3rg3HbA4bZOH)aPUZUUZB3rg3HbA4bZOH)aPUJ3UdmDh)YDuMGMwdtcf2urJHi4YDE5oEXDuMGMwdtcf2urJHi4YDKXDuMGMwdtrHXKmy(qfungRIgdrWL741oXangRtaMqYmqJXYKGQDIeunB8h70d7zaT2LHXEBNqJHi4QV3jgOXyDsIG0hGGL0obeHIIG7eDkiqHTQEgcRbbZ0H4bnTIgdrWvNctrHOqUMdPobvijv9mewdcMPdXdAATqERD5D0B7eAmebx99obeHIIG7KYe00QyyryBYqegwHv0yicUChzCNfcvijvfdlcBtgIWWkSkWphg1D82DExHzNyGgJ1jWyseEJGvS1Umm7TDcngIGR(ENaIqrrWDswUJxCh5OwdtcfgtQmqdpO7iJ7SgTg))qyfRc8ZHrDNxUZB3zx3roQ1WKqHXKQa)Cyu3XRUZTBUdvosizLfBqLwbSYac80V7SR78UtmqJX6eGvgqGN(BTllB92oHgdrWvFVtarOOi4oXan8Gz0WFGu3zx3P0oXangRtaMqYmqJXYKGQDIeunB8h7epyRDzyqVTtOXqeC137ed0ySorNcswkeyNaIqrrWDsGscK(Wqe0DKXDOtbjtFyXYD8(YD2H7iJ74f3rwUJYe00kGvgqGN(ROXqeC5o3U5oGziRXFRcyLbe4P)Qa)Cyu3zx3rGFomQ741obGhqWSYInOs7YVBTll792oHgdrWvFVtmqJX6u8)dHvStarOOi4ojqjbsFyic6oY4oEXDKL7OmbnTcyLbe4P)kAmebxUZTBUdygYA83QawzabE6VkWphg1D21De4NdJ6oETta4bemRSydQ0U87w7YW6EBNqJHi4QV3jGiuueCNuMGMwdtrHXKmy(qfungRIgdrWL7iJ7WangRcE4HMHgIwdllrInpQ7iJ7iWphg1D82DwfcwJXCh)2DkPcZoXangRtX)pewXw7YVlP32j0yicU67DIbAmwNamHKzGgJLjbv7ejOA24p2jWI2Ax(97EBNqJHi4QV3jgOXyDcWesMbAmwMeuTtKGQzJ)yNqkfnasBTl)U0EBNyGgJ1jWdBgsYl8pMuiWoHgdrWvFV1U8ByS32jgOXyDIcMcryBYAOpyNqJHi4QV3Ax(9o6TDIbAmwNwii(Sg2Mm0q0oHgdrWvFV1U8By2B7eAmebx99oXangRtpSNb0jGiuueCNwJwJ)FiSIvb(5WOUZUUZA0A8)dHvSUkeSgJ5o(T7usfMUZTBUJSChLjOP1WuuymjdMpubvJXQOXqeC1ja8acMvwSbvAx(DRD53YwVTtmqJX6u8LJ2kSnzaRmvfJ8hStOXqeC13BTl)gg0B7ed0ySorNcswmANqJHi4QV3Ax(TS3B7eAmebx99obeHIIG7KOWqPrSbRZsKPpS)K8iL1hmd)peWWyrf9tfHC54QtmqJX60d7zaT2LFdR7TDcngIGR(ENg5DIIANyGgJ1jpSiyic2jpmPa7ed0WdMrd)bsDNDDN3UJmUdygYA83QpSNbuf4NdJ6oEF5oVlXDUDZDaZqwJ)wLw8)JLdtcfgtQc8ZHrDhVVCN3W0DKXDuMGMwxSa2z6uqYHrvgkiHcFfngIGl3rg3bmdzn(B1flGDMofKCyuLHcsOWxf4NdJ6oEF5oVHP7C7M7OmbnTUybSZ0PGKdJQmuqcf(kAmebxUJmUdygYA83Qlwa7mDki5WOkdfKqHVkWphg1D8(YDEdt3rg3XlUdygYA83Q0I)FSCysOWysvGFomQ7SR7OSydQvn(ywN8kq352n3bmdzn(BvAX)pwomjuymPkWphg1DE5oGziRXFRsl()XYHjHcJj1vHG1ym3zx3rzXguRA8XSo5vGUJx7KhwKn(JDs(mKmDkiz6dlw0w7YLwsVTtOXqeC137eqekkcUtqfssviga7LGL06A83ChzCh6uqY0hwSCNDVCN3vy6o(L7usfgDh)2DuMGMwLim9z8GIkAmebxUJmUJSChpSiyicwLpdjtNcsM(WIfTtmqJX6eymjcVrWk2AxU0392oHgdrWvFVtarOOi4obvijvxSa2z6uqYHrvgkiHcFTqENyGgJ1jWdp0m0q0w7YLwAVTtOXqeC137eqekkcUtqfssviga7LGL0AHC3rg3rwUJhwemebRYNHKPtbjtFyXI6oY4oYYDuMGMwrbVcaRXyv0yicU6ed0ySobE4HMHgI2AxUuyS32j0yicU67Dcicffb3jz5oEyrWqeSkFgsMofKm9HflQ7iJ7OmbnTIcEfawJXQOXqeC5oY4oEXDwiuHKuff8kaSgJvf4NdJ6oE7oaMQzn(O7C7M7avijvHyaSxcwsRfYDhV2jgOXyDc8WdndneT1UCP7O32j0yicU67Dcicffb3jz5oEyrWqeSkFgsMofKm9HflQ7C7M7qNcsM(WIL7S7L7SJkm7ed0ySorF414puHWATlxkm7TDcngIGR(ENaIqrrWDYlUdDkiz6dlwUZUxUZoQW0D8l3PKAPUJF7omqdpygn8hi1D8ANyGgJ1jWdp0m0q0w7YLkB92oHgdrWvFVtarOOi4obEyXgK6o76oV7ed0ySobgtIWBeSIT2Llfg0B7ed0ySofgimuWk2j0yicU67T2ARDYdkOXyD5slP03Li7W47o5plSW2q7KFSFKFWY7eL3jTtDh3z7d6oXx(iu3rAeUJFEHsCbr9ZUJa9tfHaxUdD(O7Wf68zfxUd4HTniT68bdpm0DGXDQ7alpMhuO4YD8Z0PGaf2Q6hWp7o64o(z6uqGcBv9durJHi4Yp7oS6oWq7KHH7oE5nSWRvNpNVDIV8rO4YDKn3HbAmM7qcQsRoFDsUyKcc2PDENDh)qKQIcGgJ5o(XSGmay78TZ7S7Kq5k(HqH78w2GZDkTKsF7858TZ7S7al)W2gKUtD(25D2D8l3bwkbPpablP7HLmewdc6oPH4bn1DaSbqsoKChWdBBWL7OJ7eMIcrHCnhsvNpNVD2DGHGfiOqXL7aHsJaDhW8Hy1DGWnHrRUJFeaGYvQ7yJ5xpS4lvqChgOXyu3zmc8vNpgOXy0QCbcMpeRxsijVMFySgJbxiDPXh3TezKLCuRmj8GoFmqJXOv5cemFiwFDTNw8)JLLJQZhd0ymAvUabZhI1xx7lOyou8dNXF8sNpMhP8FmQkMcAgmgvffangJ68XangJwLlqW8Hy911(ckMdf)Wz8hVOdb5hAMIabQzfbpw4NkqNpgOXy0QCbcMpeRVU2lrq6dqWsQZhd0ymAvUabZhI1xx73iI)ecmpszkdeHuaq4cPlLjOP1nI4pHaZJuMYarifaSIgdrWLZhd0ymAvUabZhI1xx7lOyou8dNXF8I(WRXFCLhbuEKY6i(OPoFmqJXOv5cemFiwFDTNofKSuiqNpgOXy0QCbcMpeRVU2hgimuWk6858TZUdmeSabfkUCh0dkG3D04JUJ(GUdd0r4ob1DypCqyicwD(yGgJrVOYrcjtgaSD(yGgJrVamHKzGgJLjbvHZ4pE9WEgaCH01d7zazgOHhuggOHhmJg(dKU7BzyGgEWmA4pqQ3W0VuMGMwdtcf2urJHi46LxuMGMwdtcf2urJHi4sgLjOP1WuuymjdMpubvJXQOXqeC5vNpgOXy0xx7Lii9biyjfUq6IofeOWwvpdH1GGz6q8GMcxykkefY1CiDbvijv9mewdcMPdXdAATqUZhd0ym6RR9GXKi8gbRiCH0LYe00QyyryBYqegwHv0yicUKzHqfssvXWIW2KHimScRc8ZHr9(DfMoFmqJXOVU2dyLbe4PF4cPlz5f5OwdtcfgtQmqdpOmRrRX)pewXQa)Cy0xV3voQ1WKqHXKQa)CyuVE7gvosizLfBqLwbSYac80)UVD(yGgJrFDThWesMbAmwMeufoJ)4fpiCH0fd0WdMrd)bs3TuNpgOXy0xx7Ptbjlfceoa8acMvwSbv61B4cPlbkjq6ddrqzOtbjtFyXY7RDiJxKLYe00kGvgqGN(ROXqeCD7gygYA83QawzabE6VkWphgDxb(5WOE15JbAmg911(4)hcRiCa4bemRSydQ0R3WfsxcusG0hgIGY4fzPmbnTcyLbe4P)kAmebx3UbMHSg)TkGvgqGN(Rc8ZHr3vGFomQxD(yGgJrFDTp()HWkcxiDPmbnTgMIcJjzW8HkOAmwfngIGlzyGgJvbp8qZqdrRHLLiXMhvgb(5WOEVkeSgJ53LuHPZhd0ym6RR9aMqYmqJXYKGQWz8hValQZhd0ym6RR9aMqYmqJXYKGQWz8hVqkfnasD(yGgJrFDTh8WMHK8c)Jjfc05JbAmg911EkykeHTjRH(GoFmqJXOVU2Vqq8znSnzOHOoFmqJXOVU2)WEgaCa4bemRSydQ0R3WfsxRrRX)pewXQa)Cy0DxJwJ)FiSI1vHG1ym)UKkmVDtwktqtRHPOWysgmFOcQgJvrJHi4Y5JbAmg911(4lhTvyBYawzQkg5pOZhd0ym6RR90PGKfJ68XangJ(6A)d7zaWfsxIcdLgXgSolrM(W(tYJuwFWm8)qadJfv0pveYLJlNpgOXy0xx79WIGHiiCg)Xl5ZqY0PGKPpSyrHZdtkWlgOHhmJg(dKU7BzaZqwJ)w9H9mGQa)CyuVVExYTBGziRXFRsl()XYHjHcJjvb(5WOEF9gMYOmbnTUybSZ0PGKdJQmuqcf(kAmebxYaMHSg)T6IfWotNcsomQYqbju4Rc8ZHr9(6nmVDtzcAADXcyNPtbjhgvzOGek8v0yicUKbmdzn(B1flGDMofKCyuLHcsOWxf4NdJ691BykJxaZqwJ)wLw8)JLdtcfgtQc8ZHr3vzXguRA8XSo5vG3UbMHSg)TkT4)hlhMekmMuf4NdJ(cmdzn(BvAX)pwomjuymPUkeSgJTRYInOw14JzDYRa9QZhd0ym6RR9GXKi8gbRiCH0fuHKufIbWEjyjTUg)nzOtbjtFyXA3R3vy6xLuHr)wzcAAvIW0NXdkQOXqeCjJS8WIGHiyv(mKmDkiz6dlwuNpgOXy0xx7bp8qZqdrHlKUGkKKQlwa7mDki5WOkdfKqHVwi35JbAmg911EWdp0m0qu4cPlOcjPkedG9sWsATqUmYYdlcgIGv5ZqY0PGKPpSyrLrwktqtROGxbG1ySkAmebxoFmqJXOVU2dE4HMHgIcxiDjlpSiyicwLpdjtNcsM(WIfvgLjOPvuWRaWAmwfngIGlz8YcHkKKQOGxbG1ySQa)CyuVbmvZA8XB3GkKKQqma2lblP1c5E15JbAmg911E6dVg)HkegCH0LS8WIGHiyv(mKmDkiz6dlw0B3OtbjtFyXA3RDuHPZhd0ym6RR9GhEOzOHOWfsxEHofKm9HfRDV2rfM(vj1s9BgOHhmJg(dK6vNpgOXy0xx7bJjr4ncwr4cPlWdl2G0DF78XangJ(6AFyGWqbROZNZhd0ymALh8sWHLhPSuiq4cPl5OwdtcfgtQmqdpOmErwGziRXFR(WEgqvG8c(B3yGgEWmA4pq6UWOxD(yGgJrR8GVU2tNcswmQZhd0ymALh811EWdBgsYl8pMuiq4cPR1O14)hcRyvGFom6UaMQzn(OZhd0ymALh811(4)hcRiCa4bemRSydQ0R3Wfsxc8ZHr9gMY4fzPmbnTcyLbe4P)kAmebx3UbMHSg)TkGvgqGN(Rc8ZHr3vGFomQxD(yGgJrR8GVU2dycjZangltcQcNXF8cSOoFmqJXOvEWxx7bmHKzGgJLjbvHZ4pEHukAaK68XangJw5bFDT)H9ma4aWdiywzXguPxVHlKUyGgEWmA4pqQ37W5JbAmgTYd(6AVGdlpszPqGoFmqJXOvEWxx7Fypdaoa8acMvwSbv61BNpgOXy0kp4RR9leeFwdBtgAikCH0LxOtbbkSvLG8kdbFgHf8xobROXqeCD7MSuMGMwLcbMzBLHeXNQJHv0yicU8QZhd0ymALh811(WaHHcwr4cPlLjOPvPqGz2wzir8P6yyfngIGlzGkKKQqma2lblP1c5YqNcsM(WIL3W0VkPwQFZan8Gz0WFGuNpgOXy0kp4RR90PGKLcb68XangJw5bFDThmMeH3iyfHlKUGkKKQqma2lblP114V58XangJw5bFDTN(WRXFOcHbxiDPSydQ1hKj6tvoq9U0sC(yGgJrR8GVU2tbtHiSnzn0heUq6swErzcAAvkeyMTvgseFQogwrJHi462nLjOP1WKqHnv0yicU8QZhd0ymALh811(4lhTvyBYawzQkg5piCH0LS8IYe00QuiWmBRmKi(uDmSIgdrW1TBktqtRHjHcBQOXqeC5vNpgOXy0kp4RR9HbcdfSIoFoFmqJXOvWIEvqXCO4hoJ)4f9HxJ)4kpcO8iL1r8rtHlKUaZqwJ)wLw8)JLdtcfgtQc8ZHr9ggVDtzXguRA8XSo5vGEVJsD(yGgJrRGf911EAX)pwomjuymX5JbAmgTcw0xx7xSa2z6uqYHrvgkiHcVZhd0ymAfSOVU2lF0ym4cPl5OwdtcfgtQmqdpOZhd0ymAfSOVU2dHckkGDyBGlKUKJAnmjuymPYan8GoFmqJXOvWI(6ApezMvwQqapCH0LCuRHjHcJjvgOHh05JbAmgTcw0xx7LcbcrMzbxiDjh1AysOWysLbA4bD(yGgJrRGf911(ckMdf)u4cPl5OwdtcfgtQmqdp4TBkl2GAvJpM1jVc07slX5Z5JbAmgT(WEgWfymjcVrWkcxiDbvijvHyaSxcwsRRXFtg6uqY0hwS296Tm0PGKPpSy591oC(yGgJrRpSNb86ApDkizPqGWfsxaMQzn(O3pSNbKf4NdJ68XangJwFypd411(fcIpRHTjdnefUq6cWunRXh9(H9mGSa)CyuzOtbbkSvLG8kdbFgHf8xobROXqeC58XangJwFypd411EkykeHTjRH(GWfsxaMQzn(O3pSNbKf4NdJ68XangJwFypd411(4)hcRiCH0LYe00AykkmMKbZhQGQXyv0yicUKrGFomQ3RcbRXy(DjvyE7MSuMGMwdtrHXKmy(qfungRIgdrWLmcusG0hgIGoFmqJXO1h2ZaEDTh8WdndnefUq6cWunRXh9(H9mGSa)CyuNpgOXy06d7zaVU2tF414puHWC(yGgJrRpSNb86AFyGWqbRiCH0fGPAwJp69d7zazb(5WOoFoFmqJXOvKsrdG0xx79FeKLhmSSaPJXgaD(yGgJrRiLIgaPVU2)X)iGppszsbiw5La5p15JbAmgTIukAaK(6ApezMvEKY6dMrd)W78XangJwrkfnasFDTFtblwbB5rkZWkum6JZhd0ymAfPu0ai911ErixobZHLPYza68XangJwrkfnasFDTxAafuCLzyfkcfZqi)D(yGgJrRiLIgaPVU2lVqesWh2MmeHPQZhd0ymAfPu0ai911EbYYdBtwIWFKcxiDPSydQ1hKj6twoq3v2l52nLfBqT(GmrFYYbQ3LwYTBsXMhnlWphg17sl52nLfBqTQXhZ6KLd0CPLS7okX5JbAmgTIukAaK(6ApymaAQGvCLLi8hD(yGgJrRiLIgaPVU2RpyUWGMcBLLgbaHlKUGkKKQceaBcsPzPraWQa)Cy0orLJGUCPYgmO1w7g]] )


end
