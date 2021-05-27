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


    spec:RegisterPack( "Affliction", 20210527, [[d8KCEdqiqOfbiQ4rkj0MKs(KOuJcqDkq0QefvOxjkmlLOBbi0UOQFHk1Wus0XqvSmrjpdvcttjvUgQsABOsuFtjbghQe5CaII1jkkZtjL7bk7dq6GOkLwiQKEiQsmrabxuuK0gffvYhbev6KIIuRuk1mffXnffj2Pss)uuuLHIQuSuLe0tLIPccUQOOI2QOOs9vrrvnwLu1EvQ)kvdgQdtzXG0JPYKv4YeBwr(SinAf1PfwnGOQxdWSr52aTBs)wYWfvhhqKLRQNdz6ixxeBhv8DLW4rvQopQQ1lkQG5dQUpGO0(v5npBiSBggj7vZALzXZk51Swb(vUcw3kxhqMDdXpx2n5MdGLk7g1aLDdVDAIfokkD3KB8zLn2qy3GQK3j7MzIYrzg3CNg0CcuVRa5gfGjmJIsDVnrCJcqh37gOjbJY06g6UzyKSxnRvMfpRKxZAf4x5kyDRCDRGDdkxC7vZIlZR7M5ymeDdD3meKB3WBNMyHJIspCMV9SYb4ANPy8pCwRGLhoRvMfpx7RnVmBAQGYSRnq8W82XqghUjxySdNjLdG)AdepmVDmKXHbccNk5pCMILgo)1giEyE7yiJdd9fdGB2uvyhMvPH7Wt1FyGWBHE4MkH5V2aXddHfIb4WzkgtMc3HxHwoL8YHzvA4omvhEr9aoCmDy(vs2VCyWaHcn9W2HjJjkD4qpmnB0H)AH)AdepCMQAqzYHxHgyUP0H5TttSWrrPOdZB4WBomzmrj)1giEyiSqmaOdt1HnovmomuwTi00ddeShqkZE5WHEyWegfarY(uHo8cURddeY8Ga6Wj5(Rnq8W8sPdrrYHrfOCyGG9asz2lhM38s(HDgJHomvh(LrItoSRaZtiJIspmfGI)AdepCJqhgvGYHDgJ1nhfL2zbIoSO0hc6WuDye9HJomvh24uX4WUzXbi00dZceHomnB0HxuA20HHkh(fZnld)1giE4mpLX)WnImoCPo5W5VaeZtym)1giEyE7aiFcIomqoqtE9W8cqaDyOYu9YHfDC4A6Wtr6mbKZHzvA4omvh2YZz8pCPm(hMQddTqOdpfPZe6WaRfDy6n08HZnhaeK(R912CuukYN)IRaHAeSjH1hfyOgfLUmMGrbOa0v2cI5c5nwWrAbrOjtt(0paR4LEn1rM7JPWj(K8RT5OOuKp)fxbc1OmGXnkbeS0EUqxBZrrPiF(lUceQrzaJ70paR4LEn1rM7JPWjlJjyKXeL8PFawXl9AQJm3htHt8IAqzY4ABokkf5ZFXvGqnkdyCZX(WGYKLQbkWgfH6Vyd(l5ySebM5OGJ0hf5D1)j5uukqxzlZrbhPpkYBPLYhORSL5OGJ0hf5tuezqzs3MMyHJIsb6kBbmejJjk5rr(CPDwmjErnOmzahU5OGJ0hf5rr(CPDwmjaDLq2c4rr(8ztPcSJcnnHzFq89u4aeAkC4qKmMOKpF2uQa7Oqtty2heFVOguMmG8ABokkf5ZFXvGqnkdyCNGKEqc4s1afywMdOz7nuFQuQxt98AH8xBZrrPiF(lUceQrzaJBKiJEn1D1)j5uu6swOs3nGXZkxgtWq5cJ1j7tfc5rIm61u3v)NKtrPDReGcJlU2MJIsr(8xCfiuJYag3ZwIsxBZrrPiF(lUceQrzaJ7efrguM0TPjw4OO0R91otL3fxcjJdlCKN)HPauomnlh2Cu9hoqh24ybZGYe)12CuukcgkxySoRCaU2MJIsrzaJ7HWPs(oOLgURT5OOuugW42zmw3CuuANfiAPAGcmRKLi6dhbJNLXemZrbhPlQagccOCX1M36OO0dZceHo8u9hM(qbi0HHkZgNOE)HBiJqh2E5WiJJmo8u9hgQmvVC4MkHD4vyrCNPbZfDeA6H5fJme9v(SWnVz2uQapCtOPjm7dI)Ydx0S8lcKC4spSRk2OwOxBZrrPOmGXTZySU5OO0olq0s1afy0hkaH6OCwqD3S4aSerF4iy8SmMGrbOSgpxBZrrPOmGXTZySU5OO0olq0s1afydHz8LrN(qbie6ABokkfLbmUDgJ1nhfL2zbIwQgOadrg1PpuacHwIOpCemEwgtWaEuKhvjS(xKNchGqtHdFuKpaZfDeAA3zKHOVYNL(OipfoaHMch(OiF(SPub2rHMMWSpi(EkCacnfYwOkH1rZ2pakxah(OipNGjDYcL8u4aeAkC4KXeL8OArNMLosKb6ABokkfLbmUDgJ1nhfL2zbIwQgOaByGwQ0PpuacHwIOpCemEwgtWCfhrnL8AKot9jtAbme5yFyqzIN(qbiuhLZccoCxvSrTq9OkH1)I8VaAHIaAwReoCG5yFyqzIN(qbiuVuPLRk2OwOEuLW6Fr(xaTqrRrFOaeYZJ3vfBulu)lGwOiiHdhyo2hguM4Ppuac1PfvlxvSrTq9OkH1)I8VaAHIwJ(qbiKplVRk2OwO(xaTqrqc512CuukkdyC7mgRBokkTZceTunqb2WaTuPtFOaecTerF4iy8SmMG5koIAk55iknZ)Bbme5yFyqzIN(qbiuhLZccoCxvSrTq9byUOJqt7oJme9v(S4Fb0cfb0SwjC4aZX(WGYep9HcqOEPslxvSrTq9byUOJqt7oJme9v(S4Fb0cfTg9HcqippExvSrTq9VaAHIGeoCG5yFyqzIN(qbiuNwuTCvXg1c1hG5IocnT7mYq0x5ZI)fqlu0A0hkaH8z5DvXg1c1)cOfkcsiV2MJIsrzaJBNXyDZrrPDwGOLQbkWggOLkD6dfGqOLi6dhbJNLXemGDfhrnL8Q4(Iv)aoCxXrutjpa(FykC4UIJOMsETubYwadro2hguM4Ppuac1r5SGGd3vfBuluF(SPub2rHMMWSpi((xaTqranRvchoWCSpmOmXtFOaeQxQ0YvfBuluF(SPub2rHMMWSpi((xaTqrRrFOaeYZJ3vfBulu)lGwOiiHdhyo2hguM4Ppuac1PfvlxvSrTq95ZMsfyhfAAcZ(G47Fb0cfTg9HcqiFwExvSrTq9VaAHIGeYRT5OOuugW42zmw3CuuANfiAPAGcSHbAPsN(qbieAjI(WrW4zzmbdIKXeL85ZMsfyhfAAcZ(G47f1GYKrlGHih7ddkt80hkaH6OCwqWH7QInQfQhLacwAFypGuM9I)fqlueqZALWHdmh7ddkt80hkaH6LkTCvXg1c1JsablTpShqkZEX)cOfkAn6dfGqEE8UQyJAH6Fb0cfbjC4aZX(WGYep9HcqOoTOA5QInQfQhLacwAFypGuM9I)fqlu0A0hkaH8z5DvXg1c1)cOfkcsiV2Cn51dJQe2HrZ2pqhoMo8uKothoqh2yGfIoCXr(RT5OOuugW4g0yYu46VLtjVSmMGbTqOwtr6m1Fb0cfTMW7IlHKofGsMJOkH1rZ2pAnkYNOiYGYKUnnXchfL6PWbi00RDME6WUIJOMshEue38MztPc8WnHMMWSpi(hoqh(tun00LhobjhgiypGuM9YHP6WcVtIoomnlh2L8VO0HrcDTnhfLIYag3oJX6MJIs7SarlvduGnShqkZEPN)s(YycgWUIJOMsEoIsZ8)wJI8byUOJqt7oJme9v(S0hf5PWbi00wUQyJAH6rjGGL2h2diLzV4Fb0cfTwwTaEuKpF2uQa7Oqtty2heF)lGwOiGMfC4qKmMOKpF2uQa7Oqtty2heFiHeoCGDfhrnL8AKot9jtAnkYJQew)lYtHdqOPTCvXg1c1JsablTpShqkZEX)cOfkATSAb8OiF(SPub2rHMMWSpi((xaTqranl4WHizmrjF(SPub2rHMMWSpi(qcjC4adSR4iQPKxf3xS6hWH7koIAk5bW)dtHd3vCe1uYRLkq2AuKpF2uQa7Oqtty2heFpfoaHM2AuKpF2uQa7Oqtty2heF)lGwOO1YcYR9kuMEbnF4rrOdl2Z4F4y6WPvOPhouQoSDy0S9JdJYfDeA6HZNnKCTnhfLIYag3oJX6MJIs7SarlvduGnkQN)s(YycgWUIJOMsEnsNP(KjTG4OipQsy9VipfoaHM2YvfBulupQsy9Vi)lGwOO1whKWHdSR4iQPKNJO0m)Vfehf5dWCrhHM2Dgzi6R8zPpkYtHdqOPTCvXg1c1hG5IocnT7mYq0x5ZI)fqlu0ARds4WbgyxXrutjVkUVy1pGd3vCe1uYdG)hMchUR4iQPKxlvGSfzmrjF(SPub2rHMMWSpi(TG4OiF(SPub2rHMMWSpi(EkCacnTLRk2OwO(8ztPcSJcnnHzFq89VaAHIwBDqETZ0thM3mBkvGhUj00eM9bX)Wb6Wu4aeA6Ydh0Hd0Hr2KCyQoCcsomqWEahUPsyxBZrrPOmGX9WEaDuLWwgtWgf5ZNnLkWok00eM9bX3tHdqOPxBZrrPOmGX9WEaDuLWwgtWGizmrjF(SPub2rHMMWSpi(TaEuKhvjS(xKNchGqtHdFuKpaZfDeAA3zKHOVYNL(OipfoaHMc51UHV6omVz2uQapCtOPjm7dI)Hxe08HZClknZ)5E1iDMoCMltoSR4iQP0HhfT8Wfnl)IajhobjhU0d7QInQfQ)Wz6PdNPcMZ)fJD4mVFOM6KddnzA6Wb6WH6kWqtxE45InoCIsb7WbLn6WVyd(hgyE4shgjUshOdBtK8hobjqETnhfLIYag35ZMsfyhfAAcZ(G4VmMG5koIAk51iDM6tM0IcqbO8AlxvSrTq9OkH1)I8VaAHIwJNwatFOaeYlG58FXy96hQPoX7QInQfQ)fqlu0A8WLZcoCikaPKipxgEbmN)lgRx)qn1jqETnhfLIYag35ZMsfyhfAAcZ(G4VmMG5koIAk55iknZ)BrbOauETLRk2OwO(amx0rOPDNrgI(kFw8VaAHIwJNwatFOaeYlG58FXy96hQPoX7QInQfQ)fqlu0A8WLZcoCikaPKipxgEbmN)lgRx)qn1jqETnhfLIYag35ZMsfyhfAAcZ(G4VmMGbSR4iQPKxf3xS6hWH7koIAk5bW)dtHd3vCe1uYRLkq2cy6dfGqEbmN)lgRx)qn1jExvSrTq9VaAHIwJhUCwWHdrbiLe55YWlG58FXy96hQPobYRT5OOuugW4oF2uQa7Oqtty2he)LXemOfc1AksNP(lGwOO14HlFTZ0thM3mBkvGhUj00eM9bX)Wb6Wu4aeA6Ydhu2OdtbOCyQoCcsoCrZYFyqdiF9hEue6ABokkfLbmUDgJ1nhfL2zbIwQgOaZvCe1uAzmbBuKpF2uQa7Oqtty2heFpfoaHM2cyxXrutjVgPZuFYe4WDfhrnL8CeLM5)qETnhfLIYag3wAP8x647ysNSpviemEwgtWgf5T0s57Fb0cfT26U2MJIsrzaJ7zlrPRDtT4W0SC4grgOdx6H5Idt2Nke6WX0Hd6WbsZMoSl5Frjg)dh6HNyr6mD46pCPhMMLdt2NkK)Wz(bnF4MiFU0dNjXKC4GYgDyJHQddvis(dt1HtqYHBezC4IJ8hg00eJX4FylpNXp00dZfhMxQ)tYPOuK)ABokkfLbmUrIm61u3v)NKtrPlJjyMJcosxubmeeqZQfzmrjpQw0PzPJezGAbXrrEKiJEn1D1)j5uuQNchGqtBbXq7tSiDMU2MJIsrzaJBKiJEn1D1)j5uu6YycM5OGJ0fvadbb0SArgtuYJI85s7SysAbXrrEKiJEn1D1)j5uuQNchGqtBbXq7tSiDMAnkY7Q)tYPOu)lGwOO1w312CuukkdyCZjysNSqPLXemGrvcRJMTFauEGd3CuWr6IkGHGaAwq2YvfBulupkbeS0(WEaPm7f)lGwOiGYtwxBZrrPOmGXDIIidkt620elCuu6YycM5OGJ0hf5tuezqzs3MMyHJIsHTs4WPWbi00wJI8jkImOmPBttSWrrP(xaTqrRTURT5OOuugW4gf5ZL2zXKS0X3XKozFQqiy8SmMGnkYJI85s7Sys8VaAHIwBDxBZrrPOmGXTZySU5OO0olq0s1afyUIJOMslr0hocgplJjyq0vCe1uYRI7lw9JRnVnpNX)W8s9FsofLEyqttmgJ)Hl9W8aeZ6WK9PcHwE46pCPhMlo8IGMpmVfkQyjKCyEP(pjNIsV2MJIsrzaJBx9FsofLU0X3XKozFQqiy8SmMGzok4iDrfWqqRToGiWKXeL8OArNMLosKbcoCYyIsEuKpxANftcKTgf5D1)j5uuQ)fqlu0AzDT5TtK8hMMLdx5Ik)YdJYfDCy7WOz7hhEXSOh2OdZRhU0dNPymzkChEfA5uYlhMQdBCQyC4IJ8olpp00RT5OOuugW4g0yYu46VLtjVSmMGHQewhnB)aORRffGcqZINRDM)SOhwl6Wi(Ql00dZBMnLkWd3eAAcZ(G4FyQoCMBrPz(p3RgPZ0HZCzYYd3Kacw6Hbc2diLzVC4y6WgJD4rrOdBVCylpNfY4ABokkfLbmUDgJ1nhfL2zbIwQgOaBypGuM9sp)L8LXemGDfhrnL8CeLM5)TGizmrjF(SPub2rHMMWSpi(Tgf5dWCrhHM2Dgzi6R8zPpkYtHdqOPTCvXg1c1JsablTpShqkZEX)In4djC4a7koIAk51iDM6tM0cIKXeL85ZMsfyhfAAcZ(G43AuKhvjS(xKNchGqtB5QInQfQhLacwAFypGuM9I)fBWhs4WbgyxXrutjVkUVy1pGd3vCe1uYdG)hMchUR4iQPKxlvGSLRk2OwOEuciyP9H9asz2l(xSbFiV2zorYHbc2d4Wnvc7WX0Hbc2diLzVC4fLMnDyOYHFXg8pSLAHU8W1F4y6W0S8YHxem2HHkh2OdZedrhoRddwVCyGG9asz2lhobjORT5OOuugW4EypGoQsylJjyqleQLRk2OwOEuciyP9H9asz2l(xaTqraDksNP(lGwOOwadrYyIs(8ztPcSJcnnHzFq8Hd3vfBuluF(SPub2rHMMWSpi((xaTqraDksNP(lGwOiiV2MJIsrzaJ7H9a6OkHTmMGbTqOwqKmMOKpF2uQa7Oqtty2he)wUQyJAH6rjGGL2h2diLzV4Fb0cfLHRk2OwOEuciyP9H9asz2l(rYBuu6Atr6m1Fb0cfDT5fJCZarJXoCqc4HtqwQC4P6pSP8P5qtpSw0Hr5IlMczCyHHKfZYlxBZrrPOmGXTZySU5OO0olq0s1afybjGx7vOm9cA(WnZ2OwC4mvqOV5KddvMQxomkx0rOPhgnB)aD4spCMIXKPWD4vOLtjVCTnhfLIYag3oJX6MJIs7SarlvduGHKLXemMWryaLxxbTaEiqtMM8OzBul6ci03CIhrMdWAaNfq0CuuQhnBJArhAXiFO9jwKotqch(qGMmn5rZ2Ow0fqOV5e)lGwOO14ciV2zorYHZumMmfUdVcTCk5LdVyw0ddAa5R)WJIqh2E5Wj5lpC9hoMomnlVC4fbJDyOYHrrQgtHZu6WuakhorPGDyAwoSk8oDyEZSPubE4Mqtty2he)RT5OOuugW4g0yYu46VLtjVSmMGnkYZjysNSqjpfoaHMch(OiFaMl6i00UZidrFLpl9rrEkCacnfo8rrEuLW6FrEkCacn9ABokkfLbmUbnMmfU(B5uYllJjyKXeL85ZMsfyhfAAcZ(G43c4rr(8ztPcSJcnnHzFq89u4aeAkC4UQyJAH6ZNnLkWok00eM9bX3tFI0Fb0cfb0S4v4WHwiuRPiDM6VaAHIwZvfBuluF(SPub2rHMMWSpi((xaTqrqETnhfLIYag3GgtMcx)TCk5LLXemYyIsEuTOtZshjYaDTbcVf6HZKysoCGoCPm(h2omqG30C4ul0dViO5dNPvHtqguMCyGGagi5WQy)HbnE)WiYCaq(dNPNo8uKothoqh2Gwj0HP6WIoo8OoSw0Hbde6WOCrhHMEyAwomImha012CuukkdyCpEl0olMKLXemOjtt(qfobzqzsFiGbs8iYCaa66wjC4qtMM8HkCcYGYK(qadK4tYBbTqOwtr6m1Fb0cfT26U2MJIsrzaJBNXyDZrrPDwGOLQbkWCfhrnLU2MJIsrzaJBlTu(lD8DmPt2NkecgplJjyVm9cA2GYKRT5OOuugW4orrKbLjDBAIfokkDzmbZCuWr6JI8jkImOmPBttSWrrPWwjC4u4aeAARxMEbnBqzY12CuukkdyCJI85s7Sysw647ysNSpviemEwgtWEz6f0SbLjxBZrrPOmGXTR(pjNIsx647ysNSpviemEwgtWEz6f0SbLjTmhfCKUOcyiO1whqeyYyIsEuTOtZshjYabhozmrjpkYNlTZIjbYRT5OOuugW4E8wODuLWwgkj)NKtW45ABokkfLbmUrZ2Ow0Hwm6AFTnhfLI8wjWYNnLkWok00eM9bX)ABokkf5TsYag3ZwIsxBZrrPiVvsgW42zmw3CuuANfiAPAGcSH9asz2l98xYxgtWa2vCe1uYZruAM)3AuKpaZfDeAA3zKHOVYNL(OipfoaHM2YvfBulupkbeS0(WEaPm7f)l2GFlGhf5ZNnLkWok00eM9bX3)cOfkcOzbhoejJjk5ZNnLkWok00eM9bXhsiHdhyxXrutjVgPZuFYKwJI8OkH1)I8u4aeAAlxvSrTq9OeqWs7d7bKYSx8Vyd(TaEuKpF2uQa7Oqtty2heF)lGwOiGMfC4qKmMOKpF2uQa7Oqtty2heFiHSfWa7koIAk5vX9fR(bC4UIJOMsEa8)Wu4WDfhrnL8APcKTgf5ZNnLkWok00eM9bX3tHdqOPTgf5ZNnLkWok00eM9bX3)cOfkATSG8ABokkf5TsYag3irg9AQ7Q)tYPO0LXemYyIsEuTOtZshjYa1YzAhjY4ABokkf5TsYag3irg9AQ7Q)tYPO0LXemisgtuYJQfDAw6irgOwqCuKhjYOxtDx9FsofL6PWbi00wqm0(elsNPwJI8U6)KCkk1)Y0lOzdktU2MJIsrERKmGXTLwk)Lo(oM0j7tfcbJNLXemZrbhPpkYBPLYFT116LPxqZguMCTnhfLI8wjzaJBlTu(lD8DmPt2NkecgplJjyMJcosFuK3slLpqHTUwVm9cA2GYKwJI8wAP89u4aeA612CuukYBLKbmUtuezqzs3MMyHJIsxgtWmhfCK(OiFIIidkt620elCuukSvchofoaHM26LPxqZguMCTnhfLI8wjzaJ7efrguM0TPjw4OO0Lo(oM0j7tfcbJNLXemisHdqOPTY5KtgtuY)gyUPu3MMyHJIsrErnOmz0YCuWr6JI8jkImOmPBttSWrrPRXfxBZrrPiVvsgW4MtWKozHslJjyOkH1rZ2pakpxBZrrPiVvsgW42zmw3CuuANfiAPAGcmxXrutPLi6dhbJNLXemi6koIAk5vX9fR(X12CuukYBLKbmUDgJ1nhfL2zbIwQgOaBypGuM9sp)L8LXemGDfhrnL8CeLM5)Ta2vfBuluFaMl6i00UZidrFLpl(xSbF4Whf5dWCrhHM2Dgzi6R8zPpkYtHdqOPq2YvfBulupkbeS0(WEaPm7f)l2GFlGhf5ZNnLkWok00eM9bX3)cOfkcOzbhoejJjk5ZNnLkWok00eM9bXhsiBbmWUIJOMsEvCFXQFahUR4iQPKha)pmfoCxXrutjVwQazlxvSrTq9OeqWs7d7bKYSx8VaAHIwlRwapkYNpBkvGDuOPjm7dIV)fqlueqZcoCisgtuYNpBkvGDuOPjm7dIpKqchoWUIJOMsEnsNP(KjTa2vfBulupQsy9Vi)l2GpC4JI8OkH1)I8u4aeAkKTCvXg1c1JsablTpShqkZEX)cOfkATSAb8OiF(SPub2rHMMWSpi((xaTqranl4WHizmrjF(SPub2rHMMWSpi(qc512CuukYBLKbmUh2dOJQe2Yycg0cHA5QInQfQhLacwAFypGuM9I)fqlueqNI0zQ)cOfkQfWqKmMOKpF2uQa7Oqtty2heF4WDvXg1c1NpBkvGDuOPjm7dIV)fqlueqNI0zQ)cOfkcYRT5OOuK3kjdyCpShqhvjSLXemOfc1YvfBulupkbeS0(WEaPm7f)lGwOOmCvXg1c1JsablTpShqkZEXpsEJIsxBksNP(lGwOORT5OOuK3kjdyC7mgRBokkTZceTunqbwqc412CuukYBLKbmUDgJ1nhfL2zbIwQgOaBimJVm60hkaHqxBZrrPiVvsgW42zmw3CuuANfiAPAGcSHbAPsN(qbie6ABokkf5TsYag3oJX6MJIs7SarlvduGHiJ60hkaHqlJjyJI85ZMsfyhfAAcZ(G47PWbi0u4WHizmrjF(SPub2rHMMWSpi(xBZrrPiVvsgW4g0yYu46VLtjVSmMGnkYZjysNSqjpfoaHMETnhfLI8wjzaJBqJjtHR)woL8YYyc2OipQsy9VipfoaHM2cIKXeL8OArNMLosKb6ABokkf5TsYag3GgtMcx)TCk5LLXemisgtuYZjysNSqPRT5OOuK3kjdyCdAmzkC93YPKxwgtWqvcRJMTFa01DTnhfLI8wjzaJBuKpxANftYshFht6K9PcHGXZYycM5OGJ0hf5rr(CPDwmjRbJlA9Y0lOzdktAbXrrEuKpxANftINchGqtV2MJIsrERKmGXTZySU5OO0olq0s1afyUIJOMslr0hocgplJjyUIJOMsEvCFXQFCTnhfLI8wjzaJ7XBH2zXKSmMGbnzAYhQWjidkt6dbmqIhrMdaqHXRReoCOfc1cAY0KpuHtqguM0hcyGeFsERPiDM6VaAHIwJxHdhAY0KpuHtqguM0hcyGepImhaGcJl41wJI8OkH1)I8u4aeA612CuukYBLKbmUhVfAhvjSLHsY)j5emEU2MJIsrERKmGXnA2g1Io0Irx7RT5OOuK3vCe1ucwaMl6i00UZidrFLpllJjyqKmMOKpF2uQa7Oqtty2he)wa7QInQfQhLacwAFypGuM9I)fqlu0A8Ss4WDvXg1c1JsablTpShqkZEX)cOfkcO86kB5QInQfQhLacwAFypGuM9I)fqlueqZIxB5kDKeK3v)NKtHM2zI8qETnhfLI8UIJOMszaJ7amx0rOPDNrgI(kFwwgtWiJjk5ZNnLkWok00eM9bXV1OiF(SPub2rHMMWSpi(EkCacn9ABokkf5DfhrnLYag3dXfGgfAAhAXOLXemxvSrTq9OeqWs7d7bKYSx8VaAHIakV2c4HanzAYpBjk5Fb0cfb01bhoejJjk5NTeLG8ABokkf5DfhrnLYag3OkH1)IwgtWGizmrjF(SPub2rHMMWSpi(Ta2vfBulupkbeS0(WEaPm7f)lGwOO14v4WDvXg1c1JsablTpShqkZEX)cOfkcO86kHd3vfBulupkbeS0(WEaPm7f)lGwOiGMfV2Yv6ijiVR(pjNcnTZe5H8ABokkf5DfhrnLYag3OkH1)IwgtWiJjk5ZNnLkWok00eM9bXV1OiF(SPub2rHMMWSpi(EkCacn9ABokkf5DfhrnLYag3ixL8HM2PGMLR912CuukYpmqlv60hkaHqWsqspibCPAGcmuLW6rQgK8xBZrrPi)WaTuPtFOaecLbmUtqspibCPAGcSXl2ykEPZrqiHDTnhfLI8dd0sLo9HcqiugW4obj9GeWLQbkWsz8ZN71u3qOamygfLETV2MJIsr(H9asz2l98xYHXjysNSqPRT5OOuKFypGuM9sp)L8mGX9WEaDuLWU2MJIsr(H9asz2l98xYZag35ffLETnhfLI8d7bKYSx65VKNbmUNIxGYQACTnhfLI8d7bKYSx65VKNbmUHYQA0NsE(xBZrrPi)WEaPm7LE(l5zaJBOYJKhqOPxBZrrPi)WEaPm7LE(l5zaJBNXyDZrrPDwGOLQbkWCfhrnLwgtWGOR4iQPKxf3xS6hxBZrrPi)WEaPm7LE(l5zaJBuciyP9H9asz2lx7RT5OOuKFimJVm60hkaHqWsqspibCPAGcmbmN)lgRx)qn1jlJjya7koIAk51iDM6tM0YvfBulupQsy9Vi)lGwOO1YALqchoWUIJOMsEoIsZ8)wUQyJAH6dWCrhHM2Dgzi6R8zX)cOfkATSwjKWHdSR4iQPKxf3xS6hWH7koIAk5bW)dtHd3vCe1uYRLkqETnhfLI8dHz8LrN(qbiekdyCNGKEqc4s1afyOefkRQr3afAMpIwgtWa2vCe1uYRr6m1NmPLRk2OwOEuLW6Fr(xaTqrRXLHeoCGDfhrnL8CeLM5)TCvXg1c1hG5IocnT7mYq0x5ZI)fqlu0ACziHdhyxXrutjVkUVy1pGd3vCe1uYdG)hMchUR4iQPKxlvG8ABokkf5hcZ4lJo9HcqiugW4obj9GeWLQbkWqvcJjefAA)tGYFzmbdyxXrutjVgPZuFYKwUQyJAH6rvcR)f5Fb0cfTgxcs4Wb2vCe1uYZruAM)3YvfBuluFaMl6i00UZidrFLpl(xaTqrRXLGeoCGDfhrnL8Q4(Iv)aoCxXrutjpa(FykC4UIJOMsETubYR912CuukYpkQN)somlTu(lJjyJI8wAP89VaAHIwJl1YvfBulupkbeS0(WEaPm7f)lGwOiGokYBPLY3)cOfk6ABokkf5hf1ZFjpdyCJI85s7SyswgtWgf5rr(CPDwmj(xaTqrRXLA5QInQfQhLacwAFypGuM9I)fqlueqhf5rr(CPDwmj(xaTqrxBZrrPi)OOE(l5zaJ7efrguM0TPjw4OO0LXeSrr(efrguM0TPjw4OOu)lGwOO14sTCvXg1c1JsablTpShqkZEX)cOfkcOJI8jkImOmPBttSWrrP(xaTqrxBZrrPi)OOE(l5zaJBx9FsofLUmMGnkY7Q)tYPOu)lGwOO14sTCvXg1c1JsablTpShqkZEX)cOfkcOJI8U6)KCkk1)cOfk6AFTnhfLI8bjGWsqspibeDTV2MJIsrEKaB2su6ABokkf5rsgW4E8wODuLWwgkj)NKt9uwb1yW4zzOK8Fso1JjydbAY0KhnBJArxaH(Mt8iYCaakmU4ABokkf5rsgW4gnBJArhAXOR912CuukYJiJ60hkaHqWsqspibCPAGcSqrUpHmOmPdKsmLsa7dHt4KRT5OOuKhrg1PpuacHYag3jiPhKaUunqbwOi6tCu9O(i4eQ0Hkm212CuukYJiJ60hkaHqzaJ7eK0dsaxQgOaR4i)eRweAA30a06olvU2MJIsrEezuN(qbiekdyCNGKEqc4s1afyd7bawL2hIdqppHEb5e1jxBZrrPipImQtFOaecLbmUtqspibCPAGcmqZzqFPJMfH6GjOWDTnhfLI8iYOo9HcqiugW4obj9GeWLQbkWMygO0RPouJiMCTnhfLI8iYOo9HcqiugW4obj9GeWLQbkWwyaevEuF6lDCTnhfLI8iYOo9HcqiugW4obj9GeWLQbkWidktOEn1hck3I)ABokkf5rKrD6dfGqOmGXDcs6bjGlvduGHcDkH1nuE8MsOouBKk9AQpjF5cI)12CuukYJiJ60hkaHqzaJ7eK0dsaxQgOadf6ucRNYSryu9OouBKk9AQpjF5cI)12CuukYJiJ60hkaHqzaJBOSQg9PKN)12CuukYJiJ60hkaHqzaJ7P4fOSQgxBZrrPipImQtFOaecLbmUHkpsEaHMETV2MJIsrE6dfGqDuolOUBwCaGXX(WGYKLQbkWq5IlmwxasjrEUmwYXyjcmGbgybiLe55YWlG58FXy96hQPo5aYkaPKipxg(qrUpHmOmPdKsmLsa7dHt4eipGScqkjYZLHhvjmMquOP9pbkFipGScqkjYZLHhLOqzvn6gOqZ8reKxBZrrPip9HcqOokNfu3nloazaJBo2hguMSunqbg9HcqOEPYsoglrGbm9Hcqipp(zd1Z)Y5nLFl6dfGqEE8ZgQ7QInQfkKxBZrrPip9HcqOokNfu3nloazaJBo2hguMSunqbg9HcqOoTOwYXyjcmGPpuac5ZYpBOE(xoVP8BrFOaeYNLF2qDxvSrTqH8ABokkf5Ppuac1r5SG6UzXbidyCZX(WGYKLQbkWggOLkD6dfGql5ySebgWqey6dfGqEE8ZgQN)LZBk)w0hkaH884Nnu3vfBuluiHeoCGHiW0hkaH8z5Nnup)lN3u(TOpuac5ZYpBOURk2OwOqcjC4cqkjYZLHpLXpFUxtDdHcWGzuu612CuukYtFOaeQJYzb1DZIdqgW4MJ9HbLjlvduGrFOaeQJYzbTKJXseyaZX(WGYep9HcqOEPslo2hguM4hgOLkD6dfGqqchoWCSpmOmXtFOaeQtlQwCSpmOmXpmqlv60hkaHGeoCG5yFyqzIN(qbiuVu5aYYX(WGYepkxCHX6cqkjYZLbKWHdmh7ddkt80hkaH60I6aYYX(WGYepkxCHX6cqkjYZLbK7M8VMcMSBwXv8W82Pjw4OO0dN5BpRCaU2R4kE4mfJ)HZAfS8WzTYS45AFTxXv8W8YSPPckZU2R4kEyG4H5TJHmoCtUWyhotkha)1EfxXddepmVDmKXHbccNk5pCMILgo)1EfxXddepmVDmKXHH(IbWnBQkSdZQ0WD4P6pmq4TqpCtLW8x7vCfpmq8WqyHyaoCMIXKPWD4vOLtjVCywLgUdt1HxupGdhthMFLK9lhgmqOqtpSDyYyIsho0dtZgD4Vw4V2R4kEyG4HZuvdkto8k0aZnLomVDAIfokkfDyEdhEZHjJjk5V2R4kEyG4HHWcXaGomvh24uX4Wqz1IqtpmqWEaPm7Ldh6Hbtyuaej7tf6Wl4UomqiZdcOdNK7V2R4kEyG4H5LshIIKdJkq5Wab7bKYSxomV5L8d7mgdDyQo8lJeNCyxbMNqgfLEykaf)1EfxXddepCJqhgvGYHDgJ1nhfL2zbIoSO0hc6WuDye9HJomvh24uX4WUzXbi00dZceHomnB0HxuA20HHkh(fZnld)1EfxXddepCMNY4F4grghUuNC48xaI5jmM)AVIR4HbIhM3oaYNGOddKd0KxpmVaeqhgQmvVCyrhhUMo8uKota5CywLgUdt1HT8Cg)dxkJ)HP6Wqle6Wtr6mHomWArhMEdnF4CZbabP)AFTnhfLI85V4kqOgbBsy9rbgQrrPlJjyuakaDLTGyUqEJfCKwqeAY0Kp9dWkEPxtDK5(ykCIpj)ABokkf5ZFXvGqnkdyCJsablTNl012CuukYN)IRaHAugW4o9dWkEPxtDK5(ykCYYycgzmrjF6hGv8sVM6iZ9Xu4eVOguMmU2MJIsr(8xCfiuJYag3CSpmOmzPAGcSrrO(l2G)soglrGzok4i9rrEx9FsofLc0v2YCuWr6JI8wAP8b6kBzok4i9rr(efrguM0TPjw4OOuGUYwadrYyIsEuKpxANftIxudktgWHBok4i9rrEuKpxANftcqxjKTaEuKpF2uQa7Oqtty2heFpfoaHMchoejJjk5ZNnLkWok00eM9bX3lQbLjdiV2MJIsr(8xCfiuJYag3jiPhKaUunqbML5aA2Ed1NkL61upVwi)12CuukYN)IRaHAugW4gjYOxtDx9FsofLUKfQ0Ddy8SYLXemuUWyDY(uHqEKiJEn1D1)j5uuA3kbOW4IRT5OOuKp)fxbc1OmGX9SLO012CuukYN)IRaHAugW4orrKbLjDBAIfokk9AFTxXv8WzQ8U4sizCyHJ88pmfGYHPz5WMJQ)Wb6WghlyguM4V2MJIsrWq5cJ1zLdW12CuukkdyCpeovY3bT0WDTnhfLIYag3oJX6MJIs7SarlvduGzLSerF4iy8SmMGzok4iDrfWqqaLlU2R4H5Tokk9WSarOdpv)HPpuacDyOYSXjQ3F4gYi0HTxomY4iJdpv)HHkt1lhUPsyhEfwe3zAWCrhHMEyEXidrFLplCZBMnLkWd3eAAcZ(G4V8Wfnl)IajhU0d7QInQf612CuukkdyC7mgRBokkTZceTunqbg9HcqOokNfu3nloalr0hocgplJjyuakRXZ12CuukkdyC7mgRBokkTZceTunqb2qygFz0PpuacHU2MJIsrzaJBNXyDZrrPDwGOLQbkWqKrD6dfGqOLi6dhbJNLXemGhf5rvcR)f5PWbi0u4Whf5dWCrhHM2Dgzi6R8zPpkYtHdqOPWHpkYNpBkvGDuOPjm7dIVNchGqtHSfQsyD0S9dGYfWHpkYZjysNSqjpfoaHMchozmrjpQw0PzPJezGU2MJIsrzaJBNXyDZrrPDwGOLQbkWggOLkD6dfGqOLi6dhbJNLXemxXrutjVgPZuFYKwadro2hguM4Ppuac1r5SGGd3vfBulupQsy9Vi)lGwOiGM1kHdhyo2hguM4Ppuac1lvA5QInQfQhvjS(xK)fqlu0A0hkaH884DvXg1c1)cOfkcs4WbMJ9HbLjE6dfGqDAr1YvfBulupQsy9Vi)lGwOO1Opuac5ZY7QInQfQ)fqlueKqETnhfLIYag3oJX6MJIs7SarlvduGnmqlv60hkaHqlr0hocgplJjyUIJOMsEoIsZ8)wadro2hguM4Ppuac1r5SGGd3vfBuluFaMl6i00UZidrFLpl(xaTqranRvchoWCSpmOmXtFOaeQxQ0YvfBuluFaMl6i00UZidrFLpl(xaTqrRrFOaeYZJ3vfBulu)lGwOiiHdhyo2hguM4Ppuac1PfvlxvSrTq9byUOJqt7oJme9v(S4Fb0cfTg9HcqiFwExvSrTq9VaAHIGeYRT5OOuugW42zmw3CuuANfiAPAGcSHbAPsN(qbieAjI(WrW4zzmbdyxXrutjVkUVy1pGd3vCe1uYdG)hMchUR4iQPKxlvGSfWqKJ9HbLjE6dfGqDuoli4WDvXg1c1NpBkvGDuOPjm7dIV)fqlueqZALWHdmh7ddkt80hkaH6LkTCvXg1c1NpBkvGDuOPjm7dIV)fqlu0A0hkaH884DvXg1c1)cOfkcs4WbMJ9HbLjE6dfGqDAr1YvfBuluF(SPub2rHMMWSpi((xaTqrRrFOaeYNL3vfBulu)lGwOiiH8ABokkfLbmUDgJ1nhfL2zbIwQgOaByGwQ0PpuacHwIOpCemEwgtWGizmrjF(SPub2rHMMWSpi(ErnOmz0cyiYX(WGYep9HcqOokNfeC4UQyJAH6rjGGL2h2diLzV4Fb0cfb0SwjC4aZX(WGYep9HcqOEPslxvSrTq9OeqWs7d7bKYSx8VaAHIwJ(qbiKNhVRk2OwO(xaTqrqchoWCSpmOmXtFOaeQtlQwUQyJAH6rjGGL2h2diLzV4Fb0cfTg9HcqiFwExvSrTq9VaAHIGeYR9kEyUM86Hrvc7WOz7hOdhthEksNPdhOdBmWcrhU4i)12CuukkdyCdAmzkC93YPKxwgtWGwiuRPiDM6VaAHIwt4DXLqsNcqjZruLW6Oz7hTgf5tuezqzs3MMyHJIs9u4aeA61EfpCME6WUIJOMshEue38MztPc8WnHMMWSpi(hoqh(tun00LhobjhgiypGuM9YHP6WcVtIoomnlh2L8VO0HrcDTnhfLIYag3oJX6MJIs7SarlvduGnShqkZEPN)s(YycgWUIJOMsEoIsZ8)wJI8byUOJqt7oJme9v(S0hf5PWbi00wUQyJAH6rjGGL2h2diLzV4Fb0cfTwwTaEuKpF2uQa7Oqtty2heF)lGwOiGMfC4qKmMOKpF2uQa7Oqtty2heFiHeoCGDfhrnL8AKot9jtAnkYJQew)lYtHdqOPTCvXg1c1JsablTpShqkZEX)cOfkATSAb8OiF(SPub2rHMMWSpi((xaTqranl4WHizmrjF(SPub2rHMMWSpi(qcjC4adSR4iQPKxf3xS6hWH7koIAk5bW)dtHd3vCe1uYRLkq2AuKpF2uQa7Oqtty2heFpfoaHM2AuKpF2uQa7Oqtty2heF)lGwOO1YcYR9kE4vOm9cA(WJIqhwSNX)WX0HtRqtpCOuDy7WOz7hhgLl6i00dNpBi5ABokkfLbmUDgJ1nhfL2zbIwQgOaBuup)L8LXemGDfhrnL8AKot9jtAbXrrEuLW6FrEkCacnTLRk2OwOEuLW6Fr(xaTqrRToiHdhyxXrutjphrPz(FliokYhG5IocnT7mYq0x5ZsFuKNchGqtB5QInQfQpaZfDeAA3zKHOVYNf)lGwOO1whKWHdmWUIJOMsEvCFXQFahUR4iQPKha)pmfoCxXrutjVwQazlYyIs(8ztPcSJcnnHzFq8BbXrr(8ztPcSJcnnHzFq89u4aeAAlxvSrTq95ZMsfyhfAAcZ(G47Fb0cfT26G8AVIhotpDyEZSPubE4Mqtty2he)dhOdtHdqOPlpCqhoqhgztYHP6Wji5Wab7bC4MkHDTnhfLIYag3d7b0rvcBzmbBuKpF2uQa7Oqtty2heFpfoaHMETnhfLIYag3d7b0rvcBzmbdIKXeL85ZMsfyhfAAcZ(G43c4rrEuLW6FrEkCacnfo8rr(amx0rOPDNrgI(kFw6JI8u4aeAkKx7v8Wn8v3H5nZMsf4HBcnnHzFq8p8IGMpCMBrPz(p3RgPZ0HZCzYHDfhrnLo8OOLhUOz5xei5Wji5WLEyxvSrTq9hotpD4mvWC(VySdN59d1uNCyOjtthoqhouxbgA6YdpxSXHtukyhoOSrh(fBW)WaZdx6WiXv6aDyBIK)WjibYRT5OOuugW4oF2uQa7Oqtty2he)LXemxXrutjVgPZuFYKwuakaLxB5QInQfQhvjS(xK)fqlu0A80cy6dfGqEbmN)lgRx)qn1jExvSrTq9VaAHIwJhUCwWHdrbiLe55YWlG58FXy96hQPobYRT5OOuugW4oF2uQa7Oqtty2he)LXemxXrutjphrPz(FlkafGYRTCvXg1c1hG5IocnT7mYq0x5ZI)fqlu0A80cy6dfGqEbmN)lgRx)qn1jExvSrTq9VaAHIwJhUCwWHdrbiLe55YWlG58FXy96hQPobYRT5OOuugW4oF2uQa7Oqtty2he)LXemGDfhrnL8Q4(Iv)aoCxXrutjpa(FykC4UIJOMsETubYwatFOaeYlG58FXy96hQPoX7QInQfQ)fqlu0A8WLZcoCikaPKipxgEbmN)lgRx)qn1jqETnhfLIYag35ZMsfyhfAAcZ(G4VmMGbTqOwtr6m1Fb0cfTgpC5R9kE4m90H5nZMsf4HBcnnHzFq8pCGomfoaHMU8WbLn6WuakhMQdNGKdx0S8hg0aYx)HhfHU2MJIsrzaJBNXyDZrrPDwGOLQbkWCfhrnLwgtWgf5ZNnLkWok00eM9bX3tHdqOPTa2vCe1uYRr6m1NmboCxXrutjphrPz(pKxBZrrPOmGXTLwk)Lo(oM0j7tfcbJNLXeSrrElTu((xaTqrRTURT5OOuugW4E2su6AVIhUPwCyAwoCJid0Hl9WCXHj7tfcD4y6WbD4aPzth2L8VOeJ)Hd9WtSiDMoC9hU0dtZYHj7tfYF4m)GMpCtKpx6HZKysoCqzJoSXq1HHkej)HP6Wji5WnImoCXr(ddAAIXy8pSLNZ4hA6H5IdZl1)j5uukYFTnhfLIYag3irg9AQ7Q)tYPO0LXemZrbhPlQagccOz1ImMOKhvl60S0rImqTG4OipsKrVM6U6)KCkk1tHdqOPTGyO9jwKotxBZrrPOmGXnsKrVM6U6)KCkkDzmbZCuWr6IkGHGaAwTiJjk5rr(CPDwmjTG4OipsKrVM6U6)KCkk1tHdqOPTGyO9jwKotTgf5D1)j5uuQ)fqlu0AR7ABokkfLbmU5emPtwO0YycgWOkH1rZ2pakpWHBok4iDrfWqqanliB5QInQfQhLacwAFypGuM9I)fqlueq5jRRT5OOuugW4orrKbLjDBAIfokkDzmbZCuWr6JI8jkImOmPBttSWrrPWwjC4u4aeAARrr(efrguM0TPjw4OOu)lGwOO1w312CuukkdyCJI85s7Sysw647ysNSpviemEwgtWgf5rr(CPDwmj(xaTqrRTURT5OOuugW42zmw3CuuANfiAPAGcmxXrutPLi6dhbJNLXemi6koIAk5vX9fR(X1EfpmVnpNX)W8s9FsofLEyqttmgJ)Hl9W8aeZ6WK9PcHwE46pCPhMlo8IGMpmVfkQyjKCyEP(pjNIsV2MJIsrzaJBx9FsofLU0X3XKozFQqiy8SmMGzok4iDrfWqqRToGiWKXeL8OArNMLosKbcoCYyIsEuKpxANftcKTgf5D1)j5uuQ)fqlu0AzDTxXdZBNi5pmnlhUYfv(LhgLl64W2HrZ2po8IzrpSrhMxpCPhotXyYu4o8k0YPKxomvh24uX4Wfh5DwEEOPxBZrrPOmGXnOXKPW1FlNsEzzmbdvjSoA2(bqxxlkafGMfpx7v8Wz(ZIEyTOdJ4RUqtpmVz2uQapCtOPjm7dI)HP6WzUfLM5)CVAKothoZLjlpCtciyPhgiypGuM9YHJPdBm2HhfHoS9YHT8CwiJRT5OOuugW42zmw3CuuANfiAPAGcSH9asz2l98xYxgtWa2vCe1uYZruAM)3cIKXeL85ZMsfyhfAAcZ(G43AuKpaZfDeAA3zKHOVYNL(OipfoaHM2YvfBulupkbeS0(WEaPm7f)l2GpKWHdSR4iQPKxJ0zQpzslisgtuYNpBkvGDuOPjm7dIFRrrEuLW6FrEkCacnTLRk2OwOEuciyP9H9asz2l(xSbFiHdhyGDfhrnL8Q4(Iv)aoCxXrutjpa(FykC4UIJOMsETubYwUQyJAH6rjGGL2h2diLzV4FXg8H8AVIhoZjsomqWEahUPsyhoMomqWEaPm7LdVO0SPddvo8l2G)HTul0LhU(dhthMMLxo8IGXomu5WgDyMyi6WzDyW6LddeShqkZE5WjibDTnhfLIYag3d7b0rvcBzmbdAHqTCvXg1c1JsablTpShqkZEX)cOfkcOtr6m1Fb0cf1cyisgtuYNpBkvGDuOPjm7dIpC4UQyJAH6ZNnLkWok00eM9bX3)cOfkcOtr6m1Fb0cfb512CuukkdyCpShqhvjSLXemOfc1cIKXeL85ZMsfyhfAAcZ(G43YvfBulupkbeS0(WEaPm7f)lGwOOmCvXg1c1JsablTpShqkZEXpsEJIsxBksNP(lGwOOR9kEyEXi3mq0ySdhKaE4eKLkhEQ(dBkFAo00dRfDyuU4IPqghwyizXS8Y12CuukkdyC7mgRBokkTZceTunqbwqc41EfxXdVcLPxqZhUz2g1IdNPcc9nNCyOYu9YHr5Iocn9WOz7hOdx6HZumMmfUdVcTCk5LRT5OOuugW42zmw3CuuANfiAPAGcmKSmMGXeocdO86kOfWdbAY0KhnBJArxaH(Mt8iYCawd4SaIMJIs9OzBul6qlg5dTpXI0zcs4Whc0KPjpA2g1IUac9nN4Fb0cfTgxa51EfpCMtKC4mfJjtH7WRqlNsE5WlMf9WGgq(6p8Oi0HTxoCs(Ydx)HJPdtZYlhErWyhgQCyuKQXu4mLomfGYHtukyhMMLdRcVthM3mBkvGhUj00eM9bX)ABokkfLbmUbnMmfU(B5uYllJjyJI8CcM0jluYtHdqOPWHpkYhG5IocnT7mYq0x5ZsFuKNchGqtHdFuKhvjS(xKNchGqtV2MJIsrzaJBqJjtHR)woL8YYycgzmrjF(SPub2rHMMWSpi(TaEuKpF2uQa7Oqtty2heFpfoaHMchURk2OwO(8ztPcSJcnnHzFq890Ni9xaTqranlEfoCOfc1AksNP(lGwOO1CvXg1c1NpBkvGDuOPjm7dIV)fqlueKxBZrrPOmGXnOXKPW1FlNsEzzmbJmMOKhvl60S0rImqx7v8WaH3c9WzsmjhoqhUug)dBhgiWBAoCQf6Hxe08HZ0QWjidktomqqadKCyvS)WGgVFyezoai)HZ0thEksNPdhOdBqRe6WuDyrhhEuhwl6WGbcDyuUOJqtpmnlhgrMda6ABokkfLbmUhVfANftYYycg0KPjFOcNGmOmPpeWajEezoaaDDReoCOjtt(qfobzqzsFiGbs8j5TGwiuRPiDM6VaAHIwBDxBZrrPOmGXTZySU5OO0olq0s1afyUIJOMsxBZrrPOmGXTLwk)Lo(oM0j7tfcbJNLXeSxMEbnBqzY12CuukkdyCNOiYGYKUnnXchfLUmMGzok4i9rr(efrguM0TPjw4OOuyReoCkCacnT1ltVGMnOm5ABokkfLbmUrr(CPDwmjlD8DmPt2NkecgplJjyVm9cA2GYKRT5OOuugW42v)NKtrPlD8DmPt2NkecgplJjyVm9cA2GYKwMJcosxubme0ARdicmzmrjpQw0PzPJezGGdNmMOKhf5ZL2zXKa512CuukkdyCpEl0oQsyldLK)tYjy8CTnhfLIYag3OzBul6qlgDTV2MJIsrERey5ZMsfyhfAAcZ(G4FTnhfLI8wjzaJ7zlrPRT5OOuK3kjdyC7mgRBokkTZceTunqb2WEaPm7LE(l5lJjya7koIAk55iknZ)BnkYhG5IocnT7mYq0x5ZsFuKNchGqtB5QInQfQhLacwAFypGuM9I)fBWVfWJI85ZMsfyhfAAcZ(G47Fb0cfb0SGdhIKXeL85ZMsfyhfAAcZ(G4djKWHdSR4iQPKxJ0zQpzsRrrEuLW6FrEkCacnTLRk2OwOEuciyP9H9asz2l(xSb)wapkYNpBkvGDuOPjm7dIV)fqlueqZcoCisgtuYNpBkvGDuOPjm7dIpKq2cyGDfhrnL8Q4(Iv)aoCxXrutjpa(FykC4UIJOMsETubYwJI85ZMsfyhfAAcZ(G47PWbi00wJI85ZMsfyhfAAcZ(G47Fb0cfTwwqETnhfLI8wjzaJBKiJEn1D1)j5uu6YycgzmrjpQw0PzPJezGA5mTJezCTnhfLI8wjzaJBKiJEn1D1)j5uu6YycgejJjk5r1IonlDKiduliokYJez0RPUR(pjNIs9u4aeAAligAFIfPZuRrrEx9FsofL6Fz6f0SbLjxBZrrPiVvsgW42slL)shFht6K9PcHGXZYycM5OGJ0hf5T0s5V26A9Y0lOzdktU2MJIsrERKmGXTLwk)Lo(oM0j7tfcbJNLXemZrbhPpkYBPLYhOWwxRxMEbnBqzsRrrElTu(EkCacn9ABokkf5TsYag3jkImOmPBttSWrrPlJjyMJcosFuKprrKbLjDBAIfokkf2kHdNchGqtB9Y0lOzdktU2MJIsrERKmGXDIIidkt620elCuu6shFht6K9PcHGXZYycgePWbi00w5CYjJjk5Fdm3uQBttSWrrPiVOguMmAzok4i9rr(efrguM0TPjw4OO014IRT5OOuK3kjdyCZjysNSqPLXemuLW6Oz7haLNRT5OOuK3kjdyC7mgRBokkTZceTunqbMR4iQP0se9HJGXZYycgeDfhrnL8Q4(Iv)4ABokkf5TsYag3oJX6MJIs7SarlvduGnShqkZEPN)s(YycgWUIJOMsEoIsZ8)wa7QInQfQpaZfDeAA3zKHOVYNf)l2GpC4JI8byUOJqt7oJme9v(S0hf5PWbi0uiB5QInQfQhLacwAFypGuM9I)fBWVfWJI85ZMsfyhfAAcZ(G47Fb0cfb0SGdhIKXeL85ZMsfyhfAAcZ(G4djKTagyxXrutjVkUVy1pGd3vCe1uYdG)hMchUR4iQPKxlvGSLRk2OwOEuciyP9H9asz2l(xaTqrRLvlGhf5ZNnLkWok00eM9bX3)cOfkcOzbhoejJjk5ZNnLkWok00eM9bXhsiHdhyxXrutjVgPZuFYKwa7QInQfQhvjS(xK)fBWho8rrEuLW6FrEkCacnfYwUQyJAH6rjGGL2h2diLzV4Fb0cfTwwTaEuKpF2uQa7Oqtty2heF)lGwOiGMfC4qKmMOKpF2uQa7Oqtty2heFiH8ABokkf5TsYag3d7b0rvcBzmbdAHqTCvXg1c1JsablTpShqkZEX)cOfkcOtr6m1Fb0cf1cyisgtuYNpBkvGDuOPjm7dIpC4UQyJAH6ZNnLkWok00eM9bX3)cOfkcOtr6m1Fb0cfb512CuukYBLKbmUh2dOJQe2Yycg0cHA5QInQfQhLacwAFypGuM9I)fqluugUQyJAH6rjGGL2h2diLzV4hjVrrPRnfPZu)fqlu012CuukYBLKbmUDgJ1nhfL2zbIwQgOalib8ABokkf5TsYag3oJX6MJIs7SarlvduGneMXxgD6dfGqORT5OOuK3kjdyC7mgRBokkTZceTunqb2WaTuPtFOaecDTnhfLI8wjzaJBNXyDZrrPDwGOLQbkWqKrD6dfGqOLXeSrr(8ztPcSJcnnHzFq89u4aeAkC4qKmMOKpF2uQa7Oqtty2he)RT5OOuK3kjdyCdAmzkC93YPKxwgtWgf55emPtwOKNchGqtV2MJIsrERKmGXnOXKPW1FlNsEzzmbBuKhvjS(xKNchGqtBbrYyIsEuTOtZshjYaDTnhfLI8wjzaJBqJjtHR)woL8YYycgejJjk55emPtwO012CuukYBLKbmUbnMmfU(B5uYllJjyOkH1rZ2pa66U2MJIsrERKmGXnkYNlTZIjzPJVJjDY(uHqW4zzmbZCuWr6JI8OiFU0olMK1GXfTEz6f0SbLjTG4OipkYNlTZIjXtHdqOPxBZrrPiVvsgW42zmw3CuuANfiAPAGcmxXrutPLi6dhbJNLXemxXrutjVkUVy1pU2MJIsrERKmGX94Tq7SyswgtWGMmn5dv4eKbLj9HagiXJiZbaOW41vcho0cHAbnzAYhQWjidkt6dbmqIpjV1uKot9xaTqrRXRWHdnzAYhQWjidkt6dbmqIhrMdaqHXf8ARrrEuLW6FrEkCacn9ABokkf5TsYag3J3cTJQe2Yqj5)KCcgpxBZrrPiVvsgW4gnBJArhAXOR912CuukY7koIAkblaZfDeAA3zKHOVYNLLXemisgtuYNpBkvGDuOPjm7dIFlGDvXg1c1JsablTpShqkZEX)cOfkAnEwjC4UQyJAH6rjGGL2h2diLzV4Fb0cfbuEDLTCvXg1c1JsablTpShqkZEX)cOfkcOzXRTCLoscY7Q)tYPqt7mrEiV2MJIsrExXrutPmGXDaMl6i00UZidrFLpllJjyKXeL85ZMsfyhfAAcZ(G43AuKpF2uQa7Oqtty2heFpfoaHMETnhfLI8UIJOMszaJ7H4cqJcnTdTy0YycMRk2OwOEuciyP9H9asz2l(xaTqraLxBb8qGMmn5NTeL8VaAHIa66GdhIKXeL8ZwIsqETnhfLI8UIJOMszaJBuLW6FrlJjyqKmMOKpF2uQa7Oqtty2he)wa7QInQfQhLacwAFypGuM9I)fqlu0A8kC4UQyJAH6rjGGL2h2diLzV4Fb0cfbuEDLWH7QInQfQhLacwAFypGuM9I)fqlueqZIxB5kDKeK3v)NKtHM2zI8qETnhfLI8UIJOMszaJBuLW6FrlJjyKXeL85ZMsfyhfAAcZ(G43AuKpF2uQa7Oqtty2heFpfoaHMETnhfLI8UIJOMszaJBKRs(qt7uqZY1(ABokkf5hgOLkD6dfGqiyjiPhKaUunqbgQsy9ivds(RT5OOuKFyGwQ0PpuacHYag3jiPhKaUunqb24fBmfV05iiKWU2MJIsr(HbAPsN(qbiekdyCNGKEqc4s1afyPm(5Z9AQBiuagmJIsV2xBZrrPi)WEaPm7LE(l5W4emPtwO012CuukYpShqkZEPN)sEgW4EypGoQsyxBZrrPi)WEaPm7LE(l5zaJ78IIsV2MJIsr(H9asz2l98xYZag3tXlqzvnU2MJIsr(H9asz2l98xYZag3qzvn6tjp)RT5OOuKFypGuM9sp)L8mGXnu5rYdi00RT5OOuKFypGuM9sp)L8mGXTZySU5OO0olq0s1afyUIJOMslJjyq0vCe1uYRI7lw9JRT5OOuKFypGuM9sp)L8mGXnkbeS0(WEaPm7LR912CuukYpeMXxgD6dfGqiyjiPhKaUunqbMaMZ)fJ1RFOM6KLXemGDfhrnL8AKot9jtA5QInQfQhvjS(xK)fqlu0AzTsiHdhyxXrutjphrPz(FlxvSrTq9byUOJqt7oJme9v(S4Fb0cfTwwRes4Wb2vCe1uYRI7lw9d4WDfhrnL8a4)HPWH7koIAk51sfiV2MJIsr(HWm(YOtFOaecLbmUtqspibCPAGcmuIcLv1OBGcnZhrlJjya7koIAk51iDM6tM0YvfBulupQsy9Vi)lGwOO14YqchoWUIJOMsEoIsZ8)wUQyJAH6dWCrhHM2Dgzi6R8zX)cOfkAnUmKWHdSR4iQPKxf3xS6hWH7koIAk5bW)dtHd3vCe1uYRLkqETnhfLI8dHz8LrN(qbiekdyCNGKEqc4s1afyOkHXeIcnT)jq5VmMGbSR4iQPKxJ0zQpzslxvSrTq9OkH1)I8VaAHIwJlbjC4a7koIAk55iknZ)B5QInQfQpaZfDeAA3zKHOVYNf)lGwOO14sqchoWUIJOMsEvCFXQFahUR4iQPKha)pmfoCxXrutjVwQa51(ABokkf5hf1ZFjhMLwk)LXeSrrElTu((xaTqrRXLA5QInQfQhLacwAFypGuM9I)fqlueqhf5T0s57Fb0cfDTnhfLI8JI65VKNbmUrr(CPDwmjlJjyJI8OiFU0olMe)lGwOO14sTCvXg1c1JsablTpShqkZEX)cOfkcOJI8OiFU0olMe)lGwOORT5OOuKFuup)L8mGXDIIidkt620elCuu6Yyc2OiFIIidkt620elCuuQ)fqlu0ACPwUQyJAH6rjGGL2h2diLzV4Fb0cfb0rr(efrguM0TPjw4OOu)lGwOORT5OOuKFuup)L8mGXTR(pjNIsxgtWgf5D1)j5uuQ)fqlu0ACPwUQyJAH6rjGGL2h2diLzV4Fb0cfb0rrEx9FsofL6Fb0cfDTV2MJIsr(GeqyjiPhKaIU2xBZrrPipsGnBjkDTnhfLI8ijdyCpEl0oQsyldLK)tYPEkRGAmy8Smus(pjN6XeSHanzAYJMTrTOlGqFZjEezoaafgxCTnhfLI8ijdyCJMTrTOdTy01(ABokkf5rKrD6dfGqiyjiPhKaUunqbwOi3NqguM0bsjMsjG9HWjCY12CuukYJiJ60hkaHqzaJ7eK0dsaxQgOalue9joQEuFeCcv6qfg7ABokkf5rKrD6dfGqOmGXDcs6bjGlvduGvCKFIvlcnTBAaADNLkxBZrrPipImQtFOaecLbmUtqspibCPAGcSH9aaRs7dXbONNqVGCI6KRT5OOuKhrg1PpuacHYag3jiPhKaUunqbgO5mOV0rZIqDWeu4U2MJIsrEezuN(qbiekdyCNGKEqc4s1afytmdu61uhQretU2MJIsrEezuN(qbiekdyCNGKEqc4s1afylmaIkpQp9LoU2MJIsrEezuN(qbiekdyCNGKEqc4s1afyKbLjuVM6dbLBXFTnhfLI8iYOo9HcqiugW4obj9GeWLQbkWqHoLW6gkpEtjuhQnsLEn1NKVCbX)ABokkf5rKrD6dfGqOmGXDcs6bjGlvduGHcDkH1tz2imQEuhQnsLEn1NKVCbX)ABokkf5rKrD6dfGqOmGXnuwvJ(uYZ)ABokkf5rKrD6dfGqOmGX9u8cuwvJRT5OOuKhrg1PpuacHYag3qLhjpGqtV2xBZrrPip9HcqOokNfu3nloaW4yFyqzYs1afyOCXfgRlaPKipxgl5ySebgWadSaKsI8Cz4fWC(VySE9d1uNCazfGusKNldFOi3NqguM0bsjMsjG9HWjCcKhqwbiLe55YWJQegtik00(NaLpKhqwbiLe55YWJsuOSQgDduOz(icYRT5OOuKN(qbiuhLZcQ7MfhGmGXnh7ddktwQgOaJ(qbiuVuzjhJLiWaM(qbiKNh)SH65F58MYVf9Hcqipp(zd1DvXg1cfYRT5OOuKN(qbiuhLZcQ7MfhGmGXnh7ddktwQgOaJ(qbiuNwul5ySebgW0hkaH8z5Nnup)lN3u(TOpuac5ZYpBOURk2OwOqETnhfLI80hkaH6OCwqD3S4aKbmU5yFyqzYs1afydd0sLo9HcqOLCmwIadyicm9Hcqipp(zd1Z)Y5nLFl6dfGqEE8ZgQ7QInQfkKqchoWqey6dfGq(S8ZgQN)LZBk)w0hkaH8z5Nnu3vfBuluiHeoCbiLe55YWNY4Np3RPUHqbyWmkk9ABokkf5Ppuac1r5SG6UzXbidyCZX(WGYKLQbkWOpuac1r5SGwYXyjcmG5yFyqzIN(qbiuVuPfh7ddkt8dd0sLo9HcqiiHdhyo2hguM4Ppuac1Pfvlo2hguM4hgOLkD6dfGqqchoWCSpmOmXtFOaeQxQCaz5yFyqzIhLlUWyDbiLe55Yas4WbMJ9HbLjE6dfGqDArDaz5yFyqzIhLlUWyDbiLe55YaYDdh5rrP7vZALzXZk51S4IDZc71qtr7MmFE7kC1m9Qa5Mzh(WqywoCaMxpD4P6pC20hkaH6OCwqD3S4aK9HFbiLeVmomQaLdBjubAKmoSB20ub5V2zsOYHZkZomVukh5jzC4SPpuac55XV(SpmvhoB6dfGqEIh)6Z(WaNfVdP)ANjHkhMlYSdZlLYrEsghoB6dfGq(S8Rp7dt1HZM(qbiKNYYV(SpmWzX7q6V2zsOYHxxMDyEPuoYtY4WztFOaeYZJF9zFyQoC20hkaH8ep(1N9HbolEhs)1otcvo86YSdZlLYrEsghoB6dfGq(S8Rp7dt1HZM(qbiKNYYV(SpmWzX7q6V2x7mFE7kC1m9Qa5Mzh(WqywoCaMxpD4P6pC2UIJOMszF4xasjXlJdJkq5WwcvGgjJd7Mnnvq(RDMeQCyEYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WaZdVdP)ANjHkhMNm7W8sPCKNKXHZ2v6iji)6Z(WuD4SDLoscYVEVOguMmY(WaZdVdP)ANjHkhoRm7W8sPCKNKXHZMmMOKF9zFyQoC2KXeL8R3lQbLjJSpmW8W7q6V2zsOYH5Im7W8sPCKNKXHZMmMOKF9zFyQoC2KXeL8R3lQbLjJSpmW8W7q6V2zsOYHxxMDyEPuoYtY4WztgtuYV(SpmvhoBYyIs(17f1GYKr2hgyE4Di9x7mju5WRlZomVukh5jzC4SDLoscYV(SpmvhoBxPJKG8R3lQbLjJSpmW8W7q6V2zsOYH51m7W8sPCKNKXHZMmMOKF9zFyQoC2KXeL8R3lQbLjJSpmW8W7q6V2x7mFE7kC1m9Qa5Mzh(WqywoCaMxpD4P6pC2dzYsyu2h(fGus8Y4WOcuoSLqfOrY4WUzttfK)ANjHkhMlNzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9Hn6WzQzEzYHbMhEhs)1otcvo8kiZomVukh5jzC4SPpuac55XV(SpmvhoB6dfGqEIh)6Z(WaZdVdP)ANjHkhEfKzhMxkLJ8KmoC20hkaH8z5xF2hMQdNn9HcqipLLF9zFyG5H3H0FTZKqLdZLYSdZlLYrEsghoB6dfGqEE8Rp7dt1HZM(qbiKN4XV(SpmW8W7q6V2zsOYH5sz2H5Ls5ipjJdNn9HcqiFw(1N9HP6WztFOaeYtz5xF2hgyE4Di9x7mju5WazYSdZlLYrEsghoB6dfGqEE8Rp7dt1HZM(qbiKN4XV(SpmW8W7q6V2zsOYHbYKzhMxkLJ8KmoC20hkaH8z5xF2hMQdNn9HcqipLLF9zFyG5H3H0FTZKqLdZZkZSdZlLYrEsghoB6dfGqEE8Rp7dt1HZM(qbiKN4XV(SpmW8W7q6V2zsOYH5zLz2H5Ls5ipjJdNn9HcqiFw(1N9HP6WztFOaeYtz5xF2hgyE4Di9x7mju5W8KvMDyEPuoYtY4WztgtuYV(SpmvhoBYyIs(17f1GYKr2hg4S4Di9x7mju5W8Wfz2H5Ls5ipjJdNnzmrj)6Z(WuD4SjJjk5xVxudktgzFyG5H3H0FTZKqLdZdVMzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9HbMhEhs)1otcvompC5m7W8sPCKNKXHZM(qbiK3G68UQyJAHM9HP6Wz7QInQfQ3G6Y(WaZdVdP)ANjHkhMNvqMDyEPuoYtY4WztFOaeYBqDExvSrTqZ(WuD4SDvXg1c1BqDzFyG5H3H0FTZKqLdZdxkZomVukh5jzC4SPpuac5nOoVRk2OwOzFyQoC2UQyJAH6nOUSpmW8W7q6V2zsOYHZIlYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WaZdVdP)ANjHkhoR1LzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9HbMhEhs)1otcvoCwazYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WaNfVdP)ANjHkhMl4jZomVukh5jzC4SjJjk5xF2hMQdNnzmrj)69IAqzYi7ddCw8oK(RDMeQCyUiRm7W8sPCKNKXHZMmMOKF9zFyQoC2KXeL8R3lQbLjJSpmW8W7q6V2zsOYH5cUiZomVukh5jzC4SjJjk5xF2hMQdNnzmrj)69IAqzYi7ddmp8oK(RDMeQCyUyfKzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9HbMhEhs)1otcvomxWLYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WgD4m1mVm5WaZdVdP)ANjHkhEDRlZomVukh5jzC4SjJjk5xF2hMQdNnzmrj)69IAqzYi7ddCw8oK(R91oZN3UcxntVkqUz2HpmeMLdhG51thEQ(dNTvs2h(fGus8Y4WOcuoSLqfOrY4WUzttfK)ANjHkhMlYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WaNfVdP)ANjHkhEDz2H5Ls5ipjJdNnzmrj)6Z(WuD4SjJjk5xVxudktgzFyG5H3H0FTZKqLdZRz2H5Ls5ipjJdNnzmrj)6Z(WuD4SjJjk5xVxudktgzFyG5H3H0FTZKqLdZtwz2H5Ls5ipjJdNnzmrj)6Z(WuD4SjJjk5xVxudktgzFyG5cEhs)1otcvompCrMDyEPuoYtY4WztgtuYV(SpmvhoBYyIs(17f1GYKr2hgyE4Di9x7mju5W8WLYSdZlLYrEsghoBYyIs(1N9HP6WztgtuYVEVOguMmY(WgD4m1mVm5WaZdVdP)ANjHkhoRvMzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9Hn6WzQzEzYHbMhEhs)1otcvoCw8KzhMxkLJ8KmoC2KXeL8Rp7dt1HZMmMOKF9ErnOmzK9Hn6WzQzEzYHbMhEhs)1(ANPbZRNKXH5jRdBokk9WSari)1E3yj0C97MMaKx2nSarOne2nd7bKYSx65VKVHWEvE2qy3yokkD3WjysNSqPDJOguMm2CDt7vZAdHDJ5OO0DZWEaDuLW2nIAqzYyZ1nTxLl2qy3yokkD3Kxuu6UrudktgBUUP9QRBdHDJ5OO0DZu8cuwvJDJOguMm2CDt7v51ne2nMJIs3nqzvn6tjp)DJOguMm2CDt7v5YBiSBmhfLUBGkpsEaHMUBe1GYKXMRBAV6kydHDJOguMm2CD34(GKpSDdepSR4iQPKxf3xS6h7gZrrP7gNXyDZrrPDwGODdlquxnqz34koIAkTP9QCPne2nMJIs3nOeqWs7d7bKYSx2nIAqzYyZ1nTPDd9HcqOokNfu3nloaBiSxLNne2nIAqzYyZ1DtLVBqcTBmhfLUB4yFyqzYUHJXsKDdWhg4dd8HfGusKNldVaMZ)fJ1RFOM6KDdh77Qbk7guU4cJ1fGusKNlJnTxnRne2nIAqzYyZ1DtLVBqcTBmhfLUB4yFyqzYUHJXsKDdWhM(qbiKN4XpBOE(xoVP8pCRdtFOaeYt84Nnu3vfBul0dd5UHJ9D1aLDd9HcqOEPYM2RYfBiSBe1GYKXMR7MkF3GeA3yokkD3WX(WGYKDdhJLi7gGpm9HcqipLLF2q98VCEt5F4whM(qbiKNYYpBOURk2OwOhgYDdh77Qbk7g6dfGqDArTP9QRBdHDJOguMm2CD3u57gKq7gZrrP7go2hguMSB4ySez3a8HH4Hb(W0hkaH8ep(zd1Z)Y5nL)HBDy6dfGqEIh)SH6UQyJAHEyipmKhgo8dd8HH4Hb(W0hkaH8uw(zd1Z)Y5nL)HBDy6dfGqEkl)SH6UQyJAHEyipmKhgo8dlaPKipxg(ug)85En1nekadMrrP7go23vdu2ndd0sLo9HcqOnTxLx3qy3iQbLjJnx3nv(Ubj0UXCuu6UHJ9HbLj7goglr2naFyo2hguM4Ppuac1lvoCRdZX(WGYe)WaTuPtFOae6WqEy4WpmWhMJ9HbLjE6dfGqDArD4whMJ9HbLj(HbAPsN(qbi0HH8WWHFyGpmh7ddkt80hkaH6Lk7go23vdu2n0hkaH6OCwqBAt7MHbAPsN(qbieAdH9Q8SHWUrudktgBUUBudu2nOkH1Juni53nMJIs3nOkH1Juni530E1S2qy3iQbLjJnx3nQbk7MXl2ykEPZrqiHTBmhfLUBgVyJP4LohbHe2M2RYfBiSBe1GYKXMR7g1aLDtkJF(CVM6gcfGbZOO0DJ5OO0DtkJF(CVM6gcfGbZOO0nTPDZqygFz0PpuacH2qyVkpBiSBe1GYKXMR7gZrrP7gbmN)lgRx)qn1j7g3hK8HTBa(WUIJOMsEnsNP(KjhU1HDvXg1c1JQew)lY)cOfk6WRD4Sw5HH8WWHFyGpSR4iQPKNJO0m))WToSRk2OwO(amx0rOPDNrgI(kFw8VaAHIo8AhoRvEyipmC4hg4d7koIAk5vX9fR(XHHd)WUIJOMsEa8)W0ddh(HDfhrnL8APYHHC3OgOSBeWC(VySE9d1uNSP9QzTHWUrudktgBUUBmhfLUBqjkuwvJUbk0mFeTBCFqYh2Ub4d7koIAk51iDM6tMC4wh2vfBulupQsy9Vi)lGwOOdV2H5YhgYddh(Hb(WUIJOMsEoIsZ8)d36WUQyJAH6dWCrhHM2Dgzi6R8zX)cOfk6WRDyU8HH8WWHFyGpSR4iQPKxf3xS6hhgo8d7koIAk5bW)dtpmC4h2vCe1uYRLkhgYDJAGYUbLOqzvn6gOqZ8r0M2RYfBiSBe1GYKXMR7gZrrP7guLWycrHM2)eO83nUpi5dB3a8HDfhrnL8AKot9jtoCRd7QInQfQhvjS(xK)fqlu0Hx7WCPdd5HHd)WaFyxXrutjphrPz()HBDyxvSrTq9byUOJqt7oJme9v(S4Fb0cfD41omx6WqEy4WpmWh2vCe1uYRI7lw9Jddh(HDfhrnL8a4)HPhgo8d7koIAk51sLdd5Urnqz3GQegtik00(NaL)M20UXvCe1uAdH9Q8SHWUrudktgBUUBCFqYh2UbIhMmMOKpF2uQa7Oqtty2heFVOguMmoCRdd8HDvXg1c1JsablTpShqkZEX)cOfk6WRDyEw5HHd)WUQyJAH6rjGGL2h2diLzV4Fb0cfDyGEyEDLhU1HDvXg1c1JsablTpShqkZEX)cOfk6Wa9WzXRhU1HDLoscY7Q)tYPqt7mrEVOguMmomK7gZrrP7Mamx0rOPDNrgI(kFw20E1S2qy3iQbLjJnx3nUpi5dB3qgtuYNpBkvGDuOPjm7dIVxudktghU1Hhf5ZNnLkWok00eM9bX3tHdqOP7gZrrP7Mamx0rOPDNrgI(kFw20EvUydHDJOguMm2CD34(GKpSDJRk2OwOEuciyP9H9asz2l(xaTqrhgOhMxpCRdd8Hhc0KPj)SLOK)fqlu0Hb6Hx3HHd)Wq8WKXeL8ZwIsErnOmzCyi3nMJIs3ndXfGgfAAhAXOnTxDDBiSBe1GYKXMR7g3hK8HTBG4HjJjk5ZNnLkWok00eM9bX3lQbLjJd36WaFyxvSrTq9OeqWs7d7bKYSx8VaAHIo8AhMxpmC4h2vfBulupkbeS0(WEaPm7f)lGwOOdd0dZRR8WWHFyxvSrTq9OeqWs7d7bKYSx8VaAHIomqpCw86HBDyxPJKG8U6)KCk00otK3lQbLjJdd5UXCuu6UbvjS(x0M2RYRBiSBe1GYKXMR7g3hK8HTBiJjk5ZNnLkWok00eM9bX3lQbLjJd36WJI85ZMsfyhfAAcZ(G47PWbi00DJ5OO0DdQsy9VOnTxLlVHWUXCuu6Ub5QKp00of0SSBe1GYKXMRBAt7Mrr98xY3qyVkpBiSBe1GYKXMR7g3hK8HTBgf5T0s57Fb0cfD41omx6WToSRk2OwOEuciyP9H9asz2l(xaTqrhgOhEuK3slLV)fqlu0UXCuu6UXslL)M2RM1gc7grnOmzS56UX9bjFy7MrrEuKpxANftI)fqlu0Hx7WCPd36WUQyJAH6rjGGL2h2diLzV4Fb0cfDyGE4rrEuKpxANftI)fqlu0UXCuu6Ubf5ZL2zXKSP9QCXgc7grnOmzS56UX9bjFy7Mrr(efrguM0TPjw4OOu)lGwOOdV2H5shU1HDvXg1c1JsablTpShqkZEX)cOfk6Wa9WJI8jkImOmPBttSWrrP(xaTqr7gZrrP7MefrguM0TPjw4OO0nTxDDBiSBe1GYKXMR7g3hK8HTBgf5D1)j5uuQ)fqlu0Hx7WCPd36WUQyJAH6rjGGL2h2diLzV4Fb0cfDyGE4rrEx9FsofL6Fb0cfTBmhfLUBC1)j5uu6M20UzitwcJ2qyVkpBiSBmhfLUBq5cJ1zLdWUrudktgBUUP9QzTHWUXCuu6UziCQKVdAPHB3iQbLjJnx30EvUydHDJOguMm2CD34(GKpSDJ5OGJ0fvadbDyGEyUy3GOpC0EvE2nMJIs3noJX6MJIs7Sar7gwGOUAGYUXkzt7vx3gc7grnOmzS56Uzii3h5uu6UH36OO0dZceHo8u9hM(qbi0HHkZgNOE)HBiJqh2E5WiJJmo8u9hgQmvVC4MkHD4vyrCNPbZfDeA6H5fJme9v(SWnVz2uQapCtOPjm7dI)Ydx0S8lcKC4spSRk2OwO7gZrrP7gNXyDZrrPDwGODdI(Wr7v5z34(GKpSDdfGYHx7W8SBybI6Qbk7g6dfGqDuolOUBwCa20EvEDdHDJOguMm2CD3yokkD34mgRBokkTZceTBybI6Qbk7MHWm(YOtFOaecTP9QC5ne2nIAqzYyZ1DJ7ds(W2naF4rrEuLW6FrEkCacn9WWHF4rr(amx0rOPDNrgI(kFw6JI8u4aeA6HHd)WJI85ZMsfyhfAAcZ(G47PWbi00dd5HBDyuLW6Oz7hhgOhMlomC4hEuKNtWKozHsEkCacn9WWHFyYyIsEuTOtZshjYa5f1GYKXUbrF4O9Q8SBmhfLUBCgJ1nhfL2zbI2nSarD1aLDdImQtFOaecTP9QRGne2nIAqzYyZ1DJ7ds(W2nUIJOMsEnsNP(KjhU1Hb(Wq8WCSpmOmXtFOaeQJYzbDy4WpSRk2OwOEuLW6Fr(xaTqrhgOhoRvEy4WpmWhMJ9HbLjE6dfGq9sLd36WUQyJAH6rvcR)f5Fb0cfD41om9HcqipXJ3vfBulu)lGwOOdd5HHd)WaFyo2hguM4Ppuac1Pf1HBDyxvSrTq9OkH1)I8VaAHIo8AhM(qbiKNYY7QInQfQ)fqlu0HH8WqUBq0hoAVkp7gZrrP7gNXyDZrrPDwGODdlquxnqz3mmqlv60hkaHqBAVkxAdHDJOguMm2CD34(GKpSDJR4iQPKNJO0m))WTomWhgIhMJ9HbLjE6dfGqDuolOddh(HDvXg1c1hG5IocnT7mYq0x5ZI)fqlu0Hb6HZALhgo8dd8H5yFyqzIN(qbiuVu5WToSRk2OwO(amx0rOPDNrgI(kFw8VaAHIo8AhM(qbiKN4X7QInQfQ)fqlu0HH8WWHFyGpmh7ddkt80hkaH60I6WToSRk2OwO(amx0rOPDNrgI(kFw8VaAHIo8AhM(qbiKNYY7QInQfQ)fqlu0HH8WqUBq0hoAVkp7gZrrP7gNXyDZrrPDwGODdlquxnqz3mmqlv60hkaHqBAVkqMne2nIAqzYyZ1DJ7ds(W2naFyxXrutjVkUVy1pomC4h2vCe1uYdG)hMEy4WpSR4iQPKxlvomKhU1Hb(Wq8WCSpmOmXtFOaeQJYzbDy4WpSRk2OwO(8ztPcSJcnnHzFq89VaAHIomqpCwR8WWHFyGpmh7ddkt80hkaH6LkhU1HDvXg1c1NpBkvGDuOPjm7dIV)fqlu0Hx7W0hkaH8epExvSrTq9VaAHIomKhgo8dd8H5yFyqzIN(qbiuNwuhU1HDvXg1c1NpBkvGDuOPjm7dIV)fqlu0Hx7W0hkaH8uwExvSrTq9VaAHIomKhgYDdI(Wr7v5z3yokkD34mgRBokkTZceTBybI6Qbk7MHbAPsN(qbieAt7v5zLBiSBe1GYKXMR7g3hK8HTBG4HjJjk5ZNnLkWok00eM9bX3lQbLjJd36WaFyiEyo2hguM4Ppuac1r5SGomC4h2vfBulupkbeS0(WEaPm7f)lGwOOdd0dN1kpmC4hg4dZX(WGYep9HcqOEPYHBDyxvSrTq9OeqWs7d7bKYSx8VaAHIo8AhM(qbiKN4X7QInQfQ)fqlu0HH8WWHFyGpmh7ddkt80hkaH60I6WToSRk2OwOEuciyP9H9asz2l(xaTqrhETdtFOaeYtz5DvXg1c1)cOfk6WqEyi3ni6dhTxLNDJ5OO0DJZySU5OO0olq0UHfiQRgOSBggOLkD6dfGqOnTxLhE2qy3iQbLjJnx3nMJIs3nGgtMcx)TCk5LDZqqUpYPO0DdxtE9WOkHDy0S9d0HJPdpfPZ0Hd0HngyHOdxCKF34(GKpSDd0cHoCRdpfPZu)fqlu0Hx7WcVlUes6uakhoZXdJQewhnB)4WTo8OiFIIidkt620elCuuQNchGqt30EvEYAdHDJOguMm2CD3meK7JCkkD3KPNoSR4iQP0HhfXnVz2uQapCtOPjm7dI)Hd0H)evdnD5HtqYHbc2diLzVCyQoSW7KOJdtZYHDj)lkDyKq7gZrrP7gNXyDZrrPDwGODJ7ds(W2naFyxXrutjphrPz()HBD4rr(amx0rOPDNrgI(kFw6JI8u4aeA6HBDyxvSrTq9OeqWs7d7bKYSx8VaAHIo8AhoRd36WaF4rr(8ztPcSJcnnHzFq89VaAHIomqpCwhgo8ddXdtgtuYNpBkvGDuOPjm7dIVxudktghgYdd5HHd)WaFyxXrutjVgPZuFYKd36WJI8OkH1)I8u4aeA6HBDyxvSrTq9OeqWs7d7bKYSx8VaAHIo8AhoRd36WaF4rr(8ztPcSJcnnHzFq89VaAHIomqpCwhgo8ddXdtgtuYNpBkvGDuOPjm7dIVxudktghgYdd5HHd)WaFyGpSR4iQPKxf3xS6hhgo8d7koIAk5bW)dtpmC4h2vCe1uYRLkhgYd36WJI85ZMsfyhfAAcZ(G47PWbi00d36WJI85ZMsfyhfAAcZ(G47Fb0cfD41oCwhgYDdlquxnqz3mShqkZEPN)s(M2RYdxSHWUrudktgBUUBgcY9rofLUBwHY0lO5dpkcDyXEg)dhthoTcn9WHs1HTdJMTFCyuUOJqtpC(SHKDJ5OO0DJZySU5OO0olq0UX9bjFy7gGpSR4iQPKxJ0zQpzYHBDyiE4rrEuLW6FrEkCacn9WToSRk2OwOEuLW6Fr(xaTqrhETdVUdd5HHd)WaFyxXrutjphrPz()HBDyiE4rr(amx0rOPDNrgI(kFw6JI8u4aeA6HBDyxvSrTq9byUOJqt7oJme9v(S4Fb0cfD41o86omKhgo8dd8Hb(WUIJOMsEvCFXQFCy4WpSR4iQPKha)pm9WWHFyxXrutjVwQCyipCRdtgtuYNpBkvGDuOPjm7dIVxudktghU1HH4Hhf5ZNnLkWok00eM9bX3tHdqOPhU1HDvXg1c1NpBkvGDuOPjm7dIV)fqlu0Hx7WR7WqUBybI6Qbk7Mrr98xY30EvEw3gc7grnOmzS56UXCuu6UzypGoQsy7MHGCFKtrP7Mm90H5nZMsf4HBcnnHzFq8pCGomfoaHMU8WbD4aDyKnjhMQdNGKddeShWHBQe2UX9bjFy7Mrr(8ztPcSJcnnHzFq89u4aeA6M2RYdVUHWUrudktgBUUBCFqYh2UbIhMmMOKpF2uQa7Oqtty2heFVOguMmoCRdd8Hhf5rvcR)f5PWbi00ddh(Hhf5dWCrhHM2Dgzi6R8zPpkYtHdqOPhgYDJ5OO0DZWEaDuLW20EvE4YBiSBe1GYKXMR7gZrrP7M8ztPcSJcnnHzFq83ndb5(iNIs3nn8v3H5nZMsf4HBcnnHzFq8p8IGMpCMBrPz(p3RgPZ0HZCzYHDfhrnLo8OOLhUOz5xei5Wji5WLEyxvSrTq9hotpD4mvWC(VySdN59d1uNCyOjtthoqhouxbgA6YdpxSXHtukyhoOSrh(fBW)WaZdx6WiXv6aDyBIK)WjibYDJ7ds(W2nUIJOMsEnsNP(KjhU1HPauomqpmVE4wh2vfBulupQsy9Vi)lGwOOdV2H55WTomWh2vfBuluVaMZ)fJ1RFOM6e)lGwOOdV2H5HlN1HHd)Wq8WcqkjYZLHxaZ5)IX61putDYHHCt7v5zfSHWUrudktgBUUBCFqYh2UXvCe1uYZruAM)F4whMcq5Wa9W86HBDyxvSrTq9byUOJqt7oJme9v(S4Fb0cfD41omphU1Hb(WUQyJAH6fWC(VySE9d1uN4Fb0cfD41ompC5SomC4hgIhwasjrEUm8cyo)xmwV(HAQtomK7gZrrP7M8ztPcSJcnnHzFq830EvE4sBiSBe1GYKXMR7g3hK8HTBa(WUIJOMsEvCFXQFCy4WpSR4iQPKha)pm9WWHFyxXrutjVwQCyipCRdd8HDvXg1c1lG58FXy96hQPoX)cOfk6WRDyE4YzDy4WpmepSaKsI8Cz4fWC(VySE9d1uNCyi3nMJIs3n5ZMsfyhfAAcZ(G4VP9Q8aKzdHDJOguMm2CD34(GKpSDd0cHoCRdpfPZu)fqlu0Hx7W8WL3nMJIs3n5ZMsfyhfAAcZ(G4VP9QzTYne2nIAqzYyZ1DZqqUpYPO0DtME6W8MztPc8WnHMMWSpi(hoqhMchGqtxE4GYgDykaLdt1HtqYHlAw(ddAa5R)WJIq7gZrrP7gNXyDZrrPDwGODJ7ds(W2nJI85ZMsfyhfAAcZ(G47PWbi00d36WaFyxXrutjVgPZuFYKddh(HDfhrnL8CeLM5)hgYDdlquxnqz34koIAkTP9QzXZgc7grnOmzS56UXCuu6UXslL)UX9bjFy7MrrElTu((xaTqrhETdVUDJJVJjDY(uHq7v5zt7vZkRne2nMJIs3nZwIs7grnOmzS56M2RMfxSHWUrudktgBUUBmhfLUBqIm61u3v)NKtrP7MHGCFKtrP7MMAXHPz5WnImqhU0dZfhMSpvi0HJPdh0HdKMnDyxY)Ism(ho0dpXI0z6W1F4spmnlhMSpvi)HZ8dA(Wnr(CPhotIj5WbLn6WgdvhgQqK8hMQdNGKd3iY4Wfh5pmOPjgJX)WwEoJFOPhMlomVu)NKtrPi)UX9bjFy7gZrbhPlQagc6Wa9WzD4whMmMOKhvl60S0rImqErnOmzC4whgIhEuKhjYOxtDx9FsofL6PWbi00d36Wq8WH2Nyr6mTP9QzTUne2nIAqzYyZ1DJ7ds(W2nMJcosxubme0Hb6HZ6WTomzmrjpkYNlTZIjXlQbLjJd36Wq8WJI8irg9AQ7Q)tYPOupfoaHME4whgIho0(elsNPd36WJI8U6)KCkk1)cOfk6WRD41TBmhfLUBqIm61u3v)NKtrPBAVAw86gc7grnOmzS56UX9bjFy7gGpmQsyD0S9Jdd0dZZHHd)WMJcosxubme0Hb6HZ6WqE4wh2vfBulupkbeS0(WEaPm7f)lGwOOdd0dZtw7gZrrP7gobt6KfkTP9QzXL3qy3iQbLjJnx3nUpi5dB3yok4i9rr(efrguM0TPjw4OO0dd7WR8WWHFykCacn9WTo8OiFIIidkt620elCuuQ)fqlu0Hx7WRB3yokkD3KOiYGYKUnnXchfLUP9QzTc2qy3iQbLjJnx3nMJIs3nOiFU0olMKDJ7ds(W2nJI8OiFU0olMe)lGwOOdV2Hx3UXX3XKozFQqO9Q8SP9QzXL2qy3iQbLjJnx3nUpi5dB3aXd7koIAk5vX9fR(XUbrF4O9Q8SBmhfLUBCgJ1nhfL2zbI2nSarD1aLDJR4iQP0M2RMfqMne2nIAqzYyZ1DJ5OO0DJR(pjNIs3no(oM0j7tfcTxLNDJ7ds(W2nMJcosxubme0Hx7WR7WaXdd8HjJjk5r1IonlDKidKxudktghgo8dtgtuYJI85s7Sys8IAqzY4WqE4whEuK3v)NKtrP(xaTqrhETdN1Uzii3h5uu6UH3MNZ4FyEP(pjNIspmOPjgJX)WLEyEaIzDyY(uHqlpC9hU0dZfhErqZhM3cfvSesomVu)NKtrPBAVkxSYne2nIAqzYyZ1DJ5OO0DdOXKPW1FlNsEz3meK7JCkkD3WBNi5pmnlhUYfv(LhgLl64W2HrZ2po8IzrpSrhMxpCPhotXyYu4o8k0YPKxomvh24uX4Wfh5DwEEOP7g3hK8HTBqvcRJMTFCyGE41D4whMcq5Wa9WzXZM2RYf8SHWUrudktgBUUBgcY9rofLUBY8Nf9WArhgXxDHMEyEZSPubE4Mqtty2he)dt1HZClknZ)5E1iDMoCMltwE4MeqWspmqWEaPm7Ldhth2ySdpkcDy7LdB55Sqg7gZrrP7gNXyDZrrPDwGODJ7ds(W2naFyxXrutjphrPz()HBDyiEyYyIs(8ztPcSJcnnHzFq89IAqzY4WTo8OiFaMl6i00UZidrFLpl9rrEkCacn9WToSRk2OwOEuciyP9H9asz2l(xSb)dd5HHd)WaFyxXrutjVgPZuFYKd36Wq8WKXeL85ZMsfyhfAAcZ(G47f1GYKXHBD4rrEuLW6FrEkCacn9WToSRk2OwOEuciyP9H9asz2l(xSb)dd5HHd)WaFyGpSR4iQPKxf3xS6hhgo8d7koIAk5bW)dtpmC4h2vCe1uYRLkhgYd36WUQyJAH6rjGGL2h2diLzV4FXg8pmK7gwGOUAGYUzypGuM9sp)L8nTxLlYAdHDJOguMm2CD3yokkD3mShqhvjSDZqqUpYPO0DtMtKCyGG9aoCtLWoCmDyGG9asz2lhErPzthgQC4xSb)dBPwOlpC9hoMomnlVC4fbJDyOYHn6WmXq0HZ6WG1lhgiypGuM9YHtqcA34(GKpSDd0cHoCRd7QInQfQhLacwAFypGuM9I)fqlu0Hb6HNI0zQ)cOfk6WTomWhgIhMmMOKpF2uQa7Oqtty2heFVOguMmomC4h2vfBuluF(SPub2rHMMWSpi((xaTqrhgOhEksNP(lGwOOdd5M2RYfCXgc7grnOmzS56UX9bjFy7gOfcD4whgIhMmMOKpF2uQa7Oqtty2heFVOguMmoCRd7QInQfQhLacwAFypGuM9I)fqlu0HZ4WUQyJAH6rjGGL2h2diLzV4hjVrrPhETdpfPZu)fqlu0UXCuu6UzypGoQsyBAVkxSUne2nIAqzYyZ1DZqqUpYPO0DdVyKBgiAm2HdsapCcYsLdpv)HnLpnhA6H1IomkxCXuiJdlmKSywEz3yokkD34mgRBokkTZceTBybI6Qbk7MGeWnTxLl41ne2nIAqzYyZ1DJ7ds(W2nmHJWomqpmVUcoCRdd8Hhc0KPjpA2g1IUac9nN4rK5aC41omWhoRddepS5OOupA2g1Io0Ir(q7tSiDMomKhgo8dpeOjttE0SnQfDbe6BoX)cOfk6WRDyU4WqUBmhfLUBCgJ1nhfL2zbI2nSarD1aLDds20EvUGlVHWUrudktgBUUBmhfLUBanMmfU(B5uYl7MHGCFKtrP7MmNi5WzkgtMc3HxHwoL8YHxml6HbnG81F4rrOdBVC4K8LhU(dhthMMLxo8IGXomu5WOivJPWzkDykaLdNOuWomnlhwfENomVz2uQapCtOPjm7dI)UX9bjFy7MrrEobt6Kfk5PWbi00ddh(Hhf5dWCrhHM2Dgzi6R8zPpkYtHdqOPhgo8dpkYJQew)lYtHdqOPBAVkxSc2qy3iQbLjJnx3nUpi5dB3qgtuYNpBkvGDuOPjm7dIVxudktghU1Hb(WJI85ZMsfyhfAAcZ(G47PWbi00ddh(HDvXg1c1NpBkvGDuOPjm7dIVN(eP)cOfk6Wa9WzXRhgo8ddTqOd36Wtr6m1Fb0cfD41oSRk2OwO(8ztPcSJcnnHzFq89VaAHIomK7gZrrP7gqJjtHR)woL8YM2RYfCPne2nIAqzYyZ1DJ7ds(W2nKXeL8OArNMLosKbYlQbLjJDJ5OO0DdOXKPW1FlNsEzt7v5cGmBiSBe1GYKXMR7gZrrP7MXBH2zXKSBgcY9rofLUBacVf6HZKysoCGoCPm(h2omqG30C4ul0dViO5dNPvHtqguMCyGGagi5WQy)HbnE)WiYCaq(dNPNo8uKothoqh2Gwj0HP6WIoo8OoSw0Hbde6WOCrhHMEyAwomImha0UX9bjFy7gOjtt(qfobzqzsFiGbs8iYCaomqp86w5HHd)WqtMM8HkCcYGYK(qadK4tYpCRddTqOd36Wtr6m1Fb0cfD41o8620E11TYne2nIAqzYyZ1DJ5OO0DJZySU5OO0olq0UHfiQRgOSBCfhrnL20E11XZgc7grnOmzS56UXCuu6UXslL)UX9bjFy7MxMEbnBqzYUXX3XKozFQqO9Q8SP9QRlRne2nIAqzYyZ1DJ7ds(W2nMJcosFuKprrKbLjDBAIfokk9WWo8kpmC4hMchGqtpCRd)Y0lOzdkt2nMJIs3njkImOmPBttSWrrPBAV664Ine2nIAqzYyZ1DJ5OO0DdkYNlTZIjz34(GKpSDZltVGMnOmz3447ysNSpvi0EvE20E11TUne2nIAqzYyZ1DJ5OO0DJR(pjNIs3nUpi5dB38Y0lOzdktoCRdBok4iDrfWqqhETdVUddepmWhMmMOKhvl60S0rImqErnOmzCy4WpmzmrjpkYNlTZIjXlQbLjJdd5UXX3XKozFQqO9Q8SP9QRJx3qy3ekj)NKt7gE2nMJIs3nJ3cTJQe2UrudktgBUUP9QRJlVHWUXCuu6UbnBJArhAXODJOguMm2CDtBA3K)IRaHA0gc7v5zdHDJOguMm2CD34(GKpSDdfGYHb6Hx5HBDyiE4CH8gl4ihU1HH4HHMmn5t)aSIx61uhzUpMcN4tY3nMJIs3ntcRpkWqnkkDt7vZAdHDJ5OO0DdkbeS0(KWMtus(DJOguMm2CDt7v5Ine2nIAqzYyZ1DJ7ds(W2nKXeL8PFawXl9AQJm3htHt8IAqzYy3yokkD3K(byfV0RPoYCFmfozt7vx3gc7grnOmzS56UPY3niH2nMJIs3nCSpmOmz3WXyjYUXCuWr6JI8U6)KCkk9Wa9WR8WToS5OGJ0hf5T0s5FyGE4vE4wh2CuWr6JI8jkImOmPBttSWrrPhgOhELhU1Hb(Wq8WKXeL8OiFU0olMeVOguMmomC4h2CuWr6JI8OiFU0olMKdd0dVYdd5HBDyGp8OiF(SPub2rHMMWSpi(EkCacn9WWHFyiEyYyIs(8ztPcSJcnnHzFq89IAqzY4WqUB4yFxnqz3mkc1FXg830EvEDdHDJOguMm2CD3OgOSBSmhqZ2BO(uPuVM651c53nMJIs3nwMdOz7nuFQuQxt98AH8BAVkxEdHDJOguMm2CD3yokkD3Gez0RPUR(pjNIs3nUpi5dB3GYfgRt2NkeYJez0RPUR(pjNIs7wjhgOWomxSByHkD3y3WZk30E1vWgc7gZrrP7MzlrPDJOguMm2CDt7v5sBiSBmhfLUBsuezqzs3MMyHJIs3nIAqzYyZ1nTPDJvYgc7v5zdHDJ5OO0Dt(SPub2rHMMWSpi(7grnOmzS56M2RM1gc7gZrrP7MzlrPDJOguMm2CDt7v5Ine2nIAqzYyZ1DJ7ds(W2naFyxXrutjphrPz()HBD4rr(amx0rOPDNrgI(kFw6JI8u4aeA6HBDyxvSrTq9OeqWs7d7bKYSx8Vyd(hU1Hb(WJI85ZMsfyhfAAcZ(G47Fb0cfDyGE4SomC4hgIhMmMOKpF2uQa7Oqtty2heFVOguMmomKhgYddh(Hb(WUIJOMsEnsNP(KjhU1Hhf5rvcR)f5PWbi00d36WUQyJAH6rjGGL2h2diLzV4FXg8pCRdd8Hhf5ZNnLkWok00eM9bX3)cOfk6Wa9WzDy4WpmepmzmrjF(SPub2rHMMWSpi(ErnOmzCyipmKhU1Hb(WaFyxXrutjVkUVy1pomC4h2vCe1uYdG)hMEy4WpSR4iQPKxlvomKhU1Hhf5ZNnLkWok00eM9bX3tHdqOPhU1Hhf5ZNnLkWok00eM9bX3)cOfk6WRD4SomK7gZrrP7gNXyDZrrPDwGODdlquxnqz3mShqkZEPN)s(M2RUUne2nIAqzYyZ1DJ7ds(W2nKXeL8OArNMLosKbYlQbLjJd36Wot7irg7gZrrP7gKiJEn1D1)j5uu6M2RYRBiSBe1GYKXMR7g3hK8HTBG4HjJjk5r1IonlDKidKxudktghU1HH4Hhf5rIm61u3v)NKtrPEkCacn9WTomepCO9jwKothU1Hhf5D1)j5uuQ)LPxqZguMSBmhfLUBqIm61u3v)NKtrPBAVkxEdHDJOguMm2CD3yokkD3yPLYF34(GKpSDJ5OGJ0hf5T0s5F41o86oCRd)Y0lOzdkt2no(oM0j7tfcTxLNnTxDfSHWUrudktgBUUBmhfLUBS0s5VBCFqYh2UXCuWr6JI8wAP8pmqHD41D4wh(LPxqZguMC4whEuK3slLVNchGqt3no(oM0j7tfcTxLNnTxLlTHWUrudktgBUUBCFqYh2UXCuWr6JI8jkImOmPBttSWrrPhg2Hx5HHd)Wu4aeA6HBD4xMEbnBqzYUXCuu6UjrrKbLjDBAIfokkDt7vbYSHWUrudktgBUUBmhfLUBsuezqzs3MMyHJIs3nUpi5dB3aXdtHdqOPhU1HZ5KtgtuY)gyUPu3MMyHJIsrErnOmzC4wh2CuWr6JI8jkImOmPBttSWrrPhETdZf7ghFht6K9PcH2RYZM2RYZk3qy3iQbLjJnx3nUpi5dB3GQewhnB)4Wa9W8SBmhfLUB4emPtwO0M2RYdpBiSBe1GYKXMR7g3hK8HTBG4HDfhrnL8Q4(Iv)y3GOpC0EvE2nMJIs3noJX6MJIs7Sar7gwGOUAGYUXvCe1uAt7v5jRne2nIAqzYyZ1DJ7ds(W2naFyxXrutjphrPz()HBDyGpSRk2OwO(amx0rOPDNrgI(kFw8Vyd(hgo8dpkYhG5IocnT7mYq0x5ZsFuKNchGqtpmKhU1HDvXg1c1JsablTpShqkZEX)In4F4whg4dpkYNpBkvGDuOPjm7dIV)fqlu0Hb6HZ6WWHFyiEyYyIs(8ztPcSJcnnHzFq89IAqzY4WqEyipCRdd8Hb(WUIJOMsEvCFXQFCy4WpSR4iQPKha)pm9WWHFyxXrutjVwQCyipCRd7QInQfQhLacwAFypGuM9I)fqlu0Hx7WzD4whg4dpkYNpBkvGDuOPjm7dIV)fqlu0Hb6HZ6WWHFyiEyYyIs(8ztPcSJcnnHzFq89IAqzY4WqEyipmC4hg4d7koIAk51iDM6tMC4whg4d7QInQfQhvjS(xK)fBW)WWHF4rrEuLW6FrEkCacn9WqE4wh2vfBulupkbeS0(WEaPm7f)lGwOOdV2HZ6WTomWhEuKpF2uQa7Oqtty2heF)lGwOOdd0dN1HHd)Wq8WKXeL85ZMsfyhfAAcZ(G47f1GYKXHH8WqUBmhfLUBCgJ1nhfL2zbI2nSarD1aLDZWEaPm7LE(l5BAVkpCXgc7grnOmzS56UX9bjFy7gOfcD4wh2vfBulupkbeS0(WEaPm7f)lGwOOdd0dpfPZu)fqlu0HBDyGpmepmzmrjF(SPub2rHMMWSpi(ErnOmzCy4WpSRk2OwO(8ztPcSJcnnHzFq89VaAHIomqp8uKot9xaTqrhgYDJ5OO0DZWEaDuLW20EvEw3gc7grnOmzS56UX9bjFy7gOfcD4wh2vfBulupkbeS0(WEaPm7f)lGwOOdNXHDvXg1c1JsablTpShqkZEXpsEJIsp8AhEksNP(lGwOODJ5OO0DZWEaDuLW20EvE41ne2nIAqzYyZ1DJ5OO0DJZySU5OO0olq0UHfiQRgOSBcsa30EvE4YBiSBe1GYKXMR7gZrrP7gNXyDZrrPDwGODdlquxnqz3meMXxgD6dfGqOnTxLNvWgc7grnOmzS56UXCuu6UXzmw3CuuANfiA3Wce1vdu2ndd0sLo9Hcqi0M2RYdxAdHDJOguMm2CD34(GKpSDZOiF(SPub2rHMMWSpi(EkCacn9WWHFyiEyYyIs(8ztPcSJcnnHzFq89IAqzYy3yokkD34mgRBokkTZceTBybI6Qbk7gezuN(qbieAt7v5biZgc7grnOmzS56UX9bjFy7MrrEobt6Kfk5PWbi00DJ5OO0DdOXKPW1FlNsEzt7vZALBiSBe1GYKXMR7g3hK8HTBgf5rvcR)f5PWbi00d36Wq8WKXeL8OArNMLosKbYlQbLjJDJ5OO0DdOXKPW1FlNsEzt7vZINne2nIAqzYyZ1DJ7ds(W2nq8WKXeL8CcM0jluYlQbLjJDJ5OO0DdOXKPW1FlNsEzt7vZkRne2nIAqzYyZ1DJ7ds(W2nOkH1rZ2pomqp862nMJIs3nGgtMcx)TCk5LnTxnlUydHDJOguMm2CD3yokkD3GI85s7Sys2nUpi5dB3yok4i9rrEuKpxANftYHxd2H5Id36WVm9cA2GYKd36Wq8WJI8OiFU0olMepfoaHMUBC8DmPt2NkeAVkpBAVAwRBdHDJOguMm2CD34(GKpSDJR4iQPKxf3xS6h7ge9HJ2RYZUXCuu6UXzmw3CuuANfiA3Wce1vdu2nUIJOMsBAVAw86gc7grnOmzS56UX9bjFy7gOjtt(qfobzqzsFiGbs8iYCaomqHDyEDLhgo8ddTqOd36WqtMM8HkCcYGYK(qadK4tYpCRdpfPZu)fqlu0Hx7W86HHd)WqtMM8HkCcYGYK(qadK4rK5aCyGc7WCbVE4whEuKhvjS(xKNchGqt3nMJIs3nJ3cTZIjzt7vZIlVHWUjus(pjN2n8SBmhfLUBgVfAhvjSDJOguMm2CDt7vZAfSHWUXCuu6UbnBJArhAXODJOguMm2CDtBA3GiJ60hkaHqBiSxLNne2nIAqzYyZ1DJAGYUjuK7tidkt6aPetPeW(q4eoz3yokkD3ekY9jKbLjDGuIPucyFiCcNSP9QzTHWUrudktgBUUBudu2nHIOpXr1J6JGtOshQWy7gZrrP7Mqr0N4O6r9rWjuPdvySnTxLl2qy3iQbLjJnx3nQbk7MIJ8tSArOPDtdqR7Suz3yokkD3uCKFIvlcnTBAaADNLkBAV662qy3iQbLjJnx3nQbk7MH9aaRs7dXbONNqVGCI6KDJ5OO0DZWEaGvP9H4a0ZtOxqorDYM2RYRBiSBe1GYKXMR7g1aLDdO5mOV0rZIqDWeu42nMJIs3nGMZG(shnlc1btqHBt7v5YBiSBe1GYKXMR7g1aLDZeZaLEn1HAeXKDJ5OO0DZeZaLEn1HAeXKnTxDfSHWUrudktgBUUBudu2nlmaIkpQp9Lo2nMJIs3nlmaIkpQp9Lo20EvU0gc7grnOmzS56Urnqz3qguMq9AQpeuUf)UXCuu6UHmOmH61uFiOCl(nTxfiZgc7grnOmzS56Urnqz3GcDkH1nuE8MsOouBKk9AQpjF5cI)UXCuu6Ubf6ucRBO84nLqDO2iv61uFs(Yfe)nTxLNvUHWUrudktgBUUBudu2nOqNsy9uMncJQh1HAJuPxt9j5lxq83nMJIs3nOqNsy9uMncJQh1HAJuPxt9j5lxq830EvE4zdHDJ5OO0DduwvJ(uYZF3iQbLjJnx30EvEYAdHDJ5OO0DZu8cuwvJDJOguMm2CDt7v5Hl2qy3yokkD3avEK8acnD3iQbLjJnx30M2nizdH9Q8SHWUXCuu6Uz2suA3iQbLjJnx30E1S2qy3iQbLjJnx3nHsY)j5upM2ndbAY0KhnBJArxaH(Mt8iYCaakmUy3yokkD3mEl0oQsy7Mqj5)KCQNYkOgB3WZM2RYfBiSBmhfLUBqZ2Ow0HwmA3iQbLjJnx30M2nbjGBiSxLNne2nMJIs3njiPhKaI2nIAqzYyZ1nTPnTPnT3a]] )


end