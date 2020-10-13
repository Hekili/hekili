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


    spec:RegisterPack( "Destruction", 20201012, [[de0JQaqiOk9iOkQnbvAusvYPKcAvev0RKQAwqvDlPaTlj9lfXWikoMuQLru6zevyAev6AauBtQs13GQiJdQcDoPaSoOkOMNuf3trTpIQoOuaLfcGhkfq1eLcixeQcYjLQuQvkH2Pe1pLQu0tPQPkf9vPkLSxr)vHbRshg1Ib6XQAYQ4YiBMiFwrA0a60uEnaz2qUnu2TWVvA4sWYj8CqtN01LkBxI8DPqJxQsHZdvSEOkW8Ls2pvoBNnt)HvkllRmYktBzAlBvwzLbpjRCtVItbk9f4hq8uk9bJrPVbIGQO7vBJ0xGXbT8jBME42jEk9avTaep8Kjtnfyhy9xSjqdRdXQTXlyjDc0W(jPhSZqAVDKGP)WkLLLvgzLPTmTLTkRSYi32ao9CNcCfP3BynWtpq7COibt)HGF6XZUBdebvr3R2gUBVflq7dixr8S72B(6csc3TTS47UYkJSYKEKbvy2m9eesXtWSzwUD2m98R2gPVXvGoLilgccUbhpLEkyqeDsasnllB2m98R2gPhJWwboJvAG6E7mocIXGPNcgerNeGuZYYr2m98R2gPheT7zSsdfinOGWWj9uWGi6KaKAwwUzZ0ZVABK(PDS4yCmwPbJhqIvbMEkyqeDsasnld4Sz65xTnsVWkuardlgWc8tPNcgerNeGuZY9E2m98R2gPxA)oiDgmEajmLgGeJLEkyqeDsasnlJNYMPNF12i9f6eMeowmDaIyOMEkyqeDsasnlJhZMPNcgerNeG0)ctjHXPxzXusRajgPahfE1DL3DXJY4UTA5UklMsAfiXif4OWRUBpURSY4UTA5Us2uG6qqySfq3Th3vwzC3wTCxLftjTQggn0Du41HSY4UY7UYvM0ZVABKEbXfSy6qcXyem1SCdiBME(vBJ0)B8uOcwPZqcXyu6PGbr0jbi1SCBzYMPNcgerNeG0)ctjHXPhStsQkOhqicchsR4PQGWylGPNF12i9kqA0fGBxCgsR4Putn9a5s7NnZYTZMPNcgerNeG0)ctjHXPhStsQcYpGocwsRNTXWDX1DHBhAabYIJ7k)S722DX1DHBhAabYIJ72ZS7k30ZVABK(FdjepvWkLAww2Sz65xTnspC7qdjtqPNcgerNeGuZYYr2m9uWGi6KaK(xykjmo9kJOqRwOKiy04xmWoOABuPGbr0XDX1DfegBb0D7XDpDcwTnCx50DLPcy3Tvl3fVURYik0Qfkjcgn(fdSdQ2gvkyqeDCxCDxbjjiiqgerPNF12i9gg2IyLsnll3Sz6PGbr0jbi9VWusyC6FgQd1Wi3Th3fixA)HGWylGPNF12i9pqEHdWfPPMLbC2m98R2gPhcKpBJGDIi9uWGi6KaKAwU3ZMPNcgerNeG0)ctjHXP)zOoudJC3ECxGCP9hccJTaME(vBJ0BXBbjyLsn10xqq)IbYA2ml3oBME(vBJ0d7WW2yyyfspfmiIojaPMLLnBMEkyqeDsas)lmLegNELruO1PcdBnbnwPbKFHjzpvPGbr0j98R2gPFQWWwtqJvAa5xys2tPMLLJSz65xTnsFHvTnspfmiIojaPMLLB2m98R2gPhUDOHKjO0tbdIOtcqQzzaNntpfmiIojaP)fMscJtpEDxLruOv42HgsMGQuWGi6KE(vBJ0BXBbjyLsn10ZlLnZYTZMPNcgerNeG0)ctjHXPVaPvlKirWOk)QvICxCD3E5U41D)DrNTXOcKlTFvq8bh3Tvl3LF1krdkimJGUR8URC4Unm98R2gPxWwmwPHKjOuZYYMntpfmiIojaP)fMscJt)z1QHHTiwPQGWylGUR8U7ZqDOggLE(vBJ0)a5ii04qyBizck1SSCKntpfmiIojaPNF12i9gg2IyLs)lmLegNEbHXwaD3ECxa7U46U9YDXR7QmIcT(SYpchiwLcgerh3Tvl393fD2gJ6Zk)iCGyvbHXwaDx5DxbHXwaD3gM(hNhrdLftjfMLBNAwwUzZ0tbdIOtcq65xTns)Zi0GF12yGmOMEKb1rWyu6)dm1SmGZMPNcgerNeG0ZVABK(NrOb)QTXazqn9idQJGXO0tqifpbtnl37zZ0tbdIOtcq65xTnspqU0(P)X5r0qzXusHz52PMLXtzZ0ZVABKEbBXyLgsMGspfmiIojaPMLXJzZ0tbdIOtcq65xTnspqU0(P)X5r0qzXusHz52PMLBazZ0tbdIOtcq6FHPKW40RmIcTkzcAWXzakmmOUbvPGbr0XDX1Db7KKQG8dOJGL0Axb3fx3fUDObeiloUBpUlGD3g0DLPkR7kNUl)QvIguqygbtp)QTr6T4TGeSsPMLBlt2m98R2gPhUDOHKjO0tbdIOtcqQz52TZMPNcgerNeG0)ctjHXPhStsQcYpGocwsRNTXi98R2gP)3qcXtfSsPMLBlB2m9uWGi6KaK(xykjmo9klMsAfiXifyTWRUBpURSYKE(vBJ0dbYNTrWorKAwUTCKntp)QTr6T4TGeSsPNcgerNeGutn9)bMnZYTZMPNF12i9WomSngwirIGrPNcgerNeGuZYYMntp)QTr6pSaqd42Hgwavg0qMIt6PGbr0jbi1SSCKntpfmiIojaP)fMscJtFbsRwirIGrv(vReLE(vBJ0xyvBJuZYYnBMEkyqeDsas)lmLegN(cKwTqIebJQ8Rwjk98R2gPhKeqsailMMAwgWzZ0tbdIOtcq6FHPKW40xG0QfsKiyuLF1krPNF12i9GODpdPoboPML79Sz6PGbr0jbi9VWusyC6lqA1cjsemQYVALO0ZVABKEjtqGODpPMLXtzZ0tbdIOtcq6FHPKW40xG0QfsKiyuLF1krUBRwURYIPKwvdJg6oog5U94UYkt65xTnsFhKgMsyWuZY4XSz65xTns)HEdJvlMoaxKMEkyqeDsasnl3aYMPNcgerNeG0)ctjHXPNF1krdkimJGUR8UBB3Tvl3fCHW0ZVABKEdRafhlMoEwzOk2caPuZYTLjBMEkyqeDsas)lmLegNE(vRenOGWmc6UY7UTD3wTCxWfctp)QTr6HBhAiwn1SC72zZ0ZVABKE4VDclMoutbsPNcgerNeGutn9hsI7qA2ml3oBME(vBJ0dlqi0aTpGspfmiIojaPMLLnBME(vBJ0dTyknW4P2NEkyqeDsasnllhzZ0tbdIOtcq6FHPKW40dKlT)GF1krUlUUl)QvIguqygbD3ECxa7UnO7QmIcTAHejITsbdIOJ723D7L7QmIcTAHejITsbdIOJ7IR7QmIcTAHsIGrJFXa7GQTrLcgerh3THPNF12i9pJqd(vBJbYGA6rguhbJrPhixA)uZYYnBMEkyqeDsas)lmLegNE86U9YDlqA1cjsemQYVALi3fx39SA1WWweRuvqySfq3TV722DL3DlqA1cjsemQkim2cO72q3Tvl3fwGqOHYIPKcRpR8JWbI5UY7UTtp)QTr6Fw5hHdel1SmGZMPNcgerNeG0)ctjHXPNF1krdkimJGUR8URSPNF12i9pJqd(vBJbYGA6rguhbJrPNxk1SCVNntpfmiIojaPNF12i9WTdnKmbL(xykjmo9cssqqGmiICxCDx42HgqGS44U9m7UY1DX1D7L7Ix3vzefA9zLFeoqSkfmiIoUBRwU7Vl6Sng1Nv(r4aXQccJTa6UY7UccJTa6Unm9popIgklMskml3o1SmEkBMEkyqeDsasp)QTr6nmSfXkL(xykjmo9cssqqGmiICxCD3E5U41DvgrHwFw5hHdeRsbdIOJ72QL7(7IoBJr9zLFeoqSQGWylGUR8URGWylGUBdt)JZJOHYIPKcZYTtnlJhZMPNcgerNeG0)ctjHXPxzefA1cLebJg)Ib2bvBJkfmiIoUlUUl)QTr9bYlCaUiTAXqcztbQUlUURGWylGUBpU7PtWQTH7kNURmvaNE(vBJ0ByylIvk1SCdiBMEkyqeDsasp)QTr6FgHg8R2gdKb10JmOocgJs)FGPMLBlt2m9uWGi6KaKE(vBJ0)mcn4xTngidQPhzqDemgLEccP4jyQz52TZMPNF12i9pqoccnoe2gsMGspfmiIojaPMLBlB2m9uWGi6KaKE(vBJ0dKlTF6FHPKW40FwTAyylIvQkim2cO7kV7EwTAyylIvQE6eSAB4UYP7ktfWUBRwUlEDxLruOvlusemA8lgyhuTnQuWGi6K(hNhrdLftjfMLBNAwUTCKntpfmiIojaPFlKEiPPNF12i9LyHXGik9LyuhLE(vRenOGWmc6UY7UTDxCD3Fx0zBmQa5s7xfegBb0D7z2DBlJ72QL7(7IoBJrf2HHTXWcjsemQkim2cO72ZS72gWUlUURYik06HfaAa3o0WcOYGgYuCQuWGi64U46U)UOZ2yupSaqd42Hgwavg0qMItvqySfq3TNz3TnGD3wTCxLruO1dla0aUDOHfqLbnKP4uPGbr0XDX1D)DrNTXOEybGgWTdnSaQmOHmfNQGWylGUBpZUBBa7U46U9YD)DrNTXOc7WW2yyHejcgvfegBb0DL3DvwmL0QAy0q3XXi3Tvl393fD2gJkSddBJHfsKiyuvqySfq3TV7(7IoBJrf2HHTXWcjsemQE6eSAB4UY7UklMsAvnmAO74yK72W0xIfJGXO0xyx0aUDObeiloWuZYTLB2m9uWGi6KaK(xykjmo9GDssvq(b0rWsA9SngUlUUlC7qdiqwCCx5ND32va7UnO7ktvoCx50DvgrHwLqme4wIevkyqeDCxCDx86ULyHXGiQwyx0aUDObeiloW0ZVABK(FdjepvWkLAwUnGZMPNcgerNeG0)ctjHXPhStsQEybGgWTdnSaQmOHmfNAxH0ZVABK(hiVWb4I0uZYT79Sz6PGbr0jbi9VWusyC6b7KKQG8dOJGL0Axb3fx3fVUBjwymiIQf2fnGBhAabYId0DX1DXR7QmIcTsc(ypR2gvkyqeDsp)QTr6FG8chGlstnl3gpLntpfmiIojaP)fMscJtpED3sSWyqevlSlAa3o0acKfhO7IR7QmIcTsc(ypR2gvkyqeDCxCD3E5UhcStsQsc(ypR2gvbHXwaD3EC3NH6qnmYDB1YDb7KKQG8dOJGL0Axb3THPNF12i9pqEHdWfPPMLBJhZMPNcgerNeG0)ctjHXPhVUBjwymiIQf2fnGBhAabYId0DB1YDHBhAabYIJ7k)S7k3kGtp)QTr6Ha5Z2iyNisnl3UbKntpfmiIojaP)fMscJtFVCx42HgqGS44UYp7UYTcy3TbDxzQY6UYP7YVALObfeMrq3THPNF12i9pqEHdWfPPMLLvMSz6PGbr0jbi9VWusyC6FGSykbDx5D32PNF12i9)gsiEQGvk1SSSTZMPNF12i9w8wqcwP0tbdIOtcqQPMA6lrcOTrwwwzKvgzAaYi3A703ilclMctFVnwHvO0XD7D3LF12WDrguHvxX0dlqFww2EhpL(cIvYqu6XZUBdebvr3R2gUBVflq7dixr8S72B(6csc3TTS47UYkJSY4k6kINDx8q9g03P0XDbjPvqU7VyGS6UG0ulGv3Tb2)ubf6UXgniqwGj1HCx(vBdO7UbcNQRi)QTbSwqq)IbY6mSddBJrbsDf5xTnG1cc6xmqw7ppzQWWwtqJvAa5xys2t4BsZkJOqRtfg2AcASsdi)ctYEQsbdIOJRi)QTbSwqq)IbYA)5jfw12WvKF12awliOFXazT)8e42HgsMGCf5xTnG1cc6xmqw7ppXI3csWkHVjnJxLruOv42HgsMGQuWGi64k6kINDx8q9g03P0XDPsKah3vnmYDvGK7YVUc31GUlxInedIOQRi)QTbCgwGqObAFa5kYVABa7ppbAXuAGXtT3v0vKF12a2FEYZi0GF12yGmOIFWy0mqU0(4BsZa5s7p4xTseU8RwjAqbHzeSha3GkJOqRwirIyRuWGi60VxkJOqRwirIyRuWGi6GRYik0Qfkjcgn(fdSdQ2gvkyqeDAORi)QTbS)8KNv(r4aXW3KMXBVkqA1cjsemQYVALiCpRwnmSfXkvfegBbSFB5lqA1cjsemQkim2cydB1cwGqOHYIPKcRpR8JWbIjFBxr(vBdy)5jpJqd(vBJbYGk(bJrZ8s4BsZ8RwjAqbHzeuEzDf5xTnG9NNa3o0qYee(popIgklMskCUn(M0SGKeeeidIiCHBhAabYItpZYf3EHxLruO1Nv(r4aXQuWGi60Q1Vl6Sng1Nv(r4aXQccJTakVGWylGn0vKF12a2FEIHHTiwj8FCEenuwmLu4CB8nPzbjjiiqger42l8QmIcT(SYpchiwLcgerNwT(DrNTXO(SYpchiwvqySfq5fegBbSHUI8R2gW(ZtmmSfXkHVjnRmIcTAHsIGrJFXa7GQTrLcgerhC5xTnQpqEHdWfPvlgsiBkqfxbHXwa750jy12qoLPcyxr(vBdy)5jpJqd(vBJbYGk(bJrZ)b6kYVABa7pp5zeAWVABmqguXpymAMGqkEc6kYVABa7pp5bYrqOXHW2qYeKRi)QTbS)8eGCP9X)X5r0qzXusHZTX3KMpRwnmSfXkvfegBbu(ZQvddBrSs1tNGvBd5uMkGB1cVkJOqRwOKiy04xmWoOABuPGbr0XvKF12a2FEsjwymiIWpymAUWUObC7qdiqwCG4xIrD0m)QvIguqygbLVnU)UOZ2yubYL2Vkim2cypZTLPvRFx0zBmQWomSngwirIGrvbHXwa7zUnGXvzefA9WcanGBhAybuzqdzkovkyqeDW93fD2gJ6HfaAa3o0WcOYGgYuCQccJTa2ZCBa3QLYik06HfaAa3o0WcOYGgYuCQuWGi6G7Vl6Sng1dla0aUDOHfqLbnKP4ufegBbSN52ag3E97IoBJrf2HHTXWcjsemQkim2cO8klMsAvnmAO74yuRw)UOZ2yuHDyyBmSqIebJQccJTa2)3fD2gJkSddBJHfsKiyu90jy12qELftjTQggn0DCmQHUI8R2gW(Zt(nKq8ubRe(M0myNKufKFaDeSKwpBJbUWTdnGazXr(52va3GYuLd5uzefAvcXqGBjsuPGbr0bx8wIfgdIOAHDrd42HgqGS4aDf5xTnG9NN8a5foaxKIVjnd2jjvpSaqd42Hgwavg0qMItTRGRi)QTbS)8KhiVWb4Iu8nPzWojPki)a6iyjT2vax8wIfgdIOAHDrd42HgqGS4aXfVkJOqRKGp2ZQTrLcgerhxr(vBdy)5jpqEHdWfP4BsZ4Telmger1c7IgWTdnGazXbIRYik0kj4J9SABuPGbr0b3EDiWojPkj4J9SABufegBbSNNH6qnmQvlWojPki)a6iyjT2vOHUI8R2gW(ZtGa5Z2iyNiW3KMXBjwymiIQf2fnGBhAabYIdSvl42HgqGS4i)SCRa2vKF12a2FEYdKx4aCrk(M0CVGBhAabYIJ8ZYTc4guMQSYj)QvIguqygbBORi)QTbS)8KFdjepvWkHVjn)azXuckFBxr(vBdy)5jw8wqcwjxrxr(vBdyLxQ)8ebBXyLgsMGW3KMlqA1cjsemQYVALiC7fE)DrNTXOcKlTFvq8bNwT4xTs0GccZiO8YrdDf5xTnGvEP(ZtEGCeeACiSnKmbHVjnFwTAyylIvQkim2cO8pd1HAyKRi)QTbSYl1FEIHHTiwj8FCEenuwmLu4CB8nPzbHXwa7bW42l8QmIcT(SYpchiwLcgerNwT(DrNTXO(SYpchiwvqySfq5fegBbSHUI8R2gWkVu)5jpJqd(vBJbYGk(bJrZ)b6kYVABaR8s9NN8mcn4xTngidQ4hmgntqifpbDf5xTnGvEP(ZtaYL2h)hNhrdLftjfo3gFtIF1krdkimJG9ixxr(vBdyLxQ)8ebBXyLgsMGCf5xTnGvEP(ZtaYL2h)hNhrdLftjfo32vKF12aw5L6ppXI3csWkHVjnRmIcTkzcAWXzakmmOUbvPGbr0bxWojPki)a6iyjT2vax42HgqGS40dGBqzQYkN8RwjAqbHze0vKF12aw5L6ppbUDOHKjixr(vBdyLxQ)8KFdjepvWkHVjnd2jjvb5hqhblP1Z2y4kYVABaR8s9NNabYNTrWorGVjnRSykPvGeJuG1cV2JSY4kYVABaR8s9NNyXBbjyLCfDf5xTnG1)a7ppb2HHTXWcjsemYvKF12aw)dS)8Kdla0aUDOHfqLbnKP44kYVABaR)b2FEsHvTnW3KMlqA1cjsemQYVALixr(vBdy9pW(ZtajbKeaYIP4BsZfiTAHejcgv5xTsKRi)QTbS(hy)5jGODpdPobo4BsZfiTAHejcgv5xTsKRi)QTbS(hy)5jsMGar7EW3KMlqA1cjsemQYVALixr(vBdy9pW(Zt6G0WucdIVjnxG0QfsKiyuLF1krTAPSykPv1WOHUJJr9iRmUI8R2gW6FG9NNCO3Wy1IPdWfPUI8R2gW6FG9NNyyfO4yX0XZkdvXwaiHVjnZVALObfeMrq5B3Qf4cHUI8R2gW6FG9NNa3o0qSk(M0m)QvIguqygbLVDRwGle6kYVABaR)b2FEc83oHfthQPajxrxr(vBdyfixA)(Zt(nKq8ubRe(M0myNKufKFaDeSKwpBJbUWTdnGazXr(524c3o0acKfNEMLRRi)QTbScKlTF)5jWTdnKmb5kYVABaRa5s73FEIHHTiwj8nPzLruOvlusemA8lgyhuTnQuWGi6GRGWylG9C6eSABiNYubCRw4vzefA1cLebJg)Ib2bvBJkfmiIo4kijbbbYGiYvKF12awbYL2V)8KhiVWb4Iu8nP5NH6qnmQhGCP9hccJTa6kYVABaRa5s73FEceiF2gb7eHRi)QTbScKlTF)5jw8wqcwj8nP5NH6qnmQhGCP9hccJTa6k6kYVABaReesXtW(ZtACfOtjYIHGGBWXtUI8R2gWkbHu8eS)8emcBf4mwPbQ7TZ4iigd6kYVABaReesXtW(Ztar7EgR0qbsdkimCCf5xTnGvccP4jy)5jt7yXX4ySsdgpGeRc0vKF12awjiKING9NNiScfq0WIbSa)KRi)QTbSsqifpb7pprA)oiDgmEajmLgGeJ5kYVABaReesXtW(Ztk0jmjCSy6aeXq1vKF12awjiKING9NNiiUGfthsigJG4BsZklMsAfiXif4OWRYJhLPvlLftjTcKyKcCu41EKvMwTKSPa1HGWylG9iRmTAPSykPv1WOHUJcVoKvg5LRmUI8R2gWkbHu8eS)8KFJNcvWkDgsigJCf5xTnGvccP4jy)5jkqA0fGBxCgsR4j8nPzWojPQGEaHiiCiTINQccJTaMAQzc]] )


end
