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
            gcd = "off",

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


    spec:RegisterPack( "Affliction", 20200910, [[dCKOfcqijvEKQuXLuLqBIi9jvjigfr4uiQwLQuEfI0SOcDljrSlu9lLsggIYXuswMQKEMsrttsuDnjvTnvPQ(MKizCQsvoNKi16uLG08KeUNQyFubhusuyHkL6HQsLyIQsL6IsII0jvLkjRusXmvLkPUPKOOStjLwQQeupLOMQsHRkjkQ(QKOi2lv9xsnyuomLftLESetMWLH2mj9zLy0kvNwXRjIMnWTvv7wQFlA4K44sIslxLNJ00fUocBxs67kPgVQe48iI1RkrZNkA)G2VYVHxwyb6R9vYELmYQ0RiJVIS63S(n9YbjkOxwXksAlOxUTp6LRmuvbtjMS9YkgjG0e(n8Y0K4kOxEpcf6l0T2AzIDcxEj)BrNpbWIj7YzQXw05x2Yl7smG4Dv7D9YclqFTVs2RKrwLEfz8vKv)M1)QxMQGfFTV((17L3hHaBVRxwG0Ix(DGSkdvvWuIjBiRYe7azrsynVdKjJkb(DXdYwrMJq2RK9kzWAG18oq27YU1li9fkSM3bYQeiRYqiqbKjRGaaK9UolsYH18oqwLazvgcbkGS3nwnjoiRYmBzkCynVdKvjq2lm(ZQOaYc7wWqpQCohwZ7azvcK9cJvwI5qi7DNBqHmcfilBilSBbditnpi7DJwS7MGaYKGoDbHSdvpKUdzGCzkq2qHmXOQIh2bKnQq27Y7Mcz2HqMyOMlafKZH18oqwLazVWOcWkiKrXQ4zailSBbdEmFuhPwmiKvmksHS1tSdzX8rDKAXGqMeylGSufYWUKeDGh5CVSYLQda9YVdKvzOQcMsmzdzvMyhilscR5DGmzujWVlEq2kYCeYELSxjdwdSM3bYEx2TEbPVqH18oqwLazvgcbkGmzfeaGS31zrsoSM3bYQeiRYqiqbK9UXQjXbzvMzltHdR5DGSkbYEHXFwffqwy3cg6rLZ5WAEhiRsGSxySYsmhczV7CdkKrOazzdzHDlyazQ5bzVB0ID3eeqMe0PliKDO6H0DidKltbYgkKjgvv8WoGSrfYExE3uiZoeYed1CbOGCoSM3bYQei7fgvawbHmkwfpdazHDlyWJ5J6i1IbHSIrrkKTEIDilMpQJulgeYKaBbKLQqg2LKOd8iNdRbwZ7azvM(cWcrGciZfvZdHSs(DTaYCXLPPCiRYOuqLGczD2vYUDFvcaKzLyYMczzdiHdR5DGmRet2uUYHL87AXJkWOscR5DGmRet2uUYHL87AbPpBPMPawZ7azwjMSPCLdl531csF2Yiw(yhwmzdRXkXKnLRCyj)Uwq6ZwuI)pBTcgWASsmzt5khwYVRfK(S1Yn)CouNQAQvUrDkOJJ6tyaSd(Yn)CouNQAQvUrDkihBZfGcynVdKzLyYMYvoSKFxli9zlABk09m00WckSgRet2uUYHL87AbPpBPKXKnSgRet2uUYHL87AbPpBrqr9e43X2(4J9s6UDgvRMDOtvTsUgpynwjMSPCLdl531csF2IIOqNQ6sEhHsmz74O(qvqaqh2TGbLtruOtvDjVJqjMS1wIo8SP06WklXOOGc(Q3VsV5QkhwJvIjBkx5Ws(DTG0NT2nIoG1yLyYMYvoSKFxli9zl6UjY1A3eeooQp1fga7GVBeDWX2CbOqkvbbaDy3cguofrHov1L8ocLyYwBjwXMsRdRSeJIck4RE)k9MRQCynWAEhiRY0xawicuazyv8ibYI5JqwSJqMvI8GSHczwvBaMla5WASsmztFOkiaObzrsynwjMSPK(SLaRMeN(BltbwJvIjBkPpBr3nrUw7MGWXr9XLqvLt3nrUwJF3ZkiNqrQlHQkNUBICTg)UNvq(HFBAAffJg6y(iPXzvrGoMpcRXkXKnL0NTQA3yUa0X2(4dbf1uefow1ae4tyaSdonxRJDutruq5yBUauiLQGaGoSBbdkNIOqNQ6sEhHsmzRTeD4ztspBeASk2bF6QeGgpZfGCcfNoddGDWPJYE2AWOICSnxakKsvqaqh2TGbLtruOtvDjVJqjMSD4PEspBeASk2bF6QeGgpZfGCcfNoPkiaOd7wWGYPik0PQUK3rOet2o88EKE2i0yvSd(0vjanEMla5ekWASsmztj9zRQ2nMlaDSTp(OycX0loMkpumCSQbiWhRet2C6UjY1A3eeC8fGfIa1X8X3SxI3eiVy0IjMErxmG9NGeo2MlafWASsmztj9zRQ2nMlaDSTp(OycX0loMkphsXWXQgGaFwkchh1h7L4nbYlgTyIPx0fdy)jiHJT5cqHujcdGDWfNnTMMeao2MlafoDQuvjma2bxGwS7MGGJT5cqH0sMarUU5c0ID3ee8d)200kEwkcYH1yLyYMs6ZwvTBmxa6yBF85Bth20Ak6yvdqGpufea0HDlyq5uef6uvxY7iuIjBTLyfpRinma2bF9nXoQNwBlztchBZfGcsddGDWnxAcicuxY7iuIjBo2MlafV9kPsega7GV(Myh1tRTLSjHJT5cqH0WayhCAUwh7OMIOGYX2CbOqkvbbaDy3cguofrHov1L8ocLyYwBj6WRKtQeHbWo40rzpBnyuro2MlafsRlma2bVCiQm9IwGwSZX2CbOqADHbWo4IZMwttcahBZfGcYj9SrOXQyh8PRsaA8mxaYjuG1yLyYMs6ZwvTBmxa6yBF8rKbvtO4yvdqGpsuxyaSdoDu2ZwdgvKJT5cqHtNIm40rzpBnyuroHc5sfzWTLSjHtdRiPdpRitADIm42s2KWpu9q6U5cqPIm4L8ocLyYMtOivKbNOPH5cqTPQcMsmzZjuG1yLyYMs6Zwfda0wjMS1GHgo22hFkzce56McRXkXKnL0NTeNnTMMeahNoW7iuc9ciDnWZkhl720pRCSqsbG6WUfmOpRCCuFI5J6i1IbR4zPiKstcGMUBNOI6H1yLyYMs6Zw7grhooQpufea0HDlyq5uef6uvxY7iuIjBTLyfpVs6zJqJvXo4txLa04zUaKtOaRXkXKnL0NTOe)F2AHDsUaSdDCuFQA3yUaKlYGQjuKkYGt00WCbO2uvbtjMS5h(TPPoumAOJ5JsLOUswfBRdEvSJDsoNofzWNVc2IPx0flmACPYoYJPi50lKlvI6cdGDWv2ToYVMo9cbWUjiHJT5cqHtNLmbICDZv2ToYVMo9cbWUjiHF43MMsUujQtPQsyaSdUaTy3nbbhBZfGcNolzce56Mlql2DtqWp8BttR4zPiC6SUsMarUU5c0ID3ee8d)20uNoPjbqt3Tt8qMuQcca6WUfmOCkIcDQQl5DekXKT2s0HvKE2i0yvSd(0vjanEMla5ekKdRXkXKnL0NTeOf7UjiCCuFkzce56Mtj()S1c7KCbyhYp8BttLw1UXCbixKbvtOiLQGaGoSBbdkNIOqNQ6sEhHsmzRTeFwr6zJqJvXo4txLa04zUaKtOivI6qkf7cYRo0jBDQQvWtflXKn)pDEsRZEjEtGCXHMqLaOlgam9c)SwsNolzce56Mtj()S1c7KCbyhYp8BttDytYihwJvIjBkPpBf7OMODtIwOvZRGooQpUeQQ8dlscqkvRMxb5h(TPPWASsmztj9zlBjBsCSqsbG6WUfmOpRCCuFo8BttR4zPii1kXKnNUBICT2nbbhFbyHiqDmFuAmFuhPwmOdVhSgRet2usF26J)8irNQAarzeAXH2N64O(eZhRytYG18oq2g4xjp7ibYuNxaKfjK9njriJsCiKzVKUBN9cHczQzhqMirA)cjGm3dnjHmHDsUaSdHmcQTGCynwjMSPK(SLTKnjocMg1fXZMK54O(eZhDytYKwYeiY1nNs8)zRf2j5cWoKF43MMwXZQ6LIvwIrrbf8vVFLEZvvoSgRet2usF2QK3rOet2ocMg1fXZMK54O(eZhDytYKwYeiY1nNs8)zRf2j5cWoKF43MMwXZQ6LIvwIrrbf8vVFLEZvvU06cdGDWnxAcicuxY7iuIjBo2MlafsLima2bNok7zRbJkYX2CbOWPtQcca6WUfmOCkIcDQQl5DekXKT2s0HvsPkiaOd7wWGYPik0PQUK3rOet2AlXkE2KCynwjMSPK(SfDu2Zwdgv0rW0OUiE2Kmhh1Ny(OdBsM0sMarUU5uI)pBTWojxa2H8d)200kEwvVuSYsmkkOGV69R0BUQYH1yLyYMs6ZwennmxaQnvvWuIjBhh1hRetvulYGt00WCbO2uvbtjMSFiZPtjezWjAAyUauBQQGPet2CcfPhQEiD3Cbi5WASsmztj9zlXztRPjbWXcjfaQd7wWG(SYXI1feOh1Nykss1h(TPROEhh1NQ2nMla5FB6WMwtrPc0LqvLt3nrUwJF3Zki)WVnnvQaDjuv50DtKR1439ScYp8BttR4zPiE7vynwjMSPK(SfD3e5ATBcchlKuaOoSBbd6Zkhh1NQ2nMla5FB6WMwtrPc0LqvLt3nrUwJF3Zki)WVnnvQaDjuv50DtKR1439ScYp8BttR4bFbyHiqDmF8TxjnoRkc0X8rP1zLyYMt3nrUw7MGGpTwfml7bSgRet2usF2sz36i)A60lea7MGehlKuaOoSBbd6Zkhh1Ny(OdBwV0WUfm4X8rDKAXGoS69FJQGaGE3ObkvI6qkf7cYRo0jBDQQvWtflXKn)pDEsRZEjEtGCXHMqLaOlgam9c)SwsNolzce56Mtj()S1c7KCbyhYp8BttDOYRNuAsa00D7eVzVeVjqU4qtOsa0fdaMEHFwlPtNLmbICDZPe)F2AHDsUaSd5h(TPPvSQ(3OkiaO3nAGKstcGMUBN4n7L4nbYfhAcvcGUyaW0l8ZAjjhwJvIjBkPpBrruOtvDjVJqjMSDCuFQA3yUaKtqrnfrHuAsa00D7ep1dRXkXKnL0NTkgaOTsmzRbdnCSTp(iYGcRXkXKnL0NTQoauh20HJfskauh2TGb9zLJJ6tmF0Hv1lnMpQJulg0HNvKjvIsMarUU5uI)pBTWojxa2H8d)20uh2KmNolzce56Mtj()S1c7KCbyhYp8BttRyfzsfzWTLSjHF43MM6WZkYKkYGxY7iuIjB(HFBAQdpRitQeIm40rzpBnyur(HFBAQdpRiZPZ6cdGDWPJYE2AWOICSnxakiNCynwjMSPK(Sfbf1tGFhB7Jp2lP72zuTA2Hov1k5A8CCuFI5Jv8SjSgRet2usF2sz36i)A60lea7MGehh1Ny(yfpBwpSgRet2usF2Q6aqDythooQpX8XkwvpSgRet2usF2AHWoXyTov12lXlJDhh1hjkzce56Mtj()S1c7KCbyhYp8BttRyv9KstcGMUBN4n7L4nbYfhAcvcGUyaW0lCSnxakC6uc7L4nbYfhAcvcGUyaW0l8ZAjD6ePuSliV6qNS1PQwbpvSet28ZAjjxAmF0HnjtAmFuhPwmOdpVUImYLkHidUYU1r(10Pxia2nbj8d)20uNofzWRoauh20b)WVnn1PZ6cdGDWv2ToYVMo9cbWUjiHJT5cqH06cdGDWRoauh20bhBZfGcYD6mMpQJulgSInjJ0LIawJvIjBkPpBjStsnnjaooQpLmbICDZPe)F2AHDsUaSd5h(TPPvSQEsPjbqt3Tt8M9s8Ma5IdnHkbqxmay6fo2MlafsLqKbxz36i)A60lea7MGe(HFBAQtNIm4vhaQdB6GF43MMsoSgRet2usF2YfpkEso9cSgRet2usF2QyaG2kXKTgm0WX2(4dvbBbEuynwjMSPK(SvXaaTvIjBnyOHJT9Xh1baWJcRbwJvIjBkVKjqKRB6Z68aIQ406dPzBDbH1yLyYMYlzce56Ms6Zweuupb(DSTp(yVKUBNr1Qzh6uvRKRXZXr9rI6cdGDWv2ToYVMo9cbWUjiHJT5cqHtNLmbICDZv2ToYVMo9cbWUjiHF43MMwrL)gvbba9Urd0PZ6kzce56MRSBDKFnD6fcGDtqc)WVnnLCPLmbICDZPe)F2AHDsUaSd5h(TPPvSQs)gvbba9UrdKuAsa00D7eVzVeVjqU4qtOsa0fdaMEHFwlPurgCBjBs4h(TPPsfzWl5DekXKn)WVnnvQeIm40rzpBnyur(HFBAQtN1fga7GthL9S1Grf5yBUauqoSgRet2uEjtGix3usF2sjJjBhh1hjcdGDWf2jPMMea9FO4rchBZfGcPLmbICDZPe)F2AHDsUaSd5ekslzce56MlStsnnjaCcfYD6SKjqKRBoL4)ZwlStYfGDiNqXPZy(OosTyWk2KmynwjMSP8sMarUUPK(Sfbf1tGFQJJ6tjtGix3CkX)NTwyNKla7q(HFBAQdvkYC6mMpQJulgSIxjZPtjezWjAAyUauBQQGPet28ykso9IuAsa00D7epKjvI6cdGDWv2ToYVMo9cbWUjiHJT5cqHtNLmbICDZv2ToYVMo9cbWUjiHF43MMsUujQtPQsyaSdUaTy3nbbhBZfGcNolzce56Mlql2DtqWp8BttR4zPiC6SUsMarUU5c0ID3ee8d)20uYLwxjtGix3CkX)NTwyNKla7q(HFBAk5WASsmzt5LmbICDtj9zl15qxqMchh1N6kzce56Mtj()S1c7KCbyhYjuG1yLyYMYlzce56Ms6ZwUGmfAvIJehh1N6kzce56Mtj()S1c7KCbyhYjuG1yLyYMYlzce56Ms6ZwF8Nhj6uvdikJqlo0(uhh1Ny(OdBsgSgRet2uEjtGix3usF2syNKAAsaCCuFI5J6i1IbR4vYiDPiC6mma2bNMR1XoQPikOCSnxakKwYeiY1nNs8)zRf2j5cWoKF43MM6WtjtGix3CkX)NTwyNKla7qUG4SyYUswrgSgRet2uEjtGix3usF2YfKPqNQ6yh1yJFsCCuFuWGlStYfGDi)WVnn1PtjQRKjqKRBUaTy3nbb)WVnn1PZ6uQQega7Glql2DtqWX2CbOGCPLmbICDZPe)F2AHDsUaSd5h(TPPo88EKjfPuSli3fKPqNQ6yh1yJFs4N1s6WkynVdKvzofHmH9TLPxGSSReckczXnTKyqHSFEiKLhKbqkfYYgYkzce562riJMqgi7fiZOqwSJq27Q3L3nKf7ijq20fIdYwN9lKaYqvvSeqM1KazzSJhKf30sIbfYiO2cczcIB6fiRKjqKRBkhwJvIjBkVKjqKRBkPpBrqr9e43X2(4JswKed68suOl5xHiSyYwlWQtbDCuFKOKjqKRBoL4)ZwlStYfGDi)WVnn1HNxR3PZy(OosTyWkE2KmYLkrjtGix3CbAXUBcc(HFBAQtN1Puvjma2bxGwS7MGGJT5cqb5WASsmzt5LmbICDtj9zlckQNa)o22hFUmkhbnqHUAMIm1IeaCCuFKOKjqKRBoL4)ZwlStYfGDi)WVnn1HNxR3PZy(OosTyWkE2KmYLkrjtGix3CbAXUBcc(HFBAQtN1Puvjma2bxGwS7MGGJT5cqb5WASsmzt5LmbICDtj9zlckQNa)o22hFO7tv80vXo)6dbtXXr9rIsMarUU5uI)pBTWojxa2H8d)20uhEETENoJ5J6i1IbR4ztYixQeLmbICDZfOf7Uji4h(TPPoDwNsvLWayhCbAXUBcco2MlafKdRXkXKnLxYeiY1nL0NTiOOEc87yBF8XQSeJsgyh62iIbqqDCuFKOKjqKRBoL4)ZwlStYfGDi)WVnn1HNxR3PZy(OosTyWkE2KmYLkrjtGix3CbAXUBcc(HFBAQtN1Puvjma2bxGwS7MGGJT5cqb5WASsmzt5LmbICDtj9zlckQNa)o22hFIrG0iVVUKc8f44O(irjtGix3CkX)NTwyNKla7q(HFBAQdpVwVtNX8rDKAXGv8SjzKlvIsMarUU5c0ID3ee8d)20uNoRtPQsyaSdUaTy3nbbhBZfGcYH1yLyYMYlzce56Ms6Zweuupb(DSTp(uDmGov10iVp1Xr9rIsMarUU5uI)pBTWojxa2H8d)20uhEETENoJ5J6i1IbR4ztYixQeLmbICDZfOf7Uji4h(TPPoDwNsvLWayhCbAXUBcco2MlafKdRXkXKnLxYeiY1nL0NTUrrbG6P1ufRGWASsmzt5LmbICDtj9zlAjjUPx0Xe7OJJ6tv7gZfGCrgunHcSgRet2uEjtGix3usF2A(kylMErxSWOXLk7OJJ6tv7gZfGCrgunHcSgRet2uEjtGix3usF2IMea9LHJJ6JeUeQQ8PXQtyUaulW)qronSIKoS5750PvIPkQXg)dsDyf5sRA3yUaKlYGQjuG1yLyYMYlzce56Ms6ZwcSmFlMEr7MGWXr9PQDJ5cqUidQMqrQeHDlyW3rde7ALsur9K50P6SSh6d)20uhQNmYH1aRXkXKnLlC1hQEiD)Hok7zRbJk6iyAuxepRQ3Xr9rcrgC6OSNTgmQi)WVnn9ffzWPJYE2AWOICbXzXKn5v8iHidUTKnj8d)200xuKb3wYMeUG4SyYMCPsiYGthL9S1Grf5h(TPPVOidoDu2ZwdgvKliolMSjVIhjezWl5DekXKn)WVnn9ffzWl5DekXKnxqCwmztUurgC6OSNTgmQi)WVnnTcrgC6OSNTgmQixqCwmz)2k(MWASsmzt5cx9HQhs3j9zlBjBsCemnQlINv174O(iHidUTKnj8d)200xuKb3wYMeUG4SyYM8kEKqKbVK3rOet28d)200xuKbVK3rOet2CbXzXKn5sLqKb3wYMe(HFBA6lkYGBlztcxqCwmztEfpsiYGthL9S1Grf5h(TPPVOidoDu2ZwdgvKliolMSjxQidUTKnj8d)200kezWTLSjHliolMSFBfFtynwjMSPCHR(q1dP7K(SvjVJqjMSDemnQlINv174O(iHidEjVJqjMS5h(TPPVOidEjVJqjMS5cIZIjBYR4rcrgCBjBs4h(TPPVOidUTKnjCbXzXKn5sLqKbVK3rOet28d)200xuKbVK3rOet2CbXzXKn5v8iHidoDu2ZwdgvKF43MM(IIm40rzpBnyurUG4SyYMCPIm4L8ocLyYMF43MMwHidEjVJqjMS5cIZIj73wX3ewdSgRet2uUid6dfrHov1L8ocLyY2Xr9rKbVK3rOet28d)200kESsmzZPik0PQUK3rOet28IrdDmFK0y(OosnD3obPvo)13KyvLega7GxoevMErlql25yBUau8gz8v1tUuQcca6WUfmOCkIcDQQl5DekXKT2s0HNnj9SrOXQyh8PRsaA8mxaYjuinma2bF9nXoQNwBlztchBZfGcP1jYGtruOtvDjVJqjMS5h(TPPsRZkXKnNIOqNQ6sEhHsmzZNwRcML9awJvIjBkxKbL0NTSLSjXXcjfaQd7wWG(SYXr9jma2bVCiQm9IwGwSZX2CbOqQvIPkQfzWTLSjPI3xAmFuhPwmOdRitQeh(TPPv8SueoDwYeiY1nNs8)zRf2j5cWoKF43MM6WkYKkXHFBAAf170zD2lXBcKRyTa)trpD1SyXKn)SwsPhQEiD3Cbi5KdRXkXKnLlYGs6Zw2s2K4yHKca1HDlyqFw54O(uxyaSdE5quz6fTaTyNJT5cqHuRetvulYGBlztsfVN0y(OosTyqhwrMujo8BttR4zPiC6SKjqKRBoL4)ZwlStYfGDi)WVnn1HvKjvId)200kQ3PZ6SxI3eixXAb(NIE6QzXIjB(zTKspu9q6U5cqYjhwJvIjBkxKbL0NTOJYE2AWOIowiPaqDy3cg0NvooQpsyLyQIArgC6OSNTgmQyfVxLega7GxoevMErlql25yBUauujufea0HDlyq50CTo2rnfrbvBjsU0y(OosTyqhwrM0dvpKUBUauQe1D43MMkLQGaGoSBbdkNIOqNQ6sEhHsmzRTeFw50zjtGix3CkX)NTwyNKla7q(HFBAQd0KaOP72jEZkXKnNOPH5cqTPQcMsmzZXxawicuhZhjhwJvIjBkxKbL0NTk5DekXKTJfskauh2TGb9zLJJ6dvbbaDy3cguofrHov1L8ocLyYwBjwXMKE2i0yvSd(0vjanEMla5ekKgga7GV(Myh1tRTLSjHJT5cqHujo8BttR4zPiC6SKjqKRBoL4)ZwlStYfGDi)WVnn1HvKj9q1dP7MlajxAy3cg8y(OosTyqhwrgSgRet2uUidkPpBr00WCbO2uvbtjMSDCuFSsmvrTidortdZfGAtvfmLyY(HmNoLqKbNOPH5cqTPQcMsmzZjuKEO6H0DZfGKdRbwJvIjBkxDaa8OpennmxaQnvvWuIjBhbtJ6I4zv9ooQpLmbICDZfOf7Uji4h(TPPv8SueV9QuQcca6WUfmOCkIcDQQl5DekXKT2s8zfPNncnwf7GpDvcqJN5cqoHI0sMarUU5uI)pBTWojxa2H8d)20uhELmynwjMSPC1baWJs6Zwfda0wjMS1GHgo22hFeU6dvpKU74O(Ouvjma2bxGwS7MGGJT5cqHuQcca6WUfmOCkIcDQQl5DekXKT2s8zfPNncnwf7GpDvcqJN5cqoHIujezWTLSjHF43MMwHidUTKnjCbXzXK9BKXRu170PidEjVJqjMS5h(TPPviYGxY7iuIjBUG4SyY(nY4vQ6D6uKbNok7zRbJkYp8BttRqKbNok7zRbJkYfeNft2VrgVsvp5slzce56Mlql2DtqWp8BttR4XkXKn3wYMe(sr8wLlTKjqKRBoL4)ZwlStYfGDi)WVnn1HxjdwJvIjBkxDaa8OK(SvXaaTvIjBnyOHJT9XhHR(q1dP7ooQpkvvcdGDWfOf7Uji4yBUauiLQGaGoSBbdkNIOqNQ6sEhHsmzRTeFwr6zJqJvXo4txLa04zUaKtOiTKjqKRBoL4)ZwlStYfGDi)WVnnTIhAsa00D7eVzLyYMBlztcFPii1kXKn3wYMe(sr82MsLqKb3wYMe(HFBAAfIm42s2KWfeNft2VTYPtrg8sEhHsmzZp8BttRqKbVK3rOet2CbXzXK9BRC6uKbNok7zRbJkYp8BttRqKbNok7zRbJkYfeNft2VTICynwjMSPC1baWJs6Zwc0ID3eeooQpvTBmxaYfzq1eksLOKjqKRBoL4)ZwlStYfGDi)WVnn1HNnjJ0LIWPZsMarUU5uI)pBTWojxa2H8d)20uhSsmzZPe)F2AHDsUaSd5LmbICDxjVsg5WASsmzt5QdaGhL0NTO7MixRDtq44O(4sOQY)zv8JDWjuK6sOQY7zzpunaGF43MMcRXkXKnLRoaaEusF2YwYMehh1hxcvv(pRIFSdoHI06Kima2bNok7zRbJkYX2CbOqQekhwvVue8vCBjBsKQCyv9srWFLBlztIuLdRQxkc(MCBjBsi3PtLdRQxkc(kUTKnjKdRXkXKnLRoaaEusF2Iok7zRbJk64O(4sOQY)zv8JDWjuKwNekhwvVue8vC6OSNTgmQOuLdRQxkc(RC6OSNTgmQOuLdRQxkc(MC6OSNTgmQi5WASsmzt5QdaGhL0NTk5DekXKTJJ6JlHQk)NvXp2bNqrADkhwvVue8v8sEhHsmzlTUWayhCZLMaIa1L8ocLyYMJT5cqbSgRet2uU6aa4rj9zlIMgMla1MQkykXKTJwjMQOwKbNOPH5cqTPQcMsmz)qMtNsiYGt00WCbO2uvbtjMS5ekspu9q6U5cqYH1yLyYMYvhaapkPpBjoBAnyurhh1hxcvv(0y1jmxaQf4FOiNgwrshwrM0y(OosTyWkEwrgSgRet2uU6aa4rj9zlXztRbJk64O(ega7GthL9S1Grf5yBUaui1LqvLpnwDcZfGAb(hkYPHvK0HN6jRsELS3KGQGaGoSBbdkNIOqNQ6sEhHsmzRTeRKZgHgRIDWNUkbOXZCbiNqXHNxjxQidUTKnj8d)20uhQ)nQcca6DJgOurg8sEhHsmzZp8BttDyPiKkHidoDu2ZwdgvKF43MM6Wsr40zDHbWo40rzpBnyuro2MlafKlvcb6sOQY3nIo4h(TPPou)Bufea07gnqNoRlma2bF3i6GJT5cqb5slzh2YKTd1)gvbba9UrdewJvIjBkxDaa8OK(SL4SP1GrfDCuFcdGDWxFtSJ6P12s2KWX2CbOqQlHQkFAS6eMla1c8puKtdRiPdp1twL8kzVjbvbbaDy3cguofrHov1L8ocLyYwBjwjNncnwf7GpDvcqJN5cqoHIdpBsELu)Bsqvqaqh2TGbLtruOtvDjVJqjMS1wIvYzJqJvXo4txLa04zUaKtO88k5sfzWTLSjHF43MM6q9VrvqaqVB0aLkYGxY7iuIjB(HFBAQdlfHujeOlHQkF3i6GF43MM6q9VrvqaqVB0aD6SUWayh8DJOdo2MlafKlTKDylt2ou)Bufea07gnqynwjMSPC1baWJs6ZwIZMwdgv0Xr9jma2b3CPjGiqDjVJqjMS5yBUaui1LqvLpnwDcZfGAb(hkYPHvK0HN6jRsELS3KGQGaGoSBbdkNIOqNQ6sEhHsmzRTeRKZgHgRIDWNUkbOXZCbiNqXHNkNCPIm42s2KWp8BttDO(3OkiaO3nAGsLqGUeQQ8DJOd(HFBAQd1)gvbba9Urd0PZ6cdGDW3nIo4yBUauqU0s2HTmz7q9VrvqaqVB0aH1yLyYMYvhaapkPpBjoBAnyurhh1hxcvv(0y1jmxaQf4FOiNgwrshELmPwjMQOwKbNMea9LHdK50PlHQkFAS6eMla1c8puKtdRiPdvozWASsmzt5QdaGhL0NT2nIoG1yLyYMYvhaapkPpBPMfckk02lXBcu7I2hwJvIjBkxDaa8OK(SLcXnQKm9I2fy0awJvIjBkxDaa8OK(Svj7c2Xzbk0Qa7JooQp1jYGxYUGDCwGcTkW(O2L4A(HFBAQ06SsmzZlzxWoolqHwfyFKpTwfml7bSgRet2uU6aa4rj9zlXztRPjbWXPd8ocLqVasxd8SYXYUn9ZkhNoW7iuINvowiPaqDy3cg0NvooQpX8rDKAXGv8SueWASsmzt5QdaGhL0NTeNnTMMeahlKuaOoSBbd6Zkhl720pRCC6aVJqj0J6tmfjP6d)20vuVJth4DekHEbKUg4zLJJ6tv7gZfG8VnDytRPO06eOlHQkNUBICTg)UNvq(HFBAkSgRet2uU6aa4rj9zlXztRPjbWXcjfaQd7wWG(SYXYUn9ZkhNoW7iuc9O(etrsQ(WVnDf1740bEhHsOxaPRbEw54O(u1UXCbi)Bth20AkcRXkXKnLRoaaEusF2sC20AAsaCC6aVJqj0lG01apRCSSBt)SYXPd8ocL4zfSgRet2uU6aa4rj9zl6UjY1A3eeowiPaqDy3cg0NvooQpvTBmxaY)20HnTMIsRtGUeQQC6UjY1A87Ewb5h(TPPsRZkXKnNUBICT2nbbFATkyw2dynwjMSPC1baWJs6Zw0DtKR1UjiCSqsbG6WUfmOpRCCuFQA3yUaK)TPdBAnfH1yLyYMYvhaapkPpBr3nrUw7MGawdSgRet2uovbBbE0NVbq1POptjio0Xr9PQDJ5cqUidQMqbwJvIjBkNQGTapkPpBrruOtvDjVJqjMSDCuFQA3yUaKtqrnfrHxUkE0jBFTVs2RKr27Tjz8n9YRTRNEH6LFx9vYlqbKvPGmRet2qgyObLdRXlBeXEEEz55)U4LbdnO(n8Ycx9HQhs39B4RDLFdVm2Mlaf(T9YwjMS9Y0rzpBnyurVC5MaVX8YsazIm40rzpBnyur(HFBAkK9IqMidoDu2ZwdgvKliolMSHmYHSkEGmjGmrgCBjBs4h(TPPq2lczIm42s2KWfeNft2qg5qMuitcitKbNok7zRbJkYp8BttHSxeYezWPJYE2AWOICbXzXKnKroKvXdKjbKjYGxY7iuIjB(HFBAkK9IqMidEjVJqjMS5cIZIjBiJCitkKjYGthL9S1Grf5h(TPPqwfqMidoDu2ZwdgvKliolMSHS3GSv8n9YGPrDr4LxvVp81(QFdVm2Mlaf(T9YwjMS9Y2s2K4Ll3e4nMxwcitKb3wYMe(HFBAkK9IqMidUTKnjCbXzXKnKroKvXdKjbKjYGxY7iuIjB(HFBAkK9IqMidEjVJqjMS5cIZIjBiJCitkKjbKjYGBlztc)WVnnfYEritKb3wYMeUG4SyYgYihYQ4bYKaYezWPJYE2AWOI8d)20ui7fHmrgC6OSNTgmQixqCwmzdzKdzsHmrgCBjBs4h(TPPqwfqMidUTKnjCbXzXKnK9gKTIVPxgmnQlcV8Q69HV2n9B4LX2CbOWVTx2kXKTxUK3rOet2E5YnbEJ5LLaYezWl5DekXKn)WVnnfYEritKbVK3rOet2CbXzXKnKroKvXdKjbKjYGBlztc)WVnnfYEritKb3wYMeUG4SyYgYihYKczsazIm4L8ocLyYMF43MMczViKjYGxY7iuIjBUG4SyYgYihYQ4bYKaYezWPJYE2AWOI8d)20ui7fHmrgC6OSNTgmQixqCwmzdzKdzsHmrg8sEhHsmzZp8BttHSkGmrg8sEhHsmzZfeNft2q2Bq2k(MEzW0OUi8YRQ3h(WllqvJae(n81UYVHx2kXKTxMQGaGgKfj9YyBUau432h(AF1VHx2kXKTxwGvtIt)TLP4LX2CbOWVTp81UPFdVm2Mlaf(T9YLBc8gZl7sOQYP7MixRXV7zfKtOazsHmxcvvoD3e5An(DpRG8d)20uiRciRy0qhZhHmsHS4SQiqhZh9YwjMS9Y0DtKR1Uji8HV2k3VHxgBZfGc)2E5uXltXWlBLyY2lx1UXCbOxUQbiqVCyaSdonxRJDutruq5yBUauazsHmQcca6WUfmOCkIcDQQl5DekXKT2seYC4bY2eYifYoBeASk2bF6QeGgpZfGCcfiZPtilma2bNok7zRbJkYX2CbOaYKczufea0HDlyq5uef6uvxY7iuIjBiZHhiREiJui7SrOXQyh8PRsaA8mxaYjuGmNoHmQcca6WUfmOCkIcDQQl5DekXKnK5WdK9EqgPq2zJqJvXo4txLa04zUaKtO4LRANUTp6LjOOMIOWh(AR3VHxgBZfGc)2E5uXltXWlBLyY2lx1UXCbOxUQbiqVSvIjBoD3e5ATBcco(cWcrG6y(iK9gKzVeVjqEXOftm9IUya7pbjCSnxak8YvTt32h9YkMqm9Ip81(((n8YyBUau432lNkE5dPy4LTsmz7LRA3yUa0lx1aeOxEPi8YLBc8gZlBVeVjqEXOftm9IUya7pbjCSnxakGmPqMeqwyaSdU4SP10KaWX2CbOaYC6eYuQQega7Glql2DtqWX2CbOaYKczLmbICDZfOf7Uji4h(TPPqwfpq2srazK7LRANUTp6LvmHy6fF4RTs53WlJT5cqHFBVCQ4LPy4LTsmz7LRA3yUa0lx1aeOxMQGaGoSBbdkNIOqNQ6sEhHsmzRTeHSkEGSvqgPqwyaSd(6BIDupT2wYMeo2MlafqgPqwyaSdU5starG6sEhHsmzZX2CbOaYEdYEfYifYKaYcdGDWxFtSJ6P12s2KWX2CbOaYKczHbWo40CTo2rnfrbLJT5cqbKjfYOkiaOd7wWGYPik0PQUK3rOet2AlriZbi7viJCiJuitcilma2bNok7zRbJkYX2CbOaYKcz1bzHbWo4LdrLPx0c0IDo2MlafqMuiRoilma2bxC20AAsa4yBUauazKdzKczNncnwf7GpDvcqJN5cqoHIxUQD62(Ox(Bth20Ak6dFTVNFdVm2Mlaf(T9YPIxMIHx2kXKTxUQDJ5cqVCvdqGEzjGS6GSWayhC6OSNTgmQihBZfGciZPtitKbNok7zRbJkYjuGmYHmPqMidUTKnjCAyfjHmhEGSvKbzsHS6GmrgCBjBs4hQEiD3CbiKjfYezWl5DekXKnNqbYKczIm4ennmxaQnvvWuIjBoHIxUQD62(OxwKbvtO4dFTvA)gEzSnxak8B7LTsmz7LlgaOTsmzRbdn8YGHg62(OxUKjqKRBQp81UIm)gEzSnxak8B7LTsmz7LfNnTMMeaVCHKca1HDlyq91UYlxUjWBmVCmFuhPwmiKvXdKTueqMuiJMeanD3obKvbKvVxUSBt7Lx5LNoW7iuc9ciDnGxELp81UALFdVm2Mlaf(T9YLBc8gZltvqaqh2TGbLtruOtvDjVJqjMS1wIqwfpq2RqgPq2zJqJvXo4txLa04zUaKtO4LTsmz7L3nIo8HV2vV63WlJT5cqHFBVC5MaVX8YvTBmxaYfzq1ekqMuitKbNOPH5cqTPQcMsmzZp8BttHmhGSIrdDmFeYKczsaz1bzLSk2wh8Qyh7KCqMtNqMid(8vWwm9IUyHrJlv2rEmfjNEbYihYKczsaz1bzHbWo4k7wh5xtNEHay3eKWX2CbOaYC6eYkzce56MRSBDKFnD6fcGDtqc)WVnnfYihYKczsaz1bzkvvcdGDWfOf7Uji4yBUauazoDczLmbICDZfOf7Uji4h(TPPqwfpq2srazoDcz1bzLmbICDZfOf7Uji4h(TPPqMtNqgnjaA6UDci7bYidYKczufea0HDlyq5uef6uvxY7iuIjBTLiK5aKTcYifYoBeASk2bF6QeGgpZfGCcfiJCVSvIjBVmL4)ZwlStYfGDOp81UAt)gEzSnxak8B7Ll3e4nMxUKjqKRBoL4)ZwlStYfGDi)WVnnfYKczvTBmxaYfzq1ekqMuiJQGaGoSBbdkNIOqNQ6sEhHsmzRTeHShiBfKrkKD2i0yvSd(0vjanEMla5ekqMuitciRoidPuSliV6qNS1PQwbpvSet28)05bzsHS6Gm7L4nbYfhAcvcGUyaW0l8ZAjHmNoHSsMarUU5uI)pBTWojxa2H8d)20uiZbiBtYGmY9YwjMS9Yc0ID3ee(Wx7Qk3VHxgBZfGc)2E5YnbEJ5LDjuv5hwKeGuQwnVcYp8Btt9YwjMS9YXoQjA3KOfA18kOp81UQE)gEzSnxak8B7LTsmz7LTLSjXlxUjWBmV8HFBAkKvXdKTueqgPqMvIjBoD3e5ATBcco(cWcrG6y(iKjfYI5J6i1IbHmhGS3ZlxiPaqDy3cguFTR8HV2vVVFdVm2Mlaf(T9YLBc8gZlhZhHSkGSnjZlBLyY2l)XFEKOtvnGOmcT4q7t9HV2vvk)gEzSnxak8B7LTsmz7LTLSjXlxUjWBmVCmFeYCaY2KmitkKvYeiY1nNs8)zRf2j5cWoKF43MMczv8azRQhYKczyLLyuuqb3EjD3oJQvZo0PQwjxJNxgmnQlcV8MK5dFTREp)gEzSnxak8B7LTsmz7Ll5DekXKTxUCtG3yE5y(iK5aKTjzqMuiRKjqKRBoL4)ZwlStYfGDi)WVnnfYQ4bYwvpKjfYWklXOOGcU9s6UDgvRMDOtvTsUgpitkKvhKfga7GBU0eqeOUK3rOet2CSnxakGmPqMeqwyaSdoDu2ZwdgvKJT5cqbK50jKrvqaqh2TGbLtruOtvDjVJqjMS1wIqMdq2kitkKrvqaqh2TGbLtruOtvDjVJqjMS1wIqwfpq2Mqg5EzW0OUi8YBsMp81UQs73WlJT5cqHFBVSvIjBVmDu2Zwdgv0lxUjWBmVCmFeYCaY2KmitkKvYeiY1nNs8)zRf2j5cWoKF43MMczv8azRQhYKczyLLyuuqb3EjD3oJQvZo0PQwjxJNxgmnQlcV8MK5dFTVsMFdVm2Mlaf(T9YLBc8gZlBLyQIArgCIMgMla1MQkykXKnK9azKbzoDczsazIm4ennmxaQnvvWuIjBoHcKjfYou9q6U5cqiJCVSvIjBVmrtdZfGAtvfmLyY2h(AFDLFdVm2Mlaf(T9YwjMS9YIZMwttcGxUqsbG6WUfmO(Ax5LlwxqGEu9YXuKKQp8Btxr9E5YnbEJ5LRA3yUaK)TPdBAnfHmPqMaDjuv50DtKR1439ScYp8BttHmPqMaDjuv50DtKR1439ScYp8BttHSkEGSLIaYEdYE1h(AF9v)gEzSnxak8B7LTsmz7LP7MixRDtq4Ll3e4nMxUQDJ5cq(3MoSP1ueYKczc0LqvLt3nrUwJF3Zki)WVnnfYKczc0LqvLt3nrUwJF3Zki)WVnnfYQ4bYWxawicuhZhHS3GSxHmsHS4SQiqhZhHmPqwDqMvIjBoD3e5ATBcc(0AvWSShE5cjfaQd7wWG6RDLp81(6M(n8YyBUau432lBLyY2lRSBDKFnD6fcGDtqIxUCtG3yE5y(iK5aKTz9qMuilSBbdEmFuhPwmiK5aKT69HS3GmQcca6DJgiKjfYKaYQdYqkf7cYRo0jBDQQvWtflXKn)pDEqMuiRoiZEjEtGCXHMqLaOlgam9c)SwsiZPtiRKjqKRBoL4)ZwlStYfGDi)WVnnfYCaYQ86HmsHmAsa00D7eq2BqM9s8Ma5IdnHkbqxmay6f(zTKqMtNqwjtGix3CkX)NTwyNKla7q(HFBAkKvbKTQEi7niJQGaGE3ObczKcz0KaOP72jGS3Gm7L4nbYfhAcvcGUyaW0l8ZAjHmY9Yfskauh2TGb1x7kF4R91k3VHxgBZfGc)2E5YnbEJ5LRA3yUaKtqrnfrbKjfYOjbqt3Ttazpqw9EzRet2EzkIcDQQl5DekXKTp81(A9(n8YyBUau432lBLyY2lxmaqBLyYwdgA4Lbdn0T9rVSidQp81(6773WlJT5cqHFBVSvIjBVC1bG6WMo8YLBc8gZlhZhHmhGSv1dzsHSy(OosTyqiZHhiBfzqMuitciRKjqKRBoL4)ZwlStYfGDi)WVnnfYCaY2KmiZPtiRKjqKRBoL4)ZwlStYfGDi)WVnnfYQaYwrgKjfYezWTLSjHF43MMczo8azRidYKczIm4L8ocLyYMF43MMczo8azRidYKczsazIm40rzpBnyur(HFBAkK5WdKTImiZPtiRoilma2bNok7zRbJkYX2CbOaYihYi3lxiPaqDy3cguFTR8HV2xRu(n8YyBUau432lBLyY2lBVKUBNr1Qzh6uvRKRXZlxUjWBmVCmFeYQ4bY20l32h9Y2lP72zuTA2Hov1k5A88HV2xFp)gEzSnxak8B7Ll3e4nMxoMpczv8azBwVx2kXKTxwz36i)A60lea7MGeF4R91kTFdVm2Mlaf(T9YLBc8gZlhZhHSkGSv17LTsmz7LRoauh20Hp81Ujz(n8YyBUau432lxUjWBmVSeqwjtGix3CkX)NTwyNKla7q(HFBAkKvbKTQEiJuiJMeanD3obK9gKzVeVjqU4qtOsa0fdaMEHJT5cqbK50jKjbKzVeVjqU4qtOsa0fdaMEHFwljK50jKHuk2fKxDOt26uvRGNkwIjB(zTKqg5qMuilMpczoazBsgKjfYI5J6i1IbHmhEGSxxrgKroKjfYKaYezWv2ToYVMo9cbWUjiHF43MMczoDczIm4vhaQdB6GF43MMczoDcz1bzHbWo4k7wh5xtNEHay3eKWX2CbOaYKcz1bzHbWo4vhaQdB6GJT5cqbKroK50jKfZh1rQfdczvazBsgKrkKTueEzRet2E5fc7eJ16uvBVeVm29HV2nx53WlJT5cqHFBVC5MaVX8YLmbICDZPe)F2AHDsUaSd5h(TPPqwfq2Q6HmsHmAsa00D7eq2BqM9s8Ma5IdnHkbqxmay6fo2MlafqMuitcitKbxz36i)A60lea7MGe(HFBAkK50jKjYGxDaOoSPd(HFBAkKrUx2kXKTxwyNKAAsa8HV2nF1VHx2kXKTx2fpkEso9IxgBZfGc)2(Wx7MB63WlJT5cqHFBVSvIjBVCXaaTvIjBnyOHxgm0q32h9YufSf4r9HV2nRC)gEzSnxak8B7LTsmz7LlgaOTsmzRbdn8YGHg62(OxwDaa8O(WhEzLdl531c)g(Ax53WlBLyY2ltj()S1QiyNOd88YyBUau432h(AF1VHxgBZfGc)2E5YnbEJ5LddGDWxU5NZH6uvtTYnQtb5yBUau4LTsmz7LxU5NZH6uvtTYnQtb9HV2n9B4LTsmz7LvYyY2lJT5cqHFBF4RTY9B4LX2CbOWVTxUTp6LTxs3TZOA1SdDQQvY145LTsmz7LTxs3TZOA1SdDQQvY145dFT173WlJT5cqHFBVC5MaVX8Yufea0HDlyq5uef6uvxY7iuIjBTLiK5WdKTjKjfYQdYWklXOOGcU9s6UDgvRMDOtvTsUgpVSvIjBVmfrHov1L8ocLyY2h(AFF)gEzRet2E5DJOdVm2Mlaf(T9HV2kLFdVm2Mlaf(T9YLBc8gZlxhKfga7GVBeDWX2CbOaYKczufea0HDlyq5uef6uvxY7iuIjBTLiKvbKTjKjfYQdYWklXOOGcU9s6UDgvRMDOtvTsUgpVSvIjBVmD3e5ATBccF4dVCjtGix3u)g(Ax53WlBLyY2lVopGOkoT(qA2wxqVm2Mlaf(T9HV2x9B4LX2CbOWVTx2kXKTx2EjD3oJQvZo0PQwjxJNxUCtG3yEzjGS6GSWayhCLDRJ8RPtVqaSBcs4yBUauazoDczLmbICDZv2ToYVMo9cbWUjiHF43MMczvazvoK9gKrvqaqVB0aHmNoHS6GSsMarUU5k7wh5xtNEHay3eKWp8BttHmYHmPqwjtGix3CkX)NTwyNKla7q(HFBAkKvbKTQsdzVbzufea07gnqiJuiJMeanD3obK9gKzVeVjqU4qtOsa0fdaMEHFwljKjfYezWTLSjHF43MMczsHmrg8sEhHsmzZp8BttHmPqMeqMidoDu2ZwdgvKF43MMczoDcz1bzHbWo40rzpBnyuro2Mlafqg5E52(Ox2EjD3oJQvZo0PQwjxJNp81UPFdVm2Mlaf(T9YLBc8gZllbKfga7GlStsnnja6)qXJeo2MlafqMuiRKjqKRBoL4)ZwlStYfGDiNqbYKczLmbICDZf2jPMMeaoHcKroK50jKvYeiY1nNs8)zRf2j5cWoKtOazoDczX8rDKAXGqwfq2MK5LTsmz7LvYyY2h(ARC)gEzSnxak8B7Ll3e4nMxUKjqKRBoL4)ZwlStYfGDi)WVnnfYCaYQuKbzoDczX8rDKAXGqwfq2RKbzoDczsazIm4ennmxaQnvvWuIjBEmfjNEbYKcz0KaOP72jGShiJmitkKjbKvhKfga7GRSBDKFnD6fcGDtqchBZfGciZPtiRKjqKRBUYU1r(10Pxia2nbj8d)20uiJCitkKjbKvhKPuvjma2bxGwS7MGGJT5cqbK50jKvYeiY1nxGwS7MGGF43MMczv8azlfbK50jKvhKvYeiY1nxGwS7MGGF43MMczKdzsHS6GSsMarUU5uI)pBTWojxa2H8d)20uiJCVSvIjBVmbf1tGFQp81wVFdVm2Mlaf(T9YLBc8gZlxhKvYeiY1nNs8)zRf2j5cWoKtO4LTsmz7LvNdDbzk8HV233VHxgBZfGc)2E5YnbEJ5LRdYkzce56Mtj()S1c7KCbyhYju8YwjMS9YUGmfAvIJeF4RTs53WlJT5cqHFBVC5MaVX8YX8riZbiBtY8YwjMS9YF8Nhj6uvdikJqlo0(uF4R998B4LX2CbOWVTxUCtG3yE5y(OosTyqiRci7vYGmsHSLIaYC6eYcdGDWP5ADSJAkIckhBZfGcitkKvYeiY1nNs8)zRf2j5cWoKF43MMczo8azLmbICDZPe)F2AHDsUaSd5cIZIjBiRsGSvK5LTsmz7Lf2jPMMeaF4RTs73WlJT5cqHFBVC5MaVX8YkyWf2j5cWoKF43MMczoDczsaz1bzLmbICDZfOf7Uji4h(TPPqMtNqwDqMsvLWayhCbAXUBcco2Mlafqg5qMuiRKjqKRBoL4)ZwlStYfGDi)WVnnfYC4bYEpYGmPqgsPyxqUlitHov1XoQXg)KWpRLeYCaYw5LTsmz7LDbzk0PQo2rn24NeF4RDfz(n8YyBUau432lBLyY2lRKfjXGoVef6s(viclMS1cS6uqVC5MaVX8YsazLmbICDZPe)F2AHDsUaSd5h(TPPqMdpq2R1dzoDczX8rDKAXGqwfpq2MKbzKdzsHmjGSsMarUU5c0ID3ee8d)20uiZPtiRoitPQsyaSdUaTy3nbbhBZfGciJCVCBF0lRKfjXGoVef6s(viclMS1cS6uqF4RD1k)gEzSnxak8B7LTsmz7LVmkhbnqHUAMIm1Iea8YLBc8gZllbKvYeiY1nNs8)zRf2j5cWoKF43MMczo8azVwpK50jKfZh1rQfdczv8azBsgKroKjfYKaYkzce56Mlql2DtqWp8BttHmNoHS6GmLQkHbWo4c0ID3eeCSnxakGmY9YT9rV8Lr5iObk0vZuKPwKaGp81U6v)gEzSnxak8B7LTsmz7LP7tv80vXo)6dbtXlxUjWBmVSeqwjtGix3CkX)NTwyNKla7q(HFBAkK5WdK9A9qMtNqwmFuhPwmiKvXdKTjzqg5qMuitciRKjqKRBUaTy3nbb)WVnnfYC6eYQdYuQQega7Glql2DtqWX2CbOaYi3l32h9Y09PkE6QyNF9HGP4dFTR20VHxgBZfGc)2EzRet2EzRYsmkzGDOBJigab1lxUjWBmVSeqwjtGix3CkX)NTwyNKla7q(HFBAkK5WdK9A9qMtNqwmFuhPwmiKvXdKTjzqg5qMuitciRKjqKRBUaTy3nbb)WVnnfYC6eYQdYuQQega7Glql2DtqWX2CbOaYi3l32h9YwLLyuYa7q3grmacQp81UQY9B4LX2CbOWVTx2kXKTxogbsJ8(6skWxGxUCtG3yEzjGSsMarUU5uI)pBTWojxa2H8d)20uiZHhi716HmNoHSy(OosTyqiRIhiBtYGmYHmPqMeqwjtGix3CbAXUBcc(HFBAkK50jKvhKPuvjma2bxGwS7MGGJT5cqbKrUxUTp6LJrG0iVVUKc8f4dFTRQ3VHxgBZfGc)2EzRet2E5QJb0PQMg59PE5YnbEJ5LLaYkzce56Mtj()S1c7KCbyhYp8BttHmhEGSxRhYC6eYI5J6i1IbHSkEGSnjdYihYKczsazLmbICDZfOf7Uji4h(TPPqMtNqwDqMsvLWayhCbAXUBcco2Mlafqg5E52(OxU6yaDQQPrEFQp81U699B4LTsmz7LVrrbG6P1ufRGEzSnxak8B7dFTRQu(n8YyBUau432lxUjWBmVCv7gZfGCrgunHIx2kXKTxMwsIB6fDmXo6dFTREp)gEzSnxak8B7Ll3e4nMxUQDJ5cqUidQMqXlBLyY2lpFfSftVOlwy04sLD0h(AxvP9B4LX2CbOWVTxUCtG3yEzjGmxcvv(0y1jmxaQf4FOiNgwrsiZbiBZ3dYC6eYSsmvrn24FqkK5aKTcYihYKczvTBmxaYfzq1ekEzRet2EzAsa0xg(Wx7RK53WlJT5cqHFBVC5MaVX8YvTBmxaYfzq1ekqMuitcilSBbd(oAGyxRuciRciREYGmNoHm1zzp0h(TPPqMdqw9KbzK7LTsmz7Lfyz(wm9I2nbHp8HxwKb1VHV2v(n8YyBUau432lxUjWBmVSidEjVJqjMS5h(TPPqwfpqMvIjBofrHov1L8ocLyYMxmAOJ5JqgPqwmFuhPMUBNaYifYQC(Rq2BqMeq2kiRsGSWayh8YHOY0lAbAXohBZfGci7niJm(Q6HmYHmPqgvbbaDy3cguofrHov1L8ocLyYwBjczo8azBczKczNncnwf7GpDvcqJN5cqoHcKrkKfga7GV(Myh1tRTLSjHJT5cqbKjfYQdYezWPik0PQUK3rOet28d)20uitkKvhKzLyYMtruOtvDjVJqjMS5tRvbZYE4LTsmz7LPik0PQUK3rOet2(Wx7R(n8YyBUau432lBLyY2lBlztIxUCtG3yE5Wayh8YHOY0lAbAXohBZfGcitkKzLyQIArgCBjBsGSkGS3hYKczX8rDKAXGqMdq2kYGmPqMeq2HFBAkKvXdKTueqMtNqwjtGix3CkX)NTwyNKla7q(HFBAkK5aKTImitkKjbKD43MMczvaz1dzoDcz1bz2lXBcKRyTa)trpD1SyXKn)SwsitkKDO6H0DZfGqg5qg5E5cjfaQd7wWG6RDLp81UPFdVm2Mlaf(T9YwjMS9Y2s2K4Ll3e4nMxUoilma2bVCiQm9IwGwSZX2CbOaYKczwjMQOwKb3wYMeiRci79GmPqwmFuhPwmiK5aKTImitkKjbKD43MMczv8azlfbK50jKvYeiY1nNs8)zRf2j5cWoKF43MMczoazRidYKczsazh(TPPqwfqw9qMtNqwDqM9s8Ma5kwlW)u0txnlwmzZpRLeYKczhQEiD3CbiKroKrUxUqsbG6WUfmO(Ax5dFTvUFdVm2Mlaf(T9YwjMS9Y0rzpBnyurVC5MaVX8YsazwjMQOwKbNok7zRbJkczvazVhKvjqwyaSdE5quz6fTaTyNJT5cqbKvjqgvbbaDy3cguonxRJDutruq1wIqg5qMuilMpQJulgeYCaYwrgKjfYou9q6U5cqitkKjbKvhKD43MMczsHmQcca6WUfmOCkIcDQQl5DekXKT2seYEGSvqMtNqwjtGix3CkX)NTwyNKla7q(HFBAkK5aKrtcGMUBNaYEdYSsmzZjAAyUauBQQGPet2C8fGfIa1X8riJCVCHKca1HDlyq91UYh(AR3VHxgBZfGc)2EzRet2E5sEhHsmz7Ll3e4nMxMQGaGoSBbdkNIOqNQ6sEhHsmzRTeHSkGSnHmsHSZgHgRIDWNUkbOXZCbiNqbYifYcdGDWxFtSJ6P12s2KWX2CbOaYKczsazh(TPPqwfpq2srazoDczLmbICDZPe)F2AHDsUaSd5h(TPPqMdq2kYGmPq2HQhs3nxaczKdzsHSWUfm4X8rDKAXGqMdq2kY8Yfskauh2TGb1x7kF4R999B4LX2CbOWVTxUCtG3yEzRetvulYGt00WCbO2uvbtjMSHShiJmiZPtitcitKbNOPH5cqTPQcMsmzZjuGmPq2HQhs3nxaczK7LTsmz7LjAAyUauBQQGPet2(WhEz1baWJ63Wx7k)gEzSnxak8B7LTsmz7LjAAyUauBQQGPet2E5YnbEJ5Llzce56Mlql2DtqWp8BttHSkEGSLIaYEdYEfYKczufea0HDlyq5uef6uvxY7iuIjBTLiK9azRGmsHSZgHgRIDWNUkbOXZCbiNqbYKczLmbICDZPe)F2AHDsUaSd5h(TPPqMdq2RK5LbtJ6IWlVQEF4R9v)gEzSnxak8B7Ll3e4nMxwPQsyaSdUaTy3nbbhBZfGcitkKrvqaqh2TGbLtruOtvDjVJqjMS1wIq2dKTcYifYoBeASk2bF6QeGgpZfGCcfitkKjbKjYGBlztc)WVnnfYQaYezWTLSjHliolMSHS3GmY4vQ6HmNoHmrg8sEhHsmzZp8BttHSkGmrg8sEhHsmzZfeNft2q2Bqgz8kv9qMtNqMidoDu2ZwdgvKF43MMczvazIm40rzpBnyurUG4SyYgYEdYiJxPQhYihYKczLmbICDZfOf7Uji4h(TPPqwfpqMvIjBUTKnj8LIaYEdYQCitkKvYeiY1nNs8)zRf2j5cWoKF43MMczoazVsMx2kXKTxUyaG2kXKTgm0WldgAOB7JEzHR(q1dP7(Wx7M(n8YyBUau432lxUjWBmVSsvLWayhCbAXUBcco2MlafqMuiJQGaGoSBbdkNIOqNQ6sEhHsmzRTeHShiBfKrkKD2i0yvSd(0vjanEMla5ekqMuiRKjqKRBoL4)ZwlStYfGDi)WVnnfYQ4bYOjbqt3TtazVbzwjMS52s2KWxkciJuiZkXKn3wYMe(srazVbzBczsHmjGmrgCBjBs4h(TPPqwfqMidUTKnjCbXzXKnK9gKTcYC6eYezWl5DekXKn)WVnnfYQaYezWl5DekXKnxqCwmzdzVbzRGmNoHmrgC6OSNTgmQi)WVnnfYQaYezWPJYE2AWOICbXzXKnK9gKTcYi3lBLyY2lxmaqBLyYwdgA4Lbdn0T9rVSWvFO6H0DF4RTY9B4LX2CbOWVTxUCtG3yE5Q2nMla5ImOAcfitkKjbKvYeiY1nNs8)zRf2j5cWoKF43MMczo8azBsgKrkKTueqMtNqwjtGix3CkX)NTwyNKla7q(HFBAkK5aKzLyYMtj()S1c7KCbyhYlzce56gYQei7vYGmY9YwjMS9Yc0ID3ee(WxB9(n8YyBUau432lxUjWBmVSlHQk)NvXp2bNqbYKczUeQQ8Ew2dvda4h(TPPEzRet2Ez6UjY1A3ee(Wx7773WlJT5cqHFBVC5MaVX8YUeQQ8Fwf)yhCcfitkKvhKjbKfga7GthL9S1Grf5yBUauazsHmjGmLdRQxkc(kUTKnjqMuit5WQ6LIG)k3wYMeitkKPCyv9srW3KBlztcKroK50jKPCyv9srWxXTLSjbYi3lBLyY2lBlztIp81wP8B4LX2CbOWVTxUCtG3yEzxcvv(pRIFSdoHcKjfYQdYKaYuoSQEPi4R40rzpBnyuritkKPCyv9srWFLthL9S1GrfHmPqMYHv1lfbFtoDu2ZwdgveYi3lBLyY2lthL9S1Grf9HV23ZVHxgBZfGc)2E5YnbEJ5LDjuv5)Sk(Xo4ekqMuiRoit5WQ6LIGVIxY7iuIjBitkKvhKfga7GBU0eqeOUK3rOet2CSnxak8YwjMS9YL8ocLyY2h(AR0(n8YyBUau432lBLyY2lt00WCbO2uvbtjMS9YwjMQOwKbNOPH5cqTPQcMsmz7LjZPtjezWjAAyUauBQQGPet2CcfPhQEiD3Cbi5(Wx7kY8B4LX2CbOWVTxUCtG3yEzxcvv(0y1jmxaQf4FOiNgwrsiZbiBfzqMuilMpQJulgeYQ4bYwrMx2kXKTxwC20AWOI(Wx7Qv(n8YyBUau432lxUjWBmVCyaSdoDu2ZwdgvKJT5cqbKjfYCjuv5tJvNWCbOwG)HICAyfjHmhEGS6jdYQei7vYGS3GmjGmQcca6WUfmOCkIcDQQl5DekXKT2seYQei7SrOXQyh8PRsaA8mxaYjuGmhEGSxHmYHmPqMidUTKnj8d)20uiZbiREi7niJQGaGE3ObczsHmrg8sEhHsmzZp8BttHmhGSLIaYKczsazIm40rzpBnyur(HFBAkK5aKTueqMtNqwDqwyaSdoDu2ZwdgvKJT5cqbKroKjfYKaYeOlHQkF3i6GF43MMczoaz1dzVbzufea07gnqiZPtiRoilma2bF3i6GJT5cqbKroKjfYkzh2YKnK5aKvpK9gKrvqaqVB0a9YwjMS9YIZMwdgv0h(Ax9QFdVm2Mlaf(T9YLBc8gZlhga7GV(Myh1tRTLSjHJT5cqbKjfYCjuv5tJvNWCbOwG)HICAyfjHmhEGS6jdYQei7vYGS3GmjGmQcca6WUfmOCkIcDQQl5DekXKT2seYQei7SrOXQyh8PRsaA8mxaYjuGmhEGSnHmYHSkbYQhYEdYKaYOkiaOd7wWGYPik0PQUK3rOet2AlriRsGSZgHgRIDWNUkbOXZCbiNqbYEGSxHmYHmPqMidUTKnj8d)20uiZbiREi7niJQGaGE3ObczsHmrg8sEhHsmzZp8BttHmhGSLIaYKczsazc0LqvLVBeDWp8BttHmhGS6HS3GmQcca6DJgiK50jKvhKfga7GVBeDWX2CbOaYihYKczLSdBzYgYCaYQhYEdYOkiaO3nAGEzRet2EzXztRbJk6dFTR20VHxgBZfGc)2E5YnbEJ5LddGDWnxAcicuxY7iuIjBo2MlafqMuiZLqvLpnwDcZfGAb(hkYPHvKeYC4bYQNmiRsGSxjdYEdYKaYOkiaOd7wWGYPik0PQUK3rOet2AlriRsGSZgHgRIDWNUkbOXZCbiNqbYC4bYQCiJCitkKjYGBlztc)WVnnfYCaYQhYEdYOkiaO3nAGqMuitcitGUeQQ8DJOd(HFBAkK5aKvpK9gKrvqaqVB0aHmNoHS6GSWayh8DJOdo2Mlafqg5qMuiRKDylt2qMdqw9q2Bqgvbba9Urd0lBLyY2lloBAnyurF4RDvL73WlJT5cqHFBVC5MaVX8YUeQQ8PXQtyUaulW)qronSIKqMdq2RKbzsHmRetvulYGttcG(YaYCaYidYC6eYCjuv5tJvNWCbOwG)HICAyfjHmhGSkNmVSvIjBVS4SP1Grf9HV2v173WlBLyY2lVBeD4LX2CbOWVTp81U699B4LTsmz7LvZcbffA7L4nbQDr77LX2CbOWVTp81UQs53WlBLyY2lRqCJkjtVODbgn8YyBUau432h(Ax9E(n8YyBUau432lxUjWBmVCDqMidEj7c2Xzbk0Qa7JAxIR5h(TPPqMuiRoiZkXKnVKDb74SafAvG9r(0AvWSShEzRet2E5s2fSJZcuOvb2h9HV2vvA)gEzSnxak8B7LTsmz7LfNnTMMeaVCHKca1HDlyq91UYlpDG3rOeE5vE5YnbEJ5LJ5J6i1IbHSkEGSLIWlx2TP9YR8Yth4DekHEbKUgWlVYh(AFLm)gEzSnxak8B7LTsmz7LfNnTMMeaVCHKca1HDlyq91UYlpDG3rOe6r1lhtrsQ(WVnDf17Ll3e4nMxUQDJ5cq(3MoSP1ueYKcz1bzc0LqvLt3nrUwJF3Zki)WVnn1lx2TP9YR8Yth4DekHEbKUgWlVYh(AFDLFdVm2Mlaf(T9YwjMS9YIZMwttcGxUqsbG6WUfmO(Ax5LNoW7iuc9O6LJPijvF43MUI69YLBc8gZlx1UXCbi)Bth20Ak6Ll720E5vE5Pd8ocLqVasxd4Lx5dFTV(QFdVm2Mlaf(T9YwjMS9YIZMwttcGxE6aVJqj8YR8YLDBAV8kV80bEhHsOxaPRb8YR8HV2x30VHxgBZfGc)2EzRet2Ez6UjY1A3eeE5YnbEJ5LRA3yUaK)TPdBAnfHmPqwDqMaDjuv50DtKR1439ScYp8BttHmPqwDqMvIjBoD3e5ATBcc(0AvWSShE5cjfaQd7wWG6RDLp81(AL73WlJT5cqHFBVSvIjBVmD3e5ATBccVC5MaVX8YvTBmxaY)20HnTMIE5cjfaQd7wWG6RDLp81(A9(n8YwjMS9Y0DtKR1Uji8YyBUau432h(WltvWwGh1VHV2v(n8YyBUau432lxUjWBmVCv7gZfGCrgunHIx2kXKTx(BauDk6ZucId9HV2x9B4LX2CbOWVTxUCtG3yE5Q2nMla5euutru4LTsmz7LPik0PQUK3rOet2(Wh(Wh(W7b]] )


end