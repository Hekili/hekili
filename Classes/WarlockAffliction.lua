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
                if not settings.manage_ds_ticks or level < 52 then return end
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


    spec:RegisterPack( "Affliction", 20210403, [[d4K5EcqiOuEeuQSjjvFckzuGuNcu1QGIkQxPsPzja3sLc2Lq)ssPHPc0XGclta9mvattLIUgueBdKO(MGuACQuOZjivzDqrzEGkUNGAFGkDqOizHQGEiiHjcsKlcLQyJcsH(iuubNekv1kvPAMGKCtbPODki(juuPHcfvTubPYtH0uLuCvbPQARqrf6RqPknwbj7Lk)vrdwvhMYIbXJPQjRWLrTzvYNLOrRIoTOvlivLxdkZMWTHy3K(TudxsoouKA5apNOPJCDjSDOY3vHgpiPoVaTEOOImFOQ7lifSFL2HHRgh6Wi2fsGhmqmo4np4bIyGbMGjysO1HsbRyhAL5HzLSdvne2HIPUUePNYwDOvwqrBdxnouzxa8Sd9KOkjMvBTLjDwaj6BKALjsHWOSvpWUOALjIVwhkKIuqyF1bXHomIDHe4bdeJdEZdEGigyGjycMeOdvwXExibcLXeh6zogS6G4qhS07qXuxxI0tzR7J9Aar7HT3XuvGuSFGbSFGhmqm277DO400swIz79ByFm1yWJ9rRyHyFOQ9WI79ByFm1yWJ9HsmUUaSFOPvM(4E)g2htng8yFia2G5pnvzX(IUm97F1G9Hsal19r7crCVFd7xZr2GTFOPj4R0VFOZQOcaVVOlt)(uV)XgaB)8A)GDbwaEFKuktTCFBFYeSs7N6(0Pr7d6JX9(nSp2JAqe8(HodPYuAFm11Li9u2QCFmpom)(KjyLI79By)AoYgm5(uVVHRZX(qe9Xul3hkzayLcdW7N6(ifckVbYaLmT)XA79HsyU1i3VOkU3VH9HIwhSk59LncVpuYaWkfgG3hZd4Q99Mqi3N69b8OWZ77BKQcYOS19PeHJ79ByFuM2x2i8(EtiMMNYwNIus7ZkbswUp17ljq6P9PEFdxNJ99NShwQL7lsjj3NonA)JTIfTpeEFaB(tEe373W(yUQi4(Omp2VvpVFfGVHQcHi6qRa9vkyhk2HD7JPUUePNYw3h71aI2dBVJDy3(yQkqk2pWa2pWdgig799o2HD7dfNMwYsmBVJDy3(3W(yQXGh7JwXcX(qv7Hf37yh2T)nSpMAm4X(qjgxxa2p00ktFCVJDy3(3W(yQXGh7dbWgm)PPkl2x0LPF)RgSpucyPUpAxiI7DSd72)g2VMJSbB)qttWxPF)qNvrfaEFrxM(9PE)Jna2(51(b7cSa8(iPuMA5(2(KjyL2p19PtJ2h0hJ7DSd72)g2h7rnicE)qNHuzkTpM66sKEkBvUpMhhMFFYeSsX9o2HD7Fd7xZr2Gj3N69nCDo2hIOpMA5(qjdaRuyaE)u3hPqq5nqgOKP9pwBVpucZTg5(fvX9o2HD7Fd7dfToyvY7lBeEFOKbGvkmaVpMhWv77nHqUp17d4rHN333ivfKrzR7tjch37yh2T)nSpkt7lBeEFVjetZtzRtrkP9zLajl3N69Lei90(uVVHRZX((t2dl1Y9fPKK7tNgT)XwXI2hcVpGn)jpI7DSd72)g2hZvfb3hL5X(T659Ra8nuvieX9(E38u2QmwbyFJaXOWxSyoAKunkBnG8kmLimCpyDSvXu0ejoUo2GuCDflbjsNaE2xtP5b5v65yr1E38u2QmwbyFJaXOBdxRSabP1zft7DZtzRYyfG9nceJUnCTLGePtap7RP08G8k9Ca5vyYeSsXsqI0jGN91uAEqELEoYQbrWJ9U5PSvzScW(gbIr3gUwCginicoa1q4WJMKtaBJGbGZefCyZtjoEoAk6BaOOIYwH7bRBEkXXZrtrRS1GW9G1npL445OPyHkjdIGN21Li9u2kCpyDOXgzcwPOmRoBDkYloYQbrWd84npL445OPOmRoBDkYlgUhe(6qpAkwDAk1itzQLfcdKuWiLEyPwIhp2itWkfRonLAKPm1YcHbskyKvdIGhWV3npLTkJva23iqm62W1wi5zsmsaQHWHnmNKNgWKZRwPzFnR6JmyVBEkBvgRaSVrGy0THRvY8y2xtFdafvu2AaIu5PFegJdgqEfwwXcXKmqjtYOK5XSVM(gakQOS1P1mCdFG9U5PSvzScW(gbIr3gU2tRqP9U5PSvzScW(gbIr3gU2cvsgebpTRlr6PS19(Eh7WU9XEGA2xq8yFghdcUpLi8(0jVV5PgSFk33WzPWGi44E38u2QmSSIfIPO9W27MNYwL3gU2bJRlateRm97DZtzRYBdxR3eIP5PS1PiLuaQHWHTMdqsG0tHXiG8kS5PehpzLrswc3dS3XU9XuEkBDFrkj5(xnyFcKkmM2hcFA4Yge3hLmsUVb49LgoES)vd2hcF1aEF0UqSFORPAX(ivSosTCFOWitsGU6KRfZFAk1i7JMAzHWajfmG9B6KbhtjVFR777wm6J6E38u2Q82W16nHyAEkBDksjfGAiCycKkmMMYkrst)j7HfGKaPNcJra5vykry4GXE38u2Q82W16nHyAEkBDksjfGAiC4blSG8ysGuHXKCVBEkBvEB4A9MqmnpLTofPKcqneoSKmAsGuHXKmajbspfgJaYRWqpAkk7cXe0uKspSulXJF0umrQyDKA50BKjjqxDYZrtrk9WsTep(rtXQttPgzktTSqyGKcgP0dl1s4Rl7cXuEAGbCpaE8JMI4sbpjlvksPhwQL4XtMGvkk7Jt6KNsMhY9U5PSv5THR1BcX08u26uKska1q4WddXk5jbsfgtYaKei9uymciVc7BCSAkf1S8KMxgxhASHZaPbrWrcKkmMMYkrs4X77wm6JAu2fIjOPiGrSuLWnWdIhp04mqAqeCKaPcJPzRCDF3IrFuJYUqmbnfbmILQeoeivymfXi67wm6JAeWiwQs4XJhACginicosGuHX0Ko219Dlg9rnk7cXe0ueWiwQs4qGuHXumWOVBXOpQraJyPkHh(9U5PSv5THR1BcX08u26uKska1q4WddXk5jbsfgtYaKei9uymciVc7BCSAkfXXkDgeuhASHZaPbrWrcKkmMMYkrs4X77wm6JAmrQyDKA50BKjjqxDYraJyPkHBGhepEOXzG0Gi4ibsfgtZw56(UfJ(OgtKkwhPwo9gzsc0vNCeWiwQs4qGuHXueJOVBXOpQraJyPkHhpEOXzG0Gi4ibsfgtt6yx33Ty0h1yIuX6i1YP3itsGU6KJagXsvchcKkmMIbg9Dlg9rncyelvj8WV3npLTkVnCTEtiMMNYwNIusbOgchEyiwjpjqQWysgGKaPNcJra5vyO9nownLIk7bTObd849nownLIWccstXJ334y1ukQTYWxhASHZaPbrWrcKkmMMYkrs4X77wm6JAS60uQrMYullegiPGraJyPkHBGhepEOXzG0Gi4ibsfgtZw56(UfJ(OgRonLAKPm1YcHbskyeWiwQs4qGuHXueJOVBXOpQraJyPkHhpEOXzG0Gi4ibsfgtt6yx33Ty0h1y1PPuJmLPwwimqsbJagXsvchcKkmMIbg9Dlg9rncyelvj8WV3npLTkVnCTEtiMMNYwNIusbOgchEyiwjpjqQWysgGKaPNcJra5vySrMGvkwDAk1itzQLfcdKuWiRgebpQdn2WzG0Gi4ibsfgttzLij849Dlg9rnklqqADomaSsHb4iGrSuLWnWdIhp04mqAqeCKaPcJPzRCDF3IrFuJYceKwNddaRuyaocyelvjCiqQWykIr03Ty0h1iGrSuLWJhp04mqAqeCKaPcJPjDSR77wm6JAuwGG06CyayLcdWraJyPkHdbsfgtXaJ(UfJ(OgbmILQeE437y3(hwa09LDHyF5PbgY9ZR9VYYtA)uUVjqAjTFJJb7DZtzRYBdxlIj4R0pbwfva4aYRWqAPS(vwEstaJyPkHdd1SVG4jLimMZYUqmLNgyuF0uSqLKbrWt76sKEkBnsPhwQL7DSBFS)1((ghRMs7pAQwm)PPuJSpAQLfcdKuW9t5(GcvtTmG9lK8(qjdaRuyaEFQ3NHAI1X(0jVVVaayL2xY0E38u2Q82W16nHyAEkBDksjfGAiC4HbGvkmapRaCva5vyO9nownLI4yLodcQpAkMivSosTC6nYKeORo55OPiLEyPww33Ty0h1OSabP15WaWkfgGJagXsvcNaRd9OPy1PPuJmLPwwimqsbJagXsvc3aXJhBKjyLIvNMsnYuMAzHWajfeE4XJhAFJJvtPOMLN08Y46JMIYUqmbnfP0dl1Y6(UfJ(OgLfiiTohgawPWaCeWiwQs4eyDOhnfRonLAKPm1YcHbskyeWiwQs4giE8yJmbRuS60uQrMYullegiPGWdpE8qdTVXXQPuuzpOfnyGhVVXXQPuewqqAkE8(ghRMsrTvg(6JMIvNMsnYuMAzHWajfmsPhwQL1hnfRonLAKPm1YcHbskyeWiwQs4ei87DSB)qhFby55(JMK7ZgqeC)8A)Yo1Y9tL69T9LNgySVSI1rQL7xDAsEVBEkBvEB4A9MqmnpLTofPKcqneo8OPzfGRciVcdTVXXQPuuZYtAEzCDSnAkk7cXe0uKspSulR77wm6JAu2fIjOPiGrSuLW5MWJhp0(ghRMsrCSsNbb1X2OPyIuX6i1YP3itsGU6KNJMIu6HLAzDF3IrFuJjsfRJulNEJmjb6QtocyelvjCUj84Xdn0(ghRMsrL9Gw0GbE8(ghRMsrybbPP4X7BCSAkf1wz4RtMGvkwDAk1itzQLfcdKuW6yB0uS60uQrMYullegiPGrk9WsTSUVBXOpQXQttPgzktTSqyGKcgbmILQeo3e(9o2Tp2)AFm)PPuJSpAQLfcdKuW9t5(u6HLAza7N0(PCFPDX7t9(fsEFOKbGTpAxi27MNYwL3gU2HbGnLDHiG8k8OPy1PPuJmLPwwimqsbJu6HLA5E38u2Q82W1omaSPSlebKxHXgzcwPy1PPuJmLPwwimqsbRd9OPOSletqtrk9WsTep(rtXePI1rQLtVrMKaD1jphnfP0dl1s437y3(Obv)(y(ttPgzF0ullegiPG7FmPZ9XCKv6miO2qYYtA)qJgVVVXXQP0(JMcy)MozWXuY7xi59BDFF3IrFuJ7J9V2h7bPkiGnX(yUGHAQN3hsX11(PC)u9nsQLbS)zlg7xOuk2pjSK7dyBeCFOX4g3xY(whY9TlIb7xiz437MNYwL3gU2QttPgzktTSqyGKcgqEf234y1ukQz5jnVmUoLimCXK6(UfJ(OgLDHycAkcyelvjCWOo0eivymfzKQGa2eZgmut9C03Ty0h1iGrSuLWbdOCG4XJngtxKvv8iYivbbSjMnyOM6z437MNYwL3gU2QttPgzktTSqyGKcgqEf234y1ukIJv6miOoLimCXK6(UfJ(OgtKkwhPwo9gzsc0vNCeWiwQs4GrDOjqQWykYivbbSjMnyOM65OVBXOpQraJyPkHdgq5aXJhBmMUiRQ4rKrQccytmBWqn1ZWV3npLTkVnCTvNMsnYuMAzHWajfmG8km0(ghRMsrL9Gw0GbE8(ghRMsrybbPP4X7BCSAkf1wz4RdnbsfgtrgPkiGnXSbd1uph9Dlg9rncyelvjCWakhiE8yJX0fzvfpImsvqaBIzdgQPEg(9U5PSv5THRT60uQrMYullegiPGbKxHH0sz9RS8KMagXsvchmGY7DSBFS)1(y(ttPgzF0ullegiPG7NY9P0dl1Ya2pjSK7tjcVp17xi59B6Kb7JyH(AW(JMK7DZtzRYBdxR3eIP5PS1PiLuaQHWH9nownLciVcpAkwDAk1itzQLfcdKuWiLEyPwwhAFJJvtPOMLN08Yy849nownLI4yLodcGFVBEkBvEB4ATYwdgGpOxWtYaLmjdJraKbkzAMxHhnfTYwdgbmILQeo3CVBEkBvEB4ApTcL27y3(O9X9PtEFuMhY9BD)dSpzGsMK7Nx7N0(PuXI23xaaSsIG7N6(xIS8K2Vb736(0jVpzGsMI7J9M05(Oz1zR7dv5fVFsyj33eYEFimrmyFQ3VqY7JY8y)ghd2hX0cticUVvvjcMA5(hyFOObGIkkBvg37MNYwL3gUwjZJzFn9nauurzRbKxHnpL44jRmsYs4gyDYeSsrzFCsN8uY8qwhBJMIsMhZ(A6BaOOIYwJu6HLAzDSL68sKLN0E38u2Q82W1kzEm7RPVbGIkkBnG8kS5PehpzLrswc3aRtMGvkkZQZwNI8IRJTrtrjZJzFn9nauurzRrk9WsTSo2sDEjYYtQ(OPOVbGIkkBncyelvjCU5E38u2Q82W1Ilf8KSuPaYRWql7cXuEAGbCXapEZtjoEYkJKSeUbcFDF3IrFuJYceKwNddaRuyaocyelvjCXiW9U5PSv5THRTqLKbrWt76sKEkBnG8kS5Pehphnflujzqe80UUePNYwdFq84P0dl1Y6JMIfQKmicEAxxI0tzRraJyPkHZn37MNYwL3gUwVjetZtzRtrkPaudHd7BCSAkfGKaPNcJra5vyS5BCSAkfv2dArdg7DSBFmvvLi4(qrdafvu26(iMwycrW9BDFmUHa3NmqjtYa2Vb736(hy)JjDUpMcISffeVpu0aqrfLTU3npLTkVnCT(gakQOS1a8b9cEsgOKjzymciVcBEkXXtwzKKLW5M3a0KjyLIY(4Ko5PK5HepEYeSsrzwD26uKxm8bqgOKPzEfE0u03aqrfLTgbmILQeobU3XU9Xuxed2No597kwzqa7lRyDSVTV80aJ9pEY6(gTpMSFR7hAAc(k97h6SkQaW7t9(gUoh734yG3QQsTCVBEkBvEB4ArmbFL(jWQOcahqEfw2fIP80ad4EZ6uIWWnqm27y3(yVNSUV20(YGQp1Y9X8NMsnY(OPwwimqsb3N69XCKv6miO2qYYtA)qJghW(OfiiTUpuYaWkfgG3pV23eI9hnj33a8(wvLi5XE38u2Q82W16nHyAEkBDksjfGAiC4HbGvkmapRaCva5vyO9nownLI4yLodcQJnYeSsXQttPgzktTSqyGKcwF0umrQyDKA50BKjjqxDYZrtrk9WsTSUVBXOpQrzbcsRZHbGvkmahbSnccpE8q7BCSAkf1S8KMxgxhBKjyLIvNMsnYuMAzHWajfS(OPOSletqtrk9WsTSUVBXOpQrzbcsRZHbGvkmahbSnccpE8qdTVXXQPuuzpOfnyGhVVXXQPuewqqAkE8(ghRMsrTvg(6(UfJ(OgLfiiTohgawPWaCeW2ii87DSB)q)sEFOKbGTpAxi2pV2hkzayLcdW7FSvSO9HW7dyBeCFR0snG9BW(51(0jd49pMcX(q49nAFbBsA)a3hPb8(qjdaRuyaE)cjl37MNYwL3gU2HbGnLDHiG8kmKwkR77wm6JAuwGG06CyayLcdWraJyPkH7vwEstaJyPkRdn2itWkfRonLAKPm1YcHbskiE8(UfJ(OgRonLAKPm1YcHbskyeWiwQs4ELLN0eWiwQs437MNYwL3gU2HbGnLDHiG8km2itWkfRonLAKPm1YcHbskyDF3IrFuJYceKwNddaRuyaocyelv5T(UfJ(OgLfiiTohgawPWaCCuamkBfoxz5jnbmILQCVJD7dfg5pVbti2pjgz)cPvY7F1G9nniDMA5(At7lRyFEL8yFwi5JNmG37MNYwL3gUwVjetZtzRtrkPaudHdNeJS3XoSB)qhFby55(ON2OpUp2dceG559HWxnG3xwX6i1Y9LNgyi3V19dnnbFL(9dDwfva49U5PSv5THR1BcX08u26uKska1q4WsoG8kSGXXc4IjH26qpyifxxr5Pn6JtgbcW8CusMhgCGoWBW8u2AuEAJ(4eslOyQZlrwEsWJh)GHuCDfLN2OpozeiaZZraJyPkHZbGFVJD7h6xY7hAAc(k97h6SkQaW7F8K19rSqFny)rtY9naVFrva73G9ZR9PtgW7FmfI9HW7lZsnVsVP0(uIW7xOuk2No59vgQP9X8NMsnY(OPwwimqsb37MNYwL3gUwetWxPFcSkQaWbKxHhnfXLcEswQuKspSulXJF0umrQyDKA50BKjjqxDYZrtrk9WsTep(rtrzxiMGMIu6HLA5E38u2Q82W1Iyc(k9tGvrfaoG8kmzcwPy1PPuJmLPwwimqsbRd9OPy1PPuJmLPwwimqsbJu6HLAjE8(UfJ(OgRonLAKPm1YcHbskyeWiwQs4giMGh)vwEstaJyPkHJVBXOpQXQttPgzktTSqyGKcgbmILQe(9U5PSv5THRfXe8v6NaRIkaCa5vyYeSsrzFCsN8uY8qU3XU9Hsal19HQ8I3pL73Qi4(2(qjmp6(LwQ7FmPZ9X(kJljdIG3hkXiPK3xzdSpIb17ljZdtg3h7FT)vwEs7NY9niDbTp17Z6y)rVV20(iPuUVSI1rQL7tN8(sY8WK7DZtzRYBdx7ayPof5fhqEfgsX1vmvgxsgebphmsk5OKmpm4EZdIhpKIRRyQmUKmicEoyKuYXIQ6xz5jnbmILQeo3CVBEkBvEB4A9MqmnpLTofPKcqneoSVXXQP0E38u2Q82W1ALTgmaFqVGNKbkzsggJaYRWa(cWYtdIG37MNYwL3gU2cvsgebpTRlr6PS1aYRWMNsC8C0uSqLKbrWt76sKEkBn8bXJNspSulRd4lalpnicEVBEkBvEB4ALz1zRtrEXb4d6f8KmqjtYWyeqEfgWxawEAqe8E38u2Q82W16BaOOIYwdWh0l4jzGsMKHXiG8kmGVaS80Gi46MNsC8KvgjzjCU5nanzcwPOSpoPtEkzEiXJNmbRuuMvNTof5fd)E38u2Q82W1oawQtzxicivIbGIkkmg7DZtzRYBdxR80g9XjKwq799U5PSvz0AoC1PPuJmLPwwimqsb37MNYwLrR5Bdx7PvO0E38u2QmAnFB4A9MqmnpLTofPKcqneo8WaWkfgGNvaUkG8km0(ghRMsrCSsNbb1hnftKkwhPwo9gzsc0vN8C0uKspSulR77wm6JAuwGG06CyayLcdWraBJG1HE0uS60uQrMYullegiPGraJyPkHBG4XJnYeSsXQttPgzktTSqyGKccp84XdTVXXQPuuZYtAEzC9rtrzxiMGMIu6HLAzDF3IrFuJYceKwNddaRuyaocyBeSo0JMIvNMsnYuMAzHWajfmcyelvjCdepESrMGvkwDAk1itzQLfcdKuq4HVo0q7BCSAkfv2dArdg4X7BCSAkfHfeKMIhVVXXQPuuBLHV(OPy1PPuJmLPwwimqsbJu6HLAz9rtXQttPgzktTSqyGKcgbmILQeobc)E38u2QmAnFB4ALmpM9103aqrfLTgqEfMmbRuu2hN0jpLmpK19MoLmp27MNYwLrR5BdxRK5XSVM(gakQOS1aYRWyJmbRuu2hN0jpLmpK1X2OPOK5XSVM(gakQOS1iLEyPwwhBPoVez5jvF0u03aqrfLTgb8fGLNgebV3npLTkJwZ3gUwRS1Gb4d6f8KmqjtYWyeqEf28uIJNJMIwzRbHZnRd4lalpnicEVBEkBvgTMVnCTwzRbdWh0l4jzGsMKHXiG8kS5PehphnfTYwdc3W3SoGVaS80Gi46JMIwzRbJu6HLA5E38u2QmAnFB4Alujzqe80UUePNYwdiVcBEkXXZrtXcvsgebpTRlr6PS1WhepEk9WsTSoGVaS80Gi49U5PSvz0A(2W1wOsYGi4PDDjspLTgGpOxWtYaLmjdJra5vySrPhwQL1RWvrMGvkcmKktPPDDjspLTkJSAqe8OU5Pehphnflujzqe80UUePNYwHZb27MNYwLrR5BdxlUuWtYsLciVcl7cXuEAGbCXyVBEkBvgTMVnCTEtiMMNYwNIusbOgch234y1ukajbspfgJaYRWyZ34y1ukQSh0Igm27MNYwLrR5BdxR3eIP5PS1PiLuaQHWHhgawPWa8ScWvbKxHH234y1ukIJv6miOo0(UfJ(OgtKkwhPwo9gzsc0vNCeW2iiE8JMIjsfRJulNEJmjb6QtEoAksPhwQLWx33Ty0h1OSabP15WaWkfgGJa2gbRd9OPy1PPuJmLPwwimqsbJagXsvc3aXJhBKjyLIvNMsnYuMAzHWajfeE4Rdn0(ghRMsrL9Gw0GbE8(ghRMsrybbPP4X7BCSAkf1wz4R77wm6JAuwGG06CyayLcdWraJyPkHtG1HE0uS60uQrMYullegiPGraJyPkHBG4XJnYeSsXQttPgzktTSqyGKccp8q7BCSAkf1S8KMxgxhAF3IrFuJYUqmbnfbSncIh)OPOSletqtrk9WsTe(6(UfJ(OgLfiiTohgawPWaCeWiwQs4eyDOhnfRonLAKPm1YcHbskyeWiwQs4giE8yJmbRuS60uQrMYullegiPGWd)E38u2QmAnFB4Ahga2u2fIaYRW(UfJ(OgLfiiTohgawPWaCeWiwQs4ELLN0eWiwQY6qJnYeSsXQttPgzktTSqyGKcIhVVBXOpQXQttPgzktTSqyGKcgbmILQeUxz5jnbmILQe(9U5PSvz0A(2W1omaSPSlebKxH9Dlg9rnklqqADomaSsHb4iGrSuL367wm6JAuwGG06CyayLcdWXrbWOSv4CLLN0eWiwQY9U5PSvz0A(2W16nHyAEkBDksjfGAiC4KyK9U5PSvz0A(2W16nHyAEkBDksjfGAiC4blSG8ysGuHXKCVBEkBvgTMVnCTEtiMMNYwNIusbOgchEyiwjpjqQWysU3npLTkJwZ3gUwVjetZtzRtrkPaudHdljJMeivymjdiVcpAkwDAk1itzQLfcdKuWiLEyPwIhp2itWkfRonLAKPm1YcHbsk4E38u2QmAnFB4ArmbFL(jWQOcahqEfE0uexk4jzPsrk9WsTCVBEkBvgTMVnCTiMGVs)eyvubGdiVcpAkk7cXe0uKspSulRJnYeSsrzFCsN8uY8qU3npLTkJwZ3gUwetWxPFcSkQaWbKxHXgzcwPiUuWtYsL27MNYwLrR5BdxlIj4R0pbwfva4aYRWYUqmLNgya3BU3npLTkJwZ3gUwzwD26uKxCa(GEbpjduYKmmgbKxHnpL445OPOmRoBDkYlgoHpqDaFby5PbrW1X2OPOmRoBDkYlosPhwQL7DZtzRYO18THR1BcX08u26uKska1q4W(ghRMsbijq6PWyeqEf234y1ukQSh0Igm27MNYwLrR5Bdx7ayPof5fhqEfgsX1vmvgxsgebphmsk5OKmpm4ggtoiE8qkUUIPY4sYGi45GrsjhlQQFLLN0eWiwQs4Gj4XdP46kMkJljdIGNdgjLCusMhgCdFamP(OPOSletqtrk9WsTCVBEkBvgTMVnCTdGL6u2fIasLyaOOIcJXE38u2QmAnFB4ALN2OpoH0cAVV3npLTkJ(ghRMsHtKkwhPwo9gzsc0vNCa5vySrMGvkwDAk1itzQLfcdKuW6q77wm6JAuwGG06CyayLcdWraJyPkHdghepEF3IrFuJYceKwNddaRuyaocyelvjCXKdw33Ty0h1OSabP15WaWkfgGJagXsvc3aXK6(whfjf9nauurPwofmdGFVBEkBvg9nownLUnCTjsfRJulNEJmjb6QtoG8kmzcwPy1PPuJmLPwwimqsbRpAkwDAk1itzQLfcdKuWiLEyPwU3npLTkJ(ghRMs3gU2b7teJsTCcPfua5vyF3IrFuJYceKwNddaRuyaocyelvjCXK6qpyifxxXtRqPiGrSuLW9M4XJnYeSsXtRqj437MNYwLrFJJvtPBdxRSletqtbKxHXgzcwPy1PPuJmLPwwimqsbRdTVBXOpQrzbcsRZHbGvkmahbmILQeoycE8(UfJ(OgLfiiTohgawPWaCeWiwQs4IjhepEF3IrFuJYceKwNddaRuyaocyelvjCdetQ7BDuKu03aqrfLA5uWma(9U5PSvz034y1u62W1k7cXe0ua5vyYeSsXQttPgzktTSqyGKcwF0uS60uQrMYullegiPGrk9WsTCVBEkBvg9nownLUnCTsFxasTCsjDY799U5PSvzCyiwjpjqQWysgUqYZKyKaudHdl7cXml1KyWE38u2QmomeRKNeivymjVnCTfsEMeJeGAiC4bGTXvc4jowkzXE38u2QmomeRKNeivymjVnCTfsEMeJeGAiC4srWQZzFnnPmrsHrzR799U5PSvzCyayLcdWZkaxfgxk4jzPs7DZtzRY4WaWkfgGNvaU62W1omaSPSle7DZtzRY4WaWkfgGNvaU62W1w1u26E38u2QmomaSsHb4zfGRUnCTxjGHi6ES3npLTkJddaRuyaEwb4QBdxler3J5vbi4E38u2QmomaSsHb4zfGRUnCTqyGKbWsTCVBEkBvghgawPWa8ScWv3gUwVjetZtzRtrkPaudHd7BCSAkfqEfgB(ghRMsrL9Gw0GXE38u2QmomaSsHb4zfGRUnCTYceKwNddaRuyaEVV3npLTkJdwyb5XKaPcJjz4cjptIrcqneomJufeWMy2GHAQNdiVcdTVXXQPuuZYtAEzCDF3IrFuJYUqmbnfbmILQeobEq4XJhAFJJvtPiowPZGG6(UfJ(OgtKkwhPwo9gzsc0vNCeWiwQs4e4bHhpEO9nownLIk7bTObd849nownLIWccstXJ334y1ukQTYWV3npLTkJdwyb5XKaPcJj5THRTqYZKyKaudHdlluiIUhtdHPZGskG8km0(ghRMsrnlpP5LX19Dlg9rnk7cXe0ueWiwQs4aLHhpEO9nownLI4yLodcQ77wm6JAmrQyDKA50BKjjqxDYraJyPkHdugE84H234y1ukQSh0IgmWJ334y1ukcliinfpEFJJvtPO2kd)E38u2QmoyHfKhtcKkmMK3gU2cjptIrcqneoSSlecMOulNGcibdiVcdTVXXQPuuZYtAEzCDF3IrFuJYUqmbnfbmILQeo3i84XdTVXXQPuehR0zqqDF3IrFuJjsfRJulNEJmjb6QtocyelvjCUr4XJhAFJJvtPOYEqlAWapEFJJvtPiSGG0u849nownLIARm8799U5PSvzC00ScWvHTYwdgqEfE0u0kBnyeWiwQs4CJ19Dlg9rnklqqADomaSsHb4iGrSuLWD0u0kBnyeWiwQY9U5PSvzC00ScWv3gUwzwD26uKxCa5v4rtrzwD26uKxCeWiwQs4CJ19Dlg9rnklqqADomaSsHb4iGrSuLWD0uuMvNTof5fhbmILQCVBEkBvghnnRaC1THRTqLKbrWt76sKEkBnG8k8OPyHkjdIGN21Li9u2AeWiwQs4CJ19Dlg9rnklqqADomaSsHb4iGrSuLWD0uSqLKbrWt76sKEkBncyelv5E38u2QmoAAwb4QBdxRVbGIkkBnG8k8OPOVbGIkkBncyelvjCUX6(UfJ(OgLfiiTohgawPWaCeWiwQs4oAk6BaOOIYwJagXsvU337MNYwLXKyKWfsEMeJi377DZtzRYOKdFAfkT3npLTkJs(2W1oawQtzxicivIbGIkAwkAiMimgbKkXaqrfnZRWdgsX1vuEAJ(4KrGamphLK5Hb3WhyVBEkBvgL8THRvEAJ(4eslO9(E38u2QmkjJMeivymjdxi5zsmsaQHWHtv6bfKbrWtmDHPubYCW4spV3npLTkJsYOjbsfgtYBdxBHKNjXibOgchovjbk8udKZrIlvEcHfI9U5PSvzusgnjqQWysEB4AlK8mjgja1q4WnogCj6JPwonnrSP3k59U5PSvzusgnjqQWysEB4AlK8mjgja1q4WddadPBDoypSzvbbyPNvpV3npLTkJsYOjbsfgtYBdxBHKNjXibOgchgX8geapLNmttKcz637MNYwLrjz0KaPcJj5THRTqYZKyKaudHdFjmeE2xtigrcEVBEkBvgLKrtcKkmMK3gU2cjptIrcqneo8rdgRmqoVaTo27MNYwLrjz0KaPcJj5THRTqYZKyKaudHdtgebtZ(AoyzLLG9U5PSvzusgnjqQWysEB4AlK8mjgja1q4WYuVkettwLatj5eInk5zFnVyq7tk4E38u2QmkjJMeivymjVnCTfsEMeJeGAiCyzQxfIzPWgPrnqoHyJsE2xZlg0(KcU3npLTkJsYOjbsfgtYBdxler3J5vbi4E38u2QmkjJMeivymjVnCTxjGHi6ES3npLTkJsYOjbsfgtYBdxlegizaSul377DZtzRYibsfgttzLiPP)K9WcJZaPbrWbOgchwwX(0etgtxKvv8iaCMOGddn0qZy6ISQIhrgPkiGnXSbd1upVHgymDrwvXJyQspOGmicEIPlmLkqMdgx6z43qdmMUiRQ4ru2fcbtuQLtqbKGWVHgymDrwvXJOSqHi6EmneModkj437MNYwLrcKkmMMYkrst)j7HDB4AXzG0Gi4audHdtGuHX0SvoaCMOGddnbsfgtrmINMCwbAF00G1jqQWykIr80KtF3IrFuHFVBEkBvgjqQWyAkRejn9NSh2THRfNbsdIGdqneombsfgtt6yhaotuWHHMaPcJPyGXttoRaTpAAW6eivymfdmEAYPVBXOpQWV3npLTkJeivymnLvIKM(t2d72W1IZaPbrWbOgchEyiwjpjqQWykaCMOGddn2GMaPcJPigXttoRaTpAAW6eivymfXiEAYPVBXOpQWdpE8qJnOjqQWykgy80KZkq7JMgSobsfgtXaJNMC67wm6Jk8WJhpJPlYQkEelfbRoN910KYejfgLTU3npLTkJeivymnLvIKM(t2d72W1IZaPbrWbOgchMaPcJPPSsKua4mrbhgACginicosGuHX0SvUoodKgebhhgIvYtcKkmMGhpEOXzG0Gi4ibsfgtt6yxhNbsdIGJddXk5jbsfgtWJhp04mqAqeCKaPcJPzR8gAaNbsdIGJYk2NMyYy6ISQIhWJhp04mqAqeCKaPcJPjDS3qd4mqAqeCuwX(0etgtxKvv8aEhkogiZwDHe4bdeJdEGdgADOhnGMAP0HI9IPcDHG9dbZbmB)9R5K3prQAaT)vd2hlcKkmMMYkrst)j7HH1(agtxKaESVSr49TcQrmIh77pnTKLX9ouLkVFGy2(qrR4yaXJ9XIaPcJPigXqH1(uVpweivymfjmIHcR9HoqOg(4EhQsL3)ay2(qrR4yaXJ9XIaPcJPyGXqH1(uVpweivymfPaJHcR9HoqOg(4EhQsL3)My2(qrR4yaXJ9XIaPcJPigXqH1(uVpweivymfjmIHcR9HoqOg(4EhQsL3)My2(qrR4yaXJ9XIaPcJPyGXqH1(uVpweivymfPaJHcR9HoqOg(4EFVJ9IPcDHG9dbZbmB)9R5K3prQAaT)vd2hlFJJvtjS2hWy6IeWJ9LncVVvqnIr8yF)PPLSmU3HQu59XaZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(yGz7dfTIJbep2hlFRJIKIHcR9PEFS8TokskgQiRgebpWAFOXaQHpU3HQu59deZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(haZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(3eZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(3eZ2hkAfhdiESpw(whfjfdfw7t9(y5BDuKumurwnicEG1(qJbudFCVdvPY7Jjy2(qrR4yaXJ9XImbRumuyTp17JfzcwPyOISAqe8aR9HgdOg(4EFVJ9IPcDHG9dbZbmB)9R5K3prQAaT)vd2hRbFzfccR9bmMUib8yFzJW7BfuJyep23FAAjlJ7DOkvEFOmMTpu0kogq8yFSitWkfdfw7t9(yrMGvkgQiRgebpWAFJ2h7bZfQ2hAmGA4J7DOkvE)qlMTpu0kogq8yFSiqQWykIrmuyTp17JfbsfgtrcJyOWAFOXaQHpU3HQu59dTy2(qrR4yaXJ9XIaPcJPyGXqH1(uVpweivymfPaJHcR9HgdOg(4EhQsL3)gXS9HIwXXaIh7JfbsfgtrmIHcR9PEFSiqQWyksyedfw7dngqn8X9ouLkV)nIz7dfTIJbep2hlcKkmMIbgdfw7t9(yrGuHXuKcmgkS2hAmGA4J7DOkvE)qpmBFOOvCmG4X(yrGuHXueJyOWAFQ3hlcKkmMIegXqH1(qJbudFCVdvPY7h6Hz7dfTIJbep2hlcKkmMIbgdfw7t9(yrGuHXuKcmgkS2hAmGA4J7DOkvEFmoiMTpu0kogq8yFSiqQWykIrmuyTp17JfbsfgtrcJyOWAFOXaQHpU3HQu59X4Gy2(qrR4yaXJ9XIaPcJPyGXqH1(uVpweivymfPaJHcR9HgdOg(4EhQsL3hJaXS9HIwXXaIh7JfzcwPyOWAFQ3hlYeSsXqfz1Gi4bw7dDGqn8X9ouLkVpghaZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(yGjy2(qrR4yaXJ9XImbRumuyTp17JfzcwPyOISAqe8aR9HgdOg(4EhQsL3hdOmMTpu0kogq8yFSiqQWykAq8rF3IrFuXAFQ3hlF3IrFuJgepw7dngqn8X9ouLkVpgHwmBFOOvCmG4X(yrGuHXu0G4J(UfJ(OI1(uVpw(UfJ(OgniES2hAmGA4J7DOkvEFmUrmBFOOvCmG4X(yrGuHXu0G4J(UfJ(OI1(uVpw(UfJ(OgniES2hAmGA4J7DOkvE)apaMTpu0kogq8yFSitWkfdfw7t9(yrMGvkgQiRgebpWAFOXaQHpU3HQu59d8My2(qrR4yaXJ9XImbRumuyTp17JfzcwPyOISAqe8aR9HgdOg(4EhQsL3pWBeZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0bc1Wh37qvQ8(h4Gy2(qrR4yaXJ9XImbRumuyTp17JfzcwPyOISAqe8aR9HoqOg(4EhQsL3)ayGz7dfTIJbep2hlYeSsXqH1(uVpwKjyLIHkYQbrWdS2hAmGA4J7DOkvE)deiMTpu0kogq8yFSitWkfdfw7t9(yrMGvkgQiRgebpWAFOXaQHpU3HQu59paugZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0ya1Wh37qvQ8(hi0Iz7dfTIJbep2hlYeSsXqH1(uVpwKjyLIHkYQbrWdS23O9XEWCHQ9HgdOg(4EhQsL3)MhaZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0bc1Wh377DSxmvOleSFiyoGz7VFnN8(jsvdO9VAW(yznJ1(agtxKaESVSr49TcQrmIh77pnTKLX9ouLkV)bWS9HIwXXaIh7JfzcwPyOWAFQ3hlYeSsXqfz1Gi4bw7dDGqn8X9ouLkV)nXS9HIwXXaIh7JfzcwPyOWAFQ3hlYeSsXqfz1Gi4bw7dngqn8X9ouLkVpMGz7dfTIJbep2hlYeSsXqH1(uVpwKjyLIHkYQbrWdS2hAmGA4J7DOkvEFmceZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTp0haQHpU3HQu59X4ay2(qrR4yaXJ9XImbRumuyTp17JfzcwPyOISAqe8aR9HgdOg(4EhQsL3hJBeZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTVr7J9G5cv7dngqn8X9ouLkVFGheZ2hkAfhdiESpwKjyLIHcR9PEFSitWkfdvKvdIGhyTVr7J9G5cv7dngqn8X9ouLkVFGyGz7dfTIJbep2hlYeSsXqH1(uVpwKjyLIHkYQbrWdS23O9XEWCHQ9HgdOg(4EFVJ9rQAaXJ9XiW9npLTUViLKmU3DOIussxno0HbGvkmapRaCLRgxiy4QXHAEkB1HIlf8KSujhkRgebpCh6ixib6QXHAEkB1HomaSPSleouwnicE4o0rUqoGRghQ5PSvhAvtzRouwnicE4o0rUqUPRghQ5PSvh6vcyiIUhouwnicE4o0rUqWexnouZtzRouiIUhZRcqqhkRgebpCh6ixiqzxnouZtzRouimqYayPw6qz1Gi4H7qh5cj06QXHYQbrWd3HoupijgKMdfB77BCSAkfv2dArdgouZtzRouVjetZtzRtrkjhQiL0une2H6BCSAk5ixi3ORghQ5PSvhQSabP15WaWkfgGDOSAqe8WDOJCKdLaPcJPPSsK00FYEyUACHGHRghkRgebpCh6q7khQKjhQ5PSvhkodKgeb7qXzIc2Hc9(qVp07Zy6ISQIhrgPkiGnXSbd1up7qXzGPAiSdvwX(0etgtxKvv8WrUqc0vJdLvdIGhUdDODLdvYKd18u2QdfNbsdIGDO4mrb7qHEFcKkmMIegXttoRaTpAAW9RVpbsfgtrcJ4PjN(UfJ(OUp8ouCgyQgc7qjqQWyA2k7ixihWvJdLvdIGhUdDODLdvYKd18u2QdfNbsdIGDO4mrb7qHEFcKkmMIuGXttoRaTpAAW9RVpbsfgtrkW4PjN(UfJ(OUp8ouCgyQgc7qjqQWyAshBh5c5MUACOSAqe8WDOdTRCOsMCOMNYwDO4mqAqeSdfNjkyhk07JT9HEFcKkmMIegXttoRaTpAAW9RVpbsfgtrcJ4PjN(UfJ(OUp87d)(4XVp07JT9HEFcKkmMIuGXttoRaTpAAW9RVpbsfgtrkW4PjN(UfJ(OUp87d)(4XVpJPlYQkEelfbRoN910KYejfgLT6qXzGPAiSdDyiwjpjqQWyYrUqWexnouwnicE4o0H2voujtouZtzRouCginic2HIZefSdf69XzG0Gi4ibsfgtZw59RVpodKgebhhgIvYtcKkmM2h(9XJFFO3hNbsdIGJeivymnPJ9(13hNbsdIGJddXk5jbsfgt7d)(4XVp07JZaPbrWrcKkmMMTYouCgyQgc7qjqQWyAkRej5ih5qhgIvYtcKkmMKUACHGHRghkRgebpCh6qvdHDOYUqmZsnjg4qnpLT6qLDHyMLAsmWrUqc0vJdLvdIGhUdDOQHWo0bGTXvc4jowkzHd18u2QdDayBCLaEIJLsw4ixihWvJdLvdIGhUdDOQHWo0srWQZzFnnPmrsHrzRouZtzRo0srWQZzFnnPmrsHrzRoYro0blSG8ysGuHXK0vJlemC14qz1Gi4H7qhQ5PSvhkJufeWMy2GHAQNDOEqsminhk077BCSAkf1S8KMxgVF999Dlg9rnk7cXe0ueWiwQY9HZ(bEW9HFF843h699nownLI4yLodc2V(((UfJ(OgtKkwhPwo9gzsc0vNCeWiwQY9HZ(bEW9HFF843h699nownLIk7bTObJ9XJFFFJJvtPiSGG009XJFFFJJvtPO2kVp8ou1qyhkJufeWMy2GHAQNDKlKaD14qz1Gi4H7qhQ5PSvhQSqHi6EmneModkjhQhKedsZHc9((ghRMsrnlpP5LX7xFFF3IrFuJYUqmbnfbmILQCF4SpuEF43hp(9HEFFJJvtPiowPZGG9RVVVBXOpQXePI1rQLtVrMKaD1jhbmILQCF4SpuEF43hp(9HEFFJJvtPOYEqlAWyF843334y1ukcliinDF843334y1ukQTY7dVdvne2HkluiIUhtdHPZGsYrUqoGRghkRgebpCh6qnpLT6qLDHqWeLA5euajOd1dsIbP5qHEFFJJvtPOMLN08Y49RVVVBXOpQrzxiMGMIagXsvUpC2)g3h(9XJFFO3334y1ukIJv6miy)6777wm6JAmrQyDKA50BKjjqxDYraJyPk3ho7FJ7d)(4XVp077BCSAkfv2dArdg7Jh)((ghRMsrybbPP7Jh)((ghRMsrTvEF4DOQHWouzxiemrPwobfqc6ih5q9nownLC14cbdxnouwnicE4o0H6bjXG0COyBFYeSsXQttPgzktTSqyGKcgz1Gi4X(13h699Dlg9rnklqqADomaSsHb4iGrSuL7dN9X4G7Jh)((UfJ(OgLfiiTohgawPWaCeWiwQY9H7(yYb3V(((UfJ(OgLfiiTohgawPWaCeWiwQY9H7(bIj7xFFFRJIKI(gakQOulNcMbrwnicESp8ouZtzRo0ePI1rQLtVrMKaD1j7ixib6QXHYQbrWd3HoupijgKMdLmbRuS60uQrMYullegiPGrwnicESF99hnfRonLAKPm1YcHbskyKspSulDOMNYwDOjsfRJulNEJmjb6Qt2rUqoGRghkRgebpCh6q9GKyqAouF3IrFuJYceKwNddaRuyaocyelv5(WDFmz)67d9(dgsX1v80kukcyelv5(WD)BUpE87JT9jtWkfpTcLISAqe8yF4DOMNYwDOd2NigLA5eslih5c5MUACOSAqe8WDOd1dsIbP5qX2(KjyLIvNMsnYuMAzHWajfmYQbrWJ9RVp0777wm6JAuwGG06CyayLcdWraJyPk3ho7Jj7Jh)((UfJ(OgLfiiTohgawPWaCeWiwQY9H7(yYb3hp(99Dlg9rnklqqADomaSsHb4iGrSuL7d39det2V(((whfjf9nauurPwofmdISAqe8yF4DOMNYwDOYUqmbn5ixiyIRghkRgebpCh6q9GKyqAouYeSsXQttPgzktTSqyGKcgz1Gi4X(13F0uS60uQrMYullegiPGrk9WsT0HAEkB1Hk7cXe0KJCHaLD14qnpLT6qL(UaKA5Ks6KDOSAqe8WDOJCKdD00ScWvUACHGHRghkRgebpCh6q9GKyqAo0rtrRS1GraJyPk3ho7FJ7xFFF3IrFuJYceKwNddaRuyaocyelv5(WD)rtrRS1GraJyPkDOMNYwDOwzRbDKlKaD14qz1Gi4H7qhQhKedsZHoAkkZQZwNI8IJagXsvUpC2)g3V(((UfJ(OgLfiiTohgawPWaCeWiwQY9H7(JMIYS6S1PiV4iGrSuLouZtzRouzwD26uKxSJCHCaxnouwnicE4o0H6bjXG0COJMIfQKmicEAxxI0tzRraJyPk3ho7FJ7xFFF3IrFuJYceKwNddaRuyaocyelv5(WD)rtXcvsgebpTRlr6PS1iGrSuLouZtzRo0cvsgebpTRlr6PSvh5c5MUACOSAqe8WDOd1dsIbP5qhnf9nauurzRraJyPk3ho7FJ7xFFF3IrFuJYceKwNddaRuyaocyelv5(WD)rtrFdafvu2AeWiwQshQ5PSvhQVbGIkkB1roYHo4lRqqUACHGHRghQ5PSvhQSIfIPO9WCOSAqe8WDOJCHeORghQ5PSvh6GX1fGjIvMEhkRgebpCh6ixihWvJdLvdIGhUdDOEqsminhQ5PehpzLrswUpC3)aoujbsp5cbdhQ5PSvhQ3eIP5PS1PiLKdvKsAQgc7qTMDKlKB6QXHYQbrWd3Ho0bl9GSIYwDOykpLTUViLKC)RgSpbsfgt7dHpnCzdI7Jsgj33a8(sdhp2)Qb7dHVAaVpAxi2p01uTyFKkwhPwUpuyKjjqxDY1I5pnLAK9rtTSqyGKcgW(nDYGJPK3V199Dlg9r1HAEkB1H6nHyAEkBDksj5qLei9KlemCOEqsminhkLi8(WzFmCOIust1qyhkbsfgttzLiPP)K9WCKlemXvJdLvdIGhUdDOMNYwDOEtiMMNYwNIusourkPPAiSdDWclipMeivymjDKleOSRghkRgebpCh6q9GKyqAouO3F0uu2fIjOPiLEyPwUpE87pAkMivSosTC6nYKeORo55OPiLEyPwUpE87pAkwDAk1itzQLfcdKuWiLEyPwUp87xFFzxiMYtdm2hU7FG9XJF)rtrCPGNKLkfP0dl1Y9XJFFYeSsrzFCsN8uY8qgz1Gi4HdvsG0tUqWWHAEkB1H6nHyAEkBDksj5qfPKMQHWoujz0KaPcJjPJCHeAD14qz1Gi4H7qhQhKedsZH6BCSAkf1S8KMxgVF99HEFSTpodKgebhjqQWyAkRejTpE8777wm6JAu2fIjOPiGrSuL7d39d8G7Jh)(qVpodKgebhjqQWyA2kVF999Dlg9rnk7cXe0ueWiwQY9HZ(eivymfjmI(UfJ(OgbmILQCF43hp(9HEFCginicosGuHX0Ko27xFFF3IrFuJYUqmbnfbmILQCF4SpbsfgtrkWOVBXOpQraJyPk3h(9H3Hkjq6jxiy4qnpLT6q9MqmnpLTofPKCOIust1qyh6WqSsEsGuHXK0rUqUrxnouwnicE4o0H6bjXG0CO(ghRMsrCSsNbb7xFFO3hB7JZaPbrWrcKkmMMYkrs7Jh)((UfJ(OgtKkwhPwo9gzsc0vNCeWiwQY9H7(bEW9XJFFO3hNbsdIGJeivymnBL3V(((UfJ(OgtKkwhPwo9gzsc0vNCeWiwQY9HZ(eivymfjmI(UfJ(OgbmILQCF43hp(9HEFCginicosGuHX0Ko27xFFF3IrFuJjsfRJulNEJmjb6Qtocyelv5(WzFcKkmMIuGrF3IrFuJagXsvUp87dVdvsG0tUqWWHAEkB1H6nHyAEkBDksj5qfPKMQHWo0HHyL8KaPcJjPJCHe65QXHYQbrWd3HoupijgKMdf699nownLIk7bTObJ9XJFFFJJvtPiSGG009XJFFFJJvtPO2kVp87xFFO3hB7JZaPbrWrcKkmMMYkrs7Jh)((UfJ(OgRonLAKPm1YcHbskyeWiwQY9H7(bEW9XJFFO3hNbsdIGJeivymnBL3V(((UfJ(OgRonLAKPm1YcHbskyeWiwQY9HZ(eivymfjmI(UfJ(OgbmILQCF43hp(9HEFCginicosGuHX0Ko27xFFF3IrFuJvNMsnYuMAzHWajfmcyelv5(WzFcKkmMIuGrF3IrFuJagXsvUp87dVdvsG0tUqWWHAEkB1H6nHyAEkBDksj5qfPKMQHWo0HHyL8KaPcJjPJCHGXbD14qz1Gi4H7qhQhKedsZHIT9jtWkfRonLAKPm1YcHbskyKvdIGh7xFFO3hB7JZaPbrWrcKkmMMYkrs7Jh)((UfJ(OgLfiiTohgawPWaCeWiwQY9H7(bEW9XJFFO3hNbsdIGJeivymnBL3V(((UfJ(OgLfiiTohgawPWaCeWiwQY9HZ(eivymfjmI(UfJ(OgbmILQCF43hp(9HEFCginicosGuHX0Ko27xFFF3IrFuJYceKwNddaRuyaocyelv5(WzFcKkmMIuGrF3IrFuJagXsvUp87dVdvsG0tUqWWHAEkB1H6nHyAEkBDksj5qfPKMQHWo0HHyL8KaPcJjPJCHGbgUACOSAqe8WDOd18u2QdfXe8v6NaRIkaSdDWspiROSvh6HfaDFzxi2xEAGHC)8A)RS8K2pL7BcKws734yGd1dsIbP5qH0s5(13)klpPjGrSuL7dN9zOM9fepPeH3hZ59LDHykpnWy)67pAkwOsYGi4PDDjspLTgP0dl1sh5cbJaD14qz1Gi4H7qh6GLEqwrzRouS)1((ghRMs7pAQwm)PPuJSpAQLfcdKuW9t5(GcvtTmG9lK8(qjdaRuyaEFQ3NHAI1X(0jVVVaayL2xYKd18u2Qd1BcX08u26uKsYH6bjXG0COqVVVXXQPuehR0zqW(13F0umrQyDKA50BKjjqxDYZrtrk9WsTC)6777wm6JAuwGG06CyayLcdWraJyPk3ho7h4(13h69hnfRonLAKPm1YcHbskyeWiwQY9H7(bUpE87JT9jtWkfRonLAKPm1YcHbskyKvdIGh7d)(WVpE87d9((ghRMsrnlpP5LX7xF)rtrzxiMGMIu6HLA5(1333Ty0h1OSabP15WaWkfgGJagXsvUpC2pW9RVp07pAkwDAk1itzQLfcdKuWiGrSuL7d39dCF843hB7tMGvkwDAk1itzQLfcdKuWiRgebp2h(9HFF843h69HEFFJJvtPOYEqlAWyF843334y1ukcliinDF843334y1ukQTY7d)(13F0uS60uQrMYullegiPGrk9WsTC)67pAkwDAk1itzQLfcdKuWiGrSuL7dN9dCF4DOIust1qyh6WaWkfgGNvaUYrUqW4aUACOSAqe8WDOdDWspiROSvhAOJVaS8C)rtY9zdicUFETFzNA5(Ps9(2(Ytdm2xwX6i1Y9Ronj7qnpLT6q9MqmnpLTofPKCOEqsminhk077BCSAkf1S8KMxgVF99X2(JMIYUqmbnfP0dl1Y9RVVVBXOpQrzxiMGMIagXsvUpC2)M7d)(4XVp077BCSAkfXXkDgeSF99X2(JMIjsfRJulNEJmjb6QtEoAksPhwQL7xFFF3IrFuJjsfRJulNEJmjb6Qtocyelv5(Wz)BUp87Jh)(qVp077BCSAkfv2dArdg7Jh)((ghRMsrybbPP7Jh)((ghRMsrTvEF43V((KjyLIvNMsnYuMAzHWajfmYQbrWJ9RVp22F0uS60uQrMYullegiPGrk9WsTC)6777wm6JAS60uQrMYullegiPGraJyPk3ho7FZ9H3HksjnvdHDOJMMvaUYrUqW4MUACOSAqe8WDOd18u2QdDyaytzxiCOdw6bzfLT6qX(x7J5pnLAK9rtTSqyGKcUFk3NspSuldy)K2pL7lTlEFQ3VqY7dLmaS9r7cHd1dsIbP5qhnfRonLAKPm1YcHbskyKspSulDKlemWexnouwnicE4o0H6bjXG0COyBFYeSsXQttPgzktTSqyGKcgz1Gi4X(13h69hnfLDHycAksPhwQL7Jh)(JMIjsfRJulNEJmjb6QtEoAksPhwQL7dVd18u2QdDyaytzxiCKlemGYUACOSAqe8WDOd18u2QdT60uQrMYullegiPGo0bl9GSIYwDOObv)(y(ttPgzF0ullegiPG7FmPZ9XCKv6miO2qYYtA)qJgVVVXXQP0(JMcy)MozWXuY7xi59BDFF3IrFuJ7J9V2h7bPkiGnX(yUGHAQN3hsX11(PC)u9nsQLbS)zlg7xOuk2pjSK7dyBeCFOX4g3xY(whY9TlIb7xiz4DOEqsminhQVXXQPuuZYtAEz8(13NseEF4UpMSF999Dlg9rnk7cXe0ueWiwQY9HZ(ySF99HEFF3IrFuJmsvqaBIzdgQPEocyelv5(WzFmGYbUpE87JT9zmDrwvXJiJufeWMy2GHAQN3hEh5cbJqRRghkRgebpCh6q9GKyqAouFJJvtPiowPZGG9RVpLi8(WDFmz)6777wm6JAmrQyDKA50BKjjqxDYraJyPk3ho7JX(13h699Dlg9rnYivbbSjMnyOM65iGrSuL7dN9Xakh4(4XVp22NX0fzvfpImsvqaBIzdgQPEEF4DOMNYwDOvNMsnYuMAzHWajf0rUqW4gD14qz1Gi4H7qhQhKedsZHc9((ghRMsrL9Gw0GX(4XVVVXXQPuewqqA6(4XVVVXXQPuuBL3h(9RVp0777wm6JAKrQccytmBWqn1ZraJyPk3ho7JbuoW9XJFFSTpJPlYQkEezKQGa2eZgmut98(W7qnpLT6qRonLAKPm1YcHbskOJCHGrONRghkRgebpCh6q9GKyqAouiTuUF99VYYtAcyelv5(WzFmGYouZtzRo0QttPgzktTSqyGKc6ixibEqxnouwnicE4o0HoyPhKvu2Qdf7FTpM)0uQr2hn1YcHbsk4(PCFk9WsTmG9tcl5(uIW7t9(fsE)MozW(iwOVgS)OjPd18u2Qd1BcX08u26uKsYH6bjXG0COJMIvNMsnYuMAzHWajfmsPhwQL7xFFO3334y1ukQz5jnVmEF843334y1ukIJv6miyF4DOIust1qyhQVXXQPKJCHeigUACOSAqe8WDOd18u2Qd1kBnOd1dsIbP5qhnfTYwdgbmILQCF4S)nDO(GEbpjduYK0fcgoYfsGb6QXHAEkB1HEAfk5qz1Gi4H7qh5cjWd4QXHYQbrWd3HouZtzRoujZJzFn9nauurzRo0bl9GSIYwDOO9X9PtEFuMhY9BD)dSpzGsMK7Nx7N0(PuXI23xaaSsIG7N6(xIS8K2Vb736(0jVpzGsMI7J9M05(Oz1zR7dv5fVFsyj33eYEFimrmyFQ3VqY7JY8y)ghd2hX0cticUVvvjcMA5(hyFOObGIkkBvgDOEqsminhQ5PehpzLrswUpC3pW9RVpzcwPOSpoPtEkzEiJSAqe8y)67JT9hnfLmpM9103aqrfLTgP0dl1Y9RVp22p15Lilpjh5cjWB6QXHYQbrWd3HoupijgKMd18uIJNSYijl3hU7h4(13NmbRuuMvNTof5fhz1Gi4X(13hB7pAkkzEm7RPVbGIkkBnsPhwQL7xFFSTFQZlrwEs7xF)rtrFdafvu2AeWiwQY9HZ(30HAEkB1HkzEm7RPVbGIkkB1rUqcetC14qz1Gi4H7qhQhKedsZHc9(YUqmLNgySpC3hJ9XJFFZtjoEYkJKSCF4UFG7d)(1333Ty0h1OSabP15WaWkfgGJagXsvUpC3hJaDOMNYwDO4sbpjlvYrUqcek7QXHYQbrWd3HoupijgKMd18uIJNJMIfQKmicEAxxI0tzR7hE)dUpE87tPhwQL7xF)rtXcvsgebpTRlr6PS1iGrSuL7dN9VPd18u2QdTqLKbrWt76sKEkB1rUqcm06QXHYQbrWd3HoupijgKMdfB77BCSAkfv2dArdgoujbsp5cbdhQ5PSvhQ3eIP5PS1PiLKdvKsAQgc7q9nownLCKlKaVrxnouwnicE4o0HAEkB1H6BaOOIYwDO(GEbpjduYK0fcgo0bl9GSIYwDOyQQkrW9HIgakQOS19rmTWeIG736(yCdbUpzGsMKbSFd2V19pW(ht6CFmfezlkiEFOObGIkkB1H6bjXG0COMNsC8Kvgjz5(Wz)BU)nSp07tMGvkk7Jt6KNsMhYiRgebp2hp(9jtWkfLz1zRtrEXrwnicESp8ouYaLmnZlh6OPOVbGIkkBncyelv5(Wz)aDKlKad9C14qz1Gi4H7qhQ5PSvhkIj4R0pbwfvayh6GLEqwrzRoum1fXG9PtE)UIvgeW(Ykwh7B7lpnWy)JNSUVr7Jj736(HMMGVs)(HoRIka8(uVVHRZX(nog4TQQulDOEqsminhQSlet5Pbg7d39V5(13NseEF4UFGy4ixih4GUACOSAqe8WDOdDWspiROSvhk27jR7RnTVmO6tTCFm)PPuJSpAQLfcdKuW9PEFmhzLodcQnKS8K2p0OXbSpAbcsR7dLmaSsHb49ZR9nHy)rtY9naVVvvjsE4qnpLT6q9MqmnpLTofPKCOEqsminhk077BCSAkfXXkDgeSF99X2(KjyLIvNMsnYuMAzHWajfmYQbrWJ9RV)OPyIuX6i1YP3itsGU6KNJMIu6HLA5(1333Ty0h1OSabP15WaWkfgGJa2gb3h(9XJFFO3334y1ukQz5jnVmE)67JT9jtWkfRonLAKPm1YcHbskyKvdIGh7xF)rtrzxiMGMIu6HLA5(1333Ty0h1OSabP15WaWkfgGJa2gb3h(9XJFFO3h699nownLIk7bTObJ9XJFFFJJvtPiSGG009XJFFFJJvtPO2kVp87xFFF3IrFuJYceKwNddaRuyaocyBeCF4DOIust1qyh6WaWkfgGNvaUYrUqoagUACOSAqe8WDOd18u2QdDyaytzxiCOdw6bzfLT6qd9l59Hsga2(ODHy)8AFOKbGvkmaV)XwXI2hcVpGTrW9Tsl1a2Vb7Nx7tNmG3)yke7dH33O9fSjP9dCFKgW7dLmaSsHb49lKS0H6bjXG0COqAPC)6777wm6JAuwGG06CyayLcdWraJyPk3hU7FLLN0eWiwQY9RVp07JT9jtWkfRonLAKPm1YcHbskyKvdIGh7Jh)((UfJ(OgRonLAKPm1YcHbskyeWiwQY9H7(xz5jnbmILQCF4DKlKdeORghkRgebpCh6q9GKyqAouSTpzcwPy1PPuJmLPwwimqsbJSAqe8y)6777wm6JAuwGG06CyayLcdWraJyPk3)299Dlg9rnklqqADomaSsHb44Oayu26(Wz)RS8KMagXsv6qnpLT6qhga2u2fch5c5ahWvJdLvdIGhUdDOdw6bzfLT6qHcJ8N3Gje7NeJSFH0k59VAW(MgKotTCFTP9LvSpVsESplK8XtgWouZtzRouVjetZtzRtrkjhQiL0une2HMeJ4ixih4MUACOSAqe8WDOd1dsIbP5qfmowSpC3htcT7xFFO3FWqkUUIYtB0hNmceG55OKmpS9HZ(qVFG7Fd7BEkBnkpTrFCcPfum15LilpP9HFF843FWqkUUIYtB0hNmceG55iGrSuL7dN9pW(W7qnpLT6q9MqmnpLTofPKCOIust1qyhQKDKlKdGjUACOSAqe8WDOd18u2QdfXe8v6NaRIkaSdDWspiROSvhAOFjVFOPj4R0VFOZQOcaV)Xtw3hXc91G9hnj33a8(fvbSFd2pV2NozaV)Xui2hcVVml18k9Ms7tjcVFHsPyF6K3xzOM2hZFAk1i7JMAzHWajf0H6bjXG0COJMI4sbpjlvksPhwQL7Jh)(JMIjsfRJulNEJmjb6QtEoAksPhwQL7Jh)(JMIYUqmbnfP0dl1sh5c5aqzxnouwnicE4o0H6bjXG0COKjyLIvNMsnYuMAzHWajfmYQbrWJ9RVp07pAkwDAk1itzQLfcdKuWiLEyPwUpE8777wm6JAS60uQrMYullegiPGraJyPk3hU7hiMSpE87FLLN0eWiwQY9HZ((UfJ(OgRonLAKPm1YcHbskyeWiwQY9H3HAEkB1HIyc(k9tGvrfa2rUqoqO1vJdLvdIGhUdDOEqsminhkzcwPOSpoPtEkzEiJSAqe8WHAEkB1HIyc(k9tGvrfa2rUqoWn6QXHYQbrWd3HouZtzRo0bWsDkYl2HoyPhKvu2QdfkbSu3hQYlE)uUFRIG7B7dLW8O7xAPU)XKo3h7RmUKmicEFOeJKsEFLnW(iguVVKmpmzCFS)1(xz5jTFk33G0f0(uVpRJ9h9(At7JKs5(YkwhPwUpDY7ljZdt6q9GKyqAouifxxXuzCjzqe8CWiPKJsY8W2hU7FZdUpE87dP46kMkJljdIGNdgjLCSOA)67FLLN0eWiwQY9HZ(30rUqoqONRghkRgebpCh6qnpLT6q9MqmnpLTofPKCOIust1qyhQVXXQPKJCHCZd6QXHYQbrWd3HouZtzRouRS1GoupijgKMdfWxawEAqeSd1h0l4jzGsMKUqWWrUqUjgUACOSAqe8WDOd1dsIbP5qnpL445OPyHkjdIGN21Li9u26(H3)G7Jh)(u6HLA5(13hWxawEAqeSd18u2QdTqLKbrWt76sKEkB1rUqUzGUACOSAqe8WDOd18u2QdvMvNTof5f7q9GKyqAouaFby5PbrWouFqVGNKbkzs6cbdh5c5MhWvJdLvdIGhUdDOMNYwDO(gakQOSvhQhKedsZHc4lalpnicE)67BEkXXtwzKKL7dN9V5(3W(qVpzcwPOSpoPtEkzEiJSAqe8yF843NmbRuuMvNTof5fhz1Gi4X(W7q9b9cEsgOKjPlemCKlKBEtxno0ujgakQihkgouZtzRo0bWsDk7cHdLvdIGhUdDKlKBIjUACOMNYwDOYtB0hNqAb5qz1Gi4H7qh5ihAfG9nceJC14cbdxnouwnicE4o0H6bjXG0COuIW7d39p4(13hB7xXu0ejoE)67JT9HuCDflbjsNaE2xtP5b5v65yrLd18u2Qd9IfZrJKQrzRoYfsGUACOMNYwDOYceKwNxS4Sqjg4qz1Gi4H7qh5c5aUACOSAqe8WDOd1dsIbP5qjtWkflbjsNaE2xtP5b5v65iRgebpCOMNYwDOLGePtap7RP08G8k9SJCHCtxnouwnicE4o0H2voujtouZtzRouCginic2HIZefSd18uIJNJMI(gakQOS19H7(hC)67BEkXXZrtrRS1G7d39p4(1338uIJNJMIfQKmicEAxxI0tzR7d39p4(13h69X2(KjyLIYS6S1PiV4iRgebp2hp(9npL445OPOmRoBDkYlEF4U)b3h(9RVp07pAkwDAk1itzQLfcdKuWiLEyPwUpE87JT9jtWkfRonLAKPm1YcHbskyKvdIGh7dVdfNbMQHWo0rtYjGTrqh5cbtC14qz1Gi4H7qhQAiSd1WCsEAatoVALM91SQpYahQ5PSvhQH5K80aMCE1kn7RzvFKboYfcu2vJdLvdIGhUdDOMNYwDOsMhZ(A6BaOOIYwDOEqsminhQSIfIjzGsMKrjZJzFn9nauurzRtR59HB49pGdvKkp9dhkgh0rUqcTUACOMNYwDONwHsouwnicE4o0rUqUrxnouZtzRo0cvsgebpTRlr6PSvhkRgebpCh6ih5qTMD14cbdxnouZtzRo0QttPgzktTSqyGKc6qz1Gi4H7qh5cjqxnouZtzRo0tRqjhkRgebpCh6ixihWvJdLvdIGhUdDOEqsminhk077BCSAkfXXkDgeSF99hnftKkwhPwo9gzsc0vN8C0uKspSul3V(((UfJ(OgLfiiTohgawPWaCeW2i4(13h69hnfRonLAKPm1YcHbskyeWiwQY9H7(bUpE87JT9jtWkfRonLAKPm1YcHbskyKvdIGh7d)(WVpE87d9((ghRMsrnlpP5LX7xF)rtrzxiMGMIu6HLA5(1333Ty0h1OSabP15WaWkfgGJa2gb3V((qV)OPy1PPuJmLPwwimqsbJagXsvUpC3pW9XJFFSTpzcwPy1PPuJmLPwwimqsbJSAqe8yF43h(9RVp07d9((ghRMsrL9Gw0GX(4XVVVXXQPuewqqA6(4XVVVXXQPuuBL3h(9RV)OPy1PPuJmLPwwimqsbJu6HLA5(13F0uS60uQrMYullegiPGraJyPk3ho7h4(W7qnpLT6q9MqmnpLTofPKCOIust1qyh6WaWkfgGNvaUYrUqUPRghkRgebpCh6q9GKyqAouYeSsrzFCsN8uY8qgz1Gi4X(133B6uY8WHAEkB1HkzEm7RPVbGIkkB1rUqWexnouwnicE4o0H6bjXG0COyBFYeSsrzFCsN8uY8qgz1Gi4X(13hB7pAkkzEm7RPVbGIkkBnsPhwQL7xFFSTFQZlrwEs7xF)rtrFdafvu2AeWxawEAqeSd18u2QdvY8y2xtFdafvu2QJCHaLD14qz1Gi4H7qhQ5PSvhQv2AqhQhKedsZHAEkXXZrtrRS1G7dN9V5(13hWxawEAqeSd1h0l4jzGsMKUqWWrUqcTUACOSAqe8WDOd18u2Qd1kBnOd1dsIbP5qnpL445OPOv2AW9HB49V5(13hWxawEAqe8(13F0u0kBnyKspSulDO(GEbpjduYK0fcgoYfYn6QXHYQbrWd3HoupijgKMd18uIJNJMIfQKmicEAxxI0tzR7hE)dUpE87tPhwQL7xFFaFby5PbrWouZtzRo0cvsgebpTRlr6PSvh5cj0ZvJdLvdIGhUdDOMNYwDOfQKmicEAxxI0tzRoupijgKMdfB7tPhwQL7xF)kCvKjyLIadPYuAAxxI0tzRYiRgebp2V((MNsC8C0uSqLKbrWt76sKEkBDF4S)bCO(GEbpjduYK0fcgoYfcgh0vJdLvdIGhUdDOEqsminhQSlet5Pbg7d39XWHAEkB1HIlf8KSujh5cbdmC14qz1Gi4H7qhQhKedsZHIT99nownLIk7bTObdhQKaPNCHGHd18u2Qd1BcX08u26uKsYHksjnvdHDO(ghRMsoYfcgb6QXHYQbrWd3HoupijgKMdf699nownLI4yLodc2V((qVVVBXOpQXePI1rQLtVrMKaD1jhbSncUpE87pAkMivSosTC6nYKeORo55OPiLEyPwUp87xFFF3IrFuJYceKwNddaRuyaocyBeC)67d9(JMIvNMsnYuMAzHWajfmcyelv5(WD)a3hp(9X2(KjyLIvNMsnYuMAzHWajfmYQbrWJ9HFF43V((qVp077BCSAkfv2dArdg7Jh)((ghRMsrybbPP7Jh)((ghRMsrTvEF43V(((UfJ(OgLfiiTohgawPWaCeWiwQY9HZ(bUF99HE)rtXQttPgzktTSqyGKcgbmILQCF4UFG7Jh)(yBFYeSsXQttPgzktTSqyGKcgz1Gi4X(WVp87d9((ghRMsrnlpP5LX7xFFO333Ty0h1OSletqtraBJG7Jh)(JMIYUqmbnfP0dl1Y9HF)6777wm6JAuwGG06CyayLcdWraJyPk3ho7h4(13h69hnfRonLAKPm1YcHbskyeWiwQY9H7(bUpE87JT9jtWkfRonLAKPm1YcHbskyKvdIGh7d)(W7qnpLT6q9MqmnpLTofPKCOIust1qyh6WaWkfgGNvaUYrUqW4aUACOSAqe8WDOd1dsIbP5q9Dlg9rnklqqADomaSsHb4iGrSuL7d39VYYtAcyelv5(13h69X2(KjyLIvNMsnYuMAzHWajfmYQbrWJ9XJFFF3IrFuJvNMsnYuMAzHWajfmcyelv5(WD)RS8KMagXsvUp8ouZtzRo0HbGnLDHWrUqW4MUACOSAqe8WDOd1dsIbP5q9Dlg9rnklqqADomaSsHb4iGrSuL7F7((UfJ(OgLfiiTohgawPWaCCuamkBDF4S)vwEstaJyPkDOMNYwDOddaBk7cHJCHGbM4QXHYQbrWd3HouZtzRouVjetZtzRtrkjhQiL0une2HMeJ4ixiyaLD14qz1Gi4H7qhQ5PSvhQ3eIP5PS1PiLKdvKsAQgc7qhSWcYJjbsfgtsh5cbJqRRghkRgebpCh6qnpLT6q9MqmnpLTofPKCOIust1qyh6WqSsEsGuHXK0rUqW4gD14qz1Gi4H7qhQhKedsZHoAkwDAk1itzQLfcdKuWiLEyPwUpE87JT9jtWkfRonLAKPm1YcHbskyKvdIGhouZtzRouVjetZtzRtrkjhQiL0une2HkjJMeivymjDKlemc9C14qz1Gi4H7qhQhKedsZHoAkIlf8KSuPiLEyPw6qnpLT6qrmbFL(jWQOca7ixibEqxnouwnicE4o0H6bjXG0COJMIYUqmbnfP0dl1Y9RVp22NmbRuu2hN0jpLmpKrwnicE4qnpLT6qrmbFL(jWQOca7ixibIHRghkRgebpCh6q9GKyqAouSTpzcwPiUuWtYsLISAqe8WHAEkB1HIyc(k9tGvrfa2rUqcmqxnouwnicE4o0H6bjXG0COYUqmLNgySpC3)MouZtzRouetWxPFcSkQaWoYfsGhWvJdLvdIGhUdDOMNYwDOYS6S1PiVyhQhKedsZHAEkXXZrtrzwD26uKx8(Wj8(hy)67d4lalpnicE)67JT9hnfLz1zRtrEXrk9WsT0H6d6f8Kmqjtsxiy4ixibEtxnouwnicE4o0H6bjXG0CO(ghRMsrL9Gw0GHdvsG0tUqWWHAEkB1H6nHyAEkBDksj5qfPKMQHWouFJJvtjh5cjqmXvJdLvdIGhUdDOEqsminhkKIRRyQmUKmicEoyKuYrjzEy7d3W7JjhCF843hsX1vmvgxsgebphmsk5yr1(13)klpPjGrSuL7dN9XK9XJFFifxxXuzCjzqe8CWiPKJsY8W2hUH3)ayY(13F0uu2fIjOPiLEyPw6qnpLT6qhal1PiVyh5cjqOSRghAQedafvKdfdhQ5PSvh6ayPoLDHWHYQbrWd3HoYfsGHwxnouZtzRou5Pn6JtiTGCOSAqe8WDOJCKdnjgXvJlemC14qnpLT6qlK8mjgr6qz1Gi4H7qh5ihQKD14cbdxnouZtzRo0tRqjhkRgebpCh6ixib6QXHYQbrWd3Ho0ujgakQOzE5qhmKIRRO80g9XjJabyEokjZddUHpGd18u2QdDaSuNYUq4qtLyaOOIMLIgIjCOy4ixihWvJd18u2QdvEAJ(4eslihkRgebpCh6ih5qLKrtcKkmMKUACHGHRghkRgebpCh6qvdHDOPk9GcYGi4jMUWuQazoyCPNDOMNYwDOPk9GcYGi4jMUWuQazoyCPNDKlKaD14qz1Gi4H7qhQAiSdnvjbk8udKZrIlvEcHfchQ5PSvhAQscu4PgiNJexQ8ecleoYfYbC14qz1Gi4H7qhQAiSdTXXGlrFm1YPPjIn9wj7qnpLT6qBCm4s0htTCAAIytVvYoYfYnD14qz1Gi4H7qhQAiSdDyayiDRZb7HnRkial9S6zhQ5PSvh6WaWq6wNd2dBwvqaw6z1ZoYfcM4QXHYQbrWd3Hou1qyhkI5niaEkpzMMifY07qnpLT6qrmVbbWt5jZ0ePqMEh5cbk7QXHYQbrWd3Hou1qyh6LWq4zFnHyejyhQ5PSvh6LWq4zFnHyejyh5cj06QXHYQbrWd3Hou1qyh6rdgRmqoVaToCOMNYwDOhnySYa58c06WrUqUrxnouwnicE4o0HQgc7qjdIGPzFnhSSYsGd18u2QdLmicMM91CWYklboYfsONRghkRgebpCh6qvdHDOYuVkettwLatj5eInk5zFnVyq7tkOd18u2QdvM6vHyAYQeykjNqSrjp7R5fdAFsbDKlemoORghkRgebpCh6qvdHDOYuVkeZsHnsJAGCcXgL8SVMxmO9jf0HAEkB1Hkt9Qqmlf2inQbYjeBuYZ(AEXG2Nuqh5cbdmC14qnpLT6qHi6EmVkabDOSAqe8WDOJCHGrGUACOMNYwDOxjGHi6E4qz1Gi4H7qh5cbJd4QXHAEkB1HcHbsgal1shkRgebpCh6ih5ihQvqNnWHIMiqHJCKZba]] )


end