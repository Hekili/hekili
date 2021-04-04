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


    spec:RegisterPack( "Affliction", 20210404, [[d8ueGcqiOOwKeuspckL2KKQpbLmka1PakRcquvVsfQzja3sfe7sOFPcmmjLCmOWYeqptsPMMkOUguQSnaj9narzCaICoOuvwhqvnpGk3tcTpOiheqIfQc5HactufKUiukQnkbvLpkbvvNuckwPkvZeqQBkbLANsGFcLImuOuLLkbvEkKMQKIRkbvXwLGQ0xHsv1yLGSxQ6VkAWQ6WuwmapMktwHltSzvYNLOrRIoTOvdiQ8AGmBuUne7M0VLA4sYXHsHLd65OA6ixxqBhQ8DvkJhOkNxGwpGOkZhQ6(sqj2Vs7XWxJhDyK4liWAfig16W16WXAH9vRAJbqYJsbRepAL5azLIhvneXJcuUUyPJYw9OvwqwBdFnEuEhcDIh9KOko4FWbLjDgci6AKd4jsiZOSvh0UOd4jI7apkGWKrfg1dWJoms8feyTceJAD4AD4yTW(QvTQvGEuEL48feiqf78ON5yiQhGhDiCNhfOCDXshLTUp2VbzTd0EhOubt2(hoG9dSwbIXEFVdeNMwkCWFVFi7dugdzSpALWy7d0TduCVFi7dugdzS)Hk46q4(f2wz6I79dzFGYyiJ9bafdK70uvy7Z6Y0T)vd3)qHwQ7J2HS4E)q2VMBIbA)cBJjxPB)cNvrHqzFwxMU9PE)Bne0(51(b7qSGY(ijNNA5(2(KXeL2p19PtJ2h23I79dzFSz1aWK9lCgsLP0(aLRlw6OSv((ypCyV9jJjkf37hY(1Ctmq89PEFdxNJ9bW6BPwU)HAqqLmdk7N6(iHmkpeYGLcT)Td69puSPA47hwf37hY(arRdr5Y(8gr2)qniOsMbL9XEqPAFNXy89PEFOmcDY(UgPkKmkBDFkrK4E)q2hvO95nISVZySP5OS1jl50(IsWu47t9(CcMoAFQ33W15yF3P4aLA5(SKt89PtJ2)wRyr7dq2hkM7ugX9(HSp2KYcUpQiJ9B1j7xbLdPkKXI79dzFGYaixiN2VWkGqOUpqCO89bixnu2x0X(91(xz5jvyDFwxMU9PEFRQIfC)wzb3N69b0C((xz5jX3hyTP9jOXp3VYCG4Gf9OvW(kzIhfBX29bkxxS0rzR7J9Bqw7aT3XwSDFGsfmz7F4a2pWAfig799o2IT7deNMwkCWFVJTy7(hY(aLXqg7Jwjm2(aD7af37yl2U)HSpqzmKX(hQGRdH7xyBLPlU3XwSD)dzFGYyiJ9bafdK70uvy7Z6Y0T)vd3)qHwQ7J2HS4EhBX29pK9R5MyG2VW2yYv62VWzvuiu2N1LPBFQ3)wdbTFETFWoelOSpsY5PwUVTpzmrP9tDF60O9H9T4EhBX29pK9XMvdat2VWzivMs7duUUyPJYw57J9WH92NmMOuCVJTy7(hY(1Ctmq89PEFdxNJ9bW6BPwU)HAqqLmdk7N6(iHmkpeYGLcT)Td69puSPA47hwf37yl2U)HSpq06quUSpVrK9pudcQKzqzFShuQ23zmgFFQ3hkJqNSVRrQcjJYw3NsejU3XwSD)dzFuH2N3iY(oJXMMJYwNSKt7lkbtHVp17Zjy6O9PEFdxNJ9DNIduQL7ZsoX3NonA)BTIfTpazFOyUtze37yl2U)HSp2KYcUpQiJ9B1j7xbLdPkKXI7DSfB3)q2hOmaYfYP9lScieQ7dehkFFaYvdL9fDSFFT)vwEsfw3N1LPBFQ33QQyb3VvwW9PEFanNV)vwEs89bwBAFcA8Z9RmhioyX9(E3Cu2kpwbfxJaWOIxcBoAKunkBnG8QiLicMQvDmxju0yjoPoMbeEDflHjsNqz2xtU5G5v6Kyy1E3Cu2kpwbfxJaWOJlEapebP1zLq7DZrzR8yfuCncaJoU4bLWePtOm7Rj3CW8kDsa5vrYyIsXsyI0juM91KBoyELojkQbGjJ9U5OSvESckUgbGrhx8aCgmnamja1qKIJM4tOyJGbGZyHsrZrjozoAk6AimSIYwXuTQBokXjZrtrRS1GyQw1nhL4K5OPyOYjdatM21flDu2kMQvDGXmzmrPipRoBDYYljkQbGjd84nhL4K5OPipRoBDYYlbt1cS6apAkwDAk1itEQLHmdMuWiLoqPwIhpMjJjkfRonLAKjp1YqMbtkyuudatgGT3nhLTYJvqX1iam64IheYLzscsaQHifnG84Ng04ZRwPzFnR6BcCVBokBLhRGIRray0XfpGlYy2xtxdHHvu2AaSuLPBueJAfqEvKxjm2KmyPq8ixKXSVMUgcdROS1P1cMkw79U5OSvESckUgbGrhx8GtluP9U5OSvESckUgbGrhx8GqLtgaMmTRlw6OS19(EhBX29XMbpXfsYyFbNadUpLiY(0PSV5OgUFY33WzjZaWK4E3Cu2kViVsySjRDG27MJYw5hx8GHGRdHteRmD7DZrzR8JlEGZySP5OS1jl5uaQHifTwcGtW0rfXiG8QO5OeNmfvqsHJPAV3X29bkokBDFwYj((xnCFcMkiH2hGCA4Ygg3hLmIVVbL95gozS)vd3hGC1qzF0oKTFHRPdkmivIosTCFGWiJtWU6uoa7DAk1i7JMAziZGjfmG9B6uG3sUSFR776Mn6B6E3Cu2k)4Ih4mgBAokBDYsofGAisrcMkiHM8kwst3P4afaNGPJkIra5vrkreWHXE3Cu2k)4Ih4mgBAokBDYsofGAisXHWSGYysWubjeFVBokBLFCXdCgJnnhLTozjNcqnePiNmAsWubjepaobthveJaYRIapAkY7q2e2uKshOulXJF0umrQeDKA50zKXjyxDkZrtrkDGsTep(rtXQttPgzYtTmKzWKcgP0bk1sWQZ7q2KFAWbMQnE8JMI4sMmjlvksPduQL4XtgtukY7Bt6uMCrg89U5OSv(XfpWzm20Cu26KLCka1qKIddXkLjbtfKq8a4emDurmciVk6ACIAkf1S8KMxMuhymJZGPbGjrcMkiHM8kws4X76Mn6BAK3HSjSPiuqSu5ykWAHhpW4myAaysKGPcsOzRsDx3SrFtJ8oKnHnfHcILkhCemvqcfXi66Mn6BAekiwQCWWJhyCgmnamjsWubj0KU11DDZg9nnY7q2e2uekiwQCWrWubjumWORB2OVPrOGyPYbdS9U5OSv(XfpWzm20Cu26KLCka1qKIddXkLjbtfKq8a4emDurmciVk6ACIAkfXjkDgewhymJZGPbGjrcMkiHM8kws4X76Mn6BAmrQeDKA50zKXjyxDkrOGyPYXuG1cpEGXzW0aWKibtfKqZwL6UUzJ(MgtKkrhPwoDgzCc2vNsekiwQCWrWubjueJORB2OVPrOGyPYbdpEGXzW0aWKibtfKqt6wx31nB030yIuj6i1YPZiJtWU6uIqbXsLdocMkiHIbgDDZg9nncfelvoyGT3nhLTYpU4boJXMMJYwNSKtbOgIuCyiwPmjyQGeIhaNGPJkIra5vrGDnornLIQ4GnRHd84DnornLIGccttXJ314e1ukQTkGvhymJZGPbGjrcMkiHM8kws4X76Mn6BAS60uQrM8uldzgmPGrOGyPYXuG1cpEGXzW0aWKibtfKqZwL6UUzJ(MgRonLAKjp1YqMbtkyekiwQCWrWubjueJORB2OVPrOGyPYbdpEGXzW0aWKibtfKqt6wx31nB030y1PPuJm5PwgYmysbJqbXsLdocMkiHIbgDDZg9nncfelvoyGT3nhLTYpU4boJXMMJYwNSKtbOgIuCyiwPmjyQGeIhaNGPJkIra5vrmtgtukwDAk1itEQLHmdMuWOOgaMmQdmMXzW0aWKibtfKqtEflj84DDZg9nnYdrqADomiOsMbLiuqSu5ykWAHhpW4myAaysKGPcsOzRsDx3SrFtJ8qeKwNddcQKzqjcfelvo4iyQGekIr01nB030iuqSu5GHhpW4myAaysKGPcsOjDRR76Mn6BAKhIG06CyqqLmdkrOGyPYbhbtfKqXaJUUzJ(MgHcILkhmW27y7(hfc195DiBF(Pbh89ZR9VYYtA)KVVXqAoTFJtG7DZrzR8JlEaIXKR0nHwffcLaYRIaAoV(vwEstOGyPYbNaEIlKKjLicq(8oKn5NgCuF0umu5KbGjt76ILokBnsPduQL7DSD)cZ1(UgNOMs7pA6aS3PPuJSpAQLHmdMuW9t((WqvtTmG9d5Y(hQbbvYmOSp17lGhj6yF6u23fcHIs7ZfAVBokBLFCXdCgJnnhLTozjNcqneP4WGGkzguMvqPkG8QiWUgNOMsrCIsNbH1hnftKkrhPwoDgzCc2vNYC0uKshOulR76Mn6BAKhIG06CyqqLmdkrOGyPYbxG1bE0uS60uQrM8uldzgmPGrOGyPYXuG4XJzYyIsXQttPgzYtTmKzWKccgy4XdSRXjQPuuZYtAEzs9rtrEhYMWMIu6aLAzDx3SrFtJ8qeKwNddcQKzqjcfelvo4cSoWJMIvNMsnYKNAziZGjfmcfelvoMcepEmtgtukwDAk1itEQLHmdMuqWadpEGb214e1ukQId2SgoWJ314e1ukckimnfpExJtutPO2Qaw9rtXQttPgzYtTmKzWKcgP0bk1Y6JMIvNMsnYKNAziZGjfmcfelvo4ceS9o2UFHtUGc)C)rt89fdYcUFETFzNA5(Ps9(2(8tdo2Nxj6i1Y9RonUS3nhLTYpU4boJXMMJYwNSKtbOgIuC00SckvbKxfb214e1ukQz5jnVmPoMhnf5DiBcBksPduQL1DDZg9nnY7q2e2uekiwQCWDyWWJhyxJtutPiorPZGW6yE0umrQeDKA50zKXjyxDkZrtrkDGsTSURB2OVPXePs0rQLtNrgNGD1PeHcILkhChgm84bgyxJtutPOkoyZA4apExJtutPiOGW0u84DnornLIARcy1jJjkfRonLAKjp1YqMbtkyDmpAkwDAk1itEQLHmdMuWiLoqPww31nB030y1PPuJm5PwgYmysbJqbXsLdUdd2EhB3VWCTp270uQr2hn1YqMbtk4(jFFkDGsTmG9tA)KVp3UK9PE)qUS)HAqq7J2HS9U5OSv(XfpyyqqtEhYciVkoAkwDAk1itEQLHmdMuWiLoqPwU3nhLTYpU4bddcAY7qwa5vrmtgtukwDAk1itEQLHmdMuW6apAkY7q2e2uKshOulXJF0umrQeDKA50zKXjyxDkZrtrkDGsTeS9o2UpAq1Tp270uQr2hn1YqMbtk4(3s6C)cVIsNbHhuqwEs7x4ZK9DnornL2F0ua730PaVLCz)qUSFR776Mn6BAC)cZ1(yZivbHIX2hBcoutDY(acVU2p57NQRrsTmG9pB2y)qLs2(jHfFFOyJG7dmgaP95IR1bFF7Ie4(HCbS9U5OSv(XfpO60uQrM8uldzgmPGbKxfDnornLIAwEsZltQtjIGjSRURB2OVPrEhYMWMIqbXsLdomQdmbtfKqrbPkium2SHd1uNeDDZg9nncfelvo4WaOgiE8ywWgHzvLmIcsvqOySzdhQPobS9U5OSv(XfpO60uQrM8uldzgmPGbKxfDnornLI4eLodcRtjIGjSRURB2OVPXePs0rQLtNrgNGD1PeHcILkhCyuhycMkiHIcsvqOySzdhQPoj66Mn6BAekiwQCWHbqnq84XSGncZQkzefKQGqXyZgoutDcy7DZrzR8JlEq1PPuJm5PwgYmysbdiVkcSRXjQPuufhSznCGhVRXjQPueuqyAkE8UgNOMsrTvbS6atWubjuuqQccfJnB4qn1jrx3SrFtJqbXsLdomaQbIhpMfSrywvjJOGufekgB2WHAQtaBVBokBLFCXdQonLAKjp1YqMbtkya5vranNx)klpPjuqSu5GddG6EhB3VWCTp270uQr2hn1YqMbtk4(jFFkDGsTmG9tcl((uIi7t9(HCz)Mof4(igqUgU)Oj(E3Cu2k)4Ih4mgBAokBDYsofGAisrxJtutPaYRIJMIvNMsnYKNAziZGjfmsPduQL1b214e1ukQz5jnVmbpExJtutPiorPZGqW27MJYw5hx8aRS1Gb4c6yYKmyPq8IyeqEvC0u0kBnyekiwQCWD49U5OSv(Xfp40cvAVJT7J232NoL9rfzW3V19R9(KblfIVFETFs7NCflAFxiekkXcUFQ7FXYYtA)gUFR7tNY(KblfkUp2FsN7JMvNTUpqNxY(jHfFFJX79biejW9PE)qUSpQiJ9BCcCFetdngl4(wvflyQL7x79bIgcdROSvECVBokBLFCXd4ImM9101qyyfLTgqEv0CuItMIkiPWXuG1jJjkf59TjDktUidEDmpAkYfzm7RPRHWWkkBnsPduQL1XCQZlwwEs7DZrzR8JlEaxKXSVMUgcdROS1aYRIMJsCYuubjfoMcSozmrPipRoBDYYlPoMhnf5ImM9101qyyfLTgP0bk1Y6yo15fllpP6JMIUgcdROS1iuqSu5G7W7DZrzR8JlEaUKjtYsLciVkcmVdzt(Pbhycd84nhL4KPOcskCmfiy1DDZg9nnYdrqADomiOsMbLiuqSu5ycJa37MJYw5hx8GqLtgaMmTRlw6OS1aYRIMJsCYC0umu5KbGjt76ILokBTyTWJNshOulRpAkgQCYaWKPDDXshLTgHcILkhChEVBokBLFCXdCgJnnhLTozjNcqnePORXjQPuaCcMoQigbKxfXSRXjQPuufhSznCS3X29bkvvSG7denegwrzR7JyAOXyb3V19X4qcCFYGLcXdy)gUFR7x79VL05(afa8MfsY(ardHHvu26E3Cu2k)4Ih4AimSIYwdWf0XKjzWsH4fXiG8QO5OeNmfvqsHdUdFiatgtukY7Bt6uMCrgC84jJjkf5z1zRtwEjGvF0u01qyyfLTgHcILkhCbU3X29bkxKa3NoL97krfya7ZReDSVTp)0GJ9VDk6(gTp2TFR7xyBm5kD7x4Skkek7t9(gUoh734eOZQQsTCVBokBLFCXdqmMCLUj0QOqOeqEvK3HSj)0GdmD46uIiykqm27y7(y)NIUV20(8GQl1Y9XENMsnY(OPwgYmysb3N69l8kkDgeEqbz5jTFHptcyF0qeKw3)qniOsMbL9ZR9ngB)rt89nOSVvvXszS3nhLTYpU4boJXMMJYwNSKtbOgIuCyqqLmdkZkOufqEveyxJtutPiorPZGW6yMmMOuS60uQrM8uldzgmPG1hnftKkrhPwoDgzCc2vNYC0uKshOulR76Mn6BAKhIG06CyqqLmdkrOyJGGHhpWUgNOMsrnlpP5Lj1XmzmrPy1PPuJm5PwgYmysbRpAkY7q2e2uKshOulR76Mn6BAKhIG06CyqqLmdkrOyJGGHhpWa7ACIAkfvXbBwdh4X7ACIAkfbfeMMIhVRXjQPuuBvaRURB2OVPrEicsRZHbbvYmOeHIncc2EhB3VWdx2)qniO9r7q2(51(hQbbvYmOS)TwXI2hGSpuSrW9Tsl1a2VH7Nx7tNcu2)wYy7dq23O9zIXP9dCFKgk7FOgeujZGY(HCHV3nhLTYpU4bddcAY7qwa5vranNx31nB030ipebP15WGGkzguIqbXsLJPRS8KMqbXsLxhymtgtukwDAk1itEQLHmdMuq84DDZg9nnwDAk1itEQLHmdMuWiuqSu5y6klpPjuqSu5GT3nhLTYpU4bddcAY7qwa5vranNxhZKXeLIvNMsnYKNAziZGjfSURB2OVPrEicsRZHbbvYmOeHcILk)yx3SrFtJ8qeKwNddcQKzqjocHgLTcURS8KMqbXsLV3X29bcJCNhIXy7NKGSFi3kL9VA4(MgKotTCFTP95vIlVszSVW4YTtbk7DZrzR8JlEGZySP5OS1jl5uaQHiftsq27yl2UFHtUGc)CF0tB032hBgba0CY(aKRgk7ZReDKA5(8tdo4736(f2gtUs3(foRIcHYE3Cu2k)4Ih4mgBAokBDYsofGAisrUeqEvKj4egMWoGS6apeaHxxr(Pn6Btbba0CsKtMde4aoWdXCu2AKFAJ(2eqZOyQZlwwEsGHh)qaeEDf5N2OVnfeaqZjrOGyPYbxTbBVJT7x4Hl7xyBm5kD7x4Skkek7F7u09rmGCnC)rt89nOSFyva73W9ZR9Ptbk7FlzS9bi7ZZsnVsNP0(uIi7hQuY2NoL9vb8O9XENMsnY(OPwgYmysb37MJYw5hx8aeJjxPBcTkkekbKxfhnfXLmzswQuKshOulXJF0umrQeDKA50zKXjyxDkZrtrkDGsTep(rtrEhYMWMIu6aLA5E3Cu2k)4IhGym5kDtOvrHqjG8QizmrPy1PPuJm5PwgYmysbRd8OPy1PPuJm5PwgYmysbJu6aLAjE8UUzJ(MgRonLAKjp1YqMbtkyKGHYekiwQCmfi2HhpGMZRFLLN0ekiwQCW56Mn6BAS60uQrM8uldzgmPGrOGyPYbBVBokBLFCXdqmMCLUj0QOqOeqEvKmMOuK33M0Pm5Im47DSD)dfAPUpqNxY(jF)wzb332)qXEO7xAPU)TKo3VWOcUKmamz)dvqsUSVkgCFed82NtMdepUFH5A)RS8K2p57Ba6qAFQ3x0X(JEFTP9rsoFFELOJul3NoL95K5aX37MJYw5hx8Gb0sDYYljG8QiGWRRyQcUKmamzoeKKlrozoqy6W1cpEaHxxXufCjzayYCiijxIHv1b0CE9RS8KMqbXsLdUdV3nhLTYpU4boJXMMJYwNSKtbOgIu014e1uAVBokBLFCXdSYwdgGlOJjtYGLcXlIra5vrOCbf(PbGj7DZrzR8JlEqOYjdatM21flDu2Aa5vrZrjozoAkgQCYaWKPDDXshLTwSw4XtPduQL1HYfu4NgaMS3nhLTYpU4b8S6S1jlVKaCbDmzsgSuiErmciVkcLlOWpnamzVBokBLFCXdCnegwrzRb4c6yYKmyPq8IyeqEvekxqHFAaysDZrjozkQGKchCh(qaMmMOuK33M0Pm5Im44XtgtukYZQZwNS8saBVBokBLFCXdgql1jVdzbKkjqyyfveJ9U5OSv(XfpGFAJ(2eqZO9(E3Cu2kpATuS60uQrM8uldzgmPG7DZrzR8O1YXfp40cvAVBokBLhTwoU4boJXMMJYwNSKtbOgIuCyqqLmdkZkOufqEveyxJtutPiorPZGW6JMIjsLOJulNoJmob7QtzoAksPduQL1DDZg9nnYdrqADomiOsMbLiuSrW6apAkwDAk1itEQLHmdMuWiuqSu5ykq84XmzmrPy1PPuJm5PwgYmysbbdm84b214e1ukQz5jnVmP(OPiVdztytrkDGsTSURB2OVPrEicsRZHbbvYmOeHIncwh4rtXQttPgzYtTmKzWKcgHcILkhtbIhpMjJjkfRonLAKjp1YqMbtkiyGvhyGDnornLIQ4GnRHd84DnornLIGccttXJ314e1ukQTkGvF0uS60uQrM8uldzgmPGrkDGsTS(OPy1PPuJm5PwgYmysbJqbXsLdUabBVBokBLhTwoU4bCrgZ(A6AimSIYwdiVksgtukY7Bt6uMCrg86otNCrg7DZrzR8O1YXfpGlYy2xtxdHHvu2Aa5vrmtgtukY7Bt6uMCrg86yE0uKlYy2xtxdHHvu2AKshOulRJ5uNxSS8KQpAk6AimSIYwJq5ck8tdat27MJYw5rRLJlEGv2AWaCbDmzsgSuiErmciVkAokXjZrtrRS1GG7W1HYfu4NgaMS3nhLTYJwlhx8aRS1Gb4c6yYKmyPq8IyeqEv0CuItMJMIwzRbXuXdxhkxqHFAays9rtrRS1GrkDGsTCVBokBLhTwoU4bHkNmamzAxxS0rzRbKxfnhL4K5OPyOYjdatM21flDu2AXAHhpLoqPwwhkxqHFAayYE3Cu2kpATCCXdcvozayY0UUyPJYwdWf0XKjzWsH4fXiG8QiMP0bk1Y6v4QiJjkfHgsLP00UUyPJYw5rrnamzu3CuItMJMIHkNmamzAxxS0rzRGR27DZrzR8O1YXfpaxYKjzPsbKxf5DiBYpn4atyS3nhLTYJwlhx8aNXytZrzRtwYPaudrk6ACIAkfaNGPJkIra5vrm7ACIAkfvXbBwdh7DZrzR8O1YXfpWzm20Cu26KLCka1qKIddcQKzqzwbLQaYRIa7ACIAkfXjkDgewhyx3SrFtJjsLOJulNoJmob7QtjcfBeep(rtXePs0rQLtNrgNGD1PmhnfP0bk1sWQ76Mn6BAKhIG06CyqqLmdkrOyJG1bE0uS60uQrM8uldzgmPGrOGyPYXuG4XJzYyIsXQttPgzYtTmKzWKccgy1bgyxJtutPOkoyZA4apExJtutPiOGW0u84DnornLIARcy1DDZg9nnYdrqADomiOsMbLiuqSu5GlW6apAkwDAk1itEQLHmdMuWiuqSu5ykq84XmzmrPy1PPuJm5PwgYmysbbdmGDnornLIAwEsZltQdSRB2OVPrEhYMWMIqXgbXJF0uK3HSjSPiLoqPwcwDx3SrFtJ8qeKwNddcQKzqjcfelvo4cSoWJMIvNMsnYKNAziZGjfmcfelvoMcepEmtgtukwDAk1itEQLHmdMuqWaBVBokBLhTwoU4bddcAY7qwa5vranNx31nB030ipebP15WGGkzguIqbXsLJPRS8KMqbXsLxhymtgtukwDAk1itEQLHmdMuq84DDZg9nnwDAk1itEQLHmdMuWiuqSu5y6klpPjuqSu5GT3nhLTYJwlhx8GHbbn5DilG8QiGMZR76Mn6BAKhIG06CyqqLmdkrOGyPYp21nB030ipebP15WGGkzguIJqOrzRG7klpPjuqSu57DZrzR8O1YXfpWzm20Cu26KLCka1qKIjji7DZrzR8O1YXfpWzm20Cu26KLCka1qKIdHzbLXKGPcsi(E3Cu2kpATCCXdCgJnnhLTozjNcqneP4WqSszsWubjeFVBokBLhTwoU4boJXMMJYwNSKtbOgIuKtgnjyQGeIhqEvC0uS60uQrM8uldzgmPGrkDGsTepEmtgtukwDAk1itEQLHmdMuW9U5OSvE0A54IhGym5kDtOvrHqjG8Q4OPiUKjtYsLIu6aLA5E3Cu2kpATCCXdqmMCLUj0QOqOeqEvC0uK3HSjSPiLoqPwwhZKXeLI8(2KoLjxKbFVBokBLhTwoU4bigtUs3eAvuiuciVkIzYyIsrCjtMKLkT3nhLTYJwlhx8aeJjxPBcTkkekbKxf5DiBYpn4athEVBokBLhTwoU4b8S6S1jlVKaCbDmzsgSuiErmciVkAokXjZrtrEwD26KLxc4kw76q5ck8tdatQJ5rtrEwD26KLxsKshOul37MJYw5rRLJlEGZySP5OS1jl5uaQHifDnornLcGtW0rfXiG8QORXjQPuufhSznCS3nhLTYJwlhx8Gb0sDYYljG8QiGWRRyQcUKmamzoeKKlrozoqyQi2vl84b0CEDaHxxXufCjzayYCiijxIHv1VYYtAcfelvo4Wo84beEDftvWLKbGjZHGKCjYjZbctfRn2vF0uK3HSjSPiLoqPwU3nhLTYJwlhx8Gb0sDY7qwaPscegwrfXyVBokBLhTwoU4b8tB03MaAgT337MJYw5rxJtutPIjsLOJulNoJmob7QtjG8QiMjJjkfRonLAKjp1YqMbtkyDGDDZg9nnYdrqADomiOsMbLiuqSu5GdJAHhVRB2OVPrEicsRZHbbvYmOeHcILkhtyxTQ76Mn6BAKhIG06CyqqLmdkrOGyPYXuGyxDxRJWKIUgcdROulNmrGGT3nhLTYJUgNOMshx8GePs0rQLtNrgNGD1PeqEvKmMOuS60uQrM8uldzgmPG1hnfRonLAKjp1YqMbtkyKshOul37MJYw5rxJtutPJlEWqCjIrPwob0mkG8QORB2OVPrEicsRZHbbvYmOeHcILkhtyxDGhcGWRR4PfQuekiwQCmDy84XmzmrP4PfQey7DZrzR8ORXjQP0XfpG3HSjSPaYRIyMmMOuS60uQrM8uldzgmPG1b21nB030ipebP15WGGkzguIqbXsLdoSdpEx3SrFtJ8qeKwNddcQKzqjcfelvoMWUAHhVRB2OVPrEicsRZHbbvYmOeHcILkhtbID1DToctk6AimSIsTCYebc2E3Cu2kp6ACIAkDCXd4DiBcBkG8QizmrPy1PPuJm5PwgYmysbRpAkwDAk1itEQLHmdMuWiLoqPwU3nhLTYJUgNOMshx8aURdHPwoPKoL9(E3Cu2kpomeRuMemvqcXlgYLzscsaQHif5DiBMLAscCVBokBLhhgIvktcMkiH4hx8GqUmtsqcqneP4ak24kHYeNW5cBVBokBLhhgIvktcMkiH4hx8GqUmtsqcqnePyjly15SVMgNNijZOS19(E3Cu2kpomiOsMbLzfuQkIlzYKSuP9U5OSvECyqqLmdkZkOuDCXdgge0K3HS9U5OSvECyqqLmdkZkOuDCXdQAkBDVBokBLhhgeujZGYSckvhx8GRekayDp27MJYw5XHbbvYmOmRGs1XfpaaR7X8kegCVBokBLhhgeujZGYSckvhx8aacKlqqPwU3nhLTYJddcQKzqzwbLQJlEGZySP5OS1jl5uaQHifDnornLciVkIzxJtutPOkoyZA4yVBokBLhhgeujZGYSckvhx8aEicsRZHbbvYmOS337MJYw5XHWSGYysWubjeVyixMjjibOgIuuqQccfJnB4qn1jbKxfb214e1ukQz5jnVmPURB2OVPrEhYMWMIqbXsLdUaRfy4XdSRXjQPueNO0zqyDx3SrFtJjsLOJulNoJmob7Qtjcfelvo4cSwGHhpWUgNOMsrvCWM1WbE8UgNOMsrqbHPP4X7ACIAkf1wfW27MJYw5XHWSGYysWubje)4IheYLzscsaQHif5Hkaw3JPHi0zqofqEveyxJtutPOMLN08YK6UUzJ(Mg5DiBcBkcfelvo4aQGHhpWUgNOMsrCIsNbH1DDZg9nnMivIosTC6mY4eSRoLiuqSu5GdOcgE8a7ACIAkfvXbBwdh4X7ACIAkfbfeMMIhVRXjQPuuBvaBVBokBLhhcZckJjbtfKq8JlEqixMjjibOgIuK3HmMquQLtyiGGbKxfb214e1ukQz5jnVmPURB2OVPrEhYMWMIqbXsLdoGey4XdSRXjQPueNO0zqyDx3SrFtJjsLOJulNoJmob7Qtjcfelvo4asGHhpWUgNOMsrvCWM1WbE8UgNOMsrqbHPP4X7ACIAkf1wfW277DZrzR84OPzfuQkALTgmG8Q4OPOv2AWiuqSu5Gdiv31nB030ipebP15WGGkzguIqbXsLJPrtrRS1GrOGyPY37MJYw5XrtZkOuDCXd4z1zRtwEjbKxfhnf5z1zRtwEjrOGyPYbhqQURB2OVPrEicsRZHbbvYmOeHcILkhtJMI8S6S1jlVKiuqSu57DZrzR84OPzfuQoU4bHkNmamzAxxS0rzRbKxfhnfdvozayY0UUyPJYwJqbXsLdoGuDx3SrFtJ8qeKwNddcQKzqjcfelvoMgnfdvozayY0UUyPJYwJqbXsLV3nhLTYJJMMvqP64Ih4AimSIYwdiVkoAk6AimSIYwJqbXsLdoGuDx3SrFtJ8qeKwNddcQKzqjcfelvoMgnfDnegwrzRrOGyPY377DZrzR8yscsXqUmtsq4799U5OSvEKlfpTqL27MJYw5rUCCXdgql1jVdzbKkjqyyfnlznaJveJasLeimSIM5vXHai86kYpTrFBkiaGMtICYCGWuXAV3nhLTYJC54IhWpTrFBcOz0EFVBokBLh5KrtcMkiH4fd5Ymjbja1qKIPYDWqYaWKj2i0ukezoeCPt27MJYw5roz0KGPcsi(XfpiKlZKeKaudrkMkNGHoQH85iXLQmbim2E3Cu2kpYjJMemvqcXpU4bHCzMKGeGAisXgNaVy9TulNMMi20zLYE3Cu2kpYjJMemvqcXpU4bHCzMKGeGAisXHbbH0TohId0SkKGc3jQt27MJYw5roz0KGPcsi(XfpiKlZKeKaudrkIyodauM8trOjsipD7DZrzR8iNmAsWubje)4IheYLzscsaQHifVygIm7RjaJiMS3nhLTYJCYOjbtfKq8JlEqixMjjibOgIu8MbsubYNxWwh7DZrzR8iNmAsWubje)4IheYLzscsaQHifjdatOzFnhcVYs4E3Cu2kpYjJMemvqcXpU4bHCzMKGeGAisrEQxHSPXRsOPeFcWgLYSVMxcSDjfCVBokBLh5KrtcMkiH4hx8GqUmtsqcqnePip1Rq2SKzJ0OgYNaSrPm7R5LaBxsb37MJYw5roz0KGPcsi(XfpaaR7X8kegCVBokBLh5KrtcMkiH4hx8GRekayDp27MJYw5roz0KGPcsi(XfpaGa5ceuQL799U5OSvEKGPcsOjVIL00DkoqfXzW0aWKaudrkYRexASPGncZQkzeaoJfkfbgyGfSrywvjJOGufekgB2WHAQt2clc2imRQKrmvUdgsgaMmXgHMsHiZHGlDcyBHfbBeMvvYiY7qgtik1YjmeqqW2clc2imRQKrKhQayDpMgIqNb5ey7DZrzR8ibtfKqtEflPP7uCGoU4b4myAaysaQHifjyQGeA2QeaoJfkfbMGPcsOigXtJpRGTlAAW6emvqcfXiEA8PRB2OVPGT3nhLTYJemvqcn5vSKMUtXb64IhGZGPbGjbOgIuKGPcsOjDRdaNXcLIatWubjumW4PXNvW2fnnyDcMkiHIbgpn(01nB03uW27MJYw5rcMkiHM8kwst3P4aDCXdWzW0aWKaudrkomeRuMemvqcfaoJfkfbgZatWubjueJ4PXNvW2fnnyDcMkiHIyepn(01nB03uWadpEGXmWemvqcfdmEA8zfSDrtdwNGPcsOyGXtJpDDZg9nfmWWJxWgHzvLmILSGvNZ(AACEIKmJYw37MJYw5rcMkiHM8kwst3P4aDCXdWzW0aWKaudrksWubj0KxXskaCglukcmodMgaMejyQGeA2QuhNbtdatIddXkLjbtfKqGHhpW4myAaysKGPcsOjDRRJZGPbGjXHHyLYKGPcsiWWJhyCgmnamjsWubj0SvzlSGZGPbGjrEL4sJnfSrywvjdWWJhyCgmnamjsWubj0KU1BHfCgmnamjYRexASPGncZQkzaMhfNa5zR(ccSwbIrToCTQDedp6ndQPwY9Oy)aLcxbfMck8d(7VFnNY(jsvdP9VA4(yrWubj0KxXsA6ofhiS2hkyJWekJ95nISVfsnIrYyF3PPLcpU3b6uL9de83hiAfNajzSpwemvqcfXiwiS2N69XIGPcsOiHrSqyTpWbcEGf37aDQY(1g83hiAfNajzSpwemvqcfdmwiS2N69XIGPcsOifySqyTpWbcEGf37aDQY(hg83hiAfNajzSpwemvqcfXiwiS2N69XIGPcsOiHrSqyTpWbcEGf37aDQY(hg83hiAfNajzSpwemvqcfdmwiS2N69XIGPcsOifySqyTpWbcEGf377DSFGsHRGctbf(b)93VMtz)ePQH0(xnCFSCnornLWAFOGnctOm2N3iY(wi1igjJ9DNMwk84EhOtv2hdWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7Jb4Vpq0kobsYyFSCToctkwiS2N69XY16imPyHIIAayYaR9bgdWdS4EhOtv2pqWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7xBWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7FyWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7FyWFFGOvCcKKX(y5ADeMuSqyTp17JLR1rysXcff1aWKbw7dmgGhyX9oqNQSp2b(7deTItGKm2hlYyIsXcH1(uVpwKXeLIfkkQbGjdS2hymapWI799o2pqPWvqHPGc)G)(7xZPSFIu1qA)RgUpwd5Yczew7dfSrycLX(8gr23cPgXizSV700sHh37aDQY(avWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(gTp2m2eqVpWyaEGf37aDQY(azG)(arR4eijJ9XIGPcsOigXcH1(uVpwemvqcfjmIfcR9bgdWdS4EhOtv2hid83hiAfNajzSpwemvqcfdmwiS2N69XIGPcsOifySqyTpWyaEGf37aDQY(ajWFFGOvCcKKX(yrWubjueJyHWAFQ3hlcMkiHIegXcH1(aJb4bwCVd0Pk7dKa)9bIwXjqsg7JfbtfKqXaJfcR9PEFSiyQGeksbglew7dmgGhyX9oqNQSp2h4Vpq0kobsYyFSiyQGekIrSqyTp17JfbtfKqrcJyHWAFGXa8alU3b6uL9X(a)9bIwXjqsg7JfbtfKqXaJfcR9PEFSiyQGeksbglew7dmgGhyX9oqNQSpg1c83hiAfNajzSpwemvqcfXiwiS2N69XIGPcsOiHrSqyTpWyaEGf37aDQY(yulWFFGOvCcKKX(yrWubjumWyHWAFQ3hlcMkiHIuGXcH1(aJb4bwCVd0Pk7JrGG)(arR4eijJ9XImMOuSqyTp17JfzmrPyHIIAayYaR9boqWdS4EhOtv2hJAd(7deTItGKm2hlYyIsXcH1(uVpwKXeLIfkkQbGjdS2hymapWI7DGovzFmWoWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7Jbqf83hiAfNajzSpwemvqcfnaUORB2OVPyTp17JLRB2OVPrdGdR9bgdWdS4EhOtv2hdGmWFFGOvCcKKX(yrWubju0a4IUUzJ(MI1(uVpwUUzJ(MgnaoS2hymapWI7DGovzFmasG)(arR4eijJ9XIGPcsOObWfDDZg9nfR9PEFSCDZg9nnAaCyTpWyaEGf37aDQY(bwBWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7h4Hb)9bIwXjqsg7JfzmrPyHWAFQ3hlYyIsXcff1aWKbw7dmgGhyX9oqNQSFGajWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(ahi4bwCVd0Pk7x7Ab(7deTItGKm2hlYyIsXcH1(uVpwKXeLIfkkQbGjdS2h4abpWI7DGovz)AJb4Vpq0kobsYyFSiJjkflew7t9(yrgtukwOOOgaMmWAFGXa8alU3b6uL9RDGG)(arR4eijJ9XImMOuSqyTp17JfzmrPyHIIAayYaR9bgdWdS4EhOtv2V2avWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(aJb4bwCVd0Pk7xBGmWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(gTp2m2eqVpWyaEGf37aDQY(hU2G)(arR4eijJ9XImMOuSqyTp17JfzmrPyHIIAayYaR9boqWdS4EFVJ9dukCfuykOWp4V)(1Ck7NivnK2)QH7JL1cw7dfSrycLX(8gr23cPgXizSV700sHh37aDQY(1g83hiAfNajzSpwKXeLIfcR9PEFSiJjkfluuudatgyTpWbcEGf37aDQY(hg83hiAfNajzSpwKXeLIfcR9PEFSiJjkfluuudatgyTpWyaEGf37aDQY(yh4Vpq0kobsYyFSiJjkflew7t9(yrgtukwOOOgaMmWAFGXa8alU3b6uL9XiqWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(axBWdS4EhOtv2hJAd(7deTItGKm2hlYyIsXcH1(uVpwKXeLIfkkQbGjdS2hymapWI7DGovzFmasG)(arR4eijJ9XImMOuSqyTp17JfzmrPyHIIAayYaR9nAFSzSjGEFGXa8alU3b6uL9dSwG)(arR4eijJ9XImMOuSqyTp17JfzmrPyHIIAayYaR9nAFSzSjGEFGXa8alU3b6uL9dedWFFGOvCcKKX(yrgtukwiS2N69XImMOuSqrrnamzG1(gTp2m2eqVpWyaEGf3779cdsvdjzSpgbUV5OS19zjN4X9UhLLCI7RXJomiOsMbLzfuQ814ladFnEuZrzREuCjtMKLk5rf1aWKH)ip5liqFnEuZrzRE0Hbbn5DiZJkQbGjd)rEYxqT914rnhLT6rRAkB1JkQbGjd)rEYxWH914rnhLT6rVsOaG19WJkQbGjd)rEYxa25RXJAokB1JcG19yEfcd6rf1aWKH)ip5laO6RXJAokB1JcqGCbck1spQOgaMm8h5jFbaz(A8OIAayYWFKh1btsGP5rX8(UgNOMsrvCWM1WHh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OUgNOMsEYxaqYxJh1Cu2QhLhIG06CyqqLmdkEurnamz4pYtEYJsWubj0KxXsA6ofhiFn(cWWxJhvudatg(J8ODLhLlKh1Cu2QhfNbtdat8O4mwO4rbEFG3h49fSrywvjJOGufekgB2WHAQt8O4m4uneXJYRexASPGncZQkz4jFbb6RXJkQbGjd)rE0UYJYfYJAokB1JIZGPbGjEuCglu8OaVpbtfKqrcJ4PXNvW2fnn4(13NGPcsOiHr804tx3SrFt3hmpkodovdr8OemvqcnBv8KVGA7RXJkQbGjd)rE0UYJYfYJAokB1JIZGPbGjEuCglu8OaVpbtfKqrkW4PXNvW2fnn4(13NGPcsOify804tx3SrFt3hmpkodovdr8OemvqcnPBTN8fCyFnEurnamz4pYJ2vEuUqEuZrzREuCgmnamXJIZyHIhf49X8(aVpbtfKqrcJ4PXNvW2fnn4(13NGPcsOiHr804tx3SrFt3hS9bBF843h49X8(aVpbtfKqrkW4PXNvW2fnn4(13NGPcsOify804tx3SrFt3hS9bBF843xWgHzvLmILSGvNZ(AACEIKmJYw9O4m4uneXJomeRuMemvqc5jFbyNVgpQOgaMm8h5r7kpkxipQ5OSvpkodMgaM4rXzSqXJc8(4myAaysKGPcsOzRY(13hNbtdatIddXkLjbtfKq7d2(4XVpW7JZGPbGjrcMkiHM0TE)67JZGPbGjXHHyLYKGPcsO9bBF843h49XzW0aWKibtfKqZwfpkodovdr8Oemvqcn5vSK8KN8OddXkLjbtfKqCFn(cWWxJhvudatg(J8OQHiEuEhYMzPMKa9OMJYw9O8oKnZsnjb6jFbb6RXJkQbGjd)rEu1qep6ak24kHYeNW5cZJAokB1JoGInUsOmXjCUW8KVGA7RXJkQbGjd)rEu1qepAjly15SVMgNNijZOSvpQ5OSvpAjly15SVMgNNijZOSvp5jp6qywqzmjyQGeI7RXxag(A8OIAayYWFKh1Cu2QhvqQccfJnB4qn1jEuhmjbMMhf49DnornLIAwEsZlt2V((UUzJ(Mg5DiBcBkcfelv((GB)aR1(GTpE87d8(UgNOMsrCIsNbH7xFFx3SrFtJjsLOJulNoJmob7Qtjcfelv((GB)aR1(GTpE87d8(UgNOMsrvCWM1WX(4XVVRXjQPueuqyA6(4XVVRXjQPuuBv2hmpQAiIhvqQccfJnB4qn1jEYxqG(A8OIAayYWFKh1Cu2QhLhQayDpMgIqNb5Kh1btsGP5rbEFxJtutPOMLN08YK9RVVRB2OVPrEhYMWMIqbXsLVp42hOUpy7Jh)(aVVRXjQPueNO0zq4(1331nB030yIuj6i1YPZiJtWU6uIqbXsLVp42hOUpy7Jh)(aVVRXjQPuufhSznCSpE877ACIAkfbfeMMUpE877ACIAkf1wL9bZJQgI4r5Hkaw3JPHi0zqo5jFb12xJhvudatg(J8OMJYw9O8oKXeIsTCcdbe0J6GjjW08OaVVRXjQPuuZYtAEzY(1331nB030iVdztytrOGyPY3hC7dK2hS9XJFFG3314e1ukItu6miC)6776Mn6BAmrQeDKA50zKXjyxDkrOGyPY3hC7dK2hS9XJFFG3314e1ukQId2Sgo2hp(9DnornLIGcctt3hp(9DnornLIARY(G5rvdr8O8oKXeIsTCcdbe0tEYJ6ACIAk5RXxag(A8OIAayYWFKh1btsGP5rX8(KXeLIvNMsnYKNAziZGjfmkQbGjJ9RVpW776Mn6BAKhIG06CyqqLmdkrOGyPY3hC7JrT2hp(9DDZg9nnYdrqADomiOsMbLiuqSu57JP9XUATF99DDZg9nnYdrqADomiOsMbLiuqSu57JP9de72V((UwhHjfDnegwrPwozIaJIAayYyFW8OMJYw9OjsLOJulNoJmob7QtXt(cc0xJhvudatg(J8OoyscmnpkzmrPy1PPuJm5PwgYmysbJIAayYy)67pAkwDAk1itEQLHmdMuWiLoqPw6rnhLT6rtKkrhPwoDgzCc2vNIN8fuBFnEurnamz4pYJ6GjjW08OUUzJ(Mg5HiiTohgeujZGsekiwQ89X0(y3(13h49hcGWRR4PfQuekiwQ89X0(hEF843hZ7tgtukEAHkff1aWKX(G5rnhLT6rhIlrmk1YjGMrEYxWH914rf1aWKH)ipQdMKatZJI59jJjkfRonLAKjp1YqMbtkyuudatg7xFFG331nB030ipebP15WGGkzguIqbXsLVp42h72hp(9DDZg9nnYdrqADomiOsMbLiuqSu57JP9XUATpE8776Mn6BAKhIG06CyqqLmdkrOGyPY3ht7hi2TF99DToctk6AimSIsTCYebgf1aWKX(G5rnhLT6r5DiBcBYt(cWoFnEurnamz4pYJ6GjjW08OKXeLIvNMsnYKNAziZGjfmkQbGjJ9RV)OPy1PPuJm5PwgYmysbJu6aLAPh1Cu2QhL3HSjSjp5laO6RXJAokB1JYDDim1YjL0P4rf1aWKH)ip5jp6OPzfuQ814ladFnEurnamz4pYJ6GjjW08OJMIwzRbJqbXsLVp42hiTF99DDZg9nnYdrqADomiOsMbLiuqSu57JP9hnfTYwdgHcILk3JAokB1JALTg0t(cc0xJhvudatg(J8Ooyscmnp6OPipRoBDYYljcfelv((GBFG0(1331nB030ipebP15WGGkzguIqbXsLVpM2F0uKNvNToz5LeHcILk3JAokB1JYZQZwNS8s8KVGA7RXJkQbGjd)rEuhmjbMMhD0umu5KbGjt76ILokBncfelv((GBFG0(1331nB030ipebP15WGGkzguIqbXsLVpM2F0umu5KbGjt76ILokBncfelvUh1Cu2Qhnu5KbGjt76ILokB1t(coSVgpQOgaMm8h5rDWKeyAE0rtrxdHHvu2AekiwQ89b3(aP9RVVRB2OVPrEicsRZHbbvYmOeHcILkFFmT)OPORHWWkkBncfelvUh1Cu2Qh11qyyfLT6jp5rhYLfYiFn(cWWxJh1Cu2QhLxjm2K1oqEurnamz4pYt(cc0xJh1Cu2QhDi46q4eXktNhvudatg(J8KVGA7RXJkQbGjd)rEuhmjbMMh1CuItMIkiPW3ht7xBpkNGPJ8fGHh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OwlEYxWH914rf1aWKH)ip6q4oywrzREuGIJYw3NLCIV)vd3NGPcsO9biNgUSHX9rjJ47BqzFUHtg7F1W9bixnu2hTdz7x4A6GcdsLOJul3himY4eSRoLdWENMsnY(OPwgYmysbdy)Mof4TKl736(UUzJ(M6rnhLT6rDgJnnhLTozjN8OCcMoYxagEuhmjbMMhLsezFWTpgEuwYPPAiIhLGPcsOjVIL00DkoqEYxa25RXJkQbGjd)rEuZrzREuNXytZrzRtwYjpkl50uneXJoeMfugtcMkiH4EYxaq1xJhvudatg(J8OoyscmnpkW7pAkY7q2e2uKshOul3hp(9hnftKkrhPwoDgzCc2vNYC0uKshOul3hp(9hnfRonLAKjp1YqMbtkyKshOul3hS9RVpVdzt(Pbh7JP9R9(4XV)OPiUKjtYsLIu6aLA5(4XVpzmrPiVVnPtzYfzWJIAayYWJYjy6iFby4rnhLT6rDgJnnhLTozjN8OSKtt1qepkNmAsWubje3t(caY814rf1aWKH)ipQdMKatZJ6ACIAkf1S8KMxMSF99bEFmVpodMgaMejyQGeAYRyjTpE8776Mn6BAK3HSjSPiuqSu57JP9dSw7Jh)(aVpodMgaMejyQGeA2QSF99DDZg9nnY7q2e2uekiwQ89b3(emvqcfjmIUUzJ(MgHcILkFFW2hp(9bEFCgmnamjsWubj0KU17xFFx3SrFtJ8oKnHnfHcILkFFWTpbtfKqrkWORB2OVPrOGyPY3hS9bZJYjy6iFby4rnhLT6rDgJnnhLTozjN8OSKtt1qep6WqSszsWubje3t(cas(A8OIAayYWFKh1btsGP5rDnornLI4eLodc3V((aVpM3hNbtdatIemvqcn5vSK2hp(9DDZg9nnMivIosTC6mY4eSRoLiuqSu57JP9dSw7Jh)(aVpodMgaMejyQGeA2QSF99DDZg9nnMivIosTC6mY4eSRoLiuqSu57dU9jyQGeksyeDDZg9nncfelv((GTpE87d8(4myAaysKGPcsOjDR3V((UUzJ(MgtKkrhPwoDgzCc2vNsekiwQ89b3(emvqcfPaJUUzJ(MgHcILkFFW2hmpkNGPJ8fGHh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OddXkLjbtfKqCp5la7ZxJhvudatg(J8OoyscmnpkW77ACIAkfvXbBwdh7Jh)(UgNOMsrqbHPP7Jh)(UgNOMsrTvzFW2V((aVpM3hNbtdatIemvqcn5vSK2hp(9DDZg9nnwDAk1itEQLHmdMuWiuqSu57JP9dSw7Jh)(aVpodMgaMejyQGeA2QSF99DDZg9nnwDAk1itEQLHmdMuWiuqSu57dU9jyQGeksyeDDZg9nncfelv((GTpE87d8(4myAaysKGPcsOjDR3V((UUzJ(MgRonLAKjp1YqMbtkyekiwQ89b3(emvqcfPaJUUzJ(MgHcILkFFW2hmpkNGPJ8fGHh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OddXkLjbtfKqCp5laJA5RXJkQbGjd)rEuhmjbMMhfZ7tgtukwDAk1itEQLHmdMuWOOgaMm2V((aVpM3hNbtdatIemvqcn5vSK2hp(9DDZg9nnYdrqADomiOsMbLiuqSu57JP9dSw7Jh)(aVpodMgaMejyQGeA2QSF99DDZg9nnYdrqADomiOsMbLiuqSu57dU9jyQGeksyeDDZg9nncfelv((GTpE87d8(4myAaysKGPcsOjDR3V((UUzJ(Mg5HiiTohgeujZGsekiwQ89b3(emvqcfPaJUUzJ(MgHcILkFFW2hmpkNGPJ8fGHh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OddXkLjbtfKqCp5ladm814rf1aWKH)ipQ5OSvpkIXKR0nHwffcfp6q4oywrzRE0JcH6(8oKTp)0Gd((51(xz5jTFY33yinN2VXjqpQdMKatZJcO589RV)vwEstOGyPY3hC7lGN4cjzsjISpq(7Z7q2KFAWX(13F0umu5KbGjt76ILokBnsPduQLEYxagb6RXJkQbGjd)rE0HWDWSIYw9OfMR9DnornL2F00byVttPgzF0uldzgmPG7N89HHQMAza7hYL9pudcQKzqzFQ3xaps0X(0PSVlecfL2NlKh1Cu2Qh1zm20Cu26KLCYJ6GjjW08OaVVRXjQPueNO0zq4(13F0umrQeDKA50zKXjyxDkZrtrkDGsTC)6776Mn6BAKhIG06CyqqLmdkrOGyPY3hC7h4(13h49hnfRonLAKjp1YqMbtkyekiwQ89X0(bUpE87J59jJjkfRonLAKjp1YqMbtkyuudatg7d2(GTpE87d8(UgNOMsrnlpP5Lj7xF)rtrEhYMWMIu6aLA5(1331nB030ipebP15WGGkzguIqbXsLVp42pW9RVpW7pAkwDAk1itEQLHmdMuWiuqSu57JP9dCF843hZ7tgtukwDAk1itEQLHmdMuWOOgaMm2hS9bBF843h49bEFxJtutPOkoyZA4yF843314e1ukckimnDF843314e1ukQTk7d2(13F0uS60uQrM8uldzgmPGrkDGsTC)67pAkwDAk1itEQLHmdMuWiuqSu57dU9dCFW8OSKtt1qep6WGGkzguMvqPYt(cWO2(A8OIAayYWFKhDiChmROSvpAHtUGc)C)rt89fdYcUFETFzNA5(Ps9(2(8tdo2Nxj6i1Y9RonU4rnhLT6rDgJnnhLTozjN8OoyscmnpkW77ACIAkf1S8KMxMSF99X8(JMI8oKnHnfP0bk1Y9RVVRB2OVPrEhYMWMIqbXsLVp42)W7d2(4XVpW77ACIAkfXjkDgeUF99X8(JMIjsLOJulNoJmob7QtzoAksPduQL7xFFx3SrFtJjsLOJulNoJmob7Qtjcfelv((GB)dVpy7Jh)(aVpW77ACIAkfvXbBwdh7Jh)(UgNOMsrqbHPP7Jh)(UgNOMsrTvzFW2V((KXeLIvNMsnYKNAziZGjfmkQbGjJ9RVpM3F0uS60uQrM8uldzgmPGrkDGsTC)6776Mn6BAS60uQrM8uldzgmPGrOGyPY3hC7F49bZJYsonvdr8OJMMvqPYt(cW4W(A8OIAayYWFKh1Cu2QhDyqqtEhY8OdH7GzfLT6rlmx7J9onLAK9rtTmKzWKcUFY3NshOuldy)K2p57ZTlzFQ3pKl7FOge0(ODiZJ6GjjW08OJMIvNMsnYKNAziZGjfmsPduQLEYxagyNVgpQOgaMm8h5rDWKeyAEumVpzmrPy1PPuJm5PwgYmysbJIAayYy)67d8(JMI8oKnHnfP0bk1Y9XJF)rtXePs0rQLtNrgNGD1PmhnfP0bk1Y9bZJAokB1JomiOjVdzEYxagavFnEurnamz4pYJAokB1JwDAk1itEQLHmdMuqp6q4oywrzREu0GQBFS3PPuJSpAQLHmdMuW9VL05(fEfLodcpOGS8K2VWNj77ACIAkT)OPa2VPtbEl5Y(HCz)w331nB0304(fMR9XMrQccfJTp2eCOM6K9beEDTFY3pvxJKAza7F2SX(HkLS9tcl((qXgb3hymas7ZfxRd((2fjW9d5cyEuhmjbMMh114e1ukQz5jnVmz)67tjISpM2h72V((UUzJ(Mg5DiBcBkcfelv((GBFm2V((aVVRB2OVPrbPkium2SHd1uNeHcILkFFWTpga1a3hp(9X8(c2imRQKruqQccfJnB4qn1j7dMN8fGbqMVgpQOgaMm8h5rDWKeyAEuxJtutPiorPZGW9RVpLiY(yAFSB)6776Mn6BAmrQeDKA50zKXjyxDkrOGyPY3hC7JX(13h49DDZg9nnkivbHIXMnCOM6KiuqSu57dU9XaOg4(4XVpM3xWgHzvLmIcsvqOySzdhQPozFW8OMJYw9OvNMsnYKNAziZGjf0t(cWai5RXJkQbGjd)rEuhmjbMMhf49DnornLIQ4GnRHJ9XJFFxJtutPiOGW009XJFFxJtutPO2QSpy7xFFG331nB030OGufekgB2WHAQtIqbXsLVp42hdGAG7Jh)(yEFbBeMvvYikivbHIXMnCOM6K9bZJAokB1JwDAk1itEQLHmdMuqp5ladSpFnEurnamz4pYJ6GjjW08OaAoF)67FLLN0ekiwQ89b3(yau9OMJYw9OvNMsnYKNAziZGjf0t(ccSw(A8OIAayYWFKhDiChmROSvpAH5AFS3PPuJSpAQLHmdMuW9t((u6aLAza7New89Per2N69d5Y(nDkW9rmGCnC)rtCpQ5OSvpQZySP5OS1jl5Kh1btsGP5rhnfRonLAKjp1YqMbtkyKshOul3V((aVVRXjQPuuZYtAEzY(4XVVRXjQPueNO0zq4(G5rzjNMQHiEuxJtutjp5liqm814rf1aWKH)ipQ5OSvpQv2AqpQdMKatZJoAkALTgmcfelv((GB)d7rDbDmzsgSuiUVam8KVGad0xJh1Cu2Qh90cvYJkQbGjd)rEYxqG12xJhvudatg(J8OMJYw9OCrgZ(A6AimSIYw9OdH7GzfLT6rr7B7tNY(OIm4736(1EFYGLcX3pV2pP9tUIfTVlecfLyb3p19Vyz5jTFd3V19PtzFYGLcf3h7pPZ9rZQZw3hOZlz)KWIVVX49(aeIe4(uVFix2hvKX(nobUpIPHgJfCFRQIfm1Y9R9(ardHHvu2kp6rDWKeyAEuZrjozkQGKcFFmTFG7xFFYyIsrEFBsNYKlYGhf1aWKX(13hZ7pAkYfzm7RPRHWWkkBnsPduQL7xFFmVFQZlwwEsEYxqGh2xJhvudatg(J8OoyscmnpQ5OeNmfvqsHVpM2pW9RVpzmrPipRoBDYYljkQbGjJ9RVpM3F0uKlYy2xtxdHHvu2AKshOul3V((yE)uNxSS8K2V((JMIUgcdROS1iuqSu57dU9pSh1Cu2QhLlYy2xtxdHHvu2QN8fei25RXJkQbGjd)rEuhmjbMMhf495DiBYpn4yFmTpg7Jh)(MJsCYuubjf((yA)a3hS9RVVRB2OVPrEicsRZHbbvYmOeHcILkFFmTpgb6rnhLT6rXLmzswQKN8feiq1xJhvudatg(J8OoyscmnpQ5OeNmhnfdvozayY0UUyPJYw3V4(1AF843NshOul3V((JMIHkNmamzAxxS0rzRrOGyPY3hC7FypQ5OSvpAOYjdatM21flDu2QN8feiqMVgpQOgaMm8h5rDWKeyAEumVVRXjQPuufhSznC4r5emDKVam8OMJYw9OoJXMMJYwNSKtEuwYPPAiIh114e1uYt(ccei5RXJkQbGjd)rEuZrzREuxdHHvu2Qh1f0XKjzWsH4(cWWJ6GjjW08OMJsCYuubjf((GB)dV)HSpW7tgtukY7Bt6uMCrg8OOgaMm2hp(9jJjkf5z1zRtwEjrrnamzSpy7xF)rtrxdHHvu2AekiwQ89b3(b6rhc3bZkkB1JcuQQyb3hiAimSIYw3hX0qJXcUFR7JXHe4(KblfIhW(nC)w3V27FlPZ9bka4nlKK9bIgcdROSvp5liqSpFnEurnamz4pYJAokB1JIym5kDtOvrHqXJoeUdMvu2QhfOCrcCF6u2VRevGbSpVs0X(2(8tdo2)2PO7B0(y3(TUFHTXKR0TFHZQOqOSp17B46CSFJtGoRQk1spQdMKatZJY7q2KFAWX(yA)dVF99Per2ht7higEYxqTRLVgpQOgaMm8h5rhc3bZkkB1JI9Fk6(At7ZdQUul3h7DAk1i7JMAziZGjfCFQ3VWRO0zq4bfKLN0(f(mjG9rdrqAD)d1GGkzgu2pV23yS9hnX33GY(wvflLHh1Cu2Qh1zm20Cu26KLCYJ6GjjW08OaVVRXjQPueNO0zq4(13hZ7tgtukwDAk1itEQLHmdMuWOOgaMm2V((JMIjsLOJulNoJmob7QtzoAksPduQL7xFFx3SrFtJ8qeKwNddcQKzqjcfBeCFW2hp(9bEFxJtutPOMLN08YK9RVpM3NmMOuS60uQrM8uldzgmPGrrnamzSF99hnf5DiBcBksPduQL7xFFx3SrFtJ8qeKwNddcQKzqjcfBeCFW2hp(9bEFG3314e1ukQId2Sgo2hp(9DnornLIGcctt3hp(9DnornLIARY(GTF99DDZg9nnYdrqADomiOsMbLiuSrW9bZJYsonvdr8OddcQKzqzwbLkp5lO2y4RXJkQbGjd)rEuZrzRE0Hbbn5DiZJoeUdMvu2QhTWdx2)qniO9r7q2(51(hQbbvYmOS)TwXI2hGSpuSrW9Tsl1a2VH7Nx7tNcu2)wYy7dq23O9zIXP9dCFKgk7FOgeujZGY(HCH7rDWKeyAEuanNVF99DDZg9nnYdrqADomiOsMbLiuqSu57JP9VYYtAcfelv((13h49X8(KXeLIvNMsnYKNAziZGjfmkQbGjJ9XJFFx3SrFtJvNMsnYKNAziZGjfmcfelv((yA)RS8KMqbXsLVpyEYxqTd0xJhvudatg(J8OoyscmnpkGMZ3V((yEFYyIsXQttPgzYtTmKzWKcgf1aWKX(1331nB030ipebP15WGGkzguIqbXsLV)X776Mn6BAKhIG06CyqqLmdkXri0OS19b3(xz5jnHcILk3JAokB1JomiOjVdzEYxqTRTVgpQOgaMm8h5rhc3bZkkB1Jceg5opeJX2pjbz)qUvk7F1W9nniDMA5(At7ZRexELYyFHXLBNcu8OMJYw9OoJXMMJYwNSKtEuwYPPAiIhnjbXt(cQ9H914rf1aWKH)ipQdMKatZJYeCcBFmTp2bKTF99bE)Hai86kYpTrFBkiaGMtICYCG2hC7d8(bU)HSV5OS1i)0g9TjGMrXuNxSS8K2hS9XJF)Hai86kYpTrFBkiaGMtIqbXsLVp42V27dMh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OCXt(cQn25RXJkQbGjd)rEuZrzREueJjxPBcTkkekE0HWDWSIYw9OfE4Y(f2gtUs3(foRIcHY(3ofDFedixd3F0eFFdk7hwfW(nC)8AF6uGY(3sgBFaY(8SuZR0zkTpLiY(HkLS9PtzFvapAFS3PPuJSpAQLHmdMuqpQdMKatZJoAkIlzYKSuPiLoqPwUpE87pAkMivIosTC6mY4eSRoL5OPiLoqPwUpE87pAkY7q2e2uKshOul9KVGAdu914rf1aWKH)ipQdMKatZJsgtukwDAk1itEQLHmdMuWOOgaMm2V((aV)OPy1PPuJm5PwgYmysbJu6aLA5(4XVVRB2OVPXQttPgzYtTmKzWKcgjyOmHcILkFFmTFGy3(4XVpGMZ3V((xz5jnHcILkFFWTVRB2OVPXQttPgzYtTmKzWKcgHcILkFFW8OMJYw9OigtUs3eAvuiu8KVGAdK5RXJkQbGjd)rEuhmjbMMhLmMOuK33M0Pm5Im4rrnamz4rnhLT6rrmMCLUj0QOqO4jFb1gi5RXJkQbGjd)rEuZrzRE0b0sDYYlXJoeUdMvu2Qh9qHwQ7d05LSFY3VvwW9T9puSh6(LwQ7FlPZ9lmQGljdat2)qfKKl7RIb3hXaV95K5aXJ7xyU2)klpP9t((gGoK2N69fDS)O3xBAFKKZ3Nxj6i1Y9PtzFozoqCpQdMKatZJci86kMQGljdatMdbj5sKtMd0(yA)dxR9XJFFaHxxXufCjzayYCiijxIHv7xFFanNVF99VYYtAcfelv((GB)d7jFb1g7ZxJhvudatg(J8OMJYw9OoJXMMJYwNSKtEuwYPPAiIh114e1uYt(coCT814rf1aWKH)ipQ5OSvpQv2AqpQdMKatZJcLlOWpnamXJ6c6yYKmyPqCFby4jFbhgdFnEurnamz4pYJ6GjjW08OMJsCYC0umu5KbGjt76ILokBD)I7xR9XJFFkDGsTC)67dLlOWpnamXJAokB1JgQCYaWKPDDXshLT6jFbhoqFnEurnamz4pYJAokB1JYZQZwNS8s8OoyscmnpkuUGc)0aWepQlOJjtYGLcX9fGHN8fC4A7RXJkQbGjd)rEuZrzREuxdHHvu2Qh1btsGP5rHYfu4NgaMSF99nhL4KPOcsk89b3(hE)dzFG3NmMOuK33M0Pm5Im4rrnamzSpE87tgtukYZQZwNS8sIIAayYyFW8OUGoMmjdwke3xagEYxWHpSVgpAQKaHHvKhfdpQ5OSvp6aAPo5DiZJkQbGjd)rEYxWHXoFnEuZrzREu(Pn6BtanJ8OIAayYWFKN8KhTckUgbGr(A8fGHVgpQOgaMm8h5rDWKeyAEukrK9X0(1A)67J59RekASeNSF99X8(acVUILWePtOm7Rj3CW8kDsmSYJAokB1JEjS5Ors1OSvp5liqFnEuZrzREuEicsRZlHDgQKa9OIAayYWFKN8fuBFnEurnamz4pYJ6GjjW08OKXeLILWePtOm7Rj3CW8kDsuudatgEuZrzRE0syI0juM91KBoyELoXt(coSVgpQOgaMm8h5r7kpkxipQ5OSvpkodMgaM4rXzSqXJAokXjZrtrxdHHvu26(yA)ATF99nhL4K5OPOv2AW9X0(1A)67BokXjZrtXqLtgaMmTRlw6OS19X0(1A)67d8(yEFYyIsrEwD26KLxsuudatg7Jh)(MJsCYC0uKNvNToz5LSpM2Vw7d2(13h49hnfRonLAKjp1YqMbtkyKshOul3hp(9X8(KXeLIvNMsnYKNAziZGjfmkQbGjJ9bZJIZGt1qep6Oj(ek2iON8fGD(A8OIAayYWFKhvneXJAa5XpnOXNxTsZ(Aw13eOh1Cu2Qh1aYJFAqJpVALM91SQVjqp5laO6RXJkQbGjd)rEuZrzREuUiJzFnDnegwrzREuhmjbMMhLxjm2KmyPq8ixKXSVMUgcdROS1P1Y(yQ4(12JYsvMUHhfJA5jFbaz(A8OMJYw9ONwOsEurnamz4pYt(cas(A8OMJYw9OHkNmamzAxxS0rzREurnamz4pYtEYJAT4RXxag(A8OMJYw9OvNMsnYKNAziZGjf0JkQbGjd)rEYxqG(A8OMJYw9ONwOsEurnamz4pYt(cQTVgpQOgaMm8h5rDWKeyAEuG3314e1ukItu6miC)67pAkMivIosTC6mY4eSRoL5OPiLoqPwUF99DDZg9nnYdrqADomiOsMbLiuSrW9RVpW7pAkwDAk1itEQLHmdMuWiuqSu57JP9dCF843hZ7tgtukwDAk1itEQLHmdMuWOOgaMm2hS9bBF843h49DnornLIAwEsZlt2V((JMI8oKnHnfP0bk1Y9RVVRB2OVPrEicsRZHbbvYmOeHIncUF99bE)rtXQttPgzYtTmKzWKcgHcILkFFmTFG7Jh)(yEFYyIsXQttPgzYtTmKzWKcgf1aWKX(GTpy7xFFG3h49DnornLIQ4GnRHJ9XJFFxJtutPiOGW009XJFFxJtutPO2QSpy7xF)rtXQttPgzYtTmKzWKcgP0bk1Y9RV)OPy1PPuJm5PwgYmysbJqbXsLVp42pW9bZJAokB1J6mgBAokBDYso5rzjNMQHiE0HbbvYmOmRGsLN8fCyFnEurnamz4pYJ6GjjW08OKXeLI8(2KoLjxKbpkQbGjJ9RVVZ0jxKHh1Cu2QhLlYy2xtxdHHvu2QN8fGD(A8OIAayYWFKh1btsGP5rX8(KXeLI8(2KoLjxKbpkQbGjJ9RVpM3F0uKlYy2xtxdHHvu2AKshOul3V((yE)uNxSS8K2V((JMIUgcdROS1iuUGc)0aWepQ5OSvpkxKXSVMUgcdROSvp5laO6RXJkQbGjd)rEuZrzREuRS1GEuhmjbMMh1CuItMJMIwzRb3hC7F49RVpuUGc)0aWepQlOJjtYGLcX9fGHN8faK5RXJkQbGjd)rEuZrzREuRS1GEuhmjbMMh1CuItMJMIwzRb3htf3)W7xFFOCbf(PbGj7xF)rtrRS1GrkDGsT0J6c6yYKmyPqCFby4jFbajFnEurnamz4pYJ6GjjW08OMJsCYC0umu5KbGjt76ILokBD)I7xR9XJFFkDGsTC)67dLlOWpnamXJAokB1JgQCYaWKPDDXshLT6jFbyF(A8OIAayYWFKh1Cu2Qhnu5KbGjt76ILokB1J6GjjW08OyEFkDGsTC)67xHRImMOueAivMst76ILokBLhf1aWKX(133CuItMJMIHkNmamzAxxS0rzR7dU9RTh1f0XKjzWsH4(cWWt(cWOw(A8OIAayYWFKh1btsGP5r5DiBYpn4yFmTpgEuZrzREuCjtMKLk5jFbyGHVgpQOgaMm8h5rDWKeyAEumVVRXjQPuufhSznC4r5emDKVam8OMJYw9OoJXMMJYwNSKtEuwYPPAiIh114e1uYt(cWiqFnEurnamz4pYJ6GjjW08OaVVRXjQPueNO0zq4(13h49DDZg9nnMivIosTC6mY4eSRoLiuSrW9XJF)rtXePs0rQLtNrgNGD1PmhnfP0bk1Y9bB)6776Mn6BAKhIG06CyqqLmdkrOyJG7xFFG3F0uS60uQrM8uldzgmPGrOGyPY3ht7h4(4XVpM3NmMOuS60uQrM8uldzgmPGrrnamzSpy7d2(13h49bEFxJtutPOkoyZA4yF843314e1ukckimnDF843314e1ukQTk7d2(1331nB030ipebP15WGGkzguIqbXsLVp42pW9RVpW7pAkwDAk1itEQLHmdMuWiuqSu57JP9dCF843hZ7tgtukwDAk1itEQLHmdMuWOOgaMm2hS9bBFG3314e1ukQz5jnVmz)67d8(UUzJ(Mg5DiBcBkcfBeCF843F0uK3HSjSPiLoqPwUpy7xFFx3SrFtJ8qeKwNddcQKzqjcfelv((GB)a3V((aV)OPy1PPuJm5PwgYmysbJqbXsLVpM2pW9XJFFmVpzmrPy1PPuJm5PwgYmysbJIAayYyFW2hmpQ5OSvpQZySP5OS1jl5KhLLCAQgI4rhgeujZGYSckvEYxag12xJhvudatg(J8OoyscmnpkGMZ3V((UUzJ(Mg5HiiTohgeujZGsekiwQ89X0(xz5jnHcILkF)67d8(yEFYyIsXQttPgzYtTmKzWKcgf1aWKX(4XVVRB2OVPXQttPgzYtTmKzWKcgHcILkFFmT)vwEstOGyPY3hmpQ5OSvp6WGGM8oK5jFbyCyFnEurnamz4pYJ6GjjW08OaAoF)6776Mn6BAKhIG06CyqqLmdkrOGyPY3)49DDZg9nnYdrqADomiOsMbL4ieAu26(GB)RS8KMqbXsL7rnhLT6rhge0K3Hmp5ladSZxJhvudatg(J8OMJYw9OoJXMMJYwNSKtEuwYPPAiIhnjbXt(cWaO6RXJkQbGjd)rEuZrzREuNXytZrzRtwYjpkl50uneXJoeMfugtcMkiH4EYxagaz(A8OIAayYWFKh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OddXkLjbtfKqCp5ladGKVgpQOgaMm8h5rDWKeyAE0rtXQttPgzYtTmKzWKcgP0bk1Y9XJFFmVpzmrPy1PPuJm5PwgYmysbJIAayYWJAokB1J6mgBAokBDYso5rzjNMQHiEuoz0KGPcsiUN8fGb2NVgpQOgaMm8h5rDWKeyAE0rtrCjtMKLkfP0bk1spQ5OSvpkIXKR0nHwffcfp5liWA5RXJkQbGjd)rEuhmjbMMhD0uK3HSjSPiLoqPwUF99X8(KXeLI8(2KoLjxKbpkQbGjdpQ5OSvpkIXKR0nHwffcfp5liqm814rf1aWKH)ipQdMKatZJI59jJjkfXLmzswQuuudatgEuZrzREueJjxPBcTkkekEYxqGb6RXJkQbGjd)rEuhmjbMMhL3HSj)0GJ9X0(h2JAokB1JIym5kDtOvrHqXt(ccS2(A8OIAayYWFKh1Cu2QhLNvNToz5L4rDWKeyAEuZrjozoAkYZQZwNS8s2hCf3V27xFFOCbf(PbGj7xFFmV)OPipRoBDYYljsPduQLEuxqhtMKblfI7ladp5liWd7RXJkQbGjd)rEuhmjbMMh114e1ukQId2Sgo8OCcMoYxagEuZrzREuNXytZrzRtwYjpkl50uneXJ6ACIAk5jFbbID(A8OIAayYWFKh1btsGP5rbeEDftvWLKbGjZHGKCjYjZbAFmvCFSRw7Jh)(aAoF)67di86kMQGljdatMdbj5smSA)67FLLN0ekiwQ89b3(y3(4XVpGWRRyQcUKmamzoeKKlrozoq7JPI7xBSB)67pAkY7q2e2uKshOul9OMJYw9OdOL6KLxIN8feiq1xJhnvsGWWkYJIHh1Cu2QhDaTuN8oK5rf1aWKH)ip5liqGmFnEuZrzREu(Pn6BtanJ8OIAayYWFKN8KhnjbXxJVam814rnhLT6rd5YmjbH7rf1aWKH)ip5jpkx814ladFnEuZrzRE0tlujpQOgaMm8h5jFbb6RXJkQbGjd)rE0ujbcdROzE5rhcGWRRi)0g9TPGaaAojYjZbctfRTh1Cu2QhDaTuN8oK5rtLeimSIMLSgGX8Oy4jFb12xJh1Cu2QhLFAJ(2eqZipQOgaMm8h5jp5r5KrtcMkiH4(A8fGHVgpQOgaMm8h5rvdr8OPYDWqYaWKj2i0ukezoeCPt8OMJYw9OPYDWqYaWKj2i0ukezoeCPt8KVGa914rf1aWKH)ipQAiIhnvobdDud5ZrIlvzcqympQ5OSvpAQCcg6OgYNJexQYeGWyEYxqT914rf1aWKH)ipQAiIhTXjWlwFl1YPPjInDwP4rnhLT6rBCc8I13sTCAAIytNvkEYxWH914rf1aWKH)ipQAiIhDyqqiDRZH4anRcjOWDI6epQ5OSvp6WGGq6wNdXbAwfsqH7e1jEYxa25RXJkQbGjd)rEu1qepkI5maqzYpfHMiH805rnhLT6rrmNbakt(Pi0ejKNop5laO6RXJkQbGjd)rEu1qep6fZqKzFnbyeXepQ5OSvp6fZqKzFnbyeXep5laiZxJhvudatg(J8OQHiE0BgirfiFEbBD4rnhLT6rVzGevG85fS1HN8faK814rf1aWKH)ipQAiIhLmamHM91Ci8klHEuZrzREuYaWeA2xZHWRSe6jFbyF(A8OIAayYWFKhvneXJYt9kKnnEvcnL4ta2OuM918sGTlPGEuZrzREuEQxHSPXRsOPeFcWgLYSVMxcSDjf0t(cWOw(A8OIAayYWFKhvneXJYt9kKnlz2inQH8jaBukZ(AEjW2LuqpQ5OSvpkp1Rq2SKzJ0OgYNaSrPm7R5LaBxsb9KVamWWxJh1Cu2QhfaR7X8keg0JkQbGjd)rEYxagb6RXJAokB1JELqbaR7Hhvudatg(J8KVamQTVgpQ5OSvpkabYfiOul9OIAayYWFKN8KN8OwiD2qpkAIaeEYtEp]] )


end