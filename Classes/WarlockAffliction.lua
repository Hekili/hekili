-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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


    spec:RegisterPack( "Affliction", 20220821, [[Hekili:v33cZTnosd(BX7uLI1ehhRhotM5IDvzsM92mFZRko7MVQU6SmffKf3qrQLpSJ3kN(TFD3aKeaeaeusE28vvQyBsGgan63DdWRhD9hU(QfbfSR)TXNnE8zVC8Oth9IZMmEY1xv8Wg21xTji8tb3c)ssWA4)F9YLXrHfrPj4REionybcI80YSq41Rkk2K)dp)53gvSQC(PHPRFEE06Y4aShHzbllW)o85xF18YO4I3LC9CJJ)OxaWCdleE8lohaB0IfmEBz5HYZIT38XGS40WpT9NFD5TL5fBVz8OtG)dG22FE7p)Mvbj3YY)HT)8Z2EZRbOSy7nxTHfhV9MFb61PYp)TS7GLX2B(1GBJcvEZ8mwWNcbqLWGogNcVF7nltH2(2SGiysCvAzmVhF4EOPimIzlXw9(GnfLzS6EvKU9M7tZGMeTC7npKw(e8LRJYZJsUD7nbqlGUMaRdeUfRcGFll9EoW)PKG5XmeOR3eGTPbrKV9M)4U)OQ3sZLC(ygCxAeUsItVNgO3gK9PBJdWbhhiypQi6zfbz3YaWE)ZHE82F)dqFl3WH1BstGTGCO55PRzk9)pYyB2EtyqCSySYylkdHxaB)Bklc47tfrRzCqDfoeCOGDAwaTaMfhH7EWKplIjauo87HfklGWvSWprRaS95vOO7ttEc8J5mC0dGgbn94GBHnNJgYh1Fpj(bCSX3a0Iqd3KXE2MY44QT6)jr(8xMxMbt3382CeCWMmdNuyNG9RLr3UQ4VOSzgSzdc4uc84dMNMNlAj8ZJtsXfqwq(kyebMPCX85VgZYxXzj(hPidcUXEvA8D0MFyamfJNH0iHej8coWJskyzzLBkGxXHZ7GNCBgWcT9MFJfMbT5x)iU2IsZIkEGJM4T8TcCugrHkr5cOpGFfzacJwdZee7(JPXyBlxU8uGtplDjm)U(QV5BKP5Ky(OxyIbeFrdti(x2yevFNoZO6B9LHu0RhpMsXa0hgt550HG5uaVdfdQaC)hGjvmYozuRjd(tKzvmMhegwbS8KPv06DLXf5)47B5Nc4qy3EEqXflHP5I01rj0((jrlVa35V8SbhTHvCAqC0DSbhr9)2SO1PrzSzPlNLheMfbmpStl3yaQp9INNxUEnqHaaX87lZzZIkyRpbTK4IcG0cHl0fGakTmFwi9BLcMgparEAmlyv(SCadYkMvWcxLe9VkzM7RXfdT65mMMxSmIXEHzqUSMIW87Vlilc7oF6UiTiFgSfU4HtUliUKDb2L7yWErbyOerJaqa2hKEEWTPjpO(OsalHaDwqTigObhFKyzKhTzfXNUSEY)LVi1DP3F5zdhCm(SnablSFmdL2b2QHKGNwerCWF5lva2uJedWqleealmInBwCNehLWMfU4IrNHy(Cu()mUCT8tB38zbPSlVyIzOVkOmXgLwBuuLQOF6ZSWYcK5KDhl7bUupu(e8FaOqnir5OCSGOyeeNwpcIzlxDN4zWyTG0tnBnQMs(56cn50aWc6eU8YlgHyaXgdlHTgKNE5eziSMRTAwgxzf2CIReGCW6OcILjdmhgK3LsmLOM2auHAoBtax4sGqpnxSnPGKK3eNMTGlZHeL8HtHUwMLb7ZnIhtH9G1r)BexrDSe1TWL38hxDQ8mnRmP9snbhNzRVxz9gMcslb6OttQMfdGoJcUVLDA1c(EyUVAGkQ5IrdSthsl9xlTuZftzyKt(eJu5Sk4oq4kSoVc03H7WOQI8G7QxEvQp4YvFFAXZF36naULeQ(MGIaum1MvSN)h8ja0YMzayWtkqdLDFeIKWPryAA8I07toTBIcXSCw(M4OIzKUZU70cwCWdadJOZ5D3dGNOOU5k7kKqaWfU4zzWVuZ5JpnQchmlSbfqcsuAMdjidhqqoFvq2IlNWB(DGUtGVh0n2aMk5xP3pdWKZqPbESOweaCESMLLcngQvF2YagiDSsu8Pki7V8L6TP6LFgBnmXYVC8zF5lh3QBPjSbw7ZReT60rNw3gXRgAcyf3N6bWg3gydXjUyvIMFS6HmFwJg3m7Zc2ja2RvVFq2mQ442svKWpF6byCtKEqcSKg6d6YerDpqwo6(EHQ8bUMruEOk3h8IWqVfvoy0hKIT(UxyKobQj0bP04hj3hYjr(KeQCUlGKdbctbIxNIkpbYNSUupdotmG66SQzaJBVXm0mJVTrq4alwYvjoKMCVd9Lqq1U9gOhgv9WNLGw0e4zNiutl58h6ec7ZfKxrKzoHCf9Ozcf(iGvaPzGfwBiTfTe94LIcp2UgB3C0AsmNuXAsdQL)Bs)2FAZNDs8uhkvT((6PoN((9SLGjIRiQhGkHfKHw2Hu43Msg2aQGtPaCqKLWpQn5bGEoZd6J0cdugnO(J6a3RR1BQYwyff2r9KeZT6KP782I9TA(u01wMxcWNoSM13oZUaIaZEKqivEWsbREn7VWswzxvGNodr44EvhZwR9Zb1(G9Xos(6(QhscTTY5UE8p4uep)34sO)RbmnHKQMIx22ECc5(tR38a4loi2)3ZwKeqHzc9UIJoJscXaKGy4vq3aWKuefJO7NKtXUAbmFoE0lrzOHPjOwJGLfmUtsdLXDgqtwSrLccZ5o4mgn44k9zmXSFwQyY3s)2Rg9cu0e7FvgTzdBr7E0RzzfBO(C0nB2bFc)nkEVYPhQJP7hrVgX4WrU)TPIekxH5H8pmHznUz9aN0ThS6yRf1J2S5WGvVYN8iGN(DKfOHZaJTjquhxYLTdcZEg68pHnhYrAOx9QSkEGno2TatJ2Mp4iliSHdp0iIoN)gSyB0l6Pe4NKxhfPk5VPCS)6G)jgzbs3BNksRqukEM3LofdACB7AOcIGIO4jHpesEGtrERzOOx2OlsUFIWTHYOtVxyj5vKp6enZembhe04MxWvmrHToSjWsi)hyQlj5gXmuAhqiX7liB(JeF5vuqk3EZVeHQ14O4G4CmE9ScsoBnQwKNG7447Ksa3(Gio)eP(emZivbumxjAmgIpz7qYnEGPatimRPfaQ3yokkzMyLU7JytOA7X4rMgk1cJ7MnbGH4ILIqZO6OfxpFg2TPYxoASm4n4zJ0c1IVpxaEpkBERj3JmUyKWt2iSLJkUry0dEYJAlsJhasEULAO2KjiX)A0ZgxZLCsddWKkTrVEEEACjg2wjyiphBOAmSmv31E10NDSjc3M4S1GrgAJKzmFDXTSH4ttb99SSte(ji74W9RyWAbZY358Lv7KTkLGqKFneys1S00Gp1sKMt5AuhpIMwFKgqkHD5GvJeZUzb24422SryrCfrnRMU1LOKM4khMONHctIKYb0E5RSl7N9YqzNmJGHPwCbURXTxUhlgMDYfQUGlT5(318IH2xK2MuZKmAnoLgzbxf2yudmzNhUzITdjnJzKHoaB4Akw)sqeuMKB1PhYmHUfcQyirtk5mGY9mkJkaCO7PNRn4oN6p1ElwuMrjk(vktgr2Mkcx9mIDbZklIedULjYNsqYdfRewBwqcmcJwgrzEloNDpT90jhfbwkXD1rY4Qvblqlq(P1ZZci32ejUPj0fvrYZOyOohZC5ScNtJ2mgFWAIs6cgLloTxdkSc)0RoE8Z4aT61K1(1kObohZ9U2FajEG2sr5cALnTKlLQCJlQ)8OBtWmAtEjZTwv4tljxpH95cZIpf(lxcTn6FtyxvpUQDrUrvaVcteBxe4jpRDlNNIDGP8c5LqrEZ0LHHr53IVgF5l0oGYZeBFt(YxKThY5MbUuXnnColwRRRA09Chs5rvqGSROmtyv1hcU5ClQunOOovKsBjZlZqjw3hLqe9hp(mPyoGEIWfKva7CWlGHkkmIcUlc7k4s2yWh6HDSnyZxwRHL4YXNnWaQuYiRVbrCvOiD31rPYKaeKMmxE9l5Pp(S)lsBIuSE2T1HpQSg29cYc5akWXSniuyjobPo41fvEn5dMdADUhIqSnYc5Sl5LKwuxiGUctNdVk9u504ZbMiuZdU1nRiD2Ii2R8PNhk2sFw)APt(BQlFkHRL5vv7aSb8wmai3sVLBq(7sy3fvWRSV3cMvNtSLbKNMFwSlLleqkNXO5PLcoqYi5fPcDGybfkRNIOZ5qrr3ood5UZejQ5JO6zYSf0eHJuUC6zcmw7guUzGHOB0dNE8kQbc58eo6q6aOf42HREw6LBhNK60G9Wjk5bSPWWQCHzoia)07eLniy4gv1GNixCG8nA9MixTD1KgC7(A1x94lI8HsfgMrlzSzlcN86IjdCAQYLtuw2sM7ix6HbPSlmioqPbpTvbDXFOVoA9iKtsWTI9o)FYE)S7zJ8Wmt8r13HppK6BOMdbMXySbgRs)MFG4O9moDTdcsBzjIjGvPHsY3O28QP8japUQ6PwRVq7YlMklxCqNq(rrkSdyBynCufO2C3gXgugVg5L6yETFvUNAVAI(SqnoMY2h4NGe)dWNpqZN4)CCNjpd4290RNodMYEl1amvBNeB0zahoq1wHbPRhBYvLACABxe)tzQQt)81C0L29P4oefjFyR4bbYNwATOy7GTvPgs9Rt2RM2o9UYXoN(yBWXgZXjXZo2YSdJAn9ayv9RzM4rNKJLFlL6UTSxsXGulFfyGQSgXJ0EVnStpug0TUGE4U2fNFMWNz7oTP6V25w9VRYc9ZnApP(K8XXJefmWxLELurDz2ZKQn3lmQQvMo3yCu6uG4RgDMp1n75E1QXyPKKSOmQXmvy(gZysj4VEfbRzRRPoYeKdzxghhTnyottxlMZRdHo52x9ZN2iEKEH5Lwf1(byh6CFq9poBqYRId8EsEyAzgo6fryqMKi51u2DH(rQdMsyQckKk2z9(8u9dI3c0aRL4zN7owEol2)EEB8dBwHUMfKNhToIFpb4F3ltcxbOEqJpStSikOinlhvWe(PyPS51jyyZHwHR87Icz(3nqTtkIVbH15SS7sJ6bklilCf8xHf5ZGTjwcq08a6FApgE8aloJfghTjVh9QiLn7tjmwo4JskfstV766SmymdYbZSVlThR1W081GHasBrCmhEA7uOmL9E6ctwwO2ezJuD0MnP6evAnaPCNhNMUWrBO3pBzz2dUAeldieuzkB1OEy7HthrBbyD5sk4wndJVWoPKQBRn(vzndqV6fglz7o9Z1uN93ft7RT2S36vgy)xIJpBFwJA9(rzrMxMWPrH)aMB5f9Fr(1((ioHJzfKw1SY5p0)v4l3Nv4l)tyfsMPIbRmBoQveKqUMLSdBLMpffEUqNUZluPLQ4yHCbp6MrMQV0x2DefUSvVApeAopgzVI)8Dan0xJdRL4RAj6L9EA4aggNoQXdVv4S73G3URYBVijBToeL3uDSVVWWLFqvvtZV(dmpkxoEqR9CXZCGpGwy6gqqeZV2BNxkoFuFOkMp3eedM92C(2fvIGwXgDY2BE7pkE1FJ8BP9c)P637dvhzrI7xS29j(C8ModRwQM2B5meCs6MlYzfrlpb9ajcNrMRGjBH0WXzHKYsTi92nfuuDTwLMMyglykP8svkW(CYiFdvgF8egQwUrvfd2sWkRu6kqXWmJ6yfpII)NVA8tLNx0G93GLoDnS0C9SGNDI6HeXrn50pfpDj3gNohpBr3dll86WjOKFwKefmevgaI6PDtAwrzsuvDQwd1F9J9cRE535QOvUnCb8Mp3ET9xJqKLqV02BQdbkvP(ajsuy0gX1deEJ6OFEzmpf9W6RwNNxAkagk5banAPJfa(cFGNbZkSaUx6d4SRd3cuNwFGtiAIn4MH4EiruTpKSMtqUq66Cs)C6G9dpzfPan)91NTPF04K1GahP4pqmddQNNYsTncndX(rbs(iN7YZ6C9F1pvV4r5V2x8uRRLH3VzSQGYEGeCJs1aBxsYV0clWUzQHz6Fh2Kn1yh80(kZD2lZsMQECLrbSbTo3bCzTQo(6wiBGQS6dMa1XFRvrQ8RGh9jzKZJtM0rKYfHMxzDUhPIIxkJuL9YOc2U(KRHz3srDGpNgUEmN35SNXpbAMlpsCBFIOiOR1JYlx6B5Y3X7coSkAJwW4hlhqpcVEm5LSoDx3fcdjvlUjLRNth2L5y58n90ZPZ(lsaqDjQsjomqL4DUgQHSGLxije6dJ)UH9KQ7yxvaPRct90Z520(6fCdardq(13lSnjVctW(CrwqJbEb0bCP62UcjcWc0pItf05oUazlBHi(wUTqEB)s31J6ouHP9Oos1Wzk3VE8tglh1H6D7ICxovy(rm)lifPI1LlWAfvJawklNMXR1Y0nwZoDRjPRUPkfVRwRPWOTNzQLw03iF7kUvRQ6BDzlAgb4BgoRVOgnNEZzRkxhKKgTO6kvd2FEwZEJWNdXSV3UxmHlYnPonPrex3BVIFRrs3MPOS27z4qDhtWBHg9iUrh7KMZysxLZzR1EA2GLooRkotv7RM81xcHTS8)kEAAj515Sl0kz28V2tgFUJCXRysGw(jWktbm)pVaKIEBuSLo12vSWGSC0hSL4PGjdKUpdn1yjZxaaZ)WSsU4Y)vjihVCn4ZMAwc7ec0DAkM1Rfr3Hx)LZXl9yp7E6DSSLC)AMfKaBDZcXtyNN9gTmCDkgIpw4NMTPSGFDr6)SFDqyWCWWY8vmWB11G3yH(21LXb8l415bffXEpI3h8j0s)CyllnzHV9I2HkWrBblFtGCIyD3rPCsopyH)y2uytmk)tK)9aTjDOM9SRRsZsW(DxqCQ3ZtCxeVCibfr5R9TtGfzGfwRyblQMNjb3gVmWXOAknN6TXq6sBbgPeHYpS2yuM4Nz38skMxBVz7)pWCtWCQ)7F)984n9lLb4jlhu()UNGQ(cttaYFYu8Ivrc)6qdOwTMvqxk4vJFv8uKUbn1I)mD8tb()QRlerCyp(4rFRJBqKNk)A7cduBNE8K0ERE0Rgo8Iroxjp1waLttyvldXJoDeyVbLz)WbQpQYQ5H72qvCFQ(qnU9qnEFgk1QiOA0oQhlnmTvh1J5h0(6TLokefFwakTPA(B82qSj0skRzRx0HoA)OV10iqKC1VqN2hi4m3tyS6SNxFfWtMdifXxSJxm67U(Q7dYqFIZV(Qp(63)BV73(F)da79nFanDnAnNBNCW(jgWJpbTMgGFgYNZVW5dkbhM4(GZVl1X7TLFHU3Mg)d0nDFLCHN0qk8F)eUaI6hvWF2XJ)8W6UpXs3hBO7JB39P73OBR7Do6B)5oWRALGt)WPF)pGUKiKlJnOsnY267p6)p40tRWH()()I)Haa9ynkNmvSgKJoZlyQwrrMbyNRDfLp9BLpASxttdA7DU4p3lOAv98oIhQsRxprb60KCxbAiif)DL3air5ijAA9(xvbK1aO(b2Gqlw6EodAXt3Z(3IRCp7F)XaNVZZGojkwWwgug3tAIDy(GHl(N(9FPJfwZP(UgwspYg65LhQPZ33FX3t9O7oeFl39r7cRMS6Jr7lNYO9LuFulkdX6nyEy9f0xdzViqTWlBbOxCOa03DqiXAbMDE(OtSUJZNw08748z8(kDC8(sZmUfBJhaqXMT9LVzY(Y3mzFrIt0j33nQIjhgI9jhgA0j7YgRtaSBZJPN1)5Hz9dtBjvQBiPAGV(guDAiQbrZtCmD6uTEqk7j9sL(Uqb701fp6)HXeN9q33ezaSlya3IK7gaMjZgFWiyhVdIgTajDs)hlk3Q8A0pY3DyDQU86F)nJNgTd7DQayFxk7eNWOdjNW4wgl1xaOZkTJeB7H9bvuRVBDLp6JMSv5ZLfs8D9v0VrFHBLJYa8GFJ(05kG41)y13hxTmvD9vCq2(ffx)BJncbRjTQbw2Bca1jgHQ9Gx3awhTbG7uBW1u(TuaQXgaq8CJq0CkVAaOL3dW7fgHN1KG1as7nbG63zeQgYmwd8m9sasV0iK0suwdu0FbaHV3ieuZzwda0Eo0)rNzMOf)B50Njr226viymt7RNmTgO06niqmt(BiwBuRntwRKmTMXt9Xy3nt9QKwnP9pLhJD3mPQ1i4r9HihRaztI1KHd2SVtUz15wtVvVuby1PxtTzfW(v7aSBsyv6gqkcRObKvH8h)T4s4hhdcjbHIBV5B3EJ9mKT9MHBV5PMAQJuNBTp6zoZrl1ZIg1u4FxanL)vcplAdFPzk3J0cEMqGRwsomjA2l8LuSJQs902Bg065nvU8q5PHu6BmjgVFZGXwMbJ9zguCFQjb(EndoI2T6pMG(3x(c1Bny49APggUZQN8swnVjMuk51Q2uo4OjRLm3jVAnLfoF7lNRW8ORX6ynNE1SnDbvAE1BOAIaJeoXLxPL4k7gwjFZeizjK8tTAsL(9tGKMF93y1aklKsnA4m9ARMn58IlObQUBMvtOuUpdAGM6JTAWu7R1Ggqy4DwnrY6vCqd4S3eRMljFu1Lq)Yp1QHsTsHPdBIutnPdRECC7g0m)C1ioFG2rd2eJGXf7vGIoG4pkGee1(qctIsSEqH3EZR2EZlKfPOFOHv7VZdoSdGrE9ZVmNXxPDqI1Eycx(LXDCd841K36gNCiWn49T9Hd5ybA7d2P9Q2GiSAXL6MnDiqrFLt(0EnBqQSS(ezlqpe4NxEiXpMb2EHF0xYguRuJEmF2gpeyPPhsSKzGTxyjlRCHrmYNaRAr31wmwFt2O5v3y5wvFv2O1OjYnIFx2O1IP(4b55E5n6l8XnZw67B29pYe6gdEgEaVq0sJgrTZfgpuBZQ0PYHrTzancWuVYcUw3)36EAq)PY0ueuqtNohrxiIUJLPBTCFjqKCJoRIaQZwF52BoVxTE85cgaJxUynZ3HnikJ8iM0E2Gu8eJ0XzAYJPGU2PMPGFOJZR2zmDdYrTykh72SnZBIjeL2jIWKYHhv6MZ7dHWJoztLOztkbE8OuKhvfjqQxJDTy2RU7tCZS3(kKrOiDGViYwqqYdg8XU5RSDJYSlZcdWrcB18s3SzDD5YSlZmhWt2F2wnYndNLBIMDzc2gmYUNv9UkVXOQMRLM88nmqRvCA4NCQjNDhq2oBDWTysbARm34kf7CZxEcAwpP)kodsnMRMMHHeycGiyDurAz(SqEQowKEA5MMXq7q6AsAGsiw5N59C2Ma(NBioC45rtK4xPpNp4jYNoHTF40T38MMJ(o)dXskaZ1r)Bugc1r6u9xDLoCAZCmRmrfniHRK1O024Vb0NlFtF(zueFPVJWJr2aFubOSNuLX7RneXffS4RLWA5vFkKQc63C2QG7IsZoLo(71F1VWVEqvyQQ7(g(jx(9Pfp)DRRVxAEtJo4NB6CDR(zZw5lMTN0EMs9GbJf9cwTchIH4bP4ZbjCmv7oqM0vIVPZBs)MM664AJovmGFfjXp(4C20MoB4E5MENGIr5s2UHwPVm5QPIUOD0Umr(R4kgpi7TIWlTZPBHrlN1UKhhdH3vwd9TB39KYeqDdRFVhbh3tOp2m0hQ5SNSBM9a30HJO9fr1TFThmSwpgk3OW91)6(IYDCPp0FeUtGDir3EpqUr29Y9dFXOUDHOpOtN(5CWWL(nk2qKEkIvpTufgYtGnJLuvQB7w1t(7fx86u0ojG1itXwTu8kmAGOTZKxNk36qyI4K1jnWUf5vUEvyiDgktB824QIxLaNrJg4ZFWyk80)DIWwnPpQUy5xX(Cb9vWJUilex0rOTIfU2kmhprzX0EQw3BkNX1bvWIrakSf9IF0I0sfnYMTF5RUz)brCFNMz5OnAl6HACTkXHTWqrgPqKxFDJTG(m6YcYqhqqUZBtPjcyix6wPVnNnxZJWCto)J(sbRUPFKx777w0YpANyr62UGPhCYbFicBwqDr44To3PTOEQIMuHHYnR23(MO03sEPpxxwrcz(5blfYhlv)uNRh9dxbqRWqHTTJbRCV9FAOjCuHHsNRQvgMuA40REij0gwLhqG2Fv)10AP6vBzlxB5x7K)KihQBV53RRRnmqj8TQOKW018Dp(x6AX3Y5OINKx)5N)4rVCBZhMzXvximEd9WBmUs86aB7MZFu1owDZALby12)IgX9oRJpAZsp(egM7YczSnZ7wmYJ3YWjbwrvbxUteKsXWIt)PFdesFLNjLdCs2CfbbuODsQJML(LP7bkSv22tSCFJsy3jpA7gfv1U6oHW)D(9qyf2ag8JbUX4sUoyqjYZWyjsBld3kUR(0VDCTPk2HEjho2Yve15(WqjxBFuWP2d5JdVga27U4ogR7LZoQL7j5vuI164exTORd(NyWkrtUCz)KXO56Jbawm3YC8EgAnTZJTv9v8m(0z(LMcnr(ZyhUsqWQKPakTK6PsWAX706RyRU(s8MKKCZ6k6R4hXgmbTcGMbClB5gGqvdT0TolkBI)zWLFJEI9KGeVVGEYpsYSUIsXu9xpDABoigVYMMZkiDE1B34CG7tlUNNuYVWvd2Sj(bARAcEODQwj5N2rUqglBQOX4OQyrT1p4VvTQ(Z(lHYTBevNtfPeYTFtKA3ESKVRPoPeWvH9e2ECRGwlQ2xZlVHA2H4kcrGhw1ZlPcDbNp2nMqmSwIsbLQfrGN09jSR0wkHLSKSXX20)lN(uptFRnMC7PQ4rOazgRRlOgcsckAnnDqJZDo6zKOu3CC0oKdgHHDrupwpfyO4bzbdYYoW)A0Zgxlq7KgzvtQmQ61ZZtJlXCq(gfMJj7w07EDR7G8terbqoSa8ROx80jEoF6uBx475qLlwmGUMajrIHGCq0doPDbng0PQgZnMiSM4mMDFKMgj4ThCo46eX2ywBnoBA77eS0UIy1vIHhQ0GFLMNwN1rukEeBr)J)Hwek80)upDbTdzwKFADgiU(nR6Di70MehKaO0941ruYMyRKQTfTJ)UAml4ejs0m3ZpUv43jgXui4wGNxWWk(OYqnS(7jdY9eZil4bo81uISLGiysrUrRC9tlLMTWdQYqIpB19k)tAdezS(e7v9r9YWZ5IFl4N6QvvFjUj5VktxlrWzIU1rAL(rr4QNrciIOB4SYC8gQvCH6N8qXkHVAfKGZWOLr4cb)QgDpsd4Pcpe20KPZQsZ8LyC1EUJRYycHCmr(9SQsy5uPlR4tLmvtWb78MpUYZAFZ5e)0nmr3Qj)uurCKTv7W1mj5YLqaE5gx8I54jQcaeffnUkirmVifHjSpxywZIiEAL0NucAFxncj1HqRr3jQkQ(UUNapIsVUD1DyR2k8u5qvtBlXwoh0D6ypcgBFAbQ2WX202CBUOaBgFUt7UiUdj143t(eYBDvJUNhrkEymf7Ev5FmHCnRiLVBFlAwd)A3yz9xZb(E88Ym6ZFquYc67MbMo46GCIU8ZLtxSc1pLddvuyeR6BYvfCjCcFOvIgAN46boJfQi70dmUFOAKoI4Tfek3i(FTg7QhQpuFfj1d5pYLrDsrjeF2)Lq9DTj79ef0hteg6p(WMtd7eHiQnXSLMuerpbPl5mB51eU50N3avbb5M)WUGcPeFjOIkmiYVlvMoYlQI8bV1Ypwu121QVL(aLq4y)G0FMsEMQ7auBfNMRonBegimTfJm(3GaUN0k0pIVTkIWhLxvZNavWBX42El9wUNCVlHDxe5apgQC6lvnivkGIM0NfKk5cfoYftX80sHaiYlTfPcJp4FqOAYGlXRYHIIfzikoQESNTGg6k0m6y2zs7fTBy5gopO9OWs8FtTzYT3U9p1wCcBfGsPp1kMJxX0oJ)vpJuJYi2r8yMA9WMzoEmDVASzbLs8qmbpAU)ignelZxB2e08fTrpobg)Y20WYk)D)qqr3QXLKNFtj1IgA))r(qHOlaXWPHB63lh)CjRZvBh8NGZTHPRNh0XrbRoclNv5h2g8A2mo6ow1dOjnEkKtXlkG0LZYdG(dYczkfn)swmWNSokP(S)ReRFHJyBy6b8389naO0GglOpO9SyP6NkUkLaWj5RwxnSW2DqaqjWcwLduXHzyH2XcxLe9VkL4yT2IcpoDqMryTuRySz4aOCqGKzfuqE68oDFDDijrlukmJ1uasVNKKA(vgfgw3qLGlyuwGuW31cWCfyg2ltx8m(bk33lO)GZO4ZGysBgiBkTtssJOteJqGMH0DmlifxrxqNMfm73ZcHn)rNHJOcRSPuHXl5sx6p0z6XZ)I(H2XyAMvgNoZjNRtSOHiB6PlP(e6o3Kak2K2pcb94jU)vJ4FgZ3(4mK14L2jdLJ2OL8cVSARDaxTBVvNz4mmiHEQtguNYNpQl7ygC4sFPbZanpDTzZwlJzBlE(vvjlrmP55IVQg5mAYLnlU8y0qrzt1nYTEX7XyBp3GDPEz)T12Mt)gfTQsXinIBUBJGakly9gGhrQBQKrDTIEfPwWewQv12RAaSSdUs66vY)CRcCxzbDOZcBRknwjaMgvtixBq2QyosOApcZPNze6rumDTDlhez1EKTJ)el)DlQlp2CGkv27Sf35VkwGEsVBO(69i1wESc)pAg6AC6uPULDCgQ7Xk7WMkoRftTx5oRv196vVnDuCTwdT9(qvzxByNwP5nnE)fS36e26OElX5z7Ct1mqgIBARISufAgT8UdR2CpE(Ct4iTg8cM213PxjlUHJ1YD0C4)KmPqXP5xDrvzmRBxwLTSsUH70anhvd4H2ObhLSxhXH(IMldMAXrUJiD7arFUZazlnsto3QxHscQAI5FHHI)RQz)jeutEf(9)GcQ5y174khb1KeLRhGJQVUC5TAEE7OHySKJ)Fy4Rj(IUQV6n2PRa7wEZQyILIhFMFNZIv9sjR68iyH6IW0Gt7a7jDiXSCBwhTSlzBk5U7dc9HyEVJUnP5szrK87ROnc80urBPNW)S1tV6Vrx)wMUkGjRlSUhmdltORVQRZWs9oMpgbETH45zt)KFhLBktIIuq2uenv5zmpnnrP621Zv8b4SCB76SuWSRvWwyjDW)YXRw9nv3Fmlb1xPalQUDjA3ZAC3sEQ6c4AdHEYpS7FdqGuE22KfLMrfpaE4EQNDiMUj7TKlI3gNohp1E3diSfyOXk5NYp(6INWxrP7Ix77Ljrvf)Anu)1p2AVHyP(UgnQ2RKIBdxCkLmAdibN30p)1ieplSSEB1Twqo)CyauUrHrBeEgKUS9jf7u7x(RsRLwxLc04X33oRzxX4fiR1AK31fiRJb8foVnwTM6Hu73gRogSx66Qn1wiWY7(Qn1XqoT77ju7xGeDFo4ExLuMniftgVshevedjB9euaestPF63O(LGIHbE67Rp6HkMAku9ODhjoq(gOxtHIJqRzfy(iBMN7ljlaAF5m2koB2AR)yWR(PA0hQXYo6JADLwpdlAZwe1bQ0Eeu6gQDPyuhFAIsZDSo60mgoZDTPOMJ7CR4wOoagp9CvGS(gw0XHt2QXrANBk1liXwrXqfGDFoSutHH1Z5QB9EVVrvu9bhx68MWv8Pg5n3A8cuuCU7A3gtgJ4shxROIy4sbuFMh58iKkDKeB5G5H5mI2ranDF(x)7uHnZOcBV(aTIblsrhUphs2h1LvRWxz9WS6M08kZLJjsQnru)41gsXR08B5AB3EdPS54Ofm(r3cu5ZJKf)ybGuUXHWsGQ64KY1ZPdw1CSY9ME655iCrcrQlrvwXbduzCb3KOcwEHK44pm(7g6Gs)y)kDYUkC2tpxumLTc(LF4ZxVyre(BOnR)67fMZMxH7yFUilOXZc(bT6UGOyCuqsoavXI40CDsFj2EKDnbFl38zftE9Tct2ZsC1h8VLsx1AicLdqGveTOKt5Ntj(veahFJMkPWr6pZMPOeQQVsD(8li3GIRnlWssvJ5rkWLk7qYz41Dqd7tUGDC8CncgTdBSDDNUIKXal5RwtZCRdqBv7KJEOhbeC2QY1bjPrlOc1Rzk6r4gv9xREy3QDOl(hcaGeyCiqZFBEzyYHCG44znegchZfyjp8bFcfqdB(wyLf5VNuJ)Ii5lVfyhWp7QjmX557EgoBWYGKKIGMgti5R1JsTUXN8OW26SQAAk1hJD96WwrHkRJZ41KVIc2zr1PV8RMzKX9PMTXIQZZOQJZgJ)kgC1YIv4hcPRIw)g6jx)))d]] )


end