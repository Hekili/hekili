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

        -- Can't trust Agony stacks/duration to refresh.
        local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 980 )
        if name then
            debuff.agony.expires = expires
            debuff.agony.duration = duration
            debuff.agony.applied = max( 0, expires - duration )
            debuff.agony.count = expires > 0 and max( 1, count ) or 0
            debuff.agony.caster = caster
        else
            debuff.agony.expires = 0
            debuff.agony.duration = 0
            debuff.agony.applied = 0
            debuff.agony.count = 0
            debuff.agony.caster = "nobody"
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

    spec:RegisterStateExpr( "can_seed", function ()
        local seed_targets = min( active_enemies, Hekili:GetNumTTDsAfter( action.seed_of_corruption.cast + ( 6 * haste ) ) )
        if active_dot.seed_of_corruption < seed_targets - ( state:IsInFlight( "seed_of_corruption" ) and 1 or 0 ) then return true end
        return false
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
            nomounted = true,
            
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
            
            impact = function ()
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


    spec:RegisterPack( "Affliction", 20201108, [[du053aqiHspcjuBcj6tQcvzukH6ukH8ka1SqsULsq2Ls9lazycfhdaltq6zQcMMQqUMsGTPeuFtqqJtqKZHeI1jiQAEib3tvzFiPoOQqzHa0dfevMisi5IQcvCsbrjRuOAMQcv6MccyNkrdvquSuKqQNkQPQk6RQcv1Ev8xIgSuDyulgPEmHjlYLH2mqFwknAvvNMQxRKmBq3wGDl53QmCP44cc0Yr8CkMoPRlKTRK67QsnEbrPoVQK1li08fu7NspampNCIvCwgAmHgdaaetiTJHIe6JE4HjRVAWj3WIvClo5IdWj)yGGqxO(vtUHFbponpNS5IicCY)Q2yc5bcOwx)JO3IlaiJhebz1VsqyqfiJhiaAY0roudzvd9KtSIZYqJj0yaaGycPDmueawqmlyYMgumldDHxWK)9ucRHEYj0iMmfB7pgii0fQFLT)4Ze4jwzJtX2(YBngqJeBpKOY2dnMqJXg3gNIT9qUFUArtiVnofB7lKT)yPeMS9CdcH2(J7jwTTXPyBFHS9hlLWKTtrHRViIThcWTUyBJtX2(cz7pwkHjBNMG8kXpxfcTD416cBh8i2offH9Y2ZxeCBJtX2(cz7pFJ8kBpeGHiOlSDkAUrJiOTdVwxy76z7VpYkB3bT9xx0JhbT9a3y8Q12zBxziwQT7LTR)SA7K792gNIT9fY2FCkMgI2ofnh0WLA7pgii0fQFLX2dzwhYy7kdXs3tUHCGoeNmfB7pgii0fQFLT)4Ze4jwzJtX2(YBngqJeBpKOY2dnMqJXg3gNIT9qUFUArtiVnofB7lKT)yPeMS9CdcH2(J7jwTTXPyBFHS9hlLWKTtrHRViIThcWTUyBJtX2(cz7pwkHjBNMG8kXpxfcTD416cBh8i2offH9Y2ZxeCBJtX2(cz7pFJ8kBpeGHiOlSDkAUrJiOTdVwxy76z7VpYkB3bT9xx0JhbT9a3y8Q12zBxziwQT7LTR)SA7K792gNIT9fY2FCkMgI2ofnh0WLA7pgii0fQFLX2dzwhYy7kdXs32424Sq9Rm7gckUaAw)arOmDbEXQFfvo4N6bi1XqzSnOUzOVgPmw6iqWDlXdoNGYduAybXbDbUJASXzH6xz2neuCb0Sc8hqMOGGRKnOAJZc1VYSBiO4cOzf4pGAjEW5euEGsdlioOlqQCWpLHyP7wIhCobLhO0WcId6cCJftdXKnolu)kZUHGIlGMvG)akYGsxXaQkoa)4q08Ze2ibVsLhOS5EJeBCwO(vMDdbfxanRa)bKbXK8aLIJqIAu)kQCWptdcHsLjTOA2getYdukocjQr9RK8Hu)9aLXIHGrEtdM2aSWuKha4r24Sq9Rm7gckUaAwb(dOFoQuBCwO(vMDdbfxanRa)bK5Nt3Bj9bvQCWVyvgILU)5Os3yX0qmrPPbHqPYKwunBdIj5bkfhHe1O(vs(qk8aLXIHGrEtdM2aSWuKha4r2424uST)4eYgfrkMSDCnsEz7QhG2U(J2ol0Jy7UX251SdzAiUTXzH6xz(mniekHNyLnolu)kdWFaLW1xergWTUWgNfQFLb4pGemekzH6xjHUrPQ4a8JpKkh8JfQVgLyHboAO(bBCwO(vgG)aQ5Nl9cKgVAJGmX1x24Sq9Rma)be3E1lQCWpccsqZptdrBCwO(vgG)aIBV6fvIxcikvM0IQ5daQCWpwO(AuIfg4OHAaOszslQsh8JGGe08Z0q0gNfQFLb4pGemekzH6xjHUrPQ4a8lXKvTqMGYgc2qLd(Xc1xJsSWahnuhkLI7GP7DTnrbbxjtmzvlKj4MGC6fLloD6U5Nl9cKgVAJGmX1xB1fR8QnC4yvgILUB(5sVaPXR2iitC91glMgIPfzJZc1VYa8hqgetYdukocjQr9ROYb)yH6RrjwyGJgQdLYyvgILUx7quQSx6glMgIjkxCSkdXs3VjU(JsVKC7vV2yX0qmfoSYqS0T5El1FuAqmz2yX0qmTikJnD62GysEGsXrirnQF1wDXkVAPmwVKGqV9xPmD6wCesuJ6xTjiibn)mneTXzH6xza(dO1oeLk7LsLd(TyZfbLMFMKOgGWHzH6RrjwyGJgQdDrukUdMU312efeCLmXKvTqMGBcgWEzOgGqTXzH6xza(diJ38FLe6Givo4hbbjO5NPHOnolu)kdWFafvgLPHOKbbHUq9ROYb)yH6Rrz60DuzuMgIsgee6c1V6lMWHvxSYRwkjiibn)mneTXzH6xza(dOOYOmneLmii0fQFfvo4N6IvE1sjhIiXvClyJGtE1kfmKdC91glMgIjkPJab3c2i4KxTsbd5axFTjya7LHcpyJZc1VYa8hqIJqIAu)kQCWVfZc1xJsSWahnu4HWHvgILUx7quQSx6glMgIPWHvgILUFtC9hLEj52RETXIPHyIYyvgILUn3BP(JsdIjZglMgIPfrjbbjO5NPHOnolu)kdWFa9ZrLAJZc1VYa8hqbmebDHKWnAebPYb)mxeuA(zsI6hzJZc1VYa8hqgV5)kj0brQeVequQmPfvZhau5GFSq91OelmWrd1aqLYKwuLo4x60TXB(VscDqCtWa2ldfEWgNfQFLb4pGehHe1O(vujEjGOuzslQMpaOYb)yH6RrjwyGJgk8q4WkdXs3RDikv2lDJftdXu4WkdXs3VjU(JsVKC7vV2yX0qmrzSkdXs3M7Tu)rPbXKzJftdXevktArv6GFPt3IJqIAu)QnbdyVmu4bBCwO(vgG)asWqOKfQFLe6gLQIdWVetw1czckBiydvo4N4oy6ExBtuqWvYetw1czcUjya7LHcHs5ItNUB(5sVaPXR2iitC91MGbSxgQdnC4yvgILUB(5sVaPXR2iitC91glMgIPfzJZc1VYa8hqjMSsAUiivo4N4oy6ExBtuqWvYetw1czcUjya7LHA1dqPEYKJ24Sq9Rma)bKGHqjlu)kj0nkvfhGFI7GP7DzSXzH6xza(dOidkDfdm24Sq9Rma)bKGHqjlu)kj0nkvfhGFgKkh8lH0rGGBZpNU3smGMWcCBuwSIcl(HfIfQF128ZP7TK(G62lji0B)1ffoCcPJab3MFoDVLyanHf4MGbSxgk8Gnolu)kdWFafWqe0fsc3OreKkh8lD6ETdrPYEPB1fR8QnCyXDW09U2RDikv2lDtWa2ld1aet4WMlckn)mj9TaBCwO(vgG)akGHiOlKeUrJiivo4NYqS0DZpx6finE1gbzIRV2yX0qmr5ItNUB(5sVaPXR2iitC91wDXkVAdhwChmDVRDZpx6finE1gbzIRV2emG9YqnaHgoS5IGsZptsu)WISXzH6xza(dOagIGUqs4gnIGu5GFlowLHyP71oeLk7LUXIPHyIYyvgILUB(5sVaPXR2iitC91glMgIPfzJZc1VYa8hqjc7Le6Givo4hDei42lCTRmneLjmWn42OSyf1pet4W0rGGBVW1UY0quMWa3G7OgkvpaL6jtosHfyJZc1VYa8hqjc7Le6Givo4hDei42lCTRmneLjmWnOKdXTrzXkQFiMWHPJab3EHRDLPHOmHbUbLCiUJAOu9auQNm5ifwGnolu)kdWFaLiSxsZfbPs8ZE9bavEPiHe1OspiatoR4hau5LIesuJkDWp1fRmu)fQnolu)kdWFaz(509wsFq1ghyB3gNfQFLzZh(18ZLEbsJxTrqM46lBCwO(vMnFiWFa9ZrLAJZc1VYS5db(didIj5bkfhHe1O(vu5GFkdXs3M7Tu)rPbXKzJftdXeLcUKget24Sq9RmB(qG)aYGysEGsXrirnQFfvo4xSkdXs3M7Tu)rPbXKzJftdXeLXMoDBqmjpqP4iKOg1VARUyLxTugRxsqO3(RuMoDlocjQr9R2eeKGMFMgI24Sq9RmB(qG)aIBV6fvIxcikvM0IQ5daQCWpwO(AuMoDZTx9I6VhrLYKwuLo4hbbjO5NPHiLPt3C7vV2Qlw5vRnolu)kZMpe4pG42RErL4LaIsLjTOA(aGkh8JfQVgLPt3C7vVOWJOszslQsh8l20PBU9QxB1fR8Q1gNfQFLzZhc8hqrLrzAikzqqOlu)kQCWpwO(AuMoDhvgLPHOKbbHUq9R(IjCy1fR8QLsccsqZptdrBCwO(vMnFiWFafvgLPHOKbbHUq9ROs8sarPYKwunFaqLd(fR6IvE1szZ6gLHyPBch0WLkzqqOlu)kZglMgIjkzH6Rrz60DuzuMgIsgee6c1VIcpyJZc1VYS5db(dO1oeLk7LsLd(zUiO08ZKe1ayJZc1VYS5db(dibdHswO(vsOBuQkoa)smzvlKjOSHGnu5GFI7GP7DTnrbbxjtmzvlKj4MGC6fLloD6U5Nl9cKgVAJGmX1xBcgWEzOo0WHJvziw6U5Nl9cKgVAJGmX1xBSyAiMwKnolu)kZMpe4pGsmzL0CrqQCWpXDW09U2MOGGRKjMSQfYeCtWa2ld1QhGs9KjhTXzH6xz28Ha)buKbLUIbgBCwO(vMnFiWFafWqe0fsc3OreKkh8lD6ETdrPYEPB1fR8Q1gNfQFLzZhc8hqbmebDHKWnAebPYb)Ivziw6ETdrPYEPBSyAiMSXzH6xz28Ha)bKXB(VscDqKkXlbeLktAr18bavo4hluFnktNUnEZ)vsOdIu47bQuM0IQ0b)InD624n)xjHoiUvxSYRwBCwO(vMnFiWFaLiSxsOdIu5GF0rGGBVW1UY0quMWa3GBJYIvu)TGychMoceC7fU2vMgIYeg4gCh1qP6bOupzYrkSaBCwO(vMnFiWFaLiSxsZfbTXzH6xz28Ha)bK5Nt3Bj9bvBCBCwO(vMT4oy6ExMV3hbMwJEjjO5kUeOnolu)kZwChmDVldWFafGbh5L8aLWiHNKjcYbgBCwO(vMT4oy6ExgG)aIgExsEGs9hLyHbVSXzH6xz2I7GP7Dza(dO2iMKCUKhOKdrKC6Vnolu)kZwChmDVldWFar8Mgik9sAAybAJZc1VYSf3bt37Ya8hqGNiYGjjhIiXvusJCGnolu)kZwChmDVldWFa1erCWxE1kPHSrTXzH6xz2I7GP7Dza(dicYnE1kbHCaAOYb)uM0I6(hzO(lBek1HumHdRmPf19pYq9x2iukeAmHdRmPf1T6bOupzJqLHgd1pkMWHb92FvsWa2ldfcngBCwO(vMT4oy6ExgG)asCLalLWkMKGqoaTXzH6xz2I7GP7Dza(di9hLrf9fvjj4reivo4hDei4MGIvq0yKGhrGBcgWEzSXzH6xz2I7GP7Dza(diJ4IiE1kvx)rBCwO(vMT4oy6ExgG)aYdAWk5vRuWkBuY18J24Sq9RmBXDW09Uma)bK5IGsYPu5GFlMoceC7fU2vMgIYeg4gCBuwSI6hcPWHzH6RrjwyGJgQbyr24Sq9RmBXDW09Uma)bucfEaRE1kPpOsLd(TyLjTOU)rgQ)YgHsHfet4WGE7Vkjya7LH6feZISXTXzH6xz2jMSQfYeu2qWMV1oeLk7LAJZc1VYStmzvlKjOSHGna)buIjRKMlcAJZc1VYStmzvlKjOSHGna)buZP(v24Sq9Rm7etw1czckBiydWFab6eKgExYgNfQFLzNyYQwitqzdbBa(diA4Djjye5Lnolu)kZoXKvTqMGYgc2a8hq0iXGKvE1AJZc1VYStmzvlKjOSHGna)bKjki4kzIjRAHmbPYb)yH6Rrz609AhIsL9sPoMWHzH6Rrz60DZpx6finE1gbzIRVOoMWHvgILUn3BP(JsdIjZglMgIPWHxCSkdXs3RDikv2lDJftdXeLXQmelD38ZLEbsJxTrqM46RnwmnetlYg3gNfQFLzBWVFoQuBCwO(vMTbb(dOeH9sAUiivEPiHe1Osh8lH0rGGBZpNU3smGMWcCBuwSI6VhSXzH6xz2ge4pGm)C6ElPpOo51iX4xnldnMqJbGyc9rBaM8BMuE1AMCiRGMJOyY2xyBNfQFLTdDJA224tg6g1mpNCIjRAHmbLneSzEolbyEozwO(vtETdrPYEPtglMgIPbWrNLHopNmlu)QjNyYkP5IGtglMgIPbWrNLpmpNmlu)Qj3CQF1KXIPHyAaC0z5JMNtMfQF1KbDcsdVlnzSyAiMgahDwUG55KzH6xnzA4Djjye51KXIPHyAaC0z5cppNmlu)QjtJedsw5v7KXIPHyAaC0zziCEozSyAiMgaNSG4ksCEYSq91OmD6ETdrPYEP2o12Em2E4W2oluFnktNUB(5sVaPXR2iitC9LTtTThJThoSTRmelDBU3s9hLgetMnwmnet2E4W2(IT9yTDLHyP71oeLk7LUXIPHyY2P02J12vgILUB(5sVaPXR2iitC91glMgIjBFrtMfQF1KnrbbxjtmzvlKj4OJo5ecYrqDEolbyEozwO(vt20GqOeEIvtglMgIPbWrNLHopNmlu)QjNW1xergWTUyYyX0qmnao6S8H55KXIPHyAaCYSq9RMSGHqjlu)kj0n6KfexrIZtMfQVgLyHboASDQT9hMm0nQS4aCY8HJolF08CYSq9RMCZpx6finE1gbzIRVMmwmnetdGJolxW8CYyX0qmnaozbXvK48Kjiibn)mneNmlu)QjZTx9A0z5cppNmwmnetdGtMfQF1K52REnzXlbeLktAr1mlbyYcIRiX5jZc1xJsSWahn2o12oatwzslQshCYeeKGMFMgIJoldHZZjJftdX0a4KzH6xnzbdHswO(vsOB0jliUIeNNmluFnkXcdC0y7uB7HA7uA7I7GP7DTnrbbxjtmzvlKj4MGC6LTtPTVyBpD6U5Nl9cKgVAJGmX1xB1fR8Q12dh22J12vgILUB(5sVaPXR2iitC91glMgIjBFrtg6gvwCao5etw1czckBiyZOZYqAEozSyAiMgaNSG4ksCEYSq91OelmWrJTtTThQTtPThRTRmelDV2HOuzV0nwmnet2oL2(IT9yTDLHyP73ex)rPxsU9QxBSyAiMS9WHTDLHyPBZ9wQ)O0GyYSXIPHyY2xKTtPThRTNoDBqmjpqP4iKOg1VARUyLxT2oL2ES2UxsqO3(R2oL2E60T4iKOg1VAtqqcA(zAiozwO(vt2GysEGsXrirnQF1OZskY8CYyX0qmnaozbXvK48KxSTBUiO08ZKKTtTTdGThoSTZc1xJsSWahn2o12EO2(ISDkTDXDW09U2MOGGRKjMSQfYeCtWa2lJTtTTdqOtMfQF1Kx7quQSx6OZsaIzEozSyAiMgaNSG4ksCEYeeKGMFMgItMfQF1KnEZ)vsOdIJolbaG55KXIPHyAaCYcIRiX5jZc1xJY0P7OYOmneLmii0fQFLT)z7Xy7HdB7Qlw5vRTtPTtqqcA(zAiozwO(vtoQmktdrjdccDH6xn6SeGqNNtglMgIPbWjliUIeNNS6IvE1A7uA7CiIexXTGnco5vRuWqoW1xBSyAiMSDkTD6iqWTGnco5vRuWqoW1xBcgWEzSDky7pmzwO(vtoQmktdrjdccDH6xn6SeGhMNtglMgIPbWjliUIeNN8ITDwO(AuIfg4OX2PGT)GThoSTRmelDV2HOuzV0nwmnet2E4W2UYqS09BIR)O0lj3E1Rnwmnet2oL2ES2UYqS0T5El1FuAqmz2yX0qmz7lY2P02jiibn)mneNmlu)QjlocjQr9RgDwcWJMNtMfQF1K)5OsNmwmnetdGJolbybZZjJftdX0a4KfexrIZt2CrqP5NjjBNAB)rtMfQF1Kdyic6cjHB0ico6SeGfEEozSyAiMgaNmlu)QjB8M)RKqheNS4LaIsLjTOAMLamzbXvK48KzH6RrjwyGJgBNABhGjRmPfvPdo50PBJ38FLe6G4MGbSxgBNc2(dJolbieopNmwmnetdGtMfQF1KfhHe1O(vtw8sarPYKwunZsaMSG4ksCEYSq91OelmWrJTtbB)bBpCyBxziw6ETdrPYEPBSyAiMS9WHTDLHyP73ex)rPxsU9QxBSyAiMSDkT9yTDLHyPBZ9wQ)O0GyYSXIPHyAYktArv6GtoD6wCesuJ6xTjya7LX2PGT)WOZsacP55KXIPHyAaCYSq9RMSGHqjlu)kj0n6KfexrIZtwChmDVRTjki4kzIjRAHmb3emG9Yy7uW2d12P02xSTNoD38ZLEbsJxTrqM46RnbdyVm2o12EO2E4W2ES2UYqS0DZpx6finE1gbzIRV2yX0qmz7lAYq3OYIdWjNyYQwitqzdbBgDwcafzEozSyAiMgaNSG4ksCEYI7GP7DTnrbbxjtmzvlKj4MGbSxgBNABx9auQNm54KzH6xn5etwjnxeC0zzOXmpNmwmnetdGtMfQF1KfmekzH6xjHUrNm0nQS4aCYI7GP7DzgDwgkaZZjZc1VAYrgu6kgyMmwmnetdGJoldn055KXIPHyAaCYSq9RMSGHqjlu)kj0n6KfexrIZtoH0rGGBZpNU3smGMWcCBuwSY2PGTVyB)bBFHSDwO(vBZpNU3s6dQBVKGqV9xT9fz7HdB7jKoceCB(509wIb0ewGBcgWEzSDky7pmzOBuzXb4Kn4OZYqFyEozSyAiMgaNSG4ksCEYPt3RDikv2lDRUyLxT2E4W2U4oy6Ex71oeLk7LUjya7LX2P22bigBpCyB3CrqP5NjjB)Z2xWKzH6xn5agIGUqs4gnIGJold9rZZjJftdX0a4KfexrIZtwziw6U5Nl9cKgVAJGmX1xBSyAiMSDkT9fB7Pt3n)CPxG04vBeKjU(ARUyLxT2E4W2U4oy6Ex7MFU0lqA8QncYexFTjya7LX2P22biuBpCyB3CrqP5NjjBNAB)bBFrtMfQF1Kdyic6cjHB0ico6Sm0fmpNmwmnetdGtwqCfjop5fB7XA7kdXs3RDikv2lDJftdXKTtPThRTRmelD38ZLEbsJxTrqM46Rnwmnet2(IMmlu)QjhWqe0fsc3OreC0zzOl88CYyX0qmnaozbXvK48KPJab3EHRDLPHOmHbUb3gLfRSDQT9hIX2dh22PJab3EHRDLPHOmHbUb3rn2oL2U6bOupzYrBNc2(cMmlu)QjNiSxsOdIJoldneopNmwmnetdGtwqCfjopz6iqWTx4AxzAiktyGBqjhIBJYIv2o12(dXy7HdB70rGGBVW1UY0quMWa3Gsoe3rn2oL2U6bOupzYrBNc2(cMmlu)QjNiSxsOdIJoldnKMNtglMgIPbWjZc1VAYjc7L0CrWj7LIesuJkDWjRUyLH6VqNSxksirnQ0dcWKZkozaMS4N9AYam6SmukY8CYSq9RMS5Nt3Bj9b1jJftdX0a4OJo5gckUaAwNNZsaMNtglMgIPbWjliUIeNNS6bOTtTThJTtPThRT3G6MH(A02P02J12PJab3Tep4CckpqPHfeh0f4oQzYSq9RMmicLPlWlw9RgDwg68CYSq9RMSjki4kjic)JkfjtglMgIPbWrNLpmpNmwmnetdGtwqCfjopzLHyP7wIhCobLhO0WcId6cCJftdX0KzH6xn5wIhCobLhO0WcId6cC0z5JMNtglMgIPbWjxCaozoen)mHnsWRu5bkBU3izYSq9RMmhIMFMWgj4vQ8aLn3BKm6SCbZZjJftdX0a4KfexrIZt20GqOuzslQMTbXK8aLIJqIAu)kjFOTt9NT)GTtPThRTJHGrEtdM2CiA(zcBKGxPYdu2CVrYKzH6xnzdIj5bkfhHe1O(vJolx455KzH6xn5FoQ0jJftdX0a4OZYq48CYyX0qmnaozbXvK48KJ12vgILU)5Os3yX0qmz7uA7MgecLktAr1SniMKhOuCesuJ6xj5dTDky7py7uA7XA7yiyK30GPnhIMFMWgj4vQ8aLn3BKmzwO(vt28ZP7TK(G6OJozXDW09UmZZzjaZZjZc1VAYVpcmTg9ssqZvCjWjJftdX0a4OZYqNNtMfQF1KdWGJ8sEGsyKWtYeb5aZKXIPHyAaC0z5dZZjZc1VAY0W7sYduQ)Oelm41KXIPHyAaC0z5JMNtMfQF1KBJysY5sEGsoerYP)tglMgIPbWrNLlyEozwO(vtM4nnqu6L00WcCYyX0qmnao6SCHNNtMfQF1KbprKbtsoerIROKg5GjJftdX0a4OZYq48CYSq9RMCteXbF5vRKgYgDYyX0qmnao6SmKMNtglMgIPbWjliUIeNNSYKwu3)id1FzJqTDQT9qkgBpCyBxzslQ7FKH6VSrO2ofS9qJX2dh22vM0I6w9auQNSrOYqJX2P22Fum2E4W2oO3(RscgWEzSDky7HgZKzH6xnzcYnE1kbHCaAgDwsrMNtMfQF1KfxjWsjSIjjiKdWjJftdX0a4OZsaIzEozSyAiMgaNSG4ksCEY0rGGBckwbrJrcEebUjya7LzYSq9RMS(JYOI(IQKe8icC0zjaampNmlu)QjBexeXRwP66pozSyAiMgahDwcqOZZjZc1VAYEqdwjVALcwzJsUMFCYyX0qmnao6SeGhMNtglMgIPbWjliUIeNN8ITD6iqWTx4AxzAiktyGBWTrzXkBNAB)HqY2dh22zH6RrjwyGJgBNABhaBFrtMfQF1KnxeusoD0zjapAEozSyAiMgaNSG4ksCEYl22vM0I6(hzO(lBeQTtbBFbXy7HdB7GE7Vkjya7LX2P22xqm2(IMmlu)QjNqHhWQxTs6dQJo6Kn48CwcW8CYSq9RM8phv6KXIPHyAaC0zzOZZj7LIesuJkDWjNq6iqWT5Nt3BjgqtybUnklwr93dtMfQF1Kte2lP5IGtglMgIPbWrNLpmpNmlu)QjB(509wsFqDYyX0qmnao6OtMpCEolbyEozwO(vtU5Nl9cKgVAJGmX1xtglMgIPbWrNLHopNmlu)Qj)ZrLozSyAiMgahDw(W8CYyX0qmnaozbXvK48KvgILUn3BP(JsdIjZglMgIjBNsBxWL0GyAYSq9RMSbXK8aLIJqIAu)QrNLpAEozSyAiMgaNSG4ksCEYXA7kdXs3M7Tu)rPbXKzJftdXKTtPThRTNoDBqmjpqP4iKOg1VARUyLxT2oL2ES2UxsqO3(R2oL2E60T4iKOg1VAtqqcA(zAiozwO(vt2GysEGsXrirnQF1OZYfmpNmwmnetdGtMfQF1K52REnzXlbeLktAr1mlbyYcIRiX5jZc1xJY0PBU9Qx2o1F2(JMSYKwuLo4Kjiibn)mneTDkT90PBU9QxB1fR8QD0z5cppNmwmnetdGtMfQF1K52REnzXlbeLktAr1mlbyYcIRiX5jZc1xJY0PBU9Qx2ofS9hnzLjTOkDWjhRTNoDZTx9ARUyLxTJoldHZZjJftdX0a4KfexrIZtMfQVgLPt3rLrzAikzqqOlu)kB)Z2JX2dh22vxSYRwBNsBNGGe08Z0qCYSq9RMCuzuMgIsgee6c1VA0zzinpNmwmnetdGtwqCfjop5yTD1fR8Q12P02Bw3OmelDt4GgUujdccDH6xz2yX0qmz7uA7Sq91OmD6oQmktdrjdccDH6xz7uW2FyYSq9RMCuzuMgIsgee6c1VAYIxcikvM0IQzwcWOZskY8CYyX0qmnaozbXvK48KnxeuA(zsY2P22byYSq9RM8AhIsL9shDwcqmZZjJftdX0a4KzH6xnzbdHswO(vsOB0jliUIeNNS4oy6ExBtuqWvYetw1czcUjiNEz7uA7l22tNUB(5sVaPXR2iitC91MGbSxgBNABpuBpCyBpwBxziw6U5Nl9cKgVAJGmX1xBSyAiMS9fnzOBuzXb4KtmzvlKjOSHGnJolbaG55KXIPHyAaCYcIRiX5jlUdMU312efeCLmXKvTqMGBcgWEzSDQTD1dqPEYKJtMfQF1KtmzL0CrWrNLae68CYSq9RMCKbLUIbMjJftdX0a4OZsaEyEozSyAiMgaNSG4ksCEYPt3RDikv2lDRUyLxTtMfQF1Kdyic6cjHB0ico6SeGhnpNmwmnetdGtwqCfjop5yTDLHyP71oeLk7LUXIPHyAYSq9RMCadrqxijCJgrWrNLaSG55KXIPHyAaCYSq9RMSXB(VscDqCYIxcikvM0IQzwcWKfexrIZtMfQVgLPt3gV5)kj0brBNcF2(dtwzslQshCYXA7Pt3gV5)kj0bXT6IvE1o6SeGfEEozSyAiMgaNSG4ksCEY0rGGBVW1UY0quMWa3GBJYIv2o1F2(cIX2dh22PJab3EHRDLPHOmHbUb3rn2oL2U6bOupzYrBNc2(cMmlu)QjNiSxsOdIJolbieopNmlu)QjNiSxsZfbNmwmnetdGJolbiKMNtMfQF1Kn)C6ElPpOozSyAiMgahD0rNmhP)hzYzpiKB0rNb]] )


end