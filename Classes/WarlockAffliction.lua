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


    spec:RegisterPack( "Affliction", 20201108.1, [[dy0x5aqiPipci0MuQ8jGGyusr5ucv6vaPzbuDlbH2LQ8lazycshtvPLju1ZusmnLK6AkjzBcv03acmobroNGOADsrfnpGO7bW(akhukQAHaQhkfvQjkikxukQKtceuTsPWmbcs3uqa7uj1pbckdvqqTubb6Ps1uvI(Quub7vXFPyWI6WelgrpgLjlYLH2mcFwPmAvvNMQxReMnOBlWUL8BvgUu64ccYYr65uA6KUUq2UG67QkgVuuHoVsvRxOcZxOSFu98Dwo9KO4So(qJp0VFdnKEFbbRS6VGGPR7BXP3kSfYgo9scWP38eeqNP(vtVv2dpjnlNU9IOmC6)Q2ABobcOnx)JiFSlaiRhebf1VIrfcfiRhWaA6KroubHxd50tIIZ64dn(q)(n0q69feSYQ)gNt32ISzD8X5QM(VNsynKtpHw20brEU5jiGot9R45MdcfESf8gGipV(cJbKiLNdjW554dn(q5n4narEU5(xQn02CYBaI8CiYZnFkHjEU3Iqipdc9ylE8gGiphI8CZNsyINdzy4lIYZHaYMZE8gGiphI8CZNsyINjPOSG9lvHqEgEBoJNjokphYOIx8C)IGpEdqKNdrEE5huwWZHacejCgphckTAef5z4T5mEwpE(ZrxWZobpV)IaHqrEoWTwV24zHNvbILYZEXZ6VO8m9(84narEoe55MRsiHiphckbTsP8CZtqaDM6xz55q4WHW8SkqS0hVbiYZHipV8dklS8SE8Se(8eptcVpETXZHmHUydkuKN9INdIGQhIQq3qLN)a0XZHmqylT8Cu7B6T0JWH40brEU5jiGot9R45MdcfESf8gGipV(cJbKiLNdjW554dn(q5n4narEU5(xQn02CYBaI8CiYZnFkHjEU3Iqipdc9ylE8gGiphI8CZNsyINdzy4lIYZHaYMZE8gGiphI8CZNsyINjPOSG9lvHqEgEBoJNjokphYOIx8C)IGpEdqKNdrEE5huwWZHacejCgphckTAef5z4T5mEwpE(ZrxWZobpV)IaHqrEoWTwV24zHNvbILYZEXZ6VO8m9(84narEoe55MRsiHiphckbTsP8CZtqaDM6xz55q4WHW8SkqS0hVbiYZHipV8dklS8SE8Se(8eptcVpETXZHmHUydkuKN9INdIGQhIQq3qLN)a0XZHmqylT8Cu7J3G3qyQFL91sr2fqkkaceAsxGxI6xbUtaq9aeSq31ulQpb6HXDnrgrq82OEW5u0CegRWOoHZWxulVHWu)k7RLISlGuuqbaKnki4ktlQ8gct9RSVwkYUasrbfaqBup4CkAocJvyuNWzi4obavGyPVnQhCofnhHXkmQt4m8HLqcXeVHWu)k7RLISlGuuqbauyH6cjebVKaeq6uRHIsAp4HfyecqyQhgnPtFSJsJAv)kWcDNWupmAsN(KTR2dwO7eM6Hrt60xuzvHeIgHGa6m1VcSq31SMubIL(SE7)vgOtGpSesiMIftyQhgnPtFwV9)kd0jqWcnU7Aw60x7Vu6fySETfbfQR7FQZw41wSynPcel91(lLEbgRxBrqH66(hwcjetXL3qyQFL91sr2fqkkOaakYIgxXaWljabiXH9xOI1qCLAoct79bP8gct9RSVwkYUasrbfaqwetMJWWoknQv9Ra3jayBri0OcDdv7ZIyYCeg2rPrTQFLroemaRSRjmekYBBX07BCgYx57Q5neM6xzFTuKDbKIckaG(LOs5neM6xzFTuKDbKIckaGS)s6(yipOcUtaOjvGyPVFjQ0hwcjet7STieAuHUHQ9zrmzocd7O0Ow1VYihcYv21egcf5TTy69nod5R8D18g8gGip3C1CezrkM4zmms3ZZQhG8S(J8SW0JYZULNLWIdfsi(4neM6xzbyBri0ap2cEdHP(vwqbaucdFrutGS5mEdHP(vwqbaetGqJWu)kd0Tk4LeGaKdb3jaim1dJgSWahTGTcVHWu)klOaaQ9xk9cmwV2IGc1198gct9RSGcaiz7Q9G7eaOibfT)cje5neM6xzbfaqY2v7bNTNbrJk0nuTa(cUtaqyQhgnyHboAb77oksqr7VqcrEdHP(vwqbaetGqJWu)kd0Tk4LeGascDXguOOPLITG7eaeM6HrdwyGJwWIFh7oy6(upBuqWvMKqxSbfk(OOK2VlSqDHeIV0PwdfL0EEdHP(vwqbaKfXK5imSJsJAv)kWDcact9WOblmWrlyXVRjvGyPVWoenQ4L(WsiHyAxZAsfiw67d11F04Lr2UA)dlHeIPyXubIL(S3hJ(JglIj7dlHeIP4URP0PplIjZryyhLg1Q(vp1zl8ABxtEziG(2VUlD6JDuAuR6x9OibfT)cje5neM6xzbfaqHDiAuXlfCNaqZSxe0y)fAcSVXIjm1dJgSWahTGfFC3XUdMUp1ZgfeCLjj0fBqHIpkgiEzb7B88gct9RSGcaiR3(FLb6ei4obaksqr7VqcrEdHP(vwqbauuzvHeIgHGa6m1VcCNaGWupmAsN(IkRkKq0ieeqNP(vacnwm1zl8ABhfjOO9xiHiVHWu)klOaakQSQqcrJqqaDM6xbUtaqD2cV22jXbsDfFmXYKKxBgMaLax3)WsiHyAhzebXJjwMK8AZWeOe46(hfdeVSGCfEdHP(vwqbae7O0Ow1VcCNaqZeM6HrdwyGJwqUsSyQaXsFHDiAuXl9HLqcXuSyQaXsFFOU(JgVmY2v7FyjKqmTRjvGyPp79XO)OXIyY(WsiHykU7OibfT)cje5neM6xzbfaq)suP8gct9RSGcaOabIeoZqLwnIIG7eaSxe0y)fAcSvZBim1VYckaGSE7)vgOtGGZ2ZGOrf6gQwaFb3jaim1dJgSWahTG9Dx60N1B)VYaDc8rXaXllixH3qyQFLfuaaXoknQv9RaNTNbrJk0nuTa(cUtaGIbIxwqUYUMjm1dJgSWahTGCLyXubIL(c7q0OIx6dlHeIPyXubIL((qD9hnEzKTR2)WsiHyAxtQaXsF27Jr)rJfXK9HLqcXuC5neM6xzbfaqmbcnct9Rmq3QGxsacij0fBqHIMwk2cUtaGDhmDFQNnki4ktsOl2GcfFumq8YcY43fwOUqcXx6uRHIsApVHWu)klOaakj0fg7fbb3jaWUdMUp1ZgfeCLjj0fBqHIpkgiEzbt9a0ONj5iVHWu)klOaaIjqOryQFLb6wf8scqaS7GP7tz5neM6xzbfaqrw04kgy5neM6xzbfaqmbcnct9Rmq3QGxsacWIG7easizebXZ(lP7JbdiPcdFwvylazZwjefM6x9S)s6(yipO(8Yqa9TFnUXILqYicIN9xs3hdgqsfg(OyG4LfKRWBim1VYckaGceis4mdvA1ikcUtaiD6lSdrJkEPp1zl8Alwm2DW09PEHDiAuXl9rXaXllyFdnwm7fbn2FHMaSkEdHP(vwqbauGarcNzOsRgrrWDcaQaXsFT)sPxGX61weuOUU)HLqcX0UMLo91(lLEbgRxBrqH66(N6SfETflg7oy6(uV2FP0lWy9Alckux3)OyG4LfSVXhlM9IGg7VqtGTsC5neM6xzbfaqbcejCMHkTAefb3ja0SMubIL(c7q0OIx6dlHeIPDnPcel91(lLEbgRxBrqH66(hwcjetXL3qyQFLfuaaLOIxgOtGG7eaiJiiEEHHDviHOjHbUfFwvylaBLqJfJmIG45fg2vHeIMeg4w8f1Ut9a0ONj5iixfVHWu)klOaakrfVmqNab3jaqgrq88cd7QqcrtcdClAK44zvHTaSvcnwmYicINxyyxfsiAsyGBrJehVO2DQhGg9mjhb5Q4neM6xzbfaqjQ4LXErqWz)Ixa(cUxksPrTQXdcWKlkc4l4EPiLg1QgNaG6SfwWaepVHWu)klOaaY(lP7JH8GkVbVHWu)k7toeq7Vu6fySETfbfQR75neM6xzFYHGcaOFjQuEdHP(v2NCiOaaYIyYCeg2rPrTQFf4obavGyPp79XO)OXIyY(WsiHyAhtkJfXeVHWu)k7toeuaazrmzocd7O0Ow1VcCNaqtQaXsF27Jr)rJfXK9HLqcX0UMsN(SiMmhHHDuAuR6x9uNTWRTDn5LHa6B)6U0Pp2rPrTQF1JIeu0(lKqK3qyQFL9jhckaGKTR2doBpdIgvOBOAb8fCNaGWupmAsN(KTR2dgGvVJIeu0(lKqCx60NSD1(N6SfETXBim1VY(KdbfaqY2v7bNTNbrJk0nuTa(cUtaqyQhgnPtFY2v7b5Q31u60NSD1(N6SfETXBim1VY(KdbfaqrLvfsiAeccOZu)kWDcact9WOjD6lQSQqcrJqqaDM6xbi0yXuNTWRTDuKGI2FHeI8gct9RSp5qqbauuzvHeIgHGa6m1VcC2EgenQq3q1c4l4obGMuNTWRTDTHBvbIL(OsqRuQriiGot9RSpSesiM2jm1dJM0PVOYQcjencbb0zQFfixH3qyQFL9jhckaGc7q0OIxk4oba7fbn2FHMa7lVHWu)k7toeuaaXei0im1VYaDRcEjbiGKqxSbfkAAPyl4oba2DW09PE2OGGRmjHUydku8rrjTFxZsN(A)LsVaJ1RTiOqDD)JIbIxwWIpwSMubIL(A)LsVaJ1RTiOqDD)dlHeIP4YBim1VY(KdbfaqjHUWyVii4oba2DW09PE2OGGRmjHUydku8rXaXllyQhGg9mjh5neM6xzFYHGcaOilACfdS8gct9RSp5qqbauGarcNzOsRgrrWDcaPtFHDiAuXl9PoBHxB8gct9RSp5qqbauGarcNzOsRgrrWDcanPcel9f2HOrfV0hwcjet8gct9RSp5qqbaK1B)VYaDceC2EgenQq3q1c4l4obaHPEy0Ko9z92)RmqNabjGv21u60N1B)VYaDc8PoBHxB8gct9RSp5qqbauIkEzGobcUtaGmIG45fg2vHeIMeg4w8zvHTamaRk0yXiJiiEEHHDviHOjHbUfFrT7upan6zsocYvXBim1VY(KdbfaqjQ4LXErqEdHP(v2NCiOaaY(lP7JH8GkVbVHWu)k7JDhmDFklGphfMcJEzOO9kPyiVHWu)k7JDhmDFklOaakado6EZryGrmpzsuucS8gct9RSp2DW09PSGcais4DjZry0F0GfgSN3qyQFL9XUdMUpLfuaaTfj0KlL5imsCG0t)5neM6xzFS7GP7tzbfaquVTfIgVm2wHH8gct9RSp2DW09PSGcaiIJfzXKrIdK6kAirjG3qyQFL9XUdMUpLfuaa1grDI9ETziHIv5neM6xzFS7GP7tzbfaquuA9AZqaLa0cUtaqf6gQVFuG6VPLPGfsHglMk0nuF)Oa1Ftltbz8HglMk0nuFQhGg9mTm1eFOGT6qJfJW3(vdfdeVSGm(q5neM6xzFS7GP7tzbfaqSRyyPurXKHakbiVHWu)k7JDhmDFklOaas)rturErvYqCugcUtaGmIG4rr2ciATgIJYWhfdeVS8gct9RSp2DW09PSGcail7IOETzux)rEdHP(v2h7oy6(uwqbaKh0IvYRndtuXQ0R9h5neM6xzFS7GP7tzbfaq2lcAONcUtaOzKreepVWWUkKq0KWa3IpRkSfGTsiflMWupmAWcdC0c234YBim1VY(y3bt3NYckaGsiZde1Rnd5bvWDcantf6gQVFuG6VPLPGCvHglgHV9RgkgiEzbBvHgxEdEdHP(v2xsOl2GcfnTuSfqyhIgv8s5neM6xzFjHUydku00sXwqbausOlm2lcYBim1VY(scDXguOOPLITGcaO2t9R4neM6xzFjHUydku00sXwqbaeHtrs4DjEdHP(v2xsOl2GcfnTuSfuaarcVlziIO75neM6xzFjHUydku00sXwqbaejsTiDHxB8gct9RSVKqxSbfkAAPylOaaYgfeCLjj0fBqHIG7eaeM6Hrt60xyhIgv8sbl0yXeM6Hrt60x7Vu6fySETfbfQR7bl0yXubIL(S3hJ(JglIj7dlHeIPyXAwtQaXsFHDiAuXl9HLqcX0UMubIL(A)LsVaJ1RTiOqDD)dlHeIP4YBWBim1VY(SiGFjQuEdHP(v2NfbfaqjQ4LXErqW9srknQvnobGesgrq8S)s6(yWasQWWNvf2cWaScVHWu)k7ZIGcai7VKUpgYdQtpmsT(vZ64dn(q)(n0qA6FeA51MD6GWdApQIjEoo5zHP(v8m0TQ9XBmDjs)p607EqZ90HUvTZYPNe6InOqrtlfBNLZ6VZYPlm1VA6HDiAuXlD6yjKqmnap6So(z50fM6xn9KqxySxeC6yjKqmnap6SELz50fM6xn92t9RMowcjetdWJoRx9SC6ct9RMoHtrs4DPPJLqcX0a8OZ6vnlNUWu)QPtcVlziIO7NowcjetdWJoRJZz50fM6xnDsKAr6cV2MowcjetdWJoRbbZYPJLqcX0a80zuxrQltxyQhgnPtFHDiAuXlLNbJNdLNJfJNfM6Hrt60x7Vu6fySETfbfQR75zW45q55yX4zvGyPp79XO)OXIyY(WsiHyINJfJNBgp3epRcel9f2HOrfV0hwcjet88oEUjEwfiw6R9xk9cmwV2IGc119pSesiM454oDHP(vt3gfeCLjj0fBqHIJo60tiHeb1z5S(7SC6ct9RMUTfHqd8ylMowcjetdWJoRJFwoDHP(vtpHHViQjq2C20XsiHyAaE0z9kZYPJLqcX0a80zuxrQltxyQhgnyHboA5zW45vMUWu)QPZei0im1VYaDRoDOBvtjb40LdhDwV6z50fM6xn92FP0lWy9Alckux3pDSesiMgGhDwVQz50XsiHyAaE6mQRi1LPtrckA)fsioDHP(vtx2UA)OZ64CwoDSesiMgGNUWu)QPlBxTF6mQRi1LPlm1dJgSWahT8my88xEEhptrckA)fsioD2EgenQq3q1oR)o6SgemlNowcjetdWtNrDfPUmDHPEy0Gfg4OLNbJNJNN3XZS7GP7t9SrbbxzscDXguO4JIsAppVJNdluxiH4lDQ1qrjTF6ct9RMotGqJWu)kd0T60HUvnLeGtpj0fBqHIMwk2o6SoKMLthlHeIPb4PZOUIuxMUWupmAWcdC0YZGXZXZZ745M4zvGyPVWoenQ4L(WsiHyIN3XZnJNBINvbIL((qD9hnEzKTR2)WsiHyINJfJNvbIL(S3hJ(JglIj7dlHeIjEoU88oEUjEoD6ZIyYCeg2rPrTQF1tD2cV245D8Ct8SxgcOV9R88oEoD6JDuAuR6x9OibfT)cjeNUWu)QPBrmzocd7O0Ow1VA0zDiFwoDSesiMgGNoJ6ksDz6nJNTxe0y)fAINbJN)YZXIXZct9WOblmWrlpdgphpphxEEhpZUdMUp1ZgfeCLjj0fBqHIpkgiEz5zW45VXpDHP(vtpSdrJkEPJoR)g6SC6yjKqmnapDg1vK6Y0PibfT)cjeNUWu)QPB92)RmqNahDw)97SC6yjKqmnapDg1vK6Y0fM6Hrt60xuzvHeIgHGa6m1VINbWZHYZXIXZQZw41gpVJNPibfT)cjeNUWu)QPhvwviHOriiGot9RgDw)n(z50XsiHyAaE6mQRi1LPRoBHxB88oEwIdK6k(yILjjV2mmbkbUU)HLqcXepVJNjJiiEmXYKKxBgMaLax3)OyG4LLNbjpVY0fM6xn9OYQcjencbb0zQF1OZ6VRmlNowcjetdWtNrDfPUm9MXZct9WOblmWrlpdsEEfEowmEwfiw6lSdrJkEPpSesiM45yX4zvGyPVpux)rJxgz7Q9pSesiM45D8Ct8SkqS0N9(y0F0yrmzFyjKqmXZXLN3XZuKGI2FHeItxyQF10zhLg1Q(vJoR)U6z50fM6xn9FjQ0PJLqcX0a8OZ6VRAwoDSesiMgGNoJ6ksDz62lcAS)cnXZGXZRE6ct9RMEGarcNzOsRgrXrN1FJZz50XsiHyAaE6ct9RMU1B)VYaDcC6mQRi1LPlm1dJgSWahT8my88xEEhpNo9z92)RmqNaFumq8YYZGKNxz6S9miAuHUHQDw)D0z9xqWSC6yjKqmnapDHP(vtNDuAuR6xnDg1vK6Y0PyG4LLNbjpVcpVJNBgplm1dJgSWahT8mi55v45yX4zvGyPVWoenQ4L(WsiHyINJfJNvbIL((qD9hnEzKTR2)WsiHyIN3XZnXZQaXsF27Jr)rJfXK9HLqcXeph3PZ2ZGOrf6gQ2z93rN1FdPz50XsiHyAaE6mQRi1LPZUdMUp1ZgfeCLjj0fBqHIpkgiEz5zqYZXZZ745Wc1fsi(sNAnuus7NUWu)QPZei0im1VYaDRoDOBvtjb40tcDXguOOPLITJoR)gYNLthlHeIPb4PZOUIuxMo7oy6(upBuqWvMKqxSbfk(OyG4LLNbJNvpan6zsooDHP(vtpj0fg7fbhDwhFOZYPJLqcX0a80fM6xnDMaHgHP(vgOB1PdDRAkjaNo7oy6(u2rN1X)DwoDHP(vtpYIgxXa70XsiHyAaE0zD8XplNowcjetdWtNrDfPUm9esgrq8S)s6(yWasQWWNvf2cEgK8CZ45v45qKNfM6x9S)s6(yipO(8Yqa9TFLNJlphlgpNqYicIN9xs3hdgqsfg(OyG4LLNbjpVY0fM6xnDMaHgHP(vgOB1PdDRAkjaNUfhDwh)kZYPJLqcX0a80zuxrQltpD6lSdrJkEPp1zl8AJNJfJNz3bt3N6f2HOrfV0hfdeVS8my883q55yX4z7fbn2FHM4za88QMUWu)QPhiqKWzgQ0QruC0zD8REwoDSesiMgGNoJ6ksDz6QaXsFT)sPxGX61weuOUU)HLqcXepVJNBgpNo91(lLEbgRxBrqH66(N6SfETXZXIXZS7GP7t9A)LsVaJ1RTiOqDD)JIbIxwEgmE(B88CSy8S9IGg7Vqt8my88k8CCNUWu)QPhiqKWzgQ0QruC0zD8RAwoDSesiMgGNoJ6ksDz6nJNBINvbIL(c7q0OIx6dlHeIjEEhp3epRcel91(lLEbgRxBrqH66(hwcjet8CCNUWu)QPhiqKWzgQ0QruC0zD8X5SC6yjKqmnapDg1vK6Y0jJiiEEHHDviHOjHbUfFwvyl4zW45vcLNJfJNjJiiEEHHDviHOjHbUfFrT88oEw9a0ONj5ipdsEEvtxyQF10tuXld0jWrN1XdcMLthlHeIPb4PZOUIuxMozebXZlmSRcjenjmWTOrIJNvf2cEgmEELq55yX4zYicINxyyxfsiAsyGBrJehVOwEEhpREaA0ZKCKNbjpVQPlm1VA6jQ4Lb6e4OZ64dPz50XsiHyAaE6ct9RMEIkEzSxeC6EPiLg1QgNy6QZwybdq8t3lfP0Ow14bbyYffN(3PZ(fVM(3rN1XhYNLtxyQF10T)s6(yipOoDSesiMgGhD0P3sr2fqk6SCw)DwoDSesiMgGNoJ6ksDz6QhG8my8CO88oEUjEUf1Na9WipVJNBINjJiiEBup4CkAocJvyuNWz4lQD6ct9RMobcnPlWlr9RgDwh)SC6ct9RMUnki4kdbc)JkfPthlHeIPb4rN1RmlNowcjetdWtNrDfPUmDvGyPVnQhCofnhHXkmQt4m8HLqcX00fM6xn9nQhCofnhHXkmQt4mC0z9QNLthlHeIPb4PFTt3I60fM6xn9Wc1fsio9WcmcNUWupmAsN(yhLg1Q(v8my8CO88oEwyQhgnPtFY2v75zW45q55D8SWupmAsN(IkRkKq0ieeqNP(v8my8CO88oEUz8Ct8SkqS0N1B)VYaDc8HLqcXephlgplm1dJM0PpR3(FLb6eipdgphkphxEEhp3mEoD6R9xk9cmwV2IGc119p1zl8AJNJfJNBINvbIL(A)LsVaJ1RTiOqDD)dlHeIjEoUtpSqnLeGtpDQ1qrjTF0z9QMLthlHeIPb4PxsaoDjoS)cvSgIRuZryAVpiD6ct9RMUeh2FHkwdXvQ5imT3hKo6SooNLthlHeIPb4PZOUIuxMUTfHqJk0nuTplIjZryyhLg1Q(vg5qEgma88k88oEUjEgdHI82wm9K4W(luXAiUsnhHP9(G0Plm1VA6wetMJWWoknQv9RgDwdcMLtxyQF10)LOsNowcjetdWJoRdPz50XsiHyAaE6mQRi1LP3epRcel99lrL(WsiHyIN3XZ2wecnQq3q1(SiMmhHHDuAuR6xzKd5zqYZRWZ745M4zmekYBBX0tId7VqfRH4k1CeM27dsNUWu)QPB)L09XqEqD0rNo7oy6(u2z5S(7SC6ct9RM(NJctHrVmu0ELumC6yjKqmnap6So(z50fM6xn9am4O7nhHbgX8KjrrjWoDSesiMgGhDwVYSC6ct9RMoj8UK5im6pAWcd2pDSesiMgGhDwV6z50fM6xn9TiHMCPmhHrIdKE6)0XsiHyAaE0z9QMLtxyQF10PEBlenEzSTcdNowcjetdWJoRJZz50fM6xnDIJfzXKrIdK6kAirjy6yjKqmnap6SgemlNUWu)QP3grDI9ETziHIvNowcjetdWJoRdPz50XsiHyAaE6mQRi1LPRcDd13pkq930YuEgmEoKcLNJfJNvHUH67hfO(BAzkpdsEo(q55yX4zvOBO(upan6zAzQj(q5zW45vhkphlgpt4B)QHIbIxwEgK8C8HoDHP(vtNIsRxBgcOeG2rN1H8z50fM6xnD2vmSuQOyYqaLaC6yjKqmnap6S(BOZYPJLqcX0a80zuxrQltNmIG4rr2ciATgIJYWhfdeVStxyQF101F0evKxuLmehLHJoR)(DwoDHP(vt3YUiQxBg11FC6yjKqmnap6S(B8ZYPlm1VA6EqlwjV2mmrfRsV2FC6yjKqmnap6S(7kZYPJLqcX0a80zuxrQltVz8mzebXZlmSRcjenjmWT4ZQcBbpdgpVsiXZXIXZct9WOblmWrlpdgp)LNJ70fM6xnD7fbn0thDw)D1ZYPJLqcX0a80zuxrQltVz8Sk0nuF)Oa1Ftlt5zqYZRkuEowmEMW3(vdfdeVS8my88QcLNJ70fM6xn9eY8ar9AZqEqD0rNUC4SCw)DwoDHP(vtV9xk9cmwV2IGc119thlHeIPb4rN1XplNUWu)QP)lrLoDSesiMgGhDwVYSC6yjKqmnapDg1vK6Y0vbIL(S3hJ(JglIj7dlHeIjEEhpZKYyrmnDHP(vt3IyYCeg2rPrTQF1OZ6vplNowcjetdWtNrDfPUm9M4zvGyPp79XO)OXIyY(WsiHyIN3XZnXZPtFwetMJWWoknQv9REQZw41gpVJNBIN9Yqa9TFLN3XZPtFSJsJAv)QhfjOO9xiH40fM6xnDlIjZryyhLg1Q(vJoRx1SC6yjKqmnapDHP(vtx2UA)0zuxrQltxyQhgnPtFY2v75zWaWZRMN3XZuKGI2FHeI88oEoD6t2UA)tD2cV2MoBpdIgvOBOAN1FhDwhNZYPJLqcX0a80fM6xnDz7Q9tNrDfPUmDHPEy0Ko9jBxTNNbjpVAEEhp3epNo9jBxT)PoBHxBtNTNbrJk0nuTZ6VJoRbbZYPJLqcX0a80zuxrQltxyQhgnPtFrLvfsiAeccOZu)kEgaphkphlgpRoBHxB88oEMIeu0(lKqC6ct9RMEuzvHeIgHGa6m1VA0zDinlNowcjetdWtxyQF10JkRkKq0ieeqNP(vtNrDfPUm9M4z1zl8AJN3XZTHBvbIL(OsqRuQriiGot9RSpSesiM45D8SWupmAsN(IkRkKq0ieeqNP(v8mi55vMoBpdIgvOBOAN1FhDwhYNLthlHeIPb4PZOUIuxMU9IGg7Vqt8my883Plm1VA6HDiAuXlD0z93qNLthlHeIPb4PZOUIuxMo7oy6(upBuqWvMKqxSbfk(OOK2ZZ745MXZPtFT)sPxGX61weuOUU)rXaXllpdgphpphlgp3epRcel91(lLEbgRxBrqH66(hwcjet8CCNUWu)QPZei0im1VYaDRoDOBvtjb40tcDXguOOPLITJoR)(DwoDSesiMgGNoJ6ksDz6S7GP7t9SrbbxzscDXguO4JIbIxwEgmEw9a0ONj540fM6xn9KqxySxeC0z934NLtxyQF10JSOXvmWoDSesiMgGhDw)DLz50XsiHyAaE6mQRi1LPNo9f2HOrfV0N6SfETnDHP(vtpqGiHZmuPvJO4OZ6VREwoDSesiMgGNoJ6ksDz6nXZQaXsFHDiAuXl9HLqcX00fM6xn9abIeoZqLwnIIJoR)UQz50XsiHyAaE6ct9RMU1B)VYaDcC6mQRi1LPlm1dJM0PpR3(FLb6eipdsa88k88oEUjEoD6Z6T)xzGob(uNTWRTPZ2ZGOrf6gQ2z93rN1FJZz50XsiHyAaE6mQRi1LPtgrq88cd7QqcrtcdCl(SQWwWZGbGNxvO8CSy8mzebXZlmSRcjenjmWT4lQLN3XZQhGg9mjh5zqYZRA6ct9RMEIkEzGobo6S(liywoDHP(vtprfVm2lcoDSesiMgGhDw)nKMLtxyQF10T)s6(yipOoDSesiMgGhD0PBXz5S(7SC6ct9RM(Vev60XsiHyAaE0zD8ZYP7LIuAuRACIPNqYicIN9xs3hdgqsfg(SQWwagGvMUWu)QPNOIxg7fbNowcjetdWJoRxzwoDHP(vt3(lP7JH8G60XsiHyAaE0rhD0rNba]] )


end