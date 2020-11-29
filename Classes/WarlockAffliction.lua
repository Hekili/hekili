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
                if not settings.manage_ds_ticks then return nil end
                return class.auras.drain_soul.tick_time
            end,

            start = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
                removeStack( "decimating_bolt" )
                removeBuff( "malefic_wrath" )

                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,

            tick = function ()
                if not settings.manage_ds_ticks then return end
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
                if legendary.malefic_wrath.enabled then addStack( "malefic_wrath", nil, 1 ) end
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


    spec:RegisterSetting( "manage_ds_ticks", false, {
        name = "Model |T136163:0|t Drain Soul Ticks",
        desc = "If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of " ..
            "other spells.  This is generally not worth it, but is technically more accurate.",
        type = "toggle",
        width = "full"
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


    spec:RegisterPack( "Affliction", 20201128, [[dy0ZEbqiLkEKseTjLWNuQuvJsf5uQOELa1Seq3cuP2Le)saggOIJHkAzGsptG00eiUMsLSnqL4BkrW4uQuoNsLkRdujvZtjQ7HkTpuvoOsKyHOQ6HkrkMOsK0fvIq5Kkrk1kvQAMkrO6MGkj2jO4NkrkzOkrilvPsvEQknvqvFfujf7f4VcnykomPfRKEmktwQUmYMLsFwsgTs50IETKYSH62GSBQ(TIHlfhhujPLd55uA6exxqBhv57OcJhujLoVKQ1RePA(QW(v1aobWdUDviamWchyHdNCc7Uv4eUWzq3fCbCL6ne42OSAAfbUUcrG7sPTfNmjhhCB064r7a4bx7eIye4UjsJfUEabuLYw4AHnqbytOqSk54mK2kbytiwaG7AyILL2oyfC7QqayGfoWcho5e2DRWjCHZGgKLa4ABigagyHl7cC3YENCWk42jldCxY3SuABXjtYXFdCnkcpSA)(L8nWm8iOvc9gy3TaFdSWbw487)9l5BwA2uVISW1)9l5BG73Su6DQ)MBdHXVzj(WQv(9l5BG73Su6DQ)MLkXBcrVbUIwLSYVFjFdC)MLsVt93SIiTgBtDNWVbpvj7nTd6nlvKM(BUtiU87xY3a3VbEoiT2BGROyQnzVz3tBKqe9g8uLS3iZB4yq1Et2(M6t4UpIEduATPx9g9nIIjxEt6Vr2u5nOHJYVFjFdC)MLyUUIP3S7PqnQlVzP02ItMKJBFZseVLO3ikMCP87xY3a3VbEoiTM9nY8gL3K93SIhosV6nlvfvRcRi6nP)gOqSKWTOOksEdhbmVzPU0cE7BcBk)(L8nW9BwAgVtULEJDGO3SuvuTkSIO3SeHOM3Wum2(gzEdI6Hm6nSbQjuujh)nscrLF)s(g4(nxsEJDGO3WumoQmjhpItR8gYfus23iZBSckzYBK5nkVj7VHTrSAPx9gCAf7BKnvEdhJV7lVzLEdIu2g1lGBdAAtmbUl5BwkTT4Kj54VbUgfHhwTF)s(gygEe0kHEdS7wGVbw4alC(9)(L8nlnBQxrw46)(L8nW9Bwk9o1FZTHW43SeFy1k)(L8nW9Bwk9o1FZsL4nHO3axrRsw53VKVbUFZsP3P(BwrKwJTPUt43GNQK9M2b9MLkst)n3jex(9l5BG73aphKw7nWvum1MS3S7PnsiIEdEQs2BK5nCmOAVjBFt9jC3hrVbkT20REJ(grXKlVj93iBQ8g0Wr53VKVbUFZsmxxX0B29uOg1L3SuABXjtYXTVzjI3s0BeftUu(9l5BG73aphKwZ(gzEJYBY(BwXdhPx9MLQIQvHve9M0Fduiws4wuufjVHJaM3SuxAbV9nHnLF)s(g4(nlnJ3j3sVXoq0BwQkQwfwr0BwIquZBykgBFJmVbr9qg9g2a1ekQKJ)gjHOYVFjFdC)MljVXoq0BykghvMKJhXPvEd5ckj7BK5nwbLm5nY8gL3K93W2iwT0REdoTI9nYMkVHJX39L3SsVbrkBJ6LF)VxzsoUT0Gi2aTQc3wch7du6QKJhy2YvsiIp4SyNgskko5rl2znSTTuHsOjruCAJwLHY2KrLWMFVYKCCBPbrSbAvLG5gGnecA8ydj)ELj542sdIyd0QkbZnGkucnjIItB0Qmu2MmkWSLROyYLsfkHMerXPnAvgkBtgvixxXu)3Rmjh3wAqeBGwvjyUbWtrPUIPaDfI42hXgrK2RhipfhsCvMK8OyFKcBqOWgjhNp4SqzsYJI9rkA1415doluMK8OyFKsOBfDftrTTfNmjhNp4S40oIIjxk2SzB8ioBPc56kM6hhktsEuSpsXMnBJhXzlXhCoV4uFKsZM6YafTPxfIvuk1lsYQLE1XXoIIjxknBQldu0MEviwrPuVqUUIP(5FVYKCCBPbrSbAvLG5gqOLIPqqb6keXvx62nfP2y74sCAJndhe63Rmjh3wAqeBGwvjyUbyjQhN2iBqOWgjhpWSLRTHW4OOOksSflr940gzdcf2i54rDi(4g0f7qWvdZMgQx4eUS7ckNb53Rmjh3wAqeBGwvjyUbSPHU87vMKJBlniInqRQem3aSBAF4iUoyjWSL7oIIjxkBAOlfY1vm1xyBimokkQIeBXsupoTr2GqHnsoEuhA5GUyhcUAy20q9cNWLDxq5mi)(F)s(MLyW1sSqH6VH4rO6Vrsi6nYg9gLjd6nP9nkpnX6kMk)ELj54wU2gcJJ4Hv73Rmjh3gm3a6eVjefH0QK97vMKJBdMBamfJJktYXJ40kb6keXvhkqRGsMWLZaZwUktsEuKCckjlFb93Rmjh3gm3aA2uxgOOn9QqSIsPEGzlxjHi(ckC(9ktYXTbZnaMIXrLj54rCALaDfI42vuTkSIOydIAcmB5EIn8ixDPWJCzRoArFKsc1qEp9Qitf1kOPzJI9rksYQLE1c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iLMn1LbkAtVkeROuQxqeKMULpypo2rum5sPztDzGI20RcXkkL6fY1vm1pF(44eB4rU6sXZQnj2Q0I(if7eIJOrksYQLE1c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iLMn1LbkAtVkeROuQxqeKMULpypo2rum5sPztDzGI20RcXkkL6fY1vm1pF(440j2WJC1LItm0Ghu)4Gn8ixDPuRokv)4Gn8ixDP4JtNx0hP0SPUmqrB6vHyfLs9IKSAPxTOpsPztDzGI20RcXkkL6febPPBxg2Z)ELj542G5gGwnE9aZwU9rkA141licst3UCq(9ktYXTbZnaTA86bYQZWuuuufjwUCgy2Y9KYKKhfjNGsYYhNNxCQpsrRgVEbrqA62LdY5FVYKCCBWCdytdD53Rmjh3gm3aykghvMKJhXPvc0viIBxr1QWkIIniQjWSL7jLjjpksobLKLpyxWgEKRUu4rUSvhT4eBgCF4Wljud590RImvuRGMMnQGiTx)4OpsjHAiVNEvKPIAf00SrX(ifjz1sV68It9rknBQldu0MEviwrPuVijRw6vhh7ikMCP0SPUmqrB6vHyfLs9c56kM6NpFCCszsYJIKtqjz5d2fNydpYvxkoXqdEq9Jd2WJC1LsT6Ou9Jd2WJC1LIpoDEXP(iLMn1LbkAtVkeROuQxKKvl9QJJDeftUuA2uxgOOn9QqSIsPEHCDft9ZNpooPmj5rrYjOKS8b7c2WJC1LINvBsSvPfNyZG7dhEXoH4iAKcI0E9JJ(if7eIJOrksYQLE15fN6JuA2uxgOOn9QqSIsPErswT0Roo2rum5sPztDzGI20RcXkkL6fY1vm1pF(3Rmjh3gm3aSe1JtBKniuyJKJhy2YvzsYJIKtqjz5d2fIIjxk2HJOSrrlrDBHCDft9f70hPyjQhN2iBqOWgjhVijRw6vl2j9yloR2KFVYKCCBWCdWsupoTr2GqHnsoEGzlxLjjpksobLKLpyxikMCPyZMTXJ4SLkKRRyQVyN(iflr940gzdcf2i54fjz1sVAXoPhBXz1MSOpsHniuyJKJxqeKMUD5G87vMKJBdMBa8smffnDjWSL7j7eIJ2nf15JZJdLjjpksobLKLpypVGndUpC4fBie04XUIQvHvevqeKMULpoH93Rmjh3gm3acDRORykQTT4Kj54bMTC7JucDRORykQTT4Kj54febPPBxoi)ELj542G5gGnB2gpIZwkWSLBFKInB2gpIZwQGiinD7Yb53Rmjh3gm3aSzZ24rC2sbYQZWuuuufjwUCgy2Y9KYKKhfjNGsYYhNNxCQpsXMnBJhXzlvqeKMUD5GC(3Rmjh3gm3aykghvMKJhXPvc0viIlB4rU6sGzl3DydpYvxkoXqdEq9FVYKCCBWCdGniuyJKJhy2YvzsYJIKtqjzxoiW9jrXKlf7Wru2OOLOUTqUUIP(XHOyYLInB2gpIZwQqUUIP(5f9rkSbHcBKC8cIG00Tld7VxzsoUnyUbWgekSrYXdKvNHPOOOksSC5mWSL7jLjjpksobLKD5Ga3NeftUuSdhrzJIwI62c56kM6hhIIjxk2SzB8ioBPc56kM6NpV4uFKcBqOWgjhVGiinD7YWE(3Rmjh3gm3aA2uxgOOn9QqSIsPEGzlx2WJC1LItm0Ghu)4Gn8ixDP4z1MeBv64Gn8ixDPuRokv)4Gn8ixDP4Jt)ELj542G5gaKIP2KfrAJeIOaZwU2jehTBkQZxq(9ktYXTbZnaMIXrLj54rCALaDfI42vuTkSIOydIAcmB5EIn8ixDPWJCzRoAXj2m4(WHxsOgY7PxfzQOwbnnBubrAV(XrFKsc1qEp9Qitf1kOPzJI9rksYQLE15fSzW9HdVydHGgp2vuTkSIOcIG00Tld7It9rknBQldu0MEviwrPuVGiinDlFWECSJOyYLsZM6YafTPxfIvuk1lKRRyQF(8XXPtSHh5QlfNyObpO(XbB4rU6sPwDuQ(XbB4rU6sXhNoVGndUpC4fBie04XUIQvHvevqeKMUDzyxCQpsPztDzGI20RcXkkL6febPPB5d2JJDeftUuA2uxgOOn9QqSIsPEHCDft9ZNpooXgEKRUu8SAtITkT4eBgCF4Wl2jehrJuqK2RFC0hPyNqCensrswT0RoVGndUpC4fBie04XUIQvHvevqeKMUDzyxCQpsPztDzGI20RcXkkL6febPPB5d2JJDeftUuA2uxgOOn9QqSIsPEHCDft9ZN)9ktYXTbZnGUIQfTtioWSLlBgCF4Wl2qiOXJDfvRcRiQGiinDlFscrrzI9K(9ktYXTbZnaMIXrLj54rCALaDfI4Mcb97vMKJBdMBamfJJktYXJ40kb6keX1sbAfuYeUCgy2YTtRHTTf7M2hoIe0kszuXkkR2YNGfUvMKJxSBAF4iUoyPKESfNvBY5JJoTg22wSBAF4isqRiLrfebPPBxoO)ELj542G5gaKIP2KfrAJeIOaZwU9rkjud590RImvuRGMMnk2hPijRw6v)ELj542G5gaKIP2KfrAJeIOaZwU9rk2jehrJuKKvl9QFVYKCCBWCdasXuBYIiTrcruGzlxrXKlLMn1LbkAtVkeROuQxixxXuFXP(iLMn1LbkAtVkeROuQxKKvl9QJd7eIJ2nf15lOhhscrrzI9KwMndUpC4LMn1LbkAtVkeROuQxqeKMU98VxzsoUnyUbaPyQnzrK2iHikWSLROyYLID4ikBu0su3wixxXu)3Rmjh3gm3a6in9ioBPaZwURHTTL0jEPORyk2jO0sfROSA8fe4CCSg22wsN4LIUIPyNGslvcBwijefLj2tA5G87vMKJBdMBamfJJktYXJ40kb6keXLn8ixD53Rmjh3gm3a0QXRhy2YfrTiYUPRy63Rmjh3gm3a0QXRhiRodtrrrvKy5YzGzl3tktsEuKCckjlFCEEXje1Ii7MUIPZ)ELj542G5gaBqOWgjhpWSLlIArKDtxX0cLjjpksobLKD5Ga3NeftUuSdhrzJIwI62c56kM6hhIIjxk2SzB8ioBPc56kM6N)9ktYXTbZnGq3k6kMIABlozsoEGzlxe1Ii7MUIPFVYKCCBWCdWMnBJhXzlfy2YfrTiYUPRy63Rmjh3gm3aSzZ24rC2sbYQZWuuuufjwUCgy2Y9KYKKhfjNGsYYhNNxCcrTiYUPRy68VxzsoUnyUbWgekSrYXdKvNHPOOOksSC5mWSL7jLjjpksobLKD5Ga3NeftUuSdhrzJIwI62c56kM6hhIIjxk2SzB8ioBPc56kM6NpV4eIArKDtxX05FVYKCCBWCdOJ00J2jehy6cHqHncxo)9ktYXTbZna7M2hoIRdw(9)ELj542Ioe3Mn1LbkAtVkeROuQ)7vMKJBl6qbZnGnn0LFVYKCCBrhkyUbWumoQmjhpItReORqe3UIQvHvefBqutGzl3tSHh5QlfEKlB1rl6JusOgY7PxfzQOwbnnBuSpsrswT0RwWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0SPUmqrB6vHyfLs9cIG00T8b7XXoIIjxknBQldu0MEviwrPuVqUUIP(5ZhhNydpYvxkEwTjXwLw0hPyNqCensrswT0RwWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0SPUmqrB6vHyfLs9cIG00T8b7XXoIIjxknBQldu0MEviwrPuVqUUIP(5ZhhNoXgEKRUuCIHg8G6hhSHh5QlLA1rP6hhSHh5QlfFC68I(iLMn1LbkAtVkeROuQxKKvl9Qf9rknBQldu0MEviwrPuVGiinD7YWE(3Rmjh3w0HcMBawI6XPnYgekSrYXdmB5kkMCPyhoIYgfTe1TfY1vm1xWupAjQ)7vMKJBl6qbZnalr940gzdcf2i54bMTC3rum5sXoCeLnkAjQBlKRRyQVyN(iflr940gzdcf2i54fjz1sVAXoPhBXz1MSOpsHniuyJKJxqulISB6kM(9ktYXTfDOG5gGwnE9az1zykkkQIelxodmB5Qmj5rX(ifTA86lhKFVYKCCBrhkyUbOvJxpqwDgMIIIQiXYLZaZwUktsEuSpsrRgVoFCdYce1Ii7MUIPf9rkA141lsYQLE1VxzsoUTOdfm3acDRORykQTT4Kj54bMTCvMK8OyFKsOBfDftrTTfNmjhNlCooKKvl9QfiQfr2nDft)ELj542IouWCdi0TIUIPO22ItMKJhiRodtrrrvKy5YzGzl3DKKvl9Qfn8AeftUuqkuJ6suBBXjtYXTfY1vm1xOmj5rX(iLq3k6kMIABlozso(Yb93Rmjh3w0HcMBa8smffnDjWSLRDcXr7MI68X5VxzsoUTOdfm3aykghvMKJhXPvc0viIlB4rU6sGwbLmHlNbMTC3Hn8ixDP4edn4b1)9ktYXTfDOG5gatX4OYKC8ioTsGUcrC7kQwfwruSbrnbMTCpXgEKRUu4rUSvhT4eBgCF4Wljud590RImvuRGMMnQGiTx)4OpsjHAiVNEvKPIAf00SrX(ifjz1sV68c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iLMn1LbkAtVkeROuQxqeKMULpypo2rum5sPztDzGI20RcXkkL6fY1vm1pF(440j2WJC1LItm0Ghu)4Gn8ixDPuRokv)4Gn8ixDP4JtNxWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0SPUmqrB6vHyfLs9cIG00T8b7XXoIIjxknBQldu0MEviwrPuVqUUIP(5ZhhNydpYvxkEwTjXwLwCIndUpC4f7eIJOrkis71po6JuStioIgPijRw6vNxWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0SPUmqrB6vHyfLs9cIG00T8b7XXoIIjxknBQldu0MEviwrPuVqUUIP(5Z)ELj542IouWCdOROAr7eIdmB5YMb3ho8InecA8yxr1QWkIkicst3YNKquuMypPFVYKCCBrhkyUbWumoQmjhpItReORqe3uiOFVYKCCBrhkyUbaPyQnzrK2iHikWSLBFKcVetrrtxksYQLE1VxzsoUTOdfm3aGum1MSisBKqefy2YTpsXoH4iAKIKSAPxTyhrXKlf7Wru2OOLOUTqUUIP(VxzsoUTOdfm3aGum1MSisBKqefy2YDhrXKlfEjMIIMUuixxXu)3Rmjh3w0HcMBaqkMAtwePnsiIcmB5ANqC0UPOoFb53Rmjh3w0HcMBa2SzB8ioBPaz1zykkkQIelxodmB5EszsYJI9rk2SzB8ioBPL5g0ZloTtFKInB2gpIZwQijRw6vN)9ktYXTfDOG5gqhPPhXzlfy2YDnSTTKoXlfDftXobLwQyfLvJpU7cohhRHTTL0jEPORyk2jO0sLWMfscrrzI9KwEx)ELj542IouWCdOJ00J2je)7vMKJBl6qbZnaMIXrLj54rCALaDfI4YgEKRU87vMKJBl6qbZnGostpIZwkWSL7AyBBjDIxk6kMIDckTuXkkRgFC3fCoowdBBlPt8srxXuStqPLkHnlKeIIYe7jT8UoowdBBlPt8srxXuStqPLkwrz14JBq31I(if7eIJOrksYQLE1VxzsoUTOdfm3a6in9ODcXbMUqiuyJWLZFVYKCCBrhkyUby30(WrCDWYV)3Rmjh3wydpYvx4MqnK3tVkYurTcAA2OaZwUSzW9HdVydHGgp2vuTkSIOcIG00TlZjCooyZG7dhEXgcbnESROAvyfrfebPPB5BxW53Rmjh3wydpYvxcMBaDILqQKEvCDWsGzlx2m4(WHxSHqqJh7kQwfwrubrqA6w(21ItDAnSTTSPHUuqeKMULVGCCSJOyYLYMg6sHCDft9Z)ELj542cB4rU6sWCdWoH4iAKaZwUSzW9HdVydHGgp2vuTkSIOcIG00TlVRJd2m4(WHxSHqqJh7kQwfwrubrqA6w(2fCooyZG7dhEXgcbnESROAvyfrfebPPB5d2DTGnEpmLcBqOWgj9QiMiuHCDft9FVYKCCBHn8ixDjyUbyztik9QOKYg97vMKJBlSHh5QlbZnaogeUZJspIi74QZOFVYKCCBHn8ixDjyUbarqdQECAJ4qw2JDePq2FVYKCCBHn8ixDjyUbSINPhN2OSrrYjO6)ELj542cB4rU6sWCdOkur9u940g1LoHgz73Rmjh3wydpYvxcMBaOSPbtX0J2gLr)ELj542cB4rU6sWCdODyHwQh1LoHsHIRKc97vMKJBlSHh5QlbZnGMqu2wp9Q4kwTYVxzsoUTWgEKRUem3aqK2KEvSfRqKnWSLROOkskBKILTydt4B3GZXHOOkskBKILTydtwgw4CCikQIKIKquuMydtIWch(ccCooAZQnjIiinD7YWcNFVYKCCBHn8ixDjyUbWgNrUGuH6XwScr)ELj542cB4rU6sWCdq2OyOVoHEp2oigfy2YDnSTTGiwnmzTX2bXOcIG00T)ELj542cB4rU6sWCdWYMqu6vrjLn63Rmjh3wydpYvxcMBajud590RImvuRGMMn63Rmjh3wydpYvxcMBa2jehrJey2Y90AyBBjDIxk6kMIDckTuXkkRgFbD3oouMK8Oi5eusw(488VxzsoUTWgEKRUem3a6elHuj9Q46GLaZwUNefvrszJuSSfByYY7cohhTz1MereKMULVDbNZ)(FVYKCCBPROAvyfrXge1WLxIPOOPlbMTCzZG7dhEXgcbnESROAvyfrfebPPBxg2FVYKCCBPROAvyfrXge1em3a6kQw0oH4FVYKCCBPROAvyfrXge1em3aAgjh)3Rmjh3w6kQwfwruSbrnbZnG2erR4z6)ELj542sxr1QWkIIniQjyUbSINPhBdr1)9ktYXTLUIQvHvefBqutWCdyLqwcvl9QFVYKCCBPROAvyfrXge1em3aykghvMKJhXPvc0viIlB4rU6sGwbLmHlNbMTC3Hn8ixDP4edn4b1xWMb3ho8InecA8yxr1QWkIkicst3UmS)ELj542sxr1QWkIIniQjyUbydHGgp2vuTkSIOaZwUktsEuSpsHxIPOOPl8bNJdLjjpk2hP0SPUmqrB6vHyfLsD(GZXHOyYLID4ikBu0su3wixxXu)440oIIjxk8smffnDPqUUIP(IDeftUuA2uxgOOn9QqSIsPEHCDft9Z)(FVYKCCBjfcIBOLIPqq2F)VxzsoUTyjUBAOl)ELj542ILcMBaDKME0oH4atxiekSrIv4zvXC5mW0fcHcBKy2YTtRHTTf7M2hoIe0kszuXkkRgFCd6VxzsoUTyPG5gGDt7dhX1blGlpczZXbWalCGfoCYjSbbC5qrE6vwWDPnuZGeQ)MLWBuMKJ)gCAfB53dU40kwa8GlB4rU6caEamCcGhCjxxXuhWp4YqPqOubx2m4(WHxSHqqJh7kQwfwrubrqA623S8B4eoV544nSzW9HdVydHGgp2vuTkSIOcIG00TVHV3Sl4aUktYXb3eQH8E6vrMkQvqtZgbeamWcGhCjxxXuhWp4YqPqOubx2m4(WHxSHqqJh7kQwfwrubrqA623W3B21Bw8MtVPtRHTTLnn0LcIG00TVHV3eK3CC8MDEJOyYLYMg6sHCDft93CgCvMKJdUDILqQKEvCDWcqaWeua8Gl56kM6a(bxgkfcLk4YMb3ho8InecA8yxr1QWkIkicst3(MLFZUEZXXByZG7dhEXgcbnESROAvyfrfebPPBFdFVzxW5nhhVHndUpC4fBie04XUIQvHvevqeKMU9n89gy31Bw8g249WukSbHcBK0RIyIqfY1vm1bxLj54GRDcXr0iabatqaWdUktYXbxlBcrPxfLu2iWLCDftDa)abaZUaWdUktYXbxogeUZJspIi74QZiWLCDftDa)abadCbap4QmjhhCHiObvpoTrCil7XoIuil4sUUIPoGFGaGzjaGhCvMKJdUR4z6XPnkBuKCcQo4sUUIPoGFGaGz3aWdUktYXb3Qqf1t1JtBux6eAKnWLCDftDa)abaZUdap4QmjhhCrztdMIPhTnkJaxY1vm1b8deamCcha8GRYKCCWTDyHwQh1LoHsHIRKcbUKRRyQd4hiay4Kta8GRYKCCWTjeLT1tVkUIvRaUKRRyQd4hiay4ewa8Gl56kM6a(bxgkfcLk4kkQIKYgPyzl2WK3W3B2n48MJJ3ikQIKYgPyzl2WK3S8BGfoV544nIIQiPijefLj2WKiSW5n89MGaN3CC8M2SAtIicst3(MLFdSWbCvMKJdUisBsVk2IviYceamCgua8GRYKCCWLnoJCbPc1JTyfIaxY1vm1b8deamCgea8Gl56kM6a(bxgkfcLk4Ug22wqeRgMS2y7GyubrqA6wWvzsoo4kBum0xNqVhBheJacago3faEWvzsoo4Aztik9QOKYgbUKRRyQd4hiay4eUaGhCvMKJdUjud590RImvuRGMMncCjxxXuhWpqaWW5saap4sUUIPoGFWLHsHqPcUNEZAyBBjDIxk6kMIDckTuXkkR2B47nbD3EZXXBuMK8Oi5eus23W3B48nNbxLj54GRDcXr0iabadN7gaEWLCDftDa)GldLcHsfCp9grrvKu2iflBXgM8MLFZUGZBooEtBwTjrebPPBFdFVzxW5nNbxLj54GBNyjKkPxfxhSaeGaUDQvdXcaEamCcGhCvMKJdU2gcJJ4HvdCjxxXuhWpqaWalaEWvzsoo42jEtikcPvjdCjxxXuhWpqaWeua8Gl56kM6a(bxgkfcLk4Qmj5rrYjOKSVHV3euW1kOKjay4eCvMKJdUmfJJktYXJ40kGloTs0vicC1HacaMGaGhCjxxXuhWp4YqPqOubxjHO3W3BckCaxLj54GBZM6YafTPxfIvuk1bcaMDbGhCjxxXuhWp4YqPqOub3tVHn8ixDPWJCzRo6nlEtFKsc1qEp9Qitf1kOPzJI9rksYQLE1Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0SPUmqrB6vHyfLs9cIG00TVHV3a7BooEZoVrum5sPztDzGI20RcXkkL6fY1vm1FZ53C(nhhV50BydpYvxkEwTjXwLEZI30hPyNqCensrswT0REZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iLMn1LbkAtVkeROuQxqeKMU9n89gyFZXXB25nIIjxknBQldu0MEviwrPuVqUUIP(Bo)MZV544nNEZP3WgEKRUuCIHg8G6V544nSHh5QlLA1rP6V544nSHh5QlfFC6nNFZI30hP0SPUmqrB6vHyfLs9IKSAPx9MfVPpsPztDzGI20RcXkkL6febPPBFZYVb23CgCvMKJdUmfJJktYXJ40kGloTs0vicC7kQwfwruSbrnabadCbap4sUUIPoGFWLHsHqPcU9rkA141licst3(MLFtqaxLj54GRwnEDGaGzjaGhCjxxXuhWp4QmjhhC1QXRdUmukekvW90BuMK8Oi5eus23W3B48nNFZI3C6n9rkA141licst3(MLFtqEZzWLvNHPOOOksSay4eiay2na8GRYKCCWDtdDbCjxxXuhWpqaWS7aWdUKRRyQd4hCzOuiuQG7P3Omj5rrYjOKSVHV3a7Bw8g2WJC1LcpYLT6O3S4nNEdBgCF4Wljud590RImvuRGMMnQGiTx)nhhVPpsjHAiVNEvKPIAf00SrX(ifjz1sV6nNFZI3C6n9rknBQldu0MEviwrPuVijRw6vV544n78grXKlLMn1LbkAtVkeROuQxixxXu)nNFZ53CC8MtVrzsYJIKtqjzFdFVb23S4nNEdB4rU6sXjgAWdQ)MJJ3WgEKRUuQvhLQ)MJJ3WgEKRUu8XP3C(nlEZP30hP0SPUmqrB6vHyfLs9IKSAPx9MJJ3SZBeftUuA2uxgOOn9QqSIsPEHCDft93C(nNFZXXBo9gLjjpksobLK9n89gyFZI3WgEKRUu8SAtITk9MfV50ByZG7dhEXoH4iAKcI0E93CC8M(if7eIJOrksYQLE1Bo)MfV50B6JuA2uxgOOn9QqSIsPErswT0REZXXB25nIIjxknBQldu0MEviwrPuVqUUIP(Bo)MZGRYKCCWLPyCuzsoEeNwbCXPvIUcrGBxr1QWkIIniQbiay4eoa4bxY1vm1b8dUmukekvWvzsYJIKtqjzFdFVb23S4nIIjxk2HJOSrrlrDBHCDft93S4n78M(iflr940gzdcf2i54fjz1sV6nlEZoVj9yloR2eWvzsoo4AjQhN2iBqOWgjhhiay4Kta8Gl56kM6a(bxgkfcLk4Qmj5rrYjOKSVHV3a7Bw8grXKlfB2SnEeNTuHCDft93S4n78M(iflr940gzdcf2i54fjz1sV6nlEZoVj9yloR2K3S4n9rkSbHcBKC8cIG00TVz53eeWvzsoo4AjQhN2iBqOWgjhhiay4ewa8Gl56kM6a(bxgkfcLk4E6n2jehTBkQ)g(EdNV544nktsEuKCckj7B47nW(MZVzXByZG7dhEXgcbnESROAvyfrfebPPBFdFVHtybxLj54GlVetrrtxacagodkaEWLCDftDa)GldLcHsfC7JucDRORykQTT4Kj54febPPBFZYVjiGRYKCCWn0TIUIPO22ItMKJdeamCgea8Gl56kM6a(bxgkfcLk42hPyZMTXJ4SLkicst3(MLFtqaxLj54GRnB2gpIZwciay4Cxa4bxY1vm1b8dUktYXbxB2SnEeNTe4YqPqOub3tVrzsYJIKtqjzFdFVHZ3C(nlEZP30hPyZMTXJ4SLkicst3(MLFtqEZzWLvNHPOOOksSay4eiay4eUaGhCjxxXuhWp4YqPqOub3DEdB4rU6sXjgAWdQdUktYXbxMIXrLj54rCAfWfNwj6kebUSHh5QlabadNlba8Gl56kM6a(bxgkfcLk4Qmj5rrYjOKSVz53eK3a3V50BeftUuSdhrzJIwI62c56kM6V544nIIjxk2SzB8ioBPc56kM6V58Bw8M(if2GqHnsoEbrqA623S8BGfCvMKJdUSbHcBKCCGaGHZDdap4sUUIPoGFWvzsoo4YgekSrYXbxgkfcLk4E6nktsEuKCckj7Bw(nb5nW9Bo9grXKlf7Wru2OOLOUTqUUIP(BooEJOyYLInB2gpIZwQqUUIP(Bo)MZVzXBo9M(if2GqHnsoEbrqA623S8BG9nNbxwDgMIIIQiXcGHtGaGHZDhaEWLCDftDa)GldLcHsfCzdpYvxkoXqdEq93CC8g2WJC1LINvBsSvP3CC8g2WJC1LsT6Ou93CC8g2WJC1LIpobUktYXb3Mn1LbkAtVkeROuQdeamWcha8Gl56kM6a(bxgkfcLk4ANqC0UPO(B47nbbCvMKJdUqkMAtwePnsiIacagy5eap4sUUIPoGFWLHsHqPcUNEdB4rU6sHh5YwD0Bw8MtVHndUpC4LeQH8E6vrMkQvqtZgvqK2R)MJJ30hPKqnK3tVkYurTcAA2OyFKIKSAPx9MZVzXByZG7dhEXgcbnESROAvyfrfebPPBFZYVb23S4nNEtFKsZM6YafTPxfIvuk1licst3(g(EdSV544n78grXKlLMn1LbkAtVkeROuQxixxXu)nNFZ53CC8MtV50BydpYvxkoXqdEq93CC8g2WJC1LsT6Ou93CC8g2WJC1LIpo9MZVzXByZG7dhEXgcbnESROAvyfrfebPPBFZYVb23S4nNEtFKsZM6YafTPxfIvuk1licst3(g(EdSV544n78grXKlLMn1LbkAtVkeROuQxixxXu)nNFZ53CC8MtVHn8ixDP4z1MeBv6nlEZP3WMb3ho8IDcXr0ifeP96V544n9rk2jehrJuKKvl9Q3C(nlEdBgCF4Wl2qiOXJDfvRcRiQGiinD7Bw(nW(MfV50B6JuA2uxgOOn9QqSIsPEbrqA623W3BG9nhhVzN3ikMCP0SPUmqrB6vHyfLs9c56kM6V58BodUktYXbxMIXrLj54rCAfWfNwj6kebUDfvRcRik2GOgGaGbwybWdUKRRyQd4hCzOuiuQGlBgCF4Wl2qiOXJDfvRcRiQGiinD7B47nscrrzI9KaxLj54GBxr1I2jedeamWgua8Gl56kM6a(bxLj54GltX4OYKC8ioTc4ItReDfIa3uiiGaGb2GaGhCjxxXuhWp4YqPqOub3oTg22wSBAF4isqRiLrfROSAVz53C6nW(g4(nktYXl2nTpCexhSusp2IZQn5nNFZXXB60AyBBXUP9HJibTIugvqeKMU9nl)MGcUwbLmbadNGRYKCCWLPyCuzsoEeNwbCXPvIUcrGRLacagy3faEWLCDftDa)GldLcHsfC7JusOgY7PxfzQOwbnnBuSpsrswT0RaxLj54GlKIP2KfrAJeIiGaGbw4caEWLCDftDa)GldLcHsfC7JuStioIgPijRw6vGRYKCCWfsXuBYIiTrcreqaWa7saap4sUUIPoGFWLHsHqPcUIIjxknBQldu0MEviwrPuVqUUIP(Bw8MtVPpsPztDzGI20RcXkkL6fjz1sV6nhhVXoH4ODtr93W3Bc6BooEJKquuMypP3S8ByZG7dhEPztDzGI20RcXkkL6febPPBFZzWvzsoo4cPyQnzrK2iHiciayGD3aWdUKRRyQd4hCzOuiuQGROyYLID4ikBu0su3wixxXuhCvMKJdUqkMAtwePnsiIacagy3Da4bxY1vm1b8dUmukekvWDnSTTKoXlfDftXobLwQyfLv7n89MGaN3CC8M1W22s6eVu0vmf7euAPsyZBw8gjHOOmXEsVz53eeWvzsoo42rA6rC2sabatqHdaEWLCDftDa)GRYKCCWLPyCuzsoEeNwbCXPvIUcrGlB4rU6cqaWeuobWdUKRRyQd4hCzOuiuQGlIArKDtxXe4QmjhhC1QXRdeambfwa8Gl56kM6a(bxLj54GRwnEDWLHsHqPcUNEJYKKhfjNGsY(g(EdNV58Bw8MtVbrTiYUPRy6nNbxwDgMIIIQiXcGHtGaGjObfap4sUUIPoGFWLHsHqPcUiQfr2nDftVzXBuMK8Oi5eus23S8BcYBG73C6nIIjxk2HJOSrrlrDBHCDft93CC8grXKlfB2SnEeNTuHCDft93CgCvMKJdUSbHcBKCCGaGjObbap4sUUIPoGFWLHsHqPcUiQfr2nDftGRYKCCWn0TIUIPO22ItMKJdeambDxa4bxY1vm1b8dUmukekvWfrTiYUPRycCvMKJdU2SzB8ioBjGaGjOWfa8Gl56kM6a(bxLj54GRnB2gpIZwcCzOuiuQG7P3Omj5rrYjOKSVHV3W5Bo)MfV50BqulISB6kMEZzWLvNHPOOOksSay4eiayc6saap4sUUIPoGFWvzsoo4YgekSrYXbxgkfcLk4E6nktsEuKCckj7Bw(nb5nW9Bo9grXKlf7Wru2OOLOUTqUUIP(BooEJOyYLInB2gpIZwQqUUIP(Bo)MZVzXBo9ge1Ii7MUIP3CgCz1zykkkQIelagobcaMGUBa4b30fcHcBeWLtWvzsoo42rA6r7eIbxY1vm1b8deambD3bGhCvMKJdU2nTpCexhSaUKRRyQd4hiabCBqeBGwvbapagobWdUKRRyQd4hCzOuiuQGRKq0B47nW5nlEZoVPHKIItE0Bw8MDEZAyBBPcLqtIO40gTkdLTjJkHnGRYKCCWTLWX(aLUk54abadSa4bxLj54GRnecA8ylH3cDHqGl56kM6a(bcaMGcGhCjxxXuhWp4YqPqOubxrXKlLkucnjIItB0Qmu2MmQqUUIPo4QmjhhCRqj0KikoTrRYqzBYiGaGjia4bxY1vm1b8dUtd4AjbCvMKJdU8uuQRycC5P4qcCvMK8OyFKcBqOWgjh)n89g48MfVrzsYJI9rkA141FdFVboVzXBuMK8OyFKsOBfDftrTTfNmjh)n89g48MfV50B25nIIjxk2SzB8ioBPc56kM6V544nktsEuSpsXMnBJhXzl9g(EdCEZ53S4nNEtFKsZM6YafTPxfIvuk1lsYQLE1BooEZoVrum5sPztDzGI20RcXkkL6fY1vm1FZzWLNIIUcrGBFeBerAVoqaWSla8Gl56kM6a(bxxHiWvx62nfP2y74sCAJndhecCvMKJdU6s3UPi1gBhxItBSz4GqabadCbap4sUUIPoGFWLHsHqPcU2gcJJIIQiXwSe1JtBKniuyJKJh1HEdFCFtqFZI3SZBi4QHztd1l6s3UPi1gBhxItBSz4GqGRYKCCW1supoTr2GqHnsooqaWSeaWdUktYXb3nn0fWLCDftDa)abaZUbGhCjxxXuhWp4YqPqOub3DEJOyYLYMg6sHCDft93S4n2gcJJIIQiXwSe1JtBKniuyJKJh1HEZYVjOVzXB25neC1WSPH6fDPB3uKAJTJlXPn2mCqiWvzsoo4A30(WrCDWcqac4QdbGhadNa4bxLj54GBZM6YafTPxfIvuk1bxY1vm1b8deamWcGhCvMKJdUBAOlGl56kM6a(bcaMGcGhCjxxXuhWp4YqPqOub3tVHn8ixDPWJCzRo6nlEtFKsc1qEp9Qitf1kOPzJI9rksYQLE1Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0SPUmqrB6vHyfLs9cIG00TVHV3a7BooEZoVrum5sPztDzGI20RcXkkL6fY1vm1FZ53C(nhhV50BydpYvxkEwTjXwLEZI30hPyNqCensrswT0REZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iLMn1LbkAtVkeROuQxqeKMU9n89gyFZXXB25nIIjxknBQldu0MEviwrPuVqUUIP(Bo)MZV544nNEZP3WgEKRUuCIHg8G6V544nSHh5QlLA1rP6V544nSHh5QlfFC6nNFZI30hP0SPUmqrB6vHyfLs9IKSAPx9MfVPpsPztDzGI20RcXkkL6febPPBFZYVb23CgCvMKJdUmfJJktYXJ40kGloTs0vicC7kQwfwruSbrnabatqaWdUKRRyQd4hCzOuiuQGROyYLID4ikBu0su3wixxXu)nlEdt9OLOo4QmjhhCTe1JtBKniuyJKJdeam7cap4sUUIPoGFWLHsHqPcU78grXKlf7Wru2OOLOUTqUUIP(Bw8MDEtFKILOECAJSbHcBKC8IKSAPx9MfVzN3KESfNvBYBw8M(if2GqHnsoEbrTiYUPRycCvMKJdUwI6XPnYgekSrYXbcag4caEWLCDftDa)GRYKCCWvRgVo4YqPqOubxLjjpk2hPOvJx)nl)MGaUS6mmfffvrIfadNabaZsaap4sUUIPoGFWvzsoo4QvJxhCzOuiuQGRYKKhf7Ju0QXR)g(4(MG8MfVbrTiYUPRy6nlEtFKIwnE9IKSAPxbUS6mmfffvrIfadNabaZUbGhCjxxXuhWp4YqPqOubxLjjpk2hPe6wrxXuuBBXjtYXFd33aN3CC8gjz1sV6nlEdIArKDtxXe4QmjhhCdDRORykQTT4Kj54abaZUdap4sUUIPoGFWvzsoo4g6wrxXuuBBXjtYXbxgkfcLk4UZBKKvl9Q3S4nn8AeftUuqkuJ6suBBXjtYXTfY1vm1FZI3Omj5rX(iLq3k6kMIABlozso(Bw(nbfCz1zykkkQIelagobcagoHdaEWLCDftDa)GldLcHsfCTtioA3uu)n89gobxLj54GlVetrrtxacago5eap4sUUIPoGFWLHsHqPcU78g2WJC1LItm0GhuhCTckzcagobxLj54GltX4OYKC8ioTc4ItReDfIax2WJC1fGaGHtybWdUKRRyQd4hCzOuiuQG7P3WgEKRUu4rUSvh9MfV50ByZG7dhEjHAiVNEvKPIAf00SrfeP96V544n9rkjud590RImvuRGMMnk2hPijRw6vV58Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0SPUmqrB6vHyfLs9cIG00TVHV3a7BooEZoVrum5sPztDzGI20RcXkkL6fY1vm1FZ53C(nhhV50Bo9g2WJC1LItm0Ghu)nhhVHn8ixDPuRokv)nhhVHn8ixDP4JtV58Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0SPUmqrB6vHyfLs9cIG00TVHV3a7BooEZoVrum5sPztDzGI20RcXkkL6fY1vm1FZ53C(nhhV50BydpYvxkEwTjXwLEZI3C6nSzW9HdVyNqCensbrAV(BooEtFKIDcXr0ifjz1sV6nNFZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iLMn1LbkAtVkeROuQxqeKMU9n89gyFZXXB25nIIjxknBQldu0MEviwrPuVqUUIP(Bo)MZGRYKCCWLPyCuzsoEeNwbCXPvIUcrGBxr1QWkIIniQbiay4mOa4bxY1vm1b8dUmukekvWLndUpC4fBie04XUIQvHvevqeKMU9n89gjHOOmXEsGRYKCCWTROAr7eIbcagodcaEWLCDftDa)GRYKCCWLPyCuzsoEeNwbCXPvIUcrGBkeeqaWW5UaWdUKRRyQd4hCzOuiuQGBFKcVetrrtxksYQLEf4QmjhhCHum1MSisBKqebeamCcxaWdUKRRyQd4hCzOuiuQGBFKIDcXr0ifjz1sV6nlEZoVrum5sXoCeLnkAjQBlKRRyQdUktYXbxiftTjlI0gjerabadNlba8Gl56kM6a(bxgkfcLk4UZBeftUu4LykkA6sHCDftDWvzsoo4cPyQnzrK2iHiciay4C3aWdUKRRyQd4hCzOuiuQGRDcXr7MI6VHV3eeWvzsoo4cPyQnzrK2iHiciay4C3bGhCjxxXuhWp4QmjhhCTzZ24rC2sGldLcHsfCp9gLjjpk2hPyZMTXJ4SLEZYCFtqFZ53S4nNEZoVPpsXMnBJhXzlvKKvl9Q3CgCz1zykkkQIelagobcagyHdaEWLCDftDa)GldLcHsfCxdBBlPt8srxXuStqPLkwrz1EdFCFZUGZBooEZAyBBjDIxk6kMIDckTujS5nlEJKquuMypP3S8B2f4QmjhhC7in9ioBjGaGbwobWdUktYXb3ostpANqm4sUUIPoGFGaGbwybWdUKRRyQd4hCvMKJdUmfJJktYXJ40kGloTs0vicCzdpYvxacagydkaEWLCDftDa)GldLcHsfCxdBBlPt8srxXuStqPLkwrz1EdFCFZUGZBooEZAyBBjDIxk6kMIDckTujS5nlEJKquuMypP3S8B21BooEZAyBBjDIxk6kMIDckTuXkkR2B4J7Bc6UEZI30hPyNqCensrswT0RaxLj54GBhPPhXzlbeamWgea8GB6cHqHnc4Yj4QmjhhC7in9ODcXGl56kM6a(bcagy3faEWvzsoo4A30(WrCDWc4sUUIPoGFGaeW1sa4bWWjaEWvzsoo4UPHUaUKRRyQd4hiayGfap4sUUIPoGFWnDHqOWgjMTGBNwdBBl2nTpCejOvKYOIvuwn(4guWvzsoo42rA6r7eIb30fcHcBKyfEwvm4YjqaWeua8GRYKCCW1UP9HJ46GfWLCDftDa)abiGBkeeaEamCcGhCvMKJdUHwkMcbzbxY1vm1b8deGaUDfvRcRik2GOga8ay4eap4sUUIPoGFWLHsHqPcUSzW9HdVydHGgp2vuTkSIOcIG00TVz53al4QmjhhC5LykkA6cqaWalaEWvzsoo42vuTODcXGl56kM6a(bcaMGcGhCvMKJdUnJKJdUKRRyQd4hiayccaEWvzsoo42MiAfpthCjxxXuhWpqaWSla8GRYKCCWDfptp2gIQdUKRRyQd4hiayGla4bxLj54G7kHSeQw6vGl56kM6a(bcaMLaaEWLCDftDa)GldLcHsfC35nSHh5QlfNyObpO(Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BGfCTckzcagobxLj54GltX4OYKC8ioTc4ItReDfIax2WJC1fGaGz3aWdUKRRyQd4hCzOuiuQGRYKKhf7Ju4LykkA6YB47nW5nhhVrzsYJI9rknBQldu0MEviwrPu)n89g48MJJ3ikMCPyhoIYgfTe1TfY1vm1FZXXBo9MDEJOyYLcVetrrtxkKRRyQ)MfVzN3ikMCP0SPUmqrB6vHyfLs9c56kM6V5m4QmjhhCTHqqJh7kQwfwreqacqaxnu2ge4EtOLgGaeaa]] )


end