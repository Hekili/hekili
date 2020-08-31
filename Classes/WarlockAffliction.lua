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

            impact = function ()
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


    spec:RegisterPack( "Affliction", 20200830.3, [[dC0ydcqijvEKQe6sQsKnrs(KQeKgfrLtruAvQs1RqKMfrv3IKk2fHFPKQHruCmLKLPuQNPuY0iPQUMskBtvk13iPsnovjQZrsvSosQKAEKuUNs1(quDqvPKwOQKEOQuctKKkXfjPssNuvkrwPKKzQkLOUPQee2PKulvvcQNsKPkPQRQkbrFLKkj2lv9xsnyuomLftLESetgvxgAZuXNvIrRkoTIxJOmBGBRQ2Tu)w0WjXXjPkTCvEostx46iSDjLVRumEvjW5reRxvkMVKy)G2VYxVxIBb6REBz2wgzE5TKrS9Q1upB9YEPGef0lPyfYSf0l12h9sVvhhWuIjBVKIrcinUVEVenjUc6LEIqHQUE91xM4HWvuY)605taSyYUCMtSoD(L19sUediEl1ExVe3c0x92YSTmY8YBjJy7vRPE26T9sufS4RE73EnV0ZW5y7D9sCKw8sViK9wDCatjMSHm1vSdKfYGv9Iq2teku11RV(YepeUIs(xNoFcGft2LZCI1PZVSoSQxeYQYAc7ibY2EL8q22YSTmWQGv9Iq2BXJ1livDnSQxeYuhi7TY5ihYKuqaaYElNfYeWQEritDGS3kNJCitDbRLehK9cHTmfbSQxeYuhi7fg)znKdzHDlyOhhHqaR6fHm1bYEHr1lXCiKPUK1tHmcfilBilSBbdiZjpitDbT4XnbbKjhD6cczh6Ci9bYa5YuGSHcz8XXbpSdiBCGS3c1fkKzhcz8HAUaKlRaw1lczQdK9cJkaRGqgfRHNbGSWUfmeX8rDKA(GqwXOifY2mXdKfZh1rQ5dczYHnhYshid7ss0bEYk8skx6ma0l9Iq2B1XbmLyYgYuxXoqwidw1lczVvIfcAazBjJ8q22YSTmWQGv9Iq2BXJ1livDnSQxeYuhi7TY5ihYKuqaaYElNfYeWQEritDGS3kNJCitDbRLehK9cHTmfbSQxeYuhi7fg)znKdzHDlyOhhHqaR6fHm1bYEHr1lXCiKPUK1tHmcfilBilSBbdiZjpitDbT4XnbbKjhD6cczh6Ci9bYa5YuGSHcz8XXbpSdiBCGS3c1fkKzhcz8HAUaKlRaw1lczQdK9cJkaRGqgfRHNbGSWUfmeX8rDKA(GqwXOifY2mXdKfZh1rQ5dczYHnhYshid7ss0bEYkGvbR6fHm1vFbyHiqoK5Io5Hqwj)UwazU4Y0ubK9wlfujOqwNT68y33HaazwjMSPqw2aseWQEriZkXKnvOCyj)UwS7amkzWQEriZkXKnvOCyj)Uwq6(6ozYHv9IqMvIjBQq5Ws(DTG091nILp2Hft2WQSsmztfkhwYVRfKUVoL4)ZwRGbSkRet2uHYHL87AbP7RVCZpNd1PJMALBCMck)4Shga7qSCZpNd1PJMALBCMckW2Cbihw1lczwjMSPcLdl531cs3xN2Mc9jdnnSGcRYkXKnvOCyj)Uwq6(6kzmzdRYkXKnvOCyj)Uwq6(6euupb(LVTpUBVH(yNr1ozh60rRKBWdwLvIjBQq5Ws(DTG091PiY1PJUK3rOet2Ypo7ufea0HDlyqfue560rxY7iuIjBTLi57BPQou9smkkixS6TvpBTs9HvzLyYMkuoSKFxliDF9hJOdyvwjMSPcLdl531cs3xN(y8CJ2nbH8JZEDHbWoepgrhcSnxaYvrvqaqh2TGbvqrKRthDjVJqjMS1wIQTLQ6q1lXOOGCXQ3w9S1k1hwfSQxeYux9fGfIa5qgwdpsGSy(iKfpiKzLipiBOqMvZgG5cqbSkRet20DQccaAqwidwLvIjBkP7RZXAjXP)2YuGvzLyYMs6(61SBmxakFBFCNGIAkIC5RzacCpma2HGMB0XdQPiYPcSnxaYvrvqaqh2TGbvqrKRthDjVJqjMS1wIKVVfPNnCnwd7qmDncqJN5cqbHsLkHbWoe0r5jBnyCqb2Mla5QOkiaOd7wWGkOiY1PJUK3rOet2KVVgPNnCnwd7qmDncqJN5cqbHsLkufea0HDlyqfue560rxY7iuIjBY3FzspB4ASg2Hy6AeGgpZfGccfyvwjMSPKUVEn7gZfGY32h3vmoF6f5tLDkgYxZae4UvIjBb9X45gTBccb(cWcrG6y(472BWBcuumAX4tVOlgW(tqIaBZfGCyvwjMSPKUVEn7gZfGY32h3vmoF6f5tL9dPyiFndqG7lfU8JZU9g8MaffJwm(0l6IbS)eKiW2CbixLCHbWoe8ZMwttcGaBZfG8kvuQPega7qWrlECtqiW2Cbixvjtap30coAXJBccXHFBAQA7lfUSWQSsmztjDF9A2nMlaLVTpU)TPdBAnfLVMbiWDQcca6WUfmOckICD6Ol5DekXKT2suT9vKgga7qS5M4b1tRTLSjrGT5cqoPHbWoeMlnbebQl5DekXKTaBZfG833Mu5cdGDi2Ct8G6P12s2KiW2CbixvyaSdbn3OJhutrKtfyBUaKRIQGaGoSBbdQGIixNo6sEhHsmzRTejFBzjvUWayhc6O8KTgmoOaBZfGCv1fga7quoevMErZrlEeyBUaKRQUWayhc(ztRPjbqGT5cqUSKE2W1ynSdX01ianEMlafekWQSsmztjDF9A2nMlaLVTpUZZGQjuKVMbiWD5Qlma2HGokpzRbJdkW2CbiVsfEgc6O8KTgmoOGqrwv8me2s2KiOHviJ89vYOQoEgcBjBseh6Ci9XCbOkEgIsEhHsmzliuuXZqq00WCbO2CCatjMSfekWQSsmztjDF9IbaARet2AWqd5B7J7Lmb8CttHvzLyYMs6(68ZMwttcG8th4DekHEbKUgyFL8LhB69vYxiPaqDy3cg09vYpo7X8rDKA(GQTVu4QOjbqtFSJR2AWQSsmztjDF9hJOd5hNDQcca6WUfmOckICD6Ol5DekXKT2suT9Tj9SHRXAyhIPRraA8mxakiuGvzLyYMs6(6uI)pBn3oYwa2HYpo71SBmxak4zq1ekQ4ziiAAyUauBooGPet2Id)20uYlgn0X8rvYvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20uzvjxDk1ucdGDi4OfpUjieyBUaKxPsjtap30coAXJBccXHFBAQA7lfELk1vYeWZnTGJw84MGqC43MMwPcnjaA6JD8Dzurvqaqh2TGbvqrKRthDjVJqjMS1wIKVI0ZgUgRHDiMUgbOXZCbOGqrwyvwjMSPKUVohT4XnbH8JZEjtap30ckX)NTMBhzla7qXHFBAQQA2nMlaf8mOAcfvufea0HDlyqfue560rxY7iuIjBTL4(kspB4ASg2Hy6AeGgpZfGccfvYvhsPyxqrTHozRthTcEoyjMSf)PZtvD2BWBcuWp04oeaDXaGPxeN1KvPsjtap30ckX)NTMBhzla7qXHFBAk5BjJSWQSsmztjDF94b1eTBs0CTtEfu(Xz3LWXrCyHmasPAN8kO4WVnnfwLvIjBkP7RBlztI8fskauh2TGbDFL8JZ(HFBAQA7lfoPwjMSf0hJNB0Ujie4lalebQJ5JQI5J6i18bj)LHvzLyYMs6(6F8Nhj60rdikdxZp0(u5hN9y(OABjdSQxeYQh)k5zhjqMZ8cGSiHSVrgczuIdHm7n0h7SxOuiZj7aY4js7xObK5EOrgKXTJSfGDiKrqTfuaRYkXKnL091TLSjrEW0OUW33sg5hN9y(i5BjJQsMaEUPfuI)pBn3oYwa2HId)20u12xTMku9smkkixS6TvpBTs9HvzLyYMs6(6L8ocLyYwEW0OUW33sg5hN9y(i5BjJQsMaEUPfuI)pBn3oYwa2HId)20u12xTMku9smkkixS6TvpBTs9vvxyaSdH5starG6sEhHsmzlW2CbixLCHbWoe0r5jBnyCqb2Mla5vQqvqaqh2TGbvqrKRthDjVJqjMS1wIKVsfvbbaDy3cgubfrUoD0L8ocLyYwBjQ2(wYcRYkXKnL091PJYt2AW4GYdMg1f((wYi)4ShZhjFlzuvYeWZnTGs8)zR52r2cWouC43MMQ2(Q1uHQxIrrb5IvVT6zRvQpSkRet2us3xNOPH5cqT54aMsmzl)4SBLyQHAEgcIMgMla1MJdykXK9UmvQihpdbrtdZfGAZXbmLyYwqOO6qNdPpMlaLfwLvIjBkP7RZpBAnnjaYxiPaqDy3cg09vYxSUGa94ShtHmQ(WVnTARj)4SxZUXCbO4Bth20AkQIJUeooc6JXZnA87Ewbfh(TPPQ4OlHJJG(y8CJg)UNvqXHFBAQA7lf(7BdRYkXKnL091Ppgp3ODtqiFHKca1HDlyq3xj)4SxZUXCbO4Bth20AkQIJUeooc6JXZnA87Ewbfh(TPPQ4OlHJJG(y8CJg)UNvqXHFBAQA74lalebQJ5JVVnPXz1qGoMpQQoRet2c6JXZnA3eeIP1oGz5jGvzLyYMs6(6kpwh5xtNEHay3eKiFHKca1HDlyq3xj)4ShZhjFR1uf2TGHiMpQJuZhK8vV97ufea0pgnqvYvhsPyxqrTHozRthTcEoyjMSf)PZtvD2BWBcuWp04oeaDXaGPxeN1KvPsjtap30ckX)NTMBhzla7qXHFBAk5Q)AKstcGM(yh)D7n4nbk4hAChcGUyaW0lIZAYQuPKjGNBAbL4)ZwZTJSfGDO4WVnnvTvR9ovbba9JrdKuAsa00h74VBVbVjqb)qJ7qa0fdaMErCwtMSWQSsmztjDFDkICD6Ol5DekXKT8JZEn7gZfGcckQPiYvrtcGM(yhFFnyvwjMSPKUVEXaaTvIjBnyOH8T9XDEguyvwjMSPKUVETbG6WMoKVqsbG6WUfmO7RKFC2J5JKVAnvX8rDKA(GKVVsgvYvYeWZnTGs8)zR52r2cWouC43MMs(wYuPsjtap30ckX)NTMBhzla7qXHFBAQARKrfpdHTKnjId)20uY3xjJkEgIsEhHsmzlo8BttjFFLmQKJNHGokpzRbJdko8BttjFFLmvQuxyaSdbDuEYwdghuGT5cqUSYcRYkXKnL091jOOEc8lFBFC3Ed9XoJQDYo0PJwj3GN8JZEmFuT9TGvzLyYMs6(6kpwh5xtNEHay3eKi)4ShZhvBFR1GvzLyYMs6(61gaQdB6q(XzpMpQ2Q1GvzLyYMs6(6le2XhR1PJ2EdEz8i)4Slxjtap30ckX)NTMBhzla7qXHFBAQARwJuAsa00h74VBVbVjqb)qJ7qa0fdaMErGT5cqELkYzVbVjqb)qJ7qa0fdaMErCwtwLkiLIDbf1g6KToD0k45GLyYwCwtMSQI5JKVLmQI5J6i18bjFF7vYiRk54ziuESoYVMo9cbWUjirC43MMwPcpdrTbG6WMoeh(TPPvQuxyaSdHYJ1r(10Pxia2nbjcSnxaYvvxyaSdrTbG6WMoeyBUaKlBLkX8rDKA(GQTLmKUu4WQSsmztjDFDUDKPPjbq(XzVKjGNBAbL4)ZwZTJSfGDO4WVnnvTvRrknjaA6JD83T3G3eOGFOXDia6IbatViW2CbixLC8mekpwh5xtNEHay3eKio8BttRuHNHO2aqDythId)20uzHvzLyYMs6(6U4rXJSPxGvzLyYMs6(6fda0wjMS1GHgY32h3PkyZXJcRYkXKnL091lgaOTsmzRbdnKVTpU7maaEuyvWQSsmztfLmb8Ctt33KhGxdNwFinBRliSkRet2urjtap30us3xNGI6jWV8T9XD7n0h7mQ2j7qNoALCdEYpo7YvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20u1u)3PkiaOFmAGvQuxjtap30cLhRJ8RPtVqaSBcseh(TPPYQQKjGNBAbL4)ZwZTJSfGDO4WVnnvTvQN3PkiaOFmAGKstcGM(yh)D7n4nbk4hAChcGUyaW0lIZAYuXZqylztI4WVnnvfpdrjVJqjMSfh(TPPQKJNHGokpzRbJdko8BttRuPUWayhc6O8KTgmoOaBZfGCzHvzLyYMkkzc45MMs6(6kzmzl)4SlxyaSdb3oY00KaO)dfpseyBUaKRQKjGNBAbL4)ZwZTJSfGDOGqrvjtap30cUDKPPjbqqOiBLkLmb8CtlOe)F2AUDKTaSdfekvQeZh1rQ5dQ2wYaRYkXKnvuYeWZnnL091jOOEc8tLFC2lzc45Mwqj()S1C7iBbyhko8BttjxDltLkX8rDKA(GQTTmvQihpdbrtdZfGAZXbmLyYwetHSPxurtcGM(yhFxgvYvxyaSdHYJ1r(10Pxia2nbjcSnxaYRuPKjGNBAHYJ1r(10Pxia2nbjId)20uzvjxDk1ucdGDi4OfpUjieyBUaKxPsjtap30coAXJBccXHFBAQA7lfELk1vYeWZnTGJw84MGqC43MMkRQ6kzc45Mwqj()S1C7iBbyhko8BttLfwLvIjBQOKjGNBAkP7R7mh6cYKl)4Sxxjtap30ckX)NTMBhzla7qbHcSkRet2urjtap30us3x3fKjx7qCKi)4Sxxjtap30ckX)NTMBhzla7qbHcSkRet2urjtap30us3x)J)8irNoAarz4A(H2Nk)4ShZhjFlzGvzLyYMkkzc45MMs6(6C7itttcG8JZEmFuhPMpOABldPlfELkHbWoe0CJoEqnfrovGT5cqUQsMaEUPfuI)pBn3oYwa2HId)20uY3lzc45Mwqj()S1C7iBbyhk4eNft2QZkzGvzLyYMkkzc45MMs6(6UGm560rhpOgB8tI8JZUcgcUDKTaSdfh(TPPvQixDLmb8Ctl4OfpUjieh(TPPvQuNsnLWayhcoAXJBccb2Mla5YQQKjGNBAbL4)ZwZTJSfGDO4WVnnL89xwgviLIDbfUGm560rhpOgB8tI4SMmYxbR6fHSxiPiKXTVTm9cKLT6qqrilUPjddkK9ZdHS8GmasPqw2qwjtap30Ydz0eYazVazgfYIheYEl9wOUazXdscKnDH4GSnz)cnGm0XblbKznjqwgp4bzXnnzyqHmcQTGqgN4MEbYkzc45MMkGvzLyYMkkzc45MMs6(6euupb(LVTpURKfYWGoVb56s(viclMS1CS2uq5hND5kzc45Mwqj()S1C7iBbyhko8BttjFF71QujMpQJuZhuT9TKrwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKllSkRet2urjtap30us3xNGI6jWV8T9X9lJYrqdKRRLjptnpba5hND5kzc45Mwqj()S1C7iBbyhko8BttjFF71QujMpQJuZhuT9TKrwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKllSkRet2urjtap30us3xNGI6jWV8T9XD6ZudpDnSZV(qWuKFC2LRKjGNBAbL4)ZwZTJSfGDO4WVnnL89TxRsLy(OosnFq123sgzvjxjtap30coAXJBccXHFBAALk1Putjma2HGJw84MGqGT5cqUSWQSsmztfLmb8CttjDFDckQNa)Y32h3n1lXOKb2HUnIyaeu5hND5kzc45Mwqj()S1C7iBbyhko8BttjFF71QujMpQJuZhuT9TKrwvYvYeWZnTGJw84MGqC43MMwPsDk1ucdGDi4OfpUjieyBUaKllSkRet2urjtap30us3xNGI6jWV8T9X9y4inY7RljhFbYpo7YvYeWZnTGs8)zR52r2cWouC43MMs((2RvPsmFuhPMpOA7BjJSQKRKjGNBAbhT4XnbH4WVnnTsL6uQPega7qWrlECtqiW2CbixwyvwjMSPIsMaEUPPKUVobf1tGF5B7J71gdOthnnY7tLFC2LRKjGNBAbL4)ZwZTJSfGDO4WVnnL89TxRsLy(OosnFq123sgzvjxjtap30coAXJBccXHFBAALk1Putjma2HGJw84MGqGT5cqUSWQSsmztfLmb8CttjDF9BuuaOEAnvXkiSkRet2urjtap30us3xNwsIB6fDmXdk)4SxZUXCbOGNbvtOaRYkXKnvuYeWZnnL091NVc28Px0flmACPYdk)4SxZUXCbOGNbvtOaRYkXKnvuYeWZnnL091PjbqFzi)4SlNlHJJyAS2eMla1C8puuqdRqg5B9YvQyLyQHASX)GuYxjRQA2nMlaf8mOAcfyvwjMSPIsMaEUPPKUVohlZ3IPx0UjiKFC2Rz3yUauWZGQjuujxy3cgIh0aXJwPeQTMmvQ4mlpH(WVnnL81KrwyvWQSsmztfCx9HohsF2PJYt2AW4GYdMg1f((Q1KFC2LJNHGokpzRbJdko8BttFjEgc6O8KTgmoOGtCwmzlRA7YXZqylztI4WVnn9L4ziSLSjrWjolMSLvLC8me0r5jBnyCqXHFBA6lXZqqhLNS1GXbfCIZIjBzvBxoEgIsEhHsmzlo8BttFjEgIsEhHsmzl4eNft2YQINHGokpzRbJdko8BttvJNHGokpzRbJdk4eNft2VVsSfSkRet2ub3vFOZH0hs3x3wYMe5btJ6cFF1AYpo7YXZqylztI4WVnn9L4ziSLSjrWjolMSLvTD54zik5DekXKT4WVnn9L4zik5DekXKTGtCwmzlRk54ziSLSjrC43MM(s8me2s2Ki4eNft2YQ2UC8me0r5jBnyCqXHFBA6lXZqqhLNS1GXbfCIZIjBzvXZqylztI4WVnnvnEgcBjBseCIZIj73xj2cwLvIjBQG7Qp05q6dP7RxY7iuIjB5btJ6cFF1AYpo7YXZquY7iuIjBXHFBA6lXZquY7iuIjBbN4SyYww12LJNHWwYMeXHFBA6lXZqylztIGtCwmzlRk54zik5DekXKT4WVnn9L4zik5DekXKTGtCwmzlRA7YXZqqhLNS1GXbfh(TPPVepdbDuEYwdghuWjolMSLvfpdrjVJqjMSfh(TPPQXZquY7iuIjBbN4SyY(9vITGvbRYkXKnvWZGUtrKRthDjVJqjMSLFC25zik5DekXKT4WVnnvTDRet2ckICD6Ol5DekXKTOy0qhZhjnMpQJutFSJtQ6l2(D5wPoHbWoeLdrLPx0C0Ihb2Mla5VlJy1AYQIQGaGoSBbdQGIixNo6sEhHsmzRTejFFlspB4ASg2Hy6AeGgpZfGccfsddGDi2Ct8G6P12s2KiW2CbixvD8meue560rxY7iuIjBXHFBAQQ6SsmzlOiY1PJUK3rOet2IP1oGz5jGvzLyYMk4zqjDFDBjBsKVqsbG6WUfmO7RKFC2ddGDikhIktVO5OfpcSnxaYvzLyQHAEgcBjBsu7TvfZh1rQ5ds(kzuj3HFBAQA7lfELkLmb8CtlOe)F2AUDKTaSdfh(TPPKVsgvYD43MMQ2AvQuN9g8MafkwZX)u0txllwmzloRjt1HohsFmxakRSWQSsmztf8mOKUVUTKnjYxiPaqDy3cg09vYpo71fga7quoevMErZrlEeyBUaKRYkXud18me2s2KO2lRkMpQJuZhK8vYOsUd)20u12xk8kvkzc45Mwqj()S1C7iBbyhko8BttjFLmQK7WVnnvT1QuPo7n4nbkuSMJ)PONUwwSyYwCwtMQdDoK(yUauwzHvzLyYMk4zqjDFD6O8KTgmoO8fskauh2TGbDFL8JZUCwjMAOMNHGokpzRbJdQ2lRoHbWoeLdrLPx0C0Ihb2Mla5QdvbbaDy3cgubn3OJhutrKt1wIYQkMpQJuZhK8vYO6qNdPpMlavjxDh(TPPQOkiaOd7wWGkOiY1PJUK3rOet2AlX9vvQuYeWZnTGs8)zR52r2cWouC43MMsonjaA6JD83TsmzliAAyUauBooGPet2c8fGfIa1X8rzHvzLyYMk4zqjDF9sEhHsmzlFHKca1HDlyq3xj)4Stvqaqh2TGbvqrKRthDjVJqjMS1wIQTfPNnCnwd7qmDncqJN5cqbHcPHbWoeBUjEq90ABjBseyBUaKRsUd)20u12xk8kvkzc45Mwqj()S1C7iBbyhko8BttjFLmQo05q6J5cqzvf2TGHiMpQJuZhK8vYaRYkXKnvWZGs6(6ennmxaQnhhWuIjB5hN9dDoK(yUaewfSkRet2uHZaa4r3jAAyUauBooGPet2YdMg1f((Q1KFC2lzc45MwWrlECtqio8BttvBFPWFFBvufea0HDlyqfue560rxY7iuIjBTL4(kspB4ASg2Hy6AeGgpZfGccfvLmb8CtlOe)F2AUDKTaSdfh(TPPKVTmWQSsmztfodaGhL091lgaOTsmzRbdnKVTpUZD1h6Ci9r(XzxPMsyaSdbhT4XnbHaBZfGCvufea0HDlyqfue560rxY7iuIjBTL4(kspB4ASg2Hy6AeGgpZfGccfvYXZqylztI4WVnnvnEgcBjBseCIZIj73LrOUxRsfEgIsEhHsmzlo8BttvJNHOK3rOet2coXzXK97Yiu3RvPcpdbDuEYwdghuC43MMQgpdbDuEYwdghuWjolMSFxgH6EnzvvYeWZnTGJw84MGqC43MMQ2UvIjBHTKnjILc)D1xvjtap30ckX)NTMBhzla7qXHFBAk5BldSkRet2uHZaa4rjDF9IbaARet2AWqd5B7J7Cx9HohsFKFC2vQPega7qWrlECtqiW2CbixfvbbaDy3cgubfrUoD0L8ocLyYwBjUVI0ZgUgRHDiMUgbOXZCbOGqrvjtap30ckX)NTMBhzla7qXHFBAQA70KaOPp2XF3kXKTWwYMeXsHtQvIjBHTKnjILc)9TujhpdHTKnjId)20u14ziSLSjrWjolMSFFvLk8meL8ocLyYwC43MMQgpdrjVJqjMSfCIZIj73xvPcpdbDuEYwdghuC43MMQgpdbDuEYwdghuWjolMSFFLSWQSsmztfodaGhL0915OfpUjiKFC2Rz3yUauWZGQjuujxjtap30ckX)NTMBhzla7qXHFBAk57BjdPlfELkLmb8CtlOe)F2AUDKTaSdfh(TPPKBLyYwqj()S1C7iBbyhkkzc45MwD2wgzHvzLyYMkCgaapkP7RtFmEUr7MGq(Xz3LWXr8ZA4h7qqOOYLWXr0ZYt4yaG4WVnnfwLvIjBQWzaa8OKUVUTKnjYpo7UeooIFwd)yhccfv1jxyaSdbDuEYwdghuGT5cqUk5uoSMEPWfRe2s2KOs5WA6LcxSTWwYMevkhwtVu4ITe2s2KiBLkkhwtVu4IvcBjBsKfwLvIjBQWzaa8OKUVoDuEYwdghu(Xz3LWXr8ZA4h7qqOOQo5uoSMEPWfRe0r5jBnyCqvkhwtVu4ITf0r5jBnyCqvkhwtVu4ITe0r5jBnyCqzHvzLyYMkCgaapkP7RxY7iuIjB5hNDxchhXpRHFSdbHIQ6uoSMEPWfReL8ocLyYwvDHbWoeMlnbebQl5DekXKTaBZfGCyvwjMSPcNbaWJs6(6ennmxaQnhhWuIjB5hN9dDoK(yUaewLvIjBQWzaa8OKUVo)SP1GXbLFC2DjCCetJ1MWCbOMJ)HIcAyfYiFLmQI5J6i18bvBFLmWQSsmztfodaGhL0915NnTgmoO8JZEyaSdbDuEYwdghuGT5cqUkxchhX0yTjmxaQ54FOOGgwHmY3xtg1zBzExoQcca6WUfmOckICD6Ol5DekXKT2suDoB4ASg2Hy6AeGgpZfGccfY33wwv8me2s2Kio8BttjFT3PkiaOFmAGQ4zik5DekXKT4WVnnL8LcxLC8me0r5jBnyCqXHFBAk5lfELk1fga7qqhLNS1GXbfyBUaKlRk54OlHJJ4Xi6qC43MMs(AVtvqaq)y0aRuPUWayhIhJOdb2Mla5YQQKDylt2KV27ufea0pgnqyvwjMSPcNbaWJs6(68ZMwdghu(Xzpma2HyZnXdQNwBlztIaBZfGCvUeooIPXAtyUauZX)qrbnSczKVVMmQZ2Y8UCufea0HDlyqfue560rxY7iuIjBTLO6C2W1ynSdX01ianEMlafekKVVLSQZAVlhvbbaDy3cgubfrUoD0L8ocLyYwBjQoNnCnwd7qmDncqJN5cqbHY(2YQINHWwYMeXHFBAk5R9ovbba9JrdufpdrjVJqjMSfh(TPPKVu4QKJJUeooIhJOdXHFBAk5R9ovbba9JrdSsL6cdGDiEmIoeyBUaKlRQs2HTmzt(AVtvqaq)y0aHvzLyYMkCgaapkP7RZpBAnyCq5hN9WayhcZLMaIa1L8ocLyYwGT5cqUkxchhX0yTjmxaQ54FOOGgwHmY3xtg1zBzExoQcca6WUfmOckICD6Ol5DekXKT2suDoB4ASg2Hy6AeGgpZfGccfY3vFzvXZqylztI4WVnnL81ENQGaG(XObQsoo6s44iEmIoeh(TPPKV27ufea0pgnWkvQlma2H4Xi6qGT5cqUSQkzh2YKn5R9ovbba9JrdewLvIjBQWzaa8OKUVo)SP1GXbLFC2DjCCetJ1MWCbOMJ)HIcAyfYiFBzuzLyQHAEgcAsa0xgKltLkUeooIPXAtyUauZX)qrbnSczKR(YaRYkXKnv4maaEus3x)Xi6awLvIjBQWzaa8OKUVUtwiOixBVbVjqTlAFyvwjMSPcNbaWJs6(6ke34qY0lAxGrdyvwjMSPcNbaWJs6(6LSlyhNfix7aSpk)4Sxhpdrj7c2XzbY1oa7JAxIRfh(TPPQQZkXKTOKDb74Sa5AhG9rX0AhWS8eWQSsmztfodaGhL0915NnTMMea5NoW7iuc9ciDnW(k5lp207RKF6aVJqj2xjFHKca1HDlyq3xj)4ShZh1rQ5dQ2(sHdRYkXKnv4maaEus3xNF20AAsaKVqsbG6WUfmO7RKV8ytVVs(Pd8ocLqpo7XuiJQp8BtR2AYpDG3rOe6fq6AG9vYpo71SBmxak(20HnTMIQQJJUeooc6JXZnA87Ewbfh(TPPWQSsmztfodaGhL0915NnTMMea5lKuaOoSBbd6(k5lp207RKF6aVJqj0JZEmfYO6d)20QTM8th4DekHEbKUgyFL8JZEn7gZfGIVnDytRPiSkRet2uHZaa4rjDFD(ztRPjbq(Pd8ocLqVasxdSVs(YJn9(k5NoW7iuI9vWQSsmztfodaGhL091Ppgp3ODtqiFHKca1HDlyq3xj)4SxZUXCbO4Bth20AkQQoo6s44iOpgp3OXV7zfuC43MMQQoRet2c6JXZnA3eeIP1oGz5jGvzLyYMkCgaapkP7RtFmEUr7MGq(cjfaQd7wWGUVs(XzVMDJ5cqX3MoSP1uewLvIjBQWzaa8OKUVo9X45gTBccyvWQSsmztfufS54r3)gaDMI(mLG4q5hN9A2nMlaf8mOAcfyvwjMSPcQc2C8OKUVofrUoD0L8ocLyYw(XzVMDJ5cqbbf1ue5EPA4rNS9vVTmBlJmV8wYi22lTXUE6fQx6T0xjVa5qM6gYSsmzdzGHgubSkVKrep55LKM)BHxcm0G6R3lXD1h6Ci9XxVV6v(69syBUaK7F1lzLyY2lrhLNS1GXb9sLBc8gZljhKXZqqhLNS1GXbfh(TPPq2lbz8me0r5jBnyCqbN4SyYgYKfYuBhYKdY4ziSLSjrC43MMczVeKXZqylztIGtCwmzdzYczQGm5GmEgc6O8KTgmoO4WVnnfYEjiJNHGokpzRbJdk4eNft2qMSqMA7qMCqgpdrjVJqjMSfh(TPPq2lbz8meL8ocLyYwWjolMSHmzHmvqgpdbDuEYwdghuC43MMczQbz8me0r5jBnyCqbN4SyYgYEhYwj2YlbMg1fUxA1A(Wx92(69syBUaK7F1lzLyY2lzlztIxQCtG3yEj5GmEgcBjBseh(TPPq2lbz8me2s2Ki4eNft2qMSqMA7qMCqgpdrjVJqjMSfh(TPPq2lbz8meL8ocLyYwWjolMSHmzHmvqMCqgpdHTKnjId)20ui7LGmEgcBjBseCIZIjBitwitTDitoiJNHGokpzRbJdko8BttHSxcY4ziOJYt2AW4GcoXzXKnKjlKPcY4ziSLSjrC43MMczQbz8me2s2Ki4eNft2q27q2kXwEjW0OUW9sRwZh(Q3YxVxcBZfGC)REjRet2EPsEhHsmz7Lk3e4nMxsoiJNHOK3rOet2Id)20ui7LGmEgIsEhHsmzl4eNft2qMSqMA7qMCqgpdHTKnjId)20ui7LGmEgcBjBseCIZIjBitwitfKjhKXZquY7iuIjBXHFBAkK9sqgpdrjVJqjMSfCIZIjBitwitTDitoiJNHGokpzRbJdko8BttHSxcY4ziOJYt2AW4GcoXzXKnKjlKPcY4zik5DekXKT4WVnnfYudY4zik5DekXKTGtCwmzdzVdzReB5LatJ6c3lTAnF4dVehDmcq4R3x9kF9EjRet2EjQccaAqwiZlHT5cqU)vF4REBF9EjRet2Ejowljo93wMIxcBZfGC)R(Wx9w(69syBUaK7F1lLkEjkgEjRet2EPA2nMla9s1mab6LcdGDiO5gD8GAkICQaBZfGCitfKrvqaqh2TGbvqrKRthDjVJqjMS1wIqg57q2wqgPq2zdxJ1WoetxJa04zUauqOazvQazHbWoe0r5jBnyCqb2Mla5qMkiJQGaGoSBbdQGIixNo6sEhHsmzdzKVdzRbzKczNnCnwd7qmDncqJN5cqbHcKvPcKrvqaqh2TGbvqrKRthDjVJqjMSHmY3HSxgYifYoB4ASg2Hy6AeGgpZfGccfVun70T9rVebf1ue5(WxT67R3lHT5cqU)vVuQ4LOy4LSsmz7LQz3yUa0lvZaeOxYkXKTG(y8CJ2nbHaFbyHiqDmFeYEhYS3G3eOOy0IXNErxmG9NGeb2Mla5EPA2PB7JEjfJZNEXh(QxZxVxcBZfGC)REPuXlDifdVKvIjBVun7gZfGEPAgGa9slfUxQCtG3yEj7n4nbkkgTy8Px0fdy)jirGT5cqoKPcYKdYcdGDi4NnTMMeab2Mla5qwLkqMsnLWayhcoAXJBccb2Mla5qMkiRKjGNBAbhT4XnbH4WVnnfYuBhYwkCitwVun70T9rVKIX5tV4dF1VTVEVe2Mla5(x9sPIxIIHxYkXKTxQMDJ5cqVundqGEjQcca6WUfmOckICD6Ol5DekXKT2seYuBhYwbzKczHbWoeBUjEq90ABjBseyBUaKdzKczHbWoeMlnbebQl5DekXKTaBZfGCi7DiBBiJuitoilma2HyZnXdQNwBlztIaBZfGCitfKfga7qqZn64b1ue5ub2Mla5qMkiJQGaGoSBbdQGIixNo6sEhHsmzRTeHmYHSTHmzHmsHm5GSWayhc6O8KTgmoOaBZfGCitfKvhKfga7quoevMErZrlEeyBUaKdzQGS6GSWayhc(ztRPjbqGT5cqoKjlKrkKD2W1ynSdX01ianEMlafekEPA2PB7JEPVnDytRPOp8vRU917LW2Cbi3)Qxkv8sum8swjMS9s1SBmxa6LQzac0ljhKvhKfga7qqhLNS1GXbfyBUaKdzvQaz8me0r5jBnyCqbHcKjlKPcY4ziSLSjrqdRqgKr(oKTsgitfKvhKXZqylztI4qNdPpMlaHmvqgpdrjVJqjMSfekqMkiJNHGOPH5cqT54aMsmzliu8s1St32h9s8mOAcfF4R(L917LW2Cbi3)QxYkXKTxQyaG2kXKTgm0WlbgAOB7JEPsMaEUPP(WxT6XxVxcBZfGC)REjRet2Ej(ztRPjbWlviPaqDy3cguF1R8sLBc8gZlfZh1rQ5dczQTdzlfoKPcYOjbqtFSJdzQbzR5Lkp20EPvEPPd8ocLqVasxd4Lw5dF1RKXxVxcBZfGC)REPYnbEJ5LOkiaOd7wWGkOiY1PJUK3rOet2AlritTDiBBiJui7SHRXAyhIPRraA8mxakiu8swjMS9spgrh(Wx9Qv(69syBUaK7F1lvUjWBmVun7gZfGcEgunHcKPcY4ziiAAyUauBooGPet2Id)20uiJCiRy0qhZhHmvqMCqwDqwyaSdHYJ1r(10Pxia2nbjcSnxaYHSkvGSsMaEUPfkpwh5xtNEHay3eKio8BttHmzHmvqMCqwDqMsnLWayhcoAXJBccb2Mla5qwLkqwjtap30coAXJBccXHFBAkKP2oKTu4qwLkqwDqwjtap30coAXJBccXHFBAkKvPcKrtcGM(yhhY2HmzGmvqgvbbaDy3cgubfrUoD0L8ocLyYwBjczKdzRGmsHSZgUgRHDiMUgbOXZCbOGqbYK1lzLyY2lrj()S1C7iBbyh6dF1R22xVxcBZfGC)REPYnbEJ5Lkzc45Mwqj()S1C7iBbyhko8BttHmvqwn7gZfGcEgunHcKPcYOkiaOd7wWGkOiY1PJUK3rOet2AlriBhYwbzKczNnCnwd7qmDncqJN5cqbHcKPcYKdYQdYqkf7ckQn0jBD6OvWZblXKT4pDEqMkiRoiZEdEtGc(Hg3HaOlgam9I4SMmiRsfiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYihY2sgitwVKvIjBVehT4XnbHp8vVAlF9EjSnxaY9V6Lk3e4nMxYLWXrCyHmasPAN8kO4WVnn1lzLyY2lfpOMODtIMRDYRG(Wx9k13xVxcBZfGC)REjRet2EjBjBs8sLBc8gZlD43MMczQTdzlfoKrkKzLyYwqFmEUr7MGqGVaSqeOoMpczQGSy(OosnFqiJCi7L9sfskauh2TGb1x9kF4RE1A(69syBUaK7F1lvUjWBmVumFeYudY2sgVKvIjBV0h)5rIoD0aIYW18dTp1h(Qx92(69syBUaK7F1lzLyY2lzlztIxQCtG3yEPy(iKroKTLmqMkiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYuBhYwTgKPcYq1lXOOGCH9g6JDgv7KDOthTsUbpVeyAux4EPTKXh(QxPU917LW2Cbi3)QxYkXKTxQK3rOet2EPYnbEJ5LI5Jqg5q2wYazQGSsMaEUPfuI)pBn3oYwa2HId)20uitTDiB1AqMkidvVeJIcYf2BOp2zuTt2HoD0k5g8GmvqwDqwyaSdH5starG6sEhHsmzlW2CbihYubzYbzHbWoe0r5jBnyCqb2Mla5qwLkqgvbbaDy3cgubfrUoD0L8ocLyYwBjczKdzRGmvqgvbbaDy3cgubfrUoD0L8ocLyYwBjczQTdzBbzY6LatJ6c3lTLm(Wx9Qx2xVxcBZfGC)REjRet2Ej6O8KTgmoOxQCtG3yEPy(iKroKTLmqMkiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYuBhYwTgKPcYq1lXOOGCH9g6JDgv7KDOthTsUbpVeyAux4EPTKXh(QxPE817LW2Cbi3)QxQCtG3yEjRetnuZZqq00WCbO2CCatjMSHSDitgiRsfitoiJNHGOPH5cqT54aMsmzliuGmvq2HohsFmxaczY6LSsmz7LiAAyUauBooGPet2(Wx92Y4R3lHT5cqU)vVKvIjBVe)SP10Ka4LkKuaOoSBbdQV6vEPI1feOhhVumfYO6d)20QTMxQCtG3yEPA2nMlafFB6WMwtritfKXrxchhb9X45gn(DpRGId)20uitfKXrxchhb9X45gn(DpRGId)20uitTDiBPWHS3HST9HV6Tx5R3lHT5cqU)vVKvIjBVe9X45gTBccVu5MaVX8s1SBmxak(20HnTMIqMkiJJUeooc6JXZnA87Ewbfh(TPPqMkiJJUeooc6JXZnA87Ewbfh(TPPqMA7qg(cWcrG6y(iK9oKTnKrkKfNvdb6y(iKPcYQdYSsmzlOpgp3ODtqiMw7aMLNWlviPaqDy3cguF1R8HV6T32xVxcBZfGC)REjRet2EjLhRJ8RPtVqaSBcs8sLBc8gZlfZhHmYHSTwdYubzHDlyiI5J6i18bHmYHSvVnK9oKrvqaq)y0aHmvqMCqwDqgsPyxqrTHozRthTcEoyjMSf)PZdYubz1bz2BWBcuWp04oeaDXaGPxeN1KbzvQazLmb8CtlOe)F2AUDKTaSdfh(TPPqg5qM6VgKrkKrtcGM(yhhYEhYS3G3eOGFOXDia6IbatVioRjdYQubYkzc45Mwqj()S1C7iBbyhko8BttHm1GSvRbzVdzufea0pgnqiJuiJMean9XooK9oKzVbVjqb)qJ7qa0fdaMErCwtgKjRxQqsbG6WUfmO(Qx5dF1BVLVEVe2Mla5(x9sLBc8gZlvZUXCbOGGIAkICitfKrtcGM(yhhY2HS18swjMS9sue560rxY7iuIjBF4REB13xVxcBZfGC)REjRet2EPIbaARet2AWqdVeyOHUTp6L4zq9HV6TxZxVxcBZfGC)REjRet2EPAda1HnD4Lk3e4nMxkMpczKdzRwdYubzX8rDKA(Gqg57q2kzGmvqMCqwjtap30ckX)NTMBhzla7qXHFBAkKroKTLmqwLkqwjtap30ckX)NTMBhzla7qXHFBAkKPgKTsgitfKXZqylztI4WVnnfYiFhYwjdKPcY4zik5DekXKT4WVnnfYiFhYwjdKPcYKdY4ziOJYt2AW4GId)20uiJ8DiBLmqwLkqwDqwyaSdbDuEYwdghuGT5cqoKjlKjRxQqsbG6WUfmO(Qx5dF1B)2(69syBUaK7F1lzLyY2lzVH(yNr1ozh60rRKBWZlvUjWBmVumFeYuBhY2Yl12h9s2BOp2zuTt2HoD0k5g88HV6Tv3(69syBUaK7F1lvUjWBmVumFeYuBhY2AnVKvIjBVKYJ1r(10Pxia2nbj(Wx92VSVEVe2Mla5(x9sLBc8gZlfZhHm1GSvR5LSsmz7LQnauh20Hp8vVT6XxVxcBZfGC)REPYnbEJ5LKdYkzc45Mwqj()S1C7iBbyhko8BttHm1GSvRbzKcz0KaOPp2XHS3Hm7n4nbk4hAChcGUyaW0lcSnxaYHSkvGm5Gm7n4nbk4hAChcGUyaW0lIZAYGSkvGmKsXUGIAdDYwNoAf8CWsmzloRjdYKfYubzX8riJCiBlzGmvqwmFuhPMpiKr(oKT9kzGmzHmvqMCqgpdHYJ1r(10Pxia2nbjId)20uiRsfiJNHO2aqDythId)20uiRsfiRoilma2Hq5X6i)A60lea7MGeb2Mla5qMkiRoilma2HO2aqDythcSnxaYHmzHSkvGSy(OosnFqitniBlzGmsHSLc3lzLyY2lTqyhFSwNoA7n4LXJp8vVLm(69syBUaK7F1lvUjWBmVujtap30ckX)NTMBhzla7qXHFBAkKPgKTAniJuiJMean9XooK9oKzVbVjqb)qJ7qa0fdaMErGT5cqoKPcYKdY4ziuESoYVMo9cbWUjirC43MMczvQaz8me1gaQdB6qC43MMczY6LSsmz7L42rMMMeaF4RERv(69swjMS9sU4rXJSPx8syBUaK7F1h(Q3ABF9EjSnxaY9V6LSsmz7LkgaOTsmzRbdn8sGHg62(OxIQGnhpQp8vV1w(69syBUaK7F1lzLyY2lvmaqBLyYwdgA4Ladn0T9rVKZaa4r9Hp8skhwYVRf(69vVYxVxYkXKTxIs8)zRDqWdrh45LW2Cbi3)Qp8vVTVEVe2Mla5(x9sLBc8gZlfga7qSCZpNd1PJMALBCMckW2Cbi3lzLyY2lTCZpNd1PJMALBCMc6dF1B5R3lzLyY2lPKXKTxcBZfGC)R(WxT67R3lHT5cqU)vVuBF0lzVH(yNr1ozh60rRKBWZlzLyY2lzVH(yNr1ozh60rRKBWZh(QxZxVxcBZfGC)REPYnbEJ5LOkiaOd7wWGkOiY1PJUK3rOet2AlriJ8DiBlitfKvhKHQxIrrb5c7n0h7mQ2j7qNoALCdEEjRet2EjkICD6Ol5DekXKTp8v)2(69swjMS9spgrhEjSnxaY9V6dF1QBF9EjSnxaY9V6Lk3e4nMxQoilma2H4Xi6qGT5cqoKPcYOkiaOd7wWGkOiY1PJUK3rOet2AlritniBlitfKvhKHQxIrrb5c7n0h7mQ2j7qNoALCdEEjRet2Ej6JXZnA3ee(WhEPsMaEUPP(69vVYxVxYkXKTxAtEaEnCA9H0STUGEjSnxaY9V6dF1B7R3lHT5cqU)vVKvIjBVK9g6JDgv7KDOthTsUbpVu5MaVX8sYbz1bzHbWoekpwh5xtNEHay3eKiW2CbihYQubYkzc45MwO8yDKFnD6fcGDtqI4WVnnfYudYuFi7DiJQGaG(XObczvQaz1bzLmb8CtluESoYVMo9cbWUjirC43MMczYczQGSsMaEUPfuI)pBn3oYwa2HId)20uitniBL6bYEhYOkiaOFmAGqgPqgnjaA6JDCi7DiZEdEtGc(Hg3HaOlgam9I4SMmitfKXZqylztI4WVnnfYubz8meL8ocLyYwC43MMczQGm5GmEgc6O8KTgmoO4WVnnfYQubYQdYcdGDiOJYt2AW4GcSnxaYHmz9sT9rVK9g6JDgv7KDOthTsUbpF4RElF9EjSnxaY9V6Lk3e4nMxsoilma2HGBhzAAsa0)HIhjcSnxaYHmvqwjtap30ckX)NTMBhzla7qbHcKPcYkzc45MwWTJmnnjaccfitwiRsfiRKjGNBAbL4)ZwZTJSfGDOGqbYQubYI5J6i18bHm1GSTKXlzLyY2lPKXKTp8vR((69syBUaK7F1lvUjWBmVujtap30ckX)NTMBhzla7qXHFBAkKroKPULbYQubYI5J6i18bHm1GSTLbYQubYKdY4ziiAAyUauBooGPet2IykKn9cKPcYOjbqtFSJdz7qMmqMkitoiRoilma2Hq5X6i)A60lea7MGeb2Mla5qwLkqwjtap30cLhRJ8RPtVqaSBcseh(TPPqMSqMkitoiRoitPMsyaSdbhT4XnbHaBZfGCiRsfiRKjGNBAbhT4XnbH4WVnnfYuBhYwkCiRsfiRoiRKjGNBAbhT4XnbH4WVnnfYKfYubz1bzLmb8CtlOe)F2AUDKTaSdfh(TPPqMSEjRet2EjckQNa)uF4REnF9EjSnxaY9V6Lk3e4nMxQoiRKjGNBAbL4)ZwZTJSfGDOGqXlzLyY2l5mh6cYK7dF1VTVEVe2Mla5(x9sLBc8gZlvhKvYeWZnTGs8)zR52r2cWouqO4LSsmz7LCbzY1oehj(WxT62xVxcBZfGC)REPYnbEJ5LI5Jqg5q2wY4LSsmz7L(4pps0PJgqugUMFO9P(Wx9l7R3lHT5cqU)vVu5MaVX8sX8rDKA(GqMAq22YazKczlfoKvPcKfga7qqZn64b1ue5ub2Mla5qMkiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYiFhYkzc45Mwqj()S1C7iBbyhk4eNft2qM6azRKXlzLyY2lXTJmnnja(WxT6XxVxcBZfGC)REPYnbEJ5LuWqWTJSfGDO4WVnnfYQubYKdYQdYkzc45MwWrlECtqio8BttHSkvGS6GmLAkHbWoeC0Ih3eecSnxaYHmzHmvqwjtap30ckX)NTMBhzla7qXHFBAkKr(oK9YYazQGmKsXUGcxqMCD6OJhuJn(jrCwtgKroKTYlzLyY2l5cYKRthD8GASXpj(Wx9kz817LW2Cbi3)QxYkXKTxsjlKHbDEdY1L8RqewmzR5yTPGEPYnbEJ5LKdYkzc45Mwqj()S1C7iBbyhko8BttHmY3HSTxdYQubYI5J6i18bHm12HSTKbYKfYubzYbzLmb8Ctl4OfpUjieh(TPPqwLkqwDqMsnLWayhcoAXJBccb2Mla5qMSEP2(OxsjlKHbDEdY1L8RqewmzR5yTPG(Wx9Qv(69syBUaK7F1lzLyY2lDzuocAGCDTm5zQ5ja4Lk3e4nMxsoiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYiFhY2EniRsfilMpQJuZheYuBhY2sgitwitfKjhKvYeWZnTGJw84MGqC43MMczvQaz1bzk1ucdGDi4OfpUjieyBUaKdzY6LA7JEPlJYrqdKRRLjptnpbaF4RE12(69syBUaK7F1lzLyY2lrFMA4PRHD(1hcMIxQCtG3yEj5GSsMaEUPfuI)pBn3oYwa2HId)20uiJ8DiB71GSkvGSy(OosnFqitTDiBlzGmzHmvqMCqwjtap30coAXJBccXHFBAkKvPcKvhKPutjma2HGJw84MGqGT5cqoKjRxQTp6LOptn801Wo)6dbtXh(QxTLVEVe2Mla5(x9swjMS9sM6LyuYa7q3grmacQxQCtG3yEj5GSsMaEUPfuI)pBn3oYwa2HId)20uiJ8DiB71GSkvGSy(OosnFqitTDiBlzGmzHmvqMCqwjtap30coAXJBccXHFBAkKvPcKvhKPutjma2HGJw84MGqGT5cqoKjRxQTp6Lm1lXOKb2HUnIyaeuF4REL67R3lHT5cqU)vVKvIjBVumCKg591LKJVaVu5MaVX8sYbzLmb8CtlOe)F2AUDKTaSdfh(TPPqg57q22RbzvQazX8rDKA(GqMA7q2wYazYczQGm5GSsMaEUPfC0Ih3eeId)20uiRsfiRoitPMsyaSdbhT4XnbHaBZfGCitwVuBF0lfdhPrEFDj54lWh(QxTMVEVe2Mla5(x9swjMS9s1gdOthnnY7t9sLBc8gZljhKvYeWZnTGs8)zR52r2cWouC43MMczKVdzBVgKvPcKfZh1rQ5dczQTdzBjdKjlKPcYKdYkzc45MwWrlECtqio8BttHSkvGS6GmLAkHbWoeC0Ih3eecSnxaYHmz9sT9rVuTXa60rtJ8(uF4RE1B7R3lzLyY2lDJIca1tRPkwb9syBUaK7F1h(QxPU917LW2Cbi3)QxQCtG3yEPA2nMlaf8mOAcfVKvIjBVeTKe30l6yIh0h(Qx9Y(69syBUaK7F1lvUjWBmVun7gZfGcEgunHIxYkXKTxA(kyZNErxSWOXLkpOp8vVs94R3lHT5cqU)vVu5MaVX8sYbzUeooIPXAtyUauZX)qrbnSczqg5q2wVmKvPcKzLyQHASX)GuiJCiBfKjlKPcYQz3yUauWZGQju8swjMS9s0KaOVm8HV6TLXxVxcBZfGC)REPYnbEJ5LQz3yUauWZGQjuGmvqMCqwy3cgIh0aXJwPeqMAq2AYazvQazoZYtOp8BttHmYHS1KbYK1lzLyY2lXXY8Ty6fTBccF4dVepdQVEF1R817LW2Cbi3)QxQCtG3yEjEgIsEhHsmzlo8BttHm12HmRet2ckICD6Ol5DekXKTOy0qhZhHmsHSy(Oosn9XooKrkKP(ITHS3Hm5GSvqM6azHbWoeLdrLPx0C0Ihb2Mla5q27qMmIvRbzYczQGmQcca6WUfmOckICD6Ol5DekXKT2seYiFhY2cYifYoB4ASg2Hy6AeGgpZfGccfiJuilma2HyZnXdQNwBlztIaBZfGCitfKvhKXZqqrKRthDjVJqjMSfh(TPPqMkiRoiZkXKTGIixNo6sEhHsmzlMw7aMLNWlzLyY2lrrKRthDjVJqjMS9HV6T917LW2Cbi3)QxYkXKTxYwYMeVu5MaVX8sHbWoeLdrLPx0C0Ihb2Mla5qMkiZkXud18me2s2KazQbzVnKPcYI5J6i18bHmYHSvYazQGm5GSd)20uitTDiBPWHSkvGSsMaEUPfuI)pBn3oYwa2HId)20uiJCiBLmqMkitoi7WVnnfYudYwdYQubYQdYS3G3eOqXAo(NIE6AzXIjBXznzqMki7qNdPpMlaHmzHmz9sfskauh2TGb1x9kF4RElF9EjSnxaY9V6LSsmz7LSLSjXlvUjWBmVuDqwyaSdr5quz6fnhT4rGT5cqoKPcYSsm1qnpdHTKnjqMAq2ldzQGSy(OosnFqiJCiBLmqMkitoi7WVnnfYuBhYwkCiRsfiRKjGNBAbL4)ZwZTJSfGDO4WVnnfYihYwjdKPcYKdYo8BttHm1GS1GSkvGS6Gm7n4nbkuSMJ)PONUwwSyYwCwtgKPcYo05q6J5cqitwitwVuHKca1HDlyq9vVYh(QvFF9EjSnxaY9V6LSsmz7LOJYt2AW4GEPYnbEJ5LKdYSsm1qnpdbDuEYwdgheYudYEzitDGSWayhIYHOY0lAoAXJaBZfGCitDGmQcca6WUfmOcAUrhpOMIiNQTeHmzHmvqwmFuhPMpiKroKTsgitfKDOZH0hZfGqMkitoiRoi7WVnnfYubzufea0HDlyqfue560rxY7iuIjBTLiKTdzRGSkvGSsMaEUPfuI)pBn3oYwa2HId)20uiJCiJMean9XooK9oKzLyYwq00WCbO2CCatjMSf4lalebQJ5JqMSEPcjfaQd7wWG6RELp8vVMVEVe2Mla5(x9swjMS9sL8ocLyY2lvUjWBmVevbbaDy3cgubfrUoD0L8ocLyYwBjczQbzBbzKczNnCnwd7qmDncqJN5cqbHcKrkKfga7qS5M4b1tRTLSjrGT5cqoKPcYKdYo8BttHm12HSLchYQubYkzc45Mwqj()S1C7iBbyhko8BttHmYHSvYazQGSdDoK(yUaeYKfYubzHDlyiI5J6i18bHmYHSvY4LkKuaOoSBbdQV6v(Wx9B7R3lHT5cqU)vVu5MaVX8sh6Ci9XCbOxYkXKTxIOPH5cqT54aMsmz7dF4LCgaapQVEF1R817LW2Cbi3)QxYkXKTxIOPH5cqT54aMsmz7Lk3e4nMxQKjGNBAbhT4XnbH4WVnnfYuBhYwkCi7DiBBitfKrvqaqh2TGbvqrKRthDjVJqjMS1wIq2oKTcYifYoB4ASg2Hy6AeGgpZfGccfitfKvYeWZnTGs8)zR52r2cWouC43MMczKdzBlJxcmnQlCV0Q18HV6T917LW2Cbi3)QxQCtG3yEjLAkHbWoeC0Ih3eecSnxaYHmvqgvbbaDy3cgubfrUoD0L8ocLyYwBjcz7q2kiJui7SHRXAyhIPRraA8mxakiuGmvqMCqgpdHTKnjId)20uitniJNHWwYMebN4SyYgYEhYKrOUxdYQubY4zik5DekXKT4WVnnfYudY4zik5DekXKTGtCwmzdzVdzYiu3RbzvQaz8me0r5jBnyCqXHFBAkKPgKXZqqhLNS1GXbfCIZIjBi7DitgH6EnitwitfKvYeWZnTGJw84MGqC43MMczQTdzwjMSf2s2KiwkCi7Dit9Hmvqwjtap30ckX)NTMBhzla7qXHFBAkKroKTTmEjRet2EPIbaARet2AWqdVeyOHUTp6L4U6dDoK(4dF1B5R3lHT5cqU)vVu5MaVX8sk1ucdGDi4OfpUjieyBUaKdzQGmQcca6WUfmOckICD6Ol5DekXKT2seY2HSvqgPq2zdxJ1WoetxJa04zUauqOazQGSsMaEUPfuI)pBn3oYwa2HId)20uitTDiJMean9XooK9oKzLyYwylztIyPWHmsHmRet2cBjBselfoK9oKTfKPcYKdY4ziSLSjrC43MMczQbz8me2s2Ki4eNft2q27q2kiRsfiJNHOK3rOet2Id)20uitniJNHOK3rOet2coXzXKnK9oKTcYQubY4ziOJYt2AW4GId)20uitniJNHGokpzRbJdk4eNft2q27q2kitwVKvIjBVuXaaTvIjBnyOHxcm0q32h9sCx9HohsF8HVA13xVxcBZfGC)REPYnbEJ5LQz3yUauWZGQjuGmvqMCqwjtap30ckX)NTMBhzla7qXHFBAkKr(oKTLmqgPq2sHdzvQazLmb8CtlOe)F2AUDKTaSdfh(TPPqg5qMvIjBbL4)ZwZTJSfGDOOKjGNBAitDGSTLbYK1lzLyY2lXrlECtq4dF1R5R3lHT5cqU)vVu5MaVX8sUeooIFwd)yhccfitfK5s44i6z5jCmaqC43MM6LSsmz7LOpgp3ODtq4dF1VTVEVe2Mla5(x9sLBc8gZl5s44i(zn8JDiiuGmvqwDqMCqwyaSdbDuEYwdghuGT5cqoKPcYKdYuoSMEPWfRe2s2KazQGmLdRPxkCX2cBjBsGmvqMYH10lfUylHTKnjqMSqwLkqMYH10lfUyLWwYMeitwVKvIjBVKTKnj(WxT62xVxcBZfGC)REPYnbEJ5LCjCCe)Sg(XoeekqMkiRoitoit5WA6LcxSsqhLNS1GXbHmvqMYH10lfUyBbDuEYwdgheYubzkhwtVu4ITe0r5jBnyCqitwVKvIjBVeDuEYwdgh0h(QFzF9EjSnxaY9V6Lk3e4nMxYLWXr8ZA4h7qqOazQGS6GmLdRPxkCXkrjVJqjMSHmvqwDqwyaSdH5starG6sEhHsmzlW2Cbi3lzLyY2lvY7iuIjBF4Rw94R3lHT5cqU)vVu5MaVX8sh6Ci9XCbOxYkXKTxIOPH5cqT54aMsmz7dF1RKXxVxcBZfGC)REPYnbEJ5LCjCCetJ1MWCbOMJ)HIcAyfYGmYHSvYazQGSy(OosnFqitTDiBLmEjRet2Ej(ztRbJd6dF1Rw5R3lHT5cqU)vVu5MaVX8sHbWoe0r5jBnyCqb2Mla5qMkiZLWXrmnwBcZfGAo(hkkOHvidYiFhYwtgitDGSTLbYEhYKdYOkiaOd7wWGkOiY1PJUK3rOet2AlritDGSZgUgRHDiMUgbOXZCbOGqbYiFhY2gYKfYubz8me2s2Kio8BttHmYHS1GS3HmQcca6hJgiKPcY4zik5DekXKT4WVnnfYihYwkCitfKjhKXZqqhLNS1GXbfh(TPPqg5q2sHdzvQaz1bzHbWoe0r5jBnyCqb2Mla5qMSqMkitoiJJUeooIhJOdXHFBAkKroKTgK9oKrvqaq)y0aHSkvGS6GSWayhIhJOdb2Mla5qMSqMkiRKDylt2qg5q2Aq27qgvbba9Jrd0lzLyY2lXpBAnyCqF4RE12(69syBUaK7F1lvUjWBmVuyaSdXMBIhupT2wYMeb2Mla5qMkiZLWXrmnwBcZfGAo(hkkOHvidYiFhYwtgitDGSTLbYEhYKdYOkiaOd7wWGkOiY1PJUK3rOet2AlritDGSZgUgRHDiMUgbOXZCbOGqbYiFhY2cYKfYuhiBni7DitoiJQGaGoSBbdQGIixNo6sEhHsmzRTeHm1bYoB4ASg2Hy6AeGgpZfGccfiBhY2gYKfYubz8me2s2Kio8BttHmYHS1GS3HmQcca6hJgiKPcY4zik5DekXKT4WVnnfYihYwkCitfKjhKXrxchhXJr0H4WVnnfYihYwdYEhYOkiaOFmAGqwLkqwDqwyaSdXJr0HaBZfGCitwitfKvYoSLjBiJCiBni7DiJQGaG(XOb6LSsmz7L4NnTgmoOp8vVAlF9EjSnxaY9V6Lk3e4nMxkma2HWCPjGiqDjVJqjMSfyBUaKdzQGmxchhX0yTjmxaQ54FOOGgwHmiJ8DiBnzGm1bY2wgi7DitoiJQGaGoSBbdQGIixNo6sEhHsmzRTeHm1bYoB4ASg2Hy6AeGgpZfGccfiJ8Dit9HmzHmvqgpdHTKnjId)20uiJCiBni7DiJQGaG(XObczQGm5Gmo6s44iEmIoeh(TPPqg5q2Aq27qgvbba9JrdeYQubYQdYcdGDiEmIoeyBUaKdzYczQGSs2HTmzdzKdzRbzVdzufea0pgnqVKvIjBVe)SP1GXb9HV6vQVVEVe2Mla5(x9sLBc8gZl5s44iMgRnH5cqnh)dff0WkKbzKdzBldKPcYSsm1qnpdbnja6ldiJCitgiRsfiZLWXrmnwBcZfGAo(hkkOHvidYihYuFz8swjMS9s8ZMwdgh0h(QxTMVEVKvIjBV0Jr0HxcBZfGC)R(Wx9Q32xVxYkXKTxYjleuKRT3G3eO2fTVxcBZfGC)R(Wx9k1TVEVKvIjBVKcXnoKm9I2fy0WlHT5cqU)vF4RE1l7R3lHT5cqU)vVu5MaVX8s1bz8meLSlyhNfix7aSpQDjUwC43MMczQGS6GmRet2Is2fSJZcKRDa2hftRDaZYt4LSsmz7LkzxWoolqU2byF0h(QxPE817LW2Cbi3)QxYkXKTxIF20AAsa8sfskauh2TGb1x9kV00bEhHs4Lw5Lk3e4nMxkMpQJuZheYuBhYwkCVu5XM2lTYlnDG3rOe6fq6AaV0kF4REBz817LW2Cbi3)QxYkXKTxIF20AAsa8sfskauh2TGb1x9kV00bEhHsOhhVumfYO6d)20QTMxQCtG3yEPA2nMlafFB6WMwtritfKvhKXrxchhb9X45gn(DpRGId)20uVu5XM2lTYlnDG3rOe6fq6AaV0kF4RE7v(69syBUaK7F1lzLyY2lXpBAnnjaEPcjfaQd7wWG6RELxA6aVJqj0JJxkMczu9HFBA1wZlvUjWBmVun7gZfGIVnDytRPOxQ8yt7Lw5LMoW7iuc9ciDnGxALp8vV92(69syBUaK7F1lzLyY2lXpBAnnjaEPPd8ocLWlTYlvESP9sR8sth4DekHEbKUgWlTYh(Q3ElF9EjSnxaY9V6LSsmz7LOpgp3ODtq4Lk3e4nMxQMDJ5cqX3MoSP1ueYubz1bzC0LWXrqFmEUrJF3ZkO4WVnnfYubz1bzwjMSf0hJNB0UjietRDaZYt4LkKuaOoSBbdQV6v(Wx92QVVEVe2Mla5(x9swjMS9s0hJNB0Uji8sLBc8gZlvZUXCbO4Bth20Ak6LkKuaOoSBbdQV6v(Wx92R5R3lzLyY2lrFmEUr7MGWlHT5cqU)vF4dVevbBoEuF9(Qx5R3lHT5cqU)vVu5MaVX8s1SBmxak4zq1ekEjRet2EPVbqNPOptjio0h(Q32xVxcBZfGC)REPYnbEJ5LQz3yUauqqrnfrUxYkXKTxIIixNo6sEhHsmz7dF4dF4dVha]] )


end