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


    spec:RegisterPack( "Affliction", 20210307, [[dye1wbqiLkEeOO2Ka9jLkbJsPQtPcELsKzrs5wkvQDjPFjiggOWXeGLbk9mbjtJKQUgOiBJKk13uQKgNGu5CkvIwhjvOMNsu3JeTpsOdssLSqb0dfKctuqkDrsQqoPGuLwPk0mjPcYnjPIStqv)uPsOHssf1sjPc8uvAQKGVkivXEH6VsmyehMyXkPhJ0KLQlJAZsXNfQrRuoTOxlOMnKBdYUP63kgUu64csvTCGNtQPt56cz7KKVdQmEsQG68kH1lifnFv0(v14aWkGVDXym8WcdydagHcg7AfwyHPaGXUIV2IwgFBfAyjMXxxGy8vD10GsQLJJVTYc0iDSc4REIaugF3mRvRooKqItBlATshOq0juesSCCkqASq0jene8DnkrwOxhVIVDXym8WcdydagHcg7AfwyHPaGbmHV6wMIHhw1nmHVBzVZoEfF7SMIVQRMgusTC8Ne6raOHg(pQoja62t2v1EcSWa2a(J)XqJnXJzT64)4UFI6Q35(tUTmc9e1HgA46FC3prD17C)jHww1ebEI6KeN06FC3prD17C)jRawct3e3z0tqtCsFsZaEsOfiP)K7eHQ)XD)efGJLWprDsqCtsFI6aP1Ia8tqtCsFInpbUbe(jzZtwmr7ca(jqPwNE8tKNycID7jP)eBtSNag4Q)XD)e1rUSI4NOoqGAf3EI6QPbLulhx)e1zvQZpXee7w9pU7NOaCSew)eBEIOAY(twrdCPh)KqRachJea)K0FcueYYDBciMTNaxiZtcT7IkOFsuB9pU7NeAmENDn)e9aXpj0kGWXibWprDgWTpHkiK(j28ea3JO8tOduBKjwo(tSeIR)XD)KlBprpq8tOccveQLJxqP2Ec7giz9tS5jAdKu7j28er1K9Nq3yA40JFck1M(j2MypbUX3fSNSYpbWcDJ71)4UFYUOJw8KlZ9NmoLFslG3DBecvX3wW0KigFHzy(jQRMgusTC8Ne6raOHg(pcZW8tuNeaD7j7QApbwyaBa)X)imdZpj0yt8ywRo(pcZW8t29tux9o3FYTLrONOo0qdx)JWmm)KD)e1vVZ9NeAzvte4jQtsCsR)rygMFYUFI6Q35(twbSeMUjUZONGM4K(KMb8Kqlqs)j3jcv)JWmm)KD)efGJLWprDsqCtsFI6aP1Ia8tqtCsFInpbUbe(jzZtwmr7ca(jqPwNE8tKNycID7jP)eBtSNag4Q)rygMFYUFI6ixwr8tuhiqTIBprD10GsQLJRFI6Sk15NycIDR(hHzy(j7(jkahlH1pXMNiQMS)Kv0ax6Xpj0kGWXibWpj9NafHSC3MaIz7jWfY8Kq7UOc6Ne1w)JWmm)KD)KqJX7SR5NOhi(jHwbeogja(jQZaU9jubH0pXMNa4EeLFcDGAJmXYXFILqC9pcZW8t29tUS9e9aXpHkiurOwoEbLA7jSBGK1pXMNOnqsTNyZtevt2FcDJPHtp(jOuB6NyBI9e4gFxWEYk)eal0nUx)JWmm)KD)KDrhT4jxM7pzCk)KwaV72ieQ(h)Jc1YX11wathOvXu2WOsFGsxSCC1YgLwcXkcJG70YwvqPko4oRrnn1yqcnjGlttrluq2KuUg1(hfQLJRRTaMoqRITKYq0rqqJxAz7pkulhxxBbmDGwfBjLHedsOjbCzAkAHcYMKYQLnknbXUvJbj0KaUmnfTqbzts5k7YkI7)rHA546AlGPd0QylPmevciLveRMlqSY(y6cGL(c1ujOiwPqTufx6JvPdae1A54kcJGc1svCPpwvIhFHIWiOqTufx6JvJCTjRiUinnOKA54kcJG73Xee7wvNTBJxqzdxzxwrC)8uOwQIl9XQ6SDB8ckByfHXHG77JvB3e3gOIo94iKasBr1sA40Jpp3Xee7wTDtCBGk60JJqciTfv2Lve3p8hfQLJRRTaMoqRITKYqI0CjngsnxGyLsOPEtaIU0mUvMMs7ahd(Jc1YX11wathOvXwsziAM7LPPqhaiQ1YXvdLoxODLbad1YgL6wgHkMaIztx1m3lttHoaquRLJxKHvuzOcUdh6hLTTCVgG6ExgQau)FuOwoUU2cy6aTk2skdztIC7pkulhxxBbmDGwfBjLHO3K(axzDqMAzJYDmbXUv3Ki3QSlRiUhu3YiuXeqmB6QM5EzAk0baIATC8Im8YHk4oCOFu22Y9AaQ7DzOcq9)X)imdZprDK6WmnY4(tyvmyXtSeIFITXprO2aEsQFIOssKSI46FuOwoUwPULrOcAOH)Jc1YX1lPmKoRAIafijoP)rHA546LugcvqOIqTC8ck1MAUaXkLHvtBGKAkdqTSrPqTufxyNHswRyO(Jc1YX1lPmK2nXTbQOtpocjG0wOw2O0siwXqbJ)OqTCC9skdHkiurOwoEbLAtnxGyLDbeogjaU0c4w1YgL7PJk2f3QQy32wac2hRMqTS3tpUqft0gyA34sFSQL0WPhhKodQpW5vDee04LUachJeaxbmKKUEzydUVpwTDtCBGk60JJqciTfvadjPRve2ZZDmbXUvB3e3gOIo94iKasBrLDzfX9dhop3thvSlUv9mEZknchSpwvprOcySQL0WPhhKodQpW5vDee04LUachJeaxbmKKUEzydUVpwTDtCBGk60JJqciTfvadjPRve2ZZDmbXUvB3e3gOIo94iKasBrLDzfX9dhop3VNoQyxCR6mfmOb0ppPJk2f3QHxasXppPJk2f3Q(48HG9XQTBIBdurNECesaPTOAjnC6Xb7JvB3e3gOIo94iKasBrfWqs66LH9WFuOwoUEjLHiXJVqTSrzFSQep(IkGHK01lR()OqTCC9skdrIhFHA0fuexmbeZMwzaQLnk3lulvXf2zOK1kgWHG77JvL4XxubmKKUEz1F4pkulhxVKYq2Ki3(Jc1YX1lPmeQGqfHA54fuQn1CbIv2fq4yKa4slGBvlBuUxOwQIlSZqjRve2G0rf7IBvvSBBlab3tNb1h48Ac1YEp94cvmrBGPDJRaw6lop7JvtOw27PhxOIjAdmTBCPpw1sA40JpeCFFSA7M42av0PhhHeqAlQwsdNE855oMGy3QTBIBdurNECesaPTOYUSI4(HdNN7fQLQ4c7muYAfHn4E6OIDXTQZuWGgq)8KoQyxCRgEbif)8KoQyxCR6JZhcUVpwTDtCBGk60JJqciTfvlPHtp(8ChtqSB12nXTbQOtpocjG0wuzxwrC)WHZZ9c1svCHDgkzTIWgKoQyxCR6z8MvAeo4E6mO(aNx1teQagRcyPV48SpwvprOcySQL0WPhFi4((y12nXTbQOtpocjG0wuTKgo94ZZDmbXUvB3e3gOIo94iKasBrLDzfX9dh(Jc1YX1lPmenZ9Y0uOdae1A54QLnkfQLQ4c7muYAfHnOji2TQEGRyBCrZCxxzxwrCp4o9XQAM7LPPqhaiQ1YXRwsdNECWDsV0GY4n7pkulhxVKYq0m3lttHoaquRLJRw2OuOwQIlSZqjRve2GMGy3Q6SDB8ckB4k7YkI7b3PpwvZCVmnf6aarTwoE1sA40JdUt6LgugVzb7JvPdae1A54vadjPRxw9)rHA546LugIQeXfts3ulBuUxprOIEtaDfd48uOwQIlSZqjRve2dbPZG6dCEvhbbnEPlGWXibWvadjPRvmay)Jc1YX1lPmKixBYkIlstdkPwoUAzJsHAPkU0hRg5AtwrCrAAqj1YXvcJZtlPHtpoyFSAKRnzfXfPPbLulhVcyijD9YQ)pkulhxVKYq0z724fu2WQLnk7Jv1z724fu2WvadjPRxw9)rHA546LugIoB3gVGYgwn6ckIlMaIztRma1YgL7fQLQ4c7muYAfd4qW99XQ6SDB8ckB4kGHK01lR(d)rHA546LugcvqOIqTC8ck1MAUaXkPJk2f3ulBuUdDuXU4w1zkyqdO)hfQLJRxszi0baIATCC1YgLc1svCHDgkz9YQF37nbXUv1dCfBJlAM76k7YkI7NNMGy3Q6SDB8ckB4k7YkI7hc2hRshaiQ1YXRagssxVmS)rHA546LugcDaGOwlhxn6ckIlMaIztRma1YgL7fQLQ4c7muY6Lv)U3BcIDRQh4k2gx0m31v2Lve3ppnbXUv1z724fu2Wv2Lve3pCi4((yv6aarTwoEfWqs66LH9WFuOwoUEjLH0UjUnqfD6XribK2I)OqTCC9skdbsqCtslaP1IaSAzJs9eHk6nb0vu9)rHA546LugcvqOIqTC8ck1MAUaXk7ciCmsaCPfWTQLnk3thvSlUvvXUTTaeCpDguFGZRjul790JluXeTbM2nUcyPV48SpwnHAzVNECHkMOnW0UXL(yvlPHtp(qq6mO(aNx1rqqJx6ciCmsaCfWqs66LHn4((y12nXTbQOtpocjG0wubmKKUwrypp3Xee7wTDtCBGk60JJqciTfv2Lve3pC48C)E6OIDXTQZuWGgq)8KoQyxCRgEbif)8KoQyxCR6JZhcsNb1h48QoccA8sxaHJrcGRagssxVmSb33hR2UjUnqfD6XribK2IkGHK01kc755oMGy3QTBIBdurNECesaPTOYUSI4(HdNN7PJk2f3QEgVzLgHdUNodQpW5v9eHkGXQaw6lop7Jv1teQagRAjnC6XhcsNb1h48QoccA8sxaHJrcGRagssxVmSb33hR2UjUnqfD6XribK2IkGHK01kc755oMGy3QTBIBdurNECesaPTOYUSI4(Hd)rHA546LugsxaHl6jcPw2OKodQpW5vDee04LUachJeaxbmKKUwXMmEZkagssx)hfQLJRxsziubHkc1YXlOuBQ5ceRmng6pkulhxVKYqOccveQLJxqP2uZfiwPMvlBuIyvmsryAxdUVZRrnnv9M0h4km0kqOCvBcn8Y7HD3c1YXR6nPpWvwhKvtV0GY4n7W5zNxJAAQ6nPpWvyOvGq5kGHK01lhQd)rHA546LugcKG4MKwasRfby1YgLc1svCPpwvvI4IjPBkcJ)OqTCC9skdbsqCtslaP1IaSAzJsHAPkU0hRMqTS3tpUqft0gyA34sFmfHXFuOwoUEjLHajiUjPfG0ArawTSrPqTufx6Jv1teQagtry8hfQLJRxsziqcIBsAbiTweGvlBuAcIDR2UjUnqfD6XribK2Ik7YkI7b3lulvXL(y12nXTbQOtpocjG0wOimop1teQO3eqxXqDE2KXBwbWqs66LPZG6dCETDtCBGk60JJqciTfvadjPRp8hfQLJRxsziqcIBsAbiTweGvlBuAcIDRQh4k2gx0m31v2Lve3)Jc1YX1lPmKoqsVGYgwTSr5AuttnDwvAYkIlDgk1CvBcnSIQhgNNRrnn10zvPjRiU0zOuZ1O2Gnz8MvamKKUEz1)hfQLJRxsziubHkc1YXlOuBQ5ceRKoQyxC7pkulhxVKYqK4XxOw2OeWnawVjRi(pkulhxVKYqK4XxOgDbfXftaXSPvgGAzJY9c1svCHDgkzTIbCi4Ea3ay9MSI4d)rHA546LugcDaGOwlhxTSrjGBaSEtwrCqHAPkUWodLSEz1V79MGy3Q6bUITXfnZDDLDzfX9ZttqSBvD2UnEbLnCLDzfX9d)rHA546LugsKRnzfXfPPbLulhxTSrPqTufx6JvJCTjRiUinnOKA54kHX5PL0WPhheWnawVjRi(pkulhxVKYq0z724fu2WQLnkbCdG1BYkI)Jc1YX1lPmeD2UnEbLnSA0fuexmbeZMwzaQLnk3lulvXf2zOK1kgWHG7bCdG1BYkIp8hfQLJRxszi0baIATCC1OlOiUyciMnTYaulBuUxOwQIlSZqjRxw97EVji2TQEGRyBCrZCxxzxwrC)80ee7wvNTBJxqzdxzxwrC)WHG7bCdG1BYkIp8hfQLJRxsziDGKErprO)OqTCC9skdrVj9bUY6GS)4FuOwoUUkdRSDtCBGk60JJqciTf)rHA546Qm8skdztIC7pkulhxxLHxsziubHkc1YXlOuBQ5ceRSlGWXibWLwa3Qw2OCpDuXU4wvf722cqW(y1eQL9E6XfQyI2at7gx6JvTKgo94G0zq9boVQJGGgV0fq4yKa4kGHK01ldBW99XQTBIBdurNECesaPTOcyijDTIWEEUJji2TA7M42av0PhhHeqAlQSlRiUF4W55E6OIDXTQNXBwPr4G9XQ6jcvaJvTKgo94G0zq9boVQJGGgV0fq4yKa4kGHK01ldBW99XQTBIBdurNECesaPTOcyijDTIWEEUJji2TA7M42av0PhhHeqAlQSlRiUF4W55(90rf7IBvNPGbnG(5jDuXU4wn8cqk(5jDuXU4w1hNpeSpwTDtCBGk60JJqciTfvlPHtpoyFSA7M42av0PhhHeqAlQagssxVmSh(Jc1YX1vz4LugIM5EzAk0baIATCC1YgLMGy3Q6bUITXfnZDDLDzfX9GuXlAM7)rHA546Qm8skdrZCVmnf6aarTwoUAzJYDmbXUv1dCfBJlAM76k7YkI7b3PpwvZCVmnf6aarTwoE1sA40JdUt6LgugVzb7JvPdae1A54va3ay9MSI4)OqTCCDvgEjLHiXJVqn6ckIlMaIztRma1YgLc1svCPpwvIhFXYQpiGBaSEtwr8FuOwoUUkdVKYqK4XxOgDbfXftaXSPvgGAzJsHAPkU0hRkXJVqrLQpiGBaSEtwrCW(yvjE8fvlPHtp(pkulhxxLHxszirU2KvexKMgusTCC1YgLc1svCPpwnY1MSI4I00GsQLJRegNNwsdNECqa3ay9MSI4)OqTCCDvgEjLHe5AtwrCrAAqj1YXvJUGI4IjGy20kdqTSr5owsdNECWwvTMGy3QabQvCRinnOKA546k7YkI7bfQLQ4sFSAKRnzfXfPPbLulhF5q9hfQLJRRYWlPmevjIlMKUPw2OuprOIEtaDfd4pkulhxxLHxsziubHkc1YXlOuBQ5ceRKoQyxCtnTbsQPma1YgL7qhvSlUvDMcg0a6)rHA546Qm8skdHkiurOwoEbLAtnxGyLDbeogjaU0c4w1YgL7PJk2f3QQy32wacUNodQpW51eQL9E6XfQyI2at7gxbS0xCE2hRMqTS3tpUqft0gyA34sFSQL0WPhFiiDguFGZR6iiOXlDbeogjaUcyijD9YWgCFFSA7M42av0PhhHeqAlQagssxRiSNN7ycIDR2UjUnqfD6XribK2Ik7YkI7hoCEUFpDuXU4w1zkyqdOFEshvSlUvdVaKIFEshvSlUv9X5dbPZG6dCEvhbbnEPlGWXibWvadjPRxg2G77JvB3e3gOIo94iKasBrfWqs6AfH98ChtqSB12nXTbQOtpocjG0wuzxwrC)WHZZ90rf7IBvpJ3SsJWb3tNb1h48QEIqfWyval9fNN9XQ6jcvaJvTKgo94dbPZG6dCEvhbbnEPlGWXibWvadjPRxg2G77JvB3e3gOIo94iKasBrfWqs6AfH98ChtqSB12nXTbQOtpocjG0wuzxwrC)WH)OqTCCDvgEjLH0fq4IEIqQLnkPZG6dCEvhbbnEPlGWXibWvadjPRvSjJ3ScGHK01)rHA546Qm8skdHkiurOwoEbLAtnxGyLPXq)rHA546Qm8skdbsqCtslaP1IaSAzJY(yvvjIlMKUvTKgo94)OqTCCDvgEjLHajiUjPfG0ArawTSrzFSQEIqfWyvlPHtpo4oMGy3Q6bUITXfnZDDLDzfX9)OqTCCDvgEjLHajiUjPfG0ArawTSr5oMGy3QQsexmjDRYUSI4(FuOwoUUkdVKYqGee3K0cqATiaRw2OuprOIEtaDfv)FuOwoUUkdVKYq0z724fu2WQrxqrCXeqmBALbOw2OuOwQIl9XQ6SDB8ckB4LvgQGaUbW6nzfXb3PpwvNTBJxqzdxTKgo94)OqTCCDvgEjLHqfeQiulhVGsTPMlqSs6OIDXn10giPMYaulBushvSlUvDMcg0a6)rHA546Qm8skdPdK0lOSHvlBuUg10utNvLMSI4sNHsnx1MqdROsycgNNRrnn10zvPjRiU0zOuZ1O2Gnz8MvamKKUEzy68CnQPPMoRknzfXLodLAUQnHgwrLHcMc2hRQNiubmw1sA40J)Jc1YX1vz4LugshiPx0te6pkulhxxLHxszi6nPpWvwhK9h)Jc1YX1v6OIDXnLjul790JluXeTbM2nwTSrjDguFGZR6iiOXlDbeogjaUcyijD9YbaJZt6mO(aNx1rqqJx6ciCmsaCfWqs6AfHjy8hfQLJRR0rf7IBlPmKottiXspUSoitTSrjDguFGZR6iiOXlDbeogjaUcyijDTIWuW9DEnQPPUjrUvbmKKUwr1FEUJji2T6Me5wLDzfX9d)rHA546kDuXU42skdrprOcym1YgL0zq9boVQJGGgV0fq4yKa4kGHK01ldtNN0zq9boVQJGGgV0fq4yKa4kGHK01kctW48KodQpW5vDee04LUachJeaxbmKKUwryHPG0X7rPvPdae1APhxqmdQSlRiU)hfQLJRR0rf7IBlPmenDIaPhxS024)4FuOwoUU2fq4yKa4slGBvQkrCXK0n1YgL0zq9boVQJGGgV0fq4yKa4kGHK01ld7FuOwoUU2fq4yKa4slGBxsziDbeUONi0FuOwoUU2fq4yKa4slGBxsziTJLJ)hfQLJRRDbeogjaU0c42Lugstc4v0m9)OqTCCDTlGWXibWLwa3UKYqwrZ0lnrGf)rHA546AxaHJrcGlTaUDjLHSYandcNE8FuOwoUU2fq4yKa4slGBxsziubHkc1YXlOuBQ5ceRKoQyxCtTSr5o0rf7IBvNPGbnGEq6mO(aNx1rqqJx6ciCmsaCfWqs66LH9pkulhxx7ciCmsaCPfWTlPmeDee04LUachJea)h)Jc1YX110yiLrAUKgdP)J)rHA546QMvUjrU9hfQLJRRAEjLH0bs6f9eHulDJbGOwReJMvbPma1s3yaiQ1kzJYoVg10u1BsFGRWqRaHYvTj0WkQmu)rHA546QMxszi6nPpWvwhKHVQyGohhdpSWa2aGbSWi0HVWjap9yn(g6fQDag3FYU(eHA54pbLAtx)J4RezBdaFVjuOb(IsTPXkGV0rf7IByfWWhawb8LDzfXDCG4lfKgdsbFPZG6dCEvhbbnEPlGWXibWvadjPRFYYpjay8KZZNqNb1h48QoccA8sxaHJrcGRagssx)efFcmbd8vOwoo(MqTS3tpUqft0gyA3ySHHhwSc4l7YkI74aXxkingKc(sNb1h48QoccA8sxaHJrcGRagssx)efFcm9KGpz)t68AuttDtICRcyijD9tu8jQ)jNNpzNNycIDRUjrUvzxwrC)jhWxHA544BNPjKyPhxwhKHnm8HcRa(YUSI4ooq8LcsJbPGV0zq9boVQJGGgV0fq4yKa4kGHK01pz5Natp588j0zq9boVQJGGgV0fq4yKa4kGHK01prXNatW4jNNpHodQpW5vDee04LUachJeaxbmKKU(jk(eyHPNe8j0X7rPvPdae1APhxqmdQSlRiUJVc1YXXx9eHkGXWggE1JvaFfQLJJVA6ebspUyPTX4l7YkI74aXg2W3o3iridRag(aWkGVc1YXXxDlJqf0qdJVSlRiUJdeBy4HfRa(kulhhF7SQjcuGK4KIVSlRiUJdeBy4dfwb8LDzfXDCG4lfKgdsbFfQLQ4c7muY6NO4tcf(Qnqsnm8bGVc1YXXxQGqfHA54fuQn8fLAR4ceJVYWyddV6XkGVSlRiUJdeFPG0yqk4RLq8tu8jHcg4RqTCC8TDtCBGk60JJqciTfyddpmHvaFzxwrChhi(sbPXGuW39pHoQyxCRQIDBBb4jbFsFSAc1YEp94cvmrBGPDJl9XQwsdNE8tc(e6mO(aNx1rqqJx6ciCmsaCfWqs66NS8tG9jbFY(N0hR2UjUnqfD6XribK2IkGHK01prXNa7topFYopXee7wTDtCBGk60JJqciTfv2Lve3FYHNC4jNNpz)tOJk2f3QEgVzLgHFsWN0hRQNiubmw1sA40JFsWNqNb1h48QoccA8sxaHJrcGRagssx)KLFcSpj4t2)K(y12nXTbQOtpocjG0wubmKKU(jk(eyFY55t25jMGy3QTBIBdurNECesaPTOYUSI4(to8Kdp588j7FY(NqhvSlUvDMcg0a6p588j0rf7IB1WlaP4p588j0rf7IBvFC(jhEsWN0hR2UjUnqfD6XribK2IQL0WPh)KGpPpwTDtCBGk60JJqciTfvadjPRFYYpb2NCaFfQLJJVubHkc1YXlOuB4lk1wXfigF7ciCmsaCPfWTyddV6gRa(YUSI4ooq8LcsJbPGV9XQs84lQagssx)KLFI6XxHA544Rep(cSHHFxXkGVSlRiUJdeFfQLJJVs84lWxkingKc(U)jc1svCHDgkz9tu8jb8Kdpj4t2)K(yvjE8fvadjPRFYYpr9p5a(sxqrCXeqmBAm8bGnm8HoSc4RqTCC8DtICdFzxwrChhi2WWVlXkGVSlRiUJdeFPG0yqk47(NiulvXf2zOK1prXNa7tc(e6OIDXTQk2TTfGNe8j7FcDguFGZRjul790JluXeTbM2nUcyPV4jNNpPpwnHAzVNECHkMOnW0UXL(yvlPHtp(jhEsWNS)j9XQTBIBdurNECesaPTOAjnC6Xp588j78etqSB12nXTbQOtpocjG0wuzxwrC)jhEYHNCE(K9prOwQIlSZqjRFIIpb2Ne8j7FcDuXU4w1zkyqdO)KZZNqhvSlUvdVaKI)KZZNqhvSlUv9X5NC4jbFY(N0hR2UjUnqfD6XribK2IQL0WPh)KZZNSZtmbXUvB3e3gOIo94iKasBrLDzfX9NC4jhEY55t2)eHAPkUWodLS(jk(eyFsWNqhvSlUv9mEZknc)KGpz)tOZG6dCEvprOcySkGL(INCE(K(yv9eHkGXQwsdNE8to8KGpz)t6JvB3e3gOIo94iKasBr1sA40JFY55t25jMGy3QTBIBdurNECesaPTOYUSI4(to8Kd4RqTCC8LkiurOwoEbLAdFrP2kUaX4BxaHJrcGlTaUfBy4dagyfWx2Lve3XbIVuqAmif8vOwQIlSZqjRFIIpb2Ne8jMGy3Q6bUITXfnZDDLDzfX9Ne8j78K(yvnZ9Y0uOdae1A54vlPHtp(jbFYopj9sdkJ3m8vOwoo(QzUxMMcDaGOwlhhBy4diaSc4l7YkI74aXxkingKc(kulvXf2zOK1prXNa7tc(etqSBvD2UnEbLnCLDzfX9Ne8j78K(yvnZ9Y0uOdae1A54vlPHtp(jbFYopj9sdkJ3SNe8j9XQ0baIATC8kGHK01pz5NOE8vOwoo(QzUxMMcDaGOwlhhBy4dawSc4l7YkI74aXxkingKc(U)j6jcv0BcO)efFsap588jc1svCHDgkz9tu8jW(Kdpj4tOZG6dCEvhbbnEPlGWXibWvadjPRFIIpjayXxHA544RQeXfts3Wgg(acfwb8LDzfXDCG4lfKgdsbFfQLQ4sFSAKRnzfXfPPbLulh)jkFcmEY55tSKgo94Ne8j9XQrU2KvexKMgusTC8kGHK01pz5NOE8vOwoo(g5AtwrCrAAqj1YXXgg(aupwb8LDzfXDCG4lfKgdsbF7Jv1z724fu2WvadjPRFYYpr94RqTCC8vNTBJxqzdJnm8batyfWx2Lve3XbIVc1YXXxD2UnEbLnm(sbPXGuW39prOwQIlSZqjRFIIpjGNC4jbFY(N0hRQZ2TXlOSHRagssx)KLFI6FYb8LUGI4IjGy20y4daBy4dqDJvaFzxwrChhi(sbPXGuW3DEcDuXU4w1zkyqdOJVc1YXXxQGqfHA54fuQn8fLAR4ceJV0rf7IByddFa7kwb8LDzfXDCG4lfKgdsbFfQLQ4c7muY6NS8tu)t29t2)etqSBv9axX24IM5UUYUSI4(topFIji2TQoB3gVGYgUYUSI4(to8KGpPpwLoaquRLJxbmKKU(jl)eyXxHA544lDaGOwlhhBy4di0HvaFzxwrChhi(kulhhFPdae1A544lfKgdsbF3)eHAPkUWodLS(jl)e1)KD)K9pXee7wvpWvSnUOzURRSlRiU)KZZNycIDRQZ2TXlOSHRSlRiU)Kdp5Wtc(K9pPpwLoaquRLJxbmKKU(jl)eyFYb8LUGI4IjGy20y4daBy4dyxIvaFfQLJJVTBIBdurNECesaPTaFzxwrChhi2WWdlmWkGVSlRiUJdeFPG0yqk4REIqf9Ma6prXNOE8vOwoo(cjiUjPfG0AragBy4HnaSc4l7YkI74aXxkingKc(U)j0rf7IBvvSBBlapj4t2)e6mO(aNxtOw27PhxOIjAdmTBCfWsFXtopFsFSAc1YEp94cvmrBGPDJl9XQwsdNE8to8KGpHodQpW5vDee04LUachJeaxbmKKU(jl)eyFsWNS)j9XQTBIBdurNECesaPTOcyijD9tu8jW(KZZNSZtmbXUvB3e3gOIo94iKasBrLDzfX9NC4jhEY55t2)K9pHoQyxCR6mfmOb0FY55tOJk2f3QHxasXFY55tOJk2f3Q(48to8KGpHodQpW5vDee04LUachJeaxbmKKU(jl)eyFsWNS)j9XQTBIBdurNECesaPTOcyijD9tu8jW(KZZNSZtmbXUvB3e3gOIo94iKasBrLDzfX9NC4jhEY55t2)e6OIDXTQNXBwPr4Ne8j7FcDguFGZR6jcvaJvbS0x8KZZN0hRQNiubmw1sA40JFYHNe8j0zq9boVQJGGgV0fq4yKa4kGHK01pz5Na7tc(K9pPpwTDtCBGk60JJqciTfvadjPRFIIpb2NCE(KDEIji2TA7M42av0PhhHeqAlQSlRiU)Kdp5a(kulhhFPccveQLJxqP2WxuQTIlqm(2fq4yKa4slGBXggEyHfRa(YUSI4ooq8LcsJbPGV0zq9boVQJGGgV0fq4yKa4kGHK01prXN0KXBwbWqs6A8vOwoo(2fq4IEIqyddpSHcRa(YUSI4ooq8vOwoo(sfeQiulhVGsTHVOuBfxGy8nngcBy4Hv9yfWx2Lve3XbIVuqAmif8fXQy0tu8jW0U(KGpz)t68AuttvVj9bUcdTcekx1Mqd)KLFY(Na7t29teQLJx1BsFGRSoiRMEPbLXB2to8KZZN051OMMQEt6dCfgAfiuUcyijD9tw(jH6jhWxHA544lvqOIqTC8ck1g(IsTvCbIXxnJnm8WctyfWx2Lve3XbIVuqAmif8vOwQIl9XQQsexmjD7jk(eyGVc1YXXxibXnjTaKwlcWyddpSQBSc4l7YkI74aXxkingKc(kulvXL(y1eQL9E6XfQyI2at7gx6J9efFcmWxHA544lKG4MKwasRfbySHHh2DfRa(YUSI4ooq8LcsJbPGVc1svCPpwvprOcySNO4tGb(kulhhFHee3K0cqATiaJnm8Wg6WkGVSlRiUJdeFPG0yqk4Rji2TA7M42av0PhhHeqAlQSlRiU)KGpz)teQLQ4sFSA7M42av0PhhHeqAlEIIpbgp588j6jcv0BcO)efFsOEY55tAY4nRayijD9tw(j0zq9boV2UjUnqfD6XribK2IkGHK01p5a(kulhhFHee3K0cqATiaJnm8WUlXkGVSlRiUJdeFPG0yqk4Rji2TQEGRyBCrZCxxzxwrChFfQLJJVqcIBsAbiTweGXgg(qbdSc4l7YkI74aXxkingKc(Ug10utNvLMSI4sNHsnx1Mqd)efFI6HXtopFYAuttnDwvAYkIlDgk1CnQ9jbFstgVzfadjPRFYYpr94RqTCC8TdK0lOSHXgg(qfawb8LDzfXDCG4RqTCC8LkiurOwoEbLAdFrP2kUaX4lDuXU4g2WWhkyXkGVSlRiUJdeFPG0yqk4lGBaSEtwrm(kulhhFL4XxGnm8HkuyfWx2Lve3XbIVc1YXXxjE8f4lfKgdsbF3)eHAPkUWodLS(jk(KaEYHNe8j7FcGBaSEtwr8toGV0fuexmbeZMgdFayddFOupwb8LDzfXDCG4lfKgdsbFbCdG1BYkIFsWNiulvXf2zOK1pz5NO(NS7NS)jMGy3Q6bUITXfnZDDLDzfX9NCE(etqSBvD2UnEbLnCLDzfX9NCaFfQLJJV0baIATCCSHHpuWewb8LDzfXDCG4lfKgdsbFfQLQ4sFSAKRnzfXfPPbLulh)jkFcmEY55tSKgo94Ne8jaUbW6nzfX4RqTCC8nY1MSI4I00GsQLJJnm8HsDJvaFzxwrChhi(sbPXGuWxa3ay9MSIy8vOwoo(QZ2TXlOSHXgg(qTRyfWx2Lve3XbIVc1YXXxD2UnEbLnm(sbPXGuW39prOwQIlSZqjRFIIpjGNC4jbFY(Na4gaR3Kve)Kd4lDbfXftaXSPXWha2WWhQqhwb8LDzfXDCG4RqTCC8LoaquRLJJVuqAmif8D)teQLQ4c7muY6NS8tu)t29t2)etqSBv9axX24IM5UUYUSI4(topFIji2TQoB3gVGYgUYUSI4(to8Kdpj4t2)ea3ay9MSI4NCaFPlOiUyciMnng(aWgg(qTlXkGVc1YXX3oqsVONie(YUSI4ooqSHHx9WaRa(kulhhF1BsFGRSoidFzxwrChhi2Wg(2cy6aTkgwbm8bGvaFzxwrChhi(sbPXGuWxlH4NO4tGXtc(KDEslBvbLQ4Ne8j78K1OMMAmiHMeWLPPOfkiBskxJAXxHA544BdJk9bkDXYXXggEyXkGVc1YXXxDee04LggTf5gdWx2Lve3XbInm8HcRa(YUSI4ooq8LcsJbPGVMGy3QXGeAsaxMMIwOGSjPCLDzfXD8vOwoo(gdsOjbCzAkAHcYMKYyddV6XkGVSlRiUJdeFNw8vZg(kulhhFvjGuwrm(Qsqrm(kulvXL(yv6aarTwo(tu8jW4jbFIqTufx6JvL4Xx8efFcmEsWNiulvXL(y1ixBYkIlstdkPwo(tu8jW4jbFY(NSZtmbXUv1z724fu2Wv2Lve3FY55teQLQ4sFSQoB3gVGYg(jk(ey8Kdpj4t2)K(y12nXTbQOtpocjG0wuTKgo94NCE(KDEIji2TA7M42av0PhhHeqAlQSlRiU)Kd4RkbuCbIX3(y6cGL(cSHHhMWkGVSlRiUJdeFDbIXxj0uVjarxAg3kttPDGJb4RqTCC8vcn1Bcq0LMXTY0uAh4ya2WWRUXkGVSlRiUJdeFfQLJJVAM7LPPqhaiQ1YXXxkingKc(QBzeQyciMnDvZCVmnf6aarTwoErg(jkQ8jH6jbFYopHd9JY2wUxLqt9MaeDPzCRmnL2bogGVO05cTJVbadSHHFxXkGVc1YXX3njYn8LDzfXDCGyddFOdRa(YUSI4ooq8LcsJbPGV78etqSB1njYTk7YkI7pj4t0TmcvmbeZMUQzUxMMcDaGOwlhVid)KLFsOEsWNSZt4q)OSTL7vj0uVjarxAg3kttPDGJb4RqTCC8vVj9bUY6GmSHn8vggRag(aWkGVc1YXX32nXTbQOtpocjG0wGVSlRiUJdeBy4HfRa(kulhhF3Ki3Wx2Lve3XbInm8HcRa(YUSI4ooq8LcsJbPGV7FcDuXU4wvf722cWtc(K(y1eQL9E6XfQyI2at7gx6JvTKgo94Ne8j0zq9boVQJGGgV0fq4yKa4kGHK01pz5Na7tc(K9pPpwTDtCBGk60JJqciTfvadjPRFIIpb2NCE(KDEIji2TA7M42av0PhhHeqAlQSlRiU)Kdp5WtopFY(NqhvSlUv9mEZknc)KGpPpwvprOcySQL0WPh)KGpHodQpW5vDee04LUachJeaxbmKKU(jl)eyFsWNS)j9XQTBIBdurNECesaPTOcyijD9tu8jW(KZZNSZtmbXUvB3e3gOIo94iKasBrLDzfX9NC4jhEY55t2)K9pHoQyxCR6mfmOb0FY55tOJk2f3QHxasXFY55tOJk2f3Q(48to8KGpPpwTDtCBGk60JJqciTfvlPHtp(jbFsFSA7M42av0PhhHeqAlQagssx)KLFcSp5a(kulhhFPccveQLJxqP2WxuQTIlqm(2fq4yKa4slGBXggE1JvaFzxwrChhi(sbPXGuWxtqSBv9axX24IM5UUYUSI4(tc(eQ4fnZD8vOwoo(QzUxMMcDaGOwlhhBy4HjSc4l7YkI74aXxkingKc(UZtmbXUv1dCfBJlAM76k7YkI7pj4t25j9XQAM7LPPqhaiQ1YXRwsdNE8tc(KDEs6LgugVzpj4t6JvPdae1A54va3ay9MSIy8vOwoo(QzUxMMcDaGOwlhhBy4v3yfWx2Lve3XbIVc1YXXxjE8f4lfKgdsbFfQLQ4sFSQep(INS8tu)tc(ea3ay9MSIy8LUGI4IjGy20y4daBy43vSc4l7YkI74aXxHA544Rep(c8LcsJbPGVc1svCPpwvIhFXtuu5tu)tc(ea3ay9MSI4Ne8j9XQs84lQwsdNEm(sxqrCXeqmBAm8bGnm8HoSc4l7YkI74aXxkingKc(kulvXL(y1ixBYkIlstdkPwo(tu(ey8KZZNyjnC6Xpj4taCdG1BYkIXxHA544BKRnzfXfPPbLulhhBy43LyfWx2Lve3XbIVc1YXX3ixBYkIlstdkPwoo(sbPXGuW3DEIL0WPh)KGpPvvRji2TkqGAf3kstdkPwoUUYUSI4(tc(eHAPkU0hRg5AtwrCrAAqj1YXFYYpju4lDbfXftaXSPXWha2WWhamWkGVSlRiUJdeFPG0yqk4REIqf9Ma6prXNea(kulhhFvLiUys6g2WWhqayfWx2Lve3XbIVuqAmif8DNNqhvSlUvDMcg0a64R2aj1WWha(kulhhFPccveQLJxqP2WxuQTIlqm(shvSlUHnm8balwb8LDzfXDCG4lfKgdsbF3)e6OIDXTQk2TTfGNe8j7FcDguFGZRjul790JluXeTbM2nUcyPV4jNNpPpwnHAzVNECHkMOnW0UXL(yvlPHtp(jhEsWNqNb1h48QoccA8sxaHJrcGRagssx)KLFcSpj4t2)K(y12nXTbQOtpocjG0wubmKKU(jk(eyFY55t25jMGy3QTBIBdurNECesaPTOYUSI4(to8Kdp588j7FY(NqhvSlUvDMcg0a6p588j0rf7IB1WlaP4p588j0rf7IBvFC(jhEsWNqNb1h48QoccA8sxaHJrcGRagssx)KLFcSpj4t2)K(y12nXTbQOtpocjG0wubmKKU(jk(eyFY55t25jMGy3QTBIBdurNECesaPTOYUSI4(to8Kdp588j7FcDuXU4w1Z4nR0i8tc(K9pHodQpW5v9eHkGXQaw6lEY55t6Jv1teQagRAjnC6Xp5Wtc(e6mO(aNx1rqqJx6ciCmsaCfWqs66NS8tG9jbFY(N0hR2UjUnqfD6XribK2IkGHK01prXNa7topFYopXee7wTDtCBGk60JJqciTfv2Lve3FYHNCaFfQLJJVubHkc1YXlOuB4lk1wXfigF7ciCmsaCPfWTyddFaHcRa(YUSI4ooq8LcsJbPGV0zq9boVQJGGgV0fq4yKa4kGHK01prXN0KXBwbWqs6A8vOwoo(2fq4IEIqyddFaQhRa(YUSI4ooq8vOwoo(sfeQiulhVGsTHVOuBfxGy8nngcBy4daMWkGVSlRiUJdeFPG0yqk4BFSQQeXfts3QwsdNEm(kulhhFHee3K0cqATiaJnm8bOUXkGVSlRiUJdeFPG0yqk4BFSQEIqfWyvlPHtp(jbFYopXee7wvpWvSnUOzURRSlRiUJVc1YXXxibXnjTaKwlcWyddFa7kwb8LDzfXDCG4lfKgdsbF35jMGy3QQsexmjDRYUSI4o(kulhhFHee3K0cqATiaJnm8be6WkGVSlRiUJdeFPG0yqk4REIqf9Ma6prXNOE8vOwoo(cjiUjPfG0AragBy4dyxIvaFzxwrChhi(kulhhF1z724fu2W4lfKgdsbFfQLQ4sFSQoB3gVGYg(jlR8jH6jbFcGBaSEtwr8tc(KDEsFSQoB3gVGYgUAjnC6X4lDbfXftaXSPXWha2WWdlmWkGVSlRiUJdeFPG0yqk4lDuXU4w1zkyqdOJVAdKuddFa4RqTCC8LkiurOwoEbLAdFrP2kUaX4lDuXU4g2WWdBayfWx2Lve3XbIVuqAmif8DnQPPMoRknzfXLodLAUQnHg(jkQ8jWemEY55twJAAQPZQstwrCPZqPMRrTpj4tAY4nRayijD9tw(jW0topFYAuttnDwvAYkIlDgk1CvBcn8tuu5tcfm9KGpPpwvprOcySQL0WPhJVc1YXX3oqsVGYggBy4HfwSc4RqTCC8TdK0l6jcHVSlRiUJdeBy4HnuyfWxHA544REt6dCL1bz4l7YkI74aXg2W3UachJeaxAbClwbm8bGvaFzxwrChhi(sbPXGuWx6mO(aNx1rqqJx6ciCmsaCfWqs66NS8tGfFfQLJJVQsexmjDdBy4HfRa(kulhhF7ciCrpri8LDzfXDCGyddFOWkGVc1YXX32XYXXx2Lve3XbInm8QhRa(kulhhFBsaVIMPJVSlRiUJdeBy4HjSc4RqTCC8DfntV0ebwGVSlRiUJdeBy4v3yfWxHA5447kd0miC6X4l7YkI74aXgg(DfRa(YUSI4ooq8LcsJbPGV78e6OIDXTQZuWGgq)jbFcDguFGZR6iiOXlDbeogjaUcyijD9tw(jWIVc1YXXxQGqfHA54fuQn8fLAR4ceJV0rf7IByddFOdRa(kulhhF1rqqJx6ciCmsam(YUSI4ooqSHn8nngcRag(aWkGVc1YXX3inxsJH04l7YkI74aXg2WxnJvadFayfWxHA5447Me5g(YUSI4ooqSHHhwSc4l7YkI74aX30ngaIATs2GVDEnQPPQ3K(axHHwbcLRAtOHvuzOWxHA544BhiPx0tecFt3yaiQ1kXOzvq4BayddFOWkGVc1YXXx9M0h4kRdYWx2Lve3XbInSHnSHnmg]] )


end