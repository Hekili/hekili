-- WarlockDestruction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
            end,
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
            cooldown = 180,
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
            cast = 1.5,
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


    spec:RegisterPack( "Destruction", 20200904.1, [[dWuKQbqijQEKeQ2KQOpHIcgfGYPauTkjuYROGMfkPBjbWUK0VOOAyQcogkLLjr5zOOAAQc11uL02KqX3KaLXjbOZHIsTojqvMNe09qH9jHCquueleLQhQketucL6IOOqBefL0hrrjmsjqLtkb0kbKzIIIe3ucuv2jfLFIIIKgQeOQAPQcP8uGMkf4QOOi1xvfs1Er1FP0Gv5WelMuEmjtwjxgzZQQplrgnaNMQvRkK8AvjMnu3wP2TWVLA4uOJJIs0Yb9Citx01jvBxvQVJsmEuuuNhfz9sGmFkY(vmNnUbCWLKe3SYEOShEGz)WJRSvWk7Xp(XCWKjJeh0OOErkrCWq2ehSytOeQRsVdoOrHjCllUbCquRdveheqMgrf8m38sEcqxRQ6T5iFRJL07qbLFAoY3kZ5GA6oolWGRXbxssCZk7HYE4bM9dpUYwbJnM9dVYbf9eqd5GG((r4Ga81IcUghCrifhS4ZvSjuc1vP3XCp6ce3QxgGk(CaY0iQGN5MxYta6AvvVnh5BDSKEhkO8tZr(wz(auXNdij0fitZvgBSoxzpu2dCqSJse3aoyPgPB06XNGHG5gWnJnUbCqkenmT4SZbvqpjOlCquRJTiacCnhJ5EDUNZv(CA6)FvtuVSGYpR6gN75CA6)FDt7gYKT)wSUYx2fKKnQQBKdkQ07GdcfpS93(DiXtUzLXnGdsHOHPfNDoOc6jbDHdQP))vnr9Yck)SQBKdkQ07GdQainYQ14KNCZyo3aoifIgMwC25GkONe0foiQ1XweabUMRigZ94AzZvaMtt))RBA3qMS93I1v(YUGKSrvDJCqrLEhCqfaPrwTgN8KB2J5gWbPq0W0IZohub9KGUWblFov34vZsuvD8XsjOKuv3ihuuP3bhubqAKvRXjp5M9k3aoifIgMwC25GkONe0foOsqPn9nnxHZzKYQhFcgcUcPT4bAUNZzKYQhFcgcUcPT4bAUcNtjO0M(MMZW5kPwCqrLEhCqfaPrwTgN8KBwXWnGdsHOHPfNDoOc6jbDHdQP))vnr9Yck)SUAwI5EoNM()x30UHmz7VfRR8LDbjzJQ6gN75COwhBrae4AUIymhBvMZbfv6DWbvD8XsjOKep5MvW4gWbPq0W0IZohub9KGUWb10))QMOEzbLFwxnlXCpNR8500))6M2nKjB)TyDLVSlijBuv34CpNdyZHADSfbqGR5kIXCLvlGZzY0CkacSeHSFOOsVdbpxrZXwLzp3Z5qTo2IaiW1CfXyo2QmFoGZbfv6DWbvD8XsjOKep5Mva5gWbPq0W0IZohub9KGUWbnsz1JpbdbxH0w8anxHZ9khuuP3bhu1XhlLGss8KBgZMBahKcrdtlo7Cqf0tc6chubqGLi0CfnhBCqrLEhCqvhFSuckjXtUzS9a3aoOOsVdoiQ1X2VdjoifIgMwC25j3m2yJBahuuP3bhebqwnlA6WGdsHOHPfNDEYnJTY4gWbfv6DWb9q5bbLK4GuiAyAXzNN8KdcqE3kUbCZyJBahKcrdtlo7Cqf0tc6chut))RAI6Lfu(zD1SeZ9CouRJTiacCnxrmMJT5EohQ1XweabUMRqgZ9yoOOsVdoOQJpwkbLK4j3SY4gWbPq0W0IZohub9KGUWbtbtrw9ijyiyRQ3A6O07OsHOHP1CpNdsBXd0Cfo3shkP3XCfR5EO(6CMmnx5ZLcMIS6rsWqWwvV10rP3rLcrdtR5EohK(qcbq0WehuuP3bh037gljXtUzmNBahKcrdtlo7Cqf0tc6chujO0M(MMRW5aiVBLfsBXdehuuP3bhubqAKvRXjp5M9yUbCqrLEhCquRJTFhsCqkenmT4SZtUzVYnGdsHOHPfNDoOc6jbDHdkQ0FtwkOTtO5kCoMpNjtZv(CPGPiRFhswjwwnOVrzhuLcrdtloOOsVdoicGSAw00Hbp5MvmCd4GuiAyAXzNdQGEsqx4GkbL2030Cfoha5DRSqAlEG4GIk9o4GEO8GGss8KNCqJqs1Bnj5gWnJnUbCqrLEhCqK(E3H13g5GuiAyAXzNNCZkJBahKcrdtlo7Cqf0tc6chmfmfzTe03TdjB)Tirb9VROkfIgMwCqrLEhCWsqF3oKS93Ief0)UI4j3mMZnGdkQ07GdAStVdoifIgMwC25j3ShZnGdkQ07GdIADS97qIdsHOHPfNDEYn7vUbCqkenmT4SZbvqpjOlCWYNlfmfzf16y73HuLcrdtloOOsVdoOhkpiOKep5jhuAIBa3m24gWbPq0W0IZohub9KGUWbnsz1Jpbdbxfv6VP5EohWMtt))RkOGa4rjRcG0O6QzjMZKP5kFUuWuKvO4HT)wfaPrvkenmTMd4Z9CoGnx5ZP6gVAwIka5DRQqswmnNjtZjQ0FtwkOTtO5kAoMphW5GIk9o4GqXdB)TFhs8KBwzCd4GuiAyAXzNdQGEsqx4GRoR(E3yjPkK2IhO5kAoLGsB6BIdkQ07GdQairqy7I2D8DiXtUzmNBahKcrdtlo7CqrLEhCqFVBSKehub9KGUWbH0w8anxHZ96CpNdyZv(CPGPiRkjffMj0UsHOHP1CMmnNQB8QzjQkjffMj0UcPT4bAUIMdsBXd0CaNdQysHjBkWsuI4MXgp5M9yUbCqkenmT4SZbfv6DWbvcgBfv6DyXok5GyhL2q2ehuTq8KB2RCd4GuiAyAXzNdkQ07GdcqE3koOc6jbDHdkQ0FtwkOTtO5kCUhZbvmPWKnfyjkrCZyJNCZkgUbCqkenmT4SZbvqpjOlCWuWuKvO4HT)wfaPrvkenmTM75CgPS6XNGHGRIk930CpNdyZbqE3kROs)nnNjtZLcMISQKuuyMq7kfIgMwZzY0CPGPiRE8jy0vkenmTM75CIk93KLcA7eAUcN7XZbCoOOsVdoOcG0iRwJtEYnRGXnGdkQ07GdcfpS93(DiXbPq0W0IZop5Mva5gWbfv6DWb)TshrlRuqe0tYQrYMdsHOHPfNDEYnJzZnGdkQ07GdAuh6FM8OKvdlOKdsHOHPfNDEYnJTh4gWbPq0W0IZohuuP3bheG8UvCqf0tc6cheyZv(CPGPiRqXdB)TkasJQuiAyAnNjtZv(CPGPiRE8jy0vkenmTMZKP5sbtrwHIh2(BvaKgvPq0W0AUNZzKYQhFcgcUcPT4bAUczmhBpmhW5GkMuyYMcSeLiUzSXtUzSXg3aoifIgMwC25GkONe0foykykY63HKvILvd6Bu2bvPq0W0AUNZPP))vnr9Yck)SQBCUNZHADSfbqGR5kCUxNRam3d1YMRynNOs)nzPG2oH4GIk9o4GEO8GGss8KBgBLXnGdkQ07GdIADS97qIdsHOHPfNDEYnJnMZnGdsHOHPfNDoOc6jbDHdQP))vnr9Yck)SUAwcoOOsVdoOQJpwkbLK4j3m2Em3aoifIgMwC25GkONe0foy5ZLcMIS(DizLyz1G(gLDqvkenmT4GIk9o4GiaYQzrthg8KBgBVYnGdsHOHPfNDoOc6jbDHdw(CRoRQouuKqjPL9JLnz10HrfsBXd0CpNR85ev6DuvDOOiHssl7hlBQ6H9J9saY5EoNOs)nzPG2oHMRW5ELdkQ07GdQ6qrrcLKw2pw2ep5MXwXWnGdkQ07Gd6HYdckjXbPq0W0IZop5jhuTqCd4MXg3aoifIgMwC25GkONe0foykykYku8W2FRcG0OkfIgMwZ9CoiTfpqZv4CfW5EoNQB8QzjQi99UdRhFcgcUcPT4bAUcN7X1x5GIk9o4G(E3yjjEYnRmUbCqkenmT4SZbvqpjOlCWuWuKvO4HT)wfaPrvkenmTM75CQUXRMLOI037oSE8jyi4kK2IhO5kCUhxFDUNZv(CA6)FvtuVSGYpR6gN75COwhBrae4AUcN7XvMZbfv6DWbvD8XsjOKep5MXCUbCqkenmT4SZbfv6DWbLccbqGcY(7iT93ASzHGCqf0tc6chu1nE1SevK(E3H1Jpbdbx1noNjtZP6gVAwIksFV7W6XNGHGRqAlEGMRqgZ9yoyiBIdkfecGafK93rA7V1yZcb5j3ShZnGdkQ07GdI037oSE8jyiyoifIgMwC25j3Sx5gWbPq0W0IZohub9KGUWbnsz1Jpbdbxfv6VjoOOsVdoyjDbUCjS93kfeb7eap5MvmCd4GuiAyAXzNdQGEsqx4GgPS6XNGHGRIk930CpNdyZzKYQhFcgcUcPT4bAUcNRShQVoNjtZzKYQhFcgcUcPT4bAUcNRSYM75COwhBrae4AUIymhZRfZCMmnx5ZLcMIScfpS93QainQsHOHP1CaNdkQ07GdUe4lwuRJTEGsrZXEYep5MvW4gWbPq0W0IZohub9KGUWbnsz1Jpbdbxfv6VP5EohWMZiLvp(emeCfsBXd0CfohBVwFDotMMd16ylcGaxZv4CmV(6CpNdyZPP))1LaFXIADS1dukAo2tMQ6gNZKP5kFUuWuKvO4HT)wfaPrvkenmTM75CRoR(E3yjPkK2IhO5kAo2kBoGphW5GIk9o4GBA3qMS93I1v(YUGKSr8KBwbKBahKcrdtlo7Cqf0tc6chm9nzZ2UCAUIMt1nE1SevK(E3H1Jpbdbxx6qj9oMZW5y(dCqrLEhCqK(E3H1JpbdbZtUzmBUbCqkenmT4SZbvqpjOlCW030CfnhZFyUNZL(MSzBxonxrZP6gVAwIAjDbUCjS93kfeb7eqDPdL07yodNJ5pWbfv6DWblPlWLlHT)wPGiyNa4j3m2EGBahKcrdtlo7Cqf0tc6chmfmfzDjWxSOwhB9aLIMJ9KPkfIgMwZ9Cov34vZsuxc8flQ1XwpqPO5ypzQcPT4bAUIMlfyjkRPVjB22LtCqrLEhCqK(E3H1JpbdbZtUzSXg3aoifIgMwC25GkONe0foOQB8QzjQi99UdRhFcgcUcPT4bAUIMl9nzZ2UCIdkQ07GdwsxGlxcB)TsbrWobWtUzSvg3aoifIgMwC25GkONe0foOQB8QzjQi99UdRhFcgcUcPT4bAUIMl9nzZ2UCAUNZzKYQhFcgcUcPT4bAUcNRShQVYbfv6DWbxc8flQ1XwpqPO5ypzINCZyJ5Cd4GuiAyAXzNdQGEsqx4GQUXRMLOI037oSE8jyi4kK2IhO5kAU03KnB7YP5EoNrkRE8jyi4kK2IhO5kCo2kG1x5GIk9o4GS0q86n5HfsOoKqr8KBgBpMBahKcrdtlo7Cqf0tc6chu1nE1SevK(E3H1JpbdbxH0w8anxrZL(MSzBxon3Z5a2CgPS6XNGHGRqAlEGMRW5y716RZzY0CA6)FDjWxSOwhB9aLIMJ9KPQUX5EohQ1XweabUMRW5y(CaNdkQ07GdUPDdzY2Flwx5l7csYgXtUzS9k3aoifIgMwC25GkONe0foy6BYMTD50CfohZFGdkQ07GdI037oSE8jyiyEYnJTIHBahKcrdtlo7Cqf0tc6chm9nzZ2UCAUcNJ5pWbfv6DWblPlWLlHT)wPGiyNa4j3m2kyCd4GuiAyAXzNdQGEsqx4GPVjB22LtZv4CLX2CpNl9nzZ2UCAUIM7XCqrLEhCWLaFXIADS1dukAo2tM4j3m2kGCd4GuiAyAXzNdQGEsqx4GPVjB22LtZv4CSvmZ9CU03KnB7YP5kAUIHdkQ07GdUPDdzY2Flwx5l7csYgXtUzSXS5gWbPq0W0IZohub9KGUWbtFt2STlNMRW5yJzp3Z5sFt2STlNMRO5EmhuuP3bhKLgIxVjpSqc1HekINCZk7bUbCqkenmT4SZbvqpjOlCW03KnB7YP5kCo2kM5Eox6BYMTD50CfnxXWbfv6DWb30UHmz7VfRR8LDbjzJ4j3SYyJBahuuP3bhud39Y2FBcGSuqBM4GuiAyAXzNNCZkRmUbCqkenmT4SZbvqpjOlCqv34vZsur67Dhwp(emeCfsBXd0CfXyUI5H5kaZXwzZ9CUYNZiLvp(emeCvuP)M4GIk9o4GS0q86n5HfsOoKqr8KBwzmNBahuuP3bhe6gnIjRhwKrrrCqkenmT4SZtUzL9yUbCqkenmT4SZbvqpjOlCqJuw94tWqWvrL(BAotMMl9nzZ2UCAUcNJ5pWbfv6DWbn2P3bp5Mv2RCd4GuiAyAXzNdQGEsqx4GgPS6XNGHGRIk930CpNdyZv(CPGPiRqXdB)TkasJQuiAyAnNjtZbS5kFocHOqr1nTBit2(BX6kFzxqs2O6wEunCotMMtt))RBA3qMS93I1v(YUGKSrviTfpqZb85EohWMR85sbtrwxc8flQ1XwpqPO5ypzQsHOHP1CMmnNM()xxc8flQ1XwpqPO5ypzQcPT4bAoGphWNZKP5sFt2STlNMRqgZX2RCqrLEhCqncIi4lEuINCZkRy4gWbPq0W0IZohub9KGUWbnsz1Jpbdbxfv6VP5EohWMR85sbtrwHIh2(BvaKgvPq0W0AotMMdyZv(CecrHIQBA3qMS93I1v(YUGKSr1T8OA4CMmnNM()x30UHmz7VfRR8LDbjzJQqAlEGMd4Z9CoGnx5ZLcMISUe4lwuRJTEGsrZXEYuLcrdtR5mzAon9)VUe4lwuRJTEGsrZXEYufsBXd0CaFoGpNjtZL(MSzBxonxHmMJTx5GIk9o4GA4Ux2VoKjEYnRScg3aoifIgMwC25GkONe0foOrkRE8jyi4QOs)nn3Z5a2CLpxkykYku8W2FRcG0OkfIgMwZzY0CaBUYNJqikuuDt7gYKT)wSUYx2fKKnQULhvdNZKP500))6M2nKjB)TyDLVSlijBufsBXd0CaFUNZbS5kFUuWuK1LaFXIADS1dukAo2tMQuiAyAnNjtZPP))1LaFXIADS1dukAo2tMQqAlEGMd4Zb85mzAU03KnB7YP5kKXCS9khuuP3bh87qsd39INCZkRaYnGdsHOHPfNDoOc6jbDHdAKYQhFcgcUkQ0FtZ9CoGnx5ZLcMIScfpS93QainQsHOHP1CMmnNrkRE8jyi4kK2IhO5kKXCL9WCaFotMMl9nzZ2UCAUczmxzpWbfv6DWb1rK1tAJ4j3SYy2Cd4GuiAyAXzNdkQ07GdASvVqjYliAzv92OEkP3HDrVDfXbvqpjOlCWvNvFVBSKufsBXd0CfXyUxN75CaBov34vZsur67Dhwp(emeCfsBXd0CfXyUYEyotMMl9nzZ2UCAUcNJ5pmhW5GHSjoOXw9cLiVGOLv1BJ6PKEh2f92vep5MX8h4gWbPq0W0IZohuuP3bhe2PcQJsAzF39QB7QXyoOc6jbDHdU6S67DJLKQqAlEGMRigZ96CpNdyZP6gVAwIksFV7W6XNGHGRqAlEGMRigZv2dZzY0CPVjB22LtZv4Cm)H5aohmKnXbHDQG6OKw23DV62UAmMNCZyoBCd4GuiAyAXzNdkQ07GdIa4VjO9nf92cjSR4GkONe0fo4QZQV3nwsQcPT4bAUIym3RZ9CoGnNQB8QzjQi99UdRhFcgcUcPT4bAUIymxzpmNjtZL(MSzBxonxHZX8hMd4CWq2ehebWFtq7Bk6TfsyxXtUzmVmUbCqkenmT4SZbfv6DWbfML6UXoPiTHONowhXbvqpjOlCWvNvFVBSKufsBXd0CfXyUxN75CaBov34vZsur67Dhwp(emeCfsBXd0CfXyUYEyotMMl9nzZ2UCAUcNJ5pmhW5GHSjoOWSu3n2jfPne90X6iEYnJ5mNBahKcrdtlo7CqrLEhCW0xekB42Q6fXmZbvqpjOlCWvNvFVBSKufsBXd0CfXyUxN75CaBov34vZsur67Dhwp(emeCfsBXd0CfXyUYEyotMMl9nzZ2UCAUcNJ5pmhW5GHSjoy6lcLnCBv9IyM5j3mM)yUbCqkenmT4SZbfv6DWbF7c22FlkB4gXbvqpjOlCWvNvFVBSKufsBXd0CfXyUxN75CaBov34vZsur67Dhwp(emeCfsBXd0CfXyUYEyotMMl9nzZ2UCAUcNJ5pmhW5GHSjo4BxW2(Brzd3iEYto4I(Ioo5gWnJnUbCqrLEhCqKrcJT4w9chKcrdtlo78KBwzCd4GIk9o4Gipkr2TuYvCqkenmT4SZtUzmNBahKcrdtlo7Cqf0tc6cheG8UvwrL(BAUNZjQ0FtwkOTtO5kCUxNRamxkykYQhFcgDLcrdtR5mCoGnxkykYQhFcgDLcrdtR5EoxkykYQhjbdbBv9wthLEhvkenmTMd4CqrLEhCqLGXwrLEhwSJsoi2rPnKnXbbiVBfp5M9yUbCqkenmT4SZbvqpjOlCWYNdyZzKYQhFcgcUkQ0FtZ9CUvNvFVBSKufsBXd0CgohBZv0CgPS6XNGHGRqAlEGMd4ZzY0CiJegBtbwIsuvjPOWmH2Zv0CSnNjtZv(CPGPiRqXdB)TkasJQuiAyAXbfv6DWbvskkmtOnp5M9k3aoifIgMwC25GkONe0foOOs)nzPG2oHMRO5kJdkQ07GdQem2kQ07WIDuYbXokTHSjoO0ep5MvmCd4GuiAyAXzNdkQ07Gd67DJLK4GkONe0foiK(qcbq0W0CpNdyZv(CPGPiRkjffMj0UsHOHP1CMmnNQB8QzjQkjffMj0UcPT4bAUIMdsBXd0CaNdQysHjBkWsuI4MXgp5MvW4gWbPq0W0IZohub9KGUWbtbtrw9ijyiyRQ3A6O07OsHOHP1CpNtuP3rvbqAKvRXz1d7h7LaKZ9CoiTfpqZv4ClDOKEhZvSM7H6RCqrLEhCqFVBSKep5Mva5gWbPq0W0IZohuuP3bhujySvuP3Hf7OKdIDuAdztCq1cXtUzmBUbCqkenmT4SZbvqpjOlCWYNZiLvp(emeCvuP)MMZKP5kFUuWuKvO4HT)wfaPrvkenmT4GIk9o4G)wPJOLvkic6jz1izZtUzS9a3aoifIgMwC25GkONe0foOM()xHK6fmHq2FdvufsIk5GIk9o4GjaYQhATESS)gQiEYnJn24gWbfv6DWbnQd9ptEuYQHfuYbPq0W0IZop5MXwzCd4GuiAyAXzNdQGEsqx4GLp3QZQQdffjusAz)yztwnDyuH0w8an3Z5kForLEhvvhkksOK0Y(XYMQEy)yVeGKdkQ07GdQ6qrrcLKw2pw2ep5MXgZ5gWbfv6DWbHKy0Js2pw2eIdsHOHPfNDEYnJThZnGdkQ07GdIuTo0Js20taehKcrdtlo78KBgBVYnGdkQ07GdQairqy7I2D8DiXbPq0W0IZop5MXwXWnGdsHOHPfNDoOOsVdoia5DR4GkONe0foiWMB1z137gljvH0w8anxrZT6S67DJLKQlDOKEhZvSM7H6RZzY0CLpxkykYQhjbdbBv9wthLEhvkenmTMd4Z9CoGnx5ZP6gVAwIksFV7W6XNGHGRqswmnNjtZv(CPGPiRqXdB)TkasJQuiAyAnNjtZLcMIScfpS93QainQsHOHP1CpNZiLvp(emeCfsBXd0CfYyo2EyoGZbvmPWKnfyjkrCZyJNCZyRGXnGdsHOHPfNDoOc6jbDHdMcMIScfpS93QainQsHOHP1CpNZiLvp(emeCvuP)M4GIk9o4GkbJTIk9oSyhLCqSJsBiBIdwQr6gTE8jyiyEYnJTci3aoOOsVdoiQ1X2VdjoifIgMwC25j3m2y2Cd4GuiAyAXzNd2g5Gik5GIk9o4GVfOlAyId(wW6ehuuP)MSuqBNqZv0CSn3Z5uDJxnlrfG8UvviTfpqZviJ5y7H5mzAov34vZsur67Dhwp(emeCfsBXd0CfYyo2EDUNZbS5sbtrwHIh2(BvaKgvPq0W0AotMMlfmfzDjWxSOwhB9aLIMJ9KPkfIgMwZ9Cov34vZsuxc8flQ1XwpqPO5ypzQcPT4bAUczmhBVohWNZKP5sbtrwxc8flQ1XwpqPO5ypzQsHOHP1CpNt1nE1Se1LaFXIADS1dukAo2tMQqAlEGMRqgZX2RZ9CoGnNQB8QzjQi99UdRhFcgcUcPT4bAUIMl9nzZ2UCAotMMt1nE1SevK(E3H1JpbdbxH0w8anNHZP6gVAwIksFV7W6XNGHGRlDOKEhZv0CPVjB22LtZbCo4BbAdztCqJDJTOwhBrae4cXtUzL9a3aoifIgMwC25GkONe0foOM()x1e1llO8Z6QzjM75COwhBrae4AUIymhB1xNRam3dvMpxXAUuWuK1pwqa63eSsHOHP1CpNR85Elqx0Wu1y3ylQ1XweabUqCqrLEhCqvhFSuckjXtUzLXg3aoifIgMwC25GkONe0foiQ1XweabUMRW5kBUNZbS5kFU3c0fnmvn2n2IADSfbqGl0CMmnNcGalrO5kAo2Md4CqrLEhCqeaz1SOPddEYnRSY4gWbPq0W0IZohub9KGUWbb2CPGPiRqXdB)TkasJQuiAyAnNjtZjfeb9KQkOGa4rjRcG0OkfIgMwZb85EoNrkRE8jyi4QOs)nnNjtZPP))1LaFXIADS1dukAo2tMQ6gNZKP500))kKuVGjeY(BOIQqsu5CpNtt))Rqs9cMqi7VHkQcPT4bAUIMtjO0M(M4GIk9o4GkasJSAno5j3SYyo3aoifIgMwC25GkONe0foOM()x1e1llO8ZQUX5Eox5Z9wGUOHPQXUXwuRJTiacCHM75CLpxkykYkbLLRK07OsHOHPfhuuP3bhubqAKvRXjp5Mv2J5gWbPq0W0IZohub9KGUWblFU3c0fnmvn2n2IADSfbqGl0CpNlfmfzLGYYvs6DuPq0W0AUNZbS5wKM()xjOSCLKEhviTfpqZv4CkbL2030CMmnNM()x1e1llO8ZQUX5aohuuP3bhubqAKvRXjp5Mv2RCd4GuiAyAXzNdQGEsqx4GaBouRJTiacCnxrmM7X1xNRam3d1YMRynNOs)nzPG2oHMd4Z9CoGnx5ZLcMIScfpS93QainQsHOHP1CMmnNQB8QzjQi99UdRhFcgcUcPT4bAUIMRGnhW5GIk9o4GkasJSAno5j3SYkgUbCqrLEhCWfP8TKEuYQ14KdsHOHPfNDEYnRScg3aoifIgMwC25GkONe0foOOs)nzPG2oHMRO5yBotMMtRrioOOsVdoOVnsXYJswLKckHTraep5MvwbKBahKcrdtlo7Cqf0tc6chuuP)MSuqBNqZv0CSnNjtZP1iehuuP3bhe16ylStEYnRmMn3aoifIgMwC25GkONe0foOcGalrO5kAo24GIk9o4GQo(yPeusINCZy(dCd4GIk9o4GEO8GGssCqkenmT4SZtEYto4BcI8o4Mv2dL9WdSv2J5GSiWWJsioybUn2WKwZvmZjQ07yoSJsuDaIdImskUzLvmfmoOry)DmXbl(CfBcLqDv6Dm3JUaXT6LbOIphizmPTgbN7XSoxzpu2ddqdqfFoMrMzsPN0Aon63qAovV1KConQKhO6CmtukYyIMl6OaaqG7VoEorLEhO56aZuDaQ4ZjQ07avncjvV1KKXhlOxgGk(CIk9oqvJqs1BnjnKH5)UxdqfForLEhOQriP6TMKgYWCrV0MIusVJbirLEhOQriP6TMKgYWCK(E3H1iLdqIk9oqvJqs1BnjnKH5LG(UDiz7VfjkO)DfXQ)zKcMISwc672HKT)wKOG(3vuLcrdtRbOIpNOsVdu1iKu9wtsdzyokeJiaDArPKObirLEhOQriP6TMKgYWCJD6DmajQ07avncjvV1K0qgMJADS97qAasuP3bQAesQERjPHmm3dLheusIv)ZO8uWuKvuRJTFhsvkenmTgGgGk(CmJmZKspP1C0BcY0CPVP5sa0CIkB4CoAo5T4yrdt1birLEhigiJegBXT6LbirLEhidzyoYJsKDlLC1a0auXNRGtE3Q50reAozoKrs5cEoJqVHEY0CyhLZ1XC7gLZT1XPNcSeLZHuuiqVrSoNMEoxcGMlfyjkNlbajeGgVMtjXCVfitZTiJuS8O0CDmxkyks0aKOsVdedLGXwrLEhwSJswdztmaiVBfR(Nba5DRSIk930trL(BYsbTDcv4RfGuWuKvp(em6kfIgMwgcSuWuKvp(em6kfIgMwptbtrw9ijyiyRQ3A6O07OsHOHPfWhGev6DGmKH5kjffMj0Mv)ZOCGzKYQhFcgcUkQ0FtpxDw99UXssviTfpqgYwrgPS6XNGHGRqAlEGaUjtiJegBtbwIsuvjPOWmH2fXMjtLNcMIScfpS93QainQsHOHP1auXNZaw65sbwIY5qkkeO3O5einhajwyAnh2FHMd5rjmnxkWsuohlEcyUco5DRMJfsEtR58OohykW0JsZXINaMlbajAUuGLOeX6CYCiJKYfSxq0AoMjnZ4CgHEd9KP5C0CqIzPUdP1aKOsVdKHmmxjySvuP3Hf7OK1q2edPjw9pdrL(BYsbTDcvuzdqfFUcCVBSK0CiaToEnxqVj4CFbJNR))5sa0CgH(wGmnxkWsuwNRa)Z9iskkmtO9CS4y8Cq6djeG5kW9UXssZPr)gsZ55CeZSrhsiwNlbqqIzanx0Zbjb1XCzphlckP5sFtZPeu6rP58CasuP3bYqgM77DJLKyvXKct2uGLOeXGnw9pdi9HecGOHPNaR8uWuKvLKIcZeAxPq0W0YKjv34vZsuvskkmtODfsBXdurqAlEGa(auXNR4p6EcyUcmscgcEUhP3A6O07yUuWuK0I158KzanNXgHCnmnxbU3nwsAowCmEUGO1CzpNgnhK(qcbGwZH6oi4CjajMlbqZbPT4HhLMBPdL07yoKWeI158)CjacsmdO5emKKftZjZ9iaKgnh7noNRJ5sa0CSimnx2ZLaO5sbwIY6aKOsVdKHmm337gljXQ)zKcMIS6rsWqWwvV10rP3rLcrdtRNIk9oQkasJSAnoREy)yVeG8jK2IhOcx6qj9okwpuFDaQ4ZzaaAUsuqqbphuhtZ1)5sa6BT5(nCUuWuKO5C0Czp3wyM9Txq0CjaAUqFRrW56)C6icnx)NJefGbirLEhidzyUsWyROsVdl2rjRHSjgQfAasuP3bYqgM)BLoIwwPGiONKvJKnR(Nr5gPS6XNGHGRIk93KjtLNcMIScfpS93QainQsHOHP1aKOsVdKHmmpbqw9qR1JL93qfXQ)zOP))viPEbtiK93qfvHKOYbirLEhidzyUrDO)zYJswnSGYbirLEhidzyUQdffjusAz)yztS6FgLV6SQ6qrrcLKw2pw2KvthgviTfpqplxuP3rv1HIIekjTSFSSPQh2p2lbihGev6DGmKH5qsm6rj7hlBcnajQ07azidZrQwh6rjB6jaAasuP3bYqgMRairqy7I2D8Dinav85maanN)Nt1XYtVJ5aqqAobZIWeAoXOrStO5k4K3TAUSNd1Bkb4rP56eabNlbiXCjaAoJqFlqMMlfyjkhGev6DGmKH5aK3TIvftkmztbwIsed2y1)ma2QZQV3nwsQcPT4bQOvNvFVBSKuDPdL07Oy9q9vtMkpfmfz1JKGHGTQERPJsVJkfIgMwa)jWkx1nE1SevK(E3H1JpbdbxHKSyYKPYtbtrwHIh2(BvaKgvPq0W0YKPuWuKvO4HT)wfaPrvkenmTEAKYQhFcgcUcPT4bQqgS9aWhGev6DGmKH5kbJTIk9oSyhLSgYMyuQr6gTE8jyiyw9pJuWuKvO4HT)wfaPrvkenmTEAKYQhFcgcUkQ0FtdqfFoWwhphZQdP5qaAD8AonAoDeTMRJ5uDJxnlbRZ55CRMqZfDoNy0ijW5yPHjG5qYBpkn3VHZvIcckPhLMdS1XZbcqGl0ClDOhLMt1nE1SeObirLEhidzyoQ1X2VdPbOIpxbMmdO5yPHjG5qzREXJsZPBCUoMdS1XZbcqGl0CA0VH0CYCB5r1W5uDJxnlXC6iPenajQ07azidZFlqx0WeRHSjgg7gBrTo2IaiWfI13cwNyiQ0FtwkOTtOIy7PQB8QzjQaK3TQcPT4bQqgS9GjtQUXRMLOI037oSE8jyi4kK2IhOczW2RpbwkykYku8W2FRcG0OkfIgMwMmLcMISUe4lwuRJTEGsrZXEYuLcrdtRNQUXRMLOUe4lwuRJTEGsrZXEYufsBXduHmy7vGBYukykY6sGVyrTo26bkfnh7jtvkenmTEQ6gVAwI6sGVyrTo26bkfnh7jtviTfpqfYGTxFcmv34vZsur67Dhwp(emeCfsBXdurPVjB22LtMmP6gVAwIksFV7W6XNGHGRqAlEGmu1nE1SevK(E3H1Jpbdbxx6qj9okk9nzZ2UCc4dqfFUhPJpwkbLKMdbO1XR56aZ0CA0C6iAnx2ZHOCoDJZ9iaKgnh7nor15ywXccq)MGZHPen3J0XhlLGssZPrZPJO1CKaXobNl75quoNUX5KyUcmuEqqjP50OFdP5Ee2RZvG)5K52YJQHZP6gVAwI5C0CQE7rP50nY6Ci5nnNcGalrO5(nCophGev6DGmKH5Qo(yPeusIv)Zqt))RAI6Lfu(zD1SeprTo2IaiWvrmyR(Ab4HkZlwPGPiRFSGa0VjyLcrdtRNL)wGUOHPQXUXwuRJTiacCHgGk(CGaKvZIMomMZrZPJO1CcAozULJuTEKZ9iD8XsjOK0CzpxjkiOK0CiacCHMZ)ZXuRp3QdMHCoaYBAokA9saM73W5K5EeasJMJ9gN15maanhs20CqDmHMt0A9CoK82JsZ55C)go3wEunCov34vZsGMtmAe7eAasuP3bYqgMJaiRMfnDyWQ)zGADSfbqGRcl7jWk)TaDrdtvJDJTOwhBrae4czYKcGalrOIyd4dqfFUhbG0O5yVX5Cae0Ci6nbf8CgBeY1W0C6iAovhlp9oq15EeOGa4rP5EeasJyDoMfqF3oKMR)ZbQBesBrXeRZjXAUITaFzoWwhxWBUcmqPO5ypzAobJN7lVB4CkbLEuAobn3wcMM7ryhnNGMZyJqUgMMJfaumNemnx)Nlbq75einNOs)nnajQ07azidZvaKgz1ACYQ)zaSuWuKvO4HT)wfaPrvkenmTmzskic6jvvqbbWJswfaPrvkenmTa(tJuw94tWqWvrL(BYKjn9)VUe4lwuRJTEGsrZXEYuv3OjtA6)FfsQxWecz)nurvijQ8PM()xHK6fmHq2FdvufsBXdurkbL2030auXNRa)Zb2645abiWfAobsZfDoNg5rP5m2nMwZjXAoMrOSCLKEhZ5O5IoNlfmfjTyDUhLokNdzKI1Cpc7O5e0CjaIP50ivVP5K3IJfnmnajQ07azidZvaKgz1ACYQ)zOP))vnr9Yck)SQB8z5VfOlAyQASBSf16ylcGaxONLNcMISsqz5kj9oQuiAyAnav85E09eWCmJqz5kj9oyDopzgqZPrb9DLl45YEUTWm7BVGO5sa0C6gtFtZ1XCjaAUfPP))15k4AwO3eK158KzanhkDmEonktcox2ZPJO5EeasJMJ9gNZ57nTCjjmtZ5)5yxuVSGYpNZrZPBCasuP3bYqgMRainYQ14Kv)ZO83c0fnmvn2n2IADSfbqGl0ZuWuKvcklxjP3rLcrdtRNaBrA6)FLGYYvs6DuH0w8avOsqPn9nzYKM()x1e1llO8ZQUrGpav85ygFtXCSaGI5qYBpkX6CREUOZ563eujgNRJ5aBD8CGae4cnajQ07azidZvaKgz1ACYQ)zamuRJTiacCveJhxFTa8qTSILOs)nzPG2oHa(tGvEkykYku8W2FRcG0OkfIgMwMmP6gVAwIksFV7W6XNGHGRqAlEGkQGb8birLEhidzy(Iu(wspkz1ACoajQ07azidZ9TrkwEuYQKuqjSncGy1)mev6Vjlf02jurSzYKwJqdqIk9oqgYWCuRJTWoz1)mev6Vjlf02jurSzYKwJqdqfFUIDhmd5C9BcQeJZ1XCkacSeHMR)Z9iD8XsjOK0aKOsVdKHmmx1XhlLGssS6FgkacSeHkITbirLEhidzyUhkpiOK0a0auXN7rt8yU(phZQdP5C0CjtgDLGXmnxcGMdGxcaHY5mc9g6jtZjQ07G1500Z5uemfpMd5PUKEhO5(Y7goNoYJsZ9iaKgnh7noNZdusYAasuP3bQknXakEy7V97qIv)ZWiLvp(emeCvuP)MEcmn9)VQGccGhLSkasJQRMLWKPYtbtrwHIh2(BvaKgvPq0W0c4pbw5QUXRMLOcqE3QkKKftMmjQ0FtwkOTtOIyoWhGk(CpcajccpxXM2D8DinxhyMMliAHMRdAUcCVBSK0CIk930ClDOhLMZt0CkbLZ9B4CmtAMX6Cf8d9TazAUuGLOCohnNoIwZbGG0C)gohY3gXUYtMgGev6DGQstgYWCfajccBx0UJVdjw9pJvNvFVBSKufsBXdurkbL2030auXNd03owGZL9CipkHP5sbwIswNlbqqAohnx0ZfeTMl75G0hsiaZvG7DJLKqZ5)5EejffMj0EoLeZT658CopqjjRbirLEhOQ0KHmm337gljXQIjfMSPalrjIbBS6FgqAlEGk81NaR8uWuKvLKIcZeAxPq0W0YKjv34vZsuvskkmtODfsBXdurqAlEGa(auXN7rthtO5(nCov34vZsGMB1ZfDoNcGeLO5(nCoMjnZiRZH65ucgpxcGMdjBAoSJY5e0CDmhYJsyAUuGLOCasuP3bQknzidZvcgBfv6DyXokznKnXqTqdqfFodaajAUuGLOenNJMtI58OaOrjlefZPeenxcqY5k5Vj0CYCiSxcqoNgf03Z5YEoaEjaeCoJqVHEY0CfCY7wnajQ07avLMmKH5aK3TIvftkmztbwIsed2y1)mev6Vjlf02juHpEaQ4Z9OjEmx)NJz1H0CS4y8COuG5Czp3Q3EijnxhZbGK3mnhZKMzK1500Z5q9MMd5Lc)7kjY5EeasJMJ9gNZPP))O5yXX45qPJXZvYFtZbWlbGGZTKTuIMR1tJ65CDmxRucY7yasuP3bQknzidZvaKgz1ACYQ)zKcMIScfpS93QainQsHOHP1tJuw94tWqWvrL(B6jWaiVBLvuP)MmzkfmfzvjPOWmH2vkenmTmzkfmfz1JpbJUsHOHP1trL(BYsbTDcv4Jb(auXNJDbc9O0CsW0CeZSImMEhiwN7rt8yU(phZQdP5yXX450O50r0Aobn3wxbyobnNXgHCnmX6Cipu0CBDC6gX0CQ2OtO56)CEoNsI5qPOEzasuP3bQknzidZHIh2(B)oKgGev6DGQstgYW8FR0r0Ykfeb9KSAKShGev6DGQstgYWCJ6q)ZKhLSAybLdqfFoMX3umN)NlbqZvWjVB1CgHEd9KP5WokNJLoygY50O50r0I15k4K3TAohnNriLjtZT1vaM7djAULSLs0CsSMdsOwhQi0CsSMdbO1XR50O50r0AobVBuoxhZP6gVAwIbirLEhOQ0KHmmhG8UvSQysHjBkWsuIyWgR(NbWkpfmfzfkEy7VvbqAuLcrdtltMkpfmfz1JpbJUsHOHPLjtPGPiRqXdB)TkasJQuiAyA90iLvp(emeCfsBXduHmy7bGpav85yMgrZXS6qAojwZXo03OSdAo)ph7I6Lfu(5CoAorL(BI15e0C4oknNGMZZ5yXX45IoNRFtqLyCUoMdS1XZbcqGl0aKOsVduvAYqgM7HYdckjXQ)zKcMIS(DizLyz1G(gLDqvkenmTEQP))vnr9Yck)SQB8jQ1XweabUk81cWd1YkwIk93KLcA7eAaQ4ZXm1eabNdS1XZbcqGR5krbbL0JsZjAo2tNqZjqAUsDVM77ymbNZ)ZfDoNoYJsZXS6qAojwZXo03OSdAasuP3bQknzidZrTo2(DinajQ07avLMmKH5Qo(yPeusIv)Zqt))RAI6Lfu(zD1SedqIk9oqvPjdzyocGSAw00HbR(Nr5PGPiRFhswjwwnOVrzhuLcrdtRbirLEhOQ0KHmmx1HIIekjTSFSSjw9pJYxDwvDOOiHssl7hlBYQPdJkK2IhONLlQ07OQ6qrrcLKw2pw2u1d7h7LaKpfv6Vjlf02juHVoav85E09eWCmRoKMtI1CSd9nk7GyDUcmuEqqjP5yXX450O5K5qjSJsZ9DmMG15kWKzanNrSOO1Caiin3VHZjy8CPGPirZL9CgH0BkY5eLYxuKcgZ0C6ipknxcGMd5rjmnxkWsuohStj9oMd7OCasuP3bQknzidZ9q5bbLKgGgGk(CpA0hsiaZ57DJLKMtJ(nKMJIKGEuAozoMfnOUX5kW4tWqWZL9CTX03EbrZvsTq1birLEhOQAHy47DJLKy1)msbtrwHIh2(BvaKgvPq0W06jK2IhOclGpvDJxnlrfPV3Dy94tWqWviTfpqf(46RdqfFoMPr0CQo(yPeusAUhLokNtJ(nKMJzrdQBCUcm(eme8CzpxBm9Txq0CLuluDasuP3bQQwidzyUQJpwkbLKy1)msbtrwHIh2(BvaKgvPq0W06PQB8QzjQi99UdRhFcgcUcPT4bQWhxF9z5A6)FvtuVSGYpR6gFIADSfbqGRcFCL5dqIk9oqv1czidZ1rK1tAZAiBIHuqiacuq2FhPT)wJnleKv)Zq1nE1SevK(E3H1Jpbdbx1nAYKQB8QzjQi99UdRhFcgcUcPT4bQqgpEasuP3bQQwidzyosFV7W6XNGHGhGev6DGQQfYqgMxsxGlxcB)TsbrWobWQ)zyKYQhFcgcUkQ0FtdqIk9oqv1czidZxc8flQ1XwpqPO5ypzIv)ZWiLvp(emeCvuP)MEcmJuw94tWqWviTfpqfw2d1xnzYiLvp(emeCfsBXduHLv2tuRJTiacCvedMxlgtMkpfmfzfkEy7VvbqAuLcrdtlGpajQ07avvlKHmmFt7gYKT)wSUYx2fKKnIv)ZWiLvp(emeCvuP)MEcmJuw94tWqWviTfpqfY2R1xnzc16ylcGaxfY86RpbMM()xxc8flQ1XwpqPO5ypzQQB0KPYtbtrwHIh2(BvaKgvPq0W065QZQV3nwsQcPT4bQi2kd4aFaQ4ZvG)5k2Gf4CoAUOZ5GKSyAon9CoMA95usmxjkNB3qAUeGeZ1bnNhFcgcEopMtJ(nKMlbqZrXAU(pxcGM77LaKSohsFV7yUeanxbgFcgcEUOzzasuP3bQQwidzyosFV7W6XNGHGz1)msFt2STlNks1nE1SevK(E3H1Jpbdbxx6qj9omK5pmajQ07avvlKHmmVKUaxUe2(BLcIGDcGv)Zi9nveZF4z6BYMTD5urQUXRMLOwsxGlxcB)TsbrWobux6qj9omK5pmav85kW)CjaAUVxcqohlogphfR50OFdP5k2Gf4CoAonr9YC6gzDoK(E3XCjaAUcm(eme8aKOsVduvTqgYWCK(E3H1JpbdbZQ)zKcMISUe4lwuRJTEGsrZXEYuLcrdtRNQUXRMLOUe4lwuRJTEGsrZXEYufsBXdurPalrzn9nzZ2UCAasuP3bQQwidzyEjDbUCjS93kfeb7eaR(NHQB8QzjQi99UdRhFcgcUcPT4bQO03KnB7YPbOIpxb(NlbqZ99saY5yXX45OynNg9BinNhFcgcEohnNMOEzoDJSoNoIMRydwGdqIk9oqv1czidZxc8flQ1XwpqPO5ypzIv)Zq1nE1SevK(E3H1JpbdbxH0w8avu6BYMTD50tJuw94tWqWviTfpqfw2d1xhGev6DGQQfYqgMZsdXR3KhwiH6qcfXQ)zO6gVAwIksFV7W6XNGHGRqAlEGkk9nzZ2UC6PrkRE8jyi4kK2IhOczRawFDasuP3bQQwidzy(M2nKjB)TyDLVSlijBeR(NHQB8QzjQi99UdRhFcgcUcPT4bQO03KnB7YPNaZiLvp(emeCfsBXduHS9A9vtM00))6sGVyrTo26bkfnh7jtvDJprTo2IaiWvHmh4dqfFUc8pxcGM77LaKZ5O5eTwpNl75OyX6C6iAUhPyJMdPRamxcqY5saetZvIY5e0CBDfG5sFtZPBCobnNXgHCnmnajQ07avvlKHmmhPV3Dy94tWqWS6FgPVjB22LtfY8hgGev6DGQQfYqgMxsxGlxcB)TsbrWobWQ)zK(MSzBxoviZFyasuP3bQQwidzy(sGVyrTo26bkfnh7jtS6FgPVjB22LtfwgBptFt2STlNk6XdqIk9oqv1czidZ30UHmz7VfRR8LDbjzJy1)msFt2STlNkKTI5z6BYMTD5urfZaKOsVduvTqgYWCwAiE9M8WcjuhsOiw9pJ03KnB7YPczJz)m9nzZ2UCQOhpajQ07avvlKHmmFt7gYKT)wSUYx2fKKnIv)Zi9nzZ2UCQq2kMNPVjB22LtfvmdqIk9oqv1czidZ1WDVS93Mailf0MPbirLEhOQAHmKH5S0q86n5HfsOoKqrS6FgQUXRMLOI037oSE8jyi4kK2IhOIyumpuayRSNLBKYQhFcgcUkQ0FtdqIk9oqv1czidZHUrJyY6Hfzuu0aKOsVduvTqgYWCJD6DWQ)zyKYQhFcgcUkQ0FtMmL(MSzBxoviZFyasuP3bQQwidzyUgbre8fpkXQ)zyKYQhFcgcUkQ0Ftpbw5PGPiRqXdB)TkasJQuiAyAzYeWkNqikuuDt7gYKT)wSUYx2fKKnQULhvdnzst))RBA3qMS93I1v(YUGKSrviTfpqa)jWkpfmfzDjWxSOwhB9aLIMJ9KPkfIgMwMmPP))1LaFXIADS1dukAo2tMQqAlEGaoWnzk9nzZ2UCQqgS96aKOsVduvTqgYWCnC3l7xhYeR(NHrkRE8jyi4QOs)n9eyLNcMIScfpS93QainQsHOHPLjtaRCcHOqr1nTBit2(BX6kFzxqs2O6wEun0Kjn9)VUPDdzY2Flwx5l7csYgvH0w8ab8NaR8uWuK1LaFXIADS1dukAo2tMQuiAyAzYKM()xxc8flQ1XwpqPO5ypzQcPT4bc4a3KP03KnB7YPczW2RdqIk9oqv1czidZ)oK0WDVy1)mmsz1Jpbdbxfv6VPNaR8uWuKvO4HT)wfaPrvkenmTmzcyLtiefkQUPDdzY2Flwx5l7csYgv3YJQHMmPP))1nTBit2(BX6kFzxqs2OkK2IhiG)eyLNcMISUe4lwuRJTEGsrZXEYuLcrdtltM00))6sGVyrTo26bkfnh7jtviTfpqah4MmL(MSzBxovid2EDasuP3bQQwidzyUoISEsBeR(NHrkRE8jyi4QOs)n9eyLNcMIScfpS93QainQsHOHPLjtgPS6XNGHGRqAlEGkKrzpaCtMsFt2STlNkKrzpmajQ07avvlKHmmxhrwpPnRHSjggB1luI8cIwwvVnQNs6Dyx0BxrS6FgRoR(E3yjPkK2IhOIy86tGP6gVAwIksFV7W6XNGHGRqAlEGkIrzpyYu6BYMTD5uHm)bGpajQ07avvlKHmmxhrwpPnRHSjgWovqDusl77UxDBxngZQ)zS6S67DJLKQqAlEGkIXRpbMQB8QzjQi99UdRhFcgcUcPT4bQigL9GjtPVjB22LtfY8ha(aKOsVduvTqgYWCDez9K2SgYMyGa4VjO9nf92cjSRy1)mwDw99UXssviTfpqfX41Nat1nE1SevK(E3H1JpbdbxH0w8aveJYEWKP03KnB7YPcz(daFasuP3bQQwidzyUoISEsBwdztmeML6UXoPiTHONowhXQ)zS6S67DJLKQqAlEGkIXRpbMQB8QzjQi99UdRhFcgcUcPT4bQigL9GjtPVjB22LtfY8ha(aKOsVduvTqgYWCDez9K2SgYMyK(Iqzd3wvViMzw9pJvNvFVBSKufsBXdurmE9jWuDJxnlrfPV3Dy94tWqWviTfpqfXOShmzk9nzZ2UCQqM)aWhGev6DGQQfYqgMRJiRN0M1q2eJ3UGT93IYgUrS6FgRoR(E3yjPkK2IhOIy86tGP6gVAwIksFV7W6XNGHGRqAlEGkIrzpyYu6BYMTD5uHm)bGpanav85a11eJ45weYlf0AUSNRnM(2liAUeanNoskrZ1)50e1llO8Z5w6qpknhZIgu34Cfy8jyiyeRZjXAoJq6nf5CkXOrpknhlEcyUc(AMPuSRdqIk9oq1sns3O1JpbdbZakEy7V97qIv)Za16ylcGaxmE9z5A6)FvtuVSGYpR6gFQP))1nTBit2(BX6kFzxqs2OQUXbirLEhOAPgPB06XNGHGnKH5kasJSAnoz1)m00))QMOEzbLFw1noajQ07avl1iDJwp(emeSHmmxbqAKvRXjR(NbQ1XweabUkIXJRLva00))6M2nKjB)TyDLVSlijBuv34aKOsVduTuJ0nA94tWqWgYWCfaPrwTgNS6FgLR6gVAwIQQJpwkbLKQ6ghGev6DGQLAKUrRhFcgc2qgMRainYQ14Kv)ZqjO0M(Mk0iLvp(emeCfsBXd0tJuw94tWqWviTfpqfQeuAtFtgwsTgGev6DGQLAKUrRhFcgc2qgMR64JLsqjjw9pdn9)VQjQxwq5N1vZs8ut))RBA3qMS93I1v(YUGKSrvDJprTo2IaiWvrmyRY8birLEhOAPgPB06XNGHGnKH5Qo(yPeusIv)Zqt))RAI6Lfu(zD1Seplxt))RBA3qMS93I1v(YUGKSrvDJpbgQ1XweabUkIrz1cOjtkacSeHSFOOsVdbxeBvM9tuRJTiacCved2Qmh4dqIk9oq1sns3O1JpbdbBidZvD8XsjOKeR(NHrkRE8jyi4kK2IhOcFDasuP3bQwQr6gTE8jyiydzyUQJpwkbLKy1)muaeyjcveBdqIk9oq1sns3O1JpbdbBidZrTo2(DinajQ07avl1iDJwp(emeSHmmhbqwnlA6WyasuP3bQwQr6gTE8jyiydzyUhkpiOK0a0aKOsVdufG8UvmuD8XsjOKeR(NHM()x1e1llO8Z6QzjEIADSfbqGRIyW2tuRJTiacCviJhpajQ07avbiVBLHmm337gljXQ)zKcMIS6rsWqWwvV10rP3rLcrdtRNqAlEGkCPdL07Oy9q9vtMkpfmfz1JKGHGTQERPJsVJkfIgMwpH0hsiaIgMgGev6DGQaK3TYqgMRainYQ14Kv)ZqjO0M(MkeG8UvwiTfpqdqIk9oqvaY7wzidZrTo2(DinajQ07avbiVBLHmmhbqwnlA6WGv)ZquP)MSuqBNqfYCtMkpfmfz97qYkXYQb9nk7GQuiAyAnajQ07avbiVBLHmm3dLheusIv)ZqjO0M(MkeG8UvwiTfpq8KNCoa]] )


end
