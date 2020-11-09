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


    spec:RegisterPack( "Affliction", 20201108.2, [[dy0H5aqiPOEeqOnPq9jGGyucuDkbkVcinlGQBjaAxQYVaKHjqoMQslta9mfIPPqQRjfPTPqIVPqsJtaY5eGQ1jfrAEar3dG9buoiqGfcOEOuevtuakxukIYjbcQwPuyMabPBkaWovu(jqqzOca1sfa0tLQPQG(QueH9Q0FPyWI6WelgrpgLjlYLH2mcFwrgTQQtt1RvGzd62cA3s(TkdxkDCbGSCKEoLMoPRluBxi(UQIXlfr05vuTEPimFH0(r173D42tII7SadkWG((nOa6fyGFBAGJSDDElU9wHnqMWTxsiUDqabb0zQF12BL5Wts7WTBVykd3(VQT2MuGaAY1)yYh7cbY6HXqr9RyuHqbY6HmG2ozSdvq41sU9KO4olWGcmOVFdkGEbg43Mg42TTiBNf4O00T)7Pewl52tOLTDqKNbbeeqNP(v8CtcHcp2aEdqKNNDrWqsKYZbe48CGbfyq8g8gGip3K)l1eABs5narEoa5zqqkHjEU3Iqipdc9ydE8gGiphG8miiLWephWWixmLNdaKjN94narEoa5zqqkHjEMKIYa2Vufc5z4n5mEM4O8CaJkEXZ9lg(4narEoa55HFqzaphaiqKWz8CaO0QXuKNH3KZ4z945phDap7e888lgecf55q3A9AINfEwfiwkp7fpR)IYZ07ZJ3ae55aKNBYkHeI8CaOe2kLYZGaccOZu)klphahjaMNvbIL(4narEoa55HFqzGLN1JNLiNN4zs49XRjEoGj0btqHI8Sx8Cymu9auf6eQ88hGoEoGbcBOLNJBFBVLEeoe3oiYZGaccOZu)kEUjHqHhBaVbiYZZUiyijs55acCEoWGcmiEdEdqKNBY)LAcTnP8gGiphG8miiLWep3BriKNbHESbpEdqKNdqEgeKsyINdyyKlMYZbaYKZE8gGiphG8miiLWeptsrza7xQcH8m8MCgptCuEoGrfV45(fdF8gGiphG88WpOmGNdaeis4mEoauA1ykYZWBYz8SE88NJoGNDcEE(fdcHI8COBTEnXZcpRcelLN9IN1Fr5z695XBaI8CaYZnzLqcrEoaucBLs5zqabb0zQFLLNdGJeaZZQaXsF8gGiphG88WpOmWYZ6XZsKZt8mj8(41ephWe6GjOqrE2lEomgQEaQcDcvE(dqhphWaHn0YZXTpEdEdHP(v2xlfzxiPOaiqOjDHEjQFf4oba1drWcACZTO(eOhbh3mzmbXBI6HNtrZryScJ6eodFXT8gct9RSVwkYUqsrbfaq24WWRmTOYBim1VY(APi7cjffuaanr9WZPO5imwHrDcNHG7eaubIL(MOE45u0CegRWOoHZWhwcjet8gct9RSVwkYUqsrbfaqreQlKqe8scraPtTgkkP5GhrGXiaHPEe0Ko9XoknUv9RalOXct9iOjD6tMUAoybnwyQhbnPtFXLvfsiAeccOZu)kWcACWBwfiw6Z6T)xzGob(WsiHykAuHPEe0Ko9z92)RmqNablOGno4PtFT)sPxOX61umuOUo)PoBGxtrJ2SkqS0x7Vu6fASEnfdfQRZFyjKqmfmEdHP(v2xlfzxiPOGcaOylACfdbVKqeG0e2FHkwdXvQ5imT3hKYBim1VY(APi7cjffuaazrmzocd7O04w1VcCNaGTfHqJk0juTplIjZryyhLg3Q(vg5qWamY4MXaOyVTftVVJsaFKVJM3qyQFL91sr2fskkOaa6xIlL3qyQFL91sr2fskkOaaY(lP7JH8Gk4obGMvbIL((L4sFyjKqmn22IqOrf6eQ2NfXK5imSJsJBv)kJCiihzCZyauS32IP33rjGpY3rZBWBaI8CtwtsKfRyINXiiDopREiYZ6pYZctpkp7wEwIiouiH4J3qyQFLfGTfHqd8yd4neM6xzbfaqjmYftnHYKZ4neM6xzbfaqmbcnct9Rmq3QGxsicqoeCNaGWupcAWcdD0c2i8gct9RSGcaO2FP0l0y9AkgkuxNZBim1VYckaGKPRMdUtaGIeu0(lKqK3qyQFLfuaajtxnhC2CgenQqNq1c4l4obaHPEe0Gfg6OfSVJPibfT)cje5neM6xzbfaqmbcnct9Rmq3QGxsicij0btqHIMwk2cUtaqyQhbnyHHoAblWXS7GP7t9SXHHxzscDWeuO4JIsA(4ic1fsi(sNAnuusZ5neM6xzbfaqwetMJWWoknUv9Ra3jaim1JGgSWqhTGf44MvbIL(I4q0OIx6dlHeIPXbVzvGyPVpux)rJxgz6Q5pSesiMIgvfiw6ZEFm6pASiMSpSesiMc24MtN(SiMmhHHDuACR6x9uNnWRPXn7LHa6t)640Pp2rPXTQF1JIeu0(lKqK3qyQFLfuaafXHOrfVuWDcab3EXqJ9xOjW(gnQWupcAWcdD0cwGbBm7oy6(upBCy4vMKqhmbfk(OyO4LfSVbYBim1VYckaGSE7)vgOtGG7eaOibfT)cje5neM6xzbfaqXLvfsiAeccOZu)kWDcact9iOjD6lUSQqcrJqqaDM6xbiOOrvNnWRPXuKGI2FHeI8gct9RSGcaO4YQcjencbb0zQFf4oba1zd8AAS0ei1v8XeltsEnzycucDD(dlHeIPXKXeepMyzsYRjdtGsORZFumu8YcYr4neM6xzbfaqSJsJBv)kWDcabxyQhbnyHHoAb5irJQcel9fXHOrfV0hwcjetrJQcel99H66pA8Yitxn)HLqcX04MvbIL(S3hJ(JglIj7dlHeIPGnMIeu0(lKqK3qyQFLfuaa9lXLYBim1VYckaGcfis4mdvA1ykcUtaWEXqJ9xOjWgnVHWu)klOaaY6T)xzGobcoBodIgvOtOAb8fCNaGWupcAWcdD0c23XPtFwV9)kd0jWhfdfVSGCeEdHP(vwqbae7O04w1VcC2CgenQqNq1c4l4obakgkEzb5iJdUWupcAWcdD0cYrIgvfiw6lIdrJkEPpSesiMIgvfiw67d11F04LrMUA(dlHeIPXnRcel9zVpg9hnwet2hwcjetbJ3qyQFLfuaaXei0im1VYaDRcEjHiGKqhmbfkAAPyl4oba2DW09PE24WWRmjHoycku8rXqXllidCCeH6cjeFPtTgkkP58gct9RSGcaOKqhySxmeCNaa7oy6(upBCy4vMKqhmbfk(OyO4Lfm1drJEMKJ8gct9RSGcaiMaHgHP(vgOBvWljebWUdMUpLL3qyQFLfuaafBrJRyOL3qyQFLfuaaXei0im1VYaDRcEjHialcUtaaIrqiynDuhh8esgtq8S)s6(yWqsQWWNvf2aqg8rcqHP(vp7VKUpgYdQpVmeqF6xdw0OjKmMG4z)L09XGHKuHHpkgkEzb5ibJ3qyQFLfuaafkqKWzgQ0QXueCNaq60xehIgv8sFQZg41u0OS7GP7t9I4q0OIx6JIHIxwW(gu0O2lgAS)cnbOP8gct9RSGcaOqbIeoZqLwnMIG7eaubIL(A)LsVqJ1RPyOqDD(dlHeIPXbpD6R9xk9cnwVMIHc115p1zd8AkAu2DW09PET)sPxOX61umuOUo)rXqXllyFdmAu7fdn2FHMaBKGXBim1VYckaGcfis4mdvA1ykcUtai4nRcel9fXHOrfV0hwcjetJBwfiw6R9xk9cnwVMIHc115pSesiMcgVHWu)klOaakrfVmqNab3jaqgtq88cJ4QqcrtcdDl(SQWga2ibfnkzmbXZlmIRcjenjm0T4lUDS6HOrptYrq2uEdHP(vwqbauIkEzGobcUtaGmMG45fgXvHeIMeg6w0inXZQcBayJeu0OKXeepVWiUkKq0KWq3IgPjEXTJvpen6zsocYMYBim1VYckaGsuXlJ9IHGZ(fVa8fCVuKsJBvJhgIjxueWxW9srknUvnoba1zdSGbiqEdHP(vwqbaK9xs3hd5bvEdEdHP(v2NCiG2FP0l0y9AkgkuxNZBim1VY(Kdbfaq)sCP8gct9RSp5qqbaKfXK5imSJsJBv)kWDcaQaXsF27Jr)rJfXK9HLqcX0yMuglIjEdHP(v2NCiOaaYIyYCeg2rPXTQFf4obGMvbIL(S3hJ(JglIj7dlHeIPXnNo9zrmzocd7O04w1V6PoBGxtJB2ldb0N(1XPtFSJsJBv)QhfjOO9xiHiVHWu)k7toeuaajtxnhC2CgenQqNq1c4l4obaHPEe0Ko9jtxnhmaJEmfjOO9xiH440Ppz6Q5p1zd8AI3qyQFL9jhckaGKPRMdoBodIgvOtOAb8fCNaGWupcAsN(KPRMdYrpU50Ppz6Q5p1zd8AI3qyQFL9jhckaGIlRkKq0ieeqNP(vG7eaeM6rqt60xCzvHeIgHGa6m1VcqqrJQoBGxtJPibfT)cje5neM6xzFYHGcaO4YQcjencbb0zQFf4S5miAuHoHQfWxWDcanRoBGxtJBJ0Qcel9rLWwPuJqqaDM6xzFyjKqmnwyQhbnPtFXLvfsiAeccOZu)kqocVHWu)k7toeuaafXHOrfVuWDca2lgAS)cnb2xEdHP(v2NCiOaaIjqOryQFLb6wf8scrajHoycku00sXwWDcaS7GP7t9SXHHxzscDWeuO4JIsA(4GNo91(lLEHgRxtXqH668hfdfVSGfy0OnRcel91(lLEHgRxtXqH668hwcjetbJ3qyQFL9jhckaGscDGXEXqWDcaS7GP7t9SXHHxzscDWeuO4JIHIxwWupen6zsoYBim1VY(KdbfaqXw04kgA5neM6xzFYHGcaOqbIeoZqLwnMIG7easN(I4q0OIx6tD2aVM4neM6xzFYHGcaOqbIeoZqLwnMIG7eaAwfiw6lIdrJkEPpSesiM4neM6xzFYHGcaiR3(FLb6ei4S5miAuHoHQfWxWDcact9iOjD6Z6T)xzGobcsaJmU50PpR3(FLb6e4tD2aVM4neM6xzFYHGcaOev8YaDceCNaazmbXZlmIRcjenjm0T4ZQcBayaAAqrJsgtq88cJ4QqcrtcdDl(IBhREiA0ZKCeKnL3qyQFL9jhckaGsuXlJ9IH8gct9RSp5qqbaK9xs3hd5bvEdEdHP(v2h7oy6(uwaFokmfb9Yqr7vsXqEdHP(v2h7oy6(uwqbauigE05MJWaJzEYKOOeA5neM6xzFS7GP7tzbfaqKW7sMJWO)OblmCoVHWu)k7JDhmDFklOaaAkwOjxkZryKMaPN(ZBim1VY(y3bt3NYckaGOEBlenEzSTcd5neM6xzFS7GP7tzbfaqehl2IjJ0ei1v0qIsiVHWu)k7JDhmDFklOaaQnM6eZ9AYqcfRYBim1VY(y3bt3NYckaGOO061KHakHOfCNaGk0juF)Oa1FtltblGckAuvOtO((rbQ)MwMcYadkAuvOtO(upen6zAzQjWGaB0bfnkHp9RgkgkEzbzGbXBim1VY(y3bt3NYckaGyxXWsPIIjdbucrEdHP(v2h7oy6(uwqbaK(JM4I8IRKH4OmeCNaazmbXJISbq0AnehLHpkgkEz5neM6xzFS7GP7tzbfaqw2ft9AYOU(J8gct9RSp2DW09PSGcaipSfRKxtgMOIvPx7pYBim1VY(y3bt3NYckaGSxm0qpfCNaqWjJjiEEHrCviHOjHHUfFwvydaBKakAuHPEe0Gfg6OfSVbJ3qyQFL9XUdMUpLfuaaLqMhkQxtgYdQG7eacUk0juF)Oa1FtltbztdkAucF6xnumu8Ycwtdky8g8gct9RSVKqhmbfkAAPylGioenQ4LYBim1VY(scDWeuOOPLITGcaOKqhySxmK3qyQFL9Le6GjOqrtlfBbfaqTN6xXBim1VY(scDWeuOOPLITGcaicNIKW7s8gct9RSVKqhmbfkAAPylOaaIeExYqetNZBim1VY(scDWeuOOPLITGcaisKAr6aVM4neM6xzFjHoycku00sXwqbaKnom8ktsOdMGcfb3jaim1JGM0PVioenQ4LcwqrJkm1JGM0PV2FP0l0y9AkgkuxNdwqrJQcel9zVpg9hnwet2hwcjetrJg8MvbIL(I4q0OIx6dlHeIPXnRcel91(lLEHgRxtXqH668hwcjetbJ3G3qyQFL9zra)sCP8gct9RSplckaGsuXlJ9IHG7LIuACRACcajKmMG4z)L09XGHKuHHpRkSbGbyeEdHP(v2Nfbfaq2FjDFmKhu3EeKA9R2zbguGb99Bqb077OoYO)oQB)JqlVMSBheEy7rvmXZJcplm1VINHUvTpEJTlX6)r3E3dBY3o0TQDhU9KqhmbfkAAPy7oCN9DhUDHP(vBpIdrJkEPBhlHeIPf4v3zbUd3UWu)QTNe6aJ9IHBhlHeIPf4v3zJSd3UWu)QT3EQF12XsiHyAbE1D2O3HBxyQF12jCkscVlTDSesiMwGxDN10D42fM6xTDs4DjdrmD(2XsiHyAbE1D2OSd3UWu)QTtIulsh4102XsiHyAbE1D2OUd3owcjetlWBNrDfPUSDHPEe0Ko9fXHOrfVuEgmEoiEoAuEwyQhbnPtFT)sPxOX61umuOUoNNbJNdINJgLNvbIL(S3hJ(JglIj7dlHeIjEoAuEo48CZ8SkqS0xehIgv8sFyjKqmXZJ55M5zvGyPV2FP0l0y9AkgkuxN)WsiHyINd22fM6xTDBCy4vMKqhmbfkU6QBpHesmu3H7SV7WTlm1VA72wecnWJny7yjKqmTaV6olWD42fM6xT9eg5IPMqzYzBhlHeIPf4v3zJSd3owcjetlWBNrDfPUSDHPEe0Gfg6OLNbJNhz7ct9R2otGqJWu)kd0T62HUvnLeIBxoC1D2O3HBxyQF12B)LsVqJ1RPyOqDD(2XsiHyAbE1Dwt3HBhlHeIPf4TZOUIux2ofjOO9xiH42fM6xTDz6Q5RUZgLD42XsiHyAbE7ct9R2UmD18TZOUIux2UWupcAWcdD0YZGXZF55X8mfjOO9xiH42zZzq0OcDcv7o77Q7SrDhUDSesiMwG3oJ6ksDz7ct9iOblm0rlpdgphippMNz3bt3N6zJddVYKe6GjOqXhfL0CEEmphrOUqcXx6uRHIsA(2fM6xTDMaHgHP(vgOB1TdDRAkje3EsOdMGcfnTuSD1DwaTd3owcjetlWBNrDfPUSDHPEe0Gfg6OLNbJNdKNhZZnZZQaXsFrCiAuXl9HLqcXeppMNdop3mpRcel99H66pA8Yitxn)HLqcXephnkpRcel9zVpg9hnwet2hwcjet8CW45X8CZ8C60NfXK5imSJsJBv)QN6SbEnXZJ55M5zVmeqF6x55X8C60h7O04w1V6rrckA)fsiUDHP(vB3IyYCeg2rPXTQF1Q7Sa(oC7yjKqmTaVDg1vK6Y2dopBVyOX(l0epdgp)LNJgLNfM6rqdwyOJwEgmEoqEoy88yEMDhmDFQNnom8ktsOdMGcfFumu8YYZGXZFdC7ct9R2EehIgv8sxDN9nOD42XsiHyAbE7mQRi1LTtrckA)fsiUDHP(vB36T)xzGobU6o773D42XsiHyAbE7mQRi1LTlm1JGM0PV4YQcjencbb0zQFfpdGNdINJgLNvNnWRjEEmptrckA)fsiUDHP(vBpUSQqcrJqqaDM6xT6o7BG7WTJLqcX0c82zuxrQlBxD2aVM45X8S0ei1v8XeltsEnzycucDD(dlHeIjEEmptgtq8yILjjVMmmbkHUo)rXqXllpdsEEKTlm1VA7XLvfsiAeccOZu)Qv3zFhzhUDSesiMwG3oJ6ksDz7bNNfM6rqdwyOJwEgK88i8C0O8SkqS0xehIgv8sFyjKqmXZrJYZQaXsFFOU(JgVmY0vZFyjKqmXZJ55M5zvGyPp79XO)OXIyY(WsiHyINdgppMNPibfT)cje3UWu)QTZoknUv9RwDN9D07WTlm1VA7)sCPBhlHeIPf4v3zFB6oC7yjKqmTaVDg1vK6Y2Txm0y)fAINbJNh92fM6xT9qbIeoZqLwnMIRUZ(ok7WTJLqcX0c82fM6xTDR3(FLb6e42zuxrQlBxyQhbnyHHoA5zW45V88yEoD6Z6T)xzGob(OyO4LLNbjppY2zZzq0OcDcv7o77Q7SVJ6oC7yjKqmTaVDHP(vBNDuACR6xTDg1vK6Y2PyO4LLNbjppcppMNdoplm1JGgSWqhT8mi55r45Or5zvGyPVioenQ4L(WsiHyINJgLNvbIL((qD9hnEzKPRM)WsiHyINhZZnZZQaXsF27Jr)rJfXK9HLqcXephSTZMZGOrf6eQ2D23v3zFdOD42XsiHyAbE7mQRi1LTZUdMUp1ZghgELjj0btqHIpkgkEz5zqYZbYZJ55ic1fsi(sNAnuusZ3UWu)QTZei0im1VYaDRUDOBvtjH42tcDWeuOOPLITRUZ(gW3HBhlHeIPf4TZOUIux2o7oy6(upBCy4vMKqhmbfk(OyO4LLNbJNvpen6zsoUDHP(vBpj0bg7fdxDNfyq7WTJLqcX0c82fM6xTDMaHgHP(vgOB1TdDRAkje3o7oy6(u2v3zb(DhUDHP(vBp2IgxXq72XsiHyAbE1DwGbUd3owcjetlWBNrDfPUSDigbH8my8CthvEEmphCEoHKXeep7VKUpgmKKkm8zvHnGNbjphCEEeEoa5zHP(vp7VKUpgYdQpVmeqF6x55GXZrJYZjKmMG4z)L09XGHKuHHpkgkEz5zqYZJWZbB7ct9R2otGqJWu)kd0T62HUvnLeIB3IRUZcCKD42XsiHyAbE7mQRi1LTNo9fXHOrfV0N6SbEnXZrJYZS7GP7t9I4q0OIx6JIHIxwEgmE(Bq8C0O8S9IHg7Vqt8maEUPBxyQF12dfis4mdvA1ykU6olWrVd3owcjetlWBNrDfPUSDvGyPV2FP0l0y9AkgkuxN)WsiHyINhZZbNNtN(A)LsVqJ1RPyOqDD(tD2aVM45Or5z2DW09PET)sPxOX61umuOUo)rXqXllpdgp)nqEoAuE2EXqJ9xOjEgmEEeEoyBxyQF12dfis4mdvA1ykU6olWMUd3owcjetlWBNrDfPUS9GZZnZZQaXsFrCiAuXl9HLqcXeppMNBMNvbIL(A)LsVqJ1RPyOqDD(dlHeIjEoyBxyQF12dfis4mdvA1ykU6olWrzhUDSesiMwG3oJ6ksDz7KXeepVWiUkKq0KWq3IpRkSb8my88ibXZrJYZKXeepVWiUkKq0KWq3IV4wEEmpREiA0ZKCKNbjp30Tlm1VA7jQ4Lb6e4Q7Sah1D42XsiHyAbE7mQRi1LTtgtq88cJ4QqcrtcdDlAKM4zvHnGNbJNhjiEoAuEMmMG45fgXvHeIMeg6w0inXlULNhZZQhIg9mjh5zqYZnD7ct9R2EIkEzGobU6olWaAhUDSesiMwG3UWu)QTNOIxg7fd3UxksPXTQXj2U6SbwWae429srknUvnEyiMCrXT)D7SFXRT)D1DwGb8D42fM6xTD7VKUpgYdQBhlHeIPf4vxD7TuKDHKIUd3zF3HBhlHeIPf4TZOUIux2U6HipdgpheppMNBMNBr9jqpcYZJ55M5zYycI3e1dpNIMJWyfg1jCg(IB3UWu)QTtGqt6c9su)Qv3zbUd3UWu)QTBJddVYqGW)4sr62XsiHyAbE1D2i7WTJLqcX0c82zuxrQlBxfiw6BI6HNtrZryScJ6eodFyjKqmTDHP(vBFI6HNtrZryScJ6eodxDNn6D42XsiHyAbE7x72TOUDHP(vBpIqDHeIBpIaJXTlm1JGM0Pp2rPXTQFfpdgpheppMNfM6rqt60NmD1CEgmEoiEEmplm1JGM0PV4YQcjencbb0zQFfpdgpheppMNdop3mpRcel9z92)RmqNaFyjKqmXZrJYZct9iOjD6Z6T)xzGobYZGXZbXZbJNhZZbNNtN(A)LsVqJ1RPyOqDD(tD2aVM45Or55M5zvGyPV2FP0l0y9AkgkuxN)WsiHyINd22JiutjH42tNAnuusZxDN10D42XsiHyAbE7LeIBxAc7VqfRH4k1CeM27ds3UWu)QTlnH9xOI1qCLAoct79bPRUZgLD42XsiHyAbE7mQRi1LTBBri0OcDcv7ZIyYCeg2rPXTQFLroKNbdappcppMNBMNXaOyVTftpPjS)cvSgIRuZryAVpiD7ct9R2UfXK5imSJsJBv)Qv3zJ6oC7ct9R2(Vex62XsiHyAbE1DwaTd3owcjetlWBNrDfPUS9M5zvGyPVFjU0hwcjet88yE22IqOrf6eQ2NfXK5imSJsJBv)kJCipdsEEeEEmp3mpJbqXEBlMEsty)fQynexPMJW0EFq62fM6xTD7VKUpgYdQRU62z3bt3NYUd3zF3HBxyQF12)Cuykc6LHI2RKIHBhlHeIPf4v3zbUd3UWu)QThIHhDU5imWyMNmjkkH2TJLqcX0c8Q7Sr2HBxyQF12jH3LmhHr)rdwy48TJLqcX0c8Q7SrVd3UWu)QTpfl0KlL5imstG0t)3owcjetlWRUZA6oC7ct9R2o1BBHOXlJTvy42XsiHyAbE1D2OSd3UWu)QTtCSylMmstGuxrdjkHBhlHeIPf4v3zJ6oC7ct9R2EBm1jM71KHekwD7yjKqmTaV6olG2HBhlHeIPf4TZOUIux2Uk0juF)Oa1Ftlt5zW45akiEoAuEwf6eQVFuG6VPLP8mi55adINJgLNvHoH6t9q0ONPLPMadINbJNhDq8C0O8mHp9RgkgkEz5zqYZbg02fM6xTDkkTEnziGsiAxDNfW3HBxyQF12zxXWsPIIjdbucXTJLqcX0c8Q7SVbTd3owcjetlWBNrDfPUSDYycIhfzdGO1AiokdFumu8YUDHP(vBx)rtCrEXvYqCugU6o773D42fM6xTDl7IPEnzux)XTJLqcX0c8Q7SVbUd3UWu)QT7HTyL8AYWevSk9A)XTJLqcX0c8Q7SVJSd3owcjetlWBNrDfPUS9GZZKXeepVWiUkKq0KWq3IpRkSb8my88ibephnkplm1JGgSWqhT8my88xEoyBxyQF12Txm0qpD1D23rVd3owcjetlWBNrDfPUS9GZZQqNq99Jcu)nTmLNbjp30G45Or5zcF6xnumu8YYZGXZnniEoyBxyQF12tiZdf1Rjd5b1vxD7YH7WD23D42fM6xT92FP0l0y9AkgkuxNVDSesiMwGxDNf4oC7ct9R2(Vex62XsiHyAbE1D2i7WTJLqcX0c82zuxrQlBxfiw6ZEFm6pASiMSpSesiM45X8mtkJfX02fM6xTDlIjZryyhLg3Q(vRUZg9oC7yjKqmTaVDg1vK6Y2BMNvbIL(S3hJ(JglIj7dlHeIjEEmp3mpNo9zrmzocd7O04w1V6PoBGxt88yEUzE2ldb0N(vEEmpNo9XoknUv9REuKGI2FHeIBxyQF12TiMmhHHDuACR6xT6oRP7WTJLqcX0c82fM6xTDz6Q5BNrDfPUSDHPEe0Ko9jtxnNNbdappAEEmptrckA)fsiYZJ550Ppz6Q5p1zd8AA7S5miAuHoHQDN9D1D2OSd3owcjetlWBxyQF12LPRMVDg1vK6Y2fM6rqt60NmD1CEgK88O55X8CZ8C60NmD18N6SbEnTD2CgenQqNq1UZ(U6oBu3HBhlHeIPf4TZOUIux2UWupcAsN(IlRkKq0ieeqNP(v8maEoiEoAuEwD2aVM45X8mfjOO9xiH42fM6xT94YQcjencbb0zQF1Q7SaAhUDSesiMwG3UWu)QThxwviHOriiGot9R2oJ6ksDz7nZZQZg41eppMNBJ0Qcel9rLWwPuJqqaDM6xzFyjKqmXZJ5zHPEe0Ko9fxwviHOriiGot9R4zqYZJSD2CgenQqNq1UZ(U6olGVd3owcjetlWBNrDfPUSD7fdn2FHM4zW45VBxyQF12J4q0OIx6Q7SVbTd3owcjetlWBNrDfPUSD2DW09PE24WWRmjHoycku8rrjnNNhZZbNNtN(A)LsVqJ1RPyOqDD(JIHIxwEgmEoqEoAuEUzEwfiw6R9xk9cnwVMIHc115pSesiM45GTDHP(vBNjqOryQFLb6wD7q3QMscXTNe6GjOqrtlfBxDN997oC7yjKqmTaVDg1vK6Y2z3bt3N6zJddVYKe6GjOqXhfdfVS8my8S6HOrptYXTlm1VA7jHoWyVy4Q7SVbUd3UWu)QThBrJRyOD7yjKqmTaV6o77i7WTJLqcX0c82zuxrQlBpD6lIdrJkEPp1zd8AA7ct9R2EOarcNzOsRgtXv3zFh9oC7yjKqmTaVDg1vK6Y2BMNvbIL(I4q0OIx6dlHeIPTlm1VA7HcejCMHkTAmfxDN9TP7WTJLqcX0c82fM6xTDR3(FLb6e42zuxrQlBxyQhbnPtFwV9)kd0jqEgKa45r45X8CZ8C60N1B)VYaDc8PoBGxtBNnNbrJk0juT7SVRUZ(ok7WTJLqcX0c82zuxrQlBNmMG45fgXvHeIMeg6w8zvHnGNbdap30G45Or5zYycINxyexfsiAsyOBXxClppMNvpen6zsoYZGKNB62fM6xT9ev8YaDcC1D23rDhUDHP(vBprfVm2lgUDSesiMwGxDN9nG2HBxyQF12T)s6(yipOUDSesiMwGxD1TBXD4o77oC7ct9R2(Vex62XsiHyAbE1DwG7WT7LIuACRACITNqYycIN9xs3hdgssfg(SQWgagGr2UWu)QTNOIxg7fd3owcjetlWRUZgzhUDHP(vB3(lP7JH8G62XsiHyAbE1vxD1v3f]] )


end