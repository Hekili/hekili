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
            -- ???
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
            duration = 10,
            max_stack = 1,

            generate = function( ah )
                if active_enemies > 1 then
                    if pvptalent.bane_of_havoc.enabled and debuff.bane_of_havoc.up and query_time - last_havoc < 10 then
                        ah.count = 1
                        ah.applied = last_havoc
                        ah.expires = last_havoc + 10
                        ah.caster = "player"
                        return
                    elseif not pvptalent.bane_of_havoc.enabled and active_dot.havoc > 0 and query_time - last_havoc < 10 then
                        ah.count = 1
                        ah.applied = last_havoc
                        ah.expires = last_havoc + 10
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
            duration = 10,
            max_stack = 1,
            generate = function( boh )
                boh.applied = action.bane_of_havoc.lastCast
                boh.expires = boh.applied > 0 and ( boh.applied + 10 ) or 0
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
            duration = 12,
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
            cast = function () return ( buff.backdraft.up and 0.7 or 1 ) * 3 * haste end,
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
                removeStack( "backdraft" )
                removeStack( "crashing_chaos" )
            end,
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
                else
                    applyDebuff( "target", "havoc" )
                end
                applyBuff( "active_havoc" )
            end,

            copy = "real_havoc"
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


    spec:RegisterPack( "Destruction", 20201012, [[deeIRaqiOIEerjAtqvgLssoLsIwfrj9kLuZcQQBPKq7su)sP0WikoMuQLru5zqfAAeL6AaW2uskFJOeghubDoLe06GkqnprQUNs1(iQ6Gkjqwia9qLeOMOsc4IqfiNujPQwPizNsHFQKuPNsvtvk5RkjvzVs(Runyv6WOwmuESQMSkUmYMjYNvkgnGonLxdGMnKBd0Uf(TIHlIwoHNdA6KUUsSDr47IugVssfNhQ06HkG5lfTFQC1UAv(dRu1qozKtM2Y0wUSC4OmaqUvR8kUjPYNKFaYBOYhmiv(vacQILxTjkFsgx0WNQv5HZI4PYdu1KqCWB3UXuGly5Fa3cnWfeR2eVGL0Tqd83wESfdPR(rHv(dRu1qozKtM2Y0wUSC4OmYw2LNxuGJO8EdCfC5bANdffw5pe8lVS0DxbiOkwE1MWDx9ybAEa6sjlD3v3xhms4UTLdF3vozKtMYJmOcRwLNGqkEcwTQgTRwLNF1MO8Pnc0jbzrxqWj44PYtbJHOtbyPvd5QwLNF1MO8Ge4iWTpsD0YBN(rqmiS8uWyi6uawA1ahRwLNF1MO8yOzo9rQRaPofeiULNcgdrNcWsRgYUAvE(vBIYVzHfhJJ(i1zCasmkWYtbJHOtbyPvdauTkp)Qnr5fwYKiQBrhMKFQ8uWyi6uawA1y1QwLNF1MO8sZVaPtNXbiHPuhJyWYtbJHOtbyPvdzr1Q88R2eLp5IWKW1InDmed1YtbJHOtbyPvdCy1Q8uWyi6uaw(xykjmU8kl2qAgiXifyp5RUR8Uloug3Tzt3vzXgsZajgPa7jF1Dt3DLtg3Tzt3vY2au7ccKTa6UP7UYjJ72SP7QSydPz1aPUo9KV2Ltg3vE3v2YuE(vBIYlioPfB6sigKGLwnwHvRYZVAtu(FINcvWkD6sigKkpfmgIofGLwnAlt1Q8uWyi6uaw(xykjmU8ylsszb9aerqyxAepLfeiBbS88R2eLxbs9LaBwItxAepvAPLhiNy(Qv1OD1Q8uWyi6uaw(xykjmU8ylsszm(b4rWsA(mPfUlEUlCwqDiqwCCx53D32UlEUlCwqDiqwCC303DxzxE(vBIY)tiH4ncwPsRgYvTkp)Qnr5HZcQlzcQ8uWyi6uawA1ahRwLNcgdrNcWY)ctjHXL)zO2vdKC30DxGCI57ccKTawE(vBIYd)zryXMUAkqQ0QHSRwLNcgdrNcWY)ctjHXLxzefA2cLebJ6)aITavBImfmgIoUlEURGazlGUB6U7zrWQnH7kRURmza4UnB6U40DvgrHMTqjrWO(pGylq1MitbJHOJ7IN7kijbbbYyiQ88R2eL3abheRuPvdauTkpfmgIofGL)fMscJl)ZqTRgi5UP7Ua5eZ3feiBbS88R2eL)bYdSJniT0QXQvTkp)Qnr5Ha5ZKg2IikpfmgIofGLwnKfvRYtbJHOtby5FHPKW4Y)mu7QbsUB6UlqoX8DbbYwalp)Qnr5T4TGeSsLwA5tkOFaXyTAvnAxTkp)Qnr5HlGGt0nWKLNcgdrNcWsRgYvTkpfmgIofGL)fMscJlVYik08gHboMG6JuhYVWKSNYuWyi6uE(vBIYVryGJjO(i1H8lmj7PsRg4y1Q88R2eLp5O2eLNcgdrNcWsRgYUAvE(vBIYdNfuxYeu5PGXq0PaS0QbaQwLNcgdrNcWY)ctjHXLhNURYik0mCwqDjtqzkymeDkp)Qnr5T4TGeSsLwA55HQwvJ2vRYtbJHOtby5FHPKW4YNK0SfsKiyuMF1sqUlEU7QCxC6U)mOZKwKbYjMpli(GR72SP7YVAjOofeOrq3vE3fhD3vwE(vBIYlyl6JuxYeuPvd5QwLNcgdrNcWY)ctjHXL)mA2abheRuwqGSfq3vE39zO2vdKkp)Qnr5FGCeeQFiWjKmbvA1ahRwLNcgdrNcWYZVAtuEdeCqSsL)fMscJlVGazlGUB6UlaCx8C3v5U40DvgrHMFw5hHlemtbJHOJ72SP7(ZGotAr(zLFeUqWSGazlGUR8URGazlGU7kl)J7JOUYInKcRgTlTAi7Qv5PGXq0PaS88R2eL)zeQZVAt0rgulpYGApyqQ8)bwA1aavRYtbJHOtby55xTjk)ZiuNF1MOJmOwEKb1EWGu5jiKINGLwnwTQv5PGXq0PaS88R2eLhiNy(Y)4(iQRSydPWQr7sRgYIQv55xTjkVGTOpsDjtqLNcgdrNcWsRg4WQv5PGXq0PaS88R2eLhiNy(Y)4(iQRSydPWQr7sRgRWQv5PGXq0PaS8VWusyC5vgrHMLmb1540XegiuNGYuWyi64U45Uylsszm(b4rWsAEjP7IN7cNfuhcKfh3nD3faU7k6UYKLZDLv3LF1sqDkiqJGLNF1MO8w8wqcwPsRgTLPAvE(vBIYdNfuxYeu5PGXq0PaS0Qr72vRYtbJHOtby5FHPKW4YJTijLX4hGhblP5ZKwuE(vBIY)tiH4ncwPsRgTLRAvEkymeDkal)lmLegxELfBindKyKcmN8v3nD3vozkp)Qnr5Ha5ZKg2IikTA0ghRwLNF1MO8w8wqcwPYtbJHOtbyPLw()aRwvJ2vRYZVAtuE4ci4eDlKirWOYtbJHOtbyPvd5QwLNF1MO8hwaWoCwqDlGkJzitXT8uWyi6uawA1ahRwLNcgdrNcWY)ctjHXLpjPzlKirWOm)QLGkp)Qnr5toQnrPvdzxTkpfmgIofGL)fMscJlFssZwirIGrz(vlbvE(vBIYJrcijaOfBkTAaGQv5PGXq0PaS8VWusyC5tsA2cjsemkZVAjOYZVAtuEm0mNU0Ia3sRgRw1Q8uWyi6uaw(xykjmU8jjnBHejcgL5xTeu55xTjkVKjim0mNsRgYIQv5PGXq0PaS8VWusyC5tsA2cjsemkZVAji3Tzt3vzXgsZQbsDD6hJC30Dx5KP88R2eLFbsDtjqyPvdCy1Q88R2eL)qVbYQfB6ydslpfmgIofGLwnwHvRYtbJHOtby5FHPKW4YZVAjOofeOrq3vE3TT72SP7Inqy55xTjkVbMKIJfB6pRmuftsGuPvJ2YuTkpfmgIofGL)fMscJlp)QLG6uqGgbDx5D32UBZMUl2aHLNF1MO8Wzb1fJwA1OD7Qv5PGXq0PaS8VWusyC55xTeuNcc0iO7U7UTD3MnD3Fg0zslYa5eZNfeiBb0DL3Dbq55xTjkp8NfHfB6QPaPslT8hsIxqA1QA0UAvE(vBIYdtsiuhnpalpfmgIofGLwnKRAvE(vBIYdTyd1b5n2xEkymeDkalTAGJvRYtbJHOtby5FHPKW4YdKtmFNF1sqUlEUl)QLG6uqGgbD30Dxa4URO7QmIcnBHejIjtbJHOJ7U2DxL7QmIcnBHejIjtbJHOJ7IN7QmIcnBHsIGr9FaXwGQnrMcgdrh3DLLNF1MO8pJqD(vBIoYGA5rgu7bdsLhiNy(sRgYUAvEkymeDkal)lmLegxEC6URYDtsA2cjsemkZVAji3fp39mA2abheRuwqGSfq3DT722DL3DtsA2cjsemkliq2cO7Us3Tzt3fMKqOUYInKcZpR8JWfc6UY7UTlp)Qnr5Fw5hHleS0QbaQwLNcgdrNcWY)ctjHXLNF1sqDkiqJGUR8URCLNF1MO8pJqD(vBIoYGA5rgu7bdsLNhQ0QXQvTkpfmgIofGLNF1MO8Wzb1Lmbv(xykjmU8cssqqGmgICx8Cx4SG6qGS44UPV7UY2DXZDxL7It3vzefA(zLFeUqWmfmgIoUBZMU7pd6mPf5Nv(r4cbZccKTa6UY7UccKTa6URS8pUpI6kl2qkSA0U0QHSOAvEkymeDkalp)Qnr5nqWbXkv(xykjmU8cssqqGmgICx8C3v5U40DvgrHMFw5hHlemtbJHOJ72SP7(ZGotAr(zLFeUqWSGazlGUR8URGazlGU7kl)J7JOUYInKcRgTlTAGdRwLNcgdrNcWY)ctjHXLxzefA2cLebJ6)aITavBImfmgIoUlEUl)Qnr(bYdSJninBrxczBaQUlEURGazlGUB6U7zrWQnH7kRURmzauE(vBIYBGGdIvQ0QXkSAvEkymeDkalp)Qnr5FgH68R2eDKb1YJmO2dgKk)FGLwnAlt1Q8uWyi6uawE(vBIY)mc15xTj6idQLhzqThmivEccP4jyPvJ2TRwLNF1MO8pqocc1pe4esMGkpfmgIofGLwnAlx1Q8uWyi6uawE(vBIYdKtmF5FHPKW4YFgnBGGdIvkliq2cO7kV7EgnBGGdIvkFweSAt4UYQ7ktgaUBZMUloDxLruOzlusemQ)di2cuTjYuWyi6u(h3hrDLfBifwnAxA1OnowTkpfmgIofGLFswEiPLNF1MO8jyHXyiQ8jy0cvE(vlb1PGanc6UY7UTDx8C3Fg0zslYa5eZNfeiBb0DtF3DBlJ72SP7(ZGotArgUacor3cjsemkliq2cO7M(U72gaUlEURYik08HfaSdNfu3cOYygYuCZuWyi64U45U)mOZKwKpSaGD4SG6wavgZqMIBwqGSfq3n9D3TnaC3MnDxLruO5dlayholOUfqLXmKP4MPGXq0XDXZD)zqNjTiFyba7Wzb1TaQmMHmf3SGazlGUB67UBBa4U45URYD)zqNjTidxabNOBHejcgLfeiBb0DL3DvwSH0SAGuxN(Xi3Tzt39NbDM0ImCbeCIUfsKiyuwqGSfq3DT7(ZGotArgUacor3cjsemkFweSAt4UY7Ukl2qAwnqQRt)yK7UYYNGf9GbPYNCguholOoeiloWsRgTLD1Q8uWyi6uaw(xykjmU8ylsszm(b4rWsA(mPfUlEUlCwqDiqwCCx53D32za4URO7ktghDxz1DvgrHMLqme4KGezkymeDCx8CxC6UjyHXyikNCguholOoeiloWYZVAtu(FcjeVrWkvA1OnaQwLNcgdrNcWY)ctjHXLhBrskFyba7Wzb1TaQmMHmf38sYYZVAtu(hipWo2G0sRgTxTQv5PGXq0PaS8VWusyC5XwKKYy8dWJGL08ss3fp3fNUBcwymgIYjNb1HZcQdbYId0DXZDXP7QmIcntc(ypR2ezkymeDkp)Qnr5FG8a7ydslTA0wwuTkpfmgIofGL)fMscJlpoD3eSWymeLtodQdNfuhcKfhO7IN7QmIcntc(ypR2ezkymeDCx8C3v5UhcBrsktc(ypR2ezbbYwaD30D3NHAxnqYDB20DXwKKYy8dWJGL08ss3DLLNF1MO8pqEGDSbPLwnAJdRwLNcgdrNcWY)ctjHXLhNUBcwymgIYjNb1HZcQdbYId0DB20DHZcQdbYIJ7k)U7k7makp)Qnr5Ha5ZKg2IikTA0EfwTkpfmgIofGL)fMscJl)QCx4SG6qGS44UYV7UYoda3DfDxzYY5UYQ7YVAjOofeOrq3DLLNF1MO8pqEGDSbPLwnKtMQv5PGXq0PaS8VWusyC5FGSydbDx5D32LNF1MO8)esiEJGvQ0QHCTRwLNF1MO8w8wqcwPYtbJHOtbyPLwA5tqcOnr1qozKtM2Y0wUYNglcl2al)QpyYrO0XDxn3LF1MWDrguHzxQYNumsgIkVS0DxbiOkwE1MWDx9ybAEa6sjlD3v3xhms4UTLdF3vozKtgxkxkzP7IdA1H(fLoUlgjncYD)beJv3fJ2ybm7URG(NsQq3nMyfbYcqPfK7YVAtaD3jq4MDP4xTjG5Kc6hqmw3HlGGt0tsQlf)QnbmNuq)aIX669TBeg4ycQpsDi)ctYEcFtAxzefAEJWahtq9rQd5xys2tzkymeDCP4xTjG5Kc6hqmwxVVn5O2eUu8R2eWCsb9digRR33cNfuxYeKlf)QnbmNuq)aIX669Tw8wqcwj8nPDCQmIcndNfuxYeuMcgdrhxkxkzP7IdA1H(fLoUlLGe46UQbsURcKCx(1r4Ug0D5eSHymeLDP4xTjG7WKec1rZdqxk(vBc469Tql2qDqEJ9UuUu8R2eW17BFgH68R2eDKbv8dgK2bYjMhFtAhiNy(o)QLGWJF1sqDkiqJGPdGvuzefA2cjsetMcgdrN1RszefA2cjsetMcgdrh8ugrHMTqjrWO(pGylq1MitbJHOZkDP4xTjGR33(SYpcxii(M0ooxvssZwirIGrz(vlbH3z0SbcoiwPSGazlGRBlFssZwirIGrzbbYwaxzZMWKec1vwSHuy(zLFeUqq5B7sXVAtaxVV9zeQZVAt0rguXpyqANhcFtANF1sqDkiqJGYlNlf)QnbC9(w4SG6sMGW)X9ruxzXgsH7TX3K2fKKGGazmeHhCwqDiqwCsFx24TkCQmIcn)SYpcxiyMcgdrNMn)zqNjTi)SYpcxiywqGSfq5feiBbCLUu8R2eW17BnqWbXkH)J7JOUYInKc3BJVjTlijbbbYyicVvHtLruO5Nv(r4cbZuWyi60S5pd6mPf5Nv(r4cbZccKTakVGazlGR0LIF1MaUEFRbcoiwj8nPDLruOzlusemQ)di2cuTjYuWyi6Gh)Qnr(bYdSJninBrxczBaQ4jiq2cy6NfbR2eYQmza4sXVAtaxVV9zeQZVAt0rguXpyqA)pqxk(vBc469TpJqD(vBIoYGk(bds7eesXtqxk(vBc469Tpqocc1pe4esMGCP4xTjGR33cKtmp(pUpI6kl2qkCVn(M0(z0SbcoiwPSGazlGYFgnBGGdIvkFweSAtiRYKbqZM4uzefA2cLebJ6)aITavBImfmgIoUu8R2eW17BtWcJXqe(bds7jNb1HZcQdbYIde)emAH25xTeuNcc0iO8TX7NbDM0ImqoX8zbbYwatFVTmnB(ZGotArgUacor3cjsemkliq2cy67TbaEkJOqZhwaWoCwqDlGkJzitXntbJHOdE)mOZKwKpSaGD4SG6wavgZqMIBwqGSfW03BdGMnvgrHMpSaGD4SG6wavgZqMIBMcgdrh8(zqNjTiFyba7Wzb1TaQmMHmf3SGazlGPV3ga4TQFg0zslYWfqWj6wirIGrzbbYwaLxzXgsZQbsDD6hJA28NbDM0ImCbeCIUfsKiyuwqGSfW1)mOZKwKHlGGt0TqIebJYNfbR2eYRSydPz1aPUo9JrR0LIF1MaUEF7pHeI3iyLW3K2XwKKYy8dWJGL08zslWdolOoeiloYV3odGvuMmokRkJOqZsigcCsqImfmgIo4HZeSWymeLtodQdNfuhcKfhOlf)QnbC9(2hipWo2Gu8nPDSfjP8HfaSdNfu3cOYygYuCZljDP4xTjGR33(a5b2XgKIVjTJTijLX4hGhblP5LK4HZeSWymeLtodQdNfuhcKfhiE4uzefAMe8XEwTjYuWyi64sXVAtaxVV9bYdSJnifFtAhNjyHXyikNCguholOoeiloq8ugrHMjbFSNvBImfmgIo4TQdHTijLjbFSNvBISGazlGP)mu7QbsnBITijLX4hGhblP5LKR0LIF1MaUEFleiFM0Wweb(M0ootWcJXquo5mOoCwqDiqwCGnBcNfuhcKfh53LDgaUu8R2eW17BFG8a7ydsX3K2xfCwqDiqwCKFx2zaSIYKLtw5xTeuNcc0i4kDP4xTjGR33(tiH4ncwj8nP9hil2qq5B7sXVAtaxVV1I3csWk5s5sXVAtaZ8qR33kyl6JuxYee(M0EssZwirIGrz(vlbH3QW5pd6mPfzGCI5ZcIp42Sj)QLG6uqGgbLhhxPlf)QnbmZdTEF7dKJGq9dboHKji8nP9ZOzdeCqSszbbYwaL)zO2vdKCP4xTjGzEO17BnqWbXkH)J7JOUYInKc3BJVjTliq2cy6aaVvHtLruO5Nv(r4cbZuWyi60S5pd6mPf5Nv(r4cbZccKTakVGazlGR0LIF1MaM5HwVV9zeQZVAt0rguXpyqA)pqxk(vBcyMhA9(2NrOo)Qnrhzqf)GbPDccP4jOlf)QnbmZdTEFlqoX84)4(iQRSydPW924Bs8RwcQtbbAemDz7sXVAtaZ8qR33kyl6JuxYeKlf)QnbmZdTEFlqoX84)4(iQRSydPW92Uu8R2eWmp069Tw8wqcwj8nPDLruOzjtqDooDmHbc1jOmfmgIo4HTijLX4hGhblP5LK4bNfuhcKfN0bWkktwozLF1sqDkiqJGUu8R2eWmp069TWzb1Lmb5sXVAtaZ8qR33(tiH4ncwj8nPDSfjPmg)a8iyjnFM0cxk(vBcyMhA9(wiq(mPHTic8nPDLfBindKyKcmN810Ltgxk(vBcyMhA9(wlElibRKlLlf)Qnbm)h469TWfqWj6wirIGrUu8R2eW8FGR33Eyba7Wzb1TaQmMHmfxxk(vBcy(pW17BtoQnb(M0EssZwirIGrz(vlb5sXVAtaZ)bUEFlgjGKaGwSbFtApjPzlKirWOm)QLGCP4xTjG5)axVVfdnZPlTiWfFtApjPzlKirWOm)QLGCP4xTjG5)axVVvYeegAMd(M0EssZwirIGrz(vlb5sXVAtaZ)bUEF7cK6MsGq8nP9KKMTqIebJY8RwcQztLfBinRgi11PFmkD5KXLIF1MaM)dC9(2d9giRwSPJni1LIF1MaM)dC9(wdmjfhl20FwzOkMKaj8nPD(vlb1PGanckF7MnXgi0LIF1MaM)dC9(w4SG6IrX3K25xTeuNcc0iO8TB2eBGqxk(vBcy(pW17BH)SiSytxnfiHVjTZVAjOofeOrW92nB(ZGotArgiNy(SGazlGYdaxkxk(vBcygiNy(17B)jKq8gbRe(M0o2IKugJFaEeSKMptAbEWzb1HazXr(924bNfuhcKfN03LTlf)QnbmdKtm)69TWzb1Lmb5sXVAtaZa5eZVEFl8NfHfB6QPaj8nP9NHAxnqkDGCI57ccKTa6sXVAtaZa5eZVEFRbcoiwj8nPDLruOzlusemQ)di2cuTjYuWyi6GNGazlGPFweSAtiRYKbqZM4uzefA2cLebJ6)aITavBImfmgIo4jijbbbYyiYLIF1MaMbYjMF9(2hipWo2Gu8nP9NHAxnqkDGCI57ccKTa6sXVAtaZa5eZVEFleiFM0WweHlf)QnbmdKtm)69Tw8wqcwj8nP9NHAxnqkDGCI57ccKTa6s5sXVAtaZeesXtW17BtBeOtcYIUGGtWXtUu8R2eWmbHu8eC9(wqcCe42hPoA5Tt)iige6sXVAtaZeesXtW17BXqZC6JuxbsDkiqCDP4xTjGzccP4j469TBwyXX4OpsDghGeJc0LIF1MaMjiKINGR33kSKjru3Iomj)Klf)QnbmtqifpbxVVvA(fiD6moajmL6yed6sXVAtaZeesXtW17BtUimjCTythdXq1LIF1MaMjiKINGR33kioPfB6sigKG4Bs7kl2qAgiXifyp5RYJdLPztLfBindKyKcSN810LtMMnLSna1UGazlGPlNmnBQSydPz1aPUo9KV2Ltg5LTmUu8R2eWmbHu8eC9(2FINcvWkD6sigKCP4xTjGzccP4j469TkqQVeyZsC6sJ4j8nPDSfjPSGEaIiiSlnINYccKTawEys6RgYTAYIslTka]] )


end
