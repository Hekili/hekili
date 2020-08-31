-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 265, true )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        -- regen effects.
    }, setmetatable( {
        actual = nil,
        max = 5,
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
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        nightfall = 22039, -- 108558
        inevitable_demise = 23140, -- 334319
        drain_soul = 23141, -- 198590

        writhe_in_agony = 22044, -- 196102
        absolute_corruption = 21180, -- 196103
        siphon_life = 22089, -- 63106

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        sow_the_seeds = 19279, -- 196226
        phantom_singularity = 19292, -- 205179
        vile_taint = 22046, -- 278350

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        howl_of_terror = 23465, -- 5484

            shadow_embrace = 23139, -- 32388
        dark_caller = 23139, -- 334183
        haunt = 23159, -- 48181
        grimoire_of_sacrifice = 19295, -- 108503

        soul_conduit = 19284, -- 215941
        creeping_death = 19281, -- 264000
        dark_soul_misery = 19293, -- 113860
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        amplify_curse = 5370, -- 328774
        bane_of_fragility = 11, -- 199954
        bane_of_shadows = 17, -- 234877
        casting_circle = 20, -- 221703
        deathbolt = 12, -- 264106
        demon_armor = 3740, -- 285933
        essence_drain = 19, -- 221711
        gateway_mastery = 15, -- 248855
        nether_ward = 18, -- 212295
        rampant_afflictions = 5379, -- 335052
        rot_and_decay = 16, -- 212371
        soulshatter = 13, -- 212356
    } )

    -- Auras
    spec:RegisterAuras( {
        agony = {
            id = 980,
            duration = function () return 18 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Curse",
            max_stack = function () return ( talent.writhe_in_agony.enabled and 18 or 10 ) end,
            meta = {
                stack = function( t )
                    if t.down then return 0 end
                    if t.count >= 10 then return t.count end

                    local app = t.applied
                    local tick = t.tick_time

                    local last_real_tick = now + ( floor( ( now - app ) / tick ) * tick )
                    local ticks_since = floor( ( query_time - last_real_tick ) / tick )

                    return min( talent.writhe_in_agony.enabled and 18 or 10, t.count + ticks_since )
                end,
            }
        },
        burning_rush = {
            id = 111400,
            duration = 3600,
            max_stack = 1,
        },
        corruption = {
            id = 146739,
            duration = function () return ( talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        curse_of_exhaustion = {
            id = 334275,
            duration = 8,
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
        dark_soul_misery = {
            id = 113860,
            duration = 20,
            max_stack = 1,
        },
        decimating_bolt = {
            id = 325299,
            duration = 3600,
            max_stack = 1,
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
            max_stack = 1,
            tick_time = function () return haste end,
        },
        drain_soul = {
            id = 198590,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
        },
        eye_of_kilrogg = {
            id = 126,
            duration = 45,
            max_stack = 1,
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
        haunt = {
            id = 48181,
            duration = 18,
            type = "Magic",
            max_stack = 1,
        },
        howl_of_terror = {
            id = 5484,
            duration = 20,
            max_stack = 1,
        },
        inevitable_demise = {
            id = 334320,
            duration = 20,
            type = "Magic",
            max_stack = 50,
            copy = 273525
        },
        mortal_coil = {
            id = 6789,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        nightfall = {
            id = 264571,
            duration = 12,
            max_stack = 1,
        },
        phantom_singularity = {
            id = 205179,
            duration = 16,
            max_stack = 1,
        },
        ritual_of_summoning = {
            id = 698,
        },
        seed_of_corruption = {
            id = 27243,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadow_embrace = {
            id = 32390,
            duration = 10,
            type = "Magic",
            max_stack = 3,
        },
        shadowfury = {
            id = 30283,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        siphon_life = {
            id = 63106,
            duration = function () return 15 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 3 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
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
        summon_darkglare = {
            id = 205180,
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
        unstable_affliction = {
            id = 316099,
            duration = 21,
            tick_time = 1.5,
            type = "Magic",
            max_stack = 1,
        },
        --[[ OLD UAs:
        unstable_affliction = {
            id = 233490,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
            copy = "unstable_affliction_1"
        },
        unstable_affliction_2 = {
            id = 233496,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_3 = {
            id = 233497,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_4 = {
            id = 233498,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_5 = {
            id = 233499,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        active_uas = {
            alias = { "unstable_affliction_1", "unstable_affliction_2", "unstable_affliction_3", "unstable_affliction_4", "unstable_affliction_5" },
            aliasMode = 'longest',
            aliasType = 'debuff',
            duration = 8
        }, ]]
        vile_taint = {
            id = 278350,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },


        -- PvP Talents
        casting_circle = {
            id = 221705,
            duration = 3600,
            max_stack = 1,
        },
        curse_of_fragility = {
            id = 199954,
            duration = 10,
            max_stack = 1,
        },
        curse_of_shadows = {
            id = 234877,
            duration = 10,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_tongues = {
            id = 199890,
            duration = 10,
            type = "Curse",
            max_stack = 1,
            copy = 1714,
        },
        curse_of_weakness = {
            id = 199892,
            duration = 10,
            type = "Curse",
            max_stack = 1,
            copy = 702,
        },
        demon_armor = {
            id = 285933,
            duration = 3600,
            max_stack = 1,
        },
        essence_drain = {
            id = 221715,
            duration = 6,
            type = "Magic",
            max_stack = 5,
        },
        nether_ward = {
            id = 212295,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        soulshatter = {
            id = 236471,
            duration = 8,
            max_stack = 5,
        },
    } )


    spec:RegisterHook( "TimeToReady", function( wait, action )
        local ability = action and class.abilities[ action ]

        if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
            wait = 3600
        end

        return wait
    end )

    spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )


    state.sqrt = math.sqrt

    spec:RegisterStateExpr( "time_to_shard", function ()
        local num_agony = active_dot.agony
        if num_agony == 0 then return 3600 end

        return 1 / ( 0.16 / sqrt( num_agony ) * ( num_agony == 1 and 1.15 or 1 ) * num_agony / debuff.agony.tick_time )
    end )


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        if sourceGUID == GUID and spellName == class.abilities.seed_of_corruption.name then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        end
    end )


    spec:RegisterGear( 'tier21', 152174, 152177, 152172, 152176, 152173, 152175 )
    spec:RegisterGear( 'tier20', 147183, 147186, 147181, 147185, 147182, 147184 )
    spec:RegisterGear( 'tier19', 138314, 138323, 138373, 138320, 138311, 138317 )
    spec:RegisterGear( 'class', 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )

    spec:RegisterGear( 'amanthuls_vision', 154172 )
    spec:RegisterGear( 'hood_of_eternal_disdain', 132394 )
    spec:RegisterGear( 'norgannons_foresight', 132455 )
    spec:RegisterGear( 'pillars_of_the_dark_portal', 132357 )
    spec:RegisterGear( 'power_cord_of_lethtendris', 132457 )
    spec:RegisterGear( 'reap_and_sow', 144364 )
    spec:RegisterGear( 'sacrolashs_dark_strike', 132378 )
    spec:RegisterGear( 'soul_of_the_netherlord', 151649 )
    spec:RegisterGear( 'stretens_sleepless_shackles', 132381 )
    spec:RegisterGear( 'the_master_harvester', 151821 )


    --[[ spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
        for i = 1, 5 do
            local aura = "unstable_affliction_" .. i

            if debuff[ aura ].down then
                applyDebuff( 'target', aura, duration or 8 )
                break
            end
        end
    end ) ]]


    spec:RegisterHook( "reset_precast", function ()
        soul_shards.actual = nil

        local icd = 25

        if debuff.drain_soul.up then            
            local ticks = debuff.drain_soul.ticks_remain
            if pvptalent.rot_and_decay.enabled then
                if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 1 end
                if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 1 end
                if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 1 end
            end
            if pvptalent.essence_drain.enabled and health.pct < 100 then
                addStack( "essence_drain", debuff.drain_soul.remains, debuff.essence_drain.stack + ticks )
            end
        end

        if buff.casting.up and buff.casting.v1 == 234153 then
            removeStack( "inevitable_demise" )
        end

        if buff.casting_circle.up then
            applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
        end
    end )


    spec:RegisterStateExpr( "target_uas", function ()
        return active_dot.unstable_affliction
    end )

    spec:RegisterStateExpr( "contagion", function ()
        return active_dot.unstable_affliction > 0
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
        agony = {
            id = 980,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136139,

            handler = function ()
                applyDebuff( "target", "agony", nil, max( ( talent.writhe_in_agony.enabled or azerite.sudden_onset.enabled ) and 4 or 1, debuff.agony.stack ) )
            end,
        },


        --[[ banish = {
            id = 710,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        }, ]]


        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = function () return buff.burning_rush.up and "off" or "spell" end,

            startsCombat = true,

            talent = "burning_rush",
            texture = 538043,

            handler = function ()
                if buff.burning_rush.down then applyBuff( "burning_rush" )
                else removeBuff( "burning_rush" ) end
            end,
        },


        casting_circle = {
            id = 221703,
            cast = 0.5,
            cooldown = 60,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            pvptalent = "casting_circle",

            startsCombat = false,
            texture = 1392953,

            handler = function ()
                applyBuff( "casting_circle", 8 )
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


        corruption = {
            id = 172,
            cast = 0,
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
            cast = 3,
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
            cast = 3,
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
        

        curse_of_fragility = {
            id = 199954,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_fragility",            

            startsCombat = true,
            texture = 132097,

            usable = function () return target.is_player end,
            handler = function ()
                applyDebuff( "target", "curse_of_fragility" )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
            end,
        },


        curse_of_tongues = {
            id = 1714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_tongues",

            startsCombat = true,
            texture = 136140,

            handler = function ()
                applyDebuff( "target", "curse_of_tongues" )
                removeDebuff( "target", "curse_of_exhaustion" )
                removeDebuff( "target", "curse_oF_weakness" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
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
            texture = 615101,

            handler = function ()
                applyDebuff( "target", "curse_of_weakness" )
                removeDebuff( "target", "curse_of_exhaustion" )
                removeDebuff( "target", "curse_oF_tongues" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
            end,
        },


        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 538538,

            talent = "dark_pact",

            handler = function ()
                spend( 0.2 * health.current, "health" )
                applyBuff( "dark_pact" )
            end,
        },


        dark_soul = {
            id = 113860,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",
            
            spend = 0.01,
            spendType = "mana",

            startsCombat = false,
            texture = 463286,

            talent = "dark_soul_misery",

            handler = function ()
                applyBuff( "dark_soul_misery" )
                stat.haste = stat.haste + 0.3
            end,

            copy = "dark_soul_misery"
        },


        deathbolt = {
            id = 264106,
            cast = 1,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            pvptalent = "deathbolt",

            handler = function ()
            end,
        },


        demon_armor = {
            id = 285933,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "demon_armor",

            startsCombat = false,
            texture = 136185,

            handler = function ()
                applyBuff( "demon_armor" )
            end,
        },


        --[[ demonic_circle = {
            id = 48018,
            cast = 0.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
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
            end,
        },


        demonic_gateway = {
            id = 111771,
            cast = 2,
            cooldown = 10,
            gcd = "spell",

            spend = 0.2,
            spendType = "mana",

            startsCombat = true,

            handler = function ()
            end,
        }, ]]


        devour_magic = {
            id = 19505,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            spend = 0,
            spendType = "mana",

            startsCombat = true,
            toggle = "interrupts",

            usable = function ()
                if buff.dispellable_magic.down then return false, "no dispellable magic aura" end
                return true
            end,

            handler = function()
                removeBuff( "dispellable_magic" )
            end,
        },


        drain_life = {
            id = 234153,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return active_dot.soul_rot == 1 and 0 or 0.03 end,
            spendType = "mana",

            startsCombat = true,
            texture = 136169,

            start = function ()
                removeBuff( "inevitable_demise" )
            end,
        },


        drain_soul = {
            id = 198590,
            cast = 5,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            prechannel = true,
            breakable = true,
            breakchannel = function () removeDebuff( "target", "drain_soul" ) end,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,

            talent = "drain_soul",
            texture = 136163,

            start = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
                removeStack( "decimating_bolt" )

                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,

            tick = function ()
                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,
        },


        --[[ enslave_demon = {
            id = 1098,
            cast = 3,
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
            cast = 2,
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

            spend = 0.05,
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
            
            startsCombat = false,
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
            texture = 538443,

            usable = function () return pet.exists and buff.grimoire_of_sacrifice.down end,
            handler = function ()
                applyBuff( "grimoire_of_sacrifice" )
            end,
        },


        haunt = {
            id = 48181,
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 236298,

            talent = "haunt",

            handler = function ()
                applyDebuff( "target", "haunt" )
                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,
        },


        health_funnel = {
            id = 755,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136168,

            start = function ()
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

        
        malefic_rapture = {
            id = 324536,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            texture = 236296,
            
            handler = function ()
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
                gain( 0.2 * health.max, "health" )
            end,
        },


        nether_ward = {
            id = 212295,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "nether_ward",

            startsCombat = false,
            texture = 135796,

            handler = function ()
                applyBuff( "nether_ward" )
            end,
        },


        phantom_singularity = {
            id = 205179,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 132886,

            talent = "phantom_singularity",

            handler = function ()
                applyDebuff( "target", "phantom_singularity" )
            end,
        },


        --[[ ritual_of_summoning = {
            id = 698,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,

            handler = function ()
            end,
        }, ]]


        seed_of_corruption = {
            id = 27243,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 136193,

            velocity = 30,

            usable = function () return dot.seed_of_corruption.down end,
            handler = function ()
                applyDebuff( "target", "seed_of_corruption" )
                
                if active_enemies > 1 and talent.sow_the_seeds.enabled then
                    active_dot.seed_of_corruption = min( active_enemies, active_dot.seed_of_corruption + 2 )
                end
            end,
        },


        shadow_bolt = {
            id = 686,
            cast = 2,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136197,

            velocity = 20,

            notalent = "drain_soul",
            cycle = function () return talent.shadow_embrace.enabled and "shadow_embrace" or nil end,

            handler = function ()
                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,
        },


        shadowfury = {
            id = 30283,
            cast = 1.5,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 607865,

            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },


        siphon_life = {
            id = 63106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136188,

            talent = "siphon_life",

            handler = function ()
                applyDebuff( "target", "siphon_life" )
            end,
        },


        soulshatter = {
            id = 212356,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",
            pvptalent = "soulshatter",

            startsCombat = true,
            texture = 135728,

            usable = function () return buff.active_uas.stack > 0 or active_dot.agony > 0 or active_dot.corruption > 0 or active_dot.siphon_life > 0 end,
            handler = function ()
                local targets = min( 5, max( buff.active_uas.stack, active_dot.agony, active_dot.corruption, active_dot.siphon_life ) )

                applyBuff( "soulshatter", nil, targets )
                stat.haste = stat.haste + ( 0.1 * targets )

                gain( targets, "soul_shards" )

                active_dot.agony = max( 0, active_dot.agony - targets )
                if active_dot.agony == 0 then removeDebuff( "target", "agony" ) end

                active_dot.corruption = max( 0, active_dot.corruption - targets )
                if active_dot.corruption == 0 then removeDebuff( "target", "corruption" ) end

                active_dot.siphon_life = max( 0, active_dot.siphon_life - targets )
                if active_dot.siphon_life == 0 then removeDebuff( "target", "siphon_life" ) end
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

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136174,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        summon_darkglare = {
            id = 205180,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.dark_caller.enabled and 120 or 180 ) end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1416161,

            handler = function ()
                summonPet( "darkglare", 20 )
                if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 8 end
                if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 8 end
                -- if debuff.impending_catastrophe.up then debuff.impending_catastrophe.expires = debuff.impending_catastrophe.expires + 8 end
                if debuff.scouring_tithe.up then debuff.scouring_tithe.expires = debuff.scouring_tithe.expires + 8 end
                if debuff.siphon_life.up then debuff.siphon_life.expires = debuff.siphon_life.expires + 8 end
                if debuff.soul_rot.up then debuff.soul_rot.expires = debuff.soul_rot.expires + 8 end
                if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 8 end
            end,
        },


        summon_imp = {
            id = 688,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },


        summon_voidwalker = {
            id = 697,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "voidwalker" ) end,
        },


        summon_felhunter = {
            id = 691,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            essential = true,
            nomounted = true,

            bind = "summon_pet",

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function () summonPet( "felhunter" ) end,

            copy = { "summon_pet", 112869 }
        },


        summon_succubus = {
            id = 712,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "succubus" ) end,
        },


        unending_breath = {
            id = 5697,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 136148,

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

            toggle = "defensives",

            startsCombat = true,

            handler = function ()
                applyBuff( "unending_resolve" )
            end,
        },


        unstable_affliction = {
            id = 316099,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136228,

            handler = function ()
                applyDebuff( "target", "unstable_affliction" )

                if azerite.dreadful_calling.enabled then
                    gainChargeTime( "summon_darkglare", 1 )
                end
            end,
        },


        vile_taint = {
            id = 278350,
            cast = 1.5,
            cooldown = 20,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 1391774,

            handler = function ()
                applyDebuff( "target", "vile_taint" )
            end,
        },


        -- Warlock - Kyrian    - 312321 - scouring_tithe        (Scouring Tithe)
        scouring_tithe = {
            id = 312321,
            cast = 2,
            cooldown = 40,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 3565452,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "scouring_tithe" )
            end,

            auras = {
                scouring_tithe = {
                    id = 312321,
                    duration = 18,
                    max_stack = 1,
                },
            },
        },

        -- Warlock - Necrolord - 325289 - decimating_bolt       (Decimating Bolt)
        decimating_bolt = {
            id = 325289,
            cast = 2.5,
            cooldown = 45,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 3578232,

            toggle = "essences",

            handler = function ()
                applyBuff( "decimating_bolt", nil, 3 )
            end,

            auras = {
                decimating_bolt = {
                    id = 325299,
                    duration = 3600,
                    max_stack = 3,
                }
            }
        },

        -- Warlock - Night Fae - 325640 - soul_rot              (Soul Rot)
        soul_rot = {
            id = 325640,
            cast = 1.5,
            cooldown = 60,
            gcd = "spell",

            spend = 0.2,
            spendType = "health",

            startsCombat = true,
            texture = 3636850,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "soul_rot" )
                active_dot.soul_rot = min( 4, active_enemies )
            end,

            auras = {
                soul_rot = {
                    id = 325640,
                    duration = 8,
                    max_stack = 1
                }
            }
        },

        -- Warlock - Venthyr   - 321792 - impending_catastrophe (Impending Catastrophe)
        impending_catastrophe = {
            id = 321792,
            cast = 2,
            cooldown = 60,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 3565726,

            toggle = "essences",

            velocity = 30,

            handler = function ()
                applyDebuff( "target", "impending_catastrophe" )
            end,
                
            auras = {
                impending_catastrophe = {
                    id = 322170,
                    duration = 12,
                    max_stack = 1,
                },
            }
        },


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20200830.2, [[dC0ddcqijvEKQe6sQsHnrs(KQeKgfrLtruAvQs1RqKMfrv3ssc7IWVus1WquoMsYYuk1ZukzAssQRPKY2uLs(MKe14uLsDovjW6KKi18iPCpLQ9ruCqvPOwOQKEOQuetusI4IssK0jvLIKvss1mvLIu3uvcc7usQLQkb1tjYuLu1vvLGOVkjrI9sv)LudgLdtzXuPhlXKr1LH2mv8zLy0QItR41iQMnWTvv7wQFlA4K44ssILRYZrA6cxhHTlP8DLIXljjDEeX6vLO5lj2pO9R817L4wG(Q3MSTjJS3ElYeBVART26T8sbjkOxsXkKBlOxQTp6LEZooGPet2EjfJeqACF9EjAsCf0l9eHcTk96RVmXdHROK)1PZNayXKD5mNyD68lR7LCjgq8MQ9UEjUfOV6TjBBYi7T3ImX2R2ISvR8sufS4RE73AnV0ZW5y7D9sCKw8sViK9MDCatjMSHSQuSdKfYHQ)Iq2tek0Q0RV(YepeUIs(xNoFcGft2LZCI1PZVSou9xeYu3Ac7ibY2EL8q22KTnzq1HQ)Iq2BYJ1liTknu9xeYQci7nZ5ihYKuqaaYEtNfYfq1FriRkGS3mNJCiRkbRLehK9cHTmfbu9xeYQci7fg)znKdzHDlyOhhHqav)fHSQaYEHXQcXCiKvLK1tHmcfilBilSBbdiZjpiRkbT4XnbbKjhD6cczh6Ci9bYa5YuGSHcz8XXbpSdiBCGS3KQekKzhcz8HAUaKlRaQ(lczvbK9cJkaRGqgfRHNbGSWUfmeX8rDKA(GqwXOifY2mXdKfZh1rQ5dczYHnhYshid7ss0bEYk8skx6ma0l9Iq2B2XbmLyYgYQsXoqwihQ(lczVzIfcAazBrM8q22KTnzq1HQ)Iq2BYJ1liTknu9xeYQci7nZ5ihYKuqaaYEtNfYfq1FriRkGS3mNJCiRkbRLehK9cHTmfbu9xeYQci7fg)znKdzHDlyOhhHqav)fHSQaYEHXQcXCiKvLK1tHmcfilBilSBbdiZjpiRkbT4XnbbKjhD6cczh6Ci9bYa5YuGSHcz8XXbpSdiBCGS3KQekKzhcz8HAUaKlRaQ(lczvbK9cJkaRGqgfRHNbGSWUfmeX8rDKA(GqwXOifY2mXdKfZh1rQ5dczYHnhYshid7ss0bEYkGQdv)fHSQuRQyHiqoK5Io5Hqwj)UwazU4Y0ubK9MlfujOqwNDv8y33HaazwjMSPqw2aseq1FriZkXKnvOCyj)UwS7amk5q1FriZkXKnvOCyj)Uwq6(6ozYHQ)IqMvIjBQq5Ws(DTG091nILp2Hft2q1TsmztfkhwYVRfKUVoL4)ZwRGbuDRet2uHYHL87AbP7RVCZpNd1PJMALBCMck)4Shga7qSCZpNd1PJMALBCMckW2CbihQ(lczwjMSPcLdl531cs3xN2Mc9jdnnSGcv3kXKnvOCyj)Uwq6(6kzmzdv3kXKnvOCyj)Uwq6(6euupb(LVTpUBVK(yNr1ozh60rRKBWdQUvIjBQq5Ws(DTG091PiY1PJUK3rOet2Ypo7ufea0HDlyqfue560rxY7iuIjBTLOm7BPQoSQqmkkixS6TEbBTQQHQBLyYMkuoSKFxliDF9hJOdO6wjMSPcLdl531cs3xN(y8CJ2nbH8JZEDHbWoepgrhcSnxaYvrvqaqh2TGbvqrKRthDjVJqjMS1wIQTLQ6WQcXOOGCXQ36fS1QQgQou9xeYQsTQIfIa5qgwdpsGSy(iKfpiKzLipiBOqMvZgG5cqbuDRet20DQccaAqwihQUvIjBkP7RZXAjXP)2YuGQBLyYMs6(61SBmxakFBFCNGIAkIC5RzacCpma2HGMB0XdQPiYPcSnxaYvrvqaqh2TGbvqrKRthDjVJqjMS1wIYSVfPNnCnwd7qmDncqJN5cqbHsLkHbWoe0r5jBnyCqb2Mla5QOkiaOd7wWGkOiY1PJUK3rOet2YSVgPNnCnwd7qmDncqJN5cqbHsLkufea0HDlyqfue560rxY7iuIjBz2FBspB4ASg2Hy6AeGgpZfGccfO6wjMSPKUVEn7gZfGY32h3vmoF6f5tLDkgYxZae4UvIjBb9X45gTBccbwvXcrG6y(472lXBcuumAX4tVOlgW(tqIaBZfGCO6wjMSPKUVEn7gZfGY32h3vmoF6f5tL9dPyiFndqG7lfU8JZU9s8MaffJwm(0l6IbS)eKiW2CbixLCHbWoe8ZMwttcGaBZfG8kvuQPega7qWrlECtqiW2Cbixvjtap30coAXJBccXHFBAQA7lfUSq1TsmztjDF9A2nMlaLVTpU)TPdBAnfLVMbiWDQcca6WUfmOckICD6Ol5DekXKT2suT9vKgga7qS5M4b1tRTLSjrGT5cqoPHbWoeMlnbebQl5DekXKTaBZfG833Mu5cdGDi2Ct8G6P12s2KiW2CbixvyaSdbn3OJhutrKtfyBUaKRIQGaGoSBbdQGIixNo6sEhHsmzRTeLzBzjvUWayhc6O8KTgmoOaBZfGCv1fga7quoevMErZrlEeyBUaKRQUWayhc(ztRPjbqGT5cqUSKE2W1ynSdX01ianEMlafekq1TsmztjDF9A2nMlaLVTpUZZGQjuKVMbiWD5Qlma2HGokpzRbJdkW2CbiVsfEgc6O8KTgmoOGqrwv8me2s2KiOHvixM9vKPQoEgcBjBseh6Ci9XCbOkEgIsEhHsmzliuuXZqq00WCbO2CCatjMSfekq1TsmztjDF9IbaARet2AWqd5B7J7Lmb8CttHQBLyYMs6(68ZMwttcG8th4DekHEbKUgyFL8LhB69vYxiPaqDy3cg09vYpo7X8rDKA(GQTVu4QOjbqtFSJR2Aq1TsmztjDF9hJOd5hNDQcca6WUfmOckICD6Ol5DekXKT2suT9Tj9SHRXAyhIPRraA8mxakiuGQBLyYMs6(6uI)pBn3oYxa2HYpo71SBmxak4zq1ekQ4ziiAAyUauBooGPet2Id)20uzkgn0X8rvYvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20uzvjxDk1ucdGDi4OfpUjieyBUaKxPsjtap30coAXJBccXHFBAQA7lfELk1vYeWZnTGJw84MGqC43MMwPcnjaA6JD8DYurvqaqh2TGbvqrKRthDjVJqjMS1wIYSI0ZgUgRHDiMUgbOXZCbOGqrwO6wjMSPKUVohT4XnbH8JZEjtap30ckX)NTMBh5la7qXHFBAQQA2nMlaf8mOAcfvufea0HDlyqfue560rxY7iuIjBTL4(kspB4ASg2Hy6AeGgpZfGccfvYvhsPyxqrTHozRthTcEoyjMSf)PZtvD2lXBcuWp04oeaDXaGPxeN1KxPsjtap30ckX)NTMBh5la7qXHFBAQmBrMSq1TsmztjDF94b1eTBs0CTtEfu(Xz3LWXrCyHCasPAN8kO4WVnnfQUvIjBkP7RBlztI8fskauh2TGbDFL8JZ(HFBAQA7lfoPwjMSf0hJNB0UjieyvflebQJ5JQI5J6i18bL5THQBLyYMs6(6F8Nhj60rdikdxZp0(u5hN9y(OABrgu9xeYQh)k5zhjqMZuvHSiHSVroczuIdHm7L0h7SxOuiZj7aY4js7xObK5EOroKXTJ8fGDiKrqTfuav3kXKnL091TLSjrEW0OUW33Im5hN9y(OmBrMQsMaEUPfuI)pBn3oYxa2HId)20u12xTMkSQqmkkixS6TEbBTQQHQBLyYMs6(6L8ocLyYwEW0OUW33Im5hN9y(OmBrMQsMaEUPfuI)pBn3oYxa2HId)20u12xTMkSQqmkkixS6TEbBTQQvvxyaSdH5starG6sEhHsmzlW2CbixLCHbWoe0r5jBnyCqb2Mla5vQqvqaqh2TGbvqrKRthDjVJqjMS1wIYSsfvbbaDy3cgubfrUoD0L8ocLyYwBjQ2(wYcv3kXKnL091PJYt2AW4GYdMg1f((wKj)4ShZhLzlYuvYeWZnTGs8)zR52r(cWouC43MMQ2(Q1uHvfIrrb5IvV1lyRvvnuDRet2us3xNOPH5cqT54aMsmzl)4SBLyQHAEgcIMgMla1MJdykXK9ozvQihpdbrtdZfGAZXbmLyYwqOO6qNdPpMlaLfQUvIjBkP7RZpBAnnjaYxiPaqDy3cg09vYxSUGa94ShtHCQ(WVnTARj)4SxZUXCbO4Bth20AkQIJUeooc6JXZnA87Ewbfh(TPPQ4OlHJJG(y8CJg)UNvqXHFBAQA7lf(7Bdv3kXKnL091Ppgp3ODtqiFHKca1HDlyq3xj)4SxZUXCbO4Bth20AkQIJUeooc6JXZnA87Ewbfh(TPPQ4OlHJJG(y8CJg)UNvqXHFBAQA7yvflebQJ5JVVnPXz1qGoMpQQoRet2c6JXZnA3eeIP1oGz5jGQBLyYMs6(6kpwh5xtNEHay3eKiFHKca1HDlyq3xj)4ShZhLzR1uf2TGHiMpQJuZhuMvV17ufea0pgnqvYvhsPyxqrTHozRthTcEoyjMSf)PZtvD2lXBcuWp04oeaDXaGPxeN1KxPsjtap30ckX)NTMBh5la7qXHFBAQmv9AKstcGM(yh)D7L4nbk4hAChcGUyaW0lIZAYRuPKjGNBAbL4)ZwZTJ8fGDO4WVnnvTvR9ovbba9JrdKuAsa00h74VBVeVjqb)qJ7qa0fdaMErCwtUSq1TsmztjDFDkICD6Ol5DekXKT8JZEn7gZfGcckQPiYvrtcGM(yhFFnO6wjMSPKUVEXaaTvIjBnyOH8T9XDEguO6wjMSPKUVETbG6WMoKVqsbG6WUfmO7RKFC2J5JYSAnvX8rDKA(GYSVImvYvYeWZnTGs8)zR52r(cWouC43MMkZwKvPsjtap30ckX)NTMBh5la7qXHFBAQARitfpdHTKnjId)20uz2xrMkEgIsEhHsmzlo8BttLzFfzQKJNHGokpzRbJdko8BttLzFfzvQuxyaSdbDuEYwdghuGT5cqUSYcv3kXKnL091jOOEc8lFBFC3Ej9XoJQDYo0PJwj3GN8JZEmFuT9TGQBLyYMs6(6kpwh5xtNEHay3eKi)4ShZhvBFR1GQBLyYMs6(61gaQdB6q(XzpMpQ2Q1GQBLyYMs6(6le2XhR1PJ2EjEz8i)4Slxjtap30ckX)NTMBh5la7qXHFBAQARwJuAsa00h74VBVeVjqb)qJ7qa0fdaMErGT5cqELkYzVeVjqb)qJ7qa0fdaMErCwtELkiLIDbf1g6KToD0k45GLyYwCwtUSQI5JYSfzQI5J6i18bLzF7vKjRk54ziuESoYVMo9cbWUjirC43MMwPcpdrTbG6WMoeh(TPPvQuxyaSdHYJ1r(10Pxia2nbjcSnxaYvvxyaSdrTbG6WMoeyBUaKlBLkX8rDKA(GQTfzKUu4q1TsmztjDFDUDKRPjbq(XzVKjGNBAbL4)ZwZTJ8fGDO4WVnnvTvRrknjaA6JD83TxI3eOGFOXDia6IbatViW2CbixLC8mekpwh5xtNEHay3eKio8BttRuHNHO2aqDythId)20uzHQBLyYMs6(6U4rXJ8PxGQBLyYMs6(6fda0wjMS1GHgY32h3PkyZXJcv3kXKnL091lgaOTsmzRbdnKVTpU7maaEuO6q1TsmztfLmb8Ctt33KhGxdNwFinBRliuDRet2urjtap30us3xNGI6jWV8T9XD7L0h7mQ2j7qNoALCdEYpo7YvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20u1Q63PkiaOFmAGvQuxjtap30cLhRJ8RPtVqaSBcseh(TPPYQQKjGNBAbL4)ZwZTJ8fGDO4WVnnvTvVG3PkiaOFmAGKstcGM(yh)D7L4nbk4hAChcGUyaW0lIZAYvXZqylztI4WVnnvfpdrjVJqjMSfh(TPPQKJNHGokpzRbJdko8BttRuPUWayhc6O8KTgmoOaBZfGCzHQBLyYMkkzc45MMs6(6kzmzl)4SlxyaSdb3oY10KaO)dfpseyBUaKRQKjGNBAbL4)ZwZTJ8fGDOGqrvjtap30cUDKRPjbqqOiBLkLmb8CtlOe)F2AUDKVaSdfekvQeZh1rQ5dQ2wKbv3kXKnvuYeWZnnL091jOOEc8tLFC2lzc45Mwqj()S1C7iFbyhko8BttLPktwLkX8rDKA(GQTnzvQihpdbrtdZfGAZXbmLyYwetH8PxurtcGM(yhFNmvYvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20uzvjxDk1ucdGDi4OfpUjieyBUaKxPsjtap30coAXJBccXHFBAQA7lfELk1vYeWZnTGJw84MGqC43MMkRQ6kzc45Mwqj()S1C7iFbyhko8BttLfQUvIjBQOKjGNBAkP7R7mh6cYKl)4Sxxjtap30ckX)NTMBh5la7qbHcuDRet2urjtap30us3x3fKjx7qCKi)4Sxxjtap30ckX)NTMBh5la7qbHcuDRet2urjtap30us3x)J)8irNoAarz4A(H2Nk)4ShZhLzlYGQBLyYMkkzc45MMs6(6C7ixttcG8JZEmFuhPMpOABtgPlfELkHbWoe0CJoEqnfrovGT5cqUQsMaEUPfuI)pBn3oYxa2HId)20uz2lzc45Mwqj()S1C7iFbyhk4eNft2vXkYGQBLyYMkkzc45MMs6(6UGm560rhpOgB8tI8JZUcgcUDKVaSdfh(TPPvQixDLmb8Ctl4OfpUjieh(TPPvQuNsnLWayhcoAXJBccb2Mla5YQQKjGNBAbL4)ZwZTJ8fGDO4WVnnvM93MmviLIDbfUGm560rhpOgB8tI4SMCzwbv)fHSxiPiKXTVTm9cKLDvqqrilUPjhdkK9ZdHS8GmasPqw2qwjtap30Ydz0eYazVazgfYIheYEt9MuLazXdscKnDH4GSnz)cnGm0XblbKznjqwgp4bzXnn5yqHmcQTGqgN4MEbYkzc45MMkGQBLyYMkkzc45MMs6(6euupb(LVTpURKfYXGoVe56s(viclMS1CS2uq5hND5kzc45Mwqj()S1C7iFbyhko8BttLzF71QujMpQJuZhuT9TitwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKlluDRet2urjtap30us3xNGI6jWV8T9X9lJYrqdKRRLjptnpba5hND5kzc45Mwqj()S1C7iFbyhko8BttLzF71QujMpQJuZhuT9TitwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKlluDRet2urjtap30us3xNGI6jWV8T9XD6ZudpDnSZV(qWuKFC2LRKjGNBAbL4)ZwZTJ8fGDO4WVnnvM9TxRsLy(OosnFq123Imzvjxjtap30coAXJBccXHFBAALk1Putjma2HGJw84MGqGT5cqUSq1TsmztfLmb8CttjDFDckQNa)Y32h3TQcXOKb2HUnIyaeu5hND5kzc45Mwqj()S1C7iFbyhko8BttLzF71QujMpQJuZhuT9TitwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKlluDRet2urjtap30us3xNGI6jWV8T9X9y4inY7RljhRQYpo7YvYeWZnTGs8)zR52r(cWouC43MMkZ(2RvPsmFuhPMpOA7BrMSQKRKjGNBAbhT4XnbH4WVnnTsL6uQPega7qWrlECtqiW2CbixwO6wjMSPIsMaEUPPKUVobf1tGF5B7J71gdOthnnY7tLFC2LRKjGNBAbL4)ZwZTJ8fGDO4WVnnvM9TxRsLy(OosnFq123Imzvjxjtap30coAXJBccXHFBAALk1Putjma2HGJw84MGqGT5cqUSq1TsmztfLmb8CttjDF9BuuaOEAnvXkiuDRet2urjtap30us3xNwsIB6fDmXdk)4SxZUXCbOGNbvtOav3kXKnvuYeWZnnL091NVc28Px0flmACPYdk)4SxZUXCbOGNbvtOav3kXKnvuYeWZnnL091PjbqFzi)4SBLyQHASX)GuzwPQMDJ5cqbpdQMqbQUvIjBQOKjGNBAkP7RZXY8Ty6fTBcc5hN9A2nMlaf8mOAcfvYf2TGH4bnq8OvkHARrwLkoZYtOp8BttLznYKfQouDRet2ub3vFOZH0ND6O8KTgmoO8GPrDHVVAn5hND54ziOJYt2AW4GId)2003GNHGokpzRbJdk4eNft2YQ2UC8me2s2Kio8BttFdEgcBjBseCIZIjBzvjhpdbDuEYwdghuC43MM(g8me0r5jBnyCqbN4SyYww12LJNHOK3rOet2Id)2003GNHOK3rOet2coXzXKTSQ4ziOJYt2AW4GId)20u14ziOJYt2AW4GcoXzXK97ReBbv3kXKnvWD1h6Ci9H091TLSjrEW0OUW3xTM8JZUC8me2s2Kio8BttFdEgcBjBseCIZIjBzvBxoEgIsEhHsmzlo8BttFdEgIsEhHsmzl4eNft2YQsoEgcBjBseh(TPPVbpdHTKnjcoXzXKTSQTlhpdbDuEYwdghuC43MM(g8me0r5jBnyCqbN4SyYwwv8me2s2Kio8BttvJNHWwYMebN4SyY(9vITGQBLyYMk4U6dDoK(q6(6L8ocLyYwEW0OUW3xTM8JZUC8meL8ocLyYwC43MM(g8meL8ocLyYwWjolMSLvTD54ziSLSjrC43MM(g8me2s2Ki4eNft2YQsoEgIsEhHsmzlo8BttFdEgIsEhHsmzl4eNft2YQ2UC8me0r5jBnyCqXHFBA6BWZqqhLNS1GXbfCIZIjBzvXZquY7iuIjBXHFBAQA8meL8ocLyYwWjolMSFFLylO6q1Tsmztf8mO7ue560rxY7iuIjB5hNDEgIsEhHsmzlo8BttvB3kXKTGIixNo6sEhHsmzlkgn0X8rsJ5J6i10h74Kw1ITFxUvvryaSdr5quz6fnhT4rGT5cq(7KjwTMSQOkiaOd7wWGkOiY1PJUK3rOet2Alrz23I0ZgUgRHDiMUgbOXZCbOGqH0WayhIn3epOEATTKnjcSnxaYvvhpdbfrUoD0L8ocLyYwC43MMQQoRet2ckICD6Ol5DekXKTyATdywEcO6wjMSPcEgus3x3wYMe5lKuaOoSBbd6(k5hN9WayhIYHOY0lAoAXJaBZfGCvwjMAOMNHWwYMe1ElvX8rDKA(GYSImvYD43MMQ2(sHxPsjtap30ckX)NTMBh5la7qXHFBAQmRitLCh(TPPQTwLk1zVeVjqHI1C8pf901YIft2IZAYvDOZH0hZfGYkluDRet2ubpdkP7RBlztI8fskauh2TGbDFL8JZEDHbWoeLdrLPx0C0Ihb2Mla5QSsm1qnpdHTKnjQ92QI5J6i18bLzfzQK7WVnnvT9LcVsLsMaEUPfuI)pBn3oYxa2HId)20uzwrMk5o8BttvBTkvQZEjEtGcfR54Fk6PRLflMSfN1KR6qNdPpMlaLvwO6wjMSPcEgus3xNokpzRbJdkFHKca1HDlyq3xj)4SlNvIPgQ5ziOJYt2AW4GQ92vryaSdr5quz6fnhT4rGT5cqEvqvqaqh2TGbvqZn64b1ue5uTLOSQI5J6i18bLzfzQo05q6J5cqvYv3HFBAQkQcca6WUfmOckICD6Ol5DekXKT2sCFvLkLmb8CtlOe)F2AUDKVaSdfh(TPPYqtcGM(yh)DRet2cIMgMla1MJdykXKTaRQyHiqDmFuwO6wjMSPcEgus3xVK3rOet2YxiPaqDy3cg09vYpo7ufea0HDlyqfue560rxY7iuIjBTLOABr6zdxJ1WoetxJa04zUauqOqAyaSdXMBIhupT2wYMeb2Mla5QK7WVnnvT9LcVsLsMaEUPfuI)pBn3oYxa2HId)20uzwrMQdDoK(yUauwvHDlyiI5J6i18bLzfzq1Tsmztf8mOKUVortdZfGAZXbmLyYw(Xz)qNdPpMlaHQdv3kXKnv4maaE0DIMgMla1MJdykXKT8GPrDHVVAn5hN9sMaEUPfC0Ih3eeId)20u12xk833wfvbbaDy3cgubfrUoD0L8ocLyYwBjUVI0ZgUgRHDiMUgbOXZCbOGqrvjtap30ckX)NTMBh5la7qXHFBAQmBtguDRet2uHZaa4rjDF9IbaARet2AWqd5B7J7Cx9HohsFKFC2vQPega7qWrlECtqiW2CbixfvbbaDy3cgubfrUoD0L8ocLyYwBjUVI0ZgUgRHDiMUgbOXZCbOGqrLC8me2s2Kio8BttvJNHWwYMebN4SyY(DYev51QuHNHOK3rOet2Id)20u14zik5DekXKTGtCwmz)ozIQ8AvQWZqqhLNS1GXbfh(TPPQXZqqhLNS1GXbfCIZIj73jtuLxtwvLmb8Ctl4OfpUjieh(TPPQTBLyYwylztIyPWFVQvvYeWZnTGs8)zR52r(cWouC43MMkZ2Kbv3kXKnv4maaEus3xVyaG2kXKTgm0q(2(4o3vFOZH0h5hNDLAkHbWoeC0Ih3eecSnxaYvrvqaqh2TGbvqrKRthDjVJqjMS1wI7Ri9SHRXAyhIPRraA8mxakiuuvYeWZnTGs8)zR52r(cWouC43MMQ2onjaA6JD83TsmzlSLSjrSu4KALyYwylztIyPWFFlvYXZqylztI4WVnnvnEgcBjBseCIZIj73xvPcpdrjVJqjMSfh(TPPQXZquY7iuIjBbN4SyY(9vvQWZqqhLNS1GXbfh(TPPQXZqqhLNS1GXbfCIZIj73xjluDRet2uHZaa4rjDFDoAXJBcc5hN9A2nMlaf8mOAcfvYvYeWZnTGs8)zR52r(cWouC43MMkZ(wKr6sHxPsjtap30ckX)NTMBh5la7qXHFBAQmwjMSfuI)pBn3oYxa2HIsMaEUPRITjtwO6wjMSPcNbaWJs6(60hJNB0UjiKFC2DjCCe)Sg(XoeekQCjCCe9S8eogaio8BttHQBLyYMkCgaapkP7RBlztI8JZUlHJJ4N1Wp2HGqrvDYfga7qqhLNS1GXbfyBUaKRsoLdRPxkCXkHTKnjQuoSMEPWfBlSLSjrLYH10lfUylHTKnjYwPIYH10lfUyLWwYMezHQBLyYMkCgaapkP7RthLNS1GXbLFC2DjCCe)Sg(XoeekQQtoLdRPxkCXkbDuEYwdghuLYH10lfUyBbDuEYwdghuLYH10lfUylbDuEYwdghuwO6wjMSPcNbaWJs6(6L8ocLyYw(Xz3LWXr8ZA4h7qqOOQoLdRPxkCXkrjVJqjMSvvxyaSdH5starG6sEhHsmzlW2CbihQUvIjBQWzaa8OKUVortdZfGAZXbmLyYw(Xz)qNdPpMlaHQBLyYMkCgaapkP7RZpBAnyCq5hNDxchhX0yTjmxaQ54FOOGgwHCzwrMQy(OosnFq12xrguDRet2uHZaa4rjDFD(ztRbJdk)4Shga7qqhLNS1GXbfyBUaKRYLWXrmnwBcZfGAo(hkkOHvixM91iRk2MS3LJQGaGoSBbdQGIixNo6sEhHsmzRTeRIZgUgRHDiMUgbOXZCbOGqrM9TLvfpdHTKnjId)20uzw7DQcca6hJgOkEgIsEhHsmzlo8BttLzPWvjhpdbDuEYwdghuC43MMkZsHxPsDHbWoe0r5jBnyCqb2Mla5YQsoo6s44iEmIoeh(TPPYS27ufea0pgnWkvQlma2H4Xi6qGT5cqUSQkzh2YKTmR9ovbba9JrdeQUvIjBQWzaa8OKUVo)SP1GXbLFC2ddGDi2Ct8G6P12s2KiW2CbixLlHJJyAS2eMla1C8puuqdRqUm7RrwvSnzVlhvbbaDy3cgubfrUoD0L8ocLyYwBjwfNnCnwd7qmDncqJN5cqbHIm7BjBvS27Yrvqaqh2TGbvqrKRthDjVJqjMS1wIvXzdxJ1WoetxJa04zUauqOSVTSQ4ziSLSjrC43MMkZAVtvqaq)y0avXZquY7iuIjBXHFBAQmlfUk54OlHJJ4Xi6qC43MMkZAVtvqaq)y0aRuPUWayhIhJOdb2Mla5YQQKDylt2YS27ufea0pgnqO6wjMSPcNbaWJs6(68ZMwdghu(Xzpma2HWCPjGiqDjVJqjMSfyBUaKRYLWXrmnwBcZfGAo(hkkOHvixM91iRk2MS3LJQGaGoSBbdQGIixNo6sEhHsmzRTeRIZgUgRHDiMUgbOXZCbOGqrM9Qwwv8me2s2Kio8BttLzT3PkiaOFmAGQKJJUeooIhJOdXHFBAQmR9ovbba9JrdSsL6cdGDiEmIoeyBUaKlRQs2HTmzlZAVtvqaq)y0aHQBLyYMkCgaapkP7RZpBAnyCq5hNDxchhX0yTjmxaQ54FOOGgwHCz2MmvwjMAOMNHGMea9LHmKvPIlHJJyAS2eMla1C8puuqdRqUmvnzq1TsmztfodaGhL091FmIoGQBLyYMkCgaapkP7R7KfckY12lXBcu7I2hQUvIjBQWzaa8OKUVUcXnoKm9I2fy0aQUvIjBQWzaa8OKUVEj7c2XzbY1oa7JYpo71XZquYUGDCwGCTdW(O2L4AXHFBAQQ6SsmzlkzxWoolqU2byFumT2bmlpbuDRet2uHZaa4rjDFD(ztRPjbq(Pd8ocLqVasxdSVs(YJn9(k5NoW7iuI9vYxiPaqDy3cg09vYpo7X8rDKA(GQTVu4q1TsmztfodaGhL0915NnTMMea5lKuaOoSBbd6(k5lp207RKF6aVJqj0JZEmfYP6d)20QTM8th4DekHEbKUgyFL8JZEn7gZfGIVnDytRPOQ64OlHJJG(y8CJg)UNvqXHFBAkuDRet2uHZaa4rjDFD(ztRPjbq(cjfaQd7wWGUVs(YJn9(k5NoW7iuc94ShtHCQ(WVnTARj)0bEhHsOxaPRb2xj)4SxZUXCbO4Bth20Akcv3kXKnv4maaEus3xNF20AAsaKF6aVJqj0lG01a7RKV8ytVVs(Pd8ocLyFfuDRet2uHZaa4rjDFD6JXZnA3eeYxiPaqDy3cg09vYpo71SBmxak(20HnTMIQQJJUeooc6JXZnA87Ewbfh(TPPQQZkXKTG(y8CJ2nbHyATdywEcO6wjMSPcNbaWJs6(60hJNB0UjiKVqsbG6WUfmO7RKFC2Rz3yUau8TPdBAnfHQBLyYMkCgaapkP7RtFmEUr7MGaQouDRet2ubvbBoE09VbqNPOptjiou(XzVMDJ5cqbpdQMqbQUvIjBQGQGnhpkP7RtrKRthDjVJqjMSLFC2Rz3yUauqqrnfrUxQgE0jBF1Bt22Kr2BVfzEPn21tVq9sVP(k5fihYQYqMvIjBidm0GkGQ7LmI4jpVK08Ft8sGHguF9EjUR(qNdPp(69vVYxVxcBZfGC)REjRet2Ej6O8KTgmoOxQCtG3yEj5GmEgc6O8KTgmoO4WVnnfYEdiJNHGokpzRbJdk4eNft2qMSqMA7qMCqgpdHTKnjId)20ui7nGmEgcBjBseCIZIjBitwitfKjhKXZqqhLNS1GXbfh(TPPq2Baz8me0r5jBnyCqbN4SyYgYKfYuBhYKdY4zik5DekXKT4WVnnfYEdiJNHOK3rOet2coXzXKnKjlKPcY4ziOJYt2AW4GId)20uitniJNHGokpzRbJdk4eNft2q27q2kXwEjW0OUW9sRwZh(Q32xVxcBZfGC)REjRet2EjBjBs8sLBc8gZljhKXZqylztI4WVnnfYEdiJNHWwYMebN4SyYgYKfYuBhYKdY4zik5DekXKT4WVnnfYEdiJNHOK3rOet2coXzXKnKjlKPcYKdY4ziSLSjrC43MMczVbKXZqylztIGtCwmzdzYczQTdzYbz8me0r5jBnyCqXHFBAkK9gqgpdbDuEYwdghuWjolMSHmzHmvqgpdHTKnjId)20uitniJNHWwYMebN4SyYgYEhYwj2YlbMg1fUxA1A(Wx9w(69syBUaK7F1lzLyY2lvY7iuIjBVu5MaVX8sYbz8meL8ocLyYwC43MMczVbKXZquY7iuIjBbN4SyYgYKfYuBhYKdY4ziSLSjrC43MMczVbKXZqylztIGtCwmzdzYczQGm5GmEgIsEhHsmzlo8BttHS3aY4zik5DekXKTGtCwmzdzYczQTdzYbz8me0r5jBnyCqXHFBAkK9gqgpdbDuEYwdghuWjolMSHmzHmvqgpdrjVJqjMSfh(TPPqMAqgpdrjVJqjMSfCIZIjBi7DiBLylVeyAux4EPvR5dF4L4OJracF9(Qx5R3lzLyY2lrvqaqdYc5EjSnxaY9V6dF1B7R3lzLyY2lXXAjXP)2Yu8syBUaK7F1h(Q3YxVxcBZfGC)REPuXlrXWlzLyY2lvZUXCbOxQMbiqVuyaSdbn3OJhutrKtfyBUaKdzQGmQcca6WUfmOckICD6Ol5DekXKT2seYKzhY2cYifYoB4ASg2Hy6AeGgpZfGccfiRsfilma2HGokpzRbJdkW2CbihYubzufea0HDlyqfue560rxY7iuIjBitMDiBniJui7SHRXAyhIPRraA8mxakiuGSkvGmQcca6WUfmOckICD6Ol5DekXKnKjZoK92qgPq2zdxJ1WoetxJa04zUauqO4LQzNUTp6LiOOMIi3h(QRAF9EjSnxaY9V6LsfVefdVKvIjBVun7gZfGEPAgGa9swjMSf0hJNB0UjieyvflebQJ5Jq27qM9s8MaffJwm(0l6IbS)eKiW2Cbi3lvZoDBF0lPyC(0l(Wx9A(69syBUaK7F1lLkEPdPy4LSsmz7LQz3yUa0lvZaeOxAPW9sLBc8gZlzVeVjqrXOfJp9IUya7pbjcSnxaYHmvqMCqwyaSdb)SP10KaiW2CbihYQubYuQPega7qWrlECtqiW2CbihYubzLmb8Ctl4OfpUjieh(TPPqMA7q2sHdzY6LQzNUTp6LumoF6fF4R(T817LW2Cbi3)Qxkv8sum8swjMS9s1SBmxa6LQzac0lrvqaqh2TGbvqrKRthDjVJqjMS1wIqMA7q2kiJuilma2HyZnXdQNwBlztIaBZfGCiJuilma2HWCPjGiqDjVJqjMSfyBUaKdzVdzBdzKczYbzHbWoeBUjEq90ABjBseyBUaKdzQGSWayhcAUrhpOMIiNkW2CbihYubzufea0HDlyqfue560rxY7iuIjBTLiKjdKTnKjlKrkKjhKfga7qqhLNS1GXbfyBUaKdzQGS6GSWayhIYHOY0lAoAXJaBZfGCitfKvhKfga7qWpBAnnjacSnxaYHmzHmsHSZgUgRHDiMUgbOXZCbOGqXlvZoDBF0l9TPdBAnf9HV6QSVEVe2Mla5(x9sPIxIIHxYkXKTxQMDJ5cqVundqGEj5GS6GSWayhc6O8KTgmoOaBZfGCiRsfiJNHGokpzRbJdkiuGmzHmvqgpdHTKnjcAyfYHmz2HSvKbzQGS6GmEgcBjBseh6Ci9XCbiKPcY4zik5DekXKTGqbYubz8meennmxaQnhhWuIjBbHIxQMD62(OxINbvtO4dF1VTVEVe2Mla5(x9swjMS9sfda0wjMS1GHgEjWqdDBF0lvYeWZnn1h(QFb(69syBUaK7F1lzLyY2lXpBAnnjaEPcjfaQd7wWG6RELxQCtG3yEPy(OosnFqitTDiBPWHmvqgnjaA6JDCitniBnVu5XM2lTYlnDG3rOe6fq6AaV0kF4REfz(69syBUaK7F1lvUjWBmVevbbaDy3cgubfrUoD0L8ocLyYwBjczQTdzBdzKczNnCnwd7qmDncqJN5cqbHIxYkXKTx6Xi6Wh(QxTYxVxcBZfGC)REPYnbEJ5LQz3yUauWZGQjuGmvqgpdbrtdZfGAZXbmLyYwC43MMczYazfJg6y(iKPcYKdYQdYcdGDiuESoYVMo9cbWUjirGT5cqoKvPcKvYeWZnTq5X6i)A60lea7MGeXHFBAkKjlKPcYKdYQdYuQPega7qWrlECtqiW2CbihYQubYkzc45MwWrlECtqio8BttHm12HSLchYQubYQdYkzc45MwWrlECtqio8BttHSkvGmAsa00h74q2oKrgKPcYOkiaOd7wWGkOiY1PJUK3rOet2AlritgiBfKrkKD2W1ynSdX01ianEMlafekqMSEjRet2EjkX)NTMBh5la7qF4RE12(69syBUaK7F1lvUjWBmVujtap30ckX)NTMBh5la7qXHFBAkKPcYQz3yUauWZGQjuGmvqgvbbaDy3cgubfrUoD0L8ocLyYwBjcz7q2kiJui7SHRXAyhIPRraA8mxakiuGmvqMCqwDqgsPyxqrTHozRthTcEoyjMSf)PZdYubz1bz2lXBcuWp04oeaDXaGPxeN1KdzvQazLmb8CtlOe)F2AUDKVaSdfh(TPPqMmq2wKbzY6LSsmz7L4OfpUji8HV6vB5R3lHT5cqU)vVu5MaVX8sUeooIdlKdqkv7Kxbfh(TPPEjRet2EP4b1eTBs0CTtEf0h(Qxv1(69syBUaK7F1lzLyY2lzlztIxQCtG3yEPd)20uitTDiBPWHmsHmRet2c6JXZnA3eecSQIfIa1X8ritfKfZh1rQ5dczYazVTxQqsbG6WUfmO(Qx5dF1RwZxVxcBZfGC)REPYnbEJ5LI5JqMAq2wK5LSsmz7L(4pps0PJgqugUMFO9P(Wx9Q3YxVxcBZfGC)REjRet2EjBjBs8sLBc8gZlfZhHmzGSTidYubzLmb8CtlOe)F2AUDKVaSdfh(TPPqMA7q2Q1GmvqgwvigffKlSxsFSZOANSdD6OvYn45LatJ6c3lTfz(Wx9QQSVEVe2Mla5(x9swjMS9sL8ocLyY2lvUjWBmVumFeYKbY2ImitfKvYeWZnTGs8)zR52r(cWouC43MMczQTdzRwdYubzyvHyuuqUWEj9XoJQDYo0PJwj3GhKPcYQdYcdGDimxAcicuxY7iuIjBb2Mla5qMkitoilma2HGokpzRbJdkW2CbihYQubYOkiaOd7wWGkOiY1PJUK3rOet2AlritgiBfKPcYOkiaOd7wWGkOiY1PJUK3rOet2AlritTDiBlitwVeyAux4EPTiZh(Qx92(69syBUaK7F1lzLyY2lrhLNS1GXb9sLBc8gZlfZhHmzGSTidYubzLmb8CtlOe)F2AUDKVaSdfh(TPPqMA7q2Q1GmvqgwvigffKlSxsFSZOANSdD6OvYn45LatJ6c3lTfz(Wx9QxGVEVe2Mla5(x9sLBc8gZlzLyQHAEgcIMgMla1MJdykXKnKTdzKbzvQazYbz8meennmxaQnhhWuIjBbHcKPcYo05q6J5cqitwVKvIjBVertdZfGAZXbmLyY2h(Q3MmF9EjSnxaY9V6LSsmz7L4NnTMMeaVuHKca1HDlyq9vVYlvSUGa944LIPqovF43MwT18sLBc8gZlvZUXCbO4Bth20AkczQGmo6s44iOpgp3OXV7zfuC43MMczQGmo6s44iOpgp3OXV7zfuC43MMczQTdzlfoK9oKTTp8vV9kF9EjSnxaY9V6LSsmz7LOpgp3ODtq4Lk3e4nMxQMDJ5cqX3MoSP1ueYubzC0LWXrqFmEUrJF3ZkO4WVnnfYubzC0LWXrqFmEUrJF3ZkO4WVnnfYuBhYWQkwicuhZhHS3HSTHmsHS4SAiqhZhHmvqwDqMvIjBb9X45gTBccX0AhWS8eEPcjfaQd7wWG6RELp8vV92(69syBUaK7F1lzLyY2lP8yDKFnD6fcGDtqIxQCtG3yEPy(iKjdKT1AqMkilSBbdrmFuhPMpiKjdKT6TGS3HmQcca6hJgiKPcYKdYQdYqkf7ckQn0jBD6OvWZblXKT4pDEqMkiRoiZEjEtGc(Hg3HaOlgam9I4SMCiRsfiRKjGNBAbL4)ZwZTJ8fGDO4WVnnfYKbYQ61GmsHmAsa00h74q27qM9s8Maf8dnUdbqxmay6fXzn5qwLkqwjtap30ckX)NTMBh5la7qXHFBAkKPgKTAni7DiJQGaG(XObczKcz0KaOPp2XHS3Hm7L4nbk4hAChcGUyaW0lIZAYHmz9sfskauh2TGb1x9kF4RE7T817LW2Cbi3)QxQCtG3yEPA2nMlafeuutrKdzQGmAsa00h74q2oKTMxYkXKTxIIixNo6sEhHsmz7dF1Bx1(69syBUaK7F1lzLyY2lvmaqBLyYwdgA4Ladn0T9rVepdQp8vV9A(69syBUaK7F1lzLyY2lvBaOoSPdVu5MaVX8sX8ritgiB1AqMkilMpQJuZheYKzhYwrgKPcYKdYkzc45Mwqj()S1C7iFbyhko8BttHmzGSTidYQubYkzc45Mwqj()S1C7iFbyhko8BttHm1GSvKbzQGmEgcBjBseh(TPPqMm7q2kYGmvqgpdrjVJqjMSfh(TPPqMm7q2kYGmvqMCqgpdbDuEYwdghuC43MMczYSdzRidYQubYQdYcdGDiOJYt2AW4GcSnxaYHmzHmz9sfskauh2TGb1x9kF4RE73YxVxcBZfGC)REjRet2Ej7L0h7mQ2j7qNoALCdEEPYnbEJ5LI5JqMA7q2wEP2(OxYEj9XoJQDYo0PJwj3GNp8vVDv2xVxcBZfGC)REPYnbEJ5LI5JqMA7q2wR5LSsmz7LuESoYVMo9cbWUjiXh(Q3(T917LW2Cbi3)QxQCtG3yEPy(iKPgKTAnVKvIjBVuTbG6WMo8HV6TFb(69syBUaK7F1lvUjWBmVKCqwjtap30ckX)NTMBh5la7qXHFBAkKPgKTAniJuiJMean9XooK9oKzVeVjqb)qJ7qa0fdaMErGT5cqoKvPcKjhKzVeVjqb)qJ7qa0fdaMErCwtoKvPcKHuk2fuuBOt260rRGNdwIjBXzn5qMSqMkilMpczYazBrgKPcYI5J6i18bHmz2HSTxrgKjlKPcYKdY4ziuESoYVMo9cbWUjirC43MMczvQaz8me1gaQdB6qC43MMczvQaz1bzHbWoekpwh5xtNEHay3eKiW2CbihYubz1bzHbWoe1gaQdB6qGT5cqoKjlKvPcKfZh1rQ5dczQbzBrgKrkKTu4EjRet2EPfc74J160rBVeVmE8HV6TiZxVxcBZfGC)REPYnbEJ5Lkzc45Mwqj()S1C7iFbyhko8BttHm1GSvRbzKcz0KaOPp2XHS3Hm7L4nbk4hAChcGUyaW0lcSnxaYHmvqMCqgpdHYJ1r(10Pxia2nbjId)20uiRsfiJNHO2aqDythId)20uitwVKvIjBVe3oY10Ka4dF1BTYxVxYkXKTxYfpkEKp9IxcBZfGC)R(Wx9wB7R3lHT5cqU)vVKvIjBVuXaaTvIjBnyOHxcm0q32h9sufS54r9HV6T2YxVxcBZfGC)REjRet2EPIbaARet2AWqdVeyOHUTp6LCgaapQp8Hxs5Ws(DTWxVV6v(69swjMS9suI)pBTdcEi6apVe2Mla5(x9HV6T917LW2Cbi3)QxQCtG3yEPWayhILB(5COoD0uRCJZuqb2Mla5EjRet2EPLB(5COoD0uRCJZuqF4RElF9EjRet2EjLmMS9syBUaK7F1h(QRAF9EjSnxaY9V6LA7JEj7L0h7mQ2j7qNoALCdEEjRet2Ej7L0h7mQ2j7qNoALCdE(Wx9A(69syBUaK7F1lvUjWBmVevbbaDy3cgubfrUoD0L8ocLyYwBjczYSdzBbzQGS6GmSQqmkkixyVK(yNr1ozh60rRKBWZlzLyY2lrrKRthDjVJqjMS9HV63YxVxYkXKTx6Xi6WlHT5cqU)vF4RUk7R3lHT5cqU)vVu5MaVX8s1bzHbWoepgrhcSnxaYHmvqgvbbaDy3cgubfrUoD0L8ocLyYwBjczQbzBbzQGS6GmSQqmkkixyVK(yNr1ozh60rRKBWZlzLyY2lrFmEUr7MGWh(WlvYeWZnn1xVV6v(69swjMS9sBYdWRHtRpKMT1f0lHT5cqU)vF4REBF9EjSnxaY9V6LSsmz7LSxsFSZOANSdD6OvYn45Lk3e4nMxsoiRoilma2Hq5X6i)A60lea7MGeb2Mla5qwLkqwjtap30cLhRJ8RPtVqaSBcseh(TPPqMAqwvdzVdzufea0pgnqiRsfiRoiRKjGNBAHYJ1r(10Pxia2nbjId)20uitwitfKvYeWZnTGs8)zR52r(cWouC43MMczQbzREbq27qgvbba9JrdeYifYOjbqtFSJdzVdz2lXBcuWp04oeaDXaGPxeN1KdzQGmEgcBjBseh(TPPqMkiJNHOK3rOet2Id)20uitfKjhKXZqqhLNS1GXbfh(TPPqwLkqwDqwyaSdbDuEYwdghuGT5cqoKjRxQTp6LSxsFSZOANSdD6OvYn45dF1B5R3lHT5cqU)vVu5MaVX8sYbzHbWoeC7ixttcG(pu8irGT5cqoKPcYkzc45Mwqj()S1C7iFbyhkiuGmvqwjtap30cUDKRPjbqqOazYczvQazLmb8CtlOe)F2AUDKVaSdfekqwLkqwmFuhPMpiKPgKTfzEjRet2EjLmMS9HV6Q2xVxcBZfGC)REPYnbEJ5Lkzc45Mwqj()S1C7iFbyhko8BttHmzGSQmzqwLkqwmFuhPMpiKPgKTnzqwLkqMCqgpdbrtdZfGAZXbmLyYwetH8PxGmvqgnjaA6JDCiBhYidYubzYbz1bzHbWoekpwh5xtNEHay3eKiW2CbihYQubYkzc45MwO8yDKFnD6fcGDtqI4WVnnfYKfYubzYbz1bzk1ucdGDi4OfpUjieyBUaKdzvQazLmb8Ctl4OfpUjieh(TPPqMA7q2sHdzvQaz1bzLmb8Ctl4OfpUjieh(TPPqMSqMkiRoiRKjGNBAbL4)ZwZTJ8fGDO4WVnnfYK1lzLyY2lrqr9e4N6dF1R5R3lHT5cqU)vVu5MaVX8s1bzLmb8CtlOe)F2AUDKVaSdfekEjRet2EjN5qxqMCF4R(T817LW2Cbi3)QxQCtG3yEP6GSsMaEUPfuI)pBn3oYxa2HccfVKvIjBVKlitU2H4iXh(QRY(69syBUaK7F1lvUjWBmVumFeYKbY2ImVKvIjBV0h)5rIoD0aIYW18dTp1h(QFBF9EjSnxaY9V6Lk3e4nMxkMpQJuZheYudY2MmiJuiBPWHSkvGSWayhcAUrhpOMIiNkW2CbihYubzLmb8CtlOe)F2AUDKVaSdfh(TPPqMm7qwjtap30ckX)NTMBh5la7qbN4SyYgYQciBfzEjRet2EjUDKRPjbWh(QFb(69syBUaK7F1lvUjWBmVKcgcUDKVaSdfh(TPPqwLkqMCqwDqwjtap30coAXJBccXHFBAkKvPcKvhKPutjma2HGJw84MGqGT5cqoKjlKPcYkzc45Mwqj()S1C7iFbyhko8BttHmz2HS3MmitfKHuk2fu4cYKRthD8GASXpjIZAYHmzGSvEjRet2EjxqMCD6OJhuJn(jXh(QxrMVEVe2Mla5(x9swjMS9skzHCmOZlrUUKFfIWIjBnhRnf0lvUjWBmVKCqwjtap30ckX)NTMBh5la7qXHFBAkKjZoKT9AqwLkqwmFuhPMpiKP2oKTfzqMSqMkitoiRKjGNBAbhT4XnbH4WVnnfYQubYQdYuQPega7qWrlECtqiW2CbihYK1l12h9skzHCmOZlrUUKFfIWIjBnhRnf0h(QxTYxVxcBZfGC)REjRet2EPlJYrqdKRRLjptnpbaVu5MaVX8sYbzLmb8CtlOe)F2AUDKVaSdfh(TPPqMm7q22RbzvQazX8rDKA(GqMA7q2wKbzYczQGm5GSsMaEUPfC0Ih3eeId)20uiRsfiRoitPMsyaSdbhT4XnbHaBZfGCitwVuBF0lDzuocAGCDTm5zQ5ja4dF1R22xVxcBZfGC)REjRet2Ej6ZudpDnSZV(qWu8sLBc8gZljhKvYeWZnTGs8)zR52r(cWouC43MMczYSdzBVgKvPcKfZh1rQ5dczQTdzBrgKjlKPcYKdYkzc45MwWrlECtqio8BttHSkvGS6GmLAkHbWoeC0Ih3eecSnxaYHmz9sT9rVe9zQHNUg25xFiyk(Wx9QT817LW2Cbi3)QxYkXKTxYQkeJsgyh62iIbqq9sLBc8gZljhKvYeWZnTGs8)zR52r(cWouC43MMczYSdzBVgKvPcKfZh1rQ5dczQTdzBrgKjlKPcYKdYkzc45MwWrlECtqio8BttHSkvGS6GmLAkHbWoeC0Ih3eecSnxaYHmz9sT9rVKvvigLmWo0TredGG6dF1RQAF9EjSnxaY9V6LSsmz7LIHJ0iVVUKCSQ6Lk3e4nMxsoiRKjGNBAbL4)ZwZTJ8fGDO4WVnnfYKzhY2EniRsfilMpQJuZheYuBhY2ImitwitfKjhKvYeWZnTGJw84MGqC43MMczvQaz1bzk1ucdGDi4OfpUjieyBUaKdzY6LA7JEPy4inY7RljhRQ(Wx9Q1817LW2Cbi3)QxYkXKTxQ2yaD6OPrEFQxQCtG3yEj5GSsMaEUPfuI)pBn3oYxa2HId)20uitMDiB71GSkvGSy(OosnFqitTDiBlYGmzHmvqMCqwjtap30coAXJBccXHFBAkKvPcKvhKPutjma2HGJw84MGqGT5cqoKjRxQTp6LQngqNoAAK3N6dF1RElF9EjRet2EPBuuaOEAnvXkOxcBZfGC)R(Wx9QQSVEVe2Mla5(x9sLBc8gZlvZUXCbOGNbvtO4LSsmz7LOLK4MErht8G(Wx9Q32xVxcBZfGC)REPYnbEJ5LQz3yUauWZGQju8swjMS9sZxbB(0l6IfgnUu5b9HV6vVaF9EjSnxaY9V6Lk3e4nMxYkXud1yJ)bPqMmq2kitfKvZUXCbOGNbvtO4LSsmz7LOjbqFz4dF1BtMVEVe2Mla5(x9sLBc8gZlvZUXCbOGNbvtOazQGm5GSWUfmepObIhTsjGm1GS1idYQubYCMLNqF43MMczYazRrgKjRxYkXKTxIJL5BX0lA3ee(WhEjEguF9(Qx5R3lHT5cqU)vVu5MaVX8s8meL8ocLyYwC43MMczQTdzwjMSfue560rxY7iuIjBrXOHoMpczKczX8rDKA6JDCiJuiRQfBdzVdzYbzRGSQaYcdGDikhIktVO5OfpcSnxaYHS3HmYeRwdYKfYubzufea0HDlyqfue560rxY7iuIjBTLiKjZoKTfKrkKD2W1ynSdX01ianEMlafekqgPqwyaSdXMBIhupT2wYMeb2Mla5qMkiRoiJNHGIixNo6sEhHsmzlo8BttHmvqwDqMvIjBbfrUoD0L8ocLyYwmT2bmlpHxYkXKTxIIixNo6sEhHsmz7dF1B7R3lHT5cqU)vVKvIjBVKTKnjEPYnbEJ5LcdGDikhIktVO5OfpcSnxaYHmvqMvIPgQ5ziSLSjbYudYElitfKfZh1rQ5dczYazRidYubzYbzh(TPPqMA7q2sHdzvQazLmb8CtlOe)F2AUDKVaSdfh(TPPqMmq2kYGmvqMCq2HFBAkKPgKTgKvPcKvhKzVeVjqHI1C8pf901YIft2IZAYHmvq2HohsFmxaczYczY6LkKuaOoSBbdQV6v(Wx9w(69syBUaK7F1lzLyY2lzlztIxQCtG3yEP6GSWayhIYHOY0lAoAXJaBZfGCitfKzLyQHAEgcBjBsGm1GS3gYubzX8rDKA(GqMmq2kYGmvqMCq2HFBAkKP2oKTu4qwLkqwjtap30ckX)NTMBh5la7qXHFBAkKjdKTImitfKjhKD43MMczQbzRbzvQaz1bz2lXBcuOynh)trpDTSyXKT4SMCitfKDOZH0hZfGqMSqMSEPcjfaQd7wWG6RELp8vx1(69syBUaK7F1lzLyY2lrhLNS1GXb9sLBc8gZljhKzLyQHAEgc6O8KTgmoiKPgK92qwvazHbWoeLdrLPx0C0Ihb2Mla5qwvazufea0HDlyqf0CJoEqnfrovBjczYczQGSy(OosnFqitgiBfzqMki7qNdPpMlaHmvqMCqwDq2HFBAkKPcYOkiaOd7wWGkOiY1PJUK3rOet2AlriBhYwbzvQazLmb8CtlOe)F2AUDKVaSdfh(TPPqMmqgnjaA6JDCi7DiZkXKTGOPH5cqT54aMsmzlWQkwicuhZhHmz9sfskauh2TGb1x9kF4REnF9EjSnxaY9V6LSsmz7Lk5DekXKTxQCtG3yEjQcca6WUfmOckICD6Ol5DekXKT2seYudY2cYifYoB4ASg2Hy6AeGgpZfGccfiJuilma2HyZnXdQNwBlztIaBZfGCitfKjhKD43MMczQTdzlfoKvPcKvYeWZnTGs8)zR52r(cWouC43MMczYazRidYubzh6Ci9XCbiKjlKPcYc7wWqeZh1rQ5dczYazRiZlviPaqDy3cguF1R8HV63YxVxcBZfGC)REPYnbEJ5Lo05q6J5cqVKvIjBVertdZfGAZXbmLyY2h(Wl5maaEuF9(Qx5R3lHT5cqU)vVKvIjBVertdZfGAZXbmLyY2lvUjWBmVujtap30coAXJBccXHFBAkKP2oKTu4q27q22qMkiJQGaGoSBbdQGIixNo6sEhHsmzRTeHSDiBfKrkKD2W1ynSdX01ianEMlafekqMkiRKjGNBAbL4)ZwZTJ8fGDO4WVnnfYKbY2MmVeyAux4EPvR5dF1B7R3lHT5cqU)vVu5MaVX8sk1ucdGDi4OfpUjieyBUaKdzQGmQcca6WUfmOckICD6Ol5DekXKT2seY2HSvqgPq2zdxJ1WoetxJa04zUauqOazQGm5GmEgcBjBseh(TPPqMAqgpdHTKnjcoXzXKnK9oKrMOkVgKvPcKXZquY7iuIjBXHFBAkKPgKXZquY7iuIjBbN4SyYgYEhYituLxdYQubY4ziOJYt2AW4GId)20uitniJNHGokpzRbJdk4eNft2q27qgzIQ8AqMSqMkiRKjGNBAbhT4XnbH4WVnnfYuBhYSsmzlSLSjrSu4q27qwvdzQGSsMaEUPfuI)pBn3oYxa2HId)20uitgiBBY8swjMS9sfda0wjMS1GHgEjWqdDBF0lXD1h6Ci9Xh(Q3YxVxcBZfGC)REPYnbEJ5LuQPega7qWrlECtqiW2CbihYubzufea0HDlyqfue560rxY7iuIjBTLiKTdzRGmsHSZgUgRHDiMUgbOXZCbOGqbYubzLmb8CtlOe)F2AUDKVaSdfh(TPPqMA7qgnjaA6JDCi7DiZkXKTWwYMeXsHdzKczwjMSf2s2KiwkCi7DiBlitfKjhKXZqylztI4WVnnfYudY4ziSLSjrWjolMSHS3HSvqwLkqgpdrjVJqjMSfh(TPPqMAqgpdrjVJqjMSfCIZIjBi7DiBfKvPcKXZqqhLNS1GXbfh(TPPqMAqgpdbDuEYwdghuWjolMSHS3HSvqMSEjRet2EPIbaARet2AWqdVeyOHUTp6L4U6dDoK(4dF1vTVEVe2Mla5(x9sLBc8gZlvZUXCbOGNbvtOazQGm5GSsMaEUPfuI)pBn3oYxa2HId)20uitMDiBlYGmsHSLchYQubYkzc45Mwqj()S1C7iFbyhko8BttHmzGmRet2ckX)NTMBh5la7qrjtap30qwvazBtgKjRxYkXKTxIJw84MGWh(QxZxVxcBZfGC)REPYnbEJ5LCjCCe)Sg(XoeekqMkiZLWXr0ZYt4yaG4WVnn1lzLyY2lrFmEUr7MGWh(QFlF9EjSnxaY9V6Lk3e4nMxYLWXr8ZA4h7qqOazQGS6Gm5GSWayhc6O8KTgmoOaBZfGCitfKjhKPCyn9sHlwjSLSjbYubzkhwtVu4ITf2s2KazQGmLdRPxkCXwcBjBsGmzHSkvGmLdRPxkCXkHTKnjqMSEjRet2EjBjBs8HV6QSVEVe2Mla5(x9sLBc8gZl5s44i(zn8JDiiuGmvqwDqMCqMYH10lfUyLGokpzRbJdczQGmLdRPxkCX2c6O8KTgmoiKPcYuoSMEPWfBjOJYt2AW4GqMSEjRet2Ej6O8KTgmoOp8v)2(69syBUaK7F1lvUjWBmVKlHJJ4N1Wp2HGqbYubz1bzkhwtVu4IvIsEhHsmzdzQGS6GSWayhcZLMaIa1L8ocLyYwGT5cqUxYkXKTxQK3rOet2(Wx9lWxVxcBZfGC)REPYnbEJ5Lo05q6J5cqVKvIjBVertdZfGAZXbmLyY2h(QxrMVEVe2Mla5(x9sLBc8gZl5s44iMgRnH5cqnh)dff0WkKdzYazRidYubzX8rDKA(GqMA7q2kY8swjMS9s8ZMwdgh0h(QxTYxVxcBZfGC)REPYnbEJ5LcdGDiOJYt2AW4GcSnxaYHmvqMlHJJyAS2eMla1C8puuqdRqoKjZoKTgzqwvazBtgK9oKjhKrvqaqh2TGbvqrKRthDjVJqjMS1wIqwvazNnCnwd7qmDncqJN5cqbHcKjZoKTnKjlKPcY4ziSLSjrC43MMczYazRbzVdzufea0pgnqitfKXZquY7iuIjBXHFBAkKjdKTu4qMkitoiJNHGokpzRbJdko8BttHmzGSLchYQubYQdYcdGDiOJYt2AW4GcSnxaYHmzHmvqMCqghDjCCepgrhId)20uitgiBni7DiJQGaG(XObczvQaz1bzHbWoepgrhcSnxaYHmzHmvqwj7WwMSHmzGS1GS3HmQcca6hJgOxYkXKTxIF20AW4G(Wx9QT917LW2Cbi3)QxQCtG3yEPWayhIn3epOEATTKnjcSnxaYHmvqMlHJJyAS2eMla1C8puuqdRqoKjZoKTgzqwvazBtgK9oKjhKrvqaqh2TGbvqrKRthDjVJqjMS1wIqwvazNnCnwd7qmDncqJN5cqbHcKjZoKTfKjlKvfq2Aq27qMCqgvbbaDy3cgubfrUoD0L8ocLyYwBjczvbKD2W1ynSdX01ianEMlafekq2oKTnKjlKPcY4ziSLSjrC43MMczYazRbzVdzufea0pgnqitfKXZquY7iuIjBXHFBAkKjdKTu4qMkitoiJJUeooIhJOdXHFBAkKjdKTgK9oKrvqaq)y0aHSkvGS6GSWayhIhJOdb2Mla5qMSqMkiRKDylt2qMmq2Aq27qgvbba9Jrd0lzLyY2lXpBAnyCqF4RE1w(69syBUaK7F1lvUjWBmVuyaSdH5starG6sEhHsmzlW2CbihYubzUeooIPXAtyUauZX)qrbnSc5qMm7q2AKbzvbKTnzq27qMCqgvbbaDy3cgubfrUoD0L8ocLyYwBjczvbKD2W1ynSdX01ianEMlafekqMm7qwvdzYczQGmEgcBjBseh(TPPqMmq2Aq27qgvbba9JrdeYubzYbzC0LWXr8yeDio8BttHmzGS1GS3HmQcca6hJgiKvPcKvhKfga7q8yeDiW2CbihYKfYubzLSdBzYgYKbYwdYEhYOkiaOFmAGEjRet2Ej(ztRbJd6dF1RQAF9EjSnxaY9V6Lk3e4nMxYLWXrmnwBcZfGAo(hkkOHvihYKbY2MmitfKzLyQHAEgcAsa0xgqMmqgzqwLkqMlHJJyAS2eMla1C8puuqdRqoKjdKv1K5LSsmz7L4NnTgmoOp8vVAnF9EjRet2EPhJOdVe2Mla5(x9HV6vVLVEVKvIjBVKtwiOixBVeVjqTlAFVe2Mla5(x9HV6vvzF9EjRet2EjfIBCiz6fTlWOHxcBZfGC)R(Wx9Q32xVxcBZfGC)REPYnbEJ5LQdY4zikzxWoolqU2byFu7sCT4WVnnfYubz1bzwjMSfLSlyhNfix7aSpkMw7aMLNWlzLyY2lvYUGDCwGCTdW(Op8vV6f4R3lHT5cqU)vVKvIjBVe)SP10Ka4LkKuaOoSBbdQV6vEPPd8ocLWlTYlvUjWBmVumFuhPMpiKP2oKTu4EPYJnTxALxA6aVJqj0lG01aEPv(Wx92K5R3lHT5cqU)vVKvIjBVe)SP10Ka4LkKuaOoSBbdQV6vEPPd8ocLqpoEPykKt1h(TPvBnVu5MaVX8s1SBmxak(20HnTMIqMkiRoiJJUeooc6JXZnA87Ewbfh(TPPEPYJnTxALxA6aVJqj0lG01aEPv(Wx92R817LW2Cbi3)QxYkXKTxIF20AAsa8sfskauh2TGb1x9kV00bEhHsOhhVumfYP6d)20QTMxQCtG3yEPA2nMlafFB6WMwtrVu5XM2lTYlnDG3rOe6fq6AaV0kF4RE7T917LW2Cbi3)QxYkXKTxIF20AAsa8sth4DekHxALxQ8yt7Lw5LMoW7iuc9ciDnGxALp8vV9w(69syBUaK7F1lzLyY2lrFmEUr7MGWlvUjWBmVun7gZfGIVnDytRPiKPcYQdY4OlHJJG(y8CJg)UNvqXHFBAkKPcYQdYSsmzlOpgp3ODtqiMw7aMLNWlviPaqDy3cguF1R8HV6TRAF9EjSnxaY9V6LSsmz7LOpgp3ODtq4Lk3e4nMxQMDJ5cqX3MoSP1u0lviPaqDy3cguF1R8HV6TxZxVxYkXKTxI(y8CJ2nbHxcBZfGC)R(WhEjQc2C8O(69vVYxVxcBZfGC)REPYnbEJ5LQz3yUauWZGQju8swjMS9sFdGotrFMsqCOp8vVTVEVe2Mla5(x9sLBc8gZlvZUXCbOGGIAkICVKvIjBVefrUoD0L8ocLyY2h(Wh(WhEpa]] )


end