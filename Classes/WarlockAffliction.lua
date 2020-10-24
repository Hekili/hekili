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
            id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
            duration = function () return level > 55 and 21 or 16 end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Magic",
            max_stack = 1,
            copy = { 342938, 316099 }
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
        },


        -- Legendaries
        relic_of_demonic_synergy = {
            id = 337060,
            duration = 15,
            max_stack = 1
        },

        wrath_of_consumption = {
            id = 337130,
            duration = 20,
            max_stack = 5
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
            removeBuff( "inevitable_demise" )
            removeBuff( "inevitable_demise_az" )
        end

        if buff.casting_circle.up then
            applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "soul_shards" and amt > 0 then
            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_darkglare", amt * 2 )
            end                
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

            tick_time = function () return class.auras.drain_life.tick_time end,

            start = function ()
                removeBuff( "inevitable_demise" )
                removeBuff( "inevitable_demise_az" )
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
                },
                -- Azerite
                inevitable_demise_az = {
                    id = 273525,
                    duration = 20,
                    max_stack = 50
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

            tick_time = function () return class.auras.drain_soul.tick_time end,

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

            essential = true,
            
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
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
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
            handler = function ()
                removeBuff( "fel_domination" )
                summonPet( "felhunter" )
            end,

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
            id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136228,

            handler = function ()
                if azerite.cascading_calamity.enabled and debuff.unstable_affliction.up then
                    applyBuff( "cascading_calamity" )
                end

                applyDebuff( "target", "unstable_affliction" )

                if azerite.dreadful_calling.enabled then
                    gainChargeTime( "summon_darkglare", 1 )
                end
            end,

            copy = { 342938, 316099 },

            auras = {
                -- Azerite
                cascading_calamity = {
                    id = 275378,
                    duration = 15,
                    max_stack = 1
                }
            }
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


    spec:RegisterPack( "Affliction", 20201024, [[dy09HaqieIhjcAtIiFcHuzuQqCkvi9kvPMLi0Tqizxa9lvsdtv0Xufwgc6zQqnnrGRPkrBtev(MQK04OiLZHqkRtev18Oi5EQQ2hfXbvLuluLYdvLenrksvxuvs4KuKkTskQzIqQ6MIOKDQc(jfPIHkIIwQik8urnvrYxfrvSxf)LQgSehMyXi6XqnzjDzuBgWNvrJwv50cVwLy2qUnvSBP(TsdNchxeLA5GEoLMoPRtL2UkvFhbgViQsNhHA9Qsy(Iu7hPNhtQjxfLNde(KWNpEsycaFAAj4bHpMSsSbpzdbFro5j3Idp5xdaGcSgBpzdHy0k1j1KTRleZt(tvdBY)61Zq)CjbXRZvB44Ien2gdfa9QnCWxNmPBGut3EiNCvuEoq4tcF(4jHja8PPLGhpjCYwdgphim5E5K)IAL7HCYv2INCcPLxdaGcSgBtljpceT4luZjKwmDW6sYqAHWeKiTq4tcFsntnNqA5v(j9jBt(uZjKwikA511kxPLSbJq0cr)IVasnNqAHOOLxxRCLwm9891fsljl5mWGuZjKwikA511kxPfsilxWFs3mIwq7zGPfGfslMEOenTKxxei1CcPfIIwsralxOLKLGyGatljdXqDHmTG2Zatl6sleSWl0saqleVUeDqMwCcRn6tArOfvqCR0s00I(jkTaxcaPMtiTqu0YROfsetljdXXqALwEnaakWASTLwsM3tM0IkiUvWjBaxGaXtoH0YRbaqbwJTPLKhbIw8fQ5eslMoyDjziTqycsKwi8jHpPMPMtiT8k)K(KTjFQ5eslefT86ALR0s2GriAHOFXxaPMtiTqu0YRRvUslME((6cPLKLCgyqQ5eslefT86ALR0cjKLl4pPBgrlO9mW0cWcPftpuIMwYRlcKAoH0crrlPiGLl0sYsqmqGPLKHyOUqMwq7zGPfDPfcw4fAjaOfIxxIoitloH1g9jTi0IkiUvAjAAr)eLwGlbGuZjKwikA5v0cjIPLKH4yiTslVgaafyn22sljZ7jtArfe3ki1m1SG1yBlObKXRdPO)amYxxNOfn2oXa4xdh2KNjredwbfuCNtIiKUaaGNWWzdi7xaVvWWaiWmORb1SG1yBlObKXRdPOV)VADDC22BWk1SG1yBlObKXRdPOV)VEcdNnGSFb8wbddGaZjga)QG4wbpHHZgq2VaERGHbqGzqUfsexPMfSgBBbnGmEDif99)vxl7dLDsSfh(xEH9tGI1dST6xaVXsadPMfSgBBbnGmEDif99)vlZv)c4Xle6AOX2jga)wdgH8Qapz1cAzU6xapEHqxdn22llBY)Xjreoz7gggCf8rYr0o(rcOMfSgBBbnGmEDif99)1pXTvQzbRX2wqdiJxhsrF)F1(j1Lap5I0edGFIOcIBf8tCBfKBHeX1KSgmc5vbEYQf0YC1VaE8cHUgASTxw2uhNer4KTByyWvWhjhr74hjGAMAoH0YRi5LXUkxPf(odjMw0WHPf9JPfbRlKwclTi3LajKigKAwWAST93AWiKhT4luZcwJTTV)Vw57Rl07iNbMAwWAST99)vJpP11XBJ(0fjWqjMAwWAST99)17bI9QeTMya8BxxK3(jWQjpOMfSgBBF)F1ggFB7rbaNya8dzaiB)esetnlyn22(()QCUnXjga)qgaY2pHeXuZcwJTTV)V62wvirSxaaqbwJTtma(fSg3zFDvq32QcjI9caakWAS9)Z0P1aFj6ZKGmaKTFcjIPMfSgBBF)F1TTQqIyVaaGcSgBNya8Rb(s0NjjVGHHYGyXILA0NESGeNqjgKBHeX1KiDbaaXIfl1Op9ybjoHsmiKDKOTM6yQzbRX223)xDBRkKi2laaOaRX2jIjgJyVkWtwT)psma(jIg4lrFMKXDdvqCRGqXXqA1laaOaRX2wqUfsextsWACN91vbDBRkKi2laaOaRX2M6yQzbRX223)xTmx9lGhVqORHgBNya8BnyeYRc8KvlOL5QFb84fcDn0yBtimPJuxfeVqORHgBdczaiB)eseNoTG14o7RRcIxi01qJTnLG14o75MDc2EuQzbRX223)xXle6AOX2jIjgJyVkWtwT)psma(Tgmc5vbEYQf0YC1VaE8cHUgASTPoojidaz7NqIyQzbRX223)x)e3wPMfSgBBF)FfliKxWASThfwnXwC4)QaVCIei7nGSrIbWpExuDjObTUooB7Rc8YjsGmiKDKOTMIWKosDvqJpP11XBJ(0fjWqjgeYos0wtimDAIOcIBf04tADD82OpDrcmuIb5wirC9OuZcwJTTV)Vwf4fVDDrjga)4Dr1LGg0664STVkWlNibYGq2rI2AIgoSxxFnyQzbRX223)xXcc5fSgB7rHvtSfh(hVlQUe0wQzbRX223)xDTSpu2Xsnlyn22(()QJGyGa7HIH6c5edG)6QG3de7vjAfud8LOptNgVlQUe0G3de7vjAfeYos0wtE8mDA76I82pbw)Fj1SG1yB77)RocIbcShkgQlKtma(vbXTcA8jTUoEB0NUibgkXGClKiUM0rQRcA8jTUoEB0NUibgkXGAGVe9z604Dr1LGg04tADD82OpDrcmuIbHSJeT1KheMoTDDrE7NaRMC8rPMfSgBBF)F1rqmqG9qXqDHCIbW)riIkiUvW7bI9QeTcYTqI4Aserfe3kOXN0664TrF6IeyOedYTqI46rPMfSgBBF)FTcLO9OaGtma(jDbaaJMVhQqIyFLDcldAvbFXKJFsnlyn22(()Afkr7rbaNya8t6caagnFpuHeX(k7ew2lVa0Qc(Ijh)KAwWAST99)1kuI2BxxuI4pj6)hjgTYqORH6dhhUgIY)psmALHqxd1ha)AGVyn5NqQzbRX223)xTFsDjWtUiLAMAwWASTfeVlQUe02FcwiQENJ2dz72sJzQzbRX2wq8UO6sqBF)F1HDwiX(fWJCXr1xHS4yPMfSgBBbX7IQlbT99)vs0Uv)c41p2Zn7qm1SG1yBliExuDjOTV)VE6kWAiTFb8Yly4QFuZcwJTTG4Dr1LG2(()kmmmqSpAV1qWm1SG1yBliExuDjOTV)VcSyxlx9YlyyOSNKfhQzbRX2wq8UO6sqBF)F1Wfgaeh9PNejwLAwWASTfeVlQUe023)xHSye9PhajoSnXa4xf4jRGFSG0pVbwnX0EMoTkWtwb)ybPFEdSAkcFMoTkWtwb1WH966nWQNWNMKGNPtdeNFQhYos0wtr4tQzbRX2wq8UO6sqBF)FfVnMBfkkx9aiXHPMfSgBBbX7IQlbT99)v9J9Un562vpWcXCIbWpPlaaiKXxqS16bwiMbHSJeTLAwWASTfeVlQUe023)xT41fg9Pxd9JPMfSgBBbX7IQlbT99)1WXG7A0NESOIvHRXhtnlyn22cI3fvxcA77)R21f5HRMya8FesxaaWO57HkKi2xzNWYGwvWxm5ytlDAbRXD2Zn7eS1KhhLAwWASTfeVlQUe023)xRmoCen6tp5I0edG)JOc8KvWpwq6N3aRM6LptNgio)upKDKOTM8YNhLAMAwWASTfSkWlNibYEdiB8FpqSxLOvQzbRX2wWQaVCIei7nGSX7)RvbEXBxxe1SG1yBlyvGxorcK9gq249)vJvJTPMfSgBBbRc8YjsGS3aYgV)VceqMeTBLAwWASTfSkWlNibYEdiB8()kjA3QhWfsm1SG1yBlyvGxorcK9gq249)vsgAz4LOpPMfSgBBbRc8YjsGS3aYgV)VADDC22xf4LtKa5edGFbRXD2xxf8EGyVkrRM8mDAbRXD2xxf04tADD82OpDrcmuIn5z60QG4wbTlbE9J9wMRwqUfsextN(ierfe3k49aXEvIwb5wirCnjIOcIBf04tADD82OpDrcmuIb5wirC9Ot(odTX2ZbcFs4Zhpj85KjqGD0N2jB66ySqLR0scOfbRX20ckSQfKAEYOWQ2j1KX7IQlbTDsnhEmPMSG1y7jtWcr17C0EiB3wAmpzUfsexNBJohiCsnzbRX2t2HDwiX(fWJCXr1xHS4yNm3cjIRZTrNdhpPMSG1y7jtI2T6xaV(XEUzhINm3cjIRZTrNdjysnzbRX2t(0vG1qA)c4LxWWv)Mm3cjIRZTrNdVCsnzbRX2tggggi2hT3AiyEYClKiUo3gDoKCtQjlyn2EYal21YvV8cggk7jzXzYClKiUo3gDo8QtQjlyn2EYgUWaG4Op9KiXQtMBHeX152OZbtBsnzUfsexNBtgddLHHmzvGNSc(Xcs)8gyLwmHwmTN0s600IkWtwb)ybPFEdSslMIwi8jTKonTOc8KvqnCyVUEdS6j8jTycTKGN0s600cqC(PEi7irBPftrle(CYcwJTNmKfJOp9aiXHTJohiAtQjlyn2EY4TXCRqr5Qhajo8K5wirCDUn6C4XZj1K5wirCDUnzmmuggYKjDbaaHm(cITwpWcXmiKDKOTtwWAS9K1p272KRBx9aleZJohE8ysnzbRX2t2Ixxy0NEn0pEYClKiUo3gDo8GWj1KfSgBp5WXG7A0NESOIvHRXhpzUfsexNBJohEC8KAYClKiUo3MmggkddzYhHwiDbaaJMVhQqIyFLDcldAvbFHwmHwo20OL0PPfbRXD2Zn7eSLwmHwEqlhDYcwJTNSDDrE4QJohEKGj1K5wirCDUnzmmuggYKpcTOc8KvWpwq6N3aR0IPOLx(KwsNMwaIZp1dzhjAlTycT8YN0YrNSG1y7jxzC4iA0NEYfPJo6KRc8YjsGS3aYgtQ5WJj1KfSgBp57bI9QeTozUfsexNBJohiCsnzbRX2tUkWlE76IMm3cjIRZTrNdhpPMSG1y7jBSAS9K5wirCDUn6CibtQjlyn2EYabKjr7wNm3cjIRZTrNdVCsnzbRX2tMeTB1d4cjEYClKiUo3gDoKCtQjlyn2EYKm0YWlrFozUfsexNBJohE1j1K5wirCDUnzmmuggYKfSg3zFDvW7bI9QeTslMqlpPL0PPfbRXD2xxf04tADD82OpDrcmuIPftOLN0s600IkiUvq7sGx)yVL5QfKBHeXvAjDAA5i0crOfvqCRG3de7vjAfKBHeXvAjjAHi0IkiUvqJpP11XBJ(0fjWqjgKBHeXvA5OtwWAS9KTUooB7Rc8YjsG8OJo5kdiUiDsnhEmPMSG1y7jBnyeYJw8LjZTqI46CB05aHtQjlyn2EYv((6c9oYzGNm3cjIRZTrNdhpPMSG1y7jB8jTUoEB0NUibgkXtMBHeX152OZHemPMm3cjIRZTjJHHYWqMSDDrE7NaR0Ij0YJjlyn2EY3de7vjAD05WlNutMBHeX152KXWqzyitgYaq2(jKiEYcwJTNSnm(22JcaE05qYnPMm3cjIRZTjJHHYWqMmKbGS9tir8KfSgBpz5CBIhDo8QtQjZTqI46CBYyyOmmKjlynUZ(6QGUTvfse7faauG1yBA5NwEslPttlAGVe9jTKeTazaiB)esepzbRX2t2TTQqIyVaaGcSgBp6CW0MutMBHeX152KXWqzyitwd8LOpPLKOf5fmmugelwSuJ(0JfK4ekXGClKiUsljrlKUaaGyXILA0NESGeNqjgeYos0wAXu0YXtwWAS9KDBRkKi2laaOaRX2JohiAtQjZTqI46CBYcwJTNSBBvHeXEbaafyn2EYyyOmmKjteArd8LOpPLKOfJ7gQG4wbHIJH0QxaaqbwJTTGClKiUsljrlcwJ7SVUkOBBvHeXEbaafyn2MwmfTC8KXeJrSxf4jR25WJrNdpEoPMm3cjIRZTjJHHYWqMS1GriVkWtwTGwMR(fWJxi01qJTPftOfcPLKOLJql1vbXle6AOX2GqgaY2pHeX0s600IG14o7RRcIxi01qJTPftrlcwJ7SNB2jylTC0jlyn2EYwMR(fWJxi01qJThDo84XKAYClKiUo3MSG1y7jJxi01qJTNmggkddzYwdgH8Qapz1cAzU6xapEHqxdn2MwmfTCmTKeTazaiB)esepzmXye7vbEYQDo8y05WdcNutwWAS9K)e3wNm3cjIRZTrNdpoEsnzUfsexNBtgddLHHmz8UO6sqdADDC22xf4LtKazqi7irBPftrlesljrlhHwQRcA8jTUoEB0NUibgkXGq2rI2slMqleslPttleHwubXTcA8jTUoEB0NUibgkXGClKiUslhDYcwJTNmwqiVG1yBpkS6KrHv9T4WtUkWlNibYEdiBm6C4rcMutMBHeX152KXWqzyitgVlQUe0GwxhNT9vbE5ejqgeYos0wAXeArdh2RRVg8KfSgBp5QaV4TRlA05WJxoPMm3cjIRZTjlyn2EYybH8cwJT9OWQtgfw13Idpz8UO6sqBhDo8i5MutwWAS9KDTSpu2XozUfsexNBJohE8QtQjZTqI46CBYyyOmmKjxxf8EGyVkrRGAGVe9jTKonTG3fvxcAW7bI9QeTcczhjAlTycT84jTKonTyxxK3(jWkT8tlVCYcwJTNSJGyGa7HIH6c5rNdpmTj1K5wirCDUnzmmuggYKvbXTcA8jTUoEB0NUibgkXGClKiUsljrlhHwQRcA8jTUoEB0NUibgkXGAGVe9jTKonTG3fvxcAqJpP11XBJ(0fjWqjgeYos0wAXeA5bH0s600IDDrE7NaR0Ij0YX0YrNSG1y7j7iigiWEOyOUqE05WdI2KAYClKiUo3MmggkddzYhHwicTOcIBf8EGyVkrRGClKiUsljrleHwubXTcA8jTUoEB0NUibgkXGClKiUslhDYcwJTNSJGyGa7HIH6c5rNde(CsnzUfsexNBtgddLHHmzsxaaWO57HkKi2xzNWYGwvWxOftOLJFozbRX2tUcLO9OaGhDoq4Jj1K5wirCDUnzmmuggYKjDbaaJMVhQqIyFLDcl7LxaAvbFHwmHwo(5KfSgBp5kuI2JcaE05aHeoPMm3cjIRZTjlyn2EYvOeT3UUOjhTYqORH6dGjRb(I1KFcNC0kdHUgQpCC4Aikp5htg)jrp5hJohi84j1KfSgBpz7Nuxc8KlsNm3cjIRZTrhDYgqgVoKIoPMdpMutMBHeX152KXWqzyitwdhMwmHwEsljrleHwmyfuqXDMwsIwicTq6caaEcdNnGSFb8wbddGaZGUgtwWAS9KbyKVUorlAS9OZbcNutwWAS9KTUooB7by0NBRmCYClKiUo3gDoC8KAYClKiUo3MmggkddzYQG4wbpHHZgq2VaERGHbqGzqUfsexNSG1y7jFcdNnGSFb8wbddGaZJohsWKAYClKiUo3MClo8KLxy)eOy9aBR(fWBSeWWjlyn2EYYlSFcuSEGTv)c4nwcy4OZHxoPMm3cjIRZTjJHHYWqMS1GriVkWtwTGwMR(fWJxi01qJT9YY0Ij)0YX0ss0crOfoz7gggCfuEH9tGI1dST6xaVXsadNSG1y7jBzU6xapEHqxdn2E05qYnPMSG1y7j)jUTozUfsexNBJohE1j1K5wirCDUnzmmuggYKjcTOcIBf8tCBfKBHeXvAjjAXAWiKxf4jRwqlZv)c4Xle6AOX2EzzAXu0YX0ss0crOfoz7gggCfuEH9tGI1dST6xaVXsadNSG1y7jB)K6sGNCr6OJo6Kfx9BHtohoVYrhDg]] )


end