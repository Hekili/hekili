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


if UnitClassBase( "player" ) == 'WARLOCK' then
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
            if k == "count" or k == "current" then return t.actual

            elseif k == "actual" then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
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
        rapid_contagion = 5386, -- 344566
        rot_and_decay = 16, -- 212371
        shadow_rift = 5392, -- 353294
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
            duration = 60,
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
            duration = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
            max_stack = 1,
            tick_time = function () return haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        },
        drain_soul = {
            id = 198590,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function ()
                if not settings.manage_ds_ticks then return nil end
                return haste
            end,
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
            duration = 16,
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
            aliasMode = "longest",
            aliasType = "debuff",
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
        demon_armor = {
            id = 285933,
            duration = 3600,
            max_stack = 1,
        },
        essence_drain = {
            id = 221715,
            duration = 10,
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
        malefic_wrath = {
            id = 337125,
            duration = 8,
            max_stack = 1
        },

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


    spec:RegisterGear( "tier28", 188884, 188887, 188888, 188889, 188890 )

    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364437, "tier28_4pc", 363953 )
    -- 2-Set - Deliberate Malice - Malefic Rapture's damage is increased by 15% and each cast extends the duration of Corruption, Agony, and Unstable Affliction by 2 sec.
    -- 4-Set - Calamitous Crescendo - While Agony, Corruption, and Unstable Affliction are active, your Drain Soul has a 10% chance / Shadow Bolt has a 20% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    spec:RegisterAura( "calamitous_crescendo", {
        id = 364322,
        duration = 10,
        max_stack = 1,
    } )

    spec:RegisterGear( "tier21", 152174, 152177, 152172, 152176, 152173, 152175 )
    spec:RegisterGear( "tier20", 147183, 147186, 147181, 147185, 147182, 147184 )
    spec:RegisterGear( "tier19", 138314, 138323, 138373, 138320, 138311, 138317 )
    spec:RegisterGear( "class", 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )

    spec:RegisterGear( "amanthuls_vision", 154172 )
    spec:RegisterGear( "hood_of_eternal_disdain", 132394 )
    spec:RegisterGear( "norgannons_foresight", 132455 )
    spec:RegisterGear( "pillars_of_the_dark_portal", 132357 )
    spec:RegisterGear( "power_cord_of_lethtendris", 132457 )
    spec:RegisterGear( "reap_and_sow", 144364 )
    spec:RegisterGear( "sacrolashs_dark_strike", 132378 )
    spec:RegisterGear( "soul_of_the_netherlord", 151649 )
    spec:RegisterGear( "stretens_sleepless_shackles", 132381 )
    spec:RegisterGear( "the_master_harvester", 151821 )


    --[[ spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
        for i = 1, 5 do
            local aura = "unstable_affliction_" .. i

            if debuff[ aura ].down then
                applyDebuff( "target", aura, duration or 8 )
                break
            end
        end
    end ) ]]


    spec:RegisterHook( "reset_preauras", function ()
        if class.abilities.summon_darkglare.realCast and state.now - class.abilities.summon_darkglare.realCast < 20 then
            target.updated = true
        end
    end )


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
            cast = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
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

            break_any = function ()
                if not settings.manage_ds_ticks then return true end
                return nil
            end,

            tick_time = function ()
                if not talent.shadow_embrace.enabled or not settings.manage_ds_ticks then return nil end
                return class.auras.drain_soul.tick_time
            end,

            start = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
                removeStack( "decimating_bolt" )
                removeBuff( "malefic_wrath" )

                if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,

            tick = function ()
                if not settings.manage_ds_ticks or not talent.shadow_embrace.enabled then return end
                applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 )
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
            nobuff = "grimoire_of_sacrifice",

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
            cast = function () return buff.calamitous_crescendo.up and 0 or 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.calamitous_crescendo.up and 0 or 1 end,
            spendType = "soul_shards",

            startsCombat = true,
            texture = 236296,

            handler = function ()
                if legendary.malefic_wrath.enabled then addStack( "malefic_wrath", nil, 1 ) end

                if set_bonus.tier28_2pc > 0 then
                    if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 2 end
                    if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 2 end
                    if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 2 end
                end

                if buff.calamitous_crescendo.up then removeBuff( "calamitous_crescendo" ) end
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
                removeBuff( "malefic_wrath" )
            end,

            impact = function ()
                if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 57 and 120 or 180 ) end,
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

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },


        summon_voidwalker = {
            id = 697,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "voidwalker" ) end,
        },


        summon_felhunter = {
            id = 691,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
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

            spend = function () return buff.fel_domination.up and 0 or 1 end,
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
                },
                -- Legendary
                languishing_soul_detritus = {
                    id = 356255,
                    duration = 8,
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

            indicator = function()
                if active_enemies > 1 and settings.cycle and target.time_to_die > shortest_ttd then return "cycle" end
            end,

            handler = function ()
                applyBuff( "decimating_bolt", nil, 3 )
                if legendary.shard_of_annihilation.enabled then
                    applyBuff( "shard_of_annihilation" )
                end
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                decimating_bolt = {
                    id = 325299,
                    duration = 3600,
                    max_stack = 3,
                },
                shard_of_annihilation = {
                    id = 356342,
                    duration = 44,
                    max_stack = 1,
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
                if legendary.decaying_soul_satchel.enabled then
                    applyBuff( "decaying_soul_satchel", nil, active_dot.soul_rot )
                end
            end,

            auras = {
                soul_rot = {
                    id = 325640,
                    duration = 8,
                    max_stack = 1
                },
                decaying_soul_satchel = {
                    id = 356369,
                    duration = 8,
                    max_stack = 4,
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
                    copy = "impending_catastrophe_dot"
                },
            }
        },


    } )


    spec:RegisterSetting( "manage_ds_ticks", false, {
        name = "Model |T136163:0|t Drain Soul Ticks",
        desc = "If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of " ..
            "other spells.  This is generally not worth it, but is technically more accurate.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "agony_macro", nil, {
        name = "|T136139:0|t Agony Macro",
        desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
        type = "input",
        width = "full",
        multiline = true,
        get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.agony.name end,
        set = function () end,
    } )

    spec:RegisterSetting( "corruption_macro", nil, {
        name = "|T136118:0|t Corruption Macro",
        desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
        type = "input",
        width = "full",
        multiline = true,
        get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.corruption.name end,
        set = function () end,
    } )

    spec:RegisterSetting( "sl_macro", nil, {
        name = "|T136188:0|t Siphon Life Macro",
        desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
        type = "input",
        width = "full",
        multiline = true,
        get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.siphon_life.name end,
        set = function () end,
    } )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "spectral_intellect",

        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20220305, [[defX1eqikPSiPQa1JKQI2Kk0NKQQrbrDkiLvjvL0RqvzwQOUfGu2LO(fQQggGQogLKLPc8mvqMMkcxJsQABaQ03urughKk15KQs06KQsnpvKUhe2heXbLQcTqispesvMOkOCrivInQIOYhLQcKrkvfuNKsQyLsvEPkIQYmHuv3ufuTtaXpHujnuvezPusLEQinvaLRkvLWwLQc4RaQySas2Rk9xfgmOdt1Ib4XumzfDzKntP(SuA0sXPfwTkIQ8Aiz2qDBG2nPFlz4sLJdivlxvphLPtCDuz7OkFxegpKkoViA9svbz(uI7RIOQA)k91QlWUPtxOlqoa4p4aG)qaV1NT6eNW6pXnvs2r30o3GYBPBQ6G0nTpABJdJeLEt78K4YNxGDtzf3BOBAJiDS(MF(BdPHdq2uG8ZcqoSlrPM3Tf(zbOH)BkaUalwh9c4MoDHUa5aG)Gda(db8wF2QtCcR)qh6MY6iZfihaCT(BAtmNKEbCtNeZCt7J224WirPle44pUmO2EhU)MMfA9Nx4ba)bhS92EOxJRTeRV3EaTf2hNtAUW0ocJxi6xgu5ThqBH9X5KMl8WiEf3VWd3BdtE7b0wyFCoP5cb8KJY04Qs4fIR2WSq76x4H9EOlmT4W5ThqBHalb5Ow4H7yYoml066Dc3tlexTHzHsTWe1JAHH9ctwC9)0cbdgl02f6luCmPYcdDHsJll8Re5ThqBHOlQdatl066GDUklSpABJdJeLYw4jX7KwO4ysL82dOTqGLGCuSfk1cDEvmxiaCLi02fEy(JQf7pTWqxiihwcGM4Fljlmb)1cpm0vGXwixxE7b0wi6v6KugTqwbsl8W8hvl2FAHN0tDl04ymBHsTWNMCgAHMcSJtCjkDHsas5ThqBHPKSqwbsl04y8Wnsu6ahmzHKkFqSfk1czYhgzHsTqNxfZfAAidQqBxioycBHsJllmrP9lleaTWNCtdnxiYERhQ1qlV9aAleDvXjxykrZfwQHwy3taToomoV9aAlSpop5XXKf2hmaUxxi6DySfcGSRNwiPZfw2l0oABK(GxiUAdZcLAHExho5clfNCHsTqafJTq7OTrylezTKfkVZAwyNBqXqlV9aAl8KdtSgZ72c)9bkSlbMwyAH5rQSqJRgcpc7fAACTLMluQfgQq)Z1jJWoV9aAl06Oc1(UqleiK5RfE4aNf29r9HKCH4Gj5T32Znsukl39KPab4ccBcpMfyOUeLEoSribiHeG)O16ij74GhD0Aa4STZTFawXtJYEWCZh2HHYCDBp3irPSC3tMceGl8HGFghiyPJos2EUrIsz5UNmfiax4db)CmAecbEwDqcHuG0OShGLYKV4ydtPm55msukB75gjkLL7EYuGaCHpe8ZXOrie4z1bjeSctEdBWiZtYqitJgaDoA75gjkLL7EYuGaCHpe83(byfpnk7bZnFyhg6CyJqCmPsU9dWkEAu2dMB(WomuMuhaMMBp3irPSC3tMceGl8HGFBmXAmVBlBp3irPSC3tMceGl8HGFE(hoamDwDqcXSe24jFM8mphZriCJe8OXSKSP(NRtIsrcWF0nsWJgZsYEBPjrcWF0nsWJgZsYCktCayA4224WirPib4pIS1ehtQKzrxtPdCytzsDayAAXIBKGhnMLKzrxtPdCytib4r7iYZsYDnUkf4GfAlh2)qsMLWGk0wlwSM4ysLCxJRsboyH2YH9pKKzsDayAI22Znsukl39KPab4cFi4Nr0Cu2dt9pxNeLEghknmtewb8NdBeSocJhI)TKWYmIMJYEyQ)56KO0HxesqCOTNBKOuwU7jtbcWf(qWFJZPY2Znsukl39KPab4cFi4NtzIdatd32ghgjkD7T9qxqhYWj0CHep6tUqjaPfkn0cDJu)cd2cDEEGDaykV9CJeLYqW6imEGldQTNBKOugFi4Fs8kUFa6THz75gjkLXhc(nogpCJeLoWbtoRoiHWl6mt(WiiS6CyJWnsWJgKsGbXqYH2EUrIsz8HGFqht2Hz8ENW905WgbaoB7SXXoyifhByEIziDwzUUTh65y8czuN)Uql0nsu6cXbtwOD9leiK5lC9ZfE4aNfg6ctbwEHOh3)Kk4KlSuCYfwDsag9HO5cTRFHCmAHjcPzHNuAE75gjkLXhc(FoD4gjkDGdMCwDqcHsMVgGjoZKpmccRoh2imfpsDvYkz(cx)84ZPKD9Tug0XKDygjExAo6gj4rdsjWGyiS6O4ysLCxJRsboyH2YH9pKKBV(OrIsxioycBH21Vq5dffjlea148I6ZlmvCHTq)PfYCE0CH21VqaKD90ctlo8cTULWV1bSJ0zOTle9CXzYxDne)NuJRsbUW0qB5W(hsYZlSKg6temAHLUqtv4zLqZBp3irPm(qWVXX4HBKO0boyYz1bjeYhkksgSoCidtdzqT9CJeLY4db)ghJhUrIsh4GjNvhKqmjSNKMd5dffjSTNBKOugFi434y8Wnsu6ahm5S6GecM4Yq(qrrc7mt(WiiS6CyJa5zjzwXHhFjzjmOcT1ILzj5aSJ0zOTdJlot(QRHgZsYsyqfARflZsYDnUkf4GfAlh2)qsMLWGk0w0oYko8G14)ejhYILzjzEbMgIhQKLWGk0wlwehtQKzvIH0qdgrt22ZnsukJpe8BCmE4gjkDGdMCwDqcX0b9wAiFOOiHDoSrykEK6QK1OTrg2oDezRXZ)WbGPS8HIIKbRdhIflMQWZkHMzfhE8LKFc0dLHKdaElwqMN)Hdatz5dffjJsPJMQWZkHMzfhE8LKFc0dLDQ8HIIKSvztv4zLqZpb6HYqZIfK55F4aWuw(qrrYqsuhnvHNvcnZko84lj)eOhk7u5dffj5dYMQWZkHMFc0dLHgAwSykEK6QK5rQ0K8pIS145F4aWuw(qrrYG1HdXIftv4zLqZbyhPZqBhgxCM8vxdLFc0dLHKdaElwqMN)Hdatz5dffjJsPJMQWZkHMdWosNH2omU4m5RUgk)eOhk7u5dffjzRYMQWZkHMFc0dLHMfliZZ)WbGPS8HIIKHKOoAQcpReAoa7iDgA7W4IZKV6AO8tGEOStLpuuKKpiBQcpReA(jqpugAOzXcYMIhPUkzLmFHRFAXIP4rQRsgvYpC1IftXJuxLSwkH2rKTgp)dhaMYYhkksgSoCiwSyQcpReAURXvPahSqB5W(hsY8tGEOmKCaWBXcY88pCayklFOOizukD0ufEwj0CxJRsboyH2YH9pKK5Na9qzNkFOOijBv2ufEwj08tGEOm0SybzE(hoamLLpuuKmKe1rtv4zLqZDnUkf4GfAlh2)qsMFc0dLDQ8HIIK8bztv4zLqZpb6HYqdnlwSM4ysLCxJRsboyH2YH9pKKzsDayAEezRXZ)WbGPS8HIIKbRdhIflMQWZkHMzCGGLoM(JQf7pLFc0dLHKdaElwqMN)Hdatz5dffjJsPJMQWZkHMzCGGLoM(JQf7pLFc0dLDQ8HIIKSvztv4zLqZpb6HYqZIfK55F4aWuw(qrrYqsuhnvHNvcnZ4ablDm9hvl2Fk)eOhk7u5dffj5dYMQWZkHMFc0dLHgABpKY96czfhEHSg)NSfg2l0oABKfgSf6yWIjlS4r)2ZnsukJpe8d6yYomJ37eUNoh2iaum2r7OTrgpb6HYoLqhYWj0qcqQVYko8G14)84SKmNYehaMgUTnomsuAwcdQqB3Ewh7fAkEK6QSWzj8FsnUkf4ctdTLd7FijxyWw4ZPAOTNxihJw4H5pQwS)0cLAHe6iKoxO0ql0W9pPYczKS9CJeLY4db)ghJhUrIsh4GjNvhKqm9hvl2FA09u35WgbYMIhPUkzEKknj)JZsYbyhPZqBhgxCM8vxdnMLKLWGk02JMQWZkHMzCGGLoM(JQf7pLFc0dLD6bhrEwsURXvPahSqB5W(hsY8tGEOmKCGflwtCmPsURXvPahSqB5W(hss0qZIfKnfpsDvYA02idBNooljZko84ljlHbvOThnvHNvcnZ4ablDm9hvl2Fk)eOhk70doI8SKCxJRsboyH2YH9pKK5Na9qzi5alwSM4ysLCxJRsboyH2YH9pKKOHMfliJSP4rQRswjZx46NwSykEK6QKrL8dxTyXu8i1vjRLsODCwsURXvPahSqB5W(hsYSeguH2ECwsURXvPahSqB5W(hsY8tGEOStpaTTN1LSFI1SWzjSfs(JtUWWEHTvOTlmuPwOVqwJ)ZfY6iDgA7c7ACgT9CJeLY4db)ghJhUrIsh4GjNvhKqmlz09u35WgbYMIhPUkznABKHTthT2SKmR4WJVKSeguH2E0ufEwj0mR4WJVK8tGEOStpbAwSGSP4rQRsMhPstY)O1MLKdWosNH2omU4m5RUgAmljlHbvOThnvHNvcnhGDKodTDyCXzYxDnu(jqpu2PNanlwqgztXJuxLSsMVW1pTyXu8i1vjJk5hUAXIP4rQRswlLq7O4ysLCxJRsboyH2YH9pKKhT2SKCxJRsboyH2YH9pKKzjmOcT9OPk8SsO5UgxLcCWcTLd7FijZpb6HYo9eOT9So2l8KACvkWfMgAlh2)qsUWGTqjmOcT98cdzHbBHm3MwOulKJrl8W8h1ctlo82ZnsukJpe8p9h1GvC4ZHnIzj5UgxLcCWcTLd7FijZsyqfA72ZnsukJpe8p9h1GvC4ZHncRjoMuj314QuGdwOTCy)dj5rKNLKzfhE8LKLWGk0wlwMLKdWosNH2omU4m5RUgAmljlHbvOTOT9stQMfEsnUkf4ctdTLd7FijxyIqAwyFasLMKp)ajABKfEY50cnfpsDvw4SKZlSKg6temAHCmAHLUqtv4zLqZl06yVq0fWUKp54fIU(t1vdTqaC22lmylmutbgA75f2u45c5ujWlmK(zl8jFMCHiBf6EHmYu6KTq3wOFHCmcTTNBKOugFi4VRXvPahSqB5W(hsYZHnctXJuxLSgTnYW2PJsasiX6pAQcpReAMvC4Xxs(jqpu2PwDez5dffjzcSl5toEu)uD1qztv4zLqZpb6HYo1kG7bwSyncOZfDD0mtGDjFYXJ6NQRgcTTNBKOugFi4VRXvPahSqB5W(hsYZHnctXJuxLmpsLMK)rjajKy9hnvHNvcnhGDKodTDyCXzYxDnu(jqpu2PwDez5dffjzcSl5toEu)uD1qztv4zLqZpb6HYo1kG7bwSyncOZfDD0mtGDjFYXJ6NQRgcTThqiZx46Nlmrinl8WDmzhMfcCExAwOXzcBHDnUkf4czH2YH9pKKlm0fIdLwyIqAw4HrMa0LqBxislSS9CJeLY4db)DnUkf4GfAlh2)qsEoSrykEK6QKvY8fU(5XNtj76BPmOJj7Wms8U0Cucqcjw)rtv4zLqZtYeGUeA7aqHL8tGEOStp0rKLpuuKKjWUKp54r9t1vdLnvHNvcn)eOhk7uRaUhyXI1iGox01rZmb2L8jhpQFQUAi02EORsd9l0u8i1vHTqKd1G5MH2UqTuG2HdCwiqiZxOTqJZKfEsPlS0fAQcpRe62ZnsukJpe8314QuGdwOTCy)dj55WgbYMIhPUkzuj)WvlwmfpsDvYAPKfliBkEK6QKvY8fU(5rR9CkzxFlLbDmzhMrI3Lg0q7iYYhkksYeyxYNC8O(P6QHYMQWZkHMFc0dLDQva3dSyXAeqNl66OzMa7s(KJh1pvxneABp3irPm(qWFxJRsboyH2YH9pKKNdBeakg7OD02iJNa9qzNAfWD7zDSx4j14QuGlmn0woS)HKCHbBHsyqfA75fgs)SfkbiTqPwihJwyjn0Vqq)Kx9lCwcB75gjkLXhc(nogpCJeLoWbtoRoiHWu8i1v5mt(WiiS6CyJywsURXvPahSqB5W(hsYSeguH2EeztXJuxLSgTnYW2jlwmfpsDvY8ivAs(OT9CJeLY4db)EBPjpBsAW0q8VLegcRoh2iMLK92stMFc0dLD6j2EUrIsz8HG)gNtLTxALyHsdTWuIMSfw6cp0cf)BjHTWWEHHSWGP9ll0W9pPco5cdDH24OTrwy9lS0fkn0cf)BjjVqGtinlmn6AkDHOFytlmK(zl0XSAHairOFHsTqogTWuIMlS4r)cbDLZX4Kl076WjdTDHhAHOx9pxNeLYYBp3irPm(qWpJO5OShM6FUojk9CyJWnsWJgKsGbXqYbhfhtQKzvIH0qdgrt2rRnljZiAok7HP(NRtIsZsyqfA7rRf6WghTnY2ZnsukJpe8ZiAok7HP(NRtIsph2iCJe8ObPeyqmKCWrXXKkzw01u6ah20rRnljZiAok7HP(NRtIsZsyqfA7rRf6WghTnYXzjzt9pxNeLMFc0dLD6j2EUrIsz8HGFEbMgIhQCoSrGmR4WdwJ)tKyLflUrcE0GucmigsoaTJMQWZkHMzCGGLoM(JQf7pLFc0dLHeRoy75gjkLXhc(5uM4aW0WTTXHrIsph2iCJe8OXSKmNYehaMgUTnomsukcG3IfjmOcT94SKmNYehaMgUTnomsuA(jqpu2PNy75gjkLXhc(zrxtPdCytNnjnyAi(3scdHvNdBeZsYSORP0boSP8tGEOStpX2ZnsukJpe8BCmE4gjkDGdMCwDqcHP4rQRYzM8Hrqy15WgH1mfpsDvYkz(cx)C71h76Wjxi6v)Z1jrPle0vohJtUWsxOvaTdwO4FljSZlS(fw6cp0ctesZc7JayfMtOfIE1)CDsu62ZnsukJpe8BQ)56KO0ZMKgmne)BjHHWQZHnc3ibpAqkbge70ta0qwCmPsMvjgsdnyenzwSioMujZIUMsh4WMq74SKSP(NRtIsZpb6HYo9GTxF0wOFHsdTWQJu6pVqwhPZf6lK14)CHjAiDHUSqRFHLUWd3XKDywO117eUNwOul05vXCHfp6nExxOTBp3irPm(qWpOJj7WmEVt4E6CyJGvC4bRX)jsoXrjajKCGvBpGtdPlulzHSKQj02fEsnUkf4ctdTLd7FijxOulSpaPstYNFGeTnYcp5C68ct5ablDHhM)OAX(tlmSxOJXlCwcBH(tl076Wbn3EUrIsz8HGFJJXd3irPdCWKZQdsiM(JQf7pn6EQ7CyJaztXJuxLmpsLMK)rRjoMuj314QuGdwOTCy)dj5Xzj5aSJ0zOTdJlot(QRHgZsYsyqfA7rtv4zLqZmoqWsht)r1I9NYp5ZKOzXcYMIhPUkznABKHTthTM4ysLCxJRsboyH2YH9pKKhNLKzfhE8LKLWGk02JMQWZkHMzCGGLoM(JQf7pLFYNjrZIfKr2u8i1vjRK5lC9tlwmfpsDvYOs(HRwSykEK6QK1sj0oAQcpReAMXbcw6y6pQwS)u(jFMeTTxFbJw4H5pQfMwC4fg2l8W8hvl2FAHjkTFzHaOf(KptUqV1d98cRFHH9cLg6PfMiW4fcGwOlletotw4bleSEAHhM)OAX(tlKJrSTNBKOugFi4F6pQbR4WNdBeakg7OPk8SsOzghiyPJP)OAX(t5Na9qziXoABKXtGEOSJiBnXXKk5UgxLcCWcTLd7FijTyXufEwj0CxJRsboyH2YH9pKK5Na9qziXoABKXtGEOm02EUrIsz8HG)P)OgSIdFoSraOySJwtCmPsURXvPahSqB5W(hsYJMQWZkHMzCGGLoM(JQf7pLFc0dLXNPk8SsOzghiyPJP)OAX(t5j37su6P2rBJmEc0dLT9qpxmnanhJxyie4c5yElTq76xORjLMqBxOwYczDKjSdAUqcZOen0tBp3irPm(qWVXX4HBKO0boyYz1bjeHqGBpRlz)eRzHPn(SsSq0fqaVBOfcGSRNwiRJ0zOTlK14)KTWsx4H7yYoml066Dc3tBp3irPm(qWVXX4HBKO0boyYz1bjem6CyJqCmPsM14ZkXGab8UHYK6aW08iYtcaNTDM14ZkXGab8UHYmXnOof5daAUrIsZSgFwjgakSKdDyJJ2gbnlwMeaoB7mRXNvIbbc4DdLFc0dLD6HqB71xWOfE4oMSdZcTUENW90ct0q6cb9tE1VWzjSf6pTqUUZlS(fg2luAONwyIaJxiaAHSOvd7W4QSqjaPfYPsGxO0qluj0rw4j14QuGlmn0woS)HKmVqRJ9c5Kah9HcTDHhUJj7WSqGZ7sZ5f2u45c9fYA8FUqPw4t2pXAwO0qleaNT92ZnsukJpe8d6yYomJ37eUNoh2iqEwsMxGPH4HkzjmOcT1ILzj5aSJ0zOTdJlot(QRHgZsYsyqfARflZsYSIdp(sYsyqfAlAhr2ApNs213szqht2HzK4DPXIfaC22zqht2HzK4DPjZe3G60dzXcR4WdwJ)tKyfABV(cgTWd3XKDywO117eUNwOule0dv8qxO0qle0XKDywyI3LMfcGZ2EHCQe4fYA8FYwOs0CHsTqa0cBjLExO5cTRFHsdTqLqhzHa4EMSWeHoRele5da(fYitPt2cd2cbRNwO046czC22HjivwOulSLu6DHw4HwiRX)jdTTNBKOugFi4h0XKDygV3jCpDoSr8CkzxFlLbDmzhMrI3LMJMQWZkHMzfhE8LKFc0dLHKda(Ja4STZGoMSdZiX7st(jqpu2PNy7D4EOIh6cpCht2HzHaN3LMf6YcDmEHsasSfAx)cLgAHaHmFHRFUW6x4jFj)W1fAkEK6QS9CJeLY4db)GoMSdZ49oH7PZHnINtj76BPmOJj7Wms8U0CeztXJuxLSsMVW1pTyXu8i1vjJk5hUI2raC22zqht2HzK4DPj)eOhk70tS96ly0cpCht2HzHwxVt4EAHLUWtQXvPaxyAOTCy)dj5cnotyNxiOJk02fY4EAHsTqMZJwOVqwJ)Zfk1czIBqTWd3XKDywiW5DPzHH9c5yH2UWq2EUrIsz8HGFqht2Hz8ENW905WgH4ysLCxJRsboyH2YH9pKKhrEwsURXvPahSqB5W(hsYSeguH2AXIPk8SsO5UgxLcCWcTLd7FijZpb6HYqYbwVflakg7OeG0qQXmOtnvHNvcn314QuGdwOTCy)djz(jqpugAhr2ApNs213szqht2HzK4DPXIfaC22zqht2HzK4DPjZe3G60dzXcR4WdwJ)tKyfABp3irPm(qWpOJj7WmEVt4E6CyJqCmPsMvjgsdnyenzBVd79qxi6h20cd2clfNCH(cpStkDHTEOlmrinl06OeVqCayAHhgbgmAHk5)cbD0zHmXnOy5fADSxOD02ilmyl0buCYcLAHKox4SwOwYcbdgBHSosNH2UqPHwitCdk22ZnsukJpe8pFp0boSPZHncaC225qjEH4aW0ysGbJYmXnOqYjaElwaWzBNdL4fIdatJjbgmkZ1DeqXyhTJ2gz8eOhk70tS9CJeLY4db)ghJhUrIsh4GjNvhKqykEK6QS9CJeLY4db)EBPjpBsAW0q8VLegcRoh2iEY(jwJdatBp3irPm(qWpNYehaMgUTnomsu65WgHBKGhnMLK5uM4aW0WTTXHrIsra8wSiHbvOThFY(jwJdatBp3irPm(qWpl6AkDGdB6SjPbtdX)wsyiS6CyJ4j7NynoamT9CJeLY4db)M6FUojk9SjPbtdX)wsyiS6CyJ4j7NynoamD0nsWJgKsGbXo9eanKfhtQKzvIH0qdgrtMflIJjvYSORP0boSj02EUrIsz8HGFBmXAmVBlNdBeSIddi0zMxHDjW0GvyEKkNdvO)56KryJaaNTDMxHDjW0GvyEKkzUUTNBKOugFi4F(EOdwXHphQq)Z1jiSA75gjkLXhc(zn(Ssmauyz7T9CJeLYYEri6ACvkWbl0woS)HKC75gjkLL9I4db)noNkBp3irPSSxeFi434y8Wnsu6ahm5S6GeIP)OAX(tJUN6oh2imfpsDvY8ivAs(hNLKdWosNH2omU4m5RUgAmljlHbvOThnvHNvcnZ4ablDm9hvl2Fk)KptEe5zj5UgxLcCWcTLd7FijZpb6HYqYbwSynXXKk5UgxLcCWcTLd7FijrZIftXJuxLSgTnYW2PJZsYSIdp(sYsyqfA7rtv4zLqZmoqWsht)r1I9NYp5ZKhrEwsURXvPahSqB5W(hsY8tGEOmKCGflwtCmPsURXvPahSqB5W(hss0SybztXJuxLSsMVW1pTyXu8i1vjJk5hUAXIP4rQRswlLq74SKCxJRsboyH2YH9pKKzjmOcT94SKCxJRsboyH2YH9pKK5Na9qzNEW2Znsukl7fXhc(zenhL9Wu)Z1jrPNdBeIJjvYSkXqAObJOj7OX1bJO52Znsukl7fXhc(zenhL9Wu)Z1jrPNdBewtCmPsMvjgsdnyenzhT2SKmJO5OShM6FUojknlHbvOThTwOdBC02ihNLKn1)CDsuA(j7NynoamT9CJeLYYEr8HGFVT0KNnjnyAi(3scdHvNdBeUrcE0yws2Bln5PN4O1MLK92stMLWGk02TNBKOuw2lIpe87TLM8SjPbtdX)wsyiS6CyJWnsWJgZsYEBPjrcItC8j7NynoamDCws2BlnzwcdQqB3EUrIszzVi(qWpNYehaMgUTnomsu65WgHBKGhnMLK5uM4aW0WTTXHrIsra8wSiHbvOThFY(jwJdatBp3irPSSxeFi4NtzIdatd32ghgjk9SjPbtdX)wsyiS6CyJWAsyqfA7XoEDIJjvYVd25QmCBBCyKOuwMuhaMMhDJe8OXSKmNYehaMgUTnomsu6PhA75gjkLL9I4db)8cmnepu5CyJGvC4bRX)jsSA75gjkLL9I4db)ghJhUrIsh4GjNvhKqykEK6QCMjFyeewDoSryntXJuxLSsMVW1p3EUrIszzVi(qWVXX4HBKO0boyYz1bjet)r1I9NgDp1DoSrGSP4rQRsMhPstY)iYMQWZkHMdWosNH2omU4m5RUgk)KptAXYSKCa2r6m02HXfNjF11qJzjzjmOcTfTJMQWZkHMzCGGLoM(JQf7pLFYNjpI8SKCxJRsboyH2YH9pKK5Na9qzi5alwSM4ysLCxJRsboyH2YH9pKKOH2rKr2u8i1vjRK5lC9tlwmfpsDvYOs(HRwSykEK6QK1sj0oAQcpReAMXbcw6y6pQwS)u(jqpu2PhCe5zj5UgxLcCWcTLd7FijZpb6HYqYbwSynXXKk5UgxLcCWcTLd7Fijrdnlwq2u8i1vjRrBJmSD6iYMQWZkHMzfhE8LKFYNjTyzwsMvC4XxswcdQqBr7OPk8SsOzghiyPJP)OAX(t5Na9qzNEWrKNLK7ACvkWbl0woS)HKm)eOhkdjhyXI1ehtQK7ACvkWbl0woS)HKen02EUrIszzVi(qW)0FudwXHph2iaum2rtv4zLqZmoqWsht)r1I9NYpb6HYqID02iJNa9qzhr2AIJjvYDnUkf4GfAlh2)qsAXIPk8SsO5UgxLcCWcTLd7FijZpb6HYqID02iJNa9qzOT9CJeLYYEr8HG)P)OgSIdFoSraOySJMQWZkHMzCGGLoM(JQf7pLFc0dLXNPk8SsOzghiyPJP)OAX(t5j37su6P2rBJmEc0dLT9CJeLYYEr8HGFJJXd3irPdCWKZQdsicHa3EUrIszzVi(qWVXX4HBKO0boyYz1bjetc7jP5q(qrrcB75gjkLL9I4db)ghJhUrIsh4GjNvhKqmDqVLgYhkksyBp3irPSSxeFi434y8Wnsu6ahm5S6GecM4Yq(qrrc7mt(WiiS6CyJywsURXvPahSqB5W(hsYSeguH2AXI1ehtQK7ACvkWbl0woS)HKC75gjkLL9I4db)GoMSdZ49oH7PZHnIzjzEbMgIhQKLWGk02TNBKOuw2lIpe8d6yYomJ37eUNoh2iMLKzfhE8LKLWGk02JwtCmPsMvjgsdnyenzBp3irPSSxeFi4h0XKDygV3jCpDoSrynXXKkzEbMgIhQS9CJeLYYEr8HGFqht2Hz8ENW905WgbR4WdwJ)tKCITNBKOuw2lIpe8ZIUMsh4WMoBsAW0q8VLegcRoh2iCJe8OXSKml6AkDGdB6ueh64t2pXACay6O1MLKzrxtPdCytzjmOcTD75gjkLL9I4db)ghJhUrIsh4GjNvhKqykEK6QCMjFyeewDoSrykEK6QKvY8fU(52Znsukl7fXhc(NVh6ah205WgbaoB7COeVqCayAmjWGrzM4guibH1d8wSaOySJa4STZHs8cXbGPXKadgL56oAhTnY4jqpu2PwVfla4STZHs8cXbGPXKadgLzIBqHeehY6poljZko84ljlHbvOTBp3irPSSxeFi43gtSgZ72Y5WgbR4WacDM5vyxcmnyfMhPY5qf6FUoze2iaWzBN5vyxcmnyfMhPsMRB75gjkLL9I4db)Z3dDWko85qf6FUobHvBp3irPSSxeFi4N14ZkXaqHLT32ZnsuklBkEK6QGia7iDgA7W4IZKV6AOZHncRjoMuj314QuGdwOTCy)dj5rKnvHNvcnZ4ablDm9hvl2Fk)eOhk7uRaElwmvHNvcnZ4ablDm9hvl2Fk)eOhkdjwpWBXIPk8SsOzghiyPJP)OAX(t5Na9qzi5aR)OP0jxizt9pxNeA7at0J22ZnsuklBkEK6QWhc(dWosNH2omU4m5RUg6CyJqCmPsURXvPahSqB5W(hsYJZsYDnUkf4GfAlh2)qsMLWGk02TNBKOuw2u8i1vHpe8pjta6sOTdafwoh2imvHNvcnZ4ablDm9hvl2Fk)eOhkdjw)rKNeaoB7CJZPs(jqpugsoHflwtCmPsUX5ubTTNBKOuw2u8i1vHpe8Zko84l5CyJWAIJjvYDnUkf4GfAlh2)qsEeztv4zLqZmoqWsht)r1I9NYpb6HYo16TyXufEwj0mJdeS0X0FuTy)P8tGEOmKy9aVflMQWZkHMzCGGLoM(JQf7pLFc0dLHKdS(JMsNCHKn1)CDsOTdmrpABp3irPSSP4rQRcFi4NvC4XxY5WgH4ysLCxJRsboyH2YH9pKKhNLK7ACvkWbl0woS)HKmlHbvOTBp3irPSSP4rQRcFi4NzkUp02HesdT92EUrIsz5Pd6T0q(qrrcdbhJgHqGNvhKqWko8iA1qOF75gjkLLNoO3sd5dffjm(qWphJgHqGNvhKqmFYN2XtdEeJr4TNBKOuwE6GElnKpuuKW4db)CmAecbEwDqcrlozxZOShoJfGb2LO0TNBKOuwE6GElnKpuuKW4db)CmAecbEwDqcbNAA8qP5Of7ZWL6zdwJBqHj22ZnsuklpDqVLgYhkksy8HGFogncHapRoiHGaukR4WdEHH2EBp3irPS80FuTy)Pr3tDi4fyAiEOY2Znsuklp9hvl2FA09uhFi4F6pQbR4WBp3irPS80FuTy)Pr3tD8HG)UsIs3EUrIsz5P)OAX(tJUN64db)2XtaWvn3EUrIsz5P)OAX(tJUN64db)aWvnh2CFYTNBKOuwE6pQwS)0O7Po(qWpa6z0Jk02TNBKOuwE6pQwS)0O7Po(qWVXX4HBKO0boyYz1bjeMIhPUkNzYhgbHvNdBewZu8i1vjRK5lC9ZTNBKOuwE6pQwS)0O7Po(qWpJdeS0X0FuTy)PT32ZnsuklpjSNKMd5dffjmeCmAecbEwDqcbb2L8jhpQFQUAOZHncKnfpsDvYA02idBNoAQcpReAMvC4Xxs(jqpu2Pha8OzXcYMIhPUkzEKknj)JMQWZkHMdWosNH2omU4m5RUgk)eOhk70daE0SybztXJuxLSsMVW1pTyXu8i1vjJk5hUAXIP4rQRswlLqB75gjkLLNe2tsZH8HIIegFi4NJrJqiWZQdsiyCkaCvZHdsstsMCoSrGSP4rQRswJ2gzy70rtv4zLqZSIdp(sYpb6HYof4IMfliBkEK6QK5rQ0K8pAQcpReAoa7iDgA7W4IZKV6AO8tGEOStbUOzXcYMIhPUkzLmFHRFAXIP4rQRsgvYpC1IftXJuxLSwkH22ZnsuklpjSNKMd5dffjm(qWphJgHqGNvhKqWkomMej02XZbi55WgbYMIhPUkznABKHTthnvHNvcnZko84lj)eOhk7u0nAwSGSP4rQRsMhPstY)OPk8SsO5aSJ0zOTdJlot(QRHYpb6HYofDJMfliBkEK6QKvY8fU(PflMIhPUkzuj)WvlwmfpsDvYAPeABp3irPS8KWEsAoKpuuKW4db)CmAecbEwDqcbRXNvcAoQhWOShs9GKkNdBeiBkEK6QK1OTrg2oD0ufEwj0mR4WJVK8tGEOStpbAwSGSP4rQRsMhPstY)OPk8SsO5aSJ0zOTdJlot(QRHYpb6HYo9eOzXcYMIhPUkzLmFHRFAXIP4rQRsgvYpC1IftXJuxLSwkH22B75gjkLLNLm6EQdH3wAYZHnIzjzVT0K5Na9qzNIUpAQcpReAMXbcw6y6pQwS)u(jqpugsMLK92stMFc0dLT9CJeLYYZsgDp1Xhc(zrxtPdCytNdBeZsYSORP0boSP8tGEOStr3hnvHNvcnZ4ablDm9hvl2Fk)eOhkdjZsYSORP0boSP8tGEOSTNBKOuwEwYO7Po(qWpNYehaMgUTnomsu65WgXSKmNYehaMgUTnomsuA(jqpu2PO7JMQWZkHMzCGGLoM(JQf7pLFc0dLHKzjzoLjoamnCBBCyKO08tGEOSTNBKOuwEwYO7Po(qWVP(NRtIsph2iMLKn1)CDsuA(jqpu2PO7JMQWZkHMzCGGLoM(JQf7pLFc0dLHKzjzt9pxNeLMFc0dLT92EUrIsz5qiqeCmAecbY2EBp3irPSSsMVgGjqWZ)WbGPZQdsiMLWgsyqfA7zEoMJqmljBQ)56KO08tGEOmKCWXzjzVT0K5Na9qzi5GJZsYCktCayA4224WirP5Na9qzi5GJiBnXXKkzw01u6ah2KflZsYSORP0boSP8tGEOmKCaABpG9HIIe2cDC0Qlmrinl8KsxOD9lmTXNvIfIUac4DdDEHhgsxOD9lSpSZPsE75gjkLLvY81ambFi4NN)HdatNvhKqiFOOizmjSN8mphZrimvHNvcn314QuGdwOTCy)djz(jqpu2zEoMJgeMrimvHNvcnpjta6sOTdafwYpb6HYoxDiyKe2NnLodjkfH4ysLmRXNvIbbc4DdDoSrykEK6QKvY8fU(52dPCVUqwXHxiRX)jBHH9cLgAH2rBJSWebgVqa0cjDgA7czvP5TNBKOuwwjZxdWe8HGFqht2Hz8ENW905WgHeG0qQXmOtj0HmCcnKaK6RSIdpyn(ppoljZPmXbGPHBBJdJeLMLWGk02Th65mzHnoNkluQf(K9tSMfcGSRNwOTJXLTDE75gjkLLvY81ambFi4VX5u5CyJywsUX5uj)eOhk70d4JqhYWj0qcqA71hoABwiqBHDFuFijx4HdCw4t2pXAwyyVqwhPZqBxyP0cBXfahVWefhEUqJZXOfYXwOulemySfkn0cRUU6fonKKluQf(K9tSMfE4aN8c3EUrIszzLmFnatWhc(bDmzhMX7Dc3tNdBesasi5KDeaNTDg0XKDygjExAYpb6HYoT1mZGo6WhHoKHtOHeG027KlEAHtc7jP5cLpuuKWwyOl0vjmrNlrPlSSx4HrMa0LqBxislSK3EUrIszzLmFnatWhc(5y0iec8S6GeccSl5toEu)uD1qNdBe88pCayklFOOizmjSN80da(TNBKOuwwjZxdWe8HGFogncHapRoiHGXPaWvnhoijnjzY5Wgbp)dhaMYYhkksgtc7jpf4U9CJeLYYkz(AaMGpe8ZXOrie4z1bjeSIdJjrcTD8CasEoSrWZ)WbGPS8HIIKXKWEYtr3Bp3irPSSsMVgGj4db)CmAecbEwDqcbRXNvcAoQhWOShs9GKkNdBe88pCayklFOOizmjSN80tS9So2luAOf2H9K0VWGTqowOTlSpSZPY5fAhpTWtkDHLUqtv4zLqxO0q6cTlmUsSWeH0SWddPBp3irPSSsMVgGj4db)DnUkf4GfAlh2)qsEoSrioMuj34CQCKN)Hdat5zjSHeguH2U9CJeLYYkz(AaMGpe8pjta6sOTdafwoh2iehtQKBCovoAQcpReAURXvPahSqB5W(hsY8tGEOmKa8BpRJ9cLgAHDypj9lmylKJfA7ctrxoVq74PfEyiDHLUqtv4zLqxO0q6cTlmUseA7ctesZcpP0TNBKOuwwjZxdWe8HG)jzcqxcTDaOWY5WgH4ysLmRXNvIbbc4DdDKN)Hdat5zjSHeguH2U9CJeLYYkz(AaMGpe8314QuGdwOTCy)dj55WgH4ysLmRXNvIbbc4DdD0ufEwj08KmbOlH2oauyj)eOhkdja)2ZnsuklRK5Rbyc(qWpNYehaMgUTnomsu65WgXSKmNYehaMgUTnomsuA(jqpu2Pa3TNBKOuwwjZxdWe8HGFVT0KNdBeZsYEBPjZpb6HYo9eBp3irPSSsMVgGj4db)SORP0boSPZHnIzjzw01u6ah2u(jqpu2PNy75gjkLLvY81ambFi43u)Z1jrPNdBeZsYM6FUojkn)eOhk70tS9SUK9tSMfE4aNf62c9luAOfwDKs)cd7fo9hvl2FA09u3ctuC45cnohJwihBHsTqWGXwOVWdh4SWNSFI1S9CJeLYYkz(AaMGpe8d6yYomJ37eUNoh2iKaKqYj7iaoB7mOJj7Wms8U0KFc0dLD6b91wZmd6OdFe6qgoHgsasBp0ZX4fo9hvl2FA09u3cd7fEsnUkf4ctdTLd7FijxyWwOH7FsfCYfkHbvOTBp3irPSSsMVgGj4db)ghJhUrIsh4GjNvhKqm9hvl2FA09u3zM8Hrqy15WgXSKCxJRsboyH2YH9pKKzjmOcTD71xibo6drl01KlSKg6xitCzHYhkksylmSx4j14QuGlmn0woS)HKCHbBHsyqfA72ZnsuklRK5Rbyc(qWVXX4HBKO0boyYz1bjemXLH8HIIe2zM8Hrqy15WgXSKCxJRsboyH2YH9pKKzjmOcTD7LkUb1cpCht2HzHaN3LMfk1cp05fw)cFY(jwZct0q6cBjrcTDH4kXcroMKJXjxiUkuH2Uq76xOVqJJnCyxO5cvoqa0FEHa4KfEIS1Zw4tGEOH2UWGTqPHw4tmoSSWYEHcXKqBxyIqAwiWo4KH22ZnsuklRK5Rbyc(qWpOJj7WmEVt4E6CyJqcqcjNSJidGZ2od6yYomJeVlnzM4guNEilwaWzBNbDmzhMrI3LM8tGEOStpr26rB71hNZqIsD8cpCR7czDKozlmrdPlKqh59fYA8FYwO)0cDEEGDayAHUoxifsd9l8KACvkWfMgAlh2)qsUWGTqjmOcT98cRFHsdTq7OTrwyWwiPZqBZBp3irPSSsMVgGj4db)GoMSdZ49oH7PZHncKNLK7ACvkWbl0woS)HKmlHbvOTwSibinKAmd6utv4zLqZDnUkf4GfAlh2)qsMFc0dLH2rKbWzBNbDmzhMrI3LMmtCdQtpKflSIdpyn(prIvOT96JZzirPoEHh27HUW0IdVqJZKfMOH0fEsPlmylucdQqB3EUrIszzLmFnatWhc(NVh6GvC4ZHnIzj5UgxLcCWcTLd7FijZsyqfA72d9ReleOTWUpQpKKlCwYcFY(jwZct0q6cFY(jwJdat5TNBKOuwwjZxdWe8HGFVT0KNdBepz)eRXbGPTNBKOuwwjZxdWe8HGFoLjoamnCBBCyKO0ZHnINSFI14aW02ZnsuklRK5Rbyc(qWVP(NRtIsph2iEY(jwJdatBp3irPSSsMVgGj4db)SORP0boSPZHncXXKkzw01u6ah20XNSFI14aW027KdtSgZ72YcLAHGEOIh6c7duyxcmTW0cZJujV9CJeLYYkz(AaMGpe8BJjwJ5DB5CyJGvCyaHoZ8kSlbMgScZJu5SXvdHhHncaC22zEf2LatdwH5rQmA4aDTIzMRB7H(vcGw3h1hsYf24CQSWNSFI1K3EUrIszzLmFnatWhc(BCovoh2iMLKBCovYpb6HYo9qBV(cnuH(NRtcayAHhw6cnnUQeEHH9ctqlSX5rluAOfEyiDHa4STZBp3irPSSsMVgGj4db)Z3dDWko85WgbaoB78KmbOlH2oauyjZ1T9CJeLYYkz(AaMGpe8pFp0bR4WNdBeIJjvYSgFwjgeiG3n0XjbGZ2oZA8zLyqGaE3q5Na9qzNEilwMeaoB7mRXNvIbbc4DdLzIBqD6HohQq)Z1jJWgXKaWzBNzn(SsmiqaVBOmtCdkKG4qhNeaoB7mRXNvIbbc4DdLFc0dLHKdT9CJeLYYkz(AaMGpe8pFp0bR4WNdvO)56eewT9CJeLYYkz(AaMGpe8ZA8zLyaOWY2B75gjkLLzeIgNtLTNBKOuwMr8HG)57Hoyfh(COc9pxNmAXfahJWQZHk0)CDYiSrmjaC22zwJpRedceW7gkZe3Gcjio02ZnsuklZi(qWpRXNvIbGclBVTNBKOuwMjUmKpuuKWqWXOrie4z1bjeHYmpN4aW0aOZ5QWboMeVWqBp3irPSmtCziFOOiHXhc(5y0iec8S6GeIqzYZzK6zJzWluAaGW4TNBKOuwMjUmKpuuKW4db)CmAecbEwDqcrXJEBCLi02HRbOpmElT9CJeLYYmXLH8HIIegFi4NJrJqiWZQdsiM(JcSkDmjdQrhN8eZqQH2EUrIszzM4Yq(qrrcJpe8ZXOrie4z1bjeGUXb80G1qKma5yHz75gjkLLzIld5dffjm(qWphJgHqGNvhKqyJDqAu2daUiyA75gjkLLzIld5dffjm(qWphJgHqGNvhKqKWrrk9SH9x6C75gjkLLzIld5dffjm(qWphJgHqGNvhKqioamjJYEmjwNh)2ZnsuklZexgYhkksy8HGFogncHapRoiHGfQnhE4SU4Dvyda(SLgL9WM(YesYTNBKOuwMjUmKpuuKW4db)CmAecbEwDqcbluBo8Of7ZWL6zda(SLgL9WM(YesYTNBKOuwMjUmKpuuKW4db)aWvnh2CFYTNBKOuwMjUmKpuuKW4db)2XtaWvn3EUrIszzM4Yq(qrrcJpe8dGEg9OcTD7T9ao0cNL2VSqgxxx9Yc3t(xOZwiqHUADxyOle958ZlKvl060ppAHMs5rVqZfknbBHsTq)dPbKKWK3EUrIszz5dffjdwhoKHPHmOqWZ)WbGPZQdsiyDKjC8Ga6CrxhnpZZXCecKr2Q(kb05IUoAMjWUKp54r9t1vdHgFiBvFLa6CrxhnZHYmpN4aW0aOZ5QWboMeVWqOXhYw1xjGox01rZmR4WysKqBhphGKOXhYw1xjGox01rZmJtbGRAoCqsAsYe0qdHvBp3irPSS8HIIKbRdhYW0qgu8HGFE(hoamDwDqcH8HIIKrP0zEoMJqGS8HIIKSv5gNn6(YCu(qrrs2QCJZgMQWZkHI22ZnsukllFOOizW6WHmmnKbfFi4NN)HdatNvhKqiFOOizijQZ8CmhHaz5dffj5dYnoB09L5O8HIIK8b5gNnmvHNvcfTTNBKOuww(qrrYG1HdzyAidk(qWpp)dhaMoRoiHy6GElnKpuuKCMNJ5ieiBnKLpuuKKTk34Sr3xMJYhkksYwLBC2WufEwju0qZIfKTgYYhkksYhKBC2O7lZr5dffj5dYnoByQcpRekAOzXcb05IUoAMBXj7AgL9WzSamWUeLU9CJeLYYYhkksgSoCidtdzqXhc(55F4aW0z1bjeYhkksgSoCiN55yocbY88pCayklFOOizukDKN)Hdat5Pd6T0q(qrrcAwSGmp)dhaMYYhkksgsI6ip)dhaMYth0BPH8HIIe0SybzR6R88pCayklFOOizukHgFiBvFLN)HdatzwhzchpiGox01rt0qyLfliBvFLN)Hdatz5dffjdjrHgFiBvFLN)HdatzwhzchpiGox01rt0qy1nT7l7at30(SpxyF02ghgjkDHah)XLb12Rp7ZfE4(BAwO1FEHha8hCW2B71N95crVgxBjwFV96Z(CHaTf2hNtAUW0ocJxi6xgu5TxF2NleOTW(4CsZfEyeVI7x4H7THjV96Z(CHaTf2hNtAUqap5OmnUQeEH4Qnml0U(fEyVh6ctloCE71N95cbAleyjih1cpCht2HzHwxVt4EAH4QnmluQfMOEulmSxyYIR)NwiyWyH2UqFHIJjvwyOluACzHFLiV96Z(CHaTfIUOoamTqRRd25QSW(OTnomsukBHNeVtAHIJjvYBV(SpxiqBHalb5OyluQf68QyUqa4krOTl8W8hvl2FAHHUqqoSeanX)wswyc(RfEyORaJTqUU82Rp7Zfc0wi6v6KugTqwbsl8W8hvl2FAHN0tDl04ymBHsTWNMCgAHMcSJtCjkDHsas5TxF2NleOTWuswiRaPfACmE4gjkDGdMSqsLpi2cLAHm5dJSqPwOZRI5cnnKbvOTlehmHTqPXLfMO0(LfcGw4tUPHMlezV1d1AOL3E9zFUqG2crxvCYfMs0CHLAOf29eqRJdJZBV(SpxiqBH9X5jpoMSW(GbW96crVdJTqaKD90cjDUWYEH2rBJ0h8cXvBywOul076WjxyP4KluQfcOySfAhTncBHiRLSq5DwZc7CdkgA5TxF2NleOTWtomXAmVBl83hOWUeyAHPfMhPYcnUAi8iSxOPX1wAUqPwyOc9pxNmc782Rp7Zfc0wO1rfQ9DHwiqiZxl8WbolS7J6dj5cXbtYBVTNBKOuwU7jtbcWfe2eEmlWqDjk9CyJqcqcja)rR1rs2Xbp6O1aWzBNB)aSINgL9G5MpSddL562EUrIsz5UNmfiax4db)moqWshDKS9CJeLYYDpzkqaUWhc(5y0iec8S6GecPaPrzpalLjFXXgMszYZzKOu22Znsukl39KPab4cFi4NJrJqiWZQdsiyfM8g2GrMNKHqMgna6C02Znsukl39KPab4cFi4V9dWkEAu2dMB(Wom05WgH4ysLC7hGv80OShm38HDyOmPoamn3EUrIsz5UNmfiax4db)2yI1yE3w2EUrIsz5UNmfiax4db)88pCay6S6GeIzjSXt(m5zEoMJq4gj4rJzjzt9pxNeLIeG)OBKGhnMLK92stIeG)OBKGhnMLK5uM4aW0WTTXHrIsrcWFezRjoMujZIUMsh4WMYK6aW00If3ibpAmljZIUMsh4WMqcWJ2rKNLK7ACvkWbl0woS)HKmlHbvOTwSynXXKk5UgxLcCWcTLd7FijZK6aW0eTTNBKOuwU7jtbcWf(qWpJO5OShM6FUojk9mouAyMiSc4ph2iyDegpe)BjHLzenhL9Wu)Z1jrPdViKG4qBp3irPSC3tMceGl8HG)gNtLTNBKOuwU7jtbcWf(qWpNYehaMgUTnomsu62B71N95crxqhYWj0CHep6tUqjaPfkn0cDJu)cd2cDEEGDaykV9CJeLYqW6imEGldQTNBKOugFi4Fs8kUFa6THz75gjkLXhc(nogpCJeLoWbtoRoiHWl6mt(WiiS6CyJWnsWJgKsGbXqYH2EUrIsz8HGFqht2Hz8ENW905WgbaoB7SXXoyifhByEIziDwzUUTxFUq0ZX4fYOo)DHwOBKO0fIdMSq76xiqiZx46Nl8Wbolm0fMcS8crpU)jvWjxyP4KlS6Kam6drZfAx)c5y0ctesZcpP082ZnsukJpe8)C6Wnsu6ahm5S6GecLmFnatCMjFyeewDoSrykEK6QKvY8fU(5XNtj76BPmOJj7Wms8U0C0nsWJgKsGbXqy1rXXKk5UgxLcCWcTLd7Fij3E95c7JgjkDH4GjSfAx)cLpuuKSqauJZlQpVWuXf2c9NwiZ5rZfAx)cbq21tlmT4Wl06wc)whWosNH2Uq0ZfNjF11q8FsnUkf4ctdTLd7FijpVWsAOprWOfw6cnvHNvcnV9CJeLY4db)ghJhUrIsh4GjNvhKqiFOOizW6WHmmnKb12ZnsukJpe8BCmE4gjkDGdMCwDqcXKWEsAoKpuuKW2EUrIsz8HGFJJXd3irPdCWKZQdsiyIld5dffjSZm5dJGWQZHncKNLKzfhE8LKLWGk0wlwMLKdWosNH2omU4m5RUgAmljlHbvOTwSmlj314QuGdwOTCy)djzwcdQqBr7iR4WdwJ)tKCilwMLK5fyAiEOswcdQqBTyrCmPsMvjgsdnyenzBp3irPm(qWVXX4HBKO0boyYz1bjeth0BPH8HIIe25WgHP4rQRswJ2gzy70rKTgp)dhaMYYhkksgSoCiwSyQcpReAMvC4Xxs(jqpugsoa4TybzE(hoamLLpuuKmkLoAQcpReAMvC4Xxs(jqpu2PYhkksYwLnvHNvcn)eOhkdnlwqMN)Hdatz5dffjdjrD0ufEwj0mR4WJVK8tGEOStLpuuKKpiBQcpReA(jqpugAOzXIP4rQRsMhPstY)iYwJN)Hdatz5dffjdwhoelwmvHNvcnhGDKodTDyCXzYxDnu(jqpugsoa4TybzE(hoamLLpuuKmkLoAQcpReAoa7iDgA7W4IZKV6AO8tGEOStLpuuKKTkBQcpReA(jqpugAwSGmp)dhaMYYhkksgsI6OPk8SsO5aSJ0zOTdJlot(QRHYpb6HYov(qrrs(GSPk8SsO5Na9qzOHMfliBkEK6QKvY8fU(PflMIhPUkzuj)WvlwmfpsDvYAPeAhr2A88pCayklFOOizW6WHyXIPk8SsO5UgxLcCWcTLd7FijZpb6HYqYbaVfliZZ)WbGPS8HIIKrP0rtv4zLqZDnUkf4GfAlh2)qsMFc0dLDQ8HIIKSvztv4zLqZpb6HYqZIfK55F4aWuw(qrrYqsuhnvHNvcn314QuGdwOTCy)djz(jqpu2PYhkksYhKnvHNvcn)eOhkdn0SyXAIJjvYDnUkf4GfAlh2)qsMj1bGP5rKTgp)dhaMYYhkksgSoCiwSyQcpReAMXbcw6y6pQwS)u(jqpugsoa4TybzE(hoamLLpuuKmkLoAQcpReAMXbcw6y6pQwS)u(jqpu2PYhkksYwLnvHNvcn)eOhkdnlwqMN)Hdatz5dffjdjrD0ufEwj0mJdeS0X0FuTy)P8tGEOStLpuuKKpiBQcpReA(jqpugAOT96ZfIuUxxiR4WlK14)KTWWEH2rBJSWGTqhdwmzHfp63EUrIsz8HGFqht2Hz8ENW905WgbGIXoAhTnY4jqpu2Pe6qgoHgsas9vwXHhSg)NhNLK5uM4aW0WTTXHrIsZsyqfA72RpxO1XEHMIhPUklCwc)NuJRsbUW0qB5W(hsYfgSf(CQgA75fYXOfEy(JQf7pTqPwiHocPZfkn0cnC)tQSqgjBp3irPm(qWVXX4HBKO0boyYz1bjet)r1I9NgDp1DoSrGSP4rQRsMhPstY)4SKCa2r6m02HXfNjF11qJzjzjmOcT9OPk8SsOzghiyPJP)OAX(t5Na9qzNEWrKNLK7ACvkWbl0woS)HKm)eOhkdjhyXI1ehtQK7ACvkWbl0woS)HKen0SybztXJuxLSgTnYW2PJZsYSIdp(sYsyqfA7rtv4zLqZmoqWsht)r1I9NYpb6HYo9GJiplj314QuGdwOTCy)djz(jqpugsoWIfRjoMuj314QuGdwOTCy)djjAOzXcYiBkEK6QKvY8fU(PflMIhPUkzuj)WvlwmfpsDvYAPeAhNLK7ACvkWbl0woS)HKmlHbvOThNLK7ACvkWbl0woS)HKm)eOhk70dqB71Nl06s2pXAw4Se2cj)XjxyyVW2k02fgQul0xiRX)5czDKodTDHDnoJ2EUrIsz8HGFJJXd3irPdCWKZQdsiMLm6EQ7CyJaztXJuxLSgTnYW2PJwBwsMvC4XxswcdQqBpAQcpReAMvC4Xxs(jqpu2PNanlwq2u8i1vjZJuPj5F0AZsYbyhPZqBhgxCM8vxdnMLKLWGk02JMQWZkHMdWosNH2omU4m5RUgk)eOhk70tGMfliJSP4rQRswjZx46NwSykEK6QKrL8dxTyXu8i1vjRLsODuCmPsURXvPahSqB5W(hsYJwBwsURXvPahSqB5W(hsYSeguH2E0ufEwj0CxJRsboyH2YH9pKK5Na9qzNEc02E95cTo2l8KACvkWfMgAlh2)qsUWGTqjmOcT98cdzHbBHm3MwOulKJrl8W8h1ctlo82ZnsukJpe8p9h1GvC4ZHnIzj5UgxLcCWcTLd7FijZsyqfA72ZnsukJpe8p9h1GvC4ZHncRjoMuj314QuGdwOTCy)dj5rKNLKzfhE8LKLWGk0wlwMLKdWosNH2omU4m5RUgAmljlHbvOTOT96ZfMMunl8KACvkWfMgAlh2)qsUWeH0SW(aKknjF(bs02il8KZPfAkEK6QSWzjNxyjn0Niy0c5y0clDHMQWZkHMxO1XEHOlGDjFYXleD9NQRgAHa4STxyWwyOMcm02ZlSPWZfYPsGxyi9Zw4t(m5cr2k09czKP0jBHUTq)c5yeABp3irPm(qWFxJRsboyH2YH9pKKNdBeMIhPUkznABKHTthLaKqI1F0ufEwj0mR4WJVK8tGEOStT6iYYhkksYeyxYNC8O(P6QHYMQWZkHMFc0dLDQva3dSyXAeqNl66OzMa7s(KJh1pvxneABp3irPm(qWFxJRsboyH2YH9pKKNdBeMIhPUkzEKknj)JsasiX6pAQcpReAoa7iDgA7W4IZKV6AO8tGEOStT6iYYhkksYeyxYNC8O(P6QHYMQWZkHMFc0dLDQva3dSyXAeqNl66OzMa7s(KJh1pvxneABV(CHaHmFHRFUWeH0SWd3XKDywiW5DPzHgNjSf214QuGlKfAlh2)qsUWqxiouAHjcPzHhgzcqxcTDHiTWY2ZnsukJpe8314QuGdwOTCy)dj55WgHP4rQRswjZx46NhFoLSRVLYGoMSdZiX7sZrjajKy9hnvHNvcnpjta6sOTdafwYpb6HYo9qhrw(qrrsMa7s(KJh1pvxnu2ufEwj08tGEOStTc4EGflwJa6CrxhnZeyxYNC8O(P6QHqB71NleDvAOFHMIhPUkSfICOgm3m02fQLc0oCGZcbcz(cTfACMSWtkDHLUqtv4zLq3EUrIsz8HG)UgxLcCWcTLd7Fijph2iq2u8i1vjJk5hUAXIP4rQRswlLSybztXJuxLSsMVW1ppATNtj76BPmOJj7Wms8U0GgAhrw(qrrsMa7s(KJh1pvxnu2ufEwj08tGEOStTc4EGflwJa6CrxhnZeyxYNC8O(P6QHqB75gjkLXhc(7ACvkWbl0woS)HK8CyJaqXyhTJ2gz8eOhk7uRaUBV(CHwh7fEsnUkf4ctdTLd7FijxyWwOeguH2EEHH0pBHsasluQfYXOfwsd9le0p5v)cNLW2EUrIsz8HGFJJXd3irPdCWKZQdsimfpsDvoZKpmccRoh2iMLK7ACvkWbl0woS)HKmlHbvOThr2u8i1vjRrBJmSDYIftXJuxLmpsLMKpABp3irPm(qWV3wAYZMKgmne)BjHHWQZHnIzjzVT0K5Na9qzNEITNBKOugFi4VX5uz71NlmTsSqPHwykrt2clDHhAHI)TKWwyyVWqwyW0(LfA4(NubNCHHUqBC02ilS(fw6cLgAHI)TKKxiWjKMfMgDnLUq0pSPfgs)Sf6ywTqaKi0VqPwihJwykrZfw8OFHGUY5yCYf6DD4KH2UWdTq0R(NRtIsz5TNBKOugFi4Nr0Cu2dt9pxNeLEoSr4gj4rdsjWGyi5GJIJjvYSkXqAObJOj7O1MLKzenhL9Wu)Z1jrPzjmOcT9O1cDyJJ2gz75gjkLXhc(zenhL9Wu)Z1jrPNdBeUrcE0Gucmigso4O4ysLml6AkDGdB6O1MLKzenhL9Wu)Z1jrPzjmOcT9O1cDyJJ2g54SKSP(NRtIsZpb6HYo9eBp3irPm(qWpVatdXdvoh2iqMvC4bRX)jsSYIf3ibpAqkbgedjhG2rtv4zLqZmoqWsht)r1I9NYpb6HYqIvhS9CJeLY4db)CktCayA4224WirPNdBeUrcE0ywsMtzIdatd32ghgjkfbWBXIeguH2ECwsMtzIdatd32ghgjkn)eOhk70tS9CJeLY4db)SORP0boSPZMKgmne)BjHHWQZHnIzjzw01u6ah2u(jqpu2PNy75gjkLXhc(nogpCJeLoWbtoRoiHWu8i1v5mt(WiiS6CyJWAMIhPUkzLmFHRFU96Zf2h76Wjxi6v)Z1jrPle0vohJtUWsxOvaTdwO4FljSZlS(fw6cp0ctesZc7JayfMtOfIE1)CDsu62ZnsukJpe8BQ)56KO0ZMKgmne)BjHHWQZHnc3ibpAqkbge70ta0qwCmPsMvjgsdnyenzwSioMujZIUMsh4WMq74SKSP(NRtIsZpb6HYo9GTxFUW(OTq)cLgAHvhP0FEHSosNl0xiRX)5ct0q6cDzHw)clDHhUJj7WSqRR3jCpTqPwOZRI5clE0B8UUqB3EUrIsz8HGFqht2Hz8ENW905WgbR4WdwJ)tKCIJsasi5aR2E95cbonKUqTKfYsQMqBx4j14QuGlmn0woS)HKCHsTW(aKknjF(bs02il8KZPZlmLdeS0fEy(JQf7pTWWEHogVWzjSf6pTqVRdh0C75gjkLXhc(nogpCJeLoWbtoRoiHy6pQwS)0O7PUZHncKnfpsDvY8ivAs(hTM4ysLCxJRsboyH2YH9pKKhNLKdWosNH2omU4m5RUgAmljlHbvOThnvHNvcnZ4ablDm9hvl2Fk)KptIMfliBkEK6QK1OTrg2oD0AIJjvYDnUkf4GfAlh2)qsECwsMvC4XxswcdQqBpAQcpReAMXbcw6y6pQwS)u(jFMenlwqgztXJuxLSsMVW1pTyXu8i1vjJk5hUAXIP4rQRswlLq7OPk8SsOzghiyPJP)OAX(t5N8zs02E95c7ly0cpm)rTW0IdVWWEHhM)OAX(tlmrP9lleaTWN8zYf6TEONxy9lmSxO0qpTWebgVqa0cDzHyYzYcpyHG1tl8W8hvl2FAHCmIT9CJeLY4db)t)rnyfh(CyJaqXyhnvHNvcnZ4ablDm9hvl2Fk)eOhkdj2rBJmEc0dLDezRjoMuj314QuGdwOTCy)djPflMQWZkHM7ACvkWbl0woS)HKm)eOhkdj2rBJmEc0dLH22ZnsukJpe8p9h1GvC4ZHncafJD0AIJjvYDnUkf4GfAlh2)qsE0ufEwj0mJdeS0X0FuTy)P8tGEOm(mvHNvcnZ4ablDm9hvl2Fkp5ExIsp1oABKXtGEOSTxFUq0ZftdqZX4fgcbUqoM3sl0U(f6AsPj02fQLSqwhzc7GMlKWmkrd902ZnsukJpe8BCmE4gjkDGdMCwDqcrie42Rp7ZfADj7NynlmTXNvIfIUac4DdTqaKD90czDKodTDHSg)NSfw6cpCht2HzHwxVt4EA75gjkLXhc(nogpCJeLoWbtoRoiHGrNdBeIJjvYSgFwjgeiG3nuMuhaMMhrEsa4STZSgFwjgeiG3nuMjUb1PiFaqZnsuAM14ZkXaqHLCOdBC02iOzXYKaWzBNzn(SsmiqaVBO8tGEOStpeABV(CH9fmAHhUJj7WSqRR3jCpTWenKUqq)Kx9lCwcBH(tlKR78cRFHH9cLg6PfMiW4fcGwilA1WomUklucqAHCQe4fkn0cvcDKfEsnUkf4ctdTLd7FijZl06yVqojWrFOqBx4H7yYomle48U0CEHnfEUqFHSg)NluQf(K9tSMfkn0cbWzBV9CJeLY4db)GoMSdZ49oH7PZHncKNLK5fyAiEOswcdQqBTyzwsoa7iDgA7W4IZKV6AOXSKSeguH2AXYSKmR4WJVKSeguH2I2rKT2ZPKD9Tug0XKDygjExASybaNTDg0XKDygjExAYmXnOo9qwSWko8G14)ejwH22RpxyFbJw4H7yYoml066Dc3tluQfc6HkEOluAOfc6yYomlmX7sZcbWzBVqovc8czn(pzlujAUqPwiaAHTKsVl0CH21VqPHwOsOJSqaCptwyIqNvIfI8ba)czKP0jBHbBHG1tluACDHmoB7WeKkluQf2sk9Uql8qlK14)KH22ZnsukJpe8d6yYomJ37eUNoh2iEoLSRVLYGoMSdZiX7sZrtv4zLqZSIdp(sYpb6HYqYba)raC22zqht2HzK4DPj)eOhk70tS96ZfE4EOIh6cpCht2HzHaN3LMf6YcDmEHsasSfAx)cLgAHaHmFHRFUW6x4jFj)W1fAkEK6QS9CJeLY4db)GoMSdZ49oH7PZHnINtj76BPmOJj7Wms8U0CeztXJuxLSsMVW1pTyXu8i1vjJk5hUI2raC22zqht2HzK4DPj)eOhk70tS96Zf2xWOfE4oMSdZcTUENW90clDHNuJRsbUW0qB5W(hsYfACMWoVqqhvOTlKX90cLAHmNhTqFHSg)NluQfYe3GAHhUJj7WSqGZ7sZcd7fYXcTDHHS9CJeLY4db)GoMSdZ49oH7PZHncXXKk5UgxLcCWcTLd7FijpI8SKCxJRsboyH2YH9pKKzjmOcT1Iftv4zLqZDnUkf4GfAlh2)qsMFc0dLHKdSElwaum2rjaPHuJzqNAQcpReAURXvPahSqB5W(hsY8tGEOm0oIS1EoLSRVLYGoMSdZiX7sJfla4STZGoMSdZiX7stMjUb1PhYIfwXHhSg)NiXk02EUrIsz8HGFqht2Hz8ENW905WgH4ysLmRsmKgAWiAY2E95cpS3dDHOFytlmylSuCYf6l8WoP0f26HUWeH0SqRJs8cXbGPfEyeyWOfQK)le0rNfYe3GILxO1XEH2rBJSWGTqhqXjluQfs6CHZAHAjlemySfY6iDgA7cLgAHmXnOyBp3irPm(qW)89qh4WMoh2iaWzBNdL4fIdatJjbgmkZe3GcjNa4TybaNTDouIxioamnMeyWOmx3rafJD0oABKXtGEOStpX2ZnsukJpe8BCmE4gjkDGdMCwDqcHP4rQRY2ZnsukJpe87TLM8SjPbtdX)wsyiS6CyJ4j7NynoamT9CJeLY4db)CktCayA4224WirPNdBeUrcE0ywsMtzIdatd32ghgjkfbWBXIeguH2E8j7NynoamT9CJeLY4db)SORP0boSPZMKgmne)BjHHWQZHnINSFI14aW02ZnsukJpe8BQ)56KO0ZMKgmne)BjHHWQZHnINSFI14aW0r3ibpAqkbge70ta0qwCmPsMvjgsdnyenzwSioMujZIUMsh4WMqB75gjkLXhc(TXeRX8UTCoSrWkomGqNzEf2LatdwH5rQCouH(NRtgHncaC22zEf2LatdwH5rQK562EUrIsz8HG)57Hoyfh(COc9pxNGWQTNBKOugFi4N14ZkXaqHLT32Znsukl7fHORXvPahSqB5W(hsYTNBKOuw2lIpe834CQS9CJeLYYEr8HGFJJXd3irPdCWKZQdsiM(JQf7pn6EQ7CyJWu8i1vjZJuPj5FCwsoa7iDgA7W4IZKV6AOXSKSeguH2E0ufEwj0mJdeS0X0FuTy)P8t(m5rKNLK7ACvkWbl0woS)HKm)eOhkdjhyXI1ehtQK7ACvkWbl0woS)HKenlwmfpsDvYA02idBNooljZko84ljlHbvOThnvHNvcnZ4ablDm9hvl2Fk)KptEe5zj5UgxLcCWcTLd7FijZpb6HYqYbwSynXXKk5UgxLcCWcTLd7FijrZIfKnfpsDvYkz(cx)0IftXJuxLmQKF4QflMIhPUkzTucTJZsYDnUkf4GfAlh2)qsMLWGk02JZsYDnUkf4GfAlh2)qsMFc0dLD6bBp3irPSSxeFi4Nr0Cu2dt9pxNeLEoSrioMujZQedPHgmIMSJgxhmIMBp3irPSSxeFi4Nr0Cu2dt9pxNeLEoSrynXXKkzwLyin0Gr0KD0AZsYmIMJYEyQ)56KO0SeguH2E0AHoSXrBJCCws2u)Z1jrP5NSFI14aW02Znsukl7fXhc(92stE2K0GPH4FljmewDoSr4gj4rJzjzVT0KNEIJwBws2BlnzwcdQqB3EUrIszzVi(qWV3wAYZMKgmne)BjHHWQZHnc3ibpAmlj7TLMejioXXNSFI14aW0XzjzVT0KzjmOcTD75gjkLL9I4db)CktCayA4224WirPNdBeUrcE0ywsMtzIdatd32ghgjkfbWBXIeguH2E8j7NynoamT9CJeLYYEr8HGFoLjoamnCBBCyKO0ZMKgmne)BjHHWQZHncRjHbvOTh741joMuj)oyNRYWTTXHrIszzsDayAE0nsWJgZsYCktCayA4224WirPNEOTNBKOuw2lIpe8ZlW0q8qLZHncwXHhSg)NiXQTNBKOuw2lIpe8BCmE4gjkDGdMCwDqcHP4rQRYzM8Hrqy15WgH1mfpsDvYkz(cx)C75gjkLL9I4db)ghJhUrIsh4GjNvhKqm9hvl2FA09u35WgbYMIhPUkzEKknj)JiBQcpReAoa7iDgA7W4IZKV6AO8t(mPflZsYbyhPZqBhgxCM8vxdnMLKLWGk0w0oAQcpReAMXbcw6y6pQwS)u(jFM8iYZsYDnUkf4GfAlh2)qsMFc0dLHKdSyXAIJjvYDnUkf4GfAlh2)qsIgAhrgztXJuxLSsMVW1pTyXu8i1vjJk5hUAXIP4rQRswlLq7OPk8SsOzghiyPJP)OAX(t5Na9qzNEWrKNLK7ACvkWbl0woS)HKm)eOhkdjhyXI1ehtQK7ACvkWbl0woS)HKen0SybztXJuxLSgTnYW2PJiBQcpReAMvC4Xxs(jFM0ILzjzwXHhFjzjmOcTfTJMQWZkHMzCGGLoM(JQf7pLFc0dLD6bhrEwsURXvPahSqB5W(hsY8tGEOmKCGflwtCmPsURXvPahSqB5W(hss0qB75gjkLL9I4db)t)rnyfh(CyJaqXyhnvHNvcnZ4ablDm9hvl2Fk)eOhkdj2rBJmEc0dLDezRjoMuj314QuGdwOTCy)djPflMQWZkHM7ACvkWbl0woS)HKm)eOhkdj2rBJmEc0dLH22Znsukl7fXhc(N(JAWko85WgbGIXoAQcpReAMXbcw6y6pQwS)u(jqpugFMQWZkHMzCGGLoM(JQf7pLNCVlrPNAhTnY4jqpu22Znsukl7fXhc(nogpCJeLoWbtoRoiHiecC75gjkLL9I4db)ghJhUrIsh4GjNvhKqmjSNKMd5dffjSTNBKOuw2lIpe8BCmE4gjkDGdMCwDqcX0b9wAiFOOiHT9CJeLYYEr8HGFJJXd3irPdCWKZQdsiyIld5dffjSZm5dJGWQZHnIzj5UgxLcCWcTLd7FijZsyqfARflwtCmPsURXvPahSqB5W(hsYTNBKOuw2lIpe8d6yYomJ37eUNoh2iMLK5fyAiEOswcdQqB3EUrIszzVi(qWpOJj7WmEVt4E6CyJywsMvC4XxswcdQqBpAnXXKkzwLyin0Gr0KT9CJeLYYEr8HGFqht2Hz8ENW905WgH1ehtQK5fyAiEOY2Znsukl7fXhc(bDmzhMX7Dc3tNdBeSIdpyn(prYj2EUrIszzVi(qWpl6AkDGdB6SjPbtdX)wsyiS6CyJWnsWJgZsYSORP0boSPtrCOJpz)eRXbGPJwBwsMfDnLoWHnLLWGk02TNBKOuw2lIpe8BCmE4gjkDGdMCwDqcHP4rQRYzM8Hrqy15WgHP4rQRswjZx46NBp3irPSSxeFi4F(EOdCytNdBea4STZHs8cXbGPXKadgLzIBqHeewpWBXcGIXocGZ2ohkXlehaMgtcmyuMR7OD02iJNa9qzNA9wSaGZ2ohkXlehaMgtcmyuMjUbfsqCiR)4SKmR4WJVKSeguH2U9CJeLYYEr8HGFBmXAmVBlNdBeSIddi0zMxHDjW0GvyEKkNdvO)56KryJaaNTDMxHDjW0GvyEKkzUUTNBKOuw2lIpe8pFp0bR4WNdvO)56eewT9CJeLYYEr8HGFwJpRedafw2EBp3irPSSP4rQRcIaSJ0zOTdJlot(QRHoh2iSM4ysLCxJRsboyH2YH9pKKhr2ufEwj0mJdeS0X0FuTy)P8tGEOStTc4TyXufEwj0mJdeS0X0FuTy)P8tGEOmKy9aVflMQWZkHMzCGGLoM(JQf7pLFc0dLHKdS(JMsNCHKn1)CDsOTdmrpABp3irPSSP4rQRcFi4pa7iDgA7W4IZKV6AOZHncXXKk5UgxLcCWcTLd7Fijpolj314QuGdwOTCy)djzwcdQqB3EUrIszztXJuxf(qW)KmbOlH2oauy5CyJWufEwj0mJdeS0X0FuTy)P8tGEOmKy9hrEsa4STZnoNk5Na9qzi5ewSynXXKk5gNtf02EUrIszztXJuxf(qWpR4WJVKZHncRjoMuj314QuGdwOTCy)dj5rKnvHNvcnZ4ablDm9hvl2Fk)eOhk7uR3Iftv4zLqZmoqWsht)r1I9NYpb6HYqI1d8wSyQcpReAMXbcw6y6pQwS)u(jqpugsoW6pAkDYfs2u)Z1jH2oWe9OT9CJeLYYMIhPUk8HGFwXHhFjNdBeIJjvYDnUkf4GfAlh2)qsECwsURXvPahSqB5W(hsYSeguH2U9CJeLYYMIhPUk8HGFMP4(qBhsin02B75gjkLLNoO3sd5dffjmeCmAecbEwDqcbR4WJOvdH(TNBKOuwE6GElnKpuuKW4db)CmAecbEwDqcX8jFAhpn4rmgH3EUrIsz5Pd6T0q(qrrcJpe8ZXOrie4z1bjeT4KDnJYE4mwagyxIs3EUrIsz5Pd6T0q(qrrcJpe8ZXOrie4z1bjeCQPXdLMJwSpdxQNnynUbfMyBp3irPS80b9wAiFOOiHXhc(5y0iec8S6GeccqPSIdp4fgA7T9CJeLYYt)r1I9NgDp1HGxGPH4HkBp3irPS80FuTy)Pr3tD8HG)P)OgSIdV9CJeLYYt)r1I9NgDp1Xhc(7kjkD75gjkLLN(JQf7pn6EQJpe8Bhpbax1C75gjkLLN(JQf7pn6EQJpe8dax1CyZ9j3EUrIsz5P)OAX(tJUN64db)aONrpQqB3EUrIsz5P)OAX(tJUN64db)ghJhUrIsh4GjNvhKqykEK6QCMjFyeewDoSryntXJuxLSsMVW1p3EUrIsz5P)OAX(tJUN64db)moqWsht)r1I9N2EBp3irPS8KWEsAoKpuuKWqWXOrie4z1bjeeyxYNC8O(P6QHoh2iq2u8i1vjRrBJmSD6OPk8SsOzwXHhFj5Na9qzNEaWJMfliBkEK6QK5rQ0K8pAQcpReAoa7iDgA7W4IZKV6AO8tGEOStpa4rZIfKnfpsDvYkz(cx)0IftXJuxLmQKF4QflMIhPUkzTucTTNBKOuwEsypjnhYhkksy8HGFogncHapRoiHGXPaWvnhoijnjzY5WgbYMIhPUkznABKHTthnvHNvcnZko84lj)eOhk7uGlAwSGSP4rQRsMhPstY)OPk8SsO5aSJ0zOTdJlot(QRHYpb6HYof4IMfliBkEK6QKvY8fU(PflMIhPUkzuj)WvlwmfpsDvYAPeABp3irPS8KWEsAoKpuuKW4db)CmAecbEwDqcbR4WysKqBhphGKNdBeiBkEK6QK1OTrg2oD0ufEwj0mR4WJVK8tGEOStr3OzXcYMIhPUkzEKknj)JMQWZkHMdWosNH2omU4m5RUgk)eOhk7u0nAwSGSP4rQRswjZx46NwSykEK6QKrL8dxTyXu8i1vjRLsOT9CJeLYYtc7jP5q(qrrcJpe8ZXOrie4z1bjeSgFwjO5OEaJYEi1dsQCoSrGSP4rQRswJ2gzy70rtv4zLqZSIdp(sYpb6HYo9eOzXcYMIhPUkzEKknj)JMQWZkHMdWosNH2omU4m5RUgk)eOhk70tGMfliBkEK6QKvY8fU(PflMIhPUkzuj)WvlwmfpsDvYAPeABVTNBKOuwEwYO7PoeEBPjph2iMLK92stMFc0dLDk6(OPk8SsOzghiyPJP)OAX(t5Na9qzizws2Blnz(jqpu22Znsuklplz09uhFi4NfDnLoWHnDoSrmljZIUMsh4WMYpb6HYofDF0ufEwj0mJdeS0X0FuTy)P8tGEOmKmljZIUMsh4WMYpb6HY2EUrIsz5zjJUN64db)CktCayA4224WirPNdBeZsYCktCayA4224WirP5Na9qzNIUpAQcpReAMXbcw6y6pQwS)u(jqpugsMLK5uM4aW0WTTXHrIsZpb6HY2EUrIsz5zjJUN64db)M6FUojk9CyJyws2u)Z1jrP5Na9qzNIUpAQcpReAMXbcw6y6pQwS)u(jqpugsMLKn1)CDsuA(jqpu22B75gjkLLdHarWXOrieiB7T9CJeLYYkz(AaMabp)dhaMoRoiHywcBiHbvOTN55yocXSKSP(NRtIsZpb6HYqYbhNLK92stMFc0dLHKdooljZPmXbGPHBBJdJeLMFc0dLHKdoIS1ehtQKzrxtPdCytwSmljZIUMsh4WMYpb6HYqYbOT96ZfcSpuuKWwOJJwDHjcPzHNu6cTRFHPn(SsSq0fqaVBOZl8Wq6cTRFH9HDovYBp3irPSSsMVgGj4db)88pCay6S6Gec5dffjJjH9KN55yocHPk8SsO5UgxLcCWcTLd7FijZpb6HYoZZXC0GWmcHPk8SsO5jzcqxcTDaOWs(jqpu25QdbJKW(SP0zirPiehtQKzn(SsmiqaVBOZHnctXJuxLSsMVW1p3E95crk3RlKvC4fYA8FYwyyVqPHwOD02ilmrGXleaTqsNH2UqwvAE75gjkLLvY81ambFi4h0XKDygV3jCpDoSribinKAmd6ucDidNqdjaP(kR4WdwJ)ZJZsYCktCayA4224WirPzjmOcTD71Nle9CMSWgNtLfk1cFY(jwZcbq21tl02X4Y2oV9CJeLYYkz(AaMGpe834CQCoSrmlj34CQKFc0dLD6b8rOdz4eAibiT96Zf2hoABwiqBHDFuFijx4HdCw4t2pXAwyyVqwhPZqBxyP0cBXfahVWefhEUqJZXOfYXwOulemySfkn0cRUU6fonKKluQf(K9tSMfE4aN8c3EUrIszzLmFnatWhc(bDmzhMX7Dc3tNdBesasi5KDeaNTDg0XKDygjExAYpb6HYoT1mZGo6WhHoKHtOHeG02Rpx4jx80cNe2tsZfkFOOiHTWqxORsyIoxIsxyzVWdJmbOlH2UqKwyjV9CJeLYYkz(AaMGpe8ZXOrie4z1bjeeyxYNC8O(P6QHoh2i45F4aWuw(qrrYysyp5Pha8Bp3irPSSsMVgGj4db)CmAecbEwDqcbJtbGRAoCqsAsYKZHncE(hoamLLpuuKmMe2tEkWD75gjkLLvY81ambFi4NJrJqiWZQdsiyfhgtIeA745aK8CyJGN)Hdatz5dffjJjH9KNIU3EUrIszzLmFnatWhc(5y0iec8S6GecwJpRe0CupGrzpK6bjvoh2i45F4aWuw(qrrYysyp5PNy71Nl06yVqPHwyh2ts)cd2c5yH2UW(WoNkNxOD80cpP0fw6cnvHNvcDHsdPl0UW4kXctesZcpmKU9CJeLYYkz(AaMGpe8314QuGdwOTCy)dj55WgH4ysLCJZPYrE(hoamLNLWgsyqfA72ZnsuklRK5Rbyc(qW)KmbOlH2oauy5CyJqCmPsUX5u5OPk8SsO5UgxLcCWcTLd7FijZpb6HYqcWV96ZfADSxO0qlSd7jPFHbBHCSqBxyk6Y5fAhpTWddPlS0fAQcpRe6cLgsxODHXvIqBxyIqAw4jLU9CJeLYYkz(AaMGpe8pjta6sOTdafwoh2iehtQKzn(SsmiqaVBOJ88pCaykplHnKWGk02TNBKOuwwjZxdWe8HG)UgxLcCWcTLd7Fijph2iehtQKzn(SsmiqaVBOJMQWZkHMNKjaDj02bGcl5Na9qzib43EUrIszzLmFnatWhc(5uM4aW0WTTXHrIsph2iMLK5uM4aW0WTTXHrIsZpb6HYof4U9CJeLYYkz(AaMGpe87TLM8CyJyws2Blnz(jqpu2PNy75gjkLLvY81ambFi4NfDnLoWHnDoSrmljZIUMsh4WMYpb6HYo9eBp3irPSSsMVgGj4db)M6FUojk9CyJyws2u)Z1jrP5Na9qzNEITxFUqRlz)eRzHhoWzHUTq)cLgAHvhP0VWWEHt)r1I9NgDp1TWefhEUqJZXOfYXwOulemySf6l8Wbol8j7NynBp3irPSSsMVgGj4db)GoMSdZ49oH7PZHncjajKCYocGZ2od6yYomJeVln5Na9qzNEqFT1mZGo6WhHoKHtOHeG02Rpxi65y8cN(JQf7pn6EQBHH9cpPgxLcCHPH2YH9pKKlmyl0W9pPco5cLWGk02TNBKOuwwjZxdWe8HGFJJXd3irPdCWKZQdsiM(JQf7pn6EQ7mt(WiiS6CyJywsURXvPahSqB5W(hsYSeguH2U96Zf2xibo6drl01KlSKg6xitCzHYhkksylmSx4j14QuGlmn0woS)HKCHbBHsyqfA72ZnsuklRK5Rbyc(qWVXX4HBKO0boyYz1bjemXLH8HIIe2zM8Hrqy15WgXSKCxJRsboyH2YH9pKKzjmOcTD71NlmvCdQfE4oMSdZcboVlnluQfEOZlS(f(K9tSMfMOH0f2sIeA7cXvIfICmjhJtUqCvOcTDH21VqFHghB4WUqZfQCGaO)8cbWjl8ezRNTWNa9qdTDHbBHsdTWNyCyzHL9cfIjH2UWeH0SqGDWjdTTNBKOuwwjZxdWe8HGFqht2Hz8ENW905WgHeGesozhrgaNTDg0XKDygjExAYmXnOo9qwSaGZ2od6yYomJeVln5Na9qzNEIS1J22RpxyFCodjk1Xl8WTUlK1r6KTWenKUqcDK3xiRX)jBH(tl055b2bGPf66CHuin0VWtQXvPaxyAOTCy)dj5cd2cLWGk02ZlS(fkn0cTJ2gzHbBHKodTnV9CJeLYYkz(AaMGpe8d6yYomJ37eUNoh2iqEwsURXvPahSqB5W(hsYSeguH2AXIeG0qQXmOtnvHNvcn314QuGdwOTCy)djz(jqpugAhrgaNTDg0XKDygjExAYmXnOo9qwSWko8G14)ejwH22RpxyFCodjk1Xl8WEp0fMwC4fACMSWenKUWtkDHbBHsyqfA72ZnsuklRK5Rbyc(qW)89qhSIdFoSrmlj314QuGdwOTCy)djzwcdQqB3E95cr)kXcbAlS7J6dj5cNLSWNSFI1SWenKUWNSFI14aWuE75gjkLLvY81ambFi43Bln55WgXt2pXACayA75gjkLLvY81ambFi4NtzIdatd32ghgjk9CyJ4j7NynoamT9CJeLYYkz(AaMGpe8BQ)56KO0ZHnINSFI14aW02ZnsuklRK5Rbyc(qWpl6AkDGdB6CyJqCmPsMfDnLoWHnD8j7NynoamT96ZfEYHjwJ5DBzHsTqqpuXdDH9bkSlbMwyAH5rQK3EUrIszzLmFnatWhc(TXeRX8UTCoSrWkomGqNzEf2LatdwH5rQC24QHWJWgbaoB7mVc7sGPbRW8ivgnCGUwXmZ1T96ZfI(vcGw3h1hsYf24CQSWNSFI1K3EUrIszzLmFnatWhc(BCovoh2iMLKBCovYpb6HYo9qBV(CH9fAOc9pxNeaW0cpS0fAACvj8cd7fMGwyJZJwO0ql8Wq6cbWzBN3EUrIszzLmFnatWhc(NVh6GvC4ZHncaC225jzcqxcTDaOWsMRB75gjkLLvY81ambFi4F(EOdwXHph2iehtQKzn(SsmiqaVBOJtcaNTDM14ZkXGab8UHYpb6HYo9qwSmjaC22zwJpRedceW7gkZe3G60dDouH(NRtgHnIjbGZ2oZA8zLyqGaE3qzM4guibXHoojaC22zwJpRedceW7gk)eOhkdjhA75gjkLLvY81ambFi4F(EOdwXHphQq)Z1jiSA75gjkLLvY81ambFi4N14ZkXaqHLT32ZnsuklZienoNkBp3irPSmJ4db)Z3dDWko85qf6FUoz0IlaogHvNdvO)56KryJysa4STZSgFwjgeiG3nuMjUbfsqCOTNBKOuwMr8HGFwJpRedafw2EBp3irPSmtCziFOOiHHGJrJqiWZQdsicLzEoXbGPbqNZvHdCmjEHH2EUrIszzM4Yq(qrrcJpe8ZXOrie4z1bjeHYKNZi1ZgZGxO0aaHXBp3irPSmtCziFOOiHXhc(5y0iec8S6GeIIh924krOTdxdqFy8wA75gjkLLzIld5dffjm(qWphJgHqGNvhKqm9hfyv6ysguJoo5jMHudT9CJeLYYmXLH8HIIegFi4NJrJqiWZQdsiaDJd4PbRHizaYXcZ2ZnsuklZexgYhkksy8HGFogncHapRoiHWg7G0OShaCrW02ZnsuklZexgYhkksy8HGFogncHapRoiHiHJIu6zd7V052ZnsuklZexgYhkksy8HGFogncHapRoiHqCaysgL9ysSop(TNBKOuwMjUmKpuuKW4db)CmAecbEwDqcbluBo8WzDX7QWga8zlnk7Hn9LjKKBp3irPSmtCziFOOiHXhc(5y0iec8S6GecwO2C4rl2NHl1Zga8zlnk7Hn9LjKKBp3irPSmtCziFOOiHXhc(bGRAoS5(KBp3irPSmtCziFOOiHXhc(TJNaGRAU9CJeLYYmXLH8HIIegFi4ha9m6rfA72B71Nle4qlCwA)YczCDD1llCp5FHoBHaf6Q1DHHUq0NZpVqwTqRt)8OfAkLh9cnxO0eSfk1c9pKgqsctE75gjkLLLpuuKmyD4qgMgYGcbp)dhaMoRoiHG1rMWXdcOZfDD08mphZriqgzR6ReqNl66OzMa7s(KJh1pvxneA8HSv9vcOZfDD0mhkZ8CIdatdGoNRch4ys8cdHgFiBvFLa6CrxhnZSIdJjrcTD8CasIgFiBvFLa6CrxhnZmofaUQ5WbjPjjtqdnewT9CJeLYYYhkksgSoCidtdzqXhc(55F4aW0z1bjeYhkksgLsN55yocbYYhkksYwLBC2O7lZr5dffjzRYnoByQcpRekABp3irPSS8HIIKbRdhYW0qgu8HGFE(hoamDwDqcH8HIIKHKOoZZXCecKLpuuKKpi34Sr3xMJYhkksYhKBC2WufEwju02EUrIszz5dffjdwhoKHPHmO4db)88pCay6S6GeIPd6T0q(qrrYzEoMJqGS1qw(qrrs2QCJZgDFzokFOOijBvUXzdtv4zLqrdnlwq2AilFOOijFqUXzJUVmhLpuuKKpi34SHPk8SsOOHMfleqNl66OzUfNSRzu2dNXcWa7su62ZnsukllFOOizW6WHmmnKbfFi4NN)HdatNvhKqiFOOizW6WHCMNJ5ieiZZ)WbGPS8HIIKrP0rE(hoamLNoO3sd5dffjOzXcY88pCayklFOOizijQJ88pCaykpDqVLgYhkksqZIfKTQVYZ)WbGPS8HIIKrPeA8HSv9vE(hoamLzDKjC8Ga6CrxhnrdHvwSGSv9vE(hoamLLpuuKmKefA8HSv9vE(hoamLzDKjC8Ga6CrxhnrdHv3uE0ZIsVa5aG)Gda(doa4Ett4VgAl7McC6JwxGyDasFq99cxiWAOfgGD1ll0U(f2V8HIIKbRdhYW0qgu9VWNa6CXtZfYkqAHoNuGUqZfAACTLy5Th6hkTWd67fIELYJEHMlSF5dffjzRYav)luQf2V8HIIKSyvgO6FHiFa6GwE7H(Hsl8q99crVs5rVqZf2V8HIIK8bzGQ)fk1c7x(qrrswoidu9VqKpaDqlV9q)qPfEI(EHOxP8OxO5c7x(qrrs2Qmq1)cLAH9lFOOijlwLbQ(xiYhGoOL3EOFO0cprFVq0RuE0l0CH9lFOOijFqgO6FHsTW(LpuuKKLdYav)le5dqh0YBVThWPpADbI1bi9b13lCHaRHwya2vVSq76xy)MIhPUk9VWNa6CXtZfYkqAHoNuGUqZfAACTLy5Th6hkTqR67fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)fISvOdA5Th6hkTqR67fIELYJEHMlSFtPtUqYav)luQf2VP0jxizGktQdatZ(xiYwHoOL3EOFO0cpOVxi6vkp6fAUW(fhtQKbQ(xOulSFXXKkzGktQdatZ(xiYwHoOL3EOFO0cpuFVq0RuE0l0CH9loMujdu9VqPwy)IJjvYavMuhaMM9VqKTcDqlV9q)qPfEI(EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHiBf6GwE7H(Hsl8e99crVs5rVqZf2VP0jxizGQ)fk1c73u6KlKmqLj1bGPz)lezRqh0YBp0puAHwFFVq0RuE0l0CH9loMujdu9VqPwy)IJjvYavMuhaMM9VqKTcDqlV92EaN(O1fiwhG0huFVWfcSgAHbyx9YcTRFH9pjBNdl9VWNa6CXtZfYkqAHoNuGUqZfAACTLy5Th6hkTqRVVxi6vkp6fAUW(fhtQKbQ(xOulSFXXKkzGktQdatZ(xOlleDbDf9xiYwHoOL3EOFO0cT((EHOxP8OxO5c7)5uYU(wkdu9VqPwy)pNs213szGktQdatZ(xiYwHoOL3EOFO0cr399crVs5rVqZf2V4ysLmq1)cLAH9loMujduzsDayA2)cDzHOlORO)cr2k0bT82d9dLwyFzFVq0RuE0l0CH9lFOOijBvgO6FHsTW(LpuuKKfRYav)le5tGoOL3EOFO0c7l77fIELYJEHMlSF5dffj5dYav)luQf2V8HIIKSCqgO6FHiFc0bT82d9dLwOvw13le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)le5dqh0YBp0puAHwDqFVq0RuE0l0CH9loMujdu9VqPwy)IJjvYavMuhaMM9VqKTcDqlV9q)qPfA1j67fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)fISvOdA5Th6hkTqRS((EHOxP8OxO5c7x(qrrs2byYMQWZkH2)cLAH9BQcpReA2by6FHiBf6GwE7H(Hsl0kGBFVq0RuE0l0CH9lFOOij7amztv4zLq7FHsTW(nvHNvcn7am9VqKTcDqlV9q)qPfA1jRVxi6vkp6fAUW(FoLSRVLYav)luQf2)ZPKD9TugOYK6aW0S)fISvOdA5Th6hkTqRoz99crVs5rVqZf2V8HIIKSdWKnvHNvcT)fk1c73ufEwj0SdW0)cr2k0bT82d9dLwOvO7(EHOxP8OxO5c7)5uYU(wkdu9VqPwy)pNs213szGktQdatZ(xiYwHoOL3EOFO0cTcD33le9kLh9cnxy)YhkksYoat2ufEwj0(xOulSFtv4zLqZoat)lezRqh0YBp0puAHhCO(EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHiBf6GwE7H(Hsl8Gt03le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHh0x23le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)le5dqh0YBp0puAHhYQ(EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHiFa6GwE7H(Hsl8qh03le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHh6q99crVs5rVqZf2V4ysLmq1)cLAH9loMujduzsDayA2)cr2k0bT82d9dLw4HaU99crVs5rVqZf2)ZPKD9TugO6FHsTW(FoLSRVLYavMuhaMM9VqKTcDqlV9q)qPfEOtwFVq0RuE0l0CH9)CkzxFlLbQ(xOulS)Ntj76BPmqLj1bGPz)lezRqh0YBp0puAHhcD33le9kLh9cnxy)pNs213szGQ)fk1c7)5uYU(wkduzsDayA2)cr2k0bT82d9dLw4H6l77fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)fISvOdA5Th6hkTWd1x23le9kLh9cnxy)pNs213szGQ)fk1c7)5uYU(wkduzsDayA2)cr2k0bT82d9dLw4ja((EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHUSq0f0v0FHiBf6GwE7H(Hsl8ea3(EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHiFa6GwE7H(Hsl8eNS(EHOxP8OxO5c7NvCyaHoZav)luQf2pR4WacDMbQmPoamn7FHUSq0f0v0FHiBf6GwE7T9ao9rRlqSoaPpO(EHleyn0cdWU6LfAx)c73lQ)f(eqNlEAUqwbsl05Kc0fAUqtJRTelV9q)qPfEO(EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHiFa6GwE7H(Hsl8e99crVs5rVqZf2V4ysLmq1)cLAH9loMujduzsDayA2)cr2k0bT82d9dLwO133le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHwDqFVq0RuE0l0CH9loMujdu9VqPwy)IJjvYavMuhaMM9VqKpe6GwE7H(Hsl0Qd13le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHwHU77fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)f6Ycrxqxr)fISvOdA5Th6hkTWda((EHOxP8OxO5c7xCmPsgO6FHsTW(fhtQKbQmPoamn7FHUSq0f0v0FHiBf6GwE7H(Hsl8aR67fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)f6Ycrxqxr)fISvOdA5Th6hkTWdaU99crVs5rVqZf2pR4WacDMbQ(xOulSFwXHbe6mduzsDayA2)cDzHOlORO)cr2k0bT82B7bC6JwxGyDasFq99cxiWAOfgGD1ll0U(f2VsMVgGj6FHpb05INMlKvG0cDoPaDHMl004AlXYBp0puAHw13le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHh03le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)l0LfIUGUI(lezRqh0YBp0puAHwb899crVs5rVqZf2V4ysLmq1)cLAH9loMujduzsDayA2)cr2k0bT82d9dLwOvw13le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBp0puAHwDqFVq0RuE0l0CH9loMujdu9VqPwy)IJjvYavMuhaMM9VqKTcDqlV9q)qPfA1H67fIELYJEHMlSFXXKkzGQ)fk1c7xCmPsgOYK6aW0S)fISvOdA5Th6hkTWdoz99crVs5rVqZf2V4ysLmq1)cLAH9loMujduzsDayA2)cr2k0bT82d9dLw4bO7(EHOxP8OxO5c7NvCyaHoZav)luQf2pR4WacDMbQmPoamn7FHUSq0f0v0FHiBf6GwE7H(Hsl8qw13le9kLh9cnxy)IJjvYav)luQf2V4ysLmqLj1bGPz)lezRqh0YBVTN1bSREHMl0QdTq3irPlehmHL3E3uNtAQ)MMgGO3nfhmHDb2nLjUmKpuuKWUa7ceRUa7MsQdatZlsVPQds30qzMNtCayAa05Cv4ahtIxyOBQBKO0BAOmZZjoamna6CUkCGJjXlm0vUa5GlWUPK6aW08I0BQ6G0nnuM8CgPE2yg8cLgaim(M6gjk9MgktEoJupBmdEHsdaegFLlqo0fy3usDayAEr6nvDq6Mw8O3gxjcTD4Aa6dJ3s3u3irP30Ih924krOTdxdqFy8w6kxGCIlWUPK6aW08I0BQ6G0nD6pkWQ0XKmOgDCYtmdPg6M6gjk9Mo9hfyv6ysguJoo5jMHudDLlqS(lWUPK6aW08I0BQ6G0nf0noGNgSgIKbihlm3u3irP3uq34aEAWAisgGCSWCLlqaUxGDtj1bGP5fP3u1bPBQn2bPrzpa4IGPBQBKO0BQn2bPrzpa4IGPRCbYj7cSBkPoamnVi9MQoiDtt4OiLE2W(lDEtDJeLEtt4OiLE2W(lDELlqq3xGDtj1bGP5fP3u1bPBQ4aWKmk7XKyDE83u3irP3uXbGjzu2JjX684VYfi9LxGDtj1bGP5fP3u1bPBkluBo8WzDX7QWga8zlnk7Hn9LjKK3u3irP3uwO2C4HZ6I3vHna4ZwAu2dB6ltijVYfiwb8xGDtj1bGP5fP3u1bPBkluBo8Of7ZWL6zda(SLgL9WM(YesYBQBKO0BkluBo8Of7ZWL6zda(SLgL9WM(YesYRCbIvwDb2n1nsu6nfaUQ5WM7tEtj1bGP5fPx5ceRo4cSBQBKO0BQD8eaCvZBkPoamnVi9kxGy1HUa7M6gjk9McGEg9OcT9MsQdatZlsVYvUPYhkksgSoCidtdzqDb2fiwDb2nLuhaMMxKEtRUBkJKBQBKO0Bkp)dhaMUP8CmhDtrEHiVqRwyFDHeqNl66OzMa7s(KJh1pvxn0crBH8TqKxOvlSVUqcOZfDD0mhkZ8CIdatdGoNRch4ys8cdTq0wiFle5fA1c7RlKa6CrxhnZSIdJjrcTD8CasUq0wiFle5fA1c7RlKa6CrxhnZmofaUQ5WbjPjjtwiAleTfIyHwDtNeZ8rNeLEtbo0cNL2VSqgxxx9YcVP88FOoiDtzDKjC8Ga6CrxhnVYfihCb2nLuhaMMxKEtRUBkJKBQBKO0Bkp)dhaMUP8CmhDtrEHYhkksYIv5gNn6(YSWJlu(qrrswSk34SHPk8SsOleTBkp)hQds3u5dffjJsPRCbYHUa7MsQdatZlsVPv3nLrYn1nsu6nLN)Hdat3uEoMJUPiVq5dffjz5GCJZgDFzw4XfkFOOijlhKBC2WufEwj0fI2nLN)d1bPBQ8HIIKHKOUYfiN4cSBkPoamnVi9MwD3ugj3u3irP3uE(hoamDt55yo6MI8cT2crEHYhkksYIv5gNn6(YSWJlu(qrrswSk34SHPk8SsOleTfI2cTyzHiVqRTqKxO8HIIKSCqUXzJUVml84cLpuuKKLdYnoByQcpRe6crBHOTqlwwib05IUoAMBXj7AgL9WzSamWUeLEt55)qDq6MoDqVLgYhkksUYfiw)fy3usDayAEr6nT6UPmsUPUrIsVP88pCay6MYZXC0nf5fYZ)WbGPS8HIIKrP0cpUqE(hoamLNoO3sd5dffjleTfAXYcrEH88pCayklFOOizijQfECH88pCaykpDqVLgYhkkswiAl0ILfI8cTAH91fYZ)WbGPS8HIIKrP0crBH8TqKxOvlSVUqE(hoamLzDKjC8Ga6CrxhnxiAleXcTAHwSSqKxOvlSVUqE(hoamLLpuuKmKe1crBH8TqKxOvlSVUqE(hoamLzDKjC8Ga6CrxhnxiAleXcT6MYZ)H6G0nv(qrrYG1Hd5kx5MoDqVLgYhkksyxGDbIvxGDtj1bGP5fP3u1bPBkR4WJOvdH(BQBKO0BkR4WJOvdH(RCbYbxGDtj1bGP5fP3u1bPB68jFAhpn4rmgHVPUrIsVPZN8PD80GhXye(kxGCOlWUPK6aW08I0BQ6G0nTfNSRzu2dNXcWa7su6n1nsu6nTfNSRzu2dNXcWa7su6vUa5exGDtj1bGP5fP3u1bPBkNAA8qP5Of7ZWL6zdwJBqHj2n1nsu6nLtnnEO0C0I9z4s9SbRXnOWe7kxGy9xGDtj1bGP5fP3u1bPBkbOuwXHh8cdDtDJeLEtjaLYko8GxyORCLB6KWEsAoKpuuKWUa7ceRUa7MsQdatZlsVPUrIsVPeyxYNC8O(P6QHUPMpe6d)MI8cnfpsDvYA02idBNw4XfAQcpReAMvC4Xxs(jqpu2cpDHha8leTfAXYcrEHMIhPUkzEKknj)fECHMQWZkHMdWosNH2omU4m5RUgk)eOhkBHNUWda(fI2cTyzHiVqtXJuxLSsMVW1pxOfll0u8i1vjJk5hUUqlwwOP4rQRswlLwiA3u1bPBkb2L8jhpQFQUAORCbYbxGDtj1bGP5fP3u3irP3ugNcax1C4GK0KKj3uZhc9HFtrEHMIhPUkznABKHTtl84cnvHNvcnZko84lj)eOhkBHNUqG7crBHwSSqKxOP4rQRsMhPstYFHhxOPk8SsO5aSJ0zOTdJlot(QRHYpb6HYw4Ple4Uq0wOflle5fAkEK6QKvY8fU(5cTyzHMIhPUkzuj)W1fAXYcnfpsDvYAP0cr7MQoiDtzCkaCvZHdsstsMCLlqo0fy3usDayAEr6n1nsu6nLvCymjsOTJNdqYBQ5dH(WVPiVqtXJuxLSgTnYW2PfECHMQWZkHMzfhE8LKFc0dLTWtxi6EHOTqlwwiYl0u8i1vjZJuPj5VWJl0ufEwj0Ca2r6m02HXfNjF11q5Na9qzl80fIUxiAl0ILfI8cnfpsDvYkz(cx)CHwSSqtXJuxLmQKF46cTyzHMIhPUkzTuAHODtvhKUPSIdJjrcTD8CasELlqoXfy3usDayAEr6n1nsu6nL14Zkbnh1dyu2dPEqsLBQ5dH(WVPiVqtXJuxLSgTnYW2PfECHMQWZkHMzfhE8LKFc0dLTWtx4jwiAl0ILfI8cnfpsDvY8ivAs(l84cnvHNvcnhGDKodTDyCXzYxDnu(jqpu2cpDHNyHOTqlwwiYl0u8i1vjRK5lC9ZfAXYcnfpsDvYOs(HRl0ILfAkEK6QK1sPfI2nvDq6MYA8zLGMJ6bmk7HupiPYvUYnD6pQwS)0O7PUlWUaXQlWUPUrIsVP8cmnepu5MsQdatZlsVYfihCb2n1nsu6nD6pQbR4W3usDayAEr6vUa5qxGDtDJeLEt7kjk9MsQdatZlsVYfiN4cSBQBKO0BQD8eaCvZBkPoamnVi9kxGy9xGDtDJeLEtbGRAoS5(K3usDayAEr6vUab4Eb2n1nsu6nfa9m6rfA7nLuhaMMxKELlqozxGDtj1bGP5fP3uZhc9HFtT2cnfpsDvYkz(cx)8MYKpmYfiwDtDJeLEtnogpCJeLoWbtUP4Gjd1bPBQP4rQRYvUabDFb2n1nsu6nLXbcw6y6pQwS)0nLuhaMMxKELRCtnfpsDvUa7ceRUa7MsQdatZlsVPMpe6d)MATfkoMuj314QuGdwOTCy)djzMuhaMMl84crEHMQWZkHMzCGGLoM(JQf7pLFc0dLTWtxOva)cTyzHMQWZkHMzCGGLoM(JQf7pLFc0dLTqKSqRh4xOfll0ufEwj0mJdeS0X0FuTy)P8tGEOSfIKfEG1VWJl0u6KlKSP(NRtcTDGj6ZK6aW0CHODtDJeLEtdWosNH2omU4m5RUg6kxGCWfy3usDayAEr6n18HqF43uXXKk5UgxLcCWcTLd7FijZK6aW0CHhx4SKCxJRsboyH2YH9pKKzjmOcT9M6gjk9MgGDKodTDyCXzYxDn0vUa5qxGDtj1bGP5fP3uZhc9HFtnvHNvcnZ4ablDm9hvl2Fk)eOhkBHizHw)cpUqKx4KaWzBNBCovYpb6HYwisw4jwOfll0AluCmPsUX5ujtQdatZfI2n1nsu6nDsMa0LqBhakSCLlqoXfy3usDayAEr6n18HqF43uRTqXXKk5UgxLcCWcTLd7FijZK6aW0CHhxiYl0ufEwj0mJdeS0X0FuTy)P8tGEOSfE6cT(fAXYcnvHNvcnZ4ablDm9hvl2Fk)eOhkBHizHwpWVqlwwOPk8SsOzghiyPJP)OAX(t5Na9qzlejl8aRFHhxOP0jxizt9pxNeA7at0Nj1bGP5cr7M6gjk9MYko84l5kxGy9xGDtj1bGP5fP3uZhc9HFtfhtQK7ACvkWbl0woS)HKmtQdatZfECHZsYDnUkf4GfAlh2)qsMLWGk02BQBKO0BkR4WJVKRCbcW9cSBQBKO0BkZuCFOTdjKg6MsQdatZlsVYvUPZsgDp1Db2fiwDb2nLuhaMMxKEtnFi0h(nDws2Blnz(jqpu2cpDHO7fECHMQWZkHMzCGGLoM(JQf7pLFc0dLTqKSWzjzVT0K5Na9qz3u3irP3uVT0Kx5cKdUa7MsQdatZlsVPMpe6d)MoljZIUMsh4WMYpb6HYw4PleDVWJl0ufEwj0mJdeS0X0FuTy)P8tGEOSfIKfoljZIUMsh4WMYpb6HYUPUrIsVPSORP0boSPRCbYHUa7MsQdatZlsVPMpe6d)MoljZPmXbGPHBBJdJeLMFc0dLTWtxi6EHhxOPk8SsOzghiyPJP)OAX(t5Na9qzlejlCwsMtzIdatd32ghgjkn)eOhk7M6gjk9MYPmXbGPHBBJdJeLELlqoXfy3usDayAEr6n18HqF430zjzt9pxNeLMFc0dLTWtxi6EHhxOPk8SsOzghiyPJP)OAX(t5Na9qzlejlCws2u)Z1jrP5Na9qz3u3irP3ut9pxNeLELRCtNKTZHLlWUaXQlWUPUrIsVPSocJh4YG6MsQdatZlsVYfihCb2n1nsu6nDs8kUFa6TH5MsQdatZlsVYfih6cSBkPoamnVi9MA(qOp8BQBKGhniLadITqKSWdDtzYhg5ceRUPUrIsVPghJhUrIsh4Gj3uCWKH6G0n1l6kxGCIlWUPK6aW08I0BQ5dH(WVPa4STZgh7GHuCSH5jMH0zL56UPUrIsVPGoMSdZ49oH7PRCbI1Fb2nLuhaMMxKEtNeZ8rNeLEtrphJxiJ683fAHUrIsxioyYcTRFHaHmFHRFUWdh4SWqxykWYle94(NubNCHLItUWQtcWOpenxOD9lKJrlmrinl8KsZ3u3irP30NthUrIsh4Gj3uM8HrUaXQBQ5dH(WVPMIhPUkzLmFHRFUWJl85uYU(wkd6yYomJeVlnzsDayAUWJl0nsWJgKsGbXwiIfA1cpUqXXKk5UgxLcCWcTLd7FijZK6aW08MIdMmuhKUPkz(AaM4kxGaCVa7MsQdatZlsVPtIz(OtIsVP9rJeLUqCWe2cTRFHYhkkswiaQX5f1NxyQ4cBH(tlK58O5cTRFHai76PfMwC4fADlHFRdyhPZqBxi65IZKV6Ai(pPgxLcCHPH2YH9pKKNxyjn0Niy0clDHMQWZkHMVPUrIsVPghJhUrIsh4Gj3uCWKH6G0nv(qrrYG1HdzyAidQRCbYj7cSBkPoamnVi9M6gjk9MACmE4gjkDGdMCtXbtgQds30jH9K0CiFOOiHDLlqq3xGDtj1bGP5fP3uZhc9HFtrEHZsYSIdp(sYsyqfA7cTyzHZsYbyhPZqBhgxCM8vxdnMLKLWGk02fAXYcNLK7ACvkWbl0woS)HKmlHbvOTleTfECHSIdpyn(pxisw4HwOfllCwsMxGPH4HkzjmOcTDHwSSqXXKkzwLyin0Gr0KLj1bGP5nLjFyKlqS6M6gjk9MACmE4gjkDGdMCtXbtgQds3uM4Yq(qrrc7kxG0xEb2nLuhaMMxKEtnFi0h(n1u8i1vjRrBJmSDAHhxiYl0AlKN)Hdatz5dffjdwhoKfAXYcnvHNvcnZko84lj)eOhkBHizHha8l0ILfI8c55F4aWuw(qrrYOuAHhxOPk8SsOzwXHhFj5Na9qzl80fkFOOijlwLnvHNvcn)eOhkBHOTqlwwiYlKN)Hdatz5dffjdjrTWJl0ufEwj0mR4WJVK8tGEOSfE6cLpuuKKLdYMQWZkHMFc0dLTq0wiAl0ILfAkEK6QK5rQ0K8x4XfI8cT2c55F4aWuw(qrrYG1HdzHwSSqtv4zLqZbyhPZqBhgxCM8vxdLFc0dLTqKSWda(fAXYcrEH88pCayklFOOizukTWJl0ufEwj0Ca2r6m02HXfNjF11q5Na9qzl80fkFOOijlwLnvHNvcn)eOhkBHOTqlwwiYlKN)Hdatz5dffjdjrTWJl0ufEwj0Ca2r6m02HXfNjF11q5Na9qzl80fkFOOijlhKnvHNvcn)eOhkBHOTq0wOflle5fAkEK6QKvY8fU(5cTyzHMIhPUkzuj)W1fAXYcnfpsDvYAP0crBHhxiYl0AlKN)Hdatz5dffjdwhoKfAXYcnvHNvcn314QuGdwOTCy)djz(jqpu2crYcpa4xOflle5fYZ)WbGPS8HIIKrP0cpUqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTWtxO8HIIKSyv2ufEwj08tGEOSfI2cTyzHiVqE(hoamLLpuuKmKe1cpUqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTWtxO8HIIKSCq2ufEwj08tGEOSfI2crBHwSSqRTqXXKk5UgxLcCWcTLd7FijZK6aW0CHhxiYl0AlKN)Hdatz5dffjdwhoKfAXYcnvHNvcnZ4ablDm9hvl2Fk)eOhkBHizHha8l0ILfI8c55F4aWuw(qrrYOuAHhxOPk8SsOzghiyPJP)OAX(t5Na9qzl80fkFOOijlwLnvHNvcn)eOhkBHOTqlwwiYlKN)Hdatz5dffjdjrTWJl0ufEwj0mJdeS0X0FuTy)P8tGEOSfE6cLpuuKKLdYMQWZkHMFc0dLTq0wiA3u3irP3uJJXd3irPdCWKBkoyYqDq6MoDqVLgYhkksyx5ceRa(lWUPK6aW08I0BQBKO0BkOJj7WmEVt4E6MojM5Jojk9MIuUxxiR4WlK14)KTWWEH2rBJSWGTqhdwmzHfp6VPMpe6d)McOySfECH2rBJmEc0dLTWtxiHoKHtOHeG0c7RlKvC4bRX)5cpUWzjzoLjoamnCBBCyKO0SeguH2ELlqSYQlWUPK6aW08I0B6KyMp6KO0BQ1XEHMIhPUklCwc)NuJRsbUW0qB5W(hsYfgSf(CQgA75fYXOfEy(JQf7pTqPwiHocPZfkn0cnC)tQSqgj3u3irP3uJJXd3irPdCWKBQ5dH(WVPiVqtXJuxLmpsLMK)cpUWzj5aSJ0zOTdJlot(QRHgZsYsyqfA7cpUqtv4zLqZmoqWsht)r1I9NYpb6HYw4Pl8GfECHiVWzj5UgxLcCWcTLd7FijZpb6HYwisw4bl0ILfATfkoMuj314QuGdwOTCy)djzMuhaMMleTfI2cTyzHiVqtXJuxLSgTnYW2PfECHZsYSIdp(sYsyqfA7cpUqtv4zLqZmoqWsht)r1I9NYpb6HYw4Pl8GfECHiVWzj5UgxLcCWcTLd7FijZpb6HYwisw4bl0ILfATfkoMuj314QuGdwOTCy)djzMuhaMMleTfI2cTyzHiVqKxOP4rQRswjZx46Nl0ILfAkEK6QKrL8dxxOfll0u8i1vjRLsleTfECHZsYDnUkf4GfAlh2)qsMLWGk02fECHZsYDnUkf4GfAlh2)qsMFc0dLTWtx4bleTBkoyYqDq6Mo9hvl2FA09u3vUaXQdUa7MsQdatZlsVPtIz(OtIsVPwxY(jwZcNLWwi5po5cd7f2wH2UWqLAH(czn(pxiRJ0zOTlSRXz0n1nsu6n14y8Wnsu6ahm5MA(qOp8BkYl0u8i1vjRrBJmSDAHhxO1w4SKmR4WJVKSeguH2UWJl0ufEwj0mR4WJVK8tGEOSfE6cpXcrBHwSSqKxOP4rQRsMhPstYFHhxO1w4SKCa2r6m02HXfNjF11qJzjzjmOcTDHhxOPk8SsO5aSJ0zOTdJlot(QRHYpb6HYw4Pl8eleTfAXYcrEHiVqtXJuxLSsMVW1pxOfll0u8i1vjJk5hUUqlwwOP4rQRswlLwiAl84cfhtQK7ACvkWbl0woS)HKmtQdatZfECHwBHZsYDnUkf4GfAlh2)qsMLWGk02fECHMQWZkHM7ACvkWbl0woS)HKm)eOhkBHNUWtSq0UP4Gjd1bPB6SKr3tDx5ceRo0fy3usDayAEr6n1nsu6nD6pQbR4W30jXmF0jrP3uRJ9cpPgxLcCHPH2YH9pKKlmylucdQqBpVWqwyWwiZTPfk1c5y0cpm)rTW0IdFtnFi0h(nDwsURXvPahSqB5W(hsYSeguH2ELlqS6exGDtj1bGP5fP3uZhc9HFtT2cfhtQK7ACvkWbl0woS)HKmtQdatZfECHiVWzjzwXHhFjzjmOcTDHwSSWzj5aSJ0zOTdJlot(QRHgZsYsyqfA7cr7M6gjk9Mo9h1GvC4RCbIvw)fy3usDayAEr6n1nsu6nTRXvPahSqB5W(hsYB6KyMp6KO0BAAs1SWtQXvPaxyAOTCy)dj5ctesZc7dqQ0K85hirBJSWtoNwOP4rQRYcNLCEHL0qFIGrlKJrlS0fAQcpReAEHwh7fIUa2L8jhVq01FQUAOfcGZ2EHbBHHAkWqBpVWMcpxiNkbEHH0pBHp5ZKlezRq3lKrMsNSf62c9lKJrODtnFi0h(n1u8i1vjRrBJmSDAHhxOeG0crYcT(fECHMQWZkHMzfhE8LKFc0dLTWtxOvl84crEHMQWZkHMjWUKp54r9t1vdLFc0dLTWtxOva3dwOfll0AlKa6CrxhnZeyxYNC8O(P6QHwiAx5ceRaUxGDtj1bGP5fP3uZhc9HFtnfpsDvY8ivAs(l84cLaKwiswO1VWJl0ufEwj0Ca2r6m02HXfNjF11q5Na9qzl80fA1cpUqKxOPk8SsOzcSl5toEu)uD1q5Na9qzl80fAfW9GfAXYcT2cjGox01rZmb2L8jhpQFQUAOfI2n1nsu6nTRXvPahSqB5W(hsYRCbIvNSlWUPK6aW08I0BQBKO0BAxJRsboyH2YH9pKK30jXmF0jrP3uGqMVW1pxyIqAw4H7yYomle48U0SqJZe2c7ACvkWfYcTLd7FijxyOlehkTWeH0SWdJmbOlH2UqKwy5MA(qOp8BQP4rQRswjZx46Nl84cFoLSRVLYGoMSdZiX7stMuhaMMl84cLaKwiswO1VWJl0ufEwj08KmbOlH2oauyj)eOhkBHNUWdTWJle5fAQcpReAMa7s(KJh1pvxnu(jqpu2cpDHwbCpyHwSSqRTqcOZfDD0mtGDjFYXJ6NQRgAHODLlqScDFb2nLuhaMMxKEtDJeLEt7ACvkWbl0woS)HK8MojM5Jojk9MIUkn0VqtXJuxf2croudMBgA7c1sbAhoWzHaHmFH2cnotw4jLUWsxOPk8SsO3uZhc9HFtrEHMIhPUkzuj)W1fAXYcnfpsDvYAP0cTyzHiVqtXJuxLSsMVW1px4XfATf(CkzxFlLbDmzhMrI3LMmPoamnxiAleTfECHiVqtv4zLqZeyxYNC8O(P6QHYpb6HYw4Pl0kG7bl0ILfATfsaDUORJMzcSl5toEu)uD1qleTRCbIv9LxGDtj1bGP5fP3uZhc9HFtbum2cpUq7OTrgpb6HYw4Pl0kG7n1nsu6nTRXvPahSqB5W(hsYRCbYba)fy3usDayAEr6nDsmZhDsu6n16yVWtQXvPaxyAOTCy)dj5cd2cLWGk02ZlmK(zlucqAHsTqogTWsAOFHG(jV6x4Se2n1nsu6n14y8Wnsu6ahm5MYKpmYfiwDtnFi0h(nDwsURXvPahSqB5W(hsYSeguH2UWJle5fAkEK6QK1OTrg2oTqlwwOP4rQRsMhPstYFHODtXbtgQds3utXJuxLRCbYbwDb2nLuhaMMxKEtDJeLEt92stEtnFi0h(nDws2Blnz(jqpu2cpDHN4MAsAW0q8VLe2fiwDLlqo4GlWUPUrIsVPnoNk3usDayAEr6vUa5GdDb2nLuhaMMxKEtDJeLEtzenhL9Wu)Z1jrP30jXmF0jrP300kXcLgAHPenzlS0fEOfk(3scBHH9cdzHbt7xwOH7FsfCYfg6cTXrBJSW6xyPluAOfk(3ssEHaNqAwyA01u6cr)WMwyi9ZwOJz1cbqIq)cLAHCmAHPenxyXJ(fc6kNJXjxO31HtgA7cp0crV6FUojkLLVPMpe6d)M6gj4rdsjWGylejl8GfECHIJjvYSkXqAObJOjltQdatZfECHwBHZsYmIMJYEyQ)56KO0SeguH2UWJl0Alm0HnoABKRCbYbN4cSBkPoamnVi9MA(qOp8BQBKGhniLadITqKSWdw4XfkoMujZIUMsh4WMYK6aW0CHhxO1w4SKmJO5OShM6FUojknlHbvOTl84cT2cdDyJJ2gzHhx4SKSP(NRtIsZpb6HYw4Pl8e3u3irP3ugrZrzpm1)CDsu6vUa5aR)cSBkPoamnVi9MA(qOp8BkYlKvC4bRX)5crYcTAHwSSq3ibpAqkbgeBHizHhSq0w4XfAQcpReAMXbcw6y6pQwS)u(jqpu2crYcT6GBQBKO0BkVatdXdvUYfihaCVa7MsQdatZlsVPMpe6d)M6gj4rJzjzoLjoamnCBBCyKO0fIyHa)cTyzHsyqfA7cpUWzjzoLjoamnCBBCyKO08tGEOSfE6cpXn1nsu6nLtzIdatd32ghgjk9kxGCWj7cSBkPoamnVi9M6gjk9MYIUMsh4WMUPMpe6d)MoljZIUMsh4WMYpb6HYw4Pl8e3utsdMgI)TKWUaXQRCbYbO7lWUPK6aW08I0BQ5dH(WVPwBHMIhPUkzLmFHRFEtzYhg5ceRUPUrIsVPghJhUrIsh4Gj3uCWKH6G0n1u8i1v5kxGCqF5fy3usDayAEr6n1nsu6n1u)Z1jrP3utsdMgI)TKWUaXQBQ5dH(WVPUrcE0Gucmi2cpDHNyHaTfI8cfhtQKzvIH0qdgrtwMuhaMMl0ILfkoMujZIUMsh4WMYK6aW0CHOTWJlCws2u)Z1jrP5Na9qzl80fEWnDsmZhDsu6nTp21HtUq0R(NRtIsxiORCogNCHLUqRaAhSqX)wsyNxy9lS0fEOfMiKMf2hbWkmNqle9Q)56KO0RCbYHa(lWUPK6aW08I0BQBKO0BkOJj7WmEVt4E6MojM5Jojk9M2hTf6xO0qlS6iL(ZlK1r6CH(czn(pxyIgsxOll06xyPl8WDmzhMfAD9oH7Pfk1cDEvmxyXJEJ31fA7n18HqF43uwXHhSg)Nlejl8el84cLaKwisw4bwDLlqoKvxGDtj1bGP5fP30jXmF0jrP3uGtdPlulzHSKQj02fEsnUkf4ctdTLd7FijxOulSpaPstYNFGeTnYcp5C68ct5ablDHhM)OAX(tlmSxOJXlCwcBH(tl076WbnVPUrIsVPghJhUrIsh4Gj3uZhc9HFtrEHMIhPUkzEKknj)fECHwBHIJjvYDnUkf4GfAlh2)qsMj1bGP5cpUWzj5aSJ0zOTdJlot(QRHgZsYsyqfA7cpUqtv4zLqZmoqWsht)r1I9NYp5ZKleTfAXYcrEHMIhPUkznABKHTtl84cT2cfhtQK7ACvkWbl0woS)HKmtQdatZfECHZsYSIdp(sYsyqfA7cpUqtv4zLqZmoqWsht)r1I9NYp5ZKleTfAXYcrEHiVqtXJuxLSsMVW1pxOfll0u8i1vjJk5hUUqlwwOP4rQRswlLwiAl84cnvHNvcnZ4ablDm9hvl2Fk)KptUq0UP4Gjd1bPB60FuTy)Pr3tDx5cKdDWfy3usDayAEr6n1nsu6nD6pQbR4W30jXmF0jrP30(cgTWdZFulmT4WlmSx4H5pQwS)0ctuA)Ycbql8jFMCHERh65fw)cd7fkn0tlmrGXleaTqxwiMCMSWdwiy90cpm)r1I9NwihJy3uZhc9HFtbum2cpUqtv4zLqZmoqWsht)r1I9NYpb6HYwiswOD02iJNa9qzl84crEHwBHIJjvYDnUkf4GfAlh2)qsMj1bGP5cTyzHMQWZkHM7ACvkWbl0woS)HKm)eOhkBHizH2rBJmEc0dLTq0UYfih6qxGDtj1bGP5fP3uZhc9HFtbum2cpUqRTqXXKk5UgxLcCWcTLd7FijZK6aW0CHhxOPk8SsOzghiyPJP)OAX(t5Na9qzlKVfAQcpReAMXbcw6y6pQwS)uEY9UeLUWtxOD02iJNa9qz3u3irP30P)OgSIdFLlqo0jUa7MsQdatZlsVPtIz(OtIsVPONlMgGMJXlmecCHCmVLwOD9l01KstOTlulzHSoYe2bnxiHzuIg6PBQBKO0BQXX4HBKO0boyYnfhmzOoiDtdHaVYfihY6Va7MsQdatZlsVPMpe6d)MkoMujZA8zLyqGaE3qzsDayAUWJle5fojaC22zwJpRedceW7gkZe3GAHNUqKx4bleOTq3irPzwJpRedafwYHoSXrBJSq0wOfllCsa4STZSgFwjgeiG3nu(jqpu2cpDHhAHODtDJeLEtnogpCJeLoWbtUP4Gjd1bPBkJUYfihc4Eb2nLuhaMMxKEtDJeLEtbDmzhMX7Dc3t30jXmF0jrP30(cgTWd3XKDywO117eUNwyIgsxiOFYR(folHTq)PfY1DEH1VWWEHsd90ctey8cbqlKfTAyhgxLfkbiTqovc8cLgAHkHoYcpPgxLcCHPH2YH9pKK5fADSxiNe4OpuOTl8WDmzhMfcCExAoVWMcpxOVqwJ)Zfk1cFY(jwZcLgAHa4STVPMpe6d)MI8cNLK5fyAiEOswcdQqBxOfllCwsoa7iDgA7W4IZKV6AOXSKSeguH2Uqlww4SKmR4WJVKSeguH2Uq0w4XfI8cT2cFoLSRVLYGoMSdZiX7stMuhaMMl0ILfcGZ2od6yYomJeVlnzM4gul80fEOfAXYczfhEWA8FUqKSqRwiAx5cKdDYUa7MsQdatZlsVPUrIsVPGoMSdZ49oH7PB6KyMp6KO0BAFbJw4H7yYoml066Dc3tluQfc6HkEOluAOfc6yYomlmX7sZcbWzBVqovc8czn(pzlujAUqPwiaAHTKsVl0CH21VqPHwOsOJSqaCptwyIqNvIfI8ba)czKP0jBHbBHG1tluACDHmoB7WeKkluQf2sk9Uql8qlK14)KH2n18HqF430Ntj76BPmOJj7Wms8U0Kj1bGP5cpUqtv4zLqZSIdp(sYpb6HYwisw4ba)cpUqaC22zqht2HzK4DPj)eOhkBHNUWtCLlqoe6(cSBkPoamnVi9M6gjk9Mc6yYomJ37eUNUPtIz(OtIsVPhUhQ4HUWd3XKDywiW5DPzHUSqhJxOeGeBH21VqPHwiqiZx46NlS(fEYxYpCDHMIhPUk3uZhc9HFtFoLSRVLYGoMSdZiX7stMuhaMMl84crEHMIhPUkzLmFHRFUqlwwOP4rQRsgvYpCDHOTWJleaNTDg0XKDygjExAYpb6HYw4Pl8ex5cKd1xEb2nLuhaMMxKEtDJeLEtbDmzhMX7Dc3t30jXmF0jrP30(cgTWd3XKDywO117eUNwyPl8KACvkWfMgAlh2)qsUqJZe25fc6OcTDHmUNwOulK58Of6lK14)CHsTqM4gul8WDmzhMfcCExAwyyVqowOTlmKBQ5dH(WVPIJjvYDnUkf4GfAlh2)qsMj1bGP5cpUqKx4SKCxJRsboyH2YH9pKKzjmOcTDHwSSqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTqKSWdS(fAXYcbum2cpUqjaPHuJzql80fAQcpReAURXvPahSqB5W(hsY8tGEOSfI2cpUqKxO1w4ZPKD9Tug0XKDygjExAYK6aW0CHwSSqaC22zqht2HzK4DPjZe3GAHNUWdTqlwwiR4WdwJ)ZfIKfA1cr7kxGCcG)cSBkPoamnVi9MA(qOp8BQ4ysLmRsmKgAWiAYYK6aW08M6gjk9Mc6yYomJ37eUNUYfiNWQlWUPK6aW08I0BQBKO0B689qh4WMUPtIz(OtIsVPh27HUq0pSPfgSfwko5c9fEyNu6cB9qxyIqAwO1rjEH4aW0cpmcmy0cvY)fc6OZczIBqXYl06yVq7OTrwyWwOdO4Kfk1cjDUWzTqTKfcgm2czDKodTDHsdTqM4guSBQ5dH(WVPa4STZHs8cXbGPXKadgLzIBqTqKSWta8l0ILfcGZ2ohkXlehaMgtcmyuMRBHhxiGIXw4XfAhTnY4jqpu2cpDHN4kxGCIdUa7MsQdatZlsVPUrIsVPghJhUrIsh4Gj3uCWKH6G0n1u8i1v5kxGCIdDb2nLuhaMMxKEtDJeLEt92stEtnFi0h(n9j7NynoamDtnjnyAi(3sc7ceRUYfiN4exGDtj1bGP5fP3uZhc9HFtDJe8OXSKmNYehaMgUTnomsu6crSqGFHwSSqjmOcTDHhx4t2pXACay6M6gjk9MYPmXbGPHBBJdJeLELlqoH1Fb2nLuhaMMxKEtDJeLEtzrxtPdCyt3uZhc9HFtFY(jwJdat3utsdMgI)TKWUaXQRCbYjaUxGDtj1bGP5fP3u3irP3ut9pxNeLEtnFi0h(n9j7NynoamTWJl0nsWJgKsGbXw4Pl8eleOTqKxO4ysLmRsmKgAWiAYYK6aW0CHwSSqXXKkzw01u6ah2uMuhaMMleTBQjPbtdX)wsyxGy1vUa5eNSlWUPK6aW08I0BQBKO0BQnMynM3TLBQ5dH(WVPSIddi0zMxHDjW0GvyEKkzsDayAEtdvO)56KryFtbWzBN5vyxcmnyfMhPsMR7kxGCc09fy30qf6FUo5MA1n1nsu6nD(EOdwXHVPK6aW08I0RCbYj6lVa7M6gjk9MYA8zLyaOWYnLuhaMMxKELRCt7EYuGaC5cSlqS6cSBkPoamnVi9MA(qOp8BQeG0crYcb(fECHwBHDKKDCWJw4XfATfcGZ2o3(byfpnk7bZnFyhgkZ1DtDJeLEtTj8ywGH6su6vUa5GlWUPUrIsVPmoqWsh2eUHtf6VPK6aW08I0RCbYHUa7MsQdatZlsVPQds3uPaPrzpalLjFXXgMszYZzKOu2n1nsu6nvkqAu2dWszYxCSHPuM8CgjkLDLlqoXfy3usDayAEr6nvDq6MYkm5nSbJmpjdHmnAa05OBQBKO0BkRWK3WgmY8KmeY0ObqNJUYfiw)fy3usDayAEr6n18HqF43uXXKk52paR4PrzpyU5d7WqzsDayAEtDJeLEtB)aSINgL9G5MpSddDLlqaUxGDtDJeLEtTXeRX8UTCtj1bGP5fPx5cKt2fy3usDayAEr6nT6UPmsUPUrIsVP88pCay6MYZXC0n1nsWJgZsYM6FUojkDHizHa)cpUq3ibpAmlj7TLMCHizHa)cpUq3ibpAmljZPmXbGPHBBJdJeLUqKSqGFHhxiYl0AluCmPsMfDnLoWHnLj1bGP5cTyzHUrcE0ywsMfDnLoWHnTqKSqGFHOTWJle5folj314QuGdwOTCy)djzwcdQqBxOfll0AluCmPsURXvPahSqB5W(hsYmPoamnxiA3uE(puhKUPZsyJN8zYRCbc6(cSBkPoamnVi9M6gjk9MYiAok7HP(NRtIsVPMpe6d)MY6imEi(3sclZiAok7HP(NRtIshErlejiw4HUP4qPHzEtTc4VYfi9LxGDtDJeLEtBCovUPK6aW08I0RCbIva)fy3u3irP3uoLjoamnCBBCyKO0BkPoamnVi9kx5M6fDb2fiwDb2n1nsu6nTRXvPahSqB5W(hsYBkPoamnVi9kxGCWfy3u3irP30gNtLBkPoamnVi9kxGCOlWUPK6aW08I0BQ5dH(WVPMIhPUkzEKknj)fECHZsYbyhPZqBhgxCM8vxdnMLKLWGk02fECHMQWZkHMzCGGLoM(JQf7pLFYNjx4XfI8cNLK7ACvkWbl0woS)HKm)eOhkBHizHhSqlwwO1wO4ysLCxJRsboyH2YH9pKKzsDayAUq0wOfll0u8i1vjRrBJmSDAHhx4SKmR4WJVKSeguH2UWJl0ufEwj0mJdeS0X0FuTy)P8t(m5cpUqKx4SKCxJRsboyH2YH9pKK5Na9qzlejl8GfAXYcT2cfhtQK7ACvkWbl0woS)HKmtQdatZfI2cTyzHiVqtXJuxLSsMVW1pxOfll0u8i1vjJk5hUUqlwwOP4rQRswlLwiAl84cNLK7ACvkWbl0woS)HKmlHbvOTl84cNLK7ACvkWbl0woS)HKm)eOhkBHNUWdUPUrIsVPghJhUrIsh4Gj3uCWKH6G0nD6pQwS)0O7PURCbYjUa7MsQdatZlsVPMpe6d)MkoMujZQedPHgmIMSmPoamnx4XfACDWiAEtDJeLEtzenhL9Wu)Z1jrPx5ceR)cSBkPoamnVi9MA(qOp8BQ1wO4ysLmRsmKgAWiAYYK6aW0CHhxO1w4SKmJO5OShM6FUojknlHbvOTl84cT2cdDyJJ2gzHhx4SKSP(NRtIsZpz)eRXbGPBQBKO0BkJO5OShM6FUojk9kxGaCVa7MsQdatZlsVPUrIsVPEBPjVPMpe6d)M6gj4rJzjzVT0Kl80fEIfECHwBHZsYEBPjZsyqfA7n1K0GPH4FljSlqS6kxGCYUa7MsQdatZlsVPUrIsVPEBPjVPMpe6d)M6gj4rJzjzVT0Klejiw4jw4Xf(K9tSghaMw4Xfolj7TLMmlHbvOT3utsdMgI)TKWUaXQRCbc6(cSBkPoamnVi9MA(qOp8BQBKGhnMLK5uM4aW0WTTXHrIsxiIfc8l0ILfkHbvOTl84cFY(jwJdat3u3irP3uoLjoamnCBBCyKO0RCbsF5fy3usDayAEr6n1nsu6nLtzIdatd32ghgjk9MA(qOp8BQ1wOeguH2UWJlSJxN4ysL87GDUkd32ghgjkLLj1bGP5cpUq3ibpAmljZPmXbGPHBBJdJeLUWtx4HUPMKgmne)BjHDbIvx5ceRa(lWUPK6aW08I0BQ5dH(WVPSIdpyn(pxiswOv3u3irP3uEbMgIhQCLlqSYQlWUPK6aW08I0BQ5dH(WVPwBHMIhPUkzLmFHRFEtzYhg5ceRUPUrIsVPghJhUrIsh4Gj3uCWKH6G0n1u8i1v5kxGy1bxGDtj1bGP5fP3uZhc9HFtrEHMIhPUkzEKknj)fECHiVqtv4zLqZbyhPZqBhgxCM8vxdLFYNjxOfllCwsoa7iDgA7W4IZKV6AOXSKSeguH2Uq0w4XfAQcpReAMXbcw6y6pQwS)u(jFMCHhxiYlCwsURXvPahSqB5W(hsY8tGEOSfIKfEWcTyzHwBHIJjvYDnUkf4GfAlh2)qsMj1bGP5crBHOTWJle5fI8cnfpsDvYkz(cx)CHwSSqtXJuxLmQKF46cTyzHMIhPUkzTuAHOTWJl0ufEwj0mJdeS0X0FuTy)P8tGEOSfE6cpyHhxiYlCwsURXvPahSqB5W(hsY8tGEOSfIKfEWcTyzHwBHIJjvYDnUkf4GfAlh2)qsMj1bGP5crBHOTqlwwiYl0u8i1vjRrBJmSDAHhxiYl0ufEwj0mR4WJVK8t(m5cTyzHZsYSIdp(sYsyqfA7crBHhxOPk8SsOzghiyPJP)OAX(t5Na9qzl80fEWcpUqKx4SKCxJRsboyH2YH9pKK5Na9qzlejl8GfAXYcT2cfhtQK7ACvkWbl0woS)HKmtQdatZfI2cr7M6gjk9MACmE4gjkDGdMCtXbtgQds30P)OAX(tJUN6UYfiwDOlWUPK6aW08I0BQ5dH(WVPakgBHhxOPk8SsOzghiyPJP)OAX(t5Na9qzlejl0oABKXtGEOSfECHiVqRTqXXKk5UgxLcCWcTLd7FijZK6aW0CHwSSqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTqKSq7OTrgpb6HYwiA3u3irP30P)OgSIdFLlqS6exGDtj1bGP5fP3uZhc9HFtbum2cpUqtv4zLqZmoqWsht)r1I9NYpb6HYwiFl0ufEwj0mJdeS0X0FuTy)P8K7DjkDHNUq7OTrgpb6HYUPUrIsVPt)rnyfh(kxGyL1Fb2nLuhaMMxKEtDJeLEtnogpCJeLoWbtUP4Gjd1bPBAie4vUaXkG7fy3usDayAEr6n1nsu6n14y8Wnsu6ahm5MIdMmuhKUPtc7jP5q(qrrc7kxGy1j7cSBkPoamnVi9M6gjk9MACmE4gjkDGdMCtXbtgQds30Pd6T0q(qrrc7kxGyf6(cSBkPoamnVi9MA(qOp8B6SKCxJRsboyH2YH9pKKzjmOcTDHwSSqRTqXXKk5UgxLcCWcTLd7FijZK6aW08MYKpmYfiwDtDJeLEtnogpCJeLoWbtUP4Gjd1bPBktCziFOOiHDLlqSQV8cSBkPoamnVi9MA(qOp8B6SKmVatdXdvYsyqfA7n1nsu6nf0XKDygV3jCpDLlqoa4Va7MsQdatZlsVPMpe6d)MoljZko84ljlHbvOTl84cT2cfhtQKzvIH0qdgrtwMuhaMM3u3irP3uqht2Hz8ENW90vUa5aRUa7MsQdatZlsVPMpe6d)MATfkoMujZlW0q8qLmPoamnVPUrIsVPGoMSdZ49oH7PRCbYbhCb2nLuhaMMxKEtnFi0h(nLvC4bRX)5crYcpXn1nsu6nf0XKDygV3jCpDLlqo4qxGDtj1bGP5fP3u3irP3uw01u6ah20n18HqF43u3ibpAmljZIUMsh4WMw4Piw4Hw4Xf(K9tSghaMw4XfATfoljZIUMsh4WMYsyqfA7n1K0GPH4FljSlqS6kxGCWjUa7MsQdatZlsVPMpe6d)MAkEK6QKvY8fU(5nLjFyKlqS6M6gjk9MACmE4gjkDGdMCtXbtgQds3utXJuxLRCbYbw)fy3usDayAEr6n18HqF43uaC225qjEH4aW0ysGbJYmXnOwisqSqRh4xOflleqXyl84cbWzBNdL4fIdatJjbgmkZ1TWJl0oABKXtGEOSfE6cT(fAXYcbWzBNdL4fIdatJjbgmkZe3GAHibXcpK1VWJlCwsMvC4XxswcdQqBVPUrIsVPZ3dDGdB6kxGCaW9cSBkPoamnVi9M6gjk9MAJjwJ5DB5MA(qOp8BkR4WacDM5vyxcmnyfMhPsMuhaMM30qf6FUoze23uaC22zEf2LatdwH5rQK56UYfihCYUa7MgQq)Z1j3uRUPUrIsVPZ3dDWko8nLuhaMMxKELlqoaDFb2n1nsu6nL14ZkXaqHLBkPoamnVi9kx5MYOlWUaXQlWUPUrIsVPnoNk3usDayAEr6vUa5GlWUPK6aW08I0BAOc9pxNmc7B6KaWzBNzn(SsmiqaVBOmtCdkKG4q3u3irP3057Hoyfh(MgQq)Z1jJwCbWX3uRUYfih6cSBQBKO0BkRXNvIbGcl3usDayAEr6vUYnnec8cSlqS6cSBQBKO0BkhJgHqGSBkPoamnVi9kx5MQK5RbyIlWUaXQlWUPK6aW08I0BA1DtzKCtDJeLEt55F4aW0nLNJ5OB6SKSP(NRtIsZpb6HYwisw4bl84cNLK92stMFc0dLTqKSWdw4XfoljZPmXbGPHBBJdJeLMFc0dLTqKSWdw4XfI8cT2cfhtQKzrxtPdCytzsDayAUqlww4SKml6AkDGdBk)eOhkBHizHhSq0UP88FOoiDtNLWgsyqfA7vUa5GlWUPK6aW08I0BA1DtzKe23uZhc9HFtnfpsDvYkz(cx)8MojM5Jojk9McSpuuKWwOJJwDHjcPzHNu6cTRFHPn(SsSq0fqaVBOZl8Wq6cTRFH9HDovY3uE(puhKUPYhkksgtc7jVPUrIsVP88pCay6MYZXC0GWm6MAQcpReAEsMa0LqBhakSKFc0dLDt55yo6MAQcpReAURXvPahSqB5W(hsY8tGEOSRCbYHUa7MsQdatZlsVPUrIsVPGoMSdZ49oH7PB6KyMp6KO0Bks5EDHSIdVqwJ)t2cd7fkn0cTJ2gzHjcmEHaOfs6m02fYQsZ3uZhc9HFtLaKgsnMbTWtxiHoKHtOHeG0c7RlKvC4bRX)5cpUWzjzoLjoamnCBBCyKO0SeguH2ELlqoXfy3usDayAEr6n1nsu6nTX5u5MojM5Jojk9MIEotwyJZPYcLAHpz)eRzHai76PfA7yCzBNVPMpe6d)Molj34CQKFc0dLTWtx4blKVfsOdz4eAibiDLlqS(lWUPK6aW08I0BQBKO0BkOJj7WmEVt4E6MojM5Jojk9M2hoABwiqBHDFuFijx4HdCw4t2pXAwyyVqwhPZqBxyP0cBXfahVWefhEUqJZXOfYXwOulemySfkn0cRUU6fonKKluQf(K9tSMfE4aN8cVPMpe6d)MkbiTqKSWt2cpUqaC22zqht2HzK4DPj)eOhkBHNUWwZmd6OZc5BHe6qgoHgsasx5ceG7fy3usDayAEr6nDsmZhDsu6n9KlEAHtc7jP5cLpuuKWwyOl0vjmrNlrPlSSx4HrMa0LqBxislSKVPQds3ucSl5toEu)uD1q3uZhc9HFt55F4aWuw(qrrYysyp5cpDHha83u3irP3ucSl5toEu)uD1qx5cKt2fy3usDayAEr6n1nsu6nLXPaWvnhoijnjzYn18HqF43uE(hoamLLpuuKmMe2tUWtxiW9MQoiDtzCkaCvZHdsstsMCLlqq3xGDtj1bGP5fP3u3irP3uwXHXKiH2oEoajVPMpe6d)MYZ)WbGPS8HIIKXKWEYfE6cr33u1bPBkR4WysKqBhphGKx5cK(YlWUPK6aW08I0BQBKO0BkRXNvcAoQhWOShs9GKk3uZhc9HFt55F4aWuw(qrrYysyp5cpDHN4MQoiDtzn(SsqZr9agL9qQhKu5kxGyfWFb2nLuhaMMxKEtDJeLEt7ACvkWbl0woS)HK8MojM5Jojk9MADSxO0qlSd7jPFHbBHCSqBxyFyNtLZl0oEAHNu6clDHMQWZkHUqPH0fAxyCLyHjcPzHhgsVPMpe6d)MkoMuj34CQKj1bGP5cpUqE(hoamLNLWgsyqfA7vUaXkRUa7MsQdatZlsVPMpe6d)MkoMuj34CQKj1bGP5cpUqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTqKSqG)M6gjk9Mojta6sOTdafwUYfiwDWfy3usDayAEr6n1nsu6nDsMa0LqBhakSCtNeZ8rNeLEtTo2luAOf2H9K0VWGTqowOTlmfD58cTJNw4HH0fw6cnvHNvcDHsdPl0UW4krOTlmrinl8KsVPMpe6d)MkoMujZA8zLyqGaE3qzsDayAUWJlKN)Hdat5zjSHeguH2ELlqS6qxGDtj1bGP5fP3uZhc9HFtfhtQKzn(SsmiqaVBOmPoamnx4XfAQcpReAEsMa0LqBhakSKFc0dLTqKSqG)M6gjk9M214QuGdwOTCy)dj5vUaXQtCb2nLuhaMMxKEtnFi0h(nDwsMtzIdatd32ghgjkn)eOhkBHNUqG7n1nsu6nLtzIdatd32ghgjk9kxGyL1Fb2nLuhaMMxKEtnFi0h(nDws2Blnz(jqpu2cpDHN4M6gjk9M6TLM8kxGyfW9cSBkPoamnVi9MA(qOp8B6SKml6AkDGdBk)eOhkBHNUWtCtDJeLEtzrxtPdCytx5ceRozxGDtj1bGP5fP3uZhc9HFtNLKn1)CDsuA(jqpu2cpDHN4M6gjk9MAQ)56KO0RCbIvO7lWUPK6aW08I0BQBKO0BkOJj7WmEVt4E6MojM5Jojk9MADj7Nynl8Wbol0Tf6xO0qlS6iL(fg2lC6pQwS)0O7PUfMO4WZfACogTqo2cLAHGbJTqFHhoWzHpz)eR5MA(qOp8BQeG0crYcpzl84cbWzBNbDmzhMrI3LM8tGEOSfE6cpyH91f2AMzqhDwiFlKqhYWj0qcq6kxGyvF5fy3usDayAEr6nDsmZhDsu6nf9CmEHt)r1I9NgDp1TWWEHNuJRsbUW0qB5W(hsYfgSfA4(NubNCHsyqfA7n1nsu6n14y8Wnsu6ahm5MYKpmYfiwDtnFi0h(nDwsURXvPahSqB5W(hsYSeguH2EtXbtgQds30P)OAX(tJUN6UYfiha8xGDtj1bGP5fP30jXmF0jrP30(cjWrFiAHUMCHL0q)czIllu(qrrcBHH9cpPgxLcCHPH2YH9pKKlmylucdQqBVPUrIsVPghJhUrIsh4Gj3uM8HrUaXQBQ5dH(WVPZsYDnUkf4GfAlh2)qsMLWGk02BkoyYqDq6MYexgYhkksyx5cKdS6cSBkPoamnVi9M6gjk9Mc6yYomJ37eUNUPtIz(OtIsVPPIBqTWd3XKDywiW5DPzHsTWdDEH1VWNSFI1SWenKUWwsKqBxiUsSqKJj5yCYfIRcvOTl0U(f6l04ydh2fAUqLdea9NxiaozHNiB9Sf(eOhAOTlmyluAOf(eJdllSSxOqmj02fMiKMfcSdozODtnFi0h(nvcqAHizHNSfECHiVqaC22zqht2HzK4DPjZe3GAHNUWdTqlwwiaoB7mOJj7Wms8U0KFc0dLTWtx4jYw)cr7kxGCWbxGDtj1bGP5fP3u3irP3uqht2Hz8ENW90nDsmZhDsu6nTpoNHeL64fE4w3fY6iDYwyIgsxiHoY7lK14)KTq)Pf688a7aW0cDDUqkKg6x4j14QuGlmn0woS)HKCHbBHsyqfA75fw)cLgAH2rBJSWGTqsNH2MVPMpe6d)MI8cNLK7ACvkWbl0woS)HKmlHbvOTl0ILfkbinKAmdAHNUqtv4zLqZDnUkf4GfAlh2)qsMFc0dLTq0w4XfI8cbWzBNbDmzhMrI3LMmtCdQfE6cp0cTyzHSIdpyn(pxiswOvleTRCbYbh6cSBkPoamnVi9M6gjk9MoFp0bR4W30jXmF0jrP30(4CgsuQJx4H9EOlmT4Wl04mzHjAiDHNu6cd2cLWGk02BQ5dH(WVPZsYDnUkf4GfAlh2)qsMLWGk02RCbYbN4cSBkPoamnVi9M6gjk9M6TLM8MojM5Jojk9MI(vIfc0wy3h1hsYfolzHpz)eRzHjAiDHpz)eRXbGP8n18HqF430NSFI14aW0vUa5aR)cSBkPoamnVi9MA(qOp8B6t2pXACay6M6gjk9MYPmXbGPHBBJdJeLELlqoa4Eb2nLuhaMMxKEtnFi0h(n9j7NynoamDtDJeLEtn1)CDsu6vUa5Gt2fy3usDayAEr6n18HqF43uXXKkzw01u6ah2uMuhaMMl84cFY(jwJdat3u3irP3uw01u6ah20vUa5a09fy3usDayAEr6n1nsu6n1gtSgZ72YnnuH(NRtgH9nfaNTDMxHDjW0GvyEKkJgoqxRyM56UPMpe6d)MYkomGqNzEf2LatdwH5rQKj1bGP5nDsmZhDsu6n9KdtSgZ72YcLAHGEOIh6c7duyxcmTW0cZJujFLlqoOV8cSBkPoamnVi9M6gjk9M24CQCtNeZ8rNeLEtr)kbqR7J6dj5cBCovw4t2pXAY3uZhc9HFtNLKBCovYpb6HYw4Pl8qx5cKdb8xGDtj1bGP5fP3u3irP3057Hoyfh(MojM5Jojk9M2xOHk0)CDsaatl8WsxOPXvLWlmSxycAHnopAHsdTWddPleaNTD(MA(qOp8BkaoB78KmbOlH2oauyjZ1DLlqoKvxGDtj1bGP5fP3u3irP3057Hoyfh(MA(qOp8BQ4ysLmRXNvIbbc4DdLj1bGP5cpUWjbGZ2oZA8zLyqGaE3q5Na9qzl80fEOfAXYcNeaoB7mRXNvIbbc4DdLzIBqTWtx4HUPHk0)CDYiSVPtcaNTDM14ZkXGab8UHYmXnOqcIdDCsa4STZSgFwjgeiG3nu(jqpugso0vUa5qhCb2nnuH(NRtUPwDtDJeLEtNVh6GvC4BkPoamnVi9kxGCOdDb2n1nsu6nL14ZkXaqHLBkPoamnVi9kx5kx5k3la]] )


end