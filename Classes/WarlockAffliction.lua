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


    spec:RegisterPack( "Affliction", 20220327, [[dq1xQdqiQQ0IiaHEeKO2ei5tekJcs1PGuwLkPsVsLOzrGUfic7sIFPsYWGe6yqslts4zsIAAQKY1OQI2giI(gKinoibDoqQsRJa4DGufAEGuUNq1(iGoivvWcvj8qquMOkPQlcsvzJGuf9rvsfAKQKkYjja1kbHxQsQGmtquDtqKStcv)eKQQHcIulLQk0tHyQuv1vjaPTsaI(kKaJvsK3sacURkPcSxb)vfdwvhMYIvPEmvMSsDzKnlKplPgTsCArRgKQGxtqZgQBdQDt63kgUs64qIy5apNOPJ66uLTtiFxsA8Gu58cL1RsQOMpvL7RsQGA)sDa1G)bKTXuq8kqXkQafRCfO0cQO0kqruVwaHJTsbKvZj0QPaIAWuaXpefHthNJgqwTy4X2b)diYXd4OaYcZRsb4QRQtEX7U4g4RKjSh24CuhWI4RKjS7QaYTxIzbSgUdiBJPG4vGIvubkw5kqPfurPvGIOwrarUsUG4vaj9ZaYsU3KgUdiBs6ci(HOiC64C0(rbgapoHneqkd4w6VcuQG9xbkwrfneneq2IP1KuaAiGe97h2BA3pYkHX9d5JtyPHas0VFyVPD)xpjA8a9dPS60vAiGe97h2BA3)nGmHUftvc3pEQtx)rdO)RhyP2pY4HlneqI(9Vkzc7hszykkD97hTv2dq9JN601pp9xDac7pJ6p24jgG6hoLYuR736NnmPC)P2pVyC)GPAPHas0p0NA3yQF)ObVAk3VFikcNoohv2pKweKUF2WKYLgcir)(xLmHY(5PFt0K7(VXt1uR7)6nGWASbO(tTFypmNqc2a1e3F1RM(VEOF)L97TwAiGe9dzJUjvs9lhyQ)R3acRXgG6hsdO1(Dggl7NN(b02Zr97g4vp24C0(5eMkneqI(riUF5at97mm(yooh9Gtj3pPmijz)80VKbPJ7NN(nrtU73TqoHPw3poLSSFEX4(RoQyC)3u)aYCl0UF0TAlv)IwPHas0p0VIJ1pcr7(h1r9VciiXQhgxAiGe97h2qp4j5(fq82dO9dzxVS)BkAau)KU7FI6pkRxybe7hp1PRFE63wxXX6FuCS(5P)7rk7pkRxyz)ORd3pdm5s)RMtOeTsdbKOFONysU4aweFLaYbBCIP(rgSis5(DM6i8jJ63TyAnT7NN(tLjaWBLpzuPHas0VawzQgym1V4Kdm9dPqb9VcYbKCS(XPKlbKvWeLykGGYOC)(HOiC64C0(rbgapoHneOmk3pKYaUL(RaLky)vGIvurdrdbkJY9dzlMwtsbOHaLr5(He97h2BA3pYkHX9d5JtyPHaLr5(He97h2BA3)1tIgpq)qkRoDLgcugL7hs0VFyVPD)3aYe6wmvjC)4PoD9hnG(VEGLA)iJhU0qGYOC)qI(9Vkzc7hszykkD97hTv2dq9JN601pp9xDac7pJ6p24jgG6hoLYuR736NnmPC)P2pVyC)GPAPHaLr5(He9d9P2nM63pAWRMY97hIIWPJZrL9dPfbP7NnmPCPHaLr5(He97FvYek7NN(nrtU7)gpvtTU)R3acRXgG6p1(H9WCcjydutC)vVA6)6H(9x2V3APHaLr5(He9dzJUjvs9lhyQ)R3acRXgG6hsdO1(Dggl7NN(b02Zr97g4vp24C0(5eMkneOmk3pKOFeI7xoWu)odJpMJZrp4uY9tkdss2pp9lzq64(5PFt0K7(DlKtyQ19Jtjl7NxmU)QJkg3)n1pGm3cT7hDR2s1VOvAiqzuUFir)q)kow)ieT7Fuh1)kGGeREyCPHaLr5(He97h2qp4j5(fq82dO9dzxVS)BkAau)KU7FI6pkRxybe7hp1PRFE63wxXX6FuCS(5P)7rk7pkRxyz)ORd3pdm5s)RMtOeTsdbkJY9dj6h6jMKloGfXxjGCWgNyQFKblIuUFNPocFYO(DlMwt7(5P)uzca8w5tgvAiqzuUFir)cyLPAGXu)ItoW0pKcf0)kihqYX6hNsU0q0qyoohvwwbKBGVnoEeHp7bovJZrfmJIZjmjquek)UsCXWPick)E7ffvQbj8Ka6mrhP5azu6OI3AdH54CuzzfqUb(24lJFL0dgE0ZkXneMJZrLLva5g4BJVm(vEs6KmblOAWuCEGPZeDGhvYGXtECJkzGNJZrLneMJZrLLva5g4BJVm(vEs6KmblOAWuC5GjBrEKKdq8Hj3IMOepQHWCCoQSSci3aFB8LXVQgKWtcOZeDKMdKrPJemJIZgMuUuds4jb0zIosZbYO0rfsTBmTBimhNJklRaYnW3gFz8RIWKCXbSiUHWCCoQSSci3aFB8LXVsKbs7gtcQgmfFpS8aiBhtqrg2JIBoofrN9Wf3aaERCoQarrOmhNIOZE4IvpAmbIIqzoofrN9WfpvY2nMowueoDCoQarrOq3VSHjLlYCDz0doJOcP2nM2(8zoofrN9WfzUUm6bNrKarr0Gc99WL1ft5b(itT2dBGKJv40jm1AF(8lBys5Y6IP8aFKPw7HnqYXkKA3yAJwdH54CuzzfqUb(24lJFLKO9zIoUba8w5CubXPsh3ooQOOGzuC5kHXh2a1ellsI2Nj64gaWBLZrp2qcmELBimhNJklRaYnW3gFz8RwmpLBimhNJklRaYnW3gFz8R8ujB3y6yrr40X5OneneOmk3p0h0ropM29tIiqS(5eM6NxO(nhpG(tz)MilX2nMkneMJZrLXLRegFWJtydH54Cu5LXVAtIgpWb2QtxdH54Cu5LXVYzy8XCCo6bNswq1GP42qckzq644Okygf3CCkIoKsWjjfyLBimhNJkVm(vWgMIs3byRShGemJIF7ffvCg2GtE8KhhGKos3tXBTHaL7hYmmUFjTAaJP(nhNJ2poLC)rdOFXjhyWdy3pKcf0FQ9J4FPFiZdaiLXX6FuCS(NvoHZRZ0U)Ob0VNK6VAYl9dPrkneMJZrLxg)kGNEmhNJEWPKfunykUsoWCGRkOKbPJJJQGzuC3iIut5IsoWGhWgkGNsrdOMkWgMIs3PkW4fOmhNIOdPeCsY4OcfBys5Y6IP8aFKPw7HnqYXAiq5(9doohTFCkzz)rdOFgKQqI7)Mwmr5ak9JWgl73au)steT7pAa9FtrdG6hz8W97hh(kbm8kP7uR7hYm2KmywxORG0lMYdC)iPw7HnqYXeS)Hxiq1us9pA)UzW7PQwAimhNJkVm(vodJpMJZrp4uYcQgmfNbPkK4JCfN8XTqoHneMJZrLxg)kNHXhZX5OhCkzbvdMIVjSfJ2hgKQqILneMJZrLxg)kNHXhZX5OhCkzbvdMIlzJpmivHelfuYG0XXrvWmko67HlYXdFadx40jm1AF(2dxs4vs3PwFCgBsgmRl0zpCHtNWuR95BpCzDXuEGpYuR9Wgi5yfoDctTgnOKJh(ixmWwGv2NV9WfrjMoSLkx40jm1AF(ydtkxKt1dVqhjrBzdH54Cu5LXVYzy8XCCo6bNswq1GP4Bd2QPddsviXsbZO4UrePMYfnRx4tKrqHUFfzG0UXuHbPkK4JCfNSpFUzW7PQwKJh(agUaiylvPaRaf95dDrgiTBmvyqQcj(mkbLBg8EQQf54HpGHlac2svcngKQqIlOwCZG3tvTaiylvjA(8HUidK2nMkmivHeF4QduUzW7PQwKJh(agUaiylvj0yqQcjUurXndEpv1cGGTuLOHMpFUrePMYfrKYlXaqHUFfzG0UXuHbPkK4JCfNSpFUzW7PQws4vs3PwFCgBsgmRlubqWwQsbwbk6Zh6ImqA3yQWGufs8zuck3m49uvlj8kP7uRpoJnjdM1fQaiylvj0yqQcjUGAXndEpv1cGGTuLO5Zh6ImqA3yQWGufs8HRoq5MbVNQAjHxjDNA9XzSjzWSUqfabBPkHgdsviXLkkUzW7PQwaeSLQen085dD3iIut5IsoWGhW2Np3iIut5IWyG0uF(CJisnLl6OeAqHUFfzG0UXuHbPkK4JCfNSpFUzW7PQwwxmLh4Jm1ApSbsowbqWwQsbwbk6Zh6ImqA3yQWGufs8zuck3m49uvlRlMYd8rMATh2ajhRaiylvj0yqQcjUGAXndEpv1cGGTuLO5Zh6ImqA3yQWGufs8HRoq5MbVNQAzDXuEGpYuR9Wgi5yfabBPkHgdsviXLkkUzW7PQwaeSLQen085ZVSHjLlRlMYd8rMATh2ajhRqQDJPnuO7xrgiTBmvyqQcj(ixXj7ZNBg8EQQfPhm8ONTbewJnavaeSLQuGvGI(8HUidK2nMkmivHeFgLGYndEpv1I0dgE0Z2acRXgGkac2svcngKQqIlOwCZG3tvTaiylvjA(8HUidK2nMkmivHeF4QduUzW7PQwKEWWJE2gqyn2aubqWwQsOXGufsCPIIBg8EQQfabBPkrdTgcuU)l8aA)YXd3VCXaBz)zu)rz9c3Fk73WWJK7FerGgcZX5OYlJFfSHPO0Da2k7bibZO43JucvuwVWhabBPkHgbDKZJPdNW01voE4JCXaBO2dx8ujB3y6yrr40X5OfoDctTUHaL7xah1VBerQPC)7HVcsVykpW9JKATh2ajhR)u2pWt1uRfSFpj1)1BaH1ydq9Zt)e0XKU7NxO(DEaaPC)sIBimhNJkVm(vodJpMJZrp4uYcQgmfFBaH1ydqNvaTkygfhD3iIut5Iis5LyaO2dxs4vs3PwFCgBsgmRl0zpCHtNWuRHYndEpv1I0dgE0Z2acRXgGkac2svcTkGc99WL1ft5b(itT2dBGKJvaeSLQuGv4ZNFzdtkxwxmLh4Jm1ApSbsogAO5Zh6UrePMYfnRx4tKrqThUihp8bmCHtNWuRHYndEpv1I0dgE0Z2acRXgGkac2svcTkGc99WL1ft5b(itT2dBGKJvaeSLQuGv4ZNFzdtkxwxmLh4Jm1ApSbsogAO5Zh6O7grKAkxuYbg8a2(85grKAkxegdKM6ZNBerQPCrhLqdQ9WL1ft5b(itT2dBGKJv40jm1AO2dxwxmLh4Jm1ApSbsowbqWwQsOvbAneOC)(rkcqYL(3dl7Nmaow)zu)1tQ19Nkp9B9lxmWUF5kP7uR7FDXKudH54Cu5LXVYzy8XCCo6bNswq1GP47HpRaAvWmko6UrePMYfnRx4tKrq539Wf54HpGHlC6eMAnuUzW7PQwKJh(agUaiylvj0UgA(8HUBerQPCreP8smau(DpCjHxjDNA9XzSjzWSUqN9WfoDctTgk3m49uvlj8kP7uRpoJnjdM1fQaiylvj0UgA(8Ho6UrePMYfLCGbpGTpFUrePMYfHXaPP(85grKAkx0rj0GInmPCzDXuEGpYuR9Wgi5yq539WL1ft5b(itT2dBGKJv40jm1AOCZG3tvTSUykpWhzQ1EydKCScGGTuLq7AO1qGY9lGJ6hsVykpW9JKATh2ajhR)u2pNoHPwly)j3Fk7xAru)80VNK6)6nGW(rgpCdH54Cu5LXVABaHh54HfmJIVhUSUykpWhzQ1EydKCScNoHPw3qyoohvEz8R2gq4roEybZO4(LnmPCzDXuEGpYuR9Wgi5yqH(E4IC8WhWWfoDctT2NV9WLeEL0DQ1hNXMKbZ6cD2dx40jm1A0Aiq5(rIPU(H0lMYdC)iPw7HnqYX6VAYl9lGKuEjg4kXZ6fUFONg1VBerQPC)7HfS)Hxiq1us97jP(hTF3m49uvl9lGJ6h6dEngGmC)q)GTAQJ6)2lkQ)u2FQUbo1Ab7FzW7(9uoX9NSyY(bKTJ1p6OIc7xsUr3Y(TiMa97jj0AimhNJkVm(vRlMYd8rMATh2ajhtWmkUBerQPCrZ6f(ezeuCctc0pHYndEpv1IC8WhWWfabBPkHgQqHodsviXfcEngGm8zaB1uhvCZG3tvTaiylvj0qfswHpF(LqjE56kTle8Amaz4Za2QPocTgcZX5OYlJF16IP8aFKPw7HnqYXemJI7grKAkxerkVedafNWKa9tOCZG3tvTKWRKUtT(4m2KmywxOcGGTuLqdvOqNbPkK4cbVgdqg(mGTAQJkUzW7PQwaeSLQeAOcjRWNp)sOeVCDL2fcEngGm8zaB1uhHwdbk3V4Kdm4bS7VAYl9dPmmfLU(rbaJx63zsw2)6IP8a3Vm1ApSbsow)P2povQ)QjV0)1tUe24uR7)IbZneMJZrLxg)Q1ft5b(itT2dBGKJjygf3nIi1uUOKdm4bSHc4Pu0aQPcSHPO0DQcmEbkoHjb6Nq5MbVNQAztUe24uRp3dMlac2svcTkdf6mivHexi41yaYWNbSvtDuXndEpv1cGGTuLqdvizf(85xcL4LRR0UqWRXaKHpdyRM6i0Aiq5(H(5fc0VBerQPSSF0t1H92Pw3VokKasHc6xCYbg063zsUFins)J2VBg8EQQneMJZrLxg)Q1ft5b(itT2dBGKJjygfhD3iIut5IWyG0uF(CJisnLl6OKpFO7grKAkxuYbg8a2q5xGNsrdOMkWgMIs3PkW4f0qdk0zqQcjUqWRXaKHpdyRM6OIBg8EQQfabBPkHgQqYk85ZVekXlxxPDHGxJbidFgWwn1rO1qyoohvEz8RwxmLh4Jm1ApSbsoMGzu87rkHkkRx4dGGTuLqdvizdbk3VaoQFi9IP8a3psQ1EydKCS(tz)C6eMATG9NSyY(5eM6NN(9Ku)dVqG(HnOhgq)7HLneMJZrLxg)kNHXhZX5OhCkzbvdMI7grKAklOKbPJJJQGzu89WL1ft5b(itT2dBGKJv40jm1AOq3nIi1uUOz9cFImYNp3iIut5Iis5Lya0AimhNJkVm(vw9OXe0fZHPdBGAILXrvWmk(E4IvpAScGGTuLq7AneMJZrLxg)QfZt5gcuUFKPA)8c1pcrBz)J2FL7NnqnXY(ZO(tU)uQIX978aaszCS(tT)iCwVW9pG(hTFEH6NnqnXL(rbjV0psUUmA)qEgr9NSyY(nSC6)MyMa9Zt)EsQFeI29pIiq)WM6zyCS(T1vCSuR7VY9dzda4TY5OYsdH54Cu5LXVss0(mrh3aaERCoQGzuCZXPi6qkbNKuGvafBys5ICQE4f6ijAlHYV7HlsI2Nj64gaWBLZrlC6eMAnu(n1teoRx4gcZX5OYlJFLKO9zIoUba8w5CubZO4MJtr0HucojPaRak2WKYfzUUm6bNreu(DpCrs0(mrh3aaERCoAHtNWuRHYVPEIWz9cd1E4IBaaVvohTaiylvj0UwdH54Cu5LXVsuIPdBPYcMrXrxoE4JCXaBbIQpFMJtr0HucojPaRanOCZG3tvTi9GHh9SnGWASbOcGGTuLce1kAimhNJkVm(vEQKTBmDSOiC64CubZO4MJtr0zpCXtLSDJPJffHthNJghf95JtNWuRHApCXtLSDJPJffHthNJwaeSLQeAxRHWCCoQ8Y4xjZ1Lrp4mIe0fZHPdBGAILXrvWmk(E4Imxxg9GZiQaiylvj0UwdH54Cu5LXVYzy8XCCo6bNswq1GP4UrePMYckzq644Okygf3VUrePMYfLCGbpGDdbk3VFyDfhRFiBaaVvohTFyt9mmow)J2pQqIk6NnqnXsb7Fa9pA)vU)QjV0VF4woypM6hYgaWBLZrBimhNJkVm(vUba8w5CubDXCy6WgOMyzCufmJIBoofrhsj4KKq7Aqc0zdtkxKt1dVqhjrBPpFSHjLlYCDz0doJi0GApCXnaG3kNJwaeSLQeAv0qGY97hIyc0pVq9pRKsab7xUs6UFRF5Ib29xDH0(nUF)S)r7hszykkD97hTv2dq9Zt)MOj39pIiGZwxtTUHWCCoQ8Y4xbBykkDhGTYEasWmkUC8Wh5Ib2c8AqXjmjWkqTHaL7hfSqA)6W9lJPUuR7hsVykpW9JKATh2ajhRFE6xajP8smWvIN1lC)qpnsW(r8GHhT)R3acRXgG6pJ63W4(3dl73au)26koPDdH54Cu5LXVYzy8XCCo6bNswq1GP4BdiSgBa6ScOvbZO4O7grKAkxerkVedaLFzdtkxwxmLh4Jm1ApSbsogu7Hlj8kP7uRpoJnjdM1f6ShUWPtyQ1q5MbVNQAr6bdp6zBaH1ydqfaz7yO5Zh6UrePMYfnRx4tKrq5x2WKYL1ft5b(itT2dBGKJb1E4IC8WhWWfoDctTgk3m49uvlspy4rpBdiSgBaQaiBhdnF(qhD3iIut5IsoWGhW2Np3iIut5IWyG0uF(CJisnLl6OeAq5MbVNQAr6bdp6zBaH1ydqfaz7yO1qGY9lGkP(VEdiSFKXd3Fg1)1BaH1ydq9xDuX4(VP(bKTJ1VvBPky)dO)mQFEHau)vtmU)BQFJ7htMK7VI(Hha1)1BaH1ydq97jjzdH54Cu5LXVABaHh54HfmJIFpsjuUzW7PQwKEWWJE2gqyn2aubqWwQsbgL1l8bqWwQsOq3VSHjLlRlMYd8rMATh2ajhZNp3m49uvlRlMYd8rMATh2ajhRaiylvPaJY6f(aiylvjAneMJZrLxg)QTbeEKJhwWmk(9iLq5x2WKYL1ft5b(itT2dBGKJbLBg8EQQfPhm8ONTbewJnavaeSLQ8s3m49uvlspy4rpBdiSgBaQS9agNJcTOSEHpac2sv2qGY9dzg7wGegg3FYeC)EsRM6pAa9BAmEj16(1H7xUsUmkPD)ewsvxia1qyoohvEz8RCggFmhNJEWPKfunykEYeCdbkJY97hPiajx6hzX2t1(H(GVbMJ6)MIga1VCL0DQ19lxmWw2)O9dPmmfLU(9J2k7bOgcZX5OYlJFLZW4J54C0doLSGQbtXLKGzuC2WKYf5ITNQhc(gyoQqQDJPnuOVPBVOOICX2t1dbFdmhvKS5ecn0RasyoohTixS9u9CpyUK6jcN1lmA(8TPBVOOICX2t1dbFdmhvaeSLQeAvgTgcuUFbuj1pKYWuu663pARShG6V6cP9dBqpmG(3dl73au)ERc2)a6pJ6Nxia1F1eJ7)M6xM1AgLot5(5eM63t5e3pVq9Re0X9dPxmLh4(rsT2dBGKJv6xah1VhN486CQ19dPmmfLU(rbaJxeS)LbV736xUyGD)80pGIaKCPFEH6)2lkQHWCCoQ8Y4xbBykkDhGTYEasWmko67HlIsmDylvUWPtyQ1(8ThUKWRKUtT(4m2KmywxOZE4cNoHPw7Z3E4IC8WhWWfoDctTgnOq3VapLIgqnvGnmfLUtvGXl(8D7ffvGnmfLUtvGXlfjBoHqRY(8jhp8rUyGTarfTgcuUFbuj1pKYWuu663pARShG6NN(HTuzl1(5fQFydtrPR)QaJx6)2lkQFpLtC)YfdSL9ReT7NN(VP(RjLagt7(Jgq)8c1Vsqh3)ThqY9xn19uTF0Raf7xsUr3Y(tz)WdG6NxmTFPxuu6ss5(5P)AsjGXu)vUF5Ib2s0AimhNJkVm(vWgMIs3byRShGemJId8ukAa1ub2Wuu6ovbgVaLBg8EQQf54HpGHlac2svkWkqrOU9IIkWgMIs3PkW4LcGGTuLq7AneOC)qklv2sTFiLHPO01pkay8s)g3VHX9Zjmj7pAa9Zlu)ItoWGhWU)b0)1HIbst73nIi1uUHWCCoQ8Y4xbBykkDhGTYEasWmkoWtPObutfydtrP7ufy8cuO7grKAkxuYbg8a2(85grKAkxegdKMIgu3ErrfydtrP7ufy8sbqWwQsODTgcuUFbuj1pKYWuu663pARShG6F0(H0lMYdC)iPw7HnqYX63zswky)WMWuR7x6bO(5PFPjI636xUyGD)80VKnNW(HugMIsx)OaGXl9Nr97jtTU)KBimhNJkVm(vWgMIs3byRShGemJIZgMuUSUykpWhzQ1EydKCmOqFpCzDXuEGpYuR9Wgi5yfoDctT2Np3m49uvlRlMYd8rMATh2ajhRaiylvPaRWp957EKsO4eMo8C2jbn3m49uvlRlMYd8rMATh2ajhRaiylvjAqHUFbEkfnGAQaBykkDNQaJx8572lkQaBykkDNQaJxks2CcHwL95toE4JCXaBbIkAneMJZrLxg)kydtrP7aSv2dqcMrXzdtkxKt1dVqhjrBzdbk3)1dSu7hYZiQ)u2)O4y9B9F9qAK(RTu7VAYl9lGvsuY2nM6)6j4us9RKb6h2GU(LS5ekl9lGJ6pkRx4(tz)294X9Zt)KU7Fp9Rd3pCkL9lxjDNAD)8c1VKnNqzdH54Cu5LXVAdSup4mIemJIF7ffvsLeLSDJPZMGtjvKS5ekWRHI(8D7ffvsLeLSDJPZMGtjv8wH6EKsOIY6f(aiylvj0UwdH54Cu5LXVYzy8XCCo6bNswq1GP4UrePMYneMJZrLxg)kRE0yc6I5W0HnqnXY4OkygfhqrasUy3yQHWCCoQ8Y4x5Ps2UX0XIIWPJZrfmJIBoofrN9WfpvY2nMowueoDCoACu0NpoDctTgkafbi5IDJPgcZX5OYlJFLmxxg9GZisqxmhMoSbQjwghvbZO4akcqYf7gtneMJZrLxg)k3aaERCoQGUyomDydutSmoQcMrXbueGKl2nMGYCCkIoKsWjjH21GeOZgMuUiNQhEHosI2sF(ydtkxK56YOhCgrO1qyoohvEz8RIWKCXbSiwWmkUC8W3PUlIgSXjMoYblIuwWuzca8w5tgf)2lkQiAWgNy6ihSis5I3AdH54Cu5LXVAdSupYXdlyQmbaERCCuBimhNJkVm(vYfBpvp3dMBiAimhNJkl2qXxxmLh4Jm1ApSbsowdH54CuzXg6Y4xTyEk3qyoohvwSHUm(vodJpMJZrp4uYcQgmfFBaH1ydqNvaTkygf3nIi1uUiIuEjgaQ9WLeEL0DQ1hNXMKbZ6cD2dx40jm1AOCZG3tvTi9GHh9SnGWASbOcGSDmOqFpCzDXuEGpYuR9Wgi5yfabBPkfyf(85x2WKYL1ft5b(itT2dBGKJHMpFUrePMYfnRx4tKrqThUihp8bmCHtNWuRHYndEpv1I0dgE0Z2acRXgGkaY2XGc99WL1ft5b(itT2dBGKJvaeSLQuGv4ZNFzdtkxwxmLh4Jm1ApSbsogA(8HUBerQPCrjhyWdy7ZNBerQPCrymqAQpFUrePMYfDucnO2dxwxmLh4Jm1ApSbsowHtNWuRHApCzDXuEGpYuR9Wgi5yfabBPkHwfneMJZrLfBOlJFLKO9zIoUba8w5CubZO4SHjLlYP6HxOJKOTekNPhjr7gcZX5OYIn0LXVss0(mrh3aaERCoQGzuC)YgMuUiNQhEHosI2sO87E4IKO9zIoUba8w5C0cNoHPwdLFt9eHZ6fgQ9Wf3aaERCoAbqrasUy3yQHWCCoQSydDz8RS6rJjOlMdth2a1elJJQGzuCZXPi6ShUy1JgdAxdk)UhUy1JgRWPtyQ1neMJZrLfBOlJFLvpAmbDXCy6WgOMyzCufmJIBoofrN9WfRE0ycm(1GcqrasUy3ycQ9WfRE0yfoDctTUHWCCoQSydDz8R8ujB3y6yrr40X5OcMrXnhNIOZE4INkz7gthlkcNoohnok6ZhNoHPwdfGIaKCXUXudH54CuzXg6Y4x5Ps2UX0XIIWPJZrf0fZHPdBGAILXrvWmkUF50jm1AOwfTYgMuUam4vt5JffHthNJklKA3yAdL54ueD2dx8ujB3y6yrr40X5OqRYneMJZrLfBOlJFLOeth2sLfmJIlhp8rUyGTarTHWCCoQSydDz8RCggFmhNJEWPKfunykUBerQPSGsgKoooQcMrX9RBerQPCrjhyWdy3qyoohvwSHUm(vodJpMJZrp4uYcQgmfFBaH1ydqNvaTkygfhD3iIut5Iis5LyaOq3ndEpv1scVs6o16JZytYGzDHkaY2X85BpCjHxjDNA9XzSjzWSUqN9WfoDctTgnOCZG3tvTi9GHh9SnGWASbOcGSDmOqFpCzDXuEGpYuR9Wgi5yfabBPkfyf(85x2WKYL1ft5b(itT2dBGKJHgAqHo6UrePMYfLCGbpGTpFUrePMYfHXaPP(85grKAkx0rj0GYndEpv1I0dgE0Z2acRXgGkac2svcTkGc99WL1ft5b(itT2dBGKJvaeSLQuGv4ZNFzdtkxwxmLh4Jm1ApSbsogAO5Zh6UrePMYfnRx4tKrqHUBg8EQQf54HpGHlaY2X85BpCroE4dy4cNoHPwJguUzW7PQwKEWWJE2gqyn2aubqWwQsOvbuOVhUSUykpWhzQ1EydKCScGGTuLcScF(8lBys5Y6IP8aFKPw7HnqYXqdTgcZX5OYIn0LXVABaHh54HfmJIFpsjuUzW7PQwKEWWJE2gqyn2aubqWwQsbgL1l8bqWwQsOq3VSHjLlRlMYd8rMATh2ajhZNp3m49uvlRlMYd8rMATh2ajhRaiylvPaJY6f(aiylvjAneMJZrLfBOlJF12acpYXdlygf)EKsOCZG3tvTi9GHh9SnGWASbOcGGTuLx6MbVNQAr6bdp6zBaH1ydqLThW4CuOfL1l8bqWwQYgcZX5OYIn0LXVYzy8XCCo6bNswq1GP4jtWneMJZrLfBOlJFLZW4J54C0doLSGQbtX3e2Ir7ddsviXYgcZX5OYIn0LXVYzy8XCCo6bNswq1GP4Bd2QPddsviXYgcZX5OYIn0LXVYzy8XCCo6bNswq1GP4s24ddsviXsbLmiDCCufmJIVhUSUykpWhzQ1EydKCScNoHPw7ZNFzdtkxwxmLh4Jm1ApSbsowdH54CuzXg6Y4xbBykkDhGTYEasWmk(E4IOeth2sLlC6eMADdH54CuzXg6Y4xbBykkDhGTYEasWmk(E4IC8WhWWfoDctTgk)YgMuUiNQhEHosI2YgcZX5OYIn0LXVc2Wuu6oaBL9aKGzuC)YgMuUikX0HTu5gcZX5OYIn0LXVc2Wuu6oaBL9aKGzuC54HpYfdSf41AimhNJkl2qxg)kzUUm6bNrKGUyomDydutSmoQcMrXnhNIOZE4Imxxg9GZicAXRmuakcqYf7gtq539WfzUUm6bNruHtNWuRBimhNJkl2qxg)kNHXhZX5OhCkzbvdMI7grKAklOKbPJJJQGzuC3iIut5IsoWGhWUHWCCoQSydDz8R2al1doJibZO43ErrLujrjB3y6Sj4usfjBoHcmUFII(8Dpsju3ErrLujrjB3y6Sj4usfVvOIY6f(aiylvj08tF(U9IIkPsIs2UX0ztWPKks2Ccfy8k7NqThUihp8bmCHtNWuRBimhNJkl2qxg)QimjxCalIfmJIlhp8DQ7IObBCIPJCWIiLfmvMaaVv(KrXV9IIkIgSXjMoYblIuU4T2qyoohvwSHUm(vBGL6roEybtLjaWBLJJAdH54CuzXg6Y4xjxS9u9CpyUHOHWCCoQS4grKAkhpHxjDNA9XzSjzWSUqcMrX9lBys5Y6IP8aFKPw7HnqYXGcD3m49uvlspy4rpBdiSgBaQaiylvj0qff95ZndEpv1I0dgE0Z2acRXgGkac2svkq)ef95ZndEpv1I0dgE0Z2acRXgGkac2svkWk8tOCJU9sU4gaWBLtT(GjcGwdH54CuzXnIi1u(Y4xLWRKUtT(4m2KmywxibZO4SHjLlRlMYd8rMATh2ajhdQ9WL1ft5b(itT2dBGKJv40jm16gcZX5OYIBerQP8LXVAtUe24uRp3dMfmJI7MbVNQAr6bdp6zBaH1ydqfabBPkfOFcf6B62lkQSyEkxaeSLQuGxZNp)YgMuUSyEkJwdH54CuzXnIi1u(Y4xjhp8bmSGzuC)YgMuUSUykpWhzQ1EydKCmOq3ndEpv1I0dgE0Z2acRXgGkac2svcn)0Np3m49uvlspy4rpBdiSgBaQaiylvPa9tu0Np3m49uvlspy4rpBdiSgBaQaiylvPaRWpHYn62l5IBaaVvo16dMiaAneMJZrLf3iIut5lJFLC8WhWWcMrXzdtkxwxmLh4Jm1ApSbsogu7HlRlMYd8rMATh2ajhRWPtyQ1neMJZrLf3iIut5lJFL0nEGuRpCYludrdH54CuzzBWwnDyqQcjwg3tsNKjybvdMIlhp8jR1KjqdH54CuzzBWwnDyqQcjwEz8R8K0jzcwq1GP4Baz7OeqhrKus4gcZX5OYY2GTA6WGufsS8Y4x5jPtYeSGQbtXRXXwxot0XKYeoXgNJ2qyoohvw2gSvthgKQqILxg)kpjDsMGfunykUN6wSuP9PgB704bipYfZjetYgcZX5OYY2GTA6WGufsS8Y4x5jPtYeSGQbtXP7rLJh(ikDudH54CuzzBWwnDyqQcjwEz8R8K0jzcwq1GP4asoQP8bqsciAsqdH54CuzzBWwnDyqQcjwEz8R8K0jzcwq1GP4gWTKm5y5j1As9so2XnaQHWCCoQSSnyRMomivHelVm(vEs6KmblOAWu8AqcFihoxLudH54CuzzBWwnDyqQcjwEz8R8K0jzcwq1GP48qhHkrYZkyGtj1qyoohvw2gSvthgKQqILxg)kpjDsMGfunykomaudstEImrdOHWCCoQSSnyRMomivHelVm(vEs6KmblOAWuC3iHt3PgB704bipasoQXdOHOHWCCoQSSnGWASbOZkGwJlkX0HTu5gcZX5OYY2acRXgGoRaA9Y4xTnGWJC8WneMJZrLLTbewJnaDwb06LXVAD4C0gcZX5OYY2acRXgGoRaA9Y4xfLa6gpZUHWCCoQSSnGWASbOZkGwVm(v34z2NipqSgcZX5OYY2acRXgGoRaA9Y4xDtajbeMADdH54CuzzBaH1ydqNvaTEz8RCggFmhNJEWPKfunykUBerQPSGsgKoooQcMrX9RBerQPCrjhyWdy3qyoohvw2gqyn2a0zfqRxg)kPhm8ONTbewJna1q0qyoohvw2e2Ir7ddsviXY4Es6KmblOAWu8AqcFihoxLKGzuC0DJisnLlAwVWNiJGYndEpv1IC8WhWWfabBPkHgKenF(q3nIi1uUiIuEjgak3m49uvlj8kP7uRpoJnjdM1fQaiylvj0GKO5Zh6UrePMYfLCGbpGTpFUrePMYfHXaPP(85grKAkx0rj0AimhNJklBcBXO9HbPkKy5LXVYtsNKjybvdMItWRXaKHpdyRM6ibZO4O7grKAkx0SEHprgbLBg8EQQf54HpGHlac2svcTkqr085dD3iIut5Iis5LyaOCZG3tvTKWRKUtT(4m2KmywxOcGGTuLqRcuenF(q3nIi1uUOKdm4bS95ZnIi1uUimgin1Np3iIut5IokHwdH54CuzztylgTpmivHelVm(vEs6KmblOAWuCPNEJNzFmyIxIjzbZO4O7grKAkx0SEHprgbLBg8EQQf54HpGHlac2svcnijA(8HUBerQPCreP8smauUzW7PQws4vs3PwFCgBsgmRlubqWwQsObjrZNp0DJisnLlk5adEaBF(CJisnLlcJbst95ZnIi1uUOJsO1qyoohvw2e2Ir7ddsviXYlJFLNKojtWcQgmfxoEymXCQ1hG3DmbZO4O7grKAkx0SEHprgbLBg8EQQf54HpGHlac2svcnuiA(8HUBerQPCreP8smauUzW7PQws4vs3PwFCgBsgmRlubqWwQsOHcrZNp0DJisnLlk5adEaBF(CJisnLlcJbst95ZnIi1uUOJsO1qyoohvw2e2Ir7ddsviXYlJFLNKojtWcQgmfxUy7PkTpd4(mrhEaWKYcMrXr3nIi1uUOz9cFImck3m49uvlYXdFadxaeSLQeAxdnF(q3nIi1uUiIuEjgak3m49uvlj8kP7uRpoJnjdM1fQaiylvj0UgA(8HUBerQPCrjhyWdy7ZNBerQPCrymqAQpFUrePMYfDucTgIgcZX5OYYE4ZkGwJB1JgtWmk(E4IvpAScGGTuLqdfcLBg8EQQfPhm8ONTbewJnavaeSLQuG7Hlw9OXkac2sv2qyoohvw2dFwb06LXVsMRlJEWzejygfFpCrMRlJEWzevaeSLQeAOqOCZG3tvTi9GHh9SnGWASbOcGGTuLcCpCrMRlJEWzevaeSLQSHWCCoQSSh(ScO1lJFLNkz7gthlkcNoohvWmk(E4INkz7gthlkcNoohTaiylvj0qHq5MbVNQAr6bdp6zBaH1ydqfabBPkf4E4INkz7gthlkcNoohTaiylvzdH54Cuzzp8zfqRxg)k3aaERCoQGzu89Wf3aaERCoAbqWwQsOHcHYndEpv1I0dgE0Z2acRXgGkac2svkW9Wf3aaERCoAbqWwQYgIgcZX5OYsYeCCpjDsMGLneneMJZrLfLCG5axnUidK2nMeunyk(Ey5HtNWuRfuKH9O47HlUba8w5C0cGGTuLcScO2dxS6rJvaeSLQuGva1E4INkz7gthlkcNoohTaiylvPaRak09lBys5Imxxg9GZiYNV9WfzUUm6bNrubqWwQsbwbAneOC)(dsviXY(nCwR9xn5L(H0i9hnG(rwS9uTFOp4BG5ib7)6VO)Ob0)1jZt5sdH54CuzrjhyoWvVm(vImqA3ysq1GP4mivHeF2e2IjOid7rXDZG3tvTSUykpWhzQ1EydKCScGGTuLckYWE0HWskUBg8EQQLn5syJtT(CpyUaiylvPGZACjXzKGUr3jNJgNnmPCrUy7P6HGVbMJemJI7grKAkxuYbg8a2neOC)x4b0(LJhUF5Ib2Y(ZO(5fQ)OSEH7VAIX9Ft9t6o16(LZOLgcZX5OYIsoWCGREz8RGnmfLUdWwzpajygfNty6WZzNe0iOJCEmD4eMUUYXdFKlgyd1E4INkz7gthlkcNoohTWPtyQ1neOC)qMj5(xmpL7NN(bueGKl9FtrdG6pYW4jkQ0qyoohvwuYbMdC1lJF1I5PSGzu89WLfZt5cGGTuLqRIljOJCEmD4eMAiq5(VoL1l9dj6FfKdi5y9dPqb9dOiajx6pJ6xUs6o16(hL6Vgp3gU)QJhE3VZ8Ku)EY(5PF4uk7NxO(N11bWEAYX6NN(bueGKl9dPqbLgcZX5OYIsoWCGREz8RGnmfLUdWwzpajygfNtysGOuOU9IIkWgMIs3PkW4LcGGTuLqR2TlWg0DjbDKZJPdNWudbk3p0Zeq9VjSfJ29ZGufsSS)u73uoD5QX5O9pr9F9KlHno16(VyWCPHWCCoQSOKdmh4Qxg)kpjDsMGfunykobVgdqg(mGTAQJemJIlYaPDJPcdsviXNnHTyqRcuSHWCCoQSOKdmh4Qxg)kpjDsMGfunykU0tVXZSpgmXlXKSGzuCrgiTBmvyqQcj(SjSfdAqYgcZX5OYIsoWCGREz8R8K0jzcwq1GP4YXdJjMtT(a8UJjygfxKbs7gtfgKQqIpBcBXGgkSHWCCoQSOKdmh4Qxg)kpjDsMGfunykUCX2tvAFgW9zIo8aGjLfmJIlYaPDJPcdsviXNnHTyq7AneOC)c4O(5fQ)vSfJa9NY(9KPw3)1jZtzb7pkbu)qAK(hTF3m49uv7NxiT)ObJNQ9xn5L(V(lAimhNJklk5aZbU6LXVADXuEGpYuR9Wgi5ycMrXzdtkxwmpLHsKbs7gtL9WYdNoHPw3qyoohvwuYbMdC1lJF1MCjSXPwFUhmlygfNnmPCzX8ugk3m49uvlRlMYd8rMATh2ajhRaiylvParXgcuUFbCu)8c1)k2IrG(tz)EYuR7hb6tW(Jsa1)1Fr)J2VBg8EQQ9ZlK2F0GXt1uR7VAYl9dPrAimhNJklk5aZbU6LXVAtUe24uRp3dMfmJIZgMuUixS9u9qW3aZrqjYaPDJPYEy5HtNWuRBimhNJklk5aZbU6LXVADXuEGpYuR9Wgi5ycMrXzdtkxKl2EQEi4BG5iOCZG3tvTSjxcBCQ1N7bZfabBPkfik2qyoohvwuYbMdC1lJFLNkz7gthlkcNoohvWmk(E4INkz7gthlkcNoohTaiylvj0GKneMJZrLfLCG5ax9Y4xz1JgtWmk(E4IvpAScGGTuLq7AneMJZrLfLCG5ax9Y4xjZ1Lrp4mIemJIVhUiZ1Lrp4mIkac2svcTR1qyoohvwuYbMdC1lJFLBaaVvohvWmk(E4IBaaVvohTaiylvj0Uwdbk3VFKIaKCPFifkOFlIjq)8c1)Sskb6pJ6FBaH1ydqNvaT2F1XdV73zEsQFpz)80pCkL9B9dPqb9dOiajxAimhNJklk5aZbU6LXVc2Wuu6oaBL9aKGzuCoHjbIsH62lkQaBykkDNQaJxkac2svcTkUU1UDb2GUljOJCEmD4eMAiq5(HmdJ7FBaH1ydqNvaT2Fg1pKEXuEG7hj1ApSbsow)PSFNhaqkJJ1pNoHPw3qyoohvwuYbMdC1lJFLZW4J54C0doLSGQbtX3gqyn2a0zfqRckzq644OkygfFpCzDXuEGpYuR9Wgi5yfoDctTUHaL7xaLtCEDM630y9p8cb6xYg3pdsviXY(ZO(H0lMYdC)iPw7HnqYX6pL9ZPtyQ1neMJZrLfLCG5ax9Y4x5mm(yooh9GtjlOAWuCjB8HbPkKyPGsgKoooQcMrX3dxwxmLh4Jm1ApSbsowHtNWuRBiq5(ryZjSFiLHPO01pkay8s)80FLfS)b0pGIaKCP)QlK2FnXCQ19JNQ9JEUjdJJ1pEgHPw3F0a6363zyNh2yA3V6bFtab7)2J7)Af)u2pGGTutTU)u2pVq9diPhM7FI6NjjNAD)vtEPF)RaLIwdH54CuzrjhyoWvVm(vWgMIs3byRShGemJIZjmjqukuOF7ffvGnmfLUtvGXlfjBoHqRY(8D7ffvGnmfLUtvGXlfabBPkH21k(jAneOC)(H9o5Cud3pKYp2VCL0TS)QlK2pbDmW6xUyGTSFdq9BISeB3yQFt39tjVqG(H0lMYdC)iPw7HnqYX6pL9ZPtyQ1c2)a6NxO(JY6fU)u2pP7uRlneMJZrLfLCG5ax9Y4xbBykkDhGTYEasWmko67HlRlMYd8rMATh2ajhRWPtyQ1(8XjmD45StcAUzW7PQwwxmLh4Jm1ApSbsowbqWwQs0Gc9BVOOcSHPO0DQcmEPizZjeAv2Np54HpYfdSfiQO1qGY97h27KZrnC)xpWsTFKXd3VZKC)vxiTFins)PSFoDctTUHWCCoQSOKdmh4Qxg)QnWs9ihpSGzu89WL1ft5b(itT2dBGKJv40jm16gcuUFiFQ2pKO)vqoGKJ1)E4(bueGKl9xDH0(bueGKl2nMkneMJZrLfLCG5ax9Y4xz1JgtWmkoGIaKCXUXudH54CuzrjhyoWvVm(vEQKTBmDSOiC64CubZO4akcqYf7gtneMJZrLfLCG5ax9Y4x5gaWBLZrfmJIdOiajxSBm1qyoohvwuYbMdC1lJFLmxxg9GZisWmkoBys5Imxxg9GZickafbi5IDJPgcuUFONysU4awe3pp9dBPYwQ9lGCWgNyQFKblIuU0qyoohvwuYbMdC1lJFveMKloGfXcMrXLJh(o1Dr0GnoX0royrKYc6m1r4tgf)2lkQiAWgNy6ihSis5ZIhSPtUlERneOC)q(ufsScYbKCS(xmpL7hqrasUuAimhNJklk5aZbU6LXVAX8uwWmk(E4YI5PCbqWwQsOv5gcuUFbunvMaaVvoVXu)xps)Uftvc3Fg1FvQ)fte1pVq9F9x0)TxuuPHWCCoQSOKdmh4Qxg)QnWs9ihpSGzu8BVOOYMCjSXPwFUhmx8wBimhNJklk5aZbU6LXVAdSupYXdlygfNnmPCrUy7P6HGVbMJGAt3Errf5ITNQhc(gyoQaiylvj0QSpFB62lkQixS9u9qW3aZrfjBoHqRYcMktaG3kFYO4B62lkQixS9u9qW3aZrfjBoHcmELHAt3Errf5ITNQhc(gyoQaiylvPaRCdH54CuzrjhyoWvVm(vBGL6roEybtLjaWBLJJAdH54CuzrjhyoWvVm(vYfBpvp3dMBiAimhNJklsk(I5PCdH54Cuzrsxg)QnWs9ihpSGPYea4TYNA8CB44OkyQmbaER8jJIVPBVOOICX2t1dbFdmhvKS5ekW4vUHWCCoQSiPlJFLCX2t1Z9G5gIgcZX5OYIKn(WGufsSmUNKojtWcQgmfNxOtucK8rM1jUHWCCoQSizJpmivHelVm(vEs6KmblOAWuCPZaYZeDIagta1WhjdYiQHWCCoQSizJpmivHelVm(vEs6KmblOAWu8uLoGhB3y6Gs8mL9GpBsu6OgcZX5OYIKn(WGufsS8Y4x5jPtYeSGQbtXtvYaphpa5zNIsLo3eg3qyoohvwKSXhgKQqILxg)kpjDsMGfunyk(iIar4PAQ1htty74SAQHWCCoQSizJpmivHelVm(vEs6KmblOAWu8TbecpJE2Kt4z1JbK0rQJAimhNJkls24ddsviXYlJFLNKojtWcQgmfh2C2nGoYfI4dSNmDneMJZrLfjB8HbPkKy5LXVYtsNKjybvdMIhHny6mrNBJzm1qyoohvwKSXhgKQqILxg)kpjDsMGfunykEvtiPeqEIaJUBimhNJkls24ddsviXYlJFLNKojtWcQgmfNTBmXNj6Sj5QLGgcZX5OYIKn(WGufsS8Y4x5jPtYeSGQbtXLPg5HpMCnbMYYZTTRPZeDIiW4sowdH54CuzrYgFyqQcjwEz8R8K0jzcwq1GP4UrcNUJjxtGPS8CB7A6mrNicmUKJ1qyoohvwKSXhgKQqILxg)kpjDsMGfunykUm1ip8PgB704bip32UMot0jIaJl5yneMJZrLfjB8HbPkKy5LXVYtsNKjybvdMI7gjC6o1yBNgpa552210zIoreyCjhRHWCCoQSizJpmivHelVm(vEs6KmblOAWu85MWPu4zIo8cDen5UHWCCoQSizJpmivHelVm(vEs6KmblOAWu8LbONj6iYWdOHWCCoQSizJpmivHelVm(vEs6KmblOAWuC4zuCYNvqkHBimhNJkls24ddsviXYlJFLNKojtWcQgmfpkR9a0cz7ZeD4f6OwnoYaneMJZrLfjB8HbPkKy5LXV6gpZ(e5bI1qyoohvwKSXhgKQqILxg)QOeq34z2neMJZrLfjB8HbPkKy5LXV6Mascim16gIgcuUFua1)EuX4(LERRdG7VVoC)MS)kb97h7p1(HCptW(Lt)cyXer97gvebyA3pVKY(5PFdK8cmXPR0qyoohvwyqQcj(ixXjFClKtyCrgiTBmjOAWuC5k5sdFiuIxUUsBbfzypko6OJ61LqjE56kTle8Amaz4Za2QPocTlrh1RlHs8Y1vAxsv6aESDJPdkXZu2d(SjrPJq7s0r96sOeVCDL2f54HXeZPwFaE3Xq7s0r96sOeVCDL2fPNEJNzFmyIxIjz0qloQneMJZrLfgKQqIpYvCYh3c5eEz8RezG0UXKGQbtXzqQcj(mkjOid7rXrNbPkK4cQLftEwbJdkgKQqIlOwwm5XndEpvv0AimhNJklmivHeFKR4KpUfYj8Y4xjYaPDJjbvdMIZGufs8HRockYWEuC0zqQcjUurzXKNvW4GIbPkK4sfLftECZG3tvfTgcZX5OYcdsviXh5ko5JBHCcVm(vImqA3ysq1GP4Bd2QPddsviXckYWEuC09l6mivHexqTSyYZkyCqXGufsCb1YIjpUzW7PQIgA(8HUFrNbPkK4sfLftEwbJdkgKQqIlvuwm5XndEpvv0qZNpcL4LRR0UuJJTUCMOJjLjCInohTHWCCoQSWGufs8rUIt(4wiNWlJFLidK2nMeunykodsviXh5kozbfzypko6ImqA3yQWGufs8zuckrgiTBmv2gSvthgKQqIrZNp0fzG0UXuHbPkK4dxDGsKbs7gtLTbB10HbPkKy085dDuVUImqA3yQWGufs8zucTlrh1RRidK2nMkYvYLg(qOeVCDL2OfhvF(qh1RRidK2nMkmivHeF4QdAxIoQxxrgiTBmvKRKln8HqjE56kTrloQbereqMJgeVcuSIkqXkJI(zaPQb0uRLbeuGFWpkUaw8RJcq)97)c1FcVoaU)Ob0VymivHeFKR4KpUfYjuS(bekXlb0UF5at9BE8aBmT73TyAnjlneqEQu)via9dzJkIamT7xmgKQqIlOwQKy9Zt)IXGufsCHrTujX6h9kGo0kneqEQu)vwa6hYgvebyA3VymivHexQOujX6NN(fJbPkK4cxrPsI1p6vaDOvAiG8uP(VMa0pKnQicW0UFXyqQcjUGAPsI1pp9lgdsviXfg1sLeRF0Ra6qR0qa5Ps9FnbOFiBureGPD)IXGufsCPIsLeRFE6xmgKQqIlCfLkjw)Oxb0HwPHOHaf4h8JIlGf)6Oa0F)(Vq9NWRdG7pAa9l22GTA6WGufsSuS(bekXlb0UF5at9BE8aBmT73TyAnjlneqEQu)qVcq)cOQ0BDDamT73tsNKj4(nhNJ2Vac9ZdDeQejpRGboL01bqp2pPmiw)7uA3yAxAiG8uP(rfffG(fqvP366ayA3VNKojtW9BoohTFbe6hgaQbPjprMObCDa0J9tkdI1)oL2nM2LgIgcuGFWpkUaw8RJcq)97)c1FcVoaU)Ob0Vys24ddsviXsX6hqOeVeq7(Ldm1V5XdSX0UF3IP1KS0qa5Ps9JQFka9lGQsV11bW0UFpjDsMG73CCoA)ci0)Ct4uk8mrhEHoIMCFDa0J9tkdI1)oL2nM2LgcipvQFurHcq)cOQ0BDDamT73tsNKj4(nhNJ2Vac9hL1EaAHS9zIo8cDuRghzGRdGESFszqS(3P0UX0U0q0qGc8d(rXfWIFDua6VF)xO(t41bW9hnG(fZnIi1uwS(bekXlb0UF5at9BE8aBmT73TyAnjlneqEQu)Oka9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQFufG(HSrfraM29lMB0TxYLkjw)80VyUr3EjxQuHu7gtBX6hDuHo0kneqEQu)via9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQ)kla9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQ)Rja9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQ)Rja9dzJkIamT7xm3OBVKlvsS(5PFXCJU9sUuPcP2nM2I1p6OcDOvAiG8uP(9tbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0q0qGc8d(rXfWIFDua6VF)xO(t41bW9hnG(fBtrMhMfRFaHs8saT7xoWu)MhpWgt7(DlMwtYsdbKNk1VFka9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9BC)qFq)qE)OJk0HwPHaYtL63pfG(HSrfraM29lgWtPObutLkjw)80VyapLIgqnvQuHu7gtBX6hDuHo0kneqEQu)OqbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRFJ7h6d6hY7hDuHo0kneqEQu)qVcq)q2OIiat7(fJbPkK4cQLkjw)80VymivHexyulvsS(r)AqhALgcipvQFOxbOFiBureGPD)IXGufsCPIsLeRFE6xmgKQqIlCfLkjw)OFnOdTsdbKNk1pQOka9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JEfqhALgcipvQFuRqa6hYgvebyA3VySHjLlvsS(5PFXydtkxQuHu7gtBX6hDuHo0kneqEQu)OEnbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0qa5Ps9JQFka9dzJkIamT7xmgKQqIl2TR4MbVNQQy9Zt)I5MbVNQAXUDI1p6OcDOvAiG8uP(rfska9dzJkIamT7xmgKQqIl2TR4MbVNQQy9Zt)I5MbVNQAXUDI1p6OcDOvAiG8uP(rfLka9dzJkIamT7xmGNsrdOMkvsS(5PFXaEkfnGAQuPcP2nM2I1p6OcDOvAiG8uP(rfLka9dzJkIamT7xmgKQqIl2TR4MbVNQQy9Zt)I5MbVNQAXUDI1p6OcDOvAiG8uP(rffka9dzJkIamT7xmGNsrdOMkvsS(5PFXaEkfnGAQuPcP2nM2I1p6OcDOvAiG8uP(rffka9dzJkIamT7xmgKQqIl2TR4MbVNQQy9Zt)I5MbVNQAXUDI1p6OcDOvAiG8uP(ROYcq)q2OIiat7(fJnmPCPsI1pp9lgBys5sLkKA3yAlw)OJk0HwPHaYtL6VIRja9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQ)kGEfG(HSrfraM29lgBys5sLeRFE6xm2WKYLkvi1UX0wS(rVcOdTsdbKNk1FLrva6hYgvebyA3VySHjLlvsS(5PFXydtkxQuHu7gtBX6h9kGo0kneqEQu)vUcbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0qa5Ps9x5kla9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQ)kdjfG(HSrfraM29lgWtPObutLkjw)80VyapLIgqnvQuHu7gtBX6hDuHo0kneqEQu)vgLka9dzJkIamT7xmGNsrdOMkvsS(5PFXaEkfnGAQuPcP2nM2I1p6OcDOvAiG8uP(Rmkua6hYgvebyA3VyapLIgqnvQKy9Zt)Ib8ukAa1uPsfsTBmTfRF0rf6qR0qa5Ps9xzOxbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0qa5Ps9xzOxbOFiBureGPD)Ib8ukAa1uPsI1pp9lgWtPObutLkvi1UX0wS(rhvOdTsdbKNk1)1qrbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRFJ7h6d6hY7hDuHo0kneqEQu)xdska9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JEfqhALgcipvQ)RHsfG(HSrfraM29lMC8W3PUlvsS(5PFXKJh(o1DPsfsTBmTfRFJ7h6d6hY7hDuHo0kneneOa)GFuCbS4xhfG(73)fQ)eEDaC)rdOFXSHeRFaHs8saT7xoWu)MhpWgt7(DlMwtYsdbKNk1FLfG(HSrfraM29lgBys5sLeRFE6xm2WKYLkvi1UX0wS(rVcOdTsdbKNk1)1eG(HSrfraM29lgBys5sLeRFE6xm2WKYLkvi1UX0wS(rhvOdTsdbKNk1VFka9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9JoQqhALgcipvQFuRqa6hYgvebyA3VySHjLlvsS(5PFXydtkxQuHu7gtBX6h9kdDOvAiG8uP(rTYcq)q2OIiat7(fJnmPCPsI1pp9lgBys5sLkKA3yAlw)OJk0HwPHaYtL6hvuOa0pKnQicW0UFXydtkxQKy9Zt)IXgMuUuPcP2nM2I1VX9d9b9d59JoQqhALgcipvQ)kqrbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRFJ7h6d6hY7hDuHo0kneqEQu)vGQa0pKnQicW0UFXydtkxQKy9Zt)IXgMuUuPcP2nM2I1VX9d9b9d59JoQqhALgcipvQ)kGKcq)q2OIiat7(ftoE47u3Lkjw)80VyYXdFN6UuPcP2nM2I1VX9d9b9d59JoQqhALgIgcuGFWpkUaw8RJcq)97)c1FcVoaU)Ob0Vyk5aZbUQy9diuIxcOD)YbM6384b2yA3VBX0AswAiG8uP(rva6hYgvebyA3VySHjLlvsS(5PFXydtkxQuHu7gtBX6hDuHo0kneqEQu)via9dzJkIamT7xm2WKYLkjw)80VySHjLlvQqQDJPTy9BC)qFq)qE)OJk0HwPHaYtL6hvuua6hYgvebyA3VySHjLlvsS(5PFXydtkxQuHu7gtBX6hDuHo0kneqEQu)OIQa0pKnQicW0UFXydtkxQKy9Zt)IXgMuUuPcP2nM2I1p6OcDOvAiG8uP(rTcbOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0qa5Ps9JALfG(HSrfraM29lgBys5sLeRFE6xm2WKYLkvi1UX0wS(rhvOdTsdbKNk1FfOubOFiBureGPD)IXgMuUujX6NN(fJnmPCPsfsTBmTfRF0rf6qR0qa5Ps9xbkua6hYgvebyA3VyYXdFN6UujX6NN(ftoE47u3Lkvi1UX0wS(nUFOpOFiVF0rf6qR0qa5Ps9xzufG(HSrfraM29lgBys5sLeRFE6xm2WKYLkvi1UX0wS(rhvOdTsdrdHagEDamT7h1k3V54C0(XPKLLgIacoLSm4FarYgFyqQcjwg8pioQb)diKA3yAhUiGOgmfq4f6eLajFKzDIdiMJZrdi8cDIsGKpYSoXboiEfb)diKA3yAhUiGOgmfqKodipt0jcymbudFKmiJOaI54C0aI0za5zIoraJjGA4JKbzef4G4vo4FaHu7gt7Wfbe1GPasQshWJTBmDqjEMYEWNnjkDuaXCCoAajvPd4X2nMoOeptzp4ZMeLokWbXVwW)acP2nM2HlciQbtbKuLmWZXdqE2POuPZnHXbeZX5ObKuLmWZXdqE2POuPZnHXboiUFg8pGqQDJPD4IaIAWuazerGi8un16JPjSDCwnfqmhNJgqgreicpvtT(yAcBhNvtboioKm4FaHu7gt7Wfbe1GPaY2acHNrpBYj8S6Xas6i1rbeZX5ObKTbecpJE2Kt4z1JbK0rQJcCqCuAW)acP2nM2HlciQbtbeyZz3a6ixiIpWEY0fqmhNJgqGnNDdOJCHi(a7jtxGdIJcd(hqi1UX0oCrarnykGeHny6mrNBJzmfqmhNJgqIWgmDMOZTXmMcCqCO3G)besTBmTdxequdMcivnHKsa5jcm6oGyoohnGu1eskbKNiWO7ahehvum4FaHu7gt7Wfbe1GPacB3yIpt0ztYvlbbeZX5Obe2UXeFMOZMKRwccCqCurn4FaHu7gt7Wfbe1GPaIm1ip8XKRjWuwEUTDnDMOtebgxYXciMJZrdiYuJ8WhtUMatz552210zIoreyCjhlWbXrTIG)besTBmTdxequdMciUrcNUJjxtGPS8CB7A6mrNicmUKJfqmhNJgqCJeoDhtUMatz552210zIoreyCjhlWbXrTYb)diKA3yAhUiGOgmfqKPg5Hp1yBNgpa552210zIoreyCjhlGyoohnGitnYdFQX2onEaYZTTRPZeDIiW4sowGdIJ61c(hqi1UX0oCrarnykG4gjC6o1yBNgpa552210zIoreyCjhlGyoohnG4gjC6o1yBNgpa552210zIoreyCjhlWbXr1pd(hqi1UX0oCrarnykGm3eoLcpt0HxOJOj3boioQqYG)besTBmTdxequdMcildqpt0rKHhqaXCCoAazza6zIoIm8acCqCurPb)diKA3yAhUiGOgmfqGNrXjFwbPeoGyoohnGapJIt(ScsjCGdIJkkm4FaHu7gt7Wfbe1GPasuw7bOfY2Nj6Wl0rTACKbcCqCuHEd(hqmhNJgqUXZSprEGybesTBmTdxe4G4vGIb)diMJZrdirjGUXZSdiKA3yAhUiWbXRa1G)beZX5ObKBcijGWuRdiKA3yAhUiWboGWGufs8rUIt(4wiNWG)bXrn4FaHu7gt7WfbKznGijoGyoohnGiYaPDJPaIid7rbe07h9(rT)RB)ekXlxxPDHGxJbidFgWwn1r9Jw)x2p69JA)x3(juIxUUs7sQshWJTBmDqjEMYEWNnjkDu)O1)L9JE)O2)1TFcL4LRR0UihpmMyo16dW7ow)O1)L9JE)O2)1TFcL4LRR0Ui90B8m7Jbt8smj3pA9Jw)X7h1aYMKoqUY5Obeua1)EuX4(LERRdG7pGiYah1GPaICLCPHpekXlxxPDGdIxrW)acP2nM2HlciZAarsCaXCCoAarKbs7gtberg2JciO3pdsviXfg1YIjpRGX1pu9ZGufsCHrTSyYJBg8EQQ9JwarKboQbtbegKQqIpJsboiELd(hqi1UX0oCrazwdisIdiMJZrdiImqA3ykGiYWEuab9(zqQcjUWvuwm5zfmU(HQFgKQqIlCfLftECZG3tvTF0ciImWrnykGWGufs8HRoboi(1c(hqi1UX0oCrazwdisIdiMJZrdiImqA3ykGiYWEuab9(9B)O3pdsviXfg1YIjpRGX1pu9ZGufsCHrTSyYJBg8EQQ9Jw)O1VpF9JE)(TF07NbPkK4cxrzXKNvW46hQ(zqQcjUWvuwm5XndEpv1(rRF063NV(juIxUUs7sno26YzIoMuMWj24C0aIidCudMciBd2QPddsviXboiUFg8pGqQDJPD4IaYSgqKehqmhNJgqezG0UXuarKH9Oac69lYaPDJPcdsviXNrP(HQFrgiTBmv2gSvthgKQqI7hT(95RF07xKbs7gtfgKQqIpC1PFO6xKbs7gtLTbB10HbPkK4(rRFF(6h9(rT)RB)ImqA3yQWGufs8zuQF06)Y(rVFu7)62VidK2nMkYvYLg(qOeVCDL29Jw)X7h1(95RF07h1(VU9lYaPDJPcdsviXhU60pA9Fz)O3pQ9FD7xKbs7gtf5k5sdFiuIxUUs7(rR)49JAarKboQbtbegKQqIpYvCYboWbKTbB10HbPkKyzW)G4Og8pGqQDJPD4IaIAWuaroE4twRjtGaI54C0aIC8WNSwtMaboiEfb)diKA3yAhUiGOgmfq2aY2rjGoIiPKWbeZX5ObKnGSDucOJiskjCGdIx5G)besTBmTdxequdMci14yRlNj6yszcNyJZrdiMJZrdi14yRlNj6yszcNyJZrdCq8Rf8pGqQDJPD4IaIAWuaXtDlwQ0(uJTDA8aKh5I5eIjzaXCCoAaXtDlwQ0(uJTDA8aKh5I5eIjzGdI7Nb)diKA3yAhUiGOgmfqO7rLJh(ikDuaXCCoAaHUhvoE4JO0rboioKm4FaHu7gt7Wfbe1GPacGKJAkFaKKaIMeeqmhNJgqaKCut5dGKeq0KGahehLg8pGqQDJPD4IaIAWuaXaULKjhlpPwtQxYXoUbqbeZX5Obed4wsMCS8KAnPEjh74gaf4G4OWG)besTBmTdxequdMci1Ge(qoCUkPaI54C0asniHpKdNRskWbXHEd(hqi1UX0oCrarnykGWdDeQejpRGboLuGdIJkkg8pGqQDJPD4IaIAWuabgaQbPjprMObe4G4OIAW)acP2nM2HlciQbtbe3iHt3PgB704bipasoQXdiGyoohnG4gjC6o1yBNgpa5bqYrnEaboWbKnHTy0(WGufsSm4FqCud(hqi1UX0oCraXCCoAaPgKWhYHZvjfqCGKjqAbe073nIi1uUOz9cFImQFO63ndEpv1IC8WhWWfabBPk7hA9dj7hT(95RF073nIi1uUiIuEjgOFO63ndEpv1scVs6o16JZytYGzDHkac2sv2p06hs2pA97Zx)O3VBerQPCrjhyWdy3VpF97grKAkxegdKM2VpF97grKAkx0rP(rlGOgmfqQbj8HC4CvsboiEfb)diKA3yAhUiGyoohnGqWRXaKHpdyRM6OaIdKmbslGGE)UrePMYfnRx4tKr9dv)UzW7PQwKJh(agUaiylvz)qR)kqX(rRFF(6h9(DJisnLlIiLxIb6hQ(DZG3tvTKWRKUtT(4m2KmywxOcGGTuL9dT(Raf7hT(95RF073nIi1uUOKdm4bS73NV(DJisnLlcJbst73NV(DJisnLl6Ou)OfqudMcie8Amaz4Za2QPokWbXRCW)acP2nM2HlciMJZrdisp9gpZ(yWeVetYbehizcKwab9(DJisnLlAwVWNiJ6hQ(DZG3tvTihp8bmCbqWwQY(Hw)qY(rRFF(6h9(DJisnLlIiLxIb6hQ(DZG3tvTKWRKUtT(4m2KmywxOcGGTuL9dT(HK9Jw)(81p697grKAkxuYbg8a297Zx)UrePMYfHXaPP97Zx)UrePMYfDuQF0ciQbtbePNEJNzFmyIxIj5ahe)Ab)diKA3yAhUiGyoohnGihpmMyo16dW7owaXbsMaPfqqVF3iIut5IM1l8jYO(HQF3m49uvlYXdFadxaeSLQSFO1pkSF063NV(rVF3iIut5Iis5LyG(HQF3m49uvlj8kP7uRpoJnjdM1fQaiylvz)qRFuy)O1VpF9JE)UrePMYfLCGbpGD)(81VBerQPCrymqAA)(81VBerQPCrhL6hTaIAWuaroEymXCQ1hG3DSahe3pd(hqi1UX0oCraXCCoAarUy7PkTpd4(mrhEaWKYbehizcKwab9(DJisnLlAwVWNiJ6hQ(DZG3tvTihp8bmCbqWwQY(Hw)xRF063NV(rVF3iIut5Iis5LyG(HQF3m49uvlj8kP7uRpoJnjdM1fQaiylvz)qR)R1pA97Zx)O3VBerQPCrjhyWdy3VpF97grKAkxegdKM2VpF97grKAkx0rP(rlGOgmfqKl2EQs7ZaUpt0HhamPCGdCazBaH1ydqNvaTg8pioQb)diMJZrdiIsmDylvoGqQDJPD4IaheVIG)beZX5ObKTbeEKJhoGqQDJPD4IaheVYb)diMJZrdiRdNJgqi1UX0oCrGdIFTG)beZX5ObKOeq34z2besTBmTdxe4G4(zW)aI54C0aYnEM9jYdelGqQDJPD4Iahehsg8pGyoohnGCtajbeMADaHu7gt7Wfboiokn4FaHu7gt7WfbehizcKwaXV97grKAkxuYbg8a2bejdshheh1aI54C0aIZW4J54C0doLCabNs(OgmfqCJisnLdCqCuyW)aI54C0aI0dgE0Z2acRXgGciKA3yAhUiWboG4grKAkh8pioQb)diKA3yAhUiG4ajtG0ci(TF2WKYL1ft5b(itT2dBGKJvi1UX0UFO6h9(DZG3tvTi9GHh9SnGWASbOcGGTuL9dT(rff73NV(DZG3tvTi9GHh9SnGWASbOcGGTuL9lW(9tuSFF(63ndEpv1I0dgE0Z2acRXgGkac2sv2Va7Vc)SFO63n62l5IBaaVvo16dMiqHu7gt7(rlGyoohnGKWRKUtT(4m2KmywxOaheVIG)besTBmTdxeqCGKjqAbe2WKYL1ft5b(itT2dBGKJvi1UX0UFO6FpCzDXuEGpYuR9Wgi5yfoDctToGyoohnGKWRKUtT(4m2KmywxOaheVYb)diKA3yAhUiG4ajtG0ciUzW7PQwKEWWJE2gqyn2aubqWwQY(fy)(z)q1p69VPBVOOYI5PCbqWwQY(fy)xRFF(63V9ZgMuUSyEkxi1UX0UF0ciMJZrdiBYLWgNA95EWCGdIFTG)besTBmTdxeqCGKjqAbe)2pBys5Y6IP8aFKPw7HnqYXkKA3yA3pu9JE)UzW7PQwKEWWJE2gqyn2aubqWwQY(Hw)(z)(81VBg8EQQfPhm8ONTbewJnavaeSLQSFb2VFII97Zx)UzW7PQwKEWWJE2gqyn2aubqWwQY(fy)v4N9dv)Ur3EjxCda4TYPwFWebkKA3yA3pAbeZX5Obe54HpGHdCqC)m4FaHu7gt7WfbehizcKwaHnmPCzDXuEGpYuR9Wgi5yfsTBmT7hQ(3dxwxmLh4Jm1ApSbsowHtNWuRdiMJZrdiYXdFadh4G4qYG)beZX5ObePB8aPwF4KxOacP2nM2HlcCGdi7HpRaAn4FqCud(hqi1UX0oCraXbsMaPfq2dxS6rJvaeSLQSFO1pkSFO63ndEpv1I0dgE0Z2acRXgGkac2sv2Va7FpCXQhnwbqWwQYaI54C0aIvpASaheVIG)besTBmTdxeqCGKjqAbK9WfzUUm6bNrubqWwQY(Hw)OW(HQF3m49uvlspy4rpBdiSgBaQaiylvz)cS)9WfzUUm6bNrubqWwQYaI54C0aImxxg9GZikWbXRCW)acP2nM2HlcioqYeiTaYE4INkz7gthlkcNoohTaiylvz)qRFuy)q1VBg8EQQfPhm8ONTbewJnavaeSLQSFb2)E4INkz7gthlkcNoohTaiylvzaXCCoAaXtLSDJPJffHthNJg4G4xl4FaHu7gt7WfbehizcKwazpCXnaG3kNJwaeSLQSFO1pkSFO63ndEpv1I0dgE0Z2acRXgGkac2sv2Va7FpCXnaG3kNJwaeSLQmGyoohnG4gaWBLZrdCGdiBkY8WCW)G4Og8pGyoohnGixjm(GhNWacP2nM2HlcCq8kc(hqmhNJgq2KOXdCGT60fqi1UX0oCrGdIx5G)besTBmTdxeqCGKjqAbeZXPi6qkbNKSFb2FLdisgKooioQbeZX5ObeNHXhZX5OhCk5acoL8rnykGydf4G4xl4FaHu7gt7WfbehizcKwa52lkQ4mSbN84jpoajDKUNI3AaXCCoAab2Wuu6oaBL9auGdI7Nb)diKA3yAhUiGSjPdKRCoAabYmmUFjTAaJP(nhNJ2poLC)rdOFXjhyWdy3pKcf0FQ9J4FPFiZdaiLXX6FuCS(NvoHZRZ0U)Ob0VNK6VAYl9dPrkbeZX5ObeGNEmhNJEWPKdisgKooioQbehizcKwaXnIi1uUOKdm4bS7hQ(bEkfnGAQaBykkDNQaJxkKA3yA3pu9Boofrhsj4KK9hVFu7hQ(zdtkxwxmLh4Jm1ApSbsowHu7gt7acoL8rnykGOKdmh4QboioKm4FaHu7gt7WfbKnjDGCLZrdi(bhNJ2poLSS)Ob0pdsviX9FtlMOCaL(ryJL9BaQFPjI29hnG(VPObq9JmE4(9JdFLagEL0DQ19dzgBsgmRl0vq6ft5bUFKuR9Wgi5yc2)WleOAkP(hTF3m49uvlbeZX5ObeNHXhZX5OhCk5acoL8rnykGWGufs8rUIt(4wiNWahehLg8pGqQDJPD4IaI54C0aIZW4J54C0doLCabNs(Ogmfq2e2Ir7ddsviXYahehfg8pGqQDJPD4IaIdKmbslGGE)7HlYXdFadx40jm16(95R)9WLeEL0DQ1hNXMKbZ6cD2dx40jm16(95R)9WL1ft5b(itT2dBGKJv40jm16(rRFO6xoE4JCXa7(fy)vUFF(6FpCruIPdBPYfoDctTUFF(6NnmPCrovp8cDKeTLfsTBmTdisgKooioQbeZX5ObeNHXhZX5OhCk5acoL8rnykGizJpmivHeldCqCO3G)besTBmTdxeqCGKjqAbe3iIut5IM1l8jYO(HQF073V9lYaPDJPcdsviXh5ko5(95RF3m49uvlYXdFadxaeSLQSFb2FfOy)(81p69lYaPDJPcdsviXNrP(HQF3m49uvlYXdFadxaeSLQSFO1pdsviXfg1IBg8EQQfabBPk7hT(95RF07xKbs7gtfgKQqIpC1PFO63ndEpv1IC8WhWWfabBPk7hA9ZGufsCHRO4MbVNQAbqWwQY(rRF063NV(DJisnLlIiLxIb6hQ(rVF)2VidK2nMkmivHeFKR4K73NV(DZG3tvTKWRKUtT(4m2KmywxOcGGTuL9lW(Raf73NV(rVFrgiTBmvyqQcj(mk1pu97MbVNQAjHxjDNA9XzSjzWSUqfabBPk7hA9ZGufsCHrT4MbVNQAbqWwQY(rRFF(6h9(fzG0UXuHbPkK4dxD6hQ(DZG3tvTKWRKUtT(4m2KmywxOcGGTuL9dT(zqQcjUWvuCZG3tvTaiylvz)O1pA97Zx)O3VBerQPCrjhyWdy3VpF97grKAkxegdKM2VpF97grKAkx0rP(rRFO6h9(9B)ImqA3yQWGufs8rUItUFF(63ndEpv1Y6IP8aFKPw7HnqYXkac2sv2Va7VcuSFF(6h9(fzG0UXuHbPkK4ZOu)q1VBg8EQQL1ft5b(itT2dBGKJvaeSLQSFO1pdsviXfg1IBg8EQQfabBPk7hT(95RF07xKbs7gtfgKQqIpC1PFO63ndEpv1Y6IP8aFKPw7HnqYXkac2sv2p06NbPkK4cxrXndEpv1cGGTuL9Jw)O1VpF973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(HQF073V9lYaPDJPcdsviXh5ko5(95RF3m49uvlspy4rpBdiSgBaQaiylvz)cS)kqX(95RF07xKbs7gtfgKQqIpJs9dv)UzW7PQwKEWWJE2gqyn2aubqWwQY(Hw)mivHexyulUzW7PQwaeSLQSF063NV(rVFrgiTBmvyqQcj(WvN(HQF3m49uvlspy4rpBdiSgBaQaiylvz)qRFgKQqIlCff3m49uvlac2sv2pA9JwaXCCoAaXzy8XCCo6bNsoGGtjFudMciBd2QPddsviXYahehvum4FaHu7gt7WfbeZX5ObeydtrP7aSv2dqbKnjDGCLZrdix4b0(LJhUF5Ib2Y(ZO(JY6fU)u2VHHhj3)iIabehizcKwa5EKY(HQ)OSEHpac2sv2p06NGoY5X0HtyQ)RB)YXdFKlgy3pu9VhU4Ps2UX0XIIWPJZrlC6eMADGdIJkQb)diKA3yAhUiGSjPdKRCoAarah1VBerQPC)7HVcsVykpW9JKATh2ajhR)u2pWt1uRfSFpj1)1BaH1ydq9Zt)e0XKU7NxO(DEaaPC)sIdiMJZrdiodJpMJZrp4uYbehizcKwab9(DJisnLlIiLxIb6hQ(3dxs4vs3PwFCgBsgmRl0zpCHtNWuR7hQ(DZG3tvTi9GHh9SnGWASbOcGGTuL9dT(ROFO6h9(3dxwxmLh4Jm1ApSbsowbqWwQY(fy)v0VpF973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(rRF063NV(rVF3iIut5IM1l8jYO(HQ)9Wf54HpGHlC6eMAD)q1VBg8EQQfPhm8ONTbewJnavaeSLQSFO1Ff9dv)O3)E4Y6IP8aFKPw7HnqYXkac2sv2Va7VI(95RF)2pBys5Y6IP8aFKPw7HnqYXkKA3yA3pA9Jw)(81p69JE)UrePMYfLCGbpGD)(81VBerQPCrymqAA)(81VBerQPCrhL6hT(HQ)9WL1ft5b(itT2dBGKJv40jm16(HQ)9WL1ft5b(itT2dBGKJvaeSLQSFO1Ff9JwabNs(Ogmfq2gqyn2a0zfqRboioQve8pGqQDJPD4IaYMKoqUY5Obe)ifbi5s)7HL9tgahR)mQ)6j16(tLN(T(Llgy3VCL0DQ19VUyskGyoohnG4mm(yooh9GtjhqCGKjqAbe073nIi1uUOz9cFImQFO63V9VhUihp8bmCHtNWuR7hQ(DZG3tvTihp8bmCbqWwQY(Hw)xRF063NV(rVF3iIut5Iis5LyG(HQF)2)E4scVs6o16JZytYGzDHo7HlC6eMAD)q1VBg8EQQLeEL0DQ1hNXMKbZ6cvaeSLQSFO1)16hT(95RF07h9(DJisnLlk5adEa7(95RF3iIut5IWyG00(95RF3iIut5Iok1pA9dv)SHjLlRlMYd8rMATh2ajhRqQDJPD)q1VF7FpCzDXuEGpYuR9Wgi5yfoDctTUFO63ndEpv1Y6IP8aFKPw7HnqYXkac2sv2p06)A9JwabNs(Ogmfq2dFwb0AGdIJALd(hqi1UX0oCraXCCoAazBaHh54HdiBs6a5kNJgqeWr9dPxmLh4(rsT2dBGKJ1Fk7NtNWuRfS)K7pL9lTiQFE63ts9F9gqy)iJhoG4ajtG0ci7HlRlMYd8rMATh2ajhRWPtyQ1boioQxl4FaHu7gt7WfbehizcKwaXV9ZgMuUSUykpWhzQ1EydKCScP2nM29dv)O3)E4IC8WhWWfoDctTUFF(6FpCjHxjDNA9XzSjzWSUqN9WfoDctTUF0ciMJZrdiBdi8ihpCGdIJQFg8pGqQDJPD4IaI54C0aY6IP8aFKPw7HnqYXciBs6a5kNJgqqIPU(H0lMYdC)iPw7HnqYX6VAYl9lGKuEjg4kXZ6fUFONg1VBerQPC)7HfS)Hxiq1us97jP(hTF3m49uvl9lGJ6h6dEngGmC)q)GTAQJ6)2lkQ)u2FQUbo1Ab7FzW7(9uoX9NSyY(bKTJ1p6OIc7xsUr3Y(TiMa97jj0cioqYeiTaIBerQPCrZ6f(ezu)q1pNWu)cSF)SFO63ndEpv1IC8WhWWfabBPk7hA9JA)q1p697MbVNQAHGxJbidFgWwn1rfabBPk7hA9JkKSI(95RF)2pHs8Y1vAxi41yaYWNbSvtDu)Of4G4Ocjd(hqi1UX0oCraXbsMaPfqCJisnLlIiLxIb6hQ(5eM6xG97N9dv)UzW7PQws4vs3PwFCgBsgmRlubqWwQY(Hw)O2pu9JE)UzW7PQwi41yaYWNbSvtDubqWwQY(Hw)OcjROFF(63V9tOeVCDL2fcEngGm8zaB1uh1pAbeZX5ObK1ft5b(itT2dBGKJf4G4OIsd(hqi1UX0oCraXCCoAazDXuEGpYuR9Wgi5ybKnjDGCLZrdiItoWGhWU)QjV0pKYWuu66hfamEPFNjzz)RlMYdC)YuR9Wgi5y9NA)4uP(RM8s)xp5syJtTU)lgmhqCGKjqAbe3iIut5IsoWGhWUFO6h4Pu0aQPcSHPO0DQcmEPqQDJPD)q1pNWu)cSF)SFO63ndEpv1YMCjSXPwFUhmxaeSLQSFO1FL7hQ(rVF3m49uvle8Amaz4Za2QPoQaiylvz)qRFuHKv0VpF973(juIxUUs7cbVgdqg(mGTAQJ6hTahehvuyW)acP2nM2HlciMJZrdiRlMYd8rMATh2ajhlGSjPdKRCoAab6Nxiq)UrePMYY(rpvh2BNAD)6OqcifkOFXjhyqRFNj5(H0i9pA)UzW7PQgqCGKjqAbe073nIi1uUimginTFF(63nIi1uUOJs97Zx)O3VBerQPCrjhyWdy3pu973(bEkfnGAQaBykkDNQaJxkKA3yA3pA9Jw)q1p697MbVNQAHGxJbidFgWwn1rfabBPk7hA9JkKSI(95RF)2pHs8Y1vAxi41yaYWNbSvtDu)Of4G4Oc9g8pGqQDJPD4IaIdKmbslGCpsz)q1FuwVWhabBPk7hA9JkKmGyoohnGSUykpWhzQ1EydKCSaheVcum4FaHu7gt7WfbKnjDGCLZrdic4O(H0lMYdC)iPw7HnqYX6pL9ZPtyQ1c2FYIj7NtyQFE63ts9p8cb6h2GEya9VhwgqmhNJgqCggFmhNJEWPKdisgKooioQbehizcKwazpCzDXuEGpYuR9Wgi5yfoDctTUFO6h9(DJisnLlAwVWNiJ63NV(DJisnLlIiLxIb6hTacoL8rnykG4grKAkh4G4vGAW)acP2nM2HlciMJZrdiw9OXcioqYeiTaYE4IvpAScGGTuL9dT(VwaXfZHPdBGAILbXrnWbXROIG)beZX5ObKfZt5acP2nM2HlcCq8kQCW)acP2nM2HlciMJZrdisI2Nj64gaWBLZrdiBs6a5kNJgqqMQ9Zlu)ieTL9pA)vUF2a1el7pJ6p5(tPkg3VZdaiLXX6p1(JWz9c3)a6F0(5fQF2a1ex6hfK8s)i56YO9d5ze1FYIj73WYP)BIzc0pp97jP(riA3)iIa9dBQNHXX63wxXXsTU)k3pKnaG3kNJklbehizcKwaXCCkIoKsWjj7xG9xr)q1pBys5ICQE4f6ijAllKA3yA3pu973(3dxKeTpt0XnaG3kNJw40jm16(HQF)2FQNiCwVWboiEfxl4FaHu7gt7WfbehizcKwaXCCkIoKsWjj7xG9xr)q1pBys5Imxxg9GZiQqQDJPD)q1VF7FpCrs0(mrh3aaERCoAHtNWuR7hQ(9B)PEIWz9c3pu9VhU4gaWBLZrlac2sv2p06)AbeZX5Obejr7ZeDCda4TY5OboiEf(zW)acP2nM2HlcioqYeiTac69lhp8rUyGD)cSFu73NV(nhNIOdPeCsY(fy)v0pA9dv)UzW7PQwKEWWJE2gqyn2aubqWwQY(fy)OwraXCCoAaruIPdBPYboiEfqYG)besTBmTdxeqCGKjqAbeZXPi6ShU4Ps2UX0XIIWPJZr7pE)Oy)(81pNoHPw3pu9VhU4Ps2UX0XIIWPJZrlac2sv2p06)AbeZX5ObepvY2nMowueoDCoAGdIxbkn4FaHu7gt7WfbeZX5ObezUUm6bNruaXbsMaPfq2dxK56YOhCgrfabBPk7hA9FTaIlMdth2a1eldIJAGdIxbkm4FaHu7gt7WfbehizcKwaXV97grKAkxuYbg8a2bejdshheh1aI54C0aIZW4J54C0doLCabNs(OgmfqCJisnLdCq8kGEd(hqi1UX0oCraXCCoAaXnaG3kNJgqCXCy6WgOMyzqCudioqYeiTaI54ueDiLGts2p06)A9dj6h9(zdtkxKt1dVqhjrBzHu7gt7(95RF2WKYfzUUm6bNruHu7gt7(rRFO6FpCXnaG3kNJwaeSLQSFO1FfbKnjDGCLZrdi(H1vCS(HSba8w5C0(Hn1ZW4y9pA)OcjQOF2a1elfS)b0)O9x5(RM8s)(HB5G9yQFiBaaVvohnWbXRmkg8pGqQDJPD4IaI54C0acSHPO0Da2k7bOaYMKoqUY5Obe)qetG(5fQ)zLuciy)Yvs39B9lxmWU)QlK2VX97N9pA)qkdtrPRF)OTYEaQFE63en5U)rebC26AQ1behizcKwaroE4JCXa7(fy)xRFO6NtyQFb2FfOg4G4vg1G)besTBmTdxeq2K0bYvohnGGcwiTFD4(LXuxQ19dPxmLh4(rsT2dBGKJ1pp9lGKuEjg4kXZ6fUFONgjy)iEWWJ2)1BaH1ydq9Nr9ByC)7HL9BaQFBDfN0oGyoohnG4mm(yooh9GtjhqCGKjqAbe073nIi1uUiIuEjgOFO63V9ZgMuUSUykpWhzQ1EydKCScP2nM29dv)7Hlj8kP7uRpoJnjdM1f6ShUWPtyQ19dv)UzW7PQwKEWWJE2gqyn2aubq2ow)O1VpF9JE)UrePMYfnRx4tKr9dv)(TF2WKYL1ft5b(itT2dBGKJvi1UX0UFO6FpCroE4dy4cNoHPw3pu97MbVNQAr6bdp6zBaH1ydqfaz7y9Jw)(81p69JE)UrePMYfLCGbpGD)(81VBerQPCrymqAA)(81VBerQPCrhL6hT(HQF3m49uvlspy4rpBdiSgBaQaiBhRF0ci4uYh1GPaY2acRXgGoRaAnWbXRCfb)diKA3yAhUiGyoohnGSnGWJC8WbKnjDGCLZrdicOsQ)R3ac7hz8W9Nr9F9gqyn2au)vhvmU)BQFaz7y9B1wQc2)a6pJ6Nxia1F1eJ7)M634(XKj5(ROF4bq9F9gqyn2au)EssgqCGKjqAbK7rk7hQ(DZG3tvTi9GHh9SnGWASbOcGGTuL9lW(JY6f(aiylvz)q1p6973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(95RF3m49uvlRlMYd8rMATh2ajhRaiylvz)cS)OSEHpac2sv2pAboiELRCW)acP2nM2HlcioqYeiTaY9iL9dv)(TF2WKYL1ft5b(itT2dBGKJvi1UX0UFO63ndEpv1I0dgE0Z2acRXgGkac2sv2)L97MbVNQAr6bdp6zBaH1ydqLThW4C0(Hw)rz9cFaeSLQmGyoohnGSnGWJC8WboiELVwW)acP2nM2HlciBs6a5kNJgqGmJDlqcdJ7pzcUFpPvt9hnG(nngVKAD)6W9lxjxgL0UFclPQleGciMJZrdiodJpMJZrp4uYbeCk5JAWuajzcoWbXRSFg8pGqQDJPD4IaIdKmbslGWgMuUixS9u9qW3aZrfsTBmT7hQ(rV)nD7ffvKl2EQEi4BG5OIKnNW(Hw)O3Ff9dj63CCoArUy7P65EWCj1teoRx4(rRFF(6Ft3Errf5ITNQhc(gyoQaiylvz)qR)k3pAbeZX5ObeNHXhZX5OhCk5acoL8rnykGiPaheVYqYG)besTBmTdxeqmhNJgqGnmfLUdWwzpafq2K0bYvohnGiGkP(HugMIsx)(rBL9au)vxiTFyd6Hb0)Eyz)gG63BvW(hq)zu)8cbO(RMyC)3u)YSwZO0zk3pNWu)EkN4(5fQFLGoUFi9IP8a3psQ1EydKCSs)c4O(94eNxNtTUFiLHPO01pkay8IG9Vm4D)w)YfdS7NN(bueGKl9Zlu)3ErrbehizcKwab9(3dxeLy6WwQCHtNWuR73NV(3dxs4vs3PwFCgBsgmRl0zpCHtNWuR73NV(3dxKJh(agUWPtyQ19Jw)q1p6973(bEkfnGAQaBykkDNQaJxkKA3yA3VpF9F7ffvGnmfLUtvGXlfjBoH9dT(RC)(81VC8Wh5Ib29lW(rTF0cCq8kJsd(hqi1UX0oCraXCCoAab2Wuu6oaBL9auaztshix5C0aIaQK6hszykkD97hTv2dq9Zt)WwQSLA)8c1pSHPO01FvGXl9F7ff1VNYjUF5Ib2Y(vI29Zt)3u)1KsaJPD)rdOFEH6xjOJ7)2di5(RM6EQ2p6vGI9lj3OBz)PSF4bq9ZlM2V0lkkDjPC)80FnPeWyQ)k3VCXaBjAbehizcKwab4Pu0aQPcSHPO0DQcmEPqQDJPD)q1VBg8EQQf54HpGHlac2sv2Va7VcuSFO6)2lkQaBykkDNQaJxkac2sv2p06)AboiELrHb)diKA3yAhUiGyoohnGaBykkDhGTYEakGSjPdKRCoAabszPYwQ9dPmmfLU(rbaJx634(nmUFoHjz)rdOFEH6xCYbg8a29pG(VoumqAA)UrePMYbehizcKwab4Pu0aQPcSHPO0DQcmEPqQDJPD)q1p697grKAkxuYbg8a297Zx)UrePMYfHXaPP9Jw)q1)Txuub2Wuu6ovbgVuaeSLQSFO1)1cCq8kd9g8pGqQDJPD4IaI54C0acSHPO0Da2k7bOaYMKoqUY5Obebuj1pKYWuu663pARShG6F0(H0lMYdC)iPw7HnqYX63zswky)WMWuR7x6bO(5PFPjI636xUyGD)80VKnNW(HugMIsx)OaGXl9Nr97jtTU)KdioqYeiTacBys5Y6IP8aFKPw7HnqYXkKA3yA3pu9JE)7HlRlMYd8rMATh2ajhRWPtyQ197Zx)UzW7PQwwxmLh4Jm1ApSbsowbqWwQY(fy)v4N97Zx)3Ju2pu9ZjmD45StQFO1VBg8EQQL1ft5b(itT2dBGKJvaeSLQSF06hQ(rVF)2pWtPObutfydtrP7ufy8sHu7gt7(95R)BVOOcSHPO0DQcmEPizZjSFO1FL73NV(LJh(ixmWUFb2pQ9JwGdIFnum4FaHu7gt7WfbehizcKwaHnmPCrovp8cDKeTLfsTBmTdiMJZrdiWgMIs3byRShGcCq8RHAW)acP2nM2HlciMJZrdiBGL6bNruaztshix5C0aY1dSu7hYZiQ)u2)O4y9B9F9qAK(RTu7VAYl9lGvsuY2nM6)6j4us9RKb6h2GU(LS5ekl9lGJ6pkRx4(tz)294X9Zt)KU7Fp9Rd3pCkL9lxjDNAD)8c1VKnNqzaXbsMaPfqU9IIkPsIs2UX0ztWPKks2Cc7xG9FnuSFF(6)2lkQKkjkz7gtNnbNsQ4T2pu9Fpsz)q1FuwVWhabBPk7hA9FTahe)Ave8pGqQDJPD4IaI54C0aIZW4J54C0doLCabNs(OgmfqCJisnLdCq8Rv5G)besTBmTdxeqmhNJgqS6rJfqCGKjqAbeafbi5IDJPaIlMdth2a1eldIJAGdIFTRf8pGqQDJPD4IaIdKmbslGyoofrN9WfpvY2nMowueoDCoA)X7hf73NV(50jm16(HQFafbi5IDJPaI54C0aINkz7gthlkcNoohnWbXVMFg8pGqQDJPD4IaI54C0aImxxg9GZikG4ajtG0ciakcqYf7gtbexmhMoSbQjwgeh1ahe)AqYG)besTBmTdxeqmhNJgqCda4TY5ObehizcKwabqrasUy3yQFO63CCkIoKsWjj7hA9FT(He9JE)SHjLlYP6HxOJKOTSqQDJPD)(81pBys5Imxxg9GZiQqQDJPD)OfqCXCy6WgOMyzqCudCq8RHsd(hqi1UX0oCraXCCoAajctYfhWI4aIdKmbslGihp8DQ7IObBCIPJCWIiLlKA3yAhqsLjaWBLpzua52lkQiAWgNy6ihSis5I3AGdIFnuyW)asQmbaERCab1aI54C0aYgyPEKJhoGqQDJPD4Iahe)AqVb)diMJZrdiYfBpvp3dMdiKA3yAhUiWboGSci3aFBCW)G4Og8pGqQDJPD4IaIdKmbslGWjm1Va7hf7hQ(9B)RexmCkI6hQ(9B)3ErrLAqcpjGot0rAoqgLoQ4TgqmhNJgqIi8zpWPACoAGdIxrW)aI54C0aI0dgE0teHx8uMabesTBmTdxe4G4vo4FaHu7gt7Wfbe1GPacpW0zIoWJkzW4jpUrLmWZX5OYaI54C0acpW0zIoWJkzW4jpUrLmWZX5OYahe)Ab)diKA3yAhUiGOgmfqKdMSf5rsoaXhMClAIs8OaI54C0aICWKTipsYbi(WKBrtuIhf4G4(zW)acP2nM2HlcioqYeiTacBys5sniHNeqNj6inhiJshvi1UX0oGyoohnGuds4jb0zIosZbYO0rboioKm4FaXCCoAajctYfhWI4acP2nM2HlcCqCuAW)acP2nM2HlciZAarsCaXCCoAarKbs7gtberg2JciMJtr0zpCXnaG3kNJ2Va7hf7hQ(nhNIOZE4IvpAS(fy)Oy)q1V54ueD2dx8ujB3y6yrr40X5O9lW(rX(HQF073V9ZgMuUiZ1Lrp4mIkKA3yA3VpF9BoofrN9WfzUUm6bNru)cSFuSF06hQ(rV)9WL1ft5b(itT2dBGKJv40jm16(95RF)2pBys5Y6IP8aFKPw7HnqYXkKA3yA3pAberg4Ogmfq2dlpaY2XcCqCuyW)acP2nM2HlciMJZrdisI2Nj64gaWBLZrdioqYeiTaICLW4dBGAILfjr7ZeDCda4TY5OhBO(fy8(RCabNkDC7acQOyGdId9g8pGyoohnGSyEkhqi1UX0oCrGdIJkkg8pGyoohnG4Ps2UX0XIIWPJZrdiKA3yAhUiWboGydf8pioQb)diMJZrdiRlMYd8rMATh2ajhlGqQDJPD4IaheVIG)beZX5ObKfZt5acP2nM2HlcCq8kh8pGqQDJPD4IaIdKmbslG4grKAkxerkVed0pu9VhUKWRKUtT(4m2KmywxOZE4cNoHPw3pu97MbVNQAr6bdp6zBaH1ydqfaz7y9dv)O3)E4Y6IP8aFKPw7HnqYXkac2sv2Va7VI(95RF)2pBys5Y6IP8aFKPw7HnqYXkKA3yA3pA97Zx)UrePMYfnRx4tKr9dv)7HlYXdFadx40jm16(HQF3m49uvlspy4rpBdiSgBaQaiBhRFO6h9(3dxwxmLh4Jm1ApSbsowbqWwQY(fy)v0VpF973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(rRFF(6h9(DJisnLlk5adEa7(95RF3iIut5IWyG00(95RF3iIut5Iok1pA9dv)7HlRlMYd8rMATh2ajhRWPtyQ19dv)7HlRlMYd8rMATh2ajhRaiylvz)qR)kciMJZrdiodJpMJZrp4uYbeCk5JAWuazBaH1ydqNvaTg4G4xl4FaHu7gt7WfbehizcKwaHnmPCrovp8cDKeTLfsTBmT7hQ(DMEKeTdiMJZrdisI2Nj64gaWBLZrdCqC)m4FaHu7gt7WfbehizcKwaXV9ZgMuUiNQhEHosI2YcP2nM29dv)(T)9Wfjr7ZeDCda4TY5OfoDctTUFO63V9N6jcN1lC)q1)E4IBaaVvohTaOiajxSBmfqmhNJgqKeTpt0XnaG3kNJg4G4qYG)besTBmTdxeqmhNJgqS6rJfqCGKjqAbeZXPi6ShUy1JgRFO1)16hQ(9B)7Hlw9OXkC6eMADaXfZHPdBGAILbXrnWbXrPb)diKA3yAhUiGyoohnGy1JglG4ajtG0ciMJtr0zpCXQhnw)cmE)xRFO6hqrasUy3yQFO6FpCXQhnwHtNWuRdiUyomDydutSmioQboiokm4FaHu7gt7WfbehizcKwaXCCkIo7HlEQKTBmDSOiC64C0(J3pk2VpF9ZPtyQ19dv)akcqYf7gtbeZX5ObepvY2nMowueoDCoAGdId9g8pGqQDJPD4IaI54C0aINkz7gthlkcNoohnG4ajtG0ci(TFoDctTUFO6Fv0kBys5cWGxnLpwueoDCoQSqQDJPD)q1V54ueD2dx8ujB3y6yrr40X5O9dT(RCaXfZHPdBGAILbXrnWbXrffd(hqi1UX0oCraXbsMaPfqKJh(ixmWUFb2pQbeZX5OberjMoSLkh4G4OIAW)acP2nM2HlcioqYeiTaIF73nIi1uUOKdm4bSdisgKooioQbeZX5ObeNHXhZX5OhCk5acoL8rnykG4grKAkh4G4OwrW)acP2nM2HlcioqYeiTac697grKAkxerkVed0pu9JE)UzW7PQws4vs3PwFCgBsgmRlubq2ow)(81)E4scVs6o16JZytYGzDHo7HlC6eMAD)O1pu97MbVNQAr6bdp6zBaH1ydqfaz7y9dv)O3)E4Y6IP8aFKPw7HnqYXkac2sv2Va7VI(95RF)2pBys5Y6IP8aFKPw7HnqYXkKA3yA3pA9Jw)q1p69JE)UrePMYfLCGbpGD)(81VBerQPCrymqAA)(81VBerQPCrhL6hT(HQF3m49uvlspy4rpBdiSgBaQaiylvz)qR)k6hQ(rV)9WL1ft5b(itT2dBGKJvaeSLQSFb2Ff97Zx)(TF2WKYL1ft5b(itT2dBGKJvi1UX0UF06hT(95RF073nIi1uUOz9cFImQFO6h9(DZG3tvTihp8bmCbq2ow)(81)E4IC8WhWWfoDctTUF06hQ(DZG3tvTi9GHh9SnGWASbOcGGTuL9dT(ROFO6h9(3dxwxmLh4Jm1ApSbsowbqWwQY(fy)v0VpF973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(rRF0ciMJZrdiodJpMJZrp4uYbeCk5JAWuazBaH1ydqNvaTg4G4Ow5G)besTBmTdxeqCGKjqAbK7rk7hQ(DZG3tvTi9GHh9SnGWASbOcGGTuL9lW(JY6f(aiylvz)q1p6973(zdtkxwxmLh4Jm1ApSbsowHu7gt7(95RF3m49uvlRlMYd8rMATh2ajhRaiylvz)cS)OSEHpac2sv2pAbeZX5ObKTbeEKJhoWbXr9Ab)diKA3yAhUiG4ajtG0ci3Ju2pu97MbVNQAr6bdp6zBaH1ydqfabBPk7)Y(DZG3tvTi9GHh9SnGWASbOY2dyCoA)qR)OSEHpac2svgqmhNJgq2gq4roE4ahehv)m4FaHu7gt7WfbeZX5ObeNHXhZX5OhCk5acoL8rnykGKmbh4G4Ocjd(hqi1UX0oCraXCCoAaXzy8XCCo6bNsoGGtjFudMciBcBXO9HbPkKyzGdIJkkn4FaHu7gt7WfbeZX5ObeNHXhZX5OhCk5acoL8rnykGSnyRMomivHeldCqCurHb)diKA3yAhUiG4ajtG0ci7HlRlMYd8rMATh2ajhRWPtyQ197Zx)(TF2WKYL1ft5b(itT2dBGKJvi1UX0oGizq64G4OgqmhNJgqCggFmhNJEWPKdi4uYh1GPaIKn(WGufsSmWbXrf6n4FaHu7gt7WfbehizcKwazpCruIPdBPYfoDctToGyoohnGaBykkDhGTYEakWbXRafd(hqi1UX0oCraXbsMaPfq2dxKJh(agUWPtyQ19dv)(TF2WKYf5u9Wl0rs0wwi1UX0oGyoohnGaBykkDhGTYEakWbXRa1G)besTBmTdxeqCGKjqAbe)2pBys5IOeth2sLlKA3yAhqmhNJgqGnmfLUdWwzpaf4G4vurW)acP2nM2HlcioqYeiTaIC8Wh5Ib29lW(VwaXCCoAab2Wuu6oaBL9auGdIxrLd(hqi1UX0oCraXCCoAarMRlJEWzefqCGKjqAbeZXPi6ShUiZ1Lrp4mI6hAX7VY9dv)akcqYf7gt9dv)(T)9WfzUUm6bNruHtNWuRdiUyomDydutSmioQboiEfxl4FaHu7gt7WfbehizcKwaXnIi1uUOKdm4bSdisgKooioQbeZX5ObeNHXhZX5OhCk5acoL8rnykG4grKAkh4G4v4Nb)diKA3yAhUiG4ajtG0ci3ErrLujrjB3y6Sj4usfjBoH9lW497NOy)(81)9iL9dv)3ErrLujrjB3y6Sj4usfV1(HQ)OSEHpac2sv2p063p73NV(V9IIkPsIs2UX0ztWPKks2Cc7xGX7VY(z)q1)E4IC8WhWWfoDctToGyoohnGSbwQhCgrboiEfqYG)besTBmTdxeqmhNJgqIWKCXbSioG4ajtG0ciYXdFN6UiAWgNy6ihSis5cP2nM2bKuzca8w5tgfqU9IIkIgSXjMoYblIuU4Tg4G4vGsd(hqsLjaWBLdiOgqmhNJgq2al1JC8WbesTBmTdxe4G4vGcd(hqmhNJgqKl2EQEUhmhqi1UX0oCrGdCajzco4FqCud(hqmhNJgq8K0jzcwgqi1UX0oCrGdCarsb)dIJAW)aI54C0aYI5PCaHu7gt7WfboiEfb)diKA3yAhUiGKktaG3kFYOaYMU9IIkYfBpvpe8nWCurYMtOaJx5aI54C0aYgyPEKJhoGKktaG3kFQXZTHdiOg4G4vo4FaXCCoAarUy7P65EWCaHu7gt7WfboWbeLCG5axn4FqCud(hqi1UX0oCrazwdisIdiMJZrdiImqA3ykGiYWEuazpCXnaG3kNJwaeSLQSFb2Ff9dv)7Hlw9OXkac2sv2Va7VI(HQ)9WfpvY2nMowueoDCoAbqWwQY(fy)v0pu9JE)(TF2WKYfzUUm6bNruHu7gt7(95R)9WfzUUm6bNrubqWwQY(fy)v0pAberg4Ogmfq2dlpC6eMADGdIxrW)acP2nM2HlciZAarsCgfqCGKjqAbe3iIut5IsoWGhWoGSjPdKRCoAaXFqQcjw2VHZAT)QjV0pKgP)Ob0pYITNQ9d9bFdmhjy)x)f9hnG(VozEkxciImWrnykGWGufs8ztylwaXCCoAarKbs7gtberg2Joewsbe3m49uvlBYLWgNA95EWCbqWwQYaIid7rbe3m49uvlRlMYd8rMATh2ajhRaiylvzGdIx5G)besTBmTdxeqmhNJgqGnmfLUdWwzpafq2K0bYvohnGCHhq7xoE4(Llgyl7pJ6NxO(JY6fU)Qjg3)n1pP7uR7xoJwcioqYeiTacNW0HNZoP(Hw)e0ropMoCct9FD7xoE4JCXa7(HQ)9WfpvY2nMowueoDCoAHtNWuRdCq8Rf8pGqQDJPD4IaI54C0aYI5PCaztshix5C0acKzsU)fZt5(5PFafbi5s)3u0aO(JmmEIIkbehizcKwazpCzX8uUaiylvz)qR)k6)Y(jOJCEmD4eMcCqC)m4FaHu7gt7WfbeZX5ObeydtrP7aSv2dqbKnjDGCLZrdixNY6L(He9VcYbKCS(HuOG(bueGKl9Nr9lxjDNAD)Js9xJNBd3F1XdV73zEsQFpz)80pCkL9Zlu)Z66aypn5y9Zt)akcqYL(HuOGsaXbsMaPfq4eM6xG9Js7hQ(V9IIkWgMIs3PkW4LcGGTuL9dT(RD7cSbD9Fz)e0ropMoCctboioKm4FaHu7gt7WfbKnjDGCLZrdiqpta1)MWwmA3pdsviXY(tTFt50LRgNJ2)e1)1tUe24uR7)IbZLaIAWuaHGxJbidFgWwn1rbehizcKwarKbs7gtfgKQqIpBcBX6hA9xbkgqmhNJgqi41yaYWNbSvtDuGdIJsd(hqi1UX0oCraXCCoAar6P34z2hdM4LysoG4ajtG0ciImqA3yQWGufs8ztylw)qRFizarnykGi90B8m7Jbt8smjh4G4OWG)besTBmTdxeqmhNJgqKJhgtmNA9b4DhlG4ajtG0ciImqA3yQWGufs8ztylw)qRFuyarnykGihpmMyo16dW7owGdId9g8pGqQDJPD4IaI54C0aICX2tvAFgW9zIo8aGjLdioqYeiTaIidK2nMkmivHeF2e2I1p06)Abe1GPaICX2tvAFgW9zIo8aGjLdCqCurXG)besTBmTdxeqmhNJgqwxmLh4Jm1ApSbsowaztshix5C0aIaoQFEH6FfBXiq)PSFpzQ19FDY8uwW(Jsa1pKgP)r73ndEpv1(5fs7pAW4PA)vtEP)R)IaIdKmbslGWgMuUSyEkxi1UX0UFO6xKbs7gtL9WYdNoHPwh4G4OIAW)acP2nM2HlcioqYeiTacBys5YI5PCHu7gt7(HQF3m49uvlRlMYd8rMATh2ajhRaiylvz)cSFumGyoohnGSjxcBCQ1N7bZboioQve8pGqQDJPD4IaI54C0aYMCjSXPwFUhmhq2K0bYvohnGiGJ6NxO(xXwmc0Fk73tMAD)iqFc2FucO(V(l6F0(DZG3tvTFEH0(JgmEQMAD)vtEPFinsaXbsMaPfqydtkxKl2EQEi4BG5OcP2nM29dv)ImqA3yQShwE40jm16aheh1kh8pGqQDJPD4IaIdKmbslGWgMuUixS9u9qW3aZrfsTBmT7hQ(DZG3tvTSjxcBCQ1N7bZfabBPk7xG9JIbeZX5ObK1ft5b(itT2dBGKJf4G4OETG)besTBmTdxeqCGKjqAbK9WfpvY2nMowueoDCoAbqWwQY(Hw)qYaI54C0aINkz7gthlkcNoohnWbXr1pd(hqi1UX0oCraXbsMaPfq2dxS6rJvaeSLQSFO1)1ciMJZrdiw9OXcCqCuHKb)diKA3yAhUiG4ajtG0ci7HlYCDz0doJOcGGTuL9dT(VwaXCCoAarMRlJEWzef4G4OIsd(hqi1UX0oCraXbsMaPfq2dxCda4TY5OfabBPk7hA9FTaI54C0aIBaaVvohnWbXrffg8pGqQDJPD4IaI54C0acSHPO0Da2k7bOaYMKoqUY5Obe)ifbi5s)qkuq)wetG(5fQ)zLuc0Fg1)2acRXgGoRaAT)QJhE3VZ8Ku)EY(5PF4uk736hsHc6hqrasUeqCGKjqAbeoHP(fy)O0(HQ)BVOOcSHPO0DQcmEPaiylvz)qR)k6)62FTBxGnOR)l7NGoY5X0HtykWbXrf6n4FaHu7gt7WfbKnjDGCLZrdiqMHX9VnGWASbOZkGw7pJ6hsVykpW9JKATh2ajhR)u2VZdaiLXX6NtNWuRdiMJZrdiodJpMJZrp4uYbejdshheh1aIdKmbslGShUSUykpWhzQ1EydKCScNoHPwhqWPKpQbtbKTbewJnaDwb0AGdIxbkg8pGqQDJPD4IaYMKoqUY5ObebuoX51zQFtJ1)WleOFjBC)mivHel7pJ6hsVykpW9JKATh2ajhR)u2pNoHPwhqmhNJgqCggFmhNJEWPKdisgKooioQbehizcKwazpCzDXuEGpYuR9Wgi5yfoDctToGGtjFudMcis24ddsviXYaheVcud(hqi1UX0oCraXCCoAab2Wuu6oaBL9auaztshix5C0accBoH9dPmmfLU(rbaJx6NN(RSG9pG(bueGKl9xDH0(RjMtTUF8uTF0ZnzyCS(XZim16(Jgq)w)od78Wgt7(vp4Bciy)3EC)xR4NY(beSLAQ19NY(5fQFaj9WC)tu)mj5uR7VAYl97FfOu0cioqYeiTacNWu)cSFuA)q1p69F7ffvGnmfLUtvGXlfjBoH9dT(RC)(81)Txuub2Wuu6ovbgVuaeSLQSFO1)1k(z)Of4G4vurW)acP2nM2HlciMJZrdiWgMIs3byRShGciBs6a5kNJgq8d7DY5OgUFiLFSF5kPBz)vxiTFc6yG1VCXaBz)gG63ezj2UXu)MU7NsEHa9dPxmLh4(rsT2dBGKJ1Fk7NtNWuRfS)b0pVq9hL1lC)PSFs3PwxcioqYeiTac69VhUSUykpWhzQ1EydKCScNoHPw3VpF9ZjmD45StQFO1VBg8EQQL1ft5b(itT2dBGKJvaeSLQSF06hQ(rV)BVOOcSHPO0DQcmEPizZjSFO1FL73NV(LJh(ixmWUFb2pQ9JwGdIxrLd(hqi1UX0oCraXCCoAazdSupYXdhq2K0bYvohnG4h27KZrnC)xpWsTFKXd3VZKC)vxiTFins)PSFoDctToG4ajtG0ci7HlRlMYd8rMATh2ajhRWPtyQ1boiEfxl4FaHu7gt7WfbeZX5ObeRE0ybKnjDGCLZrdiq(uTFir)RGCajhR)9W9dOiajx6V6cP9dOiajxSBmvcioqYeiTacGIaKCXUXuGdIxHFg8pGqQDJPD4IaIdKmbslGaOiajxSBmfqmhNJgq8ujB3y6yrr40X5OboiEfqYG)besTBmTdxeqCGKjqAbeafbi5IDJPaI54C0aIBaaVvohnWbXRaLg8pGqQDJPD4IaIdKmbslGWgMuUiZ1Lrp4mIkKA3yA3pu9dOiajxSBmfqmhNJgqK56YOhCgrboiEfOWG)besTBmTdxeqmhNJgqIWKCXbSioGKktaG3kFYOaYTxuur0GnoX0royrKYNfpytNCx8wdioqYeiTaIC8W3PUlIgSXjMoYblIuUqQDJPDaztshix5C0ac0tmjxCalI7NN(HTuzl1(fqoyJtm1pYGfrkxcCq8kGEd(hqi1UX0oCraXCCoAazX8uoGSjPdKRCoAabYNQqIvqoGKJ1)I5PC)akcqYLsaXbsMaPfq2dxwmpLlac2sv2p06VYboiELrXG)besTBmTdxeqmhNJgq2al1JC8WbKnjDGCLZrdicOAQmbaERCEJP(VEK(DlMQeU)mQ)Qu)lMiQFEH6)6VO)BVOOsaXbsMaPfqU9IIkBYLWgNA95EWCXBnWbXRmQb)diKA3yAhUiGyoohnGSbwQh54HdioqYeiTacBys5ICX2t1dbFdmhvi1UX0UFO6Ft3Errf5ITNQhc(gyoQaiylvz)qR)k3VpF9VPBVOOICX2t1dbFdmhvKS5e2p06VYbKuzca8w5tgfq20TxuurUy7P6HGVbMJks2Ccfy8kd1MU9IIkYfBpvpe8nWCubqWwQsbw5aheVYve8pGKktaG3khqqnGyoohnGSbwQh54HdiKA3yAhUiWbXRCLd(hqmhNJgqKl2EQEUhmhqi1UX0oCrGdCGdiMhVmGacscdzboWHaa]] )


end