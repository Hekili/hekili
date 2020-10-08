-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


-- Conduits
-- [-] cold_embrace
-- [-] corrupting_leer
-- [-] focused_malignancy
-- [x] rolling_agony

-- Covenants
-- [x] soul_tithe
-- [x] catastrophic_origin
-- [-] prolonged_decimation
-- [-] soul_eater

-- Endurance
-- [x] accrued_vitality
-- [-] diabolic_bloodstone
-- [-] resolute_barrier

-- Finesse
-- [x] demonic_momentum
-- [x] fel_celerity
-- [-] shade_of_terror


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
            duration = function () return ( 18 + conduit.rolling_agony.mod * 0.001 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
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


        -- Conduit
        diabolic_bloodstone = {
            id = 340563,
            duration = 8,
            max_stack = 1
        }
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

            -- Conduit in WarlockDemonology.lua
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

            finish = function ()
                if conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
            end,

            auras = {
                -- Conduit
                accrued_vitality = {
                    id = 339298,
                    duration = 10,
                    max_stack = 1
                }
            }
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
            cooldown = function () return 180 + conduit.fel_celerity.mod * 0.001 end,
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
                -- Conduit
                soul_tithe = {
                    id = 340238,
                    duration = 10,
                    max_stack = 1
                }
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

            spend = 0.005,
            spendType = "mana",

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
                    duration = function () return 12 * ( 1 + conduit.catastrophic_origin.mod * 0.01 ) end,
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


    spec:RegisterPack( "Affliction", 20200910.1, [[dCeVfcqiLGhPkPCjvjPnrK(KQKigfr4uiQwLQu9kePzrf6wsIyxO6xkfnmeLJjPAzQs8mLsMMKO6Akf2MQKQVjjsnovPuNtsKSovjrAEsc3tvSpQGdkjkSqLs9qvPeMOQusxusuKoPQuISsjfZuvkrDtjrrzNskTuvjr9uIAQkHUQKOO6RsIIyVu1Fj1Gr5Wuwmv6XsmzcxgAZK0NvsJwP60kEnr0SbUTQA3s9BrdNehxsuA5Q8CKMUW1ry7ssFxjA8QscNhrSEvPy(ur7h0(6(f9YclqFTVq2lKrwLQoz86VE9x2Qs5LdsuqVSIvK0wrVCBF0lxzOQcMsmz7LvmsaPj8l6LPjXvqV8Eek0xPBU56e7eU8s(3KoFcGft2LZuJnPZVSPx2LyaXBP276LfwG(AFHSxiJSkvDY41F96VS1R7LPkyXx7lV(gE59riW276LfiT4LFniRYqvfmLyYgYQmXoqwKewZRbzYOsGFx8GS6K5iK9czVqgSgynVgK9wSB9ksFLcR51GSkbYQmecuazYkiaazVLZIKCynVgKvjqwLHqGci7TIvtIdYQmZwNchwZRbzvcK9kJ)SkkGSWUvm0JkNZH18AqwLazVYyLLyoeYER5IuiJqbYYgYc7wXaYuZdYEROf7UjiGmjOtxqi7q1dP7qgixNcKnuitmQQ4HDazJkK9w8wPqMDiKjgQ5cqb5CynVgKvjq2RmQaScczuSkEgaYc7wXGhZh1rQfdczfJIuiB5e7qwmFuhPwmiKjb2cilvHmSljrh4ro3lRCP6aqV8RbzvgQQGPet2qwLj2bYIKWAEnitgvc87IhKvNmhHSxi7fYG1aR51GS3IDRxr6RuynVgKvjqwLHqGcitwbbai7TCwKKdR51GSkbYQmecuazVvSAsCqwLz26u4WAEniRsGSxz8NvrbKf2TIHEu5CoSMxdYQei7vgRSeZHq2BnxKczekqw2qwy3kgqMAEq2BfTy3nbbKjbD6cczhQEiDhYa56uGSHczIrvfpSdiBuHS3I3kfYSdHmXqnxakiNdR51GSkbYELrfGvqiJIvXZaqwy3kg8y(OosTyqiRyuKczlNyhYI5J6i1IbHmjWwazPkKHDjj6apY5WAG18AqwLPVcSqeOaYCr18qiRKFxlGmxCDAkhYQmkfujOqwNDLSB3xLaazwjMSPqw2as4WAEniZkXKnLRCyj)Uw8OcmQKWAEniZkXKnLRCyj)Uwq6ZMQzkG18AqMvIjBkx5Ws(DTG0NnnI1p2Hft2WASsmzt5khwYVRfK(SjL4)ZwRGbSgRet2uUYHL87AbPpBUEZpNd1PQMALBuNc64O(ega7GVEZpNd1PQMALBuNcYX2CbOawZRbzwjMSPCLdl531csF2K2McDpdnnSGcRXkXKnLRCyj)Uwq6ZMkzmzdRXkXKnLRCyj)Uwq6ZMeuupb(DSTp(yVHUBNr1Qzh6uvRKlXdwJvIjBkx5Ws(DTG0NnPik0PQUK3rOet2ooQpufea0HDRyq5uef6uvxY7iuIjBTLOdpBjDbSYsmkkOGx)1RuBvVYH1yLyYMYvoSKFxli9zZDJOdynwjMSPCLdl531csF2KUBICP2nbHJJ6ZcHbWo47grhCSnxakKsvqaqh2TIbLtruOtvDjVJqjMS1wIvSL0fWklXOOGcE9xVsTv9khwdSMxdYQm9vGfIafqgwfpsGSy(iKf7iKzLipiBOqMv1gG5cqoSgRet20hQccaAqwKewJvIjBkPpBkWQjXP)26uG1yLyYMs6ZM0DtKl1UjiCCuFCjuv50DtKl1439ScYjuK6sOQYP7MixQXV7zfKF43MMwrXOHoMpsACwveOJ5JWASsmztj9zZQ2nMlaDSTp(qqrnfrHJvnab(ega7GtZL6yh1uefuo2MlafsPkiaOd7wXGYPik0PQUK3rOet2AlrhE2I0ZgHgRIDWNUkbOXZCbiNqXPZWayhC6OSNTgmQihBZfGcPufea0HDRyq5uef6uvxY7iuIjBhE2G0ZgHgRIDWNUkbOXZCbiNqXPtQcca6WUvmOCkIcDQQl5DekXKTdpVnPNncnwf7GpDvcqJN5cqoHcSgRet2usF2SQDJ5cqhB7JpkMqm9QJPYdfdhRAac8XkXKnNUBICP2nbbhFfyHiqDmF8D7n4nbYlgTyIPx1fdy)jiHJT5cqbSgRet2usF2SQDJ5cqhB7JpkMqm9QJPYZHumCSQbiWN1IWXr9XEdEtG8IrlMy6vDXa2Fcs4yBUauivIWayhCXztRPjbGJT5cqHtNkvvcdGDWfOf7Uji4yBUauiTKjqKlBUaTy3nbb)WVnnTIN1IGCynwjMSPK(Szv7gZfGo22hF(20HnTMIow1ae4dvbbaDy3kguofrHov1L8ocLyYwBjwXtDsddGDWxEtSJ6P12A2KWX2CbOG0WayhCZLMaIa1L8ocLyYMJT5cqX7VqQeHbWo4lVj2r90ABnBs4yBUauinma2bNMl1XoQPikOCSnxakKsvqaqh2TIbLtruOtvDjVJqjMS1wIo8c5KkryaSdoDu2ZwdgvKJT5cqH0fcdGDWlhIktVQfOf7CSnxakKUqyaSdU4SP10KaWX2CbOGCspBeASk2bF6QeGgpZfGCcfynwjMSPK(Szv7gZfGo22hFezq1ekow1ae4Jelega7GthL9S1Grf5yBUau40PidoDu2ZwdgvKtOqUurgCBnBs40Wks6WtDYKUGidUTMnj8dvpKUBUauQidEjVJqjMS5eksfzWjAAyUauBQQGPet2CcfynwjMSPK(SzXaaTvIjBnyOHJT9XNsMarUSPWASsmztj9ztXztRPjbWXPd8ocLqVcsxd8u3XYUn9tDhlKuaOoSBfd6tDhh1Ny(OosTyWkEwlcP0KaOP72jQydynwjMSPK(S5Ur0HJJ6dvbbaDy3kguofrHov1L8ocLyYwBjwXZlKE2i0yvSd(0vjanEMla5ekWASsmztj9ztkX)NTwyNKRa7qhh1NQ2nMla5ImOAcfPIm4ennmxaQnvvWuIjB(HFBAQdfJg6y(OujwOKvX26Gxf7yNKZPtrg85RGTy6vDXcJgxQSJ8ykso9k5sLyHWayhCLDRJ8RPtVsaSBcs4yBUau40zjtGix2CLDRJ8RPtVsaSBcs4h(TPPKlvIfuQQega7Glql2DtqWX2CbOWPZsMarUS5c0ID3ee8d)200kEwlcNoxOKjqKlBUaTy3nbb)WVnn1PtAsa00D7epKjLQGaGoSBfdkNIOqNQ6sEhHsmzRTeDOoPNncnwf7GpDvcqJN5cqoHc5WASsmztj9ztbAXUBcchh1NsMarUS5uI)pBTWojxb2H8d)20uPvTBmxaYfzq1eksPkiaOd7wXGYPik0PQUK3rOet2AlXN6KE2i0yvSd(0vjanEMla5eksLybKsXUG8QdDYwNQAf8uXsmzZ)tNN0fS3G3eixCOjuja6IbatVYpRL0PZsMarUS5uI)pBTWojxb2H8d)20uh2ImYH1yLyYMs6ZMXoQjA3KOfA18kOJJ6JlHQk)WIKaKs1Q5vq(HFBAkSgRet2usF20wZMehlKuaOoSBfd6tDhh1Nd)200kEwlcsTsmzZP7MixQDtqWXxbwicuhZhLgZh1rQfd6WBdRXkXKnL0Nn)4pps0PQgqugHwCO9PooQpX8Xk2ImynVgKTi(vYZosGm15vazrczFtseYOehcz2BO72zVsOqMA2bKjsK2VsciZ9qtsityNKRa7qiJGARihwJvIjBkPpBARztIJGPrDr8SfzooQpX8rh2ImPLmbICzZPe)F2AHDsUcSd5h(TPPv8uFdPyLLyuuqbV(RxP2QELdRXkXKnL0Nnl5DekXKTJGPrDr8SfzooQpX8rh2ImPLmbICzZPe)F2AHDsUcSd5h(TPPv8uFdPyLLyuuqbV(RxP2QELlDHWayhCZLMaIa1L8ocLyYMJT5cqHujcdGDWPJYE2AWOICSnxakC6KQGaGoSBfdkNIOqNQ6sEhHsmzRTeDOUuQcca6WUvmOCkIcDQQl5DekXKT2sSINTihwJvIjBkPpBshL9S1GrfDemnQlINTiZXr9jMp6WwKjTKjqKlBoL4)ZwlStYvGDi)WVnnTIN6BifRSeJIck41F9k1w1RCynwjMSPK(SjrtdZfGAtvfmLyY2Xr9XkXuf1Im4ennmxaQnvvWuIj7hYC6ucrgCIMgMla1MQkykXKnNqr6HQhs3nxasoSgRet2usF2uC20AAsaCSqsbG6WUvmOp1DSyDbb6r9jMIKu9HFB6k2WXr9PQDJ5cq(3MoSP1uuQaDjuv50DtKl1439ScYp8BttLkqxcvvoD3e5sn(DpRG8d)200kEwlI3FbwJvIjBkPpBs3nrUu7MGWXcjfaQd7wXG(u3Xr9PQDJ5cq(3MoSP1uuQaDjuv50DtKl1439ScYp8BttLkqxcvvoD3e5sn(DpRG8d)200kEWxbwicuhZhF)fsJZQIaDmFu6cwjMS50DtKl1Uji4tRvbZ6EaRXkXKnL0Nnv2ToYVMo9kbWUjiXXcjfaQd7wXG(u3Xr9jMp6WwBinSBfdEmFuhPwmOd1F93PkiaO3nAGsLybKsXUG8QdDYwNQAf8uXsmzZ)tNN0fS3G3eixCOjuja6IbatVYpRL0PZsMarUS5uI)pBTWojxb2H8d)20uhQ8niLMeanD3oX72BWBcKlo0eQeaDXaGPx5N1s60zjtGix2CkX)NTwyNKRa7q(HFBAAf134DQcca6DJgiP0KaOP72jE3EdEtGCXHMqLaOlgam9k)SwsYH1yLyYMs6ZMuef6uvxY7iuIjBhh1NQ2nMla5euutruiLMeanD3oXZgWASsmztj9zZIbaARet2AWqdhB7JpImOWASsmztj9zZQda1HnD4yHKca1HDRyqFQ74O(eZhDO(gsJ5J6i1IbD4PozsLOKjqKlBoL4)ZwlStYvGDi)WVnn1HTiZPZsMarUS5uI)pBTWojxb2H8d)200kQtMurgCBnBs4h(TPPo8uNmPIm4L8ocLyYMF43MM6WtDYKkHidoDu2ZwdgvKF43MM6WtDYC6CHWayhC6OSNTgmQihBZfGcYjhwJvIjBkPpBsqr9e43X2(4J9g6UDgvRMDOtvTsUephh1Ny(yfpBbRXkXKnL0Nnv2ToYVMo9kbWUjiXXr9jMpwXZwBaRXkXKnL0NnRoauh20HJJ6tmFSI6BaRXkXKnL0NnxjStmwRtvT9g8Yy3Xr9rIsMarUS5uI)pBTWojxb2H8d)200kQVbP0KaOP72jE3EdEtGCXHMqLaOlgam9khBZfGcNoLWEdEtGCXHMqLaOlgam9k)SwsNorkf7cYRo0jBDQQvWtflXKn)SwsYLgZhDylYKgZh1rQfd6WZl1jJCPsiYGRSBDKFnD6vcGDtqc)WVnn1Ptrg8Qda1HnDWp8BttD6CHWayhCLDRJ8RPtVsaSBcs4yBUauiDHWayh8Qda1HnDWX2CbOGCNoJ5J6i1IbRylYiDTiG1yLyYMs6ZMc7KuttcGJJ6tjtGix2CkX)NTwyNKRa7q(HFBAAf13GuAsa00D7eVBVbVjqU4qtOsa0fdaMELJT5cqHujezWv2ToYVMo9kbWUjiHF43MM60PidE1bG6WMo4h(TPPKdRXkXKnL0NnDXJINKtVcRXkXKnL0NnlgaOTsmzRbdnCSTp(qvWwGhfwJvIjBkPpBwmaqBLyYwdgA4yBF8rDaa8OWAG1yLyYMYlzce5YM(SmpGOkoT(qA2wxqynwjMSP8sMarUSPK(Sjbf1tGFhB7Jp2BO72zuTA2Hov1k5s8CCuFKyHWayhCLDRJ8RPtVsaSBcs4yBUau40zjtGix2CLDRJ8RPtVsaSBcs4h(TPPvu5VtvqaqVB0aD6CHsMarUS5k7wh5xtNELay3eKWp8BttjxAjtGix2CkX)NTwyNKRa7q(HFBAAf1RuVtvqaqVB0ajLMeanD3oX72BWBcKlo0eQeaDXaGPx5N1skvKb3wZMe(HFBAQurg8sEhHsmzZp8BttLkHidoDu2ZwdgvKF43MM605cHbWo40rzpBnyuro2MlafKdRXkXKnLxYeiYLnL0NnvYyY2Xr9rIWayhCHDsQPjbq)hkEKWX2CbOqAjtGix2CkX)NTwyNKRa7qoHI0sMarUS5c7KuttcaNqHCNolzce5YMtj()S1c7KCfyhYjuC6mMpQJulgSITidwJvIjBkVKjqKlBkPpBsqr9e4N64O(uYeiYLnNs8)zRf2j5kWoKF43MM6qLMmNoJ5J6i1IbR4fYC6ucrgCIMgMla1MQkykXKnpMIKtVkLMeanD3oXdzsLyHWayhCLDRJ8RPtVsaSBcs4yBUau40zjtGix2CLDRJ8RPtVsaSBcs4h(TPPKlvIfuQQega7Glql2DtqWX2CbOWPZsMarUS5c0ID3ee8d)200kEwlcNoxOKjqKlBUaTy3nbb)WVnnLCPluYeiYLnNs8)zRf2j5kWoKF43MMsoSgRet2uEjtGix2usF2uDo0fKPWXr9zHsMarUS5uI)pBTWojxb2HCcfynwjMSP8sMarUSPK(SPlitHwL4iXXr9zHsMarUS5uI)pBTWojxb2HCcfynwjMSP8sMarUSPK(S5h)5rIov1aIYi0IdTp1Xr9jMp6WwKbRXkXKnLxYeiYLnL0Nnf2jPMMeahh1Ny(OosTyWkEHmsxlcNoddGDWP5sDSJAkIckhBZfGcPLmbICzZPe)F2AHDsUcSd5h(TPPo8uYeiYLnNs8)zRf2j5kWoKliolMSRK6KbRXkXKnLxYeiYLnL0NnDbzk0PQo2rn24Nehh1hfm4c7KCfyhYp8BttD6uIfkzce5YMlql2DtqWp8BttD6CbLQkHbWo4c0ID3eeCSnxakixAjtGix2CkX)NTwyNKRa7q(HFBAQdpVnzsrkf7cYDbzk0PQo2rn24Ne(zTKouhwZRbzvMtrityFBD6vil7kHGIqwCtljgui7Nhcz5bzaKsHSSHSsMarUSDeYOjKbYEfYmkKf7iK9w6T4TczXoscKnDH4GSLz)kjGmuvflbKznjqwg74bzXnTKyqHmcQTIqMG4MEfYkzce5YMYH1yLyYMYlzce5YMs6ZMeuupb(DSTp(OKfjXGoVbf6s(viclMS1cS6uqhh1hjkzce5YMtj()S1c7KCfyhYp8BttD45LnC6mMpQJulgSINTiJCPsuYeiYLnxGwS7MGGF43MM605ckvvcdGDWfOf7Uji4yBUauqoSgRet2uEjtGix2usF2KGI6jWVJT9XNlJYrqduORMPitTibahh1hjkzce5YMtj()S1c7KCfyhYp8BttD45LnC6mMpQJulgSINTiJCPsuYeiYLnxGwS7MGGF43MM605ckvvcdGDWfOf7Uji4yBUauqoSgRet2uEjtGix2usF2KGI6jWVJT9Xh6(ufpDvSZV(qWuCCuFKOKjqKlBoL4)ZwlStYvGDi)WVnn1HNx2WPZy(OosTyWkE2ImYLkrjtGix2CbAXUBcc(HFBAQtNlOuvjma2bxGwS7MGGJT5cqb5WASsmzt5LmbICztj9ztckQNa)o22hFSklXOKb2HUnIyaeuhh1hjkzce5YMtj()S1c7KCfyhYp8BttD45LnC6mMpQJulgSINTiJCPsuYeiYLnxGwS7MGGF43MM605ckvvcdGDWfOf7Uji4yBUauqoSgRet2uEjtGix2usF2KGI6jWVJT9XNyeinY7RlPaFfooQpsuYeiYLnNs8)zRf2j5kWoKF43MM6WZlB40zmFuhPwmyfpBrg5sLOKjqKlBUaTy3nbb)WVnn1PZfuQQega7Glql2DtqWX2CbOGCynwjMSP8sMarUSPK(Sjbf1tGFhB7JpvhdOtvnnY7tDCuFKOKjqKlBoL4)ZwlStYvGDi)WVnn1HNx2WPZy(OosTyWkE2ImYLkrjtGix2CbAXUBcc(HFBAQtNlOuvjma2bxGwS7MGGJT5cqb5WASsmzt5LmbICztj9zZBuuaOEAnvXkiSgRet2uEjtGix2usF2KwsIB6vDmXo64O(u1UXCbixKbvtOaRXkXKnLxYeiYLnL0NnNVc2IPx1flmACPYo64O(u1UXCbixKbvtOaRXkXKnLxYeiYLnL0NnPjbqFz44O(iHlHQkFAS6eMla1c8puKtdRiPdB92oDALyQIASX)GuhQtU0Q2nMla5ImOAcfynwjMSP8sMarUSPK(SPalZ3IPx1UjiCCuFQA3yUaKlYGQjuKkry3kg8D0aXUwPevSbzoDQoR7H(WVnn1HniJCynWASsmzt5cx9HQhs3FOJYE2AWOIocMg1fXt9nCCuFKqKbNok7zRbJkYp8BttFvrgC6OSNTgmQixqCwmztEfpsiYGBRztc)WVnn9vfzWT1SjHliolMSjxQeIm40rzpBnyur(HFBA6RkYGthL9S1Grf5cIZIjBYR4rcrg8sEhHsmzZp8BttFvrg8sEhHsmzZfeNft2KlvKbNok7zRbJkYp8BttRqKbNok7zRbJkYfeNft2VxNVfSgRet2uUWvFO6H0DsF20wZMehbtJ6I4P(gooQpsiYGBRztc)WVnn9vfzWT1SjHliolMSjVIhjezWl5DekXKn)WVnn9vfzWl5DekXKnxqCwmztUujezWT1SjHF43MM(QIm42A2KWfeNft2KxXJeIm40rzpBnyur(HFBA6RkYGthL9S1Grf5cIZIjBYLkYGBRztc)WVnnTcrgCBnBs4cIZIj73RZ3cwJvIjBkx4Qpu9q6oPpBwY7iuIjBhbtJ6I4P(gooQpsiYGxY7iuIjB(HFBA6RkYGxY7iuIjBUG4SyYM8kEKqKb3wZMe(HFBA6RkYGBRztcxqCwmztUujezWl5DekXKn)WVnn9vfzWl5DekXKnxqCwmztEfpsiYGthL9S1Grf5h(TPPVQidoDu2ZwdgvKliolMSjxQidEjVJqjMS5h(TPPviYGxY7iuIjBUG4SyY(968TG1aRXkXKnLlYG(qruOtvDjVJqjMSDCuFezWl5DekXKn)WVnnTIhRet2CkIcDQQl5DekXKnVy0qhZhjnMpQJut3TtqALZF5DjQxjHbWo4LdrLPx1c0IDo2MlafVtgV(gKlLQGaGoSBfdkNIOqNQ6sEhHsmzRTeD4zlspBeASk2bF6QeGgpZfGCcfsddGDWxEtSJ6P12A2KWX2CbOq6cIm4uef6uvxY7iuIjB(HFBAQ0fSsmzZPik0PQUK3rOet28P1QGzDpG1yLyYMYfzqj9ztBnBsCSqsbG6WUvmOp1DCuFcdGDWlhIktVQfOf7CSnxakKALyQIArgCBnBsQ41LgZh1rQfd6qDYKkXHFBAAfpRfHtNLmbICzZPe)F2AHDsUcSd5h(TPPouNmPsC43MMwXgoDUG9g8Ma5kwlW)u0txnlwmzZpRLu6HQhs3nxaso5WASsmzt5ImOK(SPTMnjowiPaqDy3kg0N6ooQplega7GxoevMEvlql25yBUaui1kXuf1Im42A2KuXBlnMpQJulg0H6KjvId)200kEwlcNolzce5YMtj()S1c7KCfyhYp8BttDOozsL4WVnnTInC6Cb7n4nbYvSwG)PONUAwSyYMFwlP0dvpKUBUaKCYH1yLyYMYfzqj9zt6OSNTgmQOJfskauh2TIb9PUJJ6JewjMQOwKbNok7zRbJkwXBxjHbWo4LdrLPx1c0IDo2MlafvcvbbaDy3kguonxQJDutruq1wIKlnMpQJulg0H6Kj9q1dP7MlaLkXch(TPPsPkiaOd7wXGYPik0PQUK3rOet2AlXN6oDwYeiYLnNs8)zRf2j5kWoKF43MM6anjaA6UDI3TsmzZjAAyUauBQQGPet2C8vGfIa1X8rYH1yLyYMYfzqj9zZsEhHsmz7yHKca1HDRyqFQ74O(qvqaqh2TIbLtruOtvDjVJqjMS1wIvSfPNncnwf7GpDvcqJN5cqoHcPHbWo4lVj2r90ABnBs4yBUauivId)200kEwlcNolzce5YMtj()S1c7KCfyhYp8BttDOozspu9q6U5cqYLg2TIbpMpQJulg0H6KbRXkXKnLlYGs6ZMennmxaQnvvWuIjBhh1hRetvulYGt00WCbO2uvbtjMSFiZPtjezWjAAyUauBQQGPet2CcfPhQEiD3Cbi5WAG1yLyYMYvhaap6drtdZfGAtvfmLyY2rW0OUiEQVHJJ6tjtGix2CbAXUBcc(HFBAAfpRfX7ViLQGaGoSBfdkNIOqNQ6sEhHsmzRTeFQt6zJqJvXo4txLa04zUaKtOiTKjqKlBoL4)ZwlStYvGDi)WVnn1HxidwJvIjBkxDaa8OK(SzXaaTvIjBnyOHJT9XhHR(q1dP7ooQpkvvcdGDWfOf7Uji4yBUauiLQGaGoSBfdkNIOqNQ6sEhHsmzRTeFQt6zJqJvXo4txLa04zUaKtOivcrgCBnBs4h(TPPviYGBRztcxqCwmz)oz8k9goDkYGxY7iuIjB(HFBAAfIm4L8ocLyYMliolMSFNmELEdNofzWPJYE2AWOI8d)200kezWPJYE2AWOICbXzXK97KXR0BqU0sMarUS5c0ID3ee8d)200kESsmzZT1SjHVweVx5slzce5YMtj()S1c7KCfyhYp8BttD4fYG1yLyYMYvhaapkPpBwmaqBLyYwdgA4yBF8r4Qpu9q6UJJ6JsvLWayhCbAXUBcco2MlafsPkiaOd7wXGYPik0PQUK3rOet2AlXN6KE2i0yvSd(0vjanEMla5ekslzce5YMtj()S1c7KCfyhYp8BttR4HMeanD3oX7wjMS52A2KWxlcsTsmzZT1SjHVweVVLujezWT1SjHF43MMwHidUTMnjCbXzXK971D6uKbVK3rOet28d)200kezWl5DekXKnxqCwmz)EDNofzWPJYE2AWOI8d)200kezWPJYE2AWOICbXzXK971jhwJvIjBkxDaa8OK(SPaTy3nbHJJ6tv7gZfGCrgunHIujkzce5YMtj()S1c7KCfyhYp8BttD4zlYiDTiC6SKjqKlBoL4)ZwlStYvGDi)WVnn1bRet2CkX)NTwyNKRa7qEjtGix2vYlKroSgRet2uU6aa4rj9zt6UjYLA3eeooQpUeQQ8Fwf)yhCcfPUeQQ8Ew3dvda4h(TPPWASsmzt5QdaGhL0NnT1SjXXr9XLqvL)ZQ4h7GtOiDbjcdGDWPJYE2AWOICSnxakKkHYHv1RfbVo3wZMePkhwvVwe8x42A2Kiv5WQ61IGVf3wZMeYD6u5WQ61IGxNBRztc5WASsmzt5QdaGhL0NnPJYE2AWOIooQpUeQQ8Fwf)yhCcfPliHYHv1RfbVoNok7zRbJkkv5WQ61IG)cNok7zRbJkkv5WQ61IGVfNok7zRbJksoSgRet2uU6aa4rj9zZsEhHsmz74O(4sOQY)zv8JDWjuKUGYHv1RfbVoVK3rOet2sxima2b3CPjGiqDjVJqjMS5yBUauaRXkXKnLRoaaEusF2KOPH5cqTPQcMsmz74O(yLyQIArgCIMgMla1MQkykXK9dzoDkHidortdZfGAtvfmLyYMtOi9q1dP7MlajhwJvIjBkxDaa8OK(SP4SP1GrfDCuFCjuv5tJvNWCbOwG)HICAyfjDOozsJ5J6i1IbR4PozWASsmzt5QdaGhL0NnfNnTgmQOJJ6tyaSdoDu2ZwdgvKJT5cqHuxcvv(0y1jmxaQf4FOiNgwrshE2GSk5fYExcQcca6WUvmOCkIcDQQl5DekXKT2sSsoBeASk2bF6QeGgpZfGCcfhEEHCPIm42A2KWp8BttDyJ3PkiaO3nAGsfzWl5DekXKn)WVnn1H1IqQeIm40rzpBnyur(HFBAQdRfHtNlega7GthL9S1Grf5yBUauqUujeOlHQkF3i6GF43MM6WgVtvqaqVB0aD6CHWayh8DJOdo2MlafKlTKDyRt2oSX7ufea07gnqynwjMSPC1baWJs6ZMIZMwdgv0Xr9jma2bF5nXoQNwBRztchBZfGcPUeQQ8PXQtyUaulW)qronSIKo8SbzvYlK9Ueufea0HDRyq5uef6uvxY7iuIjBTLyLC2i0yvSd(0vjanEMla5eko8Sf5vYgVlbvbbaDy3kguofrHov1L8ocLyYwBjwjNncnwf7GpDvcqJN5cqoHYZlKlvKb3wZMe(HFBAQdB8ovbba9UrduQidEjVJqjMS5h(TPPoSwesLqGUeQQ8DJOd(HFBAQdB8ovbba9Urd0PZfcdGDW3nIo4yBUauqU0s2HToz7WgVtvqaqVB0aH1yLyYMYvhaapkPpBkoBAnyurhh1NWayhCZLMaIa1L8ocLyYMJT5cqHuxcvv(0y1jmxaQf4FOiNgwrshE2GSk5fYExcQcca6WUvmOCkIcDQQl5DekXKT2sSsoBeASk2bF6QeGgpZfGCcfhEQCYLkYGBRztc)WVnn1HnENQGaGE3Obkvcb6sOQY3nIo4h(TPPoSX7ufea07gnqNoxima2bF3i6GJT5cqb5slzh26KTdB8ovbba9UrdewJvIjBkxDaa8OK(SP4SP1GrfDCuFCjuv5tJvNWCbOwG)HICAyfjD4fYKALyQIArgCAsa0xgoqMtNUeQQ8PXQtyUaulW)qronSIKou5KbRXkXKnLRoaaEusF2C3i6awJvIjBkxDaa8OK(SPAwiOOqBVbVjqTlAFynwjMSPC1baWJs6ZMke3OsY0RAxGrdynwjMSPC1baWJs6ZMLSlyhNfOqRcSp64O(SGidEj7c2Xzbk0Qa7JAxIR5h(TPPsxWkXKnVKDb74SafAvG9r(0AvWSUhWASsmzt5QdaGhL0NnfNnTMMeahNoW7iuc9kiDnWtDhl720p1DC6aVJqjEQ7yHKca1HDRyqFQ74O(eZh1rQfdwXZAraRXkXKnLRoaaEusF2uC20AAsaCSqsbG6WUvmOp1DSSBt)u3XPd8ocLqpQpXuKKQp8BtxXgooDG3rOe6vq6AGN6ooQpvTBmxaY)20HnTMIsxqGUeQQC6UjYLA87Ewb5h(TPPWASsmzt5QdaGhL0NnfNnTMMeahlKuaOoSBfd6tDhl720p1DC6aVJqj0J6tmfjP6d)20vSHJth4DekHEfKUg4PUJJ6tv7gZfG8VnDytRPiSgRet2uU6aa4rj9ztXztRPjbWXPd8ocLqVcsxd8u3XYUn9tDhNoW7iuIN6WASsmzt5QdaGhL0NnP7MixQDtq4yHKca1HDRyqFQ74O(u1UXCbi)Bth20AkkDbb6sOQYP7MixQXV7zfKF43MMkDbRet2C6UjYLA3ee8P1QGzDpG1yLyYMYvhaapkPpBs3nrUu7MGWXcjfaQd7wXG(u3Xr9PQDJ5cq(3MoSP1uewJvIjBkxDaa8OK(SjD3e5sTBccynWASsmzt5ufSf4rF(gavNI(mLG4qhh1NQ2nMla5ImOAcfynwjMSPCQc2c8OK(SjfrHov1L8ocLyY2Xr9PQDJ5cqobf1uefE5Q4rNS91(czVqgzvQ6K5LxAxp9k1l)w6RKxGciRsdzwjMSHmWqdkhwJxgm0G6x0llC1hQEiD3VOV26(f9YyBUau432lBLyY2lthL9S1Grf9YLBc8gZllbKjYGthL9S1Grf5h(TPPq2RczIm40rzpBnyurUG4SyYgYihYQ4bYKaYezWT1SjHF43MMczVkKjYGBRztcxqCwmzdzKdzsHmjGmrgC6OSNTgmQi)WVnnfYEvitKbNok7zRbJkYfeNft2qg5qwfpqMeqMidEjVJqjMS5h(TPPq2RczIm4L8ocLyYMliolMSHmYHmPqMidoDu2ZwdgvKF43MMczvazIm40rzpBnyurUG4SyYgYEhYQZ3YldMg1fHxU(g(Wx7l(f9YyBUau432lBLyY2lBRztIxUCtG3yEzjGmrgCBnBs4h(TPPq2RczIm42A2KWfeNft2qg5qwfpqMeqMidEjVJqjMS5h(TPPq2RczIm4L8ocLyYMliolMSHmYHmPqMeqMidUTMnj8d)20ui7vHmrgCBnBs4cIZIjBiJCiRIhitcitKbNok7zRbJkYp8BttHSxfYezWPJYE2AWOICbXzXKnKroKjfYezWT1SjHF43MMczvazIm42A2KWfeNft2q27qwD(wEzW0OUi8Y13Wh(A3YVOxgBZfGc)2EzRet2E5sEhHsmz7Ll3e4nMxwcitKbVK3rOet28d)20ui7vHmrg8sEhHsmzZfeNft2qg5qwfpqMeqMidUTMnj8d)20ui7vHmrgCBnBs4cIZIjBiJCitkKjbKjYGxY7iuIjB(HFBAkK9QqMidEjVJqjMS5cIZIjBiJCiRIhitcitKbNok7zRbJkYp8BttHSxfYezWPJYE2AWOICbXzXKnKroKjfYezWl5DekXKn)WVnnfYQaYezWl5DekXKnxqCwmzdzVdz15B5LbtJ6IWlxFdF4dVSavncq4x0xBD)IEzRet2EzQccaAqwK0lJT5cqHFBF4R9f)IEzRet2Ezbwnjo93wNIxgBZfGc)2(Wx7w(f9YyBUau432lxUjWBmVSlHQkNUBICPg)UNvqoHcKjfYCjuv50DtKl1439ScYp8BttHSkGSIrdDmFeYifYIZQIaDmF0lBLyY2lt3nrUu7MGWh(ARC)IEzSnxak8B7LtfVmfdVSvIjBVCv7gZfGE5QgGa9YHbWo40CPo2rnfrbLJT5cqbKjfYOkiaOd7wXGYPik0PQUK3rOet2AlriZHhiBliJui7SrOXQyh8PRsaA8mxaYjuGmNoHSWayhC6OSNTgmQihBZfGcitkKrvqaqh2TIbLtruOtvDjVJqjMSHmhEGSnGmsHSZgHgRIDWNUkbOXZCbiNqbYC6eYOkiaOd7wXGYPik0PQUK3rOet2qMdpq2BdzKczNncnwf7GpDvcqJN5cqoHIxUQD62(OxMGIAkIcF4RDd)IEzSnxak8B7LtfVmfdVSvIjBVCv7gZfGE5QgGa9YwjMS50DtKl1Uji44RalebQJ5Jq27qM9g8Ma5fJwmX0R6IbS)eKWX2CbOWlx1oDBF0lRycX0R(Wx7R7x0lJT5cqHFBVCQ4LpKIHx2kXKTxUQDJ5cqVCvdqGE51IWlxUjWBmVS9g8Ma5fJwmX0R6IbS)eKWX2CbOaYKczsazHbWo4IZMwttcahBZfGciZPtitPQsyaSdUaTy3nbbhBZfGcitkKvYeiYLnxGwS7MGGF43MMczv8azRfbKrUxUQD62(OxwXeIPx9HV2kTFrVm2Mlaf(T9YPIxMIHx2kXKTxUQDJ5cqVCvdqGEzQcca6WUvmOCkIcDQQl5DekXKT2seYQ4bYQdzKczHbWo4lVj2r90ABnBs4yBUauazKczHbWo4MlnbebQl5DekXKnhBZfGci7Di7fiJuitcilma2bF5nXoQNwBRztchBZfGcitkKfga7GtZL6yh1uefuo2MlafqMuiJQGaGoSBfdkNIOqNQ6sEhHsmzRTeHmhGSxGmYHmsHmjGSWayhC6OSNTgmQihBZfGcitkKTaKfga7GxoevMEvlql25yBUauazsHSfGSWayhCXztRPjbGJT5cqbKroKrkKD2i0yvSd(0vjanEMla5ekE5Q2PB7JE5VnDytRPOp81(2(f9YyBUau432lNkEzkgEzRet2E5Q2nMla9Yvnab6LLaYwaYcdGDWPJYE2AWOICSnxakGmNoHmrgC6OSNTgmQiNqbYihYKczIm42A2KWPHvKeYC4bYQtgKjfYwaYezWT1SjHFO6H0DZfGqMuitKbVK3rOet2CcfitkKjYGt00WCbO2uvbtjMS5ekE5Q2PB7JEzrgunHIp81wP8l6LX2CbOWVTx2kXKTxUyaG2kXKTgm0WldgAOB7JE5sMarUSP(WxBDY8l6LX2CbOWVTx2kXKTxwC20AAsa8Yfskauh2TIb1xBDVC5MaVX8YX8rDKAXGqwfpq2ArazsHmAsa00D7eqwfq2gE5YUnTxUUxE6aVJqj0RG01aE56(WxB96(f9YyBUau432lxUjWBmVmvbbaDy3kguofrHov1L8ocLyYwBjczv8azVazKczNncnwf7GpDvcqJN5cqoHIx2kXKTxE3i6Wh(AR)IFrVm2Mlaf(T9YLBc8gZlx1UXCbixKbvtOazsHmrgCIMgMla1MQkykXKn)WVnnfYCaYkgn0X8ritkKjbKTaKvYQyBDWRIDStYbzoDczIm4ZxbBX0R6IfgnUuzh5XuKC6viJCitkKjbKTaKfga7GRSBDKFnD6vcGDtqchBZfGciZPtiRKjqKlBUYU1r(10Pxja2nbj8d)20uiJCitkKjbKTaKPuvjma2bxGwS7MGGJT5cqbK50jKvYeiYLnxGwS7MGGF43MMczv8azRfbK50jKTaKvYeiYLnxGwS7MGGF43MMczoDcz0KaOP72jGShiJmitkKrvqaqh2TIbLtruOtvDjVJqjMS1wIqMdqwDiJui7SrOXQyh8PRsaA8mxaYjuGmY9YwjMS9YuI)pBTWojxb2H(WxB9T8l6LX2CbOWVTxUCtG3yE5sMarUS5uI)pBTWojxb2H8d)20uitkKv1UXCbixKbvtOazsHmQcca6WUvmOCkIcDQQl5DekXKT2seYEGS6qgPq2zJqJvXo4txLa04zUaKtOazsHmjGSfGmKsXUG8QdDYwNQAf8uXsmzZ)tNhKjfYwaYS3G3eixCOjuja6IbatVYpRLeYC6eYkzce5YMtj()S1c7KCfyhYp8BttHmhGSTidYi3lBLyY2llql2Dtq4dFT1RC)IEzSnxak8B7Ll3e4nMx2LqvLFyrsasPA18ki)WVnn1lBLyY2lh7OMODtIwOvZRG(WxB9n8l6LX2CbOWVTx2kXKTx2wZMeVC5MaVX8Yh(TPPqwfpq2ArazKczwjMS50DtKl1Uji44RalebQJ5JqMuilMpQJulgeYCaYEBVCHKca1HDRyq91w3h(AR)6(f9YyBUau432lxUjWBmVCmFeYQaY2ImVSvIjBV8h)5rIov1aIYi0IdTp1h(ARxP9l6LX2CbOWVTx2kXKTx2wZMeVC5MaVX8YX8riZbiBlYGmPqwjtGix2CkX)NTwyNKRa7q(HFBAkKvXdKvFditkKHvwIrrbfC7n0D7mQwn7qNQALCjEEzW0OUi8YBrMp81w)T9l6LX2CbOWVTx2kXKTxUK3rOet2E5YnbEJ5LJ5JqMdq2wKbzsHSsMarUS5uI)pBTWojxb2H8d)20uiRIhiR(gqMuidRSeJIck42BO72zuTA2Hov1k5s8GmPq2cqwyaSdU5starG6sEhHsmzZX2CbOaYKczsazHbWo40rzpBnyuro2MlafqMtNqgvbbaDy3kguofrHov1L8ocLyYwBjczoaz1HmPqgvbbaDy3kguofrHov1L8ocLyYwBjczv8azBbzK7LbtJ6IWlVfz(WxB9kLFrVm2Mlaf(T9YwjMS9Y0rzpBnyurVC5MaVX8YX8riZbiBlYGmPqwjtGix2CkX)NTwyNKRa7q(HFBAkKvXdKvFditkKHvwIrrbfC7n0D7mQwn7qNQALCjEEzW0OUi8YBrMp81(cz(f9YyBUau432lxUjWBmVSvIPkQfzWjAAyUauBQQGPet2q2dKrgK50jKjbKjYGt00WCbO2uvbtjMS5ekqMui7q1dP7MlaHmY9YwjMS9YennmxaQnvvWuIjBF4R9L6(f9YyBUau432lBLyY2lloBAnnjaE5cjfaQd7wXG6RTUxUyDbb6r1lhtrsQ(WVnDfB4Ll3e4nMxUQDJ5cq(3MoSP1ueYKczc0LqvLt3nrUuJF3Zki)WVnnfYKczc0LqvLt3nrUuJF3Zki)WVnnfYQ4bYwlci7Di7fF4R9Lx8l6LX2CbOWVTx2kXKTxMUBICP2nbHxUCtG3yE5Q2nMla5FB6WMwtritkKjqxcvvoD3e5sn(DpRG8d)20uitkKjqxcvvoD3e5sn(DpRG8d)20uiRIhidFfyHiqDmFeYEhYEbYifYIZQIaDmFeYKczlazwjMS50DtKl1Uji4tRvbZ6E4LlKuaOoSBfdQV26(Wx7lB5x0lJT5cqHFBVSvIjBVSYU1r(10Pxja2nbjE5YnbEJ5LJ5JqMdq2wBazsHSWUvm4X8rDKAXGqMdqw9xhYEhYOkiaO3nAGqMuitciBbidPuSliV6qNS1PQwbpvSet28)05bzsHSfGm7n4nbYfhAcvcGUyaW0R8ZAjHmNoHSsMarUS5uI)pBTWojxb2H8d)20uiZbiRY3aYifYOjbqt3TtazVdz2BWBcKlo0eQeaDXaGPx5N1sczoDczLmbICzZPe)F2AHDsUcSd5h(TPPqwfqw9nGS3HmQcca6DJgiKrkKrtcGMUBNaYEhYS3G3eixCOjuja6IbatVYpRLeYi3lxiPaqDy3kguFT19HV2xQC)IEzSnxak8B7Ll3e4nMxUQDJ5cqobf1uefqMuiJMeanD3obK9azB4LTsmz7LPik0PQUK3rOet2(Wx7lB4x0lJT5cqHFBVSvIjBVCXaaTvIjBnyOHxgm0q32h9YImO(Wx7lVUFrVm2Mlaf(T9YwjMS9YvhaQdB6WlxUjWBmVCmFeYCaYQVbKjfYI5J6i1IbHmhEGS6KbzsHmjGSsMarUS5uI)pBTWojxb2H8d)20uiZbiBlYGmNoHSsMarUS5uI)pBTWojxb2H8d)20uiRciRozqMuitKb3wZMe(HFBAkK5WdKvNmitkKjYGxY7iuIjB(HFBAkK5WdKvNmitkKjbKjYGthL9S1Grf5h(TPPqMdpqwDYGmNoHSfGSWayhC6OSNTgmQihBZfGciJCiJCVCHKca1HDRyq91w3h(AFPs7x0lJT5cqHFBVSvIjBVS9g6UDgvRMDOtvTsUepVC5MaVX8YX8riRIhiBlVCBF0lBVHUBNr1Qzh6uvRKlXZh(AF5T9l6LX2CbOWVTxUCtG3yE5y(iKvXdKT1gEzRet2EzLDRJ8RPtVsaSBcs8HV2xQu(f9YyBUau432lxUjWBmVCmFeYQaYQVHx2kXKTxU6aqDyth(Wx7wK5x0lJT5cqHFBVC5MaVX8YsazLmbICzZPe)F2AHDsUcSd5h(TPPqwfqw9nGmsHmAsa00D7eq27qM9g8Ma5IdnHkbqxmay6vo2MlafqMtNqMeqM9g8Ma5IdnHkbqxmay6v(zTKqMtNqgsPyxqE1HozRtvTcEQyjMS5N1sczKdzsHSy(iK5aKTfzqMuilMpQJulgeYC4bYEPozqg5qMuitcitKbxz36i)A60Rea7MGe(HFBAkK50jKjYGxDaOoSPd(HFBAkK50jKTaKfga7GRSBDKFnD6vcGDtqchBZfGcitkKTaKfga7GxDaOoSPdo2Mlafqg5qMtNqwmFuhPwmiKvbKTfzqgPq2Ar4LTsmz7LxjStmwRtvT9g8Yy3h(A3QUFrVm2Mlaf(T9YLBc8gZlxYeiYLnNs8)zRf2j5kWoKF43MMczvaz13aYifYOjbqt3TtazVdz2BWBcKlo0eQeaDXaGPx5yBUauazsHmjGmrgCLDRJ8RPtVsaSBcs4h(TPPqMtNqMidE1bG6WMo4h(TPPqg5EzRet2EzHDsQPjbWh(A36f)IEzRet2Ezx8O4j50REzSnxak8B7dFTBTLFrVm2Mlaf(T9YwjMS9Yfda0wjMS1GHgEzWqdDBF0ltvWwGh1h(A3QY9l6LX2CbOWVTx2kXKTxUyaG2kXKTgm0WldgAOB7JEz1baWJ6dF4LvoSKFxl8l6RTUFrVSvIjBVmL4)ZwRIGDIoWZlJT5cqHFBF4R9f)IEzSnxak8B7Ll3e4nMxoma2bF9MFohQtvn1k3OofKJT5cqHx2kXKTxE9MFohQtvn1k3Oof0h(A3YVOx2kXKTxwjJjBVm2Mlaf(T9HV2k3VOxgBZfGc)2E52(Ox2EdD3oJQvZo0PQwjxINx2kXKTx2EdD3oJQvZo0PQwjxINp81UHFrVm2Mlaf(T9YLBc8gZltvqaqh2TIbLtruOtvDjVJqjMS1wIqMdpq2wqMuiBbidRSeJIck42BO72zuTA2Hov1k5s88YwjMS9Yuef6uvxY7iuIjBF4R919l6LTsmz7L3nIo8YyBUau432h(AR0(f9YyBUau432lxUjWBmV8cqwyaSd(Ur0bhBZfGcitkKrvqaqh2TIbLtruOtvDjVJqjMS1wIqwfq2wqMuiBbidRSeJIck42BO72zuTA2Hov1k5s88YwjMS9Y0DtKl1Uji8Hp8YLmbICzt9l6RTUFrVSvIjBV8Y8aIQ406dPzBDb9YyBUau432h(AFXVOxgBZfGc)2EzRet2Ez7n0D7mQwn7qNQALCjEE5YnbEJ5LLaYwaYcdGDWv2ToYVMo9kbWUjiHJT5cqbK50jKvYeiYLnxz36i)A60Rea7MGe(HFBAkKvbKv5q27qgvbba9UrdeYC6eYwaYkzce5YMRSBDKFnD6vcGDtqc)WVnnfYihYKczLmbICzZPe)F2AHDsUcSd5h(TPPqwfqw9kfK9oKrvqaqVB0aHmsHmAsa00D7eq27qM9g8Ma5IdnHkbqxmay6v(zTKqMuitKb3wZMe(HFBAkKjfYezWl5DekXKn)WVnnfYKczsazIm40rzpBnyur(HFBAkK50jKTaKfga7GthL9S1Grf5yBUauazK7LB7JEz7n0D7mQwn7qNQALCjE(Wx7w(f9YyBUau432lxUjWBmVSeqwyaSdUWoj10KaO)dfps4yBUauazsHSsMarUS5uI)pBTWojxb2HCcfitkKvYeiYLnxyNKAAsa4ekqg5qMtNqwjtGix2CkX)NTwyNKRa7qoHcK50jKfZh1rQfdczvazBrMx2kXKTxwjJjBF4RTY9l6LX2CbOWVTxUCtG3yE5sMarUS5uI)pBTWojxb2H8d)20uiZbiRstgK50jKfZh1rQfdczvazVqgK50jKjbKjYGt00WCbO2uvbtjMS5XuKC6vitkKrtcGMUBNaYEGmYGmPqMeq2cqwyaSdUYU1r(10Pxja2nbjCSnxakGmNoHSsMarUS5k7wh5xtNELay3eKWp8BttHmYHmPqMeq2cqMsvLWayhCbAXUBcco2MlafqMtNqwjtGix2CbAXUBcc(HFBAkKvXdKTweqMtNq2cqwjtGix2CbAXUBcc(HFBAkKroKjfYwaYkzce5YMtj()S1c7KCfyhYp8BttHmY9YwjMS9Yeuupb(P(Wx7g(f9YyBUau432lxUjWBmV8cqwjtGix2CkX)NTwyNKRa7qoHIx2kXKTxwDo0fKPWh(AFD)IEzSnxak8B7Ll3e4nMxEbiRKjqKlBoL4)ZwlStYvGDiNqXlBLyY2l7cYuOvjos8HV2kTFrVm2Mlaf(T9YLBc8gZlhZhHmhGSTiZlBLyY2l)XFEKOtvnGOmcT4q7t9HV232VOxgBZfGc)2E5YnbEJ5LJ5J6i1IbHSkGSxidYifYwlciZPtilma2bNMl1XoQPikOCSnxakGmPqwjtGix2CkX)NTwyNKRa7q(HFBAkK5WdKvYeiYLnNs8)zRf2j5kWoKliolMSHSkbYQtMx2kXKTxwyNKAAsa8HV2kLFrVm2Mlaf(T9YLBc8gZlRGbxyNKRa7q(HFBAkK50jKjbKTaKvYeiYLnxGwS7MGGF43MMczoDczlazkvvcdGDWfOf7Uji4yBUauazKdzsHSsMarUS5uI)pBTWojxb2H8d)20uiZHhi7TjdYKcziLIDb5UGmf6uvh7OgB8tc)SwsiZbiRUx2kXKTx2fKPqNQ6yh1yJFs8HV26K5x0lJT5cqHFBVSvIjBVSswKed68guOl5xHiSyYwlWQtb9YLBc8gZllbKvYeiYLnNs8)zRf2j5kWoKF43MMczo8azVSbK50jKfZh1rQfdczv8azBrgKroKjfYKaYkzce5YMlql2DtqWp8BttHmNoHSfGmLQkHbWo4c0ID3eeCSnxakGmY9YT9rVSswKed68guOl5xHiSyYwlWQtb9HV2619l6LX2CbOWVTx2kXKTx(YOCe0af6QzkYulsaWlxUjWBmVSeqwjtGix2CkX)NTwyNKRa7q(HFBAkK5WdK9YgqMtNqwmFuhPwmiKvXdKTfzqg5qMuitciRKjqKlBUaTy3nbb)WVnnfYC6eYwaYuQQega7Glql2DtqWX2CbOaYi3l32h9YxgLJGgOqxntrMArca(WxB9x8l6LX2CbOWVTx2kXKTxMUpvXtxf78RpemfVC5MaVX8YsazLmbICzZPe)F2AHDsUcSd5h(TPPqMdpq2lBazoDczX8rDKAXGqwfpq2wKbzKdzsHmjGSsMarUS5c0ID3ee8d)20uiZPtiBbitPQsyaSdUaTy3nbbhBZfGciJCVCBF0lt3NQ4PRID(1hcMIp81wFl)IEzSnxak8B7LTsmz7LTklXOKb2HUnIyaeuVC5MaVX8YsazLmbICzZPe)F2AHDsUcSd5h(TPPqMdpq2lBazoDczX8rDKAXGqwfpq2wKbzKdzsHmjGSsMarUS5c0ID3ee8d)20uiZPtiBbitPQsyaSdUaTy3nbbhBZfGciJCVCBF0lBvwIrjdSdDBeXaiO(WxB9k3VOxgBZfGc)2EzRet2E5yeinY7RlPaFfE5YnbEJ5LLaYkzce5YMtj()S1c7KCfyhYp8BttHmhEGSx2aYC6eYI5J6i1IbHSkEGSTidYihYKczsazLmbICzZfOf7Uji4h(TPPqMtNq2cqMsvLWayhCbAXUBcco2Mlafqg5E52(OxogbsJ8(6skWxHp81wFd)IEzSnxak8B7LTsmz7LRogqNQAAK3N6Ll3e4nMxwciRKjqKlBoL4)ZwlStYvGDi)WVnnfYC4bYEzdiZPtilMpQJulgeYQ4bY2ImiJCitkKjbKvYeiYLnxGwS7MGGF43MMczoDczlazkvvcdGDWfOf7Uji4yBUauazK7LB7JE5QJb0PQMg59P(WxB9x3VOx2kXKTx(gffaQNwtvSc6LX2CbOWVTp81wVs7x0lJT5cqHFBVC5MaVX8YvTBmxaYfzq1ekEzRet2EzAjjUPx1Xe7Op81w)T9l6LX2CbOWVTxUCtG3yE5Q2nMla5ImOAcfVSvIjBV88vWwm9QUyHrJlv2rF4RTELYVOxgBZfGc)2E5YnbEJ5LLaYCjuv5tJvNWCbOwG)HICAyfjHmhGSTEBiZPtiZkXuf1yJ)bPqMdqwDiJCitkKv1UXCbixKbvtO4LTsmz7LPjbqFz4dFTVqMFrVm2Mlaf(T9YLBc8gZlx1UXCbixKbvtOazsHmjGSWUvm47ObIDTsjGSkGSnidYC6eYuN19qF43MMczoazBqgKrUx2kXKTxwGL5BX0RA3ee(WhEzQc2c8O(f91w3VOxgBZfGc)2E5YnbEJ5LRA3yUaKlYGQju8YwjMS9YFdGQtrFMsqCOp81(IFrVm2Mlaf(T9YLBc8gZlx1UXCbiNGIAkIcVSvIjBVmfrHov1L8ocLyY2h(WlRoaaEu)I(AR7x0lJT5cqHFBVSvIjBVmrtdZfGAtvfmLyY2lxUjWBmVCjtGix2CbAXUBcc(HFBAkKvXdKTweq27q2lqMuiJQGaGoSBfdkNIOqNQ6sEhHsmzRTeHShiRoKrkKD2i0yvSd(0vjanEMla5ekqMuiRKjqKlBoL4)ZwlStYvGDi)WVnnfYCaYEHmVmyAuxeE56B4dFTV4x0lJT5cqHFBVC5MaVX8YkvvcdGDWfOf7Uji4yBUauazsHmQcca6WUvmOCkIcDQQl5DekXKT2seYEGS6qgPq2zJqJvXo4txLa04zUaKtOazsHmjGmrgCBnBs4h(TPPqwfqMidUTMnjCbXzXKnK9oKrgVsVbK50jKjYGxY7iuIjB(HFBAkKvbKjYGxY7iuIjBUG4SyYgYEhYiJxP3aYC6eYezWPJYE2AWOI8d)20uiRcitKbNok7zRbJkYfeNft2q27qgz8k9gqg5qMuiRKjqKlBUaTy3nbb)WVnnfYQ4bYSsmzZT1SjHVweq27qwLdzsHSsMarUS5uI)pBTWojxb2H8d)20uiZbi7fY8YwjMS9Yfda0wjMS1GHgEzWqdDBF0llC1hQEiD3h(A3YVOxgBZfGc)2E5YnbEJ5LvQQega7Glql2DtqWX2CbOaYKczufea0HDRyq5uef6uvxY7iuIjBTLiK9az1HmsHSZgHgRIDWNUkbOXZCbiNqbYKczLmbICzZPe)F2AHDsUcSd5h(TPPqwfpqgnjaA6UDci7DiZkXKn3wZMe(ArazKczwjMS52A2KWxlci7DiBlitkKjbKjYGBRztc)WVnnfYQaYezWT1SjHliolMSHS3HS6qMtNqMidEjVJqjMS5h(TPPqwfqMidEjVJqjMS5cIZIjBi7DiRoK50jKjYGthL9S1Grf5h(TPPqwfqMidoDu2ZwdgvKliolMSHS3HS6qg5EzRet2E5IbaARet2AWqdVmyOHUTp6LfU6dvpKU7dFTvUFrVm2Mlaf(T9YLBc8gZlx1UXCbixKbvtOazsHmjGSsMarUS5uI)pBTWojxb2H8d)20uiZHhiBlYGmsHS1IaYC6eYkzce5YMtj()S1c7KCfyhYp8BttHmhGmRet2CkX)NTwyNKRa7qEjtGix2qwLazVqgKrUx2kXKTxwGwS7MGWh(A3WVOxgBZfGc)2E5YnbEJ5LDjuv5)Sk(Xo4ekqMuiZLqvL3Z6EOAaa)WVnn1lBLyY2lt3nrUu7MGWh(AFD)IEzSnxak8B7Ll3e4nMx2LqvL)ZQ4h7GtOazsHSfGmjGSWayhC6OSNTgmQihBZfGcitkKjbKPCyv9ArWRZT1SjbYKczkhwvVwe8x42A2KazsHmLdRQxlc(wCBnBsGmYHmNoHmLdRQxlcEDUTMnjqg5EzRet2EzBnBs8HV2kTFrVm2Mlaf(T9YLBc8gZl7sOQY)zv8JDWjuGmPq2cqMeqMYHv1RfbVoNok7zRbJkczsHmLdRQxlc(lC6OSNTgmQiKjfYuoSQETi4BXPJYE2AWOIqg5EzRet2Ez6OSNTgmQOp81(2(f9YyBUau432lxUjWBmVSlHQk)NvXp2bNqbYKczlazkhwvVwe868sEhHsmzdzsHSfGSWayhCZLMaIa1L8ocLyYMJT5cqHx2kXKTxUK3rOet2(WxBLYVOxgBZfGc)2E5YnbEJ5LTsmvrTidortdZfGAtvfmLyYgYEGmYGmNoHmjGmrgCIMgMla1MQkykXKnNqbYKczhQEiD3CbiKrUx2kXKTxMOPH5cqTPQcMsmz7dFT1jZVOxgBZfGc)2E5YnbEJ5LDjuv5tJvNWCbOwG)HICAyfjHmhGS6KbzsHSy(OosTyqiRIhiRozEzRet2EzXztRbJk6dFT1R7x0lJT5cqHFBVC5MaVX8YHbWo40rzpBnyuro2MlafqMuiZLqvLpnwDcZfGAb(hkYPHvKeYC4bY2GmiRsGSxidYEhYKaYOkiaOd7wXGYPik0PQUK3rOet2AlriRsGSZgHgRIDWNUkbOXZCbiNqbYC4bYEbYihYKczIm42A2KWp8BttHmhGSnGS3HmQcca6DJgiKjfYezWl5DekXKn)WVnnfYCaYwlcitkKjbKjYGthL9S1Grf5h(TPPqMdq2ArazoDczlazHbWo40rzpBnyuro2Mlafqg5qMuitcitGUeQQ8DJOd(HFBAkK5aKTbK9oKrvqaqVB0aHmNoHSfGSWayh8DJOdo2Mlafqg5qMuiRKDyRt2qMdq2gq27qgvbba9Urd0lBLyY2lloBAnyurF4RT(l(f9YyBUau432lxUjWBmVCyaSd(YBIDupT2wZMeo2MlafqMuiZLqvLpnwDcZfGAb(hkYPHvKeYC4bY2GmiRsGSxidYEhYKaYOkiaOd7wXGYPik0PQUK3rOet2AlriRsGSZgHgRIDWNUkbOXZCbiNqbYC4bY2cYihYQeiBdi7DitciJQGaGoSBfdkNIOqNQ6sEhHsmzRTeHSkbYoBeASk2bF6QeGgpZfGCcfi7bYEbYihYKczIm42A2KWp8BttHmhGSnGS3HmQcca6DJgiKjfYezWl5DekXKn)WVnnfYCaYwlcitkKjbKjqxcvv(Ur0b)WVnnfYCaY2aYEhYOkiaO3nAGqMtNq2cqwyaSd(Ur0bhBZfGciJCitkKvYoS1jBiZbiBdi7DiJQGaGE3Ob6LTsmz7LfNnTgmQOp81wFl)IEzSnxak8B7Ll3e4nMxoma2b3CPjGiqDjVJqjMS5yBUauazsHmxcvv(0y1jmxaQf4FOiNgwrsiZHhiBdYGSkbYEHmi7DitciJQGaGoSBfdkNIOqNQ6sEhHsmzRTeHSkbYoBeASk2bF6QeGgpZfGCcfiZHhiRYHmYHmPqMidUTMnj8d)20uiZbiBdi7DiJQGaGE3ObczsHmjGmb6sOQY3nIo4h(TPPqMdq2gq27qgvbba9UrdeYC6eYwaYcdGDW3nIo4yBUauazKdzsHSs2HTozdzoazBazVdzufea07gnqVSvIjBVS4SP1Grf9HV26vUFrVm2Mlaf(T9YLBc8gZl7sOQYNgRoH5cqTa)df50WksczoazVqgKjfYSsmvrTidonja6ldiZbiJmiZPtiZLqvLpnwDcZfGAb(hkYPHvKeYCaYQCY8YwjMS9YIZMwdgv0h(ARVHFrVSvIjBV8Ur0HxgBZfGc)2(WxB9x3VOx2kXKTxwnleuuOT3G3eO2fTVxgBZfGc)2(WxB9kTFrVSvIjBVScXnQKm9Q2fy0WlJT5cqHFBF4RT(B7x0lJT5cqHFBVC5MaVX8YlazIm4LSlyhNfOqRcSpQDjUMF43MMczsHSfGmRet28s2fSJZcuOvb2h5tRvbZ6E4LTsmz7LlzxWoolqHwfyF0h(ARxP8l6LX2CbOWVTx2kXKTxwC20AAsa8Yfskauh2TIb1xBDV80bEhHs4LR7Ll3e4nMxoMpQJulgeYQ4bYwlcVCz3M2lx3lpDG3rOe6vq6AaVCDF4R9fY8l6LX2CbOWVTx2kXKTxwC20AAsa8Yfskauh2TIb1xBDV80bEhHsOhvVCmfjP6d)20vSHxUCtG3yE5Q2nMla5FB6WMwtritkKTaKjqxcvvoD3e5sn(DpRG8d)20uVCz3M2lx3lpDG3rOe6vq6AaVCDF4R9L6(f9YyBUau432lBLyY2lloBAnnjaE5cjfaQd7wXG6RTUxE6aVJqj0JQxoMIKu9HFB6k2WlxUjWBmVCv7gZfG8VnDytRPOxUSBt7LR7LNoW7iuc9kiDnGxUUp81(Yl(f9YyBUau432lBLyY2lloBAnnjaE5Pd8ocLWlx3lx2TP9Y19Yth4DekHEfKUgWlx3h(AFzl)IEzSnxak8B7LTsmz7LP7MixQDtq4Ll3e4nMxUQDJ5cq(3MoSP1ueYKczlazc0LqvLt3nrUuJF3Zki)WVnnfYKczlazwjMS50DtKl1Uji4tRvbZ6E4LlKuaOoSBfdQV26(Wx7lvUFrVm2Mlaf(T9YwjMS9Y0DtKl1Uji8YLBc8gZlx1UXCbi)Bth20Ak6LlKuaOoSBfdQV26(Wx7lB4x0lBLyY2lt3nrUu7MGWlJT5cqHFBF4dVSidQFrFT19l6LX2CbOWVTxUCtG3yEzrg8sEhHsmzZp8BttHSkEGmRet2CkIcDQQl5DekXKnVy0qhZhHmsHSy(OosnD3obKrkKv58xGS3HmjGS6qwLazHbWo4LdrLPx1c0IDo2Mlafq27qgz86BazKdzsHmQcca6WUvmOCkIcDQQl5DekXKT2seYC4bY2cYifYoBeASk2bF6QeGgpZfGCcfiJuilma2bF5nXoQNwBRztchBZfGcitkKTaKjYGtruOtvDjVJqjMS5h(TPPqMuiBbiZkXKnNIOqNQ6sEhHsmzZNwRcM19WlBLyY2ltruOtvDjVJqjMS9HV2x8l6LX2CbOWVTx2kXKTx2wZMeVC5MaVX8YHbWo4LdrLPx1c0IDo2MlafqMuiZkXuf1Im42A2KazvazVoKjfYI5J6i1IbHmhGS6KbzsHmjGSd)20uiRIhiBTiGmNoHSsMarUS5uI)pBTWojxb2H8d)20uiZbiRozqMuitci7WVnnfYQaY2aYC6eYwaYS3G3eixXAb(NIE6QzXIjB(zTKqMui7q1dP7MlaHmYHmY9Yfskauh2TIb1xBDF4RDl)IEzSnxak8B7LTsmz7LT1SjXlxUjWBmV8cqwyaSdE5quz6vTaTyNJT5cqbKjfYSsmvrTidUTMnjqwfq2BdzsHSy(OosTyqiZbiRozqMuitci7WVnnfYQ4bYwlciZPtiRKjqKlBoL4)ZwlStYvGDi)WVnnfYCaYQtgKjfYKaYo8BttHSkGSnGmNoHSfGm7n4nbYvSwG)PONUAwSyYMFwljKjfYou9q6U5cqiJCiJCVCHKca1HDRyq91w3h(ARC)IEzSnxak8B7LTsmz7LPJYE2AWOIE5YnbEJ5LLaYSsmvrTidoDu2ZwdgveYQaYEBiRsGSWayh8YHOY0RAbAXohBZfGciRsGmQcca6WUvmOCAUuh7OMIOGQTeHmYHmPqwmFuhPwmiK5aKvNmitkKDO6H0DZfGqMuitciBbi7WVnnfYKczufea0HDRyq5uef6uvxY7iuIjBTLiK9az1HmNoHSsMarUS5uI)pBTWojxb2H8d)20uiZbiJMeanD3obK9oKzLyYMt00WCbO2uvbtjMS54RalebQJ5Jqg5E5cjfaQd7wXG6RTUp81UHFrVm2Mlaf(T9YwjMS9YL8ocLyY2lxUjWBmVmvbbaDy3kguofrHov1L8ocLyYwBjczvazBbzKczNncnwf7GpDvcqJN5cqoHcKrkKfga7GV8Myh1tRT1SjHJT5cqbKjfYKaYo8BttHSkEGS1IaYC6eYkzce5YMtj()S1c7KCfyhYp8BttHmhGS6KbzsHSdvpKUBUaeYihYKczHDRyWJ5J6i1IbHmhGS6K5LlKuaOoSBfdQV26(Wx7R7x0lJT5cqHFBVC5MaVX8YwjMQOwKbNOPH5cqTPQcMsmzdzpqgzqMtNqMeqMidortdZfGAtvfmLyYMtOazsHSdvpKUBUaeYi3lBLyY2lt00WCbO2uvbtjMS9Hp8Hx2iI988YYZ)TWh(W7ba]] )


end