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


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        if sourceGUID == GUID and spellName == class.abilities.seed_of_corruption.name then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        end
    end, false )


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


    local SUMMON_DEMON_TEXT

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

        class.abilities.summon_pet = class.abilities.summon_felhunter

        if not SUMMON_DEMON_TEXT then
            SUMMON_DEMON_TEXT = GetSpellInfo( 180284 )
            class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. ( SUMMON_DEMON_TEXT or "Summon Demon" ) .. "]|r"
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
    spec:RegisterPet( "sayaad",
        function()
            if Glyphed( 240263 ) then return 120526
            elseif Glyphed( 240266 ) then return 120527
            elseif Glyphed( 112868 ) then return 58963
            elseif Glyphed( 365349 ) then return 184600
            end
            return 1863
        end,
        "summon_sayaad",
        3600,
        "incubus", "succubus" )

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
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },


        summon_voidwalker = {
            id = 697,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
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


        summon_sayaad = {
            id = 366222,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.fel_domination.up and 0 or 1 end,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "sayaad" ) end,

            copy = { "summon_incubus", "summon_succubus" }
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


    spec:RegisterPack( "Affliction", 20220617, [[Hekili:v33cZTnosd(BX7uLJ1ehhRhot25IDvzsM52mFZRko7MVQU6SmffKe3qrQLpSJ3kN(TFD3aKeaeaeusE28v1utKjbAa0OF3naVz4nF4MRNhuWU53gD(OrN)IHF3zdhnCYWlU56Ih2WU56nbHFkyj8JKG1W))1lwehfweLMGV6H40G5iiYtlZcHxVQOyt(3)8NVmQyv5SZctx)88O1LXbypcZcwuG)D4ZV56zLrXfVl5MzMh)ram3WcHh)cyQSkA(CgVTS8q5zX2B)yqwCA4N2(Z)CzcB7Td)Ut3ElcRT)82F(nRcswYY)(T)8Z2E7RbymF7TxVHfhV92Fb6ZzYp)TS7GfX2B)1GLrHkVzwgl4tHaOsyqhJtH3V92fPqBFBwqemfUoTmM3JpCp0uegXSfyREFWMIYmwDVks3E79PzqtIwS92hslFc(Y1r55rjl3EBa0cORjfW7b4wSka(vw69CG)JjbZIziqxVjaBtdAiF7T)XD)rvVLMl58Xm4U0iCLeNEpnqVni7tlJdWbhhiyhQi6zfbzlzayV)5qpE7V)bOVLB4W6nPjWgqo08801mL()hzSnBVnmiowmwzS5LHWlGn)nLfb8DPIO1moOUghcouWonnGwatJJYHNdt(SiMaq5WVdluwaHRyHFIwby7ZRqr3NM8e4FMXWrpaAe00tcwcBohnGpQ)Es8d4yJVbOeHgUjJ9SnLXXvB1)ZsCc8xMvMbt3382CeCWMmdNuyNG9Rfrlxv8xu2md2SbbCkbE8bZsZZfTe(3tssXfqwq(kyebwPCX85NIz5R4me)JuK9a3yVon(oAZpmaMIXtrAKqIeEoh4rjfSSSYnfWR4W5DWtwMbmqBV93yHzqB(1pIRTO0SOIh4OjElFRahLruOsuUa6d4wrgGWO1WmbXU)qAm22Yflod4ZZsxaZVBU(B(gzAojwp8fgy)Wh3WcI)Ln2q13PZkQ(wFzhf96XJLuma9HTuEoDiynfW7qXEka3)byrfJSt20AYG)ezvfJ5bHDvalpzzfTExzBr(p((w(zaoe2TNfuC5cyAopDDucTVFA0IlXD(Ro)4J2Wkolio6o2Xhr9Fzw060Om200ftZdcZIaMh2zLBma1NE5ZZlxVgOqaGy(9L5SPrfS1NIwrCzbqAHWf6cqaLwMpnK(vPGPXdqKNgZcwLpnhWGSIPfSWvjr)RsM5(ACXqREoJP5flJySNBgKlQPim)(7cYIWUZNUZtlYNcBHZF407cIlzxID5ogSxuagjr0iaeG9bPNhSmn5b1hvcyjeOtdQfXan4KJelJ8OnRi(0f1t(V8fPUl9(RoFWXNGpBdqWc7htrPDGDAij4zfreh8x(sfGn1iXamWcbbWcJyZMf3PXrjSPHZVC45iMphL)pLlxl)S2nFAqk7QlhBg6RcktSrP1gfvPk6h)mlSSazoz3XYEGl1dLpb)pauOgKOCuowqumcIZQhbXSLRSt8mySMt6PMUgvtj)CDHMCAaybDkxE5LdrmGyJHLWwdYtVASmewZ1wnnJRScBoXvcqoyDubXYKbMcdY7sjMsutBaQqnNTjGlCjqOLMl2MuqsYBItZMZL5qIs(WzqxlZYG95gXJPWEW6O)nIROowI6w4YB(JRptEMMvM0EPMGJZ013RSEdtbPLaD0zjvZIJHoJcUxYoRAbFpm3xDSkQ5YHhBNoKw6VwAPMlMYWiN8jgPYzvWDGWvyDEnOVd3Hrvf5b3vV8QuFWLR((0IN)U1BaClju9nbfbOyQnRyp)p4taOLnZaWGNuGgk7(iejHtJW0045P3NCw3efIz508nXrftjDND3P5S4GhaggrNZ7UhaprrDZv2viHaG7BXtZGFuZ5JpnQchmnSbfqcsuAMdjidoMGC(QGS5xnM387aDNaFpOBSbmvYVsVFkGjNIsd8yrnpa48ynllfAmuR(0fbmq6yLO4Zuq2F5l1Bt1l)m2AyILF1OZ)YxoPv3styhBTpVs0QZgEwDBeVAGjGvCFQhaBuBGnaN4IvjA(XQhY8znACZSplyNayVw9(bzZOItAlvrc)8PhGXnr6bjWsAGpOlte19az5O77fQYh4Agr5HQCFWlcd9Mx5GrFqk267EHr6eOMqhKsJFGCFiNe5tsOY5UasoeimfiEDkQ8eiFY6s9m4mXXuxNwndyC7nMIMz8Tnccp2ILCvIdPj37qFjeuTBVf6Hrvp8zjOfnbE2Pc10so)HoHW(Cb5vezMtixrpAMqHpcyfqAkyH1gsBrlrpEPOWJTRr2nhTMeZjvSM0GA5)M0V9N28zNep1HsvRVVEQZPVFpBbyI4kI6bOsybzOLDif(YuYWgqfCkfGdISe(NAtEaONZ8G(iTWaLrdQ)OoW96A9MOSfwrHDupjXCRozYoVTyFRMpfDTL5La8jdQz9TZSlGiWShjesLhSqWQxZ(lSKv2vf4PtreoUx1XS1A)CqTF8(yhjFDF9djH2w5Cxp(hCkIN)BCj0)uattiPQP4LTThNqU)46npa(IdI9)9S5jbuyMqVR4OZOKqmajigEf0namjfrXi6(j5uSRMdZNtg(sugAyAcQ1iyrbJ7K0azCNb0KfBuPGWCHdoJHhFsL(mMy2pnvm5BPF7vdFbkAI9VkJ2SHnVDp61SSInuFo6Mn7GpH)gfVx50d1X09JOxJyC4i3)2urcLRW8q(hMWSg3SEGt62dwDS186rB6myWQx5JFeWt)oYc0WzGX2eiQJl5Y2bHzpdD(NWMd4in0REvwfpWgN4wGPrBZp(iliSbdo0iIoN)gSyB4l6Pe4NKxhfPk5VPCS)6G)jgzbs3BNksRqukEM3LofdACB7AOcIGIO4PHpesEGtrERzOOx2OlsUFIWTHYOtVxyj51Kp6enZymbhe04MxWvmrHToSjWsi)hyQlj5gXmuAhqiX7liB(JeF51uqk3E7VeHQ14O4G4CmE9ScsoBnQwKNG7447Ksa3(Gio)eP(ymZivbumxjAmgIpz7qYn6ytbMqywtlauVXCuuYuXkD3hXMq12JXJmnuQfg3nBcadXflfHMH1rlUE(mOBtLVA4izWBWZgPfQfFFUe8Eu28wtUhzCXiHNSrylhvCJWOh8Kh1wKgpaK8Cl1qTjtqI)1WNnQMl50ggGXvAJE9S804smSTsWqEo2q1yyzQUR9Qjp7eteUnXzRbJmWgjZi(6IBzdXNMc67zzNk8tq2XH7xXG1cMLVl4lR2jBvkbHi)AiWKQzPPbFQLinNW1OoAinT(inGuc7YbRgjMDZcSXXTTzJWI4AIAwnDRlqjnXvomrpdfMejLdO9Yxzx2p7LHYozgbdtT4cCxJBVCpwmm7KluDbxAZ9VR5fdTViTnPMjz0ACknYcUkSXOgyYopCZeBhsAgZidDa2W1uS(LGiOmj3QtpKzcDleuXqIMuYzaL7zugva4a3tpxBWDo1FQ9wmVmJsu8RuMmISnveU6ze7cMvwejgSKjYNsqYdfRewBwqcmcJwerzEloNDpT90jhfbwkXD1rY46vbZrlq(X1ZYci32ejUPj0fvrYZOyOohZC5ScNtJ2ugFWAIs6CgLloTxdkSc)0Roz0Z4aT61K1(1kObohZ9U2FajEG2sr5cALnTKlLQCJlQ)8OLjygTjVK5wRk8PLKRNW(CHzXNc)LlH2g9VjSRQhx1Ui3OkGxHjITlc8KN1ULZtXoWuEH8sOiVz6YWWO8BXxJV8fAhq5zITVXF5lY2d5CZaxQ4MgoNfR11vn6EUdP8Okiq2vuMjSQ6db3CwIkvdkQtfP0wYSYmuI19rjer)jJoxkMdONiCbzfWoh8cyOIcJOG7IWUcUKng8HEqhBd28L1AyjUA05hBavkzK13GiUkuKU76OuzsacstMlV(L80hF2)fPnrkwp726Whvwd6EbzHCaf4y2gekSeNIuh86IkVM8bZbTo3dri2gzHC2L8sslQleqxHPZHxLEQCA0fateQ5b36MwKoDEe7v(0ZdfBPpRFT0j)n1LpLW1Y8QQDa2aElgaKL0B5gK)Ue2Drf8k77TGz15eBza5P5Nf7s5cbKYzmAwAPGdKmsEEQqhiwqHY6Pi6Couu0TJZqU7mrIA(iQEMmDonr4iLRMCUaJ1UbLBo2q0n6HtpEf1aHCEchDiDa0cC7Wvpl9YTJtsD649Wjk5bSPWWQCHzgia)S7eLniy4gv1GNkxCG8nA9MixTD1KgC7(A1x94lI8HsfgMrlzSzlcN86YXh70uLRgRSSLm3rU0ddszxAqCGsdEARc6I)qFD06riNKGBf7D()K9(z3Zg5HzM4JQVdFEi13qnhcmJXydmwL(LFG4O9moDTdcsBzjIjGvPHsY3O28Qj8japUQ6PwRVq7QlNilx84oH8JIuyhW2WA4OkqT5UnInOmEnYl1X8A)QCp1E1y9zHACmLTpWpbj(hGpFGMpX)5KotEgWT7PxpDgmL9wQbyQ2oj2OZaoCGQTcdsxpXKRk1402Ui(NYuvN(5R5OlT7tXDiks(WwXdcKpT0ArX2bBRsnK6xNSxnTD6DLJDo9X2GJnMJtINDSLzhg1A6bWQ6xZmXJojhl)wk1DBzVKIbPw(kWavznIhP9EByNEOmOBDb9WDTlV4CHpZ2DAt1FTlS6FxLf6xy0Es9j5JJhjkyGVk9kPI6YSNjvBUxAuvRmDUX4O0PaXxn8CFQB2l8QvJWsjjzEzuJzQW8nMXKsWF9kcwZwxtDKjihYUmooABWCMMUwmxuhcDYTV6NpPr8i9cZlTkQ9dWo0f(G6FC2GKxfh49K8W0YmC0lIWGmjrYRPS7s9JuhmLWufuivSZ695P6heV5ObwlWZo3DS8CwS)9Cz8dBwHUMfKNhToIFhb4F3ltcxbOEqJpStmpkOinlhvWe(PyPS51jyyZGwHR87Icz(3nqTtkIVbH15SS7sJ6bklilCf8xHf5tHTjwcq08a6FApgE8aloLfghTjVh9QiLn9tjmwo4JskfstV766SmymdYbZSVlThR1W081GHasBrCmhEA7uOmL9E6stwwO2ezJuD0MnP6evAnaPCNfNMo3rBO3pDrz2dUAeldieuzkB1OEy7HthrBbyD5sk4wndJV0oPKQBRn(vzndqV6fglz7o9Z1uN93ft7RT2S36vgy)xIJoFFwJA9(rzrMxMWPrH)aMB5f9Fr(1((ioHJzfKw1SYzp0)v4l3Nv4l)tyfsMPIbRmBgQveKqUMLSdBLMpffEUqNSZluPLQ4yHCjp6MrMQV0x2DefUQvVApeAopgzVI)8Dan0xJdRL4RAj6L9EA4aggNoQXdVv4S73G3URYBVijBToeL3uDSVV0WLFqvvtZV(dmpkxn64w75IN5aFaTW0nGGiMFT3oVsC(O(qvmFUnigm7T58TlQebTIn60T3(2Fq8Q)g53s7f(t1V3hQoYIe3VyT7t854nDkwTunT3Yzi400nxMZkIwCk6bseoJmxbt2cPHJZcjLLAr6TBkOO6ATknnXmwWus5LQuG95Kr(gQm(4jmuTCJQkgSfGvwP0vGIHzg1XkEef)pF1ONkpVOb7VblD6AyP56zbp7e1djIJAYPFkE6swgNodpBr3dll86WjOKFwKefmevgaI6PDtAwrzsuvDQwd1F9J9cRE135QOvwgohEZNBV2(Piezj0lT926qGsvQpqIefgTrC9aH3Oo6NxgZtrpS(Q155LMcGHsEaqJw6ybGVWh4zWSclG7L(ao76WTa1j1h4eIMydUziUhsev7djR5uKlKUoN0pNoy)WtwrkqZFF9zB6hmozniWrk(deZWX1ZtzP2gHMHy)OajFKZD15DU(V(hRx8O8x7lEQ11YW73mwvqzpqcUrPAGTlj5xzHfy3m1Wm9VdBYMySdEAFL5o7LzjtupUYOa2GwN7aUSwvhFDlKnqvw9btG6OV1Qiv(vWJ(KmY5Xjt6is5IqZRSo3JurXlLrQYEzubBxFY1WSBPOoWNtdxpMZ7C2Z4NanZLhjUTpwue016r5Ll9sU8D8UGdRI2O5m(XYb0JWRhtEjRt31DHWqs1IBs56z0HDzgwoFto7c6S)IeauxIQuIddujENRHAily5fscH(WOVBqpP6oXvfq6QWup7cUnTVEo3aq0aKF99cBtYRWeSpxKf0yGxaDaxQUTRqIaSa9J4ubDUJlq2YwiIVLBlK32V0D9OUdvyApQJunCMY9Rh)KXYrDOE3Ui3LtfMFeZ)csrQyD5CSwr1iGLYYPz8ATmDJ1St3As6QBQsX7Q1AkmA7zMAPf9nY3UIB1QQ(wx2IMra(MHZ6lQrZP3C6QY1bjPrZRUs1G9NN1S3i85qm77T7fJ5ICtQttAeX192R53AK0TzkkR9Egou3Xe8wOrpIB0XoP5mM0v5C2ATNMnyPJZQIZu1(QXF9Lqyll)VINMwsEDo7sTsMn)R9KXN7ix8kMeOLFcSYuaZ)ZlaPOlJIT0P2UIfgKLJ(GTapfmzG09POPgly(cay(hMvYfx(Vkb54LRbF2uZsyNqGUttXSEnp6o86VCgEPh7z3tVJLTG7xZ0GeyRBAiEc78S3OLHRtXq8Xc)00nLf8Rls)N9RdcdMbgwMVIbERUg8gl03UUioGFbVolOOi27r8(GpHw6NdBzPjZ9Tx0ouboAZz5BcKteBhuirjlaBbcY3eLbBV5WSD(sAAVGLLgQurwUHKijNhaijMtsPlDNbv7mVUZGkfiBJY)efrdGBKog3E21vPzjy)Ulio17DgKUfVombvV5R9TtGnOGnLRybZRMNjblJxe4yunLyx92yibXTaJuQF5hpDmUA8tPCEjfLVT3U9)hyGnya5)9V)EEe2(LYa8S0dM78UNGk7dttagEY5JIvrcpzrtgxTMvqxd6vJFveKKUZq1I4oDGBbjEvxqkIipFYjd)wh3zkpv(12f)P2o9iOP9w941nyWLdDUsEQTqONMWQwgIhD2qWclQwgcpw9rv(jmy3gQI7t1hQrThQr7ZqPw3evJ2r9yPHjQ7OEm)G2xVT0rP34ZcqPnvZFJ3)JnbttznB9QD0r7h(TMgbIKR(f60(abN5EcJvN98MRbEYCaP089j5MRVpidJcq(nx)Xx)(F7D)2)7VhyVV9dOX6rR5C7uifEIb84tq)ha4NH858Ry)GsWfrEuh43E84nvZVq3uvJ(E6U9VsUWtAif(VFcxar9Jk4p7KrFEqD3hBP7Jm09rT7(K9B0T19oh9T)Ch4vTIoQF40)63JoHjKlJnOsnY26Bm7)p40tRuP()()I)Ppa9rpkNmoUgKdp3lyQwdvMbyNRDfLp9BLp8cVMMg027CX)sVGQv1Z7iEOkrM9efOttYD(PHGu83v()GeLdLOP17FvnFwdG6hydcTyP75mOfpDp7FlUY9S)9hdCXopd6KOyoBrqzCpPj2H5dgG8F83)LowynNZ9Ayj9iBONxEOMo)1(l(EIhD3H4B5UpCxy1KvFmCF5ugUVK6dBrziwVbZcRVscBi7fHMgEzla9IdfG(UdcjwlWSZZhDI1DC(0IMFhNpJ2xPJJ2xAMrTyB8aak2STV8nJ3x(MX7lsCSo5(Urvm(WqSp(WqJoEx2yDcGDBEm58(ppmRFyslPsDdjvd813GQt8sniAEIJPtNQ1dszpPxQ03fkyNUU4r)pmM4Sh6(gldGDbd4wKC3aWmz2Odgb7ODq0OfiPt6)yr5wLjN(r(UdRt1Lx)7Vz80WDyVtfa77szN4egEi5eg1YyP(caDwPDKyBpSpOIA9DRR8rF44TkFGWqIVBUM(f998vokdWd(n6dfSaI38dvFnG1Yn3nxZbz7xuCZVnYieSMMUgyzVjauhBeQ2dEDdyD0gaUtSbxtz0tbOgBaaXlmcrZj5RbGwEpaVxyeEwt7xdiT3eaQFNrOAixGnWZ0lbi9sJqsl1Gnqr)fae(RgHGAwcBaG2ZH(p8CZeT4FlNWqjY2wVcbJzA)UtFOejC3TfhiZSiDNDXMbYJ2IdKzUgps(yRLKZgJdLzgjpsozRfvNdLfoS2HZKATz(hL8v2mfuFm2DlmkYzUuIfr5Xy3TWDyliPuFi(Hkq2K7sz4GYzpxUz1PVuVvdvawDgmvBwbWs0ohgM0hKUbijyfnGSkRk4VIlH)5eqpeO3z7TF72BTNeYT3oy7Tp1utDupgw7JEYjD0s9evsnf(VlHMY)SZNfTHV0mLExAbpvWhPLhjtA)8cFjfEUQS7T92JB98MYHFG80qkdzM0u2VzWilZGr(mdkUp1KovVMbhr7w9htq)3x(c1Bny49APggUtCQ8swn1uM0771Q2uAoPjRLKJkVAnLOtF7lNRW8ORX6ynTP1SnDbvAE1BOAIaJeoXLxPLBq72UkFDxiPwt(PwTAv)sVqY4k93y1gvlKsvaY8RTAzQZBdJgO6UzwTsv5sYObAQp2QnPTVRmAaHH3z1kuR3BgnGZEtSArQ89FGe6x(PwTfTvwIDy2PA2FDyyPJRmdx2e10ioFG25n3eJGXf71GIoG4pkGee1(KNtIsSE6Z3E7R2E7lKfPOFs0v7VZtJUdGrbwHFdHJVs70PR9WeU8lJ74g4XRjV1no5qGBWlX9dhYXc02hSt7vTbry1Il1nB6qGI(kN8P9A2Guzz9jYwGEiWpV8qIFmdS9c)OVKnOwPg9y(aZEiWstoKyjZaBVWsww5cJyKpwF1IURTyS(6rs3Ro5wvF)iP1OXYnIFbjP1Ij(4b5fE5n6l8XnZw67B29pYe6gJpjEQbr0sJgrTdBipAMtR0PYHrTzancWuVhmUr3)36EAq)PY0ue3vth5lrxiIUtKPBTCjCqKCdpVIaQZwF12BVOxTE0fcgaJ3yDnZ3bnikJ8iM0E2Gu8eJ0XbLZJPGU2PMPGFOJlQ2zmDTesTych72SnZBIjeL2XSXKYHhv6Ml6dHWJoztLOztkbE8OuKhvfjqQ3nITy2RUqDCZS3(EjsOi9yFrKTGGKhm4JDZxz7AkAxMfgGJe2Q5LUzZ66glAxMzoGNS)STAKBgolxVr7YeSnyKDpR6DvEJrfMyln55ByGwR40Wp5uto7oGSD66GLyExARm34kf7CZNZeAwpU)kodsnMoSMHHeycGiyDurAz(0qE2KMNEw5MMXq7KFBsAGsiw5xKc5Snb8VHvC4WtvPi36sFJOWR5b6yB)HZ2E7BAUpf4FDFsbyUo6FJYqOosxvev3tiN1mhZkturds4kznkTn(diBS8nnsr8L(ocpgzh7JkaL9KQIk4gdrCrbl(AjSwE13xRQG(nJTk4UO0SZO7uH6pLC4NKQkmv1fQe)4W)(0IN)U11x2rVPrh8ZnDzbO(Tyx5ZWUN0EMs9GbJf9cwTchIH4bP4ZbjCmv7I1M0vIVPZppdnn11Daa6uXX87Dl(DsaNnTPZgUS3P3jOyuU52BOv6ltUA2(lAhTltK)kUIXdYERi8s7C6wy0YzTR4XXq4DL1qF72DpPmbu3W637rWX9e6Jmd9bAo7j7MzpWnD4iAFruD7x7bdR1JHYnkCF9VUVOCh3Ki9hH7eyhs0T3dKBKDVC)WxmQBxi6d60PFohmCPFJInePNIy1tlvHH8eyZyjvL62UQgL)iegVofTtcynYuSvlfVxSow02PYRtLRYkmrCY6Ko2Uf5vUEvyiDgktB8kERIxLaNrJg4ZFWyk8awEQWwnPVuZyfUX(Cb9PvKUDue3EwOTIfU2kmhprzX0EQw3BkNr1bvWIrakSf9IF0I0sfnYMTF5RUz)brCFNMz5OnAl6bACTkXHTWqnAPqKxFh2nN(2mZcYqhqqUZLP0ebmKlDR0h81M7ouyUjN)rFPGv30pYR99DlA5hTtSiDBxWKdo5GpeHnlOUiC8wN7KwupvrtQWqj3v7BFtu6BjV0N7GTiHm)8Gfc5JLQF)81J(HRaOvyOG92XGvU3(pnWeoQWqz(v1kdtknC61pKeAdRYdiW)GtW)8FJRm9Nq(kfTwQE1w2Y1w(Dz6pkYH62B)966AdducFRkkjmDnF3J)5tx8bcpQ4jOYp8dwhGch(YTnFTVf3hMW4nWdVX4kXRdSTBo)Hv7y1nRvgGvB)lAe37So(Onl94tyyUllKX2mVBXipEldNeyfgkfu)jiLIHfN(t)ATK(0Htkh4KS5kccOq7Kuhnl9BO5duyRSTNy5sSLWUJF02nkmu8S(JW)D(LBzf2ag8taUX4sUoyqjYZWyjsBld2kUai1VYLTPk2HEjho2Yve15(WajxBFuWP2d5JdVga27U4ogP7LZoQL7j5vuI164e3xTRd(NyWkrtUCz)KXO56Jbawm3YC8EgynTZJSv9v8m(0z(LManr(BJiUsqWQKPakTK6PsWAX706tJSU(s86jLCZ6A6tdjXgmgTcGMbClB5gGqvdT0vzmkBI)TvMFnXI9KGeVVGEYpsYSUMsXu9NKFABoigVvSMXkiDE1B34CG7tlUNNuYVfFd2Sj(bARAmEUOQwj5N1rUqgjBQOX4OQyrT1VI0vTQ(BjnHYTBevNtfPeYTFtKA3ESKVRjoPeWvH9e2EsRGwlQ2xZlVbA2H4kcrGhw1ZlPcDbNp2nMqmSwIsbLQfrGN09jSR0wkHLSKSXr20)lN(uptFRnMC7PQ4rOazgPRlOgcsckAnnDqJZDo6zKOu3CC0oKdgHbDrupspfyO4bzbdYYoW)A4Zgvlq70gzvJRmQ61ZYtJlXCq(gfMJX7w07EDRl2(tfrbqoSa879z8aGEbF6uBx475qLlwmGUjgjrIHGCq0doPDbng0jQgZnIiSg7mMDFKMgj4vsDo46eX2ywBnoBA77eS0UMy1vIHhQ0GFp5NwN1rukEeBE)J)Hwek80)upDbTdzwKFADgiU(nR6Di70MehKaO0941ruYgBRKQTfTJ)UAml4ejs0m3ZpUv4hFiXuiyjWZlyyfFPIOgw)rkc5EIzKf8ah(Akr2sqemPi3OvU(PLsZw4JRYqIpB19k)tAdezS(y7v9r9YWZ5IFl4N6QvvFE3j5VktxlrWzSU1rAL(rr4QNrciIOlrUYC8Apw8vAi5HIvcF1kibNHrlIWfc(PY6EKgWtfEiSPjtNvLM5Bg7Q9Ch3p2ec5eI87zvLWYzs3a2NjzQMGd251PDLN1(MZj(PBySUvt(POI4iBR2HRzsYLlHa8YnU4fZXtufaikkACvqIyErkctyFUWSMfr80kPVtj0(UAesQdHwJUtuvu9hqbc8ik9M2v3HTARWtLdvnTTeB5Cq3PJ9iyS99QOAdhBtBZT5IcSz85oT7I4oKuJ)XxGqERRA098isXdJPy3Rk)JjKRzfP8D7LOzn8B2Kf1FIq47XZkZOVPgrjZPpgly6GRdYj6YpxoDXku)uomurHrSQp0BvWLWj8HwjAODIRp2zSqfzN(yJ7hQgPJiEBbHYnI)xRXU6H6d1xrs9q(JCzuNuucXN9FjuFxBYEprb9XeHb(JpS50WoriIAtmBPjfr0tr6soZwEnHBo9nZqvqqU5VwqOqkXNxSOcdI87sLPJ8IQiFWBT8JevTDT6BPV6neo2pi9NPKNj6oa1wXP5QtZgHbctBXiJ)HTG7jTc9J4d2Ji8r5v18jqf8wmUTlP3Y9K7DjS7Iih4XqLtF(ZbPsbu0K(SGujxOWrUykMLwkearEPnpvy8b)RmwtgCjEvouuSidrXr1J9050qxHMrhZoxAVODdl3W5bThfwI)BIntU92T)j2ItyRauk997XC8kM0z8V6zKAugXoIhZeRh2mZXJP7vJnlOuIhIj4rZ9hXOHyz(AZMGMpts6XjW4NlPgww5pMmck6wnUK88BcPw0q7)pYxFgDbigonCtuUvvKSoxTDWFco3gMUEwqhhfS6iSCELFyBWBY04O7yvpGM04PqofVOasxmnpa6pilKPu08lyXaFY6OK6Z(VsS(foITHPhWFZ33aGsdASG(G2ZILQFQ42QcaNKVAD1WcB3bbaLalyvoqfhMHfAhlCvs0)QuIJ1Alk840bzgH1sTIXMHdGYbbsMvqb5PZ70911HKeTqPWmwtbi9EssQ5xzuyyDdvcUGrzbsbFxlaZvGzqVmDXZ4hOCFVG(doLIpdIjTzGSP0ojjnIormcbAgs3X0GuCfDjDAwWSFpne28hEooIkSYMsf2qL7gjt6p0z6XZ)I(H2XyAMvgNoZjNRtSOHiB6PlP(e6o3Kak2K2pcb94jU)vJ4FgZ3(4mK14L2jdLJ2OL8cVSARDaxTBVvNz4mmiHEQtguNYNpQl7yo(WL(sdMbAE6AZMTwgZ2w88RQswIysZZfFvnYz0KlBwC5XOHIYMOBKB9I3JX2EUb7s9Y(BRTnN(nkAvLIrAe3C3gbbuwW6napIu3ujJ6Af9ksTGjSuRQTx1ayzhCL01RK)5wf4UYc6qNf2wvASsamnQMqU2GSvXCKq1EeMtpZi0JOy6A7woiYQ9iBh)jw(7wuxEI5avQS3zlUZFvSa9KE3q917rQT8yf(F0m0140PsDl74mu3Jv2HnvCwlMAVYDwRQ71REB6O4ATgA79HQYU2WoTsZBA8(lyV1jS1r9wIZZ25MQzGme30wfzPk0mA5DhwT5E885MWrAn4fmTRVtVswCdhRL7O5W)jzsHItZV6YQYyw3USkBzLCd3PbAoQgWdTrdokzVoId9Lnxgm1IJChr62bI(cNbYwAKgFHvVcLeu1eZ)cdf)xvZ(tiOM8k87)bfuZrQ3XvocQjjkxpahvFa)YB1882rdXyjh))WWxJ9fDvF1BStxb2T8MvXelfp(m)oNfR6vsw15rWc1fHPbN2b2t6qIz52SoArxY2uYD3he6dX8EhTmP5szrK87RPnc80urBPNU923(dIx93ORFltxfWK1fw3dMILj0nx31zyPEhZhJaVXq88SPFYVJYnLjrrkiBkIMQ8mMNMMOuD765k(aCwUTDDwky21kylSKoO3SvT6BQU)ywaQVsbwuD7s0UN14UL8u1fWngc9KFy3)gGaP8STjlknJkEa8W9up7qmDt2BjxexgNodp1E3diS5yOXk5NYp(6INWxrP7Ix77Ljrvf)Anu)1p2AVHyP(UgnQ2RKILHZpJsgTbKGZB6NFkcXZclR3wDRfKZphgaLBuy0gHNbPlAFsXoZ(L)Q0AP1vPanE89TZB2vmEbYATg5DDbY6yaFHZBJvRPEi1(TXQJb7LUUAtTfcS8UVAtDmKt6(Ec1(fir3NdU3vjLzdsXKXR0brfXqYwpffaH0u6N(nQFjOyyGN((6JEOIPMcvpA3rIhlFd0RPqXrO1ScmFKnZZ9LKfaTVCgBfNnBT1Fm41)yn6d1yzh9rTUsRNHfTzlI6avApckDd1UumQJpnrP5owhDAgdN5U2uuZXDUvCluhaJNEUkqwFdl64WjB14iTZnL6fKyROyOcWUphwQPWW65C1TEV33OkQ(GJlDEt4k(uJ8MBnEbkko3DTBJiJrCPJRvurmCPaQpZJCEesLosITCW8WCgr7iGMUp)R)DQWMzuHTxFGwXGfPOd3Ndj7J6YQv4RSEywDtAET5YXej1glQF8AdP4vA(sU22T3skBojAoJF0Tav(8izXpwaiLBCiSeOQooPC9m6GvndRCVjNDrocxKqK6suLvCWavgxWnjQGLxijo(dJ(UboO0pXVsNSRcN9SleftzRGF5h(81ZNhH)cTz9xFVWC28kCh7ZfzbnEwWpOv3fefJJcsYbOkweNMRt6lX2JSRj4B5MpRyYRVvyYEwIR(G)Tu6QwdrOCacSIOfLCk)CkXVIa44B0ujfos)z2mfLqv9vQZNFb5guCTzowsQAmpsbUuzhsodVUdAyFYfSJJNRrWODyJTR70vKmo2s(Q10m36a0w1o5Oh6rabNUQCDqsA0CQq9AMIEeUrv)1Qh2TAh6I)Haaibghc083MxgMCihioEwdHHWXCbwYdFWhtb0WMVfwzr(7j14Vis(YBb2b8lBBctCE(UNHZgSmijPiOPXes(g9OuRB8jpkSToRQMMs9XyxVoSvuOY64mEn(ROGDwuD6l)QzgzCFQzBSO68mQ64SX4VIbxTSyf(Hq66O1VHEYn))p]] )


end